
obj/user/divzero：     文件格式 elf32-i386


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
  80002c:	e8 35 00 00 00       	call   800066 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

int zero;

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	zero = 0;
  800039:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800040:	00 00 00 
	cprintf("1/0 is %08x!\n", 1/zero);
  800043:	ba 01 00 00 00       	mov    $0x1,%edx
  800048:	b9 00 00 00 00       	mov    $0x0,%ecx
  80004d:	89 d0                	mov    %edx,%eax
  80004f:	c1 fa 1f             	sar    $0x1f,%edx
  800052:	f7 f9                	idiv   %ecx
  800054:	89 44 24 04          	mov    %eax,0x4(%esp)
  800058:	c7 04 24 80 12 80 00 	movl   $0x801280,(%esp)
  80005f:	e8 d0 00 00 00       	call   800134 <cprintf>
}
  800064:	c9                   	leave  
  800065:	c3                   	ret    

00800066 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800066:	55                   	push   %ebp
  800067:	89 e5                	mov    %esp,%ebp
  800069:	83 ec 18             	sub    $0x18,%esp
  80006c:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80006f:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800072:	8b 75 08             	mov    0x8(%ebp),%esi
  800075:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800078:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  80007f:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800082:	e8 8a 0e 00 00       	call   800f11 <sys_getenvid>
  800087:	25 ff 03 00 00       	and    $0x3ff,%eax
  80008c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80008f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800094:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800099:	85 f6                	test   %esi,%esi
  80009b:	7e 07                	jle    8000a4 <libmain+0x3e>
		binaryname = argv[0];
  80009d:	8b 03                	mov    (%ebx),%eax
  80009f:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000a4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000a8:	89 34 24             	mov    %esi,(%esp)
  8000ab:	e8 83 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000b0:	e8 0a 00 00 00       	call   8000bf <exit>
}
  8000b5:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000b8:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000bb:	89 ec                	mov    %ebp,%esp
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    

008000bf <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000c5:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000cc:	e8 74 0e 00 00       	call   800f45 <sys_env_destroy>
}
  8000d1:	c9                   	leave  
  8000d2:	c3                   	ret    

008000d3 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000dc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000e3:	00 00 00 
	b.cnt = 0;
  8000e6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000ed:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000f3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8000fa:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000fe:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800104:	89 44 24 04          	mov    %eax,0x4(%esp)
  800108:	c7 04 24 4e 01 80 00 	movl   $0x80014e,(%esp)
  80010f:	e8 c9 01 00 00       	call   8002dd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800114:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80011a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80011e:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800124:	89 04 24             	mov    %eax,(%esp)
  800127:	e8 12 0b 00 00       	call   800c3e <sys_cputs>

	return b.cnt;
}
  80012c:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800132:	c9                   	leave  
  800133:	c3                   	ret    

00800134 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80013a:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80013d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800141:	8b 45 08             	mov    0x8(%ebp),%eax
  800144:	89 04 24             	mov    %eax,(%esp)
  800147:	e8 87 ff ff ff       	call   8000d3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80014c:	c9                   	leave  
  80014d:	c3                   	ret    

0080014e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80014e:	55                   	push   %ebp
  80014f:	89 e5                	mov    %esp,%ebp
  800151:	53                   	push   %ebx
  800152:	83 ec 14             	sub    $0x14,%esp
  800155:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800158:	8b 03                	mov    (%ebx),%eax
  80015a:	8b 55 08             	mov    0x8(%ebp),%edx
  80015d:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800161:	83 c0 01             	add    $0x1,%eax
  800164:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800166:	3d ff 00 00 00       	cmp    $0xff,%eax
  80016b:	75 19                	jne    800186 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80016d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800174:	00 
  800175:	8d 43 08             	lea    0x8(%ebx),%eax
  800178:	89 04 24             	mov    %eax,(%esp)
  80017b:	e8 be 0a 00 00       	call   800c3e <sys_cputs>
		b->idx = 0;
  800180:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800186:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80018a:	83 c4 14             	add    $0x14,%esp
  80018d:	5b                   	pop    %ebx
  80018e:	5d                   	pop    %ebp
  80018f:	c3                   	ret    

00800190 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800190:	55                   	push   %ebp
  800191:	89 e5                	mov    %esp,%ebp
  800193:	57                   	push   %edi
  800194:	56                   	push   %esi
  800195:	53                   	push   %ebx
  800196:	83 ec 4c             	sub    $0x4c,%esp
  800199:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80019c:	89 d6                	mov    %edx,%esi
  80019e:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001b0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001bb:	39 d1                	cmp    %edx,%ecx
  8001bd:	72 15                	jb     8001d4 <printnum+0x44>
  8001bf:	77 07                	ja     8001c8 <printnum+0x38>
  8001c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001c4:	39 d0                	cmp    %edx,%eax
  8001c6:	76 0c                	jbe    8001d4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001c8:	83 eb 01             	sub    $0x1,%ebx
  8001cb:	85 db                	test   %ebx,%ebx
  8001cd:	8d 76 00             	lea    0x0(%esi),%esi
  8001d0:	7f 61                	jg     800233 <printnum+0xa3>
  8001d2:	eb 70                	jmp    800244 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001d4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001d8:	83 eb 01             	sub    $0x1,%ebx
  8001db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8001e7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8001eb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8001ee:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8001f1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ff:	00 
  800200:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800203:	89 04 24             	mov    %eax,(%esp)
  800206:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800209:	89 54 24 04          	mov    %edx,0x4(%esp)
  80020d:	e8 ee 0d 00 00       	call   801000 <__udivdi3>
  800212:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800215:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800218:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80021c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800220:	89 04 24             	mov    %eax,(%esp)
  800223:	89 54 24 04          	mov    %edx,0x4(%esp)
  800227:	89 f2                	mov    %esi,%edx
  800229:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80022c:	e8 5f ff ff ff       	call   800190 <printnum>
  800231:	eb 11                	jmp    800244 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800233:	89 74 24 04          	mov    %esi,0x4(%esp)
  800237:	89 3c 24             	mov    %edi,(%esp)
  80023a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80023d:	83 eb 01             	sub    $0x1,%ebx
  800240:	85 db                	test   %ebx,%ebx
  800242:	7f ef                	jg     800233 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800244:	89 74 24 04          	mov    %esi,0x4(%esp)
  800248:	8b 74 24 04          	mov    0x4(%esp),%esi
  80024c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80024f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800253:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80025a:	00 
  80025b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80025e:	89 14 24             	mov    %edx,(%esp)
  800261:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800264:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800268:	e8 c3 0e 00 00       	call   801130 <__umoddi3>
  80026d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800271:	0f be 80 98 12 80 00 	movsbl 0x801298(%eax),%eax
  800278:	89 04 24             	mov    %eax,(%esp)
  80027b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80027e:	83 c4 4c             	add    $0x4c,%esp
  800281:	5b                   	pop    %ebx
  800282:	5e                   	pop    %esi
  800283:	5f                   	pop    %edi
  800284:	5d                   	pop    %ebp
  800285:	c3                   	ret    

00800286 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800286:	55                   	push   %ebp
  800287:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800289:	83 fa 01             	cmp    $0x1,%edx
  80028c:	7e 0e                	jle    80029c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80028e:	8b 10                	mov    (%eax),%edx
  800290:	8d 4a 08             	lea    0x8(%edx),%ecx
  800293:	89 08                	mov    %ecx,(%eax)
  800295:	8b 02                	mov    (%edx),%eax
  800297:	8b 52 04             	mov    0x4(%edx),%edx
  80029a:	eb 22                	jmp    8002be <getuint+0x38>
	else if (lflag)
  80029c:	85 d2                	test   %edx,%edx
  80029e:	74 10                	je     8002b0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002a0:	8b 10                	mov    (%eax),%edx
  8002a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 02                	mov    (%edx),%eax
  8002a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ae:	eb 0e                	jmp    8002be <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002b0:	8b 10                	mov    (%eax),%edx
  8002b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b5:	89 08                	mov    %ecx,(%eax)
  8002b7:	8b 02                	mov    (%edx),%eax
  8002b9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002be:	5d                   	pop    %ebp
  8002bf:	c3                   	ret    

008002c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002c6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ca:	8b 10                	mov    (%eax),%edx
  8002cc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002cf:	73 0a                	jae    8002db <sprintputch+0x1b>
		*b->buf++ = ch;
  8002d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d4:	88 0a                	mov    %cl,(%edx)
  8002d6:	83 c2 01             	add    $0x1,%edx
  8002d9:	89 10                	mov    %edx,(%eax)
}
  8002db:	5d                   	pop    %ebp
  8002dc:	c3                   	ret    

