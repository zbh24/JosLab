
obj/user/stresssched：     文件格式 elf32-i386


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
  80002c:	e8 f6 00 00 00       	call   800127 <libmain>
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

volatile int counter;

void
umain(int argc, char **argv)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	56                   	push   %esi
  800044:	53                   	push   %ebx
  800045:	83 ec 10             	sub    $0x10,%esp
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  800048:	e8 e4 0f 00 00       	call   801031 <sys_getenvid>
  80004d:	89 c6                	mov    %eax,%esi
  80004f:	bb 00 00 00 00       	mov    $0x0,%ebx

	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
  800054:	e8 8b 10 00 00       	call   8010e4 <fork>
  800059:	85 c0                	test   %eax,%eax
  80005b:	74 0a                	je     800067 <umain+0x27>
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();

	// Fork several environments
	for (i = 0; i < 20; i++)
  80005d:	83 c3 01             	add    $0x1,%ebx
  800060:	83 fb 14             	cmp    $0x14,%ebx
  800063:	75 ef                	jne    800054 <umain+0x14>
  800065:	eb 1b                	jmp    800082 <umain+0x42>
		if (fork() == 0)
			break;
	if (i == 20) {
  800067:	83 fb 14             	cmp    $0x14,%ebx
  80006a:	74 16                	je     800082 <umain+0x42>
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80006c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  800072:	6b c6 7c             	imul   $0x7c,%esi,%eax
  800075:	05 54 00 c0 ee       	add    $0xeec00054,%eax
  80007a:	8b 00                	mov    (%eax),%eax
  80007c:	85 c0                	test   %eax,%eax
  80007e:	75 0d                	jne    80008d <umain+0x4d>
  800080:	eb 1c                	jmp    80009e <umain+0x5e>
	// Fork several environments
	for (i = 0; i < 20; i++)
		if (fork() == 0)
			break;
	if (i == 20) {
		sys_yield();
  800082:	e8 76 0f 00 00       	call   800ffd <sys_yield>
		return;
  800087:	90                   	nop
  800088:	e9 93 00 00 00       	jmp    800120 <umain+0xe0>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  80008d:	6b d6 7c             	imul   $0x7c,%esi,%edx
  800090:	81 c2 54 00 c0 ee    	add    $0xeec00054,%edx
		asm volatile("pause");
  800096:	f3 90                	pause  
		sys_yield();
		return;
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800098:	8b 02                	mov    (%edx),%eax
  80009a:	85 c0                	test   %eax,%eax
  80009c:	75 f8                	jne    800096 <umain+0x56>
  80009e:	bb 00 00 00 00       	mov    $0x0,%ebx
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  8000a3:	be 00 00 00 00       	mov    $0x0,%esi
  8000a8:	e8 50 0f 00 00       	call   800ffd <sys_yield>
  8000ad:	89 f0                	mov    %esi,%eax
		for (j = 0; j < 10000; j++)
			counter++;
  8000af:	8b 15 04 20 80 00    	mov    0x802004,%edx
  8000b5:	83 c2 01             	add    $0x1,%edx
  8000b8:	89 15 04 20 80 00    	mov    %edx,0x802004
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
		for (j = 0; j < 10000; j++)
  8000be:	83 c0 01             	add    $0x1,%eax
  8000c1:	3d 10 27 00 00       	cmp    $0x2710,%eax
  8000c6:	75 e7                	jne    8000af <umain+0x6f>
	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
		asm volatile("pause");

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
  8000c8:	83 c3 01             	add    $0x1,%ebx
  8000cb:	83 fb 0a             	cmp    $0xa,%ebx
  8000ce:	75 d8                	jne    8000a8 <umain+0x68>
		sys_yield();
		for (j = 0; j < 10000; j++)
			counter++;
	}

	if (counter != 10*10000)
  8000d0:	a1 04 20 80 00       	mov    0x802004,%eax
  8000d5:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000da:	74 25                	je     800101 <umain+0xc1>
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000dc:	a1 04 20 80 00       	mov    0x802004,%eax
  8000e1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000e5:	c7 44 24 08 80 13 80 	movl   $0x801380,0x8(%esp)
  8000ec:	00 
  8000ed:	c7 44 24 04 21 00 00 	movl   $0x21,0x4(%esp)
  8000f4:	00 
  8000f5:	c7 04 24 a8 13 80 00 	movl   $0x8013a8,(%esp)
  8000fc:	e8 93 00 00 00       	call   800194 <_panic>

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  800101:	a1 08 20 80 00       	mov    0x802008,%eax
  800106:	8b 50 5c             	mov    0x5c(%eax),%edx
  800109:	8b 40 48             	mov    0x48(%eax),%eax
  80010c:	89 54 24 08          	mov    %edx,0x8(%esp)
  800110:	89 44 24 04          	mov    %eax,0x4(%esp)
  800114:	c7 04 24 bb 13 80 00 	movl   $0x8013bb,(%esp)
  80011b:	e8 2b 01 00 00       	call   80024b <cprintf>

}
  800120:	83 c4 10             	add    $0x10,%esp
  800123:	5b                   	pop    %ebx
  800124:	5e                   	pop    %esi
  800125:	5d                   	pop    %ebp
  800126:	c3                   	ret    

00800127 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800127:	55                   	push   %ebp
  800128:	89 e5                	mov    %esp,%ebp
  80012a:	83 ec 18             	sub    $0x18,%esp
  80012d:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800130:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800133:	8b 75 08             	mov    0x8(%ebp),%esi
  800136:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800139:	c7 05 08 20 80 00 00 	movl   $0x0,0x802008
  800140:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800143:	e8 e9 0e 00 00       	call   801031 <sys_getenvid>
  800148:	25 ff 03 00 00       	and    $0x3ff,%eax
  80014d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800150:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800155:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80015a:	85 f6                	test   %esi,%esi
  80015c:	7e 07                	jle    800165 <libmain+0x3e>
		binaryname = argv[0];
  80015e:	8b 03                	mov    (%ebx),%eax
  800160:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800165:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800169:	89 34 24             	mov    %esi,(%esp)
  80016c:	e8 cf fe ff ff       	call   800040 <umain>

	// exit gracefully
	exit();
  800171:	e8 0a 00 00 00       	call   800180 <exit>
}
  800176:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800179:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80017c:	89 ec                	mov    %ebp,%esp
  80017e:	5d                   	pop    %ebp
  80017f:	c3                   	ret    

00800180 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800186:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80018d:	e8 d3 0e 00 00       	call   801065 <sys_env_destroy>
}
  800192:	c9                   	leave  
  800193:	c3                   	ret    

00800194 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800194:	55                   	push   %ebp
  800195:	89 e5                	mov    %esp,%ebp
  800197:	56                   	push   %esi
  800198:	53                   	push   %ebx
  800199:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80019c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80019f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8001a5:	e8 87 0e 00 00       	call   801031 <sys_getenvid>
  8001aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001ad:	89 54 24 10          	mov    %edx,0x10(%esp)
  8001b1:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8001b8:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8001bc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001c0:	c7 04 24 e4 13 80 00 	movl   $0x8013e4,(%esp)
  8001c7:	e8 7f 00 00 00       	call   80024b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001d0:	8b 45 10             	mov    0x10(%ebp),%eax
  8001d3:	89 04 24             	mov    %eax,(%esp)
  8001d6:	e8 0f 00 00 00       	call   8001ea <vcprintf>
	cprintf("\n");
  8001db:	c7 04 24 d7 13 80 00 	movl   $0x8013d7,(%esp)
  8001e2:	e8 64 00 00 00       	call   80024b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e7:	cc                   	int3   
  8001e8:	eb fd                	jmp    8001e7 <_panic+0x53>

008001ea <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8001ea:	55                   	push   %ebp
  8001eb:	89 e5                	mov    %esp,%ebp
  8001ed:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8001f3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001fa:	00 00 00 
	b.cnt = 0;
  8001fd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800204:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800207:	8b 45 0c             	mov    0xc(%ebp),%eax
  80020a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80020e:	8b 45 08             	mov    0x8(%ebp),%eax
  800211:	89 44 24 08          	mov    %eax,0x8(%esp)
  800215:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80021b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80021f:	c7 04 24 65 02 80 00 	movl   $0x800265,(%esp)
  800226:	e8 d2 01 00 00       	call   8003fd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80022b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800231:	89 44 24 04          	mov    %eax,0x4(%esp)
  800235:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80023b:	89 04 24             	mov    %eax,(%esp)
  80023e:	e8 1b 0b 00 00       	call   800d5e <sys_cputs>

	return b.cnt;
}
  800243:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800249:	c9                   	leave  
  80024a:	c3                   	ret    

0080024b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80024b:	55                   	push   %ebp
  80024c:	89 e5                	mov    %esp,%ebp
  80024e:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800251:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800254:	89 44 24 04          	mov    %eax,0x4(%esp)
  800258:	8b 45 08             	mov    0x8(%ebp),%eax
  80025b:	89 04 24             	mov    %eax,(%esp)
  80025e:	e8 87 ff ff ff       	call   8001ea <vcprintf>
	va_end(ap);

	return cnt;
}
  800263:	c9                   	leave  
  800264:	c3                   	ret    

00800265 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800265:	55                   	push   %ebp
  800266:	89 e5                	mov    %esp,%ebp
  800268:	53                   	push   %ebx
  800269:	83 ec 14             	sub    $0x14,%esp
  80026c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80026f:	8b 03                	mov    (%ebx),%eax
  800271:	8b 55 08             	mov    0x8(%ebp),%edx
  800274:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800278:	83 c0 01             	add    $0x1,%eax
  80027b:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80027d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800282:	75 19                	jne    80029d <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800284:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80028b:	00 
  80028c:	8d 43 08             	lea    0x8(%ebx),%eax
  80028f:	89 04 24             	mov    %eax,(%esp)
  800292:	e8 c7 0a 00 00       	call   800d5e <sys_cputs>
		b->idx = 0;
  800297:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80029d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8002a1:	83 c4 14             	add    $0x14,%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5d                   	pop    %ebp
  8002a6:	c3                   	ret    
  8002a7:	66 90                	xchg   %ax,%ax
  8002a9:	66 90                	xchg   %ax,%ax
  8002ab:	66 90                	xchg   %ax,%ax
  8002ad:	66 90                	xchg   %ax,%ax
  8002af:	90                   	nop

