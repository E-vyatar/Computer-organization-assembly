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

.global main

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