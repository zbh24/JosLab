
obj/user/spin：     文件格式 elf32-i386


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
  80002c:	e8 8e 00 00 00       	call   8000bf <libmain>
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

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	53                   	push   %ebx
  800044:	83 ec 14             	sub    $0x14,%esp
	envid_t env;

	cprintf("I am the parent.  Forking the child...\n");
  800047:	c7 04 24 20 13 80 00 	movl   $0x801320,(%esp)
  80004e:	e8 3a 01 00 00       	call   80018d <cprintf>
	if ((env = fork()) == 0) {
  800053:	e8 cc 0f 00 00       	call   801024 <fork>
  800058:	89 c3                	mov    %eax,%ebx
  80005a:	85 c0                	test   %eax,%eax
  80005c:	75 0e                	jne    80006c <umain+0x2c>
		cprintf("I am the child.  Spinning...\n");
  80005e:	c7 04 24 98 13 80 00 	movl   $0x801398,(%esp)
  800065:	e8 23 01 00 00       	call   80018d <cprintf>
  80006a:	eb fe                	jmp    80006a <umain+0x2a>
		while (1)
			/* do nothing */;
	}

	cprintf("I am the parent.  Running the child...\n");
  80006c:	c7 04 24 48 13 80 00 	movl   $0x801348,(%esp)
  800073:	e8 15 01 00 00       	call   80018d <cprintf>
	sys_yield();
  800078:	e8 c0 0e 00 00       	call   800f3d <sys_yield>
	sys_yield();
  80007d:	e8 bb 0e 00 00       	call   800f3d <sys_yield>
	sys_yield();
  800082:	e8 b6 0e 00 00       	call   800f3d <sys_yield>
	sys_yield();
  800087:	e8 b1 0e 00 00       	call   800f3d <sys_yield>
	sys_yield();
  80008c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800090:	e8 a8 0e 00 00       	call   800f3d <sys_yield>
	sys_yield();
  800095:	e8 a3 0e 00 00       	call   800f3d <sys_yield>
	sys_yield();
  80009a:	e8 9e 0e 00 00       	call   800f3d <sys_yield>
	sys_yield();
  80009f:	90                   	nop
  8000a0:	e8 98 0e 00 00       	call   800f3d <sys_yield>

	cprintf("I am the parent.  Killing the child...\n");
  8000a5:	c7 04 24 70 13 80 00 	movl   $0x801370,(%esp)
  8000ac:	e8 dc 00 00 00       	call   80018d <cprintf>
	sys_env_destroy(env);
  8000b1:	89 1c 24             	mov    %ebx,(%esp)
  8000b4:	e8 ec 0e 00 00       	call   800fa5 <sys_env_destroy>
}
  8000b9:	83 c4 14             	add    $0x14,%esp
  8000bc:	5b                   	pop    %ebx
  8000bd:	5d                   	pop    %ebp
  8000be:	c3                   	ret    

008000bf <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000bf:	55                   	push   %ebp
  8000c0:	89 e5                	mov    %esp,%ebp
  8000c2:	83 ec 18             	sub    $0x18,%esp
  8000c5:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000c8:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000cb:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000d1:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000d8:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8000db:	e8 91 0e 00 00       	call   800f71 <sys_getenvid>
  8000e0:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e5:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e8:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000ed:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000f2:	85 f6                	test   %esi,%esi
  8000f4:	7e 07                	jle    8000fd <libmain+0x3e>
		binaryname = argv[0];
  8000f6:	8b 03                	mov    (%ebx),%eax
  8000f8:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000fd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800101:	89 34 24             	mov    %esi,(%esp)
  800104:	e8 37 ff ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  800109:	e8 0a 00 00 00       	call   800118 <exit>
}
  80010e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800111:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800114:	89 ec                	mov    %ebp,%esp
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80011e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800125:	e8 7b 0e 00 00       	call   800fa5 <sys_env_destroy>
}
  80012a:	c9                   	leave  
  80012b:	c3                   	ret    

0080012c <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800135:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80013c:	00 00 00 
	b.cnt = 0;
  80013f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800146:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800149:	8b 45 0c             	mov    0xc(%ebp),%eax
  80014c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800150:	8b 45 08             	mov    0x8(%ebp),%eax
  800153:	89 44 24 08          	mov    %eax,0x8(%esp)
  800157:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80015d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800161:	c7 04 24 a7 01 80 00 	movl   $0x8001a7,(%esp)
  800168:	e8 d0 01 00 00       	call   80033d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80016d:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800173:	89 44 24 04          	mov    %eax,0x4(%esp)
  800177:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80017d:	89 04 24             	mov    %eax,(%esp)
  800180:	e8 19 0b 00 00       	call   800c9e <sys_cputs>

	return b.cnt;
}
  800185:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018b:	c9                   	leave  
  80018c:	c3                   	ret    

0080018d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018d:	55                   	push   %ebp
  80018e:	89 e5                	mov    %esp,%ebp
  800190:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800193:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800196:	89 44 24 04          	mov    %eax,0x4(%esp)
  80019a:	8b 45 08             	mov    0x8(%ebp),%eax
  80019d:	89 04 24             	mov    %eax,(%esp)
  8001a0:	e8 87 ff ff ff       	call   80012c <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001a7:	55                   	push   %ebp
  8001a8:	89 e5                	mov    %esp,%ebp
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 14             	sub    $0x14,%esp
  8001ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001b1:	8b 03                	mov    (%ebx),%eax
  8001b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b6:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001ba:	83 c0 01             	add    $0x1,%eax
  8001bd:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001bf:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001c4:	75 19                	jne    8001df <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001c6:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001cd:	00 
  8001ce:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d1:	89 04 24             	mov    %eax,(%esp)
  8001d4:	e8 c5 0a 00 00       	call   800c9e <sys_cputs>
		b->idx = 0;
  8001d9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001df:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001e3:	83 c4 14             	add    $0x14,%esp
  8001e6:	5b                   	pop    %ebx
  8001e7:	5d                   	pop    %ebp
  8001e8:	c3                   	ret    
  8001e9:	66 90                	xchg   %ax,%ax
  8001eb:	66 90                	xchg   %ax,%ax
  8001ed:	66 90                	xchg   %ax,%ax
  8001ef:	90                   	nop

008001f0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001f0:	55                   	push   %ebp
  8001f1:	89 e5                	mov    %esp,%ebp
  8001f3:	57                   	push   %edi
  8001f4:	56                   	push   %esi
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 4c             	sub    $0x4c,%esp
  8001f9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001fc:	89 d6                	mov    %edx,%esi
  8001fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800201:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800204:	8b 55 0c             	mov    0xc(%ebp),%edx
  800207:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80020a:	8b 45 10             	mov    0x10(%ebp),%eax
  80020d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800210:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800213:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800216:	b9 00 00 00 00       	mov    $0x0,%ecx
  80021b:	39 d1                	cmp    %edx,%ecx
  80021d:	72 15                	jb     800234 <printnum+0x44>
  80021f:	77 07                	ja     800228 <printnum+0x38>
  800221:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800224:	39 d0                	cmp    %edx,%eax
  800226:	76 0c                	jbe    800234 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800228:	83 eb 01             	sub    $0x1,%ebx
  80022b:	85 db                	test   %ebx,%ebx
  80022d:	8d 76 00             	lea    0x0(%esi),%esi
  800230:	7f 61                	jg     800293 <printnum+0xa3>
  800232:	eb 70                	jmp    8002a4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800234:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800238:	83 eb 01             	sub    $0x1,%ebx
  80023b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80023f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800243:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800247:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80024b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80024e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800251:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800254:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800258:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80025f:	00 
  800260:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800263:	89 04 24             	mov    %eax,(%esp)
  800266:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800269:	89 54 24 04          	mov    %edx,0x4(%esp)
  80026d:	e8 2e 0e 00 00       	call   8010a0 <__udivdi3>
  800272:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800275:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800278:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80027c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800280:	89 04 24             	mov    %eax,(%esp)
  800283:	89 54 24 04          	mov    %edx,0x4(%esp)
  800287:	89 f2                	mov    %esi,%edx
  800289:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80028c:	e8 5f ff ff ff       	call   8001f0 <printnum>
  800291:	eb 11                	jmp    8002a4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800293:	89 74 24 04          	mov    %esi,0x4(%esp)
  800297:	89 3c 24             	mov    %edi,(%esp)
  80029a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80029d:	83 eb 01             	sub    $0x1,%ebx
  8002a0:	85 db                	test   %ebx,%ebx
  8002a2:	7f ef                	jg     800293 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002a8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002ac:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ba:	00 
  8002bb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002be:	89 14 24             	mov    %edx,(%esp)
  8002c1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002c4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002c8:	e8 03 0f 00 00       	call   8011d0 <__umoddi3>
  8002cd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d1:	0f be 80 c0 13 80 00 	movsbl 0x8013c0(%eax),%eax
  8002d8:	89 04 24             	mov    %eax,(%esp)
  8002db:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002de:	83 c4 4c             	add    $0x4c,%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002e9:	83 fa 01             	cmp    $0x1,%edx
  8002ec:	7e 0e                	jle    8002fc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ee:	8b 10                	mov    (%eax),%edx
  8002f0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002f3:	89 08                	mov    %ecx,(%eax)
  8002f5:	8b 02                	mov    (%edx),%eax
  8002f7:	8b 52 04             	mov    0x4(%edx),%edx
  8002fa:	eb 22                	jmp    80031e <getuint+0x38>
	else if (lflag)
  8002fc:	85 d2                	test   %edx,%edx
  8002fe:	74 10                	je     800310 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800300:	8b 10                	mov    (%eax),%edx
  800302:	8d 4a 04             	lea    0x4(%edx),%ecx
  800305:	89 08                	mov    %ecx,(%eax)
  800307:	8b 02                	mov    (%edx),%eax
  800309:	ba 00 00 00 00       	mov    $0x0,%edx
  80030e:	eb 0e                	jmp    80031e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800310:	8b 10                	mov    (%eax),%edx
  800312:	8d 4a 04             	lea    0x4(%edx),%ecx
  800315:	89 08                	mov    %ecx,(%eax)
  800317:	8b 02                	mov    (%edx),%eax
  800319:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80031e:	5d                   	pop    %ebp
  80031f:	c3                   	ret    

