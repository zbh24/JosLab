
obj/user/faultalloc：     文件格式 elf32-i386


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
  80002c:	e8 c3 00 00 00       	call   8000f4 <libmain>
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
  800039:	c7 04 24 6f 00 80 00 	movl   $0x80006f,(%esp)
  800040:	e8 4d 10 00 00       	call   801092 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  800045:	c7 44 24 04 ef be ad 	movl   $0xdeadbeef,0x4(%esp)
  80004c:	de 
  80004d:	c7 04 24 40 13 80 00 	movl   $0x801340,(%esp)
  800054:	e8 bf 01 00 00       	call   800218 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  800059:	c7 44 24 04 fe bf fe 	movl   $0xcafebffe,0x4(%esp)
  800060:	ca 
  800061:	c7 04 24 40 13 80 00 	movl   $0x801340,(%esp)
  800068:	e8 ab 01 00 00       	call   800218 <cprintf>
}
  80006d:	c9                   	leave  
  80006e:	c3                   	ret    

0080006f <handler>:

#include <inc/lib.h>

void
handler(struct UTrapframe *utf)
{
  80006f:	55                   	push   %ebp
  800070:	89 e5                	mov    %esp,%ebp
  800072:	53                   	push   %ebx
  800073:	83 ec 24             	sub    $0x24,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  800076:	8b 45 08             	mov    0x8(%ebp),%eax
  800079:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  80007b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80007f:	c7 04 24 44 13 80 00 	movl   $0x801344,(%esp)
  800086:	e8 8d 01 00 00       	call   800218 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80008b:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800092:	00 
  800093:	89 d8                	mov    %ebx,%eax
  800095:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80009a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80009e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a5:	e8 c4 0e 00 00       	call   800f6e <sys_page_alloc>
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	79 24                	jns    8000d2 <handler+0x63>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
  8000ae:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000b2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000b6:	c7 44 24 08 60 13 80 	movl   $0x801360,0x8(%esp)
  8000bd:	00 
  8000be:	c7 44 24 04 0e 00 00 	movl   $0xe,0x4(%esp)
  8000c5:	00 
  8000c6:	c7 04 24 4e 13 80 00 	movl   $0x80134e,(%esp)
  8000cd:	e8 8f 00 00 00       	call   800161 <_panic>
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  8000d2:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8000d6:	c7 44 24 08 8c 13 80 	movl   $0x80138c,0x8(%esp)
  8000dd:	00 
  8000de:	c7 44 24 04 64 00 00 	movl   $0x64,0x4(%esp)
  8000e5:	00 
  8000e6:	89 1c 24             	mov    %ebx,(%esp)
  8000e9:	e8 78 07 00 00       	call   800866 <snprintf>
}
  8000ee:	83 c4 24             	add    $0x24,%esp
  8000f1:	5b                   	pop    %ebx
  8000f2:	5d                   	pop    %ebp
  8000f3:	c3                   	ret    

008000f4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f4:	55                   	push   %ebp
  8000f5:	89 e5                	mov    %esp,%ebp
  8000f7:	83 ec 18             	sub    $0x18,%esp
  8000fa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8000fd:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800100:	8b 75 08             	mov    0x8(%ebp),%esi
  800103:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800106:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80010d:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800110:	e8 ec 0e 00 00       	call   801001 <sys_getenvid>
  800115:	25 ff 03 00 00       	and    $0x3ff,%eax
  80011a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80011d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800122:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800127:	85 f6                	test   %esi,%esi
  800129:	7e 07                	jle    800132 <libmain+0x3e>
		binaryname = argv[0];
  80012b:	8b 03                	mov    (%ebx),%eax
  80012d:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800132:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800136:	89 34 24             	mov    %esi,(%esp)
  800139:	e8 f5 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80013e:	e8 0a 00 00 00       	call   80014d <exit>
}
  800143:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800146:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800149:	89 ec                	mov    %ebp,%esp
  80014b:	5d                   	pop    %ebp
  80014c:	c3                   	ret    

0080014d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800153:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015a:	e8 d6 0e 00 00       	call   801035 <sys_env_destroy>
}
  80015f:	c9                   	leave  
  800160:	c3                   	ret    

00800161 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800161:	55                   	push   %ebp
  800162:	89 e5                	mov    %esp,%ebp
  800164:	56                   	push   %esi
  800165:	53                   	push   %ebx
  800166:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800169:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80016c:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800172:	e8 8a 0e 00 00       	call   801001 <sys_getenvid>
  800177:	8b 55 0c             	mov    0xc(%ebp),%edx
  80017a:	89 54 24 10          	mov    %edx,0x10(%esp)
  80017e:	8b 55 08             	mov    0x8(%ebp),%edx
  800181:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800185:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800189:	89 44 24 04          	mov    %eax,0x4(%esp)
  80018d:	c7 04 24 b8 13 80 00 	movl   $0x8013b8,(%esp)
  800194:	e8 7f 00 00 00       	call   800218 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800199:	89 74 24 04          	mov    %esi,0x4(%esp)
  80019d:	8b 45 10             	mov    0x10(%ebp),%eax
  8001a0:	89 04 24             	mov    %eax,(%esp)
  8001a3:	e8 0f 00 00 00       	call   8001b7 <vcprintf>
	cprintf("\n");
  8001a8:	c7 04 24 42 13 80 00 	movl   $0x801342,(%esp)
  8001af:	e8 64 00 00 00       	call   800218 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001b4:	cc                   	int3   
  8001b5:	eb fd                	jmp    8001b4 <_panic+0x53>

008001b7 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001b7:	55                   	push   %ebp
  8001b8:	89 e5                	mov    %esp,%ebp
  8001ba:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001c0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001c7:	00 00 00 
	b.cnt = 0;
  8001ca:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d1:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001db:	8b 45 08             	mov    0x8(%ebp),%eax
  8001de:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ec:	c7 04 24 32 02 80 00 	movl   $0x800232,(%esp)
  8001f3:	e8 d5 01 00 00       	call   8003cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f8:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800202:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800208:	89 04 24             	mov    %eax,(%esp)
  80020b:	e8 1e 0b 00 00       	call   800d2e <sys_cputs>

	return b.cnt;
}
  800210:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800216:	c9                   	leave  
  800217:	c3                   	ret    

00800218 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  80021e:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800221:	89 44 24 04          	mov    %eax,0x4(%esp)
  800225:	8b 45 08             	mov    0x8(%ebp),%eax
  800228:	89 04 24             	mov    %eax,(%esp)
  80022b:	e8 87 ff ff ff       	call   8001b7 <vcprintf>
	va_end(ap);

	return cnt;
}
  800230:	c9                   	leave  
  800231:	c3                   	ret    

00800232 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800232:	55                   	push   %ebp
  800233:	89 e5                	mov    %esp,%ebp
  800235:	53                   	push   %ebx
  800236:	83 ec 14             	sub    $0x14,%esp
  800239:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80023c:	8b 03                	mov    (%ebx),%eax
  80023e:	8b 55 08             	mov    0x8(%ebp),%edx
  800241:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800245:	83 c0 01             	add    $0x1,%eax
  800248:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80024a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80024f:	75 19                	jne    80026a <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800251:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800258:	00 
  800259:	8d 43 08             	lea    0x8(%ebx),%eax
  80025c:	89 04 24             	mov    %eax,(%esp)
  80025f:	e8 ca 0a 00 00       	call   800d2e <sys_cputs>
		b->idx = 0;
  800264:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80026a:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80026e:	83 c4 14             	add    $0x14,%esp
  800271:	5b                   	pop    %ebx
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    
  800274:	66 90                	xchg   %ax,%ax
  800276:	66 90                	xchg   %ax,%ax
  800278:	66 90                	xchg   %ax,%ax
  80027a:	66 90                	xchg   %ax,%ax
  80027c:	66 90                	xchg   %ax,%ax
  80027e:	66 90                	xchg   %ax,%ax

