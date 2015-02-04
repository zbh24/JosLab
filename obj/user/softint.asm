
obj/user/softint：     文件格式 elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $14");	// page fault
  800036:	cd 0e                	int    $0xe
}
  800038:	5d                   	pop    %ebp
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	55                   	push   %ebp
  80003b:	89 e5                	mov    %esp,%ebp
  80003d:	83 ec 18             	sub    $0x18,%esp
  800040:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800043:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800046:	8b 75 08             	mov    0x8(%ebp),%esi
  800049:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  80004c:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800053:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800056:	e8 53 03 00 00       	call   8003ae <sys_getenvid>
  80005b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800060:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800063:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800068:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006d:	85 f6                	test   %esi,%esi
  80006f:	7e 07                	jle    800078 <libmain+0x3e>
		binaryname = argv[0];
  800071:	8b 03                	mov    (%ebx),%eax
  800073:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800078:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  80007c:	89 34 24             	mov    %esi,(%esp)
  80007f:	e8 af ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800084:	e8 0a 00 00 00       	call   800093 <exit>
}
  800089:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  80008c:	8b 75 fc             	mov    -0x4(%ebp),%esi
  80008f:	89 ec                	mov    %ebp,%esp
  800091:	5d                   	pop    %ebp
  800092:	c3                   	ret    

00800093 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800093:	55                   	push   %ebp
  800094:	89 e5                	mov    %esp,%ebp
  800096:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800099:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a0:	e8 3d 03 00 00       	call   8003e2 <sys_env_destroy>
}
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	83 ec 0c             	sub    $0xc,%esp
  8000ad:	89 1c 24             	mov    %ebx,(%esp)
  8000b0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000b4:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b8:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c2:	89 d1                	mov    %edx,%ecx
  8000c4:	89 d3                	mov    %edx,%ebx
  8000c6:	89 d7                	mov    %edx,%edi
  8000c8:	89 d6                	mov    %edx,%esi
  8000ca:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000cc:	8b 1c 24             	mov    (%esp),%ebx
  8000cf:	8b 74 24 04          	mov    0x4(%esp),%esi
  8000d3:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8000d7:	89 ec                	mov    %ebp,%esp
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	83 ec 0c             	sub    $0xc,%esp
  8000e1:	89 1c 24             	mov    %ebx,(%esp)
  8000e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000e8:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000f4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f7:	89 c3                	mov    %eax,%ebx
  8000f9:	89 c7                	mov    %eax,%edi
  8000fb:	89 c6                	mov    %eax,%esi
  8000fd:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000ff:	8b 1c 24             	mov    (%esp),%ebx
  800102:	8b 74 24 04          	mov    0x4(%esp),%esi
  800106:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80010a:	89 ec                	mov    %ebp,%esp
  80010c:	5d                   	pop    %ebp
  80010d:	c3                   	ret    

0080010e <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  80010e:	55                   	push   %ebp
  80010f:	89 e5                	mov    %esp,%ebp
  800111:	83 ec 38             	sub    $0x38,%esp
  800114:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800117:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80011a:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80011d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800122:	b8 0c 00 00 00       	mov    $0xc,%eax
  800127:	8b 55 08             	mov    0x8(%ebp),%edx
  80012a:	89 cb                	mov    %ecx,%ebx
  80012c:	89 cf                	mov    %ecx,%edi
  80012e:	89 ce                	mov    %ecx,%esi
  800130:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800132:	85 c0                	test   %eax,%eax
  800134:	7e 28                	jle    80015e <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800136:	89 44 24 10          	mov    %eax,0x10(%esp)
  80013a:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800141:	00 
  800142:	c7 44 24 08 6a 12 80 	movl   $0x80126a,0x8(%esp)
  800149:	00 
  80014a:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800151:	00 
  800152:	c7 04 24 87 12 80 00 	movl   $0x801287,(%esp)
  800159:	e8 e1 02 00 00       	call   80043f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80015e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800161:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800164:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800167:	89 ec                	mov    %ebp,%esp
  800169:	5d                   	pop    %ebp
  80016a:	c3                   	ret    

0080016b <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	83 ec 0c             	sub    $0xc,%esp
  800171:	89 1c 24             	mov    %ebx,(%esp)
  800174:	89 74 24 04          	mov    %esi,0x4(%esp)
  800178:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80017c:	be 00 00 00 00       	mov    $0x0,%esi
  800181:	b8 0b 00 00 00       	mov    $0xb,%eax
  800186:	8b 7d 14             	mov    0x14(%ebp),%edi
  800189:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80018c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80018f:	8b 55 08             	mov    0x8(%ebp),%edx
  800192:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800194:	8b 1c 24             	mov    (%esp),%ebx
  800197:	8b 74 24 04          	mov    0x4(%esp),%esi
  80019b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80019f:	89 ec                	mov    %ebp,%esp
  8001a1:	5d                   	pop    %ebp
  8001a2:	c3                   	ret    

008001a3 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	83 ec 38             	sub    $0x38,%esp
  8001a9:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001ac:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001af:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001b7:	b8 09 00 00 00       	mov    $0x9,%eax
  8001bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c2:	89 df                	mov    %ebx,%edi
  8001c4:	89 de                	mov    %ebx,%esi
  8001c6:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	7e 28                	jle    8001f4 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001cc:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001d0:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8001d7:	00 
  8001d8:	c7 44 24 08 6a 12 80 	movl   $0x80126a,0x8(%esp)
  8001df:	00 
  8001e0:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001e7:	00 
  8001e8:	c7 04 24 87 12 80 00 	movl   $0x801287,(%esp)
  8001ef:	e8 4b 02 00 00       	call   80043f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8001f4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8001f7:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8001fa:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001fd:	89 ec                	mov    %ebp,%esp
  8001ff:	5d                   	pop    %ebp
  800200:	c3                   	ret    

00800201 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800201:	55                   	push   %ebp
  800202:	89 e5                	mov    %esp,%ebp
  800204:	83 ec 38             	sub    $0x38,%esp
  800207:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80020a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80020d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800210:	bb 00 00 00 00       	mov    $0x0,%ebx
  800215:	b8 08 00 00 00       	mov    $0x8,%eax
  80021a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021d:	8b 55 08             	mov    0x8(%ebp),%edx
  800220:	89 df                	mov    %ebx,%edi
  800222:	89 de                	mov    %ebx,%esi
  800224:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800226:	85 c0                	test   %eax,%eax
  800228:	7e 28                	jle    800252 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80022a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80022e:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800235:	00 
  800236:	c7 44 24 08 6a 12 80 	movl   $0x80126a,0x8(%esp)
  80023d:	00 
  80023e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800245:	00 
  800246:	c7 04 24 87 12 80 00 	movl   $0x801287,(%esp)
  80024d:	e8 ed 01 00 00       	call   80043f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800252:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800255:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800258:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80025b:	89 ec                	mov    %ebp,%esp
  80025d:	5d                   	pop    %ebp
  80025e:	c3                   	ret    

0080025f <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80025f:	55                   	push   %ebp
  800260:	89 e5                	mov    %esp,%ebp
  800262:	83 ec 38             	sub    $0x38,%esp
  800265:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800268:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80026b:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80026e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800273:	b8 06 00 00 00       	mov    $0x6,%eax
  800278:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027b:	8b 55 08             	mov    0x8(%ebp),%edx
  80027e:	89 df                	mov    %ebx,%edi
  800280:	89 de                	mov    %ebx,%esi
  800282:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800284:	85 c0                	test   %eax,%eax
  800286:	7e 28                	jle    8002b0 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800288:	89 44 24 10          	mov    %eax,0x10(%esp)
  80028c:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  800293:	00 
  800294:	c7 44 24 08 6a 12 80 	movl   $0x80126a,0x8(%esp)
  80029b:	00 
  80029c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002a3:	00 
  8002a4:	c7 04 24 87 12 80 00 	movl   $0x801287,(%esp)
  8002ab:	e8 8f 01 00 00       	call   80043f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002b0:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002b3:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002b6:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002b9:	89 ec                	mov    %ebp,%esp
  8002bb:	5d                   	pop    %ebp
  8002bc:	c3                   	ret    

008002bd <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	83 ec 38             	sub    $0x38,%esp
  8002c3:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002c6:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002c9:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002cc:	b8 05 00 00 00       	mov    $0x5,%eax
  8002d1:	8b 75 18             	mov    0x18(%ebp),%esi
  8002d4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002da:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e0:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002e2:	85 c0                	test   %eax,%eax
  8002e4:	7e 28                	jle    80030e <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e6:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ea:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8002f1:	00 
  8002f2:	c7 44 24 08 6a 12 80 	movl   $0x80126a,0x8(%esp)
  8002f9:	00 
  8002fa:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800301:	00 
  800302:	c7 04 24 87 12 80 00 	movl   $0x801287,(%esp)
  800309:	e8 31 01 00 00       	call   80043f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  80030e:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800311:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800314:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800317:	89 ec                	mov    %ebp,%esp
  800319:	5d                   	pop    %ebp
  80031a:	c3                   	ret    