008002b0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002b0:	55                   	push   %ebp
  8002b1:	89 e5                	mov    %esp,%ebp
  8002b3:	57                   	push   %edi
  8002b4:	56                   	push   %esi
  8002b5:	53                   	push   %ebx
  8002b6:	83 ec 4c             	sub    $0x4c,%esp
  8002b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8002bc:	89 d6                	mov    %edx,%esi
  8002be:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8002ca:	8b 45 10             	mov    0x10(%ebp),%eax
  8002cd:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002d0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002d3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8002d6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002db:	39 d1                	cmp    %edx,%ecx
  8002dd:	72 15                	jb     8002f4 <printnum+0x44>
  8002df:	77 07                	ja     8002e8 <printnum+0x38>
  8002e1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002e4:	39 d0                	cmp    %edx,%eax
  8002e6:	76 0c                	jbe    8002f4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002e8:	83 eb 01             	sub    $0x1,%ebx
  8002eb:	85 db                	test   %ebx,%ebx
  8002ed:	8d 76 00             	lea    0x0(%esi),%esi
  8002f0:	7f 61                	jg     800353 <printnum+0xa3>
  8002f2:	eb 70                	jmp    800364 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002f4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8002f8:	83 eb 01             	sub    $0x1,%ebx
  8002fb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800303:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800307:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80030b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80030e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800311:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800314:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800318:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80031f:	00 
  800320:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800323:	89 04 24             	mov    %eax,(%esp)
  800326:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800329:	89 54 24 04          	mov    %edx,0x4(%esp)
  80032d:	e8 de 0d 00 00       	call   801110 <__udivdi3>
  800332:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800335:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800338:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80033c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800340:	89 04 24             	mov    %eax,(%esp)
  800343:	89 54 24 04          	mov    %edx,0x4(%esp)
  800347:	89 f2                	mov    %esi,%edx
  800349:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80034c:	e8 5f ff ff ff       	call   8002b0 <printnum>
  800351:	eb 11                	jmp    800364 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800353:	89 74 24 04          	mov    %esi,0x4(%esp)
  800357:	89 3c 24             	mov    %edi,(%esp)
  80035a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80035d:	83 eb 01             	sub    $0x1,%ebx
  800360:	85 db                	test   %ebx,%ebx
  800362:	7f ef                	jg     800353 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800364:	89 74 24 04          	mov    %esi,0x4(%esp)
  800368:	8b 74 24 04          	mov    0x4(%esp),%esi
  80036c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80036f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800373:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80037a:	00 
  80037b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80037e:	89 14 24             	mov    %edx,(%esp)
  800381:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800384:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800388:	e8 b3 0e 00 00       	call   801240 <__umoddi3>
  80038d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800391:	0f be 80 08 14 80 00 	movsbl 0x801408(%eax),%eax
  800398:	89 04 24             	mov    %eax,(%esp)
  80039b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80039e:	83 c4 4c             	add    $0x4c,%esp
  8003a1:	5b                   	pop    %ebx
  8003a2:	5e                   	pop    %esi
  8003a3:	5f                   	pop    %edi
  8003a4:	5d                   	pop    %ebp
  8003a5:	c3                   	ret    

008003a6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8003a9:	83 fa 01             	cmp    $0x1,%edx
  8003ac:	7e 0e                	jle    8003bc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8003ae:	8b 10                	mov    (%eax),%edx
  8003b0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003b3:	89 08                	mov    %ecx,(%eax)
  8003b5:	8b 02                	mov    (%edx),%eax
  8003b7:	8b 52 04             	mov    0x4(%edx),%edx
  8003ba:	eb 22                	jmp    8003de <getuint+0x38>
	else if (lflag)
  8003bc:	85 d2                	test   %edx,%edx
  8003be:	74 10                	je     8003d0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8003c0:	8b 10                	mov    (%eax),%edx
  8003c2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c5:	89 08                	mov    %ecx,(%eax)
  8003c7:	8b 02                	mov    (%edx),%eax
  8003c9:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ce:	eb 0e                	jmp    8003de <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8003d0:	8b 10                	mov    (%eax),%edx
  8003d2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d5:	89 08                	mov    %ecx,(%eax)
  8003d7:	8b 02                	mov    (%edx),%eax
  8003d9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003de:	5d                   	pop    %ebp
  8003df:	c3                   	ret    

008003e0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ea:	8b 10                	mov    (%eax),%edx
  8003ec:	3b 50 04             	cmp    0x4(%eax),%edx
  8003ef:	73 0a                	jae    8003fb <sprintputch+0x1b>
		*b->buf++ = ch;
  8003f1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f4:	88 0a                	mov    %cl,(%edx)
  8003f6:	83 c2 01             	add    $0x1,%edx
  8003f9:	89 10                	mov    %edx,(%eax)
}
  8003fb:	5d                   	pop    %ebp
  8003fc:	c3                   	ret    

