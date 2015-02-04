
obj/user/primes：     文件格式 elf32-i386


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
  80002c:	e8 1b 01 00 00       	call   80014c <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(void)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	int i, id, p;
	envid_t envid;

	// fetch a prime from our left neighbor
top:
	p = ipc_recv(&envid, 0, 0);
  80003c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80003f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800046:	00 
  800047:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80004e:	00 
  80004f:	89 34 24             	mov    %esi,(%esp)
  800052:	e8 35 11 00 00       	call   80118c <ipc_recv>
  800057:	89 c3                	mov    %eax,%ebx
	cprintf("CPU %d: %d ", thisenv->env_cpunum, p);
  800059:	a1 04 20 80 00       	mov    0x802004,%eax
  80005e:	8b 40 5c             	mov    0x5c(%eax),%eax
  800061:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800065:	89 44 24 04          	mov    %eax,0x4(%esp)
  800069:	c7 04 24 20 14 80 00 	movl   $0x801420,(%esp)
  800070:	e8 fb 01 00 00       	call   800270 <cprintf>

	// fork a right neighbor to continue the chain
	if ((id = fork()) < 0)
  800075:	e8 8a 10 00 00       	call   801104 <fork>
  80007a:	89 c7                	mov    %eax,%edi
  80007c:	85 c0                	test   %eax,%eax
  80007e:	79 20                	jns    8000a0 <primeproc+0x6d>
		panic("fork: %e", id);
  800080:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800084:	c7 44 24 08 2c 14 80 	movl   $0x80142c,0x8(%esp)
  80008b:	00 
  80008c:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  800093:	00 
  800094:	c7 04 24 35 14 80 00 	movl   $0x801435,(%esp)
  80009b:	e8 19 01 00 00       	call   8001b9 <_panic>
	if (id == 0)
  8000a0:	85 c0                	test   %eax,%eax
  8000a2:	74 9b                	je     80003f <primeproc+0xc>
		goto top;

	// filter out multiples of our prime
	while (1) {
		i = ipc_recv(&envid, 0, 0);
  8000a4:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000a7:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000ae:	00 
  8000af:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8000b6:	00 
  8000b7:	89 34 24             	mov    %esi,(%esp)
  8000ba:	e8 cd 10 00 00       	call   80118c <ipc_recv>
  8000bf:	89 c1                	mov    %eax,%ecx
		if (i % p)
  8000c1:	89 c2                	mov    %eax,%edx
  8000c3:	c1 fa 1f             	sar    $0x1f,%edx
  8000c6:	f7 fb                	idiv   %ebx
  8000c8:	85 d2                	test   %edx,%edx
  8000ca:	74 db                	je     8000a7 <primeproc+0x74>
			ipc_send(id, i, 0, 0);
  8000cc:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d3:	00 
  8000d4:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000db:	00 
  8000dc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8000e0:	89 3c 24             	mov    %edi,(%esp)
  8000e3:	e8 82 10 00 00       	call   80116a <ipc_send>
  8000e8:	eb bd                	jmp    8000a7 <primeproc+0x74>

008000ea <umain>:
	}
}

void
umain(int argc, char **argv)
{
  8000ea:	55                   	push   %ebp
  8000eb:	89 e5                	mov    %esp,%ebp
  8000ed:	56                   	push   %esi
  8000ee:	53                   	push   %ebx
  8000ef:	83 ec 10             	sub    $0x10,%esp
	int i, id;

	// fork the first prime process in the chain
	if ((id = fork()) < 0)
  8000f2:	e8 0d 10 00 00       	call   801104 <fork>
  8000f7:	89 c6                	mov    %eax,%esi
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	79 20                	jns    80011d <umain+0x33>
		panic("fork: %e", id);
  8000fd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800101:	c7 44 24 08 2c 14 80 	movl   $0x80142c,0x8(%esp)
  800108:	00 
  800109:	c7 44 24 04 2d 00 00 	movl   $0x2d,0x4(%esp)
  800110:	00 
  800111:	c7 04 24 35 14 80 00 	movl   $0x801435,(%esp)
  800118:	e8 9c 00 00 00       	call   8001b9 <_panic>
	if (id == 0)
  80011d:	bb 02 00 00 00       	mov    $0x2,%ebx
  800122:	85 c0                	test   %eax,%eax
  800124:	75 05                	jne    80012b <umain+0x41>
		primeproc();
  800126:	e8 08 ff ff ff       	call   800033 <primeproc>

	// feed all the integers through
	for (i = 2; ; i++)
		ipc_send(id, i, 0, 0);
  80012b:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800132:	00 
  800133:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80013a:	00 
  80013b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80013f:	89 34 24             	mov    %esi,(%esp)
  800142:	e8 23 10 00 00       	call   80116a <ipc_send>
		panic("fork: %e", id);
	if (id == 0)
		primeproc();

	// feed all the integers through
	for (i = 2; ; i++)
  800147:	83 c3 01             	add    $0x1,%ebx
  80014a:	eb df                	jmp    80012b <umain+0x41>

0080014c <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 18             	sub    $0x18,%esp
  800152:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800155:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800158:	8b 75 08             	mov    0x8(%ebp),%esi
  80015b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80015e:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800165:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800168:	e8 e4 0e 00 00       	call   801051 <sys_getenvid>
  80016d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800172:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800175:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80017a:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80017f:	85 f6                	test   %esi,%esi
  800181:	7e 07                	jle    80018a <libmain+0x3e>
		binaryname = argv[0];
  800183:	8b 03                	mov    (%ebx),%eax
  800185:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80018a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80018e:	89 34 24             	mov    %esi,(%esp)
  800191:	e8 54 ff ff ff       	call   8000ea <umain>

	// exit gracefully
	exit();
  800196:	e8 0a 00 00 00       	call   8001a5 <exit>
}
  80019b:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80019e:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8001a1:	89 ec                	mov    %ebp,%esp
  8001a3:	5d                   	pop    %ebp
  8001a4:	c3                   	ret    

008001a5 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8001ab:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8001b2:	e8 ce 0e 00 00       	call   801085 <sys_env_destroy>
}
  8001b7:	c9                   	leave  
  8001b8:	c3                   	ret    

008001b9 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001b9:	55                   	push   %ebp
  8001ba:	89 e5                	mov    %esp,%ebp
  8001bc:	56                   	push   %esi
  8001bd:	53                   	push   %ebx
  8001be:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8001c1:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001c4:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001ca:	e8 82 0e 00 00       	call   801051 <sys_getenvid>
  8001cf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001d2:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001d6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d9:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001dd:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001e5:	c7 04 24 50 14 80 00 	movl   $0x801450,(%esp)
  8001ec:	e8 7f 00 00 00       	call   800270 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001f1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001f5:	8b 45 10             	mov    0x10(%ebp),%eax
  8001f8:	89 04 24             	mov    %eax,(%esp)
  8001fb:	e8 0f 00 00 00       	call   80020f <vcprintf>
	cprintf("\n");
  800200:	c7 04 24 74 14 80 00 	movl   $0x801474,(%esp)
  800207:	e8 64 00 00 00       	call   800270 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80020c:	cc                   	int3   
  80020d:	eb fd                	jmp    80020c <_panic+0x53>

0080020f <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80020f:	55                   	push   %ebp
  800210:	89 e5                	mov    %esp,%ebp
  800212:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800218:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80021f:	00 00 00 
	b.cnt = 0;
  800222:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800229:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80022c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80022f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800233:	8b 45 08             	mov    0x8(%ebp),%eax
  800236:	89 44 24 08          	mov    %eax,0x8(%esp)
  80023a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800240:	89 44 24 04          	mov    %eax,0x4(%esp)
  800244:	c7 04 24 8a 02 80 00 	movl   $0x80028a,(%esp)
  80024b:	e8 cd 01 00 00       	call   80041d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800250:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800256:	89 44 24 04          	mov    %eax,0x4(%esp)
  80025a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800260:	89 04 24             	mov    %eax,(%esp)
  800263:	e8 16 0b 00 00       	call   800d7e <sys_cputs>

	return b.cnt;
}
  800268:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80026e:	c9                   	leave  
  80026f:	c3                   	ret    

00800270 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800270:	55                   	push   %ebp
  800271:	89 e5                	mov    %esp,%ebp
  800273:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800276:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800279:	89 44 24 04          	mov    %eax,0x4(%esp)
  80027d:	8b 45 08             	mov    0x8(%ebp),%eax
  800280:	89 04 24             	mov    %eax,(%esp)
  800283:	e8 87 ff ff ff       	call   80020f <vcprintf>
	va_end(ap);

	return cnt;
}
  800288:	c9                   	leave  
  800289:	c3                   	ret    

0080028a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	53                   	push   %ebx
  80028e:	83 ec 14             	sub    $0x14,%esp
  800291:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800294:	8b 03                	mov    (%ebx),%eax
  800296:	8b 55 08             	mov    0x8(%ebp),%edx
  800299:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80029d:	83 c0 01             	add    $0x1,%eax
  8002a0:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8002a2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8002a7:	75 19                	jne    8002c2 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8002a9:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8002b0:	00 
  8002b1:	8d 43 08             	lea    0x8(%ebx),%eax
  8002b4:	89 04 24             	mov    %eax,(%esp)
  8002b7:	e8 c2 0a 00 00       	call   800d7e <sys_cputs>
		b->idx = 0;
  8002bc:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8002c2:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002c6:	83 c4 14             	add    $0x14,%esp
  8002c9:	5b                   	pop    %ebx
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    
  8002cc:	66 90                	xchg   %ax,%ax
  8002ce:	66 90                	xchg   %ax,%ax

