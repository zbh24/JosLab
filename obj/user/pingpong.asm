
obj/user/pingpong：     文件格式 elf32-i386


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
  80002c:	e8 c6 00 00 00       	call   8000f7 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	57                   	push   %edi
  800037:	56                   	push   %esi
  800038:	53                   	push   %ebx
  800039:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  80003c:	e8 23 10 00 00       	call   801064 <fork>
  800041:	89 c3                	mov    %eax,%ebx
  800043:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800046:	85 c0                	test   %eax,%eax
  800048:	74 3c                	je     800086 <umain+0x53>
		// get the ball rolling
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80004a:	e8 62 0f 00 00       	call   800fb1 <sys_getenvid>
  80004f:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800053:	89 44 24 04          	mov    %eax,0x4(%esp)
  800057:	c7 04 24 e0 13 80 00 	movl   $0x8013e0,(%esp)
  80005e:	e8 62 01 00 00       	call   8001c5 <cprintf>
		ipc_send(who, 0, 0, 0);
  800063:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80006a:	00 
  80006b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800072:	00 
  800073:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80007a:	00 
  80007b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80007e:	89 04 24             	mov    %eax,(%esp)
  800081:	e8 44 10 00 00       	call   8010ca <ipc_send>
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  800086:	8d 7d e4             	lea    -0x1c(%ebp),%edi
  800089:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800090:	00 
  800091:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800098:	00 
  800099:	89 3c 24             	mov    %edi,(%esp)
  80009c:	e8 4b 10 00 00       	call   8010ec <ipc_recv>
  8000a1:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  8000a3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8000a6:	e8 06 0f 00 00       	call   800fb1 <sys_getenvid>
  8000ab:	89 74 24 0c          	mov    %esi,0xc(%esp)
  8000af:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8000b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8000b7:	c7 04 24 f6 13 80 00 	movl   $0x8013f6,(%esp)
  8000be:	e8 02 01 00 00       	call   8001c5 <cprintf>
		if (i == 10)
  8000c3:	83 fb 0a             	cmp    $0xa,%ebx
  8000c6:	74 27                	je     8000ef <umain+0xbc>
			return;
		i++;
  8000c8:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  8000cb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8000d2:	00 
  8000d3:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8000da:	00 
  8000db:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e2:	89 04 24             	mov    %eax,(%esp)
  8000e5:	e8 e0 0f 00 00       	call   8010ca <ipc_send>
		if (i == 10)
  8000ea:	83 fb 0a             	cmp    $0xa,%ebx
  8000ed:	75 9a                	jne    800089 <umain+0x56>
			return;
	}

}
  8000ef:	83 c4 2c             	add    $0x2c,%esp
  8000f2:	5b                   	pop    %ebx
  8000f3:	5e                   	pop    %esi
  8000f4:	5f                   	pop    %edi
  8000f5:	5d                   	pop    %ebp
  8000f6:	c3                   	ret    

008000f7 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	83 ec 18             	sub    $0x18,%esp
  8000fd:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800100:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800103:	8b 75 08             	mov    0x8(%ebp),%esi
  800106:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800109:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800110:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800113:	e8 99 0e 00 00       	call   800fb1 <sys_getenvid>
  800118:	25 ff 03 00 00       	and    $0x3ff,%eax
  80011d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800120:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800125:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80012a:	85 f6                	test   %esi,%esi
  80012c:	7e 07                	jle    800135 <libmain+0x3e>
		binaryname = argv[0];
  80012e:	8b 03                	mov    (%ebx),%eax
  800130:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800135:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800139:	89 34 24             	mov    %esi,(%esp)
  80013c:	e8 f2 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800141:	e8 0a 00 00 00       	call   800150 <exit>
}
  800146:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  800149:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80014c:	89 ec                	mov    %ebp,%esp
  80014e:	5d                   	pop    %ebp
  80014f:	c3                   	ret    

00800150 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800150:	55                   	push   %ebp
  800151:	89 e5                	mov    %esp,%ebp
  800153:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800156:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80015d:	e8 83 0e 00 00       	call   800fe5 <sys_env_destroy>
}
  800162:	c9                   	leave  
  800163:	c3                   	ret    

00800164 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800164:	55                   	push   %ebp
  800165:	89 e5                	mov    %esp,%ebp
  800167:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80016d:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800174:	00 00 00 
	b.cnt = 0;
  800177:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80017e:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800181:	8b 45 0c             	mov    0xc(%ebp),%eax
  800184:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800188:	8b 45 08             	mov    0x8(%ebp),%eax
  80018b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80018f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800195:	89 44 24 04          	mov    %eax,0x4(%esp)
  800199:	c7 04 24 df 01 80 00 	movl   $0x8001df,(%esp)
  8001a0:	e8 d8 01 00 00       	call   80037d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001a5:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8001ab:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001af:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001b5:	89 04 24             	mov    %eax,(%esp)
  8001b8:	e8 21 0b 00 00       	call   800cde <sys_cputs>

	return b.cnt;
}
  8001bd:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8001cb:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8001ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001d5:	89 04 24             	mov    %eax,(%esp)
  8001d8:	e8 87 ff ff ff       	call   800164 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001dd:	c9                   	leave  
  8001de:	c3                   	ret    

008001df <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	53                   	push   %ebx
  8001e3:	83 ec 14             	sub    $0x14,%esp
  8001e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001e9:	8b 03                	mov    (%ebx),%eax
  8001eb:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ee:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8001f2:	83 c0 01             	add    $0x1,%eax
  8001f5:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8001f7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001fc:	75 19                	jne    800217 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8001fe:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800205:	00 
  800206:	8d 43 08             	lea    0x8(%ebx),%eax
  800209:	89 04 24             	mov    %eax,(%esp)
  80020c:	e8 cd 0a 00 00       	call   800cde <sys_cputs>
		b->idx = 0;
  800211:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800217:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80021b:	83 c4 14             	add    $0x14,%esp
  80021e:	5b                   	pop    %ebx
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    
  800221:	66 90                	xchg   %ax,%ax
  800223:	66 90                	xchg   %ax,%ax
  800225:	66 90                	xchg   %ax,%ax
  800227:	66 90                	xchg   %ax,%ax
  800229:	66 90                	xchg   %ax,%ax
  80022b:	66 90                	xchg   %ax,%ax
  80022d:	66 90                	xchg   %ax,%ax
  80022f:	90                   	nop

00800230 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800230:	55                   	push   %ebp
  800231:	89 e5                	mov    %esp,%ebp
  800233:	57                   	push   %edi
  800234:	56                   	push   %esi
  800235:	53                   	push   %ebx
  800236:	83 ec 4c             	sub    $0x4c,%esp
  800239:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80023c:	89 d6                	mov    %edx,%esi
  80023e:	8b 45 08             	mov    0x8(%ebp),%eax
  800241:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800244:	8b 55 0c             	mov    0xc(%ebp),%edx
  800247:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80024a:	8b 45 10             	mov    0x10(%ebp),%eax
  80024d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800250:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800253:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800256:	b9 00 00 00 00       	mov    $0x0,%ecx
  80025b:	39 d1                	cmp    %edx,%ecx
  80025d:	72 15                	jb     800274 <printnum+0x44>
  80025f:	77 07                	ja     800268 <printnum+0x38>
  800261:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800264:	39 d0                	cmp    %edx,%eax
  800266:	76 0c                	jbe    800274 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800268:	83 eb 01             	sub    $0x1,%ebx
  80026b:	85 db                	test   %ebx,%ebx
  80026d:	8d 76 00             	lea    0x0(%esi),%esi
  800270:	7f 61                	jg     8002d3 <printnum+0xa3>
  800272:	eb 70                	jmp    8002e4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800274:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800278:	83 eb 01             	sub    $0x1,%ebx
  80027b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80027f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800283:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800287:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80028b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80028e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800291:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800294:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800298:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80029f:	00 
  8002a0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8002a3:	89 04 24             	mov    %eax,(%esp)
  8002a6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8002a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002ad:	e8 be 0e 00 00       	call   801170 <__udivdi3>
  8002b2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8002b5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8002b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8002bc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8002c0:	89 04 24             	mov    %eax,(%esp)
  8002c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8002c7:	89 f2                	mov    %esi,%edx
  8002c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8002cc:	e8 5f ff ff ff       	call   800230 <printnum>
  8002d1:	eb 11                	jmp    8002e4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002d7:	89 3c 24             	mov    %edi,(%esp)
  8002da:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8002dd:	83 eb 01             	sub    $0x1,%ebx
  8002e0:	85 db                	test   %ebx,%ebx
  8002e2:	7f ef                	jg     8002d3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002e8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8002ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8002ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002f3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8002fa:	00 
  8002fb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8002fe:	89 14 24             	mov    %edx,(%esp)
  800301:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800304:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800308:	e8 93 0f 00 00       	call   8012a0 <__umoddi3>
  80030d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800311:	0f be 80 13 14 80 00 	movsbl 0x801413(%eax),%eax
  800318:	89 04 24             	mov    %eax,(%esp)
  80031b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80031e:	83 c4 4c             	add    $0x4c,%esp
  800321:	5b                   	pop    %ebx
  800322:	5e                   	pop    %esi
  800323:	5f                   	pop    %edi
  800324:	5d                   	pop    %ebp
  800325:	c3                   	ret    

00800326 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800326:	55                   	push   %ebp
  800327:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800329:	83 fa 01             	cmp    $0x1,%edx
  80032c:	7e 0e                	jle    80033c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80032e:	8b 10                	mov    (%eax),%edx
  800330:	8d 4a 08             	lea    0x8(%edx),%ecx
  800333:	89 08                	mov    %ecx,(%eax)
  800335:	8b 02                	mov    (%edx),%eax
  800337:	8b 52 04             	mov    0x4(%edx),%edx
  80033a:	eb 22                	jmp    80035e <getuint+0x38>
	else if (lflag)
  80033c:	85 d2                	test   %edx,%edx
  80033e:	74 10                	je     800350 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800340:	8b 10                	mov    (%eax),%edx
  800342:	8d 4a 04             	lea    0x4(%edx),%ecx
  800345:	89 08                	mov    %ecx,(%eax)
  800347:	8b 02                	mov    (%edx),%eax
  800349:	ba 00 00 00 00       	mov    $0x0,%edx
  80034e:	eb 0e                	jmp    80035e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800350:	8b 10                	mov    (%eax),%edx
  800352:	8d 4a 04             	lea    0x4(%edx),%ecx
  800355:	89 08                	mov    %ecx,(%eax)
  800357:	8b 02                	mov    (%edx),%eax
  800359:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80035e:	5d                   	pop    %ebp
  80035f:	c3                   	ret    