008002dd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
  8002e0:	57                   	push   %edi
  8002e1:	56                   	push   %esi
  8002e2:	53                   	push   %ebx
  8002e3:	83 ec 5c             	sub    $0x5c,%esp
  8002e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002ef:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002f6:	eb 11                	jmp    800309 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002f8:	85 c0                	test   %eax,%eax
  8002fa:	0f 84 16 04 00 00    	je     800716 <vprintfmt+0x439>
				return;
			putch(ch, putdat);
  800300:	89 74 24 04          	mov    %esi,0x4(%esp)
  800304:	89 04 24             	mov    %eax,(%esp)
  800307:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800309:	0f b6 03             	movzbl (%ebx),%eax
  80030c:	83 c3 01             	add    $0x1,%ebx
  80030f:	83 f8 25             	cmp    $0x25,%eax
  800312:	75 e4                	jne    8002f8 <vprintfmt+0x1b>
  800314:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80031b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800322:	b9 00 00 00 00       	mov    $0x0,%ecx
  800327:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80032b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800332:	eb 06                	jmp    80033a <vprintfmt+0x5d>
  800334:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800338:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80033a:	0f b6 13             	movzbl (%ebx),%edx
  80033d:	0f b6 c2             	movzbl %dl,%eax
  800340:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800343:	8d 43 01             	lea    0x1(%ebx),%eax
  800346:	83 ea 23             	sub    $0x23,%edx
  800349:	80 fa 55             	cmp    $0x55,%dl
  80034c:	0f 87 a7 03 00 00    	ja     8006f9 <vprintfmt+0x41c>
  800352:	0f b6 d2             	movzbl %dl,%edx
  800355:	ff 24 95 60 13 80 00 	jmp    *0x801360(,%edx,4)
  80035c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800360:	eb d6                	jmp    800338 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800362:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800365:	83 ea 30             	sub    $0x30,%edx
  800368:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80036b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80036e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800371:	83 fb 09             	cmp    $0x9,%ebx
  800374:	77 54                	ja     8003ca <vprintfmt+0xed>
  800376:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800379:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80037c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80037f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800382:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800386:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800389:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80038c:	83 fb 09             	cmp    $0x9,%ebx
  80038f:	76 eb                	jbe    80037c <vprintfmt+0x9f>
  800391:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800394:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800397:	eb 31                	jmp    8003ca <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800399:	8b 55 14             	mov    0x14(%ebp),%edx
  80039c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80039f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8003a2:	8b 12                	mov    (%edx),%edx
  8003a4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8003a7:	eb 21                	jmp    8003ca <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8003a9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b2:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  8003b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003b9:	e9 7a ff ff ff       	jmp    800338 <vprintfmt+0x5b>
  8003be:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003c5:	e9 6e ff ff ff       	jmp    800338 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ce:	0f 89 64 ff ff ff    	jns    800338 <vprintfmt+0x5b>
  8003d4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8003d7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003da:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8003dd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8003e0:	e9 53 ff ff ff       	jmp    800338 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003e5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8003e8:	e9 4b ff ff ff       	jmp    800338 <vprintfmt+0x5b>
  8003ed:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003f3:	8d 50 04             	lea    0x4(%eax),%edx
  8003f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003fd:	8b 00                	mov    (%eax),%eax
  8003ff:	89 04 24             	mov    %eax,(%esp)
  800402:	ff d7                	call   *%edi
  800404:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800407:	e9 fd fe ff ff       	jmp    800309 <vprintfmt+0x2c>
  80040c:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80040f:	8b 45 14             	mov    0x14(%ebp),%eax
  800412:	8d 50 04             	lea    0x4(%eax),%edx
  800415:	89 55 14             	mov    %edx,0x14(%ebp)
  800418:	8b 00                	mov    (%eax),%eax
  80041a:	89 c2                	mov    %eax,%edx
  80041c:	c1 fa 1f             	sar    $0x1f,%edx
  80041f:	31 d0                	xor    %edx,%eax
  800421:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800423:	83 f8 08             	cmp    $0x8,%eax
  800426:	7f 0b                	jg     800433 <vprintfmt+0x156>
  800428:	8b 14 85 c0 14 80 00 	mov    0x8014c0(,%eax,4),%edx
  80042f:	85 d2                	test   %edx,%edx
  800431:	75 20                	jne    800453 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800433:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800437:	c7 44 24 08 a9 12 80 	movl   $0x8012a9,0x8(%esp)
  80043e:	00 
  80043f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800443:	89 3c 24             	mov    %edi,(%esp)
  800446:	e8 53 03 00 00       	call   80079e <printfmt>
  80044b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80044e:	e9 b6 fe ff ff       	jmp    800309 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800453:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800457:	c7 44 24 08 b2 12 80 	movl   $0x8012b2,0x8(%esp)
  80045e:	00 
  80045f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800463:	89 3c 24             	mov    %edi,(%esp)
  800466:	e8 33 03 00 00       	call   80079e <printfmt>
  80046b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80046e:	e9 96 fe ff ff       	jmp    800309 <vprintfmt+0x2c>
  800473:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800476:	89 c3                	mov    %eax,%ebx
  800478:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80047b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80047e:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800481:	8b 45 14             	mov    0x14(%ebp),%eax
  800484:	8d 50 04             	lea    0x4(%eax),%edx
  800487:	89 55 14             	mov    %edx,0x14(%ebp)
  80048a:	8b 00                	mov    (%eax),%eax
  80048c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80048f:	85 c0                	test   %eax,%eax
  800491:	b8 b5 12 80 00       	mov    $0x8012b5,%eax
  800496:	0f 45 45 c4          	cmovne -0x3c(%ebp),%eax
  80049a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80049d:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8004a1:	7e 06                	jle    8004a9 <vprintfmt+0x1cc>
  8004a3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004a7:	75 13                	jne    8004bc <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004a9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004ac:	0f be 02             	movsbl (%edx),%eax
  8004af:	85 c0                	test   %eax,%eax
  8004b1:	0f 85 9b 00 00 00    	jne    800552 <vprintfmt+0x275>
  8004b7:	e9 88 00 00 00       	jmp    800544 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004bc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004c0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  8004c3:	89 0c 24             	mov    %ecx,(%esp)
  8004c6:	e8 20 03 00 00       	call   8007eb <strnlen>
  8004cb:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8004ce:	29 c2                	sub    %eax,%edx
  8004d0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004d3:	85 d2                	test   %edx,%edx
  8004d5:	7e d2                	jle    8004a9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  8004d7:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  8004db:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004de:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8004e1:	89 d3                	mov    %edx,%ebx
  8004e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004ea:	89 04 24             	mov    %eax,(%esp)
  8004ed:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ef:	83 eb 01             	sub    $0x1,%ebx
  8004f2:	85 db                	test   %ebx,%ebx
  8004f4:	7f ed                	jg     8004e3 <vprintfmt+0x206>
  8004f6:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8004f9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800500:	eb a7                	jmp    8004a9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800502:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800506:	74 1a                	je     800522 <vprintfmt+0x245>
  800508:	8d 50 e0             	lea    -0x20(%eax),%edx
  80050b:	83 fa 5e             	cmp    $0x5e,%edx
  80050e:	76 12                	jbe    800522 <vprintfmt+0x245>
					putch('?', putdat);
  800510:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800514:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80051b:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80051e:	66 90                	xchg   %ax,%ax
  800520:	eb 0a                	jmp    80052c <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800522:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800526:	89 04 24             	mov    %eax,(%esp)
  800529:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80052c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800530:	0f be 03             	movsbl (%ebx),%eax
  800533:	85 c0                	test   %eax,%eax
  800535:	74 05                	je     80053c <vprintfmt+0x25f>
  800537:	83 c3 01             	add    $0x1,%ebx
  80053a:	eb 29                	jmp    800565 <vprintfmt+0x288>
  80053c:	89 fe                	mov    %edi,%esi
  80053e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800541:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800544:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800548:	7f 2e                	jg     800578 <vprintfmt+0x29b>
  80054a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80054d:	e9 b7 fd ff ff       	jmp    800309 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800552:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800555:	83 c2 01             	add    $0x1,%edx
  800558:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80055b:	89 f7                	mov    %esi,%edi
  80055d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800560:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800563:	89 d3                	mov    %edx,%ebx
  800565:	85 f6                	test   %esi,%esi
  800567:	78 99                	js     800502 <vprintfmt+0x225>
  800569:	83 ee 01             	sub    $0x1,%esi
  80056c:	79 94                	jns    800502 <vprintfmt+0x225>
  80056e:	89 fe                	mov    %edi,%esi
  800570:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800573:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800576:	eb cc                	jmp    800544 <vprintfmt+0x267>
  800578:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80057b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80057e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800582:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800589:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80058b:	83 eb 01             	sub    $0x1,%ebx
  80058e:	85 db                	test   %ebx,%ebx
  800590:	7f ec                	jg     80057e <vprintfmt+0x2a1>
  800592:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800595:	e9 6f fd ff ff       	jmp    800309 <vprintfmt+0x2c>
  80059a:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80059d:	83 f9 01             	cmp    $0x1,%ecx
  8005a0:	7e 16                	jle    8005b8 <vprintfmt+0x2db>
		return va_arg(*ap, long long);
  8005a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a5:	8d 50 08             	lea    0x8(%eax),%edx
  8005a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ab:	8b 10                	mov    (%eax),%edx
  8005ad:	8b 48 04             	mov    0x4(%eax),%ecx
  8005b0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005b3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005b6:	eb 32                	jmp    8005ea <vprintfmt+0x30d>
	else if (lflag)
  8005b8:	85 c9                	test   %ecx,%ecx
  8005ba:	74 18                	je     8005d4 <vprintfmt+0x2f7>
		return va_arg(*ap, long);
  8005bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005bf:	8d 50 04             	lea    0x4(%eax),%edx
  8005c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005c5:	8b 00                	mov    (%eax),%eax
  8005c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005ca:	89 c1                	mov    %eax,%ecx
  8005cc:	c1 f9 1f             	sar    $0x1f,%ecx
  8005cf:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005d2:	eb 16                	jmp    8005ea <vprintfmt+0x30d>
	else
		return va_arg(*ap, int);
  8005d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005d7:	8d 50 04             	lea    0x4(%eax),%edx
  8005da:	89 55 14             	mov    %edx,0x14(%ebp)
  8005dd:	8b 00                	mov    (%eax),%eax
  8005df:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005e2:	89 c2                	mov    %eax,%edx
  8005e4:	c1 fa 1f             	sar    $0x1f,%edx
  8005e7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005ea:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005ed:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005f0:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005f5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005f9:	0f 89 b8 00 00 00    	jns    8006b7 <vprintfmt+0x3da>
				putch('-', putdat);
  8005ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800603:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80060a:	ff d7                	call   *%edi
				num = -(long long) num;
  80060c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80060f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800612:	f7 d9                	neg    %ecx
  800614:	83 d3 00             	adc    $0x0,%ebx
  800617:	f7 db                	neg    %ebx
  800619:	b8 0a 00 00 00       	mov    $0xa,%eax
  80061e:	e9 94 00 00 00       	jmp    8006b7 <vprintfmt+0x3da>
  800623:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800626:	89 ca                	mov    %ecx,%edx
  800628:	8d 45 14             	lea    0x14(%ebp),%eax
  80062b:	e8 56 fc ff ff       	call   800286 <getuint>
  800630:	89 c1                	mov    %eax,%ecx
  800632:	89 d3                	mov    %edx,%ebx
  800634:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800639:	eb 7c                	jmp    8006b7 <vprintfmt+0x3da>
  80063b:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80063e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800642:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800649:	ff d7                	call   *%edi
			putch('X', putdat);
  80064b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80064f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800656:	ff d7                	call   *%edi
			putch('X', putdat);
  800658:	89 74 24 04          	mov    %esi,0x4(%esp)
  80065c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800663:	ff d7                	call   *%edi
  800665:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800668:	e9 9c fc ff ff       	jmp    800309 <vprintfmt+0x2c>
  80066d:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800670:	89 74 24 04          	mov    %esi,0x4(%esp)
  800674:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80067b:	ff d7                	call   *%edi
			putch('x', putdat);
  80067d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800681:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800688:	ff d7                	call   *%edi
			num = (unsigned long long)
  80068a:	8b 45 14             	mov    0x14(%ebp),%eax
  80068d:	8d 50 04             	lea    0x4(%eax),%edx
  800690:	89 55 14             	mov    %edx,0x14(%ebp)
  800693:	8b 08                	mov    (%eax),%ecx
  800695:	bb 00 00 00 00       	mov    $0x0,%ebx
  80069a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80069f:	eb 16                	jmp    8006b7 <vprintfmt+0x3da>
  8006a1:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006a4:	89 ca                	mov    %ecx,%edx
  8006a6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a9:	e8 d8 fb ff ff       	call   800286 <getuint>
  8006ae:	89 c1                	mov    %eax,%ecx
  8006b0:	89 d3                	mov    %edx,%ebx
  8006b2:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006b7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006bb:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006bf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006c2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ca:	89 0c 24             	mov    %ecx,(%esp)
  8006cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006d1:	89 f2                	mov    %esi,%edx
  8006d3:	89 f8                	mov    %edi,%eax
  8006d5:	e8 b6 fa ff ff       	call   800190 <printnum>
  8006da:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8006dd:	e9 27 fc ff ff       	jmp    800309 <vprintfmt+0x2c>
  8006e2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006e5:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006e8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ec:	89 14 24             	mov    %edx,(%esp)
  8006ef:	ff d7                	call   *%edi
  8006f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8006f4:	e9 10 fc ff ff       	jmp    800309 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006fd:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800704:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800706:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800709:	80 38 25             	cmpb   $0x25,(%eax)
  80070c:	0f 84 f7 fb ff ff    	je     800309 <vprintfmt+0x2c>
  800712:	89 c3                	mov    %eax,%ebx
  800714:	eb f0                	jmp    800706 <vprintfmt+0x429>
				/* do nothing */;
			break;
		}
	}
}
  800716:	83 c4 5c             	add    $0x5c,%esp
  800719:	5b                   	pop    %ebx
  80071a:	5e                   	pop    %esi
  80071b:	5f                   	pop    %edi
  80071c:	5d                   	pop    %ebp
  80071d:	c3                   	ret    

