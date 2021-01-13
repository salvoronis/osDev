bits 64
extern kernel
_start:
	mov rdx, 0xB8000
	mov al, "H"
	mov ah, 0x0f
	mov [rdx], ax

	call kernel

	jmp $
