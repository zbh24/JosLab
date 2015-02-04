
obj/user/dumbfork：     文件格式 elf32-i386


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
  80002c:	e8 19 02 00 00       	call   80024a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <duppage>:
	}
}

void
duppage(envid_t dstenv, void *addr)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	56                   	push   %esi
  800037:	53                   	push   %ebx
  800038:	83 ec 20             	sub    $0x20,%esp
  80003b:	8b 75 08             	mov    0x8(%ebp),%esi
  80003e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	// This is NOT what you should do in your fork.
	if ((r = sys_page_alloc(dstenv, addr, PTE_P|PTE_U|PTE_W)) < 0)
  800041:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800048:	00 
  800049:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80004d:	89 34 24             	mov    %esi,(%esp)
  800050:	e8 69 10 00 00       	call   8010be <sys_page_alloc>
  800055:	85 c0                	test   %eax,%eax
  800057:	79 20                	jns    800079 <duppage+0x46>
		panic("sys_page_alloc: %e", r);
  800059:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80005d:	c7 44 24 08 60 14 80 	movl   $0x801460,0x8(%esp)
  800064:	00 
  800065:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  80006c:	00 
  80006d:	c7 04 24 73 14 80 00 	movl   $0x801473,(%esp)
  800074:	e8 3e 02 00 00       	call   8002b7 <_panic>
	if ((r = sys_page_map(dstenv, addr, 0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
  800079:	c7 44 24 10 07 00 00 	movl   $0x7,0x10(%esp)
  800080:	00 
  800081:	c7 44 24 0c 00 00 40 	movl   $0x400000,0xc(%esp)
  800088:	00 
  800089:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800090:	00 
  800091:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800095:	89 34 24             	mov    %esi,(%esp)
  800098:	e8 c3 0f 00 00       	call   801060 <sys_page_map>
  80009d:	85 c0                	test   %eax,%eax
  80009f:	79 20                	jns    8000c1 <duppage+0x8e>
		panic("sys_page_map: %e", r);
  8000a1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000a5:	c7 44 24 08 83 14 80 	movl   $0x801483,0x8(%esp)
  8000ac:	00 
  8000ad:	c7 44 24 04 22 00 00 	movl   $0x22,0x4(%esp)
  8000b4:	00 
  8000b5:	c7 04 24 73 14 80 00 	movl   $0x801473,(%esp)
  8000bc:	e8 f6 01 00 00       	call   8002b7 <_panic>
	memmove(UTEMP, addr, PGSIZE);
  8000c1:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
  8000c8:	00 
  8000c9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000cd:	c7 04 24 00 00 40 00 	movl   $0x400000,(%esp)
  8000d4:	e8 6c 0b 00 00       	call   800c45 <memmove>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8000d9:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  8000e0:	00 
  8000e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000e8:	e8 15 0f 00 00       	call   801002 <sys_page_unmap>
  8000ed:	85 c0                	test   %eax,%eax
  8000ef:	79 20                	jns    800111 <duppage+0xde>
		panic("sys_page_unmap: %e", r);
  8000f1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f5:	c7 44 24 08 94 14 80 	movl   $0x801494,0x8(%esp)
  8000fc:	00 
  8000fd:	c7 44 24 04 25 00 00 	movl   $0x25,0x4(%esp)
  800104:	00 
  800105:	c7 04 24 73 14 80 00 	movl   $0x801473,(%esp)
  80010c:	e8 a6 01 00 00       	call   8002b7 <_panic>
}
  800111:	83 c4 20             	add    $0x20,%esp
  800114:	5b                   	pop    %ebx
  800115:	5e                   	pop    %esi
  800116:	5d                   	pop    %ebp
  800117:	c3                   	ret    

00800118 <dumbfork>:

envid_t
dumbfork(void)
{
  800118:	55                   	push   %ebp
  800119:	89 e5                	mov    %esp,%ebp
  80011b:	53                   	push   %ebx
  80011c:	83 ec 24             	sub    $0x24,%esp
// This must be inlined.  Exercise for reader: why?
static __inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	__asm __volatile("int %2"
  80011f:	bb 07 00 00 00       	mov    $0x7,%ebx
  800124:	89 d8                	mov    %ebx,%eax
  800126:	cd 30                	int    $0x30
  800128:	89 c3                	mov    %eax,%ebx
	// The kernel will initialize it with a copy of our register state,
	// so that the child will appear to have called sys_exofork() too -
	// except that in the child, this "fake" call to sys_exofork()
	// will return 0 instead of the envid of the child.
	envid = sys_exofork();
	if (envid < 0)
  80012a:	85 c0                	test   %eax,%eax
  80012c:	79 20                	jns    80014e <dumbfork+0x36>
		panic("sys_exofork: %e", envid);
  80012e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800132:	c7 44 24 08 a7 14 80 	movl   $0x8014a7,0x8(%esp)
  800139:	00 
  80013a:	c7 44 24 04 37 00 00 	movl   $0x37,0x4(%esp)
  800141:	00 
  800142:	c7 04 24 73 14 80 00 	movl   $0x801473,(%esp)
  800149:	e8 69 01 00 00       	call   8002b7 <_panic>
	if (envid == 0) {
  80014e:	85 c0                	test   %eax,%eax
  800150:	75 19                	jne    80016b <dumbfork+0x53>
		// We're the child.
		// The copied value of the global variable 'thisenv'
		// is no longer valid (it refers to the parent!).
		// Fix it and return 0.
		thisenv = &envs[ENVX(sys_getenvid())];
  800152:	e8 fa 0f 00 00       	call   801151 <sys_getenvid>
  800157:	25 ff 03 00 00       	and    $0x3ff,%eax
  80015c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80015f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800164:	a3 04 20 80 00       	mov    %eax,0x802004
		return 0;
  800169:	eb 7e                	jmp    8001e9 <dumbfork+0xd1>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80016b:	c7 45 f4 00 00 80 00 	movl   $0x800000,-0xc(%ebp)
  800172:	b8 08 20 80 00       	mov    $0x802008,%eax
  800177:	3d 00 00 80 00       	cmp    $0x800000,%eax
  80017c:	76 23                	jbe    8001a1 <dumbfork+0x89>
  80017e:	b8 00 00 80 00       	mov    $0x800000,%eax
		duppage(envid, addr);
  800183:	89 44 24 04          	mov    %eax,0x4(%esp)
  800187:	89 1c 24             	mov    %ebx,(%esp)
  80018a:	e8 a4 fe ff ff       	call   800033 <duppage>
	}

	// We're the parent.
	// Eagerly copy our entire address space into the child.
	// This is NOT what you should do in your fork implementation.
	for (addr = (uint8_t*) UTEXT; addr < end; addr += PGSIZE)
  80018f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800192:	05 00 10 00 00       	add    $0x1000,%eax
  800197:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80019a:	3d 08 20 80 00       	cmp    $0x802008,%eax
  80019f:	72 e2                	jb     800183 <dumbfork+0x6b>
		duppage(envid, addr);

	// Also copy the stack we are currently running on.
	duppage(envid, ROUNDDOWN(&addr, PGSIZE));
  8001a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8001a4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  8001a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8001ad:	89 1c 24             	mov    %ebx,(%esp)
  8001b0:	e8 7e fe ff ff       	call   800033 <duppage>

	// Start the child environment running
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8001b5:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
  8001bc:	00 
  8001bd:	89 1c 24             	mov    %ebx,(%esp)
  8001c0:	e8 df 0d 00 00       	call   800fa4 <sys_env_set_status>
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	79 20                	jns    8001e9 <dumbfork+0xd1>
		panic("sys_env_set_status: %e", r);
  8001c9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001cd:	c7 44 24 08 b7 14 80 	movl   $0x8014b7,0x8(%esp)
  8001d4:	00 
  8001d5:	c7 44 24 04 4c 00 00 	movl   $0x4c,0x4(%esp)
  8001dc:	00 
  8001dd:	c7 04 24 73 14 80 00 	movl   $0x801473,(%esp)
  8001e4:	e8 ce 00 00 00       	call   8002b7 <_panic>

	return envid;
}
  8001e9:	89 d8                	mov    %ebx,%eax
  8001eb:	83 c4 24             	add    $0x24,%esp
  8001ee:	5b                   	pop    %ebx
  8001ef:	5d                   	pop    %ebp
  8001f0:	c3                   	ret    

008001f1 <umain>:

envid_t dumbfork(void);

void
umain(int argc, char **argv)
{
  8001f1:	55                   	push   %ebp
  8001f2:	89 e5                	mov    %esp,%ebp
  8001f4:	57                   	push   %edi
  8001f5:	56                   	push   %esi
  8001f6:	53                   	push   %ebx
  8001f7:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;
	int i;

	// fork a child process
	who = dumbfork();
  8001fa:	e8 19 ff ff ff       	call   800118 <dumbfork>
  8001ff:	89 c6                	mov    %eax,%esi
  800201:	bb 00 00 00 00       	mov    $0x0,%ebx

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  800206:	bf d4 14 80 00       	mov    $0x8014d4,%edi

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  80020b:	eb 26                	jmp    800233 <umain+0x42>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
  80020d:	85 f6                	test   %esi,%esi
  80020f:	b8 ce 14 80 00       	mov    $0x8014ce,%eax
  800214:	0f 45 c7             	cmovne %edi,%eax
  800217:	89 44 24 08          	mov    %eax,0x8(%esp)
  80021b:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80021f:	c7 04 24 db 14 80 00 	movl   $0x8014db,(%esp)
  800226:	e8 43 01 00 00       	call   80036e <cprintf>
		sys_yield();
  80022b:	e8 ed 0e 00 00       	call   80111d <sys_yield>

	// fork a child process
	who = dumbfork();

	// print a message and yield to the other a few times
	for (i = 0; i < (who ? 10 : 20); i++) {
  800230:	83 c3 01             	add    $0x1,%ebx
  800233:	83 fe 01             	cmp    $0x1,%esi
  800236:	19 c0                	sbb    %eax,%eax
  800238:	83 e0 0a             	and    $0xa,%eax
  80023b:	83 c0 0a             	add    $0xa,%eax
  80023e:	39 c3                	cmp    %eax,%ebx
  800240:	7c cb                	jl     80020d <umain+0x1c>
		cprintf("%d: I am the %s!\n", i, who ? "parent" : "child");
		sys_yield();
	}
}
  800242:	83 c4 1c             	add    $0x1c,%esp
  800245:	5b                   	pop    %ebx
  800246:	5e                   	pop    %esi
  800247:	5f                   	pop    %edi
  800248:	5d                   	pop    %ebp
  800249:	c3                   	ret    

0080024a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80024a:	55                   	push   %ebp
  80024b:	89 e5                	mov    %esp,%ebp
  80024d:	83 ec 18             	sub    $0x18,%esp
  800250:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800253:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800256:	8b 75 08             	mov    0x8(%ebp),%esi
  800259:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80025c:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800263:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800266:	e8 e6 0e 00 00       	call   801151 <sys_getenvid>
  80026b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800270:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800273:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800278:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80027d:	85 f6                	test   %esi,%esi
  80027f:	7e 07                	jle    800288 <libmain+0x3e>
		binaryname = argv[0];
  800281:	8b 03                	mov    (%ebx),%eax
  800283:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800288:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80028c:	89 34 24             	mov    %esi,(%esp)
  80028f:	e8 5d ff ff ff       	call   8001f1 <umain>

	// exit gracefully
	exit();
  800294:	e8 0a 00 00 00       	call   8002a3 <exit>
}
  800299:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80029c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80029f:	89 ec                	mov    %ebp,%esp
  8002a1:	5d                   	pop    %ebp
  8002a2:	c3                   	ret    

008002a3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8002a9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8002b0:	e8 d0 0e 00 00       	call   801185 <sys_env_destroy>
}
  8002b5:	c9                   	leave  
  8002b6:	c3                   	ret    

008002b7 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002b7:	55                   	push   %ebp
  8002b8:	89 e5                	mov    %esp,%ebp
  8002ba:	56                   	push   %esi
  8002bb:	53                   	push   %ebx
  8002bc:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  8002bf:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002c2:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  8002c8:	e8 84 0e 00 00       	call   801151 <sys_getenvid>
  8002cd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002d0:	89 54 24 10          	mov    %edx,0x10(%esp)
  8002d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002db:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8002df:	89 44 24 04          	mov    %eax,0x4(%esp)
  8002e3:	c7 04 24 f8 14 80 00 	movl   $0x8014f8,(%esp)
  8002ea:	e8 7f 00 00 00       	call   80036e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8002f3:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f6:	89 04 24             	mov    %eax,(%esp)
  8002f9:	e8 0f 00 00 00       	call   80030d <vcprintf>
	cprintf("\n");
  8002fe:	c7 04 24 eb 14 80 00 	movl   $0x8014eb,(%esp)
  800305:	e8 64 00 00 00       	call   80036e <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80030a:	cc                   	int3   
  80030b:	eb fd                	jmp    80030a <_panic+0x53>

0080030d <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  80030d:	55                   	push   %ebp
  80030e:	89 e5                	mov    %esp,%ebp
  800310:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800316:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80031d:	00 00 00 
	b.cnt = 0;
  800320:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800327:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80032a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80032d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800331:	8b 45 08             	mov    0x8(%ebp),%eax
  800334:	89 44 24 08          	mov    %eax,0x8(%esp)
  800338:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80033e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800342:	c7 04 24 88 03 80 00 	movl   $0x800388,(%esp)
  800349:	e8 cf 01 00 00       	call   80051d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80034e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800354:	89 44 24 04          	mov    %eax,0x4(%esp)
  800358:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80035e:	89 04 24             	mov    %eax,(%esp)
  800361:	e8 18 0b 00 00       	call   800e7e <sys_cputs>

	return b.cnt;
}
  800366:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80036c:	c9                   	leave  
  80036d:	c3                   	ret    

