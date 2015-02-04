
obj/user/yield：     文件格式 elf32-i386


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
  80002c:	e8 6d 00 00 00       	call   80009e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 14             	sub    $0x14,%esp
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
  80003a:	a1 04 20 80 00       	mov    0x802004,%eax
  80003f:	8b 40 48             	mov    0x48(%eax),%eax
  800042:	89 44 24 04          	mov    %eax,0x4(%esp)
  800046:	c7 04 24 c0 12 80 00 	movl   $0x8012c0,(%esp)
  80004d:	e8 1a 01 00 00       	call   80016c <cprintf>
  800052:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < 5; i++) {
		sys_yield();
  800057:	e8 c1 0e 00 00       	call   800f1d <sys_yield>
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
  80005c:	a1 04 20 80 00       	mov    0x802004,%eax
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
  800061:	8b 40 48             	mov    0x48(%eax),%eax
  800064:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800068:	89 44 24 04          	mov    %eax,0x4(%esp)
  80006c:	c7 04 24 e0 12 80 00 	movl   $0x8012e0,(%esp)
  800073:	e8 f4 00 00 00       	call   80016c <cprintf>
umain(int argc, char **argv)
{
	int i;

	cprintf("Hello, I am environment %08x.\n", thisenv->env_id);
	for (i = 0; i < 5; i++) {
  800078:	83 c3 01             	add    $0x1,%ebx
  80007b:	83 fb 05             	cmp    $0x5,%ebx
  80007e:	75 d7                	jne    800057 <umain+0x24>
		sys_yield();
		cprintf("Back in environment %08x, iteration %d.\n",
			thisenv->env_id, i);
	}
	cprintf("All done in environment %08x.\n", thisenv->env_id);
  800080:	a1 04 20 80 00       	mov    0x802004,%eax
  800085:	8b 40 48             	mov    0x48(%eax),%eax
  800088:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008c:	c7 04 24 0c 13 80 00 	movl   $0x80130c,(%esp)
  800093:	e8 d4 00 00 00       	call   80016c <cprintf>
}
  800098:	83 c4 14             	add    $0x14,%esp
  80009b:	5b                   	pop    %ebx
  80009c:	5d                   	pop    %ebp
  80009d:	c3                   	ret    

0080009e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	83 ec 18             	sub    $0x18,%esp
  8000a4:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000a7:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000aa:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000b0:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000b7:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8000ba:	e8 92 0e 00 00       	call   800f51 <sys_getenvid>
  8000bf:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000c4:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000c7:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000cc:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000d1:	85 f6                	test   %esi,%esi
  8000d3:	7e 07                	jle    8000dc <libmain+0x3e>
		binaryname = argv[0];
  8000d5:	8b 03                	mov    (%ebx),%eax
  8000d7:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000dc:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000e0:	89 34 24             	mov    %esi,(%esp)
  8000e3:	e8 4b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000e8:	e8 0a 00 00 00       	call   8000f7 <exit>
}
  8000ed:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000f0:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000f3:	89 ec                	mov    %ebp,%esp
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000fd:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800104:	e8 7c 0e 00 00       	call   800f85 <sys_env_destroy>
}
  800109:	c9                   	leave  
  80010a:	c3                   	ret    

0080010b <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800114:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80011b:	00 00 00 
	b.cnt = 0;
  80011e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800125:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800128:	8b 45 0c             	mov    0xc(%ebp),%eax
  80012b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80012f:	8b 45 08             	mov    0x8(%ebp),%eax
  800132:	89 44 24 08          	mov    %eax,0x8(%esp)
  800136:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80013c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800140:	c7 04 24 86 01 80 00 	movl   $0x800186,(%esp)
  800147:	e8 d1 01 00 00       	call   80031d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80014c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800152:	89 44 24 04          	mov    %eax,0x4(%esp)
  800156:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80015c:	89 04 24             	mov    %eax,(%esp)
  80015f:	e8 1a 0b 00 00       	call   800c7e <sys_cputs>

	return b.cnt;
}
  800164:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80016a:	c9                   	leave  
  80016b:	c3                   	ret    

0080016c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80016c:	55                   	push   %ebp
  80016d:	89 e5                	mov    %esp,%ebp
  80016f:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800172:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800175:	89 44 24 04          	mov    %eax,0x4(%esp)
  800179:	8b 45 08             	mov    0x8(%ebp),%eax
  80017c:	89 04 24             	mov    %eax,(%esp)
  80017f:	e8 87 ff ff ff       	call   80010b <vcprintf>
	va_end(ap);

	return cnt;
}
  800184:	c9                   	leave  
  800185:	c3                   	ret    

00800186 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800186:	55                   	push   %ebp
  800187:	89 e5                	mov    %esp,%ebp
  800189:	53                   	push   %ebx
  80018a:	83 ec 14             	sub    $0x14,%esp
  80018d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800190:	8b 03                	mov    (%ebx),%eax
  800192:	8b 55 08             	mov    0x8(%ebp),%edx
  800195:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800199:	83 c0 01             	add    $0x1,%eax
  80019c:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80019e:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a3:	75 19                	jne    8001be <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001a5:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8001ac:	00 
  8001ad:	8d 43 08             	lea    0x8(%ebx),%eax
  8001b0:	89 04 24             	mov    %eax,(%esp)
  8001b3:	e8 c6 0a 00 00       	call   800c7e <sys_cputs>
		b->idx = 0;
  8001b8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8001be:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c2:	83 c4 14             	add    $0x14,%esp
  8001c5:	5b                   	pop    %ebx
  8001c6:	5d                   	pop    %ebp
  8001c7:	c3                   	ret    
  8001c8:	66 90                	xchg   %ax,%ax
  8001ca:	66 90                	xchg   %ax,%ax
  8001cc:	66 90                	xchg   %ax,%ax
  8001ce:	66 90                	xchg   %ax,%ax

008001d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001d0:	55                   	push   %ebp
  8001d1:	89 e5                	mov    %esp,%ebp
  8001d3:	57                   	push   %edi
  8001d4:	56                   	push   %esi
  8001d5:	53                   	push   %ebx
  8001d6:	83 ec 4c             	sub    $0x4c,%esp
  8001d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8001dc:	89 d6                	mov    %edx,%esi
  8001de:	8b 45 08             	mov    0x8(%ebp),%eax
  8001e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8001ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8001ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8001f0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001fb:	39 d1                	cmp    %edx,%ecx
  8001fd:	72 15                	jb     800214 <printnum+0x44>
  8001ff:	77 07                	ja     800208 <printnum+0x38>
  800201:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800204:	39 d0                	cmp    %edx,%eax
  800206:	76 0c                	jbe    800214 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800208:	83 eb 01             	sub    $0x1,%ebx
  80020b:	85 db                	test   %ebx,%ebx
  80020d:	8d 76 00             	lea    0x0(%esi),%esi
  800210:	7f 61                	jg     800273 <printnum+0xa3>
  800212:	eb 70                	jmp    800284 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800214:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800218:	83 eb 01             	sub    $0x1,%ebx
  80021b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80021f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800223:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800227:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80022b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80022e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800231:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800234:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800238:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80023f:	00 
  800240:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800243:	89 04 24             	mov    %eax,(%esp)
  800246:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800249:	89 54 24 04          	mov    %edx,0x4(%esp)
  80024d:	e8 ee 0d 00 00       	call   801040 <__udivdi3>
  800252:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800255:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800258:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80025c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800260:	89 04 24             	mov    %eax,(%esp)
  800263:	89 54 24 04          	mov    %edx,0x4(%esp)
  800267:	89 f2                	mov    %esi,%edx
  800269:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80026c:	e8 5f ff ff ff       	call   8001d0 <printnum>
  800271:	eb 11                	jmp    800284 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800273:	89 74 24 04          	mov    %esi,0x4(%esp)
  800277:	89 3c 24             	mov    %edi,(%esp)
  80027a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80027d:	83 eb 01             	sub    $0x1,%ebx
  800280:	85 db                	test   %ebx,%ebx
  800282:	7f ef                	jg     800273 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800284:	89 74 24 04          	mov    %esi,0x4(%esp)
  800288:	8b 74 24 04          	mov    0x4(%esp),%esi
  80028c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80028f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800293:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80029a:	00 
  80029b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80029e:	89 14 24             	mov    %edx,(%esp)
  8002a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8002a4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8002a8:	e8 c3 0e 00 00       	call   801170 <__umoddi3>
  8002ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002b1:	0f be 80 35 13 80 00 	movsbl 0x801335(%eax),%eax
  8002b8:	89 04 24             	mov    %eax,(%esp)
  8002bb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8002be:	83 c4 4c             	add    $0x4c,%esp
  8002c1:	5b                   	pop    %ebx
  8002c2:	5e                   	pop    %esi
  8002c3:	5f                   	pop    %edi
  8002c4:	5d                   	pop    %ebp
  8002c5:	c3                   	ret    