0080071e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80071e:	55                   	push   %ebp
  80071f:	89 e5                	mov    %esp,%ebp
  800721:	83 ec 28             	sub    $0x28,%esp
  800724:	8b 45 08             	mov    0x8(%ebp),%eax
  800727:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80072a:	85 c0                	test   %eax,%eax
  80072c:	74 04                	je     800732 <vsnprintf+0x14>
  80072e:	85 d2                	test   %edx,%edx
  800730:	7f 07                	jg     800739 <vsnprintf+0x1b>
  800732:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800737:	eb 3b                	jmp    800774 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800739:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80073c:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800740:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800743:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80074a:	8b 45 14             	mov    0x14(%ebp),%eax
  80074d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800751:	8b 45 10             	mov    0x10(%ebp),%eax
  800754:	89 44 24 08          	mov    %eax,0x8(%esp)
  800758:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80075b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80075f:	c7 04 24 c0 02 80 00 	movl   $0x8002c0,(%esp)
  800766:	e8 72 fb ff ff       	call   8002dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80076b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80076e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800771:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800774:	c9                   	leave  
  800775:	c3                   	ret    

00800776 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800776:	55                   	push   %ebp
  800777:	89 e5                	mov    %esp,%ebp
  800779:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80077c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80077f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800783:	8b 45 10             	mov    0x10(%ebp),%eax
  800786:	89 44 24 08          	mov    %eax,0x8(%esp)
  80078a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80078d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800791:	8b 45 08             	mov    0x8(%ebp),%eax
  800794:	89 04 24             	mov    %eax,(%esp)
  800797:	e8 82 ff ff ff       	call   80071e <vsnprintf>
	va_end(ap);

	return rc;
}
  80079c:	c9                   	leave  
  80079d:	c3                   	ret    

0080079e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80079e:	55                   	push   %ebp
  80079f:	89 e5                	mov    %esp,%ebp
  8007a1:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8007a4:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8007a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ae:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007b5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007bc:	89 04 24             	mov    %eax,(%esp)
  8007bf:	e8 19 fb ff ff       	call   8002dd <vprintfmt>
	va_end(ap);
}
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    
  8007c6:	66 90                	xchg   %ax,%ax
  8007c8:	66 90                	xchg   %ax,%ax
  8007ca:	66 90                	xchg   %ax,%ax
  8007cc:	66 90                	xchg   %ax,%ax
  8007ce:	66 90                	xchg   %ax,%ax

008007d0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007d0:	55                   	push   %ebp
  8007d1:	89 e5                	mov    %esp,%ebp
  8007d3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007db:	80 3a 00             	cmpb   $0x0,(%edx)
  8007de:	74 09                	je     8007e9 <strlen+0x19>
		n++;
  8007e0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007e3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007e7:	75 f7                	jne    8007e0 <strlen+0x10>
		n++;
	return n;
}
  8007e9:	5d                   	pop    %ebp
  8007ea:	c3                   	ret    

008007eb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007eb:	55                   	push   %ebp
  8007ec:	89 e5                	mov    %esp,%ebp
  8007ee:	53                   	push   %ebx
  8007ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f5:	85 c9                	test   %ecx,%ecx
  8007f7:	74 19                	je     800812 <strnlen+0x27>
  8007f9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007fc:	74 14                	je     800812 <strnlen+0x27>
  8007fe:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800803:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800806:	39 c8                	cmp    %ecx,%eax
  800808:	74 0d                	je     800817 <strnlen+0x2c>
  80080a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80080e:	75 f3                	jne    800803 <strnlen+0x18>
  800810:	eb 05                	jmp    800817 <strnlen+0x2c>
  800812:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800817:	5b                   	pop    %ebx
  800818:	5d                   	pop    %ebp
  800819:	c3                   	ret    

