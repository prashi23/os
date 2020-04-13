;0x0000-0xffff
;0x0000-0xf000

;segment:offset
;segmentation formula
;addr = segment * 16 + offset
test_a20:
    pusha
    mov ax, [0x7dfe]
    push bx
    mov bx, 0xffff
    mov es, bx
    pop bx
    mov bx, 0x7e0e
    mov dx, [es:bx]
    cmp ax, dx
    je .cont
    popa
    mov ax, 1
    ret

.cont:
    mov ax, [0x7dff]

    push bx
    mov bx, 0xffff
    mov es, bx
    pop bx

    mov bx, 0x7e0f
    mov dx, [es:bx]

    cmp ax, dx
    je .exit

    popa
    mov ax, 1
    ret

.exit:
    popa
    xor ax, ax
    ret