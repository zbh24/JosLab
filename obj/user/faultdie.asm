
obj/user/faultdie：     文件格式 elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 61 00 00 00       	call   800092 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <umain>:
	sys_env_destroy(sys_getenvid());
}

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  800046:	c7 04 24 5e 00 80 00 	movl   $0x80005e,(%esp)
  80004d:	e8 80 0f 00 00       	call   800fd2 <set_pgfault_handler>
	*(int*)0xDeadBeef = 0;
  800052:	c7 05 ef be ad de 00 	movl   $0x0,0xdeadbeef
  800059:	00 00 00 
}
  80005c:	c9                   	leave  
  80005d:	c3                   	ret    

0080005e <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  80005e:	55                   	push   %ebp
  80005f:	89 e5                	mov    %esp,%ebp
  800061:	83 ec 18             	sub    $0x18,%esp
  800064:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void*)utf->utf_fault_va;
	uint32_t err = utf->utf_err;
	cprintf("i faulted at va %x, err %x\n", addr, err & 7);
  800067:	8b 50 04             	mov    0x4(%eax),%edx
  80006a:	83 e2 07             	and    $0x7,%edx
  80006d:	89 54 24 08          	mov    %edx,0x8(%esp)
  800071:	8b 00                	mov    (%eax),%eax
  800073:	89 44 24 04          	mov    %eax,0x4(%esp)
  800077:	c7 04 24 e0 12 80 00 	movl   $0x8012e0,(%esp)
  80007e:	e8 dd 00 00 00       	call   800160 <cprintf>
	sys_env_destroy(sys_getenvid());
  800083:	e8 b9 0e 00 00       	call   800f41 <sys_getenvid>
  800088:	89 04 24             	mov    %eax,(%esp)
  80008b:	e8 e5 0e 00 00       	call   800f75 <sys_env_destroy>
}
  800090:	c9                   	leave  
  800091:	c3                   	ret    

00800092 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800092:	55                   	push   %ebp
  800093:	89 e5                	mov    %esp,%ebp
  800095:	83 ec 18             	sub    $0x18,%esp
  800098:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80009b:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80009e:	8b 75 08             	mov    0x8(%ebp),%esi
  8000a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000a4:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000ab:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ae:	e8 8e 0e 00 00       	call   800f41 <sys_getenvid>
  8000b3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000b8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000bb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000c0:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000c5:	85 f6                	test   %esi,%esi
  8000c7:	7e 07                	jle    8000d0 <libmain+0x3e>
		binaryname = argv[0];
  8000c9:	8b 03                	mov    (%ebx),%eax
  8000cb:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000d0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000d4:	89 34 24             	mov    %esi,(%esp)
  8000d7:	e8 64 ff ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  8000dc:	e8 0a 00 00 00       	call   8000eb <exit>
}
  8000e1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000e4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000e7:	89 ec                	mov    %ebp,%esp
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000f1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000f8:	e8 78 0e 00 00       	call   800f75 <sys_env_destroy>
}
  8000fd:	c9                   	leave  
  8000fe:	c3                   	ret    

008000ff <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000ff:	55                   	push   %ebp
  800100:	89 e5                	mov    %esp,%ebp
  800102:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800108:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80010f:	00 00 00 
	b.cnt = 0;
  800112:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800119:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80011c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800123:	8b 45 08             	mov    0x8(%ebp),%eax
  800126:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800130:	89 44 24 04          	mov    %eax,0x4(%esp)
  800134:	c7 04 24 7a 01 80 00 	movl   $0x80017a,(%esp)
  80013b:	e8 cd 01 00 00       	call   80030d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800140:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800146:	89 44 24 04          	mov    %eax,0x4(%esp)
  80014a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800150:	89 04 24             	mov    %eax,(%esp)
  800153:	e8 16 0b 00 00       	call   800c6e <sys_cputs>

	return b.cnt;
}
  800158:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80015e:	c9                   	leave  
  80015f:	c3                   	ret    

00800160 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800160:	55                   	push   %ebp
  800161:	89 e5                	mov    %esp,%ebp
  800163:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800166:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800169:	89 44 24 04          	mov    %eax,0x4(%esp)
  80016d:	8b 45 08             	mov    0x8(%ebp),%eax
  800170:	89 04 24             	mov    %eax,(%esp)
  800173:	e8 87 ff ff ff       	call   8000ff <vcprintf>
	va_end(ap);

	return cnt;
}
  800178:	c9                   	leave  
  800179:	c3                   	ret    

0080017a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80017a:	55                   	push   %ebp
  80017b:	89 e5                	mov    %esp,%ebp
  80017d:	53                   	push   %ebx
  80017e:	83 ec 14             	sub    $0x14,%esp
  800181:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800184:	8b 03                	mov    (%ebx),%eax
  800186:	8b 55 08             	mov    0x8(%ebp),%edx
  800189:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80018d:	83 c0 01             	add    $0x1,%eax
  800190:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800192:	3d ff 00 00 00       	cmp    $0xff,%eax
  800197:	75 19                	jne    8001b2 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800199:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001a0:	00 
  8001a1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001a4:	89 04 24             	mov    %eax,(%esp)
  8001a7:	e8 c2 0a 00 00       	call   800c6e <sys_cputs>
		b->idx = 0;
  8001ac:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001b2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001b6:	83 c4 14             	add    $0x14,%esp
  8001b9:	5b                   	pop    %ebx
  8001ba:	5d                   	pop    %ebp
  8001bb:	c3                   	ret    
  8001bc:	66 90                	xchg   %ax,%ax
  8001be:	66 90                	xchg   %ax,%ax

008001c0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001c0:	55                   	push   %ebp
  8001c1:	89 e5                	mov    %esp,%ebp
  8001c3:	57                   	push   %edi
  8001c4:	56                   	push   %esi
  8001c5:	53                   	push   %ebx
  8001c6:	83 ec 4c             	sub    $0x4c,%esp
  8001c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001cc:	89 d6                	mov    %edx,%esi
  8001ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001da:	8b 45 10             	mov    0x10(%ebp),%eax
  8001dd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001e0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001e3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001e6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001eb:	39 d1                	cmp    %edx,%ecx
  8001ed:	72 15                	jb     800204 <printnum+0x44>
  8001ef:	77 07                	ja     8001f8 <printnum+0x38>
  8001f1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001f4:	39 d0                	cmp    %edx,%eax
  8001f6:	76 0c                	jbe    800204 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001f8:	83 eb 01             	sub    $0x1,%ebx
  8001fb:	85 db                	test   %ebx,%ebx
  8001fd:	8d 76 00             	lea    0x0(%esi),%esi
  800200:	7f 61                	jg     800263 <printnum+0xa3>
  800202:	eb 70                	jmp    800274 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800204:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800208:	83 eb 01             	sub    $0x1,%ebx
  80020b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80020f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800213:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800217:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80021b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80021e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800221:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800224:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800228:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022f:	00 
  800230:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800233:	89 04 24             	mov    %eax,(%esp)
  800236:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800239:	89 54 24 04          	mov    %edx,0x4(%esp)
  80023d:	e8 1e 0e 00 00       	call   801060 <__udivdi3>
  800242:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800245:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800248:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80024c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800250:	89 04 24             	mov    %eax,(%esp)
  800253:	89 54 24 04          	mov    %edx,0x4(%esp)
  800257:	89 f2                	mov    %esi,%edx
  800259:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80025c:	e8 5f ff ff ff       	call   8001c0 <printnum>
  800261:	eb 11                	jmp    800274 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800263:	89 74 24 04          	mov    %esi,0x4(%esp)
  800267:	89 3c 24             	mov    %edi,(%esp)
  80026a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80026d:	83 eb 01             	sub    $0x1,%ebx
  800270:	85 db                	test   %ebx,%ebx
  800272:	7f ef                	jg     800263 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800274:	89 74 24 04          	mov    %esi,0x4(%esp)
  800278:	8b 74 24 04          	mov    0x4(%esp),%esi
  80027c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80027f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800283:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80028a:	00 
  80028b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80028e:	89 14 24             	mov    %edx,(%esp)
  800291:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800294:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800298:	e8 f3 0e 00 00       	call   801190 <__umoddi3>
  80029d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a1:	0f be 80 06 13 80 00 	movsbl 0x801306(%eax),%eax
  8002a8:	89 04 24             	mov    %eax,(%esp)
  8002ab:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002ae:	83 c4 4c             	add    $0x4c,%esp
  8002b1:	5b                   	pop    %ebx
  8002b2:	5e                   	pop    %esi
  8002b3:	5f                   	pop    %edi
  8002b4:	5d                   	pop    %ebp
  8002b5:	c3                   	ret    