0080036e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800374:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800377:	89 44 24 04          	mov    %eax,0x4(%esp)
  80037b:	8b 45 08             	mov    0x8(%ebp),%eax
  80037e:	89 04 24             	mov    %eax,(%esp)
  800381:	e8 87 ff ff ff       	call   80030d <vcprintf>
	va_end(ap);

	return cnt;
}
  800386:	c9                   	leave  
  800387:	c3                   	ret    

00800388 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800388:	55                   	push   %ebp
  800389:	89 e5                	mov    %esp,%ebp
  80038b:	53                   	push   %ebx
  80038c:	83 ec 14             	sub    $0x14,%esp
  80038f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800392:	8b 03                	mov    (%ebx),%eax
  800394:	8b 55 08             	mov    0x8(%ebp),%edx
  800397:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80039b:	83 c0 01             	add    $0x1,%eax
  80039e:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8003a0:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003a5:	75 19                	jne    8003c0 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8003a7:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  8003ae:	00 
  8003af:	8d 43 08             	lea    0x8(%ebx),%eax
  8003b2:	89 04 24             	mov    %eax,(%esp)
  8003b5:	e8 c4 0a 00 00       	call   800e7e <sys_cputs>
		b->idx = 0;
  8003ba:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  8003c0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003c4:	83 c4 14             	add    $0x14,%esp
  8003c7:	5b                   	pop    %ebx
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    
  8003ca:	66 90                	xchg   %ax,%ax
  8003cc:	66 90                	xchg   %ax,%ax
  8003ce:	66 90                	xchg   %ax,%ax

008003d0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003d0:	55                   	push   %ebp
  8003d1:	89 e5                	mov    %esp,%ebp
  8003d3:	57                   	push   %edi
  8003d4:	56                   	push   %esi
  8003d5:	53                   	push   %ebx
  8003d6:	83 ec 4c             	sub    $0x4c,%esp
  8003d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003dc:	89 d6                	mov    %edx,%esi
  8003de:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8003ea:	8b 45 10             	mov    0x10(%ebp),%eax
  8003ed:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8003f0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003f3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8003f6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003fb:	39 d1                	cmp    %edx,%ecx
  8003fd:	72 15                	jb     800414 <printnum+0x44>
  8003ff:	77 07                	ja     800408 <printnum+0x38>
  800401:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800404:	39 d0                	cmp    %edx,%eax
  800406:	76 0c                	jbe    800414 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800408:	83 eb 01             	sub    $0x1,%ebx
  80040b:	85 db                	test   %ebx,%ebx
  80040d:	8d 76 00             	lea    0x0(%esi),%esi
  800410:	7f 61                	jg     800473 <printnum+0xa3>
  800412:	eb 70                	jmp    800484 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800414:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800418:	83 eb 01             	sub    $0x1,%ebx
  80041b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80041f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800423:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800427:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80042b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80042e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800431:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800434:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800438:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80043f:	00 
  800440:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800443:	89 04 24             	mov    %eax,(%esp)
  800446:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800449:	89 54 24 04          	mov    %edx,0x4(%esp)
  80044d:	e8 9e 0d 00 00       	call   8011f0 <__udivdi3>
  800452:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800455:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800458:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80045c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800460:	89 04 24             	mov    %eax,(%esp)
  800463:	89 54 24 04          	mov    %edx,0x4(%esp)
  800467:	89 f2                	mov    %esi,%edx
  800469:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80046c:	e8 5f ff ff ff       	call   8003d0 <printnum>
  800471:	eb 11                	jmp    800484 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800473:	89 74 24 04          	mov    %esi,0x4(%esp)
  800477:	89 3c 24             	mov    %edi,(%esp)
  80047a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80047d:	83 eb 01             	sub    $0x1,%ebx
  800480:	85 db                	test   %ebx,%ebx
  800482:	7f ef                	jg     800473 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800484:	89 74 24 04          	mov    %esi,0x4(%esp)
  800488:	8b 74 24 04          	mov    0x4(%esp),%esi
  80048c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80048f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800493:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80049a:	00 
  80049b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80049e:	89 14 24             	mov    %edx,(%esp)
  8004a1:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004a4:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8004a8:	e8 73 0e 00 00       	call   801320 <__umoddi3>
  8004ad:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b1:	0f be 80 1c 15 80 00 	movsbl 0x80151c(%eax),%eax
  8004b8:	89 04 24             	mov    %eax,(%esp)
  8004bb:	ff 55 e4             	call   *-0x1c(%ebp)
}
  8004be:	83 c4 4c             	add    $0x4c,%esp
  8004c1:	5b                   	pop    %ebx
  8004c2:	5e                   	pop    %esi
  8004c3:	5f                   	pop    %edi
  8004c4:	5d                   	pop    %ebp
  8004c5:	c3                   	ret    

008004c6 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004c6:	55                   	push   %ebp
  8004c7:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004c9:	83 fa 01             	cmp    $0x1,%edx
  8004cc:	7e 0e                	jle    8004dc <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004ce:	8b 10                	mov    (%eax),%edx
  8004d0:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004d3:	89 08                	mov    %ecx,(%eax)
  8004d5:	8b 02                	mov    (%edx),%eax
  8004d7:	8b 52 04             	mov    0x4(%edx),%edx
  8004da:	eb 22                	jmp    8004fe <getuint+0x38>
	else if (lflag)
  8004dc:	85 d2                	test   %edx,%edx
  8004de:	74 10                	je     8004f0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004e0:	8b 10                	mov    (%eax),%edx
  8004e2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004e5:	89 08                	mov    %ecx,(%eax)
  8004e7:	8b 02                	mov    (%edx),%eax
  8004e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ee:	eb 0e                	jmp    8004fe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004f0:	8b 10                	mov    (%eax),%edx
  8004f2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f5:	89 08                	mov    %ecx,(%eax)
  8004f7:	8b 02                	mov    (%edx),%eax
  8004f9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004fe:	5d                   	pop    %ebp
  8004ff:	c3                   	ret    

00800500 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800500:	55                   	push   %ebp
  800501:	89 e5                	mov    %esp,%ebp
  800503:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800506:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80050a:	8b 10                	mov    (%eax),%edx
  80050c:	3b 50 04             	cmp    0x4(%eax),%edx
  80050f:	73 0a                	jae    80051b <sprintputch+0x1b>
		*b->buf++ = ch;
  800511:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800514:	88 0a                	mov    %cl,(%edx)
  800516:	83 c2 01             	add    $0x1,%edx
  800519:	89 10                	mov    %edx,(%eax)
}
  80051b:	5d                   	pop    %ebp
  80051c:	c3                   	ret    