008003fd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8003fd:	55                   	push   %ebp
  8003fe:	89 e5                	mov    %esp,%ebp
  800400:	57                   	push   %edi
  800401:	56                   	push   %esi
  800402:	53                   	push   %ebx
  800403:	83 ec 5c             	sub    $0x5c,%esp
  800406:	8b 7d 08             	mov    0x8(%ebp),%edi
  800409:	8b 75 0c             	mov    0xc(%ebp),%esi
  80040c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80040f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800416:	eb 11                	jmp    800429 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800418:	85 c0                	test   %eax,%eax
  80041a:	0f 84 16 04 00 00    	je     800836 <vprintfmt+0x439>
				return;
			putch(ch, putdat);
  800420:	89 74 24 04          	mov    %esi,0x4(%esp)
  800424:	89 04 24             	mov    %eax,(%esp)
  800427:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800429:	0f b6 03             	movzbl (%ebx),%eax
  80042c:	83 c3 01             	add    $0x1,%ebx
  80042f:	83 f8 25             	cmp    $0x25,%eax
  800432:	75 e4                	jne    800418 <vprintfmt+0x1b>
  800434:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80043b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800442:	b9 00 00 00 00       	mov    $0x0,%ecx
  800447:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80044b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800452:	eb 06                	jmp    80045a <vprintfmt+0x5d>
  800454:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800458:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80045a:	0f b6 13             	movzbl (%ebx),%edx
  80045d:	0f b6 c2             	movzbl %dl,%eax
  800460:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800463:	8d 43 01             	lea    0x1(%ebx),%eax
  800466:	83 ea 23             	sub    $0x23,%edx
  800469:	80 fa 55             	cmp    $0x55,%dl
  80046c:	0f 87 a7 03 00 00    	ja     800819 <vprintfmt+0x41c>
  800472:	0f b6 d2             	movzbl %dl,%edx
  800475:	ff 24 95 c0 14 80 00 	jmp    *0x8014c0(,%edx,4)
  80047c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800480:	eb d6                	jmp    800458 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800482:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800485:	83 ea 30             	sub    $0x30,%edx
  800488:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80048b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80048e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800491:	83 fb 09             	cmp    $0x9,%ebx
  800494:	77 54                	ja     8004ea <vprintfmt+0xed>
  800496:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800499:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80049c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80049f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8004a2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8004a6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8004a9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8004ac:	83 fb 09             	cmp    $0x9,%ebx
  8004af:	76 eb                	jbe    80049c <vprintfmt+0x9f>
  8004b1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8004b4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004b7:	eb 31                	jmp    8004ea <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8004b9:	8b 55 14             	mov    0x14(%ebp),%edx
  8004bc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8004bf:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8004c2:	8b 12                	mov    (%edx),%edx
  8004c4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8004c7:	eb 21                	jmp    8004ea <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8004c9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d2:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  8004d6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004d9:	e9 7a ff ff ff       	jmp    800458 <vprintfmt+0x5b>
  8004de:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8004e5:	e9 6e ff ff ff       	jmp    800458 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8004ea:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8004ee:	0f 89 64 ff ff ff    	jns    800458 <vprintfmt+0x5b>
  8004f4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8004f7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8004fa:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8004fd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800500:	e9 53 ff ff ff       	jmp    800458 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800505:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800508:	e9 4b ff ff ff       	jmp    800458 <vprintfmt+0x5b>
  80050d:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800510:	8b 45 14             	mov    0x14(%ebp),%eax
  800513:	8d 50 04             	lea    0x4(%eax),%edx
  800516:	89 55 14             	mov    %edx,0x14(%ebp)
  800519:	89 74 24 04          	mov    %esi,0x4(%esp)
  80051d:	8b 00                	mov    (%eax),%eax
  80051f:	89 04 24             	mov    %eax,(%esp)
  800522:	ff d7                	call   *%edi
  800524:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800527:	e9 fd fe ff ff       	jmp    800429 <vprintfmt+0x2c>
  80052c:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80052f:	8b 45 14             	mov    0x14(%ebp),%eax
  800532:	8d 50 04             	lea    0x4(%eax),%edx
  800535:	89 55 14             	mov    %edx,0x14(%ebp)
  800538:	8b 00                	mov    (%eax),%eax
  80053a:	89 c2                	mov    %eax,%edx
  80053c:	c1 fa 1f             	sar    $0x1f,%edx
  80053f:	31 d0                	xor    %edx,%eax
  800541:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800543:	83 f8 08             	cmp    $0x8,%eax
  800546:	7f 0b                	jg     800553 <vprintfmt+0x156>
  800548:	8b 14 85 20 16 80 00 	mov    0x801620(,%eax,4),%edx
  80054f:	85 d2                	test   %edx,%edx
  800551:	75 20                	jne    800573 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800553:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800557:	c7 44 24 08 19 14 80 	movl   $0x801419,0x8(%esp)
  80055e:	00 
  80055f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800563:	89 3c 24             	mov    %edi,(%esp)
  800566:	e8 53 03 00 00       	call   8008be <printfmt>
  80056b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80056e:	e9 b6 fe ff ff       	jmp    800429 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800573:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800577:	c7 44 24 08 22 14 80 	movl   $0x801422,0x8(%esp)
  80057e:	00 
  80057f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800583:	89 3c 24             	mov    %edi,(%esp)
  800586:	e8 33 03 00 00       	call   8008be <printfmt>
  80058b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80058e:	e9 96 fe ff ff       	jmp    800429 <vprintfmt+0x2c>
  800593:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800596:	89 c3                	mov    %eax,%ebx
  800598:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80059b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80059e:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8005a1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005a4:	8d 50 04             	lea    0x4(%eax),%edx
  8005a7:	89 55 14             	mov    %edx,0x14(%ebp)
  8005aa:	8b 00                	mov    (%eax),%eax
  8005ac:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8005af:	85 c0                	test   %eax,%eax
  8005b1:	b8 25 14 80 00       	mov    $0x801425,%eax
  8005b6:	0f 45 45 c4          	cmovne -0x3c(%ebp),%eax
  8005ba:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8005bd:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8005c1:	7e 06                	jle    8005c9 <vprintfmt+0x1cc>
  8005c3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8005c7:	75 13                	jne    8005dc <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005c9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005cc:	0f be 02             	movsbl (%edx),%eax
  8005cf:	85 c0                	test   %eax,%eax
  8005d1:	0f 85 9b 00 00 00    	jne    800672 <vprintfmt+0x275>
  8005d7:	e9 88 00 00 00       	jmp    800664 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8005dc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8005e0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  8005e3:	89 0c 24             	mov    %ecx,(%esp)
  8005e6:	e8 20 03 00 00       	call   80090b <strnlen>
  8005eb:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8005ee:	29 c2                	sub    %eax,%edx
  8005f0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005f3:	85 d2                	test   %edx,%edx
  8005f5:	7e d2                	jle    8005c9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  8005f7:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  8005fb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8005fe:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800601:	89 d3                	mov    %edx,%ebx
  800603:	89 74 24 04          	mov    %esi,0x4(%esp)
  800607:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80060a:	89 04 24             	mov    %eax,(%esp)
  80060d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80060f:	83 eb 01             	sub    $0x1,%ebx
  800612:	85 db                	test   %ebx,%ebx
  800614:	7f ed                	jg     800603 <vprintfmt+0x206>
  800616:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  800619:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800620:	eb a7                	jmp    8005c9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800622:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800626:	74 1a                	je     800642 <vprintfmt+0x245>
  800628:	8d 50 e0             	lea    -0x20(%eax),%edx
  80062b:	83 fa 5e             	cmp    $0x5e,%edx
  80062e:	76 12                	jbe    800642 <vprintfmt+0x245>
					putch('?', putdat);
  800630:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800634:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80063b:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80063e:	66 90                	xchg   %ax,%ax
  800640:	eb 0a                	jmp    80064c <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800642:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800646:	89 04 24             	mov    %eax,(%esp)
  800649:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80064c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800650:	0f be 03             	movsbl (%ebx),%eax
  800653:	85 c0                	test   %eax,%eax
  800655:	74 05                	je     80065c <vprintfmt+0x25f>
  800657:	83 c3 01             	add    $0x1,%ebx
  80065a:	eb 29                	jmp    800685 <vprintfmt+0x288>
  80065c:	89 fe                	mov    %edi,%esi
  80065e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800661:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800664:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800668:	7f 2e                	jg     800698 <vprintfmt+0x29b>
  80066a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80066d:	e9 b7 fd ff ff       	jmp    800429 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800672:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800675:	83 c2 01             	add    $0x1,%edx
  800678:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80067b:	89 f7                	mov    %esi,%edi
  80067d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800680:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800683:	89 d3                	mov    %edx,%ebx
  800685:	85 f6                	test   %esi,%esi
  800687:	78 99                	js     800622 <vprintfmt+0x225>
  800689:	83 ee 01             	sub    $0x1,%esi
  80068c:	79 94                	jns    800622 <vprintfmt+0x225>
  80068e:	89 fe                	mov    %edi,%esi
  800690:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800693:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800696:	eb cc                	jmp    800664 <vprintfmt+0x267>
  800698:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80069b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80069e:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8006a9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8006ab:	83 eb 01             	sub    $0x1,%ebx
  8006ae:	85 db                	test   %ebx,%ebx
  8006b0:	7f ec                	jg     80069e <vprintfmt+0x2a1>
  8006b2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8006b5:	e9 6f fd ff ff       	jmp    800429 <vprintfmt+0x2c>
  8006ba:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006bd:	83 f9 01             	cmp    $0x1,%ecx
  8006c0:	7e 16                	jle    8006d8 <vprintfmt+0x2db>
		return va_arg(*ap, long long);
  8006c2:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c5:	8d 50 08             	lea    0x8(%eax),%edx
  8006c8:	89 55 14             	mov    %edx,0x14(%ebp)
  8006cb:	8b 10                	mov    (%eax),%edx
  8006cd:	8b 48 04             	mov    0x4(%eax),%ecx
  8006d0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8006d3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006d6:	eb 32                	jmp    80070a <vprintfmt+0x30d>
	else if (lflag)
  8006d8:	85 c9                	test   %ecx,%ecx
  8006da:	74 18                	je     8006f4 <vprintfmt+0x2f7>
		return va_arg(*ap, long);
  8006dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8006df:	8d 50 04             	lea    0x4(%eax),%edx
  8006e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e5:	8b 00                	mov    (%eax),%eax
  8006e7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8006ea:	89 c1                	mov    %eax,%ecx
  8006ec:	c1 f9 1f             	sar    $0x1f,%ecx
  8006ef:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8006f2:	eb 16                	jmp    80070a <vprintfmt+0x30d>
	else
		return va_arg(*ap, int);
  8006f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8006f7:	8d 50 04             	lea    0x4(%eax),%edx
  8006fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8006fd:	8b 00                	mov    (%eax),%eax
  8006ff:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800702:	89 c2                	mov    %eax,%edx
  800704:	c1 fa 1f             	sar    $0x1f,%edx
  800707:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80070a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80070d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800710:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800715:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800719:	0f 89 b8 00 00 00    	jns    8007d7 <vprintfmt+0x3da>
				putch('-', putdat);
  80071f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800723:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80072a:	ff d7                	call   *%edi
				num = -(long long) num;
  80072c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80072f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800732:	f7 d9                	neg    %ecx
  800734:	83 d3 00             	adc    $0x0,%ebx
  800737:	f7 db                	neg    %ebx
  800739:	b8 0a 00 00 00       	mov    $0xa,%eax
  80073e:	e9 94 00 00 00       	jmp    8007d7 <vprintfmt+0x3da>
  800743:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800746:	89 ca                	mov    %ecx,%edx
  800748:	8d 45 14             	lea    0x14(%ebp),%eax
  80074b:	e8 56 fc ff ff       	call   8003a6 <getuint>
  800750:	89 c1                	mov    %eax,%ecx
  800752:	89 d3                	mov    %edx,%ebx
  800754:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800759:	eb 7c                	jmp    8007d7 <vprintfmt+0x3da>
  80075b:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80075e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800762:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800769:	ff d7                	call   *%edi
			putch('X', putdat);
  80076b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80076f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800776:	ff d7                	call   *%edi
			putch('X', putdat);
  800778:	89 74 24 04          	mov    %esi,0x4(%esp)
  80077c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800783:	ff d7                	call   *%edi
  800785:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800788:	e9 9c fc ff ff       	jmp    800429 <vprintfmt+0x2c>
  80078d:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800790:	89 74 24 04          	mov    %esi,0x4(%esp)
  800794:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80079b:	ff d7                	call   *%edi
			putch('x', putdat);
  80079d:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007a1:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8007a8:	ff d7                	call   *%edi
			num = (unsigned long long)
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	8d 50 04             	lea    0x4(%eax),%edx
  8007b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b3:	8b 08                	mov    (%eax),%ecx
  8007b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8007ba:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8007bf:	eb 16                	jmp    8007d7 <vprintfmt+0x3da>
  8007c1:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8007c4:	89 ca                	mov    %ecx,%edx
  8007c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c9:	e8 d8 fb ff ff       	call   8003a6 <getuint>
  8007ce:	89 c1                	mov    %eax,%ecx
  8007d0:	89 d3                	mov    %edx,%ebx
  8007d2:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8007d7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8007db:	89 54 24 10          	mov    %edx,0x10(%esp)
  8007df:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8007e2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8007e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007ea:	89 0c 24             	mov    %ecx,(%esp)
  8007ed:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8007f1:	89 f2                	mov    %esi,%edx
  8007f3:	89 f8                	mov    %edi,%eax
  8007f5:	e8 b6 fa ff ff       	call   8002b0 <printnum>
  8007fa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8007fd:	e9 27 fc ff ff       	jmp    800429 <vprintfmt+0x2c>
  800802:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800805:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800808:	89 74 24 04          	mov    %esi,0x4(%esp)
  80080c:	89 14 24             	mov    %edx,(%esp)
  80080f:	ff d7                	call   *%edi
  800811:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800814:	e9 10 fc ff ff       	jmp    800429 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800819:	89 74 24 04          	mov    %esi,0x4(%esp)
  80081d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800824:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800826:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800829:	80 38 25             	cmpb   $0x25,(%eax)
  80082c:	0f 84 f7 fb ff ff    	je     800429 <vprintfmt+0x2c>
  800832:	89 c3                	mov    %eax,%ebx
  800834:	eb f0                	jmp    800826 <vprintfmt+0x429>
				/* do nothing */;
			break;
		}
	}
}
  800836:	83 c4 5c             	add    $0x5c,%esp
  800839:	5b                   	pop    %ebx
  80083a:	5e                   	pop    %esi
  80083b:	5f                   	pop    %edi
  80083c:	5d                   	pop    %ebp
  80083d:	c3                   	ret    

