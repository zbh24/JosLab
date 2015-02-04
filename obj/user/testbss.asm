
obj/user/testbss：     文件格式 elf32-i386


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
  80002c:	e8 ea 00 00 00       	call   80011b <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t bigarray[ARRAYSIZE];

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	int i;

	cprintf("Making sure bss works right...\n");
  800039:	c7 04 24 40 13 80 00 	movl   $0x801340,(%esp)
  800040:	e8 fa 01 00 00       	call   80023f <cprintf>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
  800045:	b8 01 00 00 00       	mov    $0x1,%eax
  80004a:	ba 20 20 80 00       	mov    $0x802020,%edx
  80004f:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  800056:	74 04                	je     80005c <umain+0x29>
  800058:	b0 00                	mov    $0x0,%al
  80005a:	eb 06                	jmp    800062 <umain+0x2f>
  80005c:	83 3c 82 00          	cmpl   $0x0,(%edx,%eax,4)
  800060:	74 20                	je     800082 <umain+0x4f>
			panic("bigarray[%d] isn't cleared!\n", i);
  800062:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800066:	c7 44 24 08 bb 13 80 	movl   $0x8013bb,0x8(%esp)
  80006d:	00 
  80006e:	c7 44 24 04 11 00 00 	movl   $0x11,0x4(%esp)
  800075:	00 
  800076:	c7 04 24 d8 13 80 00 	movl   $0x8013d8,(%esp)
  80007d:	e8 06 01 00 00       	call   800188 <_panic>
umain(int argc, char **argv)
{
	int i;

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
  800082:	83 c0 01             	add    $0x1,%eax
  800085:	3d 00 00 10 00       	cmp    $0x100000,%eax
  80008a:	75 d0                	jne    80005c <umain+0x29>
  80008c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
  800091:	ba 20 20 80 00       	mov    $0x802020,%edx
  800096:	89 04 82             	mov    %eax,(%edx,%eax,4)

	cprintf("Making sure bss works right...\n");
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
  800099:	83 c0 01             	add    $0x1,%eax
  80009c:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000a1:	75 f3                	jne    800096 <umain+0x63>
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != i)
  8000a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8000a8:	ba 20 20 80 00       	mov    $0x802020,%edx
  8000ad:	83 3d 20 20 80 00 00 	cmpl   $0x0,0x802020
  8000b4:	74 04                	je     8000ba <umain+0x87>
  8000b6:	b0 00                	mov    $0x0,%al
  8000b8:	eb 05                	jmp    8000bf <umain+0x8c>
  8000ba:	39 04 82             	cmp    %eax,(%edx,%eax,4)
  8000bd:	74 20                	je     8000df <umain+0xac>
			panic("bigarray[%d] didn't hold its value!\n", i);
  8000bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000c3:	c7 44 24 08 60 13 80 	movl   $0x801360,0x8(%esp)
  8000ca:	00 
  8000cb:	c7 44 24 04 16 00 00 	movl   $0x16,0x4(%esp)
  8000d2:	00 
  8000d3:	c7 04 24 d8 13 80 00 	movl   $0x8013d8,(%esp)
  8000da:	e8 a9 00 00 00       	call   800188 <_panic>
	for (i = 0; i < ARRAYSIZE; i++)
		if (bigarray[i] != 0)
			panic("bigarray[%d] isn't cleared!\n", i);
	for (i = 0; i < ARRAYSIZE; i++)
		bigarray[i] = i;
	for (i = 0; i < ARRAYSIZE; i++)
  8000df:	83 c0 01             	add    $0x1,%eax
  8000e2:	3d 00 00 10 00       	cmp    $0x100000,%eax
  8000e7:	75 d1                	jne    8000ba <umain+0x87>
		if (bigarray[i] != i)
			panic("bigarray[%d] didn't hold its value!\n", i);

	cprintf("Yes, good.  Now doing a wild write off the end...\n");
  8000e9:	c7 04 24 88 13 80 00 	movl   $0x801388,(%esp)
  8000f0:	e8 4a 01 00 00       	call   80023f <cprintf>
	bigarray[ARRAYSIZE+1024] = 0;
  8000f5:	c7 05 20 30 c0 00 00 	movl   $0x0,0xc03020
  8000fc:	00 00 00 
	panic("SHOULD HAVE TRAPPED!!!");
  8000ff:	c7 44 24 08 e7 13 80 	movl   $0x8013e7,0x8(%esp)
  800106:	00 
  800107:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  80010e:	00 
  80010f:	c7 04 24 d8 13 80 00 	movl   $0x8013d8,(%esp)
  800116:	e8 6d 00 00 00       	call   800188 <_panic>

0080011b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80011b:	55                   	push   %ebp
  80011c:	89 e5                	mov    %esp,%ebp
  80011e:	83 ec 18             	sub    $0x18,%esp
  800121:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800124:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800127:	8b 75 08             	mov    0x8(%ebp),%esi
  80012a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80012d:	c7 05 20 20 c0 00 00 	movl   $0x0,0xc02020
  800134:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800137:	e8 e5 0e 00 00       	call   801021 <sys_getenvid>
  80013c:	25 ff 03 00 00       	and    $0x3ff,%eax
  800141:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800144:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800149:	a3 20 20 c0 00       	mov    %eax,0xc02020
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80014e:	85 f6                	test   %esi,%esi
  800150:	7e 07                	jle    800159 <libmain+0x3e>
		binaryname = argv[0];
  800152:	8b 03                	mov    (%ebx),%eax
  800154:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800159:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80015d:	89 34 24             	mov    %esi,(%esp)
  800160:	e8 ce fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800165:	e8 0a 00 00 00       	call   800174 <exit>
}
  80016a:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80016d:	8b 75 fc             	mov    -0x4(%ebp),%esi
  800170:	89 ec                	mov    %ebp,%esp
  800172:	5d                   	pop    %ebp
  800173:	c3                   	ret    

00800174 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80017a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800181:	e8 cf 0e 00 00       	call   801055 <sys_env_destroy>
}
  800186:	c9                   	leave  
  800187:	c3                   	ret    

00800188 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800188:	55                   	push   %ebp
  800189:	89 e5                	mov    %esp,%ebp
  80018b:	56                   	push   %esi
  80018c:	53                   	push   %ebx
  80018d:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800190:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800193:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800199:	e8 83 0e 00 00       	call   801021 <sys_getenvid>
  80019e:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001a1:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001a5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001ac:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001b0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001b4:	c7 04 24 08 14 80 00 	movl   $0x801408,(%esp)
  8001bb:	e8 7f 00 00 00       	call   80023f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001c0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001c4:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c7:	89 04 24             	mov    %eax,(%esp)
  8001ca:	e8 0f 00 00 00       	call   8001de <vcprintf>
	cprintf("\n");
  8001cf:	c7 04 24 d6 13 80 00 	movl   $0x8013d6,(%esp)
  8001d6:	e8 64 00 00 00       	call   80023f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001db:	cc                   	int3   
  8001dc:	eb fd                	jmp    8001db <_panic+0x53>

008001de <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001de:	55                   	push   %ebp
  8001df:	89 e5                	mov    %esp,%ebp
  8001e1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001e7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001ee:	00 00 00 
	b.cnt = 0;
  8001f1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001f8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800202:	8b 45 08             	mov    0x8(%ebp),%eax
  800205:	89 44 24 08          	mov    %eax,0x8(%esp)
  800209:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80020f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800213:	c7 04 24 59 02 80 00 	movl   $0x800259,(%esp)
  80021a:	e8 ce 01 00 00       	call   8003ed <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800225:	89 44 24 04          	mov    %eax,0x4(%esp)
  800229:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022f:	89 04 24             	mov    %eax,(%esp)
  800232:	e8 17 0b 00 00       	call   800d4e <sys_cputs>

	return b.cnt;
}
  800237:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80023d:	c9                   	leave  
  80023e:	c3                   	ret    

0080023f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800245:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800248:	89 44 24 04          	mov    %eax,0x4(%esp)
  80024c:	8b 45 08             	mov    0x8(%ebp),%eax
  80024f:	89 04 24             	mov    %eax,(%esp)
  800252:	e8 87 ff ff ff       	call   8001de <vcprintf>
	va_end(ap);

	return cnt;
}
  800257:	c9                   	leave  
  800258:	c3                   	ret    

