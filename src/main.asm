org 0x7c00
bits 16


%define END_OF_LINE 0x0d, 0x0a


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

    hlt

jmp $


msg: db 'Hello there', END_OF_LINE, 0


times 510-($-$$) db 0
db 0x55, 0xaa