00800320 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800326:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80032a:	8b 10                	mov    (%eax),%edx
  80032c:	3b 50 04             	cmp    0x4(%eax),%edx
  80032f:	73 0a                	jae    80033b <sprintputch+0x1b>
		*b->buf++ = ch;
  800331:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800334:	88 0a                	mov    %cl,(%edx)
  800336:	83 c2 01             	add    $0x1,%edx
  800339:	89 10                	mov    %edx,(%eax)
}
  80033b:	5d                   	pop    %ebp
  80033c:	c3                   	ret    

0080033d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80033d:	55                   	push   %ebp
  80033e:	89 e5                	mov    %esp,%ebp
  800340:	57                   	push   %edi
  800341:	56                   	push   %esi
  800342:	53                   	push   %ebx
  800343:	83 ec 5c             	sub    $0x5c,%esp
  800346:	8b 7d 08             	mov    0x8(%ebp),%edi
  800349:	8b 75 0c             	mov    0xc(%ebp),%esi
  80034c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80034f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800356:	eb 11                	jmp    800369 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800358:	85 c0                	test   %eax,%eax
  80035a:	0f 84 16 04 00 00    	je     800776 <vprintfmt+0x439>
				return;
			putch(ch, putdat);
  800360:	89 74 24 04          	mov    %esi,0x4(%esp)
  800364:	89 04 24             	mov    %eax,(%esp)
  800367:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800369:	0f b6 03             	movzbl (%ebx),%eax
  80036c:	83 c3 01             	add    $0x1,%ebx
  80036f:	83 f8 25             	cmp    $0x25,%eax
  800372:	75 e4                	jne    800358 <vprintfmt+0x1b>
  800374:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80037b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800382:	b9 00 00 00 00       	mov    $0x0,%ecx
  800387:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80038b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800392:	eb 06                	jmp    80039a <vprintfmt+0x5d>
  800394:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800398:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80039a:	0f b6 13             	movzbl (%ebx),%edx
  80039d:	0f b6 c2             	movzbl %dl,%eax
  8003a0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003a3:	8d 43 01             	lea    0x1(%ebx),%eax
  8003a6:	83 ea 23             	sub    $0x23,%edx
  8003a9:	80 fa 55             	cmp    $0x55,%dl
  8003ac:	0f 87 a7 03 00 00    	ja     800759 <vprintfmt+0x41c>
  8003b2:	0f b6 d2             	movzbl %dl,%edx
  8003b5:	ff 24 95 80 14 80 00 	jmp    *0x801480(,%edx,4)
  8003bc:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003c0:	eb d6                	jmp    800398 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003c2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003c5:	83 ea 30             	sub    $0x30,%edx
  8003c8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8003cb:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003ce:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003d1:	83 fb 09             	cmp    $0x9,%ebx
  8003d4:	77 54                	ja     80042a <vprintfmt+0xed>
  8003d6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003d9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003dc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8003df:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003e2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8003e6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003e9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003ec:	83 fb 09             	cmp    $0x9,%ebx
  8003ef:	76 eb                	jbe    8003dc <vprintfmt+0x9f>
  8003f1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8003f4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003f7:	eb 31                	jmp    80042a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003f9:	8b 55 14             	mov    0x14(%ebp),%edx
  8003fc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8003ff:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800402:	8b 12                	mov    (%edx),%edx
  800404:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800407:	eb 21                	jmp    80042a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800409:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80040d:	ba 00 00 00 00       	mov    $0x0,%edx
  800412:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  800416:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800419:	e9 7a ff ff ff       	jmp    800398 <vprintfmt+0x5b>
  80041e:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800425:	e9 6e ff ff ff       	jmp    800398 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80042a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80042e:	0f 89 64 ff ff ff    	jns    800398 <vprintfmt+0x5b>
  800434:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800437:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80043a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80043d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800440:	e9 53 ff ff ff       	jmp    800398 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800445:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800448:	e9 4b ff ff ff       	jmp    800398 <vprintfmt+0x5b>
  80044d:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800450:	8b 45 14             	mov    0x14(%ebp),%eax
  800453:	8d 50 04             	lea    0x4(%eax),%edx
  800456:	89 55 14             	mov    %edx,0x14(%ebp)
  800459:	89 74 24 04          	mov    %esi,0x4(%esp)
  80045d:	8b 00                	mov    (%eax),%eax
  80045f:	89 04 24             	mov    %eax,(%esp)
  800462:	ff d7                	call   *%edi
  800464:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800467:	e9 fd fe ff ff       	jmp    800369 <vprintfmt+0x2c>
  80046c:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80046f:	8b 45 14             	mov    0x14(%ebp),%eax
  800472:	8d 50 04             	lea    0x4(%eax),%edx
  800475:	89 55 14             	mov    %edx,0x14(%ebp)
  800478:	8b 00                	mov    (%eax),%eax
  80047a:	89 c2                	mov    %eax,%edx
  80047c:	c1 fa 1f             	sar    $0x1f,%edx
  80047f:	31 d0                	xor    %edx,%eax
  800481:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800483:	83 f8 08             	cmp    $0x8,%eax
  800486:	7f 0b                	jg     800493 <vprintfmt+0x156>
  800488:	8b 14 85 e0 15 80 00 	mov    0x8015e0(,%eax,4),%edx
  80048f:	85 d2                	test   %edx,%edx
  800491:	75 20                	jne    8004b3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800493:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800497:	c7 44 24 08 d1 13 80 	movl   $0x8013d1,0x8(%esp)
  80049e:	00 
  80049f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a3:	89 3c 24             	mov    %edi,(%esp)
  8004a6:	e8 53 03 00 00       	call   8007fe <printfmt>
  8004ab:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ae:	e9 b6 fe ff ff       	jmp    800369 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004b3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004b7:	c7 44 24 08 da 13 80 	movl   $0x8013da,0x8(%esp)
  8004be:	00 
  8004bf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004c3:	89 3c 24             	mov    %edi,(%esp)
  8004c6:	e8 33 03 00 00       	call   8007fe <printfmt>
  8004cb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ce:	e9 96 fe ff ff       	jmp    800369 <vprintfmt+0x2c>
  8004d3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004d6:	89 c3                	mov    %eax,%ebx
  8004d8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004db:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004de:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e4:	8d 50 04             	lea    0x4(%eax),%edx
  8004e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ea:	8b 00                	mov    (%eax),%eax
  8004ec:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8004ef:	85 c0                	test   %eax,%eax
  8004f1:	b8 dd 13 80 00       	mov    $0x8013dd,%eax
  8004f6:	0f 45 45 c4          	cmovne -0x3c(%ebp),%eax
  8004fa:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8004fd:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800501:	7e 06                	jle    800509 <vprintfmt+0x1cc>
  800503:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800507:	75 13                	jne    80051c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800509:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80050c:	0f be 02             	movsbl (%edx),%eax
  80050f:	85 c0                	test   %eax,%eax
  800511:	0f 85 9b 00 00 00    	jne    8005b2 <vprintfmt+0x275>
  800517:	e9 88 00 00 00       	jmp    8005a4 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80051c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800520:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  800523:	89 0c 24             	mov    %ecx,(%esp)
  800526:	e8 20 03 00 00       	call   80084b <strnlen>
  80052b:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80052e:	29 c2                	sub    %eax,%edx
  800530:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800533:	85 d2                	test   %edx,%edx
  800535:	7e d2                	jle    800509 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800537:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  80053b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80053e:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800541:	89 d3                	mov    %edx,%ebx
  800543:	89 74 24 04          	mov    %esi,0x4(%esp)
  800547:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80054a:	89 04 24             	mov    %eax,(%esp)
  80054d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80054f:	83 eb 01             	sub    $0x1,%ebx
  800552:	85 db                	test   %ebx,%ebx
  800554:	7f ed                	jg     800543 <vprintfmt+0x206>
  800556:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  800559:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800560:	eb a7                	jmp    800509 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800562:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800566:	74 1a                	je     800582 <vprintfmt+0x245>
  800568:	8d 50 e0             	lea    -0x20(%eax),%edx
  80056b:	83 fa 5e             	cmp    $0x5e,%edx
  80056e:	76 12                	jbe    800582 <vprintfmt+0x245>
					putch('?', putdat);
  800570:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800574:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80057b:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80057e:	66 90                	xchg   %ax,%ax
  800580:	eb 0a                	jmp    80058c <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800582:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800586:	89 04 24             	mov    %eax,(%esp)
  800589:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80058c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800590:	0f be 03             	movsbl (%ebx),%eax
  800593:	85 c0                	test   %eax,%eax
  800595:	74 05                	je     80059c <vprintfmt+0x25f>
  800597:	83 c3 01             	add    $0x1,%ebx
  80059a:	eb 29                	jmp    8005c5 <vprintfmt+0x288>
  80059c:	89 fe                	mov    %edi,%esi
  80059e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005a1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005a4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005a8:	7f 2e                	jg     8005d8 <vprintfmt+0x29b>
  8005aa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005ad:	e9 b7 fd ff ff       	jmp    800369 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005b5:	83 c2 01             	add    $0x1,%edx
  8005b8:	89 7d dc             	mov    %edi,-0x24(%ebp)
  8005bb:	89 f7                	mov    %esi,%edi
  8005bd:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005c0:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8005c3:	89 d3                	mov    %edx,%ebx
  8005c5:	85 f6                	test   %esi,%esi
  8005c7:	78 99                	js     800562 <vprintfmt+0x225>
  8005c9:	83 ee 01             	sub    $0x1,%esi
  8005cc:	79 94                	jns    800562 <vprintfmt+0x225>
  8005ce:	89 fe                	mov    %edi,%esi
  8005d0:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005d3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8005d6:	eb cc                	jmp    8005a4 <vprintfmt+0x267>
  8005d8:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8005db:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005e2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005e9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005eb:	83 eb 01             	sub    $0x1,%ebx
  8005ee:	85 db                	test   %ebx,%ebx
  8005f0:	7f ec                	jg     8005de <vprintfmt+0x2a1>
  8005f2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005f5:	e9 6f fd ff ff       	jmp    800369 <vprintfmt+0x2c>
  8005fa:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005fd:	83 f9 01             	cmp    $0x1,%ecx
  800600:	7e 16                	jle    800618 <vprintfmt+0x2db>
		return va_arg(*ap, long long);
  800602:	8b 45 14             	mov    0x14(%ebp),%eax
  800605:	8d 50 08             	lea    0x8(%eax),%edx
  800608:	89 55 14             	mov    %edx,0x14(%ebp)
  80060b:	8b 10                	mov    (%eax),%edx
  80060d:	8b 48 04             	mov    0x4(%eax),%ecx
  800610:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800613:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800616:	eb 32                	jmp    80064a <vprintfmt+0x30d>
	else if (lflag)
  800618:	85 c9                	test   %ecx,%ecx
  80061a:	74 18                	je     800634 <vprintfmt+0x2f7>
		return va_arg(*ap, long);
  80061c:	8b 45 14             	mov    0x14(%ebp),%eax
  80061f:	8d 50 04             	lea    0x4(%eax),%edx
  800622:	89 55 14             	mov    %edx,0x14(%ebp)
  800625:	8b 00                	mov    (%eax),%eax
  800627:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80062a:	89 c1                	mov    %eax,%ecx
  80062c:	c1 f9 1f             	sar    $0x1f,%ecx
  80062f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800632:	eb 16                	jmp    80064a <vprintfmt+0x30d>
	else
		return va_arg(*ap, int);
  800634:	8b 45 14             	mov    0x14(%ebp),%eax
  800637:	8d 50 04             	lea    0x4(%eax),%edx
  80063a:	89 55 14             	mov    %edx,0x14(%ebp)
  80063d:	8b 00                	mov    (%eax),%eax
  80063f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800642:	89 c2                	mov    %eax,%edx
  800644:	c1 fa 1f             	sar    $0x1f,%edx
  800647:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80064a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80064d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800650:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800655:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800659:	0f 89 b8 00 00 00    	jns    800717 <vprintfmt+0x3da>
				putch('-', putdat);
  80065f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800663:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80066a:	ff d7                	call   *%edi
				num = -(long long) num;
  80066c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80066f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800672:	f7 d9                	neg    %ecx
  800674:	83 d3 00             	adc    $0x0,%ebx
  800677:	f7 db                	neg    %ebx
  800679:	b8 0a 00 00 00       	mov    $0xa,%eax
  80067e:	e9 94 00 00 00       	jmp    800717 <vprintfmt+0x3da>
  800683:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800686:	89 ca                	mov    %ecx,%edx
  800688:	8d 45 14             	lea    0x14(%ebp),%eax
  80068b:	e8 56 fc ff ff       	call   8002e6 <getuint>
  800690:	89 c1                	mov    %eax,%ecx
  800692:	89 d3                	mov    %edx,%ebx
  800694:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800699:	eb 7c                	jmp    800717 <vprintfmt+0x3da>
  80069b:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80069e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a2:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006a9:	ff d7                	call   *%edi
			putch('X', putdat);
  8006ab:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006af:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006b6:	ff d7                	call   *%edi
			putch('X', putdat);
  8006b8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006bc:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006c3:	ff d7                	call   *%edi
  8006c5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8006c8:	e9 9c fc ff ff       	jmp    800369 <vprintfmt+0x2c>
  8006cd:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8006d0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006db:	ff d7                	call   *%edi
			putch('x', putdat);
  8006dd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006e1:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006e8:	ff d7                	call   *%edi
			num = (unsigned long long)
  8006ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ed:	8d 50 04             	lea    0x4(%eax),%edx
  8006f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006f3:	8b 08                	mov    (%eax),%ecx
  8006f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006fa:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006ff:	eb 16                	jmp    800717 <vprintfmt+0x3da>
  800701:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800704:	89 ca                	mov    %ecx,%edx
  800706:	8d 45 14             	lea    0x14(%ebp),%eax
  800709:	e8 d8 fb ff ff       	call   8002e6 <getuint>
  80070e:	89 c1                	mov    %eax,%ecx
  800710:	89 d3                	mov    %edx,%ebx
  800712:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800717:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80071b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80071f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800722:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800726:	89 44 24 08          	mov    %eax,0x8(%esp)
  80072a:	89 0c 24             	mov    %ecx,(%esp)
  80072d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800731:	89 f2                	mov    %esi,%edx
  800733:	89 f8                	mov    %edi,%eax
  800735:	e8 b6 fa ff ff       	call   8001f0 <printnum>
  80073a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80073d:	e9 27 fc ff ff       	jmp    800369 <vprintfmt+0x2c>
  800742:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800745:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800748:	89 74 24 04          	mov    %esi,0x4(%esp)
  80074c:	89 14 24             	mov    %edx,(%esp)
  80074f:	ff d7                	call   *%edi
  800751:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800754:	e9 10 fc ff ff       	jmp    800369 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800759:	89 74 24 04          	mov    %esi,0x4(%esp)
  80075d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800764:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800766:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800769:	80 38 25             	cmpb   $0x25,(%eax)
  80076c:	0f 84 f7 fb ff ff    	je     800369 <vprintfmt+0x2c>
  800772:	89 c3                	mov    %eax,%ebx
  800774:	eb f0                	jmp    800766 <vprintfmt+0x429>
				/* do nothing */;
			break;
		}
	}
}
  800776:	83 c4 5c             	add    $0x5c,%esp
  800779:	5b                   	pop    %ebx
  80077a:	5e                   	pop    %esi
  80077b:	5f                   	pop    %edi
  80077c:	5d                   	pop    %ebp
  80077d:	c3                   	ret    

