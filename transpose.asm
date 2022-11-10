# Student ID = 260897013
##########################image transpose##################
.data
.text
.globl transpose
##########################image transpose##################
transpose:
	# $a0 -> image struct
	###############return################
	# $v0 -> image struct s.t. contents containing the transpose image.
	# Note that you need to rewrite width, height and max_value information
	
	
	# Adds your codes here 
	
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
	sw $s3, 4($s6)
	sw $s2, 0($s6)
	lw $t0, 8($s0)
	sw $t0, 8($s6)
	
	addi $s6, $s6, 12	# go to content section of new struct
	
	li $s4, 0	# row counter	
	li $s5, 0	# collum counter
	
# iterate through each pixel of original struct, and store it in the transposed location of s6
# the nested loop is similar to previous questions but now we reverse the use of row and collum counter
transposeLoop:
	li $s4, 0	#row counter, reset when reach the last row
transposeLoopA:
	move $s0, $s1
	mult $s3, $s4	# total length value times (current row - 1) is the start of the  the collum of the row
	mflo $t0	# get start of collum
	add $s0, $s0, $t0
	add $s0, $s0, $s5
	addi $s0, $s0, 12
	lb $t9, 0($s0)
	j transposeLoopEnd
	
transposeLoopEnd:

	sb $t9, 0($s6)
	addi $s6, $s6, 1	# go to the next location of s6
	addi $s4, $s4, 1
	bne $s4, $s2, transposeLoopA	# if not the last row
	addi $s5,$s5,1
	bne $s5, $s3, transposeLoop
	j transpose.return		
	

transpose.return:
	lw $s6, 0($sp)
	addi $sp, $sp, 4
	move $v0, $s6
	jr $ra