0080031b <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	83 ec 38             	sub    $0x38,%esp
  800321:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800324:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800327:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80032a:	be 00 00 00 00       	mov    $0x0,%esi
  80032f:	b8 04 00 00 00       	mov    $0x4,%eax
  800334:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800337:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80033a:	8b 55 08             	mov    0x8(%ebp),%edx
  80033d:	89 f7                	mov    %esi,%edi
  80033f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800341:	85 c0                	test   %eax,%eax
  800343:	7e 28                	jle    80036d <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800345:	89 44 24 10          	mov    %eax,0x10(%esp)
  800349:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800350:	00 
  800351:	c7 44 24 08 6a 12 80 	movl   $0x80126a,0x8(%esp)
  800358:	00 
  800359:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800360:	00 
  800361:	c7 04 24 87 12 80 00 	movl   $0x801287,(%esp)
  800368:	e8 d2 00 00 00       	call   80043f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80036d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800370:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800373:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800376:	89 ec                	mov    %ebp,%esp
  800378:	5d                   	pop    %ebp
  800379:	c3                   	ret    

0080037a <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  80037a:	55                   	push   %ebp
  80037b:	89 e5                	mov    %esp,%ebp
  80037d:	83 ec 0c             	sub    $0xc,%esp
  800380:	89 1c 24             	mov    %ebx,(%esp)
  800383:	89 74 24 04          	mov    %esi,0x4(%esp)
  800387:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80038b:	ba 00 00 00 00       	mov    $0x0,%edx
  800390:	b8 0a 00 00 00       	mov    $0xa,%eax
  800395:	89 d1                	mov    %edx,%ecx
  800397:	89 d3                	mov    %edx,%ebx
  800399:	89 d7                	mov    %edx,%edi
  80039b:	89 d6                	mov    %edx,%esi
  80039d:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80039f:	8b 1c 24             	mov    (%esp),%ebx
  8003a2:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003a6:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8003aa:	89 ec                	mov    %ebp,%esp
  8003ac:	5d                   	pop    %ebp
  8003ad:	c3                   	ret    

008003ae <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8003ae:	55                   	push   %ebp
  8003af:	89 e5                	mov    %esp,%ebp
  8003b1:	83 ec 0c             	sub    $0xc,%esp
  8003b4:	89 1c 24             	mov    %ebx,(%esp)
  8003b7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003bb:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003bf:	ba 00 00 00 00       	mov    $0x0,%edx
  8003c4:	b8 02 00 00 00       	mov    $0x2,%eax
  8003c9:	89 d1                	mov    %edx,%ecx
  8003cb:	89 d3                	mov    %edx,%ebx
  8003cd:	89 d7                	mov    %edx,%edi
  8003cf:	89 d6                	mov    %edx,%esi
  8003d1:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8003d3:	8b 1c 24             	mov    (%esp),%ebx
  8003d6:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003da:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8003de:	89 ec                	mov    %ebp,%esp
  8003e0:	5d                   	pop    %ebp
  8003e1:	c3                   	ret    

008003e2 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8003e2:	55                   	push   %ebp
  8003e3:	89 e5                	mov    %esp,%ebp
  8003e5:	83 ec 38             	sub    $0x38,%esp
  8003e8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8003eb:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8003ee:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003f1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8003f6:	b8 03 00 00 00       	mov    $0x3,%eax
  8003fb:	8b 55 08             	mov    0x8(%ebp),%edx
  8003fe:	89 cb                	mov    %ecx,%ebx
  800400:	89 cf                	mov    %ecx,%edi
  800402:	89 ce                	mov    %ecx,%esi
  800404:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800406:	85 c0                	test   %eax,%eax
  800408:	7e 28                	jle    800432 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80040a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80040e:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800415:	00 
  800416:	c7 44 24 08 6a 12 80 	movl   $0x80126a,0x8(%esp)
  80041d:	00 
  80041e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800425:	00 
  800426:	c7 04 24 87 12 80 00 	movl   $0x801287,(%esp)
  80042d:	e8 0d 00 00 00       	call   80043f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800432:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800435:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800438:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80043b:	89 ec                	mov    %ebp,%esp
  80043d:	5d                   	pop    %ebp
  80043e:	c3                   	ret    

0080043f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80043f:	55                   	push   %ebp
  800440:	89 e5                	mov    %esp,%ebp
  800442:	56                   	push   %esi
  800443:	53                   	push   %ebx
  800444:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800447:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80044a:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800450:	e8 59 ff ff ff       	call   8003ae <sys_getenvid>
  800455:	8b 55 0c             	mov    0xc(%ebp),%edx
  800458:	89 54 24 10          	mov    %edx,0x10(%esp)
  80045c:	8b 55 08             	mov    0x8(%ebp),%edx
  80045f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800463:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800467:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046b:	c7 04 24 98 12 80 00 	movl   $0x801298,(%esp)
  800472:	e8 7f 00 00 00       	call   8004f6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800477:	89 74 24 04          	mov    %esi,0x4(%esp)
  80047b:	8b 45 10             	mov    0x10(%ebp),%eax
  80047e:	89 04 24             	mov    %eax,(%esp)
  800481:	e8 0f 00 00 00       	call   800495 <vcprintf>
	cprintf("\n");
  800486:	c7 04 24 bc 12 80 00 	movl   $0x8012bc,(%esp)
  80048d:	e8 64 00 00 00       	call   8004f6 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800492:	cc                   	int3   
  800493:	eb fd                	jmp    800492 <_panic+0x53>

00800495 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800495:	55                   	push   %ebp
  800496:	89 e5                	mov    %esp,%ebp
  800498:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80049e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004a5:	00 00 00 
	b.cnt = 0;
  8004a8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004af:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004b2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b5:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8004bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004c0:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004c6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004ca:	c7 04 24 10 05 80 00 	movl   $0x800510,(%esp)
  8004d1:	e8 d7 01 00 00       	call   8006ad <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004d6:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004dc:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004e0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004e6:	89 04 24             	mov    %eax,(%esp)
  8004e9:	e8 ed fb ff ff       	call   8000db <sys_cputs>

	return b.cnt;
}
  8004ee:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8004f4:	c9                   	leave  
  8004f5:	c3                   	ret    

008004f6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8004f6:	55                   	push   %ebp
  8004f7:	89 e5                	mov    %esp,%ebp
  8004f9:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8004fc:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8004ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800503:	8b 45 08             	mov    0x8(%ebp),%eax
  800506:	89 04 24             	mov    %eax,(%esp)
  800509:	e8 87 ff ff ff       	call   800495 <vcprintf>
	va_end(ap);

	return cnt;
}
  80050e:	c9                   	leave  
  80050f:	c3                   	ret    

00800510 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800510:	55                   	push   %ebp
  800511:	89 e5                	mov    %esp,%ebp
  800513:	53                   	push   %ebx
  800514:	83 ec 14             	sub    $0x14,%esp
  800517:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80051a:	8b 03                	mov    (%ebx),%eax
  80051c:	8b 55 08             	mov    0x8(%ebp),%edx
  80051f:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800523:	83 c0 01             	add    $0x1,%eax
  800526:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800528:	3d ff 00 00 00       	cmp    $0xff,%eax
  80052d:	75 19                	jne    800548 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80052f:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800536:	00 
  800537:	8d 43 08             	lea    0x8(%ebx),%eax
  80053a:	89 04 24             	mov    %eax,(%esp)
  80053d:	e8 99 fb ff ff       	call   8000db <sys_cputs>
		b->idx = 0;
  800542:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800548:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80054c:	83 c4 14             	add    $0x14,%esp
  80054f:	5b                   	pop    %ebx
  800550:	5d                   	pop    %ebp
  800551:	c3                   	ret    
  800552:	66 90                	xchg   %ax,%ax
  800554:	66 90                	xchg   %ax,%ax
  800556:	66 90                	xchg   %ax,%ax
  800558:	66 90                	xchg   %ax,%ax
  80055a:	66 90                	xchg   %ax,%ax
  80055c:	66 90                	xchg   %ax,%ax
  80055e:	66 90                	xchg   %ax,%ax

