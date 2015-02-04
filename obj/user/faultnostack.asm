
obj/user/faultnostack：     文件格式 elf32-i386


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
  80002c:	e8 28 00 00 00       	call   800059 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	c7 44 24 04 5e 04 80 	movl   $0x80045e,0x4(%esp)
  800040:	00 
  800041:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800048:	e8 75 01 00 00       	call   8001c2 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004d:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800054:	00 00 00 
}
  800057:	c9                   	leave  
  800058:	c3                   	ret    

00800059 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800059:	55                   	push   %ebp
  80005a:	89 e5                	mov    %esp,%ebp
  80005c:	83 ec 18             	sub    $0x18,%esp
  80005f:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800062:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800065:	8b 75 08             	mov    0x8(%ebp),%esi
  800068:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80006b:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800072:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800075:	e8 53 03 00 00       	call   8003cd <sys_getenvid>
  80007a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800082:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800087:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80008c:	85 f6                	test   %esi,%esi
  80008e:	7e 07                	jle    800097 <libmain+0x3e>
		binaryname = argv[0];
  800090:	8b 03                	mov    (%ebx),%eax
  800092:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800097:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80009b:	89 34 24             	mov    %esi,(%esp)
  80009e:	e8 90 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a3:	e8 0a 00 00 00       	call   8000b2 <exit>
}
  8000a8:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000ab:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000ae:	89 ec                	mov    %ebp,%esp
  8000b0:	5d                   	pop    %ebp
  8000b1:	c3                   	ret    

008000b2 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b2:	55                   	push   %ebp
  8000b3:	89 e5                	mov    %esp,%ebp
  8000b5:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000b8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000bf:	e8 3d 03 00 00       	call   800401 <sys_env_destroy>
}
  8000c4:	c9                   	leave  
  8000c5:	c3                   	ret    

008000c6 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000c6:	55                   	push   %ebp
  8000c7:	89 e5                	mov    %esp,%ebp
  8000c9:	83 ec 0c             	sub    $0xc,%esp
  8000cc:	89 1c 24             	mov    %ebx,(%esp)
  8000cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000d3:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8000dc:	b8 01 00 00 00       	mov    $0x1,%eax
  8000e1:	89 d1                	mov    %edx,%ecx
  8000e3:	89 d3                	mov    %edx,%ebx
  8000e5:	89 d7                	mov    %edx,%edi
  8000e7:	89 d6                	mov    %edx,%esi
  8000e9:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000eb:	8b 1c 24             	mov    (%esp),%ebx
  8000ee:	8b 74 24 04          	mov    0x4(%esp),%esi
  8000f2:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8000f6:	89 ec                	mov    %ebp,%esp
  8000f8:	5d                   	pop    %ebp
  8000f9:	c3                   	ret    

008000fa <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000fa:	55                   	push   %ebp
  8000fb:	89 e5                	mov    %esp,%ebp
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	89 1c 24             	mov    %ebx,(%esp)
  800103:	89 74 24 04          	mov    %esi,0x4(%esp)
  800107:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80010b:	b8 00 00 00 00       	mov    $0x0,%eax
  800110:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800113:	8b 55 08             	mov    0x8(%ebp),%edx
  800116:	89 c3                	mov    %eax,%ebx
  800118:	89 c7                	mov    %eax,%edi
  80011a:	89 c6                	mov    %eax,%esi
  80011c:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80011e:	8b 1c 24             	mov    (%esp),%ebx
  800121:	8b 74 24 04          	mov    0x4(%esp),%esi
  800125:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800129:	89 ec                	mov    %ebp,%esp
  80012b:	5d                   	pop    %ebp
  80012c:	c3                   	ret    

0080012d <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	83 ec 38             	sub    $0x38,%esp
  800133:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800136:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800139:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80013c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800141:	b8 0c 00 00 00       	mov    $0xc,%eax
  800146:	8b 55 08             	mov    0x8(%ebp),%edx
  800149:	89 cb                	mov    %ecx,%ebx
  80014b:	89 cf                	mov    %ecx,%edi
  80014d:	89 ce                	mov    %ecx,%esi
  80014f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800151:	85 c0                	test   %eax,%eax
  800153:	7e 28                	jle    80017d <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800155:	89 44 24 10          	mov    %eax,0x10(%esp)
  800159:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800160:	00 
  800161:	c7 44 24 08 aa 12 80 	movl   $0x8012aa,0x8(%esp)
  800168:	00 
  800169:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800170:	00 
  800171:	c7 04 24 c7 12 80 00 	movl   $0x8012c7,(%esp)
  800178:	e8 ec 02 00 00       	call   800469 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80017d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800180:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800183:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800186:	89 ec                	mov    %ebp,%esp
  800188:	5d                   	pop    %ebp
  800189:	c3                   	ret    

0080018a <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	83 ec 0c             	sub    $0xc,%esp
  800190:	89 1c 24             	mov    %ebx,(%esp)
  800193:	89 74 24 04          	mov    %esi,0x4(%esp)
  800197:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80019b:	be 00 00 00 00       	mov    $0x0,%esi
  8001a0:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001a5:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001a8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8001b3:	8b 1c 24             	mov    (%esp),%ebx
  8001b6:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001ba:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001be:	89 ec                	mov    %ebp,%esp
  8001c0:	5d                   	pop    %ebp
  8001c1:	c3                   	ret    

008001c2 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8001c2:	55                   	push   %ebp
  8001c3:	89 e5                	mov    %esp,%ebp
  8001c5:	83 ec 38             	sub    $0x38,%esp
  8001c8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001cb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001ce:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001d1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001d6:	b8 09 00 00 00       	mov    $0x9,%eax
  8001db:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001de:	8b 55 08             	mov    0x8(%ebp),%edx
  8001e1:	89 df                	mov    %ebx,%edi
  8001e3:	89 de                	mov    %ebx,%esi
  8001e5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001e7:	85 c0                	test   %eax,%eax
  8001e9:	7e 28                	jle    800213 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001ef:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8001f6:	00 
  8001f7:	c7 44 24 08 aa 12 80 	movl   $0x8012aa,0x8(%esp)
  8001fe:	00 
  8001ff:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800206:	00 
  800207:	c7 04 24 c7 12 80 00 	movl   $0x8012c7,(%esp)
  80020e:	e8 56 02 00 00       	call   800469 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800213:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800216:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800219:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80021c:	89 ec                	mov    %ebp,%esp
  80021e:	5d                   	pop    %ebp
  80021f:	c3                   	ret    

00800220 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	83 ec 38             	sub    $0x38,%esp
  800226:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800229:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80022c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80022f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800234:	b8 08 00 00 00       	mov    $0x8,%eax
  800239:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023c:	8b 55 08             	mov    0x8(%ebp),%edx
  80023f:	89 df                	mov    %ebx,%edi
  800241:	89 de                	mov    %ebx,%esi
  800243:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800245:	85 c0                	test   %eax,%eax
  800247:	7e 28                	jle    800271 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800249:	89 44 24 10          	mov    %eax,0x10(%esp)
  80024d:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800254:	00 
  800255:	c7 44 24 08 aa 12 80 	movl   $0x8012aa,0x8(%esp)
  80025c:	00 
  80025d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800264:	00 
  800265:	c7 04 24 c7 12 80 00 	movl   $0x8012c7,(%esp)
  80026c:	e8 f8 01 00 00       	call   800469 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800271:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800274:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800277:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80027a:	89 ec                	mov    %ebp,%esp
  80027c:	5d                   	pop    %ebp
  80027d:	c3                   	ret    

0080027e <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80027e:	55                   	push   %ebp
  80027f:	89 e5                	mov    %esp,%ebp
  800281:	83 ec 38             	sub    $0x38,%esp
  800284:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800287:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80028a:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80028d:	bb 00 00 00 00       	mov    $0x0,%ebx
  800292:	b8 06 00 00 00       	mov    $0x6,%eax
  800297:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80029a:	8b 55 08             	mov    0x8(%ebp),%edx
  80029d:	89 df                	mov    %ebx,%edi
  80029f:	89 de                	mov    %ebx,%esi
  8002a1:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002a3:	85 c0                	test   %eax,%eax
  8002a5:	7e 28                	jle    8002cf <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002a7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ab:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002b2:	00 
  8002b3:	c7 44 24 08 aa 12 80 	movl   $0x8012aa,0x8(%esp)
  8002ba:	00 
  8002bb:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002c2:	00 
  8002c3:	c7 04 24 c7 12 80 00 	movl   $0x8012c7,(%esp)
  8002ca:	e8 9a 01 00 00       	call   800469 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002cf:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002d2:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002d5:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002d8:	89 ec                	mov    %ebp,%esp
  8002da:	5d                   	pop    %ebp
  8002db:	c3                   	ret    

