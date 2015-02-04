
obj/user/faultallocbad：     文件格式 elf32-i386


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
  80002c:	e8 af 00 00 00       	call   8000e0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
}

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(handler);
  800039:	c7 04 24 5b 00 80 00 	movl   $0x80005b,(%esp)
  800040:	e8 2d 10 00 00       	call   801072 <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  800045:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
  80004c:	00 
  80004d:	c7 04 24 ef be ad de 	movl   $0xdeadbeef,(%esp)
  800054:	e8 b5 0c 00 00       	call   800d0e <sys_cputs>
}
  800059:	c9                   	leave  
  80005a:	c3                   	ret    

0080005b <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  80005b:	55                   	push   %ebp
  80005c:	89 e5                	mov    %esp,%ebp
  80005e:	53                   	push   %ebx
  80005f:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  800062:	8b 45 08             	mov    0x8(%ebp),%eax
  800065:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800067:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80006b:	c7 04 24 20 13 80 00 	movl   $0x801320,(%esp)
  800072:	e8 8d 01 00 00       	call   800204 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  800077:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  80007e:	00 
  80007f:	89 d8                	mov    %ebx,%eax
  800081:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800086:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800091:	e8 b8 0e 00 00       	call   800f4e <sys_page_alloc>
  800096:	85 c0                	test   %eax,%eax
  800098:	79 24                	jns    8000be <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  80009a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80009e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000a2:	c7 44 24 08 40 13 80 	movl   $0x801340,0x8(%esp)
  8000a9:	00 
  8000aa:	c7 44 24 04 0f 00 00 	movl   $0xf,0x4(%esp)
  8000b1:	00 
  8000b2:	c7 04 24 2a 13 80 00 	movl   $0x80132a,(%esp)
  8000b9:	e8 8f 00 00 00       	call   80014d <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000be:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000c2:	c7 44 24 08 6c 13 80 	movl   $0x80136c,0x8(%esp)
  8000c9:	00 
  8000ca:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000d1:	00 
  8000d2:	89 1c 24             	mov    %ebx,(%esp)
  8000d5:	e8 6c 07 00 00       	call   800846 <snprintf>
}
  8000da:	83 c4 24             	add    $0x24,%esp
  8000dd:	5b                   	pop    %ebx
  8000de:	5d                   	pop    %ebp
  8000df:	c3                   	ret    

008000e0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e0:	55                   	push   %ebp
  8000e1:	89 e5                	mov    %esp,%ebp
  8000e3:	83 ec 18             	sub    $0x18,%esp
  8000e6:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000e9:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8000ec:	8b 75 08             	mov    0x8(%ebp),%esi
  8000ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8000f2:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  8000f9:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8000fc:	e8 e0 0e 00 00       	call   800fe1 <sys_getenvid>
  800101:	25 ff 03 00 00       	and    $0x3ff,%eax
  800106:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800109:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010e:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800113:	85 f6                	test   %esi,%esi
  800115:	7e 07                	jle    80011e <libmain+0x3e>
		binaryname = argv[0];
  800117:	8b 03                	mov    (%ebx),%eax
  800119:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80011e:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800122:	89 34 24             	mov    %esi,(%esp)
  800125:	e8 09 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80012a:	e8 0a 00 00 00       	call   800139 <exit>
}
  80012f:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800132:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800135:	89 ec                	mov    %ebp,%esp
  800137:	5d                   	pop    %ebp
  800138:	c3                   	ret    

00800139 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80013f:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800146:	e8 ca 0e 00 00       	call   801015 <sys_env_destroy>
}
  80014b:	c9                   	leave  
  80014c:	c3                   	ret    

0080014d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	56                   	push   %esi
  800151:	53                   	push   %ebx
  800152:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800155:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800158:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80015e:	e8 7e 0e 00 00       	call   800fe1 <sys_getenvid>
  800163:	8b 55 0c             	mov    0xc(%ebp),%edx
  800166:	89 54 24 10          	mov    %edx,0x10(%esp)
  80016a:	8b 55 08             	mov    0x8(%ebp),%edx
  80016d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800171:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800175:	89 44 24 04          	mov    %eax,0x4(%esp)
  800179:	c7 04 24 98 13 80 00 	movl   $0x801398,(%esp)
  800180:	e8 7f 00 00 00       	call   800204 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800185:	89 74 24 04          	mov    %esi,0x4(%esp)
  800189:	8b 45 10             	mov    0x10(%ebp),%eax
  80018c:	89 04 24             	mov    %eax,(%esp)
  80018f:	e8 0f 00 00 00       	call   8001a3 <vcprintf>
	cprintf("\n");
  800194:	c7 04 24 28 13 80 00 	movl   $0x801328,(%esp)
  80019b:	e8 64 00 00 00       	call   800204 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001a0:	cc                   	int3   
  8001a1:	eb fd                	jmp    8001a0 <_panic+0x53>

008001a3 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001ac:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001b3:	00 00 00 
	b.cnt = 0;
  8001b6:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001bd:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001c0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001ce:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d8:	c7 04 24 1e 02 80 00 	movl   $0x80021e,(%esp)
  8001df:	e8 c9 01 00 00       	call   8003ad <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001e4:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ee:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001f4:	89 04 24             	mov    %eax,(%esp)
  8001f7:	e8 12 0b 00 00       	call   800d0e <sys_cputs>

	return b.cnt;
}
  8001fc:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800202:	c9                   	leave  
  800203:	c3                   	ret    

00800204 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800204:	55                   	push   %ebp
  800205:	89 e5                	mov    %esp,%ebp
  800207:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80020a:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80020d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800211:	8b 45 08             	mov    0x8(%ebp),%eax
  800214:	89 04 24             	mov    %eax,(%esp)
  800217:	e8 87 ff ff ff       	call   8001a3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80021c:	c9                   	leave  
  80021d:	c3                   	ret    

0080021e <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80021e:	55                   	push   %ebp
  80021f:	89 e5                	mov    %esp,%ebp
  800221:	53                   	push   %ebx
  800222:	83 ec 14             	sub    $0x14,%esp
  800225:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800228:	8b 03                	mov    (%ebx),%eax
  80022a:	8b 55 08             	mov    0x8(%ebp),%edx
  80022d:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800231:	83 c0 01             	add    $0x1,%eax
  800234:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800236:	3d ff 00 00 00       	cmp    $0xff,%eax
  80023b:	75 19                	jne    800256 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80023d:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800244:	00 
  800245:	8d 43 08             	lea    0x8(%ebx),%eax
  800248:	89 04 24             	mov    %eax,(%esp)
  80024b:	e8 be 0a 00 00       	call   800d0e <sys_cputs>
		b->idx = 0;
  800250:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800256:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80025a:	83 c4 14             	add    $0x14,%esp
  80025d:	5b                   	pop    %ebx
  80025e:	5d                   	pop    %ebp
  80025f:	c3                   	ret    

