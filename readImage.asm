# Student ID = 260897013
#########################Read Image#########################
.data
fileBuffer: .space 1024
wBuffer: .space 5
.text
.globl read_image
#########################Read Image#########################
read_image:
	# $a0 -> input file name, it will be either P2 or P5 file
        # You need to check the char after 'P' to determine the image type. 
	################# return #####################
	# $v0 -> Image struct :
	# struct image {
	#	int width;
	#       int height;
	#	int max_value;
	#	char contents[width*height];
	#	}
	##############################################
	# Add code here
	
	#For P2 you need to use str2int 	
	
	li   $v0, 13       
	# file name is already given by a0, no need to load it
	li   $a1, 0        
	li   $a2, 0
	syscall           
	move $s6, $v0      # save the file descriptor 

	#read from file
	li   $v0, 14      
	move $a0, $s6     
	la   $a1, fileBuffer   # load it to a hardcoded buffer
	li   $a2, 3     	# get to PX\n
	syscall            
	
	lb $s7, 1($a1)
	
	la $t9, wBuffer	# another buffer to convert string to int

# i got the length width order wrong, but to complicated to change it. wloop counts length and lLoop count width.
wLoop:	
	li   $v0, 14       
	move $a0, $s6      
	la   $a1, fileBuffer   
	li   $a2, 1     # read byte by byte to avoid counting space
	syscall            
	
	lb $t1, 0($a1)
	sb $t1, 0($t9)	# store the first digit
	blt $t1, 48, wToInt	#if ascii less than 48, means the end of a string integer
	addi $t9, $t9, 1	# else go to next byte and ready the potential string integer
	j wLoop

wToInt:		# convert the string to integer, and go to the length section
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $a0, wBuffer
	jal str2int
	move $s5, $v0
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	
	
wbufferReset: # go to the beggining of wBuffer and start storing the length
	la $t9, wBuffer
lLoop:	# same as wLoop
	li   $v0, 14       # system call for read from file
	move $a0, $s6      # file descriptor 
	la   $a1, fileBuffer   # address of buffer to which to read
	li   $a2, 1     # bytes to read
	syscall            # read from file
	
	lb $t1, 0($a1)
	sb $t1, 0($t9)
	blt $t1, 48, lToInt
	addi $t9, $t9, 1
	j lLoop

lToInt:	#same as wLoop
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $a0, wBuffer
	jal str2int
	move $s4, $v0
	lw $ra, 0($sp)
	addi $sp, $sp, 4

wbufferReset2: # go to the beggining of wBuffer and start storing the length
	la $t9, wBuffer
mLoop:	# to get max value, same as wLoop
	li   $v0, 14       # system call for read from file
	move $a0, $s6      # file descriptor 
	la   $a1, fileBuffer   # address of buffer to which to read
	li   $a2, 1     # bytes to read
	syscall            # read from file
	
	lb $t1, 0($a1)
	sb $t1, 0($t9)
	blt $t1, 48, mToInt
	addi $t9, $t9, 1
	j mLoop

mToInt:	# same as wLoop
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $a0, wBuffer
	jal str2int
	move $s3, $v0
	lw $ra, 0($sp)
	addi $sp, $sp, 4

getTotal:	# get total number of pixels, used for malloc struct
	mult $s5, $s4	# multiply W x L
	mflo $t9
	move $s2, $t9		# store number of pixels to $s1 for later use
	addi $t9, $t9, 12	# the number of bytes in the content + the 12 bytes header info
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	move $a0, $t9,
	jal malloc	# allocate $t5 number of bytes
	move $s0, $v0 # get the address of struct, $s0 will increase over time to add content
	move $s1, $s0 # copy the address and use $s1 to know the beggining of struct
	lw $ra, 0($sp)
	addi $sp, $sp, -4
	
	# $t0 is ascii of px, $t1 is used to store byte temprarely, $9 to $5 are address of wbuffer, length, width, max value, and total bytes needed
	sw $s5, 0($s0)
	sw $s4, 4($s0)
	sw $s3, 8($s0)
	addi $s0, $s0, 12 #first store header informations
	
	bne $s7, 50, p5 # now go to subroutines for corresponding file type
	# from now, $t0 count the number of pixels visited, $t1 store ascii of pixel, $t9 is buffert address, $s6 file descriptor, $s0 struct location
	# $s1 is the total number of pixels
p2:	
	li $s5, 0 	# counter for total pixels
p2n:	# go to the beginning to the address to reuse storage
	la $t9, wBuffer
	
loopP2:	
	li   $v0, 14       
	move $a0, $s6     
	la   $a1, fileBuffer   
	li   $a2, 1     # read 1 byte
	syscall            
	
	lb $t1, 0($a1)
	blt $t1, 48, loopP2	# if the first char of first loop isnt a number, it means more than one space, iterate till a number shows up
	
	sb $t1, 0($t9)
	addi $t9, $t9, 1	# ready to store the next digit 

loopP2n:
	# loop and get chars, until a space or a newline appears	
	li   $v0, 14       
	move $a0, $s6       
	la   $a1, fileBuffer   
	li   $a2, 1     
	syscall          
	
	lb $t1, 0($a1)
	sb $t1, 0($t9)
	blt $t1, 48, storeP2int
	addi $t9, $t9, 1
	j loopP2n

storeP2int:	# store the converted value to struct
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	la $a0, wBuffer
	jal str2int
	move $t3, $v0  # move the byte int to $t3
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	sb $t3, 0($s0)	# store int to the struct
	addi $s0, $s0, 1 # go to next byte of struct
	addi $s5, $s5, 1	
	blt $s5, $s2, p2n	# if not the last pixel, continue the loop
	j read_image.return	# the struct is complete, exit
	

p5:	# directly store the content of p5 to struct
	li $s5, 0
loopP5:
	li   $v0, 14       
	move $a0, $s6      # file descriptor 
	la   $a1, fileBuffer   
	li   $a2, 1     # read 1 byte
	syscall
	lb $t3, 0($a1)
	sb $t3, 0($s0)
	addi $s5, $s5, 1
	addi $s0, $s0, 1
	bne $s5, $s2, loopP5
	j read_image.return	# the struct is complete, exit
			


read_image.return:
	li   $v0, 16       
	move $a0, $s6      
	syscall            # close the file

	move $v0, $s1
	
	jr $ra
	 
	
