
obj/user/faultevilhandler：     文件格式 elf32-i386


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
  80002c:	e8 44 00 00 00       	call   800075 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  800039:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800040:	00 
  800041:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  800048:	ee 
  800049:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800050:	e8 01 03 00 00       	call   800356 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  800055:	c7 44 24 04 20 00 10 	movl   $0xf0100020,0x4(%esp)
  80005c:	f0 
  80005d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800064:	e8 75 01 00 00       	call   8001de <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  800069:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800070:	00 00 00 
}
  800073:	c9                   	leave  
  800074:	c3                   	ret    

00800075 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800075:	55                   	push   %ebp
  800076:	89 e5                	mov    %esp,%ebp
  800078:	83 ec 18             	sub    $0x18,%esp
  80007b:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  80007e:	89 75 fc             	mov    %esi,-0x4(%ebp)
  800081:	8b 75 08             	mov    0x8(%ebp),%esi
  800084:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800087:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  80008e:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  800091:	e8 53 03 00 00       	call   8003e9 <sys_getenvid>
  800096:	25 ff 03 00 00       	and    $0x3ff,%eax
  80009b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80009e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000a3:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000a8:	85 f6                	test   %esi,%esi
  8000aa:	7e 07                	jle    8000b3 <libmain+0x3e>
		binaryname = argv[0];
  8000ac:	8b 03                	mov    (%ebx),%eax
  8000ae:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8000b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8000b7:	89 34 24             	mov    %esi,(%esp)
  8000ba:	e8 74 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000bf:	e8 0a 00 00 00       	call   8000ce <exit>
}
  8000c4:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000c7:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000ca:	89 ec                	mov    %ebp,%esp
  8000cc:	5d                   	pop    %ebp
  8000cd:	c3                   	ret    

008000ce <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000ce:	55                   	push   %ebp
  8000cf:	89 e5                	mov    %esp,%ebp
  8000d1:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000d4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000db:	e8 3d 03 00 00       	call   80041d <sys_env_destroy>
}
  8000e0:	c9                   	leave  
  8000e1:	c3                   	ret    

008000e2 <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000e2:	55                   	push   %ebp
  8000e3:	89 e5                	mov    %esp,%ebp
  8000e5:	83 ec 0c             	sub    $0xc,%esp
  8000e8:	89 1c 24             	mov    %ebx,(%esp)
  8000eb:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000ef:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000f3:	ba 00 00 00 00       	mov    $0x0,%edx
  8000f8:	b8 01 00 00 00       	mov    $0x1,%eax
  8000fd:	89 d1                	mov    %edx,%ecx
  8000ff:	89 d3                	mov    %edx,%ebx
  800101:	89 d7                	mov    %edx,%edi
  800103:	89 d6                	mov    %edx,%esi
  800105:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  800107:	8b 1c 24             	mov    (%esp),%ebx
  80010a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80010e:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800112:	89 ec                	mov    %ebp,%esp
  800114:	5d                   	pop    %ebp
  800115:	c3                   	ret    

00800116 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	83 ec 0c             	sub    $0xc,%esp
  80011c:	89 1c 24             	mov    %ebx,(%esp)
  80011f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800123:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800127:	b8 00 00 00 00       	mov    $0x0,%eax
  80012c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80012f:	8b 55 08             	mov    0x8(%ebp),%edx
  800132:	89 c3                	mov    %eax,%ebx
  800134:	89 c7                	mov    %eax,%edi
  800136:	89 c6                	mov    %eax,%esi
  800138:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  80013a:	8b 1c 24             	mov    (%esp),%ebx
  80013d:	8b 74 24 04          	mov    0x4(%esp),%esi
  800141:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800145:	89 ec                	mov    %ebp,%esp
  800147:	5d                   	pop    %ebp
  800148:	c3                   	ret    

00800149 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800149:	55                   	push   %ebp
  80014a:	89 e5                	mov    %esp,%ebp
  80014c:	83 ec 38             	sub    $0x38,%esp
  80014f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800152:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800155:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800158:	b9 00 00 00 00       	mov    $0x0,%ecx
  80015d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800162:	8b 55 08             	mov    0x8(%ebp),%edx
  800165:	89 cb                	mov    %ecx,%ebx
  800167:	89 cf                	mov    %ecx,%edi
  800169:	89 ce                	mov    %ecx,%esi
  80016b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80016d:	85 c0                	test   %eax,%eax
  80016f:	7e 28                	jle    800199 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800171:	89 44 24 10          	mov    %eax,0x10(%esp)
  800175:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  80017c:	00 
  80017d:	c7 44 24 08 8a 12 80 	movl   $0x80128a,0x8(%esp)
  800184:	00 
  800185:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80018c:	00 
  80018d:	c7 04 24 a7 12 80 00 	movl   $0x8012a7,(%esp)
  800194:	e8 e1 02 00 00       	call   80047a <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800199:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80019c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80019f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8001a2:	89 ec                	mov    %ebp,%esp
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	83 ec 0c             	sub    $0xc,%esp
  8001ac:	89 1c 24             	mov    %ebx,(%esp)
  8001af:	89 74 24 04          	mov    %esi,0x4(%esp)
  8001b3:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001b7:	be 00 00 00 00       	mov    $0x0,%esi
  8001bc:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001c1:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c4:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ca:	8b 55 08             	mov    0x8(%ebp),%edx
  8001cd:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8001cf:	8b 1c 24             	mov    (%esp),%ebx
  8001d2:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001d6:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001da:	89 ec                	mov    %ebp,%esp
  8001dc:	5d                   	pop    %ebp
  8001dd:	c3                   	ret    

008001de <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8001de:	55                   	push   %ebp
  8001df:	89 e5                	mov    %esp,%ebp
  8001e1:	83 ec 38             	sub    $0x38,%esp
  8001e4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001e7:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001ea:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001ed:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f2:	b8 09 00 00 00       	mov    $0x9,%eax
  8001f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fd:	89 df                	mov    %ebx,%edi
  8001ff:	89 de                	mov    %ebx,%esi
  800201:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800203:	85 c0                	test   %eax,%eax
  800205:	7e 28                	jle    80022f <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800207:	89 44 24 10          	mov    %eax,0x10(%esp)
  80020b:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  800212:	00 
  800213:	c7 44 24 08 8a 12 80 	movl   $0x80128a,0x8(%esp)
  80021a:	00 
  80021b:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800222:	00 
  800223:	c7 04 24 a7 12 80 00 	movl   $0x8012a7,(%esp)
  80022a:	e8 4b 02 00 00       	call   80047a <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  80022f:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800232:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800235:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800238:	89 ec                	mov    %ebp,%esp
  80023a:	5d                   	pop    %ebp
  80023b:	c3                   	ret    

0080023c <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80023c:	55                   	push   %ebp
  80023d:	89 e5                	mov    %esp,%ebp
  80023f:	83 ec 38             	sub    $0x38,%esp
  800242:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800245:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800248:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80024b:	bb 00 00 00 00       	mov    $0x0,%ebx
  800250:	b8 08 00 00 00       	mov    $0x8,%eax
  800255:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800258:	8b 55 08             	mov    0x8(%ebp),%edx
  80025b:	89 df                	mov    %ebx,%edi
  80025d:	89 de                	mov    %ebx,%esi
  80025f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800261:	85 c0                	test   %eax,%eax
  800263:	7e 28                	jle    80028d <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800265:	89 44 24 10          	mov    %eax,0x10(%esp)
  800269:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  800270:	00 
  800271:	c7 44 24 08 8a 12 80 	movl   $0x80128a,0x8(%esp)
  800278:	00 
  800279:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800280:	00 
  800281:	c7 04 24 a7 12 80 00 	movl   $0x8012a7,(%esp)
  800288:	e8 ed 01 00 00       	call   80047a <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80028d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800290:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800293:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800296:	89 ec                	mov    %ebp,%esp
  800298:	5d                   	pop    %ebp
  800299:	c3                   	ret    

0080029a <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  80029a:	55                   	push   %ebp
  80029b:	89 e5                	mov    %esp,%ebp
  80029d:	83 ec 38             	sub    $0x38,%esp
  8002a0:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002a3:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002a6:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002ae:	b8 06 00 00 00       	mov    $0x6,%eax
  8002b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b9:	89 df                	mov    %ebx,%edi
  8002bb:	89 de                	mov    %ebx,%esi
  8002bd:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002bf:	85 c0                	test   %eax,%eax
  8002c1:	7e 28                	jle    8002eb <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c3:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002c7:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002ce:	00 
  8002cf:	c7 44 24 08 8a 12 80 	movl   $0x80128a,0x8(%esp)
  8002d6:	00 
  8002d7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002de:	00 
  8002df:	c7 04 24 a7 12 80 00 	movl   $0x8012a7,(%esp)
  8002e6:	e8 8f 01 00 00       	call   80047a <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002eb:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002ee:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002f1:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002f4:	89 ec                	mov    %ebp,%esp
  8002f6:	5d                   	pop    %ebp
  8002f7:	c3                   	ret    

