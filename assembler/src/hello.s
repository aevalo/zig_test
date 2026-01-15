# global function, expose the hello_world
.globl hello_world
# tell compiler, we define a function
.type hello_world, @function

.section .text
hello_world:
  mov $4, %eax
  mov $1, %ebx
  mov %edi, %ecx
  # get parameter from register edi, you can learn more on x86-64 abi document
  mov $0xd, %edx
  # the length of string
  int $0x80
  # system call
  ret