008002b6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002b6:	55                   	push   %ebp
  8002b7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002b9:	83 fa 01             	cmp    $0x1,%edx
  8002bc:	7e 0e                	jle    8002cc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002be:	8b 10                	mov    (%eax),%edx
  8002c0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002c3:	89 08                	mov    %ecx,(%eax)
  8002c5:	8b 02                	mov    (%edx),%eax
  8002c7:	8b 52 04             	mov    0x4(%edx),%edx
  8002ca:	eb 22                	jmp    8002ee <getuint+0x38>
	else if (lflag)
  8002cc:	85 d2                	test   %edx,%edx
  8002ce:	74 10                	je     8002e0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002d0:	8b 10                	mov    (%eax),%edx
  8002d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d5:	89 08                	mov    %ecx,(%eax)
  8002d7:	8b 02                	mov    (%edx),%eax
  8002d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002de:	eb 0e                	jmp    8002ee <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002fa:	8b 10                	mov    (%eax),%edx
  8002fc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002ff:	73 0a                	jae    80030b <sprintputch+0x1b>
		*b->buf++ = ch;
  800301:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800304:	88 0a                	mov    %cl,(%edx)
  800306:	83 c2 01             	add    $0x1,%edx
  800309:	89 10                	mov    %edx,(%eax)
}
  80030b:	5d                   	pop    %ebp
  80030c:	c3                   	ret    

0080030d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	57                   	push   %edi
  800311:	56                   	push   %esi
  800312:	53                   	push   %ebx
  800313:	83 ec 5c             	sub    $0x5c,%esp
  800316:	8b 7d 08             	mov    0x8(%ebp),%edi
  800319:	8b 75 0c             	mov    0xc(%ebp),%esi
  80031c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80031f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800326:	eb 11                	jmp    800339 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800328:	85 c0                	test   %eax,%eax
  80032a:	0f 84 16 04 00 00    	je     800746 <vprintfmt+0x439>
				return;
			putch(ch, putdat);
  800330:	89 74 24 04          	mov    %esi,0x4(%esp)
  800334:	89 04 24             	mov    %eax,(%esp)
  800337:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800339:	0f b6 03             	movzbl (%ebx),%eax
  80033c:	83 c3 01             	add    $0x1,%ebx
  80033f:	83 f8 25             	cmp    $0x25,%eax
  800342:	75 e4                	jne    800328 <vprintfmt+0x1b>
  800344:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80034b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800352:	b9 00 00 00 00       	mov    $0x0,%ecx
  800357:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80035b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800362:	eb 06                	jmp    80036a <vprintfmt+0x5d>
  800364:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800368:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80036a:	0f b6 13             	movzbl (%ebx),%edx
  80036d:	0f b6 c2             	movzbl %dl,%eax
  800370:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800373:	8d 43 01             	lea    0x1(%ebx),%eax
  800376:	83 ea 23             	sub    $0x23,%edx
  800379:	80 fa 55             	cmp    $0x55,%dl
  80037c:	0f 87 a7 03 00 00    	ja     800729 <vprintfmt+0x41c>
  800382:	0f b6 d2             	movzbl %dl,%edx
  800385:	ff 24 95 c0 13 80 00 	jmp    *0x8013c0(,%edx,4)
  80038c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800390:	eb d6                	jmp    800368 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800392:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800395:	83 ea 30             	sub    $0x30,%edx
  800398:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80039b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80039e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003a1:	83 fb 09             	cmp    $0x9,%ebx
  8003a4:	77 54                	ja     8003fa <vprintfmt+0xed>
  8003a6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003a9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003ac:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8003af:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003b2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8003b6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003b9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003bc:	83 fb 09             	cmp    $0x9,%ebx
  8003bf:	76 eb                	jbe    8003ac <vprintfmt+0x9f>
  8003c1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8003c4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003c7:	eb 31                	jmp    8003fa <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003c9:	8b 55 14             	mov    0x14(%ebp),%edx
  8003cc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8003cf:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8003d2:	8b 12                	mov    (%edx),%edx
  8003d4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8003d7:	eb 21                	jmp    8003fa <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8003d9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003dd:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e2:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  8003e6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003e9:	e9 7a ff ff ff       	jmp    800368 <vprintfmt+0x5b>
  8003ee:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003f5:	e9 6e ff ff ff       	jmp    800368 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003fa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003fe:	0f 89 64 ff ff ff    	jns    800368 <vprintfmt+0x5b>
  800404:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800407:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80040a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80040d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800410:	e9 53 ff ff ff       	jmp    800368 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800415:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800418:	e9 4b ff ff ff       	jmp    800368 <vprintfmt+0x5b>
  80041d:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800420:	8b 45 14             	mov    0x14(%ebp),%eax
  800423:	8d 50 04             	lea    0x4(%eax),%edx
  800426:	89 55 14             	mov    %edx,0x14(%ebp)
  800429:	89 74 24 04          	mov    %esi,0x4(%esp)
  80042d:	8b 00                	mov    (%eax),%eax
  80042f:	89 04 24             	mov    %eax,(%esp)
  800432:	ff d7                	call   *%edi
  800434:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800437:	e9 fd fe ff ff       	jmp    800339 <vprintfmt+0x2c>
  80043c:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80043f:	8b 45 14             	mov    0x14(%ebp),%eax
  800442:	8d 50 04             	lea    0x4(%eax),%edx
  800445:	89 55 14             	mov    %edx,0x14(%ebp)
  800448:	8b 00                	mov    (%eax),%eax
  80044a:	89 c2                	mov    %eax,%edx
  80044c:	c1 fa 1f             	sar    $0x1f,%edx
  80044f:	31 d0                	xor    %edx,%eax
  800451:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800453:	83 f8 08             	cmp    $0x8,%eax
  800456:	7f 0b                	jg     800463 <vprintfmt+0x156>
  800458:	8b 14 85 20 15 80 00 	mov    0x801520(,%eax,4),%edx
  80045f:	85 d2                	test   %edx,%edx
  800461:	75 20                	jne    800483 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800463:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800467:	c7 44 24 08 17 13 80 	movl   $0x801317,0x8(%esp)
  80046e:	00 
  80046f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800473:	89 3c 24             	mov    %edi,(%esp)
  800476:	e8 53 03 00 00       	call   8007ce <printfmt>
  80047b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80047e:	e9 b6 fe ff ff       	jmp    800339 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800483:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800487:	c7 44 24 08 20 13 80 	movl   $0x801320,0x8(%esp)
  80048e:	00 
  80048f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800493:	89 3c 24             	mov    %edi,(%esp)
  800496:	e8 33 03 00 00       	call   8007ce <printfmt>
  80049b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80049e:	e9 96 fe ff ff       	jmp    800339 <vprintfmt+0x2c>
  8004a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004a6:	89 c3                	mov    %eax,%ebx
  8004a8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004ab:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004ae:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b4:	8d 50 04             	lea    0x4(%eax),%edx
  8004b7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ba:	8b 00                	mov    (%eax),%eax
  8004bc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	b8 23 13 80 00       	mov    $0x801323,%eax
  8004c6:	0f 45 45 c4          	cmovne -0x3c(%ebp),%eax
  8004ca:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8004cd:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8004d1:	7e 06                	jle    8004d9 <vprintfmt+0x1cc>
  8004d3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004d7:	75 13                	jne    8004ec <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004dc:	0f be 02             	movsbl (%edx),%eax
  8004df:	85 c0                	test   %eax,%eax
  8004e1:	0f 85 9b 00 00 00    	jne    800582 <vprintfmt+0x275>
  8004e7:	e9 88 00 00 00       	jmp    800574 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ec:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004f0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  8004f3:	89 0c 24             	mov    %ecx,(%esp)
  8004f6:	e8 20 03 00 00       	call   80081b <strnlen>
  8004fb:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8004fe:	29 c2                	sub    %eax,%edx
  800500:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800503:	85 d2                	test   %edx,%edx
  800505:	7e d2                	jle    8004d9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800507:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  80050b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80050e:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800511:	89 d3                	mov    %edx,%ebx
  800513:	89 74 24 04          	mov    %esi,0x4(%esp)
  800517:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80051a:	89 04 24             	mov    %eax,(%esp)
  80051d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051f:	83 eb 01             	sub    $0x1,%ebx
  800522:	85 db                	test   %ebx,%ebx
  800524:	7f ed                	jg     800513 <vprintfmt+0x206>
  800526:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  800529:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800530:	eb a7                	jmp    8004d9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800532:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800536:	74 1a                	je     800552 <vprintfmt+0x245>
  800538:	8d 50 e0             	lea    -0x20(%eax),%edx
  80053b:	83 fa 5e             	cmp    $0x5e,%edx
  80053e:	76 12                	jbe    800552 <vprintfmt+0x245>
					putch('?', putdat);
  800540:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800544:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80054b:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80054e:	66 90                	xchg   %ax,%ax
  800550:	eb 0a                	jmp    80055c <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800552:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800556:	89 04 24             	mov    %eax,(%esp)
  800559:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80055c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800560:	0f be 03             	movsbl (%ebx),%eax
  800563:	85 c0                	test   %eax,%eax
  800565:	74 05                	je     80056c <vprintfmt+0x25f>
  800567:	83 c3 01             	add    $0x1,%ebx
  80056a:	eb 29                	jmp    800595 <vprintfmt+0x288>
  80056c:	89 fe                	mov    %edi,%esi
  80056e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800571:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800574:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800578:	7f 2e                	jg     8005a8 <vprintfmt+0x29b>
  80057a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057d:	e9 b7 fd ff ff       	jmp    800339 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800582:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800585:	83 c2 01             	add    $0x1,%edx
  800588:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80058b:	89 f7                	mov    %esi,%edi
  80058d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800590:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800593:	89 d3                	mov    %edx,%ebx
  800595:	85 f6                	test   %esi,%esi
  800597:	78 99                	js     800532 <vprintfmt+0x225>
  800599:	83 ee 01             	sub    $0x1,%esi
  80059c:	79 94                	jns    800532 <vprintfmt+0x225>
  80059e:	89 fe                	mov    %edi,%esi
  8005a0:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005a3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8005a6:	eb cc                	jmp    800574 <vprintfmt+0x267>
  8005a8:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8005ab:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005ae:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005b2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005b9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005bb:	83 eb 01             	sub    $0x1,%ebx
  8005be:	85 db                	test   %ebx,%ebx
  8005c0:	7f ec                	jg     8005ae <vprintfmt+0x2a1>
  8005c2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005c5:	e9 6f fd ff ff       	jmp    800339 <vprintfmt+0x2c>
  8005ca:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005cd:	83 f9 01             	cmp    $0x1,%ecx
  8005d0:	7e 16                	jle    8005e8 <vprintfmt+0x2db>
		return va_arg(*ap, long long);
  8005d2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d5:	8d 50 08             	lea    0x8(%eax),%edx
  8005d8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005db:	8b 10                	mov    (%eax),%edx
  8005dd:	8b 48 04             	mov    0x4(%eax),%ecx
  8005e0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005e3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005e6:	eb 32                	jmp    80061a <vprintfmt+0x30d>
	else if (lflag)
  8005e8:	85 c9                	test   %ecx,%ecx
  8005ea:	74 18                	je     800604 <vprintfmt+0x2f7>
		return va_arg(*ap, long);
  8005ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ef:	8d 50 04             	lea    0x4(%eax),%edx
  8005f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005f5:	8b 00                	mov    (%eax),%eax
  8005f7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005fa:	89 c1                	mov    %eax,%ecx
  8005fc:	c1 f9 1f             	sar    $0x1f,%ecx
  8005ff:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800602:	eb 16                	jmp    80061a <vprintfmt+0x30d>
	else
		return va_arg(*ap, int);
  800604:	8b 45 14             	mov    0x14(%ebp),%eax
  800607:	8d 50 04             	lea    0x4(%eax),%edx
  80060a:	89 55 14             	mov    %edx,0x14(%ebp)
  80060d:	8b 00                	mov    (%eax),%eax
  80060f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800612:	89 c2                	mov    %eax,%edx
  800614:	c1 fa 1f             	sar    $0x1f,%edx
  800617:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80061a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80061d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800620:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800625:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800629:	0f 89 b8 00 00 00    	jns    8006e7 <vprintfmt+0x3da>
				putch('-', putdat);
  80062f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800633:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80063a:	ff d7                	call   *%edi
				num = -(long long) num;
  80063c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80063f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800642:	f7 d9                	neg    %ecx
  800644:	83 d3 00             	adc    $0x0,%ebx
  800647:	f7 db                	neg    %ebx
  800649:	b8 0a 00 00 00       	mov    $0xa,%eax
  80064e:	e9 94 00 00 00       	jmp    8006e7 <vprintfmt+0x3da>
  800653:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800656:	89 ca                	mov    %ecx,%edx
  800658:	8d 45 14             	lea    0x14(%ebp),%eax
  80065b:	e8 56 fc ff ff       	call   8002b6 <getuint>
  800660:	89 c1                	mov    %eax,%ecx
  800662:	89 d3                	mov    %edx,%ebx
  800664:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800669:	eb 7c                	jmp    8006e7 <vprintfmt+0x3da>
  80066b:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80066e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800672:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800679:	ff d7                	call   *%edi
			putch('X', putdat);
  80067b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80067f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800686:	ff d7                	call   *%edi
			putch('X', putdat);
  800688:	89 74 24 04          	mov    %esi,0x4(%esp)
  80068c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800693:	ff d7                	call   *%edi
  800695:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800698:	e9 9c fc ff ff       	jmp    800339 <vprintfmt+0x2c>
  80069d:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8006a0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006ab:	ff d7                	call   *%edi
			putch('x', putdat);
  8006ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b1:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006b8:	ff d7                	call   *%edi
			num = (unsigned long long)
  8006ba:	8b 45 14             	mov    0x14(%ebp),%eax
  8006bd:	8d 50 04             	lea    0x4(%eax),%edx
  8006c0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006c3:	8b 08                	mov    (%eax),%ecx
  8006c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ca:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006cf:	eb 16                	jmp    8006e7 <vprintfmt+0x3da>
  8006d1:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006d4:	89 ca                	mov    %ecx,%edx
  8006d6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006d9:	e8 d8 fb ff ff       	call   8002b6 <getuint>
  8006de:	89 c1                	mov    %eax,%ecx
  8006e0:	89 d3                	mov    %edx,%ebx
  8006e2:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006e7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006eb:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006ef:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006f2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006f6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006fa:	89 0c 24             	mov    %ecx,(%esp)
  8006fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800701:	89 f2                	mov    %esi,%edx
  800703:	89 f8                	mov    %edi,%eax
  800705:	e8 b6 fa ff ff       	call   8001c0 <printnum>
  80070a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80070d:	e9 27 fc ff ff       	jmp    800339 <vprintfmt+0x2c>
  800712:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800715:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800718:	89 74 24 04          	mov    %esi,0x4(%esp)
  80071c:	89 14 24             	mov    %edx,(%esp)
  80071f:	ff d7                	call   *%edi
  800721:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800724:	e9 10 fc ff ff       	jmp    800339 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800729:	89 74 24 04          	mov    %esi,0x4(%esp)
  80072d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800734:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800736:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800739:	80 38 25             	cmpb   $0x25,(%eax)
  80073c:	0f 84 f7 fb ff ff    	je     800339 <vprintfmt+0x2c>
  800742:	89 c3                	mov    %eax,%ebx
  800744:	eb f0                	jmp    800736 <vprintfmt+0x429>
				/* do nothing */;
			break;
		}
	}
}
  800746:	83 c4 5c             	add    $0x5c,%esp
  800749:	5b                   	pop    %ebx
  80074a:	5e                   	pop    %esi
  80074b:	5f                   	pop    %edi
  80074c:	5d                   	pop    %ebp
  80074d:	c3                   	ret    

