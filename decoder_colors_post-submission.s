#*********************************************************************
# * Program: Decoder                                                 *
# * Description: This program accepts as an argument a coded message *
# * where in each line:                                              *
# * byte 1 is the colour of the backgroud in ansi escape code        *
# * byte 2 is the colour of the text in ansi escape code             *
# * byte 8 is an ascii character in hex,                             *
# * byte 7 is the number of times to print the character             *
# * and bytes 3-6 are the address of the next line                   *
# ********************************************************************

.text
	inputFormat:	.asciz "%c" 		# format string to turn decimals to ascii
	backgroud:	.asciz "\x1B[48:5:%ldm"	# format string to change background color
	foreground:	.asciz "\x1B[38:5:%ldm"	# format string to change text color
	action:	.asciz "\x1B[%ldm"			# format string for special effects


.include "final.s"						# message to decode

.global main

# ********************************************************************
# * Subroutine: interpretALine                                       *
# * Description: This subroutine accepts as an argument the address  *
# * of a line in the message we're decoding.                         *
# * 8th byte saved to r13 (character to print)                       *
# * 7th byte saved to rbx (number of times to print character)       *
# * 3rd-6th bytes saved eventually to rax (next line to interpret)   *
# * 2nd byte to r14 (text colour)                                    *
# * 1st byte to r15 (background colour)                              *
# ********************************************************************

interpretALine:
	# prologue
	pushq	%rbp 			  			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		  			# copy stack pointer value to base pointer

	pushq	%rbx						# callee-saved register, save value to reset at the end of the subroutine
	pushq	%r12						# callee-saved register, save value to reset at the end of the subroutine
	pushq	%r13						# callee-saved register, save value to reset at the end of the subroutine
	pushq	%r14						# callee-saved register, save value to reset at the end of the subroutine
	pushq	%r15						# callee-saved register, save value to reset at the end of the subroutine
	subq	$8, %rsp					# move rsp to keep the stack aligned (8 bytes)
	
	movq	(%rdi), %rax				# copy to rax the value in the address rdi points to (the line to interpret)
	movb	%al, %r13b					# copy to r13 the 8th byte of the line (character to print)

	shr		$8, %rax					# shift rax one byte to the right to get access to the next byte
	movq	$0, %rbx					# clear rbx from previous values
	movb	%al, %bl					# copy to rbx the LSB of rax (number of times to print character)

	shr		$8, %rax					# shift rax one byte to the right to get access to the next bytes
	movq	$0, %rdi					# clear rdi from previous values
	movl	%eax, %edi					# copy to rdi the last 4 bytes of rax (next line to interpret)
	pushq	%rdi						# push rdi to the stack (8 bytes)
	subq	$8, %rsp					# move rsp to keep the stack aligned (8 bytes)

	shr		$32, %rax					# shift rax four bytes to the right to get access to the next byte
	movq	$0, %r14 					# clear r14 from previous values
	movb	%al, %r14b					# copy to r14 the LSB of rax (foreground color of text)

	shr		$8, %rax					# shift rax one byte to the right to get access to the next byte
	movq	$0, %r15 					# clear r15 from previous values
	movb	%al, %r15b					# copy to r15 the LSB of rax (background color of text)

	cmpq	%r14, %r15					# check if text colour and background colour are the same
	je		ifcode						# if text colour and background colour are the same jump to ifcode
	jmp		else						# else jump to else

	# find what special effect to execute
	ifcode:
		cmpq	$0, %r14				# check if text colour is 0
		je		sub0					# jump to matching line
		
		cmpq	$37, %r14				# check if text colour is 37
		je		sub37					# jump to matching line

		cmpq	$42, %r14				# check if text colour is 42
		je		sub42					# jump to matching line

		cmpq	$66, %r14				# check if text colour is 66
		je		sub66					# jump to matching line

		cmpq	$105, %r14				# check if text colour is 105
		je		sub105					# jump to matching line

		cmpq	$153, %r14				# check if text colour is 153
		je		sub153					# jump to matching line

		cmpq	$182, %r14				# check if text colour is 182
		je		sub182					# jump to matching line

	# special effect reset to normal
	sub0:
		movq	$0, %rax				# tell printf not to use 128 bit registers
		movq	$action, %rdi			# param1 for printf: format string
		movq	$0, %rsi				# param2 for printf: placeholder filler
		call	printf					# call printf
		jmp		startOfTheLoop			# skip text and background colour change and jump to printing the character

	# special effect stop blinking
	sub37:
		movq	$0, %rax				# tell printf not to use 128 bit registers
		movq	$action, %rdi			# param1 for printf: format string
		movq	$25, %rsi				# param2 for printf: placeholder filler
		call	printf					# call printf
		jmp		startOfTheLoop			# skip text and background colour change and jump to printing the character

	# special effect bold
	sub42:
		movq	$0, %rax				# tell printf not to use 128 bit registers
		movq	$action, %rdi			# param1 for printf: format string
		movq	$1, %rsi				# param2 for printf: placeholder filler
		call	printf					# call printf
		jmp		startOfTheLoop			# skip text and background colour change and jump to printing the character

	# special effect faint
	sub66:
		movq	$0, %rax				# tell printf not to use 128 bit registers
		movq	$action, %rdi			# param1 for printf: format string
		movq	$2, %rsi				# param2 for printf: placeholder filler
		call	printf					# call printf
		jmp		startOfTheLoop			# skip text and background colour change and jump to printing the character

	# special effect conceal
	sub105:
		movq	$0, %rax				# tell printf not to use 128 bit registers
		movq	$action, %rdi			# param1 for printf: format string
		movq	$8, %rsi				# param2 for printf: placeholder filler
		call	printf					# call printf
		jmp		startOfTheLoop			# skip text and background colour change and jump to printing the character

	# special effect reveal
	sub153:
		movq	$0, %rax				# tell printf not to use 128 bit registers
		movq	$action, %rdi			# param1 for printf: format string
		movq	$28, %rsi				# param2 for printf: placeholder filler
		call	printf					# call printf
		jmp		startOfTheLoop			# skip text and background colour change and jump to printing the character

	# special effect blink
	sub182:
		movq	$0, %rax				# tell printf not to use 128 bit registers
		movq	$action, %rdi			# param1 for printf: format string
		movq	$5, %rsi				# param2 for printf: placeholder filler
		call	printf					# call printf
		jmp		startOfTheLoop			# skip text and background colour change and jump to printing the character

	# text colour and background colour were different, apply them
	else:

		movq	$0, %rax				# tell printf not to use 128 bit registers
		movq	$backgroud, %rdi		# param1 for printf: format string
		movq	%r15, %rsi				# param2 for printf: placeholder filler
		call	printf					# call printf

		movq	$0, %rax				# tell printf not to use 128 bit registers
		movq	$foreground, %rdi		# param1 for printf: format string
		movq	%r14, %rsi				# param2 for printf: placeholder filler
		call	printf					# call printf


		# loop to print charcter several times
		startOfTheLoop:
			movq	$0, %r12				# initialize r12 (the iterator for loop2)
		loop2:

			movq	$0, %rax			# tell printf not to use 128 bit registers
			movq	$inputFormat, %rdi	# param1 for printf: format string
			movq	%r13, %rsi			# param2 for printf: character to print (8th byte of the line)
			call	printf				# call printf

			addq    $1, %r12        	# increment r12 by 1
			cmpq    %r12, %rbx       	# compare number of times to print character to iterator
			jg      loop2           	# repeat the loop as long as number of times to print character greater than iterator

	epilogue:
	addq	$8, %rsp					# move rsp to keep the stack aligned (8 bytes)
	popq	%rax						# pop to rax the number of the next line to interpret

	addq	$8, %rsp					# move rsp to keep the stack aligned (8 bytes)
	popq	%r15						# callee-saved register, reset the value to what is was before starting the subroutine
	popq	%r14						# callee-saved register, reset the value to what is was before starting the subroutine
	popq	%r13						# callee-saved register, reset the value to what is was before starting the subroutine
	popq	%r12						# callee-saved register, reset the value to what is was before starting the subroutine
	popq	%rbx						# callee-saved register, reset the value to what is was before starting the subroutine

	# epilogue
	movq	%rbp, %rsp					# clear local variables from stack
	popq	%rbp						# restore base pointer location 
	ret