008002f8 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8002f8:	55                   	push   %ebp
  8002f9:	89 e5                	mov    %esp,%ebp
  8002fb:	83 ec 38             	sub    $0x38,%esp
  8002fe:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800301:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800304:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800307:	b8 05 00 00 00       	mov    $0x5,%eax
  80030c:	8b 75 18             	mov    0x18(%ebp),%esi
  80030f:	8b 7d 14             	mov    0x14(%ebp),%edi
  800312:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800315:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800318:	8b 55 08             	mov    0x8(%ebp),%edx
  80031b:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80031d:	85 c0                	test   %eax,%eax
  80031f:	7e 28                	jle    800349 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  800321:	89 44 24 10          	mov    %eax,0x10(%esp)
  800325:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  80032c:	00 
  80032d:	c7 44 24 08 8a 12 80 	movl   $0x80128a,0x8(%esp)
  800334:	00 
  800335:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80033c:	00 
  80033d:	c7 04 24 a7 12 80 00 	movl   $0x8012a7,(%esp)
  800344:	e8 31 01 00 00       	call   80047a <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800349:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80034c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80034f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800352:	89 ec                	mov    %ebp,%esp
  800354:	5d                   	pop    %ebp
  800355:	c3                   	ret    

00800356 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
  800359:	83 ec 38             	sub    $0x38,%esp
  80035c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80035f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800362:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800365:	be 00 00 00 00       	mov    $0x0,%esi
  80036a:	b8 04 00 00 00       	mov    $0x4,%eax
  80036f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800372:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800375:	8b 55 08             	mov    0x8(%ebp),%edx
  800378:	89 f7                	mov    %esi,%edi
  80037a:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80037c:	85 c0                	test   %eax,%eax
  80037e:	7e 28                	jle    8003a8 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  800380:	89 44 24 10          	mov    %eax,0x10(%esp)
  800384:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  80038b:	00 
  80038c:	c7 44 24 08 8a 12 80 	movl   $0x80128a,0x8(%esp)
  800393:	00 
  800394:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80039b:	00 
  80039c:	c7 04 24 a7 12 80 00 	movl   $0x8012a7,(%esp)
  8003a3:	e8 d2 00 00 00       	call   80047a <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8003a8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8003ab:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8003ae:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8003b1:	89 ec                	mov    %ebp,%esp
  8003b3:	5d                   	pop    %ebp
  8003b4:	c3                   	ret    

008003b5 <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  8003b5:	55                   	push   %ebp
  8003b6:	89 e5                	mov    %esp,%ebp
  8003b8:	83 ec 0c             	sub    $0xc,%esp
  8003bb:	89 1c 24             	mov    %ebx,(%esp)
  8003be:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003c2:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8003cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8003d0:	89 d1                	mov    %edx,%ecx
  8003d2:	89 d3                	mov    %edx,%ebx
  8003d4:	89 d7                	mov    %edx,%edi
  8003d6:	89 d6                	mov    %edx,%esi
  8003d8:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8003da:	8b 1c 24             	mov    (%esp),%ebx
  8003dd:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003e1:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8003e5:	89 ec                	mov    %ebp,%esp
  8003e7:	5d                   	pop    %ebp
  8003e8:	c3                   	ret    

008003e9 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	83 ec 0c             	sub    $0xc,%esp
  8003ef:	89 1c 24             	mov    %ebx,(%esp)
  8003f2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003f6:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ff:	b8 02 00 00 00       	mov    $0x2,%eax
  800404:	89 d1                	mov    %edx,%ecx
  800406:	89 d3                	mov    %edx,%ebx
  800408:	89 d7                	mov    %edx,%edi
  80040a:	89 d6                	mov    %edx,%esi
  80040c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80040e:	8b 1c 24             	mov    (%esp),%ebx
  800411:	8b 74 24 04          	mov    0x4(%esp),%esi
  800415:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800419:	89 ec                	mov    %ebp,%esp
  80041b:	5d                   	pop    %ebp
  80041c:	c3                   	ret    

0080041d <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  80041d:	55                   	push   %ebp
  80041e:	89 e5                	mov    %esp,%ebp
  800420:	83 ec 38             	sub    $0x38,%esp
  800423:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800426:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800429:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80042c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800431:	b8 03 00 00 00       	mov    $0x3,%eax
  800436:	8b 55 08             	mov    0x8(%ebp),%edx
  800439:	89 cb                	mov    %ecx,%ebx
  80043b:	89 cf                	mov    %ecx,%edi
  80043d:	89 ce                	mov    %ecx,%esi
  80043f:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800441:	85 c0                	test   %eax,%eax
  800443:	7e 28                	jle    80046d <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  800445:	89 44 24 10          	mov    %eax,0x10(%esp)
  800449:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  800450:	00 
  800451:	c7 44 24 08 8a 12 80 	movl   $0x80128a,0x8(%esp)
  800458:	00 
  800459:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800460:	00 
  800461:	c7 04 24 a7 12 80 00 	movl   $0x8012a7,(%esp)
  800468:	e8 0d 00 00 00       	call   80047a <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80046d:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800470:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800473:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800476:	89 ec                	mov    %ebp,%esp
  800478:	5d                   	pop    %ebp
  800479:	c3                   	ret    

0080047a <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	56                   	push   %esi
  80047e:	53                   	push   %ebx
  80047f:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800482:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800485:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80048b:	e8 59 ff ff ff       	call   8003e9 <sys_getenvid>
  800490:	8b 55 0c             	mov    0xc(%ebp),%edx
  800493:	89 54 24 10          	mov    %edx,0x10(%esp)
  800497:	8b 55 08             	mov    0x8(%ebp),%edx
  80049a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80049e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8004a2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a6:	c7 04 24 b8 12 80 00 	movl   $0x8012b8,(%esp)
  8004ad:	e8 7f 00 00 00       	call   800531 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8004b2:	89 74 24 04          	mov    %esi,0x4(%esp)
  8004b6:	8b 45 10             	mov    0x10(%ebp),%eax
  8004b9:	89 04 24             	mov    %eax,(%esp)
  8004bc:	e8 0f 00 00 00       	call   8004d0 <vcprintf>
	cprintf("\n");
  8004c1:	c7 04 24 dc 12 80 00 	movl   $0x8012dc,(%esp)
  8004c8:	e8 64 00 00 00       	call   800531 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004cd:	cc                   	int3   
  8004ce:	eb fd                	jmp    8004cd <_panic+0x53>

008004d0 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8004d0:	55                   	push   %ebp
  8004d1:	89 e5                	mov    %esp,%ebp
  8004d3:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004d9:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004e0:	00 00 00 
	b.cnt = 0;
  8004e3:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004ea:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f0:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800501:	89 44 24 04          	mov    %eax,0x4(%esp)
  800505:	c7 04 24 4b 05 80 00 	movl   $0x80054b,(%esp)
  80050c:	e8 cc 01 00 00       	call   8006dd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800511:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800517:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800521:	89 04 24             	mov    %eax,(%esp)
  800524:	e8 ed fb ff ff       	call   800116 <sys_cputs>

	return b.cnt;
}
  800529:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80052f:	c9                   	leave  
  800530:	c3                   	ret    

00800531 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800531:	55                   	push   %ebp
  800532:	89 e5                	mov    %esp,%ebp
  800534:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800537:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  80053a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80053e:	8b 45 08             	mov    0x8(%ebp),%eax
  800541:	89 04 24             	mov    %eax,(%esp)
  800544:	e8 87 ff ff ff       	call   8004d0 <vcprintf>
	va_end(ap);

	return cnt;
}
  800549:	c9                   	leave  
  80054a:	c3                   	ret    

0080054b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80054b:	55                   	push   %ebp
  80054c:	89 e5                	mov    %esp,%ebp
  80054e:	53                   	push   %ebx
  80054f:	83 ec 14             	sub    $0x14,%esp
  800552:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800555:	8b 03                	mov    (%ebx),%eax
  800557:	8b 55 08             	mov    0x8(%ebp),%edx
  80055a:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  80055e:	83 c0 01             	add    $0x1,%eax
  800561:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  800563:	3d ff 00 00 00       	cmp    $0xff,%eax
  800568:	75 19                	jne    800583 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  80056a:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800571:	00 
  800572:	8d 43 08             	lea    0x8(%ebx),%eax
  800575:	89 04 24             	mov    %eax,(%esp)
  800578:	e8 99 fb ff ff       	call   800116 <sys_cputs>
		b->idx = 0;
  80057d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800583:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800587:	83 c4 14             	add    $0x14,%esp
  80058a:	5b                   	pop    %ebx
  80058b:	5d                   	pop    %ebp
  80058c:	c3                   	ret    
  80058d:	66 90                	xchg   %ax,%ax
  80058f:	90                   	nop

