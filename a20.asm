a20:
    pusha
    mov ax, 0x2401
    int 0x15

    call test_a20
    cmp ax, 1
    je .done
    sti

    call waitC        ; wait for controller to accept command
    mov al, 0xad      ; 0xad is the disable keyboard command
    out 0x64, al      ; send the command to port 0x64 (command port)

    call waitC
    mov al, 0xd0      ; 0xd0 is the command that allows us to read from the controller
    out 0x64, al

    call waitD        ; wait for controller data to be ready
    in al, 0x60       ; store data from port 0x60 (data port) in al
    push ax           ; push to the stack for later

    call waitC
    mov al, 0xd1      ; 0xd1 command tells the controller we want to write data to it
    out 0x64, al

    call waitC
    pop ax            ; pop data from stack
    or al, 2          ; mask bit #2
    out 0x60, al      ; send to controller through data port

    call waitC
    mov al, 0xae      ; 0xae enabled the keyboard
    out 0x64, al

    call waitC

    sti

    call test_a20
    cmp ax, 1
    je .done

;FastA20
    in al, 0x92       ; read data through port 0x92 (chipset)
    or al, 2          ; mask bit 2
    out 0x92, al      ; send data back to chipset

    call test_a20
    cmp al, 1
    je .done

    mov si, NO_A20
    call print
    jmp $

.done:
  mov si, A20DONE
  call print
  popa
  ret

waitC:              ; wait for controller to accept commands
  in al, 0x64       ; get status from command port
  test al, 2        ; is bit2 of al = 1?
                    ; 1 = busy, 0 = ready
  jnz waitC         ; if it is (jump if not equal to zero), try again
  ret

waitD:              ; wait for controller to have data to read
  in al, 0x64       ; get status from command port
  test al, 1        ; is bit1 of al = 1?
                    ; 0 = empty, 1 = full
  jz waitD          ; if data is empty try again (jump if zero)
  ret