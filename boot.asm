        cpu 8086

        %define GeometryTableSize (GeometryTableEndLoc - GeometryTableLoc)
        %define MAXFATSECS 40   ; max sectors allowed in fat

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
        SectPerClust db 1
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
        VolID dd 0x517a0297
        VolLabel db "           "
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

;; AH = 02h : the interrupt code for reading from disk
;; AL = number of sectors to read (must be nonzero)
;; CH = low eight bits of cylinder number
;; CL = sector number 1-63 (bits 0-5)
;;   high two bits of cylinder (bits 6-7, hard disk only)
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

        mov ax, [RawSecNum]     ; fetch 0-based sector number
        div byte [SecsPerCyl]   ; split into two parts
        mov ch, al              ; save the cylinder number

        mov al, ah              ; copy sector within the cyl
        xor ah, ah              ; make it 16-bit
        div byte [SectPerTrack] ; split this into two
        mov dh, al              ; save track or head number
        mov cl, ah              ; form 1-based
        inc cl                  ; sector number

        mov ax, 0x0201          ; command to read 1 sector
        int 0x13                ; read sector

        mov al, "g"
        call printc

        ret

findkernel:

        mov al, "f"             ; find kernel
        call printc

        mov ax, [RootDirSectorStart]
        mov [RawSecNum], ax
        call getsector

        ret

bootstart:

        ;; setup data segment
        mov ax, 0x07c0          ; point at start of this code
        mov ds, ax              ; set ds
        mov es, ax              ; set es

        ;; setup the stack
        xor ax, ax              ; clear ax
        mov ss, ax              ; set ss and pause interrupts
        mov sp, ax              ; stack at top of base 64k

        mov [DrvNum], dl        ; save boot drive

        cld

        mov byte al, [SectPerClust] ; secs/cluster in AX
        mul word [BytesPerSect]     ; form bytes per cluster
        mov [BytesPerClust], ax

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
        BytesPerClust resw 1