00800590 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800590:	55                   	push   %ebp
  800591:	89 e5                	mov    %esp,%ebp
  800593:	57                   	push   %edi
  800594:	56                   	push   %esi
  800595:	53                   	push   %ebx
  800596:	83 ec 4c             	sub    $0x4c,%esp
  800599:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80059c:	89 d6                	mov    %edx,%esi
  80059e:	8b 45 08             	mov    0x8(%ebp),%eax
  8005a1:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8005a7:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005aa:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ad:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8005b0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005b3:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8005b6:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005bb:	39 d1                	cmp    %edx,%ecx
  8005bd:	72 15                	jb     8005d4 <printnum+0x44>
  8005bf:	77 07                	ja     8005c8 <printnum+0x38>
  8005c1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005c4:	39 d0                	cmp    %edx,%eax
  8005c6:	76 0c                	jbe    8005d4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005c8:	83 eb 01             	sub    $0x1,%ebx
  8005cb:	85 db                	test   %ebx,%ebx
  8005cd:	8d 76 00             	lea    0x0(%esi),%esi
  8005d0:	7f 61                	jg     800633 <printnum+0xa3>
  8005d2:	eb 70                	jmp    800644 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005d4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8005d8:	83 eb 01             	sub    $0x1,%ebx
  8005db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005df:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005e3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8005e7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8005eb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8005ee:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8005f1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005f4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005f8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005ff:	00 
  800600:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800603:	89 04 24             	mov    %eax,(%esp)
  800606:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800609:	89 54 24 04          	mov    %edx,0x4(%esp)
  80060d:	e8 fe 09 00 00       	call   801010 <__udivdi3>
  800612:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800615:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800618:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80061c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800620:	89 04 24             	mov    %eax,(%esp)
  800623:	89 54 24 04          	mov    %edx,0x4(%esp)
  800627:	89 f2                	mov    %esi,%edx
  800629:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80062c:	e8 5f ff ff ff       	call   800590 <printnum>
  800631:	eb 11                	jmp    800644 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800633:	89 74 24 04          	mov    %esi,0x4(%esp)
  800637:	89 3c 24             	mov    %edi,(%esp)
  80063a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80063d:	83 eb 01             	sub    $0x1,%ebx
  800640:	85 db                	test   %ebx,%ebx
  800642:	7f ef                	jg     800633 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800644:	89 74 24 04          	mov    %esi,0x4(%esp)
  800648:	8b 74 24 04          	mov    0x4(%esp),%esi
  80064c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80064f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800653:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80065a:	00 
  80065b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80065e:	89 14 24             	mov    %edx,(%esp)
  800661:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800664:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800668:	e8 d3 0a 00 00       	call   801140 <__umoddi3>
  80066d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800671:	0f be 80 de 12 80 00 	movsbl 0x8012de(%eax),%eax
  800678:	89 04 24             	mov    %eax,(%esp)
  80067b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80067e:	83 c4 4c             	add    $0x4c,%esp
  800681:	5b                   	pop    %ebx
  800682:	5e                   	pop    %esi
  800683:	5f                   	pop    %edi
  800684:	5d                   	pop    %ebp
  800685:	c3                   	ret    

00800686 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800686:	55                   	push   %ebp
  800687:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800689:	83 fa 01             	cmp    $0x1,%edx
  80068c:	7e 0e                	jle    80069c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80068e:	8b 10                	mov    (%eax),%edx
  800690:	8d 4a 08             	lea    0x8(%edx),%ecx
  800693:	89 08                	mov    %ecx,(%eax)
  800695:	8b 02                	mov    (%edx),%eax
  800697:	8b 52 04             	mov    0x4(%edx),%edx
  80069a:	eb 22                	jmp    8006be <getuint+0x38>
	else if (lflag)
  80069c:	85 d2                	test   %edx,%edx
  80069e:	74 10                	je     8006b0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8006a0:	8b 10                	mov    (%eax),%edx
  8006a2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006a5:	89 08                	mov    %ecx,(%eax)
  8006a7:	8b 02                	mov    (%edx),%eax
  8006a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8006ae:	eb 0e                	jmp    8006be <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8006b0:	8b 10                	mov    (%eax),%edx
  8006b2:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006b5:	89 08                	mov    %ecx,(%eax)
  8006b7:	8b 02                	mov    (%edx),%eax
  8006b9:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006be:	5d                   	pop    %ebp
  8006bf:	c3                   	ret    

008006c0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006c0:	55                   	push   %ebp
  8006c1:	89 e5                	mov    %esp,%ebp
  8006c3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006c6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006ca:	8b 10                	mov    (%eax),%edx
  8006cc:	3b 50 04             	cmp    0x4(%eax),%edx
  8006cf:	73 0a                	jae    8006db <sprintputch+0x1b>
		*b->buf++ = ch;
  8006d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006d4:	88 0a                	mov    %cl,(%edx)
  8006d6:	83 c2 01             	add    $0x1,%edx
  8006d9:	89 10                	mov    %edx,(%eax)
}
  8006db:	5d                   	pop    %ebp
  8006dc:	c3                   	ret    