0080074e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80074e:	55                   	push   %ebp
  80074f:	89 e5                	mov    %esp,%ebp
  800751:	83 ec 28             	sub    $0x28,%esp
  800754:	8b 45 08             	mov    0x8(%ebp),%eax
  800757:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80075a:	85 c0                	test   %eax,%eax
  80075c:	74 04                	je     800762 <vsnprintf+0x14>
  80075e:	85 d2                	test   %edx,%edx
  800760:	7f 07                	jg     800769 <vsnprintf+0x1b>
  800762:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800767:	eb 3b                	jmp    8007a4 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800769:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80076c:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800770:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800773:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800781:	8b 45 10             	mov    0x10(%ebp),%eax
  800784:	89 44 24 08          	mov    %eax,0x8(%esp)
  800788:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80078b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80078f:	c7 04 24 f0 02 80 00 	movl   $0x8002f0,(%esp)
  800796:	e8 72 fb ff ff       	call   80030d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80079b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80079e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007a4:	c9                   	leave  
  8007a5:	c3                   	ret    

008007a6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007a6:	55                   	push   %ebp
  8007a7:	89 e5                	mov    %esp,%ebp
  8007a9:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8007ac:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8007af:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b3:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007c1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c4:	89 04 24             	mov    %eax,(%esp)
  8007c7:	e8 82 ff ff ff       	call   80074e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007cc:	c9                   	leave  
  8007cd:	c3                   	ret    

008007ce <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8007d4:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8007d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007db:	8b 45 10             	mov    0x10(%ebp),%eax
  8007de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007e5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ec:	89 04 24             	mov    %eax,(%esp)
  8007ef:	e8 19 fb ff ff       	call   80030d <vprintfmt>
	va_end(ap);
}
  8007f4:	c9                   	leave  
  8007f5:	c3                   	ret    
  8007f6:	66 90                	xchg   %ax,%ax
  8007f8:	66 90                	xchg   %ax,%ax
  8007fa:	66 90                	xchg   %ax,%ax
  8007fc:	66 90                	xchg   %ax,%ax
  8007fe:	66 90                	xchg   %ax,%ax