0080077e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	83 ec 28             	sub    $0x28,%esp
  800784:	8b 45 08             	mov    0x8(%ebp),%eax
  800787:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80078a:	85 c0                	test   %eax,%eax
  80078c:	74 04                	je     800792 <vsnprintf+0x14>
  80078e:	85 d2                	test   %edx,%edx
  800790:	7f 07                	jg     800799 <vsnprintf+0x1b>
  800792:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800797:	eb 3b                	jmp    8007d4 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800799:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80079c:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8007a0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007a3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007b1:	8b 45 10             	mov    0x10(%ebp),%eax
  8007b4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007b8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007bb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007bf:	c7 04 24 20 03 80 00 	movl   $0x800320,(%esp)
  8007c6:	e8 72 fb ff ff       	call   80033d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007cb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ce:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007d4:	c9                   	leave  
  8007d5:	c3                   	ret    

008007d6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007d6:	55                   	push   %ebp
  8007d7:	89 e5                	mov    %esp,%ebp
  8007d9:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8007dc:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8007df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007e3:	8b 45 10             	mov    0x10(%ebp),%eax
  8007e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f4:	89 04 24             	mov    %eax,(%esp)
  8007f7:	e8 82 ff ff ff       	call   80077e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007fc:	c9                   	leave  
  8007fd:	c3                   	ret    

