        cpu 8086

        %define GeometryTableSize (GeometryTableEndLoc - GeometryTableLoc)

boottop:                        ; Label used for measuring size of the
                                ; boot sector that is used by the code
                                ; which is needed to pad out the end
                                ; of the boot sector and add the
                                ; 0x55AA at the end.
        jmp bootstart
        nop

        ;; These values must match the formatting of the floppy disk.

        GeometryTableLoc equ $

        OEMName db "hintz0.1"
        BytesPerSect dw 512
        SectPerClust db 4
        RsvdSectCnt dw 1
        FATCnt db 2
        MaxFiles dw 224
        NumFilesysSect dw 2880
        MediaType db 0xF0       ; removable disk
        FATSize dw 9            ; in sectors
        SectPerTrack dw 18
        NumHeads dw 2
        SectsBeforePart dd 0    ; number of sectors before the start
                                ; partition.
        ExtNumFilesysSect dd 0  ; 0 because NumFilesysSect is not 0.
        DrvNum db 0
        Unused0 db 0
        ExtBootSig db 29
        VolID dd 0x12345678     ; arbitrary in this case.
        VolLabel db "VOLUMELABEL"
        FilesysTypeLabel db "FAT12   "

        GeometryTableEndLoc equ $

        ;; Make sure our table above is the right size.
        %if GeometryTableSize <> 59
        %error "Geometry table as defined in this code has the wrong length."
        %endif

bootstart:

	    times 509 - $ + boottop db 0 ; Space out to offset 508
	    db GeometryTableSize         ; Bytes in geometry table
        db 0x55, 0xaa
