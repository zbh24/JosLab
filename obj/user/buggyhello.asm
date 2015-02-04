
obj/user/buggyhello：     文件格式 elf32-i386


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
  80002c:	e8 1e 00 00 00       	call   80004f <libmain>
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
	sys_cputs((char*)1, 1);
  800039:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800040:	00 
  800041:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800048:	e8 a3 00 00 00       	call   8000f0 <sys_cputs>
}
  80004d:	c9                   	leave  
  80004e:	c3                   	ret    

0080004f <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004f:	55                   	push   %ebp
  800050:	89 e5                	mov    %esp,%ebp
  800052:	83 ec 18             	sub    $0x18,%esp
  800055:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  800058:	89 75 fc             	mov    %esi,-0x4(%ebp)
  80005b:	8b 75 08             	mov    0x8(%ebp),%esi
  80005e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  800061:	c7 05 04 20 80 00 00 	movl   $0x0,0x802004
  800068:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  80006b:	e8 53 03 00 00       	call   8003c3 <sys_getenvid>
  800070:	25 ff 03 00 00       	and    $0x3ff,%eax
  800075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80007d:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800082:	85 f6                	test   %esi,%esi
  800084:	7e 07                	jle    80008d <libmain+0x3e>
		binaryname = argv[0];
  800086:	8b 03                	mov    (%ebx),%eax
  800088:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800091:	89 34 24             	mov    %esi,(%esp)
  800094:	e8 9a ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800099:	e8 0a 00 00 00       	call   8000a8 <exit>
}
  80009e:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8000a1:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8000a4:	89 ec                	mov    %ebp,%esp
  8000a6:	5d                   	pop    %ebp
  8000a7:	c3                   	ret    

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b5:	e8 3d 03 00 00       	call   8003f7 <sys_env_destroy>
}
  8000ba:	c9                   	leave  
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	83 ec 0c             	sub    $0xc,%esp
  8000c2:	89 1c 24             	mov    %ebx,(%esp)
  8000c5:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000c9:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d2:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d7:	89 d1                	mov    %edx,%ecx
  8000d9:	89 d3                	mov    %edx,%ebx
  8000db:	89 d7                	mov    %edx,%edi
  8000dd:	89 d6                	mov    %edx,%esi
  8000df:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e1:	8b 1c 24             	mov    (%esp),%ebx
  8000e4:	8b 74 24 04          	mov    0x4(%esp),%esi
  8000e8:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8000ec:	89 ec                	mov    %ebp,%esp
  8000ee:	5d                   	pop    %ebp
  8000ef:	c3                   	ret    

008000f0 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000f0:	55                   	push   %ebp
  8000f1:	89 e5                	mov    %esp,%ebp
  8000f3:	83 ec 0c             	sub    $0xc,%esp
  8000f6:	89 1c 24             	mov    %ebx,(%esp)
  8000f9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8000fd:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800101:	b8 00 00 00 00       	mov    $0x0,%eax
  800106:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800109:	8b 55 08             	mov    0x8(%ebp),%edx
  80010c:	89 c3                	mov    %eax,%ebx
  80010e:	89 c7                	mov    %eax,%edi
  800110:	89 c6                	mov    %eax,%esi
  800112:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  800114:	8b 1c 24             	mov    (%esp),%ebx
  800117:	8b 74 24 04          	mov    0x4(%esp),%esi
  80011b:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80011f:	89 ec                	mov    %ebp,%esp
  800121:	5d                   	pop    %ebp
  800122:	c3                   	ret    

00800123 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  800123:	55                   	push   %ebp
  800124:	89 e5                	mov    %esp,%ebp
  800126:	83 ec 38             	sub    $0x38,%esp
  800129:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80012c:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80012f:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800132:	b9 00 00 00 00       	mov    $0x0,%ecx
  800137:	b8 0c 00 00 00       	mov    $0xc,%eax
  80013c:	8b 55 08             	mov    0x8(%ebp),%edx
  80013f:	89 cb                	mov    %ecx,%ebx
  800141:	89 cf                	mov    %ecx,%edi
  800143:	89 ce                	mov    %ecx,%esi
  800145:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800147:	85 c0                	test   %eax,%eax
  800149:	7e 28                	jle    800173 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80014b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80014f:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  800156:	00 
  800157:	c7 44 24 08 6a 12 80 	movl   $0x80126a,0x8(%esp)
  80015e:	00 
  80015f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800166:	00 
  800167:	c7 04 24 87 12 80 00 	movl   $0x801287,(%esp)
  80016e:	e8 e1 02 00 00       	call   800454 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800173:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800176:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800179:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80017c:	89 ec                	mov    %ebp,%esp
  80017e:	5d                   	pop    %ebp
  80017f:	c3                   	ret    

00800180 <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800180:	55                   	push   %ebp
  800181:	89 e5                	mov    %esp,%ebp
  800183:	83 ec 0c             	sub    $0xc,%esp
  800186:	89 1c 24             	mov    %ebx,(%esp)
  800189:	89 74 24 04          	mov    %esi,0x4(%esp)
  80018d:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800191:	be 00 00 00 00       	mov    $0x0,%esi
  800196:	b8 0b 00 00 00       	mov    $0xb,%eax
  80019b:	8b 7d 14             	mov    0x14(%ebp),%edi
  80019e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a7:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8001a9:	8b 1c 24             	mov    (%esp),%ebx
  8001ac:	8b 74 24 04          	mov    0x4(%esp),%esi
  8001b0:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8001b4:	89 ec                	mov    %ebp,%esp
  8001b6:	5d                   	pop    %ebp
  8001b7:	c3                   	ret    

008001b8 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	83 ec 38             	sub    $0x38,%esp
  8001be:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8001c1:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8001c4:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8001c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001cc:	b8 09 00 00 00       	mov    $0x9,%eax
  8001d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d4:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d7:	89 df                	mov    %ebx,%edi
  8001d9:	89 de                	mov    %ebx,%esi
  8001db:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8001dd:	85 c0                	test   %eax,%eax
  8001df:	7e 28                	jle    800209 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8001e5:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8001ec:	00 
  8001ed:	c7 44 24 08 6a 12 80 	movl   $0x80126a,0x8(%esp)
  8001f4:	00 
  8001f5:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8001fc:	00 
  8001fd:	c7 04 24 87 12 80 00 	movl   $0x801287,(%esp)
  800204:	e8 4b 02 00 00       	call   800454 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800209:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80020c:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80020f:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800212:	89 ec                	mov    %ebp,%esp
  800214:	5d                   	pop    %ebp
  800215:	c3                   	ret    

00800216 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800216:	55                   	push   %ebp
  800217:	89 e5                	mov    %esp,%ebp
  800219:	83 ec 38             	sub    $0x38,%esp
  80021c:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80021f:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800222:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800225:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022a:	b8 08 00 00 00       	mov    $0x8,%eax
  80022f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800232:	8b 55 08             	mov    0x8(%ebp),%edx
  800235:	89 df                	mov    %ebx,%edi
  800237:	89 de                	mov    %ebx,%esi
  800239:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80023b:	85 c0                	test   %eax,%eax
  80023d:	7e 28                	jle    800267 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800243:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  80024a:	00 
  80024b:	c7 44 24 08 6a 12 80 	movl   $0x80126a,0x8(%esp)
  800252:	00 
  800253:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80025a:	00 
  80025b:	c7 04 24 87 12 80 00 	movl   $0x801287,(%esp)
  800262:	e8 ed 01 00 00       	call   800454 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800267:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80026a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80026d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800270:	89 ec                	mov    %ebp,%esp
  800272:	5d                   	pop    %ebp
  800273:	c3                   	ret    

00800274 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  800274:	55                   	push   %ebp
  800275:	89 e5                	mov    %esp,%ebp
  800277:	83 ec 38             	sub    $0x38,%esp
  80027a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80027d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800280:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800283:	bb 00 00 00 00       	mov    $0x0,%ebx
  800288:	b8 06 00 00 00       	mov    $0x6,%eax
  80028d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800290:	8b 55 08             	mov    0x8(%ebp),%edx
  800293:	89 df                	mov    %ebx,%edi
  800295:	89 de                	mov    %ebx,%esi
  800297:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800299:	85 c0                	test   %eax,%eax
  80029b:	7e 28                	jle    8002c5 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80029d:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002a1:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  8002a8:	00 
  8002a9:	c7 44 24 08 6a 12 80 	movl   $0x80126a,0x8(%esp)
  8002b0:	00 
  8002b1:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8002b8:	00 
  8002b9:	c7 04 24 87 12 80 00 	movl   $0x801287,(%esp)
  8002c0:	e8 8f 01 00 00       	call   800454 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8002c5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8002c8:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8002cb:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8002ce:	89 ec                	mov    %ebp,%esp
  8002d0:	5d                   	pop    %ebp
  8002d1:	c3                   	ret    

008002d2 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8002d2:	55                   	push   %ebp
  8002d3:	89 e5                	mov    %esp,%ebp
  8002d5:	83 ec 38             	sub    $0x38,%esp
  8002d8:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8002db:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8002de:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8002e1:	b8 05 00 00 00       	mov    $0x5,%eax
  8002e6:	8b 75 18             	mov    0x18(%ebp),%esi
  8002e9:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002ec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002ef:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002f5:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8002f7:	85 c0                	test   %eax,%eax
  8002f9:	7e 28                	jle    800323 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002fb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8002ff:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  800306:	00 
  800307:	c7 44 24 08 6a 12 80 	movl   $0x80126a,0x8(%esp)
  80030e:	00 
  80030f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800316:	00 
  800317:	c7 04 24 87 12 80 00 	movl   $0x801287,(%esp)
  80031e:	e8 31 01 00 00       	call   800454 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  800323:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800326:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800329:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80032c:	89 ec                	mov    %ebp,%esp
  80032e:	5d                   	pop    %ebp
  80032f:	c3                   	ret    