00800360 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800360:	55                   	push   %ebp
  800361:	89 e5                	mov    %esp,%ebp
  800363:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800366:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80036a:	8b 10                	mov    (%eax),%edx
  80036c:	3b 50 04             	cmp    0x4(%eax),%edx
  80036f:	73 0a                	jae    80037b <sprintputch+0x1b>
		*b->buf++ = ch;
  800371:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800374:	88 0a                	mov    %cl,(%edx)
  800376:	83 c2 01             	add    $0x1,%edx
  800379:	89 10                	mov    %edx,(%eax)
}
  80037b:	5d                   	pop    %ebp
  80037c:	c3                   	ret    

0080037d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80037d:	55                   	push   %ebp
  80037e:	89 e5                	mov    %esp,%ebp
  800380:	57                   	push   %edi
  800381:	56                   	push   %esi
  800382:	53                   	push   %ebx
  800383:	83 ec 5c             	sub    $0x5c,%esp
  800386:	8b 7d 08             	mov    0x8(%ebp),%edi
  800389:	8b 75 0c             	mov    0xc(%ebp),%esi
  80038c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80038f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800396:	eb 11                	jmp    8003a9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800398:	85 c0                	test   %eax,%eax
  80039a:	0f 84 16 04 00 00    	je     8007b6 <vprintfmt+0x439>
				return;
			putch(ch, putdat);
  8003a0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003a4:	89 04 24             	mov    %eax,(%esp)
  8003a7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8003a9:	0f b6 03             	movzbl (%ebx),%eax
  8003ac:	83 c3 01             	add    $0x1,%ebx
  8003af:	83 f8 25             	cmp    $0x25,%eax
  8003b2:	75 e4                	jne    800398 <vprintfmt+0x1b>
  8003b4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8003bb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8003c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003c7:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8003cb:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8003d2:	eb 06                	jmp    8003da <vprintfmt+0x5d>
  8003d4:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8003d8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8003da:	0f b6 13             	movzbl (%ebx),%edx
  8003dd:	0f b6 c2             	movzbl %dl,%eax
  8003e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003e3:	8d 43 01             	lea    0x1(%ebx),%eax
  8003e6:	83 ea 23             	sub    $0x23,%edx
  8003e9:	80 fa 55             	cmp    $0x55,%dl
  8003ec:	0f 87 a7 03 00 00    	ja     800799 <vprintfmt+0x41c>
  8003f2:	0f b6 d2             	movzbl %dl,%edx
  8003f5:	ff 24 95 e0 14 80 00 	jmp    *0x8014e0(,%edx,4)
  8003fc:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800400:	eb d6                	jmp    8003d8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800402:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800405:	83 ea 30             	sub    $0x30,%edx
  800408:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80040b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80040e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800411:	83 fb 09             	cmp    $0x9,%ebx
  800414:	77 54                	ja     80046a <vprintfmt+0xed>
  800416:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800419:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80041c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80041f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800422:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800426:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800429:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80042c:	83 fb 09             	cmp    $0x9,%ebx
  80042f:	76 eb                	jbe    80041c <vprintfmt+0x9f>
  800431:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800434:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800437:	eb 31                	jmp    80046a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800439:	8b 55 14             	mov    0x14(%ebp),%edx
  80043c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80043f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800442:	8b 12                	mov    (%edx),%edx
  800444:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800447:	eb 21                	jmp    80046a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800449:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80044d:	ba 00 00 00 00       	mov    $0x0,%edx
  800452:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  800456:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800459:	e9 7a ff ff ff       	jmp    8003d8 <vprintfmt+0x5b>
  80045e:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800465:	e9 6e ff ff ff       	jmp    8003d8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80046a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80046e:	0f 89 64 ff ff ff    	jns    8003d8 <vprintfmt+0x5b>
  800474:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800477:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80047a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80047d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800480:	e9 53 ff ff ff       	jmp    8003d8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800485:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800488:	e9 4b ff ff ff       	jmp    8003d8 <vprintfmt+0x5b>
  80048d:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800490:	8b 45 14             	mov    0x14(%ebp),%eax
  800493:	8d 50 04             	lea    0x4(%eax),%edx
  800496:	89 55 14             	mov    %edx,0x14(%ebp)
  800499:	89 74 24 04          	mov    %esi,0x4(%esp)
  80049d:	8b 00                	mov    (%eax),%eax
  80049f:	89 04 24             	mov    %eax,(%esp)
  8004a2:	ff d7                	call   *%edi
  8004a4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8004a7:	e9 fd fe ff ff       	jmp    8003a9 <vprintfmt+0x2c>
  8004ac:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8004af:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b2:	8d 50 04             	lea    0x4(%eax),%edx
  8004b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b8:	8b 00                	mov    (%eax),%eax
  8004ba:	89 c2                	mov    %eax,%edx
  8004bc:	c1 fa 1f             	sar    $0x1f,%edx
  8004bf:	31 d0                	xor    %edx,%eax
  8004c1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004c3:	83 f8 08             	cmp    $0x8,%eax
  8004c6:	7f 0b                	jg     8004d3 <vprintfmt+0x156>
  8004c8:	8b 14 85 40 16 80 00 	mov    0x801640(,%eax,4),%edx
  8004cf:	85 d2                	test   %edx,%edx
  8004d1:	75 20                	jne    8004f3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  8004d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004d7:	c7 44 24 08 24 14 80 	movl   $0x801424,0x8(%esp)
  8004de:	00 
  8004df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004e3:	89 3c 24             	mov    %edi,(%esp)
  8004e6:	e8 53 03 00 00       	call   80083e <printfmt>
  8004eb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004ee:	e9 b6 fe ff ff       	jmp    8003a9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8004f3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004f7:	c7 44 24 08 2d 14 80 	movl   $0x80142d,0x8(%esp)
  8004fe:	00 
  8004ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800503:	89 3c 24             	mov    %edi,(%esp)
  800506:	e8 33 03 00 00       	call   80083e <printfmt>
  80050b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80050e:	e9 96 fe ff ff       	jmp    8003a9 <vprintfmt+0x2c>
  800513:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800516:	89 c3                	mov    %eax,%ebx
  800518:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80051b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80051e:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800521:	8b 45 14             	mov    0x14(%ebp),%eax
  800524:	8d 50 04             	lea    0x4(%eax),%edx
  800527:	89 55 14             	mov    %edx,0x14(%ebp)
  80052a:	8b 00                	mov    (%eax),%eax
  80052c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80052f:	85 c0                	test   %eax,%eax
  800531:	b8 30 14 80 00       	mov    $0x801430,%eax
  800536:	0f 45 45 c4          	cmovne -0x3c(%ebp),%eax
  80053a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80053d:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800541:	7e 06                	jle    800549 <vprintfmt+0x1cc>
  800543:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800547:	75 13                	jne    80055c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800549:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80054c:	0f be 02             	movsbl (%edx),%eax
  80054f:	85 c0                	test   %eax,%eax
  800551:	0f 85 9b 00 00 00    	jne    8005f2 <vprintfmt+0x275>
  800557:	e9 88 00 00 00       	jmp    8005e4 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80055c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800560:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  800563:	89 0c 24             	mov    %ecx,(%esp)
  800566:	e8 20 03 00 00       	call   80088b <strnlen>
  80056b:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80056e:	29 c2                	sub    %eax,%edx
  800570:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800573:	85 d2                	test   %edx,%edx
  800575:	7e d2                	jle    800549 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800577:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  80057b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80057e:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800581:	89 d3                	mov    %edx,%ebx
  800583:	89 74 24 04          	mov    %esi,0x4(%esp)
  800587:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80058a:	89 04 24             	mov    %eax,(%esp)
  80058d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80058f:	83 eb 01             	sub    $0x1,%ebx
  800592:	85 db                	test   %ebx,%ebx
  800594:	7f ed                	jg     800583 <vprintfmt+0x206>
  800596:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  800599:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8005a0:	eb a7                	jmp    800549 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005a2:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8005a6:	74 1a                	je     8005c2 <vprintfmt+0x245>
  8005a8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8005ab:	83 fa 5e             	cmp    $0x5e,%edx
  8005ae:	76 12                	jbe    8005c2 <vprintfmt+0x245>
					putch('?', putdat);
  8005b0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005b4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8005bb:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8005be:	66 90                	xchg   %ax,%ax
  8005c0:	eb 0a                	jmp    8005cc <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8005c2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8005c6:	89 04 24             	mov    %eax,(%esp)
  8005c9:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005cc:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8005d0:	0f be 03             	movsbl (%ebx),%eax
  8005d3:	85 c0                	test   %eax,%eax
  8005d5:	74 05                	je     8005dc <vprintfmt+0x25f>
  8005d7:	83 c3 01             	add    $0x1,%ebx
  8005da:	eb 29                	jmp    800605 <vprintfmt+0x288>
  8005dc:	89 fe                	mov    %edi,%esi
  8005de:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8005e1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8005e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005e8:	7f 2e                	jg     800618 <vprintfmt+0x29b>
  8005ea:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8005ed:	e9 b7 fd ff ff       	jmp    8003a9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005f2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8005f5:	83 c2 01             	add    $0x1,%edx
  8005f8:	89 7d dc             	mov    %edi,-0x24(%ebp)
  8005fb:	89 f7                	mov    %esi,%edi
  8005fd:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800600:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800603:	89 d3                	mov    %edx,%ebx
  800605:	85 f6                	test   %esi,%esi
  800607:	78 99                	js     8005a2 <vprintfmt+0x225>
  800609:	83 ee 01             	sub    $0x1,%esi
  80060c:	79 94                	jns    8005a2 <vprintfmt+0x225>
  80060e:	89 fe                	mov    %edi,%esi
  800610:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800613:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800616:	eb cc                	jmp    8005e4 <vprintfmt+0x267>
  800618:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80061b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80061e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800622:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800629:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80062b:	83 eb 01             	sub    $0x1,%ebx
  80062e:	85 db                	test   %ebx,%ebx
  800630:	7f ec                	jg     80061e <vprintfmt+0x2a1>
  800632:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800635:	e9 6f fd ff ff       	jmp    8003a9 <vprintfmt+0x2c>
  80063a:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80063d:	83 f9 01             	cmp    $0x1,%ecx
  800640:	7e 16                	jle    800658 <vprintfmt+0x2db>
		return va_arg(*ap, long long);
  800642:	8b 45 14             	mov    0x14(%ebp),%eax
  800645:	8d 50 08             	lea    0x8(%eax),%edx
  800648:	89 55 14             	mov    %edx,0x14(%ebp)
  80064b:	8b 10                	mov    (%eax),%edx
  80064d:	8b 48 04             	mov    0x4(%eax),%ecx
  800650:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800653:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800656:	eb 32                	jmp    80068a <vprintfmt+0x30d>
	else if (lflag)
  800658:	85 c9                	test   %ecx,%ecx
  80065a:	74 18                	je     800674 <vprintfmt+0x2f7>
		return va_arg(*ap, long);
  80065c:	8b 45 14             	mov    0x14(%ebp),%eax
  80065f:	8d 50 04             	lea    0x4(%eax),%edx
  800662:	89 55 14             	mov    %edx,0x14(%ebp)
  800665:	8b 00                	mov    (%eax),%eax
  800667:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80066a:	89 c1                	mov    %eax,%ecx
  80066c:	c1 f9 1f             	sar    $0x1f,%ecx
  80066f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800672:	eb 16                	jmp    80068a <vprintfmt+0x30d>
	else
		return va_arg(*ap, int);
  800674:	8b 45 14             	mov    0x14(%ebp),%eax
  800677:	8d 50 04             	lea    0x4(%eax),%edx
  80067a:	89 55 14             	mov    %edx,0x14(%ebp)
  80067d:	8b 00                	mov    (%eax),%eax
  80067f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800682:	89 c2                	mov    %eax,%edx
  800684:	c1 fa 1f             	sar    $0x1f,%edx
  800687:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80068a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80068d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800690:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800695:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800699:	0f 89 b8 00 00 00    	jns    800757 <vprintfmt+0x3da>
				putch('-', putdat);
  80069f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8006aa:	ff d7                	call   *%edi
				num = -(long long) num;
  8006ac:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006af:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8006b2:	f7 d9                	neg    %ecx
  8006b4:	83 d3 00             	adc    $0x0,%ebx
  8006b7:	f7 db                	neg    %ebx
  8006b9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8006be:	e9 94 00 00 00       	jmp    800757 <vprintfmt+0x3da>
  8006c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8006c6:	89 ca                	mov    %ecx,%edx
  8006c8:	8d 45 14             	lea    0x14(%ebp),%eax
  8006cb:	e8 56 fc ff ff       	call   800326 <getuint>
  8006d0:	89 c1                	mov    %eax,%ecx
  8006d2:	89 d3                	mov    %edx,%ebx
  8006d4:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  8006d9:	eb 7c                	jmp    800757 <vprintfmt+0x3da>
  8006db:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  8006de:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006e2:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006e9:	ff d7                	call   *%edi
			putch('X', putdat);
  8006eb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006ef:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8006f6:	ff d7                	call   *%edi
			putch('X', putdat);
  8006f8:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006fc:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800703:	ff d7                	call   *%edi
  800705:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800708:	e9 9c fc ff ff       	jmp    8003a9 <vprintfmt+0x2c>
  80070d:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800710:	89 74 24 04          	mov    %esi,0x4(%esp)
  800714:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  80071b:	ff d7                	call   *%edi
			putch('x', putdat);
  80071d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800721:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800728:	ff d7                	call   *%edi
			num = (unsigned long long)
  80072a:	8b 45 14             	mov    0x14(%ebp),%eax
  80072d:	8d 50 04             	lea    0x4(%eax),%edx
  800730:	89 55 14             	mov    %edx,0x14(%ebp)
  800733:	8b 08                	mov    (%eax),%ecx
  800735:	bb 00 00 00 00       	mov    $0x0,%ebx
  80073a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  80073f:	eb 16                	jmp    800757 <vprintfmt+0x3da>
  800741:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800744:	89 ca                	mov    %ecx,%edx
  800746:	8d 45 14             	lea    0x14(%ebp),%eax
  800749:	e8 d8 fb ff ff       	call   800326 <getuint>
  80074e:	89 c1                	mov    %eax,%ecx
  800750:	89 d3                	mov    %edx,%ebx
  800752:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800757:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  80075b:	89 54 24 10          	mov    %edx,0x10(%esp)
  80075f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800762:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800766:	89 44 24 08          	mov    %eax,0x8(%esp)
  80076a:	89 0c 24             	mov    %ecx,(%esp)
  80076d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800771:	89 f2                	mov    %esi,%edx
  800773:	89 f8                	mov    %edi,%eax
  800775:	e8 b6 fa ff ff       	call   800230 <printnum>
  80077a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80077d:	e9 27 fc ff ff       	jmp    8003a9 <vprintfmt+0x2c>
  800782:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800785:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800788:	89 74 24 04          	mov    %esi,0x4(%esp)
  80078c:	89 14 24             	mov    %edx,(%esp)
  80078f:	ff d7                	call   *%edi
  800791:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800794:	e9 10 fc ff ff       	jmp    8003a9 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800799:	89 74 24 04          	mov    %esi,0x4(%esp)
  80079d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  8007a4:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8007a6:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8007a9:	80 38 25             	cmpb   $0x25,(%eax)
  8007ac:	0f 84 f7 fb ff ff    	je     8003a9 <vprintfmt+0x2c>
  8007b2:	89 c3                	mov    %eax,%ebx
  8007b4:	eb f0                	jmp    8007a6 <vprintfmt+0x429>
				/* do nothing */;
			break;
		}
	}
}
  8007b6:	83 c4 5c             	add    $0x5c,%esp
  8007b9:	5b                   	pop    %ebx
  8007ba:	5e                   	pop    %esi
  8007bb:	5f                   	pop    %edi
  8007bc:	5d                   	pop    %ebp
  8007bd:	c3                   	ret    