008002dc <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8002dc:	55                   	push   %ebp
  8002dd:	89 e5                	mov    %esp,%ebp
  8002df:	83 ec 38             	sub    $0x38,%esp
  8002e2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002e5:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002e8:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002eb:	b8 05 00 00 00       	mov    $0x5,%eax
  8002f0:	8b 75 18             	mov    0x18(%ebp),%esi
  8002f3:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002f6:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ff:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800301:	85 c0                	test   %eax,%eax
  800303:	7e 28                	jle    80032d <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800305:	89 44 24 10          	mov    %eax,0x10(%esp)
  800309:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800310:	00 
  800311:	c7 44 24 08 aa 12 80 	movl   $0x8012aa,0x8(%esp)
  800318:	00 
  800319:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800320:	00 
  800321:	c7 04 24 c7 12 80 00 	movl   $0x8012c7,(%esp)
  800328:	e8 3c 01 00 00       	call   800469 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80032d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800330:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800333:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800336:	89 ec                	mov    %ebp,%esp
  800338:	5d                   	pop    %ebp
  800339:	c3                   	ret    

0080033a <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80033a:	55                   	push   %ebp
  80033b:	89 e5                	mov    %esp,%ebp
  80033d:	83 ec 38             	sub    $0x38,%esp
  800340:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800343:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800346:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800349:	be 00 00 00 00       	mov    $0x0,%esi
  80034e:	b8 04 00 00 00       	mov    $0x4,%eax
  800353:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800356:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800359:	8b 55 08             	mov    0x8(%ebp),%edx
  80035c:	89 f7                	mov    %esi,%edi
  80035e:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800360:	85 c0                	test   %eax,%eax
  800362:	7e 28                	jle    80038c <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800364:	89 44 24 10          	mov    %eax,0x10(%esp)
  800368:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80036f:	00 
  800370:	c7 44 24 08 aa 12 80 	movl   $0x8012aa,0x8(%esp)
  800377:	00 
  800378:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80037f:	00 
  800380:	c7 04 24 c7 12 80 00 	movl   $0x8012c7,(%esp)
  800387:	e8 dd 00 00 00       	call   800469 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80038c:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80038f:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800392:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800395:	89 ec                	mov    %ebp,%esp
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	83 ec 0c             	sub    $0xc,%esp
  80039f:	89 1c 24             	mov    %ebx,(%esp)
  8003a2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003a6:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8003af:	b8 0a 00 00 00       	mov    $0xa,%eax
  8003b4:	89 d1                	mov    %edx,%ecx
  8003b6:	89 d3                	mov    %edx,%ebx
  8003b8:	89 d7                	mov    %edx,%edi
  8003ba:	89 d6                	mov    %edx,%esi
  8003bc:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8003be:	8b 1c 24             	mov    (%esp),%ebx
  8003c1:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003c5:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8003c9:	89 ec                	mov    %ebp,%esp
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8003cd:	55                   	push   %ebp
  8003ce:	89 e5                	mov    %esp,%ebp
  8003d0:	83 ec 0c             	sub    $0xc,%esp
  8003d3:	89 1c 24             	mov    %ebx,(%esp)
  8003d6:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003da:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003de:	ba 00 00 00 00       	mov    $0x0,%edx
  8003e3:	b8 02 00 00 00       	mov    $0x2,%eax
  8003e8:	89 d1                	mov    %edx,%ecx
  8003ea:	89 d3                	mov    %edx,%ebx
  8003ec:	89 d7                	mov    %edx,%edi
  8003ee:	89 d6                	mov    %edx,%esi
  8003f0:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8003f2:	8b 1c 24             	mov    (%esp),%ebx
  8003f5:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003f9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8003fd:	89 ec                	mov    %ebp,%esp
  8003ff:	5d                   	pop    %ebp
  800400:	c3                   	ret    

00800401 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  800401:	55                   	push   %ebp
  800402:	89 e5                	mov    %esp,%ebp
  800404:	83 ec 38             	sub    $0x38,%esp
  800407:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80040a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80040d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800410:	b9 00 00 00 00       	mov    $0x0,%ecx
  800415:	b8 03 00 00 00       	mov    $0x3,%eax
  80041a:	8b 55 08             	mov    0x8(%ebp),%edx
  80041d:	89 cb                	mov    %ecx,%ebx
  80041f:	89 cf                	mov    %ecx,%edi
  800421:	89 ce                	mov    %ecx,%esi
  800423:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800425:	85 c0                	test   %eax,%eax
  800427:	7e 28                	jle    800451 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800429:	89 44 24 10          	mov    %eax,0x10(%esp)
  80042d:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800434:	00 
  800435:	c7 44 24 08 aa 12 80 	movl   $0x8012aa,0x8(%esp)
  80043c:	00 
  80043d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800444:	00 
  800445:	c7 04 24 c7 12 80 00 	movl   $0x8012c7,(%esp)
  80044c:	e8 18 00 00 00       	call   800469 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800451:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800454:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800457:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80045a:	89 ec                	mov    %ebp,%esp
  80045c:	5d                   	pop    %ebp
  80045d:	c3                   	ret    

0080045e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80045e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80045f:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800464:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800466:	83 c4 04             	add    $0x4,%esp

00800469 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800469:	55                   	push   %ebp
  80046a:	89 e5                	mov    %esp,%ebp
  80046c:	56                   	push   %esi
  80046d:	53                   	push   %ebx
  80046e:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800471:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800474:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80047a:	e8 4e ff ff ff       	call   8003cd <sys_getenvid>
  80047f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800482:	89 54 24 10          	mov    %edx,0x10(%esp)
  800486:	8b 55 08             	mov    0x8(%ebp),%edx
  800489:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80048d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800491:	89 44 24 04          	mov    %eax,0x4(%esp)
  800495:	c7 04 24 d8 12 80 00 	movl   $0x8012d8,(%esp)
  80049c:	e8 7f 00 00 00       	call   800520 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004a1:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004a5:	8b 45 10             	mov    0x10(%ebp),%eax
  8004a8:	89 04 24             	mov    %eax,(%esp)
  8004ab:	e8 0f 00 00 00       	call   8004bf <vcprintf>
	cprintf("\n");
  8004b0:	c7 04 24 fb 12 80 00 	movl   $0x8012fb,(%esp)
  8004b7:	e8 64 00 00 00       	call   800520 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004bc:	cc                   	int3   
  8004bd:	eb fd                	jmp    8004bc <_panic+0x53>

008004bf <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8004bf:	55                   	push   %ebp
  8004c0:	89 e5                	mov    %esp,%ebp
  8004c2:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004c8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004cf:	00 00 00 
	b.cnt = 0;
  8004d2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004d9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004dc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004df:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8004e6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004ea:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004f0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f4:	c7 04 24 3a 05 80 00 	movl   $0x80053a,(%esp)
  8004fb:	e8 cd 01 00 00       	call   8006cd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800500:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800506:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800510:	89 04 24             	mov    %eax,(%esp)
  800513:	e8 e2 fb ff ff       	call   8000fa <sys_cputs>

	return b.cnt;
}
  800518:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80051e:	c9                   	leave  
  80051f:	c3                   	ret    

00800520 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800520:	55                   	push   %ebp
  800521:	89 e5                	mov    %esp,%ebp
  800523:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800526:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800529:	89 44 24 04          	mov    %eax,0x4(%esp)
  80052d:	8b 45 08             	mov    0x8(%ebp),%eax
  800530:	89 04 24             	mov    %eax,(%esp)
  800533:	e8 87 ff ff ff       	call   8004bf <vcprintf>
	va_end(ap);

	return cnt;
}
  800538:	c9                   	leave  
  800539:	c3                   	ret    

0080053a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80053a:	55                   	push   %ebp
  80053b:	89 e5                	mov    %esp,%ebp
  80053d:	53                   	push   %ebx
  80053e:	83 ec 14             	sub    $0x14,%esp
  800541:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800544:	8b 03                	mov    (%ebx),%eax
  800546:	8b 55 08             	mov    0x8(%ebp),%edx
  800549:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80054d:	83 c0 01             	add    $0x1,%eax
  800550:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800552:	3d ff 00 00 00       	cmp    $0xff,%eax
  800557:	75 19                	jne    800572 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800559:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800560:	00 
  800561:	8d 43 08             	lea    0x8(%ebx),%eax
  800564:	89 04 24             	mov    %eax,(%esp)
  800567:	e8 8e fb ff ff       	call   8000fa <sys_cputs>
		b->idx = 0;
  80056c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800572:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800576:	83 c4 14             	add    $0x14,%esp
  800579:	5b                   	pop    %ebx
  80057a:	5d                   	pop    %ebp
  80057b:	c3                   	ret    
  80057c:	66 90                	xchg   %ax,%ax
  80057e:	66 90                	xchg   %ax,%ax

