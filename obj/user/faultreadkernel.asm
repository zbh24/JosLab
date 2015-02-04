
obj/user/faultreadkernel：     文件格式 elf32-i386


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
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	cprintf("I read %08x from location 0xf0100000!\n", *(unsigned*)0xf0100000);
  800039:	a1 00 00 10 f0       	mov    0xf0100000,%eax
  80003e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800042:	c7 04 24 60 12 80 00 	movl   $0x801260,(%esp)
  800049:	e8 d0 00 00 00       	call   80011e <cprintf>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	83 ec 18             	sub    $0x18,%esp
  800056:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800059:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80005c:	8b 75 08             	mov    0x8(%ebp),%esi
  80005f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800062:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800069:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  80006c:	e8 90 0e 00 00       	call   800f01 <sys_getenvid>
  800071:	25 ff 03 00 00       	and    $0x3ff,%eax
  800076:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800079:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007e:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800083:	85 f6                	test   %esi,%esi
  800085:	7e 07                	jle    80008e <libmain+0x3e>
		binaryname = argv[0];
  800087:	8b 03                	mov    (%ebx),%eax
  800089:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800092:	89 34 24             	mov    %esi,(%esp)
  800095:	e8 99 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80009a:	e8 0a 00 00 00       	call   8000a9 <exit>
}
  80009f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a2:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000a5:	89 ec                	mov    %ebp,%esp
  8000a7:	5d                   	pop    %ebp
  8000a8:	c3                   	ret    

008000a9 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a9:	55                   	push   %ebp
  8000aa:	89 e5                	mov    %esp,%ebp
  8000ac:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000af:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b6:	e8 7a 0e 00 00       	call   800f35 <sys_env_destroy>
}
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8000bd:	55                   	push   %ebp
  8000be:	89 e5                	mov    %esp,%ebp
  8000c0:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8000c6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8000cd:	00 00 00 
	b.cnt = 0;
  8000d0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8000d7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8000da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8000dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8000e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000e8:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8000ee:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000f2:	c7 04 24 38 01 80 00 	movl   $0x800138,(%esp)
  8000f9:	e8 cf 01 00 00       	call   8002cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8000fe:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800104:	89 44 24 04          	mov    %eax,0x4(%esp)
  800108:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80010e:	89 04 24             	mov    %eax,(%esp)
  800111:	e8 18 0b 00 00       	call   800c2e <sys_cputs>

	return b.cnt;
}
  800116:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80011c:	c9                   	leave  
  80011d:	c3                   	ret    

0080011e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80011e:	55                   	push   %ebp
  80011f:	89 e5                	mov    %esp,%ebp
  800121:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800124:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800127:	89 44 24 04          	mov    %eax,0x4(%esp)
  80012b:	8b 45 08             	mov    0x8(%ebp),%eax
  80012e:	89 04 24             	mov    %eax,(%esp)
  800131:	e8 87 ff ff ff       	call   8000bd <vcprintf>
	va_end(ap);

	return cnt;
}
  800136:	c9                   	leave  
  800137:	c3                   	ret    

00800138 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800138:	55                   	push   %ebp
  800139:	89 e5                	mov    %esp,%ebp
  80013b:	53                   	push   %ebx
  80013c:	83 ec 14             	sub    $0x14,%esp
  80013f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800142:	8b 03                	mov    (%ebx),%eax
  800144:	8b 55 08             	mov    0x8(%ebp),%edx
  800147:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80014b:	83 c0 01             	add    $0x1,%eax
  80014e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800150:	3d ff 00 00 00       	cmp    $0xff,%eax
  800155:	75 19                	jne    800170 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800157:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80015e:	00 
  80015f:	8d 43 08             	lea    0x8(%ebx),%eax
  800162:	89 04 24             	mov    %eax,(%esp)
  800165:	e8 c4 0a 00 00       	call   800c2e <sys_cputs>
		b->idx = 0;
  80016a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800170:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800174:	83 c4 14             	add    $0x14,%esp
  800177:	5b                   	pop    %ebx
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    
  80017a:	66 90                	xchg   %ax,%ax
  80017c:	66 90                	xchg   %ax,%ax
  80017e:	66 90                	xchg   %ax,%ax

00800180 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	57                   	push   %edi
  800184:	56                   	push   %esi
  800185:	53                   	push   %ebx
  800186:	83 ec 4c             	sub    $0x4c,%esp
  800189:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80018c:	89 d6                	mov    %edx,%esi
  80018e:	8b 45 08             	mov    0x8(%ebp),%eax
  800191:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800194:	8b 55 0c             	mov    0xc(%ebp),%edx
  800197:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80019a:	8b 45 10             	mov    0x10(%ebp),%eax
  80019d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001a0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ab:	39 d1                	cmp    %edx,%ecx
  8001ad:	72 15                	jb     8001c4 <printnum+0x44>
  8001af:	77 07                	ja     8001b8 <printnum+0x38>
  8001b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8001b4:	39 d0                	cmp    %edx,%eax
  8001b6:	76 0c                	jbe    8001c4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8001b8:	83 eb 01             	sub    $0x1,%ebx
  8001bb:	85 db                	test   %ebx,%ebx
  8001bd:	8d 76 00             	lea    0x0(%esi),%esi
  8001c0:	7f 61                	jg     800223 <printnum+0xa3>
  8001c2:	eb 70                	jmp    800234 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001c4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8001c8:	83 eb 01             	sub    $0x1,%ebx
  8001cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8001cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8001d7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8001db:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8001de:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8001e1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8001e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ef:	00 
  8001f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8001f3:	89 04 24             	mov    %eax,(%esp)
  8001f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8001f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8001fd:	e8 ee 0d 00 00       	call   800ff0 <__udivdi3>
  800202:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800205:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800208:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80020c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800210:	89 04 24             	mov    %eax,(%esp)
  800213:	89 54 24 04          	mov    %edx,0x4(%esp)
  800217:	89 f2                	mov    %esi,%edx
  800219:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80021c:	e8 5f ff ff ff       	call   800180 <printnum>
  800221:	eb 11                	jmp    800234 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800223:	89 74 24 04          	mov    %esi,0x4(%esp)
  800227:	89 3c 24             	mov    %edi,(%esp)
  80022a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80022d:	83 eb 01             	sub    $0x1,%ebx
  800230:	85 db                	test   %ebx,%ebx
  800232:	7f ef                	jg     800223 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800234:	89 74 24 04          	mov    %esi,0x4(%esp)
  800238:	8b 74 24 04          	mov    0x4(%esp),%esi
  80023c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80023f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800243:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80024a:	00 
  80024b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80024e:	89 14 24             	mov    %edx,(%esp)
  800251:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800254:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800258:	e8 c3 0e 00 00       	call   801120 <__umoddi3>
  80025d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800261:	0f be 80 91 12 80 00 	movsbl 0x801291(%eax),%eax
  800268:	89 04 24             	mov    %eax,(%esp)
  80026b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80026e:	83 c4 4c             	add    $0x4c,%esp
  800271:	5b                   	pop    %ebx
  800272:	5e                   	pop    %esi
  800273:	5f                   	pop    %edi
  800274:	5d                   	pop    %ebp
  800275:	c3                   	ret    

00800276 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800279:	83 fa 01             	cmp    $0x1,%edx
  80027c:	7e 0e                	jle    80028c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80027e:	8b 10                	mov    (%eax),%edx
  800280:	8d 4a 08             	lea    0x8(%edx),%ecx
  800283:	89 08                	mov    %ecx,(%eax)
  800285:	8b 02                	mov    (%edx),%eax
  800287:	8b 52 04             	mov    0x4(%edx),%edx
  80028a:	eb 22                	jmp    8002ae <getuint+0x38>
	else if (lflag)
  80028c:	85 d2                	test   %edx,%edx
  80028e:	74 10                	je     8002a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800290:	8b 10                	mov    (%eax),%edx
  800292:	8d 4a 04             	lea    0x4(%edx),%ecx
  800295:	89 08                	mov    %ecx,(%eax)
  800297:	8b 02                	mov    (%edx),%eax
  800299:	ba 00 00 00 00       	mov    $0x0,%edx
  80029e:	eb 0e                	jmp    8002ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002a0:	8b 10                	mov    (%eax),%edx
  8002a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a5:	89 08                	mov    %ecx,(%eax)
  8002a7:	8b 02                	mov    (%edx),%eax
  8002a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002ae:	5d                   	pop    %ebp
  8002af:	c3                   	ret    

008002b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002ba:	8b 10                	mov    (%eax),%edx
  8002bc:	3b 50 04             	cmp    0x4(%eax),%edx
  8002bf:	73 0a                	jae    8002cb <sprintputch+0x1b>
		*b->buf++ = ch;
  8002c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c4:	88 0a                	mov    %cl,(%edx)
  8002c6:	83 c2 01             	add    $0x1,%edx
  8002c9:	89 10                	mov    %edx,(%eax)
}
  8002cb:	5d                   	pop    %ebp
  8002cc:	c3                   	ret    

