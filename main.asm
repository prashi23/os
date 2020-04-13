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
    cli
    jmp 0x0000:zeroseg;so that our buffer is nothing

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


mov si, Loading
call print
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
; Load sectors from our disk
mov dl, 0x80
mov al, 2		; sectors to read
mov cl, 2		; start sector
mov bx, sTwo		; offset

call read_disk
;jmp test
;call printhex

call test_a20
mov dx,ax
call printhex

call a20;enablea20

jmp sTwo

;JUMP TO CURRENT LOCATION
JMP $

%include "./print.asm"
%include "./read_disk.asm"
%include "./printhex.asm"
%include "./test_a20.asm"
%include "./a20.asm"
%include "./check.asm"
%include "./gdt.asm"

;STR_0: db 'Loaded in 16bit Real mode to memory location 0x7c00.', 0x3e,0x3d, 0
;STR_T: db 'These messages use the BIOS interrupt 0x16 with the ah register set to 0x0e.', 0x10, 0x9d, 0
;STR_TH : db 'Heraclitus test boot complete. Power off this machine nad load a real OS, dummy.', 0

Loading: db 'Loading...', 0x0a, 0x0d, 0
DISK_ERR_MSG: db 'Error Loading Disk.', 0x0a, 0x0d, 0
;TEST_STR: db 'You are in the second sector.', 0x0a, 0x0d, 0
NO_A20: db 'No A20 line.', 0x0a, 0x0d, 0
A20DONE: db 'A20 Line Enabled.', 0x0a, 0x0d, 0
NO_LM: db 'No long mode support.', 0x0a, 0x0d, 0
YES_LM: db 'Long Mode supported.', 0x0a, 0x0d, 0
;DISK_ERR_MSG: db 'Error Loading Disk.', 0x0e, 0x0d, 0
testing_str: db 'Welcome to my OS', 0x0a, 0x0d, 0

;PADDING AND MAGIC NUMBER
;TIMES 510- ($- $$) DB 0
;DW 0XAA55

;test:
;mov si, testing_str
;call print


;times 512 db 0





sTwo:
mov si, TEST_STR
call print

call check

push bx
xor bx, bx
mov es, bx
pop bx

mov dl, 0x80
mov al, 3
mov cl, 3
mov bx, Kernel
call read_disk

cli

mov edi, 0x1000
mov cr3, edi
xor eax, eax
mov ecx, 4096
rep stosd
mov edi, 0x1000

;PML4T -> 0x1000
;PDPT -> 0x2000
;PDT -> 0x3000
;PT -> 0x4000

mov dword [edi], 0x2003
add edi, 0x1000
mov dword [edi], 0x3003
add edi, 0x1000
mov dword [edi], 0x4003
add edi, 0x1000

mov dword ebx, 3
mov ecx, 512

.setEntry:
    mov dword [edi], ebx
    add ebx, 0x1000
    add edi, 8
    loop .setEntry

mov eax, cr4
or eax, 1 << 5
mov cr4, eax

mov ecx, 0xc0000080
rdmsr
or eax, 1 << 8
wrmsr

mov eax, cr0
or eax, 1 << 31
or eax, 1 << 0
mov cr0, eax

lgdt [GDT.Pointer]
jmp GDT.Code:LongMode

TEST_STR: db 'You are in the second sector.', 0x0a, 0x0d, 0


[bits 64]
LongMode:

VID_MEM equ 0xb8000
mov edi, VID_MEM
mov rax, 0x8f208f208f208f20
mov ecx, 500
rep stosq

jmp Kernel

hlt
times 512-($-$$-512) db 0
;times 1048576 - ($-($$ + 512)) db 0 ; precise padding to fill up 1MB

Kernel:

mov rax, 0x8f658f4b
mov [VID_MEM], rax

mov rax, 0x8f6c8f658f6e8f72
mov [VID_MEM+4], rax

hlt

times 4096 db 0
;times 5120 db 0