00800280 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800280:	55                   	push   %ebp
  800281:	89 e5                	mov    %esp,%ebp
  800283:	57                   	push   %edi
  800284:	56                   	push   %esi
  800285:	53                   	push   %ebx
  800286:	83 ec 4c             	sub    $0x4c,%esp
  800289:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80028c:	89 d6                	mov    %edx,%esi
  80028e:	8b 45 08             	mov    0x8(%ebp),%eax
  800291:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800294:	8b 55 0c             	mov    0xc(%ebp),%edx
  800297:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80029a:	8b 45 10             	mov    0x10(%ebp),%eax
  80029d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ab:	39 d1                	cmp    %edx,%ecx
  8002ad:	72 15                	jb     8002c4 <printnum+0x44>
  8002af:	77 07                	ja     8002b8 <printnum+0x38>
  8002b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002b4:	39 d0                	cmp    %edx,%eax
  8002b6:	76 0c                	jbe    8002c4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002b8:	83 eb 01             	sub    $0x1,%ebx
  8002bb:	85 db                	test   %ebx,%ebx
  8002bd:	8d 76 00             	lea    0x0(%esi),%esi
  8002c0:	7f 61                	jg     800323 <printnum+0xa3>
  8002c2:	eb 70                	jmp    800334 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002c4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002c8:	83 eb 01             	sub    $0x1,%ebx
  8002cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002d7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002db:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002de:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8002e1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8002e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002ef:	00 
  8002f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002f3:	89 04 24             	mov    %eax,(%esp)
  8002f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002fd:	e8 ce 0d 00 00       	call   8010d0 <__udivdi3>
  800302:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800305:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800308:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80030c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800310:	89 04 24             	mov    %eax,(%esp)
  800313:	89 54 24 04          	mov    %edx,0x4(%esp)
  800317:	89 f2                	mov    %esi,%edx
  800319:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80031c:	e8 5f ff ff ff       	call   800280 <printnum>
  800321:	eb 11                	jmp    800334 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800323:	89 74 24 04          	mov    %esi,0x4(%esp)
  800327:	89 3c 24             	mov    %edi,(%esp)
  80032a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80032d:	83 eb 01             	sub    $0x1,%ebx
  800330:	85 db                	test   %ebx,%ebx
  800332:	7f ef                	jg     800323 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800334:	89 74 24 04          	mov    %esi,0x4(%esp)
  800338:	8b 74 24 04          	mov    0x4(%esp),%esi
  80033c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80033f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800343:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80034a:	00 
  80034b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80034e:	89 14 24             	mov    %edx,(%esp)
  800351:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800354:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800358:	e8 a3 0e 00 00       	call   801200 <__umoddi3>
  80035d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800361:	0f be 80 db 13 80 00 	movsbl 0x8013db(%eax),%eax
  800368:	89 04 24             	mov    %eax,(%esp)
  80036b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80036e:	83 c4 4c             	add    $0x4c,%esp
  800371:	5b                   	pop    %ebx
  800372:	5e                   	pop    %esi
  800373:	5f                   	pop    %edi
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800379:	83 fa 01             	cmp    $0x1,%edx
  80037c:	7e 0e                	jle    80038c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80037e:	8b 10                	mov    (%eax),%edx
  800380:	8d 4a 08             	lea    0x8(%edx),%ecx
  800383:	89 08                	mov    %ecx,(%eax)
  800385:	8b 02                	mov    (%edx),%eax
  800387:	8b 52 04             	mov    0x4(%edx),%edx
  80038a:	eb 22                	jmp    8003ae <getuint+0x38>
	else if (lflag)
  80038c:	85 d2                	test   %edx,%edx
  80038e:	74 10                	je     8003a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800390:	8b 10                	mov    (%eax),%edx
  800392:	8d 4a 04             	lea    0x4(%edx),%ecx
  800395:	89 08                	mov    %ecx,(%eax)
  800397:	8b 02                	mov    (%edx),%eax
  800399:	ba 00 00 00 00       	mov    $0x0,%edx
  80039e:	eb 0e                	jmp    8003ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003a0:	8b 10                	mov    (%eax),%edx
  8003a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a5:	89 08                	mov    %ecx,(%eax)
  8003a7:	8b 02                	mov    (%edx),%eax
  8003a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ae:	5d                   	pop    %ebp
  8003af:	c3                   	ret    