# ********************************************************************
# Subroutine: decode                                                 *
# Description: This subroutine accepts as an argument the address    *
# of the first line in the message we're decoding and loop through   *
# the message lines until we get 0 as next line                      *
# ********************************************************************

decode:
	# prologue
	pushq	%rbp 						# push the base pointer (and align the stack)
	movq	%rsp, %rbp					# copy stack pointer value to base pointer

	pushq	%rbx						# callee-saved register, save value to reset at the end of the subroutine
	pushq	%r14						# callee-saved register, save value to reset at the end of the subroutine
	pushq	%r15						# callee-saved register, save value to reset at the end of the subroutine
	subq	$8, %rsp					# move rsp to keep the stack aligned (8 bytes)

	movq	%rdi, %r15					# copy address of first line to r15 to use as source
	movq	$0, %rbx					# clear rbx from previous values

	# loop to interpret message's lines
	loop:

		movq	%r15, %r14				# copy to r14 the address of the first line of the message
		movq	$8, %rax				# copy 8 to rax for multiplication
		mul		%rbx					# multiply current rbx by rax (8) to get the number of bytes
										# we need to move from the first line
										
		addq	%rax, %r14				# add this number of bytes to r14 to move to selcted line
		movq	%r14, %rdi				# param1 for interpretALine: address of the line to interpret
		call	interpretALine			# call interpretALine
		movq	%rax, %rbx				# copy number of next line to interpret

		cmpq	$0, %rbx				# compare number of next line to iterator
		jne		loop					# repeat the loop as long as number of tof next line not equal to 0
	
	addq	$8, %rsp					# move rsp to keep the stack aligned (8 bytes)
	popq	%r15						# callee-saved register, reset the value to what is was before starting the subroutine
	popq	%r14						# callee-saved register, reset the value to what is was before starting the subroutine
	popq	%rbx						# callee-saved register, reset the value to what is was before starting the subroutine

	# epilogue
	movq	%rbp, %rsp					# clear local variables from stack
	popq	%rbp						# restore base pointer location 
	ret

main:
	# prologue
	pushq	%rbp 						# push the base pointer (and align the stack)
	movq	%rsp, %rbp					# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi				# param1 for decode: address of the message
	call	decode						# call decode

	movq	$0, %rax					# tell printf not to use 128 bit registers
	movq	$action, %rdi				# param1 for printf: format string
	movq	$0, %rsi					# param2 for printf: placeholder filler
	call	printf						# call printf to restore terminal to default display

	# epilogue
	movq	%rbp, %rsp					# clear local variables from stack
	popq	%rbp						# restore base pointer location 
	movq	$0, %rdi					# load program exit code
	call	exit						# exit the program