0080083e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	83 ec 28             	sub    $0x28,%esp
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80084a:	85 c0                	test   %eax,%eax
  80084c:	74 04                	je     800852 <vsnprintf+0x14>
  80084e:	85 d2                	test   %edx,%edx
  800850:	7f 07                	jg     800859 <vsnprintf+0x1b>
  800852:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800857:	eb 3b                	jmp    800894 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800859:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80085c:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800860:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800863:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80086a:	8b 45 14             	mov    0x14(%ebp),%eax
  80086d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800871:	8b 45 10             	mov    0x10(%ebp),%eax
  800874:	89 44 24 08          	mov    %eax,0x8(%esp)
  800878:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80087b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80087f:	c7 04 24 e0 03 80 00 	movl   $0x8003e0,(%esp)
  800886:	e8 72 fb ff ff       	call   8003fd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80088b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80088e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800891:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800894:	c9                   	leave  
  800895:	c3                   	ret    

00800896 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800896:	55                   	push   %ebp
  800897:	89 e5                	mov    %esp,%ebp
  800899:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80089c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80089f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008a3:	8b 45 10             	mov    0x10(%ebp),%eax
  8008a6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ad:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b4:	89 04 24             	mov    %eax,(%esp)
  8008b7:	e8 82 ff ff ff       	call   80083e <vsnprintf>
	va_end(ap);

	return rc;
}
  8008bc:	c9                   	leave  
  8008bd:	c3                   	ret    

008008be <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8008be:	55                   	push   %ebp
  8008bf:	89 e5                	mov    %esp,%ebp
  8008c1:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8008c4:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8008c7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8008cb:	8b 45 10             	mov    0x10(%ebp),%eax
  8008ce:	89 44 24 08          	mov    %eax,0x8(%esp)
  8008d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008dc:	89 04 24             	mov    %eax,(%esp)
  8008df:	e8 19 fb ff ff       	call   8003fd <vprintfmt>
	va_end(ap);
}
  8008e4:	c9                   	leave  
  8008e5:	c3                   	ret    
  8008e6:	66 90                	xchg   %ax,%ax
  8008e8:	66 90                	xchg   %ax,%ax
  8008ea:	66 90                	xchg   %ax,%ax
  8008ec:	66 90                	xchg   %ax,%ax
  8008ee:	66 90                	xchg   %ax,%ax

008008f0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008f0:	55                   	push   %ebp
  8008f1:	89 e5                	mov    %esp,%ebp
  8008f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8008fb:	80 3a 00             	cmpb   $0x0,(%edx)
  8008fe:	74 09                	je     800909 <strlen+0x19>
		n++;
  800900:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800903:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800907:	75 f7                	jne    800900 <strlen+0x10>
		n++;
	return n;
}
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    

0080090b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80090b:	55                   	push   %ebp
  80090c:	89 e5                	mov    %esp,%ebp
  80090e:	53                   	push   %ebx
  80090f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800912:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800915:	85 c9                	test   %ecx,%ecx
  800917:	74 19                	je     800932 <strnlen+0x27>
  800919:	80 3b 00             	cmpb   $0x0,(%ebx)
  80091c:	74 14                	je     800932 <strnlen+0x27>
  80091e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800923:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800926:	39 c8                	cmp    %ecx,%eax
  800928:	74 0d                	je     800937 <strnlen+0x2c>
  80092a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  80092e:	75 f3                	jne    800923 <strnlen+0x18>
  800930:	eb 05                	jmp    800937 <strnlen+0x2c>
  800932:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800937:	5b                   	pop    %ebx
  800938:	5d                   	pop    %ebp
  800939:	c3                   	ret    

0080093a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80093a:	55                   	push   %ebp
  80093b:	89 e5                	mov    %esp,%ebp
  80093d:	53                   	push   %ebx
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800944:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800949:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  80094d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800950:	83 c2 01             	add    $0x1,%edx
  800953:	84 c9                	test   %cl,%cl
  800955:	75 f2                	jne    800949 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800957:	5b                   	pop    %ebx
  800958:	5d                   	pop    %ebp
  800959:	c3                   	ret    

0080095a <strcat>:

char *
strcat(char *dst, const char *src)
{
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	53                   	push   %ebx
  80095e:	83 ec 08             	sub    $0x8,%esp
  800961:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800964:	89 1c 24             	mov    %ebx,(%esp)
  800967:	e8 84 ff ff ff       	call   8008f0 <strlen>
	strcpy(dst + len, src);
  80096c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80096f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800973:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800976:	89 04 24             	mov    %eax,(%esp)
  800979:	e8 bc ff ff ff       	call   80093a <strcpy>
	return dst;
}
  80097e:	89 d8                	mov    %ebx,%eax
  800980:	83 c4 08             	add    $0x8,%esp
  800983:	5b                   	pop    %ebx
  800984:	5d                   	pop    %ebp
  800985:	c3                   	ret    

00800986 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800986:	55                   	push   %ebp
  800987:	89 e5                	mov    %esp,%ebp
  800989:	56                   	push   %esi
  80098a:	53                   	push   %ebx
  80098b:	8b 45 08             	mov    0x8(%ebp),%eax
  80098e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800991:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800994:	85 f6                	test   %esi,%esi
  800996:	74 18                	je     8009b0 <strncpy+0x2a>
  800998:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80099d:	0f b6 1a             	movzbl (%edx),%ebx
  8009a0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8009a3:	80 3a 01             	cmpb   $0x1,(%edx)
  8009a6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009a9:	83 c1 01             	add    $0x1,%ecx
  8009ac:	39 ce                	cmp    %ecx,%esi
  8009ae:	77 ed                	ja     80099d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  8009b0:	5b                   	pop    %ebx
  8009b1:	5e                   	pop    %esi
  8009b2:	5d                   	pop    %ebp
  8009b3:	c3                   	ret    

008009b4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8009b4:	55                   	push   %ebp
  8009b5:	89 e5                	mov    %esp,%ebp
  8009b7:	56                   	push   %esi
  8009b8:	53                   	push   %ebx
  8009b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8009bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8009c2:	89 f0                	mov    %esi,%eax
  8009c4:	85 c9                	test   %ecx,%ecx
  8009c6:	74 27                	je     8009ef <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  8009c8:	83 e9 01             	sub    $0x1,%ecx
  8009cb:	74 1d                	je     8009ea <strlcpy+0x36>
  8009cd:	0f b6 1a             	movzbl (%edx),%ebx
  8009d0:	84 db                	test   %bl,%bl
  8009d2:	74 16                	je     8009ea <strlcpy+0x36>
			*dst++ = *src++;
  8009d4:	88 18                	mov    %bl,(%eax)
  8009d6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009d9:	83 e9 01             	sub    $0x1,%ecx
  8009dc:	74 0e                	je     8009ec <strlcpy+0x38>
			*dst++ = *src++;
  8009de:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  8009e1:	0f b6 1a             	movzbl (%edx),%ebx
  8009e4:	84 db                	test   %bl,%bl
  8009e6:	75 ec                	jne    8009d4 <strlcpy+0x20>
  8009e8:	eb 02                	jmp    8009ec <strlcpy+0x38>
  8009ea:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  8009ec:	c6 00 00             	movb   $0x0,(%eax)
  8009ef:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  8009f1:	5b                   	pop    %ebx
  8009f2:	5e                   	pop    %esi
  8009f3:	5d                   	pop    %ebp
  8009f4:	c3                   	ret    

008009f5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009f5:	55                   	push   %ebp
  8009f6:	89 e5                	mov    %esp,%ebp
  8009f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009fb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009fe:	0f b6 01             	movzbl (%ecx),%eax
  800a01:	84 c0                	test   %al,%al
  800a03:	74 15                	je     800a1a <strcmp+0x25>
  800a05:	3a 02                	cmp    (%edx),%al
  800a07:	75 11                	jne    800a1a <strcmp+0x25>
		p++, q++;
  800a09:	83 c1 01             	add    $0x1,%ecx
  800a0c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a0f:	0f b6 01             	movzbl (%ecx),%eax
  800a12:	84 c0                	test   %al,%al
  800a14:	74 04                	je     800a1a <strcmp+0x25>
  800a16:	3a 02                	cmp    (%edx),%al
  800a18:	74 ef                	je     800a09 <strcmp+0x14>
  800a1a:	0f b6 c0             	movzbl %al,%eax
  800a1d:	0f b6 12             	movzbl (%edx),%edx
  800a20:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a22:	5d                   	pop    %ebp
  800a23:	c3                   	ret    

