section .text
global add
add:
    mov eax, edi    ; eax = a
    add eax, esi    ; eax += b
    ret
