#-------------------------------------------------------------------------------
#author: Shailesh Kumar
#data : 2019,05,14
#description : example program for reading, modifying and getting a Green Component from source files
#-------------------------------------------------------------------------------

#only 24-bits 600x50 pixels BMP files are supported

.eqv BMP_FILE_SIZE 122880


#########################################################################################################################################################

# source 1 to source 4    82,62,77,82			62-82
# source 5 to source 8 	  104,103,132,150		103-150
# source 9 to source 12	  185,159,182,164 		159-185



#########################################################################################################################################################
	.data
#space for the 600x50px 24-bits bmp image
.align 4
res:	.space 2
image:	.space BMP_FILE_SIZE


s1: 	.asciiz "source1.bmp"
s2: 	.asciiz "source2.bmp"
s3: 	.asciiz "source3.bmp"
s4: 	.asciiz "source4.bmp"

s5: 	.asciiz "source5.bmp"
s6: 	.asciiz "source6.bmp"
s7: 	.asciiz "source7.bmp"
s8: 	.asciiz "source8.bmp"

s9: 	.asciiz "source9.bmp"
s10: 	.asciiz "source10.bmp"
s11: 	.asciiz "source11.bmp"
s12: 	.asciiz "source12.bmp"


files:  .word s1,s2,s3,s4,s5,s6,s7,s8,s9,s10,s11,s12
iterator:    .word 0
no_of_files: .word 11

temp_range: .word 0:3
	.word 0
temp_iterator:    .word 0

	
custom_ranges: .word 0:5
		.word 0
custom_iterator: .word 0
message: .asciiz " \n "
message1: .asciiz "adz"
message2: .asciiz "pea"
message3: .asciiz "qui"
errors:	  .asciiz "There was an error while opening the file. Terminating the Program..."

list_of_pixels: .word 0:255
		.word 0
fname:	.asciiz "source2.bmp"
	.text
	
.globl read_bmp
.globl get_pixels
.globl get_mode


main:
	la $s0, files								# initialize files
	lw $s5, iterator

start:
	
	
	lw $s4, no_of_files										# load again after iteration s4
	
	
	
	bgt $s5,$s4, exit
	
	sll $s7, $s5, 2 	# To go to the next file
	addu $s7, $s7, $s0										# remember to increment s7
	
	
	
	addi $s5,$s5,1
	
	li $v0, 4
	la $a0, message
	syscall
	
	li $v0, 4
	la $a0, message
	syscall
	
	li $v0, 4
	lw $a0, ($s7)
	syscall
	
	jal	read_bmp	

	

	
	jal     get_pixels
	
	
	jal 	get_mode
	move $a0, $v0
	
	
	jal	get_description
	
	jal 	clear_list

	j	start	
	

	

exit:

	#jal 	get_custom_ranges	
	li 	$v0,10		#Terminate the program
	syscall





# ============================================================================
read_bmp:
#description: 
#	reads the contents of a bmp file into memory
#arguments:
#	none
#return value: none
	sub $sp, $sp, 4		#push $ra to the stack
	sw $ra,4($sp)
	sub $sp, $sp, 4		#push $s1
	sw $s1, 4($sp)
#open file

	
	lw $v0, 0($s7)
	la $a0, ($v0)		#file name 
	li $v0, 13
        #la $a0, fname		
        li $a1, 0		#flags: 0-read file
        li $a2, 0		#mode: ignored
        syscall
	move $s1, $v0      # save the file descriptor
	
	
	#li $v0, 4
	#lw $a0, 0($s7)			$print the file name
	#la $a0, ($a0)
	#syscall
#check for errors - if the file was opened
#...
	blt $v0,0, error
	j	no_error
	error:
		li $v0, 4
		la $a0, message
		syscall	
	
		li $v0, 4
		la $a0, errors
		syscall
	
		li $v0, 4
		la $a0, message
		syscall	
		j exit
	
	

#read file
no_error:
	li $v0, 14
	move $a0, $s1
	la $a1, image
	li $a2, BMP_FILE_SIZE
	syscall

#close file
	li $v0, 16
	move $a0, $s1
        syscall
	
	lw $s1, 4($sp)		#restore (pop) $s1
	add $sp, $sp, 4
	lw $ra, 4($sp)		#restore (pop) $ra
	add $sp, $sp, 4
	jr $ra

