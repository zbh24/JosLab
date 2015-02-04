
obj/user/faultregs：     文件格式 elf32-i386


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
  80002c:	e8 71 05 00 00       	call   8005a2 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>
  800033:	66 90                	xchg   %ax,%ax
  800035:	66 90                	xchg   %ax,%ax
  800037:	66 90                	xchg   %ax,%ax
  800039:	66 90                	xchg   %ax,%ax
  80003b:	66 90                	xchg   %ax,%ax
  80003d:	66 90                	xchg   %ax,%ax
  80003f:	90                   	nop

00800040 <check_regs>:
static struct regs before, during, after;

static void
check_regs(struct regs* a, const char *an, struct regs* b, const char *bn,
	   const char *testname)
{
  800040:	55                   	push   %ebp
  800041:	89 e5                	mov    %esp,%ebp
  800043:	57                   	push   %edi
  800044:	56                   	push   %esi
  800045:	53                   	push   %ebx
  800046:	83 ec 1c             	sub    $0x1c,%esp
  800049:	89 c3                	mov    %eax,%ebx
  80004b:	89 ce                	mov    %ecx,%esi
	int mismatch = 0;

	cprintf("%-6s %-8s %-8s\n", "", an, bn);
  80004d:	8b 45 08             	mov    0x8(%ebp),%eax
  800050:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800054:	89 54 24 08          	mov    %edx,0x8(%esp)
  800058:	c7 44 24 04 31 18 80 	movl   $0x801831,0x4(%esp)
  80005f:	00 
  800060:	c7 04 24 00 18 80 00 	movl   $0x801800,(%esp)
  800067:	e8 5a 06 00 00       	call   8006c6 <cprintf>
			cprintf("MISMATCH\n");				\
			mismatch = 1;					\
		}							\
	} while (0)

	CHECK(edi, regs.reg_edi);
  80006c:	8b 06                	mov    (%esi),%eax
  80006e:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800072:	8b 03                	mov    (%ebx),%eax
  800074:	89 44 24 08          	mov    %eax,0x8(%esp)
  800078:	c7 44 24 04 10 18 80 	movl   $0x801810,0x4(%esp)
  80007f:	00 
  800080:	c7 04 24 14 18 80 00 	movl   $0x801814,(%esp)
  800087:	e8 3a 06 00 00       	call   8006c6 <cprintf>
  80008c:	8b 03                	mov    (%ebx),%eax
  80008e:	3b 06                	cmp    (%esi),%eax
  800090:	75 13                	jne    8000a5 <check_regs+0x65>
  800092:	c7 04 24 24 18 80 00 	movl   $0x801824,(%esp)
  800099:	e8 28 06 00 00       	call   8006c6 <cprintf>
  80009e:	bf 00 00 00 00       	mov    $0x0,%edi
  8000a3:	eb 11                	jmp    8000b6 <check_regs+0x76>
  8000a5:	c7 04 24 28 18 80 00 	movl   $0x801828,(%esp)
  8000ac:	e8 15 06 00 00       	call   8006c6 <cprintf>
  8000b1:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esi, regs.reg_esi);
  8000b6:	8b 46 04             	mov    0x4(%esi),%eax
  8000b9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000bd:	8b 43 04             	mov    0x4(%ebx),%eax
  8000c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8000c4:	c7 44 24 04 32 18 80 	movl   $0x801832,0x4(%esp)
  8000cb:	00 
  8000cc:	c7 04 24 14 18 80 00 	movl   $0x801814,(%esp)
  8000d3:	e8 ee 05 00 00       	call   8006c6 <cprintf>
  8000d8:	8b 43 04             	mov    0x4(%ebx),%eax
  8000db:	3b 46 04             	cmp    0x4(%esi),%eax
  8000de:	75 0e                	jne    8000ee <check_regs+0xae>
  8000e0:	c7 04 24 24 18 80 00 	movl   $0x801824,(%esp)
  8000e7:	e8 da 05 00 00       	call   8006c6 <cprintf>
  8000ec:	eb 11                	jmp    8000ff <check_regs+0xbf>
  8000ee:	c7 04 24 28 18 80 00 	movl   $0x801828,(%esp)
  8000f5:	e8 cc 05 00 00       	call   8006c6 <cprintf>
  8000fa:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebp, regs.reg_ebp);
  8000ff:	8b 46 08             	mov    0x8(%esi),%eax
  800102:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800106:	8b 43 08             	mov    0x8(%ebx),%eax
  800109:	89 44 24 08          	mov    %eax,0x8(%esp)
  80010d:	c7 44 24 04 36 18 80 	movl   $0x801836,0x4(%esp)
  800114:	00 
  800115:	c7 04 24 14 18 80 00 	movl   $0x801814,(%esp)
  80011c:	e8 a5 05 00 00       	call   8006c6 <cprintf>
  800121:	8b 43 08             	mov    0x8(%ebx),%eax
  800124:	3b 46 08             	cmp    0x8(%esi),%eax
  800127:	75 0e                	jne    800137 <check_regs+0xf7>
  800129:	c7 04 24 24 18 80 00 	movl   $0x801824,(%esp)
  800130:	e8 91 05 00 00       	call   8006c6 <cprintf>
  800135:	eb 11                	jmp    800148 <check_regs+0x108>
  800137:	c7 04 24 28 18 80 00 	movl   $0x801828,(%esp)
  80013e:	e8 83 05 00 00       	call   8006c6 <cprintf>
  800143:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ebx, regs.reg_ebx);
  800148:	8b 46 10             	mov    0x10(%esi),%eax
  80014b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80014f:	8b 43 10             	mov    0x10(%ebx),%eax
  800152:	89 44 24 08          	mov    %eax,0x8(%esp)
  800156:	c7 44 24 04 3a 18 80 	movl   $0x80183a,0x4(%esp)
  80015d:	00 
  80015e:	c7 04 24 14 18 80 00 	movl   $0x801814,(%esp)
  800165:	e8 5c 05 00 00       	call   8006c6 <cprintf>
  80016a:	8b 43 10             	mov    0x10(%ebx),%eax
  80016d:	3b 46 10             	cmp    0x10(%esi),%eax
  800170:	75 0e                	jne    800180 <check_regs+0x140>
  800172:	c7 04 24 24 18 80 00 	movl   $0x801824,(%esp)
  800179:	e8 48 05 00 00       	call   8006c6 <cprintf>
  80017e:	eb 11                	jmp    800191 <check_regs+0x151>
  800180:	c7 04 24 28 18 80 00 	movl   $0x801828,(%esp)
  800187:	e8 3a 05 00 00       	call   8006c6 <cprintf>
  80018c:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(edx, regs.reg_edx);
  800191:	8b 46 14             	mov    0x14(%esi),%eax
  800194:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800198:	8b 43 14             	mov    0x14(%ebx),%eax
  80019b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80019f:	c7 44 24 04 3e 18 80 	movl   $0x80183e,0x4(%esp)
  8001a6:	00 
  8001a7:	c7 04 24 14 18 80 00 	movl   $0x801814,(%esp)
  8001ae:	e8 13 05 00 00       	call   8006c6 <cprintf>
  8001b3:	8b 43 14             	mov    0x14(%ebx),%eax
  8001b6:	3b 46 14             	cmp    0x14(%esi),%eax
  8001b9:	75 0e                	jne    8001c9 <check_regs+0x189>
  8001bb:	c7 04 24 24 18 80 00 	movl   $0x801824,(%esp)
  8001c2:	e8 ff 04 00 00       	call   8006c6 <cprintf>
  8001c7:	eb 11                	jmp    8001da <check_regs+0x19a>
  8001c9:	c7 04 24 28 18 80 00 	movl   $0x801828,(%esp)
  8001d0:	e8 f1 04 00 00       	call   8006c6 <cprintf>
  8001d5:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(ecx, regs.reg_ecx);
  8001da:	8b 46 18             	mov    0x18(%esi),%eax
  8001dd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8001e1:	8b 43 18             	mov    0x18(%ebx),%eax
  8001e4:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001e8:	c7 44 24 04 42 18 80 	movl   $0x801842,0x4(%esp)
  8001ef:	00 
  8001f0:	c7 04 24 14 18 80 00 	movl   $0x801814,(%esp)
  8001f7:	e8 ca 04 00 00       	call   8006c6 <cprintf>
  8001fc:	8b 43 18             	mov    0x18(%ebx),%eax
  8001ff:	3b 46 18             	cmp    0x18(%esi),%eax
  800202:	75 0e                	jne    800212 <check_regs+0x1d2>
  800204:	c7 04 24 24 18 80 00 	movl   $0x801824,(%esp)
  80020b:	e8 b6 04 00 00       	call   8006c6 <cprintf>
  800210:	eb 11                	jmp    800223 <check_regs+0x1e3>
  800212:	c7 04 24 28 18 80 00 	movl   $0x801828,(%esp)
  800219:	e8 a8 04 00 00       	call   8006c6 <cprintf>
  80021e:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eax, regs.reg_eax);
  800223:	8b 46 1c             	mov    0x1c(%esi),%eax
  800226:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80022a:	8b 43 1c             	mov    0x1c(%ebx),%eax
  80022d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800231:	c7 44 24 04 46 18 80 	movl   $0x801846,0x4(%esp)
  800238:	00 
  800239:	c7 04 24 14 18 80 00 	movl   $0x801814,(%esp)
  800240:	e8 81 04 00 00       	call   8006c6 <cprintf>
  800245:	8b 43 1c             	mov    0x1c(%ebx),%eax
  800248:	3b 46 1c             	cmp    0x1c(%esi),%eax
  80024b:	75 0e                	jne    80025b <check_regs+0x21b>
  80024d:	c7 04 24 24 18 80 00 	movl   $0x801824,(%esp)
  800254:	e8 6d 04 00 00       	call   8006c6 <cprintf>
  800259:	eb 11                	jmp    80026c <check_regs+0x22c>
  80025b:	c7 04 24 28 18 80 00 	movl   $0x801828,(%esp)
  800262:	e8 5f 04 00 00       	call   8006c6 <cprintf>
  800267:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eip, eip);
  80026c:	8b 46 20             	mov    0x20(%esi),%eax
  80026f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800273:	8b 43 20             	mov    0x20(%ebx),%eax
  800276:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027a:	c7 44 24 04 4a 18 80 	movl   $0x80184a,0x4(%esp)
  800281:	00 
  800282:	c7 04 24 14 18 80 00 	movl   $0x801814,(%esp)
  800289:	e8 38 04 00 00       	call   8006c6 <cprintf>
  80028e:	8b 43 20             	mov    0x20(%ebx),%eax
  800291:	3b 46 20             	cmp    0x20(%esi),%eax
  800294:	75 0e                	jne    8002a4 <check_regs+0x264>
  800296:	c7 04 24 24 18 80 00 	movl   $0x801824,(%esp)
  80029d:	e8 24 04 00 00       	call   8006c6 <cprintf>
  8002a2:	eb 11                	jmp    8002b5 <check_regs+0x275>
  8002a4:	c7 04 24 28 18 80 00 	movl   $0x801828,(%esp)
  8002ab:	e8 16 04 00 00       	call   8006c6 <cprintf>
  8002b0:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(eflags, eflags);
  8002b5:	8b 46 24             	mov    0x24(%esi),%eax
  8002b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8002bc:	8b 43 24             	mov    0x24(%ebx),%eax
  8002bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c3:	c7 44 24 04 4e 18 80 	movl   $0x80184e,0x4(%esp)
  8002ca:	00 
  8002cb:	c7 04 24 14 18 80 00 	movl   $0x801814,(%esp)
  8002d2:	e8 ef 03 00 00       	call   8006c6 <cprintf>
  8002d7:	8b 43 24             	mov    0x24(%ebx),%eax
  8002da:	3b 46 24             	cmp    0x24(%esi),%eax
  8002dd:	75 0e                	jne    8002ed <check_regs+0x2ad>
  8002df:	c7 04 24 24 18 80 00 	movl   $0x801824,(%esp)
  8002e6:	e8 db 03 00 00       	call   8006c6 <cprintf>
  8002eb:	eb 11                	jmp    8002fe <check_regs+0x2be>
  8002ed:	c7 04 24 28 18 80 00 	movl   $0x801828,(%esp)
  8002f4:	e8 cd 03 00 00       	call   8006c6 <cprintf>
  8002f9:	bf 01 00 00 00       	mov    $0x1,%edi
	CHECK(esp, esp);
  8002fe:	8b 46 28             	mov    0x28(%esi),%eax
  800301:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800305:	8b 43 28             	mov    0x28(%ebx),%eax
  800308:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030c:	c7 44 24 04 55 18 80 	movl   $0x801855,0x4(%esp)
  800313:	00 
  800314:	c7 04 24 14 18 80 00 	movl   $0x801814,(%esp)
  80031b:	e8 a6 03 00 00       	call   8006c6 <cprintf>
  800320:	8b 43 28             	mov    0x28(%ebx),%eax
  800323:	3b 46 28             	cmp    0x28(%esi),%eax
  800326:	75 25                	jne    80034d <check_regs+0x30d>
  800328:	c7 04 24 24 18 80 00 	movl   $0x801824,(%esp)
  80032f:	e8 92 03 00 00       	call   8006c6 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800334:	8b 45 0c             	mov    0xc(%ebp),%eax
  800337:	89 44 24 04          	mov    %eax,0x4(%esp)
  80033b:	c7 04 24 59 18 80 00 	movl   $0x801859,(%esp)
  800342:	e8 7f 03 00 00       	call   8006c6 <cprintf>
	if (!mismatch)
  800347:	85 ff                	test   %edi,%edi
  800349:	74 23                	je     80036e <check_regs+0x32e>
  80034b:	eb 2f                	jmp    80037c <check_regs+0x33c>
	CHECK(edx, regs.reg_edx);
	CHECK(ecx, regs.reg_ecx);
	CHECK(eax, regs.reg_eax);
	CHECK(eip, eip);
	CHECK(eflags, eflags);
	CHECK(esp, esp);
  80034d:	c7 04 24 28 18 80 00 	movl   $0x801828,(%esp)
  800354:	e8 6d 03 00 00       	call   8006c6 <cprintf>