00800580 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800580:	55                   	push   %ebp
  800581:	89 e5                	mov    %esp,%ebp
  800583:	57                   	push   %edi
  800584:	56                   	push   %esi
  800585:	53                   	push   %ebx
  800586:	83 ec 4c             	sub    $0x4c,%esp
  800589:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80058c:	89 d6                	mov    %edx,%esi
  80058e:	8b 45 08             	mov    0x8(%ebp),%eax
  800591:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800594:	8b 55 0c             	mov    0xc(%ebp),%edx
  800597:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80059a:	8b 45 10             	mov    0x10(%ebp),%eax
  80059d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8005a0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005a6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005ab:	39 d1                	cmp    %edx,%ecx
  8005ad:	72 15                	jb     8005c4 <printnum+0x44>
  8005af:	77 07                	ja     8005b8 <printnum+0x38>
  8005b1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005b4:	39 d0                	cmp    %edx,%eax
  8005b6:	76 0c                	jbe    8005c4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005b8:	83 eb 01             	sub    $0x1,%ebx
  8005bb:	85 db                	test   %ebx,%ebx
  8005bd:	8d 76 00             	lea    0x0(%esi),%esi
  8005c0:	7f 61                	jg     800623 <printnum+0xa3>
  8005c2:	eb 70                	jmp    800634 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005c4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8005c8:	83 eb 01             	sub    $0x1,%ebx
  8005cb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005cf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005d3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8005d7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8005db:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8005de:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8005e1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005e4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005ef:	00 
  8005f0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005f3:	89 04 24             	mov    %eax,(%esp)
  8005f6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005f9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005fd:	e8 2e 0a 00 00       	call   801030 <__udivdi3>
  800602:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800605:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800608:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80060c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800610:	89 04 24             	mov    %eax,(%esp)
  800613:	89 54 24 04          	mov    %edx,0x4(%esp)
  800617:	89 f2                	mov    %esi,%edx
  800619:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80061c:	e8 5f ff ff ff       	call   800580 <printnum>
  800621:	eb 11                	jmp    800634 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800623:	89 74 24 04          	mov    %esi,0x4(%esp)
  800627:	89 3c 24             	mov    %edi,(%esp)
  80062a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80062d:	83 eb 01             	sub    $0x1,%ebx
  800630:	85 db                	test   %ebx,%ebx
  800632:	7f ef                	jg     800623 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800634:	89 74 24 04          	mov    %esi,0x4(%esp)
  800638:	8b 74 24 04          	mov    0x4(%esp),%esi
  80063c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80063f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800643:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80064a:	00 
  80064b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80064e:	89 14 24             	mov    %edx,(%esp)
  800651:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800654:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800658:	e8 03 0b 00 00       	call   801160 <__umoddi3>
  80065d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800661:	0f be 80 fd 12 80 00 	movsbl 0x8012fd(%eax),%eax
  800668:	89 04 24             	mov    %eax,(%esp)
  80066b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80066e:	83 c4 4c             	add    $0x4c,%esp
  800671:	5b                   	pop    %ebx
  800672:	5e                   	pop    %esi
  800673:	5f                   	pop    %edi
  800674:	5d                   	pop    %ebp
  800675:	c3                   	ret    

00800676 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800676:	55                   	push   %ebp
  800677:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800679:	83 fa 01             	cmp    $0x1,%edx
  80067c:	7e 0e                	jle    80068c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80067e:	8b 10                	mov    (%eax),%edx
  800680:	8d 4a 08             	lea    0x8(%edx),%ecx
  800683:	89 08                	mov    %ecx,(%eax)
  800685:	8b 02                	mov    (%edx),%eax
  800687:	8b 52 04             	mov    0x4(%edx),%edx
  80068a:	eb 22                	jmp    8006ae <getuint+0x38>
	else if (lflag)
  80068c:	85 d2                	test   %edx,%edx
  80068e:	74 10                	je     8006a0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800690:	8b 10                	mov    (%eax),%edx
  800692:	8d 4a 04             	lea    0x4(%edx),%ecx
  800695:	89 08                	mov    %ecx,(%eax)
  800697:	8b 02                	mov    (%edx),%eax
  800699:	ba 00 00 00 00       	mov    $0x0,%edx
  80069e:	eb 0e                	jmp    8006ae <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006a0:	8b 10                	mov    (%eax),%edx
  8006a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006a5:	89 08                	mov    %ecx,(%eax)
  8006a7:	8b 02                	mov    (%edx),%eax
  8006a9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006ae:	5d                   	pop    %ebp
  8006af:	c3                   	ret    

008006b0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006b0:	55                   	push   %ebp
  8006b1:	89 e5                	mov    %esp,%ebp
  8006b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006b6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006ba:	8b 10                	mov    (%eax),%edx
  8006bc:	3b 50 04             	cmp    0x4(%eax),%edx
  8006bf:	73 0a                	jae    8006cb <sprintputch+0x1b>
		*b->buf++ = ch;
  8006c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006c4:	88 0a                	mov    %cl,(%edx)
  8006c6:	83 c2 01             	add    $0x1,%edx
  8006c9:	89 10                	mov    %edx,(%eax)
}
  8006cb:	5d                   	pop    %ebp
  8006cc:	c3                   	ret    