008007fe <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800804:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800807:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80080b:	8b 45 10             	mov    0x10(%ebp),%eax
  80080e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800812:	8b 45 0c             	mov    0xc(%ebp),%eax
  800815:	89 44 24 04          	mov    %eax,0x4(%esp)
  800819:	8b 45 08             	mov    0x8(%ebp),%eax
  80081c:	89 04 24             	mov    %eax,(%esp)
  80081f:	e8 19 fb ff ff       	call   80033d <vprintfmt>
	va_end(ap);
}
  800824:	c9                   	leave  
  800825:	c3                   	ret    
  800826:	66 90                	xchg   %ax,%ax
  800828:	66 90                	xchg   %ax,%ax
  80082a:	66 90                	xchg   %ax,%ax
  80082c:	66 90                	xchg   %ax,%ax
  80082e:	66 90                	xchg   %ax,%ax

00800830 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800830:	55                   	push   %ebp
  800831:	89 e5                	mov    %esp,%ebp
  800833:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800836:	b8 00 00 00 00       	mov    $0x0,%eax
  80083b:	80 3a 00             	cmpb   $0x0,(%edx)
  80083e:	74 09                	je     800849 <strlen+0x19>
		n++;
  800840:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800843:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800847:	75 f7                	jne    800840 <strlen+0x10>
		n++;
	return n;
}
  800849:	5d                   	pop    %ebp
  80084a:	c3                   	ret    

0080084b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80084b:	55                   	push   %ebp
  80084c:	89 e5                	mov    %esp,%ebp
  80084e:	53                   	push   %ebx
  80084f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800852:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800855:	85 c9                	test   %ecx,%ecx
  800857:	74 19                	je     800872 <strnlen+0x27>
  800859:	80 3b 00             	cmpb   $0x0,(%ebx)
  80085c:	74 14                	je     800872 <strnlen+0x27>
  80085e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800863:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800866:	39 c8                	cmp    %ecx,%eax
  800868:	74 0d                	je     800877 <strnlen+0x2c>
  80086a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80086e:	75 f3                	jne    800863 <strnlen+0x18>
  800870:	eb 05                	jmp    800877 <strnlen+0x2c>
  800872:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800877:	5b                   	pop    %ebx
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	53                   	push   %ebx
  80087e:	8b 45 08             	mov    0x8(%ebp),%eax
  800881:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800884:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800889:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80088d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800890:	83 c2 01             	add    $0x1,%edx
  800893:	84 c9                	test   %cl,%cl
  800895:	75 f2                	jne    800889 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800897:	5b                   	pop    %ebx
  800898:	5d                   	pop    %ebp
  800899:	c3                   	ret    

0080089a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80089a:	55                   	push   %ebp
  80089b:	89 e5                	mov    %esp,%ebp
  80089d:	53                   	push   %ebx
  80089e:	83 ec 08             	sub    $0x8,%esp
  8008a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008a4:	89 1c 24             	mov    %ebx,(%esp)
  8008a7:	e8 84 ff ff ff       	call   800830 <strlen>
	strcpy(dst + len, src);
  8008ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008af:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008b6:	89 04 24             	mov    %eax,(%esp)
  8008b9:	e8 bc ff ff ff       	call   80087a <strcpy>
	return dst;
}
  8008be:	89 d8                	mov    %ebx,%eax
  8008c0:	83 c4 08             	add    $0x8,%esp
  8008c3:	5b                   	pop    %ebx
  8008c4:	5d                   	pop    %ebp
  8008c5:	c3                   	ret    

008008c6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008d1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008d4:	85 f6                	test   %esi,%esi
  8008d6:	74 18                	je     8008f0 <strncpy+0x2a>
  8008d8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008dd:	0f b6 1a             	movzbl (%edx),%ebx
  8008e0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008e3:	80 3a 01             	cmpb   $0x1,(%edx)
  8008e6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008e9:	83 c1 01             	add    $0x1,%ecx
  8008ec:	39 ce                	cmp    %ecx,%esi
  8008ee:	77 ed                	ja     8008dd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008f0:	5b                   	pop    %ebx
  8008f1:	5e                   	pop    %esi
  8008f2:	5d                   	pop    %ebp
  8008f3:	c3                   	ret    

008008f4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008f4:	55                   	push   %ebp
  8008f5:	89 e5                	mov    %esp,%ebp
  8008f7:	56                   	push   %esi
  8008f8:	53                   	push   %ebx
  8008f9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ff:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800902:	89 f0                	mov    %esi,%eax
  800904:	85 c9                	test   %ecx,%ecx
  800906:	74 27                	je     80092f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800908:	83 e9 01             	sub    $0x1,%ecx
  80090b:	74 1d                	je     80092a <strlcpy+0x36>
  80090d:	0f b6 1a             	movzbl (%edx),%ebx
  800910:	84 db                	test   %bl,%bl
  800912:	74 16                	je     80092a <strlcpy+0x36>
			*dst++ = *src++;
  800914:	88 18                	mov    %bl,(%eax)
  800916:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800919:	83 e9 01             	sub    $0x1,%ecx
  80091c:	74 0e                	je     80092c <strlcpy+0x38>
			*dst++ = *src++;
  80091e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800921:	0f b6 1a             	movzbl (%edx),%ebx
  800924:	84 db                	test   %bl,%bl
  800926:	75 ec                	jne    800914 <strlcpy+0x20>
  800928:	eb 02                	jmp    80092c <strlcpy+0x38>
  80092a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80092c:	c6 00 00             	movb   $0x0,(%eax)
  80092f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800931:	5b                   	pop    %ebx
  800932:	5e                   	pop    %esi
  800933:	5d                   	pop    %ebp
  800934:	c3                   	ret    

00800935 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800935:	55                   	push   %ebp
  800936:	89 e5                	mov    %esp,%ebp
  800938:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80093b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80093e:	0f b6 01             	movzbl (%ecx),%eax
  800941:	84 c0                	test   %al,%al
  800943:	74 15                	je     80095a <strcmp+0x25>
  800945:	3a 02                	cmp    (%edx),%al
  800947:	75 11                	jne    80095a <strcmp+0x25>
		p++, q++;
  800949:	83 c1 01             	add    $0x1,%ecx
  80094c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80094f:	0f b6 01             	movzbl (%ecx),%eax
  800952:	84 c0                	test   %al,%al
  800954:	74 04                	je     80095a <strcmp+0x25>
  800956:	3a 02                	cmp    (%edx),%al
  800958:	74 ef                	je     800949 <strcmp+0x14>
  80095a:	0f b6 c0             	movzbl %al,%eax
  80095d:	0f b6 12             	movzbl (%edx),%edx
  800960:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	53                   	push   %ebx
  800968:	8b 55 08             	mov    0x8(%ebp),%edx
  80096b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80096e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800971:	85 c0                	test   %eax,%eax
  800973:	74 23                	je     800998 <strncmp+0x34>
  800975:	0f b6 1a             	movzbl (%edx),%ebx
  800978:	84 db                	test   %bl,%bl
  80097a:	74 25                	je     8009a1 <strncmp+0x3d>
  80097c:	3a 19                	cmp    (%ecx),%bl
  80097e:	75 21                	jne    8009a1 <strncmp+0x3d>
  800980:	83 e8 01             	sub    $0x1,%eax
  800983:	74 13                	je     800998 <strncmp+0x34>
		n--, p++, q++;
  800985:	83 c2 01             	add    $0x1,%edx
  800988:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80098b:	0f b6 1a             	movzbl (%edx),%ebx
  80098e:	84 db                	test   %bl,%bl
  800990:	74 0f                	je     8009a1 <strncmp+0x3d>
  800992:	3a 19                	cmp    (%ecx),%bl
  800994:	74 ea                	je     800980 <strncmp+0x1c>
  800996:	eb 09                	jmp    8009a1 <strncmp+0x3d>
  800998:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80099d:	5b                   	pop    %ebx
  80099e:	5d                   	pop    %ebp
  80099f:	90                   	nop
  8009a0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009a1:	0f b6 02             	movzbl (%edx),%eax
  8009a4:	0f b6 11             	movzbl (%ecx),%edx
  8009a7:	29 d0                	sub    %edx,%eax
  8009a9:	eb f2                	jmp    80099d <strncmp+0x39>

008009ab <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009ab:	55                   	push   %ebp
  8009ac:	89 e5                	mov    %esp,%ebp
  8009ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009b5:	0f b6 10             	movzbl (%eax),%edx
  8009b8:	84 d2                	test   %dl,%dl
  8009ba:	74 18                	je     8009d4 <strchr+0x29>
		if (*s == c)
  8009bc:	38 ca                	cmp    %cl,%dl
  8009be:	75 0a                	jne    8009ca <strchr+0x1f>
  8009c0:	eb 17                	jmp    8009d9 <strchr+0x2e>
  8009c2:	38 ca                	cmp    %cl,%dl
  8009c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009c8:	74 0f                	je     8009d9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009ca:	83 c0 01             	add    $0x1,%eax
  8009cd:	0f b6 10             	movzbl (%eax),%edx
  8009d0:	84 d2                	test   %dl,%dl
  8009d2:	75 ee                	jne    8009c2 <strchr+0x17>
  8009d4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8009d9:	5d                   	pop    %ebp
  8009da:	c3                   	ret    

