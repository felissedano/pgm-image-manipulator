# Student ID = 260897013
####################################write Image#####################
.data

ph:		.space 3
p5f:		.ascii "P5\n"

.text
.globl write_image
####################################write Image#####################
write_image:
	# $a0 -> image struct
	# $a1 -> output filename
	# $a2 -> type (0 -> P5, 1->P2)
	################# returns #################
	# void
	# Add code here.
	
	# $s0 is copy of struct, $t9 is type
	move $s0, $a0
	move $s6, $a1
	move $t9, $a2
	
	# open file
	li $v0, 13
    	move $a0, $s6
    	li $a1, 1
    	li $a2, 0
    	syscall 
    	
    	# store file descriptor
    	move $s6, $v0
    	la $t2, ph	# load buffer
    	beq $t9, 0, headerP5	#if 1 then p2 else p5
    	
headerP2:	# store ascii for P, 2, and \n to $t2
	li $t0, 80
	sb $t0, 0($t2)
	li $t0, 50
	sb $t0, 1($t2)
	li $t0, 10
	sb $t0, 2($t2)
	
	# write header to file
	li $v0, 15
    	move $a0, $s6
   	move $a1, $t2
    	li $a2, 3
    	syscall
	j headerWrite
	
headerP5:	# store ascii for P, 5, and \n to $t2
	li $t0, 80
	sb $t0, 0($t2)
	li $t0, 53	# same as above, except X = 5, which is ascii 53
	sb $t0, 1($t2)
	li $t0, 10
	sb $t0, 2($t2)
	
	li $v0, 15
    	move $a0, $s6
   	move $a1, $t2
    	li $a2, 3
    	syscall
	j headerWrite
    	
headerWrite:
	move $s4, $t9	# move header info to s4 because t9 will be used in int2str
	
	#write length
	lw $a0, 0($s0)	#load first 4 bytes as length
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal int2str	# convert it to string
	move $s1, $v0
	move $s2, $v1
	lw $ra, 0($sp)
	addi $sp, $sp, 4

	# write it to file
    	li $v0, 15
    	move $a0, $s6
   	move $a1, $s1
    	move $a2, $s2
    	syscall
    	
  	#write width
  	lw $a0, 4($s0)	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal int2str
	move $s1, $v0
	move $s2, $v1
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	#replace space with newline
	move $t1, $s1
	addi $t3, $s2, -1
	add $t1, $t1, $t3
	li $t0, 10
	sb $t0, 0($t1)
	
	li $v0, 15
    	move $a0, $s6
   	move $a1, $s1
    	move $a2, $s2
    	syscall
    	
    	#write max value
  	lw $a0, 8($s0)	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal int2str
	move $s1, $v0
	move $s2, $v1
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	#replace space with newline
	move $t1, $s1
	addi $t3, $s2, -1
	add $t1, $t1, $t3
	li $t0, 10
	sb $t0, 0($t1)
	
	li $v0, 15
    	move $a0, $s6
   	move $a1, $s1
    	move $a2, $s2
    	syscall
    	
    	lw $s7, 0($s0) # length to count to
    	lw $s5, 4($s0)	#width to count to
    	li $s3, 0	#width counter
    	addi $s0, $s0, 12
    	
    	beq $s4, 0, writeP5
    
writeP2:
	li $s4, 0	# length counter
	
loopP2:
	# convert a byte to string
	lb $a0, 0($s0)	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal int2str
	move $s1, $v0
	move $s2, $v1
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	#write it to file
	li $v0, 15
    	move $a0, $s6
   	move $a1, $s1
    	move $a2, $s2
    	syscall
    	
    	#if not end of collum, continue, otherwise add a new line character to the end and start new row
    	addi $s0, $s0, 1
    	addi $s4, $s4, 1
    	bne $s4, $s7, loopP2
    
loopP2n:
	addi $s3, $s3, 1	
	beq $s3, $s5, write_image.return # been through all rows, now return
	li $t0, 10	# add new line character
	la $s1, ph
	sb $t0, 0($s1)	# newline character to buffer
	
	# write new line character
	li $v0, 15
    	move $a0, $s6
   	move $a1, $s1
    	li $a2, 1
    	syscall
    	j writeP2
    	
writeP5:	# just write length x width number of bytes to the target file
	mult $s5, $s7
	mflo $s7	# get total number of content to write

loopP5:
	lb $s1, 0($s0) 
	li $v0, 15
    	move $a0, $s6
   	move $a1, $s0	# directly write content in struct to output file
    	move $a2, $s7	# write till the end of struct
    	syscall

    	j write_image.return 

	
	
write_image.return:
		
	li   $v0, 16       
	move $a0, $s6      
	syscall            # close the file
	jr $ra