008002cd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8002cd:	55                   	push   %ebp
  8002ce:	89 e5                	mov    %esp,%ebp
  8002d0:	57                   	push   %edi
  8002d1:	56                   	push   %esi
  8002d2:	53                   	push   %ebx
  8002d3:	83 ec 5c             	sub    $0x5c,%esp
  8002d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8002d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8002dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8002df:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8002e6:	eb 11                	jmp    8002f9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8002e8:	85 c0                	test   %eax,%eax
  8002ea:	0f 84 16 04 00 00    	je     800706 <vprintfmt+0x439>
				return;
			putch(ch, putdat);
  8002f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f4:	89 04 24             	mov    %eax,(%esp)
  8002f7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8002f9:	0f b6 03             	movzbl (%ebx),%eax
  8002fc:	83 c3 01             	add    $0x1,%ebx
  8002ff:	83 f8 25             	cmp    $0x25,%eax
  800302:	75 e4                	jne    8002e8 <vprintfmt+0x1b>
  800304:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80030b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800312:	b9 00 00 00 00       	mov    $0x0,%ecx
  800317:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80031b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800322:	eb 06                	jmp    80032a <vprintfmt+0x5d>
  800324:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800328:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	0f b6 13             	movzbl (%ebx),%edx
  80032d:	0f b6 c2             	movzbl %dl,%eax
  800330:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800333:	8d 43 01             	lea    0x1(%ebx),%eax
  800336:	83 ea 23             	sub    $0x23,%edx
  800339:	80 fa 55             	cmp    $0x55,%dl
  80033c:	0f 87 a7 03 00 00    	ja     8006e9 <vprintfmt+0x41c>
  800342:	0f b6 d2             	movzbl %dl,%edx
  800345:	ff 24 95 60 13 80 00 	jmp    *0x801360(,%edx,4)
  80034c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800350:	eb d6                	jmp    800328 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800352:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800355:	83 ea 30             	sub    $0x30,%edx
  800358:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80035b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80035e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800361:	83 fb 09             	cmp    $0x9,%ebx
  800364:	77 54                	ja     8003ba <vprintfmt+0xed>
  800366:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800369:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80036c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80036f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800372:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800376:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800379:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80037c:	83 fb 09             	cmp    $0x9,%ebx
  80037f:	76 eb                	jbe    80036c <vprintfmt+0x9f>
  800381:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800384:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800387:	eb 31                	jmp    8003ba <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800389:	8b 55 14             	mov    0x14(%ebp),%edx
  80038c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80038f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800392:	8b 12                	mov    (%edx),%edx
  800394:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800397:	eb 21                	jmp    8003ba <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800399:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80039d:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a2:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  8003a6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003a9:	e9 7a ff ff ff       	jmp    800328 <vprintfmt+0x5b>
  8003ae:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8003b5:	e9 6e ff ff ff       	jmp    800328 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8003ba:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003be:	0f 89 64 ff ff ff    	jns    800328 <vprintfmt+0x5b>
  8003c4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8003c7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003ca:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8003cd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8003d0:	e9 53 ff ff ff       	jmp    800328 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8003d5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8003d8:	e9 4b ff ff ff       	jmp    800328 <vprintfmt+0x5b>
  8003dd:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8003e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e3:	8d 50 04             	lea    0x4(%eax),%edx
  8003e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003ed:	8b 00                	mov    (%eax),%eax
  8003ef:	89 04 24             	mov    %eax,(%esp)
  8003f2:	ff d7                	call   *%edi
  8003f4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8003f7:	e9 fd fe ff ff       	jmp    8002f9 <vprintfmt+0x2c>
  8003fc:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8003ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800402:	8d 50 04             	lea    0x4(%eax),%edx
  800405:	89 55 14             	mov    %edx,0x14(%ebp)
  800408:	8b 00                	mov    (%eax),%eax
  80040a:	89 c2                	mov    %eax,%edx
  80040c:	c1 fa 1f             	sar    $0x1f,%edx
  80040f:	31 d0                	xor    %edx,%eax
  800411:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800413:	83 f8 08             	cmp    $0x8,%eax
  800416:	7f 0b                	jg     800423 <vprintfmt+0x156>
  800418:	8b 14 85 c0 14 80 00 	mov    0x8014c0(,%eax,4),%edx
  80041f:	85 d2                	test   %edx,%edx
  800421:	75 20                	jne    800443 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800423:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800427:	c7 44 24 08 a2 12 80 	movl   $0x8012a2,0x8(%esp)
  80042e:	00 
  80042f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800433:	89 3c 24             	mov    %edi,(%esp)
  800436:	e8 53 03 00 00       	call   80078e <printfmt>
  80043b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80043e:	e9 b6 fe ff ff       	jmp    8002f9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800443:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800447:	c7 44 24 08 ab 12 80 	movl   $0x8012ab,0x8(%esp)
  80044e:	00 
  80044f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800453:	89 3c 24             	mov    %edi,(%esp)
  800456:	e8 33 03 00 00       	call   80078e <printfmt>
  80045b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80045e:	e9 96 fe ff ff       	jmp    8002f9 <vprintfmt+0x2c>
  800463:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800466:	89 c3                	mov    %eax,%ebx
  800468:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80046b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80046e:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800471:	8b 45 14             	mov    0x14(%ebp),%eax
  800474:	8d 50 04             	lea    0x4(%eax),%edx
  800477:	89 55 14             	mov    %edx,0x14(%ebp)
  80047a:	8b 00                	mov    (%eax),%eax
  80047c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80047f:	85 c0                	test   %eax,%eax
  800481:	b8 ae 12 80 00       	mov    $0x8012ae,%eax
  800486:	0f 45 45 c4          	cmovne -0x3c(%ebp),%eax
  80048a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80048d:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800491:	7e 06                	jle    800499 <vprintfmt+0x1cc>
  800493:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800497:	75 13                	jne    8004ac <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800499:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80049c:	0f be 02             	movsbl (%edx),%eax
  80049f:	85 c0                	test   %eax,%eax
  8004a1:	0f 85 9b 00 00 00    	jne    800542 <vprintfmt+0x275>
  8004a7:	e9 88 00 00 00       	jmp    800534 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004ac:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004b0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  8004b3:	89 0c 24             	mov    %ecx,(%esp)
  8004b6:	e8 20 03 00 00       	call   8007db <strnlen>
  8004bb:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8004be:	29 c2                	sub    %eax,%edx
  8004c0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004c3:	85 d2                	test   %edx,%edx
  8004c5:	7e d2                	jle    800499 <vprintfmt+0x1cc>
					putch(padc, putdat);
  8004c7:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  8004cb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8004ce:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8004d1:	89 d3                	mov    %edx,%ebx
  8004d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8004da:	89 04 24             	mov    %eax,(%esp)
  8004dd:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004df:	83 eb 01             	sub    $0x1,%ebx
  8004e2:	85 db                	test   %ebx,%ebx
  8004e4:	7f ed                	jg     8004d3 <vprintfmt+0x206>
  8004e6:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8004e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8004f0:	eb a7                	jmp    800499 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8004f2:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8004f6:	74 1a                	je     800512 <vprintfmt+0x245>
  8004f8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8004fb:	83 fa 5e             	cmp    $0x5e,%edx
  8004fe:	76 12                	jbe    800512 <vprintfmt+0x245>
					putch('?', putdat);
  800500:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800504:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80050b:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80050e:	66 90                	xchg   %ax,%ax
  800510:	eb 0a                	jmp    80051c <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800512:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800516:	89 04 24             	mov    %eax,(%esp)
  800519:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80051c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800520:	0f be 03             	movsbl (%ebx),%eax
  800523:	85 c0                	test   %eax,%eax
  800525:	74 05                	je     80052c <vprintfmt+0x25f>
  800527:	83 c3 01             	add    $0x1,%ebx
  80052a:	eb 29                	jmp    800555 <vprintfmt+0x288>
  80052c:	89 fe                	mov    %edi,%esi
  80052e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800531:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800534:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800538:	7f 2e                	jg     800568 <vprintfmt+0x29b>
  80053a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053d:	e9 b7 fd ff ff       	jmp    8002f9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800542:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800545:	83 c2 01             	add    $0x1,%edx
  800548:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80054b:	89 f7                	mov    %esi,%edi
  80054d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800550:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800553:	89 d3                	mov    %edx,%ebx
  800555:	85 f6                	test   %esi,%esi
  800557:	78 99                	js     8004f2 <vprintfmt+0x225>
  800559:	83 ee 01             	sub    $0x1,%esi
  80055c:	79 94                	jns    8004f2 <vprintfmt+0x225>
  80055e:	89 fe                	mov    %edi,%esi
  800560:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800563:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800566:	eb cc                	jmp    800534 <vprintfmt+0x267>
  800568:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80056b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80056e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800572:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800579:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80057b:	83 eb 01             	sub    $0x1,%ebx
  80057e:	85 db                	test   %ebx,%ebx
  800580:	7f ec                	jg     80056e <vprintfmt+0x2a1>
  800582:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800585:	e9 6f fd ff ff       	jmp    8002f9 <vprintfmt+0x2c>
  80058a:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80058d:	83 f9 01             	cmp    $0x1,%ecx
  800590:	7e 16                	jle    8005a8 <vprintfmt+0x2db>
		return va_arg(*ap, long long);
  800592:	8b 45 14             	mov    0x14(%ebp),%eax
  800595:	8d 50 08             	lea    0x8(%eax),%edx
  800598:	89 55 14             	mov    %edx,0x14(%ebp)
  80059b:	8b 10                	mov    (%eax),%edx
  80059d:	8b 48 04             	mov    0x4(%eax),%ecx
  8005a0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005a3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005a6:	eb 32                	jmp    8005da <vprintfmt+0x30d>
	else if (lflag)
  8005a8:	85 c9                	test   %ecx,%ecx
  8005aa:	74 18                	je     8005c4 <vprintfmt+0x2f7>
		return va_arg(*ap, long);
  8005ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8005af:	8d 50 04             	lea    0x4(%eax),%edx
  8005b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8005b5:	8b 00                	mov    (%eax),%eax
  8005b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005ba:	89 c1                	mov    %eax,%ecx
  8005bc:	c1 f9 1f             	sar    $0x1f,%ecx
  8005bf:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005c2:	eb 16                	jmp    8005da <vprintfmt+0x30d>
	else
		return va_arg(*ap, int);
  8005c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c7:	8d 50 04             	lea    0x4(%eax),%edx
  8005ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cd:	8b 00                	mov    (%eax),%eax
  8005cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8005d2:	89 c2                	mov    %eax,%edx
  8005d4:	c1 fa 1f             	sar    $0x1f,%edx
  8005d7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8005da:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005dd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005e0:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8005e5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005e9:	0f 89 b8 00 00 00    	jns    8006a7 <vprintfmt+0x3da>
				putch('-', putdat);
  8005ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8005fa:	ff d7                	call   *%edi
				num = -(long long) num;
  8005fc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005ff:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800602:	f7 d9                	neg    %ecx
  800604:	83 d3 00             	adc    $0x0,%ebx
  800607:	f7 db                	neg    %ebx
  800609:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060e:	e9 94 00 00 00       	jmp    8006a7 <vprintfmt+0x3da>
  800613:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800616:	89 ca                	mov    %ecx,%edx
  800618:	8d 45 14             	lea    0x14(%ebp),%eax
  80061b:	e8 56 fc ff ff       	call   800276 <getuint>
  800620:	89 c1                	mov    %eax,%ecx
  800622:	89 d3                	mov    %edx,%ebx
  800624:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800629:	eb 7c                	jmp    8006a7 <vprintfmt+0x3da>
  80062b:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80062e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800632:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800639:	ff d7                	call   *%edi
			putch('X', putdat);
  80063b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80063f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800646:	ff d7                	call   *%edi
			putch('X', putdat);
  800648:	89 74 24 04          	mov    %esi,0x4(%esp)
  80064c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800653:	ff d7                	call   *%edi
  800655:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800658:	e9 9c fc ff ff       	jmp    8002f9 <vprintfmt+0x2c>
  80065d:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800660:	89 74 24 04          	mov    %esi,0x4(%esp)
  800664:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80066b:	ff d7                	call   *%edi
			putch('x', putdat);
  80066d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800671:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800678:	ff d7                	call   *%edi
			num = (unsigned long long)
  80067a:	8b 45 14             	mov    0x14(%ebp),%eax
  80067d:	8d 50 04             	lea    0x4(%eax),%edx
  800680:	89 55 14             	mov    %edx,0x14(%ebp)
  800683:	8b 08                	mov    (%eax),%ecx
  800685:	bb 00 00 00 00       	mov    $0x0,%ebx
  80068a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80068f:	eb 16                	jmp    8006a7 <vprintfmt+0x3da>
  800691:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800694:	89 ca                	mov    %ecx,%edx
  800696:	8d 45 14             	lea    0x14(%ebp),%eax
  800699:	e8 d8 fb ff ff       	call   800276 <getuint>
  80069e:	89 c1                	mov    %eax,%ecx
  8006a0:	89 d3                	mov    %edx,%ebx
  8006a2:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006a7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006ab:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8006b2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8006b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8006ba:	89 0c 24             	mov    %ecx,(%esp)
  8006bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8006c1:	89 f2                	mov    %esi,%edx
  8006c3:	89 f8                	mov    %edi,%eax
  8006c5:	e8 b6 fa ff ff       	call   800180 <printnum>
  8006ca:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8006cd:	e9 27 fc ff ff       	jmp    8002f9 <vprintfmt+0x2c>
  8006d2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006d5:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8006d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006dc:	89 14 24             	mov    %edx,(%esp)
  8006df:	ff d7                	call   *%edi
  8006e1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8006e4:	e9 10 fc ff ff       	jmp    8002f9 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8006e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ed:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8006f4:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006f6:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8006f9:	80 38 25             	cmpb   $0x25,(%eax)
  8006fc:	0f 84 f7 fb ff ff    	je     8002f9 <vprintfmt+0x2c>
  800702:	89 c3                	mov    %eax,%ebx
  800704:	eb f0                	jmp    8006f6 <vprintfmt+0x429>
				/* do nothing */;
			break;
		}
	}
}
  800706:	83 c4 5c             	add    $0x5c,%esp
  800709:	5b                   	pop    %ebx
  80070a:	5e                   	pop    %esi
  80070b:	5f                   	pop    %edi
  80070c:	5d                   	pop    %ebp
  80070d:	c3                   	ret    