008009db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009db:	55                   	push   %ebp
  8009dc:	89 e5                	mov    %esp,%ebp
  8009de:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009e5:	0f b6 10             	movzbl (%eax),%edx
  8009e8:	84 d2                	test   %dl,%dl
  8009ea:	74 18                	je     800a04 <strfind+0x29>
		if (*s == c)
  8009ec:	38 ca                	cmp    %cl,%dl
  8009ee:	75 0a                	jne    8009fa <strfind+0x1f>
  8009f0:	eb 12                	jmp    800a04 <strfind+0x29>
  8009f2:	38 ca                	cmp    %cl,%dl
  8009f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009f8:	74 0a                	je     800a04 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009fa:	83 c0 01             	add    $0x1,%eax
  8009fd:	0f b6 10             	movzbl (%eax),%edx
  800a00:	84 d2                	test   %dl,%dl
  800a02:	75 ee                	jne    8009f2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a04:	5d                   	pop    %ebp
  800a05:	c3                   	ret    

00800a06 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a06:	55                   	push   %ebp
  800a07:	89 e5                	mov    %esp,%ebp
  800a09:	83 ec 0c             	sub    $0xc,%esp
  800a0c:	89 1c 24             	mov    %ebx,(%esp)
  800a0f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a13:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a17:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a1a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a20:	85 c9                	test   %ecx,%ecx
  800a22:	74 30                	je     800a54 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a24:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a2a:	75 25                	jne    800a51 <memset+0x4b>
  800a2c:	f6 c1 03             	test   $0x3,%cl
  800a2f:	75 20                	jne    800a51 <memset+0x4b>
		c &= 0xFF;
  800a31:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a34:	89 d3                	mov    %edx,%ebx
  800a36:	c1 e3 08             	shl    $0x8,%ebx
  800a39:	89 d6                	mov    %edx,%esi
  800a3b:	c1 e6 18             	shl    $0x18,%esi
  800a3e:	89 d0                	mov    %edx,%eax
  800a40:	c1 e0 10             	shl    $0x10,%eax
  800a43:	09 f0                	or     %esi,%eax
  800a45:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a47:	09 d8                	or     %ebx,%eax
  800a49:	c1 e9 02             	shr    $0x2,%ecx
  800a4c:	fc                   	cld    
  800a4d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a4f:	eb 03                	jmp    800a54 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a51:	fc                   	cld    
  800a52:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a54:	89 f8                	mov    %edi,%eax
  800a56:	8b 1c 24             	mov    (%esp),%ebx
  800a59:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a5d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a61:	89 ec                	mov    %ebp,%esp
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a65:	55                   	push   %ebp
  800a66:	89 e5                	mov    %esp,%ebp
  800a68:	83 ec 08             	sub    $0x8,%esp
  800a6b:	89 34 24             	mov    %esi,(%esp)
  800a6e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a72:	8b 45 08             	mov    0x8(%ebp),%eax
  800a75:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800a78:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a7b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a7d:	39 c6                	cmp    %eax,%esi
  800a7f:	73 35                	jae    800ab6 <memmove+0x51>
  800a81:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a84:	39 d0                	cmp    %edx,%eax
  800a86:	73 2e                	jae    800ab6 <memmove+0x51>
		s += n;
		d += n;
  800a88:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a8a:	f6 c2 03             	test   $0x3,%dl
  800a8d:	75 1b                	jne    800aaa <memmove+0x45>
  800a8f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a95:	75 13                	jne    800aaa <memmove+0x45>
  800a97:	f6 c1 03             	test   $0x3,%cl
  800a9a:	75 0e                	jne    800aaa <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a9c:	83 ef 04             	sub    $0x4,%edi
  800a9f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800aa2:	c1 e9 02             	shr    $0x2,%ecx
  800aa5:	fd                   	std    
  800aa6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aa8:	eb 09                	jmp    800ab3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aaa:	83 ef 01             	sub    $0x1,%edi
  800aad:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ab0:	fd                   	std    
  800ab1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ab3:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ab4:	eb 20                	jmp    800ad6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800abc:	75 15                	jne    800ad3 <memmove+0x6e>
  800abe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ac4:	75 0d                	jne    800ad3 <memmove+0x6e>
  800ac6:	f6 c1 03             	test   $0x3,%cl
  800ac9:	75 08                	jne    800ad3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800acb:	c1 e9 02             	shr    $0x2,%ecx
  800ace:	fc                   	cld    
  800acf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ad1:	eb 03                	jmp    800ad6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ad3:	fc                   	cld    
  800ad4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ad6:	8b 34 24             	mov    (%esp),%esi
  800ad9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800add:	89 ec                	mov    %ebp,%esp
  800adf:	5d                   	pop    %ebp
  800ae0:	c3                   	ret    

00800ae1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ae7:	8b 45 10             	mov    0x10(%ebp),%eax
  800aea:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af5:	8b 45 08             	mov    0x8(%ebp),%eax
  800af8:	89 04 24             	mov    %eax,(%esp)
  800afb:	e8 65 ff ff ff       	call   800a65 <memmove>
}
  800b00:	c9                   	leave  
  800b01:	c3                   	ret    

00800b02 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	57                   	push   %edi
  800b06:	56                   	push   %esi
  800b07:	53                   	push   %ebx
  800b08:	8b 75 08             	mov    0x8(%ebp),%esi
  800b0b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b0e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b11:	85 c9                	test   %ecx,%ecx
  800b13:	74 36                	je     800b4b <memcmp+0x49>
		if (*s1 != *s2)
  800b15:	0f b6 06             	movzbl (%esi),%eax
  800b18:	0f b6 1f             	movzbl (%edi),%ebx
  800b1b:	38 d8                	cmp    %bl,%al
  800b1d:	74 20                	je     800b3f <memcmp+0x3d>
  800b1f:	eb 14                	jmp    800b35 <memcmp+0x33>
  800b21:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b26:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b2b:	83 c2 01             	add    $0x1,%edx
  800b2e:	83 e9 01             	sub    $0x1,%ecx
  800b31:	38 d8                	cmp    %bl,%al
  800b33:	74 12                	je     800b47 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b35:	0f b6 c0             	movzbl %al,%eax
  800b38:	0f b6 db             	movzbl %bl,%ebx
  800b3b:	29 d8                	sub    %ebx,%eax
  800b3d:	eb 11                	jmp    800b50 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b3f:	83 e9 01             	sub    $0x1,%ecx
  800b42:	ba 00 00 00 00       	mov    $0x0,%edx
  800b47:	85 c9                	test   %ecx,%ecx
  800b49:	75 d6                	jne    800b21 <memcmp+0x1f>
  800b4b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b50:	5b                   	pop    %ebx
  800b51:	5e                   	pop    %esi
  800b52:	5f                   	pop    %edi
  800b53:	5d                   	pop    %ebp
  800b54:	c3                   	ret    

00800b55 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b55:	55                   	push   %ebp
  800b56:	89 e5                	mov    %esp,%ebp
  800b58:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b5b:	89 c2                	mov    %eax,%edx
  800b5d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b60:	39 d0                	cmp    %edx,%eax
  800b62:	73 15                	jae    800b79 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b64:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b68:	38 08                	cmp    %cl,(%eax)
  800b6a:	75 06                	jne    800b72 <memfind+0x1d>
  800b6c:	eb 0b                	jmp    800b79 <memfind+0x24>
  800b6e:	38 08                	cmp    %cl,(%eax)
  800b70:	74 07                	je     800b79 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b72:	83 c0 01             	add    $0x1,%eax
  800b75:	39 c2                	cmp    %eax,%edx
  800b77:	77 f5                	ja     800b6e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b79:	5d                   	pop    %ebp
  800b7a:	c3                   	ret    