008003b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ba:	8b 10                	mov    (%eax),%edx
  8003bc:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bf:	73 0a                	jae    8003cb <sprintputch+0x1b>
		*b->buf++ = ch;
  8003c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003c4:	88 0a                	mov    %cl,(%edx)
  8003c6:	83 c2 01             	add    $0x1,%edx
  8003c9:	89 10                	mov    %edx,(%eax)
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	57                   	push   %edi
  8003d1:	56                   	push   %esi
  8003d2:	53                   	push   %ebx
  8003d3:	83 ec 5c             	sub    $0x5c,%esp
  8003d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003df:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8003e6:	eb 11                	jmp    8003f9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8003e8:	85 c0                	test   %eax,%eax
  8003ea:	0f 84 16 04 00 00    	je     800806 <vprintfmt+0x439>
				return;
			putch(ch, putdat);
  8003f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003f4:	89 04 24             	mov    %eax,(%esp)
  8003f7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003f9:	0f b6 03             	movzbl (%ebx),%eax
  8003fc:	83 c3 01             	add    $0x1,%ebx
  8003ff:	83 f8 25             	cmp    $0x25,%eax
  800402:	75 e4                	jne    8003e8 <vprintfmt+0x1b>
  800404:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80040b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800412:	b9 00 00 00 00       	mov    $0x0,%ecx
  800417:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80041b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800422:	eb 06                	jmp    80042a <vprintfmt+0x5d>
  800424:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800428:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80042a:	0f b6 13             	movzbl (%ebx),%edx
  80042d:	0f b6 c2             	movzbl %dl,%eax
  800430:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800433:	8d 43 01             	lea    0x1(%ebx),%eax
  800436:	83 ea 23             	sub    $0x23,%edx
  800439:	80 fa 55             	cmp    $0x55,%dl
  80043c:	0f 87 a7 03 00 00    	ja     8007e9 <vprintfmt+0x41c>
  800442:	0f b6 d2             	movzbl %dl,%edx
  800445:	ff 24 95 a0 14 80 00 	jmp    *0x8014a0(,%edx,4)
  80044c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800450:	eb d6                	jmp    800428 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800452:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800455:	83 ea 30             	sub    $0x30,%edx
  800458:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80045b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80045e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800461:	83 fb 09             	cmp    $0x9,%ebx
  800464:	77 54                	ja     8004ba <vprintfmt+0xed>
  800466:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800469:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80046c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80046f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800472:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800476:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800479:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80047c:	83 fb 09             	cmp    $0x9,%ebx
  80047f:	76 eb                	jbe    80046c <vprintfmt+0x9f>
  800481:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800484:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800487:	eb 31                	jmp    8004ba <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800489:	8b 55 14             	mov    0x14(%ebp),%edx
  80048c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80048f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800492:	8b 12                	mov    (%edx),%edx
  800494:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800497:	eb 21                	jmp    8004ba <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800499:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80049d:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a2:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  8004a6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004a9:	e9 7a ff ff ff       	jmp    800428 <vprintfmt+0x5b>
  8004ae:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004b5:	e9 6e ff ff ff       	jmp    800428 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8004ba:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004be:	0f 89 64 ff ff ff    	jns    800428 <vprintfmt+0x5b>
  8004c4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8004c7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004ca:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8004cd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8004d0:	e9 53 ff ff ff       	jmp    800428 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004d5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8004d8:	e9 4b ff ff ff       	jmp    800428 <vprintfmt+0x5b>
  8004dd:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8004e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e3:	8d 50 04             	lea    0x4(%eax),%edx
  8004e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004ed:	8b 00                	mov    (%eax),%eax
  8004ef:	89 04 24             	mov    %eax,(%esp)
  8004f2:	ff d7                	call   *%edi
  8004f4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8004f7:	e9 fd fe ff ff       	jmp    8003f9 <vprintfmt+0x2c>
  8004fc:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800502:	8d 50 04             	lea    0x4(%eax),%edx
  800505:	89 55 14             	mov    %edx,0x14(%ebp)
  800508:	8b 00                	mov    (%eax),%eax
  80050a:	89 c2                	mov    %eax,%edx
  80050c:	c1 fa 1f             	sar    $0x1f,%edx
  80050f:	31 d0                	xor    %edx,%eax
  800511:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800513:	83 f8 08             	cmp    $0x8,%eax
  800516:	7f 0b                	jg     800523 <vprintfmt+0x156>
  800518:	8b 14 85 00 16 80 00 	mov    0x801600(,%eax,4),%edx
  80051f:	85 d2                	test   %edx,%edx
  800521:	75 20                	jne    800543 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800523:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800527:	c7 44 24 08 ec 13 80 	movl   $0x8013ec,0x8(%esp)
  80052e:	00 
  80052f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800533:	89 3c 24             	mov    %edi,(%esp)
  800536:	e8 53 03 00 00       	call   80088e <printfmt>
  80053b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80053e:	e9 b6 fe ff ff       	jmp    8003f9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800543:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800547:	c7 44 24 08 f5 13 80 	movl   $0x8013f5,0x8(%esp)
  80054e:	00 
  80054f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800553:	89 3c 24             	mov    %edi,(%esp)
  800556:	e8 33 03 00 00       	call   80088e <printfmt>
  80055b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80055e:	e9 96 fe ff ff       	jmp    8003f9 <vprintfmt+0x2c>
  800563:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800566:	89 c3                	mov    %eax,%ebx
  800568:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80056b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80056e:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800571:	8b 45 14             	mov    0x14(%ebp),%eax
  800574:	8d 50 04             	lea    0x4(%eax),%edx
  800577:	89 55 14             	mov    %edx,0x14(%ebp)
  80057a:	8b 00                	mov    (%eax),%eax
  80057c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80057f:	85 c0                	test   %eax,%eax
  800581:	b8 f8 13 80 00       	mov    $0x8013f8,%eax
  800586:	0f 45 45 c4          	cmovne -0x3c(%ebp),%eax
  80058a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80058d:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800591:	7e 06                	jle    800599 <vprintfmt+0x1cc>
  800593:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800597:	75 13                	jne    8005ac <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800599:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80059c:	0f be 02             	movsbl (%edx),%eax
  80059f:	85 c0                	test   %eax,%eax
  8005a1:	0f 85 9b 00 00 00    	jne    800642 <vprintfmt+0x275>
  8005a7:	e9 88 00 00 00       	jmp    800634 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ac:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005b0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  8005b3:	89 0c 24             	mov    %ecx,(%esp)
  8005b6:	e8 20 03 00 00       	call   8008db <strnlen>
  8005bb:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8005be:	29 c2                	sub    %eax,%edx
  8005c0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005c3:	85 d2                	test   %edx,%edx
  8005c5:	7e d2                	jle    800599 <vprintfmt+0x1cc>
					putch(padc, putdat);
  8005c7:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  8005cb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ce:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8005d1:	89 d3                	mov    %edx,%ebx
  8005d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005da:	89 04 24             	mov    %eax,(%esp)
  8005dd:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005df:	83 eb 01             	sub    $0x1,%ebx
  8005e2:	85 db                	test   %ebx,%ebx
  8005e4:	7f ed                	jg     8005d3 <vprintfmt+0x206>
  8005e6:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8005e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005f0:	eb a7                	jmp    800599 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005f2:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005f6:	74 1a                	je     800612 <vprintfmt+0x245>
  8005f8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005fb:	83 fa 5e             	cmp    $0x5e,%edx
  8005fe:	76 12                	jbe    800612 <vprintfmt+0x245>
					putch('?', putdat);
  800600:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800604:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80060b:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80060e:	66 90                	xchg   %ax,%ax
  800610:	eb 0a                	jmp    80061c <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800612:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800616:	89 04 24             	mov    %eax,(%esp)
  800619:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80061c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800620:	0f be 03             	movsbl (%ebx),%eax
  800623:	85 c0                	test   %eax,%eax
  800625:	74 05                	je     80062c <vprintfmt+0x25f>
  800627:	83 c3 01             	add    $0x1,%ebx
  80062a:	eb 29                	jmp    800655 <vprintfmt+0x288>
  80062c:	89 fe                	mov    %edi,%esi
  80062e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800631:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800634:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800638:	7f 2e                	jg     800668 <vprintfmt+0x29b>
  80063a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80063d:	e9 b7 fd ff ff       	jmp    8003f9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800642:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800645:	83 c2 01             	add    $0x1,%edx
  800648:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80064b:	89 f7                	mov    %esi,%edi
  80064d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800650:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800653:	89 d3                	mov    %edx,%ebx
  800655:	85 f6                	test   %esi,%esi
  800657:	78 99                	js     8005f2 <vprintfmt+0x225>
  800659:	83 ee 01             	sub    $0x1,%esi
  80065c:	79 94                	jns    8005f2 <vprintfmt+0x225>
  80065e:	89 fe                	mov    %edi,%esi
  800660:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800663:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800666:	eb cc                	jmp    800634 <vprintfmt+0x267>
  800668:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80066b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80066e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800672:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800679:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80067b:	83 eb 01             	sub    $0x1,%ebx
  80067e:	85 db                	test   %ebx,%ebx
  800680:	7f ec                	jg     80066e <vprintfmt+0x2a1>
  800682:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800685:	e9 6f fd ff ff       	jmp    8003f9 <vprintfmt+0x2c>
  80068a:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80068d:	83 f9 01             	cmp    $0x1,%ecx
  800690:	7e 16                	jle    8006a8 <vprintfmt+0x2db>
		return va_arg(*ap, long long);
  800692:	8b 45 14             	mov    0x14(%ebp),%eax
  800695:	8d 50 08             	lea    0x8(%eax),%edx
  800698:	89 55 14             	mov    %edx,0x14(%ebp)
  80069b:	8b 10                	mov    (%eax),%edx
  80069d:	8b 48 04             	mov    0x4(%eax),%ecx
  8006a0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006a3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006a6:	eb 32                	jmp    8006da <vprintfmt+0x30d>
	else if (lflag)
  8006a8:	85 c9                	test   %ecx,%ecx
  8006aa:	74 18                	je     8006c4 <vprintfmt+0x2f7>
		return va_arg(*ap, long);
  8006ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8006af:	8d 50 04             	lea    0x4(%eax),%edx
  8006b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006b5:	8b 00                	mov    (%eax),%eax
  8006b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006ba:	89 c1                	mov    %eax,%ecx
  8006bc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006bf:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006c2:	eb 16                	jmp    8006da <vprintfmt+0x30d>
	else
		return va_arg(*ap, int);
  8006c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cd:	8b 00                	mov    (%eax),%eax
  8006cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006d2:	89 c2                	mov    %eax,%edx
  8006d4:	c1 fa 1f             	sar    $0x1f,%edx
  8006d7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006da:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006dd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006e0:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8006e5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006e9:	0f 89 b8 00 00 00    	jns    8007a7 <vprintfmt+0x3da>
				putch('-', putdat);
  8006ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006f3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006fa:	ff d7                	call   *%edi
				num = -(long long) num;
  8006fc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006ff:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800702:	f7 d9                	neg    %ecx
  800704:	83 d3 00             	adc    $0x0,%ebx
  800707:	f7 db                	neg    %ebx
  800709:	b8 0a 00 00 00       	mov    $0xa,%eax
  80070e:	e9 94 00 00 00       	jmp    8007a7 <vprintfmt+0x3da>
  800713:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800716:	89 ca                	mov    %ecx,%edx
  800718:	8d 45 14             	lea    0x14(%ebp),%eax
  80071b:	e8 56 fc ff ff       	call   800376 <getuint>
  800720:	89 c1                	mov    %eax,%ecx
  800722:	89 d3                	mov    %edx,%ebx
  800724:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800729:	eb 7c                	jmp    8007a7 <vprintfmt+0x3da>
  80072b:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80072e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800732:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800739:	ff d7                	call   *%edi
			putch('X', putdat);
  80073b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80073f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800746:	ff d7                	call   *%edi
			putch('X', putdat);
  800748:	89 74 24 04          	mov    %esi,0x4(%esp)
  80074c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800753:	ff d7                	call   *%edi
  800755:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800758:	e9 9c fc ff ff       	jmp    8003f9 <vprintfmt+0x2c>
  80075d:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800760:	89 74 24 04          	mov    %esi,0x4(%esp)
  800764:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80076b:	ff d7                	call   *%edi
			putch('x', putdat);
  80076d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800771:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800778:	ff d7                	call   *%edi
			num = (unsigned long long)
  80077a:	8b 45 14             	mov    0x14(%ebp),%eax
  80077d:	8d 50 04             	lea    0x4(%eax),%edx
  800780:	89 55 14             	mov    %edx,0x14(%ebp)
  800783:	8b 08                	mov    (%eax),%ecx
  800785:	bb 00 00 00 00       	mov    $0x0,%ebx
  80078a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80078f:	eb 16                	jmp    8007a7 <vprintfmt+0x3da>
  800791:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800794:	89 ca                	mov    %ecx,%edx
  800796:	8d 45 14             	lea    0x14(%ebp),%eax
  800799:	e8 d8 fb ff ff       	call   800376 <getuint>
  80079e:	89 c1                	mov    %eax,%ecx
  8007a0:	89 d3                	mov    %edx,%ebx
  8007a2:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007a7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8007ab:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007b2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007b6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ba:	89 0c 24             	mov    %ecx,(%esp)
  8007bd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007c1:	89 f2                	mov    %esi,%edx
  8007c3:	89 f8                	mov    %edi,%eax
  8007c5:	e8 b6 fa ff ff       	call   800280 <printnum>
  8007ca:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8007cd:	e9 27 fc ff ff       	jmp    8003f9 <vprintfmt+0x2c>
  8007d2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007d5:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007d8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007dc:	89 14 24             	mov    %edx,(%esp)
  8007df:	ff d7                	call   *%edi
  8007e1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8007e4:	e9 10 fc ff ff       	jmp    8003f9 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8007e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007ed:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007f4:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007f6:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8007f9:	80 38 25             	cmpb   $0x25,(%eax)
  8007fc:	0f 84 f7 fb ff ff    	je     8003f9 <vprintfmt+0x2c>
  800802:	89 c3                	mov    %eax,%ebx
  800804:	eb f0                	jmp    8007f6 <vprintfmt+0x429>
				/* do nothing */;
			break;
		}
	}
}
  800806:	83 c4 5c             	add    $0x5c,%esp
  800809:	5b                   	pop    %ebx
  80080a:	5e                   	pop    %esi
  80080b:	5f                   	pop    %edi
  80080c:	5d                   	pop    %ebp
  80080d:	c3                   	ret    

0080080e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80080e:	55                   	push   %ebp
  80080f:	89 e5                	mov    %esp,%ebp
  800811:	83 ec 28             	sub    $0x28,%esp
  800814:	8b 45 08             	mov    0x8(%ebp),%eax
  800817:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80081a:	85 c0                	test   %eax,%eax
  80081c:	74 04                	je     800822 <vsnprintf+0x14>
  80081e:	85 d2                	test   %edx,%edx
  800820:	7f 07                	jg     800829 <vsnprintf+0x1b>
  800822:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800827:	eb 3b                	jmp    800864 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800829:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80082c:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800830:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800833:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80083a:	8b 45 14             	mov    0x14(%ebp),%eax
  80083d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800841:	8b 45 10             	mov    0x10(%ebp),%eax
  800844:	89 44 24 08          	mov    %eax,0x8(%esp)
  800848:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80084b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084f:	c7 04 24 b0 03 80 00 	movl   $0x8003b0,(%esp)
  800856:	e8 72 fb ff ff       	call   8003cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80085b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80085e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800861:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800864:	c9                   	leave  
  800865:	c3                   	ret    

