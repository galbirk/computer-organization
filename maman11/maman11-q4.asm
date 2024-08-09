# Title: Maman 11, Question 4.
# Author: Gal Birkman
# Date:  26.08.24
# Description: Processing and sorting hex numbers.
# Input: String of hex numbers pairs seperated by '$'.
# Output: Print sorted (signed and unsigned) decimal numbers.
######################################################
# Algorithm Description:
# 1. Prompt the user to input pairs of hex numbers separated by the `$`.
# 2. Read and validate the input, accroding to set of rules.
# 3. If the input string is invalid, display an error message and reprompt the user.
# 4. Convert the input string into hex integers and insert them to NUM array.
# 5. Copy NUM into unsign array and preform selection sort on unsign. Sorting in descending order (WITHOUT sign consideration). 
# 6. Copy NUM into sign array and preform selection sort on sign. Sorting in descending order (WITH sign consideration).
# 7. Print unsign array as unsigned decimal numbers.
# 8. Print sign array as signed decimal numbers.
######################################################
# Register Documentation:
# $v0 - Used for syscall code and to return values from procedures.
# $a0 - First argument for syscalls and first argument for procedures.
# $a1 - Second argument for syscalls and second argument for procedures.
# $a2 - Third argument for procedures.
# $t0-9 - Temporary registers used for various operations and intermediate results.
# $s0 - Use to store the number of valid hex pairs in the input string.
# $ra - Return address register, used by the 'jal' and 'jr' instructions.
######################################################
######################## Data segment ########################
.data
	in_msg: .asciiz "\nPlease Enter a couples of hex digits spereated by $ (no longer than 36). \n"
	in_error_msg: .asciiz "\nWrong input. \n"
	sign_msg: .asciiz "\n Sign array elements: \n"
	unsign_msg: .asciiz "\n Unsign array elements: \n"
	stringhex: .space 37
	NUM: .space 12
	unsign: .space 12
	sign: .space 12
######################## Code Segment ########################
.text
.globl main

main:
	input_loop:
		la $a0, in_msg	 	 		# load in_msg address to $a0
 		li $v0, 4				# load print string syscall code.
 		syscall       	
 		la $a0, stringhex			# load adrress of the string.
 		li $a1, 36				# limit input string to 36 chars (including null char). 
 		li $v0, 8				# load read string syscall code.
		syscall
		la $a0, stringhex
		jal is_valid				# call is_valid - validating input
		beq $v0, $zero, error			# jump to error if string is not valid
		
	move $s0, $v0
	la $a0, stringhex
	la $a1, NUM
	move $a2, $s0
	jal convert					# call convert procedure
	
	la $a0, unsign
	la $a1, NUM
	move $a2, $s0
	jal sortunsign					# call sortunsign procedure
	
	la $a0, sign
	la $a1, NUM
	move $a2, $s0
	jal sortsign					# call sortsign procedure
	
	la $a0, unsign
	move $a1, $s0
	jal printunsign					# call printunsign procedure
	
	la $a0, sign
	move $a1, $s0
	jal printsign					# call printsign procedure
	
	exit:
		li $v0, 10
		syscall 
	error:
		la $a0, in_error_msg	 	 		
 		li $v0, 4
 		syscall  
 		j input_loop
	
