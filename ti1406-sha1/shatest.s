.text
.global main

main:
	# prologue
	pushq	%rbp 						# push the base pointer (and align the stack)
	movq	%rsp, %rbp					# copy stack pointer value to base pointer

    movl    $4294967292, %edi
    roll    $2, %edi
    movq    $5, %rsi
    xorq    %rsi, %rdi

	movq	$4, %rcx
	movq	$0xFFFFFFFF, %r10			# 4294967295 in binary is 32 1's, copy to r10, use later with xor as not
	xorq	%r10, %rcx				# not b

	# epilogue
	movq	%rbp, %rsp					# clear local variables from stack
	popq	%rbp						# restore base pointer location
	ret