00800260 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800260:	55                   	push   %ebp
  800261:	89 e5                	mov    %esp,%ebp
  800263:	57                   	push   %edi
  800264:	56                   	push   %esi
  800265:	53                   	push   %ebx
  800266:	83 ec 4c             	sub    $0x4c,%esp
  800269:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80026c:	89 d6                	mov    %edx,%esi
  80026e:	8b 45 08             	mov    0x8(%ebp),%eax
  800271:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800274:	8b 55 0c             	mov    0xc(%ebp),%edx
  800277:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80027a:	8b 45 10             	mov    0x10(%ebp),%eax
  80027d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800280:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800283:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800286:	b9 00 00 00 00       	mov    $0x0,%ecx
  80028b:	39 d1                	cmp    %edx,%ecx
  80028d:	72 15                	jb     8002a4 <printnum+0x44>
  80028f:	77 07                	ja     800298 <printnum+0x38>
  800291:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800294:	39 d0                	cmp    %edx,%eax
  800296:	76 0c                	jbe    8002a4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800298:	83 eb 01             	sub    $0x1,%ebx
  80029b:	85 db                	test   %ebx,%ebx
  80029d:	8d 76 00             	lea    0x0(%esi),%esi
  8002a0:	7f 61                	jg     800303 <printnum+0xa3>
  8002a2:	eb 70                	jmp    800314 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002a4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002a8:	83 eb 01             	sub    $0x1,%ebx
  8002ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002b7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002bb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002be:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8002c1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002c4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002cf:	00 
  8002d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002d3:	89 04 24             	mov    %eax,(%esp)
  8002d6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002dd:	e8 ce 0d 00 00       	call   8010b0 <__udivdi3>
  8002e2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002e5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002ec:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002f0:	89 04 24             	mov    %eax,(%esp)
  8002f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002f7:	89 f2                	mov    %esi,%edx
  8002f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002fc:	e8 5f ff ff ff       	call   800260 <printnum>
  800301:	eb 11                	jmp    800314 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800303:	89 74 24 04          	mov    %esi,0x4(%esp)
  800307:	89 3c 24             	mov    %edi,(%esp)
  80030a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80030d:	83 eb 01             	sub    $0x1,%ebx
  800310:	85 db                	test   %ebx,%ebx
  800312:	7f ef                	jg     800303 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800314:	89 74 24 04          	mov    %esi,0x4(%esp)
  800318:	8b 74 24 04          	mov    0x4(%esp),%esi
  80031c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80031f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800323:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80032a:	00 
  80032b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80032e:	89 14 24             	mov    %edx,(%esp)
  800331:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800334:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800338:	e8 a3 0e 00 00       	call   8011e0 <__umoddi3>
  80033d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800341:	0f be 80 bb 13 80 00 	movsbl 0x8013bb(%eax),%eax
  800348:	89 04 24             	mov    %eax,(%esp)
  80034b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80034e:	83 c4 4c             	add    $0x4c,%esp
  800351:	5b                   	pop    %ebx
  800352:	5e                   	pop    %esi
  800353:	5f                   	pop    %edi
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800359:	83 fa 01             	cmp    $0x1,%edx
  80035c:	7e 0e                	jle    80036c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80035e:	8b 10                	mov    (%eax),%edx
  800360:	8d 4a 08             	lea    0x8(%edx),%ecx
  800363:	89 08                	mov    %ecx,(%eax)
  800365:	8b 02                	mov    (%edx),%eax
  800367:	8b 52 04             	mov    0x4(%edx),%edx
  80036a:	eb 22                	jmp    80038e <getuint+0x38>
	else if (lflag)
  80036c:	85 d2                	test   %edx,%edx
  80036e:	74 10                	je     800380 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800370:	8b 10                	mov    (%eax),%edx
  800372:	8d 4a 04             	lea    0x4(%edx),%ecx
  800375:	89 08                	mov    %ecx,(%eax)
  800377:	8b 02                	mov    (%edx),%eax
  800379:	ba 00 00 00 00       	mov    $0x0,%edx
  80037e:	eb 0e                	jmp    80038e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800380:	8b 10                	mov    (%eax),%edx
  800382:	8d 4a 04             	lea    0x4(%edx),%ecx
  800385:	89 08                	mov    %ecx,(%eax)
  800387:	8b 02                	mov    (%edx),%eax
  800389:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80038e:	5d                   	pop    %ebp
  80038f:	c3                   	ret    

00800390 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800396:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80039a:	8b 10                	mov    (%eax),%edx
  80039c:	3b 50 04             	cmp    0x4(%eax),%edx
  80039f:	73 0a                	jae    8003ab <sprintputch+0x1b>
		*b->buf++ = ch;
  8003a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a4:	88 0a                	mov    %cl,(%edx)
  8003a6:	83 c2 01             	add    $0x1,%edx
  8003a9:	89 10                	mov    %edx,(%eax)
}
  8003ab:	5d                   	pop    %ebp
  8003ac:	c3                   	ret    