is_valid:
# usage:
#	Checks if the string is valid.
# args:			
# 	$a0 = address of stringhex
# return:
#	$v0 = numbert of pairs / 0 if string is invalid. 
	li $t0, 0 	# stores current byte of the string
	li $t1, 0	# counter for hex digtis in a row
	li $t2, 0	# counter for '$' signs in a row.
	li $t3, 0	# counter for valid pairs
	li $t4, 0	# stores temp results for set commnads
	li $t5, 0	# stores temp results for set commnads
	li $t6, 0	# stores temp results for set commnads
	stringhex_itr:
		lb $t0, ($a0)
		beq $t0, $zero, end_of_loop		# check reached the end of the string
		beq $t0, '\n',  end_of_loop		# check if reached ebd of the string
		
		addi $a0, $a0, 1			# increase iterator by 1
		 
		bne $t0, 36, not_dollar 		# check if '$' sign
		
		got_dollar:
			addi $t3, $t3, 1		# increasing pairs number as num_of_pairs == num_of_dollars when input ia valid
			addi $t2, $t2, 1		# increasing '$' in a row
			bne $t1, 2, return_invalid	# check if 2 hex digits in a row before '$' 
			bge $t2, 2, return_invalid	# check if there are 3 '$' in a row
			li $t1, 0	# zero hex digits counter
			j stringhex_itr
			
		not_dollar:
		ble $t0, 47, return_invalid	# check if less than '0' in ascii table
		li $t6, 58
		sge $t4, $t0, $t6		# check if greater than '9' in ascii table
		li $t6, 65
		slt $t5, $t0, $t6		# check if less than 'A' in ascii table
		add $t4, $t4, $t5		
		beq $t4, 2, return_invalid	# check if $t1 is between '9' and 'A'
		bge $t0, 71, return_invalid
		addi $t1, $t1, 1
		li $t2, 0	# zero '$' signs counter
		j stringhex_itr
	return_invalid:
		li $v0, 0
		jr $ra
	end_of_loop:
		bne $t1, 0, return_invalid	# check if last char was hex and not '$'
		move $v0, $t3
		jr $ra

convert:
# usage:
#	Converting string pairs to integers.
# args:			
# 	$a0 = address of stringhex
# 	$a1 = address of NUM
# 	$a2 = address of number of pairs
# return:
#	void procedure	
	convert_loop:
		beqz $a2, return # check if there are still pairs to process
		lb $t1, ($a0)	# load char from stringhex
		addi $a0, $a0, 1 # increase pinter to next char
		lb $t2, ($a0)	# load char from stringhex
		addi $a0, $a0, 2 # increase pointer by 2: 1 for '$' sign and 1 for next iteration
		
		ble $t1, 0x39, first_not_letter	# check if first char is a letter or number
		sub $t1, $t1, 0x7		# if char is letter => substruct 7
		first_not_letter:		
		ble $t2, 0x39, second_not_letter # check if second char is letter
		sub $t2, $t2, 0x7		# if char is letter => substruct 7
		second_not_letter:
		sub $t1, $t1, 0x30		# subtruct 0x30 to get hex value
		sub $t2, $t2, 0x30		# subtruct 0x30 to get hex value
		
		sll $t1, $t1, 4 # clearing 4 bits in the LSB side of $t1 (1 byte)
		add $t1,$t1, $t2 # adding $t2 byte to the LSB side of $t1
		sb $t1, ($a1)	# store byte in NUM
		addi $a1, $a1, 1 # increase NUM pointer
		sub $a2, $a2, 1 # substract the numer of pairs
		j  convert_loop
		
	return:
		jr $ra