00800330 <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800330:	55                   	push   %ebp
  800331:	89 e5                	mov    %esp,%ebp
  800333:	83 ec 38             	sub    $0x38,%esp
  800336:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800339:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80033c:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80033f:	be 00 00 00 00       	mov    $0x0,%esi
  800344:	b8 04 00 00 00       	mov    $0x4,%eax
  800349:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80034c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80034f:	8b 55 08             	mov    0x8(%ebp),%edx
  800352:	89 f7                	mov    %esi,%edi
  800354:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  800356:	85 c0                	test   %eax,%eax
  800358:	7e 28                	jle    800382 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  80035a:	89 44 24 10          	mov    %eax,0x10(%esp)
  80035e:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  800365:	00 
  800366:	c7 44 24 08 6a 12 80 	movl   $0x80126a,0x8(%esp)
  80036d:	00 
  80036e:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800375:	00 
  800376:	c7 04 24 87 12 80 00 	movl   $0x801287,(%esp)
  80037d:	e8 d2 00 00 00       	call   800454 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800382:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  800385:	8b 75 f8             	mov    -0x8(%ebp),%esi
  800388:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80038b:	89 ec                	mov    %ebp,%esp
  80038d:	5d                   	pop    %ebp
  80038e:	c3                   	ret    

0080038f <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  80038f:	55                   	push   %ebp
  800390:	89 e5                	mov    %esp,%ebp
  800392:	83 ec 0c             	sub    $0xc,%esp
  800395:	89 1c 24             	mov    %ebx,(%esp)
  800398:	89 74 24 04          	mov    %esi,0x4(%esp)
  80039c:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8003a5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8003aa:	89 d1                	mov    %edx,%ecx
  8003ac:	89 d3                	mov    %edx,%ebx
  8003ae:	89 d7                	mov    %edx,%edi
  8003b0:	89 d6                	mov    %edx,%esi
  8003b2:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8003b4:	8b 1c 24             	mov    (%esp),%ebx
  8003b7:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003bb:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8003bf:	89 ec                	mov    %ebp,%esp
  8003c1:	5d                   	pop    %ebp
  8003c2:	c3                   	ret    

008003c3 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8003c3:	55                   	push   %ebp
  8003c4:	89 e5                	mov    %esp,%ebp
  8003c6:	83 ec 0c             	sub    $0xc,%esp
  8003c9:	89 1c 24             	mov    %ebx,(%esp)
  8003cc:	89 74 24 04          	mov    %esi,0x4(%esp)
  8003d0:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8003d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8003d9:	b8 02 00 00 00       	mov    $0x2,%eax
  8003de:	89 d1                	mov    %edx,%ecx
  8003e0:	89 d3                	mov    %edx,%ebx
  8003e2:	89 d7                	mov    %edx,%edi
  8003e4:	89 d6                	mov    %edx,%esi
  8003e6:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8003e8:	8b 1c 24             	mov    (%esp),%ebx
  8003eb:	8b 74 24 04          	mov    0x4(%esp),%esi
  8003ef:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8003f3:	89 ec                	mov    %ebp,%esp
  8003f5:	5d                   	pop    %ebp
  8003f6:	c3                   	ret    

008003f7 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8003f7:	55                   	push   %ebp
  8003f8:	89 e5                	mov    %esp,%ebp
  8003fa:	83 ec 38             	sub    $0x38,%esp
  8003fd:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  800400:	89 75 f8             	mov    %esi,-0x8(%ebp)
  800403:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800406:	b9 00 00 00 00       	mov    $0x0,%ecx
  80040b:	b8 03 00 00 00       	mov    $0x3,%eax
  800410:	8b 55 08             	mov    0x8(%ebp),%edx
  800413:	89 cb                	mov    %ecx,%ebx
  800415:	89 cf                	mov    %ecx,%edi
  800417:	89 ce                	mov    %ecx,%esi
  800419:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  80041b:	85 c0                	test   %eax,%eax
  80041d:	7e 28                	jle    800447 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80041f:	89 44 24 10          	mov    %eax,0x10(%esp)
  800423:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  80042a:	00 
  80042b:	c7 44 24 08 6a 12 80 	movl   $0x80126a,0x8(%esp)
  800432:	00 
  800433:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  80043a:	00 
  80043b:	c7 04 24 87 12 80 00 	movl   $0x801287,(%esp)
  800442:	e8 0d 00 00 00       	call   800454 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800447:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  80044a:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80044d:	8b 7d fc             	mov    -0x4(%ebp),%edi
  800450:	89 ec                	mov    %ebp,%esp
  800452:	5d                   	pop    %ebp
  800453:	c3                   	ret    

00800454 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800454:	55                   	push   %ebp
  800455:	89 e5                	mov    %esp,%ebp
  800457:	56                   	push   %esi
  800458:	53                   	push   %ebx
  800459:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  80045c:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80045f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800465:	e8 59 ff ff ff       	call   8003c3 <sys_getenvid>
  80046a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80046d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800471:	8b 55 08             	mov    0x8(%ebp),%edx
  800474:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800478:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80047c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800480:	c7 04 24 98 12 80 00 	movl   $0x801298,(%esp)
  800487:	e8 7f 00 00 00       	call   80050b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80048c:	89 74 24 04          	mov    %esi,0x4(%esp)
  800490:	8b 45 10             	mov    0x10(%ebp),%eax
  800493:	89 04 24             	mov    %eax,(%esp)
  800496:	e8 0f 00 00 00       	call   8004aa <vcprintf>
	cprintf("\n");
  80049b:	c7 04 24 bc 12 80 00 	movl   $0x8012bc,(%esp)
  8004a2:	e8 64 00 00 00       	call   80050b <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004a7:	cc                   	int3   
  8004a8:	eb fd                	jmp    8004a7 <_panic+0x53>

008004aa <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  8004aa:	55                   	push   %ebp
  8004ab:	89 e5                	mov    %esp,%ebp
  8004ad:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004b3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004ba:	00 00 00 
	b.cnt = 0;
  8004bd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004c4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ca:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8004d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004d5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004db:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004df:	c7 04 24 25 05 80 00 	movl   $0x800525,(%esp)
  8004e6:	e8 d2 01 00 00       	call   8006bd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004eb:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8004f1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f5:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8004fb:	89 04 24             	mov    %eax,(%esp)
  8004fe:	e8 ed fb ff ff       	call   8000f0 <sys_cputs>

	return b.cnt;
}
  800503:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800509:	c9                   	leave  
  80050a:	c3                   	ret    

0080050b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80050b:	55                   	push   %ebp
  80050c:	89 e5                	mov    %esp,%ebp
  80050e:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  800511:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  800514:	89 44 24 04          	mov    %eax,0x4(%esp)
  800518:	8b 45 08             	mov    0x8(%ebp),%eax
  80051b:	89 04 24             	mov    %eax,(%esp)
  80051e:	e8 87 ff ff ff       	call   8004aa <vcprintf>
	va_end(ap);

	return cnt;
}
  800523:	c9                   	leave  
  800524:	c3                   	ret    

00800525 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800525:	55                   	push   %ebp
  800526:	89 e5                	mov    %esp,%ebp
  800528:	53                   	push   %ebx
  800529:	83 ec 14             	sub    $0x14,%esp
  80052c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80052f:	8b 03                	mov    (%ebx),%eax
  800531:	8b 55 08             	mov    0x8(%ebp),%edx
  800534:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  800538:	83 c0 01             	add    $0x1,%eax
  80053b:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  80053d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800542:	75 19                	jne    80055d <putch+0x38>
		sys_cputs(b->buf, b->idx);
  800544:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  80054b:	00 
  80054c:	8d 43 08             	lea    0x8(%ebx),%eax
  80054f:	89 04 24             	mov    %eax,(%esp)
  800552:	e8 99 fb ff ff       	call   8000f0 <sys_cputs>
		b->idx = 0;
  800557:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  80055d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800561:	83 c4 14             	add    $0x14,%esp
  800564:	5b                   	pop    %ebx
  800565:	5d                   	pop    %ebp
  800566:	c3                   	ret    
  800567:	66 90                	xchg   %ax,%ax
  800569:	66 90                	xchg   %ax,%ax
  80056b:	66 90                	xchg   %ax,%ax
  80056d:	66 90                	xchg   %ax,%ax
  80056f:	90                   	nop