# ============================================================================

# ============================================================================
get_pixels:
#description: 
#	returns color of specified pixel
#arguments:
#	$a0 - x coordinate
#	$a1 - y coordinate - (0,0) - bottom left corner
#return value:
#	$v0 - 0RGB - pixel color

								#Initialize the registers
	addiu $t0, $zero, 0 
	addiu $t1, $zero, 0 
	addiu $t2, $zero, 0 
	addiu $t3, $zero, 0 
	addiu $t7, $zero, 0 
	addiu $t6, $zero, 0 
	addiu $t5, $zero, 0 


	sub $sp, $sp, 4		#push $ra to the stack
	sw $ra,4($sp)

	la $t1, image + 10	#adress of file offset to pixel array
	lw $t2, ($t1)		#file offset to pixel array in $t2
	
	la $s6, image + 34	# size of the image
	lw $s4, ($s6)
	
	#li $v0, 1
	#move $a0, $t2		#printing the size of the image
	#syscall
	
	#li $v0, 4
	#la $a0, message
	#syscall
	
	la $t1, image		#adress of bitmap
	add $t2, $t1, $t2	#adress of pixel array in $t2
	
	
	la $t9, list_of_pixels
	while:
		
		
		
		#pixel address calculation
		
		bgt $t0,$s4 , exit_while
	
		lbu $v0,1($t2)		#load G
		
		
		move $t3, $v0						#if you printed the pixels, change v0 to a different register
		
		
		
		move $t6,  $t9
		move $t7, $t3
		#add $t7, $t7, -1
		sll $t7, $t7, 2
		addu $t6, $t6, $t7
		lw $t5, 0($t6)
		addu $t5, $t5, 1
		sw $t5, 0($t6)            #in this block we increment our counter of particular index of array
		
		
		
		add $t2, $t2, 3		#pixel address 
		
		addiu $t0, $t0, 3
		
		
		j while
	
	
	
	#get color
	
	
					
									
	exit_while:	
	
		
														
																					
	lw $ra, 4($sp)		#restore (pop) $ra
	add $sp, $sp, 4
	jr $ra


	
	
	
# ============================================================================

get_mode:
# It will return the highest value in the array of 256 values that we get from getPixels program

	sub $sp, $sp, 4		#push $ra to the stack
	sw $ra,4($sp)

	la $t1, list_of_pixels	
	
	
	
	
	addiu $t0, $zero, 0 
	addiu $t7, $zero, 0 
	addiu $t6, $zero, 0 
	addiu $t5, $zero, 0 
	addiu $t2, $zero, 0 
	
	
	mode_while:
		
		
		
		#pixel address calculation
		
		beq $t0, 256, exit_mode_while
		
		move $t5, $t0
		sll $t5, $t5, 2			#every number takes 4 bytes so we shift it (offset)
		addu $t5, $t5, $t1
		lw $t2, ($t5)
		bgt $t2, $t7, swap
		
		addiu $t0, $t0, 1
		j mode_while
	
		swap:
			#addiu $t7,$zero,0
			#move $t7, $t9
			move $t7, $t2
			move $t6, $t0
			addiu $t0, $t0, 1
			
			
	
				
			
			j mode_while
	
	#get color
	
	
					
									
exit_mode_while:	
	
	addiu $t0, $zero, 0 
	
	li $v0, 4
	la $a0, message
	syscall	
	
	li $v0, 1
	move $a0, $t6
	syscall
	
	li $v0, 4
	la $a0, message
	syscall	
	
	
	j deal_with_temp
exit_mode:	
		
	move $v0, $t6																																	
	lw $ra, 4($sp)		#restore (pop) $ra
	add $sp, $sp, 4
	jr $ra

deal_with_temp:
	la $t7, temp_range
	la $t5, temp_iterator
	lw $t3, ($t5)
	sll $t4, $t3, 2
	addu $t4, $t4, $t7
	sw $t6, 0($t4)
	
	addi $t3, $t3, 1
	bgt $t3, 3, zero_iterator
	sw $t3, ($t5)
	j exit_mode
zero_iterator:
	addiu $t3, $zero, 0
	sw $t3, ($t5)
	jal put_custom_ranges
	j exit_mode	
	
	
# ============================================================================

