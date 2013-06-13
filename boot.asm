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

        ;; char should be in register al
printc:
        mov ah, 0x0E
        int 0x10
        ret

hang:
        jmp hang

;; AH = 02h
;; AL = number of sectors to read (must be nonzero)
;; CH = low eight bits of cylinder number
;; CL = sector number 1-63 (bits 0-5)
;; high two bits of cylinder (bits 6-7, hard disk only)
;; DH = head number
;; DL = drive number (bit 7 set for hard disk)
;; ES:BX -> data buffer
;;
;; Return: CF set on error if AH = 11h (corrected ECC error), AL =
;; burst length CF clear if successful AH = status (see #00234) AL =
;; number of sectors transferred (only valid if CF set for some
;; BIOSes)

getsector:
        mov ax, [RawSecNum]
        mov dl, [DrvNum]        ; set drive number

        mov ax, 0x0201          ; command to read 1 sector
        int 0x13                ; read sector

findkernel:

        ;; need to get the start of the root sector
        mov al, "f"             ; find kernel
        call printc

        call getsector

        ret

bootstart:

        cld

        mov al, "s"             ; start the process
        call printc

        mov ax, [SectPerTrack]
        mul byte [NumHeads]
        mov [SecsPerCyl], al

        call findkernel

        jmp hang

	    times 509 - $ + boottop db 0 ; Space out to offset 508
	    db GeometryTableSize         ; Bytes in geometry table
        db 0x55, 0xaa

section .bss
        RootDirSectorStart resw 1 ; Sector root dir starts at.
        RootDirNumSectors resw 1  ; Sectors in root dir.
        RawSecNum resw 1
        SecsPerCyl resw 1