0080051d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	57                   	push   %edi
  800521:	56                   	push   %esi
  800522:	53                   	push   %ebx
  800523:	83 ec 5c             	sub    $0x5c,%esp
  800526:	8b 7d 08             	mov    0x8(%ebp),%edi
  800529:	8b 75 0c             	mov    0xc(%ebp),%esi
  80052c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80052f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800536:	eb 11                	jmp    800549 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800538:	85 c0                	test   %eax,%eax
  80053a:	0f 84 16 04 00 00    	je     800956 <vprintfmt+0x439>
				return;
			putch(ch, putdat);
  800540:	89 74 24 04          	mov    %esi,0x4(%esp)
  800544:	89 04 24             	mov    %eax,(%esp)
  800547:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800549:	0f b6 03             	movzbl (%ebx),%eax
  80054c:	83 c3 01             	add    $0x1,%ebx
  80054f:	83 f8 25             	cmp    $0x25,%eax
  800552:	75 e4                	jne    800538 <vprintfmt+0x1b>
  800554:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80055b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800562:	b9 00 00 00 00       	mov    $0x0,%ecx
  800567:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80056b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800572:	eb 06                	jmp    80057a <vprintfmt+0x5d>
  800574:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800578:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	0f b6 13             	movzbl (%ebx),%edx
  80057d:	0f b6 c2             	movzbl %dl,%eax
  800580:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800583:	8d 43 01             	lea    0x1(%ebx),%eax
  800586:	83 ea 23             	sub    $0x23,%edx
  800589:	80 fa 55             	cmp    $0x55,%dl
  80058c:	0f 87 a7 03 00 00    	ja     800939 <vprintfmt+0x41c>
  800592:	0f b6 d2             	movzbl %dl,%edx
  800595:	ff 24 95 e0 15 80 00 	jmp    *0x8015e0(,%edx,4)
  80059c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  8005a0:	eb d6                	jmp    800578 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005a2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005a5:	83 ea 30             	sub    $0x30,%edx
  8005a8:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  8005ab:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8005ae:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8005b1:	83 fb 09             	cmp    $0x9,%ebx
  8005b4:	77 54                	ja     80060a <vprintfmt+0xed>
  8005b6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  8005b9:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005bc:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  8005bf:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  8005c2:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  8005c6:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  8005c9:	8d 5a d0             	lea    -0x30(%edx),%ebx
  8005cc:	83 fb 09             	cmp    $0x9,%ebx
  8005cf:	76 eb                	jbe    8005bc <vprintfmt+0x9f>
  8005d1:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8005d4:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005d7:	eb 31                	jmp    80060a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005d9:	8b 55 14             	mov    0x14(%ebp),%edx
  8005dc:	8d 5a 04             	lea    0x4(%edx),%ebx
  8005df:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8005e2:	8b 12                	mov    (%edx),%edx
  8005e4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8005e7:	eb 21                	jmp    80060a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8005e9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8005ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f2:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  8005f6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8005f9:	e9 7a ff ff ff       	jmp    800578 <vprintfmt+0x5b>
  8005fe:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800605:	e9 6e ff ff ff       	jmp    800578 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80060a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80060e:	0f 89 64 ff ff ff    	jns    800578 <vprintfmt+0x5b>
  800614:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800617:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80061a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80061d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800620:	e9 53 ff ff ff       	jmp    800578 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800625:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800628:	e9 4b ff ff ff       	jmp    800578 <vprintfmt+0x5b>
  80062d:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800630:	8b 45 14             	mov    0x14(%ebp),%eax
  800633:	8d 50 04             	lea    0x4(%eax),%edx
  800636:	89 55 14             	mov    %edx,0x14(%ebp)
  800639:	89 74 24 04          	mov    %esi,0x4(%esp)
  80063d:	8b 00                	mov    (%eax),%eax
  80063f:	89 04 24             	mov    %eax,(%esp)
  800642:	ff d7                	call   *%edi
  800644:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800647:	e9 fd fe ff ff       	jmp    800549 <vprintfmt+0x2c>
  80064c:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80064f:	8b 45 14             	mov    0x14(%ebp),%eax
  800652:	8d 50 04             	lea    0x4(%eax),%edx
  800655:	89 55 14             	mov    %edx,0x14(%ebp)
  800658:	8b 00                	mov    (%eax),%eax
  80065a:	89 c2                	mov    %eax,%edx
  80065c:	c1 fa 1f             	sar    $0x1f,%edx
  80065f:	31 d0                	xor    %edx,%eax
  800661:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800663:	83 f8 08             	cmp    $0x8,%eax
  800666:	7f 0b                	jg     800673 <vprintfmt+0x156>
  800668:	8b 14 85 40 17 80 00 	mov    0x801740(,%eax,4),%edx
  80066f:	85 d2                	test   %edx,%edx
  800671:	75 20                	jne    800693 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800673:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800677:	c7 44 24 08 2d 15 80 	movl   $0x80152d,0x8(%esp)
  80067e:	00 
  80067f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800683:	89 3c 24             	mov    %edi,(%esp)
  800686:	e8 53 03 00 00       	call   8009de <printfmt>
  80068b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80068e:	e9 b6 fe ff ff       	jmp    800549 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800693:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800697:	c7 44 24 08 36 15 80 	movl   $0x801536,0x8(%esp)
  80069e:	00 
  80069f:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006a3:	89 3c 24             	mov    %edi,(%esp)
  8006a6:	e8 33 03 00 00       	call   8009de <printfmt>
  8006ab:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8006ae:	e9 96 fe ff ff       	jmp    800549 <vprintfmt+0x2c>
  8006b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b6:	89 c3                	mov    %eax,%ebx
  8006b8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8006bb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8006be:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8006c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8006c4:	8d 50 04             	lea    0x4(%eax),%edx
  8006c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8006ca:	8b 00                	mov    (%eax),%eax
  8006cc:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  8006cf:	85 c0                	test   %eax,%eax
  8006d1:	b8 39 15 80 00       	mov    $0x801539,%eax
  8006d6:	0f 45 45 c4          	cmovne -0x3c(%ebp),%eax
  8006da:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  8006dd:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8006e1:	7e 06                	jle    8006e9 <vprintfmt+0x1cc>
  8006e3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8006e7:	75 13                	jne    8006fc <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006e9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8006ec:	0f be 02             	movsbl (%edx),%eax
  8006ef:	85 c0                	test   %eax,%eax
  8006f1:	0f 85 9b 00 00 00    	jne    800792 <vprintfmt+0x275>
  8006f7:	e9 88 00 00 00       	jmp    800784 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006fc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800700:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  800703:	89 0c 24             	mov    %ecx,(%esp)
  800706:	e8 20 03 00 00       	call   800a2b <strnlen>
  80070b:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80070e:	29 c2                	sub    %eax,%edx
  800710:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800713:	85 d2                	test   %edx,%edx
  800715:	7e d2                	jle    8006e9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800717:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  80071b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80071e:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800721:	89 d3                	mov    %edx,%ebx
  800723:	89 74 24 04          	mov    %esi,0x4(%esp)
  800727:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80072a:	89 04 24             	mov    %eax,(%esp)
  80072d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80072f:	83 eb 01             	sub    $0x1,%ebx
  800732:	85 db                	test   %ebx,%ebx
  800734:	7f ed                	jg     800723 <vprintfmt+0x206>
  800736:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  800739:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800740:	eb a7                	jmp    8006e9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800742:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800746:	74 1a                	je     800762 <vprintfmt+0x245>
  800748:	8d 50 e0             	lea    -0x20(%eax),%edx
  80074b:	83 fa 5e             	cmp    $0x5e,%edx
  80074e:	76 12                	jbe    800762 <vprintfmt+0x245>
					putch('?', putdat);
  800750:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800754:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80075b:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80075e:	66 90                	xchg   %ax,%ax
  800760:	eb 0a                	jmp    80076c <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800762:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800766:	89 04 24             	mov    %eax,(%esp)
  800769:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80076c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800770:	0f be 03             	movsbl (%ebx),%eax
  800773:	85 c0                	test   %eax,%eax
  800775:	74 05                	je     80077c <vprintfmt+0x25f>
  800777:	83 c3 01             	add    $0x1,%ebx
  80077a:	eb 29                	jmp    8007a5 <vprintfmt+0x288>
  80077c:	89 fe                	mov    %edi,%esi
  80077e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800781:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800784:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800788:	7f 2e                	jg     8007b8 <vprintfmt+0x29b>
  80078a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80078d:	e9 b7 fd ff ff       	jmp    800549 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800792:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800795:	83 c2 01             	add    $0x1,%edx
  800798:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80079b:	89 f7                	mov    %esi,%edi
  80079d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  8007a0:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  8007a3:	89 d3                	mov    %edx,%ebx
  8007a5:	85 f6                	test   %esi,%esi
  8007a7:	78 99                	js     800742 <vprintfmt+0x225>
  8007a9:	83 ee 01             	sub    $0x1,%esi
  8007ac:	79 94                	jns    800742 <vprintfmt+0x225>
  8007ae:	89 fe                	mov    %edi,%esi
  8007b0:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8007b3:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  8007b6:	eb cc                	jmp    800784 <vprintfmt+0x267>
  8007b8:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  8007bb:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8007be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007c2:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  8007c9:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8007cb:	83 eb 01             	sub    $0x1,%ebx
  8007ce:	85 db                	test   %ebx,%ebx
  8007d0:	7f ec                	jg     8007be <vprintfmt+0x2a1>
  8007d2:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8007d5:	e9 6f fd ff ff       	jmp    800549 <vprintfmt+0x2c>
  8007da:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007dd:	83 f9 01             	cmp    $0x1,%ecx
  8007e0:	7e 16                	jle    8007f8 <vprintfmt+0x2db>
		return va_arg(*ap, long long);
  8007e2:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e5:	8d 50 08             	lea    0x8(%eax),%edx
  8007e8:	89 55 14             	mov    %edx,0x14(%ebp)
  8007eb:	8b 10                	mov    (%eax),%edx
  8007ed:	8b 48 04             	mov    0x4(%eax),%ecx
  8007f0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8007f3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8007f6:	eb 32                	jmp    80082a <vprintfmt+0x30d>
	else if (lflag)
  8007f8:	85 c9                	test   %ecx,%ecx
  8007fa:	74 18                	je     800814 <vprintfmt+0x2f7>
		return va_arg(*ap, long);
  8007fc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ff:	8d 50 04             	lea    0x4(%eax),%edx
  800802:	89 55 14             	mov    %edx,0x14(%ebp)
  800805:	8b 00                	mov    (%eax),%eax
  800807:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80080a:	89 c1                	mov    %eax,%ecx
  80080c:	c1 f9 1f             	sar    $0x1f,%ecx
  80080f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800812:	eb 16                	jmp    80082a <vprintfmt+0x30d>
	else
		return va_arg(*ap, int);
  800814:	8b 45 14             	mov    0x14(%ebp),%eax
  800817:	8d 50 04             	lea    0x4(%eax),%edx
  80081a:	89 55 14             	mov    %edx,0x14(%ebp)
  80081d:	8b 00                	mov    (%eax),%eax
  80081f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800822:	89 c2                	mov    %eax,%edx
  800824:	c1 fa 1f             	sar    $0x1f,%edx
  800827:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80082a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80082d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800830:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800835:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800839:	0f 89 b8 00 00 00    	jns    8008f7 <vprintfmt+0x3da>
				putch('-', putdat);
  80083f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800843:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80084a:	ff d7                	call   *%edi
				num = -(long long) num;
  80084c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80084f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800852:	f7 d9                	neg    %ecx
  800854:	83 d3 00             	adc    $0x0,%ebx
  800857:	f7 db                	neg    %ebx
  800859:	b8 0a 00 00 00       	mov    $0xa,%eax
  80085e:	e9 94 00 00 00       	jmp    8008f7 <vprintfmt+0x3da>
  800863:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800866:	89 ca                	mov    %ecx,%edx
  800868:	8d 45 14             	lea    0x14(%ebp),%eax
  80086b:	e8 56 fc ff ff       	call   8004c6 <getuint>
  800870:	89 c1                	mov    %eax,%ecx
  800872:	89 d3                	mov    %edx,%ebx
  800874:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800879:	eb 7c                	jmp    8008f7 <vprintfmt+0x3da>
  80087b:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  80087e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800882:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800889:	ff d7                	call   *%edi
			putch('X', putdat);
  80088b:	89 74 24 04          	mov    %esi,0x4(%esp)
  80088f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800896:	ff d7                	call   *%edi
			putch('X', putdat);
  800898:	89 74 24 04          	mov    %esi,0x4(%esp)
  80089c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  8008a3:	ff d7                	call   *%edi
  8008a5:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8008a8:	e9 9c fc ff ff       	jmp    800549 <vprintfmt+0x2c>
  8008ad:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  8008b0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008b4:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  8008bb:	ff d7                	call   *%edi
			putch('x', putdat);
  8008bd:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008c1:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  8008c8:	ff d7                	call   *%edi
			num = (unsigned long long)
  8008ca:	8b 45 14             	mov    0x14(%ebp),%eax
  8008cd:	8d 50 04             	lea    0x4(%eax),%edx
  8008d0:	89 55 14             	mov    %edx,0x14(%ebp)
  8008d3:	8b 08                	mov    (%eax),%ecx
  8008d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8008da:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008df:	eb 16                	jmp    8008f7 <vprintfmt+0x3da>
  8008e1:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008e4:	89 ca                	mov    %ecx,%edx
  8008e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8008e9:	e8 d8 fb ff ff       	call   8004c6 <getuint>
  8008ee:	89 c1                	mov    %eax,%ecx
  8008f0:	89 d3                	mov    %edx,%ebx
  8008f2:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008f7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  8008fb:	89 54 24 10          	mov    %edx,0x10(%esp)
  8008ff:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800902:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800906:	89 44 24 08          	mov    %eax,0x8(%esp)
  80090a:	89 0c 24             	mov    %ecx,(%esp)
  80090d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800911:	89 f2                	mov    %esi,%edx
  800913:	89 f8                	mov    %edi,%eax
  800915:	e8 b6 fa ff ff       	call   8003d0 <printnum>
  80091a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  80091d:	e9 27 fc ff ff       	jmp    800549 <vprintfmt+0x2c>
  800922:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800925:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800928:	89 74 24 04          	mov    %esi,0x4(%esp)
  80092c:	89 14 24             	mov    %edx,(%esp)
  80092f:	ff d7                	call   *%edi
  800931:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800934:	e9 10 fc ff ff       	jmp    800549 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800939:	89 74 24 04          	mov    %esi,0x4(%esp)
  80093d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800944:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800946:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800949:	80 38 25             	cmpb   $0x25,(%eax)
  80094c:	0f 84 f7 fb ff ff    	je     800549 <vprintfmt+0x2c>
  800952:	89 c3                	mov    %eax,%ebx
  800954:	eb f0                	jmp    800946 <vprintfmt+0x429>
				/* do nothing */;
			break;
		}
	}
}
  800956:	83 c4 5c             	add    $0x5c,%esp
  800959:	5b                   	pop    %ebx
  80095a:	5e                   	pop    %esi
  80095b:	5f                   	pop    %edi
  80095c:	5d                   	pop    %ebp
  80095d:	c3                   	ret    