00800866 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80086c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80086f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800873:	8b 45 10             	mov    0x10(%ebp),%eax
  800876:	89 44 24 08          	mov    %eax,0x8(%esp)
  80087a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800881:	8b 45 08             	mov    0x8(%ebp),%eax
  800884:	89 04 24             	mov    %eax,(%esp)
  800887:	e8 82 ff ff ff       	call   80080e <vsnprintf>
	va_end(ap);

	return rc;
}
  80088c:	c9                   	leave  
  80088d:	c3                   	ret    

0080088e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80088e:	55                   	push   %ebp
  80088f:	89 e5                	mov    %esp,%ebp
  800891:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800894:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800897:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80089b:	8b 45 10             	mov    0x10(%ebp),%eax
  80089e:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008a2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ac:	89 04 24             	mov    %eax,(%esp)
  8008af:	e8 19 fb ff ff       	call   8003cd <vprintfmt>
	va_end(ap);
}
  8008b4:	c9                   	leave  
  8008b5:	c3                   	ret    
  8008b6:	66 90                	xchg   %ax,%ax
  8008b8:	66 90                	xchg   %ax,%ax
  8008ba:	66 90                	xchg   %ax,%ax
  8008bc:	66 90                	xchg   %ax,%ax
  8008be:	66 90                	xchg   %ax,%ax

008008c0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008c0:	55                   	push   %ebp
  8008c1:	89 e5                	mov    %esp,%ebp
  8008c3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008cb:	80 3a 00             	cmpb   $0x0,(%edx)
  8008ce:	74 09                	je     8008d9 <strlen+0x19>
		n++;
  8008d0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008d3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008d7:	75 f7                	jne    8008d0 <strlen+0x10>
		n++;
	return n;
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	53                   	push   %ebx
  8008df:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8008e2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008e5:	85 c9                	test   %ecx,%ecx
  8008e7:	74 19                	je     800902 <strnlen+0x27>
  8008e9:	80 3b 00             	cmpb   $0x0,(%ebx)
  8008ec:	74 14                	je     800902 <strnlen+0x27>
  8008ee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008f3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008f6:	39 c8                	cmp    %ecx,%eax
  8008f8:	74 0d                	je     800907 <strnlen+0x2c>
  8008fa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8008fe:	75 f3                	jne    8008f3 <strnlen+0x18>
  800900:	eb 05                	jmp    800907 <strnlen+0x2c>
  800902:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800907:	5b                   	pop    %ebx
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	53                   	push   %ebx
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800914:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800919:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80091d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800920:	83 c2 01             	add    $0x1,%edx
  800923:	84 c9                	test   %cl,%cl
  800925:	75 f2                	jne    800919 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800927:	5b                   	pop    %ebx
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	53                   	push   %ebx
  80092e:	83 ec 08             	sub    $0x8,%esp
  800931:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800934:	89 1c 24             	mov    %ebx,(%esp)
  800937:	e8 84 ff ff ff       	call   8008c0 <strlen>
	strcpy(dst + len, src);
  80093c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800943:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800946:	89 04 24             	mov    %eax,(%esp)
  800949:	e8 bc ff ff ff       	call   80090a <strcpy>
	return dst;
}
  80094e:	89 d8                	mov    %ebx,%eax
  800950:	83 c4 08             	add    $0x8,%esp
  800953:	5b                   	pop    %ebx
  800954:	5d                   	pop    %ebp
  800955:	c3                   	ret    

00800956 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	56                   	push   %esi
  80095a:	53                   	push   %ebx
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800961:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800964:	85 f6                	test   %esi,%esi
  800966:	74 18                	je     800980 <strncpy+0x2a>
  800968:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80096d:	0f b6 1a             	movzbl (%edx),%ebx
  800970:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800973:	80 3a 01             	cmpb   $0x1,(%edx)
  800976:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800979:	83 c1 01             	add    $0x1,%ecx
  80097c:	39 ce                	cmp    %ecx,%esi
  80097e:	77 ed                	ja     80096d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800980:	5b                   	pop    %ebx
  800981:	5e                   	pop    %esi
  800982:	5d                   	pop    %ebp
  800983:	c3                   	ret    

00800984 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800984:	55                   	push   %ebp
  800985:	89 e5                	mov    %esp,%ebp
  800987:	56                   	push   %esi
  800988:	53                   	push   %ebx
  800989:	8b 75 08             	mov    0x8(%ebp),%esi
  80098c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800992:	89 f0                	mov    %esi,%eax
  800994:	85 c9                	test   %ecx,%ecx
  800996:	74 27                	je     8009bf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800998:	83 e9 01             	sub    $0x1,%ecx
  80099b:	74 1d                	je     8009ba <strlcpy+0x36>
  80099d:	0f b6 1a             	movzbl (%edx),%ebx
  8009a0:	84 db                	test   %bl,%bl
  8009a2:	74 16                	je     8009ba <strlcpy+0x36>
			*dst++ = *src++;
  8009a4:	88 18                	mov    %bl,(%eax)
  8009a6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009a9:	83 e9 01             	sub    $0x1,%ecx
  8009ac:	74 0e                	je     8009bc <strlcpy+0x38>
			*dst++ = *src++;
  8009ae:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009b1:	0f b6 1a             	movzbl (%edx),%ebx
  8009b4:	84 db                	test   %bl,%bl
  8009b6:	75 ec                	jne    8009a4 <strlcpy+0x20>
  8009b8:	eb 02                	jmp    8009bc <strlcpy+0x38>
  8009ba:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009bc:	c6 00 00             	movb   $0x0,(%eax)
  8009bf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009c1:	5b                   	pop    %ebx
  8009c2:	5e                   	pop    %esi
  8009c3:	5d                   	pop    %ebp
  8009c4:	c3                   	ret    

008009c5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009cb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ce:	0f b6 01             	movzbl (%ecx),%eax
  8009d1:	84 c0                	test   %al,%al
  8009d3:	74 15                	je     8009ea <strcmp+0x25>
  8009d5:	3a 02                	cmp    (%edx),%al
  8009d7:	75 11                	jne    8009ea <strcmp+0x25>
		p++, q++;
  8009d9:	83 c1 01             	add    $0x1,%ecx
  8009dc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009df:	0f b6 01             	movzbl (%ecx),%eax
  8009e2:	84 c0                	test   %al,%al
  8009e4:	74 04                	je     8009ea <strcmp+0x25>
  8009e6:	3a 02                	cmp    (%edx),%al
  8009e8:	74 ef                	je     8009d9 <strcmp+0x14>
  8009ea:	0f b6 c0             	movzbl %al,%eax
  8009ed:	0f b6 12             	movzbl (%edx),%edx
  8009f0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009f2:	5d                   	pop    %ebp
  8009f3:	c3                   	ret    

008009f4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009f4:	55                   	push   %ebp
  8009f5:	89 e5                	mov    %esp,%ebp
  8009f7:	53                   	push   %ebx
  8009f8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009fe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a01:	85 c0                	test   %eax,%eax
  800a03:	74 23                	je     800a28 <strncmp+0x34>
  800a05:	0f b6 1a             	movzbl (%edx),%ebx
  800a08:	84 db                	test   %bl,%bl
  800a0a:	74 25                	je     800a31 <strncmp+0x3d>
  800a0c:	3a 19                	cmp    (%ecx),%bl
  800a0e:	75 21                	jne    800a31 <strncmp+0x3d>
  800a10:	83 e8 01             	sub    $0x1,%eax
  800a13:	74 13                	je     800a28 <strncmp+0x34>
		n--, p++, q++;
  800a15:	83 c2 01             	add    $0x1,%edx
  800a18:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a1b:	0f b6 1a             	movzbl (%edx),%ebx
  800a1e:	84 db                	test   %bl,%bl
  800a20:	74 0f                	je     800a31 <strncmp+0x3d>
  800a22:	3a 19                	cmp    (%ecx),%bl
  800a24:	74 ea                	je     800a10 <strncmp+0x1c>
  800a26:	eb 09                	jmp    800a31 <strncmp+0x3d>
  800a28:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a2d:	5b                   	pop    %ebx
  800a2e:	5d                   	pop    %ebp
  800a2f:	90                   	nop
  800a30:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a31:	0f b6 02             	movzbl (%edx),%eax
  800a34:	0f b6 11             	movzbl (%ecx),%edx
  800a37:	29 d0                	sub    %edx,%eax
  800a39:	eb f2                	jmp    800a2d <strncmp+0x39>