00800259 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800259:	55                   	push   %ebp
  80025a:	89 e5                	mov    %esp,%ebp
  80025c:	53                   	push   %ebx
  80025d:	83 ec 14             	sub    $0x14,%esp
  800260:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800263:	8b 03                	mov    (%ebx),%eax
  800265:	8b 55 08             	mov    0x8(%ebp),%edx
  800268:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80026c:	83 c0 01             	add    $0x1,%eax
  80026f:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800271:	3d ff 00 00 00       	cmp    $0xff,%eax
  800276:	75 19                	jne    800291 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800278:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80027f:	00 
  800280:	8d 43 08             	lea    0x8(%ebx),%eax
  800283:	89 04 24             	mov    %eax,(%esp)
  800286:	e8 c3 0a 00 00       	call   800d4e <sys_cputs>
		b->idx = 0;
  80028b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800291:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800295:	83 c4 14             	add    $0x14,%esp
  800298:	5b                   	pop    %ebx
  800299:	5d                   	pop    %ebp
  80029a:	c3                   	ret    
  80029b:	66 90                	xchg   %ax,%ax
  80029d:	66 90                	xchg   %ax,%ax
  80029f:	90                   	nop

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 4c             	sub    $0x4c,%esp
  8002a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002ac:	89 d6                	mov    %edx,%esi
  8002ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002ba:	8b 45 10             	mov    0x10(%ebp),%eax
  8002bd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002c0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002c6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002cb:	39 d1                	cmp    %edx,%ecx
  8002cd:	72 15                	jb     8002e4 <printnum+0x44>
  8002cf:	77 07                	ja     8002d8 <printnum+0x38>
  8002d1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002d4:	39 d0                	cmp    %edx,%eax
  8002d6:	76 0c                	jbe    8002e4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002d8:	83 eb 01             	sub    $0x1,%ebx
  8002db:	85 db                	test   %ebx,%ebx
  8002dd:	8d 76 00             	lea    0x0(%esi),%esi
  8002e0:	7f 61                	jg     800343 <printnum+0xa3>
  8002e2:	eb 70                	jmp    800354 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002e4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002e8:	83 eb 01             	sub    $0x1,%ebx
  8002eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8002f7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8002fb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8002fe:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800301:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800304:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800308:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80030f:	00 
  800310:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800313:	89 04 24             	mov    %eax,(%esp)
  800316:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800319:	89 54 24 04          	mov    %edx,0x4(%esp)
  80031d:	e8 9e 0d 00 00       	call   8010c0 <__udivdi3>
  800322:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800325:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800328:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80032c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800330:	89 04 24             	mov    %eax,(%esp)
  800333:	89 54 24 04          	mov    %edx,0x4(%esp)
  800337:	89 f2                	mov    %esi,%edx
  800339:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80033c:	e8 5f ff ff ff       	call   8002a0 <printnum>
  800341:	eb 11                	jmp    800354 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800343:	89 74 24 04          	mov    %esi,0x4(%esp)
  800347:	89 3c 24             	mov    %edi,(%esp)
  80034a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80034d:	83 eb 01             	sub    $0x1,%ebx
  800350:	85 db                	test   %ebx,%ebx
  800352:	7f ef                	jg     800343 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800354:	89 74 24 04          	mov    %esi,0x4(%esp)
  800358:	8b 74 24 04          	mov    0x4(%esp),%esi
  80035c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80035f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800363:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80036a:	00 
  80036b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80036e:	89 14 24             	mov    %edx,(%esp)
  800371:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800374:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800378:	e8 73 0e 00 00       	call   8011f0 <__umoddi3>
  80037d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800381:	0f be 80 2c 14 80 00 	movsbl 0x80142c(%eax),%eax
  800388:	89 04 24             	mov    %eax,(%esp)
  80038b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80038e:	83 c4 4c             	add    $0x4c,%esp
  800391:	5b                   	pop    %ebx
  800392:	5e                   	pop    %esi
  800393:	5f                   	pop    %edi
  800394:	5d                   	pop    %ebp
  800395:	c3                   	ret    

00800396 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800396:	55                   	push   %ebp
  800397:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800399:	83 fa 01             	cmp    $0x1,%edx
  80039c:	7e 0e                	jle    8003ac <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80039e:	8b 10                	mov    (%eax),%edx
  8003a0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 02                	mov    (%edx),%eax
  8003a7:	8b 52 04             	mov    0x4(%edx),%edx
  8003aa:	eb 22                	jmp    8003ce <getuint+0x38>
	else if (lflag)
  8003ac:	85 d2                	test   %edx,%edx
  8003ae:	74 10                	je     8003c0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003b0:	8b 10                	mov    (%eax),%edx
  8003b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003b5:	89 08                	mov    %ecx,(%eax)
  8003b7:	8b 02                	mov    (%edx),%eax
  8003b9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003be:	eb 0e                	jmp    8003ce <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003c0:	8b 10                	mov    (%eax),%edx
  8003c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c5:	89 08                	mov    %ecx,(%eax)
  8003c7:	8b 02                	mov    (%edx),%eax
  8003c9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003ce:	5d                   	pop    %ebp
  8003cf:	c3                   	ret    

008003d0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003d6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003da:	8b 10                	mov    (%eax),%edx
  8003dc:	3b 50 04             	cmp    0x4(%eax),%edx
  8003df:	73 0a                	jae    8003eb <sprintputch+0x1b>
		*b->buf++ = ch;
  8003e1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e4:	88 0a                	mov    %cl,(%edx)
  8003e6:	83 c2 01             	add    $0x1,%edx
  8003e9:	89 10                	mov    %edx,(%eax)
}
  8003eb:	5d                   	pop    %ebp
  8003ec:	c3                   	ret    