008003ad <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ad:	55                   	push   %ebp
  8003ae:	89 e5                	mov    %esp,%ebp
  8003b0:	57                   	push   %edi
  8003b1:	56                   	push   %esi
  8003b2:	53                   	push   %ebx
  8003b3:	83 ec 5c             	sub    $0x5c,%esp
  8003b6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003bf:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003c6:	eb 11                	jmp    8003d9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003c8:	85 c0                	test   %eax,%eax
  8003ca:	0f 84 16 04 00 00    	je     8007e6 <vprintfmt+0x439>
				return;
			putch(ch, putdat);
  8003d0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d4:	89 04 24             	mov    %eax,(%esp)
  8003d7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003d9:	0f b6 03             	movzbl (%ebx),%eax
  8003dc:	83 c3 01             	add    $0x1,%ebx
  8003df:	83 f8 25             	cmp    $0x25,%eax
  8003e2:	75 e4                	jne    8003c8 <vprintfmt+0x1b>
  8003e4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003eb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f7:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003fb:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800402:	eb 06                	jmp    80040a <vprintfmt+0x5d>
  800404:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800408:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80040a:	0f b6 13             	movzbl (%ebx),%edx
  80040d:	0f b6 c2             	movzbl %dl,%eax
  800410:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800413:	8d 43 01             	lea    0x1(%ebx),%eax
  800416:	83 ea 23             	sub    $0x23,%edx
  800419:	80 fa 55             	cmp    $0x55,%dl
  80041c:	0f 87 a7 03 00 00    	ja     8007c9 <vprintfmt+0x41c>
  800422:	0f b6 d2             	movzbl %dl,%edx
  800425:	ff 24 95 80 14 80 00 	jmp    *0x801480(,%edx,4)
  80042c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800430:	eb d6                	jmp    800408 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800432:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800435:	83 ea 30             	sub    $0x30,%edx
  800438:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80043b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80043e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800441:	83 fb 09             	cmp    $0x9,%ebx
  800444:	77 54                	ja     80049a <vprintfmt+0xed>
  800446:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800449:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80044c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80044f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800452:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800456:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800459:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80045c:	83 fb 09             	cmp    $0x9,%ebx
  80045f:	76 eb                	jbe    80044c <vprintfmt+0x9f>
  800461:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800464:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800467:	eb 31                	jmp    80049a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800469:	8b 55 14             	mov    0x14(%ebp),%edx
  80046c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80046f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800472:	8b 12                	mov    (%edx),%edx
  800474:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800477:	eb 21                	jmp    80049a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800479:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80047d:	ba 00 00 00 00       	mov    $0x0,%edx
  800482:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  800486:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800489:	e9 7a ff ff ff       	jmp    800408 <vprintfmt+0x5b>
  80048e:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800495:	e9 6e ff ff ff       	jmp    800408 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80049a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80049e:	0f 89 64 ff ff ff    	jns    800408 <vprintfmt+0x5b>
  8004a4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8004a7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004aa:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8004ad:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8004b0:	e9 53 ff ff ff       	jmp    800408 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004b5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8004b8:	e9 4b ff ff ff       	jmp    800408 <vprintfmt+0x5b>
  8004bd:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c3:	8d 50 04             	lea    0x4(%eax),%edx
  8004c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004cd:	8b 00                	mov    (%eax),%eax
  8004cf:	89 04 24             	mov    %eax,(%esp)
  8004d2:	ff d7                	call   *%edi
  8004d4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8004d7:	e9 fd fe ff ff       	jmp    8003d9 <vprintfmt+0x2c>
  8004dc:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004df:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e2:	8d 50 04             	lea    0x4(%eax),%edx
  8004e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e8:	8b 00                	mov    (%eax),%eax
  8004ea:	89 c2                	mov    %eax,%edx
  8004ec:	c1 fa 1f             	sar    $0x1f,%edx
  8004ef:	31 d0                	xor    %edx,%eax
  8004f1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004f3:	83 f8 08             	cmp    $0x8,%eax
  8004f6:	7f 0b                	jg     800503 <vprintfmt+0x156>
  8004f8:	8b 14 85 e0 15 80 00 	mov    0x8015e0(,%eax,4),%edx
  8004ff:	85 d2                	test   %edx,%edx
  800501:	75 20                	jne    800523 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800503:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800507:	c7 44 24 08 cc 13 80 	movl   $0x8013cc,0x8(%esp)
  80050e:	00 
  80050f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800513:	89 3c 24             	mov    %edi,(%esp)
  800516:	e8 53 03 00 00       	call   80086e <printfmt>
  80051b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80051e:	e9 b6 fe ff ff       	jmp    8003d9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800523:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800527:	c7 44 24 08 d5 13 80 	movl   $0x8013d5,0x8(%esp)
  80052e:	00 
  80052f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800533:	89 3c 24             	mov    %edi,(%esp)
  800536:	e8 33 03 00 00       	call   80086e <printfmt>
  80053b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80053e:	e9 96 fe ff ff       	jmp    8003d9 <vprintfmt+0x2c>
  800543:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800546:	89 c3                	mov    %eax,%ebx
  800548:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80054b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80054e:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800551:	8b 45 14             	mov    0x14(%ebp),%eax
  800554:	8d 50 04             	lea    0x4(%eax),%edx
  800557:	89 55 14             	mov    %edx,0x14(%ebp)
  80055a:	8b 00                	mov    (%eax),%eax
  80055c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80055f:	85 c0                	test   %eax,%eax
  800561:	b8 d8 13 80 00       	mov    $0x8013d8,%eax
  800566:	0f 45 45 c4          	cmovne -0x3c(%ebp),%eax
  80056a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80056d:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800571:	7e 06                	jle    800579 <vprintfmt+0x1cc>
  800573:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800577:	75 13                	jne    80058c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800579:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80057c:	0f be 02             	movsbl (%edx),%eax
  80057f:	85 c0                	test   %eax,%eax
  800581:	0f 85 9b 00 00 00    	jne    800622 <vprintfmt+0x275>
  800587:	e9 88 00 00 00       	jmp    800614 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800590:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  800593:	89 0c 24             	mov    %ecx,(%esp)
  800596:	e8 20 03 00 00       	call   8008bb <strnlen>
  80059b:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80059e:	29 c2                	sub    %eax,%edx
  8005a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005a3:	85 d2                	test   %edx,%edx
  8005a5:	7e d2                	jle    800579 <vprintfmt+0x1cc>
					putch(padc, putdat);
  8005a7:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  8005ab:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ae:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8005b1:	89 d3                	mov    %edx,%ebx
  8005b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005ba:	89 04 24             	mov    %eax,(%esp)
  8005bd:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005bf:	83 eb 01             	sub    $0x1,%ebx
  8005c2:	85 db                	test   %ebx,%ebx
  8005c4:	7f ed                	jg     8005b3 <vprintfmt+0x206>
  8005c6:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8005c9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005d0:	eb a7                	jmp    800579 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005d2:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005d6:	74 1a                	je     8005f2 <vprintfmt+0x245>
  8005d8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005db:	83 fa 5e             	cmp    $0x5e,%edx
  8005de:	76 12                	jbe    8005f2 <vprintfmt+0x245>
					putch('?', putdat);
  8005e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005e4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005eb:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005ee:	66 90                	xchg   %ax,%ax
  8005f0:	eb 0a                	jmp    8005fc <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005f6:	89 04 24             	mov    %eax,(%esp)
  8005f9:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005fc:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800600:	0f be 03             	movsbl (%ebx),%eax
  800603:	85 c0                	test   %eax,%eax
  800605:	74 05                	je     80060c <vprintfmt+0x25f>
  800607:	83 c3 01             	add    $0x1,%ebx
  80060a:	eb 29                	jmp    800635 <vprintfmt+0x288>
  80060c:	89 fe                	mov    %edi,%esi
  80060e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800611:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800614:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800618:	7f 2e                	jg     800648 <vprintfmt+0x29b>
  80061a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80061d:	e9 b7 fd ff ff       	jmp    8003d9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800622:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800625:	83 c2 01             	add    $0x1,%edx
  800628:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80062b:	89 f7                	mov    %esi,%edi
  80062d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800630:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800633:	89 d3                	mov    %edx,%ebx
  800635:	85 f6                	test   %esi,%esi
  800637:	78 99                	js     8005d2 <vprintfmt+0x225>
  800639:	83 ee 01             	sub    $0x1,%esi
  80063c:	79 94                	jns    8005d2 <vprintfmt+0x225>
  80063e:	89 fe                	mov    %edi,%esi
  800640:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800643:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800646:	eb cc                	jmp    800614 <vprintfmt+0x267>
  800648:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80064b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80064e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800652:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800659:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80065b:	83 eb 01             	sub    $0x1,%ebx
  80065e:	85 db                	test   %ebx,%ebx
  800660:	7f ec                	jg     80064e <vprintfmt+0x2a1>
  800662:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800665:	e9 6f fd ff ff       	jmp    8003d9 <vprintfmt+0x2c>
  80066a:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80066d:	83 f9 01             	cmp    $0x1,%ecx
  800670:	7e 16                	jle    800688 <vprintfmt+0x2db>
		return va_arg(*ap, long long);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8d 50 08             	lea    0x8(%eax),%edx
  800678:	89 55 14             	mov    %edx,0x14(%ebp)
  80067b:	8b 10                	mov    (%eax),%edx
  80067d:	8b 48 04             	mov    0x4(%eax),%ecx
  800680:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800683:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800686:	eb 32                	jmp    8006ba <vprintfmt+0x30d>
	else if (lflag)
  800688:	85 c9                	test   %ecx,%ecx
  80068a:	74 18                	je     8006a4 <vprintfmt+0x2f7>
		return va_arg(*ap, long);
  80068c:	8b 45 14             	mov    0x14(%ebp),%eax
  80068f:	8d 50 04             	lea    0x4(%eax),%edx
  800692:	89 55 14             	mov    %edx,0x14(%ebp)
  800695:	8b 00                	mov    (%eax),%eax
  800697:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80069a:	89 c1                	mov    %eax,%ecx
  80069c:	c1 f9 1f             	sar    $0x1f,%ecx
  80069f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006a2:	eb 16                	jmp    8006ba <vprintfmt+0x30d>
	else
		return va_arg(*ap, int);
  8006a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006a7:	8d 50 04             	lea    0x4(%eax),%edx
  8006aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ad:	8b 00                	mov    (%eax),%eax
  8006af:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006b2:	89 c2                	mov    %eax,%edx
  8006b4:	c1 fa 1f             	sar    $0x1f,%edx
  8006b7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006ba:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006bd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006c0:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8006c5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006c9:	0f 89 b8 00 00 00    	jns    800787 <vprintfmt+0x3da>
				putch('-', putdat);
  8006cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006da:	ff d7                	call   *%edi
				num = -(long long) num;
  8006dc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006df:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006e2:	f7 d9                	neg    %ecx
  8006e4:	83 d3 00             	adc    $0x0,%ebx
  8006e7:	f7 db                	neg    %ebx
  8006e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006ee:	e9 94 00 00 00       	jmp    800787 <vprintfmt+0x3da>
  8006f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006f6:	89 ca                	mov    %ecx,%edx
  8006f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006fb:	e8 56 fc ff ff       	call   800356 <getuint>
  800700:	89 c1                	mov    %eax,%ecx
  800702:	89 d3                	mov    %edx,%ebx
  800704:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800709:	eb 7c                	jmp    800787 <vprintfmt+0x3da>
  80070b:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80070e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800712:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800719:	ff d7                	call   *%edi
			putch('X', putdat);
  80071b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80071f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800726:	ff d7                	call   *%edi
			putch('X', putdat);
  800728:	89 74 24 04          	mov    %esi,0x4(%esp)
  80072c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800733:	ff d7                	call   *%edi
  800735:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800738:	e9 9c fc ff ff       	jmp    8003d9 <vprintfmt+0x2c>
  80073d:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800740:	89 74 24 04          	mov    %esi,0x4(%esp)
  800744:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80074b:	ff d7                	call   *%edi
			putch('x', putdat);
  80074d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800751:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800758:	ff d7                	call   *%edi
			num = (unsigned long long)
  80075a:	8b 45 14             	mov    0x14(%ebp),%eax
  80075d:	8d 50 04             	lea    0x4(%eax),%edx
  800760:	89 55 14             	mov    %edx,0x14(%ebp)
  800763:	8b 08                	mov    (%eax),%ecx
  800765:	bb 00 00 00 00       	mov    $0x0,%ebx
  80076a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80076f:	eb 16                	jmp    800787 <vprintfmt+0x3da>
  800771:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800774:	89 ca                	mov    %ecx,%edx
  800776:	8d 45 14             	lea    0x14(%ebp),%eax
  800779:	e8 d8 fb ff ff       	call   800356 <getuint>
  80077e:	89 c1                	mov    %eax,%ecx
  800780:	89 d3                	mov    %edx,%ebx
  800782:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800787:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80078b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80078f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800792:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800796:	89 44 24 08          	mov    %eax,0x8(%esp)
  80079a:	89 0c 24             	mov    %ecx,(%esp)
  80079d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007a1:	89 f2                	mov    %esi,%edx
  8007a3:	89 f8                	mov    %edi,%eax
  8007a5:	e8 b6 fa ff ff       	call   800260 <printnum>
  8007aa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8007ad:	e9 27 fc ff ff       	jmp    8003d9 <vprintfmt+0x2c>
  8007b2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007b5:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007b8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007bc:	89 14 24             	mov    %edx,(%esp)
  8007bf:	ff d7                	call   *%edi
  8007c1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8007c4:	e9 10 fc ff ff       	jmp    8003d9 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007cd:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007d4:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007d6:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8007d9:	80 38 25             	cmpb   $0x25,(%eax)
  8007dc:	0f 84 f7 fb ff ff    	je     8003d9 <vprintfmt+0x2c>
  8007e2:	89 c3                	mov    %eax,%ebx
  8007e4:	eb f0                	jmp    8007d6 <vprintfmt+0x429>
				/* do nothing */;
			break;
		}
	}
}
  8007e6:	83 c4 5c             	add    $0x5c,%esp
  8007e9:	5b                   	pop    %ebx
  8007ea:	5e                   	pop    %esi
  8007eb:	5f                   	pop    %edi
  8007ec:	5d                   	pop    %ebp
  8007ed:	c3                   	ret    

008007ee <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007ee:	55                   	push   %ebp
  8007ef:	89 e5                	mov    %esp,%ebp
  8007f1:	83 ec 28             	sub    $0x28,%esp
  8007f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007f7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8007fa:	85 c0                	test   %eax,%eax
  8007fc:	74 04                	je     800802 <vsnprintf+0x14>
  8007fe:	85 d2                	test   %edx,%edx
  800800:	7f 07                	jg     800809 <vsnprintf+0x1b>
  800802:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800807:	eb 3b                	jmp    800844 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800809:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80080c:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800810:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800813:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80081a:	8b 45 14             	mov    0x14(%ebp),%eax
  80081d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800821:	8b 45 10             	mov    0x10(%ebp),%eax
  800824:	89 44 24 08          	mov    %eax,0x8(%esp)
  800828:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80082b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80082f:	c7 04 24 90 03 80 00 	movl   $0x800390,(%esp)
  800836:	e8 72 fb ff ff       	call   8003ad <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80083b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80083e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800841:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800844:	c9                   	leave  
  800845:	c3                   	ret    