008007be <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8007be:	55                   	push   %ebp
  8007bf:	89 e5                	mov    %esp,%ebp
  8007c1:	83 ec 28             	sub    $0x28,%esp
  8007c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8007c7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  8007ca:	85 c0                	test   %eax,%eax
  8007cc:	74 04                	je     8007d2 <vsnprintf+0x14>
  8007ce:	85 d2                	test   %edx,%edx
  8007d0:	7f 07                	jg     8007d9 <vsnprintf+0x1b>
  8007d2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007d7:	eb 3b                	jmp    800814 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  8007d9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8007dc:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  8007e0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8007e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8007ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ed:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8007f1:	8b 45 10             	mov    0x10(%ebp),%eax
  8007f4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007fb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8007ff:	c7 04 24 60 03 80 00 	movl   $0x800360,(%esp)
  800806:	e8 72 fb ff ff       	call   80037d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80080b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80080e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800811:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800814:	c9                   	leave  
  800815:	c3                   	ret    

00800816 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800816:	55                   	push   %ebp
  800817:	89 e5                	mov    %esp,%ebp
  800819:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  80081c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  80081f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800823:	8b 45 10             	mov    0x10(%ebp),%eax
  800826:	89 44 24 08          	mov    %eax,0x8(%esp)
  80082a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80082d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800831:	8b 45 08             	mov    0x8(%ebp),%eax
  800834:	89 04 24             	mov    %eax,(%esp)
  800837:	e8 82 ff ff ff       	call   8007be <vsnprintf>
	va_end(ap);

	return rc;
}
  80083c:	c9                   	leave  
  80083d:	c3                   	ret    

0080083e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80083e:	55                   	push   %ebp
  80083f:	89 e5                	mov    %esp,%ebp
  800841:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800844:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800847:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80084b:	8b 45 10             	mov    0x10(%ebp),%eax
  80084e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800852:	8b 45 0c             	mov    0xc(%ebp),%eax
  800855:	89 44 24 04          	mov    %eax,0x4(%esp)
  800859:	8b 45 08             	mov    0x8(%ebp),%eax
  80085c:	89 04 24             	mov    %eax,(%esp)
  80085f:	e8 19 fb ff ff       	call   80037d <vprintfmt>
	va_end(ap);
}
  800864:	c9                   	leave  
  800865:	c3                   	ret    
  800866:	66 90                	xchg   %ax,%ax
  800868:	66 90                	xchg   %ax,%ax
  80086a:	66 90                	xchg   %ax,%ax
  80086c:	66 90                	xchg   %ax,%ax
  80086e:	66 90                	xchg   %ax,%ax

00800870 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800870:	55                   	push   %ebp
  800871:	89 e5                	mov    %esp,%ebp
  800873:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800876:	b8 00 00 00 00       	mov    $0x0,%eax
  80087b:	80 3a 00             	cmpb   $0x0,(%edx)
  80087e:	74 09                	je     800889 <strlen+0x19>
		n++;
  800880:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800883:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800887:	75 f7                	jne    800880 <strlen+0x10>
		n++;
	return n;
}
  800889:	5d                   	pop    %ebp
  80088a:	c3                   	ret    

