# ************************************************************************
# * Program: Power                                                       *
# * Description: This program ask the user for a non-negative base and   *
# * exponent, call the pow subroutine to calculate the base raised to    *
# * the power of the exponent and prints the output                      *
# ************************************************************************

.bss    # storage for user input
base:   .quad 0
exp:    .quad 0

.text                  # code needs to be in text to work
promptBase:           .asciz "\nPlease enter a non-negative number for base:\n"
promptExp:            .asciz "\nPlease enter a non-negative number for exponent:\n"
inputFormat:          .asciz "%ld"
result:               .asciz "\nThe result is: "
newLine:              .asciz "\n"


.global main

main:
        # prologue
        pushq   %rbp                    # push the base pointer
        movq    %rsp, %rbp              # copy stack pointer value to base pointer

        movq    $0, %rax                # we're not fancy enough
        movq    $promptBase, %rdi       # param1 for printf: string
        call    printf                  # call printf to print first prompt

        movq    $0, %rax                # we're not fancy enough
        movq    $inputFormat, %rdi      # param1 for scanf: format string
        movq    $base, %rsi             # param2 for scanf: memory addresses at which scanf may put the read values
        call    scanf                   # call scanf

        movq    $0, %rax                # we're not fancy enough
        movq    $promptExp, %rdi        # param1 for printf: string
        call    printf                  # call printf to print second prompt

        movq    $0, %rax                # we're not fancy enough
        movq    $inputFormat, %rdi      # param1 for scanf: format long decimal number (64 bits)
        movq    $exp, %rsi              # param2 for scanf: memory addresses at which scanf may put the read values
        call    scanf                   # call scanf

        movq    base, %rdi              # param1 for pow: base
        movq    exp, %rsi               # param2 for pow: exponent
        call    pow                     # call pow subroutine

        movq    %rax, %r8               # move pow subroutine output to %r8

        movq    $0, %rax                # we're not fancy enough
        movq    $result, %rdi           # param1 for printf: string
        call    printf                  # call printf to print the result text

        movq    $0, %rax                # we're not fancy enough
        movq    $inputFormat, %rdi      # param1 for printf: format long decimal number (64 bits)
        movq    %r8, %rsi               # param2 for printf: value to print
        call    printf                  # call printf

        movq    $0, %rax                # we're not fancy enough
        movq    $newLine, %rdi          # param1 for printf: string
        call    printf                  # call printf to print new line


        
        # epilogue
        movq    %rbp, %rsp              # clear local variables from stack
        popq    %rbp                    # restore base pointer location

end:    # load the program exit code and exits the program

        movq    $0, %rdi
        call    exit

# ************************************************************************
# * Subroutine: pow                                                      *
# * Description: This subroutine takes as input two ints and returns as  *
# * output the result of the first one raised to power of the second     *
# * Parameters: Two ints, returns one int                                *
# ************************************************************************
pow:
        # prologue
        pushq   %rbp                    # push the base pointer
        movq    %rsp, %rbp              #copy stack pointer value to to base pointer

        movq    $0, %rcx                # initialize rcx as iterator
        movq    $1, %rax                # initializing rax for multiplication

        movq    %rdi, %r8               # take base value from paramet
        movq    %rsi, %r9               # take exponent value from paramet
        
        cmpq    $0, %r9                 # compare exponent to 0
        je      ifcode                  # if exponent equal to 0 jump to if code
        jmp     loop                    # else jump to loop

        # changing base to 1
        ifcode:
                movq    $1, %r8         # change base to 1
                jmp     epilogue        # skip loop


        # calling loop to multiply the base by itself
        loop:

                imul     %r8            # signed multiply base by itself and store the result in %rax
                addq    $1, %rcx        # increment rcx by 1


                cmpq    %rcx, %r9       # compare exponent to iterator
                jg      loop            # repeat the loop as long as exponent greater than iterator


             
        # epilogue
        epilogue:
        movq    %rbp, %rsp              # clear local variables from stack
        popq    %rbp                    # restore  base pointer location

        ret                             # return from subroutine
        