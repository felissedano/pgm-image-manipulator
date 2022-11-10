# Student ID = 260897013
###############################str2int######################
.data
#string: 		.asciiz "23"
.align 2
blank:		.asciiz "\n"
.text
.globl str2int
###############################str2int######################
str2int:
	# $a0 -> address of string, i.e "32", terminated with 0, EOS
	###### returns ########
	# $v0 -> return converted integer value
	# $v1 -> length of integer
	###########################################################
	# Add code here
	
	move $t0, $a0    # t0 is the copy the string number a0
#	la $t0, string
	addi $sp, $sp, -4
	sw $s0, 0($sp)

loop1: 
	addi $s0, $0, 1 # s0 stores the number of digits of the string, the number string has at least one digit
	lb $t1, 1($t0)	# t1 is the individual char of string, load the second char, if its not null then the number of digits increase by 1
	blt $t1, 48,lenth  
	
	addi $s0, $s0, 1 
	lb $t1, 2($t0) # check third char if the second char exists
	blt $t1, 48, lenth
	
	addi $s0, $s0, 1 # s0 at most 3
	j lenth
	
lenth:
	add $v1, $0, $s0  # return value v0 is s0
	add $t3, $0, $0   
	add $t4, $0, $0  # t4 to store converted value
loop2:
	beq $s0, 0, str2int.return # s0 decreses for every loop, terminate if no more digits to convert
	lb $t1, 0($t0)  # load char
	addi $t2, $t1, -48  # -48 to get the digit value
	addi $sp,$sp,-4     # store ra and go to the multiplication subroutine
	sw $ra,0($sp) 
	jal multi
	lw $ra,0($sp)	   # restore ra value
	addi $sp,$sp,4
	addi $s0, $s0, -1
	addi $t0, $t0, 1   # go to the next address char
	j loop2
	
	
multi:
	beq $s0, 3, multi100  # if s0 is 3, means the current char should x 100
	beq $s0, 2, multi10  # if 2 then x 10
	j multi1 # if 1 then just directly add the char value
	
multi100:
	addi $t6, $0, 100
	mult $t2, $t6
	mflo $t5
	j multidone
	
multi10:
	addi $t6, $0, 10
	mult $t2, $t6
	mflo $t5
	j multidone
	
multi1:
	add $t5, $0, $t2
	j multidone
	
multidone:
	add $t4, $t4, $t5
	jr $ra
	
	
str2int.return:
	lw $s0, 0($sp)
	addi $sp, $sp, 4
	move $v0, $t4
	jr $ra
