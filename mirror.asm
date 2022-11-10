# Student ID = 260897013
########################## mirror #######################
.data
.text
.globl mirror_horizontally
########################## mirror #######################
mirror_horizontally:
	# $a0 -> image struct
	###############return################
	# $v0 -> image struct s.t. mirrored image horizontally. 
	
	
	#Add your codes here
	
	move $s0, $a0	# struct to iterate
	move $s1, $s0	# struct starting location
	addi $sp, $sp, 4
	sw $s0, 0($sp)	# store beginning location of struct
	
	lw $s2, 4($s0)	# load number of rows
	lw $s3, 0($s0)	# load number of collums

	li $s4, 0	# row counter
	li $s5, 0	# collum counter
	
mirrorLoop:
	addi $s6, $s3, -1	# get to the last pixel of each role
	li $s5, 0	# reset collum counter
mirrorLoopA:
	ble $s6, $s5, mirrorLoopEnd # if two pointer pass through each other, then the mirroring is complete for that row
	
	move $s0, $s1	# reset struct address
	mult $s3, $s4	# total length value times (current row - 1) is the start of the  the collum of the row
	mflo $t0	# get start of collum
	add $s0, $s0, $t0	#increases struct index	
	add $s0, $s0, $s5	#increase to the collum
	addi $s0, $s0, 12	#pass through 12 bytes of header	
	lb $t9, 0($s0)
	
	sub $s0, $s0, $s5	# go back to beginning of the row and now go to the location to mirror
	add $s0, $s0, $s6
	lb $t8, 0($s0)
	sb $t9, 0($s0)		# store value of t9, to collum of t8
	
	sub $s0, $s0, $s6	# fo back to the origin again, now go do the reverse thing to the collum at t9
	add $s0, $s0, $s5	
	sb $t8, 0($s0)
	
	addi $s5, $s5,1	# increase forward pointer 
	addi $s6, $s6, -1	# decrease backward pointer
	j mirrorLoopA

mirrorLoopEnd:
	addi $s4, $s4, 1	# add 1 to row
	bne $s4, $s2, mirrorLoop	# if not the last row, continue loop
	j mirror_horizontally.return	# else return

	

mirror_horizontally.return:
	lw $v0, 0($sp)
	addi $sp, $sp, 4
	jr $ra