0080081a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80081a:	55                   	push   %ebp
  80081b:	89 e5                	mov    %esp,%ebp
  80081d:	53                   	push   %ebx
  80081e:	8b 45 08             	mov    0x8(%ebp),%eax
  800821:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800824:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800829:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80082d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800830:	83 c2 01             	add    $0x1,%edx
  800833:	84 c9                	test   %cl,%cl
  800835:	75 f2                	jne    800829 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800837:	5b                   	pop    %ebx
  800838:	5d                   	pop    %ebp
  800839:	c3                   	ret    

0080083a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80083a:	55                   	push   %ebp
  80083b:	89 e5                	mov    %esp,%ebp
  80083d:	53                   	push   %ebx
  80083e:	83 ec 08             	sub    $0x8,%esp
  800841:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800844:	89 1c 24             	mov    %ebx,(%esp)
  800847:	e8 84 ff ff ff       	call   8007d0 <strlen>
	strcpy(dst + len, src);
  80084c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80084f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800853:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800856:	89 04 24             	mov    %eax,(%esp)
  800859:	e8 bc ff ff ff       	call   80081a <strcpy>
	return dst;
}
  80085e:	89 d8                	mov    %ebx,%eax
  800860:	83 c4 08             	add    $0x8,%esp
  800863:	5b                   	pop    %ebx
  800864:	5d                   	pop    %ebp
  800865:	c3                   	ret    

00800866 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	56                   	push   %esi
  80086a:	53                   	push   %ebx
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800871:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800874:	85 f6                	test   %esi,%esi
  800876:	74 18                	je     800890 <strncpy+0x2a>
  800878:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80087d:	0f b6 1a             	movzbl (%edx),%ebx
  800880:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800883:	80 3a 01             	cmpb   $0x1,(%edx)
  800886:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800889:	83 c1 01             	add    $0x1,%ecx
  80088c:	39 ce                	cmp    %ecx,%esi
  80088e:	77 ed                	ja     80087d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800890:	5b                   	pop    %ebx
  800891:	5e                   	pop    %esi
  800892:	5d                   	pop    %ebp
  800893:	c3                   	ret    

00800894 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800894:	55                   	push   %ebp
  800895:	89 e5                	mov    %esp,%ebp
  800897:	56                   	push   %esi
  800898:	53                   	push   %ebx
  800899:	8b 75 08             	mov    0x8(%ebp),%esi
  80089c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008a2:	89 f0                	mov    %esi,%eax
  8008a4:	85 c9                	test   %ecx,%ecx
  8008a6:	74 27                	je     8008cf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8008a8:	83 e9 01             	sub    $0x1,%ecx
  8008ab:	74 1d                	je     8008ca <strlcpy+0x36>
  8008ad:	0f b6 1a             	movzbl (%edx),%ebx
  8008b0:	84 db                	test   %bl,%bl
  8008b2:	74 16                	je     8008ca <strlcpy+0x36>
			*dst++ = *src++;
  8008b4:	88 18                	mov    %bl,(%eax)
  8008b6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008b9:	83 e9 01             	sub    $0x1,%ecx
  8008bc:	74 0e                	je     8008cc <strlcpy+0x38>
			*dst++ = *src++;
  8008be:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008c1:	0f b6 1a             	movzbl (%edx),%ebx
  8008c4:	84 db                	test   %bl,%bl
  8008c6:	75 ec                	jne    8008b4 <strlcpy+0x20>
  8008c8:	eb 02                	jmp    8008cc <strlcpy+0x38>
  8008ca:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008cc:	c6 00 00             	movb   $0x0,(%eax)
  8008cf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8008d1:	5b                   	pop    %ebx
  8008d2:	5e                   	pop    %esi
  8008d3:	5d                   	pop    %ebp
  8008d4:	c3                   	ret    

008008d5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008d5:	55                   	push   %ebp
  8008d6:	89 e5                	mov    %esp,%ebp
  8008d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008db:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008de:	0f b6 01             	movzbl (%ecx),%eax
  8008e1:	84 c0                	test   %al,%al
  8008e3:	74 15                	je     8008fa <strcmp+0x25>
  8008e5:	3a 02                	cmp    (%edx),%al
  8008e7:	75 11                	jne    8008fa <strcmp+0x25>
		p++, q++;
  8008e9:	83 c1 01             	add    $0x1,%ecx
  8008ec:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008ef:	0f b6 01             	movzbl (%ecx),%eax
  8008f2:	84 c0                	test   %al,%al
  8008f4:	74 04                	je     8008fa <strcmp+0x25>
  8008f6:	3a 02                	cmp    (%edx),%al
  8008f8:	74 ef                	je     8008e9 <strcmp+0x14>
  8008fa:	0f b6 c0             	movzbl %al,%eax
  8008fd:	0f b6 12             	movzbl (%edx),%edx
  800900:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800902:	5d                   	pop    %ebp
  800903:	c3                   	ret    

00800904 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800904:	55                   	push   %ebp
  800905:	89 e5                	mov    %esp,%ebp
  800907:	53                   	push   %ebx
  800908:	8b 55 08             	mov    0x8(%ebp),%edx
  80090b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80090e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800911:	85 c0                	test   %eax,%eax
  800913:	74 23                	je     800938 <strncmp+0x34>
  800915:	0f b6 1a             	movzbl (%edx),%ebx
  800918:	84 db                	test   %bl,%bl
  80091a:	74 25                	je     800941 <strncmp+0x3d>
  80091c:	3a 19                	cmp    (%ecx),%bl
  80091e:	75 21                	jne    800941 <strncmp+0x3d>
  800920:	83 e8 01             	sub    $0x1,%eax
  800923:	74 13                	je     800938 <strncmp+0x34>
		n--, p++, q++;
  800925:	83 c2 01             	add    $0x1,%edx
  800928:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80092b:	0f b6 1a             	movzbl (%edx),%ebx
  80092e:	84 db                	test   %bl,%bl
  800930:	74 0f                	je     800941 <strncmp+0x3d>
  800932:	3a 19                	cmp    (%ecx),%bl
  800934:	74 ea                	je     800920 <strncmp+0x1c>
  800936:	eb 09                	jmp    800941 <strncmp+0x3d>
  800938:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80093d:	5b                   	pop    %ebx
  80093e:	5d                   	pop    %ebp
  80093f:	90                   	nop
  800940:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800941:	0f b6 02             	movzbl (%edx),%eax
  800944:	0f b6 11             	movzbl (%ecx),%edx
  800947:	29 d0                	sub    %edx,%eax
  800949:	eb f2                	jmp    80093d <strncmp+0x39>

0080094b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800955:	0f b6 10             	movzbl (%eax),%edx
  800958:	84 d2                	test   %dl,%dl
  80095a:	74 18                	je     800974 <strchr+0x29>
		if (*s == c)
  80095c:	38 ca                	cmp    %cl,%dl
  80095e:	75 0a                	jne    80096a <strchr+0x1f>
  800960:	eb 17                	jmp    800979 <strchr+0x2e>
  800962:	38 ca                	cmp    %cl,%dl
  800964:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800968:	74 0f                	je     800979 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80096a:	83 c0 01             	add    $0x1,%eax
  80096d:	0f b6 10             	movzbl (%eax),%edx
  800970:	84 d2                	test   %dl,%dl
  800972:	75 ee                	jne    800962 <strchr+0x17>
  800974:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800979:	5d                   	pop    %ebp
  80097a:	c3                   	ret    

0080097b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80097b:	55                   	push   %ebp
  80097c:	89 e5                	mov    %esp,%ebp
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800985:	0f b6 10             	movzbl (%eax),%edx
  800988:	84 d2                	test   %dl,%dl
  80098a:	74 18                	je     8009a4 <strfind+0x29>
		if (*s == c)
  80098c:	38 ca                	cmp    %cl,%dl
  80098e:	75 0a                	jne    80099a <strfind+0x1f>
  800990:	eb 12                	jmp    8009a4 <strfind+0x29>
  800992:	38 ca                	cmp    %cl,%dl
  800994:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800998:	74 0a                	je     8009a4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80099a:	83 c0 01             	add    $0x1,%eax
  80099d:	0f b6 10             	movzbl (%eax),%edx
  8009a0:	84 d2                	test   %dl,%dl
  8009a2:	75 ee                	jne    800992 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	83 ec 0c             	sub    $0xc,%esp
  8009ac:	89 1c 24             	mov    %ebx,(%esp)
  8009af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009b3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8009b7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009c0:	85 c9                	test   %ecx,%ecx
  8009c2:	74 30                	je     8009f4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009c4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ca:	75 25                	jne    8009f1 <memset+0x4b>
  8009cc:	f6 c1 03             	test   $0x3,%cl
  8009cf:	75 20                	jne    8009f1 <memset+0x4b>
		c &= 0xFF;
  8009d1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009d4:	89 d3                	mov    %edx,%ebx
  8009d6:	c1 e3 08             	shl    $0x8,%ebx
  8009d9:	89 d6                	mov    %edx,%esi
  8009db:	c1 e6 18             	shl    $0x18,%esi
  8009de:	89 d0                	mov    %edx,%eax
  8009e0:	c1 e0 10             	shl    $0x10,%eax
  8009e3:	09 f0                	or     %esi,%eax
  8009e5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  8009e7:	09 d8                	or     %ebx,%eax
  8009e9:	c1 e9 02             	shr    $0x2,%ecx
  8009ec:	fc                   	cld    
  8009ed:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009ef:	eb 03                	jmp    8009f4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009f1:	fc                   	cld    
  8009f2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009f4:	89 f8                	mov    %edi,%eax
  8009f6:	8b 1c 24             	mov    (%esp),%ebx
  8009f9:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009fd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a01:	89 ec                	mov    %ebp,%esp
  800a03:	5d                   	pop    %ebp
  800a04:	c3                   	ret    

