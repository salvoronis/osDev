bits 16
org 0x7C00

KERNEL_OFFSET equ 0x1000 ; offset to reach main func in kernel.c
boot:
	mov [BOOT_DRIVE], dl ; store boot drive in DL

	mov bp, 0x9000
	mov sp, bp

	mov bx, MSG_REAL_MODE
	call print_string

	call load_kernel

	call switch_to_32

	;call switch_to_64

	jmp $

; bx - symbol
print_string:
	mov ah, 0x0e
	print_string_loop:
		mov al, [bx]

		cmp al, 0
		je print_string_done

		int 0x10

		inc bx
		jmp print_string_loop

	print_string_done:
		ret

; load dh sector to es:bx from drive dl
disk_load:
	push dx

	mov ah, 0x02	; BIOS read sec func
	mov al, dh	; read dh sector
	mov ch, 0x00	; read cylinder 0
	mov dh, 0x00	; select head 0
	mov cl, 0x02	; start reading from second sector after boot sector

	int 0x13

	jc disk_error

	pop dx
	cmp dh, al
	jne disk_error
	ret

disk_error:
	mov bx, DISK_ERROR_MSG
	call print_string
	jmp $

DISK_ERROR_MSG db "Disk read error",0

gdt_start:
gdt_null:
	dq 0x0

gdt_code:
	; base=0x0, limit=0xfffff
	; 1st flags: (present)1 (privilege)00 (descr type)1 -> 1001b
	; type flags: (code)1 (conforming)0 (readable)1 (accessed)0 -> 1010b
	; 2nd flags: (granularity)1 (32-bit default)1 (64-bit seg)0 (AVL)0 -> 1100b
	dw 0xffff	; Limit 0-15
	dw 0x0		; Base 0-15
	db 0x0		; Base 16-23
	db 10011010b	; 1st flag, type flag
	db 11001111b	; 2nd flags, Limit 16-19
	db 0x0

gdt_data:
	;type flags: (code)0 (expand down)0 (writable)1 (accessed)0 -> 0010b
	dw 0xffff
	dw 0x0
	db 0x0
	db 10010010b
	db 11001111b
	db 0x0

gdt_end:

gdt_descriptor:
	dw gdt_end - gdt_start - 1
	dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

;GDT64:
;	.Null: equ $ - GDT64
;	dw 0xFFFF
;	dw 0
;	db 0
;	db 0
;	db 1
;	db 0
;	.Code: equ $ - GDT64
;	dw 0
;	dw 0
;	db 0
;	db 10011010b
;	db 10101111b
;	db 0
;	.Data: equ $ - GDT64
;	dw 0
;	dw 0
;	db 0
;	db 10010010b
;	db 00000000b
;	db 0
;	.Pointer:
;	dw $ - GDT64 - 1
;	dq GDT64

bits 32

VIDEO_MEMORY equ 0xB8000
WHITE_ON_BLACK equ 0x0f

print_string_pm:
	pusha
	mov edx, VIDEO_MEMORY

print_string_pm_loop:
	mov al, [ebx]
	mov ah, WHITE_ON_BLACK

	cmp al, 0
	je print_string_pm_done

	mov [edx], ax

	inc ebx
	add edx, 2

	jmp print_string_pm_loop

print_string_pm_done:
	popa
	ret

;bits 64

;print_string_64:
;	mov rdx, VIDEO_MEMORY
;	.loop:
;		mov al, [rbx]
;		mov ah, WHITE_ON_BLACK
;
;		cmp al, 0
;		je .end
;		mov [rdx], ax
;
;		inc rbx
;		add rdx, 2
;
;		jmp .loop
;	.end:
;	ret

bits 16

switch_to_32:
	cli
	lgdt [gdt_descriptor] ; load global descriptor table

	mov eax, cr0
	or eax, 1 << 0
	mov cr0, eax

	jmp CODE_SEG:init_pm

bits 32
init_pm:
	mov ax, DATA_SEG
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax

	mov ebp, 0x90000
	mov esp, ebp

	call BEGIN_PM

	jmp $
	;ret

;switch_to_64:
;	cli
;	lgdt[GDT64.Pointer]
;
;	mov eax, cr0
;	and eax, 01111111111111111111111111111111b
;	mov cr0, eax
;
;	jmp GDT64.Code:init64
;
;bits 64

;init64:
;	cli
;	mov ax, GDT64.Data
;	mov ds, ax
;	mov es, ax
;	mov fs, ax
;	mov gs, ax
;	mov ss, ax
;	mov edi, 0xB8000
;	mov rax, 0x1f201f201f201f20
;	mov ecx, 500
;
;	mov rbp, 0x90000
;	mov rsp, rbp
;
;	call BEGIN_64

bits 16

load_kernel:
	mov bx, KERNEL_OFFSET ; destination
	mov dh, 16 ; 16 sectors of drive
	mov dl, [BOOT_DRIVE]
	call disk_load

	mov bx, MSG_LOAD_KERNEL
	call print_string

	;jmp KERNEL_OFFSET

	ret

bits 32

BEGIN_PM:
	mov ebx, MSG_PROT_MODE
	call print_string_pm

	;ret

	jmp KERNEL_OFFSET

	;jmp $

;bits 64

;BEGIN_64:
;	rep stosq
;
;	mov rbx, MSG_LONG_MODE
;	call print_string_64
;
;	jmp KERNEL_OFFSET
;	jmp $

BOOT_DRIVE	db 0
MSG_REAL_MODE	db "Starting 16-bit real mode", 0
MSG_PROT_MODE	db "Switched to 32bit", 0
MSG_LOAD_KERNEL	db "Loading kernel", 0
;MSG_LONG_MODE	db "Switched to Long Mode",0

times 510-($-$$) db 0
dw 0xAA55