008003ed <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003ed:	55                   	push   %ebp
  8003ee:	89 e5                	mov    %esp,%ebp
  8003f0:	57                   	push   %edi
  8003f1:	56                   	push   %esi
  8003f2:	53                   	push   %ebx
  8003f3:	83 ec 5c             	sub    $0x5c,%esp
  8003f6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8003f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003fc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8003ff:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800406:	eb 11                	jmp    800419 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800408:	85 c0                	test   %eax,%eax
  80040a:	0f 84 16 04 00 00    	je     800826 <vprintfmt+0x439>
				return;
			putch(ch, putdat);
  800410:	89 74 24 04          	mov    %esi,0x4(%esp)
  800414:	89 04 24             	mov    %eax,(%esp)
  800417:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800419:	0f b6 03             	movzbl (%ebx),%eax
  80041c:	83 c3 01             	add    $0x1,%ebx
  80041f:	83 f8 25             	cmp    $0x25,%eax
  800422:	75 e4                	jne    800408 <vprintfmt+0x1b>
  800424:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80042b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800432:	b9 00 00 00 00       	mov    $0x0,%ecx
  800437:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80043b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800442:	eb 06                	jmp    80044a <vprintfmt+0x5d>
  800444:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800448:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80044a:	0f b6 13             	movzbl (%ebx),%edx
  80044d:	0f b6 c2             	movzbl %dl,%eax
  800450:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800453:	8d 43 01             	lea    0x1(%ebx),%eax
  800456:	83 ea 23             	sub    $0x23,%edx
  800459:	80 fa 55             	cmp    $0x55,%dl
  80045c:	0f 87 a7 03 00 00    	ja     800809 <vprintfmt+0x41c>
  800462:	0f b6 d2             	movzbl %dl,%edx
  800465:	ff 24 95 00 15 80 00 	jmp    *0x801500(,%edx,4)
  80046c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800470:	eb d6                	jmp    800448 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800472:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800475:	83 ea 30             	sub    $0x30,%edx
  800478:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80047b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80047e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800481:	83 fb 09             	cmp    $0x9,%ebx
  800484:	77 54                	ja     8004da <vprintfmt+0xed>
  800486:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800489:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80048c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80048f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800492:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800496:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800499:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80049c:	83 fb 09             	cmp    $0x9,%ebx
  80049f:	76 eb                	jbe    80048c <vprintfmt+0x9f>
  8004a1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004a4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a7:	eb 31                	jmp    8004da <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004a9:	8b 55 14             	mov    0x14(%ebp),%edx
  8004ac:	8d 5a 04             	lea    0x4(%edx),%ebx
  8004af:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004b2:	8b 12                	mov    (%edx),%edx
  8004b4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8004b7:	eb 21                	jmp    8004da <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8004b9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c2:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  8004c6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004c9:	e9 7a ff ff ff       	jmp    800448 <vprintfmt+0x5b>
  8004ce:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004d5:	e9 6e ff ff ff       	jmp    800448 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8004da:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004de:	0f 89 64 ff ff ff    	jns    800448 <vprintfmt+0x5b>
  8004e4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8004e7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004ea:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8004ed:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8004f0:	e9 53 ff ff ff       	jmp    800448 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8004f5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8004f8:	e9 4b ff ff ff       	jmp    800448 <vprintfmt+0x5b>
  8004fd:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800500:	8b 45 14             	mov    0x14(%ebp),%eax
  800503:	8d 50 04             	lea    0x4(%eax),%edx
  800506:	89 55 14             	mov    %edx,0x14(%ebp)
  800509:	89 74 24 04          	mov    %esi,0x4(%esp)
  80050d:	8b 00                	mov    (%eax),%eax
  80050f:	89 04 24             	mov    %eax,(%esp)
  800512:	ff d7                	call   *%edi
  800514:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800517:	e9 fd fe ff ff       	jmp    800419 <vprintfmt+0x2c>
  80051c:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80051f:	8b 45 14             	mov    0x14(%ebp),%eax
  800522:	8d 50 04             	lea    0x4(%eax),%edx
  800525:	89 55 14             	mov    %edx,0x14(%ebp)
  800528:	8b 00                	mov    (%eax),%eax
  80052a:	89 c2                	mov    %eax,%edx
  80052c:	c1 fa 1f             	sar    $0x1f,%edx
  80052f:	31 d0                	xor    %edx,%eax
  800531:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800533:	83 f8 08             	cmp    $0x8,%eax
  800536:	7f 0b                	jg     800543 <vprintfmt+0x156>
  800538:	8b 14 85 60 16 80 00 	mov    0x801660(,%eax,4),%edx
  80053f:	85 d2                	test   %edx,%edx
  800541:	75 20                	jne    800563 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800543:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800547:	c7 44 24 08 3d 14 80 	movl   $0x80143d,0x8(%esp)
  80054e:	00 
  80054f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800553:	89 3c 24             	mov    %edi,(%esp)
  800556:	e8 53 03 00 00       	call   8008ae <printfmt>
  80055b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80055e:	e9 b6 fe ff ff       	jmp    800419 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800563:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800567:	c7 44 24 08 46 14 80 	movl   $0x801446,0x8(%esp)
  80056e:	00 
  80056f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800573:	89 3c 24             	mov    %edi,(%esp)
  800576:	e8 33 03 00 00       	call   8008ae <printfmt>
  80057b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80057e:	e9 96 fe ff ff       	jmp    800419 <vprintfmt+0x2c>
  800583:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800586:	89 c3                	mov    %eax,%ebx
  800588:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80058b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80058e:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800591:	8b 45 14             	mov    0x14(%ebp),%eax
  800594:	8d 50 04             	lea    0x4(%eax),%edx
  800597:	89 55 14             	mov    %edx,0x14(%ebp)
  80059a:	8b 00                	mov    (%eax),%eax
  80059c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80059f:	85 c0                	test   %eax,%eax
  8005a1:	b8 49 14 80 00       	mov    $0x801449,%eax
  8005a6:	0f 45 45 c4          	cmovne -0x3c(%ebp),%eax
  8005aa:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8005ad:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8005b1:	7e 06                	jle    8005b9 <vprintfmt+0x1cc>
  8005b3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8005b7:	75 13                	jne    8005cc <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005b9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005bc:	0f be 02             	movsbl (%edx),%eax
  8005bf:	85 c0                	test   %eax,%eax
  8005c1:	0f 85 9b 00 00 00    	jne    800662 <vprintfmt+0x275>
  8005c7:	e9 88 00 00 00       	jmp    800654 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005cc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005d0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  8005d3:	89 0c 24             	mov    %ecx,(%esp)
  8005d6:	e8 20 03 00 00       	call   8008fb <strnlen>
  8005db:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8005de:	29 c2                	sub    %eax,%edx
  8005e0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005e3:	85 d2                	test   %edx,%edx
  8005e5:	7e d2                	jle    8005b9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  8005e7:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  8005eb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005ee:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8005f1:	89 d3                	mov    %edx,%ebx
  8005f3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005f7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8005fa:	89 04 24             	mov    %eax,(%esp)
  8005fd:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005ff:	83 eb 01             	sub    $0x1,%ebx
  800602:	85 db                	test   %ebx,%ebx
  800604:	7f ed                	jg     8005f3 <vprintfmt+0x206>
  800606:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  800609:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800610:	eb a7                	jmp    8005b9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800612:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800616:	74 1a                	je     800632 <vprintfmt+0x245>
  800618:	8d 50 e0             	lea    -0x20(%eax),%edx
  80061b:	83 fa 5e             	cmp    $0x5e,%edx
  80061e:	76 12                	jbe    800632 <vprintfmt+0x245>
					putch('?', putdat);
  800620:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800624:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80062b:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80062e:	66 90                	xchg   %ax,%ax
  800630:	eb 0a                	jmp    80063c <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800632:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800636:	89 04 24             	mov    %eax,(%esp)
  800639:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80063c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800640:	0f be 03             	movsbl (%ebx),%eax
  800643:	85 c0                	test   %eax,%eax
  800645:	74 05                	je     80064c <vprintfmt+0x25f>
  800647:	83 c3 01             	add    $0x1,%ebx
  80064a:	eb 29                	jmp    800675 <vprintfmt+0x288>
  80064c:	89 fe                	mov    %edi,%esi
  80064e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800651:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800654:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800658:	7f 2e                	jg     800688 <vprintfmt+0x29b>
  80065a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80065d:	e9 b7 fd ff ff       	jmp    800419 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800662:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800665:	83 c2 01             	add    $0x1,%edx
  800668:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80066b:	89 f7                	mov    %esi,%edi
  80066d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800670:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800673:	89 d3                	mov    %edx,%ebx
  800675:	85 f6                	test   %esi,%esi
  800677:	78 99                	js     800612 <vprintfmt+0x225>
  800679:	83 ee 01             	sub    $0x1,%esi
  80067c:	79 94                	jns    800612 <vprintfmt+0x225>
  80067e:	89 fe                	mov    %edi,%esi
  800680:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800683:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800686:	eb cc                	jmp    800654 <vprintfmt+0x267>
  800688:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80068b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80068e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800692:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800699:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80069b:	83 eb 01             	sub    $0x1,%ebx
  80069e:	85 db                	test   %ebx,%ebx
  8006a0:	7f ec                	jg     80068e <vprintfmt+0x2a1>
  8006a2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006a5:	e9 6f fd ff ff       	jmp    800419 <vprintfmt+0x2c>
  8006aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006ad:	83 f9 01             	cmp    $0x1,%ecx
  8006b0:	7e 16                	jle    8006c8 <vprintfmt+0x2db>
		return va_arg(*ap, long long);
  8006b2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006b5:	8d 50 08             	lea    0x8(%eax),%edx
  8006b8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006bb:	8b 10                	mov    (%eax),%edx
  8006bd:	8b 48 04             	mov    0x4(%eax),%ecx
  8006c0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006c3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006c6:	eb 32                	jmp    8006fa <vprintfmt+0x30d>
	else if (lflag)
  8006c8:	85 c9                	test   %ecx,%ecx
  8006ca:	74 18                	je     8006e4 <vprintfmt+0x2f7>
		return va_arg(*ap, long);
  8006cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006cf:	8d 50 04             	lea    0x4(%eax),%edx
  8006d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006d5:	8b 00                	mov    (%eax),%eax
  8006d7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006da:	89 c1                	mov    %eax,%ecx
  8006dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8006df:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006e2:	eb 16                	jmp    8006fa <vprintfmt+0x30d>
	else
		return va_arg(*ap, int);
  8006e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e7:	8d 50 04             	lea    0x4(%eax),%edx
  8006ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ed:	8b 00                	mov    (%eax),%eax
  8006ef:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006f2:	89 c2                	mov    %eax,%edx
  8006f4:	c1 fa 1f             	sar    $0x1f,%edx
  8006f7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8006fa:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006fd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800700:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800705:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800709:	0f 89 b8 00 00 00    	jns    8007c7 <vprintfmt+0x3da>
				putch('-', putdat);
  80070f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800713:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80071a:	ff d7                	call   *%edi
				num = -(long long) num;
  80071c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80071f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800722:	f7 d9                	neg    %ecx
  800724:	83 d3 00             	adc    $0x0,%ebx
  800727:	f7 db                	neg    %ebx
  800729:	b8 0a 00 00 00       	mov    $0xa,%eax
  80072e:	e9 94 00 00 00       	jmp    8007c7 <vprintfmt+0x3da>
  800733:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800736:	89 ca                	mov    %ecx,%edx
  800738:	8d 45 14             	lea    0x14(%ebp),%eax
  80073b:	e8 56 fc ff ff       	call   800396 <getuint>
  800740:	89 c1                	mov    %eax,%ecx
  800742:	89 d3                	mov    %edx,%ebx
  800744:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800749:	eb 7c                	jmp    8007c7 <vprintfmt+0x3da>
  80074b:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80074e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800752:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800759:	ff d7                	call   *%edi
			putch('X', putdat);
  80075b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80075f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800766:	ff d7                	call   *%edi
			putch('X', putdat);
  800768:	89 74 24 04          	mov    %esi,0x4(%esp)
  80076c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800773:	ff d7                	call   *%edi
  800775:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800778:	e9 9c fc ff ff       	jmp    800419 <vprintfmt+0x2c>
  80077d:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800780:	89 74 24 04          	mov    %esi,0x4(%esp)
  800784:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80078b:	ff d7                	call   *%edi
			putch('x', putdat);
  80078d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800791:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800798:	ff d7                	call   *%edi
			num = (unsigned long long)
  80079a:	8b 45 14             	mov    0x14(%ebp),%eax
  80079d:	8d 50 04             	lea    0x4(%eax),%edx
  8007a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a3:	8b 08                	mov    (%eax),%ecx
  8007a5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007aa:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007af:	eb 16                	jmp    8007c7 <vprintfmt+0x3da>
  8007b1:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007b4:	89 ca                	mov    %ecx,%edx
  8007b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b9:	e8 d8 fb ff ff       	call   800396 <getuint>
  8007be:	89 c1                	mov    %eax,%ecx
  8007c0:	89 d3                	mov    %edx,%ebx
  8007c2:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007c7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8007cb:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007cf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007d2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007da:	89 0c 24             	mov    %ecx,(%esp)
  8007dd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007e1:	89 f2                	mov    %esi,%edx
  8007e3:	89 f8                	mov    %edi,%eax
  8007e5:	e8 b6 fa ff ff       	call   8002a0 <printnum>
  8007ea:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8007ed:	e9 27 fc ff ff       	jmp    800419 <vprintfmt+0x2c>
  8007f2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007f5:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8007f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007fc:	89 14 24             	mov    %edx,(%esp)
  8007ff:	ff d7                	call   *%edi
  800801:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800804:	e9 10 fc ff ff       	jmp    800419 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800809:	89 74 24 04          	mov    %esi,0x4(%esp)
  80080d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800814:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800816:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800819:	80 38 25             	cmpb   $0x25,(%eax)
  80081c:	0f 84 f7 fb ff ff    	je     800419 <vprintfmt+0x2c>
  800822:	89 c3                	mov    %eax,%ebx
  800824:	eb f0                	jmp    800816 <vprintfmt+0x429>
				/* do nothing */;
			break;
		}
	}
}
  800826:	83 c4 5c             	add    $0x5c,%esp
  800829:	5b                   	pop    %ebx
  80082a:	5e                   	pop    %esi
  80082b:	5f                   	pop    %edi
  80082c:	5d                   	pop    %ebp
  80082d:	c3                   	ret    