sortunsign:
# usage:
#	Sorting NUM array (unsigend).
# args:			
# 	$a0 = address of unsign
# 	$a1 = address of NUM
# 	$a2 = number of pairs
# return:
#	void procedure
	li $t0, 0
	copy_to_unsign:
		bge $t0, $a2, end_copy_to_unsign # check if reached the end of NUM
		add $t1, $a1, $t0 	     # get NUM[index] address
		lbu $t2,($t1)		     # load byte from NUM
		add $t3, $a0, $t0	     # get unsign[index] address
		sb $t2, ($t3)		     # store byte in unsign
		addi $t0, $t0, 1
		j copy_to_unsign
	end_copy_to_unsign:
	li $t1, 0 # counter for outer loop (i)
	sort_outer_loop:
		move $t3, $t1 # set max_index
		add $t2, $a0, $t1 # start adress of unsign in inner loop
		addi $t4, $t1, 1  # set counter for inner loop
		sort_inner_loop:
			bge $t4, $a2, end_inner_loop
			lbu $t5, ($t2)	# load unsign[i] or unsign[max_index]
			add $t7, $a0, $t4 # get unsign[j] address
			lbu $t6, ($t7)	# load unsign[j]
			bgt $t6, $t5, update_max_index # check if unsign[j] > unsign[max_index]
			continue:
			addi $t4, $t4, 1
			j sort_inner_loop
			update_max_index:
			#move $t3, $t4	# update max index
			move $t2, $t7	# update the address of the address of max number in unsign 
			j continue
		end_inner_loop:		  # unsign[i], unsign[max_index] = unsign[max_index], unsign[i] (swap numbers) 
			add $t3, $a0, $t1 # get unsign[i] address 
			lbu $t8, ($t3)	  # load unsign[i]
			lbu $t9, ($t2)	  # load unsign[max_index]
			sb $t8, ($t2)
			sb $t9, ($t3)
		addi $t1, $t1, 1	 # increasing outer loop counter by 1				
		blt $t1, $a2, sort_outer_loop
	end_sortunsign:
		jr $ra


sortsign:
# usage:
#	Sorting NUM array (sigend).
# args:			
# 	$a0 = address of sign
# 	$a1 = address of NUM
# 	$a2 = number of pairs
# return:
#	void procedure
	li $t0, 0
	copy_to_sign:
		bge $t0, $a2, end_copy_to_sign # check if reached the end of NUM
		add $t1, $a1, $t0 	     # get NUM[index] address
		lbu $t2,($t1)		     # load byte from NUM
		add $t3, $a0, $t0	     # get unsign[index] address
		sb $t2, ($t3)		     # store byte in sign
		addi $t0, $t0, 1
		j copy_to_sign
	end_copy_to_sign:
	li $t1, 0 # counter for outer loop (i)
	sort_outer_loop_signed:
		move $t3, $t1 # set max_index
		add $t2, $a0, $t1 # start adress of unsign in inner loop
		addi $t4, $t1, 1  # set counter for inner loop
		sort_inner_loop_signed:
			bge $t4, $a2, end_inner_loop_signed
			lb $t5, ($t2)	# load unsign[i] or NUM[max_index]
			add $t7, $a0, $t4 # get unsign[j] address
			lb $t6, ($t7)	# load unsign[j]
			bgt $t6, $t5, update_max_index_signed # check if unsign[j] > unsign[max_index]
			continue_signed:
			addi $t4, $t4, 1
			j sort_inner_loop_signed
			update_max_index_signed:
			move $t2, $t7	# update the address of the address of max number in unsign 
			j continue_signed
		end_inner_loop_signed:		  # unsign[i], unsign[max_index] = unsign[max_index], unsign[i] (swap numbers) 
			add $t3, $a0, $t1 # get unsign[i] address 
			lbu $t8, ($t3)	  # load unsign[i]
			lbu $t9, ($t2)	  # load unsign[max_index]
			sb $t8, ($t2)
			sb $t9, ($t3)
		addi $t1, $t1, 1	 # increasing outer loop counter by 1				
		blt $t1, $a2, sort_outer_loop_signed
	end_sortsign:
		jr $ra