00800570 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800570:	55                   	push   %ebp
  800571:	89 e5                	mov    %esp,%ebp
  800573:	57                   	push   %edi
  800574:	56                   	push   %esi
  800575:	53                   	push   %ebx
  800576:	83 ec 4c             	sub    $0x4c,%esp
  800579:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80057c:	89 d6                	mov    %edx,%esi
  80057e:	8b 45 08             	mov    0x8(%ebp),%eax
  800581:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800584:	8b 55 0c             	mov    0xc(%ebp),%edx
  800587:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80058a:	8b 45 10             	mov    0x10(%ebp),%eax
  80058d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800590:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800593:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800596:	b9 00 00 00 00       	mov    $0x0,%ecx
  80059b:	39 d1                	cmp    %edx,%ecx
  80059d:	72 15                	jb     8005b4 <printnum+0x44>
  80059f:	77 07                	ja     8005a8 <printnum+0x38>
  8005a1:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005a4:	39 d0                	cmp    %edx,%eax
  8005a6:	76 0c                	jbe    8005b4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005a8:	83 eb 01             	sub    $0x1,%ebx
  8005ab:	85 db                	test   %ebx,%ebx
  8005ad:	8d 76 00             	lea    0x0(%esi),%esi
  8005b0:	7f 61                	jg     800613 <printnum+0xa3>
  8005b2:	eb 70                	jmp    800624 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005b4:	89 7c 24 10          	mov    %edi,0x10(%esp)
  8005b8:	83 eb 01             	sub    $0x1,%ebx
  8005bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8005bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005c3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8005c7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  8005cb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8005ce:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  8005d1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  8005d4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  8005d8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8005df:	00 
  8005e0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005e3:	89 04 24             	mov    %eax,(%esp)
  8005e6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005e9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ed:	e8 fe 09 00 00       	call   800ff0 <__udivdi3>
  8005f2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8005f5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8005f8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8005fc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800600:	89 04 24             	mov    %eax,(%esp)
  800603:	89 54 24 04          	mov    %edx,0x4(%esp)
  800607:	89 f2                	mov    %esi,%edx
  800609:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80060c:	e8 5f ff ff ff       	call   800570 <printnum>
  800611:	eb 11                	jmp    800624 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800613:	89 74 24 04          	mov    %esi,0x4(%esp)
  800617:	89 3c 24             	mov    %edi,(%esp)
  80061a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80061d:	83 eb 01             	sub    $0x1,%ebx
  800620:	85 db                	test   %ebx,%ebx
  800622:	7f ef                	jg     800613 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800624:	89 74 24 04          	mov    %esi,0x4(%esp)
  800628:	8b 74 24 04          	mov    0x4(%esp),%esi
  80062c:	8b 45 dc             	mov    -0x24(%ebp),%eax
  80062f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800633:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80063a:	00 
  80063b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80063e:	89 14 24             	mov    %edx,(%esp)
  800641:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800644:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800648:	e8 d3 0a 00 00       	call   801120 <__umoddi3>
  80064d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800651:	0f be 80 be 12 80 00 	movsbl 0x8012be(%eax),%eax
  800658:	89 04 24             	mov    %eax,(%esp)
  80065b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80065e:	83 c4 4c             	add    $0x4c,%esp
  800661:	5b                   	pop    %ebx
  800662:	5e                   	pop    %esi
  800663:	5f                   	pop    %edi
  800664:	5d                   	pop    %ebp
  800665:	c3                   	ret    

00800666 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800666:	55                   	push   %ebp
  800667:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800669:	83 fa 01             	cmp    $0x1,%edx
  80066c:	7e 0e                	jle    80067c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80066e:	8b 10                	mov    (%eax),%edx
  800670:	8d 4a 08             	lea    0x8(%edx),%ecx
  800673:	89 08                	mov    %ecx,(%eax)
  800675:	8b 02                	mov    (%edx),%eax
  800677:	8b 52 04             	mov    0x4(%edx),%edx
  80067a:	eb 22                	jmp    80069e <getuint+0x38>
	else if (lflag)
  80067c:	85 d2                	test   %edx,%edx
  80067e:	74 10                	je     800690 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800680:	8b 10                	mov    (%eax),%edx
  800682:	8d 4a 04             	lea    0x4(%edx),%ecx
  800685:	89 08                	mov    %ecx,(%eax)
  800687:	8b 02                	mov    (%edx),%eax
  800689:	ba 00 00 00 00       	mov    $0x0,%edx
  80068e:	eb 0e                	jmp    80069e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800690:	8b 10                	mov    (%eax),%edx
  800692:	8d 4a 04             	lea    0x4(%edx),%ecx
  800695:	89 08                	mov    %ecx,(%eax)
  800697:	8b 02                	mov    (%edx),%eax
  800699:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80069e:	5d                   	pop    %ebp
  80069f:	c3                   	ret    

008006a0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8006a0:	55                   	push   %ebp
  8006a1:	89 e5                	mov    %esp,%ebp
  8006a3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8006a6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8006aa:	8b 10                	mov    (%eax),%edx
  8006ac:	3b 50 04             	cmp    0x4(%eax),%edx
  8006af:	73 0a                	jae    8006bb <sprintputch+0x1b>
		*b->buf++ = ch;
  8006b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006b4:	88 0a                	mov    %cl,(%edx)
  8006b6:	83 c2 01             	add    $0x1,%edx
  8006b9:	89 10                	mov    %edx,(%eax)
}
  8006bb:	5d                   	pop    %ebp
  8006bc:	c3                   	ret    