00800a3b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a3b:	55                   	push   %ebp
  800a3c:	89 e5                	mov    %esp,%ebp
  800a3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a45:	0f b6 10             	movzbl (%eax),%edx
  800a48:	84 d2                	test   %dl,%dl
  800a4a:	74 18                	je     800a64 <strchr+0x29>
		if (*s == c)
  800a4c:	38 ca                	cmp    %cl,%dl
  800a4e:	75 0a                	jne    800a5a <strchr+0x1f>
  800a50:	eb 17                	jmp    800a69 <strchr+0x2e>
  800a52:	38 ca                	cmp    %cl,%dl
  800a54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a58:	74 0f                	je     800a69 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a5a:	83 c0 01             	add    $0x1,%eax
  800a5d:	0f b6 10             	movzbl (%eax),%edx
  800a60:	84 d2                	test   %dl,%dl
  800a62:	75 ee                	jne    800a52 <strchr+0x17>
  800a64:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a69:	5d                   	pop    %ebp
  800a6a:	c3                   	ret    

00800a6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a75:	0f b6 10             	movzbl (%eax),%edx
  800a78:	84 d2                	test   %dl,%dl
  800a7a:	74 18                	je     800a94 <strfind+0x29>
		if (*s == c)
  800a7c:	38 ca                	cmp    %cl,%dl
  800a7e:	75 0a                	jne    800a8a <strfind+0x1f>
  800a80:	eb 12                	jmp    800a94 <strfind+0x29>
  800a82:	38 ca                	cmp    %cl,%dl
  800a84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a88:	74 0a                	je     800a94 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a8a:	83 c0 01             	add    $0x1,%eax
  800a8d:	0f b6 10             	movzbl (%eax),%edx
  800a90:	84 d2                	test   %dl,%dl
  800a92:	75 ee                	jne    800a82 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a94:	5d                   	pop    %ebp
  800a95:	c3                   	ret    

00800a96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a96:	55                   	push   %ebp
  800a97:	89 e5                	mov    %esp,%ebp
  800a99:	83 ec 0c             	sub    $0xc,%esp
  800a9c:	89 1c 24             	mov    %ebx,(%esp)
  800a9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800aa3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800aa7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aaa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ab0:	85 c9                	test   %ecx,%ecx
  800ab2:	74 30                	je     800ae4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ab4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aba:	75 25                	jne    800ae1 <memset+0x4b>
  800abc:	f6 c1 03             	test   $0x3,%cl
  800abf:	75 20                	jne    800ae1 <memset+0x4b>
		c &= 0xFF;
  800ac1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ac4:	89 d3                	mov    %edx,%ebx
  800ac6:	c1 e3 08             	shl    $0x8,%ebx
  800ac9:	89 d6                	mov    %edx,%esi
  800acb:	c1 e6 18             	shl    $0x18,%esi
  800ace:	89 d0                	mov    %edx,%eax
  800ad0:	c1 e0 10             	shl    $0x10,%eax
  800ad3:	09 f0                	or     %esi,%eax
  800ad5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800ad7:	09 d8                	or     %ebx,%eax
  800ad9:	c1 e9 02             	shr    $0x2,%ecx
  800adc:	fc                   	cld    
  800add:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800adf:	eb 03                	jmp    800ae4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800ae1:	fc                   	cld    
  800ae2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800ae4:	89 f8                	mov    %edi,%eax
  800ae6:	8b 1c 24             	mov    (%esp),%ebx
  800ae9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800aed:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800af1:	89 ec                	mov    %ebp,%esp
  800af3:	5d                   	pop    %ebp
  800af4:	c3                   	ret    

00800af5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800af5:	55                   	push   %ebp
  800af6:	89 e5                	mov    %esp,%ebp
  800af8:	83 ec 08             	sub    $0x8,%esp
  800afb:	89 34 24             	mov    %esi,(%esp)
  800afe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b02:	8b 45 08             	mov    0x8(%ebp),%eax
  800b05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800b08:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b0b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b0d:	39 c6                	cmp    %eax,%esi
  800b0f:	73 35                	jae    800b46 <memmove+0x51>
  800b11:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b14:	39 d0                	cmp    %edx,%eax
  800b16:	73 2e                	jae    800b46 <memmove+0x51>
		s += n;
		d += n;
  800b18:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b1a:	f6 c2 03             	test   $0x3,%dl
  800b1d:	75 1b                	jne    800b3a <memmove+0x45>
  800b1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b25:	75 13                	jne    800b3a <memmove+0x45>
  800b27:	f6 c1 03             	test   $0x3,%cl
  800b2a:	75 0e                	jne    800b3a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800b2c:	83 ef 04             	sub    $0x4,%edi
  800b2f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b32:	c1 e9 02             	shr    $0x2,%ecx
  800b35:	fd                   	std    
  800b36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b38:	eb 09                	jmp    800b43 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b3a:	83 ef 01             	sub    $0x1,%edi
  800b3d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b40:	fd                   	std    
  800b41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b43:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b44:	eb 20                	jmp    800b66 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b4c:	75 15                	jne    800b63 <memmove+0x6e>
  800b4e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b54:	75 0d                	jne    800b63 <memmove+0x6e>
  800b56:	f6 c1 03             	test   $0x3,%cl
  800b59:	75 08                	jne    800b63 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800b5b:	c1 e9 02             	shr    $0x2,%ecx
  800b5e:	fc                   	cld    
  800b5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b61:	eb 03                	jmp    800b66 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b63:	fc                   	cld    
  800b64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b66:	8b 34 24             	mov    (%esp),%esi
  800b69:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b6d:	89 ec                	mov    %ebp,%esp
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b71:	55                   	push   %ebp
  800b72:	89 e5                	mov    %esp,%ebp
  800b74:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b77:	8b 45 10             	mov    0x10(%ebp),%eax
  800b7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b85:	8b 45 08             	mov    0x8(%ebp),%eax
  800b88:	89 04 24             	mov    %eax,(%esp)
  800b8b:	e8 65 ff ff ff       	call   800af5 <memmove>
}
  800b90:	c9                   	leave  
  800b91:	c3                   	ret    

00800b92 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b92:	55                   	push   %ebp
  800b93:	89 e5                	mov    %esp,%ebp
  800b95:	57                   	push   %edi
  800b96:	56                   	push   %esi
  800b97:	53                   	push   %ebx
  800b98:	8b 75 08             	mov    0x8(%ebp),%esi
  800b9b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ba1:	85 c9                	test   %ecx,%ecx
  800ba3:	74 36                	je     800bdb <memcmp+0x49>
		if (*s1 != *s2)
  800ba5:	0f b6 06             	movzbl (%esi),%eax
  800ba8:	0f b6 1f             	movzbl (%edi),%ebx
  800bab:	38 d8                	cmp    %bl,%al
  800bad:	74 20                	je     800bcf <memcmp+0x3d>
  800baf:	eb 14                	jmp    800bc5 <memcmp+0x33>
  800bb1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800bb6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800bbb:	83 c2 01             	add    $0x1,%edx
  800bbe:	83 e9 01             	sub    $0x1,%ecx
  800bc1:	38 d8                	cmp    %bl,%al
  800bc3:	74 12                	je     800bd7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800bc5:	0f b6 c0             	movzbl %al,%eax
  800bc8:	0f b6 db             	movzbl %bl,%ebx
  800bcb:	29 d8                	sub    %ebx,%eax
  800bcd:	eb 11                	jmp    800be0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bcf:	83 e9 01             	sub    $0x1,%ecx
  800bd2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bd7:	85 c9                	test   %ecx,%ecx
  800bd9:	75 d6                	jne    800bb1 <memcmp+0x1f>
  800bdb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800be0:	5b                   	pop    %ebx
  800be1:	5e                   	pop    %esi
  800be2:	5f                   	pop    %edi
  800be3:	5d                   	pop    %ebp
  800be4:	c3                   	ret    

00800be5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800be5:	55                   	push   %ebp
  800be6:	89 e5                	mov    %esp,%ebp
  800be8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800beb:	89 c2                	mov    %eax,%edx
  800bed:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800bf0:	39 d0                	cmp    %edx,%eax
  800bf2:	73 15                	jae    800c09 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800bf4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800bf8:	38 08                	cmp    %cl,(%eax)
  800bfa:	75 06                	jne    800c02 <memfind+0x1d>
  800bfc:	eb 0b                	jmp    800c09 <memfind+0x24>
  800bfe:	38 08                	cmp    %cl,(%eax)
  800c00:	74 07                	je     800c09 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c02:	83 c0 01             	add    $0x1,%eax
  800c05:	39 c2                	cmp    %eax,%edx
  800c07:	77 f5                	ja     800bfe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c09:	5d                   	pop    %ebp
  800c0a:	c3                   	ret    

