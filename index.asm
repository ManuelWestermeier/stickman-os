; File: stickman.asm

org 0x7C00             ; Origin, the BIOS loads boot sector to 0x7C00

section .text

start:
    ; Set up stack
    cli                 ; Disable interrupts
    xor ax, ax
    mov ss, ax
    mov sp, 0x7C00
    sti                 ; Enable interrupts

    ; Set video mode to 13h (320x200, 256 colors)
    mov ax, 0x0013
    int 0x10

    ; Draw the stickman
    call draw_stickman

    ; Infinite loop to keep the program running
.hang:
    hlt
    jmp .hang

draw_stickman:
    ; Draw head (circle)
    call draw_circle

    ; Draw body (vertical line)
    call draw_body

    ; Draw arms
    call draw_arms

    ; Draw legs
    call draw_legs

    ret

draw_circle:
    ; Draws a simple circle for the head
    ; Center (160, 80), radius 10, color 15 (white)
    mov cx, 160
    mov dx, 80
    mov bx, 10
    mov al, 15
    call circle

    ret

draw_body:
    ; Draws the body (vertical line)
    ; From (160, 90) to (160, 130), color 15
    mov ax, 160
    mov bx, 90
    mov cx, 160
    mov dx, 130
    mov al, 15
    call line

    ret

draw_arms:
    ; Draws the arms
    ; Left arm from (160, 100) to (140, 120), color 15
    mov ax, 160
    mov bx, 100
    mov cx, 140
    mov dx, 120
    mov al, 15
    call line

    ; Right arm from (160, 100) to (180, 120), color 15
    mov ax, 160
    mov bx, 100
    mov cx, 180
    mov dx, 120
    mov al, 15
    call line

    ret

draw_legs:
    ; Draws the legs
    ; Left leg from (160, 130) to (140, 170), color 15
    mov ax, 160
    mov bx, 130
    mov cx, 140
    mov dx, 170
    mov al, 15
    call line

    ; Right leg from (160, 130) to (180, 170), color 15
    mov ax, 160
    mov bx, 130
    mov cx, 180
    mov dx, 170
    mov al, 15
    call line

    ret

circle:
    ; Draw a circle using the midpoint circle algorithm
    ; Inputs: CX = X center, DX = Y center, BX = radius, AL = color
    push ax
    push bx
    push cx
    push dx

    mov di, dx
    mov dh, dl
    mov dl, dh
    mov dh, al

    mov ax, 0
    mov dx, bx
    mov si, 1
    sub si, bx
    add si, 1
    add dx, dx

.loop1:
    call plot_8_circle_points

    inc ax
    sub si, ax
    add si, 2
    cmp si, 0
    jae .skip
    dec dx
    add si, 2
.skip:
    cmp ax, dx
    jb .loop1

    pop dx
    pop cx
    pop bx
    pop ax
    ret

plot_8_circle_points:
    ; Plot points for all eight octants
    ; Inputs: AX = X, DX = Y, CX = X center, DI = Y center, DH = color
    push ax
    push bx
    push cx
    push dx

    mov bx, ax
    mov ah, dh
    add bx, cx
    add dx, di
    call putpixel

    mov bx, ax
    add bx, cx
    sub dx, di
    call putpixel

    mov bx, cx
    sub bx, ax
    add dx, di
    call putpixel

    mov bx, cx
    sub bx, ax
    sub dx, di
    call putpixel

    mov bx, dx
    add bx, di
    add ax, cx
    call putpixel

    mov bx, dx
    add bx, di
    sub ax, cx
    call putpixel

    mov bx, di
    sub bx, dx
    add ax, cx
    call putpixel

    mov bx, di
    sub bx, dx
    sub ax, cx
    call putpixel

    pop dx
    pop cx
    pop bx
    pop ax
    ret

line:
    ; Draw a line using Bresenham's line algorithm
    ; Inputs: AX = x1, BX = y1, CX = x2, DX = y2, AL = color
    push ax
    push bx
    push cx
    push dx

    mov si, cx
    sub si, ax
    jns .dx_positive
    neg si
.dx_positive:
    mov di, dx
    sub di, bx
    jns .dy_positive
    neg di
.dy_positive:
    cmp si, di
    ja .dx_greater
    xchg si, di
    xchg ax, bx
    xchg cx, dx
.dx_greater:
    shl si, 1
    shl di, 1
    mov bp, di
    sub bp, si
    shr si, 1
    shr di, 1
    add bp, si

.loop:
    call putpixel

    cmp ax, cx
    je .done
    cmp ax, cx
    jg .dx_negative
    inc ax
    jmp .no_dx_neg
.dx_negative:
    dec ax
.no_dx_neg:

    cmp bx, dx
    je .done
    cmp bx, dx
    jg .dy_negative
    inc bx
    jmp .no_dy_neg
.dy_negative:
    dec bx
.no_dy_neg:
    sub bp, si
    cmp bp, 0
    jl .skip
    add bp, di
.skip:
    jmp .loop
.done:

    pop dx
    pop cx
    pop bx
    pop ax
    ret

putpixel:
    ; Plot a pixel on the screen
    ; Inputs: BX = X, DX = Y, AL = color
    mov ah, 0x0C
    mov bh, 0x00
    int 0x10
    ret

times 510-($-$$) db 0   ; Fill the rest of the boot sector with zeros
dw 0xAA55               ; Boot sector signature