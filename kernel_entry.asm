VIDEO_MEMORY equ 0xB8000
WHITE_ON_BLACK equ 0x0f

extern kernel

bits 32
_start:
	call switch_to_long_mode

	;call kernel

	jmp $

switch_to_long_mode:
	cli

	mov eax, cr0
	and eax, 01111111111111111111111111111111b
	mov cr0, eax

	mov edi, 0x1000
	mov cr3, edi
	xor eax, eax
	mov ecx, 4096
	rep stosd
	mov edi, cr3


	mov ebx, 0x00000003
	mov ecx, 512

	.SetEntry:
		mov dword [edi], ebx
		add ebx, 0x1000
		add edi, 8
		loop .SetEntry

	mov eax, cr4
	or eax, 1 << 5
	mov cr4, eax

	mov ecx, 0xC0000080
	rdmsr
	or eax, 1 << 8
	wrmsr

	;mov eax, cr0
	;or eax, 1 << 31
	;mov cr0, eax

jmp $

	lgdt [GDT64.Pointer]

	mov eax, cr0
	or eax, 1 << 31 | 1 << 0
	mov cr0, eax

	jmp GDT64.Code:Realm64

bits 64
Realm64:
	cli
	mov ax, GDT64.Data
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov edi, 0xB8000
	mov rax, 0x1F201F201F201F20
	mov ecx, 500
	rep stosq

	mov rbx, MSG_LONG_MODE
	call print_string_64

	call kernel

	jmp $


bits 64

print_string_64:
	mov rdx, VIDEO_MEMORY
	.loop:
		mov al, [rbx]
		mov ah, WHITE_ON_BLACK

		cmp al, 0
		je .end
		mov [rdx], ax

		inc rbx
		add rdx, 2

		jmp .loop
	.end:
	ret


GDT64:
	.Null: equ $ - GDT64
	dw 0xFFFF
	dw 0
	db 0
	db 0
	db 1
	db 0
	.Code: equ $ - GDT64
	dw 0
	dw 0
	db 0
	db 10011010b
	db 10101111b
	db 0
	.Data: equ $ - GDT64
	dw 0
	dw 0
	db 0
	db 10010010b
	db 00000000b
	db 0
	.Pointer:
	dw $ - GDT64 - 1
	dq GDT64

MSG_LONG_MODE	db "Started Long Mode weeeeeeeeeeeweeeeeeeeeee", 0
