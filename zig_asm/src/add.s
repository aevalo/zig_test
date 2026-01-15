    .text
    .globl add
    .type add, @function

add:
    # Reset the register value to zero. The value will be returned from the
    # function as the result.
    xor %rax, %rax
    movl %edi, %eax    # eax = a
    addl %esi, %eax    # eax += b
    ret
