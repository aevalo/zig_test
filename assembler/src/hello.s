.globl hello_world
# global function, expose the hello_world
.type hello_world, @function
# tell compiler, we define a function
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