0080095e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80095e:	55                   	push   %ebp
  80095f:	89 e5                	mov    %esp,%ebp
  800961:	83 ec 28             	sub    $0x28,%esp
  800964:	8b 45 08             	mov    0x8(%ebp),%eax
  800967:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  80096a:	85 c0                	test   %eax,%eax
  80096c:	74 04                	je     800972 <vsnprintf+0x14>
  80096e:	85 d2                	test   %edx,%edx
  800970:	7f 07                	jg     800979 <vsnprintf+0x1b>
  800972:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800977:	eb 3b                	jmp    8009b4 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800979:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80097c:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800980:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800983:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80098a:	8b 45 14             	mov    0x14(%ebp),%eax
  80098d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800991:	8b 45 10             	mov    0x10(%ebp),%eax
  800994:	89 44 24 08          	mov    %eax,0x8(%esp)
  800998:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80099b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099f:	c7 04 24 00 05 80 00 	movl   $0x800500,(%esp)
  8009a6:	e8 72 fb ff ff       	call   80051d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8009ab:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009ae:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8009b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8009b4:	c9                   	leave  
  8009b5:	c3                   	ret    

008009b6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  8009bc:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  8009bf:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8009c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d4:	89 04 24             	mov    %eax,(%esp)
  8009d7:	e8 82 ff ff ff       	call   80095e <vsnprintf>
	va_end(ap);

	return rc;
}
  8009dc:	c9                   	leave  
  8009dd:	c3                   	ret    

008009de <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8009de:	55                   	push   %ebp
  8009df:	89 e5                	mov    %esp,%ebp
  8009e1:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  8009e4:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  8009e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009eb:	8b 45 10             	mov    0x10(%ebp),%eax
  8009ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8009fc:	89 04 24             	mov    %eax,(%esp)
  8009ff:	e8 19 fb ff ff       	call   80051d <vprintfmt>
	va_end(ap);
}
  800a04:	c9                   	leave  
  800a05:	c3                   	ret    
  800a06:	66 90                	xchg   %ax,%ax
  800a08:	66 90                	xchg   %ax,%ax
  800a0a:	66 90                	xchg   %ax,%ax
  800a0c:	66 90                	xchg   %ax,%ax
  800a0e:	66 90                	xchg   %ax,%ax

00800a10 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a10:	55                   	push   %ebp
  800a11:	89 e5                	mov    %esp,%ebp
  800a13:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a16:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1b:	80 3a 00             	cmpb   $0x0,(%edx)
  800a1e:	74 09                	je     800a29 <strlen+0x19>
		n++;
  800a20:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800a23:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a27:	75 f7                	jne    800a20 <strlen+0x10>
		n++;
	return n;
}
  800a29:	5d                   	pop    %ebp
  800a2a:	c3                   	ret    

00800a2b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a2b:	55                   	push   %ebp
  800a2c:	89 e5                	mov    %esp,%ebp
  800a2e:	53                   	push   %ebx
  800a2f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a32:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a35:	85 c9                	test   %ecx,%ecx
  800a37:	74 19                	je     800a52 <strnlen+0x27>
  800a39:	80 3b 00             	cmpb   $0x0,(%ebx)
  800a3c:	74 14                	je     800a52 <strnlen+0x27>
  800a3e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800a43:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a46:	39 c8                	cmp    %ecx,%eax
  800a48:	74 0d                	je     800a57 <strnlen+0x2c>
  800a4a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800a4e:	75 f3                	jne    800a43 <strnlen+0x18>
  800a50:	eb 05                	jmp    800a57 <strnlen+0x2c>
  800a52:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800a57:	5b                   	pop    %ebx
  800a58:	5d                   	pop    %ebp
  800a59:	c3                   	ret    

00800a5a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	53                   	push   %ebx
  800a5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a61:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a64:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a69:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800a6d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800a70:	83 c2 01             	add    $0x1,%edx
  800a73:	84 c9                	test   %cl,%cl
  800a75:	75 f2                	jne    800a69 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800a77:	5b                   	pop    %ebx
  800a78:	5d                   	pop    %ebp
  800a79:	c3                   	ret    

00800a7a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a7a:	55                   	push   %ebp
  800a7b:	89 e5                	mov    %esp,%ebp
  800a7d:	53                   	push   %ebx
  800a7e:	83 ec 08             	sub    $0x8,%esp
  800a81:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a84:	89 1c 24             	mov    %ebx,(%esp)
  800a87:	e8 84 ff ff ff       	call   800a10 <strlen>
	strcpy(dst + len, src);
  800a8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800a93:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800a96:	89 04 24             	mov    %eax,(%esp)
  800a99:	e8 bc ff ff ff       	call   800a5a <strcpy>
	return dst;
}
  800a9e:	89 d8                	mov    %ebx,%eax
  800aa0:	83 c4 08             	add    $0x8,%esp
  800aa3:	5b                   	pop    %ebx
  800aa4:	5d                   	pop    %ebp
  800aa5:	c3                   	ret    

00800aa6 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800aa6:	55                   	push   %ebp
  800aa7:	89 e5                	mov    %esp,%ebp
  800aa9:	56                   	push   %esi
  800aaa:	53                   	push   %ebx
  800aab:	8b 45 08             	mov    0x8(%ebp),%eax
  800aae:	8b 55 0c             	mov    0xc(%ebp),%edx
  800ab1:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ab4:	85 f6                	test   %esi,%esi
  800ab6:	74 18                	je     800ad0 <strncpy+0x2a>
  800ab8:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800abd:	0f b6 1a             	movzbl (%edx),%ebx
  800ac0:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800ac3:	80 3a 01             	cmpb   $0x1,(%edx)
  800ac6:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ac9:	83 c1 01             	add    $0x1,%ecx
  800acc:	39 ce                	cmp    %ecx,%esi
  800ace:	77 ed                	ja     800abd <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800ad0:	5b                   	pop    %ebx
  800ad1:	5e                   	pop    %esi
  800ad2:	5d                   	pop    %ebp
  800ad3:	c3                   	ret    