008006dd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	57                   	push   %edi
  8006e1:	56                   	push   %esi
  8006e2:	53                   	push   %ebx
  8006e3:	83 ec 5c             	sub    $0x5c,%esp
  8006e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006e9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8006ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8006ef:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8006f6:	eb 11                	jmp    800709 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006f8:	85 c0                	test   %eax,%eax
  8006fa:	0f 84 16 04 00 00    	je     800b16 <vprintfmt+0x439>
				return;
			putch(ch, putdat);
  800700:	89 74 24 04          	mov    %esi,0x4(%esp)
  800704:	89 04 24             	mov    %eax,(%esp)
  800707:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800709:	0f b6 03             	movzbl (%ebx),%eax
  80070c:	83 c3 01             	add    $0x1,%ebx
  80070f:	83 f8 25             	cmp    $0x25,%eax
  800712:	75 e4                	jne    8006f8 <vprintfmt+0x1b>
  800714:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  80071b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800722:	b9 00 00 00 00       	mov    $0x0,%ecx
  800727:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80072b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800732:	eb 06                	jmp    80073a <vprintfmt+0x5d>
  800734:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800738:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073a:	0f b6 13             	movzbl (%ebx),%edx
  80073d:	0f b6 c2             	movzbl %dl,%eax
  800740:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800743:	8d 43 01             	lea    0x1(%ebx),%eax
  800746:	83 ea 23             	sub    $0x23,%edx
  800749:	80 fa 55             	cmp    $0x55,%dl
  80074c:	0f 87 a7 03 00 00    	ja     800af9 <vprintfmt+0x41c>
  800752:	0f b6 d2             	movzbl %dl,%edx
  800755:	ff 24 95 a0 13 80 00 	jmp    *0x8013a0(,%edx,4)
  80075c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800760:	eb d6                	jmp    800738 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800762:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800765:	83 ea 30             	sub    $0x30,%edx
  800768:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80076b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80076e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800771:	83 fb 09             	cmp    $0x9,%ebx
  800774:	77 54                	ja     8007ca <vprintfmt+0xed>
  800776:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800779:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80077c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80077f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800782:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800786:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800789:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80078c:	83 fb 09             	cmp    $0x9,%ebx
  80078f:	76 eb                	jbe    80077c <vprintfmt+0x9f>
  800791:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800794:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800797:	eb 31                	jmp    8007ca <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800799:	8b 55 14             	mov    0x14(%ebp),%edx
  80079c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80079f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  8007a2:	8b 12                	mov    (%edx),%edx
  8007a4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  8007a7:	eb 21                	jmp    8007ca <vprintfmt+0xed>

		case '.':
			if (width < 0)
  8007a9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8007b2:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  8007b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007b9:	e9 7a ff ff ff       	jmp    800738 <vprintfmt+0x5b>
  8007be:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8007c5:	e9 6e ff ff ff       	jmp    800738 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8007ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007ce:	0f 89 64 ff ff ff    	jns    800738 <vprintfmt+0x5b>
  8007d4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007d7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007da:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8007dd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007e0:	e9 53 ff ff ff       	jmp    800738 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007e5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8007e8:	e9 4b ff ff ff       	jmp    800738 <vprintfmt+0x5b>
  8007ed:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007f0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f3:	8d 50 04             	lea    0x4(%eax),%edx
  8007f6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007fd:	8b 00                	mov    (%eax),%eax
  8007ff:	89 04 24             	mov    %eax,(%esp)
  800802:	ff d7                	call   *%edi
  800804:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800807:	e9 fd fe ff ff       	jmp    800709 <vprintfmt+0x2c>
  80080c:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  80080f:	8b 45 14             	mov    0x14(%ebp),%eax
  800812:	8d 50 04             	lea    0x4(%eax),%edx
  800815:	89 55 14             	mov    %edx,0x14(%ebp)
  800818:	8b 00                	mov    (%eax),%eax
  80081a:	89 c2                	mov    %eax,%edx
  80081c:	c1 fa 1f             	sar    $0x1f,%edx
  80081f:	31 d0                	xor    %edx,%eax
  800821:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800823:	83 f8 08             	cmp    $0x8,%eax
  800826:	7f 0b                	jg     800833 <vprintfmt+0x156>
  800828:	8b 14 85 00 15 80 00 	mov    0x801500(,%eax,4),%edx
  80082f:	85 d2                	test   %edx,%edx
  800831:	75 20                	jne    800853 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800833:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800837:	c7 44 24 08 ef 12 80 	movl   $0x8012ef,0x8(%esp)
  80083e:	00 
  80083f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800843:	89 3c 24             	mov    %edi,(%esp)
  800846:	e8 53 03 00 00       	call   800b9e <printfmt>
  80084b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80084e:	e9 b6 fe ff ff       	jmp    800709 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800853:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800857:	c7 44 24 08 f8 12 80 	movl   $0x8012f8,0x8(%esp)
  80085e:	00 
  80085f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800863:	89 3c 24             	mov    %edi,(%esp)
  800866:	e8 33 03 00 00       	call   800b9e <printfmt>
  80086b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80086e:	e9 96 fe ff ff       	jmp    800709 <vprintfmt+0x2c>
  800873:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800876:	89 c3                	mov    %eax,%ebx
  800878:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80087b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80087e:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800881:	8b 45 14             	mov    0x14(%ebp),%eax
  800884:	8d 50 04             	lea    0x4(%eax),%edx
  800887:	89 55 14             	mov    %edx,0x14(%ebp)
  80088a:	8b 00                	mov    (%eax),%eax
  80088c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80088f:	85 c0                	test   %eax,%eax
  800891:	b8 fb 12 80 00       	mov    $0x8012fb,%eax
  800896:	0f 45 45 c4          	cmovne -0x3c(%ebp),%eax
  80089a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80089d:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  8008a1:	7e 06                	jle    8008a9 <vprintfmt+0x1cc>
  8008a3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  8008a7:	75 13                	jne    8008bc <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008a9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  8008ac:	0f be 02             	movsbl (%edx),%eax
  8008af:	85 c0                	test   %eax,%eax
  8008b1:	0f 85 9b 00 00 00    	jne    800952 <vprintfmt+0x275>
  8008b7:	e9 88 00 00 00       	jmp    800944 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008bc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008c0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  8008c3:	89 0c 24             	mov    %ecx,(%esp)
  8008c6:	e8 20 03 00 00       	call   800beb <strnlen>
  8008cb:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8008ce:	29 c2                	sub    %eax,%edx
  8008d0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008d3:	85 d2                	test   %edx,%edx
  8008d5:	7e d2                	jle    8008a9 <vprintfmt+0x1cc>
					putch(padc, putdat);
  8008d7:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  8008db:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008de:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8008e1:	89 d3                	mov    %edx,%ebx
  8008e3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8008ea:	89 04 24             	mov    %eax,(%esp)
  8008ed:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008ef:	83 eb 01             	sub    $0x1,%ebx
  8008f2:	85 db                	test   %ebx,%ebx
  8008f4:	7f ed                	jg     8008e3 <vprintfmt+0x206>
  8008f6:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8008f9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800900:	eb a7                	jmp    8008a9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800902:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800906:	74 1a                	je     800922 <vprintfmt+0x245>
  800908:	8d 50 e0             	lea    -0x20(%eax),%edx
  80090b:	83 fa 5e             	cmp    $0x5e,%edx
  80090e:	76 12                	jbe    800922 <vprintfmt+0x245>
					putch('?', putdat);
  800910:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800914:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  80091b:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  80091e:	66 90                	xchg   %ax,%ax
  800920:	eb 0a                	jmp    80092c <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800922:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800926:	89 04 24             	mov    %eax,(%esp)
  800929:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80092c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800930:	0f be 03             	movsbl (%ebx),%eax
  800933:	85 c0                	test   %eax,%eax
  800935:	74 05                	je     80093c <vprintfmt+0x25f>
  800937:	83 c3 01             	add    $0x1,%ebx
  80093a:	eb 29                	jmp    800965 <vprintfmt+0x288>
  80093c:	89 fe                	mov    %edi,%esi
  80093e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800941:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800944:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800948:	7f 2e                	jg     800978 <vprintfmt+0x29b>
  80094a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80094d:	e9 b7 fd ff ff       	jmp    800709 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800952:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800955:	83 c2 01             	add    $0x1,%edx
  800958:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80095b:	89 f7                	mov    %esi,%edi
  80095d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800960:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800963:	89 d3                	mov    %edx,%ebx
  800965:	85 f6                	test   %esi,%esi
  800967:	78 99                	js     800902 <vprintfmt+0x225>
  800969:	83 ee 01             	sub    $0x1,%esi
  80096c:	79 94                	jns    800902 <vprintfmt+0x225>
  80096e:	89 fe                	mov    %edi,%esi
  800970:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800973:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800976:	eb cc                	jmp    800944 <vprintfmt+0x267>
  800978:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80097b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80097e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800982:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800989:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80098b:	83 eb 01             	sub    $0x1,%ebx
  80098e:	85 db                	test   %ebx,%ebx
  800990:	7f ec                	jg     80097e <vprintfmt+0x2a1>
  800992:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800995:	e9 6f fd ff ff       	jmp    800709 <vprintfmt+0x2c>
  80099a:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80099d:	83 f9 01             	cmp    $0x1,%ecx
  8009a0:	7e 16                	jle    8009b8 <vprintfmt+0x2db>
		return va_arg(*ap, long long);
  8009a2:	8b 45 14             	mov    0x14(%ebp),%eax
  8009a5:	8d 50 08             	lea    0x8(%eax),%edx
  8009a8:	89 55 14             	mov    %edx,0x14(%ebp)
  8009ab:	8b 10                	mov    (%eax),%edx
  8009ad:	8b 48 04             	mov    0x4(%eax),%ecx
  8009b0:	89 55 d0             	mov    %edx,-0x30(%ebp)
  8009b3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8009b6:	eb 32                	jmp    8009ea <vprintfmt+0x30d>
	else if (lflag)
  8009b8:	85 c9                	test   %ecx,%ecx
  8009ba:	74 18                	je     8009d4 <vprintfmt+0x2f7>
		return va_arg(*ap, long);
  8009bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8009bf:	8d 50 04             	lea    0x4(%eax),%edx
  8009c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8009c5:	8b 00                	mov    (%eax),%eax
  8009c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009ca:	89 c1                	mov    %eax,%ecx
  8009cc:	c1 f9 1f             	sar    $0x1f,%ecx
  8009cf:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8009d2:	eb 16                	jmp    8009ea <vprintfmt+0x30d>
	else
		return va_arg(*ap, int);
  8009d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d7:	8d 50 04             	lea    0x4(%eax),%edx
  8009da:	89 55 14             	mov    %edx,0x14(%ebp)
  8009dd:	8b 00                	mov    (%eax),%eax
  8009df:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009e2:	89 c2                	mov    %eax,%edx
  8009e4:	c1 fa 1f             	sar    $0x1f,%edx
  8009e7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009ea:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8009ed:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8009f0:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8009f5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8009f9:	0f 89 b8 00 00 00    	jns    800ab7 <vprintfmt+0x3da>
				putch('-', putdat);
  8009ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a03:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800a0a:	ff d7                	call   *%edi
				num = -(long long) num;
  800a0c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800a0f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800a12:	f7 d9                	neg    %ecx
  800a14:	83 d3 00             	adc    $0x0,%ebx
  800a17:	f7 db                	neg    %ebx
  800a19:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a1e:	e9 94 00 00 00       	jmp    800ab7 <vprintfmt+0x3da>
  800a23:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a26:	89 ca                	mov    %ecx,%edx
  800a28:	8d 45 14             	lea    0x14(%ebp),%eax
  800a2b:	e8 56 fc ff ff       	call   800686 <getuint>
  800a30:	89 c1                	mov    %eax,%ecx
  800a32:	89 d3                	mov    %edx,%ebx
  800a34:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800a39:	eb 7c                	jmp    800ab7 <vprintfmt+0x3da>
  800a3b:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800a3e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a42:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800a49:	ff d7                	call   *%edi
			putch('X', putdat);
  800a4b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a4f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800a56:	ff d7                	call   *%edi
			putch('X', putdat);
  800a58:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a5c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800a63:	ff d7                	call   *%edi
  800a65:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800a68:	e9 9c fc ff ff       	jmp    800709 <vprintfmt+0x2c>
  800a6d:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800a70:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a74:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a7b:	ff d7                	call   *%edi
			putch('x', putdat);
  800a7d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a81:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a88:	ff d7                	call   *%edi
			num = (unsigned long long)
  800a8a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a8d:	8d 50 04             	lea    0x4(%eax),%edx
  800a90:	89 55 14             	mov    %edx,0x14(%ebp)
  800a93:	8b 08                	mov    (%eax),%ecx
  800a95:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a9a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a9f:	eb 16                	jmp    800ab7 <vprintfmt+0x3da>
  800aa1:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800aa4:	89 ca                	mov    %ecx,%edx
  800aa6:	8d 45 14             	lea    0x14(%ebp),%eax
  800aa9:	e8 d8 fb ff ff       	call   800686 <getuint>
  800aae:	89 c1                	mov    %eax,%ecx
  800ab0:	89 d3                	mov    %edx,%ebx
  800ab2:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ab7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800abb:	89 54 24 10          	mov    %edx,0x10(%esp)
  800abf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ac2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ac6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aca:	89 0c 24             	mov    %ecx,(%esp)
  800acd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ad1:	89 f2                	mov    %esi,%edx
  800ad3:	89 f8                	mov    %edi,%eax
  800ad5:	e8 b6 fa ff ff       	call   800590 <printnum>
  800ada:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800add:	e9 27 fc ff ff       	jmp    800709 <vprintfmt+0x2c>
  800ae2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800ae5:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ae8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800aec:	89 14 24             	mov    %edx,(%esp)
  800aef:	ff d7                	call   *%edi
  800af1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800af4:	e9 10 fc ff ff       	jmp    800709 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800af9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800afd:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b04:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b06:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800b09:	80 38 25             	cmpb   $0x25,(%eax)
  800b0c:	0f 84 f7 fb ff ff    	je     800709 <vprintfmt+0x2c>
  800b12:	89 c3                	mov    %eax,%ebx
  800b14:	eb f0                	jmp    800b06 <vprintfmt+0x429>
				/* do nothing */;
			break;
		}
	}
}
  800b16:	83 c4 5c             	add    $0x5c,%esp
  800b19:	5b                   	pop    %ebx
  800b1a:	5e                   	pop    %esi
  800b1b:	5f                   	pop    %edi
  800b1c:	5d                   	pop    %ebp
  800b1d:	c3                   	ret    

