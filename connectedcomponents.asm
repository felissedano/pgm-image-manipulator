# Student ID = 260897013
###############################connected components######################
.data
k:	.space 20
.text
.globl connected_components
########################## connected components ##################
connected_components:
	# $a0 -> image struct
	############return###########
	# $v0 -> image struct with labelled connected components
	# $v1 -> number of connected components (equivalent to number of unique labels)
	
	
	# Add code here
	move $s0, $a0	# struct to iterate
	move $s1, $s0	# struct starting location
	addi $sp, $sp, 4
	sw $s0, 0($sp)	# store beginning location of struct
	
	lw $s2, 4($s0)	# load number of rows
	lw $s3, 0($s0)	# load number of collums

	li $s4, 1	# row counter	no pixels on edges so start at 1
	li $s5, 1	# collum counter	same as above
	
	li $s6, 1	# this will be the label counter
	la $s7, k	#address of an array that act like disjoint set, if label n exists then it will stored at nth location of array
			# and if label n and n + i are related, then k[n+i] will have value n
	
bigLoop1:
	li $s5, 1	# each bigloop row increase, collum reset
bigLoop1a:
	move $s0, $s1	# reset struct address
	mult $s3, $s4	# total length value times (current row - 1) is the start of the  the collum of the row
	mflo $t0	# get start of collum
	add $s0, $s0, $t0	#increases struct index	
	add $s0, $s0, $s5	#increase to the collum
	addi $s0, $s0, 12	#pass through 12 bytes of header
	lb $t9, 0($s0)		#get pi
	
	beq $t9, 0, bigLoop1End	# if its background pixel then go to the next pixel
	
	lb $t8, -1($s0)		# get pi -1 (left collum)
	sub $s0, $s0, $s3	# get up pixel by substracting a row
	lb $t7, 0($s0)
	add $s0, $s0, $s3	# go back to the original pixel
	
	beq $t7, 0, loop1Case1
	beq $t8, 0, loop1Case2b
	j loop1Case3
	
########################
loop1Case1:	# both up and left are 0
	bne $t8, 0, loop1Case2a
	
	sb $s6, 0($s0)	# if both up and left are 0s, then assign label to pi
	move $t5, $s7	# load adress of disjoint set array k
	add $t5, $t5, $s6	# store the label of s6 at  the $s6th byte location
	sb $s6, 0($t5)		# store the label n at k[n]
	
	addi $s6, $s6, 1  # increase label count
	j bigLoop1End
loop1Case2a:	# $t7 is 0 but $t8 isnt
	sb $t8, 0($s0)
	j bigLoop1End
loop1Case2b:	# $t7 is not 0 but $t8 is
	sb $t7, 0($s0)
	j bigLoop1End
loop1Case3:	# if both arent 0s find which one has the min value
	blt $t7, $t8, loop1Case3a	# if t7 is smaller than t8, then assign t7s lable
	sb $t8, 0($s0)
	
	move $t5, $s7	# load adress of disjoint set array k
	add $t5, $t5, $t8	# t8 is smaller, so associate t7 with t8 by giving the value of k[t8] at k[t7]
	lb $t4, 0($t5)		# load the assocaited label
	move $t5, $s7	# reset address and now go to k[t7]
	add $t5, $t5, $t7	# now go to address of t7
	sb $t4, 0($t5)		# and stored the associated lavel
	
	j bigLoop1End
loop1Case3a:
	sb $t7, 0($s0)
	
	move $t5, $s7	# load adress of disjoint set array k
	add $t5, $t5, $t7	# t7 is smaller, so associate t8 with t7 by giving the value of k[t7] at k[t8]
	lb $t4, 0($t5)		# load the assocaited label
	move $t5, $s7	# reset address and now go to k[t8]
	add $t5, $t5, $t8	# now go to address of t8
	sb $t4, 0($t5)		# and stored the associated lavel
	
	j bigLoop1End
###############################################
	

bigLoop1End:
	addi $s5, $s5, 1	# increase current collum
	beq $s5, $s3, bigLoop1EndA	# if end of the collum
	j bigLoop1a	# if still has next collum, continue the loop in that row
bigLoop1EndA:
	beq $s4, $s2, bigLoop2 		# if both end of last row and collum, then go to loop2
	
	addi $s4, $s4, 1
	j bigLoop1	# reset collum counter
	

bigLoop2:
	li $s4, 1	# row counter	no pixels on edges so start at 1
	li $s5, 1	# collum counter	same as above
	
bigLoop2a:
	li $s5, 1	# each bigloop row increase, collum reset
bigLoop2b:
	move $s0, $s1	# reset struct address
	mult $s3, $s4	# total length value times (current row - 1) is the start of the  the collum of the row
	mflo $t0	# get start of collum
	add $s0, $s0, $t0	#increases struct index	
	add $s0, $s0, $s5	#increase to the collum
	addi $s0, $s0, 12	#pass through 12 bytes of header
	lb $t9, 0($s0)		#get pi
	
	beq $t9, 0, bigLoop2End	# if its background pixel then go to the next pixel
	
	move $t5, $s7	# load adress of disjoint set array k
	add $t5, $t5, $t9	# get to k[t9]
	lb $t4, 0($t5)		# load the assocaited label
	sb $t4, 0($s0)		# store the label to struct location of $t9

bigLoop2End:
	addi $s5, $s5, 1	# increase current collum
	beq $s5, $s3, bigLoop2EndA	# if end of the collum
	j bigLoop2b	# if still has next collum, continue the loop in that row
	
bigLoop2EndA:
	beq $s4, $s2, uniqueCount	# if both end of last row and collum, then end 
	addi $s4, $s4, 1
	j bigLoop2a	# reset collum counter
	
uniqueCount:	# iterate element 
	move $s4, $s6	
	li $s5, 1	# s5 is the index for k
	li $v1, 0	# count unique components
countLoopA:
	move $t5, $s7	# load k
	add $t5, $t5, $s5	#get to index i
	lb $t4, 0($t5)
	beq $t4, $s5, countLoopEnd	# if the value of k[s5] = s5, it means its the root of a unique connect component
	addi $s5, $s5, 1	# go to the next element
	blt $s5, $s6, countLoopA	# if not all existed labels have been visited, continue loop
	j connected_components.return	# else return
	
countLoopEnd:	
	addi $v1, $v1, 1	# compponent count +1
	addi $s5, $s5, 1	# go to the next element
	blt $s5, $s6, countLoopA # if not all existed labels have been visited, continue loop
	j connected_components.return	# else return
	
	

connected_components.return:

	move $v1, $v1
	lw $v0, 0($sp)
	addi $sp, $sp, 4
	jr $ra