00800800 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800800:	55                   	push   %ebp
  800801:	89 e5                	mov    %esp,%ebp
  800803:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800806:	b8 00 00 00 00       	mov    $0x0,%eax
  80080b:	80 3a 00             	cmpb   $0x0,(%edx)
  80080e:	74 09                	je     800819 <strlen+0x19>
		n++;
  800810:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800813:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800817:	75 f7                	jne    800810 <strlen+0x10>
		n++;
	return n;
}
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800822:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800825:	85 c9                	test   %ecx,%ecx
  800827:	74 19                	je     800842 <strnlen+0x27>
  800829:	80 3b 00             	cmpb   $0x0,(%ebx)
  80082c:	74 14                	je     800842 <strnlen+0x27>
  80082e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800833:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800836:	39 c8                	cmp    %ecx,%eax
  800838:	74 0d                	je     800847 <strnlen+0x2c>
  80083a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80083e:	75 f3                	jne    800833 <strnlen+0x18>
  800840:	eb 05                	jmp    800847 <strnlen+0x2c>
  800842:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800847:	5b                   	pop    %ebx
  800848:	5d                   	pop    %ebp
  800849:	c3                   	ret    

0080084a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80084a:	55                   	push   %ebp
  80084b:	89 e5                	mov    %esp,%ebp
  80084d:	53                   	push   %ebx
  80084e:	8b 45 08             	mov    0x8(%ebp),%eax
  800851:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800854:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800859:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80085d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800860:	83 c2 01             	add    $0x1,%edx
  800863:	84 c9                	test   %cl,%cl
  800865:	75 f2                	jne    800859 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800867:	5b                   	pop    %ebx
  800868:	5d                   	pop    %ebp
  800869:	c3                   	ret    

0080086a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80086a:	55                   	push   %ebp
  80086b:	89 e5                	mov    %esp,%ebp
  80086d:	53                   	push   %ebx
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800874:	89 1c 24             	mov    %ebx,(%esp)
  800877:	e8 84 ff ff ff       	call   800800 <strlen>
	strcpy(dst + len, src);
  80087c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80087f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800883:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800886:	89 04 24             	mov    %eax,(%esp)
  800889:	e8 bc ff ff ff       	call   80084a <strcpy>
	return dst;
}
  80088e:	89 d8                	mov    %ebx,%eax
  800890:	83 c4 08             	add    $0x8,%esp
  800893:	5b                   	pop    %ebx
  800894:	5d                   	pop    %ebp
  800895:	c3                   	ret    

00800896 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	56                   	push   %esi
  80089a:	53                   	push   %ebx
  80089b:	8b 45 08             	mov    0x8(%ebp),%eax
  80089e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008a4:	85 f6                	test   %esi,%esi
  8008a6:	74 18                	je     8008c0 <strncpy+0x2a>
  8008a8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008ad:	0f b6 1a             	movzbl (%edx),%ebx
  8008b0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008b3:	80 3a 01             	cmpb   $0x1,(%edx)
  8008b6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b9:	83 c1 01             	add    $0x1,%ecx
  8008bc:	39 ce                	cmp    %ecx,%esi
  8008be:	77 ed                	ja     8008ad <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008c0:	5b                   	pop    %ebx
  8008c1:	5e                   	pop    %esi
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008c4:	55                   	push   %ebp
  8008c5:	89 e5                	mov    %esp,%ebp
  8008c7:	56                   	push   %esi
  8008c8:	53                   	push   %ebx
  8008c9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008cf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008d2:	89 f0                	mov    %esi,%eax
  8008d4:	85 c9                	test   %ecx,%ecx
  8008d6:	74 27                	je     8008ff <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8008d8:	83 e9 01             	sub    $0x1,%ecx
  8008db:	74 1d                	je     8008fa <strlcpy+0x36>
  8008dd:	0f b6 1a             	movzbl (%edx),%ebx
  8008e0:	84 db                	test   %bl,%bl
  8008e2:	74 16                	je     8008fa <strlcpy+0x36>
			*dst++ = *src++;
  8008e4:	88 18                	mov    %bl,(%eax)
  8008e6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008e9:	83 e9 01             	sub    $0x1,%ecx
  8008ec:	74 0e                	je     8008fc <strlcpy+0x38>
			*dst++ = *src++;
  8008ee:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008f1:	0f b6 1a             	movzbl (%edx),%ebx
  8008f4:	84 db                	test   %bl,%bl
  8008f6:	75 ec                	jne    8008e4 <strlcpy+0x20>
  8008f8:	eb 02                	jmp    8008fc <strlcpy+0x38>
  8008fa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008fc:	c6 00 00             	movb   $0x0,(%eax)
  8008ff:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800901:	5b                   	pop    %ebx
  800902:	5e                   	pop    %esi
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800905:	55                   	push   %ebp
  800906:	89 e5                	mov    %esp,%ebp
  800908:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80090b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80090e:	0f b6 01             	movzbl (%ecx),%eax
  800911:	84 c0                	test   %al,%al
  800913:	74 15                	je     80092a <strcmp+0x25>
  800915:	3a 02                	cmp    (%edx),%al
  800917:	75 11                	jne    80092a <strcmp+0x25>
		p++, q++;
  800919:	83 c1 01             	add    $0x1,%ecx
  80091c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80091f:	0f b6 01             	movzbl (%ecx),%eax
  800922:	84 c0                	test   %al,%al
  800924:	74 04                	je     80092a <strcmp+0x25>
  800926:	3a 02                	cmp    (%edx),%al
  800928:	74 ef                	je     800919 <strcmp+0x14>
  80092a:	0f b6 c0             	movzbl %al,%eax
  80092d:	0f b6 12             	movzbl (%edx),%edx
  800930:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	53                   	push   %ebx
  800938:	8b 55 08             	mov    0x8(%ebp),%edx
  80093b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80093e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800941:	85 c0                	test   %eax,%eax
  800943:	74 23                	je     800968 <strncmp+0x34>
  800945:	0f b6 1a             	movzbl (%edx),%ebx
  800948:	84 db                	test   %bl,%bl
  80094a:	74 25                	je     800971 <strncmp+0x3d>
  80094c:	3a 19                	cmp    (%ecx),%bl
  80094e:	75 21                	jne    800971 <strncmp+0x3d>
  800950:	83 e8 01             	sub    $0x1,%eax
  800953:	74 13                	je     800968 <strncmp+0x34>
		n--, p++, q++;
  800955:	83 c2 01             	add    $0x1,%edx
  800958:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80095b:	0f b6 1a             	movzbl (%edx),%ebx
  80095e:	84 db                	test   %bl,%bl
  800960:	74 0f                	je     800971 <strncmp+0x3d>
  800962:	3a 19                	cmp    (%ecx),%bl
  800964:	74 ea                	je     800950 <strncmp+0x1c>
  800966:	eb 09                	jmp    800971 <strncmp+0x3d>
  800968:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80096d:	5b                   	pop    %ebx
  80096e:	5d                   	pop    %ebp
  80096f:	90                   	nop
  800970:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800971:	0f b6 02             	movzbl (%edx),%eax
  800974:	0f b6 11             	movzbl (%ecx),%edx
  800977:	29 d0                	sub    %edx,%eax
  800979:	eb f2                	jmp    80096d <strncmp+0x39>

0080097b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800985:	0f b6 10             	movzbl (%eax),%edx
  800988:	84 d2                	test   %dl,%dl
  80098a:	74 18                	je     8009a4 <strchr+0x29>
		if (*s == c)
  80098c:	38 ca                	cmp    %cl,%dl
  80098e:	75 0a                	jne    80099a <strchr+0x1f>
  800990:	eb 17                	jmp    8009a9 <strchr+0x2e>
  800992:	38 ca                	cmp    %cl,%dl
  800994:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800998:	74 0f                	je     8009a9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80099a:	83 c0 01             	add    $0x1,%eax
  80099d:	0f b6 10             	movzbl (%eax),%edx
  8009a0:	84 d2                	test   %dl,%dl
  8009a2:	75 ee                	jne    800992 <strchr+0x17>
  8009a4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8009a9:	5d                   	pop    %ebp
  8009aa:	c3                   	ret    

008009ab <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b5:	0f b6 10             	movzbl (%eax),%edx
  8009b8:	84 d2                	test   %dl,%dl
  8009ba:	74 18                	je     8009d4 <strfind+0x29>
		if (*s == c)
  8009bc:	38 ca                	cmp    %cl,%dl
  8009be:	75 0a                	jne    8009ca <strfind+0x1f>
  8009c0:	eb 12                	jmp    8009d4 <strfind+0x29>
  8009c2:	38 ca                	cmp    %cl,%dl
  8009c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009c8:	74 0a                	je     8009d4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	0f b6 10             	movzbl (%eax),%edx
  8009d0:	84 d2                	test   %dl,%dl
  8009d2:	75 ee                	jne    8009c2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009d4:	5d                   	pop    %ebp
  8009d5:	c3                   	ret    

