        ;; Just run and do nothing.
        ;;
        ;; Tells the CPU not to execute interrupts and then tells the
        ;; CPU to waith for an interrupt thus effectively stalling the
        ;; program.

        org     0x7c00          ; We are loaded by BIOS at 0x7C00.
                                ; This is important as changing it or
                                ; leaving it out starts loading at 0x0
                                ; which impacts the locations in the
                                ; rest of the program.

        bits    16              ; We are still in 16 bit Real Mode.
                                ; This line is a NASM directive to
                                ; assemble in 16 bits and not 32. NASM
                                ; defaults to 16 bits so it isn't
                                ; neccessary to manually specify it
                                ; here.

Start:

        cli                     ; Clear all Interrupts. Set the
                                ; interrupt flag to 0. Essentially
                                ; just delays all interrupts until a
                                ; later time.

        hlt                     ; Halt the system. Stops execution
                                ; until the next hardware interrupt.
                                ; Basically puts the cpu to sleep
                                ; until it has something to do.

        times 510 - ($-$$) db 0 ; We have to be 512 bytes. Clear the
                                ; rest of the bytes with 0. Times
                                ; causes the instruction to be
                                ; assembled multiple times. This
                                ; basically just fills the rest of the
                                ; image with 0.

        dw	 0xAA55             ; Boot Signature.
                                ; Old versions of bioses looked for
                                ; this in order to find a boot sector.
                                ; dw 0xAA55 is equivalent to db 0x55
                                ; db 0xAA.
