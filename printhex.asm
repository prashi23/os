printhex:

;mov si, HEX_PATTERN
;call print

;ret

;HEX_PATTERN: db '0x****', 0x0a, 0x0d, 0

HEX_CHAR_TABLE db "0123456789ABCDEFGH"
    pusha
    mov ah, 0x0e ; Teletype Output
    mov al, "0"
    int 0x10
    mov al, "x"
    int 0x10
    mov cx, 16
.charLoop:
    sub cx, 4
    mov bx, dx
    shr bx, cl
    and bx, 0x000f
    mov al, [bx + HEX_CHAR_TABLE]
    int 0x10 ; Video Services
    or cx, cx
    jne .charLoop
mov al, 0x0d
int 0x10
mov al, 0x0a
int 0x10
popa
ret