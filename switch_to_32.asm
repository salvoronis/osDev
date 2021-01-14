bits 16

switch_to_32:
	cli
	lgdt [gdt_descriptor] ; load global descriptor table

	mov eax, cr0
	or eax, 0x1
	mov cr0, eax

	call CODE_SEG:init_pm

	ret

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

	ret

switch_to_64:
	lgdt[GDT64.Pointer]
	jmp GDT64.Code:init64

bits 64

init64:
	cli
	mov ax, GDT64.Data
	mov ds, ax
	mov es, ax
	mov fs, ax
	mov gs, ax
	mov ss, ax
	mov edi, 0xB8000
	mov rax, 0x1f201f201f201f20
	mov ecx, 500

	mov rbp, 0x90000
	mov rsp, rbp

	call BEGIN_64