0080070e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80070e:	55                   	push   %ebp
  80070f:	89 e5                	mov    %esp,%ebp
  800711:	83 ec 28             	sub    $0x28,%esp
  800714:	8b 45 08             	mov    0x8(%ebp),%eax
  800717:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80071a:	85 c0                	test   %eax,%eax
  80071c:	74 04                	je     800722 <vsnprintf+0x14>
  80071e:	85 d2                	test   %edx,%edx
  800720:	7f 07                	jg     800729 <vsnprintf+0x1b>
  800722:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800727:	eb 3b                	jmp    800764 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800729:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80072c:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800730:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800733:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80073a:	8b 45 14             	mov    0x14(%ebp),%eax
  80073d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800741:	8b 45 10             	mov    0x10(%ebp),%eax
  800744:	89 44 24 08          	mov    %eax,0x8(%esp)
  800748:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80074b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80074f:	c7 04 24 b0 02 80 00 	movl   $0x8002b0,(%esp)
  800756:	e8 72 fb ff ff       	call   8002cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80075b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80075e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800761:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800764:	c9                   	leave  
  800765:	c3                   	ret    

00800766 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800766:	55                   	push   %ebp
  800767:	89 e5                	mov    %esp,%ebp
  800769:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80076c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80076f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800773:	8b 45 10             	mov    0x10(%ebp),%eax
  800776:	89 44 24 08          	mov    %eax,0x8(%esp)
  80077a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80077d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800781:	8b 45 08             	mov    0x8(%ebp),%eax
  800784:	89 04 24             	mov    %eax,(%esp)
  800787:	e8 82 ff ff ff       	call   80070e <vsnprintf>
	va_end(ap);

	return rc;
}
  80078c:	c9                   	leave  
  80078d:	c3                   	ret    

0080078e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80078e:	55                   	push   %ebp
  80078f:	89 e5                	mov    %esp,%ebp
  800791:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800794:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800797:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80079b:	8b 45 10             	mov    0x10(%ebp),%eax
  80079e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ac:	89 04 24             	mov    %eax,(%esp)
  8007af:	e8 19 fb ff ff       	call   8002cd <vprintfmt>
	va_end(ap);
}
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    
  8007b6:	66 90                	xchg   %ax,%ax
  8007b8:	66 90                	xchg   %ax,%ax
  8007ba:	66 90                	xchg   %ax,%ax
  8007bc:	66 90                	xchg   %ax,%ax
  8007be:	66 90                	xchg   %ax,%ax

008007c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007c0:	55                   	push   %ebp
  8007c1:	89 e5                	mov    %esp,%ebp
  8007c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8007cb:	80 3a 00             	cmpb   $0x0,(%edx)
  8007ce:	74 09                	je     8007d9 <strlen+0x19>
		n++;
  8007d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8007d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007d7:	75 f7                	jne    8007d0 <strlen+0x10>
		n++;
	return n;
}
  8007d9:	5d                   	pop    %ebp
  8007da:	c3                   	ret    