008002d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 4c             	sub    $0x4c,%esp
  8002d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002dc:	89 d6                	mov    %edx,%esi
  8002de:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8002ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002f0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002fb:	39 d1                	cmp    %edx,%ecx
  8002fd:	72 15                	jb     800314 <printnum+0x44>
  8002ff:	77 07                	ja     800308 <printnum+0x38>
  800301:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800304:	39 d0                	cmp    %edx,%eax
  800306:	76 0c                	jbe    800314 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800308:	83 eb 01             	sub    $0x1,%ebx
  80030b:	85 db                	test   %ebx,%ebx
  80030d:	8d 76 00             	lea    0x0(%esi),%esi
  800310:	7f 61                	jg     800373 <printnum+0xa3>
  800312:	eb 70                	jmp    800384 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800314:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800318:	83 eb 01             	sub    $0x1,%ebx
  80031b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80031f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800323:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800327:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80032b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80032e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800331:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800334:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800338:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80033f:	00 
  800340:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800343:	89 04 24             	mov    %eax,(%esp)
  800346:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800349:	89 54 24 04          	mov    %edx,0x4(%esp)
  80034d:	e8 5e 0e 00 00       	call   8011b0 <__udivdi3>
  800352:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800355:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800358:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80035c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800360:	89 04 24             	mov    %eax,(%esp)
  800363:	89 54 24 04          	mov    %edx,0x4(%esp)
  800367:	89 f2                	mov    %esi,%edx
  800369:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80036c:	e8 5f ff ff ff       	call   8002d0 <printnum>
  800371:	eb 11                	jmp    800384 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800373:	89 74 24 04          	mov    %esi,0x4(%esp)
  800377:	89 3c 24             	mov    %edi,(%esp)
  80037a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80037d:	83 eb 01             	sub    $0x1,%ebx
  800380:	85 db                	test   %ebx,%ebx
  800382:	7f ef                	jg     800373 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800384:	89 74 24 04          	mov    %esi,0x4(%esp)
  800388:	8b 74 24 04          	mov    0x4(%esp),%esi
  80038c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80038f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800393:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80039a:	00 
  80039b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80039e:	89 14 24             	mov    %edx,(%esp)
  8003a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8003a4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8003a8:	e8 33 0f 00 00       	call   8012e0 <__umoddi3>
  8003ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003b1:	0f be 80 76 14 80 00 	movsbl 0x801476(%eax),%eax
  8003b8:	89 04 24             	mov    %eax,(%esp)
  8003bb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8003be:	83 c4 4c             	add    $0x4c,%esp
  8003c1:	5b                   	pop    %ebx
  8003c2:	5e                   	pop    %esi
  8003c3:	5f                   	pop    %edi
  8003c4:	5d                   	pop    %ebp
  8003c5:	c3                   	ret    

008003c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003c6:	55                   	push   %ebp
  8003c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003c9:	83 fa 01             	cmp    $0x1,%edx
  8003cc:	7e 0e                	jle    8003dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ce:	8b 10                	mov    (%eax),%edx
  8003d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003d3:	89 08                	mov    %ecx,(%eax)
  8003d5:	8b 02                	mov    (%edx),%eax
  8003d7:	8b 52 04             	mov    0x4(%edx),%edx
  8003da:	eb 22                	jmp    8003fe <getuint+0x38>
	else if (lflag)
  8003dc:	85 d2                	test   %edx,%edx
  8003de:	74 10                	je     8003f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003e0:	8b 10                	mov    (%eax),%edx
  8003e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003e5:	89 08                	mov    %ecx,(%eax)
  8003e7:	8b 02                	mov    (%edx),%eax
  8003e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ee:	eb 0e                	jmp    8003fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003f0:	8b 10                	mov    (%eax),%edx
  8003f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003f5:	89 08                	mov    %ecx,(%eax)
  8003f7:	8b 02                	mov    (%edx),%eax
  8003f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003fe:	5d                   	pop    %ebp
  8003ff:	c3                   	ret    

00800400 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800400:	55                   	push   %ebp
  800401:	89 e5                	mov    %esp,%ebp
  800403:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800406:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80040a:	8b 10                	mov    (%eax),%edx
  80040c:	3b 50 04             	cmp    0x4(%eax),%edx
  80040f:	73 0a                	jae    80041b <sprintputch+0x1b>
		*b->buf++ = ch;
  800411:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800414:	88 0a                	mov    %cl,(%edx)
  800416:	83 c2 01             	add    $0x1,%edx
  800419:	89 10                	mov    %edx,(%eax)
}
  80041b:	5d                   	pop    %ebp
  80041c:	c3                   	ret    