008006cd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006cd:	55                   	push   %ebp
  8006ce:	89 e5                	mov    %esp,%ebp
  8006d0:	57                   	push   %edi
  8006d1:	56                   	push   %esi
  8006d2:	53                   	push   %ebx
  8006d3:	83 ec 5c             	sub    $0x5c,%esp
  8006d6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8006dc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8006df:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8006e6:	eb 11                	jmp    8006f9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	0f 84 16 04 00 00    	je     800b06 <vprintfmt+0x439>
				return;
			putch(ch, putdat);
  8006f0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006f4:	89 04 24             	mov    %eax,(%esp)
  8006f7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f9:	0f b6 03             	movzbl (%ebx),%eax
  8006fc:	83 c3 01             	add    $0x1,%ebx
  8006ff:	83 f8 25             	cmp    $0x25,%eax
  800702:	75 e4                	jne    8006e8 <vprintfmt+0x1b>
  800704:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80070b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800712:	b9 00 00 00 00       	mov    $0x0,%ecx
  800717:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80071b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800722:	eb 06                	jmp    80072a <vprintfmt+0x5d>
  800724:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800728:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072a:	0f b6 13             	movzbl (%ebx),%edx
  80072d:	0f b6 c2             	movzbl %dl,%eax
  800730:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800733:	8d 43 01             	lea    0x1(%ebx),%eax
  800736:	83 ea 23             	sub    $0x23,%edx
  800739:	80 fa 55             	cmp    $0x55,%dl
  80073c:	0f 87 a7 03 00 00    	ja     800ae9 <vprintfmt+0x41c>
  800742:	0f b6 d2             	movzbl %dl,%edx
  800745:	ff 24 95 c0 13 80 00 	jmp    *0x8013c0(,%edx,4)
  80074c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800750:	eb d6                	jmp    800728 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800752:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800755:	83 ea 30             	sub    $0x30,%edx
  800758:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80075b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80075e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800761:	83 fb 09             	cmp    $0x9,%ebx
  800764:	77 54                	ja     8007ba <vprintfmt+0xed>
  800766:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800769:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80076c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80076f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800772:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800776:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800779:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80077c:	83 fb 09             	cmp    $0x9,%ebx
  80077f:	76 eb                	jbe    80076c <vprintfmt+0x9f>
  800781:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800784:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800787:	eb 31                	jmp    8007ba <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800789:	8b 55 14             	mov    0x14(%ebp),%edx
  80078c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80078f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800792:	8b 12                	mov    (%edx),%edx
  800794:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800797:	eb 21                	jmp    8007ba <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800799:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80079d:	ba 00 00 00 00       	mov    $0x0,%edx
  8007a2:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  8007a6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007a9:	e9 7a ff ff ff       	jmp    800728 <vprintfmt+0x5b>
  8007ae:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8007b5:	e9 6e ff ff ff       	jmp    800728 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8007ba:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007be:	0f 89 64 ff ff ff    	jns    800728 <vprintfmt+0x5b>
  8007c4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007c7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007ca:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8007cd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007d0:	e9 53 ff ff ff       	jmp    800728 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007d5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8007d8:	e9 4b ff ff ff       	jmp    800728 <vprintfmt+0x5b>
  8007dd:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e3:	8d 50 04             	lea    0x4(%eax),%edx
  8007e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007ed:	8b 00                	mov    (%eax),%eax
  8007ef:	89 04 24             	mov    %eax,(%esp)
  8007f2:	ff d7                	call   *%edi
  8007f4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8007f7:	e9 fd fe ff ff       	jmp    8006f9 <vprintfmt+0x2c>
  8007fc:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007ff:	8b 45 14             	mov    0x14(%ebp),%eax
  800802:	8d 50 04             	lea    0x4(%eax),%edx
  800805:	89 55 14             	mov    %edx,0x14(%ebp)
  800808:	8b 00                	mov    (%eax),%eax
  80080a:	89 c2                	mov    %eax,%edx
  80080c:	c1 fa 1f             	sar    $0x1f,%edx
  80080f:	31 d0                	xor    %edx,%eax
  800811:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800813:	83 f8 08             	cmp    $0x8,%eax
  800816:	7f 0b                	jg     800823 <vprintfmt+0x156>
  800818:	8b 14 85 20 15 80 00 	mov    0x801520(,%eax,4),%edx
  80081f:	85 d2                	test   %edx,%edx
  800821:	75 20                	jne    800843 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800823:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800827:	c7 44 24 08 0e 13 80 	movl   $0x80130e,0x8(%esp)
  80082e:	00 
  80082f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800833:	89 3c 24             	mov    %edi,(%esp)
  800836:	e8 53 03 00 00       	call   800b8e <printfmt>
  80083b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80083e:	e9 b6 fe ff ff       	jmp    8006f9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800843:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800847:	c7 44 24 08 17 13 80 	movl   $0x801317,0x8(%esp)
  80084e:	00 
  80084f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800853:	89 3c 24             	mov    %edi,(%esp)
  800856:	e8 33 03 00 00       	call   800b8e <printfmt>
  80085b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80085e:	e9 96 fe ff ff       	jmp    8006f9 <vprintfmt+0x2c>
  800863:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800866:	89 c3                	mov    %eax,%ebx
  800868:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80086b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80086e:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800871:	8b 45 14             	mov    0x14(%ebp),%eax
  800874:	8d 50 04             	lea    0x4(%eax),%edx
  800877:	89 55 14             	mov    %edx,0x14(%ebp)
  80087a:	8b 00                	mov    (%eax),%eax
  80087c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80087f:	85 c0                	test   %eax,%eax
  800881:	b8 1a 13 80 00       	mov    $0x80131a,%eax
  800886:	0f 45 45 c4          	cmovne -0x3c(%ebp),%eax
  80088a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80088d:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800891:	7e 06                	jle    800899 <vprintfmt+0x1cc>
  800893:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800897:	75 13                	jne    8008ac <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800899:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80089c:	0f be 02             	movsbl (%edx),%eax
  80089f:	85 c0                	test   %eax,%eax
  8008a1:	0f 85 9b 00 00 00    	jne    800942 <vprintfmt+0x275>
  8008a7:	e9 88 00 00 00       	jmp    800934 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008ac:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008b0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  8008b3:	89 0c 24             	mov    %ecx,(%esp)
  8008b6:	e8 20 03 00 00       	call   800bdb <strnlen>
  8008bb:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8008be:	29 c2                	sub    %eax,%edx
  8008c0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008c3:	85 d2                	test   %edx,%edx
  8008c5:	7e d2                	jle    800899 <vprintfmt+0x1cc>
					putch(padc, putdat);
  8008c7:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  8008cb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008ce:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8008d1:	89 d3                	mov    %edx,%ebx
  8008d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008d7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8008da:	89 04 24             	mov    %eax,(%esp)
  8008dd:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008df:	83 eb 01             	sub    $0x1,%ebx
  8008e2:	85 db                	test   %ebx,%ebx
  8008e4:	7f ed                	jg     8008d3 <vprintfmt+0x206>
  8008e6:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8008e9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8008f0:	eb a7                	jmp    800899 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008f2:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8008f6:	74 1a                	je     800912 <vprintfmt+0x245>
  8008f8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8008fb:	83 fa 5e             	cmp    $0x5e,%edx
  8008fe:	76 12                	jbe    800912 <vprintfmt+0x245>
					putch('?', putdat);
  800900:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800904:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80090b:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80090e:	66 90                	xchg   %ax,%ax
  800910:	eb 0a                	jmp    80091c <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800912:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800916:	89 04 24             	mov    %eax,(%esp)
  800919:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80091c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800920:	0f be 03             	movsbl (%ebx),%eax
  800923:	85 c0                	test   %eax,%eax
  800925:	74 05                	je     80092c <vprintfmt+0x25f>
  800927:	83 c3 01             	add    $0x1,%ebx
  80092a:	eb 29                	jmp    800955 <vprintfmt+0x288>
  80092c:	89 fe                	mov    %edi,%esi
  80092e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800931:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800934:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800938:	7f 2e                	jg     800968 <vprintfmt+0x29b>
  80093a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80093d:	e9 b7 fd ff ff       	jmp    8006f9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800942:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800945:	83 c2 01             	add    $0x1,%edx
  800948:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80094b:	89 f7                	mov    %esi,%edi
  80094d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800950:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800953:	89 d3                	mov    %edx,%ebx
  800955:	85 f6                	test   %esi,%esi
  800957:	78 99                	js     8008f2 <vprintfmt+0x225>
  800959:	83 ee 01             	sub    $0x1,%esi
  80095c:	79 94                	jns    8008f2 <vprintfmt+0x225>
  80095e:	89 fe                	mov    %edi,%esi
  800960:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800963:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800966:	eb cc                	jmp    800934 <vprintfmt+0x267>
  800968:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80096b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80096e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800972:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800979:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80097b:	83 eb 01             	sub    $0x1,%ebx
  80097e:	85 db                	test   %ebx,%ebx
  800980:	7f ec                	jg     80096e <vprintfmt+0x2a1>
  800982:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800985:	e9 6f fd ff ff       	jmp    8006f9 <vprintfmt+0x2c>
  80098a:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80098d:	83 f9 01             	cmp    $0x1,%ecx
  800990:	7e 16                	jle    8009a8 <vprintfmt+0x2db>
		return va_arg(*ap, long long);
  800992:	8b 45 14             	mov    0x14(%ebp),%eax
  800995:	8d 50 08             	lea    0x8(%eax),%edx
  800998:	89 55 14             	mov    %edx,0x14(%ebp)
  80099b:	8b 10                	mov    (%eax),%edx
  80099d:	8b 48 04             	mov    0x4(%eax),%ecx
  8009a0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8009a3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8009a6:	eb 32                	jmp    8009da <vprintfmt+0x30d>
	else if (lflag)
  8009a8:	85 c9                	test   %ecx,%ecx
  8009aa:	74 18                	je     8009c4 <vprintfmt+0x2f7>
		return va_arg(*ap, long);
  8009ac:	8b 45 14             	mov    0x14(%ebp),%eax
  8009af:	8d 50 04             	lea    0x4(%eax),%edx
  8009b2:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b5:	8b 00                	mov    (%eax),%eax
  8009b7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009ba:	89 c1                	mov    %eax,%ecx
  8009bc:	c1 f9 1f             	sar    $0x1f,%ecx
  8009bf:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8009c2:	eb 16                	jmp    8009da <vprintfmt+0x30d>
	else
		return va_arg(*ap, int);
  8009c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009c7:	8d 50 04             	lea    0x4(%eax),%edx
  8009ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8009cd:	8b 00                	mov    (%eax),%eax
  8009cf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009d2:	89 c2                	mov    %eax,%edx
  8009d4:	c1 fa 1f             	sar    $0x1f,%edx
  8009d7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009da:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8009dd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8009e0:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8009e5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8009e9:	0f 89 b8 00 00 00    	jns    800aa7 <vprintfmt+0x3da>
				putch('-', putdat);
  8009ef:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009f3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009fa:	ff d7                	call   *%edi
				num = -(long long) num;
  8009fc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8009ff:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800a02:	f7 d9                	neg    %ecx
  800a04:	83 d3 00             	adc    $0x0,%ebx
  800a07:	f7 db                	neg    %ebx
  800a09:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a0e:	e9 94 00 00 00       	jmp    800aa7 <vprintfmt+0x3da>
  800a13:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a16:	89 ca                	mov    %ecx,%edx
  800a18:	8d 45 14             	lea    0x14(%ebp),%eax
  800a1b:	e8 56 fc ff ff       	call   800676 <getuint>
  800a20:	89 c1                	mov    %eax,%ecx
  800a22:	89 d3                	mov    %edx,%ebx
  800a24:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800a29:	eb 7c                	jmp    800aa7 <vprintfmt+0x3da>
  800a2b:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800a2e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a32:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800a39:	ff d7                	call   *%edi
			putch('X', putdat);
  800a3b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a3f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800a46:	ff d7                	call   *%edi
			putch('X', putdat);
  800a48:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a4c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800a53:	ff d7                	call   *%edi
  800a55:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800a58:	e9 9c fc ff ff       	jmp    8006f9 <vprintfmt+0x2c>
  800a5d:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800a60:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a64:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a6b:	ff d7                	call   *%edi
			putch('x', putdat);
  800a6d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a71:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a78:	ff d7                	call   *%edi
			num = (unsigned long long)
  800a7a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7d:	8d 50 04             	lea    0x4(%eax),%edx
  800a80:	89 55 14             	mov    %edx,0x14(%ebp)
  800a83:	8b 08                	mov    (%eax),%ecx
  800a85:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a8a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a8f:	eb 16                	jmp    800aa7 <vprintfmt+0x3da>
  800a91:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a94:	89 ca                	mov    %ecx,%edx
  800a96:	8d 45 14             	lea    0x14(%ebp),%eax
  800a99:	e8 d8 fb ff ff       	call   800676 <getuint>
  800a9e:	89 c1                	mov    %eax,%ecx
  800aa0:	89 d3                	mov    %edx,%ebx
  800aa2:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800aa7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800aab:	89 54 24 10          	mov    %edx,0x10(%esp)
  800aaf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ab2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ab6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aba:	89 0c 24             	mov    %ecx,(%esp)
  800abd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ac1:	89 f2                	mov    %esi,%edx
  800ac3:	89 f8                	mov    %edi,%eax
  800ac5:	e8 b6 fa ff ff       	call   800580 <printnum>
  800aca:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800acd:	e9 27 fc ff ff       	jmp    8006f9 <vprintfmt+0x2c>
  800ad2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800ad5:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ad8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800adc:	89 14 24             	mov    %edx,(%esp)
  800adf:	ff d7                	call   *%edi
  800ae1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800ae4:	e9 10 fc ff ff       	jmp    8006f9 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ae9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800aed:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800af4:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800af6:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800af9:	80 38 25             	cmpb   $0x25,(%eax)
  800afc:	0f 84 f7 fb ff ff    	je     8006f9 <vprintfmt+0x2c>
  800b02:	89 c3                	mov    %eax,%ebx
  800b04:	eb f0                	jmp    800af6 <vprintfmt+0x429>
				/* do nothing */;
			break;
		}
	}
}
  800b06:	83 c4 5c             	add    $0x5c,%esp
  800b09:	5b                   	pop    %ebx
  800b0a:	5e                   	pop    %esi
  800b0b:	5f                   	pop    %edi
  800b0c:	5d                   	pop    %ebp
  800b0d:	c3                   	ret    

