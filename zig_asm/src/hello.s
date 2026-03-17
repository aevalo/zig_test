.data
    msg:
        .asciz "Hello, World!\n"   # Define a null-terminated string with a newline
    msg_len = . - msg              # Length from current location to msg

.text
    .globl greet
    .globl hello_world
    .type greet, @function
    .type hello_world, @function

greet:
    mov $4, %eax
    mov $1, %ebx
    mov %edi, %ecx    # buffer pointer (argument passed in EDI)
    mov %esi, %edx      # length of string
    int $0x80 # system call
    ret

hello_world:
    mov $4, %eax
    mov $1, %ebx
    mov $msg, %ecx # get parameter from register edi, you can learn more on x86-64 abi document
    mov $msg_len, %edx # the length of string
    int $0x80 # system call
    ret
