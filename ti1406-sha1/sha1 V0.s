.global sha1_chunk

sha1_chunk:
	# prologue
	pushq	%rbp 						# push the base pointer (and align the stack)
	movq	%rsp, %rbp					# copy stack pointer value to base pointer

	movq	$16, %rbx
	firstLoop:

		movqq	-12(%rsi,  %5rbx, 4), 
		movq	%rbx, %rax
		subq	$3, %rax
		movq	$32, %r11
		mul 	%r11
		movq	%rsi, %r12
		addq	%rax, %r12
		movq	(%r12), %r13	#w[i-3]

		movq	%rbx, %rax
		subq	$8, %rax
		movq	$32, %r11
		mul 	%r11
		movq	%rsi, %r12
		addq	%rax, %r12
		movq	(%r12), %r14	#w[i-8]

		xorq	%r14, %r13

		movq	%rbx, %rax
		subq	$14, %rax
		movq	$32, %r11
		mul 	%r11
		movq	%rsi, %r12
		addq	%rax, %r12
		movq	(%r12), %r14	#w[i-14]

		xorq	%r14, %r13
		
		movq	%rbx, %rax
		subq	$16, %rax
		movq	$32, %r11
		mul 	%r11
		movq	%rsi, %r12
		addq	%rax, %r12
		movq	(%r12), %r14	#w[i-16]

		xorq	%r14, %r13
		rolq	$1, %r13

		movq	%rbx, %rax
		movq	$32, %r11
		mul		%r11
		movq	%rsi, %r11
		addq	%rax, %r11
		movq	%r13, %r11

		cmpq	$80, %rbx
		jl		firstLoop


	movq	$0, %rbx
	mainLoop:

		movq	(%rdi), %r15
		movq	4(%rdi), %rcx
		movq	8(%rdi), %rdx
		movq	12(%rdi), %r8
		movq	16(%rdi), %r9
		movq	$4294967295, %r10

		pushq	%r9
		pushq	%r8
		pushq	%rdx
		pushq	%rcx
		pushq	%r15
		subq	$8, %rsp

		cmpq	$19, %rbx
		jle		sub0
		jg		sub20
		
		cmpq	$39, %rbx
		jg		sub40

		cmpq	$59, %rbx
		jg		sub60

		jmp		temp
		
		sub0:
			andq	%rcx, %rdx
			xorq	%r10, %rcx
			andq	%r8, %rcx
			orq		%rcx, %rdx
			movq	%rdx, %r11
			movq	$0x5A827999, %r12
			jmp		temp

		sub20:
			xorq	%rcx, %rdx
			xorq	%rdx, %r8
			movq	%r8, %r11
			movq	$0x6ED9EBA1, %r12
			jmp		temp

		sub40:
			movq	%rcx, %r12
			andq	%rdx, %r12
			andq	%r8, %rcx
			andq	%rdx, %r8
			orq		%r12, %rcx
			orq		%rcx, %r8
			movq	%r8, %r11
			movq	$0x8F1BBCDC, %r12
			jmp		temp

		sub60:
			xorq	%rcx, %rdx
			xorq	%rdx, %r8
			movq	%r8, %r11
			movq	$0xCA62C1D6, %r12
			jmp		temp

			
	temp:
		addq	$8, %rsp	
		popq	%r15
		popq	%rcx
		popq	%rdx
		popq	%r8
		popq	%r9

		movq	%r15, %r13
		rolq	$5, %r13
		addq	%r11, %r13
		addq	%r9, %r13
		addq	%r12, %r13

		movq	%rbx, %r14
		movq	$32, %r11
		mul		%r11
		movq	%rsi, %r11
		addq	%r14, %r11

		addq	(%r11), %r13		#temp

		movq	%r8, %r9
		movq	%rdx, %r8
		rolq	$30, %rcx
		movq	%rcx, %rdx
		movq	%rax, %rcx
		movq	%r13, %rax

		addq	$1, %rbx
		cmpq	$80, %rbx
		jl		firstLoop

	# epilogue
	movq	%rbp, %rsp					# clear local variables from stack
	popq	%rbp						# restore base pointer location
	ret