00800a05 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a05:	55                   	push   %ebp
  800a06:	89 e5                	mov    %esp,%ebp
  800a08:	83 ec 08             	sub    $0x8,%esp
  800a0b:	89 34 24             	mov    %esi,(%esp)
  800a0e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a12:	8b 45 08             	mov    0x8(%ebp),%eax
  800a15:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800a18:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a1b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a1d:	39 c6                	cmp    %eax,%esi
  800a1f:	73 35                	jae    800a56 <memmove+0x51>
  800a21:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a24:	39 d0                	cmp    %edx,%eax
  800a26:	73 2e                	jae    800a56 <memmove+0x51>
		s += n;
		d += n;
  800a28:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a2a:	f6 c2 03             	test   $0x3,%dl
  800a2d:	75 1b                	jne    800a4a <memmove+0x45>
  800a2f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a35:	75 13                	jne    800a4a <memmove+0x45>
  800a37:	f6 c1 03             	test   $0x3,%cl
  800a3a:	75 0e                	jne    800a4a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a3c:	83 ef 04             	sub    $0x4,%edi
  800a3f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a42:	c1 e9 02             	shr    $0x2,%ecx
  800a45:	fd                   	std    
  800a46:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a48:	eb 09                	jmp    800a53 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a4a:	83 ef 01             	sub    $0x1,%edi
  800a4d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a50:	fd                   	std    
  800a51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a53:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a54:	eb 20                	jmp    800a76 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a56:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a5c:	75 15                	jne    800a73 <memmove+0x6e>
  800a5e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a64:	75 0d                	jne    800a73 <memmove+0x6e>
  800a66:	f6 c1 03             	test   $0x3,%cl
  800a69:	75 08                	jne    800a73 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800a6b:	c1 e9 02             	shr    $0x2,%ecx
  800a6e:	fc                   	cld    
  800a6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a71:	eb 03                	jmp    800a76 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a73:	fc                   	cld    
  800a74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a76:	8b 34 24             	mov    (%esp),%esi
  800a79:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a7d:	89 ec                	mov    %ebp,%esp
  800a7f:	5d                   	pop    %ebp
  800a80:	c3                   	ret    

00800a81 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a87:	8b 45 10             	mov    0x10(%ebp),%eax
  800a8a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a91:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a95:	8b 45 08             	mov    0x8(%ebp),%eax
  800a98:	89 04 24             	mov    %eax,(%esp)
  800a9b:	e8 65 ff ff ff       	call   800a05 <memmove>
}
  800aa0:	c9                   	leave  
  800aa1:	c3                   	ret    

00800aa2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800aa2:	55                   	push   %ebp
  800aa3:	89 e5                	mov    %esp,%ebp
  800aa5:	57                   	push   %edi
  800aa6:	56                   	push   %esi
  800aa7:	53                   	push   %ebx
  800aa8:	8b 75 08             	mov    0x8(%ebp),%esi
  800aab:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800aae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ab1:	85 c9                	test   %ecx,%ecx
  800ab3:	74 36                	je     800aeb <memcmp+0x49>
		if (*s1 != *s2)
  800ab5:	0f b6 06             	movzbl (%esi),%eax
  800ab8:	0f b6 1f             	movzbl (%edi),%ebx
  800abb:	38 d8                	cmp    %bl,%al
  800abd:	74 20                	je     800adf <memcmp+0x3d>
  800abf:	eb 14                	jmp    800ad5 <memcmp+0x33>
  800ac1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800ac6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800acb:	83 c2 01             	add    $0x1,%edx
  800ace:	83 e9 01             	sub    $0x1,%ecx
  800ad1:	38 d8                	cmp    %bl,%al
  800ad3:	74 12                	je     800ae7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800ad5:	0f b6 c0             	movzbl %al,%eax
  800ad8:	0f b6 db             	movzbl %bl,%ebx
  800adb:	29 d8                	sub    %ebx,%eax
  800add:	eb 11                	jmp    800af0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800adf:	83 e9 01             	sub    $0x1,%ecx
  800ae2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ae7:	85 c9                	test   %ecx,%ecx
  800ae9:	75 d6                	jne    800ac1 <memcmp+0x1f>
  800aeb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800af0:	5b                   	pop    %ebx
  800af1:	5e                   	pop    %esi
  800af2:	5f                   	pop    %edi
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800afb:	89 c2                	mov    %eax,%edx
  800afd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b00:	39 d0                	cmp    %edx,%eax
  800b02:	73 15                	jae    800b19 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b04:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b08:	38 08                	cmp    %cl,(%eax)
  800b0a:	75 06                	jne    800b12 <memfind+0x1d>
  800b0c:	eb 0b                	jmp    800b19 <memfind+0x24>
  800b0e:	38 08                	cmp    %cl,(%eax)
  800b10:	74 07                	je     800b19 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b12:	83 c0 01             	add    $0x1,%eax
  800b15:	39 c2                	cmp    %eax,%edx
  800b17:	77 f5                	ja     800b0e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b19:	5d                   	pop    %ebp
  800b1a:	c3                   	ret    

00800b1b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b1b:	55                   	push   %ebp
  800b1c:	89 e5                	mov    %esp,%ebp
  800b1e:	57                   	push   %edi
  800b1f:	56                   	push   %esi
  800b20:	53                   	push   %ebx
  800b21:	83 ec 04             	sub    $0x4,%esp
  800b24:	8b 55 08             	mov    0x8(%ebp),%edx
  800b27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b2a:	0f b6 02             	movzbl (%edx),%eax
  800b2d:	3c 20                	cmp    $0x20,%al
  800b2f:	74 04                	je     800b35 <strtol+0x1a>
  800b31:	3c 09                	cmp    $0x9,%al
  800b33:	75 0e                	jne    800b43 <strtol+0x28>
		s++;
  800b35:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b38:	0f b6 02             	movzbl (%edx),%eax
  800b3b:	3c 20                	cmp    $0x20,%al
  800b3d:	74 f6                	je     800b35 <strtol+0x1a>
  800b3f:	3c 09                	cmp    $0x9,%al
  800b41:	74 f2                	je     800b35 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b43:	3c 2b                	cmp    $0x2b,%al
  800b45:	75 0c                	jne    800b53 <strtol+0x38>
		s++;
  800b47:	83 c2 01             	add    $0x1,%edx
  800b4a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b51:	eb 15                	jmp    800b68 <strtol+0x4d>
	else if (*s == '-')
  800b53:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b5a:	3c 2d                	cmp    $0x2d,%al
  800b5c:	75 0a                	jne    800b68 <strtol+0x4d>
		s++, neg = 1;
  800b5e:	83 c2 01             	add    $0x1,%edx
  800b61:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b68:	85 db                	test   %ebx,%ebx
  800b6a:	0f 94 c0             	sete   %al
  800b6d:	74 05                	je     800b74 <strtol+0x59>
  800b6f:	83 fb 10             	cmp    $0x10,%ebx
  800b72:	75 18                	jne    800b8c <strtol+0x71>
  800b74:	80 3a 30             	cmpb   $0x30,(%edx)
  800b77:	75 13                	jne    800b8c <strtol+0x71>
  800b79:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b7d:	8d 76 00             	lea    0x0(%esi),%esi
  800b80:	75 0a                	jne    800b8c <strtol+0x71>
		s += 2, base = 16;
  800b82:	83 c2 02             	add    $0x2,%edx
  800b85:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b8a:	eb 15                	jmp    800ba1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b8c:	84 c0                	test   %al,%al
  800b8e:	66 90                	xchg   %ax,%ax
  800b90:	74 0f                	je     800ba1 <strtol+0x86>
  800b92:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b97:	80 3a 30             	cmpb   $0x30,(%edx)
  800b9a:	75 05                	jne    800ba1 <strtol+0x86>
		s++, base = 8;
  800b9c:	83 c2 01             	add    $0x1,%edx
  800b9f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ba1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ba8:	0f b6 0a             	movzbl (%edx),%ecx
  800bab:	89 cf                	mov    %ecx,%edi
  800bad:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bb0:	80 fb 09             	cmp    $0x9,%bl
  800bb3:	77 08                	ja     800bbd <strtol+0xa2>
			dig = *s - '0';
  800bb5:	0f be c9             	movsbl %cl,%ecx
  800bb8:	83 e9 30             	sub    $0x30,%ecx
  800bbb:	eb 1e                	jmp    800bdb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800bbd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800bc0:	80 fb 19             	cmp    $0x19,%bl
  800bc3:	77 08                	ja     800bcd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800bc5:	0f be c9             	movsbl %cl,%ecx
  800bc8:	83 e9 57             	sub    $0x57,%ecx
  800bcb:	eb 0e                	jmp    800bdb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800bcd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800bd0:	80 fb 19             	cmp    $0x19,%bl
  800bd3:	77 15                	ja     800bea <strtol+0xcf>
			dig = *s - 'A' + 10;
  800bd5:	0f be c9             	movsbl %cl,%ecx
  800bd8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bdb:	39 f1                	cmp    %esi,%ecx
  800bdd:	7d 0b                	jge    800bea <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800bdf:	83 c2 01             	add    $0x1,%edx
  800be2:	0f af c6             	imul   %esi,%eax
  800be5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800be8:	eb be                	jmp    800ba8 <strtol+0x8d>
  800bea:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800bec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bf0:	74 05                	je     800bf7 <strtol+0xdc>
		*endptr = (char *) s;
  800bf2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bf5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800bf7:	89 ca                	mov    %ecx,%edx
  800bf9:	f7 da                	neg    %edx
  800bfb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800bff:	0f 45 c2             	cmovne %edx,%eax
}
  800c02:	83 c4 04             	add    $0x4,%esp
  800c05:	5b                   	pop    %ebx
  800c06:	5e                   	pop    %esi
  800c07:	5f                   	pop    %edi
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	83 ec 0c             	sub    $0xc,%esp
  800c10:	89 1c 24             	mov    %ebx,(%esp)
  800c13:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c17:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c20:	b8 01 00 00 00       	mov    $0x1,%eax
  800c25:	89 d1                	mov    %edx,%ecx
  800c27:	89 d3                	mov    %edx,%ebx
  800c29:	89 d7                	mov    %edx,%edi
  800c2b:	89 d6                	mov    %edx,%esi
  800c2d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c2f:	8b 1c 24             	mov    (%esp),%ebx
  800c32:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c36:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c3a:	89 ec                	mov    %ebp,%esp
  800c3c:	5d                   	pop    %ebp
  800c3d:	c3                   	ret    