00800ad4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ad4:	55                   	push   %ebp
  800ad5:	89 e5                	mov    %esp,%ebp
  800ad7:	56                   	push   %esi
  800ad8:	53                   	push   %ebx
  800ad9:	8b 75 08             	mov    0x8(%ebp),%esi
  800adc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800adf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ae2:	89 f0                	mov    %esi,%eax
  800ae4:	85 c9                	test   %ecx,%ecx
  800ae6:	74 27                	je     800b0f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800ae8:	83 e9 01             	sub    $0x1,%ecx
  800aeb:	74 1d                	je     800b0a <strlcpy+0x36>
  800aed:	0f b6 1a             	movzbl (%edx),%ebx
  800af0:	84 db                	test   %bl,%bl
  800af2:	74 16                	je     800b0a <strlcpy+0x36>
			*dst++ = *src++;
  800af4:	88 18                	mov    %bl,(%eax)
  800af6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800af9:	83 e9 01             	sub    $0x1,%ecx
  800afc:	74 0e                	je     800b0c <strlcpy+0x38>
			*dst++ = *src++;
  800afe:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800b01:	0f b6 1a             	movzbl (%edx),%ebx
  800b04:	84 db                	test   %bl,%bl
  800b06:	75 ec                	jne    800af4 <strlcpy+0x20>
  800b08:	eb 02                	jmp    800b0c <strlcpy+0x38>
  800b0a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800b0c:	c6 00 00             	movb   $0x0,(%eax)
  800b0f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800b11:	5b                   	pop    %ebx
  800b12:	5e                   	pop    %esi
  800b13:	5d                   	pop    %ebp
  800b14:	c3                   	ret    

00800b15 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b15:	55                   	push   %ebp
  800b16:	89 e5                	mov    %esp,%ebp
  800b18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b1e:	0f b6 01             	movzbl (%ecx),%eax
  800b21:	84 c0                	test   %al,%al
  800b23:	74 15                	je     800b3a <strcmp+0x25>
  800b25:	3a 02                	cmp    (%edx),%al
  800b27:	75 11                	jne    800b3a <strcmp+0x25>
		p++, q++;
  800b29:	83 c1 01             	add    $0x1,%ecx
  800b2c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800b2f:	0f b6 01             	movzbl (%ecx),%eax
  800b32:	84 c0                	test   %al,%al
  800b34:	74 04                	je     800b3a <strcmp+0x25>
  800b36:	3a 02                	cmp    (%edx),%al
  800b38:	74 ef                	je     800b29 <strcmp+0x14>
  800b3a:	0f b6 c0             	movzbl %al,%eax
  800b3d:	0f b6 12             	movzbl (%edx),%edx
  800b40:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b42:	5d                   	pop    %ebp
  800b43:	c3                   	ret    

00800b44 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b44:	55                   	push   %ebp
  800b45:	89 e5                	mov    %esp,%ebp
  800b47:	53                   	push   %ebx
  800b48:	8b 55 08             	mov    0x8(%ebp),%edx
  800b4b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b4e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800b51:	85 c0                	test   %eax,%eax
  800b53:	74 23                	je     800b78 <strncmp+0x34>
  800b55:	0f b6 1a             	movzbl (%edx),%ebx
  800b58:	84 db                	test   %bl,%bl
  800b5a:	74 25                	je     800b81 <strncmp+0x3d>
  800b5c:	3a 19                	cmp    (%ecx),%bl
  800b5e:	75 21                	jne    800b81 <strncmp+0x3d>
  800b60:	83 e8 01             	sub    $0x1,%eax
  800b63:	74 13                	je     800b78 <strncmp+0x34>
		n--, p++, q++;
  800b65:	83 c2 01             	add    $0x1,%edx
  800b68:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800b6b:	0f b6 1a             	movzbl (%edx),%ebx
  800b6e:	84 db                	test   %bl,%bl
  800b70:	74 0f                	je     800b81 <strncmp+0x3d>
  800b72:	3a 19                	cmp    (%ecx),%bl
  800b74:	74 ea                	je     800b60 <strncmp+0x1c>
  800b76:	eb 09                	jmp    800b81 <strncmp+0x3d>
  800b78:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800b7d:	5b                   	pop    %ebx
  800b7e:	5d                   	pop    %ebp
  800b7f:	90                   	nop
  800b80:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b81:	0f b6 02             	movzbl (%edx),%eax
  800b84:	0f b6 11             	movzbl (%ecx),%edx
  800b87:	29 d0                	sub    %edx,%eax
  800b89:	eb f2                	jmp    800b7d <strncmp+0x39>

00800b8b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b8b:	55                   	push   %ebp
  800b8c:	89 e5                	mov    %esp,%ebp
  800b8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b91:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b95:	0f b6 10             	movzbl (%eax),%edx
  800b98:	84 d2                	test   %dl,%dl
  800b9a:	74 18                	je     800bb4 <strchr+0x29>
		if (*s == c)
  800b9c:	38 ca                	cmp    %cl,%dl
  800b9e:	75 0a                	jne    800baa <strchr+0x1f>
  800ba0:	eb 17                	jmp    800bb9 <strchr+0x2e>
  800ba2:	38 ca                	cmp    %cl,%dl
  800ba4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ba8:	74 0f                	je     800bb9 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800baa:	83 c0 01             	add    $0x1,%eax
  800bad:	0f b6 10             	movzbl (%eax),%edx
  800bb0:	84 d2                	test   %dl,%dl
  800bb2:	75 ee                	jne    800ba2 <strchr+0x17>
  800bb4:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800bc1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bc5:	0f b6 10             	movzbl (%eax),%edx
  800bc8:	84 d2                	test   %dl,%dl
  800bca:	74 18                	je     800be4 <strfind+0x29>
		if (*s == c)
  800bcc:	38 ca                	cmp    %cl,%dl
  800bce:	75 0a                	jne    800bda <strfind+0x1f>
  800bd0:	eb 12                	jmp    800be4 <strfind+0x29>
  800bd2:	38 ca                	cmp    %cl,%dl
  800bd4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800bd8:	74 0a                	je     800be4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800bda:	83 c0 01             	add    $0x1,%eax
  800bdd:	0f b6 10             	movzbl (%eax),%edx
  800be0:	84 d2                	test   %dl,%dl
  800be2:	75 ee                	jne    800bd2 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800be4:	5d                   	pop    %ebp
  800be5:	c3                   	ret    

00800be6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800be6:	55                   	push   %ebp
  800be7:	89 e5                	mov    %esp,%ebp
  800be9:	83 ec 0c             	sub    $0xc,%esp
  800bec:	89 1c 24             	mov    %ebx,(%esp)
  800bef:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bf3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800bf7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800bfa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bfd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800c00:	85 c9                	test   %ecx,%ecx
  800c02:	74 30                	je     800c34 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c04:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c0a:	75 25                	jne    800c31 <memset+0x4b>
  800c0c:	f6 c1 03             	test   $0x3,%cl
  800c0f:	75 20                	jne    800c31 <memset+0x4b>
		c &= 0xFF;
  800c11:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c14:	89 d3                	mov    %edx,%ebx
  800c16:	c1 e3 08             	shl    $0x8,%ebx
  800c19:	89 d6                	mov    %edx,%esi
  800c1b:	c1 e6 18             	shl    $0x18,%esi
  800c1e:	89 d0                	mov    %edx,%eax
  800c20:	c1 e0 10             	shl    $0x10,%eax
  800c23:	09 f0                	or     %esi,%eax
  800c25:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800c27:	09 d8                	or     %ebx,%eax
  800c29:	c1 e9 02             	shr    $0x2,%ecx
  800c2c:	fc                   	cld    
  800c2d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800c2f:	eb 03                	jmp    800c34 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c31:	fc                   	cld    
  800c32:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800c34:	89 f8                	mov    %edi,%eax
  800c36:	8b 1c 24             	mov    (%esp),%ebx
  800c39:	8b 74 24 04          	mov    0x4(%esp),%esi
  800c3d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800c41:	89 ec                	mov    %ebp,%esp
  800c43:	5d                   	pop    %ebp
  800c44:	c3                   	ret    

00800c45 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c45:	55                   	push   %ebp
  800c46:	89 e5                	mov    %esp,%ebp
  800c48:	83 ec 08             	sub    $0x8,%esp
  800c4b:	89 34 24             	mov    %esi,(%esp)
  800c4e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800c52:	8b 45 08             	mov    0x8(%ebp),%eax
  800c55:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800c58:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800c5b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800c5d:	39 c6                	cmp    %eax,%esi
  800c5f:	73 35                	jae    800c96 <memmove+0x51>
  800c61:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c64:	39 d0                	cmp    %edx,%eax
  800c66:	73 2e                	jae    800c96 <memmove+0x51>
		s += n;
		d += n;
  800c68:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c6a:	f6 c2 03             	test   $0x3,%dl
  800c6d:	75 1b                	jne    800c8a <memmove+0x45>
  800c6f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800c75:	75 13                	jne    800c8a <memmove+0x45>
  800c77:	f6 c1 03             	test   $0x3,%cl
  800c7a:	75 0e                	jne    800c8a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800c7c:	83 ef 04             	sub    $0x4,%edi
  800c7f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c82:	c1 e9 02             	shr    $0x2,%ecx
  800c85:	fd                   	std    
  800c86:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c88:	eb 09                	jmp    800c93 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800c8a:	83 ef 01             	sub    $0x1,%edi
  800c8d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800c90:	fd                   	std    
  800c91:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c93:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c94:	eb 20                	jmp    800cb6 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c96:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c9c:	75 15                	jne    800cb3 <memmove+0x6e>
  800c9e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800ca4:	75 0d                	jne    800cb3 <memmove+0x6e>
  800ca6:	f6 c1 03             	test   $0x3,%cl
  800ca9:	75 08                	jne    800cb3 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800cab:	c1 e9 02             	shr    $0x2,%ecx
  800cae:	fc                   	cld    
  800caf:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800cb1:	eb 03                	jmp    800cb6 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800cb3:	fc                   	cld    
  800cb4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800cb6:	8b 34 24             	mov    (%esp),%esi
  800cb9:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800cbd:	89 ec                	mov    %ebp,%esp
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
  800cc4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800cc7:	8b 45 10             	mov    0x10(%ebp),%eax
  800cca:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cd8:	89 04 24             	mov    %eax,(%esp)
  800cdb:	e8 65 ff ff ff       	call   800c45 <memmove>
}
  800ce0:	c9                   	leave  
  800ce1:	c3                   	ret    