008002c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8002c6:	55                   	push   %ebp
  8002c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8002c9:	83 fa 01             	cmp    $0x1,%edx
  8002cc:	7e 0e                	jle    8002dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8002ce:	8b 10                	mov    (%eax),%edx
  8002d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002d3:	89 08                	mov    %ecx,(%eax)
  8002d5:	8b 02                	mov    (%edx),%eax
  8002d7:	8b 52 04             	mov    0x4(%edx),%edx
  8002da:	eb 22                	jmp    8002fe <getuint+0x38>
	else if (lflag)
  8002dc:	85 d2                	test   %edx,%edx
  8002de:	74 10                	je     8002f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8002e0:	8b 10                	mov    (%eax),%edx
  8002e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e5:	89 08                	mov    %ecx,(%eax)
  8002e7:	8b 02                	mov    (%edx),%eax
  8002e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8002ee:	eb 0e                	jmp    8002fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8002f0:	8b 10                	mov    (%eax),%edx
  8002f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f5:	89 08                	mov    %ecx,(%eax)
  8002f7:	8b 02                	mov    (%edx),%eax
  8002f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002fe:	5d                   	pop    %ebp
  8002ff:	c3                   	ret    

00800300 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800300:	55                   	push   %ebp
  800301:	89 e5                	mov    %esp,%ebp
  800303:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800306:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80030a:	8b 10                	mov    (%eax),%edx
  80030c:	3b 50 04             	cmp    0x4(%eax),%edx
  80030f:	73 0a                	jae    80031b <sprintputch+0x1b>
		*b->buf++ = ch;
  800311:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800314:	88 0a                	mov    %cl,(%edx)
  800316:	83 c2 01             	add    $0x1,%edx
  800319:	89 10                	mov    %edx,(%eax)
}
  80031b:	5d                   	pop    %ebp
  80031c:	c3                   	ret    