0080041d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80041d:	55                   	push   %ebp
  80041e:	89 e5                	mov    %esp,%ebp
  800420:	57                   	push   %edi
  800421:	56                   	push   %esi
  800422:	53                   	push   %ebx
  800423:	83 ec 5c             	sub    $0x5c,%esp
  800426:	8b 7d 08             	mov    0x8(%ebp),%edi
  800429:	8b 75 0c             	mov    0xc(%ebp),%esi
  80042c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80042f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800436:	eb 11                	jmp    800449 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800438:	85 c0                	test   %eax,%eax
  80043a:	0f 84 16 04 00 00    	je     800856 <vprintfmt+0x439>
				return;
			putch(ch, putdat);
  800440:	89 74 24 04          	mov    %esi,0x4(%esp)
  800444:	89 04 24             	mov    %eax,(%esp)
  800447:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800449:	0f b6 03             	movzbl (%ebx),%eax
  80044c:	83 c3 01             	add    $0x1,%ebx
  80044f:	83 f8 25             	cmp    $0x25,%eax
  800452:	75 e4                	jne    800438 <vprintfmt+0x1b>
  800454:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80045b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800462:	b9 00 00 00 00       	mov    $0x0,%ecx
  800467:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80046b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800472:	eb 06                	jmp    80047a <vprintfmt+0x5d>
  800474:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800478:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80047a:	0f b6 13             	movzbl (%ebx),%edx
  80047d:	0f b6 c2             	movzbl %dl,%eax
  800480:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800483:	8d 43 01             	lea    0x1(%ebx),%eax
  800486:	83 ea 23             	sub    $0x23,%edx
  800489:	80 fa 55             	cmp    $0x55,%dl
  80048c:	0f 87 a7 03 00 00    	ja     800839 <vprintfmt+0x41c>
  800492:	0f b6 d2             	movzbl %dl,%edx
  800495:	ff 24 95 40 15 80 00 	jmp    *0x801540(,%edx,4)
  80049c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8004a0:	eb d6                	jmp    800478 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8004a2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004a5:	83 ea 30             	sub    $0x30,%edx
  8004a8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8004ab:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004ae:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8004b1:	83 fb 09             	cmp    $0x9,%ebx
  8004b4:	77 54                	ja     80050a <vprintfmt+0xed>
  8004b6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8004b9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8004bc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8004bf:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004c2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8004c6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004c9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8004cc:	83 fb 09             	cmp    $0x9,%ebx
  8004cf:	76 eb                	jbe    8004bc <vprintfmt+0x9f>
  8004d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004d4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004d7:	eb 31                	jmp    80050a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004d9:	8b 55 14             	mov    0x14(%ebp),%edx
  8004dc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8004df:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004e2:	8b 12                	mov    (%edx),%edx
  8004e4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8004e7:	eb 21                	jmp    80050a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8004e9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8004f2:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  8004f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004f9:	e9 7a ff ff ff       	jmp    800478 <vprintfmt+0x5b>
  8004fe:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800505:	e9 6e ff ff ff       	jmp    800478 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80050a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80050e:	0f 89 64 ff ff ff    	jns    800478 <vprintfmt+0x5b>
  800514:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800517:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80051a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80051d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800520:	e9 53 ff ff ff       	jmp    800478 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800525:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800528:	e9 4b ff ff ff       	jmp    800478 <vprintfmt+0x5b>
  80052d:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800530:	8b 45 14             	mov    0x14(%ebp),%eax
  800533:	8d 50 04             	lea    0x4(%eax),%edx
  800536:	89 55 14             	mov    %edx,0x14(%ebp)
  800539:	89 74 24 04          	mov    %esi,0x4(%esp)
  80053d:	8b 00                	mov    (%eax),%eax
  80053f:	89 04 24             	mov    %eax,(%esp)
  800542:	ff d7                	call   *%edi
  800544:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800547:	e9 fd fe ff ff       	jmp    800449 <vprintfmt+0x2c>
  80054c:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80054f:	8b 45 14             	mov    0x14(%ebp),%eax
  800552:	8d 50 04             	lea    0x4(%eax),%edx
  800555:	89 55 14             	mov    %edx,0x14(%ebp)
  800558:	8b 00                	mov    (%eax),%eax
  80055a:	89 c2                	mov    %eax,%edx
  80055c:	c1 fa 1f             	sar    $0x1f,%edx
  80055f:	31 d0                	xor    %edx,%eax
  800561:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800563:	83 f8 08             	cmp    $0x8,%eax
  800566:	7f 0b                	jg     800573 <vprintfmt+0x156>
  800568:	8b 14 85 a0 16 80 00 	mov    0x8016a0(,%eax,4),%edx
  80056f:	85 d2                	test   %edx,%edx
  800571:	75 20                	jne    800593 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800573:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800577:	c7 44 24 08 87 14 80 	movl   $0x801487,0x8(%esp)
  80057e:	00 
  80057f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800583:	89 3c 24             	mov    %edi,(%esp)
  800586:	e8 53 03 00 00       	call   8008de <printfmt>
  80058b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80058e:	e9 b6 fe ff ff       	jmp    800449 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800593:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800597:	c7 44 24 08 90 14 80 	movl   $0x801490,0x8(%esp)
  80059e:	00 
  80059f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8005a3:	89 3c 24             	mov    %edi,(%esp)
  8005a6:	e8 33 03 00 00       	call   8008de <printfmt>
  8005ab:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005ae:	e9 96 fe ff ff       	jmp    800449 <vprintfmt+0x2c>
  8005b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005b6:	89 c3                	mov    %eax,%ebx
  8005b8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8005bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005be:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c4:	8d 50 04             	lea    0x4(%eax),%edx
  8005c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005ca:	8b 00                	mov    (%eax),%eax
  8005cc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8005cf:	85 c0                	test   %eax,%eax
  8005d1:	b8 93 14 80 00       	mov    $0x801493,%eax
  8005d6:	0f 45 45 c4          	cmovne -0x3c(%ebp),%eax
  8005da:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8005dd:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8005e1:	7e 06                	jle    8005e9 <vprintfmt+0x1cc>
  8005e3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8005e7:	75 13                	jne    8005fc <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005e9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005ec:	0f be 02             	movsbl (%edx),%eax
  8005ef:	85 c0                	test   %eax,%eax
  8005f1:	0f 85 9b 00 00 00    	jne    800692 <vprintfmt+0x275>
  8005f7:	e9 88 00 00 00       	jmp    800684 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005fc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800600:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  800603:	89 0c 24             	mov    %ecx,(%esp)
  800606:	e8 20 03 00 00       	call   80092b <strnlen>
  80060b:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80060e:	29 c2                	sub    %eax,%edx
  800610:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800613:	85 d2                	test   %edx,%edx
  800615:	7e d2                	jle    8005e9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800617:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  80061b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80061e:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800621:	89 d3                	mov    %edx,%ebx
  800623:	89 74 24 04          	mov    %esi,0x4(%esp)
  800627:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80062a:	89 04 24             	mov    %eax,(%esp)
  80062d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80062f:	83 eb 01             	sub    $0x1,%ebx
  800632:	85 db                	test   %ebx,%ebx
  800634:	7f ed                	jg     800623 <vprintfmt+0x206>
  800636:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  800639:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800640:	eb a7                	jmp    8005e9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800642:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800646:	74 1a                	je     800662 <vprintfmt+0x245>
  800648:	8d 50 e0             	lea    -0x20(%eax),%edx
  80064b:	83 fa 5e             	cmp    $0x5e,%edx
  80064e:	76 12                	jbe    800662 <vprintfmt+0x245>
					putch('?', putdat);
  800650:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800654:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80065b:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80065e:	66 90                	xchg   %ax,%ax
  800660:	eb 0a                	jmp    80066c <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800662:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800666:	89 04 24             	mov    %eax,(%esp)
  800669:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80066c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800670:	0f be 03             	movsbl (%ebx),%eax
  800673:	85 c0                	test   %eax,%eax
  800675:	74 05                	je     80067c <vprintfmt+0x25f>
  800677:	83 c3 01             	add    $0x1,%ebx
  80067a:	eb 29                	jmp    8006a5 <vprintfmt+0x288>
  80067c:	89 fe                	mov    %edi,%esi
  80067e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800681:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800684:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800688:	7f 2e                	jg     8006b8 <vprintfmt+0x29b>
  80068a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80068d:	e9 b7 fd ff ff       	jmp    800449 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800692:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800695:	83 c2 01             	add    $0x1,%edx
  800698:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80069b:	89 f7                	mov    %esi,%edi
  80069d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8006a0:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8006a3:	89 d3                	mov    %edx,%ebx
  8006a5:	85 f6                	test   %esi,%esi
  8006a7:	78 99                	js     800642 <vprintfmt+0x225>
  8006a9:	83 ee 01             	sub    $0x1,%esi
  8006ac:	79 94                	jns    800642 <vprintfmt+0x225>
  8006ae:	89 fe                	mov    %edi,%esi
  8006b0:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8006b3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8006b6:	eb cc                	jmp    800684 <vprintfmt+0x267>
  8006b8:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8006bb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8006be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006c2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006c9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006cb:	83 eb 01             	sub    $0x1,%ebx
  8006ce:	85 db                	test   %ebx,%ebx
  8006d0:	7f ec                	jg     8006be <vprintfmt+0x2a1>
  8006d2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006d5:	e9 6f fd ff ff       	jmp    800449 <vprintfmt+0x2c>
  8006da:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006dd:	83 f9 01             	cmp    $0x1,%ecx
  8006e0:	7e 16                	jle    8006f8 <vprintfmt+0x2db>
		return va_arg(*ap, long long);
  8006e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e5:	8d 50 08             	lea    0x8(%eax),%edx
  8006e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006eb:	8b 10                	mov    (%eax),%edx
  8006ed:	8b 48 04             	mov    0x4(%eax),%ecx
  8006f0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006f3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006f6:	eb 32                	jmp    80072a <vprintfmt+0x30d>
	else if (lflag)
  8006f8:	85 c9                	test   %ecx,%ecx
  8006fa:	74 18                	je     800714 <vprintfmt+0x2f7>
		return va_arg(*ap, long);
  8006fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006ff:	8d 50 04             	lea    0x4(%eax),%edx
  800702:	89 55 14             	mov    %edx,0x14(%ebp)
  800705:	8b 00                	mov    (%eax),%eax
  800707:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80070a:	89 c1                	mov    %eax,%ecx
  80070c:	c1 f9 1f             	sar    $0x1f,%ecx
  80070f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800712:	eb 16                	jmp    80072a <vprintfmt+0x30d>
	else
		return va_arg(*ap, int);
  800714:	8b 45 14             	mov    0x14(%ebp),%eax
  800717:	8d 50 04             	lea    0x4(%eax),%edx
  80071a:	89 55 14             	mov    %edx,0x14(%ebp)
  80071d:	8b 00                	mov    (%eax),%eax
  80071f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800722:	89 c2                	mov    %eax,%edx
  800724:	c1 fa 1f             	sar    $0x1f,%edx
  800727:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80072a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80072d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800730:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800735:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800739:	0f 89 b8 00 00 00    	jns    8007f7 <vprintfmt+0x3da>
				putch('-', putdat);
  80073f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800743:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80074a:	ff d7                	call   *%edi
				num = -(long long) num;
  80074c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80074f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800752:	f7 d9                	neg    %ecx
  800754:	83 d3 00             	adc    $0x0,%ebx
  800757:	f7 db                	neg    %ebx
  800759:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075e:	e9 94 00 00 00       	jmp    8007f7 <vprintfmt+0x3da>
  800763:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800766:	89 ca                	mov    %ecx,%edx
  800768:	8d 45 14             	lea    0x14(%ebp),%eax
  80076b:	e8 56 fc ff ff       	call   8003c6 <getuint>
  800770:	89 c1                	mov    %eax,%ecx
  800772:	89 d3                	mov    %edx,%ebx
  800774:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800779:	eb 7c                	jmp    8007f7 <vprintfmt+0x3da>
  80077b:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80077e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800782:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800789:	ff d7                	call   *%edi
			putch('X', putdat);
  80078b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80078f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800796:	ff d7                	call   *%edi
			putch('X', putdat);
  800798:	89 74 24 04          	mov    %esi,0x4(%esp)
  80079c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8007a3:	ff d7                	call   *%edi
  8007a5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8007a8:	e9 9c fc ff ff       	jmp    800449 <vprintfmt+0x2c>
  8007ad:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8007b0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007b4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8007bb:	ff d7                	call   *%edi
			putch('x', putdat);
  8007bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c1:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007c8:	ff d7                	call   *%edi
			num = (unsigned long long)
  8007ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cd:	8d 50 04             	lea    0x4(%eax),%edx
  8007d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d3:	8b 08                	mov    (%eax),%ecx
  8007d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007da:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007df:	eb 16                	jmp    8007f7 <vprintfmt+0x3da>
  8007e1:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007e4:	89 ca                	mov    %ecx,%edx
  8007e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007e9:	e8 d8 fb ff ff       	call   8003c6 <getuint>
  8007ee:	89 c1                	mov    %eax,%ecx
  8007f0:	89 d3                	mov    %edx,%ebx
  8007f2:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007f7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8007fb:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800802:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800806:	89 44 24 08          	mov    %eax,0x8(%esp)
  80080a:	89 0c 24             	mov    %ecx,(%esp)
  80080d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800811:	89 f2                	mov    %esi,%edx
  800813:	89 f8                	mov    %edi,%eax
  800815:	e8 b6 fa ff ff       	call   8002d0 <printnum>
  80081a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80081d:	e9 27 fc ff ff       	jmp    800449 <vprintfmt+0x2c>
  800822:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800825:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800828:	89 74 24 04          	mov    %esi,0x4(%esp)
  80082c:	89 14 24             	mov    %edx,(%esp)
  80082f:	ff d7                	call   *%edi
  800831:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800834:	e9 10 fc ff ff       	jmp    800449 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800839:	89 74 24 04          	mov    %esi,0x4(%esp)
  80083d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800844:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800846:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800849:	80 38 25             	cmpb   $0x25,(%eax)
  80084c:	0f 84 f7 fb ff ff    	je     800449 <vprintfmt+0x2c>
  800852:	89 c3                	mov    %eax,%ebx
  800854:	eb f0                	jmp    800846 <vprintfmt+0x429>
				/* do nothing */;
			break;
		}
	}
}
  800856:	83 c4 5c             	add    $0x5c,%esp
  800859:	5b                   	pop    %ebx
  80085a:	5e                   	pop    %esi
  80085b:	5f                   	pop    %edi
  80085c:	5d                   	pop    %ebp
  80085d:	c3                   	ret    