008006bd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006bd:	55                   	push   %ebp
  8006be:	89 e5                	mov    %esp,%ebp
  8006c0:	57                   	push   %edi
  8006c1:	56                   	push   %esi
  8006c2:	53                   	push   %ebx
  8006c3:	83 ec 5c             	sub    $0x5c,%esp
  8006c6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8006cc:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  8006cf:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8006d6:	eb 11                	jmp    8006e9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  8006d8:	85 c0                	test   %eax,%eax
  8006da:	0f 84 16 04 00 00    	je     800af6 <vprintfmt+0x439>
				return;
			putch(ch, putdat);
  8006e0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8006e4:	89 04 24             	mov    %eax,(%esp)
  8006e7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e9:	0f b6 03             	movzbl (%ebx),%eax
  8006ec:	83 c3 01             	add    $0x1,%ebx
  8006ef:	83 f8 25             	cmp    $0x25,%eax
  8006f2:	75 e4                	jne    8006d8 <vprintfmt+0x1b>
  8006f4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8006fb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  800702:	b9 00 00 00 00       	mov    $0x0,%ecx
  800707:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  80070b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  800712:	eb 06                	jmp    80071a <vprintfmt+0x5d>
  800714:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  800718:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80071a:	0f b6 13             	movzbl (%ebx),%edx
  80071d:	0f b6 c2             	movzbl %dl,%eax
  800720:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800723:	8d 43 01             	lea    0x1(%ebx),%eax
  800726:	83 ea 23             	sub    $0x23,%edx
  800729:	80 fa 55             	cmp    $0x55,%dl
  80072c:	0f 87 a7 03 00 00    	ja     800ad9 <vprintfmt+0x41c>
  800732:	0f b6 d2             	movzbl %dl,%edx
  800735:	ff 24 95 80 13 80 00 	jmp    *0x801380(,%edx,4)
  80073c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800740:	eb d6                	jmp    800718 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800742:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800745:	83 ea 30             	sub    $0x30,%edx
  800748:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80074b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80074e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800751:	83 fb 09             	cmp    $0x9,%ebx
  800754:	77 54                	ja     8007aa <vprintfmt+0xed>
  800756:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800759:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80075c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80075f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800762:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800766:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800769:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80076c:	83 fb 09             	cmp    $0x9,%ebx
  80076f:	76 eb                	jbe    80075c <vprintfmt+0x9f>
  800771:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800774:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800777:	eb 31                	jmp    8007aa <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800779:	8b 55 14             	mov    0x14(%ebp),%edx
  80077c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80077f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800782:	8b 12                	mov    (%edx),%edx
  800784:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800787:	eb 21                	jmp    8007aa <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800789:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80078d:	ba 00 00 00 00       	mov    $0x0,%edx
  800792:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  800796:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800799:	e9 7a ff ff ff       	jmp    800718 <vprintfmt+0x5b>
  80079e:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  8007a5:	e9 6e ff ff ff       	jmp    800718 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  8007aa:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007ae:	0f 89 64 ff ff ff    	jns    800718 <vprintfmt+0x5b>
  8007b4:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007b7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8007ba:	8b 55 c8             	mov    -0x38(%ebp),%edx
  8007bd:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007c0:	e9 53 ff ff ff       	jmp    800718 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007c5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  8007c8:	e9 4b ff ff ff       	jmp    800718 <vprintfmt+0x5b>
  8007cd:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d3:	8d 50 04             	lea    0x4(%eax),%edx
  8007d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d9:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007dd:	8b 00                	mov    (%eax),%eax
  8007df:	89 04 24             	mov    %eax,(%esp)
  8007e2:	ff d7                	call   *%edi
  8007e4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8007e7:	e9 fd fe ff ff       	jmp    8006e9 <vprintfmt+0x2c>
  8007ec:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8007ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f2:	8d 50 04             	lea    0x4(%eax),%edx
  8007f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f8:	8b 00                	mov    (%eax),%eax
  8007fa:	89 c2                	mov    %eax,%edx
  8007fc:	c1 fa 1f             	sar    $0x1f,%edx
  8007ff:	31 d0                	xor    %edx,%eax
  800801:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800803:	83 f8 08             	cmp    $0x8,%eax
  800806:	7f 0b                	jg     800813 <vprintfmt+0x156>
  800808:	8b 14 85 e0 14 80 00 	mov    0x8014e0(,%eax,4),%edx
  80080f:	85 d2                	test   %edx,%edx
  800811:	75 20                	jne    800833 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  800813:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800817:	c7 44 24 08 cf 12 80 	movl   $0x8012cf,0x8(%esp)
  80081e:	00 
  80081f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800823:	89 3c 24             	mov    %edi,(%esp)
  800826:	e8 53 03 00 00       	call   800b7e <printfmt>
  80082b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80082e:	e9 b6 fe ff ff       	jmp    8006e9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800833:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800837:	c7 44 24 08 d8 12 80 	movl   $0x8012d8,0x8(%esp)
  80083e:	00 
  80083f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800843:	89 3c 24             	mov    %edi,(%esp)
  800846:	e8 33 03 00 00       	call   800b7e <printfmt>
  80084b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80084e:	e9 96 fe ff ff       	jmp    8006e9 <vprintfmt+0x2c>
  800853:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800856:	89 c3                	mov    %eax,%ebx
  800858:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  80085b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80085e:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800861:	8b 45 14             	mov    0x14(%ebp),%eax
  800864:	8d 50 04             	lea    0x4(%eax),%edx
  800867:	89 55 14             	mov    %edx,0x14(%ebp)
  80086a:	8b 00                	mov    (%eax),%eax
  80086c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  80086f:	85 c0                	test   %eax,%eax
  800871:	b8 db 12 80 00       	mov    $0x8012db,%eax
  800876:	0f 45 45 c4          	cmovne -0x3c(%ebp),%eax
  80087a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  80087d:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800881:	7e 06                	jle    800889 <vprintfmt+0x1cc>
  800883:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800887:	75 13                	jne    80089c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800889:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  80088c:	0f be 02             	movsbl (%edx),%eax
  80088f:	85 c0                	test   %eax,%eax
  800891:	0f 85 9b 00 00 00    	jne    800932 <vprintfmt+0x275>
  800897:	e9 88 00 00 00       	jmp    800924 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80089c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  8008a0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  8008a3:	89 0c 24             	mov    %ecx,(%esp)
  8008a6:	e8 20 03 00 00       	call   800bcb <strnlen>
  8008ab:	8b 55 c0             	mov    -0x40(%ebp),%edx
  8008ae:	29 c2                	sub    %eax,%edx
  8008b0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8008b3:	85 d2                	test   %edx,%edx
  8008b5:	7e d2                	jle    800889 <vprintfmt+0x1cc>
					putch(padc, putdat);
  8008b7:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  8008bb:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8008be:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  8008c1:	89 d3                	mov    %edx,%ebx
  8008c3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008c7:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8008ca:	89 04 24             	mov    %eax,(%esp)
  8008cd:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008cf:	83 eb 01             	sub    $0x1,%ebx
  8008d2:	85 db                	test   %ebx,%ebx
  8008d4:	7f ed                	jg     8008c3 <vprintfmt+0x206>
  8008d6:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  8008d9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8008e0:	eb a7                	jmp    800889 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008e2:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  8008e6:	74 1a                	je     800902 <vprintfmt+0x245>
  8008e8:	8d 50 e0             	lea    -0x20(%eax),%edx
  8008eb:	83 fa 5e             	cmp    $0x5e,%edx
  8008ee:	76 12                	jbe    800902 <vprintfmt+0x245>
					putch('?', putdat);
  8008f0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8008f4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008fb:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  8008fe:	66 90                	xchg   %ax,%ax
  800900:	eb 0a                	jmp    80090c <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800902:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800906:	89 04 24             	mov    %eax,(%esp)
  800909:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80090c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800910:	0f be 03             	movsbl (%ebx),%eax
  800913:	85 c0                	test   %eax,%eax
  800915:	74 05                	je     80091c <vprintfmt+0x25f>
  800917:	83 c3 01             	add    $0x1,%ebx
  80091a:	eb 29                	jmp    800945 <vprintfmt+0x288>
  80091c:	89 fe                	mov    %edi,%esi
  80091e:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800921:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800924:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800928:	7f 2e                	jg     800958 <vprintfmt+0x29b>
  80092a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80092d:	e9 b7 fd ff ff       	jmp    8006e9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800932:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800935:	83 c2 01             	add    $0x1,%edx
  800938:	89 7d dc             	mov    %edi,-0x24(%ebp)
  80093b:	89 f7                	mov    %esi,%edi
  80093d:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800940:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800943:	89 d3                	mov    %edx,%ebx
  800945:	85 f6                	test   %esi,%esi
  800947:	78 99                	js     8008e2 <vprintfmt+0x225>
  800949:	83 ee 01             	sub    $0x1,%esi
  80094c:	79 94                	jns    8008e2 <vprintfmt+0x225>
  80094e:	89 fe                	mov    %edi,%esi
  800950:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800953:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800956:	eb cc                	jmp    800924 <vprintfmt+0x267>
  800958:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  80095b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80095e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800962:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800969:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80096b:	83 eb 01             	sub    $0x1,%ebx
  80096e:	85 db                	test   %ebx,%ebx
  800970:	7f ec                	jg     80095e <vprintfmt+0x2a1>
  800972:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800975:	e9 6f fd ff ff       	jmp    8006e9 <vprintfmt+0x2c>
  80097a:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80097d:	83 f9 01             	cmp    $0x1,%ecx
  800980:	7e 16                	jle    800998 <vprintfmt+0x2db>
		return va_arg(*ap, long long);
  800982:	8b 45 14             	mov    0x14(%ebp),%eax
  800985:	8d 50 08             	lea    0x8(%eax),%edx
  800988:	89 55 14             	mov    %edx,0x14(%ebp)
  80098b:	8b 10                	mov    (%eax),%edx
  80098d:	8b 48 04             	mov    0x4(%eax),%ecx
  800990:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800993:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800996:	eb 32                	jmp    8009ca <vprintfmt+0x30d>
	else if (lflag)
  800998:	85 c9                	test   %ecx,%ecx
  80099a:	74 18                	je     8009b4 <vprintfmt+0x2f7>
		return va_arg(*ap, long);
  80099c:	8b 45 14             	mov    0x14(%ebp),%eax
  80099f:	8d 50 04             	lea    0x4(%eax),%edx
  8009a2:	89 55 14             	mov    %edx,0x14(%ebp)
  8009a5:	8b 00                	mov    (%eax),%eax
  8009a7:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009aa:	89 c1                	mov    %eax,%ecx
  8009ac:	c1 f9 1f             	sar    $0x1f,%ecx
  8009af:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  8009b2:	eb 16                	jmp    8009ca <vprintfmt+0x30d>
	else
		return va_arg(*ap, int);
  8009b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b7:	8d 50 04             	lea    0x4(%eax),%edx
  8009ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8009bd:	8b 00                	mov    (%eax),%eax
  8009bf:	89 45 d0             	mov    %eax,-0x30(%ebp)
  8009c2:	89 c2                	mov    %eax,%edx
  8009c4:	c1 fa 1f             	sar    $0x1f,%edx
  8009c7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8009ca:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8009cd:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8009d0:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  8009d5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8009d9:	0f 89 b8 00 00 00    	jns    800a97 <vprintfmt+0x3da>
				putch('-', putdat);
  8009df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009e3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009ea:	ff d7                	call   *%edi
				num = -(long long) num;
  8009ec:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8009ef:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8009f2:	f7 d9                	neg    %ecx
  8009f4:	83 d3 00             	adc    $0x0,%ebx
  8009f7:	f7 db                	neg    %ebx
  8009f9:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009fe:	e9 94 00 00 00       	jmp    800a97 <vprintfmt+0x3da>
  800a03:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800a06:	89 ca                	mov    %ecx,%edx
  800a08:	8d 45 14             	lea    0x14(%ebp),%eax
  800a0b:	e8 56 fc ff ff       	call   800666 <getuint>
  800a10:	89 c1                	mov    %eax,%ecx
  800a12:	89 d3                	mov    %edx,%ebx
  800a14:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800a19:	eb 7c                	jmp    800a97 <vprintfmt+0x3da>
  800a1b:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800a1e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a22:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800a29:	ff d7                	call   *%edi
			putch('X', putdat);
  800a2b:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a2f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800a36:	ff d7                	call   *%edi
			putch('X', putdat);
  800a38:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a3c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800a43:	ff d7                	call   *%edi
  800a45:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800a48:	e9 9c fc ff ff       	jmp    8006e9 <vprintfmt+0x2c>
  800a4d:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800a50:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a54:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a5b:	ff d7                	call   *%edi
			putch('x', putdat);
  800a5d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a61:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a68:	ff d7                	call   *%edi
			num = (unsigned long long)
  800a6a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a6d:	8d 50 04             	lea    0x4(%eax),%edx
  800a70:	89 55 14             	mov    %edx,0x14(%ebp)
  800a73:	8b 08                	mov    (%eax),%ecx
  800a75:	bb 00 00 00 00       	mov    $0x0,%ebx
  800a7a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800a7f:	eb 16                	jmp    800a97 <vprintfmt+0x3da>
  800a81:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a84:	89 ca                	mov    %ecx,%edx
  800a86:	8d 45 14             	lea    0x14(%ebp),%eax
  800a89:	e8 d8 fb ff ff       	call   800666 <getuint>
  800a8e:	89 c1                	mov    %eax,%ecx
  800a90:	89 d3                	mov    %edx,%ebx
  800a92:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a97:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800a9b:	89 54 24 10          	mov    %edx,0x10(%esp)
  800a9f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800aa2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800aa6:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aaa:	89 0c 24             	mov    %ecx,(%esp)
  800aad:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800ab1:	89 f2                	mov    %esi,%edx
  800ab3:	89 f8                	mov    %edi,%eax
  800ab5:	e8 b6 fa ff ff       	call   800570 <printnum>
  800aba:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800abd:	e9 27 fc ff ff       	jmp    8006e9 <vprintfmt+0x2c>
  800ac2:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800ac5:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ac8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800acc:	89 14 24             	mov    %edx,(%esp)
  800acf:	ff d7                	call   *%edi
  800ad1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800ad4:	e9 10 fc ff ff       	jmp    8006e9 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ad9:	89 74 24 04          	mov    %esi,0x4(%esp)
  800add:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ae4:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ae6:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ae9:	80 38 25             	cmpb   $0x25,(%eax)
  800aec:	0f 84 f7 fb ff ff    	je     8006e9 <vprintfmt+0x2c>
  800af2:	89 c3                	mov    %eax,%ebx
  800af4:	eb f0                	jmp    800ae6 <vprintfmt+0x429>
				/* do nothing */;
			break;
		}
	}
}
  800af6:	83 c4 5c             	add    $0x5c,%esp
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5f                   	pop    %edi
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	83 ec 28             	sub    $0x28,%esp
  800b04:	8b 45 08             	mov    0x8(%ebp),%eax
  800b07:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800b0a:	85 c0                	test   %eax,%eax
  800b0c:	74 04                	je     800b12 <vsnprintf+0x14>
  800b0e:	85 d2                	test   %edx,%edx
  800b10:	7f 07                	jg     800b19 <vsnprintf+0x1b>
  800b12:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b17:	eb 3b                	jmp    800b54 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b19:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b1c:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800b20:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b23:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b2a:	8b 45 14             	mov    0x14(%ebp),%eax
  800b2d:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b31:	8b 45 10             	mov    0x10(%ebp),%eax
  800b34:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b38:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b3b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b3f:	c7 04 24 a0 06 80 00 	movl   $0x8006a0,(%esp)
  800b46:	e8 72 fb ff ff       	call   8006bd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800b4b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800b4e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b51:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800b54:	c9                   	leave  
  800b55:	c3                   	ret    