00800ce2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	57                   	push   %edi
  800ce6:	56                   	push   %esi
  800ce7:	53                   	push   %ebx
  800ce8:	8b 75 08             	mov    0x8(%ebp),%esi
  800ceb:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800cee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cf1:	85 c9                	test   %ecx,%ecx
  800cf3:	74 36                	je     800d2b <memcmp+0x49>
		if (*s1 != *s2)
  800cf5:	0f b6 06             	movzbl (%esi),%eax
  800cf8:	0f b6 1f             	movzbl (%edi),%ebx
  800cfb:	38 d8                	cmp    %bl,%al
  800cfd:	74 20                	je     800d1f <memcmp+0x3d>
  800cff:	eb 14                	jmp    800d15 <memcmp+0x33>
  800d01:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800d06:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800d0b:	83 c2 01             	add    $0x1,%edx
  800d0e:	83 e9 01             	sub    $0x1,%ecx
  800d11:	38 d8                	cmp    %bl,%al
  800d13:	74 12                	je     800d27 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800d15:	0f b6 c0             	movzbl %al,%eax
  800d18:	0f b6 db             	movzbl %bl,%ebx
  800d1b:	29 d8                	sub    %ebx,%eax
  800d1d:	eb 11                	jmp    800d30 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800d1f:	83 e9 01             	sub    $0x1,%ecx
  800d22:	ba 00 00 00 00       	mov    $0x0,%edx
  800d27:	85 c9                	test   %ecx,%ecx
  800d29:	75 d6                	jne    800d01 <memcmp+0x1f>
  800d2b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800d3b:	89 c2                	mov    %eax,%edx
  800d3d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d40:	39 d0                	cmp    %edx,%eax
  800d42:	73 15                	jae    800d59 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d44:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800d48:	38 08                	cmp    %cl,(%eax)
  800d4a:	75 06                	jne    800d52 <memfind+0x1d>
  800d4c:	eb 0b                	jmp    800d59 <memfind+0x24>
  800d4e:	38 08                	cmp    %cl,(%eax)
  800d50:	74 07                	je     800d59 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800d52:	83 c0 01             	add    $0x1,%eax
  800d55:	39 c2                	cmp    %eax,%edx
  800d57:	77 f5                	ja     800d4e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	57                   	push   %edi
  800d5f:	56                   	push   %esi
  800d60:	53                   	push   %ebx
  800d61:	83 ec 04             	sub    $0x4,%esp
  800d64:	8b 55 08             	mov    0x8(%ebp),%edx
  800d67:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d6a:	0f b6 02             	movzbl (%edx),%eax
  800d6d:	3c 20                	cmp    $0x20,%al
  800d6f:	74 04                	je     800d75 <strtol+0x1a>
  800d71:	3c 09                	cmp    $0x9,%al
  800d73:	75 0e                	jne    800d83 <strtol+0x28>
		s++;
  800d75:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d78:	0f b6 02             	movzbl (%edx),%eax
  800d7b:	3c 20                	cmp    $0x20,%al
  800d7d:	74 f6                	je     800d75 <strtol+0x1a>
  800d7f:	3c 09                	cmp    $0x9,%al
  800d81:	74 f2                	je     800d75 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800d83:	3c 2b                	cmp    $0x2b,%al
  800d85:	75 0c                	jne    800d93 <strtol+0x38>
		s++;
  800d87:	83 c2 01             	add    $0x1,%edx
  800d8a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d91:	eb 15                	jmp    800da8 <strtol+0x4d>
	else if (*s == '-')
  800d93:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800d9a:	3c 2d                	cmp    $0x2d,%al
  800d9c:	75 0a                	jne    800da8 <strtol+0x4d>
		s++, neg = 1;
  800d9e:	83 c2 01             	add    $0x1,%edx
  800da1:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800da8:	85 db                	test   %ebx,%ebx
  800daa:	0f 94 c0             	sete   %al
  800dad:	74 05                	je     800db4 <strtol+0x59>
  800daf:	83 fb 10             	cmp    $0x10,%ebx
  800db2:	75 18                	jne    800dcc <strtol+0x71>
  800db4:	80 3a 30             	cmpb   $0x30,(%edx)
  800db7:	75 13                	jne    800dcc <strtol+0x71>
  800db9:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800dbd:	8d 76 00             	lea    0x0(%esi),%esi
  800dc0:	75 0a                	jne    800dcc <strtol+0x71>
		s += 2, base = 16;
  800dc2:	83 c2 02             	add    $0x2,%edx
  800dc5:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800dca:	eb 15                	jmp    800de1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800dcc:	84 c0                	test   %al,%al
  800dce:	66 90                	xchg   %ax,%ax
  800dd0:	74 0f                	je     800de1 <strtol+0x86>
  800dd2:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800dd7:	80 3a 30             	cmpb   $0x30,(%edx)
  800dda:	75 05                	jne    800de1 <strtol+0x86>
		s++, base = 8;
  800ddc:	83 c2 01             	add    $0x1,%edx
  800ddf:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800de1:	b8 00 00 00 00       	mov    $0x0,%eax
  800de6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800de8:	0f b6 0a             	movzbl (%edx),%ecx
  800deb:	89 cf                	mov    %ecx,%edi
  800ded:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800df0:	80 fb 09             	cmp    $0x9,%bl
  800df3:	77 08                	ja     800dfd <strtol+0xa2>
			dig = *s - '0';
  800df5:	0f be c9             	movsbl %cl,%ecx
  800df8:	83 e9 30             	sub    $0x30,%ecx
  800dfb:	eb 1e                	jmp    800e1b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800dfd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800e00:	80 fb 19             	cmp    $0x19,%bl
  800e03:	77 08                	ja     800e0d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800e05:	0f be c9             	movsbl %cl,%ecx
  800e08:	83 e9 57             	sub    $0x57,%ecx
  800e0b:	eb 0e                	jmp    800e1b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800e0d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800e10:	80 fb 19             	cmp    $0x19,%bl
  800e13:	77 15                	ja     800e2a <strtol+0xcf>
			dig = *s - 'A' + 10;
  800e15:	0f be c9             	movsbl %cl,%ecx
  800e18:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800e1b:	39 f1                	cmp    %esi,%ecx
  800e1d:	7d 0b                	jge    800e2a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800e1f:	83 c2 01             	add    $0x1,%edx
  800e22:	0f af c6             	imul   %esi,%eax
  800e25:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800e28:	eb be                	jmp    800de8 <strtol+0x8d>
  800e2a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800e2c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800e30:	74 05                	je     800e37 <strtol+0xdc>
		*endptr = (char *) s;
  800e32:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e35:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800e37:	89 ca                	mov    %ecx,%edx
  800e39:	f7 da                	neg    %edx
  800e3b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800e3f:	0f 45 c2             	cmovne %edx,%eax
}
  800e42:	83 c4 04             	add    $0x4,%esp
  800e45:	5b                   	pop    %ebx
  800e46:	5e                   	pop    %esi
  800e47:	5f                   	pop    %edi
  800e48:	5d                   	pop    %ebp
  800e49:	c3                   	ret    

00800e4a <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  800e4a:	55                   	push   %ebp
  800e4b:	89 e5                	mov    %esp,%ebp
  800e4d:	83 ec 0c             	sub    $0xc,%esp
  800e50:	89 1c 24             	mov    %ebx,(%esp)
  800e53:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e57:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e5b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e60:	b8 01 00 00 00       	mov    $0x1,%eax
  800e65:	89 d1                	mov    %edx,%ecx
  800e67:	89 d3                	mov    %edx,%ebx
  800e69:	89 d7                	mov    %edx,%edi
  800e6b:	89 d6                	mov    %edx,%esi
  800e6d:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800e6f:	8b 1c 24             	mov    (%esp),%ebx
  800e72:	8b 74 24 04          	mov    0x4(%esp),%esi
  800e76:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e7a:	89 ec                	mov    %ebp,%esp
  800e7c:	5d                   	pop    %ebp
  800e7d:	c3                   	ret    

00800e7e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800e7e:	55                   	push   %ebp
  800e7f:	89 e5                	mov    %esp,%ebp
  800e81:	83 ec 0c             	sub    $0xc,%esp
  800e84:	89 1c 24             	mov    %ebx,(%esp)
  800e87:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e8b:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800e94:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800e97:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9a:	89 c3                	mov    %eax,%ebx
  800e9c:	89 c7                	mov    %eax,%edi
  800e9e:	89 c6                	mov    %eax,%esi
  800ea0:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800ea2:	8b 1c 24             	mov    (%esp),%ebx
  800ea5:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ea9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800ead:	89 ec                	mov    %ebp,%esp
  800eaf:	5d                   	pop    %ebp
  800eb0:	c3                   	ret    

00800eb1 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800eb1:	55                   	push   %ebp
  800eb2:	89 e5                	mov    %esp,%ebp
  800eb4:	83 ec 38             	sub    $0x38,%esp
  800eb7:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800eba:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800ebd:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ec0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ec5:	b8 0c 00 00 00       	mov    $0xc,%eax
  800eca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecd:	89 cb                	mov    %ecx,%ebx
  800ecf:	89 cf                	mov    %ecx,%edi
  800ed1:	89 ce                	mov    %ecx,%esi
  800ed3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800ed5:	85 c0                	test   %eax,%eax
  800ed7:	7e 28                	jle    800f01 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800ed9:	89 44 24 10          	mov    %eax,0x10(%esp)
  800edd:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800ee4:	00 
  800ee5:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  800eec:	00 
  800eed:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800ef4:	00 
  800ef5:	c7 04 24 81 17 80 00 	movl   $0x801781,(%esp)
  800efc:	e8 b6 f3 ff ff       	call   8002b7 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800f01:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f04:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f07:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800f0a:	89 ec                	mov    %ebp,%esp
  800f0c:	5d                   	pop    %ebp
  800f0d:	c3                   	ret    

00800f0e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f0e:	55                   	push   %ebp
  800f0f:	89 e5                	mov    %esp,%ebp
  800f11:	83 ec 0c             	sub    $0xc,%esp
  800f14:	89 1c 24             	mov    %ebx,(%esp)
  800f17:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f1b:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f1f:	be 00 00 00 00       	mov    $0x0,%esi
  800f24:	b8 0b 00 00 00       	mov    $0xb,%eax
  800f29:	8b 7d 14             	mov    0x14(%ebp),%edi
  800f2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f2f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f32:	8b 55 08             	mov    0x8(%ebp),%edx
  800f35:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800f37:	8b 1c 24             	mov    (%esp),%ebx
  800f3a:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f3e:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800f42:	89 ec                	mov    %ebp,%esp
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    

