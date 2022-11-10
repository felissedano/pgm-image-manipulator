# Student ID = 260897013
###############################image boundary######################
.data
.text
.globl image_boundary
##########################image boundary##################
image_boundary:
	# $a0 -> image struct
	############return###########
	# $v0 -> image struct s.t. contents containing only binary values 0,1


        # Add code here
        
        move $s0, $a0	# struct to iterate
	move $s1, $s0	# struct starting location
	
        lw $s2, 4($s0)	# load number of rows
	lw $s3, 0($s0)	# load number of collums
	
	# create a new struct to store result image
	mult $s2, $s3
	mflo $t0
	addi $t0, $t0, 12
	move $a0, $t0
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)	
	jal malloc
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	move $s6, $v0
	
	# store the starting address to stack pointer
	addi $sp, $sp, -4
	sw $s6, 0($sp)
	
	# store header info to new struct
	sw $s3, 0($s6)
	sw $s2, 4($s6)
	lw $t0, 8($s0)
	sw $t0, 8($s6)
	addi $s6, $s6, 12	# go to content section
	
	
	# since no pixels on four side of edges, we only need to count till the second las collum of the sendcond last row
	addi $s2, $s2, -1


	li $s4, 0	# row counter	no pixels on edges so start at 1
	li $s5, 0	# collum counter	same as above
	
	
boundLoop:
	li $s5, 0	# each boundloop row increase, collum reset
	
boundLoopA:

	beq $s5,0, boundLoopEndA
	beq $s4,0, boundLoopEndA

	move $s0, $s1	# reset struct address
	mult $s3, $s4	# total length value times (current row - 1) is the start of the  the collum of the row
	mflo $t0	# get start of collum
	add $s0, $s0, $t0	#increases struct index	
	add $s0, $s0, $s5	#increase to the collum
	addi $s0, $s0, 12	#pass through 12 bytes of header
	lb $t9, 0($s0)		#get pixel
	
	beq $t9, 0, boundLoopEndA	# if its background pixel then go to the next pixel
	
	# now check four side of current pixel
	lb $t8, -1($s0)		# get pi -1 (left collum)
	beq $t8, 0, boundLoopEndB	# if t8 = 0, then its a background, and t9 is a boundary
	
	lb $t8, 1($s0)		# get pi + 1 (right collum)
	beq $t8, 0, boundLoopEndB	# if t8 = 0, then its a background, and t9 is a boundary
	
	sub $s0, $s0, $s3	# get up pixel by substracting a row
	lb $t8, 0($s0)
	add $s0, $s0, $s3	# go back to the original pixel
	beq $t8, 0, boundLoopEndB	# if t8 = 0, then its a background, and t9 is a boundary
	
        add $s0, $s0, $s3	# go to the next row
        lb $t8, 0($s0)
        sub $s0, $s0, $s3	# go back to the original row
	beq $t8, 0, boundLoopEndB  	# if t8 = 0, then its a background, and t9 is a boundary
	
	j boundLoopEndC		# its a surrounded pixel, set the value to 0
	
boundLoopEndA:	# if pi is background pixel
	li $t7, 0
	sb $t7, 0($s6)	# store 0 to new struct and go to the next slot
	addi $s6, $s6, 1
	
	addi $s5, $s5, 1	# increase current collum
	beq $s5, $s3, boundLoopEnd	# if end of the collum
	j boundLoopA	# if still has next collum, continue the loop in that row
	
boundLoopEndB:	# if pi is boundary
	li $t7, 1
	sb $t7, 0($s6)	# store 0 to new struct and go to the next slot
	addi $s6, $s6, 1
	
	addi $s5, $s5, 1	# increase current collum
	beq $s5, $s3, boundLoopEnd	# if end of the collum
	j boundLoopA	# if still has next collum, continue the loop in that row
	
boundLoopEndC:	# if pi is inside
	li $t7, 0
	sb $t7, 0($s6)	# store 0 to new struct and go to the next slot
	addi $s6, $s6, 1
	
	addi $s5, $s5, 1	# increase current collum
	beq $s5, $s3, boundLoopEnd	# if end of the collum
	j boundLoopA	# if still has next collum, continue the loop in that row
	
boundLoopEnd:
	beq $s4, $s2, image_boundary.return 	# if both end of last row and collum, then return
	addi $s4, $s4, 1
	j boundLoop	# reset collum counter

image_boundary.return:

	lw $s6, 0($sp)
	addi $sp, $sp, 4
	move $v0, $s6
	jr $ra