00800b56 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b56:	55                   	push   %ebp
  800b57:	89 e5                	mov    %esp,%ebp
  800b59:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800b5c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800b5f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b63:	8b 45 10             	mov    0x10(%ebp),%eax
  800b66:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b71:	8b 45 08             	mov    0x8(%ebp),%eax
  800b74:	89 04 24             	mov    %eax,(%esp)
  800b77:	e8 82 ff ff ff       	call   800afe <vsnprintf>
	va_end(ap);

	return rc;
}
  800b7c:	c9                   	leave  
  800b7d:	c3                   	ret    

00800b7e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b7e:	55                   	push   %ebp
  800b7f:	89 e5                	mov    %esp,%ebp
  800b81:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800b84:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800b87:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b8b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b8e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b92:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b95:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b99:	8b 45 08             	mov    0x8(%ebp),%eax
  800b9c:	89 04 24             	mov    %eax,(%esp)
  800b9f:	e8 19 fb ff ff       	call   8006bd <vprintfmt>
	va_end(ap);
}
  800ba4:	c9                   	leave  
  800ba5:	c3                   	ret    
  800ba6:	66 90                	xchg   %ax,%ax
  800ba8:	66 90                	xchg   %ax,%ax
  800baa:	66 90                	xchg   %ax,%ax
  800bac:	66 90                	xchg   %ax,%ax
  800bae:	66 90                	xchg   %ax,%ax

00800bb0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bb0:	55                   	push   %ebp
  800bb1:	89 e5                	mov    %esp,%ebp
  800bb3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800bb6:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbb:	80 3a 00             	cmpb   $0x0,(%edx)
  800bbe:	74 09                	je     800bc9 <strlen+0x19>
		n++;
  800bc0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bc3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800bc7:	75 f7                	jne    800bc0 <strlen+0x10>
		n++;
	return n;
}
  800bc9:	5d                   	pop    %ebp
  800bca:	c3                   	ret    

00800bcb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	53                   	push   %ebx
  800bcf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800bd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800bd5:	85 c9                	test   %ecx,%ecx
  800bd7:	74 19                	je     800bf2 <strnlen+0x27>
  800bd9:	80 3b 00             	cmpb   $0x0,(%ebx)
  800bdc:	74 14                	je     800bf2 <strnlen+0x27>
  800bde:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800be3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800be6:	39 c8                	cmp    %ecx,%eax
  800be8:	74 0d                	je     800bf7 <strnlen+0x2c>
  800bea:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800bee:	75 f3                	jne    800be3 <strnlen+0x18>
  800bf0:	eb 05                	jmp    800bf7 <strnlen+0x2c>
  800bf2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800bf7:	5b                   	pop    %ebx
  800bf8:	5d                   	pop    %ebp
  800bf9:	c3                   	ret    

00800bfa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	53                   	push   %ebx
  800bfe:	8b 45 08             	mov    0x8(%ebp),%eax
  800c01:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c04:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800c09:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800c0d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800c10:	83 c2 01             	add    $0x1,%edx
  800c13:	84 c9                	test   %cl,%cl
  800c15:	75 f2                	jne    800c09 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800c17:	5b                   	pop    %ebx
  800c18:	5d                   	pop    %ebp
  800c19:	c3                   	ret    

00800c1a <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c1a:	55                   	push   %ebp
  800c1b:	89 e5                	mov    %esp,%ebp
  800c1d:	53                   	push   %ebx
  800c1e:	83 ec 08             	sub    $0x8,%esp
  800c21:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800c24:	89 1c 24             	mov    %ebx,(%esp)
  800c27:	e8 84 ff ff ff       	call   800bb0 <strlen>
	strcpy(dst + len, src);
  800c2c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c2f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800c33:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800c36:	89 04 24             	mov    %eax,(%esp)
  800c39:	e8 bc ff ff ff       	call   800bfa <strcpy>
	return dst;
}
  800c3e:	89 d8                	mov    %ebx,%eax
  800c40:	83 c4 08             	add    $0x8,%esp
  800c43:	5b                   	pop    %ebx
  800c44:	5d                   	pop    %ebp
  800c45:	c3                   	ret    

00800c46 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	56                   	push   %esi
  800c4a:	53                   	push   %ebx
  800c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c51:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c54:	85 f6                	test   %esi,%esi
  800c56:	74 18                	je     800c70 <strncpy+0x2a>
  800c58:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800c5d:	0f b6 1a             	movzbl (%edx),%ebx
  800c60:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800c63:	80 3a 01             	cmpb   $0x1,(%edx)
  800c66:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800c69:	83 c1 01             	add    $0x1,%ecx
  800c6c:	39 ce                	cmp    %ecx,%esi
  800c6e:	77 ed                	ja     800c5d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800c70:	5b                   	pop    %ebx
  800c71:	5e                   	pop    %esi
  800c72:	5d                   	pop    %ebp
  800c73:	c3                   	ret    

00800c74 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800c74:	55                   	push   %ebp
  800c75:	89 e5                	mov    %esp,%ebp
  800c77:	56                   	push   %esi
  800c78:	53                   	push   %ebx
  800c79:	8b 75 08             	mov    0x8(%ebp),%esi
  800c7c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c7f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c82:	89 f0                	mov    %esi,%eax
  800c84:	85 c9                	test   %ecx,%ecx
  800c86:	74 27                	je     800caf <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800c88:	83 e9 01             	sub    $0x1,%ecx
  800c8b:	74 1d                	je     800caa <strlcpy+0x36>
  800c8d:	0f b6 1a             	movzbl (%edx),%ebx
  800c90:	84 db                	test   %bl,%bl
  800c92:	74 16                	je     800caa <strlcpy+0x36>
			*dst++ = *src++;
  800c94:	88 18                	mov    %bl,(%eax)
  800c96:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800c99:	83 e9 01             	sub    $0x1,%ecx
  800c9c:	74 0e                	je     800cac <strlcpy+0x38>
			*dst++ = *src++;
  800c9e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800ca1:	0f b6 1a             	movzbl (%edx),%ebx
  800ca4:	84 db                	test   %bl,%bl
  800ca6:	75 ec                	jne    800c94 <strlcpy+0x20>
  800ca8:	eb 02                	jmp    800cac <strlcpy+0x38>
  800caa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800cac:	c6 00 00             	movb   $0x0,(%eax)
  800caf:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800cb1:	5b                   	pop    %ebx
  800cb2:	5e                   	pop    %esi
  800cb3:	5d                   	pop    %ebp
  800cb4:	c3                   	ret    

00800cb5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cbb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800cbe:	0f b6 01             	movzbl (%ecx),%eax
  800cc1:	84 c0                	test   %al,%al
  800cc3:	74 15                	je     800cda <strcmp+0x25>
  800cc5:	3a 02                	cmp    (%edx),%al
  800cc7:	75 11                	jne    800cda <strcmp+0x25>
		p++, q++;
  800cc9:	83 c1 01             	add    $0x1,%ecx
  800ccc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800ccf:	0f b6 01             	movzbl (%ecx),%eax
  800cd2:	84 c0                	test   %al,%al
  800cd4:	74 04                	je     800cda <strcmp+0x25>
  800cd6:	3a 02                	cmp    (%edx),%al
  800cd8:	74 ef                	je     800cc9 <strcmp+0x14>
  800cda:	0f b6 c0             	movzbl %al,%eax
  800cdd:	0f b6 12             	movzbl (%edx),%edx
  800ce0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    