008007db <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007db:	55                   	push   %ebp
  8007dc:	89 e5                	mov    %esp,%ebp
  8007de:	53                   	push   %ebx
  8007df:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8007e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007e5:	85 c9                	test   %ecx,%ecx
  8007e7:	74 19                	je     800802 <strnlen+0x27>
  8007e9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8007ec:	74 14                	je     800802 <strnlen+0x27>
  8007ee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8007f3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007f6:	39 c8                	cmp    %ecx,%eax
  8007f8:	74 0d                	je     800807 <strnlen+0x2c>
  8007fa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8007fe:	75 f3                	jne    8007f3 <strnlen+0x18>
  800800:	eb 05                	jmp    800807 <strnlen+0x2c>
  800802:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800807:	5b                   	pop    %ebx
  800808:	5d                   	pop    %ebp
  800809:	c3                   	ret    

0080080a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80080a:	55                   	push   %ebp
  80080b:	89 e5                	mov    %esp,%ebp
  80080d:	53                   	push   %ebx
  80080e:	8b 45 08             	mov    0x8(%ebp),%eax
  800811:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800814:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800819:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80081d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800820:	83 c2 01             	add    $0x1,%edx
  800823:	84 c9                	test   %cl,%cl
  800825:	75 f2                	jne    800819 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800827:	5b                   	pop    %ebx
  800828:	5d                   	pop    %ebp
  800829:	c3                   	ret    

0080082a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80082a:	55                   	push   %ebp
  80082b:	89 e5                	mov    %esp,%ebp
  80082d:	53                   	push   %ebx
  80082e:	83 ec 08             	sub    $0x8,%esp
  800831:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800834:	89 1c 24             	mov    %ebx,(%esp)
  800837:	e8 84 ff ff ff       	call   8007c0 <strlen>
	strcpy(dst + len, src);
  80083c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800843:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800846:	89 04 24             	mov    %eax,(%esp)
  800849:	e8 bc ff ff ff       	call   80080a <strcpy>
	return dst;
}
  80084e:	89 d8                	mov    %ebx,%eax
  800850:	83 c4 08             	add    $0x8,%esp
  800853:	5b                   	pop    %ebx
  800854:	5d                   	pop    %ebp
  800855:	c3                   	ret    

00800856 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800856:	55                   	push   %ebp
  800857:	89 e5                	mov    %esp,%ebp
  800859:	56                   	push   %esi
  80085a:	53                   	push   %ebx
  80085b:	8b 45 08             	mov    0x8(%ebp),%eax
  80085e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800861:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800864:	85 f6                	test   %esi,%esi
  800866:	74 18                	je     800880 <strncpy+0x2a>
  800868:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80086d:	0f b6 1a             	movzbl (%edx),%ebx
  800870:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800873:	80 3a 01             	cmpb   $0x1,(%edx)
  800876:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800879:	83 c1 01             	add    $0x1,%ecx
  80087c:	39 ce                	cmp    %ecx,%esi
  80087e:	77 ed                	ja     80086d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800880:	5b                   	pop    %ebx
  800881:	5e                   	pop    %esi
  800882:	5d                   	pop    %ebp
  800883:	c3                   	ret    

00800884 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800884:	55                   	push   %ebp
  800885:	89 e5                	mov    %esp,%ebp
  800887:	56                   	push   %esi
  800888:	53                   	push   %ebx
  800889:	8b 75 08             	mov    0x8(%ebp),%esi
  80088c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800892:	89 f0                	mov    %esi,%eax
  800894:	85 c9                	test   %ecx,%ecx
  800896:	74 27                	je     8008bf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800898:	83 e9 01             	sub    $0x1,%ecx
  80089b:	74 1d                	je     8008ba <strlcpy+0x36>
  80089d:	0f b6 1a             	movzbl (%edx),%ebx
  8008a0:	84 db                	test   %bl,%bl
  8008a2:	74 16                	je     8008ba <strlcpy+0x36>
			*dst++ = *src++;
  8008a4:	88 18                	mov    %bl,(%eax)
  8008a6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008a9:	83 e9 01             	sub    $0x1,%ecx
  8008ac:	74 0e                	je     8008bc <strlcpy+0x38>
			*dst++ = *src++;
  8008ae:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008b1:	0f b6 1a             	movzbl (%edx),%ebx
  8008b4:	84 db                	test   %bl,%bl
  8008b6:	75 ec                	jne    8008a4 <strlcpy+0x20>
  8008b8:	eb 02                	jmp    8008bc <strlcpy+0x38>
  8008ba:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8008bc:	c6 00 00             	movb   $0x0,(%eax)
  8008bf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8008c1:	5b                   	pop    %ebx
  8008c2:	5e                   	pop    %esi
  8008c3:	5d                   	pop    %ebp
  8008c4:	c3                   	ret    

008008c5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008c5:	55                   	push   %ebp
  8008c6:	89 e5                	mov    %esp,%ebp
  8008c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008ce:	0f b6 01             	movzbl (%ecx),%eax
  8008d1:	84 c0                	test   %al,%al
  8008d3:	74 15                	je     8008ea <strcmp+0x25>
  8008d5:	3a 02                	cmp    (%edx),%al
  8008d7:	75 11                	jne    8008ea <strcmp+0x25>
		p++, q++;
  8008d9:	83 c1 01             	add    $0x1,%ecx
  8008dc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8008df:	0f b6 01             	movzbl (%ecx),%eax
  8008e2:	84 c0                	test   %al,%al
  8008e4:	74 04                	je     8008ea <strcmp+0x25>
  8008e6:	3a 02                	cmp    (%edx),%al
  8008e8:	74 ef                	je     8008d9 <strcmp+0x14>
  8008ea:	0f b6 c0             	movzbl %al,%eax
  8008ed:	0f b6 12             	movzbl (%edx),%edx
  8008f0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    

008008f4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	53                   	push   %ebx
  8008f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8008fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008fe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800901:	85 c0                	test   %eax,%eax
  800903:	74 23                	je     800928 <strncmp+0x34>
  800905:	0f b6 1a             	movzbl (%edx),%ebx
  800908:	84 db                	test   %bl,%bl
  80090a:	74 25                	je     800931 <strncmp+0x3d>
  80090c:	3a 19                	cmp    (%ecx),%bl
  80090e:	75 21                	jne    800931 <strncmp+0x3d>
  800910:	83 e8 01             	sub    $0x1,%eax
  800913:	74 13                	je     800928 <strncmp+0x34>
		n--, p++, q++;
  800915:	83 c2 01             	add    $0x1,%edx
  800918:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80091b:	0f b6 1a             	movzbl (%edx),%ebx
  80091e:	84 db                	test   %bl,%bl
  800920:	74 0f                	je     800931 <strncmp+0x3d>
  800922:	3a 19                	cmp    (%ecx),%bl
  800924:	74 ea                	je     800910 <strncmp+0x1c>
  800926:	eb 09                	jmp    800931 <strncmp+0x3d>
  800928:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80092d:	5b                   	pop    %ebx
  80092e:	5d                   	pop    %ebp
  80092f:	90                   	nop
  800930:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800931:	0f b6 02             	movzbl (%edx),%eax
  800934:	0f b6 11             	movzbl (%ecx),%edx
  800937:	29 d0                	sub    %edx,%eax
  800939:	eb f2                	jmp    80092d <strncmp+0x39>

0080093b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80093b:	55                   	push   %ebp
  80093c:	89 e5                	mov    %esp,%ebp
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800945:	0f b6 10             	movzbl (%eax),%edx
  800948:	84 d2                	test   %dl,%dl
  80094a:	74 18                	je     800964 <strchr+0x29>
		if (*s == c)
  80094c:	38 ca                	cmp    %cl,%dl
  80094e:	75 0a                	jne    80095a <strchr+0x1f>
  800950:	eb 17                	jmp    800969 <strchr+0x2e>
  800952:	38 ca                	cmp    %cl,%dl
  800954:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800958:	74 0f                	je     800969 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  80095a:	83 c0 01             	add    $0x1,%eax
  80095d:	0f b6 10             	movzbl (%eax),%edx
  800960:	84 d2                	test   %dl,%dl
  800962:	75 ee                	jne    800952 <strchr+0x17>
  800964:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800969:	5d                   	pop    %ebp
  80096a:	c3                   	ret    

0080096b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80096b:	55                   	push   %ebp
  80096c:	89 e5                	mov    %esp,%ebp
  80096e:	8b 45 08             	mov    0x8(%ebp),%eax
  800971:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800975:	0f b6 10             	movzbl (%eax),%edx
  800978:	84 d2                	test   %dl,%dl
  80097a:	74 18                	je     800994 <strfind+0x29>
		if (*s == c)
  80097c:	38 ca                	cmp    %cl,%dl
  80097e:	75 0a                	jne    80098a <strfind+0x1f>
  800980:	eb 12                	jmp    800994 <strfind+0x29>
  800982:	38 ca                	cmp    %cl,%dl
  800984:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800988:	74 0a                	je     800994 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  80098a:	83 c0 01             	add    $0x1,%eax
  80098d:	0f b6 10             	movzbl (%eax),%edx
  800990:	84 d2                	test   %dl,%dl
  800992:	75 ee                	jne    800982 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800994:	5d                   	pop    %ebp
  800995:	c3                   	ret    