0080088b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	53                   	push   %ebx
  80088f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800892:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800895:	85 c9                	test   %ecx,%ecx
  800897:	74 19                	je     8008b2 <strnlen+0x27>
  800899:	80 3b 00             	cmpb   $0x0,(%ebx)
  80089c:	74 14                	je     8008b2 <strnlen+0x27>
  80089e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  8008a3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008a6:	39 c8                	cmp    %ecx,%eax
  8008a8:	74 0d                	je     8008b7 <strnlen+0x2c>
  8008aa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  8008ae:	75 f3                	jne    8008a3 <strnlen+0x18>
  8008b0:	eb 05                	jmp    8008b7 <strnlen+0x2c>
  8008b2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  8008b7:	5b                   	pop    %ebx
  8008b8:	5d                   	pop    %ebp
  8008b9:	c3                   	ret    

008008ba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	53                   	push   %ebx
  8008be:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8008c4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8008c9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  8008cd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  8008d0:	83 c2 01             	add    $0x1,%edx
  8008d3:	84 c9                	test   %cl,%cl
  8008d5:	75 f2                	jne    8008c9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  8008d7:	5b                   	pop    %ebx
  8008d8:	5d                   	pop    %ebp
  8008d9:	c3                   	ret    

008008da <strcat>:

char *
strcat(char *dst, const char *src)
{
  8008da:	55                   	push   %ebp
  8008db:	89 e5                	mov    %esp,%ebp
  8008dd:	53                   	push   %ebx
  8008de:	83 ec 08             	sub    $0x8,%esp
  8008e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8008e4:	89 1c 24             	mov    %ebx,(%esp)
  8008e7:	e8 84 ff ff ff       	call   800870 <strlen>
	strcpy(dst + len, src);
  8008ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ef:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008f3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  8008f6:	89 04 24             	mov    %eax,(%esp)
  8008f9:	e8 bc ff ff ff       	call   8008ba <strcpy>
	return dst;
}
  8008fe:	89 d8                	mov    %ebx,%eax
  800900:	83 c4 08             	add    $0x8,%esp
  800903:	5b                   	pop    %ebx
  800904:	5d                   	pop    %ebp
  800905:	c3                   	ret    

00800906 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800906:	55                   	push   %ebp
  800907:	89 e5                	mov    %esp,%ebp
  800909:	56                   	push   %esi
  80090a:	53                   	push   %ebx
  80090b:	8b 45 08             	mov    0x8(%ebp),%eax
  80090e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800911:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800914:	85 f6                	test   %esi,%esi
  800916:	74 18                	je     800930 <strncpy+0x2a>
  800918:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  80091d:	0f b6 1a             	movzbl (%edx),%ebx
  800920:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800923:	80 3a 01             	cmpb   $0x1,(%edx)
  800926:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800929:	83 c1 01             	add    $0x1,%ecx
  80092c:	39 ce                	cmp    %ecx,%esi
  80092e:	77 ed                	ja     80091d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800930:	5b                   	pop    %ebx
  800931:	5e                   	pop    %esi
  800932:	5d                   	pop    %ebp
  800933:	c3                   	ret    

00800934 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	8b 75 08             	mov    0x8(%ebp),%esi
  80093c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800942:	89 f0                	mov    %esi,%eax
  800944:	85 c9                	test   %ecx,%ecx
  800946:	74 27                	je     80096f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800948:	83 e9 01             	sub    $0x1,%ecx
  80094b:	74 1d                	je     80096a <strlcpy+0x36>
  80094d:	0f b6 1a             	movzbl (%edx),%ebx
  800950:	84 db                	test   %bl,%bl
  800952:	74 16                	je     80096a <strlcpy+0x36>
			*dst++ = *src++;
  800954:	88 18                	mov    %bl,(%eax)
  800956:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800959:	83 e9 01             	sub    $0x1,%ecx
  80095c:	74 0e                	je     80096c <strlcpy+0x38>
			*dst++ = *src++;
  80095e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800961:	0f b6 1a             	movzbl (%edx),%ebx
  800964:	84 db                	test   %bl,%bl
  800966:	75 ec                	jne    800954 <strlcpy+0x20>
  800968:	eb 02                	jmp    80096c <strlcpy+0x38>
  80096a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  80096c:	c6 00 00             	movb   $0x0,(%eax)
  80096f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800971:	5b                   	pop    %ebx
  800972:	5e                   	pop    %esi
  800973:	5d                   	pop    %ebp
  800974:	c3                   	ret    

00800975 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80097b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80097e:	0f b6 01             	movzbl (%ecx),%eax
  800981:	84 c0                	test   %al,%al
  800983:	74 15                	je     80099a <strcmp+0x25>
  800985:	3a 02                	cmp    (%edx),%al
  800987:	75 11                	jne    80099a <strcmp+0x25>
		p++, q++;
  800989:	83 c1 01             	add    $0x1,%ecx
  80098c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80098f:	0f b6 01             	movzbl (%ecx),%eax
  800992:	84 c0                	test   %al,%al
  800994:	74 04                	je     80099a <strcmp+0x25>
  800996:	3a 02                	cmp    (%edx),%al
  800998:	74 ef                	je     800989 <strcmp+0x14>
  80099a:	0f b6 c0             	movzbl %al,%eax
  80099d:	0f b6 12             	movzbl (%edx),%edx
  8009a0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009a2:	5d                   	pop    %ebp
  8009a3:	c3                   	ret    

008009a4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009a4:	55                   	push   %ebp
  8009a5:	89 e5                	mov    %esp,%ebp
  8009a7:	53                   	push   %ebx
  8009a8:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009ae:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  8009b1:	85 c0                	test   %eax,%eax
  8009b3:	74 23                	je     8009d8 <strncmp+0x34>
  8009b5:	0f b6 1a             	movzbl (%edx),%ebx
  8009b8:	84 db                	test   %bl,%bl
  8009ba:	74 25                	je     8009e1 <strncmp+0x3d>
  8009bc:	3a 19                	cmp    (%ecx),%bl
  8009be:	75 21                	jne    8009e1 <strncmp+0x3d>
  8009c0:	83 e8 01             	sub    $0x1,%eax
  8009c3:	74 13                	je     8009d8 <strncmp+0x34>
		n--, p++, q++;
  8009c5:	83 c2 01             	add    $0x1,%edx
  8009c8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8009cb:	0f b6 1a             	movzbl (%edx),%ebx
  8009ce:	84 db                	test   %bl,%bl
  8009d0:	74 0f                	je     8009e1 <strncmp+0x3d>
  8009d2:	3a 19                	cmp    (%ecx),%bl
  8009d4:	74 ea                	je     8009c0 <strncmp+0x1c>
  8009d6:	eb 09                	jmp    8009e1 <strncmp+0x3d>
  8009d8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8009dd:	5b                   	pop    %ebx
  8009de:	5d                   	pop    %ebp
  8009df:	90                   	nop
  8009e0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8009e1:	0f b6 02             	movzbl (%edx),%eax
  8009e4:	0f b6 11             	movzbl (%ecx),%edx
  8009e7:	29 d0                	sub    %edx,%eax
  8009e9:	eb f2                	jmp    8009dd <strncmp+0x39>

008009eb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8009f5:	0f b6 10             	movzbl (%eax),%edx
  8009f8:	84 d2                	test   %dl,%dl
  8009fa:	74 18                	je     800a14 <strchr+0x29>
		if (*s == c)
  8009fc:	38 ca                	cmp    %cl,%dl
  8009fe:	75 0a                	jne    800a0a <strchr+0x1f>
  800a00:	eb 17                	jmp    800a19 <strchr+0x2e>
  800a02:	38 ca                	cmp    %cl,%dl
  800a04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a08:	74 0f                	je     800a19 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800a0a:	83 c0 01             	add    $0x1,%eax
  800a0d:	0f b6 10             	movzbl (%eax),%edx
  800a10:	84 d2                	test   %dl,%dl
  800a12:	75 ee                	jne    800a02 <strchr+0x17>
  800a14:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800a19:	5d                   	pop    %ebp
  800a1a:	c3                   	ret    

00800a1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a25:	0f b6 10             	movzbl (%eax),%edx
  800a28:	84 d2                	test   %dl,%dl
  800a2a:	74 18                	je     800a44 <strfind+0x29>
		if (*s == c)
  800a2c:	38 ca                	cmp    %cl,%dl
  800a2e:	75 0a                	jne    800a3a <strfind+0x1f>
  800a30:	eb 12                	jmp    800a44 <strfind+0x29>
  800a32:	38 ca                	cmp    %cl,%dl
  800a34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800a38:	74 0a                	je     800a44 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800a3a:	83 c0 01             	add    $0x1,%eax
  800a3d:	0f b6 10             	movzbl (%eax),%edx
  800a40:	84 d2                	test   %dl,%dl
  800a42:	75 ee                	jne    800a32 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800a44:	5d                   	pop    %ebp
  800a45:	c3                   	ret    

00800a46 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a46:	55                   	push   %ebp
  800a47:	89 e5                	mov    %esp,%ebp
  800a49:	83 ec 0c             	sub    $0xc,%esp
  800a4c:	89 1c 24             	mov    %ebx,(%esp)
  800a4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a53:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800a57:	8b 7d 08             	mov    0x8(%ebp),%edi
  800a5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a5d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800a60:	85 c9                	test   %ecx,%ecx
  800a62:	74 30                	je     800a94 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a64:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800a6a:	75 25                	jne    800a91 <memset+0x4b>
  800a6c:	f6 c1 03             	test   $0x3,%cl
  800a6f:	75 20                	jne    800a91 <memset+0x4b>
		c &= 0xFF;
  800a71:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a74:	89 d3                	mov    %edx,%ebx
  800a76:	c1 e3 08             	shl    $0x8,%ebx
  800a79:	89 d6                	mov    %edx,%esi
  800a7b:	c1 e6 18             	shl    $0x18,%esi
  800a7e:	89 d0                	mov    %edx,%eax
  800a80:	c1 e0 10             	shl    $0x10,%eax
  800a83:	09 f0                	or     %esi,%eax
  800a85:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800a87:	09 d8                	or     %ebx,%eax
  800a89:	c1 e9 02             	shr    $0x2,%ecx
  800a8c:	fc                   	cld    
  800a8d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a8f:	eb 03                	jmp    800a94 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a91:	fc                   	cld    
  800a92:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800a94:	89 f8                	mov    %edi,%eax
  800a96:	8b 1c 24             	mov    (%esp),%ebx
  800a99:	8b 74 24 04          	mov    0x4(%esp),%esi
  800a9d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800aa1:	89 ec                	mov    %ebp,%esp
  800aa3:	5d                   	pop    %ebp
  800aa4:	c3                   	ret    

