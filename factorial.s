# ************************************************************************
# * Program: Power                                                       *
# * Description: This program ask the user for a non-negative base and   *
# * exponent, call the pow subroutine to calculate the base raised to    *
# * the power of the exponent and prints the output                      *
# ************************************************************************

.bss    # storage for user input
n:   .quad 0

.text                  # code needs to be in text to work
promptN:           .asciz "\nPlease enter a non-negative number for n:\n"
result:            .asciz "\nThe result is: %ld\n"
input:             .asciz "%ld"         # format for scaning user input


.global main

main:
        # prologue
        pushq   %rbp                    # push the base pointer
        movq    %rsp, %rbp              # copy stack pointer value to base pointer

        movq    $0, %rax                # we're not fancy enough
        movq    $promptN, %rdi          # param1 for printf: string
        call    printf                  # call printf to print prompt

        movq    $0, %rax                # we're not fancy enough
        movq    $input, %rdi            # param1 for scanf: format string
        movq    $n, %rsi                # param2 for scanf: memory addresses at which scanf may put the read values
        call    scanf                   # call scanf

        movq    n, %rdi                 # param1 for factorial: number to factorial
        call    factorial               # call factorial subroutine

        movq    %rax, %r8               # move factorial subroutine output to %r8

        movq    $0, %rax                # we're not fancy enough
        movq    $result, %rdi           # param1 for printf: string
        movq    %r8, %rsi               # param2 for printf: placeholder value
        call    printf                  # call printf to print the result text

        
        # epilogue
        movq    %rbp, %rsp              # clear local variables from stack
        popq    %rbp                    # restore base pointer location

end:    # load the program exit code and exits the program

        movq    $0, %rdi
        call    exit

# ************************************************************************
# * Subroutine: factorial                                                *
# * Description: This subroutine takes as input one int and returns as   *
# * output the result of the n!                                          *
# * Parameters: one ints, returns one int                                *
# ************************************************************************
factorial:
        # prologue
        pushq   %rbp                    # push the base pointer
        movq    %rsp, %rbp              #copy stack pointer value to to base pointer

        cmpq    $0, %rdi                # stop rule for recursive subroutine: compare given parameter to 0
        je      ifcode                  # if n equal to 0 jump to if code
        jmp     else                    # else jump to else

        # stop rule for recursive subroutine: given parameter is 0
        ifcode:
                movq    $1, %rax        # copy 1 to rax (0!)
                jmp     epilogue        # skip else code


        # calling else to multiply rax by factorial n-1
        else:
                pushq   %rdi            # push parameter to the stack
                subq    $8, %rsp        # move rsp 8 bits down to keep stack aligned

                subq    $1, %rdi        # param1 for factorial: n-1
                call    factorial       # call factorial subroutine

                addq    $8, %rsp        # move rsp 8 bits up so it points at n
                popq    %r8             # pop n to r8
                imul    %r8             # signed multiply rax (factorial n-1) by n and store the result in %rax


             
        # epilogue
        epilogue:
        movq    %rbp, %rsp              # clear local variables from stack
        popq    %rbp                    # restore  base pointer location

        ret                             # return from subroutine