00800846 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80084c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80084f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800853:	8b 45 10             	mov    0x10(%ebp),%eax
  800856:	89 44 24 08          	mov    %eax,0x8(%esp)
  80085a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800861:	8b 45 08             	mov    0x8(%ebp),%eax
  800864:	89 04 24             	mov    %eax,(%esp)
  800867:	e8 82 ff ff ff       	call   8007ee <vsnprintf>
	va_end(ap);

	return rc;
}
  80086c:	c9                   	leave  
  80086d:	c3                   	ret    

0080086e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80086e:	55                   	push   %ebp
  80086f:	89 e5                	mov    %esp,%ebp
  800871:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800874:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800877:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80087b:	8b 45 10             	mov    0x10(%ebp),%eax
  80087e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800882:	8b 45 0c             	mov    0xc(%ebp),%eax
  800885:	89 44 24 04          	mov    %eax,0x4(%esp)
  800889:	8b 45 08             	mov    0x8(%ebp),%eax
  80088c:	89 04 24             	mov    %eax,(%esp)
  80088f:	e8 19 fb ff ff       	call   8003ad <vprintfmt>
	va_end(ap);
}
  800894:	c9                   	leave  
  800895:	c3                   	ret    
  800896:	66 90                	xchg   %ax,%ax
  800898:	66 90                	xchg   %ax,%ax
  80089a:	66 90                	xchg   %ax,%ax
  80089c:	66 90                	xchg   %ax,%ax
  80089e:	66 90                	xchg   %ax,%ax

008008a0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008a0:	55                   	push   %ebp
  8008a1:	89 e5                	mov    %esp,%ebp
  8008a3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008ab:	80 3a 00             	cmpb   $0x0,(%edx)
  8008ae:	74 09                	je     8008b9 <strlen+0x19>
		n++;
  8008b0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008b3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008b7:	75 f7                	jne    8008b0 <strlen+0x10>
		n++;
	return n;
}
  8008b9:	5d                   	pop    %ebp
  8008ba:	c3                   	ret    

008008bb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008bb:	55                   	push   %ebp
  8008bc:	89 e5                	mov    %esp,%ebp
  8008be:	53                   	push   %ebx
  8008bf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008c2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008c5:	85 c9                	test   %ecx,%ecx
  8008c7:	74 19                	je     8008e2 <strnlen+0x27>
  8008c9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008cc:	74 14                	je     8008e2 <strnlen+0x27>
  8008ce:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008d3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008d6:	39 c8                	cmp    %ecx,%eax
  8008d8:	74 0d                	je     8008e7 <strnlen+0x2c>
  8008da:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8008de:	75 f3                	jne    8008d3 <strnlen+0x18>
  8008e0:	eb 05                	jmp    8008e7 <strnlen+0x2c>
  8008e2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008e7:	5b                   	pop    %ebx
  8008e8:	5d                   	pop    %ebp
  8008e9:	c3                   	ret    

008008ea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	53                   	push   %ebx
  8008ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008f4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008f9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008fd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800900:	83 c2 01             	add    $0x1,%edx
  800903:	84 c9                	test   %cl,%cl
  800905:	75 f2                	jne    8008f9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800907:	5b                   	pop    %ebx
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	53                   	push   %ebx
  80090e:	83 ec 08             	sub    $0x8,%esp
  800911:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800914:	89 1c 24             	mov    %ebx,(%esp)
  800917:	e8 84 ff ff ff       	call   8008a0 <strlen>
	strcpy(dst + len, src);
  80091c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800923:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800926:	89 04 24             	mov    %eax,(%esp)
  800929:	e8 bc ff ff ff       	call   8008ea <strcpy>
	return dst;
}
  80092e:	89 d8                	mov    %ebx,%eax
  800930:	83 c4 08             	add    $0x8,%esp
  800933:	5b                   	pop    %ebx
  800934:	5d                   	pop    %ebp
  800935:	c3                   	ret    

00800936 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	56                   	push   %esi
  80093a:	53                   	push   %ebx
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800941:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800944:	85 f6                	test   %esi,%esi
  800946:	74 18                	je     800960 <strncpy+0x2a>
  800948:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80094d:	0f b6 1a             	movzbl (%edx),%ebx
  800950:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800953:	80 3a 01             	cmpb   $0x1,(%edx)
  800956:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800959:	83 c1 01             	add    $0x1,%ecx
  80095c:	39 ce                	cmp    %ecx,%esi
  80095e:	77 ed                	ja     80094d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800960:	5b                   	pop    %ebx
  800961:	5e                   	pop    %esi
  800962:	5d                   	pop    %ebp
  800963:	c3                   	ret    

00800964 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800964:	55                   	push   %ebp
  800965:	89 e5                	mov    %esp,%ebp
  800967:	56                   	push   %esi
  800968:	53                   	push   %ebx
  800969:	8b 75 08             	mov    0x8(%ebp),%esi
  80096c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800972:	89 f0                	mov    %esi,%eax
  800974:	85 c9                	test   %ecx,%ecx
  800976:	74 27                	je     80099f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800978:	83 e9 01             	sub    $0x1,%ecx
  80097b:	74 1d                	je     80099a <strlcpy+0x36>
  80097d:	0f b6 1a             	movzbl (%edx),%ebx
  800980:	84 db                	test   %bl,%bl
  800982:	74 16                	je     80099a <strlcpy+0x36>
			*dst++ = *src++;
  800984:	88 18                	mov    %bl,(%eax)
  800986:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800989:	83 e9 01             	sub    $0x1,%ecx
  80098c:	74 0e                	je     80099c <strlcpy+0x38>
			*dst++ = *src++;
  80098e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800991:	0f b6 1a             	movzbl (%edx),%ebx
  800994:	84 db                	test   %bl,%bl
  800996:	75 ec                	jne    800984 <strlcpy+0x20>
  800998:	eb 02                	jmp    80099c <strlcpy+0x38>
  80099a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80099c:	c6 00 00             	movb   $0x0,(%eax)
  80099f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009a1:	5b                   	pop    %ebx
  8009a2:	5e                   	pop    %esi
  8009a3:	5d                   	pop    %ebp
  8009a4:	c3                   	ret    

008009a5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009a5:	55                   	push   %ebp
  8009a6:	89 e5                	mov    %esp,%ebp
  8009a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ae:	0f b6 01             	movzbl (%ecx),%eax
  8009b1:	84 c0                	test   %al,%al
  8009b3:	74 15                	je     8009ca <strcmp+0x25>
  8009b5:	3a 02                	cmp    (%edx),%al
  8009b7:	75 11                	jne    8009ca <strcmp+0x25>
		p++, q++;
  8009b9:	83 c1 01             	add    $0x1,%ecx
  8009bc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009bf:	0f b6 01             	movzbl (%ecx),%eax
  8009c2:	84 c0                	test   %al,%al
  8009c4:	74 04                	je     8009ca <strcmp+0x25>
  8009c6:	3a 02                	cmp    (%edx),%al
  8009c8:	74 ef                	je     8009b9 <strcmp+0x14>
  8009ca:	0f b6 c0             	movzbl %al,%eax
  8009cd:	0f b6 12             	movzbl (%edx),%edx
  8009d0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	53                   	push   %ebx
  8009d8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009de:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8009e1:	85 c0                	test   %eax,%eax
  8009e3:	74 23                	je     800a08 <strncmp+0x34>
  8009e5:	0f b6 1a             	movzbl (%edx),%ebx
  8009e8:	84 db                	test   %bl,%bl
  8009ea:	74 25                	je     800a11 <strncmp+0x3d>
  8009ec:	3a 19                	cmp    (%ecx),%bl
  8009ee:	75 21                	jne    800a11 <strncmp+0x3d>
  8009f0:	83 e8 01             	sub    $0x1,%eax
  8009f3:	74 13                	je     800a08 <strncmp+0x34>
		n--, p++, q++;
  8009f5:	83 c2 01             	add    $0x1,%edx
  8009f8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009fb:	0f b6 1a             	movzbl (%edx),%ebx
  8009fe:	84 db                	test   %bl,%bl
  800a00:	74 0f                	je     800a11 <strncmp+0x3d>
  800a02:	3a 19                	cmp    (%ecx),%bl
  800a04:	74 ea                	je     8009f0 <strncmp+0x1c>
  800a06:	eb 09                	jmp    800a11 <strncmp+0x3d>
  800a08:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a0d:	5b                   	pop    %ebx
  800a0e:	5d                   	pop    %ebp
  800a0f:	90                   	nop
  800a10:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a11:	0f b6 02             	movzbl (%edx),%eax
  800a14:	0f b6 11             	movzbl (%ecx),%edx
  800a17:	29 d0                	sub    %edx,%eax
  800a19:	eb f2                	jmp    800a0d <strncmp+0x39>

