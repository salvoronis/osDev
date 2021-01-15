#define VIDEO_MEM 0xb8000
#define SCREEN_SIZE 80*25*2

void clear(void);
void print(char*);

char* video_memory = (char*) VIDEO_MEM;

void kernel() {
	clear();
	print("niggers");
	while(1) __asm__("hlt\n\t");
}

void clear(void){
	unsigned int i = 0;
	while(i < SCREEN_SIZE){
		*(video_memory + (i++)) = ' ';
		*(video_memory + (i++)) = 0x0f;
	}
}

void print(char *str){
	unsigned int i = 0;
	while(*(str + i/2) != '\0'){
		*(video_memory + (i++)) = *(str + i/2);
		*(video_memory + (i++)) = 0x0f;
	}
}