00800b1e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b1e:	55                   	push   %ebp
  800b1f:	89 e5                	mov    %esp,%ebp
  800b21:	83 ec 28             	sub    $0x28,%esp
  800b24:	8b 45 08             	mov    0x8(%ebp),%eax
  800b27:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800b2a:	85 c0                	test   %eax,%eax
  800b2c:	74 04                	je     800b32 <vsnprintf+0x14>
  800b2e:	85 d2                	test   %edx,%edx
  800b30:	7f 07                	jg     800b39 <vsnprintf+0x1b>
  800b32:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b37:	eb 3b                	jmp    800b74 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b39:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b3c:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800b40:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b43:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b4a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b4d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b51:	8b 45 10             	mov    0x10(%ebp),%eax
  800b54:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b58:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b5b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b5f:	c7 04 24 c0 06 80 00 	movl   $0x8006c0,(%esp)
  800b66:	e8 72 fb ff ff       	call   8006dd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b6b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b6e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b74:	c9                   	leave  
  800b75:	c3                   	ret    

00800b76 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800b7c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800b7f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b83:	8b 45 10             	mov    0x10(%ebp),%eax
  800b86:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b91:	8b 45 08             	mov    0x8(%ebp),%eax
  800b94:	89 04 24             	mov    %eax,(%esp)
  800b97:	e8 82 ff ff ff       	call   800b1e <vsnprintf>
	va_end(ap);

	return rc;
}
  800b9c:	c9                   	leave  
  800b9d:	c3                   	ret    

00800b9e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b9e:	55                   	push   %ebp
  800b9f:	89 e5                	mov    %esp,%ebp
  800ba1:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800ba4:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800ba7:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bab:	8b 45 10             	mov    0x10(%ebp),%eax
  800bae:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bb5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbc:	89 04 24             	mov    %eax,(%esp)
  800bbf:	e8 19 fb ff ff       	call   8006dd <vprintfmt>
	va_end(ap);
}
  800bc4:	c9                   	leave  
  800bc5:	c3                   	ret    
  800bc6:	66 90                	xchg   %ax,%ax
  800bc8:	66 90                	xchg   %ax,%ax
  800bca:	66 90                	xchg   %ax,%ax
  800bcc:	66 90                	xchg   %ax,%ax
  800bce:	66 90                	xchg   %ax,%ax

00800bd0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800bd6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bdb:	80 3a 00             	cmpb   $0x0,(%edx)
  800bde:	74 09                	je     800be9 <strlen+0x19>
		n++;
  800be0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800be3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800be7:	75 f7                	jne    800be0 <strlen+0x10>
		n++;
	return n;
}
  800be9:	5d                   	pop    %ebp
  800bea:	c3                   	ret    

00800beb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	53                   	push   %ebx
  800bef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bf2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bf5:	85 c9                	test   %ecx,%ecx
  800bf7:	74 19                	je     800c12 <strnlen+0x27>
  800bf9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800bfc:	74 14                	je     800c12 <strnlen+0x27>
  800bfe:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800c03:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c06:	39 c8                	cmp    %ecx,%eax
  800c08:	74 0d                	je     800c17 <strnlen+0x2c>
  800c0a:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800c0e:	75 f3                	jne    800c03 <strnlen+0x18>
  800c10:	eb 05                	jmp    800c17 <strnlen+0x2c>
  800c12:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800c17:	5b                   	pop    %ebx
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	53                   	push   %ebx
  800c1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c21:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c24:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c29:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c2d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c30:	83 c2 01             	add    $0x1,%edx
  800c33:	84 c9                	test   %cl,%cl
  800c35:	75 f2                	jne    800c29 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c37:	5b                   	pop    %ebx
  800c38:	5d                   	pop    %ebp
  800c39:	c3                   	ret    

00800c3a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	53                   	push   %ebx
  800c3e:	83 ec 08             	sub    $0x8,%esp
  800c41:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c44:	89 1c 24             	mov    %ebx,(%esp)
  800c47:	e8 84 ff ff ff       	call   800bd0 <strlen>
	strcpy(dst + len, src);
  800c4c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c4f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c53:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800c56:	89 04 24             	mov    %eax,(%esp)
  800c59:	e8 bc ff ff ff       	call   800c1a <strcpy>
	return dst;
}
  800c5e:	89 d8                	mov    %ebx,%eax
  800c60:	83 c4 08             	add    $0x8,%esp
  800c63:	5b                   	pop    %ebx
  800c64:	5d                   	pop    %ebp
  800c65:	c3                   	ret    

00800c66 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c66:	55                   	push   %ebp
  800c67:	89 e5                	mov    %esp,%ebp
  800c69:	56                   	push   %esi
  800c6a:	53                   	push   %ebx
  800c6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c6e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c71:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c74:	85 f6                	test   %esi,%esi
  800c76:	74 18                	je     800c90 <strncpy+0x2a>
  800c78:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800c7d:	0f b6 1a             	movzbl (%edx),%ebx
  800c80:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c83:	80 3a 01             	cmpb   $0x1,(%edx)
  800c86:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c89:	83 c1 01             	add    $0x1,%ecx
  800c8c:	39 ce                	cmp    %ecx,%esi
  800c8e:	77 ed                	ja     800c7d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c90:	5b                   	pop    %ebx
  800c91:	5e                   	pop    %esi
  800c92:	5d                   	pop    %ebp
  800c93:	c3                   	ret    

00800c94 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	56                   	push   %esi
  800c98:	53                   	push   %ebx
  800c99:	8b 75 08             	mov    0x8(%ebp),%esi
  800c9c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ca2:	89 f0                	mov    %esi,%eax
  800ca4:	85 c9                	test   %ecx,%ecx
  800ca6:	74 27                	je     800ccf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800ca8:	83 e9 01             	sub    $0x1,%ecx
  800cab:	74 1d                	je     800cca <strlcpy+0x36>
  800cad:	0f b6 1a             	movzbl (%edx),%ebx
  800cb0:	84 db                	test   %bl,%bl
  800cb2:	74 16                	je     800cca <strlcpy+0x36>
			*dst++ = *src++;
  800cb4:	88 18                	mov    %bl,(%eax)
  800cb6:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800cb9:	83 e9 01             	sub    $0x1,%ecx
  800cbc:	74 0e                	je     800ccc <strlcpy+0x38>
			*dst++ = *src++;
  800cbe:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800cc1:	0f b6 1a             	movzbl (%edx),%ebx
  800cc4:	84 db                	test   %bl,%bl
  800cc6:	75 ec                	jne    800cb4 <strlcpy+0x20>
  800cc8:	eb 02                	jmp    800ccc <strlcpy+0x38>
  800cca:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800ccc:	c6 00 00             	movb   $0x0,(%eax)
  800ccf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800cd1:	5b                   	pop    %ebx
  800cd2:	5e                   	pop    %esi
  800cd3:	5d                   	pop    %ebp
  800cd4:	c3                   	ret    

00800cd5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cdb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800cde:	0f b6 01             	movzbl (%ecx),%eax
  800ce1:	84 c0                	test   %al,%al
  800ce3:	74 15                	je     800cfa <strcmp+0x25>
  800ce5:	3a 02                	cmp    (%edx),%al
  800ce7:	75 11                	jne    800cfa <strcmp+0x25>
		p++, q++;
  800ce9:	83 c1 01             	add    $0x1,%ecx
  800cec:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800cef:	0f b6 01             	movzbl (%ecx),%eax
  800cf2:	84 c0                	test   %al,%al
  800cf4:	74 04                	je     800cfa <strcmp+0x25>
  800cf6:	3a 02                	cmp    (%edx),%al
  800cf8:	74 ef                	je     800ce9 <strcmp+0x14>
  800cfa:	0f b6 c0             	movzbl %al,%eax
  800cfd:	0f b6 12             	movzbl (%edx),%edx
  800d00:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d02:	5d                   	pop    %ebp
  800d03:	c3                   	ret    