00800c0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c0b:	55                   	push   %ebp
  800c0c:	89 e5                	mov    %esp,%ebp
  800c0e:	57                   	push   %edi
  800c0f:	56                   	push   %esi
  800c10:	53                   	push   %ebx
  800c11:	83 ec 04             	sub    $0x4,%esp
  800c14:	8b 55 08             	mov    0x8(%ebp),%edx
  800c17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c1a:	0f b6 02             	movzbl (%edx),%eax
  800c1d:	3c 20                	cmp    $0x20,%al
  800c1f:	74 04                	je     800c25 <strtol+0x1a>
  800c21:	3c 09                	cmp    $0x9,%al
  800c23:	75 0e                	jne    800c33 <strtol+0x28>
		s++;
  800c25:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c28:	0f b6 02             	movzbl (%edx),%eax
  800c2b:	3c 20                	cmp    $0x20,%al
  800c2d:	74 f6                	je     800c25 <strtol+0x1a>
  800c2f:	3c 09                	cmp    $0x9,%al
  800c31:	74 f2                	je     800c25 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c33:	3c 2b                	cmp    $0x2b,%al
  800c35:	75 0c                	jne    800c43 <strtol+0x38>
		s++;
  800c37:	83 c2 01             	add    $0x1,%edx
  800c3a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c41:	eb 15                	jmp    800c58 <strtol+0x4d>
	else if (*s == '-')
  800c43:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c4a:	3c 2d                	cmp    $0x2d,%al
  800c4c:	75 0a                	jne    800c58 <strtol+0x4d>
		s++, neg = 1;
  800c4e:	83 c2 01             	add    $0x1,%edx
  800c51:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c58:	85 db                	test   %ebx,%ebx
  800c5a:	0f 94 c0             	sete   %al
  800c5d:	74 05                	je     800c64 <strtol+0x59>
  800c5f:	83 fb 10             	cmp    $0x10,%ebx
  800c62:	75 18                	jne    800c7c <strtol+0x71>
  800c64:	80 3a 30             	cmpb   $0x30,(%edx)
  800c67:	75 13                	jne    800c7c <strtol+0x71>
  800c69:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c6d:	8d 76 00             	lea    0x0(%esi),%esi
  800c70:	75 0a                	jne    800c7c <strtol+0x71>
		s += 2, base = 16;
  800c72:	83 c2 02             	add    $0x2,%edx
  800c75:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c7a:	eb 15                	jmp    800c91 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c7c:	84 c0                	test   %al,%al
  800c7e:	66 90                	xchg   %ax,%ax
  800c80:	74 0f                	je     800c91 <strtol+0x86>
  800c82:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c87:	80 3a 30             	cmpb   $0x30,(%edx)
  800c8a:	75 05                	jne    800c91 <strtol+0x86>
		s++, base = 8;
  800c8c:	83 c2 01             	add    $0x1,%edx
  800c8f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c91:	b8 00 00 00 00       	mov    $0x0,%eax
  800c96:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c98:	0f b6 0a             	movzbl (%edx),%ecx
  800c9b:	89 cf                	mov    %ecx,%edi
  800c9d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800ca0:	80 fb 09             	cmp    $0x9,%bl
  800ca3:	77 08                	ja     800cad <strtol+0xa2>
			dig = *s - '0';
  800ca5:	0f be c9             	movsbl %cl,%ecx
  800ca8:	83 e9 30             	sub    $0x30,%ecx
  800cab:	eb 1e                	jmp    800ccb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800cad:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800cb0:	80 fb 19             	cmp    $0x19,%bl
  800cb3:	77 08                	ja     800cbd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800cb5:	0f be c9             	movsbl %cl,%ecx
  800cb8:	83 e9 57             	sub    $0x57,%ecx
  800cbb:	eb 0e                	jmp    800ccb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800cbd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800cc0:	80 fb 19             	cmp    $0x19,%bl
  800cc3:	77 15                	ja     800cda <strtol+0xcf>
			dig = *s - 'A' + 10;
  800cc5:	0f be c9             	movsbl %cl,%ecx
  800cc8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ccb:	39 f1                	cmp    %esi,%ecx
  800ccd:	7d 0b                	jge    800cda <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800ccf:	83 c2 01             	add    $0x1,%edx
  800cd2:	0f af c6             	imul   %esi,%eax
  800cd5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800cd8:	eb be                	jmp    800c98 <strtol+0x8d>
  800cda:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800cdc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ce0:	74 05                	je     800ce7 <strtol+0xdc>
		*endptr = (char *) s;
  800ce2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ce5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ce7:	89 ca                	mov    %ecx,%edx
  800ce9:	f7 da                	neg    %edx
  800ceb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800cef:	0f 45 c2             	cmovne %edx,%eax
}
  800cf2:	83 c4 04             	add    $0x4,%esp
  800cf5:	5b                   	pop    %ebx
  800cf6:	5e                   	pop    %esi
  800cf7:	5f                   	pop    %edi
  800cf8:	5d                   	pop    %ebp
  800cf9:	c3                   	ret    

00800cfa <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	83 ec 0c             	sub    $0xc,%esp
  800d00:	89 1c 24             	mov    %ebx,(%esp)
  800d03:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d07:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d0b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d10:	b8 01 00 00 00       	mov    $0x1,%eax
  800d15:	89 d1                	mov    %edx,%ecx
  800d17:	89 d3                	mov    %edx,%ebx
  800d19:	89 d7                	mov    %edx,%edi
  800d1b:	89 d6                	mov    %edx,%esi
  800d1d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d1f:	8b 1c 24             	mov    (%esp),%ebx
  800d22:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d26:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d2a:	89 ec                	mov    %ebp,%esp
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
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
  800d3f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d44:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d47:	8b 55 08             	mov    0x8(%ebp),%edx
  800d4a:	89 c3                	mov    %eax,%ebx
  800d4c:	89 c7                	mov    %eax,%edi
  800d4e:	89 c6                	mov    %eax,%esi
  800d50:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d52:	8b 1c 24             	mov    (%esp),%ebx
  800d55:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d59:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d5d:	89 ec                	mov    %ebp,%esp
  800d5f:	5d                   	pop    %ebp
  800d60:	c3                   	ret    

00800d61 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d61:	55                   	push   %ebp
  800d62:	89 e5                	mov    %esp,%ebp
  800d64:	83 ec 38             	sub    $0x38,%esp
  800d67:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d6a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d6d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d70:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d75:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d7a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7d:	89 cb                	mov    %ecx,%ebx
  800d7f:	89 cf                	mov    %ecx,%edi
  800d81:	89 ce                	mov    %ecx,%esi
  800d83:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d85:	85 c0                	test   %eax,%eax
  800d87:	7e 28                	jle    800db1 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d89:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d8d:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d94:	00 
  800d95:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800d9c:	00 
  800d9d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800da4:	00 
  800da5:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800dac:	e8 b0 f3 ff ff       	call   800161 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800db1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800db4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800db7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dba:	89 ec                	mov    %ebp,%esp
  800dbc:	5d                   	pop    %ebp
  800dbd:	c3                   	ret    

00800dbe <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
  800dc1:	83 ec 0c             	sub    $0xc,%esp
  800dc4:	89 1c 24             	mov    %ebx,(%esp)
  800dc7:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dcb:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dcf:	be 00 00 00 00       	mov    $0x0,%esi
  800dd4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800dd9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800ddc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ddf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800de2:	8b 55 08             	mov    0x8(%ebp),%edx
  800de5:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800de7:	8b 1c 24             	mov    (%esp),%ebx
  800dea:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dee:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800df2:	89 ec                	mov    %ebp,%esp
  800df4:	5d                   	pop    %ebp
  800df5:	c3                   	ret    

00800df6 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800df6:	55                   	push   %ebp
  800df7:	89 e5                	mov    %esp,%ebp
  800df9:	83 ec 38             	sub    $0x38,%esp
  800dfc:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dff:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e02:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e05:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e0a:	b8 09 00 00 00       	mov    $0x9,%eax
  800e0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e12:	8b 55 08             	mov    0x8(%ebp),%edx
  800e15:	89 df                	mov    %ebx,%edi
  800e17:	89 de                	mov    %ebx,%esi
  800e19:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e1b:	85 c0                	test   %eax,%eax
  800e1d:	7e 28                	jle    800e47 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e1f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e23:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e2a:	00 
  800e2b:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800e32:	00 
  800e33:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e3a:	00 
  800e3b:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800e42:	e8 1a f3 ff ff       	call   800161 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e47:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e4a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e4d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e50:	89 ec                	mov    %ebp,%esp
  800e52:	5d                   	pop    %ebp
  800e53:	c3                   	ret    

00800e54 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e54:	55                   	push   %ebp
  800e55:	89 e5                	mov    %esp,%ebp
  800e57:	83 ec 38             	sub    $0x38,%esp
  800e5a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e5d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e60:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e63:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e68:	b8 08 00 00 00       	mov    $0x8,%eax
  800e6d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e70:	8b 55 08             	mov    0x8(%ebp),%edx
  800e73:	89 df                	mov    %ebx,%edi
  800e75:	89 de                	mov    %ebx,%esi
  800e77:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e79:	85 c0                	test   %eax,%eax
  800e7b:	7e 28                	jle    800ea5 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e7d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e81:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e88:	00 
  800e89:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800e90:	00 
  800e91:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e98:	00 
  800e99:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800ea0:	e8 bc f2 ff ff       	call   800161 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ea5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ea8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eab:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800eae:	89 ec                	mov    %ebp,%esp
  800eb0:	5d                   	pop    %ebp
  800eb1:	c3                   	ret    

00800eb2 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800eb2:	55                   	push   %ebp
  800eb3:	89 e5                	mov    %esp,%ebp
  800eb5:	83 ec 38             	sub    $0x38,%esp
  800eb8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ebb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ebe:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ec6:	b8 06 00 00 00       	mov    $0x6,%eax
  800ecb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ece:	8b 55 08             	mov    0x8(%ebp),%edx
  800ed1:	89 df                	mov    %ebx,%edi
  800ed3:	89 de                	mov    %ebx,%esi
  800ed5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed7:	85 c0                	test   %eax,%eax
  800ed9:	7e 28                	jle    800f03 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800edb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800edf:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800ee6:	00 
  800ee7:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800eee:	00 
  800eef:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef6:	00 
  800ef7:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800efe:	e8 5e f2 ff ff       	call   800161 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f03:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f06:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f09:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f0c:	89 ec                	mov    %ebp,%esp
  800f0e:	5d                   	pop    %ebp
  800f0f:	c3                   	ret    