00800f46 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	83 ec 38             	sub    $0x38,%esp
  800f4c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800f4f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800f52:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800f55:	bb 00 00 00 00       	mov    $0x0,%ebx
  800f5a:	b8 09 00 00 00       	mov    $0x9,%eax
  800f5f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f62:	8b 55 08             	mov    0x8(%ebp),%edx
  800f65:	89 df                	mov    %ebx,%edi
  800f67:	89 de                	mov    %ebx,%esi
  800f69:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	7e 28                	jle    800f97 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800f6f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800f73:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800f7a:	00 
  800f7b:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  800f82:	00 
  800f83:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800f8a:	00 
  800f8b:	c7 04 24 81 17 80 00 	movl   $0x801781,(%esp)
  800f92:	e8 20 f3 ff ff       	call   8002b7 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800f97:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800f9a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800f9d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800fa0:	89 ec                	mov    %ebp,%esp
  800fa2:	5d                   	pop    %ebp
  800fa3:	c3                   	ret    

00800fa4 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	83 ec 38             	sub    $0x38,%esp
  800faa:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800fad:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800fb0:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800fb3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800fb8:	b8 08 00 00 00       	mov    $0x8,%eax
  800fbd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800fc0:	8b 55 08             	mov    0x8(%ebp),%edx
  800fc3:	89 df                	mov    %ebx,%edi
  800fc5:	89 de                	mov    %ebx,%esi
  800fc7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	7e 28                	jle    800ff5 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800fcd:	89 44 24 10          	mov    %eax,0x10(%esp)
  800fd1:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800fd8:	00 
  800fd9:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  800fe0:	00 
  800fe1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800fe8:	00 
  800fe9:	c7 04 24 81 17 80 00 	movl   $0x801781,(%esp)
  800ff0:	e8 c2 f2 ff ff       	call   8002b7 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800ff5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800ff8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800ffb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800ffe:	89 ec                	mov    %ebp,%esp
  801000:	5d                   	pop    %ebp
  801001:	c3                   	ret    

00801002 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	83 ec 38             	sub    $0x38,%esp
  801008:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80100b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80100e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801011:	bb 00 00 00 00       	mov    $0x0,%ebx
  801016:	b8 06 00 00 00       	mov    $0x6,%eax
  80101b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80101e:	8b 55 08             	mov    0x8(%ebp),%edx
  801021:	89 df                	mov    %ebx,%edi
  801023:	89 de                	mov    %ebx,%esi
  801025:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801027:	85 c0                	test   %eax,%eax
  801029:	7e 28                	jle    801053 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80102b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80102f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801036:	00 
  801037:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  80103e:	00 
  80103f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801046:	00 
  801047:	c7 04 24 81 17 80 00 	movl   $0x801781,(%esp)
  80104e:	e8 64 f2 ff ff       	call   8002b7 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  801053:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801056:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801059:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80105c:	89 ec                	mov    %ebp,%esp
  80105e:	5d                   	pop    %ebp
  80105f:	c3                   	ret    

00801060 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801060:	55                   	push   %ebp
  801061:	89 e5                	mov    %esp,%ebp
  801063:	83 ec 38             	sub    $0x38,%esp
  801066:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801069:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80106c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80106f:	b8 05 00 00 00       	mov    $0x5,%eax
  801074:	8b 75 18             	mov    0x18(%ebp),%esi
  801077:	8b 7d 14             	mov    0x14(%ebp),%edi
  80107a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80107d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801080:	8b 55 08             	mov    0x8(%ebp),%edx
  801083:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801085:	85 c0                	test   %eax,%eax
  801087:	7e 28                	jle    8010b1 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  801089:	89 44 24 10          	mov    %eax,0x10(%esp)
  80108d:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  801094:	00 
  801095:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  80109c:	00 
  80109d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8010a4:	00 
  8010a5:	c7 04 24 81 17 80 00 	movl   $0x801781,(%esp)
  8010ac:	e8 06 f2 ff ff       	call   8002b7 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8010b1:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8010b4:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8010b7:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8010ba:	89 ec                	mov    %ebp,%esp
  8010bc:	5d                   	pop    %ebp
  8010bd:	c3                   	ret    

008010be <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8010be:	55                   	push   %ebp
  8010bf:	89 e5                	mov    %esp,%ebp
  8010c1:	83 ec 38             	sub    $0x38,%esp
  8010c4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8010c7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8010ca:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010cd:	be 00 00 00 00       	mov    $0x0,%esi
  8010d2:	b8 04 00 00 00       	mov    $0x4,%eax
  8010d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8010da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8010dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8010e0:	89 f7                	mov    %esi,%edi
  8010e2:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8010e4:	85 c0                	test   %eax,%eax
  8010e6:	7e 28                	jle    801110 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  8010e8:	89 44 24 10          	mov    %eax,0x10(%esp)
  8010ec:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  8010f3:	00 
  8010f4:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  8010fb:	00 
  8010fc:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801103:	00 
  801104:	c7 04 24 81 17 80 00 	movl   $0x801781,(%esp)
  80110b:	e8 a7 f1 ff ff       	call   8002b7 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801110:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801113:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801116:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801119:	89 ec                	mov    %ebp,%esp
  80111b:	5d                   	pop    %ebp
  80111c:	c3                   	ret    

0080111d <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  80111d:	55                   	push   %ebp
  80111e:	89 e5                	mov    %esp,%ebp
  801120:	83 ec 0c             	sub    $0xc,%esp
  801123:	89 1c 24             	mov    %ebx,(%esp)
  801126:	89 74 24 04          	mov    %esi,0x4(%esp)
  80112a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80112e:	ba 00 00 00 00       	mov    $0x0,%edx
  801133:	b8 0a 00 00 00       	mov    $0xa,%eax
  801138:	89 d1                	mov    %edx,%ecx
  80113a:	89 d3                	mov    %edx,%ebx
  80113c:	89 d7                	mov    %edx,%edi
  80113e:	89 d6                	mov    %edx,%esi
  801140:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  801142:	8b 1c 24             	mov    (%esp),%ebx
  801145:	8b 74 24 04          	mov    0x4(%esp),%esi
  801149:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80114d:	89 ec                	mov    %ebp,%esp
  80114f:	5d                   	pop    %ebp
  801150:	c3                   	ret    

00801151 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  801151:	55                   	push   %ebp
  801152:	89 e5                	mov    %esp,%ebp
  801154:	83 ec 0c             	sub    $0xc,%esp
  801157:	89 1c 24             	mov    %ebx,(%esp)
  80115a:	89 74 24 04          	mov    %esi,0x4(%esp)
  80115e:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801162:	ba 00 00 00 00       	mov    $0x0,%edx
  801167:	b8 02 00 00 00       	mov    $0x2,%eax
  80116c:	89 d1                	mov    %edx,%ecx
  80116e:	89 d3                	mov    %edx,%ebx
  801170:	89 d7                	mov    %edx,%edi
  801172:	89 d6                	mov    %edx,%esi
  801174:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  801176:	8b 1c 24             	mov    (%esp),%ebx
  801179:	8b 74 24 04          	mov    0x4(%esp),%esi
  80117d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801181:	89 ec                	mov    %ebp,%esp
  801183:	5d                   	pop    %ebp
  801184:	c3                   	ret    

00801185 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  801185:	55                   	push   %ebp
  801186:	89 e5                	mov    %esp,%ebp
  801188:	83 ec 38             	sub    $0x38,%esp
  80118b:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80118e:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801191:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801194:	b9 00 00 00 00       	mov    $0x0,%ecx
  801199:	b8 03 00 00 00       	mov    $0x3,%eax
  80119e:	8b 55 08             	mov    0x8(%ebp),%edx
  8011a1:	89 cb                	mov    %ecx,%ebx
  8011a3:	89 cf                	mov    %ecx,%edi
  8011a5:	89 ce                	mov    %ecx,%esi
  8011a7:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8011a9:	85 c0                	test   %eax,%eax
  8011ab:	7e 28                	jle    8011d5 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  8011ad:	89 44 24 10          	mov    %eax,0x10(%esp)
  8011b1:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  8011b8:	00 
  8011b9:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  8011c0:	00 
  8011c1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8011c8:	00 
  8011c9:	c7 04 24 81 17 80 00 	movl   $0x801781,(%esp)
  8011d0:	e8 e2 f0 ff ff       	call   8002b7 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  8011d5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8011d8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8011db:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8011de:	89 ec                	mov    %ebp,%esp
  8011e0:	5d                   	pop    %ebp
  8011e1:	c3                   	ret    
  8011e2:	66 90                	xchg   %ax,%ax
  8011e4:	66 90                	xchg   %ax,%ax
  8011e6:	66 90                	xchg   %ax,%ax
  8011e8:	66 90                	xchg   %ax,%ax
  8011ea:	66 90                	xchg   %ax,%ax
  8011ec:	66 90                	xchg   %ax,%ax
  8011ee:	66 90                	xchg   %ax,%ax