008009d6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009d6:	55                   	push   %ebp
  8009d7:	89 e5                	mov    %esp,%ebp
  8009d9:	83 ec 0c             	sub    $0xc,%esp
  8009dc:	89 1c 24             	mov    %ebx,(%esp)
  8009df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009e3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8009e7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009f0:	85 c9                	test   %ecx,%ecx
  8009f2:	74 30                	je     800a24 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009f4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009fa:	75 25                	jne    800a21 <memset+0x4b>
  8009fc:	f6 c1 03             	test   $0x3,%cl
  8009ff:	75 20                	jne    800a21 <memset+0x4b>
		c &= 0xFF;
  800a01:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a04:	89 d3                	mov    %edx,%ebx
  800a06:	c1 e3 08             	shl    $0x8,%ebx
  800a09:	89 d6                	mov    %edx,%esi
  800a0b:	c1 e6 18             	shl    $0x18,%esi
  800a0e:	89 d0                	mov    %edx,%eax
  800a10:	c1 e0 10             	shl    $0x10,%eax
  800a13:	09 f0                	or     %esi,%eax
  800a15:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a17:	09 d8                	or     %ebx,%eax
  800a19:	c1 e9 02             	shr    $0x2,%ecx
  800a1c:	fc                   	cld    
  800a1d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a1f:	eb 03                	jmp    800a24 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a21:	fc                   	cld    
  800a22:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a24:	89 f8                	mov    %edi,%eax
  800a26:	8b 1c 24             	mov    (%esp),%ebx
  800a29:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a2d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a31:	89 ec                	mov    %ebp,%esp
  800a33:	5d                   	pop    %ebp
  800a34:	c3                   	ret    

00800a35 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a35:	55                   	push   %ebp
  800a36:	89 e5                	mov    %esp,%ebp
  800a38:	83 ec 08             	sub    $0x8,%esp
  800a3b:	89 34 24             	mov    %esi,(%esp)
  800a3e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a42:	8b 45 08             	mov    0x8(%ebp),%eax
  800a45:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800a48:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a4b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a4d:	39 c6                	cmp    %eax,%esi
  800a4f:	73 35                	jae    800a86 <memmove+0x51>
  800a51:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a54:	39 d0                	cmp    %edx,%eax
  800a56:	73 2e                	jae    800a86 <memmove+0x51>
		s += n;
		d += n;
  800a58:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a5a:	f6 c2 03             	test   $0x3,%dl
  800a5d:	75 1b                	jne    800a7a <memmove+0x45>
  800a5f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a65:	75 13                	jne    800a7a <memmove+0x45>
  800a67:	f6 c1 03             	test   $0x3,%cl
  800a6a:	75 0e                	jne    800a7a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a6c:	83 ef 04             	sub    $0x4,%edi
  800a6f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a72:	c1 e9 02             	shr    $0x2,%ecx
  800a75:	fd                   	std    
  800a76:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a78:	eb 09                	jmp    800a83 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a7a:	83 ef 01             	sub    $0x1,%edi
  800a7d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a80:	fd                   	std    
  800a81:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a83:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a84:	eb 20                	jmp    800aa6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a86:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a8c:	75 15                	jne    800aa3 <memmove+0x6e>
  800a8e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a94:	75 0d                	jne    800aa3 <memmove+0x6e>
  800a96:	f6 c1 03             	test   $0x3,%cl
  800a99:	75 08                	jne    800aa3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800a9b:	c1 e9 02             	shr    $0x2,%ecx
  800a9e:	fc                   	cld    
  800a9f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa1:	eb 03                	jmp    800aa6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800aa3:	fc                   	cld    
  800aa4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800aa6:	8b 34 24             	mov    (%esp),%esi
  800aa9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800aad:	89 ec                	mov    %ebp,%esp
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ab7:	8b 45 10             	mov    0x10(%ebp),%eax
  800aba:	89 44 24 08          	mov    %eax,0x8(%esp)
  800abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac8:	89 04 24             	mov    %eax,(%esp)
  800acb:	e8 65 ff ff ff       	call   800a35 <memmove>
}
  800ad0:	c9                   	leave  
  800ad1:	c3                   	ret    

00800ad2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	57                   	push   %edi
  800ad6:	56                   	push   %esi
  800ad7:	53                   	push   %ebx
  800ad8:	8b 75 08             	mov    0x8(%ebp),%esi
  800adb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ade:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ae1:	85 c9                	test   %ecx,%ecx
  800ae3:	74 36                	je     800b1b <memcmp+0x49>
		if (*s1 != *s2)
  800ae5:	0f b6 06             	movzbl (%esi),%eax
  800ae8:	0f b6 1f             	movzbl (%edi),%ebx
  800aeb:	38 d8                	cmp    %bl,%al
  800aed:	74 20                	je     800b0f <memcmp+0x3d>
  800aef:	eb 14                	jmp    800b05 <memcmp+0x33>
  800af1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800af6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800afb:	83 c2 01             	add    $0x1,%edx
  800afe:	83 e9 01             	sub    $0x1,%ecx
  800b01:	38 d8                	cmp    %bl,%al
  800b03:	74 12                	je     800b17 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b05:	0f b6 c0             	movzbl %al,%eax
  800b08:	0f b6 db             	movzbl %bl,%ebx
  800b0b:	29 d8                	sub    %ebx,%eax
  800b0d:	eb 11                	jmp    800b20 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b0f:	83 e9 01             	sub    $0x1,%ecx
  800b12:	ba 00 00 00 00       	mov    $0x0,%edx
  800b17:	85 c9                	test   %ecx,%ecx
  800b19:	75 d6                	jne    800af1 <memcmp+0x1f>
  800b1b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b20:	5b                   	pop    %ebx
  800b21:	5e                   	pop    %esi
  800b22:	5f                   	pop    %edi
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b2b:	89 c2                	mov    %eax,%edx
  800b2d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b30:	39 d0                	cmp    %edx,%eax
  800b32:	73 15                	jae    800b49 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b34:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b38:	38 08                	cmp    %cl,(%eax)
  800b3a:	75 06                	jne    800b42 <memfind+0x1d>
  800b3c:	eb 0b                	jmp    800b49 <memfind+0x24>
  800b3e:	38 08                	cmp    %cl,(%eax)
  800b40:	74 07                	je     800b49 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b42:	83 c0 01             	add    $0x1,%eax
  800b45:	39 c2                	cmp    %eax,%edx
  800b47:	77 f5                	ja     800b3e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	57                   	push   %edi
  800b4f:	56                   	push   %esi
  800b50:	53                   	push   %ebx
  800b51:	83 ec 04             	sub    $0x4,%esp
  800b54:	8b 55 08             	mov    0x8(%ebp),%edx
  800b57:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b5a:	0f b6 02             	movzbl (%edx),%eax
  800b5d:	3c 20                	cmp    $0x20,%al
  800b5f:	74 04                	je     800b65 <strtol+0x1a>
  800b61:	3c 09                	cmp    $0x9,%al
  800b63:	75 0e                	jne    800b73 <strtol+0x28>
		s++;
  800b65:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b68:	0f b6 02             	movzbl (%edx),%eax
  800b6b:	3c 20                	cmp    $0x20,%al
  800b6d:	74 f6                	je     800b65 <strtol+0x1a>
  800b6f:	3c 09                	cmp    $0x9,%al
  800b71:	74 f2                	je     800b65 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b73:	3c 2b                	cmp    $0x2b,%al
  800b75:	75 0c                	jne    800b83 <strtol+0x38>
		s++;
  800b77:	83 c2 01             	add    $0x1,%edx
  800b7a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b81:	eb 15                	jmp    800b98 <strtol+0x4d>
	else if (*s == '-')
  800b83:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b8a:	3c 2d                	cmp    $0x2d,%al
  800b8c:	75 0a                	jne    800b98 <strtol+0x4d>
		s++, neg = 1;
  800b8e:	83 c2 01             	add    $0x1,%edx
  800b91:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b98:	85 db                	test   %ebx,%ebx
  800b9a:	0f 94 c0             	sete   %al
  800b9d:	74 05                	je     800ba4 <strtol+0x59>
  800b9f:	83 fb 10             	cmp    $0x10,%ebx
  800ba2:	75 18                	jne    800bbc <strtol+0x71>
  800ba4:	80 3a 30             	cmpb   $0x30,(%edx)
  800ba7:	75 13                	jne    800bbc <strtol+0x71>
  800ba9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bad:	8d 76 00             	lea    0x0(%esi),%esi
  800bb0:	75 0a                	jne    800bbc <strtol+0x71>
		s += 2, base = 16;
  800bb2:	83 c2 02             	add    $0x2,%edx
  800bb5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bba:	eb 15                	jmp    800bd1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bbc:	84 c0                	test   %al,%al
  800bbe:	66 90                	xchg   %ax,%ax
  800bc0:	74 0f                	je     800bd1 <strtol+0x86>
  800bc2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bc7:	80 3a 30             	cmpb   $0x30,(%edx)
  800bca:	75 05                	jne    800bd1 <strtol+0x86>
		s++, base = 8;
  800bcc:	83 c2 01             	add    $0x1,%edx
  800bcf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bd1:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800bd8:	0f b6 0a             	movzbl (%edx),%ecx
  800bdb:	89 cf                	mov    %ecx,%edi
  800bdd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800be0:	80 fb 09             	cmp    $0x9,%bl
  800be3:	77 08                	ja     800bed <strtol+0xa2>
			dig = *s - '0';
  800be5:	0f be c9             	movsbl %cl,%ecx
  800be8:	83 e9 30             	sub    $0x30,%ecx
  800beb:	eb 1e                	jmp    800c0b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800bed:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800bf0:	80 fb 19             	cmp    $0x19,%bl
  800bf3:	77 08                	ja     800bfd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800bf5:	0f be c9             	movsbl %cl,%ecx
  800bf8:	83 e9 57             	sub    $0x57,%ecx
  800bfb:	eb 0e                	jmp    800c0b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800bfd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c00:	80 fb 19             	cmp    $0x19,%bl
  800c03:	77 15                	ja     800c1a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c05:	0f be c9             	movsbl %cl,%ecx
  800c08:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c0b:	39 f1                	cmp    %esi,%ecx
  800c0d:	7d 0b                	jge    800c1a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c0f:	83 c2 01             	add    $0x1,%edx
  800c12:	0f af c6             	imul   %esi,%eax
  800c15:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c18:	eb be                	jmp    800bd8 <strtol+0x8d>
  800c1a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c1c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c20:	74 05                	je     800c27 <strtol+0xdc>
		*endptr = (char *) s;
  800c22:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c25:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c27:	89 ca                	mov    %ecx,%edx
  800c29:	f7 da                	neg    %edx
  800c2b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c2f:	0f 45 c2             	cmovne %edx,%eax
}
  800c32:	83 c4 04             	add    $0x4,%esp
  800c35:	5b                   	pop    %ebx
  800c36:	5e                   	pop    %esi
  800c37:	5f                   	pop    %edi
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	83 ec 0c             	sub    $0xc,%esp
  800c40:	89 1c 24             	mov    %ebx,(%esp)
  800c43:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c47:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c50:	b8 01 00 00 00       	mov    $0x1,%eax
  800c55:	89 d1                	mov    %edx,%ecx
  800c57:	89 d3                	mov    %edx,%ebx
  800c59:	89 d7                	mov    %edx,%edi
  800c5b:	89 d6                	mov    %edx,%esi
  800c5d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c5f:	8b 1c 24             	mov    (%esp),%ebx
  800c62:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c66:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c6a:	89 ec                	mov    %ebp,%esp
  800c6c:	5d                   	pop    %ebp
  800c6d:	c3                   	ret    