00800560 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800560:	55                   	push   %ebp
  800561:	89 e5                	mov    %esp,%ebp
  800563:	57                   	push   %edi
  800564:	56                   	push   %esi
  800565:	53                   	push   %ebx
  800566:	83 ec 4c             	sub    $0x4c,%esp
  800569:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80056c:	89 d6                	mov    %edx,%esi
  80056e:	8b 45 08             	mov    0x8(%ebp),%eax
  800571:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800574:	8b 55 0c             	mov    0xc(%ebp),%edx
  800577:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80057a:	8b 45 10             	mov    0x10(%ebp),%eax
  80057d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800580:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800583:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800586:	b9 00 00 00 00       	mov    $0x0,%ecx
  80058b:	39 d1                	cmp    %edx,%ecx
  80058d:	72 15                	jb     8005a4 <printnum+0x44>
  80058f:	77 07                	ja     800598 <printnum+0x38>
  800591:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800594:	39 d0                	cmp    %edx,%eax
  800596:	76 0c                	jbe    8005a4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800598:	83 eb 01             	sub    $0x1,%ebx
  80059b:	85 db                	test   %ebx,%ebx
  80059d:	8d 76 00             	lea    0x0(%esi),%esi
  8005a0:	7f 61                	jg     800603 <printnum+0xa3>
  8005a2:	eb 70                	jmp    800614 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005a4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8005a8:	83 eb 01             	sub    $0x1,%ebx
  8005ab:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005af:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005b3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8005b7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8005bb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8005be:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8005c1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005c4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005c8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005cf:	00 
  8005d0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005d3:	89 04 24             	mov    %eax,(%esp)
  8005d6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005d9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005dd:	e8 fe 09 00 00       	call   800fe0 <__udivdi3>
  8005e2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005e5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005e8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005ec:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005f0:	89 04 24             	mov    %eax,(%esp)
  8005f3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005f7:	89 f2                	mov    %esi,%edx
  8005f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8005fc:	e8 5f ff ff ff       	call   800560 <printnum>
  800601:	eb 11                	jmp    800614 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800603:	89 74 24 04          	mov    %esi,0x4(%esp)
  800607:	89 3c 24             	mov    %edi,(%esp)
  80060a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80060d:	83 eb 01             	sub    $0x1,%ebx
  800610:	85 db                	test   %ebx,%ebx
  800612:	7f ef                	jg     800603 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800614:	89 74 24 04          	mov    %esi,0x4(%esp)
  800618:	8b 74 24 04          	mov    0x4(%esp),%esi
  80061c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80061f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800623:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80062a:	00 
  80062b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80062e:	89 14 24             	mov    %edx,(%esp)
  800631:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800634:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800638:	e8 d3 0a 00 00       	call   801110 <__umoddi3>
  80063d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800641:	0f be 80 be 12 80 00 	movsbl 0x8012be(%eax),%eax
  800648:	89 04 24             	mov    %eax,(%esp)
  80064b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80064e:	83 c4 4c             	add    $0x4c,%esp
  800651:	5b                   	pop    %ebx
  800652:	5e                   	pop    %esi
  800653:	5f                   	pop    %edi
  800654:	5d                   	pop    %ebp
  800655:	c3                   	ret    

00800656 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800656:	55                   	push   %ebp
  800657:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800659:	83 fa 01             	cmp    $0x1,%edx
  80065c:	7e 0e                	jle    80066c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80065e:	8b 10                	mov    (%eax),%edx
  800660:	8d 4a 08             	lea    0x8(%edx),%ecx
  800663:	89 08                	mov    %ecx,(%eax)
  800665:	8b 02                	mov    (%edx),%eax
  800667:	8b 52 04             	mov    0x4(%edx),%edx
  80066a:	eb 22                	jmp    80068e <getuint+0x38>
	else if (lflag)
  80066c:	85 d2                	test   %edx,%edx
  80066e:	74 10                	je     800680 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800670:	8b 10                	mov    (%eax),%edx
  800672:	8d 4a 04             	lea    0x4(%edx),%ecx
  800675:	89 08                	mov    %ecx,(%eax)
  800677:	8b 02                	mov    (%edx),%eax
  800679:	ba 00 00 00 00       	mov    $0x0,%edx
  80067e:	eb 0e                	jmp    80068e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800680:	8b 10                	mov    (%eax),%edx
  800682:	8d 4a 04             	lea    0x4(%edx),%ecx
  800685:	89 08                	mov    %ecx,(%eax)
  800687:	8b 02                	mov    (%edx),%eax
  800689:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80068e:	5d                   	pop    %ebp
  80068f:	c3                   	ret    

00800690 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800690:	55                   	push   %ebp
  800691:	89 e5                	mov    %esp,%ebp
  800693:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800696:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80069a:	8b 10                	mov    (%eax),%edx
  80069c:	3b 50 04             	cmp    0x4(%eax),%edx
  80069f:	73 0a                	jae    8006ab <sprintputch+0x1b>
		*b->buf++ = ch;
  8006a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006a4:	88 0a                	mov    %cl,(%edx)
  8006a6:	83 c2 01             	add    $0x1,%edx
  8006a9:	89 10                	mov    %edx,(%eax)
}
  8006ab:	5d                   	pop    %ebp
  8006ac:	c3                   	ret    