0080031d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80031d:	55                   	push   %ebp
  80031e:	89 e5                	mov    %esp,%ebp
  800320:	57                   	push   %edi
  800321:	56                   	push   %esi
  800322:	53                   	push   %ebx
  800323:	83 ec 5c             	sub    $0x5c,%esp
  800326:	8b 7d 08             	mov    0x8(%ebp),%edi
  800329:	8b 75 0c             	mov    0xc(%ebp),%esi
  80032c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80032f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800336:	eb 11                	jmp    800349 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800338:	85 c0                	test   %eax,%eax
  80033a:	0f 84 16 04 00 00    	je     800756 <vprintfmt+0x439>
				return;
			putch(ch, putdat);
  800340:	89 74 24 04          	mov    %esi,0x4(%esp)
  800344:	89 04 24             	mov    %eax,(%esp)
  800347:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800349:	0f b6 03             	movzbl (%ebx),%eax
  80034c:	83 c3 01             	add    $0x1,%ebx
  80034f:	83 f8 25             	cmp    $0x25,%eax
  800352:	75 e4                	jne    800338 <vprintfmt+0x1b>
  800354:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80035b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800362:	b9 00 00 00 00       	mov    $0x0,%ecx
  800367:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80036b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800372:	eb 06                	jmp    80037a <vprintfmt+0x5d>
  800374:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800378:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80037a:	0f b6 13             	movzbl (%ebx),%edx
  80037d:	0f b6 c2             	movzbl %dl,%eax
  800380:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800383:	8d 43 01             	lea    0x1(%ebx),%eax
  800386:	83 ea 23             	sub    $0x23,%edx
  800389:	80 fa 55             	cmp    $0x55,%dl
  80038c:	0f 87 a7 03 00 00    	ja     800739 <vprintfmt+0x41c>
  800392:	0f b6 d2             	movzbl %dl,%edx
  800395:	ff 24 95 00 14 80 00 	jmp    *0x801400(,%edx,4)
  80039c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8003a0:	eb d6                	jmp    800378 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8003a2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8003a5:	83 ea 30             	sub    $0x30,%edx
  8003a8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8003ab:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003ae:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003b1:	83 fb 09             	cmp    $0x9,%ebx
  8003b4:	77 54                	ja     80040a <vprintfmt+0xed>
  8003b6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8003b9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8003bc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8003bf:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8003c2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8003c6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8003c9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8003cc:	83 fb 09             	cmp    $0x9,%ebx
  8003cf:	76 eb                	jbe    8003bc <vprintfmt+0x9f>
  8003d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8003d4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003d7:	eb 31                	jmp    80040a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8003d9:	8b 55 14             	mov    0x14(%ebp),%edx
  8003dc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8003df:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8003e2:	8b 12                	mov    (%edx),%edx
  8003e4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8003e7:	eb 21                	jmp    80040a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8003e9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8003ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8003f2:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  8003f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8003f9:	e9 7a ff ff ff       	jmp    800378 <vprintfmt+0x5b>
  8003fe:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800405:	e9 6e ff ff ff       	jmp    800378 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80040a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80040e:	0f 89 64 ff ff ff    	jns    800378 <vprintfmt+0x5b>
  800414:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800417:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80041a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80041d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800420:	e9 53 ff ff ff       	jmp    800378 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800425:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800428:	e9 4b ff ff ff       	jmp    800378 <vprintfmt+0x5b>
  80042d:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800430:	8b 45 14             	mov    0x14(%ebp),%eax
  800433:	8d 50 04             	lea    0x4(%eax),%edx
  800436:	89 55 14             	mov    %edx,0x14(%ebp)
  800439:	89 74 24 04          	mov    %esi,0x4(%esp)
  80043d:	8b 00                	mov    (%eax),%eax
  80043f:	89 04 24             	mov    %eax,(%esp)
  800442:	ff d7                	call   *%edi
  800444:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800447:	e9 fd fe ff ff       	jmp    800349 <vprintfmt+0x2c>
  80044c:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80044f:	8b 45 14             	mov    0x14(%ebp),%eax
  800452:	8d 50 04             	lea    0x4(%eax),%edx
  800455:	89 55 14             	mov    %edx,0x14(%ebp)
  800458:	8b 00                	mov    (%eax),%eax
  80045a:	89 c2                	mov    %eax,%edx
  80045c:	c1 fa 1f             	sar    $0x1f,%edx
  80045f:	31 d0                	xor    %edx,%eax
  800461:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800463:	83 f8 08             	cmp    $0x8,%eax
  800466:	7f 0b                	jg     800473 <vprintfmt+0x156>
  800468:	8b 14 85 60 15 80 00 	mov    0x801560(,%eax,4),%edx
  80046f:	85 d2                	test   %edx,%edx
  800471:	75 20                	jne    800493 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800473:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800477:	c7 44 24 08 46 13 80 	movl   $0x801346,0x8(%esp)
  80047e:	00 
  80047f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800483:	89 3c 24             	mov    %edi,(%esp)
  800486:	e8 53 03 00 00       	call   8007de <printfmt>
  80048b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048e:	e9 b6 fe ff ff       	jmp    800349 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800493:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800497:	c7 44 24 08 4f 13 80 	movl   $0x80134f,0x8(%esp)
  80049e:	00 
  80049f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a3:	89 3c 24             	mov    %edi,(%esp)
  8004a6:	e8 33 03 00 00       	call   8007de <printfmt>
  8004ab:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8004ae:	e9 96 fe ff ff       	jmp    800349 <vprintfmt+0x2c>
  8004b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b6:	89 c3                	mov    %eax,%ebx
  8004b8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8004bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8004be:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8004c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c4:	8d 50 04             	lea    0x4(%eax),%edx
  8004c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ca:	8b 00                	mov    (%eax),%eax
  8004cc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8004cf:	85 c0                	test   %eax,%eax
  8004d1:	b8 52 13 80 00       	mov    $0x801352,%eax
  8004d6:	0f 45 45 c4          	cmovne -0x3c(%ebp),%eax
  8004da:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8004dd:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8004e1:	7e 06                	jle    8004e9 <vprintfmt+0x1cc>
  8004e3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8004e7:	75 13                	jne    8004fc <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004e9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8004ec:	0f be 02             	movsbl (%edx),%eax
  8004ef:	85 c0                	test   %eax,%eax
  8004f1:	0f 85 9b 00 00 00    	jne    800592 <vprintfmt+0x275>
  8004f7:	e9 88 00 00 00       	jmp    800584 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800500:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  800503:	89 0c 24             	mov    %ecx,(%esp)
  800506:	e8 20 03 00 00       	call   80082b <strnlen>
  80050b:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80050e:	29 c2                	sub    %eax,%edx
  800510:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800513:	85 d2                	test   %edx,%edx
  800515:	7e d2                	jle    8004e9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800517:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  80051b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80051e:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800521:	89 d3                	mov    %edx,%ebx
  800523:	89 74 24 04          	mov    %esi,0x4(%esp)
  800527:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80052a:	89 04 24             	mov    %eax,(%esp)
  80052d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80052f:	83 eb 01             	sub    $0x1,%ebx
  800532:	85 db                	test   %ebx,%ebx
  800534:	7f ed                	jg     800523 <vprintfmt+0x206>
  800536:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  800539:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800540:	eb a7                	jmp    8004e9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800542:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800546:	74 1a                	je     800562 <vprintfmt+0x245>
  800548:	8d 50 e0             	lea    -0x20(%eax),%edx
  80054b:	83 fa 5e             	cmp    $0x5e,%edx
  80054e:	76 12                	jbe    800562 <vprintfmt+0x245>
					putch('?', putdat);
  800550:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800554:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80055b:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80055e:	66 90                	xchg   %ax,%ax
  800560:	eb 0a                	jmp    80056c <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800562:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800566:	89 04 24             	mov    %eax,(%esp)
  800569:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80056c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800570:	0f be 03             	movsbl (%ebx),%eax
  800573:	85 c0                	test   %eax,%eax
  800575:	74 05                	je     80057c <vprintfmt+0x25f>
  800577:	83 c3 01             	add    $0x1,%ebx
  80057a:	eb 29                	jmp    8005a5 <vprintfmt+0x288>
  80057c:	89 fe                	mov    %edi,%esi
  80057e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800581:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800584:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800588:	7f 2e                	jg     8005b8 <vprintfmt+0x29b>
  80058a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058d:	e9 b7 fd ff ff       	jmp    800349 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800592:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800595:	83 c2 01             	add    $0x1,%edx
  800598:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80059b:	89 f7                	mov    %esi,%edi
  80059d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8005a0:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8005a3:	89 d3                	mov    %edx,%ebx
  8005a5:	85 f6                	test   %esi,%esi
  8005a7:	78 99                	js     800542 <vprintfmt+0x225>
  8005a9:	83 ee 01             	sub    $0x1,%esi
  8005ac:	79 94                	jns    800542 <vprintfmt+0x225>
  8005ae:	89 fe                	mov    %edi,%esi
  8005b0:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005b3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8005b6:	eb cc                	jmp    800584 <vprintfmt+0x267>
  8005b8:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8005bb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8005be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005c2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8005c9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005cb:	83 eb 01             	sub    $0x1,%ebx
  8005ce:	85 db                	test   %ebx,%ebx
  8005d0:	7f ec                	jg     8005be <vprintfmt+0x2a1>
  8005d2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8005d5:	e9 6f fd ff ff       	jmp    800349 <vprintfmt+0x2c>
  8005da:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005dd:	83 f9 01             	cmp    $0x1,%ecx
  8005e0:	7e 16                	jle    8005f8 <vprintfmt+0x2db>
		return va_arg(*ap, long long);
  8005e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e5:	8d 50 08             	lea    0x8(%eax),%edx
  8005e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8005eb:	8b 10                	mov    (%eax),%edx
  8005ed:	8b 48 04             	mov    0x4(%eax),%ecx
  8005f0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8005f3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8005f6:	eb 32                	jmp    80062a <vprintfmt+0x30d>
	else if (lflag)
  8005f8:	85 c9                	test   %ecx,%ecx
  8005fa:	74 18                	je     800614 <vprintfmt+0x2f7>
		return va_arg(*ap, long);
  8005fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8005ff:	8d 50 04             	lea    0x4(%eax),%edx
  800602:	89 55 14             	mov    %edx,0x14(%ebp)
  800605:	8b 00                	mov    (%eax),%eax
  800607:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80060a:	89 c1                	mov    %eax,%ecx
  80060c:	c1 f9 1f             	sar    $0x1f,%ecx
  80060f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800612:	eb 16                	jmp    80062a <vprintfmt+0x30d>
	else
		return va_arg(*ap, int);
  800614:	8b 45 14             	mov    0x14(%ebp),%eax
  800617:	8d 50 04             	lea    0x4(%eax),%edx
  80061a:	89 55 14             	mov    %edx,0x14(%ebp)
  80061d:	8b 00                	mov    (%eax),%eax
  80061f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800622:	89 c2                	mov    %eax,%edx
  800624:	c1 fa 1f             	sar    $0x1f,%edx
  800627:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80062a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80062d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800630:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800635:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800639:	0f 89 b8 00 00 00    	jns    8006f7 <vprintfmt+0x3da>
				putch('-', putdat);
  80063f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800643:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80064a:	ff d7                	call   *%edi
				num = -(long long) num;
  80064c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80064f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800652:	f7 d9                	neg    %ecx
  800654:	83 d3 00             	adc    $0x0,%ebx
  800657:	f7 db                	neg    %ebx
  800659:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065e:	e9 94 00 00 00       	jmp    8006f7 <vprintfmt+0x3da>
  800663:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800666:	89 ca                	mov    %ecx,%edx
  800668:	8d 45 14             	lea    0x14(%ebp),%eax
  80066b:	e8 56 fc ff ff       	call   8002c6 <getuint>
  800670:	89 c1                	mov    %eax,%ecx
  800672:	89 d3                	mov    %edx,%ebx
  800674:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800679:	eb 7c                	jmp    8006f7 <vprintfmt+0x3da>
  80067b:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80067e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800682:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800689:	ff d7                	call   *%edi
			putch('X', putdat);
  80068b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80068f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800696:	ff d7                	call   *%edi
			putch('X', putdat);
  800698:	89 74 24 04          	mov    %esi,0x4(%esp)
  80069c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006a3:	ff d7                	call   *%edi
  8006a5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8006a8:	e9 9c fc ff ff       	jmp    800349 <vprintfmt+0x2c>
  8006ad:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8006b0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006b4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8006bb:	ff d7                	call   *%edi
			putch('x', putdat);
  8006bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006c1:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8006c8:	ff d7                	call   *%edi
			num = (unsigned long long)
  8006ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cd:	8d 50 04             	lea    0x4(%eax),%edx
  8006d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d3:	8b 08                	mov    (%eax),%ecx
  8006d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006da:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8006df:	eb 16                	jmp    8006f7 <vprintfmt+0x3da>
  8006e1:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8006e4:	89 ca                	mov    %ecx,%edx
  8006e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8006e9:	e8 d8 fb ff ff       	call   8002c6 <getuint>
  8006ee:	89 c1                	mov    %eax,%ecx
  8006f0:	89 d3                	mov    %edx,%ebx
  8006f2:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8006f7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8006fb:	89 54 24 10          	mov    %edx,0x10(%esp)
  8006ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800702:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800706:	89 44 24 08          	mov    %eax,0x8(%esp)
  80070a:	89 0c 24             	mov    %ecx,(%esp)
  80070d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800711:	89 f2                	mov    %esi,%edx
  800713:	89 f8                	mov    %edi,%eax
  800715:	e8 b6 fa ff ff       	call   8001d0 <printnum>
  80071a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80071d:	e9 27 fc ff ff       	jmp    800349 <vprintfmt+0x2c>
  800722:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800725:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800728:	89 74 24 04          	mov    %esi,0x4(%esp)
  80072c:	89 14 24             	mov    %edx,(%esp)
  80072f:	ff d7                	call   *%edi
  800731:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800734:	e9 10 fc ff ff       	jmp    800349 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800739:	89 74 24 04          	mov    %esi,0x4(%esp)
  80073d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800744:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800746:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800749:	80 38 25             	cmpb   $0x25,(%eax)
  80074c:	0f 84 f7 fb ff ff    	je     800349 <vprintfmt+0x2c>
  800752:	89 c3                	mov    %eax,%ebx
  800754:	eb f0                	jmp    800746 <vprintfmt+0x429>
				/* do nothing */;
			break;
		}
	}
}
  800756:	83 c4 5c             	add    $0x5c,%esp
  800759:	5b                   	pop    %ebx
  80075a:	5e                   	pop    %esi
  80075b:	5f                   	pop    %edi
  80075c:	5d                   	pop    %ebp
  80075d:	c3                   	ret    

0080075e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80075e:	55                   	push   %ebp
  80075f:	89 e5                	mov    %esp,%ebp
  800761:	83 ec 28             	sub    $0x28,%esp
  800764:	8b 45 08             	mov    0x8(%ebp),%eax
  800767:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80076a:	85 c0                	test   %eax,%eax
  80076c:	74 04                	je     800772 <vsnprintf+0x14>
  80076e:	85 d2                	test   %edx,%edx
  800770:	7f 07                	jg     800779 <vsnprintf+0x1b>
  800772:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800777:	eb 3b                	jmp    8007b4 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800779:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80077c:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800780:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800783:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80078a:	8b 45 14             	mov    0x14(%ebp),%eax
  80078d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800791:	8b 45 10             	mov    0x10(%ebp),%eax
  800794:	89 44 24 08          	mov    %eax,0x8(%esp)
  800798:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80079b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80079f:	c7 04 24 00 03 80 00 	movl   $0x800300,(%esp)
  8007a6:	e8 72 fb ff ff       	call   80031d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007ae:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    

008007b6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8007bc:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8007bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8007c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8007d4:	89 04 24             	mov    %eax,(%esp)
  8007d7:	e8 82 ff ff ff       	call   80075e <vsnprintf>
	va_end(ap);

	return rc;
}
  8007dc:	c9                   	leave  
  8007dd:	c3                   	ret    