00800aa5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aa5:	55                   	push   %ebp
  800aa6:	89 e5                	mov    %esp,%ebp
  800aa8:	83 ec 08             	sub    $0x8,%esp
  800aab:	89 34 24             	mov    %esi,(%esp)
  800aae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800ab8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800abb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800abd:	39 c6                	cmp    %eax,%esi
  800abf:	73 35                	jae    800af6 <memmove+0x51>
  800ac1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac4:	39 d0                	cmp    %edx,%eax
  800ac6:	73 2e                	jae    800af6 <memmove+0x51>
		s += n;
		d += n;
  800ac8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800aca:	f6 c2 03             	test   $0x3,%dl
  800acd:	75 1b                	jne    800aea <memmove+0x45>
  800acf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ad5:	75 13                	jne    800aea <memmove+0x45>
  800ad7:	f6 c1 03             	test   $0x3,%cl
  800ada:	75 0e                	jne    800aea <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800adc:	83 ef 04             	sub    $0x4,%edi
  800adf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ae2:	c1 e9 02             	shr    $0x2,%ecx
  800ae5:	fd                   	std    
  800ae6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ae8:	eb 09                	jmp    800af3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800aea:	83 ef 01             	sub    $0x1,%edi
  800aed:	8d 72 ff             	lea    -0x1(%edx),%esi
  800af0:	fd                   	std    
  800af1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800af3:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800af4:	eb 20                	jmp    800b16 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800afc:	75 15                	jne    800b13 <memmove+0x6e>
  800afe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b04:	75 0d                	jne    800b13 <memmove+0x6e>
  800b06:	f6 c1 03             	test   $0x3,%cl
  800b09:	75 08                	jne    800b13 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800b0b:	c1 e9 02             	shr    $0x2,%ecx
  800b0e:	fc                   	cld    
  800b0f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b11:	eb 03                	jmp    800b16 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b13:	fc                   	cld    
  800b14:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b16:	8b 34 24             	mov    (%esp),%esi
  800b19:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800b1d:	89 ec                	mov    %ebp,%esp
  800b1f:	5d                   	pop    %ebp
  800b20:	c3                   	ret    

00800b21 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b21:	55                   	push   %ebp
  800b22:	89 e5                	mov    %esp,%ebp
  800b24:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b27:	8b 45 10             	mov    0x10(%ebp),%eax
  800b2a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b31:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b35:	8b 45 08             	mov    0x8(%ebp),%eax
  800b38:	89 04 24             	mov    %eax,(%esp)
  800b3b:	e8 65 ff ff ff       	call   800aa5 <memmove>
}
  800b40:	c9                   	leave  
  800b41:	c3                   	ret    

00800b42 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b42:	55                   	push   %ebp
  800b43:	89 e5                	mov    %esp,%ebp
  800b45:	57                   	push   %edi
  800b46:	56                   	push   %esi
  800b47:	53                   	push   %ebx
  800b48:	8b 75 08             	mov    0x8(%ebp),%esi
  800b4b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800b4e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b51:	85 c9                	test   %ecx,%ecx
  800b53:	74 36                	je     800b8b <memcmp+0x49>
		if (*s1 != *s2)
  800b55:	0f b6 06             	movzbl (%esi),%eax
  800b58:	0f b6 1f             	movzbl (%edi),%ebx
  800b5b:	38 d8                	cmp    %bl,%al
  800b5d:	74 20                	je     800b7f <memcmp+0x3d>
  800b5f:	eb 14                	jmp    800b75 <memcmp+0x33>
  800b61:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800b66:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800b6b:	83 c2 01             	add    $0x1,%edx
  800b6e:	83 e9 01             	sub    $0x1,%ecx
  800b71:	38 d8                	cmp    %bl,%al
  800b73:	74 12                	je     800b87 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800b75:	0f b6 c0             	movzbl %al,%eax
  800b78:	0f b6 db             	movzbl %bl,%ebx
  800b7b:	29 d8                	sub    %ebx,%eax
  800b7d:	eb 11                	jmp    800b90 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b7f:	83 e9 01             	sub    $0x1,%ecx
  800b82:	ba 00 00 00 00       	mov    $0x0,%edx
  800b87:	85 c9                	test   %ecx,%ecx
  800b89:	75 d6                	jne    800b61 <memcmp+0x1f>
  800b8b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800b90:	5b                   	pop    %ebx
  800b91:	5e                   	pop    %esi
  800b92:	5f                   	pop    %edi
  800b93:	5d                   	pop    %ebp
  800b94:	c3                   	ret    

00800b95 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b95:	55                   	push   %ebp
  800b96:	89 e5                	mov    %esp,%ebp
  800b98:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800b9b:	89 c2                	mov    %eax,%edx
  800b9d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ba0:	39 d0                	cmp    %edx,%eax
  800ba2:	73 15                	jae    800bb9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ba4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ba8:	38 08                	cmp    %cl,(%eax)
  800baa:	75 06                	jne    800bb2 <memfind+0x1d>
  800bac:	eb 0b                	jmp    800bb9 <memfind+0x24>
  800bae:	38 08                	cmp    %cl,(%eax)
  800bb0:	74 07                	je     800bb9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bb2:	83 c0 01             	add    $0x1,%eax
  800bb5:	39 c2                	cmp    %eax,%edx
  800bb7:	77 f5                	ja     800bae <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	57                   	push   %edi
  800bbf:	56                   	push   %esi
  800bc0:	53                   	push   %ebx
  800bc1:	83 ec 04             	sub    $0x4,%esp
  800bc4:	8b 55 08             	mov    0x8(%ebp),%edx
  800bc7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bca:	0f b6 02             	movzbl (%edx),%eax
  800bcd:	3c 20                	cmp    $0x20,%al
  800bcf:	74 04                	je     800bd5 <strtol+0x1a>
  800bd1:	3c 09                	cmp    $0x9,%al
  800bd3:	75 0e                	jne    800be3 <strtol+0x28>
		s++;
  800bd5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800bd8:	0f b6 02             	movzbl (%edx),%eax
  800bdb:	3c 20                	cmp    $0x20,%al
  800bdd:	74 f6                	je     800bd5 <strtol+0x1a>
  800bdf:	3c 09                	cmp    $0x9,%al
  800be1:	74 f2                	je     800bd5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800be3:	3c 2b                	cmp    $0x2b,%al
  800be5:	75 0c                	jne    800bf3 <strtol+0x38>
		s++;
  800be7:	83 c2 01             	add    $0x1,%edx
  800bea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bf1:	eb 15                	jmp    800c08 <strtol+0x4d>
	else if (*s == '-')
  800bf3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800bfa:	3c 2d                	cmp    $0x2d,%al
  800bfc:	75 0a                	jne    800c08 <strtol+0x4d>
		s++, neg = 1;
  800bfe:	83 c2 01             	add    $0x1,%edx
  800c01:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c08:	85 db                	test   %ebx,%ebx
  800c0a:	0f 94 c0             	sete   %al
  800c0d:	74 05                	je     800c14 <strtol+0x59>
  800c0f:	83 fb 10             	cmp    $0x10,%ebx
  800c12:	75 18                	jne    800c2c <strtol+0x71>
  800c14:	80 3a 30             	cmpb   $0x30,(%edx)
  800c17:	75 13                	jne    800c2c <strtol+0x71>
  800c19:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800c1d:	8d 76 00             	lea    0x0(%esi),%esi
  800c20:	75 0a                	jne    800c2c <strtol+0x71>
		s += 2, base = 16;
  800c22:	83 c2 02             	add    $0x2,%edx
  800c25:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c2a:	eb 15                	jmp    800c41 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c2c:	84 c0                	test   %al,%al
  800c2e:	66 90                	xchg   %ax,%ax
  800c30:	74 0f                	je     800c41 <strtol+0x86>
  800c32:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800c37:	80 3a 30             	cmpb   $0x30,(%edx)
  800c3a:	75 05                	jne    800c41 <strtol+0x86>
		s++, base = 8;
  800c3c:	83 c2 01             	add    $0x1,%edx
  800c3f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c41:	b8 00 00 00 00       	mov    $0x0,%eax
  800c46:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c48:	0f b6 0a             	movzbl (%edx),%ecx
  800c4b:	89 cf                	mov    %ecx,%edi
  800c4d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800c50:	80 fb 09             	cmp    $0x9,%bl
  800c53:	77 08                	ja     800c5d <strtol+0xa2>
			dig = *s - '0';
  800c55:	0f be c9             	movsbl %cl,%ecx
  800c58:	83 e9 30             	sub    $0x30,%ecx
  800c5b:	eb 1e                	jmp    800c7b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800c5d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800c60:	80 fb 19             	cmp    $0x19,%bl
  800c63:	77 08                	ja     800c6d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800c65:	0f be c9             	movsbl %cl,%ecx
  800c68:	83 e9 57             	sub    $0x57,%ecx
  800c6b:	eb 0e                	jmp    800c7b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800c6d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800c70:	80 fb 19             	cmp    $0x19,%bl
  800c73:	77 15                	ja     800c8a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800c75:	0f be c9             	movsbl %cl,%ecx
  800c78:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800c7b:	39 f1                	cmp    %esi,%ecx
  800c7d:	7d 0b                	jge    800c8a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800c7f:	83 c2 01             	add    $0x1,%edx
  800c82:	0f af c6             	imul   %esi,%eax
  800c85:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800c88:	eb be                	jmp    800c48 <strtol+0x8d>
  800c8a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800c8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c90:	74 05                	je     800c97 <strtol+0xdc>
		*endptr = (char *) s;
  800c92:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c95:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800c97:	89 ca                	mov    %ecx,%edx
  800c99:	f7 da                	neg    %edx
  800c9b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800c9f:	0f 45 c2             	cmovne %edx,%eax
}
  800ca2:	83 c4 04             	add    $0x4,%esp
  800ca5:	5b                   	pop    %ebx
  800ca6:	5e                   	pop    %esi
  800ca7:	5f                   	pop    %edi
  800ca8:	5d                   	pop    %ebp
  800ca9:	c3                   	ret    

