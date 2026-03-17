section     .data
msg     db  'Hello World!',10                    ; Our message with a newline
len     equ $ - msg                             ; Calculate length of message

section .text
global hello_world

hello_world:
    mov rax, 4        ; sys_write
    mov rbx, 1        ; stdout
    mov rcx, msg      ; buffer pointer (argument passed in EDI)
    mov rdx, len      ; length of string
    int 0x80           ; system call
    ret