008011f0 <__udivdi3>:
  8011f0:	55                   	push   %ebp
  8011f1:	89 e5                	mov    %esp,%ebp
  8011f3:	57                   	push   %edi
  8011f4:	56                   	push   %esi
  8011f5:	83 ec 10             	sub    $0x10,%esp
  8011f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8011fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fe:	8b 75 10             	mov    0x10(%ebp),%esi
  801201:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801204:	85 c0                	test   %eax,%eax
  801206:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801209:	75 35                	jne    801240 <__udivdi3+0x50>
  80120b:	39 fe                	cmp    %edi,%esi
  80120d:	77 61                	ja     801270 <__udivdi3+0x80>
  80120f:	85 f6                	test   %esi,%esi
  801211:	75 0b                	jne    80121e <__udivdi3+0x2e>
  801213:	b8 01 00 00 00       	mov    $0x1,%eax
  801218:	31 d2                	xor    %edx,%edx
  80121a:	f7 f6                	div    %esi
  80121c:	89 c6                	mov    %eax,%esi
  80121e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801221:	31 d2                	xor    %edx,%edx
  801223:	89 f8                	mov    %edi,%eax
  801225:	f7 f6                	div    %esi
  801227:	89 c7                	mov    %eax,%edi
  801229:	89 c8                	mov    %ecx,%eax
  80122b:	f7 f6                	div    %esi
  80122d:	89 c1                	mov    %eax,%ecx
  80122f:	89 fa                	mov    %edi,%edx
  801231:	89 c8                	mov    %ecx,%eax
  801233:	83 c4 10             	add    $0x10,%esp
  801236:	5e                   	pop    %esi
  801237:	5f                   	pop    %edi
  801238:	5d                   	pop    %ebp
  801239:	c3                   	ret    
  80123a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801240:	39 f8                	cmp    %edi,%eax
  801242:	77 1c                	ja     801260 <__udivdi3+0x70>
  801244:	0f bd d0             	bsr    %eax,%edx
  801247:	83 f2 1f             	xor    $0x1f,%edx
  80124a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80124d:	75 39                	jne    801288 <__udivdi3+0x98>
  80124f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801252:	0f 86 a0 00 00 00    	jbe    8012f8 <__udivdi3+0x108>
  801258:	39 f8                	cmp    %edi,%eax
  80125a:	0f 82 98 00 00 00    	jb     8012f8 <__udivdi3+0x108>
  801260:	31 ff                	xor    %edi,%edi
  801262:	31 c9                	xor    %ecx,%ecx
  801264:	89 c8                	mov    %ecx,%eax
  801266:	89 fa                	mov    %edi,%edx
  801268:	83 c4 10             	add    $0x10,%esp
  80126b:	5e                   	pop    %esi
  80126c:	5f                   	pop    %edi
  80126d:	5d                   	pop    %ebp
  80126e:	c3                   	ret    
  80126f:	90                   	nop
  801270:	89 d1                	mov    %edx,%ecx
  801272:	89 fa                	mov    %edi,%edx
  801274:	89 c8                	mov    %ecx,%eax
  801276:	31 ff                	xor    %edi,%edi
  801278:	f7 f6                	div    %esi
  80127a:	89 c1                	mov    %eax,%ecx
  80127c:	89 fa                	mov    %edi,%edx
  80127e:	89 c8                	mov    %ecx,%eax
  801280:	83 c4 10             	add    $0x10,%esp
  801283:	5e                   	pop    %esi
  801284:	5f                   	pop    %edi
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    
  801287:	90                   	nop
  801288:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80128c:	89 f2                	mov    %esi,%edx
  80128e:	d3 e0                	shl    %cl,%eax
  801290:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801293:	b8 20 00 00 00       	mov    $0x20,%eax
  801298:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80129b:	89 c1                	mov    %eax,%ecx
  80129d:	d3 ea                	shr    %cl,%edx
  80129f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8012a3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8012a6:	d3 e6                	shl    %cl,%esi
  8012a8:	89 c1                	mov    %eax,%ecx
  8012aa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8012ad:	89 fe                	mov    %edi,%esi
  8012af:	d3 ee                	shr    %cl,%esi
  8012b1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8012b5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8012b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012bb:	d3 e7                	shl    %cl,%edi
  8012bd:	89 c1                	mov    %eax,%ecx
  8012bf:	d3 ea                	shr    %cl,%edx
  8012c1:	09 d7                	or     %edx,%edi
  8012c3:	89 f2                	mov    %esi,%edx
  8012c5:	89 f8                	mov    %edi,%eax
  8012c7:	f7 75 ec             	divl   -0x14(%ebp)
  8012ca:	89 d6                	mov    %edx,%esi
  8012cc:	89 c7                	mov    %eax,%edi
  8012ce:	f7 65 e8             	mull   -0x18(%ebp)
  8012d1:	39 d6                	cmp    %edx,%esi
  8012d3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8012d6:	72 30                	jb     801308 <__udivdi3+0x118>
  8012d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8012db:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8012df:	d3 e2                	shl    %cl,%edx
  8012e1:	39 c2                	cmp    %eax,%edx
  8012e3:	73 05                	jae    8012ea <__udivdi3+0xfa>
  8012e5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8012e8:	74 1e                	je     801308 <__udivdi3+0x118>
  8012ea:	89 f9                	mov    %edi,%ecx
  8012ec:	31 ff                	xor    %edi,%edi
  8012ee:	e9 71 ff ff ff       	jmp    801264 <__udivdi3+0x74>
  8012f3:	90                   	nop
  8012f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012f8:	31 ff                	xor    %edi,%edi
  8012fa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8012ff:	e9 60 ff ff ff       	jmp    801264 <__udivdi3+0x74>
  801304:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801308:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80130b:	31 ff                	xor    %edi,%edi
  80130d:	89 c8                	mov    %ecx,%eax
  80130f:	89 fa                	mov    %edi,%edx
  801311:	83 c4 10             	add    $0x10,%esp
  801314:	5e                   	pop    %esi
  801315:	5f                   	pop    %edi
  801316:	5d                   	pop    %ebp
  801317:	c3                   	ret    
  801318:	66 90                	xchg   %ax,%ax
  80131a:	66 90                	xchg   %ax,%ax
  80131c:	66 90                	xchg   %ax,%ax
  80131e:	66 90                	xchg   %ax,%ax

00801320 <__umoddi3>:
  801320:	55                   	push   %ebp
  801321:	89 e5                	mov    %esp,%ebp
  801323:	57                   	push   %edi
  801324:	56                   	push   %esi
  801325:	83 ec 20             	sub    $0x20,%esp
  801328:	8b 55 14             	mov    0x14(%ebp),%edx
  80132b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80132e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801331:	8b 75 0c             	mov    0xc(%ebp),%esi
  801334:	85 d2                	test   %edx,%edx
  801336:	89 c8                	mov    %ecx,%eax
  801338:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80133b:	75 13                	jne    801350 <__umoddi3+0x30>
  80133d:	39 f7                	cmp    %esi,%edi
  80133f:	76 3f                	jbe    801380 <__umoddi3+0x60>
  801341:	89 f2                	mov    %esi,%edx
  801343:	f7 f7                	div    %edi
  801345:	89 d0                	mov    %edx,%eax
  801347:	31 d2                	xor    %edx,%edx
  801349:	83 c4 20             	add    $0x20,%esp
  80134c:	5e                   	pop    %esi
  80134d:	5f                   	pop    %edi
  80134e:	5d                   	pop    %ebp
  80134f:	c3                   	ret    
  801350:	39 f2                	cmp    %esi,%edx
  801352:	77 4c                	ja     8013a0 <__umoddi3+0x80>
  801354:	0f bd ca             	bsr    %edx,%ecx
  801357:	83 f1 1f             	xor    $0x1f,%ecx
  80135a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80135d:	75 51                	jne    8013b0 <__umoddi3+0x90>
  80135f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801362:	0f 87 e0 00 00 00    	ja     801448 <__umoddi3+0x128>
  801368:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80136b:	29 f8                	sub    %edi,%eax
  80136d:	19 d6                	sbb    %edx,%esi
  80136f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801372:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801375:	89 f2                	mov    %esi,%edx
  801377:	83 c4 20             	add    $0x20,%esp
  80137a:	5e                   	pop    %esi
  80137b:	5f                   	pop    %edi
  80137c:	5d                   	pop    %ebp
  80137d:	c3                   	ret    
  80137e:	66 90                	xchg   %ax,%ax
  801380:	85 ff                	test   %edi,%edi
  801382:	75 0b                	jne    80138f <__umoddi3+0x6f>
  801384:	b8 01 00 00 00       	mov    $0x1,%eax
  801389:	31 d2                	xor    %edx,%edx
  80138b:	f7 f7                	div    %edi
  80138d:	89 c7                	mov    %eax,%edi
  80138f:	89 f0                	mov    %esi,%eax
  801391:	31 d2                	xor    %edx,%edx
  801393:	f7 f7                	div    %edi
  801395:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801398:	f7 f7                	div    %edi
  80139a:	eb a9                	jmp    801345 <__umoddi3+0x25>
  80139c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013a0:	89 c8                	mov    %ecx,%eax
  8013a2:	89 f2                	mov    %esi,%edx
  8013a4:	83 c4 20             	add    $0x20,%esp
  8013a7:	5e                   	pop    %esi
  8013a8:	5f                   	pop    %edi
  8013a9:	5d                   	pop    %ebp
  8013aa:	c3                   	ret    
  8013ab:	90                   	nop
  8013ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013b0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013b4:	d3 e2                	shl    %cl,%edx
  8013b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8013b9:	ba 20 00 00 00       	mov    $0x20,%edx
  8013be:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8013c1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8013c4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8013c8:	89 fa                	mov    %edi,%edx
  8013ca:	d3 ea                	shr    %cl,%edx
  8013cc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013d0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8013d3:	d3 e7                	shl    %cl,%edi
  8013d5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8013d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8013dc:	89 f2                	mov    %esi,%edx
  8013de:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8013e1:	89 c7                	mov    %eax,%edi
  8013e3:	d3 ea                	shr    %cl,%edx
  8013e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8013ec:	89 c2                	mov    %eax,%edx
  8013ee:	d3 e6                	shl    %cl,%esi
  8013f0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8013f4:	d3 ea                	shr    %cl,%edx
  8013f6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8013fa:	09 d6                	or     %edx,%esi
  8013fc:	89 f0                	mov    %esi,%eax
  8013fe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801401:	d3 e7                	shl    %cl,%edi
  801403:	89 f2                	mov    %esi,%edx
  801405:	f7 75 f4             	divl   -0xc(%ebp)
  801408:	89 d6                	mov    %edx,%esi
  80140a:	f7 65 e8             	mull   -0x18(%ebp)
  80140d:	39 d6                	cmp    %edx,%esi
  80140f:	72 2b                	jb     80143c <__umoddi3+0x11c>
  801411:	39 c7                	cmp    %eax,%edi
  801413:	72 23                	jb     801438 <__umoddi3+0x118>
  801415:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801419:	29 c7                	sub    %eax,%edi
  80141b:	19 d6                	sbb    %edx,%esi
  80141d:	89 f0                	mov    %esi,%eax
  80141f:	89 f2                	mov    %esi,%edx
  801421:	d3 ef                	shr    %cl,%edi
  801423:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801427:	d3 e0                	shl    %cl,%eax
  801429:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80142d:	09 f8                	or     %edi,%eax
  80142f:	d3 ea                	shr    %cl,%edx
  801431:	83 c4 20             	add    $0x20,%esp
  801434:	5e                   	pop    %esi
  801435:	5f                   	pop    %edi
  801436:	5d                   	pop    %ebp
  801437:	c3                   	ret    
  801438:	39 d6                	cmp    %edx,%esi
  80143a:	75 d9                	jne    801415 <__umoddi3+0xf5>
  80143c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80143f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801442:	eb d1                	jmp    801415 <__umoddi3+0xf5>
  801444:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801448:	39 f2                	cmp    %esi,%edx
  80144a:	0f 82 18 ff ff ff    	jb     801368 <__umoddi3+0x48>
  801450:	e9 1d ff ff ff       	jmp    801372 <__umoddi3+0x52>
