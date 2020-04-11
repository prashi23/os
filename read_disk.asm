;creating read disk function
read_disk:
    pusha;push everything to stack
    mov ah, 0x02;reading slectors from drive
    mov dl, 0x80; selecting drive
    mov ch, 0; selecting cylinder
    mov dh, 0
    mov al, 1
    mov cl, 2;start reading 2nd sector because bootloader is our first sector

    push bx
    mov bx, 0
    mov es, bx
    pop bx
    mov bx, 0x7c00 + 0x200

    int 0x13

    jc disk_err
    popa
    ret

    disk_err:
        mov si, DISK_ERR_MSG
        call print
        jmp $