00800ce4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	53                   	push   %ebx
  800ce8:	8b 55 08             	mov    0x8(%ebp),%edx
  800ceb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800cee:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800cf1:	85 c0                	test   %eax,%eax
  800cf3:	74 23                	je     800d18 <strncmp+0x34>
  800cf5:	0f b6 1a             	movzbl (%edx),%ebx
  800cf8:	84 db                	test   %bl,%bl
  800cfa:	74 25                	je     800d21 <strncmp+0x3d>
  800cfc:	3a 19                	cmp    (%ecx),%bl
  800cfe:	75 21                	jne    800d21 <strncmp+0x3d>
  800d00:	83 e8 01             	sub    $0x1,%eax
  800d03:	74 13                	je     800d18 <strncmp+0x34>
		n--, p++, q++;
  800d05:	83 c2 01             	add    $0x1,%edx
  800d08:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d0b:	0f b6 1a             	movzbl (%edx),%ebx
  800d0e:	84 db                	test   %bl,%bl
  800d10:	74 0f                	je     800d21 <strncmp+0x3d>
  800d12:	3a 19                	cmp    (%ecx),%bl
  800d14:	74 ea                	je     800d00 <strncmp+0x1c>
  800d16:	eb 09                	jmp    800d21 <strncmp+0x3d>
  800d18:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800d1d:	5b                   	pop    %ebx
  800d1e:	5d                   	pop    %ebp
  800d1f:	90                   	nop
  800d20:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800d21:	0f b6 02             	movzbl (%edx),%eax
  800d24:	0f b6 11             	movzbl (%ecx),%edx
  800d27:	29 d0                	sub    %edx,%eax
  800d29:	eb f2                	jmp    800d1d <strncmp+0x39>

00800d2b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800d2b:	55                   	push   %ebp
  800d2c:	89 e5                	mov    %esp,%ebp
  800d2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d31:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d35:	0f b6 10             	movzbl (%eax),%edx
  800d38:	84 d2                	test   %dl,%dl
  800d3a:	74 18                	je     800d54 <strchr+0x29>
		if (*s == c)
  800d3c:	38 ca                	cmp    %cl,%dl
  800d3e:	75 0a                	jne    800d4a <strchr+0x1f>
  800d40:	eb 17                	jmp    800d59 <strchr+0x2e>
  800d42:	38 ca                	cmp    %cl,%dl
  800d44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d48:	74 0f                	je     800d59 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800d4a:	83 c0 01             	add    $0x1,%eax
  800d4d:	0f b6 10             	movzbl (%eax),%edx
  800d50:	84 d2                	test   %dl,%dl
  800d52:	75 ee                	jne    800d42 <strchr+0x17>
  800d54:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800d59:	5d                   	pop    %ebp
  800d5a:	c3                   	ret    

00800d5b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800d5b:	55                   	push   %ebp
  800d5c:	89 e5                	mov    %esp,%ebp
  800d5e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d61:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800d65:	0f b6 10             	movzbl (%eax),%edx
  800d68:	84 d2                	test   %dl,%dl
  800d6a:	74 18                	je     800d84 <strfind+0x29>
		if (*s == c)
  800d6c:	38 ca                	cmp    %cl,%dl
  800d6e:	75 0a                	jne    800d7a <strfind+0x1f>
  800d70:	eb 12                	jmp    800d84 <strfind+0x29>
  800d72:	38 ca                	cmp    %cl,%dl
  800d74:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800d78:	74 0a                	je     800d84 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800d7a:	83 c0 01             	add    $0x1,%eax
  800d7d:	0f b6 10             	movzbl (%eax),%edx
  800d80:	84 d2                	test   %dl,%dl
  800d82:	75 ee                	jne    800d72 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800d84:	5d                   	pop    %ebp
  800d85:	c3                   	ret    

00800d86 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800d86:	55                   	push   %ebp
  800d87:	89 e5                	mov    %esp,%ebp
  800d89:	83 ec 0c             	sub    $0xc,%esp
  800d8c:	89 1c 24             	mov    %ebx,(%esp)
  800d8f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800d93:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800d97:	8b 7d 08             	mov    0x8(%ebp),%edi
  800d9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800da0:	85 c9                	test   %ecx,%ecx
  800da2:	74 30                	je     800dd4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800da4:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800daa:	75 25                	jne    800dd1 <memset+0x4b>
  800dac:	f6 c1 03             	test   $0x3,%cl
  800daf:	75 20                	jne    800dd1 <memset+0x4b>
		c &= 0xFF;
  800db1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800db4:	89 d3                	mov    %edx,%ebx
  800db6:	c1 e3 08             	shl    $0x8,%ebx
  800db9:	89 d6                	mov    %edx,%esi
  800dbb:	c1 e6 18             	shl    $0x18,%esi
  800dbe:	89 d0                	mov    %edx,%eax
  800dc0:	c1 e0 10             	shl    $0x10,%eax
  800dc3:	09 f0                	or     %esi,%eax
  800dc5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800dc7:	09 d8                	or     %ebx,%eax
  800dc9:	c1 e9 02             	shr    $0x2,%ecx
  800dcc:	fc                   	cld    
  800dcd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800dcf:	eb 03                	jmp    800dd4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800dd1:	fc                   	cld    
  800dd2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800dd4:	89 f8                	mov    %edi,%eax
  800dd6:	8b 1c 24             	mov    (%esp),%ebx
  800dd9:	8b 74 24 04          	mov    0x4(%esp),%esi
  800ddd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800de1:	89 ec                	mov    %ebp,%esp
  800de3:	5d                   	pop    %ebp
  800de4:	c3                   	ret    

00800de5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800de5:	55                   	push   %ebp
  800de6:	89 e5                	mov    %esp,%ebp
  800de8:	83 ec 08             	sub    $0x8,%esp
  800deb:	89 34 24             	mov    %esi,(%esp)
  800dee:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800df2:	8b 45 08             	mov    0x8(%ebp),%eax
  800df5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800df8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800dfb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800dfd:	39 c6                	cmp    %eax,%esi
  800dff:	73 35                	jae    800e36 <memmove+0x51>
  800e01:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800e04:	39 d0                	cmp    %edx,%eax
  800e06:	73 2e                	jae    800e36 <memmove+0x51>
		s += n;
		d += n;
  800e08:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e0a:	f6 c2 03             	test   $0x3,%dl
  800e0d:	75 1b                	jne    800e2a <memmove+0x45>
  800e0f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e15:	75 13                	jne    800e2a <memmove+0x45>
  800e17:	f6 c1 03             	test   $0x3,%cl
  800e1a:	75 0e                	jne    800e2a <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800e1c:	83 ef 04             	sub    $0x4,%edi
  800e1f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800e22:	c1 e9 02             	shr    $0x2,%ecx
  800e25:	fd                   	std    
  800e26:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e28:	eb 09                	jmp    800e33 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800e2a:	83 ef 01             	sub    $0x1,%edi
  800e2d:	8d 72 ff             	lea    -0x1(%edx),%esi
  800e30:	fd                   	std    
  800e31:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800e33:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800e34:	eb 20                	jmp    800e56 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e36:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800e3c:	75 15                	jne    800e53 <memmove+0x6e>
  800e3e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800e44:	75 0d                	jne    800e53 <memmove+0x6e>
  800e46:	f6 c1 03             	test   $0x3,%cl
  800e49:	75 08                	jne    800e53 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  800e4b:	c1 e9 02             	shr    $0x2,%ecx
  800e4e:	fc                   	cld    
  800e4f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800e51:	eb 03                	jmp    800e56 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800e53:	fc                   	cld    
  800e54:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800e56:	8b 34 24             	mov    (%esp),%esi
  800e59:	8b 7c 24 04          	mov    0x4(%esp),%edi
  800e5d:	89 ec                	mov    %ebp,%esp
  800e5f:	5d                   	pop    %ebp
  800e60:	c3                   	ret    

00800e61 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800e61:	55                   	push   %ebp
  800e62:	89 e5                	mov    %esp,%ebp
  800e64:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800e67:	8b 45 10             	mov    0x10(%ebp),%eax
  800e6a:	89 44 24 08          	mov    %eax,0x8(%esp)
  800e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e71:	89 44 24 04          	mov    %eax,0x4(%esp)
  800e75:	8b 45 08             	mov    0x8(%ebp),%eax
  800e78:	89 04 24             	mov    %eax,(%esp)
  800e7b:	e8 65 ff ff ff       	call   800de5 <memmove>
}
  800e80:	c9                   	leave  
  800e81:	c3                   	ret    

00800e82 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800e82:	55                   	push   %ebp
  800e83:	89 e5                	mov    %esp,%ebp
  800e85:	57                   	push   %edi
  800e86:	56                   	push   %esi
  800e87:	53                   	push   %ebx
  800e88:	8b 75 08             	mov    0x8(%ebp),%esi
  800e8b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  800e8e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800e91:	85 c9                	test   %ecx,%ecx
  800e93:	74 36                	je     800ecb <memcmp+0x49>
		if (*s1 != *s2)
  800e95:	0f b6 06             	movzbl (%esi),%eax
  800e98:	0f b6 1f             	movzbl (%edi),%ebx
  800e9b:	38 d8                	cmp    %bl,%al
  800e9d:	74 20                	je     800ebf <memcmp+0x3d>
  800e9f:	eb 14                	jmp    800eb5 <memcmp+0x33>
  800ea1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  800ea6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  800eab:	83 c2 01             	add    $0x1,%edx
  800eae:	83 e9 01             	sub    $0x1,%ecx
  800eb1:	38 d8                	cmp    %bl,%al
  800eb3:	74 12                	je     800ec7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  800eb5:	0f b6 c0             	movzbl %al,%eax
  800eb8:	0f b6 db             	movzbl %bl,%ebx
  800ebb:	29 d8                	sub    %ebx,%eax
  800ebd:	eb 11                	jmp    800ed0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800ebf:	83 e9 01             	sub    $0x1,%ecx
  800ec2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ec7:	85 c9                	test   %ecx,%ecx
  800ec9:	75 d6                	jne    800ea1 <memcmp+0x1f>
  800ecb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  800ed0:	5b                   	pop    %ebx
  800ed1:	5e                   	pop    %esi
  800ed2:	5f                   	pop    %edi
  800ed3:	5d                   	pop    %ebp
  800ed4:	c3                   	ret    

