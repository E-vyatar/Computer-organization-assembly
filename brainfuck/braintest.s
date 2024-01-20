.global main

format_str: .asciz "We should be executing the following code:\n%s"
inputFormat:	.asciz "%c" 		# format string to turn decimals to ascii

# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
main:
	pushq %rbp
	movq %rsp, %rbp

    movq	$0, %rbx
	movq	$30000, %r9
	stackLoop:
		movq	$0, %r8
		pushq	%r8
		addq	$1, %rbx
		cmpq	%r9, %rbx
		jl		stackLoop

    addq	$239992, %rsp

    addq    $1, (%rsp)
	
	movq %rbp, %rsp
	popq %rbp
	ret
