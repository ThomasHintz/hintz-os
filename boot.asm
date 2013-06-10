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
        jz hang                 ; Jump to next print when result of
                                ; previous instruction is equal to 0,
                                ; which is the end of the string.
        mov ah, 0x0E
        int 0x10                ; Output interrupt.
        jmp print_loop


hang:
        jmp hang


msg:    db 'Hello world.', 13, 10, 0

        times 510 - ($-$$) db 0

        dw	 0xAA55
