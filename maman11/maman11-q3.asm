# Title: Maman 11, Question 3.
# Author: Gal Birkman
# Date:  26.08.24
# Description:  Calculating number of diffs in a string. If the string is polindrome, notices the user. 
# Input:	30 chars max string.
# Output:	number of diffs and if polindrome, a massage. 
# Notes: 
#   - Single char string is a polindrom.
#   - Empty string (just '\n') is also a polindrom.
######################## Data segment ########################
.data
	in_msg: .asciiz "\nPlease Enter a String that is no longer than 30 chars. \n"
	palindrome_msg: .asciiz "\nThis string is a polindrome.\n"
	diffs_msg: .asciiz "\nNumber of diffs in the string: "
	str: .space 31
######################## Code Segment ########################
.text
.globl main

main:
	la $a0, in_msg	 	 		# load in_msg address to $a0
 	li $v0, 4				# load print string syscall code.
 	syscall       	
 	la $a0, str				# load adrress of the string.
 	li $a1, 31				# limit input string to 31 chars (including null char). 
 	li $v0, 8				# load read string syscall code.
	syscall
	la $s1, str 				# load string address to $s1.
	addi $s1, $s1, -1 			# start one byte before the actual address.
	loop1: 
		addi $s1, $s1, 1 		# bumping address by 1 to get next char.
        	lb $t1, ($s1)    		# load byte from memory
		bne $t1, $zero,loop1 		# check if loaded null byte: if $t1 != 0 => jump loop1
	move $a0, $s1
	jal check_last_char			# check if last char is '\n'	
	move $s1, $v0		
	la $s2, str 				# load start address for str.
	loop2:
		beq $t4, $s1, check_polindrome	# $t4 = the previous address that $s2 point to. I'm chekcing if the address of $s1 is now the same address as $s2 was in the previous iteration (for even number of chars). 
		lb $t1, ($s1) 			# load byte from the left side of the string.
		lb $t2, ($s2)			# load byte from the right side of the string.
		sne $t3, $t1, $t2 		# check if chars are equal.
		add $s3, $s3, $t3		# increasing diff counter if needed.
		move $t4, $s2			# saving the address that $s2 points to. 
		move $t5, $s1			# saving the address that $s1 points to.
		addi $s1, $s1, -1		# decreasing the address (starts as the END of the string) by one.  
		addi $s2, $s2, 1		# increasing the address (starts as the START of the string) by one.
		bne $t4, $t5, loop2		# Checking if $t4 and $t5 are pointers to the same address (for odd number of chars).
	check_polindrome:	
		la $a0, diffs_msg		# Loading diffs_msg in order to print it
		li $v0, 4
		syscall
		move $a0, $s3		
		li $v0, 1
		syscall
		bne $s3, $zero, exit		# if diffs !=0 => not polindrome and exit the program else print polindrome massage. 
		la $a0, palindrome_msg	
		li $v0, 4
		syscall
	j exit

check_last_char:
	# usage:
	#	Checks if the string ends with '\n'. If so, checks if \n is the only char in the string.
	# args:			
	# 	$a0 = the last address of the string (null char).
	# return:
	#	$v0 = address of the actual last char in the string. 
	addi $a0, $a0, -1		
	lb $t1, ($a0)
	beq $t1, '\n', last_is_slash_n
	move $v0, $a0
	jr $ra
	last_is_slash_n:
		addi $a0, $a0, -1
		la $t2, str
		slt $t3, $a0, $t2		# checking if the address of $a0 (last char - 1) is less than the start address of str.
		bne $t3, $zero, single_char_slash_n
		move $v0, $a0
		jr $ra
		single_char_slash_n:
			addi $a0,$a0,1
			move $v0, $a0
			jr $ra

exit:
	li $v0, 10
	syscall 