008006ad <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006ad:	55                   	push   %ebp
  8006ae:	89 e5                	mov    %esp,%ebp
  8006b0:	57                   	push   %edi
  8006b1:	56                   	push   %esi
  8006b2:	53                   	push   %ebx
  8006b3:	83 ec 5c             	sub    $0x5c,%esp
  8006b6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8006bc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8006bf:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8006c6:	eb 11                	jmp    8006d9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006c8:	85 c0                	test   %eax,%eax
  8006ca:	0f 84 16 04 00 00    	je     800ae6 <vprintfmt+0x439>
				return;
			putch(ch, putdat);
  8006d0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006d4:	89 04 24             	mov    %eax,(%esp)
  8006d7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006d9:	0f b6 03             	movzbl (%ebx),%eax
  8006dc:	83 c3 01             	add    $0x1,%ebx
  8006df:	83 f8 25             	cmp    $0x25,%eax
  8006e2:	75 e4                	jne    8006c8 <vprintfmt+0x1b>
  8006e4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8006eb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8006f2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8006f7:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8006fb:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800702:	eb 06                	jmp    80070a <vprintfmt+0x5d>
  800704:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800708:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80070a:	0f b6 13             	movzbl (%ebx),%edx
  80070d:	0f b6 c2             	movzbl %dl,%eax
  800710:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800713:	8d 43 01             	lea    0x1(%ebx),%eax
  800716:	83 ea 23             	sub    $0x23,%edx
  800719:	80 fa 55             	cmp    $0x55,%dl
  80071c:	0f 87 a7 03 00 00    	ja     800ac9 <vprintfmt+0x41c>
  800722:	0f b6 d2             	movzbl %dl,%edx
  800725:	ff 24 95 80 13 80 00 	jmp    *0x801380(,%edx,4)
  80072c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800730:	eb d6                	jmp    800708 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800732:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800735:	83 ea 30             	sub    $0x30,%edx
  800738:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80073b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80073e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800741:	83 fb 09             	cmp    $0x9,%ebx
  800744:	77 54                	ja     80079a <vprintfmt+0xed>
  800746:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800749:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80074c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80074f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800752:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800756:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800759:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80075c:	83 fb 09             	cmp    $0x9,%ebx
  80075f:	76 eb                	jbe    80074c <vprintfmt+0x9f>
  800761:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800764:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800767:	eb 31                	jmp    80079a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800769:	8b 55 14             	mov    0x14(%ebp),%edx
  80076c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80076f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800772:	8b 12                	mov    (%edx),%edx
  800774:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800777:	eb 21                	jmp    80079a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800779:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80077d:	ba 00 00 00 00       	mov    $0x0,%edx
  800782:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  800786:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800789:	e9 7a ff ff ff       	jmp    800708 <vprintfmt+0x5b>
  80078e:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800795:	e9 6e ff ff ff       	jmp    800708 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80079a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80079e:	0f 89 64 ff ff ff    	jns    800708 <vprintfmt+0x5b>
  8007a4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007a7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007aa:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8007ad:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007b0:	e9 53 ff ff ff       	jmp    800708 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007b5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8007b8:	e9 4b ff ff ff       	jmp    800708 <vprintfmt+0x5b>
  8007bd:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c3:	8d 50 04             	lea    0x4(%eax),%edx
  8007c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007c9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007cd:	8b 00                	mov    (%eax),%eax
  8007cf:	89 04 24             	mov    %eax,(%esp)
  8007d2:	ff d7                	call   *%edi
  8007d4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8007d7:	e9 fd fe ff ff       	jmp    8006d9 <vprintfmt+0x2c>
  8007dc:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007df:	8b 45 14             	mov    0x14(%ebp),%eax
  8007e2:	8d 50 04             	lea    0x4(%eax),%edx
  8007e5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e8:	8b 00                	mov    (%eax),%eax
  8007ea:	89 c2                	mov    %eax,%edx
  8007ec:	c1 fa 1f             	sar    $0x1f,%edx
  8007ef:	31 d0                	xor    %edx,%eax
  8007f1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8007f3:	83 f8 08             	cmp    $0x8,%eax
  8007f6:	7f 0b                	jg     800803 <vprintfmt+0x156>
  8007f8:	8b 14 85 e0 14 80 00 	mov    0x8014e0(,%eax,4),%edx
  8007ff:	85 d2                	test   %edx,%edx
  800801:	75 20                	jne    800823 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800803:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800807:	c7 44 24 08 cf 12 80 	movl   $0x8012cf,0x8(%esp)
  80080e:	00 
  80080f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800813:	89 3c 24             	mov    %edi,(%esp)
  800816:	e8 53 03 00 00       	call   800b6e <printfmt>
  80081b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80081e:	e9 b6 fe ff ff       	jmp    8006d9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800823:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800827:	c7 44 24 08 d8 12 80 	movl   $0x8012d8,0x8(%esp)
  80082e:	00 
  80082f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800833:	89 3c 24             	mov    %edi,(%esp)
  800836:	e8 33 03 00 00       	call   800b6e <printfmt>
  80083b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80083e:	e9 96 fe ff ff       	jmp    8006d9 <vprintfmt+0x2c>
  800843:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800846:	89 c3                	mov    %eax,%ebx
  800848:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80084b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80084e:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800851:	8b 45 14             	mov    0x14(%ebp),%eax
  800854:	8d 50 04             	lea    0x4(%eax),%edx
  800857:	89 55 14             	mov    %edx,0x14(%ebp)
  80085a:	8b 00                	mov    (%eax),%eax
  80085c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80085f:	85 c0                	test   %eax,%eax
  800861:	b8 db 12 80 00       	mov    $0x8012db,%eax
  800866:	0f 45 45 c4          	cmovne -0x3c(%ebp),%eax
  80086a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80086d:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800871:	7e 06                	jle    800879 <vprintfmt+0x1cc>
  800873:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800877:	75 13                	jne    80088c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800879:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80087c:	0f be 02             	movsbl (%edx),%eax
  80087f:	85 c0                	test   %eax,%eax
  800881:	0f 85 9b 00 00 00    	jne    800922 <vprintfmt+0x275>
  800887:	e9 88 00 00 00       	jmp    800914 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80088c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800890:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  800893:	89 0c 24             	mov    %ecx,(%esp)
  800896:	e8 20 03 00 00       	call   800bbb <strnlen>
  80089b:	8b 55 c0             	mov    -0x40(%ebp),%edx
  80089e:	29 c2                	sub    %eax,%edx
  8008a0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008a3:	85 d2                	test   %edx,%edx
  8008a5:	7e d2                	jle    800879 <vprintfmt+0x1cc>
					putch(padc, putdat);
  8008a7:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  8008ab:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008ae:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8008b1:	89 d3                	mov    %edx,%ebx
  8008b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008b7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8008ba:	89 04 24             	mov    %eax,(%esp)
  8008bd:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008bf:	83 eb 01             	sub    $0x1,%ebx
  8008c2:	85 db                	test   %ebx,%ebx
  8008c4:	7f ed                	jg     8008b3 <vprintfmt+0x206>
  8008c6:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8008c9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8008d0:	eb a7                	jmp    800879 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008d2:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8008d6:	74 1a                	je     8008f2 <vprintfmt+0x245>
  8008d8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8008db:	83 fa 5e             	cmp    $0x5e,%edx
  8008de:	76 12                	jbe    8008f2 <vprintfmt+0x245>
					putch('?', putdat);
  8008e0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008e4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008eb:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008ee:	66 90                	xchg   %ax,%ax
  8008f0:	eb 0a                	jmp    8008fc <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  8008f2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008f6:	89 04 24             	mov    %eax,(%esp)
  8008f9:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008fc:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800900:	0f be 03             	movsbl (%ebx),%eax
  800903:	85 c0                	test   %eax,%eax
  800905:	74 05                	je     80090c <vprintfmt+0x25f>
  800907:	83 c3 01             	add    $0x1,%ebx
  80090a:	eb 29                	jmp    800935 <vprintfmt+0x288>
  80090c:	89 fe                	mov    %edi,%esi
  80090e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800911:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800914:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800918:	7f 2e                	jg     800948 <vprintfmt+0x29b>
  80091a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80091d:	e9 b7 fd ff ff       	jmp    8006d9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800922:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800925:	83 c2 01             	add    $0x1,%edx
  800928:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80092b:	89 f7                	mov    %esi,%edi
  80092d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800930:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800933:	89 d3                	mov    %edx,%ebx
  800935:	85 f6                	test   %esi,%esi
  800937:	78 99                	js     8008d2 <vprintfmt+0x225>
  800939:	83 ee 01             	sub    $0x1,%esi
  80093c:	79 94                	jns    8008d2 <vprintfmt+0x225>
  80093e:	89 fe                	mov    %edi,%esi
  800940:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800943:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800946:	eb cc                	jmp    800914 <vprintfmt+0x267>
  800948:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80094b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80094e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800952:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800959:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095b:	83 eb 01             	sub    $0x1,%ebx
  80095e:	85 db                	test   %ebx,%ebx
  800960:	7f ec                	jg     80094e <vprintfmt+0x2a1>
  800962:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800965:	e9 6f fd ff ff       	jmp    8006d9 <vprintfmt+0x2c>
  80096a:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80096d:	83 f9 01             	cmp    $0x1,%ecx
  800970:	7e 16                	jle    800988 <vprintfmt+0x2db>
		return va_arg(*ap, long long);
  800972:	8b 45 14             	mov    0x14(%ebp),%eax
  800975:	8d 50 08             	lea    0x8(%eax),%edx
  800978:	89 55 14             	mov    %edx,0x14(%ebp)
  80097b:	8b 10                	mov    (%eax),%edx
  80097d:	8b 48 04             	mov    0x4(%eax),%ecx
  800980:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800983:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800986:	eb 32                	jmp    8009ba <vprintfmt+0x30d>
	else if (lflag)
  800988:	85 c9                	test   %ecx,%ecx
  80098a:	74 18                	je     8009a4 <vprintfmt+0x2f7>
		return va_arg(*ap, long);
  80098c:	8b 45 14             	mov    0x14(%ebp),%eax
  80098f:	8d 50 04             	lea    0x4(%eax),%edx
  800992:	89 55 14             	mov    %edx,0x14(%ebp)
  800995:	8b 00                	mov    (%eax),%eax
  800997:	89 45 d0             	mov    %eax,-0x30(%ebp)
  80099a:	89 c1                	mov    %eax,%ecx
  80099c:	c1 f9 1f             	sar    $0x1f,%ecx
  80099f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8009a2:	eb 16                	jmp    8009ba <vprintfmt+0x30d>
	else
		return va_arg(*ap, int);
  8009a4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a7:	8d 50 04             	lea    0x4(%eax),%edx
  8009aa:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ad:	8b 00                	mov    (%eax),%eax
  8009af:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009b2:	89 c2                	mov    %eax,%edx
  8009b4:	c1 fa 1f             	sar    $0x1f,%edx
  8009b7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009ba:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8009bd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8009c0:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8009c5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8009c9:	0f 89 b8 00 00 00    	jns    800a87 <vprintfmt+0x3da>
				putch('-', putdat);
  8009cf:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009d3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009da:	ff d7                	call   *%edi
				num = -(long long) num;
  8009dc:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8009df:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8009e2:	f7 d9                	neg    %ecx
  8009e4:	83 d3 00             	adc    $0x0,%ebx
  8009e7:	f7 db                	neg    %ebx
  8009e9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009ee:	e9 94 00 00 00       	jmp    800a87 <vprintfmt+0x3da>
  8009f3:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009f6:	89 ca                	mov    %ecx,%edx
  8009f8:	8d 45 14             	lea    0x14(%ebp),%eax
  8009fb:	e8 56 fc ff ff       	call   800656 <getuint>
  800a00:	89 c1                	mov    %eax,%ecx
  800a02:	89 d3                	mov    %edx,%ebx
  800a04:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800a09:	eb 7c                	jmp    800a87 <vprintfmt+0x3da>
  800a0b:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800a0e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a12:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800a19:	ff d7                	call   *%edi
			putch('X', putdat);
  800a1b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a1f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800a26:	ff d7                	call   *%edi
			putch('X', putdat);
  800a28:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a2c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800a33:	ff d7                	call   *%edi
  800a35:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800a38:	e9 9c fc ff ff       	jmp    8006d9 <vprintfmt+0x2c>
  800a3d:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800a40:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a44:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a4b:	ff d7                	call   *%edi
			putch('x', putdat);
  800a4d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a51:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a58:	ff d7                	call   *%edi
			num = (unsigned long long)
  800a5a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a5d:	8d 50 04             	lea    0x4(%eax),%edx
  800a60:	89 55 14             	mov    %edx,0x14(%ebp)
  800a63:	8b 08                	mov    (%eax),%ecx
  800a65:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a6a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a6f:	eb 16                	jmp    800a87 <vprintfmt+0x3da>
  800a71:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a74:	89 ca                	mov    %ecx,%edx
  800a76:	8d 45 14             	lea    0x14(%ebp),%eax
  800a79:	e8 d8 fb ff ff       	call   800656 <getuint>
  800a7e:	89 c1                	mov    %eax,%ecx
  800a80:	89 d3                	mov    %edx,%ebx
  800a82:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a87:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800a8b:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a8f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a92:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a96:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a9a:	89 0c 24             	mov    %ecx,(%esp)
  800a9d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800aa1:	89 f2                	mov    %esi,%edx
  800aa3:	89 f8                	mov    %edi,%eax
  800aa5:	e8 b6 fa ff ff       	call   800560 <printnum>
  800aaa:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800aad:	e9 27 fc ff ff       	jmp    8006d9 <vprintfmt+0x2c>
  800ab2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800ab5:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ab8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800abc:	89 14 24             	mov    %edx,(%esp)
  800abf:	ff d7                	call   *%edi
  800ac1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800ac4:	e9 10 fc ff ff       	jmp    8006d9 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ac9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800acd:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ad4:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ad6:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ad9:	80 38 25             	cmpb   $0x25,(%eax)
  800adc:	0f 84 f7 fb ff ff    	je     8006d9 <vprintfmt+0x2c>
  800ae2:	89 c3                	mov    %eax,%ebx
  800ae4:	eb f0                	jmp    800ad6 <vprintfmt+0x429>
				/* do nothing */;
			break;
		}
	}
}
  800ae6:	83 c4 5c             	add    $0x5c,%esp
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	83 ec 28             	sub    $0x28,%esp
  800af4:	8b 45 08             	mov    0x8(%ebp),%eax
  800af7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800afa:	85 c0                	test   %eax,%eax
  800afc:	74 04                	je     800b02 <vsnprintf+0x14>
  800afe:	85 d2                	test   %edx,%edx
  800b00:	7f 07                	jg     800b09 <vsnprintf+0x1b>
  800b02:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b07:	eb 3b                	jmp    800b44 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b09:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b0c:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800b10:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b13:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b1a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b21:	8b 45 10             	mov    0x10(%ebp),%eax
  800b24:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b28:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b2b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b2f:	c7 04 24 90 06 80 00 	movl   $0x800690,(%esp)
  800b36:	e8 72 fb ff ff       	call   8006ad <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b3b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b3e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b41:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b44:	c9                   	leave  
  800b45:	c3                   	ret    