printunsign:
# usage:
#	Printing unsing array elements in decimal base (unsigned).
# args:			
# 	$a0 = address of unsign
# 	$a1 = number of pairs
# return:
#	void procedure

	move $t3, $a0	# move unsign address to $t3
	
	la $a0, unsign_msg	 	 		
 	li $v0, 4
 	syscall 
 	
	li $t0, 0	# init loop index
	print_unsign_loop:
		beq $t0, $a1, return_printunsign # check if all numbers were processed 
		li $t1, 100			# init divider in $t1
		lbu $t2, ($t3)			# load byte from sign
		
		li $t6, 0			# init non-zero char printed flag
		beqz $t2, print_zero_unsigned   # If number is zero, print '0'
		print_digits_loop:		# keep deviding to extract digit after digit (3 digits).
			beq $t1, 0, print_spaces # go to print spaces 
			div $t2, $t1		# divide number by divider
			mflo $t4		# get the quotient (current digit)
			mfhi $t2		# get remainder for next digit
			
			beqz $t4, skip_zero_digit_unsigned # check if skip printing is needed - digit is '0' (from the MSB side)
			li $t6, 1			# turn non-zero flag on
			print_digit_unsigned:
			addi $t4, $t4, 48	# convert decimal to ascii
			move $a0, $t4	
			li $v0, 11
			syscall
			
			div $t1, $t1, 10	# reduce divider by 10
			j print_digits_loop
		skip_zero_digit_unsigned:
			bnez $t6, print_digit_unsigned	# if non-zero flag is on, print 0.
    			div $t1, $t1, 10                    # reduce divider by 10
    			j print_digits_loop          # continue for the next digit
		print_spaces:
			addi $t0, $t0, 1	# increase loop index
			addi $t3, $t3, 1	# increase byte in sign address
			
			li $a0, 32		# print first space
			li $v0, 11
			syscall
			
			li $a0, 32		# print second space
			li $v0, 11
			syscall
			
			j print_unsign_loop
		print_zero_unsigned:
			li $a0, 48                           # ASCII '0'
    			li $v0, 11
    			syscall                            
    			j print_spaces 
	return_printunsign:
		jr $ra
		
printsign:
# usage:
#	Printing unsing array elements in decimal base (signed).
# args:			
# 	$a0 = address of sign
# 	$a1 = number of pairs
# return:
#	void procedure
	
	move $t3, $a0	# move sign address to $t3
	
	la $a0, sign_msg	 	 		
 	li $v0, 4
 	syscall 
 	
	li $t0, 0	# init loop index
	print_sign_loop:
		beq $t0, $a1, return_printsign 		# check if all numbers were processed 
		li $t1, 100				# init divider in $t1
		lb $t2, ($t3)				# load byte from sign
		
		li $t6, 0 				# init non-zero char printed flag
		beqz $t2, print_zero_signed               	# If number is zero, print '0'
		bge $t2, $zero, print_digits_loop_signed	# check nmuber sign
		print_minus_sign:
			li $a0, 45			# print '-' before negative number
			li $v0, 11
			syscall
			
			sub $t2, $zero, $t2		# convert to postivie number
		print_digits_loop_signed:		# keep deviding to extract digit after digit (3 digits).
			beq $t1, 0, print_spaces_signed # go to print spaces 
			div $t2, $t1			# divide number by divider
			mflo $t4			# get the quotient (current digit)
			mfhi $t2			# get remainder for next digit
			
			beqz $t4, skip_zero_digit_signed # check if skip printing is needed - digit is '0' (from the MSB side)
			li $t6, 1			# turn non-zero flag on
			print_digit_signed:
			addi $t4, $t4, 48		# convert decimal to ascii
			move $a0, $t4	
			li $v0, 11
			syscall
			
			div $t1, $t1, 10		# reduce divider by 10
			j print_digits_loop_signed
		skip_zero_digit_signed:
			bnez $t6, print_digit_signed	# if non-zero flag is on, print 0.
    			div $t1, $t1, 10                    # reduce divider by 10
    			j print_digits_loop_signed          # continue for the next digit
		print_spaces_signed:
			addi $t0, $t0, 1		# increase loop index
			addi $t3, $t3, 1		# increase byte in sign address
			
			li $a0, 32			# print first space
			li $v0, 11
			syscall
			
			li $a0, 32			# print second space
			li $v0, 11
			syscall
			
			j print_sign_loop
		print_zero_signed:
			li $a0, 48                           # ASCII '0'
    			li $v0, 11
    			syscall                              
    			j print_spaces_signed                
	return_printsign:
		jr $ra