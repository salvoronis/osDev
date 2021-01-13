CC = gcc
ASM = nasm
LD = ld

all: os-image

run: all
	qemu-system-x86_64 os-image

kernel.o: kernel.c
	$(CC) -m64 -fno-pie -ffreestanding -mcmodel=large -mno-red-zone -mno-mmx -mno-sse -mno-sse2 -c $< -o $@

kernel_entry.o: kernel_entry.asm
	$(ASM) $< -f elf64 -o $@

bootstrap.bin: bootstrap.asm
	$(ASM) $< -f bin -o $@

kernel.bin: kernel_entry.o kernel.o
	$(LD) -o $@ -Ttext 0x1000 $^ --oformat binary

os-image: bootstrap.bin kernel.bin
	cat $^ > $@

clean:
	rm *.bin *.o os-image