00800d04 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d04:	55                   	push   %ebp
  800d05:	89 e5                	mov    %esp,%ebp
  800d07:	53                   	push   %ebx
  800d08:	8b 55 08             	mov    0x8(%ebp),%edx
  800d0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0e:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800d11:	85 c0                	test   %eax,%eax
  800d13:	74 23                	je     800d38 <strncmp+0x34>
  800d15:	0f b6 1a             	movzbl (%edx),%ebx
  800d18:	84 db                	test   %bl,%bl
  800d1a:	74 25                	je     800d41 <strncmp+0x3d>
  800d1c:	3a 19                	cmp    (%ecx),%bl
  800d1e:	75 21                	jne    800d41 <strncmp+0x3d>
  800d20:	83 e8 01             	sub    $0x1,%eax
  800d23:	74 13                	je     800d38 <strncmp+0x34>
		n--, p++, q++;
  800d25:	83 c2 01             	add    $0x1,%edx
  800d28:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d2b:	0f b6 1a             	movzbl (%edx),%ebx
  800d2e:	84 db                	test   %bl,%bl
  800d30:	74 0f                	je     800d41 <strncmp+0x3d>
  800d32:	3a 19                	cmp    (%ecx),%bl
  800d34:	74 ea                	je     800d20 <strncmp+0x1c>
  800d36:	eb 09                	jmp    800d41 <strncmp+0x3d>
  800d38:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d3d:	5b                   	pop    %ebx
  800d3e:	5d                   	pop    %ebp
  800d3f:	90                   	nop
  800d40:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d41:	0f b6 02             	movzbl (%edx),%eax
  800d44:	0f b6 11             	movzbl (%ecx),%edx
  800d47:	29 d0                	sub    %edx,%eax
  800d49:	eb f2                	jmp    800d3d <strncmp+0x39>

00800d4b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
  800d4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d51:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d55:	0f b6 10             	movzbl (%eax),%edx
  800d58:	84 d2                	test   %dl,%dl
  800d5a:	74 18                	je     800d74 <strchr+0x29>
		if (*s == c)
  800d5c:	38 ca                	cmp    %cl,%dl
  800d5e:	75 0a                	jne    800d6a <strchr+0x1f>
  800d60:	eb 17                	jmp    800d79 <strchr+0x2e>
  800d62:	38 ca                	cmp    %cl,%dl
  800d64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d68:	74 0f                	je     800d79 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d6a:	83 c0 01             	add    $0x1,%eax
  800d6d:	0f b6 10             	movzbl (%eax),%edx
  800d70:	84 d2                	test   %dl,%dl
  800d72:	75 ee                	jne    800d62 <strchr+0x17>
  800d74:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800d79:	5d                   	pop    %ebp
  800d7a:	c3                   	ret    

00800d7b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d7b:	55                   	push   %ebp
  800d7c:	89 e5                	mov    %esp,%ebp
  800d7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d81:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d85:	0f b6 10             	movzbl (%eax),%edx
  800d88:	84 d2                	test   %dl,%dl
  800d8a:	74 18                	je     800da4 <strfind+0x29>
		if (*s == c)
  800d8c:	38 ca                	cmp    %cl,%dl
  800d8e:	75 0a                	jne    800d9a <strfind+0x1f>
  800d90:	eb 12                	jmp    800da4 <strfind+0x29>
  800d92:	38 ca                	cmp    %cl,%dl
  800d94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d98:	74 0a                	je     800da4 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d9a:	83 c0 01             	add    $0x1,%eax
  800d9d:	0f b6 10             	movzbl (%eax),%edx
  800da0:	84 d2                	test   %dl,%dl
  800da2:	75 ee                	jne    800d92 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800da4:	5d                   	pop    %ebp
  800da5:	c3                   	ret    

00800da6 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	83 ec 0c             	sub    $0xc,%esp
  800dac:	89 1c 24             	mov    %ebx,(%esp)
  800daf:	89 74 24 04          	mov    %esi,0x4(%esp)
  800db3:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800db7:	8b 7d 08             	mov    0x8(%ebp),%edi
  800dba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dbd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800dc0:	85 c9                	test   %ecx,%ecx
  800dc2:	74 30                	je     800df4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dc4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800dca:	75 25                	jne    800df1 <memset+0x4b>
  800dcc:	f6 c1 03             	test   $0x3,%cl
  800dcf:	75 20                	jne    800df1 <memset+0x4b>
		c &= 0xFF;
  800dd1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800dd4:	89 d3                	mov    %edx,%ebx
  800dd6:	c1 e3 08             	shl    $0x8,%ebx
  800dd9:	89 d6                	mov    %edx,%esi
  800ddb:	c1 e6 18             	shl    $0x18,%esi
  800dde:	89 d0                	mov    %edx,%eax
  800de0:	c1 e0 10             	shl    $0x10,%eax
  800de3:	09 f0                	or     %esi,%eax
  800de5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800de7:	09 d8                	or     %ebx,%eax
  800de9:	c1 e9 02             	shr    $0x2,%ecx
  800dec:	fc                   	cld    
  800ded:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800def:	eb 03                	jmp    800df4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800df1:	fc                   	cld    
  800df2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800df4:	89 f8                	mov    %edi,%eax
  800df6:	8b 1c 24             	mov    (%esp),%ebx
  800df9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800dfd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800e01:	89 ec                	mov    %ebp,%esp
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e05:	55                   	push   %ebp
  800e06:	89 e5                	mov    %esp,%ebp
  800e08:	83 ec 08             	sub    $0x8,%esp
  800e0b:	89 34 24             	mov    %esi,(%esp)
  800e0e:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800e12:	8b 45 08             	mov    0x8(%ebp),%eax
  800e15:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800e18:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800e1b:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800e1d:	39 c6                	cmp    %eax,%esi
  800e1f:	73 35                	jae    800e56 <memmove+0x51>
  800e21:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e24:	39 d0                	cmp    %edx,%eax
  800e26:	73 2e                	jae    800e56 <memmove+0x51>
		s += n;
		d += n;
  800e28:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e2a:	f6 c2 03             	test   $0x3,%dl
  800e2d:	75 1b                	jne    800e4a <memmove+0x45>
  800e2f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e35:	75 13                	jne    800e4a <memmove+0x45>
  800e37:	f6 c1 03             	test   $0x3,%cl
  800e3a:	75 0e                	jne    800e4a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800e3c:	83 ef 04             	sub    $0x4,%edi
  800e3f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e42:	c1 e9 02             	shr    $0x2,%ecx
  800e45:	fd                   	std    
  800e46:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e48:	eb 09                	jmp    800e53 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e4a:	83 ef 01             	sub    $0x1,%edi
  800e4d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e50:	fd                   	std    
  800e51:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e53:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e54:	eb 20                	jmp    800e76 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e56:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e5c:	75 15                	jne    800e73 <memmove+0x6e>
  800e5e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e64:	75 0d                	jne    800e73 <memmove+0x6e>
  800e66:	f6 c1 03             	test   $0x3,%cl
  800e69:	75 08                	jne    800e73 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800e6b:	c1 e9 02             	shr    $0x2,%ecx
  800e6e:	fc                   	cld    
  800e6f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e71:	eb 03                	jmp    800e76 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e73:	fc                   	cld    
  800e74:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e76:	8b 34 24             	mov    (%esp),%esi
  800e79:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e7d:	89 ec                	mov    %ebp,%esp
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e87:	8b 45 10             	mov    0x10(%ebp),%eax
  800e8a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e8e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e91:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e95:	8b 45 08             	mov    0x8(%ebp),%eax
  800e98:	89 04 24             	mov    %eax,(%esp)
  800e9b:	e8 65 ff ff ff       	call   800e05 <memmove>
}
  800ea0:	c9                   	leave  
  800ea1:	c3                   	ret    

00800ea2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	57                   	push   %edi
  800ea6:	56                   	push   %esi
  800ea7:	53                   	push   %ebx
  800ea8:	8b 75 08             	mov    0x8(%ebp),%esi
  800eab:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800eae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800eb1:	85 c9                	test   %ecx,%ecx
  800eb3:	74 36                	je     800eeb <memcmp+0x49>
		if (*s1 != *s2)
  800eb5:	0f b6 06             	movzbl (%esi),%eax
  800eb8:	0f b6 1f             	movzbl (%edi),%ebx
  800ebb:	38 d8                	cmp    %bl,%al
  800ebd:	74 20                	je     800edf <memcmp+0x3d>
  800ebf:	eb 14                	jmp    800ed5 <memcmp+0x33>
  800ec1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800ec6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800ecb:	83 c2 01             	add    $0x1,%edx
  800ece:	83 e9 01             	sub    $0x1,%ecx
  800ed1:	38 d8                	cmp    %bl,%al
  800ed3:	74 12                	je     800ee7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800ed5:	0f b6 c0             	movzbl %al,%eax
  800ed8:	0f b6 db             	movzbl %bl,%ebx
  800edb:	29 d8                	sub    %ebx,%eax
  800edd:	eb 11                	jmp    800ef0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800edf:	83 e9 01             	sub    $0x1,%ecx
  800ee2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ee7:	85 c9                	test   %ecx,%ecx
  800ee9:	75 d6                	jne    800ec1 <memcmp+0x1f>
  800eeb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800ef0:	5b                   	pop    %ebx
  800ef1:	5e                   	pop    %esi
  800ef2:	5f                   	pop    %edi
  800ef3:	5d                   	pop    %ebp
  800ef4:	c3                   	ret    