00800b7b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b7b:	55                   	push   %ebp
  800b7c:	89 e5                	mov    %esp,%ebp
  800b7e:	57                   	push   %edi
  800b7f:	56                   	push   %esi
  800b80:	53                   	push   %ebx
  800b81:	83 ec 04             	sub    $0x4,%esp
  800b84:	8b 55 08             	mov    0x8(%ebp),%edx
  800b87:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b8a:	0f b6 02             	movzbl (%edx),%eax
  800b8d:	3c 20                	cmp    $0x20,%al
  800b8f:	74 04                	je     800b95 <strtol+0x1a>
  800b91:	3c 09                	cmp    $0x9,%al
  800b93:	75 0e                	jne    800ba3 <strtol+0x28>
		s++;
  800b95:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b98:	0f b6 02             	movzbl (%edx),%eax
  800b9b:	3c 20                	cmp    $0x20,%al
  800b9d:	74 f6                	je     800b95 <strtol+0x1a>
  800b9f:	3c 09                	cmp    $0x9,%al
  800ba1:	74 f2                	je     800b95 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800ba3:	3c 2b                	cmp    $0x2b,%al
  800ba5:	75 0c                	jne    800bb3 <strtol+0x38>
		s++;
  800ba7:	83 c2 01             	add    $0x1,%edx
  800baa:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bb1:	eb 15                	jmp    800bc8 <strtol+0x4d>
	else if (*s == '-')
  800bb3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bba:	3c 2d                	cmp    $0x2d,%al
  800bbc:	75 0a                	jne    800bc8 <strtol+0x4d>
		s++, neg = 1;
  800bbe:	83 c2 01             	add    $0x1,%edx
  800bc1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bc8:	85 db                	test   %ebx,%ebx
  800bca:	0f 94 c0             	sete   %al
  800bcd:	74 05                	je     800bd4 <strtol+0x59>
  800bcf:	83 fb 10             	cmp    $0x10,%ebx
  800bd2:	75 18                	jne    800bec <strtol+0x71>
  800bd4:	80 3a 30             	cmpb   $0x30,(%edx)
  800bd7:	75 13                	jne    800bec <strtol+0x71>
  800bd9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bdd:	8d 76 00             	lea    0x0(%esi),%esi
  800be0:	75 0a                	jne    800bec <strtol+0x71>
		s += 2, base = 16;
  800be2:	83 c2 02             	add    $0x2,%edx
  800be5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bea:	eb 15                	jmp    800c01 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bec:	84 c0                	test   %al,%al
  800bee:	66 90                	xchg   %ax,%ax
  800bf0:	74 0f                	je     800c01 <strtol+0x86>
  800bf2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bf7:	80 3a 30             	cmpb   $0x30,(%edx)
  800bfa:	75 05                	jne    800c01 <strtol+0x86>
		s++, base = 8;
  800bfc:	83 c2 01             	add    $0x1,%edx
  800bff:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c01:	b8 00 00 00 00       	mov    $0x0,%eax
  800c06:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c08:	0f b6 0a             	movzbl (%edx),%ecx
  800c0b:	89 cf                	mov    %ecx,%edi
  800c0d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c10:	80 fb 09             	cmp    $0x9,%bl
  800c13:	77 08                	ja     800c1d <strtol+0xa2>
			dig = *s - '0';
  800c15:	0f be c9             	movsbl %cl,%ecx
  800c18:	83 e9 30             	sub    $0x30,%ecx
  800c1b:	eb 1e                	jmp    800c3b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800c1d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c20:	80 fb 19             	cmp    $0x19,%bl
  800c23:	77 08                	ja     800c2d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c25:	0f be c9             	movsbl %cl,%ecx
  800c28:	83 e9 57             	sub    $0x57,%ecx
  800c2b:	eb 0e                	jmp    800c3b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c2d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c30:	80 fb 19             	cmp    $0x19,%bl
  800c33:	77 15                	ja     800c4a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c35:	0f be c9             	movsbl %cl,%ecx
  800c38:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c3b:	39 f1                	cmp    %esi,%ecx
  800c3d:	7d 0b                	jge    800c4a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c3f:	83 c2 01             	add    $0x1,%edx
  800c42:	0f af c6             	imul   %esi,%eax
  800c45:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c48:	eb be                	jmp    800c08 <strtol+0x8d>
  800c4a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c4c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c50:	74 05                	je     800c57 <strtol+0xdc>
		*endptr = (char *) s;
  800c52:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c55:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c57:	89 ca                	mov    %ecx,%edx
  800c59:	f7 da                	neg    %edx
  800c5b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c5f:	0f 45 c2             	cmovne %edx,%eax
}
  800c62:	83 c4 04             	add    $0x4,%esp
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	83 ec 0c             	sub    $0xc,%esp
  800c70:	89 1c 24             	mov    %ebx,(%esp)
  800c73:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c77:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c80:	b8 01 00 00 00       	mov    $0x1,%eax
  800c85:	89 d1                	mov    %edx,%ecx
  800c87:	89 d3                	mov    %edx,%ebx
  800c89:	89 d7                	mov    %edx,%edi
  800c8b:	89 d6                	mov    %edx,%esi
  800c8d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c8f:	8b 1c 24             	mov    (%esp),%ebx
  800c92:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c96:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c9a:	89 ec                	mov    %ebp,%esp
  800c9c:	5d                   	pop    %ebp
  800c9d:	c3                   	ret    

00800c9e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	83 ec 0c             	sub    $0xc,%esp
  800ca4:	89 1c 24             	mov    %ebx,(%esp)
  800ca7:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cab:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800caf:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cb7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cba:	89 c3                	mov    %eax,%ebx
  800cbc:	89 c7                	mov    %eax,%edi
  800cbe:	89 c6                	mov    %eax,%esi
  800cc0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800cc2:	8b 1c 24             	mov    (%esp),%ebx
  800cc5:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cc9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ccd:	89 ec                	mov    %ebp,%esp
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	83 ec 38             	sub    $0x38,%esp
  800cd7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cda:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cdd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ce0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ce5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cea:	8b 55 08             	mov    0x8(%ebp),%edx
  800ced:	89 cb                	mov    %ecx,%ebx
  800cef:	89 cf                	mov    %ecx,%edi
  800cf1:	89 ce                	mov    %ecx,%esi
  800cf3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cf5:	85 c0                	test   %eax,%eax
  800cf7:	7e 28                	jle    800d21 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cf9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cfd:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d04:	00 
  800d05:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800d0c:	00 
  800d0d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d14:	00 
  800d15:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800d1c:	e8 25 03 00 00       	call   801046 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d21:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d24:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d27:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d2a:	89 ec                	mov    %ebp,%esp
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	83 ec 0c             	sub    $0xc,%esp
  800d34:	89 1c 24             	mov    %ebx,(%esp)
  800d37:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d3b:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3f:	be 00 00 00 00       	mov    $0x0,%esi
  800d44:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d49:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d4c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d4f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d52:	8b 55 08             	mov    0x8(%ebp),%edx
  800d55:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d57:	8b 1c 24             	mov    (%esp),%ebx
  800d5a:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d5e:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d62:	89 ec                	mov    %ebp,%esp
  800d64:	5d                   	pop    %ebp
  800d65:	c3                   	ret    

00800d66 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d66:	55                   	push   %ebp
  800d67:	89 e5                	mov    %esp,%ebp
  800d69:	83 ec 38             	sub    $0x38,%esp
  800d6c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d6f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d72:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d7a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d82:	8b 55 08             	mov    0x8(%ebp),%edx
  800d85:	89 df                	mov    %ebx,%edi
  800d87:	89 de                	mov    %ebx,%esi
  800d89:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d8b:	85 c0                	test   %eax,%eax
  800d8d:	7e 28                	jle    800db7 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d8f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d93:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d9a:	00 
  800d9b:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800da2:	00 
  800da3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800daa:	00 
  800dab:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800db2:	e8 8f 02 00 00       	call   801046 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800db7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dba:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dbd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dc0:	89 ec                	mov    %ebp,%esp
  800dc2:	5d                   	pop    %ebp
  800dc3:	c3                   	ret    

00800dc4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800dc4:	55                   	push   %ebp
  800dc5:	89 e5                	mov    %esp,%ebp
  800dc7:	83 ec 38             	sub    $0x38,%esp
  800dca:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dcd:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dd0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dd8:	b8 08 00 00 00       	mov    $0x8,%eax
  800ddd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de0:	8b 55 08             	mov    0x8(%ebp),%edx
  800de3:	89 df                	mov    %ebx,%edi
  800de5:	89 de                	mov    %ebx,%esi
  800de7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800de9:	85 c0                	test   %eax,%eax
  800deb:	7e 28                	jle    800e15 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ded:	89 44 24 10          	mov    %eax,0x10(%esp)
  800df1:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800df8:	00 
  800df9:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800e00:	00 
  800e01:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e08:	00 
  800e09:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800e10:	e8 31 02 00 00       	call   801046 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e15:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e18:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e1b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e1e:	89 ec                	mov    %ebp,%esp
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    

00800e22 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	83 ec 38             	sub    $0x38,%esp
  800e28:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e2b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e2e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e31:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e36:	b8 06 00 00 00       	mov    $0x6,%eax
  800e3b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e3e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e41:	89 df                	mov    %ebx,%edi
  800e43:	89 de                	mov    %ebx,%esi
  800e45:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e47:	85 c0                	test   %eax,%eax
  800e49:	7e 28                	jle    800e73 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e4f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e56:	00 
  800e57:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800e5e:	00 
  800e5f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e66:	00 
  800e67:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800e6e:	e8 d3 01 00 00       	call   801046 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e73:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e76:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e79:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e7c:	89 ec                	mov    %ebp,%esp
  800e7e:	5d                   	pop    %ebp
  800e7f:	c3                   	ret    