#undef CHECK

	cprintf("Registers %s ", testname);
  800359:	8b 45 0c             	mov    0xc(%ebp),%eax
  80035c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800360:	c7 04 24 59 18 80 00 	movl   $0x801859,(%esp)
  800367:	e8 5a 03 00 00       	call   8006c6 <cprintf>
  80036c:	eb 0e                	jmp    80037c <check_regs+0x33c>
	if (!mismatch)
		cprintf("OK\n");
  80036e:	c7 04 24 24 18 80 00 	movl   $0x801824,(%esp)
  800375:	e8 4c 03 00 00       	call   8006c6 <cprintf>
  80037a:	eb 0c                	jmp    800388 <check_regs+0x348>
	else
		cprintf("MISMATCH\n");
  80037c:	c7 04 24 28 18 80 00 	movl   $0x801828,(%esp)
  800383:	e8 3e 03 00 00       	call   8006c6 <cprintf>
}
  800388:	83 c4 1c             	add    $0x1c,%esp
  80038b:	5b                   	pop    %ebx
  80038c:	5e                   	pop    %esi
  80038d:	5f                   	pop    %edi
  80038e:	5d                   	pop    %ebp
  80038f:	c3                   	ret    

00800390 <umain>:
		panic("sys_page_alloc: %e", r);
}

void
umain(int argc, char **argv)
{
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	83 ec 18             	sub    $0x18,%esp
	set_pgfault_handler(pgfault);
  800396:	c7 04 24 a1 04 80 00 	movl   $0x8004a1,(%esp)
  80039d:	e8 a0 11 00 00       	call   801542 <set_pgfault_handler>

	__asm __volatile(
  8003a2:	50                   	push   %eax
  8003a3:	9c                   	pushf  
  8003a4:	58                   	pop    %eax
  8003a5:	0d d5 08 00 00       	or     $0x8d5,%eax
  8003aa:	50                   	push   %eax
  8003ab:	9d                   	popf   
  8003ac:	a3 44 20 80 00       	mov    %eax,0x802044
  8003b1:	8d 05 ec 03 80 00    	lea    0x8003ec,%eax
  8003b7:	a3 40 20 80 00       	mov    %eax,0x802040
  8003bc:	58                   	pop    %eax
  8003bd:	89 3d 20 20 80 00    	mov    %edi,0x802020
  8003c3:	89 35 24 20 80 00    	mov    %esi,0x802024
  8003c9:	89 2d 28 20 80 00    	mov    %ebp,0x802028
  8003cf:	89 1d 30 20 80 00    	mov    %ebx,0x802030
  8003d5:	89 15 34 20 80 00    	mov    %edx,0x802034
  8003db:	89 0d 38 20 80 00    	mov    %ecx,0x802038
  8003e1:	a3 3c 20 80 00       	mov    %eax,0x80203c
  8003e6:	89 25 48 20 80 00    	mov    %esp,0x802048
  8003ec:	c7 05 00 00 40 00 2a 	movl   $0x2a,0x400000
  8003f3:	00 00 00 
  8003f6:	89 3d a0 20 80 00    	mov    %edi,0x8020a0
  8003fc:	89 35 a4 20 80 00    	mov    %esi,0x8020a4
  800402:	89 2d a8 20 80 00    	mov    %ebp,0x8020a8
  800408:	89 1d b0 20 80 00    	mov    %ebx,0x8020b0
  80040e:	89 15 b4 20 80 00    	mov    %edx,0x8020b4
  800414:	89 0d b8 20 80 00    	mov    %ecx,0x8020b8
  80041a:	a3 bc 20 80 00       	mov    %eax,0x8020bc
  80041f:	89 25 c8 20 80 00    	mov    %esp,0x8020c8
  800425:	8b 3d 20 20 80 00    	mov    0x802020,%edi
  80042b:	8b 35 24 20 80 00    	mov    0x802024,%esi
  800431:	8b 2d 28 20 80 00    	mov    0x802028,%ebp
  800437:	8b 1d 30 20 80 00    	mov    0x802030,%ebx
  80043d:	8b 15 34 20 80 00    	mov    0x802034,%edx
  800443:	8b 0d 38 20 80 00    	mov    0x802038,%ecx
  800449:	a1 3c 20 80 00       	mov    0x80203c,%eax
  80044e:	8b 25 48 20 80 00    	mov    0x802048,%esp
  800454:	50                   	push   %eax
  800455:	9c                   	pushf  
  800456:	58                   	pop    %eax
  800457:	a3 c4 20 80 00       	mov    %eax,0x8020c4
  80045c:	58                   	pop    %eax
		: : "m" (before), "m" (after) : "memory", "cc");

	// Check UTEMP to roughly determine that EIP was restored
	// correctly (of course, we probably wouldn't get this far if
	// it weren't)
	if (*(int*)UTEMP != 42)
  80045d:	83 3d 00 00 40 00 2a 	cmpl   $0x2a,0x400000
  800464:	74 0c                	je     800472 <umain+0xe2>
		cprintf("EIP after page-fault MISMATCH\n");
  800466:	c7 04 24 c0 18 80 00 	movl   $0x8018c0,(%esp)
  80046d:	e8 54 02 00 00       	call   8006c6 <cprintf>
	after.eip = before.eip;
  800472:	a1 40 20 80 00       	mov    0x802040,%eax
  800477:	a3 c0 20 80 00       	mov    %eax,0x8020c0

	check_regs(&before, "before", &after, "after", "after page-fault");
  80047c:	c7 44 24 04 6e 18 80 	movl   $0x80186e,0x4(%esp)
  800483:	00 
  800484:	c7 04 24 7f 18 80 00 	movl   $0x80187f,(%esp)
  80048b:	b9 a0 20 80 00       	mov    $0x8020a0,%ecx
  800490:	ba 67 18 80 00       	mov    $0x801867,%edx
  800495:	b8 20 20 80 00       	mov    $0x802020,%eax
  80049a:	e8 a1 fb ff ff       	call   800040 <check_regs>
}
  80049f:	c9                   	leave  
  8004a0:	c3                   	ret    

008004a1 <pgfault>:
		cprintf("MISMATCH\n");
}

static void
pgfault(struct UTrapframe *utf)
{
  8004a1:	55                   	push   %ebp
  8004a2:	89 e5                	mov    %esp,%ebp
  8004a4:	83 ec 28             	sub    $0x28,%esp
  8004a7:	8b 45 08             	mov    0x8(%ebp),%eax
	int r;

	if (utf->utf_fault_va != (uint32_t)UTEMP)
  8004aa:	8b 10                	mov    (%eax),%edx
  8004ac:	81 fa 00 00 40 00    	cmp    $0x400000,%edx
  8004b2:	74 27                	je     8004db <pgfault+0x3a>
		panic("pgfault expected at UTEMP, got 0x%08x (eip %08x)",
  8004b4:	8b 40 28             	mov    0x28(%eax),%eax
  8004b7:	89 44 24 10          	mov    %eax,0x10(%esp)
  8004bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8004bf:	c7 44 24 08 e0 18 80 	movl   $0x8018e0,0x8(%esp)
  8004c6:	00 
  8004c7:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
  8004ce:	00 
  8004cf:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  8004d6:	e8 34 01 00 00       	call   80060f <_panic>
		      utf->utf_fault_va, utf->utf_eip);

	// Check registers in UTrapframe
	during.regs = utf->utf_regs;
  8004db:	8b 50 08             	mov    0x8(%eax),%edx
  8004de:	89 15 60 20 80 00    	mov    %edx,0x802060
  8004e4:	8b 50 0c             	mov    0xc(%eax),%edx
  8004e7:	89 15 64 20 80 00    	mov    %edx,0x802064
  8004ed:	8b 50 10             	mov    0x10(%eax),%edx
  8004f0:	89 15 68 20 80 00    	mov    %edx,0x802068
  8004f6:	8b 50 14             	mov    0x14(%eax),%edx
  8004f9:	89 15 6c 20 80 00    	mov    %edx,0x80206c
  8004ff:	8b 50 18             	mov    0x18(%eax),%edx
  800502:	89 15 70 20 80 00    	mov    %edx,0x802070
  800508:	8b 50 1c             	mov    0x1c(%eax),%edx
  80050b:	89 15 74 20 80 00    	mov    %edx,0x802074
  800511:	8b 50 20             	mov    0x20(%eax),%edx
  800514:	89 15 78 20 80 00    	mov    %edx,0x802078
  80051a:	8b 50 24             	mov    0x24(%eax),%edx
  80051d:	89 15 7c 20 80 00    	mov    %edx,0x80207c
	during.eip = utf->utf_eip;
  800523:	8b 50 28             	mov    0x28(%eax),%edx
  800526:	89 15 80 20 80 00    	mov    %edx,0x802080
	during.eflags = utf->utf_eflags;
  80052c:	8b 50 2c             	mov    0x2c(%eax),%edx
  80052f:	89 15 84 20 80 00    	mov    %edx,0x802084
	during.esp = utf->utf_esp;
  800535:	8b 40 30             	mov    0x30(%eax),%eax
  800538:	a3 88 20 80 00       	mov    %eax,0x802088
	check_regs(&before, "before", &during, "during", "in UTrapframe");
  80053d:	c7 44 24 04 96 18 80 	movl   $0x801896,0x4(%esp)
  800544:	00 
  800545:	c7 04 24 a4 18 80 00 	movl   $0x8018a4,(%esp)
  80054c:	b9 60 20 80 00       	mov    $0x802060,%ecx
  800551:	ba 67 18 80 00       	mov    $0x801867,%edx
  800556:	b8 20 20 80 00       	mov    $0x802020,%eax
  80055b:	e8 e0 fa ff ff       	call   800040 <check_regs>

	// Map UTEMP so the write succeeds
	if ((r = sys_page_alloc(0, UTEMP, PTE_U|PTE_P|PTE_W)) < 0)
  800560:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  800567:	00 
  800568:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
  80056f:	00 
  800570:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800577:	e8 a2 0e 00 00       	call   80141e <sys_page_alloc>
  80057c:	85 c0                	test   %eax,%eax
  80057e:	79 20                	jns    8005a0 <pgfault+0xff>
		panic("sys_page_alloc: %e", r);
  800580:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800584:	c7 44 24 08 ab 18 80 	movl   $0x8018ab,0x8(%esp)
  80058b:	00 
  80058c:	c7 44 24 04 5c 00 00 	movl   $0x5c,0x4(%esp)
  800593:	00 
  800594:	c7 04 24 85 18 80 00 	movl   $0x801885,(%esp)
  80059b:	e8 6f 00 00 00       	call   80060f <_panic>
}
  8005a0:	c9                   	leave  
  8005a1:	c3                   	ret    

008005a2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8005a2:	55                   	push   %ebp
  8005a3:	89 e5                	mov    %esp,%ebp
  8005a5:	83 ec 18             	sub    $0x18,%esp
  8005a8:	89 5d f8             	mov    %ebx,-0x8(%ebp)
  8005ab:	89 75 fc             	mov    %esi,-0x4(%ebp)
  8005ae:	8b 75 08             	mov    0x8(%ebp),%esi
  8005b1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	thisenv = 0;
  8005b4:	c7 05 cc 20 80 00 00 	movl   $0x0,0x8020cc
  8005bb:	00 00 00 
	thisenv = &envs[ENVX(sys_getenvid())];
  8005be:	e8 ee 0e 00 00       	call   8014b1 <sys_getenvid>
  8005c3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8005c8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8005cb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8005d0:	a3 cc 20 80 00       	mov    %eax,0x8020cc
	// save the name of the program so that panic() can use it
	if (argc > 0)
  8005d5:	85 f6                	test   %esi,%esi
  8005d7:	7e 07                	jle    8005e0 <libmain+0x3e>
		binaryname = argv[0];
  8005d9:	8b 03                	mov    (%ebx),%eax
  8005db:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  8005e0:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  8005e4:	89 34 24             	mov    %esi,(%esp)
  8005e7:	e8 a4 fd ff ff       	call   800390 <umain>

	// exit gracefully
	exit();
  8005ec:	e8 0a 00 00 00       	call   8005fb <exit>
}
  8005f1:	8b 5d f8             	mov    -0x8(%ebp),%ebx
  8005f4:	8b 75 fc             	mov    -0x4(%ebp),%esi
  8005f7:	89 ec                	mov    %ebp,%esp
  8005f9:	5d                   	pop    %ebp
  8005fa:	c3                   	ret    

008005fb <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8005fb:	55                   	push   %ebp
  8005fc:	89 e5                	mov    %esp,%ebp
  8005fe:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800601:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800608:	e8 d8 0e 00 00       	call   8014e5 <sys_env_destroy>
}
  80060d:	c9                   	leave  
  80060e:	c3                   	ret    