00800b0e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b0e:	55                   	push   %ebp
  800b0f:	89 e5                	mov    %esp,%ebp
  800b11:	83 ec 28             	sub    $0x28,%esp
  800b14:	8b 45 08             	mov    0x8(%ebp),%eax
  800b17:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800b1a:	85 c0                	test   %eax,%eax
  800b1c:	74 04                	je     800b22 <vsnprintf+0x14>
  800b1e:	85 d2                	test   %edx,%edx
  800b20:	7f 07                	jg     800b29 <vsnprintf+0x1b>
  800b22:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b27:	eb 3b                	jmp    800b64 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b29:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b2c:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800b30:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b33:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b3a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b3d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b41:	8b 45 10             	mov    0x10(%ebp),%eax
  800b44:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b48:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b4b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b4f:	c7 04 24 b0 06 80 00 	movl   $0x8006b0,(%esp)
  800b56:	e8 72 fb ff ff       	call   8006cd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b5b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b5e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b61:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b64:	c9                   	leave  
  800b65:	c3                   	ret    

00800b66 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800b6c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800b6f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b73:	8b 45 10             	mov    0x10(%ebp),%eax
  800b76:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b81:	8b 45 08             	mov    0x8(%ebp),%eax
  800b84:	89 04 24             	mov    %eax,(%esp)
  800b87:	e8 82 ff ff ff       	call   800b0e <vsnprintf>
	va_end(ap);

	return rc;
}
  800b8c:	c9                   	leave  
  800b8d:	c3                   	ret    

00800b8e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b8e:	55                   	push   %ebp
  800b8f:	89 e5                	mov    %esp,%ebp
  800b91:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800b94:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800b97:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b9b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b9e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	89 04 24             	mov    %eax,(%esp)
  800baf:	e8 19 fb ff ff       	call   8006cd <vprintfmt>
	va_end(ap);
}
  800bb4:	c9                   	leave  
  800bb5:	c3                   	ret    
  800bb6:	66 90                	xchg   %ax,%ax
  800bb8:	66 90                	xchg   %ax,%ax
  800bba:	66 90                	xchg   %ax,%ax
  800bbc:	66 90                	xchg   %ax,%ax
  800bbe:	66 90                	xchg   %ax,%ax

00800bc0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bc0:	55                   	push   %ebp
  800bc1:	89 e5                	mov    %esp,%ebp
  800bc3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800bc6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcb:	80 3a 00             	cmpb   $0x0,(%edx)
  800bce:	74 09                	je     800bd9 <strlen+0x19>
		n++;
  800bd0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bd3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bd7:	75 f7                	jne    800bd0 <strlen+0x10>
		n++;
	return n;
}
  800bd9:	5d                   	pop    %ebp
  800bda:	c3                   	ret    

00800bdb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	53                   	push   %ebx
  800bdf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800be2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800be5:	85 c9                	test   %ecx,%ecx
  800be7:	74 19                	je     800c02 <strnlen+0x27>
  800be9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800bec:	74 14                	je     800c02 <strnlen+0x27>
  800bee:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800bf3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bf6:	39 c8                	cmp    %ecx,%eax
  800bf8:	74 0d                	je     800c07 <strnlen+0x2c>
  800bfa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800bfe:	75 f3                	jne    800bf3 <strnlen+0x18>
  800c00:	eb 05                	jmp    800c07 <strnlen+0x2c>
  800c02:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800c07:	5b                   	pop    %ebx
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	53                   	push   %ebx
  800c0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c14:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c19:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c1d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c20:	83 c2 01             	add    $0x1,%edx
  800c23:	84 c9                	test   %cl,%cl
  800c25:	75 f2                	jne    800c19 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c27:	5b                   	pop    %ebx
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c2a:	55                   	push   %ebp
  800c2b:	89 e5                	mov    %esp,%ebp
  800c2d:	53                   	push   %ebx
  800c2e:	83 ec 08             	sub    $0x8,%esp
  800c31:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c34:	89 1c 24             	mov    %ebx,(%esp)
  800c37:	e8 84 ff ff ff       	call   800bc0 <strlen>
	strcpy(dst + len, src);
  800c3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c3f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c43:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800c46:	89 04 24             	mov    %eax,(%esp)
  800c49:	e8 bc ff ff ff       	call   800c0a <strcpy>
	return dst;
}
  800c4e:	89 d8                	mov    %ebx,%eax
  800c50:	83 c4 08             	add    $0x8,%esp
  800c53:	5b                   	pop    %ebx
  800c54:	5d                   	pop    %ebp
  800c55:	c3                   	ret    

00800c56 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	56                   	push   %esi
  800c5a:	53                   	push   %ebx
  800c5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c61:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c64:	85 f6                	test   %esi,%esi
  800c66:	74 18                	je     800c80 <strncpy+0x2a>
  800c68:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800c6d:	0f b6 1a             	movzbl (%edx),%ebx
  800c70:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c73:	80 3a 01             	cmpb   $0x1,(%edx)
  800c76:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c79:	83 c1 01             	add    $0x1,%ecx
  800c7c:	39 ce                	cmp    %ecx,%esi
  800c7e:	77 ed                	ja     800c6d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c80:	5b                   	pop    %ebx
  800c81:	5e                   	pop    %esi
  800c82:	5d                   	pop    %ebp
  800c83:	c3                   	ret    

00800c84 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	56                   	push   %esi
  800c88:	53                   	push   %ebx
  800c89:	8b 75 08             	mov    0x8(%ebp),%esi
  800c8c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c92:	89 f0                	mov    %esi,%eax
  800c94:	85 c9                	test   %ecx,%ecx
  800c96:	74 27                	je     800cbf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800c98:	83 e9 01             	sub    $0x1,%ecx
  800c9b:	74 1d                	je     800cba <strlcpy+0x36>
  800c9d:	0f b6 1a             	movzbl (%edx),%ebx
  800ca0:	84 db                	test   %bl,%bl
  800ca2:	74 16                	je     800cba <strlcpy+0x36>
			*dst++ = *src++;
  800ca4:	88 18                	mov    %bl,(%eax)
  800ca6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ca9:	83 e9 01             	sub    $0x1,%ecx
  800cac:	74 0e                	je     800cbc <strlcpy+0x38>
			*dst++ = *src++;
  800cae:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800cb1:	0f b6 1a             	movzbl (%edx),%ebx
  800cb4:	84 db                	test   %bl,%bl
  800cb6:	75 ec                	jne    800ca4 <strlcpy+0x20>
  800cb8:	eb 02                	jmp    800cbc <strlcpy+0x38>
  800cba:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800cbc:	c6 00 00             	movb   $0x0,(%eax)
  800cbf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800cc1:	5b                   	pop    %ebx
  800cc2:	5e                   	pop    %esi
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800cce:	0f b6 01             	movzbl (%ecx),%eax
  800cd1:	84 c0                	test   %al,%al
  800cd3:	74 15                	je     800cea <strcmp+0x25>
  800cd5:	3a 02                	cmp    (%edx),%al
  800cd7:	75 11                	jne    800cea <strcmp+0x25>
		p++, q++;
  800cd9:	83 c1 01             	add    $0x1,%ecx
  800cdc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800cdf:	0f b6 01             	movzbl (%ecx),%eax
  800ce2:	84 c0                	test   %al,%al
  800ce4:	74 04                	je     800cea <strcmp+0x25>
  800ce6:	3a 02                	cmp    (%edx),%al
  800ce8:	74 ef                	je     800cd9 <strcmp+0x14>
  800cea:	0f b6 c0             	movzbl %al,%eax
  800ced:	0f b6 12             	movzbl (%edx),%edx
  800cf0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cf2:	5d                   	pop    %ebp
  800cf3:	c3                   	ret    

00800cf4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	53                   	push   %ebx
  800cf8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cfb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cfe:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800d01:	85 c0                	test   %eax,%eax
  800d03:	74 23                	je     800d28 <strncmp+0x34>
  800d05:	0f b6 1a             	movzbl (%edx),%ebx
  800d08:	84 db                	test   %bl,%bl
  800d0a:	74 25                	je     800d31 <strncmp+0x3d>
  800d0c:	3a 19                	cmp    (%ecx),%bl
  800d0e:	75 21                	jne    800d31 <strncmp+0x3d>
  800d10:	83 e8 01             	sub    $0x1,%eax
  800d13:	74 13                	je     800d28 <strncmp+0x34>
		n--, p++, q++;
  800d15:	83 c2 01             	add    $0x1,%edx
  800d18:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d1b:	0f b6 1a             	movzbl (%edx),%ebx
  800d1e:	84 db                	test   %bl,%bl
  800d20:	74 0f                	je     800d31 <strncmp+0x3d>
  800d22:	3a 19                	cmp    (%ecx),%bl
  800d24:	74 ea                	je     800d10 <strncmp+0x1c>
  800d26:	eb 09                	jmp    800d31 <strncmp+0x3d>
  800d28:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d2d:	5b                   	pop    %ebx
  800d2e:	5d                   	pop    %ebp
  800d2f:	90                   	nop
  800d30:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d31:	0f b6 02             	movzbl (%edx),%eax
  800d34:	0f b6 11             	movzbl (%ecx),%edx
  800d37:	29 d0                	sub    %edx,%eax
  800d39:	eb f2                	jmp    800d2d <strncmp+0x39>