008007de <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8007de:	55                   	push   %ebp
  8007df:	89 e5                	mov    %esp,%ebp
  8007e1:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8007e4:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8007e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8007ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8007f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007fc:	89 04 24             	mov    %eax,(%esp)
  8007ff:	e8 19 fb ff ff       	call   80031d <vprintfmt>
	va_end(ap);
}
  800804:	c9                   	leave  
  800805:	c3                   	ret    
  800806:	66 90                	xchg   %ax,%ax
  800808:	66 90                	xchg   %ax,%ax
  80080a:	66 90                	xchg   %ax,%ax
  80080c:	66 90                	xchg   %ax,%ax
  80080e:	66 90                	xchg   %ax,%ax

00800810 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800810:	55                   	push   %ebp
  800811:	89 e5                	mov    %esp,%ebp
  800813:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800816:	b8 00 00 00 00       	mov    $0x0,%eax
  80081b:	80 3a 00             	cmpb   $0x0,(%edx)
  80081e:	74 09                	je     800829 <strlen+0x19>
		n++;
  800820:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800823:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800827:	75 f7                	jne    800820 <strlen+0x10>
		n++;
	return n;
}
  800829:	5d                   	pop    %ebp
  80082a:	c3                   	ret    

0080082b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800832:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800835:	85 c9                	test   %ecx,%ecx
  800837:	74 19                	je     800852 <strnlen+0x27>
  800839:	80 3b 00             	cmpb   $0x0,(%ebx)
  80083c:	74 14                	je     800852 <strnlen+0x27>
  80083e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800843:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800846:	39 c8                	cmp    %ecx,%eax
  800848:	74 0d                	je     800857 <strnlen+0x2c>
  80084a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80084e:	75 f3                	jne    800843 <strnlen+0x18>
  800850:	eb 05                	jmp    800857 <strnlen+0x2c>
  800852:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800857:	5b                   	pop    %ebx
  800858:	5d                   	pop    %ebp
  800859:	c3                   	ret    

0080085a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80085a:	55                   	push   %ebp
  80085b:	89 e5                	mov    %esp,%ebp
  80085d:	53                   	push   %ebx
  80085e:	8b 45 08             	mov    0x8(%ebp),%eax
  800861:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800864:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800869:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80086d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800870:	83 c2 01             	add    $0x1,%edx
  800873:	84 c9                	test   %cl,%cl
  800875:	75 f2                	jne    800869 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800877:	5b                   	pop    %ebx
  800878:	5d                   	pop    %ebp
  800879:	c3                   	ret    

0080087a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	53                   	push   %ebx
  80087e:	83 ec 08             	sub    $0x8,%esp
  800881:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800884:	89 1c 24             	mov    %ebx,(%esp)
  800887:	e8 84 ff ff ff       	call   800810 <strlen>
	strcpy(dst + len, src);
  80088c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80088f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800893:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800896:	89 04 24             	mov    %eax,(%esp)
  800899:	e8 bc ff ff ff       	call   80085a <strcpy>
	return dst;
}
  80089e:	89 d8                	mov    %ebx,%eax
  8008a0:	83 c4 08             	add    $0x8,%esp
  8008a3:	5b                   	pop    %ebx
  8008a4:	5d                   	pop    %ebp
  8008a5:	c3                   	ret    

008008a6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8008a6:	55                   	push   %ebp
  8008a7:	89 e5                	mov    %esp,%ebp
  8008a9:	56                   	push   %esi
  8008aa:	53                   	push   %ebx
  8008ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008b4:	85 f6                	test   %esi,%esi
  8008b6:	74 18                	je     8008d0 <strncpy+0x2a>
  8008b8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8008bd:	0f b6 1a             	movzbl (%edx),%ebx
  8008c0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8008c3:	80 3a 01             	cmpb   $0x1,(%edx)
  8008c6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8008c9:	83 c1 01             	add    $0x1,%ecx
  8008cc:	39 ce                	cmp    %ecx,%esi
  8008ce:	77 ed                	ja     8008bd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8008d0:	5b                   	pop    %ebx
  8008d1:	5e                   	pop    %esi
  8008d2:	5d                   	pop    %ebp
  8008d3:	c3                   	ret    

008008d4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008d4:	55                   	push   %ebp
  8008d5:	89 e5                	mov    %esp,%ebp
  8008d7:	56                   	push   %esi
  8008d8:	53                   	push   %ebx
  8008d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8008dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008e2:	89 f0                	mov    %esi,%eax
  8008e4:	85 c9                	test   %ecx,%ecx
  8008e6:	74 27                	je     80090f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8008e8:	83 e9 01             	sub    $0x1,%ecx
  8008eb:	74 1d                	je     80090a <strlcpy+0x36>
  8008ed:	0f b6 1a             	movzbl (%edx),%ebx
  8008f0:	84 db                	test   %bl,%bl
  8008f2:	74 16                	je     80090a <strlcpy+0x36>
			*dst++ = *src++;
  8008f4:	88 18                	mov    %bl,(%eax)
  8008f6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8008f9:	83 e9 01             	sub    $0x1,%ecx
  8008fc:	74 0e                	je     80090c <strlcpy+0x38>
			*dst++ = *src++;
  8008fe:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800901:	0f b6 1a             	movzbl (%edx),%ebx
  800904:	84 db                	test   %bl,%bl
  800906:	75 ec                	jne    8008f4 <strlcpy+0x20>
  800908:	eb 02                	jmp    80090c <strlcpy+0x38>
  80090a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80090c:	c6 00 00             	movb   $0x0,(%eax)
  80090f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800911:	5b                   	pop    %ebx
  800912:	5e                   	pop    %esi
  800913:	5d                   	pop    %ebp
  800914:	c3                   	ret    

00800915 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800915:	55                   	push   %ebp
  800916:	89 e5                	mov    %esp,%ebp
  800918:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80091b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80091e:	0f b6 01             	movzbl (%ecx),%eax
  800921:	84 c0                	test   %al,%al
  800923:	74 15                	je     80093a <strcmp+0x25>
  800925:	3a 02                	cmp    (%edx),%al
  800927:	75 11                	jne    80093a <strcmp+0x25>
		p++, q++;
  800929:	83 c1 01             	add    $0x1,%ecx
  80092c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80092f:	0f b6 01             	movzbl (%ecx),%eax
  800932:	84 c0                	test   %al,%al
  800934:	74 04                	je     80093a <strcmp+0x25>
  800936:	3a 02                	cmp    (%edx),%al
  800938:	74 ef                	je     800929 <strcmp+0x14>
  80093a:	0f b6 c0             	movzbl %al,%eax
  80093d:	0f b6 12             	movzbl (%edx),%edx
  800940:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800942:	5d                   	pop    %ebp
  800943:	c3                   	ret    

00800944 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800944:	55                   	push   %ebp
  800945:	89 e5                	mov    %esp,%ebp
  800947:	53                   	push   %ebx
  800948:	8b 55 08             	mov    0x8(%ebp),%edx
  80094b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80094e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800951:	85 c0                	test   %eax,%eax
  800953:	74 23                	je     800978 <strncmp+0x34>
  800955:	0f b6 1a             	movzbl (%edx),%ebx
  800958:	84 db                	test   %bl,%bl
  80095a:	74 25                	je     800981 <strncmp+0x3d>
  80095c:	3a 19                	cmp    (%ecx),%bl
  80095e:	75 21                	jne    800981 <strncmp+0x3d>
  800960:	83 e8 01             	sub    $0x1,%eax
  800963:	74 13                	je     800978 <strncmp+0x34>
		n--, p++, q++;
  800965:	83 c2 01             	add    $0x1,%edx
  800968:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  80096b:	0f b6 1a             	movzbl (%edx),%ebx
  80096e:	84 db                	test   %bl,%bl
  800970:	74 0f                	je     800981 <strncmp+0x3d>
  800972:	3a 19                	cmp    (%ecx),%bl
  800974:	74 ea                	je     800960 <strncmp+0x1c>
  800976:	eb 09                	jmp    800981 <strncmp+0x3d>
  800978:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  80097d:	5b                   	pop    %ebx
  80097e:	5d                   	pop    %ebp
  80097f:	90                   	nop
  800980:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800981:	0f b6 02             	movzbl (%edx),%eax
  800984:	0f b6 11             	movzbl (%ecx),%edx
  800987:	29 d0                	sub    %edx,%eax
  800989:	eb f2                	jmp    80097d <strncmp+0x39>

0080098b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80098b:	55                   	push   %ebp
  80098c:	89 e5                	mov    %esp,%ebp
  80098e:	8b 45 08             	mov    0x8(%ebp),%eax
  800991:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800995:	0f b6 10             	movzbl (%eax),%edx
  800998:	84 d2                	test   %dl,%dl
  80099a:	74 18                	je     8009b4 <strchr+0x29>
		if (*s == c)
  80099c:	38 ca                	cmp    %cl,%dl
  80099e:	75 0a                	jne    8009aa <strchr+0x1f>
  8009a0:	eb 17                	jmp    8009b9 <strchr+0x2e>
  8009a2:	38 ca                	cmp    %cl,%dl
  8009a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009a8:	74 0f                	je     8009b9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8009aa:	83 c0 01             	add    $0x1,%eax
  8009ad:	0f b6 10             	movzbl (%eax),%edx
  8009b0:	84 d2                	test   %dl,%dl
  8009b2:	75 ee                	jne    8009a2 <strchr+0x17>
  8009b4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  8009b9:	5d                   	pop    %ebp
  8009ba:	c3                   	ret    