00800ef5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800efb:	89 c2                	mov    %eax,%edx
  800efd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800f00:	39 d0                	cmp    %edx,%eax
  800f02:	73 15                	jae    800f19 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800f04:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800f08:	38 08                	cmp    %cl,(%eax)
  800f0a:	75 06                	jne    800f12 <memfind+0x1d>
  800f0c:	eb 0b                	jmp    800f19 <memfind+0x24>
  800f0e:	38 08                	cmp    %cl,(%eax)
  800f10:	74 07                	je     800f19 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800f12:	83 c0 01             	add    $0x1,%eax
  800f15:	39 c2                	cmp    %eax,%edx
  800f17:	77 f5                	ja     800f0e <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800f19:	5d                   	pop    %ebp
  800f1a:	c3                   	ret    

00800f1b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	57                   	push   %edi
  800f1f:	56                   	push   %esi
  800f20:	53                   	push   %ebx
  800f21:	83 ec 04             	sub    $0x4,%esp
  800f24:	8b 55 08             	mov    0x8(%ebp),%edx
  800f27:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f2a:	0f b6 02             	movzbl (%edx),%eax
  800f2d:	3c 20                	cmp    $0x20,%al
  800f2f:	74 04                	je     800f35 <strtol+0x1a>
  800f31:	3c 09                	cmp    $0x9,%al
  800f33:	75 0e                	jne    800f43 <strtol+0x28>
		s++;
  800f35:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f38:	0f b6 02             	movzbl (%edx),%eax
  800f3b:	3c 20                	cmp    $0x20,%al
  800f3d:	74 f6                	je     800f35 <strtol+0x1a>
  800f3f:	3c 09                	cmp    $0x9,%al
  800f41:	74 f2                	je     800f35 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f43:	3c 2b                	cmp    $0x2b,%al
  800f45:	75 0c                	jne    800f53 <strtol+0x38>
		s++;
  800f47:	83 c2 01             	add    $0x1,%edx
  800f4a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800f51:	eb 15                	jmp    800f68 <strtol+0x4d>
	else if (*s == '-')
  800f53:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800f5a:	3c 2d                	cmp    $0x2d,%al
  800f5c:	75 0a                	jne    800f68 <strtol+0x4d>
		s++, neg = 1;
  800f5e:	83 c2 01             	add    $0x1,%edx
  800f61:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f68:	85 db                	test   %ebx,%ebx
  800f6a:	0f 94 c0             	sete   %al
  800f6d:	74 05                	je     800f74 <strtol+0x59>
  800f6f:	83 fb 10             	cmp    $0x10,%ebx
  800f72:	75 18                	jne    800f8c <strtol+0x71>
  800f74:	80 3a 30             	cmpb   $0x30,(%edx)
  800f77:	75 13                	jne    800f8c <strtol+0x71>
  800f79:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f7d:	8d 76 00             	lea    0x0(%esi),%esi
  800f80:	75 0a                	jne    800f8c <strtol+0x71>
		s += 2, base = 16;
  800f82:	83 c2 02             	add    $0x2,%edx
  800f85:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f8a:	eb 15                	jmp    800fa1 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f8c:	84 c0                	test   %al,%al
  800f8e:	66 90                	xchg   %ax,%ax
  800f90:	74 0f                	je     800fa1 <strtol+0x86>
  800f92:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f97:	80 3a 30             	cmpb   $0x30,(%edx)
  800f9a:	75 05                	jne    800fa1 <strtol+0x86>
		s++, base = 8;
  800f9c:	83 c2 01             	add    $0x1,%edx
  800f9f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800fa1:	b8 00 00 00 00       	mov    $0x0,%eax
  800fa6:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800fa8:	0f b6 0a             	movzbl (%edx),%ecx
  800fab:	89 cf                	mov    %ecx,%edi
  800fad:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800fb0:	80 fb 09             	cmp    $0x9,%bl
  800fb3:	77 08                	ja     800fbd <strtol+0xa2>
			dig = *s - '0';
  800fb5:	0f be c9             	movsbl %cl,%ecx
  800fb8:	83 e9 30             	sub    $0x30,%ecx
  800fbb:	eb 1e                	jmp    800fdb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800fbd:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800fc0:	80 fb 19             	cmp    $0x19,%bl
  800fc3:	77 08                	ja     800fcd <strtol+0xb2>
			dig = *s - 'a' + 10;
  800fc5:	0f be c9             	movsbl %cl,%ecx
  800fc8:	83 e9 57             	sub    $0x57,%ecx
  800fcb:	eb 0e                	jmp    800fdb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800fcd:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800fd0:	80 fb 19             	cmp    $0x19,%bl
  800fd3:	77 15                	ja     800fea <strtol+0xcf>
			dig = *s - 'A' + 10;
  800fd5:	0f be c9             	movsbl %cl,%ecx
  800fd8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800fdb:	39 f1                	cmp    %esi,%ecx
  800fdd:	7d 0b                	jge    800fea <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800fdf:	83 c2 01             	add    $0x1,%edx
  800fe2:	0f af c6             	imul   %esi,%eax
  800fe5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800fe8:	eb be                	jmp    800fa8 <strtol+0x8d>
  800fea:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800fec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ff0:	74 05                	je     800ff7 <strtol+0xdc>
		*endptr = (char *) s;
  800ff2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ff5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800ff7:	89 ca                	mov    %ecx,%edx
  800ff9:	f7 da                	neg    %edx
  800ffb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800fff:	0f 45 c2             	cmovne %edx,%eax
}
  801002:	83 c4 04             	add    $0x4,%esp
  801005:	5b                   	pop    %ebx
  801006:	5e                   	pop    %esi
  801007:	5f                   	pop    %edi
  801008:	5d                   	pop    %ebp
  801009:	c3                   	ret    
  80100a:	66 90                	xchg   %ax,%ax
  80100c:	66 90                	xchg   %ax,%ax
  80100e:	66 90                	xchg   %ax,%ax

00801010 <__udivdi3>:
  801010:	55                   	push   %ebp
  801011:	89 e5                	mov    %esp,%ebp
  801013:	57                   	push   %edi
  801014:	56                   	push   %esi
  801015:	83 ec 10             	sub    $0x10,%esp
  801018:	8b 45 14             	mov    0x14(%ebp),%eax
  80101b:	8b 55 08             	mov    0x8(%ebp),%edx
  80101e:	8b 75 10             	mov    0x10(%ebp),%esi
  801021:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801024:	85 c0                	test   %eax,%eax
  801026:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801029:	75 35                	jne    801060 <__udivdi3+0x50>
  80102b:	39 fe                	cmp    %edi,%esi
  80102d:	77 61                	ja     801090 <__udivdi3+0x80>
  80102f:	85 f6                	test   %esi,%esi
  801031:	75 0b                	jne    80103e <__udivdi3+0x2e>
  801033:	b8 01 00 00 00       	mov    $0x1,%eax
  801038:	31 d2                	xor    %edx,%edx
  80103a:	f7 f6                	div    %esi
  80103c:	89 c6                	mov    %eax,%esi
  80103e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801041:	31 d2                	xor    %edx,%edx
  801043:	89 f8                	mov    %edi,%eax
  801045:	f7 f6                	div    %esi
  801047:	89 c7                	mov    %eax,%edi
  801049:	89 c8                	mov    %ecx,%eax
  80104b:	f7 f6                	div    %esi
  80104d:	89 c1                	mov    %eax,%ecx
  80104f:	89 fa                	mov    %edi,%edx
  801051:	89 c8                	mov    %ecx,%eax
  801053:	83 c4 10             	add    $0x10,%esp
  801056:	5e                   	pop    %esi
  801057:	5f                   	pop    %edi
  801058:	5d                   	pop    %ebp
  801059:	c3                   	ret    
  80105a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801060:	39 f8                	cmp    %edi,%eax
  801062:	77 1c                	ja     801080 <__udivdi3+0x70>
  801064:	0f bd d0             	bsr    %eax,%edx
  801067:	83 f2 1f             	xor    $0x1f,%edx
  80106a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80106d:	75 39                	jne    8010a8 <__udivdi3+0x98>
  80106f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801072:	0f 86 a0 00 00 00    	jbe    801118 <__udivdi3+0x108>
  801078:	39 f8                	cmp    %edi,%eax
  80107a:	0f 82 98 00 00 00    	jb     801118 <__udivdi3+0x108>
  801080:	31 ff                	xor    %edi,%edi
  801082:	31 c9                	xor    %ecx,%ecx
  801084:	89 c8                	mov    %ecx,%eax
  801086:	89 fa                	mov    %edi,%edx
  801088:	83 c4 10             	add    $0x10,%esp
  80108b:	5e                   	pop    %esi
  80108c:	5f                   	pop    %edi
  80108d:	5d                   	pop    %ebp
  80108e:	c3                   	ret    
  80108f:	90                   	nop
  801090:	89 d1                	mov    %edx,%ecx
  801092:	89 fa                	mov    %edi,%edx
  801094:	89 c8                	mov    %ecx,%eax
  801096:	31 ff                	xor    %edi,%edi
  801098:	f7 f6                	div    %esi
  80109a:	89 c1                	mov    %eax,%ecx
  80109c:	89 fa                	mov    %edi,%edx
  80109e:	89 c8                	mov    %ecx,%eax
  8010a0:	83 c4 10             	add    $0x10,%esp
  8010a3:	5e                   	pop    %esi
  8010a4:	5f                   	pop    %edi
  8010a5:	5d                   	pop    %ebp
  8010a6:	c3                   	ret    
  8010a7:	90                   	nop
  8010a8:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010ac:	89 f2                	mov    %esi,%edx
  8010ae:	d3 e0                	shl    %cl,%eax
  8010b0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8010b3:	b8 20 00 00 00       	mov    $0x20,%eax
  8010b8:	2b 45 f4             	sub    -0xc(%ebp),%eax
  8010bb:	89 c1                	mov    %eax,%ecx
  8010bd:	d3 ea                	shr    %cl,%edx
  8010bf:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010c3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8010c6:	d3 e6                	shl    %cl,%esi
  8010c8:	89 c1                	mov    %eax,%ecx
  8010ca:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8010cd:	89 fe                	mov    %edi,%esi
  8010cf:	d3 ee                	shr    %cl,%esi
  8010d1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010d5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010db:	d3 e7                	shl    %cl,%edi
  8010dd:	89 c1                	mov    %eax,%ecx
  8010df:	d3 ea                	shr    %cl,%edx
  8010e1:	09 d7                	or     %edx,%edi
  8010e3:	89 f2                	mov    %esi,%edx
  8010e5:	89 f8                	mov    %edi,%eax
  8010e7:	f7 75 ec             	divl   -0x14(%ebp)
  8010ea:	89 d6                	mov    %edx,%esi
  8010ec:	89 c7                	mov    %eax,%edi
  8010ee:	f7 65 e8             	mull   -0x18(%ebp)
  8010f1:	39 d6                	cmp    %edx,%esi
  8010f3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010f6:	72 30                	jb     801128 <__udivdi3+0x118>
  8010f8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010fb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010ff:	d3 e2                	shl    %cl,%edx
  801101:	39 c2                	cmp    %eax,%edx
  801103:	73 05                	jae    80110a <__udivdi3+0xfa>
  801105:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801108:	74 1e                	je     801128 <__udivdi3+0x118>
  80110a:	89 f9                	mov    %edi,%ecx
  80110c:	31 ff                	xor    %edi,%edi
  80110e:	e9 71 ff ff ff       	jmp    801084 <__udivdi3+0x74>
  801113:	90                   	nop
  801114:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801118:	31 ff                	xor    %edi,%edi
  80111a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80111f:	e9 60 ff ff ff       	jmp    801084 <__udivdi3+0x74>
  801124:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801128:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80112b:	31 ff                	xor    %edi,%edi
  80112d:	89 c8                	mov    %ecx,%eax
  80112f:	89 fa                	mov    %edi,%edx
  801131:	83 c4 10             	add    $0x10,%esp
  801134:	5e                   	pop    %esi
  801135:	5f                   	pop    %edi
  801136:	5d                   	pop    %ebp
  801137:	c3                   	ret    
  801138:	66 90                	xchg   %ax,%ax
  80113a:	66 90                	xchg   %ax,%ax
  80113c:	66 90                	xchg   %ax,%ax
  80113e:	66 90                	xchg   %ax,%ax

