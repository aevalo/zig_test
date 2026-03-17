.text
.globl my_strlen
.type my_strlen, @function

# Function that returns the length of the string passed in the first argument
my_strlen:
    # Reset the register value to zero. The value will be returned from the
    # function as the result.
    xor %rax, %rax
.loop:
    # Compare the first element in the given string with the `NUL` terminator (end of the string).
    cmpb $0, (%rdi,%rax)
    # If we reached the `NUL` terminator, exit from the function.
    je .done
    # Increase the counter that stores the length of the string.
    inc %rax
    # Repeat the operations above until we reach the end of the string.
    jmp .loop
.done:
    # Exit from the function and return the result in the `rax` register.
    ret