0080082e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80082e:	55                   	push   %ebp
  80082f:	89 e5                	mov    %esp,%ebp
  800831:	83 ec 28             	sub    $0x28,%esp
  800834:	8b 45 08             	mov    0x8(%ebp),%eax
  800837:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80083a:	85 c0                	test   %eax,%eax
  80083c:	74 04                	je     800842 <vsnprintf+0x14>
  80083e:	85 d2                	test   %edx,%edx
  800840:	7f 07                	jg     800849 <vsnprintf+0x1b>
  800842:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800847:	eb 3b                	jmp    800884 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800849:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80084c:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800850:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800853:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80085a:	8b 45 14             	mov    0x14(%ebp),%eax
  80085d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800861:	8b 45 10             	mov    0x10(%ebp),%eax
  800864:	89 44 24 08          	mov    %eax,0x8(%esp)
  800868:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80086b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086f:	c7 04 24 d0 03 80 00 	movl   $0x8003d0,(%esp)
  800876:	e8 72 fb ff ff       	call   8003ed <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80087b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80087e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800881:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800884:	c9                   	leave  
  800885:	c3                   	ret    

00800886 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800886:	55                   	push   %ebp
  800887:	89 e5                	mov    %esp,%ebp
  800889:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80088c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80088f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800893:	8b 45 10             	mov    0x10(%ebp),%eax
  800896:	89 44 24 08          	mov    %eax,0x8(%esp)
  80089a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089d:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a4:	89 04 24             	mov    %eax,(%esp)
  8008a7:	e8 82 ff ff ff       	call   80082e <vsnprintf>
	va_end(ap);

	return rc;
}
  8008ac:	c9                   	leave  
  8008ad:	c3                   	ret    

008008ae <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8008b4:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8008b7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008bb:	8b 45 10             	mov    0x10(%ebp),%eax
  8008be:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008c2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008cc:	89 04 24             	mov    %eax,(%esp)
  8008cf:	e8 19 fb ff ff       	call   8003ed <vprintfmt>
	va_end(ap);
}
  8008d4:	c9                   	leave  
  8008d5:	c3                   	ret    
  8008d6:	66 90                	xchg   %ax,%ax
  8008d8:	66 90                	xchg   %ax,%ax
  8008da:	66 90                	xchg   %ax,%ax
  8008dc:	66 90                	xchg   %ax,%ax
  8008de:	66 90                	xchg   %ax,%ax

008008e0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008e0:	55                   	push   %ebp
  8008e1:	89 e5                	mov    %esp,%ebp
  8008e3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008eb:	80 3a 00             	cmpb   $0x0,(%edx)
  8008ee:	74 09                	je     8008f9 <strlen+0x19>
		n++;
  8008f0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008f7:	75 f7                	jne    8008f0 <strlen+0x10>
		n++;
	return n;
}
  8008f9:	5d                   	pop    %ebp
  8008fa:	c3                   	ret    

008008fb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008fb:	55                   	push   %ebp
  8008fc:	89 e5                	mov    %esp,%ebp
  8008fe:	53                   	push   %ebx
  8008ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800902:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800905:	85 c9                	test   %ecx,%ecx
  800907:	74 19                	je     800922 <strnlen+0x27>
  800909:	80 3b 00             	cmpb   $0x0,(%ebx)
  80090c:	74 14                	je     800922 <strnlen+0x27>
  80090e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800913:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800916:	39 c8                	cmp    %ecx,%eax
  800918:	74 0d                	je     800927 <strnlen+0x2c>
  80091a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80091e:	75 f3                	jne    800913 <strnlen+0x18>
  800920:	eb 05                	jmp    800927 <strnlen+0x2c>
  800922:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800927:	5b                   	pop    %ebx
  800928:	5d                   	pop    %ebp
  800929:	c3                   	ret    

0080092a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80092a:	55                   	push   %ebp
  80092b:	89 e5                	mov    %esp,%ebp
  80092d:	53                   	push   %ebx
  80092e:	8b 45 08             	mov    0x8(%ebp),%eax
  800931:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800934:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800939:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80093d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800940:	83 c2 01             	add    $0x1,%edx
  800943:	84 c9                	test   %cl,%cl
  800945:	75 f2                	jne    800939 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800947:	5b                   	pop    %ebx
  800948:	5d                   	pop    %ebp
  800949:	c3                   	ret    

0080094a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	53                   	push   %ebx
  80094e:	83 ec 08             	sub    $0x8,%esp
  800951:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800954:	89 1c 24             	mov    %ebx,(%esp)
  800957:	e8 84 ff ff ff       	call   8008e0 <strlen>
	strcpy(dst + len, src);
  80095c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80095f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800963:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800966:	89 04 24             	mov    %eax,(%esp)
  800969:	e8 bc ff ff ff       	call   80092a <strcpy>
	return dst;
}
  80096e:	89 d8                	mov    %ebx,%eax
  800970:	83 c4 08             	add    $0x8,%esp
  800973:	5b                   	pop    %ebx
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800976:	55                   	push   %ebp
  800977:	89 e5                	mov    %esp,%ebp
  800979:	56                   	push   %esi
  80097a:	53                   	push   %ebx
  80097b:	8b 45 08             	mov    0x8(%ebp),%eax
  80097e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800981:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800984:	85 f6                	test   %esi,%esi
  800986:	74 18                	je     8009a0 <strncpy+0x2a>
  800988:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80098d:	0f b6 1a             	movzbl (%edx),%ebx
  800990:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800993:	80 3a 01             	cmpb   $0x1,(%edx)
  800996:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800999:	83 c1 01             	add    $0x1,%ecx
  80099c:	39 ce                	cmp    %ecx,%esi
  80099e:	77 ed                	ja     80098d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009a0:	5b                   	pop    %ebx
  8009a1:	5e                   	pop    %esi
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	56                   	push   %esi
  8009a8:	53                   	push   %ebx
  8009a9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ac:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009af:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009b2:	89 f0                	mov    %esi,%eax
  8009b4:	85 c9                	test   %ecx,%ecx
  8009b6:	74 27                	je     8009df <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8009b8:	83 e9 01             	sub    $0x1,%ecx
  8009bb:	74 1d                	je     8009da <strlcpy+0x36>
  8009bd:	0f b6 1a             	movzbl (%edx),%ebx
  8009c0:	84 db                	test   %bl,%bl
  8009c2:	74 16                	je     8009da <strlcpy+0x36>
			*dst++ = *src++;
  8009c4:	88 18                	mov    %bl,(%eax)
  8009c6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009c9:	83 e9 01             	sub    $0x1,%ecx
  8009cc:	74 0e                	je     8009dc <strlcpy+0x38>
			*dst++ = *src++;
  8009ce:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d1:	0f b6 1a             	movzbl (%edx),%ebx
  8009d4:	84 db                	test   %bl,%bl
  8009d6:	75 ec                	jne    8009c4 <strlcpy+0x20>
  8009d8:	eb 02                	jmp    8009dc <strlcpy+0x38>
  8009da:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009dc:	c6 00 00             	movb   $0x0,(%eax)
  8009df:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009e1:	5b                   	pop    %ebx
  8009e2:	5e                   	pop    %esi
  8009e3:	5d                   	pop    %ebp
  8009e4:	c3                   	ret    

008009e5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009e5:	55                   	push   %ebp
  8009e6:	89 e5                	mov    %esp,%ebp
  8009e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009ee:	0f b6 01             	movzbl (%ecx),%eax
  8009f1:	84 c0                	test   %al,%al
  8009f3:	74 15                	je     800a0a <strcmp+0x25>
  8009f5:	3a 02                	cmp    (%edx),%al
  8009f7:	75 11                	jne    800a0a <strcmp+0x25>
		p++, q++;
  8009f9:	83 c1 01             	add    $0x1,%ecx
  8009fc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8009ff:	0f b6 01             	movzbl (%ecx),%eax
  800a02:	84 c0                	test   %al,%al
  800a04:	74 04                	je     800a0a <strcmp+0x25>
  800a06:	3a 02                	cmp    (%edx),%al
  800a08:	74 ef                	je     8009f9 <strcmp+0x14>
  800a0a:	0f b6 c0             	movzbl %al,%eax
  800a0d:	0f b6 12             	movzbl (%edx),%edx
  800a10:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    

00800a14 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	53                   	push   %ebx
  800a18:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a1e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a21:	85 c0                	test   %eax,%eax
  800a23:	74 23                	je     800a48 <strncmp+0x34>
  800a25:	0f b6 1a             	movzbl (%edx),%ebx
  800a28:	84 db                	test   %bl,%bl
  800a2a:	74 25                	je     800a51 <strncmp+0x3d>
  800a2c:	3a 19                	cmp    (%ecx),%bl
  800a2e:	75 21                	jne    800a51 <strncmp+0x3d>
  800a30:	83 e8 01             	sub    $0x1,%eax
  800a33:	74 13                	je     800a48 <strncmp+0x34>
		n--, p++, q++;
  800a35:	83 c2 01             	add    $0x1,%edx
  800a38:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a3b:	0f b6 1a             	movzbl (%edx),%ebx
  800a3e:	84 db                	test   %bl,%bl
  800a40:	74 0f                	je     800a51 <strncmp+0x3d>
  800a42:	3a 19                	cmp    (%ecx),%bl
  800a44:	74 ea                	je     800a30 <strncmp+0x1c>
  800a46:	eb 09                	jmp    800a51 <strncmp+0x3d>
  800a48:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a4d:	5b                   	pop    %ebx
  800a4e:	5d                   	pop    %ebp
  800a4f:	90                   	nop
  800a50:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a51:	0f b6 02             	movzbl (%edx),%eax
  800a54:	0f b6 11             	movzbl (%ecx),%edx
  800a57:	29 d0                	sub    %edx,%eax
  800a59:	eb f2                	jmp    800a4d <strncmp+0x39>