put_custom_ranges:
	sub $sp, $sp, 4		#push $ra to the stack
	sw $ra,4($sp)
	la $t1, temp_range
	la $t2, custom_ranges
	la $t3, custom_iterator
	addiu $t0, $zero, 0
	lw $t6, ($t1)
	lw $t7, ($t1)
	
	
	custom_while:
		
		
		
		#pixel address calculation
		
		beq $t0, 4, exit_custom_while
		
		
		sll $t5, $t0, 2			#every number takes 4 bytes so we shift it (offset)
		addu $t5, $t5, $t1
		lw $t4, ($t5)
		blt $t4, $t6, custom_swap_min
		bgt $t4, $t7, custom_swap_max
		
		addiu $t0, $t0, 1
		j custom_while
	
		custom_swap_min:
			move $t6, $t4
			addiu $t0, $t0, 1	
			j custom_while
		custom_swap_max:
			move $t7, $t4
			addiu $t0, $t0, 1
			j custom_while
		
exit_custom_while:	
	sw $t6, ($t2)
	sw $t7, 4($t2)
	lw $t4, ($t3)
	addiu $t4, $t4, 2
	sw $t4, ($t3)
	lw $ra, 4($sp)		#restore (pop) $ra
	add $sp, $sp, 4
	jr $ra

	
###################################################################################
	
# ============================================================================

get_description:
	sub $sp, $sp, 4		#push $ra to the stack
	sw $ra,4($sp)
	move $t6, $a0
	bgt $t6,102, pea		#len lin oat
	
	adz:
		li $v0, 4
		la $a0, message1
		syscall
		j exit_description
	pea:
	
		bgt $t6,158, qui
		li $v0, 4
		la $a0, message2
		syscall
		j exit_description
	
	qui:
	
		li $v0, 4
		la $a0, message3
		syscall
	
	
exit_description:	
	
	
	
	lw $ra, 4($sp)		#restore (pop) $ra
	add $sp, $sp, 4
	jr $ra

	
###################################################################################

clear_list:
	sub $sp, $sp, 4		#push $ra to the stack
	sw $ra,4($sp)
	
	
	la $t6, list_of_pixels
	addu $t5,$zero,0
	
	while_clear_list:
	
		beq $t5, 255, exit_clear_list
		move $t1, $t6
		
		
		move $t3, $t5
		sll $t3,$t3,2
		addu $t1,$t1, $t3
		lw 	$t2, ($t1)
		addu    $t2,$zero,0
		sw 	$t2, ($t1)
		
		addiu 	$t5,$t5,1
		j while_clear_list
		
		
		
	
	exit_clear_list:
	
	lw $ra, 4($sp)		#restore (pop) $ra
	add $sp, $sp, 4
	jr $ra
	
###################################################################################

clear_temp:
	sub $sp, $sp, 4		#push $ra to the stack
	sw $ra,4($sp)
	
	
	la $t6, custom_ranges
	addu $t5,$zero,0
	
	while_temp:
	
		beq $t5, 3, exit_temp
		move $t1, $t6
		
		
		move $t3, $t5
		sll $t3,$t3,2
		addu $t1,$t1, $t3
		lw 	$t2, ($t1)
		addu    $t2,$zero,0
		sw 	$t2, ($t1)
		
		addiu 	$t5,$t5,1
		j while_temp
		
	
	exit_temp:
	
	lw $ra, 4($sp)		#restore (pop) $ra
	add $sp, $sp, 4
	jr $ra


###################################################################################

get_custom_ranges:
	sub $sp, $sp, 4		#push $ra to the stack
	sw $ra,4($sp)
	la $t6, custom_ranges
	addu $t5,$zero,0
	
	get_while:
		beq $t5,6, get_while_exit
		move 	$t3, $t5
		sll 	$t3, $t3, 2
		addu	$t6, $t6, $t3
		lw 	$t2, ($t6)
		
		li $v0, 4
		la $a0, message
		syscall	
	
		li $v0, 1
		move $a0, $t2
		syscall
	
		li $v0, 4
		la $a0, message
		syscall	
	
		
		addu $t5, $t5, 1
		
	
	get_while_exit:
	
	lw $ra, 4($sp)		#restore (pop) $ra
	add $sp, $sp, 4
	jr $ra

	