00800a1b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a25:	0f b6 10             	movzbl (%eax),%edx
  800a28:	84 d2                	test   %dl,%dl
  800a2a:	74 18                	je     800a44 <strchr+0x29>
		if (*s == c)
  800a2c:	38 ca                	cmp    %cl,%dl
  800a2e:	75 0a                	jne    800a3a <strchr+0x1f>
  800a30:	eb 17                	jmp    800a49 <strchr+0x2e>
  800a32:	38 ca                	cmp    %cl,%dl
  800a34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a38:	74 0f                	je     800a49 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a3a:	83 c0 01             	add    $0x1,%eax
  800a3d:	0f b6 10             	movzbl (%eax),%edx
  800a40:	84 d2                	test   %dl,%dl
  800a42:	75 ee                	jne    800a32 <strchr+0x17>
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a49:	5d                   	pop    %ebp
  800a4a:	c3                   	ret    

00800a4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a4b:	55                   	push   %ebp
  800a4c:	89 e5                	mov    %esp,%ebp
  800a4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a55:	0f b6 10             	movzbl (%eax),%edx
  800a58:	84 d2                	test   %dl,%dl
  800a5a:	74 18                	je     800a74 <strfind+0x29>
		if (*s == c)
  800a5c:	38 ca                	cmp    %cl,%dl
  800a5e:	75 0a                	jne    800a6a <strfind+0x1f>
  800a60:	eb 12                	jmp    800a74 <strfind+0x29>
  800a62:	38 ca                	cmp    %cl,%dl
  800a64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a68:	74 0a                	je     800a74 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a6a:	83 c0 01             	add    $0x1,%eax
  800a6d:	0f b6 10             	movzbl (%eax),%edx
  800a70:	84 d2                	test   %dl,%dl
  800a72:	75 ee                	jne    800a62 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a74:	5d                   	pop    %ebp
  800a75:	c3                   	ret    

00800a76 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a76:	55                   	push   %ebp
  800a77:	89 e5                	mov    %esp,%ebp
  800a79:	83 ec 0c             	sub    $0xc,%esp
  800a7c:	89 1c 24             	mov    %ebx,(%esp)
  800a7f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a83:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a87:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a8d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a90:	85 c9                	test   %ecx,%ecx
  800a92:	74 30                	je     800ac4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a94:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a9a:	75 25                	jne    800ac1 <memset+0x4b>
  800a9c:	f6 c1 03             	test   $0x3,%cl
  800a9f:	75 20                	jne    800ac1 <memset+0x4b>
		c &= 0xFF;
  800aa1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800aa4:	89 d3                	mov    %edx,%ebx
  800aa6:	c1 e3 08             	shl    $0x8,%ebx
  800aa9:	89 d6                	mov    %edx,%esi
  800aab:	c1 e6 18             	shl    $0x18,%esi
  800aae:	89 d0                	mov    %edx,%eax
  800ab0:	c1 e0 10             	shl    $0x10,%eax
  800ab3:	09 f0                	or     %esi,%eax
  800ab5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800ab7:	09 d8                	or     %ebx,%eax
  800ab9:	c1 e9 02             	shr    $0x2,%ecx
  800abc:	fc                   	cld    
  800abd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800abf:	eb 03                	jmp    800ac4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ac1:	fc                   	cld    
  800ac2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ac4:	89 f8                	mov    %edi,%eax
  800ac6:	8b 1c 24             	mov    (%esp),%ebx
  800ac9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800acd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ad1:	89 ec                	mov    %ebp,%esp
  800ad3:	5d                   	pop    %ebp
  800ad4:	c3                   	ret    

00800ad5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ad5:	55                   	push   %ebp
  800ad6:	89 e5                	mov    %esp,%ebp
  800ad8:	83 ec 08             	sub    $0x8,%esp
  800adb:	89 34 24             	mov    %esi,(%esp)
  800ade:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ae2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800ae8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800aeb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800aed:	39 c6                	cmp    %eax,%esi
  800aef:	73 35                	jae    800b26 <memmove+0x51>
  800af1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800af4:	39 d0                	cmp    %edx,%eax
  800af6:	73 2e                	jae    800b26 <memmove+0x51>
		s += n;
		d += n;
  800af8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800afa:	f6 c2 03             	test   $0x3,%dl
  800afd:	75 1b                	jne    800b1a <memmove+0x45>
  800aff:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b05:	75 13                	jne    800b1a <memmove+0x45>
  800b07:	f6 c1 03             	test   $0x3,%cl
  800b0a:	75 0e                	jne    800b1a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800b0c:	83 ef 04             	sub    $0x4,%edi
  800b0f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b12:	c1 e9 02             	shr    $0x2,%ecx
  800b15:	fd                   	std    
  800b16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b18:	eb 09                	jmp    800b23 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b1a:	83 ef 01             	sub    $0x1,%edi
  800b1d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b20:	fd                   	std    
  800b21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b23:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b24:	eb 20                	jmp    800b46 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b26:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b2c:	75 15                	jne    800b43 <memmove+0x6e>
  800b2e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b34:	75 0d                	jne    800b43 <memmove+0x6e>
  800b36:	f6 c1 03             	test   $0x3,%cl
  800b39:	75 08                	jne    800b43 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800b3b:	c1 e9 02             	shr    $0x2,%ecx
  800b3e:	fc                   	cld    
  800b3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b41:	eb 03                	jmp    800b46 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b43:	fc                   	cld    
  800b44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b46:	8b 34 24             	mov    (%esp),%esi
  800b49:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b4d:	89 ec                	mov    %ebp,%esp
  800b4f:	5d                   	pop    %ebp
  800b50:	c3                   	ret    

00800b51 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b57:	8b 45 10             	mov    0x10(%ebp),%eax
  800b5a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b61:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b65:	8b 45 08             	mov    0x8(%ebp),%eax
  800b68:	89 04 24             	mov    %eax,(%esp)
  800b6b:	e8 65 ff ff ff       	call   800ad5 <memmove>
}
  800b70:	c9                   	leave  
  800b71:	c3                   	ret    

00800b72 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b72:	55                   	push   %ebp
  800b73:	89 e5                	mov    %esp,%ebp
  800b75:	57                   	push   %edi
  800b76:	56                   	push   %esi
  800b77:	53                   	push   %ebx
  800b78:	8b 75 08             	mov    0x8(%ebp),%esi
  800b7b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b81:	85 c9                	test   %ecx,%ecx
  800b83:	74 36                	je     800bbb <memcmp+0x49>
		if (*s1 != *s2)
  800b85:	0f b6 06             	movzbl (%esi),%eax
  800b88:	0f b6 1f             	movzbl (%edi),%ebx
  800b8b:	38 d8                	cmp    %bl,%al
  800b8d:	74 20                	je     800baf <memcmp+0x3d>
  800b8f:	eb 14                	jmp    800ba5 <memcmp+0x33>
  800b91:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b96:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b9b:	83 c2 01             	add    $0x1,%edx
  800b9e:	83 e9 01             	sub    $0x1,%ecx
  800ba1:	38 d8                	cmp    %bl,%al
  800ba3:	74 12                	je     800bb7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800ba5:	0f b6 c0             	movzbl %al,%eax
  800ba8:	0f b6 db             	movzbl %bl,%ebx
  800bab:	29 d8                	sub    %ebx,%eax
  800bad:	eb 11                	jmp    800bc0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800baf:	83 e9 01             	sub    $0x1,%ecx
  800bb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb7:	85 c9                	test   %ecx,%ecx
  800bb9:	75 d6                	jne    800b91 <memcmp+0x1f>
  800bbb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5f                   	pop    %edi
  800bc3:	5d                   	pop    %ebp
  800bc4:	c3                   	ret    