00800e80 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	83 ec 38             	sub    $0x38,%esp
  800e86:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e89:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e8c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	b8 05 00 00 00       	mov    $0x5,%eax
  800e94:	8b 75 18             	mov    0x18(%ebp),%esi
  800e97:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e9a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	7e 28                	jle    800ed1 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ea9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ead:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800eb4:	00 
  800eb5:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800ebc:	00 
  800ebd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec4:	00 
  800ec5:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800ecc:	e8 75 01 00 00       	call   801046 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800ed1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ed4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ed7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eda:	89 ec                	mov    %ebp,%esp
  800edc:	5d                   	pop    %ebp
  800edd:	c3                   	ret    

00800ede <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	83 ec 38             	sub    $0x38,%esp
  800ee4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ee7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eea:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eed:	be 00 00 00 00       	mov    $0x0,%esi
  800ef2:	b8 04 00 00 00       	mov    $0x4,%eax
  800ef7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800efa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efd:	8b 55 08             	mov    0x8(%ebp),%edx
  800f00:	89 f7                	mov    %esi,%edi
  800f02:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f04:	85 c0                	test   %eax,%eax
  800f06:	7e 28                	jle    800f30 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f08:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f0c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f13:	00 
  800f14:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800f1b:	00 
  800f1c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f23:	00 
  800f24:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800f2b:	e8 16 01 00 00       	call   801046 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f30:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f33:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f36:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f39:	89 ec                	mov    %ebp,%esp
  800f3b:	5d                   	pop    %ebp
  800f3c:	c3                   	ret    

00800f3d <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800f3d:	55                   	push   %ebp
  800f3e:	89 e5                	mov    %esp,%ebp
  800f40:	83 ec 0c             	sub    $0xc,%esp
  800f43:	89 1c 24             	mov    %ebx,(%esp)
  800f46:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f4a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f53:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f58:	89 d1                	mov    %edx,%ecx
  800f5a:	89 d3                	mov    %edx,%ebx
  800f5c:	89 d7                	mov    %edx,%edi
  800f5e:	89 d6                	mov    %edx,%esi
  800f60:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f62:	8b 1c 24             	mov    (%esp),%ebx
  800f65:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f69:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f6d:	89 ec                	mov    %ebp,%esp
  800f6f:	5d                   	pop    %ebp
  800f70:	c3                   	ret    

00800f71 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	83 ec 0c             	sub    $0xc,%esp
  800f77:	89 1c 24             	mov    %ebx,(%esp)
  800f7a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f7e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f82:	ba 00 00 00 00       	mov    $0x0,%edx
  800f87:	b8 02 00 00 00       	mov    $0x2,%eax
  800f8c:	89 d1                	mov    %edx,%ecx
  800f8e:	89 d3                	mov    %edx,%ebx
  800f90:	89 d7                	mov    %edx,%edi
  800f92:	89 d6                	mov    %edx,%esi
  800f94:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f96:	8b 1c 24             	mov    (%esp),%ebx
  800f99:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f9d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fa1:	89 ec                	mov    %ebp,%esp
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    

00800fa5 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	83 ec 38             	sub    $0x38,%esp
  800fab:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fae:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fb1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fb9:	b8 03 00 00 00       	mov    $0x3,%eax
  800fbe:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc1:	89 cb                	mov    %ecx,%ebx
  800fc3:	89 cf                	mov    %ecx,%edi
  800fc5:	89 ce                	mov    %ecx,%esi
  800fc7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	7e 28                	jle    800ff5 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fcd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd1:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800fd8:	00 
  800fd9:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800fe0:	00 
  800fe1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe8:	00 
  800fe9:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800ff0:	e8 51 00 00 00       	call   801046 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800ff5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ff8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ffb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ffe:	89 ec                	mov    %ebp,%esp
  801000:	5d                   	pop    %ebp
  801001:	c3                   	ret    

00801002 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801008:	c7 44 24 08 2f 16 80 	movl   $0x80162f,0x8(%esp)
  80100f:	00 
  801010:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801017:	00 
  801018:	c7 04 24 45 16 80 00 	movl   $0x801645,(%esp)
  80101f:	e8 22 00 00 00       	call   801046 <_panic>

00801024 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801024:	55                   	push   %ebp
  801025:	89 e5                	mov    %esp,%ebp
  801027:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  80102a:	c7 44 24 08 30 16 80 	movl   $0x801630,0x8(%esp)
  801031:	00 
  801032:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801039:	00 
  80103a:	c7 04 24 45 16 80 00 	movl   $0x801645,(%esp)
  801041:	e8 00 00 00 00       	call   801046 <_panic>

00801046 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801046:	55                   	push   %ebp
  801047:	89 e5                	mov    %esp,%ebp
  801049:	56                   	push   %esi
  80104a:	53                   	push   %ebx
  80104b:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80104e:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801051:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  801057:	e8 15 ff ff ff       	call   800f71 <sys_getenvid>
  80105c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80105f:	89 54 24 10          	mov    %edx,0x10(%esp)
  801063:	8b 55 08             	mov    0x8(%ebp),%edx
  801066:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80106a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80106e:	89 44 24 04          	mov    %eax,0x4(%esp)
  801072:	c7 04 24 50 16 80 00 	movl   $0x801650,(%esp)
  801079:	e8 0f f1 ff ff       	call   80018d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80107e:	89 74 24 04          	mov    %esi,0x4(%esp)
  801082:	8b 45 10             	mov    0x10(%ebp),%eax
  801085:	89 04 24             	mov    %eax,(%esp)
  801088:	e8 9f f0 ff ff       	call   80012c <vcprintf>
	cprintf("\n");
  80108d:	c7 04 24 b4 13 80 00 	movl   $0x8013b4,(%esp)
  801094:	e8 f4 f0 ff ff       	call   80018d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801099:	cc                   	int3   
  80109a:	eb fd                	jmp    801099 <_panic+0x53>
  80109c:	66 90                	xchg   %ax,%ax
  80109e:	66 90                	xchg   %ax,%ax

008010a0 <__udivdi3>:
  8010a0:	55                   	push   %ebp
  8010a1:	89 e5                	mov    %esp,%ebp
  8010a3:	57                   	push   %edi
  8010a4:	56                   	push   %esi
  8010a5:	83 ec 10             	sub    $0x10,%esp
  8010a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8010ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ae:	8b 75 10             	mov    0x10(%ebp),%esi
  8010b1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8010b4:	85 c0                	test   %eax,%eax
  8010b6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8010b9:	75 35                	jne    8010f0 <__udivdi3+0x50>
  8010bb:	39 fe                	cmp    %edi,%esi
  8010bd:	77 61                	ja     801120 <__udivdi3+0x80>
  8010bf:	85 f6                	test   %esi,%esi
  8010c1:	75 0b                	jne    8010ce <__udivdi3+0x2e>
  8010c3:	b8 01 00 00 00       	mov    $0x1,%eax
  8010c8:	31 d2                	xor    %edx,%edx
  8010ca:	f7 f6                	div    %esi
  8010cc:	89 c6                	mov    %eax,%esi
  8010ce:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8010d1:	31 d2                	xor    %edx,%edx
  8010d3:	89 f8                	mov    %edi,%eax
  8010d5:	f7 f6                	div    %esi
  8010d7:	89 c7                	mov    %eax,%edi
  8010d9:	89 c8                	mov    %ecx,%eax
  8010db:	f7 f6                	div    %esi
  8010dd:	89 c1                	mov    %eax,%ecx
  8010df:	89 fa                	mov    %edi,%edx
  8010e1:	89 c8                	mov    %ecx,%eax
  8010e3:	83 c4 10             	add    $0x10,%esp
  8010e6:	5e                   	pop    %esi
  8010e7:	5f                   	pop    %edi
  8010e8:	5d                   	pop    %ebp
  8010e9:	c3                   	ret    
  8010ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8010f0:	39 f8                	cmp    %edi,%eax
  8010f2:	77 1c                	ja     801110 <__udivdi3+0x70>
  8010f4:	0f bd d0             	bsr    %eax,%edx
  8010f7:	83 f2 1f             	xor    $0x1f,%edx
  8010fa:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8010fd:	75 39                	jne    801138 <__udivdi3+0x98>
  8010ff:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801102:	0f 86 a0 00 00 00    	jbe    8011a8 <__udivdi3+0x108>
  801108:	39 f8                	cmp    %edi,%eax
  80110a:	0f 82 98 00 00 00    	jb     8011a8 <__udivdi3+0x108>
  801110:	31 ff                	xor    %edi,%edi
  801112:	31 c9                	xor    %ecx,%ecx
  801114:	89 c8                	mov    %ecx,%eax
  801116:	89 fa                	mov    %edi,%edx
  801118:	83 c4 10             	add    $0x10,%esp
  80111b:	5e                   	pop    %esi
  80111c:	5f                   	pop    %edi
  80111d:	5d                   	pop    %ebp
  80111e:	c3                   	ret    
  80111f:	90                   	nop
  801120:	89 d1                	mov    %edx,%ecx
  801122:	89 fa                	mov    %edi,%edx
  801124:	89 c8                	mov    %ecx,%eax
  801126:	31 ff                	xor    %edi,%edi
  801128:	f7 f6                	div    %esi
  80112a:	89 c1                	mov    %eax,%ecx
  80112c:	89 fa                	mov    %edi,%edx
  80112e:	89 c8                	mov    %ecx,%eax
  801130:	83 c4 10             	add    $0x10,%esp
  801133:	5e                   	pop    %esi
  801134:	5f                   	pop    %edi
  801135:	5d                   	pop    %ebp
  801136:	c3                   	ret    
  801137:	90                   	nop
  801138:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80113c:	89 f2                	mov    %esi,%edx
  80113e:	d3 e0                	shl    %cl,%eax
  801140:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801143:	b8 20 00 00 00       	mov    $0x20,%eax
  801148:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80114b:	89 c1                	mov    %eax,%ecx
  80114d:	d3 ea                	shr    %cl,%edx
  80114f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801153:	0b 55 ec             	or     -0x14(%ebp),%edx
  801156:	d3 e6                	shl    %cl,%esi
  801158:	89 c1                	mov    %eax,%ecx
  80115a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80115d:	89 fe                	mov    %edi,%esi
  80115f:	d3 ee                	shr    %cl,%esi
  801161:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801165:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801168:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80116b:	d3 e7                	shl    %cl,%edi
  80116d:	89 c1                	mov    %eax,%ecx
  80116f:	d3 ea                	shr    %cl,%edx
  801171:	09 d7                	or     %edx,%edi
  801173:	89 f2                	mov    %esi,%edx
  801175:	89 f8                	mov    %edi,%eax
  801177:	f7 75 ec             	divl   -0x14(%ebp)
  80117a:	89 d6                	mov    %edx,%esi
  80117c:	89 c7                	mov    %eax,%edi
  80117e:	f7 65 e8             	mull   -0x18(%ebp)
  801181:	39 d6                	cmp    %edx,%esi
  801183:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801186:	72 30                	jb     8011b8 <__udivdi3+0x118>
  801188:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80118b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80118f:	d3 e2                	shl    %cl,%edx
  801191:	39 c2                	cmp    %eax,%edx
  801193:	73 05                	jae    80119a <__udivdi3+0xfa>
  801195:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801198:	74 1e                	je     8011b8 <__udivdi3+0x118>
  80119a:	89 f9                	mov    %edi,%ecx
  80119c:	31 ff                	xor    %edi,%edi
  80119e:	e9 71 ff ff ff       	jmp    801114 <__udivdi3+0x74>
  8011a3:	90                   	nop
  8011a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011a8:	31 ff                	xor    %edi,%edi
  8011aa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8011af:	e9 60 ff ff ff       	jmp    801114 <__udivdi3+0x74>
  8011b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011b8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8011bb:	31 ff                	xor    %edi,%edi
  8011bd:	89 c8                	mov    %ecx,%eax
  8011bf:	89 fa                	mov    %edi,%edx
  8011c1:	83 c4 10             	add    $0x10,%esp
  8011c4:	5e                   	pop    %esi
  8011c5:	5f                   	pop    %edi
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    
  8011c8:	66 90                	xchg   %ax,%ax
  8011ca:	66 90                	xchg   %ax,%ax
  8011cc:	66 90                	xchg   %ax,%ax
  8011ce:	66 90                	xchg   %ax,%ax