00800d3b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d41:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d45:	0f b6 10             	movzbl (%eax),%edx
  800d48:	84 d2                	test   %dl,%dl
  800d4a:	74 18                	je     800d64 <strchr+0x29>
		if (*s == c)
  800d4c:	38 ca                	cmp    %cl,%dl
  800d4e:	75 0a                	jne    800d5a <strchr+0x1f>
  800d50:	eb 17                	jmp    800d69 <strchr+0x2e>
  800d52:	38 ca                	cmp    %cl,%dl
  800d54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d58:	74 0f                	je     800d69 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d5a:	83 c0 01             	add    $0x1,%eax
  800d5d:	0f b6 10             	movzbl (%eax),%edx
  800d60:	84 d2                	test   %dl,%dl
  800d62:	75 ee                	jne    800d52 <strchr+0x17>
  800d64:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800d69:	5d                   	pop    %ebp
  800d6a:	c3                   	ret    

00800d6b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d6b:	55                   	push   %ebp
  800d6c:	89 e5                	mov    %esp,%ebp
  800d6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d71:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d75:	0f b6 10             	movzbl (%eax),%edx
  800d78:	84 d2                	test   %dl,%dl
  800d7a:	74 18                	je     800d94 <strfind+0x29>
		if (*s == c)
  800d7c:	38 ca                	cmp    %cl,%dl
  800d7e:	75 0a                	jne    800d8a <strfind+0x1f>
  800d80:	eb 12                	jmp    800d94 <strfind+0x29>
  800d82:	38 ca                	cmp    %cl,%dl
  800d84:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d88:	74 0a                	je     800d94 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d8a:	83 c0 01             	add    $0x1,%eax
  800d8d:	0f b6 10             	movzbl (%eax),%edx
  800d90:	84 d2                	test   %dl,%dl
  800d92:	75 ee                	jne    800d82 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d94:	5d                   	pop    %ebp
  800d95:	c3                   	ret    

00800d96 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d96:	55                   	push   %ebp
  800d97:	89 e5                	mov    %esp,%ebp
  800d99:	83 ec 0c             	sub    $0xc,%esp
  800d9c:	89 1c 24             	mov    %ebx,(%esp)
  800d9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800da3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800da7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800daa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dad:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800db0:	85 c9                	test   %ecx,%ecx
  800db2:	74 30                	je     800de4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800db4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dba:	75 25                	jne    800de1 <memset+0x4b>
  800dbc:	f6 c1 03             	test   $0x3,%cl
  800dbf:	75 20                	jne    800de1 <memset+0x4b>
		c &= 0xFF;
  800dc1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dc4:	89 d3                	mov    %edx,%ebx
  800dc6:	c1 e3 08             	shl    $0x8,%ebx
  800dc9:	89 d6                	mov    %edx,%esi
  800dcb:	c1 e6 18             	shl    $0x18,%esi
  800dce:	89 d0                	mov    %edx,%eax
  800dd0:	c1 e0 10             	shl    $0x10,%eax
  800dd3:	09 f0                	or     %esi,%eax
  800dd5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800dd7:	09 d8                	or     %ebx,%eax
  800dd9:	c1 e9 02             	shr    $0x2,%ecx
  800ddc:	fc                   	cld    
  800ddd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ddf:	eb 03                	jmp    800de4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800de1:	fc                   	cld    
  800de2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800de4:	89 f8                	mov    %edi,%eax
  800de6:	8b 1c 24             	mov    (%esp),%ebx
  800de9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ded:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800df1:	89 ec                	mov    %ebp,%esp
  800df3:	5d                   	pop    %ebp
  800df4:	c3                   	ret    

00800df5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800df5:	55                   	push   %ebp
  800df6:	89 e5                	mov    %esp,%ebp
  800df8:	83 ec 08             	sub    $0x8,%esp
  800dfb:	89 34 24             	mov    %esi,(%esp)
  800dfe:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e02:	8b 45 08             	mov    0x8(%ebp),%eax
  800e05:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800e08:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800e0b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800e0d:	39 c6                	cmp    %eax,%esi
  800e0f:	73 35                	jae    800e46 <memmove+0x51>
  800e11:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e14:	39 d0                	cmp    %edx,%eax
  800e16:	73 2e                	jae    800e46 <memmove+0x51>
		s += n;
		d += n;
  800e18:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e1a:	f6 c2 03             	test   $0x3,%dl
  800e1d:	75 1b                	jne    800e3a <memmove+0x45>
  800e1f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e25:	75 13                	jne    800e3a <memmove+0x45>
  800e27:	f6 c1 03             	test   $0x3,%cl
  800e2a:	75 0e                	jne    800e3a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800e2c:	83 ef 04             	sub    $0x4,%edi
  800e2f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e32:	c1 e9 02             	shr    $0x2,%ecx
  800e35:	fd                   	std    
  800e36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e38:	eb 09                	jmp    800e43 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e3a:	83 ef 01             	sub    $0x1,%edi
  800e3d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e40:	fd                   	std    
  800e41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e43:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e44:	eb 20                	jmp    800e66 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e46:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e4c:	75 15                	jne    800e63 <memmove+0x6e>
  800e4e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e54:	75 0d                	jne    800e63 <memmove+0x6e>
  800e56:	f6 c1 03             	test   $0x3,%cl
  800e59:	75 08                	jne    800e63 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800e5b:	c1 e9 02             	shr    $0x2,%ecx
  800e5e:	fc                   	cld    
  800e5f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e61:	eb 03                	jmp    800e66 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e63:	fc                   	cld    
  800e64:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e66:	8b 34 24             	mov    (%esp),%esi
  800e69:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e6d:	89 ec                	mov    %ebp,%esp
  800e6f:	5d                   	pop    %ebp
  800e70:	c3                   	ret    

00800e71 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e77:	8b 45 10             	mov    0x10(%ebp),%eax
  800e7a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e81:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e85:	8b 45 08             	mov    0x8(%ebp),%eax
  800e88:	89 04 24             	mov    %eax,(%esp)
  800e8b:	e8 65 ff ff ff       	call   800df5 <memmove>
}
  800e90:	c9                   	leave  
  800e91:	c3                   	ret    

00800e92 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e92:	55                   	push   %ebp
  800e93:	89 e5                	mov    %esp,%ebp
  800e95:	57                   	push   %edi
  800e96:	56                   	push   %esi
  800e97:	53                   	push   %ebx
  800e98:	8b 75 08             	mov    0x8(%ebp),%esi
  800e9b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e9e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ea1:	85 c9                	test   %ecx,%ecx
  800ea3:	74 36                	je     800edb <memcmp+0x49>
		if (*s1 != *s2)
  800ea5:	0f b6 06             	movzbl (%esi),%eax
  800ea8:	0f b6 1f             	movzbl (%edi),%ebx
  800eab:	38 d8                	cmp    %bl,%al
  800ead:	74 20                	je     800ecf <memcmp+0x3d>
  800eaf:	eb 14                	jmp    800ec5 <memcmp+0x33>
  800eb1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800eb6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800ebb:	83 c2 01             	add    $0x1,%edx
  800ebe:	83 e9 01             	sub    $0x1,%ecx
  800ec1:	38 d8                	cmp    %bl,%al
  800ec3:	74 12                	je     800ed7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800ec5:	0f b6 c0             	movzbl %al,%eax
  800ec8:	0f b6 db             	movzbl %bl,%ebx
  800ecb:	29 d8                	sub    %ebx,%eax
  800ecd:	eb 11                	jmp    800ee0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ecf:	83 e9 01             	sub    $0x1,%ecx
  800ed2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ed7:	85 c9                	test   %ecx,%ecx
  800ed9:	75 d6                	jne    800eb1 <memcmp+0x1f>
  800edb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800eeb:	89 c2                	mov    %eax,%edx
  800eed:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ef0:	39 d0                	cmp    %edx,%eax
  800ef2:	73 15                	jae    800f09 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ef4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ef8:	38 08                	cmp    %cl,(%eax)
  800efa:	75 06                	jne    800f02 <memfind+0x1d>
  800efc:	eb 0b                	jmp    800f09 <memfind+0x24>
  800efe:	38 08                	cmp    %cl,(%eax)
  800f00:	74 07                	je     800f09 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f02:	83 c0 01             	add    $0x1,%eax
  800f05:	39 c2                	cmp    %eax,%edx
  800f07:	77 f5                	ja     800efe <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f09:	5d                   	pop    %ebp
  800f0a:	c3                   	ret    