0080085e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80085e:	55                   	push   %ebp
  80085f:	89 e5                	mov    %esp,%ebp
  800861:	83 ec 28             	sub    $0x28,%esp
  800864:	8b 45 08             	mov    0x8(%ebp),%eax
  800867:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80086a:	85 c0                	test   %eax,%eax
  80086c:	74 04                	je     800872 <vsnprintf+0x14>
  80086e:	85 d2                	test   %edx,%edx
  800870:	7f 07                	jg     800879 <vsnprintf+0x1b>
  800872:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800877:	eb 3b                	jmp    8008b4 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800879:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80087c:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800880:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800883:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80088a:	8b 45 14             	mov    0x14(%ebp),%eax
  80088d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800891:	8b 45 10             	mov    0x10(%ebp),%eax
  800894:	89 44 24 08          	mov    %eax,0x8(%esp)
  800898:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80089b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80089f:	c7 04 24 00 04 80 00 	movl   $0x800400,(%esp)
  8008a6:	e8 72 fb ff ff       	call   80041d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008ae:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8008b4:	c9                   	leave  
  8008b5:	c3                   	ret    

008008b6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008b6:	55                   	push   %ebp
  8008b7:	89 e5                	mov    %esp,%ebp
  8008b9:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8008bc:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8008bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8008c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d4:	89 04 24             	mov    %eax,(%esp)
  8008d7:	e8 82 ff ff ff       	call   80085e <vsnprintf>
	va_end(ap);

	return rc;
}
  8008dc:	c9                   	leave  
  8008dd:	c3                   	ret    

008008de <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8008e4:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8008e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fc:	89 04 24             	mov    %eax,(%esp)
  8008ff:	e8 19 fb ff ff       	call   80041d <vprintfmt>
	va_end(ap);
}
  800904:	c9                   	leave  
  800905:	c3                   	ret    
  800906:	66 90                	xchg   %ax,%ax
  800908:	66 90                	xchg   %ax,%ax
  80090a:	66 90                	xchg   %ax,%ax
  80090c:	66 90                	xchg   %ax,%ax
  80090e:	66 90                	xchg   %ax,%ax

00800910 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800910:	55                   	push   %ebp
  800911:	89 e5                	mov    %esp,%ebp
  800913:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800916:	b8 00 00 00 00       	mov    $0x0,%eax
  80091b:	80 3a 00             	cmpb   $0x0,(%edx)
  80091e:	74 09                	je     800929 <strlen+0x19>
		n++;
  800920:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800923:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800927:	75 f7                	jne    800920 <strlen+0x10>
		n++;
	return n;
}
  800929:	5d                   	pop    %ebp
  80092a:	c3                   	ret    

0080092b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80092b:	55                   	push   %ebp
  80092c:	89 e5                	mov    %esp,%ebp
  80092e:	53                   	push   %ebx
  80092f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800932:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800935:	85 c9                	test   %ecx,%ecx
  800937:	74 19                	je     800952 <strnlen+0x27>
  800939:	80 3b 00             	cmpb   $0x0,(%ebx)
  80093c:	74 14                	je     800952 <strnlen+0x27>
  80093e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800943:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800946:	39 c8                	cmp    %ecx,%eax
  800948:	74 0d                	je     800957 <strnlen+0x2c>
  80094a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80094e:	75 f3                	jne    800943 <strnlen+0x18>
  800950:	eb 05                	jmp    800957 <strnlen+0x2c>
  800952:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800957:	5b                   	pop    %ebx
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	53                   	push   %ebx
  80095e:	8b 45 08             	mov    0x8(%ebp),%eax
  800961:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800964:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800969:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80096d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800970:	83 c2 01             	add    $0x1,%edx
  800973:	84 c9                	test   %cl,%cl
  800975:	75 f2                	jne    800969 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800977:	5b                   	pop    %ebx
  800978:	5d                   	pop    %ebp
  800979:	c3                   	ret    

0080097a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	53                   	push   %ebx
  80097e:	83 ec 08             	sub    $0x8,%esp
  800981:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800984:	89 1c 24             	mov    %ebx,(%esp)
  800987:	e8 84 ff ff ff       	call   800910 <strlen>
	strcpy(dst + len, src);
  80098c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80098f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800993:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800996:	89 04 24             	mov    %eax,(%esp)
  800999:	e8 bc ff ff ff       	call   80095a <strcpy>
	return dst;
}
  80099e:	89 d8                	mov    %ebx,%eax
  8009a0:	83 c4 08             	add    $0x8,%esp
  8009a3:	5b                   	pop    %ebx
  8009a4:	5d                   	pop    %ebp
  8009a5:	c3                   	ret    

008009a6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009a6:	55                   	push   %ebp
  8009a7:	89 e5                	mov    %esp,%ebp
  8009a9:	56                   	push   %esi
  8009aa:	53                   	push   %ebx
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009b1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009b4:	85 f6                	test   %esi,%esi
  8009b6:	74 18                	je     8009d0 <strncpy+0x2a>
  8009b8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  8009bd:	0f b6 1a             	movzbl (%edx),%ebx
  8009c0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009c3:	80 3a 01             	cmpb   $0x1,(%edx)
  8009c6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009c9:	83 c1 01             	add    $0x1,%ecx
  8009cc:	39 ce                	cmp    %ecx,%esi
  8009ce:	77 ed                	ja     8009bd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009d0:	5b                   	pop    %ebx
  8009d1:	5e                   	pop    %esi
  8009d2:	5d                   	pop    %ebp
  8009d3:	c3                   	ret    

008009d4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	56                   	push   %esi
  8009d8:	53                   	push   %ebx
  8009d9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009dc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009df:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009e2:	89 f0                	mov    %esi,%eax
  8009e4:	85 c9                	test   %ecx,%ecx
  8009e6:	74 27                	je     800a0f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8009e8:	83 e9 01             	sub    $0x1,%ecx
  8009eb:	74 1d                	je     800a0a <strlcpy+0x36>
  8009ed:	0f b6 1a             	movzbl (%edx),%ebx
  8009f0:	84 db                	test   %bl,%bl
  8009f2:	74 16                	je     800a0a <strlcpy+0x36>
			*dst++ = *src++;
  8009f4:	88 18                	mov    %bl,(%eax)
  8009f6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009f9:	83 e9 01             	sub    $0x1,%ecx
  8009fc:	74 0e                	je     800a0c <strlcpy+0x38>
			*dst++ = *src++;
  8009fe:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a01:	0f b6 1a             	movzbl (%edx),%ebx
  800a04:	84 db                	test   %bl,%bl
  800a06:	75 ec                	jne    8009f4 <strlcpy+0x20>
  800a08:	eb 02                	jmp    800a0c <strlcpy+0x38>
  800a0a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a0c:	c6 00 00             	movb   $0x0,(%eax)
  800a0f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800a11:	5b                   	pop    %ebx
  800a12:	5e                   	pop    %esi
  800a13:	5d                   	pop    %ebp
  800a14:	c3                   	ret    

00800a15 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a15:	55                   	push   %ebp
  800a16:	89 e5                	mov    %esp,%ebp
  800a18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a1e:	0f b6 01             	movzbl (%ecx),%eax
  800a21:	84 c0                	test   %al,%al
  800a23:	74 15                	je     800a3a <strcmp+0x25>
  800a25:	3a 02                	cmp    (%edx),%al
  800a27:	75 11                	jne    800a3a <strcmp+0x25>
		p++, q++;
  800a29:	83 c1 01             	add    $0x1,%ecx
  800a2c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a2f:	0f b6 01             	movzbl (%ecx),%eax
  800a32:	84 c0                	test   %al,%al
  800a34:	74 04                	je     800a3a <strcmp+0x25>
  800a36:	3a 02                	cmp    (%edx),%al
  800a38:	74 ef                	je     800a29 <strcmp+0x14>
  800a3a:	0f b6 c0             	movzbl %al,%eax
  800a3d:	0f b6 12             	movzbl (%edx),%edx
  800a40:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a42:	5d                   	pop    %ebp
  800a43:	c3                   	ret    

00800a44 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	53                   	push   %ebx
  800a48:	8b 55 08             	mov    0x8(%ebp),%edx
  800a4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a4e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a51:	85 c0                	test   %eax,%eax
  800a53:	74 23                	je     800a78 <strncmp+0x34>
  800a55:	0f b6 1a             	movzbl (%edx),%ebx
  800a58:	84 db                	test   %bl,%bl
  800a5a:	74 25                	je     800a81 <strncmp+0x3d>
  800a5c:	3a 19                	cmp    (%ecx),%bl
  800a5e:	75 21                	jne    800a81 <strncmp+0x3d>
  800a60:	83 e8 01             	sub    $0x1,%eax
  800a63:	74 13                	je     800a78 <strncmp+0x34>
		n--, p++, q++;
  800a65:	83 c2 01             	add    $0x1,%edx
  800a68:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a6b:	0f b6 1a             	movzbl (%edx),%ebx
  800a6e:	84 db                	test   %bl,%bl
  800a70:	74 0f                	je     800a81 <strncmp+0x3d>
  800a72:	3a 19                	cmp    (%ecx),%bl
  800a74:	74 ea                	je     800a60 <strncmp+0x1c>
  800a76:	eb 09                	jmp    800a81 <strncmp+0x3d>
  800a78:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a7d:	5b                   	pop    %ebx
  800a7e:	5d                   	pop    %ebp
  800a7f:	90                   	nop
  800a80:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a81:	0f b6 02             	movzbl (%edx),%eax
  800a84:	0f b6 11             	movzbl (%ecx),%edx
  800a87:	29 d0                	sub    %edx,%eax
  800a89:	eb f2                	jmp    800a7d <strncmp+0x39>