00800caa <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800caa:	55                   	push   %ebp
  800cab:	89 e5                	mov    %esp,%ebp
  800cad:	83 ec 0c             	sub    $0xc,%esp
  800cb0:	89 1c 24             	mov    %ebx,(%esp)
  800cb3:	89 74 24 04          	mov    %esi,0x4(%esp)
  800cb7:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cbb:	ba 00 00 00 00       	mov    $0x0,%edx
  800cc0:	b8 01 00 00 00       	mov    $0x1,%eax
  800cc5:	89 d1                	mov    %edx,%ecx
  800cc7:	89 d3                	mov    %edx,%ebx
  800cc9:	89 d7                	mov    %edx,%edi
  800ccb:	89 d6                	mov    %edx,%esi
  800ccd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800ccf:	8b 1c 24             	mov    (%esp),%ebx
  800cd2:	8b 74 24 04          	mov    0x4(%esp),%esi
  800cd6:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800cda:	89 ec                	mov    %ebp,%esp
  800cdc:	5d                   	pop    %ebp
  800cdd:	c3                   	ret    

00800cde <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800cde:	55                   	push   %ebp
  800cdf:	89 e5                	mov    %esp,%ebp
  800ce1:	83 ec 0c             	sub    $0xc,%esp
  800ce4:	89 1c 24             	mov    %ebx,(%esp)
  800ce7:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ceb:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800cef:	b8 00 00 00 00       	mov    $0x0,%eax
  800cf4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cf7:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfa:	89 c3                	mov    %eax,%ebx
  800cfc:	89 c7                	mov    %eax,%edi
  800cfe:	89 c6                	mov    %eax,%esi
  800d00:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800d02:	8b 1c 24             	mov    (%esp),%ebx
  800d05:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d09:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800d0d:	89 ec                	mov    %ebp,%esp
  800d0f:	5d                   	pop    %ebp
  800d10:	c3                   	ret    

00800d11 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800d11:	55                   	push   %ebp
  800d12:	89 e5                	mov    %esp,%ebp
  800d14:	83 ec 38             	sub    $0x38,%esp
  800d17:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800d1a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800d1d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d20:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d25:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d2a:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2d:	89 cb                	mov    %ecx,%ebx
  800d2f:	89 cf                	mov    %ecx,%edi
  800d31:	89 ce                	mov    %ecx,%esi
  800d33:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800d35:	85 c0                	test   %eax,%eax
  800d37:	7e 28                	jle    800d61 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800d39:	89 44 24 10          	mov    %eax,0x10(%esp)
  800d3d:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800d44:	00 
  800d45:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800d4c:	00 
  800d4d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800d54:	00 
  800d55:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800d5c:	e8 ad 03 00 00       	call   80110e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800d61:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800d64:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800d67:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800d6a:	89 ec                	mov    %ebp,%esp
  800d6c:	5d                   	pop    %ebp
  800d6d:	c3                   	ret    

00800d6e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d6e:	55                   	push   %ebp
  800d6f:	89 e5                	mov    %esp,%ebp
  800d71:	83 ec 0c             	sub    $0xc,%esp
  800d74:	89 1c 24             	mov    %ebx,(%esp)
  800d77:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d7b:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d7f:	be 00 00 00 00       	mov    $0x0,%esi
  800d84:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d89:	8b 7d 14             	mov    0x14(%ebp),%edi
  800d8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800d8f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d92:	8b 55 08             	mov    0x8(%ebp),%edx
  800d95:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800d97:	8b 1c 24             	mov    (%esp),%ebx
  800d9a:	8b 74 24 04          	mov    0x4(%esp),%esi
  800d9e:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800da2:	89 ec                	mov    %ebp,%esp
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	83 ec 38             	sub    $0x38,%esp
  800dac:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800daf:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800db2:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db5:	bb 00 00 00 00       	mov    $0x0,%ebx
  800dba:	b8 09 00 00 00       	mov    $0x9,%eax
  800dbf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dc2:	8b 55 08             	mov    0x8(%ebp),%edx
  800dc5:	89 df                	mov    %ebx,%edi
  800dc7:	89 de                	mov    %ebx,%esi
  800dc9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800dcb:	85 c0                	test   %eax,%eax
  800dcd:	7e 28                	jle    800df7 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800dcf:	89 44 24 10          	mov    %eax,0x10(%esp)
  800dd3:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800dda:	00 
  800ddb:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800de2:	00 
  800de3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800dea:	00 
  800deb:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800df2:	e8 17 03 00 00       	call   80110e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800df7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800dfa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800dfd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e00:	89 ec                	mov    %ebp,%esp
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    

00800e04 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e04:	55                   	push   %ebp
  800e05:	89 e5                	mov    %esp,%ebp
  800e07:	83 ec 38             	sub    $0x38,%esp
  800e0a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e0d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e10:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e13:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e18:	b8 08 00 00 00       	mov    $0x8,%eax
  800e1d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e20:	8b 55 08             	mov    0x8(%ebp),%edx
  800e23:	89 df                	mov    %ebx,%edi
  800e25:	89 de                	mov    %ebx,%esi
  800e27:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e29:	85 c0                	test   %eax,%eax
  800e2b:	7e 28                	jle    800e55 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e2d:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e31:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800e38:	00 
  800e39:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800e40:	00 
  800e41:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800e48:	00 
  800e49:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800e50:	e8 b9 02 00 00       	call   80110e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800e55:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800e58:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800e5b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800e5e:	89 ec                	mov    %ebp,%esp
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    

00800e62 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800e62:	55                   	push   %ebp
  800e63:	89 e5                	mov    %esp,%ebp
  800e65:	83 ec 38             	sub    $0x38,%esp
  800e68:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800e6b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800e6e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e71:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e76:	b8 06 00 00 00       	mov    $0x6,%eax
  800e7b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e7e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e81:	89 df                	mov    %ebx,%edi
  800e83:	89 de                	mov    %ebx,%esi
  800e85:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800e87:	85 c0                	test   %eax,%eax
  800e89:	7e 28                	jle    800eb3 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800e8b:	89 44 24 10          	mov    %eax,0x10(%esp)
  800e8f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800e96:	00 
  800e97:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800e9e:	00 
  800e9f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ea6:	00 
  800ea7:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800eae:	e8 5b 02 00 00       	call   80110e <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800eb3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800eb6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800eb9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ebc:	89 ec                	mov    %ebp,%esp
  800ebe:	5d                   	pop    %ebp
  800ebf:	c3                   	ret    

00800ec0 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ec0:	55                   	push   %ebp
  800ec1:	89 e5                	mov    %esp,%ebp
  800ec3:	83 ec 38             	sub    $0x38,%esp
  800ec6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800ec9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ecc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ecf:	b8 05 00 00 00       	mov    $0x5,%eax
  800ed4:	8b 75 18             	mov    0x18(%ebp),%esi
  800ed7:	8b 7d 14             	mov    0x14(%ebp),%edi
  800eda:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800edd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee0:	8b 55 08             	mov    0x8(%ebp),%edx
  800ee3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	7e 28                	jle    800f11 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ee9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800eed:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800ef4:	00 
  800ef5:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800efc:	00 
  800efd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f04:	00 
  800f05:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800f0c:	e8 fd 01 00 00       	call   80110e <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800f11:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f14:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f17:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f1a:	89 ec                	mov    %ebp,%esp
  800f1c:	5d                   	pop    %ebp
  800f1d:	c3                   	ret    

00800f1e <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f1e:	55                   	push   %ebp
  800f1f:	89 e5                	mov    %esp,%ebp
  800f21:	83 ec 38             	sub    $0x38,%esp
  800f24:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f27:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f2a:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f2d:	be 00 00 00 00       	mov    $0x0,%esi
  800f32:	b8 04 00 00 00       	mov    $0x4,%eax
  800f37:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f3d:	8b 55 08             	mov    0x8(%ebp),%edx
  800f40:	89 f7                	mov    %esi,%edi
  800f42:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f44:	85 c0                	test   %eax,%eax
  800f46:	7e 28                	jle    800f70 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f48:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f4c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800f53:	00 
  800f54:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  800f5b:	00 
  800f5c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f63:	00 
  800f64:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  800f6b:	e8 9e 01 00 00       	call   80110e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800f70:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f73:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f76:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f79:	89 ec                	mov    %ebp,%esp
  800f7b:	5d                   	pop    %ebp
  800f7c:	c3                   	ret    

00800f7d <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	83 ec 0c             	sub    $0xc,%esp
  800f83:	89 1c 24             	mov    %ebx,(%esp)
  800f86:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f8a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f8e:	ba 00 00 00 00       	mov    $0x0,%edx
  800f93:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f98:	89 d1                	mov    %edx,%ecx
  800f9a:	89 d3                	mov    %edx,%ebx
  800f9c:	89 d7                	mov    %edx,%edi
  800f9e:	89 d6                	mov    %edx,%esi
  800fa0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800fa2:	8b 1c 24             	mov    (%esp),%ebx
  800fa5:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fa9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fad:	89 ec                	mov    %ebp,%esp
  800faf:	5d                   	pop    %ebp
  800fb0:	c3                   	ret    