00800a5b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a5b:	55                   	push   %ebp
  800a5c:	89 e5                	mov    %esp,%ebp
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a65:	0f b6 10             	movzbl (%eax),%edx
  800a68:	84 d2                	test   %dl,%dl
  800a6a:	74 18                	je     800a84 <strchr+0x29>
		if (*s == c)
  800a6c:	38 ca                	cmp    %cl,%dl
  800a6e:	75 0a                	jne    800a7a <strchr+0x1f>
  800a70:	eb 17                	jmp    800a89 <strchr+0x2e>
  800a72:	38 ca                	cmp    %cl,%dl
  800a74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a78:	74 0f                	je     800a89 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a7a:	83 c0 01             	add    $0x1,%eax
  800a7d:	0f b6 10             	movzbl (%eax),%edx
  800a80:	84 d2                	test   %dl,%dl
  800a82:	75 ee                	jne    800a72 <strchr+0x17>
  800a84:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a95:	0f b6 10             	movzbl (%eax),%edx
  800a98:	84 d2                	test   %dl,%dl
  800a9a:	74 18                	je     800ab4 <strfind+0x29>
		if (*s == c)
  800a9c:	38 ca                	cmp    %cl,%dl
  800a9e:	75 0a                	jne    800aaa <strfind+0x1f>
  800aa0:	eb 12                	jmp    800ab4 <strfind+0x29>
  800aa2:	38 ca                	cmp    %cl,%dl
  800aa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800aa8:	74 0a                	je     800ab4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aaa:	83 c0 01             	add    $0x1,%eax
  800aad:	0f b6 10             	movzbl (%eax),%edx
  800ab0:	84 d2                	test   %dl,%dl
  800ab2:	75 ee                	jne    800aa2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800ab4:	5d                   	pop    %ebp
  800ab5:	c3                   	ret    

00800ab6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ab6:	55                   	push   %ebp
  800ab7:	89 e5                	mov    %esp,%ebp
  800ab9:	83 ec 0c             	sub    $0xc,%esp
  800abc:	89 1c 24             	mov    %ebx,(%esp)
  800abf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ac3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ac7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800aca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ad0:	85 c9                	test   %ecx,%ecx
  800ad2:	74 30                	je     800b04 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ad4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ada:	75 25                	jne    800b01 <memset+0x4b>
  800adc:	f6 c1 03             	test   $0x3,%cl
  800adf:	75 20                	jne    800b01 <memset+0x4b>
		c &= 0xFF;
  800ae1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ae4:	89 d3                	mov    %edx,%ebx
  800ae6:	c1 e3 08             	shl    $0x8,%ebx
  800ae9:	89 d6                	mov    %edx,%esi
  800aeb:	c1 e6 18             	shl    $0x18,%esi
  800aee:	89 d0                	mov    %edx,%eax
  800af0:	c1 e0 10             	shl    $0x10,%eax
  800af3:	09 f0                	or     %esi,%eax
  800af5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800af7:	09 d8                	or     %ebx,%eax
  800af9:	c1 e9 02             	shr    $0x2,%ecx
  800afc:	fc                   	cld    
  800afd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800aff:	eb 03                	jmp    800b04 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b01:	fc                   	cld    
  800b02:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b04:	89 f8                	mov    %edi,%eax
  800b06:	8b 1c 24             	mov    (%esp),%ebx
  800b09:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b0d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b11:	89 ec                	mov    %ebp,%esp
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	83 ec 08             	sub    $0x8,%esp
  800b1b:	89 34 24             	mov    %esi,(%esp)
  800b1e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b22:	8b 45 08             	mov    0x8(%ebp),%eax
  800b25:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800b28:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b2b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b2d:	39 c6                	cmp    %eax,%esi
  800b2f:	73 35                	jae    800b66 <memmove+0x51>
  800b31:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b34:	39 d0                	cmp    %edx,%eax
  800b36:	73 2e                	jae    800b66 <memmove+0x51>
		s += n;
		d += n;
  800b38:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b3a:	f6 c2 03             	test   $0x3,%dl
  800b3d:	75 1b                	jne    800b5a <memmove+0x45>
  800b3f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b45:	75 13                	jne    800b5a <memmove+0x45>
  800b47:	f6 c1 03             	test   $0x3,%cl
  800b4a:	75 0e                	jne    800b5a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800b4c:	83 ef 04             	sub    $0x4,%edi
  800b4f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b52:	c1 e9 02             	shr    $0x2,%ecx
  800b55:	fd                   	std    
  800b56:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b58:	eb 09                	jmp    800b63 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b5a:	83 ef 01             	sub    $0x1,%edi
  800b5d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b60:	fd                   	std    
  800b61:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b63:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b64:	eb 20                	jmp    800b86 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b66:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b6c:	75 15                	jne    800b83 <memmove+0x6e>
  800b6e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b74:	75 0d                	jne    800b83 <memmove+0x6e>
  800b76:	f6 c1 03             	test   $0x3,%cl
  800b79:	75 08                	jne    800b83 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800b7b:	c1 e9 02             	shr    $0x2,%ecx
  800b7e:	fc                   	cld    
  800b7f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b81:	eb 03                	jmp    800b86 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b83:	fc                   	cld    
  800b84:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b86:	8b 34 24             	mov    (%esp),%esi
  800b89:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b8d:	89 ec                	mov    %ebp,%esp
  800b8f:	5d                   	pop    %ebp
  800b90:	c3                   	ret    

00800b91 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b91:	55                   	push   %ebp
  800b92:	89 e5                	mov    %esp,%ebp
  800b94:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b97:	8b 45 10             	mov    0x10(%ebp),%eax
  800b9a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba8:	89 04 24             	mov    %eax,(%esp)
  800bab:	e8 65 ff ff ff       	call   800b15 <memmove>
}
  800bb0:	c9                   	leave  
  800bb1:	c3                   	ret    

00800bb2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bb2:	55                   	push   %ebp
  800bb3:	89 e5                	mov    %esp,%ebp
  800bb5:	57                   	push   %edi
  800bb6:	56                   	push   %esi
  800bb7:	53                   	push   %ebx
  800bb8:	8b 75 08             	mov    0x8(%ebp),%esi
  800bbb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800bbe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc1:	85 c9                	test   %ecx,%ecx
  800bc3:	74 36                	je     800bfb <memcmp+0x49>
		if (*s1 != *s2)
  800bc5:	0f b6 06             	movzbl (%esi),%eax
  800bc8:	0f b6 1f             	movzbl (%edi),%ebx
  800bcb:	38 d8                	cmp    %bl,%al
  800bcd:	74 20                	je     800bef <memcmp+0x3d>
  800bcf:	eb 14                	jmp    800be5 <memcmp+0x33>
  800bd1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800bd6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800bdb:	83 c2 01             	add    $0x1,%edx
  800bde:	83 e9 01             	sub    $0x1,%ecx
  800be1:	38 d8                	cmp    %bl,%al
  800be3:	74 12                	je     800bf7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800be5:	0f b6 c0             	movzbl %al,%eax
  800be8:	0f b6 db             	movzbl %bl,%ebx
  800beb:	29 d8                	sub    %ebx,%eax
  800bed:	eb 11                	jmp    800c00 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bef:	83 e9 01             	sub    $0x1,%ecx
  800bf2:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf7:	85 c9                	test   %ecx,%ecx
  800bf9:	75 d6                	jne    800bd1 <memcmp+0x1f>
  800bfb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800c00:	5b                   	pop    %ebx
  800c01:	5e                   	pop    %esi
  800c02:	5f                   	pop    %edi
  800c03:	5d                   	pop    %ebp
  800c04:	c3                   	ret    

