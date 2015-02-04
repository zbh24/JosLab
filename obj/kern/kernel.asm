
obj/kern/kernelÔºö     Êñá‰ª∂Ê†ºÂºè elf32-i386


Disassembly of section .text:

f0100000 <_start+0xeffffff4>:
.globl		_start
_start = RELOC(entry)

.globl entry
entry:
	movw	$0x1234,0x472			# warm boot
f0100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
f0100006:	00 00                	add    %al,(%eax)
f0100008:	fe 4f 52             	decb   0x52(%edi)
f010000b:	e4 66                	in     $0x66,%al

f010000c <entry>:
f010000c:	66 c7 05 72 04 00 00 	movw   $0x1234,0x472
f0100013:	34 12 
	# sufficient until we set up our real page table in mem_init
	# in lab 2.

	# Load the physical address of entry_pgdir into cr3.  entry_pgdir
	# is defined in entrypgdir.c.
	movl	$(RELOC(entry_pgdir)), %eax
f0100015:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl	%eax, %cr3
f010001a:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl	%cr0, %eax
f010001d:	0f 20 c0             	mov    %cr0,%eax
	orl	$(CR0_PE|CR0_PG|CR0_WP), %eax
f0100020:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl	%eax, %cr0
f0100025:	0f 22 c0             	mov    %eax,%cr0

	# Now paging is enabled, but we're still running at a low EIP
	# (why is this okay?).  Jump up above KERNBASE before entering
	# C code.
	mov	$relocated, %eax
f0100028:	b8 2f 00 10 f0       	mov    $0xf010002f,%eax
	jmp	*%eax
f010002d:	ff e0                	jmp    *%eax

f010002f <relocated>:
relocated:

	# Clear the frame pointer register (EBP)
	# so that once we get into debugging C code,
	# stack backtraces will be terminated properly.
	movl	$0x0,%ebp			# nuke frame pointer
f010002f:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Set the stack pointer
	movl	$(bootstacktop),%esp
f0100034:	bc 00 e0 11 f0       	mov    $0xf011e000,%esp

	# now to C code
	call	i386_init
f0100039:	e8 2a 01 00 00       	call   f0100168 <i386_init>

f010003e <spin>:

	# Should never get here, but in case we do, just spin.
spin:	jmp	spin
f010003e:	eb fe                	jmp    f010003e <spin>

f0100040 <_warn>:
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
{
f0100040:	55                   	push   %ebp
f0100041:	89 e5                	mov    %esp,%ebp
f0100043:	53                   	push   %ebx
f0100044:	83 ec 14             	sub    $0x14,%esp
		monitor(NULL);
}

/* like panic, but don't */
void
_warn(const char *file, int line, const char *fmt,...)
f0100047:	8d 5d 14             	lea    0x14(%ebp),%ebx
{
	va_list ap;

	va_start(ap, fmt);
	cprintf("kernel warning at %s:%d: ", file, line);
f010004a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010004d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100051:	8b 45 08             	mov    0x8(%ebp),%eax
f0100054:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100058:	c7 04 24 60 65 10 f0 	movl   $0xf0106560,(%esp)
f010005f:	e8 c5 3e 00 00       	call   f0103f29 <cprintf>
	vcprintf(fmt, ap);
f0100064:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0100068:	8b 45 10             	mov    0x10(%ebp),%eax
f010006b:	89 04 24             	mov    %eax,(%esp)
f010006e:	e8 83 3e 00 00       	call   f0103ef6 <vcprintf>
	cprintf("\n");
f0100073:	c7 04 24 18 77 10 f0 	movl   $0xf0107718,(%esp)
f010007a:	e8 aa 3e 00 00       	call   f0103f29 <cprintf>
	va_end(ap);
}
f010007f:	83 c4 14             	add    $0x14,%esp
f0100082:	5b                   	pop    %ebx
f0100083:	5d                   	pop    %ebp
f0100084:	c3                   	ret    

f0100085 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
{
f0100085:	55                   	push   %ebp
f0100086:	89 e5                	mov    %esp,%ebp
f0100088:	56                   	push   %esi
f0100089:	53                   	push   %ebx
f010008a:	83 ec 10             	sub    $0x10,%esp
f010008d:	8b 75 10             	mov    0x10(%ebp),%esi
	va_list ap;

	if (panicstr)
f0100090:	83 3d e0 3e 22 f0 00 	cmpl   $0x0,0xf0223ee0
f0100097:	75 46                	jne    f01000df <_panic+0x5a>
		goto dead;
	panicstr = fmt;
f0100099:	89 35 e0 3e 22 f0    	mov    %esi,0xf0223ee0

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");
f010009f:	fa                   	cli    
f01000a0:	fc                   	cld    
/*
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt,...)
f01000a1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Be extra sure that the machine is in as reasonable state
	__asm __volatile("cli; cld");

	va_start(ap, fmt);
	cprintf("kernel panic on CPU %d at %s:%d: ", cpunum(), file, line);
f01000a4:	e8 86 5d 00 00       	call   f0105e2f <cpunum>
f01000a9:	8b 55 0c             	mov    0xc(%ebp),%edx
f01000ac:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01000b0:	8b 55 08             	mov    0x8(%ebp),%edx
f01000b3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01000b7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01000bb:	c7 04 24 b8 65 10 f0 	movl   $0xf01065b8,(%esp)
f01000c2:	e8 62 3e 00 00       	call   f0103f29 <cprintf>
	vcprintf(fmt, ap);
f01000c7:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01000cb:	89 34 24             	mov    %esi,(%esp)
f01000ce:	e8 23 3e 00 00       	call   f0103ef6 <vcprintf>
	cprintf("\n");
f01000d3:	c7 04 24 18 77 10 f0 	movl   $0xf0107718,(%esp)
f01000da:	e8 4a 3e 00 00       	call   f0103f29 <cprintf>
	va_end(ap);

dead:
	/* break into the kernel monitor */
	while (1)
		monitor(NULL);
f01000df:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01000e6:	e8 36 08 00 00       	call   f0100921 <monitor>
f01000eb:	eb f2                	jmp    f01000df <_panic+0x5a>

f01000ed <mp_main>:
}

// Setup code for APs
void
mp_main(void)
{
f01000ed:	55                   	push   %ebp
f01000ee:	89 e5                	mov    %esp,%ebp
f01000f0:	83 ec 18             	sub    $0x18,%esp
	// We are in high EIP now, safe to switch to kern_pgdir 
	lcr3(PADDR(kern_pgdir));
f01000f3:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01000f8:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01000fd:	77 20                	ja     f010011f <mp_main+0x32>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01000ff:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100103:	c7 44 24 08 dc 65 10 	movl   $0xf01065dc,0x8(%esp)
f010010a:	f0 
f010010b:	c7 44 24 04 74 00 00 	movl   $0x74,0x4(%esp)
f0100112:	00 
f0100113:	c7 04 24 7a 65 10 f0 	movl   $0xf010657a,(%esp)
f010011a:	e8 66 ff ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010011f:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0100125:	0f 22 d8             	mov    %eax,%cr3
	cprintf("SMP: CPU %d starting\n", cpunum());
f0100128:	e8 02 5d 00 00       	call   f0105e2f <cpunum>
f010012d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100131:	c7 04 24 86 65 10 f0 	movl   $0xf0106586,(%esp)
f0100138:	e8 ec 3d 00 00       	call   f0103f29 <cprintf>

	lapic_init();
f010013d:	e8 26 5e 00 00       	call   f0105f68 <lapic_init>
	env_init_percpu();
f0100142:	e8 39 34 00 00       	call   f0103580 <env_init_percpu>
	trap_init_percpu();
f0100147:	e8 14 3e 00 00       	call   f0103f60 <trap_init_percpu>
	xchg(&thiscpu->cpu_status, CPU_STARTED); // tell boot_aps() we're up
f010014c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0100150:	e8 da 5c 00 00       	call   f0105e2f <cpunum>
f0100155:	6b d0 74             	imul   $0x74,%eax,%edx
f0100158:	81 c2 24 40 22 f0    	add    $0xf0224024,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f010015e:	b8 01 00 00 00       	mov    $0x1,%eax
f0100163:	f0 87 02             	lock xchg %eax,(%edx)
f0100166:	eb fe                	jmp    f0100166 <mp_main+0x79>

f0100168 <i386_init>:
static void boot_aps(void);


void
i386_init(void)
{
f0100168:	55                   	push   %ebp
f0100169:	89 e5                	mov    %esp,%ebp
f010016b:	56                   	push   %esi
f010016c:	53                   	push   %ebx
f010016d:	83 ec 10             	sub    $0x10,%esp
	extern char edata[], end[];

	// Before doing anything else, complete the ELF loading process.
	// Clear the uninitialized global data (BSS) section of our program.
	// This ensures that all static/global variables start out zero.
	memset(edata, 0, end - edata);
f0100170:	b8 08 50 26 f0       	mov    $0xf0265008,%eax
f0100175:	2d 00 22 22 f0       	sub    $0xf0222200,%eax
f010017a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010017e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0100185:	00 
f0100186:	c7 04 24 00 22 22 f0 	movl   $0xf0222200,(%esp)
f010018d:	e8 f4 55 00 00       	call   f0105786 <memset>

	// Initialize the console.
	// Can't call cprintf until after we do this!
	cons_init();
f0100192:	e8 42 05 00 00       	call   f01006d9 <cons_init>

	cprintf("6828 decimal is %o octal!\n", 6828);
f0100197:	c7 44 24 04 ac 1a 00 	movl   $0x1aac,0x4(%esp)
f010019e:	00 
f010019f:	c7 04 24 9c 65 10 f0 	movl   $0xf010659c,(%esp)
f01001a6:	e8 7e 3d 00 00       	call   f0103f29 <cprintf>

	// Lab 2 memory management initialization functions
	mem_init();
f01001ab:	e8 1a 18 00 00       	call   f01019ca <mem_init>

	// Lab 3 user environment initialization functions
	env_init();
f01001b0:	e8 f5 33 00 00       	call   f01035aa <env_init>
		
	trap_init();
f01001b5:	e8 03 3e 00 00       	call   f0103fbd <trap_init>

	// Lab 4 multiprocessor initialization functions
	mp_init();
f01001ba:	e8 8b 59 00 00       	call   f0105b4a <mp_init>
	lapic_init();
f01001bf:	90                   	nop
f01001c0:	e8 a3 5d 00 00       	call   f0105f68 <lapic_init>

	// Lab 4 multitasking initialization functions
	pic_init();
f01001c5:	e8 a3 3c 00 00       	call   f0103e6d <pic_init>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01001ca:	c7 04 24 a0 03 12 f0 	movl   $0xf01203a0,(%esp)
f01001d1:	e8 2f 60 00 00       	call   f0106205 <spin_lock>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01001d6:	83 3d e8 3e 22 f0 07 	cmpl   $0x7,0xf0223ee8
f01001dd:	77 24                	ja     f0100203 <i386_init+0x9b>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01001df:	c7 44 24 0c 00 70 00 	movl   $0x7000,0xc(%esp)
f01001e6:	00 
f01001e7:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f01001ee:	f0 
f01001ef:	c7 44 24 04 55 00 00 	movl   $0x55,0x4(%esp)
f01001f6:	00 
f01001f7:	c7 04 24 7a 65 10 f0 	movl   $0xf010657a,(%esp)
f01001fe:	e8 82 fe ff ff       	call   f0100085 <_panic>
	void *code;
	struct CpuInfo *c;

	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);
f0100203:	b8 66 5a 10 f0       	mov    $0xf0105a66,%eax
f0100208:	2d ec 59 10 f0       	sub    $0xf01059ec,%eax
f010020d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100211:	c7 44 24 04 ec 59 10 	movl   $0xf01059ec,0x4(%esp)
f0100218:	f0 
f0100219:	c7 04 24 00 70 00 f0 	movl   $0xf0007000,(%esp)
f0100220:	e8 c0 55 00 00       	call   f01057e5 <memmove>

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100225:	6b 05 c4 43 22 f0 74 	imul   $0x74,0xf02243c4,%eax
f010022c:	05 20 40 22 f0       	add    $0xf0224020,%eax
f0100231:	3d 20 40 22 f0       	cmp    $0xf0224020,%eax
f0100236:	76 65                	jbe    f010029d <i386_init+0x135>
f0100238:	be 00 00 00 00       	mov    $0x0,%esi
f010023d:	bb 20 40 22 f0       	mov    $0xf0224020,%ebx
		if (c == cpus + cpunum())  // We've started already.
f0100242:	e8 e8 5b 00 00       	call   f0105e2f <cpunum>
f0100247:	6b c0 74             	imul   $0x74,%eax,%eax
f010024a:	05 20 40 22 f0       	add    $0xf0224020,%eax
f010024f:	39 d8                	cmp    %ebx,%eax
f0100251:	74 34                	je     f0100287 <i386_init+0x11f>
			continue;

		// Tell mpentry.S what stack to use 
		mpentry_kstack = percpu_kstacks[c - cpus] + KSTKSIZE;
f0100253:	89 f0                	mov    %esi,%eax
f0100255:	c1 f8 02             	sar    $0x2,%eax
f0100258:	69 c0 35 c2 72 4f    	imul   $0x4f72c235,%eax,%eax
f010025e:	c1 e0 0f             	shl    $0xf,%eax
f0100261:	8d 80 00 d0 22 f0    	lea    -0xfdd3000(%eax),%eax
f0100267:	a3 e4 3e 22 f0       	mov    %eax,0xf0223ee4
		// Start the CPU at mpentry_start
		lapic_startap(c->cpu_id, PADDR(code));
f010026c:	c7 44 24 04 00 70 00 	movl   $0x7000,0x4(%esp)
f0100273:	00 
f0100274:	0f b6 03             	movzbl (%ebx),%eax
f0100277:	89 04 24             	mov    %eax,(%esp)
f010027a:	e8 19 5c 00 00       	call   f0105e98 <lapic_startap>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
f010027f:	8b 43 04             	mov    0x4(%ebx),%eax
f0100282:	83 f8 01             	cmp    $0x1,%eax
f0100285:	75 f8                	jne    f010027f <i386_init+0x117>
	// Write entry code to unused memory at MPENTRY_PADDR
	code = KADDR(MPENTRY_PADDR);
	memmove(code, mpentry_start, mpentry_end - mpentry_start);

	// Boot each AP one at a time
	for (c = cpus; c < cpus + ncpu; c++) {
f0100287:	83 c3 74             	add    $0x74,%ebx
f010028a:	83 c6 74             	add    $0x74,%esi
f010028d:	6b 05 c4 43 22 f0 74 	imul   $0x74,0xf02243c4,%eax
f0100294:	05 20 40 22 f0       	add    $0xf0224020,%eax
f0100299:	39 c3                	cmp    %eax,%ebx
f010029b:	72 a5                	jb     f0100242 <i386_init+0xda>
		// Wait for the CPU to finish some basic setup in mp_main()
		while(c->cpu_status != CPU_STARTED)
			;
	}

	ENV_CREATE(user_divzero, ENV_TYPE_USER);
f010029d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01002a4:	00 
f01002a5:	c7 44 24 04 62 89 00 	movl   $0x8962,0x4(%esp)
f01002ac:	00 
f01002ad:	c7 04 24 8f b2 14 f0 	movl   $0xf014b28f,(%esp)
f01002b4:	e8 c6 39 00 00       	call   f0103c7f <env_create>


	// We only have one user environment for now, so just run it.
		
	env_run(&envs[0]);
f01002b9:	a1 38 32 22 f0       	mov    0xf0223238,%eax
f01002be:	89 04 24             	mov    %eax,(%esp)
f01002c1:	e8 2e 34 00 00       	call   f01036f4 <env_run>
f01002c6:	66 90                	xchg   %ax,%ax
f01002c8:	66 90                	xchg   %ax,%ax
f01002ca:	66 90                	xchg   %ax,%ax
f01002cc:	66 90                	xchg   %ax,%ax
f01002ce:	66 90                	xchg   %ax,%ax

f01002d0 <delay>:
static void cons_putc(int c);

// Stupid I/O delay routine necessitated by historical PC design flaws
static void
delay(void)
{
f01002d0:	55                   	push   %ebp
f01002d1:	89 e5                	mov    %esp,%ebp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01002d3:	ba 84 00 00 00       	mov    $0x84,%edx
f01002d8:	ec                   	in     (%dx),%al
f01002d9:	ec                   	in     (%dx),%al
f01002da:	ec                   	in     (%dx),%al
f01002db:	ec                   	in     (%dx),%al
	inb(0x84);
	inb(0x84);
	inb(0x84);
	inb(0x84);
}
f01002dc:	5d                   	pop    %ebp
f01002dd:	c3                   	ret    

f01002de <serial_proc_data>:

static bool serial_exists;

static int
serial_proc_data(void)
{
f01002de:	55                   	push   %ebp
f01002df:	89 e5                	mov    %esp,%ebp
f01002e1:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01002e6:	ec                   	in     (%dx),%al
f01002e7:	89 c2                	mov    %eax,%edx
	if (!(inb(COM1+COM_LSR) & COM_LSR_DATA))
f01002e9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f01002ee:	f6 c2 01             	test   $0x1,%dl
f01002f1:	74 09                	je     f01002fc <serial_proc_data+0x1e>
f01002f3:	ba f8 03 00 00       	mov    $0x3f8,%edx
f01002f8:	ec                   	in     (%dx),%al
		return -1;
	return inb(COM1+COM_RX);
f01002f9:	0f b6 c0             	movzbl %al,%eax
}
f01002fc:	5d                   	pop    %ebp
f01002fd:	c3                   	ret    

f01002fe <cons_intr>:

// called by device interrupt routines to feed input characters
// into the circular console input buffer.
static void
cons_intr(int (*proc)(void))
{
f01002fe:	55                   	push   %ebp
f01002ff:	89 e5                	mov    %esp,%ebp
f0100301:	57                   	push   %edi
f0100302:	56                   	push   %esi
f0100303:	53                   	push   %ebx
f0100304:	83 ec 0c             	sub    $0xc,%esp
f0100307:	89 c6                	mov    %eax,%esi
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100309:	bb 24 32 22 f0       	mov    $0xf0223224,%ebx
f010030e:	bf 20 30 22 f0       	mov    $0xf0223020,%edi
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100313:	eb 1b                	jmp    f0100330 <cons_intr+0x32>
		if (c == 0)
f0100315:	85 c0                	test   %eax,%eax
f0100317:	74 17                	je     f0100330 <cons_intr+0x32>
			continue;
		cons.buf[cons.wpos++] = c;
f0100319:	8b 13                	mov    (%ebx),%edx
f010031b:	88 04 3a             	mov    %al,(%edx,%edi,1)
f010031e:	8d 42 01             	lea    0x1(%edx),%eax
		if (cons.wpos == CONSBUFSIZE)
f0100321:	3d 00 02 00 00       	cmp    $0x200,%eax
			cons.wpos = 0;
f0100326:	ba 00 00 00 00       	mov    $0x0,%edx
f010032b:	0f 44 c2             	cmove  %edx,%eax
f010032e:	89 03                	mov    %eax,(%ebx)
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f0100330:	ff d6                	call   *%esi
f0100332:	83 f8 ff             	cmp    $0xffffffff,%eax
f0100335:	75 de                	jne    f0100315 <cons_intr+0x17>
			continue;
		cons.buf[cons.wpos++] = c;
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
	}
}
f0100337:	83 c4 0c             	add    $0xc,%esp
f010033a:	5b                   	pop    %ebx
f010033b:	5e                   	pop    %esi
f010033c:	5f                   	pop    %edi
f010033d:	5d                   	pop    %ebp
f010033e:	c3                   	ret    

f010033f <kbd_intr>:
	return c;
}

void
kbd_intr(void)
{
f010033f:	55                   	push   %ebp
f0100340:	89 e5                	mov    %esp,%ebp
f0100342:	83 ec 08             	sub    $0x8,%esp
	cons_intr(kbd_proc_data);
f0100345:	b8 da 05 10 f0       	mov    $0xf01005da,%eax
f010034a:	e8 af ff ff ff       	call   f01002fe <cons_intr>
}
f010034f:	c9                   	leave  
f0100350:	c3                   	ret    

f0100351 <serial_intr>:
	return inb(COM1+COM_RX);
}

void
serial_intr(void)
{
f0100351:	55                   	push   %ebp
f0100352:	89 e5                	mov    %esp,%ebp
f0100354:	83 ec 08             	sub    $0x8,%esp
	if (serial_exists)
f0100357:	80 3d 04 30 22 f0 00 	cmpb   $0x0,0xf0223004
f010035e:	74 0a                	je     f010036a <serial_intr+0x19>
		cons_intr(serial_proc_data);
f0100360:	b8 de 02 10 f0       	mov    $0xf01002de,%eax
f0100365:	e8 94 ff ff ff       	call   f01002fe <cons_intr>
}
f010036a:	c9                   	leave  
f010036b:	c3                   	ret    

f010036c <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f010036c:	55                   	push   %ebp
f010036d:	89 e5                	mov    %esp,%ebp
f010036f:	83 ec 08             	sub    $0x8,%esp
	int c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	serial_intr();
f0100372:	e8 da ff ff ff       	call   f0100351 <serial_intr>
	kbd_intr();
f0100377:	e8 c3 ff ff ff       	call   f010033f <kbd_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f010037c:	8b 15 20 32 22 f0    	mov    0xf0223220,%edx
f0100382:	b8 00 00 00 00       	mov    $0x0,%eax
f0100387:	3b 15 24 32 22 f0    	cmp    0xf0223224,%edx
f010038d:	74 1e                	je     f01003ad <cons_getc+0x41>
		c = cons.buf[cons.rpos++];
f010038f:	0f b6 82 20 30 22 f0 	movzbl -0xfddcfe0(%edx),%eax
f0100396:	83 c2 01             	add    $0x1,%edx
		if (cons.rpos == CONSBUFSIZE)
f0100399:	81 fa 00 02 00 00    	cmp    $0x200,%edx
			cons.rpos = 0;
f010039f:	b9 00 00 00 00       	mov    $0x0,%ecx
f01003a4:	0f 44 d1             	cmove  %ecx,%edx
f01003a7:	89 15 20 32 22 f0    	mov    %edx,0xf0223220
		return c;
	}
	return 0;
}
f01003ad:	c9                   	leave  
f01003ae:	c3                   	ret    

f01003af <getchar>:
	cons_putc(c);
}

int
getchar(void)
{
f01003af:	55                   	push   %ebp
f01003b0:	89 e5                	mov    %esp,%ebp
f01003b2:	83 ec 08             	sub    $0x8,%esp
	int c;

	while ((c = cons_getc()) == 0)
f01003b5:	e8 b2 ff ff ff       	call   f010036c <cons_getc>
f01003ba:	85 c0                	test   %eax,%eax
f01003bc:	74 f7                	je     f01003b5 <getchar+0x6>
		/* do nothing */;
	return c;
}
f01003be:	c9                   	leave  
f01003bf:	c3                   	ret    

f01003c0 <iscons>:

int
iscons(int fdnum)
{
f01003c0:	55                   	push   %ebp
f01003c1:	89 e5                	mov    %esp,%ebp
	// used by readline
	return 1;
}
f01003c3:	b8 01 00 00 00       	mov    $0x1,%eax
f01003c8:	5d                   	pop    %ebp
f01003c9:	c3                   	ret    

f01003ca <cons_putc>:
}

// output a character to the console
static void
cons_putc(int c)
{
f01003ca:	55                   	push   %ebp
f01003cb:	89 e5                	mov    %esp,%ebp
f01003cd:	57                   	push   %edi
f01003ce:	56                   	push   %esi
f01003cf:	53                   	push   %ebx
f01003d0:	83 ec 2c             	sub    $0x2c,%esp
f01003d3:	89 c7                	mov    %eax,%edi
f01003d5:	ba fd 03 00 00       	mov    $0x3fd,%edx
f01003da:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003db:	a8 20                	test   $0x20,%al
f01003dd:	75 21                	jne    f0100400 <cons_putc+0x36>
f01003df:	bb 00 00 00 00       	mov    $0x0,%ebx
f01003e4:	be fd 03 00 00       	mov    $0x3fd,%esi
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();
f01003e9:	e8 e2 fe ff ff       	call   f01002d0 <delay>
f01003ee:	89 f2                	mov    %esi,%edx
f01003f0:	ec                   	in     (%dx),%al
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003f1:	a8 20                	test   $0x20,%al
f01003f3:	75 0b                	jne    f0100400 <cons_putc+0x36>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
f01003f5:	83 c3 01             	add    $0x1,%ebx
static void
serial_putc(int c)
{
	int i;

	for (i = 0;
f01003f8:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f01003fe:	75 e9                	jne    f01003e9 <cons_putc+0x1f>
	     !(inb(COM1 + COM_LSR) & COM_LSR_TXRDY) && i < 12800;
	     i++)
		delay();

	outb(COM1 + COM_TX, c);
f0100400:	89 fa                	mov    %edi,%edx
f0100402:	89 f8                	mov    %edi,%eax
f0100404:	88 55 e7             	mov    %dl,-0x19(%ebp)
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100407:	ba f8 03 00 00       	mov    $0x3f8,%edx
f010040c:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f010040d:	b2 79                	mov    $0x79,%dl
f010040f:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100410:	84 c0                	test   %al,%al
f0100412:	78 21                	js     f0100435 <cons_putc+0x6b>
f0100414:	bb 00 00 00 00       	mov    $0x0,%ebx
f0100419:	be 79 03 00 00       	mov    $0x379,%esi
		delay();
f010041e:	e8 ad fe ff ff       	call   f01002d0 <delay>
f0100423:	89 f2                	mov    %esi,%edx
f0100425:	ec                   	in     (%dx),%al
static void
lpt_putc(int c)
{
	int i;

	for (i = 0; !(inb(0x378+1) & 0x80) && i < 12800; i++)
f0100426:	84 c0                	test   %al,%al
f0100428:	78 0b                	js     f0100435 <cons_putc+0x6b>
f010042a:	83 c3 01             	add    $0x1,%ebx
f010042d:	81 fb 00 32 00 00    	cmp    $0x3200,%ebx
f0100433:	75 e9                	jne    f010041e <cons_putc+0x54>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100435:	ba 78 03 00 00       	mov    $0x378,%edx
f010043a:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
f010043e:	ee                   	out    %al,(%dx)
f010043f:	b2 7a                	mov    $0x7a,%dl
f0100441:	b8 0d 00 00 00       	mov    $0xd,%eax
f0100446:	ee                   	out    %al,(%dx)
f0100447:	b8 08 00 00 00       	mov    $0x8,%eax
f010044c:	ee                   	out    %al,(%dx)
static void
cga_putc(int c)
{
	// if no attribute given, then use black on white
	if (!(c & ~0xFF))
		c |= 0x0700;
f010044d:	89 f8                	mov    %edi,%eax
f010044f:	80 cc 07             	or     $0x7,%ah
f0100452:	f7 c7 00 ff ff ff    	test   $0xffffff00,%edi
f0100458:	0f 44 f8             	cmove  %eax,%edi

	switch (c & 0xff) {
f010045b:	89 f8                	mov    %edi,%eax
f010045d:	25 ff 00 00 00       	and    $0xff,%eax
f0100462:	83 f8 09             	cmp    $0x9,%eax
f0100465:	0f 84 89 00 00 00    	je     f01004f4 <cons_putc+0x12a>
f010046b:	83 f8 09             	cmp    $0x9,%eax
f010046e:	7f 12                	jg     f0100482 <cons_putc+0xb8>
f0100470:	83 f8 08             	cmp    $0x8,%eax
f0100473:	0f 85 af 00 00 00    	jne    f0100528 <cons_putc+0x15e>
f0100479:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
f0100480:	eb 18                	jmp    f010049a <cons_putc+0xd0>
f0100482:	83 f8 0a             	cmp    $0xa,%eax
f0100485:	8d 76 00             	lea    0x0(%esi),%esi
f0100488:	74 40                	je     f01004ca <cons_putc+0x100>
f010048a:	83 f8 0d             	cmp    $0xd,%eax
f010048d:	8d 76 00             	lea    0x0(%esi),%esi
f0100490:	0f 85 92 00 00 00    	jne    f0100528 <cons_putc+0x15e>
f0100496:	66 90                	xchg   %ax,%ax
f0100498:	eb 38                	jmp    f01004d2 <cons_putc+0x108>
	case '\b':
		if (crt_pos > 0) {
f010049a:	0f b7 05 10 30 22 f0 	movzwl 0xf0223010,%eax
f01004a1:	66 85 c0             	test   %ax,%ax
f01004a4:	0f 84 e8 00 00 00    	je     f0100592 <cons_putc+0x1c8>
			crt_pos--;
f01004aa:	83 e8 01             	sub    $0x1,%eax
f01004ad:	66 a3 10 30 22 f0    	mov    %ax,0xf0223010
			crt_buf[crt_pos] = (c & ~0xff) | ' ';
f01004b3:	0f b7 c0             	movzwl %ax,%eax
f01004b6:	66 81 e7 00 ff       	and    $0xff00,%di
f01004bb:	83 cf 20             	or     $0x20,%edi
f01004be:	8b 15 0c 30 22 f0    	mov    0xf022300c,%edx
f01004c4:	66 89 3c 42          	mov    %di,(%edx,%eax,2)
f01004c8:	eb 7b                	jmp    f0100545 <cons_putc+0x17b>
		}
		break;
	case '\n':
		crt_pos += CRT_COLS;
f01004ca:	66 83 05 10 30 22 f0 	addw   $0x50,0xf0223010
f01004d1:	50 
		/* fallthru */
	case '\r':
		crt_pos -= (crt_pos % CRT_COLS);
f01004d2:	0f b7 05 10 30 22 f0 	movzwl 0xf0223010,%eax
f01004d9:	69 c0 cd cc 00 00    	imul   $0xcccd,%eax,%eax
f01004df:	c1 e8 10             	shr    $0x10,%eax
f01004e2:	66 c1 e8 06          	shr    $0x6,%ax
f01004e6:	8d 04 80             	lea    (%eax,%eax,4),%eax
f01004e9:	c1 e0 04             	shl    $0x4,%eax
f01004ec:	66 a3 10 30 22 f0    	mov    %ax,0xf0223010
f01004f2:	eb 51                	jmp    f0100545 <cons_putc+0x17b>
		break;
	case '\t':
		cons_putc(' ');
f01004f4:	b8 20 00 00 00       	mov    $0x20,%eax
f01004f9:	e8 cc fe ff ff       	call   f01003ca <cons_putc>
		cons_putc(' ');
f01004fe:	b8 20 00 00 00       	mov    $0x20,%eax
f0100503:	e8 c2 fe ff ff       	call   f01003ca <cons_putc>
		cons_putc(' ');
f0100508:	b8 20 00 00 00       	mov    $0x20,%eax
f010050d:	e8 b8 fe ff ff       	call   f01003ca <cons_putc>
		cons_putc(' ');
f0100512:	b8 20 00 00 00       	mov    $0x20,%eax
f0100517:	e8 ae fe ff ff       	call   f01003ca <cons_putc>
		cons_putc(' ');
f010051c:	b8 20 00 00 00       	mov    $0x20,%eax
f0100521:	e8 a4 fe ff ff       	call   f01003ca <cons_putc>
f0100526:	eb 1d                	jmp    f0100545 <cons_putc+0x17b>
		break;
	default:
		crt_buf[crt_pos++] = c;		/* write the character */
f0100528:	0f b7 05 10 30 22 f0 	movzwl 0xf0223010,%eax
f010052f:	0f b7 c8             	movzwl %ax,%ecx
f0100532:	8b 15 0c 30 22 f0    	mov    0xf022300c,%edx
f0100538:	66 89 3c 4a          	mov    %di,(%edx,%ecx,2)
f010053c:	83 c0 01             	add    $0x1,%eax
f010053f:	66 a3 10 30 22 f0    	mov    %ax,0xf0223010
		break;
	}

	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
f0100545:	66 81 3d 10 30 22 f0 	cmpw   $0x7cf,0xf0223010
f010054c:	cf 07 
f010054e:	76 42                	jbe    f0100592 <cons_putc+0x1c8>
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
f0100550:	a1 0c 30 22 f0       	mov    0xf022300c,%eax
f0100555:	c7 44 24 08 00 0f 00 	movl   $0xf00,0x8(%esp)
f010055c:	00 
f010055d:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
f0100563:	89 54 24 04          	mov    %edx,0x4(%esp)
f0100567:	89 04 24             	mov    %eax,(%esp)
f010056a:	e8 76 52 00 00       	call   f01057e5 <memmove>
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
			crt_buf[i] = 0x0700 | ' ';
f010056f:	8b 15 0c 30 22 f0    	mov    0xf022300c,%edx
f0100575:	b8 80 07 00 00       	mov    $0x780,%eax
f010057a:	66 c7 04 42 20 07    	movw   $0x720,(%edx,%eax,2)
	// What is the purpose of this?
	if (crt_pos >= CRT_SIZE) {
		int i;

		memmove(crt_buf, crt_buf + CRT_COLS, (CRT_SIZE - CRT_COLS) * sizeof(uint16_t));
		for (i = CRT_SIZE - CRT_COLS; i < CRT_SIZE; i++)
f0100580:	83 c0 01             	add    $0x1,%eax
f0100583:	3d d0 07 00 00       	cmp    $0x7d0,%eax
f0100588:	75 f0                	jne    f010057a <cons_putc+0x1b0>
			crt_buf[i] = 0x0700 | ' ';
		crt_pos -= CRT_COLS;
f010058a:	66 83 2d 10 30 22 f0 	subw   $0x50,0xf0223010
f0100591:	50 
	}

	/* move that little blinky thing */
	outb(addr_6845, 14);
f0100592:	8b 0d 08 30 22 f0    	mov    0xf0223008,%ecx
f0100598:	89 cb                	mov    %ecx,%ebx
f010059a:	b8 0e 00 00 00       	mov    $0xe,%eax
f010059f:	89 ca                	mov    %ecx,%edx
f01005a1:	ee                   	out    %al,(%dx)
	outb(addr_6845 + 1, crt_pos >> 8);
f01005a2:	0f b7 35 10 30 22 f0 	movzwl 0xf0223010,%esi
f01005a9:	83 c1 01             	add    $0x1,%ecx
f01005ac:	89 f0                	mov    %esi,%eax
f01005ae:	66 c1 e8 08          	shr    $0x8,%ax
f01005b2:	89 ca                	mov    %ecx,%edx
f01005b4:	ee                   	out    %al,(%dx)
f01005b5:	b8 0f 00 00 00       	mov    $0xf,%eax
f01005ba:	89 da                	mov    %ebx,%edx
f01005bc:	ee                   	out    %al,(%dx)
f01005bd:	89 f0                	mov    %esi,%eax
f01005bf:	89 ca                	mov    %ecx,%edx
f01005c1:	ee                   	out    %al,(%dx)
cons_putc(int c)
{
	serial_putc(c);
	lpt_putc(c);
	cga_putc(c);
}
f01005c2:	83 c4 2c             	add    $0x2c,%esp
f01005c5:	5b                   	pop    %ebx
f01005c6:	5e                   	pop    %esi
f01005c7:	5f                   	pop    %edi
f01005c8:	5d                   	pop    %ebp
f01005c9:	c3                   	ret    

f01005ca <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01005ca:	55                   	push   %ebp
f01005cb:	89 e5                	mov    %esp,%ebp
f01005cd:	83 ec 08             	sub    $0x8,%esp
	cons_putc(c);
f01005d0:	8b 45 08             	mov    0x8(%ebp),%eax
f01005d3:	e8 f2 fd ff ff       	call   f01003ca <cons_putc>
}
f01005d8:	c9                   	leave  
f01005d9:	c3                   	ret    

f01005da <kbd_proc_data>:
 * Get data from the keyboard.  If we finish a character, return it.  Else 0.
 * Return -1 if no data.
 */
static int
kbd_proc_data(void)
{
f01005da:	55                   	push   %ebp
f01005db:	89 e5                	mov    %esp,%ebp
f01005dd:	53                   	push   %ebx
f01005de:	83 ec 14             	sub    $0x14,%esp

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01005e1:	ba 64 00 00 00       	mov    $0x64,%edx
f01005e6:	ec                   	in     (%dx),%al
	int c;
	uint8_t data;
	static uint32_t shift;

	if ((inb(KBSTATP) & KBS_DIB) == 0)
f01005e7:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
f01005ec:	a8 01                	test   $0x1,%al
f01005ee:	0f 84 dd 00 00 00    	je     f01006d1 <kbd_proc_data+0xf7>
f01005f4:	b2 60                	mov    $0x60,%dl
f01005f6:	ec                   	in     (%dx),%al
		return -1;

	data = inb(KBDATAP);

	if (data == 0xE0) {
f01005f7:	3c e0                	cmp    $0xe0,%al
f01005f9:	75 11                	jne    f010060c <kbd_proc_data+0x32>
		// E0 escape character
		shift |= E0ESC;
f01005fb:	83 0d 00 30 22 f0 40 	orl    $0x40,0xf0223000
f0100602:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100607:	e9 c5 00 00 00       	jmp    f01006d1 <kbd_proc_data+0xf7>
	} else if (data & 0x80) {
f010060c:	84 c0                	test   %al,%al
f010060e:	79 35                	jns    f0100645 <kbd_proc_data+0x6b>
		// Key released
		data = (shift & E0ESC ? data : data & 0x7F);
f0100610:	8b 15 00 30 22 f0    	mov    0xf0223000,%edx
f0100616:	89 c1                	mov    %eax,%ecx
f0100618:	83 e1 7f             	and    $0x7f,%ecx
f010061b:	f6 c2 40             	test   $0x40,%dl
f010061e:	0f 44 c1             	cmove  %ecx,%eax
		shift &= ~(shiftcode[data] | E0ESC);
f0100621:	0f b6 c0             	movzbl %al,%eax
f0100624:	0f b6 80 60 66 10 f0 	movzbl -0xfef99a0(%eax),%eax
f010062b:	83 c8 40             	or     $0x40,%eax
f010062e:	0f b6 c0             	movzbl %al,%eax
f0100631:	f7 d0                	not    %eax
f0100633:	21 c2                	and    %eax,%edx
f0100635:	89 15 00 30 22 f0    	mov    %edx,0xf0223000
f010063b:	bb 00 00 00 00       	mov    $0x0,%ebx
		return 0;
f0100640:	e9 8c 00 00 00       	jmp    f01006d1 <kbd_proc_data+0xf7>
	} else if (shift & E0ESC) {
f0100645:	8b 15 00 30 22 f0    	mov    0xf0223000,%edx
f010064b:	f6 c2 40             	test   $0x40,%dl
f010064e:	74 0c                	je     f010065c <kbd_proc_data+0x82>
		// Last character was an E0 escape; or with 0x80
		data |= 0x80;
f0100650:	83 c8 80             	or     $0xffffff80,%eax
		shift &= ~E0ESC;
f0100653:	83 e2 bf             	and    $0xffffffbf,%edx
f0100656:	89 15 00 30 22 f0    	mov    %edx,0xf0223000
	}

	shift |= shiftcode[data];
f010065c:	0f b6 c0             	movzbl %al,%eax
	shift ^= togglecode[data];
f010065f:	0f b6 90 60 66 10 f0 	movzbl -0xfef99a0(%eax),%edx
f0100666:	0b 15 00 30 22 f0    	or     0xf0223000,%edx
f010066c:	0f b6 88 60 67 10 f0 	movzbl -0xfef98a0(%eax),%ecx
f0100673:	31 ca                	xor    %ecx,%edx
f0100675:	89 15 00 30 22 f0    	mov    %edx,0xf0223000

	c = charcode[shift & (CTL | SHIFT)][data];
f010067b:	89 d1                	mov    %edx,%ecx
f010067d:	83 e1 03             	and    $0x3,%ecx
f0100680:	8b 0c 8d 60 68 10 f0 	mov    -0xfef97a0(,%ecx,4),%ecx
f0100687:	0f b6 1c 01          	movzbl (%ecx,%eax,1),%ebx
	if (shift & CAPSLOCK) {
f010068b:	f6 c2 08             	test   $0x8,%dl
f010068e:	74 1b                	je     f01006ab <kbd_proc_data+0xd1>
		if ('a' <= c && c <= 'z')
f0100690:	89 d9                	mov    %ebx,%ecx
f0100692:	8d 43 9f             	lea    -0x61(%ebx),%eax
f0100695:	83 f8 19             	cmp    $0x19,%eax
f0100698:	77 05                	ja     f010069f <kbd_proc_data+0xc5>
			c += 'A' - 'a';
f010069a:	83 eb 20             	sub    $0x20,%ebx
f010069d:	eb 0c                	jmp    f01006ab <kbd_proc_data+0xd1>
		else if ('A' <= c && c <= 'Z')
f010069f:	83 e9 41             	sub    $0x41,%ecx
			c += 'a' - 'A';
f01006a2:	8d 43 20             	lea    0x20(%ebx),%eax
f01006a5:	83 f9 19             	cmp    $0x19,%ecx
f01006a8:	0f 46 d8             	cmovbe %eax,%ebx
	}

	// Process special keys
	// Ctrl-Alt-Del: reboot
	if (!(~shift & (CTL | ALT)) && c == KEY_DEL) {
f01006ab:	f7 d2                	not    %edx
f01006ad:	f6 c2 06             	test   $0x6,%dl
f01006b0:	75 1f                	jne    f01006d1 <kbd_proc_data+0xf7>
f01006b2:	81 fb e9 00 00 00    	cmp    $0xe9,%ebx
f01006b8:	75 17                	jne    f01006d1 <kbd_proc_data+0xf7>
		cprintf("Rebooting!\n");
f01006ba:	c7 04 24 23 66 10 f0 	movl   $0xf0106623,(%esp)
f01006c1:	e8 63 38 00 00       	call   f0103f29 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f01006c6:	ba 92 00 00 00       	mov    $0x92,%edx
f01006cb:	b8 03 00 00 00       	mov    $0x3,%eax
f01006d0:	ee                   	out    %al,(%dx)
		outb(0x92, 0x3); // courtesy of Chris Frost
	}

	return c;
}
f01006d1:	89 d8                	mov    %ebx,%eax
f01006d3:	83 c4 14             	add    $0x14,%esp
f01006d6:	5b                   	pop    %ebx
f01006d7:	5d                   	pop    %ebp
f01006d8:	c3                   	ret    

f01006d9 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f01006d9:	55                   	push   %ebp
f01006da:	89 e5                	mov    %esp,%ebp
f01006dc:	57                   	push   %edi
f01006dd:	56                   	push   %esi
f01006de:	53                   	push   %ebx
f01006df:	83 ec 1c             	sub    $0x1c,%esp
	volatile uint16_t *cp;
	uint16_t was;
	unsigned pos;

	cp = (uint16_t*) (KERNBASE + CGA_BUF);
	was = *cp;
f01006e2:	b8 00 80 0b f0       	mov    $0xf00b8000,%eax
f01006e7:	0f b7 10             	movzwl (%eax),%edx
	*cp = (uint16_t) 0xA55A;
f01006ea:	66 c7 00 5a a5       	movw   $0xa55a,(%eax)
	if (*cp != 0xA55A) {
f01006ef:	0f b7 00             	movzwl (%eax),%eax
f01006f2:	66 3d 5a a5          	cmp    $0xa55a,%ax
f01006f6:	74 11                	je     f0100709 <cons_init+0x30>
		cp = (uint16_t*) (KERNBASE + MONO_BUF);
		addr_6845 = MONO_BASE;
f01006f8:	c7 05 08 30 22 f0 b4 	movl   $0x3b4,0xf0223008
f01006ff:	03 00 00 
f0100702:	be 00 00 0b f0       	mov    $0xf00b0000,%esi
f0100707:	eb 16                	jmp    f010071f <cons_init+0x46>
	} else {
		*cp = was;
f0100709:	66 89 15 00 80 0b f0 	mov    %dx,0xf00b8000
		addr_6845 = CGA_BASE;
f0100710:	c7 05 08 30 22 f0 d4 	movl   $0x3d4,0xf0223008
f0100717:	03 00 00 
f010071a:	be 00 80 0b f0       	mov    $0xf00b8000,%esi
	}

	/* Extract cursor location */
	outb(addr_6845, 14);
f010071f:	8b 0d 08 30 22 f0    	mov    0xf0223008,%ecx
f0100725:	89 cb                	mov    %ecx,%ebx
f0100727:	b8 0e 00 00 00       	mov    $0xe,%eax
f010072c:	89 ca                	mov    %ecx,%edx
f010072e:	ee                   	out    %al,(%dx)
	pos = inb(addr_6845 + 1) << 8;
f010072f:	83 c1 01             	add    $0x1,%ecx

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100732:	89 ca                	mov    %ecx,%edx
f0100734:	ec                   	in     (%dx),%al
f0100735:	0f b6 f8             	movzbl %al,%edi
f0100738:	c1 e7 08             	shl    $0x8,%edi
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f010073b:	b8 0f 00 00 00       	mov    $0xf,%eax
f0100740:	89 da                	mov    %ebx,%edx
f0100742:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0100743:	89 ca                	mov    %ecx,%edx
f0100745:	ec                   	in     (%dx),%al
	outb(addr_6845, 15);
	pos |= inb(addr_6845 + 1);

	crt_buf = (uint16_t*) cp;
f0100746:	89 35 0c 30 22 f0    	mov    %esi,0xf022300c
	crt_pos = pos;
f010074c:	0f b6 c8             	movzbl %al,%ecx
f010074f:	09 cf                	or     %ecx,%edi
f0100751:	66 89 3d 10 30 22 f0 	mov    %di,0xf0223010

static void
kbd_init(void)
{
	// Drain the kbd buffer so that Bochs generates interrupts.
	kbd_intr();
f0100758:	e8 e2 fb ff ff       	call   f010033f <kbd_intr>
	irq_setmask_8259A(irq_mask_8259A & ~(1<<1));
f010075d:	0f b7 05 8e 03 12 f0 	movzwl 0xf012038e,%eax
f0100764:	25 fd ff 00 00       	and    $0xfffd,%eax
f0100769:	89 04 24             	mov    %eax,(%esp)
f010076c:	e8 8b 36 00 00       	call   f0103dfc <irq_setmask_8259A>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0100771:	bb fa 03 00 00       	mov    $0x3fa,%ebx
f0100776:	b8 00 00 00 00       	mov    $0x0,%eax
f010077b:	89 da                	mov    %ebx,%edx
f010077d:	ee                   	out    %al,(%dx)
f010077e:	b2 fb                	mov    $0xfb,%dl
f0100780:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
f0100785:	ee                   	out    %al,(%dx)
f0100786:	b9 f8 03 00 00       	mov    $0x3f8,%ecx
f010078b:	b8 0c 00 00 00       	mov    $0xc,%eax
f0100790:	89 ca                	mov    %ecx,%edx
f0100792:	ee                   	out    %al,(%dx)
f0100793:	b2 f9                	mov    $0xf9,%dl
f0100795:	b8 00 00 00 00       	mov    $0x0,%eax
f010079a:	ee                   	out    %al,(%dx)
f010079b:	b2 fb                	mov    $0xfb,%dl
f010079d:	b8 03 00 00 00       	mov    $0x3,%eax
f01007a2:	ee                   	out    %al,(%dx)
f01007a3:	b2 fc                	mov    $0xfc,%dl
f01007a5:	b8 00 00 00 00       	mov    $0x0,%eax
f01007aa:	ee                   	out    %al,(%dx)
f01007ab:	b2 f9                	mov    $0xf9,%dl
f01007ad:	b8 01 00 00 00       	mov    $0x1,%eax
f01007b2:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f01007b3:	b2 fd                	mov    $0xfd,%dl
f01007b5:	ec                   	in     (%dx),%al
	// Enable rcv interrupts
	outb(COM1+COM_IER, COM_IER_RDI);

	// Clear any preexisting overrun indications and interrupts
	// Serial port doesn't exist if COM_LSR returns 0xFF
	serial_exists = (inb(COM1+COM_LSR) != 0xFF);
f01007b6:	3c ff                	cmp    $0xff,%al
f01007b8:	0f 95 c0             	setne  %al
f01007bb:	89 c6                	mov    %eax,%esi
f01007bd:	a2 04 30 22 f0       	mov    %al,0xf0223004
f01007c2:	89 da                	mov    %ebx,%edx
f01007c4:	ec                   	in     (%dx),%al
f01007c5:	89 ca                	mov    %ecx,%edx
f01007c7:	ec                   	in     (%dx),%al
{
	cga_init();
	kbd_init();
	serial_init();

	if (!serial_exists)
f01007c8:	89 f0                	mov    %esi,%eax
f01007ca:	84 c0                	test   %al,%al
f01007cc:	75 0c                	jne    f01007da <cons_init+0x101>
		cprintf("Serial port does not exist!\n");
f01007ce:	c7 04 24 2f 66 10 f0 	movl   $0xf010662f,(%esp)
f01007d5:	e8 4f 37 00 00       	call   f0103f29 <cprintf>
}
f01007da:	83 c4 1c             	add    $0x1c,%esp
f01007dd:	5b                   	pop    %ebx
f01007de:	5e                   	pop    %esi
f01007df:	5f                   	pop    %edi
f01007e0:	5d                   	pop    %ebp
f01007e1:	c3                   	ret    
f01007e2:	66 90                	xchg   %ax,%ax
f01007e4:	66 90                	xchg   %ax,%ax
f01007e6:	66 90                	xchg   %ax,%ax
f01007e8:	66 90                	xchg   %ax,%ax
f01007ea:	66 90                	xchg   %ax,%ax
f01007ec:	66 90                	xchg   %ax,%ax
f01007ee:	66 90                	xchg   %ax,%ax

f01007f0 <mon_kerninfo>:
	return 0;
}

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f01007f0:	55                   	push   %ebp
f01007f1:	89 e5                	mov    %esp,%ebp
f01007f3:	83 ec 18             	sub    $0x18,%esp
	extern char _start[], entry[], etext[], edata[], end[];

	cprintf("Special kernel symbols:\n");
f01007f6:	c7 04 24 70 68 10 f0 	movl   $0xf0106870,(%esp)
f01007fd:	e8 27 37 00 00       	call   f0103f29 <cprintf>
	cprintf("  _start                  %08x (phys)\n", _start);
f0100802:	c7 44 24 04 0c 00 10 	movl   $0x10000c,0x4(%esp)
f0100809:	00 
f010080a:	c7 04 24 38 69 10 f0 	movl   $0xf0106938,(%esp)
f0100811:	e8 13 37 00 00       	call   f0103f29 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f0100816:	c7 44 24 08 0c 00 10 	movl   $0x10000c,0x8(%esp)
f010081d:	00 
f010081e:	c7 44 24 04 0c 00 10 	movl   $0xf010000c,0x4(%esp)
f0100825:	f0 
f0100826:	c7 04 24 60 69 10 f0 	movl   $0xf0106960,(%esp)
f010082d:	e8 f7 36 00 00       	call   f0103f29 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f0100832:	c7 44 24 08 45 65 10 	movl   $0x106545,0x8(%esp)
f0100839:	00 
f010083a:	c7 44 24 04 45 65 10 	movl   $0xf0106545,0x4(%esp)
f0100841:	f0 
f0100842:	c7 04 24 84 69 10 f0 	movl   $0xf0106984,(%esp)
f0100849:	e8 db 36 00 00       	call   f0103f29 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f010084e:	c7 44 24 08 00 22 22 	movl   $0x222200,0x8(%esp)
f0100855:	00 
f0100856:	c7 44 24 04 00 22 22 	movl   $0xf0222200,0x4(%esp)
f010085d:	f0 
f010085e:	c7 04 24 a8 69 10 f0 	movl   $0xf01069a8,(%esp)
f0100865:	e8 bf 36 00 00       	call   f0103f29 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f010086a:	c7 44 24 08 08 50 26 	movl   $0x265008,0x8(%esp)
f0100871:	00 
f0100872:	c7 44 24 04 08 50 26 	movl   $0xf0265008,0x4(%esp)
f0100879:	f0 
f010087a:	c7 04 24 cc 69 10 f0 	movl   $0xf01069cc,(%esp)
f0100881:	e8 a3 36 00 00       	call   f0103f29 <cprintf>
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100886:	b8 07 54 26 f0       	mov    $0xf0265407,%eax
f010088b:	2d 0c 00 10 f0       	sub    $0xf010000c,%eax
	cprintf("  _start                  %08x (phys)\n", _start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100890:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0100895:	8d 90 ff 03 00 00    	lea    0x3ff(%eax),%edx
f010089b:	85 c0                	test   %eax,%eax
f010089d:	0f 48 c2             	cmovs  %edx,%eax
f01008a0:	c1 f8 0a             	sar    $0xa,%eax
f01008a3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008a7:	c7 04 24 f0 69 10 f0 	movl   $0xf01069f0,(%esp)
f01008ae:	e8 76 36 00 00       	call   f0103f29 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f01008b3:	b8 00 00 00 00       	mov    $0x0,%eax
f01008b8:	c9                   	leave  
f01008b9:	c3                   	ret    

f01008ba <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f01008ba:	55                   	push   %ebp
f01008bb:	89 e5                	mov    %esp,%ebp
f01008bd:	83 ec 18             	sub    $0x18,%esp
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f01008c0:	a1 c4 6a 10 f0       	mov    0xf0106ac4,%eax
f01008c5:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008c9:	a1 c0 6a 10 f0       	mov    0xf0106ac0,%eax
f01008ce:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008d2:	c7 04 24 89 68 10 f0 	movl   $0xf0106889,(%esp)
f01008d9:	e8 4b 36 00 00       	call   f0103f29 <cprintf>
f01008de:	a1 d0 6a 10 f0       	mov    0xf0106ad0,%eax
f01008e3:	89 44 24 08          	mov    %eax,0x8(%esp)
f01008e7:	a1 cc 6a 10 f0       	mov    0xf0106acc,%eax
f01008ec:	89 44 24 04          	mov    %eax,0x4(%esp)
f01008f0:	c7 04 24 89 68 10 f0 	movl   $0xf0106889,(%esp)
f01008f7:	e8 2d 36 00 00       	call   f0103f29 <cprintf>
f01008fc:	a1 dc 6a 10 f0       	mov    0xf0106adc,%eax
f0100901:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100905:	a1 d8 6a 10 f0       	mov    0xf0106ad8,%eax
f010090a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010090e:	c7 04 24 89 68 10 f0 	movl   $0xf0106889,(%esp)
f0100915:	e8 0f 36 00 00       	call   f0103f29 <cprintf>
	return 0;
}
f010091a:	b8 00 00 00 00       	mov    $0x0,%eax
f010091f:	c9                   	leave  
f0100920:	c3                   	ret    

f0100921 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100921:	55                   	push   %ebp
f0100922:	89 e5                	mov    %esp,%ebp
f0100924:	57                   	push   %edi
f0100925:	56                   	push   %esi
f0100926:	53                   	push   %ebx
f0100927:	83 ec 5c             	sub    $0x5c,%esp
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f010092a:	c7 04 24 1c 6a 10 f0 	movl   $0xf0106a1c,(%esp)
f0100931:	e8 f3 35 00 00       	call   f0103f29 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f0100936:	c7 04 24 40 6a 10 f0 	movl   $0xf0106a40,(%esp)
f010093d:	e8 e7 35 00 00       	call   f0103f29 <cprintf>

	if (tf != NULL)
f0100942:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
f0100946:	74 0b                	je     f0100953 <monitor+0x32>
		print_trapframe(tf);
f0100948:	8b 45 08             	mov    0x8(%ebp),%eax
f010094b:	89 04 24             	mov    %eax,(%esp)
f010094e:	e8 4c 3a 00 00       	call   f010439f <print_trapframe>

	while (1) {
		buf = readline("K> ");
f0100953:	c7 04 24 92 68 10 f0 	movl   $0xf0106892,(%esp)
f010095a:	e8 71 4b 00 00       	call   f01054d0 <readline>
f010095f:	89 c3                	mov    %eax,%ebx
		if (buf != NULL)
f0100961:	85 c0                	test   %eax,%eax
f0100963:	74 ee                	je     f0100953 <monitor+0x32>
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f0100965:	c7 45 a8 00 00 00 00 	movl   $0x0,-0x58(%ebp)
f010096c:	be 00 00 00 00       	mov    $0x0,%esi
f0100971:	eb 06                	jmp    f0100979 <monitor+0x58>
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100973:	c6 03 00             	movb   $0x0,(%ebx)
f0100976:	83 c3 01             	add    $0x1,%ebx
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100979:	0f b6 03             	movzbl (%ebx),%eax
f010097c:	84 c0                	test   %al,%al
f010097e:	74 6b                	je     f01009eb <monitor+0xca>
f0100980:	0f be c0             	movsbl %al,%eax
f0100983:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100987:	c7 04 24 96 68 10 f0 	movl   $0xf0106896,(%esp)
f010098e:	e8 98 4d 00 00       	call   f010572b <strchr>
f0100993:	85 c0                	test   %eax,%eax
f0100995:	75 dc                	jne    f0100973 <monitor+0x52>
			*buf++ = 0;
		if (*buf == 0)
f0100997:	80 3b 00             	cmpb   $0x0,(%ebx)
f010099a:	74 4f                	je     f01009eb <monitor+0xca>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f010099c:	83 fe 0f             	cmp    $0xf,%esi
f010099f:	90                   	nop
f01009a0:	75 16                	jne    f01009b8 <monitor+0x97>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f01009a2:	c7 44 24 04 10 00 00 	movl   $0x10,0x4(%esp)
f01009a9:	00 
f01009aa:	c7 04 24 9b 68 10 f0 	movl   $0xf010689b,(%esp)
f01009b1:	e8 73 35 00 00       	call   f0103f29 <cprintf>
f01009b6:	eb 9b                	jmp    f0100953 <monitor+0x32>
			return 0;
		}
		argv[argc++] = buf;
f01009b8:	89 5c b5 a8          	mov    %ebx,-0x58(%ebp,%esi,4)
f01009bc:	83 c6 01             	add    $0x1,%esi
		while (*buf && !strchr(WHITESPACE, *buf))
f01009bf:	0f b6 03             	movzbl (%ebx),%eax
f01009c2:	84 c0                	test   %al,%al
f01009c4:	75 0c                	jne    f01009d2 <monitor+0xb1>
f01009c6:	eb b1                	jmp    f0100979 <monitor+0x58>
			buf++;
f01009c8:	83 c3 01             	add    $0x1,%ebx
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01009cb:	0f b6 03             	movzbl (%ebx),%eax
f01009ce:	84 c0                	test   %al,%al
f01009d0:	74 a7                	je     f0100979 <monitor+0x58>
f01009d2:	0f be c0             	movsbl %al,%eax
f01009d5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01009d9:	c7 04 24 96 68 10 f0 	movl   $0xf0106896,(%esp)
f01009e0:	e8 46 4d 00 00       	call   f010572b <strchr>
f01009e5:	85 c0                	test   %eax,%eax
f01009e7:	74 df                	je     f01009c8 <monitor+0xa7>
f01009e9:	eb 8e                	jmp    f0100979 <monitor+0x58>
			buf++;
	}
	argv[argc] = 0;
f01009eb:	c7 44 b5 a8 00 00 00 	movl   $0x0,-0x58(%ebp,%esi,4)
f01009f2:	00 

	// Lookup and invoke the command
	if (argc == 0)
f01009f3:	85 f6                	test   %esi,%esi
f01009f5:	0f 84 58 ff ff ff    	je     f0100953 <monitor+0x32>
f01009fb:	bb c0 6a 10 f0       	mov    $0xf0106ac0,%ebx
f0100a00:	bf 00 00 00 00       	mov    $0x0,%edi
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f0100a05:	8b 03                	mov    (%ebx),%eax
f0100a07:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a0b:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a0e:	89 04 24             	mov    %eax,(%esp)
f0100a11:	e8 9f 4c 00 00       	call   f01056b5 <strcmp>
f0100a16:	85 c0                	test   %eax,%eax
f0100a18:	75 23                	jne    f0100a3d <monitor+0x11c>
			return commands[i].func(argc, argv, tf);
f0100a1a:	6b ff 0c             	imul   $0xc,%edi,%edi
f0100a1d:	8b 45 08             	mov    0x8(%ebp),%eax
f0100a20:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100a24:	8d 45 a8             	lea    -0x58(%ebp),%eax
f0100a27:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a2b:	89 34 24             	mov    %esi,(%esp)
f0100a2e:	ff 97 c8 6a 10 f0    	call   *-0xfef9538(%edi)
		print_trapframe(tf);

	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f0100a34:	85 c0                	test   %eax,%eax
f0100a36:	78 28                	js     f0100a60 <monitor+0x13f>
f0100a38:	e9 16 ff ff ff       	jmp    f0100953 <monitor+0x32>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f0100a3d:	83 c7 01             	add    $0x1,%edi
f0100a40:	83 c3 0c             	add    $0xc,%ebx
f0100a43:	83 ff 03             	cmp    $0x3,%edi
f0100a46:	75 bd                	jne    f0100a05 <monitor+0xe4>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f0100a48:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0100a4b:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100a4f:	c7 04 24 b8 68 10 f0 	movl   $0xf01068b8,(%esp)
f0100a56:	e8 ce 34 00 00       	call   f0103f29 <cprintf>
f0100a5b:	e9 f3 fe ff ff       	jmp    f0100953 <monitor+0x32>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f0100a60:	83 c4 5c             	add    $0x5c,%esp
f0100a63:	5b                   	pop    %ebx
f0100a64:	5e                   	pop    %esi
f0100a65:	5f                   	pop    %edi
f0100a66:	5d                   	pop    %ebp
f0100a67:	c3                   	ret    

f0100a68 <mon_backtrace>:
	return 0;
}

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f0100a68:	55                   	push   %ebp
f0100a69:	89 e5                	mov    %esp,%ebp
f0100a6b:	57                   	push   %edi
f0100a6c:	56                   	push   %esi
f0100a6d:	53                   	push   %ebx
f0100a6e:	83 ec 3c             	sub    $0x3c,%esp

static __inline uint32_t
read_ebp(void)
{
	uint32_t ebp;
	__asm __volatile("movl %%ebp,%0" : "=r" (ebp));
f0100a71:	89 ee                	mov    %ebp,%esi
	uint32_t ebp,eip;
	struct Eipdebuginfo info;
	int i=0;

	ebp=read_ebp();
	while(ebp != 0) {
f0100a73:	85 f6                	test   %esi,%esi
f0100a75:	0f 84 8f 00 00 00    	je     f0100b0a <mon_backtrace+0xa2>
		eip = *((uint32_t *)(ebp+4));
		// change ip to addr
		// debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
		debuginfo_eip((uintptr_t)eip,&info);
f0100a7b:	8d 7d d0             	lea    -0x30(%ebp),%edi
	struct Eipdebuginfo info;
	int i=0;

	ebp=read_ebp();
	while(ebp != 0) {
		eip = *((uint32_t *)(ebp+4));
f0100a7e:	8b 5e 04             	mov    0x4(%esi),%ebx
		// change ip to addr
		// debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
		debuginfo_eip((uintptr_t)eip,&info);
f0100a81:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0100a85:	89 1c 24             	mov    %ebx,(%esp)
f0100a88:	e8 51 41 00 00       	call   f0104bde <debuginfo_eip>
		cprintf("ebp %0x eip %0x ",ebp,eip);
f0100a8d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0100a91:	89 74 24 04          	mov    %esi,0x4(%esp)
f0100a95:	c7 04 24 ce 68 10 f0 	movl   $0xf01068ce,(%esp)
f0100a9c:	e8 88 34 00 00       	call   f0103f29 <cprintf>
		cprintf("args ");
f0100aa1:	c7 04 24 df 68 10 f0 	movl   $0xf01068df,(%esp)
f0100aa8:	e8 7c 34 00 00       	call   f0103f29 <cprintf>
f0100aad:	bb 00 00 00 00       	mov    $0x0,%ebx
		for(i=0;i<=4;i++)
			cprintf("%0x ",*(uint32_t *)(ebp+8+4*i));
f0100ab2:	8b 44 9e 08          	mov    0x8(%esi,%ebx,4),%eax
f0100ab6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100aba:	c7 04 24 da 68 10 f0 	movl   $0xf01068da,(%esp)
f0100ac1:	e8 63 34 00 00       	call   f0103f29 <cprintf>
		// change ip to addr
		// debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
		debuginfo_eip((uintptr_t)eip,&info);
		cprintf("ebp %0x eip %0x ",ebp,eip);
		cprintf("args ");
		for(i=0;i<=4;i++)
f0100ac6:	83 c3 01             	add    $0x1,%ebx
f0100ac9:	83 fb 05             	cmp    $0x5,%ebx
f0100acc:	75 e4                	jne    f0100ab2 <mon_backtrace+0x4a>
			cprintf("%0x ",*(uint32_t *)(ebp+8+4*i));
		cprintf("\n");
f0100ace:	c7 04 24 18 77 10 f0 	movl   $0xf0107718,(%esp)
f0100ad5:	e8 4f 34 00 00       	call   f0103f29 <cprintf>
		cprintf("	eipfile: %s	eipfunc: %s ",info.eip_file,info.eip_fn_name);
f0100ada:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100add:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ae1:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0100ae4:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100ae8:	c7 04 24 e5 68 10 f0 	movl   $0xf01068e5,(%esp)
f0100aef:	e8 35 34 00 00       	call   f0103f29 <cprintf>
		cprintf("\n");
f0100af4:	c7 04 24 18 77 10 f0 	movl   $0xf0107718,(%esp)
f0100afb:	e8 29 34 00 00       	call   f0103f29 <cprintf>
		ebp=*((uint32_t *)ebp);
f0100b00:	8b 36                	mov    (%esi),%esi
	uint32_t ebp,eip;
	struct Eipdebuginfo info;
	int i=0;

	ebp=read_ebp();
	while(ebp != 0) {
f0100b02:	85 f6                	test   %esi,%esi
f0100b04:	0f 85 74 ff ff ff    	jne    f0100a7e <mon_backtrace+0x16>
		cprintf("	eipfile: %s	eipfunc: %s ",info.eip_file,info.eip_fn_name);
		cprintf("\n");
		ebp=*((uint32_t *)ebp);
	}
	return 0;
}
f0100b0a:	b8 00 00 00 00       	mov    $0x0,%eax
f0100b0f:	83 c4 3c             	add    $0x3c,%esp
f0100b12:	5b                   	pop    %ebx
f0100b13:	5e                   	pop    %esi
f0100b14:	5f                   	pop    %edi
f0100b15:	5d                   	pop    %ebp
f0100b16:	c3                   	ret    
f0100b17:	66 90                	xchg   %ax,%ax
f0100b19:	66 90                	xchg   %ax,%ax
f0100b1b:	66 90                	xchg   %ax,%ax
f0100b1d:	66 90                	xchg   %ax,%ax
f0100b1f:	90                   	nop

f0100b20 <boot_alloc>:
// If we're out of memory, boot_alloc should panic.
// This function may ONLY be used during initialization,
// before the page_free_list list has been set up.
static void *
boot_alloc(uint32_t n)
{
f0100b20:	55                   	push   %ebp
f0100b21:	89 e5                	mov    %esp,%ebp
	// Initialize nextfree if this is the first time.
	// 'end' is a magic symbol automatically generated by the linker,
	// which points to the end of the kernel's bss segment:
	// the first virtual address that the linker did *not* assign
	// to any kernel code or global variables.
	if (!nextfree) {
f0100b23:	83 3d 28 32 22 f0 00 	cmpl   $0x0,0xf0223228
f0100b2a:	75 11                	jne    f0100b3d <boot_alloc+0x1d>
		extern char end[];
		nextfree = ROUNDUP((char *) end, PGSIZE);
f0100b2c:	ba 07 60 26 f0       	mov    $0xf0266007,%edx
f0100b31:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0100b37:	89 15 28 32 22 f0    	mov    %edx,0xf0223228
	// Allocate a chunk large enough to hold 'n' bytes, then update
	// nextfree.  Make sure nextfree is kept aligned
	// to a multiple of PGSIZE.
	//
	// LAB 2: Your code here.
	if(n > 0) {
f0100b3d:	85 c0                	test   %eax,%eax
f0100b3f:	74 1b                	je     f0100b5c <boot_alloc+0x3c>
		result = nextfree;
f0100b41:	8b 15 28 32 22 f0    	mov    0xf0223228,%edx
		nextfree = nextfree+n;
		nextfree = ROUNDUP((char *) nextfree, PGSIZE);
f0100b47:	8d 84 02 ff 0f 00 00 	lea    0xfff(%edx,%eax,1),%eax
f0100b4e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100b53:	a3 28 32 22 f0       	mov    %eax,0xf0223228
f0100b58:	89 d0                	mov    %edx,%eax
		return result;
f0100b5a:	eb 05                	jmp    f0100b61 <boot_alloc+0x41>
	}
	if(n == 0) {
		return nextfree;
f0100b5c:	a1 28 32 22 f0       	mov    0xf0223228,%eax
	}
	return NULL;
}
f0100b61:	5d                   	pop    %ebp
f0100b62:	c3                   	ret    

f0100b63 <page_free>:
// Return a page to the free list.
// (This function should only be called when pp->pp_ref reaches 0.)
//
void
page_free(struct PageInfo *pp)
{
f0100b63:	55                   	push   %ebp
f0100b64:	89 e5                	mov    %esp,%ebp
f0100b66:	8b 45 08             	mov    0x8(%ebp),%eax
	// Fill this function in
	if(pp->pp_ref == 0) {
f0100b69:	66 83 78 04 00       	cmpw   $0x0,0x4(%eax)
f0100b6e:	75 0d                	jne    f0100b7d <page_free+0x1a>
		pp->pp_link=page_free_list;
f0100b70:	8b 15 30 32 22 f0    	mov    0xf0223230,%edx
f0100b76:	89 10                	mov    %edx,(%eax)
		page_free_list=pp;
f0100b78:	a3 30 32 22 f0       	mov    %eax,0xf0223230
	}
}
f0100b7d:	5d                   	pop    %ebp
f0100b7e:	c3                   	ret    

f0100b7f <page_decref>:
// Decrement the reference count on a page,
// freeing it if there are no more refs.
//
void
page_decref(struct PageInfo* pp)
{	
f0100b7f:	55                   	push   %ebp
f0100b80:	89 e5                	mov    %esp,%ebp
f0100b82:	83 ec 04             	sub    $0x4,%esp
f0100b85:	8b 45 08             	mov    0x8(%ebp),%eax
	
	if (--pp->pp_ref == 0)
f0100b88:	0f b7 50 04          	movzwl 0x4(%eax),%edx
f0100b8c:	83 ea 01             	sub    $0x1,%edx
f0100b8f:	66 89 50 04          	mov    %dx,0x4(%eax)
f0100b93:	66 85 d2             	test   %dx,%dx
f0100b96:	75 08                	jne    f0100ba0 <page_decref+0x21>
		page_free(pp);
f0100b98:	89 04 24             	mov    %eax,(%esp)
f0100b9b:	e8 c3 ff ff ff       	call   f0100b63 <page_free>
}
f0100ba0:	c9                   	leave  
f0100ba1:	c3                   	ret    

f0100ba2 <tlb_invalidate>:
// Invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
//
void
tlb_invalidate(pde_t *pgdir, void *va)
{
f0100ba2:	55                   	push   %ebp
f0100ba3:	89 e5                	mov    %esp,%ebp
f0100ba5:	83 ec 08             	sub    $0x8,%esp
	// Flush the entry only if we're modifying the current address space.
	if (!curenv || curenv->env_pgdir == pgdir)
f0100ba8:	e8 82 52 00 00       	call   f0105e2f <cpunum>
f0100bad:	6b c0 74             	imul   $0x74,%eax,%eax
f0100bb0:	83 b8 28 40 22 f0 00 	cmpl   $0x0,-0xfddbfd8(%eax)
f0100bb7:	74 16                	je     f0100bcf <tlb_invalidate+0x2d>
f0100bb9:	e8 71 52 00 00       	call   f0105e2f <cpunum>
f0100bbe:	6b c0 74             	imul   $0x74,%eax,%eax
f0100bc1:	8b 90 28 40 22 f0    	mov    -0xfddbfd8(%eax),%edx
f0100bc7:	8b 45 08             	mov    0x8(%ebp),%eax
f0100bca:	39 42 60             	cmp    %eax,0x60(%edx)
f0100bcd:	75 06                	jne    f0100bd5 <tlb_invalidate+0x33>
}

static __inline void
invlpg(void *addr)
{
	__asm __volatile("invlpg (%0)" : : "r" (addr) : "memory");
f0100bcf:	8b 45 0c             	mov    0xc(%ebp),%eax
f0100bd2:	0f 01 38             	invlpg (%eax)
		invlpg(va);
}
f0100bd5:	c9                   	leave  
f0100bd6:	c3                   	ret    

f0100bd7 <check_va2pa>:
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.

static physaddr_t
check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100bd7:	55                   	push   %ebp
f0100bd8:	89 e5                	mov    %esp,%ebp
f0100bda:	83 ec 18             	sub    $0x18,%esp
	pte_t *p;

	pgdir = &pgdir[PDX(va)];
	if (!(*pgdir & PTE_P))
f0100bdd:	89 d1                	mov    %edx,%ecx
f0100bdf:	c1 e9 16             	shr    $0x16,%ecx
f0100be2:	8b 04 88             	mov    (%eax,%ecx,4),%eax
f0100be5:	a8 01                	test   $0x1,%al
f0100be7:	74 4d                	je     f0100c36 <check_va2pa+0x5f>
		return ~0;
	p = (pte_t*) KADDR(PTE_ADDR(*pgdir));
f0100be9:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100bee:	89 c1                	mov    %eax,%ecx
f0100bf0:	c1 e9 0c             	shr    $0xc,%ecx
f0100bf3:	3b 0d e8 3e 22 f0    	cmp    0xf0223ee8,%ecx
f0100bf9:	72 20                	jb     f0100c1b <check_va2pa+0x44>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bfb:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100bff:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f0100c06:	f0 
f0100c07:	c7 44 24 04 a4 03 00 	movl   $0x3a4,0x4(%esp)
f0100c0e:	00 
f0100c0f:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0100c16:	e8 6a f4 ff ff       	call   f0100085 <_panic>
	if (!(p[PTX(va)] & PTE_P))
f0100c1b:	c1 ea 0c             	shr    $0xc,%edx
f0100c1e:	81 e2 ff 03 00 00    	and    $0x3ff,%edx
f0100c24:	8b 84 90 00 00 00 f0 	mov    -0x10000000(%eax,%edx,4),%eax
f0100c2b:	a8 01                	test   $0x1,%al
f0100c2d:	74 07                	je     f0100c36 <check_va2pa+0x5f>
		return ~0;
	return PTE_ADDR(p[PTX(va)]);
f0100c2f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f0100c34:	eb 05                	jmp    f0100c3b <check_va2pa+0x64>
f0100c36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
f0100c3b:	c9                   	leave  
f0100c3c:	c3                   	ret    

f0100c3d <nvram_read>:
// Detect machine's physical memory setup.
// --------------------------------------------------------------

static int
nvram_read(int r)
{
f0100c3d:	55                   	push   %ebp
f0100c3e:	89 e5                	mov    %esp,%ebp
f0100c40:	83 ec 18             	sub    $0x18,%esp
f0100c43:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0100c46:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0100c49:	89 c3                	mov    %eax,%ebx
	return mc146818_read(r) | (mc146818_read(r + 1) << 8);
f0100c4b:	89 04 24             	mov    %eax,(%esp)
f0100c4e:	e8 81 31 00 00       	call   f0103dd4 <mc146818_read>
f0100c53:	89 c6                	mov    %eax,%esi
f0100c55:	83 c3 01             	add    $0x1,%ebx
f0100c58:	89 1c 24             	mov    %ebx,(%esp)
f0100c5b:	e8 74 31 00 00       	call   f0103dd4 <mc146818_read>
f0100c60:	c1 e0 08             	shl    $0x8,%eax
f0100c63:	09 f0                	or     %esi,%eax
}
f0100c65:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0100c68:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0100c6b:	89 ec                	mov    %ebp,%esp
f0100c6d:	5d                   	pop    %ebp
f0100c6e:	c3                   	ret    

f0100c6f <i386_detect_memory>:

static void
i386_detect_memory(void)
{
f0100c6f:	55                   	push   %ebp
f0100c70:	89 e5                	mov    %esp,%ebp
f0100c72:	83 ec 18             	sub    $0x18,%esp
	size_t npages_extmem;

	// Use CMOS calls to measure available base & extended memory.
	// (CMOS calls return results in kilobytes.)
	npages_basemem = (nvram_read(NVRAM_BASELO) * 1024) / PGSIZE;
f0100c75:	b8 15 00 00 00       	mov    $0x15,%eax
f0100c7a:	e8 be ff ff ff       	call   f0100c3d <nvram_read>
f0100c7f:	c1 e0 0a             	shl    $0xa,%eax
f0100c82:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100c88:	85 c0                	test   %eax,%eax
f0100c8a:	0f 48 c2             	cmovs  %edx,%eax
f0100c8d:	c1 f8 0c             	sar    $0xc,%eax
f0100c90:	a3 2c 32 22 f0       	mov    %eax,0xf022322c
	npages_extmem = (nvram_read(NVRAM_EXTLO) * 1024) / PGSIZE;
f0100c95:	b8 17 00 00 00       	mov    $0x17,%eax
f0100c9a:	e8 9e ff ff ff       	call   f0100c3d <nvram_read>
f0100c9f:	c1 e0 0a             	shl    $0xa,%eax
f0100ca2:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
f0100ca8:	85 c0                	test   %eax,%eax
f0100caa:	0f 48 c2             	cmovs  %edx,%eax
f0100cad:	c1 f8 0c             	sar    $0xc,%eax

	// Calculate the number of physical pages available in both base
	// and extended memory.
	if (npages_extmem)
f0100cb0:	85 c0                	test   %eax,%eax
f0100cb2:	74 0e                	je     f0100cc2 <i386_detect_memory+0x53>
		npages = (EXTPHYSMEM / PGSIZE) + npages_extmem;
f0100cb4:	8d 90 00 01 00 00    	lea    0x100(%eax),%edx
f0100cba:	89 15 e8 3e 22 f0    	mov    %edx,0xf0223ee8
f0100cc0:	eb 0c                	jmp    f0100cce <i386_detect_memory+0x5f>
	else
		npages = npages_basemem;
f0100cc2:	8b 15 2c 32 22 f0    	mov    0xf022322c,%edx
f0100cc8:	89 15 e8 3e 22 f0    	mov    %edx,0xf0223ee8

	cprintf("Physical memory: %uK available, base = %uK, extended = %uK\n",
f0100cce:	c1 e0 0c             	shl    $0xc,%eax
f0100cd1:	c1 e8 0a             	shr    $0xa,%eax
f0100cd4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100cd8:	a1 2c 32 22 f0       	mov    0xf022322c,%eax
f0100cdd:	c1 e0 0c             	shl    $0xc,%eax
f0100ce0:	c1 e8 0a             	shr    $0xa,%eax
f0100ce3:	89 44 24 08          	mov    %eax,0x8(%esp)
f0100ce7:	a1 e8 3e 22 f0       	mov    0xf0223ee8,%eax
f0100cec:	c1 e0 0c             	shl    $0xc,%eax
f0100cef:	c1 e8 0a             	shr    $0xa,%eax
f0100cf2:	89 44 24 04          	mov    %eax,0x4(%esp)
f0100cf6:	c7 04 24 e4 6a 10 f0 	movl   $0xf0106ae4,(%esp)
f0100cfd:	e8 27 32 00 00       	call   f0103f29 <cprintf>
		npages * PGSIZE / 1024,
		npages_basemem * PGSIZE / 1024,
		npages_extmem * PGSIZE / 1024);
}
f0100d02:	c9                   	leave  
f0100d03:	c3                   	ret    

f0100d04 <page_init>:
// allocator functions below to allocate and deallocate physical
// memory via the page_free_list.
//
void
page_init(void)
{
f0100d04:	55                   	push   %ebp
f0100d05:	89 e5                	mov    %esp,%ebp
f0100d07:	56                   	push   %esi
f0100d08:	53                   	push   %ebx
f0100d09:	83 ec 10             	sub    $0x10,%esp
	// }
	
	size_t i;
	extern char end[];
	size_t low = PGNUM(IOPHYSMEM);
	size_t up = PGNUM(PADDR(boot_alloc(0)));
f0100d0c:	b8 00 00 00 00       	mov    $0x0,%eax
f0100d11:	e8 0a fe ff ff       	call   f0100b20 <boot_alloc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100d16:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0100d1b:	77 20                	ja     f0100d3d <page_init+0x39>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100d1d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100d21:	c7 44 24 08 dc 65 10 	movl   $0xf01065dc,0x8(%esp)
f0100d28:	f0 
f0100d29:	c7 44 24 04 51 01 00 	movl   $0x151,0x4(%esp)
f0100d30:	00 
f0100d31:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0100d38:	e8 48 f3 ff ff       	call   f0100085 <_panic>
f0100d3d:	8b 1d 30 32 22 f0    	mov    0xf0223230,%ebx
f0100d43:	b9 02 00 00 00       	mov    $0x2,%ecx
f0100d48:	b8 01 00 00 00       	mov    $0x1,%eax
f0100d4d:	eb 06                	jmp    f0100d55 <page_init+0x51>
f0100d4f:	83 c0 01             	add    $0x1,%eax
f0100d52:	83 c1 01             	add    $0x1,%ecx

	int mpentry = PGNUM(MPENTRY_PADDR);
	//panic("shizhende %d",up);
	for (i = 1; i < low; i++) {
			if(i == mpentry) continue;
f0100d55:	83 f8 07             	cmp    $0x7,%eax
f0100d58:	74 f5                	je     f0100d4f <page_init+0x4b>
f0100d5a:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
			pages[i].pp_ref = 0;
f0100d61:	8b 35 f0 3e 22 f0    	mov    0xf0223ef0,%esi
f0100d67:	66 c7 44 16 04 00 00 	movw   $0x0,0x4(%esi,%edx,1)
			pages[i].pp_link = page_free_list;
f0100d6e:	8b 35 f0 3e 22 f0    	mov    0xf0223ef0,%esi
f0100d74:	89 1c 16             	mov    %ebx,(%esi,%edx,1)
			page_free_list = &pages[i];
f0100d77:	89 d3                	mov    %edx,%ebx
f0100d79:	03 1d f0 3e 22 f0    	add    0xf0223ef0,%ebx
	size_t low = PGNUM(IOPHYSMEM);
	size_t up = PGNUM(PADDR(boot_alloc(0)));

	int mpentry = PGNUM(MPENTRY_PADDR);
	//panic("shizhende %d",up);
	for (i = 1; i < low; i++) {
f0100d7f:	81 f9 9f 00 00 00    	cmp    $0x9f,%ecx
f0100d85:	76 c8                	jbe    f0100d4f <page_init+0x4b>
f0100d87:	89 1d 30 32 22 f0    	mov    %ebx,0xf0223230
			if(i == mpentry) continue;
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
	}
	for(i = 700;i < npages;i++) {
f0100d8d:	81 3d e8 3e 22 f0 bc 	cmpl   $0x2bc,0xf0223ee8
f0100d94:	02 00 00 
f0100d97:	76 3b                	jbe    f0100dd4 <page_init+0xd0>
f0100d99:	b8 bc 02 00 00       	mov    $0x2bc,%eax
f0100d9e:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
			pages[i].pp_ref = 0;
f0100da5:	8b 0d f0 3e 22 f0    	mov    0xf0223ef0,%ecx
f0100dab:	66 c7 44 11 04 00 00 	movw   $0x0,0x4(%ecx,%edx,1)
			pages[i].pp_link = page_free_list;
f0100db2:	8b 0d f0 3e 22 f0    	mov    0xf0223ef0,%ecx
f0100db8:	89 1c 11             	mov    %ebx,(%ecx,%edx,1)
			page_free_list = &pages[i];
f0100dbb:	89 d3                	mov    %edx,%ebx
f0100dbd:	03 1d f0 3e 22 f0    	add    0xf0223ef0,%ebx
			if(i == mpentry) continue;
			pages[i].pp_ref = 0;
			pages[i].pp_link = page_free_list;
			page_free_list = &pages[i];
	}
	for(i = 700;i < npages;i++) {
f0100dc3:	83 c0 01             	add    $0x1,%eax
f0100dc6:	39 05 e8 3e 22 f0    	cmp    %eax,0xf0223ee8
f0100dcc:	77 d0                	ja     f0100d9e <page_init+0x9a>
f0100dce:	89 1d 30 32 22 f0    	mov    %ebx,0xf0223230

	}
	//panic("shishi %d",page2pa(page_free_list->pp_link)/PGSIZE);
	//panic("xcv %0x %0x %0x",&pages[0],&pages[1],&pages[npages-1]);
	
}
f0100dd4:	83 c4 10             	add    $0x10,%esp
f0100dd7:	5b                   	pop    %ebx
f0100dd8:	5e                   	pop    %esi
f0100dd9:	5d                   	pop    %ebp
f0100dda:	c3                   	ret    

f0100ddb <check_page_free_list>:
//
// Check that the pages on the page_free_list are reasonable.
//
static void
check_page_free_list(bool only_low_memory)
{
f0100ddb:	55                   	push   %ebp
f0100ddc:	89 e5                	mov    %esp,%ebp
f0100dde:	57                   	push   %edi
f0100ddf:	56                   	push   %esi
f0100de0:	53                   	push   %ebx
f0100de1:	83 ec 5c             	sub    $0x5c,%esp
	struct PageInfo *pp;
	unsigned pdx_limit = only_low_memory ? 1 : NPDENTRIES;
f0100de4:	3c 01                	cmp    $0x1,%al
f0100de6:	19 f6                	sbb    %esi,%esi
f0100de8:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
f0100dee:	83 c6 01             	add    $0x1,%esi
	int nfree_basemem = 0, nfree_extmem = 0;
	char *first_free_page;

	if (!page_free_list)
f0100df1:	8b 1d 30 32 22 f0    	mov    0xf0223230,%ebx
f0100df7:	85 db                	test   %ebx,%ebx
f0100df9:	75 1c                	jne    f0100e17 <check_page_free_list+0x3c>
		panic("'page_free_list' is a null pointer!");
f0100dfb:	c7 44 24 08 20 6b 10 	movl   $0xf0106b20,0x8(%esp)
f0100e02:	f0 
f0100e03:	c7 44 24 04 d3 02 00 	movl   $0x2d3,0x4(%esp)
f0100e0a:	00 
f0100e0b:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0100e12:	e8 6e f2 ff ff       	call   f0100085 <_panic>

	if (only_low_memory) {
f0100e17:	84 c0                	test   %al,%al
f0100e19:	74 52                	je     f0100e6d <check_page_free_list+0x92>
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
f0100e1b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0100e1e:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0100e21:	8d 45 e0             	lea    -0x20(%ebp),%eax
f0100e24:	89 45 dc             	mov    %eax,-0x24(%ebp)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e27:	8b 0d f0 3e 22 f0    	mov    0xf0223ef0,%ecx
		for (pp = page_free_list; pp; pp = pp->pp_link) {
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
f0100e2d:	89 d8                	mov    %ebx,%eax
f0100e2f:	29 c8                	sub    %ecx,%eax
f0100e31:	c1 e0 09             	shl    $0x9,%eax
f0100e34:	c1 e8 16             	shr    $0x16,%eax
f0100e37:	39 c6                	cmp    %eax,%esi
f0100e39:	0f 96 c0             	setbe  %al
f0100e3c:	0f b6 c0             	movzbl %al,%eax
			*tp[pagetype] = pp;
f0100e3f:	8b 54 85 d8          	mov    -0x28(%ebp,%eax,4),%edx
f0100e43:	89 1a                	mov    %ebx,(%edx)
			tp[pagetype] = &pp->pp_link;
f0100e45:	89 5c 85 d8          	mov    %ebx,-0x28(%ebp,%eax,4)
	if (only_low_memory) {
		// Move pages with lower addresses first in the free
		// list, since entry_pgdir does not map all pages.
		struct PageInfo *pp1, *pp2;
		struct PageInfo **tp[2] = { &pp1, &pp2 };
		for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100e49:	8b 1b                	mov    (%ebx),%ebx
f0100e4b:	85 db                	test   %ebx,%ebx
f0100e4d:	75 de                	jne    f0100e2d <check_page_free_list+0x52>
			int pagetype = PDX(page2pa(pp)) >= pdx_limit;
			*tp[pagetype] = pp;
			tp[pagetype] = &pp->pp_link;
		}
		*tp[1] = 0;
f0100e4f:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0100e52:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
		*tp[0] = pp2;
f0100e58:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0100e5b:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0100e5e:	89 10                	mov    %edx,(%eax)
		page_free_list = pp1;
f0100e60:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
f0100e63:	89 1d 30 32 22 f0    	mov    %ebx,0xf0223230
	}
	// panic("we %d",page2pa(page_free_list->pp_link)/PGSIZE); 1024 -1023

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100e69:	85 db                	test   %ebx,%ebx
f0100e6b:	74 67                	je     f0100ed4 <check_page_free_list+0xf9>
f0100e6d:	89 d8                	mov    %ebx,%eax
f0100e6f:	2b 05 f0 3e 22 f0    	sub    0xf0223ef0,%eax
f0100e75:	c1 f8 03             	sar    $0x3,%eax
f0100e78:	c1 e0 0c             	shl    $0xc,%eax
		if (PDX(page2pa(pp)) < pdx_limit)
f0100e7b:	89 c2                	mov    %eax,%edx
f0100e7d:	c1 ea 16             	shr    $0x16,%edx
f0100e80:	39 d6                	cmp    %edx,%esi
f0100e82:	76 4a                	jbe    f0100ece <check_page_free_list+0xf3>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100e84:	89 c2                	mov    %eax,%edx
f0100e86:	c1 ea 0c             	shr    $0xc,%edx
f0100e89:	3b 15 e8 3e 22 f0    	cmp    0xf0223ee8,%edx
f0100e8f:	72 20                	jb     f0100eb1 <check_page_free_list+0xd6>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100e91:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0100e95:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f0100e9c:	f0 
f0100e9d:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0100ea4:	00 
f0100ea5:	c7 04 24 b7 73 10 f0 	movl   $0xf01073b7,(%esp)
f0100eac:	e8 d4 f1 ff ff       	call   f0100085 <_panic>
			memset(page2kva(pp), 0x97, 128);
f0100eb1:	c7 44 24 08 80 00 00 	movl   $0x80,0x8(%esp)
f0100eb8:	00 
f0100eb9:	c7 44 24 04 97 00 00 	movl   $0x97,0x4(%esp)
f0100ec0:	00 
f0100ec1:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0100ec6:	89 04 24             	mov    %eax,(%esp)
f0100ec9:	e8 b8 48 00 00       	call   f0105786 <memset>
	}
	// panic("we %d",page2pa(page_free_list->pp_link)/PGSIZE); 1024 -1023

	// if there's a page that shouldn't be on the free list,
	// try to make sure it eventually causes trouble.
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0100ece:	8b 1b                	mov    (%ebx),%ebx
f0100ed0:	85 db                	test   %ebx,%ebx
f0100ed2:	75 99                	jne    f0100e6d <check_page_free_list+0x92>
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
f0100ed4:	b8 00 00 00 00       	mov    $0x0,%eax
f0100ed9:	e8 42 fc ff ff       	call   f0100b20 <boot_alloc>
f0100ede:	89 45 c4             	mov    %eax,-0x3c(%ebp)
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f0100ee1:	8b 15 30 32 22 f0    	mov    0xf0223230,%edx
f0100ee7:	85 d2                	test   %edx,%edx
f0100ee9:	0f 84 3c 02 00 00    	je     f010112b <check_page_free_list+0x350>
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100eef:	8b 1d f0 3e 22 f0    	mov    0xf0223ef0,%ebx
f0100ef5:	39 da                	cmp    %ebx,%edx
f0100ef7:	72 51                	jb     f0100f4a <check_page_free_list+0x16f>
		assert(pp < pages + npages);
f0100ef9:	a1 e8 3e 22 f0       	mov    0xf0223ee8,%eax
f0100efe:	89 45 c8             	mov    %eax,-0x38(%ebp)
f0100f01:	8d 04 c3             	lea    (%ebx,%eax,8),%eax
f0100f04:	89 45 d0             	mov    %eax,-0x30(%ebp)
f0100f07:	39 c2                	cmp    %eax,%edx
f0100f09:	73 68                	jae    f0100f73 <check_page_free_list+0x198>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100f0b:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0100f0e:	89 d0                	mov    %edx,%eax
f0100f10:	29 d8                	sub    %ebx,%eax
f0100f12:	a8 07                	test   $0x7,%al
f0100f14:	0f 85 86 00 00 00    	jne    f0100fa0 <check_page_free_list+0x1c5>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100f1a:	c1 f8 03             	sar    $0x3,%eax
f0100f1d:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100f20:	85 c0                	test   %eax,%eax
f0100f22:	0f 84 a6 00 00 00    	je     f0100fce <check_page_free_list+0x1f3>
		assert(page2pa(pp) != IOPHYSMEM);
f0100f28:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100f2d:	0f 84 c6 00 00 00    	je     f0100ff9 <check_page_free_list+0x21e>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f0100f33:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0100f38:	0f 85 0a 01 00 00    	jne    f0101048 <check_page_free_list+0x26d>
f0100f3e:	66 90                	xchg   %ax,%ax
f0100f40:	e9 df 00 00 00       	jmp    f0101024 <check_page_free_list+0x249>
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
		// check that we didn't corrupt the free list itself
		assert(pp >= pages);
f0100f45:	3b 55 b4             	cmp    -0x4c(%ebp),%edx
f0100f48:	73 24                	jae    f0100f6e <check_page_free_list+0x193>
f0100f4a:	c7 44 24 0c c5 73 10 	movl   $0xf01073c5,0xc(%esp)
f0100f51:	f0 
f0100f52:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0100f59:	f0 
f0100f5a:	c7 44 24 04 ee 02 00 	movl   $0x2ee,0x4(%esp)
f0100f61:	00 
f0100f62:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0100f69:	e8 17 f1 ff ff       	call   f0100085 <_panic>
		assert(pp < pages + npages);
f0100f6e:	3b 55 d0             	cmp    -0x30(%ebp),%edx
f0100f71:	72 24                	jb     f0100f97 <check_page_free_list+0x1bc>
f0100f73:	c7 44 24 0c e6 73 10 	movl   $0xf01073e6,0xc(%esp)
f0100f7a:	f0 
f0100f7b:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0100f82:	f0 
f0100f83:	c7 44 24 04 ef 02 00 	movl   $0x2ef,0x4(%esp)
f0100f8a:	00 
f0100f8b:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0100f92:	e8 ee f0 ff ff       	call   f0100085 <_panic>
		assert(((char *) pp - (char *) pages) % sizeof(*pp) == 0);
f0100f97:	89 d0                	mov    %edx,%eax
f0100f99:	2b 45 cc             	sub    -0x34(%ebp),%eax
f0100f9c:	a8 07                	test   $0x7,%al
f0100f9e:	74 24                	je     f0100fc4 <check_page_free_list+0x1e9>
f0100fa0:	c7 44 24 0c 44 6b 10 	movl   $0xf0106b44,0xc(%esp)
f0100fa7:	f0 
f0100fa8:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0100faf:	f0 
f0100fb0:	c7 44 24 04 f0 02 00 	movl   $0x2f0,0x4(%esp)
f0100fb7:	00 
f0100fb8:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0100fbf:	e8 c1 f0 ff ff       	call   f0100085 <_panic>
f0100fc4:	c1 f8 03             	sar    $0x3,%eax
f0100fc7:	c1 e0 0c             	shl    $0xc,%eax

		// check a few pages that shouldn't be on the free list
		assert(page2pa(pp) != 0);
f0100fca:	85 c0                	test   %eax,%eax
f0100fcc:	75 24                	jne    f0100ff2 <check_page_free_list+0x217>
f0100fce:	c7 44 24 0c fa 73 10 	movl   $0xf01073fa,0xc(%esp)
f0100fd5:	f0 
f0100fd6:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0100fdd:	f0 
f0100fde:	c7 44 24 04 f3 02 00 	movl   $0x2f3,0x4(%esp)
f0100fe5:	00 
f0100fe6:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0100fed:	e8 93 f0 ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != IOPHYSMEM);
f0100ff2:	3d 00 00 0a 00       	cmp    $0xa0000,%eax
f0100ff7:	75 24                	jne    f010101d <check_page_free_list+0x242>
f0100ff9:	c7 44 24 0c 0b 74 10 	movl   $0xf010740b,0xc(%esp)
f0101000:	f0 
f0101001:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101008:	f0 
f0101009:	c7 44 24 04 f4 02 00 	movl   $0x2f4,0x4(%esp)
f0101010:	00 
f0101011:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101018:	e8 68 f0 ff ff       	call   f0100085 <_panic>
		assert(page2pa(pp) != EXTPHYSMEM - PGSIZE);
f010101d:	3d 00 f0 0f 00       	cmp    $0xff000,%eax
f0101022:	75 31                	jne    f0101055 <check_page_free_list+0x27a>
f0101024:	c7 44 24 0c 78 6b 10 	movl   $0xf0106b78,0xc(%esp)
f010102b:	f0 
f010102c:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101033:	f0 
f0101034:	c7 44 24 04 f5 02 00 	movl   $0x2f5,0x4(%esp)
f010103b:	00 
f010103c:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101043:	e8 3d f0 ff ff       	call   f0100085 <_panic>
f0101048:	be 00 00 00 00       	mov    $0x0,%esi
f010104d:	bf 00 00 00 00       	mov    $0x0,%edi
f0101052:	89 5d b4             	mov    %ebx,-0x4c(%ebp)
		assert(page2pa(pp) != EXTPHYSMEM);
f0101055:	3d 00 00 10 00       	cmp    $0x100000,%eax
f010105a:	75 24                	jne    f0101080 <check_page_free_list+0x2a5>
f010105c:	c7 44 24 0c 24 74 10 	movl   $0xf0107424,0xc(%esp)
f0101063:	f0 
f0101064:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f010106b:	f0 
f010106c:	c7 44 24 04 f6 02 00 	movl   $0x2f6,0x4(%esp)
f0101073:	00 
f0101074:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f010107b:	e8 05 f0 ff ff       	call   f0100085 <_panic>
f0101080:	89 c1                	mov    %eax,%ecx
		assert(page2pa(pp) < EXTPHYSMEM || (char *) page2kva(pp) >= first_free_page);
f0101082:	3d ff ff 0f 00       	cmp    $0xfffff,%eax
f0101087:	76 59                	jbe    f01010e2 <check_page_free_list+0x307>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101089:	89 c3                	mov    %eax,%ebx
f010108b:	c1 eb 0c             	shr    $0xc,%ebx
f010108e:	39 5d c8             	cmp    %ebx,-0x38(%ebp)
f0101091:	77 20                	ja     f01010b3 <check_page_free_list+0x2d8>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101093:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101097:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f010109e:	f0 
f010109f:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01010a6:	00 
f01010a7:	c7 04 24 b7 73 10 f0 	movl   $0xf01073b7,(%esp)
f01010ae:	e8 d2 ef ff ff       	call   f0100085 <_panic>
f01010b3:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f01010b9:	39 5d c4             	cmp    %ebx,-0x3c(%ebp)
f01010bc:	76 24                	jbe    f01010e2 <check_page_free_list+0x307>
f01010be:	c7 44 24 0c 9c 6b 10 	movl   $0xf0106b9c,0xc(%esp)
f01010c5:	f0 
f01010c6:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f01010cd:	f0 
f01010ce:	c7 44 24 04 f7 02 00 	movl   $0x2f7,0x4(%esp)
f01010d5:	00 
f01010d6:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01010dd:	e8 a3 ef ff ff       	call   f0100085 <_panic>
		// (new test for lab 4)
		assert(page2pa(pp) != MPENTRY_PADDR);
f01010e2:	3d 00 70 00 00       	cmp    $0x7000,%eax
f01010e7:	75 24                	jne    f010110d <check_page_free_list+0x332>
f01010e9:	c7 44 24 0c 3e 74 10 	movl   $0xf010743e,0xc(%esp)
f01010f0:	f0 
f01010f1:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f01010f8:	f0 
f01010f9:	c7 44 24 04 f9 02 00 	movl   $0x2f9,0x4(%esp)
f0101100:	00 
f0101101:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101108:	e8 78 ef ff ff       	call   f0100085 <_panic>

		if (page2pa(pp) < EXTPHYSMEM)
f010110d:	81 f9 ff ff 0f 00    	cmp    $0xfffff,%ecx
f0101113:	77 05                	ja     f010111a <check_page_free_list+0x33f>
			++nfree_basemem;
f0101115:	83 c7 01             	add    $0x1,%edi
f0101118:	eb 03                	jmp    f010111d <check_page_free_list+0x342>
		else
			++nfree_extmem;
f010111a:	83 c6 01             	add    $0x1,%esi
	for (pp = page_free_list; pp; pp = pp->pp_link)
		if (PDX(page2pa(pp)) < pdx_limit)
			memset(page2kva(pp), 0x97, 128);

	first_free_page = (char *) boot_alloc(0);
	for (pp = page_free_list; pp; pp = pp->pp_link) {
f010111d:	8b 12                	mov    (%edx),%edx
f010111f:	85 d2                	test   %edx,%edx
f0101121:	0f 85 1e fe ff ff    	jne    f0100f45 <check_page_free_list+0x16a>
			++nfree_basemem;
		else
			++nfree_extmem;
	}

	assert(nfree_basemem > 0);
f0101127:	85 ff                	test   %edi,%edi
f0101129:	7f 24                	jg     f010114f <check_page_free_list+0x374>
f010112b:	c7 44 24 0c 5b 74 10 	movl   $0xf010745b,0xc(%esp)
f0101132:	f0 
f0101133:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f010113a:	f0 
f010113b:	c7 44 24 04 01 03 00 	movl   $0x301,0x4(%esp)
f0101142:	00 
f0101143:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f010114a:	e8 36 ef ff ff       	call   f0100085 <_panic>
	assert(nfree_extmem > 0);
f010114f:	85 f6                	test   %esi,%esi
f0101151:	7f 24                	jg     f0101177 <check_page_free_list+0x39c>
f0101153:	c7 44 24 0c 6d 74 10 	movl   $0xf010746d,0xc(%esp)
f010115a:	f0 
f010115b:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101162:	f0 
f0101163:	c7 44 24 04 02 03 00 	movl   $0x302,0x4(%esp)
f010116a:	00 
f010116b:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101172:	e8 0e ef ff ff       	call   f0100085 <_panic>
}
f0101177:	83 c4 5c             	add    $0x5c,%esp
f010117a:	5b                   	pop    %ebx
f010117b:	5e                   	pop    %esi
f010117c:	5f                   	pop    %edi
f010117d:	5d                   	pop    %ebp
f010117e:	c3                   	ret    

f010117f <page_alloc>:
// Returns NULL if out of free memory.
//
// Hint: use page2kva and memset
struct PageInfo *
page_alloc(int alloc_flags)
{
f010117f:	55                   	push   %ebp
f0101180:	89 e5                	mov    %esp,%ebp
f0101182:	53                   	push   %ebx
f0101183:	83 ec 14             	sub    $0x14,%esp
	// Fill this function in
	struct PageInfo *p,*q;
	p=NULL;
	
	if(page_free_list==NULL)
f0101186:	8b 1d 30 32 22 f0    	mov    0xf0223230,%ebx
f010118c:	85 db                	test   %ebx,%ebx
f010118e:	74 65                	je     f01011f5 <page_alloc+0x76>
		return NULL;
		
	p=page_free_list;
	page_free_list=page_free_list->pp_link;
f0101190:	8b 03                	mov    (%ebx),%eax
f0101192:	a3 30 32 22 f0       	mov    %eax,0xf0223230
	if (alloc_flags & ALLOC_ZERO) {
f0101197:	f6 45 08 01          	testb  $0x1,0x8(%ebp)
f010119b:	74 58                	je     f01011f5 <page_alloc+0x76>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010119d:	89 d8                	mov    %ebx,%eax
f010119f:	2b 05 f0 3e 22 f0    	sub    0xf0223ef0,%eax
f01011a5:	c1 f8 03             	sar    $0x3,%eax
f01011a8:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01011ab:	89 c2                	mov    %eax,%edx
f01011ad:	c1 ea 0c             	shr    $0xc,%edx
f01011b0:	3b 15 e8 3e 22 f0    	cmp    0xf0223ee8,%edx
f01011b6:	72 20                	jb     f01011d8 <page_alloc+0x59>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01011b8:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01011bc:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f01011c3:	f0 
f01011c4:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01011cb:	00 
f01011cc:	c7 04 24 b7 73 10 f0 	movl   $0xf01073b7,(%esp)
f01011d3:	e8 ad ee ff ff       	call   f0100085 <_panic>
		q=(struct PageInfo *)page2kva(p);
		memset(q, 0, PGSIZE);
f01011d8:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01011df:	00 
f01011e0:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01011e7:	00 
f01011e8:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01011ed:	89 04 24             	mov    %eax,(%esp)
f01011f0:	e8 91 45 00 00       	call   f0105786 <memset>
	}
	return p;
}
f01011f5:	89 d8                	mov    %ebx,%eax
f01011f7:	83 c4 14             	add    $0x14,%esp
f01011fa:	5b                   	pop    %ebx
f01011fb:	5d                   	pop    %ebp
f01011fc:	c3                   	ret    

f01011fd <pgdir_walk>:
// Hint 3: look at inc/mmu.h for useful macros that mainipulate page
// table and page directory entries.
//
pte_t *
pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f01011fd:	55                   	push   %ebp
f01011fe:	89 e5                	mov    %esp,%ebp
f0101200:	83 ec 18             	sub    $0x18,%esp
f0101203:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0101206:	89 75 fc             	mov    %esi,-0x4(%ebp)
	// Fill this function in
	pde_t *pde;
	pde_t *pgtab;
	struct PageInfo *temp=NULL;
	
	pde=&pgdir[PDX(va)];	// pde is adr of pdir
f0101209:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f010120c:	89 de                	mov    %ebx,%esi
f010120e:	c1 ee 16             	shr    $0x16,%esi
f0101211:	c1 e6 02             	shl    $0x2,%esi
f0101214:	03 75 08             	add    0x8(%ebp),%esi
	
	if(*pde & PTE_P) 	// check is present;ps:pdx and ptx flags is same 
f0101217:	8b 06                	mov    (%esi),%eax
f0101219:	a8 01                	test   $0x1,%al
f010121b:	74 39                	je     f0101256 <pgdir_walk+0x59>
		pgtab=(pte_t *)KADDR(PTE_ADDR((*pde)));	// page table start addr;pte_addr is use by pte and pde
f010121d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101222:	89 c2                	mov    %eax,%edx
f0101224:	c1 ea 0c             	shr    $0xc,%edx
f0101227:	3b 15 e8 3e 22 f0    	cmp    0xf0223ee8,%edx
f010122d:	72 20                	jb     f010124f <pgdir_walk+0x52>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010122f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101233:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f010123a:	f0 
f010123b:	c7 44 24 04 bd 01 00 	movl   $0x1bd,0x4(%esp)
f0101242:	00 
f0101243:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f010124a:	e8 36 ee ff ff       	call   f0100085 <_panic>
f010124f:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101254:	eb 62                	jmp    f01012b8 <pgdir_walk+0xbb>
	else if(create==0)
f0101256:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
f010125a:	74 69                	je     f01012c5 <pgdir_walk+0xc8>
		return NULL;
	else if((temp=page_alloc(ALLOC_ZERO))!=NULL){
f010125c:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101263:	e8 17 ff ff ff       	call   f010117f <page_alloc>
f0101268:	85 c0                	test   %eax,%eax
f010126a:	74 59                	je     f01012c5 <pgdir_walk+0xc8>
		temp->pp_ref=1;
f010126c:	66 c7 40 04 01 00    	movw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101272:	2b 05 f0 3e 22 f0    	sub    0xf0223ef0,%eax
f0101278:	c1 f8 03             	sar    $0x3,%eax
f010127b:	89 c2                	mov    %eax,%edx
f010127d:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101280:	89 d0                	mov    %edx,%eax
f0101282:	c1 e8 0c             	shr    $0xc,%eax
f0101285:	3b 05 e8 3e 22 f0    	cmp    0xf0223ee8,%eax
f010128b:	72 20                	jb     f01012ad <pgdir_walk+0xb0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010128d:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101291:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f0101298:	f0 
f0101299:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01012a0:	00 
f01012a1:	c7 04 24 b7 73 10 f0 	movl   $0xf01073b7,(%esp)
f01012a8:	e8 d8 ed ff ff       	call   f0100085 <_panic>
		pgtab=(pde_t *)page2kva(temp);
f01012ad:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
		*pde=page2pa(temp)|PTE_P|PTE_U|PTE_W;	//*pde store 0,4096, 8192,...
f01012b3:	83 ca 07             	or     $0x7,%edx
f01012b6:	89 16                	mov    %edx,(%esi)
	}	
	else
		return NULL;
	return &pgtab[PTX(va)];			// physical page addr
f01012b8:	c1 eb 0a             	shr    $0xa,%ebx
f01012bb:	81 e3 fc 0f 00 00    	and    $0xffc,%ebx
f01012c1:	01 d8                	add    %ebx,%eax
f01012c3:	eb 05                	jmp    f01012ca <pgdir_walk+0xcd>
f01012c5:	b8 00 00 00 00       	mov    $0x0,%eax
}
f01012ca:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f01012cd:	8b 75 fc             	mov    -0x4(%ebp),%esi
f01012d0:	89 ec                	mov    %ebp,%esp
f01012d2:	5d                   	pop    %ebp
f01012d3:	c3                   	ret    

f01012d4 <user_mem_check>:
// Returns 0 if the user program can access this range of addresses,
// and -E_FAULT otherwise.
//
int
user_mem_check(struct Env *env, const void *va, size_t len, int perm)
{
f01012d4:	55                   	push   %ebp
f01012d5:	89 e5                	mov    %esp,%ebp
f01012d7:	57                   	push   %edi
f01012d8:	56                   	push   %esi
f01012d9:	53                   	push   %ebx
f01012da:	83 ec 2c             	sub    $0x2c,%esp
f01012dd:	8b 75 08             	mov    0x8(%ebp),%esi
	// LAB 3: Your code here.
	char *start=(char *)va;
f01012e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *end=(char *)(start+len); // TS
f01012e3:	8b 45 10             	mov    0x10(%ebp),%eax
f01012e6:	01 d8                	add    %ebx,%eax
f01012e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	
	perm = perm|PTE_U|PTE_P;
f01012eb:	8b 7d 14             	mov    0x14(%ebp),%edi
f01012ee:	83 cf 05             	or     $0x5,%edi
	pte_t *pte;
	for(;start<end;start+=PGSIZE) {
f01012f1:	39 c3                	cmp    %eax,%ebx
f01012f3:	73 63                	jae    f0101358 <user_mem_check+0x84>
	
		if(start>=(char *)ULIM) {
f01012f5:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f01012fb:	76 1a                	jbe    f0101317 <user_mem_check+0x43>
f01012fd:	eb 0b                	jmp    f010130a <user_mem_check+0x36>
f01012ff:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0101305:	8d 76 00             	lea    0x0(%esi),%esi
f0101308:	76 0d                	jbe    f0101317 <user_mem_check+0x43>
			user_mem_check_addr=(int )start;
f010130a:	89 1d 34 32 22 f0    	mov    %ebx,0xf0223234
f0101310:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
			return -E_FAULT;
f0101315:	eb 46                	jmp    f010135d <user_mem_check+0x89>
		}
		pte=(pte_t *)pgdir_walk(env->env_pgdir,start,0);
f0101317:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010131e:	00 
f010131f:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101323:	8b 46 60             	mov    0x60(%esi),%eax
f0101326:	89 04 24             	mov    %eax,(%esp)
f0101329:	e8 cf fe ff ff       	call   f01011fd <pgdir_walk>
		if( pte==NULL || (*pte & perm)!= perm) {
f010132e:	85 c0                	test   %eax,%eax
f0101330:	74 08                	je     f010133a <user_mem_check+0x66>
f0101332:	8b 00                	mov    (%eax),%eax
f0101334:	21 f8                	and    %edi,%eax
f0101336:	39 c7                	cmp    %eax,%edi
f0101338:	74 0d                	je     f0101347 <user_mem_check+0x73>
			user_mem_check_addr=(int )start;
f010133a:	89 1d 34 32 22 f0    	mov    %ebx,0xf0223234
f0101340:	b8 fa ff ff ff       	mov    $0xfffffffa,%eax
			return -E_FAULT;
f0101345:	eb 16                	jmp    f010135d <user_mem_check+0x89>
		}
		start = ROUNDDOWN (start, PGSIZE);
f0101347:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	char *start=(char *)va;
	char *end=(char *)(start+len); // TS
	
	perm = perm|PTE_U|PTE_P;
	pte_t *pte;
	for(;start<end;start+=PGSIZE) {
f010134d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0101353:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
f0101356:	77 a7                	ja     f01012ff <user_mem_check+0x2b>
f0101358:	b8 00 00 00 00       	mov    $0x0,%eax
		start = ROUNDDOWN (start, PGSIZE);
	}

	
	return 0;
}
f010135d:	83 c4 2c             	add    $0x2c,%esp
f0101360:	5b                   	pop    %ebx
f0101361:	5e                   	pop    %esi
f0101362:	5f                   	pop    %edi
f0101363:	5d                   	pop    %ebp
f0101364:	c3                   	ret    

f0101365 <user_mem_assert>:
// If it cannot, 'env' is destroyed and, if env is the current
// environment, this function will not return.
//
void
user_mem_assert(struct Env *env, const void *va, size_t len, int perm)
{
f0101365:	55                   	push   %ebp
f0101366:	89 e5                	mov    %esp,%ebp
f0101368:	53                   	push   %ebx
f0101369:	83 ec 14             	sub    $0x14,%esp
f010136c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (user_mem_check(env, va, len, perm | PTE_U) < 0) {
f010136f:	8b 45 14             	mov    0x14(%ebp),%eax
f0101372:	83 c8 04             	or     $0x4,%eax
f0101375:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101379:	8b 45 10             	mov    0x10(%ebp),%eax
f010137c:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101380:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101383:	89 44 24 04          	mov    %eax,0x4(%esp)
f0101387:	89 1c 24             	mov    %ebx,(%esp)
f010138a:	e8 45 ff ff ff       	call   f01012d4 <user_mem_check>
f010138f:	85 c0                	test   %eax,%eax
f0101391:	79 24                	jns    f01013b7 <user_mem_assert+0x52>
		cprintf("[%08x] user_mem_check assertion failure for "
f0101393:	a1 34 32 22 f0       	mov    0xf0223234,%eax
f0101398:	89 44 24 08          	mov    %eax,0x8(%esp)
f010139c:	8b 43 48             	mov    0x48(%ebx),%eax
f010139f:	89 44 24 04          	mov    %eax,0x4(%esp)
f01013a3:	c7 04 24 e4 6b 10 f0 	movl   $0xf0106be4,(%esp)
f01013aa:	e8 7a 2b 00 00       	call   f0103f29 <cprintf>
			"va %08x\n", env->env_id, user_mem_check_addr);
		env_destroy(env);	// may not return
f01013af:	89 1c 24             	mov    %ebx,(%esp)
f01013b2:	e8 23 26 00 00       	call   f01039da <env_destroy>
	}
}
f01013b7:	83 c4 14             	add    $0x14,%esp
f01013ba:	5b                   	pop    %ebx
f01013bb:	5d                   	pop    %ebp
f01013bc:	c3                   	ret    

f01013bd <boot_map_region>:
// mapped pages.
//
// Hint: the TA solution uses pgdir_walk
static void
boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
{
f01013bd:	55                   	push   %ebp
f01013be:	89 e5                	mov    %esp,%ebp
f01013c0:	57                   	push   %edi
f01013c1:	56                   	push   %esi
f01013c2:	53                   	push   %ebx
f01013c3:	83 ec 2c             	sub    $0x2c,%esp
f01013c6:	89 45 dc             	mov    %eax,-0x24(%ebp)
f01013c9:	89 d3                	mov    %edx,%ebx
f01013cb:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f01013ce:	8b 7d 08             	mov    0x8(%ebp),%edi
	pte_t *pte;
	int i=0;
	
	// xiang dang yu alloc a page
	for(i=0;i<size;i=i+PGSIZE) {
f01013d1:	85 c9                	test   %ecx,%ecx
f01013d3:	74 43                	je     f0101418 <boot_map_region+0x5b>
f01013d5:	be 00 00 00 00       	mov    $0x0,%esi
		pte = pgdir_walk (pgdir, (char *)va, 1);
		*pte = pa|perm|PTE_P;
f01013da:	8b 45 0c             	mov    0xc(%ebp),%eax
f01013dd:	83 c8 01             	or     $0x1,%eax
f01013e0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	pte_t *pte;
	int i=0;
	
	// xiang dang yu alloc a page
	for(i=0;i<size;i=i+PGSIZE) {
		pte = pgdir_walk (pgdir, (char *)va, 1);
f01013e3:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f01013ea:	00 
f01013eb:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01013ef:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01013f2:	89 04 24             	mov    %eax,(%esp)
f01013f5:	e8 03 fe ff ff       	call   f01011fd <pgdir_walk>
		*pte = pa|perm|PTE_P;
f01013fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01013fd:	09 fa                	or     %edi,%edx
f01013ff:	89 10                	mov    %edx,(%eax)
		pa += PGSIZE;
f0101401:	81 c7 00 10 00 00    	add    $0x1000,%edi
		va += PGSIZE;
f0101407:	81 c3 00 10 00 00    	add    $0x1000,%ebx
{
	pte_t *pte;
	int i=0;
	
	// xiang dang yu alloc a page
	for(i=0;i<size;i=i+PGSIZE) {
f010140d:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0101413:	39 75 e0             	cmp    %esi,-0x20(%ebp)
f0101416:	77 cb                	ja     f01013e3 <boot_map_region+0x26>
		*pte = pa|perm|PTE_P;
		pa += PGSIZE;
		va += PGSIZE;
	}
	// Fill this function in
}
f0101418:	83 c4 2c             	add    $0x2c,%esp
f010141b:	5b                   	pop    %ebx
f010141c:	5e                   	pop    %esi
f010141d:	5f                   	pop    %edi
f010141e:	5d                   	pop    %ebp
f010141f:	c3                   	ret    

f0101420 <mmio_map_region>:
// location.  Return the base of the reserved region.  size does *not*
// have to be multiple of PGSIZE.
//
void *
mmio_map_region(physaddr_t pa, size_t size)
{
f0101420:	55                   	push   %ebp
f0101421:	89 e5                	mov    %esp,%ebp
f0101423:	53                   	push   %ebx
f0101424:	83 ec 14             	sub    $0x14,%esp
f0101427:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	//
	// Hint: The staff solution uses boot_map_region.
	//
	// Your code here:
	
	boot_map_region(kern_pgdir,base,size,pa,PTE_PCD|PTE_PWT|PTE_W|PTE_P);
f010142a:	c7 44 24 04 1b 00 00 	movl   $0x1b,0x4(%esp)
f0101431:	00 
f0101432:	8b 45 08             	mov    0x8(%ebp),%eax
f0101435:	89 04 24             	mov    %eax,(%esp)
f0101438:	89 d9                	mov    %ebx,%ecx
f010143a:	8b 15 00 03 12 f0    	mov    0xf0120300,%edx
f0101440:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0101445:	e8 73 ff ff ff       	call   f01013bd <boot_map_region>
	base=ROUNDUP((base+size),PGSIZE);
f010144a:	a1 00 03 12 f0       	mov    0xf0120300,%eax
f010144f:	8d 84 03 ff 0f 00 00 	lea    0xfff(%ebx,%eax,1),%eax
f0101456:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010145b:	a3 00 03 12 f0       	mov    %eax,0xf0120300
	cprintf("shuzi%x base %x\n",MMIOLIM-MMIOBASE,base);
f0101460:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101464:	c7 44 24 04 00 00 40 	movl   $0x400000,0x4(%esp)
f010146b:	00 
f010146c:	c7 04 24 7e 74 10 f0 	movl   $0xf010747e,(%esp)
f0101473:	e8 b1 2a 00 00       	call   f0103f29 <cprintf>
	return (void *)base;
	//panic("mmio_map_region not implemented");
}
f0101478:	a1 00 03 12 f0       	mov    0xf0120300,%eax
f010147d:	83 c4 14             	add    $0x14,%esp
f0101480:	5b                   	pop    %ebx
f0101481:	5d                   	pop    %ebp
f0101482:	c3                   	ret    

f0101483 <page_lookup>:
//
// Hint: the TA solution uses pgdir_walk and pa2page.
//
struct PageInfo *
page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0101483:	55                   	push   %ebp
f0101484:	89 e5                	mov    %esp,%ebp
f0101486:	53                   	push   %ebx
f0101487:	83 ec 14             	sub    $0x14,%esp
f010148a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// Fill this function in
	pte_t *temp;
	
	if((temp=pgdir_walk(pgdir,va,0))==NULL)
f010148d:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0101494:	00 
f0101495:	8b 45 0c             	mov    0xc(%ebp),%eax
f0101498:	89 44 24 04          	mov    %eax,0x4(%esp)
f010149c:	8b 45 08             	mov    0x8(%ebp),%eax
f010149f:	89 04 24             	mov    %eax,(%esp)
f01014a2:	e8 56 fd ff ff       	call   f01011fd <pgdir_walk>
f01014a7:	85 c0                	test   %eax,%eax
f01014a9:	74 3e                	je     f01014e9 <page_lookup+0x66>
		return NULL;
	else {
		if(pte_store!=0)
f01014ab:	85 db                	test   %ebx,%ebx
f01014ad:	74 02                	je     f01014b1 <page_lookup+0x2e>
			*pte_store=temp;;	// int **
f01014af:	89 03                	mov    %eax,(%ebx)
		if(*temp & PTE_P)
f01014b1:	8b 00                	mov    (%eax),%eax
f01014b3:	a8 01                	test   $0x1,%al
f01014b5:	74 32                	je     f01014e9 <page_lookup+0x66>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01014b7:	c1 e8 0c             	shr    $0xc,%eax
f01014ba:	3b 05 e8 3e 22 f0    	cmp    0xf0223ee8,%eax
f01014c0:	72 1c                	jb     f01014de <page_lookup+0x5b>
		panic("pa2page called with invalid pa");
f01014c2:	c7 44 24 08 1c 6c 10 	movl   $0xf0106c1c,0x8(%esp)
f01014c9:	f0 
f01014ca:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f01014d1:	00 
f01014d2:	c7 04 24 b7 73 10 f0 	movl   $0xf01073b7,(%esp)
f01014d9:	e8 a7 eb ff ff       	call   f0100085 <_panic>
	return &pages[PGNUM(pa)];
f01014de:	c1 e0 03             	shl    $0x3,%eax
f01014e1:	03 05 f0 3e 22 f0    	add    0xf0223ef0,%eax
			return pa2page(PTE_ADDR(*temp));	// *PTE AND PDE dou cun de shi  0,4096,8192
f01014e7:	eb 05                	jmp    f01014ee <page_lookup+0x6b>
f01014e9:	b8 00 00 00 00       	mov    $0x0,%eax
		else
			return NULL;
	}
}
f01014ee:	83 c4 14             	add    $0x14,%esp
f01014f1:	5b                   	pop    %ebx
f01014f2:	5d                   	pop    %ebp
f01014f3:	c3                   	ret    

f01014f4 <page_remove>:
// Hint: The TA solution is implemented using page_lookup,
// 	tlb_invalidate, and page_decref.
//
void
page_remove(pde_t *pgdir, void *va)
{
f01014f4:	55                   	push   %ebp
f01014f5:	89 e5                	mov    %esp,%ebp
f01014f7:	83 ec 28             	sub    $0x28,%esp
f01014fa:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f01014fd:	89 75 fc             	mov    %esi,-0x4(%ebp)
f0101500:	8b 75 08             	mov    0x8(%ebp),%esi
f0101503:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct PageInfo *temp=NULL;
	pte_t *pte=NULL;
f0101506:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
	
	if((temp=page_lookup(pgdir,va,&pte))==NULL)
f010150d:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0101510:	89 44 24 08          	mov    %eax,0x8(%esp)
f0101514:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101518:	89 34 24             	mov    %esi,(%esp)
f010151b:	e8 63 ff ff ff       	call   f0101483 <page_lookup>
f0101520:	85 c0                	test   %eax,%eax
f0101522:	74 1d                	je     f0101541 <page_remove+0x4d>
		;
	else {
		page_decref(temp);
f0101524:	89 04 24             	mov    %eax,(%esp)
f0101527:	e8 53 f6 ff ff       	call   f0100b7f <page_decref>
		tlb_invalidate(pgdir,va);
f010152c:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0101530:	89 34 24             	mov    %esi,(%esp)
f0101533:	e8 6a f6 ff ff       	call   f0100ba2 <tlb_invalidate>
		*pte=0;	
f0101538:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010153b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	// Fill this function in
}
f0101541:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0101544:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0101547:	89 ec                	mov    %ebp,%esp
f0101549:	5d                   	pop    %ebp
f010154a:	c3                   	ret    

f010154b <page_insert>:
// Hint: The TA solution is implemented using pgdir_walk, page_remove,
// and page2pa.
//
int
page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f010154b:	55                   	push   %ebp
f010154c:	89 e5                	mov    %esp,%ebp
f010154e:	83 ec 28             	sub    $0x28,%esp
f0101551:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0101554:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0101557:	89 7d fc             	mov    %edi,-0x4(%ebp)
f010155a:	8b 75 0c             	mov    0xc(%ebp),%esi
f010155d:	8b 7d 10             	mov    0x10(%ebp),%edi
	// Fill this function inFF
	pte_t *pte;

	pte=pgdir_walk(pgdir,va,1);	
f0101560:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0101567:	00 
f0101568:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010156c:	8b 45 08             	mov    0x8(%ebp),%eax
f010156f:	89 04 24             	mov    %eax,(%esp)
f0101572:	e8 86 fc ff ff       	call   f01011fd <pgdir_walk>
f0101577:	89 c3                	mov    %eax,%ebx
	if(pte == NULL)
f0101579:	b8 fc ff ff ff       	mov    $0xfffffffc,%eax
f010157e:	85 db                	test   %ebx,%ebx
f0101580:	74 66                	je     f01015e8 <page_insert+0x9d>
		return -E_NO_MEM;
	if(*pte & PTE_P) {
f0101582:	8b 03                	mov    (%ebx),%eax
f0101584:	a8 01                	test   $0x1,%al
f0101586:	74 3c                	je     f01015c4 <page_insert+0x79>
		if (PTE_ADDR(*pte) == page2pa (pp)) {
f0101588:	25 00 f0 ff ff       	and    $0xfffff000,%eax
f010158d:	89 f2                	mov    %esi,%edx
f010158f:	2b 15 f0 3e 22 f0    	sub    0xf0223ef0,%edx
f0101595:	c1 fa 03             	sar    $0x3,%edx
f0101598:	c1 e2 0c             	shl    $0xc,%edx
f010159b:	39 d0                	cmp    %edx,%eax
f010159d:	75 16                	jne    f01015b5 <page_insert+0x6a>
			pp -> pp_ref--;			
f010159f:	66 83 6e 04 01       	subw   $0x1,0x4(%esi)
			tlb_invalidate(pgdir, va);
f01015a4:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01015a8:	8b 45 08             	mov    0x8(%ebp),%eax
f01015ab:	89 04 24             	mov    %eax,(%esp)
f01015ae:	e8 ef f5 ff ff       	call   f0100ba2 <tlb_invalidate>
f01015b3:	eb 0f                	jmp    f01015c4 <page_insert+0x79>
		} else 
			page_remove(pgdir, va);
f01015b5:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01015b9:	8b 45 08             	mov    0x8(%ebp),%eax
f01015bc:	89 04 24             	mov    %eax,(%esp)
f01015bf:	e8 30 ff ff ff       	call   f01014f4 <page_remove>
	}			
	pp -> pp_ref++;
f01015c4:	66 83 46 04 01       	addw   $0x1,0x4(%esi)
	*pte=page2pa(pp)|perm|PTE_P;  
f01015c9:	8b 55 14             	mov    0x14(%ebp),%edx
f01015cc:	83 ca 01             	or     $0x1,%edx
f01015cf:	2b 35 f0 3e 22 f0    	sub    0xf0223ef0,%esi
f01015d5:	c1 fe 03             	sar    $0x3,%esi
f01015d8:	89 f0                	mov    %esi,%eax
f01015da:	c1 e0 0c             	shl    $0xc,%eax
f01015dd:	89 d6                	mov    %edx,%esi
f01015df:	09 c6                	or     %eax,%esi
f01015e1:	89 33                	mov    %esi,(%ebx)
f01015e3:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f01015e8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01015eb:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01015ee:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01015f1:	89 ec                	mov    %ebp,%esp
f01015f3:	5d                   	pop    %ebp
f01015f4:	c3                   	ret    

f01015f5 <check_page_installed_pgdir>:
}

// check page_insert, page_remove, &c, with an installed kern_pgdir
static void
check_page_installed_pgdir(void)
{
f01015f5:	55                   	push   %ebp
f01015f6:	89 e5                	mov    %esp,%ebp
f01015f8:	57                   	push   %edi
f01015f9:	56                   	push   %esi
f01015fa:	53                   	push   %ebx
f01015fb:	83 ec 2c             	sub    $0x2c,%esp
	uintptr_t va;
	int i;

	// check that we can read and write installed pages
	pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f01015fe:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101605:	e8 75 fb ff ff       	call   f010117f <page_alloc>
f010160a:	89 c3                	mov    %eax,%ebx
f010160c:	85 c0                	test   %eax,%eax
f010160e:	75 24                	jne    f0101634 <check_page_installed_pgdir+0x3f>
f0101610:	c7 44 24 0c 8f 74 10 	movl   $0xf010748f,0xc(%esp)
f0101617:	f0 
f0101618:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f010161f:	f0 
f0101620:	c7 44 24 04 69 04 00 	movl   $0x469,0x4(%esp)
f0101627:	00 
f0101628:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f010162f:	e8 51 ea ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0101634:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010163b:	e8 3f fb ff ff       	call   f010117f <page_alloc>
f0101640:	89 c7                	mov    %eax,%edi
f0101642:	85 c0                	test   %eax,%eax
f0101644:	75 24                	jne    f010166a <check_page_installed_pgdir+0x75>
f0101646:	c7 44 24 0c a5 74 10 	movl   $0xf01074a5,0xc(%esp)
f010164d:	f0 
f010164e:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101655:	f0 
f0101656:	c7 44 24 04 6a 04 00 	movl   $0x46a,0x4(%esp)
f010165d:	00 
f010165e:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101665:	e8 1b ea ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f010166a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101671:	e8 09 fb ff ff       	call   f010117f <page_alloc>
f0101676:	89 c6                	mov    %eax,%esi
f0101678:	85 c0                	test   %eax,%eax
f010167a:	75 24                	jne    f01016a0 <check_page_installed_pgdir+0xab>
f010167c:	c7 44 24 0c bb 74 10 	movl   $0xf01074bb,0xc(%esp)
f0101683:	f0 
f0101684:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f010168b:	f0 
f010168c:	c7 44 24 04 6b 04 00 	movl   $0x46b,0x4(%esp)
f0101693:	00 
f0101694:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f010169b:	e8 e5 e9 ff ff       	call   f0100085 <_panic>
	page_free(pp0);
f01016a0:	89 1c 24             	mov    %ebx,(%esp)
f01016a3:	e8 bb f4 ff ff       	call   f0100b63 <page_free>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01016a8:	89 f8                	mov    %edi,%eax
f01016aa:	2b 05 f0 3e 22 f0    	sub    0xf0223ef0,%eax
f01016b0:	c1 f8 03             	sar    $0x3,%eax
f01016b3:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01016b6:	89 c2                	mov    %eax,%edx
f01016b8:	c1 ea 0c             	shr    $0xc,%edx
f01016bb:	3b 15 e8 3e 22 f0    	cmp    0xf0223ee8,%edx
f01016c1:	72 20                	jb     f01016e3 <check_page_installed_pgdir+0xee>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01016c3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01016c7:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f01016ce:	f0 
f01016cf:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01016d6:	00 
f01016d7:	c7 04 24 b7 73 10 f0 	movl   $0xf01073b7,(%esp)
f01016de:	e8 a2 e9 ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp1), 1, PGSIZE);
f01016e3:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01016ea:	00 
f01016eb:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f01016f2:	00 
f01016f3:	2d 00 00 00 10       	sub    $0x10000000,%eax
f01016f8:	89 04 24             	mov    %eax,(%esp)
f01016fb:	e8 86 40 00 00       	call   f0105786 <memset>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101700:	89 75 e4             	mov    %esi,-0x1c(%ebp)
f0101703:	89 f0                	mov    %esi,%eax
f0101705:	2b 05 f0 3e 22 f0    	sub    0xf0223ef0,%eax
f010170b:	c1 f8 03             	sar    $0x3,%eax
f010170e:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101711:	89 c2                	mov    %eax,%edx
f0101713:	c1 ea 0c             	shr    $0xc,%edx
f0101716:	3b 15 e8 3e 22 f0    	cmp    0xf0223ee8,%edx
f010171c:	72 20                	jb     f010173e <check_page_installed_pgdir+0x149>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010171e:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101722:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f0101729:	f0 
f010172a:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101731:	00 
f0101732:	c7 04 24 b7 73 10 f0 	movl   $0xf01073b7,(%esp)
f0101739:	e8 47 e9 ff ff       	call   f0100085 <_panic>
	memset(page2kva(pp2), 2, PGSIZE);
f010173e:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101745:	00 
f0101746:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010174d:	00 
f010174e:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101753:	89 04 24             	mov    %eax,(%esp)
f0101756:	e8 2b 40 00 00       	call   f0105786 <memset>
	page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W);
f010175b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0101762:	00 
f0101763:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010176a:	00 
f010176b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010176f:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0101774:	89 04 24             	mov    %eax,(%esp)
f0101777:	e8 cf fd ff ff       	call   f010154b <page_insert>
	assert(pp1->pp_ref == 1);
f010177c:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0101781:	74 24                	je     f01017a7 <check_page_installed_pgdir+0x1b2>
f0101783:	c7 44 24 0c d1 74 10 	movl   $0xf01074d1,0xc(%esp)
f010178a:	f0 
f010178b:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101792:	f0 
f0101793:	c7 44 24 04 70 04 00 	movl   $0x470,0x4(%esp)
f010179a:	00 
f010179b:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01017a2:	e8 de e8 ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)PGSIZE == 0x01010101U);
f01017a7:	81 3d 00 10 00 00 01 	cmpl   $0x1010101,0x1000
f01017ae:	01 01 01 
f01017b1:	74 24                	je     f01017d7 <check_page_installed_pgdir+0x1e2>
f01017b3:	c7 44 24 0c 3c 6c 10 	movl   $0xf0106c3c,0xc(%esp)
f01017ba:	f0 
f01017bb:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f01017c2:	f0 
f01017c3:	c7 44 24 04 71 04 00 	movl   $0x471,0x4(%esp)
f01017ca:	00 
f01017cb:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01017d2:	e8 ae e8 ff ff       	call   f0100085 <_panic>
	page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W);
f01017d7:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01017de:	00 
f01017df:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01017e6:	00 
f01017e7:	89 74 24 04          	mov    %esi,0x4(%esp)
f01017eb:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f01017f0:	89 04 24             	mov    %eax,(%esp)
f01017f3:	e8 53 fd ff ff       	call   f010154b <page_insert>
	assert(*(uint32_t *)PGSIZE == 0x02020202U);
f01017f8:	81 3d 00 10 00 00 02 	cmpl   $0x2020202,0x1000
f01017ff:	02 02 02 
f0101802:	74 24                	je     f0101828 <check_page_installed_pgdir+0x233>
f0101804:	c7 44 24 0c 60 6c 10 	movl   $0xf0106c60,0xc(%esp)
f010180b:	f0 
f010180c:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101813:	f0 
f0101814:	c7 44 24 04 73 04 00 	movl   $0x473,0x4(%esp)
f010181b:	00 
f010181c:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101823:	e8 5d e8 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f0101828:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f010182d:	74 24                	je     f0101853 <check_page_installed_pgdir+0x25e>
f010182f:	c7 44 24 0c e2 74 10 	movl   $0xf01074e2,0xc(%esp)
f0101836:	f0 
f0101837:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f010183e:	f0 
f010183f:	c7 44 24 04 74 04 00 	movl   $0x474,0x4(%esp)
f0101846:	00 
f0101847:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f010184e:	e8 32 e8 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f0101853:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0101858:	74 24                	je     f010187e <check_page_installed_pgdir+0x289>
f010185a:	c7 44 24 0c f3 74 10 	movl   $0xf01074f3,0xc(%esp)
f0101861:	f0 
f0101862:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101869:	f0 
f010186a:	c7 44 24 04 75 04 00 	movl   $0x475,0x4(%esp)
f0101871:	00 
f0101872:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101879:	e8 07 e8 ff ff       	call   f0100085 <_panic>
	*(uint32_t *)PGSIZE = 0x03030303U;
f010187e:	c7 05 00 10 00 00 03 	movl   $0x3030303,0x1000
f0101885:	03 03 03 
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101888:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010188b:	2b 05 f0 3e 22 f0    	sub    0xf0223ef0,%eax
f0101891:	c1 f8 03             	sar    $0x3,%eax
f0101894:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101897:	89 c2                	mov    %eax,%edx
f0101899:	c1 ea 0c             	shr    $0xc,%edx
f010189c:	3b 15 e8 3e 22 f0    	cmp    0xf0223ee8,%edx
f01018a2:	72 20                	jb     f01018c4 <check_page_installed_pgdir+0x2cf>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01018a4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01018a8:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f01018af:	f0 
f01018b0:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f01018b7:	00 
f01018b8:	c7 04 24 b7 73 10 f0 	movl   $0xf01073b7,(%esp)
f01018bf:	e8 c1 e7 ff ff       	call   f0100085 <_panic>
	assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f01018c4:	81 b8 00 00 00 f0 03 	cmpl   $0x3030303,-0x10000000(%eax)
f01018cb:	03 03 03 
f01018ce:	74 24                	je     f01018f4 <check_page_installed_pgdir+0x2ff>
f01018d0:	c7 44 24 0c 84 6c 10 	movl   $0xf0106c84,0xc(%esp)
f01018d7:	f0 
f01018d8:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f01018df:	f0 
f01018e0:	c7 44 24 04 77 04 00 	movl   $0x477,0x4(%esp)
f01018e7:	00 
f01018e8:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01018ef:	e8 91 e7 ff ff       	call   f0100085 <_panic>
	page_remove(kern_pgdir, (void*) PGSIZE);
f01018f4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01018fb:	00 
f01018fc:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0101901:	89 04 24             	mov    %eax,(%esp)
f0101904:	e8 eb fb ff ff       	call   f01014f4 <page_remove>
	assert(pp2->pp_ref == 0);
f0101909:	66 83 7e 04 00       	cmpw   $0x0,0x4(%esi)
f010190e:	74 24                	je     f0101934 <check_page_installed_pgdir+0x33f>
f0101910:	c7 44 24 0c 04 75 10 	movl   $0xf0107504,0xc(%esp)
f0101917:	f0 
f0101918:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f010191f:	f0 
f0101920:	c7 44 24 04 79 04 00 	movl   $0x479,0x4(%esp)
f0101927:	00 
f0101928:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f010192f:	e8 51 e7 ff ff       	call   f0100085 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0101934:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0101939:	8b 08                	mov    (%eax),%ecx
f010193b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0101941:	89 da                	mov    %ebx,%edx
f0101943:	2b 15 f0 3e 22 f0    	sub    0xf0223ef0,%edx
f0101949:	c1 fa 03             	sar    $0x3,%edx
f010194c:	c1 e2 0c             	shl    $0xc,%edx
f010194f:	39 d1                	cmp    %edx,%ecx
f0101951:	74 24                	je     f0101977 <check_page_installed_pgdir+0x382>
f0101953:	c7 44 24 0c b0 6c 10 	movl   $0xf0106cb0,0xc(%esp)
f010195a:	f0 
f010195b:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101962:	f0 
f0101963:	c7 44 24 04 7c 04 00 	movl   $0x47c,0x4(%esp)
f010196a:	00 
f010196b:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101972:	e8 0e e7 ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f0101977:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f010197d:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0101982:	74 24                	je     f01019a8 <check_page_installed_pgdir+0x3b3>
f0101984:	c7 44 24 0c 15 75 10 	movl   $0xf0107515,0xc(%esp)
f010198b:	f0 
f010198c:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101993:	f0 
f0101994:	c7 44 24 04 7e 04 00 	movl   $0x47e,0x4(%esp)
f010199b:	00 
f010199c:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01019a3:	e8 dd e6 ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f01019a8:	66 c7 43 04 00 00    	movw   $0x0,0x4(%ebx)

	// free the pages we took
	page_free(pp0);
f01019ae:	89 1c 24             	mov    %ebx,(%esp)
f01019b1:	e8 ad f1 ff ff       	call   f0100b63 <page_free>

	cprintf("check_page_installed_pgdir() succeeded!\n");
f01019b6:	c7 04 24 d8 6c 10 f0 	movl   $0xf0106cd8,(%esp)
f01019bd:	e8 67 25 00 00       	call   f0103f29 <cprintf>
}
f01019c2:	83 c4 2c             	add    $0x2c,%esp
f01019c5:	5b                   	pop    %ebx
f01019c6:	5e                   	pop    %esi
f01019c7:	5f                   	pop    %edi
f01019c8:	5d                   	pop    %ebp
f01019c9:	c3                   	ret    

f01019ca <mem_init>:
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
{
f01019ca:	55                   	push   %ebp
f01019cb:	89 e5                	mov    %esp,%ebp
f01019cd:	57                   	push   %edi
f01019ce:	56                   	push   %esi
f01019cf:	53                   	push   %ebx
f01019d0:	83 ec 3c             	sub    $0x3c,%esp
	uint32_t cr0;
	size_t n;

	// Find out how much memory the machine has (npages & npages_basemem).
	i386_detect_memory();
f01019d3:	e8 97 f2 ff ff       	call   f0100c6f <i386_detect_memory>
	// Remove this line when you're ready to test this function.
	//panic("mem_init: This function is not finished\n");

	//////////////////////////////////////////////////////////////////////
	// create initial page directory.
	kern_pgdir = (pde_t *) boot_alloc(PGSIZE);
f01019d8:	b8 00 10 00 00       	mov    $0x1000,%eax
f01019dd:	e8 3e f1 ff ff       	call   f0100b20 <boot_alloc>
f01019e2:	a3 ec 3e 22 f0       	mov    %eax,0xf0223eec
	memset(kern_pgdir, 0, PGSIZE);
f01019e7:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01019ee:	00 
f01019ef:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01019f6:	00 
f01019f7:	89 04 24             	mov    %eax,(%esp)
f01019fa:	e8 87 3d 00 00       	call   f0105786 <memset>
	// a virtual page table at virtual address UVPT.
	// (For now, you don't have understand the greater purpose of the
	// following line.)

	// Permissions: kernel R, user R
	kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
f01019ff:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0101a04:	89 c2                	mov    %eax,%edx
f0101a06:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0101a0b:	77 20                	ja     f0101a2d <mem_init+0x63>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0101a0d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101a11:	c7 44 24 08 dc 65 10 	movl   $0xf01065dc,0x8(%esp)
f0101a18:	f0 
f0101a19:	c7 44 24 04 96 00 00 	movl   $0x96,0x4(%esp)
f0101a20:	00 
f0101a21:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101a28:	e8 58 e6 ff ff       	call   f0100085 <_panic>
f0101a2d:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0101a33:	83 ca 05             	or     $0x5,%edx
f0101a36:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// The kernel uses this array to keep track of physical pages: for
	// each physical page, there is a corresponding struct PageInfo in this
	// array.  'npages' is the number of physical pages in memory.
	// Your code goes here:
	
	pages = (struct PageInfo *)boot_alloc(npages* sizeof(struct PageInfo));
f0101a3c:	a1 e8 3e 22 f0       	mov    0xf0223ee8,%eax
f0101a41:	c1 e0 03             	shl    $0x3,%eax
f0101a44:	e8 d7 f0 ff ff       	call   f0100b20 <boot_alloc>
f0101a49:	a3 f0 3e 22 f0       	mov    %eax,0xf0223ef0

	//////////////////////////////////////////////////////////////////////
	// Make 'envs' point to an array of size 'NENV' of 'struct Env'.
	// LAB 3: Your code here.
	
	envs = (struct Env *)boot_alloc(NENV * sizeof(struct Env));
f0101a4e:	b8 00 f0 01 00       	mov    $0x1f000,%eax
f0101a53:	e8 c8 f0 ff ff       	call   f0100b20 <boot_alloc>
f0101a58:	a3 38 32 22 f0       	mov    %eax,0xf0223238
	// Now that we've allocated the initial kernel data structures, we set
	// up the list of free physical pages. Once we've done so, all further
	// memory management will go through the page_* functions. In
	// particular, we can now map memory using boot_map_region
	// or page_insert
	page_init();
f0101a5d:	e8 a2 f2 ff ff       	call   f0100d04 <page_init>

	check_page_free_list(1);
f0101a62:	b8 01 00 00 00       	mov    $0x1,%eax
f0101a67:	e8 6f f3 ff ff       	call   f0100ddb <check_page_free_list>
	int nfree;
	struct PageInfo *fl;
	char *c;
	int i;

	if (!pages)
f0101a6c:	83 3d f0 3e 22 f0 00 	cmpl   $0x0,0xf0223ef0
f0101a73:	75 1c                	jne    f0101a91 <mem_init+0xc7>
		panic("'pages' is a null pointer!");
f0101a75:	c7 44 24 08 26 75 10 	movl   $0xf0107526,0x8(%esp)
f0101a7c:	f0 
f0101a7d:	c7 44 24 04 13 03 00 	movl   $0x313,0x4(%esp)
f0101a84:	00 
f0101a85:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101a8c:	e8 f4 e5 ff ff       	call   f0100085 <_panic>

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101a91:	a1 30 32 22 f0       	mov    0xf0223230,%eax
f0101a96:	bb 00 00 00 00       	mov    $0x0,%ebx
f0101a9b:	85 c0                	test   %eax,%eax
f0101a9d:	74 09                	je     f0101aa8 <mem_init+0xde>
		++nfree;
f0101a9f:	83 c3 01             	add    $0x1,%ebx

	if (!pages)
		panic("'pages' is a null pointer!");

	// check number of free pages
	for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101aa2:	8b 00                	mov    (%eax),%eax
f0101aa4:	85 c0                	test   %eax,%eax
f0101aa6:	75 f7                	jne    f0101a9f <mem_init+0xd5>
		++nfree;
	// panic("vd %d %d",page2pa(page_free_list)/PGSIZE,nfree); 1024 1023 HOU

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101aa8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101aaf:	e8 cb f6 ff ff       	call   f010117f <page_alloc>
f0101ab4:	89 c6                	mov    %eax,%esi
f0101ab6:	85 c0                	test   %eax,%eax
f0101ab8:	75 24                	jne    f0101ade <mem_init+0x114>
f0101aba:	c7 44 24 0c 8f 74 10 	movl   $0xf010748f,0xc(%esp)
f0101ac1:	f0 
f0101ac2:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101ac9:	f0 
f0101aca:	c7 44 24 04 1c 03 00 	movl   $0x31c,0x4(%esp)
f0101ad1:	00 
f0101ad2:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101ad9:	e8 a7 e5 ff ff       	call   f0100085 <_panic>
	//panic("vdsd %d",page2pa(pp0)/PGSIZE);
	assert((pp1 = page_alloc(0)));
f0101ade:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ae5:	e8 95 f6 ff ff       	call   f010117f <page_alloc>
f0101aea:	89 c7                	mov    %eax,%edi
f0101aec:	85 c0                	test   %eax,%eax
f0101aee:	75 24                	jne    f0101b14 <mem_init+0x14a>
f0101af0:	c7 44 24 0c a5 74 10 	movl   $0xf01074a5,0xc(%esp)
f0101af7:	f0 
f0101af8:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101aff:	f0 
f0101b00:	c7 44 24 04 1e 03 00 	movl   $0x31e,0x4(%esp)
f0101b07:	00 
f0101b08:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101b0f:	e8 71 e5 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0101b14:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101b1b:	e8 5f f6 ff ff       	call   f010117f <page_alloc>
f0101b20:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101b23:	85 c0                	test   %eax,%eax
f0101b25:	75 24                	jne    f0101b4b <mem_init+0x181>
f0101b27:	c7 44 24 0c bb 74 10 	movl   $0xf01074bb,0xc(%esp)
f0101b2e:	f0 
f0101b2f:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101b36:	f0 
f0101b37:	c7 44 24 04 1f 03 00 	movl   $0x31f,0x4(%esp)
f0101b3e:	00 
f0101b3f:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101b46:	e8 3a e5 ff ff       	call   f0100085 <_panic>

	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101b4b:	39 fe                	cmp    %edi,%esi
f0101b4d:	75 24                	jne    f0101b73 <mem_init+0x1a9>
f0101b4f:	c7 44 24 0c 41 75 10 	movl   $0xf0107541,0xc(%esp)
f0101b56:	f0 
f0101b57:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101b5e:	f0 
f0101b5f:	c7 44 24 04 22 03 00 	movl   $0x322,0x4(%esp)
f0101b66:	00 
f0101b67:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101b6e:	e8 12 e5 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101b73:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101b76:	74 05                	je     f0101b7d <mem_init+0x1b3>
f0101b78:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101b7b:	75 24                	jne    f0101ba1 <mem_init+0x1d7>
f0101b7d:	c7 44 24 0c 04 6d 10 	movl   $0xf0106d04,0xc(%esp)
f0101b84:	f0 
f0101b85:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101b8c:	f0 
f0101b8d:	c7 44 24 04 23 03 00 	movl   $0x323,0x4(%esp)
f0101b94:	00 
f0101b95:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101b9c:	e8 e4 e4 ff ff       	call   f0100085 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101ba1:	8b 15 f0 3e 22 f0    	mov    0xf0223ef0,%edx
	//panic("vd %d",(pp0-pp1));
	assert(page2pa(pp0) < npages*PGSIZE);
f0101ba7:	a1 e8 3e 22 f0       	mov    0xf0223ee8,%eax
f0101bac:	c1 e0 0c             	shl    $0xc,%eax
f0101baf:	89 f1                	mov    %esi,%ecx
f0101bb1:	29 d1                	sub    %edx,%ecx
f0101bb3:	c1 f9 03             	sar    $0x3,%ecx
f0101bb6:	c1 e1 0c             	shl    $0xc,%ecx
f0101bb9:	39 c1                	cmp    %eax,%ecx
f0101bbb:	72 24                	jb     f0101be1 <mem_init+0x217>
f0101bbd:	c7 44 24 0c 53 75 10 	movl   $0xf0107553,0xc(%esp)
f0101bc4:	f0 
f0101bc5:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101bcc:	f0 
f0101bcd:	c7 44 24 04 25 03 00 	movl   $0x325,0x4(%esp)
f0101bd4:	00 
f0101bd5:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101bdc:	e8 a4 e4 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp1) < npages*PGSIZE);
f0101be1:	89 f9                	mov    %edi,%ecx
f0101be3:	29 d1                	sub    %edx,%ecx
f0101be5:	c1 f9 03             	sar    $0x3,%ecx
f0101be8:	c1 e1 0c             	shl    $0xc,%ecx
f0101beb:	39 c8                	cmp    %ecx,%eax
f0101bed:	77 24                	ja     f0101c13 <mem_init+0x249>
f0101bef:	c7 44 24 0c 70 75 10 	movl   $0xf0107570,0xc(%esp)
f0101bf6:	f0 
f0101bf7:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101bfe:	f0 
f0101bff:	c7 44 24 04 26 03 00 	movl   $0x326,0x4(%esp)
f0101c06:	00 
f0101c07:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101c0e:	e8 72 e4 ff ff       	call   f0100085 <_panic>
	assert(page2pa(pp2) < npages*PGSIZE);
f0101c13:	8b 4d d4             	mov    -0x2c(%ebp),%ecx
f0101c16:	29 d1                	sub    %edx,%ecx
f0101c18:	89 ca                	mov    %ecx,%edx
f0101c1a:	c1 fa 03             	sar    $0x3,%edx
f0101c1d:	c1 e2 0c             	shl    $0xc,%edx
f0101c20:	39 d0                	cmp    %edx,%eax
f0101c22:	77 24                	ja     f0101c48 <mem_init+0x27e>
f0101c24:	c7 44 24 0c 8d 75 10 	movl   $0xf010758d,0xc(%esp)
f0101c2b:	f0 
f0101c2c:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101c33:	f0 
f0101c34:	c7 44 24 04 27 03 00 	movl   $0x327,0x4(%esp)
f0101c3b:	00 
f0101c3c:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101c43:	e8 3d e4 ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0101c48:	a1 30 32 22 f0       	mov    0xf0223230,%eax
f0101c4d:	89 45 cc             	mov    %eax,-0x34(%ebp)
	page_free_list = 0;
f0101c50:	c7 05 30 32 22 f0 00 	movl   $0x0,0xf0223230
f0101c57:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0101c5a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101c61:	e8 19 f5 ff ff       	call   f010117f <page_alloc>
f0101c66:	85 c0                	test   %eax,%eax
f0101c68:	74 24                	je     f0101c8e <mem_init+0x2c4>
f0101c6a:	c7 44 24 0c aa 75 10 	movl   $0xf01075aa,0xc(%esp)
f0101c71:	f0 
f0101c72:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101c79:	f0 
f0101c7a:	c7 44 24 04 2e 03 00 	movl   $0x32e,0x4(%esp)
f0101c81:	00 
f0101c82:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101c89:	e8 f7 e3 ff ff       	call   f0100085 <_panic>

	// free and re-allocate?
	page_free(pp0);
f0101c8e:	89 34 24             	mov    %esi,(%esp)
f0101c91:	e8 cd ee ff ff       	call   f0100b63 <page_free>
	page_free(pp1);
f0101c96:	89 3c 24             	mov    %edi,(%esp)
f0101c99:	e8 c5 ee ff ff       	call   f0100b63 <page_free>
	page_free(pp2);
f0101c9e:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0101ca1:	89 14 24             	mov    %edx,(%esp)
f0101ca4:	e8 ba ee ff ff       	call   f0100b63 <page_free>
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101ca9:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101cb0:	e8 ca f4 ff ff       	call   f010117f <page_alloc>
f0101cb5:	89 c6                	mov    %eax,%esi
f0101cb7:	85 c0                	test   %eax,%eax
f0101cb9:	75 24                	jne    f0101cdf <mem_init+0x315>
f0101cbb:	c7 44 24 0c 8f 74 10 	movl   $0xf010748f,0xc(%esp)
f0101cc2:	f0 
f0101cc3:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101cca:	f0 
f0101ccb:	c7 44 24 04 35 03 00 	movl   $0x335,0x4(%esp)
f0101cd2:	00 
f0101cd3:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101cda:	e8 a6 e3 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0101cdf:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ce6:	e8 94 f4 ff ff       	call   f010117f <page_alloc>
f0101ceb:	89 c7                	mov    %eax,%edi
f0101ced:	85 c0                	test   %eax,%eax
f0101cef:	75 24                	jne    f0101d15 <mem_init+0x34b>
f0101cf1:	c7 44 24 0c a5 74 10 	movl   $0xf01074a5,0xc(%esp)
f0101cf8:	f0 
f0101cf9:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101d00:	f0 
f0101d01:	c7 44 24 04 36 03 00 	movl   $0x336,0x4(%esp)
f0101d08:	00 
f0101d09:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101d10:	e8 70 e3 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0101d15:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101d1c:	e8 5e f4 ff ff       	call   f010117f <page_alloc>
f0101d21:	89 45 d4             	mov    %eax,-0x2c(%ebp)
f0101d24:	85 c0                	test   %eax,%eax
f0101d26:	75 24                	jne    f0101d4c <mem_init+0x382>
f0101d28:	c7 44 24 0c bb 74 10 	movl   $0xf01074bb,0xc(%esp)
f0101d2f:	f0 
f0101d30:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101d37:	f0 
f0101d38:	c7 44 24 04 37 03 00 	movl   $0x337,0x4(%esp)
f0101d3f:	00 
f0101d40:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101d47:	e8 39 e3 ff ff       	call   f0100085 <_panic>
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0101d4c:	39 fe                	cmp    %edi,%esi
f0101d4e:	75 24                	jne    f0101d74 <mem_init+0x3aa>
f0101d50:	c7 44 24 0c 41 75 10 	movl   $0xf0107541,0xc(%esp)
f0101d57:	f0 
f0101d58:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101d5f:	f0 
f0101d60:	c7 44 24 04 39 03 00 	movl   $0x339,0x4(%esp)
f0101d67:	00 
f0101d68:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101d6f:	e8 11 e3 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101d74:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
f0101d77:	74 05                	je     f0101d7e <mem_init+0x3b4>
f0101d79:	3b 75 d4             	cmp    -0x2c(%ebp),%esi
f0101d7c:	75 24                	jne    f0101da2 <mem_init+0x3d8>
f0101d7e:	c7 44 24 0c 04 6d 10 	movl   $0xf0106d04,0xc(%esp)
f0101d85:	f0 
f0101d86:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101d8d:	f0 
f0101d8e:	c7 44 24 04 3a 03 00 	movl   $0x33a,0x4(%esp)
f0101d95:	00 
f0101d96:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101d9d:	e8 e3 e2 ff ff       	call   f0100085 <_panic>
	assert(!page_alloc(0));
f0101da2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101da9:	e8 d1 f3 ff ff       	call   f010117f <page_alloc>
f0101dae:	85 c0                	test   %eax,%eax
f0101db0:	74 24                	je     f0101dd6 <mem_init+0x40c>
f0101db2:	c7 44 24 0c aa 75 10 	movl   $0xf01075aa,0xc(%esp)
f0101db9:	f0 
f0101dba:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101dc1:	f0 
f0101dc2:	c7 44 24 04 3b 03 00 	movl   $0x33b,0x4(%esp)
f0101dc9:	00 
f0101dca:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101dd1:	e8 af e2 ff ff       	call   f0100085 <_panic>
f0101dd6:	89 75 d0             	mov    %esi,-0x30(%ebp)
f0101dd9:	89 f0                	mov    %esi,%eax
f0101ddb:	2b 05 f0 3e 22 f0    	sub    0xf0223ef0,%eax
f0101de1:	c1 f8 03             	sar    $0x3,%eax
f0101de4:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101de7:	89 c2                	mov    %eax,%edx
f0101de9:	c1 ea 0c             	shr    $0xc,%edx
f0101dec:	3b 15 e8 3e 22 f0    	cmp    0xf0223ee8,%edx
f0101df2:	72 20                	jb     f0101e14 <mem_init+0x44a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101df4:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0101df8:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f0101dff:	f0 
f0101e00:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101e07:	00 
f0101e08:	c7 04 24 b7 73 10 f0 	movl   $0xf01073b7,(%esp)
f0101e0f:	e8 71 e2 ff ff       	call   f0100085 <_panic>

	// test flags
	memset(page2kva(pp0), 1, PGSIZE);
f0101e14:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0101e1b:	00 
f0101e1c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
f0101e23:	00 
f0101e24:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0101e29:	89 04 24             	mov    %eax,(%esp)
f0101e2c:	e8 55 39 00 00       	call   f0105786 <memset>
	page_free(pp0);
f0101e31:	89 34 24             	mov    %esi,(%esp)
f0101e34:	e8 2a ed ff ff       	call   f0100b63 <page_free>
	//panic("qsdf %d",ALLOC_ZERO);
	assert((pp = page_alloc(ALLOC_ZERO)));
f0101e39:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0101e40:	e8 3a f3 ff ff       	call   f010117f <page_alloc>
f0101e45:	85 c0                	test   %eax,%eax
f0101e47:	75 24                	jne    f0101e6d <mem_init+0x4a3>
f0101e49:	c7 44 24 0c b9 75 10 	movl   $0xf01075b9,0xc(%esp)
f0101e50:	f0 
f0101e51:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101e58:	f0 
f0101e59:	c7 44 24 04 41 03 00 	movl   $0x341,0x4(%esp)
f0101e60:	00 
f0101e61:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101e68:	e8 18 e2 ff ff       	call   f0100085 <_panic>
	assert(pp && pp0 == pp);
f0101e6d:	39 c6                	cmp    %eax,%esi
f0101e6f:	74 24                	je     f0101e95 <mem_init+0x4cb>
f0101e71:	c7 44 24 0c d7 75 10 	movl   $0xf01075d7,0xc(%esp)
f0101e78:	f0 
f0101e79:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101e80:	f0 
f0101e81:	c7 44 24 04 42 03 00 	movl   $0x342,0x4(%esp)
f0101e88:	00 
f0101e89:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101e90:	e8 f0 e1 ff ff       	call   f0100085 <_panic>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101e95:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0101e98:	2b 15 f0 3e 22 f0    	sub    0xf0223ef0,%edx
f0101e9e:	c1 fa 03             	sar    $0x3,%edx
f0101ea1:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101ea4:	89 d0                	mov    %edx,%eax
f0101ea6:	c1 e8 0c             	shr    $0xc,%eax
f0101ea9:	3b 05 e8 3e 22 f0    	cmp    0xf0223ee8,%eax
f0101eaf:	72 20                	jb     f0101ed1 <mem_init+0x507>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101eb1:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0101eb5:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f0101ebc:	f0 
f0101ebd:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0101ec4:	00 
f0101ec5:	c7 04 24 b7 73 10 f0 	movl   $0xf01073b7,(%esp)
f0101ecc:	e8 b4 e1 ff ff       	call   f0100085 <_panic>
	//panic("qsdf %d %0x",page2pa(pp)/PGSIZE,page2kva(pp));
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101ed1:	80 ba 00 00 00 f0 00 	cmpb   $0x0,-0x10000000(%edx)
f0101ed8:	75 11                	jne    f0101eeb <mem_init+0x521>
f0101eda:	8d 82 01 00 00 f0    	lea    -0xfffffff(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0101ee0:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	//panic("qsdf %d %0x",page2pa(pp)/PGSIZE,page2kva(pp));
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
		assert(c[i] == 0);
f0101ee6:	80 38 00             	cmpb   $0x0,(%eax)
f0101ee9:	74 24                	je     f0101f0f <mem_init+0x545>
f0101eeb:	c7 44 24 0c e7 75 10 	movl   $0xf01075e7,0xc(%esp)
f0101ef2:	f0 
f0101ef3:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101efa:	f0 
f0101efb:	c7 44 24 04 46 03 00 	movl   $0x346,0x4(%esp)
f0101f02:	00 
f0101f03:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101f0a:	e8 76 e1 ff ff       	call   f0100085 <_panic>
f0101f0f:	83 c0 01             	add    $0x1,%eax
	//panic("qsdf %d",ALLOC_ZERO);
	assert((pp = page_alloc(ALLOC_ZERO)));
	assert(pp && pp0 == pp);
	//panic("qsdf %d %0x",page2pa(pp)/PGSIZE,page2kva(pp));
	c = page2kva(pp);
	for (i = 0; i < PGSIZE; i++)
f0101f12:	39 d0                	cmp    %edx,%eax
f0101f14:	75 d0                	jne    f0101ee6 <mem_init+0x51c>
		assert(c[i] == 0);

	// give free list back
	page_free_list = fl;
f0101f16:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0101f19:	89 0d 30 32 22 f0    	mov    %ecx,0xf0223230

	// free the pages we took
	page_free(pp0);
f0101f1f:	89 34 24             	mov    %esi,(%esp)
f0101f22:	e8 3c ec ff ff       	call   f0100b63 <page_free>
	page_free(pp1);
f0101f27:	89 3c 24             	mov    %edi,(%esp)
f0101f2a:	e8 34 ec ff ff       	call   f0100b63 <page_free>
	page_free(pp2);
f0101f2f:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0101f32:	89 04 24             	mov    %eax,(%esp)
f0101f35:	e8 29 ec ff ff       	call   f0100b63 <page_free>

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101f3a:	a1 30 32 22 f0       	mov    0xf0223230,%eax
f0101f3f:	85 c0                	test   %eax,%eax
f0101f41:	74 09                	je     f0101f4c <mem_init+0x582>
		--nfree;
f0101f43:	83 eb 01             	sub    $0x1,%ebx
	page_free(pp0);
	page_free(pp1);
	page_free(pp2);

	// number of free pages should be the same
	for (pp = page_free_list; pp; pp = pp->pp_link)
f0101f46:	8b 00                	mov    (%eax),%eax
f0101f48:	85 c0                	test   %eax,%eax
f0101f4a:	75 f7                	jne    f0101f43 <mem_init+0x579>
		--nfree;
	assert(nfree == 0);
f0101f4c:	85 db                	test   %ebx,%ebx
f0101f4e:	74 24                	je     f0101f74 <mem_init+0x5aa>
f0101f50:	c7 44 24 0c f1 75 10 	movl   $0xf01075f1,0xc(%esp)
f0101f57:	f0 
f0101f58:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101f5f:	f0 
f0101f60:	c7 44 24 04 53 03 00 	movl   $0x353,0x4(%esp)
f0101f67:	00 
f0101f68:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101f6f:	e8 11 e1 ff ff       	call   f0100085 <_panic>

	cprintf("check_page_alloc() succeeded!\n");
f0101f74:	c7 04 24 24 6d 10 f0 	movl   $0xf0106d24,(%esp)
f0101f7b:	e8 a9 1f 00 00       	call   f0103f29 <cprintf>
	int i;
	extern pde_t entry_pgdir[];

	// should be able to allocate three pages
	pp0 = pp1 = pp2 = 0;
	assert((pp0 = page_alloc(0)));
f0101f80:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101f87:	e8 f3 f1 ff ff       	call   f010117f <page_alloc>
f0101f8c:	89 c6                	mov    %eax,%esi
f0101f8e:	85 c0                	test   %eax,%eax
f0101f90:	75 24                	jne    f0101fb6 <mem_init+0x5ec>
f0101f92:	c7 44 24 0c 8f 74 10 	movl   $0xf010748f,0xc(%esp)
f0101f99:	f0 
f0101f9a:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101fa1:	f0 
f0101fa2:	c7 44 24 04 b9 03 00 	movl   $0x3b9,0x4(%esp)
f0101fa9:	00 
f0101faa:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101fb1:	e8 cf e0 ff ff       	call   f0100085 <_panic>
	assert((pp1 = page_alloc(0)));
f0101fb6:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101fbd:	e8 bd f1 ff ff       	call   f010117f <page_alloc>
f0101fc2:	89 c7                	mov    %eax,%edi
f0101fc4:	85 c0                	test   %eax,%eax
f0101fc6:	75 24                	jne    f0101fec <mem_init+0x622>
f0101fc8:	c7 44 24 0c a5 74 10 	movl   $0xf01074a5,0xc(%esp)
f0101fcf:	f0 
f0101fd0:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0101fd7:	f0 
f0101fd8:	c7 44 24 04 ba 03 00 	movl   $0x3ba,0x4(%esp)
f0101fdf:	00 
f0101fe0:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0101fe7:	e8 99 e0 ff ff       	call   f0100085 <_panic>
	assert((pp2 = page_alloc(0)));
f0101fec:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0101ff3:	e8 87 f1 ff ff       	call   f010117f <page_alloc>
f0101ff8:	89 c3                	mov    %eax,%ebx
f0101ffa:	85 c0                	test   %eax,%eax
f0101ffc:	75 24                	jne    f0102022 <mem_init+0x658>
f0101ffe:	c7 44 24 0c bb 74 10 	movl   $0xf01074bb,0xc(%esp)
f0102005:	f0 
f0102006:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f010200d:	f0 
f010200e:	c7 44 24 04 bb 03 00 	movl   $0x3bb,0x4(%esp)
f0102015:	00 
f0102016:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f010201d:	e8 63 e0 ff ff       	call   f0100085 <_panic>
	//panic("daodi1 %d",pp2->pp_ref); 0
	assert(pp0);
	assert(pp1 && pp1 != pp0);
f0102022:	39 fe                	cmp    %edi,%esi
f0102024:	75 24                	jne    f010204a <mem_init+0x680>
f0102026:	c7 44 24 0c 41 75 10 	movl   $0xf0107541,0xc(%esp)
f010202d:	f0 
f010202e:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102035:	f0 
f0102036:	c7 44 24 04 be 03 00 	movl   $0x3be,0x4(%esp)
f010203d:	00 
f010203e:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102045:	e8 3b e0 ff ff       	call   f0100085 <_panic>
	assert(pp2 && pp2 != pp1 && pp2 != pp0);
f010204a:	39 c7                	cmp    %eax,%edi
f010204c:	74 04                	je     f0102052 <mem_init+0x688>
f010204e:	39 c6                	cmp    %eax,%esi
f0102050:	75 24                	jne    f0102076 <mem_init+0x6ac>
f0102052:	c7 44 24 0c 04 6d 10 	movl   $0xf0106d04,0xc(%esp)
f0102059:	f0 
f010205a:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102061:	f0 
f0102062:	c7 44 24 04 bf 03 00 	movl   $0x3bf,0x4(%esp)
f0102069:	00 
f010206a:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102071:	e8 0f e0 ff ff       	call   f0100085 <_panic>

	// temporarily steal the rest of the free pages
	fl = page_free_list;
f0102076:	8b 15 30 32 22 f0    	mov    0xf0223230,%edx
f010207c:	89 55 c8             	mov    %edx,-0x38(%ebp)
	page_free_list = 0;
f010207f:	c7 05 30 32 22 f0 00 	movl   $0x0,0xf0223230
f0102086:	00 00 00 

	// should be no free memory
	assert(!page_alloc(0));
f0102089:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102090:	e8 ea f0 ff ff       	call   f010117f <page_alloc>
f0102095:	85 c0                	test   %eax,%eax
f0102097:	74 24                	je     f01020bd <mem_init+0x6f3>
f0102099:	c7 44 24 0c aa 75 10 	movl   $0xf01075aa,0xc(%esp)
f01020a0:	f0 
f01020a1:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f01020a8:	f0 
f01020a9:	c7 44 24 04 c6 03 00 	movl   $0x3c6,0x4(%esp)
f01020b0:	00 
f01020b1:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01020b8:	e8 c8 df ff ff       	call   f0100085 <_panic>

	// there is no page allocated at address 0
	assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f01020bd:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f01020c0:	89 44 24 08          	mov    %eax,0x8(%esp)
f01020c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01020cb:	00 
f01020cc:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f01020d1:	89 04 24             	mov    %eax,(%esp)
f01020d4:	e8 aa f3 ff ff       	call   f0101483 <page_lookup>
f01020d9:	85 c0                	test   %eax,%eax
f01020db:	74 24                	je     f0102101 <mem_init+0x737>
f01020dd:	c7 44 24 0c 44 6d 10 	movl   $0xf0106d44,0xc(%esp)
f01020e4:	f0 
f01020e5:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f01020ec:	f0 
f01020ed:	c7 44 24 04 c9 03 00 	movl   $0x3c9,0x4(%esp)
f01020f4:	00 
f01020f5:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01020fc:	e8 84 df ff ff       	call   f0100085 <_panic>

	// there is no free memory, so we can't allocate a page table
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) < 0);
f0102101:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102108:	00 
f0102109:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102110:	00 
f0102111:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102115:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f010211a:	89 04 24             	mov    %eax,(%esp)
f010211d:	e8 29 f4 ff ff       	call   f010154b <page_insert>
f0102122:	85 c0                	test   %eax,%eax
f0102124:	78 24                	js     f010214a <mem_init+0x780>
f0102126:	c7 44 24 0c 7c 6d 10 	movl   $0xf0106d7c,0xc(%esp)
f010212d:	f0 
f010212e:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102135:	f0 
f0102136:	c7 44 24 04 cc 03 00 	movl   $0x3cc,0x4(%esp)
f010213d:	00 
f010213e:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102145:	e8 3b df ff ff       	call   f0100085 <_panic>

	// free pp0 and try again: pp0 should be used for page table
	page_free(pp0);
f010214a:	89 34 24             	mov    %esi,(%esp)
f010214d:	e8 11 ea ff ff       	call   f0100b63 <page_free>
	assert(page_insert(kern_pgdir, pp1, 0x0, PTE_W) == 0);
f0102152:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102159:	00 
f010215a:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102161:	00 
f0102162:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0102166:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f010216b:	89 04 24             	mov    %eax,(%esp)
f010216e:	e8 d8 f3 ff ff       	call   f010154b <page_insert>
f0102173:	85 c0                	test   %eax,%eax
f0102175:	74 24                	je     f010219b <mem_init+0x7d1>
f0102177:	c7 44 24 0c ac 6d 10 	movl   $0xf0106dac,0xc(%esp)
f010217e:	f0 
f010217f:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102186:	f0 
f0102187:	c7 44 24 04 d0 03 00 	movl   $0x3d0,0x4(%esp)
f010218e:	00 
f010218f:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102196:	e8 ea de ff ff       	call   f0100085 <_panic>
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010219b:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f01021a0:	89 75 d4             	mov    %esi,-0x2c(%ebp)
f01021a3:	8b 08                	mov    (%eax),%ecx
f01021a5:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f01021ab:	89 f2                	mov    %esi,%edx
f01021ad:	2b 15 f0 3e 22 f0    	sub    0xf0223ef0,%edx
f01021b3:	c1 fa 03             	sar    $0x3,%edx
f01021b6:	c1 e2 0c             	shl    $0xc,%edx
f01021b9:	39 d1                	cmp    %edx,%ecx
f01021bb:	74 24                	je     f01021e1 <mem_init+0x817>
f01021bd:	c7 44 24 0c b0 6c 10 	movl   $0xf0106cb0,0xc(%esp)
f01021c4:	f0 
f01021c5:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f01021cc:	f0 
f01021cd:	c7 44 24 04 d1 03 00 	movl   $0x3d1,0x4(%esp)
f01021d4:	00 
f01021d5:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01021dc:	e8 a4 de ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01021e1:	ba 00 00 00 00       	mov    $0x0,%edx
f01021e6:	e8 ec e9 ff ff       	call   f0100bd7 <check_va2pa>
f01021eb:	89 7d d0             	mov    %edi,-0x30(%ebp)
f01021ee:	89 fa                	mov    %edi,%edx
f01021f0:	2b 15 f0 3e 22 f0    	sub    0xf0223ef0,%edx
f01021f6:	c1 fa 03             	sar    $0x3,%edx
f01021f9:	c1 e2 0c             	shl    $0xc,%edx
f01021fc:	39 d0                	cmp    %edx,%eax
f01021fe:	74 24                	je     f0102224 <mem_init+0x85a>
f0102200:	c7 44 24 0c dc 6d 10 	movl   $0xf0106ddc,0xc(%esp)
f0102207:	f0 
f0102208:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f010220f:	f0 
f0102210:	c7 44 24 04 d2 03 00 	movl   $0x3d2,0x4(%esp)
f0102217:	00 
f0102218:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f010221f:	e8 61 de ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f0102224:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f0102229:	74 24                	je     f010224f <mem_init+0x885>
f010222b:	c7 44 24 0c d1 74 10 	movl   $0xf01074d1,0xc(%esp)
f0102232:	f0 
f0102233:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f010223a:	f0 
f010223b:	c7 44 24 04 d3 03 00 	movl   $0x3d3,0x4(%esp)
f0102242:	00 
f0102243:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f010224a:	e8 36 de ff ff       	call   f0100085 <_panic>
	assert(pp0->pp_ref == 1);
f010224f:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102254:	74 24                	je     f010227a <mem_init+0x8b0>
f0102256:	c7 44 24 0c 15 75 10 	movl   $0xf0107515,0xc(%esp)
f010225d:	f0 
f010225e:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102265:	f0 
f0102266:	c7 44 24 04 d4 03 00 	movl   $0x3d4,0x4(%esp)
f010226d:	00 
f010226e:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102275:	e8 0b de ff ff       	call   f0100085 <_panic>

	// should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010227a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102281:	00 
f0102282:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102289:	00 
f010228a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010228e:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0102293:	89 04 24             	mov    %eax,(%esp)
f0102296:	e8 b0 f2 ff ff       	call   f010154b <page_insert>
f010229b:	85 c0                	test   %eax,%eax
f010229d:	74 24                	je     f01022c3 <mem_init+0x8f9>
f010229f:	c7 44 24 0c 0c 6e 10 	movl   $0xf0106e0c,0xc(%esp)
f01022a6:	f0 
f01022a7:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f01022ae:	f0 
f01022af:	c7 44 24 04 d7 03 00 	movl   $0x3d7,0x4(%esp)
f01022b6:	00 
f01022b7:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01022be:	e8 c2 dd ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01022c3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01022c8:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f01022cd:	e8 05 e9 ff ff       	call   f0100bd7 <check_va2pa>
f01022d2:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f01022d5:	89 da                	mov    %ebx,%edx
f01022d7:	2b 15 f0 3e 22 f0    	sub    0xf0223ef0,%edx
f01022dd:	c1 fa 03             	sar    $0x3,%edx
f01022e0:	c1 e2 0c             	shl    $0xc,%edx
f01022e3:	39 d0                	cmp    %edx,%eax
f01022e5:	74 24                	je     f010230b <mem_init+0x941>
f01022e7:	c7 44 24 0c 48 6e 10 	movl   $0xf0106e48,0xc(%esp)
f01022ee:	f0 
f01022ef:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f01022f6:	f0 
f01022f7:	c7 44 24 04 d8 03 00 	movl   $0x3d8,0x4(%esp)
f01022fe:	00 
f01022ff:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102306:	e8 7a dd ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f010230b:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102310:	74 24                	je     f0102336 <mem_init+0x96c>
f0102312:	c7 44 24 0c e2 74 10 	movl   $0xf01074e2,0xc(%esp)
f0102319:	f0 
f010231a:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102321:	f0 
f0102322:	c7 44 24 04 d9 03 00 	movl   $0x3d9,0x4(%esp)
f0102329:	00 
f010232a:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102331:	e8 4f dd ff ff       	call   f0100085 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102336:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010233d:	e8 3d ee ff ff       	call   f010117f <page_alloc>
f0102342:	85 c0                	test   %eax,%eax
f0102344:	74 24                	je     f010236a <mem_init+0x9a0>
f0102346:	c7 44 24 0c aa 75 10 	movl   $0xf01075aa,0xc(%esp)
f010234d:	f0 
f010234e:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102355:	f0 
f0102356:	c7 44 24 04 dc 03 00 	movl   $0x3dc,0x4(%esp)
f010235d:	00 
f010235e:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102365:	e8 1b dd ff ff       	call   f0100085 <_panic>

	// should be able to map pp2 at PGSIZE because it's already there
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f010236a:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102371:	00 
f0102372:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102379:	00 
f010237a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f010237e:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0102383:	89 04 24             	mov    %eax,(%esp)
f0102386:	e8 c0 f1 ff ff       	call   f010154b <page_insert>
f010238b:	85 c0                	test   %eax,%eax
f010238d:	74 24                	je     f01023b3 <mem_init+0x9e9>
f010238f:	c7 44 24 0c 0c 6e 10 	movl   $0xf0106e0c,0xc(%esp)
f0102396:	f0 
f0102397:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f010239e:	f0 
f010239f:	c7 44 24 04 df 03 00 	movl   $0x3df,0x4(%esp)
f01023a6:	00 
f01023a7:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01023ae:	e8 d2 dc ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f01023b3:	ba 00 10 00 00       	mov    $0x1000,%edx
f01023b8:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f01023bd:	e8 15 e8 ff ff       	call   f0100bd7 <check_va2pa>
f01023c2:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01023c5:	2b 15 f0 3e 22 f0    	sub    0xf0223ef0,%edx
f01023cb:	c1 fa 03             	sar    $0x3,%edx
f01023ce:	c1 e2 0c             	shl    $0xc,%edx
f01023d1:	39 d0                	cmp    %edx,%eax
f01023d3:	74 24                	je     f01023f9 <mem_init+0xa2f>
f01023d5:	c7 44 24 0c 48 6e 10 	movl   $0xf0106e48,0xc(%esp)
f01023dc:	f0 
f01023dd:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f01023e4:	f0 
f01023e5:	c7 44 24 04 e0 03 00 	movl   $0x3e0,0x4(%esp)
f01023ec:	00 
f01023ed:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01023f4:	e8 8c dc ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f01023f9:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f01023fe:	74 24                	je     f0102424 <mem_init+0xa5a>
f0102400:	c7 44 24 0c e2 74 10 	movl   $0xf01074e2,0xc(%esp)
f0102407:	f0 
f0102408:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f010240f:	f0 
f0102410:	c7 44 24 04 e1 03 00 	movl   $0x3e1,0x4(%esp)
f0102417:	00 
f0102418:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f010241f:	e8 61 dc ff ff       	call   f0100085 <_panic>

	// pp2 should NOT be on the free list
	// could happen in ref counts are handled sloppily in page_insert
	assert(!page_alloc(0));
f0102424:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f010242b:	e8 4f ed ff ff       	call   f010117f <page_alloc>
f0102430:	85 c0                	test   %eax,%eax
f0102432:	74 24                	je     f0102458 <mem_init+0xa8e>
f0102434:	c7 44 24 0c aa 75 10 	movl   $0xf01075aa,0xc(%esp)
f010243b:	f0 
f010243c:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102443:	f0 
f0102444:	c7 44 24 04 e5 03 00 	movl   $0x3e5,0x4(%esp)
f010244b:	00 
f010244c:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102453:	e8 2d dc ff ff       	call   f0100085 <_panic>

	// check that pgdir_walk returns a pointer to the pte
	ptep = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0102458:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f010245d:	8b 00                	mov    (%eax),%eax
f010245f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102464:	89 c2                	mov    %eax,%edx
f0102466:	c1 ea 0c             	shr    $0xc,%edx
f0102469:	3b 15 e8 3e 22 f0    	cmp    0xf0223ee8,%edx
f010246f:	72 20                	jb     f0102491 <mem_init+0xac7>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102471:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102475:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f010247c:	f0 
f010247d:	c7 44 24 04 e8 03 00 	movl   $0x3e8,0x4(%esp)
f0102484:	00 
f0102485:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f010248c:	e8 f4 db ff ff       	call   f0100085 <_panic>
f0102491:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102496:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0102499:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01024a0:	00 
f01024a1:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01024a8:	00 
f01024a9:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f01024ae:	89 04 24             	mov    %eax,(%esp)
f01024b1:	e8 47 ed ff ff       	call   f01011fd <pgdir_walk>
f01024b6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01024b9:	83 c2 04             	add    $0x4,%edx
f01024bc:	39 d0                	cmp    %edx,%eax
f01024be:	74 24                	je     f01024e4 <mem_init+0xb1a>
f01024c0:	c7 44 24 0c 78 6e 10 	movl   $0xf0106e78,0xc(%esp)
f01024c7:	f0 
f01024c8:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f01024cf:	f0 
f01024d0:	c7 44 24 04 e9 03 00 	movl   $0x3e9,0x4(%esp)
f01024d7:	00 
f01024d8:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01024df:	e8 a1 db ff ff       	call   f0100085 <_panic>

	// should be able to change permissions too.
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W|PTE_U) == 0);
f01024e4:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f01024eb:	00 
f01024ec:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f01024f3:	00 
f01024f4:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01024f8:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f01024fd:	89 04 24             	mov    %eax,(%esp)
f0102500:	e8 46 f0 ff ff       	call   f010154b <page_insert>
f0102505:	85 c0                	test   %eax,%eax
f0102507:	74 24                	je     f010252d <mem_init+0xb63>
f0102509:	c7 44 24 0c b8 6e 10 	movl   $0xf0106eb8,0xc(%esp)
f0102510:	f0 
f0102511:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102518:	f0 
f0102519:	c7 44 24 04 ec 03 00 	movl   $0x3ec,0x4(%esp)
f0102520:	00 
f0102521:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102528:	e8 58 db ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f010252d:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102532:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0102537:	e8 9b e6 ff ff       	call   f0100bd7 <check_va2pa>
f010253c:	8b 55 cc             	mov    -0x34(%ebp),%edx
f010253f:	2b 15 f0 3e 22 f0    	sub    0xf0223ef0,%edx
f0102545:	c1 fa 03             	sar    $0x3,%edx
f0102548:	c1 e2 0c             	shl    $0xc,%edx
f010254b:	39 d0                	cmp    %edx,%eax
f010254d:	74 24                	je     f0102573 <mem_init+0xba9>
f010254f:	c7 44 24 0c 48 6e 10 	movl   $0xf0106e48,0xc(%esp)
f0102556:	f0 
f0102557:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f010255e:	f0 
f010255f:	c7 44 24 04 ed 03 00 	movl   $0x3ed,0x4(%esp)
f0102566:	00 
f0102567:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f010256e:	e8 12 db ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 1);
f0102573:	66 83 7b 04 01       	cmpw   $0x1,0x4(%ebx)
f0102578:	74 24                	je     f010259e <mem_init+0xbd4>
f010257a:	c7 44 24 0c e2 74 10 	movl   $0xf01074e2,0xc(%esp)
f0102581:	f0 
f0102582:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102589:	f0 
f010258a:	c7 44 24 04 ee 03 00 	movl   $0x3ee,0x4(%esp)
f0102591:	00 
f0102592:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102599:	e8 e7 da ff ff       	call   f0100085 <_panic>
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U);
f010259e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01025a5:	00 
f01025a6:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01025ad:	00 
f01025ae:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f01025b3:	89 04 24             	mov    %eax,(%esp)
f01025b6:	e8 42 ec ff ff       	call   f01011fd <pgdir_walk>
f01025bb:	f6 00 04             	testb  $0x4,(%eax)
f01025be:	75 24                	jne    f01025e4 <mem_init+0xc1a>
f01025c0:	c7 44 24 0c f8 6e 10 	movl   $0xf0106ef8,0xc(%esp)
f01025c7:	f0 
f01025c8:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f01025cf:	f0 
f01025d0:	c7 44 24 04 ef 03 00 	movl   $0x3ef,0x4(%esp)
f01025d7:	00 
f01025d8:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01025df:	e8 a1 da ff ff       	call   f0100085 <_panic>
	assert(kern_pgdir[0] & PTE_U);
f01025e4:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f01025e9:	f6 00 04             	testb  $0x4,(%eax)
f01025ec:	75 24                	jne    f0102612 <mem_init+0xc48>
f01025ee:	c7 44 24 0c fc 75 10 	movl   $0xf01075fc,0xc(%esp)
f01025f5:	f0 
f01025f6:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f01025fd:	f0 
f01025fe:	c7 44 24 04 f0 03 00 	movl   $0x3f0,0x4(%esp)
f0102605:	00 
f0102606:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f010260d:	e8 73 da ff ff       	call   f0100085 <_panic>

	// should be able to remap with fewer permissions
	//panic("daodi2 %d",pp2->pp_ref);
	assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_W) == 0);
f0102612:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102619:	00 
f010261a:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102621:	00 
f0102622:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102626:	89 04 24             	mov    %eax,(%esp)
f0102629:	e8 1d ef ff ff       	call   f010154b <page_insert>
f010262e:	85 c0                	test   %eax,%eax
f0102630:	74 24                	je     f0102656 <mem_init+0xc8c>
f0102632:	c7 44 24 0c 0c 6e 10 	movl   $0xf0106e0c,0xc(%esp)
f0102639:	f0 
f010263a:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102641:	f0 
f0102642:	c7 44 24 04 f4 03 00 	movl   $0x3f4,0x4(%esp)
f0102649:	00 
f010264a:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102651:	e8 2f da ff ff       	call   f0100085 <_panic>
	
	assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_W);
f0102656:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010265d:	00 
f010265e:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102665:	00 
f0102666:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f010266b:	89 04 24             	mov    %eax,(%esp)
f010266e:	e8 8a eb ff ff       	call   f01011fd <pgdir_walk>
f0102673:	f6 00 02             	testb  $0x2,(%eax)
f0102676:	75 24                	jne    f010269c <mem_init+0xcd2>
f0102678:	c7 44 24 0c 2c 6f 10 	movl   $0xf0106f2c,0xc(%esp)
f010267f:	f0 
f0102680:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102687:	f0 
f0102688:	c7 44 24 04 f6 03 00 	movl   $0x3f6,0x4(%esp)
f010268f:	00 
f0102690:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102697:	e8 e9 d9 ff ff       	call   f0100085 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f010269c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f01026a3:	00 
f01026a4:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01026ab:	00 
f01026ac:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f01026b1:	89 04 24             	mov    %eax,(%esp)
f01026b4:	e8 44 eb ff ff       	call   f01011fd <pgdir_walk>
f01026b9:	f6 00 04             	testb  $0x4,(%eax)
f01026bc:	74 24                	je     f01026e2 <mem_init+0xd18>
f01026be:	c7 44 24 0c 60 6f 10 	movl   $0xf0106f60,0xc(%esp)
f01026c5:	f0 
f01026c6:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f01026cd:	f0 
f01026ce:	c7 44 24 04 f7 03 00 	movl   $0x3f7,0x4(%esp)
f01026d5:	00 
f01026d6:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01026dd:	e8 a3 d9 ff ff       	call   f0100085 <_panic>
	
	// should not be able to map at PTSIZE because need free page for page table
	assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_W) < 0);
f01026e2:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f01026e9:	00 
f01026ea:	c7 44 24 08 00 00 40 	movl   $0x400000,0x8(%esp)
f01026f1:	00 
f01026f2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01026f6:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f01026fb:	89 04 24             	mov    %eax,(%esp)
f01026fe:	e8 48 ee ff ff       	call   f010154b <page_insert>
f0102703:	85 c0                	test   %eax,%eax
f0102705:	78 24                	js     f010272b <mem_init+0xd61>
f0102707:	c7 44 24 0c 98 6f 10 	movl   $0xf0106f98,0xc(%esp)
f010270e:	f0 
f010270f:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102716:	f0 
f0102717:	c7 44 24 04 fa 03 00 	movl   $0x3fa,0x4(%esp)
f010271e:	00 
f010271f:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102726:	e8 5a d9 ff ff       	call   f0100085 <_panic>
	

	//panic("ddsg %0x %0x",pp1,pp2);
	// insert pp1 at PGSIZE (replacing pp2)
	assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_W) == 0);
f010272b:	c7 44 24 0c 02 00 00 	movl   $0x2,0xc(%esp)
f0102732:	00 
f0102733:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f010273a:	00 
f010273b:	89 7c 24 04          	mov    %edi,0x4(%esp)
f010273f:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0102744:	89 04 24             	mov    %eax,(%esp)
f0102747:	e8 ff ed ff ff       	call   f010154b <page_insert>
f010274c:	85 c0                	test   %eax,%eax
f010274e:	74 24                	je     f0102774 <mem_init+0xdaa>
f0102750:	c7 44 24 0c d0 6f 10 	movl   $0xf0106fd0,0xc(%esp)
f0102757:	f0 
f0102758:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f010275f:	f0 
f0102760:	c7 44 24 04 ff 03 00 	movl   $0x3ff,0x4(%esp)
f0102767:	00 
f0102768:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f010276f:	e8 11 d9 ff ff       	call   f0100085 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_U));
f0102774:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f010277b:	00 
f010277c:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102783:	00 
f0102784:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0102789:	89 04 24             	mov    %eax,(%esp)
f010278c:	e8 6c ea ff ff       	call   f01011fd <pgdir_walk>
f0102791:	f6 00 04             	testb  $0x4,(%eax)
f0102794:	74 24                	je     f01027ba <mem_init+0xdf0>
f0102796:	c7 44 24 0c 60 6f 10 	movl   $0xf0106f60,0xc(%esp)
f010279d:	f0 
f010279e:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f01027a5:	f0 
f01027a6:	c7 44 24 04 00 04 00 	movl   $0x400,0x4(%esp)
f01027ad:	00 
f01027ae:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01027b5:	e8 cb d8 ff ff       	call   f0100085 <_panic>

	// should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
	assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f01027ba:	ba 00 00 00 00       	mov    $0x0,%edx
f01027bf:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f01027c4:	e8 0e e4 ff ff       	call   f0100bd7 <check_va2pa>
f01027c9:	8b 55 d0             	mov    -0x30(%ebp),%edx
f01027cc:	2b 15 f0 3e 22 f0    	sub    0xf0223ef0,%edx
f01027d2:	c1 fa 03             	sar    $0x3,%edx
f01027d5:	c1 e2 0c             	shl    $0xc,%edx
f01027d8:	39 d0                	cmp    %edx,%eax
f01027da:	74 24                	je     f0102800 <mem_init+0xe36>
f01027dc:	c7 44 24 0c 0c 70 10 	movl   $0xf010700c,0xc(%esp)
f01027e3:	f0 
f01027e4:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f01027eb:	f0 
f01027ec:	c7 44 24 04 03 04 00 	movl   $0x403,0x4(%esp)
f01027f3:	00 
f01027f4:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01027fb:	e8 85 d8 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102800:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102805:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f010280a:	e8 c8 e3 ff ff       	call   f0100bd7 <check_va2pa>
f010280f:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102812:	2b 15 f0 3e 22 f0    	sub    0xf0223ef0,%edx
f0102818:	c1 fa 03             	sar    $0x3,%edx
f010281b:	c1 e2 0c             	shl    $0xc,%edx
f010281e:	39 d0                	cmp    %edx,%eax
f0102820:	74 24                	je     f0102846 <mem_init+0xe7c>
f0102822:	c7 44 24 0c 38 70 10 	movl   $0xf0107038,0xc(%esp)
f0102829:	f0 
f010282a:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102831:	f0 
f0102832:	c7 44 24 04 04 04 00 	movl   $0x404,0x4(%esp)
f0102839:	00 
f010283a:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102841:	e8 3f d8 ff ff       	call   f0100085 <_panic>
	// ... and ref counts should reflect this
	assert(pp1->pp_ref == 2);
f0102846:	66 83 7f 04 02       	cmpw   $0x2,0x4(%edi)
f010284b:	74 24                	je     f0102871 <mem_init+0xea7>
f010284d:	c7 44 24 0c 12 76 10 	movl   $0xf0107612,0xc(%esp)
f0102854:	f0 
f0102855:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f010285c:	f0 
f010285d:	c7 44 24 04 06 04 00 	movl   $0x406,0x4(%esp)
f0102864:	00 
f0102865:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f010286c:	e8 14 d8 ff ff       	call   f0100085 <_panic>
	
	assert(pp2->pp_ref == 0);
f0102871:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102876:	74 24                	je     f010289c <mem_init+0xed2>
f0102878:	c7 44 24 0c 04 75 10 	movl   $0xf0107504,0xc(%esp)
f010287f:	f0 
f0102880:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102887:	f0 
f0102888:	c7 44 24 04 08 04 00 	movl   $0x408,0x4(%esp)
f010288f:	00 
f0102890:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102897:	e8 e9 d7 ff ff       	call   f0100085 <_panic>

	// pp2 should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp2);
f010289c:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01028a3:	e8 d7 e8 ff ff       	call   f010117f <page_alloc>
f01028a8:	85 c0                	test   %eax,%eax
f01028aa:	74 06                	je     f01028b2 <mem_init+0xee8>
f01028ac:	39 c3                	cmp    %eax,%ebx
f01028ae:	66 90                	xchg   %ax,%ax
f01028b0:	74 24                	je     f01028d6 <mem_init+0xf0c>
f01028b2:	c7 44 24 0c 68 70 10 	movl   $0xf0107068,0xc(%esp)
f01028b9:	f0 
f01028ba:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f01028c1:	f0 
f01028c2:	c7 44 24 04 0b 04 00 	movl   $0x40b,0x4(%esp)
f01028c9:	00 
f01028ca:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01028d1:	e8 af d7 ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at 0 should keep pp1 at PGSIZE
	page_remove(kern_pgdir, 0x0);
f01028d6:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f01028dd:	00 
f01028de:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f01028e3:	89 04 24             	mov    %eax,(%esp)
f01028e6:	e8 09 ec ff ff       	call   f01014f4 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01028eb:	ba 00 00 00 00       	mov    $0x0,%edx
f01028f0:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f01028f5:	e8 dd e2 ff ff       	call   f0100bd7 <check_va2pa>
f01028fa:	83 f8 ff             	cmp    $0xffffffff,%eax
f01028fd:	74 24                	je     f0102923 <mem_init+0xf59>
f01028ff:	c7 44 24 0c 8c 70 10 	movl   $0xf010708c,0xc(%esp)
f0102906:	f0 
f0102907:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f010290e:	f0 
f010290f:	c7 44 24 04 0f 04 00 	movl   $0x40f,0x4(%esp)
f0102916:	00 
f0102917:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f010291e:	e8 62 d7 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0102923:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102928:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f010292d:	e8 a5 e2 ff ff       	call   f0100bd7 <check_va2pa>
f0102932:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0102935:	2b 15 f0 3e 22 f0    	sub    0xf0223ef0,%edx
f010293b:	c1 fa 03             	sar    $0x3,%edx
f010293e:	c1 e2 0c             	shl    $0xc,%edx
f0102941:	39 d0                	cmp    %edx,%eax
f0102943:	74 24                	je     f0102969 <mem_init+0xf9f>
f0102945:	c7 44 24 0c 38 70 10 	movl   $0xf0107038,0xc(%esp)
f010294c:	f0 
f010294d:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102954:	f0 
f0102955:	c7 44 24 04 10 04 00 	movl   $0x410,0x4(%esp)
f010295c:	00 
f010295d:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102964:	e8 1c d7 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 1);
f0102969:	66 83 7f 04 01       	cmpw   $0x1,0x4(%edi)
f010296e:	74 24                	je     f0102994 <mem_init+0xfca>
f0102970:	c7 44 24 0c d1 74 10 	movl   $0xf01074d1,0xc(%esp)
f0102977:	f0 
f0102978:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f010297f:	f0 
f0102980:	c7 44 24 04 11 04 00 	movl   $0x411,0x4(%esp)
f0102987:	00 
f0102988:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f010298f:	e8 f1 d6 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0102994:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102999:	74 24                	je     f01029bf <mem_init+0xff5>
f010299b:	c7 44 24 0c 04 75 10 	movl   $0xf0107504,0xc(%esp)
f01029a2:	f0 
f01029a3:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f01029aa:	f0 
f01029ab:	c7 44 24 04 12 04 00 	movl   $0x412,0x4(%esp)
f01029b2:	00 
f01029b3:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01029ba:	e8 c6 d6 ff ff       	call   f0100085 <_panic>

	// unmapping pp1 at PGSIZE should free it
	page_remove(kern_pgdir, (void*) PGSIZE);
f01029bf:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f01029c6:	00 
f01029c7:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f01029cc:	89 04 24             	mov    %eax,(%esp)
f01029cf:	e8 20 eb ff ff       	call   f01014f4 <page_remove>
	assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01029d4:	ba 00 00 00 00       	mov    $0x0,%edx
f01029d9:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f01029de:	e8 f4 e1 ff ff       	call   f0100bd7 <check_va2pa>
f01029e3:	83 f8 ff             	cmp    $0xffffffff,%eax
f01029e6:	74 24                	je     f0102a0c <mem_init+0x1042>
f01029e8:	c7 44 24 0c 8c 70 10 	movl   $0xf010708c,0xc(%esp)
f01029ef:	f0 
f01029f0:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f01029f7:	f0 
f01029f8:	c7 44 24 04 16 04 00 	movl   $0x416,0x4(%esp)
f01029ff:	00 
f0102a00:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102a07:	e8 79 d6 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102a0c:	ba 00 10 00 00       	mov    $0x1000,%edx
f0102a11:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0102a16:	e8 bc e1 ff ff       	call   f0100bd7 <check_va2pa>
f0102a1b:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102a1e:	74 24                	je     f0102a44 <mem_init+0x107a>
f0102a20:	c7 44 24 0c b0 70 10 	movl   $0xf01070b0,0xc(%esp)
f0102a27:	f0 
f0102a28:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102a2f:	f0 
f0102a30:	c7 44 24 04 17 04 00 	movl   $0x417,0x4(%esp)
f0102a37:	00 
f0102a38:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102a3f:	e8 41 d6 ff ff       	call   f0100085 <_panic>
	assert(pp1->pp_ref == 0);
f0102a44:	66 83 7f 04 00       	cmpw   $0x0,0x4(%edi)
f0102a49:	74 24                	je     f0102a6f <mem_init+0x10a5>
f0102a4b:	c7 44 24 0c f3 74 10 	movl   $0xf01074f3,0xc(%esp)
f0102a52:	f0 
f0102a53:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102a5a:	f0 
f0102a5b:	c7 44 24 04 18 04 00 	movl   $0x418,0x4(%esp)
f0102a62:	00 
f0102a63:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102a6a:	e8 16 d6 ff ff       	call   f0100085 <_panic>
	assert(pp2->pp_ref == 0);
f0102a6f:	66 83 7b 04 00       	cmpw   $0x0,0x4(%ebx)
f0102a74:	74 24                	je     f0102a9a <mem_init+0x10d0>
f0102a76:	c7 44 24 0c 04 75 10 	movl   $0xf0107504,0xc(%esp)
f0102a7d:	f0 
f0102a7e:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102a85:	f0 
f0102a86:	c7 44 24 04 19 04 00 	movl   $0x419,0x4(%esp)
f0102a8d:	00 
f0102a8e:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102a95:	e8 eb d5 ff ff       	call   f0100085 <_panic>

	// so it should be returned by page_alloc
	assert((pp = page_alloc(0)) && pp == pp1);
f0102a9a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102aa1:	e8 d9 e6 ff ff       	call   f010117f <page_alloc>
f0102aa6:	85 c0                	test   %eax,%eax
f0102aa8:	74 04                	je     f0102aae <mem_init+0x10e4>
f0102aaa:	39 c7                	cmp    %eax,%edi
f0102aac:	74 24                	je     f0102ad2 <mem_init+0x1108>
f0102aae:	c7 44 24 0c d8 70 10 	movl   $0xf01070d8,0xc(%esp)
f0102ab5:	f0 
f0102ab6:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102abd:	f0 
f0102abe:	c7 44 24 04 1c 04 00 	movl   $0x41c,0x4(%esp)
f0102ac5:	00 
f0102ac6:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102acd:	e8 b3 d5 ff ff       	call   f0100085 <_panic>

	// should be no free memory
	assert(!page_alloc(0));
f0102ad2:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102ad9:	e8 a1 e6 ff ff       	call   f010117f <page_alloc>
f0102ade:	85 c0                	test   %eax,%eax
f0102ae0:	74 24                	je     f0102b06 <mem_init+0x113c>
f0102ae2:	c7 44 24 0c aa 75 10 	movl   $0xf01075aa,0xc(%esp)
f0102ae9:	f0 
f0102aea:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102af1:	f0 
f0102af2:	c7 44 24 04 1f 04 00 	movl   $0x41f,0x4(%esp)
f0102af9:	00 
f0102afa:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102b01:	e8 7f d5 ff ff       	call   f0100085 <_panic>

	// forcibly take pp0 back
	assert(PTE_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102b06:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0102b0b:	8b 08                	mov    (%eax),%ecx
f0102b0d:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
f0102b13:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102b16:	2b 15 f0 3e 22 f0    	sub    0xf0223ef0,%edx
f0102b1c:	c1 fa 03             	sar    $0x3,%edx
f0102b1f:	c1 e2 0c             	shl    $0xc,%edx
f0102b22:	39 d1                	cmp    %edx,%ecx
f0102b24:	74 24                	je     f0102b4a <mem_init+0x1180>
f0102b26:	c7 44 24 0c b0 6c 10 	movl   $0xf0106cb0,0xc(%esp)
f0102b2d:	f0 
f0102b2e:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102b35:	f0 
f0102b36:	c7 44 24 04 22 04 00 	movl   $0x422,0x4(%esp)
f0102b3d:	00 
f0102b3e:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102b45:	e8 3b d5 ff ff       	call   f0100085 <_panic>
	kern_pgdir[0] = 0;
f0102b4a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	assert(pp0->pp_ref == 1);
f0102b50:	66 83 7e 04 01       	cmpw   $0x1,0x4(%esi)
f0102b55:	74 24                	je     f0102b7b <mem_init+0x11b1>
f0102b57:	c7 44 24 0c 15 75 10 	movl   $0xf0107515,0xc(%esp)
f0102b5e:	f0 
f0102b5f:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102b66:	f0 
f0102b67:	c7 44 24 04 24 04 00 	movl   $0x424,0x4(%esp)
f0102b6e:	00 
f0102b6f:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102b76:	e8 0a d5 ff ff       	call   f0100085 <_panic>
	pp0->pp_ref = 0;
f0102b7b:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// check pointer arithmetic in pgdir_walk
	page_free(pp0);
f0102b81:	89 34 24             	mov    %esi,(%esp)
f0102b84:	e8 da df ff ff       	call   f0100b63 <page_free>
	va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
	ptep = pgdir_walk(kern_pgdir, va, 1);
f0102b89:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102b90:	00 
f0102b91:	c7 44 24 04 00 10 40 	movl   $0x401000,0x4(%esp)
f0102b98:	00 
f0102b99:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0102b9e:	89 04 24             	mov    %eax,(%esp)
f0102ba1:	e8 57 e6 ff ff       	call   f01011fd <pgdir_walk>
f0102ba6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	ptep1 = (pte_t *) KADDR(PTE_ADDR(kern_pgdir[PDX(va)]));
f0102ba9:	8b 0d ec 3e 22 f0    	mov    0xf0223eec,%ecx
f0102baf:	83 c1 04             	add    $0x4,%ecx
f0102bb2:	8b 11                	mov    (%ecx),%edx
f0102bb4:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
f0102bba:	89 55 cc             	mov    %edx,-0x34(%ebp)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bbd:	c1 ea 0c             	shr    $0xc,%edx
f0102bc0:	3b 15 e8 3e 22 f0    	cmp    0xf0223ee8,%edx
f0102bc6:	72 23                	jb     f0102beb <mem_init+0x1221>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102bc8:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0102bcb:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f0102bcf:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f0102bd6:	f0 
f0102bd7:	c7 44 24 04 2b 04 00 	movl   $0x42b,0x4(%esp)
f0102bde:	00 
f0102bdf:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102be6:	e8 9a d4 ff ff       	call   f0100085 <_panic>
	assert(ptep == ptep1 + PTX(va));
f0102beb:	8b 55 cc             	mov    -0x34(%ebp),%edx
f0102bee:	81 ea fc ff ff 0f    	sub    $0xffffffc,%edx
f0102bf4:	39 d0                	cmp    %edx,%eax
f0102bf6:	74 24                	je     f0102c1c <mem_init+0x1252>
f0102bf8:	c7 44 24 0c 23 76 10 	movl   $0xf0107623,0xc(%esp)
f0102bff:	f0 
f0102c00:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102c07:	f0 
f0102c08:	c7 44 24 04 2c 04 00 	movl   $0x42c,0x4(%esp)
f0102c0f:	00 
f0102c10:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102c17:	e8 69 d4 ff ff       	call   f0100085 <_panic>
	kern_pgdir[PDX(va)] = 0;
f0102c1c:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	pp0->pp_ref = 0;
f0102c22:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c28:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0102c2b:	2b 05 f0 3e 22 f0    	sub    0xf0223ef0,%eax
f0102c31:	c1 f8 03             	sar    $0x3,%eax
f0102c34:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c37:	89 c2                	mov    %eax,%edx
f0102c39:	c1 ea 0c             	shr    $0xc,%edx
f0102c3c:	3b 15 e8 3e 22 f0    	cmp    0xf0223ee8,%edx
f0102c42:	72 20                	jb     f0102c64 <mem_init+0x129a>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c44:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0102c48:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f0102c4f:	f0 
f0102c50:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102c57:	00 
f0102c58:	c7 04 24 b7 73 10 f0 	movl   $0xf01073b7,(%esp)
f0102c5f:	e8 21 d4 ff ff       	call   f0100085 <_panic>

	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
f0102c64:	c7 44 24 08 00 10 00 	movl   $0x1000,0x8(%esp)
f0102c6b:	00 
f0102c6c:	c7 44 24 04 ff 00 00 	movl   $0xff,0x4(%esp)
f0102c73:	00 
f0102c74:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0102c79:	89 04 24             	mov    %eax,(%esp)
f0102c7c:	e8 05 2b 00 00       	call   f0105786 <memset>
	page_free(pp0);
f0102c81:	89 34 24             	mov    %esi,(%esp)
f0102c84:	e8 da de ff ff       	call   f0100b63 <page_free>
	pgdir_walk(kern_pgdir, 0x0, 1);
f0102c89:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0102c90:	00 
f0102c91:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0102c98:	00 
f0102c99:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0102c9e:	89 04 24             	mov    %eax,(%esp)
f0102ca1:	e8 57 e5 ff ff       	call   f01011fd <pgdir_walk>
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102ca6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102ca9:	2b 15 f0 3e 22 f0    	sub    0xf0223ef0,%edx
f0102caf:	c1 fa 03             	sar    $0x3,%edx
f0102cb2:	c1 e2 0c             	shl    $0xc,%edx
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102cb5:	89 d0                	mov    %edx,%eax
f0102cb7:	c1 e8 0c             	shr    $0xc,%eax
f0102cba:	3b 05 e8 3e 22 f0    	cmp    0xf0223ee8,%eax
f0102cc0:	72 20                	jb     f0102ce2 <mem_init+0x1318>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102cc2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0102cc6:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f0102ccd:	f0 
f0102cce:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0102cd5:	00 
f0102cd6:	c7 04 24 b7 73 10 f0 	movl   $0xf01073b7,(%esp)
f0102cdd:	e8 a3 d3 ff ff       	call   f0100085 <_panic>
	ptep = (pte_t *) page2kva(pp0);
f0102ce2:	8d 82 00 00 00 f0    	lea    -0x10000000(%edx),%eax
f0102ce8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102ceb:	f6 00 01             	testb  $0x1,(%eax)
f0102cee:	75 11                	jne    f0102d01 <mem_init+0x1337>
f0102cf0:	8d 82 04 00 00 f0    	lea    -0xffffffc(%edx),%eax
// will be setup later.
//
// From UTOP to ULIM, the user is allowed to read but not write.
// Above ULIM the user cannot read or write.
void
mem_init(void)
f0102cf6:	81 ea 00 f0 ff 0f    	sub    $0xffff000,%edx
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
		assert((ptep[i] & PTE_P) == 0);
f0102cfc:	f6 00 01             	testb  $0x1,(%eax)
f0102cff:	74 24                	je     f0102d25 <mem_init+0x135b>
f0102d01:	c7 44 24 0c 3b 76 10 	movl   $0xf010763b,0xc(%esp)
f0102d08:	f0 
f0102d09:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102d10:	f0 
f0102d11:	c7 44 24 04 36 04 00 	movl   $0x436,0x4(%esp)
f0102d18:	00 
f0102d19:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102d20:	e8 60 d3 ff ff       	call   f0100085 <_panic>
f0102d25:	83 c0 04             	add    $0x4,%eax
	// check that new page tables get cleared
	memset(page2kva(pp0), 0xFF, PGSIZE);
	page_free(pp0);
	pgdir_walk(kern_pgdir, 0x0, 1);
	ptep = (pte_t *) page2kva(pp0);
	for(i=0; i<NPTENTRIES; i++)
f0102d28:	39 d0                	cmp    %edx,%eax
f0102d2a:	75 d0                	jne    f0102cfc <mem_init+0x1332>
		assert((ptep[i] & PTE_P) == 0);
	kern_pgdir[0] = 0;
f0102d2c:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0102d31:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	pp0->pp_ref = 0;
f0102d37:	66 c7 46 04 00 00    	movw   $0x0,0x4(%esi)

	// give free list back
	page_free_list = fl;
f0102d3d:	8b 45 c8             	mov    -0x38(%ebp),%eax
f0102d40:	a3 30 32 22 f0       	mov    %eax,0xf0223230

	// free the pages we took
	page_free(pp0);
f0102d45:	89 34 24             	mov    %esi,(%esp)
f0102d48:	e8 16 de ff ff       	call   f0100b63 <page_free>
	page_free(pp1);
f0102d4d:	89 3c 24             	mov    %edi,(%esp)
f0102d50:	e8 0e de ff ff       	call   f0100b63 <page_free>
	page_free(pp2);
f0102d55:	89 1c 24             	mov    %ebx,(%esp)
f0102d58:	e8 06 de ff ff       	call   f0100b63 <page_free>

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
f0102d5d:	c7 44 24 04 01 10 00 	movl   $0x1001,0x4(%esp)
f0102d64:	00 
f0102d65:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d6c:	e8 af e6 ff ff       	call   f0101420 <mmio_map_region>
f0102d71:	89 c3                	mov    %eax,%ebx
f0102d73:	89 c6                	mov    %eax,%esi
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102d75:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0102d7c:	00 
f0102d7d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0102d84:	e8 97 e6 ff ff       	call   f0101420 <mmio_map_region>
f0102d89:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
f0102d8c:	81 fb ff ff 7f ef    	cmp    $0xef7fffff,%ebx
f0102d92:	76 0d                	jbe    f0102da1 <mem_init+0x13d7>
f0102d94:	8d 83 a0 1f 00 00    	lea    0x1fa0(%ebx),%eax
f0102d9a:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102d9f:	76 24                	jbe    f0102dc5 <mem_init+0x13fb>
f0102da1:	c7 44 24 0c fc 70 10 	movl   $0xf01070fc,0xc(%esp)
f0102da8:	f0 
f0102da9:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102db0:	f0 
f0102db1:	c7 44 24 04 46 04 00 	movl   $0x446,0x4(%esp)
f0102db8:	00 
f0102db9:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102dc0:	e8 c0 d2 ff ff       	call   f0100085 <_panic>
	page_free(pp1);
	page_free(pp2);

	// test mmio_map_region
	mm1 = (uintptr_t) mmio_map_region(0, 4097);
	mm2 = (uintptr_t) mmio_map_region(0, 4096);
f0102dc5:	8b 7d d4             	mov    -0x2c(%ebp),%edi
	// check that they're in the right region
	assert(mm1 >= MMIOBASE && mm1 + 8096 < MMIOLIM);
	assert(mm2 >= MMIOBASE && mm2 + 8096 < MMIOLIM);
f0102dc8:	81 ff ff ff 7f ef    	cmp    $0xef7fffff,%edi
f0102dce:	76 0d                	jbe    f0102ddd <mem_init+0x1413>
f0102dd0:	8d 87 a0 1f 00 00    	lea    0x1fa0(%edi),%eax
f0102dd6:	3d ff ff bf ef       	cmp    $0xefbfffff,%eax
f0102ddb:	76 24                	jbe    f0102e01 <mem_init+0x1437>
f0102ddd:	c7 44 24 0c 24 71 10 	movl   $0xf0107124,0xc(%esp)
f0102de4:	f0 
f0102de5:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102dec:	f0 
f0102ded:	c7 44 24 04 47 04 00 	movl   $0x447,0x4(%esp)
f0102df4:	00 
f0102df5:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102dfc:	e8 84 d2 ff ff       	call   f0100085 <_panic>
	// check that they're page-aligned
	assert(mm1 % PGSIZE == 0 && mm2 % PGSIZE == 0);
f0102e01:	89 f8                	mov    %edi,%eax
f0102e03:	09 d8                	or     %ebx,%eax
f0102e05:	a9 ff 0f 00 00       	test   $0xfff,%eax
f0102e0a:	74 24                	je     f0102e30 <mem_init+0x1466>
f0102e0c:	c7 44 24 0c 4c 71 10 	movl   $0xf010714c,0xc(%esp)
f0102e13:	f0 
f0102e14:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102e1b:	f0 
f0102e1c:	c7 44 24 04 49 04 00 	movl   $0x449,0x4(%esp)
f0102e23:	00 
f0102e24:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102e2b:	e8 55 d2 ff ff       	call   f0100085 <_panic>
	// check that they don't overlap
	// assert(mm1 + 8096 <= mm2);
	// check page mappings
	assert(check_va2pa(kern_pgdir, mm1) == 0);
f0102e30:	89 da                	mov    %ebx,%edx
f0102e32:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0102e37:	e8 9b dd ff ff       	call   f0100bd7 <check_va2pa>
f0102e3c:	85 c0                	test   %eax,%eax
f0102e3e:	74 24                	je     f0102e64 <mem_init+0x149a>
f0102e40:	c7 44 24 0c 74 71 10 	movl   $0xf0107174,0xc(%esp)
f0102e47:	f0 
f0102e48:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102e4f:	f0 
f0102e50:	c7 44 24 04 4d 04 00 	movl   $0x44d,0x4(%esp)
f0102e57:	00 
f0102e58:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102e5f:	e8 21 d2 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, mm1+PGSIZE) == PGSIZE);
f0102e64:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0102e6a:	89 f2                	mov    %esi,%edx
f0102e6c:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0102e71:	e8 61 dd ff ff       	call   f0100bd7 <check_va2pa>
f0102e76:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0102e7b:	74 24                	je     f0102ea1 <mem_init+0x14d7>
f0102e7d:	c7 44 24 0c 98 71 10 	movl   $0xf0107198,0xc(%esp)
f0102e84:	f0 
f0102e85:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102e8c:	f0 
f0102e8d:	c7 44 24 04 4e 04 00 	movl   $0x44e,0x4(%esp)
f0102e94:	00 
f0102e95:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102e9c:	e8 e4 d1 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, mm2) == 0);
f0102ea1:	89 fa                	mov    %edi,%edx
f0102ea3:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0102ea8:	e8 2a dd ff ff       	call   f0100bd7 <check_va2pa>
f0102ead:	85 c0                	test   %eax,%eax
f0102eaf:	74 24                	je     f0102ed5 <mem_init+0x150b>
f0102eb1:	c7 44 24 0c c8 71 10 	movl   $0xf01071c8,0xc(%esp)
f0102eb8:	f0 
f0102eb9:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102ec0:	f0 
f0102ec1:	c7 44 24 04 4f 04 00 	movl   $0x44f,0x4(%esp)
f0102ec8:	00 
f0102ec9:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102ed0:	e8 b0 d1 ff ff       	call   f0100085 <_panic>
	assert(check_va2pa(kern_pgdir, mm2+PGSIZE) == ~0);
f0102ed5:	8d 97 00 10 00 00    	lea    0x1000(%edi),%edx
f0102edb:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0102ee0:	e8 f2 dc ff ff       	call   f0100bd7 <check_va2pa>
f0102ee5:	83 f8 ff             	cmp    $0xffffffff,%eax
f0102ee8:	74 24                	je     f0102f0e <mem_init+0x1544>
f0102eea:	c7 44 24 0c ec 71 10 	movl   $0xf01071ec,0xc(%esp)
f0102ef1:	f0 
f0102ef2:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102ef9:	f0 
f0102efa:	c7 44 24 04 50 04 00 	movl   $0x450,0x4(%esp)
f0102f01:	00 
f0102f02:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102f09:	e8 77 d1 ff ff       	call   f0100085 <_panic>
	// check permissions
	assert(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & (PTE_W|PTE_PWT|PTE_PCD));
f0102f0e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102f15:	00 
f0102f16:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102f1a:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0102f1f:	89 04 24             	mov    %eax,(%esp)
f0102f22:	e8 d6 e2 ff ff       	call   f01011fd <pgdir_walk>
f0102f27:	f6 00 1a             	testb  $0x1a,(%eax)
f0102f2a:	75 24                	jne    f0102f50 <mem_init+0x1586>
f0102f2c:	c7 44 24 0c 18 72 10 	movl   $0xf0107218,0xc(%esp)
f0102f33:	f0 
f0102f34:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102f3b:	f0 
f0102f3c:	c7 44 24 04 52 04 00 	movl   $0x452,0x4(%esp)
f0102f43:	00 
f0102f44:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102f4b:	e8 35 d1 ff ff       	call   f0100085 <_panic>
	assert(!(*pgdir_walk(kern_pgdir, (void*) mm1, 0) & PTE_U));
f0102f50:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102f57:	00 
f0102f58:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102f5c:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0102f61:	89 04 24             	mov    %eax,(%esp)
f0102f64:	e8 94 e2 ff ff       	call   f01011fd <pgdir_walk>
f0102f69:	f6 00 04             	testb  $0x4,(%eax)
f0102f6c:	74 24                	je     f0102f92 <mem_init+0x15c8>
f0102f6e:	c7 44 24 0c 5c 72 10 	movl   $0xf010725c,0xc(%esp)
f0102f75:	f0 
f0102f76:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0102f7d:	f0 
f0102f7e:	c7 44 24 04 53 04 00 	movl   $0x453,0x4(%esp)
f0102f85:	00 
f0102f86:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0102f8d:	e8 f3 d0 ff ff       	call   f0100085 <_panic>
	// clear the mappings
	*pgdir_walk(kern_pgdir, (void*) mm1, 0) = 0;
f0102f92:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102f99:	00 
f0102f9a:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0102f9e:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0102fa3:	89 04 24             	mov    %eax,(%esp)
f0102fa6:	e8 52 e2 ff ff       	call   f01011fd <pgdir_walk>
f0102fab:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm1 + PGSIZE, 0) = 0;
f0102fb1:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102fb8:	00 
f0102fb9:	89 74 24 04          	mov    %esi,0x4(%esp)
f0102fbd:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0102fc2:	89 04 24             	mov    %eax,(%esp)
f0102fc5:	e8 33 e2 ff ff       	call   f01011fd <pgdir_walk>
f0102fca:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	*pgdir_walk(kern_pgdir, (void*) mm2, 0) = 0;
f0102fd0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
f0102fd7:	00 
f0102fd8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0102fdb:	89 54 24 04          	mov    %edx,0x4(%esp)
f0102fdf:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0102fe4:	89 04 24             	mov    %eax,(%esp)
f0102fe7:	e8 11 e2 ff ff       	call   f01011fd <pgdir_walk>
f0102fec:	c7 00 00 00 00 00    	movl   $0x0,(%eax)


	cprintf("check_page() succeeded!\n");
f0102ff2:	c7 04 24 52 76 10 f0 	movl   $0xf0107652,(%esp)
f0102ff9:	e8 2b 0f 00 00       	call   f0103f29 <cprintf>
	//      (ie. perm = PTE_U | PTE_P)
	//    - pages itself -- kernel RW, user NONE
	// Your code goes here:
	//boot_map_region();boot_map_region(pde_t *pgdir, uintptr_t va, size_t size, physaddr_t pa, int perm)
	
	boot_map_region(kern_pgdir,UPAGES,npages * sizeof(struct PageInfo),PADDR(pages),PTE_U);	// ”√ªßø…“‘∂¡
f0102ffe:	a1 f0 3e 22 f0       	mov    0xf0223ef0,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103003:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103008:	77 20                	ja     f010302a <mem_init+0x1660>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010300a:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010300e:	c7 44 24 08 dc 65 10 	movl   $0xf01065dc,0x8(%esp)
f0103015:	f0 
f0103016:	c7 44 24 04 c1 00 00 	movl   $0xc1,0x4(%esp)
f010301d:	00 
f010301e:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0103025:	e8 5b d0 ff ff       	call   f0100085 <_panic>
f010302a:	8b 0d e8 3e 22 f0    	mov    0xf0223ee8,%ecx
f0103030:	c1 e1 03             	shl    $0x3,%ecx
f0103033:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f010303a:	00 
f010303b:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103041:	89 04 24             	mov    %eax,(%esp)
f0103044:	ba 00 00 00 ef       	mov    $0xef000000,%edx
f0103049:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f010304e:	e8 6a e3 ff ff       	call   f01013bd <boot_map_region>
	// Permissions:
	//    - the new image at UENVS  -- kernel R, user R
	//    - envs itself -- kernel RW, user NONE
	// LAB 3: Your code here.
	
	boot_map_region(kern_pgdir,UENVS,ROUNDUP(NENV*sizeof(struct Env), PGSIZE),PADDR(envs),PTE_U);	
f0103053:	a1 38 32 22 f0       	mov    0xf0223238,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103058:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f010305d:	77 20                	ja     f010307f <mem_init+0x16b5>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010305f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103063:	c7 44 24 08 dc 65 10 	movl   $0xf01065dc,0x8(%esp)
f010306a:	f0 
f010306b:	c7 44 24 04 cb 00 00 	movl   $0xcb,0x4(%esp)
f0103072:	00 
f0103073:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f010307a:	e8 06 d0 ff ff       	call   f0100085 <_panic>
f010307f:	c7 44 24 04 04 00 00 	movl   $0x4,0x4(%esp)
f0103086:	00 
f0103087:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f010308d:	89 04 24             	mov    %eax,(%esp)
f0103090:	b9 00 f0 01 00       	mov    $0x1f000,%ecx
f0103095:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
f010309a:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f010309f:	e8 19 e3 ff ff       	call   f01013bd <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01030a4:	b8 00 60 11 f0       	mov    $0xf0116000,%eax
f01030a9:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01030ae:	77 20                	ja     f01030d0 <mem_init+0x1706>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01030b0:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01030b4:	c7 44 24 08 dc 65 10 	movl   $0xf01065dc,0x8(%esp)
f01030bb:	f0 
f01030bc:	c7 44 24 04 d9 00 00 	movl   $0xd9,0x4(%esp)
f01030c3:	00 
f01030c4:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01030cb:	e8 b5 cf ff ff       	call   f0100085 <_panic>
	//       the kernel overflows its stack, it will fault rather than
	//       overwrite memory.  Known as a "guard page".
	//     Permissions: kernel RW, user NONE
	// Your code goes here:
	
	boot_map_region(kern_pgdir,KSTACKTOP-KSTKSIZE,KSTKSIZE,PADDR(bootstack),PTE_W);
f01030d0:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01030d7:	00 
f01030d8:	05 00 00 00 10       	add    $0x10000000,%eax
f01030dd:	89 04 24             	mov    %eax,(%esp)
f01030e0:	b9 00 80 00 00       	mov    $0x8000,%ecx
f01030e5:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f01030ea:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f01030ef:	e8 c9 e2 ff ff       	call   f01013bd <boot_map_region>
	// We might not have 2^32 - KERNBASE bytes of physical memory, but
	// we just set up the mapping anyway.
	// Permissions: kernel RW, user NONE
	// Your code goes here:
	
	boot_map_region(kern_pgdir,KERNBASE,0xfffffff,(physaddr_t)0,PTE_W);	//0xfff ffff
f01030f4:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f01030fb:	00 
f01030fc:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f0103103:	b9 ff ff ff 0f       	mov    $0xfffffff,%ecx
f0103108:	ba 00 00 00 f0       	mov    $0xf0000000,%edx
f010310d:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0103112:	e8 a6 e2 ff ff       	call   f01013bd <boot_map_region>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103117:	c7 45 cc 00 50 22 f0 	movl   $0xf0225000,-0x34(%ebp)
f010311e:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0103125:	0f 87 0a 04 00 00    	ja     f0103535 <mem_init+0x1b6b>
f010312b:	b8 00 50 22 f0       	mov    $0xf0225000,%eax
f0103130:	eb 0a                	jmp    f010313c <mem_init+0x1772>
f0103132:	89 d8                	mov    %ebx,%eax
f0103134:	81 fb ff ff ff ef    	cmp    $0xefffffff,%ebx
f010313a:	77 20                	ja     f010315c <mem_init+0x1792>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f010313c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103140:	c7 44 24 08 dc 65 10 	movl   $0xf01065dc,0x8(%esp)
f0103147:	f0 
f0103148:	c7 44 24 04 1d 01 00 	movl   $0x11d,0x4(%esp)
f010314f:	00 
f0103150:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0103157:	e8 29 cf ff ff       	call   f0100085 <_panic>
	//
	// LAB 4: Your code here:
	int i=0;
	int temp=KSTKSIZE + KSTKGAP;
	for(i=0;i<NCPU;i++) 
		boot_map_region(kern_pgdir,KSTACKTOP-i*temp-KSTKSIZE,KSTKSIZE,PADDR(percpu_kstacks[i]),PTE_W);
f010315c:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f0103163:	00 
f0103164:	8d 83 00 00 00 10    	lea    0x10000000(%ebx),%eax
f010316a:	89 04 24             	mov    %eax,(%esp)
f010316d:	b9 00 80 00 00       	mov    $0x8000,%ecx
f0103172:	89 f2                	mov    %esi,%edx
f0103174:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0103179:	e8 3f e2 ff ff       	call   f01013bd <boot_map_region>
f010317e:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0103184:	81 ee 00 00 01 00    	sub    $0x10000,%esi
	//     Permissions: kernel RW, user NONE
	//
	// LAB 4: Your code here:
	int i=0;
	int temp=KSTKSIZE + KSTKGAP;
	for(i=0;i<NCPU;i++) 
f010318a:	81 fe 00 80 f7 ef    	cmp    $0xeff78000,%esi
f0103190:	75 a0                	jne    f0103132 <mem_init+0x1768>
check_kern_pgdir(void)
{
	uint32_t i, n;
	pde_t *pgdir;

	pgdir = kern_pgdir;
f0103192:	8b 1d ec 3e 22 f0    	mov    0xf0223eec,%ebx

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
f0103198:	a1 e8 3e 22 f0       	mov    0xf0223ee8,%eax
f010319d:	8d 3c c5 ff 0f 00 00 	lea    0xfff(,%eax,8),%edi
	for (i = 0; i < n; i += PGSIZE)
f01031a4:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f01031aa:	74 79                	je     f0103225 <mem_init+0x185b>
f01031ac:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
f01031b1:	8d 96 00 00 00 ef    	lea    -0x11000000(%esi),%edx
f01031b7:	89 d8                	mov    %ebx,%eax
f01031b9:	e8 19 da ff ff       	call   f0100bd7 <check_va2pa>
f01031be:	8b 15 f0 3e 22 f0    	mov    0xf0223ef0,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01031c4:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f01031ca:	77 20                	ja     f01031ec <mem_init+0x1822>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01031cc:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01031d0:	c7 44 24 08 dc 65 10 	movl   $0xf01065dc,0x8(%esp)
f01031d7:	f0 
f01031d8:	c7 44 24 04 6b 03 00 	movl   $0x36b,0x4(%esp)
f01031df:	00 
f01031e0:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01031e7:	e8 99 ce ff ff       	call   f0100085 <_panic>
f01031ec:	8d 94 16 00 00 00 10 	lea    0x10000000(%esi,%edx,1),%edx
f01031f3:	39 d0                	cmp    %edx,%eax
f01031f5:	74 24                	je     f010321b <mem_init+0x1851>
f01031f7:	c7 44 24 0c 90 72 10 	movl   $0xf0107290,0xc(%esp)
f01031fe:	f0 
f01031ff:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0103206:	f0 
f0103207:	c7 44 24 04 6b 03 00 	movl   $0x36b,0x4(%esp)
f010320e:	00 
f010320f:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0103216:	e8 6a ce ff ff       	call   f0100085 <_panic>

	pgdir = kern_pgdir;

	// check pages array
	n = ROUNDUP(npages*sizeof(struct PageInfo), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f010321b:	81 c6 00 10 00 00    	add    $0x1000,%esi
f0103221:	39 f7                	cmp    %esi,%edi
f0103223:	77 8c                	ja     f01031b1 <mem_init+0x17e7>
f0103225:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);
f010322a:	8d 96 00 00 c0 ee    	lea    -0x11400000(%esi),%edx
f0103230:	89 d8                	mov    %ebx,%eax
f0103232:	e8 a0 d9 ff ff       	call   f0100bd7 <check_va2pa>
f0103237:	8b 15 38 32 22 f0    	mov    0xf0223238,%edx
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010323d:	81 fa ff ff ff ef    	cmp    $0xefffffff,%edx
f0103243:	77 20                	ja     f0103265 <mem_init+0x189b>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103245:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0103249:	c7 44 24 08 dc 65 10 	movl   $0xf01065dc,0x8(%esp)
f0103250:	f0 
f0103251:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f0103258:	00 
f0103259:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0103260:	e8 20 ce ff ff       	call   f0100085 <_panic>
f0103265:	8d 94 32 00 00 00 10 	lea    0x10000000(%edx,%esi,1),%edx
f010326c:	39 d0                	cmp    %edx,%eax
f010326e:	74 24                	je     f0103294 <mem_init+0x18ca>
f0103270:	c7 44 24 0c c4 72 10 	movl   $0xf01072c4,0xc(%esp)
f0103277:	f0 
f0103278:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f010327f:	f0 
f0103280:	c7 44 24 04 70 03 00 	movl   $0x370,0x4(%esp)
f0103287:	00 
f0103288:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f010328f:	e8 f1 cd ff ff       	call   f0100085 <_panic>
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);

	// check envs array (new test for lab 3)
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
f0103294:	81 c6 00 10 00 00    	add    $0x1000,%esi
f010329a:	81 fe 00 f0 01 00    	cmp    $0x1f000,%esi
f01032a0:	75 88                	jne    f010322a <mem_init+0x1860>
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01032a2:	a1 e8 3e 22 f0       	mov    0xf0223ee8,%eax
f01032a7:	c1 e0 0c             	shl    $0xc,%eax
f01032aa:	85 c0                	test   %eax,%eax
f01032ac:	74 4c                	je     f01032fa <mem_init+0x1930>
f01032ae:	be 00 00 00 00       	mov    $0x0,%esi
		assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01032b3:	8d 96 00 00 00 f0    	lea    -0x10000000(%esi),%edx
f01032b9:	89 d8                	mov    %ebx,%eax
f01032bb:	e8 17 d9 ff ff       	call   f0100bd7 <check_va2pa>
f01032c0:	39 c6                	cmp    %eax,%esi
f01032c2:	74 24                	je     f01032e8 <mem_init+0x191e>
f01032c4:	c7 44 24 0c f8 72 10 	movl   $0xf01072f8,0xc(%esp)
f01032cb:	f0 
f01032cc:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f01032d3:	f0 
f01032d4:	c7 44 24 04 74 03 00 	movl   $0x374,0x4(%esp)
f01032db:	00 
f01032dc:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01032e3:	e8 9d cd ff ff       	call   f0100085 <_panic>
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01032e8:	81 c6 00 10 00 00    	add    $0x1000,%esi
f01032ee:	a1 e8 3e 22 f0       	mov    0xf0223ee8,%eax
f01032f3:	c1 e0 0c             	shl    $0xc,%eax
f01032f6:	39 c6                	cmp    %eax,%esi
f01032f8:	72 b9                	jb     f01032b3 <mem_init+0x18e9>
f01032fa:	c7 45 d0 00 00 ff ef 	movl   $0xefff0000,-0x30(%ebp)

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f0103301:	89 df                	mov    %ebx,%edi
	n = ROUNDUP(NENV*sizeof(struct Env), PGSIZE);
	for (i = 0; i < n; i += PGSIZE)
		assert(check_va2pa(pgdir, UENVS + i) == PADDR(envs) + i);

	// check phys mem
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0103303:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f0103306:	89 4d c8             	mov    %ecx,-0x38(%ebp)
f0103309:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f010330c:	81 c3 00 80 00 00    	add    $0x8000,%ebx
f0103312:	89 ce                	mov    %ecx,%esi
f0103314:	81 c6 00 00 00 10    	add    $0x10000000,%esi
f010331a:	8b 45 d0             	mov    -0x30(%ebp),%eax
f010331d:	05 00 00 01 00       	add    $0x10000,%eax
f0103322:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f0103325:	89 da                	mov    %ebx,%edx
f0103327:	89 f8                	mov    %edi,%eax
f0103329:	e8 a9 d8 ff ff       	call   f0100bd7 <check_va2pa>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010332e:	81 7d cc ff ff ff ef 	cmpl   $0xefffffff,-0x34(%ebp)
f0103335:	77 23                	ja     f010335a <mem_init+0x1990>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103337:	8b 55 c8             	mov    -0x38(%ebp),%edx
f010333a:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010333e:	c7 44 24 08 dc 65 10 	movl   $0xf01065dc,0x8(%esp)
f0103345:	f0 
f0103346:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f010334d:	00 
f010334e:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0103355:	e8 2b cd ff ff       	call   f0100085 <_panic>
f010335a:	39 f0                	cmp    %esi,%eax
f010335c:	74 24                	je     f0103382 <mem_init+0x19b8>
f010335e:	c7 44 24 0c 20 73 10 	movl   $0xf0107320,0xc(%esp)
f0103365:	f0 
f0103366:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f010336d:	f0 
f010336e:	c7 44 24 04 7c 03 00 	movl   $0x37c,0x4(%esp)
f0103375:	00 
f0103376:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f010337d:	e8 03 cd ff ff       	call   f0100085 <_panic>
f0103382:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103388:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
f010338e:	39 5d d4             	cmp    %ebx,-0x2c(%ebp)
f0103391:	0f 85 d4 01 00 00    	jne    f010356b <mem_init+0x1ba1>
f0103397:	bb 00 00 00 00       	mov    $0x0,%ebx
f010339c:	8b 75 d0             	mov    -0x30(%ebp),%esi
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
f010339f:	8d 14 33             	lea    (%ebx,%esi,1),%edx
f01033a2:	89 f8                	mov    %edi,%eax
f01033a4:	e8 2e d8 ff ff       	call   f0100bd7 <check_va2pa>
f01033a9:	83 f8 ff             	cmp    $0xffffffff,%eax
f01033ac:	74 24                	je     f01033d2 <mem_init+0x1a08>
f01033ae:	c7 44 24 0c 68 73 10 	movl   $0xf0107368,0xc(%esp)
f01033b5:	f0 
f01033b6:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f01033bd:	f0 
f01033be:	c7 44 24 04 7e 03 00 	movl   $0x37e,0x4(%esp)
f01033c5:	00 
f01033c6:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01033cd:	e8 b3 cc ff ff       	call   f0100085 <_panic>
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
				== PADDR(percpu_kstacks[n]) + i);
		for (i = 0; i < KSTKGAP; i += PGSIZE)
f01033d2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f01033d8:	81 fb 00 80 00 00    	cmp    $0x8000,%ebx
f01033de:	75 bf                	jne    f010339f <mem_init+0x19d5>
f01033e0:	81 6d d0 00 00 01 00 	subl   $0x10000,-0x30(%ebp)
f01033e7:	81 45 cc 00 80 00 00 	addl   $0x8000,-0x34(%ebp)
	for (i = 0; i < npages * PGSIZE; i += PGSIZE)
		assert(check_va2pa(pgdir, KERNBASE + i) == i);

	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
f01033ee:	81 7d d0 00 00 f7 ef 	cmpl   $0xeff70000,-0x30(%ebp)
f01033f5:	0f 85 08 ff ff ff    	jne    f0103303 <mem_init+0x1939>
f01033fb:	89 fb                	mov    %edi,%ebx
f01033fd:	b8 00 00 00 00       	mov    $0x0,%eax
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
		switch (i) {
f0103402:	8d 90 45 fc ff ff    	lea    -0x3bb(%eax),%edx
f0103408:	83 fa 04             	cmp    $0x4,%edx
f010340b:	77 2e                	ja     f010343b <mem_init+0x1a71>
		case PDX(UVPT):
		case PDX(KSTACKTOP-1):
		case PDX(UPAGES):
		case PDX(UENVS):
		case PDX(MMIOBASE):
			assert(pgdir[i] & PTE_P);
f010340d:	f6 04 83 01          	testb  $0x1,(%ebx,%eax,4)
f0103411:	0f 85 aa 00 00 00    	jne    f01034c1 <mem_init+0x1af7>
f0103417:	c7 44 24 0c 6b 76 10 	movl   $0xf010766b,0xc(%esp)
f010341e:	f0 
f010341f:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0103426:	f0 
f0103427:	c7 44 24 04 89 03 00 	movl   $0x389,0x4(%esp)
f010342e:	00 
f010342f:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0103436:	e8 4a cc ff ff       	call   f0100085 <_panic>
			break;
		default:
			if (i >= PDX(KERNBASE)) {
f010343b:	3d bf 03 00 00       	cmp    $0x3bf,%eax
f0103440:	76 55                	jbe    f0103497 <mem_init+0x1acd>
				assert(pgdir[i] & PTE_P);
f0103442:	8b 14 83             	mov    (%ebx,%eax,4),%edx
f0103445:	f6 c2 01             	test   $0x1,%dl
f0103448:	75 24                	jne    f010346e <mem_init+0x1aa4>
f010344a:	c7 44 24 0c 6b 76 10 	movl   $0xf010766b,0xc(%esp)
f0103451:	f0 
f0103452:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0103459:	f0 
f010345a:	c7 44 24 04 8d 03 00 	movl   $0x38d,0x4(%esp)
f0103461:	00 
f0103462:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0103469:	e8 17 cc ff ff       	call   f0100085 <_panic>
				assert(pgdir[i] & PTE_W);
f010346e:	f6 c2 02             	test   $0x2,%dl
f0103471:	75 4e                	jne    f01034c1 <mem_init+0x1af7>
f0103473:	c7 44 24 0c 7c 76 10 	movl   $0xf010767c,0xc(%esp)
f010347a:	f0 
f010347b:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0103482:	f0 
f0103483:	c7 44 24 04 8e 03 00 	movl   $0x38e,0x4(%esp)
f010348a:	00 
f010348b:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0103492:	e8 ee cb ff ff       	call   f0100085 <_panic>
			} else
				assert(pgdir[i] == 0);
f0103497:	83 3c 83 00          	cmpl   $0x0,(%ebx,%eax,4)
f010349b:	74 24                	je     f01034c1 <mem_init+0x1af7>
f010349d:	c7 44 24 0c 8d 76 10 	movl   $0xf010768d,0xc(%esp)
f01034a4:	f0 
f01034a5:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f01034ac:	f0 
f01034ad:	c7 44 24 04 90 03 00 	movl   $0x390,0x4(%esp)
f01034b4:	00 
f01034b5:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f01034bc:	e8 c4 cb ff ff       	call   f0100085 <_panic>
		for (i = 0; i < KSTKGAP; i += PGSIZE)
			assert(check_va2pa(pgdir, base + i) == ~0);
	}

	// check PDE permissions
	for (i = 0; i < NPDENTRIES; i++) {
f01034c1:	83 c0 01             	add    $0x1,%eax
f01034c4:	3d 00 04 00 00       	cmp    $0x400,%eax
f01034c9:	0f 85 33 ff ff ff    	jne    f0103402 <mem_init+0x1a38>
			} else
				assert(pgdir[i] == 0);
			break;
		}
	}
	cprintf("check_kern_pgdir() succeeded!\n");
f01034cf:	c7 04 24 8c 73 10 f0 	movl   $0xf010738c,(%esp)
f01034d6:	e8 4e 0a 00 00       	call   f0103f29 <cprintf>
	// somewhere between KERNBASE and KERNBASE+4MB right now, which is
	// mapped the same way by both page tables.
	//
	// If the machine reboots at this point, you've probably set up your
	// kern_pgdir wrong.
	lcr3(PADDR(kern_pgdir));
f01034db:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01034e0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01034e5:	77 20                	ja     f0103507 <mem_init+0x1b3d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01034e7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01034eb:	c7 44 24 08 dc 65 10 	movl   $0xf01065dc,0x8(%esp)
f01034f2:	f0 
f01034f3:	c7 44 24 04 f5 00 00 	movl   $0xf5,0x4(%esp)
f01034fa:	00 
f01034fb:	c7 04 24 ab 73 10 f0 	movl   $0xf01073ab,(%esp)
f0103502:	e8 7e cb ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f0103507:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f010350d:	0f 22 d8             	mov    %eax,%cr3

	check_page_free_list(0);
f0103510:	b8 00 00 00 00       	mov    $0x0,%eax
f0103515:	e8 c1 d8 ff ff       	call   f0100ddb <check_page_free_list>

static __inline uint32_t
rcr0(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr0,%0" : "=r" (val));
f010351a:	0f 20 c0             	mov    %cr0,%eax

	// entry.S set the really important flags in cr0 (including enabling
	// paging).  Here we configure the rest of the flags that we care about.
	cr0 = rcr0();
	cr0 |= CR0_PE|CR0_PG|CR0_AM|CR0_WP|CR0_NE|CR0_MP;
f010351d:	0d 23 00 05 80       	or     $0x80050023,%eax
}

static __inline void
lcr0(uint32_t val)
{
	__asm __volatile("movl %0,%%cr0" : : "r" (val));
f0103522:	83 e0 f3             	and    $0xfffffff3,%eax
f0103525:	0f 22 c0             	mov    %eax,%cr0
	cr0 &= ~(CR0_TS|CR0_EM);
	lcr0(cr0);

	// Some more checks, only possible after kern_pgdir is installed.
	check_page_installed_pgdir();
f0103528:	e8 c8 e0 ff ff       	call   f01015f5 <check_page_installed_pgdir>
}
f010352d:	83 c4 3c             	add    $0x3c,%esp
f0103530:	5b                   	pop    %ebx
f0103531:	5e                   	pop    %esi
f0103532:	5f                   	pop    %edi
f0103533:	5d                   	pop    %ebp
f0103534:	c3                   	ret    
	//
	// LAB 4: Your code here:
	int i=0;
	int temp=KSTKSIZE + KSTKGAP;
	for(i=0;i<NCPU;i++) 
		boot_map_region(kern_pgdir,KSTACKTOP-i*temp-KSTKSIZE,KSTKSIZE,PADDR(percpu_kstacks[i]),PTE_W);
f0103535:	c7 44 24 04 02 00 00 	movl   $0x2,0x4(%esp)
f010353c:	00 
f010353d:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0103540:	05 00 00 00 10       	add    $0x10000000,%eax
f0103545:	89 04 24             	mov    %eax,(%esp)
f0103548:	b9 00 80 00 00       	mov    $0x8000,%ecx
f010354d:	ba 00 80 ff ef       	mov    $0xefff8000,%edx
f0103552:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
f0103557:	e8 61 de ff ff       	call   f01013bd <boot_map_region>
f010355c:	bb 00 d0 22 f0       	mov    $0xf022d000,%ebx
f0103561:	be 00 80 fe ef       	mov    $0xeffe8000,%esi
f0103566:	e9 c7 fb ff ff       	jmp    f0103132 <mem_init+0x1768>
	// check kernel stack
	// (updated in lab 4 to check per-CPU kernel stacks)
	for (n = 0; n < NCPU; n++) {
		uint32_t base = KSTACKTOP - (KSTKSIZE + KSTKGAP) * (n + 1);
		for (i = 0; i < KSTKSIZE; i += PGSIZE)
			assert(check_va2pa(pgdir, base + KSTKGAP + i)
f010356b:	89 da                	mov    %ebx,%edx
f010356d:	89 f8                	mov    %edi,%eax
f010356f:	e8 63 d6 ff ff       	call   f0100bd7 <check_va2pa>
f0103574:	e9 e1 fd ff ff       	jmp    f010335a <mem_init+0x1990>
f0103579:	66 90                	xchg   %ax,%ax
f010357b:	66 90                	xchg   %ax,%ax
f010357d:	66 90                	xchg   %ax,%ax
f010357f:	90                   	nop

f0103580 <env_init_percpu>:
}

// Load GDT and segment descriptors.
void
env_init_percpu(void)
{
f0103580:	55                   	push   %ebp
f0103581:	89 e5                	mov    %esp,%ebp
}

static __inline void
lgdt(void *p)
{
	__asm __volatile("lgdt (%0)" : : "r" (p));
f0103583:	b8 88 03 12 f0       	mov    $0xf0120388,%eax
f0103588:	0f 01 10             	lgdtl  (%eax)
	lgdt(&gdt_pd);
	// The kernel never uses GS or FS, so we leave those set to
	// the user data segment.
	asm volatile("movw %%ax,%%gs" :: "a" (GD_UD|3));
f010358b:	b8 23 00 00 00       	mov    $0x23,%eax
f0103590:	8e e8                	mov    %eax,%gs
	asm volatile("movw %%ax,%%fs" :: "a" (GD_UD|3));
f0103592:	8e e0                	mov    %eax,%fs
	// The kernel does use ES, DS, and SS.  We'll change between
	// the kernel and user data segments as needed.
	asm volatile("movw %%ax,%%es" :: "a" (GD_KD));
f0103594:	b0 10                	mov    $0x10,%al
f0103596:	8e c0                	mov    %eax,%es
	asm volatile("movw %%ax,%%ds" :: "a" (GD_KD));
f0103598:	8e d8                	mov    %eax,%ds
	asm volatile("movw %%ax,%%ss" :: "a" (GD_KD));
f010359a:	8e d0                	mov    %eax,%ss
	// Load the kernel text segment into CS.
	asm volatile("ljmp %0,$1f\n 1:\n" :: "i" (GD_KT));
f010359c:	ea a3 35 10 f0 08 00 	ljmp   $0x8,$0xf01035a3
}

static __inline void
lldt(uint16_t sel)
{
	__asm __volatile("lldt %0" : : "r" (sel));
f01035a3:	b0 00                	mov    $0x0,%al
f01035a5:	0f 00 d0             	lldt   %ax
	// For good measure, clear the local descriptor table (LDT),
	// since we don't use it.
	lldt(0);
}
f01035a8:	5d                   	pop    %ebp
f01035a9:	c3                   	ret    

f01035aa <env_init>:
// they are in the envs array (i.e., so that the first call to
// env_alloc() returns envs[0]).
//
void
env_init(void)
{
f01035aa:	55                   	push   %ebp
f01035ab:	89 e5                	mov    %esp,%ebp
	// Set up envs array
	// LAB 3: Your code here.

	int i=0;	
	env_free_list=&envs[0];
f01035ad:	8b 15 38 32 22 f0    	mov    0xf0223238,%edx
f01035b3:	b8 00 00 00 00       	mov    $0x0,%eax
	for(i=0;i<NENV;i++) {
		envs[i].env_status=ENV_FREE;
f01035b8:	8b 0d 38 32 22 f0    	mov    0xf0223238,%ecx
f01035be:	c7 44 01 54 00 00 00 	movl   $0x0,0x54(%ecx,%eax,1)
f01035c5:	00 
		envs[i].env_id=0;
f01035c6:	8b 0d 38 32 22 f0    	mov    0xf0223238,%ecx
f01035cc:	c7 44 01 48 00 00 00 	movl   $0x0,0x48(%ecx,%eax,1)
f01035d3:	00 
		// mark in the free list
		env_free_list->env_link=&envs[i];
f01035d4:	89 c1                	mov    %eax,%ecx
f01035d6:	03 0d 38 32 22 f0    	add    0xf0223238,%ecx
f01035dc:	89 4a 44             	mov    %ecx,0x44(%edx)
		env_free_list=&envs[i];
f01035df:	89 c2                	mov    %eax,%edx
f01035e1:	03 15 38 32 22 f0    	add    0xf0223238,%edx
f01035e7:	83 c0 7c             	add    $0x7c,%eax
	// Set up envs array
	// LAB 3: Your code here.

	int i=0;	
	env_free_list=&envs[0];
	for(i=0;i<NENV;i++) {
f01035ea:	3d 00 f0 01 00       	cmp    $0x1f000,%eax
f01035ef:	75 c7                	jne    f01035b8 <env_init+0xe>
		envs[i].env_id=0;
		// mark in the free list
		env_free_list->env_link=&envs[i];
		env_free_list=&envs[i];
	}
	env_free_list->env_link=NULL;
f01035f1:	c7 42 44 00 00 00 00 	movl   $0x0,0x44(%edx)
	env_free_list=&envs[0];
f01035f8:	a1 38 32 22 f0       	mov    0xf0223238,%eax
f01035fd:	a3 3c 32 22 f0       	mov    %eax,0xf022323c
	// Per-CPU part of the initialization
	env_init_percpu();
f0103602:	e8 79 ff ff ff       	call   f0103580 <env_init_percpu>
}
f0103607:	5d                   	pop    %ebp
f0103608:	c3                   	ret    

f0103609 <envid2env>:
//   On success, sets *env_store to the environment.
//   On error, sets *env_store to NULL.
//
int
envid2env(envid_t envid, struct Env **env_store, bool checkperm)
{
f0103609:	55                   	push   %ebp
f010360a:	89 e5                	mov    %esp,%ebp
f010360c:	83 ec 18             	sub    $0x18,%esp
f010360f:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0103612:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0103615:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0103618:	8b 45 08             	mov    0x8(%ebp),%eax
f010361b:	8b 75 0c             	mov    0xc(%ebp),%esi
f010361e:	0f b6 55 10          	movzbl 0x10(%ebp),%edx
	struct Env *e;

	// If envid is zero, return the current environment.
	if (envid == 0) {
f0103622:	85 c0                	test   %eax,%eax
f0103624:	75 17                	jne    f010363d <envid2env+0x34>
		*env_store = curenv;
f0103626:	e8 04 28 00 00       	call   f0105e2f <cpunum>
f010362b:	6b c0 74             	imul   $0x74,%eax,%eax
f010362e:	8b 80 28 40 22 f0    	mov    -0xfddbfd8(%eax),%eax
f0103634:	89 06                	mov    %eax,(%esi)
f0103636:	b8 00 00 00 00       	mov    $0x0,%eax
		return 0;
f010363b:	eb 67                	jmp    f01036a4 <envid2env+0x9b>
	// Look up the Env structure via the index part of the envid,
	// then check the env_id field in that struct Env
	// to ensure that the envid is not stale
	// (i.e., does not refer to a _previous_ environment
	// that used the same slot in the envs[] array).
	e = &envs[ENVX(envid)];
f010363d:	89 c3                	mov    %eax,%ebx
f010363f:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
f0103645:	6b db 7c             	imul   $0x7c,%ebx,%ebx
f0103648:	03 1d 38 32 22 f0    	add    0xf0223238,%ebx
	if (e->env_status == ENV_FREE || e->env_id != envid) {
f010364e:	83 7b 54 00          	cmpl   $0x0,0x54(%ebx)
f0103652:	74 05                	je     f0103659 <envid2env+0x50>
f0103654:	39 43 48             	cmp    %eax,0x48(%ebx)
f0103657:	74 0d                	je     f0103666 <envid2env+0x5d>
		*env_store = 0;
f0103659:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
f010365f:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f0103664:	eb 3e                	jmp    f01036a4 <envid2env+0x9b>
	// Check that the calling environment has legitimate permission
	// to manipulate the specified environment.
	// If checkperm is set, the specified environment
	// must be either the current environment
	// or an immediate child of the current environment.
	if (checkperm && e != curenv && e->env_parent_id != curenv->env_id) {
f0103666:	84 d2                	test   %dl,%dl
f0103668:	74 33                	je     f010369d <envid2env+0x94>
f010366a:	e8 c0 27 00 00       	call   f0105e2f <cpunum>
f010366f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103672:	39 98 28 40 22 f0    	cmp    %ebx,-0xfddbfd8(%eax)
f0103678:	74 23                	je     f010369d <envid2env+0x94>
f010367a:	8b 7b 4c             	mov    0x4c(%ebx),%edi
f010367d:	e8 ad 27 00 00       	call   f0105e2f <cpunum>
f0103682:	6b c0 74             	imul   $0x74,%eax,%eax
f0103685:	8b 80 28 40 22 f0    	mov    -0xfddbfd8(%eax),%eax
f010368b:	3b 78 48             	cmp    0x48(%eax),%edi
f010368e:	74 0d                	je     f010369d <envid2env+0x94>
		*env_store = 0;
f0103690:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
f0103696:	b8 fe ff ff ff       	mov    $0xfffffffe,%eax
		return -E_BAD_ENV;
f010369b:	eb 07                	jmp    f01036a4 <envid2env+0x9b>
	}

	*env_store = e;
f010369d:	89 1e                	mov    %ebx,(%esi)
f010369f:	b8 00 00 00 00       	mov    $0x0,%eax
	return 0;
}
f01036a4:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01036a7:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01036aa:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01036ad:	89 ec                	mov    %ebp,%esp
f01036af:	5d                   	pop    %ebp
f01036b0:	c3                   	ret    

f01036b1 <env_pop_tf>:
// This function does not return.
//
void
env_pop_tf(struct Trapframe *tf)

{
f01036b1:	55                   	push   %ebp
f01036b2:	89 e5                	mov    %esp,%ebp
f01036b4:	53                   	push   %ebx
f01036b5:	83 ec 14             	sub    $0x14,%esp
	// Record the CPU we are running on for user-space debugging
	curenv->env_cpunum = cpunum();
f01036b8:	e8 72 27 00 00       	call   f0105e2f <cpunum>
f01036bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01036c0:	8b 98 28 40 22 f0    	mov    -0xfddbfd8(%eax),%ebx
f01036c6:	e8 64 27 00 00       	call   f0105e2f <cpunum>
f01036cb:	89 43 5c             	mov    %eax,0x5c(%ebx)
	

	__asm __volatile("movl %0,%%esp\n"
f01036ce:	8b 65 08             	mov    0x8(%ebp),%esp
f01036d1:	61                   	popa   
f01036d2:	07                   	pop    %es
f01036d3:	1f                   	pop    %ds
f01036d4:	83 c4 08             	add    $0x8,%esp
f01036d7:	cf                   	iret   
		"\tpopl %%es\n"
		"\tpopl %%ds\n"
		"\taddl $0x8,%%esp\n" /* skip tf_trapno and tf_errcode */
		"\tiret"
		: : "g" (tf) : "memory");
	panic("iret failed");  /* mostly to placate the compiler */
f01036d8:	c7 44 24 08 9b 76 10 	movl   $0xf010769b,0x8(%esp)
f01036df:	f0 
f01036e0:	c7 44 24 04 fb 01 00 	movl   $0x1fb,0x4(%esp)
f01036e7:	00 
f01036e8:	c7 04 24 a7 76 10 f0 	movl   $0xf01076a7,(%esp)
f01036ef:	e8 91 c9 ff ff       	call   f0100085 <_panic>

f01036f4 <env_run>:
//
// This function does not return.
//
void
env_run(struct Env *e)
{
f01036f4:	55                   	push   %ebp
f01036f5:	89 e5                	mov    %esp,%ebp
f01036f7:	53                   	push   %ebx
f01036f8:	83 ec 14             	sub    $0x14,%esp
	//	and make sure you have set the relevant parts of
	//	e->env_tf to sensible values.

	// LAB 3: Your code here.
	
	if(curenv!=NULL) {
f01036fb:	e8 2f 27 00 00       	call   f0105e2f <cpunum>
f0103700:	6b c0 74             	imul   $0x74,%eax,%eax
f0103703:	83 b8 28 40 22 f0 00 	cmpl   $0x0,-0xfddbfd8(%eax)
f010370a:	74 29                	je     f0103735 <env_run+0x41>
		if(curenv->env_status==ENV_RUNNING)  {
f010370c:	e8 1e 27 00 00       	call   f0105e2f <cpunum>
f0103711:	6b c0 74             	imul   $0x74,%eax,%eax
f0103714:	8b 80 28 40 22 f0    	mov    -0xfddbfd8(%eax),%eax
f010371a:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f010371e:	75 15                	jne    f0103735 <env_run+0x41>
			curenv->env_status=ENV_RUNNABLE;
f0103720:	e8 0a 27 00 00       	call   f0105e2f <cpunum>
f0103725:	6b c0 74             	imul   $0x74,%eax,%eax
f0103728:	8b 80 28 40 22 f0    	mov    -0xfddbfd8(%eax),%eax
f010372e:	c7 40 54 02 00 00 00 	movl   $0x2,0x54(%eax)
		}
	}
	curenv=e;
f0103735:	e8 f5 26 00 00       	call   f0105e2f <cpunum>
f010373a:	bb 20 40 22 f0       	mov    $0xf0224020,%ebx
f010373f:	6b c0 74             	imul   $0x74,%eax,%eax
f0103742:	8b 55 08             	mov    0x8(%ebp),%edx
f0103745:	89 54 18 08          	mov    %edx,0x8(%eax,%ebx,1)
	
	curenv->env_status=ENV_RUNNING;
f0103749:	e8 e1 26 00 00       	call   f0105e2f <cpunum>
f010374e:	6b c0 74             	imul   $0x74,%eax,%eax
f0103751:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103755:	c7 40 54 03 00 00 00 	movl   $0x3,0x54(%eax)
	curenv->env_runs++;
f010375c:	e8 ce 26 00 00       	call   f0105e2f <cpunum>
f0103761:	6b c0 74             	imul   $0x74,%eax,%eax
f0103764:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103768:	83 40 58 01          	addl   $0x1,0x58(%eax)
		
	lcr3(PADDR(curenv->env_pgdir));
f010376c:	e8 be 26 00 00       	call   f0105e2f <cpunum>
f0103771:	6b c0 74             	imul   $0x74,%eax,%eax
f0103774:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0103778:	8b 40 60             	mov    0x60(%eax),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010377b:	89 c2                	mov    %eax,%edx
f010377d:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103782:	77 20                	ja     f01037a4 <env_run+0xb0>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103784:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103788:	c7 44 24 08 dc 65 10 	movl   $0xf01065dc,0x8(%esp)
f010378f:	f0 
f0103790:	c7 44 24 04 24 02 00 	movl   $0x224,0x4(%esp)
f0103797:	00 
f0103798:	c7 04 24 a7 76 10 f0 	movl   $0xf01076a7,(%esp)
f010379f:	e8 e1 c8 ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f01037a4:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f01037aa:	0f 22 da             	mov    %edx,%cr3
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f01037ad:	c7 04 24 a0 03 12 f0 	movl   $0xf01203a0,(%esp)
f01037b4:	e8 33 29 00 00       	call   f01060ec <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f01037b9:	f3 90                	pause  
	//cprintf("dizi %08x",&(curenv->env_tf));
	unlock_kernel();
	env_pop_tf(&(curenv->env_tf));
f01037bb:	e8 6f 26 00 00       	call   f0105e2f <cpunum>
f01037c0:	6b c0 74             	imul   $0x74,%eax,%eax
f01037c3:	8b 80 28 40 22 f0    	mov    -0xfddbfd8(%eax),%eax
f01037c9:	89 04 24             	mov    %eax,(%esp)
f01037cc:	e8 e0 fe ff ff       	call   f01036b1 <env_pop_tf>

f01037d1 <env_free>:
//
// Frees env e and all memory it uses.
//
void
env_free(struct Env *e)
{
f01037d1:	55                   	push   %ebp
f01037d2:	89 e5                	mov    %esp,%ebp
f01037d4:	57                   	push   %edi
f01037d5:	56                   	push   %esi
f01037d6:	53                   	push   %ebx
f01037d7:	83 ec 2c             	sub    $0x2c,%esp
f01037da:	8b 7d 08             	mov    0x8(%ebp),%edi
	physaddr_t pa;

	// If freeing the current environment, switch to kern_pgdir
	// before freeing the page directory, just in case the page
	// gets reused.
	if (e == curenv)
f01037dd:	e8 4d 26 00 00       	call   f0105e2f <cpunum>
f01037e2:	6b c0 74             	imul   $0x74,%eax,%eax
f01037e5:	39 b8 28 40 22 f0    	cmp    %edi,-0xfddbfd8(%eax)
f01037eb:	75 35                	jne    f0103822 <env_free+0x51>
		lcr3(PADDR(kern_pgdir));
f01037ed:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01037f2:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01037f7:	77 20                	ja     f0103819 <env_free+0x48>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01037f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01037fd:	c7 44 24 08 dc 65 10 	movl   $0xf01065dc,0x8(%esp)
f0103804:	f0 
f0103805:	c7 44 24 04 a6 01 00 	movl   $0x1a6,0x4(%esp)
f010380c:	00 
f010380d:	c7 04 24 a7 76 10 f0 	movl   $0xf01076a7,(%esp)
f0103814:	e8 6c c8 ff ff       	call   f0100085 <_panic>
f0103819:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f010381f:	0f 22 d8             	mov    %eax,%cr3

	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103822:	8b 5f 48             	mov    0x48(%edi),%ebx
f0103825:	e8 05 26 00 00       	call   f0105e2f <cpunum>
f010382a:	6b d0 74             	imul   $0x74,%eax,%edx
f010382d:	b8 00 00 00 00       	mov    $0x0,%eax
f0103832:	83 ba 28 40 22 f0 00 	cmpl   $0x0,-0xfddbfd8(%edx)
f0103839:	74 11                	je     f010384c <env_free+0x7b>
f010383b:	e8 ef 25 00 00       	call   f0105e2f <cpunum>
f0103840:	6b c0 74             	imul   $0x74,%eax,%eax
f0103843:	8b 80 28 40 22 f0    	mov    -0xfddbfd8(%eax),%eax
f0103849:	8b 40 48             	mov    0x48(%eax),%eax
f010384c:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103850:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103854:	c7 04 24 b2 76 10 f0 	movl   $0xf01076b2,(%esp)
f010385b:	e8 c9 06 00 00       	call   f0103f29 <cprintf>
f0103860:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
f0103867:	8b 45 e0             	mov    -0x20(%ebp),%eax
f010386a:	c1 e0 02             	shl    $0x2,%eax
f010386d:	89 45 dc             	mov    %eax,-0x24(%ebp)
	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {

		// only look at mapped page tables
		if (!(e->env_pgdir[pdeno] & PTE_P))
f0103870:	8b 47 60             	mov    0x60(%edi),%eax
f0103873:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0103876:	8b 34 10             	mov    (%eax,%edx,1),%esi
f0103879:	f7 c6 01 00 00 00    	test   $0x1,%esi
f010387f:	0f 84 b8 00 00 00    	je     f010393d <env_free+0x16c>
			continue;

		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
f0103885:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010388b:	89 f0                	mov    %esi,%eax
f010388d:	c1 e8 0c             	shr    $0xc,%eax
f0103890:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0103893:	3b 05 e8 3e 22 f0    	cmp    0xf0223ee8,%eax
f0103899:	72 20                	jb     f01038bb <env_free+0xea>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010389b:	89 74 24 0c          	mov    %esi,0xc(%esp)
f010389f:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f01038a6:	f0 
f01038a7:	c7 44 24 04 b5 01 00 	movl   $0x1b5,0x4(%esp)
f01038ae:	00 
f01038af:	c7 04 24 a7 76 10 f0 	movl   $0xf01076a7,(%esp)
f01038b6:	e8 ca c7 ff ff       	call   f0100085 <_panic>
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01038bb:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01038be:	c1 e2 16             	shl    $0x16,%edx
f01038c1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01038c4:	bb 00 00 00 00       	mov    $0x0,%ebx
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
			if (pt[pteno] & PTE_P)
f01038c9:	f6 84 9e 00 00 00 f0 	testb  $0x1,-0x10000000(%esi,%ebx,4)
f01038d0:	01 
f01038d1:	74 17                	je     f01038ea <env_free+0x119>
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
f01038d3:	89 d8                	mov    %ebx,%eax
f01038d5:	c1 e0 0c             	shl    $0xc,%eax
f01038d8:	0b 45 e4             	or     -0x1c(%ebp),%eax
f01038db:	89 44 24 04          	mov    %eax,0x4(%esp)
f01038df:	8b 47 60             	mov    0x60(%edi),%eax
f01038e2:	89 04 24             	mov    %eax,(%esp)
f01038e5:	e8 0a dc ff ff       	call   f01014f4 <page_remove>
		// find the pa and va of the page table
		pa = PTE_ADDR(e->env_pgdir[pdeno]);
		pt = (pte_t*) KADDR(pa);

		// unmap all PTEs in this page table
		for (pteno = 0; pteno <= PTX(~0); pteno++) {
f01038ea:	83 c3 01             	add    $0x1,%ebx
f01038ed:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
f01038f3:	75 d4                	jne    f01038c9 <env_free+0xf8>
			if (pt[pteno] & PTE_P)
				page_remove(e->env_pgdir, PGADDR(pdeno, pteno, 0));
		}

		// free the page table itself
		e->env_pgdir[pdeno] = 0;
f01038f5:	8b 47 60             	mov    0x60(%edi),%eax
f01038f8:	8b 55 dc             	mov    -0x24(%ebp),%edx
f01038fb:	c7 04 10 00 00 00 00 	movl   $0x0,(%eax,%edx,1)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103902:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0103905:	3b 05 e8 3e 22 f0    	cmp    0xf0223ee8,%eax
f010390b:	72 1c                	jb     f0103929 <env_free+0x158>
		panic("pa2page called with invalid pa");
f010390d:	c7 44 24 08 1c 6c 10 	movl   $0xf0106c1c,0x8(%esp)
f0103914:	f0 
f0103915:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f010391c:	00 
f010391d:	c7 04 24 b7 73 10 f0 	movl   $0xf01073b7,(%esp)
f0103924:	e8 5c c7 ff ff       	call   f0100085 <_panic>
		page_decref(pa2page(pa));
f0103929:	8b 45 d8             	mov    -0x28(%ebp),%eax
f010392c:	c1 e0 03             	shl    $0x3,%eax
f010392f:	03 05 f0 3e 22 f0    	add    0xf0223ef0,%eax
f0103935:	89 04 24             	mov    %eax,(%esp)
f0103938:	e8 42 d2 ff ff       	call   f0100b7f <page_decref>
	// Note the environment's demise.
	cprintf("[%08x] free env %08x\n", curenv ? curenv->env_id : 0, e->env_id);

	// Flush all mapped pages in the user portion of the address space
	static_assert(UTOP % PTSIZE == 0);
	for (pdeno = 0; pdeno < PDX(UTOP); pdeno++) {
f010393d:	83 45 e0 01          	addl   $0x1,-0x20(%ebp)
f0103941:	81 7d e0 bb 03 00 00 	cmpl   $0x3bb,-0x20(%ebp)
f0103948:	0f 85 19 ff ff ff    	jne    f0103867 <env_free+0x96>
		e->env_pgdir[pdeno] = 0;
		page_decref(pa2page(pa));
	}

	// free the page directory
	pa = PADDR(e->env_pgdir);
f010394e:	8b 47 60             	mov    0x60(%edi),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103951:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103956:	77 20                	ja     f0103978 <env_free+0x1a7>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103958:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010395c:	c7 44 24 08 dc 65 10 	movl   $0xf01065dc,0x8(%esp)
f0103963:	f0 
f0103964:	c7 44 24 04 c3 01 00 	movl   $0x1c3,0x4(%esp)
f010396b:	00 
f010396c:	c7 04 24 a7 76 10 f0 	movl   $0xf01076a7,(%esp)
f0103973:	e8 0d c7 ff ff       	call   f0100085 <_panic>
	e->env_pgdir = 0;
f0103978:	c7 47 60 00 00 00 00 	movl   $0x0,0x60(%edi)
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010397f:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103985:	c1 e8 0c             	shr    $0xc,%eax
f0103988:	3b 05 e8 3e 22 f0    	cmp    0xf0223ee8,%eax
f010398e:	72 1c                	jb     f01039ac <env_free+0x1db>
		panic("pa2page called with invalid pa");
f0103990:	c7 44 24 08 1c 6c 10 	movl   $0xf0106c1c,0x8(%esp)
f0103997:	f0 
f0103998:	c7 44 24 04 51 00 00 	movl   $0x51,0x4(%esp)
f010399f:	00 
f01039a0:	c7 04 24 b7 73 10 f0 	movl   $0xf01073b7,(%esp)
f01039a7:	e8 d9 c6 ff ff       	call   f0100085 <_panic>
	page_decref(pa2page(pa));
f01039ac:	c1 e0 03             	shl    $0x3,%eax
f01039af:	03 05 f0 3e 22 f0    	add    0xf0223ef0,%eax
f01039b5:	89 04 24             	mov    %eax,(%esp)
f01039b8:	e8 c2 d1 ff ff       	call   f0100b7f <page_decref>

	// return the environment to the free list
	e->env_status = ENV_FREE;
f01039bd:	c7 47 54 00 00 00 00 	movl   $0x0,0x54(%edi)
	e->env_link = env_free_list;
f01039c4:	a1 3c 32 22 f0       	mov    0xf022323c,%eax
f01039c9:	89 47 44             	mov    %eax,0x44(%edi)
	env_free_list = e;
f01039cc:	89 3d 3c 32 22 f0    	mov    %edi,0xf022323c
}
f01039d2:	83 c4 2c             	add    $0x2c,%esp
f01039d5:	5b                   	pop    %ebx
f01039d6:	5e                   	pop    %esi
f01039d7:	5f                   	pop    %edi
f01039d8:	5d                   	pop    %ebp
f01039d9:	c3                   	ret    

f01039da <env_destroy>:
// If e was the current env, then runs a new environment (and does not return
// to the caller).
//
void
env_destroy(struct Env *e)
{
f01039da:	55                   	push   %ebp
f01039db:	89 e5                	mov    %esp,%ebp
f01039dd:	53                   	push   %ebx
f01039de:	83 ec 14             	sub    $0x14,%esp
f01039e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// If e is currently running on other CPUs, we change its state to
	// ENV_DYING. A zombie environment will be freed the next time
	// it traps to the kernel.
	if (e->env_status == ENV_RUNNING && curenv != e) {
f01039e4:	83 7b 54 03          	cmpl   $0x3,0x54(%ebx)
f01039e8:	75 19                	jne    f0103a03 <env_destroy+0x29>
f01039ea:	e8 40 24 00 00       	call   f0105e2f <cpunum>
f01039ef:	6b c0 74             	imul   $0x74,%eax,%eax
f01039f2:	39 98 28 40 22 f0    	cmp    %ebx,-0xfddbfd8(%eax)
f01039f8:	74 09                	je     f0103a03 <env_destroy+0x29>
		e->env_status = ENV_DYING;
f01039fa:	c7 43 54 01 00 00 00 	movl   $0x1,0x54(%ebx)
		return;
f0103a01:	eb 2f                	jmp    f0103a32 <env_destroy+0x58>
	}

	env_free(e);
f0103a03:	89 1c 24             	mov    %ebx,(%esp)
f0103a06:	e8 c6 fd ff ff       	call   f01037d1 <env_free>

	if (curenv == e) {
f0103a0b:	e8 1f 24 00 00       	call   f0105e2f <cpunum>
f0103a10:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a13:	39 98 28 40 22 f0    	cmp    %ebx,-0xfddbfd8(%eax)
f0103a19:	75 17                	jne    f0103a32 <env_destroy+0x58>
		curenv = NULL;
f0103a1b:	e8 0f 24 00 00       	call   f0105e2f <cpunum>
f0103a20:	6b c0 74             	imul   $0x74,%eax,%eax
f0103a23:	c7 80 28 40 22 f0 00 	movl   $0x0,-0xfddbfd8(%eax)
f0103a2a:	00 00 00 
		sched_yield();
f0103a2d:	e8 26 0f 00 00       	call   f0104958 <sched_yield>
	}
}
f0103a32:	83 c4 14             	add    $0x14,%esp
f0103a35:	5b                   	pop    %ebx
f0103a36:	5d                   	pop    %ebp
f0103a37:	c3                   	ret    

f0103a38 <env_alloc>:
//	-E_NO_FREE_ENV if all NENVS environments are allocated
//	-E_NO_MEM on memory exhaustion
//
int
env_alloc(struct Env **newenv_store, envid_t parent_id)
{
f0103a38:	55                   	push   %ebp
f0103a39:	89 e5                	mov    %esp,%ebp
f0103a3b:	53                   	push   %ebx
f0103a3c:	83 ec 14             	sub    $0x14,%esp
	int32_t generation;
	int r;
	struct Env *e;

	if (!(e = env_free_list))
f0103a3f:	8b 1d 3c 32 22 f0    	mov    0xf022323c,%ebx
f0103a45:	ba fb ff ff ff       	mov    $0xfffffffb,%edx
f0103a4a:	85 db                	test   %ebx,%ebx
f0103a4c:	0f 84 a8 01 00 00    	je     f0103bfa <env_alloc+0x1c2>
{
	int i;
	struct PageInfo *p = NULL;

	// Allocate a page for the page directory
	if (!(p = page_alloc(ALLOC_ZERO)))
f0103a52:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103a59:	e8 21 d7 ff ff       	call   f010117f <page_alloc>
f0103a5e:	ba fc ff ff ff       	mov    $0xfffffffc,%edx
f0103a63:	85 c0                	test   %eax,%eax
f0103a65:	0f 84 8f 01 00 00    	je     f0103bfa <env_alloc+0x1c2>
	//	is an exception -- you need to increment env_pgdir's
	//	pp_ref for env_free to work correctly.
	//    - The functions in kern/pmap.h are handy.

	// LAB 3: Your code here.
	p->pp_ref++;
f0103a6b:	66 83 40 04 01       	addw   $0x1,0x4(%eax)
void	user_mem_assert(struct Env *env, const void *va, size_t len, int perm);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0103a70:	2b 05 f0 3e 22 f0    	sub    0xf0223ef0,%eax
f0103a76:	c1 f8 03             	sar    $0x3,%eax
f0103a79:	c1 e0 0c             	shl    $0xc,%eax
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0103a7c:	89 c2                	mov    %eax,%edx
f0103a7e:	c1 ea 0c             	shr    $0xc,%edx
f0103a81:	3b 15 e8 3e 22 f0    	cmp    0xf0223ee8,%edx
f0103a87:	72 20                	jb     f0103aa9 <env_alloc+0x71>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0103a89:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103a8d:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f0103a94:	f0 
f0103a95:	c7 44 24 04 58 00 00 	movl   $0x58,0x4(%esp)
f0103a9c:	00 
f0103a9d:	c7 04 24 b7 73 10 f0 	movl   $0xf01073b7,(%esp)
f0103aa4:	e8 dc c5 ff ff       	call   f0100085 <_panic>
	e->env_pgdir=(pde_t *)page2kva(p);
f0103aa9:	2d 00 00 00 10       	sub    $0x10000000,%eax
f0103aae:	89 43 60             	mov    %eax,0x60(%ebx)
	
	memset (e->env_pgdir, 0, PDX(UTOP) * sizeof (pde_t));
f0103ab1:	c7 44 24 08 ec 0e 00 	movl   $0xeec,0x8(%esp)
f0103ab8:	00 
f0103ab9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103ac0:	00 
f0103ac1:	89 04 24             	mov    %eax,(%esp)
f0103ac4:	e8 bd 1c 00 00       	call   f0105786 <memset>
f0103ac9:	b8 ec 0e 00 00       	mov    $0xeec,%eax
	for(i=PDX(UTOP);i<1024;i++)  
		e->env_pgdir[i]=kern_pgdir[i];  
f0103ace:	8b 53 60             	mov    0x60(%ebx),%edx
f0103ad1:	8b 0d ec 3e 22 f0    	mov    0xf0223eec,%ecx
f0103ad7:	8b 0c 01             	mov    (%ecx,%eax,1),%ecx
f0103ada:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
f0103add:	83 c0 04             	add    $0x4,%eax
	// LAB 3: Your code here.
	p->pp_ref++;
	e->env_pgdir=(pde_t *)page2kva(p);
	
	memset (e->env_pgdir, 0, PDX(UTOP) * sizeof (pde_t));
	for(i=PDX(UTOP);i<1024;i++)  
f0103ae0:	3d 00 10 00 00       	cmp    $0x1000,%eax
f0103ae5:	75 e7                	jne    f0103ace <env_alloc+0x96>
	
	// kern_pgdir[PDX(UVPT)] = PADDR(kern_pgdir) | PTE_U | PTE_P;
	
	// UVPT maps the env's own page table read-only.
	// Permissions: kernel R, user R
	e->env_pgdir[PDX(UVPT)] = PADDR(e->env_pgdir) | PTE_P | PTE_U; // UVPT always store the current pagetable
f0103ae7:	8b 43 60             	mov    0x60(%ebx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103aea:	89 c2                	mov    %eax,%edx
f0103aec:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103af1:	77 20                	ja     f0103b13 <env_alloc+0xdb>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103af3:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103af7:	c7 44 24 08 dc 65 10 	movl   $0xf01065dc,0x8(%esp)
f0103afe:	f0 
f0103aff:	c7 44 24 04 d6 00 00 	movl   $0xd6,0x4(%esp)
f0103b06:	00 
f0103b07:	c7 04 24 a7 76 10 f0 	movl   $0xf01076a7,(%esp)
f0103b0e:	e8 72 c5 ff ff       	call   f0100085 <_panic>
f0103b13:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103b19:	83 ca 05             	or     $0x5,%edx
f0103b1c:	89 90 f4 0e 00 00    	mov    %edx,0xef4(%eax)
	// Allocate and set up the page directory for this environment.
	if ((r = env_setup_vm(e)) < 0)
		return r;

	// Generate an env_id for this environment.
	generation = (e->env_id + (1 << ENVGENSHIFT)) & ~(NENV - 1);
f0103b22:	8b 43 48             	mov    0x48(%ebx),%eax
f0103b25:	05 00 10 00 00       	add    $0x1000,%eax
	if (generation <= 0)	// Don't create a negative env_id.
f0103b2a:	25 00 fc ff ff       	and    $0xfffffc00,%eax
f0103b2f:	ba 00 10 00 00       	mov    $0x1000,%edx
f0103b34:	0f 4e c2             	cmovle %edx,%eax
		generation = 1 << ENVGENSHIFT;
	e->env_id = generation | (e - envs);
f0103b37:	89 da                	mov    %ebx,%edx
f0103b39:	2b 15 38 32 22 f0    	sub    0xf0223238,%edx
f0103b3f:	c1 fa 02             	sar    $0x2,%edx
f0103b42:	69 d2 df 7b ef bd    	imul   $0xbdef7bdf,%edx,%edx
f0103b48:	09 d0                	or     %edx,%eax
f0103b4a:	89 43 48             	mov    %eax,0x48(%ebx)

	// Set the basic status variables.
	e->env_parent_id = parent_id;
f0103b4d:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103b50:	89 43 4c             	mov    %eax,0x4c(%ebx)
	e->env_type = ENV_TYPE_USER;
f0103b53:	c7 43 50 00 00 00 00 	movl   $0x0,0x50(%ebx)
	e->env_status = ENV_RUNNABLE;
f0103b5a:	c7 43 54 02 00 00 00 	movl   $0x2,0x54(%ebx)
	e->env_runs = 0;
f0103b61:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)

	// Clear out all the saved register state,
	// to prevent the register values
	// of a prior environment inhabiting this Env structure
	// from "leaking" into our new environment.
	memset(&e->env_tf, 0, sizeof(e->env_tf));
f0103b68:	c7 44 24 08 44 00 00 	movl   $0x44,0x8(%esp)
f0103b6f:	00 
f0103b70:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103b77:	00 
f0103b78:	89 1c 24             	mov    %ebx,(%esp)
f0103b7b:	e8 06 1c 00 00       	call   f0105786 <memset>
	// The low 2 bits of each segment register contains the
	// Requestor Privilege Level (RPL); 3 means user mode.  When
	// we switch privilege levels, the hardware does various
	// checks involving the RPL and the Descriptor Privilege Level
	// (DPL) stored in the descriptors themselves.
	e->env_tf.tf_ds = GD_UD | 3;
f0103b80:	66 c7 43 24 23 00    	movw   $0x23,0x24(%ebx)
	e->env_tf.tf_es = GD_UD | 3;
f0103b86:	66 c7 43 20 23 00    	movw   $0x23,0x20(%ebx)
	e->env_tf.tf_ss = GD_UD | 3;
f0103b8c:	66 c7 43 40 23 00    	movw   $0x23,0x40(%ebx)
	e->env_tf.tf_esp = USTACKTOP;
f0103b92:	c7 43 3c 00 e0 bf ee 	movl   $0xeebfe000,0x3c(%ebx)
	e->env_tf.tf_cs = GD_UT | 3;
f0103b99:	66 c7 43 34 1b 00    	movw   $0x1b,0x34(%ebx)

	// Enable interrupts while in user mode.
	// LAB 4: Your code here.

	// Clear the page fault handler until user installs one.
	e->env_pgfault_upcall = 0;
f0103b9f:	c7 43 64 00 00 00 00 	movl   $0x0,0x64(%ebx)

	// Also clear the IPC receiving flag.
	e->env_ipc_recving = 0;
f0103ba6:	c6 43 68 00          	movb   $0x0,0x68(%ebx)

	// commit the allocation
	env_free_list = e->env_link;
f0103baa:	8b 43 44             	mov    0x44(%ebx),%eax
f0103bad:	a3 3c 32 22 f0       	mov    %eax,0xf022323c
	*newenv_store = e;
f0103bb2:	8b 45 08             	mov    0x8(%ebp),%eax
f0103bb5:	89 18                	mov    %ebx,(%eax)

	cprintf("[%08x] new env %08x\n", curenv ? curenv->env_id : 0, e->env_id);
f0103bb7:	8b 5b 48             	mov    0x48(%ebx),%ebx
f0103bba:	e8 70 22 00 00       	call   f0105e2f <cpunum>
f0103bbf:	6b d0 74             	imul   $0x74,%eax,%edx
f0103bc2:	b8 00 00 00 00       	mov    $0x0,%eax
f0103bc7:	83 ba 28 40 22 f0 00 	cmpl   $0x0,-0xfddbfd8(%edx)
f0103bce:	74 11                	je     f0103be1 <env_alloc+0x1a9>
f0103bd0:	e8 5a 22 00 00       	call   f0105e2f <cpunum>
f0103bd5:	6b c0 74             	imul   $0x74,%eax,%eax
f0103bd8:	8b 80 28 40 22 f0    	mov    -0xfddbfd8(%eax),%eax
f0103bde:	8b 40 48             	mov    0x48(%eax),%eax
f0103be1:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103be5:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103be9:	c7 04 24 c8 76 10 f0 	movl   $0xf01076c8,(%esp)
f0103bf0:	e8 34 03 00 00       	call   f0103f29 <cprintf>
f0103bf5:	ba 00 00 00 00       	mov    $0x0,%edx
	return 0;
}
f0103bfa:	89 d0                	mov    %edx,%eax
f0103bfc:	83 c4 14             	add    $0x14,%esp
f0103bff:	5b                   	pop    %ebx
f0103c00:	5d                   	pop    %ebp
f0103c01:	c3                   	ret    

f0103c02 <region_alloc>:
// Pages should be writable by user and kernel.
// Panic if any allocation attempt fails.
//
static void
region_alloc(struct Env *e, void *va, size_t len)
{
f0103c02:	55                   	push   %ebp
f0103c03:	89 e5                	mov    %esp,%ebp
f0103c05:	57                   	push   %edi
f0103c06:	56                   	push   %esi
f0103c07:	53                   	push   %ebx
f0103c08:	83 ec 1c             	sub    $0x1c,%esp
f0103c0b:	89 c6                	mov    %eax,%esi
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	
 	void* i;   
	for(i=ROUNDDOWN(va,PGSIZE);i<ROUNDUP(va+len,PGSIZE);i+=PGSIZE)  
f0103c0d:	89 d3                	mov    %edx,%ebx
f0103c0f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
f0103c15:	8d bc 0a ff 0f 00 00 	lea    0xfff(%edx,%ecx,1),%edi
f0103c1c:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
f0103c22:	39 fb                	cmp    %edi,%ebx
f0103c24:	73 51                	jae    f0103c77 <region_alloc+0x75>
	{  
		struct PageInfo* p=(struct PageInfo*)page_alloc(1);  
f0103c26:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
f0103c2d:	e8 4d d5 ff ff       	call   f010117f <page_alloc>
		if(p==NULL)  
f0103c32:	85 c0                	test   %eax,%eax
f0103c34:	75 1c                	jne    f0103c52 <region_alloc+0x50>
			panic("Memory out!");  
f0103c36:	c7 44 24 08 dd 76 10 	movl   $0xf01076dd,0x8(%esp)
f0103c3d:	f0 
f0103c3e:	c7 44 24 04 3a 01 00 	movl   $0x13a,0x4(%esp)
f0103c45:	00 
f0103c46:	c7 04 24 a7 76 10 f0 	movl   $0xf01076a7,(%esp)
f0103c4d:	e8 33 c4 ff ff       	call   f0100085 <_panic>
		page_insert(e->env_pgdir,p,i,PTE_W|PTE_U);  
f0103c52:	c7 44 24 0c 06 00 00 	movl   $0x6,0xc(%esp)
f0103c59:	00 
f0103c5a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0103c5e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103c62:	8b 46 60             	mov    0x60(%esi),%eax
f0103c65:	89 04 24             	mov    %eax,(%esp)
f0103c68:	e8 de d8 ff ff       	call   f010154b <page_insert>
	//   'va' and 'len' values that are not page-aligned.
	//   You should round va down, and round (va + len) up.
	//   (Watch out for corner-cases!)
	
 	void* i;   
	for(i=ROUNDDOWN(va,PGSIZE);i<ROUNDUP(va+len,PGSIZE);i+=PGSIZE)  
f0103c6d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
f0103c73:	39 fb                	cmp    %edi,%ebx
f0103c75:	72 af                	jb     f0103c26 <region_alloc+0x24>
		struct PageInfo* p=(struct PageInfo*)page_alloc(1);  
		if(p==NULL)  
			panic("Memory out!");  
		page_insert(e->env_pgdir,p,i,PTE_W|PTE_U);  
	} 
}
f0103c77:	83 c4 1c             	add    $0x1c,%esp
f0103c7a:	5b                   	pop    %ebx
f0103c7b:	5e                   	pop    %esi
f0103c7c:	5f                   	pop    %edi
f0103c7d:	5d                   	pop    %ebp
f0103c7e:	c3                   	ret    

f0103c7f <env_create>:
// before running the first user-mode environment.
// The new env's parent ID is set to 0.
//
void
env_create(uint8_t *binary, size_t size, enum EnvType type)
{
f0103c7f:	55                   	push   %ebp
f0103c80:	89 e5                	mov    %esp,%ebp
f0103c82:	57                   	push   %edi
f0103c83:	56                   	push   %esi
f0103c84:	53                   	push   %ebx
f0103c85:	83 ec 3c             	sub    $0x3c,%esp
	// LAB 3: Your code here.
	
	struct Env *p;
	env_alloc(&p,0);
f0103c88:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103c8f:	00 
f0103c90:	8d 45 e4             	lea    -0x1c(%ebp),%eax
f0103c93:	89 04 24             	mov    %eax,(%esp)
f0103c96:	e8 9d fd ff ff       	call   f0103a38 <env_alloc>
	p->env_type=type;
f0103c9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103c9e:	8b 55 10             	mov    0x10(%ebp),%edx
f0103ca1:	89 50 50             	mov    %edx,0x50(%eax)
	load_icode(p, binary, size);
f0103ca4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0103ca7:	89 45 d4             	mov    %eax,-0x2c(%ebp)
	

	// LAB 3: Your code here.
	

	struct Elf *ELFHDR = (struct Elf*) binary;
f0103caa:	8b 7d 08             	mov    0x8(%ebp),%edi
	struct Proghdr *ph, *eph;
	int i;

	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
f0103cad:	81 3f 7f 45 4c 46    	cmpl   $0x464c457f,(%edi)
f0103cb3:	74 1c                	je     f0103cd1 <env_create+0x52>
		panic ("load_icode: Not a valid ELF");
f0103cb5:	c7 44 24 08 e9 76 10 	movl   $0xf01076e9,0x8(%esp)
f0103cbc:	f0 
f0103cbd:	c7 44 24 04 63 01 00 	movl   $0x163,0x4(%esp)
f0103cc4:	00 
f0103cc5:	c7 04 24 a7 76 10 f0 	movl   $0xf01076a7,(%esp)
f0103ccc:	e8 b4 c3 ff ff       	call   f0100085 <_panic>

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f0103cd1:	8b 5f 1c             	mov    0x1c(%edi),%ebx
	eph = ph + ELFHDR->e_phnum;
f0103cd4:	0f b7 77 2c          	movzwl 0x2c(%edi),%esi
	
	lcr3 (PADDR(e->env_pgdir));
f0103cd8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103cdb:	8b 42 60             	mov    0x60(%edx),%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103cde:	89 c2                	mov    %eax,%edx
f0103ce0:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103ce5:	77 20                	ja     f0103d07 <env_create+0x88>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103ce7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103ceb:	c7 44 24 08 dc 65 10 	movl   $0xf01065dc,0x8(%esp)
f0103cf2:	f0 
f0103cf3:	c7 44 24 04 69 01 00 	movl   $0x169,0x4(%esp)
f0103cfa:	00 
f0103cfb:	c7 04 24 a7 76 10 f0 	movl   $0xf01076a7,(%esp)
f0103d02:	e8 7e c3 ff ff       	call   f0100085 <_panic>
	// is this a valid ELF?
	if (ELFHDR->e_magic != ELF_MAGIC)
		panic ("load_icode: Not a valid ELF");

	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
f0103d07:	8d 1c 1f             	lea    (%edi,%ebx,1),%ebx
	eph = ph + ELFHDR->e_phnum;
f0103d0a:	0f b7 f6             	movzwl %si,%esi
f0103d0d:	c1 e6 05             	shl    $0x5,%esi
f0103d10:	8d 34 33             	lea    (%ebx,%esi,1),%esi
f0103d13:	81 c2 00 00 00 10    	add    $0x10000000,%edx
f0103d19:	0f 22 da             	mov    %edx,%cr3
	
	lcr3 (PADDR(e->env_pgdir));
	for (; ph < eph; ph++) 
f0103d1c:	39 f3                	cmp    %esi,%ebx
f0103d1e:	73 50                	jae    f0103d70 <env_create+0xf1>
		// p_pa is the load address of this segment (as well
		// as the physical address)
		//readseg(ph->p_pa, ph->p_memsz, ph->p_offset);
		if (ph->p_type == ELF_PROG_LOAD) {
f0103d20:	83 3b 01             	cmpl   $0x1,(%ebx)
f0103d23:	75 44                	jne    f0103d69 <env_create+0xea>
			region_alloc (e, (void*) ph->p_va, ph->p_memsz);
f0103d25:	8b 4b 14             	mov    0x14(%ebx),%ecx
f0103d28:	8b 53 08             	mov    0x8(%ebx),%edx
f0103d2b:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103d2e:	e8 cf fe ff ff       	call   f0103c02 <region_alloc>
			memset ((void *)ph->p_va, 0, ph->p_memsz);
f0103d33:	8b 43 14             	mov    0x14(%ebx),%eax
f0103d36:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103d3a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
f0103d41:	00 
f0103d42:	8b 43 08             	mov    0x8(%ebx),%eax
f0103d45:	89 04 24             	mov    %eax,(%esp)
f0103d48:	e8 39 1a 00 00       	call   f0105786 <memset>
			memmove ((void *)ph->p_va, binary + ph->p_offset, ph->p_filesz);
f0103d4d:	8b 43 10             	mov    0x10(%ebx),%eax
f0103d50:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103d54:	8b 45 08             	mov    0x8(%ebp),%eax
f0103d57:	03 43 04             	add    0x4(%ebx),%eax
f0103d5a:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103d5e:	8b 43 08             	mov    0x8(%ebx),%eax
f0103d61:	89 04 24             	mov    %eax,(%esp)
f0103d64:	e8 7c 1a 00 00       	call   f01057e5 <memmove>
	// load each program segment (ignores ph flags)
	ph = (struct Proghdr *) ((uint8_t *) ELFHDR + ELFHDR->e_phoff);
	eph = ph + ELFHDR->e_phnum;
	
	lcr3 (PADDR(e->env_pgdir));
	for (; ph < eph; ph++) 
f0103d69:	83 c3 20             	add    $0x20,%ebx
f0103d6c:	39 de                	cmp    %ebx,%esi
f0103d6e:	77 b0                	ja     f0103d20 <env_create+0xa1>
		}
	
	
	// call the entry point from the ELF header
	// note: does not return!
	lcr3(PADDR(kern_pgdir)); 
f0103d70:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0103d75:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f0103d7a:	77 20                	ja     f0103d9c <env_create+0x11d>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0103d7c:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103d80:	c7 44 24 08 dc 65 10 	movl   $0xf01065dc,0x8(%esp)
f0103d87:	f0 
f0103d88:	c7 44 24 04 77 01 00 	movl   $0x177,0x4(%esp)
f0103d8f:	00 
f0103d90:	c7 04 24 a7 76 10 f0 	movl   $0xf01076a7,(%esp)
f0103d97:	e8 e9 c2 ff ff       	call   f0100085 <_panic>
f0103d9c:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0103da2:	0f 22 d8             	mov    %eax,%cr3
	e->env_tf.tf_eip = ELFHDR->e_entry;
f0103da5:	8b 47 18             	mov    0x18(%edi),%eax
f0103da8:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0103dab:	89 42 30             	mov    %eax,0x30(%edx)
	// Now map one page for the program's initial stack
	// at virtual address USTACKTOP - PGSIZE.
	// LAB 3: Your code here. 

	region_alloc (e, (void*) (USTACKTOP - PGSIZE), PGSIZE);	
f0103dae:	b9 00 10 00 00       	mov    $0x1000,%ecx
f0103db3:	ba 00 d0 bf ee       	mov    $0xeebfd000,%edx
f0103db8:	8b 45 d4             	mov    -0x2c(%ebp),%eax
f0103dbb:	e8 42 fe ff ff       	call   f0103c02 <region_alloc>
	 
	cprintf("load_icode finish!\r\n"); 
f0103dc0:	c7 04 24 05 77 10 f0 	movl   $0xf0107705,(%esp)
f0103dc7:	e8 5d 01 00 00       	call   f0103f29 <cprintf>
	p->env_type=type;
	load_icode(p, binary, size);

	// int env_alloc(struct Env **newenv_store, envid_t parent_id)
	
}
f0103dcc:	83 c4 3c             	add    $0x3c,%esp
f0103dcf:	5b                   	pop    %ebx
f0103dd0:	5e                   	pop    %esi
f0103dd1:	5f                   	pop    %edi
f0103dd2:	5d                   	pop    %ebp
f0103dd3:	c3                   	ret    

f0103dd4 <mc146818_read>:
#include <kern/kclock.h>


unsigned
mc146818_read(unsigned reg)
{
f0103dd4:	55                   	push   %ebp
f0103dd5:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103dd7:	ba 70 00 00 00       	mov    $0x70,%edx
f0103ddc:	8b 45 08             	mov    0x8(%ebp),%eax
f0103ddf:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0103de0:	b2 71                	mov    $0x71,%dl
f0103de2:	ec                   	in     (%dx),%al
f0103de3:	0f b6 c0             	movzbl %al,%eax
	outb(IO_RTC, reg);
	return inb(IO_RTC+1);
}
f0103de6:	5d                   	pop    %ebp
f0103de7:	c3                   	ret    

f0103de8 <mc146818_write>:

void
mc146818_write(unsigned reg, unsigned datum)
{
f0103de8:	55                   	push   %ebp
f0103de9:	89 e5                	mov    %esp,%ebp
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0103deb:	ba 70 00 00 00       	mov    $0x70,%edx
f0103df0:	8b 45 08             	mov    0x8(%ebp),%eax
f0103df3:	ee                   	out    %al,(%dx)
f0103df4:	b2 71                	mov    $0x71,%dl
f0103df6:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103df9:	ee                   	out    %al,(%dx)
	outb(IO_RTC, reg);
	outb(IO_RTC+1, datum);
}
f0103dfa:	5d                   	pop    %ebp
f0103dfb:	c3                   	ret    

f0103dfc <irq_setmask_8259A>:
		irq_setmask_8259A(irq_mask_8259A);
}

void
irq_setmask_8259A(uint16_t mask)
{
f0103dfc:	55                   	push   %ebp
f0103dfd:	89 e5                	mov    %esp,%ebp
f0103dff:	56                   	push   %esi
f0103e00:	53                   	push   %ebx
f0103e01:	83 ec 10             	sub    $0x10,%esp
f0103e04:	8b 45 08             	mov    0x8(%ebp),%eax
f0103e07:	89 c6                	mov    %eax,%esi
	int i;
	irq_mask_8259A = mask;
f0103e09:	66 a3 8e 03 12 f0    	mov    %ax,0xf012038e
	if (!didinit)
f0103e0f:	80 3d 40 32 22 f0 00 	cmpb   $0x0,0xf0223240
f0103e16:	74 4e                	je     f0103e66 <irq_setmask_8259A+0x6a>
f0103e18:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e1d:	ee                   	out    %al,(%dx)
f0103e1e:	89 f0                	mov    %esi,%eax
f0103e20:	66 c1 e8 08          	shr    $0x8,%ax
f0103e24:	b2 a1                	mov    $0xa1,%dl
f0103e26:	ee                   	out    %al,(%dx)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
f0103e27:	c7 04 24 1a 77 10 f0 	movl   $0xf010771a,(%esp)
f0103e2e:	e8 f6 00 00 00       	call   f0103f29 <cprintf>
f0103e33:	bb 00 00 00 00       	mov    $0x0,%ebx
	for (i = 0; i < 16; i++)
		if (~mask & (1<<i))
f0103e38:	0f b7 f6             	movzwl %si,%esi
f0103e3b:	f7 d6                	not    %esi
f0103e3d:	0f a3 de             	bt     %ebx,%esi
f0103e40:	73 10                	jae    f0103e52 <irq_setmask_8259A+0x56>
			cprintf(" %d", i);
f0103e42:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f0103e46:	c7 04 24 9e 7b 10 f0 	movl   $0xf0107b9e,(%esp)
f0103e4d:	e8 d7 00 00 00       	call   f0103f29 <cprintf>
	if (!didinit)
		return;
	outb(IO_PIC1+1, (char)mask);
	outb(IO_PIC2+1, (char)(mask >> 8));
	cprintf("enabled interrupts:");
	for (i = 0; i < 16; i++)
f0103e52:	83 c3 01             	add    $0x1,%ebx
f0103e55:	83 fb 10             	cmp    $0x10,%ebx
f0103e58:	75 e3                	jne    f0103e3d <irq_setmask_8259A+0x41>
		if (~mask & (1<<i))
			cprintf(" %d", i);
	cprintf("\n");
f0103e5a:	c7 04 24 18 77 10 f0 	movl   $0xf0107718,(%esp)
f0103e61:	e8 c3 00 00 00       	call   f0103f29 <cprintf>
}
f0103e66:	83 c4 10             	add    $0x10,%esp
f0103e69:	5b                   	pop    %ebx
f0103e6a:	5e                   	pop    %esi
f0103e6b:	5d                   	pop    %ebp
f0103e6c:	c3                   	ret    

f0103e6d <pic_init>:
static bool didinit;

/* Initialize the 8259A interrupt controllers. */
void
pic_init(void)
{
f0103e6d:	55                   	push   %ebp
f0103e6e:	89 e5                	mov    %esp,%ebp
f0103e70:	83 ec 18             	sub    $0x18,%esp
	didinit = 1;
f0103e73:	c6 05 40 32 22 f0 01 	movb   $0x1,0xf0223240
f0103e7a:	ba 21 00 00 00       	mov    $0x21,%edx
f0103e7f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0103e84:	ee                   	out    %al,(%dx)
f0103e85:	b2 a1                	mov    $0xa1,%dl
f0103e87:	ee                   	out    %al,(%dx)
f0103e88:	b2 20                	mov    $0x20,%dl
f0103e8a:	b8 11 00 00 00       	mov    $0x11,%eax
f0103e8f:	ee                   	out    %al,(%dx)
f0103e90:	b2 21                	mov    $0x21,%dl
f0103e92:	b8 20 00 00 00       	mov    $0x20,%eax
f0103e97:	ee                   	out    %al,(%dx)
f0103e98:	b8 04 00 00 00       	mov    $0x4,%eax
f0103e9d:	ee                   	out    %al,(%dx)
f0103e9e:	b8 03 00 00 00       	mov    $0x3,%eax
f0103ea3:	ee                   	out    %al,(%dx)
f0103ea4:	b2 a0                	mov    $0xa0,%dl
f0103ea6:	b8 11 00 00 00       	mov    $0x11,%eax
f0103eab:	ee                   	out    %al,(%dx)
f0103eac:	b2 a1                	mov    $0xa1,%dl
f0103eae:	b8 28 00 00 00       	mov    $0x28,%eax
f0103eb3:	ee                   	out    %al,(%dx)
f0103eb4:	b8 02 00 00 00       	mov    $0x2,%eax
f0103eb9:	ee                   	out    %al,(%dx)
f0103eba:	b8 01 00 00 00       	mov    $0x1,%eax
f0103ebf:	ee                   	out    %al,(%dx)
f0103ec0:	b2 20                	mov    $0x20,%dl
f0103ec2:	b8 68 00 00 00       	mov    $0x68,%eax
f0103ec7:	ee                   	out    %al,(%dx)
f0103ec8:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103ecd:	ee                   	out    %al,(%dx)
f0103ece:	b2 a0                	mov    $0xa0,%dl
f0103ed0:	b8 68 00 00 00       	mov    $0x68,%eax
f0103ed5:	ee                   	out    %al,(%dx)
f0103ed6:	b8 0a 00 00 00       	mov    $0xa,%eax
f0103edb:	ee                   	out    %al,(%dx)
	outb(IO_PIC1, 0x0a);             /* read IRR by default */

	outb(IO_PIC2, 0x68);               /* OCW3 */
	outb(IO_PIC2, 0x0a);               /* OCW3 */

	if (irq_mask_8259A != 0xFFFF)
f0103edc:	0f b7 05 8e 03 12 f0 	movzwl 0xf012038e,%eax
f0103ee3:	66 83 f8 ff          	cmp    $0xffff,%ax
f0103ee7:	74 0b                	je     f0103ef4 <pic_init+0x87>
		irq_setmask_8259A(irq_mask_8259A);
f0103ee9:	0f b7 c0             	movzwl %ax,%eax
f0103eec:	89 04 24             	mov    %eax,(%esp)
f0103eef:	e8 08 ff ff ff       	call   f0103dfc <irq_setmask_8259A>
}
f0103ef4:	c9                   	leave  
f0103ef5:	c3                   	ret    

f0103ef6 <vcprintf>:
	*cnt++;
}

int
vcprintf(const char *fmt, va_list ap)
{
f0103ef6:	55                   	push   %ebp
f0103ef7:	89 e5                	mov    %esp,%ebp
f0103ef9:	83 ec 28             	sub    $0x28,%esp
	int cnt = 0;
f0103efc:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0103f03:	8b 45 0c             	mov    0xc(%ebp),%eax
f0103f06:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0103f0a:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f0d:	89 44 24 08          	mov    %eax,0x8(%esp)
f0103f11:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0103f14:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f18:	c7 04 24 43 3f 10 f0 	movl   $0xf0103f43,(%esp)
f0103f1f:	e8 b9 10 00 00       	call   f0104fdd <vprintfmt>
	return cnt;
}
f0103f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0103f27:	c9                   	leave  
f0103f28:	c3                   	ret    

f0103f29 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f0103f29:	55                   	push   %ebp
f0103f2a:	89 e5                	mov    %esp,%ebp
f0103f2c:	83 ec 18             	sub    $0x18,%esp
	vprintfmt((void*)putch, &cnt, fmt, ap);
	return cnt;
}

int
cprintf(const char *fmt, ...)
f0103f2f:	8d 45 0c             	lea    0xc(%ebp),%eax
{
	va_list ap;
	int cnt;

	va_start(ap, fmt);
	cnt = vcprintf(fmt, ap);
f0103f32:	89 44 24 04          	mov    %eax,0x4(%esp)
f0103f36:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f39:	89 04 24             	mov    %eax,(%esp)
f0103f3c:	e8 b5 ff ff ff       	call   f0103ef6 <vcprintf>
	va_end(ap);

	return cnt;
}
f0103f41:	c9                   	leave  
f0103f42:	c3                   	ret    

f0103f43 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0103f43:	55                   	push   %ebp
f0103f44:	89 e5                	mov    %esp,%ebp
f0103f46:	83 ec 18             	sub    $0x18,%esp
	cputchar(ch);
f0103f49:	8b 45 08             	mov    0x8(%ebp),%eax
f0103f4c:	89 04 24             	mov    %eax,(%esp)
f0103f4f:	e8 76 c6 ff ff       	call   f01005ca <cputchar>
	*cnt++;
}
f0103f54:	c9                   	leave  
f0103f55:	c3                   	ret    
f0103f56:	66 90                	xchg   %ax,%ax
f0103f58:	66 90                	xchg   %ax,%ax
f0103f5a:	66 90                	xchg   %ax,%ax
f0103f5c:	66 90                	xchg   %ax,%ax
f0103f5e:	66 90                	xchg   %ax,%ax

f0103f60 <trap_init_percpu>:
}

// Initialize and load the per-CPU TSS and IDT
void
trap_init_percpu(void)
{
f0103f60:	55                   	push   %ebp
f0103f61:	89 e5                	mov    %esp,%ebp
	//
	// LAB 4: Your code here:

	// Setup a TSS so that we get the right stack
	// when we trap to the kernel.
	ts.ts_esp0 = KSTACKTOP;
f0103f63:	c7 05 64 3a 22 f0 00 	movl   $0xf0000000,0xf0223a64
f0103f6a:	00 00 f0 
	ts.ts_ss0 = GD_KD;
f0103f6d:	66 c7 05 68 3a 22 f0 	movw   $0x10,0xf0223a68
f0103f74:	10 00 

	// Initialize the TSS slot of the gdt.
	gdt[GD_TSS0 >> 3] = SEG16(STS_T32A, (uint32_t) (&ts),
f0103f76:	66 c7 05 48 03 12 f0 	movw   $0x68,0xf0120348
f0103f7d:	68 00 
f0103f7f:	b8 60 3a 22 f0       	mov    $0xf0223a60,%eax
f0103f84:	66 a3 4a 03 12 f0    	mov    %ax,0xf012034a
f0103f8a:	89 c2                	mov    %eax,%edx
f0103f8c:	c1 ea 10             	shr    $0x10,%edx
f0103f8f:	88 15 4c 03 12 f0    	mov    %dl,0xf012034c
f0103f95:	c6 05 4e 03 12 f0 40 	movb   $0x40,0xf012034e
f0103f9c:	c1 e8 18             	shr    $0x18,%eax
f0103f9f:	a2 4f 03 12 f0       	mov    %al,0xf012034f
					sizeof(struct Taskstate), 0);
	gdt[GD_TSS0 >> 3].sd_s = 0;
f0103fa4:	c6 05 4d 03 12 f0 89 	movb   $0x89,0xf012034d
}

static __inline void
ltr(uint16_t sel)
{
	__asm __volatile("ltr %0" : : "r" (sel));
f0103fab:	b8 28 00 00 00       	mov    $0x28,%eax
f0103fb0:	0f 00 d8             	ltr    %ax
}

static __inline void
lidt(void *p)
{
	__asm __volatile("lidt (%0)" : : "r" (p));
f0103fb3:	b8 90 03 12 f0       	mov    $0xf0120390,%eax
f0103fb8:	0f 01 18             	lidtl  (%eax)
	// bottom three bits are special; we leave them 0)
	ltr(GD_TSS0);

	// Load the IDT
	lidt(&idt_pd);
}
f0103fbb:	5d                   	pop    %ebp
f0103fbc:	c3                   	ret    

f0103fbd <trap_init>:
}


void
trap_init(void)
{
f0103fbd:	55                   	push   %ebp
f0103fbe:	89 e5                	mov    %esp,%ebp
	extern void routine_mchk ();
	extern void routine_simderr ();
	
	extern void routine_syscall();
	
	SETGATE (idt[T_DIVIDE], 0, GD_KT, routine_divide, 0);
f0103fc0:	b8 e6 47 10 f0       	mov    $0xf01047e6,%eax
f0103fc5:	66 a3 60 32 22 f0    	mov    %ax,0xf0223260
f0103fcb:	66 c7 05 62 32 22 f0 	movw   $0x8,0xf0223262
f0103fd2:	08 00 
f0103fd4:	c6 05 64 32 22 f0 00 	movb   $0x0,0xf0223264
f0103fdb:	c6 05 65 32 22 f0 8e 	movb   $0x8e,0xf0223265
f0103fe2:	c1 e8 10             	shr    $0x10,%eax
f0103fe5:	66 a3 66 32 22 f0    	mov    %ax,0xf0223266
	SETGATE (idt[T_DEBUG], 0, GD_KT, routine_debug, 0);
f0103feb:	b8 ec 47 10 f0       	mov    $0xf01047ec,%eax
f0103ff0:	66 a3 68 32 22 f0    	mov    %ax,0xf0223268
f0103ff6:	66 c7 05 6a 32 22 f0 	movw   $0x8,0xf022326a
f0103ffd:	08 00 
f0103fff:	c6 05 6c 32 22 f0 00 	movb   $0x0,0xf022326c
f0104006:	c6 05 6d 32 22 f0 8e 	movb   $0x8e,0xf022326d
f010400d:	c1 e8 10             	shr    $0x10,%eax
f0104010:	66 a3 6e 32 22 f0    	mov    %ax,0xf022326e
	SETGATE (idt[T_NMI], 0, GD_KT, routine_nmi, 0);
f0104016:	b8 f2 47 10 f0       	mov    $0xf01047f2,%eax
f010401b:	66 a3 70 32 22 f0    	mov    %ax,0xf0223270
f0104021:	66 c7 05 72 32 22 f0 	movw   $0x8,0xf0223272
f0104028:	08 00 
f010402a:	c6 05 74 32 22 f0 00 	movb   $0x0,0xf0223274
f0104031:	c6 05 75 32 22 f0 8e 	movb   $0x8e,0xf0223275
f0104038:	c1 e8 10             	shr    $0x10,%eax
f010403b:	66 a3 76 32 22 f0    	mov    %ax,0xf0223276
	
	// break point needs no kernel mode privilege
	SETGATE (idt[T_BRKPT], 0, GD_KT, routine_brkpt, 3);
f0104041:	b8 f8 47 10 f0       	mov    $0xf01047f8,%eax
f0104046:	66 a3 78 32 22 f0    	mov    %ax,0xf0223278
f010404c:	66 c7 05 7a 32 22 f0 	movw   $0x8,0xf022327a
f0104053:	08 00 
f0104055:	c6 05 7c 32 22 f0 00 	movb   $0x0,0xf022327c
f010405c:	c6 05 7d 32 22 f0 ee 	movb   $0xee,0xf022327d
f0104063:	c1 e8 10             	shr    $0x10,%eax
f0104066:	66 a3 7e 32 22 f0    	mov    %ax,0xf022327e
	
	SETGATE (idt[T_OFLOW], 0, GD_KT, routine_oflow, 0);
f010406c:	b8 fe 47 10 f0       	mov    $0xf01047fe,%eax
f0104071:	66 a3 80 32 22 f0    	mov    %ax,0xf0223280
f0104077:	66 c7 05 82 32 22 f0 	movw   $0x8,0xf0223282
f010407e:	08 00 
f0104080:	c6 05 84 32 22 f0 00 	movb   $0x0,0xf0223284
f0104087:	c6 05 85 32 22 f0 8e 	movb   $0x8e,0xf0223285
f010408e:	c1 e8 10             	shr    $0x10,%eax
f0104091:	66 a3 86 32 22 f0    	mov    %ax,0xf0223286
	SETGATE (idt[T_BOUND], 0, GD_KT, routine_bound, 0);
f0104097:	b8 04 48 10 f0       	mov    $0xf0104804,%eax
f010409c:	66 a3 88 32 22 f0    	mov    %ax,0xf0223288
f01040a2:	66 c7 05 8a 32 22 f0 	movw   $0x8,0xf022328a
f01040a9:	08 00 
f01040ab:	c6 05 8c 32 22 f0 00 	movb   $0x0,0xf022328c
f01040b2:	c6 05 8d 32 22 f0 8e 	movb   $0x8e,0xf022328d
f01040b9:	c1 e8 10             	shr    $0x10,%eax
f01040bc:	66 a3 8e 32 22 f0    	mov    %ax,0xf022328e
	SETGATE (idt[T_ILLOP], 0, GD_KT, routine_illop, 0);
f01040c2:	b8 0a 48 10 f0       	mov    $0xf010480a,%eax
f01040c7:	66 a3 90 32 22 f0    	mov    %ax,0xf0223290
f01040cd:	66 c7 05 92 32 22 f0 	movw   $0x8,0xf0223292
f01040d4:	08 00 
f01040d6:	c6 05 94 32 22 f0 00 	movb   $0x0,0xf0223294
f01040dd:	c6 05 95 32 22 f0 8e 	movb   $0x8e,0xf0223295
f01040e4:	c1 e8 10             	shr    $0x10,%eax
f01040e7:	66 a3 96 32 22 f0    	mov    %ax,0xf0223296
	SETGATE (idt[T_DEVICE], 0, GD_KT, routine_device, 0);
f01040ed:	b8 10 48 10 f0       	mov    $0xf0104810,%eax
f01040f2:	66 a3 98 32 22 f0    	mov    %ax,0xf0223298
f01040f8:	66 c7 05 9a 32 22 f0 	movw   $0x8,0xf022329a
f01040ff:	08 00 
f0104101:	c6 05 9c 32 22 f0 00 	movb   $0x0,0xf022329c
f0104108:	c6 05 9d 32 22 f0 8e 	movb   $0x8e,0xf022329d
f010410f:	c1 e8 10             	shr    $0x10,%eax
f0104112:	66 a3 9e 32 22 f0    	mov    %ax,0xf022329e
	SETGATE (idt[T_DBLFLT], 0, GD_KT, routine_dblflt, 0);
f0104118:	b8 16 48 10 f0       	mov    $0xf0104816,%eax
f010411d:	66 a3 a0 32 22 f0    	mov    %ax,0xf02232a0
f0104123:	66 c7 05 a2 32 22 f0 	movw   $0x8,0xf02232a2
f010412a:	08 00 
f010412c:	c6 05 a4 32 22 f0 00 	movb   $0x0,0xf02232a4
f0104133:	c6 05 a5 32 22 f0 8e 	movb   $0x8e,0xf02232a5
f010413a:	c1 e8 10             	shr    $0x10,%eax
f010413d:	66 a3 a6 32 22 f0    	mov    %ax,0xf02232a6
	SETGATE (idt[T_TSS], 0, GD_KT, routine_tss, 0);
f0104143:	b8 1a 48 10 f0       	mov    $0xf010481a,%eax
f0104148:	66 a3 b0 32 22 f0    	mov    %ax,0xf02232b0
f010414e:	66 c7 05 b2 32 22 f0 	movw   $0x8,0xf02232b2
f0104155:	08 00 
f0104157:	c6 05 b4 32 22 f0 00 	movb   $0x0,0xf02232b4
f010415e:	c6 05 b5 32 22 f0 8e 	movb   $0x8e,0xf02232b5
f0104165:	c1 e8 10             	shr    $0x10,%eax
f0104168:	66 a3 b6 32 22 f0    	mov    %ax,0xf02232b6
	SETGATE (idt[T_SEGNP], 0, GD_KT, routine_segnp, 0);
f010416e:	b8 1e 48 10 f0       	mov    $0xf010481e,%eax
f0104173:	66 a3 b8 32 22 f0    	mov    %ax,0xf02232b8
f0104179:	66 c7 05 ba 32 22 f0 	movw   $0x8,0xf02232ba
f0104180:	08 00 
f0104182:	c6 05 bc 32 22 f0 00 	movb   $0x0,0xf02232bc
f0104189:	c6 05 bd 32 22 f0 8e 	movb   $0x8e,0xf02232bd
f0104190:	c1 e8 10             	shr    $0x10,%eax
f0104193:	66 a3 be 32 22 f0    	mov    %ax,0xf02232be
	SETGATE (idt[T_STACK], 0, GD_KT, routine_stack, 0);
f0104199:	b8 22 48 10 f0       	mov    $0xf0104822,%eax
f010419e:	66 a3 c0 32 22 f0    	mov    %ax,0xf02232c0
f01041a4:	66 c7 05 c2 32 22 f0 	movw   $0x8,0xf02232c2
f01041ab:	08 00 
f01041ad:	c6 05 c4 32 22 f0 00 	movb   $0x0,0xf02232c4
f01041b4:	c6 05 c5 32 22 f0 8e 	movb   $0x8e,0xf02232c5
f01041bb:	c1 e8 10             	shr    $0x10,%eax
f01041be:	66 a3 c6 32 22 f0    	mov    %ax,0xf02232c6
	SETGATE (idt[T_GPFLT], 0, GD_KT, routine_gpflt, 0);
f01041c4:	b8 26 48 10 f0       	mov    $0xf0104826,%eax
f01041c9:	66 a3 c8 32 22 f0    	mov    %ax,0xf02232c8
f01041cf:	66 c7 05 ca 32 22 f0 	movw   $0x8,0xf02232ca
f01041d6:	08 00 
f01041d8:	c6 05 cc 32 22 f0 00 	movb   $0x0,0xf02232cc
f01041df:	c6 05 cd 32 22 f0 8e 	movb   $0x8e,0xf02232cd
f01041e6:	c1 e8 10             	shr    $0x10,%eax
f01041e9:	66 a3 ce 32 22 f0    	mov    %ax,0xf02232ce
	SETGATE (idt[T_PGFLT], 0, GD_KT, routine_pgflt, 0);
f01041ef:	b8 2a 48 10 f0       	mov    $0xf010482a,%eax
f01041f4:	66 a3 d0 32 22 f0    	mov    %ax,0xf02232d0
f01041fa:	66 c7 05 d2 32 22 f0 	movw   $0x8,0xf02232d2
f0104201:	08 00 
f0104203:	c6 05 d4 32 22 f0 00 	movb   $0x0,0xf02232d4
f010420a:	c6 05 d5 32 22 f0 8e 	movb   $0x8e,0xf02232d5
f0104211:	c1 e8 10             	shr    $0x10,%eax
f0104214:	66 a3 d6 32 22 f0    	mov    %ax,0xf02232d6
	SETGATE (idt[T_FPERR], 0, GD_KT, routine_fperr, 0);
f010421a:	b8 2e 48 10 f0       	mov    $0xf010482e,%eax
f010421f:	66 a3 e0 32 22 f0    	mov    %ax,0xf02232e0
f0104225:	66 c7 05 e2 32 22 f0 	movw   $0x8,0xf02232e2
f010422c:	08 00 
f010422e:	c6 05 e4 32 22 f0 00 	movb   $0x0,0xf02232e4
f0104235:	c6 05 e5 32 22 f0 8e 	movb   $0x8e,0xf02232e5
f010423c:	c1 e8 10             	shr    $0x10,%eax
f010423f:	66 a3 e6 32 22 f0    	mov    %ax,0xf02232e6
	SETGATE (idt[T_ALIGN], 0, GD_KT, routine_align, 0);
f0104245:	b8 34 48 10 f0       	mov    $0xf0104834,%eax
f010424a:	66 a3 e8 32 22 f0    	mov    %ax,0xf02232e8
f0104250:	66 c7 05 ea 32 22 f0 	movw   $0x8,0xf02232ea
f0104257:	08 00 
f0104259:	c6 05 ec 32 22 f0 00 	movb   $0x0,0xf02232ec
f0104260:	c6 05 ed 32 22 f0 8e 	movb   $0x8e,0xf02232ed
f0104267:	c1 e8 10             	shr    $0x10,%eax
f010426a:	66 a3 ee 32 22 f0    	mov    %ax,0xf02232ee
	SETGATE (idt[T_MCHK], 0, GD_KT, routine_mchk, 0);
f0104270:	b8 38 48 10 f0       	mov    $0xf0104838,%eax
f0104275:	66 a3 f0 32 22 f0    	mov    %ax,0xf02232f0
f010427b:	66 c7 05 f2 32 22 f0 	movw   $0x8,0xf02232f2
f0104282:	08 00 
f0104284:	c6 05 f4 32 22 f0 00 	movb   $0x0,0xf02232f4
f010428b:	c6 05 f5 32 22 f0 8e 	movb   $0x8e,0xf02232f5
f0104292:	c1 e8 10             	shr    $0x10,%eax
f0104295:	66 a3 f6 32 22 f0    	mov    %ax,0xf02232f6
	SETGATE (idt[T_SIMDERR], 0, GD_KT, routine_simderr, 0);
f010429b:	b8 3e 48 10 f0       	mov    $0xf010483e,%eax
f01042a0:	66 a3 f8 32 22 f0    	mov    %ax,0xf02232f8
f01042a6:	66 c7 05 fa 32 22 f0 	movw   $0x8,0xf02232fa
f01042ad:	08 00 
f01042af:	c6 05 fc 32 22 f0 00 	movb   $0x0,0xf02232fc
f01042b6:	c6 05 fd 32 22 f0 8e 	movb   $0x8e,0xf02232fd
f01042bd:	c1 e8 10             	shr    $0x10,%eax
f01042c0:	66 a3 fe 32 22 f0    	mov    %ax,0xf02232fe
	
	// Exerices 7
	SETGATE (idt[T_SYSCALL], 0, GD_KT, routine_syscall, 3);
f01042c6:	b8 44 48 10 f0       	mov    $0xf0104844,%eax
f01042cb:	66 a3 e0 33 22 f0    	mov    %ax,0xf02233e0
f01042d1:	66 c7 05 e2 33 22 f0 	movw   $0x8,0xf02233e2
f01042d8:	08 00 
f01042da:	c6 05 e4 33 22 f0 00 	movb   $0x0,0xf02233e4
f01042e1:	c6 05 e5 33 22 f0 ee 	movb   $0xee,0xf02233e5
f01042e8:	c1 e8 10             	shr    $0x10,%eax
f01042eb:	66 a3 e6 33 22 f0    	mov    %ax,0xf02233e6
	
	// Per-CPU setup 
	trap_init_percpu();
f01042f1:	e8 6a fc ff ff       	call   f0103f60 <trap_init_percpu>
}
f01042f6:	5d                   	pop    %ebp
f01042f7:	c3                   	ret    

f01042f8 <print_regs>:
	}
}

void
print_regs(struct PushRegs *regs)
{
f01042f8:	55                   	push   %ebp
f01042f9:	89 e5                	mov    %esp,%ebp
f01042fb:	53                   	push   %ebx
f01042fc:	83 ec 14             	sub    $0x14,%esp
f01042ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("  edi  0x%08x\n", regs->reg_edi);
f0104302:	8b 03                	mov    (%ebx),%eax
f0104304:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104308:	c7 04 24 2e 77 10 f0 	movl   $0xf010772e,(%esp)
f010430f:	e8 15 fc ff ff       	call   f0103f29 <cprintf>
	cprintf("  esi  0x%08x\n", regs->reg_esi);
f0104314:	8b 43 04             	mov    0x4(%ebx),%eax
f0104317:	89 44 24 04          	mov    %eax,0x4(%esp)
f010431b:	c7 04 24 3d 77 10 f0 	movl   $0xf010773d,(%esp)
f0104322:	e8 02 fc ff ff       	call   f0103f29 <cprintf>
	cprintf("  ebp  0x%08x\n", regs->reg_ebp);
f0104327:	8b 43 08             	mov    0x8(%ebx),%eax
f010432a:	89 44 24 04          	mov    %eax,0x4(%esp)
f010432e:	c7 04 24 4c 77 10 f0 	movl   $0xf010774c,(%esp)
f0104335:	e8 ef fb ff ff       	call   f0103f29 <cprintf>
	cprintf("  oesp 0x%08x\n", regs->reg_oesp);
f010433a:	8b 43 0c             	mov    0xc(%ebx),%eax
f010433d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104341:	c7 04 24 5b 77 10 f0 	movl   $0xf010775b,(%esp)
f0104348:	e8 dc fb ff ff       	call   f0103f29 <cprintf>
	cprintf("  ebx  0x%08x\n", regs->reg_ebx);
f010434d:	8b 43 10             	mov    0x10(%ebx),%eax
f0104350:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104354:	c7 04 24 6a 77 10 f0 	movl   $0xf010776a,(%esp)
f010435b:	e8 c9 fb ff ff       	call   f0103f29 <cprintf>
	cprintf("  edx  0x%08x\n", regs->reg_edx);
f0104360:	8b 43 14             	mov    0x14(%ebx),%eax
f0104363:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104367:	c7 04 24 79 77 10 f0 	movl   $0xf0107779,(%esp)
f010436e:	e8 b6 fb ff ff       	call   f0103f29 <cprintf>
	cprintf("  ecx  0x%08x\n", regs->reg_ecx);
f0104373:	8b 43 18             	mov    0x18(%ebx),%eax
f0104376:	89 44 24 04          	mov    %eax,0x4(%esp)
f010437a:	c7 04 24 88 77 10 f0 	movl   $0xf0107788,(%esp)
f0104381:	e8 a3 fb ff ff       	call   f0103f29 <cprintf>
	cprintf("  eax  0x%08x\n", regs->reg_eax);
f0104386:	8b 43 1c             	mov    0x1c(%ebx),%eax
f0104389:	89 44 24 04          	mov    %eax,0x4(%esp)
f010438d:	c7 04 24 97 77 10 f0 	movl   $0xf0107797,(%esp)
f0104394:	e8 90 fb ff ff       	call   f0103f29 <cprintf>
}
f0104399:	83 c4 14             	add    $0x14,%esp
f010439c:	5b                   	pop    %ebx
f010439d:	5d                   	pop    %ebp
f010439e:	c3                   	ret    

f010439f <print_trapframe>:
	lidt(&idt_pd);
}

void
print_trapframe(struct Trapframe *tf)
{
f010439f:	55                   	push   %ebp
f01043a0:	89 e5                	mov    %esp,%ebp
f01043a2:	56                   	push   %esi
f01043a3:	53                   	push   %ebx
f01043a4:	83 ec 10             	sub    $0x10,%esp
f01043a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
f01043aa:	e8 80 1a 00 00       	call   f0105e2f <cpunum>
f01043af:	89 44 24 08          	mov    %eax,0x8(%esp)
f01043b3:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01043b7:	c7 04 24 a6 77 10 f0 	movl   $0xf01077a6,(%esp)
f01043be:	e8 66 fb ff ff       	call   f0103f29 <cprintf>
	print_regs(&tf->tf_regs);
f01043c3:	89 1c 24             	mov    %ebx,(%esp)
f01043c6:	e8 2d ff ff ff       	call   f01042f8 <print_regs>
	cprintf("  es   0x----%04x\n", tf->tf_es);
f01043cb:	0f b7 43 20          	movzwl 0x20(%ebx),%eax
f01043cf:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043d3:	c7 04 24 c4 77 10 f0 	movl   $0xf01077c4,(%esp)
f01043da:	e8 4a fb ff ff       	call   f0103f29 <cprintf>
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
f01043df:	0f b7 43 24          	movzwl 0x24(%ebx),%eax
f01043e3:	89 44 24 04          	mov    %eax,0x4(%esp)
f01043e7:	c7 04 24 d7 77 10 f0 	movl   $0xf01077d7,(%esp)
f01043ee:	e8 36 fb ff ff       	call   f0103f29 <cprintf>
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f01043f3:	8b 43 28             	mov    0x28(%ebx),%eax
		"Alignment Check",
		"Machine-Check",
		"SIMD Floating-Point Exception"
	};

	if (trapno < sizeof(excnames)/sizeof(excnames[0]))
f01043f6:	83 f8 13             	cmp    $0x13,%eax
f01043f9:	77 09                	ja     f0104404 <print_trapframe+0x65>
		return excnames[trapno];
f01043fb:	8b 14 85 c0 7a 10 f0 	mov    -0xfef8540(,%eax,4),%edx
f0104402:	eb 1d                	jmp    f0104421 <print_trapframe+0x82>
	if (trapno == T_SYSCALL)
f0104404:	ba ea 77 10 f0       	mov    $0xf01077ea,%edx
f0104409:	83 f8 30             	cmp    $0x30,%eax
f010440c:	74 13                	je     f0104421 <print_trapframe+0x82>
		return "System call";
	if (trapno >= IRQ_OFFSET && trapno < IRQ_OFFSET + 16)
f010440e:	8d 50 e0             	lea    -0x20(%eax),%edx
f0104411:	83 fa 10             	cmp    $0x10,%edx
f0104414:	ba f6 77 10 f0       	mov    $0xf01077f6,%edx
f0104419:	b9 05 78 10 f0       	mov    $0xf0107805,%ecx
f010441e:	0f 42 d1             	cmovb  %ecx,%edx
{
	cprintf("TRAP frame at %p from CPU %d\n", tf, cpunum());
	print_regs(&tf->tf_regs);
	cprintf("  es   0x----%04x\n", tf->tf_es);
	cprintf("  ds   0x----%04x\n", tf->tf_ds);
	cprintf("  trap 0x%08x %s\n", tf->tf_trapno, trapname(tf->tf_trapno));
f0104421:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104425:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104429:	c7 04 24 18 78 10 f0 	movl   $0xf0107818,(%esp)
f0104430:	e8 f4 fa ff ff       	call   f0103f29 <cprintf>
	// If this trap was a page fault that just happened
	// (so %cr2 is meaningful), print the faulting linear address.
	if (tf == last_tf && tf->tf_trapno == T_PGFLT)
f0104435:	3b 1d c8 3a 22 f0    	cmp    0xf0223ac8,%ebx
f010443b:	75 19                	jne    f0104456 <print_trapframe+0xb7>
f010443d:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f0104441:	75 13                	jne    f0104456 <print_trapframe+0xb7>

static __inline uint32_t
rcr2(void)
{
	uint32_t val;
	__asm __volatile("movl %%cr2,%0" : "=r" (val));
f0104443:	0f 20 d0             	mov    %cr2,%eax
		cprintf("  cr2  0x%08x\n", rcr2());
f0104446:	89 44 24 04          	mov    %eax,0x4(%esp)
f010444a:	c7 04 24 2a 78 10 f0 	movl   $0xf010782a,(%esp)
f0104451:	e8 d3 fa ff ff       	call   f0103f29 <cprintf>
	cprintf("  err  0x%08x", tf->tf_err);
f0104456:	8b 43 2c             	mov    0x2c(%ebx),%eax
f0104459:	89 44 24 04          	mov    %eax,0x4(%esp)
f010445d:	c7 04 24 39 78 10 f0 	movl   $0xf0107839,(%esp)
f0104464:	e8 c0 fa ff ff       	call   f0103f29 <cprintf>
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
f0104469:	83 7b 28 0e          	cmpl   $0xe,0x28(%ebx)
f010446d:	75 4a                	jne    f01044b9 <print_trapframe+0x11a>
		cprintf(" [%s, %s, %s]\n",
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
f010446f:	8b 43 2c             	mov    0x2c(%ebx),%eax
	// For page faults, print decoded fault error code:
	// U/K=fault occurred in user/kernel mode
	// W/R=a write/read caused the fault
	// PR=a protection violation caused the fault (NP=page not present).
	if (tf->tf_trapno == T_PGFLT)
		cprintf(" [%s, %s, %s]\n",
f0104472:	a8 01                	test   $0x1,%al
f0104474:	ba 47 78 10 f0       	mov    $0xf0107847,%edx
f0104479:	b9 53 78 10 f0       	mov    $0xf0107853,%ecx
f010447e:	0f 44 ca             	cmove  %edx,%ecx
f0104481:	a8 02                	test   $0x2,%al
f0104483:	ba 5e 78 10 f0       	mov    $0xf010785e,%edx
f0104488:	be 63 78 10 f0       	mov    $0xf0107863,%esi
f010448d:	0f 45 d6             	cmovne %esi,%edx
f0104490:	a8 04                	test   $0x4,%al
f0104492:	b8 43 79 10 f0       	mov    $0xf0107943,%eax
f0104497:	be 69 78 10 f0       	mov    $0xf0107869,%esi
f010449c:	0f 45 c6             	cmovne %esi,%eax
f010449f:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
f01044a3:	89 54 24 08          	mov    %edx,0x8(%esp)
f01044a7:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044ab:	c7 04 24 6e 78 10 f0 	movl   $0xf010786e,(%esp)
f01044b2:	e8 72 fa ff ff       	call   f0103f29 <cprintf>
f01044b7:	eb 0c                	jmp    f01044c5 <print_trapframe+0x126>
			tf->tf_err & 4 ? "user" : "kernel",
			tf->tf_err & 2 ? "write" : "read",
			tf->tf_err & 1 ? "protection" : "not-present");
	else
		cprintf("\n");
f01044b9:	c7 04 24 18 77 10 f0 	movl   $0xf0107718,(%esp)
f01044c0:	e8 64 fa ff ff       	call   f0103f29 <cprintf>
	cprintf("  eip  0x%08x\n", tf->tf_eip);
f01044c5:	8b 43 30             	mov    0x30(%ebx),%eax
f01044c8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044cc:	c7 04 24 7d 78 10 f0 	movl   $0xf010787d,(%esp)
f01044d3:	e8 51 fa ff ff       	call   f0103f29 <cprintf>
	cprintf("  cs   0x----%04x\n", tf->tf_cs);
f01044d8:	0f b7 43 34          	movzwl 0x34(%ebx),%eax
f01044dc:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044e0:	c7 04 24 8c 78 10 f0 	movl   $0xf010788c,(%esp)
f01044e7:	e8 3d fa ff ff       	call   f0103f29 <cprintf>
	cprintf("  flag 0x%08x\n", tf->tf_eflags);
f01044ec:	8b 43 38             	mov    0x38(%ebx),%eax
f01044ef:	89 44 24 04          	mov    %eax,0x4(%esp)
f01044f3:	c7 04 24 9f 78 10 f0 	movl   $0xf010789f,(%esp)
f01044fa:	e8 2a fa ff ff       	call   f0103f29 <cprintf>
	if ((tf->tf_cs & 3) != 0) {
f01044ff:	f6 43 34 03          	testb  $0x3,0x34(%ebx)
f0104503:	74 27                	je     f010452c <print_trapframe+0x18d>
		cprintf("  esp  0x%08x\n", tf->tf_esp);
f0104505:	8b 43 3c             	mov    0x3c(%ebx),%eax
f0104508:	89 44 24 04          	mov    %eax,0x4(%esp)
f010450c:	c7 04 24 ae 78 10 f0 	movl   $0xf01078ae,(%esp)
f0104513:	e8 11 fa ff ff       	call   f0103f29 <cprintf>
		cprintf("  ss   0x----%04x\n", tf->tf_ss);
f0104518:	0f b7 43 40          	movzwl 0x40(%ebx),%eax
f010451c:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104520:	c7 04 24 bd 78 10 f0 	movl   $0xf01078bd,(%esp)
f0104527:	e8 fd f9 ff ff       	call   f0103f29 <cprintf>
	}
}
f010452c:	83 c4 10             	add    $0x10,%esp
f010452f:	5b                   	pop    %ebx
f0104530:	5e                   	pop    %esi
f0104531:	5d                   	pop    %ebp
f0104532:	c3                   	ret    

f0104533 <page_fault_handler>:
}


void
page_fault_handler(struct Trapframe *tf)
{
f0104533:	55                   	push   %ebp
f0104534:	89 e5                	mov    %esp,%ebp
f0104536:	83 ec 28             	sub    $0x28,%esp
f0104539:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f010453c:	89 75 f8             	mov    %esi,-0x8(%ebp)
f010453f:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104542:	8b 75 08             	mov    0x8(%ebp),%esi
f0104545:	0f 20 d3             	mov    %cr2,%ebx

	// Read processor's CR2 register to find the faulting address
	fault_va = rcr2();
	
	// Handle kernel-mode page faults.
	if((tf->tf_cs & 3)==0)
f0104548:	f6 46 34 03          	testb  $0x3,0x34(%esi)
f010454c:	75 1c                	jne    f010456a <page_fault_handler+0x37>
		panic("kernel-mode page faults");
f010454e:	c7 44 24 08 d0 78 10 	movl   $0xf01078d0,0x8(%esp)
f0104555:	f0 
f0104556:	c7 44 24 04 4a 01 00 	movl   $0x14a,0x4(%esp)
f010455d:	00 
f010455e:	c7 04 24 e8 78 10 f0 	movl   $0xf01078e8,(%esp)
f0104565:	e8 1b bb ff ff       	call   f0100085 <_panic>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f010456a:	8b 7e 30             	mov    0x30(%esi),%edi
		curenv->env_id, fault_va, tf->tf_eip);
f010456d:	e8 bd 18 00 00       	call   f0105e2f <cpunum>
	//   (the 'tf' variable points at 'curenv->env_tf').

	// LAB 4: Your code here.

	// Destroy the environment that caused the fault.
	cprintf("[%08x] user fault va %08x ip %08x\n",
f0104572:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0104576:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010457a:	bb 20 40 22 f0       	mov    $0xf0224020,%ebx
f010457f:	6b c0 74             	imul   $0x74,%eax,%eax
f0104582:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f0104586:	8b 40 48             	mov    0x48(%eax),%eax
f0104589:	89 44 24 04          	mov    %eax,0x4(%esp)
f010458d:	c7 04 24 90 7a 10 f0 	movl   $0xf0107a90,(%esp)
f0104594:	e8 90 f9 ff ff       	call   f0103f29 <cprintf>
		curenv->env_id, fault_va, tf->tf_eip);
	print_trapframe(tf);
f0104599:	89 34 24             	mov    %esi,(%esp)
f010459c:	e8 fe fd ff ff       	call   f010439f <print_trapframe>
	env_destroy(curenv);
f01045a1:	e8 89 18 00 00       	call   f0105e2f <cpunum>
f01045a6:	6b c0 74             	imul   $0x74,%eax,%eax
f01045a9:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01045ad:	89 04 24             	mov    %eax,(%esp)
f01045b0:	e8 25 f4 ff ff       	call   f01039da <env_destroy>
}
f01045b5:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01045b8:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01045bb:	8b 7d fc             	mov    -0x4(%ebp),%edi
f01045be:	89 ec                	mov    %ebp,%esp
f01045c0:	5d                   	pop    %ebp
f01045c1:	c3                   	ret    

f01045c2 <trap>:
	}
}

void
trap(struct Trapframe *tf)
{
f01045c2:	55                   	push   %ebp
f01045c3:	89 e5                	mov    %esp,%ebp
f01045c5:	57                   	push   %edi
f01045c6:	56                   	push   %esi
f01045c7:	53                   	push   %ebx
f01045c8:	83 ec 2c             	sub    $0x2c,%esp
f01045cb:	8b 75 08             	mov    0x8(%ebp),%esi
	// The environment may have set DF and some versions
	// of GCC rely on DF being clear
	asm volatile("cld" ::: "cc");
f01045ce:	fc                   	cld    

	// Halt the CPU if some other CPU has called panic()
	extern char *panicstr;
	if (panicstr)
f01045cf:	83 3d e0 3e 22 f0 00 	cmpl   $0x0,0xf0223ee0
f01045d6:	74 01                	je     f01045d9 <trap+0x17>
		asm volatile("hlt");
f01045d8:	f4                   	hlt    

	// Re-acqurie the big kernel lock if we were halted in
	// sched_yield()
	if (xchg(&thiscpu->cpu_status, CPU_STARTED) == CPU_HALTED)
f01045d9:	e8 51 18 00 00       	call   f0105e2f <cpunum>
f01045de:	6b d0 74             	imul   $0x74,%eax,%edx
f01045e1:	81 c2 24 40 22 f0    	add    $0xf0224024,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01045e7:	b8 01 00 00 00       	mov    $0x1,%eax
f01045ec:	f0 87 02             	lock xchg %eax,(%edx)
f01045ef:	83 f8 02             	cmp    $0x2,%eax
f01045f2:	75 0c                	jne    f0104600 <trap+0x3e>
extern struct spinlock kernel_lock;

static inline void
lock_kernel(void)
{
	spin_lock(&kernel_lock);
f01045f4:	c7 04 24 a0 03 12 f0 	movl   $0xf01203a0,(%esp)
f01045fb:	e8 05 1c 00 00       	call   f0106205 <spin_lock>

static __inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	__asm __volatile("pushfl; popl %0" : "=r" (eflags));
f0104600:	9c                   	pushf  
f0104601:	58                   	pop    %eax
		lock_kernel();
	// Check that interrupts are disabled.  If this assertion
	// fails, DO NOT be tempted to fix it by inserting a "cli" in
	// the interrupt path.
	assert(!(read_eflags() & FL_IF));
f0104602:	f6 c4 02             	test   $0x2,%ah
f0104605:	74 24                	je     f010462b <trap+0x69>
f0104607:	c7 44 24 0c f4 78 10 	movl   $0xf01078f4,0xc(%esp)
f010460e:	f0 
f010460f:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0104616:	f0 
f0104617:	c7 44 24 04 17 01 00 	movl   $0x117,0x4(%esp)
f010461e:	00 
f010461f:	c7 04 24 e8 78 10 f0 	movl   $0xf01078e8,(%esp)
f0104626:	e8 5a ba ff ff       	call   f0100085 <_panic>

	if ((tf->tf_cs & 3) == 3) {
f010462b:	0f b7 46 34          	movzwl 0x34(%esi),%eax
f010462f:	83 e0 03             	and    $0x3,%eax
f0104632:	83 f8 03             	cmp    $0x3,%eax
f0104635:	0f 85 a9 00 00 00    	jne    f01046e4 <trap+0x122>
f010463b:	c7 04 24 a0 03 12 f0 	movl   $0xf01203a0,(%esp)
f0104642:	e8 be 1b 00 00       	call   f0106205 <spin_lock>
		// Trapped from user mode.
		// Acquire the big kernel lock before doing any
		// serious kernel work.
		// LAB 4: Your code here.
		lock_kernel();
		assert(curenv);
f0104647:	e8 e3 17 00 00       	call   f0105e2f <cpunum>
f010464c:	6b c0 74             	imul   $0x74,%eax,%eax
f010464f:	83 b8 28 40 22 f0 00 	cmpl   $0x0,-0xfddbfd8(%eax)
f0104656:	75 24                	jne    f010467c <trap+0xba>
f0104658:	c7 44 24 0c 0d 79 10 	movl   $0xf010790d,0xc(%esp)
f010465f:	f0 
f0104660:	c7 44 24 08 d1 73 10 	movl   $0xf01073d1,0x8(%esp)
f0104667:	f0 
f0104668:	c7 44 24 04 1f 01 00 	movl   $0x11f,0x4(%esp)
f010466f:	00 
f0104670:	c7 04 24 e8 78 10 f0 	movl   $0xf01078e8,(%esp)
f0104677:	e8 09 ba ff ff       	call   f0100085 <_panic>
		// Garbage collect if current enviroment is a zombie
		if (curenv->env_status == ENV_DYING) {
f010467c:	e8 ae 17 00 00       	call   f0105e2f <cpunum>
f0104681:	6b c0 74             	imul   $0x74,%eax,%eax
f0104684:	8b 80 28 40 22 f0    	mov    -0xfddbfd8(%eax),%eax
f010468a:	83 78 54 01          	cmpl   $0x1,0x54(%eax)
f010468e:	75 2e                	jne    f01046be <trap+0xfc>
			env_free(curenv);
f0104690:	e8 9a 17 00 00       	call   f0105e2f <cpunum>
f0104695:	be 20 40 22 f0       	mov    $0xf0224020,%esi
f010469a:	6b c0 74             	imul   $0x74,%eax,%eax
f010469d:	8b 44 30 08          	mov    0x8(%eax,%esi,1),%eax
f01046a1:	89 04 24             	mov    %eax,(%esp)
f01046a4:	e8 28 f1 ff ff       	call   f01037d1 <env_free>
			curenv = NULL;
f01046a9:	e8 81 17 00 00       	call   f0105e2f <cpunum>
f01046ae:	6b c0 74             	imul   $0x74,%eax,%eax
f01046b1:	c7 44 30 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,1)
f01046b8:	00 
			sched_yield();
f01046b9:	e8 9a 02 00 00       	call   f0104958 <sched_yield>
		}

		// Copy trap frame (which is currently on the stack)
		// into 'curenv->env_tf', so that running the environment
		// will restart at the trap point.
		curenv->env_tf = *tf;
f01046be:	e8 6c 17 00 00       	call   f0105e2f <cpunum>
f01046c3:	bb 20 40 22 f0       	mov    $0xf0224020,%ebx
f01046c8:	6b c0 74             	imul   $0x74,%eax,%eax
f01046cb:	8b 44 18 08          	mov    0x8(%eax,%ebx,1),%eax
f01046cf:	b9 11 00 00 00       	mov    $0x11,%ecx
f01046d4:	89 c7                	mov    %eax,%edi
f01046d6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
		// The trapframe on the stack should be ignored from here on.
		tf = &curenv->env_tf;
f01046d8:	e8 52 17 00 00       	call   f0105e2f <cpunum>
f01046dd:	6b c0 74             	imul   $0x74,%eax,%eax
f01046e0:	8b 74 18 08          	mov    0x8(%eax,%ebx,1),%esi
	}

	// Record that tf is the last real trapframe so
	// print_trapframe can print some additional information.
	last_tf = tf;
f01046e4:	89 35 c8 3a 22 f0    	mov    %esi,0xf0223ac8


	// Handle spurious interrupts
	// The hardware sometimes raises these because of noise on the
	// IRQ line or other reasons. We don't care.
	if (tf->tf_trapno == IRQ_OFFSET + IRQ_SPURIOUS) {
f01046ea:	8b 46 28             	mov    0x28(%esi),%eax
f01046ed:	83 f8 27             	cmp    $0x27,%eax
f01046f0:	75 19                	jne    f010470b <trap+0x149>
		cprintf("Spurious interrupt on irq 7\n");
f01046f2:	c7 04 24 14 79 10 f0 	movl   $0xf0107914,(%esp)
f01046f9:	e8 2b f8 ff ff       	call   f0103f29 <cprintf>
		print_trapframe(tf);
f01046fe:	89 34 24             	mov    %esi,(%esp)
f0104701:	e8 99 fc ff ff       	call   f010439f <print_trapframe>
f0104706:	e9 9a 00 00 00       	jmp    f01047a5 <trap+0x1e3>
	// Handle clock interrupts. Don't forget to acknowledge the
	// interrupt using lapic_eoi() before calling the scheduler!
	// LAB 4: Your code here.

	//cprintf("NUMBER%d\n",tf->tf_trapno);
	if (tf->tf_trapno == T_PGFLT) {
f010470b:	83 f8 0e             	cmp    $0xe,%eax
f010470e:	66 90                	xchg   %ax,%ax
f0104710:	75 0b                	jne    f010471d <trap+0x15b>
		page_fault_handler(tf);
f0104712:	89 34 24             	mov    %esi,(%esp)
f0104715:	8d 76 00             	lea    0x0(%esi),%esi
f0104718:	e8 16 fe ff ff       	call   f0104533 <page_fault_handler>
	}
	if (tf->tf_trapno == T_BRKPT) {
f010471d:	83 7e 28 03          	cmpl   $0x3,0x28(%esi)
f0104721:	75 08                	jne    f010472b <trap+0x169>
		monitor(tf);
f0104723:	89 34 24             	mov    %esi,(%esp)
f0104726:	e8 f6 c1 ff ff       	call   f0100921 <monitor>
	}
	if(tf->tf_trapno==T_SYSCALL) {
f010472b:	83 7e 28 30          	cmpl   $0x30,0x28(%esi)
f010472f:	90                   	nop
f0104730:	75 32                	jne    f0104764 <trap+0x1a2>
		(tf->tf_regs).reg_eax=syscall((tf->tf_regs).reg_eax,(tf->tf_regs).reg_edx,(tf->tf_regs).reg_ecx,(tf->tf_regs).reg_ebx,(tf->tf_regs).reg_edi,(tf->tf_regs).reg_esi);
f0104732:	8b 46 04             	mov    0x4(%esi),%eax
f0104735:	89 44 24 14          	mov    %eax,0x14(%esp)
f0104739:	8b 06                	mov    (%esi),%eax
f010473b:	89 44 24 10          	mov    %eax,0x10(%esp)
f010473f:	8b 46 10             	mov    0x10(%esi),%eax
f0104742:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0104746:	8b 46 18             	mov    0x18(%esi),%eax
f0104749:	89 44 24 08          	mov    %eax,0x8(%esp)
f010474d:	8b 46 14             	mov    0x14(%esi),%eax
f0104750:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104754:	8b 46 1c             	mov    0x1c(%esi),%eax
f0104757:	89 04 24             	mov    %eax,(%esp)
f010475a:	e8 11 02 00 00       	call   f0104970 <syscall>
f010475f:	89 46 1c             	mov    %eax,0x1c(%esi)
f0104762:	eb 41                	jmp    f01047a5 <trap+0x1e3>
			panic ("trap_dispatch: The System Call number is invalid");
		return ;
	}
	
	// Unexpected trap: The user process or the kernel has a bug.
	print_trapframe(tf);
f0104764:	89 34 24             	mov    %esi,(%esp)
f0104767:	e8 33 fc ff ff       	call   f010439f <print_trapframe>
	if (tf->tf_cs == GD_KT)
f010476c:	66 83 7e 34 08       	cmpw   $0x8,0x34(%esi)
f0104771:	75 1c                	jne    f010478f <trap+0x1cd>
		panic("unhandled trap in kernel");
f0104773:	c7 44 24 08 31 79 10 	movl   $0xf0107931,0x8(%esp)
f010477a:	f0 
f010477b:	c7 44 24 04 fd 00 00 	movl   $0xfd,0x4(%esp)
f0104782:	00 
f0104783:	c7 04 24 e8 78 10 f0 	movl   $0xf01078e8,(%esp)
f010478a:	e8 f6 b8 ff ff       	call   f0100085 <_panic>
	else {
		env_destroy(curenv);
f010478f:	e8 9b 16 00 00       	call   f0105e2f <cpunum>
f0104794:	6b c0 74             	imul   $0x74,%eax,%eax
f0104797:	8b 80 28 40 22 f0    	mov    -0xfddbfd8(%eax),%eax
f010479d:	89 04 24             	mov    %eax,(%esp)
f01047a0:	e8 35 f2 ff ff       	call   f01039da <env_destroy>
	trap_dispatch(tf);

	// If we made it to this point, then no other environment was
	// scheduled, so we should return to the current environment
	// if doing so makes sense.
	if (curenv && curenv->env_status == ENV_RUNNING)
f01047a5:	e8 85 16 00 00       	call   f0105e2f <cpunum>
f01047aa:	6b c0 74             	imul   $0x74,%eax,%eax
f01047ad:	83 b8 28 40 22 f0 00 	cmpl   $0x0,-0xfddbfd8(%eax)
f01047b4:	74 2a                	je     f01047e0 <trap+0x21e>
f01047b6:	e8 74 16 00 00       	call   f0105e2f <cpunum>
f01047bb:	6b c0 74             	imul   $0x74,%eax,%eax
f01047be:	8b 80 28 40 22 f0    	mov    -0xfddbfd8(%eax),%eax
f01047c4:	83 78 54 03          	cmpl   $0x3,0x54(%eax)
f01047c8:	75 16                	jne    f01047e0 <trap+0x21e>
		env_run(curenv);
f01047ca:	e8 60 16 00 00       	call   f0105e2f <cpunum>
f01047cf:	6b c0 74             	imul   $0x74,%eax,%eax
f01047d2:	8b 80 28 40 22 f0    	mov    -0xfddbfd8(%eax),%eax
f01047d8:	89 04 24             	mov    %eax,(%esp)
f01047db:	e8 14 ef ff ff       	call   f01036f4 <env_run>
	else
		sched_yield();
f01047e0:	e8 73 01 00 00       	call   f0104958 <sched_yield>
f01047e5:	90                   	nop

f01047e6 <routine_divide>:

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
 
	TRAPHANDLER_NOEC(routine_divide, T_DIVIDE)
f01047e6:	6a 00                	push   $0x0
f01047e8:	6a 00                	push   $0x0
f01047ea:	eb 5e                	jmp    f010484a <_alltraps>

f01047ec <routine_debug>:
	TRAPHANDLER_NOEC(routine_debug, T_DEBUG)
f01047ec:	6a 00                	push   $0x0
f01047ee:	6a 01                	push   $0x1
f01047f0:	eb 58                	jmp    f010484a <_alltraps>

f01047f2 <routine_nmi>:
	TRAPHANDLER_NOEC(routine_nmi, T_NMI)
f01047f2:	6a 00                	push   $0x0
f01047f4:	6a 02                	push   $0x2
f01047f6:	eb 52                	jmp    f010484a <_alltraps>

f01047f8 <routine_brkpt>:
	TRAPHANDLER_NOEC(routine_brkpt, T_BRKPT)
f01047f8:	6a 00                	push   $0x0
f01047fa:	6a 03                	push   $0x3
f01047fc:	eb 4c                	jmp    f010484a <_alltraps>

f01047fe <routine_oflow>:
	TRAPHANDLER_NOEC(routine_oflow, T_OFLOW)
f01047fe:	6a 00                	push   $0x0
f0104800:	6a 04                	push   $0x4
f0104802:	eb 46                	jmp    f010484a <_alltraps>

f0104804 <routine_bound>:
	TRAPHANDLER_NOEC(routine_bound, T_BOUND)
f0104804:	6a 00                	push   $0x0
f0104806:	6a 05                	push   $0x5
f0104808:	eb 40                	jmp    f010484a <_alltraps>

f010480a <routine_illop>:
	TRAPHANDLER_NOEC(routine_illop, T_ILLOP)
f010480a:	6a 00                	push   $0x0
f010480c:	6a 06                	push   $0x6
f010480e:	eb 3a                	jmp    f010484a <_alltraps>

f0104810 <routine_device>:
	TRAPHANDLER_NOEC(routine_device, T_DEVICE)
f0104810:	6a 00                	push   $0x0
f0104812:	6a 07                	push   $0x7
f0104814:	eb 34                	jmp    f010484a <_alltraps>

f0104816 <routine_dblflt>:
	
	TRAPHANDLER(routine_dblflt, T_DBLFLT)
f0104816:	6a 08                	push   $0x8
f0104818:	eb 30                	jmp    f010484a <_alltraps>

f010481a <routine_tss>:
	TRAPHANDLER(routine_tss, T_TSS)
f010481a:	6a 0a                	push   $0xa
f010481c:	eb 2c                	jmp    f010484a <_alltraps>

f010481e <routine_segnp>:
	TRAPHANDLER(routine_segnp, T_SEGNP)
f010481e:	6a 0b                	push   $0xb
f0104820:	eb 28                	jmp    f010484a <_alltraps>

f0104822 <routine_stack>:
	TRAPHANDLER(routine_stack, T_STACK)
f0104822:	6a 0c                	push   $0xc
f0104824:	eb 24                	jmp    f010484a <_alltraps>

f0104826 <routine_gpflt>:
	TRAPHANDLER(routine_gpflt, T_GPFLT)
f0104826:	6a 0d                	push   $0xd
f0104828:	eb 20                	jmp    f010484a <_alltraps>

f010482a <routine_pgflt>:
	TRAPHANDLER(routine_pgflt, T_PGFLT)
f010482a:	6a 0e                	push   $0xe
f010482c:	eb 1c                	jmp    f010484a <_alltraps>

f010482e <routine_fperr>:
	TRAPHANDLER_NOEC(routine_fperr, T_FPERR)
f010482e:	6a 00                	push   $0x0
f0104830:	6a 10                	push   $0x10
f0104832:	eb 16                	jmp    f010484a <_alltraps>

f0104834 <routine_align>:
	TRAPHANDLER(routine_align, T_ALIGN)
f0104834:	6a 11                	push   $0x11
f0104836:	eb 12                	jmp    f010484a <_alltraps>

f0104838 <routine_mchk>:
	TRAPHANDLER_NOEC(routine_mchk, T_MCHK)
f0104838:	6a 00                	push   $0x0
f010483a:	6a 12                	push   $0x12
f010483c:	eb 0c                	jmp    f010484a <_alltraps>

f010483e <routine_simderr>:
	TRAPHANDLER_NOEC(routine_simderr, T_SIMDERR)
f010483e:	6a 00                	push   $0x0
f0104840:	6a 13                	push   $0x13
f0104842:	eb 06                	jmp    f010484a <_alltraps>

f0104844 <routine_syscall>:

	TRAPHANDLER_NOEC(routine_syscall, T_SYSCALL)
f0104844:	6a 00                	push   $0x0
f0104846:	6a 30                	push   $0x30
f0104848:	eb 00                	jmp    f010484a <_alltraps>

f010484a <_alltraps>:
 * Lab 3: Your code here for _alltraps
 */
 
_alltraps:
	
	pushw $0x0
f010484a:	66 6a 00             	pushw  $0x0
	pushw %ds
f010484d:	66 1e                	pushw  %ds
	pushw $0x0
f010484f:	66 6a 00             	pushw  $0x0
	pushw %es
f0104852:	66 06                	pushw  %es
	pushal			# according to the tf:8,es,0,ds,0,trapno
f0104854:	60                   	pusha  

	movl $GD_KD, %eax
f0104855:	b8 10 00 00 00       	mov    $0x10,%eax
	movw %ax, %ds
f010485a:	8e d8                	mov    %eax,%ds
	movw %ax, %es
f010485c:	8e c0                	mov    %eax,%es

	pushl %esp
f010485e:	54                   	push   %esp
	call trap
f010485f:	e8 5e fd ff ff       	call   f01045c2 <trap>
f0104864:	66 90                	xchg   %ax,%ax
f0104866:	66 90                	xchg   %ax,%ax
f0104868:	66 90                	xchg   %ax,%ax
f010486a:	66 90                	xchg   %ax,%ax
f010486c:	66 90                	xchg   %ax,%ax
f010486e:	66 90                	xchg   %ax,%ax

f0104870 <sched_halt>:
// Halt this CPU when there is nothing to do. Wait until the
// timer interrupt wakes it up. This function never returns.
//
void
sched_halt(void)
{
f0104870:	55                   	push   %ebp
f0104871:	89 e5                	mov    %esp,%ebp
f0104873:	83 ec 18             	sub    $0x18,%esp
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
		if ((envs[i].env_status == ENV_RUNNABLE ||
f0104876:	8b 15 38 32 22 f0    	mov    0xf0223238,%edx
f010487c:	8b 42 54             	mov    0x54(%edx),%eax
f010487f:	83 e8 02             	sub    $0x2,%eax
f0104882:	83 f8 01             	cmp    $0x1,%eax
f0104885:	76 45                	jbe    f01048cc <sched_halt+0x5c>
f0104887:	b8 01 00 00 00       	mov    $0x1,%eax
f010488c:	8b 8a d0 00 00 00    	mov    0xd0(%edx),%ecx
f0104892:	83 e9 02             	sub    $0x2,%ecx
f0104895:	83 f9 01             	cmp    $0x1,%ecx
f0104898:	76 0f                	jbe    f01048a9 <sched_halt+0x39>
{
	int i;

	// For debugging and testing purposes, if there are no runnable
	// environments in the system, then drop into the kernel monitor.
	for (i = 0; i < NENV; i++) {
f010489a:	83 c0 01             	add    $0x1,%eax
f010489d:	83 c2 7c             	add    $0x7c,%edx
f01048a0:	3d 00 04 00 00       	cmp    $0x400,%eax
f01048a5:	75 e5                	jne    f010488c <sched_halt+0x1c>
f01048a7:	eb 09                	jmp    f01048b2 <sched_halt+0x42>
		if ((envs[i].env_status == ENV_RUNNABLE ||
		     envs[i].env_status == ENV_RUNNING))
			break;
	}
	if (i == NENV) {
f01048a9:	3d 00 04 00 00       	cmp    $0x400,%eax
f01048ae:	66 90                	xchg   %ax,%ax
f01048b0:	75 1a                	jne    f01048cc <sched_halt+0x5c>
		cprintf("No runnable environments in the system!\n");
f01048b2:	c7 04 24 10 7b 10 f0 	movl   $0xf0107b10,(%esp)
f01048b9:	e8 6b f6 ff ff       	call   f0103f29 <cprintf>
		while (1)
			monitor(NULL);
f01048be:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01048c5:	e8 57 c0 ff ff       	call   f0100921 <monitor>
f01048ca:	eb f2                	jmp    f01048be <sched_halt+0x4e>
	}

	// Mark that no environment is running on this CPU
	curenv = NULL;
f01048cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01048d0:	e8 5a 15 00 00       	call   f0105e2f <cpunum>
f01048d5:	6b c0 74             	imul   $0x74,%eax,%eax
f01048d8:	c7 80 28 40 22 f0 00 	movl   $0x0,-0xfddbfd8(%eax)
f01048df:	00 00 00 
	lcr3(PADDR(kern_pgdir));
f01048e2:	a1 ec 3e 22 f0       	mov    0xf0223eec,%eax
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f01048e7:	3d ff ff ff ef       	cmp    $0xefffffff,%eax
f01048ec:	77 20                	ja     f010490e <sched_halt+0x9e>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f01048ee:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01048f2:	c7 44 24 08 dc 65 10 	movl   $0xf01065dc,0x8(%esp)
f01048f9:	f0 
f01048fa:	c7 44 24 04 3c 00 00 	movl   $0x3c,0x4(%esp)
f0104901:	00 
f0104902:	c7 04 24 39 7b 10 f0 	movl   $0xf0107b39,(%esp)
f0104909:	e8 77 b7 ff ff       	call   f0100085 <_panic>
}

static __inline void
lcr3(uint32_t val)
{
	__asm __volatile("movl %0,%%cr3" : : "r" (val));
f010490e:	8d 80 00 00 00 10    	lea    0x10000000(%eax),%eax
f0104914:	0f 22 d8             	mov    %eax,%cr3

	// Mark that this CPU is in the HALT state, so that when
	// timer interupts come in, we know we should re-acquire the
	// big kernel lock
	xchg(&thiscpu->cpu_status, CPU_HALTED);
f0104917:	e8 13 15 00 00       	call   f0105e2f <cpunum>
f010491c:	6b d0 74             	imul   $0x74,%eax,%edx
f010491f:	81 c2 24 40 22 f0    	add    $0xf0224024,%edx
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f0104925:	b8 02 00 00 00       	mov    $0x2,%eax
f010492a:	f0 87 02             	lock xchg %eax,(%edx)
}

static inline void
unlock_kernel(void)
{
	spin_unlock(&kernel_lock);
f010492d:	c7 04 24 a0 03 12 f0 	movl   $0xf01203a0,(%esp)
f0104934:	e8 b3 17 00 00       	call   f01060ec <spin_unlock>

	// Normally we wouldn't need to do this, but QEMU only runs
	// one CPU at a time and has a long time-slice.  Without the
	// pause, this CPU is likely to reacquire the lock before
	// another CPU has even been given a chance to acquire it.
	asm volatile("pause");
f0104939:	f3 90                	pause  
		"movl %0, %%esp\n"
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
f010493b:	e8 ef 14 00 00       	call   f0105e2f <cpunum>

	// Release the big kernel lock as if we were "leaving" the kernel
	unlock_kernel();

	// Reset stack pointer, enable interrupts and then halt.
	asm volatile (
f0104940:	6b c0 74             	imul   $0x74,%eax,%eax
f0104943:	8b 80 30 40 22 f0    	mov    -0xfddbfd0(%eax),%eax
f0104949:	bd 00 00 00 00       	mov    $0x0,%ebp
f010494e:	89 c4                	mov    %eax,%esp
f0104950:	6a 00                	push   $0x0
f0104952:	6a 00                	push   $0x0
f0104954:	fb                   	sti    
f0104955:	f4                   	hlt    
		"pushl $0\n"
		"pushl $0\n"
		"sti\n"
		"hlt\n"
	: : "a" (thiscpu->cpu_ts.ts_esp0));
}
f0104956:	c9                   	leave  
f0104957:	c3                   	ret    

f0104958 <sched_yield>:
void sched_halt(void);

// Choose a user environment to run and run it.
void
sched_yield(void)
{
f0104958:	55                   	push   %ebp
f0104959:	89 e5                	mov    %esp,%ebp
f010495b:	83 ec 08             	sub    $0x8,%esp
	// below to halt the cpu.

	// LAB 4: Your code here.

	// sched_halt never returns
	sched_halt();
f010495e:	e8 0d ff ff ff       	call   f0104870 <sched_halt>
}
f0104963:	c9                   	leave  
f0104964:	c3                   	ret    
f0104965:	66 90                	xchg   %ax,%ax
f0104967:	66 90                	xchg   %ax,%ax
f0104969:	66 90                	xchg   %ax,%ax
f010496b:	66 90                	xchg   %ax,%ax
f010496d:	66 90                	xchg   %ax,%ax
f010496f:	90                   	nop

f0104970 <syscall>:
}

// Dispatches to the correct kernel function, passing the arguments.
int32_t
syscall(uint32_t syscallno, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
f0104970:	55                   	push   %ebp
f0104971:	89 e5                	mov    %esp,%ebp
f0104973:	83 ec 28             	sub    $0x28,%esp
f0104976:	89 5d f8             	mov    %ebx,-0x8(%ebp)
f0104979:	89 75 fc             	mov    %esi,-0x4(%ebp)
f010497c:	8b 55 08             	mov    0x8(%ebp),%edx
f010497f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0104982:	8b 75 10             	mov    0x10(%ebp),%esi
		  // "D" (a4),
		  // "S" (a5)
		// : "cc", "memory");
	// return ret
	int32_t ret=0;
	switch (syscallno) {
f0104985:	83 fa 01             	cmp    $0x1,%edx
f0104988:	74 62                	je     f01049ec <syscall+0x7c>
f010498a:	83 fa 01             	cmp    $0x1,%edx
f010498d:	72 15                	jb     f01049a4 <syscall+0x34>
f010498f:	83 fa 02             	cmp    $0x2,%edx
f0104992:	74 62                	je     f01049f6 <syscall+0x86>
f0104994:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0104999:	83 fa 03             	cmp    $0x3,%edx
f010499c:	0f 85 f5 00 00 00    	jne    f0104a97 <syscall+0x127>
f01049a2:	eb 6a                	jmp    f0104a0e <syscall+0x9e>
{
	// Check that the user has permission to read memory [s, s+len).
	// Destroy the environment if not.

	// LAB 3: Your code here.
	user_mem_assert (curenv, s, len, PTE_U);
f01049a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01049a8:	e8 82 14 00 00       	call   f0105e2f <cpunum>
f01049ad:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f01049b4:	00 
f01049b5:	89 74 24 08          	mov    %esi,0x8(%esp)
f01049b9:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01049bd:	6b c0 74             	imul   $0x74,%eax,%eax
f01049c0:	8b 80 28 40 22 f0    	mov    -0xfddbfd8(%eax),%eax
f01049c6:	89 04 24             	mov    %eax,(%esp)
f01049c9:	e8 97 c9 ff ff       	call   f0101365 <user_mem_assert>

	// Print the string supplied by the user.
	cprintf("%.*s", len, s);
f01049ce:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f01049d2:	89 74 24 04          	mov    %esi,0x4(%esp)
f01049d6:	c7 04 24 46 7b 10 f0 	movl   $0xf0107b46,(%esp)
f01049dd:	e8 47 f5 ff ff       	call   f0103f29 <cprintf>
f01049e2:	b8 00 00 00 00       	mov    $0x0,%eax
f01049e7:	e9 ab 00 00 00       	jmp    f0104a97 <syscall+0x127>
// Read a character from the system console without blocking.
// Returns the character, or 0 if there is no input waiting.
static int
sys_cgetc(void)
{
	return cons_getc();
f01049ec:	e8 7b b9 ff ff       	call   f010036c <cons_getc>
	int32_t ret=0;
	switch (syscallno) {
		case SYS_cputs:
			sys_cputs ((const char*) a1, (size_t)a2); break;
		case SYS_cgetc:
			ret = sys_cgetc (); break;
f01049f1:	e9 a1 00 00 00       	jmp    f0104a97 <syscall+0x127>

// Returns the current environment's envid.
static envid_t
sys_getenvid(void)
{
	return curenv->env_id;
f01049f6:	66 90                	xchg   %ax,%ax
f01049f8:	e8 32 14 00 00       	call   f0105e2f <cpunum>
f01049fd:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a00:	8b 80 28 40 22 f0    	mov    -0xfddbfd8(%eax),%eax
f0104a06:	8b 40 48             	mov    0x48(%eax),%eax
		case SYS_cputs:
			sys_cputs ((const char*) a1, (size_t)a2); break;
		case SYS_cgetc:
			ret = sys_cgetc (); break;
		case SYS_getenvid:
			ret = sys_getenvid (); break;
f0104a09:	e9 89 00 00 00       	jmp    f0104a97 <syscall+0x127>
sys_env_destroy(envid_t envid)
{
	int r;
	struct Env *e;

	if ((r = envid2env(envid, &e, 1)) < 0)
f0104a0e:	c7 44 24 08 01 00 00 	movl   $0x1,0x8(%esp)
f0104a15:	00 
f0104a16:	8d 45 f4             	lea    -0xc(%ebp),%eax
f0104a19:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a1d:	89 1c 24             	mov    %ebx,(%esp)
f0104a20:	e8 e4 eb ff ff       	call   f0103609 <envid2env>
f0104a25:	85 c0                	test   %eax,%eax
f0104a27:	78 6e                	js     f0104a97 <syscall+0x127>
		return r;
	if (e == curenv)
f0104a29:	e8 01 14 00 00       	call   f0105e2f <cpunum>
f0104a2e:	8b 55 f4             	mov    -0xc(%ebp),%edx
f0104a31:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a34:	39 90 28 40 22 f0    	cmp    %edx,-0xfddbfd8(%eax)
f0104a3a:	75 23                	jne    f0104a5f <syscall+0xef>
		cprintf("[%08x] exiting gracefully\n", curenv->env_id);
f0104a3c:	e8 ee 13 00 00       	call   f0105e2f <cpunum>
f0104a41:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a44:	8b 80 28 40 22 f0    	mov    -0xfddbfd8(%eax),%eax
f0104a4a:	8b 40 48             	mov    0x48(%eax),%eax
f0104a4d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a51:	c7 04 24 4b 7b 10 f0 	movl   $0xf0107b4b,(%esp)
f0104a58:	e8 cc f4 ff ff       	call   f0103f29 <cprintf>
f0104a5d:	eb 28                	jmp    f0104a87 <syscall+0x117>
	else
		cprintf("[%08x] destroying %08x\n", curenv->env_id, e->env_id);
f0104a5f:	8b 5a 48             	mov    0x48(%edx),%ebx
f0104a62:	e8 c8 13 00 00       	call   f0105e2f <cpunum>
f0104a67:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104a6b:	6b c0 74             	imul   $0x74,%eax,%eax
f0104a6e:	8b 80 28 40 22 f0    	mov    -0xfddbfd8(%eax),%eax
f0104a74:	8b 40 48             	mov    0x48(%eax),%eax
f0104a77:	89 44 24 04          	mov    %eax,0x4(%esp)
f0104a7b:	c7 04 24 66 7b 10 f0 	movl   $0xf0107b66,(%esp)
f0104a82:	e8 a2 f4 ff ff       	call   f0103f29 <cprintf>
	env_destroy(e);
f0104a87:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0104a8a:	89 04 24             	mov    %eax,(%esp)
f0104a8d:	e8 48 ef ff ff       	call   f01039da <env_destroy>
f0104a92:	b8 00 00 00 00       	mov    $0x0,%eax
		default:
			ret = -E_INVAL;
	}
	return ret;
	panic("syscall not implemented");
}
f0104a97:	8b 5d f8             	mov    -0x8(%ebp),%ebx
f0104a9a:	8b 75 fc             	mov    -0x4(%ebp),%esi
f0104a9d:	89 ec                	mov    %ebp,%esp
f0104a9f:	5d                   	pop    %ebp
f0104aa0:	c3                   	ret    
f0104aa1:	66 90                	xchg   %ax,%ax
f0104aa3:	66 90                	xchg   %ax,%ax
f0104aa5:	66 90                	xchg   %ax,%ax
f0104aa7:	66 90                	xchg   %ax,%ax
f0104aa9:	66 90                	xchg   %ax,%ax
f0104aab:	66 90                	xchg   %ax,%ax
f0104aad:	66 90                	xchg   %ax,%ax
f0104aaf:	90                   	nop

f0104ab0 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0104ab0:	55                   	push   %ebp
f0104ab1:	89 e5                	mov    %esp,%ebp
f0104ab3:	57                   	push   %edi
f0104ab4:	56                   	push   %esi
f0104ab5:	53                   	push   %ebx
f0104ab6:	83 ec 14             	sub    $0x14,%esp
f0104ab9:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0104abc:	89 55 e8             	mov    %edx,-0x18(%ebp)
f0104abf:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0104ac2:	8b 75 08             	mov    0x8(%ebp),%esi
	int l = *region_left, r = *region_right, any_matches = 0;
f0104ac5:	8b 1a                	mov    (%edx),%ebx
f0104ac7:	8b 01                	mov    (%ecx),%eax
f0104ac9:	89 45 ec             	mov    %eax,-0x14(%ebp)

	while (l <= r) {
f0104acc:	39 c3                	cmp    %eax,%ebx
f0104ace:	0f 8f 9c 00 00 00    	jg     f0104b70 <stab_binsearch+0xc0>
f0104ad4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		int true_m = (l + r) / 2, m = true_m;
f0104adb:	8b 45 ec             	mov    -0x14(%ebp),%eax
f0104ade:	01 d8                	add    %ebx,%eax
f0104ae0:	89 c7                	mov    %eax,%edi
f0104ae2:	c1 ef 1f             	shr    $0x1f,%edi
f0104ae5:	01 c7                	add    %eax,%edi
f0104ae7:	d1 ff                	sar    %edi

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104ae9:	39 df                	cmp    %ebx,%edi
f0104aeb:	7c 33                	jl     f0104b20 <stab_binsearch+0x70>
f0104aed:	8d 04 7f             	lea    (%edi,%edi,2),%eax
f0104af0:	8b 55 f0             	mov    -0x10(%ebp),%edx
f0104af3:	0f b6 44 82 04       	movzbl 0x4(%edx,%eax,4),%eax
f0104af8:	39 f0                	cmp    %esi,%eax
f0104afa:	0f 84 bc 00 00 00    	je     f0104bbc <stab_binsearch+0x10c>
f0104b00:	8d 44 7f fd          	lea    -0x3(%edi,%edi,2),%eax
f0104b04:	8d 54 82 04          	lea    0x4(%edx,%eax,4),%edx
f0104b08:	89 f8                	mov    %edi,%eax
			m--;
f0104b0a:	83 e8 01             	sub    $0x1,%eax

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0104b0d:	39 d8                	cmp    %ebx,%eax
f0104b0f:	7c 0f                	jl     f0104b20 <stab_binsearch+0x70>
f0104b11:	0f b6 0a             	movzbl (%edx),%ecx
f0104b14:	83 ea 0c             	sub    $0xc,%edx
f0104b17:	39 f1                	cmp    %esi,%ecx
f0104b19:	75 ef                	jne    f0104b0a <stab_binsearch+0x5a>
f0104b1b:	e9 9e 00 00 00       	jmp    f0104bbe <stab_binsearch+0x10e>
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0104b20:	8d 5f 01             	lea    0x1(%edi),%ebx
			continue;
f0104b23:	eb 3c                	jmp    f0104b61 <stab_binsearch+0xb1>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0104b25:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104b28:	89 01                	mov    %eax,(%ecx)
			l = true_m + 1;
f0104b2a:	8d 5f 01             	lea    0x1(%edi),%ebx
f0104b2d:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0104b34:	eb 2b                	jmp    f0104b61 <stab_binsearch+0xb1>
		} else if (stabs[m].n_value > addr) {
f0104b36:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104b39:	76 14                	jbe    f0104b4f <stab_binsearch+0x9f>
			*region_right = m - 1;
f0104b3b:	83 e8 01             	sub    $0x1,%eax
f0104b3e:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0104b41:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104b44:	89 02                	mov    %eax,(%edx)
f0104b46:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
f0104b4d:	eb 12                	jmp    f0104b61 <stab_binsearch+0xb1>
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0104b4f:	8b 4d e8             	mov    -0x18(%ebp),%ecx
f0104b52:	89 01                	mov    %eax,(%ecx)
			l = m;
			addr++;
f0104b54:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
f0104b58:	89 c3                	mov    %eax,%ebx
f0104b5a:	c7 45 e4 01 00 00 00 	movl   $0x1,-0x1c(%ebp)
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0104b61:	39 5d ec             	cmp    %ebx,-0x14(%ebp)
f0104b64:	0f 8d 71 ff ff ff    	jge    f0104adb <stab_binsearch+0x2b>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0104b6a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0104b6e:	75 0f                	jne    f0104b7f <stab_binsearch+0xcf>
		*region_right = *region_left - 1;
f0104b70:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104b73:	8b 03                	mov    (%ebx),%eax
f0104b75:	83 e8 01             	sub    $0x1,%eax
f0104b78:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104b7b:	89 02                	mov    %eax,(%edx)
f0104b7d:	eb 57                	jmp    f0104bd6 <stab_binsearch+0x126>
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b7f:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104b82:	8b 01                	mov    (%ecx),%eax
		     l > *region_left && stabs[l].n_type != type;
f0104b84:	8b 5d e8             	mov    -0x18(%ebp),%ebx
f0104b87:	8b 0b                	mov    (%ebx),%ecx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104b89:	39 c1                	cmp    %eax,%ecx
f0104b8b:	7d 28                	jge    f0104bb5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0104b8d:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104b90:	8b 5d f0             	mov    -0x10(%ebp),%ebx
f0104b93:	0f b6 54 93 04       	movzbl 0x4(%ebx,%edx,4),%edx
f0104b98:	39 f2                	cmp    %esi,%edx
f0104b9a:	74 19                	je     f0104bb5 <stab_binsearch+0x105>
f0104b9c:	8d 54 40 fd          	lea    -0x3(%eax,%eax,2),%edx
f0104ba0:	8d 54 93 04          	lea    0x4(%ebx,%edx,4),%edx
		     l--)
f0104ba4:	83 e8 01             	sub    $0x1,%eax

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104ba7:	39 c1                	cmp    %eax,%ecx
f0104ba9:	7d 0a                	jge    f0104bb5 <stab_binsearch+0x105>
		     l > *region_left && stabs[l].n_type != type;
f0104bab:	0f b6 1a             	movzbl (%edx),%ebx
f0104bae:	83 ea 0c             	sub    $0xc,%edx

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0104bb1:	39 f3                	cmp    %esi,%ebx
f0104bb3:	75 ef                	jne    f0104ba4 <stab_binsearch+0xf4>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
f0104bb5:	8b 55 e8             	mov    -0x18(%ebp),%edx
f0104bb8:	89 02                	mov    %eax,(%edx)
f0104bba:	eb 1a                	jmp    f0104bd6 <stab_binsearch+0x126>
	}
}
f0104bbc:	89 f8                	mov    %edi,%eax
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0104bbe:	8d 14 40             	lea    (%eax,%eax,2),%edx
f0104bc1:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0104bc4:	8b 54 91 08          	mov    0x8(%ecx,%edx,4),%edx
f0104bc8:	3b 55 0c             	cmp    0xc(%ebp),%edx
f0104bcb:	0f 82 54 ff ff ff    	jb     f0104b25 <stab_binsearch+0x75>
f0104bd1:	e9 60 ff ff ff       	jmp    f0104b36 <stab_binsearch+0x86>
		     l > *region_left && stabs[l].n_type != type;
		     l--)
			/* do nothing */;
		*region_left = l;
	}
}
f0104bd6:	83 c4 14             	add    $0x14,%esp
f0104bd9:	5b                   	pop    %ebx
f0104bda:	5e                   	pop    %esi
f0104bdb:	5f                   	pop    %edi
f0104bdc:	5d                   	pop    %ebp
f0104bdd:	c3                   	ret    

f0104bde <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0104bde:	55                   	push   %ebp
f0104bdf:	89 e5                	mov    %esp,%ebp
f0104be1:	83 ec 48             	sub    $0x48,%esp
f0104be4:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f0104be7:	89 75 f8             	mov    %esi,-0x8(%ebp)
f0104bea:	89 7d fc             	mov    %edi,-0x4(%ebp)
f0104bed:	8b 75 08             	mov    0x8(%ebp),%esi
f0104bf0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0104bf3:	c7 03 7e 7b 10 f0    	movl   $0xf0107b7e,(%ebx)
	info->eip_line = 0;
f0104bf9:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
	info->eip_fn_name = "<unknown>";
f0104c00:	c7 43 08 7e 7b 10 f0 	movl   $0xf0107b7e,0x8(%ebx)
	info->eip_fn_namelen = 9;
f0104c07:	c7 43 0c 09 00 00 00 	movl   $0x9,0xc(%ebx)
	info->eip_fn_addr = addr;
f0104c0e:	89 73 10             	mov    %esi,0x10(%ebx)
	info->eip_fn_narg = 0;
f0104c11:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)

	// Find the relevant set of stabs
	if (addr >= ULIM) {
f0104c18:	81 fe ff ff 7f ef    	cmp    $0xef7fffff,%esi
f0104c1e:	76 1f                	jbe    f0104c3f <debuginfo_eip+0x61>
f0104c20:	bf 17 54 11 f0       	mov    $0xf0115417,%edi
f0104c25:	c7 45 d4 41 1b 11 f0 	movl   $0xf0111b41,-0x2c(%ebp)
f0104c2c:	c7 45 cc 40 1b 11 f0 	movl   $0xf0111b40,-0x34(%ebp)
f0104c33:	c7 45 d0 54 80 10 f0 	movl   $0xf0108054,-0x30(%ebp)
f0104c3a:	e9 c7 00 00 00       	jmp    f0104d06 <debuginfo_eip+0x128>
		const struct UserStabData *usd = (const struct UserStabData *) USTABDATA;

		// Make sure this memory is valid.
		// Return -1 if it is not.  Hint: Call user_mem_check.
		// LAB 3: Your code here.
		if (user_mem_check(curenv, usd, sizeof (struct UserStabData), PTE_U) < 0)
f0104c3f:	e8 eb 11 00 00       	call   f0105e2f <cpunum>
f0104c44:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104c4b:	00 
f0104c4c:	c7 44 24 08 10 00 00 	movl   $0x10,0x8(%esp)
f0104c53:	00 
f0104c54:	c7 44 24 04 00 00 20 	movl   $0x200000,0x4(%esp)
f0104c5b:	00 
f0104c5c:	6b c0 74             	imul   $0x74,%eax,%eax
f0104c5f:	8b 80 28 40 22 f0    	mov    -0xfddbfd8(%eax),%eax
f0104c65:	89 04 24             	mov    %eax,(%esp)
f0104c68:	e8 67 c6 ff ff       	call   f01012d4 <user_mem_check>
f0104c6d:	85 c0                	test   %eax,%eax
f0104c6f:	0f 88 f4 01 00 00    	js     f0104e69 <debuginfo_eip+0x28b>
			return -1;

		stabs = usd->stabs;
f0104c75:	b8 00 00 20 00       	mov    $0x200000,%eax
f0104c7a:	8b 10                	mov    (%eax),%edx
f0104c7c:	89 55 d0             	mov    %edx,-0x30(%ebp)
		stab_end = usd->stab_end;
f0104c7f:	8b 48 04             	mov    0x4(%eax),%ecx
f0104c82:	89 4d cc             	mov    %ecx,-0x34(%ebp)
		stabstr = usd->stabstr;
f0104c85:	8b 50 08             	mov    0x8(%eax),%edx
f0104c88:	89 55 d4             	mov    %edx,-0x2c(%ebp)
		stabstr_end = usd->stabstr_end;
f0104c8b:	8b 78 0c             	mov    0xc(%eax),%edi

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check (curenv, stabs, stab_end - stabs, PTE_U) < 0 \
f0104c8e:	e8 9c 11 00 00       	call   f0105e2f <cpunum>
f0104c93:	89 c2                	mov    %eax,%edx
					|| user_mem_check (curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
f0104c95:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104c9c:	00 
f0104c9d:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104ca0:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0104ca3:	c1 f8 02             	sar    $0x2,%eax
f0104ca6:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104cac:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104cb0:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104cb3:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104cb7:	6b c2 74             	imul   $0x74,%edx,%eax
f0104cba:	8b 80 28 40 22 f0    	mov    -0xfddbfd8(%eax),%eax
f0104cc0:	89 04 24             	mov    %eax,(%esp)
f0104cc3:	e8 0c c6 ff ff       	call   f01012d4 <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check (curenv, stabs, stab_end - stabs, PTE_U) < 0 \
f0104cc8:	85 c0                	test   %eax,%eax
f0104cca:	0f 88 99 01 00 00    	js     f0104e69 <debuginfo_eip+0x28b>
					|| user_mem_check (curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
f0104cd0:	e8 5a 11 00 00       	call   f0105e2f <cpunum>
f0104cd5:	c7 44 24 0c 04 00 00 	movl   $0x4,0xc(%esp)
f0104cdc:	00 
f0104cdd:	89 fa                	mov    %edi,%edx
f0104cdf:	2b 55 d4             	sub    -0x2c(%ebp),%edx
f0104ce2:	89 54 24 08          	mov    %edx,0x8(%esp)
f0104ce6:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0104ce9:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104ced:	6b c0 74             	imul   $0x74,%eax,%eax
f0104cf0:	8b 80 28 40 22 f0    	mov    -0xfddbfd8(%eax),%eax
f0104cf6:	89 04 24             	mov    %eax,(%esp)
f0104cf9:	e8 d6 c5 ff ff       	call   f01012d4 <user_mem_check>
		stabstr = usd->stabstr;
		stabstr_end = usd->stabstr_end;

		// Make sure the STABS and string table memory is valid.
		// LAB 3: Your code here.
		if (user_mem_check (curenv, stabs, stab_end - stabs, PTE_U) < 0 \
f0104cfe:	85 c0                	test   %eax,%eax
f0104d00:	0f 88 63 01 00 00    	js     f0104e69 <debuginfo_eip+0x28b>
					|| user_mem_check (curenv, stabstr, stabstr_end - stabstr, PTE_U) < 0)
		return -1;
	}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f0104d06:	39 7d d4             	cmp    %edi,-0x2c(%ebp)
f0104d09:	0f 83 5a 01 00 00    	jae    f0104e69 <debuginfo_eip+0x28b>
f0104d0f:	80 7f ff 00          	cmpb   $0x0,-0x1(%edi)
f0104d13:	0f 85 50 01 00 00    	jne    f0104e69 <debuginfo_eip+0x28b>
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0104d19:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
	rfile = (stab_end - stabs) - 1;
f0104d20:	8b 45 cc             	mov    -0x34(%ebp),%eax
f0104d23:	2b 45 d0             	sub    -0x30(%ebp),%eax
f0104d26:	c1 f8 02             	sar    $0x2,%eax
f0104d29:	69 c0 ab aa aa aa    	imul   $0xaaaaaaab,%eax,%eax
f0104d2f:	83 e8 01             	sub    $0x1,%eax
f0104d32:	89 45 e0             	mov    %eax,-0x20(%ebp)
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f0104d35:	8d 4d e0             	lea    -0x20(%ebp),%ecx
f0104d38:	8d 55 e4             	lea    -0x1c(%ebp),%edx
f0104d3b:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104d3f:	c7 04 24 64 00 00 00 	movl   $0x64,(%esp)
f0104d46:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104d49:	e8 62 fd ff ff       	call   f0104ab0 <stab_binsearch>
	if (lfile == 0)
f0104d4e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104d51:	85 c0                	test   %eax,%eax
f0104d53:	0f 84 10 01 00 00    	je     f0104e69 <debuginfo_eip+0x28b>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f0104d59:	89 45 dc             	mov    %eax,-0x24(%ebp)
	rfun = rfile;
f0104d5c:	8b 45 e0             	mov    -0x20(%ebp),%eax
f0104d5f:	89 45 d8             	mov    %eax,-0x28(%ebp)
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f0104d62:	8d 4d d8             	lea    -0x28(%ebp),%ecx
f0104d65:	8d 55 dc             	lea    -0x24(%ebp),%edx
f0104d68:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104d6c:	c7 04 24 24 00 00 00 	movl   $0x24,(%esp)
f0104d73:	8b 45 d0             	mov    -0x30(%ebp),%eax
f0104d76:	e8 35 fd ff ff       	call   f0104ab0 <stab_binsearch>

	if (lfun <= rfun) {
f0104d7b:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104d7e:	3b 45 d8             	cmp    -0x28(%ebp),%eax
f0104d81:	7f 2a                	jg     f0104dad <debuginfo_eip+0x1cf>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0104d83:	6b c0 0c             	imul   $0xc,%eax,%eax
f0104d86:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104d89:	8b 04 08             	mov    (%eax,%ecx,1),%eax
f0104d8c:	89 fa                	mov    %edi,%edx
f0104d8e:	2b 55 d4             	sub    -0x2c(%ebp),%edx
f0104d91:	39 d0                	cmp    %edx,%eax
f0104d93:	73 06                	jae    f0104d9b <debuginfo_eip+0x1bd>
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0104d95:	03 45 d4             	add    -0x2c(%ebp),%eax
f0104d98:	89 43 08             	mov    %eax,0x8(%ebx)
		info->eip_fn_addr = stabs[lfun].n_value;
f0104d9b:	8b 75 dc             	mov    -0x24(%ebp),%esi
f0104d9e:	6b c6 0c             	imul   $0xc,%esi,%eax
f0104da1:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104da4:	8b 44 10 08          	mov    0x8(%eax,%edx,1),%eax
f0104da8:	89 43 10             	mov    %eax,0x10(%ebx)
f0104dab:	eb 06                	jmp    f0104db3 <debuginfo_eip+0x1d5>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0104dad:	89 73 10             	mov    %esi,0x10(%ebx)
		lline = lfile;
f0104db0:	8b 75 e4             	mov    -0x1c(%ebp),%esi
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f0104db3:	c7 44 24 04 3a 00 00 	movl   $0x3a,0x4(%esp)
f0104dba:	00 
f0104dbb:	8b 43 08             	mov    0x8(%ebx),%eax
f0104dbe:	89 04 24             	mov    %eax,(%esp)
f0104dc1:	e8 95 09 00 00       	call   f010575b <strfind>
f0104dc6:	2b 43 08             	sub    0x8(%ebx),%eax
f0104dc9:	89 43 0c             	mov    %eax,0xc(%ebx)
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
	       && stabs[lline].n_type != N_SOL
f0104dcc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
f0104dcf:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104dd2:	39 ce                	cmp    %ecx,%esi
f0104dd4:	7c 55                	jl     f0104e2b <debuginfo_eip+0x24d>
	       && stabs[lline].n_type != N_SOL
f0104dd6:	6b ce 0c             	imul   $0xc,%esi,%ecx
f0104dd9:	03 4d d0             	add    -0x30(%ebp),%ecx
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104ddc:	0f b6 51 04          	movzbl 0x4(%ecx),%edx
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104de0:	80 fa 84             	cmp    $0x84,%dl
f0104de3:	74 31                	je     f0104e16 <debuginfo_eip+0x238>
f0104de5:	8d 46 ff             	lea    -0x1(%esi),%eax
f0104de8:	6b c0 0c             	imul   $0xc,%eax,%eax
f0104deb:	03 45 d0             	add    -0x30(%ebp),%eax
f0104dee:	eb 16                	jmp    f0104e06 <debuginfo_eip+0x228>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f0104df0:	83 ee 01             	sub    $0x1,%esi
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104df3:	39 75 cc             	cmp    %esi,-0x34(%ebp)
f0104df6:	7f 33                	jg     f0104e2b <debuginfo_eip+0x24d>
f0104df8:	89 c1                	mov    %eax,%ecx
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104dfa:	0f b6 50 04          	movzbl 0x4(%eax),%edx
f0104dfe:	83 e8 0c             	sub    $0xc,%eax
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0104e01:	80 fa 84             	cmp    $0x84,%dl
f0104e04:	74 10                	je     f0104e16 <debuginfo_eip+0x238>
f0104e06:	80 fa 64             	cmp    $0x64,%dl
f0104e09:	75 e5                	jne    f0104df0 <debuginfo_eip+0x212>
	       && stabs[lline].n_type != N_SOL
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f0104e0b:	83 79 08 00          	cmpl   $0x0,0x8(%ecx)
f0104e0f:	74 df                	je     f0104df0 <debuginfo_eip+0x212>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f0104e11:	3b 75 cc             	cmp    -0x34(%ebp),%esi
f0104e14:	7c 15                	jl     f0104e2b <debuginfo_eip+0x24d>
f0104e16:	6b f6 0c             	imul   $0xc,%esi,%esi
f0104e19:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0104e1c:	8b 04 16             	mov    (%esi,%edx,1),%eax
f0104e1f:	2b 7d d4             	sub    -0x2c(%ebp),%edi
f0104e22:	39 f8                	cmp    %edi,%eax
f0104e24:	73 05                	jae    f0104e2b <debuginfo_eip+0x24d>
		info->eip_file = stabstr + stabs[lline].n_strx;
f0104e26:	03 45 d4             	add    -0x2c(%ebp),%eax
f0104e29:	89 03                	mov    %eax,(%ebx)


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0104e2b:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0104e2e:	8b 4d d8             	mov    -0x28(%ebp),%ecx
f0104e31:	39 ca                	cmp    %ecx,%edx
f0104e33:	7d 3d                	jge    f0104e72 <debuginfo_eip+0x294>
		for (lline = lfun + 1;
f0104e35:	8d 42 01             	lea    0x1(%edx),%eax
f0104e38:	39 c1                	cmp    %eax,%ecx
f0104e3a:	7e 36                	jle    f0104e72 <debuginfo_eip+0x294>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104e3c:	6b c8 0c             	imul   $0xc,%eax,%ecx
f0104e3f:	8b 75 d0             	mov    -0x30(%ebp),%esi
f0104e42:	80 7c 31 04 a0       	cmpb   $0xa0,0x4(%ecx,%esi,1)
f0104e47:	75 29                	jne    f0104e72 <debuginfo_eip+0x294>
f0104e49:	6b d2 0c             	imul   $0xc,%edx,%edx
f0104e4c:	8d 54 16 1c          	lea    0x1c(%esi,%edx,1),%edx
		     lline++)
			info->eip_fn_narg++;
f0104e50:	83 43 14 01          	addl   $0x1,0x14(%ebx)
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0104e54:	83 c0 01             	add    $0x1,%eax


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104e57:	39 45 d8             	cmp    %eax,-0x28(%ebp)
f0104e5a:	7e 16                	jle    f0104e72 <debuginfo_eip+0x294>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0104e5c:	0f b6 0a             	movzbl (%edx),%ecx
f0104e5f:	83 c2 0c             	add    $0xc,%edx


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0104e62:	80 f9 a0             	cmp    $0xa0,%cl
f0104e65:	74 e9                	je     f0104e50 <debuginfo_eip+0x272>
f0104e67:	eb 09                	jmp    f0104e72 <debuginfo_eip+0x294>
f0104e69:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
f0104e6e:	66 90                	xchg   %ax,%ax
f0104e70:	eb 05                	jmp    f0104e77 <debuginfo_eip+0x299>
f0104e72:	b8 00 00 00 00       	mov    $0x0,%eax
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
}
f0104e77:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f0104e7a:	8b 75 f8             	mov    -0x8(%ebp),%esi
f0104e7d:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0104e80:	89 ec                	mov    %ebp,%esp
f0104e82:	5d                   	pop    %ebp
f0104e83:	c3                   	ret    
f0104e84:	66 90                	xchg   %ax,%ax
f0104e86:	66 90                	xchg   %ax,%ax
f0104e88:	66 90                	xchg   %ax,%ax
f0104e8a:	66 90                	xchg   %ax,%ax
f0104e8c:	66 90                	xchg   %ax,%ax
f0104e8e:	66 90                	xchg   %ax,%ax

f0104e90 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0104e90:	55                   	push   %ebp
f0104e91:	89 e5                	mov    %esp,%ebp
f0104e93:	57                   	push   %edi
f0104e94:	56                   	push   %esi
f0104e95:	53                   	push   %ebx
f0104e96:	83 ec 4c             	sub    $0x4c,%esp
f0104e99:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0104e9c:	89 d6                	mov    %edx,%esi
f0104e9e:	8b 45 08             	mov    0x8(%ebp),%eax
f0104ea1:	89 45 d8             	mov    %eax,-0x28(%ebp)
f0104ea4:	8b 55 0c             	mov    0xc(%ebp),%edx
f0104ea7:	89 55 e0             	mov    %edx,-0x20(%ebp)
f0104eaa:	8b 45 10             	mov    0x10(%ebp),%eax
f0104ead:	8b 5d 14             	mov    0x14(%ebp),%ebx
f0104eb0:	8b 7d 18             	mov    0x18(%ebp),%edi
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0104eb3:	89 45 dc             	mov    %eax,-0x24(%ebp)
f0104eb6:	b9 00 00 00 00       	mov    $0x0,%ecx
f0104ebb:	39 d1                	cmp    %edx,%ecx
f0104ebd:	72 15                	jb     f0104ed4 <printnum+0x44>
f0104ebf:	77 07                	ja     f0104ec8 <printnum+0x38>
f0104ec1:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104ec4:	39 d0                	cmp    %edx,%eax
f0104ec6:	76 0c                	jbe    f0104ed4 <printnum+0x44>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104ec8:	83 eb 01             	sub    $0x1,%ebx
f0104ecb:	85 db                	test   %ebx,%ebx
f0104ecd:	8d 76 00             	lea    0x0(%esi),%esi
f0104ed0:	7f 61                	jg     f0104f33 <printnum+0xa3>
f0104ed2:	eb 70                	jmp    f0104f44 <printnum+0xb4>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0104ed4:	89 7c 24 10          	mov    %edi,0x10(%esp)
f0104ed8:	83 eb 01             	sub    $0x1,%ebx
f0104edb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104edf:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104ee3:	8b 4c 24 08          	mov    0x8(%esp),%ecx
f0104ee7:	8b 5c 24 0c          	mov    0xc(%esp),%ebx
f0104eeb:	89 4d d0             	mov    %ecx,-0x30(%ebp)
f0104eee:	89 5d d4             	mov    %ebx,-0x2c(%ebp)
f0104ef1:	8b 5d dc             	mov    -0x24(%ebp),%ebx
f0104ef4:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f0104ef8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104eff:	00 
f0104f00:	8b 45 d8             	mov    -0x28(%ebp),%eax
f0104f03:	89 04 24             	mov    %eax,(%esp)
f0104f06:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0104f09:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104f0d:	e8 ce 13 00 00       	call   f01062e0 <__udivdi3>
f0104f12:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f0104f15:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0104f18:	89 4c 24 08          	mov    %ecx,0x8(%esp)
f0104f1c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
f0104f20:	89 04 24             	mov    %eax,(%esp)
f0104f23:	89 54 24 04          	mov    %edx,0x4(%esp)
f0104f27:	89 f2                	mov    %esi,%edx
f0104f29:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0104f2c:	e8 5f ff ff ff       	call   f0104e90 <printnum>
f0104f31:	eb 11                	jmp    f0104f44 <printnum+0xb4>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0104f33:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104f37:	89 3c 24             	mov    %edi,(%esp)
f0104f3a:	ff 55 e4             	call   *-0x1c(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0104f3d:	83 eb 01             	sub    $0x1,%ebx
f0104f40:	85 db                	test   %ebx,%ebx
f0104f42:	7f ef                	jg     f0104f33 <printnum+0xa3>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0104f44:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104f48:	8b 74 24 04          	mov    0x4(%esp),%esi
f0104f4c:	8b 45 dc             	mov    -0x24(%ebp),%eax
f0104f4f:	89 44 24 08          	mov    %eax,0x8(%esp)
f0104f53:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
f0104f5a:	00 
f0104f5b:	8b 55 d8             	mov    -0x28(%ebp),%edx
f0104f5e:	89 14 24             	mov    %edx,(%esp)
f0104f61:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0104f64:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f0104f68:	e8 a3 14 00 00       	call   f0106410 <__umoddi3>
f0104f6d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0104f71:	0f be 80 88 7b 10 f0 	movsbl -0xfef8478(%eax),%eax
f0104f78:	89 04 24             	mov    %eax,(%esp)
f0104f7b:	ff 55 e4             	call   *-0x1c(%ebp)
}
f0104f7e:	83 c4 4c             	add    $0x4c,%esp
f0104f81:	5b                   	pop    %ebx
f0104f82:	5e                   	pop    %esi
f0104f83:	5f                   	pop    %edi
f0104f84:	5d                   	pop    %ebp
f0104f85:	c3                   	ret    

f0104f86 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f0104f86:	55                   	push   %ebp
f0104f87:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
f0104f89:	83 fa 01             	cmp    $0x1,%edx
f0104f8c:	7e 0e                	jle    f0104f9c <getuint+0x16>
		return va_arg(*ap, unsigned long long);
f0104f8e:	8b 10                	mov    (%eax),%edx
f0104f90:	8d 4a 08             	lea    0x8(%edx),%ecx
f0104f93:	89 08                	mov    %ecx,(%eax)
f0104f95:	8b 02                	mov    (%edx),%eax
f0104f97:	8b 52 04             	mov    0x4(%edx),%edx
f0104f9a:	eb 22                	jmp    f0104fbe <getuint+0x38>
	else if (lflag)
f0104f9c:	85 d2                	test   %edx,%edx
f0104f9e:	74 10                	je     f0104fb0 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
f0104fa0:	8b 10                	mov    (%eax),%edx
f0104fa2:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104fa5:	89 08                	mov    %ecx,(%eax)
f0104fa7:	8b 02                	mov    (%edx),%eax
f0104fa9:	ba 00 00 00 00       	mov    $0x0,%edx
f0104fae:	eb 0e                	jmp    f0104fbe <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
f0104fb0:	8b 10                	mov    (%eax),%edx
f0104fb2:	8d 4a 04             	lea    0x4(%edx),%ecx
f0104fb5:	89 08                	mov    %ecx,(%eax)
f0104fb7:	8b 02                	mov    (%edx),%eax
f0104fb9:	ba 00 00 00 00       	mov    $0x0,%edx
}
f0104fbe:	5d                   	pop    %ebp
f0104fbf:	c3                   	ret    

f0104fc0 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0104fc0:	55                   	push   %ebp
f0104fc1:	89 e5                	mov    %esp,%ebp
f0104fc3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
f0104fc6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
f0104fca:	8b 10                	mov    (%eax),%edx
f0104fcc:	3b 50 04             	cmp    0x4(%eax),%edx
f0104fcf:	73 0a                	jae    f0104fdb <sprintputch+0x1b>
		*b->buf++ = ch;
f0104fd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
f0104fd4:	88 0a                	mov    %cl,(%edx)
f0104fd6:	83 c2 01             	add    $0x1,%edx
f0104fd9:	89 10                	mov    %edx,(%eax)
}
f0104fdb:	5d                   	pop    %ebp
f0104fdc:	c3                   	ret    

f0104fdd <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f0104fdd:	55                   	push   %ebp
f0104fde:	89 e5                	mov    %esp,%ebp
f0104fe0:	57                   	push   %edi
f0104fe1:	56                   	push   %esi
f0104fe2:	53                   	push   %ebx
f0104fe3:	83 ec 5c             	sub    $0x5c,%esp
f0104fe6:	8b 7d 08             	mov    0x8(%ebp),%edi
f0104fe9:	8b 75 0c             	mov    0xc(%ebp),%esi
f0104fec:	8b 5d 10             	mov    0x10(%ebp),%ebx
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0104fef:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
f0104ff6:	eb 11                	jmp    f0105009 <vprintfmt+0x2c>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
f0104ff8:	85 c0                	test   %eax,%eax
f0104ffa:	0f 84 16 04 00 00    	je     f0105416 <vprintfmt+0x439>
				return;
			putch(ch, putdat);
f0105000:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105004:	89 04 24             	mov    %eax,(%esp)
f0105007:	ff d7                	call   *%edi
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f0105009:	0f b6 03             	movzbl (%ebx),%eax
f010500c:	83 c3 01             	add    $0x1,%ebx
f010500f:	83 f8 25             	cmp    $0x25,%eax
f0105012:	75 e4                	jne    f0104ff8 <vprintfmt+0x1b>
f0105014:	c7 45 cc ff ff ff ff 	movl   $0xffffffff,-0x34(%ebp)
f010501b:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
f0105022:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105027:	c6 45 dc 20          	movb   $0x20,-0x24(%ebp)
f010502b:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
f0105032:	eb 06                	jmp    f010503a <vprintfmt+0x5d>
f0105034:	c6 45 dc 2d          	movb   $0x2d,-0x24(%ebp)
f0105038:	89 c3                	mov    %eax,%ebx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010503a:	0f b6 13             	movzbl (%ebx),%edx
f010503d:	0f b6 c2             	movzbl %dl,%eax
f0105040:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105043:	8d 43 01             	lea    0x1(%ebx),%eax
f0105046:	83 ea 23             	sub    $0x23,%edx
f0105049:	80 fa 55             	cmp    $0x55,%dl
f010504c:	0f 87 a7 03 00 00    	ja     f01053f9 <vprintfmt+0x41c>
f0105052:	0f b6 d2             	movzbl %dl,%edx
f0105055:	ff 24 95 40 7c 10 f0 	jmp    *-0xfef83c0(,%edx,4)
f010505c:	c6 45 dc 30          	movb   $0x30,-0x24(%ebp)
f0105060:	eb d6                	jmp    f0105038 <vprintfmt+0x5b>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f0105062:	8b 55 e0             	mov    -0x20(%ebp),%edx
f0105065:	83 ea 30             	sub    $0x30,%edx
f0105068:	89 55 cc             	mov    %edx,-0x34(%ebp)
				ch = *fmt;
f010506b:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f010506e:	8d 5a d0             	lea    -0x30(%edx),%ebx
f0105071:	83 fb 09             	cmp    $0x9,%ebx
f0105074:	77 54                	ja     f01050ca <vprintfmt+0xed>
f0105076:	89 4d e0             	mov    %ecx,-0x20(%ebp)
f0105079:	8b 4d cc             	mov    -0x34(%ebp),%ecx
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
f010507c:	83 c0 01             	add    $0x1,%eax
				precision = precision * 10 + ch - '0';
f010507f:	8d 0c 89             	lea    (%ecx,%ecx,4),%ecx
f0105082:	8d 4c 4a d0          	lea    -0x30(%edx,%ecx,2),%ecx
				ch = *fmt;
f0105086:	0f be 10             	movsbl (%eax),%edx
				if (ch < '0' || ch > '9')
f0105089:	8d 5a d0             	lea    -0x30(%edx),%ebx
f010508c:	83 fb 09             	cmp    $0x9,%ebx
f010508f:	76 eb                	jbe    f010507c <vprintfmt+0x9f>
f0105091:	89 4d cc             	mov    %ecx,-0x34(%ebp)
f0105094:	8b 4d e0             	mov    -0x20(%ebp),%ecx
f0105097:	eb 31                	jmp    f01050ca <vprintfmt+0xed>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f0105099:	8b 55 14             	mov    0x14(%ebp),%edx
f010509c:	8d 5a 04             	lea    0x4(%edx),%ebx
f010509f:	89 5d 14             	mov    %ebx,0x14(%ebp)
f01050a2:	8b 12                	mov    (%edx),%edx
f01050a4:	89 55 cc             	mov    %edx,-0x34(%ebp)
			goto process_precision;
f01050a7:	eb 21                	jmp    f01050ca <vprintfmt+0xed>

		case '.':
			if (width < 0)
f01050a9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01050ad:	ba 00 00 00 00       	mov    $0x0,%edx
f01050b2:	0f 49 55 e4          	cmovns -0x1c(%ebp),%edx
f01050b6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01050b9:	e9 7a ff ff ff       	jmp    f0105038 <vprintfmt+0x5b>
f01050be:	c7 45 d0 01 00 00 00 	movl   $0x1,-0x30(%ebp)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
			goto reswitch;
f01050c5:	e9 6e ff ff ff       	jmp    f0105038 <vprintfmt+0x5b>

		process_precision:
			if (width < 0)
f01050ca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f01050ce:	0f 89 64 ff ff ff    	jns    f0105038 <vprintfmt+0x5b>
f01050d4:	8b 55 cc             	mov    -0x34(%ebp),%edx
f01050d7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01050da:	8b 55 c8             	mov    -0x38(%ebp),%edx
f01050dd:	89 55 cc             	mov    %edx,-0x34(%ebp)
f01050e0:	e9 53 ff ff ff       	jmp    f0105038 <vprintfmt+0x5b>
				width = precision, precision = -1;
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f01050e5:	83 c1 01             	add    $0x1,%ecx
			goto reswitch;
f01050e8:	e9 4b ff ff ff       	jmp    f0105038 <vprintfmt+0x5b>
f01050ed:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f01050f0:	8b 45 14             	mov    0x14(%ebp),%eax
f01050f3:	8d 50 04             	lea    0x4(%eax),%edx
f01050f6:	89 55 14             	mov    %edx,0x14(%ebp)
f01050f9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01050fd:	8b 00                	mov    (%eax),%eax
f01050ff:	89 04 24             	mov    %eax,(%esp)
f0105102:	ff d7                	call   *%edi
f0105104:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f0105107:	e9 fd fe ff ff       	jmp    f0105009 <vprintfmt+0x2c>
f010510c:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// error message
		case 'e':
			err = va_arg(ap, int);
f010510f:	8b 45 14             	mov    0x14(%ebp),%eax
f0105112:	8d 50 04             	lea    0x4(%eax),%edx
f0105115:	89 55 14             	mov    %edx,0x14(%ebp)
f0105118:	8b 00                	mov    (%eax),%eax
f010511a:	89 c2                	mov    %eax,%edx
f010511c:	c1 fa 1f             	sar    $0x1f,%edx
f010511f:	31 d0                	xor    %edx,%eax
f0105121:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0105123:	83 f8 08             	cmp    $0x8,%eax
f0105126:	7f 0b                	jg     f0105133 <vprintfmt+0x156>
f0105128:	8b 14 85 a0 7d 10 f0 	mov    -0xfef8260(,%eax,4),%edx
f010512f:	85 d2                	test   %edx,%edx
f0105131:	75 20                	jne    f0105153 <vprintfmt+0x176>
				printfmt(putch, putdat, "error %d", err);
f0105133:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105137:	c7 44 24 08 99 7b 10 	movl   $0xf0107b99,0x8(%esp)
f010513e:	f0 
f010513f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105143:	89 3c 24             	mov    %edi,(%esp)
f0105146:	e8 53 03 00 00       	call   f010549e <printfmt>
f010514b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f010514e:	e9 b6 fe ff ff       	jmp    f0105009 <vprintfmt+0x2c>
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f0105153:	89 54 24 0c          	mov    %edx,0xc(%esp)
f0105157:	c7 44 24 08 e3 73 10 	movl   $0xf01073e3,0x8(%esp)
f010515e:	f0 
f010515f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105163:	89 3c 24             	mov    %edi,(%esp)
f0105166:	e8 33 03 00 00       	call   f010549e <printfmt>
f010516b:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010516e:	e9 96 fe ff ff       	jmp    f0105009 <vprintfmt+0x2c>
f0105173:	89 45 e0             	mov    %eax,-0x20(%ebp)
f0105176:	89 c3                	mov    %eax,%ebx
f0105178:	8b 4d cc             	mov    -0x34(%ebp),%ecx
f010517b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f010517e:	89 45 c0             	mov    %eax,-0x40(%ebp)
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f0105181:	8b 45 14             	mov    0x14(%ebp),%eax
f0105184:	8d 50 04             	lea    0x4(%eax),%edx
f0105187:	89 55 14             	mov    %edx,0x14(%ebp)
f010518a:	8b 00                	mov    (%eax),%eax
f010518c:	89 45 c4             	mov    %eax,-0x3c(%ebp)
f010518f:	85 c0                	test   %eax,%eax
f0105191:	b8 a2 7b 10 f0       	mov    $0xf0107ba2,%eax
f0105196:	0f 45 45 c4          	cmovne -0x3c(%ebp),%eax
f010519a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
f010519d:	83 7d c0 00          	cmpl   $0x0,-0x40(%ebp)
f01051a1:	7e 06                	jle    f01051a9 <vprintfmt+0x1cc>
f01051a3:	80 7d dc 2d          	cmpb   $0x2d,-0x24(%ebp)
f01051a7:	75 13                	jne    f01051bc <vprintfmt+0x1df>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01051a9:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f01051ac:	0f be 02             	movsbl (%edx),%eax
f01051af:	85 c0                	test   %eax,%eax
f01051b1:	0f 85 9b 00 00 00    	jne    f0105252 <vprintfmt+0x275>
f01051b7:	e9 88 00 00 00       	jmp    f0105244 <vprintfmt+0x267>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01051bc:	89 4c 24 04          	mov    %ecx,0x4(%esp)
f01051c0:	8b 4d c4             	mov    -0x3c(%ebp),%ecx
f01051c3:	89 0c 24             	mov    %ecx,(%esp)
f01051c6:	e8 00 04 00 00       	call   f01055cb <strnlen>
f01051cb:	8b 55 c0             	mov    -0x40(%ebp),%edx
f01051ce:	29 c2                	sub    %eax,%edx
f01051d0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01051d3:	85 d2                	test   %edx,%edx
f01051d5:	7e d2                	jle    f01051a9 <vprintfmt+0x1cc>
					putch(padc, putdat);
f01051d7:	0f be 4d dc          	movsbl -0x24(%ebp),%ecx
f01051db:	89 4d dc             	mov    %ecx,-0x24(%ebp)
f01051de:	89 5d c0             	mov    %ebx,-0x40(%ebp)
f01051e1:	89 d3                	mov    %edx,%ebx
f01051e3:	89 74 24 04          	mov    %esi,0x4(%esp)
f01051e7:	8b 45 dc             	mov    -0x24(%ebp),%eax
f01051ea:	89 04 24             	mov    %eax,(%esp)
f01051ed:	ff d7                	call   *%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f01051ef:	83 eb 01             	sub    $0x1,%ebx
f01051f2:	85 db                	test   %ebx,%ebx
f01051f4:	7f ed                	jg     f01051e3 <vprintfmt+0x206>
f01051f6:	8b 5d c0             	mov    -0x40(%ebp),%ebx
f01051f9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
f0105200:	eb a7                	jmp    f01051a9 <vprintfmt+0x1cc>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f0105202:	83 7d d0 00          	cmpl   $0x0,-0x30(%ebp)
f0105206:	74 1a                	je     f0105222 <vprintfmt+0x245>
f0105208:	8d 50 e0             	lea    -0x20(%eax),%edx
f010520b:	83 fa 5e             	cmp    $0x5e,%edx
f010520e:	76 12                	jbe    f0105222 <vprintfmt+0x245>
					putch('?', putdat);
f0105210:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105214:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
f010521b:	ff 55 dc             	call   *-0x24(%ebp)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010521e:	66 90                	xchg   %ax,%ax
f0105220:	eb 0a                	jmp    f010522c <vprintfmt+0x24f>
					putch('?', putdat);
				else
					putch(ch, putdat);
f0105222:	89 7c 24 04          	mov    %edi,0x4(%esp)
f0105226:	89 04 24             	mov    %eax,(%esp)
f0105229:	ff 55 dc             	call   *-0x24(%ebp)
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f010522c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
f0105230:	0f be 03             	movsbl (%ebx),%eax
f0105233:	85 c0                	test   %eax,%eax
f0105235:	74 05                	je     f010523c <vprintfmt+0x25f>
f0105237:	83 c3 01             	add    $0x1,%ebx
f010523a:	eb 29                	jmp    f0105265 <vprintfmt+0x288>
f010523c:	89 fe                	mov    %edi,%esi
f010523e:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0105241:	8b 5d cc             	mov    -0x34(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0105244:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
f0105248:	7f 2e                	jg     f0105278 <vprintfmt+0x29b>
f010524a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
f010524d:	e9 b7 fd ff ff       	jmp    f0105009 <vprintfmt+0x2c>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0105252:	8b 55 c4             	mov    -0x3c(%ebp),%edx
f0105255:	83 c2 01             	add    $0x1,%edx
f0105258:	89 7d dc             	mov    %edi,-0x24(%ebp)
f010525b:	89 f7                	mov    %esi,%edi
f010525d:	8b 75 cc             	mov    -0x34(%ebp),%esi
f0105260:	89 5d cc             	mov    %ebx,-0x34(%ebp)
f0105263:	89 d3                	mov    %edx,%ebx
f0105265:	85 f6                	test   %esi,%esi
f0105267:	78 99                	js     f0105202 <vprintfmt+0x225>
f0105269:	83 ee 01             	sub    $0x1,%esi
f010526c:	79 94                	jns    f0105202 <vprintfmt+0x225>
f010526e:	89 fe                	mov    %edi,%esi
f0105270:	8b 7d dc             	mov    -0x24(%ebp),%edi
f0105273:	8b 5d cc             	mov    -0x34(%ebp),%ebx
f0105276:	eb cc                	jmp    f0105244 <vprintfmt+0x267>
f0105278:	89 5d d0             	mov    %ebx,-0x30(%ebp)
f010527b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010527e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105282:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
f0105289:	ff d7                	call   *%edi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010528b:	83 eb 01             	sub    $0x1,%ebx
f010528e:	85 db                	test   %ebx,%ebx
f0105290:	7f ec                	jg     f010527e <vprintfmt+0x2a1>
f0105292:	8b 5d d0             	mov    -0x30(%ebp),%ebx
f0105295:	e9 6f fd ff ff       	jmp    f0105009 <vprintfmt+0x2c>
f010529a:	89 45 e0             	mov    %eax,-0x20(%ebp)
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f010529d:	83 f9 01             	cmp    $0x1,%ecx
f01052a0:	7e 16                	jle    f01052b8 <vprintfmt+0x2db>
		return va_arg(*ap, long long);
f01052a2:	8b 45 14             	mov    0x14(%ebp),%eax
f01052a5:	8d 50 08             	lea    0x8(%eax),%edx
f01052a8:	89 55 14             	mov    %edx,0x14(%ebp)
f01052ab:	8b 10                	mov    (%eax),%edx
f01052ad:	8b 48 04             	mov    0x4(%eax),%ecx
f01052b0:	89 55 d0             	mov    %edx,-0x30(%ebp)
f01052b3:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01052b6:	eb 32                	jmp    f01052ea <vprintfmt+0x30d>
	else if (lflag)
f01052b8:	85 c9                	test   %ecx,%ecx
f01052ba:	74 18                	je     f01052d4 <vprintfmt+0x2f7>
		return va_arg(*ap, long);
f01052bc:	8b 45 14             	mov    0x14(%ebp),%eax
f01052bf:	8d 50 04             	lea    0x4(%eax),%edx
f01052c2:	89 55 14             	mov    %edx,0x14(%ebp)
f01052c5:	8b 00                	mov    (%eax),%eax
f01052c7:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01052ca:	89 c1                	mov    %eax,%ecx
f01052cc:	c1 f9 1f             	sar    $0x1f,%ecx
f01052cf:	89 4d d4             	mov    %ecx,-0x2c(%ebp)
f01052d2:	eb 16                	jmp    f01052ea <vprintfmt+0x30d>
	else
		return va_arg(*ap, int);
f01052d4:	8b 45 14             	mov    0x14(%ebp),%eax
f01052d7:	8d 50 04             	lea    0x4(%eax),%edx
f01052da:	89 55 14             	mov    %edx,0x14(%ebp)
f01052dd:	8b 00                	mov    (%eax),%eax
f01052df:	89 45 d0             	mov    %eax,-0x30(%ebp)
f01052e2:	89 c2                	mov    %eax,%edx
f01052e4:	c1 fa 1f             	sar    $0x1f,%edx
f01052e7:	89 55 d4             	mov    %edx,-0x2c(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01052ea:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f01052ed:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f01052f0:	b8 0a 00 00 00       	mov    $0xa,%eax
			if ((long long) num < 0) {
f01052f5:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
f01052f9:	0f 89 b8 00 00 00    	jns    f01053b7 <vprintfmt+0x3da>
				putch('-', putdat);
f01052ff:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105303:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
f010530a:	ff d7                	call   *%edi
				num = -(long long) num;
f010530c:	8b 4d d0             	mov    -0x30(%ebp),%ecx
f010530f:	8b 5d d4             	mov    -0x2c(%ebp),%ebx
f0105312:	f7 d9                	neg    %ecx
f0105314:	83 d3 00             	adc    $0x0,%ebx
f0105317:	f7 db                	neg    %ebx
f0105319:	b8 0a 00 00 00       	mov    $0xa,%eax
f010531e:	e9 94 00 00 00       	jmp    f01053b7 <vprintfmt+0x3da>
f0105323:	89 45 e0             	mov    %eax,-0x20(%ebp)
			base = 10;
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0105326:	89 ca                	mov    %ecx,%edx
f0105328:	8d 45 14             	lea    0x14(%ebp),%eax
f010532b:	e8 56 fc ff ff       	call   f0104f86 <getuint>
f0105330:	89 c1                	mov    %eax,%ecx
f0105332:	89 d3                	mov    %edx,%ebx
f0105334:	b8 0a 00 00 00       	mov    $0xa,%eax
			base = 10;
			goto number;
f0105339:	eb 7c                	jmp    f01053b7 <vprintfmt+0x3da>
f010533b:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			putch('X', putdat);
f010533e:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105342:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105349:	ff d7                	call   *%edi
			putch('X', putdat);
f010534b:	89 74 24 04          	mov    %esi,0x4(%esp)
f010534f:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105356:	ff d7                	call   *%edi
			putch('X', putdat);
f0105358:	89 74 24 04          	mov    %esi,0x4(%esp)
f010535c:	c7 04 24 58 00 00 00 	movl   $0x58,(%esp)
f0105363:	ff d7                	call   *%edi
f0105365:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f0105368:	e9 9c fc ff ff       	jmp    f0105009 <vprintfmt+0x2c>
f010536d:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
f0105370:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105374:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
f010537b:	ff d7                	call   *%edi
			putch('x', putdat);
f010537d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105381:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
f0105388:	ff d7                	call   *%edi
			num = (unsigned long long)
f010538a:	8b 45 14             	mov    0x14(%ebp),%eax
f010538d:	8d 50 04             	lea    0x4(%eax),%edx
f0105390:	89 55 14             	mov    %edx,0x14(%ebp)
f0105393:	8b 08                	mov    (%eax),%ecx
f0105395:	bb 00 00 00 00       	mov    $0x0,%ebx
f010539a:	b8 10 00 00 00       	mov    $0x10,%eax
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
f010539f:	eb 16                	jmp    f01053b7 <vprintfmt+0x3da>
f01053a1:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f01053a4:	89 ca                	mov    %ecx,%edx
f01053a6:	8d 45 14             	lea    0x14(%ebp),%eax
f01053a9:	e8 d8 fb ff ff       	call   f0104f86 <getuint>
f01053ae:	89 c1                	mov    %eax,%ecx
f01053b0:	89 d3                	mov    %edx,%ebx
f01053b2:	b8 10 00 00 00       	mov    $0x10,%eax
			base = 16;
		number:
			printnum(putch, putdat, num, base, width, padc);
f01053b7:	0f be 55 dc          	movsbl -0x24(%ebp),%edx
f01053bb:	89 54 24 10          	mov    %edx,0x10(%esp)
f01053bf:	8b 55 e4             	mov    -0x1c(%ebp),%edx
f01053c2:	89 54 24 0c          	mov    %edx,0xc(%esp)
f01053c6:	89 44 24 08          	mov    %eax,0x8(%esp)
f01053ca:	89 0c 24             	mov    %ecx,(%esp)
f01053cd:	89 5c 24 04          	mov    %ebx,0x4(%esp)
f01053d1:	89 f2                	mov    %esi,%edx
f01053d3:	89 f8                	mov    %edi,%eax
f01053d5:	e8 b6 fa ff ff       	call   f0104e90 <printnum>
f01053da:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f01053dd:	e9 27 fc ff ff       	jmp    f0105009 <vprintfmt+0x2c>
f01053e2:	8b 55 e0             	mov    -0x20(%ebp),%edx
f01053e5:	89 45 e0             	mov    %eax,-0x20(%ebp)

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01053e8:	89 74 24 04          	mov    %esi,0x4(%esp)
f01053ec:	89 14 24             	mov    %edx,(%esp)
f01053ef:	ff d7                	call   *%edi
f01053f1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
			break;
f01053f4:	e9 10 fc ff ff       	jmp    f0105009 <vprintfmt+0x2c>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01053f9:	89 74 24 04          	mov    %esi,0x4(%esp)
f01053fd:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
f0105404:	ff d7                	call   *%edi
			for (fmt--; fmt[-1] != '%'; fmt--)
f0105406:	8d 43 ff             	lea    -0x1(%ebx),%eax
f0105409:	80 38 25             	cmpb   $0x25,(%eax)
f010540c:	0f 84 f7 fb ff ff    	je     f0105009 <vprintfmt+0x2c>
f0105412:	89 c3                	mov    %eax,%ebx
f0105414:	eb f0                	jmp    f0105406 <vprintfmt+0x429>
				/* do nothing */;
			break;
		}
	}
}
f0105416:	83 c4 5c             	add    $0x5c,%esp
f0105419:	5b                   	pop    %ebx
f010541a:	5e                   	pop    %esi
f010541b:	5f                   	pop    %edi
f010541c:	5d                   	pop    %ebp
f010541d:	c3                   	ret    

f010541e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f010541e:	55                   	push   %ebp
f010541f:	89 e5                	mov    %esp,%ebp
f0105421:	83 ec 28             	sub    $0x28,%esp
f0105424:	8b 45 08             	mov    0x8(%ebp),%eax
f0105427:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
f010542a:	85 c0                	test   %eax,%eax
f010542c:	74 04                	je     f0105432 <vsnprintf+0x14>
f010542e:	85 d2                	test   %edx,%edx
f0105430:	7f 07                	jg     f0105439 <vsnprintf+0x1b>
f0105432:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
f0105437:	eb 3b                	jmp    f0105474 <vsnprintf+0x56>
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};
f0105439:	89 45 ec             	mov    %eax,-0x14(%ebp)
f010543c:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
f0105440:	89 45 f0             	mov    %eax,-0x10(%ebp)
f0105443:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f010544a:	8b 45 14             	mov    0x14(%ebp),%eax
f010544d:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105451:	8b 45 10             	mov    0x10(%ebp),%eax
f0105454:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105458:	8d 45 ec             	lea    -0x14(%ebp),%eax
f010545b:	89 44 24 04          	mov    %eax,0x4(%esp)
f010545f:	c7 04 24 c0 4f 10 f0 	movl   $0xf0104fc0,(%esp)
f0105466:	e8 72 fb ff ff       	call   f0104fdd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f010546b:	8b 45 ec             	mov    -0x14(%ebp),%eax
f010546e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
f0105471:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
f0105474:	c9                   	leave  
f0105475:	c3                   	ret    

f0105476 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0105476:	55                   	push   %ebp
f0105477:	89 e5                	mov    %esp,%ebp
f0105479:	83 ec 18             	sub    $0x18,%esp

	return b.cnt;
}

int
snprintf(char *buf, int n, const char *fmt, ...)
f010547c:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;
	int rc;

	va_start(ap, fmt);
	rc = vsnprintf(buf, n, fmt, ap);
f010547f:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105483:	8b 45 10             	mov    0x10(%ebp),%eax
f0105486:	89 44 24 08          	mov    %eax,0x8(%esp)
f010548a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010548d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105491:	8b 45 08             	mov    0x8(%ebp),%eax
f0105494:	89 04 24             	mov    %eax,(%esp)
f0105497:	e8 82 ff ff ff       	call   f010541e <vsnprintf>
	va_end(ap);

	return rc;
}
f010549c:	c9                   	leave  
f010549d:	c3                   	ret    

f010549e <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010549e:	55                   	push   %ebp
f010549f:	89 e5                	mov    %esp,%ebp
f01054a1:	83 ec 18             	sub    $0x18,%esp
		}
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
f01054a4:	8d 45 14             	lea    0x14(%ebp),%eax
{
	va_list ap;

	va_start(ap, fmt);
	vprintfmt(putch, putdat, fmt, ap);
f01054a7:	89 44 24 0c          	mov    %eax,0xc(%esp)
f01054ab:	8b 45 10             	mov    0x10(%ebp),%eax
f01054ae:	89 44 24 08          	mov    %eax,0x8(%esp)
f01054b2:	8b 45 0c             	mov    0xc(%ebp),%eax
f01054b5:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054b9:	8b 45 08             	mov    0x8(%ebp),%eax
f01054bc:	89 04 24             	mov    %eax,(%esp)
f01054bf:	e8 19 fb ff ff       	call   f0104fdd <vprintfmt>
	va_end(ap);
}
f01054c4:	c9                   	leave  
f01054c5:	c3                   	ret    
f01054c6:	66 90                	xchg   %ax,%ax
f01054c8:	66 90                	xchg   %ax,%ax
f01054ca:	66 90                	xchg   %ax,%ax
f01054cc:	66 90                	xchg   %ax,%ax
f01054ce:	66 90                	xchg   %ax,%ax

f01054d0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f01054d0:	55                   	push   %ebp
f01054d1:	89 e5                	mov    %esp,%ebp
f01054d3:	57                   	push   %edi
f01054d4:	56                   	push   %esi
f01054d5:	53                   	push   %ebx
f01054d6:	83 ec 1c             	sub    $0x1c,%esp
f01054d9:	8b 45 08             	mov    0x8(%ebp),%eax
	int i, c, echoing;

	if (prompt != NULL)
f01054dc:	85 c0                	test   %eax,%eax
f01054de:	74 10                	je     f01054f0 <readline+0x20>
		cprintf("%s", prompt);
f01054e0:	89 44 24 04          	mov    %eax,0x4(%esp)
f01054e4:	c7 04 24 e3 73 10 f0 	movl   $0xf01073e3,(%esp)
f01054eb:	e8 39 ea ff ff       	call   f0103f29 <cprintf>

	i = 0;
	echoing = iscons(0);
f01054f0:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
f01054f7:	e8 c4 ae ff ff       	call   f01003c0 <iscons>
f01054fc:	89 c7                	mov    %eax,%edi
f01054fe:	be 00 00 00 00       	mov    $0x0,%esi
	while (1) {
		c = getchar();
f0105503:	e8 a7 ae ff ff       	call   f01003af <getchar>
f0105508:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
f010550a:	85 c0                	test   %eax,%eax
f010550c:	79 17                	jns    f0105525 <readline+0x55>
			cprintf("read error: %e\n", c);
f010550e:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105512:	c7 04 24 c4 7d 10 f0 	movl   $0xf0107dc4,(%esp)
f0105519:	e8 0b ea ff ff       	call   f0103f29 <cprintf>
f010551e:	b8 00 00 00 00       	mov    $0x0,%eax
			return NULL;
f0105523:	eb 76                	jmp    f010559b <readline+0xcb>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105525:	83 f8 08             	cmp    $0x8,%eax
f0105528:	74 08                	je     f0105532 <readline+0x62>
f010552a:	83 f8 7f             	cmp    $0x7f,%eax
f010552d:	8d 76 00             	lea    0x0(%esi),%esi
f0105530:	75 19                	jne    f010554b <readline+0x7b>
f0105532:	85 f6                	test   %esi,%esi
f0105534:	7e 15                	jle    f010554b <readline+0x7b>
			if (echoing)
f0105536:	85 ff                	test   %edi,%edi
f0105538:	74 0c                	je     f0105546 <readline+0x76>
				cputchar('\b');
f010553a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
f0105541:	e8 84 b0 ff ff       	call   f01005ca <cputchar>
			i--;
f0105546:	83 ee 01             	sub    $0x1,%esi
	while (1) {
		c = getchar();
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0105549:	eb b8                	jmp    f0105503 <readline+0x33>
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f010554b:	83 fb 1f             	cmp    $0x1f,%ebx
f010554e:	66 90                	xchg   %ax,%ax
f0105550:	7e 23                	jle    f0105575 <readline+0xa5>
f0105552:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
f0105558:	7f 1b                	jg     f0105575 <readline+0xa5>
			if (echoing)
f010555a:	85 ff                	test   %edi,%edi
f010555c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105560:	74 08                	je     f010556a <readline+0x9a>
				cputchar(c);
f0105562:	89 1c 24             	mov    %ebx,(%esp)
f0105565:	e8 60 b0 ff ff       	call   f01005ca <cputchar>
			buf[i++] = c;
f010556a:	88 9e e0 3a 22 f0    	mov    %bl,-0xfddc520(%esi)
f0105570:	83 c6 01             	add    $0x1,%esi
f0105573:	eb 8e                	jmp    f0105503 <readline+0x33>
		} else if (c == '\n' || c == '\r') {
f0105575:	83 fb 0a             	cmp    $0xa,%ebx
f0105578:	74 05                	je     f010557f <readline+0xaf>
f010557a:	83 fb 0d             	cmp    $0xd,%ebx
f010557d:	75 84                	jne    f0105503 <readline+0x33>
			if (echoing)
f010557f:	85 ff                	test   %edi,%edi
f0105581:	74 0c                	je     f010558f <readline+0xbf>
				cputchar('\n');
f0105583:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
f010558a:	e8 3b b0 ff ff       	call   f01005ca <cputchar>
			buf[i] = 0;
f010558f:	c6 86 e0 3a 22 f0 00 	movb   $0x0,-0xfddc520(%esi)
f0105596:	b8 e0 3a 22 f0       	mov    $0xf0223ae0,%eax
			return buf;
		}
	}
}
f010559b:	83 c4 1c             	add    $0x1c,%esp
f010559e:	5b                   	pop    %ebx
f010559f:	5e                   	pop    %esi
f01055a0:	5f                   	pop    %edi
f01055a1:	5d                   	pop    %ebp
f01055a2:	c3                   	ret    
f01055a3:	66 90                	xchg   %ax,%ax
f01055a5:	66 90                	xchg   %ax,%ax
f01055a7:	66 90                	xchg   %ax,%ax
f01055a9:	66 90                	xchg   %ax,%ax
f01055ab:	66 90                	xchg   %ax,%ax
f01055ad:	66 90                	xchg   %ax,%ax
f01055af:	90                   	nop

f01055b0 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
f01055b0:	55                   	push   %ebp
f01055b1:	89 e5                	mov    %esp,%ebp
f01055b3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
f01055b6:	b8 00 00 00 00       	mov    $0x0,%eax
f01055bb:	80 3a 00             	cmpb   $0x0,(%edx)
f01055be:	74 09                	je     f01055c9 <strlen+0x19>
		n++;
f01055c0:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f01055c3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
f01055c7:	75 f7                	jne    f01055c0 <strlen+0x10>
		n++;
	return n;
}
f01055c9:	5d                   	pop    %ebp
f01055ca:	c3                   	ret    

f01055cb <strnlen>:

int
strnlen(const char *s, size_t size)
{
f01055cb:	55                   	push   %ebp
f01055cc:	89 e5                	mov    %esp,%ebp
f01055ce:	53                   	push   %ebx
f01055cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
f01055d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01055d5:	85 c9                	test   %ecx,%ecx
f01055d7:	74 19                	je     f01055f2 <strnlen+0x27>
f01055d9:	80 3b 00             	cmpb   $0x0,(%ebx)
f01055dc:	74 14                	je     f01055f2 <strnlen+0x27>
f01055de:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
f01055e3:	83 c0 01             	add    $0x1,%eax
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f01055e6:	39 c8                	cmp    %ecx,%eax
f01055e8:	74 0d                	je     f01055f7 <strnlen+0x2c>
f01055ea:	80 3c 03 00          	cmpb   $0x0,(%ebx,%eax,1)
f01055ee:	75 f3                	jne    f01055e3 <strnlen+0x18>
f01055f0:	eb 05                	jmp    f01055f7 <strnlen+0x2c>
f01055f2:	b8 00 00 00 00       	mov    $0x0,%eax
		n++;
	return n;
}
f01055f7:	5b                   	pop    %ebx
f01055f8:	5d                   	pop    %ebp
f01055f9:	c3                   	ret    

f01055fa <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f01055fa:	55                   	push   %ebp
f01055fb:	89 e5                	mov    %esp,%ebp
f01055fd:	53                   	push   %ebx
f01055fe:	8b 45 08             	mov    0x8(%ebp),%eax
f0105601:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f0105604:	ba 00 00 00 00       	mov    $0x0,%edx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0105609:	0f b6 0c 13          	movzbl (%ebx,%edx,1),%ecx
f010560d:	88 0c 10             	mov    %cl,(%eax,%edx,1)
f0105610:	83 c2 01             	add    $0x1,%edx
f0105613:	84 c9                	test   %cl,%cl
f0105615:	75 f2                	jne    f0105609 <strcpy+0xf>
		/* do nothing */;
	return ret;
}
f0105617:	5b                   	pop    %ebx
f0105618:	5d                   	pop    %ebp
f0105619:	c3                   	ret    

f010561a <strcat>:

char *
strcat(char *dst, const char *src)
{
f010561a:	55                   	push   %ebp
f010561b:	89 e5                	mov    %esp,%ebp
f010561d:	53                   	push   %ebx
f010561e:	83 ec 08             	sub    $0x8,%esp
f0105621:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
f0105624:	89 1c 24             	mov    %ebx,(%esp)
f0105627:	e8 84 ff ff ff       	call   f01055b0 <strlen>
	strcpy(dst + len, src);
f010562c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010562f:	89 54 24 04          	mov    %edx,0x4(%esp)
f0105633:	8d 04 03             	lea    (%ebx,%eax,1),%eax
f0105636:	89 04 24             	mov    %eax,(%esp)
f0105639:	e8 bc ff ff ff       	call   f01055fa <strcpy>
	return dst;
}
f010563e:	89 d8                	mov    %ebx,%eax
f0105640:	83 c4 08             	add    $0x8,%esp
f0105643:	5b                   	pop    %ebx
f0105644:	5d                   	pop    %ebp
f0105645:	c3                   	ret    

f0105646 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0105646:	55                   	push   %ebp
f0105647:	89 e5                	mov    %esp,%ebp
f0105649:	56                   	push   %esi
f010564a:	53                   	push   %ebx
f010564b:	8b 45 08             	mov    0x8(%ebp),%eax
f010564e:	8b 55 0c             	mov    0xc(%ebp),%edx
f0105651:	8b 75 10             	mov    0x10(%ebp),%esi
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105654:	85 f6                	test   %esi,%esi
f0105656:	74 18                	je     f0105670 <strncpy+0x2a>
f0105658:	b9 00 00 00 00       	mov    $0x0,%ecx
		*dst++ = *src;
f010565d:	0f b6 1a             	movzbl (%edx),%ebx
f0105660:	88 1c 08             	mov    %bl,(%eax,%ecx,1)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
f0105663:	80 3a 01             	cmpb   $0x1,(%edx)
f0105666:	83 da ff             	sbb    $0xffffffff,%edx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0105669:	83 c1 01             	add    $0x1,%ecx
f010566c:	39 ce                	cmp    %ecx,%esi
f010566e:	77 ed                	ja     f010565d <strncpy+0x17>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0105670:	5b                   	pop    %ebx
f0105671:	5e                   	pop    %esi
f0105672:	5d                   	pop    %ebp
f0105673:	c3                   	ret    

f0105674 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0105674:	55                   	push   %ebp
f0105675:	89 e5                	mov    %esp,%ebp
f0105677:	56                   	push   %esi
f0105678:	53                   	push   %ebx
f0105679:	8b 75 08             	mov    0x8(%ebp),%esi
f010567c:	8b 55 0c             	mov    0xc(%ebp),%edx
f010567f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0105682:	89 f0                	mov    %esi,%eax
f0105684:	85 c9                	test   %ecx,%ecx
f0105686:	74 27                	je     f01056af <strlcpy+0x3b>
		while (--size > 0 && *src != '\0')
f0105688:	83 e9 01             	sub    $0x1,%ecx
f010568b:	74 1d                	je     f01056aa <strlcpy+0x36>
f010568d:	0f b6 1a             	movzbl (%edx),%ebx
f0105690:	84 db                	test   %bl,%bl
f0105692:	74 16                	je     f01056aa <strlcpy+0x36>
			*dst++ = *src++;
f0105694:	88 18                	mov    %bl,(%eax)
f0105696:	83 c0 01             	add    $0x1,%eax
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0105699:	83 e9 01             	sub    $0x1,%ecx
f010569c:	74 0e                	je     f01056ac <strlcpy+0x38>
			*dst++ = *src++;
f010569e:	83 c2 01             	add    $0x1,%edx
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f01056a1:	0f b6 1a             	movzbl (%edx),%ebx
f01056a4:	84 db                	test   %bl,%bl
f01056a6:	75 ec                	jne    f0105694 <strlcpy+0x20>
f01056a8:	eb 02                	jmp    f01056ac <strlcpy+0x38>
f01056aa:	89 f0                	mov    %esi,%eax
			*dst++ = *src++;
		*dst = '\0';
f01056ac:	c6 00 00             	movb   $0x0,(%eax)
f01056af:	29 f0                	sub    %esi,%eax
	}
	return dst - dst_in;
}
f01056b1:	5b                   	pop    %ebx
f01056b2:	5e                   	pop    %esi
f01056b3:	5d                   	pop    %ebp
f01056b4:	c3                   	ret    

f01056b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f01056b5:	55                   	push   %ebp
f01056b6:	89 e5                	mov    %esp,%ebp
f01056b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
f01056bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
f01056be:	0f b6 01             	movzbl (%ecx),%eax
f01056c1:	84 c0                	test   %al,%al
f01056c3:	74 15                	je     f01056da <strcmp+0x25>
f01056c5:	3a 02                	cmp    (%edx),%al
f01056c7:	75 11                	jne    f01056da <strcmp+0x25>
		p++, q++;
f01056c9:	83 c1 01             	add    $0x1,%ecx
f01056cc:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f01056cf:	0f b6 01             	movzbl (%ecx),%eax
f01056d2:	84 c0                	test   %al,%al
f01056d4:	74 04                	je     f01056da <strcmp+0x25>
f01056d6:	3a 02                	cmp    (%edx),%al
f01056d8:	74 ef                	je     f01056c9 <strcmp+0x14>
f01056da:	0f b6 c0             	movzbl %al,%eax
f01056dd:	0f b6 12             	movzbl (%edx),%edx
f01056e0:	29 d0                	sub    %edx,%eax
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
}
f01056e2:	5d                   	pop    %ebp
f01056e3:	c3                   	ret    

f01056e4 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
f01056e4:	55                   	push   %ebp
f01056e5:	89 e5                	mov    %esp,%ebp
f01056e7:	53                   	push   %ebx
f01056e8:	8b 55 08             	mov    0x8(%ebp),%edx
f01056eb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
f01056ee:	8b 45 10             	mov    0x10(%ebp),%eax
	while (n > 0 && *p && *p == *q)
f01056f1:	85 c0                	test   %eax,%eax
f01056f3:	74 23                	je     f0105718 <strncmp+0x34>
f01056f5:	0f b6 1a             	movzbl (%edx),%ebx
f01056f8:	84 db                	test   %bl,%bl
f01056fa:	74 25                	je     f0105721 <strncmp+0x3d>
f01056fc:	3a 19                	cmp    (%ecx),%bl
f01056fe:	75 21                	jne    f0105721 <strncmp+0x3d>
f0105700:	83 e8 01             	sub    $0x1,%eax
f0105703:	74 13                	je     f0105718 <strncmp+0x34>
		n--, p++, q++;
f0105705:	83 c2 01             	add    $0x1,%edx
f0105708:	83 c1 01             	add    $0x1,%ecx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f010570b:	0f b6 1a             	movzbl (%edx),%ebx
f010570e:	84 db                	test   %bl,%bl
f0105710:	74 0f                	je     f0105721 <strncmp+0x3d>
f0105712:	3a 19                	cmp    (%ecx),%bl
f0105714:	74 ea                	je     f0105700 <strncmp+0x1c>
f0105716:	eb 09                	jmp    f0105721 <strncmp+0x3d>
f0105718:	b8 00 00 00 00       	mov    $0x0,%eax
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
f010571d:	5b                   	pop    %ebx
f010571e:	5d                   	pop    %ebp
f010571f:	90                   	nop
f0105720:	c3                   	ret    
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0105721:	0f b6 02             	movzbl (%edx),%eax
f0105724:	0f b6 11             	movzbl (%ecx),%edx
f0105727:	29 d0                	sub    %edx,%eax
f0105729:	eb f2                	jmp    f010571d <strncmp+0x39>

f010572b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f010572b:	55                   	push   %ebp
f010572c:	89 e5                	mov    %esp,%ebp
f010572e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105731:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105735:	0f b6 10             	movzbl (%eax),%edx
f0105738:	84 d2                	test   %dl,%dl
f010573a:	74 18                	je     f0105754 <strchr+0x29>
		if (*s == c)
f010573c:	38 ca                	cmp    %cl,%dl
f010573e:	75 0a                	jne    f010574a <strchr+0x1f>
f0105740:	eb 17                	jmp    f0105759 <strchr+0x2e>
f0105742:	38 ca                	cmp    %cl,%dl
f0105744:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105748:	74 0f                	je     f0105759 <strchr+0x2e>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f010574a:	83 c0 01             	add    $0x1,%eax
f010574d:	0f b6 10             	movzbl (%eax),%edx
f0105750:	84 d2                	test   %dl,%dl
f0105752:	75 ee                	jne    f0105742 <strchr+0x17>
f0105754:	b8 00 00 00 00       	mov    $0x0,%eax
		if (*s == c)
			return (char *) s;
	return 0;
}
f0105759:	5d                   	pop    %ebp
f010575a:	c3                   	ret    

f010575b <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f010575b:	55                   	push   %ebp
f010575c:	89 e5                	mov    %esp,%ebp
f010575e:	8b 45 08             	mov    0x8(%ebp),%eax
f0105761:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
f0105765:	0f b6 10             	movzbl (%eax),%edx
f0105768:	84 d2                	test   %dl,%dl
f010576a:	74 18                	je     f0105784 <strfind+0x29>
		if (*s == c)
f010576c:	38 ca                	cmp    %cl,%dl
f010576e:	75 0a                	jne    f010577a <strfind+0x1f>
f0105770:	eb 12                	jmp    f0105784 <strfind+0x29>
f0105772:	38 ca                	cmp    %cl,%dl
f0105774:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0105778:	74 0a                	je     f0105784 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f010577a:	83 c0 01             	add    $0x1,%eax
f010577d:	0f b6 10             	movzbl (%eax),%edx
f0105780:	84 d2                	test   %dl,%dl
f0105782:	75 ee                	jne    f0105772 <strfind+0x17>
		if (*s == c)
			break;
	return (char *) s;
}
f0105784:	5d                   	pop    %ebp
f0105785:	c3                   	ret    

f0105786 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
f0105786:	55                   	push   %ebp
f0105787:	89 e5                	mov    %esp,%ebp
f0105789:	83 ec 0c             	sub    $0xc,%esp
f010578c:	89 1c 24             	mov    %ebx,(%esp)
f010578f:	89 74 24 04          	mov    %esi,0x4(%esp)
f0105793:	89 7c 24 08          	mov    %edi,0x8(%esp)
f0105797:	8b 7d 08             	mov    0x8(%ebp),%edi
f010579a:	8b 45 0c             	mov    0xc(%ebp),%eax
f010579d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
f01057a0:	85 c9                	test   %ecx,%ecx
f01057a2:	74 30                	je     f01057d4 <memset+0x4e>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01057a4:	f7 c7 03 00 00 00    	test   $0x3,%edi
f01057aa:	75 25                	jne    f01057d1 <memset+0x4b>
f01057ac:	f6 c1 03             	test   $0x3,%cl
f01057af:	75 20                	jne    f01057d1 <memset+0x4b>
		c &= 0xFF;
f01057b1:	0f b6 d0             	movzbl %al,%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
f01057b4:	89 d3                	mov    %edx,%ebx
f01057b6:	c1 e3 08             	shl    $0x8,%ebx
f01057b9:	89 d6                	mov    %edx,%esi
f01057bb:	c1 e6 18             	shl    $0x18,%esi
f01057be:	89 d0                	mov    %edx,%eax
f01057c0:	c1 e0 10             	shl    $0x10,%eax
f01057c3:	09 f0                	or     %esi,%eax
f01057c5:	09 d0                	or     %edx,%eax
		asm volatile("cld; rep stosl\n"
f01057c7:	09 d8                	or     %ebx,%eax
f01057c9:	c1 e9 02             	shr    $0x2,%ecx
f01057cc:	fc                   	cld    
f01057cd:	f3 ab                	rep stos %eax,%es:(%edi)
{
	char *p;

	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
f01057cf:	eb 03                	jmp    f01057d4 <memset+0x4e>
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
f01057d1:	fc                   	cld    
f01057d2:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
f01057d4:	89 f8                	mov    %edi,%eax
f01057d6:	8b 1c 24             	mov    (%esp),%ebx
f01057d9:	8b 74 24 04          	mov    0x4(%esp),%esi
f01057dd:	8b 7c 24 08          	mov    0x8(%esp),%edi
f01057e1:	89 ec                	mov    %ebp,%esp
f01057e3:	5d                   	pop    %ebp
f01057e4:	c3                   	ret    

f01057e5 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f01057e5:	55                   	push   %ebp
f01057e6:	89 e5                	mov    %esp,%ebp
f01057e8:	83 ec 08             	sub    $0x8,%esp
f01057eb:	89 34 24             	mov    %esi,(%esp)
f01057ee:	89 7c 24 04          	mov    %edi,0x4(%esp)
f01057f2:	8b 45 08             	mov    0x8(%ebp),%eax
f01057f5:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
f01057f8:	8b 75 0c             	mov    0xc(%ebp),%esi
	d = dst;
f01057fb:	89 c7                	mov    %eax,%edi
	if (s < d && s + n > d) {
f01057fd:	39 c6                	cmp    %eax,%esi
f01057ff:	73 35                	jae    f0105836 <memmove+0x51>
f0105801:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
f0105804:	39 d0                	cmp    %edx,%eax
f0105806:	73 2e                	jae    f0105836 <memmove+0x51>
		s += n;
		d += n;
f0105808:	01 cf                	add    %ecx,%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f010580a:	f6 c2 03             	test   $0x3,%dl
f010580d:	75 1b                	jne    f010582a <memmove+0x45>
f010580f:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105815:	75 13                	jne    f010582a <memmove+0x45>
f0105817:	f6 c1 03             	test   $0x3,%cl
f010581a:	75 0e                	jne    f010582a <memmove+0x45>
			asm volatile("std; rep movsl\n"
f010581c:	83 ef 04             	sub    $0x4,%edi
f010581f:	8d 72 fc             	lea    -0x4(%edx),%esi
f0105822:	c1 e9 02             	shr    $0x2,%ecx
f0105825:	fd                   	std    
f0105826:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105828:	eb 09                	jmp    f0105833 <memmove+0x4e>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
f010582a:	83 ef 01             	sub    $0x1,%edi
f010582d:	8d 72 ff             	lea    -0x1(%edx),%esi
f0105830:	fd                   	std    
f0105831:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
f0105833:	fc                   	cld    
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0105834:	eb 20                	jmp    f0105856 <memmove+0x71>
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105836:	f7 c6 03 00 00 00    	test   $0x3,%esi
f010583c:	75 15                	jne    f0105853 <memmove+0x6e>
f010583e:	f7 c7 03 00 00 00    	test   $0x3,%edi
f0105844:	75 0d                	jne    f0105853 <memmove+0x6e>
f0105846:	f6 c1 03             	test   $0x3,%cl
f0105849:	75 08                	jne    f0105853 <memmove+0x6e>
			asm volatile("cld; rep movsl\n"
f010584b:	c1 e9 02             	shr    $0x2,%ecx
f010584e:	fc                   	cld    
f010584f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
f0105851:	eb 03                	jmp    f0105856 <memmove+0x71>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
f0105853:	fc                   	cld    
f0105854:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
f0105856:	8b 34 24             	mov    (%esp),%esi
f0105859:	8b 7c 24 04          	mov    0x4(%esp),%edi
f010585d:	89 ec                	mov    %ebp,%esp
f010585f:	5d                   	pop    %ebp
f0105860:	c3                   	ret    

f0105861 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
f0105861:	55                   	push   %ebp
f0105862:	89 e5                	mov    %esp,%ebp
f0105864:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
f0105867:	8b 45 10             	mov    0x10(%ebp),%eax
f010586a:	89 44 24 08          	mov    %eax,0x8(%esp)
f010586e:	8b 45 0c             	mov    0xc(%ebp),%eax
f0105871:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105875:	8b 45 08             	mov    0x8(%ebp),%eax
f0105878:	89 04 24             	mov    %eax,(%esp)
f010587b:	e8 65 ff ff ff       	call   f01057e5 <memmove>
}
f0105880:	c9                   	leave  
f0105881:	c3                   	ret    

f0105882 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0105882:	55                   	push   %ebp
f0105883:	89 e5                	mov    %esp,%ebp
f0105885:	57                   	push   %edi
f0105886:	56                   	push   %esi
f0105887:	53                   	push   %ebx
f0105888:	8b 75 08             	mov    0x8(%ebp),%esi
f010588b:	8b 7d 0c             	mov    0xc(%ebp),%edi
f010588e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0105891:	85 c9                	test   %ecx,%ecx
f0105893:	74 36                	je     f01058cb <memcmp+0x49>
		if (*s1 != *s2)
f0105895:	0f b6 06             	movzbl (%esi),%eax
f0105898:	0f b6 1f             	movzbl (%edi),%ebx
f010589b:	38 d8                	cmp    %bl,%al
f010589d:	74 20                	je     f01058bf <memcmp+0x3d>
f010589f:	eb 14                	jmp    f01058b5 <memcmp+0x33>
f01058a1:	0f b6 44 16 01       	movzbl 0x1(%esi,%edx,1),%eax
f01058a6:	0f b6 5c 17 01       	movzbl 0x1(%edi,%edx,1),%ebx
f01058ab:	83 c2 01             	add    $0x1,%edx
f01058ae:	83 e9 01             	sub    $0x1,%ecx
f01058b1:	38 d8                	cmp    %bl,%al
f01058b3:	74 12                	je     f01058c7 <memcmp+0x45>
			return (int) *s1 - (int) *s2;
f01058b5:	0f b6 c0             	movzbl %al,%eax
f01058b8:	0f b6 db             	movzbl %bl,%ebx
f01058bb:	29 d8                	sub    %ebx,%eax
f01058bd:	eb 11                	jmp    f01058d0 <memcmp+0x4e>
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f01058bf:	83 e9 01             	sub    $0x1,%ecx
f01058c2:	ba 00 00 00 00       	mov    $0x0,%edx
f01058c7:	85 c9                	test   %ecx,%ecx
f01058c9:	75 d6                	jne    f01058a1 <memcmp+0x1f>
f01058cb:	b8 00 00 00 00       	mov    $0x0,%eax
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
}
f01058d0:	5b                   	pop    %ebx
f01058d1:	5e                   	pop    %esi
f01058d2:	5f                   	pop    %edi
f01058d3:	5d                   	pop    %ebp
f01058d4:	c3                   	ret    

f01058d5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
f01058d5:	55                   	push   %ebp
f01058d6:	89 e5                	mov    %esp,%ebp
f01058d8:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
f01058db:	89 c2                	mov    %eax,%edx
f01058dd:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
f01058e0:	39 d0                	cmp    %edx,%eax
f01058e2:	73 15                	jae    f01058f9 <memfind+0x24>
		if (*(const unsigned char *) s == (unsigned char) c)
f01058e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
f01058e8:	38 08                	cmp    %cl,(%eax)
f01058ea:	75 06                	jne    f01058f2 <memfind+0x1d>
f01058ec:	eb 0b                	jmp    f01058f9 <memfind+0x24>
f01058ee:	38 08                	cmp    %cl,(%eax)
f01058f0:	74 07                	je     f01058f9 <memfind+0x24>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f01058f2:	83 c0 01             	add    $0x1,%eax
f01058f5:	39 c2                	cmp    %eax,%edx
f01058f7:	77 f5                	ja     f01058ee <memfind+0x19>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f01058f9:	5d                   	pop    %ebp
f01058fa:	c3                   	ret    

f01058fb <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f01058fb:	55                   	push   %ebp
f01058fc:	89 e5                	mov    %esp,%ebp
f01058fe:	57                   	push   %edi
f01058ff:	56                   	push   %esi
f0105900:	53                   	push   %ebx
f0105901:	83 ec 04             	sub    $0x4,%esp
f0105904:	8b 55 08             	mov    0x8(%ebp),%edx
f0105907:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010590a:	0f b6 02             	movzbl (%edx),%eax
f010590d:	3c 20                	cmp    $0x20,%al
f010590f:	74 04                	je     f0105915 <strtol+0x1a>
f0105911:	3c 09                	cmp    $0x9,%al
f0105913:	75 0e                	jne    f0105923 <strtol+0x28>
		s++;
f0105915:	83 c2 01             	add    $0x1,%edx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f0105918:	0f b6 02             	movzbl (%edx),%eax
f010591b:	3c 20                	cmp    $0x20,%al
f010591d:	74 f6                	je     f0105915 <strtol+0x1a>
f010591f:	3c 09                	cmp    $0x9,%al
f0105921:	74 f2                	je     f0105915 <strtol+0x1a>
		s++;

	// plus/minus sign
	if (*s == '+')
f0105923:	3c 2b                	cmp    $0x2b,%al
f0105925:	75 0c                	jne    f0105933 <strtol+0x38>
		s++;
f0105927:	83 c2 01             	add    $0x1,%edx
f010592a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f0105931:	eb 15                	jmp    f0105948 <strtol+0x4d>
	else if (*s == '-')
f0105933:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
f010593a:	3c 2d                	cmp    $0x2d,%al
f010593c:	75 0a                	jne    f0105948 <strtol+0x4d>
		s++, neg = 1;
f010593e:	83 c2 01             	add    $0x1,%edx
f0105941:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f0105948:	85 db                	test   %ebx,%ebx
f010594a:	0f 94 c0             	sete   %al
f010594d:	74 05                	je     f0105954 <strtol+0x59>
f010594f:	83 fb 10             	cmp    $0x10,%ebx
f0105952:	75 18                	jne    f010596c <strtol+0x71>
f0105954:	80 3a 30             	cmpb   $0x30,(%edx)
f0105957:	75 13                	jne    f010596c <strtol+0x71>
f0105959:	80 7a 01 78          	cmpb   $0x78,0x1(%edx)
f010595d:	8d 76 00             	lea    0x0(%esi),%esi
f0105960:	75 0a                	jne    f010596c <strtol+0x71>
		s += 2, base = 16;
f0105962:	83 c2 02             	add    $0x2,%edx
f0105965:	bb 10 00 00 00       	mov    $0x10,%ebx
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010596a:	eb 15                	jmp    f0105981 <strtol+0x86>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f010596c:	84 c0                	test   %al,%al
f010596e:	66 90                	xchg   %ax,%ax
f0105970:	74 0f                	je     f0105981 <strtol+0x86>
f0105972:	bb 0a 00 00 00       	mov    $0xa,%ebx
f0105977:	80 3a 30             	cmpb   $0x30,(%edx)
f010597a:	75 05                	jne    f0105981 <strtol+0x86>
		s++, base = 8;
f010597c:	83 c2 01             	add    $0x1,%edx
f010597f:	b3 08                	mov    $0x8,%bl
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0105981:	b8 00 00 00 00       	mov    $0x0,%eax
f0105986:	89 de                	mov    %ebx,%esi

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f0105988:	0f b6 0a             	movzbl (%edx),%ecx
f010598b:	89 cf                	mov    %ecx,%edi
f010598d:	8d 59 d0             	lea    -0x30(%ecx),%ebx
f0105990:	80 fb 09             	cmp    $0x9,%bl
f0105993:	77 08                	ja     f010599d <strtol+0xa2>
			dig = *s - '0';
f0105995:	0f be c9             	movsbl %cl,%ecx
f0105998:	83 e9 30             	sub    $0x30,%ecx
f010599b:	eb 1e                	jmp    f01059bb <strtol+0xc0>
		else if (*s >= 'a' && *s <= 'z')
f010599d:	8d 5f 9f             	lea    -0x61(%edi),%ebx
f01059a0:	80 fb 19             	cmp    $0x19,%bl
f01059a3:	77 08                	ja     f01059ad <strtol+0xb2>
			dig = *s - 'a' + 10;
f01059a5:	0f be c9             	movsbl %cl,%ecx
f01059a8:	83 e9 57             	sub    $0x57,%ecx
f01059ab:	eb 0e                	jmp    f01059bb <strtol+0xc0>
		else if (*s >= 'A' && *s <= 'Z')
f01059ad:	8d 5f bf             	lea    -0x41(%edi),%ebx
f01059b0:	80 fb 19             	cmp    $0x19,%bl
f01059b3:	77 15                	ja     f01059ca <strtol+0xcf>
			dig = *s - 'A' + 10;
f01059b5:	0f be c9             	movsbl %cl,%ecx
f01059b8:	83 e9 37             	sub    $0x37,%ecx
		else
			break;
		if (dig >= base)
f01059bb:	39 f1                	cmp    %esi,%ecx
f01059bd:	7d 0b                	jge    f01059ca <strtol+0xcf>
			break;
		s++, val = (val * base) + dig;
f01059bf:	83 c2 01             	add    $0x1,%edx
f01059c2:	0f af c6             	imul   %esi,%eax
f01059c5:	8d 04 01             	lea    (%ecx,%eax,1),%eax
		// we don't properly detect overflow!
	}
f01059c8:	eb be                	jmp    f0105988 <strtol+0x8d>
f01059ca:	89 c1                	mov    %eax,%ecx

	if (endptr)
f01059cc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
f01059d0:	74 05                	je     f01059d7 <strtol+0xdc>
		*endptr = (char *) s;
f01059d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
f01059d5:	89 13                	mov    %edx,(%ebx)
	return (neg ? -val : val);
f01059d7:	89 ca                	mov    %ecx,%edx
f01059d9:	f7 da                	neg    %edx
f01059db:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
f01059df:	0f 45 c2             	cmovne %edx,%eax
}
f01059e2:	83 c4 04             	add    $0x4,%esp
f01059e5:	5b                   	pop    %ebx
f01059e6:	5e                   	pop    %esi
f01059e7:	5f                   	pop    %edi
f01059e8:	5d                   	pop    %ebp
f01059e9:	c3                   	ret    
f01059ea:	66 90                	xchg   %ax,%ax

f01059ec <mpentry_start>:
.set PROT_MODE_DSEG, 0x10	# kernel data segment selector

.code16           
.globl mpentry_start
mpentry_start:
	cli            
f01059ec:	fa                   	cli    

	xorw    %ax, %ax
f01059ed:	31 c0                	xor    %eax,%eax
	movw    %ax, %ds
f01059ef:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f01059f1:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f01059f3:	8e d0                	mov    %eax,%ss

	lgdt    MPBOOTPHYS(gdtdesc)
f01059f5:	0f 01 16             	lgdtl  (%esi)
f01059f8:	74 70                	je     f0105a6a <mpentry_end+0x4>
	movl    %cr0, %eax
f01059fa:	0f 20 c0             	mov    %cr0,%eax
	orl     $CR0_PE, %eax
f01059fd:	66 83 c8 01          	or     $0x1,%ax
	movl    %eax, %cr0
f0105a01:	0f 22 c0             	mov    %eax,%cr0

	ljmpl   $(PROT_MODE_CSEG), $(MPBOOTPHYS(start32))
f0105a04:	66 ea 20 70 00 00    	ljmpw  $0x0,$0x7020
f0105a0a:	08 00                	or     %al,(%eax)

f0105a0c <start32>:

.code32
start32:
	movw    $(PROT_MODE_DSEG), %ax
f0105a0c:	66 b8 10 00          	mov    $0x10,%ax
	movw    %ax, %ds
f0105a10:	8e d8                	mov    %eax,%ds
	movw    %ax, %es
f0105a12:	8e c0                	mov    %eax,%es
	movw    %ax, %ss
f0105a14:	8e d0                	mov    %eax,%ss
	movw    $0, %ax
f0105a16:	66 b8 00 00          	mov    $0x0,%ax
	movw    %ax, %fs
f0105a1a:	8e e0                	mov    %eax,%fs
	movw    %ax, %gs
f0105a1c:	8e e8                	mov    %eax,%gs

	# Set up initial page table. We cannot use kern_pgdir yet because
	# we are still running at a low EIP.
	movl    $(RELOC(entry_pgdir)), %eax
f0105a1e:	b8 00 e0 11 00       	mov    $0x11e000,%eax
	movl    %eax, %cr3
f0105a23:	0f 22 d8             	mov    %eax,%cr3
	# Turn on paging.
	movl    %cr0, %eax
f0105a26:	0f 20 c0             	mov    %cr0,%eax
	orl     $(CR0_PE|CR0_PG|CR0_WP), %eax
f0105a29:	0d 01 00 01 80       	or     $0x80010001,%eax
	movl    %eax, %cr0
f0105a2e:	0f 22 c0             	mov    %eax,%cr0

	# Switch to the per-cpu stack allocated in boot_aps()
	movl    mpentry_kstack, %esp
f0105a31:	8b 25 e4 3e 22 f0    	mov    0xf0223ee4,%esp
	movl    $0x0, %ebp       # nuke frame pointer
f0105a37:	bd 00 00 00 00       	mov    $0x0,%ebp

	# Call mp_main().  (Exercise for the reader: why the indirect call?)
	movl    $mp_main, %eax
f0105a3c:	b8 ed 00 10 f0       	mov    $0xf01000ed,%eax
	call    *%eax
f0105a41:	ff d0                	call   *%eax

f0105a43 <spin>:

	# If mp_main returns (it shouldn't), loop.
spin:
	jmp     spin
f0105a43:	eb fe                	jmp    f0105a43 <spin>
f0105a45:	8d 76 00             	lea    0x0(%esi),%esi

f0105a48 <gdt>:
	...
f0105a50:	ff                   	(bad)  
f0105a51:	ff 00                	incl   (%eax)
f0105a53:	00 00                	add    %al,(%eax)
f0105a55:	9a cf 00 ff ff 00 00 	lcall  $0x0,$0xffff00cf
f0105a5c:	00 92 cf 00 17 00    	add    %dl,0x1700cf(%edx)

f0105a60 <gdtdesc>:
f0105a60:	17                   	pop    %ss
f0105a61:	00 5c 70 00          	add    %bl,0x0(%eax,%esi,2)
	...

f0105a66 <mpentry_end>:
	.word   0x17				# sizeof(gdt) - 1
	.long   MPBOOTPHYS(gdt)			# address gdt

.globl mpentry_end
mpentry_end:
	nop
f0105a66:	90                   	nop
f0105a67:	66 90                	xchg   %ax,%ax
f0105a69:	66 90                	xchg   %ax,%ax
f0105a6b:	66 90                	xchg   %ax,%ax
f0105a6d:	66 90                	xchg   %ax,%ax
f0105a6f:	90                   	nop

f0105a70 <sum>:
#define MPIOINTR  0x03  // One per bus interrupt source
#define MPLINTR   0x04  // One per system interrupt source

static uint8_t
sum(void *addr, int len)
{
f0105a70:	55                   	push   %ebp
f0105a71:	89 e5                	mov    %esp,%ebp
f0105a73:	56                   	push   %esi
f0105a74:	53                   	push   %ebx
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a75:	bb 00 00 00 00       	mov    $0x0,%ebx
f0105a7a:	b9 00 00 00 00       	mov    $0x0,%ecx
f0105a7f:	85 d2                	test   %edx,%edx
f0105a81:	7e 0d                	jle    f0105a90 <sum+0x20>
		sum += ((uint8_t *)addr)[i];
f0105a83:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
f0105a87:	01 f3                	add    %esi,%ebx
sum(void *addr, int len)
{
	int i, sum;

	sum = 0;
	for (i = 0; i < len; i++)
f0105a89:	83 c1 01             	add    $0x1,%ecx
f0105a8c:	39 d1                	cmp    %edx,%ecx
f0105a8e:	75 f3                	jne    f0105a83 <sum+0x13>
		sum += ((uint8_t *)addr)[i];
	return sum;
}
f0105a90:	89 d8                	mov    %ebx,%eax
f0105a92:	5b                   	pop    %ebx
f0105a93:	5e                   	pop    %esi
f0105a94:	5d                   	pop    %ebp
f0105a95:	c3                   	ret    

f0105a96 <mpsearch1>:

// Look for an MP structure in the len bytes at physical address addr.
static struct mp *
mpsearch1(physaddr_t a, int len)
{
f0105a96:	55                   	push   %ebp
f0105a97:	89 e5                	mov    %esp,%ebp
f0105a99:	56                   	push   %esi
f0105a9a:	53                   	push   %ebx
f0105a9b:	83 ec 10             	sub    $0x10,%esp
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105a9e:	8b 0d e8 3e 22 f0    	mov    0xf0223ee8,%ecx
f0105aa4:	89 c3                	mov    %eax,%ebx
f0105aa6:	c1 eb 0c             	shr    $0xc,%ebx
f0105aa9:	39 cb                	cmp    %ecx,%ebx
f0105aab:	72 20                	jb     f0105acd <mpsearch1+0x37>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105aad:	89 44 24 0c          	mov    %eax,0xc(%esp)
f0105ab1:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f0105ab8:	f0 
f0105ab9:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0105ac0:	00 
f0105ac1:	c7 04 24 61 7f 10 f0 	movl   $0xf0107f61,(%esp)
f0105ac8:	e8 b8 a5 ff ff       	call   f0100085 <_panic>
	struct mp *mp = KADDR(a), *end = KADDR(a + len);
f0105acd:	8d 34 02             	lea    (%edx,%eax,1),%esi
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105ad0:	89 f2                	mov    %esi,%edx
f0105ad2:	c1 ea 0c             	shr    $0xc,%edx
f0105ad5:	39 d1                	cmp    %edx,%ecx
f0105ad7:	77 20                	ja     f0105af9 <mpsearch1+0x63>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105ad9:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0105add:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f0105ae4:	f0 
f0105ae5:	c7 44 24 04 57 00 00 	movl   $0x57,0x4(%esp)
f0105aec:	00 
f0105aed:	c7 04 24 61 7f 10 f0 	movl   $0xf0107f61,(%esp)
f0105af4:	e8 8c a5 ff ff       	call   f0100085 <_panic>
f0105af9:	8d 98 00 00 00 f0    	lea    -0x10000000(%eax),%ebx
f0105aff:	81 ee 00 00 00 10    	sub    $0x10000000,%esi

	for (; mp < end; mp++)
f0105b05:	39 f3                	cmp    %esi,%ebx
f0105b07:	73 33                	jae    f0105b3c <mpsearch1+0xa6>
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105b09:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0105b10:	00 
f0105b11:	c7 44 24 04 71 7f 10 	movl   $0xf0107f71,0x4(%esp)
f0105b18:	f0 
f0105b19:	89 1c 24             	mov    %ebx,(%esp)
f0105b1c:	e8 61 fd ff ff       	call   f0105882 <memcmp>
f0105b21:	85 c0                	test   %eax,%eax
f0105b23:	75 10                	jne    f0105b35 <mpsearch1+0x9f>
		    sum(mp, sizeof(*mp)) == 0)
f0105b25:	ba 10 00 00 00       	mov    $0x10,%edx
f0105b2a:	89 d8                	mov    %ebx,%eax
f0105b2c:	e8 3f ff ff ff       	call   f0105a70 <sum>
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
f0105b31:	84 c0                	test   %al,%al
f0105b33:	74 0c                	je     f0105b41 <mpsearch1+0xab>
static struct mp *
mpsearch1(physaddr_t a, int len)
{
	struct mp *mp = KADDR(a), *end = KADDR(a + len);

	for (; mp < end; mp++)
f0105b35:	83 c3 10             	add    $0x10,%ebx
f0105b38:	39 de                	cmp    %ebx,%esi
f0105b3a:	77 cd                	ja     f0105b09 <mpsearch1+0x73>
f0105b3c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (memcmp(mp->signature, "_MP_", 4) == 0 &&
		    sum(mp, sizeof(*mp)) == 0)
			return mp;
	return NULL;
}
f0105b41:	89 d8                	mov    %ebx,%eax
f0105b43:	83 c4 10             	add    $0x10,%esp
f0105b46:	5b                   	pop    %ebx
f0105b47:	5e                   	pop    %esi
f0105b48:	5d                   	pop    %ebp
f0105b49:	c3                   	ret    

f0105b4a <mp_init>:
	return conf;
}

void
mp_init(void)
{
f0105b4a:	55                   	push   %ebp
f0105b4b:	89 e5                	mov    %esp,%ebp
f0105b4d:	57                   	push   %edi
f0105b4e:	56                   	push   %esi
f0105b4f:	53                   	push   %ebx
f0105b50:	83 ec 2c             	sub    $0x2c,%esp
	struct mpconf *conf;
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
f0105b53:	c7 05 c0 43 22 f0 20 	movl   $0xf0224020,0xf02243c0
f0105b5a:	40 22 f0 
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105b5d:	83 3d e8 3e 22 f0 00 	cmpl   $0x0,0xf0223ee8
f0105b64:	75 24                	jne    f0105b8a <mp_init+0x40>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105b66:	c7 44 24 0c 00 04 00 	movl   $0x400,0xc(%esp)
f0105b6d:	00 
f0105b6e:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f0105b75:	f0 
f0105b76:	c7 44 24 04 6f 00 00 	movl   $0x6f,0x4(%esp)
f0105b7d:	00 
f0105b7e:	c7 04 24 61 7f 10 f0 	movl   $0xf0107f61,(%esp)
f0105b85:	e8 fb a4 ff ff       	call   f0100085 <_panic>
	// The BIOS data area lives in 16-bit segment 0x40.
	bda = (uint8_t *) KADDR(0x40 << 4);

	// [MP 4] The 16-bit segment of the EBDA is in the two bytes
	// starting at byte 0x0E of the BDA.  0 if not present.
	if ((p = *(uint16_t *) (bda + 0x0E))) {
f0105b8a:	0f b7 05 0e 04 00 f0 	movzwl 0xf000040e,%eax
f0105b91:	85 c0                	test   %eax,%eax
f0105b93:	74 16                	je     f0105bab <mp_init+0x61>
		p <<= 4;	// Translate from segment to PA
		if ((mp = mpsearch1(p, 1024)))
f0105b95:	c1 e0 04             	shl    $0x4,%eax
f0105b98:	ba 00 04 00 00       	mov    $0x400,%edx
f0105b9d:	e8 f4 fe ff ff       	call   f0105a96 <mpsearch1>
f0105ba2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105ba5:	85 c0                	test   %eax,%eax
f0105ba7:	75 3c                	jne    f0105be5 <mp_init+0x9b>
f0105ba9:	eb 20                	jmp    f0105bcb <mp_init+0x81>
			return mp;
	} else {
		// The size of base memory, in KB is in the two bytes
		// starting at 0x13 of the BDA.
		p = *(uint16_t *) (bda + 0x13) * 1024;
		if ((mp = mpsearch1(p - 1024, 1024)))
f0105bab:	0f b7 05 13 04 00 f0 	movzwl 0xf0000413,%eax
f0105bb2:	c1 e0 0a             	shl    $0xa,%eax
f0105bb5:	2d 00 04 00 00       	sub    $0x400,%eax
f0105bba:	ba 00 04 00 00       	mov    $0x400,%edx
f0105bbf:	e8 d2 fe ff ff       	call   f0105a96 <mpsearch1>
f0105bc4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
f0105bc7:	85 c0                	test   %eax,%eax
f0105bc9:	75 1a                	jne    f0105be5 <mp_init+0x9b>
			return mp;
	}
	return mpsearch1(0xF0000, 0x10000);
f0105bcb:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105bd0:	b8 00 00 0f 00       	mov    $0xf0000,%eax
f0105bd5:	e8 bc fe ff ff       	call   f0105a96 <mpsearch1>
f0105bda:	89 45 e4             	mov    %eax,-0x1c(%ebp)
mpconfig(struct mp **pmp)
{
	struct mpconf *conf;
	struct mp *mp;

	if ((mp = mpsearch()) == 0)
f0105bdd:	85 c0                	test   %eax,%eax
f0105bdf:	0f 84 28 02 00 00    	je     f0105e0d <mp_init+0x2c3>
		return NULL;
	if (mp->physaddr == 0 || mp->type != 0) {
f0105be5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105be8:	8b 78 04             	mov    0x4(%eax),%edi
f0105beb:	85 ff                	test   %edi,%edi
f0105bed:	74 06                	je     f0105bf5 <mp_init+0xab>
f0105bef:	80 78 0b 00          	cmpb   $0x0,0xb(%eax)
f0105bf3:	74 11                	je     f0105c06 <mp_init+0xbc>
		cprintf("SMP: Default configurations not implemented\n");
f0105bf5:	c7 04 24 d4 7d 10 f0 	movl   $0xf0107dd4,(%esp)
f0105bfc:	e8 28 e3 ff ff       	call   f0103f29 <cprintf>
f0105c01:	e9 07 02 00 00       	jmp    f0105e0d <mp_init+0x2c3>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105c06:	89 f8                	mov    %edi,%eax
f0105c08:	c1 e8 0c             	shr    $0xc,%eax
f0105c0b:	3b 05 e8 3e 22 f0    	cmp    0xf0223ee8,%eax
f0105c11:	72 20                	jb     f0105c33 <mp_init+0xe9>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105c13:	89 7c 24 0c          	mov    %edi,0xc(%esp)
f0105c17:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f0105c1e:	f0 
f0105c1f:	c7 44 24 04 90 00 00 	movl   $0x90,0x4(%esp)
f0105c26:	00 
f0105c27:	c7 04 24 61 7f 10 f0 	movl   $0xf0107f61,(%esp)
f0105c2e:	e8 52 a4 ff ff       	call   f0100085 <_panic>
		return NULL;
	}
	conf = (struct mpconf *) KADDR(mp->physaddr);
f0105c33:	81 ef 00 00 00 10    	sub    $0x10000000,%edi
	if (memcmp(conf, "PCMP", 4) != 0) {
f0105c39:	c7 44 24 08 04 00 00 	movl   $0x4,0x8(%esp)
f0105c40:	00 
f0105c41:	c7 44 24 04 76 7f 10 	movl   $0xf0107f76,0x4(%esp)
f0105c48:	f0 
f0105c49:	89 3c 24             	mov    %edi,(%esp)
f0105c4c:	e8 31 fc ff ff       	call   f0105882 <memcmp>
f0105c51:	85 c0                	test   %eax,%eax
f0105c53:	74 11                	je     f0105c66 <mp_init+0x11c>
		cprintf("SMP: Incorrect MP configuration table signature\n");
f0105c55:	c7 04 24 04 7e 10 f0 	movl   $0xf0107e04,(%esp)
f0105c5c:	e8 c8 e2 ff ff       	call   f0103f29 <cprintf>
f0105c61:	e9 a7 01 00 00       	jmp    f0105e0d <mp_init+0x2c3>
		return NULL;
	}
	if (sum(conf, conf->length) != 0) {
f0105c66:	0f b7 57 04          	movzwl 0x4(%edi),%edx
f0105c6a:	89 f8                	mov    %edi,%eax
f0105c6c:	e8 ff fd ff ff       	call   f0105a70 <sum>
f0105c71:	84 c0                	test   %al,%al
f0105c73:	74 11                	je     f0105c86 <mp_init+0x13c>
		cprintf("SMP: Bad MP configuration checksum\n");
f0105c75:	c7 04 24 38 7e 10 f0 	movl   $0xf0107e38,(%esp)
f0105c7c:	e8 a8 e2 ff ff       	call   f0103f29 <cprintf>
f0105c81:	e9 87 01 00 00       	jmp    f0105e0d <mp_init+0x2c3>
		return NULL;
	}
	if (conf->version != 1 && conf->version != 4) {
f0105c86:	0f b6 47 06          	movzbl 0x6(%edi),%eax
f0105c8a:	3c 01                	cmp    $0x1,%al
f0105c8c:	74 1c                	je     f0105caa <mp_init+0x160>
f0105c8e:	3c 04                	cmp    $0x4,%al
f0105c90:	74 18                	je     f0105caa <mp_init+0x160>
		cprintf("SMP: Unsupported MP version %d\n", conf->version);
f0105c92:	0f b6 c0             	movzbl %al,%eax
f0105c95:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105c99:	c7 04 24 5c 7e 10 f0 	movl   $0xf0107e5c,(%esp)
f0105ca0:	e8 84 e2 ff ff       	call   f0103f29 <cprintf>
f0105ca5:	e9 63 01 00 00       	jmp    f0105e0d <mp_init+0x2c3>
		return NULL;
	}
	if (sum((uint8_t *)conf + conf->length, conf->xlength) != conf->xchecksum) {
f0105caa:	0f b7 57 28          	movzwl 0x28(%edi),%edx
f0105cae:	0f b7 47 04          	movzwl 0x4(%edi),%eax
f0105cb2:	8d 04 07             	lea    (%edi,%eax,1),%eax
f0105cb5:	e8 b6 fd ff ff       	call   f0105a70 <sum>
f0105cba:	3a 47 2a             	cmp    0x2a(%edi),%al
f0105cbd:	74 11                	je     f0105cd0 <mp_init+0x186>
		cprintf("SMP: Bad MP configuration extended checksum\n");
f0105cbf:	c7 04 24 7c 7e 10 f0 	movl   $0xf0107e7c,(%esp)
f0105cc6:	e8 5e e2 ff ff       	call   f0103f29 <cprintf>
f0105ccb:	e9 3d 01 00 00       	jmp    f0105e0d <mp_init+0x2c3>
	struct mpproc *proc;
	uint8_t *p;
	unsigned int i;

	bootcpu = &cpus[0];
	if ((conf = mpconfig(&mp)) == 0)
f0105cd0:	85 ff                	test   %edi,%edi
f0105cd2:	0f 84 35 01 00 00    	je     f0105e0d <mp_init+0x2c3>
		return;
	ismp = 1;
f0105cd8:	c7 05 00 40 22 f0 01 	movl   $0x1,0xf0224000
f0105cdf:	00 00 00 
	lapicaddr = conf->lapicaddr;
f0105ce2:	8b 47 24             	mov    0x24(%edi),%eax
f0105ce5:	a3 00 50 26 f0       	mov    %eax,0xf0265000

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105cea:	8d 5f 2c             	lea    0x2c(%edi),%ebx
f0105ced:	66 83 7f 22 00       	cmpw   $0x0,0x22(%edi)
f0105cf2:	0f 84 96 00 00 00    	je     f0105d8e <mp_init+0x244>
f0105cf8:	be 00 00 00 00       	mov    $0x0,%esi
		switch (*p) {
f0105cfd:	0f b6 03             	movzbl (%ebx),%eax
f0105d00:	84 c0                	test   %al,%al
f0105d02:	74 06                	je     f0105d0a <mp_init+0x1c0>
f0105d04:	3c 04                	cmp    $0x4,%al
f0105d06:	77 56                	ja     f0105d5e <mp_init+0x214>
f0105d08:	eb 4f                	jmp    f0105d59 <mp_init+0x20f>
		case MPPROC:
			proc = (struct mpproc *)p;
f0105d0a:	89 da                	mov    %ebx,%edx
			if (proc->flags & MPPROC_BOOT)
f0105d0c:	f6 43 03 02          	testb  $0x2,0x3(%ebx)
f0105d10:	74 11                	je     f0105d23 <mp_init+0x1d9>
				bootcpu = &cpus[ncpu];
f0105d12:	6b 05 c4 43 22 f0 74 	imul   $0x74,0xf02243c4,%eax
f0105d19:	05 20 40 22 f0       	add    $0xf0224020,%eax
f0105d1e:	a3 c0 43 22 f0       	mov    %eax,0xf02243c0
			if (ncpu < NCPU) {
f0105d23:	a1 c4 43 22 f0       	mov    0xf02243c4,%eax
f0105d28:	83 f8 07             	cmp    $0x7,%eax
f0105d2b:	7f 13                	jg     f0105d40 <mp_init+0x1f6>
				cpus[ncpu].cpu_id = ncpu;
f0105d2d:	6b d0 74             	imul   $0x74,%eax,%edx
f0105d30:	88 82 20 40 22 f0    	mov    %al,-0xfddbfe0(%edx)
				ncpu++;
f0105d36:	83 c0 01             	add    $0x1,%eax
f0105d39:	a3 c4 43 22 f0       	mov    %eax,0xf02243c4
f0105d3e:	eb 14                	jmp    f0105d54 <mp_init+0x20a>
			} else {
				cprintf("SMP: too many CPUs, CPU %d disabled\n",
f0105d40:	0f b6 42 01          	movzbl 0x1(%edx),%eax
f0105d44:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d48:	c7 04 24 ac 7e 10 f0 	movl   $0xf0107eac,(%esp)
f0105d4f:	e8 d5 e1 ff ff       	call   f0103f29 <cprintf>
					proc->apicid);
			}
			p += sizeof(struct mpproc);
f0105d54:	83 c3 14             	add    $0x14,%ebx
			continue;
f0105d57:	eb 26                	jmp    f0105d7f <mp_init+0x235>
		case MPBUS:
		case MPIOAPIC:
		case MPIOINTR:
		case MPLINTR:
			p += 8;
f0105d59:	83 c3 08             	add    $0x8,%ebx
			continue;
f0105d5c:	eb 21                	jmp    f0105d7f <mp_init+0x235>
		default:
			cprintf("mpinit: unknown config type %x\n", *p);
f0105d5e:	0f b6 c0             	movzbl %al,%eax
f0105d61:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105d65:	c7 04 24 d4 7e 10 f0 	movl   $0xf0107ed4,(%esp)
f0105d6c:	e8 b8 e1 ff ff       	call   f0103f29 <cprintf>
			ismp = 0;
f0105d71:	c7 05 00 40 22 f0 00 	movl   $0x0,0xf0224000
f0105d78:	00 00 00 
			i = conf->entry;
f0105d7b:	0f b7 77 22          	movzwl 0x22(%edi),%esi
	if ((conf = mpconfig(&mp)) == 0)
		return;
	ismp = 1;
	lapicaddr = conf->lapicaddr;

	for (p = conf->entries, i = 0; i < conf->entry; i++) {
f0105d7f:	83 c6 01             	add    $0x1,%esi
f0105d82:	0f b7 47 22          	movzwl 0x22(%edi),%eax
f0105d86:	39 f0                	cmp    %esi,%eax
f0105d88:	0f 87 6f ff ff ff    	ja     f0105cfd <mp_init+0x1b3>
			ismp = 0;
			i = conf->entry;
		}
	}

	bootcpu->cpu_status = CPU_STARTED;
f0105d8e:	a1 c0 43 22 f0       	mov    0xf02243c0,%eax
f0105d93:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
	if (!ismp) {
f0105d9a:	83 3d 00 40 22 f0 00 	cmpl   $0x0,0xf0224000
f0105da1:	75 22                	jne    f0105dc5 <mp_init+0x27b>
		// Didn't like what we found; fall back to no MP.
		ncpu = 1;
f0105da3:	c7 05 c4 43 22 f0 01 	movl   $0x1,0xf02243c4
f0105daa:	00 00 00 
		lapicaddr = 0;
f0105dad:	c7 05 00 50 26 f0 00 	movl   $0x0,0xf0265000
f0105db4:	00 00 00 
		cprintf("SMP: configuration not found, SMP disabled\n");
f0105db7:	c7 04 24 f4 7e 10 f0 	movl   $0xf0107ef4,(%esp)
f0105dbe:	e8 66 e1 ff ff       	call   f0103f29 <cprintf>
		return;
f0105dc3:	eb 48                	jmp    f0105e0d <mp_init+0x2c3>
	}
	cprintf("SMP: CPU %d found %d CPU(s)\n", bootcpu->cpu_id,  ncpu);
f0105dc5:	a1 c4 43 22 f0       	mov    0xf02243c4,%eax
f0105dca:	89 44 24 08          	mov    %eax,0x8(%esp)
f0105dce:	a1 c0 43 22 f0       	mov    0xf02243c0,%eax
f0105dd3:	0f b6 00             	movzbl (%eax),%eax
f0105dd6:	89 44 24 04          	mov    %eax,0x4(%esp)
f0105dda:	c7 04 24 7b 7f 10 f0 	movl   $0xf0107f7b,(%esp)
f0105de1:	e8 43 e1 ff ff       	call   f0103f29 <cprintf>

	if (mp->imcrp) {
f0105de6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
f0105de9:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
f0105ded:	74 1e                	je     f0105e0d <mp_init+0x2c3>
		// [MP 3.2.6.1] If the hardware implements PIC mode,
		// switch to getting interrupts from the LAPIC.
		cprintf("SMP: Setting IMCR to switch from PIC mode to symmetric I/O mode\n");
f0105def:	c7 04 24 20 7f 10 f0 	movl   $0xf0107f20,(%esp)
f0105df6:	e8 2e e1 ff ff       	call   f0103f29 <cprintf>
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105dfb:	ba 22 00 00 00       	mov    $0x22,%edx
f0105e00:	b8 70 00 00 00       	mov    $0x70,%eax
f0105e05:	ee                   	out    %al,(%dx)

static __inline uint8_t
inb(int port)
{
	uint8_t data;
	__asm __volatile("inb %w1,%0" : "=a" (data) : "d" (port));
f0105e06:	b2 23                	mov    $0x23,%dl
f0105e08:	ec                   	in     (%dx),%al
}

static __inline void
outb(int port, uint8_t data)
{
	__asm __volatile("outb %0,%w1" : : "a" (data), "d" (port));
f0105e09:	83 c8 01             	or     $0x1,%eax
f0105e0c:	ee                   	out    %al,(%dx)
		outb(0x22, 0x70);   // Select IMCR
		outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
	}
}
f0105e0d:	83 c4 2c             	add    $0x2c,%esp
f0105e10:	5b                   	pop    %ebx
f0105e11:	5e                   	pop    %esi
f0105e12:	5f                   	pop    %edi
f0105e13:	5d                   	pop    %ebp
f0105e14:	c3                   	ret    

f0105e15 <lapicw>:
physaddr_t lapicaddr;        // Initialized in mpconfig.c
volatile uint32_t *lapic;

static void
lapicw(int index, int value)
{
f0105e15:	55                   	push   %ebp
f0105e16:	89 e5                	mov    %esp,%ebp
	lapic[index] = value;
f0105e18:	c1 e0 02             	shl    $0x2,%eax
f0105e1b:	03 05 04 50 26 f0    	add    0xf0265004,%eax
f0105e21:	89 10                	mov    %edx,(%eax)
	lapic[ID];  // wait for write to finish, by reading
f0105e23:	a1 04 50 26 f0       	mov    0xf0265004,%eax
f0105e28:	83 c0 20             	add    $0x20,%eax
f0105e2b:	8b 00                	mov    (%eax),%eax
}
f0105e2d:	5d                   	pop    %ebp
f0105e2e:	c3                   	ret    

f0105e2f <cpunum>:
	lapicw(TPR, 0);
}

int
cpunum(void)
{
f0105e2f:	55                   	push   %ebp
f0105e30:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105e32:	8b 15 04 50 26 f0    	mov    0xf0265004,%edx
f0105e38:	b8 00 00 00 00       	mov    $0x0,%eax
f0105e3d:	85 d2                	test   %edx,%edx
f0105e3f:	74 08                	je     f0105e49 <cpunum+0x1a>
		return lapic[ID] >> 24;
f0105e41:	83 c2 20             	add    $0x20,%edx
f0105e44:	8b 02                	mov    (%edx),%eax
f0105e46:	c1 e8 18             	shr    $0x18,%eax
	return 0;
}
f0105e49:	5d                   	pop    %ebp
f0105e4a:	c3                   	ret    

f0105e4b <lapic_eoi>:

// Acknowledge interrupt.
void
lapic_eoi(void)
{
f0105e4b:	55                   	push   %ebp
f0105e4c:	89 e5                	mov    %esp,%ebp
	if (lapic)
f0105e4e:	83 3d 04 50 26 f0 00 	cmpl   $0x0,0xf0265004
f0105e55:	74 0f                	je     f0105e66 <lapic_eoi+0x1b>
		lapicw(EOI, 0);
f0105e57:	ba 00 00 00 00       	mov    $0x0,%edx
f0105e5c:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0105e61:	e8 af ff ff ff       	call   f0105e15 <lapicw>
}
f0105e66:	5d                   	pop    %ebp
f0105e67:	c3                   	ret    

f0105e68 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
static void
microdelay(int us)
{
f0105e68:	55                   	push   %ebp
f0105e69:	89 e5                	mov    %esp,%ebp
}
f0105e6b:	5d                   	pop    %ebp
f0105e6c:	c3                   	ret    

f0105e6d <lapic_ipi>:
	}
}

void
lapic_ipi(int vector)
{
f0105e6d:	55                   	push   %ebp
f0105e6e:	89 e5                	mov    %esp,%ebp
	lapicw(ICRLO, OTHERS | FIXED | vector);
f0105e70:	8b 55 08             	mov    0x8(%ebp),%edx
f0105e73:	81 ca 00 00 0c 00    	or     $0xc0000,%edx
f0105e79:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105e7e:	e8 92 ff ff ff       	call   f0105e15 <lapicw>
	while (lapic[ICRLO] & DELIVS)
f0105e83:	8b 15 04 50 26 f0    	mov    0xf0265004,%edx
f0105e89:	81 c2 00 03 00 00    	add    $0x300,%edx
f0105e8f:	8b 02                	mov    (%edx),%eax
f0105e91:	f6 c4 10             	test   $0x10,%ah
f0105e94:	75 f9                	jne    f0105e8f <lapic_ipi+0x22>
		;
}
f0105e96:	5d                   	pop    %ebp
f0105e97:	c3                   	ret    

f0105e98 <lapic_startap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapic_startap(uint8_t apicid, uint32_t addr)
{
f0105e98:	55                   	push   %ebp
f0105e99:	89 e5                	mov    %esp,%ebp
f0105e9b:	56                   	push   %esi
f0105e9c:	53                   	push   %ebx
f0105e9d:	83 ec 10             	sub    $0x10,%esp
f0105ea0:	8b 75 0c             	mov    0xc(%ebp),%esi
f0105ea3:	0f b6 5d 08          	movzbl 0x8(%ebp),%ebx
f0105ea7:	ba 70 00 00 00       	mov    $0x70,%edx
f0105eac:	b8 0f 00 00 00       	mov    $0xf,%eax
f0105eb1:	ee                   	out    %al,(%dx)
f0105eb2:	b2 71                	mov    $0x71,%dl
f0105eb4:	b8 0a 00 00 00       	mov    $0xa,%eax
f0105eb9:	ee                   	out    %al,(%dx)
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0105eba:	83 3d e8 3e 22 f0 00 	cmpl   $0x0,0xf0223ee8
f0105ec1:	75 24                	jne    f0105ee7 <lapic_startap+0x4f>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0105ec3:	c7 44 24 0c 67 04 00 	movl   $0x467,0xc(%esp)
f0105eca:	00 
f0105ecb:	c7 44 24 08 00 66 10 	movl   $0xf0106600,0x8(%esp)
f0105ed2:	f0 
f0105ed3:	c7 44 24 04 98 00 00 	movl   $0x98,0x4(%esp)
f0105eda:	00 
f0105edb:	c7 04 24 98 7f 10 f0 	movl   $0xf0107f98,(%esp)
f0105ee2:	e8 9e a1 ff ff       	call   f0100085 <_panic>
	// and the warm reset vector (DWORD based at 40:67) to point at
	// the AP startup code prior to the [universal startup algorithm]."
	outb(IO_RTC, 0xF);  // offset 0xF is shutdown code
	outb(IO_RTC+1, 0x0A);
	wrv = (uint16_t *)KADDR((0x40 << 4 | 0x67));  // Warm reset vector
	wrv[0] = 0;
f0105ee7:	66 c7 05 67 04 00 f0 	movw   $0x0,0xf0000467
f0105eee:	00 00 
	wrv[1] = addr >> 4;
f0105ef0:	89 f0                	mov    %esi,%eax
f0105ef2:	c1 e8 04             	shr    $0x4,%eax
f0105ef5:	66 a3 69 04 00 f0    	mov    %ax,0xf0000469

	// "Universal startup algorithm."
	// Send INIT (level-triggered) interrupt to reset other CPU.
	lapicw(ICRHI, apicid << 24);
f0105efb:	c1 e3 18             	shl    $0x18,%ebx
f0105efe:	89 da                	mov    %ebx,%edx
f0105f00:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f05:	e8 0b ff ff ff       	call   f0105e15 <lapicw>
	lapicw(ICRLO, INIT | LEVEL | ASSERT);
f0105f0a:	ba 00 c5 00 00       	mov    $0xc500,%edx
f0105f0f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f14:	e8 fc fe ff ff       	call   f0105e15 <lapicw>
	microdelay(200);
	lapicw(ICRLO, INIT | LEVEL);
f0105f19:	ba 00 85 00 00       	mov    $0x8500,%edx
f0105f1e:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f23:	e8 ed fe ff ff       	call   f0105e15 <lapicw>
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f28:	c1 ee 0c             	shr    $0xc,%esi
f0105f2b:	81 ce 00 06 00 00    	or     $0x600,%esi
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105f31:	89 da                	mov    %ebx,%edx
f0105f33:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f38:	e8 d8 fe ff ff       	call   f0105e15 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f3d:	89 f2                	mov    %esi,%edx
f0105f3f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f44:	e8 cc fe ff ff       	call   f0105e15 <lapicw>
	// Regular hardware is supposed to only accept a STARTUP
	// when it is in the halted state due to an INIT.  So the second
	// should be ignored, but it is part of the official Intel algorithm.
	// Bochs complains about the second one.  Too bad for Bochs.
	for (i = 0; i < 2; i++) {
		lapicw(ICRHI, apicid << 24);
f0105f49:	89 da                	mov    %ebx,%edx
f0105f4b:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0105f50:	e8 c0 fe ff ff       	call   f0105e15 <lapicw>
		lapicw(ICRLO, STARTUP | (addr >> 12));
f0105f55:	89 f2                	mov    %esi,%edx
f0105f57:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0105f5c:	e8 b4 fe ff ff       	call   f0105e15 <lapicw>
		microdelay(200);
	}
}
f0105f61:	83 c4 10             	add    $0x10,%esp
f0105f64:	5b                   	pop    %ebx
f0105f65:	5e                   	pop    %esi
f0105f66:	5d                   	pop    %ebp
f0105f67:	c3                   	ret    

f0105f68 <lapic_init>:
	lapic[ID];  // wait for write to finish, by reading
}

void
lapic_init(void)
{
f0105f68:	55                   	push   %ebp
f0105f69:	89 e5                	mov    %esp,%ebp
f0105f6b:	83 ec 18             	sub    $0x18,%esp
	if (!lapicaddr)
f0105f6e:	a1 00 50 26 f0       	mov    0xf0265000,%eax
f0105f73:	85 c0                	test   %eax,%eax
f0105f75:	0f 84 20 01 00 00    	je     f010609b <lapic_init+0x133>
		return;

	// lapicaddr is the physical address of the LAPIC's 4K MMIO
	// region.  Map it in to virtual memory so we can access it.
	lapic = mmio_map_region(lapicaddr, 4096);
f0105f7b:	c7 44 24 04 00 10 00 	movl   $0x1000,0x4(%esp)
f0105f82:	00 
f0105f83:	89 04 24             	mov    %eax,(%esp)
f0105f86:	e8 95 b4 ff ff       	call   f0101420 <mmio_map_region>
f0105f8b:	a3 04 50 26 f0       	mov    %eax,0xf0265004

	// Enable local APIC; set spurious interrupt vector.
	lapicw(SVR, ENABLE | (IRQ_OFFSET + IRQ_SPURIOUS));
f0105f90:	ba 27 01 00 00       	mov    $0x127,%edx
f0105f95:	b8 3c 00 00 00       	mov    $0x3c,%eax
f0105f9a:	e8 76 fe ff ff       	call   f0105e15 <lapicw>

	// The timer repeatedly counts down at bus frequency
	// from lapic[TICR] and then issues an interrupt.  
	// If we cared more about precise timekeeping,
	// TICR would be calibrated using an external time source.
	lapicw(TDCR, X1);
f0105f9f:	ba 0b 00 00 00       	mov    $0xb,%edx
f0105fa4:	b8 f8 00 00 00       	mov    $0xf8,%eax
f0105fa9:	e8 67 fe ff ff       	call   f0105e15 <lapicw>
	lapicw(TIMER, PERIODIC | (IRQ_OFFSET + IRQ_TIMER));
f0105fae:	ba 20 00 02 00       	mov    $0x20020,%edx
f0105fb3:	b8 c8 00 00 00       	mov    $0xc8,%eax
f0105fb8:	e8 58 fe ff ff       	call   f0105e15 <lapicw>
	lapicw(TICR, 10000000); 
f0105fbd:	ba 80 96 98 00       	mov    $0x989680,%edx
f0105fc2:	b8 e0 00 00 00       	mov    $0xe0,%eax
f0105fc7:	e8 49 fe ff ff       	call   f0105e15 <lapicw>
	//
	// According to Intel MP Specification, the BIOS should initialize
	// BSP's local APIC in Virtual Wire Mode, in which 8259A's
	// INTR is virtually connected to BSP's LINTIN0. In this mode,
	// we do not need to program the IOAPIC.
	if (thiscpu != bootcpu)
f0105fcc:	e8 5e fe ff ff       	call   f0105e2f <cpunum>
f0105fd1:	6b c0 74             	imul   $0x74,%eax,%eax
f0105fd4:	05 20 40 22 f0       	add    $0xf0224020,%eax
f0105fd9:	3b 05 c0 43 22 f0    	cmp    0xf02243c0,%eax
f0105fdf:	74 0f                	je     f0105ff0 <lapic_init+0x88>
		lapicw(LINT0, MASKED);
f0105fe1:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105fe6:	b8 d4 00 00 00       	mov    $0xd4,%eax
f0105feb:	e8 25 fe ff ff       	call   f0105e15 <lapicw>

	// Disable NMI (LINT1) on all CPUs
	lapicw(LINT1, MASKED);
f0105ff0:	ba 00 00 01 00       	mov    $0x10000,%edx
f0105ff5:	b8 d8 00 00 00       	mov    $0xd8,%eax
f0105ffa:	e8 16 fe ff ff       	call   f0105e15 <lapicw>

	// Disable performance counter overflow interrupts
	// on machines that provide that interrupt entry.
	if (((lapic[VER]>>16) & 0xFF) >= 4)
f0105fff:	a1 04 50 26 f0       	mov    0xf0265004,%eax
f0106004:	83 c0 30             	add    $0x30,%eax
f0106007:	8b 00                	mov    (%eax),%eax
f0106009:	c1 e8 10             	shr    $0x10,%eax
f010600c:	3c 03                	cmp    $0x3,%al
f010600e:	76 0f                	jbe    f010601f <lapic_init+0xb7>
		lapicw(PCINT, MASKED);
f0106010:	ba 00 00 01 00       	mov    $0x10000,%edx
f0106015:	b8 d0 00 00 00       	mov    $0xd0,%eax
f010601a:	e8 f6 fd ff ff       	call   f0105e15 <lapicw>

	// Map error interrupt to IRQ_ERROR.
	lapicw(ERROR, IRQ_OFFSET + IRQ_ERROR);
f010601f:	ba 33 00 00 00       	mov    $0x33,%edx
f0106024:	b8 dc 00 00 00       	mov    $0xdc,%eax
f0106029:	e8 e7 fd ff ff       	call   f0105e15 <lapicw>

	// Clear error status register (requires back-to-back writes).
	lapicw(ESR, 0);
f010602e:	ba 00 00 00 00       	mov    $0x0,%edx
f0106033:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106038:	e8 d8 fd ff ff       	call   f0105e15 <lapicw>
	lapicw(ESR, 0);
f010603d:	ba 00 00 00 00       	mov    $0x0,%edx
f0106042:	b8 a0 00 00 00       	mov    $0xa0,%eax
f0106047:	e8 c9 fd ff ff       	call   f0105e15 <lapicw>

	// Ack any outstanding interrupts.
	lapicw(EOI, 0);
f010604c:	ba 00 00 00 00       	mov    $0x0,%edx
f0106051:	b8 2c 00 00 00       	mov    $0x2c,%eax
f0106056:	e8 ba fd ff ff       	call   f0105e15 <lapicw>

	// Send an Init Level De-Assert to synchronize arbitration ID's.
	lapicw(ICRHI, 0);
f010605b:	ba 00 00 00 00       	mov    $0x0,%edx
f0106060:	b8 c4 00 00 00       	mov    $0xc4,%eax
f0106065:	e8 ab fd ff ff       	call   f0105e15 <lapicw>
	lapicw(ICRLO, BCAST | INIT | LEVEL);
f010606a:	ba 00 85 08 00       	mov    $0x88500,%edx
f010606f:	b8 c0 00 00 00       	mov    $0xc0,%eax
f0106074:	e8 9c fd ff ff       	call   f0105e15 <lapicw>
	while(lapic[ICRLO] & DELIVS)
f0106079:	8b 15 04 50 26 f0    	mov    0xf0265004,%edx
f010607f:	81 c2 00 03 00 00    	add    $0x300,%edx
f0106085:	8b 02                	mov    (%edx),%eax
f0106087:	f6 c4 10             	test   $0x10,%ah
f010608a:	75 f9                	jne    f0106085 <lapic_init+0x11d>
		;

	// Enable interrupts on the APIC (but not on the processor).
	lapicw(TPR, 0);
f010608c:	ba 00 00 00 00       	mov    $0x0,%edx
f0106091:	b8 20 00 00 00       	mov    $0x20,%eax
f0106096:	e8 7a fd ff ff       	call   f0105e15 <lapicw>
}
f010609b:	c9                   	leave  
f010609c:	c3                   	ret    
f010609d:	66 90                	xchg   %ax,%ax
f010609f:	90                   	nop

f01060a0 <__spin_initlock>:
}
#endif

void
__spin_initlock(struct spinlock *lk, char *name)
{
f01060a0:	55                   	push   %ebp
f01060a1:	89 e5                	mov    %esp,%ebp
f01060a3:	8b 45 08             	mov    0x8(%ebp),%eax
	lk->locked = 0;
f01060a6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
#ifdef DEBUG_SPINLOCK
	lk->name = name;
f01060ac:	8b 55 0c             	mov    0xc(%ebp),%edx
f01060af:	89 50 04             	mov    %edx,0x4(%eax)
	lk->cpu = 0;
f01060b2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
#endif
}
f01060b9:	5d                   	pop    %ebp
f01060ba:	c3                   	ret    

f01060bb <holding>:
}

// Check whether this CPU is holding the lock.
static int
holding(struct spinlock *lock)
{
f01060bb:	55                   	push   %ebp
f01060bc:	89 e5                	mov    %esp,%ebp
f01060be:	53                   	push   %ebx
f01060bf:	83 ec 04             	sub    $0x4,%esp
f01060c2:	89 c2                	mov    %eax,%edx
	return lock->locked && lock->cpu == thiscpu;
f01060c4:	b8 00 00 00 00       	mov    $0x0,%eax
f01060c9:	83 3a 00             	cmpl   $0x0,(%edx)
f01060cc:	74 18                	je     f01060e6 <holding+0x2b>
f01060ce:	8b 5a 08             	mov    0x8(%edx),%ebx
f01060d1:	e8 59 fd ff ff       	call   f0105e2f <cpunum>
f01060d6:	6b c0 74             	imul   $0x74,%eax,%eax
f01060d9:	05 20 40 22 f0       	add    $0xf0224020,%eax
f01060de:	39 c3                	cmp    %eax,%ebx
f01060e0:	0f 94 c0             	sete   %al
f01060e3:	0f b6 c0             	movzbl %al,%eax
}
f01060e6:	83 c4 04             	add    $0x4,%esp
f01060e9:	5b                   	pop    %ebx
f01060ea:	5d                   	pop    %ebp
f01060eb:	c3                   	ret    

f01060ec <spin_unlock>:
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
{
f01060ec:	55                   	push   %ebp
f01060ed:	89 e5                	mov    %esp,%ebp
f01060ef:	83 ec 78             	sub    $0x78,%esp
f01060f2:	89 5d f4             	mov    %ebx,-0xc(%ebp)
f01060f5:	89 75 f8             	mov    %esi,-0x8(%ebp)
f01060f8:	89 7d fc             	mov    %edi,-0x4(%ebp)
f01060fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (!holding(lk)) {
f01060fe:	89 d8                	mov    %ebx,%eax
f0106100:	e8 b6 ff ff ff       	call   f01060bb <holding>
f0106105:	85 c0                	test   %eax,%eax
f0106107:	0f 85 d5 00 00 00    	jne    f01061e2 <spin_unlock+0xf6>
		int i;
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
f010610d:	c7 44 24 08 28 00 00 	movl   $0x28,0x8(%esp)
f0106114:	00 
f0106115:	8d 43 0c             	lea    0xc(%ebx),%eax
f0106118:	89 44 24 04          	mov    %eax,0x4(%esp)
f010611c:	8d 45 a8             	lea    -0x58(%ebp),%eax
f010611f:	89 04 24             	mov    %eax,(%esp)
f0106122:	e8 be f6 ff ff       	call   f01057e5 <memmove>
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
f0106127:	8b 43 08             	mov    0x8(%ebx),%eax
f010612a:	0f b6 30             	movzbl (%eax),%esi
f010612d:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106130:	e8 fa fc ff ff       	call   f0105e2f <cpunum>
f0106135:	89 74 24 0c          	mov    %esi,0xc(%esp)
f0106139:	89 5c 24 08          	mov    %ebx,0x8(%esp)
f010613d:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106141:	c7 04 24 a8 7f 10 f0 	movl   $0xf0107fa8,(%esp)
f0106148:	e8 dc dd ff ff       	call   f0103f29 <cprintf>
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f010614d:	8b 45 a8             	mov    -0x58(%ebp),%eax
f0106150:	85 c0                	test   %eax,%eax
f0106152:	74 72                	je     f01061c6 <spin_unlock+0xda>
f0106154:	8d 5d a8             	lea    -0x58(%ebp),%ebx
#endif
}

// Release the lock.
void
spin_unlock(struct spinlock *lk)
f0106157:	8d 7d cc             	lea    -0x34(%ebp),%edi
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
f010615a:	8d 75 d0             	lea    -0x30(%ebp),%esi
f010615d:	89 74 24 04          	mov    %esi,0x4(%esp)
f0106161:	89 04 24             	mov    %eax,(%esp)
f0106164:	e8 75 ea ff ff       	call   f0104bde <debuginfo_eip>
f0106169:	85 c0                	test   %eax,%eax
f010616b:	78 39                	js     f01061a6 <spin_unlock+0xba>
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
f010616d:	8b 03                	mov    (%ebx),%eax
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
			struct Eipdebuginfo info;
			if (debuginfo_eip(pcs[i], &info) >= 0)
				cprintf("  %08x %s:%d: %.*s+%x\n", pcs[i],
f010616f:	89 c2                	mov    %eax,%edx
f0106171:	2b 55 e0             	sub    -0x20(%ebp),%edx
f0106174:	89 54 24 18          	mov    %edx,0x18(%esp)
f0106178:	8b 55 d8             	mov    -0x28(%ebp),%edx
f010617b:	89 54 24 14          	mov    %edx,0x14(%esp)
f010617f:	8b 55 dc             	mov    -0x24(%ebp),%edx
f0106182:	89 54 24 10          	mov    %edx,0x10(%esp)
f0106186:	8b 55 d4             	mov    -0x2c(%ebp),%edx
f0106189:	89 54 24 0c          	mov    %edx,0xc(%esp)
f010618d:	8b 55 d0             	mov    -0x30(%ebp),%edx
f0106190:	89 54 24 08          	mov    %edx,0x8(%esp)
f0106194:	89 44 24 04          	mov    %eax,0x4(%esp)
f0106198:	c7 04 24 0c 80 10 f0 	movl   $0xf010800c,(%esp)
f010619f:	e8 85 dd ff ff       	call   f0103f29 <cprintf>
f01061a4:	eb 12                	jmp    f01061b8 <spin_unlock+0xcc>
					info.eip_file, info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
f01061a6:	8b 03                	mov    (%ebx),%eax
f01061a8:	89 44 24 04          	mov    %eax,0x4(%esp)
f01061ac:	c7 04 24 23 80 10 f0 	movl   $0xf0108023,(%esp)
f01061b3:	e8 71 dd ff ff       	call   f0103f29 <cprintf>
		uint32_t pcs[10];
		// Nab the acquiring EIP chain before it gets released
		memmove(pcs, lk->pcs, sizeof pcs);
		cprintf("CPU %d cannot release %s: held by CPU %d\nAcquired at:", 
			cpunum(), lk->name, lk->cpu->cpu_id);
		for (i = 0; i < 10 && pcs[i]; i++) {
f01061b8:	39 fb                	cmp    %edi,%ebx
f01061ba:	74 0a                	je     f01061c6 <spin_unlock+0xda>
f01061bc:	8b 43 04             	mov    0x4(%ebx),%eax
f01061bf:	83 c3 04             	add    $0x4,%ebx
f01061c2:	85 c0                	test   %eax,%eax
f01061c4:	75 97                	jne    f010615d <spin_unlock+0x71>
					info.eip_fn_namelen, info.eip_fn_name,
					pcs[i] - info.eip_fn_addr);
			else
				cprintf("  %08x\n", pcs[i]);
		}
		panic("spin_unlock");
f01061c6:	c7 44 24 08 2b 80 10 	movl   $0xf010802b,0x8(%esp)
f01061cd:	f0 
f01061ce:	c7 44 24 04 67 00 00 	movl   $0x67,0x4(%esp)
f01061d5:	00 
f01061d6:	c7 04 24 37 80 10 f0 	movl   $0xf0108037,(%esp)
f01061dd:	e8 a3 9e ff ff       	call   f0100085 <_panic>
	}

	lk->pcs[0] = 0;
f01061e2:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
	lk->cpu = 0;
f01061e9:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
xchg(volatile uint32_t *addr, uint32_t newval)
{
	uint32_t result;

	// The + in "+m" denotes a read-modify-write operand.
	asm volatile("lock; xchgl %0, %1" :
f01061f0:	b8 00 00 00 00       	mov    $0x0,%eax
f01061f5:	f0 87 03             	lock xchg %eax,(%ebx)
	// Paper says that Intel 64 and IA-32 will not move a load
	// after a store. So lock->locked = 0 would work here.
	// The xchg being asm volatile ensures gcc emits it after
	// the above assignments (and after the critical section).
	xchg(&lk->locked, 0);
}
f01061f8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
f01061fb:	8b 75 f8             	mov    -0x8(%ebp),%esi
f01061fe:	8b 7d fc             	mov    -0x4(%ebp),%edi
f0106201:	89 ec                	mov    %ebp,%esp
f0106203:	5d                   	pop    %ebp
f0106204:	c3                   	ret    

f0106205 <spin_lock>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
{
f0106205:	55                   	push   %ebp
f0106206:	89 e5                	mov    %esp,%ebp
f0106208:	56                   	push   %esi
f0106209:	53                   	push   %ebx
f010620a:	83 ec 20             	sub    $0x20,%esp
f010620d:	8b 5d 08             	mov    0x8(%ebp),%ebx
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
f0106210:	89 d8                	mov    %ebx,%eax
f0106212:	e8 a4 fe ff ff       	call   f01060bb <holding>
f0106217:	85 c0                	test   %eax,%eax
f0106219:	75 12                	jne    f010622d <spin_lock+0x28>
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f010621b:	89 da                	mov    %ebx,%edx
f010621d:	b0 01                	mov    $0x1,%al
f010621f:	f0 87 03             	lock xchg %eax,(%ebx)
f0106222:	b9 01 00 00 00       	mov    $0x1,%ecx
f0106227:	85 c0                	test   %eax,%eax
f0106229:	75 2e                	jne    f0106259 <spin_lock+0x54>
f010622b:	eb 37                	jmp    f0106264 <spin_lock+0x5f>
void
spin_lock(struct spinlock *lk)
{
#ifdef DEBUG_SPINLOCK
	if (holding(lk))
		panic("CPU %d cannot acquire %s: already holding", cpunum(), lk->name);
f010622d:	8b 5b 04             	mov    0x4(%ebx),%ebx
f0106230:	e8 fa fb ff ff       	call   f0105e2f <cpunum>
f0106235:	89 5c 24 10          	mov    %ebx,0x10(%esp)
f0106239:	89 44 24 0c          	mov    %eax,0xc(%esp)
f010623d:	c7 44 24 08 e0 7f 10 	movl   $0xf0107fe0,0x8(%esp)
f0106244:	f0 
f0106245:	c7 44 24 04 41 00 00 	movl   $0x41,0x4(%esp)
f010624c:	00 
f010624d:	c7 04 24 37 80 10 f0 	movl   $0xf0108037,(%esp)
f0106254:	e8 2c 9e ff ff       	call   f0100085 <_panic>

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
		asm volatile ("pause");
f0106259:	f3 90                	pause  
f010625b:	89 c8                	mov    %ecx,%eax
f010625d:	f0 87 02             	lock xchg %eax,(%edx)
#endif

	// The xchg is atomic.
	// It also serializes, so that reads after acquire are not
	// reordered before it. 
	while (xchg(&lk->locked, 1) != 0)
f0106260:	85 c0                	test   %eax,%eax
f0106262:	75 f5                	jne    f0106259 <spin_lock+0x54>
		asm volatile ("pause");

	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
f0106264:	e8 c6 fb ff ff       	call   f0105e2f <cpunum>
f0106269:	6b c0 74             	imul   $0x74,%eax,%eax
f010626c:	05 20 40 22 f0       	add    $0xf0224020,%eax
f0106271:	89 43 08             	mov    %eax,0x8(%ebx)
	get_caller_pcs(lk->pcs);
f0106274:	8d 73 0c             	lea    0xc(%ebx),%esi
get_caller_pcs(uint32_t pcs[])
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
f0106277:	89 e8                	mov    %ebp,%eax
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
f0106279:	3d ff ff 7f ef       	cmp    $0xef7fffff,%eax
f010627e:	77 3d                	ja     f01062bd <spin_lock+0xb8>
f0106280:	eb 30                	jmp    f01062b2 <spin_lock+0xad>
f0106282:	81 fa ff ff 7f ef    	cmp    $0xef7fffff,%edx
f0106288:	76 2d                	jbe    f01062b7 <spin_lock+0xb2>
			break;
		pcs[i] = ebp[1];          // saved %eip
f010628a:	8b 4a 04             	mov    0x4(%edx),%ecx
f010628d:	89 0c 86             	mov    %ecx,(%esi,%eax,4)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f0106290:	8b 12                	mov    (%edx),%edx
{
	uint32_t *ebp;
	int i;

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
f0106292:	83 c0 01             	add    $0x1,%eax
f0106295:	83 f8 0a             	cmp    $0xa,%eax
f0106298:	75 e8                	jne    f0106282 <spin_lock+0x7d>
f010629a:	eb 30                	jmp    f01062cc <spin_lock+0xc7>
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
		pcs[i] = 0;
f010629c:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
		ebp = (uint32_t *)ebp[0]; // saved %ebp
	}
	for (; i < 10; i++)
f01062a2:	83 c0 01             	add    $0x1,%eax
f01062a5:	83 c2 04             	add    $0x4,%edx
f01062a8:	83 f8 09             	cmp    $0x9,%eax
f01062ab:	7e ef                	jle    f010629c <spin_lock+0x97>
f01062ad:	8d 76 00             	lea    0x0(%esi),%esi
f01062b0:	eb 1a                	jmp    f01062cc <spin_lock+0xc7>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01062b2:	b8 00 00 00 00       	mov    $0x0,%eax
// Acquire the lock.
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
spin_lock(struct spinlock *lk)
f01062b7:	8d 54 83 0c          	lea    0xc(%ebx,%eax,4),%edx
f01062bb:	eb df                	jmp    f010629c <spin_lock+0x97>

	ebp = (uint32_t *)read_ebp();
	for (i = 0; i < 10; i++){
		if (ebp == 0 || ebp < (uint32_t *)ULIM)
			break;
		pcs[i] = ebp[1];          // saved %eip
f01062bd:	8b 50 04             	mov    0x4(%eax),%edx
f01062c0:	89 53 0c             	mov    %edx,0xc(%ebx)
		ebp = (uint32_t *)ebp[0]; // saved %ebp
f01062c3:	8b 10                	mov    (%eax),%edx
f01062c5:	b8 01 00 00 00       	mov    $0x1,%eax
f01062ca:	eb b6                	jmp    f0106282 <spin_lock+0x7d>
	// Record info about lock acquisition for debugging.
#ifdef DEBUG_SPINLOCK
	lk->cpu = thiscpu;
	get_caller_pcs(lk->pcs);
#endif
}
f01062cc:	83 c4 20             	add    $0x20,%esp
f01062cf:	5b                   	pop    %ebx
f01062d0:	5e                   	pop    %esi
f01062d1:	5d                   	pop    %ebp
f01062d2:	c3                   	ret    
f01062d3:	66 90                	xchg   %ax,%ax
f01062d5:	66 90                	xchg   %ax,%ax
f01062d7:	66 90                	xchg   %ax,%ax
f01062d9:	66 90                	xchg   %ax,%ax
f01062db:	66 90                	xchg   %ax,%ax
f01062dd:	66 90                	xchg   %ax,%ax
f01062df:	90                   	nop

f01062e0 <__udivdi3>:
f01062e0:	55                   	push   %ebp
f01062e1:	89 e5                	mov    %esp,%ebp
f01062e3:	57                   	push   %edi
f01062e4:	56                   	push   %esi
f01062e5:	83 ec 10             	sub    $0x10,%esp
f01062e8:	8b 45 14             	mov    0x14(%ebp),%eax
f01062eb:	8b 55 08             	mov    0x8(%ebp),%edx
f01062ee:	8b 75 10             	mov    0x10(%ebp),%esi
f01062f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
f01062f4:	85 c0                	test   %eax,%eax
f01062f6:	89 55 f0             	mov    %edx,-0x10(%ebp)
f01062f9:	75 35                	jne    f0106330 <__udivdi3+0x50>
f01062fb:	39 fe                	cmp    %edi,%esi
f01062fd:	77 61                	ja     f0106360 <__udivdi3+0x80>
f01062ff:	85 f6                	test   %esi,%esi
f0106301:	75 0b                	jne    f010630e <__udivdi3+0x2e>
f0106303:	b8 01 00 00 00       	mov    $0x1,%eax
f0106308:	31 d2                	xor    %edx,%edx
f010630a:	f7 f6                	div    %esi
f010630c:	89 c6                	mov    %eax,%esi
f010630e:	8b 4d f0             	mov    -0x10(%ebp),%ecx
f0106311:	31 d2                	xor    %edx,%edx
f0106313:	89 f8                	mov    %edi,%eax
f0106315:	f7 f6                	div    %esi
f0106317:	89 c7                	mov    %eax,%edi
f0106319:	89 c8                	mov    %ecx,%eax
f010631b:	f7 f6                	div    %esi
f010631d:	89 c1                	mov    %eax,%ecx
f010631f:	89 fa                	mov    %edi,%edx
f0106321:	89 c8                	mov    %ecx,%eax
f0106323:	83 c4 10             	add    $0x10,%esp
f0106326:	5e                   	pop    %esi
f0106327:	5f                   	pop    %edi
f0106328:	5d                   	pop    %ebp
f0106329:	c3                   	ret    
f010632a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
f0106330:	39 f8                	cmp    %edi,%eax
f0106332:	77 1c                	ja     f0106350 <__udivdi3+0x70>
f0106334:	0f bd d0             	bsr    %eax,%edx
f0106337:	83 f2 1f             	xor    $0x1f,%edx
f010633a:	89 55 f4             	mov    %edx,-0xc(%ebp)
f010633d:	75 39                	jne    f0106378 <__udivdi3+0x98>
f010633f:	3b 75 f0             	cmp    -0x10(%ebp),%esi
f0106342:	0f 86 a0 00 00 00    	jbe    f01063e8 <__udivdi3+0x108>
f0106348:	39 f8                	cmp    %edi,%eax
f010634a:	0f 82 98 00 00 00    	jb     f01063e8 <__udivdi3+0x108>
f0106350:	31 ff                	xor    %edi,%edi
f0106352:	31 c9                	xor    %ecx,%ecx
f0106354:	89 c8                	mov    %ecx,%eax
f0106356:	89 fa                	mov    %edi,%edx
f0106358:	83 c4 10             	add    $0x10,%esp
f010635b:	5e                   	pop    %esi
f010635c:	5f                   	pop    %edi
f010635d:	5d                   	pop    %ebp
f010635e:	c3                   	ret    
f010635f:	90                   	nop
f0106360:	89 d1                	mov    %edx,%ecx
f0106362:	89 fa                	mov    %edi,%edx
f0106364:	89 c8                	mov    %ecx,%eax
f0106366:	31 ff                	xor    %edi,%edi
f0106368:	f7 f6                	div    %esi
f010636a:	89 c1                	mov    %eax,%ecx
f010636c:	89 fa                	mov    %edi,%edx
f010636e:	89 c8                	mov    %ecx,%eax
f0106370:	83 c4 10             	add    $0x10,%esp
f0106373:	5e                   	pop    %esi
f0106374:	5f                   	pop    %edi
f0106375:	5d                   	pop    %ebp
f0106376:	c3                   	ret    
f0106377:	90                   	nop
f0106378:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f010637c:	89 f2                	mov    %esi,%edx
f010637e:	d3 e0                	shl    %cl,%eax
f0106380:	89 45 ec             	mov    %eax,-0x14(%ebp)
f0106383:	b8 20 00 00 00       	mov    $0x20,%eax
f0106388:	2b 45 f4             	sub    -0xc(%ebp),%eax
f010638b:	89 c1                	mov    %eax,%ecx
f010638d:	d3 ea                	shr    %cl,%edx
f010638f:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f0106393:	0b 55 ec             	or     -0x14(%ebp),%edx
f0106396:	d3 e6                	shl    %cl,%esi
f0106398:	89 c1                	mov    %eax,%ecx
f010639a:	89 75 e8             	mov    %esi,-0x18(%ebp)
f010639d:	89 fe                	mov    %edi,%esi
f010639f:	d3 ee                	shr    %cl,%esi
f01063a1:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01063a5:	89 55 ec             	mov    %edx,-0x14(%ebp)
f01063a8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01063ab:	d3 e7                	shl    %cl,%edi
f01063ad:	89 c1                	mov    %eax,%ecx
f01063af:	d3 ea                	shr    %cl,%edx
f01063b1:	09 d7                	or     %edx,%edi
f01063b3:	89 f2                	mov    %esi,%edx
f01063b5:	89 f8                	mov    %edi,%eax
f01063b7:	f7 75 ec             	divl   -0x14(%ebp)
f01063ba:	89 d6                	mov    %edx,%esi
f01063bc:	89 c7                	mov    %eax,%edi
f01063be:	f7 65 e8             	mull   -0x18(%ebp)
f01063c1:	39 d6                	cmp    %edx,%esi
f01063c3:	89 55 ec             	mov    %edx,-0x14(%ebp)
f01063c6:	72 30                	jb     f01063f8 <__udivdi3+0x118>
f01063c8:	8b 55 f0             	mov    -0x10(%ebp),%edx
f01063cb:	0f b6 4d f4          	movzbl -0xc(%ebp),%ecx
f01063cf:	d3 e2                	shl    %cl,%edx
f01063d1:	39 c2                	cmp    %eax,%edx
f01063d3:	73 05                	jae    f01063da <__udivdi3+0xfa>
f01063d5:	3b 75 ec             	cmp    -0x14(%ebp),%esi
f01063d8:	74 1e                	je     f01063f8 <__udivdi3+0x118>
f01063da:	89 f9                	mov    %edi,%ecx
f01063dc:	31 ff                	xor    %edi,%edi
f01063de:	e9 71 ff ff ff       	jmp    f0106354 <__udivdi3+0x74>
f01063e3:	90                   	nop
f01063e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01063e8:	31 ff                	xor    %edi,%edi
f01063ea:	b9 01 00 00 00       	mov    $0x1,%ecx
f01063ef:	e9 60 ff ff ff       	jmp    f0106354 <__udivdi3+0x74>
f01063f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01063f8:	8d 4f ff             	lea    -0x1(%edi),%ecx
f01063fb:	31 ff                	xor    %edi,%edi
f01063fd:	89 c8                	mov    %ecx,%eax
f01063ff:	89 fa                	mov    %edi,%edx
f0106401:	83 c4 10             	add    $0x10,%esp
f0106404:	5e                   	pop    %esi
f0106405:	5f                   	pop    %edi
f0106406:	5d                   	pop    %ebp
f0106407:	c3                   	ret    
f0106408:	66 90                	xchg   %ax,%ax
f010640a:	66 90                	xchg   %ax,%ax
f010640c:	66 90                	xchg   %ax,%ax
f010640e:	66 90                	xchg   %ax,%ax

f0106410 <__umoddi3>:
f0106410:	55                   	push   %ebp
f0106411:	89 e5                	mov    %esp,%ebp
f0106413:	57                   	push   %edi
f0106414:	56                   	push   %esi
f0106415:	83 ec 20             	sub    $0x20,%esp
f0106418:	8b 55 14             	mov    0x14(%ebp),%edx
f010641b:	8b 4d 08             	mov    0x8(%ebp),%ecx
f010641e:	8b 7d 10             	mov    0x10(%ebp),%edi
f0106421:	8b 75 0c             	mov    0xc(%ebp),%esi
f0106424:	85 d2                	test   %edx,%edx
f0106426:	89 c8                	mov    %ecx,%eax
f0106428:	89 4d f4             	mov    %ecx,-0xc(%ebp)
f010642b:	75 13                	jne    f0106440 <__umoddi3+0x30>
f010642d:	39 f7                	cmp    %esi,%edi
f010642f:	76 3f                	jbe    f0106470 <__umoddi3+0x60>
f0106431:	89 f2                	mov    %esi,%edx
f0106433:	f7 f7                	div    %edi
f0106435:	89 d0                	mov    %edx,%eax
f0106437:	31 d2                	xor    %edx,%edx
f0106439:	83 c4 20             	add    $0x20,%esp
f010643c:	5e                   	pop    %esi
f010643d:	5f                   	pop    %edi
f010643e:	5d                   	pop    %ebp
f010643f:	c3                   	ret    
f0106440:	39 f2                	cmp    %esi,%edx
f0106442:	77 4c                	ja     f0106490 <__umoddi3+0x80>
f0106444:	0f bd ca             	bsr    %edx,%ecx
f0106447:	83 f1 1f             	xor    $0x1f,%ecx
f010644a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
f010644d:	75 51                	jne    f01064a0 <__umoddi3+0x90>
f010644f:	3b 7d f4             	cmp    -0xc(%ebp),%edi
f0106452:	0f 87 e0 00 00 00    	ja     f0106538 <__umoddi3+0x128>
f0106458:	8b 45 f4             	mov    -0xc(%ebp),%eax
f010645b:	29 f8                	sub    %edi,%eax
f010645d:	19 d6                	sbb    %edx,%esi
f010645f:	89 45 f4             	mov    %eax,-0xc(%ebp)
f0106462:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106465:	89 f2                	mov    %esi,%edx
f0106467:	83 c4 20             	add    $0x20,%esp
f010646a:	5e                   	pop    %esi
f010646b:	5f                   	pop    %edi
f010646c:	5d                   	pop    %ebp
f010646d:	c3                   	ret    
f010646e:	66 90                	xchg   %ax,%ax
f0106470:	85 ff                	test   %edi,%edi
f0106472:	75 0b                	jne    f010647f <__umoddi3+0x6f>
f0106474:	b8 01 00 00 00       	mov    $0x1,%eax
f0106479:	31 d2                	xor    %edx,%edx
f010647b:	f7 f7                	div    %edi
f010647d:	89 c7                	mov    %eax,%edi
f010647f:	89 f0                	mov    %esi,%eax
f0106481:	31 d2                	xor    %edx,%edx
f0106483:	f7 f7                	div    %edi
f0106485:	8b 45 f4             	mov    -0xc(%ebp),%eax
f0106488:	f7 f7                	div    %edi
f010648a:	eb a9                	jmp    f0106435 <__umoddi3+0x25>
f010648c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106490:	89 c8                	mov    %ecx,%eax
f0106492:	89 f2                	mov    %esi,%edx
f0106494:	83 c4 20             	add    $0x20,%esp
f0106497:	5e                   	pop    %esi
f0106498:	5f                   	pop    %edi
f0106499:	5d                   	pop    %ebp
f010649a:	c3                   	ret    
f010649b:	90                   	nop
f010649c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f01064a0:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01064a4:	d3 e2                	shl    %cl,%edx
f01064a6:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01064a9:	ba 20 00 00 00       	mov    $0x20,%edx
f01064ae:	2b 55 f0             	sub    -0x10(%ebp),%edx
f01064b1:	89 55 ec             	mov    %edx,-0x14(%ebp)
f01064b4:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01064b8:	89 fa                	mov    %edi,%edx
f01064ba:	d3 ea                	shr    %cl,%edx
f01064bc:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01064c0:	0b 55 f4             	or     -0xc(%ebp),%edx
f01064c3:	d3 e7                	shl    %cl,%edi
f01064c5:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01064c9:	89 55 f4             	mov    %edx,-0xc(%ebp)
f01064cc:	89 f2                	mov    %esi,%edx
f01064ce:	89 7d e8             	mov    %edi,-0x18(%ebp)
f01064d1:	89 c7                	mov    %eax,%edi
f01064d3:	d3 ea                	shr    %cl,%edx
f01064d5:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01064d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
f01064dc:	89 c2                	mov    %eax,%edx
f01064de:	d3 e6                	shl    %cl,%esi
f01064e0:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f01064e4:	d3 ea                	shr    %cl,%edx
f01064e6:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f01064ea:	09 d6                	or     %edx,%esi
f01064ec:	89 f0                	mov    %esi,%eax
f01064ee:	8b 75 e4             	mov    -0x1c(%ebp),%esi
f01064f1:	d3 e7                	shl    %cl,%edi
f01064f3:	89 f2                	mov    %esi,%edx
f01064f5:	f7 75 f4             	divl   -0xc(%ebp)
f01064f8:	89 d6                	mov    %edx,%esi
f01064fa:	f7 65 e8             	mull   -0x18(%ebp)
f01064fd:	39 d6                	cmp    %edx,%esi
f01064ff:	72 2b                	jb     f010652c <__umoddi3+0x11c>
f0106501:	39 c7                	cmp    %eax,%edi
f0106503:	72 23                	jb     f0106528 <__umoddi3+0x118>
f0106505:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f0106509:	29 c7                	sub    %eax,%edi
f010650b:	19 d6                	sbb    %edx,%esi
f010650d:	89 f0                	mov    %esi,%eax
f010650f:	89 f2                	mov    %esi,%edx
f0106511:	d3 ef                	shr    %cl,%edi
f0106513:	0f b6 4d ec          	movzbl -0x14(%ebp),%ecx
f0106517:	d3 e0                	shl    %cl,%eax
f0106519:	0f b6 4d f0          	movzbl -0x10(%ebp),%ecx
f010651d:	09 f8                	or     %edi,%eax
f010651f:	d3 ea                	shr    %cl,%edx
f0106521:	83 c4 20             	add    $0x20,%esp
f0106524:	5e                   	pop    %esi
f0106525:	5f                   	pop    %edi
f0106526:	5d                   	pop    %ebp
f0106527:	c3                   	ret    
f0106528:	39 d6                	cmp    %edx,%esi
f010652a:	75 d9                	jne    f0106505 <__umoddi3+0xf5>
f010652c:	2b 45 e8             	sub    -0x18(%ebp),%eax
f010652f:	1b 55 f4             	sbb    -0xc(%ebp),%edx
f0106532:	eb d1                	jmp    f0106505 <__umoddi3+0xf5>
f0106534:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
f0106538:	39 f2                	cmp    %esi,%edx
f010653a:	0f 82 18 ff ff ff    	jb     f0106458 <__umoddi3+0x48>
f0106540:	e9 1d ff ff ff       	jmp    f0106462 <__umoddi3+0x52>