00800bc5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bcb:	89 c2                	mov    %eax,%edx
  800bcd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bd0:	39 d0                	cmp    %edx,%eax
  800bd2:	73 15                	jae    800be9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bd4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800bd8:	38 08                	cmp    %cl,(%eax)
  800bda:	75 06                	jne    800be2 <memfind+0x1d>
  800bdc:	eb 0b                	jmp    800be9 <memfind+0x24>
  800bde:	38 08                	cmp    %cl,(%eax)
  800be0:	74 07                	je     800be9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800be2:	83 c0 01             	add    $0x1,%eax
  800be5:	39 c2                	cmp    %eax,%edx
  800be7:	77 f5                	ja     800bde <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	83 ec 04             	sub    $0x4,%esp
  800bf4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bfa:	0f b6 02             	movzbl (%edx),%eax
  800bfd:	3c 20                	cmp    $0x20,%al
  800bff:	74 04                	je     800c05 <strtol+0x1a>
  800c01:	3c 09                	cmp    $0x9,%al
  800c03:	75 0e                	jne    800c13 <strtol+0x28>
		s++;
  800c05:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c08:	0f b6 02             	movzbl (%edx),%eax
  800c0b:	3c 20                	cmp    $0x20,%al
  800c0d:	74 f6                	je     800c05 <strtol+0x1a>
  800c0f:	3c 09                	cmp    $0x9,%al
  800c11:	74 f2                	je     800c05 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c13:	3c 2b                	cmp    $0x2b,%al
  800c15:	75 0c                	jne    800c23 <strtol+0x38>
		s++;
  800c17:	83 c2 01             	add    $0x1,%edx
  800c1a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c21:	eb 15                	jmp    800c38 <strtol+0x4d>
	else if (*s == '-')
  800c23:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c2a:	3c 2d                	cmp    $0x2d,%al
  800c2c:	75 0a                	jne    800c38 <strtol+0x4d>
		s++, neg = 1;
  800c2e:	83 c2 01             	add    $0x1,%edx
  800c31:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c38:	85 db                	test   %ebx,%ebx
  800c3a:	0f 94 c0             	sete   %al
  800c3d:	74 05                	je     800c44 <strtol+0x59>
  800c3f:	83 fb 10             	cmp    $0x10,%ebx
  800c42:	75 18                	jne    800c5c <strtol+0x71>
  800c44:	80 3a 30             	cmpb   $0x30,(%edx)
  800c47:	75 13                	jne    800c5c <strtol+0x71>
  800c49:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c4d:	8d 76 00             	lea    0x0(%esi),%esi
  800c50:	75 0a                	jne    800c5c <strtol+0x71>
		s += 2, base = 16;
  800c52:	83 c2 02             	add    $0x2,%edx
  800c55:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c5a:	eb 15                	jmp    800c71 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c5c:	84 c0                	test   %al,%al
  800c5e:	66 90                	xchg   %ax,%ax
  800c60:	74 0f                	je     800c71 <strtol+0x86>
  800c62:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c67:	80 3a 30             	cmpb   $0x30,(%edx)
  800c6a:	75 05                	jne    800c71 <strtol+0x86>
		s++, base = 8;
  800c6c:	83 c2 01             	add    $0x1,%edx
  800c6f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c71:	b8 00 00 00 00       	mov    $0x0,%eax
  800c76:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c78:	0f b6 0a             	movzbl (%edx),%ecx
  800c7b:	89 cf                	mov    %ecx,%edi
  800c7d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c80:	80 fb 09             	cmp    $0x9,%bl
  800c83:	77 08                	ja     800c8d <strtol+0xa2>
			dig = *s - '0';
  800c85:	0f be c9             	movsbl %cl,%ecx
  800c88:	83 e9 30             	sub    $0x30,%ecx
  800c8b:	eb 1e                	jmp    800cab <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800c8d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c90:	80 fb 19             	cmp    $0x19,%bl
  800c93:	77 08                	ja     800c9d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c95:	0f be c9             	movsbl %cl,%ecx
  800c98:	83 e9 57             	sub    $0x57,%ecx
  800c9b:	eb 0e                	jmp    800cab <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c9d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800ca0:	80 fb 19             	cmp    $0x19,%bl
  800ca3:	77 15                	ja     800cba <strtol+0xcf>
			dig = *s - 'A' + 10;
  800ca5:	0f be c9             	movsbl %cl,%ecx
  800ca8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cab:	39 f1                	cmp    %esi,%ecx
  800cad:	7d 0b                	jge    800cba <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800caf:	83 c2 01             	add    $0x1,%edx
  800cb2:	0f af c6             	imul   %esi,%eax
  800cb5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800cb8:	eb be                	jmp    800c78 <strtol+0x8d>
  800cba:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800cbc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cc0:	74 05                	je     800cc7 <strtol+0xdc>
		*endptr = (char *) s;
  800cc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800cc5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800cc7:	89 ca                	mov    %ecx,%edx
  800cc9:	f7 da                	neg    %edx
  800ccb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800ccf:	0f 45 c2             	cmovne %edx,%eax
}
  800cd2:	83 c4 04             	add    $0x4,%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	83 ec 0c             	sub    $0xc,%esp
  800ce0:	89 1c 24             	mov    %ebx,(%esp)
  800ce3:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ce7:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ceb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf0:	b8 01 00 00 00       	mov    $0x1,%eax
  800cf5:	89 d1                	mov    %edx,%ecx
  800cf7:	89 d3                	mov    %edx,%ebx
  800cf9:	89 d7                	mov    %edx,%edi
  800cfb:	89 d6                	mov    %edx,%esi
  800cfd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800cff:	8b 1c 24             	mov    (%esp),%ebx
  800d02:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d06:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d0a:	89 ec                	mov    %ebp,%esp
  800d0c:	5d                   	pop    %ebp
  800d0d:	c3                   	ret    

00800d0e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800d1f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d27:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2a:	89 c3                	mov    %eax,%ebx
  800d2c:	89 c7                	mov    %eax,%edi
  800d2e:	89 c6                	mov    %eax,%esi
  800d30:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d32:	8b 1c 24             	mov    (%esp),%ebx
  800d35:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d39:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d3d:	89 ec                	mov    %ebp,%esp
  800d3f:	5d                   	pop    %ebp
  800d40:	c3                   	ret    

00800d41 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d41:	55                   	push   %ebp
  800d42:	89 e5                	mov    %esp,%ebp
  800d44:	83 ec 38             	sub    $0x38,%esp
  800d47:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d4a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d4d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d50:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d55:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d5a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d5d:	89 cb                	mov    %ecx,%ebx
  800d5f:	89 cf                	mov    %ecx,%edi
  800d61:	89 ce                	mov    %ecx,%esi
  800d63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d65:	85 c0                	test   %eax,%eax
  800d67:	7e 28                	jle    800d91 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d69:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d6d:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d74:	00 
  800d75:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800d7c:	00 
  800d7d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d84:	00 
  800d85:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800d8c:	e8 bc f3 ff ff       	call   80014d <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d91:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d94:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d97:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d9a:	89 ec                	mov    %ebp,%esp
  800d9c:	5d                   	pop    %ebp
  800d9d:	c3                   	ret    

00800d9e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	83 ec 0c             	sub    $0xc,%esp
  800da4:	89 1c 24             	mov    %ebx,(%esp)
  800da7:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dab:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800daf:	be 00 00 00 00       	mov    $0x0,%esi
  800db4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800db9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dbc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800dc7:	8b 1c 24             	mov    (%esp),%ebx
  800dca:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dce:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dd2:	89 ec                	mov    %ebp,%esp
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    

00800dd6 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800dd6:	55                   	push   %ebp
  800dd7:	89 e5                	mov    %esp,%ebp
  800dd9:	83 ec 38             	sub    $0x38,%esp
  800ddc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ddf:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800de2:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800de5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dea:	b8 09 00 00 00       	mov    $0x9,%eax
  800def:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800df2:	8b 55 08             	mov    0x8(%ebp),%edx
  800df5:	89 df                	mov    %ebx,%edi
  800df7:	89 de                	mov    %ebx,%esi
  800df9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dfb:	85 c0                	test   %eax,%eax
  800dfd:	7e 28                	jle    800e27 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dff:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e03:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e0a:	00 
  800e0b:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800e12:	00 
  800e13:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e1a:	00 
  800e1b:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800e22:	e8 26 f3 ff ff       	call   80014d <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e27:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e2a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e2d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e30:	89 ec                	mov    %ebp,%esp
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    

00800e34 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	83 ec 38             	sub    $0x38,%esp
  800e3a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e3d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e40:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e43:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e48:	b8 08 00 00 00       	mov    $0x8,%eax
  800e4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e50:	8b 55 08             	mov    0x8(%ebp),%edx
  800e53:	89 df                	mov    %ebx,%edi
  800e55:	89 de                	mov    %ebx,%esi
  800e57:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e59:	85 c0                	test   %eax,%eax
  800e5b:	7e 28                	jle    800e85 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e5d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e61:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e68:	00 
  800e69:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800e70:	00 
  800e71:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e78:	00 
  800e79:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800e80:	e8 c8 f2 ff ff       	call   80014d <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e85:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e88:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e8b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e8e:	89 ec                	mov    %ebp,%esp
  800e90:	5d                   	pop    %ebp
  800e91:	c3                   	ret    

00800e92 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	83 ec 38             	sub    $0x38,%esp
  800e98:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e9b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e9e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ea1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ea6:	b8 06 00 00 00       	mov    $0x6,%eax
  800eab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eae:	8b 55 08             	mov    0x8(%ebp),%edx
  800eb1:	89 df                	mov    %ebx,%edi
  800eb3:	89 de                	mov    %ebx,%esi
  800eb5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	7e 28                	jle    800ee3 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ebb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ebf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ec6:	00 
  800ec7:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800ece:	00 
  800ecf:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ed6:	00 
  800ed7:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800ede:	e8 6a f2 ff ff       	call   80014d <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800ee3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ee6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ee9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eec:	89 ec                	mov    %ebp,%esp
  800eee:	5d                   	pop    %ebp
  800eef:	c3                   	ret    

