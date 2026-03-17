section .text
global add

add:
    xor rax, rax
    mov eax, edi    ; eax = a
    add eax, esi    ; eax += b
    ret