00800c3e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	83 ec 0c             	sub    $0xc,%esp
  800c44:	89 1c 24             	mov    %ebx,(%esp)
  800c47:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c4b:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c4f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c54:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c57:	8b 55 08             	mov    0x8(%ebp),%edx
  800c5a:	89 c3                	mov    %eax,%ebx
  800c5c:	89 c7                	mov    %eax,%edi
  800c5e:	89 c6                	mov    %eax,%esi
  800c60:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c62:	8b 1c 24             	mov    (%esp),%ebx
  800c65:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c69:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c6d:	89 ec                	mov    %ebp,%esp
  800c6f:	5d                   	pop    %ebp
  800c70:	c3                   	ret    

00800c71 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800c71:	55                   	push   %ebp
  800c72:	89 e5                	mov    %esp,%ebp
  800c74:	83 ec 38             	sub    $0x38,%esp
  800c77:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c7a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c7d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c80:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c85:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c8a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c8d:	89 cb                	mov    %ecx,%ebx
  800c8f:	89 cf                	mov    %ecx,%edi
  800c91:	89 ce                	mov    %ecx,%esi
  800c93:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c95:	85 c0                	test   %eax,%eax
  800c97:	7e 28                	jle    800cc1 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c99:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c9d:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ca4:	00 
  800ca5:	c7 44 24 08 e4 14 80 	movl   $0x8014e4,0x8(%esp)
  800cac:	00 
  800cad:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cb4:	00 
  800cb5:	c7 04 24 01 15 80 00 	movl   $0x801501,(%esp)
  800cbc:	e8 e1 02 00 00       	call   800fa2 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cc1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cc4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cc7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cca:	89 ec                	mov    %ebp,%esp
  800ccc:	5d                   	pop    %ebp
  800ccd:	c3                   	ret    

00800cce <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cce:	55                   	push   %ebp
  800ccf:	89 e5                	mov    %esp,%ebp
  800cd1:	83 ec 0c             	sub    $0xc,%esp
  800cd4:	89 1c 24             	mov    %ebx,(%esp)
  800cd7:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cdb:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cdf:	be 00 00 00 00       	mov    $0x0,%esi
  800ce4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ce9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf2:	8b 55 08             	mov    0x8(%ebp),%edx
  800cf5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800cf7:	8b 1c 24             	mov    (%esp),%ebx
  800cfa:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cfe:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d02:	89 ec                	mov    %ebp,%esp
  800d04:	5d                   	pop    %ebp
  800d05:	c3                   	ret    

00800d06 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d06:	55                   	push   %ebp
  800d07:	89 e5                	mov    %esp,%ebp
  800d09:	83 ec 38             	sub    $0x38,%esp
  800d0c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d0f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d12:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d15:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d1a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d22:	8b 55 08             	mov    0x8(%ebp),%edx
  800d25:	89 df                	mov    %ebx,%edi
  800d27:	89 de                	mov    %ebx,%esi
  800d29:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d2b:	85 c0                	test   %eax,%eax
  800d2d:	7e 28                	jle    800d57 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d2f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d33:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d3a:	00 
  800d3b:	c7 44 24 08 e4 14 80 	movl   $0x8014e4,0x8(%esp)
  800d42:	00 
  800d43:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d4a:	00 
  800d4b:	c7 04 24 01 15 80 00 	movl   $0x801501,(%esp)
  800d52:	e8 4b 02 00 00       	call   800fa2 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d57:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d5a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d5d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d60:	89 ec                	mov    %ebp,%esp
  800d62:	5d                   	pop    %ebp
  800d63:	c3                   	ret    

00800d64 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d64:	55                   	push   %ebp
  800d65:	89 e5                	mov    %esp,%ebp
  800d67:	83 ec 38             	sub    $0x38,%esp
  800d6a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d6d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d70:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d73:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d78:	b8 08 00 00 00       	mov    $0x8,%eax
  800d7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d80:	8b 55 08             	mov    0x8(%ebp),%edx
  800d83:	89 df                	mov    %ebx,%edi
  800d85:	89 de                	mov    %ebx,%esi
  800d87:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	7e 28                	jle    800db5 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d91:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d98:	00 
  800d99:	c7 44 24 08 e4 14 80 	movl   $0x8014e4,0x8(%esp)
  800da0:	00 
  800da1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da8:	00 
  800da9:	c7 04 24 01 15 80 00 	movl   $0x801501,(%esp)
  800db0:	e8 ed 01 00 00       	call   800fa2 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800db5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dbb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dbe:	89 ec                	mov    %ebp,%esp
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    

00800dc2 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800dc2:	55                   	push   %ebp
  800dc3:	89 e5                	mov    %esp,%ebp
  800dc5:	83 ec 38             	sub    $0x38,%esp
  800dc8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dcb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dce:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd6:	b8 06 00 00 00       	mov    $0x6,%eax
  800ddb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dde:	8b 55 08             	mov    0x8(%ebp),%edx
  800de1:	89 df                	mov    %ebx,%edi
  800de3:	89 de                	mov    %ebx,%esi
  800de5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de7:	85 c0                	test   %eax,%eax
  800de9:	7e 28                	jle    800e13 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800deb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800def:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800df6:	00 
  800df7:	c7 44 24 08 e4 14 80 	movl   $0x8014e4,0x8(%esp)
  800dfe:	00 
  800dff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e06:	00 
  800e07:	c7 04 24 01 15 80 00 	movl   $0x801501,(%esp)
  800e0e:	e8 8f 01 00 00       	call   800fa2 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e13:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e16:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e19:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e1c:	89 ec                	mov    %ebp,%esp
  800e1e:	5d                   	pop    %ebp
  800e1f:	c3                   	ret    