00800c05 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c0b:	89 c2                	mov    %eax,%edx
  800c0d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c10:	39 d0                	cmp    %edx,%eax
  800c12:	73 15                	jae    800c29 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c14:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c18:	38 08                	cmp    %cl,(%eax)
  800c1a:	75 06                	jne    800c22 <memfind+0x1d>
  800c1c:	eb 0b                	jmp    800c29 <memfind+0x24>
  800c1e:	38 08                	cmp    %cl,(%eax)
  800c20:	74 07                	je     800c29 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c22:	83 c0 01             	add    $0x1,%eax
  800c25:	39 c2                	cmp    %eax,%edx
  800c27:	77 f5                	ja     800c1e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	57                   	push   %edi
  800c2f:	56                   	push   %esi
  800c30:	53                   	push   %ebx
  800c31:	83 ec 04             	sub    $0x4,%esp
  800c34:	8b 55 08             	mov    0x8(%ebp),%edx
  800c37:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c3a:	0f b6 02             	movzbl (%edx),%eax
  800c3d:	3c 20                	cmp    $0x20,%al
  800c3f:	74 04                	je     800c45 <strtol+0x1a>
  800c41:	3c 09                	cmp    $0x9,%al
  800c43:	75 0e                	jne    800c53 <strtol+0x28>
		s++;
  800c45:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c48:	0f b6 02             	movzbl (%edx),%eax
  800c4b:	3c 20                	cmp    $0x20,%al
  800c4d:	74 f6                	je     800c45 <strtol+0x1a>
  800c4f:	3c 09                	cmp    $0x9,%al
  800c51:	74 f2                	je     800c45 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c53:	3c 2b                	cmp    $0x2b,%al
  800c55:	75 0c                	jne    800c63 <strtol+0x38>
		s++;
  800c57:	83 c2 01             	add    $0x1,%edx
  800c5a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c61:	eb 15                	jmp    800c78 <strtol+0x4d>
	else if (*s == '-')
  800c63:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c6a:	3c 2d                	cmp    $0x2d,%al
  800c6c:	75 0a                	jne    800c78 <strtol+0x4d>
		s++, neg = 1;
  800c6e:	83 c2 01             	add    $0x1,%edx
  800c71:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c78:	85 db                	test   %ebx,%ebx
  800c7a:	0f 94 c0             	sete   %al
  800c7d:	74 05                	je     800c84 <strtol+0x59>
  800c7f:	83 fb 10             	cmp    $0x10,%ebx
  800c82:	75 18                	jne    800c9c <strtol+0x71>
  800c84:	80 3a 30             	cmpb   $0x30,(%edx)
  800c87:	75 13                	jne    800c9c <strtol+0x71>
  800c89:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c8d:	8d 76 00             	lea    0x0(%esi),%esi
  800c90:	75 0a                	jne    800c9c <strtol+0x71>
		s += 2, base = 16;
  800c92:	83 c2 02             	add    $0x2,%edx
  800c95:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c9a:	eb 15                	jmp    800cb1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c9c:	84 c0                	test   %al,%al
  800c9e:	66 90                	xchg   %ax,%ax
  800ca0:	74 0f                	je     800cb1 <strtol+0x86>
  800ca2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800ca7:	80 3a 30             	cmpb   $0x30,(%edx)
  800caa:	75 05                	jne    800cb1 <strtol+0x86>
		s++, base = 8;
  800cac:	83 c2 01             	add    $0x1,%edx
  800caf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cb1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cb6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cb8:	0f b6 0a             	movzbl (%edx),%ecx
  800cbb:	89 cf                	mov    %ecx,%edi
  800cbd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cc0:	80 fb 09             	cmp    $0x9,%bl
  800cc3:	77 08                	ja     800ccd <strtol+0xa2>
			dig = *s - '0';
  800cc5:	0f be c9             	movsbl %cl,%ecx
  800cc8:	83 e9 30             	sub    $0x30,%ecx
  800ccb:	eb 1e                	jmp    800ceb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800ccd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800cd0:	80 fb 19             	cmp    $0x19,%bl
  800cd3:	77 08                	ja     800cdd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800cd5:	0f be c9             	movsbl %cl,%ecx
  800cd8:	83 e9 57             	sub    $0x57,%ecx
  800cdb:	eb 0e                	jmp    800ceb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800cdd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800ce0:	80 fb 19             	cmp    $0x19,%bl
  800ce3:	77 15                	ja     800cfa <strtol+0xcf>
			dig = *s - 'A' + 10;
  800ce5:	0f be c9             	movsbl %cl,%ecx
  800ce8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800ceb:	39 f1                	cmp    %esi,%ecx
  800ced:	7d 0b                	jge    800cfa <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800cef:	83 c2 01             	add    $0x1,%edx
  800cf2:	0f af c6             	imul   %esi,%eax
  800cf5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800cf8:	eb be                	jmp    800cb8 <strtol+0x8d>
  800cfa:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800cfc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d00:	74 05                	je     800d07 <strtol+0xdc>
		*endptr = (char *) s;
  800d02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d05:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d07:	89 ca                	mov    %ecx,%edx
  800d09:	f7 da                	neg    %edx
  800d0b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d0f:	0f 45 c2             	cmovne %edx,%eax
}
  800d12:	83 c4 04             	add    $0x4,%esp
  800d15:	5b                   	pop    %ebx
  800d16:	5e                   	pop    %esi
  800d17:	5f                   	pop    %edi
  800d18:	5d                   	pop    %ebp
  800d19:	c3                   	ret    

00800d1a <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800d1a:	55                   	push   %ebp
  800d1b:	89 e5                	mov    %esp,%ebp
  800d1d:	83 ec 0c             	sub    $0xc,%esp
  800d20:	89 1c 24             	mov    %ebx,(%esp)
  800d23:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d27:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d2b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d30:	b8 01 00 00 00       	mov    $0x1,%eax
  800d35:	89 d1                	mov    %edx,%ecx
  800d37:	89 d3                	mov    %edx,%ebx
  800d39:	89 d7                	mov    %edx,%edi
  800d3b:	89 d6                	mov    %edx,%esi
  800d3d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d3f:	8b 1c 24             	mov    (%esp),%ebx
  800d42:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d46:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d4a:	89 ec                	mov    %ebp,%esp
  800d4c:	5d                   	pop    %ebp
  800d4d:	c3                   	ret    

00800d4e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d4e:	55                   	push   %ebp
  800d4f:	89 e5                	mov    %esp,%ebp
  800d51:	83 ec 0c             	sub    $0xc,%esp
  800d54:	89 1c 24             	mov    %ebx,(%esp)
  800d57:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d5b:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d64:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d67:	8b 55 08             	mov    0x8(%ebp),%edx
  800d6a:	89 c3                	mov    %eax,%ebx
  800d6c:	89 c7                	mov    %eax,%edi
  800d6e:	89 c6                	mov    %eax,%esi
  800d70:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d72:	8b 1c 24             	mov    (%esp),%ebx
  800d75:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d79:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d7d:	89 ec                	mov    %ebp,%esp
  800d7f:	5d                   	pop    %ebp
  800d80:	c3                   	ret    

00800d81 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d81:	55                   	push   %ebp
  800d82:	89 e5                	mov    %esp,%ebp
  800d84:	83 ec 38             	sub    $0x38,%esp
  800d87:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d8a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d8d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d90:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d95:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d9a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9d:	89 cb                	mov    %ecx,%ebx
  800d9f:	89 cf                	mov    %ecx,%edi
  800da1:	89 ce                	mov    %ecx,%esi
  800da3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800da5:	85 c0                	test   %eax,%eax
  800da7:	7e 28                	jle    800dd1 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800da9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dad:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800db4:	00 
  800db5:	c7 44 24 08 84 16 80 	movl   $0x801684,0x8(%esp)
  800dbc:	00 
  800dbd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dc4:	00 
  800dc5:	c7 04 24 a1 16 80 00 	movl   $0x8016a1,(%esp)
  800dcc:	e8 b7 f3 ff ff       	call   800188 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800dd1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dd4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dd7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dda:	89 ec                	mov    %ebp,%esp
  800ddc:	5d                   	pop    %ebp
  800ddd:	c3                   	ret    

00800dde <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dde:	55                   	push   %ebp
  800ddf:	89 e5                	mov    %esp,%ebp
  800de1:	83 ec 0c             	sub    $0xc,%esp
  800de4:	89 1c 24             	mov    %ebx,(%esp)
  800de7:	89 74 24 04          	mov    %esi,0x4(%esp)
  800deb:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800def:	be 00 00 00 00       	mov    $0x0,%esi
  800df4:	b8 0b 00 00 00       	mov    $0xb,%eax
  800df9:	8b 7d 14             	mov    0x14(%ebp),%edi
  800dfc:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800dff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e02:	8b 55 08             	mov    0x8(%ebp),%edx
  800e05:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e07:	8b 1c 24             	mov    (%esp),%ebx
  800e0a:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e0e:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e12:	89 ec                	mov    %ebp,%esp
  800e14:	5d                   	pop    %ebp
  800e15:	c3                   	ret    

00800e16 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e16:	55                   	push   %ebp
  800e17:	89 e5                	mov    %esp,%ebp
  800e19:	83 ec 38             	sub    $0x38,%esp
  800e1c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e1f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e22:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e25:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e2a:	b8 09 00 00 00       	mov    $0x9,%eax
  800e2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e32:	8b 55 08             	mov    0x8(%ebp),%edx
  800e35:	89 df                	mov    %ebx,%edi
  800e37:	89 de                	mov    %ebx,%esi
  800e39:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e3b:	85 c0                	test   %eax,%eax
  800e3d:	7e 28                	jle    800e67 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e3f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e43:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e4a:	00 
  800e4b:	c7 44 24 08 84 16 80 	movl   $0x801684,0x8(%esp)
  800e52:	00 
  800e53:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e5a:	00 
  800e5b:	c7 04 24 a1 16 80 00 	movl   $0x8016a1,(%esp)
  800e62:	e8 21 f3 ff ff       	call   800188 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e67:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e6a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e6d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e70:	89 ec                	mov    %ebp,%esp
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e74:	55                   	push   %ebp
  800e75:	89 e5                	mov    %esp,%ebp
  800e77:	83 ec 38             	sub    $0x38,%esp
  800e7a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e7d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e80:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e83:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e88:	b8 08 00 00 00       	mov    $0x8,%eax
  800e8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e90:	8b 55 08             	mov    0x8(%ebp),%edx
  800e93:	89 df                	mov    %ebx,%edi
  800e95:	89 de                	mov    %ebx,%esi
  800e97:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e99:	85 c0                	test   %eax,%eax
  800e9b:	7e 28                	jle    800ec5 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e9d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ea1:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ea8:	00 
  800ea9:	c7 44 24 08 84 16 80 	movl   $0x801684,0x8(%esp)
  800eb0:	00 
  800eb1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800eb8:	00 
  800eb9:	c7 04 24 a1 16 80 00 	movl   $0x8016a1,(%esp)
  800ec0:	e8 c3 f2 ff ff       	call   800188 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ec5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ec8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ecb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ece:	89 ec                	mov    %ebp,%esp
  800ed0:	5d                   	pop    %ebp
  800ed1:	c3                   	ret    