008009bb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8009bb:	55                   	push   %ebp
  8009bc:	89 e5                	mov    %esp,%ebp
  8009be:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009c5:	0f b6 10             	movzbl (%eax),%edx
  8009c8:	84 d2                	test   %dl,%dl
  8009ca:	74 18                	je     8009e4 <strfind+0x29>
		if (*s == c)
  8009cc:	38 ca                	cmp    %cl,%dl
  8009ce:	75 0a                	jne    8009da <strfind+0x1f>
  8009d0:	eb 12                	jmp    8009e4 <strfind+0x29>
  8009d2:	38 ca                	cmp    %cl,%dl
  8009d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8009d8:	74 0a                	je     8009e4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  8009da:	83 c0 01             	add    $0x1,%eax
  8009dd:	0f b6 10             	movzbl (%eax),%edx
  8009e0:	84 d2                	test   %dl,%dl
  8009e2:	75 ee                	jne    8009d2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  8009e4:	5d                   	pop    %ebp
  8009e5:	c3                   	ret    

008009e6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	83 ec 0c             	sub    $0xc,%esp
  8009ec:	89 1c 24             	mov    %ebx,(%esp)
  8009ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009f3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8009f7:	8b 7d 08             	mov    0x8(%ebp),%edi
  8009fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a00:	85 c9                	test   %ecx,%ecx
  800a02:	74 30                	je     800a34 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a0a:	75 25                	jne    800a31 <memset+0x4b>
  800a0c:	f6 c1 03             	test   $0x3,%cl
  800a0f:	75 20                	jne    800a31 <memset+0x4b>
		c &= 0xFF;
  800a11:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a14:	89 d3                	mov    %edx,%ebx
  800a16:	c1 e3 08             	shl    $0x8,%ebx
  800a19:	89 d6                	mov    %edx,%esi
  800a1b:	c1 e6 18             	shl    $0x18,%esi
  800a1e:	89 d0                	mov    %edx,%eax
  800a20:	c1 e0 10             	shl    $0x10,%eax
  800a23:	09 f0                	or     %esi,%eax
  800a25:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a27:	09 d8                	or     %ebx,%eax
  800a29:	c1 e9 02             	shr    $0x2,%ecx
  800a2c:	fc                   	cld    
  800a2d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a2f:	eb 03                	jmp    800a34 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a31:	fc                   	cld    
  800a32:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a34:	89 f8                	mov    %edi,%eax
  800a36:	8b 1c 24             	mov    (%esp),%ebx
  800a39:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a3d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800a41:	89 ec                	mov    %ebp,%esp
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	83 ec 08             	sub    $0x8,%esp
  800a4b:	89 34 24             	mov    %esi,(%esp)
  800a4e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800a52:	8b 45 08             	mov    0x8(%ebp),%eax
  800a55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800a58:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800a5b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800a5d:	39 c6                	cmp    %eax,%esi
  800a5f:	73 35                	jae    800a96 <memmove+0x51>
  800a61:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800a64:	39 d0                	cmp    %edx,%eax
  800a66:	73 2e                	jae    800a96 <memmove+0x51>
		s += n;
		d += n;
  800a68:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a6a:	f6 c2 03             	test   $0x3,%dl
  800a6d:	75 1b                	jne    800a8a <memmove+0x45>
  800a6f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a75:	75 13                	jne    800a8a <memmove+0x45>
  800a77:	f6 c1 03             	test   $0x3,%cl
  800a7a:	75 0e                	jne    800a8a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800a7c:	83 ef 04             	sub    $0x4,%edi
  800a7f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a82:	c1 e9 02             	shr    $0x2,%ecx
  800a85:	fd                   	std    
  800a86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a88:	eb 09                	jmp    800a93 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800a8a:	83 ef 01             	sub    $0x1,%edi
  800a8d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800a90:	fd                   	std    
  800a91:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a93:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800a94:	eb 20                	jmp    800ab6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a96:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a9c:	75 15                	jne    800ab3 <memmove+0x6e>
  800a9e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aa4:	75 0d                	jne    800ab3 <memmove+0x6e>
  800aa6:	f6 c1 03             	test   $0x3,%cl
  800aa9:	75 08                	jne    800ab3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800aab:	c1 e9 02             	shr    $0x2,%ecx
  800aae:	fc                   	cld    
  800aaf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ab1:	eb 03                	jmp    800ab6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800ab3:	fc                   	cld    
  800ab4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800ab6:	8b 34 24             	mov    (%esp),%esi
  800ab9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800abd:	89 ec                	mov    %ebp,%esp
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ac7:	8b 45 10             	mov    0x10(%ebp),%eax
  800aca:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ace:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad8:	89 04 24             	mov    %eax,(%esp)
  800adb:	e8 65 ff ff ff       	call   800a45 <memmove>
}
  800ae0:	c9                   	leave  
  800ae1:	c3                   	ret    

00800ae2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	57                   	push   %edi
  800ae6:	56                   	push   %esi
  800ae7:	53                   	push   %ebx
  800ae8:	8b 75 08             	mov    0x8(%ebp),%esi
  800aeb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800aee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800af1:	85 c9                	test   %ecx,%ecx
  800af3:	74 36                	je     800b2b <memcmp+0x49>
		if (*s1 != *s2)
  800af5:	0f b6 06             	movzbl (%esi),%eax
  800af8:	0f b6 1f             	movzbl (%edi),%ebx
  800afb:	38 d8                	cmp    %bl,%al
  800afd:	74 20                	je     800b1f <memcmp+0x3d>
  800aff:	eb 14                	jmp    800b15 <memcmp+0x33>
  800b01:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b06:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b0b:	83 c2 01             	add    $0x1,%edx
  800b0e:	83 e9 01             	sub    $0x1,%ecx
  800b11:	38 d8                	cmp    %bl,%al
  800b13:	74 12                	je     800b27 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b15:	0f b6 c0             	movzbl %al,%eax
  800b18:	0f b6 db             	movzbl %bl,%ebx
  800b1b:	29 d8                	sub    %ebx,%eax
  800b1d:	eb 11                	jmp    800b30 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b1f:	83 e9 01             	sub    $0x1,%ecx
  800b22:	ba 00 00 00 00       	mov    $0x0,%edx
  800b27:	85 c9                	test   %ecx,%ecx
  800b29:	75 d6                	jne    800b01 <memcmp+0x1f>
  800b2b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b30:	5b                   	pop    %ebx
  800b31:	5e                   	pop    %esi
  800b32:	5f                   	pop    %edi
  800b33:	5d                   	pop    %ebp
  800b34:	c3                   	ret    

00800b35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b35:	55                   	push   %ebp
  800b36:	89 e5                	mov    %esp,%ebp
  800b38:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b3b:	89 c2                	mov    %eax,%edx
  800b3d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b40:	39 d0                	cmp    %edx,%eax
  800b42:	73 15                	jae    800b59 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b44:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800b48:	38 08                	cmp    %cl,(%eax)
  800b4a:	75 06                	jne    800b52 <memfind+0x1d>
  800b4c:	eb 0b                	jmp    800b59 <memfind+0x24>
  800b4e:	38 08                	cmp    %cl,(%eax)
  800b50:	74 07                	je     800b59 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800b52:	83 c0 01             	add    $0x1,%eax
  800b55:	39 c2                	cmp    %eax,%edx
  800b57:	77 f5                	ja     800b4e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800b59:	5d                   	pop    %ebp
  800b5a:	c3                   	ret    