00800996 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 0c             	sub    $0xc,%esp
  80099c:	89 1c 24             	mov    %ebx,(%esp)
  80099f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009a3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8009a7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  8009b0:	85 c9                	test   %ecx,%ecx
  8009b2:	74 30                	je     8009e4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009b4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  8009ba:	75 25                	jne    8009e1 <memset+0x4b>
  8009bc:	f6 c1 03             	test   $0x3,%cl
  8009bf:	75 20                	jne    8009e1 <memset+0x4b>
		c &= 0xFF;
  8009c1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c4:	89 d3                	mov    %edx,%ebx
  8009c6:	c1 e3 08             	shl    $0x8,%ebx
  8009c9:	89 d6                	mov    %edx,%esi
  8009cb:	c1 e6 18             	shl    $0x18,%esi
  8009ce:	89 d0                	mov    %edx,%eax
  8009d0:	c1 e0 10             	shl    $0x10,%eax
  8009d3:	09 f0                	or     %esi,%eax
  8009d5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  8009d7:	09 d8                	or     %ebx,%eax
  8009d9:	c1 e9 02             	shr    $0x2,%ecx
  8009dc:	fc                   	cld    
  8009dd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009df:	eb 03                	jmp    8009e4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009e1:	fc                   	cld    
  8009e2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  8009e4:	89 f8                	mov    %edi,%eax
  8009e6:	8b 1c 24             	mov    (%esp),%ebx
  8009e9:	8b 74 24 04          	mov    0x4(%esp),%esi
  8009ed:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8009f1:	89 ec                	mov    %ebp,%esp
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	83 ec 08             	sub    $0x8,%esp
  8009fb:	89 34 24             	mov    %esi,(%esp)
  8009fe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
  800a05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800a08:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a0b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a0d:	39 c6                	cmp    %eax,%esi
  800a0f:	73 35                	jae    800a46 <memmove+0x51>
  800a11:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a14:	39 d0                	cmp    %edx,%eax
  800a16:	73 2e                	jae    800a46 <memmove+0x51>
		s += n;
		d += n;
  800a18:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a1a:	f6 c2 03             	test   $0x3,%dl
  800a1d:	75 1b                	jne    800a3a <memmove+0x45>
  800a1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a25:	75 13                	jne    800a3a <memmove+0x45>
  800a27:	f6 c1 03             	test   $0x3,%cl
  800a2a:	75 0e                	jne    800a3a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a2c:	83 ef 04             	sub    $0x4,%edi
  800a2f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a32:	c1 e9 02             	shr    $0x2,%ecx
  800a35:	fd                   	std    
  800a36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a38:	eb 09                	jmp    800a43 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a3a:	83 ef 01             	sub    $0x1,%edi
  800a3d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a40:	fd                   	std    
  800a41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a43:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a44:	eb 20                	jmp    800a66 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a4c:	75 15                	jne    800a63 <memmove+0x6e>
  800a4e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a54:	75 0d                	jne    800a63 <memmove+0x6e>
  800a56:	f6 c1 03             	test   $0x3,%cl
  800a59:	75 08                	jne    800a63 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800a5b:	c1 e9 02             	shr    $0x2,%ecx
  800a5e:	fc                   	cld    
  800a5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a61:	eb 03                	jmp    800a66 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800a63:	fc                   	cld    
  800a64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a66:	8b 34 24             	mov    (%esp),%esi
  800a69:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800a6d:	89 ec                	mov    %ebp,%esp
  800a6f:	5d                   	pop    %ebp
  800a70:	c3                   	ret    

00800a71 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a71:	55                   	push   %ebp
  800a72:	89 e5                	mov    %esp,%ebp
  800a74:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a77:	8b 45 10             	mov    0x10(%ebp),%eax
  800a7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a85:	8b 45 08             	mov    0x8(%ebp),%eax
  800a88:	89 04 24             	mov    %eax,(%esp)
  800a8b:	e8 65 ff ff ff       	call   8009f5 <memmove>
}
  800a90:	c9                   	leave  
  800a91:	c3                   	ret    

00800a92 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a92:	55                   	push   %ebp
  800a93:	89 e5                	mov    %esp,%ebp
  800a95:	57                   	push   %edi
  800a96:	56                   	push   %esi
  800a97:	53                   	push   %ebx
  800a98:	8b 75 08             	mov    0x8(%ebp),%esi
  800a9b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800a9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800aa1:	85 c9                	test   %ecx,%ecx
  800aa3:	74 36                	je     800adb <memcmp+0x49>
		if (*s1 != *s2)
  800aa5:	0f b6 06             	movzbl (%esi),%eax
  800aa8:	0f b6 1f             	movzbl (%edi),%ebx
  800aab:	38 d8                	cmp    %bl,%al
  800aad:	74 20                	je     800acf <memcmp+0x3d>
  800aaf:	eb 14                	jmp    800ac5 <memcmp+0x33>
  800ab1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800ab6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800abb:	83 c2 01             	add    $0x1,%edx
  800abe:	83 e9 01             	sub    $0x1,%ecx
  800ac1:	38 d8                	cmp    %bl,%al
  800ac3:	74 12                	je     800ad7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800ac5:	0f b6 c0             	movzbl %al,%eax
  800ac8:	0f b6 db             	movzbl %bl,%ebx
  800acb:	29 d8                	sub    %ebx,%eax
  800acd:	eb 11                	jmp    800ae0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800acf:	83 e9 01             	sub    $0x1,%ecx
  800ad2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad7:	85 c9                	test   %ecx,%ecx
  800ad9:	75 d6                	jne    800ab1 <memcmp+0x1f>
  800adb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800ae0:	5b                   	pop    %ebx
  800ae1:	5e                   	pop    %esi
  800ae2:	5f                   	pop    %edi
  800ae3:	5d                   	pop    %ebp
  800ae4:	c3                   	ret    

00800ae5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ae5:	55                   	push   %ebp
  800ae6:	89 e5                	mov    %esp,%ebp
  800ae8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800aeb:	89 c2                	mov    %eax,%edx
  800aed:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800af0:	39 d0                	cmp    %edx,%eax
  800af2:	73 15                	jae    800b09 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800af4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800af8:	38 08                	cmp    %cl,(%eax)
  800afa:	75 06                	jne    800b02 <memfind+0x1d>
  800afc:	eb 0b                	jmp    800b09 <memfind+0x24>
  800afe:	38 08                	cmp    %cl,(%eax)
  800b00:	74 07                	je     800b09 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b02:	83 c0 01             	add    $0x1,%eax
  800b05:	39 c2                	cmp    %eax,%edx
  800b07:	77 f5                	ja     800afe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b09:	5d                   	pop    %ebp
  800b0a:	c3                   	ret    