00800a8b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a8b:	55                   	push   %ebp
  800a8c:	89 e5                	mov    %esp,%ebp
  800a8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a95:	0f b6 10             	movzbl (%eax),%edx
  800a98:	84 d2                	test   %dl,%dl
  800a9a:	74 18                	je     800ab4 <strchr+0x29>
		if (*s == c)
  800a9c:	38 ca                	cmp    %cl,%dl
  800a9e:	75 0a                	jne    800aaa <strchr+0x1f>
  800aa0:	eb 17                	jmp    800ab9 <strchr+0x2e>
  800aa2:	38 ca                	cmp    %cl,%dl
  800aa4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800aa8:	74 0f                	je     800ab9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800aaa:	83 c0 01             	add    $0x1,%eax
  800aad:	0f b6 10             	movzbl (%eax),%edx
  800ab0:	84 d2                	test   %dl,%dl
  800ab2:	75 ee                	jne    800aa2 <strchr+0x17>
  800ab4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac5:	0f b6 10             	movzbl (%eax),%edx
  800ac8:	84 d2                	test   %dl,%dl
  800aca:	74 18                	je     800ae4 <strfind+0x29>
		if (*s == c)
  800acc:	38 ca                	cmp    %cl,%dl
  800ace:	75 0a                	jne    800ada <strfind+0x1f>
  800ad0:	eb 12                	jmp    800ae4 <strfind+0x29>
  800ad2:	38 ca                	cmp    %cl,%dl
  800ad4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ad8:	74 0a                	je     800ae4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800ada:	83 c0 01             	add    $0x1,%eax
  800add:	0f b6 10             	movzbl (%eax),%edx
  800ae0:	84 d2                	test   %dl,%dl
  800ae2:	75 ee                	jne    800ad2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800ae4:	5d                   	pop    %ebp
  800ae5:	c3                   	ret    

00800ae6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ae6:	55                   	push   %ebp
  800ae7:	89 e5                	mov    %esp,%ebp
  800ae9:	83 ec 0c             	sub    $0xc,%esp
  800aec:	89 1c 24             	mov    %ebx,(%esp)
  800aef:	89 74 24 04          	mov    %esi,0x4(%esp)
  800af3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800af7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800afa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b00:	85 c9                	test   %ecx,%ecx
  800b02:	74 30                	je     800b34 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b0a:	75 25                	jne    800b31 <memset+0x4b>
  800b0c:	f6 c1 03             	test   $0x3,%cl
  800b0f:	75 20                	jne    800b31 <memset+0x4b>
		c &= 0xFF;
  800b11:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b14:	89 d3                	mov    %edx,%ebx
  800b16:	c1 e3 08             	shl    $0x8,%ebx
  800b19:	89 d6                	mov    %edx,%esi
  800b1b:	c1 e6 18             	shl    $0x18,%esi
  800b1e:	89 d0                	mov    %edx,%eax
  800b20:	c1 e0 10             	shl    $0x10,%eax
  800b23:	09 f0                	or     %esi,%eax
  800b25:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800b27:	09 d8                	or     %ebx,%eax
  800b29:	c1 e9 02             	shr    $0x2,%ecx
  800b2c:	fc                   	cld    
  800b2d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b2f:	eb 03                	jmp    800b34 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b31:	fc                   	cld    
  800b32:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b34:	89 f8                	mov    %edi,%eax
  800b36:	8b 1c 24             	mov    (%esp),%ebx
  800b39:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b3d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b41:	89 ec                	mov    %ebp,%esp
  800b43:	5d                   	pop    %ebp
  800b44:	c3                   	ret    

00800b45 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b45:	55                   	push   %ebp
  800b46:	89 e5                	mov    %esp,%ebp
  800b48:	83 ec 08             	sub    $0x8,%esp
  800b4b:	89 34 24             	mov    %esi,(%esp)
  800b4e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b52:	8b 45 08             	mov    0x8(%ebp),%eax
  800b55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800b58:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b5b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b5d:	39 c6                	cmp    %eax,%esi
  800b5f:	73 35                	jae    800b96 <memmove+0x51>
  800b61:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b64:	39 d0                	cmp    %edx,%eax
  800b66:	73 2e                	jae    800b96 <memmove+0x51>
		s += n;
		d += n;
  800b68:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b6a:	f6 c2 03             	test   $0x3,%dl
  800b6d:	75 1b                	jne    800b8a <memmove+0x45>
  800b6f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b75:	75 13                	jne    800b8a <memmove+0x45>
  800b77:	f6 c1 03             	test   $0x3,%cl
  800b7a:	75 0e                	jne    800b8a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800b7c:	83 ef 04             	sub    $0x4,%edi
  800b7f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b82:	c1 e9 02             	shr    $0x2,%ecx
  800b85:	fd                   	std    
  800b86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b88:	eb 09                	jmp    800b93 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b8a:	83 ef 01             	sub    $0x1,%edi
  800b8d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b90:	fd                   	std    
  800b91:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b93:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b94:	eb 20                	jmp    800bb6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b96:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b9c:	75 15                	jne    800bb3 <memmove+0x6e>
  800b9e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ba4:	75 0d                	jne    800bb3 <memmove+0x6e>
  800ba6:	f6 c1 03             	test   $0x3,%cl
  800ba9:	75 08                	jne    800bb3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800bab:	c1 e9 02             	shr    $0x2,%ecx
  800bae:	fc                   	cld    
  800baf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800bb1:	eb 03                	jmp    800bb6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800bb3:	fc                   	cld    
  800bb4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bb6:	8b 34 24             	mov    (%esp),%esi
  800bb9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800bbd:	89 ec                	mov    %ebp,%esp
  800bbf:	5d                   	pop    %ebp
  800bc0:	c3                   	ret    

00800bc1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bc1:	55                   	push   %ebp
  800bc2:	89 e5                	mov    %esp,%ebp
  800bc4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bc7:	8b 45 10             	mov    0x10(%ebp),%eax
  800bca:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd8:	89 04 24             	mov    %eax,(%esp)
  800bdb:	e8 65 ff ff ff       	call   800b45 <memmove>
}
  800be0:	c9                   	leave  
  800be1:	c3                   	ret    

00800be2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800be2:	55                   	push   %ebp
  800be3:	89 e5                	mov    %esp,%ebp
  800be5:	57                   	push   %edi
  800be6:	56                   	push   %esi
  800be7:	53                   	push   %ebx
  800be8:	8b 75 08             	mov    0x8(%ebp),%esi
  800beb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800bee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf1:	85 c9                	test   %ecx,%ecx
  800bf3:	74 36                	je     800c2b <memcmp+0x49>
		if (*s1 != *s2)
  800bf5:	0f b6 06             	movzbl (%esi),%eax
  800bf8:	0f b6 1f             	movzbl (%edi),%ebx
  800bfb:	38 d8                	cmp    %bl,%al
  800bfd:	74 20                	je     800c1f <memcmp+0x3d>
  800bff:	eb 14                	jmp    800c15 <memcmp+0x33>
  800c01:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800c06:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800c0b:	83 c2 01             	add    $0x1,%edx
  800c0e:	83 e9 01             	sub    $0x1,%ecx
  800c11:	38 d8                	cmp    %bl,%al
  800c13:	74 12                	je     800c27 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800c15:	0f b6 c0             	movzbl %al,%eax
  800c18:	0f b6 db             	movzbl %bl,%ebx
  800c1b:	29 d8                	sub    %ebx,%eax
  800c1d:	eb 11                	jmp    800c30 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c1f:	83 e9 01             	sub    $0x1,%ecx
  800c22:	ba 00 00 00 00       	mov    $0x0,%edx
  800c27:	85 c9                	test   %ecx,%ecx
  800c29:	75 d6                	jne    800c01 <memcmp+0x1f>
  800c2b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c35:	55                   	push   %ebp
  800c36:	89 e5                	mov    %esp,%ebp
  800c38:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c3b:	89 c2                	mov    %eax,%edx
  800c3d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c40:	39 d0                	cmp    %edx,%eax
  800c42:	73 15                	jae    800c59 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c44:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c48:	38 08                	cmp    %cl,(%eax)
  800c4a:	75 06                	jne    800c52 <memfind+0x1d>
  800c4c:	eb 0b                	jmp    800c59 <memfind+0x24>
  800c4e:	38 08                	cmp    %cl,(%eax)
  800c50:	74 07                	je     800c59 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c52:	83 c0 01             	add    $0x1,%eax
  800c55:	39 c2                	cmp    %eax,%edx
  800c57:	77 f5                	ja     800c4e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c59:	5d                   	pop    %ebp
  800c5a:	c3                   	ret    

