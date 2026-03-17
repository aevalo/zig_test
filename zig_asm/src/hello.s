.data
msg:
    .asciz "Hello, World!\n"   # Define a null-terminated string with a newline
msg_len = . - msg              # Length from current location to msg

.section .text
    # global function, expose the hello_world
    .globl hello_world
    # tell compiler, we define a function
    .type hello_world, @function

hello_world:
  mov $4, %eax
  mov $1, %ebx
  mov $msg, %ecx # get parameter from register edi, you can learn more on x86-64 abi document
  mov $msg_len, %edx # the length of string
  int $0x80 # system call
  ret