00800a24 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a24:	55                   	push   %ebp
  800a25:	89 e5                	mov    %esp,%ebp
  800a27:	53                   	push   %ebx
  800a28:	8b 55 08             	mov    0x8(%ebp),%edx
  800a2b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a2e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800a31:	85 c0                	test   %eax,%eax
  800a33:	74 23                	je     800a58 <strncmp+0x34>
  800a35:	0f b6 1a             	movzbl (%edx),%ebx
  800a38:	84 db                	test   %bl,%bl
  800a3a:	74 25                	je     800a61 <strncmp+0x3d>
  800a3c:	3a 19                	cmp    (%ecx),%bl
  800a3e:	75 21                	jne    800a61 <strncmp+0x3d>
  800a40:	83 e8 01             	sub    $0x1,%eax
  800a43:	74 13                	je     800a58 <strncmp+0x34>
		n--, p++, q++;
  800a45:	83 c2 01             	add    $0x1,%edx
  800a48:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a4b:	0f b6 1a             	movzbl (%edx),%ebx
  800a4e:	84 db                	test   %bl,%bl
  800a50:	74 0f                	je     800a61 <strncmp+0x3d>
  800a52:	3a 19                	cmp    (%ecx),%bl
  800a54:	74 ea                	je     800a40 <strncmp+0x1c>
  800a56:	eb 09                	jmp    800a61 <strncmp+0x3d>
  800a58:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800a5d:	5b                   	pop    %ebx
  800a5e:	5d                   	pop    %ebp
  800a5f:	90                   	nop
  800a60:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a61:	0f b6 02             	movzbl (%edx),%eax
  800a64:	0f b6 11             	movzbl (%ecx),%edx
  800a67:	29 d0                	sub    %edx,%eax
  800a69:	eb f2                	jmp    800a5d <strncmp+0x39>

00800a6b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a75:	0f b6 10             	movzbl (%eax),%edx
  800a78:	84 d2                	test   %dl,%dl
  800a7a:	74 18                	je     800a94 <strchr+0x29>
		if (*s == c)
  800a7c:	38 ca                	cmp    %cl,%dl
  800a7e:	75 0a                	jne    800a8a <strchr+0x1f>
  800a80:	eb 17                	jmp    800a99 <strchr+0x2e>
  800a82:	38 ca                	cmp    %cl,%dl
  800a84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a88:	74 0f                	je     800a99 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a8a:	83 c0 01             	add    $0x1,%eax
  800a8d:	0f b6 10             	movzbl (%eax),%edx
  800a90:	84 d2                	test   %dl,%dl
  800a92:	75 ee                	jne    800a82 <strchr+0x17>
  800a94:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    

00800a9b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a9b:	55                   	push   %ebp
  800a9c:	89 e5                	mov    %esp,%ebp
  800a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aa5:	0f b6 10             	movzbl (%eax),%edx
  800aa8:	84 d2                	test   %dl,%dl
  800aaa:	74 18                	je     800ac4 <strfind+0x29>
		if (*s == c)
  800aac:	38 ca                	cmp    %cl,%dl
  800aae:	75 0a                	jne    800aba <strfind+0x1f>
  800ab0:	eb 12                	jmp    800ac4 <strfind+0x29>
  800ab2:	38 ca                	cmp    %cl,%dl
  800ab4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ab8:	74 0a                	je     800ac4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800aba:	83 c0 01             	add    $0x1,%eax
  800abd:	0f b6 10             	movzbl (%eax),%edx
  800ac0:	84 d2                	test   %dl,%dl
  800ac2:	75 ee                	jne    800ab2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800ac4:	5d                   	pop    %ebp
  800ac5:	c3                   	ret    

00800ac6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800ac6:	55                   	push   %ebp
  800ac7:	89 e5                	mov    %esp,%ebp
  800ac9:	83 ec 0c             	sub    $0xc,%esp
  800acc:	89 1c 24             	mov    %ebx,(%esp)
  800acf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ad3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800ad7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800ada:	8b 45 0c             	mov    0xc(%ebp),%eax
  800add:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800ae0:	85 c9                	test   %ecx,%ecx
  800ae2:	74 30                	je     800b14 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ae4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800aea:	75 25                	jne    800b11 <memset+0x4b>
  800aec:	f6 c1 03             	test   $0x3,%cl
  800aef:	75 20                	jne    800b11 <memset+0x4b>
		c &= 0xFF;
  800af1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800af4:	89 d3                	mov    %edx,%ebx
  800af6:	c1 e3 08             	shl    $0x8,%ebx
  800af9:	89 d6                	mov    %edx,%esi
  800afb:	c1 e6 18             	shl    $0x18,%esi
  800afe:	89 d0                	mov    %edx,%eax
  800b00:	c1 e0 10             	shl    $0x10,%eax
  800b03:	09 f0                	or     %esi,%eax
  800b05:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800b07:	09 d8                	or     %ebx,%eax
  800b09:	c1 e9 02             	shr    $0x2,%ecx
  800b0c:	fc                   	cld    
  800b0d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b0f:	eb 03                	jmp    800b14 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b11:	fc                   	cld    
  800b12:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b14:	89 f8                	mov    %edi,%eax
  800b16:	8b 1c 24             	mov    (%esp),%ebx
  800b19:	8b 74 24 04          	mov    0x4(%esp),%esi
  800b1d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800b21:	89 ec                	mov    %ebp,%esp
  800b23:	5d                   	pop    %ebp
  800b24:	c3                   	ret    

00800b25 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b25:	55                   	push   %ebp
  800b26:	89 e5                	mov    %esp,%ebp
  800b28:	83 ec 08             	sub    $0x8,%esp
  800b2b:	89 34 24             	mov    %esi,(%esp)
  800b2e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800b32:	8b 45 08             	mov    0x8(%ebp),%eax
  800b35:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800b38:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800b3b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800b3d:	39 c6                	cmp    %eax,%esi
  800b3f:	73 35                	jae    800b76 <memmove+0x51>
  800b41:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b44:	39 d0                	cmp    %edx,%eax
  800b46:	73 2e                	jae    800b76 <memmove+0x51>
		s += n;
		d += n;
  800b48:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b4a:	f6 c2 03             	test   $0x3,%dl
  800b4d:	75 1b                	jne    800b6a <memmove+0x45>
  800b4f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b55:	75 13                	jne    800b6a <memmove+0x45>
  800b57:	f6 c1 03             	test   $0x3,%cl
  800b5a:	75 0e                	jne    800b6a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800b5c:	83 ef 04             	sub    $0x4,%edi
  800b5f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b62:	c1 e9 02             	shr    $0x2,%ecx
  800b65:	fd                   	std    
  800b66:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b68:	eb 09                	jmp    800b73 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b6a:	83 ef 01             	sub    $0x1,%edi
  800b6d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b70:	fd                   	std    
  800b71:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b73:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b74:	eb 20                	jmp    800b96 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b76:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b7c:	75 15                	jne    800b93 <memmove+0x6e>
  800b7e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b84:	75 0d                	jne    800b93 <memmove+0x6e>
  800b86:	f6 c1 03             	test   $0x3,%cl
  800b89:	75 08                	jne    800b93 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800b8b:	c1 e9 02             	shr    $0x2,%ecx
  800b8e:	fc                   	cld    
  800b8f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b91:	eb 03                	jmp    800b96 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b93:	fc                   	cld    
  800b94:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b96:	8b 34 24             	mov    (%esp),%esi
  800b99:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b9d:	89 ec                	mov    %ebp,%esp
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ba7:	8b 45 10             	mov    0x10(%ebp),%eax
  800baa:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bae:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bb8:	89 04 24             	mov    %eax,(%esp)
  800bbb:	e8 65 ff ff ff       	call   800b25 <memmove>
}
  800bc0:	c9                   	leave  
  800bc1:	c3                   	ret    

00800bc2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bc2:	55                   	push   %ebp
  800bc3:	89 e5                	mov    %esp,%ebp
  800bc5:	57                   	push   %edi
  800bc6:	56                   	push   %esi
  800bc7:	53                   	push   %ebx
  800bc8:	8b 75 08             	mov    0x8(%ebp),%esi
  800bcb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800bce:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd1:	85 c9                	test   %ecx,%ecx
  800bd3:	74 36                	je     800c0b <memcmp+0x49>
		if (*s1 != *s2)
  800bd5:	0f b6 06             	movzbl (%esi),%eax
  800bd8:	0f b6 1f             	movzbl (%edi),%ebx
  800bdb:	38 d8                	cmp    %bl,%al
  800bdd:	74 20                	je     800bff <memcmp+0x3d>
  800bdf:	eb 14                	jmp    800bf5 <memcmp+0x33>
  800be1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800be6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800beb:	83 c2 01             	add    $0x1,%edx
  800bee:	83 e9 01             	sub    $0x1,%ecx
  800bf1:	38 d8                	cmp    %bl,%al
  800bf3:	74 12                	je     800c07 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800bf5:	0f b6 c0             	movzbl %al,%eax
  800bf8:	0f b6 db             	movzbl %bl,%ebx
  800bfb:	29 d8                	sub    %ebx,%eax
  800bfd:	eb 11                	jmp    800c10 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bff:	83 e9 01             	sub    $0x1,%ecx
  800c02:	ba 00 00 00 00       	mov    $0x0,%edx
  800c07:	85 c9                	test   %ecx,%ecx
  800c09:	75 d6                	jne    800be1 <memcmp+0x1f>
  800c0b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800c10:	5b                   	pop    %ebx
  800c11:	5e                   	pop    %esi
  800c12:	5f                   	pop    %edi
  800c13:	5d                   	pop    %ebp
  800c14:	c3                   	ret    