00800b46 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800b4c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800b4f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b53:	8b 45 10             	mov    0x10(%ebp),%eax
  800b56:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b61:	8b 45 08             	mov    0x8(%ebp),%eax
  800b64:	89 04 24             	mov    %eax,(%esp)
  800b67:	e8 82 ff ff ff       	call   800aee <vsnprintf>
	va_end(ap);

	return rc;
}
  800b6c:	c9                   	leave  
  800b6d:	c3                   	ret    

00800b6e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800b74:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800b77:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b7b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b7e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b82:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b85:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b89:	8b 45 08             	mov    0x8(%ebp),%eax
  800b8c:	89 04 24             	mov    %eax,(%esp)
  800b8f:	e8 19 fb ff ff       	call   8006ad <vprintfmt>
	va_end(ap);
}
  800b94:	c9                   	leave  
  800b95:	c3                   	ret    
  800b96:	66 90                	xchg   %ax,%ax
  800b98:	66 90                	xchg   %ax,%ax
  800b9a:	66 90                	xchg   %ax,%ax
  800b9c:	66 90                	xchg   %ax,%ax
  800b9e:	66 90                	xchg   %ax,%ax

00800ba0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800ba0:	55                   	push   %ebp
  800ba1:	89 e5                	mov    %esp,%ebp
  800ba3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800ba6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bab:	80 3a 00             	cmpb   $0x0,(%edx)
  800bae:	74 09                	je     800bb9 <strlen+0x19>
		n++;
  800bb0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bb3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bb7:	75 f7                	jne    800bb0 <strlen+0x10>
		n++;
	return n;
}
  800bb9:	5d                   	pop    %ebp
  800bba:	c3                   	ret    

00800bbb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bbb:	55                   	push   %ebp
  800bbc:	89 e5                	mov    %esp,%ebp
  800bbe:	53                   	push   %ebx
  800bbf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bc5:	85 c9                	test   %ecx,%ecx
  800bc7:	74 19                	je     800be2 <strnlen+0x27>
  800bc9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800bcc:	74 14                	je     800be2 <strnlen+0x27>
  800bce:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800bd3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bd6:	39 c8                	cmp    %ecx,%eax
  800bd8:	74 0d                	je     800be7 <strnlen+0x2c>
  800bda:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800bde:	75 f3                	jne    800bd3 <strnlen+0x18>
  800be0:	eb 05                	jmp    800be7 <strnlen+0x2c>
  800be2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800be7:	5b                   	pop    %ebx
  800be8:	5d                   	pop    %ebp
  800be9:	c3                   	ret    

00800bea <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bea:	55                   	push   %ebp
  800beb:	89 e5                	mov    %esp,%ebp
  800bed:	53                   	push   %ebx
  800bee:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bf4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800bf9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800bfd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c00:	83 c2 01             	add    $0x1,%edx
  800c03:	84 c9                	test   %cl,%cl
  800c05:	75 f2                	jne    800bf9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c07:	5b                   	pop    %ebx
  800c08:	5d                   	pop    %ebp
  800c09:	c3                   	ret    

00800c0a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c0a:	55                   	push   %ebp
  800c0b:	89 e5                	mov    %esp,%ebp
  800c0d:	53                   	push   %ebx
  800c0e:	83 ec 08             	sub    $0x8,%esp
  800c11:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c14:	89 1c 24             	mov    %ebx,(%esp)
  800c17:	e8 84 ff ff ff       	call   800ba0 <strlen>
	strcpy(dst + len, src);
  800c1c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c1f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c23:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800c26:	89 04 24             	mov    %eax,(%esp)
  800c29:	e8 bc ff ff ff       	call   800bea <strcpy>
	return dst;
}
  800c2e:	89 d8                	mov    %ebx,%eax
  800c30:	83 c4 08             	add    $0x8,%esp
  800c33:	5b                   	pop    %ebx
  800c34:	5d                   	pop    %ebp
  800c35:	c3                   	ret    

00800c36 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	56                   	push   %esi
  800c3a:	53                   	push   %ebx
  800c3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c41:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c44:	85 f6                	test   %esi,%esi
  800c46:	74 18                	je     800c60 <strncpy+0x2a>
  800c48:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800c4d:	0f b6 1a             	movzbl (%edx),%ebx
  800c50:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c53:	80 3a 01             	cmpb   $0x1,(%edx)
  800c56:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c59:	83 c1 01             	add    $0x1,%ecx
  800c5c:	39 ce                	cmp    %ecx,%esi
  800c5e:	77 ed                	ja     800c4d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c60:	5b                   	pop    %ebx
  800c61:	5e                   	pop    %esi
  800c62:	5d                   	pop    %ebp
  800c63:	c3                   	ret    

00800c64 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c64:	55                   	push   %ebp
  800c65:	89 e5                	mov    %esp,%ebp
  800c67:	56                   	push   %esi
  800c68:	53                   	push   %ebx
  800c69:	8b 75 08             	mov    0x8(%ebp),%esi
  800c6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c6f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c72:	89 f0                	mov    %esi,%eax
  800c74:	85 c9                	test   %ecx,%ecx
  800c76:	74 27                	je     800c9f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800c78:	83 e9 01             	sub    $0x1,%ecx
  800c7b:	74 1d                	je     800c9a <strlcpy+0x36>
  800c7d:	0f b6 1a             	movzbl (%edx),%ebx
  800c80:	84 db                	test   %bl,%bl
  800c82:	74 16                	je     800c9a <strlcpy+0x36>
			*dst++ = *src++;
  800c84:	88 18                	mov    %bl,(%eax)
  800c86:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c89:	83 e9 01             	sub    $0x1,%ecx
  800c8c:	74 0e                	je     800c9c <strlcpy+0x38>
			*dst++ = *src++;
  800c8e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c91:	0f b6 1a             	movzbl (%edx),%ebx
  800c94:	84 db                	test   %bl,%bl
  800c96:	75 ec                	jne    800c84 <strlcpy+0x20>
  800c98:	eb 02                	jmp    800c9c <strlcpy+0x38>
  800c9a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800c9c:	c6 00 00             	movb   $0x0,(%eax)
  800c9f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800ca1:	5b                   	pop    %ebx
  800ca2:	5e                   	pop    %esi
  800ca3:	5d                   	pop    %ebp
  800ca4:	c3                   	ret    

00800ca5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800ca5:	55                   	push   %ebp
  800ca6:	89 e5                	mov    %esp,%ebp
  800ca8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cab:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800cae:	0f b6 01             	movzbl (%ecx),%eax
  800cb1:	84 c0                	test   %al,%al
  800cb3:	74 15                	je     800cca <strcmp+0x25>
  800cb5:	3a 02                	cmp    (%edx),%al
  800cb7:	75 11                	jne    800cca <strcmp+0x25>
		p++, q++;
  800cb9:	83 c1 01             	add    $0x1,%ecx
  800cbc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800cbf:	0f b6 01             	movzbl (%ecx),%eax
  800cc2:	84 c0                	test   %al,%al
  800cc4:	74 04                	je     800cca <strcmp+0x25>
  800cc6:	3a 02                	cmp    (%edx),%al
  800cc8:	74 ef                	je     800cb9 <strcmp+0x14>
  800cca:	0f b6 c0             	movzbl %al,%eax
  800ccd:	0f b6 12             	movzbl (%edx),%edx
  800cd0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800cd2:	5d                   	pop    %ebp
  800cd3:	c3                   	ret    