0080060f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80060f:	55                   	push   %ebp
  800610:	89 e5                	mov    %esp,%ebp
  800612:	56                   	push   %esi
  800613:	53                   	push   %ebx
  800614:	83 ec 20             	sub    $0x20,%esp
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
  800617:	8d 75 14             	lea    0x14(%ebp),%esi
	va_list ap;

	va_start(ap, fmt);

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80061a:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800620:	e8 8c 0e 00 00       	call   8014b1 <sys_getenvid>
  800625:	8b 55 0c             	mov    0xc(%ebp),%edx
  800628:	89 54 24 10          	mov    %edx,0x10(%esp)
  80062c:	8b 55 08             	mov    0x8(%ebp),%edx
  80062f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800633:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800637:	89 44 24 04          	mov    %eax,0x4(%esp)
  80063b:	c7 04 24 1c 19 80 00 	movl   $0x80191c,(%esp)
  800642:	e8 7f 00 00 00       	call   8006c6 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800647:	89 74 24 04          	mov    %esi,0x4(%esp)
  80064b:	8b 45 10             	mov    0x10(%ebp),%eax
  80064e:	89 04 24             	mov    %eax,(%esp)
  800651:	e8 0f 00 00 00       	call   800665 <vcprintf>
	cprintf("\n");
  800656:	c7 04 24 30 18 80 00 	movl   $0x801830,(%esp)
  80065d:	e8 64 00 00 00       	call   8006c6 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800662:	cc                   	int3   
  800663:	eb fd                	jmp    800662 <_panic+0x53>

00800665 <vcprintf>:
	b->cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
  800665:	55                   	push   %ebp
  800666:	89 e5                	mov    %esp,%ebp
  800668:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  80066e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800675:	00 00 00 
	b.cnt = 0;
  800678:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80067f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800682:	8b 45 0c             	mov    0xc(%ebp),%eax
  800685:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800689:	8b 45 08             	mov    0x8(%ebp),%eax
  80068c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800690:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800696:	89 44 24 04          	mov    %eax,0x4(%esp)
  80069a:	c7 04 24 e0 06 80 00 	movl   $0x8006e0,(%esp)
  8006a1:	e8 d7 01 00 00       	call   80087d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8006a6:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8006ac:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006b0:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8006b6:	89 04 24             	mov    %eax,(%esp)
  8006b9:	e8 20 0b 00 00       	call   8011de <sys_cputs>

	return b.cnt;
}
  8006be:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8006c4:	c9                   	leave  
  8006c5:	c3                   	ret    

008006c6 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8006c6:	55                   	push   %ebp
  8006c7:	89 e5                	mov    %esp,%ebp
  8006c9:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
cprintf(const char *fmt, ...)
  8006cc:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
  8006cf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d6:	89 04 24             	mov    %eax,(%esp)
  8006d9:	e8 87 ff ff ff       	call   800665 <vcprintf>
	va_end(ap);

	return cnt;
}
  8006de:	c9                   	leave  
  8006df:	c3                   	ret    

008006e0 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	53                   	push   %ebx
  8006e4:	83 ec 14             	sub    $0x14,%esp
  8006e7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8006ea:	8b 03                	mov    (%ebx),%eax
  8006ec:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ef:	88 54 03 08          	mov    %dl,0x8(%ebx,%eax,1)
  8006f3:	83 c0 01             	add    $0x1,%eax
  8006f6:	89 03                	mov    %eax,(%ebx)
	if (b->idx == 256-1) {
  8006f8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8006fd:	75 19                	jne    800718 <putch+0x38>
		sys_cputs(b->buf, b->idx);
  8006ff:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
  800706:	00 
  800707:	8d 43 08             	lea    0x8(%ebx),%eax
  80070a:	89 04 24             	mov    %eax,(%esp)
  80070d:	e8 cc 0a 00 00       	call   8011de <sys_cputs>
		b->idx = 0;
  800712:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
	}
	b->cnt++;
  800718:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80071c:	83 c4 14             	add    $0x14,%esp
  80071f:	5b                   	pop    %ebx
  800720:	5d                   	pop    %ebp
  800721:	c3                   	ret    
  800722:	66 90                	xchg   %ax,%ax
  800724:	66 90                	xchg   %ax,%ax
  800726:	66 90                	xchg   %ax,%ax
  800728:	66 90                	xchg   %ax,%ax
  80072a:	66 90                	xchg   %ax,%ax
  80072c:	66 90                	xchg   %ax,%ax
  80072e:	66 90                	xchg   %ax,%ax

00800730 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800730:	55                   	push   %ebp
  800731:	89 e5                	mov    %esp,%ebp
  800733:	57                   	push   %edi
  800734:	56                   	push   %esi
  800735:	53                   	push   %ebx
  800736:	83 ec 4c             	sub    $0x4c,%esp
  800739:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80073c:	89 d6                	mov    %edx,%esi
  80073e:	8b 45 08             	mov    0x8(%ebp),%eax
  800741:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800744:	8b 55 0c             	mov    0xc(%ebp),%edx
  800747:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80074a:	8b 45 10             	mov    0x10(%ebp),%eax
  80074d:	8b 5d 14             	mov    0x14(%ebp),%ebx
  800750:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800753:	89 45 dc             	mov    %eax,-0x24(%ebp)
  800756:	b9 00 00 00 00       	mov    $0x0,%ecx
  80075b:	39 d1                	cmp    %edx,%ecx
  80075d:	72 15                	jb     800774 <printnum+0x44>
  80075f:	77 07                	ja     800768 <printnum+0x38>
  800761:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800764:	39 d0                	cmp    %edx,%eax
  800766:	76 0c                	jbe    800774 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800768:	83 eb 01             	sub    $0x1,%ebx
  80076b:	85 db                	test   %ebx,%ebx
  80076d:	8d 76 00             	lea    0x0(%esi),%esi
  800770:	7f 61                	jg     8007d3 <printnum+0xa3>
  800772:	eb 70                	jmp    8007e4 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800774:	89 7c 24 10          	mov    %edi,0x10(%esp)
  800778:	83 eb 01             	sub    $0x1,%ebx
  80077b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80077f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800783:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  800787:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
  80078b:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  80078e:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
  800791:	8b 5d dc             	mov    -0x24(%ebp),%ebx
  800794:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800798:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80079f:	00 
  8007a0:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8007a3:	89 04 24             	mov    %eax,(%esp)
  8007a6:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007a9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007ad:	e8 ce 0d 00 00       	call   801580 <__udivdi3>
  8007b2:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8007b5:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  8007b8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8007bc:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8007c0:	89 04 24             	mov    %eax,(%esp)
  8007c3:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007c7:	89 f2                	mov    %esi,%edx
  8007c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8007cc:	e8 5f ff ff ff       	call   800730 <printnum>
  8007d1:	eb 11                	jmp    8007e4 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8007d3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007d7:	89 3c 24             	mov    %edi,(%esp)
  8007da:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8007dd:	83 eb 01             	sub    $0x1,%ebx
  8007e0:	85 db                	test   %ebx,%ebx
  8007e2:	7f ef                	jg     8007d3 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8007e4:	89 74 24 04          	mov    %esi,0x4(%esp)
  8007e8:	8b 74 24 04          	mov    0x4(%esp),%esi
  8007ec:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8007ef:	89 44 24 08          	mov    %eax,0x8(%esp)
  8007f3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8007fa:	00 
  8007fb:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007fe:	89 14 24             	mov    %edx,(%esp)
  800801:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800804:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800808:	e8 a3 0e 00 00       	call   8016b0 <__umoddi3>
  80080d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800811:	0f be 80 3f 19 80 00 	movsbl 0x80193f(%eax),%eax
  800818:	89 04 24             	mov    %eax,(%esp)
  80081b:	ff 55 e4             	call   *-0x1c(%ebp)
}
  80081e:	83 c4 4c             	add    $0x4c,%esp
  800821:	5b                   	pop    %ebx
  800822:	5e                   	pop    %esi
  800823:	5f                   	pop    %edi
  800824:	5d                   	pop    %ebp
  800825:	c3                   	ret    

00800826 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800826:	55                   	push   %ebp
  800827:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800829:	83 fa 01             	cmp    $0x1,%edx
  80082c:	7e 0e                	jle    80083c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  80082e:	8b 10                	mov    (%eax),%edx
  800830:	8d 4a 08             	lea    0x8(%edx),%ecx
  800833:	89 08                	mov    %ecx,(%eax)
  800835:	8b 02                	mov    (%edx),%eax
  800837:	8b 52 04             	mov    0x4(%edx),%edx
  80083a:	eb 22                	jmp    80085e <getuint+0x38>
	else if (lflag)
  80083c:	85 d2                	test   %edx,%edx
  80083e:	74 10                	je     800850 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  800840:	8b 10                	mov    (%eax),%edx
  800842:	8d 4a 04             	lea    0x4(%edx),%ecx
  800845:	89 08                	mov    %ecx,(%eax)
  800847:	8b 02                	mov    (%edx),%eax
  800849:	ba 00 00 00 00       	mov    $0x0,%edx
  80084e:	eb 0e                	jmp    80085e <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  800850:	8b 10                	mov    (%eax),%edx
  800852:	8d 4a 04             	lea    0x4(%edx),%ecx
  800855:	89 08                	mov    %ecx,(%eax)
  800857:	8b 02                	mov    (%edx),%eax
  800859:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80085e:	5d                   	pop    %ebp
  80085f:	c3                   	ret    

00800860 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800866:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80086a:	8b 10                	mov    (%eax),%edx
  80086c:	3b 50 04             	cmp    0x4(%eax),%edx
  80086f:	73 0a                	jae    80087b <sprintputch+0x1b>
		*b->buf++ = ch;
  800871:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800874:	88 0a                	mov    %cl,(%edx)
  800876:	83 c2 01             	add    $0x1,%edx
  800879:	89 10                	mov    %edx,(%eax)
}
  80087b:	5d                   	pop    %ebp
  80087c:	c3                   	ret    