00800c5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c5b:	55                   	push   %ebp
  800c5c:	89 e5                	mov    %esp,%ebp
  800c5e:	57                   	push   %edi
  800c5f:	56                   	push   %esi
  800c60:	53                   	push   %ebx
  800c61:	83 ec 04             	sub    $0x4,%esp
  800c64:	8b 55 08             	mov    0x8(%ebp),%edx
  800c67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c6a:	0f b6 02             	movzbl (%edx),%eax
  800c6d:	3c 20                	cmp    $0x20,%al
  800c6f:	74 04                	je     800c75 <strtol+0x1a>
  800c71:	3c 09                	cmp    $0x9,%al
  800c73:	75 0e                	jne    800c83 <strtol+0x28>
		s++;
  800c75:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c78:	0f b6 02             	movzbl (%edx),%eax
  800c7b:	3c 20                	cmp    $0x20,%al
  800c7d:	74 f6                	je     800c75 <strtol+0x1a>
  800c7f:	3c 09                	cmp    $0x9,%al
  800c81:	74 f2                	je     800c75 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c83:	3c 2b                	cmp    $0x2b,%al
  800c85:	75 0c                	jne    800c93 <strtol+0x38>
		s++;
  800c87:	83 c2 01             	add    $0x1,%edx
  800c8a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c91:	eb 15                	jmp    800ca8 <strtol+0x4d>
	else if (*s == '-')
  800c93:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c9a:	3c 2d                	cmp    $0x2d,%al
  800c9c:	75 0a                	jne    800ca8 <strtol+0x4d>
		s++, neg = 1;
  800c9e:	83 c2 01             	add    $0x1,%edx
  800ca1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ca8:	85 db                	test   %ebx,%ebx
  800caa:	0f 94 c0             	sete   %al
  800cad:	74 05                	je     800cb4 <strtol+0x59>
  800caf:	83 fb 10             	cmp    $0x10,%ebx
  800cb2:	75 18                	jne    800ccc <strtol+0x71>
  800cb4:	80 3a 30             	cmpb   $0x30,(%edx)
  800cb7:	75 13                	jne    800ccc <strtol+0x71>
  800cb9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800cbd:	8d 76 00             	lea    0x0(%esi),%esi
  800cc0:	75 0a                	jne    800ccc <strtol+0x71>
		s += 2, base = 16;
  800cc2:	83 c2 02             	add    $0x2,%edx
  800cc5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cca:	eb 15                	jmp    800ce1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ccc:	84 c0                	test   %al,%al
  800cce:	66 90                	xchg   %ax,%ax
  800cd0:	74 0f                	je     800ce1 <strtol+0x86>
  800cd2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800cd7:	80 3a 30             	cmpb   $0x30,(%edx)
  800cda:	75 05                	jne    800ce1 <strtol+0x86>
		s++, base = 8;
  800cdc:	83 c2 01             	add    $0x1,%edx
  800cdf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800ce1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ce6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800ce8:	0f b6 0a             	movzbl (%edx),%ecx
  800ceb:	89 cf                	mov    %ecx,%edi
  800ced:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cf0:	80 fb 09             	cmp    $0x9,%bl
  800cf3:	77 08                	ja     800cfd <strtol+0xa2>
			dig = *s - '0';
  800cf5:	0f be c9             	movsbl %cl,%ecx
  800cf8:	83 e9 30             	sub    $0x30,%ecx
  800cfb:	eb 1e                	jmp    800d1b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800cfd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800d00:	80 fb 19             	cmp    $0x19,%bl
  800d03:	77 08                	ja     800d0d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800d05:	0f be c9             	movsbl %cl,%ecx
  800d08:	83 e9 57             	sub    $0x57,%ecx
  800d0b:	eb 0e                	jmp    800d1b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800d0d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800d10:	80 fb 19             	cmp    $0x19,%bl
  800d13:	77 15                	ja     800d2a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800d15:	0f be c9             	movsbl %cl,%ecx
  800d18:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800d1b:	39 f1                	cmp    %esi,%ecx
  800d1d:	7d 0b                	jge    800d2a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800d1f:	83 c2 01             	add    $0x1,%edx
  800d22:	0f af c6             	imul   %esi,%eax
  800d25:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800d28:	eb be                	jmp    800ce8 <strtol+0x8d>
  800d2a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800d2c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d30:	74 05                	je     800d37 <strtol+0xdc>
		*endptr = (char *) s;
  800d32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d35:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d37:	89 ca                	mov    %ecx,%edx
  800d39:	f7 da                	neg    %edx
  800d3b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d3f:	0f 45 c2             	cmovne %edx,%eax
}
  800d42:	83 c4 04             	add    $0x4,%esp
  800d45:	5b                   	pop    %ebx
  800d46:	5e                   	pop    %esi
  800d47:	5f                   	pop    %edi
  800d48:	5d                   	pop    %ebp
  800d49:	c3                   	ret    

00800d4a <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	83 ec 0c             	sub    $0xc,%esp
  800d50:	89 1c 24             	mov    %ebx,(%esp)
  800d53:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d57:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d60:	b8 01 00 00 00       	mov    $0x1,%eax
  800d65:	89 d1                	mov    %edx,%ecx
  800d67:	89 d3                	mov    %edx,%ebx
  800d69:	89 d7                	mov    %edx,%edi
  800d6b:	89 d6                	mov    %edx,%esi
  800d6d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d6f:	8b 1c 24             	mov    (%esp),%ebx
  800d72:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d76:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d7a:	89 ec                	mov    %ebp,%esp
  800d7c:	5d                   	pop    %ebp
  800d7d:	c3                   	ret    

00800d7e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	83 ec 0c             	sub    $0xc,%esp
  800d84:	89 1c 24             	mov    %ebx,(%esp)
  800d87:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d8b:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d97:	8b 55 08             	mov    0x8(%ebp),%edx
  800d9a:	89 c3                	mov    %eax,%ebx
  800d9c:	89 c7                	mov    %eax,%edi
  800d9e:	89 c6                	mov    %eax,%esi
  800da0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800da2:	8b 1c 24             	mov    (%esp),%ebx
  800da5:	8b 74 24 04          	mov    0x4(%esp),%esi
  800da9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dad:	89 ec                	mov    %ebp,%esp
  800daf:	5d                   	pop    %ebp
  800db0:	c3                   	ret    

00800db1 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800db1:	55                   	push   %ebp
  800db2:	89 e5                	mov    %esp,%ebp
  800db4:	83 ec 38             	sub    $0x38,%esp
  800db7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800dba:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800dbd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dc0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800dc5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dca:	8b 55 08             	mov    0x8(%ebp),%edx
  800dcd:	89 cb                	mov    %ecx,%ebx
  800dcf:	89 cf                	mov    %ecx,%edi
  800dd1:	89 ce                	mov    %ecx,%esi
  800dd3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dd5:	85 c0                	test   %eax,%eax
  800dd7:	7e 28                	jle    800e01 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ddd:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800de4:	00 
  800de5:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  800dec:	00 
  800ded:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800df4:	00 
  800df5:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  800dfc:	e8 b8 f3 ff ff       	call   8001b9 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800e01:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e04:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e07:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e0a:	89 ec                	mov    %ebp,%esp
  800e0c:	5d                   	pop    %ebp
  800e0d:	c3                   	ret    

00800e0e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	83 ec 0c             	sub    $0xc,%esp
  800e14:	89 1c 24             	mov    %ebx,(%esp)
  800e17:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e1b:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e1f:	be 00 00 00 00       	mov    $0x0,%esi
  800e24:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e29:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e32:	8b 55 08             	mov    0x8(%ebp),%edx
  800e35:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e37:	8b 1c 24             	mov    (%esp),%ebx
  800e3a:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e3e:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e42:	89 ec                	mov    %ebp,%esp
  800e44:	5d                   	pop    %ebp
  800e45:	c3                   	ret    

00800e46 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e46:	55                   	push   %ebp
  800e47:	89 e5                	mov    %esp,%ebp
  800e49:	83 ec 38             	sub    $0x38,%esp
  800e4c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e4f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e52:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e5a:	b8 09 00 00 00       	mov    $0x9,%eax
  800e5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e62:	8b 55 08             	mov    0x8(%ebp),%edx
  800e65:	89 df                	mov    %ebx,%edi
  800e67:	89 de                	mov    %ebx,%esi
  800e69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e6b:	85 c0                	test   %eax,%eax
  800e6d:	7e 28                	jle    800e97 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e6f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e73:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e7a:	00 
  800e7b:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  800e82:	00 
  800e83:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e8a:	00 
  800e8b:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  800e92:	e8 22 f3 ff ff       	call   8001b9 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e97:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e9a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e9d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ea0:	89 ec                	mov    %ebp,%esp
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	83 ec 38             	sub    $0x38,%esp
  800eaa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ead:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eb0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800eb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800eb8:	b8 08 00 00 00       	mov    $0x8,%eax
  800ebd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ec0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec3:	89 df                	mov    %ebx,%edi
  800ec5:	89 de                	mov    %ebx,%esi
  800ec7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ec9:	85 c0                	test   %eax,%eax
  800ecb:	7e 28                	jle    800ef5 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ecd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800ed1:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800ed8:	00 
  800ed9:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  800ee0:	00 
  800ee1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ee8:	00 
  800ee9:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  800ef0:	e8 c4 f2 ff ff       	call   8001b9 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ef5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ef8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800efb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800efe:	89 ec                	mov    %ebp,%esp
  800f00:	5d                   	pop    %ebp
  800f01:	c3                   	ret    

00800f02 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
  800f05:	83 ec 38             	sub    $0x38,%esp
  800f08:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f0b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f0e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f11:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f16:	b8 06 00 00 00       	mov    $0x6,%eax
  800f1b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f1e:	8b 55 08             	mov    0x8(%ebp),%edx
  800f21:	89 df                	mov    %ebx,%edi
  800f23:	89 de                	mov    %ebx,%esi
  800f25:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f27:	85 c0                	test   %eax,%eax
  800f29:	7e 28                	jle    800f53 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f2b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f2f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f36:	00 
  800f37:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  800f3e:	00 
  800f3f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f46:	00 
  800f47:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  800f4e:	e8 66 f2 ff ff       	call   8001b9 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f53:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f56:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f59:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f5c:	89 ec                	mov    %ebp,%esp
  800f5e:	5d                   	pop    %ebp
  800f5f:	c3                   	ret    

00800f60 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f60:	55                   	push   %ebp
  800f61:	89 e5                	mov    %esp,%ebp
  800f63:	83 ec 38             	sub    $0x38,%esp
  800f66:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f69:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f6c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f6f:	b8 05 00 00 00       	mov    $0x5,%eax
  800f74:	8b 75 18             	mov    0x18(%ebp),%esi
  800f77:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f7a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f7d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f80:	8b 55 08             	mov    0x8(%ebp),%edx
  800f83:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f85:	85 c0                	test   %eax,%eax
  800f87:	7e 28                	jle    800fb1 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f89:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f8d:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f94:	00 
  800f95:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  800f9c:	00 
  800f9d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fa4:	00 
  800fa5:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  800fac:	e8 08 f2 ff ff       	call   8001b9 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800fb1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800fb4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800fb7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fba:	89 ec                	mov    %ebp,%esp
  800fbc:	5d                   	pop    %ebp
  800fbd:	c3                   	ret    