00800c15 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c1b:	89 c2                	mov    %eax,%edx
  800c1d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c20:	39 d0                	cmp    %edx,%eax
  800c22:	73 15                	jae    800c39 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c24:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800c28:	38 08                	cmp    %cl,(%eax)
  800c2a:	75 06                	jne    800c32 <memfind+0x1d>
  800c2c:	eb 0b                	jmp    800c39 <memfind+0x24>
  800c2e:	38 08                	cmp    %cl,(%eax)
  800c30:	74 07                	je     800c39 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c32:	83 c0 01             	add    $0x1,%eax
  800c35:	39 c2                	cmp    %eax,%edx
  800c37:	77 f5                	ja     800c2e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c3b:	55                   	push   %ebp
  800c3c:	89 e5                	mov    %esp,%ebp
  800c3e:	57                   	push   %edi
  800c3f:	56                   	push   %esi
  800c40:	53                   	push   %ebx
  800c41:	83 ec 04             	sub    $0x4,%esp
  800c44:	8b 55 08             	mov    0x8(%ebp),%edx
  800c47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c4a:	0f b6 02             	movzbl (%edx),%eax
  800c4d:	3c 20                	cmp    $0x20,%al
  800c4f:	74 04                	je     800c55 <strtol+0x1a>
  800c51:	3c 09                	cmp    $0x9,%al
  800c53:	75 0e                	jne    800c63 <strtol+0x28>
		s++;
  800c55:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c58:	0f b6 02             	movzbl (%edx),%eax
  800c5b:	3c 20                	cmp    $0x20,%al
  800c5d:	74 f6                	je     800c55 <strtol+0x1a>
  800c5f:	3c 09                	cmp    $0x9,%al
  800c61:	74 f2                	je     800c55 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c63:	3c 2b                	cmp    $0x2b,%al
  800c65:	75 0c                	jne    800c73 <strtol+0x38>
		s++;
  800c67:	83 c2 01             	add    $0x1,%edx
  800c6a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c71:	eb 15                	jmp    800c88 <strtol+0x4d>
	else if (*s == '-')
  800c73:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800c7a:	3c 2d                	cmp    $0x2d,%al
  800c7c:	75 0a                	jne    800c88 <strtol+0x4d>
		s++, neg = 1;
  800c7e:	83 c2 01             	add    $0x1,%edx
  800c81:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c88:	85 db                	test   %ebx,%ebx
  800c8a:	0f 94 c0             	sete   %al
  800c8d:	74 05                	je     800c94 <strtol+0x59>
  800c8f:	83 fb 10             	cmp    $0x10,%ebx
  800c92:	75 18                	jne    800cac <strtol+0x71>
  800c94:	80 3a 30             	cmpb   $0x30,(%edx)
  800c97:	75 13                	jne    800cac <strtol+0x71>
  800c99:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c9d:	8d 76 00             	lea    0x0(%esi),%esi
  800ca0:	75 0a                	jne    800cac <strtol+0x71>
		s += 2, base = 16;
  800ca2:	83 c2 02             	add    $0x2,%edx
  800ca5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800caa:	eb 15                	jmp    800cc1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cac:	84 c0                	test   %al,%al
  800cae:	66 90                	xchg   %ax,%ax
  800cb0:	74 0f                	je     800cc1 <strtol+0x86>
  800cb2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800cb7:	80 3a 30             	cmpb   $0x30,(%edx)
  800cba:	75 05                	jne    800cc1 <strtol+0x86>
		s++, base = 8;
  800cbc:	83 c2 01             	add    $0x1,%edx
  800cbf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800cc6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800cc8:	0f b6 0a             	movzbl (%edx),%ecx
  800ccb:	89 cf                	mov    %ecx,%edi
  800ccd:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800cd0:	80 fb 09             	cmp    $0x9,%bl
  800cd3:	77 08                	ja     800cdd <strtol+0xa2>
			dig = *s - '0';
  800cd5:	0f be c9             	movsbl %cl,%ecx
  800cd8:	83 e9 30             	sub    $0x30,%ecx
  800cdb:	eb 1e                	jmp    800cfb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800cdd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800ce0:	80 fb 19             	cmp    $0x19,%bl
  800ce3:	77 08                	ja     800ced <strtol+0xb2>
			dig = *s - 'a' + 10;
  800ce5:	0f be c9             	movsbl %cl,%ecx
  800ce8:	83 e9 57             	sub    $0x57,%ecx
  800ceb:	eb 0e                	jmp    800cfb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800ced:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800cf0:	80 fb 19             	cmp    $0x19,%bl
  800cf3:	77 15                	ja     800d0a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800cf5:	0f be c9             	movsbl %cl,%ecx
  800cf8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800cfb:	39 f1                	cmp    %esi,%ecx
  800cfd:	7d 0b                	jge    800d0a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800cff:	83 c2 01             	add    $0x1,%edx
  800d02:	0f af c6             	imul   %esi,%eax
  800d05:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800d08:	eb be                	jmp    800cc8 <strtol+0x8d>
  800d0a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800d0c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d10:	74 05                	je     800d17 <strtol+0xdc>
		*endptr = (char *) s;
  800d12:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d15:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800d17:	89 ca                	mov    %ecx,%edx
  800d19:	f7 da                	neg    %edx
  800d1b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800d1f:	0f 45 c2             	cmovne %edx,%eax
}
  800d22:	83 c4 04             	add    $0x4,%esp
  800d25:	5b                   	pop    %ebx
  800d26:	5e                   	pop    %esi
  800d27:	5f                   	pop    %edi
  800d28:	5d                   	pop    %ebp
  800d29:	c3                   	ret    

00800d2a <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	83 ec 0c             	sub    $0xc,%esp
  800d30:	89 1c 24             	mov    %ebx,(%esp)
  800d33:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d37:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d3b:	ba 00 00 00 00       	mov    $0x0,%edx
  800d40:	b8 01 00 00 00       	mov    $0x1,%eax
  800d45:	89 d1                	mov    %edx,%ecx
  800d47:	89 d3                	mov    %edx,%ebx
  800d49:	89 d7                	mov    %edx,%edi
  800d4b:	89 d6                	mov    %edx,%esi
  800d4d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800d4f:	8b 1c 24             	mov    (%esp),%ebx
  800d52:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d56:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d5a:	89 ec                	mov    %ebp,%esp
  800d5c:	5d                   	pop    %ebp
  800d5d:	c3                   	ret    

00800d5e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800d5e:	55                   	push   %ebp
  800d5f:	89 e5                	mov    %esp,%ebp
  800d61:	83 ec 0c             	sub    $0xc,%esp
  800d64:	89 1c 24             	mov    %ebx,(%esp)
  800d67:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d6b:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d6f:	b8 00 00 00 00       	mov    $0x0,%eax
  800d74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d77:	8b 55 08             	mov    0x8(%ebp),%edx
  800d7a:	89 c3                	mov    %eax,%ebx
  800d7c:	89 c7                	mov    %eax,%edi
  800d7e:	89 c6                	mov    %eax,%esi
  800d80:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d82:	8b 1c 24             	mov    (%esp),%ebx
  800d85:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d89:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d8d:	89 ec                	mov    %ebp,%esp
  800d8f:	5d                   	pop    %ebp
  800d90:	c3                   	ret    

00800d91 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d91:	55                   	push   %ebp
  800d92:	89 e5                	mov    %esp,%ebp
  800d94:	83 ec 38             	sub    $0x38,%esp
  800d97:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d9a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d9d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800da0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800da5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800daa:	8b 55 08             	mov    0x8(%ebp),%edx
  800dad:	89 cb                	mov    %ecx,%ebx
  800daf:	89 cf                	mov    %ecx,%edi
  800db1:	89 ce                	mov    %ecx,%esi
  800db3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800db5:	85 c0                	test   %eax,%eax
  800db7:	7e 28                	jle    800de1 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800db9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dbd:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800dc4:	00 
  800dc5:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800dcc:	00 
  800dcd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dd4:	00 
  800dd5:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800ddc:	e8 b3 f3 ff ff       	call   800194 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800de1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800de4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800de7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800dea:	89 ec                	mov    %ebp,%esp
  800dec:	5d                   	pop    %ebp
  800ded:	c3                   	ret    

00800dee <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	83 ec 0c             	sub    $0xc,%esp
  800df4:	89 1c 24             	mov    %ebx,(%esp)
  800df7:	89 74 24 04          	mov    %esi,0x4(%esp)
  800dfb:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800dff:	be 00 00 00 00       	mov    $0x0,%esi
  800e04:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e09:	8b 7d 14             	mov    0x14(%ebp),%edi
  800e0c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800e0f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e12:	8b 55 08             	mov    0x8(%ebp),%edx
  800e15:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800e17:	8b 1c 24             	mov    (%esp),%ebx
  800e1a:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e1e:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e22:	89 ec                	mov    %ebp,%esp
  800e24:	5d                   	pop    %ebp
  800e25:	c3                   	ret    

00800e26 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e26:	55                   	push   %ebp
  800e27:	89 e5                	mov    %esp,%ebp
  800e29:	83 ec 38             	sub    $0x38,%esp
  800e2c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e2f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e32:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3a:	b8 09 00 00 00       	mov    $0x9,%eax
  800e3f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e42:	8b 55 08             	mov    0x8(%ebp),%edx
  800e45:	89 df                	mov    %ebx,%edi
  800e47:	89 de                	mov    %ebx,%esi
  800e49:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e4b:	85 c0                	test   %eax,%eax
  800e4d:	7e 28                	jle    800e77 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e4f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e53:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800e5a:	00 
  800e5b:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800e62:	00 
  800e63:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e6a:	00 
  800e6b:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800e72:	e8 1d f3 ff ff       	call   800194 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800e77:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e7a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e7d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e80:	89 ec                	mov    %ebp,%esp
  800e82:	5d                   	pop    %ebp
  800e83:	c3                   	ret    

00800e84 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e84:	55                   	push   %ebp
  800e85:	89 e5                	mov    %esp,%ebp
  800e87:	83 ec 38             	sub    $0x38,%esp
  800e8a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e8d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e90:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e93:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e98:	b8 08 00 00 00       	mov    $0x8,%eax
  800e9d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ea0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ea3:	89 df                	mov    %ebx,%edi
  800ea5:	89 de                	mov    %ebx,%esi
  800ea7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ea9:	85 c0                	test   %eax,%eax
  800eab:	7e 28                	jle    800ed5 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ead:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eb1:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800eb8:	00 
  800eb9:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800ec0:	00 
  800ec1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ec8:	00 
  800ec9:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800ed0:	e8 bf f2 ff ff       	call   800194 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ed5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ed8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800edb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ede:	89 ec                	mov    %ebp,%esp
  800ee0:	5d                   	pop    %ebp
  800ee1:	c3                   	ret    