00800b5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b5b:	55                   	push   %ebp
  800b5c:	89 e5                	mov    %esp,%ebp
  800b5e:	57                   	push   %edi
  800b5f:	56                   	push   %esi
  800b60:	53                   	push   %ebx
  800b61:	83 ec 04             	sub    $0x4,%esp
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
  800b67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b6a:	0f b6 02             	movzbl (%edx),%eax
  800b6d:	3c 20                	cmp    $0x20,%al
  800b6f:	74 04                	je     800b75 <strtol+0x1a>
  800b71:	3c 09                	cmp    $0x9,%al
  800b73:	75 0e                	jne    800b83 <strtol+0x28>
		s++;
  800b75:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b78:	0f b6 02             	movzbl (%edx),%eax
  800b7b:	3c 20                	cmp    $0x20,%al
  800b7d:	74 f6                	je     800b75 <strtol+0x1a>
  800b7f:	3c 09                	cmp    $0x9,%al
  800b81:	74 f2                	je     800b75 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800b83:	3c 2b                	cmp    $0x2b,%al
  800b85:	75 0c                	jne    800b93 <strtol+0x38>
		s++;
  800b87:	83 c2 01             	add    $0x1,%edx
  800b8a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b91:	eb 15                	jmp    800ba8 <strtol+0x4d>
	else if (*s == '-')
  800b93:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800b9a:	3c 2d                	cmp    $0x2d,%al
  800b9c:	75 0a                	jne    800ba8 <strtol+0x4d>
		s++, neg = 1;
  800b9e:	83 c2 01             	add    $0x1,%edx
  800ba1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ba8:	85 db                	test   %ebx,%ebx
  800baa:	0f 94 c0             	sete   %al
  800bad:	74 05                	je     800bb4 <strtol+0x59>
  800baf:	83 fb 10             	cmp    $0x10,%ebx
  800bb2:	75 18                	jne    800bcc <strtol+0x71>
  800bb4:	80 3a 30             	cmpb   $0x30,(%edx)
  800bb7:	75 13                	jne    800bcc <strtol+0x71>
  800bb9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800bbd:	8d 76 00             	lea    0x0(%esi),%esi
  800bc0:	75 0a                	jne    800bcc <strtol+0x71>
		s += 2, base = 16;
  800bc2:	83 c2 02             	add    $0x2,%edx
  800bc5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bca:	eb 15                	jmp    800be1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800bcc:	84 c0                	test   %al,%al
  800bce:	66 90                	xchg   %ax,%ax
  800bd0:	74 0f                	je     800be1 <strtol+0x86>
  800bd2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800bd7:	80 3a 30             	cmpb   $0x30,(%edx)
  800bda:	75 05                	jne    800be1 <strtol+0x86>
		s++, base = 8;
  800bdc:	83 c2 01             	add    $0x1,%edx
  800bdf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800be1:	b8 00 00 00 00       	mov    $0x0,%eax
  800be6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800be8:	0f b6 0a             	movzbl (%edx),%ecx
  800beb:	89 cf                	mov    %ecx,%edi
  800bed:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800bf0:	80 fb 09             	cmp    $0x9,%bl
  800bf3:	77 08                	ja     800bfd <strtol+0xa2>
			dig = *s - '0';
  800bf5:	0f be c9             	movsbl %cl,%ecx
  800bf8:	83 e9 30             	sub    $0x30,%ecx
  800bfb:	eb 1e                	jmp    800c1b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800bfd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c00:	80 fb 19             	cmp    $0x19,%bl
  800c03:	77 08                	ja     800c0d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c05:	0f be c9             	movsbl %cl,%ecx
  800c08:	83 e9 57             	sub    $0x57,%ecx
  800c0b:	eb 0e                	jmp    800c1b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c0d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c10:	80 fb 19             	cmp    $0x19,%bl
  800c13:	77 15                	ja     800c2a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c15:	0f be c9             	movsbl %cl,%ecx
  800c18:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c1b:	39 f1                	cmp    %esi,%ecx
  800c1d:	7d 0b                	jge    800c2a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c1f:	83 c2 01             	add    $0x1,%edx
  800c22:	0f af c6             	imul   %esi,%eax
  800c25:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c28:	eb be                	jmp    800be8 <strtol+0x8d>
  800c2a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c2c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c30:	74 05                	je     800c37 <strtol+0xdc>
		*endptr = (char *) s;
  800c32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c35:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c37:	89 ca                	mov    %ecx,%edx
  800c39:	f7 da                	neg    %edx
  800c3b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c3f:	0f 45 c2             	cmovne %edx,%eax
}
  800c42:	83 c4 04             	add    $0x4,%esp
  800c45:	5b                   	pop    %ebx
  800c46:	5e                   	pop    %esi
  800c47:	5f                   	pop    %edi
  800c48:	5d                   	pop    %ebp
  800c49:	c3                   	ret    

00800c4a <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800c4a:	55                   	push   %ebp
  800c4b:	89 e5                	mov    %esp,%ebp
  800c4d:	83 ec 0c             	sub    $0xc,%esp
  800c50:	89 1c 24             	mov    %ebx,(%esp)
  800c53:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c57:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800c60:	b8 01 00 00 00       	mov    $0x1,%eax
  800c65:	89 d1                	mov    %edx,%ecx
  800c67:	89 d3                	mov    %edx,%ebx
  800c69:	89 d7                	mov    %edx,%edi
  800c6b:	89 d6                	mov    %edx,%esi
  800c6d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800c6f:	8b 1c 24             	mov    (%esp),%ebx
  800c72:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c76:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c7a:	89 ec                	mov    %ebp,%esp
  800c7c:	5d                   	pop    %ebp
  800c7d:	c3                   	ret    

00800c7e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	83 ec 0c             	sub    $0xc,%esp
  800c84:	89 1c 24             	mov    %ebx,(%esp)
  800c87:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c8b:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c97:	8b 55 08             	mov    0x8(%ebp),%edx
  800c9a:	89 c3                	mov    %eax,%ebx
  800c9c:	89 c7                	mov    %eax,%edi
  800c9e:	89 c6                	mov    %eax,%esi
  800ca0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ca2:	8b 1c 24             	mov    (%esp),%ebx
  800ca5:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ca9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cad:	89 ec                	mov    %ebp,%esp
  800caf:	5d                   	pop    %ebp
  800cb0:	c3                   	ret    

00800cb1 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	83 ec 38             	sub    $0x38,%esp
  800cb7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800cba:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800cbd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cc0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cc5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800cca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ccd:	89 cb                	mov    %ecx,%ebx
  800ccf:	89 cf                	mov    %ecx,%edi
  800cd1:	89 ce                	mov    %ecx,%esi
  800cd3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800cd5:	85 c0                	test   %eax,%eax
  800cd7:	7e 28                	jle    800d01 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800cd9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800cdd:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ce4:	00 
  800ce5:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800cec:	00 
  800ced:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800cf4:	00 
  800cf5:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800cfc:	e8 e1 02 00 00       	call   800fe2 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d01:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d04:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d07:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d0a:	89 ec                	mov    %ebp,%esp
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d0e:	55                   	push   %ebp
  800d0f:	89 e5                	mov    %esp,%ebp
  800d11:	83 ec 0c             	sub    $0xc,%esp
  800d14:	89 1c 24             	mov    %ebx,(%esp)
  800d17:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d1b:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d1f:	be 00 00 00 00       	mov    $0x0,%esi
  800d24:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d29:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d37:	8b 1c 24             	mov    (%esp),%ebx
  800d3a:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d3e:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d42:	89 ec                	mov    %ebp,%esp
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d46:	55                   	push   %ebp
  800d47:	89 e5                	mov    %esp,%ebp
  800d49:	83 ec 38             	sub    $0x38,%esp
  800d4c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d4f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d52:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800d5a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d62:	8b 55 08             	mov    0x8(%ebp),%edx
  800d65:	89 df                	mov    %ebx,%edi
  800d67:	89 de                	mov    %ebx,%esi
  800d69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d6b:	85 c0                	test   %eax,%eax
  800d6d:	7e 28                	jle    800d97 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d6f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d73:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800d7a:	00 
  800d7b:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800d82:	00 
  800d83:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d8a:	00 
  800d8b:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800d92:	e8 4b 02 00 00       	call   800fe2 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800d97:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d9a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d9d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800da0:	89 ec                	mov    %ebp,%esp
  800da2:	5d                   	pop    %ebp
  800da3:	c3                   	ret    

00800da4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800da4:	55                   	push   %ebp
  800da5:	89 e5                	mov    %esp,%ebp
  800da7:	83 ec 38             	sub    $0x38,%esp
  800daa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dad:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800db0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800db8:	b8 08 00 00 00       	mov    $0x8,%eax
  800dbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc3:	89 df                	mov    %ebx,%edi
  800dc5:	89 de                	mov    %ebx,%esi
  800dc7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	7e 28                	jle    800df5 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd1:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800dd8:	00 
  800dd9:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800de0:	00 
  800de1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800de8:	00 
  800de9:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800df0:	e8 ed 01 00 00       	call   800fe2 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800df5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800df8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dfb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dfe:	89 ec                	mov    %ebp,%esp
  800e00:	5d                   	pop    %ebp
  800e01:	c3                   	ret    