00800c6e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	83 ec 0c             	sub    $0xc,%esp
  800c74:	89 1c 24             	mov    %ebx,(%esp)
  800c77:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c7b:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c84:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c87:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8a:	89 c3                	mov    %eax,%ebx
  800c8c:	89 c7                	mov    %eax,%edi
  800c8e:	89 c6                	mov    %eax,%esi
  800c90:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c92:	8b 1c 24             	mov    (%esp),%ebx
  800c95:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c99:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c9d:	89 ec                	mov    %ebp,%esp
  800c9f:	5d                   	pop    %ebp
  800ca0:	c3                   	ret    

00800ca1 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800ca1:	55                   	push   %ebp
  800ca2:	89 e5                	mov    %esp,%ebp
  800ca4:	83 ec 38             	sub    $0x38,%esp
  800ca7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800caa:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cad:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cb0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cb5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cba:	8b 55 08             	mov    0x8(%ebp),%edx
  800cbd:	89 cb                	mov    %ecx,%ebx
  800cbf:	89 cf                	mov    %ecx,%edi
  800cc1:	89 ce                	mov    %ecx,%esi
  800cc3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cc5:	85 c0                	test   %eax,%eax
  800cc7:	7e 28                	jle    800cf1 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cc9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ccd:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800cd4:	00 
  800cd5:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800cdc:	00 
  800cdd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ce4:	00 
  800ce5:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800cec:	e8 16 03 00 00       	call   801007 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cf1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cf4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cf7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cfa:	89 ec                	mov    %ebp,%esp
  800cfc:	5d                   	pop    %ebp
  800cfd:	c3                   	ret    

00800cfe <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cfe:	55                   	push   %ebp
  800cff:	89 e5                	mov    %esp,%ebp
  800d01:	83 ec 0c             	sub    $0xc,%esp
  800d04:	89 1c 24             	mov    %ebx,(%esp)
  800d07:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d0b:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0f:	be 00 00 00 00       	mov    $0x0,%esi
  800d14:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d19:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d27:	8b 1c 24             	mov    (%esp),%ebx
  800d2a:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d2e:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d32:	89 ec                	mov    %ebp,%esp
  800d34:	5d                   	pop    %ebp
  800d35:	c3                   	ret    

00800d36 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d36:	55                   	push   %ebp
  800d37:	89 e5                	mov    %esp,%ebp
  800d39:	83 ec 38             	sub    $0x38,%esp
  800d3c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d3f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d42:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d45:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d4a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d52:	8b 55 08             	mov    0x8(%ebp),%edx
  800d55:	89 df                	mov    %ebx,%edi
  800d57:	89 de                	mov    %ebx,%esi
  800d59:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d5b:	85 c0                	test   %eax,%eax
  800d5d:	7e 28                	jle    800d87 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d5f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d63:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d6a:	00 
  800d6b:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800d72:	00 
  800d73:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d7a:	00 
  800d7b:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800d82:	e8 80 02 00 00       	call   801007 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d87:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d8a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d8d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d90:	89 ec                	mov    %ebp,%esp
  800d92:	5d                   	pop    %ebp
  800d93:	c3                   	ret    

00800d94 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d94:	55                   	push   %ebp
  800d95:	89 e5                	mov    %esp,%ebp
  800d97:	83 ec 38             	sub    $0x38,%esp
  800d9a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d9d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800da0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800da8:	b8 08 00 00 00       	mov    $0x8,%eax
  800dad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800db0:	8b 55 08             	mov    0x8(%ebp),%edx
  800db3:	89 df                	mov    %ebx,%edi
  800db5:	89 de                	mov    %ebx,%esi
  800db7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	7e 28                	jle    800de5 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dbd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dc1:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dc8:	00 
  800dc9:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800dd0:	00 
  800dd1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd8:	00 
  800dd9:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800de0:	e8 22 02 00 00       	call   801007 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800de5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800deb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dee:	89 ec                	mov    %ebp,%esp
  800df0:	5d                   	pop    %ebp
  800df1:	c3                   	ret    

00800df2 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800df2:	55                   	push   %ebp
  800df3:	89 e5                	mov    %esp,%ebp
  800df5:	83 ec 38             	sub    $0x38,%esp
  800df8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dfb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dfe:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e01:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e06:	b8 06 00 00 00       	mov    $0x6,%eax
  800e0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e0e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e11:	89 df                	mov    %ebx,%edi
  800e13:	89 de                	mov    %ebx,%esi
  800e15:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e17:	85 c0                	test   %eax,%eax
  800e19:	7e 28                	jle    800e43 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e1f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e26:	00 
  800e27:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800e2e:	00 
  800e2f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e36:	00 
  800e37:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800e3e:	e8 c4 01 00 00       	call   801007 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e43:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e46:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e49:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e4c:	89 ec                	mov    %ebp,%esp
  800e4e:	5d                   	pop    %ebp
  800e4f:	c3                   	ret    

00800e50 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e50:	55                   	push   %ebp
  800e51:	89 e5                	mov    %esp,%ebp
  800e53:	83 ec 38             	sub    $0x38,%esp
  800e56:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e59:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e5c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5f:	b8 05 00 00 00       	mov    $0x5,%eax
  800e64:	8b 75 18             	mov    0x18(%ebp),%esi
  800e67:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e6a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e70:	8b 55 08             	mov    0x8(%ebp),%edx
  800e73:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e75:	85 c0                	test   %eax,%eax
  800e77:	7e 28                	jle    800ea1 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e79:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e7d:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e84:	00 
  800e85:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800e8c:	00 
  800e8d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e94:	00 
  800e95:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800e9c:	e8 66 01 00 00       	call   801007 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ea1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ea7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eaa:	89 ec                	mov    %ebp,%esp
  800eac:	5d                   	pop    %ebp
  800ead:	c3                   	ret    