00800f10 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f10:	55                   	push   %ebp
  800f11:	89 e5                	mov    %esp,%ebp
  800f13:	83 ec 38             	sub    $0x38,%esp
  800f16:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f19:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f1c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1f:	b8 05 00 00 00       	mov    $0x5,%eax
  800f24:	8b 75 18             	mov    0x18(%ebp),%esi
  800f27:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f2a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f30:	8b 55 08             	mov    0x8(%ebp),%edx
  800f33:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f35:	85 c0                	test   %eax,%eax
  800f37:	7e 28                	jle    800f61 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f39:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f3d:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f44:	00 
  800f45:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800f4c:	00 
  800f4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f54:	00 
  800f55:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800f5c:	e8 00 f2 ff ff       	call   800161 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f61:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f64:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f67:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f6a:	89 ec                	mov    %ebp,%esp
  800f6c:	5d                   	pop    %ebp
  800f6d:	c3                   	ret    

00800f6e <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f6e:	55                   	push   %ebp
  800f6f:	89 e5                	mov    %esp,%ebp
  800f71:	83 ec 38             	sub    $0x38,%esp
  800f74:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f77:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f7a:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f7d:	be 00 00 00 00       	mov    $0x0,%esi
  800f82:	b8 04 00 00 00       	mov    $0x4,%eax
  800f87:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f8a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f8d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f90:	89 f7                	mov    %esi,%edi
  800f92:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f94:	85 c0                	test   %eax,%eax
  800f96:	7e 28                	jle    800fc0 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f98:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f9c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800fa3:	00 
  800fa4:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  800fab:	00 
  800fac:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fb3:	00 
  800fb4:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  800fbb:	e8 a1 f1 ff ff       	call   800161 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fc0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fc3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fc6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fc9:	89 ec                	mov    %ebp,%esp
  800fcb:	5d                   	pop    %ebp
  800fcc:	c3                   	ret    

00800fcd <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	83 ec 0c             	sub    $0xc,%esp
  800fd3:	89 1c 24             	mov    %ebx,(%esp)
  800fd6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fda:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fde:	ba 00 00 00 00       	mov    $0x0,%edx
  800fe3:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fe8:	89 d1                	mov    %edx,%ecx
  800fea:	89 d3                	mov    %edx,%ebx
  800fec:	89 d7                	mov    %edx,%edi
  800fee:	89 d6                	mov    %edx,%esi
  800ff0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800ff2:	8b 1c 24             	mov    (%esp),%ebx
  800ff5:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ff9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ffd:	89 ec                	mov    %ebp,%esp
  800fff:	5d                   	pop    %ebp
  801000:	c3                   	ret    

00801001 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801001:	55                   	push   %ebp
  801002:	89 e5                	mov    %esp,%ebp
  801004:	83 ec 0c             	sub    $0xc,%esp
  801007:	89 1c 24             	mov    %ebx,(%esp)
  80100a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80100e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801012:	ba 00 00 00 00       	mov    $0x0,%edx
  801017:	b8 02 00 00 00       	mov    $0x2,%eax
  80101c:	89 d1                	mov    %edx,%ecx
  80101e:	89 d3                	mov    %edx,%ebx
  801020:	89 d7                	mov    %edx,%edi
  801022:	89 d6                	mov    %edx,%esi
  801024:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801026:	8b 1c 24             	mov    (%esp),%ebx
  801029:	8b 74 24 04          	mov    0x4(%esp),%esi
  80102d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801031:	89 ec                	mov    %ebp,%esp
  801033:	5d                   	pop    %ebp
  801034:	c3                   	ret    

00801035 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	83 ec 38             	sub    $0x38,%esp
  80103b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80103e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801041:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801044:	b9 00 00 00 00       	mov    $0x0,%ecx
  801049:	b8 03 00 00 00       	mov    $0x3,%eax
  80104e:	8b 55 08             	mov    0x8(%ebp),%edx
  801051:	89 cb                	mov    %ecx,%ebx
  801053:	89 cf                	mov    %ecx,%edi
  801055:	89 ce                	mov    %ecx,%esi
  801057:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801059:	85 c0                	test   %eax,%eax
  80105b:	7e 28                	jle    801085 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80105d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801061:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801068:	00 
  801069:	c7 44 24 08 24 16 80 	movl   $0x801624,0x8(%esp)
  801070:	00 
  801071:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801078:	00 
  801079:	c7 04 24 41 16 80 00 	movl   $0x801641,(%esp)
  801080:	e8 dc f0 ff ff       	call   800161 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801085:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801088:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80108b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80108e:	89 ec                	mov    %ebp,%esp
  801090:	5d                   	pop    %ebp
  801091:	c3                   	ret    

00801092 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801092:	55                   	push   %ebp
  801093:	89 e5                	mov    %esp,%ebp
  801095:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801098:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  80109f:	75 1c                	jne    8010bd <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  8010a1:	c7 44 24 08 50 16 80 	movl   $0x801650,0x8(%esp)
  8010a8:	00 
  8010a9:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  8010b0:	00 
  8010b1:	c7 04 24 74 16 80 00 	movl   $0x801674,(%esp)
  8010b8:	e8 a4 f0 ff ff       	call   800161 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8010bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c0:	a3 08 20 80 00       	mov    %eax,0x802008
}
  8010c5:	c9                   	leave  
  8010c6:	c3                   	ret    
  8010c7:	66 90                	xchg   %ax,%ax
  8010c9:	66 90                	xchg   %ax,%ax
  8010cb:	66 90                	xchg   %ax,%ax
  8010cd:	66 90                	xchg   %ax,%ax
  8010cf:	90                   	nop