00800e20 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e20:	55                   	push   %ebp
  800e21:	89 e5                	mov    %esp,%ebp
  800e23:	83 ec 38             	sub    $0x38,%esp
  800e26:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e29:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e2c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e2f:	b8 05 00 00 00       	mov    $0x5,%eax
  800e34:	8b 75 18             	mov    0x18(%ebp),%esi
  800e37:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e3a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e3d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e40:	8b 55 08             	mov    0x8(%ebp),%edx
  800e43:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e45:	85 c0                	test   %eax,%eax
  800e47:	7e 28                	jle    800e71 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e49:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4d:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e54:	00 
  800e55:	c7 44 24 08 e4 14 80 	movl   $0x8014e4,0x8(%esp)
  800e5c:	00 
  800e5d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e64:	00 
  800e65:	c7 04 24 01 15 80 00 	movl   $0x801501,(%esp)
  800e6c:	e8 31 01 00 00       	call   800fa2 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e71:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e74:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e77:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e7a:	89 ec                	mov    %ebp,%esp
  800e7c:	5d                   	pop    %ebp
  800e7d:	c3                   	ret    

00800e7e <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	83 ec 38             	sub    $0x38,%esp
  800e84:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e87:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e8a:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8d:	be 00 00 00 00       	mov    $0x0,%esi
  800e92:	b8 04 00 00 00       	mov    $0x4,%eax
  800e97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e9d:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea0:	89 f7                	mov    %esi,%edi
  800ea2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ea4:	85 c0                	test   %eax,%eax
  800ea6:	7e 28                	jle    800ed0 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eac:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800eb3:	00 
  800eb4:	c7 44 24 08 e4 14 80 	movl   $0x8014e4,0x8(%esp)
  800ebb:	00 
  800ebc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec3:	00 
  800ec4:	c7 04 24 01 15 80 00 	movl   $0x801501,(%esp)
  800ecb:	e8 d2 00 00 00       	call   800fa2 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ed0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ed3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ed9:	89 ec                	mov    %ebp,%esp
  800edb:	5d                   	pop    %ebp
  800edc:	c3                   	ret    

00800edd <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	83 ec 0c             	sub    $0xc,%esp
  800ee3:	89 1c 24             	mov    %ebx,(%esp)
  800ee6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eea:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eee:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ef8:	89 d1                	mov    %edx,%ecx
  800efa:	89 d3                	mov    %edx,%ebx
  800efc:	89 d7                	mov    %edx,%edi
  800efe:	89 d6                	mov    %edx,%esi
  800f00:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f02:	8b 1c 24             	mov    (%esp),%ebx
  800f05:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f09:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f0d:	89 ec                	mov    %ebp,%esp
  800f0f:	5d                   	pop    %ebp
  800f10:	c3                   	ret    

00800f11 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f11:	55                   	push   %ebp
  800f12:	89 e5                	mov    %esp,%ebp
  800f14:	83 ec 0c             	sub    $0xc,%esp
  800f17:	89 1c 24             	mov    %ebx,(%esp)
  800f1a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f1e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f22:	ba 00 00 00 00       	mov    $0x0,%edx
  800f27:	b8 02 00 00 00       	mov    $0x2,%eax
  800f2c:	89 d1                	mov    %edx,%ecx
  800f2e:	89 d3                	mov    %edx,%ebx
  800f30:	89 d7                	mov    %edx,%edi
  800f32:	89 d6                	mov    %edx,%esi
  800f34:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f36:	8b 1c 24             	mov    (%esp),%ebx
  800f39:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f3d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f41:	89 ec                	mov    %ebp,%esp
  800f43:	5d                   	pop    %ebp
  800f44:	c3                   	ret    

00800f45 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f45:	55                   	push   %ebp
  800f46:	89 e5                	mov    %esp,%ebp
  800f48:	83 ec 38             	sub    $0x38,%esp
  800f4b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f4e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f51:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f54:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f59:	b8 03 00 00 00       	mov    $0x3,%eax
  800f5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f61:	89 cb                	mov    %ecx,%ebx
  800f63:	89 cf                	mov    %ecx,%edi
  800f65:	89 ce                	mov    %ecx,%esi
  800f67:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f69:	85 c0                	test   %eax,%eax
  800f6b:	7e 28                	jle    800f95 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f71:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f78:	00 
  800f79:	c7 44 24 08 e4 14 80 	movl   $0x8014e4,0x8(%esp)
  800f80:	00 
  800f81:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f88:	00 
  800f89:	c7 04 24 01 15 80 00 	movl   $0x801501,(%esp)
  800f90:	e8 0d 00 00 00       	call   800fa2 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f95:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f98:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f9b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f9e:	89 ec                	mov    %ebp,%esp
  800fa0:	5d                   	pop    %ebp
  800fa1:	c3                   	ret    

00800fa2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	56                   	push   %esi
  800fa6:	53                   	push   %ebx
  800fa7:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800faa:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fad:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800fb3:	e8 59 ff ff ff       	call   800f11 <sys_getenvid>
  800fb8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fbb:	89 54 24 10          	mov    %edx,0x10(%esp)
  800fbf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fc6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fca:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fce:	c7 04 24 10 15 80 00 	movl   $0x801510,(%esp)
  800fd5:	e8 5a f1 ff ff       	call   800134 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fda:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fde:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe1:	89 04 24             	mov    %eax,(%esp)
  800fe4:	e8 ea f0 ff ff       	call   8000d3 <vcprintf>
	cprintf("\n");
  800fe9:	c7 04 24 8c 12 80 00 	movl   $0x80128c,(%esp)
  800ff0:	e8 3f f1 ff ff       	call   800134 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800ff5:	cc                   	int3   
  800ff6:	eb fd                	jmp    800ff5 <_panic+0x53>
  800ff8:	66 90                	xchg   %ax,%ax
  800ffa:	66 90                	xchg   %ax,%ax
  800ffc:	66 90                	xchg   %ax,%ax
  800ffe:	66 90                	xchg   %ax,%ax

00801000 <__udivdi3>:
  801000:	55                   	push   %ebp
  801001:	89 e5                	mov    %esp,%ebp
  801003:	57                   	push   %edi
  801004:	56                   	push   %esi
  801005:	83 ec 10             	sub    $0x10,%esp
  801008:	8b 45 14             	mov    0x14(%ebp),%eax
  80100b:	8b 55 08             	mov    0x8(%ebp),%edx
  80100e:	8b 75 10             	mov    0x10(%ebp),%esi
  801011:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801014:	85 c0                	test   %eax,%eax
  801016:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801019:	75 35                	jne    801050 <__udivdi3+0x50>
  80101b:	39 fe                	cmp    %edi,%esi
  80101d:	77 61                	ja     801080 <__udivdi3+0x80>
  80101f:	85 f6                	test   %esi,%esi
  801021:	75 0b                	jne    80102e <__udivdi3+0x2e>
  801023:	b8 01 00 00 00       	mov    $0x1,%eax
  801028:	31 d2                	xor    %edx,%edx
  80102a:	f7 f6                	div    %esi
  80102c:	89 c6                	mov    %eax,%esi
  80102e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801031:	31 d2                	xor    %edx,%edx
  801033:	89 f8                	mov    %edi,%eax
  801035:	f7 f6                	div    %esi
  801037:	89 c7                	mov    %eax,%edi
  801039:	89 c8                	mov    %ecx,%eax
  80103b:	f7 f6                	div    %esi
  80103d:	89 c1                	mov    %eax,%ecx
  80103f:	89 fa                	mov    %edi,%edx
  801041:	89 c8                	mov    %ecx,%eax
  801043:	83 c4 10             	add    $0x10,%esp
  801046:	5e                   	pop    %esi
  801047:	5f                   	pop    %edi
  801048:	5d                   	pop    %ebp
  801049:	c3                   	ret    
  80104a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801050:	39 f8                	cmp    %edi,%eax
  801052:	77 1c                	ja     801070 <__udivdi3+0x70>
  801054:	0f bd d0             	bsr    %eax,%edx
  801057:	83 f2 1f             	xor    $0x1f,%edx
  80105a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80105d:	75 39                	jne    801098 <__udivdi3+0x98>
  80105f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801062:	0f 86 a0 00 00 00    	jbe    801108 <__udivdi3+0x108>
  801068:	39 f8                	cmp    %edi,%eax
  80106a:	0f 82 98 00 00 00    	jb     801108 <__udivdi3+0x108>
  801070:	31 ff                	xor    %edi,%edi
  801072:	31 c9                	xor    %ecx,%ecx
  801074:	89 c8                	mov    %ecx,%eax
  801076:	89 fa                	mov    %edi,%edx
  801078:	83 c4 10             	add    $0x10,%esp
  80107b:	5e                   	pop    %esi
  80107c:	5f                   	pop    %edi
  80107d:	5d                   	pop    %ebp
  80107e:	c3                   	ret    
  80107f:	90                   	nop
  801080:	89 d1                	mov    %edx,%ecx
  801082:	89 fa                	mov    %edi,%edx
  801084:	89 c8                	mov    %ecx,%eax
  801086:	31 ff                	xor    %edi,%edi
  801088:	f7 f6                	div    %esi
  80108a:	89 c1                	mov    %eax,%ecx
  80108c:	89 fa                	mov    %edi,%edx
  80108e:	89 c8                	mov    %ecx,%eax
  801090:	83 c4 10             	add    $0x10,%esp
  801093:	5e                   	pop    %esi
  801094:	5f                   	pop    %edi
  801095:	5d                   	pop    %ebp
  801096:	c3                   	ret    
  801097:	90                   	nop
  801098:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80109c:	89 f2                	mov    %esi,%edx
  80109e:	d3 e0                	shl    %cl,%eax
  8010a0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8010a3:	b8 20 00 00 00       	mov    $0x20,%eax
  8010a8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8010ab:	89 c1                	mov    %eax,%ecx
  8010ad:	d3 ea                	shr    %cl,%edx
  8010af:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010b3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8010b6:	d3 e6                	shl    %cl,%esi
  8010b8:	89 c1                	mov    %eax,%ecx
  8010ba:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8010bd:	89 fe                	mov    %edi,%esi
  8010bf:	d3 ee                	shr    %cl,%esi
  8010c1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010c5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010cb:	d3 e7                	shl    %cl,%edi
  8010cd:	89 c1                	mov    %eax,%ecx
  8010cf:	d3 ea                	shr    %cl,%edx
  8010d1:	09 d7                	or     %edx,%edi
  8010d3:	89 f2                	mov    %esi,%edx
  8010d5:	89 f8                	mov    %edi,%eax
  8010d7:	f7 75 ec             	divl   -0x14(%ebp)
  8010da:	89 d6                	mov    %edx,%esi
  8010dc:	89 c7                	mov    %eax,%edi
  8010de:	f7 65 e8             	mull   -0x18(%ebp)
  8010e1:	39 d6                	cmp    %edx,%esi
  8010e3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010e6:	72 30                	jb     801118 <__udivdi3+0x118>
  8010e8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010eb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010ef:	d3 e2                	shl    %cl,%edx
  8010f1:	39 c2                	cmp    %eax,%edx
  8010f3:	73 05                	jae    8010fa <__udivdi3+0xfa>
  8010f5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8010f8:	74 1e                	je     801118 <__udivdi3+0x118>
  8010fa:	89 f9                	mov    %edi,%ecx
  8010fc:	31 ff                	xor    %edi,%edi
  8010fe:	e9 71 ff ff ff       	jmp    801074 <__udivdi3+0x74>
  801103:	90                   	nop
  801104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801108:	31 ff                	xor    %edi,%edi
  80110a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80110f:	e9 60 ff ff ff       	jmp    801074 <__udivdi3+0x74>
  801114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801118:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80111b:	31 ff                	xor    %edi,%edi
  80111d:	89 c8                	mov    %ecx,%eax
  80111f:	89 fa                	mov    %edi,%edx
  801121:	83 c4 10             	add    $0x10,%esp
  801124:	5e                   	pop    %esi
  801125:	5f                   	pop    %edi
  801126:	5d                   	pop    %ebp
  801127:	c3                   	ret    
  801128:	66 90                	xchg   %ax,%ax
  80112a:	66 90                	xchg   %ax,%ax
  80112c:	66 90                	xchg   %ax,%ax
  80112e:	66 90                	xchg   %ax,%ax