00800ef0 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ef0:	55                   	push   %ebp
  800ef1:	89 e5                	mov    %esp,%ebp
  800ef3:	83 ec 38             	sub    $0x38,%esp
  800ef6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ef9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800efc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eff:	b8 05 00 00 00       	mov    $0x5,%eax
  800f04:	8b 75 18             	mov    0x18(%ebp),%esi
  800f07:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f0a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f10:	8b 55 08             	mov    0x8(%ebp),%edx
  800f13:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f15:	85 c0                	test   %eax,%eax
  800f17:	7e 28                	jle    800f41 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f19:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f1d:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f24:	00 
  800f25:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800f2c:	00 
  800f2d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f34:	00 
  800f35:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800f3c:	e8 0c f2 ff ff       	call   80014d <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f41:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f44:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f47:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f4a:	89 ec                	mov    %ebp,%esp
  800f4c:	5d                   	pop    %ebp
  800f4d:	c3                   	ret    

00800f4e <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f4e:	55                   	push   %ebp
  800f4f:	89 e5                	mov    %esp,%ebp
  800f51:	83 ec 38             	sub    $0x38,%esp
  800f54:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f57:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f5a:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f5d:	be 00 00 00 00       	mov    $0x0,%esi
  800f62:	b8 04 00 00 00       	mov    $0x4,%eax
  800f67:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f6a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f6d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f70:	89 f7                	mov    %esi,%edi
  800f72:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f74:	85 c0                	test   %eax,%eax
  800f76:	7e 28                	jle    800fa0 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f78:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f7c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f83:	00 
  800f84:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  800f8b:	00 
  800f8c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f93:	00 
  800f94:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  800f9b:	e8 ad f1 ff ff       	call   80014d <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fa0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fa3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fa6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fa9:	89 ec                	mov    %ebp,%esp
  800fab:	5d                   	pop    %ebp
  800fac:	c3                   	ret    

00800fad <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800fad:	55                   	push   %ebp
  800fae:	89 e5                	mov    %esp,%ebp
  800fb0:	83 ec 0c             	sub    $0xc,%esp
  800fb3:	89 1c 24             	mov    %ebx,(%esp)
  800fb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fba:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fbe:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fc8:	89 d1                	mov    %edx,%ecx
  800fca:	89 d3                	mov    %edx,%ebx
  800fcc:	89 d7                	mov    %edx,%edi
  800fce:	89 d6                	mov    %edx,%esi
  800fd0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fd2:	8b 1c 24             	mov    (%esp),%ebx
  800fd5:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fd9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fdd:	89 ec                	mov    %ebp,%esp
  800fdf:	5d                   	pop    %ebp
  800fe0:	c3                   	ret    

00800fe1 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800fe1:	55                   	push   %ebp
  800fe2:	89 e5                	mov    %esp,%ebp
  800fe4:	83 ec 0c             	sub    $0xc,%esp
  800fe7:	89 1c 24             	mov    %ebx,(%esp)
  800fea:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fee:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ff7:	b8 02 00 00 00       	mov    $0x2,%eax
  800ffc:	89 d1                	mov    %edx,%ecx
  800ffe:	89 d3                	mov    %edx,%ebx
  801000:	89 d7                	mov    %edx,%edi
  801002:	89 d6                	mov    %edx,%esi
  801004:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801006:	8b 1c 24             	mov    (%esp),%ebx
  801009:	8b 74 24 04          	mov    0x4(%esp),%esi
  80100d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801011:	89 ec                	mov    %ebp,%esp
  801013:	5d                   	pop    %ebp
  801014:	c3                   	ret    

00801015 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801015:	55                   	push   %ebp
  801016:	89 e5                	mov    %esp,%ebp
  801018:	83 ec 38             	sub    $0x38,%esp
  80101b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80101e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801021:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801024:	b9 00 00 00 00       	mov    $0x0,%ecx
  801029:	b8 03 00 00 00       	mov    $0x3,%eax
  80102e:	8b 55 08             	mov    0x8(%ebp),%edx
  801031:	89 cb                	mov    %ecx,%ebx
  801033:	89 cf                	mov    %ecx,%edi
  801035:	89 ce                	mov    %ecx,%esi
  801037:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801039:	85 c0                	test   %eax,%eax
  80103b:	7e 28                	jle    801065 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80103d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801041:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801048:	00 
  801049:	c7 44 24 08 04 16 80 	movl   $0x801604,0x8(%esp)
  801050:	00 
  801051:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801058:	00 
  801059:	c7 04 24 21 16 80 00 	movl   $0x801621,(%esp)
  801060:	e8 e8 f0 ff ff       	call   80014d <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801065:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801068:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80106b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80106e:	89 ec                	mov    %ebp,%esp
  801070:	5d                   	pop    %ebp
  801071:	c3                   	ret    

00801072 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801072:	55                   	push   %ebp
  801073:	89 e5                	mov    %esp,%ebp
  801075:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801078:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80107f:	75 1c                	jne    80109d <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  801081:	c7 44 24 08 30 16 80 	movl   $0x801630,0x8(%esp)
  801088:	00 
  801089:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801090:	00 
  801091:	c7 04 24 54 16 80 00 	movl   $0x801654,(%esp)
  801098:	e8 b0 f0 ff ff       	call   80014d <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80109d:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a0:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8010a5:	c9                   	leave  
  8010a6:	c3                   	ret    
  8010a7:	66 90                	xchg   %ax,%ax
  8010a9:	66 90                	xchg   %ax,%ax
  8010ab:	66 90                	xchg   %ax,%ax
  8010ad:	66 90                	xchg   %ax,%ax
  8010af:	90                   	nop

008010b0 <__udivdi3>:
  8010b0:	55                   	push   %ebp
  8010b1:	89 e5                	mov    %esp,%ebp
  8010b3:	57                   	push   %edi
  8010b4:	56                   	push   %esi
  8010b5:	83 ec 10             	sub    $0x10,%esp
  8010b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8010bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8010be:	8b 75 10             	mov    0x10(%ebp),%esi
  8010c1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8010c9:	75 35                	jne    801100 <__udivdi3+0x50>
  8010cb:	39 fe                	cmp    %edi,%esi
  8010cd:	77 61                	ja     801130 <__udivdi3+0x80>
  8010cf:	85 f6                	test   %esi,%esi
  8010d1:	75 0b                	jne    8010de <__udivdi3+0x2e>
  8010d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8010d8:	31 d2                	xor    %edx,%edx
  8010da:	f7 f6                	div    %esi
  8010dc:	89 c6                	mov    %eax,%esi
  8010de:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8010e1:	31 d2                	xor    %edx,%edx
  8010e3:	89 f8                	mov    %edi,%eax
  8010e5:	f7 f6                	div    %esi
  8010e7:	89 c7                	mov    %eax,%edi
  8010e9:	89 c8                	mov    %ecx,%eax
  8010eb:	f7 f6                	div    %esi
  8010ed:	89 c1                	mov    %eax,%ecx
  8010ef:	89 fa                	mov    %edi,%edx
  8010f1:	89 c8                	mov    %ecx,%eax
  8010f3:	83 c4 10             	add    $0x10,%esp
  8010f6:	5e                   	pop    %esi
  8010f7:	5f                   	pop    %edi
  8010f8:	5d                   	pop    %ebp
  8010f9:	c3                   	ret    
  8010fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801100:	39 f8                	cmp    %edi,%eax
  801102:	77 1c                	ja     801120 <__udivdi3+0x70>
  801104:	0f bd d0             	bsr    %eax,%edx
  801107:	83 f2 1f             	xor    $0x1f,%edx
  80110a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80110d:	75 39                	jne    801148 <__udivdi3+0x98>
  80110f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801112:	0f 86 a0 00 00 00    	jbe    8011b8 <__udivdi3+0x108>
  801118:	39 f8                	cmp    %edi,%eax
  80111a:	0f 82 98 00 00 00    	jb     8011b8 <__udivdi3+0x108>
  801120:	31 ff                	xor    %edi,%edi
  801122:	31 c9                	xor    %ecx,%ecx
  801124:	89 c8                	mov    %ecx,%eax
  801126:	89 fa                	mov    %edi,%edx
  801128:	83 c4 10             	add    $0x10,%esp
  80112b:	5e                   	pop    %esi
  80112c:	5f                   	pop    %edi
  80112d:	5d                   	pop    %ebp
  80112e:	c3                   	ret    
  80112f:	90                   	nop
  801130:	89 d1                	mov    %edx,%ecx
  801132:	89 fa                	mov    %edi,%edx
  801134:	89 c8                	mov    %ecx,%eax
  801136:	31 ff                	xor    %edi,%edi
  801138:	f7 f6                	div    %esi
  80113a:	89 c1                	mov    %eax,%ecx
  80113c:	89 fa                	mov    %edi,%edx
  80113e:	89 c8                	mov    %ecx,%eax
  801140:	83 c4 10             	add    $0x10,%esp
  801143:	5e                   	pop    %esi
  801144:	5f                   	pop    %edi
  801145:	5d                   	pop    %ebp
  801146:	c3                   	ret    
  801147:	90                   	nop
  801148:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80114c:	89 f2                	mov    %esi,%edx
  80114e:	d3 e0                	shl    %cl,%eax
  801150:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801153:	b8 20 00 00 00       	mov    $0x20,%eax
  801158:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80115b:	89 c1                	mov    %eax,%ecx
  80115d:	d3 ea                	shr    %cl,%edx
  80115f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801163:	0b 55 ec             	or     -0x14(%ebp),%edx
  801166:	d3 e6                	shl    %cl,%esi
  801168:	89 c1                	mov    %eax,%ecx
  80116a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80116d:	89 fe                	mov    %edi,%esi
  80116f:	d3 ee                	shr    %cl,%esi
  801171:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801175:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801178:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80117b:	d3 e7                	shl    %cl,%edi
  80117d:	89 c1                	mov    %eax,%ecx
  80117f:	d3 ea                	shr    %cl,%edx
  801181:	09 d7                	or     %edx,%edi
  801183:	89 f2                	mov    %esi,%edx
  801185:	89 f8                	mov    %edi,%eax
  801187:	f7 75 ec             	divl   -0x14(%ebp)
  80118a:	89 d6                	mov    %edx,%esi
  80118c:	89 c7                	mov    %eax,%edi
  80118e:	f7 65 e8             	mull   -0x18(%ebp)
  801191:	39 d6                	cmp    %edx,%esi
  801193:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801196:	72 30                	jb     8011c8 <__udivdi3+0x118>
  801198:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80119b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80119f:	d3 e2                	shl    %cl,%edx
  8011a1:	39 c2                	cmp    %eax,%edx
  8011a3:	73 05                	jae    8011aa <__udivdi3+0xfa>
  8011a5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8011a8:	74 1e                	je     8011c8 <__udivdi3+0x118>
  8011aa:	89 f9                	mov    %edi,%ecx
  8011ac:	31 ff                	xor    %edi,%edi
  8011ae:	e9 71 ff ff ff       	jmp    801124 <__udivdi3+0x74>
  8011b3:	90                   	nop
  8011b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011b8:	31 ff                	xor    %edi,%edi
  8011ba:	b9 01 00 00 00       	mov    $0x1,%ecx
  8011bf:	e9 60 ff ff ff       	jmp    801124 <__udivdi3+0x74>
  8011c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011c8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8011cb:	31 ff                	xor    %edi,%edi
  8011cd:	89 c8                	mov    %ecx,%eax
  8011cf:	89 fa                	mov    %edi,%edx
  8011d1:	83 c4 10             	add    $0x10,%esp
  8011d4:	5e                   	pop    %esi
  8011d5:	5f                   	pop    %edi
  8011d6:	5d                   	pop    %ebp
  8011d7:	c3                   	ret    
  8011d8:	66 90                	xchg   %ax,%ax
  8011da:	66 90                	xchg   %ax,%ax
  8011dc:	66 90                	xchg   %ax,%ax
  8011de:	66 90                	xchg   %ax,%ax