00800fb1 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	83 ec 0c             	sub    $0xc,%esp
  800fb7:	89 1c 24             	mov    %ebx,(%esp)
  800fba:	89 74 24 04          	mov    %esi,0x4(%esp)
  800fbe:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fc2:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc7:	b8 02 00 00 00       	mov    $0x2,%eax
  800fcc:	89 d1                	mov    %edx,%ecx
  800fce:	89 d3                	mov    %edx,%ebx
  800fd0:	89 d7                	mov    %edx,%edi
  800fd2:	89 d6                	mov    %edx,%esi
  800fd4:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800fd6:	8b 1c 24             	mov    (%esp),%ebx
  800fd9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800fdd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fe1:	89 ec                	mov    %ebp,%esp
  800fe3:	5d                   	pop    %ebp
  800fe4:	c3                   	ret    

00800fe5 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800fe5:	55                   	push   %ebp
  800fe6:	89 e5                	mov    %esp,%ebp
  800fe8:	83 ec 38             	sub    $0x38,%esp
  800feb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fee:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ff1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ff4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ff9:	b8 03 00 00 00       	mov    $0x3,%eax
  800ffe:	8b 55 08             	mov    0x8(%ebp),%edx
  801001:	89 cb                	mov    %ecx,%ebx
  801003:	89 cf                	mov    %ecx,%edi
  801005:	89 ce                	mov    %ecx,%esi
  801007:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801009:	85 c0                	test   %eax,%eax
  80100b:	7e 28                	jle    801035 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80100d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801011:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801018:	00 
  801019:	c7 44 24 08 64 16 80 	movl   $0x801664,0x8(%esp)
  801020:	00 
  801021:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801028:	00 
  801029:	c7 04 24 81 16 80 00 	movl   $0x801681,(%esp)
  801030:	e8 d9 00 00 00       	call   80110e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801035:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801038:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80103b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80103e:	89 ec                	mov    %ebp,%esp
  801040:	5d                   	pop    %ebp
  801041:	c3                   	ret    

00801042 <sfork>:
}

// Challenge!
int
sfork(void)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	83 ec 18             	sub    $0x18,%esp
	panic("sfork not implemented");
  801048:	c7 44 24 08 8f 16 80 	movl   $0x80168f,0x8(%esp)
  80104f:	00 
  801050:	c7 44 24 04 59 00 00 	movl   $0x59,0x4(%esp)
  801057:	00 
  801058:	c7 04 24 a5 16 80 00 	movl   $0x8016a5,(%esp)
  80105f:	e8 aa 00 00 00       	call   80110e <_panic>

00801064 <fork>:
//   Neither user exception stack should ever be marked copy-on-write,
//   so you must allocate a new page for the child's user exception stack.
//
envid_t
fork(void)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("fork not implemented");
  80106a:	c7 44 24 08 90 16 80 	movl   $0x801690,0x8(%esp)
  801071:	00 
  801072:	c7 44 24 04 52 00 00 	movl   $0x52,0x4(%esp)
  801079:	00 
  80107a:	c7 04 24 a5 16 80 00 	movl   $0x8016a5,(%esp)
  801081:	e8 88 00 00 00       	call   80110e <_panic>

00801086 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801086:	55                   	push   %ebp
  801087:	89 e5                	mov    %esp,%ebp
  801089:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
		if (envs[i].env_type == type)
  80108c:	8b 15 50 00 c0 ee    	mov    0xeec00050,%edx
  801092:	b8 01 00 00 00       	mov    $0x1,%eax
  801097:	39 ca                	cmp    %ecx,%edx
  801099:	75 04                	jne    80109f <ipc_find_env+0x19>
  80109b:	b0 00                	mov    $0x0,%al
  80109d:	eb 0f                	jmp    8010ae <ipc_find_env+0x28>
  80109f:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8010a2:	81 c2 50 00 c0 ee    	add    $0xeec00050,%edx
  8010a8:	8b 12                	mov    (%edx),%edx
  8010aa:	39 ca                	cmp    %ecx,%edx
  8010ac:	75 0c                	jne    8010ba <ipc_find_env+0x34>
			return envs[i].env_id;
  8010ae:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010b1:	05 48 00 c0 ee       	add    $0xeec00048,%eax
  8010b6:	8b 00                	mov    (%eax),%eax
  8010b8:	eb 0e                	jmp    8010c8 <ipc_find_env+0x42>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  8010ba:	83 c0 01             	add    $0x1,%eax
  8010bd:	3d 00 04 00 00       	cmp    $0x400,%eax
  8010c2:	75 db                	jne    80109f <ipc_find_env+0x19>
  8010c4:	66 b8 00 00          	mov    $0x0,%ax
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
}
  8010c8:	5d                   	pop    %ebp
  8010c9:	c3                   	ret    

008010ca <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_send not implemented");
  8010d0:	c7 44 24 08 b0 16 80 	movl   $0x8016b0,0x8(%esp)
  8010d7:	00 
  8010d8:	c7 44 24 04 2a 00 00 	movl   $0x2a,0x4(%esp)
  8010df:	00 
  8010e0:	c7 04 24 c9 16 80 00 	movl   $0x8016c9,(%esp)
  8010e7:	e8 22 00 00 00       	call   80110e <_panic>

008010ec <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8010ec:	55                   	push   %ebp
  8010ed:	89 e5                	mov    %esp,%ebp
  8010ef:	83 ec 18             	sub    $0x18,%esp
	// LAB 4: Your code here.
	panic("ipc_recv not implemented");
  8010f2:	c7 44 24 08 d3 16 80 	movl   $0x8016d3,0x8(%esp)
  8010f9:	00 
  8010fa:	c7 44 24 04 1a 00 00 	movl   $0x1a,0x4(%esp)
  801101:	00 
  801102:	c7 04 24 c9 16 80 00 	movl   $0x8016c9,(%esp)
  801109:	e8 00 00 00 00       	call   80110e <_panic>

0080110e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80110e:	55                   	push   %ebp
  80110f:	89 e5                	mov    %esp,%ebp
  801111:	56                   	push   %esi
  801112:	53                   	push   %ebx
  801113:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  801116:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801119:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80111f:	e8 8d fe ff ff       	call   800fb1 <sys_getenvid>
  801124:	8b 55 0c             	mov    0xc(%ebp),%edx
  801127:	89 54 24 10          	mov    %edx,0x10(%esp)
  80112b:	8b 55 08             	mov    0x8(%ebp),%edx
  80112e:	89 54 24 0c          	mov    %edx,0xc(%esp)
  801132:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801136:	89 44 24 04          	mov    %eax,0x4(%esp)
  80113a:	c7 04 24 ec 16 80 00 	movl   $0x8016ec,(%esp)
  801141:	e8 7f f0 ff ff       	call   8001c5 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801146:	89 74 24 04          	mov    %esi,0x4(%esp)
  80114a:	8b 45 10             	mov    0x10(%ebp),%eax
  80114d:	89 04 24             	mov    %eax,(%esp)
  801150:	e8 0f f0 ff ff       	call   800164 <vcprintf>
	cprintf("\n");
  801155:	c7 04 24 07 14 80 00 	movl   $0x801407,(%esp)
  80115c:	e8 64 f0 ff ff       	call   8001c5 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801161:	cc                   	int3   
  801162:	eb fd                	jmp    801161 <_panic+0x53>
  801164:	66 90                	xchg   %ax,%ax
  801166:	66 90                	xchg   %ax,%ax
  801168:	66 90                	xchg   %ax,%ax
  80116a:	66 90                	xchg   %ax,%ax
  80116c:	66 90                	xchg   %ax,%ax
  80116e:	66 90                	xchg   %ax,%ax