00800ee2 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800ee2:	55                   	push   %ebp
  800ee3:	89 e5                	mov    %esp,%ebp
  800ee5:	83 ec 38             	sub    $0x38,%esp
  800ee8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eeb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800eee:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ef6:	b8 06 00 00 00       	mov    $0x6,%eax
  800efb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800efe:	8b 55 08             	mov    0x8(%ebp),%edx
  800f01:	89 df                	mov    %ebx,%edi
  800f03:	89 de                	mov    %ebx,%esi
  800f05:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f07:	85 c0                	test   %eax,%eax
  800f09:	7e 28                	jle    800f33 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f0b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f0f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800f16:	00 
  800f17:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800f1e:	00 
  800f1f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f26:	00 
  800f27:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800f2e:	e8 61 f2 ff ff       	call   800194 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800f33:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f36:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f39:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f3c:	89 ec                	mov    %ebp,%esp
  800f3e:	5d                   	pop    %ebp
  800f3f:	c3                   	ret    

00800f40 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f40:	55                   	push   %ebp
  800f41:	89 e5                	mov    %esp,%ebp
  800f43:	83 ec 38             	sub    $0x38,%esp
  800f46:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f49:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f4c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f4f:	b8 05 00 00 00       	mov    $0x5,%eax
  800f54:	8b 75 18             	mov    0x18(%ebp),%esi
  800f57:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f5a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f5d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f60:	8b 55 08             	mov    0x8(%ebp),%edx
  800f63:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f65:	85 c0                	test   %eax,%eax
  800f67:	7e 28                	jle    800f91 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f69:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f6d:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800f74:	00 
  800f75:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800f7c:	00 
  800f7d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f84:	00 
  800f85:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800f8c:	e8 03 f2 ff ff       	call   800194 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f91:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f94:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f97:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f9a:	89 ec                	mov    %ebp,%esp
  800f9c:	5d                   	pop    %ebp
  800f9d:	c3                   	ret    

00800f9e <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f9e:	55                   	push   %ebp
  800f9f:	89 e5                	mov    %esp,%ebp
  800fa1:	83 ec 38             	sub    $0x38,%esp
  800fa4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fa7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800faa:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fad:	be 00 00 00 00       	mov    $0x0,%esi
  800fb2:	b8 04 00 00 00       	mov    $0x4,%eax
  800fb7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800fba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fbd:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc0:	89 f7                	mov    %esi,%edi
  800fc2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fc4:	85 c0                	test   %eax,%eax
  800fc6:	7e 28                	jle    800ff0 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fc8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fcc:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800fd3:	00 
  800fd4:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  800fdb:	00 
  800fdc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe3:	00 
  800fe4:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  800feb:	e8 a4 f1 ff ff       	call   800194 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800ff0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ff3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ff6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ff9:	89 ec                	mov    %ebp,%esp
  800ffb:	5d                   	pop    %ebp
  800ffc:	c3                   	ret    

00800ffd <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	83 ec 0c             	sub    $0xc,%esp
  801003:	89 1c 24             	mov    %ebx,(%esp)
  801006:	89 74 24 04          	mov    %esi,0x4(%esp)
  80100a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80100e:	ba 00 00 00 00       	mov    $0x0,%edx
  801013:	b8 0a 00 00 00       	mov    $0xa,%eax
  801018:	89 d1                	mov    %edx,%ecx
  80101a:	89 d3                	mov    %edx,%ebx
  80101c:	89 d7                	mov    %edx,%edi
  80101e:	89 d6                	mov    %edx,%esi
  801020:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801022:	8b 1c 24             	mov    (%esp),%ebx
  801025:	8b 74 24 04          	mov    0x4(%esp),%esi
  801029:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80102d:	89 ec                	mov    %ebp,%esp
  80102f:	5d                   	pop    %ebp
  801030:	c3                   	ret    

00801031 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	83 ec 0c             	sub    $0xc,%esp
  801037:	89 1c 24             	mov    %ebx,(%esp)
  80103a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80103e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801042:	ba 00 00 00 00       	mov    $0x0,%edx
  801047:	b8 02 00 00 00       	mov    $0x2,%eax
  80104c:	89 d1                	mov    %edx,%ecx
  80104e:	89 d3                	mov    %edx,%ebx
  801050:	89 d7                	mov    %edx,%edi
  801052:	89 d6                	mov    %edx,%esi
  801054:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801056:	8b 1c 24             	mov    (%esp),%ebx
  801059:	8b 74 24 04          	mov    0x4(%esp),%esi
  80105d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801061:	89 ec                	mov    %ebp,%esp
  801063:	5d                   	pop    %ebp
  801064:	c3                   	ret    

00801065 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801065:	55                   	push   %ebp
  801066:	89 e5                	mov    %esp,%ebp
  801068:	83 ec 38             	sub    $0x38,%esp
  80106b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80106e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801071:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801074:	b9 00 00 00 00       	mov    $0x0,%ecx
  801079:	b8 03 00 00 00       	mov    $0x3,%eax
  80107e:	8b 55 08             	mov    0x8(%ebp),%edx
  801081:	89 cb                	mov    %ecx,%ebx
  801083:	89 cf                	mov    %ecx,%edi
  801085:	89 ce                	mov    %ecx,%esi
  801087:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801089:	85 c0                	test   %eax,%eax
  80108b:	7e 28                	jle    8010b5 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80108d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801091:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801098:	00 
  801099:	c7 44 24 08 44 16 80 	movl   $0x801644,0x8(%esp)
  8010a0:	00 
  8010a1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010a8:	00 
  8010a9:	c7 04 24 61 16 80 00 	movl   $0x801661,(%esp)
  8010b0:	e8 df f0 ff ff       	call   800194 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8010b5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010b8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010bb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010be:	89 ec                	mov    %ebp,%esp
  8010c0:	5d                   	pop    %ebp
  8010c1:	c3                   	ret    

008010c2 <sfork>:
}

