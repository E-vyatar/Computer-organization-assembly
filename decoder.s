#*********************************************************************
# * Program: Decoder                                                 *
# * Description: This program accepts as an argument a coded message *
# * where in each line:                                              *
# * bytes 1-2 doesn't matter,                                        *
# * byte 8 is an ascii character in hex,                             *
# * byte 7 is the number of times to print the character             *
# * and bytes 3-6 are the address of the next line                   *
# ********************************************************************

.text
	inputFormat:	.asciz "%c" 	# format string to turn decimals to ascii

.include "final.s"					# message to decode

.global main

# ********************************************************************
# Subroutine: interpretALine                                         *
# Description: This subroutine accepts as an argument the address     *
# of a line in the message we're decoding.                           *
# 8th byte saved to r13 (character to print)                         *
# 7th byte saved to rbx (number of times to print character)         *
# 3rd-6th bytes saved eventually to rax (next line to interpret)     *
# ********************************************************************

interpretALine:
	# prologue
	pushq	%rbp 			  		# push the base pointer (and align the stack)
	movq	%rsp, %rbp		  		# copy stack pointer value to base pointer

	pushq	%rbx					# callee-saved register, save value to reset at the end of the subroutine
	pushq	%r12					# callee-saved register, save value to reset at the end of the subroutine
	pushq	%r13					# callee-saved register, save value to reset at the end of the subroutine
	subq	$8, %rsp				# move rsp to keep the stack aligned (8 bytes)
	
	movq	(%rdi), %rax			# copy to rax the value in the address rdi points to (the line to interpret)
	movb	%al, %r13b				# copy to r13 the 8th byte of the line (character to print)

	shr		$8, %rax				# shift rax one byte to the right to get access to the next byte
	movq	$0, %rbx				# clear rbx from previous values
	movb	%al, %bl				# copy to rbx the LSB of rax (number of times to print character)

	shr		$8, %rax				# shift rax one byte to the right to get access to the next bytes
	movq	$0, %rdi				# clear rdi from previous values
	movl	%eax, %edi				# copy to rdi the last 4 bytes of rax (next line to interpret)
	pushq	%rdi					# push rdi to the stack (8 bytes)
	subq	$8, %rsp				# move rsp to keep the stack aligned (8 bytes)

	movq	$0, %r12				# initialize r12 (the iterator for loop2)

	# loop to print charcter several times
	loop2:

		movq	$0, %rax			# tell printf not to use 128 bit registers
		movq	$inputFormat, %rdi	# param1 for printf: format string
		movq	%r13, %rsi			# param2 for printf: character to print (8th byte of the line)
		call	printf				# call printf

		addq    $1, %r12        	# increment r12 by 1
		cmpq    %r12, %rbx       	# compare number of times to print character to iterator
		jg      loop2           	# repeat the loop as long as number of times to print character greater than iterator

	addq	$8, %rsp				# move rsp to keep the stack aligned (8 bytes)
	popq	%rax					# pop to rax the number of the next line to interpret

	addq	$8, %rsp				# move rsp to keep the stack aligned (8 bytes)
	popq	%r13					# callee-saved register, reset the value to what is was before starting the subroutine
	popq	%r12					# callee-saved register, reset the value to what is was before starting the subroutine
	popq	%rbx					# callee-saved register, reset the value to what is was before starting the subroutine

	# epilogue
	movq	%rbp, %rsp				# clear local variables from stack
	popq	%rbp					# restore base pointer location 
	ret

# ********************************************************************
# Subroutine: decode                                                 *
# Description: This subroutine accepts as an argument the address    *
# of the first line in the message we're decoding and loop through   *
# the message lines until we get 0 as next line                      *
# ********************************************************************

decode:
	# prologue
	pushq	%rbp 					# push the base pointer (and align the stack)
	movq	%rsp, %rbp				# copy stack pointer value to base pointer

	pushq	%rbx					# callee-saved register, save value to reset at the end of the subroutine
	pushq	%r14					# callee-saved register, save value to reset at the end of the subroutine
	pushq	%r15					# callee-saved register, save value to reset at the end of the subroutine
	subq	$8, %rsp				# move rsp to keep the stack aligned (8 bytes)

	movq	%rdi, %r15				# copy address of first line to r15 to use as source
	movq	$0, %rbx				# clear rbx from previous values

	# loop to interpret message's lines
	loop:

		movq	%r15, %r14			# copy to r14 the address of the first line of the message
		movq	$8, %rax			# copy 8 to rax for multiplication
		mul		%rbx				# multiply current rbx by rax (8) to get the number of bytes
									# we need to move from the first line
		addq	%rax, %r14			# add this number of bytes to r14 to move to selcted line
		movq	%r14, %rdi			# param1 for interpretALine: address of the line to interpret
		call	interpretALine		# call interpretALine
		movq	%rax, %rbx			# copy number of next line to interpret

		cmpq	$0, %rbx			# compare number of next line to iterator
		jne		loop				# repeat the loop as long as number of tof next line not equal to 0
	
	addq	$8, %rsp				# move rsp to keep the stack aligned (8 bytes)
	popq	%r15					# callee-saved register, reset the value to what is was before starting the subroutine
	popq	%r14					# callee-saved register, reset the value to what is was before starting the subroutine
	popq	%rbx					# callee-saved register, reset the value to what is was before starting the subroutine

	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	ret

main:
	pushq	%rbp 			# push the base pointer (and align the stack)
	movq	%rsp, %rbp		# copy stack pointer value to base pointer

	movq	$MESSAGE, %rdi	# param1 for decode: address of the message
	call	decode			# call decode

	# epilogue
	movq	%rbp, %rsp		# clear local variables from stack
	popq	%rbp			# restore base pointer location 
	movq	$0, %rdi		# load program exit code
	call	exit			# exit the program