00800ed5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ed5:	55                   	push   %ebp
  800ed6:	89 e5                	mov    %esp,%ebp
  800ed8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800edb:	89 c2                	mov    %eax,%edx
  800edd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800ee0:	39 d0                	cmp    %edx,%eax
  800ee2:	73 15                	jae    800ef9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ee4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  800ee8:	38 08                	cmp    %cl,(%eax)
  800eea:	75 06                	jne    800ef2 <memfind+0x1d>
  800eec:	eb 0b                	jmp    800ef9 <memfind+0x24>
  800eee:	38 08                	cmp    %cl,(%eax)
  800ef0:	74 07                	je     800ef9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800ef2:	83 c0 01             	add    $0x1,%eax
  800ef5:	39 c2                	cmp    %eax,%edx
  800ef7:	77 f5                	ja     800eee <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800ef9:	5d                   	pop    %ebp
  800efa:	c3                   	ret    

00800efb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800efb:	55                   	push   %ebp
  800efc:	89 e5                	mov    %esp,%ebp
  800efe:	57                   	push   %edi
  800eff:	56                   	push   %esi
  800f00:	53                   	push   %ebx
  800f01:	83 ec 04             	sub    $0x4,%esp
  800f04:	8b 55 08             	mov    0x8(%ebp),%edx
  800f07:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f0a:	0f b6 02             	movzbl (%edx),%eax
  800f0d:	3c 20                	cmp    $0x20,%al
  800f0f:	74 04                	je     800f15 <strtol+0x1a>
  800f11:	3c 09                	cmp    $0x9,%al
  800f13:	75 0e                	jne    800f23 <strtol+0x28>
		s++;
  800f15:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800f18:	0f b6 02             	movzbl (%edx),%eax
  800f1b:	3c 20                	cmp    $0x20,%al
  800f1d:	74 f6                	je     800f15 <strtol+0x1a>
  800f1f:	3c 09                	cmp    $0x9,%al
  800f21:	74 f2                	je     800f15 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  800f23:	3c 2b                	cmp    $0x2b,%al
  800f25:	75 0c                	jne    800f33 <strtol+0x38>
		s++;
  800f27:	83 c2 01             	add    $0x1,%edx
  800f2a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800f31:	eb 15                	jmp    800f48 <strtol+0x4d>
	else if (*s == '-')
  800f33:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  800f3a:	3c 2d                	cmp    $0x2d,%al
  800f3c:	75 0a                	jne    800f48 <strtol+0x4d>
		s++, neg = 1;
  800f3e:	83 c2 01             	add    $0x1,%edx
  800f41:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f48:	85 db                	test   %ebx,%ebx
  800f4a:	0f 94 c0             	sete   %al
  800f4d:	74 05                	je     800f54 <strtol+0x59>
  800f4f:	83 fb 10             	cmp    $0x10,%ebx
  800f52:	75 18                	jne    800f6c <strtol+0x71>
  800f54:	80 3a 30             	cmpb   $0x30,(%edx)
  800f57:	75 13                	jne    800f6c <strtol+0x71>
  800f59:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  800f5d:	8d 76 00             	lea    0x0(%esi),%esi
  800f60:	75 0a                	jne    800f6c <strtol+0x71>
		s += 2, base = 16;
  800f62:	83 c2 02             	add    $0x2,%edx
  800f65:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800f6a:	eb 15                	jmp    800f81 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f6c:	84 c0                	test   %al,%al
  800f6e:	66 90                	xchg   %ax,%ax
  800f70:	74 0f                	je     800f81 <strtol+0x86>
  800f72:	bb 0a 00 00 00       	mov    $0xa,%ebx
  800f77:	80 3a 30             	cmpb   $0x30,(%edx)
  800f7a:	75 05                	jne    800f81 <strtol+0x86>
		s++, base = 8;
  800f7c:	83 c2 01             	add    $0x1,%edx
  800f7f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800f81:	b8 00 00 00 00       	mov    $0x0,%eax
  800f86:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800f88:	0f b6 0a             	movzbl (%edx),%ecx
  800f8b:	89 cf                	mov    %ecx,%edi
  800f8d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  800f90:	80 fb 09             	cmp    $0x9,%bl
  800f93:	77 08                	ja     800f9d <strtol+0xa2>
			dig = *s - '0';
  800f95:	0f be c9             	movsbl %cl,%ecx
  800f98:	83 e9 30             	sub    $0x30,%ecx
  800f9b:	eb 1e                	jmp    800fbb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  800f9d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  800fa0:	80 fb 19             	cmp    $0x19,%bl
  800fa3:	77 08                	ja     800fad <strtol+0xb2>
			dig = *s - 'a' + 10;
  800fa5:	0f be c9             	movsbl %cl,%ecx
  800fa8:	83 e9 57             	sub    $0x57,%ecx
  800fab:	eb 0e                	jmp    800fbb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  800fad:	8d 5f bf             	lea    -0x41(%edi),%ebx
  800fb0:	80 fb 19             	cmp    $0x19,%bl
  800fb3:	77 15                	ja     800fca <strtol+0xcf>
			dig = *s - 'A' + 10;
  800fb5:	0f be c9             	movsbl %cl,%ecx
  800fb8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  800fbb:	39 f1                	cmp    %esi,%ecx
  800fbd:	7d 0b                	jge    800fca <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  800fbf:	83 c2 01             	add    $0x1,%edx
  800fc2:	0f af c6             	imul   %esi,%eax
  800fc5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  800fc8:	eb be                	jmp    800f88 <strtol+0x8d>
  800fca:	89 c1                	mov    %eax,%ecx

	if (endptr)
  800fcc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800fd0:	74 05                	je     800fd7 <strtol+0xdc>
		*endptr = (char *) s;
  800fd2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800fd5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  800fd7:	89 ca                	mov    %ecx,%edx
  800fd9:	f7 da                	neg    %edx
  800fdb:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  800fdf:	0f 45 c2             	cmovne %edx,%eax
}
  800fe2:	83 c4 04             	add    $0x4,%esp
  800fe5:	5b                   	pop    %ebx
  800fe6:	5e                   	pop    %esi
  800fe7:	5f                   	pop    %edi
  800fe8:	5d                   	pop    %ebp
  800fe9:	c3                   	ret    
  800fea:	66 90                	xchg   %ax,%ax
  800fec:	66 90                	xchg   %ax,%ax
  800fee:	66 90                	xchg   %ax,%ax

00800ff0 <__udivdi3>:
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	57                   	push   %edi
  800ff4:	56                   	push   %esi
  800ff5:	83 ec 10             	sub    $0x10,%esp
  800ff8:	8b 45 14             	mov    0x14(%ebp),%eax
  800ffb:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffe:	8b 75 10             	mov    0x10(%ebp),%esi
  801001:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801004:	85 c0                	test   %eax,%eax
  801006:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801009:	75 35                	jne    801040 <__udivdi3+0x50>
  80100b:	39 fe                	cmp    %edi,%esi
  80100d:	77 61                	ja     801070 <__udivdi3+0x80>
  80100f:	85 f6                	test   %esi,%esi
  801011:	75 0b                	jne    80101e <__udivdi3+0x2e>
  801013:	b8 01 00 00 00       	mov    $0x1,%eax
  801018:	31 d2                	xor    %edx,%edx
  80101a:	f7 f6                	div    %esi
  80101c:	89 c6                	mov    %eax,%esi
  80101e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  801021:	31 d2                	xor    %edx,%edx
  801023:	89 f8                	mov    %edi,%eax
  801025:	f7 f6                	div    %esi
  801027:	89 c7                	mov    %eax,%edi
  801029:	89 c8                	mov    %ecx,%eax
  80102b:	f7 f6                	div    %esi
  80102d:	89 c1                	mov    %eax,%ecx
  80102f:	89 fa                	mov    %edi,%edx
  801031:	89 c8                	mov    %ecx,%eax
  801033:	83 c4 10             	add    $0x10,%esp
  801036:	5e                   	pop    %esi
  801037:	5f                   	pop    %edi
  801038:	5d                   	pop    %ebp
  801039:	c3                   	ret    
  80103a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801040:	39 f8                	cmp    %edi,%eax
  801042:	77 1c                	ja     801060 <__udivdi3+0x70>
  801044:	0f bd d0             	bsr    %eax,%edx
  801047:	83 f2 1f             	xor    $0x1f,%edx
  80104a:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80104d:	75 39                	jne    801088 <__udivdi3+0x98>
  80104f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  801052:	0f 86 a0 00 00 00    	jbe    8010f8 <__udivdi3+0x108>
  801058:	39 f8                	cmp    %edi,%eax
  80105a:	0f 82 98 00 00 00    	jb     8010f8 <__udivdi3+0x108>
  801060:	31 ff                	xor    %edi,%edi
  801062:	31 c9                	xor    %ecx,%ecx
  801064:	89 c8                	mov    %ecx,%eax
  801066:	89 fa                	mov    %edi,%edx
  801068:	83 c4 10             	add    $0x10,%esp
  80106b:	5e                   	pop    %esi
  80106c:	5f                   	pop    %edi
  80106d:	5d                   	pop    %ebp
  80106e:	c3                   	ret    
  80106f:	90                   	nop
  801070:	89 d1                	mov    %edx,%ecx
  801072:	89 fa                	mov    %edi,%edx
  801074:	89 c8                	mov    %ecx,%eax
  801076:	31 ff                	xor    %edi,%edi
  801078:	f7 f6                	div    %esi
  80107a:	89 c1                	mov    %eax,%ecx
  80107c:	89 fa                	mov    %edi,%edx
  80107e:	89 c8                	mov    %ecx,%eax
  801080:	83 c4 10             	add    $0x10,%esp
  801083:	5e                   	pop    %esi
  801084:	5f                   	pop    %edi
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    
  801087:	90                   	nop
  801088:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80108c:	89 f2                	mov    %esi,%edx
  80108e:	d3 e0                	shl    %cl,%eax
  801090:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801093:	b8 20 00 00 00       	mov    $0x20,%eax
  801098:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80109b:	89 c1                	mov    %eax,%ecx
  80109d:	d3 ea                	shr    %cl,%edx
  80109f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010a3:	0b 55 ec             	or     -0x14(%ebp),%edx
  8010a6:	d3 e6                	shl    %cl,%esi
  8010a8:	89 c1                	mov    %eax,%ecx
  8010aa:	89 75 e8             	mov    %esi,-0x18(%ebp)
  8010ad:	89 fe                	mov    %edi,%esi
  8010af:	d3 ee                	shr    %cl,%esi
  8010b1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010b5:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010b8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010bb:	d3 e7                	shl    %cl,%edi
  8010bd:	89 c1                	mov    %eax,%ecx
  8010bf:	d3 ea                	shr    %cl,%edx
  8010c1:	09 d7                	or     %edx,%edi
  8010c3:	89 f2                	mov    %esi,%edx
  8010c5:	89 f8                	mov    %edi,%eax
  8010c7:	f7 75 ec             	divl   -0x14(%ebp)
  8010ca:	89 d6                	mov    %edx,%esi
  8010cc:	89 c7                	mov    %eax,%edi
  8010ce:	f7 65 e8             	mull   -0x18(%ebp)
  8010d1:	39 d6                	cmp    %edx,%esi
  8010d3:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8010d6:	72 30                	jb     801108 <__udivdi3+0x118>
  8010d8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010db:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  8010df:	d3 e2                	shl    %cl,%edx
  8010e1:	39 c2                	cmp    %eax,%edx
  8010e3:	73 05                	jae    8010ea <__udivdi3+0xfa>
  8010e5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  8010e8:	74 1e                	je     801108 <__udivdi3+0x118>
  8010ea:	89 f9                	mov    %edi,%ecx
  8010ec:	31 ff                	xor    %edi,%edi
  8010ee:	e9 71 ff ff ff       	jmp    801064 <__udivdi3+0x74>
  8010f3:	90                   	nop
  8010f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8010f8:	31 ff                	xor    %edi,%edi
  8010fa:	b9 01 00 00 00       	mov    $0x1,%ecx
  8010ff:	e9 60 ff ff ff       	jmp    801064 <__udivdi3+0x74>
  801104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801108:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80110b:	31 ff                	xor    %edi,%edi
  80110d:	89 c8                	mov    %ecx,%eax
  80110f:	89 fa                	mov    %edi,%edx
  801111:	83 c4 10             	add    $0x10,%esp
  801114:	5e                   	pop    %esi
  801115:	5f                   	pop    %edi
  801116:	5d                   	pop    %ebp
  801117:	c3                   	ret    
  801118:	66 90                	xchg   %ax,%ax
  80111a:	66 90                	xchg   %ax,%ax
  80111c:	66 90                	xchg   %ax,%ax
  80111e:	66 90                	xchg   %ax,%ax

