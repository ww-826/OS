
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	0000d297          	auipc	t0,0xd
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc020d000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	0000d297          	auipc	t0,0xd
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc020d008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c020c2b7          	lui	t0,0xc020c
    # t1 := 0xffffffff40000000 即虚实映射偏移量
    li      t1, 0xffffffffc0000000 - 0x80000000
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
    # t0 减去虚实映射偏移量 0xffffffff40000000，变为三级页表的物理地址
    sub     t0, t0, t1
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
    # t0 >>= 12，变为三级页表的物理页号
    srli    t0, t0, 12
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc

    # t1 := 8 << 60，设置 satp 的 MODE 字段为 Sv39
    li      t1, 8 << 60
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
    # 将刚才计算出的预设三级页表物理页号附加到 satp 中
    or      t0, t0, t1
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
    # 将算出的 t0(即新的MODE|页表基址物理页号) 覆盖到 satp 中
    csrw    satp, t0
ffffffffc0200034:	18029073          	csrw	satp,t0
    # 使用 sfence.vma 指令刷新 TLB
    sfence.vma
ffffffffc0200038:	12000073          	sfence.vma
    # 从此，我们给内核搭建出了一个完美的虚拟内存空间！
    #nop # 可能映射的位置有些bug。。插入一个nop
    
    # 我们在虚拟内存空间中：随意将 sp 设置为虚拟地址！
    lui sp, %hi(bootstacktop)
ffffffffc020003c:	c020c137          	lui	sp,0xc020c

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200044:	04a28293          	addi	t0,t0,74 # ffffffffc020004a <kern_init>
    jr t0
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <kern_init>:
void grade_backtrace(void);

int kern_init(void)
{
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc020004a:	000c8517          	auipc	a0,0xc8
ffffffffc020004e:	cfe50513          	addi	a0,a0,-770 # ffffffffc02c7d48 <buf>
ffffffffc0200052:	000cc617          	auipc	a2,0xcc
ffffffffc0200056:	32660613          	addi	a2,a2,806 # ffffffffc02cc378 <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16 # ffffffffc020bff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	416060ef          	jal	ffffffffc0206478 <memset>
    cons_init(); // init the console
ffffffffc0200066:	4da000ef          	jal	ffffffffc0200540 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006a:	00006597          	auipc	a1,0x6
ffffffffc020006e:	43e58593          	addi	a1,a1,1086 # ffffffffc02064a8 <etext+0x6>
ffffffffc0200072:	00006517          	auipc	a0,0x6
ffffffffc0200076:	45650513          	addi	a0,a0,1110 # ffffffffc02064c8 <etext+0x26>
ffffffffc020007a:	11e000ef          	jal	ffffffffc0200198 <cprintf>

    print_kerninfo();
ffffffffc020007e:	1ac000ef          	jal	ffffffffc020022a <print_kerninfo>

    // grade_backtrace();

    dtb_init(); // init dtb
ffffffffc0200082:	530000ef          	jal	ffffffffc02005b2 <dtb_init>
    pmm_init(); // init physical memory management
ffffffffc0200086:	78a020ef          	jal	ffffffffc0202810 <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	07b000ef          	jal	ffffffffc0200904 <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	079000ef          	jal	ffffffffc0200906 <idt_init>

    vmm_init(); // init virtual memory management
ffffffffc0200092:	023030ef          	jal	ffffffffc02038b4 <vmm_init>
    sched_init();
ffffffffc0200096:	1c7050ef          	jal	ffffffffc0205a5c <sched_init>
    proc_init(); // init process table
ffffffffc020009a:	6e0050ef          	jal	ffffffffc020577a <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009e:	45a000ef          	jal	ffffffffc02004f8 <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc02000a2:	057000ef          	jal	ffffffffc02008f8 <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a6:	075050ef          	jal	ffffffffc020591a <cpu_idle>

ffffffffc02000aa <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02000aa:	7179                	addi	sp,sp,-48
ffffffffc02000ac:	f406                	sd	ra,40(sp)
ffffffffc02000ae:	f022                	sd	s0,32(sp)
ffffffffc02000b0:	ec26                	sd	s1,24(sp)
ffffffffc02000b2:	e84a                	sd	s2,16(sp)
ffffffffc02000b4:	e44e                	sd	s3,8(sp)
    if (prompt != NULL) {
ffffffffc02000b6:	c901                	beqz	a0,ffffffffc02000c6 <readline+0x1c>
        cprintf("%s", prompt);
ffffffffc02000b8:	85aa                	mv	a1,a0
ffffffffc02000ba:	00006517          	auipc	a0,0x6
ffffffffc02000be:	41650513          	addi	a0,a0,1046 # ffffffffc02064d0 <etext+0x2e>
ffffffffc02000c2:	0d6000ef          	jal	ffffffffc0200198 <cprintf>
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
            cputchar(c);
            buf[i ++] = c;
ffffffffc02000c6:	4481                	li	s1,0
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000c8:	497d                	li	s2,31
            buf[i ++] = c;
ffffffffc02000ca:	000c8997          	auipc	s3,0xc8
ffffffffc02000ce:	c7e98993          	addi	s3,s3,-898 # ffffffffc02c7d48 <buf>
        c = getchar();
ffffffffc02000d2:	148000ef          	jal	ffffffffc020021a <getchar>
ffffffffc02000d6:	842a                	mv	s0,a0
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000d8:	ff850793          	addi	a5,a0,-8
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000dc:	3ff4a713          	slti	a4,s1,1023
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000e0:	ff650693          	addi	a3,a0,-10
ffffffffc02000e4:	ff350613          	addi	a2,a0,-13
        if (c < 0) {
ffffffffc02000e8:	02054963          	bltz	a0,ffffffffc020011a <readline+0x70>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000ec:	02a95f63          	bge	s2,a0,ffffffffc020012a <readline+0x80>
ffffffffc02000f0:	cf0d                	beqz	a4,ffffffffc020012a <readline+0x80>
            cputchar(c);
ffffffffc02000f2:	0da000ef          	jal	ffffffffc02001cc <cputchar>
            buf[i ++] = c;
ffffffffc02000f6:	009987b3          	add	a5,s3,s1
ffffffffc02000fa:	00878023          	sb	s0,0(a5)
ffffffffc02000fe:	2485                	addiw	s1,s1,1
        c = getchar();
ffffffffc0200100:	11a000ef          	jal	ffffffffc020021a <getchar>
ffffffffc0200104:	842a                	mv	s0,a0
        else if (c == '\b' && i > 0) {
ffffffffc0200106:	ff850793          	addi	a5,a0,-8
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc020010a:	3ff4a713          	slti	a4,s1,1023
        else if (c == '\n' || c == '\r') {
ffffffffc020010e:	ff650693          	addi	a3,a0,-10
ffffffffc0200112:	ff350613          	addi	a2,a0,-13
        if (c < 0) {
ffffffffc0200116:	fc055be3          	bgez	a0,ffffffffc02000ec <readline+0x42>
            cputchar(c);
            buf[i] = '\0';
            return buf;
        }
    }
}
ffffffffc020011a:	70a2                	ld	ra,40(sp)
ffffffffc020011c:	7402                	ld	s0,32(sp)
ffffffffc020011e:	64e2                	ld	s1,24(sp)
ffffffffc0200120:	6942                	ld	s2,16(sp)
ffffffffc0200122:	69a2                	ld	s3,8(sp)
            return NULL;
ffffffffc0200124:	4501                	li	a0,0
}
ffffffffc0200126:	6145                	addi	sp,sp,48
ffffffffc0200128:	8082                	ret
        else if (c == '\b' && i > 0) {
ffffffffc020012a:	eb81                	bnez	a5,ffffffffc020013a <readline+0x90>
            cputchar(c);
ffffffffc020012c:	4521                	li	a0,8
        else if (c == '\b' && i > 0) {
ffffffffc020012e:	00905663          	blez	s1,ffffffffc020013a <readline+0x90>
            cputchar(c);
ffffffffc0200132:	09a000ef          	jal	ffffffffc02001cc <cputchar>
            i --;
ffffffffc0200136:	34fd                	addiw	s1,s1,-1
ffffffffc0200138:	bf69                	j	ffffffffc02000d2 <readline+0x28>
        else if (c == '\n' || c == '\r') {
ffffffffc020013a:	c291                	beqz	a3,ffffffffc020013e <readline+0x94>
ffffffffc020013c:	fa59                	bnez	a2,ffffffffc02000d2 <readline+0x28>
            cputchar(c);
ffffffffc020013e:	8522                	mv	a0,s0
ffffffffc0200140:	08c000ef          	jal	ffffffffc02001cc <cputchar>
            buf[i] = '\0';
ffffffffc0200144:	000c8517          	auipc	a0,0xc8
ffffffffc0200148:	c0450513          	addi	a0,a0,-1020 # ffffffffc02c7d48 <buf>
ffffffffc020014c:	94aa                	add	s1,s1,a0
ffffffffc020014e:	00048023          	sb	zero,0(s1)
}
ffffffffc0200152:	70a2                	ld	ra,40(sp)
ffffffffc0200154:	7402                	ld	s0,32(sp)
ffffffffc0200156:	64e2                	ld	s1,24(sp)
ffffffffc0200158:	6942                	ld	s2,16(sp)
ffffffffc020015a:	69a2                	ld	s3,8(sp)
ffffffffc020015c:	6145                	addi	sp,sp,48
ffffffffc020015e:	8082                	ret

ffffffffc0200160 <cputch>:
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt)
{
ffffffffc0200160:	1101                	addi	sp,sp,-32
ffffffffc0200162:	ec06                	sd	ra,24(sp)
ffffffffc0200164:	e42e                	sd	a1,8(sp)
    cons_putc(c);
ffffffffc0200166:	3dc000ef          	jal	ffffffffc0200542 <cons_putc>
    (*cnt)++;
ffffffffc020016a:	65a2                	ld	a1,8(sp)
}
ffffffffc020016c:	60e2                	ld	ra,24(sp)
    (*cnt)++;
ffffffffc020016e:	419c                	lw	a5,0(a1)
ffffffffc0200170:	2785                	addiw	a5,a5,1
ffffffffc0200172:	c19c                	sw	a5,0(a1)
}
ffffffffc0200174:	6105                	addi	sp,sp,32
ffffffffc0200176:	8082                	ret

ffffffffc0200178 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int vcprintf(const char *fmt, va_list ap)
{
ffffffffc0200178:	1101                	addi	sp,sp,-32
ffffffffc020017a:	862a                	mv	a2,a0
ffffffffc020017c:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc020017e:	00000517          	auipc	a0,0x0
ffffffffc0200182:	fe250513          	addi	a0,a0,-30 # ffffffffc0200160 <cputch>
ffffffffc0200186:	006c                	addi	a1,sp,12
{
ffffffffc0200188:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc020018a:	c602                	sw	zero,12(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc020018c:	6d3050ef          	jal	ffffffffc020605e <vprintfmt>
    return cnt;
}
ffffffffc0200190:	60e2                	ld	ra,24(sp)
ffffffffc0200192:	4532                	lw	a0,12(sp)
ffffffffc0200194:	6105                	addi	sp,sp,32
ffffffffc0200196:	8082                	ret

ffffffffc0200198 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...)
{
ffffffffc0200198:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc020019a:	02810313          	addi	t1,sp,40
{
ffffffffc020019e:	f42e                	sd	a1,40(sp)
ffffffffc02001a0:	f832                	sd	a2,48(sp)
ffffffffc02001a2:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02001a4:	862a                	mv	a2,a0
ffffffffc02001a6:	004c                	addi	a1,sp,4
ffffffffc02001a8:	00000517          	auipc	a0,0x0
ffffffffc02001ac:	fb850513          	addi	a0,a0,-72 # ffffffffc0200160 <cputch>
ffffffffc02001b0:	869a                	mv	a3,t1
{
ffffffffc02001b2:	ec06                	sd	ra,24(sp)
ffffffffc02001b4:	e0ba                	sd	a4,64(sp)
ffffffffc02001b6:	e4be                	sd	a5,72(sp)
ffffffffc02001b8:	e8c2                	sd	a6,80(sp)
ffffffffc02001ba:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
ffffffffc02001bc:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
ffffffffc02001be:	e41a                	sd	t1,8(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02001c0:	69f050ef          	jal	ffffffffc020605e <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001c4:	60e2                	ld	ra,24(sp)
ffffffffc02001c6:	4512                	lw	a0,4(sp)
ffffffffc02001c8:	6125                	addi	sp,sp,96
ffffffffc02001ca:	8082                	ret

ffffffffc02001cc <cputchar>:

/* cputchar - writes a single character to stdout */
void cputchar(int c)
{
    cons_putc(c);
ffffffffc02001cc:	ae9d                	j	ffffffffc0200542 <cons_putc>

ffffffffc02001ce <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int cputs(const char *str)
{
ffffffffc02001ce:	1101                	addi	sp,sp,-32
ffffffffc02001d0:	e822                	sd	s0,16(sp)
ffffffffc02001d2:	ec06                	sd	ra,24(sp)
ffffffffc02001d4:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str++) != '\0')
ffffffffc02001d6:	00054503          	lbu	a0,0(a0)
ffffffffc02001da:	c51d                	beqz	a0,ffffffffc0200208 <cputs+0x3a>
ffffffffc02001dc:	e426                	sd	s1,8(sp)
ffffffffc02001de:	0405                	addi	s0,s0,1
    int cnt = 0;
ffffffffc02001e0:	4481                	li	s1,0
    cons_putc(c);
ffffffffc02001e2:	360000ef          	jal	ffffffffc0200542 <cons_putc>
    while ((c = *str++) != '\0')
ffffffffc02001e6:	00044503          	lbu	a0,0(s0)
ffffffffc02001ea:	0405                	addi	s0,s0,1
ffffffffc02001ec:	87a6                	mv	a5,s1
    (*cnt)++;
ffffffffc02001ee:	2485                	addiw	s1,s1,1
    while ((c = *str++) != '\0')
ffffffffc02001f0:	f96d                	bnez	a0,ffffffffc02001e2 <cputs+0x14>
    cons_putc(c);
ffffffffc02001f2:	4529                	li	a0,10
    (*cnt)++;
ffffffffc02001f4:	0027841b          	addiw	s0,a5,2
ffffffffc02001f8:	64a2                	ld	s1,8(sp)
    cons_putc(c);
ffffffffc02001fa:	348000ef          	jal	ffffffffc0200542 <cons_putc>
    {
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001fe:	60e2                	ld	ra,24(sp)
ffffffffc0200200:	8522                	mv	a0,s0
ffffffffc0200202:	6442                	ld	s0,16(sp)
ffffffffc0200204:	6105                	addi	sp,sp,32
ffffffffc0200206:	8082                	ret
    cons_putc(c);
ffffffffc0200208:	4529                	li	a0,10
ffffffffc020020a:	338000ef          	jal	ffffffffc0200542 <cons_putc>
    while ((c = *str++) != '\0')
ffffffffc020020e:	4405                	li	s0,1
}
ffffffffc0200210:	60e2                	ld	ra,24(sp)
ffffffffc0200212:	8522                	mv	a0,s0
ffffffffc0200214:	6442                	ld	s0,16(sp)
ffffffffc0200216:	6105                	addi	sp,sp,32
ffffffffc0200218:	8082                	ret

ffffffffc020021a <getchar>:

/* getchar - reads a single non-zero character from stdin */
int getchar(void)
{
ffffffffc020021a:	1141                	addi	sp,sp,-16
ffffffffc020021c:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020021e:	358000ef          	jal	ffffffffc0200576 <cons_getc>
ffffffffc0200222:	dd75                	beqz	a0,ffffffffc020021e <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200224:	60a2                	ld	ra,8(sp)
ffffffffc0200226:	0141                	addi	sp,sp,16
ffffffffc0200228:	8082                	ret

ffffffffc020022a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020022a:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc020022c:	00006517          	auipc	a0,0x6
ffffffffc0200230:	2ac50513          	addi	a0,a0,684 # ffffffffc02064d8 <etext+0x36>
void print_kerninfo(void) {
ffffffffc0200234:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200236:	f63ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020023a:	00000597          	auipc	a1,0x0
ffffffffc020023e:	e1058593          	addi	a1,a1,-496 # ffffffffc020004a <kern_init>
ffffffffc0200242:	00006517          	auipc	a0,0x6
ffffffffc0200246:	2b650513          	addi	a0,a0,694 # ffffffffc02064f8 <etext+0x56>
ffffffffc020024a:	f4fff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020024e:	00006597          	auipc	a1,0x6
ffffffffc0200252:	25458593          	addi	a1,a1,596 # ffffffffc02064a2 <etext>
ffffffffc0200256:	00006517          	auipc	a0,0x6
ffffffffc020025a:	2c250513          	addi	a0,a0,706 # ffffffffc0206518 <etext+0x76>
ffffffffc020025e:	f3bff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200262:	000c8597          	auipc	a1,0xc8
ffffffffc0200266:	ae658593          	addi	a1,a1,-1306 # ffffffffc02c7d48 <buf>
ffffffffc020026a:	00006517          	auipc	a0,0x6
ffffffffc020026e:	2ce50513          	addi	a0,a0,718 # ffffffffc0206538 <etext+0x96>
ffffffffc0200272:	f27ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200276:	000cc597          	auipc	a1,0xcc
ffffffffc020027a:	10258593          	addi	a1,a1,258 # ffffffffc02cc378 <end>
ffffffffc020027e:	00006517          	auipc	a0,0x6
ffffffffc0200282:	2da50513          	addi	a0,a0,730 # ffffffffc0206558 <etext+0xb6>
ffffffffc0200286:	f13ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020028a:	00000717          	auipc	a4,0x0
ffffffffc020028e:	dc070713          	addi	a4,a4,-576 # ffffffffc020004a <kern_init>
ffffffffc0200292:	000cc797          	auipc	a5,0xcc
ffffffffc0200296:	4e578793          	addi	a5,a5,1253 # ffffffffc02cc777 <end+0x3ff>
ffffffffc020029a:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020029c:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02002a0:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002a2:	3ff5f593          	andi	a1,a1,1023
ffffffffc02002a6:	95be                	add	a1,a1,a5
ffffffffc02002a8:	85a9                	srai	a1,a1,0xa
ffffffffc02002aa:	00006517          	auipc	a0,0x6
ffffffffc02002ae:	2ce50513          	addi	a0,a0,718 # ffffffffc0206578 <etext+0xd6>
}
ffffffffc02002b2:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002b4:	b5d5                	j	ffffffffc0200198 <cprintf>

ffffffffc02002b6 <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc02002b6:	1141                	addi	sp,sp,-16
    
    panic("Not Implemented!");
ffffffffc02002b8:	00006617          	auipc	a2,0x6
ffffffffc02002bc:	2f060613          	addi	a2,a2,752 # ffffffffc02065a8 <etext+0x106>
ffffffffc02002c0:	04e00593          	li	a1,78
ffffffffc02002c4:	00006517          	auipc	a0,0x6
ffffffffc02002c8:	2fc50513          	addi	a0,a0,764 # ffffffffc02065c0 <etext+0x11e>
void print_stackframe(void) {
ffffffffc02002cc:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002ce:	17c000ef          	jal	ffffffffc020044a <__panic>

ffffffffc02002d2 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc02002d2:	1101                	addi	sp,sp,-32
ffffffffc02002d4:	e822                	sd	s0,16(sp)
ffffffffc02002d6:	e426                	sd	s1,8(sp)
ffffffffc02002d8:	ec06                	sd	ra,24(sp)
ffffffffc02002da:	00008417          	auipc	s0,0x8
ffffffffc02002de:	47e40413          	addi	s0,s0,1150 # ffffffffc0208758 <commands>
ffffffffc02002e2:	00008497          	auipc	s1,0x8
ffffffffc02002e6:	4be48493          	addi	s1,s1,1214 # ffffffffc02087a0 <commands+0x48>
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002ea:	6410                	ld	a2,8(s0)
ffffffffc02002ec:	600c                	ld	a1,0(s0)
ffffffffc02002ee:	00006517          	auipc	a0,0x6
ffffffffc02002f2:	2ea50513          	addi	a0,a0,746 # ffffffffc02065d8 <etext+0x136>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002f6:	0461                	addi	s0,s0,24
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002f8:	ea1ff0ef          	jal	ffffffffc0200198 <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc02002fc:	fe9417e3          	bne	s0,s1,ffffffffc02002ea <mon_help+0x18>
    }
    return 0;
}
ffffffffc0200300:	60e2                	ld	ra,24(sp)
ffffffffc0200302:	6442                	ld	s0,16(sp)
ffffffffc0200304:	64a2                	ld	s1,8(sp)
ffffffffc0200306:	4501                	li	a0,0
ffffffffc0200308:	6105                	addi	sp,sp,32
ffffffffc020030a:	8082                	ret

ffffffffc020030c <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc020030c:	1141                	addi	sp,sp,-16
ffffffffc020030e:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200310:	f1bff0ef          	jal	ffffffffc020022a <print_kerninfo>
    return 0;
}
ffffffffc0200314:	60a2                	ld	ra,8(sp)
ffffffffc0200316:	4501                	li	a0,0
ffffffffc0200318:	0141                	addi	sp,sp,16
ffffffffc020031a:	8082                	ret

ffffffffc020031c <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc020031c:	1141                	addi	sp,sp,-16
ffffffffc020031e:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200320:	f97ff0ef          	jal	ffffffffc02002b6 <print_stackframe>
    return 0;
}
ffffffffc0200324:	60a2                	ld	ra,8(sp)
ffffffffc0200326:	4501                	li	a0,0
ffffffffc0200328:	0141                	addi	sp,sp,16
ffffffffc020032a:	8082                	ret

ffffffffc020032c <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc020032c:	7131                	addi	sp,sp,-192
ffffffffc020032e:	e952                	sd	s4,144(sp)
ffffffffc0200330:	8a2a                	mv	s4,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200332:	00006517          	auipc	a0,0x6
ffffffffc0200336:	2b650513          	addi	a0,a0,694 # ffffffffc02065e8 <etext+0x146>
kmonitor(struct trapframe *tf) {
ffffffffc020033a:	fd06                	sd	ra,184(sp)
ffffffffc020033c:	f922                	sd	s0,176(sp)
ffffffffc020033e:	f526                	sd	s1,168(sp)
ffffffffc0200340:	ed4e                	sd	s3,152(sp)
ffffffffc0200342:	e556                	sd	s5,136(sp)
ffffffffc0200344:	e15a                	sd	s6,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200346:	e53ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc020034a:	00006517          	auipc	a0,0x6
ffffffffc020034e:	2c650513          	addi	a0,a0,710 # ffffffffc0206610 <etext+0x16e>
ffffffffc0200352:	e47ff0ef          	jal	ffffffffc0200198 <cprintf>
    if (tf != NULL) {
ffffffffc0200356:	000a0563          	beqz	s4,ffffffffc0200360 <kmonitor+0x34>
        print_trapframe(tf);
ffffffffc020035a:	8552                	mv	a0,s4
ffffffffc020035c:	792000ef          	jal	ffffffffc0200aee <print_trapframe>
ffffffffc0200360:	00008a97          	auipc	s5,0x8
ffffffffc0200364:	3f8a8a93          	addi	s5,s5,1016 # ffffffffc0208758 <commands>
        if (argc == MAXARGS - 1) {
ffffffffc0200368:	49bd                	li	s3,15
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020036a:	00006517          	auipc	a0,0x6
ffffffffc020036e:	2ce50513          	addi	a0,a0,718 # ffffffffc0206638 <etext+0x196>
ffffffffc0200372:	d39ff0ef          	jal	ffffffffc02000aa <readline>
ffffffffc0200376:	842a                	mv	s0,a0
ffffffffc0200378:	d96d                	beqz	a0,ffffffffc020036a <kmonitor+0x3e>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020037a:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc020037e:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200380:	e99d                	bnez	a1,ffffffffc02003b6 <kmonitor+0x8a>
    int argc = 0;
ffffffffc0200382:	8b26                	mv	s6,s1
    if (argc == 0) {
ffffffffc0200384:	fe0b03e3          	beqz	s6,ffffffffc020036a <kmonitor+0x3e>
ffffffffc0200388:	00008497          	auipc	s1,0x8
ffffffffc020038c:	3d048493          	addi	s1,s1,976 # ffffffffc0208758 <commands>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200390:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200392:	6582                	ld	a1,0(sp)
ffffffffc0200394:	6088                	ld	a0,0(s1)
ffffffffc0200396:	074060ef          	jal	ffffffffc020640a <strcmp>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020039a:	478d                	li	a5,3
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc020039c:	c149                	beqz	a0,ffffffffc020041e <kmonitor+0xf2>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020039e:	2405                	addiw	s0,s0,1
ffffffffc02003a0:	04e1                	addi	s1,s1,24
ffffffffc02003a2:	fef418e3          	bne	s0,a5,ffffffffc0200392 <kmonitor+0x66>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003a6:	6582                	ld	a1,0(sp)
ffffffffc02003a8:	00006517          	auipc	a0,0x6
ffffffffc02003ac:	2c050513          	addi	a0,a0,704 # ffffffffc0206668 <etext+0x1c6>
ffffffffc02003b0:	de9ff0ef          	jal	ffffffffc0200198 <cprintf>
    return 0;
ffffffffc02003b4:	bf5d                	j	ffffffffc020036a <kmonitor+0x3e>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b6:	00006517          	auipc	a0,0x6
ffffffffc02003ba:	28a50513          	addi	a0,a0,650 # ffffffffc0206640 <etext+0x19e>
ffffffffc02003be:	0a8060ef          	jal	ffffffffc0206466 <strchr>
ffffffffc02003c2:	c901                	beqz	a0,ffffffffc02003d2 <kmonitor+0xa6>
ffffffffc02003c4:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc02003c8:	00040023          	sb	zero,0(s0)
ffffffffc02003cc:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003ce:	d9d5                	beqz	a1,ffffffffc0200382 <kmonitor+0x56>
ffffffffc02003d0:	b7dd                	j	ffffffffc02003b6 <kmonitor+0x8a>
        if (*buf == '\0') {
ffffffffc02003d2:	00044783          	lbu	a5,0(s0)
ffffffffc02003d6:	d7d5                	beqz	a5,ffffffffc0200382 <kmonitor+0x56>
        if (argc == MAXARGS - 1) {
ffffffffc02003d8:	03348b63          	beq	s1,s3,ffffffffc020040e <kmonitor+0xe2>
        argv[argc ++] = buf;
ffffffffc02003dc:	00349793          	slli	a5,s1,0x3
ffffffffc02003e0:	978a                	add	a5,a5,sp
ffffffffc02003e2:	e380                	sd	s0,0(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003e4:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc02003e8:	2485                	addiw	s1,s1,1
ffffffffc02003ea:	8b26                	mv	s6,s1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003ec:	e591                	bnez	a1,ffffffffc02003f8 <kmonitor+0xcc>
ffffffffc02003ee:	bf59                	j	ffffffffc0200384 <kmonitor+0x58>
ffffffffc02003f0:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc02003f4:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc02003f6:	d5d1                	beqz	a1,ffffffffc0200382 <kmonitor+0x56>
ffffffffc02003f8:	00006517          	auipc	a0,0x6
ffffffffc02003fc:	24850513          	addi	a0,a0,584 # ffffffffc0206640 <etext+0x19e>
ffffffffc0200400:	066060ef          	jal	ffffffffc0206466 <strchr>
ffffffffc0200404:	d575                	beqz	a0,ffffffffc02003f0 <kmonitor+0xc4>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200406:	00044583          	lbu	a1,0(s0)
ffffffffc020040a:	dda5                	beqz	a1,ffffffffc0200382 <kmonitor+0x56>
ffffffffc020040c:	b76d                	j	ffffffffc02003b6 <kmonitor+0x8a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020040e:	45c1                	li	a1,16
ffffffffc0200410:	00006517          	auipc	a0,0x6
ffffffffc0200414:	23850513          	addi	a0,a0,568 # ffffffffc0206648 <etext+0x1a6>
ffffffffc0200418:	d81ff0ef          	jal	ffffffffc0200198 <cprintf>
ffffffffc020041c:	b7c1                	j	ffffffffc02003dc <kmonitor+0xb0>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020041e:	00141793          	slli	a5,s0,0x1
ffffffffc0200422:	97a2                	add	a5,a5,s0
ffffffffc0200424:	078e                	slli	a5,a5,0x3
ffffffffc0200426:	97d6                	add	a5,a5,s5
ffffffffc0200428:	6b9c                	ld	a5,16(a5)
ffffffffc020042a:	fffb051b          	addiw	a0,s6,-1
ffffffffc020042e:	8652                	mv	a2,s4
ffffffffc0200430:	002c                	addi	a1,sp,8
ffffffffc0200432:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc0200434:	f2055be3          	bgez	a0,ffffffffc020036a <kmonitor+0x3e>
}
ffffffffc0200438:	70ea                	ld	ra,184(sp)
ffffffffc020043a:	744a                	ld	s0,176(sp)
ffffffffc020043c:	74aa                	ld	s1,168(sp)
ffffffffc020043e:	69ea                	ld	s3,152(sp)
ffffffffc0200440:	6a4a                	ld	s4,144(sp)
ffffffffc0200442:	6aaa                	ld	s5,136(sp)
ffffffffc0200444:	6b0a                	ld	s6,128(sp)
ffffffffc0200446:	6129                	addi	sp,sp,192
ffffffffc0200448:	8082                	ret

ffffffffc020044a <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc020044a:	000cc317          	auipc	t1,0xcc
ffffffffc020044e:	ea633303          	ld	t1,-346(t1) # ffffffffc02cc2f0 <is_panic>
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc0200452:	715d                	addi	sp,sp,-80
ffffffffc0200454:	ec06                	sd	ra,24(sp)
ffffffffc0200456:	f436                	sd	a3,40(sp)
ffffffffc0200458:	f83a                	sd	a4,48(sp)
ffffffffc020045a:	fc3e                	sd	a5,56(sp)
ffffffffc020045c:	e0c2                	sd	a6,64(sp)
ffffffffc020045e:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc0200460:	02031e63          	bnez	t1,ffffffffc020049c <__panic+0x52>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200464:	4705                	li	a4,1

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200466:	103c                	addi	a5,sp,40
ffffffffc0200468:	e822                	sd	s0,16(sp)
ffffffffc020046a:	8432                	mv	s0,a2
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020046c:	862e                	mv	a2,a1
ffffffffc020046e:	85aa                	mv	a1,a0
ffffffffc0200470:	00006517          	auipc	a0,0x6
ffffffffc0200474:	2a050513          	addi	a0,a0,672 # ffffffffc0206710 <etext+0x26e>
    is_panic = 1;
ffffffffc0200478:	000cc697          	auipc	a3,0xcc
ffffffffc020047c:	e6e6bc23          	sd	a4,-392(a3) # ffffffffc02cc2f0 <is_panic>
    va_start(ap, fmt);
ffffffffc0200480:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200482:	d17ff0ef          	jal	ffffffffc0200198 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200486:	65a2                	ld	a1,8(sp)
ffffffffc0200488:	8522                	mv	a0,s0
ffffffffc020048a:	cefff0ef          	jal	ffffffffc0200178 <vcprintf>
    cprintf("\n");
ffffffffc020048e:	00006517          	auipc	a0,0x6
ffffffffc0200492:	2a250513          	addi	a0,a0,674 # ffffffffc0206730 <etext+0x28e>
ffffffffc0200496:	d03ff0ef          	jal	ffffffffc0200198 <cprintf>
ffffffffc020049a:	6442                	ld	s0,16(sp)
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc020049c:	4501                	li	a0,0
ffffffffc020049e:	4581                	li	a1,0
ffffffffc02004a0:	4601                	li	a2,0
ffffffffc02004a2:	48a1                	li	a7,8
ffffffffc02004a4:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004a8:	456000ef          	jal	ffffffffc02008fe <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc02004ac:	4501                	li	a0,0
ffffffffc02004ae:	e7fff0ef          	jal	ffffffffc020032c <kmonitor>
    while (1) {
ffffffffc02004b2:	bfed                	j	ffffffffc02004ac <__panic+0x62>

ffffffffc02004b4 <__warn>:
    }
}

/* __warn - like panic, but don't */
void
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004b4:	715d                	addi	sp,sp,-80
ffffffffc02004b6:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004b8:	02810313          	addi	t1,sp,40
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004bc:	8432                	mv	s0,a2
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004be:	862e                	mv	a2,a1
ffffffffc02004c0:	85aa                	mv	a1,a0
ffffffffc02004c2:	00006517          	auipc	a0,0x6
ffffffffc02004c6:	27650513          	addi	a0,a0,630 # ffffffffc0206738 <etext+0x296>
__warn(const char *file, int line, const char *fmt, ...) {
ffffffffc02004ca:	ec06                	sd	ra,24(sp)
ffffffffc02004cc:	f436                	sd	a3,40(sp)
ffffffffc02004ce:	f83a                	sd	a4,48(sp)
ffffffffc02004d0:	fc3e                	sd	a5,56(sp)
ffffffffc02004d2:	e0c2                	sd	a6,64(sp)
ffffffffc02004d4:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02004d6:	e41a                	sd	t1,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004d8:	cc1ff0ef          	jal	ffffffffc0200198 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004dc:	65a2                	ld	a1,8(sp)
ffffffffc02004de:	8522                	mv	a0,s0
ffffffffc02004e0:	c99ff0ef          	jal	ffffffffc0200178 <vcprintf>
    cprintf("\n");
ffffffffc02004e4:	00006517          	auipc	a0,0x6
ffffffffc02004e8:	24c50513          	addi	a0,a0,588 # ffffffffc0206730 <etext+0x28e>
ffffffffc02004ec:	cadff0ef          	jal	ffffffffc0200198 <cprintf>
    va_end(ap);
}
ffffffffc02004f0:	60e2                	ld	ra,24(sp)
ffffffffc02004f2:	6442                	ld	s0,16(sp)
ffffffffc02004f4:	6161                	addi	sp,sp,80
ffffffffc02004f6:	8082                	ret

ffffffffc02004f8 <clock_init>:
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void)
{
    set_csr(sie, MIP_STIP);
ffffffffc02004f8:	02000793          	li	a5,32
ffffffffc02004fc:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200500:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200504:	67e1                	lui	a5,0x18
ffffffffc0200506:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_matrix_out_size+0xcfb8>
ffffffffc020050a:	953e                	add	a0,a0,a5
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020050c:	4581                	li	a1,0
ffffffffc020050e:	4601                	li	a2,0
ffffffffc0200510:	4881                	li	a7,0
ffffffffc0200512:	00000073          	ecall
    cprintf("++ setup timer interrupts\n");
ffffffffc0200516:	00006517          	auipc	a0,0x6
ffffffffc020051a:	24250513          	addi	a0,a0,578 # ffffffffc0206758 <etext+0x2b6>
    ticks = 0;
ffffffffc020051e:	000cc797          	auipc	a5,0xcc
ffffffffc0200522:	dc07bd23          	sd	zero,-550(a5) # ffffffffc02cc2f8 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200526:	b98d                	j	ffffffffc0200198 <cprintf>

ffffffffc0200528 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200528:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020052c:	67e1                	lui	a5,0x18
ffffffffc020052e:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_matrix_out_size+0xcfb8>
ffffffffc0200532:	953e                	add	a0,a0,a5
ffffffffc0200534:	4581                	li	a1,0
ffffffffc0200536:	4601                	li	a2,0
ffffffffc0200538:	4881                	li	a7,0
ffffffffc020053a:	00000073          	ecall
ffffffffc020053e:	8082                	ret

ffffffffc0200540 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200540:	8082                	ret

ffffffffc0200542 <cons_putc>:
#include <riscv.h>
#include <assert.h>
#include <atomic.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200542:	100027f3          	csrr	a5,sstatus
ffffffffc0200546:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200548:	0ff57513          	zext.b	a0,a0
ffffffffc020054c:	e799                	bnez	a5,ffffffffc020055a <cons_putc+0x18>
ffffffffc020054e:	4581                	li	a1,0
ffffffffc0200550:	4601                	li	a2,0
ffffffffc0200552:	4885                	li	a7,1
ffffffffc0200554:	00000073          	ecall
    }
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
ffffffffc0200558:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc020055a:	1101                	addi	sp,sp,-32
ffffffffc020055c:	ec06                	sd	ra,24(sp)
ffffffffc020055e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200560:	39e000ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc0200564:	6522                	ld	a0,8(sp)
ffffffffc0200566:	4581                	li	a1,0
ffffffffc0200568:	4601                	li	a2,0
ffffffffc020056a:	4885                	li	a7,1
ffffffffc020056c:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200570:	60e2                	ld	ra,24(sp)
ffffffffc0200572:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0200574:	a651                	j	ffffffffc02008f8 <intr_enable>

ffffffffc0200576 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0200576:	100027f3          	csrr	a5,sstatus
ffffffffc020057a:	8b89                	andi	a5,a5,2
ffffffffc020057c:	eb89                	bnez	a5,ffffffffc020058e <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc020057e:	4501                	li	a0,0
ffffffffc0200580:	4581                	li	a1,0
ffffffffc0200582:	4601                	li	a2,0
ffffffffc0200584:	4889                	li	a7,2
ffffffffc0200586:	00000073          	ecall
ffffffffc020058a:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc020058c:	8082                	ret
int cons_getc(void) {
ffffffffc020058e:	1101                	addi	sp,sp,-32
ffffffffc0200590:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200592:	36c000ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc0200596:	4501                	li	a0,0
ffffffffc0200598:	4581                	li	a1,0
ffffffffc020059a:	4601                	li	a2,0
ffffffffc020059c:	4889                	li	a7,2
ffffffffc020059e:	00000073          	ecall
ffffffffc02005a2:	2501                	sext.w	a0,a0
ffffffffc02005a4:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005a6:	352000ef          	jal	ffffffffc02008f8 <intr_enable>
}
ffffffffc02005aa:	60e2                	ld	ra,24(sp)
ffffffffc02005ac:	6522                	ld	a0,8(sp)
ffffffffc02005ae:	6105                	addi	sp,sp,32
ffffffffc02005b0:	8082                	ret

ffffffffc02005b2 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc02005b2:	7179                	addi	sp,sp,-48
    cprintf("DTB Init\n");
ffffffffc02005b4:	00006517          	auipc	a0,0x6
ffffffffc02005b8:	1c450513          	addi	a0,a0,452 # ffffffffc0206778 <etext+0x2d6>
void dtb_init(void) {
ffffffffc02005bc:	f406                	sd	ra,40(sp)
ffffffffc02005be:	f022                	sd	s0,32(sp)
    cprintf("DTB Init\n");
ffffffffc02005c0:	bd9ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc02005c4:	0000d597          	auipc	a1,0xd
ffffffffc02005c8:	a3c5b583          	ld	a1,-1476(a1) # ffffffffc020d000 <boot_hartid>
ffffffffc02005cc:	00006517          	auipc	a0,0x6
ffffffffc02005d0:	1bc50513          	addi	a0,a0,444 # ffffffffc0206788 <etext+0x2e6>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc02005d4:	0000d417          	auipc	s0,0xd
ffffffffc02005d8:	a3440413          	addi	s0,s0,-1484 # ffffffffc020d008 <boot_dtb>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc02005dc:	bbdff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc02005e0:	600c                	ld	a1,0(s0)
ffffffffc02005e2:	00006517          	auipc	a0,0x6
ffffffffc02005e6:	1b650513          	addi	a0,a0,438 # ffffffffc0206798 <etext+0x2f6>
ffffffffc02005ea:	bafff0ef          	jal	ffffffffc0200198 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc02005ee:	6018                	ld	a4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc02005f0:	00006517          	auipc	a0,0x6
ffffffffc02005f4:	1c050513          	addi	a0,a0,448 # ffffffffc02067b0 <etext+0x30e>
    if (boot_dtb == 0) {
ffffffffc02005f8:	10070163          	beqz	a4,ffffffffc02006fa <dtb_init+0x148>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc02005fc:	57f5                	li	a5,-3
ffffffffc02005fe:	07fa                	slli	a5,a5,0x1e
ffffffffc0200600:	973e                	add	a4,a4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc0200602:	431c                	lw	a5,0(a4)
    if (magic != 0xd00dfeed) {
ffffffffc0200604:	d00e06b7          	lui	a3,0xd00e0
ffffffffc0200608:	eed68693          	addi	a3,a3,-275 # ffffffffd00dfeed <end+0xfe13b75>
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020060c:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200610:	0187961b          	slliw	a2,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200614:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200618:	0ff5f593          	zext.b	a1,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020061c:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200620:	05c2                	slli	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200622:	8e49                	or	a2,a2,a0
ffffffffc0200624:	0ff7f793          	zext.b	a5,a5
ffffffffc0200628:	8dd1                	or	a1,a1,a2
ffffffffc020062a:	07a2                	slli	a5,a5,0x8
ffffffffc020062c:	8ddd                	or	a1,a1,a5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020062e:	00ff0837          	lui	a6,0xff0
    if (magic != 0xd00dfeed) {
ffffffffc0200632:	0cd59863          	bne	a1,a3,ffffffffc0200702 <dtb_init+0x150>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc0200636:	4710                	lw	a2,8(a4)
ffffffffc0200638:	4754                	lw	a3,12(a4)
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020063a:	e84a                	sd	s2,16(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020063c:	0086541b          	srliw	s0,a2,0x8
ffffffffc0200640:	0086d79b          	srliw	a5,a3,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200644:	01865e1b          	srliw	t3,a2,0x18
ffffffffc0200648:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020064c:	0186151b          	slliw	a0,a2,0x18
ffffffffc0200650:	0186959b          	slliw	a1,a3,0x18
ffffffffc0200654:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200658:	0106561b          	srliw	a2,a2,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020065c:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200660:	0106d69b          	srliw	a3,a3,0x10
ffffffffc0200664:	01c56533          	or	a0,a0,t3
ffffffffc0200668:	0115e5b3          	or	a1,a1,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020066c:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200670:	0ff67613          	zext.b	a2,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200674:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200678:	0ff6f693          	zext.b	a3,a3
ffffffffc020067c:	8c49                	or	s0,s0,a0
ffffffffc020067e:	0622                	slli	a2,a2,0x8
ffffffffc0200680:	8fcd                	or	a5,a5,a1
ffffffffc0200682:	06a2                	slli	a3,a3,0x8
ffffffffc0200684:	8c51                	or	s0,s0,a2
ffffffffc0200686:	8fd5                	or	a5,a5,a3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200688:	1402                	slli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020068a:	1782                	slli	a5,a5,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020068c:	9001                	srli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020068e:	9381                	srli	a5,a5,0x20
ffffffffc0200690:	ec26                	sd	s1,24(sp)
    int in_memory_node = 0;
ffffffffc0200692:	4301                	li	t1,0
        switch (token) {
ffffffffc0200694:	488d                	li	a7,3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200696:	943a                	add	s0,s0,a4
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200698:	00e78933          	add	s2,a5,a4
        switch (token) {
ffffffffc020069c:	4e05                	li	t3,1
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc020069e:	4018                	lw	a4,0(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006a0:	0087579b          	srliw	a5,a4,0x8
ffffffffc02006a4:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006a8:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006ac:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006b0:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006b4:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006b8:	8ed1                	or	a3,a3,a2
ffffffffc02006ba:	0ff77713          	zext.b	a4,a4
ffffffffc02006be:	8fd5                	or	a5,a5,a3
ffffffffc02006c0:	0722                	slli	a4,a4,0x8
ffffffffc02006c2:	8fd9                	or	a5,a5,a4
        switch (token) {
ffffffffc02006c4:	05178763          	beq	a5,a7,ffffffffc0200712 <dtb_init+0x160>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc02006c8:	0411                	addi	s0,s0,4
        switch (token) {
ffffffffc02006ca:	00f8e963          	bltu	a7,a5,ffffffffc02006dc <dtb_init+0x12a>
ffffffffc02006ce:	07c78d63          	beq	a5,t3,ffffffffc0200748 <dtb_init+0x196>
ffffffffc02006d2:	4709                	li	a4,2
ffffffffc02006d4:	00e79763          	bne	a5,a4,ffffffffc02006e2 <dtb_init+0x130>
ffffffffc02006d8:	4301                	li	t1,0
ffffffffc02006da:	b7d1                	j	ffffffffc020069e <dtb_init+0xec>
ffffffffc02006dc:	4711                	li	a4,4
ffffffffc02006de:	fce780e3          	beq	a5,a4,ffffffffc020069e <dtb_init+0xec>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc02006e2:	00006517          	auipc	a0,0x6
ffffffffc02006e6:	19650513          	addi	a0,a0,406 # ffffffffc0206878 <etext+0x3d6>
ffffffffc02006ea:	aafff0ef          	jal	ffffffffc0200198 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc02006ee:	64e2                	ld	s1,24(sp)
ffffffffc02006f0:	6942                	ld	s2,16(sp)
ffffffffc02006f2:	00006517          	auipc	a0,0x6
ffffffffc02006f6:	1be50513          	addi	a0,a0,446 # ffffffffc02068b0 <etext+0x40e>
}
ffffffffc02006fa:	7402                	ld	s0,32(sp)
ffffffffc02006fc:	70a2                	ld	ra,40(sp)
ffffffffc02006fe:	6145                	addi	sp,sp,48
    cprintf("DTB init completed\n");
ffffffffc0200700:	bc61                	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200702:	7402                	ld	s0,32(sp)
ffffffffc0200704:	70a2                	ld	ra,40(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200706:	00006517          	auipc	a0,0x6
ffffffffc020070a:	0ca50513          	addi	a0,a0,202 # ffffffffc02067d0 <etext+0x32e>
}
ffffffffc020070e:	6145                	addi	sp,sp,48
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200710:	b461                	j	ffffffffc0200198 <cprintf>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200712:	4058                	lw	a4,4(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200714:	0087579b          	srliw	a5,a4,0x8
ffffffffc0200718:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020071c:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200720:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200724:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200728:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020072c:	8ed1                	or	a3,a3,a2
ffffffffc020072e:	0ff77713          	zext.b	a4,a4
ffffffffc0200732:	8fd5                	or	a5,a5,a3
ffffffffc0200734:	0722                	slli	a4,a4,0x8
ffffffffc0200736:	8fd9                	or	a5,a5,a4
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200738:	04031463          	bnez	t1,ffffffffc0200780 <dtb_init+0x1ce>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc020073c:	1782                	slli	a5,a5,0x20
ffffffffc020073e:	9381                	srli	a5,a5,0x20
ffffffffc0200740:	043d                	addi	s0,s0,15
ffffffffc0200742:	943e                	add	s0,s0,a5
ffffffffc0200744:	9871                	andi	s0,s0,-4
                break;
ffffffffc0200746:	bfa1                	j	ffffffffc020069e <dtb_init+0xec>
                int name_len = strlen(name);
ffffffffc0200748:	8522                	mv	a0,s0
ffffffffc020074a:	e01a                	sd	t1,0(sp)
ffffffffc020074c:	479050ef          	jal	ffffffffc02063c4 <strlen>
ffffffffc0200750:	84aa                	mv	s1,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200752:	4619                	li	a2,6
ffffffffc0200754:	8522                	mv	a0,s0
ffffffffc0200756:	00006597          	auipc	a1,0x6
ffffffffc020075a:	0a258593          	addi	a1,a1,162 # ffffffffc02067f8 <etext+0x356>
ffffffffc020075e:	4e1050ef          	jal	ffffffffc020643e <strncmp>
ffffffffc0200762:	6302                	ld	t1,0(sp)
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc0200764:	0411                	addi	s0,s0,4
ffffffffc0200766:	0004879b          	sext.w	a5,s1
ffffffffc020076a:	943e                	add	s0,s0,a5
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020076c:	00153513          	seqz	a0,a0
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc0200770:	9871                	andi	s0,s0,-4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200772:	00a36333          	or	t1,t1,a0
                break;
ffffffffc0200776:	00ff0837          	lui	a6,0xff0
ffffffffc020077a:	488d                	li	a7,3
ffffffffc020077c:	4e05                	li	t3,1
ffffffffc020077e:	b705                	j	ffffffffc020069e <dtb_init+0xec>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200780:	4418                	lw	a4,8(s0)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200782:	00006597          	auipc	a1,0x6
ffffffffc0200786:	07e58593          	addi	a1,a1,126 # ffffffffc0206800 <etext+0x35e>
ffffffffc020078a:	e43e                	sd	a5,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020078c:	0087551b          	srliw	a0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200790:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200794:	0187169b          	slliw	a3,a4,0x18
ffffffffc0200798:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020079c:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007a0:	01057533          	and	a0,a0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007a4:	8ed1                	or	a3,a3,a2
ffffffffc02007a6:	0ff77713          	zext.b	a4,a4
ffffffffc02007aa:	0722                	slli	a4,a4,0x8
ffffffffc02007ac:	8d55                	or	a0,a0,a3
ffffffffc02007ae:	8d59                	or	a0,a0,a4
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc02007b0:	1502                	slli	a0,a0,0x20
ffffffffc02007b2:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02007b4:	954a                	add	a0,a0,s2
ffffffffc02007b6:	e01a                	sd	t1,0(sp)
ffffffffc02007b8:	453050ef          	jal	ffffffffc020640a <strcmp>
ffffffffc02007bc:	67a2                	ld	a5,8(sp)
ffffffffc02007be:	473d                	li	a4,15
ffffffffc02007c0:	6302                	ld	t1,0(sp)
ffffffffc02007c2:	00ff0837          	lui	a6,0xff0
ffffffffc02007c6:	488d                	li	a7,3
ffffffffc02007c8:	4e05                	li	t3,1
ffffffffc02007ca:	f6f779e3          	bgeu	a4,a5,ffffffffc020073c <dtb_init+0x18a>
ffffffffc02007ce:	f53d                	bnez	a0,ffffffffc020073c <dtb_init+0x18a>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc02007d0:	00c43683          	ld	a3,12(s0)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc02007d4:	01443703          	ld	a4,20(s0)
        cprintf("Physical Memory from DTB:\n");
ffffffffc02007d8:	00006517          	auipc	a0,0x6
ffffffffc02007dc:	03050513          	addi	a0,a0,48 # ffffffffc0206808 <etext+0x366>
           fdt32_to_cpu(x >> 32);
ffffffffc02007e0:	4206d793          	srai	a5,a3,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007e4:	0087d31b          	srliw	t1,a5,0x8
ffffffffc02007e8:	00871f93          	slli	t6,a4,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc02007ec:	42075893          	srai	a7,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007f0:	0187df1b          	srliw	t5,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007f4:	0187959b          	slliw	a1,a5,0x18
ffffffffc02007f8:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007fc:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200800:	420fd613          	srai	a2,t6,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200804:	0188de9b          	srliw	t4,a7,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200808:	01037333          	and	t1,t1,a6
ffffffffc020080c:	01889e1b          	slliw	t3,a7,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200810:	01e5e5b3          	or	a1,a1,t5
ffffffffc0200814:	0ff7f793          	zext.b	a5,a5
ffffffffc0200818:	01de6e33          	or	t3,t3,t4
ffffffffc020081c:	0065e5b3          	or	a1,a1,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200820:	01067633          	and	a2,a2,a6
ffffffffc0200824:	0086d31b          	srliw	t1,a3,0x8
ffffffffc0200828:	0087541b          	srliw	s0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020082c:	07a2                	slli	a5,a5,0x8
ffffffffc020082e:	0108d89b          	srliw	a7,a7,0x10
ffffffffc0200832:	0186df1b          	srliw	t5,a3,0x18
ffffffffc0200836:	01875e9b          	srliw	t4,a4,0x18
ffffffffc020083a:	8ddd                	or	a1,a1,a5
ffffffffc020083c:	01c66633          	or	a2,a2,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200840:	0186979b          	slliw	a5,a3,0x18
ffffffffc0200844:	01871e1b          	slliw	t3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200848:	0ff8f893          	zext.b	a7,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020084c:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200850:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200854:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200858:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020085c:	01037333          	and	t1,t1,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200860:	08a2                	slli	a7,a7,0x8
ffffffffc0200862:	01e7e7b3          	or	a5,a5,t5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200866:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020086a:	0ff6f693          	zext.b	a3,a3
ffffffffc020086e:	01de6833          	or	a6,t3,t4
ffffffffc0200872:	0ff77713          	zext.b	a4,a4
ffffffffc0200876:	01166633          	or	a2,a2,a7
ffffffffc020087a:	0067e7b3          	or	a5,a5,t1
ffffffffc020087e:	06a2                	slli	a3,a3,0x8
ffffffffc0200880:	01046433          	or	s0,s0,a6
ffffffffc0200884:	0722                	slli	a4,a4,0x8
ffffffffc0200886:	8fd5                	or	a5,a5,a3
ffffffffc0200888:	8c59                	or	s0,s0,a4
           fdt32_to_cpu(x >> 32);
ffffffffc020088a:	1582                	slli	a1,a1,0x20
ffffffffc020088c:	1602                	slli	a2,a2,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020088e:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200890:	9201                	srli	a2,a2,0x20
ffffffffc0200892:	9181                	srli	a1,a1,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200894:	1402                	slli	s0,s0,0x20
ffffffffc0200896:	00b7e4b3          	or	s1,a5,a1
ffffffffc020089a:	8c51                	or	s0,s0,a2
        cprintf("Physical Memory from DTB:\n");
ffffffffc020089c:	8fdff0ef          	jal	ffffffffc0200198 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc02008a0:	85a6                	mv	a1,s1
ffffffffc02008a2:	00006517          	auipc	a0,0x6
ffffffffc02008a6:	f8650513          	addi	a0,a0,-122 # ffffffffc0206828 <etext+0x386>
ffffffffc02008aa:	8efff0ef          	jal	ffffffffc0200198 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc02008ae:	01445613          	srli	a2,s0,0x14
ffffffffc02008b2:	85a2                	mv	a1,s0
ffffffffc02008b4:	00006517          	auipc	a0,0x6
ffffffffc02008b8:	f8c50513          	addi	a0,a0,-116 # ffffffffc0206840 <etext+0x39e>
ffffffffc02008bc:	8ddff0ef          	jal	ffffffffc0200198 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc02008c0:	009405b3          	add	a1,s0,s1
ffffffffc02008c4:	15fd                	addi	a1,a1,-1
ffffffffc02008c6:	00006517          	auipc	a0,0x6
ffffffffc02008ca:	f9a50513          	addi	a0,a0,-102 # ffffffffc0206860 <etext+0x3be>
ffffffffc02008ce:	8cbff0ef          	jal	ffffffffc0200198 <cprintf>
        memory_base = mem_base;
ffffffffc02008d2:	000cc797          	auipc	a5,0xcc
ffffffffc02008d6:	a297bb23          	sd	s1,-1482(a5) # ffffffffc02cc308 <memory_base>
        memory_size = mem_size;
ffffffffc02008da:	000cc797          	auipc	a5,0xcc
ffffffffc02008de:	a287b323          	sd	s0,-1498(a5) # ffffffffc02cc300 <memory_size>
ffffffffc02008e2:	b531                	j	ffffffffc02006ee <dtb_init+0x13c>

ffffffffc02008e4 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02008e4:	000cc517          	auipc	a0,0xcc
ffffffffc02008e8:	a2453503          	ld	a0,-1500(a0) # ffffffffc02cc308 <memory_base>
ffffffffc02008ec:	8082                	ret

ffffffffc02008ee <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc02008ee:	000cc517          	auipc	a0,0xcc
ffffffffc02008f2:	a1253503          	ld	a0,-1518(a0) # ffffffffc02cc300 <memory_size>
ffffffffc02008f6:	8082                	ret

ffffffffc02008f8 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02008f8:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02008fc:	8082                	ret

ffffffffc02008fe <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02008fe:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200902:	8082                	ret

ffffffffc0200904 <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc0200904:	8082                	ret

ffffffffc0200906 <idt_init>:
void idt_init(void)
{
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc0200906:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc020090a:	00000797          	auipc	a5,0x0
ffffffffc020090e:	46e78793          	addi	a5,a5,1134 # ffffffffc0200d78 <__alltraps>
ffffffffc0200912:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc0200916:	000407b7          	lui	a5,0x40
ffffffffc020091a:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc020091e:	8082                	ret

ffffffffc0200920 <print_regs>:
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200920:	610c                	ld	a1,0(a0)
{
ffffffffc0200922:	1141                	addi	sp,sp,-16
ffffffffc0200924:	e022                	sd	s0,0(sp)
ffffffffc0200926:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200928:	00006517          	auipc	a0,0x6
ffffffffc020092c:	fa050513          	addi	a0,a0,-96 # ffffffffc02068c8 <etext+0x426>
{
ffffffffc0200930:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200932:	867ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200936:	640c                	ld	a1,8(s0)
ffffffffc0200938:	00006517          	auipc	a0,0x6
ffffffffc020093c:	fa850513          	addi	a0,a0,-88 # ffffffffc02068e0 <etext+0x43e>
ffffffffc0200940:	859ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200944:	680c                	ld	a1,16(s0)
ffffffffc0200946:	00006517          	auipc	a0,0x6
ffffffffc020094a:	fb250513          	addi	a0,a0,-78 # ffffffffc02068f8 <etext+0x456>
ffffffffc020094e:	84bff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200952:	6c0c                	ld	a1,24(s0)
ffffffffc0200954:	00006517          	auipc	a0,0x6
ffffffffc0200958:	fbc50513          	addi	a0,a0,-68 # ffffffffc0206910 <etext+0x46e>
ffffffffc020095c:	83dff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200960:	700c                	ld	a1,32(s0)
ffffffffc0200962:	00006517          	auipc	a0,0x6
ffffffffc0200966:	fc650513          	addi	a0,a0,-58 # ffffffffc0206928 <etext+0x486>
ffffffffc020096a:	82fff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc020096e:	740c                	ld	a1,40(s0)
ffffffffc0200970:	00006517          	auipc	a0,0x6
ffffffffc0200974:	fd050513          	addi	a0,a0,-48 # ffffffffc0206940 <etext+0x49e>
ffffffffc0200978:	821ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc020097c:	780c                	ld	a1,48(s0)
ffffffffc020097e:	00006517          	auipc	a0,0x6
ffffffffc0200982:	fda50513          	addi	a0,a0,-38 # ffffffffc0206958 <etext+0x4b6>
ffffffffc0200986:	813ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc020098a:	7c0c                	ld	a1,56(s0)
ffffffffc020098c:	00006517          	auipc	a0,0x6
ffffffffc0200990:	fe450513          	addi	a0,a0,-28 # ffffffffc0206970 <etext+0x4ce>
ffffffffc0200994:	805ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200998:	602c                	ld	a1,64(s0)
ffffffffc020099a:	00006517          	auipc	a0,0x6
ffffffffc020099e:	fee50513          	addi	a0,a0,-18 # ffffffffc0206988 <etext+0x4e6>
ffffffffc02009a2:	ff6ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02009a6:	642c                	ld	a1,72(s0)
ffffffffc02009a8:	00006517          	auipc	a0,0x6
ffffffffc02009ac:	ff850513          	addi	a0,a0,-8 # ffffffffc02069a0 <etext+0x4fe>
ffffffffc02009b0:	fe8ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02009b4:	682c                	ld	a1,80(s0)
ffffffffc02009b6:	00006517          	auipc	a0,0x6
ffffffffc02009ba:	00250513          	addi	a0,a0,2 # ffffffffc02069b8 <etext+0x516>
ffffffffc02009be:	fdaff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02009c2:	6c2c                	ld	a1,88(s0)
ffffffffc02009c4:	00006517          	auipc	a0,0x6
ffffffffc02009c8:	00c50513          	addi	a0,a0,12 # ffffffffc02069d0 <etext+0x52e>
ffffffffc02009cc:	fccff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02009d0:	702c                	ld	a1,96(s0)
ffffffffc02009d2:	00006517          	auipc	a0,0x6
ffffffffc02009d6:	01650513          	addi	a0,a0,22 # ffffffffc02069e8 <etext+0x546>
ffffffffc02009da:	fbeff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc02009de:	742c                	ld	a1,104(s0)
ffffffffc02009e0:	00006517          	auipc	a0,0x6
ffffffffc02009e4:	02050513          	addi	a0,a0,32 # ffffffffc0206a00 <etext+0x55e>
ffffffffc02009e8:	fb0ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc02009ec:	782c                	ld	a1,112(s0)
ffffffffc02009ee:	00006517          	auipc	a0,0x6
ffffffffc02009f2:	02a50513          	addi	a0,a0,42 # ffffffffc0206a18 <etext+0x576>
ffffffffc02009f6:	fa2ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc02009fa:	7c2c                	ld	a1,120(s0)
ffffffffc02009fc:	00006517          	auipc	a0,0x6
ffffffffc0200a00:	03450513          	addi	a0,a0,52 # ffffffffc0206a30 <etext+0x58e>
ffffffffc0200a04:	f94ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200a08:	604c                	ld	a1,128(s0)
ffffffffc0200a0a:	00006517          	auipc	a0,0x6
ffffffffc0200a0e:	03e50513          	addi	a0,a0,62 # ffffffffc0206a48 <etext+0x5a6>
ffffffffc0200a12:	f86ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200a16:	644c                	ld	a1,136(s0)
ffffffffc0200a18:	00006517          	auipc	a0,0x6
ffffffffc0200a1c:	04850513          	addi	a0,a0,72 # ffffffffc0206a60 <etext+0x5be>
ffffffffc0200a20:	f78ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200a24:	684c                	ld	a1,144(s0)
ffffffffc0200a26:	00006517          	auipc	a0,0x6
ffffffffc0200a2a:	05250513          	addi	a0,a0,82 # ffffffffc0206a78 <etext+0x5d6>
ffffffffc0200a2e:	f6aff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200a32:	6c4c                	ld	a1,152(s0)
ffffffffc0200a34:	00006517          	auipc	a0,0x6
ffffffffc0200a38:	05c50513          	addi	a0,a0,92 # ffffffffc0206a90 <etext+0x5ee>
ffffffffc0200a3c:	f5cff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200a40:	704c                	ld	a1,160(s0)
ffffffffc0200a42:	00006517          	auipc	a0,0x6
ffffffffc0200a46:	06650513          	addi	a0,a0,102 # ffffffffc0206aa8 <etext+0x606>
ffffffffc0200a4a:	f4eff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200a4e:	744c                	ld	a1,168(s0)
ffffffffc0200a50:	00006517          	auipc	a0,0x6
ffffffffc0200a54:	07050513          	addi	a0,a0,112 # ffffffffc0206ac0 <etext+0x61e>
ffffffffc0200a58:	f40ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200a5c:	784c                	ld	a1,176(s0)
ffffffffc0200a5e:	00006517          	auipc	a0,0x6
ffffffffc0200a62:	07a50513          	addi	a0,a0,122 # ffffffffc0206ad8 <etext+0x636>
ffffffffc0200a66:	f32ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200a6a:	7c4c                	ld	a1,184(s0)
ffffffffc0200a6c:	00006517          	auipc	a0,0x6
ffffffffc0200a70:	08450513          	addi	a0,a0,132 # ffffffffc0206af0 <etext+0x64e>
ffffffffc0200a74:	f24ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200a78:	606c                	ld	a1,192(s0)
ffffffffc0200a7a:	00006517          	auipc	a0,0x6
ffffffffc0200a7e:	08e50513          	addi	a0,a0,142 # ffffffffc0206b08 <etext+0x666>
ffffffffc0200a82:	f16ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200a86:	646c                	ld	a1,200(s0)
ffffffffc0200a88:	00006517          	auipc	a0,0x6
ffffffffc0200a8c:	09850513          	addi	a0,a0,152 # ffffffffc0206b20 <etext+0x67e>
ffffffffc0200a90:	f08ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200a94:	686c                	ld	a1,208(s0)
ffffffffc0200a96:	00006517          	auipc	a0,0x6
ffffffffc0200a9a:	0a250513          	addi	a0,a0,162 # ffffffffc0206b38 <etext+0x696>
ffffffffc0200a9e:	efaff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200aa2:	6c6c                	ld	a1,216(s0)
ffffffffc0200aa4:	00006517          	auipc	a0,0x6
ffffffffc0200aa8:	0ac50513          	addi	a0,a0,172 # ffffffffc0206b50 <etext+0x6ae>
ffffffffc0200aac:	eecff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200ab0:	706c                	ld	a1,224(s0)
ffffffffc0200ab2:	00006517          	auipc	a0,0x6
ffffffffc0200ab6:	0b650513          	addi	a0,a0,182 # ffffffffc0206b68 <etext+0x6c6>
ffffffffc0200aba:	edeff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200abe:	746c                	ld	a1,232(s0)
ffffffffc0200ac0:	00006517          	auipc	a0,0x6
ffffffffc0200ac4:	0c050513          	addi	a0,a0,192 # ffffffffc0206b80 <etext+0x6de>
ffffffffc0200ac8:	ed0ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200acc:	786c                	ld	a1,240(s0)
ffffffffc0200ace:	00006517          	auipc	a0,0x6
ffffffffc0200ad2:	0ca50513          	addi	a0,a0,202 # ffffffffc0206b98 <etext+0x6f6>
ffffffffc0200ad6:	ec2ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200ada:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200adc:	6402                	ld	s0,0(sp)
ffffffffc0200ade:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200ae0:	00006517          	auipc	a0,0x6
ffffffffc0200ae4:	0d050513          	addi	a0,a0,208 # ffffffffc0206bb0 <etext+0x70e>
}
ffffffffc0200ae8:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200aea:	eaeff06f          	j	ffffffffc0200198 <cprintf>

ffffffffc0200aee <print_trapframe>:
{
ffffffffc0200aee:	1141                	addi	sp,sp,-16
ffffffffc0200af0:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200af2:	85aa                	mv	a1,a0
{
ffffffffc0200af4:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200af6:	00006517          	auipc	a0,0x6
ffffffffc0200afa:	0d250513          	addi	a0,a0,210 # ffffffffc0206bc8 <etext+0x726>
{
ffffffffc0200afe:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200b00:	e98ff0ef          	jal	ffffffffc0200198 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200b04:	8522                	mv	a0,s0
ffffffffc0200b06:	e1bff0ef          	jal	ffffffffc0200920 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200b0a:	10043583          	ld	a1,256(s0)
ffffffffc0200b0e:	00006517          	auipc	a0,0x6
ffffffffc0200b12:	0d250513          	addi	a0,a0,210 # ffffffffc0206be0 <etext+0x73e>
ffffffffc0200b16:	e82ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200b1a:	10843583          	ld	a1,264(s0)
ffffffffc0200b1e:	00006517          	auipc	a0,0x6
ffffffffc0200b22:	0da50513          	addi	a0,a0,218 # ffffffffc0206bf8 <etext+0x756>
ffffffffc0200b26:	e72ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200b2a:	11043583          	ld	a1,272(s0)
ffffffffc0200b2e:	00006517          	auipc	a0,0x6
ffffffffc0200b32:	0e250513          	addi	a0,a0,226 # ffffffffc0206c10 <etext+0x76e>
ffffffffc0200b36:	e62ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b3a:	11843583          	ld	a1,280(s0)
}
ffffffffc0200b3e:	6402                	ld	s0,0(sp)
ffffffffc0200b40:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b42:	00006517          	auipc	a0,0x6
ffffffffc0200b46:	0de50513          	addi	a0,a0,222 # ffffffffc0206c20 <etext+0x77e>
}
ffffffffc0200b4a:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b4c:	e4cff06f          	j	ffffffffc0200198 <cprintf>

ffffffffc0200b50 <interrupt_handler>:
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf)
{
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause)
ffffffffc0200b50:	11853783          	ld	a5,280(a0)
ffffffffc0200b54:	472d                	li	a4,11
ffffffffc0200b56:	0786                	slli	a5,a5,0x1
ffffffffc0200b58:	8385                	srli	a5,a5,0x1
ffffffffc0200b5a:	06f76a63          	bltu	a4,a5,ffffffffc0200bce <interrupt_handler+0x7e>
ffffffffc0200b5e:	00008717          	auipc	a4,0x8
ffffffffc0200b62:	c4270713          	addi	a4,a4,-958 # ffffffffc02087a0 <commands+0x48>
ffffffffc0200b66:	078a                	slli	a5,a5,0x2
ffffffffc0200b68:	97ba                	add	a5,a5,a4
ffffffffc0200b6a:	439c                	lw	a5,0(a5)
ffffffffc0200b6c:	97ba                	add	a5,a5,a4
ffffffffc0200b6e:	8782                	jr	a5
        break;
    case IRQ_H_SOFT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_SOFT:
        cprintf("Machine software interrupt\n");
ffffffffc0200b70:	00006517          	auipc	a0,0x6
ffffffffc0200b74:	12850513          	addi	a0,a0,296 # ffffffffc0206c98 <etext+0x7f6>
ffffffffc0200b78:	e20ff06f          	j	ffffffffc0200198 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200b7c:	00006517          	auipc	a0,0x6
ffffffffc0200b80:	0fc50513          	addi	a0,a0,252 # ffffffffc0206c78 <etext+0x7d6>
ffffffffc0200b84:	e14ff06f          	j	ffffffffc0200198 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200b88:	00006517          	auipc	a0,0x6
ffffffffc0200b8c:	0b050513          	addi	a0,a0,176 # ffffffffc0206c38 <etext+0x796>
ffffffffc0200b90:	e08ff06f          	j	ffffffffc0200198 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200b94:	00006517          	auipc	a0,0x6
ffffffffc0200b98:	0c450513          	addi	a0,a0,196 # ffffffffc0206c58 <etext+0x7b6>
ffffffffc0200b9c:	dfcff06f          	j	ffffffffc0200198 <cprintf>
{
ffffffffc0200ba0:	1141                	addi	sp,sp,-16
ffffffffc0200ba2:	e406                	sd	ra,8(sp)
        // "All bits besides SSIP and USIP in the sip register are
        // read-only." -- privileged spec1.9.1, 4.1.4, p59
        // In fact, Call sbi_set_timer will clear STIP, or you can clear it
        // directly.
        // clear_csr(sip, SIP_STIP);
        clock_set_next_event();
ffffffffc0200ba4:	985ff0ef          	jal	ffffffffc0200528 <clock_set_next_event>
        ++ticks;
ffffffffc0200ba8:	000cb797          	auipc	a5,0xcb
ffffffffc0200bac:	7507b783          	ld	a5,1872(a5) # ffffffffc02cc2f8 <ticks>
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200bb0:	60a2                	ld	ra,8(sp)
        ++ticks;
ffffffffc0200bb2:	0785                	addi	a5,a5,1
ffffffffc0200bb4:	000cb717          	auipc	a4,0xcb
ffffffffc0200bb8:	74f73223          	sd	a5,1860(a4) # ffffffffc02cc2f8 <ticks>
}
ffffffffc0200bbc:	0141                	addi	sp,sp,16
        run_timer_list();
ffffffffc0200bbe:	1f40506f          	j	ffffffffc0205db2 <run_timer_list>
        cprintf("Supervisor external interrupt\n");
ffffffffc0200bc2:	00006517          	auipc	a0,0x6
ffffffffc0200bc6:	0f650513          	addi	a0,a0,246 # ffffffffc0206cb8 <etext+0x816>
ffffffffc0200bca:	dceff06f          	j	ffffffffc0200198 <cprintf>
        print_trapframe(tf);
ffffffffc0200bce:	b705                	j	ffffffffc0200aee <print_trapframe>

ffffffffc0200bd0 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf, uintptr_t kstacktop);
void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200bd0:	11853783          	ld	a5,280(a0)
ffffffffc0200bd4:	473d                	li	a4,15
ffffffffc0200bd6:	10f76e63          	bltu	a4,a5,ffffffffc0200cf2 <exception_handler+0x122>
ffffffffc0200bda:	00008717          	auipc	a4,0x8
ffffffffc0200bde:	bf670713          	addi	a4,a4,-1034 # ffffffffc02087d0 <commands+0x78>
ffffffffc0200be2:	078a                	slli	a5,a5,0x2
ffffffffc0200be4:	97ba                	add	a5,a5,a4
ffffffffc0200be6:	439c                	lw	a5,0(a5)
{
ffffffffc0200be8:	1101                	addi	sp,sp,-32
ffffffffc0200bea:	ec06                	sd	ra,24(sp)
    switch (tf->cause)
ffffffffc0200bec:	97ba                	add	a5,a5,a4
ffffffffc0200bee:	86aa                	mv	a3,a0
ffffffffc0200bf0:	8782                	jr	a5
ffffffffc0200bf2:	e42a                	sd	a0,8(sp)
        // cprintf("Environment call from U-mode\n");
        tf->epc += 4;
        syscall();
        break;
    case CAUSE_SUPERVISOR_ECALL:
        cprintf("Environment call from S-mode\n");
ffffffffc0200bf4:	00006517          	auipc	a0,0x6
ffffffffc0200bf8:	1cc50513          	addi	a0,a0,460 # ffffffffc0206dc0 <etext+0x91e>
ffffffffc0200bfc:	d9cff0ef          	jal	ffffffffc0200198 <cprintf>
        tf->epc += 4;
ffffffffc0200c00:	66a2                	ld	a3,8(sp)
ffffffffc0200c02:	1086b783          	ld	a5,264(a3)
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200c06:	60e2                	ld	ra,24(sp)
        tf->epc += 4;
ffffffffc0200c08:	0791                	addi	a5,a5,4
ffffffffc0200c0a:	10f6b423          	sd	a5,264(a3)
}
ffffffffc0200c0e:	6105                	addi	sp,sp,32
        syscall();
ffffffffc0200c10:	3540506f          	j	ffffffffc0205f64 <syscall>
}
ffffffffc0200c14:	60e2                	ld	ra,24(sp)
        cprintf("Environment call from H-mode\n");
ffffffffc0200c16:	00006517          	auipc	a0,0x6
ffffffffc0200c1a:	1ca50513          	addi	a0,a0,458 # ffffffffc0206de0 <etext+0x93e>
}
ffffffffc0200c1e:	6105                	addi	sp,sp,32
        cprintf("Environment call from H-mode\n");
ffffffffc0200c20:	d78ff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200c24:	60e2                	ld	ra,24(sp)
        cprintf("Environment call from M-mode\n");
ffffffffc0200c26:	00006517          	auipc	a0,0x6
ffffffffc0200c2a:	1da50513          	addi	a0,a0,474 # ffffffffc0206e00 <etext+0x95e>
}
ffffffffc0200c2e:	6105                	addi	sp,sp,32
        cprintf("Environment call from M-mode\n");
ffffffffc0200c30:	d68ff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200c34:	60e2                	ld	ra,24(sp)
        cprintf("Instruction page fault\n");
ffffffffc0200c36:	00006517          	auipc	a0,0x6
ffffffffc0200c3a:	1ea50513          	addi	a0,a0,490 # ffffffffc0206e20 <etext+0x97e>
}
ffffffffc0200c3e:	6105                	addi	sp,sp,32
        cprintf("Instruction page fault\n");
ffffffffc0200c40:	d58ff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200c44:	60e2                	ld	ra,24(sp)
        cprintf("Load page fault\n");
ffffffffc0200c46:	00006517          	auipc	a0,0x6
ffffffffc0200c4a:	1f250513          	addi	a0,a0,498 # ffffffffc0206e38 <etext+0x996>
}
ffffffffc0200c4e:	6105                	addi	sp,sp,32
        cprintf("Load page fault\n");
ffffffffc0200c50:	d48ff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200c54:	60e2                	ld	ra,24(sp)
        cprintf("Store/AMO page fault\n");
ffffffffc0200c56:	00006517          	auipc	a0,0x6
ffffffffc0200c5a:	1fa50513          	addi	a0,a0,506 # ffffffffc0206e50 <etext+0x9ae>
}
ffffffffc0200c5e:	6105                	addi	sp,sp,32
        cprintf("Store/AMO page fault\n");
ffffffffc0200c60:	d38ff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200c64:	60e2                	ld	ra,24(sp)
        cprintf("Instruction address misaligned\n");
ffffffffc0200c66:	00006517          	auipc	a0,0x6
ffffffffc0200c6a:	07250513          	addi	a0,a0,114 # ffffffffc0206cd8 <etext+0x836>
}
ffffffffc0200c6e:	6105                	addi	sp,sp,32
        cprintf("Instruction address misaligned\n");
ffffffffc0200c70:	d28ff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200c74:	60e2                	ld	ra,24(sp)
        cprintf("Instruction access fault\n");
ffffffffc0200c76:	00006517          	auipc	a0,0x6
ffffffffc0200c7a:	08250513          	addi	a0,a0,130 # ffffffffc0206cf8 <etext+0x856>
}
ffffffffc0200c7e:	6105                	addi	sp,sp,32
        cprintf("Instruction access fault\n");
ffffffffc0200c80:	d18ff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200c84:	60e2                	ld	ra,24(sp)
        cprintf("Illegal instruction\n");
ffffffffc0200c86:	00006517          	auipc	a0,0x6
ffffffffc0200c8a:	09250513          	addi	a0,a0,146 # ffffffffc0206d18 <etext+0x876>
}
ffffffffc0200c8e:	6105                	addi	sp,sp,32
        cprintf("Illegal instruction\n");
ffffffffc0200c90:	d08ff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200c94:	60e2                	ld	ra,24(sp)
        cprintf("Breakpoint\n");
ffffffffc0200c96:	00006517          	auipc	a0,0x6
ffffffffc0200c9a:	09a50513          	addi	a0,a0,154 # ffffffffc0206d30 <etext+0x88e>
}
ffffffffc0200c9e:	6105                	addi	sp,sp,32
        cprintf("Breakpoint\n");
ffffffffc0200ca0:	cf8ff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200ca4:	60e2                	ld	ra,24(sp)
        cprintf("Load address misaligned\n");
ffffffffc0200ca6:	00006517          	auipc	a0,0x6
ffffffffc0200caa:	09a50513          	addi	a0,a0,154 # ffffffffc0206d40 <etext+0x89e>
}
ffffffffc0200cae:	6105                	addi	sp,sp,32
        cprintf("Load address misaligned\n");
ffffffffc0200cb0:	ce8ff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200cb4:	60e2                	ld	ra,24(sp)
        cprintf("Load access fault\n");
ffffffffc0200cb6:	00006517          	auipc	a0,0x6
ffffffffc0200cba:	0aa50513          	addi	a0,a0,170 # ffffffffc0206d60 <etext+0x8be>
}
ffffffffc0200cbe:	6105                	addi	sp,sp,32
        cprintf("Load access fault\n");
ffffffffc0200cc0:	cd8ff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200cc4:	60e2                	ld	ra,24(sp)
        cprintf("Store/AMO access fault\n");
ffffffffc0200cc6:	00006517          	auipc	a0,0x6
ffffffffc0200cca:	0e250513          	addi	a0,a0,226 # ffffffffc0206da8 <etext+0x906>
}
ffffffffc0200cce:	6105                	addi	sp,sp,32
        cprintf("Store/AMO access fault\n");
ffffffffc0200cd0:	cc8ff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200cd4:	60e2                	ld	ra,24(sp)
ffffffffc0200cd6:	6105                	addi	sp,sp,32
        print_trapframe(tf);
ffffffffc0200cd8:	bd19                	j	ffffffffc0200aee <print_trapframe>
        panic("AMO address misaligned\n");
ffffffffc0200cda:	00006617          	auipc	a2,0x6
ffffffffc0200cde:	09e60613          	addi	a2,a2,158 # ffffffffc0206d78 <etext+0x8d6>
ffffffffc0200ce2:	0b000593          	li	a1,176
ffffffffc0200ce6:	00006517          	auipc	a0,0x6
ffffffffc0200cea:	0aa50513          	addi	a0,a0,170 # ffffffffc0206d90 <etext+0x8ee>
ffffffffc0200cee:	f5cff0ef          	jal	ffffffffc020044a <__panic>
        print_trapframe(tf);
ffffffffc0200cf2:	bbf5                	j	ffffffffc0200aee <print_trapframe>

ffffffffc0200cf4 <trap>:
 * */
void trap(struct trapframe *tf)
{
    // dispatch based on what type of trap occurred
    //    cputs("some trap");
    if (current == NULL)
ffffffffc0200cf4:	000cb717          	auipc	a4,0xcb
ffffffffc0200cf8:	65c73703          	ld	a4,1628(a4) # ffffffffc02cc350 <current>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200cfc:	11853583          	ld	a1,280(a0)
    if (current == NULL)
ffffffffc0200d00:	cf21                	beqz	a4,ffffffffc0200d58 <trap+0x64>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200d02:	10053603          	ld	a2,256(a0)
    {
        trap_dispatch(tf);
    }
    else
    {
        struct trapframe *otf = current->tf;
ffffffffc0200d06:	0a073803          	ld	a6,160(a4)
{
ffffffffc0200d0a:	1101                	addi	sp,sp,-32
ffffffffc0200d0c:	ec06                	sd	ra,24(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200d0e:	10067613          	andi	a2,a2,256
        current->tf = tf;
ffffffffc0200d12:	f348                	sd	a0,160(a4)
    if ((intptr_t)tf->cause < 0)
ffffffffc0200d14:	e432                	sd	a2,8(sp)
ffffffffc0200d16:	e042                	sd	a6,0(sp)
ffffffffc0200d18:	0205c763          	bltz	a1,ffffffffc0200d46 <trap+0x52>
        exception_handler(tf);
ffffffffc0200d1c:	eb5ff0ef          	jal	ffffffffc0200bd0 <exception_handler>
ffffffffc0200d20:	6622                	ld	a2,8(sp)
ffffffffc0200d22:	6802                	ld	a6,0(sp)
ffffffffc0200d24:	000cb697          	auipc	a3,0xcb
ffffffffc0200d28:	62c68693          	addi	a3,a3,1580 # ffffffffc02cc350 <current>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200d2c:	6298                	ld	a4,0(a3)
ffffffffc0200d2e:	0b073023          	sd	a6,160(a4)
        if (!in_kernel)
ffffffffc0200d32:	e619                	bnez	a2,ffffffffc0200d40 <trap+0x4c>
        {
            if (current->flags & PF_EXITING)
ffffffffc0200d34:	0b072783          	lw	a5,176(a4)
ffffffffc0200d38:	8b85                	andi	a5,a5,1
ffffffffc0200d3a:	e79d                	bnez	a5,ffffffffc0200d68 <trap+0x74>
            {
                do_exit(-E_KILLED);
            }
            if (current->need_resched)
ffffffffc0200d3c:	6f1c                	ld	a5,24(a4)
ffffffffc0200d3e:	e38d                	bnez	a5,ffffffffc0200d60 <trap+0x6c>
            {
                schedule();
            }
        }
    }
}
ffffffffc0200d40:	60e2                	ld	ra,24(sp)
ffffffffc0200d42:	6105                	addi	sp,sp,32
ffffffffc0200d44:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200d46:	e0bff0ef          	jal	ffffffffc0200b50 <interrupt_handler>
ffffffffc0200d4a:	6802                	ld	a6,0(sp)
ffffffffc0200d4c:	6622                	ld	a2,8(sp)
ffffffffc0200d4e:	000cb697          	auipc	a3,0xcb
ffffffffc0200d52:	60268693          	addi	a3,a3,1538 # ffffffffc02cc350 <current>
ffffffffc0200d56:	bfd9                	j	ffffffffc0200d2c <trap+0x38>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200d58:	0005c363          	bltz	a1,ffffffffc0200d5e <trap+0x6a>
        exception_handler(tf);
ffffffffc0200d5c:	bd95                	j	ffffffffc0200bd0 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200d5e:	bbcd                	j	ffffffffc0200b50 <interrupt_handler>
}
ffffffffc0200d60:	60e2                	ld	ra,24(sp)
ffffffffc0200d62:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200d64:	6450406f          	j	ffffffffc0205ba8 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200d68:	555d                	li	a0,-9
ffffffffc0200d6a:	6cb030ef          	jal	ffffffffc0204c34 <do_exit>
            if (current->need_resched)
ffffffffc0200d6e:	000cb717          	auipc	a4,0xcb
ffffffffc0200d72:	5e273703          	ld	a4,1506(a4) # ffffffffc02cc350 <current>
ffffffffc0200d76:	b7d9                	j	ffffffffc0200d3c <trap+0x48>

ffffffffc0200d78 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200d78:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200d7c:	00011463          	bnez	sp,ffffffffc0200d84 <__alltraps+0xc>
ffffffffc0200d80:	14002173          	csrr	sp,sscratch
ffffffffc0200d84:	712d                	addi	sp,sp,-288
ffffffffc0200d86:	e002                	sd	zero,0(sp)
ffffffffc0200d88:	e406                	sd	ra,8(sp)
ffffffffc0200d8a:	ec0e                	sd	gp,24(sp)
ffffffffc0200d8c:	f012                	sd	tp,32(sp)
ffffffffc0200d8e:	f416                	sd	t0,40(sp)
ffffffffc0200d90:	f81a                	sd	t1,48(sp)
ffffffffc0200d92:	fc1e                	sd	t2,56(sp)
ffffffffc0200d94:	e0a2                	sd	s0,64(sp)
ffffffffc0200d96:	e4a6                	sd	s1,72(sp)
ffffffffc0200d98:	e8aa                	sd	a0,80(sp)
ffffffffc0200d9a:	ecae                	sd	a1,88(sp)
ffffffffc0200d9c:	f0b2                	sd	a2,96(sp)
ffffffffc0200d9e:	f4b6                	sd	a3,104(sp)
ffffffffc0200da0:	f8ba                	sd	a4,112(sp)
ffffffffc0200da2:	fcbe                	sd	a5,120(sp)
ffffffffc0200da4:	e142                	sd	a6,128(sp)
ffffffffc0200da6:	e546                	sd	a7,136(sp)
ffffffffc0200da8:	e94a                	sd	s2,144(sp)
ffffffffc0200daa:	ed4e                	sd	s3,152(sp)
ffffffffc0200dac:	f152                	sd	s4,160(sp)
ffffffffc0200dae:	f556                	sd	s5,168(sp)
ffffffffc0200db0:	f95a                	sd	s6,176(sp)
ffffffffc0200db2:	fd5e                	sd	s7,184(sp)
ffffffffc0200db4:	e1e2                	sd	s8,192(sp)
ffffffffc0200db6:	e5e6                	sd	s9,200(sp)
ffffffffc0200db8:	e9ea                	sd	s10,208(sp)
ffffffffc0200dba:	edee                	sd	s11,216(sp)
ffffffffc0200dbc:	f1f2                	sd	t3,224(sp)
ffffffffc0200dbe:	f5f6                	sd	t4,232(sp)
ffffffffc0200dc0:	f9fa                	sd	t5,240(sp)
ffffffffc0200dc2:	fdfe                	sd	t6,248(sp)
ffffffffc0200dc4:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200dc8:	100024f3          	csrr	s1,sstatus
ffffffffc0200dcc:	14102973          	csrr	s2,sepc
ffffffffc0200dd0:	143029f3          	csrr	s3,stval
ffffffffc0200dd4:	14202a73          	csrr	s4,scause
ffffffffc0200dd8:	e822                	sd	s0,16(sp)
ffffffffc0200dda:	e226                	sd	s1,256(sp)
ffffffffc0200ddc:	e64a                	sd	s2,264(sp)
ffffffffc0200dde:	ea4e                	sd	s3,272(sp)
ffffffffc0200de0:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200de2:	850a                	mv	a0,sp
    jal trap
ffffffffc0200de4:	f11ff0ef          	jal	ffffffffc0200cf4 <trap>

ffffffffc0200de8 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200de8:	6492                	ld	s1,256(sp)
ffffffffc0200dea:	6932                	ld	s2,264(sp)
ffffffffc0200dec:	1004f413          	andi	s0,s1,256
ffffffffc0200df0:	e401                	bnez	s0,ffffffffc0200df8 <__trapret+0x10>
ffffffffc0200df2:	1200                	addi	s0,sp,288
ffffffffc0200df4:	14041073          	csrw	sscratch,s0
ffffffffc0200df8:	10049073          	csrw	sstatus,s1
ffffffffc0200dfc:	14191073          	csrw	sepc,s2
ffffffffc0200e00:	60a2                	ld	ra,8(sp)
ffffffffc0200e02:	61e2                	ld	gp,24(sp)
ffffffffc0200e04:	7202                	ld	tp,32(sp)
ffffffffc0200e06:	72a2                	ld	t0,40(sp)
ffffffffc0200e08:	7342                	ld	t1,48(sp)
ffffffffc0200e0a:	73e2                	ld	t2,56(sp)
ffffffffc0200e0c:	6406                	ld	s0,64(sp)
ffffffffc0200e0e:	64a6                	ld	s1,72(sp)
ffffffffc0200e10:	6546                	ld	a0,80(sp)
ffffffffc0200e12:	65e6                	ld	a1,88(sp)
ffffffffc0200e14:	7606                	ld	a2,96(sp)
ffffffffc0200e16:	76a6                	ld	a3,104(sp)
ffffffffc0200e18:	7746                	ld	a4,112(sp)
ffffffffc0200e1a:	77e6                	ld	a5,120(sp)
ffffffffc0200e1c:	680a                	ld	a6,128(sp)
ffffffffc0200e1e:	68aa                	ld	a7,136(sp)
ffffffffc0200e20:	694a                	ld	s2,144(sp)
ffffffffc0200e22:	69ea                	ld	s3,152(sp)
ffffffffc0200e24:	7a0a                	ld	s4,160(sp)
ffffffffc0200e26:	7aaa                	ld	s5,168(sp)
ffffffffc0200e28:	7b4a                	ld	s6,176(sp)
ffffffffc0200e2a:	7bea                	ld	s7,184(sp)
ffffffffc0200e2c:	6c0e                	ld	s8,192(sp)
ffffffffc0200e2e:	6cae                	ld	s9,200(sp)
ffffffffc0200e30:	6d4e                	ld	s10,208(sp)
ffffffffc0200e32:	6dee                	ld	s11,216(sp)
ffffffffc0200e34:	7e0e                	ld	t3,224(sp)
ffffffffc0200e36:	7eae                	ld	t4,232(sp)
ffffffffc0200e38:	7f4e                	ld	t5,240(sp)
ffffffffc0200e3a:	7fee                	ld	t6,248(sp)
ffffffffc0200e3c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200e3e:	10200073          	sret

ffffffffc0200e42 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200e42:	812a                	mv	sp,a0
ffffffffc0200e44:	b755                	j	ffffffffc0200de8 <__trapret>

ffffffffc0200e46 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200e46:	000c7797          	auipc	a5,0xc7
ffffffffc0200e4a:	30278793          	addi	a5,a5,770 # ffffffffc02c8148 <free_area>
ffffffffc0200e4e:	e79c                	sd	a5,8(a5)
ffffffffc0200e50:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200e52:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200e56:	8082                	ret

ffffffffc0200e58 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200e58:	000c7517          	auipc	a0,0xc7
ffffffffc0200e5c:	30056503          	lwu	a0,768(a0) # ffffffffc02c8158 <free_area+0x10>
ffffffffc0200e60:	8082                	ret

ffffffffc0200e62 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200e62:	711d                	addi	sp,sp,-96
ffffffffc0200e64:	e0ca                	sd	s2,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200e66:	000c7917          	auipc	s2,0xc7
ffffffffc0200e6a:	2e290913          	addi	s2,s2,738 # ffffffffc02c8148 <free_area>
ffffffffc0200e6e:	00893783          	ld	a5,8(s2)
ffffffffc0200e72:	ec86                	sd	ra,88(sp)
ffffffffc0200e74:	e8a2                	sd	s0,80(sp)
ffffffffc0200e76:	e4a6                	sd	s1,72(sp)
ffffffffc0200e78:	fc4e                	sd	s3,56(sp)
ffffffffc0200e7a:	f852                	sd	s4,48(sp)
ffffffffc0200e7c:	f456                	sd	s5,40(sp)
ffffffffc0200e7e:	f05a                	sd	s6,32(sp)
ffffffffc0200e80:	ec5e                	sd	s7,24(sp)
ffffffffc0200e82:	e862                	sd	s8,16(sp)
ffffffffc0200e84:	e466                	sd	s9,8(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200e86:	2f278363          	beq	a5,s2,ffffffffc020116c <default_check+0x30a>
    int count = 0, total = 0;
ffffffffc0200e8a:	4401                	li	s0,0
ffffffffc0200e8c:	4481                	li	s1,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200e8e:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200e92:	8b09                	andi	a4,a4,2
ffffffffc0200e94:	2e070063          	beqz	a4,ffffffffc0201174 <default_check+0x312>
        count ++, total += p->property;
ffffffffc0200e98:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200e9c:	679c                	ld	a5,8(a5)
ffffffffc0200e9e:	2485                	addiw	s1,s1,1
ffffffffc0200ea0:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ea2:	ff2796e3          	bne	a5,s2,ffffffffc0200e8e <default_check+0x2c>
    }
    assert(total == nr_free_pages());
ffffffffc0200ea6:	89a2                	mv	s3,s0
ffffffffc0200ea8:	741000ef          	jal	ffffffffc0201de8 <nr_free_pages>
ffffffffc0200eac:	73351463          	bne	a0,s3,ffffffffc02015d4 <default_check+0x772>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200eb0:	4505                	li	a0,1
ffffffffc0200eb2:	6c5000ef          	jal	ffffffffc0201d76 <alloc_pages>
ffffffffc0200eb6:	8a2a                	mv	s4,a0
ffffffffc0200eb8:	44050e63          	beqz	a0,ffffffffc0201314 <default_check+0x4b2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200ebc:	4505                	li	a0,1
ffffffffc0200ebe:	6b9000ef          	jal	ffffffffc0201d76 <alloc_pages>
ffffffffc0200ec2:	89aa                	mv	s3,a0
ffffffffc0200ec4:	72050863          	beqz	a0,ffffffffc02015f4 <default_check+0x792>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200ec8:	4505                	li	a0,1
ffffffffc0200eca:	6ad000ef          	jal	ffffffffc0201d76 <alloc_pages>
ffffffffc0200ece:	8aaa                	mv	s5,a0
ffffffffc0200ed0:	4c050263          	beqz	a0,ffffffffc0201394 <default_check+0x532>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200ed4:	40a987b3          	sub	a5,s3,a0
ffffffffc0200ed8:	40aa0733          	sub	a4,s4,a0
ffffffffc0200edc:	0017b793          	seqz	a5,a5
ffffffffc0200ee0:	00173713          	seqz	a4,a4
ffffffffc0200ee4:	8fd9                	or	a5,a5,a4
ffffffffc0200ee6:	30079763          	bnez	a5,ffffffffc02011f4 <default_check+0x392>
ffffffffc0200eea:	313a0563          	beq	s4,s3,ffffffffc02011f4 <default_check+0x392>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200eee:	000a2783          	lw	a5,0(s4)
ffffffffc0200ef2:	2a079163          	bnez	a5,ffffffffc0201194 <default_check+0x332>
ffffffffc0200ef6:	0009a783          	lw	a5,0(s3)
ffffffffc0200efa:	28079d63          	bnez	a5,ffffffffc0201194 <default_check+0x332>
ffffffffc0200efe:	411c                	lw	a5,0(a0)
ffffffffc0200f00:	28079a63          	bnez	a5,ffffffffc0201194 <default_check+0x332>
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page)
{
    return page - pages + nbase;
ffffffffc0200f04:	000cb797          	auipc	a5,0xcb
ffffffffc0200f08:	43c7b783          	ld	a5,1084(a5) # ffffffffc02cc340 <pages>
ffffffffc0200f0c:	00008617          	auipc	a2,0x8
ffffffffc0200f10:	35c63603          	ld	a2,860(a2) # ffffffffc0209268 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f14:	000cb697          	auipc	a3,0xcb
ffffffffc0200f18:	4246b683          	ld	a3,1060(a3) # ffffffffc02cc338 <npage>
ffffffffc0200f1c:	40fa0733          	sub	a4,s4,a5
ffffffffc0200f20:	8719                	srai	a4,a4,0x6
ffffffffc0200f22:	9732                	add	a4,a4,a2
}

static inline uintptr_t
page2pa(struct Page *page)
{
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f24:	0732                	slli	a4,a4,0xc
ffffffffc0200f26:	06b2                	slli	a3,a3,0xc
ffffffffc0200f28:	2ad77663          	bgeu	a4,a3,ffffffffc02011d4 <default_check+0x372>
    return page - pages + nbase;
ffffffffc0200f2c:	40f98733          	sub	a4,s3,a5
ffffffffc0200f30:	8719                	srai	a4,a4,0x6
ffffffffc0200f32:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f34:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200f36:	4cd77f63          	bgeu	a4,a3,ffffffffc0201414 <default_check+0x5b2>
    return page - pages + nbase;
ffffffffc0200f3a:	40f507b3          	sub	a5,a0,a5
ffffffffc0200f3e:	8799                	srai	a5,a5,0x6
ffffffffc0200f40:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200f42:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200f44:	32d7f863          	bgeu	a5,a3,ffffffffc0201274 <default_check+0x412>
    assert(alloc_page() == NULL);
ffffffffc0200f48:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200f4a:	00093c03          	ld	s8,0(s2)
ffffffffc0200f4e:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200f52:	000c7b17          	auipc	s6,0xc7
ffffffffc0200f56:	206b2b03          	lw	s6,518(s6) # ffffffffc02c8158 <free_area+0x10>
    elm->prev = elm->next = elm;
ffffffffc0200f5a:	01293023          	sd	s2,0(s2)
ffffffffc0200f5e:	01293423          	sd	s2,8(s2)
    nr_free = 0;
ffffffffc0200f62:	000c7797          	auipc	a5,0xc7
ffffffffc0200f66:	1e07ab23          	sw	zero,502(a5) # ffffffffc02c8158 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200f6a:	60d000ef          	jal	ffffffffc0201d76 <alloc_pages>
ffffffffc0200f6e:	2e051363          	bnez	a0,ffffffffc0201254 <default_check+0x3f2>
    free_page(p0);
ffffffffc0200f72:	8552                	mv	a0,s4
ffffffffc0200f74:	4585                	li	a1,1
ffffffffc0200f76:	63b000ef          	jal	ffffffffc0201db0 <free_pages>
    free_page(p1);
ffffffffc0200f7a:	854e                	mv	a0,s3
ffffffffc0200f7c:	4585                	li	a1,1
ffffffffc0200f7e:	633000ef          	jal	ffffffffc0201db0 <free_pages>
    free_page(p2);
ffffffffc0200f82:	8556                	mv	a0,s5
ffffffffc0200f84:	4585                	li	a1,1
ffffffffc0200f86:	62b000ef          	jal	ffffffffc0201db0 <free_pages>
    assert(nr_free == 3);
ffffffffc0200f8a:	000c7717          	auipc	a4,0xc7
ffffffffc0200f8e:	1ce72703          	lw	a4,462(a4) # ffffffffc02c8158 <free_area+0x10>
ffffffffc0200f92:	478d                	li	a5,3
ffffffffc0200f94:	2af71063          	bne	a4,a5,ffffffffc0201234 <default_check+0x3d2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f98:	4505                	li	a0,1
ffffffffc0200f9a:	5dd000ef          	jal	ffffffffc0201d76 <alloc_pages>
ffffffffc0200f9e:	89aa                	mv	s3,a0
ffffffffc0200fa0:	26050a63          	beqz	a0,ffffffffc0201214 <default_check+0x3b2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200fa4:	4505                	li	a0,1
ffffffffc0200fa6:	5d1000ef          	jal	ffffffffc0201d76 <alloc_pages>
ffffffffc0200faa:	8aaa                	mv	s5,a0
ffffffffc0200fac:	3c050463          	beqz	a0,ffffffffc0201374 <default_check+0x512>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200fb0:	4505                	li	a0,1
ffffffffc0200fb2:	5c5000ef          	jal	ffffffffc0201d76 <alloc_pages>
ffffffffc0200fb6:	8a2a                	mv	s4,a0
ffffffffc0200fb8:	38050e63          	beqz	a0,ffffffffc0201354 <default_check+0x4f2>
    assert(alloc_page() == NULL);
ffffffffc0200fbc:	4505                	li	a0,1
ffffffffc0200fbe:	5b9000ef          	jal	ffffffffc0201d76 <alloc_pages>
ffffffffc0200fc2:	36051963          	bnez	a0,ffffffffc0201334 <default_check+0x4d2>
    free_page(p0);
ffffffffc0200fc6:	4585                	li	a1,1
ffffffffc0200fc8:	854e                	mv	a0,s3
ffffffffc0200fca:	5e7000ef          	jal	ffffffffc0201db0 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200fce:	00893783          	ld	a5,8(s2)
ffffffffc0200fd2:	1f278163          	beq	a5,s2,ffffffffc02011b4 <default_check+0x352>
    assert((p = alloc_page()) == p0);
ffffffffc0200fd6:	4505                	li	a0,1
ffffffffc0200fd8:	59f000ef          	jal	ffffffffc0201d76 <alloc_pages>
ffffffffc0200fdc:	8caa                	mv	s9,a0
ffffffffc0200fde:	30a99b63          	bne	s3,a0,ffffffffc02012f4 <default_check+0x492>
    assert(alloc_page() == NULL);
ffffffffc0200fe2:	4505                	li	a0,1
ffffffffc0200fe4:	593000ef          	jal	ffffffffc0201d76 <alloc_pages>
ffffffffc0200fe8:	2e051663          	bnez	a0,ffffffffc02012d4 <default_check+0x472>
    assert(nr_free == 0);
ffffffffc0200fec:	000c7797          	auipc	a5,0xc7
ffffffffc0200ff0:	16c7a783          	lw	a5,364(a5) # ffffffffc02c8158 <free_area+0x10>
ffffffffc0200ff4:	2c079063          	bnez	a5,ffffffffc02012b4 <default_check+0x452>
    free_page(p);
ffffffffc0200ff8:	8566                	mv	a0,s9
ffffffffc0200ffa:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200ffc:	01893023          	sd	s8,0(s2)
ffffffffc0201000:	01793423          	sd	s7,8(s2)
    nr_free = nr_free_store;
ffffffffc0201004:	01692823          	sw	s6,16(s2)
    free_page(p);
ffffffffc0201008:	5a9000ef          	jal	ffffffffc0201db0 <free_pages>
    free_page(p1);
ffffffffc020100c:	8556                	mv	a0,s5
ffffffffc020100e:	4585                	li	a1,1
ffffffffc0201010:	5a1000ef          	jal	ffffffffc0201db0 <free_pages>
    free_page(p2);
ffffffffc0201014:	8552                	mv	a0,s4
ffffffffc0201016:	4585                	li	a1,1
ffffffffc0201018:	599000ef          	jal	ffffffffc0201db0 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc020101c:	4515                	li	a0,5
ffffffffc020101e:	559000ef          	jal	ffffffffc0201d76 <alloc_pages>
ffffffffc0201022:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201024:	26050863          	beqz	a0,ffffffffc0201294 <default_check+0x432>
ffffffffc0201028:	651c                	ld	a5,8(a0)
    assert(!PageProperty(p0));
ffffffffc020102a:	8b89                	andi	a5,a5,2
ffffffffc020102c:	54079463          	bnez	a5,ffffffffc0201574 <default_check+0x712>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201030:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201032:	00093b83          	ld	s7,0(s2)
ffffffffc0201036:	00893b03          	ld	s6,8(s2)
ffffffffc020103a:	01293023          	sd	s2,0(s2)
ffffffffc020103e:	01293423          	sd	s2,8(s2)
    assert(alloc_page() == NULL);
ffffffffc0201042:	535000ef          	jal	ffffffffc0201d76 <alloc_pages>
ffffffffc0201046:	50051763          	bnez	a0,ffffffffc0201554 <default_check+0x6f2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020104a:	08098a13          	addi	s4,s3,128
ffffffffc020104e:	8552                	mv	a0,s4
ffffffffc0201050:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0201052:	000c7c17          	auipc	s8,0xc7
ffffffffc0201056:	106c2c03          	lw	s8,262(s8) # ffffffffc02c8158 <free_area+0x10>
    nr_free = 0;
ffffffffc020105a:	000c7797          	auipc	a5,0xc7
ffffffffc020105e:	0e07af23          	sw	zero,254(a5) # ffffffffc02c8158 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0201062:	54f000ef          	jal	ffffffffc0201db0 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201066:	4511                	li	a0,4
ffffffffc0201068:	50f000ef          	jal	ffffffffc0201d76 <alloc_pages>
ffffffffc020106c:	4c051463          	bnez	a0,ffffffffc0201534 <default_check+0x6d2>
ffffffffc0201070:	0889b783          	ld	a5,136(s3)
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201074:	8b89                	andi	a5,a5,2
ffffffffc0201076:	48078f63          	beqz	a5,ffffffffc0201514 <default_check+0x6b2>
ffffffffc020107a:	0909a503          	lw	a0,144(s3)
ffffffffc020107e:	478d                	li	a5,3
ffffffffc0201080:	48f51a63          	bne	a0,a5,ffffffffc0201514 <default_check+0x6b2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201084:	4f3000ef          	jal	ffffffffc0201d76 <alloc_pages>
ffffffffc0201088:	8aaa                	mv	s5,a0
ffffffffc020108a:	46050563          	beqz	a0,ffffffffc02014f4 <default_check+0x692>
    assert(alloc_page() == NULL);
ffffffffc020108e:	4505                	li	a0,1
ffffffffc0201090:	4e7000ef          	jal	ffffffffc0201d76 <alloc_pages>
ffffffffc0201094:	44051063          	bnez	a0,ffffffffc02014d4 <default_check+0x672>
    assert(p0 + 2 == p1);
ffffffffc0201098:	415a1e63          	bne	s4,s5,ffffffffc02014b4 <default_check+0x652>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc020109c:	4585                	li	a1,1
ffffffffc020109e:	854e                	mv	a0,s3
ffffffffc02010a0:	511000ef          	jal	ffffffffc0201db0 <free_pages>
    free_pages(p1, 3);
ffffffffc02010a4:	8552                	mv	a0,s4
ffffffffc02010a6:	458d                	li	a1,3
ffffffffc02010a8:	509000ef          	jal	ffffffffc0201db0 <free_pages>
ffffffffc02010ac:	0089b783          	ld	a5,8(s3)
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02010b0:	8b89                	andi	a5,a5,2
ffffffffc02010b2:	3e078163          	beqz	a5,ffffffffc0201494 <default_check+0x632>
ffffffffc02010b6:	0109aa83          	lw	s5,16(s3)
ffffffffc02010ba:	4785                	li	a5,1
ffffffffc02010bc:	3cfa9c63          	bne	s5,a5,ffffffffc0201494 <default_check+0x632>
ffffffffc02010c0:	008a3783          	ld	a5,8(s4)
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02010c4:	8b89                	andi	a5,a5,2
ffffffffc02010c6:	3a078763          	beqz	a5,ffffffffc0201474 <default_check+0x612>
ffffffffc02010ca:	010a2703          	lw	a4,16(s4)
ffffffffc02010ce:	478d                	li	a5,3
ffffffffc02010d0:	3af71263          	bne	a4,a5,ffffffffc0201474 <default_check+0x612>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02010d4:	8556                	mv	a0,s5
ffffffffc02010d6:	4a1000ef          	jal	ffffffffc0201d76 <alloc_pages>
ffffffffc02010da:	36a99d63          	bne	s3,a0,ffffffffc0201454 <default_check+0x5f2>
    free_page(p0);
ffffffffc02010de:	85d6                	mv	a1,s5
ffffffffc02010e0:	4d1000ef          	jal	ffffffffc0201db0 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02010e4:	4509                	li	a0,2
ffffffffc02010e6:	491000ef          	jal	ffffffffc0201d76 <alloc_pages>
ffffffffc02010ea:	34aa1563          	bne	s4,a0,ffffffffc0201434 <default_check+0x5d2>

    free_pages(p0, 2);
ffffffffc02010ee:	4589                	li	a1,2
ffffffffc02010f0:	4c1000ef          	jal	ffffffffc0201db0 <free_pages>
    free_page(p2);
ffffffffc02010f4:	04098513          	addi	a0,s3,64
ffffffffc02010f8:	85d6                	mv	a1,s5
ffffffffc02010fa:	4b7000ef          	jal	ffffffffc0201db0 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02010fe:	4515                	li	a0,5
ffffffffc0201100:	477000ef          	jal	ffffffffc0201d76 <alloc_pages>
ffffffffc0201104:	89aa                	mv	s3,a0
ffffffffc0201106:	48050763          	beqz	a0,ffffffffc0201594 <default_check+0x732>
    assert(alloc_page() == NULL);
ffffffffc020110a:	8556                	mv	a0,s5
ffffffffc020110c:	46b000ef          	jal	ffffffffc0201d76 <alloc_pages>
ffffffffc0201110:	2e051263          	bnez	a0,ffffffffc02013f4 <default_check+0x592>

    assert(nr_free == 0);
ffffffffc0201114:	000c7797          	auipc	a5,0xc7
ffffffffc0201118:	0447a783          	lw	a5,68(a5) # ffffffffc02c8158 <free_area+0x10>
ffffffffc020111c:	2a079c63          	bnez	a5,ffffffffc02013d4 <default_check+0x572>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201120:	854e                	mv	a0,s3
ffffffffc0201122:	4595                	li	a1,5
    nr_free = nr_free_store;
ffffffffc0201124:	01892823          	sw	s8,16(s2)
    free_list = free_list_store;
ffffffffc0201128:	01793023          	sd	s7,0(s2)
ffffffffc020112c:	01693423          	sd	s6,8(s2)
    free_pages(p0, 5);
ffffffffc0201130:	481000ef          	jal	ffffffffc0201db0 <free_pages>
    return listelm->next;
ffffffffc0201134:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201138:	01278963          	beq	a5,s2,ffffffffc020114a <default_check+0x2e8>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020113c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201140:	679c                	ld	a5,8(a5)
ffffffffc0201142:	34fd                	addiw	s1,s1,-1
ffffffffc0201144:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201146:	ff279be3          	bne	a5,s2,ffffffffc020113c <default_check+0x2da>
    }
    assert(count == 0);
ffffffffc020114a:	26049563          	bnez	s1,ffffffffc02013b4 <default_check+0x552>
    assert(total == 0);
ffffffffc020114e:	46041363          	bnez	s0,ffffffffc02015b4 <default_check+0x752>
}
ffffffffc0201152:	60e6                	ld	ra,88(sp)
ffffffffc0201154:	6446                	ld	s0,80(sp)
ffffffffc0201156:	64a6                	ld	s1,72(sp)
ffffffffc0201158:	6906                	ld	s2,64(sp)
ffffffffc020115a:	79e2                	ld	s3,56(sp)
ffffffffc020115c:	7a42                	ld	s4,48(sp)
ffffffffc020115e:	7aa2                	ld	s5,40(sp)
ffffffffc0201160:	7b02                	ld	s6,32(sp)
ffffffffc0201162:	6be2                	ld	s7,24(sp)
ffffffffc0201164:	6c42                	ld	s8,16(sp)
ffffffffc0201166:	6ca2                	ld	s9,8(sp)
ffffffffc0201168:	6125                	addi	sp,sp,96
ffffffffc020116a:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc020116c:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020116e:	4401                	li	s0,0
ffffffffc0201170:	4481                	li	s1,0
ffffffffc0201172:	bb1d                	j	ffffffffc0200ea8 <default_check+0x46>
        assert(PageProperty(p));
ffffffffc0201174:	00006697          	auipc	a3,0x6
ffffffffc0201178:	cf468693          	addi	a3,a3,-780 # ffffffffc0206e68 <etext+0x9c6>
ffffffffc020117c:	00006617          	auipc	a2,0x6
ffffffffc0201180:	cfc60613          	addi	a2,a2,-772 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201184:	0ef00593          	li	a1,239
ffffffffc0201188:	00006517          	auipc	a0,0x6
ffffffffc020118c:	d0850513          	addi	a0,a0,-760 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201190:	abaff0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201194:	00006697          	auipc	a3,0x6
ffffffffc0201198:	dbc68693          	addi	a3,a3,-580 # ffffffffc0206f50 <etext+0xaae>
ffffffffc020119c:	00006617          	auipc	a2,0x6
ffffffffc02011a0:	cdc60613          	addi	a2,a2,-804 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02011a4:	0bd00593          	li	a1,189
ffffffffc02011a8:	00006517          	auipc	a0,0x6
ffffffffc02011ac:	ce850513          	addi	a0,a0,-792 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc02011b0:	a9aff0ef          	jal	ffffffffc020044a <__panic>
    assert(!list_empty(&free_list));
ffffffffc02011b4:	00006697          	auipc	a3,0x6
ffffffffc02011b8:	e6468693          	addi	a3,a3,-412 # ffffffffc0207018 <etext+0xb76>
ffffffffc02011bc:	00006617          	auipc	a2,0x6
ffffffffc02011c0:	cbc60613          	addi	a2,a2,-836 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02011c4:	0d800593          	li	a1,216
ffffffffc02011c8:	00006517          	auipc	a0,0x6
ffffffffc02011cc:	cc850513          	addi	a0,a0,-824 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc02011d0:	a7aff0ef          	jal	ffffffffc020044a <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02011d4:	00006697          	auipc	a3,0x6
ffffffffc02011d8:	dbc68693          	addi	a3,a3,-580 # ffffffffc0206f90 <etext+0xaee>
ffffffffc02011dc:	00006617          	auipc	a2,0x6
ffffffffc02011e0:	c9c60613          	addi	a2,a2,-868 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02011e4:	0bf00593          	li	a1,191
ffffffffc02011e8:	00006517          	auipc	a0,0x6
ffffffffc02011ec:	ca850513          	addi	a0,a0,-856 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc02011f0:	a5aff0ef          	jal	ffffffffc020044a <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02011f4:	00006697          	auipc	a3,0x6
ffffffffc02011f8:	d3468693          	addi	a3,a3,-716 # ffffffffc0206f28 <etext+0xa86>
ffffffffc02011fc:	00006617          	auipc	a2,0x6
ffffffffc0201200:	c7c60613          	addi	a2,a2,-900 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201204:	0bc00593          	li	a1,188
ffffffffc0201208:	00006517          	auipc	a0,0x6
ffffffffc020120c:	c8850513          	addi	a0,a0,-888 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201210:	a3aff0ef          	jal	ffffffffc020044a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201214:	00006697          	auipc	a3,0x6
ffffffffc0201218:	cb468693          	addi	a3,a3,-844 # ffffffffc0206ec8 <etext+0xa26>
ffffffffc020121c:	00006617          	auipc	a2,0x6
ffffffffc0201220:	c5c60613          	addi	a2,a2,-932 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201224:	0d100593          	li	a1,209
ffffffffc0201228:	00006517          	auipc	a0,0x6
ffffffffc020122c:	c6850513          	addi	a0,a0,-920 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201230:	a1aff0ef          	jal	ffffffffc020044a <__panic>
    assert(nr_free == 3);
ffffffffc0201234:	00006697          	auipc	a3,0x6
ffffffffc0201238:	dd468693          	addi	a3,a3,-556 # ffffffffc0207008 <etext+0xb66>
ffffffffc020123c:	00006617          	auipc	a2,0x6
ffffffffc0201240:	c3c60613          	addi	a2,a2,-964 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201244:	0cf00593          	li	a1,207
ffffffffc0201248:	00006517          	auipc	a0,0x6
ffffffffc020124c:	c4850513          	addi	a0,a0,-952 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201250:	9faff0ef          	jal	ffffffffc020044a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201254:	00006697          	auipc	a3,0x6
ffffffffc0201258:	d9c68693          	addi	a3,a3,-612 # ffffffffc0206ff0 <etext+0xb4e>
ffffffffc020125c:	00006617          	auipc	a2,0x6
ffffffffc0201260:	c1c60613          	addi	a2,a2,-996 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201264:	0ca00593          	li	a1,202
ffffffffc0201268:	00006517          	auipc	a0,0x6
ffffffffc020126c:	c2850513          	addi	a0,a0,-984 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201270:	9daff0ef          	jal	ffffffffc020044a <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201274:	00006697          	auipc	a3,0x6
ffffffffc0201278:	d5c68693          	addi	a3,a3,-676 # ffffffffc0206fd0 <etext+0xb2e>
ffffffffc020127c:	00006617          	auipc	a2,0x6
ffffffffc0201280:	bfc60613          	addi	a2,a2,-1028 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201284:	0c100593          	li	a1,193
ffffffffc0201288:	00006517          	auipc	a0,0x6
ffffffffc020128c:	c0850513          	addi	a0,a0,-1016 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201290:	9baff0ef          	jal	ffffffffc020044a <__panic>
    assert(p0 != NULL);
ffffffffc0201294:	00006697          	auipc	a3,0x6
ffffffffc0201298:	dcc68693          	addi	a3,a3,-564 # ffffffffc0207060 <etext+0xbbe>
ffffffffc020129c:	00006617          	auipc	a2,0x6
ffffffffc02012a0:	bdc60613          	addi	a2,a2,-1060 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02012a4:	0f700593          	li	a1,247
ffffffffc02012a8:	00006517          	auipc	a0,0x6
ffffffffc02012ac:	be850513          	addi	a0,a0,-1048 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc02012b0:	99aff0ef          	jal	ffffffffc020044a <__panic>
    assert(nr_free == 0);
ffffffffc02012b4:	00006697          	auipc	a3,0x6
ffffffffc02012b8:	d9c68693          	addi	a3,a3,-612 # ffffffffc0207050 <etext+0xbae>
ffffffffc02012bc:	00006617          	auipc	a2,0x6
ffffffffc02012c0:	bbc60613          	addi	a2,a2,-1092 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02012c4:	0de00593          	li	a1,222
ffffffffc02012c8:	00006517          	auipc	a0,0x6
ffffffffc02012cc:	bc850513          	addi	a0,a0,-1080 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc02012d0:	97aff0ef          	jal	ffffffffc020044a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012d4:	00006697          	auipc	a3,0x6
ffffffffc02012d8:	d1c68693          	addi	a3,a3,-740 # ffffffffc0206ff0 <etext+0xb4e>
ffffffffc02012dc:	00006617          	auipc	a2,0x6
ffffffffc02012e0:	b9c60613          	addi	a2,a2,-1124 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02012e4:	0dc00593          	li	a1,220
ffffffffc02012e8:	00006517          	auipc	a0,0x6
ffffffffc02012ec:	ba850513          	addi	a0,a0,-1112 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc02012f0:	95aff0ef          	jal	ffffffffc020044a <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02012f4:	00006697          	auipc	a3,0x6
ffffffffc02012f8:	d3c68693          	addi	a3,a3,-708 # ffffffffc0207030 <etext+0xb8e>
ffffffffc02012fc:	00006617          	auipc	a2,0x6
ffffffffc0201300:	b7c60613          	addi	a2,a2,-1156 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201304:	0db00593          	li	a1,219
ffffffffc0201308:	00006517          	auipc	a0,0x6
ffffffffc020130c:	b8850513          	addi	a0,a0,-1144 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201310:	93aff0ef          	jal	ffffffffc020044a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201314:	00006697          	auipc	a3,0x6
ffffffffc0201318:	bb468693          	addi	a3,a3,-1100 # ffffffffc0206ec8 <etext+0xa26>
ffffffffc020131c:	00006617          	auipc	a2,0x6
ffffffffc0201320:	b5c60613          	addi	a2,a2,-1188 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201324:	0b800593          	li	a1,184
ffffffffc0201328:	00006517          	auipc	a0,0x6
ffffffffc020132c:	b6850513          	addi	a0,a0,-1176 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201330:	91aff0ef          	jal	ffffffffc020044a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201334:	00006697          	auipc	a3,0x6
ffffffffc0201338:	cbc68693          	addi	a3,a3,-836 # ffffffffc0206ff0 <etext+0xb4e>
ffffffffc020133c:	00006617          	auipc	a2,0x6
ffffffffc0201340:	b3c60613          	addi	a2,a2,-1220 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201344:	0d500593          	li	a1,213
ffffffffc0201348:	00006517          	auipc	a0,0x6
ffffffffc020134c:	b4850513          	addi	a0,a0,-1208 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201350:	8faff0ef          	jal	ffffffffc020044a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201354:	00006697          	auipc	a3,0x6
ffffffffc0201358:	bb468693          	addi	a3,a3,-1100 # ffffffffc0206f08 <etext+0xa66>
ffffffffc020135c:	00006617          	auipc	a2,0x6
ffffffffc0201360:	b1c60613          	addi	a2,a2,-1252 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201364:	0d300593          	li	a1,211
ffffffffc0201368:	00006517          	auipc	a0,0x6
ffffffffc020136c:	b2850513          	addi	a0,a0,-1240 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201370:	8daff0ef          	jal	ffffffffc020044a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201374:	00006697          	auipc	a3,0x6
ffffffffc0201378:	b7468693          	addi	a3,a3,-1164 # ffffffffc0206ee8 <etext+0xa46>
ffffffffc020137c:	00006617          	auipc	a2,0x6
ffffffffc0201380:	afc60613          	addi	a2,a2,-1284 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201384:	0d200593          	li	a1,210
ffffffffc0201388:	00006517          	auipc	a0,0x6
ffffffffc020138c:	b0850513          	addi	a0,a0,-1272 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201390:	8baff0ef          	jal	ffffffffc020044a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201394:	00006697          	auipc	a3,0x6
ffffffffc0201398:	b7468693          	addi	a3,a3,-1164 # ffffffffc0206f08 <etext+0xa66>
ffffffffc020139c:	00006617          	auipc	a2,0x6
ffffffffc02013a0:	adc60613          	addi	a2,a2,-1316 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02013a4:	0ba00593          	li	a1,186
ffffffffc02013a8:	00006517          	auipc	a0,0x6
ffffffffc02013ac:	ae850513          	addi	a0,a0,-1304 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc02013b0:	89aff0ef          	jal	ffffffffc020044a <__panic>
    assert(count == 0);
ffffffffc02013b4:	00006697          	auipc	a3,0x6
ffffffffc02013b8:	dfc68693          	addi	a3,a3,-516 # ffffffffc02071b0 <etext+0xd0e>
ffffffffc02013bc:	00006617          	auipc	a2,0x6
ffffffffc02013c0:	abc60613          	addi	a2,a2,-1348 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02013c4:	12400593          	li	a1,292
ffffffffc02013c8:	00006517          	auipc	a0,0x6
ffffffffc02013cc:	ac850513          	addi	a0,a0,-1336 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc02013d0:	87aff0ef          	jal	ffffffffc020044a <__panic>
    assert(nr_free == 0);
ffffffffc02013d4:	00006697          	auipc	a3,0x6
ffffffffc02013d8:	c7c68693          	addi	a3,a3,-900 # ffffffffc0207050 <etext+0xbae>
ffffffffc02013dc:	00006617          	auipc	a2,0x6
ffffffffc02013e0:	a9c60613          	addi	a2,a2,-1380 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02013e4:	11900593          	li	a1,281
ffffffffc02013e8:	00006517          	auipc	a0,0x6
ffffffffc02013ec:	aa850513          	addi	a0,a0,-1368 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc02013f0:	85aff0ef          	jal	ffffffffc020044a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013f4:	00006697          	auipc	a3,0x6
ffffffffc02013f8:	bfc68693          	addi	a3,a3,-1028 # ffffffffc0206ff0 <etext+0xb4e>
ffffffffc02013fc:	00006617          	auipc	a2,0x6
ffffffffc0201400:	a7c60613          	addi	a2,a2,-1412 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201404:	11700593          	li	a1,279
ffffffffc0201408:	00006517          	auipc	a0,0x6
ffffffffc020140c:	a8850513          	addi	a0,a0,-1400 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201410:	83aff0ef          	jal	ffffffffc020044a <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201414:	00006697          	auipc	a3,0x6
ffffffffc0201418:	b9c68693          	addi	a3,a3,-1124 # ffffffffc0206fb0 <etext+0xb0e>
ffffffffc020141c:	00006617          	auipc	a2,0x6
ffffffffc0201420:	a5c60613          	addi	a2,a2,-1444 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201424:	0c000593          	li	a1,192
ffffffffc0201428:	00006517          	auipc	a0,0x6
ffffffffc020142c:	a6850513          	addi	a0,a0,-1432 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201430:	81aff0ef          	jal	ffffffffc020044a <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201434:	00006697          	auipc	a3,0x6
ffffffffc0201438:	d3c68693          	addi	a3,a3,-708 # ffffffffc0207170 <etext+0xcce>
ffffffffc020143c:	00006617          	auipc	a2,0x6
ffffffffc0201440:	a3c60613          	addi	a2,a2,-1476 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201444:	11100593          	li	a1,273
ffffffffc0201448:	00006517          	auipc	a0,0x6
ffffffffc020144c:	a4850513          	addi	a0,a0,-1464 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201450:	ffbfe0ef          	jal	ffffffffc020044a <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201454:	00006697          	auipc	a3,0x6
ffffffffc0201458:	cfc68693          	addi	a3,a3,-772 # ffffffffc0207150 <etext+0xcae>
ffffffffc020145c:	00006617          	auipc	a2,0x6
ffffffffc0201460:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201464:	10f00593          	li	a1,271
ffffffffc0201468:	00006517          	auipc	a0,0x6
ffffffffc020146c:	a2850513          	addi	a0,a0,-1496 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201470:	fdbfe0ef          	jal	ffffffffc020044a <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201474:	00006697          	auipc	a3,0x6
ffffffffc0201478:	cb468693          	addi	a3,a3,-844 # ffffffffc0207128 <etext+0xc86>
ffffffffc020147c:	00006617          	auipc	a2,0x6
ffffffffc0201480:	9fc60613          	addi	a2,a2,-1540 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201484:	10d00593          	li	a1,269
ffffffffc0201488:	00006517          	auipc	a0,0x6
ffffffffc020148c:	a0850513          	addi	a0,a0,-1528 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201490:	fbbfe0ef          	jal	ffffffffc020044a <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201494:	00006697          	auipc	a3,0x6
ffffffffc0201498:	c6c68693          	addi	a3,a3,-916 # ffffffffc0207100 <etext+0xc5e>
ffffffffc020149c:	00006617          	auipc	a2,0x6
ffffffffc02014a0:	9dc60613          	addi	a2,a2,-1572 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02014a4:	10c00593          	li	a1,268
ffffffffc02014a8:	00006517          	auipc	a0,0x6
ffffffffc02014ac:	9e850513          	addi	a0,a0,-1560 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc02014b0:	f9bfe0ef          	jal	ffffffffc020044a <__panic>
    assert(p0 + 2 == p1);
ffffffffc02014b4:	00006697          	auipc	a3,0x6
ffffffffc02014b8:	c3c68693          	addi	a3,a3,-964 # ffffffffc02070f0 <etext+0xc4e>
ffffffffc02014bc:	00006617          	auipc	a2,0x6
ffffffffc02014c0:	9bc60613          	addi	a2,a2,-1604 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02014c4:	10700593          	li	a1,263
ffffffffc02014c8:	00006517          	auipc	a0,0x6
ffffffffc02014cc:	9c850513          	addi	a0,a0,-1592 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc02014d0:	f7bfe0ef          	jal	ffffffffc020044a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014d4:	00006697          	auipc	a3,0x6
ffffffffc02014d8:	b1c68693          	addi	a3,a3,-1252 # ffffffffc0206ff0 <etext+0xb4e>
ffffffffc02014dc:	00006617          	auipc	a2,0x6
ffffffffc02014e0:	99c60613          	addi	a2,a2,-1636 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02014e4:	10600593          	li	a1,262
ffffffffc02014e8:	00006517          	auipc	a0,0x6
ffffffffc02014ec:	9a850513          	addi	a0,a0,-1624 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc02014f0:	f5bfe0ef          	jal	ffffffffc020044a <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02014f4:	00006697          	auipc	a3,0x6
ffffffffc02014f8:	bdc68693          	addi	a3,a3,-1060 # ffffffffc02070d0 <etext+0xc2e>
ffffffffc02014fc:	00006617          	auipc	a2,0x6
ffffffffc0201500:	97c60613          	addi	a2,a2,-1668 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201504:	10500593          	li	a1,261
ffffffffc0201508:	00006517          	auipc	a0,0x6
ffffffffc020150c:	98850513          	addi	a0,a0,-1656 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201510:	f3bfe0ef          	jal	ffffffffc020044a <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201514:	00006697          	auipc	a3,0x6
ffffffffc0201518:	b8c68693          	addi	a3,a3,-1140 # ffffffffc02070a0 <etext+0xbfe>
ffffffffc020151c:	00006617          	auipc	a2,0x6
ffffffffc0201520:	95c60613          	addi	a2,a2,-1700 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201524:	10400593          	li	a1,260
ffffffffc0201528:	00006517          	auipc	a0,0x6
ffffffffc020152c:	96850513          	addi	a0,a0,-1688 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201530:	f1bfe0ef          	jal	ffffffffc020044a <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201534:	00006697          	auipc	a3,0x6
ffffffffc0201538:	b5468693          	addi	a3,a3,-1196 # ffffffffc0207088 <etext+0xbe6>
ffffffffc020153c:	00006617          	auipc	a2,0x6
ffffffffc0201540:	93c60613          	addi	a2,a2,-1732 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201544:	10300593          	li	a1,259
ffffffffc0201548:	00006517          	auipc	a0,0x6
ffffffffc020154c:	94850513          	addi	a0,a0,-1720 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201550:	efbfe0ef          	jal	ffffffffc020044a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201554:	00006697          	auipc	a3,0x6
ffffffffc0201558:	a9c68693          	addi	a3,a3,-1380 # ffffffffc0206ff0 <etext+0xb4e>
ffffffffc020155c:	00006617          	auipc	a2,0x6
ffffffffc0201560:	91c60613          	addi	a2,a2,-1764 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201564:	0fd00593          	li	a1,253
ffffffffc0201568:	00006517          	auipc	a0,0x6
ffffffffc020156c:	92850513          	addi	a0,a0,-1752 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201570:	edbfe0ef          	jal	ffffffffc020044a <__panic>
    assert(!PageProperty(p0));
ffffffffc0201574:	00006697          	auipc	a3,0x6
ffffffffc0201578:	afc68693          	addi	a3,a3,-1284 # ffffffffc0207070 <etext+0xbce>
ffffffffc020157c:	00006617          	auipc	a2,0x6
ffffffffc0201580:	8fc60613          	addi	a2,a2,-1796 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201584:	0f800593          	li	a1,248
ffffffffc0201588:	00006517          	auipc	a0,0x6
ffffffffc020158c:	90850513          	addi	a0,a0,-1784 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201590:	ebbfe0ef          	jal	ffffffffc020044a <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201594:	00006697          	auipc	a3,0x6
ffffffffc0201598:	bfc68693          	addi	a3,a3,-1028 # ffffffffc0207190 <etext+0xcee>
ffffffffc020159c:	00006617          	auipc	a2,0x6
ffffffffc02015a0:	8dc60613          	addi	a2,a2,-1828 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02015a4:	11600593          	li	a1,278
ffffffffc02015a8:	00006517          	auipc	a0,0x6
ffffffffc02015ac:	8e850513          	addi	a0,a0,-1816 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc02015b0:	e9bfe0ef          	jal	ffffffffc020044a <__panic>
    assert(total == 0);
ffffffffc02015b4:	00006697          	auipc	a3,0x6
ffffffffc02015b8:	c0c68693          	addi	a3,a3,-1012 # ffffffffc02071c0 <etext+0xd1e>
ffffffffc02015bc:	00006617          	auipc	a2,0x6
ffffffffc02015c0:	8bc60613          	addi	a2,a2,-1860 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02015c4:	12500593          	li	a1,293
ffffffffc02015c8:	00006517          	auipc	a0,0x6
ffffffffc02015cc:	8c850513          	addi	a0,a0,-1848 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc02015d0:	e7bfe0ef          	jal	ffffffffc020044a <__panic>
    assert(total == nr_free_pages());
ffffffffc02015d4:	00006697          	auipc	a3,0x6
ffffffffc02015d8:	8d468693          	addi	a3,a3,-1836 # ffffffffc0206ea8 <etext+0xa06>
ffffffffc02015dc:	00006617          	auipc	a2,0x6
ffffffffc02015e0:	89c60613          	addi	a2,a2,-1892 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02015e4:	0f200593          	li	a1,242
ffffffffc02015e8:	00006517          	auipc	a0,0x6
ffffffffc02015ec:	8a850513          	addi	a0,a0,-1880 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc02015f0:	e5bfe0ef          	jal	ffffffffc020044a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02015f4:	00006697          	auipc	a3,0x6
ffffffffc02015f8:	8f468693          	addi	a3,a3,-1804 # ffffffffc0206ee8 <etext+0xa46>
ffffffffc02015fc:	00006617          	auipc	a2,0x6
ffffffffc0201600:	87c60613          	addi	a2,a2,-1924 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201604:	0b900593          	li	a1,185
ffffffffc0201608:	00006517          	auipc	a0,0x6
ffffffffc020160c:	88850513          	addi	a0,a0,-1912 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201610:	e3bfe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201614 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201614:	1141                	addi	sp,sp,-16
ffffffffc0201616:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201618:	14058663          	beqz	a1,ffffffffc0201764 <default_free_pages+0x150>
    for (; p != base + n; p ++) {
ffffffffc020161c:	00659713          	slli	a4,a1,0x6
ffffffffc0201620:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc0201624:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc0201626:	c30d                	beqz	a4,ffffffffc0201648 <default_free_pages+0x34>
ffffffffc0201628:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020162a:	8b05                	andi	a4,a4,1
ffffffffc020162c:	10071c63          	bnez	a4,ffffffffc0201744 <default_free_pages+0x130>
ffffffffc0201630:	6798                	ld	a4,8(a5)
ffffffffc0201632:	8b09                	andi	a4,a4,2
ffffffffc0201634:	10071863          	bnez	a4,ffffffffc0201744 <default_free_pages+0x130>
        p->flags = 0;
ffffffffc0201638:	0007b423          	sd	zero,8(a5)
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc020163c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201640:	04078793          	addi	a5,a5,64
ffffffffc0201644:	fed792e3          	bne	a5,a3,ffffffffc0201628 <default_free_pages+0x14>
    base->property = n;
ffffffffc0201648:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020164a:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020164e:	4789                	li	a5,2
ffffffffc0201650:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201654:	000c7717          	auipc	a4,0xc7
ffffffffc0201658:	b0472703          	lw	a4,-1276(a4) # ffffffffc02c8158 <free_area+0x10>
ffffffffc020165c:	000c7697          	auipc	a3,0xc7
ffffffffc0201660:	aec68693          	addi	a3,a3,-1300 # ffffffffc02c8148 <free_area>
    return list->next == list;
ffffffffc0201664:	669c                	ld	a5,8(a3)
ffffffffc0201666:	9f2d                	addw	a4,a4,a1
ffffffffc0201668:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020166a:	0ad78163          	beq	a5,a3,ffffffffc020170c <default_free_pages+0xf8>
            struct Page* page = le2page(le, page_link);
ffffffffc020166e:	fe878713          	addi	a4,a5,-24
ffffffffc0201672:	4581                	li	a1,0
ffffffffc0201674:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201678:	00e56a63          	bltu	a0,a4,ffffffffc020168c <default_free_pages+0x78>
    return listelm->next;
ffffffffc020167c:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020167e:	04d70c63          	beq	a4,a3,ffffffffc02016d6 <default_free_pages+0xc2>
    struct Page *p = base;
ffffffffc0201682:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc0201684:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201688:	fee57ae3          	bgeu	a0,a4,ffffffffc020167c <default_free_pages+0x68>
ffffffffc020168c:	c199                	beqz	a1,ffffffffc0201692 <default_free_pages+0x7e>
ffffffffc020168e:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201692:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201694:	e390                	sd	a2,0(a5)
ffffffffc0201696:	e710                	sd	a2,8(a4)
    elm->next = next;
    elm->prev = prev;
ffffffffc0201698:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc020169a:	f11c                	sd	a5,32(a0)
    if (le != &free_list) {
ffffffffc020169c:	00d70d63          	beq	a4,a3,ffffffffc02016b6 <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc02016a0:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc02016a4:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc02016a8:	02059813          	slli	a6,a1,0x20
ffffffffc02016ac:	01a85793          	srli	a5,a6,0x1a
ffffffffc02016b0:	97b2                	add	a5,a5,a2
ffffffffc02016b2:	02f50c63          	beq	a0,a5,ffffffffc02016ea <default_free_pages+0xd6>
    return listelm->next;
ffffffffc02016b6:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc02016b8:	00d78c63          	beq	a5,a3,ffffffffc02016d0 <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc02016bc:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc02016be:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc02016c2:	02061593          	slli	a1,a2,0x20
ffffffffc02016c6:	01a5d713          	srli	a4,a1,0x1a
ffffffffc02016ca:	972a                	add	a4,a4,a0
ffffffffc02016cc:	04e68c63          	beq	a3,a4,ffffffffc0201724 <default_free_pages+0x110>
}
ffffffffc02016d0:	60a2                	ld	ra,8(sp)
ffffffffc02016d2:	0141                	addi	sp,sp,16
ffffffffc02016d4:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02016d6:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02016d8:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02016da:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02016dc:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02016de:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02016e0:	02d70f63          	beq	a4,a3,ffffffffc020171e <default_free_pages+0x10a>
ffffffffc02016e4:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc02016e6:	87ba                	mv	a5,a4
ffffffffc02016e8:	bf71                	j	ffffffffc0201684 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc02016ea:	491c                	lw	a5,16(a0)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02016ec:	5875                	li	a6,-3
ffffffffc02016ee:	9fad                	addw	a5,a5,a1
ffffffffc02016f0:	fef72c23          	sw	a5,-8(a4)
ffffffffc02016f4:	6108b02f          	amoand.d	zero,a6,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02016f8:	01853803          	ld	a6,24(a0)
ffffffffc02016fc:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc02016fe:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201700:	00b83423          	sd	a1,8(a6) # ff0008 <_binary_obj___user_matrix_out_size+0xfe4920>
    return listelm->next;
ffffffffc0201704:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0201706:	0105b023          	sd	a6,0(a1)
ffffffffc020170a:	b77d                	j	ffffffffc02016b8 <default_free_pages+0xa4>
}
ffffffffc020170c:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020170e:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc0201712:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201714:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc0201716:	e398                	sd	a4,0(a5)
ffffffffc0201718:	e798                	sd	a4,8(a5)
}
ffffffffc020171a:	0141                	addi	sp,sp,16
ffffffffc020171c:	8082                	ret
ffffffffc020171e:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0201720:	873e                	mv	a4,a5
ffffffffc0201722:	bfad                	j	ffffffffc020169c <default_free_pages+0x88>
            base->property += p->property;
ffffffffc0201724:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201728:	56f5                	li	a3,-3
ffffffffc020172a:	9f31                	addw	a4,a4,a2
ffffffffc020172c:	c918                	sw	a4,16(a0)
ffffffffc020172e:	ff078713          	addi	a4,a5,-16
ffffffffc0201732:	60d7302f          	amoand.d	zero,a3,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201736:	6398                	ld	a4,0(a5)
ffffffffc0201738:	679c                	ld	a5,8(a5)
}
ffffffffc020173a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020173c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020173e:	e398                	sd	a4,0(a5)
ffffffffc0201740:	0141                	addi	sp,sp,16
ffffffffc0201742:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201744:	00006697          	auipc	a3,0x6
ffffffffc0201748:	a9468693          	addi	a3,a3,-1388 # ffffffffc02071d8 <etext+0xd36>
ffffffffc020174c:	00005617          	auipc	a2,0x5
ffffffffc0201750:	72c60613          	addi	a2,a2,1836 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201754:	08200593          	li	a1,130
ffffffffc0201758:	00005517          	auipc	a0,0x5
ffffffffc020175c:	73850513          	addi	a0,a0,1848 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201760:	cebfe0ef          	jal	ffffffffc020044a <__panic>
    assert(n > 0);
ffffffffc0201764:	00006697          	auipc	a3,0x6
ffffffffc0201768:	a6c68693          	addi	a3,a3,-1428 # ffffffffc02071d0 <etext+0xd2e>
ffffffffc020176c:	00005617          	auipc	a2,0x5
ffffffffc0201770:	70c60613          	addi	a2,a2,1804 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201774:	07f00593          	li	a1,127
ffffffffc0201778:	00005517          	auipc	a0,0x5
ffffffffc020177c:	71850513          	addi	a0,a0,1816 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc0201780:	ccbfe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201784 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201784:	c951                	beqz	a0,ffffffffc0201818 <default_alloc_pages+0x94>
    if (n > nr_free) {
ffffffffc0201786:	000c7597          	auipc	a1,0xc7
ffffffffc020178a:	9d25a583          	lw	a1,-1582(a1) # ffffffffc02c8158 <free_area+0x10>
ffffffffc020178e:	86aa                	mv	a3,a0
ffffffffc0201790:	02059793          	slli	a5,a1,0x20
ffffffffc0201794:	9381                	srli	a5,a5,0x20
ffffffffc0201796:	00a7ef63          	bltu	a5,a0,ffffffffc02017b4 <default_alloc_pages+0x30>
    list_entry_t *le = &free_list;
ffffffffc020179a:	000c7617          	auipc	a2,0xc7
ffffffffc020179e:	9ae60613          	addi	a2,a2,-1618 # ffffffffc02c8148 <free_area>
ffffffffc02017a2:	87b2                	mv	a5,a2
ffffffffc02017a4:	a029                	j	ffffffffc02017ae <default_alloc_pages+0x2a>
        if (p->property >= n) {
ffffffffc02017a6:	ff87e703          	lwu	a4,-8(a5)
ffffffffc02017aa:	00d77763          	bgeu	a4,a3,ffffffffc02017b8 <default_alloc_pages+0x34>
    return listelm->next;
ffffffffc02017ae:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc02017b0:	fec79be3          	bne	a5,a2,ffffffffc02017a6 <default_alloc_pages+0x22>
        return NULL;
ffffffffc02017b4:	4501                	li	a0,0
}
ffffffffc02017b6:	8082                	ret
        if (page->property > n) {
ffffffffc02017b8:	ff87a883          	lw	a7,-8(a5)
    return listelm->prev;
ffffffffc02017bc:	0007b803          	ld	a6,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02017c0:	6798                	ld	a4,8(a5)
ffffffffc02017c2:	02089313          	slli	t1,a7,0x20
ffffffffc02017c6:	02035313          	srli	t1,t1,0x20
    prev->next = next;
ffffffffc02017ca:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc02017ce:	01073023          	sd	a6,0(a4)
        struct Page *p = le2page(le, page_link);
ffffffffc02017d2:	fe878513          	addi	a0,a5,-24
        if (page->property > n) {
ffffffffc02017d6:	0266fa63          	bgeu	a3,t1,ffffffffc020180a <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc02017da:	00669713          	slli	a4,a3,0x6
            p->property = page->property - n;
ffffffffc02017de:	40d888bb          	subw	a7,a7,a3
            struct Page *p = page + n;
ffffffffc02017e2:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc02017e4:	01172823          	sw	a7,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02017e8:	00870313          	addi	t1,a4,8
ffffffffc02017ec:	4889                	li	a7,2
ffffffffc02017ee:	4113302f          	amoor.d	zero,a7,(t1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02017f2:	00883883          	ld	a7,8(a6)
            list_add(prev, &(p->page_link));
ffffffffc02017f6:	01870313          	addi	t1,a4,24
    prev->next = next->prev = elm;
ffffffffc02017fa:	0068b023          	sd	t1,0(a7)
ffffffffc02017fe:	00683423          	sd	t1,8(a6)
    elm->next = next;
ffffffffc0201802:	03173023          	sd	a7,32(a4)
    elm->prev = prev;
ffffffffc0201806:	01073c23          	sd	a6,24(a4)
        nr_free -= n;
ffffffffc020180a:	9d95                	subw	a1,a1,a3
ffffffffc020180c:	ca0c                	sw	a1,16(a2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020180e:	5775                	li	a4,-3
ffffffffc0201810:	17c1                	addi	a5,a5,-16
ffffffffc0201812:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201816:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201818:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020181a:	00006697          	auipc	a3,0x6
ffffffffc020181e:	9b668693          	addi	a3,a3,-1610 # ffffffffc02071d0 <etext+0xd2e>
ffffffffc0201822:	00005617          	auipc	a2,0x5
ffffffffc0201826:	65660613          	addi	a2,a2,1622 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc020182a:	06100593          	li	a1,97
ffffffffc020182e:	00005517          	auipc	a0,0x5
ffffffffc0201832:	66250513          	addi	a0,a0,1634 # ffffffffc0206e90 <etext+0x9ee>
default_alloc_pages(size_t n) {
ffffffffc0201836:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201838:	c13fe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020183c <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020183c:	1141                	addi	sp,sp,-16
ffffffffc020183e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201840:	c9e1                	beqz	a1,ffffffffc0201910 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0201842:	00659713          	slli	a4,a1,0x6
ffffffffc0201846:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc020184a:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc020184c:	cf11                	beqz	a4,ffffffffc0201868 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020184e:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201850:	8b05                	andi	a4,a4,1
ffffffffc0201852:	cf59                	beqz	a4,ffffffffc02018f0 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0201854:	0007a823          	sw	zero,16(a5)
ffffffffc0201858:	0007b423          	sd	zero,8(a5)
ffffffffc020185c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201860:	04078793          	addi	a5,a5,64
ffffffffc0201864:	fed795e3          	bne	a5,a3,ffffffffc020184e <default_init_memmap+0x12>
    base->property = n;
ffffffffc0201868:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020186a:	4789                	li	a5,2
ffffffffc020186c:	00850713          	addi	a4,a0,8
ffffffffc0201870:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201874:	000c7717          	auipc	a4,0xc7
ffffffffc0201878:	8e472703          	lw	a4,-1820(a4) # ffffffffc02c8158 <free_area+0x10>
ffffffffc020187c:	000c7697          	auipc	a3,0xc7
ffffffffc0201880:	8cc68693          	addi	a3,a3,-1844 # ffffffffc02c8148 <free_area>
    return list->next == list;
ffffffffc0201884:	669c                	ld	a5,8(a3)
ffffffffc0201886:	9f2d                	addw	a4,a4,a1
ffffffffc0201888:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc020188a:	04d78663          	beq	a5,a3,ffffffffc02018d6 <default_init_memmap+0x9a>
            struct Page* page = le2page(le, page_link);
ffffffffc020188e:	fe878713          	addi	a4,a5,-24
ffffffffc0201892:	4581                	li	a1,0
ffffffffc0201894:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201898:	00e56a63          	bltu	a0,a4,ffffffffc02018ac <default_init_memmap+0x70>
    return listelm->next;
ffffffffc020189c:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc020189e:	02d70263          	beq	a4,a3,ffffffffc02018c2 <default_init_memmap+0x86>
    struct Page *p = base;
ffffffffc02018a2:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02018a4:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02018a8:	fee57ae3          	bgeu	a0,a4,ffffffffc020189c <default_init_memmap+0x60>
ffffffffc02018ac:	c199                	beqz	a1,ffffffffc02018b2 <default_init_memmap+0x76>
ffffffffc02018ae:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02018b2:	6398                	ld	a4,0(a5)
}
ffffffffc02018b4:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc02018b6:	e390                	sd	a2,0(a5)
ffffffffc02018b8:	e710                	sd	a2,8(a4)
    elm->prev = prev;
ffffffffc02018ba:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc02018bc:	f11c                	sd	a5,32(a0)
ffffffffc02018be:	0141                	addi	sp,sp,16
ffffffffc02018c0:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02018c2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02018c4:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02018c6:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02018c8:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02018ca:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc02018cc:	00d70e63          	beq	a4,a3,ffffffffc02018e8 <default_init_memmap+0xac>
ffffffffc02018d0:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc02018d2:	87ba                	mv	a5,a4
ffffffffc02018d4:	bfc1                	j	ffffffffc02018a4 <default_init_memmap+0x68>
}
ffffffffc02018d6:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02018d8:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc02018dc:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02018de:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc02018e0:	e398                	sd	a4,0(a5)
ffffffffc02018e2:	e798                	sd	a4,8(a5)
}
ffffffffc02018e4:	0141                	addi	sp,sp,16
ffffffffc02018e6:	8082                	ret
ffffffffc02018e8:	60a2                	ld	ra,8(sp)
ffffffffc02018ea:	e290                	sd	a2,0(a3)
ffffffffc02018ec:	0141                	addi	sp,sp,16
ffffffffc02018ee:	8082                	ret
        assert(PageReserved(p));
ffffffffc02018f0:	00006697          	auipc	a3,0x6
ffffffffc02018f4:	91068693          	addi	a3,a3,-1776 # ffffffffc0207200 <etext+0xd5e>
ffffffffc02018f8:	00005617          	auipc	a2,0x5
ffffffffc02018fc:	58060613          	addi	a2,a2,1408 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201900:	04800593          	li	a1,72
ffffffffc0201904:	00005517          	auipc	a0,0x5
ffffffffc0201908:	58c50513          	addi	a0,a0,1420 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc020190c:	b3ffe0ef          	jal	ffffffffc020044a <__panic>
    assert(n > 0);
ffffffffc0201910:	00006697          	auipc	a3,0x6
ffffffffc0201914:	8c068693          	addi	a3,a3,-1856 # ffffffffc02071d0 <etext+0xd2e>
ffffffffc0201918:	00005617          	auipc	a2,0x5
ffffffffc020191c:	56060613          	addi	a2,a2,1376 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201920:	04500593          	li	a1,69
ffffffffc0201924:	00005517          	auipc	a0,0x5
ffffffffc0201928:	56c50513          	addi	a0,a0,1388 # ffffffffc0206e90 <etext+0x9ee>
ffffffffc020192c:	b1ffe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201930 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201930:	c531                	beqz	a0,ffffffffc020197c <slob_free+0x4c>
		return;

	if (size)
ffffffffc0201932:	e9b9                	bnez	a1,ffffffffc0201988 <slob_free+0x58>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201934:	100027f3          	csrr	a5,sstatus
ffffffffc0201938:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020193a:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020193c:	efb1                	bnez	a5,ffffffffc0201998 <slob_free+0x68>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020193e:	000c6797          	auipc	a5,0xc6
ffffffffc0201942:	3f27b783          	ld	a5,1010(a5) # ffffffffc02c7d30 <slobfree>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201946:	873e                	mv	a4,a5
ffffffffc0201948:	679c                	ld	a5,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc020194a:	02a77a63          	bgeu	a4,a0,ffffffffc020197e <slob_free+0x4e>
ffffffffc020194e:	00f56463          	bltu	a0,a5,ffffffffc0201956 <slob_free+0x26>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201952:	fef76ae3          	bltu	a4,a5,ffffffffc0201946 <slob_free+0x16>
			break;

	if (b + b->units == cur->next)
ffffffffc0201956:	4110                	lw	a2,0(a0)
ffffffffc0201958:	00461693          	slli	a3,a2,0x4
ffffffffc020195c:	96aa                	add	a3,a3,a0
ffffffffc020195e:	0ad78463          	beq	a5,a3,ffffffffc0201a06 <slob_free+0xd6>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc0201962:	4310                	lw	a2,0(a4)
ffffffffc0201964:	e51c                	sd	a5,8(a0)
ffffffffc0201966:	00461693          	slli	a3,a2,0x4
ffffffffc020196a:	96ba                	add	a3,a3,a4
ffffffffc020196c:	08d50163          	beq	a0,a3,ffffffffc02019ee <slob_free+0xbe>
ffffffffc0201970:	e708                	sd	a0,8(a4)
		cur->next = b->next;
	}
	else
		cur->next = b;

	slobfree = cur;
ffffffffc0201972:	000c6797          	auipc	a5,0xc6
ffffffffc0201976:	3ae7bf23          	sd	a4,958(a5) # ffffffffc02c7d30 <slobfree>
    if (flag) {
ffffffffc020197a:	e9a5                	bnez	a1,ffffffffc02019ea <slob_free+0xba>
ffffffffc020197c:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc020197e:	fcf574e3          	bgeu	a0,a5,ffffffffc0201946 <slob_free+0x16>
ffffffffc0201982:	fcf762e3          	bltu	a4,a5,ffffffffc0201946 <slob_free+0x16>
ffffffffc0201986:	bfc1                	j	ffffffffc0201956 <slob_free+0x26>
		b->units = SLOB_UNITS(size);
ffffffffc0201988:	25bd                	addiw	a1,a1,15
ffffffffc020198a:	8191                	srli	a1,a1,0x4
ffffffffc020198c:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020198e:	100027f3          	csrr	a5,sstatus
ffffffffc0201992:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201994:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201996:	d7c5                	beqz	a5,ffffffffc020193e <slob_free+0xe>
{
ffffffffc0201998:	1101                	addi	sp,sp,-32
ffffffffc020199a:	e42a                	sd	a0,8(sp)
ffffffffc020199c:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020199e:	f61fe0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc02019a2:	6522                	ld	a0,8(sp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019a4:	000c6797          	auipc	a5,0xc6
ffffffffc02019a8:	38c7b783          	ld	a5,908(a5) # ffffffffc02c7d30 <slobfree>
ffffffffc02019ac:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019ae:	873e                	mv	a4,a5
ffffffffc02019b0:	679c                	ld	a5,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019b2:	06a77663          	bgeu	a4,a0,ffffffffc0201a1e <slob_free+0xee>
ffffffffc02019b6:	00f56463          	bltu	a0,a5,ffffffffc02019be <slob_free+0x8e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019ba:	fef76ae3          	bltu	a4,a5,ffffffffc02019ae <slob_free+0x7e>
	if (b + b->units == cur->next)
ffffffffc02019be:	4110                	lw	a2,0(a0)
ffffffffc02019c0:	00461693          	slli	a3,a2,0x4
ffffffffc02019c4:	96aa                	add	a3,a3,a0
ffffffffc02019c6:	06d78363          	beq	a5,a3,ffffffffc0201a2c <slob_free+0xfc>
	if (cur + cur->units == b)
ffffffffc02019ca:	4310                	lw	a2,0(a4)
ffffffffc02019cc:	e51c                	sd	a5,8(a0)
ffffffffc02019ce:	00461693          	slli	a3,a2,0x4
ffffffffc02019d2:	96ba                	add	a3,a3,a4
ffffffffc02019d4:	06d50163          	beq	a0,a3,ffffffffc0201a36 <slob_free+0x106>
ffffffffc02019d8:	e708                	sd	a0,8(a4)
	slobfree = cur;
ffffffffc02019da:	000c6797          	auipc	a5,0xc6
ffffffffc02019de:	34e7bb23          	sd	a4,854(a5) # ffffffffc02c7d30 <slobfree>
    if (flag) {
ffffffffc02019e2:	e1a9                	bnez	a1,ffffffffc0201a24 <slob_free+0xf4>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc02019e4:	60e2                	ld	ra,24(sp)
ffffffffc02019e6:	6105                	addi	sp,sp,32
ffffffffc02019e8:	8082                	ret
        intr_enable();
ffffffffc02019ea:	f0ffe06f          	j	ffffffffc02008f8 <intr_enable>
		cur->units += b->units;
ffffffffc02019ee:	4114                	lw	a3,0(a0)
		cur->next = b->next;
ffffffffc02019f0:	853e                	mv	a0,a5
ffffffffc02019f2:	e708                	sd	a0,8(a4)
		cur->units += b->units;
ffffffffc02019f4:	00c687bb          	addw	a5,a3,a2
ffffffffc02019f8:	c31c                	sw	a5,0(a4)
	slobfree = cur;
ffffffffc02019fa:	000c6797          	auipc	a5,0xc6
ffffffffc02019fe:	32e7bb23          	sd	a4,822(a5) # ffffffffc02c7d30 <slobfree>
    if (flag) {
ffffffffc0201a02:	ddad                	beqz	a1,ffffffffc020197c <slob_free+0x4c>
ffffffffc0201a04:	b7dd                	j	ffffffffc02019ea <slob_free+0xba>
		b->units += cur->next->units;
ffffffffc0201a06:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201a08:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201a0a:	9eb1                	addw	a3,a3,a2
ffffffffc0201a0c:	c114                	sw	a3,0(a0)
	if (cur + cur->units == b)
ffffffffc0201a0e:	4310                	lw	a2,0(a4)
ffffffffc0201a10:	e51c                	sd	a5,8(a0)
ffffffffc0201a12:	00461693          	slli	a3,a2,0x4
ffffffffc0201a16:	96ba                	add	a3,a3,a4
ffffffffc0201a18:	f4d51ce3          	bne	a0,a3,ffffffffc0201970 <slob_free+0x40>
ffffffffc0201a1c:	bfc9                	j	ffffffffc02019ee <slob_free+0xbe>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a1e:	f8f56ee3          	bltu	a0,a5,ffffffffc02019ba <slob_free+0x8a>
ffffffffc0201a22:	b771                	j	ffffffffc02019ae <slob_free+0x7e>
}
ffffffffc0201a24:	60e2                	ld	ra,24(sp)
ffffffffc0201a26:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201a28:	ed1fe06f          	j	ffffffffc02008f8 <intr_enable>
		b->units += cur->next->units;
ffffffffc0201a2c:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201a2e:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201a30:	9eb1                	addw	a3,a3,a2
ffffffffc0201a32:	c114                	sw	a3,0(a0)
		b->next = cur->next->next;
ffffffffc0201a34:	bf59                	j	ffffffffc02019ca <slob_free+0x9a>
		cur->units += b->units;
ffffffffc0201a36:	4114                	lw	a3,0(a0)
		cur->next = b->next;
ffffffffc0201a38:	853e                	mv	a0,a5
		cur->units += b->units;
ffffffffc0201a3a:	00c687bb          	addw	a5,a3,a2
ffffffffc0201a3e:	c31c                	sw	a5,0(a4)
		cur->next = b->next;
ffffffffc0201a40:	bf61                	j	ffffffffc02019d8 <slob_free+0xa8>

ffffffffc0201a42 <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201a42:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201a44:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201a46:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201a4a:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201a4c:	32a000ef          	jal	ffffffffc0201d76 <alloc_pages>
	if (!page)
ffffffffc0201a50:	c91d                	beqz	a0,ffffffffc0201a86 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201a52:	000cb697          	auipc	a3,0xcb
ffffffffc0201a56:	8ee6b683          	ld	a3,-1810(a3) # ffffffffc02cc340 <pages>
ffffffffc0201a5a:	00008797          	auipc	a5,0x8
ffffffffc0201a5e:	80e7b783          	ld	a5,-2034(a5) # ffffffffc0209268 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201a62:	000cb717          	auipc	a4,0xcb
ffffffffc0201a66:	8d673703          	ld	a4,-1834(a4) # ffffffffc02cc338 <npage>
    return page - pages + nbase;
ffffffffc0201a6a:	8d15                	sub	a0,a0,a3
ffffffffc0201a6c:	8519                	srai	a0,a0,0x6
ffffffffc0201a6e:	953e                	add	a0,a0,a5
    return KADDR(page2pa(page));
ffffffffc0201a70:	00c51793          	slli	a5,a0,0xc
ffffffffc0201a74:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201a76:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201a78:	00e7fa63          	bgeu	a5,a4,ffffffffc0201a8c <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201a7c:	000cb797          	auipc	a5,0xcb
ffffffffc0201a80:	8b47b783          	ld	a5,-1868(a5) # ffffffffc02cc330 <va_pa_offset>
ffffffffc0201a84:	953e                	add	a0,a0,a5
}
ffffffffc0201a86:	60a2                	ld	ra,8(sp)
ffffffffc0201a88:	0141                	addi	sp,sp,16
ffffffffc0201a8a:	8082                	ret
ffffffffc0201a8c:	86aa                	mv	a3,a0
ffffffffc0201a8e:	00005617          	auipc	a2,0x5
ffffffffc0201a92:	79a60613          	addi	a2,a2,1946 # ffffffffc0207228 <etext+0xd86>
ffffffffc0201a96:	07100593          	li	a1,113
ffffffffc0201a9a:	00005517          	auipc	a0,0x5
ffffffffc0201a9e:	7b650513          	addi	a0,a0,1974 # ffffffffc0207250 <etext+0xdae>
ffffffffc0201aa2:	9a9fe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201aa6 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201aa6:	7179                	addi	sp,sp,-48
ffffffffc0201aa8:	f406                	sd	ra,40(sp)
ffffffffc0201aaa:	f022                	sd	s0,32(sp)
ffffffffc0201aac:	ec26                	sd	s1,24(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201aae:	01050713          	addi	a4,a0,16
ffffffffc0201ab2:	6785                	lui	a5,0x1
ffffffffc0201ab4:	0af77e63          	bgeu	a4,a5,ffffffffc0201b70 <slob_alloc.constprop.0+0xca>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201ab8:	00f50413          	addi	s0,a0,15
ffffffffc0201abc:	8011                	srli	s0,s0,0x4
ffffffffc0201abe:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ac0:	100025f3          	csrr	a1,sstatus
ffffffffc0201ac4:	8989                	andi	a1,a1,2
ffffffffc0201ac6:	edd1                	bnez	a1,ffffffffc0201b62 <slob_alloc.constprop.0+0xbc>
	prev = slobfree;
ffffffffc0201ac8:	000c6497          	auipc	s1,0xc6
ffffffffc0201acc:	26848493          	addi	s1,s1,616 # ffffffffc02c7d30 <slobfree>
ffffffffc0201ad0:	6090                	ld	a2,0(s1)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201ad2:	6618                	ld	a4,8(a2)
		if (cur->units >= units + delta)
ffffffffc0201ad4:	4314                	lw	a3,0(a4)
ffffffffc0201ad6:	0886da63          	bge	a3,s0,ffffffffc0201b6a <slob_alloc.constprop.0+0xc4>
		if (cur == slobfree)
ffffffffc0201ada:	00e60a63          	beq	a2,a4,ffffffffc0201aee <slob_alloc.constprop.0+0x48>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201ade:	671c                	ld	a5,8(a4)
		if (cur->units >= units + delta)
ffffffffc0201ae0:	4394                	lw	a3,0(a5)
ffffffffc0201ae2:	0286d863          	bge	a3,s0,ffffffffc0201b12 <slob_alloc.constprop.0+0x6c>
		if (cur == slobfree)
ffffffffc0201ae6:	6090                	ld	a2,0(s1)
ffffffffc0201ae8:	873e                	mv	a4,a5
ffffffffc0201aea:	fee61ae3          	bne	a2,a4,ffffffffc0201ade <slob_alloc.constprop.0+0x38>
    if (flag) {
ffffffffc0201aee:	e9b1                	bnez	a1,ffffffffc0201b42 <slob_alloc.constprop.0+0x9c>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201af0:	4501                	li	a0,0
ffffffffc0201af2:	f51ff0ef          	jal	ffffffffc0201a42 <__slob_get_free_pages.constprop.0>
ffffffffc0201af6:	87aa                	mv	a5,a0
			if (!cur)
ffffffffc0201af8:	c915                	beqz	a0,ffffffffc0201b2c <slob_alloc.constprop.0+0x86>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201afa:	6585                	lui	a1,0x1
ffffffffc0201afc:	e35ff0ef          	jal	ffffffffc0201930 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201b00:	100025f3          	csrr	a1,sstatus
ffffffffc0201b04:	8989                	andi	a1,a1,2
ffffffffc0201b06:	e98d                	bnez	a1,ffffffffc0201b38 <slob_alloc.constprop.0+0x92>
			cur = slobfree;
ffffffffc0201b08:	6098                	ld	a4,0(s1)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201b0a:	671c                	ld	a5,8(a4)
		if (cur->units >= units + delta)
ffffffffc0201b0c:	4394                	lw	a3,0(a5)
ffffffffc0201b0e:	fc86cce3          	blt	a3,s0,ffffffffc0201ae6 <slob_alloc.constprop.0+0x40>
			if (cur->units == units)	/* exact fit? */
ffffffffc0201b12:	04d40563          	beq	s0,a3,ffffffffc0201b5c <slob_alloc.constprop.0+0xb6>
				prev->next = cur + units;
ffffffffc0201b16:	00441613          	slli	a2,s0,0x4
ffffffffc0201b1a:	963e                	add	a2,a2,a5
ffffffffc0201b1c:	e710                	sd	a2,8(a4)
				prev->next->next = cur->next;
ffffffffc0201b1e:	6788                	ld	a0,8(a5)
				prev->next->units = cur->units - units;
ffffffffc0201b20:	9e81                	subw	a3,a3,s0
ffffffffc0201b22:	c214                	sw	a3,0(a2)
				prev->next->next = cur->next;
ffffffffc0201b24:	e608                	sd	a0,8(a2)
				cur->units = units;
ffffffffc0201b26:	c380                	sw	s0,0(a5)
			slobfree = prev;
ffffffffc0201b28:	e098                	sd	a4,0(s1)
    if (flag) {
ffffffffc0201b2a:	ed99                	bnez	a1,ffffffffc0201b48 <slob_alloc.constprop.0+0xa2>
}
ffffffffc0201b2c:	70a2                	ld	ra,40(sp)
ffffffffc0201b2e:	7402                	ld	s0,32(sp)
ffffffffc0201b30:	64e2                	ld	s1,24(sp)
ffffffffc0201b32:	853e                	mv	a0,a5
ffffffffc0201b34:	6145                	addi	sp,sp,48
ffffffffc0201b36:	8082                	ret
        intr_disable();
ffffffffc0201b38:	dc7fe0ef          	jal	ffffffffc02008fe <intr_disable>
			cur = slobfree;
ffffffffc0201b3c:	6098                	ld	a4,0(s1)
        return 1;
ffffffffc0201b3e:	4585                	li	a1,1
ffffffffc0201b40:	b7e9                	j	ffffffffc0201b0a <slob_alloc.constprop.0+0x64>
        intr_enable();
ffffffffc0201b42:	db7fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0201b46:	b76d                	j	ffffffffc0201af0 <slob_alloc.constprop.0+0x4a>
ffffffffc0201b48:	e43e                	sd	a5,8(sp)
ffffffffc0201b4a:	daffe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0201b4e:	67a2                	ld	a5,8(sp)
}
ffffffffc0201b50:	70a2                	ld	ra,40(sp)
ffffffffc0201b52:	7402                	ld	s0,32(sp)
ffffffffc0201b54:	64e2                	ld	s1,24(sp)
ffffffffc0201b56:	853e                	mv	a0,a5
ffffffffc0201b58:	6145                	addi	sp,sp,48
ffffffffc0201b5a:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201b5c:	6794                	ld	a3,8(a5)
ffffffffc0201b5e:	e714                	sd	a3,8(a4)
ffffffffc0201b60:	b7e1                	j	ffffffffc0201b28 <slob_alloc.constprop.0+0x82>
        intr_disable();
ffffffffc0201b62:	d9dfe0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc0201b66:	4585                	li	a1,1
ffffffffc0201b68:	b785                	j	ffffffffc0201ac8 <slob_alloc.constprop.0+0x22>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201b6a:	87ba                	mv	a5,a4
	prev = slobfree;
ffffffffc0201b6c:	8732                	mv	a4,a2
ffffffffc0201b6e:	b755                	j	ffffffffc0201b12 <slob_alloc.constprop.0+0x6c>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201b70:	00005697          	auipc	a3,0x5
ffffffffc0201b74:	6f068693          	addi	a3,a3,1776 # ffffffffc0207260 <etext+0xdbe>
ffffffffc0201b78:	00005617          	auipc	a2,0x5
ffffffffc0201b7c:	30060613          	addi	a2,a2,768 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0201b80:	06300593          	li	a1,99
ffffffffc0201b84:	00005517          	auipc	a0,0x5
ffffffffc0201b88:	6fc50513          	addi	a0,a0,1788 # ffffffffc0207280 <etext+0xdde>
ffffffffc0201b8c:	8bffe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201b90 <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc0201b90:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc0201b92:	00005517          	auipc	a0,0x5
ffffffffc0201b96:	70650513          	addi	a0,a0,1798 # ffffffffc0207298 <etext+0xdf6>
{
ffffffffc0201b9a:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc0201b9c:	dfcfe0ef          	jal	ffffffffc0200198 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201ba0:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201ba2:	00005517          	auipc	a0,0x5
ffffffffc0201ba6:	70e50513          	addi	a0,a0,1806 # ffffffffc02072b0 <etext+0xe0e>
}
ffffffffc0201baa:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201bac:	decfe06f          	j	ffffffffc0200198 <cprintf>

ffffffffc0201bb0 <kallocated>:

size_t
kallocated(void)
{
	return slob_allocated();
}
ffffffffc0201bb0:	4501                	li	a0,0
ffffffffc0201bb2:	8082                	ret

ffffffffc0201bb4 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201bb4:	1101                	addi	sp,sp,-32
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201bb6:	6685                	lui	a3,0x1
{
ffffffffc0201bb8:	ec06                	sd	ra,24(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201bba:	16bd                	addi	a3,a3,-17 # fef <_binary_obj___user_softint_out_size-0x80f9>
ffffffffc0201bbc:	04a6f963          	bgeu	a3,a0,ffffffffc0201c0e <kmalloc+0x5a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201bc0:	e42a                	sd	a0,8(sp)
ffffffffc0201bc2:	4561                	li	a0,24
ffffffffc0201bc4:	e822                	sd	s0,16(sp)
ffffffffc0201bc6:	ee1ff0ef          	jal	ffffffffc0201aa6 <slob_alloc.constprop.0>
ffffffffc0201bca:	842a                	mv	s0,a0
	if (!bb)
ffffffffc0201bcc:	c541                	beqz	a0,ffffffffc0201c54 <kmalloc+0xa0>
	bb->order = find_order(size);
ffffffffc0201bce:	47a2                	lw	a5,8(sp)
	for (; size > 4096; size >>= 1)
ffffffffc0201bd0:	6705                	lui	a4,0x1
	int order = 0;
ffffffffc0201bd2:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201bd4:	00f75763          	bge	a4,a5,ffffffffc0201be2 <kmalloc+0x2e>
ffffffffc0201bd8:	4017d79b          	sraiw	a5,a5,0x1
		order++;
ffffffffc0201bdc:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc0201bde:	fef74de3          	blt	a4,a5,ffffffffc0201bd8 <kmalloc+0x24>
	bb->order = find_order(size);
ffffffffc0201be2:	c008                	sw	a0,0(s0)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201be4:	e5fff0ef          	jal	ffffffffc0201a42 <__slob_get_free_pages.constprop.0>
ffffffffc0201be8:	e408                	sd	a0,8(s0)
	if (bb->pages)
ffffffffc0201bea:	cd31                	beqz	a0,ffffffffc0201c46 <kmalloc+0x92>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201bec:	100027f3          	csrr	a5,sstatus
ffffffffc0201bf0:	8b89                	andi	a5,a5,2
ffffffffc0201bf2:	eb85                	bnez	a5,ffffffffc0201c22 <kmalloc+0x6e>
		bb->next = bigblocks;
ffffffffc0201bf4:	000ca797          	auipc	a5,0xca
ffffffffc0201bf8:	71c7b783          	ld	a5,1820(a5) # ffffffffc02cc310 <bigblocks>
		bigblocks = bb;
ffffffffc0201bfc:	000ca717          	auipc	a4,0xca
ffffffffc0201c00:	70873a23          	sd	s0,1812(a4) # ffffffffc02cc310 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201c04:	e81c                	sd	a5,16(s0)
    if (flag) {
ffffffffc0201c06:	6442                	ld	s0,16(sp)
	return __kmalloc(size, 0);
}
ffffffffc0201c08:	60e2                	ld	ra,24(sp)
ffffffffc0201c0a:	6105                	addi	sp,sp,32
ffffffffc0201c0c:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201c0e:	0541                	addi	a0,a0,16
ffffffffc0201c10:	e97ff0ef          	jal	ffffffffc0201aa6 <slob_alloc.constprop.0>
ffffffffc0201c14:	87aa                	mv	a5,a0
		return m ? (void *)(m + 1) : 0;
ffffffffc0201c16:	0541                	addi	a0,a0,16
ffffffffc0201c18:	fbe5                	bnez	a5,ffffffffc0201c08 <kmalloc+0x54>
		return 0;
ffffffffc0201c1a:	4501                	li	a0,0
}
ffffffffc0201c1c:	60e2                	ld	ra,24(sp)
ffffffffc0201c1e:	6105                	addi	sp,sp,32
ffffffffc0201c20:	8082                	ret
        intr_disable();
ffffffffc0201c22:	cddfe0ef          	jal	ffffffffc02008fe <intr_disable>
		bb->next = bigblocks;
ffffffffc0201c26:	000ca797          	auipc	a5,0xca
ffffffffc0201c2a:	6ea7b783          	ld	a5,1770(a5) # ffffffffc02cc310 <bigblocks>
		bigblocks = bb;
ffffffffc0201c2e:	000ca717          	auipc	a4,0xca
ffffffffc0201c32:	6e873123          	sd	s0,1762(a4) # ffffffffc02cc310 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201c36:	e81c                	sd	a5,16(s0)
        intr_enable();
ffffffffc0201c38:	cc1fe0ef          	jal	ffffffffc02008f8 <intr_enable>
		return bb->pages;
ffffffffc0201c3c:	6408                	ld	a0,8(s0)
}
ffffffffc0201c3e:	60e2                	ld	ra,24(sp)
		return bb->pages;
ffffffffc0201c40:	6442                	ld	s0,16(sp)
}
ffffffffc0201c42:	6105                	addi	sp,sp,32
ffffffffc0201c44:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c46:	8522                	mv	a0,s0
ffffffffc0201c48:	45e1                	li	a1,24
ffffffffc0201c4a:	ce7ff0ef          	jal	ffffffffc0201930 <slob_free>
		return 0;
ffffffffc0201c4e:	4501                	li	a0,0
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201c50:	6442                	ld	s0,16(sp)
ffffffffc0201c52:	b7e9                	j	ffffffffc0201c1c <kmalloc+0x68>
ffffffffc0201c54:	6442                	ld	s0,16(sp)
		return 0;
ffffffffc0201c56:	4501                	li	a0,0
ffffffffc0201c58:	b7d1                	j	ffffffffc0201c1c <kmalloc+0x68>

ffffffffc0201c5a <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201c5a:	c571                	beqz	a0,ffffffffc0201d26 <kfree+0xcc>
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201c5c:	03451793          	slli	a5,a0,0x34
ffffffffc0201c60:	e3e1                	bnez	a5,ffffffffc0201d20 <kfree+0xc6>
{
ffffffffc0201c62:	1101                	addi	sp,sp,-32
ffffffffc0201c64:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c66:	100027f3          	csrr	a5,sstatus
ffffffffc0201c6a:	8b89                	andi	a5,a5,2
ffffffffc0201c6c:	e7c1                	bnez	a5,ffffffffc0201cf4 <kfree+0x9a>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201c6e:	000ca797          	auipc	a5,0xca
ffffffffc0201c72:	6a27b783          	ld	a5,1698(a5) # ffffffffc02cc310 <bigblocks>
    return 0;
ffffffffc0201c76:	4581                	li	a1,0
ffffffffc0201c78:	cbad                	beqz	a5,ffffffffc0201cea <kfree+0x90>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201c7a:	000ca617          	auipc	a2,0xca
ffffffffc0201c7e:	69660613          	addi	a2,a2,1686 # ffffffffc02cc310 <bigblocks>
ffffffffc0201c82:	a021                	j	ffffffffc0201c8a <kfree+0x30>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201c84:	01070613          	addi	a2,a4,16
ffffffffc0201c88:	c3a5                	beqz	a5,ffffffffc0201ce8 <kfree+0x8e>
		{
			if (bb->pages == block)
ffffffffc0201c8a:	6794                	ld	a3,8(a5)
ffffffffc0201c8c:	873e                	mv	a4,a5
			{
				*last = bb->next;
ffffffffc0201c8e:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0201c90:	fea69ae3          	bne	a3,a0,ffffffffc0201c84 <kfree+0x2a>
				*last = bb->next;
ffffffffc0201c94:	e21c                	sd	a5,0(a2)
    if (flag) {
ffffffffc0201c96:	edb5                	bnez	a1,ffffffffc0201d12 <kfree+0xb8>
    return pa2page(PADDR(kva));
ffffffffc0201c98:	c02007b7          	lui	a5,0xc0200
ffffffffc0201c9c:	0af56263          	bltu	a0,a5,ffffffffc0201d40 <kfree+0xe6>
ffffffffc0201ca0:	000ca797          	auipc	a5,0xca
ffffffffc0201ca4:	6907b783          	ld	a5,1680(a5) # ffffffffc02cc330 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc0201ca8:	000ca697          	auipc	a3,0xca
ffffffffc0201cac:	6906b683          	ld	a3,1680(a3) # ffffffffc02cc338 <npage>
    return pa2page(PADDR(kva));
ffffffffc0201cb0:	8d1d                	sub	a0,a0,a5
    if (PPN(pa) >= npage)
ffffffffc0201cb2:	00c55793          	srli	a5,a0,0xc
ffffffffc0201cb6:	06d7f963          	bgeu	a5,a3,ffffffffc0201d28 <kfree+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0201cba:	00007617          	auipc	a2,0x7
ffffffffc0201cbe:	5ae63603          	ld	a2,1454(a2) # ffffffffc0209268 <nbase>
ffffffffc0201cc2:	000ca517          	auipc	a0,0xca
ffffffffc0201cc6:	67e53503          	ld	a0,1662(a0) # ffffffffc02cc340 <pages>
	free_pages(kva2page((void*)kva), 1 << order);
ffffffffc0201cca:	4314                	lw	a3,0(a4)
ffffffffc0201ccc:	8f91                	sub	a5,a5,a2
ffffffffc0201cce:	079a                	slli	a5,a5,0x6
ffffffffc0201cd0:	4585                	li	a1,1
ffffffffc0201cd2:	953e                	add	a0,a0,a5
ffffffffc0201cd4:	00d595bb          	sllw	a1,a1,a3
ffffffffc0201cd8:	e03a                	sd	a4,0(sp)
ffffffffc0201cda:	0d6000ef          	jal	ffffffffc0201db0 <free_pages>
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201cde:	6502                	ld	a0,0(sp)
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201ce0:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201ce2:	45e1                	li	a1,24
}
ffffffffc0201ce4:	6105                	addi	sp,sp,32
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201ce6:	b1a9                	j	ffffffffc0201930 <slob_free>
ffffffffc0201ce8:	e185                	bnez	a1,ffffffffc0201d08 <kfree+0xae>
}
ffffffffc0201cea:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201cec:	1541                	addi	a0,a0,-16
ffffffffc0201cee:	4581                	li	a1,0
}
ffffffffc0201cf0:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201cf2:	b93d                	j	ffffffffc0201930 <slob_free>
        intr_disable();
ffffffffc0201cf4:	e02a                	sd	a0,0(sp)
ffffffffc0201cf6:	c09fe0ef          	jal	ffffffffc02008fe <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201cfa:	000ca797          	auipc	a5,0xca
ffffffffc0201cfe:	6167b783          	ld	a5,1558(a5) # ffffffffc02cc310 <bigblocks>
ffffffffc0201d02:	6502                	ld	a0,0(sp)
        return 1;
ffffffffc0201d04:	4585                	li	a1,1
ffffffffc0201d06:	fbb5                	bnez	a5,ffffffffc0201c7a <kfree+0x20>
ffffffffc0201d08:	e02a                	sd	a0,0(sp)
        intr_enable();
ffffffffc0201d0a:	beffe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0201d0e:	6502                	ld	a0,0(sp)
ffffffffc0201d10:	bfe9                	j	ffffffffc0201cea <kfree+0x90>
ffffffffc0201d12:	e42a                	sd	a0,8(sp)
ffffffffc0201d14:	e03a                	sd	a4,0(sp)
ffffffffc0201d16:	be3fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0201d1a:	6522                	ld	a0,8(sp)
ffffffffc0201d1c:	6702                	ld	a4,0(sp)
ffffffffc0201d1e:	bfad                	j	ffffffffc0201c98 <kfree+0x3e>
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d20:	1541                	addi	a0,a0,-16
ffffffffc0201d22:	4581                	li	a1,0
ffffffffc0201d24:	b131                	j	ffffffffc0201930 <slob_free>
ffffffffc0201d26:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201d28:	00005617          	auipc	a2,0x5
ffffffffc0201d2c:	5d060613          	addi	a2,a2,1488 # ffffffffc02072f8 <etext+0xe56>
ffffffffc0201d30:	06900593          	li	a1,105
ffffffffc0201d34:	00005517          	auipc	a0,0x5
ffffffffc0201d38:	51c50513          	addi	a0,a0,1308 # ffffffffc0207250 <etext+0xdae>
ffffffffc0201d3c:	f0efe0ef          	jal	ffffffffc020044a <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201d40:	86aa                	mv	a3,a0
ffffffffc0201d42:	00005617          	auipc	a2,0x5
ffffffffc0201d46:	58e60613          	addi	a2,a2,1422 # ffffffffc02072d0 <etext+0xe2e>
ffffffffc0201d4a:	07700593          	li	a1,119
ffffffffc0201d4e:	00005517          	auipc	a0,0x5
ffffffffc0201d52:	50250513          	addi	a0,a0,1282 # ffffffffc0207250 <etext+0xdae>
ffffffffc0201d56:	ef4fe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201d5a <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc0201d5a:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201d5c:	00005617          	auipc	a2,0x5
ffffffffc0201d60:	59c60613          	addi	a2,a2,1436 # ffffffffc02072f8 <etext+0xe56>
ffffffffc0201d64:	06900593          	li	a1,105
ffffffffc0201d68:	00005517          	auipc	a0,0x5
ffffffffc0201d6c:	4e850513          	addi	a0,a0,1256 # ffffffffc0207250 <etext+0xdae>
pa2page(uintptr_t pa)
ffffffffc0201d70:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201d72:	ed8fe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201d76 <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d76:	100027f3          	csrr	a5,sstatus
ffffffffc0201d7a:	8b89                	andi	a5,a5,2
ffffffffc0201d7c:	e799                	bnez	a5,ffffffffc0201d8a <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201d7e:	000ca797          	auipc	a5,0xca
ffffffffc0201d82:	59a7b783          	ld	a5,1434(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc0201d86:	6f9c                	ld	a5,24(a5)
ffffffffc0201d88:	8782                	jr	a5
{
ffffffffc0201d8a:	1101                	addi	sp,sp,-32
ffffffffc0201d8c:	ec06                	sd	ra,24(sp)
ffffffffc0201d8e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201d90:	b6ffe0ef          	jal	ffffffffc02008fe <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201d94:	000ca797          	auipc	a5,0xca
ffffffffc0201d98:	5847b783          	ld	a5,1412(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc0201d9c:	6522                	ld	a0,8(sp)
ffffffffc0201d9e:	6f9c                	ld	a5,24(a5)
ffffffffc0201da0:	9782                	jalr	a5
ffffffffc0201da2:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201da4:	b55fe0ef          	jal	ffffffffc02008f8 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201da8:	60e2                	ld	ra,24(sp)
ffffffffc0201daa:	6522                	ld	a0,8(sp)
ffffffffc0201dac:	6105                	addi	sp,sp,32
ffffffffc0201dae:	8082                	ret

ffffffffc0201db0 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201db0:	100027f3          	csrr	a5,sstatus
ffffffffc0201db4:	8b89                	andi	a5,a5,2
ffffffffc0201db6:	e799                	bnez	a5,ffffffffc0201dc4 <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201db8:	000ca797          	auipc	a5,0xca
ffffffffc0201dbc:	5607b783          	ld	a5,1376(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc0201dc0:	739c                	ld	a5,32(a5)
ffffffffc0201dc2:	8782                	jr	a5
{
ffffffffc0201dc4:	1101                	addi	sp,sp,-32
ffffffffc0201dc6:	ec06                	sd	ra,24(sp)
ffffffffc0201dc8:	e42e                	sd	a1,8(sp)
ffffffffc0201dca:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0201dcc:	b33fe0ef          	jal	ffffffffc02008fe <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201dd0:	000ca797          	auipc	a5,0xca
ffffffffc0201dd4:	5487b783          	ld	a5,1352(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc0201dd8:	65a2                	ld	a1,8(sp)
ffffffffc0201dda:	6502                	ld	a0,0(sp)
ffffffffc0201ddc:	739c                	ld	a5,32(a5)
ffffffffc0201dde:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201de0:	60e2                	ld	ra,24(sp)
ffffffffc0201de2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201de4:	b15fe06f          	j	ffffffffc02008f8 <intr_enable>

ffffffffc0201de8 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201de8:	100027f3          	csrr	a5,sstatus
ffffffffc0201dec:	8b89                	andi	a5,a5,2
ffffffffc0201dee:	e799                	bnez	a5,ffffffffc0201dfc <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201df0:	000ca797          	auipc	a5,0xca
ffffffffc0201df4:	5287b783          	ld	a5,1320(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc0201df8:	779c                	ld	a5,40(a5)
ffffffffc0201dfa:	8782                	jr	a5
{
ffffffffc0201dfc:	1101                	addi	sp,sp,-32
ffffffffc0201dfe:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201e00:	afffe0ef          	jal	ffffffffc02008fe <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201e04:	000ca797          	auipc	a5,0xca
ffffffffc0201e08:	5147b783          	ld	a5,1300(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc0201e0c:	779c                	ld	a5,40(a5)
ffffffffc0201e0e:	9782                	jalr	a5
ffffffffc0201e10:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201e12:	ae7fe0ef          	jal	ffffffffc02008f8 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201e16:	60e2                	ld	ra,24(sp)
ffffffffc0201e18:	6522                	ld	a0,8(sp)
ffffffffc0201e1a:	6105                	addi	sp,sp,32
ffffffffc0201e1c:	8082                	ret

ffffffffc0201e1e <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201e1e:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201e22:	1ff7f793          	andi	a5,a5,511
ffffffffc0201e26:	078e                	slli	a5,a5,0x3
ffffffffc0201e28:	00f50733          	add	a4,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc0201e2c:	6314                	ld	a3,0(a4)
{
ffffffffc0201e2e:	7139                	addi	sp,sp,-64
ffffffffc0201e30:	f822                	sd	s0,48(sp)
ffffffffc0201e32:	f426                	sd	s1,40(sp)
ffffffffc0201e34:	fc06                	sd	ra,56(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc0201e36:	0016f793          	andi	a5,a3,1
{
ffffffffc0201e3a:	842e                	mv	s0,a1
ffffffffc0201e3c:	8832                	mv	a6,a2
ffffffffc0201e3e:	000ca497          	auipc	s1,0xca
ffffffffc0201e42:	4fa48493          	addi	s1,s1,1274 # ffffffffc02cc338 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc0201e46:	ebd1                	bnez	a5,ffffffffc0201eda <get_pte+0xbc>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201e48:	16060d63          	beqz	a2,ffffffffc0201fc2 <get_pte+0x1a4>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201e4c:	100027f3          	csrr	a5,sstatus
ffffffffc0201e50:	8b89                	andi	a5,a5,2
ffffffffc0201e52:	16079e63          	bnez	a5,ffffffffc0201fce <get_pte+0x1b0>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201e56:	000ca797          	auipc	a5,0xca
ffffffffc0201e5a:	4c27b783          	ld	a5,1218(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc0201e5e:	4505                	li	a0,1
ffffffffc0201e60:	e43a                	sd	a4,8(sp)
ffffffffc0201e62:	6f9c                	ld	a5,24(a5)
ffffffffc0201e64:	e832                	sd	a2,16(sp)
ffffffffc0201e66:	9782                	jalr	a5
ffffffffc0201e68:	6722                	ld	a4,8(sp)
ffffffffc0201e6a:	6842                	ld	a6,16(sp)
ffffffffc0201e6c:	87aa                	mv	a5,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201e6e:	14078a63          	beqz	a5,ffffffffc0201fc2 <get_pte+0x1a4>
    return page - pages + nbase;
ffffffffc0201e72:	000ca517          	auipc	a0,0xca
ffffffffc0201e76:	4ce53503          	ld	a0,1230(a0) # ffffffffc02cc340 <pages>
ffffffffc0201e7a:	000808b7          	lui	a7,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201e7e:	000ca497          	auipc	s1,0xca
ffffffffc0201e82:	4ba48493          	addi	s1,s1,1210 # ffffffffc02cc338 <npage>
ffffffffc0201e86:	40a78533          	sub	a0,a5,a0
ffffffffc0201e8a:	8519                	srai	a0,a0,0x6
ffffffffc0201e8c:	9546                	add	a0,a0,a7
ffffffffc0201e8e:	6090                	ld	a2,0(s1)
ffffffffc0201e90:	00c51693          	slli	a3,a0,0xc
    page->ref = val;
ffffffffc0201e94:	4585                	li	a1,1
ffffffffc0201e96:	82b1                	srli	a3,a3,0xc
ffffffffc0201e98:	c38c                	sw	a1,0(a5)
    return page2ppn(page) << PGSHIFT;
ffffffffc0201e9a:	0532                	slli	a0,a0,0xc
ffffffffc0201e9c:	1ac6f763          	bgeu	a3,a2,ffffffffc020204a <get_pte+0x22c>
ffffffffc0201ea0:	000ca697          	auipc	a3,0xca
ffffffffc0201ea4:	4906b683          	ld	a3,1168(a3) # ffffffffc02cc330 <va_pa_offset>
ffffffffc0201ea8:	6605                	lui	a2,0x1
ffffffffc0201eaa:	4581                	li	a1,0
ffffffffc0201eac:	9536                	add	a0,a0,a3
ffffffffc0201eae:	ec42                	sd	a6,24(sp)
ffffffffc0201eb0:	e83e                	sd	a5,16(sp)
ffffffffc0201eb2:	e43a                	sd	a4,8(sp)
ffffffffc0201eb4:	5c4040ef          	jal	ffffffffc0206478 <memset>
    return page - pages + nbase;
ffffffffc0201eb8:	000ca697          	auipc	a3,0xca
ffffffffc0201ebc:	4886b683          	ld	a3,1160(a3) # ffffffffc02cc340 <pages>
ffffffffc0201ec0:	67c2                	ld	a5,16(sp)
ffffffffc0201ec2:	000808b7          	lui	a7,0x80
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201ec6:	6722                	ld	a4,8(sp)
ffffffffc0201ec8:	40d786b3          	sub	a3,a5,a3
ffffffffc0201ecc:	8699                	srai	a3,a3,0x6
ffffffffc0201ece:	96c6                	add	a3,a3,a7
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201ed0:	06aa                	slli	a3,a3,0xa
ffffffffc0201ed2:	6862                	ld	a6,24(sp)
ffffffffc0201ed4:	0116e693          	ori	a3,a3,17
ffffffffc0201ed8:	e314                	sd	a3,0(a4)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201eda:	c006f693          	andi	a3,a3,-1024
ffffffffc0201ede:	6098                	ld	a4,0(s1)
ffffffffc0201ee0:	068a                	slli	a3,a3,0x2
ffffffffc0201ee2:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201ee6:	14e7f663          	bgeu	a5,a4,ffffffffc0202032 <get_pte+0x214>
ffffffffc0201eea:	000ca897          	auipc	a7,0xca
ffffffffc0201eee:	44688893          	addi	a7,a7,1094 # ffffffffc02cc330 <va_pa_offset>
ffffffffc0201ef2:	0008b603          	ld	a2,0(a7)
ffffffffc0201ef6:	01545793          	srli	a5,s0,0x15
ffffffffc0201efa:	1ff7f793          	andi	a5,a5,511
ffffffffc0201efe:	96b2                	add	a3,a3,a2
ffffffffc0201f00:	078e                	slli	a5,a5,0x3
ffffffffc0201f02:	97b6                	add	a5,a5,a3
    if (!(*pdep0 & PTE_V))
ffffffffc0201f04:	6394                	ld	a3,0(a5)
ffffffffc0201f06:	0016f613          	andi	a2,a3,1
ffffffffc0201f0a:	e659                	bnez	a2,ffffffffc0201f98 <get_pte+0x17a>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201f0c:	0a080b63          	beqz	a6,ffffffffc0201fc2 <get_pte+0x1a4>
ffffffffc0201f10:	10002773          	csrr	a4,sstatus
ffffffffc0201f14:	8b09                	andi	a4,a4,2
ffffffffc0201f16:	ef71                	bnez	a4,ffffffffc0201ff2 <get_pte+0x1d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201f18:	000ca717          	auipc	a4,0xca
ffffffffc0201f1c:	40073703          	ld	a4,1024(a4) # ffffffffc02cc318 <pmm_manager>
ffffffffc0201f20:	4505                	li	a0,1
ffffffffc0201f22:	e43e                	sd	a5,8(sp)
ffffffffc0201f24:	6f18                	ld	a4,24(a4)
ffffffffc0201f26:	9702                	jalr	a4
ffffffffc0201f28:	67a2                	ld	a5,8(sp)
ffffffffc0201f2a:	872a                	mv	a4,a0
ffffffffc0201f2c:	000ca897          	auipc	a7,0xca
ffffffffc0201f30:	40488893          	addi	a7,a7,1028 # ffffffffc02cc330 <va_pa_offset>
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201f34:	c759                	beqz	a4,ffffffffc0201fc2 <get_pte+0x1a4>
    return page - pages + nbase;
ffffffffc0201f36:	000ca697          	auipc	a3,0xca
ffffffffc0201f3a:	40a6b683          	ld	a3,1034(a3) # ffffffffc02cc340 <pages>
ffffffffc0201f3e:	00080837          	lui	a6,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201f42:	608c                	ld	a1,0(s1)
ffffffffc0201f44:	40d706b3          	sub	a3,a4,a3
ffffffffc0201f48:	8699                	srai	a3,a3,0x6
ffffffffc0201f4a:	96c2                	add	a3,a3,a6
ffffffffc0201f4c:	00c69613          	slli	a2,a3,0xc
    page->ref = val;
ffffffffc0201f50:	4505                	li	a0,1
ffffffffc0201f52:	8231                	srli	a2,a2,0xc
ffffffffc0201f54:	c308                	sw	a0,0(a4)
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f56:	06b2                	slli	a3,a3,0xc
ffffffffc0201f58:	10b67663          	bgeu	a2,a1,ffffffffc0202064 <get_pte+0x246>
ffffffffc0201f5c:	0008b503          	ld	a0,0(a7)
ffffffffc0201f60:	6605                	lui	a2,0x1
ffffffffc0201f62:	4581                	li	a1,0
ffffffffc0201f64:	9536                	add	a0,a0,a3
ffffffffc0201f66:	e83a                	sd	a4,16(sp)
ffffffffc0201f68:	e43e                	sd	a5,8(sp)
ffffffffc0201f6a:	50e040ef          	jal	ffffffffc0206478 <memset>
    return page - pages + nbase;
ffffffffc0201f6e:	000ca697          	auipc	a3,0xca
ffffffffc0201f72:	3d26b683          	ld	a3,978(a3) # ffffffffc02cc340 <pages>
ffffffffc0201f76:	6742                	ld	a4,16(sp)
ffffffffc0201f78:	00080837          	lui	a6,0x80
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201f7c:	67a2                	ld	a5,8(sp)
ffffffffc0201f7e:	40d706b3          	sub	a3,a4,a3
ffffffffc0201f82:	8699                	srai	a3,a3,0x6
ffffffffc0201f84:	96c2                	add	a3,a3,a6
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201f86:	06aa                	slli	a3,a3,0xa
ffffffffc0201f88:	0116e693          	ori	a3,a3,17
ffffffffc0201f8c:	e394                	sd	a3,0(a5)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201f8e:	6098                	ld	a4,0(s1)
ffffffffc0201f90:	000ca897          	auipc	a7,0xca
ffffffffc0201f94:	3a088893          	addi	a7,a7,928 # ffffffffc02cc330 <va_pa_offset>
ffffffffc0201f98:	c006f693          	andi	a3,a3,-1024
ffffffffc0201f9c:	068a                	slli	a3,a3,0x2
ffffffffc0201f9e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201fa2:	06e7fc63          	bgeu	a5,a4,ffffffffc020201a <get_pte+0x1fc>
ffffffffc0201fa6:	0008b783          	ld	a5,0(a7)
ffffffffc0201faa:	8031                	srli	s0,s0,0xc
ffffffffc0201fac:	1ff47413          	andi	s0,s0,511
ffffffffc0201fb0:	040e                	slli	s0,s0,0x3
ffffffffc0201fb2:	96be                	add	a3,a3,a5
}
ffffffffc0201fb4:	70e2                	ld	ra,56(sp)
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0201fb6:	00868533          	add	a0,a3,s0
}
ffffffffc0201fba:	7442                	ld	s0,48(sp)
ffffffffc0201fbc:	74a2                	ld	s1,40(sp)
ffffffffc0201fbe:	6121                	addi	sp,sp,64
ffffffffc0201fc0:	8082                	ret
ffffffffc0201fc2:	70e2                	ld	ra,56(sp)
ffffffffc0201fc4:	7442                	ld	s0,48(sp)
ffffffffc0201fc6:	74a2                	ld	s1,40(sp)
            return NULL;
ffffffffc0201fc8:	4501                	li	a0,0
}
ffffffffc0201fca:	6121                	addi	sp,sp,64
ffffffffc0201fcc:	8082                	ret
        intr_disable();
ffffffffc0201fce:	e83a                	sd	a4,16(sp)
ffffffffc0201fd0:	ec32                	sd	a2,24(sp)
ffffffffc0201fd2:	92dfe0ef          	jal	ffffffffc02008fe <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201fd6:	000ca797          	auipc	a5,0xca
ffffffffc0201fda:	3427b783          	ld	a5,834(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc0201fde:	4505                	li	a0,1
ffffffffc0201fe0:	6f9c                	ld	a5,24(a5)
ffffffffc0201fe2:	9782                	jalr	a5
ffffffffc0201fe4:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201fe6:	913fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0201fea:	6862                	ld	a6,24(sp)
ffffffffc0201fec:	6742                	ld	a4,16(sp)
ffffffffc0201fee:	67a2                	ld	a5,8(sp)
ffffffffc0201ff0:	bdbd                	j	ffffffffc0201e6e <get_pte+0x50>
        intr_disable();
ffffffffc0201ff2:	e83e                	sd	a5,16(sp)
ffffffffc0201ff4:	90bfe0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc0201ff8:	000ca717          	auipc	a4,0xca
ffffffffc0201ffc:	32073703          	ld	a4,800(a4) # ffffffffc02cc318 <pmm_manager>
ffffffffc0202000:	4505                	li	a0,1
ffffffffc0202002:	6f18                	ld	a4,24(a4)
ffffffffc0202004:	9702                	jalr	a4
ffffffffc0202006:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0202008:	8f1fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc020200c:	6722                	ld	a4,8(sp)
ffffffffc020200e:	67c2                	ld	a5,16(sp)
ffffffffc0202010:	000ca897          	auipc	a7,0xca
ffffffffc0202014:	32088893          	addi	a7,a7,800 # ffffffffc02cc330 <va_pa_offset>
ffffffffc0202018:	bf31                	j	ffffffffc0201f34 <get_pte+0x116>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020201a:	00005617          	auipc	a2,0x5
ffffffffc020201e:	20e60613          	addi	a2,a2,526 # ffffffffc0207228 <etext+0xd86>
ffffffffc0202022:	0f900593          	li	a1,249
ffffffffc0202026:	00005517          	auipc	a0,0x5
ffffffffc020202a:	2f250513          	addi	a0,a0,754 # ffffffffc0207318 <etext+0xe76>
ffffffffc020202e:	c1cfe0ef          	jal	ffffffffc020044a <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202032:	00005617          	auipc	a2,0x5
ffffffffc0202036:	1f660613          	addi	a2,a2,502 # ffffffffc0207228 <etext+0xd86>
ffffffffc020203a:	0ec00593          	li	a1,236
ffffffffc020203e:	00005517          	auipc	a0,0x5
ffffffffc0202042:	2da50513          	addi	a0,a0,730 # ffffffffc0207318 <etext+0xe76>
ffffffffc0202046:	c04fe0ef          	jal	ffffffffc020044a <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020204a:	86aa                	mv	a3,a0
ffffffffc020204c:	00005617          	auipc	a2,0x5
ffffffffc0202050:	1dc60613          	addi	a2,a2,476 # ffffffffc0207228 <etext+0xd86>
ffffffffc0202054:	0e800593          	li	a1,232
ffffffffc0202058:	00005517          	auipc	a0,0x5
ffffffffc020205c:	2c050513          	addi	a0,a0,704 # ffffffffc0207318 <etext+0xe76>
ffffffffc0202060:	beafe0ef          	jal	ffffffffc020044a <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202064:	00005617          	auipc	a2,0x5
ffffffffc0202068:	1c460613          	addi	a2,a2,452 # ffffffffc0207228 <etext+0xd86>
ffffffffc020206c:	0f600593          	li	a1,246
ffffffffc0202070:	00005517          	auipc	a0,0x5
ffffffffc0202074:	2a850513          	addi	a0,a0,680 # ffffffffc0207318 <etext+0xe76>
ffffffffc0202078:	bd2fe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020207c <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc020207c:	1141                	addi	sp,sp,-16
ffffffffc020207e:	e022                	sd	s0,0(sp)
ffffffffc0202080:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202082:	4601                	li	a2,0
{
ffffffffc0202084:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202086:	d99ff0ef          	jal	ffffffffc0201e1e <get_pte>
    if (ptep_store != NULL)
ffffffffc020208a:	c011                	beqz	s0,ffffffffc020208e <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc020208c:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc020208e:	c511                	beqz	a0,ffffffffc020209a <get_page+0x1e>
ffffffffc0202090:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202092:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202094:	0017f713          	andi	a4,a5,1
ffffffffc0202098:	e709                	bnez	a4,ffffffffc02020a2 <get_page+0x26>
}
ffffffffc020209a:	60a2                	ld	ra,8(sp)
ffffffffc020209c:	6402                	ld	s0,0(sp)
ffffffffc020209e:	0141                	addi	sp,sp,16
ffffffffc02020a0:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc02020a2:	000ca717          	auipc	a4,0xca
ffffffffc02020a6:	29673703          	ld	a4,662(a4) # ffffffffc02cc338 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc02020aa:	078a                	slli	a5,a5,0x2
ffffffffc02020ac:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02020ae:	00e7ff63          	bgeu	a5,a4,ffffffffc02020cc <get_page+0x50>
    return &pages[PPN(pa) - nbase];
ffffffffc02020b2:	000ca517          	auipc	a0,0xca
ffffffffc02020b6:	28e53503          	ld	a0,654(a0) # ffffffffc02cc340 <pages>
ffffffffc02020ba:	60a2                	ld	ra,8(sp)
ffffffffc02020bc:	6402                	ld	s0,0(sp)
ffffffffc02020be:	079a                	slli	a5,a5,0x6
ffffffffc02020c0:	fe000737          	lui	a4,0xfe000
ffffffffc02020c4:	97ba                	add	a5,a5,a4
ffffffffc02020c6:	953e                	add	a0,a0,a5
ffffffffc02020c8:	0141                	addi	sp,sp,16
ffffffffc02020ca:	8082                	ret
ffffffffc02020cc:	c8fff0ef          	jal	ffffffffc0201d5a <pa2page.part.0>

ffffffffc02020d0 <unmap_range>:
        tlb_invalidate(pgdir, la); //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc02020d0:	715d                	addi	sp,sp,-80
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02020d2:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc02020d6:	e486                	sd	ra,72(sp)
ffffffffc02020d8:	e0a2                	sd	s0,64(sp)
ffffffffc02020da:	fc26                	sd	s1,56(sp)
ffffffffc02020dc:	f84a                	sd	s2,48(sp)
ffffffffc02020de:	f44e                	sd	s3,40(sp)
ffffffffc02020e0:	f052                	sd	s4,32(sp)
ffffffffc02020e2:	ec56                	sd	s5,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02020e4:	03479713          	slli	a4,a5,0x34
ffffffffc02020e8:	ef61                	bnez	a4,ffffffffc02021c0 <unmap_range+0xf0>
    assert(USER_ACCESS(start, end));
ffffffffc02020ea:	00200a37          	lui	s4,0x200
ffffffffc02020ee:	00c5b7b3          	sltu	a5,a1,a2
ffffffffc02020f2:	0145b733          	sltu	a4,a1,s4
ffffffffc02020f6:	0017b793          	seqz	a5,a5
ffffffffc02020fa:	8fd9                	or	a5,a5,a4
ffffffffc02020fc:	842e                	mv	s0,a1
ffffffffc02020fe:	84b2                	mv	s1,a2
ffffffffc0202100:	e3e5                	bnez	a5,ffffffffc02021e0 <unmap_range+0x110>
ffffffffc0202102:	4785                	li	a5,1
ffffffffc0202104:	07fe                	slli	a5,a5,0x1f
ffffffffc0202106:	0785                	addi	a5,a5,1
ffffffffc0202108:	892a                	mv	s2,a0
ffffffffc020210a:	6985                	lui	s3,0x1
    do
    {
        pte_t *ptep = get_pte(pgdir, start, 0);
        if (ptep == NULL)
        {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020210c:	ffe00ab7          	lui	s5,0xffe00
    assert(USER_ACCESS(start, end));
ffffffffc0202110:	0cf67863          	bgeu	a2,a5,ffffffffc02021e0 <unmap_range+0x110>
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0202114:	4601                	li	a2,0
ffffffffc0202116:	85a2                	mv	a1,s0
ffffffffc0202118:	854a                	mv	a0,s2
ffffffffc020211a:	d05ff0ef          	jal	ffffffffc0201e1e <get_pte>
ffffffffc020211e:	87aa                	mv	a5,a0
        if (ptep == NULL)
ffffffffc0202120:	cd31                	beqz	a0,ffffffffc020217c <unmap_range+0xac>
            continue;
        }
        if (*ptep != 0)
ffffffffc0202122:	6118                	ld	a4,0(a0)
ffffffffc0202124:	ef11                	bnez	a4,ffffffffc0202140 <unmap_range+0x70>
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0202126:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc0202128:	c019                	beqz	s0,ffffffffc020212e <unmap_range+0x5e>
ffffffffc020212a:	fe9465e3          	bltu	s0,s1,ffffffffc0202114 <unmap_range+0x44>
}
ffffffffc020212e:	60a6                	ld	ra,72(sp)
ffffffffc0202130:	6406                	ld	s0,64(sp)
ffffffffc0202132:	74e2                	ld	s1,56(sp)
ffffffffc0202134:	7942                	ld	s2,48(sp)
ffffffffc0202136:	79a2                	ld	s3,40(sp)
ffffffffc0202138:	7a02                	ld	s4,32(sp)
ffffffffc020213a:	6ae2                	ld	s5,24(sp)
ffffffffc020213c:	6161                	addi	sp,sp,80
ffffffffc020213e:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc0202140:	00177693          	andi	a3,a4,1
ffffffffc0202144:	d2ed                	beqz	a3,ffffffffc0202126 <unmap_range+0x56>
    if (PPN(pa) >= npage)
ffffffffc0202146:	000ca697          	auipc	a3,0xca
ffffffffc020214a:	1f26b683          	ld	a3,498(a3) # ffffffffc02cc338 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc020214e:	070a                	slli	a4,a4,0x2
ffffffffc0202150:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc0202152:	0ad77763          	bgeu	a4,a3,ffffffffc0202200 <unmap_range+0x130>
    return &pages[PPN(pa) - nbase];
ffffffffc0202156:	000ca517          	auipc	a0,0xca
ffffffffc020215a:	1ea53503          	ld	a0,490(a0) # ffffffffc02cc340 <pages>
ffffffffc020215e:	071a                	slli	a4,a4,0x6
ffffffffc0202160:	fe0006b7          	lui	a3,0xfe000
ffffffffc0202164:	9736                	add	a4,a4,a3
ffffffffc0202166:	953a                	add	a0,a0,a4
    page->ref -= 1;
ffffffffc0202168:	4118                	lw	a4,0(a0)
ffffffffc020216a:	377d                	addiw	a4,a4,-1 # fffffffffdffffff <end+0x3dd33c87>
ffffffffc020216c:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020216e:	cb19                	beqz	a4,ffffffffc0202184 <unmap_range+0xb4>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc0202170:	0007b023          	sd	zero,0(a5)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202174:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0202178:	944e                	add	s0,s0,s3
ffffffffc020217a:	b77d                	j	ffffffffc0202128 <unmap_range+0x58>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020217c:	9452                	add	s0,s0,s4
ffffffffc020217e:	01547433          	and	s0,s0,s5
            continue;
ffffffffc0202182:	b75d                	j	ffffffffc0202128 <unmap_range+0x58>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202184:	10002773          	csrr	a4,sstatus
ffffffffc0202188:	8b09                	andi	a4,a4,2
ffffffffc020218a:	eb19                	bnez	a4,ffffffffc02021a0 <unmap_range+0xd0>
        pmm_manager->free_pages(base, n);
ffffffffc020218c:	000ca717          	auipc	a4,0xca
ffffffffc0202190:	18c73703          	ld	a4,396(a4) # ffffffffc02cc318 <pmm_manager>
ffffffffc0202194:	4585                	li	a1,1
ffffffffc0202196:	e03e                	sd	a5,0(sp)
ffffffffc0202198:	7318                	ld	a4,32(a4)
ffffffffc020219a:	9702                	jalr	a4
    if (flag) {
ffffffffc020219c:	6782                	ld	a5,0(sp)
ffffffffc020219e:	bfc9                	j	ffffffffc0202170 <unmap_range+0xa0>
        intr_disable();
ffffffffc02021a0:	e43e                	sd	a5,8(sp)
ffffffffc02021a2:	e02a                	sd	a0,0(sp)
ffffffffc02021a4:	f5afe0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc02021a8:	000ca717          	auipc	a4,0xca
ffffffffc02021ac:	17073703          	ld	a4,368(a4) # ffffffffc02cc318 <pmm_manager>
ffffffffc02021b0:	6502                	ld	a0,0(sp)
ffffffffc02021b2:	4585                	li	a1,1
ffffffffc02021b4:	7318                	ld	a4,32(a4)
ffffffffc02021b6:	9702                	jalr	a4
        intr_enable();
ffffffffc02021b8:	f40fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc02021bc:	67a2                	ld	a5,8(sp)
ffffffffc02021be:	bf4d                	j	ffffffffc0202170 <unmap_range+0xa0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02021c0:	00005697          	auipc	a3,0x5
ffffffffc02021c4:	16868693          	addi	a3,a3,360 # ffffffffc0207328 <etext+0xe86>
ffffffffc02021c8:	00005617          	auipc	a2,0x5
ffffffffc02021cc:	cb060613          	addi	a2,a2,-848 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02021d0:	12100593          	li	a1,289
ffffffffc02021d4:	00005517          	auipc	a0,0x5
ffffffffc02021d8:	14450513          	addi	a0,a0,324 # ffffffffc0207318 <etext+0xe76>
ffffffffc02021dc:	a6efe0ef          	jal	ffffffffc020044a <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02021e0:	00005697          	auipc	a3,0x5
ffffffffc02021e4:	17868693          	addi	a3,a3,376 # ffffffffc0207358 <etext+0xeb6>
ffffffffc02021e8:	00005617          	auipc	a2,0x5
ffffffffc02021ec:	c9060613          	addi	a2,a2,-880 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02021f0:	12200593          	li	a1,290
ffffffffc02021f4:	00005517          	auipc	a0,0x5
ffffffffc02021f8:	12450513          	addi	a0,a0,292 # ffffffffc0207318 <etext+0xe76>
ffffffffc02021fc:	a4efe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0202200:	b5bff0ef          	jal	ffffffffc0201d5a <pa2page.part.0>

ffffffffc0202204 <exit_range>:
{
ffffffffc0202204:	7135                	addi	sp,sp,-160
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202206:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc020220a:	ed06                	sd	ra,152(sp)
ffffffffc020220c:	e922                	sd	s0,144(sp)
ffffffffc020220e:	e526                	sd	s1,136(sp)
ffffffffc0202210:	e14a                	sd	s2,128(sp)
ffffffffc0202212:	fcce                	sd	s3,120(sp)
ffffffffc0202214:	f8d2                	sd	s4,112(sp)
ffffffffc0202216:	f4d6                	sd	s5,104(sp)
ffffffffc0202218:	f0da                	sd	s6,96(sp)
ffffffffc020221a:	ecde                	sd	s7,88(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020221c:	17d2                	slli	a5,a5,0x34
ffffffffc020221e:	22079263          	bnez	a5,ffffffffc0202442 <exit_range+0x23e>
    assert(USER_ACCESS(start, end));
ffffffffc0202222:	00200937          	lui	s2,0x200
ffffffffc0202226:	00c5b7b3          	sltu	a5,a1,a2
ffffffffc020222a:	0125b733          	sltu	a4,a1,s2
ffffffffc020222e:	0017b793          	seqz	a5,a5
ffffffffc0202232:	8fd9                	or	a5,a5,a4
ffffffffc0202234:	26079263          	bnez	a5,ffffffffc0202498 <exit_range+0x294>
ffffffffc0202238:	4785                	li	a5,1
ffffffffc020223a:	07fe                	slli	a5,a5,0x1f
ffffffffc020223c:	0785                	addi	a5,a5,1
ffffffffc020223e:	24f67d63          	bgeu	a2,a5,ffffffffc0202498 <exit_range+0x294>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0202242:	c00004b7          	lui	s1,0xc0000
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202246:	ffe007b7          	lui	a5,0xffe00
ffffffffc020224a:	8a2a                	mv	s4,a0
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc020224c:	8ced                	and	s1,s1,a1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020224e:	00f5f833          	and	a6,a1,a5
    if (PPN(pa) >= npage)
ffffffffc0202252:	000caa97          	auipc	s5,0xca
ffffffffc0202256:	0e6a8a93          	addi	s5,s5,230 # ffffffffc02cc338 <npage>
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc020225a:	400009b7          	lui	s3,0x40000
ffffffffc020225e:	a809                	j	ffffffffc0202270 <exit_range+0x6c>
        d1start += PDSIZE;
ffffffffc0202260:	013487b3          	add	a5,s1,s3
ffffffffc0202264:	400004b7          	lui	s1,0x40000
        d0start = d1start;
ffffffffc0202268:	8826                	mv	a6,s1
    } while (d1start != 0 && d1start < end);
ffffffffc020226a:	c3f1                	beqz	a5,ffffffffc020232e <exit_range+0x12a>
ffffffffc020226c:	0cc7f163          	bgeu	a5,a2,ffffffffc020232e <exit_range+0x12a>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc0202270:	01e4d413          	srli	s0,s1,0x1e
ffffffffc0202274:	1ff47413          	andi	s0,s0,511
ffffffffc0202278:	040e                	slli	s0,s0,0x3
ffffffffc020227a:	9452                	add	s0,s0,s4
ffffffffc020227c:	00043883          	ld	a7,0(s0)
        if (pde1 & PTE_V)
ffffffffc0202280:	0018f793          	andi	a5,a7,1
ffffffffc0202284:	dff1                	beqz	a5,ffffffffc0202260 <exit_range+0x5c>
ffffffffc0202286:	000ab783          	ld	a5,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020228a:	088a                	slli	a7,a7,0x2
ffffffffc020228c:	00c8d893          	srli	a7,a7,0xc
    if (PPN(pa) >= npage)
ffffffffc0202290:	20f8f263          	bgeu	a7,a5,ffffffffc0202494 <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc0202294:	fff802b7          	lui	t0,0xfff80
ffffffffc0202298:	00588f33          	add	t5,a7,t0
    return page - pages + nbase;
ffffffffc020229c:	000803b7          	lui	t2,0x80
ffffffffc02022a0:	007f0733          	add	a4,t5,t2
    return page2ppn(page) << PGSHIFT;
ffffffffc02022a4:	00c71e13          	slli	t3,a4,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc02022a8:	0f1a                	slli	t5,t5,0x6
    return KADDR(page2pa(page));
ffffffffc02022aa:	1cf77863          	bgeu	a4,a5,ffffffffc020247a <exit_range+0x276>
ffffffffc02022ae:	000caf97          	auipc	t6,0xca
ffffffffc02022b2:	082f8f93          	addi	t6,t6,130 # ffffffffc02cc330 <va_pa_offset>
ffffffffc02022b6:	000fb783          	ld	a5,0(t6)
            free_pd0 = 1;
ffffffffc02022ba:	4e85                	li	t4,1
ffffffffc02022bc:	6b05                	lui	s6,0x1
ffffffffc02022be:	9e3e                	add	t3,t3,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc02022c0:	01348333          	add	t1,s1,s3
                pde0 = pd0[PDX0(d0start)];
ffffffffc02022c4:	01585713          	srli	a4,a6,0x15
ffffffffc02022c8:	1ff77713          	andi	a4,a4,511
ffffffffc02022cc:	070e                	slli	a4,a4,0x3
ffffffffc02022ce:	9772                	add	a4,a4,t3
ffffffffc02022d0:	631c                	ld	a5,0(a4)
                if (pde0 & PTE_V)
ffffffffc02022d2:	0017f693          	andi	a3,a5,1
ffffffffc02022d6:	e6bd                	bnez	a3,ffffffffc0202344 <exit_range+0x140>
                    free_pd0 = 0;
ffffffffc02022d8:	4e81                	li	t4,0
                d0start += PTSIZE;
ffffffffc02022da:	984a                	add	a6,a6,s2
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc02022dc:	00080863          	beqz	a6,ffffffffc02022ec <exit_range+0xe8>
ffffffffc02022e0:	879a                	mv	a5,t1
ffffffffc02022e2:	00667363          	bgeu	a2,t1,ffffffffc02022e8 <exit_range+0xe4>
ffffffffc02022e6:	87b2                	mv	a5,a2
ffffffffc02022e8:	fcf86ee3          	bltu	a6,a5,ffffffffc02022c4 <exit_range+0xc0>
            if (free_pd0)
ffffffffc02022ec:	f60e8ae3          	beqz	t4,ffffffffc0202260 <exit_range+0x5c>
    if (PPN(pa) >= npage)
ffffffffc02022f0:	000ab783          	ld	a5,0(s5)
ffffffffc02022f4:	1af8f063          	bgeu	a7,a5,ffffffffc0202494 <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc02022f8:	000ca517          	auipc	a0,0xca
ffffffffc02022fc:	04853503          	ld	a0,72(a0) # ffffffffc02cc340 <pages>
ffffffffc0202300:	957a                	add	a0,a0,t5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202302:	100027f3          	csrr	a5,sstatus
ffffffffc0202306:	8b89                	andi	a5,a5,2
ffffffffc0202308:	10079b63          	bnez	a5,ffffffffc020241e <exit_range+0x21a>
        pmm_manager->free_pages(base, n);
ffffffffc020230c:	000ca797          	auipc	a5,0xca
ffffffffc0202310:	00c7b783          	ld	a5,12(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc0202314:	4585                	li	a1,1
ffffffffc0202316:	e432                	sd	a2,8(sp)
ffffffffc0202318:	739c                	ld	a5,32(a5)
ffffffffc020231a:	9782                	jalr	a5
ffffffffc020231c:	6622                	ld	a2,8(sp)
                pgdir[PDX1(d1start)] = 0;
ffffffffc020231e:	00043023          	sd	zero,0(s0)
        d1start += PDSIZE;
ffffffffc0202322:	013487b3          	add	a5,s1,s3
ffffffffc0202326:	400004b7          	lui	s1,0x40000
        d0start = d1start;
ffffffffc020232a:	8826                	mv	a6,s1
    } while (d1start != 0 && d1start < end);
ffffffffc020232c:	f3a1                	bnez	a5,ffffffffc020226c <exit_range+0x68>
}
ffffffffc020232e:	60ea                	ld	ra,152(sp)
ffffffffc0202330:	644a                	ld	s0,144(sp)
ffffffffc0202332:	64aa                	ld	s1,136(sp)
ffffffffc0202334:	690a                	ld	s2,128(sp)
ffffffffc0202336:	79e6                	ld	s3,120(sp)
ffffffffc0202338:	7a46                	ld	s4,112(sp)
ffffffffc020233a:	7aa6                	ld	s5,104(sp)
ffffffffc020233c:	7b06                	ld	s6,96(sp)
ffffffffc020233e:	6be6                	ld	s7,88(sp)
ffffffffc0202340:	610d                	addi	sp,sp,160
ffffffffc0202342:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc0202344:	000ab503          	ld	a0,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202348:	078a                	slli	a5,a5,0x2
ffffffffc020234a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020234c:	14a7f463          	bgeu	a5,a0,ffffffffc0202494 <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc0202350:	9796                	add	a5,a5,t0
    return page - pages + nbase;
ffffffffc0202352:	00778bb3          	add	s7,a5,t2
    return &pages[PPN(pa) - nbase];
ffffffffc0202356:	00679593          	slli	a1,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc020235a:	00cb9693          	slli	a3,s7,0xc
    return KADDR(page2pa(page));
ffffffffc020235e:	10abf263          	bgeu	s7,a0,ffffffffc0202462 <exit_range+0x25e>
ffffffffc0202362:	000fb783          	ld	a5,0(t6)
ffffffffc0202366:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc0202368:	01668533          	add	a0,a3,s6
                        if (pt[i] & PTE_V)
ffffffffc020236c:	629c                	ld	a5,0(a3)
ffffffffc020236e:	8b85                	andi	a5,a5,1
ffffffffc0202370:	f7ad                	bnez	a5,ffffffffc02022da <exit_range+0xd6>
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc0202372:	06a1                	addi	a3,a3,8
ffffffffc0202374:	fea69ce3          	bne	a3,a0,ffffffffc020236c <exit_range+0x168>
    return &pages[PPN(pa) - nbase];
ffffffffc0202378:	000ca517          	auipc	a0,0xca
ffffffffc020237c:	fc853503          	ld	a0,-56(a0) # ffffffffc02cc340 <pages>
ffffffffc0202380:	952e                	add	a0,a0,a1
ffffffffc0202382:	100027f3          	csrr	a5,sstatus
ffffffffc0202386:	8b89                	andi	a5,a5,2
ffffffffc0202388:	e3b9                	bnez	a5,ffffffffc02023ce <exit_range+0x1ca>
        pmm_manager->free_pages(base, n);
ffffffffc020238a:	000ca797          	auipc	a5,0xca
ffffffffc020238e:	f8e7b783          	ld	a5,-114(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc0202392:	4585                	li	a1,1
ffffffffc0202394:	e0b2                	sd	a2,64(sp)
ffffffffc0202396:	739c                	ld	a5,32(a5)
ffffffffc0202398:	fc1a                	sd	t1,56(sp)
ffffffffc020239a:	f846                	sd	a7,48(sp)
ffffffffc020239c:	f47a                	sd	t5,40(sp)
ffffffffc020239e:	f072                	sd	t3,32(sp)
ffffffffc02023a0:	ec76                	sd	t4,24(sp)
ffffffffc02023a2:	e842                	sd	a6,16(sp)
ffffffffc02023a4:	e43a                	sd	a4,8(sp)
ffffffffc02023a6:	9782                	jalr	a5
    if (flag) {
ffffffffc02023a8:	6722                	ld	a4,8(sp)
ffffffffc02023aa:	6842                	ld	a6,16(sp)
ffffffffc02023ac:	6ee2                	ld	t4,24(sp)
ffffffffc02023ae:	7e02                	ld	t3,32(sp)
ffffffffc02023b0:	7f22                	ld	t5,40(sp)
ffffffffc02023b2:	78c2                	ld	a7,48(sp)
ffffffffc02023b4:	7362                	ld	t1,56(sp)
ffffffffc02023b6:	6606                	ld	a2,64(sp)
                        pd0[PDX0(d0start)] = 0;
ffffffffc02023b8:	fff802b7          	lui	t0,0xfff80
ffffffffc02023bc:	000803b7          	lui	t2,0x80
ffffffffc02023c0:	000caf97          	auipc	t6,0xca
ffffffffc02023c4:	f70f8f93          	addi	t6,t6,-144 # ffffffffc02cc330 <va_pa_offset>
ffffffffc02023c8:	00073023          	sd	zero,0(a4)
ffffffffc02023cc:	b739                	j	ffffffffc02022da <exit_range+0xd6>
        intr_disable();
ffffffffc02023ce:	e4b2                	sd	a2,72(sp)
ffffffffc02023d0:	e09a                	sd	t1,64(sp)
ffffffffc02023d2:	fc46                	sd	a7,56(sp)
ffffffffc02023d4:	f47a                	sd	t5,40(sp)
ffffffffc02023d6:	f072                	sd	t3,32(sp)
ffffffffc02023d8:	ec76                	sd	t4,24(sp)
ffffffffc02023da:	e842                	sd	a6,16(sp)
ffffffffc02023dc:	e43a                	sd	a4,8(sp)
ffffffffc02023de:	f82a                	sd	a0,48(sp)
ffffffffc02023e0:	d1efe0ef          	jal	ffffffffc02008fe <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02023e4:	000ca797          	auipc	a5,0xca
ffffffffc02023e8:	f347b783          	ld	a5,-204(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc02023ec:	7542                	ld	a0,48(sp)
ffffffffc02023ee:	4585                	li	a1,1
ffffffffc02023f0:	739c                	ld	a5,32(a5)
ffffffffc02023f2:	9782                	jalr	a5
        intr_enable();
ffffffffc02023f4:	d04fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc02023f8:	6722                	ld	a4,8(sp)
ffffffffc02023fa:	6626                	ld	a2,72(sp)
ffffffffc02023fc:	6306                	ld	t1,64(sp)
ffffffffc02023fe:	78e2                	ld	a7,56(sp)
ffffffffc0202400:	7f22                	ld	t5,40(sp)
ffffffffc0202402:	7e02                	ld	t3,32(sp)
ffffffffc0202404:	6ee2                	ld	t4,24(sp)
ffffffffc0202406:	6842                	ld	a6,16(sp)
ffffffffc0202408:	000caf97          	auipc	t6,0xca
ffffffffc020240c:	f28f8f93          	addi	t6,t6,-216 # ffffffffc02cc330 <va_pa_offset>
ffffffffc0202410:	000803b7          	lui	t2,0x80
ffffffffc0202414:	fff802b7          	lui	t0,0xfff80
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202418:	00073023          	sd	zero,0(a4)
ffffffffc020241c:	bd7d                	j	ffffffffc02022da <exit_range+0xd6>
        intr_disable();
ffffffffc020241e:	e832                	sd	a2,16(sp)
ffffffffc0202420:	e42a                	sd	a0,8(sp)
ffffffffc0202422:	cdcfe0ef          	jal	ffffffffc02008fe <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202426:	000ca797          	auipc	a5,0xca
ffffffffc020242a:	ef27b783          	ld	a5,-270(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc020242e:	6522                	ld	a0,8(sp)
ffffffffc0202430:	4585                	li	a1,1
ffffffffc0202432:	739c                	ld	a5,32(a5)
ffffffffc0202434:	9782                	jalr	a5
        intr_enable();
ffffffffc0202436:	cc2fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc020243a:	6642                	ld	a2,16(sp)
                pgdir[PDX1(d1start)] = 0;
ffffffffc020243c:	00043023          	sd	zero,0(s0)
ffffffffc0202440:	b5cd                	j	ffffffffc0202322 <exit_range+0x11e>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202442:	00005697          	auipc	a3,0x5
ffffffffc0202446:	ee668693          	addi	a3,a3,-282 # ffffffffc0207328 <etext+0xe86>
ffffffffc020244a:	00005617          	auipc	a2,0x5
ffffffffc020244e:	a2e60613          	addi	a2,a2,-1490 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0202452:	13600593          	li	a1,310
ffffffffc0202456:	00005517          	auipc	a0,0x5
ffffffffc020245a:	ec250513          	addi	a0,a0,-318 # ffffffffc0207318 <etext+0xe76>
ffffffffc020245e:	fedfd0ef          	jal	ffffffffc020044a <__panic>
    return KADDR(page2pa(page));
ffffffffc0202462:	00005617          	auipc	a2,0x5
ffffffffc0202466:	dc660613          	addi	a2,a2,-570 # ffffffffc0207228 <etext+0xd86>
ffffffffc020246a:	07100593          	li	a1,113
ffffffffc020246e:	00005517          	auipc	a0,0x5
ffffffffc0202472:	de250513          	addi	a0,a0,-542 # ffffffffc0207250 <etext+0xdae>
ffffffffc0202476:	fd5fd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc020247a:	86f2                	mv	a3,t3
ffffffffc020247c:	00005617          	auipc	a2,0x5
ffffffffc0202480:	dac60613          	addi	a2,a2,-596 # ffffffffc0207228 <etext+0xd86>
ffffffffc0202484:	07100593          	li	a1,113
ffffffffc0202488:	00005517          	auipc	a0,0x5
ffffffffc020248c:	dc850513          	addi	a0,a0,-568 # ffffffffc0207250 <etext+0xdae>
ffffffffc0202490:	fbbfd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0202494:	8c7ff0ef          	jal	ffffffffc0201d5a <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0202498:	00005697          	auipc	a3,0x5
ffffffffc020249c:	ec068693          	addi	a3,a3,-320 # ffffffffc0207358 <etext+0xeb6>
ffffffffc02024a0:	00005617          	auipc	a2,0x5
ffffffffc02024a4:	9d860613          	addi	a2,a2,-1576 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02024a8:	13700593          	li	a1,311
ffffffffc02024ac:	00005517          	auipc	a0,0x5
ffffffffc02024b0:	e6c50513          	addi	a0,a0,-404 # ffffffffc0207318 <etext+0xe76>
ffffffffc02024b4:	f97fd0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02024b8 <copy_range>:
{
ffffffffc02024b8:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02024ba:	00d667b3          	or	a5,a2,a3
{
ffffffffc02024be:	f486                	sd	ra,104(sp)
ffffffffc02024c0:	f0a2                	sd	s0,96(sp)
ffffffffc02024c2:	eca6                	sd	s1,88(sp)
ffffffffc02024c4:	e8ca                	sd	s2,80(sp)
ffffffffc02024c6:	e4ce                	sd	s3,72(sp)
ffffffffc02024c8:	e0d2                	sd	s4,64(sp)
ffffffffc02024ca:	fc56                	sd	s5,56(sp)
ffffffffc02024cc:	f85a                	sd	s6,48(sp)
ffffffffc02024ce:	f45e                	sd	s7,40(sp)
ffffffffc02024d0:	f062                	sd	s8,32(sp)
ffffffffc02024d2:	ec66                	sd	s9,24(sp)
ffffffffc02024d4:	e86a                	sd	s10,16(sp)
ffffffffc02024d6:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02024d8:	03479713          	slli	a4,a5,0x34
ffffffffc02024dc:	18071163          	bnez	a4,ffffffffc020265e <copy_range+0x1a6>
    assert(USER_ACCESS(start, end));
ffffffffc02024e0:	00200cb7          	lui	s9,0x200
ffffffffc02024e4:	00d637b3          	sltu	a5,a2,a3
ffffffffc02024e8:	01963733          	sltu	a4,a2,s9
ffffffffc02024ec:	0017b793          	seqz	a5,a5
ffffffffc02024f0:	8fd9                	or	a5,a5,a4
ffffffffc02024f2:	8432                	mv	s0,a2
ffffffffc02024f4:	84b6                	mv	s1,a3
ffffffffc02024f6:	14079463          	bnez	a5,ffffffffc020263e <copy_range+0x186>
ffffffffc02024fa:	4785                	li	a5,1
ffffffffc02024fc:	07fe                	slli	a5,a5,0x1f
ffffffffc02024fe:	0785                	addi	a5,a5,1
ffffffffc0202500:	12f6ff63          	bgeu	a3,a5,ffffffffc020263e <copy_range+0x186>
ffffffffc0202504:	8aaa                	mv	s5,a0
ffffffffc0202506:	892e                	mv	s2,a1
ffffffffc0202508:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage)
ffffffffc020250a:	000cac17          	auipc	s8,0xca
ffffffffc020250e:	e2ec0c13          	addi	s8,s8,-466 # ffffffffc02cc338 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202512:	000cab97          	auipc	s7,0xca
ffffffffc0202516:	e2eb8b93          	addi	s7,s7,-466 # ffffffffc02cc340 <pages>
ffffffffc020251a:	fff80b37          	lui	s6,0xfff80
        page = pmm_manager->alloc_pages(n);
ffffffffc020251e:	000caa17          	auipc	s4,0xca
ffffffffc0202522:	dfaa0a13          	addi	s4,s4,-518 # ffffffffc02cc318 <pmm_manager>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0202526:	4601                	li	a2,0
ffffffffc0202528:	85a2                	mv	a1,s0
ffffffffc020252a:	854a                	mv	a0,s2
ffffffffc020252c:	8f3ff0ef          	jal	ffffffffc0201e1e <get_pte>
ffffffffc0202530:	8d2a                	mv	s10,a0
        if (ptep == NULL)
ffffffffc0202532:	cd41                	beqz	a0,ffffffffc02025ca <copy_range+0x112>
        if (*ptep & PTE_V)
ffffffffc0202534:	611c                	ld	a5,0(a0)
ffffffffc0202536:	8b85                	andi	a5,a5,1
ffffffffc0202538:	e78d                	bnez	a5,ffffffffc0202562 <copy_range+0xaa>
        start += PGSIZE;
ffffffffc020253a:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc020253c:	c019                	beqz	s0,ffffffffc0202542 <copy_range+0x8a>
ffffffffc020253e:	fe9464e3          	bltu	s0,s1,ffffffffc0202526 <copy_range+0x6e>
    return 0;
ffffffffc0202542:	4501                	li	a0,0
}
ffffffffc0202544:	70a6                	ld	ra,104(sp)
ffffffffc0202546:	7406                	ld	s0,96(sp)
ffffffffc0202548:	64e6                	ld	s1,88(sp)
ffffffffc020254a:	6946                	ld	s2,80(sp)
ffffffffc020254c:	69a6                	ld	s3,72(sp)
ffffffffc020254e:	6a06                	ld	s4,64(sp)
ffffffffc0202550:	7ae2                	ld	s5,56(sp)
ffffffffc0202552:	7b42                	ld	s6,48(sp)
ffffffffc0202554:	7ba2                	ld	s7,40(sp)
ffffffffc0202556:	7c02                	ld	s8,32(sp)
ffffffffc0202558:	6ce2                	ld	s9,24(sp)
ffffffffc020255a:	6d42                	ld	s10,16(sp)
ffffffffc020255c:	6da2                	ld	s11,8(sp)
ffffffffc020255e:	6165                	addi	sp,sp,112
ffffffffc0202560:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc0202562:	4605                	li	a2,1
ffffffffc0202564:	85a2                	mv	a1,s0
ffffffffc0202566:	8556                	mv	a0,s5
ffffffffc0202568:	8b7ff0ef          	jal	ffffffffc0201e1e <get_pte>
ffffffffc020256c:	cd3d                	beqz	a0,ffffffffc02025ea <copy_range+0x132>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc020256e:	000d3783          	ld	a5,0(s10)
    if (!(pte & PTE_V))
ffffffffc0202572:	0017f713          	andi	a4,a5,1
ffffffffc0202576:	cf25                	beqz	a4,ffffffffc02025ee <copy_range+0x136>
    if (PPN(pa) >= npage)
ffffffffc0202578:	000c3703          	ld	a4,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc020257c:	078a                	slli	a5,a5,0x2
ffffffffc020257e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202580:	0ae7f363          	bgeu	a5,a4,ffffffffc0202626 <copy_range+0x16e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202584:	000bbd83          	ld	s11,0(s7)
ffffffffc0202588:	97da                	add	a5,a5,s6
ffffffffc020258a:	079a                	slli	a5,a5,0x6
ffffffffc020258c:	9dbe                	add	s11,s11,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020258e:	100027f3          	csrr	a5,sstatus
ffffffffc0202592:	8b89                	andi	a5,a5,2
ffffffffc0202594:	e3a1                	bnez	a5,ffffffffc02025d4 <copy_range+0x11c>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202596:	000a3783          	ld	a5,0(s4)
ffffffffc020259a:	4505                	li	a0,1
ffffffffc020259c:	6f9c                	ld	a5,24(a5)
ffffffffc020259e:	9782                	jalr	a5
ffffffffc02025a0:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc02025a2:	060d8263          	beqz	s11,ffffffffc0202606 <copy_range+0x14e>
            assert(npage != NULL);
ffffffffc02025a6:	f80d1ae3          	bnez	s10,ffffffffc020253a <copy_range+0x82>
ffffffffc02025aa:	00005697          	auipc	a3,0x5
ffffffffc02025ae:	dfe68693          	addi	a3,a3,-514 # ffffffffc02073a8 <etext+0xf06>
ffffffffc02025b2:	00005617          	auipc	a2,0x5
ffffffffc02025b6:	8c660613          	addi	a2,a2,-1850 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02025ba:	19600593          	li	a1,406
ffffffffc02025be:	00005517          	auipc	a0,0x5
ffffffffc02025c2:	d5a50513          	addi	a0,a0,-678 # ffffffffc0207318 <etext+0xe76>
ffffffffc02025c6:	e85fd0ef          	jal	ffffffffc020044a <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02025ca:	9466                	add	s0,s0,s9
ffffffffc02025cc:	ffe007b7          	lui	a5,0xffe00
ffffffffc02025d0:	8c7d                	and	s0,s0,a5
            continue;
ffffffffc02025d2:	b7ad                	j	ffffffffc020253c <copy_range+0x84>
        intr_disable();
ffffffffc02025d4:	b2afe0ef          	jal	ffffffffc02008fe <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02025d8:	000a3783          	ld	a5,0(s4)
ffffffffc02025dc:	4505                	li	a0,1
ffffffffc02025de:	6f9c                	ld	a5,24(a5)
ffffffffc02025e0:	9782                	jalr	a5
ffffffffc02025e2:	8d2a                	mv	s10,a0
        intr_enable();
ffffffffc02025e4:	b14fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc02025e8:	bf6d                	j	ffffffffc02025a2 <copy_range+0xea>
                return -E_NO_MEM;
ffffffffc02025ea:	5571                	li	a0,-4
ffffffffc02025ec:	bfa1                	j	ffffffffc0202544 <copy_range+0x8c>
        panic("pte2page called with invalid pte");
ffffffffc02025ee:	00005617          	auipc	a2,0x5
ffffffffc02025f2:	d8260613          	addi	a2,a2,-638 # ffffffffc0207370 <etext+0xece>
ffffffffc02025f6:	07f00593          	li	a1,127
ffffffffc02025fa:	00005517          	auipc	a0,0x5
ffffffffc02025fe:	c5650513          	addi	a0,a0,-938 # ffffffffc0207250 <etext+0xdae>
ffffffffc0202602:	e49fd0ef          	jal	ffffffffc020044a <__panic>
            assert(page != NULL);
ffffffffc0202606:	00005697          	auipc	a3,0x5
ffffffffc020260a:	d9268693          	addi	a3,a3,-622 # ffffffffc0207398 <etext+0xef6>
ffffffffc020260e:	00005617          	auipc	a2,0x5
ffffffffc0202612:	86a60613          	addi	a2,a2,-1942 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0202616:	19500593          	li	a1,405
ffffffffc020261a:	00005517          	auipc	a0,0x5
ffffffffc020261e:	cfe50513          	addi	a0,a0,-770 # ffffffffc0207318 <etext+0xe76>
ffffffffc0202622:	e29fd0ef          	jal	ffffffffc020044a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202626:	00005617          	auipc	a2,0x5
ffffffffc020262a:	cd260613          	addi	a2,a2,-814 # ffffffffc02072f8 <etext+0xe56>
ffffffffc020262e:	06900593          	li	a1,105
ffffffffc0202632:	00005517          	auipc	a0,0x5
ffffffffc0202636:	c1e50513          	addi	a0,a0,-994 # ffffffffc0207250 <etext+0xdae>
ffffffffc020263a:	e11fd0ef          	jal	ffffffffc020044a <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020263e:	00005697          	auipc	a3,0x5
ffffffffc0202642:	d1a68693          	addi	a3,a3,-742 # ffffffffc0207358 <etext+0xeb6>
ffffffffc0202646:	00005617          	auipc	a2,0x5
ffffffffc020264a:	83260613          	addi	a2,a2,-1998 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc020264e:	17d00593          	li	a1,381
ffffffffc0202652:	00005517          	auipc	a0,0x5
ffffffffc0202656:	cc650513          	addi	a0,a0,-826 # ffffffffc0207318 <etext+0xe76>
ffffffffc020265a:	df1fd0ef          	jal	ffffffffc020044a <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020265e:	00005697          	auipc	a3,0x5
ffffffffc0202662:	cca68693          	addi	a3,a3,-822 # ffffffffc0207328 <etext+0xe86>
ffffffffc0202666:	00005617          	auipc	a2,0x5
ffffffffc020266a:	81260613          	addi	a2,a2,-2030 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc020266e:	17c00593          	li	a1,380
ffffffffc0202672:	00005517          	auipc	a0,0x5
ffffffffc0202676:	ca650513          	addi	a0,a0,-858 # ffffffffc0207318 <etext+0xe76>
ffffffffc020267a:	dd1fd0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020267e <page_remove>:
{
ffffffffc020267e:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202680:	4601                	li	a2,0
{
ffffffffc0202682:	e822                	sd	s0,16(sp)
ffffffffc0202684:	ec06                	sd	ra,24(sp)
ffffffffc0202686:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202688:	f96ff0ef          	jal	ffffffffc0201e1e <get_pte>
    if (ptep != NULL)
ffffffffc020268c:	c511                	beqz	a0,ffffffffc0202698 <page_remove+0x1a>
    if (*ptep & PTE_V)
ffffffffc020268e:	6118                	ld	a4,0(a0)
ffffffffc0202690:	87aa                	mv	a5,a0
ffffffffc0202692:	00177693          	andi	a3,a4,1
ffffffffc0202696:	e689                	bnez	a3,ffffffffc02026a0 <page_remove+0x22>
}
ffffffffc0202698:	60e2                	ld	ra,24(sp)
ffffffffc020269a:	6442                	ld	s0,16(sp)
ffffffffc020269c:	6105                	addi	sp,sp,32
ffffffffc020269e:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc02026a0:	000ca697          	auipc	a3,0xca
ffffffffc02026a4:	c986b683          	ld	a3,-872(a3) # ffffffffc02cc338 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc02026a8:	070a                	slli	a4,a4,0x2
ffffffffc02026aa:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc02026ac:	06d77563          	bgeu	a4,a3,ffffffffc0202716 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc02026b0:	000ca517          	auipc	a0,0xca
ffffffffc02026b4:	c9053503          	ld	a0,-880(a0) # ffffffffc02cc340 <pages>
ffffffffc02026b8:	071a                	slli	a4,a4,0x6
ffffffffc02026ba:	fe0006b7          	lui	a3,0xfe000
ffffffffc02026be:	9736                	add	a4,a4,a3
ffffffffc02026c0:	953a                	add	a0,a0,a4
    page->ref -= 1;
ffffffffc02026c2:	4118                	lw	a4,0(a0)
ffffffffc02026c4:	377d                	addiw	a4,a4,-1
ffffffffc02026c6:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02026c8:	cb09                	beqz	a4,ffffffffc02026da <page_remove+0x5c>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc02026ca:	0007b023          	sd	zero,0(a5) # ffffffffffe00000 <end+0x3fb33c88>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02026ce:	12040073          	sfence.vma	s0
}
ffffffffc02026d2:	60e2                	ld	ra,24(sp)
ffffffffc02026d4:	6442                	ld	s0,16(sp)
ffffffffc02026d6:	6105                	addi	sp,sp,32
ffffffffc02026d8:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02026da:	10002773          	csrr	a4,sstatus
ffffffffc02026de:	8b09                	andi	a4,a4,2
ffffffffc02026e0:	eb19                	bnez	a4,ffffffffc02026f6 <page_remove+0x78>
        pmm_manager->free_pages(base, n);
ffffffffc02026e2:	000ca717          	auipc	a4,0xca
ffffffffc02026e6:	c3673703          	ld	a4,-970(a4) # ffffffffc02cc318 <pmm_manager>
ffffffffc02026ea:	4585                	li	a1,1
ffffffffc02026ec:	e03e                	sd	a5,0(sp)
ffffffffc02026ee:	7318                	ld	a4,32(a4)
ffffffffc02026f0:	9702                	jalr	a4
    if (flag) {
ffffffffc02026f2:	6782                	ld	a5,0(sp)
ffffffffc02026f4:	bfd9                	j	ffffffffc02026ca <page_remove+0x4c>
        intr_disable();
ffffffffc02026f6:	e43e                	sd	a5,8(sp)
ffffffffc02026f8:	e02a                	sd	a0,0(sp)
ffffffffc02026fa:	a04fe0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc02026fe:	000ca717          	auipc	a4,0xca
ffffffffc0202702:	c1a73703          	ld	a4,-998(a4) # ffffffffc02cc318 <pmm_manager>
ffffffffc0202706:	6502                	ld	a0,0(sp)
ffffffffc0202708:	4585                	li	a1,1
ffffffffc020270a:	7318                	ld	a4,32(a4)
ffffffffc020270c:	9702                	jalr	a4
        intr_enable();
ffffffffc020270e:	9eafe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202712:	67a2                	ld	a5,8(sp)
ffffffffc0202714:	bf5d                	j	ffffffffc02026ca <page_remove+0x4c>
ffffffffc0202716:	e44ff0ef          	jal	ffffffffc0201d5a <pa2page.part.0>

ffffffffc020271a <page_insert>:
{
ffffffffc020271a:	7139                	addi	sp,sp,-64
ffffffffc020271c:	f426                	sd	s1,40(sp)
ffffffffc020271e:	84b2                	mv	s1,a2
ffffffffc0202720:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202722:	4605                	li	a2,1
{
ffffffffc0202724:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202726:	85a6                	mv	a1,s1
{
ffffffffc0202728:	fc06                	sd	ra,56(sp)
ffffffffc020272a:	e436                	sd	a3,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020272c:	ef2ff0ef          	jal	ffffffffc0201e1e <get_pte>
    if (ptep == NULL)
ffffffffc0202730:	cd61                	beqz	a0,ffffffffc0202808 <page_insert+0xee>
    page->ref += 1;
ffffffffc0202732:	400c                	lw	a1,0(s0)
    if (*ptep & PTE_V)
ffffffffc0202734:	611c                	ld	a5,0(a0)
ffffffffc0202736:	66a2                	ld	a3,8(sp)
ffffffffc0202738:	0015861b          	addiw	a2,a1,1 # 1001 <_binary_obj___user_softint_out_size-0x80e7>
ffffffffc020273c:	c010                	sw	a2,0(s0)
ffffffffc020273e:	0017f613          	andi	a2,a5,1
ffffffffc0202742:	872a                	mv	a4,a0
ffffffffc0202744:	e61d                	bnez	a2,ffffffffc0202772 <page_insert+0x58>
    return &pages[PPN(pa) - nbase];
ffffffffc0202746:	000ca617          	auipc	a2,0xca
ffffffffc020274a:	bfa63603          	ld	a2,-1030(a2) # ffffffffc02cc340 <pages>
    return page - pages + nbase;
ffffffffc020274e:	8c11                	sub	s0,s0,a2
ffffffffc0202750:	8419                	srai	s0,s0,0x6
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202752:	200007b7          	lui	a5,0x20000
ffffffffc0202756:	042a                	slli	s0,s0,0xa
ffffffffc0202758:	943e                	add	s0,s0,a5
ffffffffc020275a:	8ec1                	or	a3,a3,s0
ffffffffc020275c:	0016e693          	ori	a3,a3,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202760:	e314                	sd	a3,0(a4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202762:	12048073          	sfence.vma	s1
    return 0;
ffffffffc0202766:	4501                	li	a0,0
}
ffffffffc0202768:	70e2                	ld	ra,56(sp)
ffffffffc020276a:	7442                	ld	s0,48(sp)
ffffffffc020276c:	74a2                	ld	s1,40(sp)
ffffffffc020276e:	6121                	addi	sp,sp,64
ffffffffc0202770:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc0202772:	000ca617          	auipc	a2,0xca
ffffffffc0202776:	bc663603          	ld	a2,-1082(a2) # ffffffffc02cc338 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc020277a:	078a                	slli	a5,a5,0x2
ffffffffc020277c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020277e:	08c7f763          	bgeu	a5,a2,ffffffffc020280c <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc0202782:	000ca617          	auipc	a2,0xca
ffffffffc0202786:	bbe63603          	ld	a2,-1090(a2) # ffffffffc02cc340 <pages>
ffffffffc020278a:	fe000537          	lui	a0,0xfe000
ffffffffc020278e:	079a                	slli	a5,a5,0x6
ffffffffc0202790:	97aa                	add	a5,a5,a0
ffffffffc0202792:	00f60533          	add	a0,a2,a5
        if (p == page)
ffffffffc0202796:	00a40963          	beq	s0,a0,ffffffffc02027a8 <page_insert+0x8e>
    page->ref -= 1;
ffffffffc020279a:	411c                	lw	a5,0(a0)
ffffffffc020279c:	37fd                	addiw	a5,a5,-1 # 1fffffff <_binary_obj___user_matrix_out_size+0x1fff4917>
ffffffffc020279e:	c11c                	sw	a5,0(a0)
        if (page_ref(page) ==
ffffffffc02027a0:	c791                	beqz	a5,ffffffffc02027ac <page_insert+0x92>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02027a2:	12048073          	sfence.vma	s1
}
ffffffffc02027a6:	b765                	j	ffffffffc020274e <page_insert+0x34>
ffffffffc02027a8:	c00c                	sw	a1,0(s0)
    return page->ref;
ffffffffc02027aa:	b755                	j	ffffffffc020274e <page_insert+0x34>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02027ac:	100027f3          	csrr	a5,sstatus
ffffffffc02027b0:	8b89                	andi	a5,a5,2
ffffffffc02027b2:	e39d                	bnez	a5,ffffffffc02027d8 <page_insert+0xbe>
        pmm_manager->free_pages(base, n);
ffffffffc02027b4:	000ca797          	auipc	a5,0xca
ffffffffc02027b8:	b647b783          	ld	a5,-1180(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc02027bc:	4585                	li	a1,1
ffffffffc02027be:	e83a                	sd	a4,16(sp)
ffffffffc02027c0:	739c                	ld	a5,32(a5)
ffffffffc02027c2:	e436                	sd	a3,8(sp)
ffffffffc02027c4:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc02027c6:	000ca617          	auipc	a2,0xca
ffffffffc02027ca:	b7a63603          	ld	a2,-1158(a2) # ffffffffc02cc340 <pages>
ffffffffc02027ce:	66a2                	ld	a3,8(sp)
ffffffffc02027d0:	6742                	ld	a4,16(sp)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02027d2:	12048073          	sfence.vma	s1
ffffffffc02027d6:	bfa5                	j	ffffffffc020274e <page_insert+0x34>
        intr_disable();
ffffffffc02027d8:	ec3a                	sd	a4,24(sp)
ffffffffc02027da:	e836                	sd	a3,16(sp)
ffffffffc02027dc:	e42a                	sd	a0,8(sp)
ffffffffc02027de:	920fe0ef          	jal	ffffffffc02008fe <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02027e2:	000ca797          	auipc	a5,0xca
ffffffffc02027e6:	b367b783          	ld	a5,-1226(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc02027ea:	6522                	ld	a0,8(sp)
ffffffffc02027ec:	4585                	li	a1,1
ffffffffc02027ee:	739c                	ld	a5,32(a5)
ffffffffc02027f0:	9782                	jalr	a5
        intr_enable();
ffffffffc02027f2:	906fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc02027f6:	000ca617          	auipc	a2,0xca
ffffffffc02027fa:	b4a63603          	ld	a2,-1206(a2) # ffffffffc02cc340 <pages>
ffffffffc02027fe:	6762                	ld	a4,24(sp)
ffffffffc0202800:	66c2                	ld	a3,16(sp)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202802:	12048073          	sfence.vma	s1
ffffffffc0202806:	b7a1                	j	ffffffffc020274e <page_insert+0x34>
        return -E_NO_MEM;
ffffffffc0202808:	5571                	li	a0,-4
ffffffffc020280a:	bfb9                	j	ffffffffc0202768 <page_insert+0x4e>
ffffffffc020280c:	d4eff0ef          	jal	ffffffffc0201d5a <pa2page.part.0>

ffffffffc0202810 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202810:	00006797          	auipc	a5,0x6
ffffffffc0202814:	00078793          	mv	a5,a5
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202818:	638c                	ld	a1,0(a5)
{
ffffffffc020281a:	7159                	addi	sp,sp,-112
ffffffffc020281c:	f486                	sd	ra,104(sp)
ffffffffc020281e:	e8ca                	sd	s2,80(sp)
ffffffffc0202820:	e4ce                	sd	s3,72(sp)
ffffffffc0202822:	f85a                	sd	s6,48(sp)
ffffffffc0202824:	f0a2                	sd	s0,96(sp)
ffffffffc0202826:	eca6                	sd	s1,88(sp)
ffffffffc0202828:	e0d2                	sd	s4,64(sp)
ffffffffc020282a:	fc56                	sd	s5,56(sp)
ffffffffc020282c:	f45e                	sd	s7,40(sp)
ffffffffc020282e:	f062                	sd	s8,32(sp)
ffffffffc0202830:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202832:	000cab17          	auipc	s6,0xca
ffffffffc0202836:	ae6b0b13          	addi	s6,s6,-1306 # ffffffffc02cc318 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020283a:	00005517          	auipc	a0,0x5
ffffffffc020283e:	b7e50513          	addi	a0,a0,-1154 # ffffffffc02073b8 <etext+0xf16>
    pmm_manager = &default_pmm_manager;
ffffffffc0202842:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202846:	953fd0ef          	jal	ffffffffc0200198 <cprintf>
    pmm_manager->init();
ffffffffc020284a:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020284e:	000ca997          	auipc	s3,0xca
ffffffffc0202852:	ae298993          	addi	s3,s3,-1310 # ffffffffc02cc330 <va_pa_offset>
    pmm_manager->init();
ffffffffc0202856:	679c                	ld	a5,8(a5)
ffffffffc0202858:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020285a:	57f5                	li	a5,-3
ffffffffc020285c:	07fa                	slli	a5,a5,0x1e
ffffffffc020285e:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc0202862:	882fe0ef          	jal	ffffffffc02008e4 <get_memory_base>
ffffffffc0202866:	892a                	mv	s2,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc0202868:	886fe0ef          	jal	ffffffffc02008ee <get_memory_size>
    if (mem_size == 0) {
ffffffffc020286c:	70050e63          	beqz	a0,ffffffffc0202f88 <pmm_init+0x778>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc0202870:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc0202872:	00005517          	auipc	a0,0x5
ffffffffc0202876:	b7e50513          	addi	a0,a0,-1154 # ffffffffc02073f0 <etext+0xf4e>
ffffffffc020287a:	91ffd0ef          	jal	ffffffffc0200198 <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc020287e:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc0202882:	864a                	mv	a2,s2
ffffffffc0202884:	85a6                	mv	a1,s1
ffffffffc0202886:	fff40693          	addi	a3,s0,-1
ffffffffc020288a:	00005517          	auipc	a0,0x5
ffffffffc020288e:	b7e50513          	addi	a0,a0,-1154 # ffffffffc0207408 <etext+0xf66>
ffffffffc0202892:	907fd0ef          	jal	ffffffffc0200198 <cprintf>
    if (maxpa > KERNTOP)
ffffffffc0202896:	c80007b7          	lui	a5,0xc8000
ffffffffc020289a:	8522                	mv	a0,s0
ffffffffc020289c:	5287ed63          	bltu	a5,s0,ffffffffc0202dd6 <pmm_init+0x5c6>
ffffffffc02028a0:	77fd                	lui	a5,0xfffff
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02028a2:	000cb617          	auipc	a2,0xcb
ffffffffc02028a6:	ad560613          	addi	a2,a2,-1323 # ffffffffc02cd377 <end+0xfff>
ffffffffc02028aa:	8e7d                	and	a2,a2,a5
    npage = maxpa / PGSIZE;
ffffffffc02028ac:	8131                	srli	a0,a0,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02028ae:	000cab97          	auipc	s7,0xca
ffffffffc02028b2:	a92b8b93          	addi	s7,s7,-1390 # ffffffffc02cc340 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02028b6:	000ca497          	auipc	s1,0xca
ffffffffc02028ba:	a8248493          	addi	s1,s1,-1406 # ffffffffc02cc338 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02028be:	00cbb023          	sd	a2,0(s7)
    npage = maxpa / PGSIZE;
ffffffffc02028c2:	e088                	sd	a0,0(s1)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02028c4:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02028c8:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02028ca:	02f50763          	beq	a0,a5,ffffffffc02028f8 <pmm_init+0xe8>
ffffffffc02028ce:	4701                	li	a4,0
ffffffffc02028d0:	4585                	li	a1,1
ffffffffc02028d2:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc02028d6:	00671793          	slli	a5,a4,0x6
ffffffffc02028da:	97b2                	add	a5,a5,a2
ffffffffc02028dc:	07a1                	addi	a5,a5,8 # 80008 <_binary_obj___user_matrix_out_size+0x74920>
ffffffffc02028de:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02028e2:	6088                	ld	a0,0(s1)
ffffffffc02028e4:	0705                	addi	a4,a4,1
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02028e6:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02028ea:	00d507b3          	add	a5,a0,a3
ffffffffc02028ee:	fef764e3          	bltu	a4,a5,ffffffffc02028d6 <pmm_init+0xc6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02028f2:	079a                	slli	a5,a5,0x6
ffffffffc02028f4:	00f606b3          	add	a3,a2,a5
ffffffffc02028f8:	c02007b7          	lui	a5,0xc0200
ffffffffc02028fc:	16f6eee3          	bltu	a3,a5,ffffffffc0203278 <pmm_init+0xa68>
ffffffffc0202900:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0202904:	77fd                	lui	a5,0xfffff
ffffffffc0202906:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202908:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc020290a:	4e86ed63          	bltu	a3,s0,ffffffffc0202e04 <pmm_init+0x5f4>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc020290e:	00005517          	auipc	a0,0x5
ffffffffc0202912:	b2250513          	addi	a0,a0,-1246 # ffffffffc0207430 <etext+0xf8e>
ffffffffc0202916:	883fd0ef          	jal	ffffffffc0200198 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc020291a:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc020291e:	000ca917          	auipc	s2,0xca
ffffffffc0202922:	a0a90913          	addi	s2,s2,-1526 # ffffffffc02cc328 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc0202926:	7b9c                	ld	a5,48(a5)
ffffffffc0202928:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc020292a:	00005517          	auipc	a0,0x5
ffffffffc020292e:	b1e50513          	addi	a0,a0,-1250 # ffffffffc0207448 <etext+0xfa6>
ffffffffc0202932:	867fd0ef          	jal	ffffffffc0200198 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0202936:	00009697          	auipc	a3,0x9
ffffffffc020293a:	6ca68693          	addi	a3,a3,1738 # ffffffffc020c000 <boot_page_table_sv39>
ffffffffc020293e:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0202942:	c02007b7          	lui	a5,0xc0200
ffffffffc0202946:	2af6eee3          	bltu	a3,a5,ffffffffc0203402 <pmm_init+0xbf2>
ffffffffc020294a:	0009b783          	ld	a5,0(s3)
ffffffffc020294e:	8e9d                	sub	a3,a3,a5
ffffffffc0202950:	000ca797          	auipc	a5,0xca
ffffffffc0202954:	9cd7b823          	sd	a3,-1584(a5) # ffffffffc02cc320 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202958:	100027f3          	csrr	a5,sstatus
ffffffffc020295c:	8b89                	andi	a5,a5,2
ffffffffc020295e:	48079963          	bnez	a5,ffffffffc0202df0 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202962:	000b3783          	ld	a5,0(s6)
ffffffffc0202966:	779c                	ld	a5,40(a5)
ffffffffc0202968:	9782                	jalr	a5
ffffffffc020296a:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020296c:	6098                	ld	a4,0(s1)
ffffffffc020296e:	c80007b7          	lui	a5,0xc8000
ffffffffc0202972:	83b1                	srli	a5,a5,0xc
ffffffffc0202974:	66e7e663          	bltu	a5,a4,ffffffffc0202fe0 <pmm_init+0x7d0>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202978:	00093503          	ld	a0,0(s2)
ffffffffc020297c:	64050263          	beqz	a0,ffffffffc0202fc0 <pmm_init+0x7b0>
ffffffffc0202980:	03451793          	slli	a5,a0,0x34
ffffffffc0202984:	62079e63          	bnez	a5,ffffffffc0202fc0 <pmm_init+0x7b0>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0202988:	4601                	li	a2,0
ffffffffc020298a:	4581                	li	a1,0
ffffffffc020298c:	ef0ff0ef          	jal	ffffffffc020207c <get_page>
ffffffffc0202990:	240519e3          	bnez	a0,ffffffffc02033e2 <pmm_init+0xbd2>
ffffffffc0202994:	100027f3          	csrr	a5,sstatus
ffffffffc0202998:	8b89                	andi	a5,a5,2
ffffffffc020299a:	44079063          	bnez	a5,ffffffffc0202dda <pmm_init+0x5ca>
        page = pmm_manager->alloc_pages(n);
ffffffffc020299e:	000b3783          	ld	a5,0(s6)
ffffffffc02029a2:	4505                	li	a0,1
ffffffffc02029a4:	6f9c                	ld	a5,24(a5)
ffffffffc02029a6:	9782                	jalr	a5
ffffffffc02029a8:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc02029aa:	00093503          	ld	a0,0(s2)
ffffffffc02029ae:	4681                	li	a3,0
ffffffffc02029b0:	4601                	li	a2,0
ffffffffc02029b2:	85d2                	mv	a1,s4
ffffffffc02029b4:	d67ff0ef          	jal	ffffffffc020271a <page_insert>
ffffffffc02029b8:	280511e3          	bnez	a0,ffffffffc020343a <pmm_init+0xc2a>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc02029bc:	00093503          	ld	a0,0(s2)
ffffffffc02029c0:	4601                	li	a2,0
ffffffffc02029c2:	4581                	li	a1,0
ffffffffc02029c4:	c5aff0ef          	jal	ffffffffc0201e1e <get_pte>
ffffffffc02029c8:	240509e3          	beqz	a0,ffffffffc020341a <pmm_init+0xc0a>
    assert(pte2page(*ptep) == p1);
ffffffffc02029cc:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc02029ce:	0017f713          	andi	a4,a5,1
ffffffffc02029d2:	58070f63          	beqz	a4,ffffffffc0202f70 <pmm_init+0x760>
    if (PPN(pa) >= npage)
ffffffffc02029d6:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc02029d8:	078a                	slli	a5,a5,0x2
ffffffffc02029da:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02029dc:	58e7f863          	bgeu	a5,a4,ffffffffc0202f6c <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc02029e0:	000bb683          	ld	a3,0(s7)
ffffffffc02029e4:	079a                	slli	a5,a5,0x6
ffffffffc02029e6:	fe000637          	lui	a2,0xfe000
ffffffffc02029ea:	97b2                	add	a5,a5,a2
ffffffffc02029ec:	97b6                	add	a5,a5,a3
ffffffffc02029ee:	14fa1ae3          	bne	s4,a5,ffffffffc0203342 <pmm_init+0xb32>
    assert(page_ref(p1) == 1);
ffffffffc02029f2:	000a2683          	lw	a3,0(s4)
ffffffffc02029f6:	4785                	li	a5,1
ffffffffc02029f8:	12f695e3          	bne	a3,a5,ffffffffc0203322 <pmm_init+0xb12>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc02029fc:	00093503          	ld	a0,0(s2)
ffffffffc0202a00:	77fd                	lui	a5,0xfffff
ffffffffc0202a02:	6114                	ld	a3,0(a0)
ffffffffc0202a04:	068a                	slli	a3,a3,0x2
ffffffffc0202a06:	8efd                	and	a3,a3,a5
ffffffffc0202a08:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202a0c:	0ee67fe3          	bgeu	a2,a4,ffffffffc020330a <pmm_init+0xafa>
ffffffffc0202a10:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202a14:	96e2                	add	a3,a3,s8
ffffffffc0202a16:	0006ba83          	ld	s5,0(a3)
ffffffffc0202a1a:	0a8a                	slli	s5,s5,0x2
ffffffffc0202a1c:	00fafab3          	and	s5,s5,a5
ffffffffc0202a20:	00cad793          	srli	a5,s5,0xc
ffffffffc0202a24:	0ce7f6e3          	bgeu	a5,a4,ffffffffc02032f0 <pmm_init+0xae0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202a28:	4601                	li	a2,0
ffffffffc0202a2a:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202a2c:	9c56                	add	s8,s8,s5
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202a2e:	bf0ff0ef          	jal	ffffffffc0201e1e <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202a32:	0c21                	addi	s8,s8,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202a34:	05851ee3          	bne	a0,s8,ffffffffc0203290 <pmm_init+0xa80>
ffffffffc0202a38:	100027f3          	csrr	a5,sstatus
ffffffffc0202a3c:	8b89                	andi	a5,a5,2
ffffffffc0202a3e:	3e079b63          	bnez	a5,ffffffffc0202e34 <pmm_init+0x624>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202a42:	000b3783          	ld	a5,0(s6)
ffffffffc0202a46:	4505                	li	a0,1
ffffffffc0202a48:	6f9c                	ld	a5,24(a5)
ffffffffc0202a4a:	9782                	jalr	a5
ffffffffc0202a4c:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202a4e:	00093503          	ld	a0,0(s2)
ffffffffc0202a52:	46d1                	li	a3,20
ffffffffc0202a54:	6605                	lui	a2,0x1
ffffffffc0202a56:	85e2                	mv	a1,s8
ffffffffc0202a58:	cc3ff0ef          	jal	ffffffffc020271a <page_insert>
ffffffffc0202a5c:	06051ae3          	bnez	a0,ffffffffc02032d0 <pmm_init+0xac0>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202a60:	00093503          	ld	a0,0(s2)
ffffffffc0202a64:	4601                	li	a2,0
ffffffffc0202a66:	6585                	lui	a1,0x1
ffffffffc0202a68:	bb6ff0ef          	jal	ffffffffc0201e1e <get_pte>
ffffffffc0202a6c:	040502e3          	beqz	a0,ffffffffc02032b0 <pmm_init+0xaa0>
    assert(*ptep & PTE_U);
ffffffffc0202a70:	611c                	ld	a5,0(a0)
ffffffffc0202a72:	0107f713          	andi	a4,a5,16
ffffffffc0202a76:	7e070163          	beqz	a4,ffffffffc0203258 <pmm_init+0xa48>
    assert(*ptep & PTE_W);
ffffffffc0202a7a:	8b91                	andi	a5,a5,4
ffffffffc0202a7c:	7a078e63          	beqz	a5,ffffffffc0203238 <pmm_init+0xa28>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0202a80:	00093503          	ld	a0,0(s2)
ffffffffc0202a84:	611c                	ld	a5,0(a0)
ffffffffc0202a86:	8bc1                	andi	a5,a5,16
ffffffffc0202a88:	78078863          	beqz	a5,ffffffffc0203218 <pmm_init+0xa08>
    assert(page_ref(p2) == 1);
ffffffffc0202a8c:	000c2703          	lw	a4,0(s8)
ffffffffc0202a90:	4785                	li	a5,1
ffffffffc0202a92:	76f71363          	bne	a4,a5,ffffffffc02031f8 <pmm_init+0x9e8>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0202a96:	4681                	li	a3,0
ffffffffc0202a98:	6605                	lui	a2,0x1
ffffffffc0202a9a:	85d2                	mv	a1,s4
ffffffffc0202a9c:	c7fff0ef          	jal	ffffffffc020271a <page_insert>
ffffffffc0202aa0:	72051c63          	bnez	a0,ffffffffc02031d8 <pmm_init+0x9c8>
    assert(page_ref(p1) == 2);
ffffffffc0202aa4:	000a2703          	lw	a4,0(s4)
ffffffffc0202aa8:	4789                	li	a5,2
ffffffffc0202aaa:	70f71763          	bne	a4,a5,ffffffffc02031b8 <pmm_init+0x9a8>
    assert(page_ref(p2) == 0);
ffffffffc0202aae:	000c2783          	lw	a5,0(s8)
ffffffffc0202ab2:	6e079363          	bnez	a5,ffffffffc0203198 <pmm_init+0x988>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202ab6:	00093503          	ld	a0,0(s2)
ffffffffc0202aba:	4601                	li	a2,0
ffffffffc0202abc:	6585                	lui	a1,0x1
ffffffffc0202abe:	b60ff0ef          	jal	ffffffffc0201e1e <get_pte>
ffffffffc0202ac2:	6a050b63          	beqz	a0,ffffffffc0203178 <pmm_init+0x968>
    assert(pte2page(*ptep) == p1);
ffffffffc0202ac6:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202ac8:	00177793          	andi	a5,a4,1
ffffffffc0202acc:	4a078263          	beqz	a5,ffffffffc0202f70 <pmm_init+0x760>
    if (PPN(pa) >= npage)
ffffffffc0202ad0:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202ad2:	00271793          	slli	a5,a4,0x2
ffffffffc0202ad6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202ad8:	48d7fa63          	bgeu	a5,a3,ffffffffc0202f6c <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202adc:	000bb683          	ld	a3,0(s7)
ffffffffc0202ae0:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202ae4:	97d6                	add	a5,a5,s5
ffffffffc0202ae6:	079a                	slli	a5,a5,0x6
ffffffffc0202ae8:	97b6                	add	a5,a5,a3
ffffffffc0202aea:	66fa1763          	bne	s4,a5,ffffffffc0203158 <pmm_init+0x948>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202aee:	8b41                	andi	a4,a4,16
ffffffffc0202af0:	64071463          	bnez	a4,ffffffffc0203138 <pmm_init+0x928>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc0202af4:	00093503          	ld	a0,0(s2)
ffffffffc0202af8:	4581                	li	a1,0
ffffffffc0202afa:	b85ff0ef          	jal	ffffffffc020267e <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202afe:	000a2c83          	lw	s9,0(s4)
ffffffffc0202b02:	4785                	li	a5,1
ffffffffc0202b04:	60fc9a63          	bne	s9,a5,ffffffffc0203118 <pmm_init+0x908>
    assert(page_ref(p2) == 0);
ffffffffc0202b08:	000c2783          	lw	a5,0(s8)
ffffffffc0202b0c:	5e079663          	bnez	a5,ffffffffc02030f8 <pmm_init+0x8e8>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc0202b10:	00093503          	ld	a0,0(s2)
ffffffffc0202b14:	6585                	lui	a1,0x1
ffffffffc0202b16:	b69ff0ef          	jal	ffffffffc020267e <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202b1a:	000a2783          	lw	a5,0(s4)
ffffffffc0202b1e:	52079d63          	bnez	a5,ffffffffc0203058 <pmm_init+0x848>
    assert(page_ref(p2) == 0);
ffffffffc0202b22:	000c2783          	lw	a5,0(s8)
ffffffffc0202b26:	50079963          	bnez	a5,ffffffffc0203038 <pmm_init+0x828>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202b2a:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202b2e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b30:	000a3783          	ld	a5,0(s4)
ffffffffc0202b34:	078a                	slli	a5,a5,0x2
ffffffffc0202b36:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b38:	42e7fa63          	bgeu	a5,a4,ffffffffc0202f6c <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b3c:	000bb503          	ld	a0,0(s7)
ffffffffc0202b40:	97d6                	add	a5,a5,s5
ffffffffc0202b42:	079a                	slli	a5,a5,0x6
    return page->ref;
ffffffffc0202b44:	00f506b3          	add	a3,a0,a5
ffffffffc0202b48:	4294                	lw	a3,0(a3)
ffffffffc0202b4a:	4d969763          	bne	a3,s9,ffffffffc0203018 <pmm_init+0x808>
    return page - pages + nbase;
ffffffffc0202b4e:	8799                	srai	a5,a5,0x6
ffffffffc0202b50:	00080637          	lui	a2,0x80
ffffffffc0202b54:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b56:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202b5a:	4ae7f363          	bgeu	a5,a4,ffffffffc0203000 <pmm_init+0x7f0>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202b5e:	0009b783          	ld	a5,0(s3)
ffffffffc0202b62:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b64:	639c                	ld	a5,0(a5)
ffffffffc0202b66:	078a                	slli	a5,a5,0x2
ffffffffc0202b68:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b6a:	40e7f163          	bgeu	a5,a4,ffffffffc0202f6c <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b6e:	8f91                	sub	a5,a5,a2
ffffffffc0202b70:	079a                	slli	a5,a5,0x6
ffffffffc0202b72:	953e                	add	a0,a0,a5
ffffffffc0202b74:	100027f3          	csrr	a5,sstatus
ffffffffc0202b78:	8b89                	andi	a5,a5,2
ffffffffc0202b7a:	30079863          	bnez	a5,ffffffffc0202e8a <pmm_init+0x67a>
        pmm_manager->free_pages(base, n);
ffffffffc0202b7e:	000b3783          	ld	a5,0(s6)
ffffffffc0202b82:	4585                	li	a1,1
ffffffffc0202b84:	739c                	ld	a5,32(a5)
ffffffffc0202b86:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b88:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202b8c:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b8e:	078a                	slli	a5,a5,0x2
ffffffffc0202b90:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b92:	3ce7fd63          	bgeu	a5,a4,ffffffffc0202f6c <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b96:	000bb503          	ld	a0,0(s7)
ffffffffc0202b9a:	fe000737          	lui	a4,0xfe000
ffffffffc0202b9e:	079a                	slli	a5,a5,0x6
ffffffffc0202ba0:	97ba                	add	a5,a5,a4
ffffffffc0202ba2:	953e                	add	a0,a0,a5
ffffffffc0202ba4:	100027f3          	csrr	a5,sstatus
ffffffffc0202ba8:	8b89                	andi	a5,a5,2
ffffffffc0202baa:	2c079463          	bnez	a5,ffffffffc0202e72 <pmm_init+0x662>
ffffffffc0202bae:	000b3783          	ld	a5,0(s6)
ffffffffc0202bb2:	4585                	li	a1,1
ffffffffc0202bb4:	739c                	ld	a5,32(a5)
ffffffffc0202bb6:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202bb8:	00093783          	ld	a5,0(s2)
ffffffffc0202bbc:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd32c88>
    asm volatile("sfence.vma");
ffffffffc0202bc0:	12000073          	sfence.vma
ffffffffc0202bc4:	100027f3          	csrr	a5,sstatus
ffffffffc0202bc8:	8b89                	andi	a5,a5,2
ffffffffc0202bca:	28079a63          	bnez	a5,ffffffffc0202e5e <pmm_init+0x64e>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202bce:	000b3783          	ld	a5,0(s6)
ffffffffc0202bd2:	779c                	ld	a5,40(a5)
ffffffffc0202bd4:	9782                	jalr	a5
ffffffffc0202bd6:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202bd8:	4d441063          	bne	s0,s4,ffffffffc0203098 <pmm_init+0x888>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202bdc:	00005517          	auipc	a0,0x5
ffffffffc0202be0:	b9450513          	addi	a0,a0,-1132 # ffffffffc0207770 <etext+0x12ce>
ffffffffc0202be4:	db4fd0ef          	jal	ffffffffc0200198 <cprintf>
ffffffffc0202be8:	100027f3          	csrr	a5,sstatus
ffffffffc0202bec:	8b89                	andi	a5,a5,2
ffffffffc0202bee:	24079e63          	bnez	a5,ffffffffc0202e4a <pmm_init+0x63a>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202bf2:	000b3783          	ld	a5,0(s6)
ffffffffc0202bf6:	779c                	ld	a5,40(a5)
ffffffffc0202bf8:	9782                	jalr	a5
ffffffffc0202bfa:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202bfc:	609c                	ld	a5,0(s1)
ffffffffc0202bfe:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202c02:	7a7d                	lui	s4,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202c04:	00c79713          	slli	a4,a5,0xc
ffffffffc0202c08:	6a85                	lui	s5,0x1
ffffffffc0202c0a:	02e47c63          	bgeu	s0,a4,ffffffffc0202c42 <pmm_init+0x432>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202c0e:	00c45713          	srli	a4,s0,0xc
ffffffffc0202c12:	30f77063          	bgeu	a4,a5,ffffffffc0202f12 <pmm_init+0x702>
ffffffffc0202c16:	0009b583          	ld	a1,0(s3)
ffffffffc0202c1a:	00093503          	ld	a0,0(s2)
ffffffffc0202c1e:	4601                	li	a2,0
ffffffffc0202c20:	95a2                	add	a1,a1,s0
ffffffffc0202c22:	9fcff0ef          	jal	ffffffffc0201e1e <get_pte>
ffffffffc0202c26:	32050363          	beqz	a0,ffffffffc0202f4c <pmm_init+0x73c>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202c2a:	611c                	ld	a5,0(a0)
ffffffffc0202c2c:	078a                	slli	a5,a5,0x2
ffffffffc0202c2e:	0147f7b3          	and	a5,a5,s4
ffffffffc0202c32:	2e879d63          	bne	a5,s0,ffffffffc0202f2c <pmm_init+0x71c>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202c36:	609c                	ld	a5,0(s1)
ffffffffc0202c38:	9456                	add	s0,s0,s5
ffffffffc0202c3a:	00c79713          	slli	a4,a5,0xc
ffffffffc0202c3e:	fce468e3          	bltu	s0,a4,ffffffffc0202c0e <pmm_init+0x3fe>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc0202c42:	00093783          	ld	a5,0(s2)
ffffffffc0202c46:	639c                	ld	a5,0(a5)
ffffffffc0202c48:	42079863          	bnez	a5,ffffffffc0203078 <pmm_init+0x868>
ffffffffc0202c4c:	100027f3          	csrr	a5,sstatus
ffffffffc0202c50:	8b89                	andi	a5,a5,2
ffffffffc0202c52:	24079863          	bnez	a5,ffffffffc0202ea2 <pmm_init+0x692>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202c56:	000b3783          	ld	a5,0(s6)
ffffffffc0202c5a:	4505                	li	a0,1
ffffffffc0202c5c:	6f9c                	ld	a5,24(a5)
ffffffffc0202c5e:	9782                	jalr	a5
ffffffffc0202c60:	842a                	mv	s0,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202c62:	00093503          	ld	a0,0(s2)
ffffffffc0202c66:	4699                	li	a3,6
ffffffffc0202c68:	10000613          	li	a2,256
ffffffffc0202c6c:	85a2                	mv	a1,s0
ffffffffc0202c6e:	aadff0ef          	jal	ffffffffc020271a <page_insert>
ffffffffc0202c72:	46051363          	bnez	a0,ffffffffc02030d8 <pmm_init+0x8c8>
    assert(page_ref(p) == 1);
ffffffffc0202c76:	4018                	lw	a4,0(s0)
ffffffffc0202c78:	4785                	li	a5,1
ffffffffc0202c7a:	42f71f63          	bne	a4,a5,ffffffffc02030b8 <pmm_init+0x8a8>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202c7e:	00093503          	ld	a0,0(s2)
ffffffffc0202c82:	6605                	lui	a2,0x1
ffffffffc0202c84:	10060613          	addi	a2,a2,256 # 1100 <_binary_obj___user_softint_out_size-0x7fe8>
ffffffffc0202c88:	4699                	li	a3,6
ffffffffc0202c8a:	85a2                	mv	a1,s0
ffffffffc0202c8c:	a8fff0ef          	jal	ffffffffc020271a <page_insert>
ffffffffc0202c90:	72051963          	bnez	a0,ffffffffc02033c2 <pmm_init+0xbb2>
    assert(page_ref(p) == 2);
ffffffffc0202c94:	4018                	lw	a4,0(s0)
ffffffffc0202c96:	4789                	li	a5,2
ffffffffc0202c98:	70f71563          	bne	a4,a5,ffffffffc02033a2 <pmm_init+0xb92>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202c9c:	00005597          	auipc	a1,0x5
ffffffffc0202ca0:	c1c58593          	addi	a1,a1,-996 # ffffffffc02078b8 <etext+0x1416>
ffffffffc0202ca4:	10000513          	li	a0,256
ffffffffc0202ca8:	750030ef          	jal	ffffffffc02063f8 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202cac:	6585                	lui	a1,0x1
ffffffffc0202cae:	10058593          	addi	a1,a1,256 # 1100 <_binary_obj___user_softint_out_size-0x7fe8>
ffffffffc0202cb2:	10000513          	li	a0,256
ffffffffc0202cb6:	754030ef          	jal	ffffffffc020640a <strcmp>
ffffffffc0202cba:	6c051463          	bnez	a0,ffffffffc0203382 <pmm_init+0xb72>
    return page - pages + nbase;
ffffffffc0202cbe:	000bb683          	ld	a3,0(s7)
ffffffffc0202cc2:	000807b7          	lui	a5,0x80
    return KADDR(page2pa(page));
ffffffffc0202cc6:	6098                	ld	a4,0(s1)
    return page - pages + nbase;
ffffffffc0202cc8:	40d406b3          	sub	a3,s0,a3
ffffffffc0202ccc:	8699                	srai	a3,a3,0x6
ffffffffc0202cce:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0202cd0:	00c69793          	slli	a5,a3,0xc
ffffffffc0202cd4:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202cd6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202cd8:	32e7f463          	bgeu	a5,a4,ffffffffc0203000 <pmm_init+0x7f0>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202cdc:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202ce0:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202ce4:	97b6                	add	a5,a5,a3
ffffffffc0202ce6:	10078023          	sb	zero,256(a5) # 80100 <_binary_obj___user_matrix_out_size+0x74a18>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202cea:	6da030ef          	jal	ffffffffc02063c4 <strlen>
ffffffffc0202cee:	66051a63          	bnez	a0,ffffffffc0203362 <pmm_init+0xb52>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0202cf2:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202cf6:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202cf8:	000a3783          	ld	a5,0(s4) # fffffffffffff000 <end+0x3fd32c88>
ffffffffc0202cfc:	078a                	slli	a5,a5,0x2
ffffffffc0202cfe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202d00:	26e7f663          	bgeu	a5,a4,ffffffffc0202f6c <pmm_init+0x75c>
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d04:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202d08:	2ee7fc63          	bgeu	a5,a4,ffffffffc0203000 <pmm_init+0x7f0>
ffffffffc0202d0c:	0009b783          	ld	a5,0(s3)
ffffffffc0202d10:	00f689b3          	add	s3,a3,a5
ffffffffc0202d14:	100027f3          	csrr	a5,sstatus
ffffffffc0202d18:	8b89                	andi	a5,a5,2
ffffffffc0202d1a:	1e079163          	bnez	a5,ffffffffc0202efc <pmm_init+0x6ec>
        pmm_manager->free_pages(base, n);
ffffffffc0202d1e:	000b3783          	ld	a5,0(s6)
ffffffffc0202d22:	8522                	mv	a0,s0
ffffffffc0202d24:	4585                	li	a1,1
ffffffffc0202d26:	739c                	ld	a5,32(a5)
ffffffffc0202d28:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d2a:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage)
ffffffffc0202d2e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d30:	078a                	slli	a5,a5,0x2
ffffffffc0202d32:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202d34:	22e7fc63          	bgeu	a5,a4,ffffffffc0202f6c <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d38:	000bb503          	ld	a0,0(s7)
ffffffffc0202d3c:	fe000737          	lui	a4,0xfe000
ffffffffc0202d40:	079a                	slli	a5,a5,0x6
ffffffffc0202d42:	97ba                	add	a5,a5,a4
ffffffffc0202d44:	953e                	add	a0,a0,a5
ffffffffc0202d46:	100027f3          	csrr	a5,sstatus
ffffffffc0202d4a:	8b89                	andi	a5,a5,2
ffffffffc0202d4c:	18079c63          	bnez	a5,ffffffffc0202ee4 <pmm_init+0x6d4>
ffffffffc0202d50:	000b3783          	ld	a5,0(s6)
ffffffffc0202d54:	4585                	li	a1,1
ffffffffc0202d56:	739c                	ld	a5,32(a5)
ffffffffc0202d58:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d5a:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202d5e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d60:	078a                	slli	a5,a5,0x2
ffffffffc0202d62:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202d64:	20e7f463          	bgeu	a5,a4,ffffffffc0202f6c <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d68:	000bb503          	ld	a0,0(s7)
ffffffffc0202d6c:	fe000737          	lui	a4,0xfe000
ffffffffc0202d70:	079a                	slli	a5,a5,0x6
ffffffffc0202d72:	97ba                	add	a5,a5,a4
ffffffffc0202d74:	953e                	add	a0,a0,a5
ffffffffc0202d76:	100027f3          	csrr	a5,sstatus
ffffffffc0202d7a:	8b89                	andi	a5,a5,2
ffffffffc0202d7c:	14079863          	bnez	a5,ffffffffc0202ecc <pmm_init+0x6bc>
ffffffffc0202d80:	000b3783          	ld	a5,0(s6)
ffffffffc0202d84:	4585                	li	a1,1
ffffffffc0202d86:	739c                	ld	a5,32(a5)
ffffffffc0202d88:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202d8a:	00093783          	ld	a5,0(s2)
ffffffffc0202d8e:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0202d92:	12000073          	sfence.vma
ffffffffc0202d96:	100027f3          	csrr	a5,sstatus
ffffffffc0202d9a:	8b89                	andi	a5,a5,2
ffffffffc0202d9c:	10079e63          	bnez	a5,ffffffffc0202eb8 <pmm_init+0x6a8>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202da0:	000b3783          	ld	a5,0(s6)
ffffffffc0202da4:	779c                	ld	a5,40(a5)
ffffffffc0202da6:	9782                	jalr	a5
ffffffffc0202da8:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202daa:	1e8c1b63          	bne	s8,s0,ffffffffc0202fa0 <pmm_init+0x790>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202dae:	00005517          	auipc	a0,0x5
ffffffffc0202db2:	b8250513          	addi	a0,a0,-1150 # ffffffffc0207930 <etext+0x148e>
ffffffffc0202db6:	be2fd0ef          	jal	ffffffffc0200198 <cprintf>
}
ffffffffc0202dba:	7406                	ld	s0,96(sp)
ffffffffc0202dbc:	70a6                	ld	ra,104(sp)
ffffffffc0202dbe:	64e6                	ld	s1,88(sp)
ffffffffc0202dc0:	6946                	ld	s2,80(sp)
ffffffffc0202dc2:	69a6                	ld	s3,72(sp)
ffffffffc0202dc4:	6a06                	ld	s4,64(sp)
ffffffffc0202dc6:	7ae2                	ld	s5,56(sp)
ffffffffc0202dc8:	7b42                	ld	s6,48(sp)
ffffffffc0202dca:	7ba2                	ld	s7,40(sp)
ffffffffc0202dcc:	7c02                	ld	s8,32(sp)
ffffffffc0202dce:	6ce2                	ld	s9,24(sp)
ffffffffc0202dd0:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0202dd2:	dbffe06f          	j	ffffffffc0201b90 <kmalloc_init>
    if (maxpa > KERNTOP)
ffffffffc0202dd6:	853e                	mv	a0,a5
ffffffffc0202dd8:	b4e1                	j	ffffffffc02028a0 <pmm_init+0x90>
        intr_disable();
ffffffffc0202dda:	b25fd0ef          	jal	ffffffffc02008fe <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202dde:	000b3783          	ld	a5,0(s6)
ffffffffc0202de2:	4505                	li	a0,1
ffffffffc0202de4:	6f9c                	ld	a5,24(a5)
ffffffffc0202de6:	9782                	jalr	a5
ffffffffc0202de8:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202dea:	b0ffd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202dee:	be75                	j	ffffffffc02029aa <pmm_init+0x19a>
        intr_disable();
ffffffffc0202df0:	b0ffd0ef          	jal	ffffffffc02008fe <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202df4:	000b3783          	ld	a5,0(s6)
ffffffffc0202df8:	779c                	ld	a5,40(a5)
ffffffffc0202dfa:	9782                	jalr	a5
ffffffffc0202dfc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202dfe:	afbfd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202e02:	b6ad                	j	ffffffffc020296c <pmm_init+0x15c>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202e04:	6705                	lui	a4,0x1
ffffffffc0202e06:	177d                	addi	a4,a4,-1 # fff <_binary_obj___user_softint_out_size-0x80e9>
ffffffffc0202e08:	96ba                	add	a3,a3,a4
ffffffffc0202e0a:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc0202e0c:	00c7d713          	srli	a4,a5,0xc
ffffffffc0202e10:	14a77e63          	bgeu	a4,a0,ffffffffc0202f6c <pmm_init+0x75c>
    pmm_manager->init_memmap(base, n);
ffffffffc0202e14:	000b3683          	ld	a3,0(s6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202e18:	8c1d                	sub	s0,s0,a5
    return &pages[PPN(pa) - nbase];
ffffffffc0202e1a:	071a                	slli	a4,a4,0x6
ffffffffc0202e1c:	fe0007b7          	lui	a5,0xfe000
ffffffffc0202e20:	973e                	add	a4,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0202e22:	6a9c                	ld	a5,16(a3)
ffffffffc0202e24:	00c45593          	srli	a1,s0,0xc
ffffffffc0202e28:	00e60533          	add	a0,a2,a4
ffffffffc0202e2c:	9782                	jalr	a5
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202e2e:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202e32:	bcf1                	j	ffffffffc020290e <pmm_init+0xfe>
        intr_disable();
ffffffffc0202e34:	acbfd0ef          	jal	ffffffffc02008fe <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202e38:	000b3783          	ld	a5,0(s6)
ffffffffc0202e3c:	4505                	li	a0,1
ffffffffc0202e3e:	6f9c                	ld	a5,24(a5)
ffffffffc0202e40:	9782                	jalr	a5
ffffffffc0202e42:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202e44:	ab5fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202e48:	b119                	j	ffffffffc0202a4e <pmm_init+0x23e>
        intr_disable();
ffffffffc0202e4a:	ab5fd0ef          	jal	ffffffffc02008fe <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202e4e:	000b3783          	ld	a5,0(s6)
ffffffffc0202e52:	779c                	ld	a5,40(a5)
ffffffffc0202e54:	9782                	jalr	a5
ffffffffc0202e56:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202e58:	aa1fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202e5c:	b345                	j	ffffffffc0202bfc <pmm_init+0x3ec>
        intr_disable();
ffffffffc0202e5e:	aa1fd0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc0202e62:	000b3783          	ld	a5,0(s6)
ffffffffc0202e66:	779c                	ld	a5,40(a5)
ffffffffc0202e68:	9782                	jalr	a5
ffffffffc0202e6a:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202e6c:	a8dfd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202e70:	b3a5                	j	ffffffffc0202bd8 <pmm_init+0x3c8>
ffffffffc0202e72:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202e74:	a8bfd0ef          	jal	ffffffffc02008fe <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202e78:	000b3783          	ld	a5,0(s6)
ffffffffc0202e7c:	6522                	ld	a0,8(sp)
ffffffffc0202e7e:	4585                	li	a1,1
ffffffffc0202e80:	739c                	ld	a5,32(a5)
ffffffffc0202e82:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e84:	a75fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202e88:	bb05                	j	ffffffffc0202bb8 <pmm_init+0x3a8>
ffffffffc0202e8a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202e8c:	a73fd0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc0202e90:	000b3783          	ld	a5,0(s6)
ffffffffc0202e94:	6522                	ld	a0,8(sp)
ffffffffc0202e96:	4585                	li	a1,1
ffffffffc0202e98:	739c                	ld	a5,32(a5)
ffffffffc0202e9a:	9782                	jalr	a5
        intr_enable();
ffffffffc0202e9c:	a5dfd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202ea0:	b1e5                	j	ffffffffc0202b88 <pmm_init+0x378>
        intr_disable();
ffffffffc0202ea2:	a5dfd0ef          	jal	ffffffffc02008fe <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202ea6:	000b3783          	ld	a5,0(s6)
ffffffffc0202eaa:	4505                	li	a0,1
ffffffffc0202eac:	6f9c                	ld	a5,24(a5)
ffffffffc0202eae:	9782                	jalr	a5
ffffffffc0202eb0:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202eb2:	a47fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202eb6:	b375                	j	ffffffffc0202c62 <pmm_init+0x452>
        intr_disable();
ffffffffc0202eb8:	a47fd0ef          	jal	ffffffffc02008fe <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202ebc:	000b3783          	ld	a5,0(s6)
ffffffffc0202ec0:	779c                	ld	a5,40(a5)
ffffffffc0202ec2:	9782                	jalr	a5
ffffffffc0202ec4:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202ec6:	a33fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202eca:	b5c5                	j	ffffffffc0202daa <pmm_init+0x59a>
ffffffffc0202ecc:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202ece:	a31fd0ef          	jal	ffffffffc02008fe <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202ed2:	000b3783          	ld	a5,0(s6)
ffffffffc0202ed6:	6522                	ld	a0,8(sp)
ffffffffc0202ed8:	4585                	li	a1,1
ffffffffc0202eda:	739c                	ld	a5,32(a5)
ffffffffc0202edc:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ede:	a1bfd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202ee2:	b565                	j	ffffffffc0202d8a <pmm_init+0x57a>
ffffffffc0202ee4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202ee6:	a19fd0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc0202eea:	000b3783          	ld	a5,0(s6)
ffffffffc0202eee:	6522                	ld	a0,8(sp)
ffffffffc0202ef0:	4585                	li	a1,1
ffffffffc0202ef2:	739c                	ld	a5,32(a5)
ffffffffc0202ef4:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ef6:	a03fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202efa:	b585                	j	ffffffffc0202d5a <pmm_init+0x54a>
        intr_disable();
ffffffffc0202efc:	a03fd0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc0202f00:	000b3783          	ld	a5,0(s6)
ffffffffc0202f04:	8522                	mv	a0,s0
ffffffffc0202f06:	4585                	li	a1,1
ffffffffc0202f08:	739c                	ld	a5,32(a5)
ffffffffc0202f0a:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f0c:	9edfd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202f10:	bd29                	j	ffffffffc0202d2a <pmm_init+0x51a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202f12:	86a2                	mv	a3,s0
ffffffffc0202f14:	00004617          	auipc	a2,0x4
ffffffffc0202f18:	31460613          	addi	a2,a2,788 # ffffffffc0207228 <etext+0xd86>
ffffffffc0202f1c:	24f00593          	li	a1,591
ffffffffc0202f20:	00004517          	auipc	a0,0x4
ffffffffc0202f24:	3f850513          	addi	a0,a0,1016 # ffffffffc0207318 <etext+0xe76>
ffffffffc0202f28:	d22fd0ef          	jal	ffffffffc020044a <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202f2c:	00005697          	auipc	a3,0x5
ffffffffc0202f30:	8a468693          	addi	a3,a3,-1884 # ffffffffc02077d0 <etext+0x132e>
ffffffffc0202f34:	00004617          	auipc	a2,0x4
ffffffffc0202f38:	f4460613          	addi	a2,a2,-188 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0202f3c:	25000593          	li	a1,592
ffffffffc0202f40:	00004517          	auipc	a0,0x4
ffffffffc0202f44:	3d850513          	addi	a0,a0,984 # ffffffffc0207318 <etext+0xe76>
ffffffffc0202f48:	d02fd0ef          	jal	ffffffffc020044a <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202f4c:	00005697          	auipc	a3,0x5
ffffffffc0202f50:	84468693          	addi	a3,a3,-1980 # ffffffffc0207790 <etext+0x12ee>
ffffffffc0202f54:	00004617          	auipc	a2,0x4
ffffffffc0202f58:	f2460613          	addi	a2,a2,-220 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0202f5c:	24f00593          	li	a1,591
ffffffffc0202f60:	00004517          	auipc	a0,0x4
ffffffffc0202f64:	3b850513          	addi	a0,a0,952 # ffffffffc0207318 <etext+0xe76>
ffffffffc0202f68:	ce2fd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0202f6c:	deffe0ef          	jal	ffffffffc0201d5a <pa2page.part.0>
        panic("pte2page called with invalid pte");
ffffffffc0202f70:	00004617          	auipc	a2,0x4
ffffffffc0202f74:	40060613          	addi	a2,a2,1024 # ffffffffc0207370 <etext+0xece>
ffffffffc0202f78:	07f00593          	li	a1,127
ffffffffc0202f7c:	00004517          	auipc	a0,0x4
ffffffffc0202f80:	2d450513          	addi	a0,a0,724 # ffffffffc0207250 <etext+0xdae>
ffffffffc0202f84:	cc6fd0ef          	jal	ffffffffc020044a <__panic>
        panic("DTB memory info not available");
ffffffffc0202f88:	00004617          	auipc	a2,0x4
ffffffffc0202f8c:	44860613          	addi	a2,a2,1096 # ffffffffc02073d0 <etext+0xf2e>
ffffffffc0202f90:	06400593          	li	a1,100
ffffffffc0202f94:	00004517          	auipc	a0,0x4
ffffffffc0202f98:	38450513          	addi	a0,a0,900 # ffffffffc0207318 <etext+0xe76>
ffffffffc0202f9c:	caefd0ef          	jal	ffffffffc020044a <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0202fa0:	00004697          	auipc	a3,0x4
ffffffffc0202fa4:	7a868693          	addi	a3,a3,1960 # ffffffffc0207748 <etext+0x12a6>
ffffffffc0202fa8:	00004617          	auipc	a2,0x4
ffffffffc0202fac:	ed060613          	addi	a2,a2,-304 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0202fb0:	26a00593          	li	a1,618
ffffffffc0202fb4:	00004517          	auipc	a0,0x4
ffffffffc0202fb8:	36450513          	addi	a0,a0,868 # ffffffffc0207318 <etext+0xe76>
ffffffffc0202fbc:	c8efd0ef          	jal	ffffffffc020044a <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202fc0:	00004697          	auipc	a3,0x4
ffffffffc0202fc4:	4c868693          	addi	a3,a3,1224 # ffffffffc0207488 <etext+0xfe6>
ffffffffc0202fc8:	00004617          	auipc	a2,0x4
ffffffffc0202fcc:	eb060613          	addi	a2,a2,-336 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0202fd0:	21100593          	li	a1,529
ffffffffc0202fd4:	00004517          	auipc	a0,0x4
ffffffffc0202fd8:	34450513          	addi	a0,a0,836 # ffffffffc0207318 <etext+0xe76>
ffffffffc0202fdc:	c6efd0ef          	jal	ffffffffc020044a <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202fe0:	00004697          	auipc	a3,0x4
ffffffffc0202fe4:	48868693          	addi	a3,a3,1160 # ffffffffc0207468 <etext+0xfc6>
ffffffffc0202fe8:	00004617          	auipc	a2,0x4
ffffffffc0202fec:	e9060613          	addi	a2,a2,-368 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0202ff0:	21000593          	li	a1,528
ffffffffc0202ff4:	00004517          	auipc	a0,0x4
ffffffffc0202ff8:	32450513          	addi	a0,a0,804 # ffffffffc0207318 <etext+0xe76>
ffffffffc0202ffc:	c4efd0ef          	jal	ffffffffc020044a <__panic>
    return KADDR(page2pa(page));
ffffffffc0203000:	00004617          	auipc	a2,0x4
ffffffffc0203004:	22860613          	addi	a2,a2,552 # ffffffffc0207228 <etext+0xd86>
ffffffffc0203008:	07100593          	li	a1,113
ffffffffc020300c:	00004517          	auipc	a0,0x4
ffffffffc0203010:	24450513          	addi	a0,a0,580 # ffffffffc0207250 <etext+0xdae>
ffffffffc0203014:	c36fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0203018:	00004697          	auipc	a3,0x4
ffffffffc020301c:	70068693          	addi	a3,a3,1792 # ffffffffc0207718 <etext+0x1276>
ffffffffc0203020:	00004617          	auipc	a2,0x4
ffffffffc0203024:	e5860613          	addi	a2,a2,-424 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203028:	23800593          	li	a1,568
ffffffffc020302c:	00004517          	auipc	a0,0x4
ffffffffc0203030:	2ec50513          	addi	a0,a0,748 # ffffffffc0207318 <etext+0xe76>
ffffffffc0203034:	c16fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203038:	00004697          	auipc	a3,0x4
ffffffffc020303c:	69868693          	addi	a3,a3,1688 # ffffffffc02076d0 <etext+0x122e>
ffffffffc0203040:	00004617          	auipc	a2,0x4
ffffffffc0203044:	e3860613          	addi	a2,a2,-456 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203048:	23600593          	li	a1,566
ffffffffc020304c:	00004517          	auipc	a0,0x4
ffffffffc0203050:	2cc50513          	addi	a0,a0,716 # ffffffffc0207318 <etext+0xe76>
ffffffffc0203054:	bf6fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0203058:	00004697          	auipc	a3,0x4
ffffffffc020305c:	6a868693          	addi	a3,a3,1704 # ffffffffc0207700 <etext+0x125e>
ffffffffc0203060:	00004617          	auipc	a2,0x4
ffffffffc0203064:	e1860613          	addi	a2,a2,-488 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203068:	23500593          	li	a1,565
ffffffffc020306c:	00004517          	auipc	a0,0x4
ffffffffc0203070:	2ac50513          	addi	a0,a0,684 # ffffffffc0207318 <etext+0xe76>
ffffffffc0203074:	bd6fd0ef          	jal	ffffffffc020044a <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc0203078:	00004697          	auipc	a3,0x4
ffffffffc020307c:	77068693          	addi	a3,a3,1904 # ffffffffc02077e8 <etext+0x1346>
ffffffffc0203080:	00004617          	auipc	a2,0x4
ffffffffc0203084:	df860613          	addi	a2,a2,-520 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203088:	25300593          	li	a1,595
ffffffffc020308c:	00004517          	auipc	a0,0x4
ffffffffc0203090:	28c50513          	addi	a0,a0,652 # ffffffffc0207318 <etext+0xe76>
ffffffffc0203094:	bb6fd0ef          	jal	ffffffffc020044a <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0203098:	00004697          	auipc	a3,0x4
ffffffffc020309c:	6b068693          	addi	a3,a3,1712 # ffffffffc0207748 <etext+0x12a6>
ffffffffc02030a0:	00004617          	auipc	a2,0x4
ffffffffc02030a4:	dd860613          	addi	a2,a2,-552 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02030a8:	24000593          	li	a1,576
ffffffffc02030ac:	00004517          	auipc	a0,0x4
ffffffffc02030b0:	26c50513          	addi	a0,a0,620 # ffffffffc0207318 <etext+0xe76>
ffffffffc02030b4:	b96fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p) == 1);
ffffffffc02030b8:	00004697          	auipc	a3,0x4
ffffffffc02030bc:	78868693          	addi	a3,a3,1928 # ffffffffc0207840 <etext+0x139e>
ffffffffc02030c0:	00004617          	auipc	a2,0x4
ffffffffc02030c4:	db860613          	addi	a2,a2,-584 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02030c8:	25800593          	li	a1,600
ffffffffc02030cc:	00004517          	auipc	a0,0x4
ffffffffc02030d0:	24c50513          	addi	a0,a0,588 # ffffffffc0207318 <etext+0xe76>
ffffffffc02030d4:	b76fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc02030d8:	00004697          	auipc	a3,0x4
ffffffffc02030dc:	72868693          	addi	a3,a3,1832 # ffffffffc0207800 <etext+0x135e>
ffffffffc02030e0:	00004617          	auipc	a2,0x4
ffffffffc02030e4:	d9860613          	addi	a2,a2,-616 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02030e8:	25700593          	li	a1,599
ffffffffc02030ec:	00004517          	auipc	a0,0x4
ffffffffc02030f0:	22c50513          	addi	a0,a0,556 # ffffffffc0207318 <etext+0xe76>
ffffffffc02030f4:	b56fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02030f8:	00004697          	auipc	a3,0x4
ffffffffc02030fc:	5d868693          	addi	a3,a3,1496 # ffffffffc02076d0 <etext+0x122e>
ffffffffc0203100:	00004617          	auipc	a2,0x4
ffffffffc0203104:	d7860613          	addi	a2,a2,-648 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203108:	23200593          	li	a1,562
ffffffffc020310c:	00004517          	auipc	a0,0x4
ffffffffc0203110:	20c50513          	addi	a0,a0,524 # ffffffffc0207318 <etext+0xe76>
ffffffffc0203114:	b36fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203118:	00004697          	auipc	a3,0x4
ffffffffc020311c:	45868693          	addi	a3,a3,1112 # ffffffffc0207570 <etext+0x10ce>
ffffffffc0203120:	00004617          	auipc	a2,0x4
ffffffffc0203124:	d5860613          	addi	a2,a2,-680 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203128:	23100593          	li	a1,561
ffffffffc020312c:	00004517          	auipc	a0,0x4
ffffffffc0203130:	1ec50513          	addi	a0,a0,492 # ffffffffc0207318 <etext+0xe76>
ffffffffc0203134:	b16fd0ef          	jal	ffffffffc020044a <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203138:	00004697          	auipc	a3,0x4
ffffffffc020313c:	5b068693          	addi	a3,a3,1456 # ffffffffc02076e8 <etext+0x1246>
ffffffffc0203140:	00004617          	auipc	a2,0x4
ffffffffc0203144:	d3860613          	addi	a2,a2,-712 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203148:	22e00593          	li	a1,558
ffffffffc020314c:	00004517          	auipc	a0,0x4
ffffffffc0203150:	1cc50513          	addi	a0,a0,460 # ffffffffc0207318 <etext+0xe76>
ffffffffc0203154:	af6fd0ef          	jal	ffffffffc020044a <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203158:	00004697          	auipc	a3,0x4
ffffffffc020315c:	40068693          	addi	a3,a3,1024 # ffffffffc0207558 <etext+0x10b6>
ffffffffc0203160:	00004617          	auipc	a2,0x4
ffffffffc0203164:	d1860613          	addi	a2,a2,-744 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203168:	22d00593          	li	a1,557
ffffffffc020316c:	00004517          	auipc	a0,0x4
ffffffffc0203170:	1ac50513          	addi	a0,a0,428 # ffffffffc0207318 <etext+0xe76>
ffffffffc0203174:	ad6fd0ef          	jal	ffffffffc020044a <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0203178:	00004697          	auipc	a3,0x4
ffffffffc020317c:	48068693          	addi	a3,a3,1152 # ffffffffc02075f8 <etext+0x1156>
ffffffffc0203180:	00004617          	auipc	a2,0x4
ffffffffc0203184:	cf860613          	addi	a2,a2,-776 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203188:	22c00593          	li	a1,556
ffffffffc020318c:	00004517          	auipc	a0,0x4
ffffffffc0203190:	18c50513          	addi	a0,a0,396 # ffffffffc0207318 <etext+0xe76>
ffffffffc0203194:	ab6fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203198:	00004697          	auipc	a3,0x4
ffffffffc020319c:	53868693          	addi	a3,a3,1336 # ffffffffc02076d0 <etext+0x122e>
ffffffffc02031a0:	00004617          	auipc	a2,0x4
ffffffffc02031a4:	cd860613          	addi	a2,a2,-808 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02031a8:	22b00593          	li	a1,555
ffffffffc02031ac:	00004517          	auipc	a0,0x4
ffffffffc02031b0:	16c50513          	addi	a0,a0,364 # ffffffffc0207318 <etext+0xe76>
ffffffffc02031b4:	a96fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02031b8:	00004697          	auipc	a3,0x4
ffffffffc02031bc:	50068693          	addi	a3,a3,1280 # ffffffffc02076b8 <etext+0x1216>
ffffffffc02031c0:	00004617          	auipc	a2,0x4
ffffffffc02031c4:	cb860613          	addi	a2,a2,-840 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02031c8:	22a00593          	li	a1,554
ffffffffc02031cc:	00004517          	auipc	a0,0x4
ffffffffc02031d0:	14c50513          	addi	a0,a0,332 # ffffffffc0207318 <etext+0xe76>
ffffffffc02031d4:	a76fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc02031d8:	00004697          	auipc	a3,0x4
ffffffffc02031dc:	4b068693          	addi	a3,a3,1200 # ffffffffc0207688 <etext+0x11e6>
ffffffffc02031e0:	00004617          	auipc	a2,0x4
ffffffffc02031e4:	c9860613          	addi	a2,a2,-872 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02031e8:	22900593          	li	a1,553
ffffffffc02031ec:	00004517          	auipc	a0,0x4
ffffffffc02031f0:	12c50513          	addi	a0,a0,300 # ffffffffc0207318 <etext+0xe76>
ffffffffc02031f4:	a56fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p2) == 1);
ffffffffc02031f8:	00004697          	auipc	a3,0x4
ffffffffc02031fc:	47868693          	addi	a3,a3,1144 # ffffffffc0207670 <etext+0x11ce>
ffffffffc0203200:	00004617          	auipc	a2,0x4
ffffffffc0203204:	c7860613          	addi	a2,a2,-904 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203208:	22700593          	li	a1,551
ffffffffc020320c:	00004517          	auipc	a0,0x4
ffffffffc0203210:	10c50513          	addi	a0,a0,268 # ffffffffc0207318 <etext+0xe76>
ffffffffc0203214:	a36fd0ef          	jal	ffffffffc020044a <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0203218:	00004697          	auipc	a3,0x4
ffffffffc020321c:	43868693          	addi	a3,a3,1080 # ffffffffc0207650 <etext+0x11ae>
ffffffffc0203220:	00004617          	auipc	a2,0x4
ffffffffc0203224:	c5860613          	addi	a2,a2,-936 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203228:	22600593          	li	a1,550
ffffffffc020322c:	00004517          	auipc	a0,0x4
ffffffffc0203230:	0ec50513          	addi	a0,a0,236 # ffffffffc0207318 <etext+0xe76>
ffffffffc0203234:	a16fd0ef          	jal	ffffffffc020044a <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203238:	00004697          	auipc	a3,0x4
ffffffffc020323c:	40868693          	addi	a3,a3,1032 # ffffffffc0207640 <etext+0x119e>
ffffffffc0203240:	00004617          	auipc	a2,0x4
ffffffffc0203244:	c3860613          	addi	a2,a2,-968 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203248:	22500593          	li	a1,549
ffffffffc020324c:	00004517          	auipc	a0,0x4
ffffffffc0203250:	0cc50513          	addi	a0,a0,204 # ffffffffc0207318 <etext+0xe76>
ffffffffc0203254:	9f6fd0ef          	jal	ffffffffc020044a <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203258:	00004697          	auipc	a3,0x4
ffffffffc020325c:	3d868693          	addi	a3,a3,984 # ffffffffc0207630 <etext+0x118e>
ffffffffc0203260:	00004617          	auipc	a2,0x4
ffffffffc0203264:	c1860613          	addi	a2,a2,-1000 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203268:	22400593          	li	a1,548
ffffffffc020326c:	00004517          	auipc	a0,0x4
ffffffffc0203270:	0ac50513          	addi	a0,a0,172 # ffffffffc0207318 <etext+0xe76>
ffffffffc0203274:	9d6fd0ef          	jal	ffffffffc020044a <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0203278:	00004617          	auipc	a2,0x4
ffffffffc020327c:	05860613          	addi	a2,a2,88 # ffffffffc02072d0 <etext+0xe2e>
ffffffffc0203280:	08000593          	li	a1,128
ffffffffc0203284:	00004517          	auipc	a0,0x4
ffffffffc0203288:	09450513          	addi	a0,a0,148 # ffffffffc0207318 <etext+0xe76>
ffffffffc020328c:	9befd0ef          	jal	ffffffffc020044a <__panic>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0203290:	00004697          	auipc	a3,0x4
ffffffffc0203294:	2f868693          	addi	a3,a3,760 # ffffffffc0207588 <etext+0x10e6>
ffffffffc0203298:	00004617          	auipc	a2,0x4
ffffffffc020329c:	be060613          	addi	a2,a2,-1056 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02032a0:	21f00593          	li	a1,543
ffffffffc02032a4:	00004517          	auipc	a0,0x4
ffffffffc02032a8:	07450513          	addi	a0,a0,116 # ffffffffc0207318 <etext+0xe76>
ffffffffc02032ac:	99efd0ef          	jal	ffffffffc020044a <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02032b0:	00004697          	auipc	a3,0x4
ffffffffc02032b4:	34868693          	addi	a3,a3,840 # ffffffffc02075f8 <etext+0x1156>
ffffffffc02032b8:	00004617          	auipc	a2,0x4
ffffffffc02032bc:	bc060613          	addi	a2,a2,-1088 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02032c0:	22300593          	li	a1,547
ffffffffc02032c4:	00004517          	auipc	a0,0x4
ffffffffc02032c8:	05450513          	addi	a0,a0,84 # ffffffffc0207318 <etext+0xe76>
ffffffffc02032cc:	97efd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc02032d0:	00004697          	auipc	a3,0x4
ffffffffc02032d4:	2e868693          	addi	a3,a3,744 # ffffffffc02075b8 <etext+0x1116>
ffffffffc02032d8:	00004617          	auipc	a2,0x4
ffffffffc02032dc:	ba060613          	addi	a2,a2,-1120 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02032e0:	22200593          	li	a1,546
ffffffffc02032e4:	00004517          	auipc	a0,0x4
ffffffffc02032e8:	03450513          	addi	a0,a0,52 # ffffffffc0207318 <etext+0xe76>
ffffffffc02032ec:	95efd0ef          	jal	ffffffffc020044a <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc02032f0:	86d6                	mv	a3,s5
ffffffffc02032f2:	00004617          	auipc	a2,0x4
ffffffffc02032f6:	f3660613          	addi	a2,a2,-202 # ffffffffc0207228 <etext+0xd86>
ffffffffc02032fa:	21e00593          	li	a1,542
ffffffffc02032fe:	00004517          	auipc	a0,0x4
ffffffffc0203302:	01a50513          	addi	a0,a0,26 # ffffffffc0207318 <etext+0xe76>
ffffffffc0203306:	944fd0ef          	jal	ffffffffc020044a <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc020330a:	00004617          	auipc	a2,0x4
ffffffffc020330e:	f1e60613          	addi	a2,a2,-226 # ffffffffc0207228 <etext+0xd86>
ffffffffc0203312:	21d00593          	li	a1,541
ffffffffc0203316:	00004517          	auipc	a0,0x4
ffffffffc020331a:	00250513          	addi	a0,a0,2 # ffffffffc0207318 <etext+0xe76>
ffffffffc020331e:	92cfd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203322:	00004697          	auipc	a3,0x4
ffffffffc0203326:	24e68693          	addi	a3,a3,590 # ffffffffc0207570 <etext+0x10ce>
ffffffffc020332a:	00004617          	auipc	a2,0x4
ffffffffc020332e:	b4e60613          	addi	a2,a2,-1202 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203332:	21b00593          	li	a1,539
ffffffffc0203336:	00004517          	auipc	a0,0x4
ffffffffc020333a:	fe250513          	addi	a0,a0,-30 # ffffffffc0207318 <etext+0xe76>
ffffffffc020333e:	90cfd0ef          	jal	ffffffffc020044a <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203342:	00004697          	auipc	a3,0x4
ffffffffc0203346:	21668693          	addi	a3,a3,534 # ffffffffc0207558 <etext+0x10b6>
ffffffffc020334a:	00004617          	auipc	a2,0x4
ffffffffc020334e:	b2e60613          	addi	a2,a2,-1234 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203352:	21a00593          	li	a1,538
ffffffffc0203356:	00004517          	auipc	a0,0x4
ffffffffc020335a:	fc250513          	addi	a0,a0,-62 # ffffffffc0207318 <etext+0xe76>
ffffffffc020335e:	8ecfd0ef          	jal	ffffffffc020044a <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0203362:	00004697          	auipc	a3,0x4
ffffffffc0203366:	5a668693          	addi	a3,a3,1446 # ffffffffc0207908 <etext+0x1466>
ffffffffc020336a:	00004617          	auipc	a2,0x4
ffffffffc020336e:	b0e60613          	addi	a2,a2,-1266 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203372:	26100593          	li	a1,609
ffffffffc0203376:	00004517          	auipc	a0,0x4
ffffffffc020337a:	fa250513          	addi	a0,a0,-94 # ffffffffc0207318 <etext+0xe76>
ffffffffc020337e:	8ccfd0ef          	jal	ffffffffc020044a <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0203382:	00004697          	auipc	a3,0x4
ffffffffc0203386:	54e68693          	addi	a3,a3,1358 # ffffffffc02078d0 <etext+0x142e>
ffffffffc020338a:	00004617          	auipc	a2,0x4
ffffffffc020338e:	aee60613          	addi	a2,a2,-1298 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203392:	25e00593          	li	a1,606
ffffffffc0203396:	00004517          	auipc	a0,0x4
ffffffffc020339a:	f8250513          	addi	a0,a0,-126 # ffffffffc0207318 <etext+0xe76>
ffffffffc020339e:	8acfd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p) == 2);
ffffffffc02033a2:	00004697          	auipc	a3,0x4
ffffffffc02033a6:	4fe68693          	addi	a3,a3,1278 # ffffffffc02078a0 <etext+0x13fe>
ffffffffc02033aa:	00004617          	auipc	a2,0x4
ffffffffc02033ae:	ace60613          	addi	a2,a2,-1330 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02033b2:	25a00593          	li	a1,602
ffffffffc02033b6:	00004517          	auipc	a0,0x4
ffffffffc02033ba:	f6250513          	addi	a0,a0,-158 # ffffffffc0207318 <etext+0xe76>
ffffffffc02033be:	88cfd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02033c2:	00004697          	auipc	a3,0x4
ffffffffc02033c6:	49668693          	addi	a3,a3,1174 # ffffffffc0207858 <etext+0x13b6>
ffffffffc02033ca:	00004617          	auipc	a2,0x4
ffffffffc02033ce:	aae60613          	addi	a2,a2,-1362 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02033d2:	25900593          	li	a1,601
ffffffffc02033d6:	00004517          	auipc	a0,0x4
ffffffffc02033da:	f4250513          	addi	a0,a0,-190 # ffffffffc0207318 <etext+0xe76>
ffffffffc02033de:	86cfd0ef          	jal	ffffffffc020044a <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc02033e2:	00004697          	auipc	a3,0x4
ffffffffc02033e6:	0e668693          	addi	a3,a3,230 # ffffffffc02074c8 <etext+0x1026>
ffffffffc02033ea:	00004617          	auipc	a2,0x4
ffffffffc02033ee:	a8e60613          	addi	a2,a2,-1394 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02033f2:	21200593          	li	a1,530
ffffffffc02033f6:	00004517          	auipc	a0,0x4
ffffffffc02033fa:	f2250513          	addi	a0,a0,-222 # ffffffffc0207318 <etext+0xe76>
ffffffffc02033fe:	84cfd0ef          	jal	ffffffffc020044a <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0203402:	00004617          	auipc	a2,0x4
ffffffffc0203406:	ece60613          	addi	a2,a2,-306 # ffffffffc02072d0 <etext+0xe2e>
ffffffffc020340a:	0c800593          	li	a1,200
ffffffffc020340e:	00004517          	auipc	a0,0x4
ffffffffc0203412:	f0a50513          	addi	a0,a0,-246 # ffffffffc0207318 <etext+0xe76>
ffffffffc0203416:	834fd0ef          	jal	ffffffffc020044a <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc020341a:	00004697          	auipc	a3,0x4
ffffffffc020341e:	10e68693          	addi	a3,a3,270 # ffffffffc0207528 <etext+0x1086>
ffffffffc0203422:	00004617          	auipc	a2,0x4
ffffffffc0203426:	a5660613          	addi	a2,a2,-1450 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc020342a:	21900593          	li	a1,537
ffffffffc020342e:	00004517          	auipc	a0,0x4
ffffffffc0203432:	eea50513          	addi	a0,a0,-278 # ffffffffc0207318 <etext+0xe76>
ffffffffc0203436:	814fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc020343a:	00004697          	auipc	a3,0x4
ffffffffc020343e:	0be68693          	addi	a3,a3,190 # ffffffffc02074f8 <etext+0x1056>
ffffffffc0203442:	00004617          	auipc	a2,0x4
ffffffffc0203446:	a3660613          	addi	a2,a2,-1482 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc020344a:	21600593          	li	a1,534
ffffffffc020344e:	00004517          	auipc	a0,0x4
ffffffffc0203452:	eca50513          	addi	a0,a0,-310 # ffffffffc0207318 <etext+0xe76>
ffffffffc0203456:	ff5fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020345a <pgdir_alloc_page>:
{
ffffffffc020345a:	7139                	addi	sp,sp,-64
ffffffffc020345c:	f426                	sd	s1,40(sp)
ffffffffc020345e:	f04a                	sd	s2,32(sp)
ffffffffc0203460:	ec4e                	sd	s3,24(sp)
ffffffffc0203462:	fc06                	sd	ra,56(sp)
ffffffffc0203464:	f822                	sd	s0,48(sp)
ffffffffc0203466:	892a                	mv	s2,a0
ffffffffc0203468:	84ae                	mv	s1,a1
ffffffffc020346a:	89b2                	mv	s3,a2
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020346c:	100027f3          	csrr	a5,sstatus
ffffffffc0203470:	8b89                	andi	a5,a5,2
ffffffffc0203472:	ebb5                	bnez	a5,ffffffffc02034e6 <pgdir_alloc_page+0x8c>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203474:	000c9417          	auipc	s0,0xc9
ffffffffc0203478:	ea440413          	addi	s0,s0,-348 # ffffffffc02cc318 <pmm_manager>
ffffffffc020347c:	601c                	ld	a5,0(s0)
ffffffffc020347e:	4505                	li	a0,1
ffffffffc0203480:	6f9c                	ld	a5,24(a5)
ffffffffc0203482:	9782                	jalr	a5
ffffffffc0203484:	85aa                	mv	a1,a0
    if (page != NULL)
ffffffffc0203486:	c5b9                	beqz	a1,ffffffffc02034d4 <pgdir_alloc_page+0x7a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc0203488:	86ce                	mv	a3,s3
ffffffffc020348a:	854a                	mv	a0,s2
ffffffffc020348c:	8626                	mv	a2,s1
ffffffffc020348e:	e42e                	sd	a1,8(sp)
ffffffffc0203490:	a8aff0ef          	jal	ffffffffc020271a <page_insert>
ffffffffc0203494:	65a2                	ld	a1,8(sp)
ffffffffc0203496:	e515                	bnez	a0,ffffffffc02034c2 <pgdir_alloc_page+0x68>
        assert(page_ref(page) == 1);
ffffffffc0203498:	4198                	lw	a4,0(a1)
        page->pra_vaddr = la;
ffffffffc020349a:	fd84                	sd	s1,56(a1)
        assert(page_ref(page) == 1);
ffffffffc020349c:	4785                	li	a5,1
ffffffffc020349e:	02f70c63          	beq	a4,a5,ffffffffc02034d6 <pgdir_alloc_page+0x7c>
ffffffffc02034a2:	00004697          	auipc	a3,0x4
ffffffffc02034a6:	4ae68693          	addi	a3,a3,1198 # ffffffffc0207950 <etext+0x14ae>
ffffffffc02034aa:	00004617          	auipc	a2,0x4
ffffffffc02034ae:	9ce60613          	addi	a2,a2,-1586 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02034b2:	1f700593          	li	a1,503
ffffffffc02034b6:	00004517          	auipc	a0,0x4
ffffffffc02034ba:	e6250513          	addi	a0,a0,-414 # ffffffffc0207318 <etext+0xe76>
ffffffffc02034be:	f8dfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02034c2:	100027f3          	csrr	a5,sstatus
ffffffffc02034c6:	8b89                	andi	a5,a5,2
ffffffffc02034c8:	ef95                	bnez	a5,ffffffffc0203504 <pgdir_alloc_page+0xaa>
        pmm_manager->free_pages(base, n);
ffffffffc02034ca:	601c                	ld	a5,0(s0)
ffffffffc02034cc:	852e                	mv	a0,a1
ffffffffc02034ce:	4585                	li	a1,1
ffffffffc02034d0:	739c                	ld	a5,32(a5)
ffffffffc02034d2:	9782                	jalr	a5
            return NULL;
ffffffffc02034d4:	4581                	li	a1,0
}
ffffffffc02034d6:	70e2                	ld	ra,56(sp)
ffffffffc02034d8:	7442                	ld	s0,48(sp)
ffffffffc02034da:	74a2                	ld	s1,40(sp)
ffffffffc02034dc:	7902                	ld	s2,32(sp)
ffffffffc02034de:	69e2                	ld	s3,24(sp)
ffffffffc02034e0:	852e                	mv	a0,a1
ffffffffc02034e2:	6121                	addi	sp,sp,64
ffffffffc02034e4:	8082                	ret
        intr_disable();
ffffffffc02034e6:	c18fd0ef          	jal	ffffffffc02008fe <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02034ea:	000c9417          	auipc	s0,0xc9
ffffffffc02034ee:	e2e40413          	addi	s0,s0,-466 # ffffffffc02cc318 <pmm_manager>
ffffffffc02034f2:	601c                	ld	a5,0(s0)
ffffffffc02034f4:	4505                	li	a0,1
ffffffffc02034f6:	6f9c                	ld	a5,24(a5)
ffffffffc02034f8:	9782                	jalr	a5
ffffffffc02034fa:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02034fc:	bfcfd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0203500:	65a2                	ld	a1,8(sp)
ffffffffc0203502:	b751                	j	ffffffffc0203486 <pgdir_alloc_page+0x2c>
        intr_disable();
ffffffffc0203504:	bfafd0ef          	jal	ffffffffc02008fe <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203508:	601c                	ld	a5,0(s0)
ffffffffc020350a:	6522                	ld	a0,8(sp)
ffffffffc020350c:	4585                	li	a1,1
ffffffffc020350e:	739c                	ld	a5,32(a5)
ffffffffc0203510:	9782                	jalr	a5
        intr_enable();
ffffffffc0203512:	be6fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0203516:	bf7d                	j	ffffffffc02034d4 <pgdir_alloc_page+0x7a>

ffffffffc0203518 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0203518:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020351a:	00004697          	auipc	a3,0x4
ffffffffc020351e:	44e68693          	addi	a3,a3,1102 # ffffffffc0207968 <etext+0x14c6>
ffffffffc0203522:	00004617          	auipc	a2,0x4
ffffffffc0203526:	95660613          	addi	a2,a2,-1706 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc020352a:	07400593          	li	a1,116
ffffffffc020352e:	00004517          	auipc	a0,0x4
ffffffffc0203532:	45a50513          	addi	a0,a0,1114 # ffffffffc0207988 <etext+0x14e6>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0203536:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc0203538:	f13fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020353c <mm_create>:
{
ffffffffc020353c:	1101                	addi	sp,sp,-32
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc020353e:	05800513          	li	a0,88
{
ffffffffc0203542:	ec06                	sd	ra,24(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203544:	e70fe0ef          	jal	ffffffffc0201bb4 <kmalloc>
ffffffffc0203548:	87aa                	mv	a5,a0
    if (mm != NULL)
ffffffffc020354a:	c505                	beqz	a0,ffffffffc0203572 <mm_create+0x36>
    elm->prev = elm->next = elm;
ffffffffc020354c:	e788                	sd	a0,8(a5)
ffffffffc020354e:	e388                	sd	a0,0(a5)
        mm->mmap_cache = NULL;
ffffffffc0203550:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203554:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203558:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc020355c:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc0203560:	02052823          	sw	zero,48(a0)
        sem_init(&(mm->mm_sem), 1);
ffffffffc0203564:	4585                	li	a1,1
ffffffffc0203566:	03850513          	addi	a0,a0,56
ffffffffc020356a:	e43e                	sd	a5,8(sp)
ffffffffc020356c:	70f000ef          	jal	ffffffffc020447a <sem_init>
ffffffffc0203570:	67a2                	ld	a5,8(sp)
}
ffffffffc0203572:	60e2                	ld	ra,24(sp)
ffffffffc0203574:	853e                	mv	a0,a5
ffffffffc0203576:	6105                	addi	sp,sp,32
ffffffffc0203578:	8082                	ret

ffffffffc020357a <find_vma>:
    if (mm != NULL)
ffffffffc020357a:	c505                	beqz	a0,ffffffffc02035a2 <find_vma+0x28>
        vma = mm->mmap_cache;
ffffffffc020357c:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc020357e:	c781                	beqz	a5,ffffffffc0203586 <find_vma+0xc>
ffffffffc0203580:	6798                	ld	a4,8(a5)
ffffffffc0203582:	02e5f363          	bgeu	a1,a4,ffffffffc02035a8 <find_vma+0x2e>
    return listelm->next;
ffffffffc0203586:	651c                	ld	a5,8(a0)
            while ((le = list_next(le)) != list)
ffffffffc0203588:	00f50d63          	beq	a0,a5,ffffffffc02035a2 <find_vma+0x28>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc020358c:	fe87b703          	ld	a4,-24(a5) # fffffffffdffffe8 <end+0x3dd33c70>
ffffffffc0203590:	00e5e663          	bltu	a1,a4,ffffffffc020359c <find_vma+0x22>
ffffffffc0203594:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203598:	00e5ee63          	bltu	a1,a4,ffffffffc02035b4 <find_vma+0x3a>
ffffffffc020359c:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc020359e:	fef517e3          	bne	a0,a5,ffffffffc020358c <find_vma+0x12>
    struct vma_struct *vma = NULL;
ffffffffc02035a2:	4781                	li	a5,0
}
ffffffffc02035a4:	853e                	mv	a0,a5
ffffffffc02035a6:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc02035a8:	6b98                	ld	a4,16(a5)
ffffffffc02035aa:	fce5fee3          	bgeu	a1,a4,ffffffffc0203586 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc02035ae:	e91c                	sd	a5,16(a0)
}
ffffffffc02035b0:	853e                	mv	a0,a5
ffffffffc02035b2:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc02035b4:	1781                	addi	a5,a5,-32
            mm->mmap_cache = vma;
ffffffffc02035b6:	e91c                	sd	a5,16(a0)
ffffffffc02035b8:	bfe5                	j	ffffffffc02035b0 <find_vma+0x36>

ffffffffc02035ba <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc02035ba:	6590                	ld	a2,8(a1)
ffffffffc02035bc:	0105b803          	ld	a6,16(a1)
{
ffffffffc02035c0:	1141                	addi	sp,sp,-16
ffffffffc02035c2:	e406                	sd	ra,8(sp)
ffffffffc02035c4:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc02035c6:	01066763          	bltu	a2,a6,ffffffffc02035d4 <insert_vma_struct+0x1a>
ffffffffc02035ca:	a8b9                	j	ffffffffc0203628 <insert_vma_struct+0x6e>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc02035cc:	fe87b703          	ld	a4,-24(a5)
ffffffffc02035d0:	04e66763          	bltu	a2,a4,ffffffffc020361e <insert_vma_struct+0x64>
ffffffffc02035d4:	86be                	mv	a3,a5
ffffffffc02035d6:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc02035d8:	fef51ae3          	bne	a0,a5,ffffffffc02035cc <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc02035dc:	02a68463          	beq	a3,a0,ffffffffc0203604 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc02035e0:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc02035e4:	fe86b883          	ld	a7,-24(a3)
ffffffffc02035e8:	08e8f063          	bgeu	a7,a4,ffffffffc0203668 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02035ec:	04e66e63          	bltu	a2,a4,ffffffffc0203648 <insert_vma_struct+0x8e>
    }
    if (le_next != list)
ffffffffc02035f0:	00f50a63          	beq	a0,a5,ffffffffc0203604 <insert_vma_struct+0x4a>
ffffffffc02035f4:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc02035f8:	05076863          	bltu	a4,a6,ffffffffc0203648 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc02035fc:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203600:	02c77263          	bgeu	a4,a2,ffffffffc0203624 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc0203604:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0203606:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203608:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc020360c:	e390                	sd	a2,0(a5)
ffffffffc020360e:	e690                	sd	a2,8(a3)
}
ffffffffc0203610:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0203612:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203614:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc0203616:	2705                	addiw	a4,a4,1
ffffffffc0203618:	d118                	sw	a4,32(a0)
}
ffffffffc020361a:	0141                	addi	sp,sp,16
ffffffffc020361c:	8082                	ret
    if (le_prev != list)
ffffffffc020361e:	fca691e3          	bne	a3,a0,ffffffffc02035e0 <insert_vma_struct+0x26>
ffffffffc0203622:	bfd9                	j	ffffffffc02035f8 <insert_vma_struct+0x3e>
ffffffffc0203624:	ef5ff0ef          	jal	ffffffffc0203518 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203628:	00004697          	auipc	a3,0x4
ffffffffc020362c:	37068693          	addi	a3,a3,880 # ffffffffc0207998 <etext+0x14f6>
ffffffffc0203630:	00004617          	auipc	a2,0x4
ffffffffc0203634:	84860613          	addi	a2,a2,-1976 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203638:	07a00593          	li	a1,122
ffffffffc020363c:	00004517          	auipc	a0,0x4
ffffffffc0203640:	34c50513          	addi	a0,a0,844 # ffffffffc0207988 <etext+0x14e6>
ffffffffc0203644:	e07fc0ef          	jal	ffffffffc020044a <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203648:	00004697          	auipc	a3,0x4
ffffffffc020364c:	39068693          	addi	a3,a3,912 # ffffffffc02079d8 <etext+0x1536>
ffffffffc0203650:	00004617          	auipc	a2,0x4
ffffffffc0203654:	82860613          	addi	a2,a2,-2008 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203658:	07300593          	li	a1,115
ffffffffc020365c:	00004517          	auipc	a0,0x4
ffffffffc0203660:	32c50513          	addi	a0,a0,812 # ffffffffc0207988 <etext+0x14e6>
ffffffffc0203664:	de7fc0ef          	jal	ffffffffc020044a <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203668:	00004697          	auipc	a3,0x4
ffffffffc020366c:	35068693          	addi	a3,a3,848 # ffffffffc02079b8 <etext+0x1516>
ffffffffc0203670:	00004617          	auipc	a2,0x4
ffffffffc0203674:	80860613          	addi	a2,a2,-2040 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203678:	07200593          	li	a1,114
ffffffffc020367c:	00004517          	auipc	a0,0x4
ffffffffc0203680:	30c50513          	addi	a0,a0,780 # ffffffffc0207988 <etext+0x14e6>
ffffffffc0203684:	dc7fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0203688 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc0203688:	591c                	lw	a5,48(a0)
{
ffffffffc020368a:	1141                	addi	sp,sp,-16
ffffffffc020368c:	e406                	sd	ra,8(sp)
ffffffffc020368e:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc0203690:	e78d                	bnez	a5,ffffffffc02036ba <mm_destroy+0x32>
ffffffffc0203692:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203694:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc0203696:	00a40c63          	beq	s0,a0,ffffffffc02036ae <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc020369a:	6118                	ld	a4,0(a0)
ffffffffc020369c:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc020369e:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02036a0:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02036a2:	e398                	sd	a4,0(a5)
ffffffffc02036a4:	db6fe0ef          	jal	ffffffffc0201c5a <kfree>
    return listelm->next;
ffffffffc02036a8:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc02036aa:	fea418e3          	bne	s0,a0,ffffffffc020369a <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc02036ae:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc02036b0:	6402                	ld	s0,0(sp)
ffffffffc02036b2:	60a2                	ld	ra,8(sp)
ffffffffc02036b4:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc02036b6:	da4fe06f          	j	ffffffffc0201c5a <kfree>
    assert(mm_count(mm) == 0);
ffffffffc02036ba:	00004697          	auipc	a3,0x4
ffffffffc02036be:	33e68693          	addi	a3,a3,830 # ffffffffc02079f8 <etext+0x1556>
ffffffffc02036c2:	00003617          	auipc	a2,0x3
ffffffffc02036c6:	7b660613          	addi	a2,a2,1974 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02036ca:	09e00593          	li	a1,158
ffffffffc02036ce:	00004517          	auipc	a0,0x4
ffffffffc02036d2:	2ba50513          	addi	a0,a0,698 # ffffffffc0207988 <etext+0x14e6>
ffffffffc02036d6:	d75fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02036da <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02036da:	6785                	lui	a5,0x1
ffffffffc02036dc:	17fd                	addi	a5,a5,-1 # fff <_binary_obj___user_softint_out_size-0x80e9>
ffffffffc02036de:	963e                	add	a2,a2,a5
    if (!USER_ACCESS(start, end))
ffffffffc02036e0:	4785                	li	a5,1
{
ffffffffc02036e2:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02036e4:	962e                	add	a2,a2,a1
ffffffffc02036e6:	787d                	lui	a6,0xfffff
    if (!USER_ACCESS(start, end))
ffffffffc02036e8:	07fe                	slli	a5,a5,0x1f
{
ffffffffc02036ea:	f822                	sd	s0,48(sp)
ffffffffc02036ec:	f426                	sd	s1,40(sp)
ffffffffc02036ee:	01067433          	and	s0,a2,a6
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc02036f2:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end))
ffffffffc02036f6:	0785                	addi	a5,a5,1
ffffffffc02036f8:	0084b633          	sltu	a2,s1,s0
ffffffffc02036fc:	00f437b3          	sltu	a5,s0,a5
ffffffffc0203700:	00163613          	seqz	a2,a2
ffffffffc0203704:	0017b793          	seqz	a5,a5
{
ffffffffc0203708:	fc06                	sd	ra,56(sp)
    if (!USER_ACCESS(start, end))
ffffffffc020370a:	8fd1                	or	a5,a5,a2
ffffffffc020370c:	ebbd                	bnez	a5,ffffffffc0203782 <mm_map+0xa8>
ffffffffc020370e:	002007b7          	lui	a5,0x200
ffffffffc0203712:	06f4e863          	bltu	s1,a5,ffffffffc0203782 <mm_map+0xa8>
ffffffffc0203716:	f04a                	sd	s2,32(sp)
ffffffffc0203718:	ec4e                	sd	s3,24(sp)
ffffffffc020371a:	e852                	sd	s4,16(sp)
ffffffffc020371c:	892a                	mv	s2,a0
ffffffffc020371e:	89ba                	mv	s3,a4
ffffffffc0203720:	8a36                	mv	s4,a3
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0203722:	c135                	beqz	a0,ffffffffc0203786 <mm_map+0xac>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc0203724:	85a6                	mv	a1,s1
ffffffffc0203726:	e55ff0ef          	jal	ffffffffc020357a <find_vma>
ffffffffc020372a:	c501                	beqz	a0,ffffffffc0203732 <mm_map+0x58>
ffffffffc020372c:	651c                	ld	a5,8(a0)
ffffffffc020372e:	0487e763          	bltu	a5,s0,ffffffffc020377c <mm_map+0xa2>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203732:	03000513          	li	a0,48
ffffffffc0203736:	c7efe0ef          	jal	ffffffffc0201bb4 <kmalloc>
ffffffffc020373a:	85aa                	mv	a1,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc020373c:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc020373e:	c59d                	beqz	a1,ffffffffc020376c <mm_map+0x92>
        vma->vm_start = vm_start;
ffffffffc0203740:	e584                	sd	s1,8(a1)
        vma->vm_end = vm_end;
ffffffffc0203742:	e980                	sd	s0,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0203744:	0145ac23          	sw	s4,24(a1)

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc0203748:	854a                	mv	a0,s2
ffffffffc020374a:	e42e                	sd	a1,8(sp)
ffffffffc020374c:	e6fff0ef          	jal	ffffffffc02035ba <insert_vma_struct>
    if (vma_store != NULL)
ffffffffc0203750:	65a2                	ld	a1,8(sp)
ffffffffc0203752:	00098463          	beqz	s3,ffffffffc020375a <mm_map+0x80>
    {
        *vma_store = vma;
ffffffffc0203756:	00b9b023          	sd	a1,0(s3)
ffffffffc020375a:	7902                	ld	s2,32(sp)
ffffffffc020375c:	69e2                	ld	s3,24(sp)
ffffffffc020375e:	6a42                	ld	s4,16(sp)
    }
    ret = 0;
ffffffffc0203760:	4501                	li	a0,0

out:
    return ret;
}
ffffffffc0203762:	70e2                	ld	ra,56(sp)
ffffffffc0203764:	7442                	ld	s0,48(sp)
ffffffffc0203766:	74a2                	ld	s1,40(sp)
ffffffffc0203768:	6121                	addi	sp,sp,64
ffffffffc020376a:	8082                	ret
ffffffffc020376c:	70e2                	ld	ra,56(sp)
ffffffffc020376e:	7442                	ld	s0,48(sp)
ffffffffc0203770:	7902                	ld	s2,32(sp)
ffffffffc0203772:	69e2                	ld	s3,24(sp)
ffffffffc0203774:	6a42                	ld	s4,16(sp)
ffffffffc0203776:	74a2                	ld	s1,40(sp)
ffffffffc0203778:	6121                	addi	sp,sp,64
ffffffffc020377a:	8082                	ret
ffffffffc020377c:	7902                	ld	s2,32(sp)
ffffffffc020377e:	69e2                	ld	s3,24(sp)
ffffffffc0203780:	6a42                	ld	s4,16(sp)
        return -E_INVAL;
ffffffffc0203782:	5575                	li	a0,-3
ffffffffc0203784:	bff9                	j	ffffffffc0203762 <mm_map+0x88>
    assert(mm != NULL);
ffffffffc0203786:	00004697          	auipc	a3,0x4
ffffffffc020378a:	28a68693          	addi	a3,a3,650 # ffffffffc0207a10 <etext+0x156e>
ffffffffc020378e:	00003617          	auipc	a2,0x3
ffffffffc0203792:	6ea60613          	addi	a2,a2,1770 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203796:	0b300593          	li	a1,179
ffffffffc020379a:	00004517          	auipc	a0,0x4
ffffffffc020379e:	1ee50513          	addi	a0,a0,494 # ffffffffc0207988 <etext+0x14e6>
ffffffffc02037a2:	ca9fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02037a6 <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc02037a6:	7139                	addi	sp,sp,-64
ffffffffc02037a8:	fc06                	sd	ra,56(sp)
ffffffffc02037aa:	f822                	sd	s0,48(sp)
ffffffffc02037ac:	f426                	sd	s1,40(sp)
ffffffffc02037ae:	f04a                	sd	s2,32(sp)
ffffffffc02037b0:	ec4e                	sd	s3,24(sp)
ffffffffc02037b2:	e852                	sd	s4,16(sp)
ffffffffc02037b4:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc02037b6:	c525                	beqz	a0,ffffffffc020381e <dup_mmap+0x78>
ffffffffc02037b8:	892a                	mv	s2,a0
ffffffffc02037ba:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc02037bc:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc02037be:	c1a5                	beqz	a1,ffffffffc020381e <dup_mmap+0x78>
    return listelm->prev;
ffffffffc02037c0:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc02037c2:	04848c63          	beq	s1,s0,ffffffffc020381a <dup_mmap+0x74>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02037c6:	03000513          	li	a0,48
    {
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc02037ca:	fe843a83          	ld	s5,-24(s0)
ffffffffc02037ce:	ff043a03          	ld	s4,-16(s0)
ffffffffc02037d2:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02037d6:	bdefe0ef          	jal	ffffffffc0201bb4 <kmalloc>
    if (vma != NULL)
ffffffffc02037da:	c515                	beqz	a0,ffffffffc0203806 <dup_mmap+0x60>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc02037dc:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc02037de:	01553423          	sd	s5,8(a0)
ffffffffc02037e2:	01453823          	sd	s4,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc02037e6:	01352c23          	sw	s3,24(a0)
        insert_vma_struct(to, nvma);
ffffffffc02037ea:	854a                	mv	a0,s2
ffffffffc02037ec:	dcfff0ef          	jal	ffffffffc02035ba <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc02037f0:	ff043683          	ld	a3,-16(s0)
ffffffffc02037f4:	fe843603          	ld	a2,-24(s0)
ffffffffc02037f8:	6c8c                	ld	a1,24(s1)
ffffffffc02037fa:	01893503          	ld	a0,24(s2)
ffffffffc02037fe:	4701                	li	a4,0
ffffffffc0203800:	cb9fe0ef          	jal	ffffffffc02024b8 <copy_range>
ffffffffc0203804:	dd55                	beqz	a0,ffffffffc02037c0 <dup_mmap+0x1a>
            return -E_NO_MEM;
ffffffffc0203806:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0203808:	70e2                	ld	ra,56(sp)
ffffffffc020380a:	7442                	ld	s0,48(sp)
ffffffffc020380c:	74a2                	ld	s1,40(sp)
ffffffffc020380e:	7902                	ld	s2,32(sp)
ffffffffc0203810:	69e2                	ld	s3,24(sp)
ffffffffc0203812:	6a42                	ld	s4,16(sp)
ffffffffc0203814:	6aa2                	ld	s5,8(sp)
ffffffffc0203816:	6121                	addi	sp,sp,64
ffffffffc0203818:	8082                	ret
    return 0;
ffffffffc020381a:	4501                	li	a0,0
ffffffffc020381c:	b7f5                	j	ffffffffc0203808 <dup_mmap+0x62>
    assert(to != NULL && from != NULL);
ffffffffc020381e:	00004697          	auipc	a3,0x4
ffffffffc0203822:	20268693          	addi	a3,a3,514 # ffffffffc0207a20 <etext+0x157e>
ffffffffc0203826:	00003617          	auipc	a2,0x3
ffffffffc020382a:	65260613          	addi	a2,a2,1618 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc020382e:	0cf00593          	li	a1,207
ffffffffc0203832:	00004517          	auipc	a0,0x4
ffffffffc0203836:	15650513          	addi	a0,a0,342 # ffffffffc0207988 <etext+0x14e6>
ffffffffc020383a:	c11fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020383e <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc020383e:	1101                	addi	sp,sp,-32
ffffffffc0203840:	ec06                	sd	ra,24(sp)
ffffffffc0203842:	e822                	sd	s0,16(sp)
ffffffffc0203844:	e426                	sd	s1,8(sp)
ffffffffc0203846:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203848:	c531                	beqz	a0,ffffffffc0203894 <exit_mmap+0x56>
ffffffffc020384a:	591c                	lw	a5,48(a0)
ffffffffc020384c:	84aa                	mv	s1,a0
ffffffffc020384e:	e3b9                	bnez	a5,ffffffffc0203894 <exit_mmap+0x56>
    return listelm->next;
ffffffffc0203850:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0203852:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc0203856:	02850663          	beq	a0,s0,ffffffffc0203882 <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc020385a:	ff043603          	ld	a2,-16(s0)
ffffffffc020385e:	fe843583          	ld	a1,-24(s0)
ffffffffc0203862:	854a                	mv	a0,s2
ffffffffc0203864:	86dfe0ef          	jal	ffffffffc02020d0 <unmap_range>
ffffffffc0203868:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc020386a:	fe8498e3          	bne	s1,s0,ffffffffc020385a <exit_mmap+0x1c>
ffffffffc020386e:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc0203870:	00848c63          	beq	s1,s0,ffffffffc0203888 <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0203874:	ff043603          	ld	a2,-16(s0)
ffffffffc0203878:	fe843583          	ld	a1,-24(s0)
ffffffffc020387c:	854a                	mv	a0,s2
ffffffffc020387e:	987fe0ef          	jal	ffffffffc0202204 <exit_range>
ffffffffc0203882:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203884:	fe8498e3          	bne	s1,s0,ffffffffc0203874 <exit_mmap+0x36>
    }
}
ffffffffc0203888:	60e2                	ld	ra,24(sp)
ffffffffc020388a:	6442                	ld	s0,16(sp)
ffffffffc020388c:	64a2                	ld	s1,8(sp)
ffffffffc020388e:	6902                	ld	s2,0(sp)
ffffffffc0203890:	6105                	addi	sp,sp,32
ffffffffc0203892:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203894:	00004697          	auipc	a3,0x4
ffffffffc0203898:	1ac68693          	addi	a3,a3,428 # ffffffffc0207a40 <etext+0x159e>
ffffffffc020389c:	00003617          	auipc	a2,0x3
ffffffffc02038a0:	5dc60613          	addi	a2,a2,1500 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02038a4:	0e800593          	li	a1,232
ffffffffc02038a8:	00004517          	auipc	a0,0x4
ffffffffc02038ac:	0e050513          	addi	a0,a0,224 # ffffffffc0207988 <etext+0x14e6>
ffffffffc02038b0:	b9bfc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02038b4 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc02038b4:	7179                	addi	sp,sp,-48
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02038b6:	05800513          	li	a0,88
{
ffffffffc02038ba:	f406                	sd	ra,40(sp)
ffffffffc02038bc:	f022                	sd	s0,32(sp)
ffffffffc02038be:	ec26                	sd	s1,24(sp)
ffffffffc02038c0:	e84a                	sd	s2,16(sp)
ffffffffc02038c2:	e44e                	sd	s3,8(sp)
ffffffffc02038c4:	e052                	sd	s4,0(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02038c6:	aeefe0ef          	jal	ffffffffc0201bb4 <kmalloc>
    if (mm != NULL)
ffffffffc02038ca:	16050f63          	beqz	a0,ffffffffc0203a48 <vmm_init+0x194>
    elm->prev = elm->next = elm;
ffffffffc02038ce:	e508                	sd	a0,8(a0)
ffffffffc02038d0:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02038d2:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02038d6:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02038da:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc02038de:	02053423          	sd	zero,40(a0)
ffffffffc02038e2:	02052823          	sw	zero,48(a0)
        sem_init(&(mm->mm_sem), 1);
ffffffffc02038e6:	842a                	mv	s0,a0
ffffffffc02038e8:	4585                	li	a1,1
ffffffffc02038ea:	03850513          	addi	a0,a0,56
ffffffffc02038ee:	38d000ef          	jal	ffffffffc020447a <sem_init>
ffffffffc02038f2:	03200493          	li	s1,50
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02038f6:	03000513          	li	a0,48
ffffffffc02038fa:	abafe0ef          	jal	ffffffffc0201bb4 <kmalloc>
    if (vma != NULL)
ffffffffc02038fe:	12050563          	beqz	a0,ffffffffc0203a28 <vmm_init+0x174>
        vma->vm_end = vm_end;
ffffffffc0203902:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc0203906:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203908:	00052c23          	sw	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc020390c:	e91c                	sd	a5,16(a0)
    int i;
    for (i = step1; i >= 1; i--)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020390e:	85aa                	mv	a1,a0
    for (i = step1; i >= 1; i--)
ffffffffc0203910:	14ed                	addi	s1,s1,-5
        insert_vma_struct(mm, vma);
ffffffffc0203912:	8522                	mv	a0,s0
ffffffffc0203914:	ca7ff0ef          	jal	ffffffffc02035ba <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0203918:	fcf9                	bnez	s1,ffffffffc02038f6 <vmm_init+0x42>
ffffffffc020391a:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc020391e:	1f900913          	li	s2,505
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203922:	03000513          	li	a0,48
ffffffffc0203926:	a8efe0ef          	jal	ffffffffc0201bb4 <kmalloc>
    if (vma != NULL)
ffffffffc020392a:	12050f63          	beqz	a0,ffffffffc0203a68 <vmm_init+0x1b4>
        vma->vm_end = vm_end;
ffffffffc020392e:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc0203932:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203934:	00052c23          	sw	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc0203938:	e91c                	sd	a5,16(a0)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc020393a:	85aa                	mv	a1,a0
    for (i = step1 + 1; i <= step2; i++)
ffffffffc020393c:	0495                	addi	s1,s1,5
        insert_vma_struct(mm, vma);
ffffffffc020393e:	8522                	mv	a0,s0
ffffffffc0203940:	c7bff0ef          	jal	ffffffffc02035ba <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203944:	fd249fe3          	bne	s1,s2,ffffffffc0203922 <vmm_init+0x6e>
    return listelm->next;
ffffffffc0203948:	641c                	ld	a5,8(s0)
ffffffffc020394a:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc020394c:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0203950:	1ef40c63          	beq	s0,a5,ffffffffc0203b48 <vmm_init+0x294>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203954:	fe87b603          	ld	a2,-24(a5) # 1fffe8 <_binary_obj___user_matrix_out_size+0x1f4900>
ffffffffc0203958:	ffe70693          	addi	a3,a4,-2
ffffffffc020395c:	12d61663          	bne	a2,a3,ffffffffc0203a88 <vmm_init+0x1d4>
ffffffffc0203960:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203964:	12e69263          	bne	a3,a4,ffffffffc0203a88 <vmm_init+0x1d4>
    for (i = 1; i <= step2; i++)
ffffffffc0203968:	0715                	addi	a4,a4,5
ffffffffc020396a:	679c                	ld	a5,8(a5)
ffffffffc020396c:	feb712e3          	bne	a4,a1,ffffffffc0203950 <vmm_init+0x9c>
ffffffffc0203970:	491d                	li	s2,7
ffffffffc0203972:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203974:	85a6                	mv	a1,s1
ffffffffc0203976:	8522                	mv	a0,s0
ffffffffc0203978:	c03ff0ef          	jal	ffffffffc020357a <find_vma>
ffffffffc020397c:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc020397e:	20050563          	beqz	a0,ffffffffc0203b88 <vmm_init+0x2d4>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0203982:	00148593          	addi	a1,s1,1
ffffffffc0203986:	8522                	mv	a0,s0
ffffffffc0203988:	bf3ff0ef          	jal	ffffffffc020357a <find_vma>
ffffffffc020398c:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc020398e:	1c050d63          	beqz	a0,ffffffffc0203b68 <vmm_init+0x2b4>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0203992:	85ca                	mv	a1,s2
ffffffffc0203994:	8522                	mv	a0,s0
ffffffffc0203996:	be5ff0ef          	jal	ffffffffc020357a <find_vma>
        assert(vma3 == NULL);
ffffffffc020399a:	18051763          	bnez	a0,ffffffffc0203b28 <vmm_init+0x274>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc020399e:	00348593          	addi	a1,s1,3
ffffffffc02039a2:	8522                	mv	a0,s0
ffffffffc02039a4:	bd7ff0ef          	jal	ffffffffc020357a <find_vma>
        assert(vma4 == NULL);
ffffffffc02039a8:	16051063          	bnez	a0,ffffffffc0203b08 <vmm_init+0x254>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc02039ac:	00448593          	addi	a1,s1,4
ffffffffc02039b0:	8522                	mv	a0,s0
ffffffffc02039b2:	bc9ff0ef          	jal	ffffffffc020357a <find_vma>
        assert(vma5 == NULL);
ffffffffc02039b6:	12051963          	bnez	a0,ffffffffc0203ae8 <vmm_init+0x234>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc02039ba:	008a3783          	ld	a5,8(s4)
ffffffffc02039be:	10979563          	bne	a5,s1,ffffffffc0203ac8 <vmm_init+0x214>
ffffffffc02039c2:	010a3783          	ld	a5,16(s4)
ffffffffc02039c6:	11279163          	bne	a5,s2,ffffffffc0203ac8 <vmm_init+0x214>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc02039ca:	0089b783          	ld	a5,8(s3)
ffffffffc02039ce:	0c979d63          	bne	a5,s1,ffffffffc0203aa8 <vmm_init+0x1f4>
ffffffffc02039d2:	0109b783          	ld	a5,16(s3)
ffffffffc02039d6:	0d279963          	bne	a5,s2,ffffffffc0203aa8 <vmm_init+0x1f4>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc02039da:	0495                	addi	s1,s1,5
ffffffffc02039dc:	1f900793          	li	a5,505
ffffffffc02039e0:	0915                	addi	s2,s2,5
ffffffffc02039e2:	f8f499e3          	bne	s1,a5,ffffffffc0203974 <vmm_init+0xc0>
ffffffffc02039e6:	4491                	li	s1,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc02039e8:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc02039ea:	85a6                	mv	a1,s1
ffffffffc02039ec:	8522                	mv	a0,s0
ffffffffc02039ee:	b8dff0ef          	jal	ffffffffc020357a <find_vma>
        if (vma_below_5 != NULL)
ffffffffc02039f2:	1a051b63          	bnez	a0,ffffffffc0203ba8 <vmm_init+0x2f4>
    for (i = 4; i >= 0; i--)
ffffffffc02039f6:	14fd                	addi	s1,s1,-1
ffffffffc02039f8:	ff2499e3          	bne	s1,s2,ffffffffc02039ea <vmm_init+0x136>
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
ffffffffc02039fc:	8522                	mv	a0,s0
ffffffffc02039fe:	c8bff0ef          	jal	ffffffffc0203688 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203a02:	00004517          	auipc	a0,0x4
ffffffffc0203a06:	1ae50513          	addi	a0,a0,430 # ffffffffc0207bb0 <etext+0x170e>
ffffffffc0203a0a:	f8efc0ef          	jal	ffffffffc0200198 <cprintf>
}
ffffffffc0203a0e:	7402                	ld	s0,32(sp)
ffffffffc0203a10:	70a2                	ld	ra,40(sp)
ffffffffc0203a12:	64e2                	ld	s1,24(sp)
ffffffffc0203a14:	6942                	ld	s2,16(sp)
ffffffffc0203a16:	69a2                	ld	s3,8(sp)
ffffffffc0203a18:	6a02                	ld	s4,0(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203a1a:	00004517          	auipc	a0,0x4
ffffffffc0203a1e:	1b650513          	addi	a0,a0,438 # ffffffffc0207bd0 <etext+0x172e>
}
ffffffffc0203a22:	6145                	addi	sp,sp,48
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203a24:	f74fc06f          	j	ffffffffc0200198 <cprintf>
        assert(vma != NULL);
ffffffffc0203a28:	00004697          	auipc	a3,0x4
ffffffffc0203a2c:	03868693          	addi	a3,a3,56 # ffffffffc0207a60 <etext+0x15be>
ffffffffc0203a30:	00003617          	auipc	a2,0x3
ffffffffc0203a34:	44860613          	addi	a2,a2,1096 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203a38:	12c00593          	li	a1,300
ffffffffc0203a3c:	00004517          	auipc	a0,0x4
ffffffffc0203a40:	f4c50513          	addi	a0,a0,-180 # ffffffffc0207988 <etext+0x14e6>
ffffffffc0203a44:	a07fc0ef          	jal	ffffffffc020044a <__panic>
    assert(mm != NULL);
ffffffffc0203a48:	00004697          	auipc	a3,0x4
ffffffffc0203a4c:	fc868693          	addi	a3,a3,-56 # ffffffffc0207a10 <etext+0x156e>
ffffffffc0203a50:	00003617          	auipc	a2,0x3
ffffffffc0203a54:	42860613          	addi	a2,a2,1064 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203a58:	12400593          	li	a1,292
ffffffffc0203a5c:	00004517          	auipc	a0,0x4
ffffffffc0203a60:	f2c50513          	addi	a0,a0,-212 # ffffffffc0207988 <etext+0x14e6>
ffffffffc0203a64:	9e7fc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma != NULL);
ffffffffc0203a68:	00004697          	auipc	a3,0x4
ffffffffc0203a6c:	ff868693          	addi	a3,a3,-8 # ffffffffc0207a60 <etext+0x15be>
ffffffffc0203a70:	00003617          	auipc	a2,0x3
ffffffffc0203a74:	40860613          	addi	a2,a2,1032 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203a78:	13300593          	li	a1,307
ffffffffc0203a7c:	00004517          	auipc	a0,0x4
ffffffffc0203a80:	f0c50513          	addi	a0,a0,-244 # ffffffffc0207988 <etext+0x14e6>
ffffffffc0203a84:	9c7fc0ef          	jal	ffffffffc020044a <__panic>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203a88:	00004697          	auipc	a3,0x4
ffffffffc0203a8c:	00068693          	mv	a3,a3
ffffffffc0203a90:	00003617          	auipc	a2,0x3
ffffffffc0203a94:	3e860613          	addi	a2,a2,1000 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203a98:	13d00593          	li	a1,317
ffffffffc0203a9c:	00004517          	auipc	a0,0x4
ffffffffc0203aa0:	eec50513          	addi	a0,a0,-276 # ffffffffc0207988 <etext+0x14e6>
ffffffffc0203aa4:	9a7fc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203aa8:	00004697          	auipc	a3,0x4
ffffffffc0203aac:	09868693          	addi	a3,a3,152 # ffffffffc0207b40 <etext+0x169e>
ffffffffc0203ab0:	00003617          	auipc	a2,0x3
ffffffffc0203ab4:	3c860613          	addi	a2,a2,968 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203ab8:	14f00593          	li	a1,335
ffffffffc0203abc:	00004517          	auipc	a0,0x4
ffffffffc0203ac0:	ecc50513          	addi	a0,a0,-308 # ffffffffc0207988 <etext+0x14e6>
ffffffffc0203ac4:	987fc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203ac8:	00004697          	auipc	a3,0x4
ffffffffc0203acc:	04868693          	addi	a3,a3,72 # ffffffffc0207b10 <etext+0x166e>
ffffffffc0203ad0:	00003617          	auipc	a2,0x3
ffffffffc0203ad4:	3a860613          	addi	a2,a2,936 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203ad8:	14e00593          	li	a1,334
ffffffffc0203adc:	00004517          	auipc	a0,0x4
ffffffffc0203ae0:	eac50513          	addi	a0,a0,-340 # ffffffffc0207988 <etext+0x14e6>
ffffffffc0203ae4:	967fc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma5 == NULL);
ffffffffc0203ae8:	00004697          	auipc	a3,0x4
ffffffffc0203aec:	01868693          	addi	a3,a3,24 # ffffffffc0207b00 <etext+0x165e>
ffffffffc0203af0:	00003617          	auipc	a2,0x3
ffffffffc0203af4:	38860613          	addi	a2,a2,904 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203af8:	14c00593          	li	a1,332
ffffffffc0203afc:	00004517          	auipc	a0,0x4
ffffffffc0203b00:	e8c50513          	addi	a0,a0,-372 # ffffffffc0207988 <etext+0x14e6>
ffffffffc0203b04:	947fc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma4 == NULL);
ffffffffc0203b08:	00004697          	auipc	a3,0x4
ffffffffc0203b0c:	fe868693          	addi	a3,a3,-24 # ffffffffc0207af0 <etext+0x164e>
ffffffffc0203b10:	00003617          	auipc	a2,0x3
ffffffffc0203b14:	36860613          	addi	a2,a2,872 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203b18:	14a00593          	li	a1,330
ffffffffc0203b1c:	00004517          	auipc	a0,0x4
ffffffffc0203b20:	e6c50513          	addi	a0,a0,-404 # ffffffffc0207988 <etext+0x14e6>
ffffffffc0203b24:	927fc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma3 == NULL);
ffffffffc0203b28:	00004697          	auipc	a3,0x4
ffffffffc0203b2c:	fb868693          	addi	a3,a3,-72 # ffffffffc0207ae0 <etext+0x163e>
ffffffffc0203b30:	00003617          	auipc	a2,0x3
ffffffffc0203b34:	34860613          	addi	a2,a2,840 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203b38:	14800593          	li	a1,328
ffffffffc0203b3c:	00004517          	auipc	a0,0x4
ffffffffc0203b40:	e4c50513          	addi	a0,a0,-436 # ffffffffc0207988 <etext+0x14e6>
ffffffffc0203b44:	907fc0ef          	jal	ffffffffc020044a <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203b48:	00004697          	auipc	a3,0x4
ffffffffc0203b4c:	f2868693          	addi	a3,a3,-216 # ffffffffc0207a70 <etext+0x15ce>
ffffffffc0203b50:	00003617          	auipc	a2,0x3
ffffffffc0203b54:	32860613          	addi	a2,a2,808 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203b58:	13b00593          	li	a1,315
ffffffffc0203b5c:	00004517          	auipc	a0,0x4
ffffffffc0203b60:	e2c50513          	addi	a0,a0,-468 # ffffffffc0207988 <etext+0x14e6>
ffffffffc0203b64:	8e7fc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma2 != NULL);
ffffffffc0203b68:	00004697          	auipc	a3,0x4
ffffffffc0203b6c:	f6868693          	addi	a3,a3,-152 # ffffffffc0207ad0 <etext+0x162e>
ffffffffc0203b70:	00003617          	auipc	a2,0x3
ffffffffc0203b74:	30860613          	addi	a2,a2,776 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203b78:	14600593          	li	a1,326
ffffffffc0203b7c:	00004517          	auipc	a0,0x4
ffffffffc0203b80:	e0c50513          	addi	a0,a0,-500 # ffffffffc0207988 <etext+0x14e6>
ffffffffc0203b84:	8c7fc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma1 != NULL);
ffffffffc0203b88:	00004697          	auipc	a3,0x4
ffffffffc0203b8c:	f3868693          	addi	a3,a3,-200 # ffffffffc0207ac0 <etext+0x161e>
ffffffffc0203b90:	00003617          	auipc	a2,0x3
ffffffffc0203b94:	2e860613          	addi	a2,a2,744 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203b98:	14400593          	li	a1,324
ffffffffc0203b9c:	00004517          	auipc	a0,0x4
ffffffffc0203ba0:	dec50513          	addi	a0,a0,-532 # ffffffffc0207988 <etext+0x14e6>
ffffffffc0203ba4:	8a7fc0ef          	jal	ffffffffc020044a <__panic>
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203ba8:	6914                	ld	a3,16(a0)
ffffffffc0203baa:	6510                	ld	a2,8(a0)
ffffffffc0203bac:	0004859b          	sext.w	a1,s1
ffffffffc0203bb0:	00004517          	auipc	a0,0x4
ffffffffc0203bb4:	fc050513          	addi	a0,a0,-64 # ffffffffc0207b70 <etext+0x16ce>
ffffffffc0203bb8:	de0fc0ef          	jal	ffffffffc0200198 <cprintf>
        assert(vma_below_5 == NULL);
ffffffffc0203bbc:	00004697          	auipc	a3,0x4
ffffffffc0203bc0:	fdc68693          	addi	a3,a3,-36 # ffffffffc0207b98 <etext+0x16f6>
ffffffffc0203bc4:	00003617          	auipc	a2,0x3
ffffffffc0203bc8:	2b460613          	addi	a2,a2,692 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0203bcc:	15900593          	li	a1,345
ffffffffc0203bd0:	00004517          	auipc	a0,0x4
ffffffffc0203bd4:	db850513          	addi	a0,a0,-584 # ffffffffc0207988 <etext+0x14e6>
ffffffffc0203bd8:	873fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0203bdc <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0203bdc:	7179                	addi	sp,sp,-48
ffffffffc0203bde:	f022                	sd	s0,32(sp)
ffffffffc0203be0:	f406                	sd	ra,40(sp)
ffffffffc0203be2:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0203be4:	c52d                	beqz	a0,ffffffffc0203c4e <user_mem_check+0x72>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0203be6:	002007b7          	lui	a5,0x200
ffffffffc0203bea:	04f5ed63          	bltu	a1,a5,ffffffffc0203c44 <user_mem_check+0x68>
ffffffffc0203bee:	ec26                	sd	s1,24(sp)
ffffffffc0203bf0:	00c584b3          	add	s1,a1,a2
ffffffffc0203bf4:	0695ff63          	bgeu	a1,s1,ffffffffc0203c72 <user_mem_check+0x96>
ffffffffc0203bf8:	4785                	li	a5,1
ffffffffc0203bfa:	07fe                	slli	a5,a5,0x1f
ffffffffc0203bfc:	0785                	addi	a5,a5,1 # 200001 <_binary_obj___user_matrix_out_size+0x1f4919>
ffffffffc0203bfe:	06f4fa63          	bgeu	s1,a5,ffffffffc0203c72 <user_mem_check+0x96>
ffffffffc0203c02:	e84a                	sd	s2,16(sp)
ffffffffc0203c04:	e44e                	sd	s3,8(sp)
ffffffffc0203c06:	8936                	mv	s2,a3
ffffffffc0203c08:	89aa                	mv	s3,a0
ffffffffc0203c0a:	a829                	j	ffffffffc0203c24 <user_mem_check+0x48>
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203c0c:	6685                	lui	a3,0x1
ffffffffc0203c0e:	9736                	add	a4,a4,a3
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203c10:	0027f693          	andi	a3,a5,2
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203c14:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203c16:	c685                	beqz	a3,ffffffffc0203c3e <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203c18:	c399                	beqz	a5,ffffffffc0203c1e <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203c1a:	02e46263          	bltu	s0,a4,ffffffffc0203c3e <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0203c1e:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc0203c20:	04947b63          	bgeu	s0,s1,ffffffffc0203c76 <user_mem_check+0x9a>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc0203c24:	85a2                	mv	a1,s0
ffffffffc0203c26:	854e                	mv	a0,s3
ffffffffc0203c28:	953ff0ef          	jal	ffffffffc020357a <find_vma>
ffffffffc0203c2c:	c909                	beqz	a0,ffffffffc0203c3e <user_mem_check+0x62>
ffffffffc0203c2e:	6518                	ld	a4,8(a0)
ffffffffc0203c30:	00e46763          	bltu	s0,a4,ffffffffc0203c3e <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203c34:	4d1c                	lw	a5,24(a0)
ffffffffc0203c36:	fc091be3          	bnez	s2,ffffffffc0203c0c <user_mem_check+0x30>
ffffffffc0203c3a:	8b85                	andi	a5,a5,1
ffffffffc0203c3c:	f3ed                	bnez	a5,ffffffffc0203c1e <user_mem_check+0x42>
ffffffffc0203c3e:	64e2                	ld	s1,24(sp)
ffffffffc0203c40:	6942                	ld	s2,16(sp)
ffffffffc0203c42:	69a2                	ld	s3,8(sp)
            return 0;
ffffffffc0203c44:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0203c46:	70a2                	ld	ra,40(sp)
ffffffffc0203c48:	7402                	ld	s0,32(sp)
ffffffffc0203c4a:	6145                	addi	sp,sp,48
ffffffffc0203c4c:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203c4e:	c02007b7          	lui	a5,0xc0200
ffffffffc0203c52:	fef5eae3          	bltu	a1,a5,ffffffffc0203c46 <user_mem_check+0x6a>
ffffffffc0203c56:	c80007b7          	lui	a5,0xc8000
ffffffffc0203c5a:	962e                	add	a2,a2,a1
ffffffffc0203c5c:	0785                	addi	a5,a5,1 # ffffffffc8000001 <end+0x7d33c89>
ffffffffc0203c5e:	00c5b433          	sltu	s0,a1,a2
ffffffffc0203c62:	00f63633          	sltu	a2,a2,a5
}
ffffffffc0203c66:	70a2                	ld	ra,40(sp)
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203c68:	00867533          	and	a0,a2,s0
}
ffffffffc0203c6c:	7402                	ld	s0,32(sp)
ffffffffc0203c6e:	6145                	addi	sp,sp,48
ffffffffc0203c70:	8082                	ret
ffffffffc0203c72:	64e2                	ld	s1,24(sp)
ffffffffc0203c74:	bfc1                	j	ffffffffc0203c44 <user_mem_check+0x68>
ffffffffc0203c76:	64e2                	ld	s1,24(sp)
ffffffffc0203c78:	6942                	ld	s2,16(sp)
ffffffffc0203c7a:	69a2                	ld	s3,8(sp)
        return 1;
ffffffffc0203c7c:	4505                	li	a0,1
ffffffffc0203c7e:	b7e1                	j	ffffffffc0203c46 <user_mem_check+0x6a>

ffffffffc0203c80 <phi_test_sema>:

struct proc_struct *philosopher_proc_sema[N];

void phi_test_sema(int i) /* i：哲学家号码从0到N-1 */
{ 
    if(state_sema[i]==HUNGRY&&state_sema[LEFT]!=EATING
ffffffffc0203c80:	00251793          	slli	a5,a0,0x2
ffffffffc0203c84:	000c4617          	auipc	a2,0xc4
ffffffffc0203c88:	61460613          	addi	a2,a2,1556 # ffffffffc02c8298 <state_sema>
ffffffffc0203c8c:	97b2                	add	a5,a5,a2
ffffffffc0203c8e:	4394                	lw	a3,0(a5)
ffffffffc0203c90:	4705                	li	a4,1
ffffffffc0203c92:	00e68363          	beq	a3,a4,ffffffffc0203c98 <phi_test_sema+0x18>
            &&state_sema[RIGHT]!=EATING)
    {
        state_sema[i]=EATING;
        up(&s[i]);
    }
}
ffffffffc0203c96:	8082                	ret
    if(state_sema[i]==HUNGRY&&state_sema[LEFT]!=EATING
ffffffffc0203c98:	666666b7          	lui	a3,0x66666
ffffffffc0203c9c:	0045071b          	addiw	a4,a0,4
ffffffffc0203ca0:	66768693          	addi	a3,a3,1639 # 66666667 <_binary_obj___user_matrix_out_size+0x6665af7f>
ffffffffc0203ca4:	02d705b3          	mul	a1,a4,a3
ffffffffc0203ca8:	41f7581b          	sraiw	a6,a4,0x1f
ffffffffc0203cac:	4889                	li	a7,2
ffffffffc0203cae:	9585                	srai	a1,a1,0x21
ffffffffc0203cb0:	410585bb          	subw	a1,a1,a6
ffffffffc0203cb4:	0025981b          	slliw	a6,a1,0x2
ffffffffc0203cb8:	00b805bb          	addw	a1,a6,a1
ffffffffc0203cbc:	9f0d                	subw	a4,a4,a1
ffffffffc0203cbe:	070a                	slli	a4,a4,0x2
ffffffffc0203cc0:	9732                	add	a4,a4,a2
ffffffffc0203cc2:	4318                	lw	a4,0(a4)
ffffffffc0203cc4:	fd1709e3          	beq	a4,a7,ffffffffc0203c96 <phi_test_sema+0x16>
            &&state_sema[RIGHT]!=EATING)
ffffffffc0203cc8:	0015071b          	addiw	a4,a0,1
ffffffffc0203ccc:	02d706b3          	mul	a3,a4,a3
ffffffffc0203cd0:	41f7559b          	sraiw	a1,a4,0x1f
ffffffffc0203cd4:	9685                	srai	a3,a3,0x21
ffffffffc0203cd6:	9e8d                	subw	a3,a3,a1
ffffffffc0203cd8:	0026959b          	slliw	a1,a3,0x2
ffffffffc0203cdc:	9ead                	addw	a3,a3,a1
ffffffffc0203cde:	9f15                	subw	a4,a4,a3
ffffffffc0203ce0:	070a                	slli	a4,a4,0x2
ffffffffc0203ce2:	963a                	add	a2,a2,a4
ffffffffc0203ce4:	4218                	lw	a4,0(a2)
ffffffffc0203ce6:	fb1708e3          	beq	a4,a7,ffffffffc0203c96 <phi_test_sema+0x16>
        up(&s[i]);
ffffffffc0203cea:	00151713          	slli	a4,a0,0x1
ffffffffc0203cee:	972a                	add	a4,a4,a0
ffffffffc0203cf0:	070e                	slli	a4,a4,0x3
ffffffffc0203cf2:	000c4517          	auipc	a0,0xc4
ffffffffc0203cf6:	51650513          	addi	a0,a0,1302 # ffffffffc02c8208 <s>
ffffffffc0203cfa:	953a                	add	a0,a0,a4
        state_sema[i]=EATING;
ffffffffc0203cfc:	0117a023          	sw	a7,0(a5)
        up(&s[i]);
ffffffffc0203d00:	7800006f          	j	ffffffffc0204480 <up>

ffffffffc0203d04 <philosopher_using_semaphore>:
        phi_test_sema(RIGHT); /* 看一下右邻居现在是否能进餐 */
        up(&mutex); /* 离开临界区 */
}

int philosopher_using_semaphore(void * arg) /* i：哲学家号码，从0到N-1 */
{
ffffffffc0203d04:	715d                	addi	sp,sp,-80
ffffffffc0203d06:	e0a2                	sd	s0,64(sp)
    int i, iter=0;
    i=(int)arg;
ffffffffc0203d08:	0005041b          	sext.w	s0,a0
    cprintf("I am No.%d philosopher_sema\n",i);
ffffffffc0203d0c:	85a2                	mv	a1,s0
ffffffffc0203d0e:	00004517          	auipc	a0,0x4
ffffffffc0203d12:	eda50513          	addi	a0,a0,-294 # ffffffffc0207be8 <etext+0x1746>
{
ffffffffc0203d16:	fc26                	sd	s1,56(sp)
ffffffffc0203d18:	f84a                	sd	s2,48(sp)
ffffffffc0203d1a:	f44e                	sd	s3,40(sp)
ffffffffc0203d1c:	f052                	sd	s4,32(sp)
ffffffffc0203d1e:	ec56                	sd	s5,24(sp)
ffffffffc0203d20:	e85a                	sd	s6,16(sp)
ffffffffc0203d22:	e45e                	sd	s7,8(sp)
ffffffffc0203d24:	e486                	sd	ra,72(sp)
    cprintf("I am No.%d philosopher_sema\n",i);
ffffffffc0203d26:	c72fc0ef          	jal	ffffffffc0200198 <cprintf>
        phi_test_sema(LEFT); /* 看一下左邻居现在是否能进餐 */
ffffffffc0203d2a:	666667b7          	lui	a5,0x66666
ffffffffc0203d2e:	00440a9b          	addiw	s5,s0,4
ffffffffc0203d32:	66778793          	addi	a5,a5,1639 # 66666667 <_binary_obj___user_matrix_out_size+0x6665af7f>
ffffffffc0203d36:	02fa8733          	mul	a4,s5,a5
        phi_test_sema(RIGHT); /* 看一下右邻居现在是否能进餐 */
ffffffffc0203d3a:	00140a1b          	addiw	s4,s0,1
        phi_test_sema(LEFT); /* 看一下左邻居现在是否能进餐 */
ffffffffc0203d3e:	41fad69b          	sraiw	a3,s5,0x1f
        phi_test_sema(RIGHT); /* 看一下右邻居现在是否能进餐 */
ffffffffc0203d42:	41fa561b          	sraiw	a2,s4,0x1f
        down(&s[i]); /* 如果得不到叉子就阻塞 */
ffffffffc0203d46:	00141993          	slli	s3,s0,0x1
ffffffffc0203d4a:	99a2                	add	s3,s3,s0
ffffffffc0203d4c:	098e                	slli	s3,s3,0x3
ffffffffc0203d4e:	000c4517          	auipc	a0,0xc4
ffffffffc0203d52:	4ba50513          	addi	a0,a0,1210 # ffffffffc02c8208 <s>
ffffffffc0203d56:	00241593          	slli	a1,s0,0x2
ffffffffc0203d5a:	000c4917          	auipc	s2,0xc4
ffffffffc0203d5e:	53e90913          	addi	s2,s2,1342 # ffffffffc02c8298 <state_sema>
        phi_test_sema(RIGHT); /* 看一下右邻居现在是否能进餐 */
ffffffffc0203d62:	02fa07b3          	mul	a5,s4,a5
        phi_test_sema(LEFT); /* 看一下左邻居现在是否能进餐 */
ffffffffc0203d66:	9705                	srai	a4,a4,0x21
ffffffffc0203d68:	9f15                	subw	a4,a4,a3
ffffffffc0203d6a:	0027169b          	slliw	a3,a4,0x2
ffffffffc0203d6e:	9f35                	addw	a4,a4,a3
ffffffffc0203d70:	40ea8abb          	subw	s5,s5,a4
    while(iter++<TIMES)
ffffffffc0203d74:	4485                	li	s1,1
        down(&s[i]); /* 如果得不到叉子就阻塞 */
ffffffffc0203d76:	99aa                	add	s3,s3,a0
        state_sema[i]=HUNGRY; /* 记录下哲学家i饥饿的事实 */
ffffffffc0203d78:	992e                	add	s2,s2,a1
ffffffffc0203d7a:	8ba6                	mv	s7,s1
        phi_test_sema(RIGHT); /* 看一下右邻居现在是否能进餐 */
ffffffffc0203d7c:	9785                	srai	a5,a5,0x21
ffffffffc0203d7e:	9f91                	subw	a5,a5,a2
ffffffffc0203d80:	0027971b          	slliw	a4,a5,0x2
ffffffffc0203d84:	9fb9                	addw	a5,a5,a4
    while(iter++<TIMES)
ffffffffc0203d86:	4b15                	li	s6,5
        phi_test_sema(RIGHT); /* 看一下右邻居现在是否能进餐 */
ffffffffc0203d88:	40fa0a3b          	subw	s4,s4,a5
    { /* 无限循环 */
        cprintf("Iter %d, No.%d philosopher_sema is thinking\n",iter,i); /* 哲学家正在思考 */
ffffffffc0203d8c:	85a6                	mv	a1,s1
ffffffffc0203d8e:	8622                	mv	a2,s0
ffffffffc0203d90:	00004517          	auipc	a0,0x4
ffffffffc0203d94:	e7850513          	addi	a0,a0,-392 # ffffffffc0207c08 <etext+0x1766>
ffffffffc0203d98:	c00fc0ef          	jal	ffffffffc0200198 <cprintf>
        do_sleep(SLEEP_TIME);
ffffffffc0203d9c:	4529                	li	a0,10
ffffffffc0203d9e:	3c5010ef          	jal	ffffffffc0205962 <do_sleep>
        down(&mutex); /* 进入临界区 */
ffffffffc0203da2:	000c4517          	auipc	a0,0xc4
ffffffffc0203da6:	4de50513          	addi	a0,a0,1246 # ffffffffc02c8280 <mutex>
ffffffffc0203daa:	6da000ef          	jal	ffffffffc0204484 <down>
        phi_test_sema(i); /* 试图得到两只叉子 */
ffffffffc0203dae:	8522                	mv	a0,s0
        state_sema[i]=HUNGRY; /* 记录下哲学家i饥饿的事实 */
ffffffffc0203db0:	01792023          	sw	s7,0(s2)
        phi_test_sema(i); /* 试图得到两只叉子 */
ffffffffc0203db4:	ecdff0ef          	jal	ffffffffc0203c80 <phi_test_sema>
        up(&mutex); /* 离开临界区 */
ffffffffc0203db8:	000c4517          	auipc	a0,0xc4
ffffffffc0203dbc:	4c850513          	addi	a0,a0,1224 # ffffffffc02c8280 <mutex>
ffffffffc0203dc0:	6c0000ef          	jal	ffffffffc0204480 <up>
        down(&s[i]); /* 如果得不到叉子就阻塞 */
ffffffffc0203dc4:	854e                	mv	a0,s3
ffffffffc0203dc6:	6be000ef          	jal	ffffffffc0204484 <down>
        phi_take_forks_sema(i); 
        /* 需要两只叉子，或者阻塞 */
        cprintf("Iter %d, No.%d philosopher_sema is eating\n",iter,i); /* 进餐 */
ffffffffc0203dca:	85a6                	mv	a1,s1
ffffffffc0203dcc:	8622                	mv	a2,s0
ffffffffc0203dce:	00004517          	auipc	a0,0x4
ffffffffc0203dd2:	e6a50513          	addi	a0,a0,-406 # ffffffffc0207c38 <etext+0x1796>
ffffffffc0203dd6:	bc2fc0ef          	jal	ffffffffc0200198 <cprintf>
        do_sleep(SLEEP_TIME);
ffffffffc0203dda:	4529                	li	a0,10
ffffffffc0203ddc:	387010ef          	jal	ffffffffc0205962 <do_sleep>
        down(&mutex); /* 进入临界区 */
ffffffffc0203de0:	000c4517          	auipc	a0,0xc4
ffffffffc0203de4:	4a050513          	addi	a0,a0,1184 # ffffffffc02c8280 <mutex>
ffffffffc0203de8:	69c000ef          	jal	ffffffffc0204484 <down>
        phi_test_sema(LEFT); /* 看一下左邻居现在是否能进餐 */
ffffffffc0203dec:	8556                	mv	a0,s5
        state_sema[i]=THINKING; /* 哲学家进餐结束 */
ffffffffc0203dee:	00092023          	sw	zero,0(s2)
        phi_test_sema(LEFT); /* 看一下左邻居现在是否能进餐 */
ffffffffc0203df2:	e8fff0ef          	jal	ffffffffc0203c80 <phi_test_sema>
        phi_test_sema(RIGHT); /* 看一下右邻居现在是否能进餐 */
ffffffffc0203df6:	8552                	mv	a0,s4
ffffffffc0203df8:	e89ff0ef          	jal	ffffffffc0203c80 <phi_test_sema>
        up(&mutex); /* 离开临界区 */
ffffffffc0203dfc:	000c4517          	auipc	a0,0xc4
ffffffffc0203e00:	48450513          	addi	a0,a0,1156 # ffffffffc02c8280 <mutex>
    while(iter++<TIMES)
ffffffffc0203e04:	2485                	addiw	s1,s1,1
        up(&mutex); /* 离开临界区 */
ffffffffc0203e06:	67a000ef          	jal	ffffffffc0204480 <up>
    while(iter++<TIMES)
ffffffffc0203e0a:	f96491e3          	bne	s1,s6,ffffffffc0203d8c <philosopher_using_semaphore+0x88>
        phi_put_forks_sema(i); 
        /* 把两把叉子同时放回桌子 */
    }
    cprintf("No.%d philosopher_sema quit\n",i);
ffffffffc0203e0e:	85a2                	mv	a1,s0
ffffffffc0203e10:	00004517          	auipc	a0,0x4
ffffffffc0203e14:	e5850513          	addi	a0,a0,-424 # ffffffffc0207c68 <etext+0x17c6>
ffffffffc0203e18:	b80fc0ef          	jal	ffffffffc0200198 <cprintf>
    return 0;    
}
ffffffffc0203e1c:	60a6                	ld	ra,72(sp)
ffffffffc0203e1e:	6406                	ld	s0,64(sp)
ffffffffc0203e20:	74e2                	ld	s1,56(sp)
ffffffffc0203e22:	7942                	ld	s2,48(sp)
ffffffffc0203e24:	79a2                	ld	s3,40(sp)
ffffffffc0203e26:	7a02                	ld	s4,32(sp)
ffffffffc0203e28:	6ae2                	ld	s5,24(sp)
ffffffffc0203e2a:	6b42                	ld	s6,16(sp)
ffffffffc0203e2c:	6ba2                	ld	s7,8(sp)
ffffffffc0203e2e:	4501                	li	a0,0
ffffffffc0203e30:	6161                	addi	sp,sp,80
ffffffffc0203e32:	8082                	ret

ffffffffc0203e34 <phi_test_condvar>:
struct proc_struct *philosopher_proc_condvar[N]; // N philosopher
int state_condvar[N];                            // the philosopher's state: EATING, HUNGARY, THINKING  
monitor_t mt, *mtp=&mt;                          // monitor

void phi_test_condvar (int i) { 
    if(state_condvar[i]==HUNGRY&&state_condvar[LEFT]!=EATING
ffffffffc0203e34:	00251613          	slli	a2,a0,0x2
ffffffffc0203e38:	000c4697          	auipc	a3,0xc4
ffffffffc0203e3c:	36868693          	addi	a3,a3,872 # ffffffffc02c81a0 <state_condvar>
ffffffffc0203e40:	00c68833          	add	a6,a3,a2
ffffffffc0203e44:	00082703          	lw	a4,0(a6) # fffffffffffff000 <end+0x3fd32c88>
ffffffffc0203e48:	4785                	li	a5,1
ffffffffc0203e4a:	00f70363          	beq	a4,a5,ffffffffc0203e50 <phi_test_condvar+0x1c>
ffffffffc0203e4e:	8082                	ret
ffffffffc0203e50:	66666737          	lui	a4,0x66666
ffffffffc0203e54:	0045079b          	addiw	a5,a0,4
ffffffffc0203e58:	66770713          	addi	a4,a4,1639 # 66666667 <_binary_obj___user_matrix_out_size+0x6665af7f>
ffffffffc0203e5c:	02e785b3          	mul	a1,a5,a4
ffffffffc0203e60:	41f7d89b          	sraiw	a7,a5,0x1f
ffffffffc0203e64:	4309                	li	t1,2
ffffffffc0203e66:	9585                	srai	a1,a1,0x21
ffffffffc0203e68:	411585bb          	subw	a1,a1,a7
ffffffffc0203e6c:	0025989b          	slliw	a7,a1,0x2
ffffffffc0203e70:	00b885bb          	addw	a1,a7,a1
ffffffffc0203e74:	9f8d                	subw	a5,a5,a1
ffffffffc0203e76:	078a                	slli	a5,a5,0x2
ffffffffc0203e78:	97b6                	add	a5,a5,a3
ffffffffc0203e7a:	439c                	lw	a5,0(a5)
ffffffffc0203e7c:	fc6789e3          	beq	a5,t1,ffffffffc0203e4e <phi_test_condvar+0x1a>
            &&state_condvar[RIGHT]!=EATING) {
ffffffffc0203e80:	0015079b          	addiw	a5,a0,1
ffffffffc0203e84:	02e78733          	mul	a4,a5,a4
ffffffffc0203e88:	41f7d59b          	sraiw	a1,a5,0x1f
ffffffffc0203e8c:	9705                	srai	a4,a4,0x21
ffffffffc0203e8e:	9f0d                	subw	a4,a4,a1
ffffffffc0203e90:	0027159b          	slliw	a1,a4,0x2
ffffffffc0203e94:	9f2d                	addw	a4,a4,a1
ffffffffc0203e96:	9f99                	subw	a5,a5,a4
ffffffffc0203e98:	078a                	slli	a5,a5,0x2
ffffffffc0203e9a:	96be                	add	a3,a3,a5
ffffffffc0203e9c:	429c                	lw	a5,0(a3)
ffffffffc0203e9e:	fa6788e3          	beq	a5,t1,ffffffffc0203e4e <phi_test_condvar+0x1a>
void phi_test_condvar (int i) { 
ffffffffc0203ea2:	7179                	addi	sp,sp,-48
ffffffffc0203ea4:	85aa                	mv	a1,a0
        cprintf("phi_test_condvar: state_condvar[%d] will eating\n",i);
ffffffffc0203ea6:	e42a                	sd	a0,8(sp)
ffffffffc0203ea8:	00004517          	auipc	a0,0x4
ffffffffc0203eac:	de050513          	addi	a0,a0,-544 # ffffffffc0207c88 <etext+0x17e6>
void phi_test_condvar (int i) { 
ffffffffc0203eb0:	f406                	sd	ra,40(sp)
        cprintf("phi_test_condvar: state_condvar[%d] will eating\n",i);
ffffffffc0203eb2:	e832                	sd	a2,16(sp)
ffffffffc0203eb4:	ec42                	sd	a6,24(sp)
ffffffffc0203eb6:	ae2fc0ef          	jal	ffffffffc0200198 <cprintf>
        state_condvar[i] = EATING ;
        cprintf("phi_test_condvar: signal self_cv[%d] \n",i);
ffffffffc0203eba:	65a2                	ld	a1,8(sp)
        state_condvar[i] = EATING ;
ffffffffc0203ebc:	6862                	ld	a6,24(sp)
ffffffffc0203ebe:	4309                	li	t1,2
        cprintf("phi_test_condvar: signal self_cv[%d] \n",i);
ffffffffc0203ec0:	00004517          	auipc	a0,0x4
ffffffffc0203ec4:	e0050513          	addi	a0,a0,-512 # ffffffffc0207cc0 <etext+0x181e>
        state_condvar[i] = EATING ;
ffffffffc0203ec8:	00682023          	sw	t1,0(a6)
        cprintf("phi_test_condvar: signal self_cv[%d] \n",i);
ffffffffc0203ecc:	accfc0ef          	jal	ffffffffc0200198 <cprintf>
        cond_signal(&mtp->cv[i]) ;
ffffffffc0203ed0:	000c4797          	auipc	a5,0xc4
ffffffffc0203ed4:	e687b783          	ld	a5,-408(a5) # ffffffffc02c7d38 <mtp>
ffffffffc0203ed8:	65a2                	ld	a1,8(sp)
ffffffffc0203eda:	6642                	ld	a2,16(sp)
ffffffffc0203edc:	7f88                	ld	a0,56(a5)
    }
}
ffffffffc0203ede:	70a2                	ld	ra,40(sp)
        cond_signal(&mtp->cv[i]) ;
ffffffffc0203ee0:	962e                	add	a2,a2,a1
ffffffffc0203ee2:	060e                	slli	a2,a2,0x3
ffffffffc0203ee4:	9532                	add	a0,a0,a2
}
ffffffffc0203ee6:	6145                	addi	sp,sp,48
        cond_signal(&mtp->cv[i]) ;
ffffffffc0203ee8:	a66d                	j	ffffffffc0204292 <cond_signal>

ffffffffc0203eea <phi_take_forks_condvar>:


void phi_take_forks_condvar(int i) {
ffffffffc0203eea:	7179                	addi	sp,sp,-48
ffffffffc0203eec:	e84a                	sd	s2,16(sp)
     down(&(mtp->mutex));
ffffffffc0203eee:	000c4917          	auipc	s2,0xc4
ffffffffc0203ef2:	e4a90913          	addi	s2,s2,-438 # ffffffffc02c7d38 <mtp>
void phi_take_forks_condvar(int i) {
ffffffffc0203ef6:	e44e                	sd	s3,8(sp)
ffffffffc0203ef8:	89aa                	mv	s3,a0
     down(&(mtp->mutex));
ffffffffc0203efa:	00093503          	ld	a0,0(s2)
void phi_take_forks_condvar(int i) {
ffffffffc0203efe:	f406                	sd	ra,40(sp)
ffffffffc0203f00:	f022                	sd	s0,32(sp)
ffffffffc0203f02:	ec26                	sd	s1,24(sp)
//--------into routine in monitor--------------
     // LAB7 EXERCISE1: 2312260
     // I am hungry
     // try to get fork
    state_condvar[i] = HUNGRY;
ffffffffc0203f04:	000c4417          	auipc	s0,0xc4
ffffffffc0203f08:	29c40413          	addi	s0,s0,668 # ffffffffc02c81a0 <state_condvar>
     down(&(mtp->mutex));
ffffffffc0203f0c:	578000ef          	jal	ffffffffc0204484 <down>
    state_condvar[i] = HUNGRY;
ffffffffc0203f10:	00299493          	slli	s1,s3,0x2
ffffffffc0203f14:	4785                	li	a5,1
ffffffffc0203f16:	9426                	add	s0,s0,s1
    phi_test_condvar(i);
ffffffffc0203f18:	854e                	mv	a0,s3
    state_condvar[i] = HUNGRY;
ffffffffc0203f1a:	c01c                	sw	a5,0(s0)
    phi_test_condvar(i);
ffffffffc0203f1c:	f19ff0ef          	jal	ffffffffc0203e34 <phi_test_condvar>
    if (state_condvar[i] != EATING) {
ffffffffc0203f20:	4018                	lw	a4,0(s0)
ffffffffc0203f22:	4789                	li	a5,2
ffffffffc0203f24:	00f70a63          	beq	a4,a5,ffffffffc0203f38 <phi_take_forks_condvar+0x4e>
        cond_wait(&mtp->cv[i]);
ffffffffc0203f28:	00093783          	ld	a5,0(s2)
ffffffffc0203f2c:	94ce                	add	s1,s1,s3
ffffffffc0203f2e:	048e                	slli	s1,s1,0x3
ffffffffc0203f30:	7f88                	ld	a0,56(a5)
ffffffffc0203f32:	9526                	add	a0,a0,s1
ffffffffc0203f34:	3b4000ef          	jal	ffffffffc02042e8 <cond_wait>
    }
//--------leave routine in monitor--------------
      if(mtp->next_count>0)
ffffffffc0203f38:	00093503          	ld	a0,0(s2)
ffffffffc0203f3c:	591c                	lw	a5,48(a0)
ffffffffc0203f3e:	00f05363          	blez	a5,ffffffffc0203f44 <phi_take_forks_condvar+0x5a>
         up(&(mtp->next));
ffffffffc0203f42:	0561                	addi	a0,a0,24
      else
         up(&(mtp->mutex));
}
ffffffffc0203f44:	7402                	ld	s0,32(sp)
ffffffffc0203f46:	70a2                	ld	ra,40(sp)
ffffffffc0203f48:	64e2                	ld	s1,24(sp)
ffffffffc0203f4a:	6942                	ld	s2,16(sp)
ffffffffc0203f4c:	69a2                	ld	s3,8(sp)
ffffffffc0203f4e:	6145                	addi	sp,sp,48
         up(&(mtp->mutex));
ffffffffc0203f50:	ab05                	j	ffffffffc0204480 <up>

ffffffffc0203f52 <phi_put_forks_condvar>:

void phi_put_forks_condvar(int i) {
ffffffffc0203f52:	1101                	addi	sp,sp,-32
ffffffffc0203f54:	e04a                	sd	s2,0(sp)
     down(&(mtp->mutex));
ffffffffc0203f56:	000c4917          	auipc	s2,0xc4
ffffffffc0203f5a:	de290913          	addi	s2,s2,-542 # ffffffffc02c7d38 <mtp>
void phi_put_forks_condvar(int i) {
ffffffffc0203f5e:	e426                	sd	s1,8(sp)
ffffffffc0203f60:	84aa                	mv	s1,a0
     down(&(mtp->mutex));
ffffffffc0203f62:	00093503          	ld	a0,0(s2)
void phi_put_forks_condvar(int i) {
ffffffffc0203f66:	ec06                	sd	ra,24(sp)
ffffffffc0203f68:	e822                	sd	s0,16(sp)
     down(&(mtp->mutex));
ffffffffc0203f6a:	51a000ef          	jal	ffffffffc0204484 <down>
//--------into routine in monitor--------------
     // LAB7 EXERCISE1: 2312260
     // I ate over
     // test left and right neighbors
    state_condvar[i] = THINKING;
    phi_test_condvar(LEFT);
ffffffffc0203f6e:	66666437          	lui	s0,0x66666
ffffffffc0203f72:	0044851b          	addiw	a0,s1,4
ffffffffc0203f76:	66740413          	addi	s0,s0,1639 # 66666667 <_binary_obj___user_matrix_out_size+0x6665af7f>
ffffffffc0203f7a:	028507b3          	mul	a5,a0,s0
    state_condvar[i] = THINKING;
ffffffffc0203f7e:	00249613          	slli	a2,s1,0x2
    phi_test_condvar(RIGHT);
ffffffffc0203f82:	2485                	addiw	s1,s1,1
    phi_test_condvar(LEFT);
ffffffffc0203f84:	41f5569b          	sraiw	a3,a0,0x1f
    state_condvar[i] = THINKING;
ffffffffc0203f88:	000c4717          	auipc	a4,0xc4
ffffffffc0203f8c:	21870713          	addi	a4,a4,536 # ffffffffc02c81a0 <state_condvar>
ffffffffc0203f90:	9732                	add	a4,a4,a2
ffffffffc0203f92:	00072023          	sw	zero,0(a4)
    phi_test_condvar(RIGHT);
ffffffffc0203f96:	02848433          	mul	s0,s1,s0
    phi_test_condvar(LEFT);
ffffffffc0203f9a:	9785                	srai	a5,a5,0x21
ffffffffc0203f9c:	9f95                	subw	a5,a5,a3
ffffffffc0203f9e:	0027971b          	slliw	a4,a5,0x2
ffffffffc0203fa2:	9fb9                	addw	a5,a5,a4
ffffffffc0203fa4:	9d1d                	subw	a0,a0,a5
ffffffffc0203fa6:	e8fff0ef          	jal	ffffffffc0203e34 <phi_test_condvar>
    phi_test_condvar(RIGHT);
ffffffffc0203faa:	41f4d79b          	sraiw	a5,s1,0x1f
ffffffffc0203fae:	9405                	srai	s0,s0,0x21
ffffffffc0203fb0:	9c1d                	subw	s0,s0,a5
ffffffffc0203fb2:	0024151b          	slliw	a0,s0,0x2
ffffffffc0203fb6:	9d21                	addw	a0,a0,s0
ffffffffc0203fb8:	40a4853b          	subw	a0,s1,a0
ffffffffc0203fbc:	e79ff0ef          	jal	ffffffffc0203e34 <phi_test_condvar>
//--------leave routine in monitor--------------
     if(mtp->next_count>0)
ffffffffc0203fc0:	00093503          	ld	a0,0(s2)
ffffffffc0203fc4:	591c                	lw	a5,48(a0)
ffffffffc0203fc6:	00f05363          	blez	a5,ffffffffc0203fcc <phi_put_forks_condvar+0x7a>
        up(&(mtp->next));
ffffffffc0203fca:	0561                	addi	a0,a0,24
     else
        up(&(mtp->mutex));
}
ffffffffc0203fcc:	6442                	ld	s0,16(sp)
ffffffffc0203fce:	60e2                	ld	ra,24(sp)
ffffffffc0203fd0:	64a2                	ld	s1,8(sp)
ffffffffc0203fd2:	6902                	ld	s2,0(sp)
ffffffffc0203fd4:	6105                	addi	sp,sp,32
        up(&(mtp->mutex));
ffffffffc0203fd6:	a16d                	j	ffffffffc0204480 <up>

ffffffffc0203fd8 <philosopher_using_condvar>:

//---------- philosophers using monitor (condition variable) ----------------------
int philosopher_using_condvar(void * arg) { /* arg is the No. of philosopher 0~N-1*/
ffffffffc0203fd8:	1101                	addi	sp,sp,-32
ffffffffc0203fda:	e822                	sd	s0,16(sp)
  
    int i, iter=0;
    i=(int)arg;
ffffffffc0203fdc:	0005041b          	sext.w	s0,a0
    cprintf("I am No.%d philosopher_condvar\n",i);
ffffffffc0203fe0:	85a2                	mv	a1,s0
ffffffffc0203fe2:	00004517          	auipc	a0,0x4
ffffffffc0203fe6:	d0650513          	addi	a0,a0,-762 # ffffffffc0207ce8 <etext+0x1846>
int philosopher_using_condvar(void * arg) { /* arg is the No. of philosopher 0~N-1*/
ffffffffc0203fea:	e426                	sd	s1,8(sp)
ffffffffc0203fec:	e04a                	sd	s2,0(sp)
ffffffffc0203fee:	ec06                	sd	ra,24(sp)
    while(iter++<TIMES)
ffffffffc0203ff0:	4485                	li	s1,1
    cprintf("I am No.%d philosopher_condvar\n",i);
ffffffffc0203ff2:	9a6fc0ef          	jal	ffffffffc0200198 <cprintf>
    while(iter++<TIMES)
ffffffffc0203ff6:	4915                	li	s2,5
    { /* iterate*/
        cprintf("Iter %d, No.%d philosopher_condvar is thinking\n",iter,i); /* thinking*/
ffffffffc0203ff8:	85a6                	mv	a1,s1
ffffffffc0203ffa:	8622                	mv	a2,s0
ffffffffc0203ffc:	00004517          	auipc	a0,0x4
ffffffffc0204000:	d0c50513          	addi	a0,a0,-756 # ffffffffc0207d08 <etext+0x1866>
ffffffffc0204004:	994fc0ef          	jal	ffffffffc0200198 <cprintf>
        do_sleep(SLEEP_TIME);
ffffffffc0204008:	4529                	li	a0,10
ffffffffc020400a:	159010ef          	jal	ffffffffc0205962 <do_sleep>
        phi_take_forks_condvar(i); 
ffffffffc020400e:	8522                	mv	a0,s0
ffffffffc0204010:	edbff0ef          	jal	ffffffffc0203eea <phi_take_forks_condvar>
        /* need two forks, maybe blocked */
        cprintf("Iter %d, No.%d philosopher_condvar is eating\n",iter,i); /* eating*/
ffffffffc0204014:	85a6                	mv	a1,s1
ffffffffc0204016:	8622                	mv	a2,s0
ffffffffc0204018:	00004517          	auipc	a0,0x4
ffffffffc020401c:	d2050513          	addi	a0,a0,-736 # ffffffffc0207d38 <etext+0x1896>
ffffffffc0204020:	978fc0ef          	jal	ffffffffc0200198 <cprintf>
        do_sleep(SLEEP_TIME);
ffffffffc0204024:	4529                	li	a0,10
ffffffffc0204026:	13d010ef          	jal	ffffffffc0205962 <do_sleep>
        phi_put_forks_condvar(i); 
ffffffffc020402a:	8522                	mv	a0,s0
    while(iter++<TIMES)
ffffffffc020402c:	2485                	addiw	s1,s1,1
        phi_put_forks_condvar(i); 
ffffffffc020402e:	f25ff0ef          	jal	ffffffffc0203f52 <phi_put_forks_condvar>
    while(iter++<TIMES)
ffffffffc0204032:	fd2493e3          	bne	s1,s2,ffffffffc0203ff8 <philosopher_using_condvar+0x20>
        /* return two forks back*/
    }
    cprintf("No.%d philosopher_condvar quit\n",i);
ffffffffc0204036:	85a2                	mv	a1,s0
ffffffffc0204038:	00004517          	auipc	a0,0x4
ffffffffc020403c:	d3050513          	addi	a0,a0,-720 # ffffffffc0207d68 <etext+0x18c6>
ffffffffc0204040:	958fc0ef          	jal	ffffffffc0200198 <cprintf>
    return 0;    
}
ffffffffc0204044:	60e2                	ld	ra,24(sp)
ffffffffc0204046:	6442                	ld	s0,16(sp)
ffffffffc0204048:	64a2                	ld	s1,8(sp)
ffffffffc020404a:	6902                	ld	s2,0(sp)
ffffffffc020404c:	4501                	li	a0,0
ffffffffc020404e:	6105                	addi	sp,sp,32
ffffffffc0204050:	8082                	ret

ffffffffc0204052 <check_sync>:

void check_sync(void){
ffffffffc0204052:	711d                	addi	sp,sp,-96
ffffffffc0204054:	e8a2                	sd	s0,80(sp)

    int i, pids[N];

    //check semaphore
    sem_init(&mutex, 1);
ffffffffc0204056:	4585                	li	a1,1
ffffffffc0204058:	000c4517          	auipc	a0,0xc4
ffffffffc020405c:	22850513          	addi	a0,a0,552 # ffffffffc02c8280 <mutex>
ffffffffc0204060:	0020                	addi	s0,sp,8
void check_sync(void){
ffffffffc0204062:	e4a6                	sd	s1,72(sp)
ffffffffc0204064:	e0ca                	sd	s2,64(sp)
ffffffffc0204066:	fc4e                	sd	s3,56(sp)
ffffffffc0204068:	f852                	sd	s4,48(sp)
ffffffffc020406a:	f456                	sd	s5,40(sp)
ffffffffc020406c:	ec86                	sd	ra,88(sp)
ffffffffc020406e:	f05a                	sd	s6,32(sp)
    sem_init(&mutex, 1);
ffffffffc0204070:	8a22                	mv	s4,s0
ffffffffc0204072:	408000ef          	jal	ffffffffc020447a <sem_init>
    for(i=0;i<N;i++){
ffffffffc0204076:	000c4997          	auipc	s3,0xc4
ffffffffc020407a:	19298993          	addi	s3,s3,402 # ffffffffc02c8208 <s>
ffffffffc020407e:	000c4917          	auipc	s2,0xc4
ffffffffc0204082:	16290913          	addi	s2,s2,354 # ffffffffc02c81e0 <philosopher_proc_sema>
    sem_init(&mutex, 1);
ffffffffc0204086:	4481                	li	s1,0
    for(i=0;i<N;i++){
ffffffffc0204088:	4a95                	li	s5,5
        sem_init(&s[i], 0);
ffffffffc020408a:	4581                	li	a1,0
ffffffffc020408c:	854e                	mv	a0,s3
ffffffffc020408e:	3ec000ef          	jal	ffffffffc020447a <sem_init>
        int pid = kernel_thread(philosopher_using_semaphore, (void *)i, 0);
ffffffffc0204092:	85a6                	mv	a1,s1
ffffffffc0204094:	4601                	li	a2,0
ffffffffc0204096:	00000517          	auipc	a0,0x0
ffffffffc020409a:	c6e50513          	addi	a0,a0,-914 # ffffffffc0203d04 <philosopher_using_semaphore>
ffffffffc020409e:	347000ef          	jal	ffffffffc0204be4 <kernel_thread>
        if (pid <= 0) {
ffffffffc02040a2:	0ca05763          	blez	a0,ffffffffc0204170 <check_sync+0x11e>
            panic("create No.%d philosopher_using_semaphore failed.\n");
        }
        pids[i] = pid;
ffffffffc02040a6:	00aa2023          	sw	a0,0(s4)
        philosopher_proc_sema[i] = find_proc(pid);
ffffffffc02040aa:	6bc000ef          	jal	ffffffffc0204766 <find_proc>
ffffffffc02040ae:	00a93023          	sd	a0,0(s2)
        set_proc_name(philosopher_proc_sema[i], "philosopher_sema_proc");
ffffffffc02040b2:	00004597          	auipc	a1,0x4
ffffffffc02040b6:	d2658593          	addi	a1,a1,-730 # ffffffffc0207dd8 <etext+0x1936>
    for(i=0;i<N;i++){
ffffffffc02040ba:	0485                	addi	s1,s1,1
        set_proc_name(philosopher_proc_sema[i], "philosopher_sema_proc");
ffffffffc02040bc:	61e000ef          	jal	ffffffffc02046da <set_proc_name>
    for(i=0;i<N;i++){
ffffffffc02040c0:	09e1                	addi	s3,s3,24
ffffffffc02040c2:	0a11                	addi	s4,s4,4
ffffffffc02040c4:	0921                	addi	s2,s2,8
ffffffffc02040c6:	fd5492e3          	bne	s1,s5,ffffffffc020408a <check_sync+0x38>
ffffffffc02040ca:	01440a93          	addi	s5,s0,20
ffffffffc02040ce:	84a2                	mv	s1,s0
    }
    for (i=0;i<N;i++)
        assert(do_wait(pids[i],NULL) == 0);
ffffffffc02040d0:	4088                	lw	a0,0(s1)
ffffffffc02040d2:	4581                	li	a1,0
ffffffffc02040d4:	5f4010ef          	jal	ffffffffc02056c8 <do_wait>
ffffffffc02040d8:	0e051463          	bnez	a0,ffffffffc02041c0 <check_sync+0x16e>
    for (i=0;i<N;i++)
ffffffffc02040dc:	0491                	addi	s1,s1,4
ffffffffc02040de:	ff5499e3          	bne	s1,s5,ffffffffc02040d0 <check_sync+0x7e>

    //check condition variable
    monitor_init(&mt, N);
ffffffffc02040e2:	4595                	li	a1,5
ffffffffc02040e4:	000c4517          	auipc	a0,0xc4
ffffffffc02040e8:	07c50513          	addi	a0,a0,124 # ffffffffc02c8160 <mt>
ffffffffc02040ec:	0f4000ef          	jal	ffffffffc02041e0 <monitor_init>
ffffffffc02040f0:	8a22                	mv	s4,s0
ffffffffc02040f2:	000c4917          	auipc	s2,0xc4
ffffffffc02040f6:	0ae90913          	addi	s2,s2,174 # ffffffffc02c81a0 <state_condvar>
ffffffffc02040fa:	000c4997          	auipc	s3,0xc4
ffffffffc02040fe:	0be98993          	addi	s3,s3,190 # ffffffffc02c81b8 <philosopher_proc_condvar>
ffffffffc0204102:	4481                	li	s1,0
    for(i=0;i<N;i++){
ffffffffc0204104:	4b15                	li	s6,5
        state_condvar[i]=THINKING;
        int pid = kernel_thread(philosopher_using_condvar, (void *)i, 0);
ffffffffc0204106:	4601                	li	a2,0
ffffffffc0204108:	85a6                	mv	a1,s1
ffffffffc020410a:	00000517          	auipc	a0,0x0
ffffffffc020410e:	ece50513          	addi	a0,a0,-306 # ffffffffc0203fd8 <philosopher_using_condvar>
        state_condvar[i]=THINKING;
ffffffffc0204112:	00092023          	sw	zero,0(s2)
        int pid = kernel_thread(philosopher_using_condvar, (void *)i, 0);
ffffffffc0204116:	2cf000ef          	jal	ffffffffc0204be4 <kernel_thread>
        if (pid <= 0) {
ffffffffc020411a:	08a05763          	blez	a0,ffffffffc02041a8 <check_sync+0x156>
            panic("create No.%d philosopher_using_condvar failed.\n");
        }
        pids[i] = pid;
ffffffffc020411e:	00aa2023          	sw	a0,0(s4)
        philosopher_proc_condvar[i] = find_proc(pid);
ffffffffc0204122:	644000ef          	jal	ffffffffc0204766 <find_proc>
ffffffffc0204126:	00a9b023          	sd	a0,0(s3)
        set_proc_name(philosopher_proc_condvar[i], "philosopher_condvar_proc");
ffffffffc020412a:	00004597          	auipc	a1,0x4
ffffffffc020412e:	d1658593          	addi	a1,a1,-746 # ffffffffc0207e40 <etext+0x199e>
    for(i=0;i<N;i++){
ffffffffc0204132:	0485                	addi	s1,s1,1
        set_proc_name(philosopher_proc_condvar[i], "philosopher_condvar_proc");
ffffffffc0204134:	5a6000ef          	jal	ffffffffc02046da <set_proc_name>
    for(i=0;i<N;i++){
ffffffffc0204138:	0911                	addi	s2,s2,4
ffffffffc020413a:	0a11                	addi	s4,s4,4
ffffffffc020413c:	09a1                	addi	s3,s3,8
ffffffffc020413e:	fd6494e3          	bne	s1,s6,ffffffffc0204106 <check_sync+0xb4>
    }
    for (i=0;i<N;i++)
        assert(do_wait(pids[i],NULL) == 0);
ffffffffc0204142:	4008                	lw	a0,0(s0)
ffffffffc0204144:	4581                	li	a1,0
ffffffffc0204146:	582010ef          	jal	ffffffffc02056c8 <do_wait>
ffffffffc020414a:	ed1d                	bnez	a0,ffffffffc0204188 <check_sync+0x136>
    for (i=0;i<N;i++)
ffffffffc020414c:	0411                	addi	s0,s0,4
ffffffffc020414e:	ff541ae3          	bne	s0,s5,ffffffffc0204142 <check_sync+0xf0>
    monitor_free(&mt, N);
}
ffffffffc0204152:	6446                	ld	s0,80(sp)
ffffffffc0204154:	60e6                	ld	ra,88(sp)
ffffffffc0204156:	64a6                	ld	s1,72(sp)
ffffffffc0204158:	6906                	ld	s2,64(sp)
ffffffffc020415a:	79e2                	ld	s3,56(sp)
ffffffffc020415c:	7a42                	ld	s4,48(sp)
ffffffffc020415e:	7aa2                	ld	s5,40(sp)
ffffffffc0204160:	7b02                	ld	s6,32(sp)
    monitor_free(&mt, N);
ffffffffc0204162:	4595                	li	a1,5
ffffffffc0204164:	000c4517          	auipc	a0,0xc4
ffffffffc0204168:	ffc50513          	addi	a0,a0,-4 # ffffffffc02c8160 <mt>
}
ffffffffc020416c:	6125                	addi	sp,sp,96
    monitor_free(&mt, N);
ffffffffc020416e:	aa39                	j	ffffffffc020428c <monitor_free>
            panic("create No.%d philosopher_using_semaphore failed.\n");
ffffffffc0204170:	00004617          	auipc	a2,0x4
ffffffffc0204174:	c1860613          	addi	a2,a2,-1000 # ffffffffc0207d88 <etext+0x18e6>
ffffffffc0204178:	0f700593          	li	a1,247
ffffffffc020417c:	00004517          	auipc	a0,0x4
ffffffffc0204180:	c4450513          	addi	a0,a0,-956 # ffffffffc0207dc0 <etext+0x191e>
ffffffffc0204184:	ac6fc0ef          	jal	ffffffffc020044a <__panic>
        assert(do_wait(pids[i],NULL) == 0);
ffffffffc0204188:	00004697          	auipc	a3,0x4
ffffffffc020418c:	c6868693          	addi	a3,a3,-920 # ffffffffc0207df0 <etext+0x194e>
ffffffffc0204190:	00003617          	auipc	a2,0x3
ffffffffc0204194:	ce860613          	addi	a2,a2,-792 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0204198:	10d00593          	li	a1,269
ffffffffc020419c:	00004517          	auipc	a0,0x4
ffffffffc02041a0:	c2450513          	addi	a0,a0,-988 # ffffffffc0207dc0 <etext+0x191e>
ffffffffc02041a4:	aa6fc0ef          	jal	ffffffffc020044a <__panic>
            panic("create No.%d philosopher_using_condvar failed.\n");
ffffffffc02041a8:	00004617          	auipc	a2,0x4
ffffffffc02041ac:	c6860613          	addi	a2,a2,-920 # ffffffffc0207e10 <etext+0x196e>
ffffffffc02041b0:	10600593          	li	a1,262
ffffffffc02041b4:	00004517          	auipc	a0,0x4
ffffffffc02041b8:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0207dc0 <etext+0x191e>
ffffffffc02041bc:	a8efc0ef          	jal	ffffffffc020044a <__panic>
        assert(do_wait(pids[i],NULL) == 0);
ffffffffc02041c0:	00004697          	auipc	a3,0x4
ffffffffc02041c4:	c3068693          	addi	a3,a3,-976 # ffffffffc0207df0 <etext+0x194e>
ffffffffc02041c8:	00003617          	auipc	a2,0x3
ffffffffc02041cc:	cb060613          	addi	a2,a2,-848 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02041d0:	0fe00593          	li	a1,254
ffffffffc02041d4:	00004517          	auipc	a0,0x4
ffffffffc02041d8:	bec50513          	addi	a0,a0,-1044 # ffffffffc0207dc0 <etext+0x191e>
ffffffffc02041dc:	a6efc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02041e0 <monitor_init>:
#include <assert.h>


// Initialize monitor.
void     
monitor_init (monitor_t * mtp, size_t num_cv) {
ffffffffc02041e0:	7179                	addi	sp,sp,-48
ffffffffc02041e2:	f406                	sd	ra,40(sp)
ffffffffc02041e4:	f022                	sd	s0,32(sp)
ffffffffc02041e6:	ec26                	sd	s1,24(sp)
ffffffffc02041e8:	e84a                	sd	s2,16(sp)
ffffffffc02041ea:	e44e                	sd	s3,8(sp)
    int i;
    assert(num_cv>0);
ffffffffc02041ec:	c1b5                	beqz	a1,ffffffffc0204250 <monitor_init+0x70>
    mtp->next_count = 0;
ffffffffc02041ee:	89ae                	mv	s3,a1
ffffffffc02041f0:	02052823          	sw	zero,48(a0)
    mtp->cv = NULL;
ffffffffc02041f4:	02053c23          	sd	zero,56(a0)
    sem_init(&(mtp->mutex), 1); //unlocked
ffffffffc02041f8:	4585                	li	a1,1
ffffffffc02041fa:	892a                	mv	s2,a0
ffffffffc02041fc:	27e000ef          	jal	ffffffffc020447a <sem_init>
    sem_init(&(mtp->next), 0);
ffffffffc0204200:	01890513          	addi	a0,s2,24
ffffffffc0204204:	4581                	li	a1,0
ffffffffc0204206:	274000ef          	jal	ffffffffc020447a <sem_init>
    mtp->cv =(condvar_t *) kmalloc(sizeof(condvar_t)*num_cv);
ffffffffc020420a:	00299513          	slli	a0,s3,0x2
ffffffffc020420e:	954e                	add	a0,a0,s3
ffffffffc0204210:	050e                	slli	a0,a0,0x3
ffffffffc0204212:	9a3fd0ef          	jal	ffffffffc0201bb4 <kmalloc>
ffffffffc0204216:	02a93c23          	sd	a0,56(s2)
    assert(mtp->cv!=NULL);
ffffffffc020421a:	4401                	li	s0,0
ffffffffc020421c:	4481                	li	s1,0
ffffffffc020421e:	c921                	beqz	a0,ffffffffc020426e <monitor_init+0x8e>
    for(i=0; i<num_cv; i++){
        mtp->cv[i].count=0;
ffffffffc0204220:	9522                	add	a0,a0,s0
ffffffffc0204222:	00052c23          	sw	zero,24(a0)
        sem_init(&(mtp->cv[i].sem),0);
ffffffffc0204226:	4581                	li	a1,0
ffffffffc0204228:	252000ef          	jal	ffffffffc020447a <sem_init>
        mtp->cv[i].owner=mtp;
ffffffffc020422c:	03893503          	ld	a0,56(s2)
    for(i=0; i<num_cv; i++){
ffffffffc0204230:	0485                	addi	s1,s1,1
        mtp->cv[i].owner=mtp;
ffffffffc0204232:	008507b3          	add	a5,a0,s0
ffffffffc0204236:	0327b023          	sd	s2,32(a5)
    for(i=0; i<num_cv; i++){
ffffffffc020423a:	02840413          	addi	s0,s0,40
ffffffffc020423e:	ff3491e3          	bne	s1,s3,ffffffffc0204220 <monitor_init+0x40>
    }
}
ffffffffc0204242:	70a2                	ld	ra,40(sp)
ffffffffc0204244:	7402                	ld	s0,32(sp)
ffffffffc0204246:	64e2                	ld	s1,24(sp)
ffffffffc0204248:	6942                	ld	s2,16(sp)
ffffffffc020424a:	69a2                	ld	s3,8(sp)
ffffffffc020424c:	6145                	addi	sp,sp,48
ffffffffc020424e:	8082                	ret
    assert(num_cv>0);
ffffffffc0204250:	00004697          	auipc	a3,0x4
ffffffffc0204254:	c1068693          	addi	a3,a3,-1008 # ffffffffc0207e60 <etext+0x19be>
ffffffffc0204258:	00003617          	auipc	a2,0x3
ffffffffc020425c:	c2060613          	addi	a2,a2,-992 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0204260:	45ad                	li	a1,11
ffffffffc0204262:	00004517          	auipc	a0,0x4
ffffffffc0204266:	c0e50513          	addi	a0,a0,-1010 # ffffffffc0207e70 <etext+0x19ce>
ffffffffc020426a:	9e0fc0ef          	jal	ffffffffc020044a <__panic>
    assert(mtp->cv!=NULL);
ffffffffc020426e:	00004697          	auipc	a3,0x4
ffffffffc0204272:	c1a68693          	addi	a3,a3,-998 # ffffffffc0207e88 <etext+0x19e6>
ffffffffc0204276:	00003617          	auipc	a2,0x3
ffffffffc020427a:	c0260613          	addi	a2,a2,-1022 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc020427e:	45c5                	li	a1,17
ffffffffc0204280:	00004517          	auipc	a0,0x4
ffffffffc0204284:	bf050513          	addi	a0,a0,-1040 # ffffffffc0207e70 <etext+0x19ce>
ffffffffc0204288:	9c2fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020428c <monitor_free>:

// Free monitor.
void
monitor_free (monitor_t * mtp, size_t num_cv) {
    kfree(mtp->cv);
ffffffffc020428c:	7d08                	ld	a0,56(a0)
ffffffffc020428e:	9cdfd06f          	j	ffffffffc0201c5a <kfree>

ffffffffc0204292 <cond_signal>:

// Unlock one of threads waiting on the condition variable. 
void 
cond_signal (condvar_t *cvp) {
   //LAB7 EXERCISE1: 2312260
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
ffffffffc0204292:	711c                	ld	a5,32(a0)
ffffffffc0204294:	4d10                	lw	a2,24(a0)
cond_signal (condvar_t *cvp) {
ffffffffc0204296:	1141                	addi	sp,sp,-16
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
ffffffffc0204298:	5b94                	lw	a3,48(a5)
cond_signal (condvar_t *cvp) {
ffffffffc020429a:	e022                	sd	s0,0(sp)
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
ffffffffc020429c:	85aa                	mv	a1,a0
cond_signal (condvar_t *cvp) {
ffffffffc020429e:	842a                	mv	s0,a0
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
ffffffffc02042a0:	00004517          	auipc	a0,0x4
ffffffffc02042a4:	bf850513          	addi	a0,a0,-1032 # ffffffffc0207e98 <etext+0x19f6>
cond_signal (condvar_t *cvp) {
ffffffffc02042a8:	e406                	sd	ra,8(sp)
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
ffffffffc02042aa:	eeffb0ef          	jal	ffffffffc0200198 <cprintf>
   *             mt.next_count--;
   *          }
   *       }
   */
   if(cvp->count > 0) {
      cvp->owner->next_count ++;
ffffffffc02042ae:	701c                	ld	a5,32(s0)
   if(cvp->count > 0) {
ffffffffc02042b0:	4c10                	lw	a2,24(s0)
      cvp->owner->next_count ++;
ffffffffc02042b2:	5b94                	lw	a3,48(a5)
   if(cvp->count > 0) {
ffffffffc02042b4:	02c05063          	blez	a2,ffffffffc02042d4 <cond_signal+0x42>
      cvp->owner->next_count ++;
ffffffffc02042b8:	2685                	addiw	a3,a3,1
ffffffffc02042ba:	db94                	sw	a3,48(a5)
      up(&(cvp->sem));
ffffffffc02042bc:	8522                	mv	a0,s0
ffffffffc02042be:	1c2000ef          	jal	ffffffffc0204480 <up>
      down(&(cvp->owner->next));
ffffffffc02042c2:	7008                	ld	a0,32(s0)
ffffffffc02042c4:	0561                	addi	a0,a0,24
ffffffffc02042c6:	1be000ef          	jal	ffffffffc0204484 <down>
      cvp->owner->next_count --;
ffffffffc02042ca:	701c                	ld	a5,32(s0)
   }
   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc02042cc:	4c10                	lw	a2,24(s0)
      cvp->owner->next_count --;
ffffffffc02042ce:	5b94                	lw	a3,48(a5)
ffffffffc02042d0:	36fd                	addiw	a3,a3,-1
ffffffffc02042d2:	db94                	sw	a3,48(a5)
   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc02042d4:	85a2                	mv	a1,s0
}
ffffffffc02042d6:	6402                	ld	s0,0(sp)
ffffffffc02042d8:	60a2                	ld	ra,8(sp)
   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc02042da:	00004517          	auipc	a0,0x4
ffffffffc02042de:	c0650513          	addi	a0,a0,-1018 # ffffffffc0207ee0 <etext+0x1a3e>
}
ffffffffc02042e2:	0141                	addi	sp,sp,16
   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc02042e4:	eb5fb06f          	j	ffffffffc0200198 <cprintf>

ffffffffc02042e8 <cond_wait>:
// Suspend calling thread on a condition variable waiting for condition Atomically unlocks 
// mutex and suspends calling thread on conditional variable after waking up locks mutex. Notice: mp is mutex semaphore for monitor's procedures
void
cond_wait (condvar_t *cvp) {
    //LAB7 EXERCISE1: 2312260
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc02042e8:	711c                	ld	a5,32(a0)
ffffffffc02042ea:	4d10                	lw	a2,24(a0)
cond_wait (condvar_t *cvp) {
ffffffffc02042ec:	1141                	addi	sp,sp,-16
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc02042ee:	5b94                	lw	a3,48(a5)
cond_wait (condvar_t *cvp) {
ffffffffc02042f0:	e022                	sd	s0,0(sp)
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc02042f2:	85aa                	mv	a1,a0
cond_wait (condvar_t *cvp) {
ffffffffc02042f4:	842a                	mv	s0,a0
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc02042f6:	00004517          	auipc	a0,0x4
ffffffffc02042fa:	c3250513          	addi	a0,a0,-974 # ffffffffc0207f28 <etext+0x1a86>
cond_wait (condvar_t *cvp) {
ffffffffc02042fe:	e406                	sd	ra,8(sp)
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0204300:	e99fb0ef          	jal	ffffffffc0200198 <cprintf>
    *            signal(mt.mutex);
    *         wait(cv.sem);
    *         cv.count --;
    */
    cvp->count ++;
    if(cvp->owner->next_count > 0)
ffffffffc0204304:	7008                	ld	a0,32(s0)
    cvp->count ++;
ffffffffc0204306:	4c1c                	lw	a5,24(s0)
    if(cvp->owner->next_count > 0)
ffffffffc0204308:	5918                	lw	a4,48(a0)
    cvp->count ++;
ffffffffc020430a:	2785                	addiw	a5,a5,1
ffffffffc020430c:	cc1c                	sw	a5,24(s0)
    if(cvp->owner->next_count > 0)
ffffffffc020430e:	02e05763          	blez	a4,ffffffffc020433c <cond_wait+0x54>
       up(&(cvp->owner->next));
ffffffffc0204312:	0561                	addi	a0,a0,24
ffffffffc0204314:	16c000ef          	jal	ffffffffc0204480 <up>
    else
       up(&(cvp->owner->mutex));
    down(&(cvp->sem));
ffffffffc0204318:	8522                	mv	a0,s0
ffffffffc020431a:	16a000ef          	jal	ffffffffc0204484 <down>
    cvp->count --;
ffffffffc020431e:	4c10                	lw	a2,24(s0)
    cprintf("cond_wait end:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0204320:	701c                	ld	a5,32(s0)
ffffffffc0204322:	85a2                	mv	a1,s0
    cvp->count --;
ffffffffc0204324:	367d                	addiw	a2,a2,-1
    cprintf("cond_wait end:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0204326:	5b94                	lw	a3,48(a5)
    cvp->count --;
ffffffffc0204328:	cc10                	sw	a2,24(s0)
}
ffffffffc020432a:	6402                	ld	s0,0(sp)
ffffffffc020432c:	60a2                	ld	ra,8(sp)
    cprintf("cond_wait end:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc020432e:	00004517          	auipc	a0,0x4
ffffffffc0204332:	c4250513          	addi	a0,a0,-958 # ffffffffc0207f70 <etext+0x1ace>
}
ffffffffc0204336:	0141                	addi	sp,sp,16
    cprintf("cond_wait end:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0204338:	e61fb06f          	j	ffffffffc0200198 <cprintf>
       up(&(cvp->owner->mutex));
ffffffffc020433c:	144000ef          	jal	ffffffffc0204480 <up>
ffffffffc0204340:	bfe1                	j	ffffffffc0204318 <cond_wait+0x30>

ffffffffc0204342 <__down.constprop.0>:
        }
    }
    local_intr_restore(intr_flag);
}

static __noinline uint32_t __down(semaphore_t *sem, uint32_t wait_state) {
ffffffffc0204342:	711d                	addi	sp,sp,-96
ffffffffc0204344:	ec86                	sd	ra,88(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204346:	100027f3          	csrr	a5,sstatus
ffffffffc020434a:	8b89                	andi	a5,a5,2
ffffffffc020434c:	eba1                	bnez	a5,ffffffffc020439c <__down.constprop.0+0x5a>
    bool intr_flag;
    local_intr_save(intr_flag);
    if (sem->value > 0) {
ffffffffc020434e:	411c                	lw	a5,0(a0)
ffffffffc0204350:	00f05863          	blez	a5,ffffffffc0204360 <__down.constprop.0+0x1e>
        sem->value --;
ffffffffc0204354:	37fd                	addiw	a5,a5,-1
ffffffffc0204356:	c11c                	sw	a5,0(a0)

    if (wait->wakeup_flags != wait_state) {
        return wait->wakeup_flags;
    }
    return 0;
}
ffffffffc0204358:	60e6                	ld	ra,88(sp)
        return 0;
ffffffffc020435a:	4501                	li	a0,0
}
ffffffffc020435c:	6125                	addi	sp,sp,96
ffffffffc020435e:	8082                	ret
    wait_current_set(&(sem->wait_queue), wait, wait_state);
ffffffffc0204360:	0521                	addi	a0,a0,8
ffffffffc0204362:	082c                	addi	a1,sp,24
ffffffffc0204364:	10000613          	li	a2,256
ffffffffc0204368:	e8a2                	sd	s0,80(sp)
ffffffffc020436a:	e4a6                	sd	s1,72(sp)
ffffffffc020436c:	0820                	addi	s0,sp,24
ffffffffc020436e:	84aa                	mv	s1,a0
ffffffffc0204370:	1f4000ef          	jal	ffffffffc0204564 <wait_current_set>
    schedule();
ffffffffc0204374:	035010ef          	jal	ffffffffc0205ba8 <schedule>
ffffffffc0204378:	100027f3          	csrr	a5,sstatus
ffffffffc020437c:	8b89                	andi	a5,a5,2
ffffffffc020437e:	efa9                	bnez	a5,ffffffffc02043d8 <__down.constprop.0+0x96>
    wait_current_del(&(sem->wait_queue), wait);
ffffffffc0204380:	8522                	mv	a0,s0
ffffffffc0204382:	186000ef          	jal	ffffffffc0204508 <wait_in_queue>
ffffffffc0204386:	e521                	bnez	a0,ffffffffc02043ce <__down.constprop.0+0x8c>
    if (wait->wakeup_flags != wait_state) {
ffffffffc0204388:	5502                	lw	a0,32(sp)
ffffffffc020438a:	10000793          	li	a5,256
ffffffffc020438e:	6446                	ld	s0,80(sp)
ffffffffc0204390:	64a6                	ld	s1,72(sp)
ffffffffc0204392:	fcf503e3          	beq	a0,a5,ffffffffc0204358 <__down.constprop.0+0x16>
}
ffffffffc0204396:	60e6                	ld	ra,88(sp)
ffffffffc0204398:	6125                	addi	sp,sp,96
ffffffffc020439a:	8082                	ret
ffffffffc020439c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020439e:	d60fc0ef          	jal	ffffffffc02008fe <intr_disable>
    if (sem->value > 0) {
ffffffffc02043a2:	6522                	ld	a0,8(sp)
ffffffffc02043a4:	411c                	lw	a5,0(a0)
ffffffffc02043a6:	00f05763          	blez	a5,ffffffffc02043b4 <__down.constprop.0+0x72>
        sem->value --;
ffffffffc02043aa:	37fd                	addiw	a5,a5,-1
ffffffffc02043ac:	c11c                	sw	a5,0(a0)
        intr_enable();
ffffffffc02043ae:	d4afc0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc02043b2:	b75d                	j	ffffffffc0204358 <__down.constprop.0+0x16>
    wait_current_set(&(sem->wait_queue), wait, wait_state);
ffffffffc02043b4:	0521                	addi	a0,a0,8
ffffffffc02043b6:	082c                	addi	a1,sp,24
ffffffffc02043b8:	10000613          	li	a2,256
ffffffffc02043bc:	e8a2                	sd	s0,80(sp)
ffffffffc02043be:	e4a6                	sd	s1,72(sp)
ffffffffc02043c0:	0820                	addi	s0,sp,24
ffffffffc02043c2:	84aa                	mv	s1,a0
ffffffffc02043c4:	1a0000ef          	jal	ffffffffc0204564 <wait_current_set>
ffffffffc02043c8:	d30fc0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc02043cc:	b765                	j	ffffffffc0204374 <__down.constprop.0+0x32>
    wait_current_del(&(sem->wait_queue), wait);
ffffffffc02043ce:	85a2                	mv	a1,s0
ffffffffc02043d0:	8526                	mv	a0,s1
ffffffffc02043d2:	0e8000ef          	jal	ffffffffc02044ba <wait_queue_del>
    if (flag) {
ffffffffc02043d6:	bf4d                	j	ffffffffc0204388 <__down.constprop.0+0x46>
        intr_disable();
ffffffffc02043d8:	d26fc0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc02043dc:	8522                	mv	a0,s0
ffffffffc02043de:	12a000ef          	jal	ffffffffc0204508 <wait_in_queue>
ffffffffc02043e2:	e501                	bnez	a0,ffffffffc02043ea <__down.constprop.0+0xa8>
        intr_enable();
ffffffffc02043e4:	d14fc0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc02043e8:	b745                	j	ffffffffc0204388 <__down.constprop.0+0x46>
ffffffffc02043ea:	85a2                	mv	a1,s0
ffffffffc02043ec:	8526                	mv	a0,s1
ffffffffc02043ee:	0cc000ef          	jal	ffffffffc02044ba <wait_queue_del>
    if (flag) {
ffffffffc02043f2:	bfcd                	j	ffffffffc02043e4 <__down.constprop.0+0xa2>

ffffffffc02043f4 <__up.constprop.0>:
static __noinline void __up(semaphore_t *sem, uint32_t wait_state) {
ffffffffc02043f4:	1101                	addi	sp,sp,-32
ffffffffc02043f6:	e426                	sd	s1,8(sp)
ffffffffc02043f8:	ec06                	sd	ra,24(sp)
ffffffffc02043fa:	e822                	sd	s0,16(sp)
ffffffffc02043fc:	e04a                	sd	s2,0(sp)
ffffffffc02043fe:	84aa                	mv	s1,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204400:	100027f3          	csrr	a5,sstatus
ffffffffc0204404:	8b89                	andi	a5,a5,2
ffffffffc0204406:	4901                	li	s2,0
ffffffffc0204408:	e7b1                	bnez	a5,ffffffffc0204454 <__up.constprop.0+0x60>
        if ((wait = wait_queue_first(&(sem->wait_queue))) == NULL) {
ffffffffc020440a:	00848413          	addi	s0,s1,8
ffffffffc020440e:	8522                	mv	a0,s0
ffffffffc0204410:	0e8000ef          	jal	ffffffffc02044f8 <wait_queue_first>
ffffffffc0204414:	cd05                	beqz	a0,ffffffffc020444c <__up.constprop.0+0x58>
            assert(wait->proc->wait_state == wait_state);
ffffffffc0204416:	6118                	ld	a4,0(a0)
ffffffffc0204418:	10000793          	li	a5,256
ffffffffc020441c:	0ec72603          	lw	a2,236(a4)
ffffffffc0204420:	02f61e63          	bne	a2,a5,ffffffffc020445c <__up.constprop.0+0x68>
            wakeup_wait(&(sem->wait_queue), wait, wait_state, 1);
ffffffffc0204424:	85aa                	mv	a1,a0
ffffffffc0204426:	4685                	li	a3,1
ffffffffc0204428:	8522                	mv	a0,s0
ffffffffc020442a:	0ec000ef          	jal	ffffffffc0204516 <wakeup_wait>
    if (flag) {
ffffffffc020442e:	00091863          	bnez	s2,ffffffffc020443e <__up.constprop.0+0x4a>
}
ffffffffc0204432:	60e2                	ld	ra,24(sp)
ffffffffc0204434:	6442                	ld	s0,16(sp)
ffffffffc0204436:	64a2                	ld	s1,8(sp)
ffffffffc0204438:	6902                	ld	s2,0(sp)
ffffffffc020443a:	6105                	addi	sp,sp,32
ffffffffc020443c:	8082                	ret
ffffffffc020443e:	6442                	ld	s0,16(sp)
ffffffffc0204440:	60e2                	ld	ra,24(sp)
ffffffffc0204442:	64a2                	ld	s1,8(sp)
ffffffffc0204444:	6902                	ld	s2,0(sp)
ffffffffc0204446:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204448:	cb0fc06f          	j	ffffffffc02008f8 <intr_enable>
            sem->value ++;
ffffffffc020444c:	409c                	lw	a5,0(s1)
ffffffffc020444e:	2785                	addiw	a5,a5,1
ffffffffc0204450:	c09c                	sw	a5,0(s1)
ffffffffc0204452:	bff1                	j	ffffffffc020442e <__up.constprop.0+0x3a>
        intr_disable();
ffffffffc0204454:	caafc0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc0204458:	4905                	li	s2,1
ffffffffc020445a:	bf45                	j	ffffffffc020440a <__up.constprop.0+0x16>
            assert(wait->proc->wait_state == wait_state);
ffffffffc020445c:	00004697          	auipc	a3,0x4
ffffffffc0204460:	b5c68693          	addi	a3,a3,-1188 # ffffffffc0207fb8 <etext+0x1b16>
ffffffffc0204464:	00003617          	auipc	a2,0x3
ffffffffc0204468:	a1460613          	addi	a2,a2,-1516 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc020446c:	45e5                	li	a1,25
ffffffffc020446e:	00004517          	auipc	a0,0x4
ffffffffc0204472:	b7250513          	addi	a0,a0,-1166 # ffffffffc0207fe0 <etext+0x1b3e>
ffffffffc0204476:	fd5fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020447a <sem_init>:
    sem->value = value;
ffffffffc020447a:	c10c                	sw	a1,0(a0)
    wait_queue_init(&(sem->wait_queue));
ffffffffc020447c:	0521                	addi	a0,a0,8
ffffffffc020447e:	a81d                	j	ffffffffc02044b4 <wait_queue_init>

ffffffffc0204480 <up>:

void
up(semaphore_t *sem) {
    __up(sem, WT_KSEM);
ffffffffc0204480:	f75ff06f          	j	ffffffffc02043f4 <__up.constprop.0>

ffffffffc0204484 <down>:
}

void
down(semaphore_t *sem) {
ffffffffc0204484:	1141                	addi	sp,sp,-16
ffffffffc0204486:	e406                	sd	ra,8(sp)
    uint32_t flags = __down(sem, WT_KSEM);
ffffffffc0204488:	ebbff0ef          	jal	ffffffffc0204342 <__down.constprop.0>
    assert(flags == 0);
ffffffffc020448c:	e501                	bnez	a0,ffffffffc0204494 <down+0x10>
}
ffffffffc020448e:	60a2                	ld	ra,8(sp)
ffffffffc0204490:	0141                	addi	sp,sp,16
ffffffffc0204492:	8082                	ret
    assert(flags == 0);
ffffffffc0204494:	00004697          	auipc	a3,0x4
ffffffffc0204498:	b5c68693          	addi	a3,a3,-1188 # ffffffffc0207ff0 <etext+0x1b4e>
ffffffffc020449c:	00003617          	auipc	a2,0x3
ffffffffc02044a0:	9dc60613          	addi	a2,a2,-1572 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02044a4:	04000593          	li	a1,64
ffffffffc02044a8:	00004517          	auipc	a0,0x4
ffffffffc02044ac:	b3850513          	addi	a0,a0,-1224 # ffffffffc0207fe0 <etext+0x1b3e>
ffffffffc02044b0:	f9bfb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02044b4 <wait_queue_init>:
    elm->prev = elm->next = elm;
ffffffffc02044b4:	e508                	sd	a0,8(a0)
ffffffffc02044b6:	e108                	sd	a0,0(a0)
}

void
wait_queue_init(wait_queue_t *queue) {
    list_init(&(queue->wait_head));
}
ffffffffc02044b8:	8082                	ret

ffffffffc02044ba <wait_queue_del>:
    return list->next == list;
ffffffffc02044ba:	7198                	ld	a4,32(a1)
    list_add_before(&(queue->wait_head), &(wait->wait_link));
}

void
wait_queue_del(wait_queue_t *queue, wait_t *wait) {
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
ffffffffc02044bc:	01858793          	addi	a5,a1,24
ffffffffc02044c0:	00e78b63          	beq	a5,a4,ffffffffc02044d6 <wait_queue_del+0x1c>
ffffffffc02044c4:	6994                	ld	a3,16(a1)
ffffffffc02044c6:	00a69863          	bne	a3,a0,ffffffffc02044d6 <wait_queue_del+0x1c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02044ca:	6d94                	ld	a3,24(a1)
    prev->next = next;
ffffffffc02044cc:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02044ce:	e314                	sd	a3,0(a4)
    elm->prev = elm->next = elm;
ffffffffc02044d0:	f19c                	sd	a5,32(a1)
ffffffffc02044d2:	ed9c                	sd	a5,24(a1)
ffffffffc02044d4:	8082                	ret
wait_queue_del(wait_queue_t *queue, wait_t *wait) {
ffffffffc02044d6:	1141                	addi	sp,sp,-16
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
ffffffffc02044d8:	00004697          	auipc	a3,0x4
ffffffffc02044dc:	b7868693          	addi	a3,a3,-1160 # ffffffffc0208050 <etext+0x1bae>
ffffffffc02044e0:	00003617          	auipc	a2,0x3
ffffffffc02044e4:	99860613          	addi	a2,a2,-1640 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02044e8:	45f1                	li	a1,28
ffffffffc02044ea:	00004517          	auipc	a0,0x4
ffffffffc02044ee:	b4e50513          	addi	a0,a0,-1202 # ffffffffc0208038 <etext+0x1b96>
wait_queue_del(wait_queue_t *queue, wait_t *wait) {
ffffffffc02044f2:	e406                	sd	ra,8(sp)
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
ffffffffc02044f4:	f57fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02044f8 <wait_queue_first>:
    return listelm->next;
ffffffffc02044f8:	651c                	ld	a5,8(a0)
}

wait_t *
wait_queue_first(wait_queue_t *queue) {
    list_entry_t *le = list_next(&(queue->wait_head));
    if (le != &(queue->wait_head)) {
ffffffffc02044fa:	00f50563          	beq	a0,a5,ffffffffc0204504 <wait_queue_first+0xc>
        return le2wait(le, wait_link);
ffffffffc02044fe:	fe878513          	addi	a0,a5,-24
ffffffffc0204502:	8082                	ret
    }
    return NULL;
ffffffffc0204504:	4501                	li	a0,0
}
ffffffffc0204506:	8082                	ret

ffffffffc0204508 <wait_in_queue>:
    return list_empty(&(queue->wait_head));
}

bool
wait_in_queue(wait_t *wait) {
    return !list_empty(&(wait->wait_link));
ffffffffc0204508:	711c                	ld	a5,32(a0)
ffffffffc020450a:	0561                	addi	a0,a0,24
ffffffffc020450c:	40a78533          	sub	a0,a5,a0
}
ffffffffc0204510:	00a03533          	snez	a0,a0
ffffffffc0204514:	8082                	ret

ffffffffc0204516 <wakeup_wait>:

void
wakeup_wait(wait_queue_t *queue, wait_t *wait, uint32_t wakeup_flags, bool del) {
    if (del) {
ffffffffc0204516:	e689                	bnez	a3,ffffffffc0204520 <wakeup_wait+0xa>
        wait_queue_del(queue, wait);
    }
    wait->wakeup_flags = wakeup_flags;
    wakeup_proc(wait->proc);
ffffffffc0204518:	6188                	ld	a0,0(a1)
    wait->wakeup_flags = wakeup_flags;
ffffffffc020451a:	c590                	sw	a2,8(a1)
    wakeup_proc(wait->proc);
ffffffffc020451c:	5940106f          	j	ffffffffc0205ab0 <wakeup_proc>
    return list->next == list;
ffffffffc0204520:	7198                	ld	a4,32(a1)
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
ffffffffc0204522:	01858793          	addi	a5,a1,24
ffffffffc0204526:	00e78e63          	beq	a5,a4,ffffffffc0204542 <wakeup_wait+0x2c>
ffffffffc020452a:	6994                	ld	a3,16(a1)
ffffffffc020452c:	00d51b63          	bne	a0,a3,ffffffffc0204542 <wakeup_wait+0x2c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204530:	6d94                	ld	a3,24(a1)
    wakeup_proc(wait->proc);
ffffffffc0204532:	6188                	ld	a0,0(a1)
    prev->next = next;
ffffffffc0204534:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0204536:	e314                	sd	a3,0(a4)
    elm->prev = elm->next = elm;
ffffffffc0204538:	f19c                	sd	a5,32(a1)
ffffffffc020453a:	ed9c                	sd	a5,24(a1)
    wait->wakeup_flags = wakeup_flags;
ffffffffc020453c:	c590                	sw	a2,8(a1)
    wakeup_proc(wait->proc);
ffffffffc020453e:	5720106f          	j	ffffffffc0205ab0 <wakeup_proc>
wakeup_wait(wait_queue_t *queue, wait_t *wait, uint32_t wakeup_flags, bool del) {
ffffffffc0204542:	1141                	addi	sp,sp,-16
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
ffffffffc0204544:	00004697          	auipc	a3,0x4
ffffffffc0204548:	b0c68693          	addi	a3,a3,-1268 # ffffffffc0208050 <etext+0x1bae>
ffffffffc020454c:	00003617          	auipc	a2,0x3
ffffffffc0204550:	92c60613          	addi	a2,a2,-1748 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0204554:	45f1                	li	a1,28
ffffffffc0204556:	00004517          	auipc	a0,0x4
ffffffffc020455a:	ae250513          	addi	a0,a0,-1310 # ffffffffc0208038 <etext+0x1b96>
wakeup_wait(wait_queue_t *queue, wait_t *wait, uint32_t wakeup_flags, bool del) {
ffffffffc020455e:	e406                	sd	ra,8(sp)
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
ffffffffc0204560:	eebfb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0204564 <wait_current_set>:
    }
}

void
wait_current_set(wait_queue_t *queue, wait_t *wait, uint32_t wait_state) {
    assert(current != NULL);
ffffffffc0204564:	000c8797          	auipc	a5,0xc8
ffffffffc0204568:	dec7b783          	ld	a5,-532(a5) # ffffffffc02cc350 <current>
ffffffffc020456c:	c39d                	beqz	a5,ffffffffc0204592 <wait_current_set+0x2e>
    wait->wakeup_flags = WT_INTERRUPTED;
ffffffffc020456e:	80000737          	lui	a4,0x80000
ffffffffc0204572:	c598                	sw	a4,8(a1)
    list_init(&(wait->wait_link));
ffffffffc0204574:	01858713          	addi	a4,a1,24
ffffffffc0204578:	ed98                	sd	a4,24(a1)
    wait->proc = proc;
ffffffffc020457a:	e19c                	sd	a5,0(a1)
    wait_init(wait, current);
    current->state = PROC_SLEEPING;
    current->wait_state = wait_state;
ffffffffc020457c:	0ec7a623          	sw	a2,236(a5)
    current->state = PROC_SLEEPING;
ffffffffc0204580:	4605                	li	a2,1
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204582:	6114                	ld	a3,0(a0)
ffffffffc0204584:	c390                	sw	a2,0(a5)
    wait->wait_queue = queue;
ffffffffc0204586:	e988                	sd	a0,16(a1)
    prev->next = next->prev = elm;
ffffffffc0204588:	e118                	sd	a4,0(a0)
ffffffffc020458a:	e698                	sd	a4,8(a3)
    elm->prev = prev;
ffffffffc020458c:	ed94                	sd	a3,24(a1)
    elm->next = next;
ffffffffc020458e:	f188                	sd	a0,32(a1)
ffffffffc0204590:	8082                	ret
wait_current_set(wait_queue_t *queue, wait_t *wait, uint32_t wait_state) {
ffffffffc0204592:	1141                	addi	sp,sp,-16
    assert(current != NULL);
ffffffffc0204594:	00004697          	auipc	a3,0x4
ffffffffc0204598:	afc68693          	addi	a3,a3,-1284 # ffffffffc0208090 <etext+0x1bee>
ffffffffc020459c:	00003617          	auipc	a2,0x3
ffffffffc02045a0:	8dc60613          	addi	a2,a2,-1828 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02045a4:	07400593          	li	a1,116
ffffffffc02045a8:	00004517          	auipc	a0,0x4
ffffffffc02045ac:	a9050513          	addi	a0,a0,-1392 # ffffffffc0208038 <etext+0x1b96>
wait_current_set(wait_queue_t *queue, wait_t *wait, uint32_t wait_state) {
ffffffffc02045b0:	e406                	sd	ra,8(sp)
    assert(current != NULL);
ffffffffc02045b2:	e99fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02045b6 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc02045b6:	8526                	mv	a0,s1
	jalr s0
ffffffffc02045b8:	9402                	jalr	s0

	jal do_exit
ffffffffc02045ba:	67a000ef          	jal	ffffffffc0204c34 <do_exit>

ffffffffc02045be <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc02045be:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02045c0:	14800513          	li	a0,328
{
ffffffffc02045c4:	e022                	sd	s0,0(sp)
ffffffffc02045c6:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc02045c8:	decfd0ef          	jal	ffffffffc0201bb4 <kmalloc>
ffffffffc02045cc:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc02045ce:	cd35                	beqz	a0,ffffffffc020464a <alloc_proc+0x8c>
         *       struct trapframe *tf;                       // Trap frame for current interrupt
         *       uintptr_t pgdir;                            // the base addr of Page Directroy Table(PDT)
         *       uint32_t flags;                             // Process flag
         *       char name[PROC_NAME_LEN + 1];               // Process name
         */
        proc->state = PROC_UNINIT;
ffffffffc02045d0:	57fd                	li	a5,-1
ffffffffc02045d2:	1782                	slli	a5,a5,0x20
ffffffffc02045d4:	e11c                	sd	a5,0(a0)
        proc->pid = -1;
        proc->runs = 0;
ffffffffc02045d6:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc02045da:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc02045de:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc02045e2:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc02045e6:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc02045ea:	07000613          	li	a2,112
ffffffffc02045ee:	4581                	li	a1,0
ffffffffc02045f0:	03050513          	addi	a0,a0,48
ffffffffc02045f4:	685010ef          	jal	ffffffffc0206478 <memset>
        proc->tf = NULL;
        proc->pgdir = boot_pgdir_pa;
ffffffffc02045f8:	000c8797          	auipc	a5,0xc8
ffffffffc02045fc:	d287b783          	ld	a5,-728(a5) # ffffffffc02cc320 <boot_pgdir_pa>
        proc->tf = NULL;
ffffffffc0204600:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;
ffffffffc0204604:	0a042823          	sw	zero,176(s0)
        proc->pgdir = boot_pgdir_pa;
ffffffffc0204608:	f45c                	sd	a5,168(s0)
        memset(proc->name, 0, sizeof(proc->name));
ffffffffc020460a:	0b440513          	addi	a0,s0,180
ffffffffc020460e:	4641                	li	a2,16
ffffffffc0204610:	4581                	li	a1,0
ffffffffc0204612:	667010ef          	jal	ffffffffc0206478 <memset>
         *       skew_heap_entry_t lab6_run_pool;            // entry in the run pool (lab6 stride)
         *       uint32_t lab6_stride;                       // stride value (lab6 stride)
         *       uint32_t lab6_priority;                     // priority value (lab6 stride)
         */
        proc->rq = NULL;
        list_init(&(proc->run_link));
ffffffffc0204616:	11040793          	addi	a5,s0,272
        proc->wait_state = 0;
ffffffffc020461a:	0e042623          	sw	zero,236(s0)
        proc->cptr = proc->optr = proc->yptr = NULL;
ffffffffc020461e:	0e043c23          	sd	zero,248(s0)
ffffffffc0204622:	10043023          	sd	zero,256(s0)
ffffffffc0204626:	0e043823          	sd	zero,240(s0)
        proc->rq = NULL;
ffffffffc020462a:	10043423          	sd	zero,264(s0)
        proc->time_slice = 0;
ffffffffc020462e:	12042023          	sw	zero,288(s0)
        proc->lab6_run_pool.left = proc->lab6_run_pool.right = proc->lab6_run_pool.parent = NULL;
ffffffffc0204632:	12043423          	sd	zero,296(s0)
ffffffffc0204636:	12043c23          	sd	zero,312(s0)
ffffffffc020463a:	12043823          	sd	zero,304(s0)
        proc->lab6_stride = 0;
ffffffffc020463e:	14043023          	sd	zero,320(s0)
    elm->prev = elm->next = elm;
ffffffffc0204642:	10f43c23          	sd	a5,280(s0)
ffffffffc0204646:	10f43823          	sd	a5,272(s0)
        proc->lab6_priority = 0;

        
    }
    return proc;
}
ffffffffc020464a:	60a2                	ld	ra,8(sp)
ffffffffc020464c:	8522                	mv	a0,s0
ffffffffc020464e:	6402                	ld	s0,0(sp)
ffffffffc0204650:	0141                	addi	sp,sp,16
ffffffffc0204652:	8082                	ret

ffffffffc0204654 <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc0204654:	000c8797          	auipc	a5,0xc8
ffffffffc0204658:	cfc7b783          	ld	a5,-772(a5) # ffffffffc02cc350 <current>
ffffffffc020465c:	73c8                	ld	a0,160(a5)
ffffffffc020465e:	fe4fc06f          	j	ffffffffc0200e42 <forkrets>

ffffffffc0204662 <put_pgdir.isra.0>:
    return 0;
}

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm)
ffffffffc0204662:	1141                	addi	sp,sp,-16
ffffffffc0204664:	e406                	sd	ra,8(sp)
    return pa2page(PADDR(kva));
ffffffffc0204666:	c02007b7          	lui	a5,0xc0200
ffffffffc020466a:	02f56f63          	bltu	a0,a5,ffffffffc02046a8 <put_pgdir.isra.0+0x46>
ffffffffc020466e:	000c8797          	auipc	a5,0xc8
ffffffffc0204672:	cc27b783          	ld	a5,-830(a5) # ffffffffc02cc330 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc0204676:	000c8717          	auipc	a4,0xc8
ffffffffc020467a:	cc273703          	ld	a4,-830(a4) # ffffffffc02cc338 <npage>
    return pa2page(PADDR(kva));
ffffffffc020467e:	8d1d                	sub	a0,a0,a5
    if (PPN(pa) >= npage)
ffffffffc0204680:	00c55793          	srli	a5,a0,0xc
ffffffffc0204684:	02e7ff63          	bgeu	a5,a4,ffffffffc02046c2 <put_pgdir.isra.0+0x60>
    return &pages[PPN(pa) - nbase];
ffffffffc0204688:	00005717          	auipc	a4,0x5
ffffffffc020468c:	be073703          	ld	a4,-1056(a4) # ffffffffc0209268 <nbase>
ffffffffc0204690:	000c8517          	auipc	a0,0xc8
ffffffffc0204694:	cb053503          	ld	a0,-848(a0) # ffffffffc02cc340 <pages>
{
    free_page(kva2page(mm->pgdir));
}
ffffffffc0204698:	60a2                	ld	ra,8(sp)
ffffffffc020469a:	8f99                	sub	a5,a5,a4
ffffffffc020469c:	079a                	slli	a5,a5,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc020469e:	4585                	li	a1,1
ffffffffc02046a0:	953e                	add	a0,a0,a5
}
ffffffffc02046a2:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc02046a4:	f0cfd06f          	j	ffffffffc0201db0 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc02046a8:	86aa                	mv	a3,a0
ffffffffc02046aa:	00003617          	auipc	a2,0x3
ffffffffc02046ae:	c2660613          	addi	a2,a2,-986 # ffffffffc02072d0 <etext+0xe2e>
ffffffffc02046b2:	07700593          	li	a1,119
ffffffffc02046b6:	00003517          	auipc	a0,0x3
ffffffffc02046ba:	b9a50513          	addi	a0,a0,-1126 # ffffffffc0207250 <etext+0xdae>
ffffffffc02046be:	d8dfb0ef          	jal	ffffffffc020044a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02046c2:	00003617          	auipc	a2,0x3
ffffffffc02046c6:	c3660613          	addi	a2,a2,-970 # ffffffffc02072f8 <etext+0xe56>
ffffffffc02046ca:	06900593          	li	a1,105
ffffffffc02046ce:	00003517          	auipc	a0,0x3
ffffffffc02046d2:	b8250513          	addi	a0,a0,-1150 # ffffffffc0207250 <etext+0xdae>
ffffffffc02046d6:	d75fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02046da <set_proc_name>:
{
ffffffffc02046da:	1101                	addi	sp,sp,-32
ffffffffc02046dc:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02046de:	0b450413          	addi	s0,a0,180
{
ffffffffc02046e2:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02046e4:	8522                	mv	a0,s0
{
ffffffffc02046e6:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02046e8:	4641                	li	a2,16
ffffffffc02046ea:	4581                	li	a1,0
{
ffffffffc02046ec:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02046ee:	58b010ef          	jal	ffffffffc0206478 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02046f2:	8522                	mv	a0,s0
}
ffffffffc02046f4:	6442                	ld	s0,16(sp)
ffffffffc02046f6:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02046f8:	85a6                	mv	a1,s1
}
ffffffffc02046fa:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02046fc:	463d                	li	a2,15
}
ffffffffc02046fe:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204700:	58b0106f          	j	ffffffffc020648a <memcpy>

ffffffffc0204704 <proc_run>:
    if (proc != current)
ffffffffc0204704:	000c8697          	auipc	a3,0xc8
ffffffffc0204708:	c4c6b683          	ld	a3,-948(a3) # ffffffffc02cc350 <current>
ffffffffc020470c:	04a68463          	beq	a3,a0,ffffffffc0204754 <proc_run+0x50>
{
ffffffffc0204710:	1101                	addi	sp,sp,-32
ffffffffc0204712:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204714:	100027f3          	csrr	a5,sstatus
ffffffffc0204718:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020471a:	4601                	li	a2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020471c:	ef8d                	bnez	a5,ffffffffc0204756 <proc_run+0x52>
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned long pgdir)
{
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc020471e:	755c                	ld	a5,168(a0)
ffffffffc0204720:	577d                	li	a4,-1
ffffffffc0204722:	177e                	slli	a4,a4,0x3f
ffffffffc0204724:	83b1                	srli	a5,a5,0xc
ffffffffc0204726:	e032                	sd	a2,0(sp)
            current = proc;
ffffffffc0204728:	000c8597          	auipc	a1,0xc8
ffffffffc020472c:	c2a5b423          	sd	a0,-984(a1) # ffffffffc02cc350 <current>
ffffffffc0204730:	8fd9                	or	a5,a5,a4
ffffffffc0204732:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0204736:	03050593          	addi	a1,a0,48
ffffffffc020473a:	03068513          	addi	a0,a3,48
ffffffffc020473e:	2aa010ef          	jal	ffffffffc02059e8 <switch_to>
    if (flag) {
ffffffffc0204742:	6602                	ld	a2,0(sp)
ffffffffc0204744:	e601                	bnez	a2,ffffffffc020474c <proc_run+0x48>
}
ffffffffc0204746:	60e2                	ld	ra,24(sp)
ffffffffc0204748:	6105                	addi	sp,sp,32
ffffffffc020474a:	8082                	ret
ffffffffc020474c:	60e2                	ld	ra,24(sp)
ffffffffc020474e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204750:	9a8fc06f          	j	ffffffffc02008f8 <intr_enable>
ffffffffc0204754:	8082                	ret
ffffffffc0204756:	e42a                	sd	a0,8(sp)
ffffffffc0204758:	e036                	sd	a3,0(sp)
        intr_disable();
ffffffffc020475a:	9a4fc0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc020475e:	6522                	ld	a0,8(sp)
ffffffffc0204760:	6682                	ld	a3,0(sp)
ffffffffc0204762:	4605                	li	a2,1
ffffffffc0204764:	bf6d                	j	ffffffffc020471e <proc_run+0x1a>

ffffffffc0204766 <find_proc>:
    if (0 < pid && pid < MAX_PID)
ffffffffc0204766:	6789                	lui	a5,0x2
ffffffffc0204768:	fff5071b          	addiw	a4,a0,-1
ffffffffc020476c:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x70ea>
ffffffffc020476e:	02e7ef63          	bltu	a5,a4,ffffffffc02047ac <find_proc+0x46>
{
ffffffffc0204772:	1101                	addi	sp,sp,-32
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204774:	45a9                	li	a1,10
{
ffffffffc0204776:	ec06                	sd	ra,24(sp)
ffffffffc0204778:	e42a                	sd	a0,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020477a:	069010ef          	jal	ffffffffc0205fe2 <hash32>
ffffffffc020477e:	02051793          	slli	a5,a0,0x20
ffffffffc0204782:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0204786:	000c4797          	auipc	a5,0xc4
ffffffffc020478a:	b2a78793          	addi	a5,a5,-1238 # ffffffffc02c82b0 <hash_list>
ffffffffc020478e:	96be                	add	a3,a3,a5
        while ((le = list_next(le)) != list)
ffffffffc0204790:	6622                	ld	a2,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204792:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0204794:	a029                	j	ffffffffc020479e <find_proc+0x38>
            if (proc->pid == pid)
ffffffffc0204796:	f2c7a703          	lw	a4,-212(a5)
ffffffffc020479a:	00c70b63          	beq	a4,a2,ffffffffc02047b0 <find_proc+0x4a>
    return listelm->next;
ffffffffc020479e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02047a0:	fef69be3          	bne	a3,a5,ffffffffc0204796 <find_proc+0x30>
}
ffffffffc02047a4:	60e2                	ld	ra,24(sp)
    return NULL;
ffffffffc02047a6:	4501                	li	a0,0
}
ffffffffc02047a8:	6105                	addi	sp,sp,32
ffffffffc02047aa:	8082                	ret
    return NULL;
ffffffffc02047ac:	4501                	li	a0,0
}
ffffffffc02047ae:	8082                	ret
ffffffffc02047b0:	60e2                	ld	ra,24(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02047b2:	f2878513          	addi	a0,a5,-216
}
ffffffffc02047b6:	6105                	addi	sp,sp,32
ffffffffc02047b8:	8082                	ret

ffffffffc02047ba <do_fork>:
 */
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf)
{
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS)
ffffffffc02047ba:	000c8717          	auipc	a4,0xc8
ffffffffc02047be:	b8e72703          	lw	a4,-1138(a4) # ffffffffc02cc348 <nr_process>
ffffffffc02047c2:	6785                	lui	a5,0x1
ffffffffc02047c4:	36f75763          	bge	a4,a5,ffffffffc0204b32 <do_fork+0x378>
{
ffffffffc02047c8:	7159                	addi	sp,sp,-112
ffffffffc02047ca:	f0a2                	sd	s0,96(sp)
ffffffffc02047cc:	eca6                	sd	s1,88(sp)
ffffffffc02047ce:	e8ca                	sd	s2,80(sp)
ffffffffc02047d0:	ec66                	sd	s9,24(sp)
ffffffffc02047d2:	f486                	sd	ra,104(sp)
ffffffffc02047d4:	892e                	mv	s2,a1
ffffffffc02047d6:	84b2                	mv	s1,a2
ffffffffc02047d8:	8caa                	mv	s9,a0
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid

    if ((proc = alloc_proc()) == NULL) {
ffffffffc02047da:	de5ff0ef          	jal	ffffffffc02045be <alloc_proc>
ffffffffc02047de:	842a                	mv	s0,a0
ffffffffc02047e0:	34050163          	beqz	a0,ffffffffc0204b22 <do_fork+0x368>
        goto fork_out;
    }
    proc->parent = current;
ffffffffc02047e4:	fc56                	sd	s5,56(sp)
ffffffffc02047e6:	000c8a97          	auipc	s5,0xc8
ffffffffc02047ea:	b6aa8a93          	addi	s5,s5,-1174 # ffffffffc02cc350 <current>
ffffffffc02047ee:	000ab783          	ld	a5,0(s5)
    assert(current->wait_state == 0);
ffffffffc02047f2:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_softint_out_size-0x7ffc>
    proc->parent = current;
ffffffffc02047f6:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc02047f8:	32071f63          	bnez	a4,ffffffffc0204b36 <do_fork+0x37c>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02047fc:	4509                	li	a0,2
ffffffffc02047fe:	d78fd0ef          	jal	ffffffffc0201d76 <alloc_pages>
    if (page != NULL)
ffffffffc0204802:	30050c63          	beqz	a0,ffffffffc0204b1a <do_fork+0x360>
    return page - pages + nbase;
ffffffffc0204806:	f85a                	sd	s6,48(sp)
ffffffffc0204808:	000c8b17          	auipc	s6,0xc8
ffffffffc020480c:	b38b0b13          	addi	s6,s6,-1224 # ffffffffc02cc340 <pages>
ffffffffc0204810:	000b3783          	ld	a5,0(s6)
ffffffffc0204814:	e4ce                	sd	s3,72(sp)
ffffffffc0204816:	00005997          	auipc	s3,0x5
ffffffffc020481a:	a529b983          	ld	s3,-1454(s3) # ffffffffc0209268 <nbase>
ffffffffc020481e:	40f506b3          	sub	a3,a0,a5
ffffffffc0204822:	f45e                	sd	s7,40(sp)
    return KADDR(page2pa(page));
ffffffffc0204824:	000c8b97          	auipc	s7,0xc8
ffffffffc0204828:	b14b8b93          	addi	s7,s7,-1260 # ffffffffc02cc338 <npage>
    return page - pages + nbase;
ffffffffc020482c:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020482e:	57fd                	li	a5,-1
ffffffffc0204830:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc0204834:	96ce                	add	a3,a3,s3
    return KADDR(page2pa(page));
ffffffffc0204836:	83b1                	srli	a5,a5,0xc
ffffffffc0204838:	00f6f633          	and	a2,a3,a5
ffffffffc020483c:	e0d2                	sd	s4,64(sp)
ffffffffc020483e:	f062                	sd	s8,32(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc0204840:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204842:	34e67b63          	bgeu	a2,a4,ffffffffc0204b98 <do_fork+0x3de>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204846:	000ab603          	ld	a2,0(s5)
ffffffffc020484a:	000c8c17          	auipc	s8,0xc8
ffffffffc020484e:	ae6c0c13          	addi	s8,s8,-1306 # ffffffffc02cc330 <va_pa_offset>
ffffffffc0204852:	000c3703          	ld	a4,0(s8)
ffffffffc0204856:	02863a03          	ld	s4,40(a2)
ffffffffc020485a:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc020485c:	e814                	sd	a3,16(s0)
    if (oldmm == NULL)
ffffffffc020485e:	020a0863          	beqz	s4,ffffffffc020488e <do_fork+0xd4>
    if (clone_flags & CLONE_VM)
ffffffffc0204862:	100cf713          	andi	a4,s9,256
ffffffffc0204866:	18070a63          	beqz	a4,ffffffffc02049fa <do_fork+0x240>
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc020486a:	030a2703          	lw	a4,48(s4)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc020486e:	018a3783          	ld	a5,24(s4)
ffffffffc0204872:	c02006b7          	lui	a3,0xc0200
ffffffffc0204876:	2705                	addiw	a4,a4,1
ffffffffc0204878:	02ea2823          	sw	a4,48(s4)
    proc->mm = mm;
ffffffffc020487c:	03443423          	sd	s4,40(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204880:	2ed7ee63          	bltu	a5,a3,ffffffffc0204b7c <do_fork+0x3c2>
ffffffffc0204884:	000c3703          	ld	a4,0(s8)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204888:	6814                	ld	a3,16(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc020488a:	8f99                	sub	a5,a5,a4
ffffffffc020488c:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc020488e:	6789                	lui	a5,0x2
ffffffffc0204890:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_softint_out_size-0x7208>
ffffffffc0204894:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204896:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204898:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc020489a:	87b6                	mv	a5,a3
ffffffffc020489c:	12048713          	addi	a4,s1,288
ffffffffc02048a0:	6a0c                	ld	a1,16(a2)
ffffffffc02048a2:	00063803          	ld	a6,0(a2)
ffffffffc02048a6:	6608                	ld	a0,8(a2)
ffffffffc02048a8:	eb8c                	sd	a1,16(a5)
ffffffffc02048aa:	0107b023          	sd	a6,0(a5)
ffffffffc02048ae:	e788                	sd	a0,8(a5)
ffffffffc02048b0:	6e0c                	ld	a1,24(a2)
ffffffffc02048b2:	02060613          	addi	a2,a2,32
ffffffffc02048b6:	02078793          	addi	a5,a5,32
ffffffffc02048ba:	feb7bc23          	sd	a1,-8(a5)
ffffffffc02048be:	fee611e3          	bne	a2,a4,ffffffffc02048a0 <do_fork+0xe6>
    proc->tf->gpr.a0 = 0;
ffffffffc02048c2:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x6>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02048c6:	1a090c63          	beqz	s2,ffffffffc0204a7e <do_fork+0x2c4>
ffffffffc02048ca:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02048ce:	00000797          	auipc	a5,0x0
ffffffffc02048d2:	d8678793          	addi	a5,a5,-634 # ffffffffc0204654 <forkret>
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02048d6:	fc14                	sd	a3,56(s0)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02048d8:	f81c                	sd	a5,48(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02048da:	100027f3          	csrr	a5,sstatus
ffffffffc02048de:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02048e0:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02048e2:	1a079d63          	bnez	a5,ffffffffc0204a9c <do_fork+0x2e2>
    if (++last_pid >= MAX_PID)
ffffffffc02048e6:	000c3517          	auipc	a0,0xc3
ffffffffc02048ea:	45e52503          	lw	a0,1118(a0) # ffffffffc02c7d44 <last_pid.1>
ffffffffc02048ee:	6789                	lui	a5,0x2
ffffffffc02048f0:	2505                	addiw	a0,a0,1
ffffffffc02048f2:	000c3717          	auipc	a4,0xc3
ffffffffc02048f6:	44a72923          	sw	a0,1106(a4) # ffffffffc02c7d44 <last_pid.1>
ffffffffc02048fa:	1cf55063          	bge	a0,a5,ffffffffc0204aba <do_fork+0x300>
    if (last_pid >= next_safe)
ffffffffc02048fe:	000c3797          	auipc	a5,0xc3
ffffffffc0204902:	4427a783          	lw	a5,1090(a5) # ffffffffc02c7d40 <next_safe.0>
ffffffffc0204906:	000c8497          	auipc	s1,0xc8
ffffffffc020490a:	9aa48493          	addi	s1,s1,-1622 # ffffffffc02cc2b0 <proc_list>
ffffffffc020490e:	06f54563          	blt	a0,a5,ffffffffc0204978 <do_fork+0x1be>
ffffffffc0204912:	000c8497          	auipc	s1,0xc8
ffffffffc0204916:	99e48493          	addi	s1,s1,-1634 # ffffffffc02cc2b0 <proc_list>
ffffffffc020491a:	0084b883          	ld	a7,8(s1)
        next_safe = MAX_PID;
ffffffffc020491e:	6789                	lui	a5,0x2
ffffffffc0204920:	000c3717          	auipc	a4,0xc3
ffffffffc0204924:	42f72023          	sw	a5,1056(a4) # ffffffffc02c7d40 <next_safe.0>
ffffffffc0204928:	86aa                	mv	a3,a0
ffffffffc020492a:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc020492c:	04988063          	beq	a7,s1,ffffffffc020496c <do_fork+0x1b2>
ffffffffc0204930:	882e                	mv	a6,a1
ffffffffc0204932:	87c6                	mv	a5,a7
ffffffffc0204934:	6609                	lui	a2,0x2
ffffffffc0204936:	a811                	j	ffffffffc020494a <do_fork+0x190>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc0204938:	00e6d663          	bge	a3,a4,ffffffffc0204944 <do_fork+0x18a>
ffffffffc020493c:	00c75463          	bge	a4,a2,ffffffffc0204944 <do_fork+0x18a>
                next_safe = proc->pid;
ffffffffc0204940:	863a                	mv	a2,a4
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc0204942:	4805                	li	a6,1
ffffffffc0204944:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204946:	00978d63          	beq	a5,s1,ffffffffc0204960 <do_fork+0x1a6>
            if (proc->pid == last_pid)
ffffffffc020494a:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_softint_out_size-0x71ac>
ffffffffc020494e:	fee695e3          	bne	a3,a4,ffffffffc0204938 <do_fork+0x17e>
                if (++last_pid >= next_safe)
ffffffffc0204952:	2685                	addiw	a3,a3,1
ffffffffc0204954:	1cc6d963          	bge	a3,a2,ffffffffc0204b26 <do_fork+0x36c>
ffffffffc0204958:	679c                	ld	a5,8(a5)
ffffffffc020495a:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc020495c:	fe9797e3          	bne	a5,s1,ffffffffc020494a <do_fork+0x190>
ffffffffc0204960:	00080663          	beqz	a6,ffffffffc020496c <do_fork+0x1b2>
ffffffffc0204964:	000c3797          	auipc	a5,0xc3
ffffffffc0204968:	3cc7ae23          	sw	a2,988(a5) # ffffffffc02c7d40 <next_safe.0>
ffffffffc020496c:	c591                	beqz	a1,ffffffffc0204978 <do_fork+0x1be>
ffffffffc020496e:	000c3797          	auipc	a5,0xc3
ffffffffc0204972:	3cd7ab23          	sw	a3,982(a5) # ffffffffc02c7d44 <last_pid.1>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc0204976:	8536                	mv	a0,a3
    copy_thread(proc, stack, tf);

    bool intr_flag;
    local_intr_save(intr_flag);
    {
        proc->pid = get_pid();
ffffffffc0204978:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc020497a:	45a9                	li	a1,10
ffffffffc020497c:	666010ef          	jal	ffffffffc0205fe2 <hash32>
ffffffffc0204980:	02051793          	slli	a5,a0,0x20
ffffffffc0204984:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204988:	000c4797          	auipc	a5,0xc4
ffffffffc020498c:	92878793          	addi	a5,a5,-1752 # ffffffffc02c82b0 <hash_list>
ffffffffc0204990:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204992:	6518                	ld	a4,8(a0)
ffffffffc0204994:	0d840793          	addi	a5,s0,216
ffffffffc0204998:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc020499a:	e31c                	sd	a5,0(a4)
ffffffffc020499c:	e51c                	sd	a5,8(a0)
    elm->next = next;
ffffffffc020499e:	f078                	sd	a4,224(s0)
    list_add(&proc_list, &(proc->list_link));
ffffffffc02049a0:	0c840793          	addi	a5,s0,200
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc02049a4:	7018                	ld	a4,32(s0)
    elm->prev = prev;
ffffffffc02049a6:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc02049a8:	e21c                	sd	a5,0(a2)
    proc->yptr = NULL;
ffffffffc02049aa:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc02049ae:	7b74                	ld	a3,240(a4)
ffffffffc02049b0:	e49c                	sd	a5,8(s1)
    elm->next = next;
ffffffffc02049b2:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc02049b4:	e464                	sd	s1,200(s0)
ffffffffc02049b6:	10d43023          	sd	a3,256(s0)
ffffffffc02049ba:	c299                	beqz	a3,ffffffffc02049c0 <do_fork+0x206>
        proc->optr->yptr = proc;
ffffffffc02049bc:	fee0                	sd	s0,248(a3)
    proc->parent->cptr = proc;
ffffffffc02049be:	7018                	ld	a4,32(s0)
    nr_process++;
ffffffffc02049c0:	000c8797          	auipc	a5,0xc8
ffffffffc02049c4:	9887a783          	lw	a5,-1656(a5) # ffffffffc02cc348 <nr_process>
    proc->parent->cptr = proc;
ffffffffc02049c8:	fb60                	sd	s0,240(a4)
    nr_process++;
ffffffffc02049ca:	2785                	addiw	a5,a5,1
ffffffffc02049cc:	000c8717          	auipc	a4,0xc8
ffffffffc02049d0:	96f72e23          	sw	a5,-1668(a4) # ffffffffc02cc348 <nr_process>
    if (flag) {
ffffffffc02049d4:	0e091963          	bnez	s2,ffffffffc0204ac6 <do_fork+0x30c>
        hash_proc(proc);
        set_links(proc);
    }
    local_intr_restore(intr_flag);

    wakeup_proc(proc);
ffffffffc02049d8:	8522                	mv	a0,s0
ffffffffc02049da:	0d6010ef          	jal	ffffffffc0205ab0 <wakeup_proc>

    ret = proc->pid;
ffffffffc02049de:	4048                	lw	a0,4(s0)
ffffffffc02049e0:	69a6                	ld	s3,72(sp)
ffffffffc02049e2:	6a06                	ld	s4,64(sp)
ffffffffc02049e4:	7ae2                	ld	s5,56(sp)
ffffffffc02049e6:	7b42                	ld	s6,48(sp)
ffffffffc02049e8:	7ba2                	ld	s7,40(sp)
ffffffffc02049ea:	7c02                	ld	s8,32(sp)
bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
ffffffffc02049ec:	70a6                	ld	ra,104(sp)
ffffffffc02049ee:	7406                	ld	s0,96(sp)
ffffffffc02049f0:	64e6                	ld	s1,88(sp)
ffffffffc02049f2:	6946                	ld	s2,80(sp)
ffffffffc02049f4:	6ce2                	ld	s9,24(sp)
ffffffffc02049f6:	6165                	addi	sp,sp,112
ffffffffc02049f8:	8082                	ret
    if ((mm = mm_create()) == NULL)
ffffffffc02049fa:	b43fe0ef          	jal	ffffffffc020353c <mm_create>
ffffffffc02049fe:	8caa                	mv	s9,a0
ffffffffc0204a00:	0e050163          	beqz	a0,ffffffffc0204ae2 <do_fork+0x328>
    if ((page = alloc_page()) == NULL)
ffffffffc0204a04:	4505                	li	a0,1
ffffffffc0204a06:	b70fd0ef          	jal	ffffffffc0201d76 <alloc_pages>
ffffffffc0204a0a:	c969                	beqz	a0,ffffffffc0204adc <do_fork+0x322>
    return page - pages + nbase;
ffffffffc0204a0c:	000b3683          	ld	a3,0(s6)
    return KADDR(page2pa(page));
ffffffffc0204a10:	57fd                	li	a5,-1
ffffffffc0204a12:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc0204a16:	40d506b3          	sub	a3,a0,a3
ffffffffc0204a1a:	8699                	srai	a3,a3,0x6
ffffffffc0204a1c:	96ce                	add	a3,a3,s3
    return KADDR(page2pa(page));
ffffffffc0204a1e:	83b1                	srli	a5,a5,0xc
ffffffffc0204a20:	8ff5                	and	a5,a5,a3
ffffffffc0204a22:	e86a                	sd	s10,16(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc0204a24:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204a26:	1ae7f363          	bgeu	a5,a4,ffffffffc0204bcc <do_fork+0x412>
ffffffffc0204a2a:	000c3783          	ld	a5,0(s8)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204a2e:	000c8597          	auipc	a1,0xc8
ffffffffc0204a32:	8fa5b583          	ld	a1,-1798(a1) # ffffffffc02cc328 <boot_pgdir_va>
ffffffffc0204a36:	6605                	lui	a2,0x1
ffffffffc0204a38:	96be                	add	a3,a3,a5
ffffffffc0204a3a:	8536                	mv	a0,a3
ffffffffc0204a3c:	e436                	sd	a3,8(sp)
ffffffffc0204a3e:	24d010ef          	jal	ffffffffc020648a <memcpy>
    mm->pgdir = pgdir;
ffffffffc0204a42:	66a2                	ld	a3,8(sp)
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        down(&(mm->mm_sem));
ffffffffc0204a44:	038a0513          	addi	a0,s4,56
ffffffffc0204a48:	038a0d13          	addi	s10,s4,56
ffffffffc0204a4c:	00dcbc23          	sd	a3,24(s9) # 200018 <_binary_obj___user_matrix_out_size+0x1f4930>
ffffffffc0204a50:	a35ff0ef          	jal	ffffffffc0204484 <down>
        if (current != NULL)
ffffffffc0204a54:	000ab783          	ld	a5,0(s5)
ffffffffc0204a58:	c781                	beqz	a5,ffffffffc0204a60 <do_fork+0x2a6>
        {
            mm->locked_by = current->pid;
ffffffffc0204a5a:	43dc                	lw	a5,4(a5)
ffffffffc0204a5c:	04fa2823          	sw	a5,80(s4)
        ret = dup_mmap(mm, oldmm);
ffffffffc0204a60:	85d2                	mv	a1,s4
ffffffffc0204a62:	8566                	mv	a0,s9
ffffffffc0204a64:	d43fe0ef          	jal	ffffffffc02037a6 <dup_mmap>
ffffffffc0204a68:	8aaa                	mv	s5,a0
static inline void
unlock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        up(&(mm->mm_sem));
ffffffffc0204a6a:	856a                	mv	a0,s10
ffffffffc0204a6c:	a15ff0ef          	jal	ffffffffc0204480 <up>
        mm->locked_by = 0;
ffffffffc0204a70:	040a2823          	sw	zero,80(s4)
    if ((mm = mm_create()) == NULL)
ffffffffc0204a74:	8a66                	mv	s4,s9
    if (ret != 0)
ffffffffc0204a76:	040a9b63          	bnez	s5,ffffffffc0204acc <do_fork+0x312>
ffffffffc0204a7a:	6d42                	ld	s10,16(sp)
ffffffffc0204a7c:	b3fd                	j	ffffffffc020486a <do_fork+0xb0>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204a7e:	8936                	mv	s2,a3
ffffffffc0204a80:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204a84:	00000797          	auipc	a5,0x0
ffffffffc0204a88:	bd078793          	addi	a5,a5,-1072 # ffffffffc0204654 <forkret>
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204a8c:	fc14                	sd	a3,56(s0)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204a8e:	f81c                	sd	a5,48(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204a90:	100027f3          	csrr	a5,sstatus
ffffffffc0204a94:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204a96:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204a98:	e40787e3          	beqz	a5,ffffffffc02048e6 <do_fork+0x12c>
        intr_disable();
ffffffffc0204a9c:	e63fb0ef          	jal	ffffffffc02008fe <intr_disable>
    if (++last_pid >= MAX_PID)
ffffffffc0204aa0:	000c3517          	auipc	a0,0xc3
ffffffffc0204aa4:	2a452503          	lw	a0,676(a0) # ffffffffc02c7d44 <last_pid.1>
ffffffffc0204aa8:	6789                	lui	a5,0x2
        return 1;
ffffffffc0204aaa:	4905                	li	s2,1
ffffffffc0204aac:	2505                	addiw	a0,a0,1
ffffffffc0204aae:	000c3717          	auipc	a4,0xc3
ffffffffc0204ab2:	28a72b23          	sw	a0,662(a4) # ffffffffc02c7d44 <last_pid.1>
ffffffffc0204ab6:	e4f544e3          	blt	a0,a5,ffffffffc02048fe <do_fork+0x144>
        last_pid = 1;
ffffffffc0204aba:	4505                	li	a0,1
ffffffffc0204abc:	000c3797          	auipc	a5,0xc3
ffffffffc0204ac0:	28a7a423          	sw	a0,648(a5) # ffffffffc02c7d44 <last_pid.1>
        goto inside;
ffffffffc0204ac4:	b5b9                	j	ffffffffc0204912 <do_fork+0x158>
        intr_enable();
ffffffffc0204ac6:	e33fb0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0204aca:	b739                	j	ffffffffc02049d8 <do_fork+0x21e>
    exit_mmap(mm);
ffffffffc0204acc:	8566                	mv	a0,s9
ffffffffc0204ace:	d71fe0ef          	jal	ffffffffc020383e <exit_mmap>
    put_pgdir(mm);
ffffffffc0204ad2:	018cb503          	ld	a0,24(s9)
ffffffffc0204ad6:	b8dff0ef          	jal	ffffffffc0204662 <put_pgdir.isra.0>
ffffffffc0204ada:	6d42                	ld	s10,16(sp)
    mm_destroy(mm);
ffffffffc0204adc:	8566                	mv	a0,s9
ffffffffc0204ade:	babfe0ef          	jal	ffffffffc0203688 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204ae2:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0204ae4:	c02007b7          	lui	a5,0xc0200
ffffffffc0204ae8:	0cf6e563          	bltu	a3,a5,ffffffffc0204bb2 <do_fork+0x3f8>
ffffffffc0204aec:	000c3783          	ld	a5,0(s8)
    if (PPN(pa) >= npage)
ffffffffc0204af0:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc0204af4:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage)
ffffffffc0204af8:	83b1                	srli	a5,a5,0xc
ffffffffc0204afa:	06e7f463          	bgeu	a5,a4,ffffffffc0204b62 <do_fork+0x3a8>
    return &pages[PPN(pa) - nbase];
ffffffffc0204afe:	000b3503          	ld	a0,0(s6)
ffffffffc0204b02:	413787b3          	sub	a5,a5,s3
ffffffffc0204b06:	079a                	slli	a5,a5,0x6
ffffffffc0204b08:	953e                	add	a0,a0,a5
ffffffffc0204b0a:	4589                	li	a1,2
ffffffffc0204b0c:	aa4fd0ef          	jal	ffffffffc0201db0 <free_pages>
}
ffffffffc0204b10:	69a6                	ld	s3,72(sp)
ffffffffc0204b12:	6a06                	ld	s4,64(sp)
ffffffffc0204b14:	7b42                	ld	s6,48(sp)
ffffffffc0204b16:	7ba2                	ld	s7,40(sp)
ffffffffc0204b18:	7c02                	ld	s8,32(sp)
    kfree(proc);
ffffffffc0204b1a:	8522                	mv	a0,s0
ffffffffc0204b1c:	93efd0ef          	jal	ffffffffc0201c5a <kfree>
ffffffffc0204b20:	7ae2                	ld	s5,56(sp)
    ret = -E_NO_MEM;
ffffffffc0204b22:	5571                	li	a0,-4
    return ret;
ffffffffc0204b24:	b5e1                	j	ffffffffc02049ec <do_fork+0x232>
                    if (last_pid >= MAX_PID)
ffffffffc0204b26:	6789                	lui	a5,0x2
ffffffffc0204b28:	00f6c363          	blt	a3,a5,ffffffffc0204b2e <do_fork+0x374>
                        last_pid = 1;
ffffffffc0204b2c:	4685                	li	a3,1
                    goto repeat;
ffffffffc0204b2e:	4585                	li	a1,1
ffffffffc0204b30:	bbf5                	j	ffffffffc020492c <do_fork+0x172>
    int ret = -E_NO_FREE_PROC;
ffffffffc0204b32:	556d                	li	a0,-5
}
ffffffffc0204b34:	8082                	ret
    assert(current->wait_state == 0);
ffffffffc0204b36:	00003697          	auipc	a3,0x3
ffffffffc0204b3a:	56a68693          	addi	a3,a3,1386 # ffffffffc02080a0 <etext+0x1bfe>
ffffffffc0204b3e:	00002617          	auipc	a2,0x2
ffffffffc0204b42:	33a60613          	addi	a2,a2,826 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0204b46:	1e600593          	li	a1,486
ffffffffc0204b4a:	00003517          	auipc	a0,0x3
ffffffffc0204b4e:	57650513          	addi	a0,a0,1398 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc0204b52:	e4ce                	sd	s3,72(sp)
ffffffffc0204b54:	e0d2                	sd	s4,64(sp)
ffffffffc0204b56:	f85a                	sd	s6,48(sp)
ffffffffc0204b58:	f45e                	sd	s7,40(sp)
ffffffffc0204b5a:	f062                	sd	s8,32(sp)
ffffffffc0204b5c:	e86a                	sd	s10,16(sp)
ffffffffc0204b5e:	8edfb0ef          	jal	ffffffffc020044a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204b62:	00002617          	auipc	a2,0x2
ffffffffc0204b66:	79660613          	addi	a2,a2,1942 # ffffffffc02072f8 <etext+0xe56>
ffffffffc0204b6a:	06900593          	li	a1,105
ffffffffc0204b6e:	00002517          	auipc	a0,0x2
ffffffffc0204b72:	6e250513          	addi	a0,a0,1762 # ffffffffc0207250 <etext+0xdae>
ffffffffc0204b76:	e86a                	sd	s10,16(sp)
ffffffffc0204b78:	8d3fb0ef          	jal	ffffffffc020044a <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204b7c:	86be                	mv	a3,a5
ffffffffc0204b7e:	00002617          	auipc	a2,0x2
ffffffffc0204b82:	75260613          	addi	a2,a2,1874 # ffffffffc02072d0 <etext+0xe2e>
ffffffffc0204b86:	19f00593          	li	a1,415
ffffffffc0204b8a:	00003517          	auipc	a0,0x3
ffffffffc0204b8e:	53650513          	addi	a0,a0,1334 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc0204b92:	e86a                	sd	s10,16(sp)
ffffffffc0204b94:	8b7fb0ef          	jal	ffffffffc020044a <__panic>
    return KADDR(page2pa(page));
ffffffffc0204b98:	00002617          	auipc	a2,0x2
ffffffffc0204b9c:	69060613          	addi	a2,a2,1680 # ffffffffc0207228 <etext+0xd86>
ffffffffc0204ba0:	07100593          	li	a1,113
ffffffffc0204ba4:	00002517          	auipc	a0,0x2
ffffffffc0204ba8:	6ac50513          	addi	a0,a0,1708 # ffffffffc0207250 <etext+0xdae>
ffffffffc0204bac:	e86a                	sd	s10,16(sp)
ffffffffc0204bae:	89dfb0ef          	jal	ffffffffc020044a <__panic>
    return pa2page(PADDR(kva));
ffffffffc0204bb2:	00002617          	auipc	a2,0x2
ffffffffc0204bb6:	71e60613          	addi	a2,a2,1822 # ffffffffc02072d0 <etext+0xe2e>
ffffffffc0204bba:	07700593          	li	a1,119
ffffffffc0204bbe:	00002517          	auipc	a0,0x2
ffffffffc0204bc2:	69250513          	addi	a0,a0,1682 # ffffffffc0207250 <etext+0xdae>
ffffffffc0204bc6:	e86a                	sd	s10,16(sp)
ffffffffc0204bc8:	883fb0ef          	jal	ffffffffc020044a <__panic>
    return KADDR(page2pa(page));
ffffffffc0204bcc:	00002617          	auipc	a2,0x2
ffffffffc0204bd0:	65c60613          	addi	a2,a2,1628 # ffffffffc0207228 <etext+0xd86>
ffffffffc0204bd4:	07100593          	li	a1,113
ffffffffc0204bd8:	00002517          	auipc	a0,0x2
ffffffffc0204bdc:	67850513          	addi	a0,a0,1656 # ffffffffc0207250 <etext+0xdae>
ffffffffc0204be0:	86bfb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0204be4 <kernel_thread>:
{
ffffffffc0204be4:	7129                	addi	sp,sp,-320
ffffffffc0204be6:	fa22                	sd	s0,304(sp)
ffffffffc0204be8:	f626                	sd	s1,296(sp)
ffffffffc0204bea:	f24a                	sd	s2,288(sp)
ffffffffc0204bec:	842a                	mv	s0,a0
ffffffffc0204bee:	84ae                	mv	s1,a1
ffffffffc0204bf0:	8932                	mv	s2,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204bf2:	850a                	mv	a0,sp
ffffffffc0204bf4:	12000613          	li	a2,288
ffffffffc0204bf8:	4581                	li	a1,0
{
ffffffffc0204bfa:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204bfc:	07d010ef          	jal	ffffffffc0206478 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0204c00:	e0a2                	sd	s0,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0204c02:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204c04:	100027f3          	csrr	a5,sstatus
ffffffffc0204c08:	edd7f793          	andi	a5,a5,-291
ffffffffc0204c0c:	1207e793          	ori	a5,a5,288
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204c10:	860a                	mv	a2,sp
ffffffffc0204c12:	10096513          	ori	a0,s2,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204c16:	00000717          	auipc	a4,0x0
ffffffffc0204c1a:	9a070713          	addi	a4,a4,-1632 # ffffffffc02045b6 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204c1e:	4581                	li	a1,0
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204c20:	e23e                	sd	a5,256(sp)
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204c22:	e63a                	sd	a4,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204c24:	b97ff0ef          	jal	ffffffffc02047ba <do_fork>
}
ffffffffc0204c28:	70f2                	ld	ra,312(sp)
ffffffffc0204c2a:	7452                	ld	s0,304(sp)
ffffffffc0204c2c:	74b2                	ld	s1,296(sp)
ffffffffc0204c2e:	7912                	ld	s2,288(sp)
ffffffffc0204c30:	6131                	addi	sp,sp,320
ffffffffc0204c32:	8082                	ret

ffffffffc0204c34 <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int do_exit(int error_code)
{
ffffffffc0204c34:	7179                	addi	sp,sp,-48
ffffffffc0204c36:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc0204c38:	000c7417          	auipc	s0,0xc7
ffffffffc0204c3c:	71840413          	addi	s0,s0,1816 # ffffffffc02cc350 <current>
ffffffffc0204c40:	601c                	ld	a5,0(s0)
ffffffffc0204c42:	000c7717          	auipc	a4,0xc7
ffffffffc0204c46:	71e73703          	ld	a4,1822(a4) # ffffffffc02cc360 <idleproc>
{
ffffffffc0204c4a:	f406                	sd	ra,40(sp)
ffffffffc0204c4c:	ec26                	sd	s1,24(sp)
    if (current == idleproc)
ffffffffc0204c4e:	0ce78b63          	beq	a5,a4,ffffffffc0204d24 <do_exit+0xf0>
    {
        panic("idleproc exit.\n");
    }
    if (current == initproc)
ffffffffc0204c52:	000c7497          	auipc	s1,0xc7
ffffffffc0204c56:	70648493          	addi	s1,s1,1798 # ffffffffc02cc358 <initproc>
ffffffffc0204c5a:	6098                	ld	a4,0(s1)
ffffffffc0204c5c:	e84a                	sd	s2,16(sp)
ffffffffc0204c5e:	0ee78c63          	beq	a5,a4,ffffffffc0204d56 <do_exit+0x122>
    {
        panic("initproc exit.\n");
    }
    struct mm_struct *mm = current->mm;
ffffffffc0204c62:	7798                	ld	a4,40(a5)
ffffffffc0204c64:	892a                	mv	s2,a0
    if (mm != NULL)
ffffffffc0204c66:	c315                	beqz	a4,ffffffffc0204c8a <do_exit+0x56>
ffffffffc0204c68:	000c7797          	auipc	a5,0xc7
ffffffffc0204c6c:	6b87b783          	ld	a5,1720(a5) # ffffffffc02cc320 <boot_pgdir_pa>
ffffffffc0204c70:	56fd                	li	a3,-1
ffffffffc0204c72:	16fe                	slli	a3,a3,0x3f
ffffffffc0204c74:	83b1                	srli	a5,a5,0xc
ffffffffc0204c76:	8fd5                	or	a5,a5,a3
ffffffffc0204c78:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0204c7c:	5b1c                	lw	a5,48(a4)
ffffffffc0204c7e:	37fd                	addiw	a5,a5,-1
ffffffffc0204c80:	db1c                	sw	a5,48(a4)
    {
        lsatp(boot_pgdir_pa);
        if (mm_count_dec(mm) == 0)
ffffffffc0204c82:	cfd5                	beqz	a5,ffffffffc0204d3e <do_exit+0x10a>
        {
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
        }
        current->mm = NULL;
ffffffffc0204c84:	601c                	ld	a5,0(s0)
ffffffffc0204c86:	0207b423          	sd	zero,40(a5)
    }
    current->state = PROC_ZOMBIE;
ffffffffc0204c8a:	470d                	li	a4,3
    current->exit_code = error_code;
ffffffffc0204c8c:	0f27a423          	sw	s2,232(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0204c90:	c398                	sw	a4,0(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204c92:	100027f3          	csrr	a5,sstatus
ffffffffc0204c96:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204c98:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204c9a:	ebf1                	bnez	a5,ffffffffc0204d6e <do_exit+0x13a>
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
    {
        proc = current->parent;
ffffffffc0204c9c:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204c9e:	800007b7          	lui	a5,0x80000
ffffffffc0204ca2:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_obj___user_matrix_out_size+0xffffffff7fff4919>
        proc = current->parent;
ffffffffc0204ca4:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204ca6:	0ec52703          	lw	a4,236(a0)
ffffffffc0204caa:	0cf70663          	beq	a4,a5,ffffffffc0204d76 <do_exit+0x142>
        {
            wakeup_proc(proc);
        }
        while (current->cptr != NULL)
ffffffffc0204cae:	6018                	ld	a4,0(s0)
            }
            proc->parent = initproc;
            initproc->cptr = proc;
            if (proc->state == PROC_ZOMBIE)
            {
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204cb0:	800005b7          	lui	a1,0x80000
ffffffffc0204cb4:	0585                	addi	a1,a1,1 # ffffffff80000001 <_binary_obj___user_matrix_out_size+0xffffffff7fff4919>
        while (current->cptr != NULL)
ffffffffc0204cb6:	7b7c                	ld	a5,240(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204cb8:	460d                	li	a2,3
        while (current->cptr != NULL)
ffffffffc0204cba:	e789                	bnez	a5,ffffffffc0204cc4 <do_exit+0x90>
ffffffffc0204cbc:	a83d                	j	ffffffffc0204cfa <do_exit+0xc6>
ffffffffc0204cbe:	6018                	ld	a4,0(s0)
ffffffffc0204cc0:	7b7c                	ld	a5,240(a4)
ffffffffc0204cc2:	cf85                	beqz	a5,ffffffffc0204cfa <do_exit+0xc6>
            current->cptr = proc->optr;
ffffffffc0204cc4:	1007b683          	ld	a3,256(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204cc8:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc0204cca:	fb74                	sd	a3,240(a4)
            proc->yptr = NULL;
ffffffffc0204ccc:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204cd0:	7978                	ld	a4,240(a0)
ffffffffc0204cd2:	10e7b023          	sd	a4,256(a5)
ffffffffc0204cd6:	c311                	beqz	a4,ffffffffc0204cda <do_exit+0xa6>
                initproc->cptr->yptr = proc;
ffffffffc0204cd8:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204cda:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0204cdc:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0204cde:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204ce0:	fcc71fe3          	bne	a4,a2,ffffffffc0204cbe <do_exit+0x8a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204ce4:	0ec52783          	lw	a5,236(a0)
ffffffffc0204ce8:	fcb79be3          	bne	a5,a1,ffffffffc0204cbe <do_exit+0x8a>
                {
                    wakeup_proc(initproc);
ffffffffc0204cec:	5c5000ef          	jal	ffffffffc0205ab0 <wakeup_proc>
ffffffffc0204cf0:	800005b7          	lui	a1,0x80000
ffffffffc0204cf4:	0585                	addi	a1,a1,1 # ffffffff80000001 <_binary_obj___user_matrix_out_size+0xffffffff7fff4919>
ffffffffc0204cf6:	460d                	li	a2,3
ffffffffc0204cf8:	b7d9                	j	ffffffffc0204cbe <do_exit+0x8a>
    if (flag) {
ffffffffc0204cfa:	02091263          	bnez	s2,ffffffffc0204d1e <do_exit+0xea>
                }
            }
        }
    }
    local_intr_restore(intr_flag);
    schedule();
ffffffffc0204cfe:	6ab000ef          	jal	ffffffffc0205ba8 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0204d02:	601c                	ld	a5,0(s0)
ffffffffc0204d04:	00003617          	auipc	a2,0x3
ffffffffc0204d08:	3f460613          	addi	a2,a2,1012 # ffffffffc02080f8 <etext+0x1c56>
ffffffffc0204d0c:	24d00593          	li	a1,589
ffffffffc0204d10:	43d4                	lw	a3,4(a5)
ffffffffc0204d12:	00003517          	auipc	a0,0x3
ffffffffc0204d16:	3ae50513          	addi	a0,a0,942 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc0204d1a:	f30fb0ef          	jal	ffffffffc020044a <__panic>
        intr_enable();
ffffffffc0204d1e:	bdbfb0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0204d22:	bff1                	j	ffffffffc0204cfe <do_exit+0xca>
        panic("idleproc exit.\n");
ffffffffc0204d24:	00003617          	auipc	a2,0x3
ffffffffc0204d28:	3b460613          	addi	a2,a2,948 # ffffffffc02080d8 <etext+0x1c36>
ffffffffc0204d2c:	21900593          	li	a1,537
ffffffffc0204d30:	00003517          	auipc	a0,0x3
ffffffffc0204d34:	39050513          	addi	a0,a0,912 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc0204d38:	e84a                	sd	s2,16(sp)
ffffffffc0204d3a:	f10fb0ef          	jal	ffffffffc020044a <__panic>
            exit_mmap(mm);
ffffffffc0204d3e:	853a                	mv	a0,a4
ffffffffc0204d40:	e43a                	sd	a4,8(sp)
ffffffffc0204d42:	afdfe0ef          	jal	ffffffffc020383e <exit_mmap>
            put_pgdir(mm);
ffffffffc0204d46:	6722                	ld	a4,8(sp)
ffffffffc0204d48:	6f08                	ld	a0,24(a4)
ffffffffc0204d4a:	919ff0ef          	jal	ffffffffc0204662 <put_pgdir.isra.0>
            mm_destroy(mm);
ffffffffc0204d4e:	6522                	ld	a0,8(sp)
ffffffffc0204d50:	939fe0ef          	jal	ffffffffc0203688 <mm_destroy>
ffffffffc0204d54:	bf05                	j	ffffffffc0204c84 <do_exit+0x50>
        panic("initproc exit.\n");
ffffffffc0204d56:	00003617          	auipc	a2,0x3
ffffffffc0204d5a:	39260613          	addi	a2,a2,914 # ffffffffc02080e8 <etext+0x1c46>
ffffffffc0204d5e:	21d00593          	li	a1,541
ffffffffc0204d62:	00003517          	auipc	a0,0x3
ffffffffc0204d66:	35e50513          	addi	a0,a0,862 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc0204d6a:	ee0fb0ef          	jal	ffffffffc020044a <__panic>
        intr_disable();
ffffffffc0204d6e:	b91fb0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc0204d72:	4905                	li	s2,1
ffffffffc0204d74:	b725                	j	ffffffffc0204c9c <do_exit+0x68>
            wakeup_proc(proc);
ffffffffc0204d76:	53b000ef          	jal	ffffffffc0205ab0 <wakeup_proc>
ffffffffc0204d7a:	bf15                	j	ffffffffc0204cae <do_exit+0x7a>

ffffffffc0204d7c <do_wait.part.0>:
}

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int do_wait(int pid, int *code_store)
ffffffffc0204d7c:	7179                	addi	sp,sp,-48
ffffffffc0204d7e:	ec26                	sd	s1,24(sp)
ffffffffc0204d80:	e84a                	sd	s2,16(sp)
ffffffffc0204d82:	e44e                	sd	s3,8(sp)
ffffffffc0204d84:	f406                	sd	ra,40(sp)
ffffffffc0204d86:	f022                	sd	s0,32(sp)
ffffffffc0204d88:	84aa                	mv	s1,a0
ffffffffc0204d8a:	892e                	mv	s2,a1
ffffffffc0204d8c:	000c7997          	auipc	s3,0xc7
ffffffffc0204d90:	5c498993          	addi	s3,s3,1476 # ffffffffc02cc350 <current>

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
    if (pid != 0)
ffffffffc0204d94:	cd19                	beqz	a0,ffffffffc0204db2 <do_wait.part.0+0x36>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204d96:	6789                	lui	a5,0x2
ffffffffc0204d98:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x70ea>
ffffffffc0204d9a:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204d9e:	12e7f563          	bgeu	a5,a4,ffffffffc0204ec8 <do_wait.part.0+0x14c>
    }
    local_intr_restore(intr_flag);
    put_kstack(proc);
    kfree(proc);
    return 0;
}
ffffffffc0204da2:	70a2                	ld	ra,40(sp)
ffffffffc0204da4:	7402                	ld	s0,32(sp)
ffffffffc0204da6:	64e2                	ld	s1,24(sp)
ffffffffc0204da8:	6942                	ld	s2,16(sp)
ffffffffc0204daa:	69a2                	ld	s3,8(sp)
    return -E_BAD_PROC;
ffffffffc0204dac:	5579                	li	a0,-2
}
ffffffffc0204dae:	6145                	addi	sp,sp,48
ffffffffc0204db0:	8082                	ret
        proc = current->cptr;
ffffffffc0204db2:	0009b703          	ld	a4,0(s3)
ffffffffc0204db6:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr)
ffffffffc0204db8:	d46d                	beqz	s0,ffffffffc0204da2 <do_wait.part.0+0x26>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204dba:	468d                	li	a3,3
ffffffffc0204dbc:	a021                	j	ffffffffc0204dc4 <do_wait.part.0+0x48>
        for (; proc != NULL; proc = proc->optr)
ffffffffc0204dbe:	10043403          	ld	s0,256(s0)
ffffffffc0204dc2:	c075                	beqz	s0,ffffffffc0204ea6 <do_wait.part.0+0x12a>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204dc4:	401c                	lw	a5,0(s0)
ffffffffc0204dc6:	fed79ce3          	bne	a5,a3,ffffffffc0204dbe <do_wait.part.0+0x42>
    if (proc == idleproc || proc == initproc)
ffffffffc0204dca:	000c7797          	auipc	a5,0xc7
ffffffffc0204dce:	5967b783          	ld	a5,1430(a5) # ffffffffc02cc360 <idleproc>
ffffffffc0204dd2:	14878263          	beq	a5,s0,ffffffffc0204f16 <do_wait.part.0+0x19a>
ffffffffc0204dd6:	000c7797          	auipc	a5,0xc7
ffffffffc0204dda:	5827b783          	ld	a5,1410(a5) # ffffffffc02cc358 <initproc>
ffffffffc0204dde:	12f40c63          	beq	s0,a5,ffffffffc0204f16 <do_wait.part.0+0x19a>
    if (code_store != NULL)
ffffffffc0204de2:	00090663          	beqz	s2,ffffffffc0204dee <do_wait.part.0+0x72>
        *code_store = proc->exit_code;
ffffffffc0204de6:	0e842783          	lw	a5,232(s0)
ffffffffc0204dea:	00f92023          	sw	a5,0(s2)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204dee:	100027f3          	csrr	a5,sstatus
ffffffffc0204df2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204df4:	4601                	li	a2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204df6:	10079963          	bnez	a5,ffffffffc0204f08 <do_wait.part.0+0x18c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0204dfa:	6c74                	ld	a3,216(s0)
ffffffffc0204dfc:	7078                	ld	a4,224(s0)
    if (proc->optr != NULL)
ffffffffc0204dfe:	10043783          	ld	a5,256(s0)
    prev->next = next;
ffffffffc0204e02:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0204e04:	e314                	sd	a3,0(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0204e06:	6474                	ld	a3,200(s0)
ffffffffc0204e08:	6878                	ld	a4,208(s0)
    prev->next = next;
ffffffffc0204e0a:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc0204e0c:	e314                	sd	a3,0(a4)
ffffffffc0204e0e:	c789                	beqz	a5,ffffffffc0204e18 <do_wait.part.0+0x9c>
        proc->optr->yptr = proc->yptr;
ffffffffc0204e10:	7c78                	ld	a4,248(s0)
ffffffffc0204e12:	fff8                	sd	a4,248(a5)
        proc->yptr->optr = proc->optr;
ffffffffc0204e14:	10043783          	ld	a5,256(s0)
    if (proc->yptr != NULL)
ffffffffc0204e18:	7c78                	ld	a4,248(s0)
ffffffffc0204e1a:	c36d                	beqz	a4,ffffffffc0204efc <do_wait.part.0+0x180>
        proc->yptr->optr = proc->optr;
ffffffffc0204e1c:	10f73023          	sd	a5,256(a4)
    nr_process--;
ffffffffc0204e20:	000c7797          	auipc	a5,0xc7
ffffffffc0204e24:	5287a783          	lw	a5,1320(a5) # ffffffffc02cc348 <nr_process>
ffffffffc0204e28:	37fd                	addiw	a5,a5,-1
ffffffffc0204e2a:	000c7717          	auipc	a4,0xc7
ffffffffc0204e2e:	50f72f23          	sw	a5,1310(a4) # ffffffffc02cc348 <nr_process>
    if (flag) {
ffffffffc0204e32:	e271                	bnez	a2,ffffffffc0204ef6 <do_wait.part.0+0x17a>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204e34:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0204e36:	c02007b7          	lui	a5,0xc0200
ffffffffc0204e3a:	10f6e663          	bltu	a3,a5,ffffffffc0204f46 <do_wait.part.0+0x1ca>
ffffffffc0204e3e:	000c7717          	auipc	a4,0xc7
ffffffffc0204e42:	4f273703          	ld	a4,1266(a4) # ffffffffc02cc330 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc0204e46:	000c7797          	auipc	a5,0xc7
ffffffffc0204e4a:	4f27b783          	ld	a5,1266(a5) # ffffffffc02cc338 <npage>
    return pa2page(PADDR(kva));
ffffffffc0204e4e:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc0204e50:	82b1                	srli	a3,a3,0xc
ffffffffc0204e52:	0cf6fe63          	bgeu	a3,a5,ffffffffc0204f2e <do_wait.part.0+0x1b2>
    return &pages[PPN(pa) - nbase];
ffffffffc0204e56:	00004797          	auipc	a5,0x4
ffffffffc0204e5a:	4127b783          	ld	a5,1042(a5) # ffffffffc0209268 <nbase>
ffffffffc0204e5e:	000c7517          	auipc	a0,0xc7
ffffffffc0204e62:	4e253503          	ld	a0,1250(a0) # ffffffffc02cc340 <pages>
ffffffffc0204e66:	4589                	li	a1,2
ffffffffc0204e68:	8e9d                	sub	a3,a3,a5
ffffffffc0204e6a:	069a                	slli	a3,a3,0x6
ffffffffc0204e6c:	9536                	add	a0,a0,a3
ffffffffc0204e6e:	f43fc0ef          	jal	ffffffffc0201db0 <free_pages>
    kfree(proc);
ffffffffc0204e72:	8522                	mv	a0,s0
ffffffffc0204e74:	de7fc0ef          	jal	ffffffffc0201c5a <kfree>
}
ffffffffc0204e78:	70a2                	ld	ra,40(sp)
ffffffffc0204e7a:	7402                	ld	s0,32(sp)
ffffffffc0204e7c:	64e2                	ld	s1,24(sp)
ffffffffc0204e7e:	6942                	ld	s2,16(sp)
ffffffffc0204e80:	69a2                	ld	s3,8(sp)
    return 0;
ffffffffc0204e82:	4501                	li	a0,0
}
ffffffffc0204e84:	6145                	addi	sp,sp,48
ffffffffc0204e86:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc0204e88:	000c7997          	auipc	s3,0xc7
ffffffffc0204e8c:	4c898993          	addi	s3,s3,1224 # ffffffffc02cc350 <current>
ffffffffc0204e90:	0009b703          	ld	a4,0(s3)
ffffffffc0204e94:	f487b683          	ld	a3,-184(a5)
ffffffffc0204e98:	f0e695e3          	bne	a3,a4,ffffffffc0204da2 <do_wait.part.0+0x26>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204e9c:	f287a603          	lw	a2,-216(a5)
ffffffffc0204ea0:	468d                	li	a3,3
ffffffffc0204ea2:	06d60063          	beq	a2,a3,ffffffffc0204f02 <do_wait.part.0+0x186>
        current->wait_state = WT_CHILD;
ffffffffc0204ea6:	800007b7          	lui	a5,0x80000
ffffffffc0204eaa:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_obj___user_matrix_out_size+0xffffffff7fff4919>
        current->state = PROC_SLEEPING;
ffffffffc0204eac:	4685                	li	a3,1
        current->wait_state = WT_CHILD;
ffffffffc0204eae:	0ef72623          	sw	a5,236(a4)
        current->state = PROC_SLEEPING;
ffffffffc0204eb2:	c314                	sw	a3,0(a4)
        schedule();
ffffffffc0204eb4:	4f5000ef          	jal	ffffffffc0205ba8 <schedule>
        if (current->flags & PF_EXITING)
ffffffffc0204eb8:	0009b783          	ld	a5,0(s3)
ffffffffc0204ebc:	0b07a783          	lw	a5,176(a5)
ffffffffc0204ec0:	8b85                	andi	a5,a5,1
ffffffffc0204ec2:	e7b9                	bnez	a5,ffffffffc0204f10 <do_wait.part.0+0x194>
    if (pid != 0)
ffffffffc0204ec4:	ee0487e3          	beqz	s1,ffffffffc0204db2 <do_wait.part.0+0x36>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204ec8:	45a9                	li	a1,10
ffffffffc0204eca:	8526                	mv	a0,s1
ffffffffc0204ecc:	116010ef          	jal	ffffffffc0205fe2 <hash32>
ffffffffc0204ed0:	02051793          	slli	a5,a0,0x20
ffffffffc0204ed4:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204ed8:	000c3797          	auipc	a5,0xc3
ffffffffc0204edc:	3d878793          	addi	a5,a5,984 # ffffffffc02c82b0 <hash_list>
ffffffffc0204ee0:	953e                	add	a0,a0,a5
ffffffffc0204ee2:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc0204ee4:	a029                	j	ffffffffc0204eee <do_wait.part.0+0x172>
            if (proc->pid == pid)
ffffffffc0204ee6:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0204eea:	f8970fe3          	beq	a4,s1,ffffffffc0204e88 <do_wait.part.0+0x10c>
    return listelm->next;
ffffffffc0204eee:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204ef0:	fef51be3          	bne	a0,a5,ffffffffc0204ee6 <do_wait.part.0+0x16a>
ffffffffc0204ef4:	b57d                	j	ffffffffc0204da2 <do_wait.part.0+0x26>
        intr_enable();
ffffffffc0204ef6:	a03fb0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0204efa:	bf2d                	j	ffffffffc0204e34 <do_wait.part.0+0xb8>
        proc->parent->cptr = proc->optr;
ffffffffc0204efc:	7018                	ld	a4,32(s0)
ffffffffc0204efe:	fb7c                	sd	a5,240(a4)
ffffffffc0204f00:	b705                	j	ffffffffc0204e20 <do_wait.part.0+0xa4>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204f02:	f2878413          	addi	s0,a5,-216
ffffffffc0204f06:	b5d1                	j	ffffffffc0204dca <do_wait.part.0+0x4e>
        intr_disable();
ffffffffc0204f08:	9f7fb0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc0204f0c:	4605                	li	a2,1
ffffffffc0204f0e:	b5f5                	j	ffffffffc0204dfa <do_wait.part.0+0x7e>
            do_exit(-E_KILLED);
ffffffffc0204f10:	555d                	li	a0,-9
ffffffffc0204f12:	d23ff0ef          	jal	ffffffffc0204c34 <do_exit>
        panic("wait idleproc or initproc.\n");
ffffffffc0204f16:	00003617          	auipc	a2,0x3
ffffffffc0204f1a:	20260613          	addi	a2,a2,514 # ffffffffc0208118 <etext+0x1c76>
ffffffffc0204f1e:	36f00593          	li	a1,879
ffffffffc0204f22:	00003517          	auipc	a0,0x3
ffffffffc0204f26:	19e50513          	addi	a0,a0,414 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc0204f2a:	d20fb0ef          	jal	ffffffffc020044a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204f2e:	00002617          	auipc	a2,0x2
ffffffffc0204f32:	3ca60613          	addi	a2,a2,970 # ffffffffc02072f8 <etext+0xe56>
ffffffffc0204f36:	06900593          	li	a1,105
ffffffffc0204f3a:	00002517          	auipc	a0,0x2
ffffffffc0204f3e:	31650513          	addi	a0,a0,790 # ffffffffc0207250 <etext+0xdae>
ffffffffc0204f42:	d08fb0ef          	jal	ffffffffc020044a <__panic>
    return pa2page(PADDR(kva));
ffffffffc0204f46:	00002617          	auipc	a2,0x2
ffffffffc0204f4a:	38a60613          	addi	a2,a2,906 # ffffffffc02072d0 <etext+0xe2e>
ffffffffc0204f4e:	07700593          	li	a1,119
ffffffffc0204f52:	00002517          	auipc	a0,0x2
ffffffffc0204f56:	2fe50513          	addi	a0,a0,766 # ffffffffc0207250 <etext+0xdae>
ffffffffc0204f5a:	cf0fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0204f5e <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc0204f5e:	1141                	addi	sp,sp,-16
ffffffffc0204f60:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0204f62:	e87fc0ef          	jal	ffffffffc0201de8 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0204f66:	c4bfc0ef          	jal	ffffffffc0201bb0 <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0204f6a:	4601                	li	a2,0
ffffffffc0204f6c:	4581                	li	a1,0
ffffffffc0204f6e:	00000517          	auipc	a0,0x0
ffffffffc0204f72:	6ba50513          	addi	a0,a0,1722 # ffffffffc0205628 <user_main>
ffffffffc0204f76:	c6fff0ef          	jal	ffffffffc0204be4 <kernel_thread>
    if (pid <= 0)
ffffffffc0204f7a:	08a05a63          	blez	a0,ffffffffc020500e <init_main+0xb0>
    {
        panic("create user_main failed.\n");
    }
    extern void check_sync(void);
    check_sync(); // check philosopher sync problem
ffffffffc0204f7e:	8d4ff0ef          	jal	ffffffffc0204052 <check_sync>
init_main(void *arg)
ffffffffc0204f82:	a019                	j	ffffffffc0204f88 <init_main+0x2a>

    while (do_wait(0, NULL) == 0)
    {
        schedule();
ffffffffc0204f84:	425000ef          	jal	ffffffffc0205ba8 <schedule>
    if (code_store != NULL)
ffffffffc0204f88:	4581                	li	a1,0
ffffffffc0204f8a:	4501                	li	a0,0
ffffffffc0204f8c:	df1ff0ef          	jal	ffffffffc0204d7c <do_wait.part.0>
    while (do_wait(0, NULL) == 0)
ffffffffc0204f90:	d975                	beqz	a0,ffffffffc0204f84 <init_main+0x26>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0204f92:	00003517          	auipc	a0,0x3
ffffffffc0204f96:	1c650513          	addi	a0,a0,454 # ffffffffc0208158 <etext+0x1cb6>
ffffffffc0204f9a:	9fefb0ef          	jal	ffffffffc0200198 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204f9e:	000c7797          	auipc	a5,0xc7
ffffffffc0204fa2:	3ba7b783          	ld	a5,954(a5) # ffffffffc02cc358 <initproc>
ffffffffc0204fa6:	7bf8                	ld	a4,240(a5)
ffffffffc0204fa8:	e339                	bnez	a4,ffffffffc0204fee <init_main+0x90>
ffffffffc0204faa:	7ff8                	ld	a4,248(a5)
ffffffffc0204fac:	e329                	bnez	a4,ffffffffc0204fee <init_main+0x90>
ffffffffc0204fae:	1007b703          	ld	a4,256(a5)
ffffffffc0204fb2:	ef15                	bnez	a4,ffffffffc0204fee <init_main+0x90>
    assert(nr_process == 2);
ffffffffc0204fb4:	000c7697          	auipc	a3,0xc7
ffffffffc0204fb8:	3946a683          	lw	a3,916(a3) # ffffffffc02cc348 <nr_process>
ffffffffc0204fbc:	4709                	li	a4,2
ffffffffc0204fbe:	0ae69463          	bne	a3,a4,ffffffffc0205066 <init_main+0x108>
ffffffffc0204fc2:	000c7697          	auipc	a3,0xc7
ffffffffc0204fc6:	2ee68693          	addi	a3,a3,750 # ffffffffc02cc2b0 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204fca:	6698                	ld	a4,8(a3)
ffffffffc0204fcc:	0c878793          	addi	a5,a5,200
ffffffffc0204fd0:	06f71b63          	bne	a4,a5,ffffffffc0205046 <init_main+0xe8>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0204fd4:	629c                	ld	a5,0(a3)
ffffffffc0204fd6:	04f71863          	bne	a4,a5,ffffffffc0205026 <init_main+0xc8>

    cprintf("init check memory pass.\n");
ffffffffc0204fda:	00003517          	auipc	a0,0x3
ffffffffc0204fde:	26650513          	addi	a0,a0,614 # ffffffffc0208240 <etext+0x1d9e>
ffffffffc0204fe2:	9b6fb0ef          	jal	ffffffffc0200198 <cprintf>
    return 0;
}
ffffffffc0204fe6:	60a2                	ld	ra,8(sp)
ffffffffc0204fe8:	4501                	li	a0,0
ffffffffc0204fea:	0141                	addi	sp,sp,16
ffffffffc0204fec:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204fee:	00003697          	auipc	a3,0x3
ffffffffc0204ff2:	19268693          	addi	a3,a3,402 # ffffffffc0208180 <etext+0x1cde>
ffffffffc0204ff6:	00002617          	auipc	a2,0x2
ffffffffc0204ffa:	e8260613          	addi	a2,a2,-382 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0204ffe:	3de00593          	li	a1,990
ffffffffc0205002:	00003517          	auipc	a0,0x3
ffffffffc0205006:	0be50513          	addi	a0,a0,190 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc020500a:	c40fb0ef          	jal	ffffffffc020044a <__panic>
        panic("create user_main failed.\n");
ffffffffc020500e:	00003617          	auipc	a2,0x3
ffffffffc0205012:	12a60613          	addi	a2,a2,298 # ffffffffc0208138 <etext+0x1c96>
ffffffffc0205016:	3d300593          	li	a1,979
ffffffffc020501a:	00003517          	auipc	a0,0x3
ffffffffc020501e:	0a650513          	addi	a0,a0,166 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc0205022:	c28fb0ef          	jal	ffffffffc020044a <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205026:	00003697          	auipc	a3,0x3
ffffffffc020502a:	1ea68693          	addi	a3,a3,490 # ffffffffc0208210 <etext+0x1d6e>
ffffffffc020502e:	00002617          	auipc	a2,0x2
ffffffffc0205032:	e4a60613          	addi	a2,a2,-438 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0205036:	3e100593          	li	a1,993
ffffffffc020503a:	00003517          	auipc	a0,0x3
ffffffffc020503e:	08650513          	addi	a0,a0,134 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc0205042:	c08fb0ef          	jal	ffffffffc020044a <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205046:	00003697          	auipc	a3,0x3
ffffffffc020504a:	19a68693          	addi	a3,a3,410 # ffffffffc02081e0 <etext+0x1d3e>
ffffffffc020504e:	00002617          	auipc	a2,0x2
ffffffffc0205052:	e2a60613          	addi	a2,a2,-470 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0205056:	3e000593          	li	a1,992
ffffffffc020505a:	00003517          	auipc	a0,0x3
ffffffffc020505e:	06650513          	addi	a0,a0,102 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc0205062:	be8fb0ef          	jal	ffffffffc020044a <__panic>
    assert(nr_process == 2);
ffffffffc0205066:	00003697          	auipc	a3,0x3
ffffffffc020506a:	16a68693          	addi	a3,a3,362 # ffffffffc02081d0 <etext+0x1d2e>
ffffffffc020506e:	00002617          	auipc	a2,0x2
ffffffffc0205072:	e0a60613          	addi	a2,a2,-502 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0205076:	3df00593          	li	a1,991
ffffffffc020507a:	00003517          	auipc	a0,0x3
ffffffffc020507e:	04650513          	addi	a0,a0,70 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc0205082:	bc8fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0205086 <do_execve>:
{
ffffffffc0205086:	7171                	addi	sp,sp,-176
ffffffffc0205088:	e8ea                	sd	s10,80(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020508a:	000c7d17          	auipc	s10,0xc7
ffffffffc020508e:	2c6d0d13          	addi	s10,s10,710 # ffffffffc02cc350 <current>
ffffffffc0205092:	000d3783          	ld	a5,0(s10)
{
ffffffffc0205096:	e94a                	sd	s2,144(sp)
ffffffffc0205098:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020509a:	0287b903          	ld	s2,40(a5)
{
ffffffffc020509e:	84ae                	mv	s1,a1
ffffffffc02050a0:	e54e                	sd	s3,136(sp)
ffffffffc02050a2:	ec32                	sd	a2,24(sp)
ffffffffc02050a4:	89aa                	mv	s3,a0
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc02050a6:	85aa                	mv	a1,a0
ffffffffc02050a8:	8626                	mv	a2,s1
ffffffffc02050aa:	854a                	mv	a0,s2
ffffffffc02050ac:	4681                	li	a3,0
{
ffffffffc02050ae:	f506                	sd	ra,168(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc02050b0:	b2dfe0ef          	jal	ffffffffc0203bdc <user_mem_check>
ffffffffc02050b4:	48050263          	beqz	a0,ffffffffc0205538 <do_execve+0x4b2>
    memset(local_name, 0, sizeof(local_name));
ffffffffc02050b8:	4641                	li	a2,16
ffffffffc02050ba:	1808                	addi	a0,sp,48
ffffffffc02050bc:	4581                	li	a1,0
ffffffffc02050be:	3ba010ef          	jal	ffffffffc0206478 <memset>
    if (len > PROC_NAME_LEN)
ffffffffc02050c2:	47bd                	li	a5,15
ffffffffc02050c4:	8626                	mv	a2,s1
ffffffffc02050c6:	0e97ef63          	bltu	a5,s1,ffffffffc02051c4 <do_execve+0x13e>
    memcpy(local_name, name, len);
ffffffffc02050ca:	85ce                	mv	a1,s3
ffffffffc02050cc:	1808                	addi	a0,sp,48
ffffffffc02050ce:	3bc010ef          	jal	ffffffffc020648a <memcpy>
    if (mm != NULL)
ffffffffc02050d2:	10090063          	beqz	s2,ffffffffc02051d2 <do_execve+0x14c>
        cputs("mm != NULL");
ffffffffc02050d6:	00003517          	auipc	a0,0x3
ffffffffc02050da:	93a50513          	addi	a0,a0,-1734 # ffffffffc0207a10 <etext+0x156e>
ffffffffc02050de:	8f0fb0ef          	jal	ffffffffc02001ce <cputs>
ffffffffc02050e2:	000c7797          	auipc	a5,0xc7
ffffffffc02050e6:	23e7b783          	ld	a5,574(a5) # ffffffffc02cc320 <boot_pgdir_pa>
ffffffffc02050ea:	577d                	li	a4,-1
ffffffffc02050ec:	177e                	slli	a4,a4,0x3f
ffffffffc02050ee:	83b1                	srli	a5,a5,0xc
ffffffffc02050f0:	8fd9                	or	a5,a5,a4
ffffffffc02050f2:	18079073          	csrw	satp,a5
ffffffffc02050f6:	03092783          	lw	a5,48(s2)
ffffffffc02050fa:	37fd                	addiw	a5,a5,-1
ffffffffc02050fc:	02f92823          	sw	a5,48(s2)
        if (mm_count_dec(mm) == 0)
ffffffffc0205100:	30078763          	beqz	a5,ffffffffc020540e <do_execve+0x388>
        current->mm = NULL;
ffffffffc0205104:	000d3783          	ld	a5,0(s10)
ffffffffc0205108:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc020510c:	c30fe0ef          	jal	ffffffffc020353c <mm_create>
ffffffffc0205110:	89aa                	mv	s3,a0
ffffffffc0205112:	22050063          	beqz	a0,ffffffffc0205332 <do_execve+0x2ac>
    if ((page = alloc_page()) == NULL)
ffffffffc0205116:	4505                	li	a0,1
ffffffffc0205118:	c5ffc0ef          	jal	ffffffffc0201d76 <alloc_pages>
ffffffffc020511c:	42050363          	beqz	a0,ffffffffc0205542 <do_execve+0x4bc>
    return page - pages + nbase;
ffffffffc0205120:	f0e2                	sd	s8,96(sp)
ffffffffc0205122:	000c7c17          	auipc	s8,0xc7
ffffffffc0205126:	21ec0c13          	addi	s8,s8,542 # ffffffffc02cc340 <pages>
ffffffffc020512a:	000c3783          	ld	a5,0(s8)
ffffffffc020512e:	f4de                	sd	s7,104(sp)
ffffffffc0205130:	00004b97          	auipc	s7,0x4
ffffffffc0205134:	138bbb83          	ld	s7,312(s7) # ffffffffc0209268 <nbase>
ffffffffc0205138:	40f506b3          	sub	a3,a0,a5
ffffffffc020513c:	ece6                	sd	s9,88(sp)
    return KADDR(page2pa(page));
ffffffffc020513e:	000c7c97          	auipc	s9,0xc7
ffffffffc0205142:	1fac8c93          	addi	s9,s9,506 # ffffffffc02cc338 <npage>
ffffffffc0205146:	f8da                	sd	s6,112(sp)
    return page - pages + nbase;
ffffffffc0205148:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc020514a:	5b7d                	li	s6,-1
ffffffffc020514c:	000cb783          	ld	a5,0(s9)
    return page - pages + nbase;
ffffffffc0205150:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0205152:	00cb5713          	srli	a4,s6,0xc
ffffffffc0205156:	e83a                	sd	a4,16(sp)
ffffffffc0205158:	fcd6                	sd	s5,120(sp)
ffffffffc020515a:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc020515c:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020515e:	40f77563          	bgeu	a4,a5,ffffffffc0205568 <do_execve+0x4e2>
ffffffffc0205162:	000c7a97          	auipc	s5,0xc7
ffffffffc0205166:	1cea8a93          	addi	s5,s5,462 # ffffffffc02cc330 <va_pa_offset>
ffffffffc020516a:	000ab783          	ld	a5,0(s5)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc020516e:	000c7597          	auipc	a1,0xc7
ffffffffc0205172:	1ba5b583          	ld	a1,442(a1) # ffffffffc02cc328 <boot_pgdir_va>
ffffffffc0205176:	6605                	lui	a2,0x1
ffffffffc0205178:	00f68933          	add	s2,a3,a5
ffffffffc020517c:	854a                	mv	a0,s2
ffffffffc020517e:	30c010ef          	jal	ffffffffc020648a <memcpy>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0205182:	66e2                	ld	a3,24(sp)
ffffffffc0205184:	464c47b7          	lui	a5,0x464c4
ffffffffc0205188:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_matrix_out_size+0x464b8e97>
ffffffffc020518c:	4298                	lw	a4,0(a3)
    mm->pgdir = pgdir;
ffffffffc020518e:	0129bc23          	sd	s2,24(s3)
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0205192:	06f70863          	beq	a4,a5,ffffffffc0205202 <do_execve+0x17c>
        ret = -E_INVAL_ELF;
ffffffffc0205196:	54e1                	li	s1,-8
    put_pgdir(mm);
ffffffffc0205198:	854a                	mv	a0,s2
ffffffffc020519a:	cc8ff0ef          	jal	ffffffffc0204662 <put_pgdir.isra.0>
ffffffffc020519e:	7ae6                	ld	s5,120(sp)
ffffffffc02051a0:	7b46                	ld	s6,112(sp)
ffffffffc02051a2:	7ba6                	ld	s7,104(sp)
ffffffffc02051a4:	7c06                	ld	s8,96(sp)
ffffffffc02051a6:	6ce6                	ld	s9,88(sp)
    mm_destroy(mm);
ffffffffc02051a8:	854e                	mv	a0,s3
ffffffffc02051aa:	cdefe0ef          	jal	ffffffffc0203688 <mm_destroy>
    do_exit(ret);
ffffffffc02051ae:	8526                	mv	a0,s1
ffffffffc02051b0:	f122                	sd	s0,160(sp)
ffffffffc02051b2:	e152                	sd	s4,128(sp)
ffffffffc02051b4:	fcd6                	sd	s5,120(sp)
ffffffffc02051b6:	f8da                	sd	s6,112(sp)
ffffffffc02051b8:	f4de                	sd	s7,104(sp)
ffffffffc02051ba:	f0e2                	sd	s8,96(sp)
ffffffffc02051bc:	ece6                	sd	s9,88(sp)
ffffffffc02051be:	e4ee                	sd	s11,72(sp)
ffffffffc02051c0:	a75ff0ef          	jal	ffffffffc0204c34 <do_exit>
    if (len > PROC_NAME_LEN)
ffffffffc02051c4:	863e                	mv	a2,a5
    memcpy(local_name, name, len);
ffffffffc02051c6:	85ce                	mv	a1,s3
ffffffffc02051c8:	1808                	addi	a0,sp,48
ffffffffc02051ca:	2c0010ef          	jal	ffffffffc020648a <memcpy>
    if (mm != NULL)
ffffffffc02051ce:	f00914e3          	bnez	s2,ffffffffc02050d6 <do_execve+0x50>
    if (current->mm != NULL)
ffffffffc02051d2:	000d3783          	ld	a5,0(s10)
ffffffffc02051d6:	779c                	ld	a5,40(a5)
ffffffffc02051d8:	db95                	beqz	a5,ffffffffc020510c <do_execve+0x86>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc02051da:	00003617          	auipc	a2,0x3
ffffffffc02051de:	08660613          	addi	a2,a2,134 # ffffffffc0208260 <etext+0x1dbe>
ffffffffc02051e2:	25900593          	li	a1,601
ffffffffc02051e6:	00003517          	auipc	a0,0x3
ffffffffc02051ea:	eda50513          	addi	a0,a0,-294 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc02051ee:	f122                	sd	s0,160(sp)
ffffffffc02051f0:	e152                	sd	s4,128(sp)
ffffffffc02051f2:	fcd6                	sd	s5,120(sp)
ffffffffc02051f4:	f8da                	sd	s6,112(sp)
ffffffffc02051f6:	f4de                	sd	s7,104(sp)
ffffffffc02051f8:	f0e2                	sd	s8,96(sp)
ffffffffc02051fa:	ece6                	sd	s9,88(sp)
ffffffffc02051fc:	e4ee                	sd	s11,72(sp)
ffffffffc02051fe:	a4cfb0ef          	jal	ffffffffc020044a <__panic>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205202:	0386d703          	lhu	a4,56(a3)
ffffffffc0205206:	e152                	sd	s4,128(sp)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205208:	0206ba03          	ld	s4,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020520c:	00371793          	slli	a5,a4,0x3
ffffffffc0205210:	8f99                	sub	a5,a5,a4
ffffffffc0205212:	078e                	slli	a5,a5,0x3
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205214:	9a36                	add	s4,s4,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205216:	97d2                	add	a5,a5,s4
ffffffffc0205218:	f122                	sd	s0,160(sp)
ffffffffc020521a:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph++)
ffffffffc020521c:	00fa7e63          	bgeu	s4,a5,ffffffffc0205238 <do_execve+0x1b2>
ffffffffc0205220:	e4ee                	sd	s11,72(sp)
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0205222:	000a2783          	lw	a5,0(s4)
ffffffffc0205226:	4705                	li	a4,1
ffffffffc0205228:	10e78763          	beq	a5,a4,ffffffffc0205336 <do_execve+0x2b0>
    for (; ph < ph_end; ph++)
ffffffffc020522c:	77a2                	ld	a5,40(sp)
ffffffffc020522e:	038a0a13          	addi	s4,s4,56
ffffffffc0205232:	fefa68e3          	bltu	s4,a5,ffffffffc0205222 <do_execve+0x19c>
ffffffffc0205236:	6da6                	ld	s11,72(sp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc0205238:	4701                	li	a4,0
ffffffffc020523a:	46ad                	li	a3,11
ffffffffc020523c:	00100637          	lui	a2,0x100
ffffffffc0205240:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0205244:	854e                	mv	a0,s3
ffffffffc0205246:	c94fe0ef          	jal	ffffffffc02036da <mm_map>
ffffffffc020524a:	84aa                	mv	s1,a0
ffffffffc020524c:	1a051963          	bnez	a0,ffffffffc02053fe <do_execve+0x378>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0205250:	0189b503          	ld	a0,24(s3)
ffffffffc0205254:	467d                	li	a2,31
ffffffffc0205256:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc020525a:	a00fe0ef          	jal	ffffffffc020345a <pgdir_alloc_page>
ffffffffc020525e:	3a050463          	beqz	a0,ffffffffc0205606 <do_execve+0x580>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205262:	0189b503          	ld	a0,24(s3)
ffffffffc0205266:	467d                	li	a2,31
ffffffffc0205268:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc020526c:	9eefe0ef          	jal	ffffffffc020345a <pgdir_alloc_page>
ffffffffc0205270:	36050a63          	beqz	a0,ffffffffc02055e4 <do_execve+0x55e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205274:	0189b503          	ld	a0,24(s3)
ffffffffc0205278:	467d                	li	a2,31
ffffffffc020527a:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc020527e:	9dcfe0ef          	jal	ffffffffc020345a <pgdir_alloc_page>
ffffffffc0205282:	34050063          	beqz	a0,ffffffffc02055c2 <do_execve+0x53c>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205286:	0189b503          	ld	a0,24(s3)
ffffffffc020528a:	467d                	li	a2,31
ffffffffc020528c:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205290:	9cafe0ef          	jal	ffffffffc020345a <pgdir_alloc_page>
ffffffffc0205294:	30050663          	beqz	a0,ffffffffc02055a0 <do_execve+0x51a>
    mm->mm_count += 1;
ffffffffc0205298:	0309a783          	lw	a5,48(s3)
    current->mm = mm;
ffffffffc020529c:	000d3603          	ld	a2,0(s10)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc02052a0:	0189b683          	ld	a3,24(s3)
ffffffffc02052a4:	2785                	addiw	a5,a5,1
ffffffffc02052a6:	02f9a823          	sw	a5,48(s3)
    current->mm = mm;
ffffffffc02052aa:	03363423          	sd	s3,40(a2) # 100028 <_binary_obj___user_matrix_out_size+0xf4940>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc02052ae:	c02007b7          	lui	a5,0xc0200
ffffffffc02052b2:	2cf6ea63          	bltu	a3,a5,ffffffffc0205586 <do_execve+0x500>
ffffffffc02052b6:	000ab783          	ld	a5,0(s5)
ffffffffc02052ba:	577d                	li	a4,-1
ffffffffc02052bc:	177e                	slli	a4,a4,0x3f
ffffffffc02052be:	8e9d                	sub	a3,a3,a5
ffffffffc02052c0:	00c6d793          	srli	a5,a3,0xc
ffffffffc02052c4:	f654                	sd	a3,168(a2)
ffffffffc02052c6:	8fd9                	or	a5,a5,a4
ffffffffc02052c8:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc02052cc:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02052ce:	4581                	li	a1,0
ffffffffc02052d0:	12000613          	li	a2,288
ffffffffc02052d4:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc02052d6:	10043903          	ld	s2,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02052da:	19e010ef          	jal	ffffffffc0206478 <memset>
    tf->epc = elf->e_entry;
ffffffffc02052de:	67e2                	ld	a5,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02052e0:	000d3983          	ld	s3,0(s10)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc02052e4:	edf97913          	andi	s2,s2,-289
    tf->epc = elf->e_entry;
ffffffffc02052e8:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc02052ea:	4785                	li	a5,1
ffffffffc02052ec:	07fe                	slli	a5,a5,0x1f
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc02052ee:	02096913          	ori	s2,s2,32
    tf->epc = elf->e_entry;
ffffffffc02052f2:	10e43423          	sd	a4,264(s0)
    tf->gpr.sp = USTACKTOP;
ffffffffc02052f6:	e81c                	sd	a5,16(s0)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc02052f8:	11243023          	sd	s2,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02052fc:	4641                	li	a2,16
ffffffffc02052fe:	4581                	li	a1,0
ffffffffc0205300:	0b498513          	addi	a0,s3,180
ffffffffc0205304:	174010ef          	jal	ffffffffc0206478 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205308:	180c                	addi	a1,sp,48
ffffffffc020530a:	0b498513          	addi	a0,s3,180
ffffffffc020530e:	463d                	li	a2,15
ffffffffc0205310:	17a010ef          	jal	ffffffffc020648a <memcpy>
ffffffffc0205314:	740a                	ld	s0,160(sp)
ffffffffc0205316:	6a0a                	ld	s4,128(sp)
ffffffffc0205318:	7ae6                	ld	s5,120(sp)
ffffffffc020531a:	7b46                	ld	s6,112(sp)
ffffffffc020531c:	7ba6                	ld	s7,104(sp)
ffffffffc020531e:	7c06                	ld	s8,96(sp)
ffffffffc0205320:	6ce6                	ld	s9,88(sp)
}
ffffffffc0205322:	70aa                	ld	ra,168(sp)
ffffffffc0205324:	694a                	ld	s2,144(sp)
ffffffffc0205326:	69aa                	ld	s3,136(sp)
ffffffffc0205328:	6d46                	ld	s10,80(sp)
ffffffffc020532a:	8526                	mv	a0,s1
ffffffffc020532c:	64ea                	ld	s1,152(sp)
ffffffffc020532e:	614d                	addi	sp,sp,176
ffffffffc0205330:	8082                	ret
    int ret = -E_NO_MEM;
ffffffffc0205332:	54f1                	li	s1,-4
ffffffffc0205334:	bdad                	j	ffffffffc02051ae <do_execve+0x128>
        if (ph->p_filesz > ph->p_memsz)
ffffffffc0205336:	028a3603          	ld	a2,40(s4)
ffffffffc020533a:	020a3783          	ld	a5,32(s4)
ffffffffc020533e:	20f66663          	bltu	a2,a5,ffffffffc020554a <do_execve+0x4c4>
        if (ph->p_flags & ELF_PF_X)
ffffffffc0205342:	004a2783          	lw	a5,4(s4)
ffffffffc0205346:	0027971b          	slliw	a4,a5,0x2
        if (ph->p_flags & ELF_PF_W)
ffffffffc020534a:	0027f693          	andi	a3,a5,2
        if (ph->p_flags & ELF_PF_X)
ffffffffc020534e:	8b11                	andi	a4,a4,4
        if (ph->p_flags & ELF_PF_R)
ffffffffc0205350:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0205352:	cae9                	beqz	a3,ffffffffc0205424 <do_execve+0x39e>
        if (ph->p_flags & ELF_PF_R)
ffffffffc0205354:	1c079a63          	bnez	a5,ffffffffc0205528 <do_execve+0x4a2>
            perm |= (PTE_W | PTE_R);
ffffffffc0205358:	47dd                	li	a5,23
            vm_flags |= VM_WRITE;
ffffffffc020535a:	00276693          	ori	a3,a4,2
            perm |= (PTE_W | PTE_R);
ffffffffc020535e:	e43e                	sd	a5,8(sp)
        if (vm_flags & VM_EXEC)
ffffffffc0205360:	c709                	beqz	a4,ffffffffc020536a <do_execve+0x2e4>
            perm |= PTE_X;
ffffffffc0205362:	67a2                	ld	a5,8(sp)
ffffffffc0205364:	0087e793          	ori	a5,a5,8
ffffffffc0205368:	e43e                	sd	a5,8(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc020536a:	010a3583          	ld	a1,16(s4)
ffffffffc020536e:	4701                	li	a4,0
ffffffffc0205370:	854e                	mv	a0,s3
ffffffffc0205372:	b68fe0ef          	jal	ffffffffc02036da <mm_map>
ffffffffc0205376:	84aa                	mv	s1,a0
ffffffffc0205378:	1c051763          	bnez	a0,ffffffffc0205546 <do_execve+0x4c0>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc020537c:	010a3b03          	ld	s6,16(s4)
        end = ph->p_va + ph->p_filesz;
ffffffffc0205380:	020a3483          	ld	s1,32(s4)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0205384:	77fd                	lui	a5,0xfffff
ffffffffc0205386:	00fb75b3          	and	a1,s6,a5
        end = ph->p_va + ph->p_filesz;
ffffffffc020538a:	94da                	add	s1,s1,s6
        while (start < end)
ffffffffc020538c:	1a9b7863          	bgeu	s6,s1,ffffffffc020553c <do_execve+0x4b6>
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205390:	008a3903          	ld	s2,8(s4)
ffffffffc0205394:	67e2                	ld	a5,24(sp)
ffffffffc0205396:	993e                	add	s2,s2,a5
ffffffffc0205398:	a881                	j	ffffffffc02053e8 <do_execve+0x362>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc020539a:	6785                	lui	a5,0x1
ffffffffc020539c:	00f58db3          	add	s11,a1,a5
                size -= la - end;
ffffffffc02053a0:	41648633          	sub	a2,s1,s6
            if (end < la)
ffffffffc02053a4:	01b4e463          	bltu	s1,s11,ffffffffc02053ac <do_execve+0x326>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc02053a8:	416d8633          	sub	a2,s11,s6
    return page - pages + nbase;
ffffffffc02053ac:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc02053b0:	67c2                	ld	a5,16(sp)
ffffffffc02053b2:	000cb503          	ld	a0,0(s9)
    return page - pages + nbase;
ffffffffc02053b6:	40d406b3          	sub	a3,s0,a3
ffffffffc02053ba:	8699                	srai	a3,a3,0x6
ffffffffc02053bc:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc02053be:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc02053c2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02053c4:	18a87663          	bgeu	a6,a0,ffffffffc0205550 <do_execve+0x4ca>
ffffffffc02053c8:	000ab503          	ld	a0,0(s5)
ffffffffc02053cc:	40bb05b3          	sub	a1,s6,a1
            memcpy(page2kva(page) + off, from, size);
ffffffffc02053d0:	e032                	sd	a2,0(sp)
ffffffffc02053d2:	9536                	add	a0,a0,a3
ffffffffc02053d4:	952e                	add	a0,a0,a1
ffffffffc02053d6:	85ca                	mv	a1,s2
ffffffffc02053d8:	0b2010ef          	jal	ffffffffc020648a <memcpy>
            start += size, from += size;
ffffffffc02053dc:	6602                	ld	a2,0(sp)
ffffffffc02053de:	9b32                	add	s6,s6,a2
ffffffffc02053e0:	9932                	add	s2,s2,a2
        while (start < end)
ffffffffc02053e2:	049b7863          	bgeu	s6,s1,ffffffffc0205432 <do_execve+0x3ac>
ffffffffc02053e6:	85ee                	mv	a1,s11
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc02053e8:	0189b503          	ld	a0,24(s3)
ffffffffc02053ec:	6622                	ld	a2,8(sp)
ffffffffc02053ee:	e02e                	sd	a1,0(sp)
ffffffffc02053f0:	86afe0ef          	jal	ffffffffc020345a <pgdir_alloc_page>
ffffffffc02053f4:	6582                	ld	a1,0(sp)
ffffffffc02053f6:	842a                	mv	s0,a0
ffffffffc02053f8:	f14d                	bnez	a0,ffffffffc020539a <do_execve+0x314>
ffffffffc02053fa:	6da6                	ld	s11,72(sp)
        ret = -E_NO_MEM;
ffffffffc02053fc:	54f1                	li	s1,-4
    exit_mmap(mm);
ffffffffc02053fe:	854e                	mv	a0,s3
ffffffffc0205400:	c3efe0ef          	jal	ffffffffc020383e <exit_mmap>
ffffffffc0205404:	0189b903          	ld	s2,24(s3)
ffffffffc0205408:	740a                	ld	s0,160(sp)
ffffffffc020540a:	6a0a                	ld	s4,128(sp)
ffffffffc020540c:	b371                	j	ffffffffc0205198 <do_execve+0x112>
            exit_mmap(mm);
ffffffffc020540e:	854a                	mv	a0,s2
ffffffffc0205410:	c2efe0ef          	jal	ffffffffc020383e <exit_mmap>
            put_pgdir(mm);
ffffffffc0205414:	01893503          	ld	a0,24(s2)
ffffffffc0205418:	a4aff0ef          	jal	ffffffffc0204662 <put_pgdir.isra.0>
            mm_destroy(mm);
ffffffffc020541c:	854a                	mv	a0,s2
ffffffffc020541e:	a6afe0ef          	jal	ffffffffc0203688 <mm_destroy>
ffffffffc0205422:	b1cd                	j	ffffffffc0205104 <do_execve+0x7e>
        if (ph->p_flags & ELF_PF_R)
ffffffffc0205424:	0e078e63          	beqz	a5,ffffffffc0205520 <do_execve+0x49a>
            perm |= PTE_R;
ffffffffc0205428:	47cd                	li	a5,19
            vm_flags |= VM_READ;
ffffffffc020542a:	00176693          	ori	a3,a4,1
            perm |= PTE_R;
ffffffffc020542e:	e43e                	sd	a5,8(sp)
ffffffffc0205430:	bf05                	j	ffffffffc0205360 <do_execve+0x2da>
        end = ph->p_va + ph->p_memsz;
ffffffffc0205432:	010a3483          	ld	s1,16(s4)
ffffffffc0205436:	028a3683          	ld	a3,40(s4)
ffffffffc020543a:	94b6                	add	s1,s1,a3
        if (start < la)
ffffffffc020543c:	07bb7c63          	bgeu	s6,s11,ffffffffc02054b4 <do_execve+0x42e>
            if (start == end)
ffffffffc0205440:	df6486e3          	beq	s1,s6,ffffffffc020522c <do_execve+0x1a6>
                size -= la - end;
ffffffffc0205444:	41648933          	sub	s2,s1,s6
            if (end < la)
ffffffffc0205448:	0fb4f563          	bgeu	s1,s11,ffffffffc0205532 <do_execve+0x4ac>
    return page - pages + nbase;
ffffffffc020544c:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc0205450:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0205454:	40d406b3          	sub	a3,s0,a3
ffffffffc0205458:	8699                	srai	a3,a3,0x6
ffffffffc020545a:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc020545c:	00c69593          	slli	a1,a3,0xc
ffffffffc0205460:	81b1                	srli	a1,a1,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0205462:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205464:	0ec5f663          	bgeu	a1,a2,ffffffffc0205550 <do_execve+0x4ca>
ffffffffc0205468:	000ab603          	ld	a2,0(s5)
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc020546c:	6505                	lui	a0,0x1
ffffffffc020546e:	955a                	add	a0,a0,s6
ffffffffc0205470:	96b2                	add	a3,a3,a2
ffffffffc0205472:	41b50533          	sub	a0,a0,s11
            memset(page2kva(page) + off, 0, size);
ffffffffc0205476:	9536                	add	a0,a0,a3
ffffffffc0205478:	864a                	mv	a2,s2
ffffffffc020547a:	4581                	li	a1,0
ffffffffc020547c:	7fd000ef          	jal	ffffffffc0206478 <memset>
            start += size;
ffffffffc0205480:	9b4a                	add	s6,s6,s2
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0205482:	01b4b6b3          	sltu	a3,s1,s11
ffffffffc0205486:	01b4f463          	bgeu	s1,s11,ffffffffc020548e <do_execve+0x408>
ffffffffc020548a:	db6481e3          	beq	s1,s6,ffffffffc020522c <do_execve+0x1a6>
ffffffffc020548e:	e299                	bnez	a3,ffffffffc0205494 <do_execve+0x40e>
ffffffffc0205490:	03bb0263          	beq	s6,s11,ffffffffc02054b4 <do_execve+0x42e>
ffffffffc0205494:	00003697          	auipc	a3,0x3
ffffffffc0205498:	df468693          	addi	a3,a3,-524 # ffffffffc0208288 <etext+0x1de6>
ffffffffc020549c:	00002617          	auipc	a2,0x2
ffffffffc02054a0:	9dc60613          	addi	a2,a2,-1572 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02054a4:	2c200593          	li	a1,706
ffffffffc02054a8:	00003517          	auipc	a0,0x3
ffffffffc02054ac:	c1850513          	addi	a0,a0,-1000 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc02054b0:	f9bfa0ef          	jal	ffffffffc020044a <__panic>
        while (start < end)
ffffffffc02054b4:	d69b7ce3          	bgeu	s6,s1,ffffffffc020522c <do_execve+0x1a6>
ffffffffc02054b8:	56fd                	li	a3,-1
ffffffffc02054ba:	00c6d793          	srli	a5,a3,0xc
ffffffffc02054be:	f03e                	sd	a5,32(sp)
ffffffffc02054c0:	a0b9                	j	ffffffffc020550e <do_execve+0x488>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc02054c2:	6785                	lui	a5,0x1
ffffffffc02054c4:	00fd8833          	add	a6,s11,a5
                size -= la - end;
ffffffffc02054c8:	41648933          	sub	s2,s1,s6
            if (end < la)
ffffffffc02054cc:	0104e463          	bltu	s1,a6,ffffffffc02054d4 <do_execve+0x44e>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc02054d0:	41680933          	sub	s2,a6,s6
    return page - pages + nbase;
ffffffffc02054d4:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc02054d8:	7782                	ld	a5,32(sp)
ffffffffc02054da:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc02054de:	40d406b3          	sub	a3,s0,a3
ffffffffc02054e2:	8699                	srai	a3,a3,0x6
ffffffffc02054e4:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc02054e6:	00f6f533          	and	a0,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc02054ea:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02054ec:	06b57263          	bgeu	a0,a1,ffffffffc0205550 <do_execve+0x4ca>
ffffffffc02054f0:	000ab583          	ld	a1,0(s5)
ffffffffc02054f4:	41bb0533          	sub	a0,s6,s11
            memset(page2kva(page) + off, 0, size);
ffffffffc02054f8:	864a                	mv	a2,s2
ffffffffc02054fa:	96ae                	add	a3,a3,a1
ffffffffc02054fc:	9536                	add	a0,a0,a3
ffffffffc02054fe:	4581                	li	a1,0
            start += size;
ffffffffc0205500:	9b4a                	add	s6,s6,s2
ffffffffc0205502:	e042                	sd	a6,0(sp)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205504:	775000ef          	jal	ffffffffc0206478 <memset>
        while (start < end)
ffffffffc0205508:	d29b72e3          	bgeu	s6,s1,ffffffffc020522c <do_execve+0x1a6>
ffffffffc020550c:	6d82                	ld	s11,0(sp)
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc020550e:	0189b503          	ld	a0,24(s3)
ffffffffc0205512:	6622                	ld	a2,8(sp)
ffffffffc0205514:	85ee                	mv	a1,s11
ffffffffc0205516:	f45fd0ef          	jal	ffffffffc020345a <pgdir_alloc_page>
ffffffffc020551a:	842a                	mv	s0,a0
ffffffffc020551c:	f15d                	bnez	a0,ffffffffc02054c2 <do_execve+0x43c>
ffffffffc020551e:	bdf1                	j	ffffffffc02053fa <do_execve+0x374>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205520:	47c5                	li	a5,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc0205522:	86ba                	mv	a3,a4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205524:	e43e                	sd	a5,8(sp)
ffffffffc0205526:	bd2d                	j	ffffffffc0205360 <do_execve+0x2da>
            perm |= (PTE_W | PTE_R);
ffffffffc0205528:	47dd                	li	a5,23
            vm_flags |= VM_READ;
ffffffffc020552a:	00376693          	ori	a3,a4,3
            perm |= (PTE_W | PTE_R);
ffffffffc020552e:	e43e                	sd	a5,8(sp)
ffffffffc0205530:	bd05                	j	ffffffffc0205360 <do_execve+0x2da>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0205532:	416d8933          	sub	s2,s11,s6
ffffffffc0205536:	bf19                	j	ffffffffc020544c <do_execve+0x3c6>
        return -E_INVAL;
ffffffffc0205538:	54f5                	li	s1,-3
ffffffffc020553a:	b3e5                	j	ffffffffc0205322 <do_execve+0x29c>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc020553c:	8dae                	mv	s11,a1
        while (start < end)
ffffffffc020553e:	84da                	mv	s1,s6
ffffffffc0205540:	bddd                	j	ffffffffc0205436 <do_execve+0x3b0>
    int ret = -E_NO_MEM;
ffffffffc0205542:	54f1                	li	s1,-4
ffffffffc0205544:	b195                	j	ffffffffc02051a8 <do_execve+0x122>
ffffffffc0205546:	6da6                	ld	s11,72(sp)
ffffffffc0205548:	bd5d                	j	ffffffffc02053fe <do_execve+0x378>
            ret = -E_INVAL_ELF;
ffffffffc020554a:	6da6                	ld	s11,72(sp)
ffffffffc020554c:	54e1                	li	s1,-8
ffffffffc020554e:	bd45                	j	ffffffffc02053fe <do_execve+0x378>
ffffffffc0205550:	00002617          	auipc	a2,0x2
ffffffffc0205554:	cd860613          	addi	a2,a2,-808 # ffffffffc0207228 <etext+0xd86>
ffffffffc0205558:	07100593          	li	a1,113
ffffffffc020555c:	00002517          	auipc	a0,0x2
ffffffffc0205560:	cf450513          	addi	a0,a0,-780 # ffffffffc0207250 <etext+0xdae>
ffffffffc0205564:	ee7fa0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0205568:	00002617          	auipc	a2,0x2
ffffffffc020556c:	cc060613          	addi	a2,a2,-832 # ffffffffc0207228 <etext+0xd86>
ffffffffc0205570:	07100593          	li	a1,113
ffffffffc0205574:	00002517          	auipc	a0,0x2
ffffffffc0205578:	cdc50513          	addi	a0,a0,-804 # ffffffffc0207250 <etext+0xdae>
ffffffffc020557c:	f122                	sd	s0,160(sp)
ffffffffc020557e:	e152                	sd	s4,128(sp)
ffffffffc0205580:	e4ee                	sd	s11,72(sp)
ffffffffc0205582:	ec9fa0ef          	jal	ffffffffc020044a <__panic>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0205586:	00002617          	auipc	a2,0x2
ffffffffc020558a:	d4a60613          	addi	a2,a2,-694 # ffffffffc02072d0 <etext+0xe2e>
ffffffffc020558e:	2e100593          	li	a1,737
ffffffffc0205592:	00003517          	auipc	a0,0x3
ffffffffc0205596:	b2e50513          	addi	a0,a0,-1234 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc020559a:	e4ee                	sd	s11,72(sp)
ffffffffc020559c:	eaffa0ef          	jal	ffffffffc020044a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc02055a0:	00003697          	auipc	a3,0x3
ffffffffc02055a4:	e0068693          	addi	a3,a3,-512 # ffffffffc02083a0 <etext+0x1efe>
ffffffffc02055a8:	00002617          	auipc	a2,0x2
ffffffffc02055ac:	8d060613          	addi	a2,a2,-1840 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02055b0:	2dc00593          	li	a1,732
ffffffffc02055b4:	00003517          	auipc	a0,0x3
ffffffffc02055b8:	b0c50513          	addi	a0,a0,-1268 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc02055bc:	e4ee                	sd	s11,72(sp)
ffffffffc02055be:	e8dfa0ef          	jal	ffffffffc020044a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc02055c2:	00003697          	auipc	a3,0x3
ffffffffc02055c6:	d9668693          	addi	a3,a3,-618 # ffffffffc0208358 <etext+0x1eb6>
ffffffffc02055ca:	00002617          	auipc	a2,0x2
ffffffffc02055ce:	8ae60613          	addi	a2,a2,-1874 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02055d2:	2db00593          	li	a1,731
ffffffffc02055d6:	00003517          	auipc	a0,0x3
ffffffffc02055da:	aea50513          	addi	a0,a0,-1302 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc02055de:	e4ee                	sd	s11,72(sp)
ffffffffc02055e0:	e6bfa0ef          	jal	ffffffffc020044a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc02055e4:	00003697          	auipc	a3,0x3
ffffffffc02055e8:	d2c68693          	addi	a3,a3,-724 # ffffffffc0208310 <etext+0x1e6e>
ffffffffc02055ec:	00002617          	auipc	a2,0x2
ffffffffc02055f0:	88c60613          	addi	a2,a2,-1908 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02055f4:	2da00593          	li	a1,730
ffffffffc02055f8:	00003517          	auipc	a0,0x3
ffffffffc02055fc:	ac850513          	addi	a0,a0,-1336 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc0205600:	e4ee                	sd	s11,72(sp)
ffffffffc0205602:	e49fa0ef          	jal	ffffffffc020044a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0205606:	00003697          	auipc	a3,0x3
ffffffffc020560a:	cc268693          	addi	a3,a3,-830 # ffffffffc02082c8 <etext+0x1e26>
ffffffffc020560e:	00002617          	auipc	a2,0x2
ffffffffc0205612:	86a60613          	addi	a2,a2,-1942 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0205616:	2d900593          	li	a1,729
ffffffffc020561a:	00003517          	auipc	a0,0x3
ffffffffc020561e:	aa650513          	addi	a0,a0,-1370 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc0205622:	e4ee                	sd	s11,72(sp)
ffffffffc0205624:	e27fa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0205628 <user_main>:
{
ffffffffc0205628:	1101                	addi	sp,sp,-32
ffffffffc020562a:	e426                	sd	s1,8(sp)
    KERNEL_EXECVE(exit);
ffffffffc020562c:	000c7497          	auipc	s1,0xc7
ffffffffc0205630:	d2448493          	addi	s1,s1,-732 # ffffffffc02cc350 <current>
ffffffffc0205634:	609c                	ld	a5,0(s1)
ffffffffc0205636:	00003617          	auipc	a2,0x3
ffffffffc020563a:	db260613          	addi	a2,a2,-590 # ffffffffc02083e8 <etext+0x1f46>
ffffffffc020563e:	00003517          	auipc	a0,0x3
ffffffffc0205642:	db250513          	addi	a0,a0,-590 # ffffffffc02083f0 <etext+0x1f4e>
ffffffffc0205646:	43cc                	lw	a1,4(a5)
{
ffffffffc0205648:	ec06                	sd	ra,24(sp)
ffffffffc020564a:	e822                	sd	s0,16(sp)
ffffffffc020564c:	e04a                	sd	s2,0(sp)
    KERNEL_EXECVE(exit);
ffffffffc020564e:	b4bfa0ef          	jal	ffffffffc0200198 <cprintf>
    size_t len = strlen(name);
ffffffffc0205652:	00003517          	auipc	a0,0x3
ffffffffc0205656:	d9650513          	addi	a0,a0,-618 # ffffffffc02083e8 <etext+0x1f46>
ffffffffc020565a:	56b000ef          	jal	ffffffffc02063c4 <strlen>
    struct trapframe *old_tf = current->tf;
ffffffffc020565e:	6098                	ld	a4,0(s1)
    struct trapframe *new_tf = (struct trapframe *)(current->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0205660:	6789                	lui	a5,0x2
ffffffffc0205662:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_softint_out_size-0x7208>
ffffffffc0205666:	6b00                	ld	s0,16(a4)
    memcpy(new_tf, old_tf, sizeof(struct trapframe));
ffffffffc0205668:	734c                	ld	a1,160(a4)
    size_t len = strlen(name);
ffffffffc020566a:	892a                	mv	s2,a0
    struct trapframe *new_tf = (struct trapframe *)(current->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc020566c:	943e                	add	s0,s0,a5
    memcpy(new_tf, old_tf, sizeof(struct trapframe));
ffffffffc020566e:	12000613          	li	a2,288
ffffffffc0205672:	8522                	mv	a0,s0
ffffffffc0205674:	617000ef          	jal	ffffffffc020648a <memcpy>
    current->tf = new_tf;
ffffffffc0205678:	609c                	ld	a5,0(s1)
    ret = do_execve(name, len, binary, size);
ffffffffc020567a:	85ca                	mv	a1,s2
ffffffffc020567c:	3fe05697          	auipc	a3,0x3fe05
ffffffffc0205680:	05c68693          	addi	a3,a3,92 # a6d8 <_binary_obj___user_exit_out_size>
    current->tf = new_tf;
ffffffffc0205684:	f3c0                	sd	s0,160(a5)
    ret = do_execve(name, len, binary, size);
ffffffffc0205686:	00025617          	auipc	a2,0x25
ffffffffc020568a:	ce260613          	addi	a2,a2,-798 # ffffffffc022a368 <_binary_obj___user_exit_out_start>
ffffffffc020568e:	00003517          	auipc	a0,0x3
ffffffffc0205692:	d5a50513          	addi	a0,a0,-678 # ffffffffc02083e8 <etext+0x1f46>
ffffffffc0205696:	9f1ff0ef          	jal	ffffffffc0205086 <do_execve>
    asm volatile(
ffffffffc020569a:	8122                	mv	sp,s0
ffffffffc020569c:	f4cfb06f          	j	ffffffffc0200de8 <__trapret>
    panic("user_main execve failed.\n");
ffffffffc02056a0:	00003617          	auipc	a2,0x3
ffffffffc02056a4:	d7860613          	addi	a2,a2,-648 # ffffffffc0208418 <etext+0x1f76>
ffffffffc02056a8:	3c600593          	li	a1,966
ffffffffc02056ac:	00003517          	auipc	a0,0x3
ffffffffc02056b0:	a1450513          	addi	a0,a0,-1516 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc02056b4:	d97fa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02056b8 <do_yield>:
    current->need_resched = 1;
ffffffffc02056b8:	000c7797          	auipc	a5,0xc7
ffffffffc02056bc:	c987b783          	ld	a5,-872(a5) # ffffffffc02cc350 <current>
ffffffffc02056c0:	4705                	li	a4,1
}
ffffffffc02056c2:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc02056c4:	ef98                	sd	a4,24(a5)
}
ffffffffc02056c6:	8082                	ret

ffffffffc02056c8 <do_wait>:
    if (code_store != NULL)
ffffffffc02056c8:	c59d                	beqz	a1,ffffffffc02056f6 <do_wait+0x2e>
{
ffffffffc02056ca:	1101                	addi	sp,sp,-32
ffffffffc02056cc:	e02a                	sd	a0,0(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02056ce:	000c7517          	auipc	a0,0xc7
ffffffffc02056d2:	c8253503          	ld	a0,-894(a0) # ffffffffc02cc350 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc02056d6:	4685                	li	a3,1
ffffffffc02056d8:	4611                	li	a2,4
ffffffffc02056da:	7508                	ld	a0,40(a0)
{
ffffffffc02056dc:	ec06                	sd	ra,24(sp)
ffffffffc02056de:	e42e                	sd	a1,8(sp)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc02056e0:	cfcfe0ef          	jal	ffffffffc0203bdc <user_mem_check>
ffffffffc02056e4:	6702                	ld	a4,0(sp)
ffffffffc02056e6:	67a2                	ld	a5,8(sp)
ffffffffc02056e8:	c909                	beqz	a0,ffffffffc02056fa <do_wait+0x32>
}
ffffffffc02056ea:	60e2                	ld	ra,24(sp)
ffffffffc02056ec:	85be                	mv	a1,a5
ffffffffc02056ee:	853a                	mv	a0,a4
ffffffffc02056f0:	6105                	addi	sp,sp,32
ffffffffc02056f2:	e8aff06f          	j	ffffffffc0204d7c <do_wait.part.0>
ffffffffc02056f6:	e86ff06f          	j	ffffffffc0204d7c <do_wait.part.0>
ffffffffc02056fa:	60e2                	ld	ra,24(sp)
ffffffffc02056fc:	5575                	li	a0,-3
ffffffffc02056fe:	6105                	addi	sp,sp,32
ffffffffc0205700:	8082                	ret

ffffffffc0205702 <do_kill>:
    if (0 < pid && pid < MAX_PID)
ffffffffc0205702:	6789                	lui	a5,0x2
ffffffffc0205704:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205708:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x70ea>
ffffffffc020570a:	06e7e463          	bltu	a5,a4,ffffffffc0205772 <do_kill+0x70>
{
ffffffffc020570e:	1101                	addi	sp,sp,-32
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205710:	45a9                	li	a1,10
{
ffffffffc0205712:	ec06                	sd	ra,24(sp)
ffffffffc0205714:	e42a                	sd	a0,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205716:	0cd000ef          	jal	ffffffffc0205fe2 <hash32>
ffffffffc020571a:	02051793          	slli	a5,a0,0x20
ffffffffc020571e:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205722:	000c3797          	auipc	a5,0xc3
ffffffffc0205726:	b8e78793          	addi	a5,a5,-1138 # ffffffffc02c82b0 <hash_list>
ffffffffc020572a:	96be                	add	a3,a3,a5
        while ((le = list_next(le)) != list)
ffffffffc020572c:	6622                	ld	a2,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020572e:	8536                	mv	a0,a3
        while ((le = list_next(le)) != list)
ffffffffc0205730:	a029                	j	ffffffffc020573a <do_kill+0x38>
            if (proc->pid == pid)
ffffffffc0205732:	f2c52703          	lw	a4,-212(a0)
ffffffffc0205736:	00c70963          	beq	a4,a2,ffffffffc0205748 <do_kill+0x46>
ffffffffc020573a:	6508                	ld	a0,8(a0)
        while ((le = list_next(le)) != list)
ffffffffc020573c:	fea69be3          	bne	a3,a0,ffffffffc0205732 <do_kill+0x30>
}
ffffffffc0205740:	60e2                	ld	ra,24(sp)
    return -E_INVAL;
ffffffffc0205742:	5575                	li	a0,-3
}
ffffffffc0205744:	6105                	addi	sp,sp,32
ffffffffc0205746:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc0205748:	fd852703          	lw	a4,-40(a0)
ffffffffc020574c:	00177693          	andi	a3,a4,1
ffffffffc0205750:	e29d                	bnez	a3,ffffffffc0205776 <do_kill+0x74>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0205752:	4954                	lw	a3,20(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205754:	00176713          	ori	a4,a4,1
ffffffffc0205758:	fce52c23          	sw	a4,-40(a0)
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc020575c:	0006c663          	bltz	a3,ffffffffc0205768 <do_kill+0x66>
            return 0;
ffffffffc0205760:	4501                	li	a0,0
}
ffffffffc0205762:	60e2                	ld	ra,24(sp)
ffffffffc0205764:	6105                	addi	sp,sp,32
ffffffffc0205766:	8082                	ret
                wakeup_proc(proc);
ffffffffc0205768:	f2850513          	addi	a0,a0,-216
ffffffffc020576c:	344000ef          	jal	ffffffffc0205ab0 <wakeup_proc>
ffffffffc0205770:	bfc5                	j	ffffffffc0205760 <do_kill+0x5e>
    return -E_INVAL;
ffffffffc0205772:	5575                	li	a0,-3
}
ffffffffc0205774:	8082                	ret
        return -E_KILLED;
ffffffffc0205776:	555d                	li	a0,-9
ffffffffc0205778:	b7ed                	j	ffffffffc0205762 <do_kill+0x60>

ffffffffc020577a <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc020577a:	1101                	addi	sp,sp,-32
ffffffffc020577c:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc020577e:	000c7797          	auipc	a5,0xc7
ffffffffc0205782:	b3278793          	addi	a5,a5,-1230 # ffffffffc02cc2b0 <proc_list>
ffffffffc0205786:	ec06                	sd	ra,24(sp)
ffffffffc0205788:	e822                	sd	s0,16(sp)
ffffffffc020578a:	e04a                	sd	s2,0(sp)
ffffffffc020578c:	000c3497          	auipc	s1,0xc3
ffffffffc0205790:	b2448493          	addi	s1,s1,-1244 # ffffffffc02c82b0 <hash_list>
ffffffffc0205794:	e79c                	sd	a5,8(a5)
ffffffffc0205796:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0205798:	000c7717          	auipc	a4,0xc7
ffffffffc020579c:	b1870713          	addi	a4,a4,-1256 # ffffffffc02cc2b0 <proc_list>
ffffffffc02057a0:	87a6                	mv	a5,s1
ffffffffc02057a2:	e79c                	sd	a5,8(a5)
ffffffffc02057a4:	e39c                	sd	a5,0(a5)
ffffffffc02057a6:	07c1                	addi	a5,a5,16
ffffffffc02057a8:	fee79de3          	bne	a5,a4,ffffffffc02057a2 <proc_init+0x28>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc02057ac:	e13fe0ef          	jal	ffffffffc02045be <alloc_proc>
ffffffffc02057b0:	000c7917          	auipc	s2,0xc7
ffffffffc02057b4:	bb090913          	addi	s2,s2,-1104 # ffffffffc02cc360 <idleproc>
ffffffffc02057b8:	00a93023          	sd	a0,0(s2)
ffffffffc02057bc:	10050363          	beqz	a0,ffffffffc02058c2 <proc_init+0x148>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc02057c0:	4789                	li	a5,2
ffffffffc02057c2:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02057c4:	00005797          	auipc	a5,0x5
ffffffffc02057c8:	83c78793          	addi	a5,a5,-1988 # ffffffffc020a000 <bootstack>
ffffffffc02057cc:	e91c                	sd	a5,16(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02057ce:	0b450413          	addi	s0,a0,180
    idleproc->need_resched = 1;
ffffffffc02057d2:	4785                	li	a5,1
ffffffffc02057d4:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02057d6:	4641                	li	a2,16
ffffffffc02057d8:	8522                	mv	a0,s0
ffffffffc02057da:	4581                	li	a1,0
ffffffffc02057dc:	49d000ef          	jal	ffffffffc0206478 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02057e0:	8522                	mv	a0,s0
ffffffffc02057e2:	463d                	li	a2,15
ffffffffc02057e4:	00003597          	auipc	a1,0x3
ffffffffc02057e8:	c6c58593          	addi	a1,a1,-916 # ffffffffc0208450 <etext+0x1fae>
ffffffffc02057ec:	49f000ef          	jal	ffffffffc020648a <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc02057f0:	000c7797          	auipc	a5,0xc7
ffffffffc02057f4:	b587a783          	lw	a5,-1192(a5) # ffffffffc02cc348 <nr_process>

    current = idleproc;
ffffffffc02057f8:	00093703          	ld	a4,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc02057fc:	4601                	li	a2,0
    nr_process++;
ffffffffc02057fe:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205800:	4581                	li	a1,0
ffffffffc0205802:	fffff517          	auipc	a0,0xfffff
ffffffffc0205806:	75c50513          	addi	a0,a0,1884 # ffffffffc0204f5e <init_main>
    current = idleproc;
ffffffffc020580a:	000c7697          	auipc	a3,0xc7
ffffffffc020580e:	b4e6b323          	sd	a4,-1210(a3) # ffffffffc02cc350 <current>
    nr_process++;
ffffffffc0205812:	000c7717          	auipc	a4,0xc7
ffffffffc0205816:	b2f72b23          	sw	a5,-1226(a4) # ffffffffc02cc348 <nr_process>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc020581a:	bcaff0ef          	jal	ffffffffc0204be4 <kernel_thread>
ffffffffc020581e:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc0205820:	08a05563          	blez	a0,ffffffffc02058aa <proc_init+0x130>
    if (0 < pid && pid < MAX_PID)
ffffffffc0205824:	6789                	lui	a5,0x2
ffffffffc0205826:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x70ea>
ffffffffc0205828:	fff5071b          	addiw	a4,a0,-1
ffffffffc020582c:	02e7e463          	bltu	a5,a4,ffffffffc0205854 <proc_init+0xda>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205830:	45a9                	li	a1,10
ffffffffc0205832:	7b0000ef          	jal	ffffffffc0205fe2 <hash32>
ffffffffc0205836:	02051713          	slli	a4,a0,0x20
ffffffffc020583a:	01c75793          	srli	a5,a4,0x1c
ffffffffc020583e:	00f486b3          	add	a3,s1,a5
ffffffffc0205842:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0205844:	a029                	j	ffffffffc020584e <proc_init+0xd4>
            if (proc->pid == pid)
ffffffffc0205846:	f2c7a703          	lw	a4,-212(a5)
ffffffffc020584a:	04870d63          	beq	a4,s0,ffffffffc02058a4 <proc_init+0x12a>
    return listelm->next;
ffffffffc020584e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0205850:	fef69be3          	bne	a3,a5,ffffffffc0205846 <proc_init+0xcc>
    return NULL;
ffffffffc0205854:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205856:	0b478413          	addi	s0,a5,180
ffffffffc020585a:	4641                	li	a2,16
ffffffffc020585c:	4581                	li	a1,0
ffffffffc020585e:	8522                	mv	a0,s0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205860:	000c7717          	auipc	a4,0xc7
ffffffffc0205864:	aef73c23          	sd	a5,-1288(a4) # ffffffffc02cc358 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205868:	411000ef          	jal	ffffffffc0206478 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020586c:	8522                	mv	a0,s0
ffffffffc020586e:	463d                	li	a2,15
ffffffffc0205870:	00003597          	auipc	a1,0x3
ffffffffc0205874:	c0858593          	addi	a1,a1,-1016 # ffffffffc0208478 <etext+0x1fd6>
ffffffffc0205878:	413000ef          	jal	ffffffffc020648a <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020587c:	00093783          	ld	a5,0(s2)
ffffffffc0205880:	cfad                	beqz	a5,ffffffffc02058fa <proc_init+0x180>
ffffffffc0205882:	43dc                	lw	a5,4(a5)
ffffffffc0205884:	ebbd                	bnez	a5,ffffffffc02058fa <proc_init+0x180>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205886:	000c7797          	auipc	a5,0xc7
ffffffffc020588a:	ad27b783          	ld	a5,-1326(a5) # ffffffffc02cc358 <initproc>
ffffffffc020588e:	c7b1                	beqz	a5,ffffffffc02058da <proc_init+0x160>
ffffffffc0205890:	43d8                	lw	a4,4(a5)
ffffffffc0205892:	4785                	li	a5,1
ffffffffc0205894:	04f71363          	bne	a4,a5,ffffffffc02058da <proc_init+0x160>
}
ffffffffc0205898:	60e2                	ld	ra,24(sp)
ffffffffc020589a:	6442                	ld	s0,16(sp)
ffffffffc020589c:	64a2                	ld	s1,8(sp)
ffffffffc020589e:	6902                	ld	s2,0(sp)
ffffffffc02058a0:	6105                	addi	sp,sp,32
ffffffffc02058a2:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02058a4:	f2878793          	addi	a5,a5,-216
ffffffffc02058a8:	b77d                	j	ffffffffc0205856 <proc_init+0xdc>
        panic("create init_main failed.\n");
ffffffffc02058aa:	00003617          	auipc	a2,0x3
ffffffffc02058ae:	bae60613          	addi	a2,a2,-1106 # ffffffffc0208458 <etext+0x1fb6>
ffffffffc02058b2:	40400593          	li	a1,1028
ffffffffc02058b6:	00003517          	auipc	a0,0x3
ffffffffc02058ba:	80a50513          	addi	a0,a0,-2038 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc02058be:	b8dfa0ef          	jal	ffffffffc020044a <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc02058c2:	00003617          	auipc	a2,0x3
ffffffffc02058c6:	b7660613          	addi	a2,a2,-1162 # ffffffffc0208438 <etext+0x1f96>
ffffffffc02058ca:	3f500593          	li	a1,1013
ffffffffc02058ce:	00002517          	auipc	a0,0x2
ffffffffc02058d2:	7f250513          	addi	a0,a0,2034 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc02058d6:	b75fa0ef          	jal	ffffffffc020044a <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02058da:	00003697          	auipc	a3,0x3
ffffffffc02058de:	bce68693          	addi	a3,a3,-1074 # ffffffffc02084a8 <etext+0x2006>
ffffffffc02058e2:	00001617          	auipc	a2,0x1
ffffffffc02058e6:	59660613          	addi	a2,a2,1430 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc02058ea:	40b00593          	li	a1,1035
ffffffffc02058ee:	00002517          	auipc	a0,0x2
ffffffffc02058f2:	7d250513          	addi	a0,a0,2002 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc02058f6:	b55fa0ef          	jal	ffffffffc020044a <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02058fa:	00003697          	auipc	a3,0x3
ffffffffc02058fe:	b8668693          	addi	a3,a3,-1146 # ffffffffc0208480 <etext+0x1fde>
ffffffffc0205902:	00001617          	auipc	a2,0x1
ffffffffc0205906:	57660613          	addi	a2,a2,1398 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc020590a:	40a00593          	li	a1,1034
ffffffffc020590e:	00002517          	auipc	a0,0x2
ffffffffc0205912:	7b250513          	addi	a0,a0,1970 # ffffffffc02080c0 <etext+0x1c1e>
ffffffffc0205916:	b35fa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020591a <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc020591a:	1141                	addi	sp,sp,-16
ffffffffc020591c:	e022                	sd	s0,0(sp)
ffffffffc020591e:	e406                	sd	ra,8(sp)
ffffffffc0205920:	000c7417          	auipc	s0,0xc7
ffffffffc0205924:	a3040413          	addi	s0,s0,-1488 # ffffffffc02cc350 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc0205928:	6018                	ld	a4,0(s0)
ffffffffc020592a:	6f1c                	ld	a5,24(a4)
ffffffffc020592c:	dffd                	beqz	a5,ffffffffc020592a <cpu_idle+0x10>
        {
            schedule();
ffffffffc020592e:	27a000ef          	jal	ffffffffc0205ba8 <schedule>
ffffffffc0205932:	bfdd                	j	ffffffffc0205928 <cpu_idle+0xe>

ffffffffc0205934 <lab6_set_priority>:
        }
    }
}
// FOR LAB6, set the process's priority (bigger value will get more CPU time)
void lab6_set_priority(uint32_t priority)
{
ffffffffc0205934:	1101                	addi	sp,sp,-32
ffffffffc0205936:	85aa                	mv	a1,a0
    cprintf("set priority to %d\n", priority);
ffffffffc0205938:	e42a                	sd	a0,8(sp)
ffffffffc020593a:	00003517          	auipc	a0,0x3
ffffffffc020593e:	b9650513          	addi	a0,a0,-1130 # ffffffffc02084d0 <etext+0x202e>
{
ffffffffc0205942:	ec06                	sd	ra,24(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc0205944:	855fa0ef          	jal	ffffffffc0200198 <cprintf>
    if (priority == 0)
ffffffffc0205948:	65a2                	ld	a1,8(sp)
        current->lab6_priority = 1;
ffffffffc020594a:	000c7717          	auipc	a4,0xc7
ffffffffc020594e:	a0673703          	ld	a4,-1530(a4) # ffffffffc02cc350 <current>
    if (priority == 0)
ffffffffc0205952:	4785                	li	a5,1
ffffffffc0205954:	c191                	beqz	a1,ffffffffc0205958 <lab6_set_priority+0x24>
ffffffffc0205956:	87ae                	mv	a5,a1
    else
        current->lab6_priority = priority;
}
ffffffffc0205958:	60e2                	ld	ra,24(sp)
        current->lab6_priority = 1;
ffffffffc020595a:	14f72223          	sw	a5,324(a4)
}
ffffffffc020595e:	6105                	addi	sp,sp,32
ffffffffc0205960:	8082                	ret

ffffffffc0205962 <do_sleep>:
// do_sleep - set current process state to sleep and add timer with "time"
//          - then call scheduler. if process run again, delete timer first.
int do_sleep(unsigned int time)
{
    if (time == 0)
ffffffffc0205962:	c531                	beqz	a0,ffffffffc02059ae <do_sleep+0x4c>
{
ffffffffc0205964:	7139                	addi	sp,sp,-64
ffffffffc0205966:	fc06                	sd	ra,56(sp)
ffffffffc0205968:	f822                	sd	s0,48(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020596a:	100027f3          	csrr	a5,sstatus
ffffffffc020596e:	8b89                	andi	a5,a5,2
ffffffffc0205970:	e3a9                	bnez	a5,ffffffffc02059b2 <do_sleep+0x50>
    {
        return 0;
    }
    bool intr_flag;
    local_intr_save(intr_flag);
    timer_t __timer, *timer = timer_init(&__timer, current, time);
ffffffffc0205972:	000c7797          	auipc	a5,0xc7
ffffffffc0205976:	9de7b783          	ld	a5,-1570(a5) # ffffffffc02cc350 <current>
    elm->prev = elm->next = elm;
ffffffffc020597a:	1014                	addi	a3,sp,32
    current->state = PROC_SLEEPING;
    current->wait_state = WT_TIMER;
ffffffffc020597c:	80000737          	lui	a4,0x80000
to_struct((le), timer_t, member)

// init a timer
static inline timer_t *
timer_init(timer_t *timer, struct proc_struct *proc, int expires) {
    timer->expires = expires;
ffffffffc0205980:	c82a                	sw	a0,16(sp)
ffffffffc0205982:	f436                	sd	a3,40(sp)
ffffffffc0205984:	f036                	sd	a3,32(sp)
    timer->proc = proc;
ffffffffc0205986:	ec3e                	sd	a5,24(sp)
    current->state = PROC_SLEEPING;
ffffffffc0205988:	4685                	li	a3,1
    current->wait_state = WT_TIMER;
ffffffffc020598a:	0709                	addi	a4,a4,2 # ffffffff80000002 <_binary_obj___user_matrix_out_size+0xffffffff7fff491a>
ffffffffc020598c:	0808                	addi	a0,sp,16
    current->state = PROC_SLEEPING;
ffffffffc020598e:	c394                	sw	a3,0(a5)
    current->wait_state = WT_TIMER;
ffffffffc0205990:	0ee7a623          	sw	a4,236(a5)
ffffffffc0205994:	842a                	mv	s0,a0
    add_timer(timer);
ffffffffc0205996:	2c8000ef          	jal	ffffffffc0205c5e <add_timer>
    local_intr_restore(intr_flag);

    schedule();
ffffffffc020599a:	20e000ef          	jal	ffffffffc0205ba8 <schedule>

    del_timer(timer);
ffffffffc020599e:	8522                	mv	a0,s0
ffffffffc02059a0:	384000ef          	jal	ffffffffc0205d24 <del_timer>
    return 0;
}
ffffffffc02059a4:	70e2                	ld	ra,56(sp)
ffffffffc02059a6:	7442                	ld	s0,48(sp)
ffffffffc02059a8:	4501                	li	a0,0
ffffffffc02059aa:	6121                	addi	sp,sp,64
ffffffffc02059ac:	8082                	ret
ffffffffc02059ae:	4501                	li	a0,0
ffffffffc02059b0:	8082                	ret
        intr_disable();
ffffffffc02059b2:	e42a                	sd	a0,8(sp)
ffffffffc02059b4:	f4bfa0ef          	jal	ffffffffc02008fe <intr_disable>
    timer_t __timer, *timer = timer_init(&__timer, current, time);
ffffffffc02059b8:	000c7797          	auipc	a5,0xc7
ffffffffc02059bc:	9987b783          	ld	a5,-1640(a5) # ffffffffc02cc350 <current>
    timer->expires = expires;
ffffffffc02059c0:	6522                	ld	a0,8(sp)
ffffffffc02059c2:	1014                	addi	a3,sp,32
    current->wait_state = WT_TIMER;
ffffffffc02059c4:	80000737          	lui	a4,0x80000
ffffffffc02059c8:	c82a                	sw	a0,16(sp)
ffffffffc02059ca:	f436                	sd	a3,40(sp)
ffffffffc02059cc:	f036                	sd	a3,32(sp)
    timer->proc = proc;
ffffffffc02059ce:	ec3e                	sd	a5,24(sp)
    current->state = PROC_SLEEPING;
ffffffffc02059d0:	4685                	li	a3,1
    current->wait_state = WT_TIMER;
ffffffffc02059d2:	0709                	addi	a4,a4,2 # ffffffff80000002 <_binary_obj___user_matrix_out_size+0xffffffff7fff491a>
ffffffffc02059d4:	0808                	addi	a0,sp,16
    current->state = PROC_SLEEPING;
ffffffffc02059d6:	c394                	sw	a3,0(a5)
    current->wait_state = WT_TIMER;
ffffffffc02059d8:	0ee7a623          	sw	a4,236(a5)
ffffffffc02059dc:	842a                	mv	s0,a0
    add_timer(timer);
ffffffffc02059de:	280000ef          	jal	ffffffffc0205c5e <add_timer>
        intr_enable();
ffffffffc02059e2:	f17fa0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc02059e6:	bf55                	j	ffffffffc020599a <do_sleep+0x38>

ffffffffc02059e8 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc02059e8:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc02059ec:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc02059f0:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc02059f2:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc02059f4:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc02059f8:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc02059fc:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0205a00:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0205a04:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0205a08:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0205a0c:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0205a10:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0205a14:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0205a18:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0205a1c:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0205a20:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0205a24:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0205a26:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0205a28:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0205a2c:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0205a30:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0205a34:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0205a38:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0205a3c:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0205a40:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0205a44:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0205a48:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0205a4c:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0205a50:	8082                	ret

ffffffffc0205a52 <RR_init>:
 */
static void
RR_init(struct run_queue *rq)
{
    // LAB6: 填写你在lab6中实现的代码
}
ffffffffc0205a52:	8082                	ret

ffffffffc0205a54 <RR_enqueue>:
 */
static void
RR_enqueue(struct run_queue *rq, struct proc_struct *proc)
{
    // LAB6: 填写你在lab6中实现的代码
}
ffffffffc0205a54:	8082                	ret

ffffffffc0205a56 <RR_pick_next>:
 */
static struct proc_struct *
RR_pick_next(struct run_queue *rq)
{
    // LAB6: 填写你在lab6中实现的代码
}
ffffffffc0205a56:	8082                	ret

ffffffffc0205a58 <RR_proc_tick>:
 * exhausted and update the proc struct ``proc''. proc->time_slice
 * denotes the time slices left for current process. proc->need_resched
 * is the flag variable for process switching.
 */
static void
RR_proc_tick(struct run_queue *rq, struct proc_struct *proc)
ffffffffc0205a58:	8082                	ret

ffffffffc0205a5a <RR_dequeue>:
RR_dequeue(struct run_queue *rq, struct proc_struct *proc)
ffffffffc0205a5a:	8082                	ret

ffffffffc0205a5c <sched_init>:

void
sched_init(void) {
    list_init(&timer_list);

    sched_class = &default_sched_class;
ffffffffc0205a5c:	000c2797          	auipc	a5,0xc2
ffffffffc0205a60:	2a478793          	addi	a5,a5,676 # ffffffffc02c7d00 <default_sched_class>
sched_init(void) {
ffffffffc0205a64:	1141                	addi	sp,sp,-16

    rq = &__rq;
    rq->max_time_slice = MAX_TIME_SLICE;
    sched_class->init(rq);
ffffffffc0205a66:	6794                	ld	a3,8(a5)
    sched_class = &default_sched_class;
ffffffffc0205a68:	000c7717          	auipc	a4,0xc7
ffffffffc0205a6c:	90f73423          	sd	a5,-1784(a4) # ffffffffc02cc370 <sched_class>
sched_init(void) {
ffffffffc0205a70:	e406                	sd	ra,8(sp)
ffffffffc0205a72:	000c7797          	auipc	a5,0xc7
ffffffffc0205a76:	86e78793          	addi	a5,a5,-1938 # ffffffffc02cc2e0 <timer_list>
    rq = &__rq;
ffffffffc0205a7a:	000c7717          	auipc	a4,0xc7
ffffffffc0205a7e:	84670713          	addi	a4,a4,-1978 # ffffffffc02cc2c0 <__rq>
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc0205a82:	4615                	li	a2,5
ffffffffc0205a84:	e79c                	sd	a5,8(a5)
ffffffffc0205a86:	e39c                	sd	a5,0(a5)
    sched_class->init(rq);
ffffffffc0205a88:	853a                	mv	a0,a4
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc0205a8a:	cb50                	sw	a2,20(a4)
    rq = &__rq;
ffffffffc0205a8c:	000c7797          	auipc	a5,0xc7
ffffffffc0205a90:	8ce7be23          	sd	a4,-1828(a5) # ffffffffc02cc368 <rq>
    sched_class->init(rq);
ffffffffc0205a94:	9682                	jalr	a3

    cprintf("sched class: %s\n", sched_class->name);
ffffffffc0205a96:	000c7797          	auipc	a5,0xc7
ffffffffc0205a9a:	8da7b783          	ld	a5,-1830(a5) # ffffffffc02cc370 <sched_class>
}
ffffffffc0205a9e:	60a2                	ld	ra,8(sp)
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc0205aa0:	00003517          	auipc	a0,0x3
ffffffffc0205aa4:	a5850513          	addi	a0,a0,-1448 # ffffffffc02084f8 <etext+0x2056>
ffffffffc0205aa8:	638c                	ld	a1,0(a5)
}
ffffffffc0205aaa:	0141                	addi	sp,sp,16
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc0205aac:	eecfa06f          	j	ffffffffc0200198 <cprintf>

ffffffffc0205ab0 <wakeup_proc>:

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205ab0:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205ab2:	1101                	addi	sp,sp,-32
ffffffffc0205ab4:	ec06                	sd	ra,24(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205ab6:	478d                	li	a5,3
ffffffffc0205ab8:	0cf70863          	beq	a4,a5,ffffffffc0205b88 <wakeup_proc+0xd8>
ffffffffc0205abc:	85aa                	mv	a1,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205abe:	100027f3          	csrr	a5,sstatus
ffffffffc0205ac2:	8b89                	andi	a5,a5,2
ffffffffc0205ac4:	e3b1                	bnez	a5,ffffffffc0205b08 <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205ac6:	4789                	li	a5,2
ffffffffc0205ac8:	08f70563          	beq	a4,a5,ffffffffc0205b52 <wakeup_proc+0xa2>
            proc->state = PROC_RUNNABLE;
            proc->wait_state = 0;
            if (proc != current) {
ffffffffc0205acc:	000c7717          	auipc	a4,0xc7
ffffffffc0205ad0:	88473703          	ld	a4,-1916(a4) # ffffffffc02cc350 <current>
            proc->wait_state = 0;
ffffffffc0205ad4:	0e052623          	sw	zero,236(a0)
            proc->state = PROC_RUNNABLE;
ffffffffc0205ad8:	c11c                	sw	a5,0(a0)
            if (proc != current) {
ffffffffc0205ada:	02e50463          	beq	a0,a4,ffffffffc0205b02 <wakeup_proc+0x52>
    if (proc != idleproc) {
ffffffffc0205ade:	000c7797          	auipc	a5,0xc7
ffffffffc0205ae2:	8827b783          	ld	a5,-1918(a5) # ffffffffc02cc360 <idleproc>
ffffffffc0205ae6:	00f50e63          	beq	a0,a5,ffffffffc0205b02 <wakeup_proc+0x52>
        sched_class->enqueue(rq, proc);
ffffffffc0205aea:	000c7797          	auipc	a5,0xc7
ffffffffc0205aee:	8867b783          	ld	a5,-1914(a5) # ffffffffc02cc370 <sched_class>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205af2:	60e2                	ld	ra,24(sp)
        sched_class->enqueue(rq, proc);
ffffffffc0205af4:	000c7517          	auipc	a0,0xc7
ffffffffc0205af8:	87453503          	ld	a0,-1932(a0) # ffffffffc02cc368 <rq>
ffffffffc0205afc:	6b9c                	ld	a5,16(a5)
}
ffffffffc0205afe:	6105                	addi	sp,sp,32
        sched_class->enqueue(rq, proc);
ffffffffc0205b00:	8782                	jr	a5
}
ffffffffc0205b02:	60e2                	ld	ra,24(sp)
ffffffffc0205b04:	6105                	addi	sp,sp,32
ffffffffc0205b06:	8082                	ret
        intr_disable();
ffffffffc0205b08:	e42a                	sd	a0,8(sp)
ffffffffc0205b0a:	df5fa0ef          	jal	ffffffffc02008fe <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205b0e:	65a2                	ld	a1,8(sp)
ffffffffc0205b10:	4789                	li	a5,2
ffffffffc0205b12:	4198                	lw	a4,0(a1)
ffffffffc0205b14:	04f70d63          	beq	a4,a5,ffffffffc0205b6e <wakeup_proc+0xbe>
            if (proc != current) {
ffffffffc0205b18:	000c7717          	auipc	a4,0xc7
ffffffffc0205b1c:	83873703          	ld	a4,-1992(a4) # ffffffffc02cc350 <current>
            proc->wait_state = 0;
ffffffffc0205b20:	0e05a623          	sw	zero,236(a1)
            proc->state = PROC_RUNNABLE;
ffffffffc0205b24:	c19c                	sw	a5,0(a1)
            if (proc != current) {
ffffffffc0205b26:	02e58263          	beq	a1,a4,ffffffffc0205b4a <wakeup_proc+0x9a>
    if (proc != idleproc) {
ffffffffc0205b2a:	000c7797          	auipc	a5,0xc7
ffffffffc0205b2e:	8367b783          	ld	a5,-1994(a5) # ffffffffc02cc360 <idleproc>
ffffffffc0205b32:	00f58c63          	beq	a1,a5,ffffffffc0205b4a <wakeup_proc+0x9a>
        sched_class->enqueue(rq, proc);
ffffffffc0205b36:	000c7797          	auipc	a5,0xc7
ffffffffc0205b3a:	83a7b783          	ld	a5,-1990(a5) # ffffffffc02cc370 <sched_class>
ffffffffc0205b3e:	000c7517          	auipc	a0,0xc7
ffffffffc0205b42:	82a53503          	ld	a0,-2006(a0) # ffffffffc02cc368 <rq>
ffffffffc0205b46:	6b9c                	ld	a5,16(a5)
ffffffffc0205b48:	9782                	jalr	a5
}
ffffffffc0205b4a:	60e2                	ld	ra,24(sp)
ffffffffc0205b4c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205b4e:	dabfa06f          	j	ffffffffc02008f8 <intr_enable>
ffffffffc0205b52:	60e2                	ld	ra,24(sp)
            warn("wakeup runnable process.\n");
ffffffffc0205b54:	00003617          	auipc	a2,0x3
ffffffffc0205b58:	9f460613          	addi	a2,a2,-1548 # ffffffffc0208548 <etext+0x20a6>
ffffffffc0205b5c:	04800593          	li	a1,72
ffffffffc0205b60:	00003517          	auipc	a0,0x3
ffffffffc0205b64:	9d050513          	addi	a0,a0,-1584 # ffffffffc0208530 <etext+0x208e>
}
ffffffffc0205b68:	6105                	addi	sp,sp,32
            warn("wakeup runnable process.\n");
ffffffffc0205b6a:	94bfa06f          	j	ffffffffc02004b4 <__warn>
ffffffffc0205b6e:	00003617          	auipc	a2,0x3
ffffffffc0205b72:	9da60613          	addi	a2,a2,-1574 # ffffffffc0208548 <etext+0x20a6>
ffffffffc0205b76:	04800593          	li	a1,72
ffffffffc0205b7a:	00003517          	auipc	a0,0x3
ffffffffc0205b7e:	9b650513          	addi	a0,a0,-1610 # ffffffffc0208530 <etext+0x208e>
ffffffffc0205b82:	933fa0ef          	jal	ffffffffc02004b4 <__warn>
    if (flag) {
ffffffffc0205b86:	b7d1                	j	ffffffffc0205b4a <wakeup_proc+0x9a>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205b88:	00003697          	auipc	a3,0x3
ffffffffc0205b8c:	98868693          	addi	a3,a3,-1656 # ffffffffc0208510 <etext+0x206e>
ffffffffc0205b90:	00001617          	auipc	a2,0x1
ffffffffc0205b94:	2e860613          	addi	a2,a2,744 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0205b98:	03c00593          	li	a1,60
ffffffffc0205b9c:	00003517          	auipc	a0,0x3
ffffffffc0205ba0:	99450513          	addi	a0,a0,-1644 # ffffffffc0208530 <etext+0x208e>
ffffffffc0205ba4:	8a7fa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0205ba8 <schedule>:

void
schedule(void) {
ffffffffc0205ba8:	7139                	addi	sp,sp,-64
ffffffffc0205baa:	fc06                	sd	ra,56(sp)
ffffffffc0205bac:	f822                	sd	s0,48(sp)
ffffffffc0205bae:	f426                	sd	s1,40(sp)
ffffffffc0205bb0:	f04a                	sd	s2,32(sp)
ffffffffc0205bb2:	ec4e                	sd	s3,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205bb4:	100027f3          	csrr	a5,sstatus
ffffffffc0205bb8:	8b89                	andi	a5,a5,2
ffffffffc0205bba:	4981                	li	s3,0
ffffffffc0205bbc:	efc9                	bnez	a5,ffffffffc0205c56 <schedule+0xae>
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205bbe:	000c6417          	auipc	s0,0xc6
ffffffffc0205bc2:	79240413          	addi	s0,s0,1938 # ffffffffc02cc350 <current>
ffffffffc0205bc6:	600c                	ld	a1,0(s0)
        if (current->state == PROC_RUNNABLE) {
ffffffffc0205bc8:	4789                	li	a5,2
ffffffffc0205bca:	000c6497          	auipc	s1,0xc6
ffffffffc0205bce:	79e48493          	addi	s1,s1,1950 # ffffffffc02cc368 <rq>
ffffffffc0205bd2:	4198                	lw	a4,0(a1)
        current->need_resched = 0;
ffffffffc0205bd4:	0005bc23          	sd	zero,24(a1)
        if (current->state == PROC_RUNNABLE) {
ffffffffc0205bd8:	000c6917          	auipc	s2,0xc6
ffffffffc0205bdc:	79890913          	addi	s2,s2,1944 # ffffffffc02cc370 <sched_class>
ffffffffc0205be0:	04f70f63          	beq	a4,a5,ffffffffc0205c3e <schedule+0x96>
    return sched_class->pick_next(rq);
ffffffffc0205be4:	00093783          	ld	a5,0(s2)
ffffffffc0205be8:	6088                	ld	a0,0(s1)
ffffffffc0205bea:	739c                	ld	a5,32(a5)
ffffffffc0205bec:	9782                	jalr	a5
ffffffffc0205bee:	85aa                	mv	a1,a0
            sched_class_enqueue(current);
        }
        if ((next = sched_class_pick_next()) != NULL) {
ffffffffc0205bf0:	c131                	beqz	a0,ffffffffc0205c34 <schedule+0x8c>
    sched_class->dequeue(rq, proc);
ffffffffc0205bf2:	00093783          	ld	a5,0(s2)
ffffffffc0205bf6:	6088                	ld	a0,0(s1)
ffffffffc0205bf8:	e42e                	sd	a1,8(sp)
ffffffffc0205bfa:	6f9c                	ld	a5,24(a5)
ffffffffc0205bfc:	9782                	jalr	a5
ffffffffc0205bfe:	65a2                	ld	a1,8(sp)
            sched_class_dequeue(next);
        }
        if (next == NULL) {
            next = idleproc;
        }
        next->runs ++;
ffffffffc0205c00:	459c                	lw	a5,8(a1)
        if (next != current) {
ffffffffc0205c02:	6018                	ld	a4,0(s0)
        next->runs ++;
ffffffffc0205c04:	2785                	addiw	a5,a5,1
ffffffffc0205c06:	c59c                	sw	a5,8(a1)
        if (next != current) {
ffffffffc0205c08:	00b70563          	beq	a4,a1,ffffffffc0205c12 <schedule+0x6a>
            proc_run(next);
ffffffffc0205c0c:	852e                	mv	a0,a1
ffffffffc0205c0e:	af7fe0ef          	jal	ffffffffc0204704 <proc_run>
    if (flag) {
ffffffffc0205c12:	00099963          	bnez	s3,ffffffffc0205c24 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205c16:	70e2                	ld	ra,56(sp)
ffffffffc0205c18:	7442                	ld	s0,48(sp)
ffffffffc0205c1a:	74a2                	ld	s1,40(sp)
ffffffffc0205c1c:	7902                	ld	s2,32(sp)
ffffffffc0205c1e:	69e2                	ld	s3,24(sp)
ffffffffc0205c20:	6121                	addi	sp,sp,64
ffffffffc0205c22:	8082                	ret
ffffffffc0205c24:	7442                	ld	s0,48(sp)
ffffffffc0205c26:	70e2                	ld	ra,56(sp)
ffffffffc0205c28:	74a2                	ld	s1,40(sp)
ffffffffc0205c2a:	7902                	ld	s2,32(sp)
ffffffffc0205c2c:	69e2                	ld	s3,24(sp)
ffffffffc0205c2e:	6121                	addi	sp,sp,64
        intr_enable();
ffffffffc0205c30:	cc9fa06f          	j	ffffffffc02008f8 <intr_enable>
            next = idleproc;
ffffffffc0205c34:	000c6597          	auipc	a1,0xc6
ffffffffc0205c38:	72c5b583          	ld	a1,1836(a1) # ffffffffc02cc360 <idleproc>
ffffffffc0205c3c:	b7d1                	j	ffffffffc0205c00 <schedule+0x58>
    if (proc != idleproc) {
ffffffffc0205c3e:	000c6797          	auipc	a5,0xc6
ffffffffc0205c42:	7227b783          	ld	a5,1826(a5) # ffffffffc02cc360 <idleproc>
ffffffffc0205c46:	f8f58fe3          	beq	a1,a5,ffffffffc0205be4 <schedule+0x3c>
        sched_class->enqueue(rq, proc);
ffffffffc0205c4a:	00093783          	ld	a5,0(s2)
ffffffffc0205c4e:	6088                	ld	a0,0(s1)
ffffffffc0205c50:	6b9c                	ld	a5,16(a5)
ffffffffc0205c52:	9782                	jalr	a5
ffffffffc0205c54:	bf41                	j	ffffffffc0205be4 <schedule+0x3c>
        intr_disable();
ffffffffc0205c56:	ca9fa0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc0205c5a:	4985                	li	s3,1
ffffffffc0205c5c:	b78d                	j	ffffffffc0205bbe <schedule+0x16>

ffffffffc0205c5e <add_timer>:

// add timer to timer_list
void
add_timer(timer_t *timer) {
ffffffffc0205c5e:	1101                	addi	sp,sp,-32
ffffffffc0205c60:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205c62:	100027f3          	csrr	a5,sstatus
ffffffffc0205c66:	8b89                	andi	a5,a5,2
ffffffffc0205c68:	4801                	li	a6,0
ffffffffc0205c6a:	e7bd                	bnez	a5,ffffffffc0205cd8 <add_timer+0x7a>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        assert(timer->expires > 0 && timer->proc != NULL);
ffffffffc0205c6c:	4118                	lw	a4,0(a0)
ffffffffc0205c6e:	cb3d                	beqz	a4,ffffffffc0205ce4 <add_timer+0x86>
ffffffffc0205c70:	651c                	ld	a5,8(a0)
ffffffffc0205c72:	cbad                	beqz	a5,ffffffffc0205ce4 <add_timer+0x86>
        assert(list_empty(&(timer->timer_link)));
ffffffffc0205c74:	6d1c                	ld	a5,24(a0)
ffffffffc0205c76:	01050593          	addi	a1,a0,16
ffffffffc0205c7a:	08f59563          	bne	a1,a5,ffffffffc0205d04 <add_timer+0xa6>
    return listelm->next;
ffffffffc0205c7e:	000c6617          	auipc	a2,0xc6
ffffffffc0205c82:	66260613          	addi	a2,a2,1634 # ffffffffc02cc2e0 <timer_list>
ffffffffc0205c86:	661c                	ld	a5,8(a2)
        list_entry_t *le = list_next(&timer_list);
        while (le != &timer_list) {
ffffffffc0205c88:	00c79863          	bne	a5,a2,ffffffffc0205c98 <add_timer+0x3a>
ffffffffc0205c8c:	a805                	j	ffffffffc0205cbc <add_timer+0x5e>
ffffffffc0205c8e:	679c                	ld	a5,8(a5)
            timer_t *next = le2timer(le, timer_link);
            if (timer->expires < next->expires) {
                next->expires -= timer->expires;
                break;
            }
            timer->expires -= next->expires;
ffffffffc0205c90:	9f15                	subw	a4,a4,a3
ffffffffc0205c92:	c118                	sw	a4,0(a0)
        while (le != &timer_list) {
ffffffffc0205c94:	02c78463          	beq	a5,a2,ffffffffc0205cbc <add_timer+0x5e>
            if (timer->expires < next->expires) {
ffffffffc0205c98:	ff07a683          	lw	a3,-16(a5)
ffffffffc0205c9c:	fed779e3          	bgeu	a4,a3,ffffffffc0205c8e <add_timer+0x30>
                next->expires -= timer->expires;
ffffffffc0205ca0:	9e99                	subw	a3,a3,a4
    __list_add(elm, listelm->prev, listelm);
ffffffffc0205ca2:	6398                	ld	a4,0(a5)
ffffffffc0205ca4:	fed7a823          	sw	a3,-16(a5)
    prev->next = next->prev = elm;
ffffffffc0205ca8:	e38c                	sd	a1,0(a5)
ffffffffc0205caa:	e70c                	sd	a1,8(a4)
    elm->prev = prev;
ffffffffc0205cac:	e918                	sd	a4,16(a0)
    elm->next = next;
ffffffffc0205cae:	ed1c                	sd	a5,24(a0)
    if (flag) {
ffffffffc0205cb0:	02080163          	beqz	a6,ffffffffc0205cd2 <add_timer+0x74>
            le = list_next(le);
        }
        list_add_before(le, &(timer->timer_link));
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205cb4:	60e2                	ld	ra,24(sp)
ffffffffc0205cb6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205cb8:	c41fa06f          	j	ffffffffc02008f8 <intr_enable>
        list_entry_t *le = list_next(&timer_list);
ffffffffc0205cbc:	000c6797          	auipc	a5,0xc6
ffffffffc0205cc0:	62478793          	addi	a5,a5,1572 # ffffffffc02cc2e0 <timer_list>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0205cc4:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0205cc6:	e38c                	sd	a1,0(a5)
ffffffffc0205cc8:	e70c                	sd	a1,8(a4)
    elm->prev = prev;
ffffffffc0205cca:	e918                	sd	a4,16(a0)
    elm->next = next;
ffffffffc0205ccc:	ed1c                	sd	a5,24(a0)
    if (flag) {
ffffffffc0205cce:	fe0813e3          	bnez	a6,ffffffffc0205cb4 <add_timer+0x56>
}
ffffffffc0205cd2:	60e2                	ld	ra,24(sp)
ffffffffc0205cd4:	6105                	addi	sp,sp,32
ffffffffc0205cd6:	8082                	ret
ffffffffc0205cd8:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0205cda:	c25fa0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc0205cde:	6522                	ld	a0,8(sp)
ffffffffc0205ce0:	4805                	li	a6,1
ffffffffc0205ce2:	b769                	j	ffffffffc0205c6c <add_timer+0xe>
        assert(timer->expires > 0 && timer->proc != NULL);
ffffffffc0205ce4:	00003697          	auipc	a3,0x3
ffffffffc0205ce8:	88468693          	addi	a3,a3,-1916 # ffffffffc0208568 <etext+0x20c6>
ffffffffc0205cec:	00001617          	auipc	a2,0x1
ffffffffc0205cf0:	18c60613          	addi	a2,a2,396 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0205cf4:	06c00593          	li	a1,108
ffffffffc0205cf8:	00003517          	auipc	a0,0x3
ffffffffc0205cfc:	83850513          	addi	a0,a0,-1992 # ffffffffc0208530 <etext+0x208e>
ffffffffc0205d00:	f4afa0ef          	jal	ffffffffc020044a <__panic>
        assert(list_empty(&(timer->timer_link)));
ffffffffc0205d04:	00003697          	auipc	a3,0x3
ffffffffc0205d08:	89468693          	addi	a3,a3,-1900 # ffffffffc0208598 <etext+0x20f6>
ffffffffc0205d0c:	00001617          	auipc	a2,0x1
ffffffffc0205d10:	16c60613          	addi	a2,a2,364 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0205d14:	06d00593          	li	a1,109
ffffffffc0205d18:	00003517          	auipc	a0,0x3
ffffffffc0205d1c:	81850513          	addi	a0,a0,-2024 # ffffffffc0208530 <etext+0x208e>
ffffffffc0205d20:	f2afa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0205d24 <del_timer>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205d24:	100027f3          	csrr	a5,sstatus
ffffffffc0205d28:	8b89                	andi	a5,a5,2
ffffffffc0205d2a:	ef95                	bnez	a5,ffffffffc0205d66 <del_timer+0x42>
    return list->next == list;
ffffffffc0205d2c:	6d1c                	ld	a5,24(a0)
void
del_timer(timer_t *timer) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (!list_empty(&(timer->timer_link))) {
ffffffffc0205d2e:	01050713          	addi	a4,a0,16
    return 0;
ffffffffc0205d32:	4601                	li	a2,0
ffffffffc0205d34:	02f70863          	beq	a4,a5,ffffffffc0205d64 <del_timer+0x40>
            if (timer->expires != 0) {
                list_entry_t *le = list_next(&(timer->timer_link));
                if (le != &timer_list) {
ffffffffc0205d38:	000c6597          	auipc	a1,0xc6
ffffffffc0205d3c:	5a858593          	addi	a1,a1,1448 # ffffffffc02cc2e0 <timer_list>
            if (timer->expires != 0) {
ffffffffc0205d40:	4114                	lw	a3,0(a0)
                if (le != &timer_list) {
ffffffffc0205d42:	00b78863          	beq	a5,a1,ffffffffc0205d52 <del_timer+0x2e>
ffffffffc0205d46:	c691                	beqz	a3,ffffffffc0205d52 <del_timer+0x2e>
                    timer_t *next = le2timer(le, timer_link);
                    next->expires += timer->expires;
ffffffffc0205d48:	ff07a583          	lw	a1,-16(a5)
ffffffffc0205d4c:	9ead                	addw	a3,a3,a1
ffffffffc0205d4e:	fed7a823          	sw	a3,-16(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205d52:	6914                	ld	a3,16(a0)
    prev->next = next;
ffffffffc0205d54:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0205d56:	e394                	sd	a3,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0205d58:	ed18                	sd	a4,24(a0)
ffffffffc0205d5a:	e918                	sd	a4,16(a0)
    if (flag) {
ffffffffc0205d5c:	e211                	bnez	a2,ffffffffc0205d60 <del_timer+0x3c>
ffffffffc0205d5e:	8082                	ret
        intr_enable();
ffffffffc0205d60:	b99fa06f          	j	ffffffffc02008f8 <intr_enable>
ffffffffc0205d64:	8082                	ret
del_timer(timer_t *timer) {
ffffffffc0205d66:	1101                	addi	sp,sp,-32
ffffffffc0205d68:	e42a                	sd	a0,8(sp)
ffffffffc0205d6a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0205d6c:	b93fa0ef          	jal	ffffffffc02008fe <intr_disable>
    return list->next == list;
ffffffffc0205d70:	6522                	ld	a0,8(sp)
        return 1;
ffffffffc0205d72:	4605                	li	a2,1
ffffffffc0205d74:	6d1c                	ld	a5,24(a0)
        if (!list_empty(&(timer->timer_link))) {
ffffffffc0205d76:	01050713          	addi	a4,a0,16
ffffffffc0205d7a:	02f70863          	beq	a4,a5,ffffffffc0205daa <del_timer+0x86>
                if (le != &timer_list) {
ffffffffc0205d7e:	000c6597          	auipc	a1,0xc6
ffffffffc0205d82:	56258593          	addi	a1,a1,1378 # ffffffffc02cc2e0 <timer_list>
            if (timer->expires != 0) {
ffffffffc0205d86:	4114                	lw	a3,0(a0)
                if (le != &timer_list) {
ffffffffc0205d88:	00b78863          	beq	a5,a1,ffffffffc0205d98 <del_timer+0x74>
ffffffffc0205d8c:	c691                	beqz	a3,ffffffffc0205d98 <del_timer+0x74>
                    next->expires += timer->expires;
ffffffffc0205d8e:	ff07a583          	lw	a1,-16(a5)
ffffffffc0205d92:	9ead                	addw	a3,a3,a1
ffffffffc0205d94:	fed7a823          	sw	a3,-16(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0205d98:	6914                	ld	a3,16(a0)
    prev->next = next;
ffffffffc0205d9a:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0205d9c:	e394                	sd	a3,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0205d9e:	ed18                	sd	a4,24(a0)
ffffffffc0205da0:	e918                	sd	a4,16(a0)
    if (flag) {
ffffffffc0205da2:	e601                	bnez	a2,ffffffffc0205daa <del_timer+0x86>
            }
            list_del_init(&(timer->timer_link));
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205da4:	60e2                	ld	ra,24(sp)
ffffffffc0205da6:	6105                	addi	sp,sp,32
ffffffffc0205da8:	8082                	ret
ffffffffc0205daa:	60e2                	ld	ra,24(sp)
ffffffffc0205dac:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205dae:	b4bfa06f          	j	ffffffffc02008f8 <intr_enable>

ffffffffc0205db2 <run_timer_list>:

// call scheduler to update tick related info, and check the timer is expired? If expired, then wakup proc
void
run_timer_list(void) {
ffffffffc0205db2:	7179                	addi	sp,sp,-48
ffffffffc0205db4:	f406                	sd	ra,40(sp)
ffffffffc0205db6:	f022                	sd	s0,32(sp)
ffffffffc0205db8:	e44e                	sd	s3,8(sp)
ffffffffc0205dba:	e052                	sd	s4,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205dbc:	100027f3          	csrr	a5,sstatus
ffffffffc0205dc0:	8b89                	andi	a5,a5,2
ffffffffc0205dc2:	4a01                	li	s4,0
ffffffffc0205dc4:	ebe1                	bnez	a5,ffffffffc0205e94 <run_timer_list+0xe2>
    return listelm->next;
ffffffffc0205dc6:	000c6997          	auipc	s3,0xc6
ffffffffc0205dca:	51a98993          	addi	s3,s3,1306 # ffffffffc02cc2e0 <timer_list>
ffffffffc0205dce:	0089b403          	ld	s0,8(s3)
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        list_entry_t *le = list_next(&timer_list);
        if (le != &timer_list) {
ffffffffc0205dd2:	07340b63          	beq	s0,s3,ffffffffc0205e48 <run_timer_list+0x96>
            timer_t *timer = le2timer(le, timer_link);
            assert(timer->expires != 0);
ffffffffc0205dd6:	ff042783          	lw	a5,-16(s0)
ffffffffc0205dda:	0e078163          	beqz	a5,ffffffffc0205ebc <run_timer_list+0x10a>
            timer->expires --;
ffffffffc0205dde:	37fd                	addiw	a5,a5,-1
ffffffffc0205de0:	fef42823          	sw	a5,-16(s0)
            while (timer->expires == 0) {
ffffffffc0205de4:	e3b5                	bnez	a5,ffffffffc0205e48 <run_timer_list+0x96>
ffffffffc0205de6:	e84a                	sd	s2,16(sp)
ffffffffc0205de8:	ec26                	sd	s1,24(sp)
            timer_t *timer = le2timer(le, timer_link);
ffffffffc0205dea:	ff040913          	addi	s2,s0,-16
ffffffffc0205dee:	a005                	j	ffffffffc0205e0e <run_timer_list+0x5c>
                le = list_next(le);
                struct proc_struct *proc = timer->proc;
                if (proc->wait_state != 0) {
                    assert(proc->wait_state & WT_INTERRUPTED);
ffffffffc0205df0:	0a07d663          	bgez	a5,ffffffffc0205e9c <run_timer_list+0xea>
                }
                else {
                    warn("process %d's wait_state == 0.\n", proc->pid);
                }
                wakeup_proc(proc);
ffffffffc0205df4:	8526                	mv	a0,s1
ffffffffc0205df6:	cbbff0ef          	jal	ffffffffc0205ab0 <wakeup_proc>
                del_timer(timer);
ffffffffc0205dfa:	854a                	mv	a0,s2
ffffffffc0205dfc:	f29ff0ef          	jal	ffffffffc0205d24 <del_timer>
                if (le == &timer_list) {
ffffffffc0205e00:	05340263          	beq	s0,s3,ffffffffc0205e44 <run_timer_list+0x92>
            while (timer->expires == 0) {
ffffffffc0205e04:	ff042783          	lw	a5,-16(s0)
                    break;
                }
                timer = le2timer(le, timer_link);
ffffffffc0205e08:	ff040913          	addi	s2,s0,-16
            while (timer->expires == 0) {
ffffffffc0205e0c:	ef85                	bnez	a5,ffffffffc0205e44 <run_timer_list+0x92>
                struct proc_struct *proc = timer->proc;
ffffffffc0205e0e:	00893483          	ld	s1,8(s2)
ffffffffc0205e12:	6400                	ld	s0,8(s0)
                if (proc->wait_state != 0) {
ffffffffc0205e14:	0ec4a783          	lw	a5,236(s1)
ffffffffc0205e18:	ffe1                	bnez	a5,ffffffffc0205df0 <run_timer_list+0x3e>
                    warn("process %d's wait_state == 0.\n", proc->pid);
ffffffffc0205e1a:	40d4                	lw	a3,4(s1)
ffffffffc0205e1c:	00002617          	auipc	a2,0x2
ffffffffc0205e20:	7e460613          	addi	a2,a2,2020 # ffffffffc0208600 <etext+0x215e>
ffffffffc0205e24:	0a300593          	li	a1,163
ffffffffc0205e28:	00002517          	auipc	a0,0x2
ffffffffc0205e2c:	70850513          	addi	a0,a0,1800 # ffffffffc0208530 <etext+0x208e>
ffffffffc0205e30:	e84fa0ef          	jal	ffffffffc02004b4 <__warn>
                wakeup_proc(proc);
ffffffffc0205e34:	8526                	mv	a0,s1
ffffffffc0205e36:	c7bff0ef          	jal	ffffffffc0205ab0 <wakeup_proc>
                del_timer(timer);
ffffffffc0205e3a:	854a                	mv	a0,s2
ffffffffc0205e3c:	ee9ff0ef          	jal	ffffffffc0205d24 <del_timer>
                if (le == &timer_list) {
ffffffffc0205e40:	fd3412e3          	bne	s0,s3,ffffffffc0205e04 <run_timer_list+0x52>
ffffffffc0205e44:	64e2                	ld	s1,24(sp)
ffffffffc0205e46:	6942                	ld	s2,16(sp)
            }
        }
        sched_class_proc_tick(current);
ffffffffc0205e48:	000c6597          	auipc	a1,0xc6
ffffffffc0205e4c:	5085b583          	ld	a1,1288(a1) # ffffffffc02cc350 <current>
    if (proc != idleproc) {
ffffffffc0205e50:	000c6797          	auipc	a5,0xc6
ffffffffc0205e54:	5107b783          	ld	a5,1296(a5) # ffffffffc02cc360 <idleproc>
ffffffffc0205e58:	02f58b63          	beq	a1,a5,ffffffffc0205e8e <run_timer_list+0xdc>
        sched_class->proc_tick(rq, proc);
ffffffffc0205e5c:	000c6797          	auipc	a5,0xc6
ffffffffc0205e60:	5147b783          	ld	a5,1300(a5) # ffffffffc02cc370 <sched_class>
ffffffffc0205e64:	000c6517          	auipc	a0,0xc6
ffffffffc0205e68:	50453503          	ld	a0,1284(a0) # ffffffffc02cc368 <rq>
ffffffffc0205e6c:	779c                	ld	a5,40(a5)
ffffffffc0205e6e:	9782                	jalr	a5
    if (flag) {
ffffffffc0205e70:	000a1863          	bnez	s4,ffffffffc0205e80 <run_timer_list+0xce>
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205e74:	70a2                	ld	ra,40(sp)
ffffffffc0205e76:	7402                	ld	s0,32(sp)
ffffffffc0205e78:	69a2                	ld	s3,8(sp)
ffffffffc0205e7a:	6a02                	ld	s4,0(sp)
ffffffffc0205e7c:	6145                	addi	sp,sp,48
ffffffffc0205e7e:	8082                	ret
ffffffffc0205e80:	7402                	ld	s0,32(sp)
ffffffffc0205e82:	70a2                	ld	ra,40(sp)
ffffffffc0205e84:	69a2                	ld	s3,8(sp)
ffffffffc0205e86:	6a02                	ld	s4,0(sp)
ffffffffc0205e88:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc0205e8a:	a6ffa06f          	j	ffffffffc02008f8 <intr_enable>
        proc->need_resched = 1;
ffffffffc0205e8e:	4785                	li	a5,1
ffffffffc0205e90:	ed9c                	sd	a5,24(a1)
ffffffffc0205e92:	bff9                	j	ffffffffc0205e70 <run_timer_list+0xbe>
        intr_disable();
ffffffffc0205e94:	a6bfa0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc0205e98:	4a05                	li	s4,1
ffffffffc0205e9a:	b735                	j	ffffffffc0205dc6 <run_timer_list+0x14>
                    assert(proc->wait_state & WT_INTERRUPTED);
ffffffffc0205e9c:	00002697          	auipc	a3,0x2
ffffffffc0205ea0:	73c68693          	addi	a3,a3,1852 # ffffffffc02085d8 <etext+0x2136>
ffffffffc0205ea4:	00001617          	auipc	a2,0x1
ffffffffc0205ea8:	fd460613          	addi	a2,a2,-44 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0205eac:	0a000593          	li	a1,160
ffffffffc0205eb0:	00002517          	auipc	a0,0x2
ffffffffc0205eb4:	68050513          	addi	a0,a0,1664 # ffffffffc0208530 <etext+0x208e>
ffffffffc0205eb8:	d92fa0ef          	jal	ffffffffc020044a <__panic>
            assert(timer->expires != 0);
ffffffffc0205ebc:	00002697          	auipc	a3,0x2
ffffffffc0205ec0:	70468693          	addi	a3,a3,1796 # ffffffffc02085c0 <etext+0x211e>
ffffffffc0205ec4:	00001617          	auipc	a2,0x1
ffffffffc0205ec8:	fb460613          	addi	a2,a2,-76 # ffffffffc0206e78 <etext+0x9d6>
ffffffffc0205ecc:	09a00593          	li	a1,154
ffffffffc0205ed0:	00002517          	auipc	a0,0x2
ffffffffc0205ed4:	66050513          	addi	a0,a0,1632 # ffffffffc0208530 <etext+0x208e>
ffffffffc0205ed8:	ec26                	sd	s1,24(sp)
ffffffffc0205eda:	e84a                	sd	s2,16(sp)
ffffffffc0205edc:	d6efa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0205ee0 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc0205ee0:	000c6797          	auipc	a5,0xc6
ffffffffc0205ee4:	4707b783          	ld	a5,1136(a5) # ffffffffc02cc350 <current>
}
ffffffffc0205ee8:	43c8                	lw	a0,4(a5)
ffffffffc0205eea:	8082                	ret

ffffffffc0205eec <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc0205eec:	4501                	li	a0,0
ffffffffc0205eee:	8082                	ret

ffffffffc0205ef0 <sys_gettime>:
static int sys_gettime(uint64_t arg[]){
    return (int)ticks*10;
ffffffffc0205ef0:	000c6797          	auipc	a5,0xc6
ffffffffc0205ef4:	4087b783          	ld	a5,1032(a5) # ffffffffc02cc2f8 <ticks>
ffffffffc0205ef8:	0027951b          	slliw	a0,a5,0x2
ffffffffc0205efc:	9d3d                	addw	a0,a0,a5
ffffffffc0205efe:	0015151b          	slliw	a0,a0,0x1
}
ffffffffc0205f02:	8082                	ret

ffffffffc0205f04 <sys_lab6_set_priority>:
static int sys_lab6_set_priority(uint64_t arg[]){
    uint64_t priority = (uint64_t)arg[0];
    lab6_set_priority(priority);
ffffffffc0205f04:	4108                	lw	a0,0(a0)
static int sys_lab6_set_priority(uint64_t arg[]){
ffffffffc0205f06:	1141                	addi	sp,sp,-16
ffffffffc0205f08:	e406                	sd	ra,8(sp)
    lab6_set_priority(priority);
ffffffffc0205f0a:	a2bff0ef          	jal	ffffffffc0205934 <lab6_set_priority>
    return 0;
}
ffffffffc0205f0e:	60a2                	ld	ra,8(sp)
ffffffffc0205f10:	4501                	li	a0,0
ffffffffc0205f12:	0141                	addi	sp,sp,16
ffffffffc0205f14:	8082                	ret

ffffffffc0205f16 <sys_putc>:
    cputchar(c);
ffffffffc0205f16:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc0205f18:	1141                	addi	sp,sp,-16
ffffffffc0205f1a:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0205f1c:	ab0fa0ef          	jal	ffffffffc02001cc <cputchar>
}
ffffffffc0205f20:	60a2                	ld	ra,8(sp)
ffffffffc0205f22:	4501                	li	a0,0
ffffffffc0205f24:	0141                	addi	sp,sp,16
ffffffffc0205f26:	8082                	ret

ffffffffc0205f28 <sys_kill>:
    return do_kill(pid);
ffffffffc0205f28:	4108                	lw	a0,0(a0)
ffffffffc0205f2a:	fd8ff06f          	j	ffffffffc0205702 <do_kill>

ffffffffc0205f2e <sys_sleep>:
static int
sys_sleep(uint64_t arg[]) {
    unsigned int time = (unsigned int)arg[0];
    return do_sleep(time);
ffffffffc0205f2e:	4108                	lw	a0,0(a0)
ffffffffc0205f30:	a33ff06f          	j	ffffffffc0205962 <do_sleep>

ffffffffc0205f34 <sys_yield>:
    return do_yield();
ffffffffc0205f34:	f84ff06f          	j	ffffffffc02056b8 <do_yield>

ffffffffc0205f38 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0205f38:	6d14                	ld	a3,24(a0)
ffffffffc0205f3a:	6910                	ld	a2,16(a0)
ffffffffc0205f3c:	650c                	ld	a1,8(a0)
ffffffffc0205f3e:	6108                	ld	a0,0(a0)
ffffffffc0205f40:	946ff06f          	j	ffffffffc0205086 <do_execve>

ffffffffc0205f44 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0205f44:	650c                	ld	a1,8(a0)
ffffffffc0205f46:	4108                	lw	a0,0(a0)
ffffffffc0205f48:	f80ff06f          	j	ffffffffc02056c8 <do_wait>

ffffffffc0205f4c <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0205f4c:	000c6797          	auipc	a5,0xc6
ffffffffc0205f50:	4047b783          	ld	a5,1028(a5) # ffffffffc02cc350 <current>
    return do_fork(0, stack, tf);
ffffffffc0205f54:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc0205f56:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0205f58:	6a0c                	ld	a1,16(a2)
ffffffffc0205f5a:	861fe06f          	j	ffffffffc02047ba <do_fork>

ffffffffc0205f5e <sys_exit>:
    return do_exit(error_code);
ffffffffc0205f5e:	4108                	lw	a0,0(a0)
ffffffffc0205f60:	cd5fe06f          	j	ffffffffc0204c34 <do_exit>

ffffffffc0205f64 <syscall>:

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
    struct trapframe *tf = current->tf;
ffffffffc0205f64:	000c6697          	auipc	a3,0xc6
ffffffffc0205f68:	3ec6b683          	ld	a3,1004(a3) # ffffffffc02cc350 <current>
syscall(void) {
ffffffffc0205f6c:	715d                	addi	sp,sp,-80
ffffffffc0205f6e:	e0a2                	sd	s0,64(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205f70:	72c0                	ld	s0,160(a3)
syscall(void) {
ffffffffc0205f72:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205f74:	0ff00793          	li	a5,255
    int num = tf->gpr.a0;
ffffffffc0205f78:	4834                	lw	a3,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205f7a:	02d7ec63          	bltu	a5,a3,ffffffffc0205fb2 <syscall+0x4e>
        if (syscalls[num] != NULL) {
ffffffffc0205f7e:	00003797          	auipc	a5,0x3
ffffffffc0205f82:	8ca78793          	addi	a5,a5,-1846 # ffffffffc0208848 <syscalls>
ffffffffc0205f86:	00369613          	slli	a2,a3,0x3
ffffffffc0205f8a:	97b2                	add	a5,a5,a2
ffffffffc0205f8c:	639c                	ld	a5,0(a5)
ffffffffc0205f8e:	c395                	beqz	a5,ffffffffc0205fb2 <syscall+0x4e>
            arg[0] = tf->gpr.a1;
ffffffffc0205f90:	7028                	ld	a0,96(s0)
ffffffffc0205f92:	742c                	ld	a1,104(s0)
ffffffffc0205f94:	7830                	ld	a2,112(s0)
ffffffffc0205f96:	7c34                	ld	a3,120(s0)
ffffffffc0205f98:	6c38                	ld	a4,88(s0)
ffffffffc0205f9a:	f02a                	sd	a0,32(sp)
ffffffffc0205f9c:	f42e                	sd	a1,40(sp)
ffffffffc0205f9e:	f832                	sd	a2,48(sp)
ffffffffc0205fa0:	fc36                	sd	a3,56(sp)
ffffffffc0205fa2:	ec3a                	sd	a4,24(sp)
            arg[1] = tf->gpr.a2;
            arg[2] = tf->gpr.a3;
            arg[3] = tf->gpr.a4;
            arg[4] = tf->gpr.a5;
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205fa4:	0828                	addi	a0,sp,24
ffffffffc0205fa6:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0205fa8:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205faa:	e828                	sd	a0,80(s0)
}
ffffffffc0205fac:	6406                	ld	s0,64(sp)
ffffffffc0205fae:	6161                	addi	sp,sp,80
ffffffffc0205fb0:	8082                	ret
    print_trapframe(tf);
ffffffffc0205fb2:	8522                	mv	a0,s0
ffffffffc0205fb4:	e436                	sd	a3,8(sp)
ffffffffc0205fb6:	b39fa0ef          	jal	ffffffffc0200aee <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0205fba:	000c6797          	auipc	a5,0xc6
ffffffffc0205fbe:	3967b783          	ld	a5,918(a5) # ffffffffc02cc350 <current>
ffffffffc0205fc2:	66a2                	ld	a3,8(sp)
ffffffffc0205fc4:	00002617          	auipc	a2,0x2
ffffffffc0205fc8:	65c60613          	addi	a2,a2,1628 # ffffffffc0208620 <etext+0x217e>
ffffffffc0205fcc:	43d8                	lw	a4,4(a5)
ffffffffc0205fce:	07300593          	li	a1,115
ffffffffc0205fd2:	0b478793          	addi	a5,a5,180
ffffffffc0205fd6:	00002517          	auipc	a0,0x2
ffffffffc0205fda:	67a50513          	addi	a0,a0,1658 # ffffffffc0208650 <etext+0x21ae>
ffffffffc0205fde:	c6cfa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0205fe2 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc0205fe2:	9e3707b7          	lui	a5,0x9e370
ffffffffc0205fe6:	2785                	addiw	a5,a5,1 # ffffffff9e370001 <_binary_obj___user_matrix_out_size+0xffffffff9e364919>
ffffffffc0205fe8:	02a787bb          	mulw	a5,a5,a0
    return (hash >> (32 - bits));
ffffffffc0205fec:	02000513          	li	a0,32
ffffffffc0205ff0:	9d0d                	subw	a0,a0,a1
}
ffffffffc0205ff2:	00a7d53b          	srlw	a0,a5,a0
ffffffffc0205ff6:	8082                	ret

ffffffffc0205ff8 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205ff8:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0205ffa:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0205ffe:	f022                	sd	s0,32(sp)
ffffffffc0206000:	ec26                	sd	s1,24(sp)
ffffffffc0206002:	e84a                	sd	s2,16(sp)
ffffffffc0206004:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0206006:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc020600a:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
ffffffffc020600c:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0206010:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0206014:	84aa                	mv	s1,a0
ffffffffc0206016:	892e                	mv	s2,a1
    if (num >= base) {
ffffffffc0206018:	03067d63          	bgeu	a2,a6,ffffffffc0206052 <printnum+0x5a>
ffffffffc020601c:	e44e                	sd	s3,8(sp)
ffffffffc020601e:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0206020:	4785                	li	a5,1
ffffffffc0206022:	00e7d763          	bge	a5,a4,ffffffffc0206030 <printnum+0x38>
            putch(padc, putdat);
ffffffffc0206026:	85ca                	mv	a1,s2
ffffffffc0206028:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc020602a:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc020602c:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020602e:	fc65                	bnez	s0,ffffffffc0206026 <printnum+0x2e>
ffffffffc0206030:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206032:	00002797          	auipc	a5,0x2
ffffffffc0206036:	63678793          	addi	a5,a5,1590 # ffffffffc0208668 <etext+0x21c6>
ffffffffc020603a:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc020603c:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020603e:	0007c503          	lbu	a0,0(a5)
}
ffffffffc0206042:	70a2                	ld	ra,40(sp)
ffffffffc0206044:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206046:	85ca                	mv	a1,s2
ffffffffc0206048:	87a6                	mv	a5,s1
}
ffffffffc020604a:	6942                	ld	s2,16(sp)
ffffffffc020604c:	64e2                	ld	s1,24(sp)
ffffffffc020604e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206050:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0206052:	03065633          	divu	a2,a2,a6
ffffffffc0206056:	8722                	mv	a4,s0
ffffffffc0206058:	fa1ff0ef          	jal	ffffffffc0205ff8 <printnum>
ffffffffc020605c:	bfd9                	j	ffffffffc0206032 <printnum+0x3a>

ffffffffc020605e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020605e:	7119                	addi	sp,sp,-128
ffffffffc0206060:	f4a6                	sd	s1,104(sp)
ffffffffc0206062:	f0ca                	sd	s2,96(sp)
ffffffffc0206064:	ecce                	sd	s3,88(sp)
ffffffffc0206066:	e8d2                	sd	s4,80(sp)
ffffffffc0206068:	e4d6                	sd	s5,72(sp)
ffffffffc020606a:	e0da                	sd	s6,64(sp)
ffffffffc020606c:	f862                	sd	s8,48(sp)
ffffffffc020606e:	fc86                	sd	ra,120(sp)
ffffffffc0206070:	f8a2                	sd	s0,112(sp)
ffffffffc0206072:	fc5e                	sd	s7,56(sp)
ffffffffc0206074:	f466                	sd	s9,40(sp)
ffffffffc0206076:	f06a                	sd	s10,32(sp)
ffffffffc0206078:	ec6e                	sd	s11,24(sp)
ffffffffc020607a:	84aa                	mv	s1,a0
ffffffffc020607c:	8c32                	mv	s8,a2
ffffffffc020607e:	8a36                	mv	s4,a3
ffffffffc0206080:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206082:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206086:	05500b13          	li	s6,85
ffffffffc020608a:	00003a97          	auipc	s5,0x3
ffffffffc020608e:	fbea8a93          	addi	s5,s5,-66 # ffffffffc0209048 <syscalls+0x800>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206092:	000c4503          	lbu	a0,0(s8)
ffffffffc0206096:	001c0413          	addi	s0,s8,1
ffffffffc020609a:	01350a63          	beq	a0,s3,ffffffffc02060ae <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc020609e:	cd0d                	beqz	a0,ffffffffc02060d8 <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc02060a0:	85ca                	mv	a1,s2
ffffffffc02060a2:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc02060a4:	00044503          	lbu	a0,0(s0)
ffffffffc02060a8:	0405                	addi	s0,s0,1
ffffffffc02060aa:	ff351ae3          	bne	a0,s3,ffffffffc020609e <vprintfmt+0x40>
        width = precision = -1;
ffffffffc02060ae:	5cfd                	li	s9,-1
ffffffffc02060b0:	8d66                	mv	s10,s9
        char padc = ' ';
ffffffffc02060b2:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc02060b6:	4b81                	li	s7,0
ffffffffc02060b8:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02060ba:	00044683          	lbu	a3,0(s0)
ffffffffc02060be:	00140c13          	addi	s8,s0,1
ffffffffc02060c2:	fdd6859b          	addiw	a1,a3,-35
ffffffffc02060c6:	0ff5f593          	zext.b	a1,a1
ffffffffc02060ca:	02bb6663          	bltu	s6,a1,ffffffffc02060f6 <vprintfmt+0x98>
ffffffffc02060ce:	058a                	slli	a1,a1,0x2
ffffffffc02060d0:	95d6                	add	a1,a1,s5
ffffffffc02060d2:	4198                	lw	a4,0(a1)
ffffffffc02060d4:	9756                	add	a4,a4,s5
ffffffffc02060d6:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02060d8:	70e6                	ld	ra,120(sp)
ffffffffc02060da:	7446                	ld	s0,112(sp)
ffffffffc02060dc:	74a6                	ld	s1,104(sp)
ffffffffc02060de:	7906                	ld	s2,96(sp)
ffffffffc02060e0:	69e6                	ld	s3,88(sp)
ffffffffc02060e2:	6a46                	ld	s4,80(sp)
ffffffffc02060e4:	6aa6                	ld	s5,72(sp)
ffffffffc02060e6:	6b06                	ld	s6,64(sp)
ffffffffc02060e8:	7be2                	ld	s7,56(sp)
ffffffffc02060ea:	7c42                	ld	s8,48(sp)
ffffffffc02060ec:	7ca2                	ld	s9,40(sp)
ffffffffc02060ee:	7d02                	ld	s10,32(sp)
ffffffffc02060f0:	6de2                	ld	s11,24(sp)
ffffffffc02060f2:	6109                	addi	sp,sp,128
ffffffffc02060f4:	8082                	ret
            putch('%', putdat);
ffffffffc02060f6:	85ca                	mv	a1,s2
ffffffffc02060f8:	02500513          	li	a0,37
ffffffffc02060fc:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02060fe:	fff44783          	lbu	a5,-1(s0)
ffffffffc0206102:	02500713          	li	a4,37
ffffffffc0206106:	8c22                	mv	s8,s0
ffffffffc0206108:	f8e785e3          	beq	a5,a4,ffffffffc0206092 <vprintfmt+0x34>
ffffffffc020610c:	ffec4783          	lbu	a5,-2(s8)
ffffffffc0206110:	1c7d                	addi	s8,s8,-1
ffffffffc0206112:	fee79de3          	bne	a5,a4,ffffffffc020610c <vprintfmt+0xae>
ffffffffc0206116:	bfb5                	j	ffffffffc0206092 <vprintfmt+0x34>
                ch = *fmt;
ffffffffc0206118:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc020611c:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
ffffffffc020611e:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc0206122:	fd06071b          	addiw	a4,a2,-48
ffffffffc0206126:	24e56a63          	bltu	a0,a4,ffffffffc020637a <vprintfmt+0x31c>
                ch = *fmt;
ffffffffc020612a:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020612c:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
ffffffffc020612e:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
ffffffffc0206132:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0206136:	0197073b          	addw	a4,a4,s9
ffffffffc020613a:	0017171b          	slliw	a4,a4,0x1
ffffffffc020613e:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206140:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0206144:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0206146:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020614a:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
ffffffffc020614e:	feb570e3          	bgeu	a0,a1,ffffffffc020612e <vprintfmt+0xd0>
            if (width < 0)
ffffffffc0206152:	f60d54e3          	bgez	s10,ffffffffc02060ba <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc0206156:	8d66                	mv	s10,s9
ffffffffc0206158:	5cfd                	li	s9,-1
ffffffffc020615a:	b785                	j	ffffffffc02060ba <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020615c:	8db6                	mv	s11,a3
ffffffffc020615e:	8462                	mv	s0,s8
ffffffffc0206160:	bfa9                	j	ffffffffc02060ba <vprintfmt+0x5c>
ffffffffc0206162:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc0206164:	4b85                	li	s7,1
            goto reswitch;
ffffffffc0206166:	bf91                	j	ffffffffc02060ba <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc0206168:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020616a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020616e:	00f74463          	blt	a4,a5,ffffffffc0206176 <vprintfmt+0x118>
    else if (lflag) {
ffffffffc0206172:	1a078763          	beqz	a5,ffffffffc0206320 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
ffffffffc0206176:	000a3603          	ld	a2,0(s4)
ffffffffc020617a:	46c1                	li	a3,16
ffffffffc020617c:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020617e:	000d879b          	sext.w	a5,s11
ffffffffc0206182:	876a                	mv	a4,s10
ffffffffc0206184:	85ca                	mv	a1,s2
ffffffffc0206186:	8526                	mv	a0,s1
ffffffffc0206188:	e71ff0ef          	jal	ffffffffc0205ff8 <printnum>
            break;
ffffffffc020618c:	b719                	j	ffffffffc0206092 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc020618e:	000a2503          	lw	a0,0(s4)
ffffffffc0206192:	85ca                	mv	a1,s2
ffffffffc0206194:	0a21                	addi	s4,s4,8
ffffffffc0206196:	9482                	jalr	s1
            break;
ffffffffc0206198:	bded                	j	ffffffffc0206092 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc020619a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020619c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02061a0:	00f74463          	blt	a4,a5,ffffffffc02061a8 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc02061a4:	16078963          	beqz	a5,ffffffffc0206316 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
ffffffffc02061a8:	000a3603          	ld	a2,0(s4)
ffffffffc02061ac:	46a9                	li	a3,10
ffffffffc02061ae:	8a2e                	mv	s4,a1
ffffffffc02061b0:	b7f9                	j	ffffffffc020617e <vprintfmt+0x120>
            putch('0', putdat);
ffffffffc02061b2:	85ca                	mv	a1,s2
ffffffffc02061b4:	03000513          	li	a0,48
ffffffffc02061b8:	9482                	jalr	s1
            putch('x', putdat);
ffffffffc02061ba:	85ca                	mv	a1,s2
ffffffffc02061bc:	07800513          	li	a0,120
ffffffffc02061c0:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02061c2:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc02061c6:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02061c8:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02061ca:	bf55                	j	ffffffffc020617e <vprintfmt+0x120>
            putch(ch, putdat);
ffffffffc02061cc:	85ca                	mv	a1,s2
ffffffffc02061ce:	02500513          	li	a0,37
ffffffffc02061d2:	9482                	jalr	s1
            break;
ffffffffc02061d4:	bd7d                	j	ffffffffc0206092 <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc02061d6:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02061da:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc02061dc:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc02061de:	bf95                	j	ffffffffc0206152 <vprintfmt+0xf4>
    if (lflag >= 2) {
ffffffffc02061e0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02061e2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02061e6:	00f74463          	blt	a4,a5,ffffffffc02061ee <vprintfmt+0x190>
    else if (lflag) {
ffffffffc02061ea:	12078163          	beqz	a5,ffffffffc020630c <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
ffffffffc02061ee:	000a3603          	ld	a2,0(s4)
ffffffffc02061f2:	46a1                	li	a3,8
ffffffffc02061f4:	8a2e                	mv	s4,a1
ffffffffc02061f6:	b761                	j	ffffffffc020617e <vprintfmt+0x120>
            if (width < 0)
ffffffffc02061f8:	876a                	mv	a4,s10
ffffffffc02061fa:	000d5363          	bgez	s10,ffffffffc0206200 <vprintfmt+0x1a2>
ffffffffc02061fe:	4701                	li	a4,0
ffffffffc0206200:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206204:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0206206:	bd55                	j	ffffffffc02060ba <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
ffffffffc0206208:	000d841b          	sext.w	s0,s11
ffffffffc020620c:	fd340793          	addi	a5,s0,-45
ffffffffc0206210:	00f037b3          	snez	a5,a5
ffffffffc0206214:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206218:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
ffffffffc020621c:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020621e:	008a0793          	addi	a5,s4,8
ffffffffc0206222:	e43e                	sd	a5,8(sp)
ffffffffc0206224:	100d8c63          	beqz	s11,ffffffffc020633c <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc0206228:	12071363          	bnez	a4,ffffffffc020634e <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020622c:	000dc783          	lbu	a5,0(s11)
ffffffffc0206230:	0007851b          	sext.w	a0,a5
ffffffffc0206234:	c78d                	beqz	a5,ffffffffc020625e <vprintfmt+0x200>
ffffffffc0206236:	0d85                	addi	s11,s11,1
ffffffffc0206238:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020623a:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020623e:	000cc563          	bltz	s9,ffffffffc0206248 <vprintfmt+0x1ea>
ffffffffc0206242:	3cfd                	addiw	s9,s9,-1
ffffffffc0206244:	008c8d63          	beq	s9,s0,ffffffffc020625e <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206248:	020b9663          	bnez	s7,ffffffffc0206274 <vprintfmt+0x216>
                    putch(ch, putdat);
ffffffffc020624c:	85ca                	mv	a1,s2
ffffffffc020624e:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206250:	000dc783          	lbu	a5,0(s11)
ffffffffc0206254:	0d85                	addi	s11,s11,1
ffffffffc0206256:	3d7d                	addiw	s10,s10,-1
ffffffffc0206258:	0007851b          	sext.w	a0,a5
ffffffffc020625c:	f3ed                	bnez	a5,ffffffffc020623e <vprintfmt+0x1e0>
            for (; width > 0; width --) {
ffffffffc020625e:	01a05963          	blez	s10,ffffffffc0206270 <vprintfmt+0x212>
                putch(' ', putdat);
ffffffffc0206262:	85ca                	mv	a1,s2
ffffffffc0206264:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc0206268:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
ffffffffc020626a:	9482                	jalr	s1
            for (; width > 0; width --) {
ffffffffc020626c:	fe0d1be3          	bnez	s10,ffffffffc0206262 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206270:	6a22                	ld	s4,8(sp)
ffffffffc0206272:	b505                	j	ffffffffc0206092 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206274:	3781                	addiw	a5,a5,-32
ffffffffc0206276:	fcfa7be3          	bgeu	s4,a5,ffffffffc020624c <vprintfmt+0x1ee>
                    putch('?', putdat);
ffffffffc020627a:	03f00513          	li	a0,63
ffffffffc020627e:	85ca                	mv	a1,s2
ffffffffc0206280:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206282:	000dc783          	lbu	a5,0(s11)
ffffffffc0206286:	0d85                	addi	s11,s11,1
ffffffffc0206288:	3d7d                	addiw	s10,s10,-1
ffffffffc020628a:	0007851b          	sext.w	a0,a5
ffffffffc020628e:	dbe1                	beqz	a5,ffffffffc020625e <vprintfmt+0x200>
ffffffffc0206290:	fa0cd9e3          	bgez	s9,ffffffffc0206242 <vprintfmt+0x1e4>
ffffffffc0206294:	b7c5                	j	ffffffffc0206274 <vprintfmt+0x216>
            if (err < 0) {
ffffffffc0206296:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020629a:	4661                	li	a2,24
            err = va_arg(ap, int);
ffffffffc020629c:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020629e:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc02062a2:	8fb9                	xor	a5,a5,a4
ffffffffc02062a4:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc02062a8:	02d64563          	blt	a2,a3,ffffffffc02062d2 <vprintfmt+0x274>
ffffffffc02062ac:	00003797          	auipc	a5,0x3
ffffffffc02062b0:	ef478793          	addi	a5,a5,-268 # ffffffffc02091a0 <error_string>
ffffffffc02062b4:	00369713          	slli	a4,a3,0x3
ffffffffc02062b8:	97ba                	add	a5,a5,a4
ffffffffc02062ba:	639c                	ld	a5,0(a5)
ffffffffc02062bc:	cb99                	beqz	a5,ffffffffc02062d2 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
ffffffffc02062be:	86be                	mv	a3,a5
ffffffffc02062c0:	00000617          	auipc	a2,0x0
ffffffffc02062c4:	21060613          	addi	a2,a2,528 # ffffffffc02064d0 <etext+0x2e>
ffffffffc02062c8:	85ca                	mv	a1,s2
ffffffffc02062ca:	8526                	mv	a0,s1
ffffffffc02062cc:	0d8000ef          	jal	ffffffffc02063a4 <printfmt>
ffffffffc02062d0:	b3c9                	j	ffffffffc0206092 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02062d2:	00002617          	auipc	a2,0x2
ffffffffc02062d6:	3b660613          	addi	a2,a2,950 # ffffffffc0208688 <etext+0x21e6>
ffffffffc02062da:	85ca                	mv	a1,s2
ffffffffc02062dc:	8526                	mv	a0,s1
ffffffffc02062de:	0c6000ef          	jal	ffffffffc02063a4 <printfmt>
ffffffffc02062e2:	bb45                	j	ffffffffc0206092 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc02062e4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02062e6:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc02062ea:	00f74363          	blt	a4,a5,ffffffffc02062f0 <vprintfmt+0x292>
    else if (lflag) {
ffffffffc02062ee:	cf81                	beqz	a5,ffffffffc0206306 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
ffffffffc02062f0:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02062f4:	02044b63          	bltz	s0,ffffffffc020632a <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc02062f8:	8622                	mv	a2,s0
ffffffffc02062fa:	8a5e                	mv	s4,s7
ffffffffc02062fc:	46a9                	li	a3,10
ffffffffc02062fe:	b541                	j	ffffffffc020617e <vprintfmt+0x120>
            lflag ++;
ffffffffc0206300:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206302:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0206304:	bb5d                	j	ffffffffc02060ba <vprintfmt+0x5c>
        return va_arg(*ap, int);
ffffffffc0206306:	000a2403          	lw	s0,0(s4)
ffffffffc020630a:	b7ed                	j	ffffffffc02062f4 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
ffffffffc020630c:	000a6603          	lwu	a2,0(s4)
ffffffffc0206310:	46a1                	li	a3,8
ffffffffc0206312:	8a2e                	mv	s4,a1
ffffffffc0206314:	b5ad                	j	ffffffffc020617e <vprintfmt+0x120>
ffffffffc0206316:	000a6603          	lwu	a2,0(s4)
ffffffffc020631a:	46a9                	li	a3,10
ffffffffc020631c:	8a2e                	mv	s4,a1
ffffffffc020631e:	b585                	j	ffffffffc020617e <vprintfmt+0x120>
ffffffffc0206320:	000a6603          	lwu	a2,0(s4)
ffffffffc0206324:	46c1                	li	a3,16
ffffffffc0206326:	8a2e                	mv	s4,a1
ffffffffc0206328:	bd99                	j	ffffffffc020617e <vprintfmt+0x120>
                putch('-', putdat);
ffffffffc020632a:	85ca                	mv	a1,s2
ffffffffc020632c:	02d00513          	li	a0,45
ffffffffc0206330:	9482                	jalr	s1
                num = -(long long)num;
ffffffffc0206332:	40800633          	neg	a2,s0
ffffffffc0206336:	8a5e                	mv	s4,s7
ffffffffc0206338:	46a9                	li	a3,10
ffffffffc020633a:	b591                	j	ffffffffc020617e <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
ffffffffc020633c:	e329                	bnez	a4,ffffffffc020637e <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020633e:	02800793          	li	a5,40
ffffffffc0206342:	853e                	mv	a0,a5
ffffffffc0206344:	00002d97          	auipc	s11,0x2
ffffffffc0206348:	33dd8d93          	addi	s11,s11,829 # ffffffffc0208681 <etext+0x21df>
ffffffffc020634c:	b5f5                	j	ffffffffc0206238 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020634e:	85e6                	mv	a1,s9
ffffffffc0206350:	856e                	mv	a0,s11
ffffffffc0206352:	08a000ef          	jal	ffffffffc02063dc <strnlen>
ffffffffc0206356:	40ad0d3b          	subw	s10,s10,a0
ffffffffc020635a:	01a05863          	blez	s10,ffffffffc020636a <vprintfmt+0x30c>
                    putch(padc, putdat);
ffffffffc020635e:	85ca                	mv	a1,s2
ffffffffc0206360:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206362:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
ffffffffc0206364:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206366:	fe0d1ce3          	bnez	s10,ffffffffc020635e <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020636a:	000dc783          	lbu	a5,0(s11)
ffffffffc020636e:	0007851b          	sext.w	a0,a5
ffffffffc0206372:	ec0792e3          	bnez	a5,ffffffffc0206236 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206376:	6a22                	ld	s4,8(sp)
ffffffffc0206378:	bb29                	j	ffffffffc0206092 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020637a:	8462                	mv	s0,s8
ffffffffc020637c:	bbd9                	j	ffffffffc0206152 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020637e:	85e6                	mv	a1,s9
ffffffffc0206380:	00002517          	auipc	a0,0x2
ffffffffc0206384:	30050513          	addi	a0,a0,768 # ffffffffc0208680 <etext+0x21de>
ffffffffc0206388:	054000ef          	jal	ffffffffc02063dc <strnlen>
ffffffffc020638c:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206390:	02800793          	li	a5,40
                p = "(null)";
ffffffffc0206394:	00002d97          	auipc	s11,0x2
ffffffffc0206398:	2ecd8d93          	addi	s11,s11,748 # ffffffffc0208680 <etext+0x21de>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020639c:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020639e:	fda040e3          	bgtz	s10,ffffffffc020635e <vprintfmt+0x300>
ffffffffc02063a2:	bd51                	j	ffffffffc0206236 <vprintfmt+0x1d8>

ffffffffc02063a4 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02063a4:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc02063a6:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02063aa:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02063ac:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc02063ae:	ec06                	sd	ra,24(sp)
ffffffffc02063b0:	f83a                	sd	a4,48(sp)
ffffffffc02063b2:	fc3e                	sd	a5,56(sp)
ffffffffc02063b4:	e0c2                	sd	a6,64(sp)
ffffffffc02063b6:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02063b8:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02063ba:	ca5ff0ef          	jal	ffffffffc020605e <vprintfmt>
}
ffffffffc02063be:	60e2                	ld	ra,24(sp)
ffffffffc02063c0:	6161                	addi	sp,sp,80
ffffffffc02063c2:	8082                	ret

ffffffffc02063c4 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02063c4:	00054783          	lbu	a5,0(a0)
ffffffffc02063c8:	cb81                	beqz	a5,ffffffffc02063d8 <strlen+0x14>
    size_t cnt = 0;
ffffffffc02063ca:	4781                	li	a5,0
        cnt ++;
ffffffffc02063cc:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc02063ce:	00f50733          	add	a4,a0,a5
ffffffffc02063d2:	00074703          	lbu	a4,0(a4)
ffffffffc02063d6:	fb7d                	bnez	a4,ffffffffc02063cc <strlen+0x8>
    }
    return cnt;
}
ffffffffc02063d8:	853e                	mv	a0,a5
ffffffffc02063da:	8082                	ret

ffffffffc02063dc <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02063dc:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02063de:	e589                	bnez	a1,ffffffffc02063e8 <strnlen+0xc>
ffffffffc02063e0:	a811                	j	ffffffffc02063f4 <strnlen+0x18>
        cnt ++;
ffffffffc02063e2:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02063e4:	00f58863          	beq	a1,a5,ffffffffc02063f4 <strnlen+0x18>
ffffffffc02063e8:	00f50733          	add	a4,a0,a5
ffffffffc02063ec:	00074703          	lbu	a4,0(a4)
ffffffffc02063f0:	fb6d                	bnez	a4,ffffffffc02063e2 <strnlen+0x6>
ffffffffc02063f2:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02063f4:	852e                	mv	a0,a1
ffffffffc02063f6:	8082                	ret

ffffffffc02063f8 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02063f8:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02063fa:	0005c703          	lbu	a4,0(a1)
ffffffffc02063fe:	0585                	addi	a1,a1,1
ffffffffc0206400:	0785                	addi	a5,a5,1
ffffffffc0206402:	fee78fa3          	sb	a4,-1(a5)
ffffffffc0206406:	fb75                	bnez	a4,ffffffffc02063fa <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc0206408:	8082                	ret

ffffffffc020640a <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc020640a:	00054783          	lbu	a5,0(a0)
ffffffffc020640e:	e791                	bnez	a5,ffffffffc020641a <strcmp+0x10>
ffffffffc0206410:	a01d                	j	ffffffffc0206436 <strcmp+0x2c>
ffffffffc0206412:	00054783          	lbu	a5,0(a0)
ffffffffc0206416:	cb99                	beqz	a5,ffffffffc020642c <strcmp+0x22>
ffffffffc0206418:	0585                	addi	a1,a1,1
ffffffffc020641a:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc020641e:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0206420:	fef709e3          	beq	a4,a5,ffffffffc0206412 <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206424:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0206428:	9d19                	subw	a0,a0,a4
ffffffffc020642a:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020642c:	0015c703          	lbu	a4,1(a1)
ffffffffc0206430:	4501                	li	a0,0
}
ffffffffc0206432:	9d19                	subw	a0,a0,a4
ffffffffc0206434:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206436:	0005c703          	lbu	a4,0(a1)
ffffffffc020643a:	4501                	li	a0,0
ffffffffc020643c:	b7f5                	j	ffffffffc0206428 <strcmp+0x1e>

ffffffffc020643e <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020643e:	ce01                	beqz	a2,ffffffffc0206456 <strncmp+0x18>
ffffffffc0206440:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0206444:	167d                	addi	a2,a2,-1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0206446:	cb91                	beqz	a5,ffffffffc020645a <strncmp+0x1c>
ffffffffc0206448:	0005c703          	lbu	a4,0(a1)
ffffffffc020644c:	00f71763          	bne	a4,a5,ffffffffc020645a <strncmp+0x1c>
        n --, s1 ++, s2 ++;
ffffffffc0206450:	0505                	addi	a0,a0,1
ffffffffc0206452:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0206454:	f675                	bnez	a2,ffffffffc0206440 <strncmp+0x2>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206456:	4501                	li	a0,0
ffffffffc0206458:	8082                	ret
ffffffffc020645a:	00054503          	lbu	a0,0(a0)
ffffffffc020645e:	0005c783          	lbu	a5,0(a1)
ffffffffc0206462:	9d1d                	subw	a0,a0,a5
}
ffffffffc0206464:	8082                	ret

ffffffffc0206466 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0206466:	a021                	j	ffffffffc020646e <strchr+0x8>
        if (*s == c) {
ffffffffc0206468:	00f58763          	beq	a1,a5,ffffffffc0206476 <strchr+0x10>
            return (char *)s;
        }
        s ++;
ffffffffc020646c:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020646e:	00054783          	lbu	a5,0(a0)
ffffffffc0206472:	fbfd                	bnez	a5,ffffffffc0206468 <strchr+0x2>
    }
    return NULL;
ffffffffc0206474:	4501                	li	a0,0
}
ffffffffc0206476:	8082                	ret

ffffffffc0206478 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0206478:	ca01                	beqz	a2,ffffffffc0206488 <memset+0x10>
ffffffffc020647a:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020647c:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020647e:	0785                	addi	a5,a5,1
ffffffffc0206480:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0206484:	fef61de3          	bne	a2,a5,ffffffffc020647e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0206488:	8082                	ret

ffffffffc020648a <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020648a:	ca19                	beqz	a2,ffffffffc02064a0 <memcpy+0x16>
ffffffffc020648c:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020648e:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0206490:	0005c703          	lbu	a4,0(a1)
ffffffffc0206494:	0585                	addi	a1,a1,1
ffffffffc0206496:	0785                	addi	a5,a5,1
ffffffffc0206498:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020649c:	feb61ae3          	bne	a2,a1,ffffffffc0206490 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc02064a0:	8082                	ret