00800b0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	57                   	push   %edi
  800b0f:	56                   	push   %esi
  800b10:	53                   	push   %ebx
  800b11:	83 ec 04             	sub    $0x4,%esp
  800b14:	8b 55 08             	mov    0x8(%ebp),%edx
  800b17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b1a:	0f b6 02             	movzbl (%edx),%eax
  800b1d:	3c 20                	cmp    $0x20,%al
  800b1f:	74 04                	je     800b25 <strtol+0x1a>
  800b21:	3c 09                	cmp    $0x9,%al
  800b23:	75 0e                	jne    800b33 <strtol+0x28>
		s++;
  800b25:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b28:	0f b6 02             	movzbl (%edx),%eax
  800b2b:	3c 20                	cmp    $0x20,%al
  800b2d:	74 f6                	je     800b25 <strtol+0x1a>
  800b2f:	3c 09                	cmp    $0x9,%al
  800b31:	74 f2                	je     800b25 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b33:	3c 2b                	cmp    $0x2b,%al
  800b35:	75 0c                	jne    800b43 <strtol+0x38>
		s++;
  800b37:	83 c2 01             	add    $0x1,%edx
  800b3a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b41:	eb 15                	jmp    800b58 <strtol+0x4d>
	else if (*s == '-')
  800b43:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b4a:	3c 2d                	cmp    $0x2d,%al
  800b4c:	75 0a                	jne    800b58 <strtol+0x4d>
		s++, neg = 1;
  800b4e:	83 c2 01             	add    $0x1,%edx
  800b51:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b58:	85 db                	test   %ebx,%ebx
  800b5a:	0f 94 c0             	sete   %al
  800b5d:	74 05                	je     800b64 <strtol+0x59>
  800b5f:	83 fb 10             	cmp    $0x10,%ebx
  800b62:	75 18                	jne    800b7c <strtol+0x71>
  800b64:	80 3a 30             	cmpb   $0x30,(%edx)
  800b67:	75 13                	jne    800b7c <strtol+0x71>
  800b69:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800b6d:	8d 76 00             	lea    0x0(%esi),%esi
  800b70:	75 0a                	jne    800b7c <strtol+0x71>
		s += 2, base = 16;
  800b72:	83 c2 02             	add    $0x2,%edx
  800b75:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b7a:	eb 15                	jmp    800b91 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b7c:	84 c0                	test   %al,%al
  800b7e:	66 90                	xchg   %ax,%ax
  800b80:	74 0f                	je     800b91 <strtol+0x86>
  800b82:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800b87:	80 3a 30             	cmpb   $0x30,(%edx)
  800b8a:	75 05                	jne    800b91 <strtol+0x86>
		s++, base = 8;
  800b8c:	83 c2 01             	add    $0x1,%edx
  800b8f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800b91:	b8 00 00 00 00       	mov    $0x0,%eax
  800b96:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800b98:	0f b6 0a             	movzbl (%edx),%ecx
  800b9b:	89 cf                	mov    %ecx,%edi
  800b9d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ba0:	80 fb 09             	cmp    $0x9,%bl
  800ba3:	77 08                	ja     800bad <strtol+0xa2>
			dig = *s - '0';
  800ba5:	0f be c9             	movsbl %cl,%ecx
  800ba8:	83 e9 30             	sub    $0x30,%ecx
  800bab:	eb 1e                	jmp    800bcb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800bad:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800bb0:	80 fb 19             	cmp    $0x19,%bl
  800bb3:	77 08                	ja     800bbd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800bb5:	0f be c9             	movsbl %cl,%ecx
  800bb8:	83 e9 57             	sub    $0x57,%ecx
  800bbb:	eb 0e                	jmp    800bcb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800bbd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800bc0:	80 fb 19             	cmp    $0x19,%bl
  800bc3:	77 15                	ja     800bda <strtol+0xcf>
			dig = *s - 'A' + 10;
  800bc5:	0f be c9             	movsbl %cl,%ecx
  800bc8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800bcb:	39 f1                	cmp    %esi,%ecx
  800bcd:	7d 0b                	jge    800bda <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800bcf:	83 c2 01             	add    $0x1,%edx
  800bd2:	0f af c6             	imul   %esi,%eax
  800bd5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800bd8:	eb be                	jmp    800b98 <strtol+0x8d>
  800bda:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800bdc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800be0:	74 05                	je     800be7 <strtol+0xdc>
		*endptr = (char *) s;
  800be2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800be5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800be7:	89 ca                	mov    %ecx,%edx
  800be9:	f7 da                	neg    %edx
  800beb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800bef:	0f 45 c2             	cmovne %edx,%eax
}
  800bf2:	83 c4 04             	add    $0x4,%esp
  800bf5:	5b                   	pop    %ebx
  800bf6:	5e                   	pop    %esi
  800bf7:	5f                   	pop    %edi
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	83 ec 0c             	sub    $0xc,%esp
  800c00:	89 1c 24             	mov    %ebx,(%esp)
  800c03:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c07:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c10:	b8 01 00 00 00       	mov    $0x1,%eax
  800c15:	89 d1                	mov    %edx,%ecx
  800c17:	89 d3                	mov    %edx,%ebx
  800c19:	89 d7                	mov    %edx,%edi
  800c1b:	89 d6                	mov    %edx,%esi
  800c1d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c1f:	8b 1c 24             	mov    (%esp),%ebx
  800c22:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c26:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c2a:	89 ec                	mov    %ebp,%esp
  800c2c:	5d                   	pop    %ebp
  800c2d:	c3                   	ret    

00800c2e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	83 ec 0c             	sub    $0xc,%esp
  800c34:	89 1c 24             	mov    %ebx,(%esp)
  800c37:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c3b:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c47:	8b 55 08             	mov    0x8(%ebp),%edx
  800c4a:	89 c3                	mov    %eax,%ebx
  800c4c:	89 c7                	mov    %eax,%edi
  800c4e:	89 c6                	mov    %eax,%esi
  800c50:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800c52:	8b 1c 24             	mov    (%esp),%ebx
  800c55:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c59:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c5d:	89 ec                	mov    %ebp,%esp
  800c5f:	5d                   	pop    %ebp
  800c60:	c3                   	ret    

00800c61 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800c61:	55                   	push   %ebp
  800c62:	89 e5                	mov    %esp,%ebp
  800c64:	83 ec 38             	sub    $0x38,%esp
  800c67:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800c6a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800c6d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c70:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c75:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800c7d:	89 cb                	mov    %ecx,%ebx
  800c7f:	89 cf                	mov    %ecx,%edi
  800c81:	89 ce                	mov    %ecx,%esi
  800c83:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800c85:	85 c0                	test   %eax,%eax
  800c87:	7e 28                	jle    800cb1 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800c89:	89 44 24 10          	mov    %eax,0x10(%esp)
  800c8d:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800c94:	00 
  800c95:	c7 44 24 08 e4 14 80 	movl   $0x8014e4,0x8(%esp)
  800c9c:	00 
  800c9d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ca4:	00 
  800ca5:	c7 04 24 01 15 80 00 	movl   $0x801501,(%esp)
  800cac:	e8 e1 02 00 00       	call   800f92 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800cb1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800cb4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800cb7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800cba:	89 ec                	mov    %ebp,%esp
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	83 ec 0c             	sub    $0xc,%esp
  800cc4:	89 1c 24             	mov    %ebx,(%esp)
  800cc7:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ccb:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ccf:	be 00 00 00 00       	mov    $0x0,%esi
  800cd4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800cd9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800cdc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800cdf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ce2:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800ce7:	8b 1c 24             	mov    (%esp),%ebx
  800cea:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cee:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cf2:	89 ec                	mov    %ebp,%esp
  800cf4:	5d                   	pop    %ebp
  800cf5:	c3                   	ret    

00800cf6 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	83 ec 38             	sub    $0x38,%esp
  800cfc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cff:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d02:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d0a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d12:	8b 55 08             	mov    0x8(%ebp),%edx
  800d15:	89 df                	mov    %ebx,%edi
  800d17:	89 de                	mov    %ebx,%esi
  800d19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d1b:	85 c0                	test   %eax,%eax
  800d1d:	7e 28                	jle    800d47 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d1f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d23:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d2a:	00 
  800d2b:	c7 44 24 08 e4 14 80 	movl   $0x8014e4,0x8(%esp)
  800d32:	00 
  800d33:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d3a:	00 
  800d3b:	c7 04 24 01 15 80 00 	movl   $0x801501,(%esp)
  800d42:	e8 4b 02 00 00       	call   800f92 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d47:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d4a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d4d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d50:	89 ec                	mov    %ebp,%esp
  800d52:	5d                   	pop    %ebp
  800d53:	c3                   	ret    

00800d54 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	83 ec 38             	sub    $0x38,%esp
  800d5a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d5d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d60:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d68:	b8 08 00 00 00       	mov    $0x8,%eax
  800d6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d70:	8b 55 08             	mov    0x8(%ebp),%edx
  800d73:	89 df                	mov    %ebx,%edi
  800d75:	89 de                	mov    %ebx,%esi
  800d77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d79:	85 c0                	test   %eax,%eax
  800d7b:	7e 28                	jle    800da5 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d81:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800d88:	00 
  800d89:	c7 44 24 08 e4 14 80 	movl   $0x8014e4,0x8(%esp)
  800d90:	00 
  800d91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d98:	00 
  800d99:	c7 04 24 01 15 80 00 	movl   $0x801501,(%esp)
  800da0:	e8 ed 01 00 00       	call   800f92 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800da5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800da8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dab:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dae:	89 ec                	mov    %ebp,%esp
  800db0:	5d                   	pop    %ebp
  800db1:	c3                   	ret    

00800db2 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800db2:	55                   	push   %ebp
  800db3:	89 e5                	mov    %esp,%ebp
  800db5:	83 ec 38             	sub    $0x38,%esp
  800db8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dbb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dbe:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dc6:	b8 06 00 00 00       	mov    $0x6,%eax
  800dcb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dce:	8b 55 08             	mov    0x8(%ebp),%edx
  800dd1:	89 df                	mov    %ebx,%edi
  800dd3:	89 de                	mov    %ebx,%esi
  800dd5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd7:	85 c0                	test   %eax,%eax
  800dd9:	7e 28                	jle    800e03 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ddb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ddf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800de6:	00 
  800de7:	c7 44 24 08 e4 14 80 	movl   $0x8014e4,0x8(%esp)
  800dee:	00 
  800def:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df6:	00 
  800df7:	c7 04 24 01 15 80 00 	movl   $0x801501,(%esp)
  800dfe:	e8 8f 01 00 00       	call   800f92 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e03:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e06:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e09:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e0c:	89 ec                	mov    %ebp,%esp
  800e0e:	5d                   	pop    %ebp
  800e0f:	c3                   	ret    