00801120 <__umoddi3>:
  801120:	55                   	push   %ebp
  801121:	89 e5                	mov    %esp,%ebp
  801123:	57                   	push   %edi
  801124:	56                   	push   %esi
  801125:	83 ec 20             	sub    $0x20,%esp
  801128:	8b 55 14             	mov    0x14(%ebp),%edx
  80112b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112e:	8b 7d 10             	mov    0x10(%ebp),%edi
  801131:	8b 75 0c             	mov    0xc(%ebp),%esi
  801134:	85 d2                	test   %edx,%edx
  801136:	89 c8                	mov    %ecx,%eax
  801138:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  80113b:	75 13                	jne    801150 <__umoddi3+0x30>
  80113d:	39 f7                	cmp    %esi,%edi
  80113f:	76 3f                	jbe    801180 <__umoddi3+0x60>
  801141:	89 f2                	mov    %esi,%edx
  801143:	f7 f7                	div    %edi
  801145:	89 d0                	mov    %edx,%eax
  801147:	31 d2                	xor    %edx,%edx
  801149:	83 c4 20             	add    $0x20,%esp
  80114c:	5e                   	pop    %esi
  80114d:	5f                   	pop    %edi
  80114e:	5d                   	pop    %ebp
  80114f:	c3                   	ret    
  801150:	39 f2                	cmp    %esi,%edx
  801152:	77 4c                	ja     8011a0 <__umoddi3+0x80>
  801154:	0f bd ca             	bsr    %edx,%ecx
  801157:	83 f1 1f             	xor    $0x1f,%ecx
  80115a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80115d:	75 51                	jne    8011b0 <__umoddi3+0x90>
  80115f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  801162:	0f 87 e0 00 00 00    	ja     801248 <__umoddi3+0x128>
  801168:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80116b:	29 f8                	sub    %edi,%eax
  80116d:	19 d6                	sbb    %edx,%esi
  80116f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801172:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801175:	89 f2                	mov    %esi,%edx
  801177:	83 c4 20             	add    $0x20,%esp
  80117a:	5e                   	pop    %esi
  80117b:	5f                   	pop    %edi
  80117c:	5d                   	pop    %ebp
  80117d:	c3                   	ret    
  80117e:	66 90                	xchg   %ax,%ax
  801180:	85 ff                	test   %edi,%edi
  801182:	75 0b                	jne    80118f <__umoddi3+0x6f>
  801184:	b8 01 00 00 00       	mov    $0x1,%eax
  801189:	31 d2                	xor    %edx,%edx
  80118b:	f7 f7                	div    %edi
  80118d:	89 c7                	mov    %eax,%edi
  80118f:	89 f0                	mov    %esi,%eax
  801191:	31 d2                	xor    %edx,%edx
  801193:	f7 f7                	div    %edi
  801195:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801198:	f7 f7                	div    %edi
  80119a:	eb a9                	jmp    801145 <__umoddi3+0x25>
  80119c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011a0:	89 c8                	mov    %ecx,%eax
  8011a2:	89 f2                	mov    %esi,%edx
  8011a4:	83 c4 20             	add    $0x20,%esp
  8011a7:	5e                   	pop    %esi
  8011a8:	5f                   	pop    %edi
  8011a9:	5d                   	pop    %ebp
  8011aa:	c3                   	ret    
  8011ab:	90                   	nop
  8011ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8011b0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011b4:	d3 e2                	shl    %cl,%edx
  8011b6:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011b9:	ba 20 00 00 00       	mov    $0x20,%edx
  8011be:	2b 55 f0             	sub    -0x10(%ebp),%edx
  8011c1:	89 55 ec             	mov    %edx,-0x14(%ebp)
  8011c4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011c8:	89 fa                	mov    %edi,%edx
  8011ca:	d3 ea                	shr    %cl,%edx
  8011cc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011d0:	0b 55 f4             	or     -0xc(%ebp),%edx
  8011d3:	d3 e7                	shl    %cl,%edi
  8011d5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8011dc:	89 f2                	mov    %esi,%edx
  8011de:	89 7d e8             	mov    %edi,-0x18(%ebp)
  8011e1:	89 c7                	mov    %eax,%edi
  8011e3:	d3 ea                	shr    %cl,%edx
  8011e5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011e9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8011ec:	89 c2                	mov    %eax,%edx
  8011ee:	d3 e6                	shl    %cl,%esi
  8011f0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8011f4:	d3 ea                	shr    %cl,%edx
  8011f6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8011fa:	09 d6                	or     %edx,%esi
  8011fc:	89 f0                	mov    %esi,%eax
  8011fe:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801201:	d3 e7                	shl    %cl,%edi
  801203:	89 f2                	mov    %esi,%edx
  801205:	f7 75 f4             	divl   -0xc(%ebp)
  801208:	89 d6                	mov    %edx,%esi
  80120a:	f7 65 e8             	mull   -0x18(%ebp)
  80120d:	39 d6                	cmp    %edx,%esi
  80120f:	72 2b                	jb     80123c <__umoddi3+0x11c>
  801211:	39 c7                	cmp    %eax,%edi
  801213:	72 23                	jb     801238 <__umoddi3+0x118>
  801215:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801219:	29 c7                	sub    %eax,%edi
  80121b:	19 d6                	sbb    %edx,%esi
  80121d:	89 f0                	mov    %esi,%eax
  80121f:	89 f2                	mov    %esi,%edx
  801221:	d3 ef                	shr    %cl,%edi
  801223:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801227:	d3 e0                	shl    %cl,%eax
  801229:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80122d:	09 f8                	or     %edi,%eax
  80122f:	d3 ea                	shr    %cl,%edx
  801231:	83 c4 20             	add    $0x20,%esp
  801234:	5e                   	pop    %esi
  801235:	5f                   	pop    %edi
  801236:	5d                   	pop    %ebp
  801237:	c3                   	ret    
  801238:	39 d6                	cmp    %edx,%esi
  80123a:	75 d9                	jne    801215 <__umoddi3+0xf5>
  80123c:	2b 45 e8             	sub    -0x18(%ebp),%eax
  80123f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  801242:	eb d1                	jmp    801215 <__umoddi3+0xf5>
  801244:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801248:	39 f2                	cmp    %esi,%edx
  80124a:	0f 82 18 ff ff ff    	jb     801168 <__umoddi3+0x48>
  801250:	e9 1d ff ff ff       	jmp    801172 <__umoddi3+0x52>
