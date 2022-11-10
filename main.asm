######################Assignment 3 main function###############
			.data
			.align 2
inputFile:		.asciiz "feepP2.pgm"
			.align 2
outputFile:		.asciiz "feepOut.pgm"
			.align 2
blank:			.asciiz "\n"
			.align 2
sucessStr:		.asciiz "Exit Sucess\n"
			.text

			.globl main			
main:		
	#Open Image file for reading
	#Test your implementation section by section using readImage, writeImage

	la $a0, inputFile
	jal read_image		# read image File
	move $s0,$v0		# copy address of the read image
	
	
	########Test connected components by uncomment here#####
	#move $a0,$s0		# copy address of the read image
	#jal connected_components
	########################################################
	
	
	########Test image boundary by uncomment this section###
	#move $a0,$s0		# copy address of the read image
	#jal image_boundary
	########################################################
	
	
	########Test transpose by uncomment this section#########
	move $a0,$s0		# copy address of the read image
	jal transpose
	########################################################
		
	
	########Test mirror by uncomment this section############
	#move $a0,$s0		# copy address of the read image
	#jal mirror_horizontally
	#########################################################
	
	move $a0,$v0		# write pgm file 
	la $a1,outputFile	# to `outputFile'
	li $a2,	1		# 0 == P5, 1 == P2
	jal write_image
	
	j main.exitSucess

										
########################Exit Labels#########################
main.exitSucess:
	li $v0, 4		#syscall for print string
	la $a0,sucessStr
	syscall
	j main.exit
main.exit:
	li $v0,10
	syscall	
		