00800e10 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e10:	55                   	push   %ebp
  800e11:	89 e5                	mov    %esp,%ebp
  800e13:	83 ec 38             	sub    $0x38,%esp
  800e16:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e19:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e1c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1f:	b8 05 00 00 00       	mov    $0x5,%eax
  800e24:	8b 75 18             	mov    0x18(%ebp),%esi
  800e27:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e30:	8b 55 08             	mov    0x8(%ebp),%edx
  800e33:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e35:	85 c0                	test   %eax,%eax
  800e37:	7e 28                	jle    800e61 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e39:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e3d:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e44:	00 
  800e45:	c7 44 24 08 e4 14 80 	movl   $0x8014e4,0x8(%esp)
  800e4c:	00 
  800e4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e54:	00 
  800e55:	c7 04 24 01 15 80 00 	movl   $0x801501,(%esp)
  800e5c:	e8 31 01 00 00       	call   800f92 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800e61:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e64:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e67:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e6a:	89 ec                	mov    %ebp,%esp
  800e6c:	5d                   	pop    %ebp
  800e6d:	c3                   	ret    

00800e6e <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e6e:	55                   	push   %ebp
  800e6f:	89 e5                	mov    %esp,%ebp
  800e71:	83 ec 38             	sub    $0x38,%esp
  800e74:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e77:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e7a:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e7d:	be 00 00 00 00       	mov    $0x0,%esi
  800e82:	b8 04 00 00 00       	mov    $0x4,%eax
  800e87:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800e90:	89 f7                	mov    %esi,%edi
  800e92:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e94:	85 c0                	test   %eax,%eax
  800e96:	7e 28                	jle    800ec0 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e98:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e9c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ea3:	00 
  800ea4:	c7 44 24 08 e4 14 80 	movl   $0x8014e4,0x8(%esp)
  800eab:	00 
  800eac:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb3:	00 
  800eb4:	c7 04 24 01 15 80 00 	movl   $0x801501,(%esp)
  800ebb:	e8 d2 00 00 00       	call   800f92 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ec0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ec3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ec6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ec9:	89 ec                	mov    %ebp,%esp
  800ecb:	5d                   	pop    %ebp
  800ecc:	c3                   	ret    

00800ecd <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800ecd:	55                   	push   %ebp
  800ece:	89 e5                	mov    %esp,%ebp
  800ed0:	83 ec 0c             	sub    $0xc,%esp
  800ed3:	89 1c 24             	mov    %ebx,(%esp)
  800ed6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800eda:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ede:	ba 00 00 00 00       	mov    $0x0,%edx
  800ee3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ee8:	89 d1                	mov    %edx,%ecx
  800eea:	89 d3                	mov    %edx,%ebx
  800eec:	89 d7                	mov    %edx,%edi
  800eee:	89 d6                	mov    %edx,%esi
  800ef0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ef2:	8b 1c 24             	mov    (%esp),%ebx
  800ef5:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ef9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800efd:	89 ec                	mov    %ebp,%esp
  800eff:	5d                   	pop    %ebp
  800f00:	c3                   	ret    

00800f01 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f01:	55                   	push   %ebp
  800f02:	89 e5                	mov    %esp,%ebp
  800f04:	83 ec 0c             	sub    $0xc,%esp
  800f07:	89 1c 24             	mov    %ebx,(%esp)
  800f0a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f0e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f12:	ba 00 00 00 00       	mov    $0x0,%edx
  800f17:	b8 02 00 00 00       	mov    $0x2,%eax
  800f1c:	89 d1                	mov    %edx,%ecx
  800f1e:	89 d3                	mov    %edx,%ebx
  800f20:	89 d7                	mov    %edx,%edi
  800f22:	89 d6                	mov    %edx,%esi
  800f24:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f26:	8b 1c 24             	mov    (%esp),%ebx
  800f29:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f2d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f31:	89 ec                	mov    %ebp,%esp
  800f33:	5d                   	pop    %ebp
  800f34:	c3                   	ret    

00800f35 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f35:	55                   	push   %ebp
  800f36:	89 e5                	mov    %esp,%ebp
  800f38:	83 ec 38             	sub    $0x38,%esp
  800f3b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f3e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f41:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f44:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f49:	b8 03 00 00 00       	mov    $0x3,%eax
  800f4e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f51:	89 cb                	mov    %ecx,%ebx
  800f53:	89 cf                	mov    %ecx,%edi
  800f55:	89 ce                	mov    %ecx,%esi
  800f57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	7e 28                	jle    800f85 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f61:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800f68:	00 
  800f69:	c7 44 24 08 e4 14 80 	movl   $0x8014e4,0x8(%esp)
  800f70:	00 
  800f71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f78:	00 
  800f79:	c7 04 24 01 15 80 00 	movl   $0x801501,(%esp)
  800f80:	e8 0d 00 00 00       	call   800f92 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800f85:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f88:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f8b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f8e:	89 ec                	mov    %ebp,%esp
  800f90:	5d                   	pop    %ebp
  800f91:	c3                   	ret    

00800f92 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800f92:	55                   	push   %ebp
  800f93:	89 e5                	mov    %esp,%ebp
  800f95:	56                   	push   %esi
  800f96:	53                   	push   %ebx
  800f97:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800f9a:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800f9d:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800fa3:	e8 59 ff ff ff       	call   800f01 <sys_getenvid>
  800fa8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800fab:	89 54 24 10          	mov    %edx,0x10(%esp)
  800faf:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800fb6:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800fba:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fbe:	c7 04 24 10 15 80 00 	movl   $0x801510,(%esp)
  800fc5:	e8 54 f1 ff ff       	call   80011e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800fca:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fce:	8b 45 10             	mov    0x10(%ebp),%eax
  800fd1:	89 04 24             	mov    %eax,(%esp)
  800fd4:	e8 e4 f0 ff ff       	call   8000bd <vcprintf>
	cprintf("\n");
  800fd9:	c7 04 24 34 15 80 00 	movl   $0x801534,(%esp)
  800fe0:	e8 39 f1 ff ff       	call   80011e <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800fe5:	cc                   	int3   
  800fe6:	eb fd                	jmp    800fe5 <_panic+0x53>
  800fe8:	66 90                	xchg   %ax,%ax
  800fea:	66 90                	xchg   %ax,%ax
  800fec:	66 90                	xchg   %ax,%ax
  800fee:	66 90                	xchg   %ax,%ax