00800cd4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800cd4:	55                   	push   %ebp
  800cd5:	89 e5                	mov    %esp,%ebp
  800cd7:	53                   	push   %ebx
  800cd8:	8b 55 08             	mov    0x8(%ebp),%edx
  800cdb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cde:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800ce1:	85 c0                	test   %eax,%eax
  800ce3:	74 23                	je     800d08 <strncmp+0x34>
  800ce5:	0f b6 1a             	movzbl (%edx),%ebx
  800ce8:	84 db                	test   %bl,%bl
  800cea:	74 25                	je     800d11 <strncmp+0x3d>
  800cec:	3a 19                	cmp    (%ecx),%bl
  800cee:	75 21                	jne    800d11 <strncmp+0x3d>
  800cf0:	83 e8 01             	sub    $0x1,%eax
  800cf3:	74 13                	je     800d08 <strncmp+0x34>
		n--, p++, q++;
  800cf5:	83 c2 01             	add    $0x1,%edx
  800cf8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800cfb:	0f b6 1a             	movzbl (%edx),%ebx
  800cfe:	84 db                	test   %bl,%bl
  800d00:	74 0f                	je     800d11 <strncmp+0x3d>
  800d02:	3a 19                	cmp    (%ecx),%bl
  800d04:	74 ea                	je     800cf0 <strncmp+0x1c>
  800d06:	eb 09                	jmp    800d11 <strncmp+0x3d>
  800d08:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d0d:	5b                   	pop    %ebx
  800d0e:	5d                   	pop    %ebp
  800d0f:	90                   	nop
  800d10:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d11:	0f b6 02             	movzbl (%edx),%eax
  800d14:	0f b6 11             	movzbl (%ecx),%edx
  800d17:	29 d0                	sub    %edx,%eax
  800d19:	eb f2                	jmp    800d0d <strncmp+0x39>

00800d1b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d1b:	55                   	push   %ebp
  800d1c:	89 e5                	mov    %esp,%ebp
  800d1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d25:	0f b6 10             	movzbl (%eax),%edx
  800d28:	84 d2                	test   %dl,%dl
  800d2a:	74 18                	je     800d44 <strchr+0x29>
		if (*s == c)
  800d2c:	38 ca                	cmp    %cl,%dl
  800d2e:	75 0a                	jne    800d3a <strchr+0x1f>
  800d30:	eb 17                	jmp    800d49 <strchr+0x2e>
  800d32:	38 ca                	cmp    %cl,%dl
  800d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d38:	74 0f                	je     800d49 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d3a:	83 c0 01             	add    $0x1,%eax
  800d3d:	0f b6 10             	movzbl (%eax),%edx
  800d40:	84 d2                	test   %dl,%dl
  800d42:	75 ee                	jne    800d32 <strchr+0x17>
  800d44:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800d49:	5d                   	pop    %ebp
  800d4a:	c3                   	ret    

00800d4b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d55:	0f b6 10             	movzbl (%eax),%edx
  800d58:	84 d2                	test   %dl,%dl
  800d5a:	74 18                	je     800d74 <strfind+0x29>
		if (*s == c)
  800d5c:	38 ca                	cmp    %cl,%dl
  800d5e:	75 0a                	jne    800d6a <strfind+0x1f>
  800d60:	eb 12                	jmp    800d74 <strfind+0x29>
  800d62:	38 ca                	cmp    %cl,%dl
  800d64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d68:	74 0a                	je     800d74 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d6a:	83 c0 01             	add    $0x1,%eax
  800d6d:	0f b6 10             	movzbl (%eax),%edx
  800d70:	84 d2                	test   %dl,%dl
  800d72:	75 ee                	jne    800d62 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d74:	5d                   	pop    %ebp
  800d75:	c3                   	ret    

00800d76 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d76:	55                   	push   %ebp
  800d77:	89 e5                	mov    %esp,%ebp
  800d79:	83 ec 0c             	sub    $0xc,%esp
  800d7c:	89 1c 24             	mov    %ebx,(%esp)
  800d7f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d83:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d87:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d8d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800d90:	85 c9                	test   %ecx,%ecx
  800d92:	74 30                	je     800dc4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800d94:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800d9a:	75 25                	jne    800dc1 <memset+0x4b>
  800d9c:	f6 c1 03             	test   $0x3,%cl
  800d9f:	75 20                	jne    800dc1 <memset+0x4b>
		c &= 0xFF;
  800da1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800da4:	89 d3                	mov    %edx,%ebx
  800da6:	c1 e3 08             	shl    $0x8,%ebx
  800da9:	89 d6                	mov    %edx,%esi
  800dab:	c1 e6 18             	shl    $0x18,%esi
  800dae:	89 d0                	mov    %edx,%eax
  800db0:	c1 e0 10             	shl    $0x10,%eax
  800db3:	09 f0                	or     %esi,%eax
  800db5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800db7:	09 d8                	or     %ebx,%eax
  800db9:	c1 e9 02             	shr    $0x2,%ecx
  800dbc:	fc                   	cld    
  800dbd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dbf:	eb 03                	jmp    800dc4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dc1:	fc                   	cld    
  800dc2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dc4:	89 f8                	mov    %edi,%eax
  800dc6:	8b 1c 24             	mov    (%esp),%ebx
  800dc9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dcd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800dd1:	89 ec                	mov    %ebp,%esp
  800dd3:	5d                   	pop    %ebp
  800dd4:	c3                   	ret    

00800dd5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800dd5:	55                   	push   %ebp
  800dd6:	89 e5                	mov    %esp,%ebp
  800dd8:	83 ec 08             	sub    $0x8,%esp
  800ddb:	89 34 24             	mov    %esi,(%esp)
  800dde:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800de2:	8b 45 08             	mov    0x8(%ebp),%eax
  800de5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800de8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800deb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800ded:	39 c6                	cmp    %eax,%esi
  800def:	73 35                	jae    800e26 <memmove+0x51>
  800df1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800df4:	39 d0                	cmp    %edx,%eax
  800df6:	73 2e                	jae    800e26 <memmove+0x51>
		s += n;
		d += n;
  800df8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800dfa:	f6 c2 03             	test   $0x3,%dl
  800dfd:	75 1b                	jne    800e1a <memmove+0x45>
  800dff:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e05:	75 13                	jne    800e1a <memmove+0x45>
  800e07:	f6 c1 03             	test   $0x3,%cl
  800e0a:	75 0e                	jne    800e1a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800e0c:	83 ef 04             	sub    $0x4,%edi
  800e0f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e12:	c1 e9 02             	shr    $0x2,%ecx
  800e15:	fd                   	std    
  800e16:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e18:	eb 09                	jmp    800e23 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e1a:	83 ef 01             	sub    $0x1,%edi
  800e1d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e20:	fd                   	std    
  800e21:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e23:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e24:	eb 20                	jmp    800e46 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e26:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e2c:	75 15                	jne    800e43 <memmove+0x6e>
  800e2e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e34:	75 0d                	jne    800e43 <memmove+0x6e>
  800e36:	f6 c1 03             	test   $0x3,%cl
  800e39:	75 08                	jne    800e43 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800e3b:	c1 e9 02             	shr    $0x2,%ecx
  800e3e:	fc                   	cld    
  800e3f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e41:	eb 03                	jmp    800e46 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e43:	fc                   	cld    
  800e44:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e46:	8b 34 24             	mov    (%esp),%esi
  800e49:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e4d:	89 ec                	mov    %ebp,%esp
  800e4f:	5d                   	pop    %ebp
  800e50:	c3                   	ret    

00800e51 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e51:	55                   	push   %ebp
  800e52:	89 e5                	mov    %esp,%ebp
  800e54:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e57:	8b 45 10             	mov    0x10(%ebp),%eax
  800e5a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e61:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e65:	8b 45 08             	mov    0x8(%ebp),%eax
  800e68:	89 04 24             	mov    %eax,(%esp)
  800e6b:	e8 65 ff ff ff       	call   800dd5 <memmove>
}
  800e70:	c9                   	leave  
  800e71:	c3                   	ret    

00800e72 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e72:	55                   	push   %ebp
  800e73:	89 e5                	mov    %esp,%ebp
  800e75:	57                   	push   %edi
  800e76:	56                   	push   %esi
  800e77:	53                   	push   %ebx
  800e78:	8b 75 08             	mov    0x8(%ebp),%esi
  800e7b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e7e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e81:	85 c9                	test   %ecx,%ecx
  800e83:	74 36                	je     800ebb <memcmp+0x49>
		if (*s1 != *s2)
  800e85:	0f b6 06             	movzbl (%esi),%eax
  800e88:	0f b6 1f             	movzbl (%edi),%ebx
  800e8b:	38 d8                	cmp    %bl,%al
  800e8d:	74 20                	je     800eaf <memcmp+0x3d>
  800e8f:	eb 14                	jmp    800ea5 <memcmp+0x33>
  800e91:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800e96:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800e9b:	83 c2 01             	add    $0x1,%edx
  800e9e:	83 e9 01             	sub    $0x1,%ecx
  800ea1:	38 d8                	cmp    %bl,%al
  800ea3:	74 12                	je     800eb7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800ea5:	0f b6 c0             	movzbl %al,%eax
  800ea8:	0f b6 db             	movzbl %bl,%ebx
  800eab:	29 d8                	sub    %ebx,%eax
  800ead:	eb 11                	jmp    800ec0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eaf:	83 e9 01             	sub    $0x1,%ecx
  800eb2:	ba 00 00 00 00       	mov    $0x0,%edx
  800eb7:	85 c9                	test   %ecx,%ecx
  800eb9:	75 d6                	jne    800e91 <memcmp+0x1f>
  800ebb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800ec0:	5b                   	pop    %ebx
  800ec1:	5e                   	pop    %esi
  800ec2:	5f                   	pop    %edi
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800ecb:	89 c2                	mov    %eax,%edx
  800ecd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ed0:	39 d0                	cmp    %edx,%eax
  800ed2:	73 15                	jae    800ee9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ed4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ed8:	38 08                	cmp    %cl,(%eax)
  800eda:	75 06                	jne    800ee2 <memfind+0x1d>
  800edc:	eb 0b                	jmp    800ee9 <memfind+0x24>
  800ede:	38 08                	cmp    %cl,(%eax)
  800ee0:	74 07                	je     800ee9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ee2:	83 c0 01             	add    $0x1,%eax
  800ee5:	39 c2                	cmp    %eax,%edx
  800ee7:	77 f5                	ja     800ede <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ee9:	5d                   	pop    %ebp
  800eea:	c3                   	ret    