00800fbe <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	83 ec 38             	sub    $0x38,%esp
  800fc4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fc7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fca:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fcd:	be 00 00 00 00       	mov    $0x0,%esi
  800fd2:	b8 04 00 00 00       	mov    $0x4,%eax
  800fd7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fdd:	8b 55 08             	mov    0x8(%ebp),%edx
  800fe0:	89 f7                	mov    %esi,%edi
  800fe2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	7e 28                	jle    801010 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fe8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fec:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800ff3:	00 
  800ff4:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  800ffb:	00 
  800ffc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801003:	00 
  801004:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  80100b:	e8 a9 f1 ff ff       	call   8001b9 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801010:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801013:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801016:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801019:	89 ec                	mov    %ebp,%esp
  80101b:	5d                   	pop    %ebp
  80101c:	c3                   	ret    

0080101d <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  80101d:	55                   	push   %ebp
  80101e:	89 e5                	mov    %esp,%ebp
  801020:	83 ec 0c             	sub    $0xc,%esp
  801023:	89 1c 24             	mov    %ebx,(%esp)
  801026:	89 74 24 04          	mov    %esi,0x4(%esp)
  80102a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80102e:	ba 00 00 00 00       	mov    $0x0,%edx
  801033:	b8 0a 00 00 00       	mov    $0xa,%eax
  801038:	89 d1                	mov    %edx,%ecx
  80103a:	89 d3                	mov    %edx,%ebx
  80103c:	89 d7                	mov    %edx,%edi
  80103e:	89 d6                	mov    %edx,%esi
  801040:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801042:	8b 1c 24             	mov    (%esp),%ebx
  801045:	8b 74 24 04          	mov    0x4(%esp),%esi
  801049:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80104d:	89 ec                	mov    %ebp,%esp
  80104f:	5d                   	pop    %ebp
  801050:	c3                   	ret    

00801051 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801051:	55                   	push   %ebp
  801052:	89 e5                	mov    %esp,%ebp
  801054:	83 ec 0c             	sub    $0xc,%esp
  801057:	89 1c 24             	mov    %ebx,(%esp)
  80105a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80105e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801062:	ba 00 00 00 00       	mov    $0x0,%edx
  801067:	b8 02 00 00 00       	mov    $0x2,%eax
  80106c:	89 d1                	mov    %edx,%ecx
  80106e:	89 d3                	mov    %edx,%ebx
  801070:	89 d7                	mov    %edx,%edi
  801072:	89 d6                	mov    %edx,%esi
  801074:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801076:	8b 1c 24             	mov    (%esp),%ebx
  801079:	8b 74 24 04          	mov    0x4(%esp),%esi
  80107d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801081:	89 ec                	mov    %ebp,%esp
  801083:	5d                   	pop    %ebp
  801084:	c3                   	ret    

00801085 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801085:	55                   	push   %ebp
  801086:	89 e5                	mov    %esp,%ebp
  801088:	83 ec 38             	sub    $0x38,%esp
  80108b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80108e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801091:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801094:	b9 00 00 00 00       	mov    $0x0,%ecx
  801099:	b8 03 00 00 00       	mov    $0x3,%eax
  80109e:	8b 55 08             	mov    0x8(%ebp),%edx
  8010a1:	89 cb                	mov    %ecx,%ebx
  8010a3:	89 cf                	mov    %ecx,%edi
  8010a5:	89 ce                	mov    %ecx,%esi
  8010a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010a9:	85 c0                	test   %eax,%eax
  8010ab:	7e 28                	jle    8010d5 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010b1:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8010b8:	00 
  8010b9:	c7 44 24 08 c4 16 80 	movl   $0x8016c4,0x8(%esp)
  8010c0:	00 
  8010c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010c8:	00 
  8010c9:	c7 04 24 e1 16 80 00 	movl   $0x8016e1,(%esp)
  8010d0:	e8 e4 f0 ff ff       	call   8001b9 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010d5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010d8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010db:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010de:	89 ec                	mov    %ebp,%esp
  8010e0:	5d                   	pop    %ebp
  8010e1:	c3                   	ret    

008010e2 <sfork>:
}