008010d0 <__udivdi3>:
  8010d0:	55                   	push   %ebp
  8010d1:	89 e5                	mov    %esp,%ebp
  8010d3:	57                   	push   %edi
  8010d4:	56                   	push   %esi
  8010d5:	83 ec 10             	sub    $0x10,%esp
  8010d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8010db:	8b 55 08             	mov    0x8(%ebp),%edx
  8010de:	8b 75 10             	mov    0x10(%ebp),%esi
  8010e1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8010e9:	75 35                	jne    801120 <__udivdi3+0x50>
  8010eb:	39 fe                	cmp    %edi,%esi
  8010ed:	77 61                	ja     801150 <__udivdi3+0x80>
  8010ef:	85 f6                	test   %esi,%esi
  8010f1:	75 0b                	jne    8010fe <__udivdi3+0x2e>
  8010f3:	b8 01 00 00 00       	mov    $0x1,%eax
  8010f8:	31 d2                	xor    %edx,%edx
  8010fa:	f7 f6                	div    %esi
  8010fc:	89 c6                	mov    %eax,%esi
  8010fe:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801101:	31 d2                	xor    %edx,%edx
  801103:	89 f8                	mov    %edi,%eax
  801105:	f7 f6                	div    %esi
  801107:	89 c7                	mov    %eax,%edi
  801109:	89 c8                	mov    %ecx,%eax
  80110b:	f7 f6                	div    %esi
  80110d:	89 c1                	mov    %eax,%ecx
  80110f:	89 fa                	mov    %edi,%edx
  801111:	89 c8                	mov    %ecx,%eax
  801113:	83 c4 10             	add    $0x10,%esp
  801116:	5e                   	pop    %esi
  801117:	5f                   	pop    %edi
  801118:	5d                   	pop    %ebp
  801119:	c3                   	ret    
  80111a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801120:	39 f8                	cmp    %edi,%eax
  801122:	77 1c                	ja     801140 <__udivdi3+0x70>
  801124:	0f bd d0             	bsr    %eax,%edx
  801127:	83 f2 1f             	xor    $0x1f,%edx
  80112a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80112d:	75 39                	jne    801168 <__udivdi3+0x98>
  80112f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801132:	0f 86 a0 00 00 00    	jbe    8011d8 <__udivdi3+0x108>
  801138:	39 f8                	cmp    %edi,%eax
  80113a:	0f 82 98 00 00 00    	jb     8011d8 <__udivdi3+0x108>
  801140:	31 ff                	xor    %edi,%edi
  801142:	31 c9                	xor    %ecx,%ecx
  801144:	89 c8                	mov    %ecx,%eax
  801146:	89 fa                	mov    %edi,%edx
  801148:	83 c4 10             	add    $0x10,%esp
  80114b:	5e                   	pop    %esi
  80114c:	5f                   	pop    %edi
  80114d:	5d                   	pop    %ebp
  80114e:	c3                   	ret    
  80114f:	90                   	nop
  801150:	89 d1                	mov    %edx,%ecx
  801152:	89 fa                	mov    %edi,%edx
  801154:	89 c8                	mov    %ecx,%eax
  801156:	31 ff                	xor    %edi,%edi
  801158:	f7 f6                	div    %esi
  80115a:	89 c1                	mov    %eax,%ecx
  80115c:	89 fa                	mov    %edi,%edx
  80115e:	89 c8                	mov    %ecx,%eax
  801160:	83 c4 10             	add    $0x10,%esp
  801163:	5e                   	pop    %esi
  801164:	5f                   	pop    %edi
  801165:	5d                   	pop    %ebp
  801166:	c3                   	ret    
  801167:	90                   	nop
  801168:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80116c:	89 f2                	mov    %esi,%edx
  80116e:	d3 e0                	shl    %cl,%eax
  801170:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801173:	b8 20 00 00 00       	mov    $0x20,%eax
  801178:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80117b:	89 c1                	mov    %eax,%ecx
  80117d:	d3 ea                	shr    %cl,%edx
  80117f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801183:	0b 55 ec             	or     -0x14(%ebp),%edx
  801186:	d3 e6                	shl    %cl,%esi
  801188:	89 c1                	mov    %eax,%ecx
  80118a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80118d:	89 fe                	mov    %edi,%esi
  80118f:	d3 ee                	shr    %cl,%esi
  801191:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801195:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801198:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80119b:	d3 e7                	shl    %cl,%edi
  80119d:	89 c1                	mov    %eax,%ecx
  80119f:	d3 ea                	shr    %cl,%edx
  8011a1:	09 d7                	or     %edx,%edi
  8011a3:	89 f2                	mov    %esi,%edx
  8011a5:	89 f8                	mov    %edi,%eax
  8011a7:	f7 75 ec             	divl   -0x14(%ebp)
  8011aa:	89 d6                	mov    %edx,%esi
  8011ac:	89 c7                	mov    %eax,%edi
  8011ae:	f7 65 e8             	mull   -0x18(%ebp)
  8011b1:	39 d6                	cmp    %edx,%esi
  8011b3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8011b6:	72 30                	jb     8011e8 <__udivdi3+0x118>
  8011b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011bb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011bf:	d3 e2                	shl    %cl,%edx
  8011c1:	39 c2                	cmp    %eax,%edx
  8011c3:	73 05                	jae    8011ca <__udivdi3+0xfa>
  8011c5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8011c8:	74 1e                	je     8011e8 <__udivdi3+0x118>
  8011ca:	89 f9                	mov    %edi,%ecx
  8011cc:	31 ff                	xor    %edi,%edi
  8011ce:	e9 71 ff ff ff       	jmp    801144 <__udivdi3+0x74>
  8011d3:	90                   	nop
  8011d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011d8:	31 ff                	xor    %edi,%edi
  8011da:	b9 01 00 00 00       	mov    $0x1,%ecx
  8011df:	e9 60 ff ff ff       	jmp    801144 <__udivdi3+0x74>
  8011e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011e8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8011eb:	31 ff                	xor    %edi,%edi
  8011ed:	89 c8                	mov    %ecx,%eax
  8011ef:	89 fa                	mov    %edi,%edx
  8011f1:	83 c4 10             	add    $0x10,%esp
  8011f4:	5e                   	pop    %esi
  8011f5:	5f                   	pop    %edi
  8011f6:	5d                   	pop    %ebp
  8011f7:	c3                   	ret    
  8011f8:	66 90                	xchg   %ax,%ax
  8011fa:	66 90                	xchg   %ax,%ax
  8011fc:	66 90                	xchg   %ax,%ax
  8011fe:	66 90                	xchg   %ax,%ax

00801200 <__umoddi3>:
  801200:	55                   	push   %ebp
  801201:	89 e5                	mov    %esp,%ebp
  801203:	57                   	push   %edi
  801204:	56                   	push   %esi
  801205:	83 ec 20             	sub    $0x20,%esp
  801208:	8b 55 14             	mov    0x14(%ebp),%edx
  80120b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801211:	8b 75 0c             	mov    0xc(%ebp),%esi
  801214:	85 d2                	test   %edx,%edx
  801216:	89 c8                	mov    %ecx,%eax
  801218:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80121b:	75 13                	jne    801230 <__umoddi3+0x30>
  80121d:	39 f7                	cmp    %esi,%edi
  80121f:	76 3f                	jbe    801260 <__umoddi3+0x60>
  801221:	89 f2                	mov    %esi,%edx
  801223:	f7 f7                	div    %edi
  801225:	89 d0                	mov    %edx,%eax
  801227:	31 d2                	xor    %edx,%edx
  801229:	83 c4 20             	add    $0x20,%esp
  80122c:	5e                   	pop    %esi
  80122d:	5f                   	pop    %edi
  80122e:	5d                   	pop    %ebp
  80122f:	c3                   	ret    
  801230:	39 f2                	cmp    %esi,%edx
  801232:	77 4c                	ja     801280 <__umoddi3+0x80>
  801234:	0f bd ca             	bsr    %edx,%ecx
  801237:	83 f1 1f             	xor    $0x1f,%ecx
  80123a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80123d:	75 51                	jne    801290 <__umoddi3+0x90>
  80123f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801242:	0f 87 e0 00 00 00    	ja     801328 <__umoddi3+0x128>
  801248:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80124b:	29 f8                	sub    %edi,%eax
  80124d:	19 d6                	sbb    %edx,%esi
  80124f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801252:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801255:	89 f2                	mov    %esi,%edx
  801257:	83 c4 20             	add    $0x20,%esp
  80125a:	5e                   	pop    %esi
  80125b:	5f                   	pop    %edi
  80125c:	5d                   	pop    %ebp
  80125d:	c3                   	ret    
  80125e:	66 90                	xchg   %ax,%ax
  801260:	85 ff                	test   %edi,%edi
  801262:	75 0b                	jne    80126f <__umoddi3+0x6f>
  801264:	b8 01 00 00 00       	mov    $0x1,%eax
  801269:	31 d2                	xor    %edx,%edx
  80126b:	f7 f7                	div    %edi
  80126d:	89 c7                	mov    %eax,%edi
  80126f:	89 f0                	mov    %esi,%eax
  801271:	31 d2                	xor    %edx,%edx
  801273:	f7 f7                	div    %edi
  801275:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801278:	f7 f7                	div    %edi
  80127a:	eb a9                	jmp    801225 <__umoddi3+0x25>
  80127c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801280:	89 c8                	mov    %ecx,%eax
  801282:	89 f2                	mov    %esi,%edx
  801284:	83 c4 20             	add    $0x20,%esp
  801287:	5e                   	pop    %esi
  801288:	5f                   	pop    %edi
  801289:	5d                   	pop    %ebp
  80128a:	c3                   	ret    
  80128b:	90                   	nop
  80128c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801290:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801294:	d3 e2                	shl    %cl,%edx
  801296:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801299:	ba 20 00 00 00       	mov    $0x20,%edx
  80129e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8012a1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8012a4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012a8:	89 fa                	mov    %edi,%edx
  8012aa:	d3 ea                	shr    %cl,%edx
  8012ac:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012b0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8012b3:	d3 e7                	shl    %cl,%edi
  8012b5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012b9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8012bc:	89 f2                	mov    %esi,%edx
  8012be:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8012c1:	89 c7                	mov    %eax,%edi
  8012c3:	d3 ea                	shr    %cl,%edx
  8012c5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8012cc:	89 c2                	mov    %eax,%edx
  8012ce:	d3 e6                	shl    %cl,%esi
  8012d0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012d4:	d3 ea                	shr    %cl,%edx
  8012d6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012da:	09 d6                	or     %edx,%esi
  8012dc:	89 f0                	mov    %esi,%eax
  8012de:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8012e1:	d3 e7                	shl    %cl,%edi
  8012e3:	89 f2                	mov    %esi,%edx
  8012e5:	f7 75 f4             	divl   -0xc(%ebp)
  8012e8:	89 d6                	mov    %edx,%esi
  8012ea:	f7 65 e8             	mull   -0x18(%ebp)
  8012ed:	39 d6                	cmp    %edx,%esi
  8012ef:	72 2b                	jb     80131c <__umoddi3+0x11c>
  8012f1:	39 c7                	cmp    %eax,%edi
  8012f3:	72 23                	jb     801318 <__umoddi3+0x118>
  8012f5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012f9:	29 c7                	sub    %eax,%edi
  8012fb:	19 d6                	sbb    %edx,%esi
  8012fd:	89 f0                	mov    %esi,%eax
  8012ff:	89 f2                	mov    %esi,%edx
  801301:	d3 ef                	shr    %cl,%edi
  801303:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801307:	d3 e0                	shl    %cl,%eax
  801309:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80130d:	09 f8                	or     %edi,%eax
  80130f:	d3 ea                	shr    %cl,%edx
  801311:	83 c4 20             	add    $0x20,%esp
  801314:	5e                   	pop    %esi
  801315:	5f                   	pop    %edi
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    
  801318:	39 d6                	cmp    %edx,%esi
  80131a:	75 d9                	jne    8012f5 <__umoddi3+0xf5>
  80131c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80131f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801322:	eb d1                	jmp    8012f5 <__umoddi3+0xf5>
  801324:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801328:	39 f2                	cmp    %esi,%edx
  80132a:	0f 82 18 ff ff ff    	jb     801248 <__umoddi3+0x48>
  801330:	e9 1d ff ff ff       	jmp    801252 <__umoddi3+0x52>
