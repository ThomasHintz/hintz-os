        ;; A basic hello world written in the boot sector.
        ;;
        ;; Modified slightly to output two hello worlds.

        org 0x7c00

        xor ax, ax              ; Set ax to 0. asdf asd fasdf asdf asd
                                ; xor is fewer bytes than move and
                                ; doesn't require an immediate value
                                ; to be loaded from memory.
        mov ds, ax              ; set data segment to 0

        mov si, msg             ; Set string index pointer to the
                                ; start of the message.

print_loop:
        lodsb                   ; Load string.
        or al, al               ; zero = end of string
        jz print_loop2          ; Jump to next print when result of
                                ; previous instruction is equal to 0,
                                ; which is the end of the string.
        mov ah, 0x0E
        int 0x10                ; Output interrupt.
        jmp print_loop



	    xor ax, ax
        mov ds, ax

        mov si, msg2

print_loop2:
        lodsb
        or al, al
        jz hang                 ; Jump to hang when result of previous
                                ; instruction is equal to 0.
        mov ah, 0x0E
        int 0x10
        jmp print_loop


hang:
        jmp hang


msg:    db 'Hello world.', 13, 10, 0
msg2:   db 'Hello world2.', 13, 10, 0

        times 510 - ($-$$) db 0

        dw	 0xAA55
