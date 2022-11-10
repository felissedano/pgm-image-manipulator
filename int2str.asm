# Student ID = 260897013
###############################int2str######################
.data
.align 2
int2strBuffer:	.word 36
storeint2str:	.word 5
.text
.globl int2str
###############################int2str######################
int2str:
	# $a0 <- integer to convert
	##############return#########
	# $v0 <- space terminated string 
	# $v1 <- length or number string + 1(for space)
	###############################
	# Add code here
	
	move $t0, $a0   # t0 is the integer to convert
	la $t1, storeint2str
	addi $sp, $sp, -4
	addi $t7, $0, 47	# store a random ascii at the bottom of stack to indicate the end of string/int 
	sw $t7, 0($sp)		# we store ascii values of each digit from low to high on a stack and then store them in to a string address
	
	addi $t6, $0, 1		# length, start with 1 as we also include space
	
	
loop1:
	addi $t9, $0, 10	# store the value 10 to dive the integer
	div $t0, $t9 		# dive by 10, the remainder is the lowest order digit
	mfhi $t2
	mflo $t0
	addi $t2, $t2, 48	# get the ascii value of the digit
	addi $sp, $sp, -4
	sw $t2, 0($sp)		# store the char temperarly at sp
	addi $t6, $0, 1		# store length of string
	ble $t0, $0, storeChar 	# if quotient is zero it means we reach the last digit in the integer
	j loop1
	
	
storeChar:	
	
	lw $t8, 0($sp)		# load the highest order digit on t8 and store it to the first byte of string array
	beq $t8, 47, int2str.return	# if the random indication ascii is found then it means we have already stored the last digit
	sb $t8, 0($t1)	
	addi $t1, $t1, 1	# go to the next byte of address
	addi $sp, $sp, 4	# restore stack
	addi $t6, $t6, 1
	j storeChar	

int2str.return:
	
	addi $t8, $0, 32	# add ascii of space
	sb $t8, 0($t1)
	addi $sp, $sp, 4	# restore sp
	addi $t1, $t1, 1
	addi $t8, $0, 0
	sb $t8, 0($t1)		# store null character

	la $v0, storeint2str
	add $v1, $0, $t6
	jr $ra