0080087d <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80087d:	55                   	push   %ebp
  80087e:	89 e5                	mov    %esp,%ebp
  800880:	57                   	push   %edi
  800881:	56                   	push   %esi
  800882:	53                   	push   %ebx
  800883:	83 ec 5c             	sub    $0x5c,%esp
  800886:	8b 7d 08             	mov    0x8(%ebp),%edi
  800889:	8b 75 0c             	mov    0xc(%ebp),%esi
  80088c:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
  80088f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800896:	eb 11                	jmp    8008a9 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800898:	85 c0                	test   %eax,%eax
  80089a:	0f 84 16 04 00 00    	je     800cb6 <vprintfmt+0x439>
				return;
			putch(ch, putdat);
  8008a0:	89 74 24 04          	mov    %esi,0x4(%esp)
  8008a4:	89 04 24             	mov    %eax,(%esp)
  8008a7:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8008a9:	0f b6 03             	movzbl (%ebx),%eax
  8008ac:	83 c3 01             	add    $0x1,%ebx
  8008af:	83 f8 25             	cmp    $0x25,%eax
  8008b2:	75 e4                	jne    800898 <vprintfmt+0x1b>
  8008b4:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
  8008bb:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
  8008c2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8008c7:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
  8008cb:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
  8008d2:	eb 06                	jmp    8008da <vprintfmt+0x5d>
  8008d4:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
  8008d8:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008da:	0f b6 13             	movzbl (%ebx),%edx
  8008dd:	0f b6 c2             	movzbl %dl,%eax
  8008e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008e3:	8d 43 01             	lea    0x1(%ebx),%eax
  8008e6:	83 ea 23             	sub    $0x23,%edx
  8008e9:	80 fa 55             	cmp    $0x55,%dl
  8008ec:	0f 87 a7 03 00 00    	ja     800c99 <vprintfmt+0x41c>
  8008f2:	0f b6 d2             	movzbl %dl,%edx
  8008f5:	ff 24 95 00 1a 80 00 	jmp    *0x801a00(,%edx,4)
  8008fc:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
  800900:	eb d6                	jmp    8008d8 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  800902:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800905:	83 ea 30             	sub    $0x30,%edx
  800908:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
  80090b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  80090e:	8d 5a d0             	lea    -0x30(%edx),%ebx
  800911:	83 fb 09             	cmp    $0x9,%ebx
  800914:	77 54                	ja     80096a <vprintfmt+0xed>
  800916:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800919:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80091c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
  80091f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
  800922:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
  800926:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
  800929:	8d 5a d0             	lea    -0x30(%edx),%ebx
  80092c:	83 fb 09             	cmp    $0x9,%ebx
  80092f:	76 eb                	jbe    80091c <vprintfmt+0x9f>
  800931:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  800934:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800937:	eb 31                	jmp    80096a <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  800939:	8b 55 14             	mov    0x14(%ebp),%edx
  80093c:	8d 5a 04             	lea    0x4(%edx),%ebx
  80093f:	89 5d 14             	mov    %ebx,0x14(%ebp)
  800942:	8b 12                	mov    (%edx),%edx
  800944:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
  800947:	eb 21                	jmp    80096a <vprintfmt+0xed>

		case '.':
			if (width < 0)
  800949:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80094d:	ba 00 00 00 00       	mov    $0x0,%edx
  800952:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
  800956:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800959:	e9 7a ff ff ff       	jmp    8008d8 <vprintfmt+0x5b>
  80095e:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
  800965:	e9 6e ff ff ff       	jmp    8008d8 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
  80096a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80096e:	0f 89 64 ff ff ff    	jns    8008d8 <vprintfmt+0x5b>
  800974:	8b 55 cc             	mov    -0x34(%ebp),%edx
  800977:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80097a:	8b 55 c8             	mov    -0x38(%ebp),%edx
  80097d:	89 55 cc             	mov    %edx,-0x34(%ebp)
  800980:	e9 53 ff ff ff       	jmp    8008d8 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800985:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
  800988:	e9 4b ff ff ff       	jmp    8008d8 <vprintfmt+0x5b>
  80098d:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800990:	8b 45 14             	mov    0x14(%ebp),%eax
  800993:	8d 50 04             	lea    0x4(%eax),%edx
  800996:	89 55 14             	mov    %edx,0x14(%ebp)
  800999:	89 74 24 04          	mov    %esi,0x4(%esp)
  80099d:	8b 00                	mov    (%eax),%eax
  80099f:	89 04 24             	mov    %eax,(%esp)
  8009a2:	ff d7                	call   *%edi
  8009a4:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  8009a7:	e9 fd fe ff ff       	jmp    8008a9 <vprintfmt+0x2c>
  8009ac:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
  8009af:	8b 45 14             	mov    0x14(%ebp),%eax
  8009b2:	8d 50 04             	lea    0x4(%eax),%edx
  8009b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8009b8:	8b 00                	mov    (%eax),%eax
  8009ba:	89 c2                	mov    %eax,%edx
  8009bc:	c1 fa 1f             	sar    $0x1f,%edx
  8009bf:	31 d0                	xor    %edx,%eax
  8009c1:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009c3:	83 f8 08             	cmp    $0x8,%eax
  8009c6:	7f 0b                	jg     8009d3 <vprintfmt+0x156>
  8009c8:	8b 14 85 60 1b 80 00 	mov    0x801b60(,%eax,4),%edx
  8009cf:	85 d2                	test   %edx,%edx
  8009d1:	75 20                	jne    8009f3 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
  8009d3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8009d7:	c7 44 24 08 50 19 80 	movl   $0x801950,0x8(%esp)
  8009de:	00 
  8009df:	89 74 24 04          	mov    %esi,0x4(%esp)
  8009e3:	89 3c 24             	mov    %edi,(%esp)
  8009e6:	e8 53 03 00 00       	call   800d3e <printfmt>
  8009eb:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8009ee:	e9 b6 fe ff ff       	jmp    8008a9 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  8009f3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009f7:	c7 44 24 08 59 19 80 	movl   $0x801959,0x8(%esp)
  8009fe:	00 
  8009ff:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a03:	89 3c 24             	mov    %edi,(%esp)
  800a06:	e8 33 03 00 00       	call   800d3e <printfmt>
  800a0b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800a0e:	e9 96 fe ff ff       	jmp    8008a9 <vprintfmt+0x2c>
  800a13:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a16:	89 c3                	mov    %eax,%ebx
  800a18:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  800a1b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800a1e:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800a21:	8b 45 14             	mov    0x14(%ebp),%eax
  800a24:	8d 50 04             	lea    0x4(%eax),%edx
  800a27:	89 55 14             	mov    %edx,0x14(%ebp)
  800a2a:	8b 00                	mov    (%eax),%eax
  800a2c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
  800a2f:	85 c0                	test   %eax,%eax
  800a31:	b8 5c 19 80 00       	mov    $0x80195c,%eax
  800a36:	0f 45 45 c4          	cmovne -0x3c(%ebp),%eax
  800a3a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
  800a3d:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
  800a41:	7e 06                	jle    800a49 <vprintfmt+0x1cc>
  800a43:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
  800a47:	75 13                	jne    800a5c <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800a49:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800a4c:	0f be 02             	movsbl (%edx),%eax
  800a4f:	85 c0                	test   %eax,%eax
  800a51:	0f 85 9b 00 00 00    	jne    800af2 <vprintfmt+0x275>
  800a57:	e9 88 00 00 00       	jmp    800ae4 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a5c:	89 4c 24 04          	mov    %ecx,0x4(%esp)
  800a60:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
  800a63:	89 0c 24             	mov    %ecx,(%esp)
  800a66:	e8 20 03 00 00       	call   800d8b <strnlen>
  800a6b:	8b 55 c0             	mov    -0x40(%ebp),%edx
  800a6e:	29 c2                	sub    %eax,%edx
  800a70:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a73:	85 d2                	test   %edx,%edx
  800a75:	7e d2                	jle    800a49 <vprintfmt+0x1cc>
					putch(padc, putdat);
  800a77:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
  800a7b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800a7e:	89 5d c0             	mov    %ebx,-0x40(%ebp)
  800a81:	89 d3                	mov    %edx,%ebx
  800a83:	89 74 24 04          	mov    %esi,0x4(%esp)
  800a87:	8b 45 dc             	mov    -0x24(%ebp),%eax
  800a8a:	89 04 24             	mov    %eax,(%esp)
  800a8d:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  800a8f:	83 eb 01             	sub    $0x1,%ebx
  800a92:	85 db                	test   %ebx,%ebx
  800a94:	7f ed                	jg     800a83 <vprintfmt+0x206>
  800a96:	8b 5d c0             	mov    -0x40(%ebp),%ebx
  800a99:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800aa0:	eb a7                	jmp    800a49 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800aa2:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
  800aa6:	74 1a                	je     800ac2 <vprintfmt+0x245>
  800aa8:	8d 50 e0             	lea    -0x20(%eax),%edx
  800aab:	83 fa 5e             	cmp    $0x5e,%edx
  800aae:	76 12                	jbe    800ac2 <vprintfmt+0x245>
					putch('?', putdat);
  800ab0:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ab4:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800abb:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800abe:	66 90                	xchg   %ax,%ax
  800ac0:	eb 0a                	jmp    800acc <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
  800ac2:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800ac6:	89 04 24             	mov    %eax,(%esp)
  800ac9:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800acc:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800ad0:	0f be 03             	movsbl (%ebx),%eax
  800ad3:	85 c0                	test   %eax,%eax
  800ad5:	74 05                	je     800adc <vprintfmt+0x25f>
  800ad7:	83 c3 01             	add    $0x1,%ebx
  800ada:	eb 29                	jmp    800b05 <vprintfmt+0x288>
  800adc:	89 fe                	mov    %edi,%esi
  800ade:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800ae1:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800ae4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ae8:	7f 2e                	jg     800b18 <vprintfmt+0x29b>
  800aea:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800aed:	e9 b7 fd ff ff       	jmp    8008a9 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800af2:	8b 55 c4             	mov    -0x3c(%ebp),%edx
  800af5:	83 c2 01             	add    $0x1,%edx
  800af8:	89 7d dc             	mov    %edi,-0x24(%ebp)
  800afb:	89 f7                	mov    %esi,%edi
  800afd:	8b 75 cc             	mov    -0x34(%ebp),%esi
  800b00:	89 5d cc             	mov    %ebx,-0x34(%ebp)
  800b03:	89 d3                	mov    %edx,%ebx
  800b05:	85 f6                	test   %esi,%esi
  800b07:	78 99                	js     800aa2 <vprintfmt+0x225>
  800b09:	83 ee 01             	sub    $0x1,%esi
  800b0c:	79 94                	jns    800aa2 <vprintfmt+0x225>
  800b0e:	89 fe                	mov    %edi,%esi
  800b10:	8b 7d dc             	mov    -0x24(%ebp),%edi
  800b13:	8b 5d cc             	mov    -0x34(%ebp),%ebx
  800b16:	eb cc                	jmp    800ae4 <vprintfmt+0x267>
  800b18:	89 5d d0             	mov    %ebx,-0x30(%ebp)
  800b1b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800b1e:	89 74 24 04          	mov    %esi,0x4(%esp)
  800b22:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800b29:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800b2b:	83 eb 01             	sub    $0x1,%ebx
  800b2e:	85 db                	test   %ebx,%ebx
  800b30:	7f ec                	jg     800b1e <vprintfmt+0x2a1>
  800b32:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  800b35:	e9 6f fd ff ff       	jmp    8008a9 <vprintfmt+0x2c>
  800b3a:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800b3d:	83 f9 01             	cmp    $0x1,%ecx
  800b40:	7e 16                	jle    800b58 <vprintfmt+0x2db>
		return va_arg(*ap, long long);
  800b42:	8b 45 14             	mov    0x14(%ebp),%eax
  800b45:	8d 50 08             	lea    0x8(%eax),%edx
  800b48:	89 55 14             	mov    %edx,0x14(%ebp)
  800b4b:	8b 10                	mov    (%eax),%edx
  800b4d:	8b 48 04             	mov    0x4(%eax),%ecx
  800b50:	89 55 d0             	mov    %edx,-0x30(%ebp)
  800b53:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800b56:	eb 32                	jmp    800b8a <vprintfmt+0x30d>
	else if (lflag)
  800b58:	85 c9                	test   %ecx,%ecx
  800b5a:	74 18                	je     800b74 <vprintfmt+0x2f7>
		return va_arg(*ap, long);
  800b5c:	8b 45 14             	mov    0x14(%ebp),%eax
  800b5f:	8d 50 04             	lea    0x4(%eax),%edx
  800b62:	89 55 14             	mov    %edx,0x14(%ebp)
  800b65:	8b 00                	mov    (%eax),%eax
  800b67:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800b6a:	89 c1                	mov    %eax,%ecx
  800b6c:	c1 f9 1f             	sar    $0x1f,%ecx
  800b6f:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
  800b72:	eb 16                	jmp    800b8a <vprintfmt+0x30d>
	else
		return va_arg(*ap, int);
  800b74:	8b 45 14             	mov    0x14(%ebp),%eax
  800b77:	8d 50 04             	lea    0x4(%eax),%edx
  800b7a:	89 55 14             	mov    %edx,0x14(%ebp)
  800b7d:	8b 00                	mov    (%eax),%eax
  800b7f:	89 45 d0             	mov    %eax,-0x30(%ebp)
  800b82:	89 c2                	mov    %eax,%edx
  800b84:	c1 fa 1f             	sar    $0x1f,%edx
  800b87:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800b8a:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800b8d:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800b90:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
  800b95:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800b99:	0f 89 b8 00 00 00    	jns    800c57 <vprintfmt+0x3da>
				putch('-', putdat);
  800b9f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800ba3:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800baa:	ff d7                	call   *%edi
				num = -(long long) num;
  800bac:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  800baf:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
  800bb2:	f7 d9                	neg    %ecx
  800bb4:	83 d3 00             	adc    $0x0,%ebx
  800bb7:	f7 db                	neg    %ebx
  800bb9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bbe:	e9 94 00 00 00       	jmp    800c57 <vprintfmt+0x3da>
  800bc3:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800bc6:	89 ca                	mov    %ecx,%edx
  800bc8:	8d 45 14             	lea    0x14(%ebp),%eax
  800bcb:	e8 56 fc ff ff       	call   800826 <getuint>
  800bd0:	89 c1                	mov    %eax,%ecx
  800bd2:	89 d3                	mov    %edx,%ebx
  800bd4:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
  800bd9:	eb 7c                	jmp    800c57 <vprintfmt+0x3da>
  800bdb:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
  800bde:	89 74 24 04          	mov    %esi,0x4(%esp)
  800be2:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800be9:	ff d7                	call   *%edi
			putch('X', putdat);
  800beb:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bef:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800bf6:	ff d7                	call   *%edi
			putch('X', putdat);
  800bf8:	89 74 24 04          	mov    %esi,0x4(%esp)
  800bfc:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
  800c03:	ff d7                	call   *%edi
  800c05:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800c08:	e9 9c fc ff ff       	jmp    8008a9 <vprintfmt+0x2c>
  800c0d:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
  800c10:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c14:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800c1b:	ff d7                	call   *%edi
			putch('x', putdat);
  800c1d:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c21:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800c28:	ff d7                	call   *%edi
			num = (unsigned long long)
  800c2a:	8b 45 14             	mov    0x14(%ebp),%eax
  800c2d:	8d 50 04             	lea    0x4(%eax),%edx
  800c30:	89 55 14             	mov    %edx,0x14(%ebp)
  800c33:	8b 08                	mov    (%eax),%ecx
  800c35:	bb 00 00 00 00       	mov    $0x0,%ebx
  800c3a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800c3f:	eb 16                	jmp    800c57 <vprintfmt+0x3da>
  800c41:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800c44:	89 ca                	mov    %ecx,%edx
  800c46:	8d 45 14             	lea    0x14(%ebp),%eax
  800c49:	e8 d8 fb ff ff       	call   800826 <getuint>
  800c4e:	89 c1                	mov    %eax,%ecx
  800c50:	89 d3                	mov    %edx,%ebx
  800c52:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
  800c57:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
  800c5b:	89 54 24 10          	mov    %edx,0x10(%esp)
  800c5f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800c62:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800c66:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c6a:	89 0c 24             	mov    %ecx,(%esp)
  800c6d:	89 5c 24 04          	mov    %ebx,0x4(%esp)
  800c71:	89 f2                	mov    %esi,%edx
  800c73:	89 f8                	mov    %edi,%eax
  800c75:	e8 b6 fa ff ff       	call   800730 <printnum>
  800c7a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800c7d:	e9 27 fc ff ff       	jmp    8008a9 <vprintfmt+0x2c>
  800c82:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800c85:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800c88:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c8c:	89 14 24             	mov    %edx,(%esp)
  800c8f:	ff d7                	call   *%edi
  800c91:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
  800c94:	e9 10 fc ff ff       	jmp    8008a9 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800c99:	89 74 24 04          	mov    %esi,0x4(%esp)
  800c9d:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ca4:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ca6:	8d 43 ff             	lea    -0x1(%ebx),%eax
  800ca9:	80 38 25             	cmpb   $0x25,(%eax)
  800cac:	0f 84 f7 fb ff ff    	je     8008a9 <vprintfmt+0x2c>
  800cb2:	89 c3                	mov    %eax,%ebx
  800cb4:	eb f0                	jmp    800ca6 <vprintfmt+0x429>
				/* do nothing */;
			break;
		}
	}
}
  800cb6:	83 c4 5c             	add    $0x5c,%esp
  800cb9:	5b                   	pop    %ebx
  800cba:	5e                   	pop    %esi
  800cbb:	5f                   	pop    %edi
  800cbc:	5d                   	pop    %ebp
  800cbd:	c3                   	ret    