00800eae <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800eae:	55                   	push   %ebp
  800eaf:	89 e5                	mov    %esp,%ebp
  800eb1:	83 ec 38             	sub    $0x38,%esp
  800eb4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eb7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eba:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ebd:	be 00 00 00 00       	mov    $0x0,%esi
  800ec2:	b8 04 00 00 00       	mov    $0x4,%eax
  800ec7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eca:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ecd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed0:	89 f7                	mov    %esi,%edi
  800ed2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed4:	85 c0                	test   %eax,%eax
  800ed6:	7e 28                	jle    800f00 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800edc:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ee3:	00 
  800ee4:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800eeb:	00 
  800eec:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef3:	00 
  800ef4:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800efb:	e8 07 01 00 00       	call   801007 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f00:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f03:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f06:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f09:	89 ec                	mov    %ebp,%esp
  800f0b:	5d                   	pop    %ebp
  800f0c:	c3                   	ret    

00800f0d <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	83 ec 0c             	sub    $0xc,%esp
  800f13:	89 1c 24             	mov    %ebx,(%esp)
  800f16:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f1a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f23:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f28:	89 d1                	mov    %edx,%ecx
  800f2a:	89 d3                	mov    %edx,%ebx
  800f2c:	89 d7                	mov    %edx,%edi
  800f2e:	89 d6                	mov    %edx,%esi
  800f30:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f32:	8b 1c 24             	mov    (%esp),%ebx
  800f35:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f39:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f3d:	89 ec                	mov    %ebp,%esp
  800f3f:	5d                   	pop    %ebp
  800f40:	c3                   	ret    

00800f41 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f41:	55                   	push   %ebp
  800f42:	89 e5                	mov    %esp,%ebp
  800f44:	83 ec 0c             	sub    $0xc,%esp
  800f47:	89 1c 24             	mov    %ebx,(%esp)
  800f4a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f4e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f52:	ba 00 00 00 00       	mov    $0x0,%edx
  800f57:	b8 02 00 00 00       	mov    $0x2,%eax
  800f5c:	89 d1                	mov    %edx,%ecx
  800f5e:	89 d3                	mov    %edx,%ebx
  800f60:	89 d7                	mov    %edx,%edi
  800f62:	89 d6                	mov    %edx,%esi
  800f64:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f66:	8b 1c 24             	mov    (%esp),%ebx
  800f69:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f6d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f71:	89 ec                	mov    %ebp,%esp
  800f73:	5d                   	pop    %ebp
  800f74:	c3                   	ret    

00800f75 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f75:	55                   	push   %ebp
  800f76:	89 e5                	mov    %esp,%ebp
  800f78:	83 ec 38             	sub    $0x38,%esp
  800f7b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f7e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f81:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f84:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f89:	b8 03 00 00 00       	mov    $0x3,%eax
  800f8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f91:	89 cb                	mov    %ecx,%ebx
  800f93:	89 cf                	mov    %ecx,%edi
  800f95:	89 ce                	mov    %ecx,%esi
  800f97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	7e 28                	jle    800fc5 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f9d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fa1:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800fa8:	00 
  800fa9:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  800fb0:	00 
  800fb1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fb8:	00 
  800fb9:	c7 04 24 61 15 80 00 	movl   $0x801561,(%esp)
  800fc0:	e8 42 00 00 00       	call   801007 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800fc5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fc8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fcb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fce:	89 ec                	mov    %ebp,%esp
  800fd0:	5d                   	pop    %ebp
  800fd1:	c3                   	ret    

00800fd2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  800fd8:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  800fdf:	75 1c                	jne    800ffd <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  800fe1:	c7 44 24 08 70 15 80 	movl   $0x801570,0x8(%esp)
  800fe8:	00 
  800fe9:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  800ff0:	00 
  800ff1:	c7 04 24 94 15 80 00 	movl   $0x801594,(%esp)
  800ff8:	e8 0a 00 00 00       	call   801007 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800ffd:	8b 45 08             	mov    0x8(%ebp),%eax
  801000:	a3 08 20 80 00       	mov    %eax,0x802008
}
  801005:	c9                   	leave  
  801006:	c3                   	ret    

00801007 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801007:	55                   	push   %ebp
  801008:	89 e5                	mov    %esp,%ebp
  80100a:	56                   	push   %esi
  80100b:	53                   	push   %ebx
  80100c:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80100f:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801012:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801018:	e8 24 ff ff ff       	call   800f41 <sys_getenvid>
  80101d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801020:	89 54 24 10          	mov    %edx,0x10(%esp)
  801024:	8b 55 08             	mov    0x8(%ebp),%edx
  801027:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80102b:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80102f:	89 44 24 04          	mov    %eax,0x4(%esp)
  801033:	c7 04 24 a4 15 80 00 	movl   $0x8015a4,(%esp)
  80103a:	e8 21 f1 ff ff       	call   800160 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80103f:	89 74 24 04          	mov    %esi,0x4(%esp)
  801043:	8b 45 10             	mov    0x10(%ebp),%eax
  801046:	89 04 24             	mov    %eax,(%esp)
  801049:	e8 b1 f0 ff ff       	call   8000ff <vcprintf>
	cprintf("\n");
  80104e:	c7 04 24 fa 12 80 00 	movl   $0x8012fa,(%esp)
  801055:	e8 06 f1 ff ff       	call   800160 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80105a:	cc                   	int3   
  80105b:	eb fd                	jmp    80105a <_panic+0x53>
  80105d:	66 90                	xchg   %ax,%ax
  80105f:	90                   	nop

00801060 <__udivdi3>:
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	57                   	push   %edi
  801064:	56                   	push   %esi
  801065:	83 ec 10             	sub    $0x10,%esp
  801068:	8b 45 14             	mov    0x14(%ebp),%eax
  80106b:	8b 55 08             	mov    0x8(%ebp),%edx
  80106e:	8b 75 10             	mov    0x10(%ebp),%esi
  801071:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801074:	85 c0                	test   %eax,%eax
  801076:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801079:	75 35                	jne    8010b0 <__udivdi3+0x50>
  80107b:	39 fe                	cmp    %edi,%esi
  80107d:	77 61                	ja     8010e0 <__udivdi3+0x80>
  80107f:	85 f6                	test   %esi,%esi
  801081:	75 0b                	jne    80108e <__udivdi3+0x2e>
  801083:	b8 01 00 00 00       	mov    $0x1,%eax
  801088:	31 d2                	xor    %edx,%edx
  80108a:	f7 f6                	div    %esi
  80108c:	89 c6                	mov    %eax,%esi
  80108e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801091:	31 d2                	xor    %edx,%edx
  801093:	89 f8                	mov    %edi,%eax
  801095:	f7 f6                	div    %esi
  801097:	89 c7                	mov    %eax,%edi
  801099:	89 c8                	mov    %ecx,%eax
  80109b:	f7 f6                	div    %esi
  80109d:	89 c1                	mov    %eax,%ecx
  80109f:	89 fa                	mov    %edi,%edx
  8010a1:	89 c8                	mov    %ecx,%eax
  8010a3:	83 c4 10             	add    $0x10,%esp
  8010a6:	5e                   	pop    %esi
  8010a7:	5f                   	pop    %edi
  8010a8:	5d                   	pop    %ebp
  8010a9:	c3                   	ret    
  8010aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010b0:	39 f8                	cmp    %edi,%eax
  8010b2:	77 1c                	ja     8010d0 <__udivdi3+0x70>
  8010b4:	0f bd d0             	bsr    %eax,%edx
  8010b7:	83 f2 1f             	xor    $0x1f,%edx
  8010ba:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8010bd:	75 39                	jne    8010f8 <__udivdi3+0x98>
  8010bf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8010c2:	0f 86 a0 00 00 00    	jbe    801168 <__udivdi3+0x108>
  8010c8:	39 f8                	cmp    %edi,%eax
  8010ca:	0f 82 98 00 00 00    	jb     801168 <__udivdi3+0x108>
  8010d0:	31 ff                	xor    %edi,%edi
  8010d2:	31 c9                	xor    %ecx,%ecx
  8010d4:	89 c8                	mov    %ecx,%eax
  8010d6:	89 fa                	mov    %edi,%edx
  8010d8:	83 c4 10             	add    $0x10,%esp
  8010db:	5e                   	pop    %esi
  8010dc:	5f                   	pop    %edi
  8010dd:	5d                   	pop    %ebp
  8010de:	c3                   	ret    
  8010df:	90                   	nop
  8010e0:	89 d1                	mov    %edx,%ecx
  8010e2:	89 fa                	mov    %edi,%edx
  8010e4:	89 c8                	mov    %ecx,%eax
  8010e6:	31 ff                	xor    %edi,%edi
  8010e8:	f7 f6                	div    %esi
  8010ea:	89 c1                	mov    %eax,%ecx
  8010ec:	89 fa                	mov    %edi,%edx
  8010ee:	89 c8                	mov    %ecx,%eax
  8010f0:	83 c4 10             	add    $0x10,%esp
  8010f3:	5e                   	pop    %esi
  8010f4:	5f                   	pop    %edi
  8010f5:	5d                   	pop    %ebp
  8010f6:	c3                   	ret    
  8010f7:	90                   	nop
  8010f8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010fc:	89 f2                	mov    %esi,%edx
  8010fe:	d3 e0                	shl    %cl,%eax
  801100:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801103:	b8 20 00 00 00       	mov    $0x20,%eax
  801108:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80110b:	89 c1                	mov    %eax,%ecx
  80110d:	d3 ea                	shr    %cl,%edx
  80110f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801113:	0b 55 ec             	or     -0x14(%ebp),%edx
  801116:	d3 e6                	shl    %cl,%esi
  801118:	89 c1                	mov    %eax,%ecx
  80111a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80111d:	89 fe                	mov    %edi,%esi
  80111f:	d3 ee                	shr    %cl,%esi
  801121:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801125:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801128:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80112b:	d3 e7                	shl    %cl,%edi
  80112d:	89 c1                	mov    %eax,%ecx
  80112f:	d3 ea                	shr    %cl,%edx
  801131:	09 d7                	or     %edx,%edi
  801133:	89 f2                	mov    %esi,%edx
  801135:	89 f8                	mov    %edi,%eax
  801137:	f7 75 ec             	divl   -0x14(%ebp)
  80113a:	89 d6                	mov    %edx,%esi
  80113c:	89 c7                	mov    %eax,%edi
  80113e:	f7 65 e8             	mull   -0x18(%ebp)
  801141:	39 d6                	cmp    %edx,%esi
  801143:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801146:	72 30                	jb     801178 <__udivdi3+0x118>
  801148:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80114b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80114f:	d3 e2                	shl    %cl,%edx
  801151:	39 c2                	cmp    %eax,%edx
  801153:	73 05                	jae    80115a <__udivdi3+0xfa>
  801155:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801158:	74 1e                	je     801178 <__udivdi3+0x118>
  80115a:	89 f9                	mov    %edi,%ecx
  80115c:	31 ff                	xor    %edi,%edi
  80115e:	e9 71 ff ff ff       	jmp    8010d4 <__udivdi3+0x74>
  801163:	90                   	nop
  801164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801168:	31 ff                	xor    %edi,%edi
  80116a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80116f:	e9 60 ff ff ff       	jmp    8010d4 <__udivdi3+0x74>
  801174:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801178:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80117b:	31 ff                	xor    %edi,%edi
  80117d:	89 c8                	mov    %ecx,%eax
  80117f:	89 fa                	mov    %edi,%edx
  801181:	83 c4 10             	add    $0x10,%esp
  801184:	5e                   	pop    %esi
  801185:	5f                   	pop    %edi
  801186:	5d                   	pop    %ebp
  801187:	c3                   	ret    
  801188:	66 90                	xchg   %ax,%ax
  80118a:	66 90                	xchg   %ax,%ax
  80118c:	66 90                	xchg   %ax,%ax
  80118e:	66 90                	xchg   %ax,%ax

