[org 0x7c00];default space for bootsector

;MOV si, STR_0
;call printf
;mov si, STR_T
;call printf
;mov si, STR_TH
;call printf

call readDisk
jmp test

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

;creating read disk function
readDisk:
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
        call printf
        jmp $


;STR_0: db 'Loaded in 16bit Real mode to memory location 0x7c00.', 0x3e,0x3d, 0
;STR_T: db 'These messages use the BIOS interrupt 0x16 with the ah register set to 0x0e.', 0x10, 0x9d, 0
;STR_TH : db 'Heraclitus test boot complete. Power off this machine nad load a real OS, dummy.', 0

DISK_ERR_MSG: db 'Error Loading Disk.', 0x0e, 0x0d, 0
testing_str: db 'Welcome to my OS', 0x0a, 0x0d, 0

;PADDING AND MAGIC NUMBER
TIMES 510- ($- $$) DB 0
DW 0XAA55

test:
mov si, testing_str
call printf


times 512 db 0