00800cbe <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800cbe:	55                   	push   %ebp
  800cbf:	89 e5                	mov    %esp,%ebp
  800cc1:	83 ec 28             	sub    $0x28,%esp
  800cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
  800cca:	85 c0                	test   %eax,%eax
  800ccc:	74 04                	je     800cd2 <vsnprintf+0x14>
  800cce:	85 d2                	test   %edx,%edx
  800cd0:	7f 07                	jg     800cd9 <vsnprintf+0x1b>
  800cd2:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800cd7:	eb 3b                	jmp    800d14 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
  800cd9:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800cdc:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
  800ce0:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800ce3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cea:	8b 45 14             	mov    0x14(%ebp),%eax
  800ced:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800cf1:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800cf8:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cfb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cff:	c7 04 24 60 08 80 00 	movl   $0x800860,(%esp)
  800d06:	e8 72 fb ff ff       	call   80087d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800d0b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800d0e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800d11:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800d14:	c9                   	leave  
  800d15:	c3                   	ret    

00800d16 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800d16:	55                   	push   %ebp
  800d17:	89 e5                	mov    %esp,%ebp
  800d19:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
  800d1c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
  800d1f:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d23:	8b 45 10             	mov    0x10(%ebp),%eax
  800d26:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d31:	8b 45 08             	mov    0x8(%ebp),%eax
  800d34:	89 04 24             	mov    %eax,(%esp)
  800d37:	e8 82 ff ff ff       	call   800cbe <vsnprintf>
	va_end(ap);

	return rc;
}
  800d3c:	c9                   	leave  
  800d3d:	c3                   	ret    

00800d3e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
  800d41:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
  800d44:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
  800d47:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d4b:	8b 45 10             	mov    0x10(%ebp),%eax
  800d4e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800d52:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d55:	89 44 24 04          	mov    %eax,0x4(%esp)
  800d59:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5c:	89 04 24             	mov    %eax,(%esp)
  800d5f:	e8 19 fb ff ff       	call   80087d <vprintfmt>
	va_end(ap);
}
  800d64:	c9                   	leave  
  800d65:	c3                   	ret    
  800d66:	66 90                	xchg   %ax,%ax
  800d68:	66 90                	xchg   %ax,%ax
  800d6a:	66 90                	xchg   %ax,%ax
  800d6c:	66 90                	xchg   %ax,%ax
  800d6e:	66 90                	xchg   %ax,%ax

00800d70 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d76:	b8 00 00 00 00       	mov    $0x0,%eax
  800d7b:	80 3a 00             	cmpb   $0x0,(%edx)
  800d7e:	74 09                	je     800d89 <strlen+0x19>
		n++;
  800d80:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800d83:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d87:	75 f7                	jne    800d80 <strlen+0x10>
		n++;
	return n;
}
  800d89:	5d                   	pop    %ebp
  800d8a:	c3                   	ret    

00800d8b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d8b:	55                   	push   %ebp
  800d8c:	89 e5                	mov    %esp,%ebp
  800d8e:	53                   	push   %ebx
  800d8f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800d92:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d95:	85 c9                	test   %ecx,%ecx
  800d97:	74 19                	je     800db2 <strnlen+0x27>
  800d99:	80 3b 00             	cmpb   $0x0,(%ebx)
  800d9c:	74 14                	je     800db2 <strnlen+0x27>
  800d9e:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
  800da3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800da6:	39 c8                	cmp    %ecx,%eax
  800da8:	74 0d                	je     800db7 <strnlen+0x2c>
  800daa:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
  800dae:	75 f3                	jne    800da3 <strnlen+0x18>
  800db0:	eb 05                	jmp    800db7 <strnlen+0x2c>
  800db2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
  800db7:	5b                   	pop    %ebx
  800db8:	5d                   	pop    %ebp
  800db9:	c3                   	ret    

00800dba <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800dba:	55                   	push   %ebp
  800dbb:	89 e5                	mov    %esp,%ebp
  800dbd:	53                   	push   %ebx
  800dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dc4:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800dc9:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
  800dcd:	88 0c 10             	mov    %cl,(%eax,%edx,1)
  800dd0:	83 c2 01             	add    $0x1,%edx
  800dd3:	84 c9                	test   %cl,%cl
  800dd5:	75 f2                	jne    800dc9 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
  800dd7:	5b                   	pop    %ebx
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <strcat>:

char *
strcat(char *dst, const char *src)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	53                   	push   %ebx
  800dde:	83 ec 08             	sub    $0x8,%esp
  800de1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800de4:	89 1c 24             	mov    %ebx,(%esp)
  800de7:	e8 84 ff ff ff       	call   800d70 <strlen>
	strcpy(dst + len, src);
  800dec:	8b 55 0c             	mov    0xc(%ebp),%edx
  800def:	89 54 24 04          	mov    %edx,0x4(%esp)
  800df3:	8d 04 03             	lea    (%ebx,%eax,1),%eax
  800df6:	89 04 24             	mov    %eax,(%esp)
  800df9:	e8 bc ff ff ff       	call   800dba <strcpy>
	return dst;
}
  800dfe:	89 d8                	mov    %ebx,%eax
  800e00:	83 c4 08             	add    $0x8,%esp
  800e03:	5b                   	pop    %ebx
  800e04:	5d                   	pop    %ebp
  800e05:	c3                   	ret    

00800e06 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	56                   	push   %esi
  800e0a:	53                   	push   %ebx
  800e0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e11:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e14:	85 f6                	test   %esi,%esi
  800e16:	74 18                	je     800e30 <strncpy+0x2a>
  800e18:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
  800e1d:	0f b6 1a             	movzbl (%edx),%ebx
  800e20:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800e23:	80 3a 01             	cmpb   $0x1,(%edx)
  800e26:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800e29:	83 c1 01             	add    $0x1,%ecx
  800e2c:	39 ce                	cmp    %ecx,%esi
  800e2e:	77 ed                	ja     800e1d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800e30:	5b                   	pop    %ebx
  800e31:	5e                   	pop    %esi
  800e32:	5d                   	pop    %ebp
  800e33:	c3                   	ret    

00800e34 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	56                   	push   %esi
  800e38:	53                   	push   %ebx
  800e39:	8b 75 08             	mov    0x8(%ebp),%esi
  800e3c:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e3f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800e42:	89 f0                	mov    %esi,%eax
  800e44:	85 c9                	test   %ecx,%ecx
  800e46:	74 27                	je     800e6f <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
  800e48:	83 e9 01             	sub    $0x1,%ecx
  800e4b:	74 1d                	je     800e6a <strlcpy+0x36>
  800e4d:	0f b6 1a             	movzbl (%edx),%ebx
  800e50:	84 db                	test   %bl,%bl
  800e52:	74 16                	je     800e6a <strlcpy+0x36>
			*dst++ = *src++;
  800e54:	88 18                	mov    %bl,(%eax)
  800e56:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e59:	83 e9 01             	sub    $0x1,%ecx
  800e5c:	74 0e                	je     800e6c <strlcpy+0x38>
			*dst++ = *src++;
  800e5e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800e61:	0f b6 1a             	movzbl (%edx),%ebx
  800e64:	84 db                	test   %bl,%bl
  800e66:	75 ec                	jne    800e54 <strlcpy+0x20>
  800e68:	eb 02                	jmp    800e6c <strlcpy+0x38>
  800e6a:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
  800e6c:	c6 00 00             	movb   $0x0,(%eax)
  800e6f:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
  800e71:	5b                   	pop    %ebx
  800e72:	5e                   	pop    %esi
  800e73:	5d                   	pop    %ebp
  800e74:	c3                   	ret    

00800e75 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e75:	55                   	push   %ebp
  800e76:	89 e5                	mov    %esp,%ebp
  800e78:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e7b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e7e:	0f b6 01             	movzbl (%ecx),%eax
  800e81:	84 c0                	test   %al,%al
  800e83:	74 15                	je     800e9a <strcmp+0x25>
  800e85:	3a 02                	cmp    (%edx),%al
  800e87:	75 11                	jne    800e9a <strcmp+0x25>
		p++, q++;
  800e89:	83 c1 01             	add    $0x1,%ecx
  800e8c:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800e8f:	0f b6 01             	movzbl (%ecx),%eax
  800e92:	84 c0                	test   %al,%al
  800e94:	74 04                	je     800e9a <strcmp+0x25>
  800e96:	3a 02                	cmp    (%edx),%al
  800e98:	74 ef                	je     800e89 <strcmp+0x14>
  800e9a:	0f b6 c0             	movzbl %al,%eax
  800e9d:	0f b6 12             	movzbl (%edx),%edx
  800ea0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800ea2:	5d                   	pop    %ebp
  800ea3:	c3                   	ret    

00800ea4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800ea4:	55                   	push   %ebp
  800ea5:	89 e5                	mov    %esp,%ebp
  800ea7:	53                   	push   %ebx
  800ea8:	8b 55 08             	mov    0x8(%ebp),%edx
  800eab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800eae:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
  800eb1:	85 c0                	test   %eax,%eax
  800eb3:	74 23                	je     800ed8 <strncmp+0x34>
  800eb5:	0f b6 1a             	movzbl (%edx),%ebx
  800eb8:	84 db                	test   %bl,%bl
  800eba:	74 25                	je     800ee1 <strncmp+0x3d>
  800ebc:	3a 19                	cmp    (%ecx),%bl
  800ebe:	75 21                	jne    800ee1 <strncmp+0x3d>
  800ec0:	83 e8 01             	sub    $0x1,%eax
  800ec3:	74 13                	je     800ed8 <strncmp+0x34>
		n--, p++, q++;
  800ec5:	83 c2 01             	add    $0x1,%edx
  800ec8:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800ecb:	0f b6 1a             	movzbl (%edx),%ebx
  800ece:	84 db                	test   %bl,%bl
  800ed0:	74 0f                	je     800ee1 <strncmp+0x3d>
  800ed2:	3a 19                	cmp    (%ecx),%bl
  800ed4:	74 ea                	je     800ec0 <strncmp+0x1c>
  800ed6:	eb 09                	jmp    800ee1 <strncmp+0x3d>
  800ed8:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800edd:	5b                   	pop    %ebx
  800ede:	5d                   	pop    %ebp
  800edf:	90                   	nop
  800ee0:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800ee1:	0f b6 02             	movzbl (%edx),%eax
  800ee4:	0f b6 11             	movzbl (%ecx),%edx
  800ee7:	29 d0                	sub    %edx,%eax
  800ee9:	eb f2                	jmp    800edd <strncmp+0x39>

00800eeb <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800eeb:	55                   	push   %ebp
  800eec:	89 e5                	mov    %esp,%ebp
  800eee:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ef5:	0f b6 10             	movzbl (%eax),%edx
  800ef8:	84 d2                	test   %dl,%dl
  800efa:	74 18                	je     800f14 <strchr+0x29>
		if (*s == c)
  800efc:	38 ca                	cmp    %cl,%dl
  800efe:	75 0a                	jne    800f0a <strchr+0x1f>
  800f00:	eb 17                	jmp    800f19 <strchr+0x2e>
  800f02:	38 ca                	cmp    %cl,%dl
  800f04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f08:	74 0f                	je     800f19 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800f0a:	83 c0 01             	add    $0x1,%eax
  800f0d:	0f b6 10             	movzbl (%eax),%edx
  800f10:	84 d2                	test   %dl,%dl
  800f12:	75 ee                	jne    800f02 <strchr+0x17>
  800f14:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
  800f19:	5d                   	pop    %ebp
  800f1a:	c3                   	ret    

00800f1b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800f1b:	55                   	push   %ebp
  800f1c:	89 e5                	mov    %esp,%ebp
  800f1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f21:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800f25:	0f b6 10             	movzbl (%eax),%edx
  800f28:	84 d2                	test   %dl,%dl
  800f2a:	74 18                	je     800f44 <strfind+0x29>
		if (*s == c)
  800f2c:	38 ca                	cmp    %cl,%dl
  800f2e:	75 0a                	jne    800f3a <strfind+0x1f>
  800f30:	eb 12                	jmp    800f44 <strfind+0x29>
  800f32:	38 ca                	cmp    %cl,%dl
  800f34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800f38:	74 0a                	je     800f44 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800f3a:	83 c0 01             	add    $0x1,%eax
  800f3d:	0f b6 10             	movzbl (%eax),%edx
  800f40:	84 d2                	test   %dl,%dl
  800f42:	75 ee                	jne    800f32 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    

00800f46 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800f46:	55                   	push   %ebp
  800f47:	89 e5                	mov    %esp,%ebp
  800f49:	83 ec 0c             	sub    $0xc,%esp
  800f4c:	89 1c 24             	mov    %ebx,(%esp)
  800f4f:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f53:	89 7c 24 08          	mov    %edi,0x8(%esp)
  800f57:	8b 7d 08             	mov    0x8(%ebp),%edi
  800f5a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f5d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800f60:	85 c9                	test   %ecx,%ecx
  800f62:	74 30                	je     800f94 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f64:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800f6a:	75 25                	jne    800f91 <memset+0x4b>
  800f6c:	f6 c1 03             	test   $0x3,%cl
  800f6f:	75 20                	jne    800f91 <memset+0x4b>
		c &= 0xFF;
  800f71:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800f74:	89 d3                	mov    %edx,%ebx
  800f76:	c1 e3 08             	shl    $0x8,%ebx
  800f79:	89 d6                	mov    %edx,%esi
  800f7b:	c1 e6 18             	shl    $0x18,%esi
  800f7e:	89 d0                	mov    %edx,%eax
  800f80:	c1 e0 10             	shl    $0x10,%eax
  800f83:	09 f0                	or     %esi,%eax
  800f85:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
  800f87:	09 d8                	or     %ebx,%eax
  800f89:	c1 e9 02             	shr    $0x2,%ecx
  800f8c:	fc                   	cld    
  800f8d:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800f8f:	eb 03                	jmp    800f94 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800f91:	fc                   	cld    
  800f92:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800f94:	89 f8                	mov    %edi,%eax
  800f96:	8b 1c 24             	mov    (%esp),%ebx
  800f99:	8b 74 24 04          	mov    0x4(%esp),%esi
  800f9d:	8b 7c 24 08          	mov    0x8(%esp),%edi
  800fa1:	89 ec                	mov    %ebp,%esp
  800fa3:	5d                   	pop    %ebp
  800fa4:	c3                   	ret    

