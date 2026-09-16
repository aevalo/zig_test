.text
    .globl foo
    .type foo, @function

foo:
    # Function prologue
    pushq %rbp
    movq  %rsp, %rbp

    # Allocate space for local variables
    subq  $8, %rsp

    # Access local variables
    movl  $42, -4(%rbp)
    movl  -4(%rbp), %eax

    # Function epilogue
    movq  %rbp, %rsp
    popq  %rbp
    ret