00800f0b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f0b:	55                   	push   %ebp
  800f0c:	89 e5                	mov    %esp,%ebp
  800f0e:	57                   	push   %edi
  800f0f:	56                   	push   %esi
  800f10:	53                   	push   %ebx
  800f11:	83 ec 04             	sub    $0x4,%esp
  800f14:	8b 55 08             	mov    0x8(%ebp),%edx
  800f17:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f1a:	0f b6 02             	movzbl (%edx),%eax
  800f1d:	3c 20                	cmp    $0x20,%al
  800f1f:	74 04                	je     800f25 <strtol+0x1a>
  800f21:	3c 09                	cmp    $0x9,%al
  800f23:	75 0e                	jne    800f33 <strtol+0x28>
		s++;
  800f25:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f28:	0f b6 02             	movzbl (%edx),%eax
  800f2b:	3c 20                	cmp    $0x20,%al
  800f2d:	74 f6                	je     800f25 <strtol+0x1a>
  800f2f:	3c 09                	cmp    $0x9,%al
  800f31:	74 f2                	je     800f25 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f33:	3c 2b                	cmp    $0x2b,%al
  800f35:	75 0c                	jne    800f43 <strtol+0x38>
		s++;
  800f37:	83 c2 01             	add    $0x1,%edx
  800f3a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800f41:	eb 15                	jmp    800f58 <strtol+0x4d>
	else if (*s == '-')
  800f43:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800f4a:	3c 2d                	cmp    $0x2d,%al
  800f4c:	75 0a                	jne    800f58 <strtol+0x4d>
		s++, neg = 1;
  800f4e:	83 c2 01             	add    $0x1,%edx
  800f51:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f58:	85 db                	test   %ebx,%ebx
  800f5a:	0f 94 c0             	sete   %al
  800f5d:	74 05                	je     800f64 <strtol+0x59>
  800f5f:	83 fb 10             	cmp    $0x10,%ebx
  800f62:	75 18                	jne    800f7c <strtol+0x71>
  800f64:	80 3a 30             	cmpb   $0x30,(%edx)
  800f67:	75 13                	jne    800f7c <strtol+0x71>
  800f69:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f6d:	8d 76 00             	lea    0x0(%esi),%esi
  800f70:	75 0a                	jne    800f7c <strtol+0x71>
		s += 2, base = 16;
  800f72:	83 c2 02             	add    $0x2,%edx
  800f75:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f7a:	eb 15                	jmp    800f91 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f7c:	84 c0                	test   %al,%al
  800f7e:	66 90                	xchg   %ax,%ax
  800f80:	74 0f                	je     800f91 <strtol+0x86>
  800f82:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f87:	80 3a 30             	cmpb   $0x30,(%edx)
  800f8a:	75 05                	jne    800f91 <strtol+0x86>
		s++, base = 8;
  800f8c:	83 c2 01             	add    $0x1,%edx
  800f8f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f91:	b8 00 00 00 00       	mov    $0x0,%eax
  800f96:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f98:	0f b6 0a             	movzbl (%edx),%ecx
  800f9b:	89 cf                	mov    %ecx,%edi
  800f9d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800fa0:	80 fb 09             	cmp    $0x9,%bl
  800fa3:	77 08                	ja     800fad <strtol+0xa2>
			dig = *s - '0';
  800fa5:	0f be c9             	movsbl %cl,%ecx
  800fa8:	83 e9 30             	sub    $0x30,%ecx
  800fab:	eb 1e                	jmp    800fcb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800fad:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800fb0:	80 fb 19             	cmp    $0x19,%bl
  800fb3:	77 08                	ja     800fbd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800fb5:	0f be c9             	movsbl %cl,%ecx
  800fb8:	83 e9 57             	sub    $0x57,%ecx
  800fbb:	eb 0e                	jmp    800fcb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800fbd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800fc0:	80 fb 19             	cmp    $0x19,%bl
  800fc3:	77 15                	ja     800fda <strtol+0xcf>
			dig = *s - 'A' + 10;
  800fc5:	0f be c9             	movsbl %cl,%ecx
  800fc8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800fcb:	39 f1                	cmp    %esi,%ecx
  800fcd:	7d 0b                	jge    800fda <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800fcf:	83 c2 01             	add    $0x1,%edx
  800fd2:	0f af c6             	imul   %esi,%eax
  800fd5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800fd8:	eb be                	jmp    800f98 <strtol+0x8d>
  800fda:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800fdc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fe0:	74 05                	je     800fe7 <strtol+0xdc>
		*endptr = (char *) s;
  800fe2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fe5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800fe7:	89 ca                	mov    %ecx,%edx
  800fe9:	f7 da                	neg    %edx
  800feb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800fef:	0f 45 c2             	cmovne %edx,%eax
}
  800ff2:	83 c4 04             	add    $0x4,%esp
  800ff5:	5b                   	pop    %ebx
  800ff6:	5e                   	pop    %esi
  800ff7:	5f                   	pop    %edi
  800ff8:	5d                   	pop    %ebp
  800ff9:	c3                   	ret    

00800ffa <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800ffa:	55                   	push   %ebp
  800ffb:	89 e5                	mov    %esp,%ebp
  800ffd:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801000:	83 3d 08 20 80 00 00 	cmpl   $0x0,0x802008
  801007:	75 1c                	jne    801025 <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  801009:	c7 44 24 08 44 15 80 	movl   $0x801544,0x8(%esp)
  801010:	00 
  801011:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801018:	00 
  801019:	c7 04 24 68 15 80 00 	movl   $0x801568,(%esp)
  801020:	e8 44 f4 ff ff       	call   800469 <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801025:	8b 45 08             	mov    0x8(%ebp),%eax
  801028:	a3 08 20 80 00       	mov    %eax,0x802008
}
  80102d:	c9                   	leave  
  80102e:	c3                   	ret    
  80102f:	90                   	nop

00801030 <__udivdi3>:
  801030:	55                   	push   %ebp
  801031:	89 e5                	mov    %esp,%ebp
  801033:	57                   	push   %edi
  801034:	56                   	push   %esi
  801035:	83 ec 10             	sub    $0x10,%esp
  801038:	8b 45 14             	mov    0x14(%ebp),%eax
  80103b:	8b 55 08             	mov    0x8(%ebp),%edx
  80103e:	8b 75 10             	mov    0x10(%ebp),%esi
  801041:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801044:	85 c0                	test   %eax,%eax
  801046:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801049:	75 35                	jne    801080 <__udivdi3+0x50>
  80104b:	39 fe                	cmp    %edi,%esi
  80104d:	77 61                	ja     8010b0 <__udivdi3+0x80>
  80104f:	85 f6                	test   %esi,%esi
  801051:	75 0b                	jne    80105e <__udivdi3+0x2e>
  801053:	b8 01 00 00 00       	mov    $0x1,%eax
  801058:	31 d2                	xor    %edx,%edx
  80105a:	f7 f6                	div    %esi
  80105c:	89 c6                	mov    %eax,%esi
  80105e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801061:	31 d2                	xor    %edx,%edx
  801063:	89 f8                	mov    %edi,%eax
  801065:	f7 f6                	div    %esi
  801067:	89 c7                	mov    %eax,%edi
  801069:	89 c8                	mov    %ecx,%eax
  80106b:	f7 f6                	div    %esi
  80106d:	89 c1                	mov    %eax,%ecx
  80106f:	89 fa                	mov    %edi,%edx
  801071:	89 c8                	mov    %ecx,%eax
  801073:	83 c4 10             	add    $0x10,%esp
  801076:	5e                   	pop    %esi
  801077:	5f                   	pop    %edi
  801078:	5d                   	pop    %ebp
  801079:	c3                   	ret    
  80107a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801080:	39 f8                	cmp    %edi,%eax
  801082:	77 1c                	ja     8010a0 <__udivdi3+0x70>
  801084:	0f bd d0             	bsr    %eax,%edx
  801087:	83 f2 1f             	xor    $0x1f,%edx
  80108a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80108d:	75 39                	jne    8010c8 <__udivdi3+0x98>
  80108f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801092:	0f 86 a0 00 00 00    	jbe    801138 <__udivdi3+0x108>
  801098:	39 f8                	cmp    %edi,%eax
  80109a:	0f 82 98 00 00 00    	jb     801138 <__udivdi3+0x108>
  8010a0:	31 ff                	xor    %edi,%edi
  8010a2:	31 c9                	xor    %ecx,%ecx
  8010a4:	89 c8                	mov    %ecx,%eax
  8010a6:	89 fa                	mov    %edi,%edx
  8010a8:	83 c4 10             	add    $0x10,%esp
  8010ab:	5e                   	pop    %esi
  8010ac:	5f                   	pop    %edi
  8010ad:	5d                   	pop    %ebp
  8010ae:	c3                   	ret    
  8010af:	90                   	nop
  8010b0:	89 d1                	mov    %edx,%ecx
  8010b2:	89 fa                	mov    %edi,%edx
  8010b4:	89 c8                	mov    %ecx,%eax
  8010b6:	31 ff                	xor    %edi,%edi
  8010b8:	f7 f6                	div    %esi
  8010ba:	89 c1                	mov    %eax,%ecx
  8010bc:	89 fa                	mov    %edi,%edx
  8010be:	89 c8                	mov    %ecx,%eax
  8010c0:	83 c4 10             	add    $0x10,%esp
  8010c3:	5e                   	pop    %esi
  8010c4:	5f                   	pop    %edi
  8010c5:	5d                   	pop    %ebp
  8010c6:	c3                   	ret    
  8010c7:	90                   	nop
  8010c8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010cc:	89 f2                	mov    %esi,%edx
  8010ce:	d3 e0                	shl    %cl,%eax
  8010d0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8010d3:	b8 20 00 00 00       	mov    $0x20,%eax
  8010d8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8010db:	89 c1                	mov    %eax,%ecx
  8010dd:	d3 ea                	shr    %cl,%edx
  8010df:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010e3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8010e6:	d3 e6                	shl    %cl,%esi
  8010e8:	89 c1                	mov    %eax,%ecx
  8010ea:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8010ed:	89 fe                	mov    %edi,%esi
  8010ef:	d3 ee                	shr    %cl,%esi
  8010f1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010f5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010fb:	d3 e7                	shl    %cl,%edi
  8010fd:	89 c1                	mov    %eax,%ecx
  8010ff:	d3 ea                	shr    %cl,%edx
  801101:	09 d7                	or     %edx,%edi
  801103:	89 f2                	mov    %esi,%edx
  801105:	89 f8                	mov    %edi,%eax
  801107:	f7 75 ec             	divl   -0x14(%ebp)
  80110a:	89 d6                	mov    %edx,%esi
  80110c:	89 c7                	mov    %eax,%edi
  80110e:	f7 65 e8             	mull   -0x18(%ebp)
  801111:	39 d6                	cmp    %edx,%esi
  801113:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801116:	72 30                	jb     801148 <__udivdi3+0x118>
  801118:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80111b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80111f:	d3 e2                	shl    %cl,%edx
  801121:	39 c2                	cmp    %eax,%edx
  801123:	73 05                	jae    80112a <__udivdi3+0xfa>
  801125:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801128:	74 1e                	je     801148 <__udivdi3+0x118>
  80112a:	89 f9                	mov    %edi,%ecx
  80112c:	31 ff                	xor    %edi,%edi
  80112e:	e9 71 ff ff ff       	jmp    8010a4 <__udivdi3+0x74>
  801133:	90                   	nop
  801134:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801138:	31 ff                	xor    %edi,%edi
  80113a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80113f:	e9 60 ff ff ff       	jmp    8010a4 <__udivdi3+0x74>
  801144:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801148:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80114b:	31 ff                	xor    %edi,%edi
  80114d:	89 c8                	mov    %ecx,%eax
  80114f:	89 fa                	mov    %edi,%edx
  801151:	83 c4 10             	add    $0x10,%esp
  801154:	5e                   	pop    %esi
  801155:	5f                   	pop    %edi
  801156:	5d                   	pop    %ebp
  801157:	c3                   	ret    
  801158:	66 90                	xchg   %ax,%ax
  80115a:	66 90                	xchg   %ax,%ax
  80115c:	66 90                	xchg   %ax,%ax
  80115e:	66 90                	xchg   %ax,%ax