00800eeb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	57                   	push   %edi
  800eef:	56                   	push   %esi
  800ef0:	53                   	push   %ebx
  800ef1:	83 ec 04             	sub    $0x4,%esp
  800ef4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ef7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800efa:	0f b6 02             	movzbl (%edx),%eax
  800efd:	3c 20                	cmp    $0x20,%al
  800eff:	74 04                	je     800f05 <strtol+0x1a>
  800f01:	3c 09                	cmp    $0x9,%al
  800f03:	75 0e                	jne    800f13 <strtol+0x28>
		s++;
  800f05:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f08:	0f b6 02             	movzbl (%edx),%eax
  800f0b:	3c 20                	cmp    $0x20,%al
  800f0d:	74 f6                	je     800f05 <strtol+0x1a>
  800f0f:	3c 09                	cmp    $0x9,%al
  800f11:	74 f2                	je     800f05 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f13:	3c 2b                	cmp    $0x2b,%al
  800f15:	75 0c                	jne    800f23 <strtol+0x38>
		s++;
  800f17:	83 c2 01             	add    $0x1,%edx
  800f1a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800f21:	eb 15                	jmp    800f38 <strtol+0x4d>
	else if (*s == '-')
  800f23:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800f2a:	3c 2d                	cmp    $0x2d,%al
  800f2c:	75 0a                	jne    800f38 <strtol+0x4d>
		s++, neg = 1;
  800f2e:	83 c2 01             	add    $0x1,%edx
  800f31:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f38:	85 db                	test   %ebx,%ebx
  800f3a:	0f 94 c0             	sete   %al
  800f3d:	74 05                	je     800f44 <strtol+0x59>
  800f3f:	83 fb 10             	cmp    $0x10,%ebx
  800f42:	75 18                	jne    800f5c <strtol+0x71>
  800f44:	80 3a 30             	cmpb   $0x30,(%edx)
  800f47:	75 13                	jne    800f5c <strtol+0x71>
  800f49:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f4d:	8d 76 00             	lea    0x0(%esi),%esi
  800f50:	75 0a                	jne    800f5c <strtol+0x71>
		s += 2, base = 16;
  800f52:	83 c2 02             	add    $0x2,%edx
  800f55:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f5a:	eb 15                	jmp    800f71 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f5c:	84 c0                	test   %al,%al
  800f5e:	66 90                	xchg   %ax,%ax
  800f60:	74 0f                	je     800f71 <strtol+0x86>
  800f62:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f67:	80 3a 30             	cmpb   $0x30,(%edx)
  800f6a:	75 05                	jne    800f71 <strtol+0x86>
		s++, base = 8;
  800f6c:	83 c2 01             	add    $0x1,%edx
  800f6f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f71:	b8 00 00 00 00       	mov    $0x0,%eax
  800f76:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f78:	0f b6 0a             	movzbl (%edx),%ecx
  800f7b:	89 cf                	mov    %ecx,%edi
  800f7d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f80:	80 fb 09             	cmp    $0x9,%bl
  800f83:	77 08                	ja     800f8d <strtol+0xa2>
			dig = *s - '0';
  800f85:	0f be c9             	movsbl %cl,%ecx
  800f88:	83 e9 30             	sub    $0x30,%ecx
  800f8b:	eb 1e                	jmp    800fab <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800f8d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800f90:	80 fb 19             	cmp    $0x19,%bl
  800f93:	77 08                	ja     800f9d <strtol+0xb2>
			dig = *s - 'a' + 10;
  800f95:	0f be c9             	movsbl %cl,%ecx
  800f98:	83 e9 57             	sub    $0x57,%ecx
  800f9b:	eb 0e                	jmp    800fab <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800f9d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800fa0:	80 fb 19             	cmp    $0x19,%bl
  800fa3:	77 15                	ja     800fba <strtol+0xcf>
			dig = *s - 'A' + 10;
  800fa5:	0f be c9             	movsbl %cl,%ecx
  800fa8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800fab:	39 f1                	cmp    %esi,%ecx
  800fad:	7d 0b                	jge    800fba <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800faf:	83 c2 01             	add    $0x1,%edx
  800fb2:	0f af c6             	imul   %esi,%eax
  800fb5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800fb8:	eb be                	jmp    800f78 <strtol+0x8d>
  800fba:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800fbc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fc0:	74 05                	je     800fc7 <strtol+0xdc>
		*endptr = (char *) s;
  800fc2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fc5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800fc7:	89 ca                	mov    %ecx,%edx
  800fc9:	f7 da                	neg    %edx
  800fcb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800fcf:	0f 45 c2             	cmovne %edx,%eax
}
  800fd2:	83 c4 04             	add    $0x4,%esp
  800fd5:	5b                   	pop    %ebx
  800fd6:	5e                   	pop    %esi
  800fd7:	5f                   	pop    %edi
  800fd8:	5d                   	pop    %ebp
  800fd9:	c3                   	ret    
  800fda:	66 90                	xchg   %ax,%ax
  800fdc:	66 90                	xchg   %ax,%ax
  800fde:	66 90                	xchg   %ax,%ax

