
_memtest2:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
	exit();
}

int
main(int argc, char *argv[])
{
   0:	f3 0f 1e fb          	endbr32 
   4:	55                   	push   %ebp
   5:	89 e5                	mov    %esp,%ebp
   7:	83 e4 f0             	and    $0xfffffff0,%esp
	// printf(1, "Memtest starting\n");
	mem();
   a:	e8 01 00 00 00       	call   10 <mem>
   f:	90                   	nop

00000010 <mem>:
{
  10:	f3 0f 1e fb          	endbr32 
  14:	55                   	push   %ebp
  15:	89 e5                	mov    %esp,%ebp
  17:	57                   	push   %edi
  18:	56                   	push   %esi
  19:	53                   	push   %ebx
  1a:	bb c8 00 00 00       	mov    $0xc8,%ebx
  1f:	83 ec 0c             	sub    $0xc,%esp
  22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
		char *memory = (char*) malloc(size); //4kb;
  28:	83 ec 0c             	sub    $0xc,%esp
  2b:	68 00 10 00 00       	push   $0x1000
  30:	e8 eb 07 00 00       	call   820 <malloc>
	for(int j=0;j<200;++j){
  35:	83 c4 10             	add    $0x10,%esp
		memory[0] = (char) (65);
  38:	c6 00 41             	movb   $0x41,(%eax)
	for(int j=0;j<200;++j){
  3b:	83 eb 01             	sub    $0x1,%ebx
  3e:	75 e8                	jne    28 <mem+0x18>
	pid = fork();
  40:	e8 06 04 00 00       	call   44b <fork>
	if(pid > 0) {
  45:	85 c0                	test   %eax,%eax
  47:	0f 8f c2 00 00 00    	jg     10f <mem+0xff>
	else if(pid < 0){ 
  4d:	0f 85 a6 00 00 00    	jne    f9 <mem+0xe9>
		printf(1,"Entered else\n");
  53:	53                   	push   %ebx
		sleep(100);
  54:	be 34 01 00 00       	mov    $0x134,%esi
				memory[k] = (char)(65+(k%26));
  59:	bf 4f ec c4 4e       	mov    $0x4ec4ec4f,%edi
		printf(1,"Entered else\n");
  5e:	53                   	push   %ebx
  5f:	68 53 09 00 00       	push   $0x953
  64:	6a 01                	push   $0x1
  66:	e8 55 05 00 00       	call   5c0 <printf>
		sleep(100);
  6b:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
  72:	e8 6c 04 00 00       	call   4e3 <sleep>
  77:	83 c4 10             	add    $0x10,%esp
			char *memory = (char*) malloc(size); //4kb;
  7a:	83 ec 0c             	sub    $0xc,%esp
  7d:	68 00 10 00 00       	push   $0x1000
  82:	e8 99 07 00 00       	call   820 <malloc>
			if (memory == 0) goto failed;
  87:	83 c4 10             	add    $0x10,%esp
			char *memory = (char*) malloc(size); //4kb;
  8a:	89 c3                	mov    %eax,%ebx
			if (memory == 0) goto failed;
  8c:	85 c0                	test   %eax,%eax
  8e:	74 55                	je     e5 <mem+0xd5>
			for(int k=0;k<size;++k){
  90:	31 c9                	xor    %ecx,%ecx
  92:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
				memory[k] = (char)(65+(k%26));
  98:	89 c8                	mov    %ecx,%eax
  9a:	f7 e7                	mul    %edi
  9c:	89 c8                	mov    %ecx,%eax
  9e:	c1 ea 03             	shr    $0x3,%edx
  a1:	6b d2 1a             	imul   $0x1a,%edx,%edx
  a4:	29 d0                	sub    %edx,%eax
  a6:	83 c0 41             	add    $0x41,%eax
  a9:	88 04 0b             	mov    %al,(%ebx,%ecx,1)
			for(int k=0;k<size;++k){
  ac:	83 c1 01             	add    $0x1,%ecx
  af:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
  b5:	75 e1                	jne    98 <mem+0x88>
			for(int k=0;k<size;++k){
  b7:	31 c9                	xor    %ecx,%ecx
  b9:	eb 14                	jmp    cf <mem+0xbf>
  bb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  bf:	90                   	nop
  c0:	83 c1 01             	add    $0x1,%ecx
  c3:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
  c9:	0f 84 ec 00 00 00    	je     1bb <mem+0x1ab>
				if(memory[k] != (char)(65+(k%26))) goto failed;
  cf:	89 c8                	mov    %ecx,%eax
  d1:	f7 e7                	mul    %edi
  d3:	89 c8                	mov    %ecx,%eax
  d5:	c1 ea 03             	shr    $0x3,%edx
  d8:	6b d2 1a             	imul   $0x1a,%edx,%edx
  db:	29 d0                	sub    %edx,%eax
  dd:	83 c0 41             	add    $0x41,%eax
  e0:	38 04 0b             	cmp    %al,(%ebx,%ecx,1)
  e3:	74 db                	je     c0 <mem+0xb0>
	printf(1, "Memtest2 Failed!\n");
  e5:	83 ec 08             	sub    $0x8,%esp
  e8:	68 83 09 00 00       	push   $0x983
  ed:	6a 01                	push   $0x1
  ef:	e8 cc 04 00 00       	call   5c0 <printf>
	exit();
  f4:	e8 5a 03 00 00       	call   453 <exit>
		printf(1, "Fork Failed\n");
  f9:	56                   	push   %esi
  fa:	56                   	push   %esi
  fb:	68 46 09 00 00       	push   $0x946
 100:	6a 01                	push   $0x1
 102:	e8 b9 04 00 00       	call   5c0 <printf>
 107:	83 c4 10             	add    $0x10,%esp
	exit();
 10a:	e8 44 03 00 00       	call   453 <exit>
		printf(1,"Entered if\n");
 10f:	50                   	push   %eax
 110:	be 64 00 00 00       	mov    $0x64,%esi
				memory[k] = (char)(65+(k%26));
 115:	bf 4f ec c4 4e       	mov    $0x4ec4ec4f,%edi
		printf(1,"Entered if\n");
 11a:	50                   	push   %eax
 11b:	68 28 09 00 00       	push   $0x928
 120:	6a 01                	push   $0x1
 122:	e8 99 04 00 00       	call   5c0 <printf>
 127:	83 c4 10             	add    $0x10,%esp
			char *memory = (char*) malloc(size); //4kb;
 12a:	83 ec 0c             	sub    $0xc,%esp
 12d:	68 00 10 00 00       	push   $0x1000
 132:	e8 e9 06 00 00       	call   820 <malloc>
			if (memory == 0) goto failed;
 137:	83 c4 10             	add    $0x10,%esp
			char *memory = (char*) malloc(size); //4kb;
 13a:	89 c3                	mov    %eax,%ebx
			if (memory == 0) goto failed;
 13c:	85 c0                	test   %eax,%eax
 13e:	74 a5                	je     e5 <mem+0xd5>
			for(int k=0;k<size;++k){
 140:	31 c9                	xor    %ecx,%ecx
 142:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
				memory[k] = (char)(65+(k%26));
 148:	89 c8                	mov    %ecx,%eax
 14a:	f7 e7                	mul    %edi
 14c:	89 c8                	mov    %ecx,%eax
 14e:	c1 ea 03             	shr    $0x3,%edx
 151:	6b d2 1a             	imul   $0x1a,%edx,%edx
 154:	29 d0                	sub    %edx,%eax
 156:	83 c0 41             	add    $0x41,%eax
 159:	88 04 0b             	mov    %al,(%ebx,%ecx,1)
			for(int k=0;k<size;++k){
 15c:	83 c1 01             	add    $0x1,%ecx
 15f:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
 165:	75 e1                	jne    148 <mem+0x138>
			for(int k=0;k<size;++k){
 167:	31 c9                	xor    %ecx,%ecx
 169:	eb 10                	jmp    17b <mem+0x16b>
 16b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 16f:	90                   	nop
 170:	83 c1 01             	add    $0x1,%ecx
 173:	81 f9 00 10 00 00    	cmp    $0x1000,%ecx
 179:	74 1b                	je     196 <mem+0x186>
				if(memory[k] != (char)(65+(k%26))) goto failed;
 17b:	89 c8                	mov    %ecx,%eax
 17d:	f7 e7                	mul    %edi
 17f:	89 c8                	mov    %ecx,%eax
 181:	c1 ea 03             	shr    $0x3,%edx
 184:	6b d2 1a             	imul   $0x1a,%edx,%edx
 187:	29 d0                	sub    %edx,%eax
 189:	83 c0 41             	add    $0x41,%eax
 18c:	38 04 0b             	cmp    %al,(%ebx,%ecx,1)
 18f:	74 df                	je     170 <mem+0x160>
 191:	e9 4f ff ff ff       	jmp    e5 <mem+0xd5>
		for(int j=0;j<100;++j){
 196:	83 ee 01             	sub    $0x1,%esi
 199:	75 8f                	jne    12a <mem+0x11a>
		printf(1,"Parent alloc-ed:\n");
 19b:	57                   	push   %edi
 19c:	57                   	push   %edi
 19d:	68 34 09 00 00       	push   $0x934
 1a2:	6a 01                	push   $0x1
 1a4:	e8 17 04 00 00       	call   5c0 <printf>
		getrss();
 1a9:	e8 45 03 00 00       	call   4f3 <getrss>
		wait();
 1ae:	e8 a8 02 00 00       	call   45b <wait>
 1b3:	83 c4 10             	add    $0x10,%esp
 1b6:	e9 4f ff ff ff       	jmp    10a <mem+0xfa>
		for(int j=0;j<308;++j){
 1bb:	83 ee 01             	sub    $0x1,%esi
 1be:	0f 85 b6 fe ff ff    	jne    7a <mem+0x6a>
		printf(1,"Child alloc-ed\n");
 1c4:	50                   	push   %eax
 1c5:	50                   	push   %eax
 1c6:	68 61 09 00 00       	push   $0x961
 1cb:	6a 01                	push   $0x1
 1cd:	e8 ee 03 00 00       	call   5c0 <printf>
		getrss();
 1d2:	e8 1c 03 00 00       	call   4f3 <getrss>
		printf(1, "Memtest2 Passed!\n");
 1d7:	5a                   	pop    %edx
 1d8:	59                   	pop    %ecx
 1d9:	68 71 09 00 00       	push   $0x971
 1de:	6a 01                	push   $0x1
 1e0:	e8 db 03 00 00       	call   5c0 <printf>
 1e5:	83 c4 10             	add    $0x10,%esp
 1e8:	e9 1d ff ff ff       	jmp    10a <mem+0xfa>
 1ed:	66 90                	xchg   %ax,%ax
 1ef:	90                   	nop

000001f0 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 1f0:	f3 0f 1e fb          	endbr32 
 1f4:	55                   	push   %ebp
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1f5:	31 c0                	xor    %eax,%eax
{
 1f7:	89 e5                	mov    %esp,%ebp
 1f9:	53                   	push   %ebx
 1fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
 1fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  while((*s++ = *t++) != 0)
 200:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
 204:	88 14 01             	mov    %dl,(%ecx,%eax,1)
 207:	83 c0 01             	add    $0x1,%eax
 20a:	84 d2                	test   %dl,%dl
 20c:	75 f2                	jne    200 <strcpy+0x10>
    ;
  return os;
}
 20e:	89 c8                	mov    %ecx,%eax
 210:	5b                   	pop    %ebx
 211:	5d                   	pop    %ebp
 212:	c3                   	ret    
 213:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 21a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00000220 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 220:	f3 0f 1e fb          	endbr32 
 224:	55                   	push   %ebp
 225:	89 e5                	mov    %esp,%ebp
 227:	53                   	push   %ebx
 228:	8b 4d 08             	mov    0x8(%ebp),%ecx
 22b:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 22e:	0f b6 01             	movzbl (%ecx),%eax
 231:	0f b6 1a             	movzbl (%edx),%ebx
 234:	84 c0                	test   %al,%al
 236:	75 19                	jne    251 <strcmp+0x31>
 238:	eb 26                	jmp    260 <strcmp+0x40>
 23a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 240:	0f b6 41 01          	movzbl 0x1(%ecx),%eax
    p++, q++;
 244:	83 c1 01             	add    $0x1,%ecx
 247:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 24a:	0f b6 1a             	movzbl (%edx),%ebx
 24d:	84 c0                	test   %al,%al
 24f:	74 0f                	je     260 <strcmp+0x40>
 251:	38 d8                	cmp    %bl,%al
 253:	74 eb                	je     240 <strcmp+0x20>
  return (uchar)*p - (uchar)*q;
 255:	29 d8                	sub    %ebx,%eax
}
 257:	5b                   	pop    %ebx
 258:	5d                   	pop    %ebp
 259:	c3                   	ret    
 25a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
 260:	31 c0                	xor    %eax,%eax
  return (uchar)*p - (uchar)*q;
 262:	29 d8                	sub    %ebx,%eax
}
 264:	5b                   	pop    %ebx
 265:	5d                   	pop    %ebp
 266:	c3                   	ret    
 267:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 26e:	66 90                	xchg   %ax,%ax

00000270 <strlen>:

uint
strlen(const char *s)
{
 270:	f3 0f 1e fb          	endbr32 
 274:	55                   	push   %ebp
 275:	89 e5                	mov    %esp,%ebp
 277:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
 27a:	80 3a 00             	cmpb   $0x0,(%edx)
 27d:	74 21                	je     2a0 <strlen+0x30>
 27f:	31 c0                	xor    %eax,%eax
 281:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 288:	83 c0 01             	add    $0x1,%eax
 28b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
 28f:	89 c1                	mov    %eax,%ecx
 291:	75 f5                	jne    288 <strlen+0x18>
    ;
  return n;
}
 293:	89 c8                	mov    %ecx,%eax
 295:	5d                   	pop    %ebp
 296:	c3                   	ret    
 297:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 29e:	66 90                	xchg   %ax,%ax
  for(n = 0; s[n]; n++)
 2a0:	31 c9                	xor    %ecx,%ecx
}
 2a2:	5d                   	pop    %ebp
 2a3:	89 c8                	mov    %ecx,%eax
 2a5:	c3                   	ret    
 2a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 2ad:	8d 76 00             	lea    0x0(%esi),%esi

000002b0 <memset>:

void*
memset(void *dst, int c, uint n)
{
 2b0:	f3 0f 1e fb          	endbr32 
 2b4:	55                   	push   %ebp
 2b5:	89 e5                	mov    %esp,%ebp
 2b7:	57                   	push   %edi
 2b8:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 2bb:	8b 4d 10             	mov    0x10(%ebp),%ecx
 2be:	8b 45 0c             	mov    0xc(%ebp),%eax
 2c1:	89 d7                	mov    %edx,%edi
 2c3:	fc                   	cld    
 2c4:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 2c6:	89 d0                	mov    %edx,%eax
 2c8:	5f                   	pop    %edi
 2c9:	5d                   	pop    %ebp
 2ca:	c3                   	ret    
 2cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 2cf:	90                   	nop

000002d0 <strchr>:

char*
strchr(const char *s, char c)
{
 2d0:	f3 0f 1e fb          	endbr32 
 2d4:	55                   	push   %ebp
 2d5:	89 e5                	mov    %esp,%ebp
 2d7:	8b 45 08             	mov    0x8(%ebp),%eax
 2da:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 2de:	0f b6 10             	movzbl (%eax),%edx
 2e1:	84 d2                	test   %dl,%dl
 2e3:	75 16                	jne    2fb <strchr+0x2b>
 2e5:	eb 21                	jmp    308 <strchr+0x38>
 2e7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 2ee:	66 90                	xchg   %ax,%ax
 2f0:	0f b6 50 01          	movzbl 0x1(%eax),%edx
 2f4:	83 c0 01             	add    $0x1,%eax
 2f7:	84 d2                	test   %dl,%dl
 2f9:	74 0d                	je     308 <strchr+0x38>
    if(*s == c)
 2fb:	38 d1                	cmp    %dl,%cl
 2fd:	75 f1                	jne    2f0 <strchr+0x20>
      return (char*)s;
  return 0;
}
 2ff:	5d                   	pop    %ebp
 300:	c3                   	ret    
 301:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  return 0;
 308:	31 c0                	xor    %eax,%eax
}
 30a:	5d                   	pop    %ebp
 30b:	c3                   	ret    
 30c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000310 <gets>:

char*
gets(char *buf, int max)
{
 310:	f3 0f 1e fb          	endbr32 
 314:	55                   	push   %ebp
 315:	89 e5                	mov    %esp,%ebp
 317:	57                   	push   %edi
 318:	56                   	push   %esi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 319:	31 f6                	xor    %esi,%esi
{
 31b:	53                   	push   %ebx
 31c:	89 f3                	mov    %esi,%ebx
 31e:	83 ec 1c             	sub    $0x1c,%esp
 321:	8b 7d 08             	mov    0x8(%ebp),%edi
  for(i=0; i+1 < max; ){
 324:	eb 33                	jmp    359 <gets+0x49>
 326:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 32d:	8d 76 00             	lea    0x0(%esi),%esi
    cc = read(0, &c, 1);
 330:	83 ec 04             	sub    $0x4,%esp
 333:	8d 45 e7             	lea    -0x19(%ebp),%eax
 336:	6a 01                	push   $0x1
 338:	50                   	push   %eax
 339:	6a 00                	push   $0x0
 33b:	e8 2b 01 00 00       	call   46b <read>
    if(cc < 1)
 340:	83 c4 10             	add    $0x10,%esp
 343:	85 c0                	test   %eax,%eax
 345:	7e 1c                	jle    363 <gets+0x53>
      break;
    buf[i++] = c;
 347:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 34b:	83 c7 01             	add    $0x1,%edi
 34e:	88 47 ff             	mov    %al,-0x1(%edi)
    if(c == '\n' || c == '\r')
 351:	3c 0a                	cmp    $0xa,%al
 353:	74 23                	je     378 <gets+0x68>
 355:	3c 0d                	cmp    $0xd,%al
 357:	74 1f                	je     378 <gets+0x68>
  for(i=0; i+1 < max; ){
 359:	83 c3 01             	add    $0x1,%ebx
 35c:	89 fe                	mov    %edi,%esi
 35e:	3b 5d 0c             	cmp    0xc(%ebp),%ebx
 361:	7c cd                	jl     330 <gets+0x20>
 363:	89 f3                	mov    %esi,%ebx
      break;
  }
  buf[i] = '\0';
  return buf;
}
 365:	8b 45 08             	mov    0x8(%ebp),%eax
  buf[i] = '\0';
 368:	c6 03 00             	movb   $0x0,(%ebx)
}
 36b:	8d 65 f4             	lea    -0xc(%ebp),%esp
 36e:	5b                   	pop    %ebx
 36f:	5e                   	pop    %esi
 370:	5f                   	pop    %edi
 371:	5d                   	pop    %ebp
 372:	c3                   	ret    
 373:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 377:	90                   	nop
 378:	8b 75 08             	mov    0x8(%ebp),%esi
 37b:	8b 45 08             	mov    0x8(%ebp),%eax
 37e:	01 de                	add    %ebx,%esi
 380:	89 f3                	mov    %esi,%ebx
  buf[i] = '\0';
 382:	c6 03 00             	movb   $0x0,(%ebx)
}
 385:	8d 65 f4             	lea    -0xc(%ebp),%esp
 388:	5b                   	pop    %ebx
 389:	5e                   	pop    %esi
 38a:	5f                   	pop    %edi
 38b:	5d                   	pop    %ebp
 38c:	c3                   	ret    
 38d:	8d 76 00             	lea    0x0(%esi),%esi

00000390 <stat>:

int
stat(const char *n, struct stat *st)
{
 390:	f3 0f 1e fb          	endbr32 
 394:	55                   	push   %ebp
 395:	89 e5                	mov    %esp,%ebp
 397:	56                   	push   %esi
 398:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 399:	83 ec 08             	sub    $0x8,%esp
 39c:	6a 00                	push   $0x0
 39e:	ff 75 08             	pushl  0x8(%ebp)
 3a1:	e8 ed 00 00 00       	call   493 <open>
  if(fd < 0)
 3a6:	83 c4 10             	add    $0x10,%esp
 3a9:	85 c0                	test   %eax,%eax
 3ab:	78 2b                	js     3d8 <stat+0x48>
    return -1;
  r = fstat(fd, st);
 3ad:	83 ec 08             	sub    $0x8,%esp
 3b0:	ff 75 0c             	pushl  0xc(%ebp)
 3b3:	89 c3                	mov    %eax,%ebx
 3b5:	50                   	push   %eax
 3b6:	e8 f0 00 00 00       	call   4ab <fstat>
  close(fd);
 3bb:	89 1c 24             	mov    %ebx,(%esp)
  r = fstat(fd, st);
 3be:	89 c6                	mov    %eax,%esi
  close(fd);
 3c0:	e8 b6 00 00 00       	call   47b <close>
  return r;
 3c5:	83 c4 10             	add    $0x10,%esp
}
 3c8:	8d 65 f8             	lea    -0x8(%ebp),%esp
 3cb:	89 f0                	mov    %esi,%eax
 3cd:	5b                   	pop    %ebx
 3ce:	5e                   	pop    %esi
 3cf:	5d                   	pop    %ebp
 3d0:	c3                   	ret    
 3d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
 3d8:	be ff ff ff ff       	mov    $0xffffffff,%esi
 3dd:	eb e9                	jmp    3c8 <stat+0x38>
 3df:	90                   	nop

000003e0 <atoi>:

int
atoi(const char *s)
{
 3e0:	f3 0f 1e fb          	endbr32 
 3e4:	55                   	push   %ebp
 3e5:	89 e5                	mov    %esp,%ebp
 3e7:	53                   	push   %ebx
 3e8:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 3eb:	0f be 02             	movsbl (%edx),%eax
 3ee:	8d 48 d0             	lea    -0x30(%eax),%ecx
 3f1:	80 f9 09             	cmp    $0x9,%cl
  n = 0;
 3f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  while('0' <= *s && *s <= '9')
 3f9:	77 1a                	ja     415 <atoi+0x35>
 3fb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 3ff:	90                   	nop
    n = n*10 + *s++ - '0';
 400:	83 c2 01             	add    $0x1,%edx
 403:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
 406:	8d 4c 48 d0          	lea    -0x30(%eax,%ecx,2),%ecx
  while('0' <= *s && *s <= '9')
 40a:	0f be 02             	movsbl (%edx),%eax
 40d:	8d 58 d0             	lea    -0x30(%eax),%ebx
 410:	80 fb 09             	cmp    $0x9,%bl
 413:	76 eb                	jbe    400 <atoi+0x20>
  return n;
}
 415:	89 c8                	mov    %ecx,%eax
 417:	5b                   	pop    %ebx
 418:	5d                   	pop    %ebp
 419:	c3                   	ret    
 41a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

00000420 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 420:	f3 0f 1e fb          	endbr32 
 424:	55                   	push   %ebp
 425:	89 e5                	mov    %esp,%ebp
 427:	57                   	push   %edi
 428:	8b 45 10             	mov    0x10(%ebp),%eax
 42b:	8b 55 08             	mov    0x8(%ebp),%edx
 42e:	56                   	push   %esi
 42f:	8b 75 0c             	mov    0xc(%ebp),%esi
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 432:	85 c0                	test   %eax,%eax
 434:	7e 0f                	jle    445 <memmove+0x25>
 436:	01 d0                	add    %edx,%eax
  dst = vdst;
 438:	89 d7                	mov    %edx,%edi
 43a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    *dst++ = *src++;
 440:	a4                   	movsb  %ds:(%esi),%es:(%edi)
  while(n-- > 0)
 441:	39 f8                	cmp    %edi,%eax
 443:	75 fb                	jne    440 <memmove+0x20>
  return vdst;
}
 445:	5e                   	pop    %esi
 446:	89 d0                	mov    %edx,%eax
 448:	5f                   	pop    %edi
 449:	5d                   	pop    %ebp
 44a:	c3                   	ret    

0000044b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 44b:	b8 01 00 00 00       	mov    $0x1,%eax
 450:	cd 40                	int    $0x40
 452:	c3                   	ret    

00000453 <exit>:
SYSCALL(exit)
 453:	b8 02 00 00 00       	mov    $0x2,%eax
 458:	cd 40                	int    $0x40
 45a:	c3                   	ret    

0000045b <wait>:
SYSCALL(wait)
 45b:	b8 03 00 00 00       	mov    $0x3,%eax
 460:	cd 40                	int    $0x40
 462:	c3                   	ret    

00000463 <pipe>:
SYSCALL(pipe)
 463:	b8 04 00 00 00       	mov    $0x4,%eax
 468:	cd 40                	int    $0x40
 46a:	c3                   	ret    

0000046b <read>:
SYSCALL(read)
 46b:	b8 05 00 00 00       	mov    $0x5,%eax
 470:	cd 40                	int    $0x40
 472:	c3                   	ret    

00000473 <write>:
SYSCALL(write)
 473:	b8 10 00 00 00       	mov    $0x10,%eax
 478:	cd 40                	int    $0x40
 47a:	c3                   	ret    

0000047b <close>:
SYSCALL(close)
 47b:	b8 15 00 00 00       	mov    $0x15,%eax
 480:	cd 40                	int    $0x40
 482:	c3                   	ret    

00000483 <kill>:
SYSCALL(kill)
 483:	b8 06 00 00 00       	mov    $0x6,%eax
 488:	cd 40                	int    $0x40
 48a:	c3                   	ret    

0000048b <exec>:
SYSCALL(exec)
 48b:	b8 07 00 00 00       	mov    $0x7,%eax
 490:	cd 40                	int    $0x40
 492:	c3                   	ret    

00000493 <open>:
SYSCALL(open)
 493:	b8 0f 00 00 00       	mov    $0xf,%eax
 498:	cd 40                	int    $0x40
 49a:	c3                   	ret    

0000049b <mknod>:
SYSCALL(mknod)
 49b:	b8 11 00 00 00       	mov    $0x11,%eax
 4a0:	cd 40                	int    $0x40
 4a2:	c3                   	ret    

000004a3 <unlink>:
SYSCALL(unlink)
 4a3:	b8 12 00 00 00       	mov    $0x12,%eax
 4a8:	cd 40                	int    $0x40
 4aa:	c3                   	ret    

000004ab <fstat>:
SYSCALL(fstat)
 4ab:	b8 08 00 00 00       	mov    $0x8,%eax
 4b0:	cd 40                	int    $0x40
 4b2:	c3                   	ret    

000004b3 <link>:
SYSCALL(link)
 4b3:	b8 13 00 00 00       	mov    $0x13,%eax
 4b8:	cd 40                	int    $0x40
 4ba:	c3                   	ret    

000004bb <mkdir>:
SYSCALL(mkdir)
 4bb:	b8 14 00 00 00       	mov    $0x14,%eax
 4c0:	cd 40                	int    $0x40
 4c2:	c3                   	ret    

000004c3 <chdir>:
SYSCALL(chdir)
 4c3:	b8 09 00 00 00       	mov    $0x9,%eax
 4c8:	cd 40                	int    $0x40
 4ca:	c3                   	ret    

000004cb <dup>:
SYSCALL(dup)
 4cb:	b8 0a 00 00 00       	mov    $0xa,%eax
 4d0:	cd 40                	int    $0x40
 4d2:	c3                   	ret    

000004d3 <getpid>:
SYSCALL(getpid)
 4d3:	b8 0b 00 00 00       	mov    $0xb,%eax
 4d8:	cd 40                	int    $0x40
 4da:	c3                   	ret    

000004db <sbrk>:
SYSCALL(sbrk)
 4db:	b8 0c 00 00 00       	mov    $0xc,%eax
 4e0:	cd 40                	int    $0x40
 4e2:	c3                   	ret    

000004e3 <sleep>:
SYSCALL(sleep)
 4e3:	b8 0d 00 00 00       	mov    $0xd,%eax
 4e8:	cd 40                	int    $0x40
 4ea:	c3                   	ret    

000004eb <uptime>:
SYSCALL(uptime)
 4eb:	b8 0e 00 00 00       	mov    $0xe,%eax
 4f0:	cd 40                	int    $0x40
 4f2:	c3                   	ret    

000004f3 <getrss>:
SYSCALL(getrss)
 4f3:	b8 16 00 00 00       	mov    $0x16,%eax
 4f8:	cd 40                	int    $0x40
 4fa:	c3                   	ret    

000004fb <getNumFreePages>:
 4fb:	b8 17 00 00 00       	mov    $0x17,%eax
 500:	cd 40                	int    $0x40
 502:	c3                   	ret    
 503:	66 90                	xchg   %ax,%ax
 505:	66 90                	xchg   %ax,%ax
 507:	66 90                	xchg   %ax,%ax
 509:	66 90                	xchg   %ax,%ax
 50b:	66 90                	xchg   %ax,%ax
 50d:	66 90                	xchg   %ax,%ax
 50f:	90                   	nop

00000510 <printint>:
  write(fd, &c, 1);
}

static void
printint(int fd, int xx, int base, int sgn)
{
 510:	55                   	push   %ebp
 511:	89 e5                	mov    %esp,%ebp
 513:	57                   	push   %edi
 514:	56                   	push   %esi
 515:	53                   	push   %ebx
 516:	83 ec 3c             	sub    $0x3c,%esp
 519:	89 4d c4             	mov    %ecx,-0x3c(%ebp)
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    neg = 1;
    x = -xx;
 51c:	89 d1                	mov    %edx,%ecx
{
 51e:	89 45 b8             	mov    %eax,-0x48(%ebp)
  if(sgn && xx < 0){
 521:	85 d2                	test   %edx,%edx
 523:	0f 89 7f 00 00 00    	jns    5a8 <printint+0x98>
 529:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
 52d:	74 79                	je     5a8 <printint+0x98>
    neg = 1;
 52f:	c7 45 bc 01 00 00 00 	movl   $0x1,-0x44(%ebp)
    x = -xx;
 536:	f7 d9                	neg    %ecx
  } else {
    x = xx;
  }

  i = 0;
 538:	31 db                	xor    %ebx,%ebx
 53a:	8d 75 d7             	lea    -0x29(%ebp),%esi
 53d:	8d 76 00             	lea    0x0(%esi),%esi
  do{
    buf[i++] = digits[x % base];
 540:	89 c8                	mov    %ecx,%eax
 542:	31 d2                	xor    %edx,%edx
 544:	89 cf                	mov    %ecx,%edi
 546:	f7 75 c4             	divl   -0x3c(%ebp)
 549:	0f b6 92 b4 09 00 00 	movzbl 0x9b4(%edx),%edx
 550:	89 45 c0             	mov    %eax,-0x40(%ebp)
 553:	89 d8                	mov    %ebx,%eax
 555:	8d 5b 01             	lea    0x1(%ebx),%ebx
  }while((x /= base) != 0);
 558:	8b 4d c0             	mov    -0x40(%ebp),%ecx
    buf[i++] = digits[x % base];
 55b:	88 14 1e             	mov    %dl,(%esi,%ebx,1)
  }while((x /= base) != 0);
 55e:	39 7d c4             	cmp    %edi,-0x3c(%ebp)
 561:	76 dd                	jbe    540 <printint+0x30>
  if(neg)
 563:	8b 4d bc             	mov    -0x44(%ebp),%ecx
 566:	85 c9                	test   %ecx,%ecx
 568:	74 0c                	je     576 <printint+0x66>
    buf[i++] = '-';
 56a:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
    buf[i++] = digits[x % base];
 56f:	89 d8                	mov    %ebx,%eax
    buf[i++] = '-';
 571:	ba 2d 00 00 00       	mov    $0x2d,%edx

  while(--i >= 0)
 576:	8b 7d b8             	mov    -0x48(%ebp),%edi
 579:	8d 5c 05 d7          	lea    -0x29(%ebp,%eax,1),%ebx
 57d:	eb 07                	jmp    586 <printint+0x76>
 57f:	90                   	nop
 580:	0f b6 13             	movzbl (%ebx),%edx
 583:	83 eb 01             	sub    $0x1,%ebx
  write(fd, &c, 1);
 586:	83 ec 04             	sub    $0x4,%esp
 589:	88 55 d7             	mov    %dl,-0x29(%ebp)
 58c:	6a 01                	push   $0x1
 58e:	56                   	push   %esi
 58f:	57                   	push   %edi
 590:	e8 de fe ff ff       	call   473 <write>
  while(--i >= 0)
 595:	83 c4 10             	add    $0x10,%esp
 598:	39 de                	cmp    %ebx,%esi
 59a:	75 e4                	jne    580 <printint+0x70>
    putc(fd, buf[i]);
}
 59c:	8d 65 f4             	lea    -0xc(%ebp),%esp
 59f:	5b                   	pop    %ebx
 5a0:	5e                   	pop    %esi
 5a1:	5f                   	pop    %edi
 5a2:	5d                   	pop    %ebp
 5a3:	c3                   	ret    
 5a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  neg = 0;
 5a8:	c7 45 bc 00 00 00 00 	movl   $0x0,-0x44(%ebp)
 5af:	eb 87                	jmp    538 <printint+0x28>
 5b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 5b8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 5bf:	90                   	nop

000005c0 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 5c0:	f3 0f 1e fb          	endbr32 
 5c4:	55                   	push   %ebp
 5c5:	89 e5                	mov    %esp,%ebp
 5c7:	57                   	push   %edi
 5c8:	56                   	push   %esi
 5c9:	53                   	push   %ebx
 5ca:	83 ec 2c             	sub    $0x2c,%esp
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5cd:	8b 75 0c             	mov    0xc(%ebp),%esi
 5d0:	0f b6 1e             	movzbl (%esi),%ebx
 5d3:	84 db                	test   %bl,%bl
 5d5:	0f 84 b4 00 00 00    	je     68f <printf+0xcf>
  ap = (uint*)(void*)&fmt + 1;
 5db:	8d 45 10             	lea    0x10(%ebp),%eax
 5de:	83 c6 01             	add    $0x1,%esi
  write(fd, &c, 1);
 5e1:	8d 7d e7             	lea    -0x19(%ebp),%edi
  state = 0;
 5e4:	31 d2                	xor    %edx,%edx
  ap = (uint*)(void*)&fmt + 1;
 5e6:	89 45 d0             	mov    %eax,-0x30(%ebp)
 5e9:	eb 33                	jmp    61e <printf+0x5e>
 5eb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 5ef:	90                   	nop
 5f0:	89 55 d4             	mov    %edx,-0x2c(%ebp)
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
 5f3:	ba 25 00 00 00       	mov    $0x25,%edx
      if(c == '%'){
 5f8:	83 f8 25             	cmp    $0x25,%eax
 5fb:	74 17                	je     614 <printf+0x54>
  write(fd, &c, 1);
 5fd:	83 ec 04             	sub    $0x4,%esp
 600:	88 5d e7             	mov    %bl,-0x19(%ebp)
 603:	6a 01                	push   $0x1
 605:	57                   	push   %edi
 606:	ff 75 08             	pushl  0x8(%ebp)
 609:	e8 65 fe ff ff       	call   473 <write>
 60e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
      } else {
        putc(fd, c);
 611:	83 c4 10             	add    $0x10,%esp
  for(i = 0; fmt[i]; i++){
 614:	0f b6 1e             	movzbl (%esi),%ebx
 617:	83 c6 01             	add    $0x1,%esi
 61a:	84 db                	test   %bl,%bl
 61c:	74 71                	je     68f <printf+0xcf>
    c = fmt[i] & 0xff;
 61e:	0f be cb             	movsbl %bl,%ecx
 621:	0f b6 c3             	movzbl %bl,%eax
    if(state == 0){
 624:	85 d2                	test   %edx,%edx
 626:	74 c8                	je     5f0 <printf+0x30>
      }
    } else if(state == '%'){
 628:	83 fa 25             	cmp    $0x25,%edx
 62b:	75 e7                	jne    614 <printf+0x54>
      if(c == 'd'){
 62d:	83 f8 64             	cmp    $0x64,%eax
 630:	0f 84 9a 00 00 00    	je     6d0 <printf+0x110>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 636:	81 e1 f7 00 00 00    	and    $0xf7,%ecx
 63c:	83 f9 70             	cmp    $0x70,%ecx
 63f:	74 5f                	je     6a0 <printf+0xe0>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 641:	83 f8 73             	cmp    $0x73,%eax
 644:	0f 84 d6 00 00 00    	je     720 <printf+0x160>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 64a:	83 f8 63             	cmp    $0x63,%eax
 64d:	0f 84 8d 00 00 00    	je     6e0 <printf+0x120>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 653:	83 f8 25             	cmp    $0x25,%eax
 656:	0f 84 b4 00 00 00    	je     710 <printf+0x150>
  write(fd, &c, 1);
 65c:	83 ec 04             	sub    $0x4,%esp
 65f:	c6 45 e7 25          	movb   $0x25,-0x19(%ebp)
 663:	6a 01                	push   $0x1
 665:	57                   	push   %edi
 666:	ff 75 08             	pushl  0x8(%ebp)
 669:	e8 05 fe ff ff       	call   473 <write>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
 66e:	88 5d e7             	mov    %bl,-0x19(%ebp)
  write(fd, &c, 1);
 671:	83 c4 0c             	add    $0xc,%esp
 674:	6a 01                	push   $0x1
 676:	83 c6 01             	add    $0x1,%esi
 679:	57                   	push   %edi
 67a:	ff 75 08             	pushl  0x8(%ebp)
 67d:	e8 f1 fd ff ff       	call   473 <write>
  for(i = 0; fmt[i]; i++){
 682:	0f b6 5e ff          	movzbl -0x1(%esi),%ebx
        putc(fd, c);
 686:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 689:	31 d2                	xor    %edx,%edx
  for(i = 0; fmt[i]; i++){
 68b:	84 db                	test   %bl,%bl
 68d:	75 8f                	jne    61e <printf+0x5e>
    }
  }
}
 68f:	8d 65 f4             	lea    -0xc(%ebp),%esp
 692:	5b                   	pop    %ebx
 693:	5e                   	pop    %esi
 694:	5f                   	pop    %edi
 695:	5d                   	pop    %ebp
 696:	c3                   	ret    
 697:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 69e:	66 90                	xchg   %ax,%ax
        printint(fd, *ap, 16, 0);
 6a0:	83 ec 0c             	sub    $0xc,%esp
 6a3:	b9 10 00 00 00       	mov    $0x10,%ecx
 6a8:	6a 00                	push   $0x0
 6aa:	8b 5d d0             	mov    -0x30(%ebp),%ebx
 6ad:	8b 45 08             	mov    0x8(%ebp),%eax
 6b0:	8b 13                	mov    (%ebx),%edx
 6b2:	e8 59 fe ff ff       	call   510 <printint>
        ap++;
 6b7:	89 d8                	mov    %ebx,%eax
 6b9:	83 c4 10             	add    $0x10,%esp
      state = 0;
 6bc:	31 d2                	xor    %edx,%edx
        ap++;
 6be:	83 c0 04             	add    $0x4,%eax
 6c1:	89 45 d0             	mov    %eax,-0x30(%ebp)
 6c4:	e9 4b ff ff ff       	jmp    614 <printf+0x54>
 6c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        printint(fd, *ap, 10, 1);
 6d0:	83 ec 0c             	sub    $0xc,%esp
 6d3:	b9 0a 00 00 00       	mov    $0xa,%ecx
 6d8:	6a 01                	push   $0x1
 6da:	eb ce                	jmp    6aa <printf+0xea>
 6dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        putc(fd, *ap);
 6e0:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  write(fd, &c, 1);
 6e3:	83 ec 04             	sub    $0x4,%esp
        putc(fd, *ap);
 6e6:	8b 03                	mov    (%ebx),%eax
  write(fd, &c, 1);
 6e8:	6a 01                	push   $0x1
        ap++;
 6ea:	83 c3 04             	add    $0x4,%ebx
  write(fd, &c, 1);
 6ed:	57                   	push   %edi
 6ee:	ff 75 08             	pushl  0x8(%ebp)
        putc(fd, *ap);
 6f1:	88 45 e7             	mov    %al,-0x19(%ebp)
  write(fd, &c, 1);
 6f4:	e8 7a fd ff ff       	call   473 <write>
        ap++;
 6f9:	89 5d d0             	mov    %ebx,-0x30(%ebp)
 6fc:	83 c4 10             	add    $0x10,%esp
      state = 0;
 6ff:	31 d2                	xor    %edx,%edx
 701:	e9 0e ff ff ff       	jmp    614 <printf+0x54>
 706:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 70d:	8d 76 00             	lea    0x0(%esi),%esi
        putc(fd, c);
 710:	88 5d e7             	mov    %bl,-0x19(%ebp)
  write(fd, &c, 1);
 713:	83 ec 04             	sub    $0x4,%esp
 716:	e9 59 ff ff ff       	jmp    674 <printf+0xb4>
 71b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 71f:	90                   	nop
        s = (char*)*ap;
 720:	8b 45 d0             	mov    -0x30(%ebp),%eax
 723:	8b 18                	mov    (%eax),%ebx
        ap++;
 725:	83 c0 04             	add    $0x4,%eax
 728:	89 45 d0             	mov    %eax,-0x30(%ebp)
        if(s == 0)
 72b:	85 db                	test   %ebx,%ebx
 72d:	74 17                	je     746 <printf+0x186>
        while(*s != 0){
 72f:	0f b6 03             	movzbl (%ebx),%eax
      state = 0;
 732:	31 d2                	xor    %edx,%edx
        while(*s != 0){
 734:	84 c0                	test   %al,%al
 736:	0f 84 d8 fe ff ff    	je     614 <printf+0x54>
 73c:	89 75 d4             	mov    %esi,-0x2c(%ebp)
 73f:	89 de                	mov    %ebx,%esi
 741:	8b 5d 08             	mov    0x8(%ebp),%ebx
 744:	eb 1a                	jmp    760 <printf+0x1a0>
          s = "(null)";
 746:	bb ab 09 00 00       	mov    $0x9ab,%ebx
        while(*s != 0){
 74b:	89 75 d4             	mov    %esi,-0x2c(%ebp)
 74e:	b8 28 00 00 00       	mov    $0x28,%eax
 753:	89 de                	mov    %ebx,%esi
 755:	8b 5d 08             	mov    0x8(%ebp),%ebx
 758:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 75f:	90                   	nop
  write(fd, &c, 1);
 760:	83 ec 04             	sub    $0x4,%esp
          s++;
 763:	83 c6 01             	add    $0x1,%esi
 766:	88 45 e7             	mov    %al,-0x19(%ebp)
  write(fd, &c, 1);
 769:	6a 01                	push   $0x1
 76b:	57                   	push   %edi
 76c:	53                   	push   %ebx
 76d:	e8 01 fd ff ff       	call   473 <write>
        while(*s != 0){
 772:	0f b6 06             	movzbl (%esi),%eax
 775:	83 c4 10             	add    $0x10,%esp
 778:	84 c0                	test   %al,%al
 77a:	75 e4                	jne    760 <printf+0x1a0>
 77c:	8b 75 d4             	mov    -0x2c(%ebp),%esi
      state = 0;
 77f:	31 d2                	xor    %edx,%edx
 781:	e9 8e fe ff ff       	jmp    614 <printf+0x54>
 786:	66 90                	xchg   %ax,%ax
 788:	66 90                	xchg   %ax,%ax
 78a:	66 90                	xchg   %ax,%ax
 78c:	66 90                	xchg   %ax,%ax
 78e:	66 90                	xchg   %ax,%ax

00000790 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 790:	f3 0f 1e fb          	endbr32 
 794:	55                   	push   %ebp
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 795:	a1 a0 0c 00 00       	mov    0xca0,%eax
{
 79a:	89 e5                	mov    %esp,%ebp
 79c:	57                   	push   %edi
 79d:	56                   	push   %esi
 79e:	53                   	push   %ebx
 79f:	8b 5d 08             	mov    0x8(%ebp),%ebx
 7a2:	8b 10                	mov    (%eax),%edx
  bp = (Header*)ap - 1;
 7a4:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a7:	39 c8                	cmp    %ecx,%eax
 7a9:	73 15                	jae    7c0 <free+0x30>
 7ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 7af:	90                   	nop
 7b0:	39 d1                	cmp    %edx,%ecx
 7b2:	72 14                	jb     7c8 <free+0x38>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7b4:	39 d0                	cmp    %edx,%eax
 7b6:	73 10                	jae    7c8 <free+0x38>
{
 7b8:	89 d0                	mov    %edx,%eax
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7ba:	8b 10                	mov    (%eax),%edx
 7bc:	39 c8                	cmp    %ecx,%eax
 7be:	72 f0                	jb     7b0 <free+0x20>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7c0:	39 d0                	cmp    %edx,%eax
 7c2:	72 f4                	jb     7b8 <free+0x28>
 7c4:	39 d1                	cmp    %edx,%ecx
 7c6:	73 f0                	jae    7b8 <free+0x28>
      break;
  if(bp + bp->s.size == p->s.ptr){
 7c8:	8b 73 fc             	mov    -0x4(%ebx),%esi
 7cb:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 7ce:	39 fa                	cmp    %edi,%edx
 7d0:	74 1e                	je     7f0 <free+0x60>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 7d2:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 7d5:	8b 50 04             	mov    0x4(%eax),%edx
 7d8:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 7db:	39 f1                	cmp    %esi,%ecx
 7dd:	74 28                	je     807 <free+0x77>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 7df:	89 08                	mov    %ecx,(%eax)
  freep = p;
}
 7e1:	5b                   	pop    %ebx
  freep = p;
 7e2:	a3 a0 0c 00 00       	mov    %eax,0xca0
}
 7e7:	5e                   	pop    %esi
 7e8:	5f                   	pop    %edi
 7e9:	5d                   	pop    %ebp
 7ea:	c3                   	ret    
 7eb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
 7ef:	90                   	nop
    bp->s.size += p->s.ptr->s.size;
 7f0:	03 72 04             	add    0x4(%edx),%esi
 7f3:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f6:	8b 10                	mov    (%eax),%edx
 7f8:	8b 12                	mov    (%edx),%edx
 7fa:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 7fd:	8b 50 04             	mov    0x4(%eax),%edx
 800:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 803:	39 f1                	cmp    %esi,%ecx
 805:	75 d8                	jne    7df <free+0x4f>
    p->s.size += bp->s.size;
 807:	03 53 fc             	add    -0x4(%ebx),%edx
  freep = p;
 80a:	a3 a0 0c 00 00       	mov    %eax,0xca0
    p->s.size += bp->s.size;
 80f:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 812:	8b 53 f8             	mov    -0x8(%ebx),%edx
 815:	89 10                	mov    %edx,(%eax)
}
 817:	5b                   	pop    %ebx
 818:	5e                   	pop    %esi
 819:	5f                   	pop    %edi
 81a:	5d                   	pop    %ebp
 81b:	c3                   	ret    
 81c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

00000820 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 820:	f3 0f 1e fb          	endbr32 
 824:	55                   	push   %ebp
 825:	89 e5                	mov    %esp,%ebp
 827:	57                   	push   %edi
 828:	56                   	push   %esi
 829:	53                   	push   %ebx
 82a:	83 ec 1c             	sub    $0x1c,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 82d:	8b 45 08             	mov    0x8(%ebp),%eax
  if((prevp = freep) == 0){
 830:	8b 3d a0 0c 00 00    	mov    0xca0,%edi
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 836:	8d 70 07             	lea    0x7(%eax),%esi
 839:	c1 ee 03             	shr    $0x3,%esi
 83c:	83 c6 01             	add    $0x1,%esi
  if((prevp = freep) == 0){
 83f:	85 ff                	test   %edi,%edi
 841:	0f 84 a9 00 00 00    	je     8f0 <malloc+0xd0>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 847:	8b 07                	mov    (%edi),%eax
    if(p->s.size >= nunits){
 849:	8b 48 04             	mov    0x4(%eax),%ecx
 84c:	39 f1                	cmp    %esi,%ecx
 84e:	73 6d                	jae    8bd <malloc+0x9d>
 850:	81 fe 00 10 00 00    	cmp    $0x1000,%esi
 856:	bb 00 10 00 00       	mov    $0x1000,%ebx
 85b:	0f 43 de             	cmovae %esi,%ebx
  p = sbrk(nu * sizeof(Header));
 85e:	8d 0c dd 00 00 00 00 	lea    0x0(,%ebx,8),%ecx
 865:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
 868:	eb 17                	jmp    881 <malloc+0x61>
 86a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 870:	8b 10                	mov    (%eax),%edx
    if(p->s.size >= nunits){
 872:	8b 4a 04             	mov    0x4(%edx),%ecx
 875:	39 f1                	cmp    %esi,%ecx
 877:	73 4f                	jae    8c8 <malloc+0xa8>
 879:	8b 3d a0 0c 00 00    	mov    0xca0,%edi
 87f:	89 d0                	mov    %edx,%eax
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 881:	39 c7                	cmp    %eax,%edi
 883:	75 eb                	jne    870 <malloc+0x50>
  p = sbrk(nu * sizeof(Header));
 885:	83 ec 0c             	sub    $0xc,%esp
 888:	ff 75 e4             	pushl  -0x1c(%ebp)
 88b:	e8 4b fc ff ff       	call   4db <sbrk>
  if(p == (char*)-1)
 890:	83 c4 10             	add    $0x10,%esp
 893:	83 f8 ff             	cmp    $0xffffffff,%eax
 896:	74 1b                	je     8b3 <malloc+0x93>
  hp->s.size = nu;
 898:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 89b:	83 ec 0c             	sub    $0xc,%esp
 89e:	83 c0 08             	add    $0x8,%eax
 8a1:	50                   	push   %eax
 8a2:	e8 e9 fe ff ff       	call   790 <free>
  return freep;
 8a7:	a1 a0 0c 00 00       	mov    0xca0,%eax
      if((p = morecore(nunits)) == 0)
 8ac:	83 c4 10             	add    $0x10,%esp
 8af:	85 c0                	test   %eax,%eax
 8b1:	75 bd                	jne    870 <malloc+0x50>
        return 0;
  }
}
 8b3:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return 0;
 8b6:	31 c0                	xor    %eax,%eax
}
 8b8:	5b                   	pop    %ebx
 8b9:	5e                   	pop    %esi
 8ba:	5f                   	pop    %edi
 8bb:	5d                   	pop    %ebp
 8bc:	c3                   	ret    
    if(p->s.size >= nunits){
 8bd:	89 c2                	mov    %eax,%edx
 8bf:	89 f8                	mov    %edi,%eax
 8c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      if(p->s.size == nunits)
 8c8:	39 ce                	cmp    %ecx,%esi
 8ca:	74 54                	je     920 <malloc+0x100>
        p->s.size -= nunits;
 8cc:	29 f1                	sub    %esi,%ecx
 8ce:	89 4a 04             	mov    %ecx,0x4(%edx)
        p += p->s.size;
 8d1:	8d 14 ca             	lea    (%edx,%ecx,8),%edx
        p->s.size = nunits;
 8d4:	89 72 04             	mov    %esi,0x4(%edx)
      freep = prevp;
 8d7:	a3 a0 0c 00 00       	mov    %eax,0xca0
}
 8dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return (void*)(p + 1);
 8df:	8d 42 08             	lea    0x8(%edx),%eax
}
 8e2:	5b                   	pop    %ebx
 8e3:	5e                   	pop    %esi
 8e4:	5f                   	pop    %edi
 8e5:	5d                   	pop    %ebp
 8e6:	c3                   	ret    
 8e7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
 8ee:	66 90                	xchg   %ax,%ax
    base.s.ptr = freep = prevp = &base;
 8f0:	c7 05 a0 0c 00 00 a4 	movl   $0xca4,0xca0
 8f7:	0c 00 00 
    base.s.size = 0;
 8fa:	bf a4 0c 00 00       	mov    $0xca4,%edi
    base.s.ptr = freep = prevp = &base;
 8ff:	c7 05 a4 0c 00 00 a4 	movl   $0xca4,0xca4
 906:	0c 00 00 
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 909:	89 f8                	mov    %edi,%eax
    base.s.size = 0;
 90b:	c7 05 a8 0c 00 00 00 	movl   $0x0,0xca8
 912:	00 00 00 
    if(p->s.size >= nunits){
 915:	e9 36 ff ff ff       	jmp    850 <malloc+0x30>
 91a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        prevp->s.ptr = p->s.ptr;
 920:	8b 0a                	mov    (%edx),%ecx
 922:	89 08                	mov    %ecx,(%eax)
 924:	eb b1                	jmp    8d7 <malloc+0xb7>