// Challenge!
int
sfork(void)
{
  8010e2:	55                   	push   %ebp
  8010e3:	89 e5                	mov    %esp,%ebp
  8010e5:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8010e8:	c7 44 24 08 ef 16 80 	movl   $0x8016ef,0x8(%esp)
  8010ef:	00 
  8010f0:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  8010f7:	00 
  8010f8:	c7 04 24 05 17 80 00 	movl   $0x801705,(%esp)
  8010ff:	e8 b5 f0 ff ff       	call   8001b9 <_panic>

00801104 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801104:	55                   	push   %ebp
  801105:	89 e5                	mov    %esp,%ebp
  801107:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  80110a:	c7 44 24 08 f0 16 80 	movl   $0x8016f0,0x8(%esp)
  801111:	00 
  801112:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801119:	00 
  80111a:	c7 04 24 05 17 80 00 	movl   $0x801705,(%esp)
  801121:	e8 93 f0 ff ff       	call   8001b9 <_panic>

00801126 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801126:	55                   	push   %ebp
  801127:	89 e5                	mov    %esp,%ebp
  801129:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80112c:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801132:	b8 01 00 00 00       	mov    $0x1,%eax
  801137:	39 ca                	cmp    %ecx,%edx
  801139:	75 04                	jne    80113f <ipc_find_env+0x19>
  80113b:	b0 00                	mov    $0x0,%al
  80113d:	eb 0f                	jmp    80114e <ipc_find_env+0x28>
  80113f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801142:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  801148:	8b 12                	mov    (%edx),%edx
  80114a:	39 ca                	cmp    %ecx,%edx
  80114c:	75 0c                	jne    80115a <ipc_find_env+0x34>
			return envs[i].env_id;
  80114e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801151:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  801156:	8b 00                	mov    (%eax),%eax
  801158:	eb 0e                	jmp    801168 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  80115a:	83 c0 01             	add    $0x1,%eax
  80115d:	3d 00 04 00 00       	cmp    $0x400,%eax
  801162:	75 db                	jne    80113f <ipc_find_env+0x19>
  801164:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  801168:	5d                   	pop    %ebp
  801169:	c3                   	ret    

0080116a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80116a:	55                   	push   %ebp
  80116b:	89 e5                	mov    %esp,%ebp
  80116d:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  801170:	c7 44 24 08 10 17 80 	movl   $0x801710,0x8(%esp)
  801177:	00 
  801178:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  80117f:	00 
  801180:	c7 04 24 29 17 80 00 	movl   $0x801729,(%esp)
  801187:	e8 2d f0 ff ff       	call   8001b9 <_panic>

0080118c <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80118c:	55                   	push   %ebp
  80118d:	89 e5                	mov    %esp,%ebp
  80118f:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  801192:	c7 44 24 08 33 17 80 	movl   $0x801733,0x8(%esp)
  801199:	00 
  80119a:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  8011a1:	00 
  8011a2:	c7 04 24 29 17 80 00 	movl   $0x801729,(%esp)
  8011a9:	e8 0b f0 ff ff       	call   8001b9 <_panic>
  8011ae:	66 90                	xchg   %ax,%ax

008011b0 <__udivdi3>:
  8011b0:	55                   	push   %ebp
  8011b1:	89 e5                	mov    %esp,%ebp
  8011b3:	57                   	push   %edi
  8011b4:	56                   	push   %esi
  8011b5:	83 ec 10             	sub    $0x10,%esp
  8011b8:	8b 45 14             	mov    0x14(%ebp),%eax
  8011bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8011be:	8b 75 10             	mov    0x10(%ebp),%esi
  8011c1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  8011c4:	85 c0                	test   %eax,%eax
  8011c6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  8011c9:	75 35                	jne    801200 <__udivdi3+0x50>
  8011cb:	39 fe                	cmp    %edi,%esi
  8011cd:	77 61                	ja     801230 <__udivdi3+0x80>
  8011cf:	85 f6                	test   %esi,%esi
  8011d1:	75 0b                	jne    8011de <__udivdi3+0x2e>
  8011d3:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d8:	31 d2                	xor    %edx,%edx
  8011da:	f7 f6                	div    %esi
  8011dc:	89 c6                	mov    %eax,%esi
  8011de:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8011e1:	31 d2                	xor    %edx,%edx
  8011e3:	89 f8                	mov    %edi,%eax
  8011e5:	f7 f6                	div    %esi
  8011e7:	89 c7                	mov    %eax,%edi
  8011e9:	89 c8                	mov    %ecx,%eax
  8011eb:	f7 f6                	div    %esi
  8011ed:	89 c1                	mov    %eax,%ecx
  8011ef:	89 fa                	mov    %edi,%edx
  8011f1:	89 c8                	mov    %ecx,%eax
  8011f3:	83 c4 10             	add    $0x10,%esp
  8011f6:	5e                   	pop    %esi
  8011f7:	5f                   	pop    %edi
  8011f8:	5d                   	pop    %ebp
  8011f9:	c3                   	ret    
  8011fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801200:	39 f8                	cmp    %edi,%eax
  801202:	77 1c                	ja     801220 <__udivdi3+0x70>
  801204:	0f bd d0             	bsr    %eax,%edx
  801207:	83 f2 1f             	xor    $0x1f,%edx
  80120a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80120d:	75 39                	jne    801248 <__udivdi3+0x98>
  80120f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801212:	0f 86 a0 00 00 00    	jbe    8012b8 <__udivdi3+0x108>
  801218:	39 f8                	cmp    %edi,%eax
  80121a:	0f 82 98 00 00 00    	jb     8012b8 <__udivdi3+0x108>
  801220:	31 ff                	xor    %edi,%edi
  801222:	31 c9                	xor    %ecx,%ecx
  801224:	89 c8                	mov    %ecx,%eax
  801226:	89 fa                	mov    %edi,%edx
  801228:	83 c4 10             	add    $0x10,%esp
  80122b:	5e                   	pop    %esi
  80122c:	5f                   	pop    %edi
  80122d:	5d                   	pop    %ebp
  80122e:	c3                   	ret    
  80122f:	90                   	nop
  801230:	89 d1                	mov    %edx,%ecx
  801232:	89 fa                	mov    %edi,%edx
  801234:	89 c8                	mov    %ecx,%eax
  801236:	31 ff                	xor    %edi,%edi
  801238:	f7 f6                	div    %esi
  80123a:	89 c1                	mov    %eax,%ecx
  80123c:	89 fa                	mov    %edi,%edx
  80123e:	89 c8                	mov    %ecx,%eax
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	5e                   	pop    %esi
  801244:	5f                   	pop    %edi
  801245:	5d                   	pop    %ebp
  801246:	c3                   	ret    
  801247:	90                   	nop
  801248:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80124c:	89 f2                	mov    %esi,%edx
  80124e:	d3 e0                	shl    %cl,%eax
  801250:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801253:	b8 20 00 00 00       	mov    $0x20,%eax
  801258:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80125b:	89 c1                	mov    %eax,%ecx
  80125d:	d3 ea                	shr    %cl,%edx
  80125f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801263:	0b 55 ec             	or     -0x14(%ebp),%edx
  801266:	d3 e6                	shl    %cl,%esi
  801268:	89 c1                	mov    %eax,%ecx
  80126a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80126d:	89 fe                	mov    %edi,%esi
  80126f:	d3 ee                	shr    %cl,%esi
  801271:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801275:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801278:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80127b:	d3 e7                	shl    %cl,%edi
  80127d:	89 c1                	mov    %eax,%ecx
  80127f:	d3 ea                	shr    %cl,%edx
  801281:	09 d7                	or     %edx,%edi
  801283:	89 f2                	mov    %esi,%edx
  801285:	89 f8                	mov    %edi,%eax
  801287:	f7 75 ec             	divl   -0x14(%ebp)
  80128a:	89 d6                	mov    %edx,%esi
  80128c:	89 c7                	mov    %eax,%edi
  80128e:	f7 65 e8             	mull   -0x18(%ebp)
  801291:	39 d6                	cmp    %edx,%esi
  801293:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801296:	72 30                	jb     8012c8 <__udivdi3+0x118>
  801298:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80129b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80129f:	d3 e2                	shl    %cl,%edx
  8012a1:	39 c2                	cmp    %eax,%edx
  8012a3:	73 05                	jae    8012aa <__udivdi3+0xfa>
  8012a5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8012a8:	74 1e                	je     8012c8 <__udivdi3+0x118>
  8012aa:	89 f9                	mov    %edi,%ecx
  8012ac:	31 ff                	xor    %edi,%edi
  8012ae:	e9 71 ff ff ff       	jmp    801224 <__udivdi3+0x74>
  8012b3:	90                   	nop
  8012b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012b8:	31 ff                	xor    %edi,%edi
  8012ba:	b9 01 00 00 00       	mov    $0x1,%ecx
  8012bf:	e9 60 ff ff ff       	jmp    801224 <__udivdi3+0x74>
  8012c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8012cb:	31 ff                	xor    %edi,%edi
  8012cd:	89 c8                	mov    %ecx,%eax
  8012cf:	89 fa                	mov    %edi,%edx
  8012d1:	83 c4 10             	add    $0x10,%esp
  8012d4:	5e                   	pop    %esi
  8012d5:	5f                   	pop    %edi
  8012d6:	5d                   	pop    %ebp
  8012d7:	c3                   	ret    
  8012d8:	66 90                	xchg   %ax,%ax
  8012da:	66 90                	xchg   %ax,%ax
  8012dc:	66 90                	xchg   %ax,%ax
  8012de:	66 90                	xchg   %ax,%ax

008012e0 <__umoddi3>:
  8012e0:	55                   	push   %ebp
  8012e1:	89 e5                	mov    %esp,%ebp
  8012e3:	57                   	push   %edi
  8012e4:	56                   	push   %esi
  8012e5:	83 ec 20             	sub    $0x20,%esp
  8012e8:	8b 55 14             	mov    0x14(%ebp),%edx
  8012eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ee:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012f1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012f4:	85 d2                	test   %edx,%edx
  8012f6:	89 c8                	mov    %ecx,%eax
  8012f8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8012fb:	75 13                	jne    801310 <__umoddi3+0x30>
  8012fd:	39 f7                	cmp    %esi,%edi
  8012ff:	76 3f                	jbe    801340 <__umoddi3+0x60>
  801301:	89 f2                	mov    %esi,%edx
  801303:	f7 f7                	div    %edi
  801305:	89 d0                	mov    %edx,%eax
  801307:	31 d2                	xor    %edx,%edx
  801309:	83 c4 20             	add    $0x20,%esp
  80130c:	5e                   	pop    %esi
  80130d:	5f                   	pop    %edi
  80130e:	5d                   	pop    %ebp
  80130f:	c3                   	ret    
  801310:	39 f2                	cmp    %esi,%edx
  801312:	77 4c                	ja     801360 <__umoddi3+0x80>
  801314:	0f bd ca             	bsr    %edx,%ecx
  801317:	83 f1 1f             	xor    $0x1f,%ecx
  80131a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80131d:	75 51                	jne    801370 <__umoddi3+0x90>
  80131f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801322:	0f 87 e0 00 00 00    	ja     801408 <__umoddi3+0x128>
  801328:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132b:	29 f8                	sub    %edi,%eax
  80132d:	19 d6                	sbb    %edx,%esi
  80132f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801332:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801335:	89 f2                	mov    %esi,%edx
  801337:	83 c4 20             	add    $0x20,%esp
  80133a:	5e                   	pop    %esi
  80133b:	5f                   	pop    %edi
  80133c:	5d                   	pop    %ebp
  80133d:	c3                   	ret    
  80133e:	66 90                	xchg   %ax,%ax
  801340:	85 ff                	test   %edi,%edi
  801342:	75 0b                	jne    80134f <__umoddi3+0x6f>
  801344:	b8 01 00 00 00       	mov    $0x1,%eax
  801349:	31 d2                	xor    %edx,%edx
  80134b:	f7 f7                	div    %edi
  80134d:	89 c7                	mov    %eax,%edi
  80134f:	89 f0                	mov    %esi,%eax
  801351:	31 d2                	xor    %edx,%edx
  801353:	f7 f7                	div    %edi
  801355:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801358:	f7 f7                	div    %edi
  80135a:	eb a9                	jmp    801305 <__umoddi3+0x25>
  80135c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801360:	89 c8                	mov    %ecx,%eax
  801362:	89 f2                	mov    %esi,%edx
  801364:	83 c4 20             	add    $0x20,%esp
  801367:	5e                   	pop    %esi
  801368:	5f                   	pop    %edi
  801369:	5d                   	pop    %ebp
  80136a:	c3                   	ret    
  80136b:	90                   	nop
  80136c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801370:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801374:	d3 e2                	shl    %cl,%edx
  801376:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801379:	ba 20 00 00 00       	mov    $0x20,%edx
  80137e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801381:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801384:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801388:	89 fa                	mov    %edi,%edx
  80138a:	d3 ea                	shr    %cl,%edx
  80138c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801390:	0b 55 f4             	or     -0xc(%ebp),%edx
  801393:	d3 e7                	shl    %cl,%edi
  801395:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801399:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80139c:	89 f2                	mov    %esi,%edx
  80139e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8013a1:	89 c7                	mov    %eax,%edi
  8013a3:	d3 ea                	shr    %cl,%edx
  8013a5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013a9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8013ac:	89 c2                	mov    %eax,%edx
  8013ae:	d3 e6                	shl    %cl,%esi
  8013b0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8013b4:	d3 ea                	shr    %cl,%edx
  8013b6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013ba:	09 d6                	or     %edx,%esi
  8013bc:	89 f0                	mov    %esi,%eax
  8013be:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013c1:	d3 e7                	shl    %cl,%edi
  8013c3:	89 f2                	mov    %esi,%edx
  8013c5:	f7 75 f4             	divl   -0xc(%ebp)
  8013c8:	89 d6                	mov    %edx,%esi
  8013ca:	f7 65 e8             	mull   -0x18(%ebp)
  8013cd:	39 d6                	cmp    %edx,%esi
  8013cf:	72 2b                	jb     8013fc <__umoddi3+0x11c>
  8013d1:	39 c7                	cmp    %eax,%edi
  8013d3:	72 23                	jb     8013f8 <__umoddi3+0x118>
  8013d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013d9:	29 c7                	sub    %eax,%edi
  8013db:	19 d6                	sbb    %edx,%esi
  8013dd:	89 f0                	mov    %esi,%eax
  8013df:	89 f2                	mov    %esi,%edx
  8013e1:	d3 ef                	shr    %cl,%edi
  8013e3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8013e7:	d3 e0                	shl    %cl,%eax
  8013e9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013ed:	09 f8                	or     %edi,%eax
  8013ef:	d3 ea                	shr    %cl,%edx
  8013f1:	83 c4 20             	add    $0x20,%esp
  8013f4:	5e                   	pop    %esi
  8013f5:	5f                   	pop    %edi
  8013f6:	5d                   	pop    %ebp
  8013f7:	c3                   	ret    
  8013f8:	39 d6                	cmp    %edx,%esi
  8013fa:	75 d9                	jne    8013d5 <__umoddi3+0xf5>
  8013fc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8013ff:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801402:	eb d1                	jmp    8013d5 <__umoddi3+0xf5>
  801404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801408:	39 f2                	cmp    %esi,%edx
  80140a:	0f 82 18 ff ff ff    	jb     801328 <__umoddi3+0x48>
  801410:	e9 1d ff ff ff       	jmp    801332 <__umoddi3+0x52>
