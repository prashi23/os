[org 0x7c00]

MOV si, STR
call printf
;JUMP TO CURRENT LOCATION
JMP $
printf:
    PUSHA  ;to print everything on stack and pusha works only on 16bit mode
    str_loop:
        MOV al, [si]
        cmp al, 0
        jne print_char
        popa
        ret

    print_char:
        mov ah, 0x0e
        int 0x10
        add si, 1
        jmp str_loop

STR: db 'hello world', 0

;PADDING AND MAGIC NUMBER
TIMES 510- ($- $$) DB 0
DW 0XAA55