// Challenge!
int
sfork(void)
{
  8010c2:	55                   	push   %ebp
  8010c3:	89 e5                	mov    %esp,%ebp
  8010c5:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  8010c8:	c7 44 24 08 6f 16 80 	movl   $0x80166f,0x8(%esp)
  8010cf:	00 
  8010d0:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  8010d7:	00 
  8010d8:	c7 04 24 85 16 80 00 	movl   $0x801685,(%esp)
  8010df:	e8 b0 f0 ff ff       	call   800194 <_panic>

008010e4 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  8010e4:	55                   	push   %ebp
  8010e5:	89 e5                	mov    %esp,%ebp
  8010e7:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  8010ea:	c7 44 24 08 70 16 80 	movl   $0x801670,0x8(%esp)
  8010f1:	00 
  8010f2:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  8010f9:	00 
  8010fa:	c7 04 24 85 16 80 00 	movl   $0x801685,(%esp)
  801101:	e8 8e f0 ff ff       	call   800194 <_panic>
  801106:	66 90                	xchg   %ax,%ax
  801108:	66 90                	xchg   %ax,%ax
  80110a:	66 90                	xchg   %ax,%ax
  80110c:	66 90                	xchg   %ax,%ax
  80110e:	66 90                	xchg   %ax,%ax

00801110 <__udivdi3>:
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	57                   	push   %edi
  801114:	56                   	push   %esi
  801115:	83 ec 10             	sub    $0x10,%esp
  801118:	8b 45 14             	mov    0x14(%ebp),%eax
  80111b:	8b 55 08             	mov    0x8(%ebp),%edx
  80111e:	8b 75 10             	mov    0x10(%ebp),%esi
  801121:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801124:	85 c0                	test   %eax,%eax
  801126:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801129:	75 35                	jne    801160 <__udivdi3+0x50>
  80112b:	39 fe                	cmp    %edi,%esi
  80112d:	77 61                	ja     801190 <__udivdi3+0x80>
  80112f:	85 f6                	test   %esi,%esi
  801131:	75 0b                	jne    80113e <__udivdi3+0x2e>
  801133:	b8 01 00 00 00       	mov    $0x1,%eax
  801138:	31 d2                	xor    %edx,%edx
  80113a:	f7 f6                	div    %esi
  80113c:	89 c6                	mov    %eax,%esi
  80113e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801141:	31 d2                	xor    %edx,%edx
  801143:	89 f8                	mov    %edi,%eax
  801145:	f7 f6                	div    %esi
  801147:	89 c7                	mov    %eax,%edi
  801149:	89 c8                	mov    %ecx,%eax
  80114b:	f7 f6                	div    %esi
  80114d:	89 c1                	mov    %eax,%ecx
  80114f:	89 fa                	mov    %edi,%edx
  801151:	89 c8                	mov    %ecx,%eax
  801153:	83 c4 10             	add    $0x10,%esp
  801156:	5e                   	pop    %esi
  801157:	5f                   	pop    %edi
  801158:	5d                   	pop    %ebp
  801159:	c3                   	ret    
  80115a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801160:	39 f8                	cmp    %edi,%eax
  801162:	77 1c                	ja     801180 <__udivdi3+0x70>
  801164:	0f bd d0             	bsr    %eax,%edx
  801167:	83 f2 1f             	xor    $0x1f,%edx
  80116a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80116d:	75 39                	jne    8011a8 <__udivdi3+0x98>
  80116f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801172:	0f 86 a0 00 00 00    	jbe    801218 <__udivdi3+0x108>
  801178:	39 f8                	cmp    %edi,%eax
  80117a:	0f 82 98 00 00 00    	jb     801218 <__udivdi3+0x108>
  801180:	31 ff                	xor    %edi,%edi
  801182:	31 c9                	xor    %ecx,%ecx
  801184:	89 c8                	mov    %ecx,%eax
  801186:	89 fa                	mov    %edi,%edx
  801188:	83 c4 10             	add    $0x10,%esp
  80118b:	5e                   	pop    %esi
  80118c:	5f                   	pop    %edi
  80118d:	5d                   	pop    %ebp
  80118e:	c3                   	ret    
  80118f:	90                   	nop
  801190:	89 d1                	mov    %edx,%ecx
  801192:	89 fa                	mov    %edi,%edx
  801194:	89 c8                	mov    %ecx,%eax
  801196:	31 ff                	xor    %edi,%edi
  801198:	f7 f6                	div    %esi
  80119a:	89 c1                	mov    %eax,%ecx
  80119c:	89 fa                	mov    %edi,%edx
  80119e:	89 c8                	mov    %ecx,%eax
  8011a0:	83 c4 10             	add    $0x10,%esp
  8011a3:	5e                   	pop    %esi
  8011a4:	5f                   	pop    %edi
  8011a5:	5d                   	pop    %ebp
  8011a6:	c3                   	ret    
  8011a7:	90                   	nop
  8011a8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011ac:	89 f2                	mov    %esi,%edx
  8011ae:	d3 e0                	shl    %cl,%eax
  8011b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8011b3:	b8 20 00 00 00       	mov    $0x20,%eax
  8011b8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8011bb:	89 c1                	mov    %eax,%ecx
  8011bd:	d3 ea                	shr    %cl,%edx
  8011bf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011c3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8011c6:	d3 e6                	shl    %cl,%esi
  8011c8:	89 c1                	mov    %eax,%ecx
  8011ca:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8011cd:	89 fe                	mov    %edi,%esi
  8011cf:	d3 ee                	shr    %cl,%esi
  8011d1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011d5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8011d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011db:	d3 e7                	shl    %cl,%edi
  8011dd:	89 c1                	mov    %eax,%ecx
  8011df:	d3 ea                	shr    %cl,%edx
  8011e1:	09 d7                	or     %edx,%edi
  8011e3:	89 f2                	mov    %esi,%edx
  8011e5:	89 f8                	mov    %edi,%eax
  8011e7:	f7 75 ec             	divl   -0x14(%ebp)
  8011ea:	89 d6                	mov    %edx,%esi
  8011ec:	89 c7                	mov    %eax,%edi
  8011ee:	f7 65 e8             	mull   -0x18(%ebp)
  8011f1:	39 d6                	cmp    %edx,%esi
  8011f3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8011f6:	72 30                	jb     801228 <__udivdi3+0x118>
  8011f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8011fb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8011ff:	d3 e2                	shl    %cl,%edx
  801201:	39 c2                	cmp    %eax,%edx
  801203:	73 05                	jae    80120a <__udivdi3+0xfa>
  801205:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801208:	74 1e                	je     801228 <__udivdi3+0x118>
  80120a:	89 f9                	mov    %edi,%ecx
  80120c:	31 ff                	xor    %edi,%edi
  80120e:	e9 71 ff ff ff       	jmp    801184 <__udivdi3+0x74>
  801213:	90                   	nop
  801214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801218:	31 ff                	xor    %edi,%edi
  80121a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80121f:	e9 60 ff ff ff       	jmp    801184 <__udivdi3+0x74>
  801224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801228:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80122b:	31 ff                	xor    %edi,%edi
  80122d:	89 c8                	mov    %ecx,%eax
  80122f:	89 fa                	mov    %edi,%edx
  801231:	83 c4 10             	add    $0x10,%esp
  801234:	5e                   	pop    %esi
  801235:	5f                   	pop    %edi
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    
  801238:	66 90                	xchg   %ax,%ax
  80123a:	66 90                	xchg   %ax,%ax
  80123c:	66 90                	xchg   %ax,%ax
  80123e:	66 90                	xchg   %ax,%ax

00801240 <__umoddi3>:
  801240:	55                   	push   %ebp
  801241:	89 e5                	mov    %esp,%ebp
  801243:	57                   	push   %edi
  801244:	56                   	push   %esi
  801245:	83 ec 20             	sub    $0x20,%esp
  801248:	8b 55 14             	mov    0x14(%ebp),%edx
  80124b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80124e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801251:	8b 75 0c             	mov    0xc(%ebp),%esi
  801254:	85 d2                	test   %edx,%edx
  801256:	89 c8                	mov    %ecx,%eax
  801258:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80125b:	75 13                	jne    801270 <__umoddi3+0x30>
  80125d:	39 f7                	cmp    %esi,%edi
  80125f:	76 3f                	jbe    8012a0 <__umoddi3+0x60>
  801261:	89 f2                	mov    %esi,%edx
  801263:	f7 f7                	div    %edi
  801265:	89 d0                	mov    %edx,%eax
  801267:	31 d2                	xor    %edx,%edx
  801269:	83 c4 20             	add    $0x20,%esp
  80126c:	5e                   	pop    %esi
  80126d:	5f                   	pop    %edi
  80126e:	5d                   	pop    %ebp
  80126f:	c3                   	ret    
  801270:	39 f2                	cmp    %esi,%edx
  801272:	77 4c                	ja     8012c0 <__umoddi3+0x80>
  801274:	0f bd ca             	bsr    %edx,%ecx
  801277:	83 f1 1f             	xor    $0x1f,%ecx
  80127a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80127d:	75 51                	jne    8012d0 <__umoddi3+0x90>
  80127f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801282:	0f 87 e0 00 00 00    	ja     801368 <__umoddi3+0x128>
  801288:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80128b:	29 f8                	sub    %edi,%eax
  80128d:	19 d6                	sbb    %edx,%esi
  80128f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801292:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801295:	89 f2                	mov    %esi,%edx
  801297:	83 c4 20             	add    $0x20,%esp
  80129a:	5e                   	pop    %esi
  80129b:	5f                   	pop    %edi
  80129c:	5d                   	pop    %ebp
  80129d:	c3                   	ret    
  80129e:	66 90                	xchg   %ax,%ax
  8012a0:	85 ff                	test   %edi,%edi
  8012a2:	75 0b                	jne    8012af <__umoddi3+0x6f>
  8012a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8012a9:	31 d2                	xor    %edx,%edx
  8012ab:	f7 f7                	div    %edi
  8012ad:	89 c7                	mov    %eax,%edi
  8012af:	89 f0                	mov    %esi,%eax
  8012b1:	31 d2                	xor    %edx,%edx
  8012b3:	f7 f7                	div    %edi
  8012b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012b8:	f7 f7                	div    %edi
  8012ba:	eb a9                	jmp    801265 <__umoddi3+0x25>
  8012bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012c0:	89 c8                	mov    %ecx,%eax
  8012c2:	89 f2                	mov    %esi,%edx
  8012c4:	83 c4 20             	add    $0x20,%esp
  8012c7:	5e                   	pop    %esi
  8012c8:	5f                   	pop    %edi
  8012c9:	5d                   	pop    %ebp
  8012ca:	c3                   	ret    
  8012cb:	90                   	nop
  8012cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012d0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012d4:	d3 e2                	shl    %cl,%edx
  8012d6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8012d9:	ba 20 00 00 00       	mov    $0x20,%edx
  8012de:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8012e1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8012e4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012e8:	89 fa                	mov    %edi,%edx
  8012ea:	d3 ea                	shr    %cl,%edx
  8012ec:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8012f0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8012f3:	d3 e7                	shl    %cl,%edi
  8012f5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8012f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8012fc:	89 f2                	mov    %esi,%edx
  8012fe:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801301:	89 c7                	mov    %eax,%edi
  801303:	d3 ea                	shr    %cl,%edx
  801305:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801309:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80130c:	89 c2                	mov    %eax,%edx
  80130e:	d3 e6                	shl    %cl,%esi
  801310:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801314:	d3 ea                	shr    %cl,%edx
  801316:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80131a:	09 d6                	or     %edx,%esi
  80131c:	89 f0                	mov    %esi,%eax
  80131e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801321:	d3 e7                	shl    %cl,%edi
  801323:	89 f2                	mov    %esi,%edx
  801325:	f7 75 f4             	divl   -0xc(%ebp)
  801328:	89 d6                	mov    %edx,%esi
  80132a:	f7 65 e8             	mull   -0x18(%ebp)
  80132d:	39 d6                	cmp    %edx,%esi
  80132f:	72 2b                	jb     80135c <__umoddi3+0x11c>
  801331:	39 c7                	cmp    %eax,%edi
  801333:	72 23                	jb     801358 <__umoddi3+0x118>
  801335:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801339:	29 c7                	sub    %eax,%edi
  80133b:	19 d6                	sbb    %edx,%esi
  80133d:	89 f0                	mov    %esi,%eax
  80133f:	89 f2                	mov    %esi,%edx
  801341:	d3 ef                	shr    %cl,%edi
  801343:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801347:	d3 e0                	shl    %cl,%eax
  801349:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80134d:	09 f8                	or     %edi,%eax
  80134f:	d3 ea                	shr    %cl,%edx
  801351:	83 c4 20             	add    $0x20,%esp
  801354:	5e                   	pop    %esi
  801355:	5f                   	pop    %edi
  801356:	5d                   	pop    %ebp
  801357:	c3                   	ret    
  801358:	39 d6                	cmp    %edx,%esi
  80135a:	75 d9                	jne    801335 <__umoddi3+0xf5>
  80135c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80135f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801362:	eb d1                	jmp    801335 <__umoddi3+0xf5>
  801364:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801368:	39 f2                	cmp    %esi,%edx
  80136a:	0f 82 18 ff ff ff    	jb     801288 <__umoddi3+0x48>
  801370:	e9 1d ff ff ff       	jmp    801292 <__umoddi3+0x52>