00801160 <__umoddi3>:
  801160:	55                   	push   %ebp
  801161:	89 e5                	mov    %esp,%ebp
  801163:	57                   	push   %edi
  801164:	56                   	push   %esi
  801165:	83 ec 20             	sub    $0x20,%esp
  801168:	8b 55 14             	mov    0x14(%ebp),%edx
  80116b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801171:	8b 75 0c             	mov    0xc(%ebp),%esi
  801174:	85 d2                	test   %edx,%edx
  801176:	89 c8                	mov    %ecx,%eax
  801178:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80117b:	75 13                	jne    801190 <__umoddi3+0x30>
  80117d:	39 f7                	cmp    %esi,%edi
  80117f:	76 3f                	jbe    8011c0 <__umoddi3+0x60>
  801181:	89 f2                	mov    %esi,%edx
  801183:	f7 f7                	div    %edi
  801185:	89 d0                	mov    %edx,%eax
  801187:	31 d2                	xor    %edx,%edx
  801189:	83 c4 20             	add    $0x20,%esp
  80118c:	5e                   	pop    %esi
  80118d:	5f                   	pop    %edi
  80118e:	5d                   	pop    %ebp
  80118f:	c3                   	ret    
  801190:	39 f2                	cmp    %esi,%edx
  801192:	77 4c                	ja     8011e0 <__umoddi3+0x80>
  801194:	0f bd ca             	bsr    %edx,%ecx
  801197:	83 f1 1f             	xor    $0x1f,%ecx
  80119a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80119d:	75 51                	jne    8011f0 <__umoddi3+0x90>
  80119f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8011a2:	0f 87 e0 00 00 00    	ja     801288 <__umoddi3+0x128>
  8011a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011ab:	29 f8                	sub    %edi,%eax
  8011ad:	19 d6                	sbb    %edx,%esi
  8011af:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8011b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b5:	89 f2                	mov    %esi,%edx
  8011b7:	83 c4 20             	add    $0x20,%esp
  8011ba:	5e                   	pop    %esi
  8011bb:	5f                   	pop    %edi
  8011bc:	5d                   	pop    %ebp
  8011bd:	c3                   	ret    
  8011be:	66 90                	xchg   %ax,%ax
  8011c0:	85 ff                	test   %edi,%edi
  8011c2:	75 0b                	jne    8011cf <__umoddi3+0x6f>
  8011c4:	b8 01 00 00 00       	mov    $0x1,%eax
  8011c9:	31 d2                	xor    %edx,%edx
  8011cb:	f7 f7                	div    %edi
  8011cd:	89 c7                	mov    %eax,%edi
  8011cf:	89 f0                	mov    %esi,%eax
  8011d1:	31 d2                	xor    %edx,%edx
  8011d3:	f7 f7                	div    %edi
  8011d5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011d8:	f7 f7                	div    %edi
  8011da:	eb a9                	jmp    801185 <__umoddi3+0x25>
  8011dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011e0:	89 c8                	mov    %ecx,%eax
  8011e2:	89 f2                	mov    %esi,%edx
  8011e4:	83 c4 20             	add    $0x20,%esp
  8011e7:	5e                   	pop    %esi
  8011e8:	5f                   	pop    %edi
  8011e9:	5d                   	pop    %ebp
  8011ea:	c3                   	ret    
  8011eb:	90                   	nop
  8011ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011f0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011f4:	d3 e2                	shl    %cl,%edx
  8011f6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011f9:	ba 20 00 00 00       	mov    $0x20,%edx
  8011fe:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801201:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801204:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801208:	89 fa                	mov    %edi,%edx
  80120a:	d3 ea                	shr    %cl,%edx
  80120c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801210:	0b 55 f4             	or     -0xc(%ebp),%edx
  801213:	d3 e7                	shl    %cl,%edi
  801215:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801219:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80121c:	89 f2                	mov    %esi,%edx
  80121e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801221:	89 c7                	mov    %eax,%edi
  801223:	d3 ea                	shr    %cl,%edx
  801225:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801229:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80122c:	89 c2                	mov    %eax,%edx
  80122e:	d3 e6                	shl    %cl,%esi
  801230:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801234:	d3 ea                	shr    %cl,%edx
  801236:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80123a:	09 d6                	or     %edx,%esi
  80123c:	89 f0                	mov    %esi,%eax
  80123e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801241:	d3 e7                	shl    %cl,%edi
  801243:	89 f2                	mov    %esi,%edx
  801245:	f7 75 f4             	divl   -0xc(%ebp)
  801248:	89 d6                	mov    %edx,%esi
  80124a:	f7 65 e8             	mull   -0x18(%ebp)
  80124d:	39 d6                	cmp    %edx,%esi
  80124f:	72 2b                	jb     80127c <__umoddi3+0x11c>
  801251:	39 c7                	cmp    %eax,%edi
  801253:	72 23                	jb     801278 <__umoddi3+0x118>
  801255:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801259:	29 c7                	sub    %eax,%edi
  80125b:	19 d6                	sbb    %edx,%esi
  80125d:	89 f0                	mov    %esi,%eax
  80125f:	89 f2                	mov    %esi,%edx
  801261:	d3 ef                	shr    %cl,%edi
  801263:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801267:	d3 e0                	shl    %cl,%eax
  801269:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80126d:	09 f8                	or     %edi,%eax
  80126f:	d3 ea                	shr    %cl,%edx
  801271:	83 c4 20             	add    $0x20,%esp
  801274:	5e                   	pop    %esi
  801275:	5f                   	pop    %edi
  801276:	5d                   	pop    %ebp
  801277:	c3                   	ret    
  801278:	39 d6                	cmp    %edx,%esi
  80127a:	75 d9                	jne    801255 <__umoddi3+0xf5>
  80127c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80127f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801282:	eb d1                	jmp    801255 <__umoddi3+0xf5>
  801284:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801288:	39 f2                	cmp    %esi,%edx
  80128a:	0f 82 18 ff ff ff    	jb     8011a8 <__umoddi3+0x48>
  801290:	e9 1d ff ff ff       	jmp    8011b2 <__umoddi3+0x52>