008011e0 <__umoddi3>:
  8011e0:	55                   	push   %ebp
  8011e1:	89 e5                	mov    %esp,%ebp
  8011e3:	57                   	push   %edi
  8011e4:	56                   	push   %esi
  8011e5:	83 ec 20             	sub    $0x20,%esp
  8011e8:	8b 55 14             	mov    0x14(%ebp),%edx
  8011eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8011f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8011f4:	85 d2                	test   %edx,%edx
  8011f6:	89 c8                	mov    %ecx,%eax
  8011f8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8011fb:	75 13                	jne    801210 <__umoddi3+0x30>
  8011fd:	39 f7                	cmp    %esi,%edi
  8011ff:	76 3f                	jbe    801240 <__umoddi3+0x60>
  801201:	89 f2                	mov    %esi,%edx
  801203:	f7 f7                	div    %edi
  801205:	89 d0                	mov    %edx,%eax
  801207:	31 d2                	xor    %edx,%edx
  801209:	83 c4 20             	add    $0x20,%esp
  80120c:	5e                   	pop    %esi
  80120d:	5f                   	pop    %edi
  80120e:	5d                   	pop    %ebp
  80120f:	c3                   	ret    
  801210:	39 f2                	cmp    %esi,%edx
  801212:	77 4c                	ja     801260 <__umoddi3+0x80>
  801214:	0f bd ca             	bsr    %edx,%ecx
  801217:	83 f1 1f             	xor    $0x1f,%ecx
  80121a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80121d:	75 51                	jne    801270 <__umoddi3+0x90>
  80121f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801222:	0f 87 e0 00 00 00    	ja     801308 <__umoddi3+0x128>
  801228:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80122b:	29 f8                	sub    %edi,%eax
  80122d:	19 d6                	sbb    %edx,%esi
  80122f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801232:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801235:	89 f2                	mov    %esi,%edx
  801237:	83 c4 20             	add    $0x20,%esp
  80123a:	5e                   	pop    %esi
  80123b:	5f                   	pop    %edi
  80123c:	5d                   	pop    %ebp
  80123d:	c3                   	ret    
  80123e:	66 90                	xchg   %ax,%ax
  801240:	85 ff                	test   %edi,%edi
  801242:	75 0b                	jne    80124f <__umoddi3+0x6f>
  801244:	b8 01 00 00 00       	mov    $0x1,%eax
  801249:	31 d2                	xor    %edx,%edx
  80124b:	f7 f7                	div    %edi
  80124d:	89 c7                	mov    %eax,%edi
  80124f:	89 f0                	mov    %esi,%eax
  801251:	31 d2                	xor    %edx,%edx
  801253:	f7 f7                	div    %edi
  801255:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801258:	f7 f7                	div    %edi
  80125a:	eb a9                	jmp    801205 <__umoddi3+0x25>
  80125c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801260:	89 c8                	mov    %ecx,%eax
  801262:	89 f2                	mov    %esi,%edx
  801264:	83 c4 20             	add    $0x20,%esp
  801267:	5e                   	pop    %esi
  801268:	5f                   	pop    %edi
  801269:	5d                   	pop    %ebp
  80126a:	c3                   	ret    
  80126b:	90                   	nop
  80126c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801270:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801274:	d3 e2                	shl    %cl,%edx
  801276:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801279:	ba 20 00 00 00       	mov    $0x20,%edx
  80127e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801281:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801284:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801288:	89 fa                	mov    %edi,%edx
  80128a:	d3 ea                	shr    %cl,%edx
  80128c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801290:	0b 55 f4             	or     -0xc(%ebp),%edx
  801293:	d3 e7                	shl    %cl,%edi
  801295:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801299:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80129c:	89 f2                	mov    %esi,%edx
  80129e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8012a1:	89 c7                	mov    %eax,%edi
  8012a3:	d3 ea                	shr    %cl,%edx
  8012a5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8012ac:	89 c2                	mov    %eax,%edx
  8012ae:	d3 e6                	shl    %cl,%esi
  8012b0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012b4:	d3 ea                	shr    %cl,%edx
  8012b6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012ba:	09 d6                	or     %edx,%esi
  8012bc:	89 f0                	mov    %esi,%eax
  8012be:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8012c1:	d3 e7                	shl    %cl,%edi
  8012c3:	89 f2                	mov    %esi,%edx
  8012c5:	f7 75 f4             	divl   -0xc(%ebp)
  8012c8:	89 d6                	mov    %edx,%esi
  8012ca:	f7 65 e8             	mull   -0x18(%ebp)
  8012cd:	39 d6                	cmp    %edx,%esi
  8012cf:	72 2b                	jb     8012fc <__umoddi3+0x11c>
  8012d1:	39 c7                	cmp    %eax,%edi
  8012d3:	72 23                	jb     8012f8 <__umoddi3+0x118>
  8012d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012d9:	29 c7                	sub    %eax,%edi
  8012db:	19 d6                	sbb    %edx,%esi
  8012dd:	89 f0                	mov    %esi,%eax
  8012df:	89 f2                	mov    %esi,%edx
  8012e1:	d3 ef                	shr    %cl,%edi
  8012e3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012e7:	d3 e0                	shl    %cl,%eax
  8012e9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012ed:	09 f8                	or     %edi,%eax
  8012ef:	d3 ea                	shr    %cl,%edx
  8012f1:	83 c4 20             	add    $0x20,%esp
  8012f4:	5e                   	pop    %esi
  8012f5:	5f                   	pop    %edi
  8012f6:	5d                   	pop    %ebp
  8012f7:	c3                   	ret    
  8012f8:	39 d6                	cmp    %edx,%esi
  8012fa:	75 d9                	jne    8012d5 <__umoddi3+0xf5>
  8012fc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8012ff:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801302:	eb d1                	jmp    8012d5 <__umoddi3+0xf5>
  801304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801308:	39 f2                	cmp    %esi,%edx
  80130a:	0f 82 18 ff ff ff    	jb     801228 <__umoddi3+0x48>
  801310:	e9 1d ff ff ff       	jmp    801232 <__umoddi3+0x52>