00801140 <__umoddi3>:
  801140:	55                   	push   %ebp
  801141:	89 e5                	mov    %esp,%ebp
  801143:	57                   	push   %edi
  801144:	56                   	push   %esi
  801145:	83 ec 20             	sub    $0x20,%esp
  801148:	8b 55 14             	mov    0x14(%ebp),%edx
  80114b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80114e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801151:	8b 75 0c             	mov    0xc(%ebp),%esi
  801154:	85 d2                	test   %edx,%edx
  801156:	89 c8                	mov    %ecx,%eax
  801158:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80115b:	75 13                	jne    801170 <__umoddi3+0x30>
  80115d:	39 f7                	cmp    %esi,%edi
  80115f:	76 3f                	jbe    8011a0 <__umoddi3+0x60>
  801161:	89 f2                	mov    %esi,%edx
  801163:	f7 f7                	div    %edi
  801165:	89 d0                	mov    %edx,%eax
  801167:	31 d2                	xor    %edx,%edx
  801169:	83 c4 20             	add    $0x20,%esp
  80116c:	5e                   	pop    %esi
  80116d:	5f                   	pop    %edi
  80116e:	5d                   	pop    %ebp
  80116f:	c3                   	ret    
  801170:	39 f2                	cmp    %esi,%edx
  801172:	77 4c                	ja     8011c0 <__umoddi3+0x80>
  801174:	0f bd ca             	bsr    %edx,%ecx
  801177:	83 f1 1f             	xor    $0x1f,%ecx
  80117a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80117d:	75 51                	jne    8011d0 <__umoddi3+0x90>
  80117f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801182:	0f 87 e0 00 00 00    	ja     801268 <__umoddi3+0x128>
  801188:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80118b:	29 f8                	sub    %edi,%eax
  80118d:	19 d6                	sbb    %edx,%esi
  80118f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801192:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801195:	89 f2                	mov    %esi,%edx
  801197:	83 c4 20             	add    $0x20,%esp
  80119a:	5e                   	pop    %esi
  80119b:	5f                   	pop    %edi
  80119c:	5d                   	pop    %ebp
  80119d:	c3                   	ret    
  80119e:	66 90                	xchg   %ax,%ax
  8011a0:	85 ff                	test   %edi,%edi
  8011a2:	75 0b                	jne    8011af <__umoddi3+0x6f>
  8011a4:	b8 01 00 00 00       	mov    $0x1,%eax
  8011a9:	31 d2                	xor    %edx,%edx
  8011ab:	f7 f7                	div    %edi
  8011ad:	89 c7                	mov    %eax,%edi
  8011af:	89 f0                	mov    %esi,%eax
  8011b1:	31 d2                	xor    %edx,%edx
  8011b3:	f7 f7                	div    %edi
  8011b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8011b8:	f7 f7                	div    %edi
  8011ba:	eb a9                	jmp    801165 <__umoddi3+0x25>
  8011bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011c0:	89 c8                	mov    %ecx,%eax
  8011c2:	89 f2                	mov    %esi,%edx
  8011c4:	83 c4 20             	add    $0x20,%esp
  8011c7:	5e                   	pop    %esi
  8011c8:	5f                   	pop    %edi
  8011c9:	5d                   	pop    %ebp
  8011ca:	c3                   	ret    
  8011cb:	90                   	nop
  8011cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011d0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011d4:	d3 e2                	shl    %cl,%edx
  8011d6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011d9:	ba 20 00 00 00       	mov    $0x20,%edx
  8011de:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8011e1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8011e4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011e8:	89 fa                	mov    %edi,%edx
  8011ea:	d3 ea                	shr    %cl,%edx
  8011ec:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011f0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8011f3:	d3 e7                	shl    %cl,%edi
  8011f5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011f9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011fc:	89 f2                	mov    %esi,%edx
  8011fe:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801201:	89 c7                	mov    %eax,%edi
  801203:	d3 ea                	shr    %cl,%edx
  801205:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801209:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80120c:	89 c2                	mov    %eax,%edx
  80120e:	d3 e6                	shl    %cl,%esi
  801210:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801214:	d3 ea                	shr    %cl,%edx
  801216:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80121a:	09 d6                	or     %edx,%esi
  80121c:	89 f0                	mov    %esi,%eax
  80121e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801221:	d3 e7                	shl    %cl,%edi
  801223:	89 f2                	mov    %esi,%edx
  801225:	f7 75 f4             	divl   -0xc(%ebp)
  801228:	89 d6                	mov    %edx,%esi
  80122a:	f7 65 e8             	mull   -0x18(%ebp)
  80122d:	39 d6                	cmp    %edx,%esi
  80122f:	72 2b                	jb     80125c <__umoddi3+0x11c>
  801231:	39 c7                	cmp    %eax,%edi
  801233:	72 23                	jb     801258 <__umoddi3+0x118>
  801235:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801239:	29 c7                	sub    %eax,%edi
  80123b:	19 d6                	sbb    %edx,%esi
  80123d:	89 f0                	mov    %esi,%eax
  80123f:	89 f2                	mov    %esi,%edx
  801241:	d3 ef                	shr    %cl,%edi
  801243:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801247:	d3 e0                	shl    %cl,%eax
  801249:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80124d:	09 f8                	or     %edi,%eax
  80124f:	d3 ea                	shr    %cl,%edx
  801251:	83 c4 20             	add    $0x20,%esp
  801254:	5e                   	pop    %esi
  801255:	5f                   	pop    %edi
  801256:	5d                   	pop    %ebp
  801257:	c3                   	ret    
  801258:	39 d6                	cmp    %edx,%esi
  80125a:	75 d9                	jne    801235 <__umoddi3+0xf5>
  80125c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80125f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801262:	eb d1                	jmp    801235 <__umoddi3+0xf5>
  801264:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801268:	39 f2                	cmp    %esi,%edx
  80126a:	0f 82 18 ff ff ff    	jb     801188 <__umoddi3+0x48>
  801270:	e9 1d ff ff ff       	jmp    801192 <__umoddi3+0x52>