00800e02 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e02:	55                   	push   %ebp
  800e03:	89 e5                	mov    %esp,%ebp
  800e05:	83 ec 38             	sub    $0x38,%esp
  800e08:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e0b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e0e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e16:	b8 06 00 00 00       	mov    $0x6,%eax
  800e1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e21:	89 df                	mov    %ebx,%edi
  800e23:	89 de                	mov    %ebx,%esi
  800e25:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e27:	85 c0                	test   %eax,%eax
  800e29:	7e 28                	jle    800e53 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e2f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e36:	00 
  800e37:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800e3e:	00 
  800e3f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e46:	00 
  800e47:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800e4e:	e8 8f 01 00 00       	call   800fe2 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800e53:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e56:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e59:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e5c:	89 ec                	mov    %ebp,%esp
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e60:	55                   	push   %ebp
  800e61:	89 e5                	mov    %esp,%ebp
  800e63:	83 ec 38             	sub    $0x38,%esp
  800e66:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e69:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e6c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e6f:	b8 05 00 00 00       	mov    $0x5,%eax
  800e74:	8b 75 18             	mov    0x18(%ebp),%esi
  800e77:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e80:	8b 55 08             	mov    0x8(%ebp),%edx
  800e83:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e85:	85 c0                	test   %eax,%eax
  800e87:	7e 28                	jle    800eb1 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e89:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8d:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800e94:	00 
  800e95:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800e9c:	00 
  800e9d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea4:	00 
  800ea5:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800eac:	e8 31 01 00 00       	call   800fe2 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800eb1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eb4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eb7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eba:	89 ec                	mov    %ebp,%esp
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	83 ec 38             	sub    $0x38,%esp
  800ec4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ec7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eca:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecd:	be 00 00 00 00       	mov    $0x0,%esi
  800ed2:	b8 04 00 00 00       	mov    $0x4,%eax
  800ed7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800edd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee0:	89 f7                	mov    %esi,%edi
  800ee2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee4:	85 c0                	test   %eax,%eax
  800ee6:	7e 28                	jle    800f10 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eec:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ef3:	00 
  800ef4:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800efb:	00 
  800efc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f03:	00 
  800f04:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800f0b:	e8 d2 00 00 00       	call   800fe2 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f10:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f13:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f16:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f19:	89 ec                	mov    %ebp,%esp
  800f1b:	5d                   	pop    %ebp
  800f1c:	c3                   	ret    

00800f1d <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800f1d:	55                   	push   %ebp
  800f1e:	89 e5                	mov    %esp,%ebp
  800f20:	83 ec 0c             	sub    $0xc,%esp
  800f23:	89 1c 24             	mov    %ebx,(%esp)
  800f26:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f2a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f33:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f38:	89 d1                	mov    %edx,%ecx
  800f3a:	89 d3                	mov    %edx,%ebx
  800f3c:	89 d7                	mov    %edx,%edi
  800f3e:	89 d6                	mov    %edx,%esi
  800f40:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800f42:	8b 1c 24             	mov    (%esp),%ebx
  800f45:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f49:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f4d:	89 ec                	mov    %ebp,%esp
  800f4f:	5d                   	pop    %ebp
  800f50:	c3                   	ret    

00800f51 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800f51:	55                   	push   %ebp
  800f52:	89 e5                	mov    %esp,%ebp
  800f54:	83 ec 0c             	sub    $0xc,%esp
  800f57:	89 1c 24             	mov    %ebx,(%esp)
  800f5a:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f5e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f62:	ba 00 00 00 00       	mov    $0x0,%edx
  800f67:	b8 02 00 00 00       	mov    $0x2,%eax
  800f6c:	89 d1                	mov    %edx,%ecx
  800f6e:	89 d3                	mov    %edx,%ebx
  800f70:	89 d7                	mov    %edx,%edi
  800f72:	89 d6                	mov    %edx,%esi
  800f74:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800f76:	8b 1c 24             	mov    (%esp),%ebx
  800f79:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f7d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f81:	89 ec                	mov    %ebp,%esp
  800f83:	5d                   	pop    %ebp
  800f84:	c3                   	ret    

00800f85 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800f85:	55                   	push   %ebp
  800f86:	89 e5                	mov    %esp,%ebp
  800f88:	83 ec 38             	sub    $0x38,%esp
  800f8b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f8e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f91:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f94:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f99:	b8 03 00 00 00       	mov    $0x3,%eax
  800f9e:	8b 55 08             	mov    0x8(%ebp),%edx
  800fa1:	89 cb                	mov    %ecx,%ebx
  800fa3:	89 cf                	mov    %ecx,%edi
  800fa5:	89 ce                	mov    %ecx,%esi
  800fa7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fa9:	85 c0                	test   %eax,%eax
  800fab:	7e 28                	jle    800fd5 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fad:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fb1:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800fb8:	00 
  800fb9:	c7 44 24 08 84 15 80 	movl   $0x801584,0x8(%esp)
  800fc0:	00 
  800fc1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fc8:	00 
  800fc9:	c7 04 24 a1 15 80 00 	movl   $0x8015a1,(%esp)
  800fd0:	e8 0d 00 00 00       	call   800fe2 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800fd5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fd8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fdb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fde:	89 ec                	mov    %ebp,%esp
  800fe0:	5d                   	pop    %ebp
  800fe1:	c3                   	ret    

00800fe2 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	56                   	push   %esi
  800fe6:	53                   	push   %ebx
  800fe7:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800fea:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800fed:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800ff3:	e8 59 ff ff ff       	call   800f51 <sys_getenvid>
  800ff8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ffb:	89 54 24 10          	mov    %edx,0x10(%esp)
  800fff:	8b 55 08             	mov    0x8(%ebp),%edx
  801002:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801006:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80100a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80100e:	c7 04 24 b0 15 80 00 	movl   $0x8015b0,(%esp)
  801015:	e8 52 f1 ff ff       	call   80016c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80101a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80101e:	8b 45 10             	mov    0x10(%ebp),%eax
  801021:	89 04 24             	mov    %eax,(%esp)
  801024:	e8 e2 f0 ff ff       	call   80010b <vcprintf>
	cprintf("\n");
  801029:	c7 04 24 d4 15 80 00 	movl   $0x8015d4,(%esp)
  801030:	e8 37 f1 ff ff       	call   80016c <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801035:	cc                   	int3   
  801036:	eb fd                	jmp    801035 <_panic+0x53>
  801038:	66 90                	xchg   %ax,%ax
  80103a:	66 90                	xchg   %ax,%ax
  80103c:	66 90                	xchg   %ax,%ax
  80103e:	66 90                	xchg   %ax,%ax

00801040 <__udivdi3>:
  801040:	55                   	push   %ebp
  801041:	89 e5                	mov    %esp,%ebp
  801043:	57                   	push   %edi
  801044:	56                   	push   %esi
  801045:	83 ec 10             	sub    $0x10,%esp
  801048:	8b 45 14             	mov    0x14(%ebp),%eax
  80104b:	8b 55 08             	mov    0x8(%ebp),%edx
  80104e:	8b 75 10             	mov    0x10(%ebp),%esi
  801051:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801054:	85 c0                	test   %eax,%eax
  801056:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801059:	75 35                	jne    801090 <__udivdi3+0x50>
  80105b:	39 fe                	cmp    %edi,%esi
  80105d:	77 61                	ja     8010c0 <__udivdi3+0x80>
  80105f:	85 f6                	test   %esi,%esi
  801061:	75 0b                	jne    80106e <__udivdi3+0x2e>
  801063:	b8 01 00 00 00       	mov    $0x1,%eax
  801068:	31 d2                	xor    %edx,%edx
  80106a:	f7 f6                	div    %esi
  80106c:	89 c6                	mov    %eax,%esi
  80106e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801071:	31 d2                	xor    %edx,%edx
  801073:	89 f8                	mov    %edi,%eax
  801075:	f7 f6                	div    %esi
  801077:	89 c7                	mov    %eax,%edi
  801079:	89 c8                	mov    %ecx,%eax
  80107b:	f7 f6                	div    %esi
  80107d:	89 c1                	mov    %eax,%ecx
  80107f:	89 fa                	mov    %edi,%edx
  801081:	89 c8                	mov    %ecx,%eax
  801083:	83 c4 10             	add    $0x10,%esp
  801086:	5e                   	pop    %esi
  801087:	5f                   	pop    %edi
  801088:	5d                   	pop    %ebp
  801089:	c3                   	ret    
  80108a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801090:	39 f8                	cmp    %edi,%eax
  801092:	77 1c                	ja     8010b0 <__udivdi3+0x70>
  801094:	0f bd d0             	bsr    %eax,%edx
  801097:	83 f2 1f             	xor    $0x1f,%edx
  80109a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80109d:	75 39                	jne    8010d8 <__udivdi3+0x98>
  80109f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8010a2:	0f 86 a0 00 00 00    	jbe    801148 <__udivdi3+0x108>
  8010a8:	39 f8                	cmp    %edi,%eax
  8010aa:	0f 82 98 00 00 00    	jb     801148 <__udivdi3+0x108>
  8010b0:	31 ff                	xor    %edi,%edi
  8010b2:	31 c9                	xor    %ecx,%ecx
  8010b4:	89 c8                	mov    %ecx,%eax
  8010b6:	89 fa                	mov    %edi,%edx
  8010b8:	83 c4 10             	add    $0x10,%esp
  8010bb:	5e                   	pop    %esi
  8010bc:	5f                   	pop    %edi
  8010bd:	5d                   	pop    %ebp
  8010be:	c3                   	ret    
  8010bf:	90                   	nop
  8010c0:	89 d1                	mov    %edx,%ecx
  8010c2:	89 fa                	mov    %edi,%edx
  8010c4:	89 c8                	mov    %ecx,%eax
  8010c6:	31 ff                	xor    %edi,%edi
  8010c8:	f7 f6                	div    %esi
  8010ca:	89 c1                	mov    %eax,%ecx
  8010cc:	89 fa                	mov    %edi,%edx
  8010ce:	89 c8                	mov    %ecx,%eax
  8010d0:	83 c4 10             	add    $0x10,%esp
  8010d3:	5e                   	pop    %esi
  8010d4:	5f                   	pop    %edi
  8010d5:	5d                   	pop    %ebp
  8010d6:	c3                   	ret    
  8010d7:	90                   	nop
  8010d8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010dc:	89 f2                	mov    %esi,%edx
  8010de:	d3 e0                	shl    %cl,%eax
  8010e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8010e3:	b8 20 00 00 00       	mov    $0x20,%eax
  8010e8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8010eb:	89 c1                	mov    %eax,%ecx
  8010ed:	d3 ea                	shr    %cl,%edx
  8010ef:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010f3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8010f6:	d3 e6                	shl    %cl,%esi
  8010f8:	89 c1                	mov    %eax,%ecx
  8010fa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8010fd:	89 fe                	mov    %edi,%esi
  8010ff:	d3 ee                	shr    %cl,%esi
  801101:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801105:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801108:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80110b:	d3 e7                	shl    %cl,%edi
  80110d:	89 c1                	mov    %eax,%ecx
  80110f:	d3 ea                	shr    %cl,%edx
  801111:	09 d7                	or     %edx,%edi
  801113:	89 f2                	mov    %esi,%edx
  801115:	89 f8                	mov    %edi,%eax
  801117:	f7 75 ec             	divl   -0x14(%ebp)
  80111a:	89 d6                	mov    %edx,%esi
  80111c:	89 c7                	mov    %eax,%edi
  80111e:	f7 65 e8             	mull   -0x18(%ebp)
  801121:	39 d6                	cmp    %edx,%esi
  801123:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801126:	72 30                	jb     801158 <__udivdi3+0x118>
  801128:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80112b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80112f:	d3 e2                	shl    %cl,%edx
  801131:	39 c2                	cmp    %eax,%edx
  801133:	73 05                	jae    80113a <__udivdi3+0xfa>
  801135:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801138:	74 1e                	je     801158 <__udivdi3+0x118>
  80113a:	89 f9                	mov    %edi,%ecx
  80113c:	31 ff                	xor    %edi,%edi
  80113e:	e9 71 ff ff ff       	jmp    8010b4 <__udivdi3+0x74>
  801143:	90                   	nop
  801144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801148:	31 ff                	xor    %edi,%edi
  80114a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80114f:	e9 60 ff ff ff       	jmp    8010b4 <__udivdi3+0x74>
  801154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801158:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80115b:	31 ff                	xor    %edi,%edi
  80115d:	89 c8                	mov    %ecx,%eax
  80115f:	89 fa                	mov    %edi,%edx
  801161:	83 c4 10             	add    $0x10,%esp
  801164:	5e                   	pop    %esi
  801165:	5f                   	pop    %edi
  801166:	5d                   	pop    %ebp
  801167:	c3                   	ret    
  801168:	66 90                	xchg   %ax,%ax
  80116a:	66 90                	xchg   %ax,%ax
  80116c:	66 90                	xchg   %ax,%ax
  80116e:	66 90                	xchg   %ax,%ax