00800ff0 <__udivdi3>:
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	57                   	push   %edi
  800ff4:	56                   	push   %esi
  800ff5:	83 ec 10             	sub    $0x10,%esp
  800ff8:	8b 45 14             	mov    0x14(%ebp),%eax
  800ffb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffe:	8b 75 10             	mov    0x10(%ebp),%esi
  801001:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801004:	85 c0                	test   %eax,%eax
  801006:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801009:	75 35                	jne    801040 <__udivdi3+0x50>
  80100b:	39 fe                	cmp    %edi,%esi
  80100d:	77 61                	ja     801070 <__udivdi3+0x80>
  80100f:	85 f6                	test   %esi,%esi
  801011:	75 0b                	jne    80101e <__udivdi3+0x2e>
  801013:	b8 01 00 00 00       	mov    $0x1,%eax
  801018:	31 d2                	xor    %edx,%edx
  80101a:	f7 f6                	div    %esi
  80101c:	89 c6                	mov    %eax,%esi
  80101e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801021:	31 d2                	xor    %edx,%edx
  801023:	89 f8                	mov    %edi,%eax
  801025:	f7 f6                	div    %esi
  801027:	89 c7                	mov    %eax,%edi
  801029:	89 c8                	mov    %ecx,%eax
  80102b:	f7 f6                	div    %esi
  80102d:	89 c1                	mov    %eax,%ecx
  80102f:	89 fa                	mov    %edi,%edx
  801031:	89 c8                	mov    %ecx,%eax
  801033:	83 c4 10             	add    $0x10,%esp
  801036:	5e                   	pop    %esi
  801037:	5f                   	pop    %edi
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    
  80103a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801040:	39 f8                	cmp    %edi,%eax
  801042:	77 1c                	ja     801060 <__udivdi3+0x70>
  801044:	0f bd d0             	bsr    %eax,%edx
  801047:	83 f2 1f             	xor    $0x1f,%edx
  80104a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80104d:	75 39                	jne    801088 <__udivdi3+0x98>
  80104f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801052:	0f 86 a0 00 00 00    	jbe    8010f8 <__udivdi3+0x108>
  801058:	39 f8                	cmp    %edi,%eax
  80105a:	0f 82 98 00 00 00    	jb     8010f8 <__udivdi3+0x108>
  801060:	31 ff                	xor    %edi,%edi
  801062:	31 c9                	xor    %ecx,%ecx
  801064:	89 c8                	mov    %ecx,%eax
  801066:	89 fa                	mov    %edi,%edx
  801068:	83 c4 10             	add    $0x10,%esp
  80106b:	5e                   	pop    %esi
  80106c:	5f                   	pop    %edi
  80106d:	5d                   	pop    %ebp
  80106e:	c3                   	ret    
  80106f:	90                   	nop
  801070:	89 d1                	mov    %edx,%ecx
  801072:	89 fa                	mov    %edi,%edx
  801074:	89 c8                	mov    %ecx,%eax
  801076:	31 ff                	xor    %edi,%edi
  801078:	f7 f6                	div    %esi
  80107a:	89 c1                	mov    %eax,%ecx
  80107c:	89 fa                	mov    %edi,%edx
  80107e:	89 c8                	mov    %ecx,%eax
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	5e                   	pop    %esi
  801084:	5f                   	pop    %edi
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    
  801087:	90                   	nop
  801088:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80108c:	89 f2                	mov    %esi,%edx
  80108e:	d3 e0                	shl    %cl,%eax
  801090:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801093:	b8 20 00 00 00       	mov    $0x20,%eax
  801098:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80109b:	89 c1                	mov    %eax,%ecx
  80109d:	d3 ea                	shr    %cl,%edx
  80109f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010a3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8010a6:	d3 e6                	shl    %cl,%esi
  8010a8:	89 c1                	mov    %eax,%ecx
  8010aa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8010ad:	89 fe                	mov    %edi,%esi
  8010af:	d3 ee                	shr    %cl,%esi
  8010b1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010b5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010bb:	d3 e7                	shl    %cl,%edi
  8010bd:	89 c1                	mov    %eax,%ecx
  8010bf:	d3 ea                	shr    %cl,%edx
  8010c1:	09 d7                	or     %edx,%edi
  8010c3:	89 f2                	mov    %esi,%edx
  8010c5:	89 f8                	mov    %edi,%eax
  8010c7:	f7 75 ec             	divl   -0x14(%ebp)
  8010ca:	89 d6                	mov    %edx,%esi
  8010cc:	89 c7                	mov    %eax,%edi
  8010ce:	f7 65 e8             	mull   -0x18(%ebp)
  8010d1:	39 d6                	cmp    %edx,%esi
  8010d3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010d6:	72 30                	jb     801108 <__udivdi3+0x118>
  8010d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010db:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010df:	d3 e2                	shl    %cl,%edx
  8010e1:	39 c2                	cmp    %eax,%edx
  8010e3:	73 05                	jae    8010ea <__udivdi3+0xfa>
  8010e5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8010e8:	74 1e                	je     801108 <__udivdi3+0x118>
  8010ea:	89 f9                	mov    %edi,%ecx
  8010ec:	31 ff                	xor    %edi,%edi
  8010ee:	e9 71 ff ff ff       	jmp    801064 <__udivdi3+0x74>
  8010f3:	90                   	nop
  8010f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010f8:	31 ff                	xor    %edi,%edi
  8010fa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8010ff:	e9 60 ff ff ff       	jmp    801064 <__udivdi3+0x74>
  801104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801108:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80110b:	31 ff                	xor    %edi,%edi
  80110d:	89 c8                	mov    %ecx,%eax
  80110f:	89 fa                	mov    %edi,%edx
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	5e                   	pop    %esi
  801115:	5f                   	pop    %edi
  801116:	5d                   	pop    %ebp
  801117:	c3                   	ret    
  801118:	66 90                	xchg   %ax,%ax
  80111a:	66 90                	xchg   %ax,%ax
  80111c:	66 90                	xchg   %ax,%ax
  80111e:	66 90                	xchg   %ax,%ax

00801120 <__umoddi3>:
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	57                   	push   %edi
  801124:	56                   	push   %esi
  801125:	83 ec 20             	sub    $0x20,%esp
  801128:	8b 55 14             	mov    0x14(%ebp),%edx
  80112b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801131:	8b 75 0c             	mov    0xc(%ebp),%esi
  801134:	85 d2                	test   %edx,%edx
  801136:	89 c8                	mov    %ecx,%eax
  801138:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80113b:	75 13                	jne    801150 <__umoddi3+0x30>
  80113d:	39 f7                	cmp    %esi,%edi
  80113f:	76 3f                	jbe    801180 <__umoddi3+0x60>
  801141:	89 f2                	mov    %esi,%edx
  801143:	f7 f7                	div    %edi
  801145:	89 d0                	mov    %edx,%eax
  801147:	31 d2                	xor    %edx,%edx
  801149:	83 c4 20             	add    $0x20,%esp
  80114c:	5e                   	pop    %esi
  80114d:	5f                   	pop    %edi
  80114e:	5d                   	pop    %ebp
  80114f:	c3                   	ret    
  801150:	39 f2                	cmp    %esi,%edx
  801152:	77 4c                	ja     8011a0 <__umoddi3+0x80>
  801154:	0f bd ca             	bsr    %edx,%ecx
  801157:	83 f1 1f             	xor    $0x1f,%ecx
  80115a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80115d:	75 51                	jne    8011b0 <__umoddi3+0x90>
  80115f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801162:	0f 87 e0 00 00 00    	ja     801248 <__umoddi3+0x128>
  801168:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116b:	29 f8                	sub    %edi,%eax
  80116d:	19 d6                	sbb    %edx,%esi
  80116f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801172:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801175:	89 f2                	mov    %esi,%edx
  801177:	83 c4 20             	add    $0x20,%esp
  80117a:	5e                   	pop    %esi
  80117b:	5f                   	pop    %edi
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    
  80117e:	66 90                	xchg   %ax,%ax
  801180:	85 ff                	test   %edi,%edi
  801182:	75 0b                	jne    80118f <__umoddi3+0x6f>
  801184:	b8 01 00 00 00       	mov    $0x1,%eax
  801189:	31 d2                	xor    %edx,%edx
  80118b:	f7 f7                	div    %edi
  80118d:	89 c7                	mov    %eax,%edi
  80118f:	89 f0                	mov    %esi,%eax
  801191:	31 d2                	xor    %edx,%edx
  801193:	f7 f7                	div    %edi
  801195:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801198:	f7 f7                	div    %edi
  80119a:	eb a9                	jmp    801145 <__umoddi3+0x25>
  80119c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011a0:	89 c8                	mov    %ecx,%eax
  8011a2:	89 f2                	mov    %esi,%edx
  8011a4:	83 c4 20             	add    $0x20,%esp
  8011a7:	5e                   	pop    %esi
  8011a8:	5f                   	pop    %edi
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    
  8011ab:	90                   	nop
  8011ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011b0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011b4:	d3 e2                	shl    %cl,%edx
  8011b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011b9:	ba 20 00 00 00       	mov    $0x20,%edx
  8011be:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8011c1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8011c4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011c8:	89 fa                	mov    %edi,%edx
  8011ca:	d3 ea                	shr    %cl,%edx
  8011cc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011d0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8011d3:	d3 e7                	shl    %cl,%edi
  8011d5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011dc:	89 f2                	mov    %esi,%edx
  8011de:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8011e1:	89 c7                	mov    %eax,%edi
  8011e3:	d3 ea                	shr    %cl,%edx
  8011e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8011ec:	89 c2                	mov    %eax,%edx
  8011ee:	d3 e6                	shl    %cl,%esi
  8011f0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011f4:	d3 ea                	shr    %cl,%edx
  8011f6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011fa:	09 d6                	or     %edx,%esi
  8011fc:	89 f0                	mov    %esi,%eax
  8011fe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801201:	d3 e7                	shl    %cl,%edi
  801203:	89 f2                	mov    %esi,%edx
  801205:	f7 75 f4             	divl   -0xc(%ebp)
  801208:	89 d6                	mov    %edx,%esi
  80120a:	f7 65 e8             	mull   -0x18(%ebp)
  80120d:	39 d6                	cmp    %edx,%esi
  80120f:	72 2b                	jb     80123c <__umoddi3+0x11c>
  801211:	39 c7                	cmp    %eax,%edi
  801213:	72 23                	jb     801238 <__umoddi3+0x118>
  801215:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801219:	29 c7                	sub    %eax,%edi
  80121b:	19 d6                	sbb    %edx,%esi
  80121d:	89 f0                	mov    %esi,%eax
  80121f:	89 f2                	mov    %esi,%edx
  801221:	d3 ef                	shr    %cl,%edi
  801223:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801227:	d3 e0                	shl    %cl,%eax
  801229:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80122d:	09 f8                	or     %edi,%eax
  80122f:	d3 ea                	shr    %cl,%edx
  801231:	83 c4 20             	add    $0x20,%esp
  801234:	5e                   	pop    %esi
  801235:	5f                   	pop    %edi
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    
  801238:	39 d6                	cmp    %edx,%esi
  80123a:	75 d9                	jne    801215 <__umoddi3+0xf5>
  80123c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80123f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801242:	eb d1                	jmp    801215 <__umoddi3+0xf5>
  801244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801248:	39 f2                	cmp    %esi,%edx
  80124a:	0f 82 18 ff ff ff    	jb     801168 <__umoddi3+0x48>
  801250:	e9 1d ff ff ff       	jmp    801172 <__umoddi3+0x52>