008011d0 <__umoddi3>:
  8011d0:	55                   	push   %ebp
  8011d1:	89 e5                	mov    %esp,%ebp
  8011d3:	57                   	push   %edi
  8011d4:	56                   	push   %esi
  8011d5:	83 ec 20             	sub    $0x20,%esp
  8011d8:	8b 55 14             	mov    0x14(%ebp),%edx
  8011db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011de:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011e1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011e4:	85 d2                	test   %edx,%edx
  8011e6:	89 c8                	mov    %ecx,%eax
  8011e8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8011eb:	75 13                	jne    801200 <__umoddi3+0x30>
  8011ed:	39 f7                	cmp    %esi,%edi
  8011ef:	76 3f                	jbe    801230 <__umoddi3+0x60>
  8011f1:	89 f2                	mov    %esi,%edx
  8011f3:	f7 f7                	div    %edi
  8011f5:	89 d0                	mov    %edx,%eax
  8011f7:	31 d2                	xor    %edx,%edx
  8011f9:	83 c4 20             	add    $0x20,%esp
  8011fc:	5e                   	pop    %esi
  8011fd:	5f                   	pop    %edi
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    
  801200:	39 f2                	cmp    %esi,%edx
  801202:	77 4c                	ja     801250 <__umoddi3+0x80>
  801204:	0f bd ca             	bsr    %edx,%ecx
  801207:	83 f1 1f             	xor    $0x1f,%ecx
  80120a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80120d:	75 51                	jne    801260 <__umoddi3+0x90>
  80120f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801212:	0f 87 e0 00 00 00    	ja     8012f8 <__umoddi3+0x128>
  801218:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80121b:	29 f8                	sub    %edi,%eax
  80121d:	19 d6                	sbb    %edx,%esi
  80121f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801222:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801225:	89 f2                	mov    %esi,%edx
  801227:	83 c4 20             	add    $0x20,%esp
  80122a:	5e                   	pop    %esi
  80122b:	5f                   	pop    %edi
  80122c:	5d                   	pop    %ebp
  80122d:	c3                   	ret    
  80122e:	66 90                	xchg   %ax,%ax
  801230:	85 ff                	test   %edi,%edi
  801232:	75 0b                	jne    80123f <__umoddi3+0x6f>
  801234:	b8 01 00 00 00       	mov    $0x1,%eax
  801239:	31 d2                	xor    %edx,%edx
  80123b:	f7 f7                	div    %edi
  80123d:	89 c7                	mov    %eax,%edi
  80123f:	89 f0                	mov    %esi,%eax
  801241:	31 d2                	xor    %edx,%edx
  801243:	f7 f7                	div    %edi
  801245:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801248:	f7 f7                	div    %edi
  80124a:	eb a9                	jmp    8011f5 <__umoddi3+0x25>
  80124c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801250:	89 c8                	mov    %ecx,%eax
  801252:	89 f2                	mov    %esi,%edx
  801254:	83 c4 20             	add    $0x20,%esp
  801257:	5e                   	pop    %esi
  801258:	5f                   	pop    %edi
  801259:	5d                   	pop    %ebp
  80125a:	c3                   	ret    
  80125b:	90                   	nop
  80125c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801260:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801264:	d3 e2                	shl    %cl,%edx
  801266:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801269:	ba 20 00 00 00       	mov    $0x20,%edx
  80126e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801271:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801274:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801278:	89 fa                	mov    %edi,%edx
  80127a:	d3 ea                	shr    %cl,%edx
  80127c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801280:	0b 55 f4             	or     -0xc(%ebp),%edx
  801283:	d3 e7                	shl    %cl,%edi
  801285:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801289:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80128c:	89 f2                	mov    %esi,%edx
  80128e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801291:	89 c7                	mov    %eax,%edi
  801293:	d3 ea                	shr    %cl,%edx
  801295:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801299:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80129c:	89 c2                	mov    %eax,%edx
  80129e:	d3 e6                	shl    %cl,%esi
  8012a0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012a4:	d3 ea                	shr    %cl,%edx
  8012a6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012aa:	09 d6                	or     %edx,%esi
  8012ac:	89 f0                	mov    %esi,%eax
  8012ae:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8012b1:	d3 e7                	shl    %cl,%edi
  8012b3:	89 f2                	mov    %esi,%edx
  8012b5:	f7 75 f4             	divl   -0xc(%ebp)
  8012b8:	89 d6                	mov    %edx,%esi
  8012ba:	f7 65 e8             	mull   -0x18(%ebp)
  8012bd:	39 d6                	cmp    %edx,%esi
  8012bf:	72 2b                	jb     8012ec <__umoddi3+0x11c>
  8012c1:	39 c7                	cmp    %eax,%edi
  8012c3:	72 23                	jb     8012e8 <__umoddi3+0x118>
  8012c5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012c9:	29 c7                	sub    %eax,%edi
  8012cb:	19 d6                	sbb    %edx,%esi
  8012cd:	89 f0                	mov    %esi,%eax
  8012cf:	89 f2                	mov    %esi,%edx
  8012d1:	d3 ef                	shr    %cl,%edi
  8012d3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012d7:	d3 e0                	shl    %cl,%eax
  8012d9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012dd:	09 f8                	or     %edi,%eax
  8012df:	d3 ea                	shr    %cl,%edx
  8012e1:	83 c4 20             	add    $0x20,%esp
  8012e4:	5e                   	pop    %esi
  8012e5:	5f                   	pop    %edi
  8012e6:	5d                   	pop    %ebp
  8012e7:	c3                   	ret    
  8012e8:	39 d6                	cmp    %edx,%esi
  8012ea:	75 d9                	jne    8012c5 <__umoddi3+0xf5>
  8012ec:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8012ef:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8012f2:	eb d1                	jmp    8012c5 <__umoddi3+0xf5>
  8012f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012f8:	39 f2                	cmp    %esi,%edx
  8012fa:	0f 82 18 ff ff ff    	jb     801218 <__umoddi3+0x48>
  801300:	e9 1d ff ff ff       	jmp    801222 <__umoddi3+0x52>