00801170 <__umoddi3>:
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	57                   	push   %edi
  801174:	56                   	push   %esi
  801175:	83 ec 20             	sub    $0x20,%esp
  801178:	8b 55 14             	mov    0x14(%ebp),%edx
  80117b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80117e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801181:	8b 75 0c             	mov    0xc(%ebp),%esi
  801184:	85 d2                	test   %edx,%edx
  801186:	89 c8                	mov    %ecx,%eax
  801188:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80118b:	75 13                	jne    8011a0 <__umoddi3+0x30>
  80118d:	39 f7                	cmp    %esi,%edi
  80118f:	76 3f                	jbe    8011d0 <__umoddi3+0x60>
  801191:	89 f2                	mov    %esi,%edx
  801193:	f7 f7                	div    %edi
  801195:	89 d0                	mov    %edx,%eax
  801197:	31 d2                	xor    %edx,%edx
  801199:	83 c4 20             	add    $0x20,%esp
  80119c:	5e                   	pop    %esi
  80119d:	5f                   	pop    %edi
  80119e:	5d                   	pop    %ebp
  80119f:	c3                   	ret    
  8011a0:	39 f2                	cmp    %esi,%edx
  8011a2:	77 4c                	ja     8011f0 <__umoddi3+0x80>
  8011a4:	0f bd ca             	bsr    %edx,%ecx
  8011a7:	83 f1 1f             	xor    $0x1f,%ecx
  8011aa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8011ad:	75 51                	jne    801200 <__umoddi3+0x90>
  8011af:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8011b2:	0f 87 e0 00 00 00    	ja     801298 <__umoddi3+0x128>
  8011b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011bb:	29 f8                	sub    %edi,%eax
  8011bd:	19 d6                	sbb    %edx,%esi
  8011bf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8011c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011c5:	89 f2                	mov    %esi,%edx
  8011c7:	83 c4 20             	add    $0x20,%esp
  8011ca:	5e                   	pop    %esi
  8011cb:	5f                   	pop    %edi
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    
  8011ce:	66 90                	xchg   %ax,%ax
  8011d0:	85 ff                	test   %edi,%edi
  8011d2:	75 0b                	jne    8011df <__umoddi3+0x6f>
  8011d4:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d9:	31 d2                	xor    %edx,%edx
  8011db:	f7 f7                	div    %edi
  8011dd:	89 c7                	mov    %eax,%edi
  8011df:	89 f0                	mov    %esi,%eax
  8011e1:	31 d2                	xor    %edx,%edx
  8011e3:	f7 f7                	div    %edi
  8011e5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011e8:	f7 f7                	div    %edi
  8011ea:	eb a9                	jmp    801195 <__umoddi3+0x25>
  8011ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011f0:	89 c8                	mov    %ecx,%eax
  8011f2:	89 f2                	mov    %esi,%edx
  8011f4:	83 c4 20             	add    $0x20,%esp
  8011f7:	5e                   	pop    %esi
  8011f8:	5f                   	pop    %edi
  8011f9:	5d                   	pop    %ebp
  8011fa:	c3                   	ret    
  8011fb:	90                   	nop
  8011fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801200:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801204:	d3 e2                	shl    %cl,%edx
  801206:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801209:	ba 20 00 00 00       	mov    $0x20,%edx
  80120e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801211:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801214:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801218:	89 fa                	mov    %edi,%edx
  80121a:	d3 ea                	shr    %cl,%edx
  80121c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801220:	0b 55 f4             	or     -0xc(%ebp),%edx
  801223:	d3 e7                	shl    %cl,%edi
  801225:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801229:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80122c:	89 f2                	mov    %esi,%edx
  80122e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801231:	89 c7                	mov    %eax,%edi
  801233:	d3 ea                	shr    %cl,%edx
  801235:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801239:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80123c:	89 c2                	mov    %eax,%edx
  80123e:	d3 e6                	shl    %cl,%esi
  801240:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801244:	d3 ea                	shr    %cl,%edx
  801246:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80124a:	09 d6                	or     %edx,%esi
  80124c:	89 f0                	mov    %esi,%eax
  80124e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801251:	d3 e7                	shl    %cl,%edi
  801253:	89 f2                	mov    %esi,%edx
  801255:	f7 75 f4             	divl   -0xc(%ebp)
  801258:	89 d6                	mov    %edx,%esi
  80125a:	f7 65 e8             	mull   -0x18(%ebp)
  80125d:	39 d6                	cmp    %edx,%esi
  80125f:	72 2b                	jb     80128c <__umoddi3+0x11c>
  801261:	39 c7                	cmp    %eax,%edi
  801263:	72 23                	jb     801288 <__umoddi3+0x118>
  801265:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801269:	29 c7                	sub    %eax,%edi
  80126b:	19 d6                	sbb    %edx,%esi
  80126d:	89 f0                	mov    %esi,%eax
  80126f:	89 f2                	mov    %esi,%edx
  801271:	d3 ef                	shr    %cl,%edi
  801273:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801277:	d3 e0                	shl    %cl,%eax
  801279:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80127d:	09 f8                	or     %edi,%eax
  80127f:	d3 ea                	shr    %cl,%edx
  801281:	83 c4 20             	add    $0x20,%esp
  801284:	5e                   	pop    %esi
  801285:	5f                   	pop    %edi
  801286:	5d                   	pop    %ebp
  801287:	c3                   	ret    
  801288:	39 d6                	cmp    %edx,%esi
  80128a:	75 d9                	jne    801265 <__umoddi3+0xf5>
  80128c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80128f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801292:	eb d1                	jmp    801265 <__umoddi3+0xf5>
  801294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801298:	39 f2                	cmp    %esi,%edx
  80129a:	0f 82 18 ff ff ff    	jb     8011b8 <__umoddi3+0x48>
  8012a0:	e9 1d ff ff ff       	jmp    8011c2 <__umoddi3+0x52>