00800fa5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800fa5:	55                   	push   %ebp
  800fa6:	89 e5                	mov    %esp,%ebp
  800fa8:	83 ec 08             	sub    $0x8,%esp
  800fab:	89 34 24             	mov    %esi,(%esp)
  800fae:	89 7c 24 04          	mov    %edi,0x4(%esp)
  800fb2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
  800fb8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
  800fbb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
  800fbd:	39 c6                	cmp    %eax,%esi
  800fbf:	73 35                	jae    800ff6 <memmove+0x51>
  800fc1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800fc4:	39 d0                	cmp    %edx,%eax
  800fc6:	73 2e                	jae    800ff6 <memmove+0x51>
		s += n;
		d += n;
  800fc8:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fca:	f6 c2 03             	test   $0x3,%dl
  800fcd:	75 1b                	jne    800fea <memmove+0x45>
  800fcf:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800fd5:	75 13                	jne    800fea <memmove+0x45>
  800fd7:	f6 c1 03             	test   $0x3,%cl
  800fda:	75 0e                	jne    800fea <memmove+0x45>
			asm volatile("std; rep movsl\n"
  800fdc:	83 ef 04             	sub    $0x4,%edi
  800fdf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800fe2:	c1 e9 02             	shr    $0x2,%ecx
  800fe5:	fd                   	std    
  800fe6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800fe8:	eb 09                	jmp    800ff3 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800fea:	83 ef 01             	sub    $0x1,%edi
  800fed:	8d 72 ff             	lea    -0x1(%edx),%esi
  800ff0:	fd                   	std    
  800ff1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800ff3:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ff4:	eb 20                	jmp    801016 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ff6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ffc:	75 15                	jne    801013 <memmove+0x6e>
  800ffe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801004:	75 0d                	jne    801013 <memmove+0x6e>
  801006:	f6 c1 03             	test   $0x3,%cl
  801009:	75 08                	jne    801013 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
  80100b:	c1 e9 02             	shr    $0x2,%ecx
  80100e:	fc                   	cld    
  80100f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801011:	eb 03                	jmp    801016 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  801013:	fc                   	cld    
  801014:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  801016:	8b 34 24             	mov    (%esp),%esi
  801019:	8b 7c 24 04          	mov    0x4(%esp),%edi
  80101d:	89 ec                	mov    %ebp,%esp
  80101f:	5d                   	pop    %ebp
  801020:	c3                   	ret    

00801021 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  801021:	55                   	push   %ebp
  801022:	89 e5                	mov    %esp,%ebp
  801024:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  801027:	8b 45 10             	mov    0x10(%ebp),%eax
  80102a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80102e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801031:	89 44 24 04          	mov    %eax,0x4(%esp)
  801035:	8b 45 08             	mov    0x8(%ebp),%eax
  801038:	89 04 24             	mov    %eax,(%esp)
  80103b:	e8 65 ff ff ff       	call   800fa5 <memmove>
}
  801040:	c9                   	leave  
  801041:	c3                   	ret    

00801042 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801042:	55                   	push   %ebp
  801043:	89 e5                	mov    %esp,%ebp
  801045:	57                   	push   %edi
  801046:	56                   	push   %esi
  801047:	53                   	push   %ebx
  801048:	8b 75 08             	mov    0x8(%ebp),%esi
  80104b:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80104e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801051:	85 c9                	test   %ecx,%ecx
  801053:	74 36                	je     80108b <memcmp+0x49>
		if (*s1 != *s2)
  801055:	0f b6 06             	movzbl (%esi),%eax
  801058:	0f b6 1f             	movzbl (%edi),%ebx
  80105b:	38 d8                	cmp    %bl,%al
  80105d:	74 20                	je     80107f <memcmp+0x3d>
  80105f:	eb 14                	jmp    801075 <memcmp+0x33>
  801061:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
  801066:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
  80106b:	83 c2 01             	add    $0x1,%edx
  80106e:	83 e9 01             	sub    $0x1,%ecx
  801071:	38 d8                	cmp    %bl,%al
  801073:	74 12                	je     801087 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
  801075:	0f b6 c0             	movzbl %al,%eax
  801078:	0f b6 db             	movzbl %bl,%ebx
  80107b:	29 d8                	sub    %ebx,%eax
  80107d:	eb 11                	jmp    801090 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80107f:	83 e9 01             	sub    $0x1,%ecx
  801082:	ba 00 00 00 00       	mov    $0x0,%edx
  801087:	85 c9                	test   %ecx,%ecx
  801089:	75 d6                	jne    801061 <memcmp+0x1f>
  80108b:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
  801090:	5b                   	pop    %ebx
  801091:	5e                   	pop    %esi
  801092:	5f                   	pop    %edi
  801093:	5d                   	pop    %ebp
  801094:	c3                   	ret    

00801095 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80109b:	89 c2                	mov    %eax,%edx
  80109d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8010a0:	39 d0                	cmp    %edx,%eax
  8010a2:	73 15                	jae    8010b9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
  8010a4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  8010a8:	38 08                	cmp    %cl,(%eax)
  8010aa:	75 06                	jne    8010b2 <memfind+0x1d>
  8010ac:	eb 0b                	jmp    8010b9 <memfind+0x24>
  8010ae:	38 08                	cmp    %cl,(%eax)
  8010b0:	74 07                	je     8010b9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  8010b2:	83 c0 01             	add    $0x1,%eax
  8010b5:	39 c2                	cmp    %eax,%edx
  8010b7:	77 f5                	ja     8010ae <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  8010b9:	5d                   	pop    %ebp
  8010ba:	c3                   	ret    

008010bb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8010bb:	55                   	push   %ebp
  8010bc:	89 e5                	mov    %esp,%ebp
  8010be:	57                   	push   %edi
  8010bf:	56                   	push   %esi
  8010c0:	53                   	push   %ebx
  8010c1:	83 ec 04             	sub    $0x4,%esp
  8010c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8010c7:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010ca:	0f b6 02             	movzbl (%edx),%eax
  8010cd:	3c 20                	cmp    $0x20,%al
  8010cf:	74 04                	je     8010d5 <strtol+0x1a>
  8010d1:	3c 09                	cmp    $0x9,%al
  8010d3:	75 0e                	jne    8010e3 <strtol+0x28>
		s++;
  8010d5:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8010d8:	0f b6 02             	movzbl (%edx),%eax
  8010db:	3c 20                	cmp    $0x20,%al
  8010dd:	74 f6                	je     8010d5 <strtol+0x1a>
  8010df:	3c 09                	cmp    $0x9,%al
  8010e1:	74 f2                	je     8010d5 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
  8010e3:	3c 2b                	cmp    $0x2b,%al
  8010e5:	75 0c                	jne    8010f3 <strtol+0x38>
		s++;
  8010e7:	83 c2 01             	add    $0x1,%edx
  8010ea:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8010f1:	eb 15                	jmp    801108 <strtol+0x4d>
	else if (*s == '-')
  8010f3:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  8010fa:	3c 2d                	cmp    $0x2d,%al
  8010fc:	75 0a                	jne    801108 <strtol+0x4d>
		s++, neg = 1;
  8010fe:	83 c2 01             	add    $0x1,%edx
  801101:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801108:	85 db                	test   %ebx,%ebx
  80110a:	0f 94 c0             	sete   %al
  80110d:	74 05                	je     801114 <strtol+0x59>
  80110f:	83 fb 10             	cmp    $0x10,%ebx
  801112:	75 18                	jne    80112c <strtol+0x71>
  801114:	80 3a 30             	cmpb   $0x30,(%edx)
  801117:	75 13                	jne    80112c <strtol+0x71>
  801119:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
  80111d:	8d 76 00             	lea    0x0(%esi),%esi
  801120:	75 0a                	jne    80112c <strtol+0x71>
		s += 2, base = 16;
  801122:	83 c2 02             	add    $0x2,%edx
  801125:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80112a:	eb 15                	jmp    801141 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  80112c:	84 c0                	test   %al,%al
  80112e:	66 90                	xchg   %ax,%ax
  801130:	74 0f                	je     801141 <strtol+0x86>
  801132:	bb 0a 00 00 00       	mov    $0xa,%ebx
  801137:	80 3a 30             	cmpb   $0x30,(%edx)
  80113a:	75 05                	jne    801141 <strtol+0x86>
		s++, base = 8;
  80113c:	83 c2 01             	add    $0x1,%edx
  80113f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801141:	b8 00 00 00 00       	mov    $0x0,%eax
  801146:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801148:	0f b6 0a             	movzbl (%edx),%ecx
  80114b:	89 cf                	mov    %ecx,%edi
  80114d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
  801150:	80 fb 09             	cmp    $0x9,%bl
  801153:	77 08                	ja     80115d <strtol+0xa2>
			dig = *s - '0';
  801155:	0f be c9             	movsbl %cl,%ecx
  801158:	83 e9 30             	sub    $0x30,%ecx
  80115b:	eb 1e                	jmp    80117b <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
  80115d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
  801160:	80 fb 19             	cmp    $0x19,%bl
  801163:	77 08                	ja     80116d <strtol+0xb2>
			dig = *s - 'a' + 10;
  801165:	0f be c9             	movsbl %cl,%ecx
  801168:	83 e9 57             	sub    $0x57,%ecx
  80116b:	eb 0e                	jmp    80117b <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
  80116d:	8d 5f bf             	lea    -0x41(%edi),%ebx
  801170:	80 fb 19             	cmp    $0x19,%bl
  801173:	77 15                	ja     80118a <strtol+0xcf>
			dig = *s - 'A' + 10;
  801175:	0f be c9             	movsbl %cl,%ecx
  801178:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
  80117b:	39 f1                	cmp    %esi,%ecx
  80117d:	7d 0b                	jge    80118a <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
  80117f:	83 c2 01             	add    $0x1,%edx
  801182:	0f af c6             	imul   %esi,%eax
  801185:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
  801188:	eb be                	jmp    801148 <strtol+0x8d>
  80118a:	89 c1                	mov    %eax,%ecx

	if (endptr)
  80118c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801190:	74 05                	je     801197 <strtol+0xdc>
		*endptr = (char *) s;
  801192:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801195:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
  801197:	89 ca                	mov    %ecx,%edx
  801199:	f7 da                	neg    %edx
  80119b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  80119f:	0f 45 c2             	cmovne %edx,%eax
}
  8011a2:	83 c4 04             	add    $0x4,%esp
  8011a5:	5b                   	pop    %ebx
  8011a6:	5e                   	pop    %esi
  8011a7:	5f                   	pop    %edi
  8011a8:	5d                   	pop    %ebp
  8011a9:	c3                   	ret    

008011aa <sys_cgetc>:
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}

