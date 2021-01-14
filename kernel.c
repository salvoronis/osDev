#define SCREEN_SIZE 25*80*2
#define VIDEO_MEM 0xB8000

void clear(void);
//void print(char*);
//unsigned int strlen(char*);
static char* video_memory = (char*) VIDEO_MEM;

void kernel() {
	//clear();
	char* video_memory = (char*) VIDEO_MEM;
	*video_memory = 'A';
	//print("anime");
	while(1){}
}

void clear(void){
	char* video_memory = (char*) VIDEO_MEM - 1;
	unsigned int i = 0;
	while(i <= SCREEN_SIZE){
		*(video_memory + (i++)) = ' ';
		*(video_memory + (i++)) = 0x0f;
	}
}

/*void print(char* str){
	char* video_memory = (char*) VIDEO_MEM;
	unsigned int i = 0;
	for(unsigned int i = 0; i <= 10; i += 2){
		*(video_memory + i + 1) = 0xf0;//*(str + (i));
		//*(video_memory + i) = 0xf2;
	}
}

unsigned int strlen(char* str){
	unsigned int i = 0;
	while (*(str + i) != '\0'){
		i++;
	}
	return i;
}*/
