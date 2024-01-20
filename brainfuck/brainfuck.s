.data
cells: .skip 30000

.text
.global brainfuck

format_str: .asciz "We should be executing the following code:\n%s\n"
inputFormat:	.asciz "%c" 		# format string to turn decimals to ascii
newLine:	.asciz "\n"	 		# string new line at the end of the code

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	# prologue
	pushq	%rbp 				  			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		  				# copy stack pointer value to base pointer

	pushq	%rbx							# callee-saved register, save value to reset at the end of the subroutine
	pushq	%r12							# callee-saved register, save value to reset at the end of the subroutine
	pushq	%r13							# callee-saved register, save value to reset at the end of the subroutine
	pushq	%r14							# callee-saved register, save value to reset at the end of the subroutine
	pushq	%r15							# callee-saved register, save value to reset at the end of the subroutine
	subq	$8, %rsp						# move rsp to keep the stack aligned (8 bytes)

	movq	$0, %rax						# tell printf not to use 128 bit registers
	movq	%rdi, %rsi						# param2 for printf: placeholder filler - content of file to interpret
	movq	%rsi, %r12						# copy content of file to interpret
	movq	$format_str, %rdi				# param1 for printf: format string
	call	printf							# call printf

	movq	$0, %rbx						# loop iterator
	movq	$cells, %r13					# cells begining address
	movq	$1, %r14						# cell number counter
	movq	$0, %rcx						# holder of current character
	movq	$0, %r15						# brackets counter

	# loop over the text and interpret it
	commandLoop:

		movb	(%r12, %rbx, 1), %cl		# extract current character

		# check what is the command
		cmpq	$62, %rcx					# move the cell pointer to the right
		je		subAR						# jump to matching code

		cmpq	$60, %rcx					# move the cell pointer to the left
		je		subAL						# jump to matching code

		cmpq	$43, %rcx					# increment the memory cell at the pointer
		je		subPlus						# jump to matching code

		cmpq	$45, %rcx					# decrement the memory cell at the pointer
		je		subMinus					# jump to matching code

		cmpq	$46, %rcx					# output the character signified by the cell at the pointer
		je		subDot						# jump to matching code

		cmpq	$44, %rcx					# input a character and store it in the cell at the pointer
		je		subComma					# jump to matching code

		cmpq	$91, %rcx					# jump past the matching ] if the cell at the pointer is 0
		je		subBO						# jump to matching code

		cmpq	$93, %rcx					# jump back to the matching [ if the cell at the pointer is nonzero
		je		subBC						# jump to matching code

		cmpq	$0, %rcx					# end of text, we finished to interpret
		je		end							# jump to matching code

		jmp		temp						# current character is not a command, skip to next iteration

		# >
		subAR:
			addq	$1, %r14				# increment cell number counter
			jmp		temp					# continue to next iteration of the loop

		# <
		subAL:
			subq	$1, %r14				# decrement cell number counter
			jmp		temp					# continue to next iteration of the loop

		# +
		subPlus:
			addb	$1, (%r13, %r14, 1)		# increment value in current pointed cell
			jmp		temp					# continue to next iteration of the loop

		# -
		subMinus:
			subb	$1, (%r13, %r14, 1)		# decrement value in current pointed cell
			jmp		temp					# continue to next iteration of the loop

		# .
		subDot:
			movq	$0, %rax				# tell printf not to use 128 bit registers
			movq	$0, %rsi				# initialize rsi
			movq	$inputFormat, %rdi		# param1 for printf: format string
			movb	(%r13, %r14, 1), %sil	# param2 for printf: character to print
			call	printf					# call printf
			jmp		temp					# continue to next iteration of the loop

		# ,
		subComma:
			movq    $0, %rax                # tell printf not to use 128 bit registers
			movq    $inputFormat, %rdi      # param1 for scanf: format string
			leaq    (%r13, %r14, 1), %rsi   # param2 for scanf: memory addresses at which scanf may put the read values
			call    scanf                   # call scanf
			jmp		temp					# continue to next iteration of the loop

		# [
		subBO:
			cmpb	$0, (%r13, %r14, 1)		# check if value in current pointed cell is 0
			je		OB						# value in current pointed cell is 0, we need to skip to matching ]
			jmp		OB1						# value in current pointed cell is not 0, jump to second method

			# pointed cell is 0 loop
			OB:
				addq	$1, %rbx			# increment iterator to see next character
				cmpb	$91, (%r12, %rbx, 1)# check if character is another [
				je		one					# character is another [, jump to matching method
				cmpb	$93, (%r12, %rbx, 1)# check if character is ]
				je		two					# character is ], jump to matching method
				jmp		OB					# character is neither [ or ], repeat the loop

				# another [ while checking for ] of different [
				one:
					addq	$1, %r15		# increment brackets counter
					jmp		OB				# continue to next iteration of the loop

				# found a ]
				two:
					cmpq	$0, %r15		# check if brackets counter is 0
					je		temp			# it's the ] we were looking for, continue to next iteration of the loop
					subq	$1, %r15		# it's a ] of a different [, decrement brackets counter
					jmp		OB				# repeat the loop

			# pointed cell is not 0
			OB1:
				pushq	%rbx				# save location of this [
				subq	$8, %rsp			# move rsp to keep the stack aligned (8 bytes)
				jmp		temp				# continue to next iteration of the loop

		# ]
		subBC:
			cmpb	$0, (%r13, %r14, 1)		# check if value in current pointed cell is 0
			jne		CB1						# value in current pointed cell is not 0, we need to go back to matching [
			jmp		CB0						# value in current pointed cell is 0, continue to next iteration of the loop
			
			# go back to matcing [
			CB1:
				addq	$8, %rsp			# move rsp to keep the stack aligned (8 bytes)
				popq	%rbx				# move rbx back to matcing [
				subq	$1, %rbx			# decrement rbx to negate temp increment
				jmp		temp				# continue to next iteration of the loop

			# continue with the code
			CB0:
				addq	$8, %rsp			# move rsp to keep the stack aligned (8 bytes)
				popq	%rax				# pop last ]
				movq	$0, %rax			# reset rax
				jmp		temp				# continue to next iteration of the loop

		# loop iteration
		temp:
			addq	$1, %rbx				# increment iterator
			jmp		commandLoop				# repeat the loop

	# post loop, print new line
	end:
		movq	$0, %rax					# tell printf not to use 128 bit registers
		movq	$newLine, %rdi				# param1 for printf: string
		call	printf						# call printf

	# epilogue
	addq	$8, %rsp						# move rsp to keep the stack aligned (8 bytes)
	popq	%r15							# callee-saved register, reset the value to what is was before starting the subroutine
	popq	%r14							# callee-saved register, reset the value to what is was before starting the subroutine
	popq	%r13							# callee-saved register, reset the value to what is was before starting the subroutine
	popq	%r12							# callee-saved register, reset the value to what is was before starting the subroutine
	popq	%rbx							# callee-saved register, reset the value to what is was before starting the subroutine
	
	movq	%rbp, %rsp						# clear local variables from stack
	popq	%rbp							# restore base pointer location 
	ret