00800ed2 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	83 ec 38             	sub    $0x38,%esp
  800ed8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800edb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ede:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ee1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ee6:	b8 06 00 00 00       	mov    $0x6,%eax
  800eeb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eee:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef1:	89 df                	mov    %ebx,%edi
  800ef3:	89 de                	mov    %ebx,%esi
  800ef5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	7e 28                	jle    800f23 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800efb:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eff:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f06:	00 
  800f07:	c7 44 24 08 84 16 80 	movl   $0x801684,0x8(%esp)
  800f0e:	00 
  800f0f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f16:	00 
  800f17:	c7 04 24 a1 16 80 00 	movl   $0x8016a1,(%esp)
  800f1e:	e8 65 f2 ff ff       	call   800188 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f23:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f26:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f29:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f2c:	89 ec                	mov    %ebp,%esp
  800f2e:	5d                   	pop    %ebp
  800f2f:	c3                   	ret    

00800f30 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f30:	55                   	push   %ebp
  800f31:	89 e5                	mov    %esp,%ebp
  800f33:	83 ec 38             	sub    $0x38,%esp
  800f36:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f39:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f3c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f3f:	b8 05 00 00 00       	mov    $0x5,%eax
  800f44:	8b 75 18             	mov    0x18(%ebp),%esi
  800f47:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f4a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f4d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f50:	8b 55 08             	mov    0x8(%ebp),%edx
  800f53:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f55:	85 c0                	test   %eax,%eax
  800f57:	7e 28                	jle    800f81 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f59:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f5d:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f64:	00 
  800f65:	c7 44 24 08 84 16 80 	movl   $0x801684,0x8(%esp)
  800f6c:	00 
  800f6d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f74:	00 
  800f75:	c7 04 24 a1 16 80 00 	movl   $0x8016a1,(%esp)
  800f7c:	e8 07 f2 ff ff       	call   800188 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f81:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f84:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f87:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f8a:	89 ec                	mov    %ebp,%esp
  800f8c:	5d                   	pop    %ebp
  800f8d:	c3                   	ret    

00800f8e <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f8e:	55                   	push   %ebp
  800f8f:	89 e5                	mov    %esp,%ebp
  800f91:	83 ec 38             	sub    $0x38,%esp
  800f94:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f97:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f9a:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f9d:	be 00 00 00 00       	mov    $0x0,%esi
  800fa2:	b8 04 00 00 00       	mov    $0x4,%eax
  800fa7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800faa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fad:	8b 55 08             	mov    0x8(%ebp),%edx
  800fb0:	89 f7                	mov    %esi,%edi
  800fb2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fb4:	85 c0                	test   %eax,%eax
  800fb6:	7e 28                	jle    800fe0 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fb8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fbc:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800fc3:	00 
  800fc4:	c7 44 24 08 84 16 80 	movl   $0x801684,0x8(%esp)
  800fcb:	00 
  800fcc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fd3:	00 
  800fd4:	c7 04 24 a1 16 80 00 	movl   $0x8016a1,(%esp)
  800fdb:	e8 a8 f1 ff ff       	call   800188 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800fe0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fe3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fe6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fe9:	89 ec                	mov    %ebp,%esp
  800feb:	5d                   	pop    %ebp
  800fec:	c3                   	ret    

00800fed <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	83 ec 0c             	sub    $0xc,%esp
  800ff3:	89 1c 24             	mov    %ebx,(%esp)
  800ff6:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ffa:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ffe:	ba 00 00 00 00       	mov    $0x0,%edx
  801003:	b8 0a 00 00 00       	mov    $0xa,%eax
  801008:	89 d1                	mov    %edx,%ecx
  80100a:	89 d3                	mov    %edx,%ebx
  80100c:	89 d7                	mov    %edx,%edi
  80100e:	89 d6                	mov    %edx,%esi
  801010:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801012:	8b 1c 24             	mov    (%esp),%ebx
  801015:	8b 74 24 04          	mov    0x4(%esp),%esi
  801019:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80101d:	89 ec                	mov    %ebp,%esp
  80101f:	5d                   	pop    %ebp
  801020:	c3                   	ret    

00801021 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	83 ec 0c             	sub    $0xc,%esp
  801027:	89 1c 24             	mov    %ebx,(%esp)
  80102a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80102e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801032:	ba 00 00 00 00       	mov    $0x0,%edx
  801037:	b8 02 00 00 00       	mov    $0x2,%eax
  80103c:	89 d1                	mov    %edx,%ecx
  80103e:	89 d3                	mov    %edx,%ebx
  801040:	89 d7                	mov    %edx,%edi
  801042:	89 d6                	mov    %edx,%esi
  801044:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801046:	8b 1c 24             	mov    (%esp),%ebx
  801049:	8b 74 24 04          	mov    0x4(%esp),%esi
  80104d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801051:	89 ec                	mov    %ebp,%esp
  801053:	5d                   	pop    %ebp
  801054:	c3                   	ret    

00801055 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	83 ec 38             	sub    $0x38,%esp
  80105b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80105e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801061:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801064:	b9 00 00 00 00       	mov    $0x0,%ecx
  801069:	b8 03 00 00 00       	mov    $0x3,%eax
  80106e:	8b 55 08             	mov    0x8(%ebp),%edx
  801071:	89 cb                	mov    %ecx,%ebx
  801073:	89 cf                	mov    %ecx,%edi
  801075:	89 ce                	mov    %ecx,%esi
  801077:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801079:	85 c0                	test   %eax,%eax
  80107b:	7e 28                	jle    8010a5 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80107d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801081:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801088:	00 
  801089:	c7 44 24 08 84 16 80 	movl   $0x801684,0x8(%esp)
  801090:	00 
  801091:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801098:	00 
  801099:	c7 04 24 a1 16 80 00 	movl   $0x8016a1,(%esp)
  8010a0:	e8 e3 f0 ff ff       	call   800188 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010a5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010a8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010ab:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010ae:	89 ec                	mov    %ebp,%esp
  8010b0:	5d                   	pop    %ebp
  8010b1:	c3                   	ret    
  8010b2:	66 90                	xchg   %ax,%ax
  8010b4:	66 90                	xchg   %ax,%ax
  8010b6:	66 90                	xchg   %ax,%ax
  8010b8:	66 90                	xchg   %ax,%ax
  8010ba:	66 90                	xchg   %ax,%ax
  8010bc:	66 90                	xchg   %ax,%ax
  8010be:	66 90                	xchg   %ax,%ax