00801170 <__udivdi3>:
  801170:	55                   	push   %ebp
  801171:	89 e5                	mov    %esp,%ebp
  801173:	57                   	push   %edi
  801174:	56                   	push   %esi
  801175:	83 ec 10             	sub    $0x10,%esp
  801178:	8b 45 14             	mov    0x14(%ebp),%eax
  80117b:	8b 55 08             	mov    0x8(%ebp),%edx
  80117e:	8b 75 10             	mov    0x10(%ebp),%esi
  801181:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801184:	85 c0                	test   %eax,%eax
  801186:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801189:	75 35                	jne    8011c0 <__udivdi3+0x50>
  80118b:	39 fe                	cmp    %edi,%esi
  80118d:	77 61                	ja     8011f0 <__udivdi3+0x80>
  80118f:	85 f6                	test   %esi,%esi
  801191:	75 0b                	jne    80119e <__udivdi3+0x2e>
  801193:	b8 01 00 00 00       	mov    $0x1,%eax
  801198:	31 d2                	xor    %edx,%edx
  80119a:	f7 f6                	div    %esi
  80119c:	89 c6                	mov    %eax,%esi
  80119e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8011a1:	31 d2                	xor    %edx,%edx
  8011a3:	89 f8                	mov    %edi,%eax
  8011a5:	f7 f6                	div    %esi
  8011a7:	89 c7                	mov    %eax,%edi
  8011a9:	89 c8                	mov    %ecx,%eax
  8011ab:	f7 f6                	div    %esi
  8011ad:	89 c1                	mov    %eax,%ecx
  8011af:	89 fa                	mov    %edi,%edx
  8011b1:	89 c8                	mov    %ecx,%eax
  8011b3:	83 c4 10             	add    $0x10,%esp
  8011b6:	5e                   	pop    %esi
  8011b7:	5f                   	pop    %edi
  8011b8:	5d                   	pop    %ebp
  8011b9:	c3                   	ret    
  8011ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8011c0:	39 f8                	cmp    %edi,%eax
  8011c2:	77 1c                	ja     8011e0 <__udivdi3+0x70>
  8011c4:	0f bd d0             	bsr    %eax,%edx
  8011c7:	83 f2 1f             	xor    $0x1f,%edx
  8011ca:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011cd:	75 39                	jne    801208 <__udivdi3+0x98>
  8011cf:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8011d2:	0f 86 a0 00 00 00    	jbe    801278 <__udivdi3+0x108>
  8011d8:	39 f8                	cmp    %edi,%eax
  8011da:	0f 82 98 00 00 00    	jb     801278 <__udivdi3+0x108>
  8011e0:	31 ff                	xor    %edi,%edi
  8011e2:	31 c9                	xor    %ecx,%ecx
  8011e4:	89 c8                	mov    %ecx,%eax
  8011e6:	89 fa                	mov    %edi,%edx
  8011e8:	83 c4 10             	add    $0x10,%esp
  8011eb:	5e                   	pop    %esi
  8011ec:	5f                   	pop    %edi
  8011ed:	5d                   	pop    %ebp
  8011ee:	c3                   	ret    
  8011ef:	90                   	nop
  8011f0:	89 d1                	mov    %edx,%ecx
  8011f2:	89 fa                	mov    %edi,%edx
  8011f4:	89 c8                	mov    %ecx,%eax
  8011f6:	31 ff                	xor    %edi,%edi
  8011f8:	f7 f6                	div    %esi
  8011fa:	89 c1                	mov    %eax,%ecx
  8011fc:	89 fa                	mov    %edi,%edx
  8011fe:	89 c8                	mov    %ecx,%eax
  801200:	83 c4 10             	add    $0x10,%esp
  801203:	5e                   	pop    %esi
  801204:	5f                   	pop    %edi
  801205:	5d                   	pop    %ebp
  801206:	c3                   	ret    
  801207:	90                   	nop
  801208:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80120c:	89 f2                	mov    %esi,%edx
  80120e:	d3 e0                	shl    %cl,%eax
  801210:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801213:	b8 20 00 00 00       	mov    $0x20,%eax
  801218:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80121b:	89 c1                	mov    %eax,%ecx
  80121d:	d3 ea                	shr    %cl,%edx
  80121f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801223:	0b 55 ec             	or     -0x14(%ebp),%edx
  801226:	d3 e6                	shl    %cl,%esi
  801228:	89 c1                	mov    %eax,%ecx
  80122a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80122d:	89 fe                	mov    %edi,%esi
  80122f:	d3 ee                	shr    %cl,%esi
  801231:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801235:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801238:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80123b:	d3 e7                	shl    %cl,%edi
  80123d:	89 c1                	mov    %eax,%ecx
  80123f:	d3 ea                	shr    %cl,%edx
  801241:	09 d7                	or     %edx,%edi
  801243:	89 f2                	mov    %esi,%edx
  801245:	89 f8                	mov    %edi,%eax
  801247:	f7 75 ec             	divl   -0x14(%ebp)
  80124a:	89 d6                	mov    %edx,%esi
  80124c:	89 c7                	mov    %eax,%edi
  80124e:	f7 65 e8             	mull   -0x18(%ebp)
  801251:	39 d6                	cmp    %edx,%esi
  801253:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801256:	72 30                	jb     801288 <__udivdi3+0x118>
  801258:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80125b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80125f:	d3 e2                	shl    %cl,%edx
  801261:	39 c2                	cmp    %eax,%edx
  801263:	73 05                	jae    80126a <__udivdi3+0xfa>
  801265:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801268:	74 1e                	je     801288 <__udivdi3+0x118>
  80126a:	89 f9                	mov    %edi,%ecx
  80126c:	31 ff                	xor    %edi,%edi
  80126e:	e9 71 ff ff ff       	jmp    8011e4 <__udivdi3+0x74>
  801273:	90                   	nop
  801274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801278:	31 ff                	xor    %edi,%edi
  80127a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80127f:	e9 60 ff ff ff       	jmp    8011e4 <__udivdi3+0x74>
  801284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801288:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80128b:	31 ff                	xor    %edi,%edi
  80128d:	89 c8                	mov    %ecx,%eax
  80128f:	89 fa                	mov    %edi,%edx
  801291:	83 c4 10             	add    $0x10,%esp
  801294:	5e                   	pop    %esi
  801295:	5f                   	pop    %edi
  801296:	5d                   	pop    %ebp
  801297:	c3                   	ret    
  801298:	66 90                	xchg   %ax,%ax
  80129a:	66 90                	xchg   %ax,%ax
  80129c:	66 90                	xchg   %ax,%ax
  80129e:	66 90                	xchg   %ax,%ax

008012a0 <__umoddi3>:
  8012a0:	55                   	push   %ebp
  8012a1:	89 e5                	mov    %esp,%ebp
  8012a3:	57                   	push   %edi
  8012a4:	56                   	push   %esi
  8012a5:	83 ec 20             	sub    $0x20,%esp
  8012a8:	8b 55 14             	mov    0x14(%ebp),%edx
  8012ab:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ae:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012b1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012b4:	85 d2                	test   %edx,%edx
  8012b6:	89 c8                	mov    %ecx,%eax
  8012b8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8012bb:	75 13                	jne    8012d0 <__umoddi3+0x30>
  8012bd:	39 f7                	cmp    %esi,%edi
  8012bf:	76 3f                	jbe    801300 <__umoddi3+0x60>
  8012c1:	89 f2                	mov    %esi,%edx
  8012c3:	f7 f7                	div    %edi
  8012c5:	89 d0                	mov    %edx,%eax
  8012c7:	31 d2                	xor    %edx,%edx
  8012c9:	83 c4 20             	add    $0x20,%esp
  8012cc:	5e                   	pop    %esi
  8012cd:	5f                   	pop    %edi
  8012ce:	5d                   	pop    %ebp
  8012cf:	c3                   	ret    
  8012d0:	39 f2                	cmp    %esi,%edx
  8012d2:	77 4c                	ja     801320 <__umoddi3+0x80>
  8012d4:	0f bd ca             	bsr    %edx,%ecx
  8012d7:	83 f1 1f             	xor    $0x1f,%ecx
  8012da:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8012dd:	75 51                	jne    801330 <__umoddi3+0x90>
  8012df:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8012e2:	0f 87 e0 00 00 00    	ja     8013c8 <__umoddi3+0x128>
  8012e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012eb:	29 f8                	sub    %edi,%eax
  8012ed:	19 d6                	sbb    %edx,%esi
  8012ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8012f2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8012f5:	89 f2                	mov    %esi,%edx
  8012f7:	83 c4 20             	add    $0x20,%esp
  8012fa:	5e                   	pop    %esi
  8012fb:	5f                   	pop    %edi
  8012fc:	5d                   	pop    %ebp
  8012fd:	c3                   	ret    
  8012fe:	66 90                	xchg   %ax,%ax
  801300:	85 ff                	test   %edi,%edi
  801302:	75 0b                	jne    80130f <__umoddi3+0x6f>
  801304:	b8 01 00 00 00       	mov    $0x1,%eax
  801309:	31 d2                	xor    %edx,%edx
  80130b:	f7 f7                	div    %edi
  80130d:	89 c7                	mov    %eax,%edi
  80130f:	89 f0                	mov    %esi,%eax
  801311:	31 d2                	xor    %edx,%edx
  801313:	f7 f7                	div    %edi
  801315:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801318:	f7 f7                	div    %edi
  80131a:	eb a9                	jmp    8012c5 <__umoddi3+0x25>
  80131c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801320:	89 c8                	mov    %ecx,%eax
  801322:	89 f2                	mov    %esi,%edx
  801324:	83 c4 20             	add    $0x20,%esp
  801327:	5e                   	pop    %esi
  801328:	5f                   	pop    %edi
  801329:	5d                   	pop    %ebp
  80132a:	c3                   	ret    
  80132b:	90                   	nop
  80132c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801330:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801334:	d3 e2                	shl    %cl,%edx
  801336:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801339:	ba 20 00 00 00       	mov    $0x20,%edx
  80133e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801341:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801344:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801348:	89 fa                	mov    %edi,%edx
  80134a:	d3 ea                	shr    %cl,%edx
  80134c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801350:	0b 55 f4             	or     -0xc(%ebp),%edx
  801353:	d3 e7                	shl    %cl,%edi
  801355:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801359:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80135c:	89 f2                	mov    %esi,%edx
  80135e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801361:	89 c7                	mov    %eax,%edi
  801363:	d3 ea                	shr    %cl,%edx
  801365:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801369:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80136c:	89 c2                	mov    %eax,%edx
  80136e:	d3 e6                	shl    %cl,%esi
  801370:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801374:	d3 ea                	shr    %cl,%edx
  801376:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80137a:	09 d6                	or     %edx,%esi
  80137c:	89 f0                	mov    %esi,%eax
  80137e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801381:	d3 e7                	shl    %cl,%edi
  801383:	89 f2                	mov    %esi,%edx
  801385:	f7 75 f4             	divl   -0xc(%ebp)
  801388:	89 d6                	mov    %edx,%esi
  80138a:	f7 65 e8             	mull   -0x18(%ebp)
  80138d:	39 d6                	cmp    %edx,%esi
  80138f:	72 2b                	jb     8013bc <__umoddi3+0x11c>
  801391:	39 c7                	cmp    %eax,%edi
  801393:	72 23                	jb     8013b8 <__umoddi3+0x118>
  801395:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801399:	29 c7                	sub    %eax,%edi
  80139b:	19 d6                	sbb    %edx,%esi
  80139d:	89 f0                	mov    %esi,%eax
  80139f:	89 f2                	mov    %esi,%edx
  8013a1:	d3 ef                	shr    %cl,%edi
  8013a3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8013a7:	d3 e0                	shl    %cl,%eax
  8013a9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013ad:	09 f8                	or     %edi,%eax
  8013af:	d3 ea                	shr    %cl,%edx
  8013b1:	83 c4 20             	add    $0x20,%esp
  8013b4:	5e                   	pop    %esi
  8013b5:	5f                   	pop    %edi
  8013b6:	5d                   	pop    %ebp
  8013b7:	c3                   	ret    
  8013b8:	39 d6                	cmp    %edx,%esi
  8013ba:	75 d9                	jne    801395 <__umoddi3+0xf5>
  8013bc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8013bf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8013c2:	eb d1                	jmp    801395 <__umoddi3+0xf5>
  8013c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013c8:	39 f2                	cmp    %esi,%edx
  8013ca:	0f 82 18 ff ff ff    	jb     8012e8 <__umoddi3+0x48>
  8013d0:	e9 1d ff ff ff       	jmp    8012f2 <__umoddi3+0x52>