00800fe0 <__udivdi3>:
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	57                   	push   %edi
  800fe4:	56                   	push   %esi
  800fe5:	83 ec 10             	sub    $0x10,%esp
  800fe8:	8b 45 14             	mov    0x14(%ebp),%eax
  800feb:	8b 55 08             	mov    0x8(%ebp),%edx
  800fee:	8b 75 10             	mov    0x10(%ebp),%esi
  800ff1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	89 55 f0             	mov    %edx,-0x10(%ebp)
  800ff9:	75 35                	jne    801030 <__udivdi3+0x50>
  800ffb:	39 fe                	cmp    %edi,%esi
  800ffd:	77 61                	ja     801060 <__udivdi3+0x80>
  800fff:	85 f6                	test   %esi,%esi
  801001:	75 0b                	jne    80100e <__udivdi3+0x2e>
  801003:	b8 01 00 00 00       	mov    $0x1,%eax
  801008:	31 d2                	xor    %edx,%edx
  80100a:	f7 f6                	div    %esi
  80100c:	89 c6                	mov    %eax,%esi
  80100e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801011:	31 d2                	xor    %edx,%edx
  801013:	89 f8                	mov    %edi,%eax
  801015:	f7 f6                	div    %esi
  801017:	89 c7                	mov    %eax,%edi
  801019:	89 c8                	mov    %ecx,%eax
  80101b:	f7 f6                	div    %esi
  80101d:	89 c1                	mov    %eax,%ecx
  80101f:	89 fa                	mov    %edi,%edx
  801021:	89 c8                	mov    %ecx,%eax
  801023:	83 c4 10             	add    $0x10,%esp
  801026:	5e                   	pop    %esi
  801027:	5f                   	pop    %edi
  801028:	5d                   	pop    %ebp
  801029:	c3                   	ret    
  80102a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801030:	39 f8                	cmp    %edi,%eax
  801032:	77 1c                	ja     801050 <__udivdi3+0x70>
  801034:	0f bd d0             	bsr    %eax,%edx
  801037:	83 f2 1f             	xor    $0x1f,%edx
  80103a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80103d:	75 39                	jne    801078 <__udivdi3+0x98>
  80103f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801042:	0f 86 a0 00 00 00    	jbe    8010e8 <__udivdi3+0x108>
  801048:	39 f8                	cmp    %edi,%eax
  80104a:	0f 82 98 00 00 00    	jb     8010e8 <__udivdi3+0x108>
  801050:	31 ff                	xor    %edi,%edi
  801052:	31 c9                	xor    %ecx,%ecx
  801054:	89 c8                	mov    %ecx,%eax
  801056:	89 fa                	mov    %edi,%edx
  801058:	83 c4 10             	add    $0x10,%esp
  80105b:	5e                   	pop    %esi
  80105c:	5f                   	pop    %edi
  80105d:	5d                   	pop    %ebp
  80105e:	c3                   	ret    
  80105f:	90                   	nop
  801060:	89 d1                	mov    %edx,%ecx
  801062:	89 fa                	mov    %edi,%edx
  801064:	89 c8                	mov    %ecx,%eax
  801066:	31 ff                	xor    %edi,%edi
  801068:	f7 f6                	div    %esi
  80106a:	89 c1                	mov    %eax,%ecx
  80106c:	89 fa                	mov    %edi,%edx
  80106e:	89 c8                	mov    %ecx,%eax
  801070:	83 c4 10             	add    $0x10,%esp
  801073:	5e                   	pop    %esi
  801074:	5f                   	pop    %edi
  801075:	5d                   	pop    %ebp
  801076:	c3                   	ret    
  801077:	90                   	nop
  801078:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80107c:	89 f2                	mov    %esi,%edx
  80107e:	d3 e0                	shl    %cl,%eax
  801080:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801083:	b8 20 00 00 00       	mov    $0x20,%eax
  801088:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80108b:	89 c1                	mov    %eax,%ecx
  80108d:	d3 ea                	shr    %cl,%edx
  80108f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801093:	0b 55 ec             	or     -0x14(%ebp),%edx
  801096:	d3 e6                	shl    %cl,%esi
  801098:	89 c1                	mov    %eax,%ecx
  80109a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80109d:	89 fe                	mov    %edi,%esi
  80109f:	d3 ee                	shr    %cl,%esi
  8010a1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010a5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010ab:	d3 e7                	shl    %cl,%edi
  8010ad:	89 c1                	mov    %eax,%ecx
  8010af:	d3 ea                	shr    %cl,%edx
  8010b1:	09 d7                	or     %edx,%edi
  8010b3:	89 f2                	mov    %esi,%edx
  8010b5:	89 f8                	mov    %edi,%eax
  8010b7:	f7 75 ec             	divl   -0x14(%ebp)
  8010ba:	89 d6                	mov    %edx,%esi
  8010bc:	89 c7                	mov    %eax,%edi
  8010be:	f7 65 e8             	mull   -0x18(%ebp)
  8010c1:	39 d6                	cmp    %edx,%esi
  8010c3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010c6:	72 30                	jb     8010f8 <__udivdi3+0x118>
  8010c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010cb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010cf:	d3 e2                	shl    %cl,%edx
  8010d1:	39 c2                	cmp    %eax,%edx
  8010d3:	73 05                	jae    8010da <__udivdi3+0xfa>
  8010d5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8010d8:	74 1e                	je     8010f8 <__udivdi3+0x118>
  8010da:	89 f9                	mov    %edi,%ecx
  8010dc:	31 ff                	xor    %edi,%edi
  8010de:	e9 71 ff ff ff       	jmp    801054 <__udivdi3+0x74>
  8010e3:	90                   	nop
  8010e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010e8:	31 ff                	xor    %edi,%edi
  8010ea:	b9 01 00 00 00       	mov    $0x1,%ecx
  8010ef:	e9 60 ff ff ff       	jmp    801054 <__udivdi3+0x74>
  8010f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010f8:	8d 4f ff             	lea    -0x1(%edi),%ecx
  8010fb:	31 ff                	xor    %edi,%edi
  8010fd:	89 c8                	mov    %ecx,%eax
  8010ff:	89 fa                	mov    %edi,%edx
  801101:	83 c4 10             	add    $0x10,%esp
  801104:	5e                   	pop    %esi
  801105:	5f                   	pop    %edi
  801106:	5d                   	pop    %ebp
  801107:	c3                   	ret    
  801108:	66 90                	xchg   %ax,%ax
  80110a:	66 90                	xchg   %ax,%ax
  80110c:	66 90                	xchg   %ax,%ax
  80110e:	66 90                	xchg   %ax,%ax

00801110 <__umoddi3>:
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	57                   	push   %edi
  801114:	56                   	push   %esi
  801115:	83 ec 20             	sub    $0x20,%esp
  801118:	8b 55 14             	mov    0x14(%ebp),%edx
  80111b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80111e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801121:	8b 75 0c             	mov    0xc(%ebp),%esi
  801124:	85 d2                	test   %edx,%edx
  801126:	89 c8                	mov    %ecx,%eax
  801128:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80112b:	75 13                	jne    801140 <__umoddi3+0x30>
  80112d:	39 f7                	cmp    %esi,%edi
  80112f:	76 3f                	jbe    801170 <__umoddi3+0x60>
  801131:	89 f2                	mov    %esi,%edx
  801133:	f7 f7                	div    %edi
  801135:	89 d0                	mov    %edx,%eax
  801137:	31 d2                	xor    %edx,%edx
  801139:	83 c4 20             	add    $0x20,%esp
  80113c:	5e                   	pop    %esi
  80113d:	5f                   	pop    %edi
  80113e:	5d                   	pop    %ebp
  80113f:	c3                   	ret    
  801140:	39 f2                	cmp    %esi,%edx
  801142:	77 4c                	ja     801190 <__umoddi3+0x80>
  801144:	0f bd ca             	bsr    %edx,%ecx
  801147:	83 f1 1f             	xor    $0x1f,%ecx
  80114a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80114d:	75 51                	jne    8011a0 <__umoddi3+0x90>
  80114f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801152:	0f 87 e0 00 00 00    	ja     801238 <__umoddi3+0x128>
  801158:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115b:	29 f8                	sub    %edi,%eax
  80115d:	19 d6                	sbb    %edx,%esi
  80115f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801162:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801165:	89 f2                	mov    %esi,%edx
  801167:	83 c4 20             	add    $0x20,%esp
  80116a:	5e                   	pop    %esi
  80116b:	5f                   	pop    %edi
  80116c:	5d                   	pop    %ebp
  80116d:	c3                   	ret    
  80116e:	66 90                	xchg   %ax,%ax
  801170:	85 ff                	test   %edi,%edi
  801172:	75 0b                	jne    80117f <__umoddi3+0x6f>
  801174:	b8 01 00 00 00       	mov    $0x1,%eax
  801179:	31 d2                	xor    %edx,%edx
  80117b:	f7 f7                	div    %edi
  80117d:	89 c7                	mov    %eax,%edi
  80117f:	89 f0                	mov    %esi,%eax
  801181:	31 d2                	xor    %edx,%edx
  801183:	f7 f7                	div    %edi
  801185:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801188:	f7 f7                	div    %edi
  80118a:	eb a9                	jmp    801135 <__umoddi3+0x25>
  80118c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801190:	89 c8                	mov    %ecx,%eax
  801192:	89 f2                	mov    %esi,%edx
  801194:	83 c4 20             	add    $0x20,%esp
  801197:	5e                   	pop    %esi
  801198:	5f                   	pop    %edi
  801199:	5d                   	pop    %ebp
  80119a:	c3                   	ret    
  80119b:	90                   	nop
  80119c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011a0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011a4:	d3 e2                	shl    %cl,%edx
  8011a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011a9:	ba 20 00 00 00       	mov    $0x20,%edx
  8011ae:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8011b1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8011b4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011b8:	89 fa                	mov    %edi,%edx
  8011ba:	d3 ea                	shr    %cl,%edx
  8011bc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011c0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8011c3:	d3 e7                	shl    %cl,%edi
  8011c5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011cc:	89 f2                	mov    %esi,%edx
  8011ce:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8011d1:	89 c7                	mov    %eax,%edi
  8011d3:	d3 ea                	shr    %cl,%edx
  8011d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8011dc:	89 c2                	mov    %eax,%edx
  8011de:	d3 e6                	shl    %cl,%esi
  8011e0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011e4:	d3 ea                	shr    %cl,%edx
  8011e6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011ea:	09 d6                	or     %edx,%esi
  8011ec:	89 f0                	mov    %esi,%eax
  8011ee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8011f1:	d3 e7                	shl    %cl,%edi
  8011f3:	89 f2                	mov    %esi,%edx
  8011f5:	f7 75 f4             	divl   -0xc(%ebp)
  8011f8:	89 d6                	mov    %edx,%esi
  8011fa:	f7 65 e8             	mull   -0x18(%ebp)
  8011fd:	39 d6                	cmp    %edx,%esi
  8011ff:	72 2b                	jb     80122c <__umoddi3+0x11c>
  801201:	39 c7                	cmp    %eax,%edi
  801203:	72 23                	jb     801228 <__umoddi3+0x118>
  801205:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801209:	29 c7                	sub    %eax,%edi
  80120b:	19 d6                	sbb    %edx,%esi
  80120d:	89 f0                	mov    %esi,%eax
  80120f:	89 f2                	mov    %esi,%edx
  801211:	d3 ef                	shr    %cl,%edi
  801213:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801217:	d3 e0                	shl    %cl,%eax
  801219:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80121d:	09 f8                	or     %edi,%eax
  80121f:	d3 ea                	shr    %cl,%edx
  801221:	83 c4 20             	add    $0x20,%esp
  801224:	5e                   	pop    %esi
  801225:	5f                   	pop    %edi
  801226:	5d                   	pop    %ebp
  801227:	c3                   	ret    
  801228:	39 d6                	cmp    %edx,%esi
  80122a:	75 d9                	jne    801205 <__umoddi3+0xf5>
  80122c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80122f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801232:	eb d1                	jmp    801205 <__umoddi3+0xf5>
  801234:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801238:	39 f2                	cmp    %esi,%edx
  80123a:	0f 82 18 ff ff ff    	jb     801158 <__umoddi3+0x48>
  801240:	e9 1d ff ff ff       	jmp    801162 <__umoddi3+0x52>