008010c0 <__udivdi3>:
  8010c0:	55                   	push   %ebp
  8010c1:	89 e5                	mov    %esp,%ebp
  8010c3:	57                   	push   %edi
  8010c4:	56                   	push   %esi
  8010c5:	83 ec 10             	sub    $0x10,%esp
  8010c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8010cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8010ce:	8b 75 10             	mov    0x10(%ebp),%esi
  8010d1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8010d4:	85 c0                	test   %eax,%eax
  8010d6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8010d9:	75 35                	jne    801110 <__udivdi3+0x50>
  8010db:	39 fe                	cmp    %edi,%esi
  8010dd:	77 61                	ja     801140 <__udivdi3+0x80>
  8010df:	85 f6                	test   %esi,%esi
  8010e1:	75 0b                	jne    8010ee <__udivdi3+0x2e>
  8010e3:	b8 01 00 00 00       	mov    $0x1,%eax
  8010e8:	31 d2                	xor    %edx,%edx
  8010ea:	f7 f6                	div    %esi
  8010ec:	89 c6                	mov    %eax,%esi
  8010ee:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8010f1:	31 d2                	xor    %edx,%edx
  8010f3:	89 f8                	mov    %edi,%eax
  8010f5:	f7 f6                	div    %esi
  8010f7:	89 c7                	mov    %eax,%edi
  8010f9:	89 c8                	mov    %ecx,%eax
  8010fb:	f7 f6                	div    %esi
  8010fd:	89 c1                	mov    %eax,%ecx
  8010ff:	89 fa                	mov    %edi,%edx
  801101:	89 c8                	mov    %ecx,%eax
  801103:	83 c4 10             	add    $0x10,%esp
  801106:	5e                   	pop    %esi
  801107:	5f                   	pop    %edi
  801108:	5d                   	pop    %ebp
  801109:	c3                   	ret    
  80110a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801110:	39 f8                	cmp    %edi,%eax
  801112:	77 1c                	ja     801130 <__udivdi3+0x70>
  801114:	0f bd d0             	bsr    %eax,%edx
  801117:	83 f2 1f             	xor    $0x1f,%edx
  80111a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80111d:	75 39                	jne    801158 <__udivdi3+0x98>
  80111f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801122:	0f 86 a0 00 00 00    	jbe    8011c8 <__udivdi3+0x108>
  801128:	39 f8                	cmp    %edi,%eax
  80112a:	0f 82 98 00 00 00    	jb     8011c8 <__udivdi3+0x108>
  801130:	31 ff                	xor    %edi,%edi
  801132:	31 c9                	xor    %ecx,%ecx
  801134:	89 c8                	mov    %ecx,%eax
  801136:	89 fa                	mov    %edi,%edx
  801138:	83 c4 10             	add    $0x10,%esp
  80113b:	5e                   	pop    %esi
  80113c:	5f                   	pop    %edi
  80113d:	5d                   	pop    %ebp
  80113e:	c3                   	ret    
  80113f:	90                   	nop
  801140:	89 d1                	mov    %edx,%ecx
  801142:	89 fa                	mov    %edi,%edx
  801144:	89 c8                	mov    %ecx,%eax
  801146:	31 ff                	xor    %edi,%edi
  801148:	f7 f6                	div    %esi
  80114a:	89 c1                	mov    %eax,%ecx
  80114c:	89 fa                	mov    %edi,%edx
  80114e:	89 c8                	mov    %ecx,%eax
  801150:	83 c4 10             	add    $0x10,%esp
  801153:	5e                   	pop    %esi
  801154:	5f                   	pop    %edi
  801155:	5d                   	pop    %ebp
  801156:	c3                   	ret    
  801157:	90                   	nop
  801158:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80115c:	89 f2                	mov    %esi,%edx
  80115e:	d3 e0                	shl    %cl,%eax
  801160:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801163:	b8 20 00 00 00       	mov    $0x20,%eax
  801168:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80116b:	89 c1                	mov    %eax,%ecx
  80116d:	d3 ea                	shr    %cl,%edx
  80116f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801173:	0b 55 ec             	or     -0x14(%ebp),%edx
  801176:	d3 e6                	shl    %cl,%esi
  801178:	89 c1                	mov    %eax,%ecx
  80117a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80117d:	89 fe                	mov    %edi,%esi
  80117f:	d3 ee                	shr    %cl,%esi
  801181:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801185:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801188:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80118b:	d3 e7                	shl    %cl,%edi
  80118d:	89 c1                	mov    %eax,%ecx
  80118f:	d3 ea                	shr    %cl,%edx
  801191:	09 d7                	or     %edx,%edi
  801193:	89 f2                	mov    %esi,%edx
  801195:	89 f8                	mov    %edi,%eax
  801197:	f7 75 ec             	divl   -0x14(%ebp)
  80119a:	89 d6                	mov    %edx,%esi
  80119c:	89 c7                	mov    %eax,%edi
  80119e:	f7 65 e8             	mull   -0x18(%ebp)
  8011a1:	39 d6                	cmp    %edx,%esi
  8011a3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8011a6:	72 30                	jb     8011d8 <__udivdi3+0x118>
  8011a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011ab:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011af:	d3 e2                	shl    %cl,%edx
  8011b1:	39 c2                	cmp    %eax,%edx
  8011b3:	73 05                	jae    8011ba <__udivdi3+0xfa>
  8011b5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8011b8:	74 1e                	je     8011d8 <__udivdi3+0x118>
  8011ba:	89 f9                	mov    %edi,%ecx
  8011bc:	31 ff                	xor    %edi,%edi
  8011be:	e9 71 ff ff ff       	jmp    801134 <__udivdi3+0x74>
  8011c3:	90                   	nop
  8011c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011c8:	31 ff                	xor    %edi,%edi
  8011ca:	b9 01 00 00 00       	mov    $0x1,%ecx
  8011cf:	e9 60 ff ff ff       	jmp    801134 <__udivdi3+0x74>
  8011d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011d8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8011db:	31 ff                	xor    %edi,%edi
  8011dd:	89 c8                	mov    %ecx,%eax
  8011df:	89 fa                	mov    %edi,%edx
  8011e1:	83 c4 10             	add    $0x10,%esp
  8011e4:	5e                   	pop    %esi
  8011e5:	5f                   	pop    %edi
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    
  8011e8:	66 90                	xchg   %ax,%ax
  8011ea:	66 90                	xchg   %ax,%ax
  8011ec:	66 90                	xchg   %ax,%ax
  8011ee:	66 90                	xchg   %ax,%ax

008011f0 <__umoddi3>:
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	57                   	push   %edi
  8011f4:	56                   	push   %esi
  8011f5:	83 ec 20             	sub    $0x20,%esp
  8011f8:	8b 55 14             	mov    0x14(%ebp),%edx
  8011fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  801201:	8b 75 0c             	mov    0xc(%ebp),%esi
  801204:	85 d2                	test   %edx,%edx
  801206:	89 c8                	mov    %ecx,%eax
  801208:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80120b:	75 13                	jne    801220 <__umoddi3+0x30>
  80120d:	39 f7                	cmp    %esi,%edi
  80120f:	76 3f                	jbe    801250 <__umoddi3+0x60>
  801211:	89 f2                	mov    %esi,%edx
  801213:	f7 f7                	div    %edi
  801215:	89 d0                	mov    %edx,%eax
  801217:	31 d2                	xor    %edx,%edx
  801219:	83 c4 20             	add    $0x20,%esp
  80121c:	5e                   	pop    %esi
  80121d:	5f                   	pop    %edi
  80121e:	5d                   	pop    %ebp
  80121f:	c3                   	ret    
  801220:	39 f2                	cmp    %esi,%edx
  801222:	77 4c                	ja     801270 <__umoddi3+0x80>
  801224:	0f bd ca             	bsr    %edx,%ecx
  801227:	83 f1 1f             	xor    $0x1f,%ecx
  80122a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80122d:	75 51                	jne    801280 <__umoddi3+0x90>
  80122f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801232:	0f 87 e0 00 00 00    	ja     801318 <__umoddi3+0x128>
  801238:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80123b:	29 f8                	sub    %edi,%eax
  80123d:	19 d6                	sbb    %edx,%esi
  80123f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801242:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801245:	89 f2                	mov    %esi,%edx
  801247:	83 c4 20             	add    $0x20,%esp
  80124a:	5e                   	pop    %esi
  80124b:	5f                   	pop    %edi
  80124c:	5d                   	pop    %ebp
  80124d:	c3                   	ret    
  80124e:	66 90                	xchg   %ax,%ax
  801250:	85 ff                	test   %edi,%edi
  801252:	75 0b                	jne    80125f <__umoddi3+0x6f>
  801254:	b8 01 00 00 00       	mov    $0x1,%eax
  801259:	31 d2                	xor    %edx,%edx
  80125b:	f7 f7                	div    %edi
  80125d:	89 c7                	mov    %eax,%edi
  80125f:	89 f0                	mov    %esi,%eax
  801261:	31 d2                	xor    %edx,%edx
  801263:	f7 f7                	div    %edi
  801265:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801268:	f7 f7                	div    %edi
  80126a:	eb a9                	jmp    801215 <__umoddi3+0x25>
  80126c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801270:	89 c8                	mov    %ecx,%eax
  801272:	89 f2                	mov    %esi,%edx
  801274:	83 c4 20             	add    $0x20,%esp
  801277:	5e                   	pop    %esi
  801278:	5f                   	pop    %edi
  801279:	5d                   	pop    %ebp
  80127a:	c3                   	ret    
  80127b:	90                   	nop
  80127c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801280:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801284:	d3 e2                	shl    %cl,%edx
  801286:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801289:	ba 20 00 00 00       	mov    $0x20,%edx
  80128e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801291:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801294:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801298:	89 fa                	mov    %edi,%edx
  80129a:	d3 ea                	shr    %cl,%edx
  80129c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012a0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8012a3:	d3 e7                	shl    %cl,%edi
  8012a5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8012ac:	89 f2                	mov    %esi,%edx
  8012ae:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8012b1:	89 c7                	mov    %eax,%edi
  8012b3:	d3 ea                	shr    %cl,%edx
  8012b5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012b9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8012bc:	89 c2                	mov    %eax,%edx
  8012be:	d3 e6                	shl    %cl,%esi
  8012c0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012c4:	d3 ea                	shr    %cl,%edx
  8012c6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012ca:	09 d6                	or     %edx,%esi
  8012cc:	89 f0                	mov    %esi,%eax
  8012ce:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8012d1:	d3 e7                	shl    %cl,%edi
  8012d3:	89 f2                	mov    %esi,%edx
  8012d5:	f7 75 f4             	divl   -0xc(%ebp)
  8012d8:	89 d6                	mov    %edx,%esi
  8012da:	f7 65 e8             	mull   -0x18(%ebp)
  8012dd:	39 d6                	cmp    %edx,%esi
  8012df:	72 2b                	jb     80130c <__umoddi3+0x11c>
  8012e1:	39 c7                	cmp    %eax,%edi
  8012e3:	72 23                	jb     801308 <__umoddi3+0x118>
  8012e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012e9:	29 c7                	sub    %eax,%edi
  8012eb:	19 d6                	sbb    %edx,%esi
  8012ed:	89 f0                	mov    %esi,%eax
  8012ef:	89 f2                	mov    %esi,%edx
  8012f1:	d3 ef                	shr    %cl,%edi
  8012f3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012f7:	d3 e0                	shl    %cl,%eax
  8012f9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012fd:	09 f8                	or     %edi,%eax
  8012ff:	d3 ea                	shr    %cl,%edx
  801301:	83 c4 20             	add    $0x20,%esp
  801304:	5e                   	pop    %esi
  801305:	5f                   	pop    %edi
  801306:	5d                   	pop    %ebp
  801307:	c3                   	ret    
  801308:	39 d6                	cmp    %edx,%esi
  80130a:	75 d9                	jne    8012e5 <__umoddi3+0xf5>
  80130c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80130f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801312:	eb d1                	jmp    8012e5 <__umoddi3+0xf5>
  801314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801318:	39 f2                	cmp    %esi,%edx
  80131a:	0f 82 18 ff ff ff    	jb     801238 <__umoddi3+0x48>
  801320:	e9 1d ff ff ff       	jmp    801242 <__umoddi3+0x52>