int
sys_cgetc(void)
{
  8011aa:	55                   	push   %ebp
  8011ab:	89 e5                	mov    %esp,%ebp
  8011ad:	83 ec 0c             	sub    $0xc,%esp
  8011b0:	89 1c 24             	mov    %ebx,(%esp)
  8011b3:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011b7:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8011c0:	b8 01 00 00 00       	mov    $0x1,%eax
  8011c5:	89 d1                	mov    %edx,%ecx
  8011c7:	89 d3                	mov    %edx,%ebx
  8011c9:	89 d7                	mov    %edx,%edi
  8011cb:	89 d6                	mov    %edx,%esi
  8011cd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8011cf:	8b 1c 24             	mov    (%esp),%ebx
  8011d2:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011d6:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8011da:	89 ec                	mov    %ebp,%esp
  8011dc:	5d                   	pop    %ebp
  8011dd:	c3                   	ret    

008011de <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8011de:	55                   	push   %ebp
  8011df:	89 e5                	mov    %esp,%ebp
  8011e1:	83 ec 0c             	sub    $0xc,%esp
  8011e4:	89 1c 24             	mov    %ebx,(%esp)
  8011e7:	89 74 24 04          	mov    %esi,0x4(%esp)
  8011eb:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8011ef:	b8 00 00 00 00       	mov    $0x0,%eax
  8011f4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8011f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8011fa:	89 c3                	mov    %eax,%ebx
  8011fc:	89 c7                	mov    %eax,%edi
  8011fe:	89 c6                	mov    %eax,%esi
  801200:	cd 30                	int    $0x30

void
sys_cputs(const char *s, size_t len)
{
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  801202:	8b 1c 24             	mov    (%esp),%ebx
  801205:	8b 74 24 04          	mov    0x4(%esp),%esi
  801209:	8b 7c 24 08          	mov    0x8(%esp),%edi
  80120d:	89 ec                	mov    %ebp,%esp
  80120f:	5d                   	pop    %ebp
  801210:	c3                   	ret    

00801211 <sys_ipc_recv>:
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}

int
sys_ipc_recv(void *dstva)
{
  801211:	55                   	push   %ebp
  801212:	89 e5                	mov    %esp,%ebp
  801214:	83 ec 38             	sub    $0x38,%esp
  801217:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80121a:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80121d:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801220:	b9 00 00 00 00       	mov    $0x0,%ecx
  801225:	b8 0c 00 00 00       	mov    $0xc,%eax
  80122a:	8b 55 08             	mov    0x8(%ebp),%edx
  80122d:	89 cb                	mov    %ecx,%ebx
  80122f:	89 cf                	mov    %ecx,%edi
  801231:	89 ce                	mov    %ecx,%esi
  801233:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801235:	85 c0                	test   %eax,%eax
  801237:	7e 28                	jle    801261 <sys_ipc_recv+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  801239:	89 44 24 10          	mov    %eax,0x10(%esp)
  80123d:	c7 44 24 0c 0c 00 00 	movl   $0xc,0xc(%esp)
  801244:	00 
  801245:	c7 44 24 08 84 1b 80 	movl   $0x801b84,0x8(%esp)
  80124c:	00 
  80124d:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801254:	00 
  801255:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  80125c:	e8 ae f3 ff ff       	call   80060f <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  801261:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801264:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801267:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80126a:	89 ec                	mov    %ebp,%esp
  80126c:	5d                   	pop    %ebp
  80126d:	c3                   	ret    

0080126e <sys_ipc_try_send>:
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80126e:	55                   	push   %ebp
  80126f:	89 e5                	mov    %esp,%ebp
  801271:	83 ec 0c             	sub    $0xc,%esp
  801274:	89 1c 24             	mov    %ebx,(%esp)
  801277:	89 74 24 04          	mov    %esi,0x4(%esp)
  80127b:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80127f:	be 00 00 00 00       	mov    $0x0,%esi
  801284:	b8 0b 00 00 00       	mov    $0xb,%eax
  801289:	8b 7d 14             	mov    0x14(%ebp),%edi
  80128c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80128f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801292:	8b 55 08             	mov    0x8(%ebp),%edx
  801295:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  801297:	8b 1c 24             	mov    (%esp),%ebx
  80129a:	8b 74 24 04          	mov    0x4(%esp),%esi
  80129e:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8012a2:	89 ec                	mov    %ebp,%esp
  8012a4:	5d                   	pop    %ebp
  8012a5:	c3                   	ret    

008012a6 <sys_env_set_pgfault_upcall>:
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
  8012a9:	83 ec 38             	sub    $0x38,%esp
  8012ac:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8012af:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8012b2:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8012b5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8012ba:	b8 09 00 00 00       	mov    $0x9,%eax
  8012bf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8012c2:	8b 55 08             	mov    0x8(%ebp),%edx
  8012c5:	89 df                	mov    %ebx,%edi
  8012c7:	89 de                	mov    %ebx,%esi
  8012c9:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8012cb:	85 c0                	test   %eax,%eax
  8012cd:	7e 28                	jle    8012f7 <sys_env_set_pgfault_upcall+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8012cf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8012d3:	c7 44 24 0c 09 00 00 	movl   $0x9,0xc(%esp)
  8012da:	00 
  8012db:	c7 44 24 08 84 1b 80 	movl   $0x801b84,0x8(%esp)
  8012e2:	00 
  8012e3:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8012ea:	00 
  8012eb:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  8012f2:	e8 18 f3 ff ff       	call   80060f <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8012f7:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8012fa:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8012fd:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801300:	89 ec                	mov    %ebp,%esp
  801302:	5d                   	pop    %ebp
  801303:	c3                   	ret    

00801304 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	83 ec 38             	sub    $0x38,%esp
  80130a:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80130d:	89 75 f8             	mov    %esi,-0x8(%ebp)
  801310:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801313:	bb 00 00 00 00       	mov    $0x0,%ebx
  801318:	b8 08 00 00 00       	mov    $0x8,%eax
  80131d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801320:	8b 55 08             	mov    0x8(%ebp),%edx
  801323:	89 df                	mov    %ebx,%edi
  801325:	89 de                	mov    %ebx,%esi
  801327:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801329:	85 c0                	test   %eax,%eax
  80132b:	7e 28                	jle    801355 <sys_env_set_status+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80132d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801331:	c7 44 24 0c 08 00 00 	movl   $0x8,0xc(%esp)
  801338:	00 
  801339:	c7 44 24 08 84 1b 80 	movl   $0x801b84,0x8(%esp)
  801340:	00 
  801341:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801348:	00 
  801349:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  801350:	e8 ba f2 ff ff       	call   80060f <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  801355:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801358:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80135b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80135e:	89 ec                	mov    %ebp,%esp
  801360:	5d                   	pop    %ebp
  801361:	c3                   	ret    

00801362 <sys_page_unmap>:
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}

int
sys_page_unmap(envid_t envid, void *va)
{
  801362:	55                   	push   %ebp
  801363:	89 e5                	mov    %esp,%ebp
  801365:	83 ec 38             	sub    $0x38,%esp
  801368:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  80136b:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80136e:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  801371:	bb 00 00 00 00       	mov    $0x0,%ebx
  801376:	b8 06 00 00 00       	mov    $0x6,%eax
  80137b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80137e:	8b 55 08             	mov    0x8(%ebp),%edx
  801381:	89 df                	mov    %ebx,%edi
  801383:	89 de                	mov    %ebx,%esi
  801385:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801387:	85 c0                	test   %eax,%eax
  801389:	7e 28                	jle    8013b3 <sys_page_unmap+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  80138b:	89 44 24 10          	mov    %eax,0x10(%esp)
  80138f:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
  801396:	00 
  801397:	c7 44 24 08 84 1b 80 	movl   $0x801b84,0x8(%esp)
  80139e:	00 
  80139f:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8013a6:	00 
  8013a7:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  8013ae:	e8 5c f2 ff ff       	call   80060f <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  8013b3:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  8013b6:	8b 75 f8             	mov    -0x8(%ebp),%esi
  8013b9:	8b 7d fc             	mov    -0x4(%ebp),%edi
  8013bc:	89 ec                	mov    %ebp,%esp
  8013be:	5d                   	pop    %ebp
  8013bf:	c3                   	ret    

008013c0 <sys_page_map>:
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8013c0:	55                   	push   %ebp
  8013c1:	89 e5                	mov    %esp,%ebp
  8013c3:	83 ec 38             	sub    $0x38,%esp
  8013c6:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8013c9:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8013cc:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8013cf:	b8 05 00 00 00       	mov    $0x5,%eax
  8013d4:	8b 75 18             	mov    0x18(%ebp),%esi
  8013d7:	8b 7d 14             	mov    0x14(%ebp),%edi
  8013da:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013e0:	8b 55 08             	mov    0x8(%ebp),%edx
  8013e3:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8013e5:	85 c0                	test   %eax,%eax
  8013e7:	7e 28                	jle    801411 <sys_page_map+0x51>
		panic("syscall %d returned %d (> 0)", num, ret);
  8013e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8013ed:	c7 44 24 0c 05 00 00 	movl   $0x5,0xc(%esp)
  8013f4:	00 
  8013f5:	c7 44 24 08 84 1b 80 	movl   $0x801b84,0x8(%esp)
  8013fc:	00 
  8013fd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801404:	00 
  801405:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  80140c:	e8 fe f1 ff ff       	call   80060f <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  801411:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801414:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801417:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80141a:	89 ec                	mov    %ebp,%esp
  80141c:	5d                   	pop    %ebp
  80141d:	c3                   	ret    

0080141e <sys_page_alloc>:
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80141e:	55                   	push   %ebp
  80141f:	89 e5                	mov    %esp,%ebp
  801421:	83 ec 38             	sub    $0x38,%esp
  801424:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  801427:	89 75 f8             	mov    %esi,-0x8(%ebp)
  80142a:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80142d:	be 00 00 00 00       	mov    $0x0,%esi
  801432:	b8 04 00 00 00       	mov    $0x4,%eax
  801437:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80143a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80143d:	8b 55 08             	mov    0x8(%ebp),%edx
  801440:	89 f7                	mov    %esi,%edi
  801442:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801444:	85 c0                	test   %eax,%eax
  801446:	7e 28                	jle    801470 <sys_page_alloc+0x52>
		panic("syscall %d returned %d (> 0)", num, ret);
  801448:	89 44 24 10          	mov    %eax,0x10(%esp)
  80144c:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
  801453:	00 
  801454:	c7 44 24 08 84 1b 80 	movl   $0x801b84,0x8(%esp)
  80145b:	00 
  80145c:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801463:	00 
  801464:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  80146b:	e8 9f f1 ff ff       	call   80060f <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  801470:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801473:	8b 75 f8             	mov    -0x8(%ebp),%esi
  801476:	8b 7d fc             	mov    -0x4(%ebp),%edi
  801479:	89 ec                	mov    %ebp,%esp
  80147b:	5d                   	pop    %ebp
  80147c:	c3                   	ret    

0080147d <sys_yield>:
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}

void
sys_yield(void)
{
  80147d:	55                   	push   %ebp
  80147e:	89 e5                	mov    %esp,%ebp
  801480:	83 ec 0c             	sub    $0xc,%esp
  801483:	89 1c 24             	mov    %ebx,(%esp)
  801486:	89 74 24 04          	mov    %esi,0x4(%esp)
  80148a:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80148e:	ba 00 00 00 00       	mov    $0x0,%edx
  801493:	b8 0a 00 00 00       	mov    $0xa,%eax
  801498:	89 d1                	mov    %edx,%ecx
  80149a:	89 d3                	mov    %edx,%ebx
  80149c:	89 d7                	mov    %edx,%edi
  80149e:	89 d6                	mov    %edx,%esi
  8014a0:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  8014a2:	8b 1c 24             	mov    (%esp),%ebx
  8014a5:	8b 74 24 04          	mov    0x4(%esp),%esi
  8014a9:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8014ad:	89 ec                	mov    %ebp,%esp
  8014af:	5d                   	pop    %ebp
  8014b0:	c3                   	ret    

008014b1 <sys_getenvid>:
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}

envid_t
sys_getenvid(void)
{
  8014b1:	55                   	push   %ebp
  8014b2:	89 e5                	mov    %esp,%ebp
  8014b4:	83 ec 0c             	sub    $0xc,%esp
  8014b7:	89 1c 24             	mov    %ebx,(%esp)
  8014ba:	89 74 24 04          	mov    %esi,0x4(%esp)
  8014be:	89 7c 24 08          	mov    %edi,0x8(%esp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c7:	b8 02 00 00 00       	mov    $0x2,%eax
  8014cc:	89 d1                	mov    %edx,%ecx
  8014ce:	89 d3                	mov    %edx,%ebx
  8014d0:	89 d7                	mov    %edx,%edi
  8014d2:	89 d6                	mov    %edx,%esi
  8014d4:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  8014d6:	8b 1c 24             	mov    (%esp),%ebx
  8014d9:	8b 74 24 04          	mov    0x4(%esp),%esi
  8014dd:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8014e1:	89 ec                	mov    %ebp,%esp
  8014e3:	5d                   	pop    %ebp
  8014e4:	c3                   	ret    

008014e5 <sys_env_destroy>:
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}

int
sys_env_destroy(envid_t envid)
{
  8014e5:	55                   	push   %ebp
  8014e6:	89 e5                	mov    %esp,%ebp
  8014e8:	83 ec 38             	sub    $0x38,%esp
  8014eb:	89 5d f4             	mov    %ebx,-0xc(%ebp)
  8014ee:	89 75 f8             	mov    %esi,-0x8(%ebp)
  8014f1:	89 7d fc             	mov    %edi,-0x4(%ebp)
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8014f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8014f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8014fe:	8b 55 08             	mov    0x8(%ebp),%edx
  801501:	89 cb                	mov    %ecx,%ebx
  801503:	89 cf                	mov    %ecx,%edi
  801505:	89 ce                	mov    %ecx,%esi
  801507:	cd 30                	int    $0x30
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  801509:	85 c0                	test   %eax,%eax
  80150b:	7e 28                	jle    801535 <sys_env_destroy+0x50>
		panic("syscall %d returned %d (> 0)", num, ret);
  80150d:	89 44 24 10          	mov    %eax,0x10(%esp)
  801511:	c7 44 24 0c 03 00 00 	movl   $0x3,0xc(%esp)
  801518:	00 
  801519:	c7 44 24 08 84 1b 80 	movl   $0x801b84,0x8(%esp)
  801520:	00 
  801521:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801528:	00 
  801529:	c7 04 24 a1 1b 80 00 	movl   $0x801ba1,(%esp)
  801530:	e8 da f0 ff ff       	call   80060f <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  801535:	8b 5d f4             	mov    -0xc(%ebp),%ebx
  801538:	8b 75 f8             	mov    -0x8(%ebp),%esi
  80153b:	8b 7d fc             	mov    -0x4(%ebp),%edi
  80153e:	89 ec                	mov    %ebp,%esp
  801540:	5d                   	pop    %ebp
  801541:	c3                   	ret    

00801542 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801542:	55                   	push   %ebp
  801543:	89 e5                	mov    %esp,%ebp
  801545:	83 ec 18             	sub    $0x18,%esp
	int r;

	if (_pgfault_handler == 0) {
  801548:	83 3d d0 20 80 00 00 	cmpl   $0x0,0x8020d0
  80154f:	75 1c                	jne    80156d <set_pgfault_handler+0x2b>
		// First time through!
		// LAB 4: Your code here.
		panic("set_pgfault_handler not implemented");
  801551:	c7 44 24 08 b0 1b 80 	movl   $0x801bb0,0x8(%esp)
  801558:	00 
  801559:	c7 44 24 04 20 00 00 	movl   $0x20,0x4(%esp)
  801560:	00 
  801561:	c7 04 24 d4 1b 80 00 	movl   $0x801bd4,(%esp)
  801568:	e8 a2 f0 ff ff       	call   80060f <_panic>
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80156d:	8b 45 08             	mov    0x8(%ebp),%eax
  801570:	a3 d0 20 80 00       	mov    %eax,0x8020d0
}
  801575:	c9                   	leave  
  801576:	c3                   	ret    
  801577:	66 90                	xchg   %ax,%ax
  801579:	66 90                	xchg   %ax,%ax
  80157b:	66 90                	xchg   %ax,%ax
  80157d:	66 90                	xchg   %ax,%ax
  80157f:	90                   	nop

00801580 <__udivdi3>:
  801580:	55                   	push   %ebp
  801581:	89 e5                	mov    %esp,%ebp
  801583:	57                   	push   %edi
  801584:	56                   	push   %esi
  801585:	83 ec 10             	sub    $0x10,%esp
  801588:	8b 45 14             	mov    0x14(%ebp),%eax
  80158b:	8b 55 08             	mov    0x8(%ebp),%edx
  80158e:	8b 75 10             	mov    0x10(%ebp),%esi
  801591:	8b 7d 0c             	mov    0xc(%ebp),%edi
  801594:	85 c0                	test   %eax,%eax
  801596:	89 55 f0             	mov    %edx,-0x10(%ebp)
  801599:	75 35                	jne    8015d0 <__udivdi3+0x50>
  80159b:	39 fe                	cmp    %edi,%esi
  80159d:	77 61                	ja     801600 <__udivdi3+0x80>
  80159f:	85 f6                	test   %esi,%esi
  8015a1:	75 0b                	jne    8015ae <__udivdi3+0x2e>
  8015a3:	b8 01 00 00 00       	mov    $0x1,%eax
  8015a8:	31 d2                	xor    %edx,%edx
  8015aa:	f7 f6                	div    %esi
  8015ac:	89 c6                	mov    %eax,%esi
  8015ae:	8b 4d f0             	mov    -0x10(%ebp),%ecx
  8015b1:	31 d2                	xor    %edx,%edx
  8015b3:	89 f8                	mov    %edi,%eax
  8015b5:	f7 f6                	div    %esi
  8015b7:	89 c7                	mov    %eax,%edi
  8015b9:	89 c8                	mov    %ecx,%eax
  8015bb:	f7 f6                	div    %esi
  8015bd:	89 c1                	mov    %eax,%ecx
  8015bf:	89 fa                	mov    %edi,%edx
  8015c1:	89 c8                	mov    %ecx,%eax
  8015c3:	83 c4 10             	add    $0x10,%esp
  8015c6:	5e                   	pop    %esi
  8015c7:	5f                   	pop    %edi
  8015c8:	5d                   	pop    %ebp
  8015c9:	c3                   	ret    
  8015ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8015d0:	39 f8                	cmp    %edi,%eax
  8015d2:	77 1c                	ja     8015f0 <__udivdi3+0x70>
  8015d4:	0f bd d0             	bsr    %eax,%edx
  8015d7:	83 f2 1f             	xor    $0x1f,%edx
  8015da:	89 55 f4             	mov    %edx,-0xc(%ebp)
  8015dd:	75 39                	jne    801618 <__udivdi3+0x98>
  8015df:	3b 75 f0             	cmp    -0x10(%ebp),%esi
  8015e2:	0f 86 a0 00 00 00    	jbe    801688 <__udivdi3+0x108>
  8015e8:	39 f8                	cmp    %edi,%eax
  8015ea:	0f 82 98 00 00 00    	jb     801688 <__udivdi3+0x108>
  8015f0:	31 ff                	xor    %edi,%edi
  8015f2:	31 c9                	xor    %ecx,%ecx
  8015f4:	89 c8                	mov    %ecx,%eax
  8015f6:	89 fa                	mov    %edi,%edx
  8015f8:	83 c4 10             	add    $0x10,%esp
  8015fb:	5e                   	pop    %esi
  8015fc:	5f                   	pop    %edi
  8015fd:	5d                   	pop    %ebp
  8015fe:	c3                   	ret    
  8015ff:	90                   	nop
  801600:	89 d1                	mov    %edx,%ecx
  801602:	89 fa                	mov    %edi,%edx
  801604:	89 c8                	mov    %ecx,%eax
  801606:	31 ff                	xor    %edi,%edi
  801608:	f7 f6                	div    %esi
  80160a:	89 c1                	mov    %eax,%ecx
  80160c:	89 fa                	mov    %edi,%edx
  80160e:	89 c8                	mov    %ecx,%eax
  801610:	83 c4 10             	add    $0x10,%esp
  801613:	5e                   	pop    %esi
  801614:	5f                   	pop    %edi
  801615:	5d                   	pop    %ebp
  801616:	c3                   	ret    
  801617:	90                   	nop
  801618:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80161c:	89 f2                	mov    %esi,%edx
  80161e:	d3 e0                	shl    %cl,%eax
  801620:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801623:	b8 20 00 00 00       	mov    $0x20,%eax
  801628:	2b 45 f4             	sub    -0xc(%ebp),%eax
  80162b:	89 c1                	mov    %eax,%ecx
  80162d:	d3 ea                	shr    %cl,%edx
  80162f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801633:	0b 55 ec             	or     -0x14(%ebp),%edx
  801636:	d3 e6                	shl    %cl,%esi
  801638:	89 c1                	mov    %eax,%ecx
  80163a:	89 75 e8             	mov    %esi,-0x18(%ebp)
  80163d:	89 fe                	mov    %edi,%esi
  80163f:	d3 ee                	shr    %cl,%esi
  801641:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  801645:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801648:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80164b:	d3 e7                	shl    %cl,%edi
  80164d:	89 c1                	mov    %eax,%ecx
  80164f:	d3 ea                	shr    %cl,%edx
  801651:	09 d7                	or     %edx,%edi
  801653:	89 f2                	mov    %esi,%edx
  801655:	89 f8                	mov    %edi,%eax
  801657:	f7 75 ec             	divl   -0x14(%ebp)
  80165a:	89 d6                	mov    %edx,%esi
  80165c:	89 c7                	mov    %eax,%edi
  80165e:	f7 65 e8             	mull   -0x18(%ebp)
  801661:	39 d6                	cmp    %edx,%esi
  801663:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801666:	72 30                	jb     801698 <__udivdi3+0x118>
  801668:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80166b:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
  80166f:	d3 e2                	shl    %cl,%edx
  801671:	39 c2                	cmp    %eax,%edx
  801673:	73 05                	jae    80167a <__udivdi3+0xfa>
  801675:	3b 75 ec             	cmp    -0x14(%ebp),%esi
  801678:	74 1e                	je     801698 <__udivdi3+0x118>
  80167a:	89 f9                	mov    %edi,%ecx
  80167c:	31 ff                	xor    %edi,%edi
  80167e:	e9 71 ff ff ff       	jmp    8015f4 <__udivdi3+0x74>
  801683:	90                   	nop
  801684:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801688:	31 ff                	xor    %edi,%edi
  80168a:	b9 01 00 00 00       	mov    $0x1,%ecx
  80168f:	e9 60 ff ff ff       	jmp    8015f4 <__udivdi3+0x74>
  801694:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801698:	8d 4f ff             	lea    -0x1(%edi),%ecx
  80169b:	31 ff                	xor    %edi,%edi
  80169d:	89 c8                	mov    %ecx,%eax
  80169f:	89 fa                	mov    %edi,%edx
  8016a1:	83 c4 10             	add    $0x10,%esp
  8016a4:	5e                   	pop    %esi
  8016a5:	5f                   	pop    %edi
  8016a6:	5d                   	pop    %ebp
  8016a7:	c3                   	ret    
  8016a8:	66 90                	xchg   %ax,%ax
  8016aa:	66 90                	xchg   %ax,%ax
  8016ac:	66 90                	xchg   %ax,%ax
  8016ae:	66 90                	xchg   %ax,%ax

008016b0 <__umoddi3>:
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	57                   	push   %edi
  8016b4:	56                   	push   %esi
  8016b5:	83 ec 20             	sub    $0x20,%esp
  8016b8:	8b 55 14             	mov    0x14(%ebp),%edx
  8016bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016be:	8b 7d 10             	mov    0x10(%ebp),%edi
  8016c1:	8b 75 0c             	mov    0xc(%ebp),%esi
  8016c4:	85 d2                	test   %edx,%edx
  8016c6:	89 c8                	mov    %ecx,%eax
  8016c8:	89 4d f4             	mov    %ecx,-0xc(%ebp)
  8016cb:	75 13                	jne    8016e0 <__umoddi3+0x30>
  8016cd:	39 f7                	cmp    %esi,%edi
  8016cf:	76 3f                	jbe    801710 <__umoddi3+0x60>
  8016d1:	89 f2                	mov    %esi,%edx
  8016d3:	f7 f7                	div    %edi
  8016d5:	89 d0                	mov    %edx,%eax
  8016d7:	31 d2                	xor    %edx,%edx
  8016d9:	83 c4 20             	add    $0x20,%esp
  8016dc:	5e                   	pop    %esi
  8016dd:	5f                   	pop    %edi
  8016de:	5d                   	pop    %ebp
  8016df:	c3                   	ret    
  8016e0:	39 f2                	cmp    %esi,%edx
  8016e2:	77 4c                	ja     801730 <__umoddi3+0x80>
  8016e4:	0f bd ca             	bsr    %edx,%ecx
  8016e7:	83 f1 1f             	xor    $0x1f,%ecx
  8016ea:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8016ed:	75 51                	jne    801740 <__umoddi3+0x90>
  8016ef:	3b 7d f4             	cmp    -0xc(%ebp),%edi
  8016f2:	0f 87 e0 00 00 00    	ja     8017d8 <__umoddi3+0x128>
  8016f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016fb:	29 f8                	sub    %edi,%eax
  8016fd:	19 d6                	sbb    %edx,%esi
  8016ff:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801702:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801705:	89 f2                	mov    %esi,%edx
  801707:	83 c4 20             	add    $0x20,%esp
  80170a:	5e                   	pop    %esi
  80170b:	5f                   	pop    %edi
  80170c:	5d                   	pop    %ebp
  80170d:	c3                   	ret    
  80170e:	66 90                	xchg   %ax,%ax
  801710:	85 ff                	test   %edi,%edi
  801712:	75 0b                	jne    80171f <__umoddi3+0x6f>
  801714:	b8 01 00 00 00       	mov    $0x1,%eax
  801719:	31 d2                	xor    %edx,%edx
  80171b:	f7 f7                	div    %edi
  80171d:	89 c7                	mov    %eax,%edi
  80171f:	89 f0                	mov    %esi,%eax
  801721:	31 d2                	xor    %edx,%edx
  801723:	f7 f7                	div    %edi
  801725:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801728:	f7 f7                	div    %edi
  80172a:	eb a9                	jmp    8016d5 <__umoddi3+0x25>
  80172c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801730:	89 c8                	mov    %ecx,%eax
  801732:	89 f2                	mov    %esi,%edx
  801734:	83 c4 20             	add    $0x20,%esp
  801737:	5e                   	pop    %esi
  801738:	5f                   	pop    %edi
  801739:	5d                   	pop    %ebp
  80173a:	c3                   	ret    
  80173b:	90                   	nop
  80173c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801740:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801744:	d3 e2                	shl    %cl,%edx
  801746:	89 55 f4             	mov    %edx,-0xc(%ebp)
  801749:	ba 20 00 00 00       	mov    $0x20,%edx
  80174e:	2b 55 f0             	sub    -0x10(%ebp),%edx
  801751:	89 55 ec             	mov    %edx,-0x14(%ebp)
  801754:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801758:	89 fa                	mov    %edi,%edx
  80175a:	d3 ea                	shr    %cl,%edx
  80175c:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801760:	0b 55 f4             	or     -0xc(%ebp),%edx
  801763:	d3 e7                	shl    %cl,%edi
  801765:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801769:	89 55 f4             	mov    %edx,-0xc(%ebp)
  80176c:	89 f2                	mov    %esi,%edx
  80176e:	89 7d e8             	mov    %edi,-0x18(%ebp)
  801771:	89 c7                	mov    %eax,%edi
  801773:	d3 ea                	shr    %cl,%edx
  801775:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  801779:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80177c:	89 c2                	mov    %eax,%edx
  80177e:	d3 e6                	shl    %cl,%esi
  801780:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  801784:	d3 ea                	shr    %cl,%edx
  801786:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  80178a:	09 d6                	or     %edx,%esi
  80178c:	89 f0                	mov    %esi,%eax
  80178e:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801791:	d3 e7                	shl    %cl,%edi
  801793:	89 f2                	mov    %esi,%edx
  801795:	f7 75 f4             	divl   -0xc(%ebp)
  801798:	89 d6                	mov    %edx,%esi
  80179a:	f7 65 e8             	mull   -0x18(%ebp)
  80179d:	39 d6                	cmp    %edx,%esi
  80179f:	72 2b                	jb     8017cc <__umoddi3+0x11c>
  8017a1:	39 c7                	cmp    %eax,%edi
  8017a3:	72 23                	jb     8017c8 <__umoddi3+0x118>
  8017a5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8017a9:	29 c7                	sub    %eax,%edi
  8017ab:	19 d6                	sbb    %edx,%esi
  8017ad:	89 f0                	mov    %esi,%eax
  8017af:	89 f2                	mov    %esi,%edx
  8017b1:	d3 ef                	shr    %cl,%edi
  8017b3:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
  8017b7:	d3 e0                	shl    %cl,%eax
  8017b9:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
  8017bd:	09 f8                	or     %edi,%eax
  8017bf:	d3 ea                	shr    %cl,%edx
  8017c1:	83 c4 20             	add    $0x20,%esp
  8017c4:	5e                   	pop    %esi
  8017c5:	5f                   	pop    %edi
  8017c6:	5d                   	pop    %ebp
  8017c7:	c3                   	ret    
  8017c8:	39 d6                	cmp    %edx,%esi
  8017ca:	75 d9                	jne    8017a5 <__umoddi3+0xf5>
  8017cc:	2b 45 e8             	sub    -0x18(%ebp),%eax
  8017cf:	1b 55 f4             	sbb    -0xc(%ebp),%edx
  8017d2:	eb d1                	jmp    8017a5 <__umoddi3+0xf5>
  8017d4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8017d8:	39 f2                	cmp    %esi,%edx
  8017da:	0f 82 18 ff ff ff    	jb     8016f8 <__umoddi3+0x48>
  8017e0:	e9 1d ff ff ff       	jmp    801702 <__umoddi3+0x52>