00801190 <__umoddi3>:
  801190:	55                   	push   %ebp
  801191:	89 e5                	mov    %esp,%ebp
  801193:	57                   	push   %edi
  801194:	56                   	push   %esi
  801195:	83 ec 20             	sub    $0x20,%esp
  801198:	8b 55 14             	mov    0x14(%ebp),%edx
  80119b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80119e:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011a1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011a4:	85 d2                	test   %edx,%edx
  8011a6:	89 c8                	mov    %ecx,%eax
  8011a8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8011ab:	75 13                	jne    8011c0 <__umoddi3+0x30>
  8011ad:	39 f7                	cmp    %esi,%edi
  8011af:	76 3f                	jbe    8011f0 <__umoddi3+0x60>
  8011b1:	89 f2                	mov    %esi,%edx
  8011b3:	f7 f7                	div    %edi
  8011b5:	89 d0                	mov    %edx,%eax
  8011b7:	31 d2                	xor    %edx,%edx
  8011b9:	83 c4 20             	add    $0x20,%esp
  8011bc:	5e                   	pop    %esi
  8011bd:	5f                   	pop    %edi
  8011be:	5d                   	pop    %ebp
  8011bf:	c3                   	ret    
  8011c0:	39 f2                	cmp    %esi,%edx
  8011c2:	77 4c                	ja     801210 <__umoddi3+0x80>
  8011c4:	0f bd ca             	bsr    %edx,%ecx
  8011c7:	83 f1 1f             	xor    $0x1f,%ecx
  8011ca:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8011cd:	75 51                	jne    801220 <__umoddi3+0x90>
  8011cf:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8011d2:	0f 87 e0 00 00 00    	ja     8012b8 <__umoddi3+0x128>
  8011d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011db:	29 f8                	sub    %edi,%eax
  8011dd:	19 d6                	sbb    %edx,%esi
  8011df:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8011e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e5:	89 f2                	mov    %esi,%edx
  8011e7:	83 c4 20             	add    $0x20,%esp
  8011ea:	5e                   	pop    %esi
  8011eb:	5f                   	pop    %edi
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    
  8011ee:	66 90                	xchg   %ax,%ax
  8011f0:	85 ff                	test   %edi,%edi
  8011f2:	75 0b                	jne    8011ff <__umoddi3+0x6f>
  8011f4:	b8 01 00 00 00       	mov    $0x1,%eax
  8011f9:	31 d2                	xor    %edx,%edx
  8011fb:	f7 f7                	div    %edi
  8011fd:	89 c7                	mov    %eax,%edi
  8011ff:	89 f0                	mov    %esi,%eax
  801201:	31 d2                	xor    %edx,%edx
  801203:	f7 f7                	div    %edi
  801205:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801208:	f7 f7                	div    %edi
  80120a:	eb a9                	jmp    8011b5 <__umoddi3+0x25>
  80120c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801210:	89 c8                	mov    %ecx,%eax
  801212:	89 f2                	mov    %esi,%edx
  801214:	83 c4 20             	add    $0x20,%esp
  801217:	5e                   	pop    %esi
  801218:	5f                   	pop    %edi
  801219:	5d                   	pop    %ebp
  80121a:	c3                   	ret    
  80121b:	90                   	nop
  80121c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801220:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801224:	d3 e2                	shl    %cl,%edx
  801226:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801229:	ba 20 00 00 00       	mov    $0x20,%edx
  80122e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801231:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801234:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801238:	89 fa                	mov    %edi,%edx
  80123a:	d3 ea                	shr    %cl,%edx
  80123c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801240:	0b 55 f4             	or     -0xc(%ebp),%edx
  801243:	d3 e7                	shl    %cl,%edi
  801245:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801249:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80124c:	89 f2                	mov    %esi,%edx
  80124e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801251:	89 c7                	mov    %eax,%edi
  801253:	d3 ea                	shr    %cl,%edx
  801255:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801259:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80125c:	89 c2                	mov    %eax,%edx
  80125e:	d3 e6                	shl    %cl,%esi
  801260:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801264:	d3 ea                	shr    %cl,%edx
  801266:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80126a:	09 d6                	or     %edx,%esi
  80126c:	89 f0                	mov    %esi,%eax
  80126e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801271:	d3 e7                	shl    %cl,%edi
  801273:	89 f2                	mov    %esi,%edx
  801275:	f7 75 f4             	divl   -0xc(%ebp)
  801278:	89 d6                	mov    %edx,%esi
  80127a:	f7 65 e8             	mull   -0x18(%ebp)
  80127d:	39 d6                	cmp    %edx,%esi
  80127f:	72 2b                	jb     8012ac <__umoddi3+0x11c>
  801281:	39 c7                	cmp    %eax,%edi
  801283:	72 23                	jb     8012a8 <__umoddi3+0x118>
  801285:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801289:	29 c7                	sub    %eax,%edi
  80128b:	19 d6                	sbb    %edx,%esi
  80128d:	89 f0                	mov    %esi,%eax
  80128f:	89 f2                	mov    %esi,%edx
  801291:	d3 ef                	shr    %cl,%edi
  801293:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801297:	d3 e0                	shl    %cl,%eax
  801299:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80129d:	09 f8                	or     %edi,%eax
  80129f:	d3 ea                	shr    %cl,%edx
  8012a1:	83 c4 20             	add    $0x20,%esp
  8012a4:	5e                   	pop    %esi
  8012a5:	5f                   	pop    %edi
  8012a6:	5d                   	pop    %ebp
  8012a7:	c3                   	ret    
  8012a8:	39 d6                	cmp    %edx,%esi
  8012aa:	75 d9                	jne    801285 <__umoddi3+0xf5>
  8012ac:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8012af:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8012b2:	eb d1                	jmp    801285 <__umoddi3+0xf5>
  8012b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012b8:	39 f2                	cmp    %esi,%edx
  8012ba:	0f 82 18 ff ff ff    	jb     8011d8 <__umoddi3+0x48>
  8012c0:	e9 1d ff ff ff       	jmp    8011e2 <__umoddi3+0x52>
