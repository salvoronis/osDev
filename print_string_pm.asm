[bits 32]

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

bits 64

print_string_64:
	;pusha
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
	;popa
	ret