00801130 <__umoddi3>:
  801130:	55                   	push   %ebp
  801131:	89 e5                	mov    %esp,%ebp
  801133:	57                   	push   %edi
  801134:	56                   	push   %esi
  801135:	83 ec 20             	sub    $0x20,%esp
  801138:	8b 55 14             	mov    0x14(%ebp),%edx
  80113b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80113e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801141:	8b 75 0c             	mov    0xc(%ebp),%esi
  801144:	85 d2                	test   %edx,%edx
  801146:	89 c8                	mov    %ecx,%eax
  801148:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80114b:	75 13                	jne    801160 <__umoddi3+0x30>
  80114d:	39 f7                	cmp    %esi,%edi
  80114f:	76 3f                	jbe    801190 <__umoddi3+0x60>
  801151:	89 f2                	mov    %esi,%edx
  801153:	f7 f7                	div    %edi
  801155:	89 d0                	mov    %edx,%eax
  801157:	31 d2                	xor    %edx,%edx
  801159:	83 c4 20             	add    $0x20,%esp
  80115c:	5e                   	pop    %esi
  80115d:	5f                   	pop    %edi
  80115e:	5d                   	pop    %ebp
  80115f:	c3                   	ret    
  801160:	39 f2                	cmp    %esi,%edx
  801162:	77 4c                	ja     8011b0 <__umoddi3+0x80>
  801164:	0f bd ca             	bsr    %edx,%ecx
  801167:	83 f1 1f             	xor    $0x1f,%ecx
  80116a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80116d:	75 51                	jne    8011c0 <__umoddi3+0x90>
  80116f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801172:	0f 87 e0 00 00 00    	ja     801258 <__umoddi3+0x128>
  801178:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80117b:	29 f8                	sub    %edi,%eax
  80117d:	19 d6                	sbb    %edx,%esi
  80117f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801182:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801185:	89 f2                	mov    %esi,%edx
  801187:	83 c4 20             	add    $0x20,%esp
  80118a:	5e                   	pop    %esi
  80118b:	5f                   	pop    %edi
  80118c:	5d                   	pop    %ebp
  80118d:	c3                   	ret    
  80118e:	66 90                	xchg   %ax,%ax
  801190:	85 ff                	test   %edi,%edi
  801192:	75 0b                	jne    80119f <__umoddi3+0x6f>
  801194:	b8 01 00 00 00       	mov    $0x1,%eax
  801199:	31 d2                	xor    %edx,%edx
  80119b:	f7 f7                	div    %edi
  80119d:	89 c7                	mov    %eax,%edi
  80119f:	89 f0                	mov    %esi,%eax
  8011a1:	31 d2                	xor    %edx,%edx
  8011a3:	f7 f7                	div    %edi
  8011a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011a8:	f7 f7                	div    %edi
  8011aa:	eb a9                	jmp    801155 <__umoddi3+0x25>
  8011ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011b0:	89 c8                	mov    %ecx,%eax
  8011b2:	89 f2                	mov    %esi,%edx
  8011b4:	83 c4 20             	add    $0x20,%esp
  8011b7:	5e                   	pop    %esi
  8011b8:	5f                   	pop    %edi
  8011b9:	5d                   	pop    %ebp
  8011ba:	c3                   	ret    
  8011bb:	90                   	nop
  8011bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011c0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011c4:	d3 e2                	shl    %cl,%edx
  8011c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011c9:	ba 20 00 00 00       	mov    $0x20,%edx
  8011ce:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8011d1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8011d4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011d8:	89 fa                	mov    %edi,%edx
  8011da:	d3 ea                	shr    %cl,%edx
  8011dc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011e0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8011e3:	d3 e7                	shl    %cl,%edi
  8011e5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011e9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011ec:	89 f2                	mov    %esi,%edx
  8011ee:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8011f1:	89 c7                	mov    %eax,%edi
  8011f3:	d3 ea                	shr    %cl,%edx
  8011f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011f9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8011fc:	89 c2                	mov    %eax,%edx
  8011fe:	d3 e6                	shl    %cl,%esi
  801200:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801204:	d3 ea                	shr    %cl,%edx
  801206:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80120a:	09 d6                	or     %edx,%esi
  80120c:	89 f0                	mov    %esi,%eax
  80120e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801211:	d3 e7                	shl    %cl,%edi
  801213:	89 f2                	mov    %esi,%edx
  801215:	f7 75 f4             	divl   -0xc(%ebp)
  801218:	89 d6                	mov    %edx,%esi
  80121a:	f7 65 e8             	mull   -0x18(%ebp)
  80121d:	39 d6                	cmp    %edx,%esi
  80121f:	72 2b                	jb     80124c <__umoddi3+0x11c>
  801221:	39 c7                	cmp    %eax,%edi
  801223:	72 23                	jb     801248 <__umoddi3+0x118>
  801225:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801229:	29 c7                	sub    %eax,%edi
  80122b:	19 d6                	sbb    %edx,%esi
  80122d:	89 f0                	mov    %esi,%eax
  80122f:	89 f2                	mov    %esi,%edx
  801231:	d3 ef                	shr    %cl,%edi
  801233:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801237:	d3 e0                	shl    %cl,%eax
  801239:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80123d:	09 f8                	or     %edi,%eax
  80123f:	d3 ea                	shr    %cl,%edx
  801241:	83 c4 20             	add    $0x20,%esp
  801244:	5e                   	pop    %esi
  801245:	5f                   	pop    %edi
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    
  801248:	39 d6                	cmp    %edx,%esi
  80124a:	75 d9                	jne    801225 <__umoddi3+0xf5>
  80124c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80124f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801252:	eb d1                	jmp    801225 <__umoddi3+0xf5>
  801254:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801258:	39 f2                	cmp    %esi,%edx
  80125a:	0f 82 18 ff ff ff    	jb     801178 <__umoddi3+0x48>
  801260:	e9 1d ff ff ff       	jmp    801182 <__umoddi3+0x52>
