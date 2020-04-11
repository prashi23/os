[org 0x7c00];default space for bootsector
[bits 16]

;section .data
;    ;constants
;    VAL equ 0x1234

;section .bss
;    ;mutable variables
;    VAR: resb 8 ;8 bytes reserved for var

section .text
    global main

main:;main is the entry point

    jmp 0x00:zeroseg;so that our buffer is nothing

zeroseg:
    xor ax, ax;sets ax to boolean, it's same as mov ax, 0 but this is just 2bytes
    mov ss, ax
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov sp, main
    cld; clear direction flag to read string from lowesr
sti ; get rid of interrupts

push ax
xor ax, ax
int 0x13
pop ax

;MOV si, STR_0
;call printf
;mov si, STR_T
;call printf
;mov si, STR_TH
;call printf

call read_disk
;jmp test
call printhex
;JUMP TO CURRENT LOCATION
JMP $

%include "./print.asm"
%include "./read_disk.asm"
%include "./printhex.asm"

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
call print


times 512 db 0