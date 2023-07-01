org 0x7c00
bits 16


%define END_OF_LINE 0x0d, 0x0a


; BPB (BIOS Parameter Block) - fields needed for a valid FAT12 file system - https://wiki.osdev.org/FAT
; used a fat header example for the values.

jmp short start
nop
db 'MSWIN4.1'       ; OEM identifier
dw 512              ; Bytes per sector
db 1                ; Sectors per cluster
dw 1                ; Reserved sectors
db 2                ; Number of FAT's (File allocation tables)
dw 0xE0             ; Number of root directory entries
dw 2880             ; Total sectors
db 0xF0             ; Media descriptor type - F0 = https://en.wikipedia.org/wiki/Design_of_the_FAT_file_system#BPB20_OFS_0Ah
dw 9                ; Number of sectors per FAT
dw 18               ; Number of sectors per track
dw 2                ; Number of sides on the storage media
dd 0                ; Number of hidden sectors
dd 0                ; Number of large sector

; EBR - Extended Boot Record

db 0                ; Drive number - 0x00 for floppy and 0x80 for hard disk
db 0                ; Reserved byte
db 0x29             ; Signature - must be 0x28 or 0x29
dd 0x80112005       ; VolumeID 'Serial' number. Can be ignored
db 'IDAN GUR OS'    ; Volume label string. 11 bytes
db 'FAT12   '       ; System identifier string. 8 bytes


;
; Code starts here
;


start:
    jmp main


print_string:
    ;
    ; prints a string to the screen
    ; params:
    ;   ds:si pointer to string
    ;

    push si
    push ax
    push bx

.loop:
    lodsb  ; load ds:si to al and then inc si by num of bytes loaded - loads next char at a time

    ; check if al is null(0) if it is then the 0 flag is set so jumps to .done
    or al, al
    jz .done

    ; call bios interrupt
    mov ah, 0x0E
    mov bh, 0
    int 0x10

    jmp .loop

.done:
    pop bx
    pop ax
    pop si
    ret

main:
    ; setup data segments
    mov ax, 0  ; cant write directly to ds/es 
    mov ds, ax
    mov es, ax

    ; setup stack
    mov ss, ax
    mov sp, 0x7c00

    ; print the string
    mov si, msg
    call print_string

    mov si, msg_2
    call print_string

    hlt

.halt:
    jmp $


msg: db 'Hello there', END_OF_LINE, 0
msg_2: db 'Hello World', END_OF_LINE, 0


times 510-($-$$) db 0
db 0x55, 0xaa