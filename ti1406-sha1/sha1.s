.global sha1_chunk

sha1_chunk:
	# prologue
	pushq	%rbp 							# push the base pointer (and align the stack)
	movq	%rsp, %rbp						# copy stack pointer value to base pointer

	pushq	%rbx							# callee-saved register, save value to reset at the end of the subroutine
	pushq	%r12							# callee-saved register, save value to reset at the end of the subroutine
	pushq	%r13							# callee-saved register, save value to reset at the end of the subroutine
	pushq	%r14							# callee-saved register, save value to reset at the end of the subroutine
	pushq	%r15							# callee-saved register, save value to reset at the end of the subroutine
	subq	$8, %rsp						# move rsp to keep the stack aligned (8 bytes)

	# loop for creating w[16]-w[79] (inclusive)
	movq	$16, %rbx						# initialize rbx (the iterator for firstLoop)
	firstLoop:

		subq	$3, %rbx					# subtract 3 from rbx for easier access to memory
		movl	(%rsi, %rbx, 4), %r13d		# copy w[i-3] to r13
		subq	$5, %rbx					# subtract 5 from rbx for easier access to memory (-3-5=-8)
		movl	(%rsi, %rbx, 4), %r14d		# copy w[i-8] to r14
		xorl	%r14d, %r13d				# w[i-3] xor w[i-8] (store in r13)

		subq	$6, %rbx					# subtract 6 from rbx for easier access to memory (-8-6=-14)
		movl	(%rsi, %rbx, 4), %r14d		# copy w[i-14] to r14
		xorl	%r14d, %r13d				# r13 xor w[i-14] (store in r13)

		subq	$2, %rbx					# subtract 2 from rbx for easier access to memory (-14-2=-16)
		movl	(%rsi, %rbx, 4), %r14d		# copy w[i-16]
		xorl	%r14d, %r13d				# r13 xor w[i-16] (store in r13)
		roll	$1, %r13d					# rotate r13 1 to the left

		addq	$16, %rbx					# add 16 to rbx to reset iterator
		movl	%r13d, (%rsi, %rbx, 4)		# store w[i] in the ith word place in memory

		addq	$1, %rbx					# increment iterator
		cmpq	$79, %rbx					# keep looping as long as iterator is less than or equal to 79
		jle		firstLoop					# repeat the loop


	# loop for hashing
	movl	(%rdi), %r15d					# a = h0
	movl	4(%rdi), %ecx					# b = h1
	movl	8(%rdi), %edx					# c = h2
	movl	12(%rdi), %r8d					# d = h3
	movl	16(%rdi), %r9d					# e = h4
	movq	$0, %rbx						# initialize rbx (the iterator for mainLoop)
	mainLoop:

		pushq	%r9							# push h4 value to the stack
		pushq	%r8							# push h3 value to the stack
		pushq	%rdx						# push h2 value to the stack
		pushq	%rcx						# push h1 value to the stack
		pushq	%r15						# push h0 value to the stack
		subq	$8, %rsp					# move rsp to keep the stack aligned (8 bytes)

		cmpq	$19, %rbx					# check iterator to branch
		jle		sub0						# 0 <= iterator <= 19
		
		cmpq	$39, %rbx					# check iterator to branch
		jle		sub20						# 20 <= iterator <= 39
		
		cmpq	$59, %rbx					# check iterator to branch
		jle		sub40						# 40 <= iterator <= 59

		cmpq	$79, %rbx					# check iterator to branch
		jle		sub60						# 60 <= iterator <= 79

		jmp		temp						# default branch
		
		sub0:
			andl	%ecx, %edx				# b and c
			notl	%ecx					# not b
			andl	%r8d, %ecx				# (not b) and d
			orl		%ecx, %edx				# (b and c) or ((not b) and d)
			movl	%edx, %r11d				# f = (b and c) or ((not b) and d)
			movl	$0x5A827999, %r12d		# k = 0x5A827999
			jmp		temp					# jump to next part after branching

		sub20:
			xorl	%ecx, %edx				# b xor c
			xorl	%edx, %r8d				# (b xor c) xor d
			movl	%r8d, %r11d				# f = b xor c xor d
			movl	$0x6ED9EBA1, %r12d		# k = 0x6ED9EBA1
			jmp		temp					# jump to next part after branching

		sub40:
			movl	%ecx, %r12d				# copy b
			andl	%edx, %r12d				# b and c
			andl	%r8d, %ecx				# b and d
			andl	%edx, %r8d				# c and d
			orl		%r12d, %ecx				# (b and c) or (b and d)
			orl		%ecx, %r8d				# ((b and c) or (b and d)) or (c and d)
			movl	%r8d, %r11d				# f = (b and c) or (b and d) or (c and d)
			movl	$0x8F1BBCDC, %r12d		# k = 0x8F1BBCDC
			jmp		temp					# jump to next part after branching

		sub60:
			xorl	%ecx, %edx				# b xor c
			xorl	%edx, %r8d				# (b xor c) xor d
			movl	%r8d, %r11d				# f = b xor c xor d
			movl	$0xCA62C1D6, %r12d		# k = 0xCA62C1D6
			jmp		temp					# jump to next part after branching

			
		temp:
			addq	$8, %rsp       			# move rsp to keep the stack aligned (8 bytes)
			popq	%r15					# pop h4 value from the stack
			popq	%rcx					# pop h3 value from the stack
			popq	%rdx					# pop h2 value from the stack
			popq	%r8						# pop h1 value from the stack
			popq	%r9						# pop h0 value from the stack

			movl	%r15d, %r13d			# temp = a
			roll	$5, %r13d				# temp leftrotate 5
			addl	%r11d, %r13d			# temp + f
			addl	%r9d, %r13d				# temp + e
			addl	%r12d, %r13d			# temp + k
			addl	(%rsi, %rbx, 4), %r13d	# temp + w[i]

			movl	%r8d, %r9d				# e = d
			movl	%edx, %r8d				# d = c
			roll	$30, %ecx				# b leftrotate 30
			movl	%ecx, %edx				# c = b
			movl	%r15d, %ecx				# b = a
			movl	%r13d, %r15d			# a = temp

			addq	$1, %rbx				# increment iterator
			cmpq	$79, %rbx				# keep looping as long as iterator is less than or equal to 79
			jle		mainLoop				# repeat the loop

	addl	%r15d, (%rdi)					# h0 = h0 + a
	addl	%ecx, 4(%rdi)					# h1 = h1 + b
	addl	%edx, 8(%rdi)					# h2 = h2 + c
	addl	%r8d, 12(%rdi)					# h3 = h3 + d
	addl	%r9d, 16(%rdi)					# h4 = h4 + e

	addq	$8, %rsp						# move rsp to keep the stack aligned (8 bytes)
	popq	%r15							# callee-saved register, reset the value to what is was before starting the subroutine
	popq	%r14							# callee-saved register, reset the value to what is was before starting the subroutine
	popq	%r13							# callee-saved register, reset the value to what is was before starting the subroutine
	popq	%r12							# callee-saved register, reset the value to what is was before starting the subroutine
	popq	%rbx							# callee-saved register, reset the value to what is was before starting the subroutine

	# epilogue
	movq	%rbp, %rsp						# clear local variables from stack
	popq	%rbp							# restore base pointer location
	ret
