
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
ffffffffc0200056:	32e60613          	addi	a2,a2,814 # ffffffffc02cc380 <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16 # ffffffffc020bff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	6d6060ef          	jal	ffffffffc0206738 <memset>
    cons_init(); // init the console
ffffffffc0200066:	4da000ef          	jal	ffffffffc0200540 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006a:	00006597          	auipc	a1,0x6
ffffffffc020006e:	6fe58593          	addi	a1,a1,1790 # ffffffffc0206768 <etext+0x6>
ffffffffc0200072:	00006517          	auipc	a0,0x6
ffffffffc0200076:	71650513          	addi	a0,a0,1814 # ffffffffc0206788 <etext+0x26>
ffffffffc020007a:	11e000ef          	jal	ffffffffc0200198 <cprintf>

    print_kerninfo();
ffffffffc020007e:	1ac000ef          	jal	ffffffffc020022a <print_kerninfo>

    // grade_backtrace();

    dtb_init(); // init dtb
ffffffffc0200082:	530000ef          	jal	ffffffffc02005b2 <dtb_init>
    pmm_init(); // init physical memory management
ffffffffc0200086:	0dd020ef          	jal	ffffffffc0202962 <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	07b000ef          	jal	ffffffffc0200904 <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	079000ef          	jal	ffffffffc0200906 <idt_init>

    vmm_init(); // init virtual memory management
ffffffffc0200092:	175030ef          	jal	ffffffffc0203a06 <vmm_init>
    sched_init();
ffffffffc0200096:	487050ef          	jal	ffffffffc0205d1c <sched_init>
    proc_init(); // init process table
ffffffffc020009a:	0c5050ef          	jal	ffffffffc020595e <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009e:	45a000ef          	jal	ffffffffc02004f8 <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc02000a2:	057000ef          	jal	ffffffffc02008f8 <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a6:	259050ef          	jal	ffffffffc0205afe <cpu_idle>

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
ffffffffc02000be:	6d650513          	addi	a0,a0,1750 # ffffffffc0206790 <etext+0x2e>
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
ffffffffc020018c:	192060ef          	jal	ffffffffc020631e <vprintfmt>
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
ffffffffc02001c0:	15e060ef          	jal	ffffffffc020631e <vprintfmt>
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
ffffffffc0200230:	56c50513          	addi	a0,a0,1388 # ffffffffc0206798 <etext+0x36>
void print_kerninfo(void) {
ffffffffc0200234:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200236:	f63ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020023a:	00000597          	auipc	a1,0x0
ffffffffc020023e:	e1058593          	addi	a1,a1,-496 # ffffffffc020004a <kern_init>
ffffffffc0200242:	00006517          	auipc	a0,0x6
ffffffffc0200246:	57650513          	addi	a0,a0,1398 # ffffffffc02067b8 <etext+0x56>
ffffffffc020024a:	f4fff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020024e:	00006597          	auipc	a1,0x6
ffffffffc0200252:	51458593          	addi	a1,a1,1300 # ffffffffc0206762 <etext>
ffffffffc0200256:	00006517          	auipc	a0,0x6
ffffffffc020025a:	58250513          	addi	a0,a0,1410 # ffffffffc02067d8 <etext+0x76>
ffffffffc020025e:	f3bff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200262:	000c8597          	auipc	a1,0xc8
ffffffffc0200266:	ae658593          	addi	a1,a1,-1306 # ffffffffc02c7d48 <buf>
ffffffffc020026a:	00006517          	auipc	a0,0x6
ffffffffc020026e:	58e50513          	addi	a0,a0,1422 # ffffffffc02067f8 <etext+0x96>
ffffffffc0200272:	f27ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200276:	000cc597          	auipc	a1,0xcc
ffffffffc020027a:	10a58593          	addi	a1,a1,266 # ffffffffc02cc380 <end>
ffffffffc020027e:	00006517          	auipc	a0,0x6
ffffffffc0200282:	59a50513          	addi	a0,a0,1434 # ffffffffc0206818 <etext+0xb6>
ffffffffc0200286:	f13ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020028a:	00000717          	auipc	a4,0x0
ffffffffc020028e:	dc070713          	addi	a4,a4,-576 # ffffffffc020004a <kern_init>
ffffffffc0200292:	000cc797          	auipc	a5,0xcc
ffffffffc0200296:	4ed78793          	addi	a5,a5,1261 # ffffffffc02cc77f <end+0x3ff>
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
ffffffffc02002ae:	58e50513          	addi	a0,a0,1422 # ffffffffc0206838 <etext+0xd6>
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
ffffffffc02002bc:	5b060613          	addi	a2,a2,1456 # ffffffffc0206868 <etext+0x106>
ffffffffc02002c0:	04e00593          	li	a1,78
ffffffffc02002c4:	00006517          	auipc	a0,0x6
ffffffffc02002c8:	5bc50513          	addi	a0,a0,1468 # ffffffffc0206880 <etext+0x11e>
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
ffffffffc02002da:	00009417          	auipc	s0,0x9
ffffffffc02002de:	91640413          	addi	s0,s0,-1770 # ffffffffc0208bf0 <commands>
ffffffffc02002e2:	00009497          	auipc	s1,0x9
ffffffffc02002e6:	95648493          	addi	s1,s1,-1706 # ffffffffc0208c38 <commands+0x48>
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002ea:	6410                	ld	a2,8(s0)
ffffffffc02002ec:	600c                	ld	a1,0(s0)
ffffffffc02002ee:	00006517          	auipc	a0,0x6
ffffffffc02002f2:	5aa50513          	addi	a0,a0,1450 # ffffffffc0206898 <etext+0x136>
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
ffffffffc0200336:	57650513          	addi	a0,a0,1398 # ffffffffc02068a8 <etext+0x146>
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
ffffffffc020034e:	58650513          	addi	a0,a0,1414 # ffffffffc02068d0 <etext+0x16e>
ffffffffc0200352:	e47ff0ef          	jal	ffffffffc0200198 <cprintf>
    if (tf != NULL) {
ffffffffc0200356:	000a0563          	beqz	s4,ffffffffc0200360 <kmonitor+0x34>
        print_trapframe(tf);
ffffffffc020035a:	8552                	mv	a0,s4
ffffffffc020035c:	792000ef          	jal	ffffffffc0200aee <print_trapframe>
ffffffffc0200360:	00009a97          	auipc	s5,0x9
ffffffffc0200364:	890a8a93          	addi	s5,s5,-1904 # ffffffffc0208bf0 <commands>
        if (argc == MAXARGS - 1) {
ffffffffc0200368:	49bd                	li	s3,15
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020036a:	00006517          	auipc	a0,0x6
ffffffffc020036e:	58e50513          	addi	a0,a0,1422 # ffffffffc02068f8 <etext+0x196>
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
ffffffffc0200388:	00009497          	auipc	s1,0x9
ffffffffc020038c:	86848493          	addi	s1,s1,-1944 # ffffffffc0208bf0 <commands>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200390:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200392:	6582                	ld	a1,0(sp)
ffffffffc0200394:	6088                	ld	a0,0(s1)
ffffffffc0200396:	334060ef          	jal	ffffffffc02066ca <strcmp>
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
ffffffffc02003ac:	58050513          	addi	a0,a0,1408 # ffffffffc0206928 <etext+0x1c6>
ffffffffc02003b0:	de9ff0ef          	jal	ffffffffc0200198 <cprintf>
    return 0;
ffffffffc02003b4:	bf5d                	j	ffffffffc020036a <kmonitor+0x3e>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b6:	00006517          	auipc	a0,0x6
ffffffffc02003ba:	54a50513          	addi	a0,a0,1354 # ffffffffc0206900 <etext+0x19e>
ffffffffc02003be:	368060ef          	jal	ffffffffc0206726 <strchr>
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
ffffffffc02003fc:	50850513          	addi	a0,a0,1288 # ffffffffc0206900 <etext+0x19e>
ffffffffc0200400:	326060ef          	jal	ffffffffc0206726 <strchr>
ffffffffc0200404:	d575                	beqz	a0,ffffffffc02003f0 <kmonitor+0xc4>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200406:	00044583          	lbu	a1,0(s0)
ffffffffc020040a:	dda5                	beqz	a1,ffffffffc0200382 <kmonitor+0x56>
ffffffffc020040c:	b76d                	j	ffffffffc02003b6 <kmonitor+0x8a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020040e:	45c1                	li	a1,16
ffffffffc0200410:	00006517          	auipc	a0,0x6
ffffffffc0200414:	4f850513          	addi	a0,a0,1272 # ffffffffc0206908 <etext+0x1a6>
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
ffffffffc0200474:	56050513          	addi	a0,a0,1376 # ffffffffc02069d0 <etext+0x26e>
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
ffffffffc0200492:	56250513          	addi	a0,a0,1378 # ffffffffc02069f0 <etext+0x28e>
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
ffffffffc02004c6:	53650513          	addi	a0,a0,1334 # ffffffffc02069f8 <etext+0x296>
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
ffffffffc02004e8:	50c50513          	addi	a0,a0,1292 # ffffffffc02069f0 <etext+0x28e>
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
ffffffffc020051a:	50250513          	addi	a0,a0,1282 # ffffffffc0206a18 <etext+0x2b6>
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
ffffffffc02005b8:	48450513          	addi	a0,a0,1156 # ffffffffc0206a38 <etext+0x2d6>
void dtb_init(void) {
ffffffffc02005bc:	f406                	sd	ra,40(sp)
ffffffffc02005be:	f022                	sd	s0,32(sp)
    cprintf("DTB Init\n");
ffffffffc02005c0:	bd9ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc02005c4:	0000d597          	auipc	a1,0xd
ffffffffc02005c8:	a3c5b583          	ld	a1,-1476(a1) # ffffffffc020d000 <boot_hartid>
ffffffffc02005cc:	00006517          	auipc	a0,0x6
ffffffffc02005d0:	47c50513          	addi	a0,a0,1148 # ffffffffc0206a48 <etext+0x2e6>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc02005d4:	0000d417          	auipc	s0,0xd
ffffffffc02005d8:	a3440413          	addi	s0,s0,-1484 # ffffffffc020d008 <boot_dtb>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc02005dc:	bbdff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc02005e0:	600c                	ld	a1,0(s0)
ffffffffc02005e2:	00006517          	auipc	a0,0x6
ffffffffc02005e6:	47650513          	addi	a0,a0,1142 # ffffffffc0206a58 <etext+0x2f6>
ffffffffc02005ea:	bafff0ef          	jal	ffffffffc0200198 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc02005ee:	6018                	ld	a4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc02005f0:	00006517          	auipc	a0,0x6
ffffffffc02005f4:	48050513          	addi	a0,a0,1152 # ffffffffc0206a70 <etext+0x30e>
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
ffffffffc0200608:	eed68693          	addi	a3,a3,-275 # ffffffffd00dfeed <end+0xfe13b6d>
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
ffffffffc02006e6:	45650513          	addi	a0,a0,1110 # ffffffffc0206b38 <etext+0x3d6>
ffffffffc02006ea:	aafff0ef          	jal	ffffffffc0200198 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc02006ee:	64e2                	ld	s1,24(sp)
ffffffffc02006f0:	6942                	ld	s2,16(sp)
ffffffffc02006f2:	00006517          	auipc	a0,0x6
ffffffffc02006f6:	47e50513          	addi	a0,a0,1150 # ffffffffc0206b70 <etext+0x40e>
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
ffffffffc020070a:	38a50513          	addi	a0,a0,906 # ffffffffc0206a90 <etext+0x32e>
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
ffffffffc020074c:	739050ef          	jal	ffffffffc0206684 <strlen>
ffffffffc0200750:	84aa                	mv	s1,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200752:	4619                	li	a2,6
ffffffffc0200754:	8522                	mv	a0,s0
ffffffffc0200756:	00006597          	auipc	a1,0x6
ffffffffc020075a:	36258593          	addi	a1,a1,866 # ffffffffc0206ab8 <etext+0x356>
ffffffffc020075e:	7a1050ef          	jal	ffffffffc02066fe <strncmp>
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
ffffffffc0200786:	33e58593          	addi	a1,a1,830 # ffffffffc0206ac0 <etext+0x35e>
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
ffffffffc02007b8:	713050ef          	jal	ffffffffc02066ca <strcmp>
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
ffffffffc02007dc:	2f050513          	addi	a0,a0,752 # ffffffffc0206ac8 <etext+0x366>
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
ffffffffc02008a6:	24650513          	addi	a0,a0,582 # ffffffffc0206ae8 <etext+0x386>
ffffffffc02008aa:	8efff0ef          	jal	ffffffffc0200198 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc02008ae:	01445613          	srli	a2,s0,0x14
ffffffffc02008b2:	85a2                	mv	a1,s0
ffffffffc02008b4:	00006517          	auipc	a0,0x6
ffffffffc02008b8:	24c50513          	addi	a0,a0,588 # ffffffffc0206b00 <etext+0x39e>
ffffffffc02008bc:	8ddff0ef          	jal	ffffffffc0200198 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc02008c0:	009405b3          	add	a1,s0,s1
ffffffffc02008c4:	15fd                	addi	a1,a1,-1
ffffffffc02008c6:	00006517          	auipc	a0,0x6
ffffffffc02008ca:	25a50513          	addi	a0,a0,602 # ffffffffc0206b20 <etext+0x3be>
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
ffffffffc020090e:	5be78793          	addi	a5,a5,1470 # ffffffffc0200ec8 <__alltraps>
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
ffffffffc020092c:	26050513          	addi	a0,a0,608 # ffffffffc0206b88 <etext+0x426>
{
ffffffffc0200930:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200932:	867ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200936:	640c                	ld	a1,8(s0)
ffffffffc0200938:	00006517          	auipc	a0,0x6
ffffffffc020093c:	26850513          	addi	a0,a0,616 # ffffffffc0206ba0 <etext+0x43e>
ffffffffc0200940:	859ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200944:	680c                	ld	a1,16(s0)
ffffffffc0200946:	00006517          	auipc	a0,0x6
ffffffffc020094a:	27250513          	addi	a0,a0,626 # ffffffffc0206bb8 <etext+0x456>
ffffffffc020094e:	84bff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200952:	6c0c                	ld	a1,24(s0)
ffffffffc0200954:	00006517          	auipc	a0,0x6
ffffffffc0200958:	27c50513          	addi	a0,a0,636 # ffffffffc0206bd0 <etext+0x46e>
ffffffffc020095c:	83dff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200960:	700c                	ld	a1,32(s0)
ffffffffc0200962:	00006517          	auipc	a0,0x6
ffffffffc0200966:	28650513          	addi	a0,a0,646 # ffffffffc0206be8 <etext+0x486>
ffffffffc020096a:	82fff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc020096e:	740c                	ld	a1,40(s0)
ffffffffc0200970:	00006517          	auipc	a0,0x6
ffffffffc0200974:	29050513          	addi	a0,a0,656 # ffffffffc0206c00 <etext+0x49e>
ffffffffc0200978:	821ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc020097c:	780c                	ld	a1,48(s0)
ffffffffc020097e:	00006517          	auipc	a0,0x6
ffffffffc0200982:	29a50513          	addi	a0,a0,666 # ffffffffc0206c18 <etext+0x4b6>
ffffffffc0200986:	813ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc020098a:	7c0c                	ld	a1,56(s0)
ffffffffc020098c:	00006517          	auipc	a0,0x6
ffffffffc0200990:	2a450513          	addi	a0,a0,676 # ffffffffc0206c30 <etext+0x4ce>
ffffffffc0200994:	805ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200998:	602c                	ld	a1,64(s0)
ffffffffc020099a:	00006517          	auipc	a0,0x6
ffffffffc020099e:	2ae50513          	addi	a0,a0,686 # ffffffffc0206c48 <etext+0x4e6>
ffffffffc02009a2:	ff6ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02009a6:	642c                	ld	a1,72(s0)
ffffffffc02009a8:	00006517          	auipc	a0,0x6
ffffffffc02009ac:	2b850513          	addi	a0,a0,696 # ffffffffc0206c60 <etext+0x4fe>
ffffffffc02009b0:	fe8ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02009b4:	682c                	ld	a1,80(s0)
ffffffffc02009b6:	00006517          	auipc	a0,0x6
ffffffffc02009ba:	2c250513          	addi	a0,a0,706 # ffffffffc0206c78 <etext+0x516>
ffffffffc02009be:	fdaff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02009c2:	6c2c                	ld	a1,88(s0)
ffffffffc02009c4:	00006517          	auipc	a0,0x6
ffffffffc02009c8:	2cc50513          	addi	a0,a0,716 # ffffffffc0206c90 <etext+0x52e>
ffffffffc02009cc:	fccff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02009d0:	702c                	ld	a1,96(s0)
ffffffffc02009d2:	00006517          	auipc	a0,0x6
ffffffffc02009d6:	2d650513          	addi	a0,a0,726 # ffffffffc0206ca8 <etext+0x546>
ffffffffc02009da:	fbeff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc02009de:	742c                	ld	a1,104(s0)
ffffffffc02009e0:	00006517          	auipc	a0,0x6
ffffffffc02009e4:	2e050513          	addi	a0,a0,736 # ffffffffc0206cc0 <etext+0x55e>
ffffffffc02009e8:	fb0ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc02009ec:	782c                	ld	a1,112(s0)
ffffffffc02009ee:	00006517          	auipc	a0,0x6
ffffffffc02009f2:	2ea50513          	addi	a0,a0,746 # ffffffffc0206cd8 <etext+0x576>
ffffffffc02009f6:	fa2ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc02009fa:	7c2c                	ld	a1,120(s0)
ffffffffc02009fc:	00006517          	auipc	a0,0x6
ffffffffc0200a00:	2f450513          	addi	a0,a0,756 # ffffffffc0206cf0 <etext+0x58e>
ffffffffc0200a04:	f94ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200a08:	604c                	ld	a1,128(s0)
ffffffffc0200a0a:	00006517          	auipc	a0,0x6
ffffffffc0200a0e:	2fe50513          	addi	a0,a0,766 # ffffffffc0206d08 <etext+0x5a6>
ffffffffc0200a12:	f86ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200a16:	644c                	ld	a1,136(s0)
ffffffffc0200a18:	00006517          	auipc	a0,0x6
ffffffffc0200a1c:	30850513          	addi	a0,a0,776 # ffffffffc0206d20 <etext+0x5be>
ffffffffc0200a20:	f78ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200a24:	684c                	ld	a1,144(s0)
ffffffffc0200a26:	00006517          	auipc	a0,0x6
ffffffffc0200a2a:	31250513          	addi	a0,a0,786 # ffffffffc0206d38 <etext+0x5d6>
ffffffffc0200a2e:	f6aff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200a32:	6c4c                	ld	a1,152(s0)
ffffffffc0200a34:	00006517          	auipc	a0,0x6
ffffffffc0200a38:	31c50513          	addi	a0,a0,796 # ffffffffc0206d50 <etext+0x5ee>
ffffffffc0200a3c:	f5cff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200a40:	704c                	ld	a1,160(s0)
ffffffffc0200a42:	00006517          	auipc	a0,0x6
ffffffffc0200a46:	32650513          	addi	a0,a0,806 # ffffffffc0206d68 <etext+0x606>
ffffffffc0200a4a:	f4eff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200a4e:	744c                	ld	a1,168(s0)
ffffffffc0200a50:	00006517          	auipc	a0,0x6
ffffffffc0200a54:	33050513          	addi	a0,a0,816 # ffffffffc0206d80 <etext+0x61e>
ffffffffc0200a58:	f40ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200a5c:	784c                	ld	a1,176(s0)
ffffffffc0200a5e:	00006517          	auipc	a0,0x6
ffffffffc0200a62:	33a50513          	addi	a0,a0,826 # ffffffffc0206d98 <etext+0x636>
ffffffffc0200a66:	f32ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200a6a:	7c4c                	ld	a1,184(s0)
ffffffffc0200a6c:	00006517          	auipc	a0,0x6
ffffffffc0200a70:	34450513          	addi	a0,a0,836 # ffffffffc0206db0 <etext+0x64e>
ffffffffc0200a74:	f24ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200a78:	606c                	ld	a1,192(s0)
ffffffffc0200a7a:	00006517          	auipc	a0,0x6
ffffffffc0200a7e:	34e50513          	addi	a0,a0,846 # ffffffffc0206dc8 <etext+0x666>
ffffffffc0200a82:	f16ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200a86:	646c                	ld	a1,200(s0)
ffffffffc0200a88:	00006517          	auipc	a0,0x6
ffffffffc0200a8c:	35850513          	addi	a0,a0,856 # ffffffffc0206de0 <etext+0x67e>
ffffffffc0200a90:	f08ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200a94:	686c                	ld	a1,208(s0)
ffffffffc0200a96:	00006517          	auipc	a0,0x6
ffffffffc0200a9a:	36250513          	addi	a0,a0,866 # ffffffffc0206df8 <etext+0x696>
ffffffffc0200a9e:	efaff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200aa2:	6c6c                	ld	a1,216(s0)
ffffffffc0200aa4:	00006517          	auipc	a0,0x6
ffffffffc0200aa8:	36c50513          	addi	a0,a0,876 # ffffffffc0206e10 <etext+0x6ae>
ffffffffc0200aac:	eecff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200ab0:	706c                	ld	a1,224(s0)
ffffffffc0200ab2:	00006517          	auipc	a0,0x6
ffffffffc0200ab6:	37650513          	addi	a0,a0,886 # ffffffffc0206e28 <etext+0x6c6>
ffffffffc0200aba:	edeff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200abe:	746c                	ld	a1,232(s0)
ffffffffc0200ac0:	00006517          	auipc	a0,0x6
ffffffffc0200ac4:	38050513          	addi	a0,a0,896 # ffffffffc0206e40 <etext+0x6de>
ffffffffc0200ac8:	ed0ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200acc:	786c                	ld	a1,240(s0)
ffffffffc0200ace:	00006517          	auipc	a0,0x6
ffffffffc0200ad2:	38a50513          	addi	a0,a0,906 # ffffffffc0206e58 <etext+0x6f6>
ffffffffc0200ad6:	ec2ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200ada:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200adc:	6402                	ld	s0,0(sp)
ffffffffc0200ade:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200ae0:	00006517          	auipc	a0,0x6
ffffffffc0200ae4:	39050513          	addi	a0,a0,912 # ffffffffc0206e70 <etext+0x70e>
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
ffffffffc0200afa:	39250513          	addi	a0,a0,914 # ffffffffc0206e88 <etext+0x726>
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
ffffffffc0200b12:	39250513          	addi	a0,a0,914 # ffffffffc0206ea0 <etext+0x73e>
ffffffffc0200b16:	e82ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200b1a:	10843583          	ld	a1,264(s0)
ffffffffc0200b1e:	00006517          	auipc	a0,0x6
ffffffffc0200b22:	39a50513          	addi	a0,a0,922 # ffffffffc0206eb8 <etext+0x756>
ffffffffc0200b26:	e72ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200b2a:	11043583          	ld	a1,272(s0)
ffffffffc0200b2e:	00006517          	auipc	a0,0x6
ffffffffc0200b32:	3a250513          	addi	a0,a0,930 # ffffffffc0206ed0 <etext+0x76e>
ffffffffc0200b36:	e62ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b3a:	11843583          	ld	a1,280(s0)
}
ffffffffc0200b3e:	6402                	ld	s0,0(sp)
ffffffffc0200b40:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b42:	00006517          	auipc	a0,0x6
ffffffffc0200b46:	39e50513          	addi	a0,a0,926 # ffffffffc0206ee0 <etext+0x77e>
}
ffffffffc0200b4a:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b4c:	e4cff06f          	j	ffffffffc0200198 <cprintf>

ffffffffc0200b50 <pgfault_handler>:
void kernel_execve_ret(struct trapframe *tf, uintptr_t kstacktop);

static int pgfault_handler(struct trapframe *tf) {
    extern struct mm_struct *check_mm_struct;
    struct mm_struct *mm;
    if (check_mm_struct != NULL) {
ffffffffc0200b50:	000cb797          	auipc	a5,0xcb
ffffffffc0200b54:	7f87b783          	ld	a5,2040(a5) # ffffffffc02cc348 <check_mm_struct>
static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200b58:	1101                	addi	sp,sp,-32
ffffffffc0200b5a:	ec06                	sd	ra,24(sp)
        assert(current == idleproc);
ffffffffc0200b5c:	000cb697          	auipc	a3,0xcb
ffffffffc0200b60:	7fc6b683          	ld	a3,2044(a3) # ffffffffc02cc358 <current>
static int pgfault_handler(struct trapframe *tf) {
ffffffffc0200b64:	872a                	mv	a4,a0
    if (check_mm_struct != NULL) {
ffffffffc0200b66:	c385                	beqz	a5,ffffffffc0200b86 <pgfault_handler+0x36>
        assert(current == idleproc);
ffffffffc0200b68:	000cc617          	auipc	a2,0xcc
ffffffffc0200b6c:	80063603          	ld	a2,-2048(a2) # ffffffffc02cc368 <idleproc>
ffffffffc0200b70:	02d61663          	bne	a2,a3,ffffffffc0200b9c <pgfault_handler+0x4c>
            panic("unhandled page fault.\n");
        }
        mm = current->mm;
    }
    return do_pgfault(mm, tf->cause, tf->tval);
}
ffffffffc0200b74:	60e2                	ld	ra,24(sp)
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200b76:	11073603          	ld	a2,272(a4)
ffffffffc0200b7a:	11873583          	ld	a1,280(a4)
ffffffffc0200b7e:	853e                	mv	a0,a5
}
ffffffffc0200b80:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200b82:	2500306f          	j	ffffffffc0203dd2 <do_pgfault>
        if (current == NULL) {
ffffffffc0200b86:	ca9d                	beqz	a3,ffffffffc0200bbc <pgfault_handler+0x6c>
        mm = current->mm;
ffffffffc0200b88:	769c                	ld	a5,40(a3)
}
ffffffffc0200b8a:	60e2                	ld	ra,24(sp)
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200b8c:	11073603          	ld	a2,272(a4)
ffffffffc0200b90:	11873583          	ld	a1,280(a4)
ffffffffc0200b94:	853e                	mv	a0,a5
}
ffffffffc0200b96:	6105                	addi	sp,sp,32
    return do_pgfault(mm, tf->cause, tf->tval);
ffffffffc0200b98:	23a0306f          	j	ffffffffc0203dd2 <do_pgfault>
        assert(current == idleproc);
ffffffffc0200b9c:	00006697          	auipc	a3,0x6
ffffffffc0200ba0:	35c68693          	addi	a3,a3,860 # ffffffffc0206ef8 <etext+0x796>
ffffffffc0200ba4:	00006617          	auipc	a2,0x6
ffffffffc0200ba8:	36c60613          	addi	a2,a2,876 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0200bac:	09d00593          	li	a1,157
ffffffffc0200bb0:	00006517          	auipc	a0,0x6
ffffffffc0200bb4:	37850513          	addi	a0,a0,888 # ffffffffc0206f28 <etext+0x7c6>
ffffffffc0200bb8:	893ff0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0200bbc:	e42a                	sd	a0,8(sp)
            print_trapframe(tf);
ffffffffc0200bbe:	f31ff0ef          	jal	ffffffffc0200aee <print_trapframe>
            print_regs(&tf->gpr);
ffffffffc0200bc2:	6522                	ld	a0,8(sp)
ffffffffc0200bc4:	d5dff0ef          	jal	ffffffffc0200920 <print_regs>
            panic("unhandled page fault.\n");
ffffffffc0200bc8:	00006617          	auipc	a2,0x6
ffffffffc0200bcc:	37860613          	addi	a2,a2,888 # ffffffffc0206f40 <etext+0x7de>
ffffffffc0200bd0:	0a400593          	li	a1,164
ffffffffc0200bd4:	00006517          	auipc	a0,0x6
ffffffffc0200bd8:	35450513          	addi	a0,a0,852 # ffffffffc0206f28 <etext+0x7c6>
ffffffffc0200bdc:	86fff0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0200be0 <interrupt_handler>:
    switch (cause)
ffffffffc0200be0:	11853783          	ld	a5,280(a0)
ffffffffc0200be4:	472d                	li	a4,11
ffffffffc0200be6:	0786                	slli	a5,a5,0x1
ffffffffc0200be8:	8385                	srli	a5,a5,0x1
ffffffffc0200bea:	06f76a63          	bltu	a4,a5,ffffffffc0200c5e <interrupt_handler+0x7e>
ffffffffc0200bee:	00008717          	auipc	a4,0x8
ffffffffc0200bf2:	04a70713          	addi	a4,a4,74 # ffffffffc0208c38 <commands+0x48>
ffffffffc0200bf6:	078a                	slli	a5,a5,0x2
ffffffffc0200bf8:	97ba                	add	a5,a5,a4
ffffffffc0200bfa:	439c                	lw	a5,0(a5)
ffffffffc0200bfc:	97ba                	add	a5,a5,a4
ffffffffc0200bfe:	8782                	jr	a5
        cprintf("Machine software interrupt\n");
ffffffffc0200c00:	00006517          	auipc	a0,0x6
ffffffffc0200c04:	3b850513          	addi	a0,a0,952 # ffffffffc0206fb8 <etext+0x856>
ffffffffc0200c08:	d90ff06f          	j	ffffffffc0200198 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200c0c:	00006517          	auipc	a0,0x6
ffffffffc0200c10:	38c50513          	addi	a0,a0,908 # ffffffffc0206f98 <etext+0x836>
ffffffffc0200c14:	d84ff06f          	j	ffffffffc0200198 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200c18:	00006517          	auipc	a0,0x6
ffffffffc0200c1c:	34050513          	addi	a0,a0,832 # ffffffffc0206f58 <etext+0x7f6>
ffffffffc0200c20:	d78ff06f          	j	ffffffffc0200198 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200c24:	00006517          	auipc	a0,0x6
ffffffffc0200c28:	35450513          	addi	a0,a0,852 # ffffffffc0206f78 <etext+0x816>
ffffffffc0200c2c:	d6cff06f          	j	ffffffffc0200198 <cprintf>
{
ffffffffc0200c30:	1141                	addi	sp,sp,-16
ffffffffc0200c32:	e406                	sd	ra,8(sp)
        clock_set_next_event();
ffffffffc0200c34:	8f5ff0ef          	jal	ffffffffc0200528 <clock_set_next_event>
        ++ticks;
ffffffffc0200c38:	000cb797          	auipc	a5,0xcb
ffffffffc0200c3c:	6c07b783          	ld	a5,1728(a5) # ffffffffc02cc2f8 <ticks>
}
ffffffffc0200c40:	60a2                	ld	ra,8(sp)
        ++ticks;
ffffffffc0200c42:	0785                	addi	a5,a5,1
ffffffffc0200c44:	000cb717          	auipc	a4,0xcb
ffffffffc0200c48:	6af73a23          	sd	a5,1716(a4) # ffffffffc02cc2f8 <ticks>
}
ffffffffc0200c4c:	0141                	addi	sp,sp,16
        run_timer_list();
ffffffffc0200c4e:	4240506f          	j	ffffffffc0206072 <run_timer_list>
        cprintf("Supervisor external interrupt\n");
ffffffffc0200c52:	00006517          	auipc	a0,0x6
ffffffffc0200c56:	38650513          	addi	a0,a0,902 # ffffffffc0206fd8 <etext+0x876>
ffffffffc0200c5a:	d3eff06f          	j	ffffffffc0200198 <cprintf>
        print_trapframe(tf);
ffffffffc0200c5e:	bd41                	j	ffffffffc0200aee <print_trapframe>

ffffffffc0200c60 <exception_handler>:

void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200c60:	11853783          	ld	a5,280(a0)
ffffffffc0200c64:	473d                	li	a4,15
ffffffffc0200c66:	1af76c63          	bltu	a4,a5,ffffffffc0200e1e <exception_handler+0x1be>
ffffffffc0200c6a:	00008717          	auipc	a4,0x8
ffffffffc0200c6e:	ffe70713          	addi	a4,a4,-2 # ffffffffc0208c68 <commands+0x78>
ffffffffc0200c72:	078a                	slli	a5,a5,0x2
ffffffffc0200c74:	97ba                	add	a5,a5,a4
ffffffffc0200c76:	439c                	lw	a5,0(a5)
{
ffffffffc0200c78:	1101                	addi	sp,sp,-32
ffffffffc0200c7a:	ec06                	sd	ra,24(sp)
    switch (tf->cause)
ffffffffc0200c7c:	97ba                	add	a5,a5,a4
ffffffffc0200c7e:	862a                	mv	a2,a0
ffffffffc0200c80:	8782                	jr	a5
ffffffffc0200c82:	e42a                	sd	a0,8(sp)
        // cprintf("Environment call from U-mode\n");
        tf->epc += 4;
        syscall();
        break;
    case CAUSE_SUPERVISOR_ECALL:
        cprintf("Environment call from S-mode\n");
ffffffffc0200c84:	00006517          	auipc	a0,0x6
ffffffffc0200c88:	47450513          	addi	a0,a0,1140 # ffffffffc02070f8 <etext+0x996>
ffffffffc0200c8c:	d0cff0ef          	jal	ffffffffc0200198 <cprintf>
        tf->epc += 4;
ffffffffc0200c90:	6622                	ld	a2,8(sp)
ffffffffc0200c92:	10863783          	ld	a5,264(a2)
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200c96:	60e2                	ld	ra,24(sp)
        tf->epc += 4;
ffffffffc0200c98:	0791                	addi	a5,a5,4
ffffffffc0200c9a:	10f63423          	sd	a5,264(a2)
}
ffffffffc0200c9e:	6105                	addi	sp,sp,32
        syscall();
ffffffffc0200ca0:	5840506f          	j	ffffffffc0206224 <syscall>
}
ffffffffc0200ca4:	60e2                	ld	ra,24(sp)
        cprintf("Environment call from H-mode\n");
ffffffffc0200ca6:	00006517          	auipc	a0,0x6
ffffffffc0200caa:	47250513          	addi	a0,a0,1138 # ffffffffc0207118 <etext+0x9b6>
}
ffffffffc0200cae:	6105                	addi	sp,sp,32
        cprintf("Environment call from H-mode\n");
ffffffffc0200cb0:	ce8ff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200cb4:	60e2                	ld	ra,24(sp)
        cprintf("Environment call from M-mode\n");
ffffffffc0200cb6:	00006517          	auipc	a0,0x6
ffffffffc0200cba:	48250513          	addi	a0,a0,1154 # ffffffffc0207138 <etext+0x9d6>
}
ffffffffc0200cbe:	6105                	addi	sp,sp,32
        cprintf("Environment call from M-mode\n");
ffffffffc0200cc0:	cd8ff06f          	j	ffffffffc0200198 <cprintf>
ffffffffc0200cc4:	e42a                	sd	a0,8(sp)
        cprintf("Instruction page fault\n");
ffffffffc0200cc6:	00006517          	auipc	a0,0x6
ffffffffc0200cca:	49250513          	addi	a0,a0,1170 # ffffffffc0207158 <etext+0x9f6>
ffffffffc0200cce:	ccaff0ef          	jal	ffffffffc0200198 <cprintf>
        if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200cd2:	6522                	ld	a0,8(sp)
ffffffffc0200cd4:	e7dff0ef          	jal	ffffffffc0200b50 <pgfault_handler>
ffffffffc0200cd8:	6622                	ld	a2,8(sp)
ffffffffc0200cda:	14051363          	bnez	a0,ffffffffc0200e20 <exception_handler+0x1c0>
}
ffffffffc0200cde:	60e2                	ld	ra,24(sp)
ffffffffc0200ce0:	6105                	addi	sp,sp,32
ffffffffc0200ce2:	8082                	ret
ffffffffc0200ce4:	e42a                	sd	a0,8(sp)
        cprintf("Load page fault\n");
ffffffffc0200ce6:	00006517          	auipc	a0,0x6
ffffffffc0200cea:	4aa50513          	addi	a0,a0,1194 # ffffffffc0207190 <etext+0xa2e>
ffffffffc0200cee:	caaff0ef          	jal	ffffffffc0200198 <cprintf>
        if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200cf2:	6522                	ld	a0,8(sp)
ffffffffc0200cf4:	e5dff0ef          	jal	ffffffffc0200b50 <pgfault_handler>
ffffffffc0200cf8:	6622                	ld	a2,8(sp)
ffffffffc0200cfa:	d175                	beqz	a0,ffffffffc0200cde <exception_handler+0x7e>
ffffffffc0200cfc:	e42a                	sd	a0,8(sp)
            print_trapframe(tf);
ffffffffc0200cfe:	8532                	mv	a0,a2
ffffffffc0200d00:	defff0ef          	jal	ffffffffc0200aee <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
ffffffffc0200d04:	66a2                	ld	a3,8(sp)
ffffffffc0200d06:	00006617          	auipc	a2,0x6
ffffffffc0200d0a:	46a60613          	addi	a2,a2,1130 # ffffffffc0207170 <etext+0xa0e>
ffffffffc0200d0e:	0e800593          	li	a1,232
ffffffffc0200d12:	00006517          	auipc	a0,0x6
ffffffffc0200d16:	21650513          	addi	a0,a0,534 # ffffffffc0206f28 <etext+0x7c6>
ffffffffc0200d1a:	f30ff0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0200d1e:	e42a                	sd	a0,8(sp)
        cprintf("Store/AMO page fault\n");
ffffffffc0200d20:	00006517          	auipc	a0,0x6
ffffffffc0200d24:	48850513          	addi	a0,a0,1160 # ffffffffc02071a8 <etext+0xa46>
ffffffffc0200d28:	c70ff0ef          	jal	ffffffffc0200198 <cprintf>
        if ((ret = pgfault_handler(tf)) != 0) {
ffffffffc0200d2c:	6522                	ld	a0,8(sp)
ffffffffc0200d2e:	e23ff0ef          	jal	ffffffffc0200b50 <pgfault_handler>
ffffffffc0200d32:	6622                	ld	a2,8(sp)
ffffffffc0200d34:	d54d                	beqz	a0,ffffffffc0200cde <exception_handler+0x7e>
ffffffffc0200d36:	e42a                	sd	a0,8(sp)
            print_trapframe(tf);
ffffffffc0200d38:	8532                	mv	a0,a2
ffffffffc0200d3a:	db5ff0ef          	jal	ffffffffc0200aee <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
ffffffffc0200d3e:	66a2                	ld	a3,8(sp)
ffffffffc0200d40:	00006617          	auipc	a2,0x6
ffffffffc0200d44:	43060613          	addi	a2,a2,1072 # ffffffffc0207170 <etext+0xa0e>
ffffffffc0200d48:	0ef00593          	li	a1,239
ffffffffc0200d4c:	00006517          	auipc	a0,0x6
ffffffffc0200d50:	1dc50513          	addi	a0,a0,476 # ffffffffc0206f28 <etext+0x7c6>
ffffffffc0200d54:	ef6ff0ef          	jal	ffffffffc020044a <__panic>
}
ffffffffc0200d58:	60e2                	ld	ra,24(sp)
        cprintf("Instruction address misaligned\n");
ffffffffc0200d5a:	00006517          	auipc	a0,0x6
ffffffffc0200d5e:	29e50513          	addi	a0,a0,670 # ffffffffc0206ff8 <etext+0x896>
}
ffffffffc0200d62:	6105                	addi	sp,sp,32
        cprintf("Instruction address misaligned\n");
ffffffffc0200d64:	c34ff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200d68:	60e2                	ld	ra,24(sp)
        cprintf("Instruction access fault\n");
ffffffffc0200d6a:	00006517          	auipc	a0,0x6
ffffffffc0200d6e:	2ae50513          	addi	a0,a0,686 # ffffffffc0207018 <etext+0x8b6>
}
ffffffffc0200d72:	6105                	addi	sp,sp,32
        cprintf("Instruction access fault\n");
ffffffffc0200d74:	c24ff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200d78:	60e2                	ld	ra,24(sp)
        cprintf("Breakpoint\n");
ffffffffc0200d7a:	00006517          	auipc	a0,0x6
ffffffffc0200d7e:	30650513          	addi	a0,a0,774 # ffffffffc0207080 <etext+0x91e>
}
ffffffffc0200d82:	6105                	addi	sp,sp,32
        cprintf("Breakpoint\n");
ffffffffc0200d84:	c14ff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200d88:	60e2                	ld	ra,24(sp)
        cprintf("Load address misaligned\n");
ffffffffc0200d8a:	00006517          	auipc	a0,0x6
ffffffffc0200d8e:	30650513          	addi	a0,a0,774 # ffffffffc0207090 <etext+0x92e>
}
ffffffffc0200d92:	6105                	addi	sp,sp,32
        cprintf("Load address misaligned\n");
ffffffffc0200d94:	c04ff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200d98:	60e2                	ld	ra,24(sp)
        cprintf("Load access fault\n");
ffffffffc0200d9a:	00006517          	auipc	a0,0x6
ffffffffc0200d9e:	31650513          	addi	a0,a0,790 # ffffffffc02070b0 <etext+0x94e>
}
ffffffffc0200da2:	6105                	addi	sp,sp,32
        cprintf("Load access fault\n");
ffffffffc0200da4:	bf4ff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200da8:	60e2                	ld	ra,24(sp)
        cprintf("Store/AMO access fault\n");
ffffffffc0200daa:	00006517          	auipc	a0,0x6
ffffffffc0200dae:	33650513          	addi	a0,a0,822 # ffffffffc02070e0 <etext+0x97e>
}
ffffffffc0200db2:	6105                	addi	sp,sp,32
        cprintf("Store/AMO access fault\n");
ffffffffc0200db4:	be4ff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200db8:	60e2                	ld	ra,24(sp)
ffffffffc0200dba:	6105                	addi	sp,sp,32
        print_trapframe(tf);
ffffffffc0200dbc:	bb0d                	j	ffffffffc0200aee <print_trapframe>
        cprintf("Illegal instruction\n");
ffffffffc0200dbe:	e42a                	sd	a0,8(sp)
ffffffffc0200dc0:	00006517          	auipc	a0,0x6
ffffffffc0200dc4:	27850513          	addi	a0,a0,632 # ffffffffc0207038 <etext+0x8d6>
ffffffffc0200dc8:	bd0ff0ef          	jal	ffffffffc0200198 <cprintf>
        print_trapframe(tf);
ffffffffc0200dcc:	6522                	ld	a0,8(sp)
ffffffffc0200dce:	d21ff0ef          	jal	ffffffffc0200aee <print_trapframe>
        if (current != NULL) {
ffffffffc0200dd2:	000cb617          	auipc	a2,0xcb
ffffffffc0200dd6:	58663603          	ld	a2,1414(a2) # ffffffffc02cc358 <current>
ffffffffc0200dda:	ca11                	beqz	a2,ffffffffc0200dee <exception_handler+0x18e>
            cprintf("Current process: %d %s\n", current->pid, current->name);
ffffffffc0200ddc:	424c                	lw	a1,4(a2)
ffffffffc0200dde:	00006517          	auipc	a0,0x6
ffffffffc0200de2:	27250513          	addi	a0,a0,626 # ffffffffc0207050 <etext+0x8ee>
ffffffffc0200de6:	0b460613          	addi	a2,a2,180
ffffffffc0200dea:	baeff0ef          	jal	ffffffffc0200198 <cprintf>
        panic("Illegal instruction");
ffffffffc0200dee:	00006617          	auipc	a2,0x6
ffffffffc0200df2:	27a60613          	addi	a2,a2,634 # ffffffffc0207068 <etext+0x906>
ffffffffc0200df6:	0bc00593          	li	a1,188
ffffffffc0200dfa:	00006517          	auipc	a0,0x6
ffffffffc0200dfe:	12e50513          	addi	a0,a0,302 # ffffffffc0206f28 <etext+0x7c6>
ffffffffc0200e02:	e48ff0ef          	jal	ffffffffc020044a <__panic>
        panic("AMO address misaligned\n");
ffffffffc0200e06:	00006617          	auipc	a2,0x6
ffffffffc0200e0a:	2c260613          	addi	a2,a2,706 # ffffffffc02070c8 <etext+0x966>
ffffffffc0200e0e:	0c800593          	li	a1,200
ffffffffc0200e12:	00006517          	auipc	a0,0x6
ffffffffc0200e16:	11650513          	addi	a0,a0,278 # ffffffffc0206f28 <etext+0x7c6>
ffffffffc0200e1a:	e30ff0ef          	jal	ffffffffc020044a <__panic>
        print_trapframe(tf);
ffffffffc0200e1e:	b9c1                	j	ffffffffc0200aee <print_trapframe>
ffffffffc0200e20:	e42a                	sd	a0,8(sp)
            print_trapframe(tf);
ffffffffc0200e22:	8532                	mv	a0,a2
ffffffffc0200e24:	ccbff0ef          	jal	ffffffffc0200aee <print_trapframe>
            panic("handle pgfault failed. %e\n", ret);
ffffffffc0200e28:	66a2                	ld	a3,8(sp)
ffffffffc0200e2a:	00006617          	auipc	a2,0x6
ffffffffc0200e2e:	34660613          	addi	a2,a2,838 # ffffffffc0207170 <etext+0xa0e>
ffffffffc0200e32:	0e100593          	li	a1,225
ffffffffc0200e36:	00006517          	auipc	a0,0x6
ffffffffc0200e3a:	0f250513          	addi	a0,a0,242 # ffffffffc0206f28 <etext+0x7c6>
ffffffffc0200e3e:	e0cff0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0200e42 <trap>:
 * */
void trap(struct trapframe *tf)
{
    // dispatch based on what type of trap occurred
    //    cputs("some trap");
    if (current == NULL)
ffffffffc0200e42:	000cb717          	auipc	a4,0xcb
ffffffffc0200e46:	51673703          	ld	a4,1302(a4) # ffffffffc02cc358 <current>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200e4a:	11853583          	ld	a1,280(a0)
    if (current == NULL)
ffffffffc0200e4e:	cf21                	beqz	a4,ffffffffc0200ea6 <trap+0x64>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200e50:	10053603          	ld	a2,256(a0)
    {
        trap_dispatch(tf);
    }
    else
    {
        struct trapframe *otf = current->tf;
ffffffffc0200e54:	0a073803          	ld	a6,160(a4)
{
ffffffffc0200e58:	1101                	addi	sp,sp,-32
ffffffffc0200e5a:	ec06                	sd	ra,24(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200e5c:	10067613          	andi	a2,a2,256
        current->tf = tf;
ffffffffc0200e60:	f348                	sd	a0,160(a4)
    if ((intptr_t)tf->cause < 0)
ffffffffc0200e62:	e432                	sd	a2,8(sp)
ffffffffc0200e64:	e042                	sd	a6,0(sp)
ffffffffc0200e66:	0205c763          	bltz	a1,ffffffffc0200e94 <trap+0x52>
        exception_handler(tf);
ffffffffc0200e6a:	df7ff0ef          	jal	ffffffffc0200c60 <exception_handler>
ffffffffc0200e6e:	6622                	ld	a2,8(sp)
ffffffffc0200e70:	6802                	ld	a6,0(sp)
ffffffffc0200e72:	000cb697          	auipc	a3,0xcb
ffffffffc0200e76:	4e668693          	addi	a3,a3,1254 # ffffffffc02cc358 <current>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200e7a:	6298                	ld	a4,0(a3)
ffffffffc0200e7c:	0b073023          	sd	a6,160(a4)
        if (!in_kernel)
ffffffffc0200e80:	e619                	bnez	a2,ffffffffc0200e8e <trap+0x4c>
        {
            if (current->flags & PF_EXITING)
ffffffffc0200e82:	0b072783          	lw	a5,176(a4)
ffffffffc0200e86:	8b85                	andi	a5,a5,1
ffffffffc0200e88:	e79d                	bnez	a5,ffffffffc0200eb6 <trap+0x74>
            {
                do_exit(-E_KILLED);
            }
            if (current->need_resched)
ffffffffc0200e8a:	6f1c                	ld	a5,24(a4)
ffffffffc0200e8c:	e38d                	bnez	a5,ffffffffc0200eae <trap+0x6c>
            {
                schedule();
            }
        }
    }
}
ffffffffc0200e8e:	60e2                	ld	ra,24(sp)
ffffffffc0200e90:	6105                	addi	sp,sp,32
ffffffffc0200e92:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200e94:	d4dff0ef          	jal	ffffffffc0200be0 <interrupt_handler>
ffffffffc0200e98:	6802                	ld	a6,0(sp)
ffffffffc0200e9a:	6622                	ld	a2,8(sp)
ffffffffc0200e9c:	000cb697          	auipc	a3,0xcb
ffffffffc0200ea0:	4bc68693          	addi	a3,a3,1212 # ffffffffc02cc358 <current>
ffffffffc0200ea4:	bfd9                	j	ffffffffc0200e7a <trap+0x38>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200ea6:	0005c363          	bltz	a1,ffffffffc0200eac <trap+0x6a>
        exception_handler(tf);
ffffffffc0200eaa:	bb5d                	j	ffffffffc0200c60 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200eac:	bb15                	j	ffffffffc0200be0 <interrupt_handler>
}
ffffffffc0200eae:	60e2                	ld	ra,24(sp)
ffffffffc0200eb0:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200eb2:	7b70406f          	j	ffffffffc0205e68 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200eb6:	555d                	li	a0,-9
ffffffffc0200eb8:	01c040ef          	jal	ffffffffc0204ed4 <do_exit>
            if (current->need_resched)
ffffffffc0200ebc:	000cb717          	auipc	a4,0xcb
ffffffffc0200ec0:	49c73703          	ld	a4,1180(a4) # ffffffffc02cc358 <current>
ffffffffc0200ec4:	b7d9                	j	ffffffffc0200e8a <trap+0x48>
	...

ffffffffc0200ec8 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ec8:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200ecc:	00011463          	bnez	sp,ffffffffc0200ed4 <__alltraps+0xc>
ffffffffc0200ed0:	14002173          	csrr	sp,sscratch
ffffffffc0200ed4:	712d                	addi	sp,sp,-288
ffffffffc0200ed6:	e002                	sd	zero,0(sp)
ffffffffc0200ed8:	e406                	sd	ra,8(sp)
ffffffffc0200eda:	ec0e                	sd	gp,24(sp)
ffffffffc0200edc:	f012                	sd	tp,32(sp)
ffffffffc0200ede:	f416                	sd	t0,40(sp)
ffffffffc0200ee0:	f81a                	sd	t1,48(sp)
ffffffffc0200ee2:	fc1e                	sd	t2,56(sp)
ffffffffc0200ee4:	e0a2                	sd	s0,64(sp)
ffffffffc0200ee6:	e4a6                	sd	s1,72(sp)
ffffffffc0200ee8:	e8aa                	sd	a0,80(sp)
ffffffffc0200eea:	ecae                	sd	a1,88(sp)
ffffffffc0200eec:	f0b2                	sd	a2,96(sp)
ffffffffc0200eee:	f4b6                	sd	a3,104(sp)
ffffffffc0200ef0:	f8ba                	sd	a4,112(sp)
ffffffffc0200ef2:	fcbe                	sd	a5,120(sp)
ffffffffc0200ef4:	e142                	sd	a6,128(sp)
ffffffffc0200ef6:	e546                	sd	a7,136(sp)
ffffffffc0200ef8:	e94a                	sd	s2,144(sp)
ffffffffc0200efa:	ed4e                	sd	s3,152(sp)
ffffffffc0200efc:	f152                	sd	s4,160(sp)
ffffffffc0200efe:	f556                	sd	s5,168(sp)
ffffffffc0200f00:	f95a                	sd	s6,176(sp)
ffffffffc0200f02:	fd5e                	sd	s7,184(sp)
ffffffffc0200f04:	e1e2                	sd	s8,192(sp)
ffffffffc0200f06:	e5e6                	sd	s9,200(sp)
ffffffffc0200f08:	e9ea                	sd	s10,208(sp)
ffffffffc0200f0a:	edee                	sd	s11,216(sp)
ffffffffc0200f0c:	f1f2                	sd	t3,224(sp)
ffffffffc0200f0e:	f5f6                	sd	t4,232(sp)
ffffffffc0200f10:	f9fa                	sd	t5,240(sp)
ffffffffc0200f12:	fdfe                	sd	t6,248(sp)
ffffffffc0200f14:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200f18:	100024f3          	csrr	s1,sstatus
ffffffffc0200f1c:	14102973          	csrr	s2,sepc
ffffffffc0200f20:	143029f3          	csrr	s3,stval
ffffffffc0200f24:	14202a73          	csrr	s4,scause
ffffffffc0200f28:	e822                	sd	s0,16(sp)
ffffffffc0200f2a:	e226                	sd	s1,256(sp)
ffffffffc0200f2c:	e64a                	sd	s2,264(sp)
ffffffffc0200f2e:	ea4e                	sd	s3,272(sp)
ffffffffc0200f30:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200f32:	850a                	mv	a0,sp
    jal trap
ffffffffc0200f34:	f0fff0ef          	jal	ffffffffc0200e42 <trap>

ffffffffc0200f38 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200f38:	6492                	ld	s1,256(sp)
ffffffffc0200f3a:	6932                	ld	s2,264(sp)
ffffffffc0200f3c:	1004f413          	andi	s0,s1,256
ffffffffc0200f40:	e401                	bnez	s0,ffffffffc0200f48 <__trapret+0x10>
ffffffffc0200f42:	1200                	addi	s0,sp,288
ffffffffc0200f44:	14041073          	csrw	sscratch,s0
ffffffffc0200f48:	10049073          	csrw	sstatus,s1
ffffffffc0200f4c:	14191073          	csrw	sepc,s2
ffffffffc0200f50:	60a2                	ld	ra,8(sp)
ffffffffc0200f52:	61e2                	ld	gp,24(sp)
ffffffffc0200f54:	7202                	ld	tp,32(sp)
ffffffffc0200f56:	72a2                	ld	t0,40(sp)
ffffffffc0200f58:	7342                	ld	t1,48(sp)
ffffffffc0200f5a:	73e2                	ld	t2,56(sp)
ffffffffc0200f5c:	6406                	ld	s0,64(sp)
ffffffffc0200f5e:	64a6                	ld	s1,72(sp)
ffffffffc0200f60:	6546                	ld	a0,80(sp)
ffffffffc0200f62:	65e6                	ld	a1,88(sp)
ffffffffc0200f64:	7606                	ld	a2,96(sp)
ffffffffc0200f66:	76a6                	ld	a3,104(sp)
ffffffffc0200f68:	7746                	ld	a4,112(sp)
ffffffffc0200f6a:	77e6                	ld	a5,120(sp)
ffffffffc0200f6c:	680a                	ld	a6,128(sp)
ffffffffc0200f6e:	68aa                	ld	a7,136(sp)
ffffffffc0200f70:	694a                	ld	s2,144(sp)
ffffffffc0200f72:	69ea                	ld	s3,152(sp)
ffffffffc0200f74:	7a0a                	ld	s4,160(sp)
ffffffffc0200f76:	7aaa                	ld	s5,168(sp)
ffffffffc0200f78:	7b4a                	ld	s6,176(sp)
ffffffffc0200f7a:	7bea                	ld	s7,184(sp)
ffffffffc0200f7c:	6c0e                	ld	s8,192(sp)
ffffffffc0200f7e:	6cae                	ld	s9,200(sp)
ffffffffc0200f80:	6d4e                	ld	s10,208(sp)
ffffffffc0200f82:	6dee                	ld	s11,216(sp)
ffffffffc0200f84:	7e0e                	ld	t3,224(sp)
ffffffffc0200f86:	7eae                	ld	t4,232(sp)
ffffffffc0200f88:	7f4e                	ld	t5,240(sp)
ffffffffc0200f8a:	7fee                	ld	t6,248(sp)
ffffffffc0200f8c:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200f8e:	10200073          	sret

ffffffffc0200f92 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200f92:	812a                	mv	sp,a0
ffffffffc0200f94:	b755                	j	ffffffffc0200f38 <__trapret>

ffffffffc0200f96 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200f96:	000c7797          	auipc	a5,0xc7
ffffffffc0200f9a:	1b278793          	addi	a5,a5,434 # ffffffffc02c8148 <free_area>
ffffffffc0200f9e:	e79c                	sd	a5,8(a5)
ffffffffc0200fa0:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200fa2:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200fa6:	8082                	ret

ffffffffc0200fa8 <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200fa8:	000c7517          	auipc	a0,0xc7
ffffffffc0200fac:	1b056503          	lwu	a0,432(a0) # ffffffffc02c8158 <free_area+0x10>
ffffffffc0200fb0:	8082                	ret

ffffffffc0200fb2 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200fb2:	711d                	addi	sp,sp,-96
ffffffffc0200fb4:	e0ca                	sd	s2,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200fb6:	000c7917          	auipc	s2,0xc7
ffffffffc0200fba:	19290913          	addi	s2,s2,402 # ffffffffc02c8148 <free_area>
ffffffffc0200fbe:	00893783          	ld	a5,8(s2)
ffffffffc0200fc2:	ec86                	sd	ra,88(sp)
ffffffffc0200fc4:	e8a2                	sd	s0,80(sp)
ffffffffc0200fc6:	e4a6                	sd	s1,72(sp)
ffffffffc0200fc8:	fc4e                	sd	s3,56(sp)
ffffffffc0200fca:	f852                	sd	s4,48(sp)
ffffffffc0200fcc:	f456                	sd	s5,40(sp)
ffffffffc0200fce:	f05a                	sd	s6,32(sp)
ffffffffc0200fd0:	ec5e                	sd	s7,24(sp)
ffffffffc0200fd2:	e862                	sd	s8,16(sp)
ffffffffc0200fd4:	e466                	sd	s9,8(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200fd6:	2f278363          	beq	a5,s2,ffffffffc02012bc <default_check+0x30a>
    int count = 0, total = 0;
ffffffffc0200fda:	4401                	li	s0,0
ffffffffc0200fdc:	4481                	li	s1,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200fde:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200fe2:	8b09                	andi	a4,a4,2
ffffffffc0200fe4:	2e070063          	beqz	a4,ffffffffc02012c4 <default_check+0x312>
        count ++, total += p->property;
ffffffffc0200fe8:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200fec:	679c                	ld	a5,8(a5)
ffffffffc0200fee:	2485                	addiw	s1,s1,1
ffffffffc0200ff0:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200ff2:	ff2796e3          	bne	a5,s2,ffffffffc0200fde <default_check+0x2c>
    }
    assert(total == nr_free_pages());
ffffffffc0200ff6:	89a2                	mv	s3,s0
ffffffffc0200ff8:	743000ef          	jal	ffffffffc0201f3a <nr_free_pages>
ffffffffc0200ffc:	73351463          	bne	a0,s3,ffffffffc0201724 <default_check+0x772>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201000:	4505                	li	a0,1
ffffffffc0201002:	6c7000ef          	jal	ffffffffc0201ec8 <alloc_pages>
ffffffffc0201006:	8a2a                	mv	s4,a0
ffffffffc0201008:	44050e63          	beqz	a0,ffffffffc0201464 <default_check+0x4b2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc020100c:	4505                	li	a0,1
ffffffffc020100e:	6bb000ef          	jal	ffffffffc0201ec8 <alloc_pages>
ffffffffc0201012:	89aa                	mv	s3,a0
ffffffffc0201014:	72050863          	beqz	a0,ffffffffc0201744 <default_check+0x792>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201018:	4505                	li	a0,1
ffffffffc020101a:	6af000ef          	jal	ffffffffc0201ec8 <alloc_pages>
ffffffffc020101e:	8aaa                	mv	s5,a0
ffffffffc0201020:	4c050263          	beqz	a0,ffffffffc02014e4 <default_check+0x532>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201024:	40a987b3          	sub	a5,s3,a0
ffffffffc0201028:	40aa0733          	sub	a4,s4,a0
ffffffffc020102c:	0017b793          	seqz	a5,a5
ffffffffc0201030:	00173713          	seqz	a4,a4
ffffffffc0201034:	8fd9                	or	a5,a5,a4
ffffffffc0201036:	30079763          	bnez	a5,ffffffffc0201344 <default_check+0x392>
ffffffffc020103a:	313a0563          	beq	s4,s3,ffffffffc0201344 <default_check+0x392>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc020103e:	000a2783          	lw	a5,0(s4)
ffffffffc0201042:	2a079163          	bnez	a5,ffffffffc02012e4 <default_check+0x332>
ffffffffc0201046:	0009a783          	lw	a5,0(s3)
ffffffffc020104a:	28079d63          	bnez	a5,ffffffffc02012e4 <default_check+0x332>
ffffffffc020104e:	411c                	lw	a5,0(a0)
ffffffffc0201050:	28079a63          	bnez	a5,ffffffffc02012e4 <default_check+0x332>
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page)
{
    return page - pages + nbase;
ffffffffc0201054:	000cb797          	auipc	a5,0xcb
ffffffffc0201058:	2ec7b783          	ld	a5,748(a5) # ffffffffc02cc340 <pages>
ffffffffc020105c:	00008617          	auipc	a2,0x8
ffffffffc0201060:	6a463603          	ld	a2,1700(a2) # ffffffffc0209700 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201064:	000cb697          	auipc	a3,0xcb
ffffffffc0201068:	2d46b683          	ld	a3,724(a3) # ffffffffc02cc338 <npage>
ffffffffc020106c:	40fa0733          	sub	a4,s4,a5
ffffffffc0201070:	8719                	srai	a4,a4,0x6
ffffffffc0201072:	9732                	add	a4,a4,a2
}

static inline uintptr_t
page2pa(struct Page *page)
{
    return page2ppn(page) << PGSHIFT;
ffffffffc0201074:	0732                	slli	a4,a4,0xc
ffffffffc0201076:	06b2                	slli	a3,a3,0xc
ffffffffc0201078:	2ad77663          	bgeu	a4,a3,ffffffffc0201324 <default_check+0x372>
    return page - pages + nbase;
ffffffffc020107c:	40f98733          	sub	a4,s3,a5
ffffffffc0201080:	8719                	srai	a4,a4,0x6
ffffffffc0201082:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201084:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201086:	4cd77f63          	bgeu	a4,a3,ffffffffc0201564 <default_check+0x5b2>
    return page - pages + nbase;
ffffffffc020108a:	40f507b3          	sub	a5,a0,a5
ffffffffc020108e:	8799                	srai	a5,a5,0x6
ffffffffc0201090:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201092:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201094:	32d7f863          	bgeu	a5,a3,ffffffffc02013c4 <default_check+0x412>
    assert(alloc_page() == NULL);
ffffffffc0201098:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020109a:	00093c03          	ld	s8,0(s2)
ffffffffc020109e:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc02010a2:	000c7b17          	auipc	s6,0xc7
ffffffffc02010a6:	0b6b2b03          	lw	s6,182(s6) # ffffffffc02c8158 <free_area+0x10>
    elm->prev = elm->next = elm;
ffffffffc02010aa:	01293023          	sd	s2,0(s2)
ffffffffc02010ae:	01293423          	sd	s2,8(s2)
    nr_free = 0;
ffffffffc02010b2:	000c7797          	auipc	a5,0xc7
ffffffffc02010b6:	0a07a323          	sw	zero,166(a5) # ffffffffc02c8158 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc02010ba:	60f000ef          	jal	ffffffffc0201ec8 <alloc_pages>
ffffffffc02010be:	2e051363          	bnez	a0,ffffffffc02013a4 <default_check+0x3f2>
    free_page(p0);
ffffffffc02010c2:	8552                	mv	a0,s4
ffffffffc02010c4:	4585                	li	a1,1
ffffffffc02010c6:	63d000ef          	jal	ffffffffc0201f02 <free_pages>
    free_page(p1);
ffffffffc02010ca:	854e                	mv	a0,s3
ffffffffc02010cc:	4585                	li	a1,1
ffffffffc02010ce:	635000ef          	jal	ffffffffc0201f02 <free_pages>
    free_page(p2);
ffffffffc02010d2:	8556                	mv	a0,s5
ffffffffc02010d4:	4585                	li	a1,1
ffffffffc02010d6:	62d000ef          	jal	ffffffffc0201f02 <free_pages>
    assert(nr_free == 3);
ffffffffc02010da:	000c7717          	auipc	a4,0xc7
ffffffffc02010de:	07e72703          	lw	a4,126(a4) # ffffffffc02c8158 <free_area+0x10>
ffffffffc02010e2:	478d                	li	a5,3
ffffffffc02010e4:	2af71063          	bne	a4,a5,ffffffffc0201384 <default_check+0x3d2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02010e8:	4505                	li	a0,1
ffffffffc02010ea:	5df000ef          	jal	ffffffffc0201ec8 <alloc_pages>
ffffffffc02010ee:	89aa                	mv	s3,a0
ffffffffc02010f0:	26050a63          	beqz	a0,ffffffffc0201364 <default_check+0x3b2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02010f4:	4505                	li	a0,1
ffffffffc02010f6:	5d3000ef          	jal	ffffffffc0201ec8 <alloc_pages>
ffffffffc02010fa:	8aaa                	mv	s5,a0
ffffffffc02010fc:	3c050463          	beqz	a0,ffffffffc02014c4 <default_check+0x512>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201100:	4505                	li	a0,1
ffffffffc0201102:	5c7000ef          	jal	ffffffffc0201ec8 <alloc_pages>
ffffffffc0201106:	8a2a                	mv	s4,a0
ffffffffc0201108:	38050e63          	beqz	a0,ffffffffc02014a4 <default_check+0x4f2>
    assert(alloc_page() == NULL);
ffffffffc020110c:	4505                	li	a0,1
ffffffffc020110e:	5bb000ef          	jal	ffffffffc0201ec8 <alloc_pages>
ffffffffc0201112:	36051963          	bnez	a0,ffffffffc0201484 <default_check+0x4d2>
    free_page(p0);
ffffffffc0201116:	4585                	li	a1,1
ffffffffc0201118:	854e                	mv	a0,s3
ffffffffc020111a:	5e9000ef          	jal	ffffffffc0201f02 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc020111e:	00893783          	ld	a5,8(s2)
ffffffffc0201122:	1f278163          	beq	a5,s2,ffffffffc0201304 <default_check+0x352>
    assert((p = alloc_page()) == p0);
ffffffffc0201126:	4505                	li	a0,1
ffffffffc0201128:	5a1000ef          	jal	ffffffffc0201ec8 <alloc_pages>
ffffffffc020112c:	8caa                	mv	s9,a0
ffffffffc020112e:	30a99b63          	bne	s3,a0,ffffffffc0201444 <default_check+0x492>
    assert(alloc_page() == NULL);
ffffffffc0201132:	4505                	li	a0,1
ffffffffc0201134:	595000ef          	jal	ffffffffc0201ec8 <alloc_pages>
ffffffffc0201138:	2e051663          	bnez	a0,ffffffffc0201424 <default_check+0x472>
    assert(nr_free == 0);
ffffffffc020113c:	000c7797          	auipc	a5,0xc7
ffffffffc0201140:	01c7a783          	lw	a5,28(a5) # ffffffffc02c8158 <free_area+0x10>
ffffffffc0201144:	2c079063          	bnez	a5,ffffffffc0201404 <default_check+0x452>
    free_page(p);
ffffffffc0201148:	8566                	mv	a0,s9
ffffffffc020114a:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc020114c:	01893023          	sd	s8,0(s2)
ffffffffc0201150:	01793423          	sd	s7,8(s2)
    nr_free = nr_free_store;
ffffffffc0201154:	01692823          	sw	s6,16(s2)
    free_page(p);
ffffffffc0201158:	5ab000ef          	jal	ffffffffc0201f02 <free_pages>
    free_page(p1);
ffffffffc020115c:	8556                	mv	a0,s5
ffffffffc020115e:	4585                	li	a1,1
ffffffffc0201160:	5a3000ef          	jal	ffffffffc0201f02 <free_pages>
    free_page(p2);
ffffffffc0201164:	8552                	mv	a0,s4
ffffffffc0201166:	4585                	li	a1,1
ffffffffc0201168:	59b000ef          	jal	ffffffffc0201f02 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc020116c:	4515                	li	a0,5
ffffffffc020116e:	55b000ef          	jal	ffffffffc0201ec8 <alloc_pages>
ffffffffc0201172:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201174:	26050863          	beqz	a0,ffffffffc02013e4 <default_check+0x432>
ffffffffc0201178:	651c                	ld	a5,8(a0)
    assert(!PageProperty(p0));
ffffffffc020117a:	8b89                	andi	a5,a5,2
ffffffffc020117c:	54079463          	bnez	a5,ffffffffc02016c4 <default_check+0x712>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0201180:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201182:	00093b83          	ld	s7,0(s2)
ffffffffc0201186:	00893b03          	ld	s6,8(s2)
ffffffffc020118a:	01293023          	sd	s2,0(s2)
ffffffffc020118e:	01293423          	sd	s2,8(s2)
    assert(alloc_page() == NULL);
ffffffffc0201192:	537000ef          	jal	ffffffffc0201ec8 <alloc_pages>
ffffffffc0201196:	50051763          	bnez	a0,ffffffffc02016a4 <default_check+0x6f2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc020119a:	08098a13          	addi	s4,s3,128
ffffffffc020119e:	8552                	mv	a0,s4
ffffffffc02011a0:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02011a2:	000c7c17          	auipc	s8,0xc7
ffffffffc02011a6:	fb6c2c03          	lw	s8,-74(s8) # ffffffffc02c8158 <free_area+0x10>
    nr_free = 0;
ffffffffc02011aa:	000c7797          	auipc	a5,0xc7
ffffffffc02011ae:	fa07a723          	sw	zero,-82(a5) # ffffffffc02c8158 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02011b2:	551000ef          	jal	ffffffffc0201f02 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02011b6:	4511                	li	a0,4
ffffffffc02011b8:	511000ef          	jal	ffffffffc0201ec8 <alloc_pages>
ffffffffc02011bc:	4c051463          	bnez	a0,ffffffffc0201684 <default_check+0x6d2>
ffffffffc02011c0:	0889b783          	ld	a5,136(s3)
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02011c4:	8b89                	andi	a5,a5,2
ffffffffc02011c6:	48078f63          	beqz	a5,ffffffffc0201664 <default_check+0x6b2>
ffffffffc02011ca:	0909a503          	lw	a0,144(s3)
ffffffffc02011ce:	478d                	li	a5,3
ffffffffc02011d0:	48f51a63          	bne	a0,a5,ffffffffc0201664 <default_check+0x6b2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02011d4:	4f5000ef          	jal	ffffffffc0201ec8 <alloc_pages>
ffffffffc02011d8:	8aaa                	mv	s5,a0
ffffffffc02011da:	46050563          	beqz	a0,ffffffffc0201644 <default_check+0x692>
    assert(alloc_page() == NULL);
ffffffffc02011de:	4505                	li	a0,1
ffffffffc02011e0:	4e9000ef          	jal	ffffffffc0201ec8 <alloc_pages>
ffffffffc02011e4:	44051063          	bnez	a0,ffffffffc0201624 <default_check+0x672>
    assert(p0 + 2 == p1);
ffffffffc02011e8:	415a1e63          	bne	s4,s5,ffffffffc0201604 <default_check+0x652>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc02011ec:	4585                	li	a1,1
ffffffffc02011ee:	854e                	mv	a0,s3
ffffffffc02011f0:	513000ef          	jal	ffffffffc0201f02 <free_pages>
    free_pages(p1, 3);
ffffffffc02011f4:	8552                	mv	a0,s4
ffffffffc02011f6:	458d                	li	a1,3
ffffffffc02011f8:	50b000ef          	jal	ffffffffc0201f02 <free_pages>
ffffffffc02011fc:	0089b783          	ld	a5,8(s3)
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201200:	8b89                	andi	a5,a5,2
ffffffffc0201202:	3e078163          	beqz	a5,ffffffffc02015e4 <default_check+0x632>
ffffffffc0201206:	0109aa83          	lw	s5,16(s3)
ffffffffc020120a:	4785                	li	a5,1
ffffffffc020120c:	3cfa9c63          	bne	s5,a5,ffffffffc02015e4 <default_check+0x632>
ffffffffc0201210:	008a3783          	ld	a5,8(s4)
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201214:	8b89                	andi	a5,a5,2
ffffffffc0201216:	3a078763          	beqz	a5,ffffffffc02015c4 <default_check+0x612>
ffffffffc020121a:	010a2703          	lw	a4,16(s4)
ffffffffc020121e:	478d                	li	a5,3
ffffffffc0201220:	3af71263          	bne	a4,a5,ffffffffc02015c4 <default_check+0x612>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201224:	8556                	mv	a0,s5
ffffffffc0201226:	4a3000ef          	jal	ffffffffc0201ec8 <alloc_pages>
ffffffffc020122a:	36a99d63          	bne	s3,a0,ffffffffc02015a4 <default_check+0x5f2>
    free_page(p0);
ffffffffc020122e:	85d6                	mv	a1,s5
ffffffffc0201230:	4d3000ef          	jal	ffffffffc0201f02 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201234:	4509                	li	a0,2
ffffffffc0201236:	493000ef          	jal	ffffffffc0201ec8 <alloc_pages>
ffffffffc020123a:	34aa1563          	bne	s4,a0,ffffffffc0201584 <default_check+0x5d2>

    free_pages(p0, 2);
ffffffffc020123e:	4589                	li	a1,2
ffffffffc0201240:	4c3000ef          	jal	ffffffffc0201f02 <free_pages>
    free_page(p2);
ffffffffc0201244:	04098513          	addi	a0,s3,64
ffffffffc0201248:	85d6                	mv	a1,s5
ffffffffc020124a:	4b9000ef          	jal	ffffffffc0201f02 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020124e:	4515                	li	a0,5
ffffffffc0201250:	479000ef          	jal	ffffffffc0201ec8 <alloc_pages>
ffffffffc0201254:	89aa                	mv	s3,a0
ffffffffc0201256:	48050763          	beqz	a0,ffffffffc02016e4 <default_check+0x732>
    assert(alloc_page() == NULL);
ffffffffc020125a:	8556                	mv	a0,s5
ffffffffc020125c:	46d000ef          	jal	ffffffffc0201ec8 <alloc_pages>
ffffffffc0201260:	2e051263          	bnez	a0,ffffffffc0201544 <default_check+0x592>

    assert(nr_free == 0);
ffffffffc0201264:	000c7797          	auipc	a5,0xc7
ffffffffc0201268:	ef47a783          	lw	a5,-268(a5) # ffffffffc02c8158 <free_area+0x10>
ffffffffc020126c:	2a079c63          	bnez	a5,ffffffffc0201524 <default_check+0x572>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0201270:	854e                	mv	a0,s3
ffffffffc0201272:	4595                	li	a1,5
    nr_free = nr_free_store;
ffffffffc0201274:	01892823          	sw	s8,16(s2)
    free_list = free_list_store;
ffffffffc0201278:	01793023          	sd	s7,0(s2)
ffffffffc020127c:	01693423          	sd	s6,8(s2)
    free_pages(p0, 5);
ffffffffc0201280:	483000ef          	jal	ffffffffc0201f02 <free_pages>
    return listelm->next;
ffffffffc0201284:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201288:	01278963          	beq	a5,s2,ffffffffc020129a <default_check+0x2e8>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc020128c:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201290:	679c                	ld	a5,8(a5)
ffffffffc0201292:	34fd                	addiw	s1,s1,-1
ffffffffc0201294:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201296:	ff279be3          	bne	a5,s2,ffffffffc020128c <default_check+0x2da>
    }
    assert(count == 0);
ffffffffc020129a:	26049563          	bnez	s1,ffffffffc0201504 <default_check+0x552>
    assert(total == 0);
ffffffffc020129e:	46041363          	bnez	s0,ffffffffc0201704 <default_check+0x752>
}
ffffffffc02012a2:	60e6                	ld	ra,88(sp)
ffffffffc02012a4:	6446                	ld	s0,80(sp)
ffffffffc02012a6:	64a6                	ld	s1,72(sp)
ffffffffc02012a8:	6906                	ld	s2,64(sp)
ffffffffc02012aa:	79e2                	ld	s3,56(sp)
ffffffffc02012ac:	7a42                	ld	s4,48(sp)
ffffffffc02012ae:	7aa2                	ld	s5,40(sp)
ffffffffc02012b0:	7b02                	ld	s6,32(sp)
ffffffffc02012b2:	6be2                	ld	s7,24(sp)
ffffffffc02012b4:	6c42                	ld	s8,16(sp)
ffffffffc02012b6:	6ca2                	ld	s9,8(sp)
ffffffffc02012b8:	6125                	addi	sp,sp,96
ffffffffc02012ba:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc02012bc:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02012be:	4401                	li	s0,0
ffffffffc02012c0:	4481                	li	s1,0
ffffffffc02012c2:	bb1d                	j	ffffffffc0200ff8 <default_check+0x46>
        assert(PageProperty(p));
ffffffffc02012c4:	00006697          	auipc	a3,0x6
ffffffffc02012c8:	efc68693          	addi	a3,a3,-260 # ffffffffc02071c0 <etext+0xa5e>
ffffffffc02012cc:	00006617          	auipc	a2,0x6
ffffffffc02012d0:	c4460613          	addi	a2,a2,-956 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02012d4:	0ef00593          	li	a1,239
ffffffffc02012d8:	00006517          	auipc	a0,0x6
ffffffffc02012dc:	ef850513          	addi	a0,a0,-264 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc02012e0:	96aff0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02012e4:	00006697          	auipc	a3,0x6
ffffffffc02012e8:	fac68693          	addi	a3,a3,-84 # ffffffffc0207290 <etext+0xb2e>
ffffffffc02012ec:	00006617          	auipc	a2,0x6
ffffffffc02012f0:	c2460613          	addi	a2,a2,-988 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02012f4:	0bd00593          	li	a1,189
ffffffffc02012f8:	00006517          	auipc	a0,0x6
ffffffffc02012fc:	ed850513          	addi	a0,a0,-296 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201300:	94aff0ef          	jal	ffffffffc020044a <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201304:	00006697          	auipc	a3,0x6
ffffffffc0201308:	05468693          	addi	a3,a3,84 # ffffffffc0207358 <etext+0xbf6>
ffffffffc020130c:	00006617          	auipc	a2,0x6
ffffffffc0201310:	c0460613          	addi	a2,a2,-1020 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201314:	0d800593          	li	a1,216
ffffffffc0201318:	00006517          	auipc	a0,0x6
ffffffffc020131c:	eb850513          	addi	a0,a0,-328 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201320:	92aff0ef          	jal	ffffffffc020044a <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201324:	00006697          	auipc	a3,0x6
ffffffffc0201328:	fac68693          	addi	a3,a3,-84 # ffffffffc02072d0 <etext+0xb6e>
ffffffffc020132c:	00006617          	auipc	a2,0x6
ffffffffc0201330:	be460613          	addi	a2,a2,-1052 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201334:	0bf00593          	li	a1,191
ffffffffc0201338:	00006517          	auipc	a0,0x6
ffffffffc020133c:	e9850513          	addi	a0,a0,-360 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201340:	90aff0ef          	jal	ffffffffc020044a <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201344:	00006697          	auipc	a3,0x6
ffffffffc0201348:	f2468693          	addi	a3,a3,-220 # ffffffffc0207268 <etext+0xb06>
ffffffffc020134c:	00006617          	auipc	a2,0x6
ffffffffc0201350:	bc460613          	addi	a2,a2,-1084 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201354:	0bc00593          	li	a1,188
ffffffffc0201358:	00006517          	auipc	a0,0x6
ffffffffc020135c:	e7850513          	addi	a0,a0,-392 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201360:	8eaff0ef          	jal	ffffffffc020044a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201364:	00006697          	auipc	a3,0x6
ffffffffc0201368:	ea468693          	addi	a3,a3,-348 # ffffffffc0207208 <etext+0xaa6>
ffffffffc020136c:	00006617          	auipc	a2,0x6
ffffffffc0201370:	ba460613          	addi	a2,a2,-1116 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201374:	0d100593          	li	a1,209
ffffffffc0201378:	00006517          	auipc	a0,0x6
ffffffffc020137c:	e5850513          	addi	a0,a0,-424 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201380:	8caff0ef          	jal	ffffffffc020044a <__panic>
    assert(nr_free == 3);
ffffffffc0201384:	00006697          	auipc	a3,0x6
ffffffffc0201388:	fc468693          	addi	a3,a3,-60 # ffffffffc0207348 <etext+0xbe6>
ffffffffc020138c:	00006617          	auipc	a2,0x6
ffffffffc0201390:	b8460613          	addi	a2,a2,-1148 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201394:	0cf00593          	li	a1,207
ffffffffc0201398:	00006517          	auipc	a0,0x6
ffffffffc020139c:	e3850513          	addi	a0,a0,-456 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc02013a0:	8aaff0ef          	jal	ffffffffc020044a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013a4:	00006697          	auipc	a3,0x6
ffffffffc02013a8:	f8c68693          	addi	a3,a3,-116 # ffffffffc0207330 <etext+0xbce>
ffffffffc02013ac:	00006617          	auipc	a2,0x6
ffffffffc02013b0:	b6460613          	addi	a2,a2,-1180 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02013b4:	0ca00593          	li	a1,202
ffffffffc02013b8:	00006517          	auipc	a0,0x6
ffffffffc02013bc:	e1850513          	addi	a0,a0,-488 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc02013c0:	88aff0ef          	jal	ffffffffc020044a <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02013c4:	00006697          	auipc	a3,0x6
ffffffffc02013c8:	f4c68693          	addi	a3,a3,-180 # ffffffffc0207310 <etext+0xbae>
ffffffffc02013cc:	00006617          	auipc	a2,0x6
ffffffffc02013d0:	b4460613          	addi	a2,a2,-1212 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02013d4:	0c100593          	li	a1,193
ffffffffc02013d8:	00006517          	auipc	a0,0x6
ffffffffc02013dc:	df850513          	addi	a0,a0,-520 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc02013e0:	86aff0ef          	jal	ffffffffc020044a <__panic>
    assert(p0 != NULL);
ffffffffc02013e4:	00006697          	auipc	a3,0x6
ffffffffc02013e8:	fbc68693          	addi	a3,a3,-68 # ffffffffc02073a0 <etext+0xc3e>
ffffffffc02013ec:	00006617          	auipc	a2,0x6
ffffffffc02013f0:	b2460613          	addi	a2,a2,-1244 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02013f4:	0f700593          	li	a1,247
ffffffffc02013f8:	00006517          	auipc	a0,0x6
ffffffffc02013fc:	dd850513          	addi	a0,a0,-552 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201400:	84aff0ef          	jal	ffffffffc020044a <__panic>
    assert(nr_free == 0);
ffffffffc0201404:	00006697          	auipc	a3,0x6
ffffffffc0201408:	f8c68693          	addi	a3,a3,-116 # ffffffffc0207390 <etext+0xc2e>
ffffffffc020140c:	00006617          	auipc	a2,0x6
ffffffffc0201410:	b0460613          	addi	a2,a2,-1276 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201414:	0de00593          	li	a1,222
ffffffffc0201418:	00006517          	auipc	a0,0x6
ffffffffc020141c:	db850513          	addi	a0,a0,-584 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201420:	82aff0ef          	jal	ffffffffc020044a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201424:	00006697          	auipc	a3,0x6
ffffffffc0201428:	f0c68693          	addi	a3,a3,-244 # ffffffffc0207330 <etext+0xbce>
ffffffffc020142c:	00006617          	auipc	a2,0x6
ffffffffc0201430:	ae460613          	addi	a2,a2,-1308 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201434:	0dc00593          	li	a1,220
ffffffffc0201438:	00006517          	auipc	a0,0x6
ffffffffc020143c:	d9850513          	addi	a0,a0,-616 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201440:	80aff0ef          	jal	ffffffffc020044a <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201444:	00006697          	auipc	a3,0x6
ffffffffc0201448:	f2c68693          	addi	a3,a3,-212 # ffffffffc0207370 <etext+0xc0e>
ffffffffc020144c:	00006617          	auipc	a2,0x6
ffffffffc0201450:	ac460613          	addi	a2,a2,-1340 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201454:	0db00593          	li	a1,219
ffffffffc0201458:	00006517          	auipc	a0,0x6
ffffffffc020145c:	d7850513          	addi	a0,a0,-648 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201460:	febfe0ef          	jal	ffffffffc020044a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201464:	00006697          	auipc	a3,0x6
ffffffffc0201468:	da468693          	addi	a3,a3,-604 # ffffffffc0207208 <etext+0xaa6>
ffffffffc020146c:	00006617          	auipc	a2,0x6
ffffffffc0201470:	aa460613          	addi	a2,a2,-1372 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201474:	0b800593          	li	a1,184
ffffffffc0201478:	00006517          	auipc	a0,0x6
ffffffffc020147c:	d5850513          	addi	a0,a0,-680 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201480:	fcbfe0ef          	jal	ffffffffc020044a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201484:	00006697          	auipc	a3,0x6
ffffffffc0201488:	eac68693          	addi	a3,a3,-340 # ffffffffc0207330 <etext+0xbce>
ffffffffc020148c:	00006617          	auipc	a2,0x6
ffffffffc0201490:	a8460613          	addi	a2,a2,-1404 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201494:	0d500593          	li	a1,213
ffffffffc0201498:	00006517          	auipc	a0,0x6
ffffffffc020149c:	d3850513          	addi	a0,a0,-712 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc02014a0:	fabfe0ef          	jal	ffffffffc020044a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02014a4:	00006697          	auipc	a3,0x6
ffffffffc02014a8:	da468693          	addi	a3,a3,-604 # ffffffffc0207248 <etext+0xae6>
ffffffffc02014ac:	00006617          	auipc	a2,0x6
ffffffffc02014b0:	a6460613          	addi	a2,a2,-1436 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02014b4:	0d300593          	li	a1,211
ffffffffc02014b8:	00006517          	auipc	a0,0x6
ffffffffc02014bc:	d1850513          	addi	a0,a0,-744 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc02014c0:	f8bfe0ef          	jal	ffffffffc020044a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02014c4:	00006697          	auipc	a3,0x6
ffffffffc02014c8:	d6468693          	addi	a3,a3,-668 # ffffffffc0207228 <etext+0xac6>
ffffffffc02014cc:	00006617          	auipc	a2,0x6
ffffffffc02014d0:	a4460613          	addi	a2,a2,-1468 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02014d4:	0d200593          	li	a1,210
ffffffffc02014d8:	00006517          	auipc	a0,0x6
ffffffffc02014dc:	cf850513          	addi	a0,a0,-776 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc02014e0:	f6bfe0ef          	jal	ffffffffc020044a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02014e4:	00006697          	auipc	a3,0x6
ffffffffc02014e8:	d6468693          	addi	a3,a3,-668 # ffffffffc0207248 <etext+0xae6>
ffffffffc02014ec:	00006617          	auipc	a2,0x6
ffffffffc02014f0:	a2460613          	addi	a2,a2,-1500 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02014f4:	0ba00593          	li	a1,186
ffffffffc02014f8:	00006517          	auipc	a0,0x6
ffffffffc02014fc:	cd850513          	addi	a0,a0,-808 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201500:	f4bfe0ef          	jal	ffffffffc020044a <__panic>
    assert(count == 0);
ffffffffc0201504:	00006697          	auipc	a3,0x6
ffffffffc0201508:	fec68693          	addi	a3,a3,-20 # ffffffffc02074f0 <etext+0xd8e>
ffffffffc020150c:	00006617          	auipc	a2,0x6
ffffffffc0201510:	a0460613          	addi	a2,a2,-1532 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201514:	12400593          	li	a1,292
ffffffffc0201518:	00006517          	auipc	a0,0x6
ffffffffc020151c:	cb850513          	addi	a0,a0,-840 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201520:	f2bfe0ef          	jal	ffffffffc020044a <__panic>
    assert(nr_free == 0);
ffffffffc0201524:	00006697          	auipc	a3,0x6
ffffffffc0201528:	e6c68693          	addi	a3,a3,-404 # ffffffffc0207390 <etext+0xc2e>
ffffffffc020152c:	00006617          	auipc	a2,0x6
ffffffffc0201530:	9e460613          	addi	a2,a2,-1564 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201534:	11900593          	li	a1,281
ffffffffc0201538:	00006517          	auipc	a0,0x6
ffffffffc020153c:	c9850513          	addi	a0,a0,-872 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201540:	f0bfe0ef          	jal	ffffffffc020044a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201544:	00006697          	auipc	a3,0x6
ffffffffc0201548:	dec68693          	addi	a3,a3,-532 # ffffffffc0207330 <etext+0xbce>
ffffffffc020154c:	00006617          	auipc	a2,0x6
ffffffffc0201550:	9c460613          	addi	a2,a2,-1596 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201554:	11700593          	li	a1,279
ffffffffc0201558:	00006517          	auipc	a0,0x6
ffffffffc020155c:	c7850513          	addi	a0,a0,-904 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201560:	eebfe0ef          	jal	ffffffffc020044a <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201564:	00006697          	auipc	a3,0x6
ffffffffc0201568:	d8c68693          	addi	a3,a3,-628 # ffffffffc02072f0 <etext+0xb8e>
ffffffffc020156c:	00006617          	auipc	a2,0x6
ffffffffc0201570:	9a460613          	addi	a2,a2,-1628 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201574:	0c000593          	li	a1,192
ffffffffc0201578:	00006517          	auipc	a0,0x6
ffffffffc020157c:	c5850513          	addi	a0,a0,-936 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201580:	ecbfe0ef          	jal	ffffffffc020044a <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201584:	00006697          	auipc	a3,0x6
ffffffffc0201588:	f2c68693          	addi	a3,a3,-212 # ffffffffc02074b0 <etext+0xd4e>
ffffffffc020158c:	00006617          	auipc	a2,0x6
ffffffffc0201590:	98460613          	addi	a2,a2,-1660 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201594:	11100593          	li	a1,273
ffffffffc0201598:	00006517          	auipc	a0,0x6
ffffffffc020159c:	c3850513          	addi	a0,a0,-968 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc02015a0:	eabfe0ef          	jal	ffffffffc020044a <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02015a4:	00006697          	auipc	a3,0x6
ffffffffc02015a8:	eec68693          	addi	a3,a3,-276 # ffffffffc0207490 <etext+0xd2e>
ffffffffc02015ac:	00006617          	auipc	a2,0x6
ffffffffc02015b0:	96460613          	addi	a2,a2,-1692 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02015b4:	10f00593          	li	a1,271
ffffffffc02015b8:	00006517          	auipc	a0,0x6
ffffffffc02015bc:	c1850513          	addi	a0,a0,-1000 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc02015c0:	e8bfe0ef          	jal	ffffffffc020044a <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02015c4:	00006697          	auipc	a3,0x6
ffffffffc02015c8:	ea468693          	addi	a3,a3,-348 # ffffffffc0207468 <etext+0xd06>
ffffffffc02015cc:	00006617          	auipc	a2,0x6
ffffffffc02015d0:	94460613          	addi	a2,a2,-1724 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02015d4:	10d00593          	li	a1,269
ffffffffc02015d8:	00006517          	auipc	a0,0x6
ffffffffc02015dc:	bf850513          	addi	a0,a0,-1032 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc02015e0:	e6bfe0ef          	jal	ffffffffc020044a <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02015e4:	00006697          	auipc	a3,0x6
ffffffffc02015e8:	e5c68693          	addi	a3,a3,-420 # ffffffffc0207440 <etext+0xcde>
ffffffffc02015ec:	00006617          	auipc	a2,0x6
ffffffffc02015f0:	92460613          	addi	a2,a2,-1756 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02015f4:	10c00593          	li	a1,268
ffffffffc02015f8:	00006517          	auipc	a0,0x6
ffffffffc02015fc:	bd850513          	addi	a0,a0,-1064 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201600:	e4bfe0ef          	jal	ffffffffc020044a <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201604:	00006697          	auipc	a3,0x6
ffffffffc0201608:	e2c68693          	addi	a3,a3,-468 # ffffffffc0207430 <etext+0xcce>
ffffffffc020160c:	00006617          	auipc	a2,0x6
ffffffffc0201610:	90460613          	addi	a2,a2,-1788 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201614:	10700593          	li	a1,263
ffffffffc0201618:	00006517          	auipc	a0,0x6
ffffffffc020161c:	bb850513          	addi	a0,a0,-1096 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201620:	e2bfe0ef          	jal	ffffffffc020044a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201624:	00006697          	auipc	a3,0x6
ffffffffc0201628:	d0c68693          	addi	a3,a3,-756 # ffffffffc0207330 <etext+0xbce>
ffffffffc020162c:	00006617          	auipc	a2,0x6
ffffffffc0201630:	8e460613          	addi	a2,a2,-1820 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201634:	10600593          	li	a1,262
ffffffffc0201638:	00006517          	auipc	a0,0x6
ffffffffc020163c:	b9850513          	addi	a0,a0,-1128 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201640:	e0bfe0ef          	jal	ffffffffc020044a <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201644:	00006697          	auipc	a3,0x6
ffffffffc0201648:	dcc68693          	addi	a3,a3,-564 # ffffffffc0207410 <etext+0xcae>
ffffffffc020164c:	00006617          	auipc	a2,0x6
ffffffffc0201650:	8c460613          	addi	a2,a2,-1852 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201654:	10500593          	li	a1,261
ffffffffc0201658:	00006517          	auipc	a0,0x6
ffffffffc020165c:	b7850513          	addi	a0,a0,-1160 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201660:	debfe0ef          	jal	ffffffffc020044a <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201664:	00006697          	auipc	a3,0x6
ffffffffc0201668:	d7c68693          	addi	a3,a3,-644 # ffffffffc02073e0 <etext+0xc7e>
ffffffffc020166c:	00006617          	auipc	a2,0x6
ffffffffc0201670:	8a460613          	addi	a2,a2,-1884 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201674:	10400593          	li	a1,260
ffffffffc0201678:	00006517          	auipc	a0,0x6
ffffffffc020167c:	b5850513          	addi	a0,a0,-1192 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201680:	dcbfe0ef          	jal	ffffffffc020044a <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201684:	00006697          	auipc	a3,0x6
ffffffffc0201688:	d4468693          	addi	a3,a3,-700 # ffffffffc02073c8 <etext+0xc66>
ffffffffc020168c:	00006617          	auipc	a2,0x6
ffffffffc0201690:	88460613          	addi	a2,a2,-1916 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201694:	10300593          	li	a1,259
ffffffffc0201698:	00006517          	auipc	a0,0x6
ffffffffc020169c:	b3850513          	addi	a0,a0,-1224 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc02016a0:	dabfe0ef          	jal	ffffffffc020044a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02016a4:	00006697          	auipc	a3,0x6
ffffffffc02016a8:	c8c68693          	addi	a3,a3,-884 # ffffffffc0207330 <etext+0xbce>
ffffffffc02016ac:	00006617          	auipc	a2,0x6
ffffffffc02016b0:	86460613          	addi	a2,a2,-1948 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02016b4:	0fd00593          	li	a1,253
ffffffffc02016b8:	00006517          	auipc	a0,0x6
ffffffffc02016bc:	b1850513          	addi	a0,a0,-1256 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc02016c0:	d8bfe0ef          	jal	ffffffffc020044a <__panic>
    assert(!PageProperty(p0));
ffffffffc02016c4:	00006697          	auipc	a3,0x6
ffffffffc02016c8:	cec68693          	addi	a3,a3,-788 # ffffffffc02073b0 <etext+0xc4e>
ffffffffc02016cc:	00006617          	auipc	a2,0x6
ffffffffc02016d0:	84460613          	addi	a2,a2,-1980 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02016d4:	0f800593          	li	a1,248
ffffffffc02016d8:	00006517          	auipc	a0,0x6
ffffffffc02016dc:	af850513          	addi	a0,a0,-1288 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc02016e0:	d6bfe0ef          	jal	ffffffffc020044a <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02016e4:	00006697          	auipc	a3,0x6
ffffffffc02016e8:	dec68693          	addi	a3,a3,-532 # ffffffffc02074d0 <etext+0xd6e>
ffffffffc02016ec:	00006617          	auipc	a2,0x6
ffffffffc02016f0:	82460613          	addi	a2,a2,-2012 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02016f4:	11600593          	li	a1,278
ffffffffc02016f8:	00006517          	auipc	a0,0x6
ffffffffc02016fc:	ad850513          	addi	a0,a0,-1320 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201700:	d4bfe0ef          	jal	ffffffffc020044a <__panic>
    assert(total == 0);
ffffffffc0201704:	00006697          	auipc	a3,0x6
ffffffffc0201708:	dfc68693          	addi	a3,a3,-516 # ffffffffc0207500 <etext+0xd9e>
ffffffffc020170c:	00006617          	auipc	a2,0x6
ffffffffc0201710:	80460613          	addi	a2,a2,-2044 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201714:	12500593          	li	a1,293
ffffffffc0201718:	00006517          	auipc	a0,0x6
ffffffffc020171c:	ab850513          	addi	a0,a0,-1352 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201720:	d2bfe0ef          	jal	ffffffffc020044a <__panic>
    assert(total == nr_free_pages());
ffffffffc0201724:	00006697          	auipc	a3,0x6
ffffffffc0201728:	ac468693          	addi	a3,a3,-1340 # ffffffffc02071e8 <etext+0xa86>
ffffffffc020172c:	00005617          	auipc	a2,0x5
ffffffffc0201730:	7e460613          	addi	a2,a2,2020 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201734:	0f200593          	li	a1,242
ffffffffc0201738:	00006517          	auipc	a0,0x6
ffffffffc020173c:	a9850513          	addi	a0,a0,-1384 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201740:	d0bfe0ef          	jal	ffffffffc020044a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201744:	00006697          	auipc	a3,0x6
ffffffffc0201748:	ae468693          	addi	a3,a3,-1308 # ffffffffc0207228 <etext+0xac6>
ffffffffc020174c:	00005617          	auipc	a2,0x5
ffffffffc0201750:	7c460613          	addi	a2,a2,1988 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201754:	0b900593          	li	a1,185
ffffffffc0201758:	00006517          	auipc	a0,0x6
ffffffffc020175c:	a7850513          	addi	a0,a0,-1416 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201760:	cebfe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201764 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc0201764:	1141                	addi	sp,sp,-16
ffffffffc0201766:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201768:	14058663          	beqz	a1,ffffffffc02018b4 <default_free_pages+0x150>
    for (; p != base + n; p ++) {
ffffffffc020176c:	00659713          	slli	a4,a1,0x6
ffffffffc0201770:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc0201774:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc0201776:	c30d                	beqz	a4,ffffffffc0201798 <default_free_pages+0x34>
ffffffffc0201778:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc020177a:	8b05                	andi	a4,a4,1
ffffffffc020177c:	10071c63          	bnez	a4,ffffffffc0201894 <default_free_pages+0x130>
ffffffffc0201780:	6798                	ld	a4,8(a5)
ffffffffc0201782:	8b09                	andi	a4,a4,2
ffffffffc0201784:	10071863          	bnez	a4,ffffffffc0201894 <default_free_pages+0x130>
        p->flags = 0;
ffffffffc0201788:	0007b423          	sd	zero,8(a5)
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc020178c:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201790:	04078793          	addi	a5,a5,64
ffffffffc0201794:	fed792e3          	bne	a5,a3,ffffffffc0201778 <default_free_pages+0x14>
    base->property = n;
ffffffffc0201798:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc020179a:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020179e:	4789                	li	a5,2
ffffffffc02017a0:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02017a4:	000c7717          	auipc	a4,0xc7
ffffffffc02017a8:	9b472703          	lw	a4,-1612(a4) # ffffffffc02c8158 <free_area+0x10>
ffffffffc02017ac:	000c7697          	auipc	a3,0xc7
ffffffffc02017b0:	99c68693          	addi	a3,a3,-1636 # ffffffffc02c8148 <free_area>
    return list->next == list;
ffffffffc02017b4:	669c                	ld	a5,8(a3)
ffffffffc02017b6:	9f2d                	addw	a4,a4,a1
ffffffffc02017b8:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02017ba:	0ad78163          	beq	a5,a3,ffffffffc020185c <default_free_pages+0xf8>
            struct Page* page = le2page(le, page_link);
ffffffffc02017be:	fe878713          	addi	a4,a5,-24
ffffffffc02017c2:	4581                	li	a1,0
ffffffffc02017c4:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02017c8:	00e56a63          	bltu	a0,a4,ffffffffc02017dc <default_free_pages+0x78>
    return listelm->next;
ffffffffc02017cc:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02017ce:	04d70c63          	beq	a4,a3,ffffffffc0201826 <default_free_pages+0xc2>
    struct Page *p = base;
ffffffffc02017d2:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02017d4:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02017d8:	fee57ae3          	bgeu	a0,a4,ffffffffc02017cc <default_free_pages+0x68>
ffffffffc02017dc:	c199                	beqz	a1,ffffffffc02017e2 <default_free_pages+0x7e>
ffffffffc02017de:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc02017e2:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02017e4:	e390                	sd	a2,0(a5)
ffffffffc02017e6:	e710                	sd	a2,8(a4)
    elm->next = next;
    elm->prev = prev;
ffffffffc02017e8:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc02017ea:	f11c                	sd	a5,32(a0)
    if (le != &free_list) {
ffffffffc02017ec:	00d70d63          	beq	a4,a3,ffffffffc0201806 <default_free_pages+0xa2>
        if (p + p->property == base) {
ffffffffc02017f0:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc02017f4:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base) {
ffffffffc02017f8:	02059813          	slli	a6,a1,0x20
ffffffffc02017fc:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201800:	97b2                	add	a5,a5,a2
ffffffffc0201802:	02f50c63          	beq	a0,a5,ffffffffc020183a <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0201806:	711c                	ld	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201808:	00d78c63          	beq	a5,a3,ffffffffc0201820 <default_free_pages+0xbc>
        if (base + base->property == p) {
ffffffffc020180c:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc020180e:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p) {
ffffffffc0201812:	02061593          	slli	a1,a2,0x20
ffffffffc0201816:	01a5d713          	srli	a4,a1,0x1a
ffffffffc020181a:	972a                	add	a4,a4,a0
ffffffffc020181c:	04e68c63          	beq	a3,a4,ffffffffc0201874 <default_free_pages+0x110>
}
ffffffffc0201820:	60a2                	ld	ra,8(sp)
ffffffffc0201822:	0141                	addi	sp,sp,16
ffffffffc0201824:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201826:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201828:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020182a:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc020182c:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020182e:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201830:	02d70f63          	beq	a4,a3,ffffffffc020186e <default_free_pages+0x10a>
ffffffffc0201834:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0201836:	87ba                	mv	a5,a4
ffffffffc0201838:	bf71                	j	ffffffffc02017d4 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc020183a:	491c                	lw	a5,16(a0)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020183c:	5875                	li	a6,-3
ffffffffc020183e:	9fad                	addw	a5,a5,a1
ffffffffc0201840:	fef72c23          	sw	a5,-8(a4)
ffffffffc0201844:	6108b02f          	amoand.d	zero,a6,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201848:	01853803          	ld	a6,24(a0)
ffffffffc020184c:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc020184e:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc0201850:	00b83423          	sd	a1,8(a6) # ff0008 <_binary_obj___user_matrix_out_size+0xfe4920>
    return listelm->next;
ffffffffc0201854:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0201856:	0105b023          	sd	a6,0(a1)
ffffffffc020185a:	b77d                	j	ffffffffc0201808 <default_free_pages+0xa4>
}
ffffffffc020185c:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020185e:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc0201862:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201864:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc0201866:	e398                	sd	a4,0(a5)
ffffffffc0201868:	e798                	sd	a4,8(a5)
}
ffffffffc020186a:	0141                	addi	sp,sp,16
ffffffffc020186c:	8082                	ret
ffffffffc020186e:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc0201870:	873e                	mv	a4,a5
ffffffffc0201872:	bfad                	j	ffffffffc02017ec <default_free_pages+0x88>
            base->property += p->property;
ffffffffc0201874:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201878:	56f5                	li	a3,-3
ffffffffc020187a:	9f31                	addw	a4,a4,a2
ffffffffc020187c:	c918                	sw	a4,16(a0)
ffffffffc020187e:	ff078713          	addi	a4,a5,-16
ffffffffc0201882:	60d7302f          	amoand.d	zero,a3,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201886:	6398                	ld	a4,0(a5)
ffffffffc0201888:	679c                	ld	a5,8(a5)
}
ffffffffc020188a:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc020188c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020188e:	e398                	sd	a4,0(a5)
ffffffffc0201890:	0141                	addi	sp,sp,16
ffffffffc0201892:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201894:	00006697          	auipc	a3,0x6
ffffffffc0201898:	c8468693          	addi	a3,a3,-892 # ffffffffc0207518 <etext+0xdb6>
ffffffffc020189c:	00005617          	auipc	a2,0x5
ffffffffc02018a0:	67460613          	addi	a2,a2,1652 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02018a4:	08200593          	li	a1,130
ffffffffc02018a8:	00006517          	auipc	a0,0x6
ffffffffc02018ac:	92850513          	addi	a0,a0,-1752 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc02018b0:	b9bfe0ef          	jal	ffffffffc020044a <__panic>
    assert(n > 0);
ffffffffc02018b4:	00006697          	auipc	a3,0x6
ffffffffc02018b8:	c5c68693          	addi	a3,a3,-932 # ffffffffc0207510 <etext+0xdae>
ffffffffc02018bc:	00005617          	auipc	a2,0x5
ffffffffc02018c0:	65460613          	addi	a2,a2,1620 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02018c4:	07f00593          	li	a1,127
ffffffffc02018c8:	00006517          	auipc	a0,0x6
ffffffffc02018cc:	90850513          	addi	a0,a0,-1784 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc02018d0:	b7bfe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02018d4 <default_alloc_pages>:
    assert(n > 0);
ffffffffc02018d4:	c951                	beqz	a0,ffffffffc0201968 <default_alloc_pages+0x94>
    if (n > nr_free) {
ffffffffc02018d6:	000c7597          	auipc	a1,0xc7
ffffffffc02018da:	8825a583          	lw	a1,-1918(a1) # ffffffffc02c8158 <free_area+0x10>
ffffffffc02018de:	86aa                	mv	a3,a0
ffffffffc02018e0:	02059793          	slli	a5,a1,0x20
ffffffffc02018e4:	9381                	srli	a5,a5,0x20
ffffffffc02018e6:	00a7ef63          	bltu	a5,a0,ffffffffc0201904 <default_alloc_pages+0x30>
    list_entry_t *le = &free_list;
ffffffffc02018ea:	000c7617          	auipc	a2,0xc7
ffffffffc02018ee:	85e60613          	addi	a2,a2,-1954 # ffffffffc02c8148 <free_area>
ffffffffc02018f2:	87b2                	mv	a5,a2
ffffffffc02018f4:	a029                	j	ffffffffc02018fe <default_alloc_pages+0x2a>
        if (p->property >= n) {
ffffffffc02018f6:	ff87e703          	lwu	a4,-8(a5)
ffffffffc02018fa:	00d77763          	bgeu	a4,a3,ffffffffc0201908 <default_alloc_pages+0x34>
    return listelm->next;
ffffffffc02018fe:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201900:	fec79be3          	bne	a5,a2,ffffffffc02018f6 <default_alloc_pages+0x22>
        return NULL;
ffffffffc0201904:	4501                	li	a0,0
}
ffffffffc0201906:	8082                	ret
        if (page->property > n) {
ffffffffc0201908:	ff87a883          	lw	a7,-8(a5)
    return listelm->prev;
ffffffffc020190c:	0007b803          	ld	a6,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201910:	6798                	ld	a4,8(a5)
ffffffffc0201912:	02089313          	slli	t1,a7,0x20
ffffffffc0201916:	02035313          	srli	t1,t1,0x20
    prev->next = next;
ffffffffc020191a:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc020191e:	01073023          	sd	a6,0(a4)
        struct Page *p = le2page(le, page_link);
ffffffffc0201922:	fe878513          	addi	a0,a5,-24
        if (page->property > n) {
ffffffffc0201926:	0266fa63          	bgeu	a3,t1,ffffffffc020195a <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc020192a:	00669713          	slli	a4,a3,0x6
            p->property = page->property - n;
ffffffffc020192e:	40d888bb          	subw	a7,a7,a3
            struct Page *p = page + n;
ffffffffc0201932:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201934:	01172823          	sw	a7,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201938:	00870313          	addi	t1,a4,8
ffffffffc020193c:	4889                	li	a7,2
ffffffffc020193e:	4113302f          	amoor.d	zero,a7,(t1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201942:	00883883          	ld	a7,8(a6)
            list_add(prev, &(p->page_link));
ffffffffc0201946:	01870313          	addi	t1,a4,24
    prev->next = next->prev = elm;
ffffffffc020194a:	0068b023          	sd	t1,0(a7)
ffffffffc020194e:	00683423          	sd	t1,8(a6)
    elm->next = next;
ffffffffc0201952:	03173023          	sd	a7,32(a4)
    elm->prev = prev;
ffffffffc0201956:	01073c23          	sd	a6,24(a4)
        nr_free -= n;
ffffffffc020195a:	9d95                	subw	a1,a1,a3
ffffffffc020195c:	ca0c                	sw	a1,16(a2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020195e:	5775                	li	a4,-3
ffffffffc0201960:	17c1                	addi	a5,a5,-16
ffffffffc0201962:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201966:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc0201968:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc020196a:	00006697          	auipc	a3,0x6
ffffffffc020196e:	ba668693          	addi	a3,a3,-1114 # ffffffffc0207510 <etext+0xdae>
ffffffffc0201972:	00005617          	auipc	a2,0x5
ffffffffc0201976:	59e60613          	addi	a2,a2,1438 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020197a:	06100593          	li	a1,97
ffffffffc020197e:	00006517          	auipc	a0,0x6
ffffffffc0201982:	85250513          	addi	a0,a0,-1966 # ffffffffc02071d0 <etext+0xa6e>
default_alloc_pages(size_t n) {
ffffffffc0201986:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201988:	ac3fe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020198c <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc020198c:	1141                	addi	sp,sp,-16
ffffffffc020198e:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201990:	c9e1                	beqz	a1,ffffffffc0201a60 <default_init_memmap+0xd4>
    for (; p != base + n; p ++) {
ffffffffc0201992:	00659713          	slli	a4,a1,0x6
ffffffffc0201996:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc020199a:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc020199c:	cf11                	beqz	a4,ffffffffc02019b8 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020199e:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02019a0:	8b05                	andi	a4,a4,1
ffffffffc02019a2:	cf59                	beqz	a4,ffffffffc0201a40 <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc02019a4:	0007a823          	sw	zero,16(a5)
ffffffffc02019a8:	0007b423          	sd	zero,8(a5)
ffffffffc02019ac:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02019b0:	04078793          	addi	a5,a5,64
ffffffffc02019b4:	fed795e3          	bne	a5,a3,ffffffffc020199e <default_init_memmap+0x12>
    base->property = n;
ffffffffc02019b8:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02019ba:	4789                	li	a5,2
ffffffffc02019bc:	00850713          	addi	a4,a0,8
ffffffffc02019c0:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02019c4:	000c6717          	auipc	a4,0xc6
ffffffffc02019c8:	79472703          	lw	a4,1940(a4) # ffffffffc02c8158 <free_area+0x10>
ffffffffc02019cc:	000c6697          	auipc	a3,0xc6
ffffffffc02019d0:	77c68693          	addi	a3,a3,1916 # ffffffffc02c8148 <free_area>
    return list->next == list;
ffffffffc02019d4:	669c                	ld	a5,8(a3)
ffffffffc02019d6:	9f2d                	addw	a4,a4,a1
ffffffffc02019d8:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc02019da:	04d78663          	beq	a5,a3,ffffffffc0201a26 <default_init_memmap+0x9a>
            struct Page* page = le2page(le, page_link);
ffffffffc02019de:	fe878713          	addi	a4,a5,-24
ffffffffc02019e2:	4581                	li	a1,0
ffffffffc02019e4:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc02019e8:	00e56a63          	bltu	a0,a4,ffffffffc02019fc <default_init_memmap+0x70>
    return listelm->next;
ffffffffc02019ec:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc02019ee:	02d70263          	beq	a4,a3,ffffffffc0201a12 <default_init_memmap+0x86>
    struct Page *p = base;
ffffffffc02019f2:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc02019f4:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc02019f8:	fee57ae3          	bgeu	a0,a4,ffffffffc02019ec <default_init_memmap+0x60>
ffffffffc02019fc:	c199                	beqz	a1,ffffffffc0201a02 <default_init_memmap+0x76>
ffffffffc02019fe:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201a02:	6398                	ld	a4,0(a5)
}
ffffffffc0201a04:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201a06:	e390                	sd	a2,0(a5)
ffffffffc0201a08:	e710                	sd	a2,8(a4)
    elm->prev = prev;
ffffffffc0201a0a:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc0201a0c:	f11c                	sd	a5,32(a0)
ffffffffc0201a0e:	0141                	addi	sp,sp,16
ffffffffc0201a10:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201a12:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201a14:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201a16:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201a18:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201a1a:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201a1c:	00d70e63          	beq	a4,a3,ffffffffc0201a38 <default_init_memmap+0xac>
ffffffffc0201a20:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0201a22:	87ba                	mv	a5,a4
ffffffffc0201a24:	bfc1                	j	ffffffffc02019f4 <default_init_memmap+0x68>
}
ffffffffc0201a26:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201a28:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc0201a2c:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201a2e:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc0201a30:	e398                	sd	a4,0(a5)
ffffffffc0201a32:	e798                	sd	a4,8(a5)
}
ffffffffc0201a34:	0141                	addi	sp,sp,16
ffffffffc0201a36:	8082                	ret
ffffffffc0201a38:	60a2                	ld	ra,8(sp)
ffffffffc0201a3a:	e290                	sd	a2,0(a3)
ffffffffc0201a3c:	0141                	addi	sp,sp,16
ffffffffc0201a3e:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201a40:	00006697          	auipc	a3,0x6
ffffffffc0201a44:	b0068693          	addi	a3,a3,-1280 # ffffffffc0207540 <etext+0xdde>
ffffffffc0201a48:	00005617          	auipc	a2,0x5
ffffffffc0201a4c:	4c860613          	addi	a2,a2,1224 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201a50:	04800593          	li	a1,72
ffffffffc0201a54:	00005517          	auipc	a0,0x5
ffffffffc0201a58:	77c50513          	addi	a0,a0,1916 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201a5c:	9effe0ef          	jal	ffffffffc020044a <__panic>
    assert(n > 0);
ffffffffc0201a60:	00006697          	auipc	a3,0x6
ffffffffc0201a64:	ab068693          	addi	a3,a3,-1360 # ffffffffc0207510 <etext+0xdae>
ffffffffc0201a68:	00005617          	auipc	a2,0x5
ffffffffc0201a6c:	4a860613          	addi	a2,a2,1192 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201a70:	04500593          	li	a1,69
ffffffffc0201a74:	00005517          	auipc	a0,0x5
ffffffffc0201a78:	75c50513          	addi	a0,a0,1884 # ffffffffc02071d0 <etext+0xa6e>
ffffffffc0201a7c:	9cffe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201a80 <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201a80:	c531                	beqz	a0,ffffffffc0201acc <slob_free+0x4c>
		return;

	if (size)
ffffffffc0201a82:	e9b9                	bnez	a1,ffffffffc0201ad8 <slob_free+0x58>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a84:	100027f3          	csrr	a5,sstatus
ffffffffc0201a88:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201a8a:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201a8c:	efb1                	bnez	a5,ffffffffc0201ae8 <slob_free+0x68>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a8e:	000c6797          	auipc	a5,0xc6
ffffffffc0201a92:	2a27b783          	ld	a5,674(a5) # ffffffffc02c7d30 <slobfree>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a96:	873e                	mv	a4,a5
ffffffffc0201a98:	679c                	ld	a5,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a9a:	02a77a63          	bgeu	a4,a0,ffffffffc0201ace <slob_free+0x4e>
ffffffffc0201a9e:	00f56463          	bltu	a0,a5,ffffffffc0201aa6 <slob_free+0x26>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201aa2:	fef76ae3          	bltu	a4,a5,ffffffffc0201a96 <slob_free+0x16>
			break;

	if (b + b->units == cur->next)
ffffffffc0201aa6:	4110                	lw	a2,0(a0)
ffffffffc0201aa8:	00461693          	slli	a3,a2,0x4
ffffffffc0201aac:	96aa                	add	a3,a3,a0
ffffffffc0201aae:	0ad78463          	beq	a5,a3,ffffffffc0201b56 <slob_free+0xd6>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc0201ab2:	4310                	lw	a2,0(a4)
ffffffffc0201ab4:	e51c                	sd	a5,8(a0)
ffffffffc0201ab6:	00461693          	slli	a3,a2,0x4
ffffffffc0201aba:	96ba                	add	a3,a3,a4
ffffffffc0201abc:	08d50163          	beq	a0,a3,ffffffffc0201b3e <slob_free+0xbe>
ffffffffc0201ac0:	e708                	sd	a0,8(a4)
		cur->next = b->next;
	}
	else
		cur->next = b;

	slobfree = cur;
ffffffffc0201ac2:	000c6797          	auipc	a5,0xc6
ffffffffc0201ac6:	26e7b723          	sd	a4,622(a5) # ffffffffc02c7d30 <slobfree>
    if (flag) {
ffffffffc0201aca:	e9a5                	bnez	a1,ffffffffc0201b3a <slob_free+0xba>
ffffffffc0201acc:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201ace:	fcf574e3          	bgeu	a0,a5,ffffffffc0201a96 <slob_free+0x16>
ffffffffc0201ad2:	fcf762e3          	bltu	a4,a5,ffffffffc0201a96 <slob_free+0x16>
ffffffffc0201ad6:	bfc1                	j	ffffffffc0201aa6 <slob_free+0x26>
		b->units = SLOB_UNITS(size);
ffffffffc0201ad8:	25bd                	addiw	a1,a1,15
ffffffffc0201ada:	8191                	srli	a1,a1,0x4
ffffffffc0201adc:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ade:	100027f3          	csrr	a5,sstatus
ffffffffc0201ae2:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201ae4:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ae6:	d7c5                	beqz	a5,ffffffffc0201a8e <slob_free+0xe>
{
ffffffffc0201ae8:	1101                	addi	sp,sp,-32
ffffffffc0201aea:	e42a                	sd	a0,8(sp)
ffffffffc0201aec:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201aee:	e11fe0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc0201af2:	6522                	ld	a0,8(sp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201af4:	000c6797          	auipc	a5,0xc6
ffffffffc0201af8:	23c7b783          	ld	a5,572(a5) # ffffffffc02c7d30 <slobfree>
ffffffffc0201afc:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201afe:	873e                	mv	a4,a5
ffffffffc0201b00:	679c                	ld	a5,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201b02:	06a77663          	bgeu	a4,a0,ffffffffc0201b6e <slob_free+0xee>
ffffffffc0201b06:	00f56463          	bltu	a0,a5,ffffffffc0201b0e <slob_free+0x8e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201b0a:	fef76ae3          	bltu	a4,a5,ffffffffc0201afe <slob_free+0x7e>
	if (b + b->units == cur->next)
ffffffffc0201b0e:	4110                	lw	a2,0(a0)
ffffffffc0201b10:	00461693          	slli	a3,a2,0x4
ffffffffc0201b14:	96aa                	add	a3,a3,a0
ffffffffc0201b16:	06d78363          	beq	a5,a3,ffffffffc0201b7c <slob_free+0xfc>
	if (cur + cur->units == b)
ffffffffc0201b1a:	4310                	lw	a2,0(a4)
ffffffffc0201b1c:	e51c                	sd	a5,8(a0)
ffffffffc0201b1e:	00461693          	slli	a3,a2,0x4
ffffffffc0201b22:	96ba                	add	a3,a3,a4
ffffffffc0201b24:	06d50163          	beq	a0,a3,ffffffffc0201b86 <slob_free+0x106>
ffffffffc0201b28:	e708                	sd	a0,8(a4)
	slobfree = cur;
ffffffffc0201b2a:	000c6797          	auipc	a5,0xc6
ffffffffc0201b2e:	20e7b323          	sd	a4,518(a5) # ffffffffc02c7d30 <slobfree>
    if (flag) {
ffffffffc0201b32:	e1a9                	bnez	a1,ffffffffc0201b74 <slob_free+0xf4>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201b34:	60e2                	ld	ra,24(sp)
ffffffffc0201b36:	6105                	addi	sp,sp,32
ffffffffc0201b38:	8082                	ret
        intr_enable();
ffffffffc0201b3a:	dbffe06f          	j	ffffffffc02008f8 <intr_enable>
		cur->units += b->units;
ffffffffc0201b3e:	4114                	lw	a3,0(a0)
		cur->next = b->next;
ffffffffc0201b40:	853e                	mv	a0,a5
ffffffffc0201b42:	e708                	sd	a0,8(a4)
		cur->units += b->units;
ffffffffc0201b44:	00c687bb          	addw	a5,a3,a2
ffffffffc0201b48:	c31c                	sw	a5,0(a4)
	slobfree = cur;
ffffffffc0201b4a:	000c6797          	auipc	a5,0xc6
ffffffffc0201b4e:	1ee7b323          	sd	a4,486(a5) # ffffffffc02c7d30 <slobfree>
    if (flag) {
ffffffffc0201b52:	ddad                	beqz	a1,ffffffffc0201acc <slob_free+0x4c>
ffffffffc0201b54:	b7dd                	j	ffffffffc0201b3a <slob_free+0xba>
		b->units += cur->next->units;
ffffffffc0201b56:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201b58:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201b5a:	9eb1                	addw	a3,a3,a2
ffffffffc0201b5c:	c114                	sw	a3,0(a0)
	if (cur + cur->units == b)
ffffffffc0201b5e:	4310                	lw	a2,0(a4)
ffffffffc0201b60:	e51c                	sd	a5,8(a0)
ffffffffc0201b62:	00461693          	slli	a3,a2,0x4
ffffffffc0201b66:	96ba                	add	a3,a3,a4
ffffffffc0201b68:	f4d51ce3          	bne	a0,a3,ffffffffc0201ac0 <slob_free+0x40>
ffffffffc0201b6c:	bfc9                	j	ffffffffc0201b3e <slob_free+0xbe>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201b6e:	f8f56ee3          	bltu	a0,a5,ffffffffc0201b0a <slob_free+0x8a>
ffffffffc0201b72:	b771                	j	ffffffffc0201afe <slob_free+0x7e>
}
ffffffffc0201b74:	60e2                	ld	ra,24(sp)
ffffffffc0201b76:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201b78:	d81fe06f          	j	ffffffffc02008f8 <intr_enable>
		b->units += cur->next->units;
ffffffffc0201b7c:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201b7e:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201b80:	9eb1                	addw	a3,a3,a2
ffffffffc0201b82:	c114                	sw	a3,0(a0)
		b->next = cur->next->next;
ffffffffc0201b84:	bf59                	j	ffffffffc0201b1a <slob_free+0x9a>
		cur->units += b->units;
ffffffffc0201b86:	4114                	lw	a3,0(a0)
		cur->next = b->next;
ffffffffc0201b88:	853e                	mv	a0,a5
		cur->units += b->units;
ffffffffc0201b8a:	00c687bb          	addw	a5,a3,a2
ffffffffc0201b8e:	c31c                	sw	a5,0(a4)
		cur->next = b->next;
ffffffffc0201b90:	bf61                	j	ffffffffc0201b28 <slob_free+0xa8>

ffffffffc0201b92 <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201b92:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201b94:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201b96:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201b9a:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201b9c:	32c000ef          	jal	ffffffffc0201ec8 <alloc_pages>
	if (!page)
ffffffffc0201ba0:	c91d                	beqz	a0,ffffffffc0201bd6 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201ba2:	000ca697          	auipc	a3,0xca
ffffffffc0201ba6:	79e6b683          	ld	a3,1950(a3) # ffffffffc02cc340 <pages>
ffffffffc0201baa:	00008797          	auipc	a5,0x8
ffffffffc0201bae:	b567b783          	ld	a5,-1194(a5) # ffffffffc0209700 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201bb2:	000ca717          	auipc	a4,0xca
ffffffffc0201bb6:	78673703          	ld	a4,1926(a4) # ffffffffc02cc338 <npage>
    return page - pages + nbase;
ffffffffc0201bba:	8d15                	sub	a0,a0,a3
ffffffffc0201bbc:	8519                	srai	a0,a0,0x6
ffffffffc0201bbe:	953e                	add	a0,a0,a5
    return KADDR(page2pa(page));
ffffffffc0201bc0:	00c51793          	slli	a5,a0,0xc
ffffffffc0201bc4:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201bc6:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201bc8:	00e7fa63          	bgeu	a5,a4,ffffffffc0201bdc <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201bcc:	000ca797          	auipc	a5,0xca
ffffffffc0201bd0:	7647b783          	ld	a5,1892(a5) # ffffffffc02cc330 <va_pa_offset>
ffffffffc0201bd4:	953e                	add	a0,a0,a5
}
ffffffffc0201bd6:	60a2                	ld	ra,8(sp)
ffffffffc0201bd8:	0141                	addi	sp,sp,16
ffffffffc0201bda:	8082                	ret
ffffffffc0201bdc:	86aa                	mv	a3,a0
ffffffffc0201bde:	00006617          	auipc	a2,0x6
ffffffffc0201be2:	98a60613          	addi	a2,a2,-1654 # ffffffffc0207568 <etext+0xe06>
ffffffffc0201be6:	07100593          	li	a1,113
ffffffffc0201bea:	00006517          	auipc	a0,0x6
ffffffffc0201bee:	9a650513          	addi	a0,a0,-1626 # ffffffffc0207590 <etext+0xe2e>
ffffffffc0201bf2:	859fe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201bf6 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201bf6:	7179                	addi	sp,sp,-48
ffffffffc0201bf8:	f406                	sd	ra,40(sp)
ffffffffc0201bfa:	f022                	sd	s0,32(sp)
ffffffffc0201bfc:	ec26                	sd	s1,24(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201bfe:	01050713          	addi	a4,a0,16
ffffffffc0201c02:	6785                	lui	a5,0x1
ffffffffc0201c04:	0af77e63          	bgeu	a4,a5,ffffffffc0201cc0 <slob_alloc.constprop.0+0xca>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201c08:	00f50413          	addi	s0,a0,15
ffffffffc0201c0c:	8011                	srli	s0,s0,0x4
ffffffffc0201c0e:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c10:	100025f3          	csrr	a1,sstatus
ffffffffc0201c14:	8989                	andi	a1,a1,2
ffffffffc0201c16:	edd1                	bnez	a1,ffffffffc0201cb2 <slob_alloc.constprop.0+0xbc>
	prev = slobfree;
ffffffffc0201c18:	000c6497          	auipc	s1,0xc6
ffffffffc0201c1c:	11848493          	addi	s1,s1,280 # ffffffffc02c7d30 <slobfree>
ffffffffc0201c20:	6090                	ld	a2,0(s1)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201c22:	6618                	ld	a4,8(a2)
		if (cur->units >= units + delta)
ffffffffc0201c24:	4314                	lw	a3,0(a4)
ffffffffc0201c26:	0886da63          	bge	a3,s0,ffffffffc0201cba <slob_alloc.constprop.0+0xc4>
		if (cur == slobfree)
ffffffffc0201c2a:	00e60a63          	beq	a2,a4,ffffffffc0201c3e <slob_alloc.constprop.0+0x48>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201c2e:	671c                	ld	a5,8(a4)
		if (cur->units >= units + delta)
ffffffffc0201c30:	4394                	lw	a3,0(a5)
ffffffffc0201c32:	0286d863          	bge	a3,s0,ffffffffc0201c62 <slob_alloc.constprop.0+0x6c>
		if (cur == slobfree)
ffffffffc0201c36:	6090                	ld	a2,0(s1)
ffffffffc0201c38:	873e                	mv	a4,a5
ffffffffc0201c3a:	fee61ae3          	bne	a2,a4,ffffffffc0201c2e <slob_alloc.constprop.0+0x38>
    if (flag) {
ffffffffc0201c3e:	e9b1                	bnez	a1,ffffffffc0201c92 <slob_alloc.constprop.0+0x9c>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201c40:	4501                	li	a0,0
ffffffffc0201c42:	f51ff0ef          	jal	ffffffffc0201b92 <__slob_get_free_pages.constprop.0>
ffffffffc0201c46:	87aa                	mv	a5,a0
			if (!cur)
ffffffffc0201c48:	c915                	beqz	a0,ffffffffc0201c7c <slob_alloc.constprop.0+0x86>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201c4a:	6585                	lui	a1,0x1
ffffffffc0201c4c:	e35ff0ef          	jal	ffffffffc0201a80 <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201c50:	100025f3          	csrr	a1,sstatus
ffffffffc0201c54:	8989                	andi	a1,a1,2
ffffffffc0201c56:	e98d                	bnez	a1,ffffffffc0201c88 <slob_alloc.constprop.0+0x92>
			cur = slobfree;
ffffffffc0201c58:	6098                	ld	a4,0(s1)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201c5a:	671c                	ld	a5,8(a4)
		if (cur->units >= units + delta)
ffffffffc0201c5c:	4394                	lw	a3,0(a5)
ffffffffc0201c5e:	fc86cce3          	blt	a3,s0,ffffffffc0201c36 <slob_alloc.constprop.0+0x40>
			if (cur->units == units)	/* exact fit? */
ffffffffc0201c62:	04d40563          	beq	s0,a3,ffffffffc0201cac <slob_alloc.constprop.0+0xb6>
				prev->next = cur + units;
ffffffffc0201c66:	00441613          	slli	a2,s0,0x4
ffffffffc0201c6a:	963e                	add	a2,a2,a5
ffffffffc0201c6c:	e710                	sd	a2,8(a4)
				prev->next->next = cur->next;
ffffffffc0201c6e:	6788                	ld	a0,8(a5)
				prev->next->units = cur->units - units;
ffffffffc0201c70:	9e81                	subw	a3,a3,s0
ffffffffc0201c72:	c214                	sw	a3,0(a2)
				prev->next->next = cur->next;
ffffffffc0201c74:	e608                	sd	a0,8(a2)
				cur->units = units;
ffffffffc0201c76:	c380                	sw	s0,0(a5)
			slobfree = prev;
ffffffffc0201c78:	e098                	sd	a4,0(s1)
    if (flag) {
ffffffffc0201c7a:	ed99                	bnez	a1,ffffffffc0201c98 <slob_alloc.constprop.0+0xa2>
}
ffffffffc0201c7c:	70a2                	ld	ra,40(sp)
ffffffffc0201c7e:	7402                	ld	s0,32(sp)
ffffffffc0201c80:	64e2                	ld	s1,24(sp)
ffffffffc0201c82:	853e                	mv	a0,a5
ffffffffc0201c84:	6145                	addi	sp,sp,48
ffffffffc0201c86:	8082                	ret
        intr_disable();
ffffffffc0201c88:	c77fe0ef          	jal	ffffffffc02008fe <intr_disable>
			cur = slobfree;
ffffffffc0201c8c:	6098                	ld	a4,0(s1)
        return 1;
ffffffffc0201c8e:	4585                	li	a1,1
ffffffffc0201c90:	b7e9                	j	ffffffffc0201c5a <slob_alloc.constprop.0+0x64>
        intr_enable();
ffffffffc0201c92:	c67fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0201c96:	b76d                	j	ffffffffc0201c40 <slob_alloc.constprop.0+0x4a>
ffffffffc0201c98:	e43e                	sd	a5,8(sp)
ffffffffc0201c9a:	c5ffe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0201c9e:	67a2                	ld	a5,8(sp)
}
ffffffffc0201ca0:	70a2                	ld	ra,40(sp)
ffffffffc0201ca2:	7402                	ld	s0,32(sp)
ffffffffc0201ca4:	64e2                	ld	s1,24(sp)
ffffffffc0201ca6:	853e                	mv	a0,a5
ffffffffc0201ca8:	6145                	addi	sp,sp,48
ffffffffc0201caa:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201cac:	6794                	ld	a3,8(a5)
ffffffffc0201cae:	e714                	sd	a3,8(a4)
ffffffffc0201cb0:	b7e1                	j	ffffffffc0201c78 <slob_alloc.constprop.0+0x82>
        intr_disable();
ffffffffc0201cb2:	c4dfe0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc0201cb6:	4585                	li	a1,1
ffffffffc0201cb8:	b785                	j	ffffffffc0201c18 <slob_alloc.constprop.0+0x22>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201cba:	87ba                	mv	a5,a4
	prev = slobfree;
ffffffffc0201cbc:	8732                	mv	a4,a2
ffffffffc0201cbe:	b755                	j	ffffffffc0201c62 <slob_alloc.constprop.0+0x6c>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201cc0:	00006697          	auipc	a3,0x6
ffffffffc0201cc4:	8e068693          	addi	a3,a3,-1824 # ffffffffc02075a0 <etext+0xe3e>
ffffffffc0201cc8:	00005617          	auipc	a2,0x5
ffffffffc0201ccc:	24860613          	addi	a2,a2,584 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0201cd0:	06300593          	li	a1,99
ffffffffc0201cd4:	00006517          	auipc	a0,0x6
ffffffffc0201cd8:	8ec50513          	addi	a0,a0,-1812 # ffffffffc02075c0 <etext+0xe5e>
ffffffffc0201cdc:	f6efe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201ce0 <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc0201ce0:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc0201ce2:	00006517          	auipc	a0,0x6
ffffffffc0201ce6:	8f650513          	addi	a0,a0,-1802 # ffffffffc02075d8 <etext+0xe76>
{
ffffffffc0201cea:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc0201cec:	cacfe0ef          	jal	ffffffffc0200198 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201cf0:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201cf2:	00006517          	auipc	a0,0x6
ffffffffc0201cf6:	8fe50513          	addi	a0,a0,-1794 # ffffffffc02075f0 <etext+0xe8e>
}
ffffffffc0201cfa:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201cfc:	c9cfe06f          	j	ffffffffc0200198 <cprintf>

ffffffffc0201d00 <kallocated>:

size_t
kallocated(void)
{
	return slob_allocated();
}
ffffffffc0201d00:	4501                	li	a0,0
ffffffffc0201d02:	8082                	ret

ffffffffc0201d04 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201d04:	1101                	addi	sp,sp,-32
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201d06:	6685                	lui	a3,0x1
{
ffffffffc0201d08:	ec06                	sd	ra,24(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201d0a:	16bd                	addi	a3,a3,-17 # fef <_binary_obj___user_softint_out_size-0x80f9>
ffffffffc0201d0c:	04a6f963          	bgeu	a3,a0,ffffffffc0201d5e <kmalloc+0x5a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201d10:	e42a                	sd	a0,8(sp)
ffffffffc0201d12:	4561                	li	a0,24
ffffffffc0201d14:	e822                	sd	s0,16(sp)
ffffffffc0201d16:	ee1ff0ef          	jal	ffffffffc0201bf6 <slob_alloc.constprop.0>
ffffffffc0201d1a:	842a                	mv	s0,a0
	if (!bb)
ffffffffc0201d1c:	c541                	beqz	a0,ffffffffc0201da4 <kmalloc+0xa0>
	bb->order = find_order(size);
ffffffffc0201d1e:	47a2                	lw	a5,8(sp)
	for (; size > 4096; size >>= 1)
ffffffffc0201d20:	6705                	lui	a4,0x1
	int order = 0;
ffffffffc0201d22:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201d24:	00f75763          	bge	a4,a5,ffffffffc0201d32 <kmalloc+0x2e>
ffffffffc0201d28:	4017d79b          	sraiw	a5,a5,0x1
		order++;
ffffffffc0201d2c:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc0201d2e:	fef74de3          	blt	a4,a5,ffffffffc0201d28 <kmalloc+0x24>
	bb->order = find_order(size);
ffffffffc0201d32:	c008                	sw	a0,0(s0)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201d34:	e5fff0ef          	jal	ffffffffc0201b92 <__slob_get_free_pages.constprop.0>
ffffffffc0201d38:	e408                	sd	a0,8(s0)
	if (bb->pages)
ffffffffc0201d3a:	cd31                	beqz	a0,ffffffffc0201d96 <kmalloc+0x92>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201d3c:	100027f3          	csrr	a5,sstatus
ffffffffc0201d40:	8b89                	andi	a5,a5,2
ffffffffc0201d42:	eb85                	bnez	a5,ffffffffc0201d72 <kmalloc+0x6e>
		bb->next = bigblocks;
ffffffffc0201d44:	000ca797          	auipc	a5,0xca
ffffffffc0201d48:	5cc7b783          	ld	a5,1484(a5) # ffffffffc02cc310 <bigblocks>
		bigblocks = bb;
ffffffffc0201d4c:	000ca717          	auipc	a4,0xca
ffffffffc0201d50:	5c873223          	sd	s0,1476(a4) # ffffffffc02cc310 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201d54:	e81c                	sd	a5,16(s0)
    if (flag) {
ffffffffc0201d56:	6442                	ld	s0,16(sp)
	return __kmalloc(size, 0);
}
ffffffffc0201d58:	60e2                	ld	ra,24(sp)
ffffffffc0201d5a:	6105                	addi	sp,sp,32
ffffffffc0201d5c:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201d5e:	0541                	addi	a0,a0,16
ffffffffc0201d60:	e97ff0ef          	jal	ffffffffc0201bf6 <slob_alloc.constprop.0>
ffffffffc0201d64:	87aa                	mv	a5,a0
		return m ? (void *)(m + 1) : 0;
ffffffffc0201d66:	0541                	addi	a0,a0,16
ffffffffc0201d68:	fbe5                	bnez	a5,ffffffffc0201d58 <kmalloc+0x54>
		return 0;
ffffffffc0201d6a:	4501                	li	a0,0
}
ffffffffc0201d6c:	60e2                	ld	ra,24(sp)
ffffffffc0201d6e:	6105                	addi	sp,sp,32
ffffffffc0201d70:	8082                	ret
        intr_disable();
ffffffffc0201d72:	b8dfe0ef          	jal	ffffffffc02008fe <intr_disable>
		bb->next = bigblocks;
ffffffffc0201d76:	000ca797          	auipc	a5,0xca
ffffffffc0201d7a:	59a7b783          	ld	a5,1434(a5) # ffffffffc02cc310 <bigblocks>
		bigblocks = bb;
ffffffffc0201d7e:	000ca717          	auipc	a4,0xca
ffffffffc0201d82:	58873923          	sd	s0,1426(a4) # ffffffffc02cc310 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201d86:	e81c                	sd	a5,16(s0)
        intr_enable();
ffffffffc0201d88:	b71fe0ef          	jal	ffffffffc02008f8 <intr_enable>
		return bb->pages;
ffffffffc0201d8c:	6408                	ld	a0,8(s0)
}
ffffffffc0201d8e:	60e2                	ld	ra,24(sp)
		return bb->pages;
ffffffffc0201d90:	6442                	ld	s0,16(sp)
}
ffffffffc0201d92:	6105                	addi	sp,sp,32
ffffffffc0201d94:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d96:	8522                	mv	a0,s0
ffffffffc0201d98:	45e1                	li	a1,24
ffffffffc0201d9a:	ce7ff0ef          	jal	ffffffffc0201a80 <slob_free>
		return 0;
ffffffffc0201d9e:	4501                	li	a0,0
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201da0:	6442                	ld	s0,16(sp)
ffffffffc0201da2:	b7e9                	j	ffffffffc0201d6c <kmalloc+0x68>
ffffffffc0201da4:	6442                	ld	s0,16(sp)
		return 0;
ffffffffc0201da6:	4501                	li	a0,0
ffffffffc0201da8:	b7d1                	j	ffffffffc0201d6c <kmalloc+0x68>

ffffffffc0201daa <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201daa:	c579                	beqz	a0,ffffffffc0201e78 <kfree+0xce>
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201dac:	03451793          	slli	a5,a0,0x34
ffffffffc0201db0:	e3e1                	bnez	a5,ffffffffc0201e70 <kfree+0xc6>
{
ffffffffc0201db2:	1101                	addi	sp,sp,-32
ffffffffc0201db4:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201db6:	100027f3          	csrr	a5,sstatus
ffffffffc0201dba:	8b89                	andi	a5,a5,2
ffffffffc0201dbc:	e7c1                	bnez	a5,ffffffffc0201e44 <kfree+0x9a>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201dbe:	000ca797          	auipc	a5,0xca
ffffffffc0201dc2:	5527b783          	ld	a5,1362(a5) # ffffffffc02cc310 <bigblocks>
    return 0;
ffffffffc0201dc6:	4581                	li	a1,0
ffffffffc0201dc8:	cbad                	beqz	a5,ffffffffc0201e3a <kfree+0x90>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201dca:	000ca617          	auipc	a2,0xca
ffffffffc0201dce:	54660613          	addi	a2,a2,1350 # ffffffffc02cc310 <bigblocks>
ffffffffc0201dd2:	a021                	j	ffffffffc0201dda <kfree+0x30>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201dd4:	01070613          	addi	a2,a4,16
ffffffffc0201dd8:	c3a5                	beqz	a5,ffffffffc0201e38 <kfree+0x8e>
		{
			if (bb->pages == block)
ffffffffc0201dda:	6794                	ld	a3,8(a5)
ffffffffc0201ddc:	873e                	mv	a4,a5
			{
				*last = bb->next;
ffffffffc0201dde:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0201de0:	fea69ae3          	bne	a3,a0,ffffffffc0201dd4 <kfree+0x2a>
				*last = bb->next;
ffffffffc0201de4:	e21c                	sd	a5,0(a2)
    if (flag) {
ffffffffc0201de6:	edb5                	bnez	a1,ffffffffc0201e62 <kfree+0xb8>
    return pa2page(PADDR(kva));
ffffffffc0201de8:	c02007b7          	lui	a5,0xc0200
ffffffffc0201dec:	0af56363          	bltu	a0,a5,ffffffffc0201e92 <kfree+0xe8>
ffffffffc0201df0:	000ca797          	auipc	a5,0xca
ffffffffc0201df4:	5407b783          	ld	a5,1344(a5) # ffffffffc02cc330 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc0201df8:	000ca697          	auipc	a3,0xca
ffffffffc0201dfc:	5406b683          	ld	a3,1344(a3) # ffffffffc02cc338 <npage>
    return pa2page(PADDR(kva));
ffffffffc0201e00:	8d1d                	sub	a0,a0,a5
    if (PPN(pa) >= npage)
ffffffffc0201e02:	00c55793          	srli	a5,a0,0xc
ffffffffc0201e06:	06d7fa63          	bgeu	a5,a3,ffffffffc0201e7a <kfree+0xd0>
    return &pages[PPN(pa) - nbase];
ffffffffc0201e0a:	00008617          	auipc	a2,0x8
ffffffffc0201e0e:	8f663603          	ld	a2,-1802(a2) # ffffffffc0209700 <nbase>
ffffffffc0201e12:	000ca517          	auipc	a0,0xca
ffffffffc0201e16:	52e53503          	ld	a0,1326(a0) # ffffffffc02cc340 <pages>
	free_pages(kva2page((void*)kva), 1 << order);
ffffffffc0201e1a:	4314                	lw	a3,0(a4)
ffffffffc0201e1c:	8f91                	sub	a5,a5,a2
ffffffffc0201e1e:	079a                	slli	a5,a5,0x6
ffffffffc0201e20:	4585                	li	a1,1
ffffffffc0201e22:	953e                	add	a0,a0,a5
ffffffffc0201e24:	00d595bb          	sllw	a1,a1,a3
ffffffffc0201e28:	e03a                	sd	a4,0(sp)
ffffffffc0201e2a:	0d8000ef          	jal	ffffffffc0201f02 <free_pages>
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201e2e:	6502                	ld	a0,0(sp)
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201e30:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201e32:	45e1                	li	a1,24
}
ffffffffc0201e34:	6105                	addi	sp,sp,32
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201e36:	b1a9                	j	ffffffffc0201a80 <slob_free>
ffffffffc0201e38:	e185                	bnez	a1,ffffffffc0201e58 <kfree+0xae>
}
ffffffffc0201e3a:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201e3c:	1541                	addi	a0,a0,-16
ffffffffc0201e3e:	4581                	li	a1,0
}
ffffffffc0201e40:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201e42:	b93d                	j	ffffffffc0201a80 <slob_free>
        intr_disable();
ffffffffc0201e44:	e02a                	sd	a0,0(sp)
ffffffffc0201e46:	ab9fe0ef          	jal	ffffffffc02008fe <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201e4a:	000ca797          	auipc	a5,0xca
ffffffffc0201e4e:	4c67b783          	ld	a5,1222(a5) # ffffffffc02cc310 <bigblocks>
ffffffffc0201e52:	6502                	ld	a0,0(sp)
        return 1;
ffffffffc0201e54:	4585                	li	a1,1
ffffffffc0201e56:	fbb5                	bnez	a5,ffffffffc0201dca <kfree+0x20>
ffffffffc0201e58:	e02a                	sd	a0,0(sp)
        intr_enable();
ffffffffc0201e5a:	a9ffe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0201e5e:	6502                	ld	a0,0(sp)
ffffffffc0201e60:	bfe9                	j	ffffffffc0201e3a <kfree+0x90>
ffffffffc0201e62:	e42a                	sd	a0,8(sp)
ffffffffc0201e64:	e03a                	sd	a4,0(sp)
ffffffffc0201e66:	a93fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0201e6a:	6522                	ld	a0,8(sp)
ffffffffc0201e6c:	6702                	ld	a4,0(sp)
ffffffffc0201e6e:	bfad                	j	ffffffffc0201de8 <kfree+0x3e>
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201e70:	1541                	addi	a0,a0,-16
ffffffffc0201e72:	4581                	li	a1,0
ffffffffc0201e74:	c0dff06f          	j	ffffffffc0201a80 <slob_free>
ffffffffc0201e78:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201e7a:	00005617          	auipc	a2,0x5
ffffffffc0201e7e:	7be60613          	addi	a2,a2,1982 # ffffffffc0207638 <etext+0xed6>
ffffffffc0201e82:	06900593          	li	a1,105
ffffffffc0201e86:	00005517          	auipc	a0,0x5
ffffffffc0201e8a:	70a50513          	addi	a0,a0,1802 # ffffffffc0207590 <etext+0xe2e>
ffffffffc0201e8e:	dbcfe0ef          	jal	ffffffffc020044a <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201e92:	86aa                	mv	a3,a0
ffffffffc0201e94:	00005617          	auipc	a2,0x5
ffffffffc0201e98:	77c60613          	addi	a2,a2,1916 # ffffffffc0207610 <etext+0xeae>
ffffffffc0201e9c:	07700593          	li	a1,119
ffffffffc0201ea0:	00005517          	auipc	a0,0x5
ffffffffc0201ea4:	6f050513          	addi	a0,a0,1776 # ffffffffc0207590 <etext+0xe2e>
ffffffffc0201ea8:	da2fe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201eac <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc0201eac:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201eae:	00005617          	auipc	a2,0x5
ffffffffc0201eb2:	78a60613          	addi	a2,a2,1930 # ffffffffc0207638 <etext+0xed6>
ffffffffc0201eb6:	06900593          	li	a1,105
ffffffffc0201eba:	00005517          	auipc	a0,0x5
ffffffffc0201ebe:	6d650513          	addi	a0,a0,1750 # ffffffffc0207590 <etext+0xe2e>
pa2page(uintptr_t pa)
ffffffffc0201ec2:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201ec4:	d86fe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201ec8 <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201ec8:	100027f3          	csrr	a5,sstatus
ffffffffc0201ecc:	8b89                	andi	a5,a5,2
ffffffffc0201ece:	e799                	bnez	a5,ffffffffc0201edc <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201ed0:	000ca797          	auipc	a5,0xca
ffffffffc0201ed4:	4487b783          	ld	a5,1096(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc0201ed8:	6f9c                	ld	a5,24(a5)
ffffffffc0201eda:	8782                	jr	a5
{
ffffffffc0201edc:	1101                	addi	sp,sp,-32
ffffffffc0201ede:	ec06                	sd	ra,24(sp)
ffffffffc0201ee0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201ee2:	a1dfe0ef          	jal	ffffffffc02008fe <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201ee6:	000ca797          	auipc	a5,0xca
ffffffffc0201eea:	4327b783          	ld	a5,1074(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc0201eee:	6522                	ld	a0,8(sp)
ffffffffc0201ef0:	6f9c                	ld	a5,24(a5)
ffffffffc0201ef2:	9782                	jalr	a5
ffffffffc0201ef4:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201ef6:	a03fe0ef          	jal	ffffffffc02008f8 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201efa:	60e2                	ld	ra,24(sp)
ffffffffc0201efc:	6522                	ld	a0,8(sp)
ffffffffc0201efe:	6105                	addi	sp,sp,32
ffffffffc0201f00:	8082                	ret

ffffffffc0201f02 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f02:	100027f3          	csrr	a5,sstatus
ffffffffc0201f06:	8b89                	andi	a5,a5,2
ffffffffc0201f08:	e799                	bnez	a5,ffffffffc0201f16 <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201f0a:	000ca797          	auipc	a5,0xca
ffffffffc0201f0e:	40e7b783          	ld	a5,1038(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc0201f12:	739c                	ld	a5,32(a5)
ffffffffc0201f14:	8782                	jr	a5
{
ffffffffc0201f16:	1101                	addi	sp,sp,-32
ffffffffc0201f18:	ec06                	sd	ra,24(sp)
ffffffffc0201f1a:	e42e                	sd	a1,8(sp)
ffffffffc0201f1c:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0201f1e:	9e1fe0ef          	jal	ffffffffc02008fe <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201f22:	000ca797          	auipc	a5,0xca
ffffffffc0201f26:	3f67b783          	ld	a5,1014(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc0201f2a:	65a2                	ld	a1,8(sp)
ffffffffc0201f2c:	6502                	ld	a0,0(sp)
ffffffffc0201f2e:	739c                	ld	a5,32(a5)
ffffffffc0201f30:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201f32:	60e2                	ld	ra,24(sp)
ffffffffc0201f34:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201f36:	9c3fe06f          	j	ffffffffc02008f8 <intr_enable>

ffffffffc0201f3a <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f3a:	100027f3          	csrr	a5,sstatus
ffffffffc0201f3e:	8b89                	andi	a5,a5,2
ffffffffc0201f40:	e799                	bnez	a5,ffffffffc0201f4e <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f42:	000ca797          	auipc	a5,0xca
ffffffffc0201f46:	3d67b783          	ld	a5,982(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc0201f4a:	779c                	ld	a5,40(a5)
ffffffffc0201f4c:	8782                	jr	a5
{
ffffffffc0201f4e:	1101                	addi	sp,sp,-32
ffffffffc0201f50:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201f52:	9adfe0ef          	jal	ffffffffc02008fe <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201f56:	000ca797          	auipc	a5,0xca
ffffffffc0201f5a:	3c27b783          	ld	a5,962(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc0201f5e:	779c                	ld	a5,40(a5)
ffffffffc0201f60:	9782                	jalr	a5
ffffffffc0201f62:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201f64:	995fe0ef          	jal	ffffffffc02008f8 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201f68:	60e2                	ld	ra,24(sp)
ffffffffc0201f6a:	6522                	ld	a0,8(sp)
ffffffffc0201f6c:	6105                	addi	sp,sp,32
ffffffffc0201f6e:	8082                	ret

ffffffffc0201f70 <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201f70:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201f74:	1ff7f793          	andi	a5,a5,511
ffffffffc0201f78:	078e                	slli	a5,a5,0x3
ffffffffc0201f7a:	00f50733          	add	a4,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc0201f7e:	6314                	ld	a3,0(a4)
{
ffffffffc0201f80:	7139                	addi	sp,sp,-64
ffffffffc0201f82:	f822                	sd	s0,48(sp)
ffffffffc0201f84:	f426                	sd	s1,40(sp)
ffffffffc0201f86:	fc06                	sd	ra,56(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc0201f88:	0016f793          	andi	a5,a3,1
{
ffffffffc0201f8c:	842e                	mv	s0,a1
ffffffffc0201f8e:	8832                	mv	a6,a2
ffffffffc0201f90:	000ca497          	auipc	s1,0xca
ffffffffc0201f94:	3a848493          	addi	s1,s1,936 # ffffffffc02cc338 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc0201f98:	ebd1                	bnez	a5,ffffffffc020202c <get_pte+0xbc>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201f9a:	16060d63          	beqz	a2,ffffffffc0202114 <get_pte+0x1a4>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201f9e:	100027f3          	csrr	a5,sstatus
ffffffffc0201fa2:	8b89                	andi	a5,a5,2
ffffffffc0201fa4:	16079e63          	bnez	a5,ffffffffc0202120 <get_pte+0x1b0>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201fa8:	000ca797          	auipc	a5,0xca
ffffffffc0201fac:	3707b783          	ld	a5,880(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc0201fb0:	4505                	li	a0,1
ffffffffc0201fb2:	e43a                	sd	a4,8(sp)
ffffffffc0201fb4:	6f9c                	ld	a5,24(a5)
ffffffffc0201fb6:	e832                	sd	a2,16(sp)
ffffffffc0201fb8:	9782                	jalr	a5
ffffffffc0201fba:	6722                	ld	a4,8(sp)
ffffffffc0201fbc:	6842                	ld	a6,16(sp)
ffffffffc0201fbe:	87aa                	mv	a5,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201fc0:	14078a63          	beqz	a5,ffffffffc0202114 <get_pte+0x1a4>
    return page - pages + nbase;
ffffffffc0201fc4:	000ca517          	auipc	a0,0xca
ffffffffc0201fc8:	37c53503          	ld	a0,892(a0) # ffffffffc02cc340 <pages>
ffffffffc0201fcc:	000808b7          	lui	a7,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201fd0:	000ca497          	auipc	s1,0xca
ffffffffc0201fd4:	36848493          	addi	s1,s1,872 # ffffffffc02cc338 <npage>
ffffffffc0201fd8:	40a78533          	sub	a0,a5,a0
ffffffffc0201fdc:	8519                	srai	a0,a0,0x6
ffffffffc0201fde:	9546                	add	a0,a0,a7
ffffffffc0201fe0:	6090                	ld	a2,0(s1)
ffffffffc0201fe2:	00c51693          	slli	a3,a0,0xc
    page->ref = val;
ffffffffc0201fe6:	4585                	li	a1,1
ffffffffc0201fe8:	82b1                	srli	a3,a3,0xc
ffffffffc0201fea:	c38c                	sw	a1,0(a5)
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fec:	0532                	slli	a0,a0,0xc
ffffffffc0201fee:	1ac6f763          	bgeu	a3,a2,ffffffffc020219c <get_pte+0x22c>
ffffffffc0201ff2:	000ca697          	auipc	a3,0xca
ffffffffc0201ff6:	33e6b683          	ld	a3,830(a3) # ffffffffc02cc330 <va_pa_offset>
ffffffffc0201ffa:	6605                	lui	a2,0x1
ffffffffc0201ffc:	4581                	li	a1,0
ffffffffc0201ffe:	9536                	add	a0,a0,a3
ffffffffc0202000:	ec42                	sd	a6,24(sp)
ffffffffc0202002:	e83e                	sd	a5,16(sp)
ffffffffc0202004:	e43a                	sd	a4,8(sp)
ffffffffc0202006:	732040ef          	jal	ffffffffc0206738 <memset>
    return page - pages + nbase;
ffffffffc020200a:	000ca697          	auipc	a3,0xca
ffffffffc020200e:	3366b683          	ld	a3,822(a3) # ffffffffc02cc340 <pages>
ffffffffc0202012:	67c2                	ld	a5,16(sp)
ffffffffc0202014:	000808b7          	lui	a7,0x80
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0202018:	6722                	ld	a4,8(sp)
ffffffffc020201a:	40d786b3          	sub	a3,a5,a3
ffffffffc020201e:	8699                	srai	a3,a3,0x6
ffffffffc0202020:	96c6                	add	a3,a3,a7
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202022:	06aa                	slli	a3,a3,0xa
ffffffffc0202024:	6862                	ld	a6,24(sp)
ffffffffc0202026:	0116e693          	ori	a3,a3,17
ffffffffc020202a:	e314                	sd	a3,0(a4)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc020202c:	c006f693          	andi	a3,a3,-1024
ffffffffc0202030:	6098                	ld	a4,0(s1)
ffffffffc0202032:	068a                	slli	a3,a3,0x2
ffffffffc0202034:	00c6d793          	srli	a5,a3,0xc
ffffffffc0202038:	14e7f663          	bgeu	a5,a4,ffffffffc0202184 <get_pte+0x214>
ffffffffc020203c:	000ca897          	auipc	a7,0xca
ffffffffc0202040:	2f488893          	addi	a7,a7,756 # ffffffffc02cc330 <va_pa_offset>
ffffffffc0202044:	0008b603          	ld	a2,0(a7)
ffffffffc0202048:	01545793          	srli	a5,s0,0x15
ffffffffc020204c:	1ff7f793          	andi	a5,a5,511
ffffffffc0202050:	96b2                	add	a3,a3,a2
ffffffffc0202052:	078e                	slli	a5,a5,0x3
ffffffffc0202054:	97b6                	add	a5,a5,a3
    if (!(*pdep0 & PTE_V))
ffffffffc0202056:	6394                	ld	a3,0(a5)
ffffffffc0202058:	0016f613          	andi	a2,a3,1
ffffffffc020205c:	e659                	bnez	a2,ffffffffc02020ea <get_pte+0x17a>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc020205e:	0a080b63          	beqz	a6,ffffffffc0202114 <get_pte+0x1a4>
ffffffffc0202062:	10002773          	csrr	a4,sstatus
ffffffffc0202066:	8b09                	andi	a4,a4,2
ffffffffc0202068:	ef71                	bnez	a4,ffffffffc0202144 <get_pte+0x1d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc020206a:	000ca717          	auipc	a4,0xca
ffffffffc020206e:	2ae73703          	ld	a4,686(a4) # ffffffffc02cc318 <pmm_manager>
ffffffffc0202072:	4505                	li	a0,1
ffffffffc0202074:	e43e                	sd	a5,8(sp)
ffffffffc0202076:	6f18                	ld	a4,24(a4)
ffffffffc0202078:	9702                	jalr	a4
ffffffffc020207a:	67a2                	ld	a5,8(sp)
ffffffffc020207c:	872a                	mv	a4,a0
ffffffffc020207e:	000ca897          	auipc	a7,0xca
ffffffffc0202082:	2b288893          	addi	a7,a7,690 # ffffffffc02cc330 <va_pa_offset>
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202086:	c759                	beqz	a4,ffffffffc0202114 <get_pte+0x1a4>
    return page - pages + nbase;
ffffffffc0202088:	000ca697          	auipc	a3,0xca
ffffffffc020208c:	2b86b683          	ld	a3,696(a3) # ffffffffc02cc340 <pages>
ffffffffc0202090:	00080837          	lui	a6,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202094:	608c                	ld	a1,0(s1)
ffffffffc0202096:	40d706b3          	sub	a3,a4,a3
ffffffffc020209a:	8699                	srai	a3,a3,0x6
ffffffffc020209c:	96c2                	add	a3,a3,a6
ffffffffc020209e:	00c69613          	slli	a2,a3,0xc
    page->ref = val;
ffffffffc02020a2:	4505                	li	a0,1
ffffffffc02020a4:	8231                	srli	a2,a2,0xc
ffffffffc02020a6:	c308                	sw	a0,0(a4)
    return page2ppn(page) << PGSHIFT;
ffffffffc02020a8:	06b2                	slli	a3,a3,0xc
ffffffffc02020aa:	10b67663          	bgeu	a2,a1,ffffffffc02021b6 <get_pte+0x246>
ffffffffc02020ae:	0008b503          	ld	a0,0(a7)
ffffffffc02020b2:	6605                	lui	a2,0x1
ffffffffc02020b4:	4581                	li	a1,0
ffffffffc02020b6:	9536                	add	a0,a0,a3
ffffffffc02020b8:	e83a                	sd	a4,16(sp)
ffffffffc02020ba:	e43e                	sd	a5,8(sp)
ffffffffc02020bc:	67c040ef          	jal	ffffffffc0206738 <memset>
    return page - pages + nbase;
ffffffffc02020c0:	000ca697          	auipc	a3,0xca
ffffffffc02020c4:	2806b683          	ld	a3,640(a3) # ffffffffc02cc340 <pages>
ffffffffc02020c8:	6742                	ld	a4,16(sp)
ffffffffc02020ca:	00080837          	lui	a6,0x80
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02020ce:	67a2                	ld	a5,8(sp)
ffffffffc02020d0:	40d706b3          	sub	a3,a4,a3
ffffffffc02020d4:	8699                	srai	a3,a3,0x6
ffffffffc02020d6:	96c2                	add	a3,a3,a6
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02020d8:	06aa                	slli	a3,a3,0xa
ffffffffc02020da:	0116e693          	ori	a3,a3,17
ffffffffc02020de:	e394                	sd	a3,0(a5)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02020e0:	6098                	ld	a4,0(s1)
ffffffffc02020e2:	000ca897          	auipc	a7,0xca
ffffffffc02020e6:	24e88893          	addi	a7,a7,590 # ffffffffc02cc330 <va_pa_offset>
ffffffffc02020ea:	c006f693          	andi	a3,a3,-1024
ffffffffc02020ee:	068a                	slli	a3,a3,0x2
ffffffffc02020f0:	00c6d793          	srli	a5,a3,0xc
ffffffffc02020f4:	06e7fc63          	bgeu	a5,a4,ffffffffc020216c <get_pte+0x1fc>
ffffffffc02020f8:	0008b783          	ld	a5,0(a7)
ffffffffc02020fc:	8031                	srli	s0,s0,0xc
ffffffffc02020fe:	1ff47413          	andi	s0,s0,511
ffffffffc0202102:	040e                	slli	s0,s0,0x3
ffffffffc0202104:	96be                	add	a3,a3,a5
}
ffffffffc0202106:	70e2                	ld	ra,56(sp)
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202108:	00868533          	add	a0,a3,s0
}
ffffffffc020210c:	7442                	ld	s0,48(sp)
ffffffffc020210e:	74a2                	ld	s1,40(sp)
ffffffffc0202110:	6121                	addi	sp,sp,64
ffffffffc0202112:	8082                	ret
ffffffffc0202114:	70e2                	ld	ra,56(sp)
ffffffffc0202116:	7442                	ld	s0,48(sp)
ffffffffc0202118:	74a2                	ld	s1,40(sp)
            return NULL;
ffffffffc020211a:	4501                	li	a0,0
}
ffffffffc020211c:	6121                	addi	sp,sp,64
ffffffffc020211e:	8082                	ret
        intr_disable();
ffffffffc0202120:	e83a                	sd	a4,16(sp)
ffffffffc0202122:	ec32                	sd	a2,24(sp)
ffffffffc0202124:	fdafe0ef          	jal	ffffffffc02008fe <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202128:	000ca797          	auipc	a5,0xca
ffffffffc020212c:	1f07b783          	ld	a5,496(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc0202130:	4505                	li	a0,1
ffffffffc0202132:	6f9c                	ld	a5,24(a5)
ffffffffc0202134:	9782                	jalr	a5
ffffffffc0202136:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0202138:	fc0fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc020213c:	6862                	ld	a6,24(sp)
ffffffffc020213e:	6742                	ld	a4,16(sp)
ffffffffc0202140:	67a2                	ld	a5,8(sp)
ffffffffc0202142:	bdbd                	j	ffffffffc0201fc0 <get_pte+0x50>
        intr_disable();
ffffffffc0202144:	e83e                	sd	a5,16(sp)
ffffffffc0202146:	fb8fe0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc020214a:	000ca717          	auipc	a4,0xca
ffffffffc020214e:	1ce73703          	ld	a4,462(a4) # ffffffffc02cc318 <pmm_manager>
ffffffffc0202152:	4505                	li	a0,1
ffffffffc0202154:	6f18                	ld	a4,24(a4)
ffffffffc0202156:	9702                	jalr	a4
ffffffffc0202158:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020215a:	f9efe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc020215e:	6722                	ld	a4,8(sp)
ffffffffc0202160:	67c2                	ld	a5,16(sp)
ffffffffc0202162:	000ca897          	auipc	a7,0xca
ffffffffc0202166:	1ce88893          	addi	a7,a7,462 # ffffffffc02cc330 <va_pa_offset>
ffffffffc020216a:	bf31                	j	ffffffffc0202086 <get_pte+0x116>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020216c:	00005617          	auipc	a2,0x5
ffffffffc0202170:	3fc60613          	addi	a2,a2,1020 # ffffffffc0207568 <etext+0xe06>
ffffffffc0202174:	0f900593          	li	a1,249
ffffffffc0202178:	00005517          	auipc	a0,0x5
ffffffffc020217c:	4e050513          	addi	a0,a0,1248 # ffffffffc0207658 <etext+0xef6>
ffffffffc0202180:	acafe0ef          	jal	ffffffffc020044a <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202184:	00005617          	auipc	a2,0x5
ffffffffc0202188:	3e460613          	addi	a2,a2,996 # ffffffffc0207568 <etext+0xe06>
ffffffffc020218c:	0ec00593          	li	a1,236
ffffffffc0202190:	00005517          	auipc	a0,0x5
ffffffffc0202194:	4c850513          	addi	a0,a0,1224 # ffffffffc0207658 <etext+0xef6>
ffffffffc0202198:	ab2fe0ef          	jal	ffffffffc020044a <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020219c:	86aa                	mv	a3,a0
ffffffffc020219e:	00005617          	auipc	a2,0x5
ffffffffc02021a2:	3ca60613          	addi	a2,a2,970 # ffffffffc0207568 <etext+0xe06>
ffffffffc02021a6:	0e800593          	li	a1,232
ffffffffc02021aa:	00005517          	auipc	a0,0x5
ffffffffc02021ae:	4ae50513          	addi	a0,a0,1198 # ffffffffc0207658 <etext+0xef6>
ffffffffc02021b2:	a98fe0ef          	jal	ffffffffc020044a <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02021b6:	00005617          	auipc	a2,0x5
ffffffffc02021ba:	3b260613          	addi	a2,a2,946 # ffffffffc0207568 <etext+0xe06>
ffffffffc02021be:	0f600593          	li	a1,246
ffffffffc02021c2:	00005517          	auipc	a0,0x5
ffffffffc02021c6:	49650513          	addi	a0,a0,1174 # ffffffffc0207658 <etext+0xef6>
ffffffffc02021ca:	a80fe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02021ce <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc02021ce:	1141                	addi	sp,sp,-16
ffffffffc02021d0:	e022                	sd	s0,0(sp)
ffffffffc02021d2:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02021d4:	4601                	li	a2,0
{
ffffffffc02021d6:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02021d8:	d99ff0ef          	jal	ffffffffc0201f70 <get_pte>
    if (ptep_store != NULL)
ffffffffc02021dc:	c011                	beqz	s0,ffffffffc02021e0 <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc02021de:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc02021e0:	c511                	beqz	a0,ffffffffc02021ec <get_page+0x1e>
ffffffffc02021e2:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc02021e4:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc02021e6:	0017f713          	andi	a4,a5,1
ffffffffc02021ea:	e709                	bnez	a4,ffffffffc02021f4 <get_page+0x26>
}
ffffffffc02021ec:	60a2                	ld	ra,8(sp)
ffffffffc02021ee:	6402                	ld	s0,0(sp)
ffffffffc02021f0:	0141                	addi	sp,sp,16
ffffffffc02021f2:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc02021f4:	000ca717          	auipc	a4,0xca
ffffffffc02021f8:	14473703          	ld	a4,324(a4) # ffffffffc02cc338 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc02021fc:	078a                	slli	a5,a5,0x2
ffffffffc02021fe:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202200:	00e7ff63          	bgeu	a5,a4,ffffffffc020221e <get_page+0x50>
    return &pages[PPN(pa) - nbase];
ffffffffc0202204:	000ca517          	auipc	a0,0xca
ffffffffc0202208:	13c53503          	ld	a0,316(a0) # ffffffffc02cc340 <pages>
ffffffffc020220c:	60a2                	ld	ra,8(sp)
ffffffffc020220e:	6402                	ld	s0,0(sp)
ffffffffc0202210:	079a                	slli	a5,a5,0x6
ffffffffc0202212:	fe000737          	lui	a4,0xfe000
ffffffffc0202216:	97ba                	add	a5,a5,a4
ffffffffc0202218:	953e                	add	a0,a0,a5
ffffffffc020221a:	0141                	addi	sp,sp,16
ffffffffc020221c:	8082                	ret
ffffffffc020221e:	c8fff0ef          	jal	ffffffffc0201eac <pa2page.part.0>

ffffffffc0202222 <unmap_range>:
        tlb_invalidate(pgdir, la); //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc0202222:	715d                	addi	sp,sp,-80
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202224:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202228:	e486                	sd	ra,72(sp)
ffffffffc020222a:	e0a2                	sd	s0,64(sp)
ffffffffc020222c:	fc26                	sd	s1,56(sp)
ffffffffc020222e:	f84a                	sd	s2,48(sp)
ffffffffc0202230:	f44e                	sd	s3,40(sp)
ffffffffc0202232:	f052                	sd	s4,32(sp)
ffffffffc0202234:	ec56                	sd	s5,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202236:	03479713          	slli	a4,a5,0x34
ffffffffc020223a:	ef61                	bnez	a4,ffffffffc0202312 <unmap_range+0xf0>
    assert(USER_ACCESS(start, end));
ffffffffc020223c:	00200a37          	lui	s4,0x200
ffffffffc0202240:	00c5b7b3          	sltu	a5,a1,a2
ffffffffc0202244:	0145b733          	sltu	a4,a1,s4
ffffffffc0202248:	0017b793          	seqz	a5,a5
ffffffffc020224c:	8fd9                	or	a5,a5,a4
ffffffffc020224e:	842e                	mv	s0,a1
ffffffffc0202250:	84b2                	mv	s1,a2
ffffffffc0202252:	e3e5                	bnez	a5,ffffffffc0202332 <unmap_range+0x110>
ffffffffc0202254:	4785                	li	a5,1
ffffffffc0202256:	07fe                	slli	a5,a5,0x1f
ffffffffc0202258:	0785                	addi	a5,a5,1
ffffffffc020225a:	892a                	mv	s2,a0
ffffffffc020225c:	6985                	lui	s3,0x1
    do
    {
        pte_t *ptep = get_pte(pgdir, start, 0);
        if (ptep == NULL)
        {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020225e:	ffe00ab7          	lui	s5,0xffe00
    assert(USER_ACCESS(start, end));
ffffffffc0202262:	0cf67863          	bgeu	a2,a5,ffffffffc0202332 <unmap_range+0x110>
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0202266:	4601                	li	a2,0
ffffffffc0202268:	85a2                	mv	a1,s0
ffffffffc020226a:	854a                	mv	a0,s2
ffffffffc020226c:	d05ff0ef          	jal	ffffffffc0201f70 <get_pte>
ffffffffc0202270:	87aa                	mv	a5,a0
        if (ptep == NULL)
ffffffffc0202272:	cd31                	beqz	a0,ffffffffc02022ce <unmap_range+0xac>
            continue;
        }
        if (*ptep != 0)
ffffffffc0202274:	6118                	ld	a4,0(a0)
ffffffffc0202276:	ef11                	bnez	a4,ffffffffc0202292 <unmap_range+0x70>
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0202278:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc020227a:	c019                	beqz	s0,ffffffffc0202280 <unmap_range+0x5e>
ffffffffc020227c:	fe9465e3          	bltu	s0,s1,ffffffffc0202266 <unmap_range+0x44>
}
ffffffffc0202280:	60a6                	ld	ra,72(sp)
ffffffffc0202282:	6406                	ld	s0,64(sp)
ffffffffc0202284:	74e2                	ld	s1,56(sp)
ffffffffc0202286:	7942                	ld	s2,48(sp)
ffffffffc0202288:	79a2                	ld	s3,40(sp)
ffffffffc020228a:	7a02                	ld	s4,32(sp)
ffffffffc020228c:	6ae2                	ld	s5,24(sp)
ffffffffc020228e:	6161                	addi	sp,sp,80
ffffffffc0202290:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc0202292:	00177693          	andi	a3,a4,1
ffffffffc0202296:	d2ed                	beqz	a3,ffffffffc0202278 <unmap_range+0x56>
    if (PPN(pa) >= npage)
ffffffffc0202298:	000ca697          	auipc	a3,0xca
ffffffffc020229c:	0a06b683          	ld	a3,160(a3) # ffffffffc02cc338 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc02022a0:	070a                	slli	a4,a4,0x2
ffffffffc02022a2:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc02022a4:	0ad77763          	bgeu	a4,a3,ffffffffc0202352 <unmap_range+0x130>
    return &pages[PPN(pa) - nbase];
ffffffffc02022a8:	000ca517          	auipc	a0,0xca
ffffffffc02022ac:	09853503          	ld	a0,152(a0) # ffffffffc02cc340 <pages>
ffffffffc02022b0:	071a                	slli	a4,a4,0x6
ffffffffc02022b2:	fe0006b7          	lui	a3,0xfe000
ffffffffc02022b6:	9736                	add	a4,a4,a3
ffffffffc02022b8:	953a                	add	a0,a0,a4
    page->ref -= 1;
ffffffffc02022ba:	4118                	lw	a4,0(a0)
ffffffffc02022bc:	377d                	addiw	a4,a4,-1 # fffffffffdffffff <end+0x3dd33c7f>
ffffffffc02022be:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02022c0:	cb19                	beqz	a4,ffffffffc02022d6 <unmap_range+0xb4>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc02022c2:	0007b023          	sd	zero,0(a5)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02022c6:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc02022ca:	944e                	add	s0,s0,s3
ffffffffc02022cc:	b77d                	j	ffffffffc020227a <unmap_range+0x58>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02022ce:	9452                	add	s0,s0,s4
ffffffffc02022d0:	01547433          	and	s0,s0,s5
            continue;
ffffffffc02022d4:	b75d                	j	ffffffffc020227a <unmap_range+0x58>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02022d6:	10002773          	csrr	a4,sstatus
ffffffffc02022da:	8b09                	andi	a4,a4,2
ffffffffc02022dc:	eb19                	bnez	a4,ffffffffc02022f2 <unmap_range+0xd0>
        pmm_manager->free_pages(base, n);
ffffffffc02022de:	000ca717          	auipc	a4,0xca
ffffffffc02022e2:	03a73703          	ld	a4,58(a4) # ffffffffc02cc318 <pmm_manager>
ffffffffc02022e6:	4585                	li	a1,1
ffffffffc02022e8:	e03e                	sd	a5,0(sp)
ffffffffc02022ea:	7318                	ld	a4,32(a4)
ffffffffc02022ec:	9702                	jalr	a4
    if (flag) {
ffffffffc02022ee:	6782                	ld	a5,0(sp)
ffffffffc02022f0:	bfc9                	j	ffffffffc02022c2 <unmap_range+0xa0>
        intr_disable();
ffffffffc02022f2:	e43e                	sd	a5,8(sp)
ffffffffc02022f4:	e02a                	sd	a0,0(sp)
ffffffffc02022f6:	e08fe0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc02022fa:	000ca717          	auipc	a4,0xca
ffffffffc02022fe:	01e73703          	ld	a4,30(a4) # ffffffffc02cc318 <pmm_manager>
ffffffffc0202302:	6502                	ld	a0,0(sp)
ffffffffc0202304:	4585                	li	a1,1
ffffffffc0202306:	7318                	ld	a4,32(a4)
ffffffffc0202308:	9702                	jalr	a4
        intr_enable();
ffffffffc020230a:	deefe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc020230e:	67a2                	ld	a5,8(sp)
ffffffffc0202310:	bf4d                	j	ffffffffc02022c2 <unmap_range+0xa0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202312:	00005697          	auipc	a3,0x5
ffffffffc0202316:	35668693          	addi	a3,a3,854 # ffffffffc0207668 <etext+0xf06>
ffffffffc020231a:	00005617          	auipc	a2,0x5
ffffffffc020231e:	bf660613          	addi	a2,a2,-1034 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0202322:	12100593          	li	a1,289
ffffffffc0202326:	00005517          	auipc	a0,0x5
ffffffffc020232a:	33250513          	addi	a0,a0,818 # ffffffffc0207658 <etext+0xef6>
ffffffffc020232e:	91cfe0ef          	jal	ffffffffc020044a <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202332:	00005697          	auipc	a3,0x5
ffffffffc0202336:	36668693          	addi	a3,a3,870 # ffffffffc0207698 <etext+0xf36>
ffffffffc020233a:	00005617          	auipc	a2,0x5
ffffffffc020233e:	bd660613          	addi	a2,a2,-1066 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0202342:	12200593          	li	a1,290
ffffffffc0202346:	00005517          	auipc	a0,0x5
ffffffffc020234a:	31250513          	addi	a0,a0,786 # ffffffffc0207658 <etext+0xef6>
ffffffffc020234e:	8fcfe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0202352:	b5bff0ef          	jal	ffffffffc0201eac <pa2page.part.0>

ffffffffc0202356 <exit_range>:
{
ffffffffc0202356:	7135                	addi	sp,sp,-160
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202358:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc020235c:	ed06                	sd	ra,152(sp)
ffffffffc020235e:	e922                	sd	s0,144(sp)
ffffffffc0202360:	e526                	sd	s1,136(sp)
ffffffffc0202362:	e14a                	sd	s2,128(sp)
ffffffffc0202364:	fcce                	sd	s3,120(sp)
ffffffffc0202366:	f8d2                	sd	s4,112(sp)
ffffffffc0202368:	f4d6                	sd	s5,104(sp)
ffffffffc020236a:	f0da                	sd	s6,96(sp)
ffffffffc020236c:	ecde                	sd	s7,88(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020236e:	17d2                	slli	a5,a5,0x34
ffffffffc0202370:	22079263          	bnez	a5,ffffffffc0202594 <exit_range+0x23e>
    assert(USER_ACCESS(start, end));
ffffffffc0202374:	00200937          	lui	s2,0x200
ffffffffc0202378:	00c5b7b3          	sltu	a5,a1,a2
ffffffffc020237c:	0125b733          	sltu	a4,a1,s2
ffffffffc0202380:	0017b793          	seqz	a5,a5
ffffffffc0202384:	8fd9                	or	a5,a5,a4
ffffffffc0202386:	26079263          	bnez	a5,ffffffffc02025ea <exit_range+0x294>
ffffffffc020238a:	4785                	li	a5,1
ffffffffc020238c:	07fe                	slli	a5,a5,0x1f
ffffffffc020238e:	0785                	addi	a5,a5,1
ffffffffc0202390:	24f67d63          	bgeu	a2,a5,ffffffffc02025ea <exit_range+0x294>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0202394:	c00004b7          	lui	s1,0xc0000
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202398:	ffe007b7          	lui	a5,0xffe00
ffffffffc020239c:	8a2a                	mv	s4,a0
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc020239e:	8ced                	and	s1,s1,a1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02023a0:	00f5f833          	and	a6,a1,a5
    if (PPN(pa) >= npage)
ffffffffc02023a4:	000caa97          	auipc	s5,0xca
ffffffffc02023a8:	f94a8a93          	addi	s5,s5,-108 # ffffffffc02cc338 <npage>
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc02023ac:	400009b7          	lui	s3,0x40000
ffffffffc02023b0:	a809                	j	ffffffffc02023c2 <exit_range+0x6c>
        d1start += PDSIZE;
ffffffffc02023b2:	013487b3          	add	a5,s1,s3
ffffffffc02023b6:	400004b7          	lui	s1,0x40000
        d0start = d1start;
ffffffffc02023ba:	8826                	mv	a6,s1
    } while (d1start != 0 && d1start < end);
ffffffffc02023bc:	c3f1                	beqz	a5,ffffffffc0202480 <exit_range+0x12a>
ffffffffc02023be:	0cc7f163          	bgeu	a5,a2,ffffffffc0202480 <exit_range+0x12a>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02023c2:	01e4d413          	srli	s0,s1,0x1e
ffffffffc02023c6:	1ff47413          	andi	s0,s0,511
ffffffffc02023ca:	040e                	slli	s0,s0,0x3
ffffffffc02023cc:	9452                	add	s0,s0,s4
ffffffffc02023ce:	00043883          	ld	a7,0(s0)
        if (pde1 & PTE_V)
ffffffffc02023d2:	0018f793          	andi	a5,a7,1
ffffffffc02023d6:	dff1                	beqz	a5,ffffffffc02023b2 <exit_range+0x5c>
ffffffffc02023d8:	000ab783          	ld	a5,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02023dc:	088a                	slli	a7,a7,0x2
ffffffffc02023de:	00c8d893          	srli	a7,a7,0xc
    if (PPN(pa) >= npage)
ffffffffc02023e2:	20f8f263          	bgeu	a7,a5,ffffffffc02025e6 <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc02023e6:	fff802b7          	lui	t0,0xfff80
ffffffffc02023ea:	00588f33          	add	t5,a7,t0
    return page - pages + nbase;
ffffffffc02023ee:	000803b7          	lui	t2,0x80
ffffffffc02023f2:	007f0733          	add	a4,t5,t2
    return page2ppn(page) << PGSHIFT;
ffffffffc02023f6:	00c71e13          	slli	t3,a4,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc02023fa:	0f1a                	slli	t5,t5,0x6
    return KADDR(page2pa(page));
ffffffffc02023fc:	1cf77863          	bgeu	a4,a5,ffffffffc02025cc <exit_range+0x276>
ffffffffc0202400:	000caf97          	auipc	t6,0xca
ffffffffc0202404:	f30f8f93          	addi	t6,t6,-208 # ffffffffc02cc330 <va_pa_offset>
ffffffffc0202408:	000fb783          	ld	a5,0(t6)
            free_pd0 = 1;
ffffffffc020240c:	4e85                	li	t4,1
ffffffffc020240e:	6b05                	lui	s6,0x1
ffffffffc0202410:	9e3e                	add	t3,t3,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202412:	01348333          	add	t1,s1,s3
                pde0 = pd0[PDX0(d0start)];
ffffffffc0202416:	01585713          	srli	a4,a6,0x15
ffffffffc020241a:	1ff77713          	andi	a4,a4,511
ffffffffc020241e:	070e                	slli	a4,a4,0x3
ffffffffc0202420:	9772                	add	a4,a4,t3
ffffffffc0202422:	631c                	ld	a5,0(a4)
                if (pde0 & PTE_V)
ffffffffc0202424:	0017f693          	andi	a3,a5,1
ffffffffc0202428:	e6bd                	bnez	a3,ffffffffc0202496 <exit_range+0x140>
                    free_pd0 = 0;
ffffffffc020242a:	4e81                	li	t4,0
                d0start += PTSIZE;
ffffffffc020242c:	984a                	add	a6,a6,s2
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc020242e:	00080863          	beqz	a6,ffffffffc020243e <exit_range+0xe8>
ffffffffc0202432:	879a                	mv	a5,t1
ffffffffc0202434:	00667363          	bgeu	a2,t1,ffffffffc020243a <exit_range+0xe4>
ffffffffc0202438:	87b2                	mv	a5,a2
ffffffffc020243a:	fcf86ee3          	bltu	a6,a5,ffffffffc0202416 <exit_range+0xc0>
            if (free_pd0)
ffffffffc020243e:	f60e8ae3          	beqz	t4,ffffffffc02023b2 <exit_range+0x5c>
    if (PPN(pa) >= npage)
ffffffffc0202442:	000ab783          	ld	a5,0(s5)
ffffffffc0202446:	1af8f063          	bgeu	a7,a5,ffffffffc02025e6 <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc020244a:	000ca517          	auipc	a0,0xca
ffffffffc020244e:	ef653503          	ld	a0,-266(a0) # ffffffffc02cc340 <pages>
ffffffffc0202452:	957a                	add	a0,a0,t5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202454:	100027f3          	csrr	a5,sstatus
ffffffffc0202458:	8b89                	andi	a5,a5,2
ffffffffc020245a:	10079b63          	bnez	a5,ffffffffc0202570 <exit_range+0x21a>
        pmm_manager->free_pages(base, n);
ffffffffc020245e:	000ca797          	auipc	a5,0xca
ffffffffc0202462:	eba7b783          	ld	a5,-326(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc0202466:	4585                	li	a1,1
ffffffffc0202468:	e432                	sd	a2,8(sp)
ffffffffc020246a:	739c                	ld	a5,32(a5)
ffffffffc020246c:	9782                	jalr	a5
ffffffffc020246e:	6622                	ld	a2,8(sp)
                pgdir[PDX1(d1start)] = 0;
ffffffffc0202470:	00043023          	sd	zero,0(s0)
        d1start += PDSIZE;
ffffffffc0202474:	013487b3          	add	a5,s1,s3
ffffffffc0202478:	400004b7          	lui	s1,0x40000
        d0start = d1start;
ffffffffc020247c:	8826                	mv	a6,s1
    } while (d1start != 0 && d1start < end);
ffffffffc020247e:	f3a1                	bnez	a5,ffffffffc02023be <exit_range+0x68>
}
ffffffffc0202480:	60ea                	ld	ra,152(sp)
ffffffffc0202482:	644a                	ld	s0,144(sp)
ffffffffc0202484:	64aa                	ld	s1,136(sp)
ffffffffc0202486:	690a                	ld	s2,128(sp)
ffffffffc0202488:	79e6                	ld	s3,120(sp)
ffffffffc020248a:	7a46                	ld	s4,112(sp)
ffffffffc020248c:	7aa6                	ld	s5,104(sp)
ffffffffc020248e:	7b06                	ld	s6,96(sp)
ffffffffc0202490:	6be6                	ld	s7,88(sp)
ffffffffc0202492:	610d                	addi	sp,sp,160
ffffffffc0202494:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc0202496:	000ab503          	ld	a0,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc020249a:	078a                	slli	a5,a5,0x2
ffffffffc020249c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020249e:	14a7f463          	bgeu	a5,a0,ffffffffc02025e6 <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc02024a2:	9796                	add	a5,a5,t0
    return page - pages + nbase;
ffffffffc02024a4:	00778bb3          	add	s7,a5,t2
    return &pages[PPN(pa) - nbase];
ffffffffc02024a8:	00679593          	slli	a1,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02024ac:	00cb9693          	slli	a3,s7,0xc
    return KADDR(page2pa(page));
ffffffffc02024b0:	10abf263          	bgeu	s7,a0,ffffffffc02025b4 <exit_range+0x25e>
ffffffffc02024b4:	000fb783          	ld	a5,0(t6)
ffffffffc02024b8:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc02024ba:	01668533          	add	a0,a3,s6
                        if (pt[i] & PTE_V)
ffffffffc02024be:	629c                	ld	a5,0(a3)
ffffffffc02024c0:	8b85                	andi	a5,a5,1
ffffffffc02024c2:	f7ad                	bnez	a5,ffffffffc020242c <exit_range+0xd6>
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc02024c4:	06a1                	addi	a3,a3,8
ffffffffc02024c6:	fea69ce3          	bne	a3,a0,ffffffffc02024be <exit_range+0x168>
    return &pages[PPN(pa) - nbase];
ffffffffc02024ca:	000ca517          	auipc	a0,0xca
ffffffffc02024ce:	e7653503          	ld	a0,-394(a0) # ffffffffc02cc340 <pages>
ffffffffc02024d2:	952e                	add	a0,a0,a1
ffffffffc02024d4:	100027f3          	csrr	a5,sstatus
ffffffffc02024d8:	8b89                	andi	a5,a5,2
ffffffffc02024da:	e3b9                	bnez	a5,ffffffffc0202520 <exit_range+0x1ca>
        pmm_manager->free_pages(base, n);
ffffffffc02024dc:	000ca797          	auipc	a5,0xca
ffffffffc02024e0:	e3c7b783          	ld	a5,-452(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc02024e4:	4585                	li	a1,1
ffffffffc02024e6:	e0b2                	sd	a2,64(sp)
ffffffffc02024e8:	739c                	ld	a5,32(a5)
ffffffffc02024ea:	fc1a                	sd	t1,56(sp)
ffffffffc02024ec:	f846                	sd	a7,48(sp)
ffffffffc02024ee:	f47a                	sd	t5,40(sp)
ffffffffc02024f0:	f072                	sd	t3,32(sp)
ffffffffc02024f2:	ec76                	sd	t4,24(sp)
ffffffffc02024f4:	e842                	sd	a6,16(sp)
ffffffffc02024f6:	e43a                	sd	a4,8(sp)
ffffffffc02024f8:	9782                	jalr	a5
    if (flag) {
ffffffffc02024fa:	6722                	ld	a4,8(sp)
ffffffffc02024fc:	6842                	ld	a6,16(sp)
ffffffffc02024fe:	6ee2                	ld	t4,24(sp)
ffffffffc0202500:	7e02                	ld	t3,32(sp)
ffffffffc0202502:	7f22                	ld	t5,40(sp)
ffffffffc0202504:	78c2                	ld	a7,48(sp)
ffffffffc0202506:	7362                	ld	t1,56(sp)
ffffffffc0202508:	6606                	ld	a2,64(sp)
                        pd0[PDX0(d0start)] = 0;
ffffffffc020250a:	fff802b7          	lui	t0,0xfff80
ffffffffc020250e:	000803b7          	lui	t2,0x80
ffffffffc0202512:	000caf97          	auipc	t6,0xca
ffffffffc0202516:	e1ef8f93          	addi	t6,t6,-482 # ffffffffc02cc330 <va_pa_offset>
ffffffffc020251a:	00073023          	sd	zero,0(a4)
ffffffffc020251e:	b739                	j	ffffffffc020242c <exit_range+0xd6>
        intr_disable();
ffffffffc0202520:	e4b2                	sd	a2,72(sp)
ffffffffc0202522:	e09a                	sd	t1,64(sp)
ffffffffc0202524:	fc46                	sd	a7,56(sp)
ffffffffc0202526:	f47a                	sd	t5,40(sp)
ffffffffc0202528:	f072                	sd	t3,32(sp)
ffffffffc020252a:	ec76                	sd	t4,24(sp)
ffffffffc020252c:	e842                	sd	a6,16(sp)
ffffffffc020252e:	e43a                	sd	a4,8(sp)
ffffffffc0202530:	f82a                	sd	a0,48(sp)
ffffffffc0202532:	bccfe0ef          	jal	ffffffffc02008fe <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202536:	000ca797          	auipc	a5,0xca
ffffffffc020253a:	de27b783          	ld	a5,-542(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc020253e:	7542                	ld	a0,48(sp)
ffffffffc0202540:	4585                	li	a1,1
ffffffffc0202542:	739c                	ld	a5,32(a5)
ffffffffc0202544:	9782                	jalr	a5
        intr_enable();
ffffffffc0202546:	bb2fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc020254a:	6722                	ld	a4,8(sp)
ffffffffc020254c:	6626                	ld	a2,72(sp)
ffffffffc020254e:	6306                	ld	t1,64(sp)
ffffffffc0202550:	78e2                	ld	a7,56(sp)
ffffffffc0202552:	7f22                	ld	t5,40(sp)
ffffffffc0202554:	7e02                	ld	t3,32(sp)
ffffffffc0202556:	6ee2                	ld	t4,24(sp)
ffffffffc0202558:	6842                	ld	a6,16(sp)
ffffffffc020255a:	000caf97          	auipc	t6,0xca
ffffffffc020255e:	dd6f8f93          	addi	t6,t6,-554 # ffffffffc02cc330 <va_pa_offset>
ffffffffc0202562:	000803b7          	lui	t2,0x80
ffffffffc0202566:	fff802b7          	lui	t0,0xfff80
                        pd0[PDX0(d0start)] = 0;
ffffffffc020256a:	00073023          	sd	zero,0(a4)
ffffffffc020256e:	bd7d                	j	ffffffffc020242c <exit_range+0xd6>
        intr_disable();
ffffffffc0202570:	e832                	sd	a2,16(sp)
ffffffffc0202572:	e42a                	sd	a0,8(sp)
ffffffffc0202574:	b8afe0ef          	jal	ffffffffc02008fe <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202578:	000ca797          	auipc	a5,0xca
ffffffffc020257c:	da07b783          	ld	a5,-608(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc0202580:	6522                	ld	a0,8(sp)
ffffffffc0202582:	4585                	li	a1,1
ffffffffc0202584:	739c                	ld	a5,32(a5)
ffffffffc0202586:	9782                	jalr	a5
        intr_enable();
ffffffffc0202588:	b70fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc020258c:	6642                	ld	a2,16(sp)
                pgdir[PDX1(d1start)] = 0;
ffffffffc020258e:	00043023          	sd	zero,0(s0)
ffffffffc0202592:	b5cd                	j	ffffffffc0202474 <exit_range+0x11e>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202594:	00005697          	auipc	a3,0x5
ffffffffc0202598:	0d468693          	addi	a3,a3,212 # ffffffffc0207668 <etext+0xf06>
ffffffffc020259c:	00005617          	auipc	a2,0x5
ffffffffc02025a0:	97460613          	addi	a2,a2,-1676 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02025a4:	13600593          	li	a1,310
ffffffffc02025a8:	00005517          	auipc	a0,0x5
ffffffffc02025ac:	0b050513          	addi	a0,a0,176 # ffffffffc0207658 <etext+0xef6>
ffffffffc02025b0:	e9bfd0ef          	jal	ffffffffc020044a <__panic>
    return KADDR(page2pa(page));
ffffffffc02025b4:	00005617          	auipc	a2,0x5
ffffffffc02025b8:	fb460613          	addi	a2,a2,-76 # ffffffffc0207568 <etext+0xe06>
ffffffffc02025bc:	07100593          	li	a1,113
ffffffffc02025c0:	00005517          	auipc	a0,0x5
ffffffffc02025c4:	fd050513          	addi	a0,a0,-48 # ffffffffc0207590 <etext+0xe2e>
ffffffffc02025c8:	e83fd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02025cc:	86f2                	mv	a3,t3
ffffffffc02025ce:	00005617          	auipc	a2,0x5
ffffffffc02025d2:	f9a60613          	addi	a2,a2,-102 # ffffffffc0207568 <etext+0xe06>
ffffffffc02025d6:	07100593          	li	a1,113
ffffffffc02025da:	00005517          	auipc	a0,0x5
ffffffffc02025de:	fb650513          	addi	a0,a0,-74 # ffffffffc0207590 <etext+0xe2e>
ffffffffc02025e2:	e69fd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02025e6:	8c7ff0ef          	jal	ffffffffc0201eac <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc02025ea:	00005697          	auipc	a3,0x5
ffffffffc02025ee:	0ae68693          	addi	a3,a3,174 # ffffffffc0207698 <etext+0xf36>
ffffffffc02025f2:	00005617          	auipc	a2,0x5
ffffffffc02025f6:	91e60613          	addi	a2,a2,-1762 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02025fa:	13700593          	li	a1,311
ffffffffc02025fe:	00005517          	auipc	a0,0x5
ffffffffc0202602:	05a50513          	addi	a0,a0,90 # ffffffffc0207658 <etext+0xef6>
ffffffffc0202606:	e45fd0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020260a <copy_range>:
{
ffffffffc020260a:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020260c:	00d667b3          	or	a5,a2,a3
{
ffffffffc0202610:	f486                	sd	ra,104(sp)
ffffffffc0202612:	f0a2                	sd	s0,96(sp)
ffffffffc0202614:	eca6                	sd	s1,88(sp)
ffffffffc0202616:	e8ca                	sd	s2,80(sp)
ffffffffc0202618:	e4ce                	sd	s3,72(sp)
ffffffffc020261a:	e0d2                	sd	s4,64(sp)
ffffffffc020261c:	fc56                	sd	s5,56(sp)
ffffffffc020261e:	f85a                	sd	s6,48(sp)
ffffffffc0202620:	f45e                	sd	s7,40(sp)
ffffffffc0202622:	f062                	sd	s8,32(sp)
ffffffffc0202624:	ec66                	sd	s9,24(sp)
ffffffffc0202626:	e86a                	sd	s10,16(sp)
ffffffffc0202628:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020262a:	03479713          	slli	a4,a5,0x34
ffffffffc020262e:	18071163          	bnez	a4,ffffffffc02027b0 <copy_range+0x1a6>
    assert(USER_ACCESS(start, end));
ffffffffc0202632:	00200cb7          	lui	s9,0x200
ffffffffc0202636:	00d637b3          	sltu	a5,a2,a3
ffffffffc020263a:	01963733          	sltu	a4,a2,s9
ffffffffc020263e:	0017b793          	seqz	a5,a5
ffffffffc0202642:	8fd9                	or	a5,a5,a4
ffffffffc0202644:	8432                	mv	s0,a2
ffffffffc0202646:	84b6                	mv	s1,a3
ffffffffc0202648:	14079463          	bnez	a5,ffffffffc0202790 <copy_range+0x186>
ffffffffc020264c:	4785                	li	a5,1
ffffffffc020264e:	07fe                	slli	a5,a5,0x1f
ffffffffc0202650:	0785                	addi	a5,a5,1
ffffffffc0202652:	12f6ff63          	bgeu	a3,a5,ffffffffc0202790 <copy_range+0x186>
ffffffffc0202656:	8aaa                	mv	s5,a0
ffffffffc0202658:	892e                	mv	s2,a1
ffffffffc020265a:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage)
ffffffffc020265c:	000cac17          	auipc	s8,0xca
ffffffffc0202660:	cdcc0c13          	addi	s8,s8,-804 # ffffffffc02cc338 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc0202664:	000cab97          	auipc	s7,0xca
ffffffffc0202668:	cdcb8b93          	addi	s7,s7,-804 # ffffffffc02cc340 <pages>
ffffffffc020266c:	fff80b37          	lui	s6,0xfff80
        page = pmm_manager->alloc_pages(n);
ffffffffc0202670:	000caa17          	auipc	s4,0xca
ffffffffc0202674:	ca8a0a13          	addi	s4,s4,-856 # ffffffffc02cc318 <pmm_manager>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc0202678:	4601                	li	a2,0
ffffffffc020267a:	85a2                	mv	a1,s0
ffffffffc020267c:	854a                	mv	a0,s2
ffffffffc020267e:	8f3ff0ef          	jal	ffffffffc0201f70 <get_pte>
ffffffffc0202682:	8d2a                	mv	s10,a0
        if (ptep == NULL)
ffffffffc0202684:	cd41                	beqz	a0,ffffffffc020271c <copy_range+0x112>
        if (*ptep & PTE_V)
ffffffffc0202686:	611c                	ld	a5,0(a0)
ffffffffc0202688:	8b85                	andi	a5,a5,1
ffffffffc020268a:	e78d                	bnez	a5,ffffffffc02026b4 <copy_range+0xaa>
        start += PGSIZE;
ffffffffc020268c:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc020268e:	c019                	beqz	s0,ffffffffc0202694 <copy_range+0x8a>
ffffffffc0202690:	fe9464e3          	bltu	s0,s1,ffffffffc0202678 <copy_range+0x6e>
    return 0;
ffffffffc0202694:	4501                	li	a0,0
}
ffffffffc0202696:	70a6                	ld	ra,104(sp)
ffffffffc0202698:	7406                	ld	s0,96(sp)
ffffffffc020269a:	64e6                	ld	s1,88(sp)
ffffffffc020269c:	6946                	ld	s2,80(sp)
ffffffffc020269e:	69a6                	ld	s3,72(sp)
ffffffffc02026a0:	6a06                	ld	s4,64(sp)
ffffffffc02026a2:	7ae2                	ld	s5,56(sp)
ffffffffc02026a4:	7b42                	ld	s6,48(sp)
ffffffffc02026a6:	7ba2                	ld	s7,40(sp)
ffffffffc02026a8:	7c02                	ld	s8,32(sp)
ffffffffc02026aa:	6ce2                	ld	s9,24(sp)
ffffffffc02026ac:	6d42                	ld	s10,16(sp)
ffffffffc02026ae:	6da2                	ld	s11,8(sp)
ffffffffc02026b0:	6165                	addi	sp,sp,112
ffffffffc02026b2:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc02026b4:	4605                	li	a2,1
ffffffffc02026b6:	85a2                	mv	a1,s0
ffffffffc02026b8:	8556                	mv	a0,s5
ffffffffc02026ba:	8b7ff0ef          	jal	ffffffffc0201f70 <get_pte>
ffffffffc02026be:	cd3d                	beqz	a0,ffffffffc020273c <copy_range+0x132>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc02026c0:	000d3783          	ld	a5,0(s10)
    if (!(pte & PTE_V))
ffffffffc02026c4:	0017f713          	andi	a4,a5,1
ffffffffc02026c8:	cf25                	beqz	a4,ffffffffc0202740 <copy_range+0x136>
    if (PPN(pa) >= npage)
ffffffffc02026ca:	000c3703          	ld	a4,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc02026ce:	078a                	slli	a5,a5,0x2
ffffffffc02026d0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02026d2:	0ae7f363          	bgeu	a5,a4,ffffffffc0202778 <copy_range+0x16e>
    return &pages[PPN(pa) - nbase];
ffffffffc02026d6:	000bbd83          	ld	s11,0(s7)
ffffffffc02026da:	97da                	add	a5,a5,s6
ffffffffc02026dc:	079a                	slli	a5,a5,0x6
ffffffffc02026de:	9dbe                	add	s11,s11,a5
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02026e0:	100027f3          	csrr	a5,sstatus
ffffffffc02026e4:	8b89                	andi	a5,a5,2
ffffffffc02026e6:	e3a1                	bnez	a5,ffffffffc0202726 <copy_range+0x11c>
        page = pmm_manager->alloc_pages(n);
ffffffffc02026e8:	000a3783          	ld	a5,0(s4)
ffffffffc02026ec:	4505                	li	a0,1
ffffffffc02026ee:	6f9c                	ld	a5,24(a5)
ffffffffc02026f0:	9782                	jalr	a5
ffffffffc02026f2:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc02026f4:	060d8263          	beqz	s11,ffffffffc0202758 <copy_range+0x14e>
            assert(npage != NULL);
ffffffffc02026f8:	f80d1ae3          	bnez	s10,ffffffffc020268c <copy_range+0x82>
ffffffffc02026fc:	00005697          	auipc	a3,0x5
ffffffffc0202700:	fec68693          	addi	a3,a3,-20 # ffffffffc02076e8 <etext+0xf86>
ffffffffc0202704:	00005617          	auipc	a2,0x5
ffffffffc0202708:	80c60613          	addi	a2,a2,-2036 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020270c:	19600593          	li	a1,406
ffffffffc0202710:	00005517          	auipc	a0,0x5
ffffffffc0202714:	f4850513          	addi	a0,a0,-184 # ffffffffc0207658 <etext+0xef6>
ffffffffc0202718:	d33fd0ef          	jal	ffffffffc020044a <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020271c:	9466                	add	s0,s0,s9
ffffffffc020271e:	ffe007b7          	lui	a5,0xffe00
ffffffffc0202722:	8c7d                	and	s0,s0,a5
            continue;
ffffffffc0202724:	b7ad                	j	ffffffffc020268e <copy_range+0x84>
        intr_disable();
ffffffffc0202726:	9d8fe0ef          	jal	ffffffffc02008fe <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020272a:	000a3783          	ld	a5,0(s4)
ffffffffc020272e:	4505                	li	a0,1
ffffffffc0202730:	6f9c                	ld	a5,24(a5)
ffffffffc0202732:	9782                	jalr	a5
ffffffffc0202734:	8d2a                	mv	s10,a0
        intr_enable();
ffffffffc0202736:	9c2fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc020273a:	bf6d                	j	ffffffffc02026f4 <copy_range+0xea>
                return -E_NO_MEM;
ffffffffc020273c:	5571                	li	a0,-4
ffffffffc020273e:	bfa1                	j	ffffffffc0202696 <copy_range+0x8c>
        panic("pte2page called with invalid pte");
ffffffffc0202740:	00005617          	auipc	a2,0x5
ffffffffc0202744:	f7060613          	addi	a2,a2,-144 # ffffffffc02076b0 <etext+0xf4e>
ffffffffc0202748:	07f00593          	li	a1,127
ffffffffc020274c:	00005517          	auipc	a0,0x5
ffffffffc0202750:	e4450513          	addi	a0,a0,-444 # ffffffffc0207590 <etext+0xe2e>
ffffffffc0202754:	cf7fd0ef          	jal	ffffffffc020044a <__panic>
            assert(page != NULL);
ffffffffc0202758:	00005697          	auipc	a3,0x5
ffffffffc020275c:	f8068693          	addi	a3,a3,-128 # ffffffffc02076d8 <etext+0xf76>
ffffffffc0202760:	00004617          	auipc	a2,0x4
ffffffffc0202764:	7b060613          	addi	a2,a2,1968 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0202768:	19500593          	li	a1,405
ffffffffc020276c:	00005517          	auipc	a0,0x5
ffffffffc0202770:	eec50513          	addi	a0,a0,-276 # ffffffffc0207658 <etext+0xef6>
ffffffffc0202774:	cd7fd0ef          	jal	ffffffffc020044a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0202778:	00005617          	auipc	a2,0x5
ffffffffc020277c:	ec060613          	addi	a2,a2,-320 # ffffffffc0207638 <etext+0xed6>
ffffffffc0202780:	06900593          	li	a1,105
ffffffffc0202784:	00005517          	auipc	a0,0x5
ffffffffc0202788:	e0c50513          	addi	a0,a0,-500 # ffffffffc0207590 <etext+0xe2e>
ffffffffc020278c:	cbffd0ef          	jal	ffffffffc020044a <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc0202790:	00005697          	auipc	a3,0x5
ffffffffc0202794:	f0868693          	addi	a3,a3,-248 # ffffffffc0207698 <etext+0xf36>
ffffffffc0202798:	00004617          	auipc	a2,0x4
ffffffffc020279c:	77860613          	addi	a2,a2,1912 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02027a0:	17d00593          	li	a1,381
ffffffffc02027a4:	00005517          	auipc	a0,0x5
ffffffffc02027a8:	eb450513          	addi	a0,a0,-332 # ffffffffc0207658 <etext+0xef6>
ffffffffc02027ac:	c9ffd0ef          	jal	ffffffffc020044a <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02027b0:	00005697          	auipc	a3,0x5
ffffffffc02027b4:	eb868693          	addi	a3,a3,-328 # ffffffffc0207668 <etext+0xf06>
ffffffffc02027b8:	00004617          	auipc	a2,0x4
ffffffffc02027bc:	75860613          	addi	a2,a2,1880 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02027c0:	17c00593          	li	a1,380
ffffffffc02027c4:	00005517          	auipc	a0,0x5
ffffffffc02027c8:	e9450513          	addi	a0,a0,-364 # ffffffffc0207658 <etext+0xef6>
ffffffffc02027cc:	c7ffd0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02027d0 <page_remove>:
{
ffffffffc02027d0:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02027d2:	4601                	li	a2,0
{
ffffffffc02027d4:	e822                	sd	s0,16(sp)
ffffffffc02027d6:	ec06                	sd	ra,24(sp)
ffffffffc02027d8:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02027da:	f96ff0ef          	jal	ffffffffc0201f70 <get_pte>
    if (ptep != NULL)
ffffffffc02027de:	c511                	beqz	a0,ffffffffc02027ea <page_remove+0x1a>
    if (*ptep & PTE_V)
ffffffffc02027e0:	6118                	ld	a4,0(a0)
ffffffffc02027e2:	87aa                	mv	a5,a0
ffffffffc02027e4:	00177693          	andi	a3,a4,1
ffffffffc02027e8:	e689                	bnez	a3,ffffffffc02027f2 <page_remove+0x22>
}
ffffffffc02027ea:	60e2                	ld	ra,24(sp)
ffffffffc02027ec:	6442                	ld	s0,16(sp)
ffffffffc02027ee:	6105                	addi	sp,sp,32
ffffffffc02027f0:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc02027f2:	000ca697          	auipc	a3,0xca
ffffffffc02027f6:	b466b683          	ld	a3,-1210(a3) # ffffffffc02cc338 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc02027fa:	070a                	slli	a4,a4,0x2
ffffffffc02027fc:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc02027fe:	06d77563          	bgeu	a4,a3,ffffffffc0202868 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc0202802:	000ca517          	auipc	a0,0xca
ffffffffc0202806:	b3e53503          	ld	a0,-1218(a0) # ffffffffc02cc340 <pages>
ffffffffc020280a:	071a                	slli	a4,a4,0x6
ffffffffc020280c:	fe0006b7          	lui	a3,0xfe000
ffffffffc0202810:	9736                	add	a4,a4,a3
ffffffffc0202812:	953a                	add	a0,a0,a4
    page->ref -= 1;
ffffffffc0202814:	4118                	lw	a4,0(a0)
ffffffffc0202816:	377d                	addiw	a4,a4,-1
ffffffffc0202818:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc020281a:	cb09                	beqz	a4,ffffffffc020282c <page_remove+0x5c>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc020281c:	0007b023          	sd	zero,0(a5) # ffffffffffe00000 <end+0x3fb33c80>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202820:	12040073          	sfence.vma	s0
}
ffffffffc0202824:	60e2                	ld	ra,24(sp)
ffffffffc0202826:	6442                	ld	s0,16(sp)
ffffffffc0202828:	6105                	addi	sp,sp,32
ffffffffc020282a:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020282c:	10002773          	csrr	a4,sstatus
ffffffffc0202830:	8b09                	andi	a4,a4,2
ffffffffc0202832:	eb19                	bnez	a4,ffffffffc0202848 <page_remove+0x78>
        pmm_manager->free_pages(base, n);
ffffffffc0202834:	000ca717          	auipc	a4,0xca
ffffffffc0202838:	ae473703          	ld	a4,-1308(a4) # ffffffffc02cc318 <pmm_manager>
ffffffffc020283c:	4585                	li	a1,1
ffffffffc020283e:	e03e                	sd	a5,0(sp)
ffffffffc0202840:	7318                	ld	a4,32(a4)
ffffffffc0202842:	9702                	jalr	a4
    if (flag) {
ffffffffc0202844:	6782                	ld	a5,0(sp)
ffffffffc0202846:	bfd9                	j	ffffffffc020281c <page_remove+0x4c>
        intr_disable();
ffffffffc0202848:	e43e                	sd	a5,8(sp)
ffffffffc020284a:	e02a                	sd	a0,0(sp)
ffffffffc020284c:	8b2fe0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc0202850:	000ca717          	auipc	a4,0xca
ffffffffc0202854:	ac873703          	ld	a4,-1336(a4) # ffffffffc02cc318 <pmm_manager>
ffffffffc0202858:	6502                	ld	a0,0(sp)
ffffffffc020285a:	4585                	li	a1,1
ffffffffc020285c:	7318                	ld	a4,32(a4)
ffffffffc020285e:	9702                	jalr	a4
        intr_enable();
ffffffffc0202860:	898fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202864:	67a2                	ld	a5,8(sp)
ffffffffc0202866:	bf5d                	j	ffffffffc020281c <page_remove+0x4c>
ffffffffc0202868:	e44ff0ef          	jal	ffffffffc0201eac <pa2page.part.0>

ffffffffc020286c <page_insert>:
{
ffffffffc020286c:	7139                	addi	sp,sp,-64
ffffffffc020286e:	f426                	sd	s1,40(sp)
ffffffffc0202870:	84b2                	mv	s1,a2
ffffffffc0202872:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202874:	4605                	li	a2,1
{
ffffffffc0202876:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202878:	85a6                	mv	a1,s1
{
ffffffffc020287a:	fc06                	sd	ra,56(sp)
ffffffffc020287c:	e436                	sd	a3,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020287e:	ef2ff0ef          	jal	ffffffffc0201f70 <get_pte>
    if (ptep == NULL)
ffffffffc0202882:	cd61                	beqz	a0,ffffffffc020295a <page_insert+0xee>
    page->ref += 1;
ffffffffc0202884:	400c                	lw	a1,0(s0)
    if (*ptep & PTE_V)
ffffffffc0202886:	611c                	ld	a5,0(a0)
ffffffffc0202888:	66a2                	ld	a3,8(sp)
ffffffffc020288a:	0015861b          	addiw	a2,a1,1 # 1001 <_binary_obj___user_softint_out_size-0x80e7>
ffffffffc020288e:	c010                	sw	a2,0(s0)
ffffffffc0202890:	0017f613          	andi	a2,a5,1
ffffffffc0202894:	872a                	mv	a4,a0
ffffffffc0202896:	e61d                	bnez	a2,ffffffffc02028c4 <page_insert+0x58>
    return &pages[PPN(pa) - nbase];
ffffffffc0202898:	000ca617          	auipc	a2,0xca
ffffffffc020289c:	aa863603          	ld	a2,-1368(a2) # ffffffffc02cc340 <pages>
    return page - pages + nbase;
ffffffffc02028a0:	8c11                	sub	s0,s0,a2
ffffffffc02028a2:	8419                	srai	s0,s0,0x6
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02028a4:	200007b7          	lui	a5,0x20000
ffffffffc02028a8:	042a                	slli	s0,s0,0xa
ffffffffc02028aa:	943e                	add	s0,s0,a5
ffffffffc02028ac:	8ec1                	or	a3,a3,s0
ffffffffc02028ae:	0016e693          	ori	a3,a3,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02028b2:	e314                	sd	a3,0(a4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02028b4:	12048073          	sfence.vma	s1
    return 0;
ffffffffc02028b8:	4501                	li	a0,0
}
ffffffffc02028ba:	70e2                	ld	ra,56(sp)
ffffffffc02028bc:	7442                	ld	s0,48(sp)
ffffffffc02028be:	74a2                	ld	s1,40(sp)
ffffffffc02028c0:	6121                	addi	sp,sp,64
ffffffffc02028c2:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc02028c4:	000ca617          	auipc	a2,0xca
ffffffffc02028c8:	a7463603          	ld	a2,-1420(a2) # ffffffffc02cc338 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc02028cc:	078a                	slli	a5,a5,0x2
ffffffffc02028ce:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02028d0:	08c7f763          	bgeu	a5,a2,ffffffffc020295e <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc02028d4:	000ca617          	auipc	a2,0xca
ffffffffc02028d8:	a6c63603          	ld	a2,-1428(a2) # ffffffffc02cc340 <pages>
ffffffffc02028dc:	fe000537          	lui	a0,0xfe000
ffffffffc02028e0:	079a                	slli	a5,a5,0x6
ffffffffc02028e2:	97aa                	add	a5,a5,a0
ffffffffc02028e4:	00f60533          	add	a0,a2,a5
        if (p == page)
ffffffffc02028e8:	00a40963          	beq	s0,a0,ffffffffc02028fa <page_insert+0x8e>
    page->ref -= 1;
ffffffffc02028ec:	411c                	lw	a5,0(a0)
ffffffffc02028ee:	37fd                	addiw	a5,a5,-1 # 1fffffff <_binary_obj___user_matrix_out_size+0x1fff4917>
ffffffffc02028f0:	c11c                	sw	a5,0(a0)
        if (page_ref(page) ==
ffffffffc02028f2:	c791                	beqz	a5,ffffffffc02028fe <page_insert+0x92>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02028f4:	12048073          	sfence.vma	s1
}
ffffffffc02028f8:	b765                	j	ffffffffc02028a0 <page_insert+0x34>
ffffffffc02028fa:	c00c                	sw	a1,0(s0)
    return page->ref;
ffffffffc02028fc:	b755                	j	ffffffffc02028a0 <page_insert+0x34>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02028fe:	100027f3          	csrr	a5,sstatus
ffffffffc0202902:	8b89                	andi	a5,a5,2
ffffffffc0202904:	e39d                	bnez	a5,ffffffffc020292a <page_insert+0xbe>
        pmm_manager->free_pages(base, n);
ffffffffc0202906:	000ca797          	auipc	a5,0xca
ffffffffc020290a:	a127b783          	ld	a5,-1518(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc020290e:	4585                	li	a1,1
ffffffffc0202910:	e83a                	sd	a4,16(sp)
ffffffffc0202912:	739c                	ld	a5,32(a5)
ffffffffc0202914:	e436                	sd	a3,8(sp)
ffffffffc0202916:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0202918:	000ca617          	auipc	a2,0xca
ffffffffc020291c:	a2863603          	ld	a2,-1496(a2) # ffffffffc02cc340 <pages>
ffffffffc0202920:	66a2                	ld	a3,8(sp)
ffffffffc0202922:	6742                	ld	a4,16(sp)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202924:	12048073          	sfence.vma	s1
ffffffffc0202928:	bfa5                	j	ffffffffc02028a0 <page_insert+0x34>
        intr_disable();
ffffffffc020292a:	ec3a                	sd	a4,24(sp)
ffffffffc020292c:	e836                	sd	a3,16(sp)
ffffffffc020292e:	e42a                	sd	a0,8(sp)
ffffffffc0202930:	fcffd0ef          	jal	ffffffffc02008fe <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202934:	000ca797          	auipc	a5,0xca
ffffffffc0202938:	9e47b783          	ld	a5,-1564(a5) # ffffffffc02cc318 <pmm_manager>
ffffffffc020293c:	6522                	ld	a0,8(sp)
ffffffffc020293e:	4585                	li	a1,1
ffffffffc0202940:	739c                	ld	a5,32(a5)
ffffffffc0202942:	9782                	jalr	a5
        intr_enable();
ffffffffc0202944:	fb5fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202948:	000ca617          	auipc	a2,0xca
ffffffffc020294c:	9f863603          	ld	a2,-1544(a2) # ffffffffc02cc340 <pages>
ffffffffc0202950:	6762                	ld	a4,24(sp)
ffffffffc0202952:	66c2                	ld	a3,16(sp)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202954:	12048073          	sfence.vma	s1
ffffffffc0202958:	b7a1                	j	ffffffffc02028a0 <page_insert+0x34>
        return -E_NO_MEM;
ffffffffc020295a:	5571                	li	a0,-4
ffffffffc020295c:	bfb9                	j	ffffffffc02028ba <page_insert+0x4e>
ffffffffc020295e:	d4eff0ef          	jal	ffffffffc0201eac <pa2page.part.0>

ffffffffc0202962 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202962:	00006797          	auipc	a5,0x6
ffffffffc0202966:	34678793          	addi	a5,a5,838 # ffffffffc0208ca8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020296a:	638c                	ld	a1,0(a5)
{
ffffffffc020296c:	7159                	addi	sp,sp,-112
ffffffffc020296e:	f486                	sd	ra,104(sp)
ffffffffc0202970:	e8ca                	sd	s2,80(sp)
ffffffffc0202972:	e4ce                	sd	s3,72(sp)
ffffffffc0202974:	f85a                	sd	s6,48(sp)
ffffffffc0202976:	f0a2                	sd	s0,96(sp)
ffffffffc0202978:	eca6                	sd	s1,88(sp)
ffffffffc020297a:	e0d2                	sd	s4,64(sp)
ffffffffc020297c:	fc56                	sd	s5,56(sp)
ffffffffc020297e:	f45e                	sd	s7,40(sp)
ffffffffc0202980:	f062                	sd	s8,32(sp)
ffffffffc0202982:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0202984:	000cab17          	auipc	s6,0xca
ffffffffc0202988:	994b0b13          	addi	s6,s6,-1644 # ffffffffc02cc318 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020298c:	00005517          	auipc	a0,0x5
ffffffffc0202990:	d6c50513          	addi	a0,a0,-660 # ffffffffc02076f8 <etext+0xf96>
    pmm_manager = &default_pmm_manager;
ffffffffc0202994:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202998:	801fd0ef          	jal	ffffffffc0200198 <cprintf>
    pmm_manager->init();
ffffffffc020299c:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02029a0:	000ca997          	auipc	s3,0xca
ffffffffc02029a4:	99098993          	addi	s3,s3,-1648 # ffffffffc02cc330 <va_pa_offset>
    pmm_manager->init();
ffffffffc02029a8:	679c                	ld	a5,8(a5)
ffffffffc02029aa:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02029ac:	57f5                	li	a5,-3
ffffffffc02029ae:	07fa                	slli	a5,a5,0x1e
ffffffffc02029b0:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc02029b4:	f31fd0ef          	jal	ffffffffc02008e4 <get_memory_base>
ffffffffc02029b8:	892a                	mv	s2,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc02029ba:	f35fd0ef          	jal	ffffffffc02008ee <get_memory_size>
    if (mem_size == 0) {
ffffffffc02029be:	70050e63          	beqz	a0,ffffffffc02030da <pmm_init+0x778>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc02029c2:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc02029c4:	00005517          	auipc	a0,0x5
ffffffffc02029c8:	d6c50513          	addi	a0,a0,-660 # ffffffffc0207730 <etext+0xfce>
ffffffffc02029cc:	fccfd0ef          	jal	ffffffffc0200198 <cprintf>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc02029d0:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02029d4:	864a                	mv	a2,s2
ffffffffc02029d6:	85a6                	mv	a1,s1
ffffffffc02029d8:	fff40693          	addi	a3,s0,-1
ffffffffc02029dc:	00005517          	auipc	a0,0x5
ffffffffc02029e0:	d6c50513          	addi	a0,a0,-660 # ffffffffc0207748 <etext+0xfe6>
ffffffffc02029e4:	fb4fd0ef          	jal	ffffffffc0200198 <cprintf>
    if (maxpa > KERNTOP)
ffffffffc02029e8:	c80007b7          	lui	a5,0xc8000
ffffffffc02029ec:	8522                	mv	a0,s0
ffffffffc02029ee:	5287ed63          	bltu	a5,s0,ffffffffc0202f28 <pmm_init+0x5c6>
ffffffffc02029f2:	77fd                	lui	a5,0xfffff
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02029f4:	000cb617          	auipc	a2,0xcb
ffffffffc02029f8:	98b60613          	addi	a2,a2,-1653 # ffffffffc02cd37f <end+0xfff>
ffffffffc02029fc:	8e7d                	and	a2,a2,a5
    npage = maxpa / PGSIZE;
ffffffffc02029fe:	8131                	srli	a0,a0,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202a00:	000cab97          	auipc	s7,0xca
ffffffffc0202a04:	940b8b93          	addi	s7,s7,-1728 # ffffffffc02cc340 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0202a08:	000ca497          	auipc	s1,0xca
ffffffffc0202a0c:	93048493          	addi	s1,s1,-1744 # ffffffffc02cc338 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202a10:	00cbb023          	sd	a2,0(s7)
    npage = maxpa / PGSIZE;
ffffffffc0202a14:	e088                	sd	a0,0(s1)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202a16:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202a1a:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202a1c:	02f50763          	beq	a0,a5,ffffffffc0202a4a <pmm_init+0xe8>
ffffffffc0202a20:	4701                	li	a4,0
ffffffffc0202a22:	4585                	li	a1,1
ffffffffc0202a24:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc0202a28:	00671793          	slli	a5,a4,0x6
ffffffffc0202a2c:	97b2                	add	a5,a5,a2
ffffffffc0202a2e:	07a1                	addi	a5,a5,8 # 80008 <_binary_obj___user_matrix_out_size+0x74920>
ffffffffc0202a30:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202a34:	6088                	ld	a0,0(s1)
ffffffffc0202a36:	0705                	addi	a4,a4,1
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202a38:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202a3c:	00d507b3          	add	a5,a0,a3
ffffffffc0202a40:	fef764e3          	bltu	a4,a5,ffffffffc0202a28 <pmm_init+0xc6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202a44:	079a                	slli	a5,a5,0x6
ffffffffc0202a46:	00f606b3          	add	a3,a2,a5
ffffffffc0202a4a:	c02007b7          	lui	a5,0xc0200
ffffffffc0202a4e:	16f6eee3          	bltu	a3,a5,ffffffffc02033ca <pmm_init+0xa68>
ffffffffc0202a52:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0202a56:	77fd                	lui	a5,0xfffff
ffffffffc0202a58:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202a5a:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc0202a5c:	4e86ed63          	bltu	a3,s0,ffffffffc0202f56 <pmm_init+0x5f4>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202a60:	00005517          	auipc	a0,0x5
ffffffffc0202a64:	d1050513          	addi	a0,a0,-752 # ffffffffc0207770 <etext+0x100e>
ffffffffc0202a68:	f30fd0ef          	jal	ffffffffc0200198 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc0202a6c:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0202a70:	000ca917          	auipc	s2,0xca
ffffffffc0202a74:	8b890913          	addi	s2,s2,-1864 # ffffffffc02cc328 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc0202a78:	7b9c                	ld	a5,48(a5)
ffffffffc0202a7a:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202a7c:	00005517          	auipc	a0,0x5
ffffffffc0202a80:	d0c50513          	addi	a0,a0,-756 # ffffffffc0207788 <etext+0x1026>
ffffffffc0202a84:	f14fd0ef          	jal	ffffffffc0200198 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0202a88:	00009697          	auipc	a3,0x9
ffffffffc0202a8c:	57868693          	addi	a3,a3,1400 # ffffffffc020c000 <boot_page_table_sv39>
ffffffffc0202a90:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0202a94:	c02007b7          	lui	a5,0xc0200
ffffffffc0202a98:	2af6eee3          	bltu	a3,a5,ffffffffc0203554 <pmm_init+0xbf2>
ffffffffc0202a9c:	0009b783          	ld	a5,0(s3)
ffffffffc0202aa0:	8e9d                	sub	a3,a3,a5
ffffffffc0202aa2:	000ca797          	auipc	a5,0xca
ffffffffc0202aa6:	86d7bf23          	sd	a3,-1922(a5) # ffffffffc02cc320 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0202aaa:	100027f3          	csrr	a5,sstatus
ffffffffc0202aae:	8b89                	andi	a5,a5,2
ffffffffc0202ab0:	48079963          	bnez	a5,ffffffffc0202f42 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202ab4:	000b3783          	ld	a5,0(s6)
ffffffffc0202ab8:	779c                	ld	a5,40(a5)
ffffffffc0202aba:	9782                	jalr	a5
ffffffffc0202abc:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0202abe:	6098                	ld	a4,0(s1)
ffffffffc0202ac0:	c80007b7          	lui	a5,0xc8000
ffffffffc0202ac4:	83b1                	srli	a5,a5,0xc
ffffffffc0202ac6:	66e7e663          	bltu	a5,a4,ffffffffc0203132 <pmm_init+0x7d0>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202aca:	00093503          	ld	a0,0(s2)
ffffffffc0202ace:	64050263          	beqz	a0,ffffffffc0203112 <pmm_init+0x7b0>
ffffffffc0202ad2:	03451793          	slli	a5,a0,0x34
ffffffffc0202ad6:	62079e63          	bnez	a5,ffffffffc0203112 <pmm_init+0x7b0>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0202ada:	4601                	li	a2,0
ffffffffc0202adc:	4581                	li	a1,0
ffffffffc0202ade:	ef0ff0ef          	jal	ffffffffc02021ce <get_page>
ffffffffc0202ae2:	240519e3          	bnez	a0,ffffffffc0203534 <pmm_init+0xbd2>
ffffffffc0202ae6:	100027f3          	csrr	a5,sstatus
ffffffffc0202aea:	8b89                	andi	a5,a5,2
ffffffffc0202aec:	44079063          	bnez	a5,ffffffffc0202f2c <pmm_init+0x5ca>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202af0:	000b3783          	ld	a5,0(s6)
ffffffffc0202af4:	4505                	li	a0,1
ffffffffc0202af6:	6f9c                	ld	a5,24(a5)
ffffffffc0202af8:	9782                	jalr	a5
ffffffffc0202afa:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0202afc:	00093503          	ld	a0,0(s2)
ffffffffc0202b00:	4681                	li	a3,0
ffffffffc0202b02:	4601                	li	a2,0
ffffffffc0202b04:	85d2                	mv	a1,s4
ffffffffc0202b06:	d67ff0ef          	jal	ffffffffc020286c <page_insert>
ffffffffc0202b0a:	280511e3          	bnez	a0,ffffffffc020358c <pmm_init+0xc2a>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0202b0e:	00093503          	ld	a0,0(s2)
ffffffffc0202b12:	4601                	li	a2,0
ffffffffc0202b14:	4581                	li	a1,0
ffffffffc0202b16:	c5aff0ef          	jal	ffffffffc0201f70 <get_pte>
ffffffffc0202b1a:	240509e3          	beqz	a0,ffffffffc020356c <pmm_init+0xc0a>
    assert(pte2page(*ptep) == p1);
ffffffffc0202b1e:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202b20:	0017f713          	andi	a4,a5,1
ffffffffc0202b24:	58070f63          	beqz	a4,ffffffffc02030c2 <pmm_init+0x760>
    if (PPN(pa) >= npage)
ffffffffc0202b28:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202b2a:	078a                	slli	a5,a5,0x2
ffffffffc0202b2c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b2e:	58e7f863          	bgeu	a5,a4,ffffffffc02030be <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b32:	000bb683          	ld	a3,0(s7)
ffffffffc0202b36:	079a                	slli	a5,a5,0x6
ffffffffc0202b38:	fe000637          	lui	a2,0xfe000
ffffffffc0202b3c:	97b2                	add	a5,a5,a2
ffffffffc0202b3e:	97b6                	add	a5,a5,a3
ffffffffc0202b40:	14fa1ae3          	bne	s4,a5,ffffffffc0203494 <pmm_init+0xb32>
    assert(page_ref(p1) == 1);
ffffffffc0202b44:	000a2683          	lw	a3,0(s4)
ffffffffc0202b48:	4785                	li	a5,1
ffffffffc0202b4a:	12f695e3          	bne	a3,a5,ffffffffc0203474 <pmm_init+0xb12>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0202b4e:	00093503          	ld	a0,0(s2)
ffffffffc0202b52:	77fd                	lui	a5,0xfffff
ffffffffc0202b54:	6114                	ld	a3,0(a0)
ffffffffc0202b56:	068a                	slli	a3,a3,0x2
ffffffffc0202b58:	8efd                	and	a3,a3,a5
ffffffffc0202b5a:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202b5e:	0ee67fe3          	bgeu	a2,a4,ffffffffc020345c <pmm_init+0xafa>
ffffffffc0202b62:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202b66:	96e2                	add	a3,a3,s8
ffffffffc0202b68:	0006ba83          	ld	s5,0(a3)
ffffffffc0202b6c:	0a8a                	slli	s5,s5,0x2
ffffffffc0202b6e:	00fafab3          	and	s5,s5,a5
ffffffffc0202b72:	00cad793          	srli	a5,s5,0xc
ffffffffc0202b76:	0ce7f6e3          	bgeu	a5,a4,ffffffffc0203442 <pmm_init+0xae0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202b7a:	4601                	li	a2,0
ffffffffc0202b7c:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202b7e:	9c56                	add	s8,s8,s5
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202b80:	bf0ff0ef          	jal	ffffffffc0201f70 <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202b84:	0c21                	addi	s8,s8,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202b86:	05851ee3          	bne	a0,s8,ffffffffc02033e2 <pmm_init+0xa80>
ffffffffc0202b8a:	100027f3          	csrr	a5,sstatus
ffffffffc0202b8e:	8b89                	andi	a5,a5,2
ffffffffc0202b90:	3e079b63          	bnez	a5,ffffffffc0202f86 <pmm_init+0x624>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202b94:	000b3783          	ld	a5,0(s6)
ffffffffc0202b98:	4505                	li	a0,1
ffffffffc0202b9a:	6f9c                	ld	a5,24(a5)
ffffffffc0202b9c:	9782                	jalr	a5
ffffffffc0202b9e:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202ba0:	00093503          	ld	a0,0(s2)
ffffffffc0202ba4:	46d1                	li	a3,20
ffffffffc0202ba6:	6605                	lui	a2,0x1
ffffffffc0202ba8:	85e2                	mv	a1,s8
ffffffffc0202baa:	cc3ff0ef          	jal	ffffffffc020286c <page_insert>
ffffffffc0202bae:	06051ae3          	bnez	a0,ffffffffc0203422 <pmm_init+0xac0>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202bb2:	00093503          	ld	a0,0(s2)
ffffffffc0202bb6:	4601                	li	a2,0
ffffffffc0202bb8:	6585                	lui	a1,0x1
ffffffffc0202bba:	bb6ff0ef          	jal	ffffffffc0201f70 <get_pte>
ffffffffc0202bbe:	040502e3          	beqz	a0,ffffffffc0203402 <pmm_init+0xaa0>
    assert(*ptep & PTE_U);
ffffffffc0202bc2:	611c                	ld	a5,0(a0)
ffffffffc0202bc4:	0107f713          	andi	a4,a5,16
ffffffffc0202bc8:	7e070163          	beqz	a4,ffffffffc02033aa <pmm_init+0xa48>
    assert(*ptep & PTE_W);
ffffffffc0202bcc:	8b91                	andi	a5,a5,4
ffffffffc0202bce:	7a078e63          	beqz	a5,ffffffffc020338a <pmm_init+0xa28>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0202bd2:	00093503          	ld	a0,0(s2)
ffffffffc0202bd6:	611c                	ld	a5,0(a0)
ffffffffc0202bd8:	8bc1                	andi	a5,a5,16
ffffffffc0202bda:	78078863          	beqz	a5,ffffffffc020336a <pmm_init+0xa08>
    assert(page_ref(p2) == 1);
ffffffffc0202bde:	000c2703          	lw	a4,0(s8)
ffffffffc0202be2:	4785                	li	a5,1
ffffffffc0202be4:	76f71363          	bne	a4,a5,ffffffffc020334a <pmm_init+0x9e8>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0202be8:	4681                	li	a3,0
ffffffffc0202bea:	6605                	lui	a2,0x1
ffffffffc0202bec:	85d2                	mv	a1,s4
ffffffffc0202bee:	c7fff0ef          	jal	ffffffffc020286c <page_insert>
ffffffffc0202bf2:	72051c63          	bnez	a0,ffffffffc020332a <pmm_init+0x9c8>
    assert(page_ref(p1) == 2);
ffffffffc0202bf6:	000a2703          	lw	a4,0(s4)
ffffffffc0202bfa:	4789                	li	a5,2
ffffffffc0202bfc:	70f71763          	bne	a4,a5,ffffffffc020330a <pmm_init+0x9a8>
    assert(page_ref(p2) == 0);
ffffffffc0202c00:	000c2783          	lw	a5,0(s8)
ffffffffc0202c04:	6e079363          	bnez	a5,ffffffffc02032ea <pmm_init+0x988>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202c08:	00093503          	ld	a0,0(s2)
ffffffffc0202c0c:	4601                	li	a2,0
ffffffffc0202c0e:	6585                	lui	a1,0x1
ffffffffc0202c10:	b60ff0ef          	jal	ffffffffc0201f70 <get_pte>
ffffffffc0202c14:	6a050b63          	beqz	a0,ffffffffc02032ca <pmm_init+0x968>
    assert(pte2page(*ptep) == p1);
ffffffffc0202c18:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202c1a:	00177793          	andi	a5,a4,1
ffffffffc0202c1e:	4a078263          	beqz	a5,ffffffffc02030c2 <pmm_init+0x760>
    if (PPN(pa) >= npage)
ffffffffc0202c22:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202c24:	00271793          	slli	a5,a4,0x2
ffffffffc0202c28:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202c2a:	48d7fa63          	bgeu	a5,a3,ffffffffc02030be <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c2e:	000bb683          	ld	a3,0(s7)
ffffffffc0202c32:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202c36:	97d6                	add	a5,a5,s5
ffffffffc0202c38:	079a                	slli	a5,a5,0x6
ffffffffc0202c3a:	97b6                	add	a5,a5,a3
ffffffffc0202c3c:	66fa1763          	bne	s4,a5,ffffffffc02032aa <pmm_init+0x948>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202c40:	8b41                	andi	a4,a4,16
ffffffffc0202c42:	64071463          	bnez	a4,ffffffffc020328a <pmm_init+0x928>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc0202c46:	00093503          	ld	a0,0(s2)
ffffffffc0202c4a:	4581                	li	a1,0
ffffffffc0202c4c:	b85ff0ef          	jal	ffffffffc02027d0 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202c50:	000a2c83          	lw	s9,0(s4)
ffffffffc0202c54:	4785                	li	a5,1
ffffffffc0202c56:	60fc9a63          	bne	s9,a5,ffffffffc020326a <pmm_init+0x908>
    assert(page_ref(p2) == 0);
ffffffffc0202c5a:	000c2783          	lw	a5,0(s8)
ffffffffc0202c5e:	5e079663          	bnez	a5,ffffffffc020324a <pmm_init+0x8e8>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc0202c62:	00093503          	ld	a0,0(s2)
ffffffffc0202c66:	6585                	lui	a1,0x1
ffffffffc0202c68:	b69ff0ef          	jal	ffffffffc02027d0 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202c6c:	000a2783          	lw	a5,0(s4)
ffffffffc0202c70:	52079d63          	bnez	a5,ffffffffc02031aa <pmm_init+0x848>
    assert(page_ref(p2) == 0);
ffffffffc0202c74:	000c2783          	lw	a5,0(s8)
ffffffffc0202c78:	50079963          	bnez	a5,ffffffffc020318a <pmm_init+0x828>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202c7c:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202c80:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202c82:	000a3783          	ld	a5,0(s4)
ffffffffc0202c86:	078a                	slli	a5,a5,0x2
ffffffffc0202c88:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202c8a:	42e7fa63          	bgeu	a5,a4,ffffffffc02030be <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c8e:	000bb503          	ld	a0,0(s7)
ffffffffc0202c92:	97d6                	add	a5,a5,s5
ffffffffc0202c94:	079a                	slli	a5,a5,0x6
    return page->ref;
ffffffffc0202c96:	00f506b3          	add	a3,a0,a5
ffffffffc0202c9a:	4294                	lw	a3,0(a3)
ffffffffc0202c9c:	4d969763          	bne	a3,s9,ffffffffc020316a <pmm_init+0x808>
    return page - pages + nbase;
ffffffffc0202ca0:	8799                	srai	a5,a5,0x6
ffffffffc0202ca2:	00080637          	lui	a2,0x80
ffffffffc0202ca6:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202ca8:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202cac:	4ae7f363          	bgeu	a5,a4,ffffffffc0203152 <pmm_init+0x7f0>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202cb0:	0009b783          	ld	a5,0(s3)
ffffffffc0202cb4:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0202cb6:	639c                	ld	a5,0(a5)
ffffffffc0202cb8:	078a                	slli	a5,a5,0x2
ffffffffc0202cba:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202cbc:	40e7f163          	bgeu	a5,a4,ffffffffc02030be <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202cc0:	8f91                	sub	a5,a5,a2
ffffffffc0202cc2:	079a                	slli	a5,a5,0x6
ffffffffc0202cc4:	953e                	add	a0,a0,a5
ffffffffc0202cc6:	100027f3          	csrr	a5,sstatus
ffffffffc0202cca:	8b89                	andi	a5,a5,2
ffffffffc0202ccc:	30079863          	bnez	a5,ffffffffc0202fdc <pmm_init+0x67a>
        pmm_manager->free_pages(base, n);
ffffffffc0202cd0:	000b3783          	ld	a5,0(s6)
ffffffffc0202cd4:	4585                	li	a1,1
ffffffffc0202cd6:	739c                	ld	a5,32(a5)
ffffffffc0202cd8:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202cda:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202cde:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ce0:	078a                	slli	a5,a5,0x2
ffffffffc0202ce2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202ce4:	3ce7fd63          	bgeu	a5,a4,ffffffffc02030be <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ce8:	000bb503          	ld	a0,0(s7)
ffffffffc0202cec:	fe000737          	lui	a4,0xfe000
ffffffffc0202cf0:	079a                	slli	a5,a5,0x6
ffffffffc0202cf2:	97ba                	add	a5,a5,a4
ffffffffc0202cf4:	953e                	add	a0,a0,a5
ffffffffc0202cf6:	100027f3          	csrr	a5,sstatus
ffffffffc0202cfa:	8b89                	andi	a5,a5,2
ffffffffc0202cfc:	2c079463          	bnez	a5,ffffffffc0202fc4 <pmm_init+0x662>
ffffffffc0202d00:	000b3783          	ld	a5,0(s6)
ffffffffc0202d04:	4585                	li	a1,1
ffffffffc0202d06:	739c                	ld	a5,32(a5)
ffffffffc0202d08:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202d0a:	00093783          	ld	a5,0(s2)
ffffffffc0202d0e:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd32c80>
    asm volatile("sfence.vma");
ffffffffc0202d12:	12000073          	sfence.vma
ffffffffc0202d16:	100027f3          	csrr	a5,sstatus
ffffffffc0202d1a:	8b89                	andi	a5,a5,2
ffffffffc0202d1c:	28079a63          	bnez	a5,ffffffffc0202fb0 <pmm_init+0x64e>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202d20:	000b3783          	ld	a5,0(s6)
ffffffffc0202d24:	779c                	ld	a5,40(a5)
ffffffffc0202d26:	9782                	jalr	a5
ffffffffc0202d28:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202d2a:	4d441063          	bne	s0,s4,ffffffffc02031ea <pmm_init+0x888>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202d2e:	00005517          	auipc	a0,0x5
ffffffffc0202d32:	d8250513          	addi	a0,a0,-638 # ffffffffc0207ab0 <etext+0x134e>
ffffffffc0202d36:	c62fd0ef          	jal	ffffffffc0200198 <cprintf>
ffffffffc0202d3a:	100027f3          	csrr	a5,sstatus
ffffffffc0202d3e:	8b89                	andi	a5,a5,2
ffffffffc0202d40:	24079e63          	bnez	a5,ffffffffc0202f9c <pmm_init+0x63a>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202d44:	000b3783          	ld	a5,0(s6)
ffffffffc0202d48:	779c                	ld	a5,40(a5)
ffffffffc0202d4a:	9782                	jalr	a5
ffffffffc0202d4c:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202d4e:	609c                	ld	a5,0(s1)
ffffffffc0202d50:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202d54:	7a7d                	lui	s4,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202d56:	00c79713          	slli	a4,a5,0xc
ffffffffc0202d5a:	6a85                	lui	s5,0x1
ffffffffc0202d5c:	02e47c63          	bgeu	s0,a4,ffffffffc0202d94 <pmm_init+0x432>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202d60:	00c45713          	srli	a4,s0,0xc
ffffffffc0202d64:	30f77063          	bgeu	a4,a5,ffffffffc0203064 <pmm_init+0x702>
ffffffffc0202d68:	0009b583          	ld	a1,0(s3)
ffffffffc0202d6c:	00093503          	ld	a0,0(s2)
ffffffffc0202d70:	4601                	li	a2,0
ffffffffc0202d72:	95a2                	add	a1,a1,s0
ffffffffc0202d74:	9fcff0ef          	jal	ffffffffc0201f70 <get_pte>
ffffffffc0202d78:	32050363          	beqz	a0,ffffffffc020309e <pmm_init+0x73c>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202d7c:	611c                	ld	a5,0(a0)
ffffffffc0202d7e:	078a                	slli	a5,a5,0x2
ffffffffc0202d80:	0147f7b3          	and	a5,a5,s4
ffffffffc0202d84:	2e879d63          	bne	a5,s0,ffffffffc020307e <pmm_init+0x71c>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202d88:	609c                	ld	a5,0(s1)
ffffffffc0202d8a:	9456                	add	s0,s0,s5
ffffffffc0202d8c:	00c79713          	slli	a4,a5,0xc
ffffffffc0202d90:	fce468e3          	bltu	s0,a4,ffffffffc0202d60 <pmm_init+0x3fe>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc0202d94:	00093783          	ld	a5,0(s2)
ffffffffc0202d98:	639c                	ld	a5,0(a5)
ffffffffc0202d9a:	42079863          	bnez	a5,ffffffffc02031ca <pmm_init+0x868>
ffffffffc0202d9e:	100027f3          	csrr	a5,sstatus
ffffffffc0202da2:	8b89                	andi	a5,a5,2
ffffffffc0202da4:	24079863          	bnez	a5,ffffffffc0202ff4 <pmm_init+0x692>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202da8:	000b3783          	ld	a5,0(s6)
ffffffffc0202dac:	4505                	li	a0,1
ffffffffc0202dae:	6f9c                	ld	a5,24(a5)
ffffffffc0202db0:	9782                	jalr	a5
ffffffffc0202db2:	842a                	mv	s0,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202db4:	00093503          	ld	a0,0(s2)
ffffffffc0202db8:	4699                	li	a3,6
ffffffffc0202dba:	10000613          	li	a2,256
ffffffffc0202dbe:	85a2                	mv	a1,s0
ffffffffc0202dc0:	aadff0ef          	jal	ffffffffc020286c <page_insert>
ffffffffc0202dc4:	46051363          	bnez	a0,ffffffffc020322a <pmm_init+0x8c8>
    assert(page_ref(p) == 1);
ffffffffc0202dc8:	4018                	lw	a4,0(s0)
ffffffffc0202dca:	4785                	li	a5,1
ffffffffc0202dcc:	42f71f63          	bne	a4,a5,ffffffffc020320a <pmm_init+0x8a8>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202dd0:	00093503          	ld	a0,0(s2)
ffffffffc0202dd4:	6605                	lui	a2,0x1
ffffffffc0202dd6:	10060613          	addi	a2,a2,256 # 1100 <_binary_obj___user_softint_out_size-0x7fe8>
ffffffffc0202dda:	4699                	li	a3,6
ffffffffc0202ddc:	85a2                	mv	a1,s0
ffffffffc0202dde:	a8fff0ef          	jal	ffffffffc020286c <page_insert>
ffffffffc0202de2:	72051963          	bnez	a0,ffffffffc0203514 <pmm_init+0xbb2>
    assert(page_ref(p) == 2);
ffffffffc0202de6:	4018                	lw	a4,0(s0)
ffffffffc0202de8:	4789                	li	a5,2
ffffffffc0202dea:	70f71563          	bne	a4,a5,ffffffffc02034f4 <pmm_init+0xb92>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202dee:	00005597          	auipc	a1,0x5
ffffffffc0202df2:	e0a58593          	addi	a1,a1,-502 # ffffffffc0207bf8 <etext+0x1496>
ffffffffc0202df6:	10000513          	li	a0,256
ffffffffc0202dfa:	0bf030ef          	jal	ffffffffc02066b8 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202dfe:	6585                	lui	a1,0x1
ffffffffc0202e00:	10058593          	addi	a1,a1,256 # 1100 <_binary_obj___user_softint_out_size-0x7fe8>
ffffffffc0202e04:	10000513          	li	a0,256
ffffffffc0202e08:	0c3030ef          	jal	ffffffffc02066ca <strcmp>
ffffffffc0202e0c:	6c051463          	bnez	a0,ffffffffc02034d4 <pmm_init+0xb72>
    return page - pages + nbase;
ffffffffc0202e10:	000bb683          	ld	a3,0(s7)
ffffffffc0202e14:	000807b7          	lui	a5,0x80
    return KADDR(page2pa(page));
ffffffffc0202e18:	6098                	ld	a4,0(s1)
    return page - pages + nbase;
ffffffffc0202e1a:	40d406b3          	sub	a3,s0,a3
ffffffffc0202e1e:	8699                	srai	a3,a3,0x6
ffffffffc0202e20:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0202e22:	00c69793          	slli	a5,a3,0xc
ffffffffc0202e26:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202e28:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202e2a:	32e7f463          	bgeu	a5,a4,ffffffffc0203152 <pmm_init+0x7f0>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202e2e:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202e32:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202e36:	97b6                	add	a5,a5,a3
ffffffffc0202e38:	10078023          	sb	zero,256(a5) # 80100 <_binary_obj___user_matrix_out_size+0x74a18>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202e3c:	049030ef          	jal	ffffffffc0206684 <strlen>
ffffffffc0202e40:	66051a63          	bnez	a0,ffffffffc02034b4 <pmm_init+0xb52>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0202e44:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202e48:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202e4a:	000a3783          	ld	a5,0(s4) # fffffffffffff000 <end+0x3fd32c80>
ffffffffc0202e4e:	078a                	slli	a5,a5,0x2
ffffffffc0202e50:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202e52:	26e7f663          	bgeu	a5,a4,ffffffffc02030be <pmm_init+0x75c>
    return page2ppn(page) << PGSHIFT;
ffffffffc0202e56:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202e5a:	2ee7fc63          	bgeu	a5,a4,ffffffffc0203152 <pmm_init+0x7f0>
ffffffffc0202e5e:	0009b783          	ld	a5,0(s3)
ffffffffc0202e62:	00f689b3          	add	s3,a3,a5
ffffffffc0202e66:	100027f3          	csrr	a5,sstatus
ffffffffc0202e6a:	8b89                	andi	a5,a5,2
ffffffffc0202e6c:	1e079163          	bnez	a5,ffffffffc020304e <pmm_init+0x6ec>
        pmm_manager->free_pages(base, n);
ffffffffc0202e70:	000b3783          	ld	a5,0(s6)
ffffffffc0202e74:	8522                	mv	a0,s0
ffffffffc0202e76:	4585                	li	a1,1
ffffffffc0202e78:	739c                	ld	a5,32(a5)
ffffffffc0202e7a:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202e7c:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage)
ffffffffc0202e80:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202e82:	078a                	slli	a5,a5,0x2
ffffffffc0202e84:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202e86:	22e7fc63          	bgeu	a5,a4,ffffffffc02030be <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202e8a:	000bb503          	ld	a0,0(s7)
ffffffffc0202e8e:	fe000737          	lui	a4,0xfe000
ffffffffc0202e92:	079a                	slli	a5,a5,0x6
ffffffffc0202e94:	97ba                	add	a5,a5,a4
ffffffffc0202e96:	953e                	add	a0,a0,a5
ffffffffc0202e98:	100027f3          	csrr	a5,sstatus
ffffffffc0202e9c:	8b89                	andi	a5,a5,2
ffffffffc0202e9e:	18079c63          	bnez	a5,ffffffffc0203036 <pmm_init+0x6d4>
ffffffffc0202ea2:	000b3783          	ld	a5,0(s6)
ffffffffc0202ea6:	4585                	li	a1,1
ffffffffc0202ea8:	739c                	ld	a5,32(a5)
ffffffffc0202eaa:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202eac:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202eb0:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202eb2:	078a                	slli	a5,a5,0x2
ffffffffc0202eb4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202eb6:	20e7f463          	bgeu	a5,a4,ffffffffc02030be <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202eba:	000bb503          	ld	a0,0(s7)
ffffffffc0202ebe:	fe000737          	lui	a4,0xfe000
ffffffffc0202ec2:	079a                	slli	a5,a5,0x6
ffffffffc0202ec4:	97ba                	add	a5,a5,a4
ffffffffc0202ec6:	953e                	add	a0,a0,a5
ffffffffc0202ec8:	100027f3          	csrr	a5,sstatus
ffffffffc0202ecc:	8b89                	andi	a5,a5,2
ffffffffc0202ece:	14079863          	bnez	a5,ffffffffc020301e <pmm_init+0x6bc>
ffffffffc0202ed2:	000b3783          	ld	a5,0(s6)
ffffffffc0202ed6:	4585                	li	a1,1
ffffffffc0202ed8:	739c                	ld	a5,32(a5)
ffffffffc0202eda:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202edc:	00093783          	ld	a5,0(s2)
ffffffffc0202ee0:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0202ee4:	12000073          	sfence.vma
ffffffffc0202ee8:	100027f3          	csrr	a5,sstatus
ffffffffc0202eec:	8b89                	andi	a5,a5,2
ffffffffc0202eee:	10079e63          	bnez	a5,ffffffffc020300a <pmm_init+0x6a8>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202ef2:	000b3783          	ld	a5,0(s6)
ffffffffc0202ef6:	779c                	ld	a5,40(a5)
ffffffffc0202ef8:	9782                	jalr	a5
ffffffffc0202efa:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202efc:	1e8c1b63          	bne	s8,s0,ffffffffc02030f2 <pmm_init+0x790>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202f00:	00005517          	auipc	a0,0x5
ffffffffc0202f04:	d7050513          	addi	a0,a0,-656 # ffffffffc0207c70 <etext+0x150e>
ffffffffc0202f08:	a90fd0ef          	jal	ffffffffc0200198 <cprintf>
}
ffffffffc0202f0c:	7406                	ld	s0,96(sp)
ffffffffc0202f0e:	70a6                	ld	ra,104(sp)
ffffffffc0202f10:	64e6                	ld	s1,88(sp)
ffffffffc0202f12:	6946                	ld	s2,80(sp)
ffffffffc0202f14:	69a6                	ld	s3,72(sp)
ffffffffc0202f16:	6a06                	ld	s4,64(sp)
ffffffffc0202f18:	7ae2                	ld	s5,56(sp)
ffffffffc0202f1a:	7b42                	ld	s6,48(sp)
ffffffffc0202f1c:	7ba2                	ld	s7,40(sp)
ffffffffc0202f1e:	7c02                	ld	s8,32(sp)
ffffffffc0202f20:	6ce2                	ld	s9,24(sp)
ffffffffc0202f22:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0202f24:	dbdfe06f          	j	ffffffffc0201ce0 <kmalloc_init>
    if (maxpa > KERNTOP)
ffffffffc0202f28:	853e                	mv	a0,a5
ffffffffc0202f2a:	b4e1                	j	ffffffffc02029f2 <pmm_init+0x90>
        intr_disable();
ffffffffc0202f2c:	9d3fd0ef          	jal	ffffffffc02008fe <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202f30:	000b3783          	ld	a5,0(s6)
ffffffffc0202f34:	4505                	li	a0,1
ffffffffc0202f36:	6f9c                	ld	a5,24(a5)
ffffffffc0202f38:	9782                	jalr	a5
ffffffffc0202f3a:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202f3c:	9bdfd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202f40:	be75                	j	ffffffffc0202afc <pmm_init+0x19a>
        intr_disable();
ffffffffc0202f42:	9bdfd0ef          	jal	ffffffffc02008fe <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202f46:	000b3783          	ld	a5,0(s6)
ffffffffc0202f4a:	779c                	ld	a5,40(a5)
ffffffffc0202f4c:	9782                	jalr	a5
ffffffffc0202f4e:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202f50:	9a9fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202f54:	b6ad                	j	ffffffffc0202abe <pmm_init+0x15c>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202f56:	6705                	lui	a4,0x1
ffffffffc0202f58:	177d                	addi	a4,a4,-1 # fff <_binary_obj___user_softint_out_size-0x80e9>
ffffffffc0202f5a:	96ba                	add	a3,a3,a4
ffffffffc0202f5c:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc0202f5e:	00c7d713          	srli	a4,a5,0xc
ffffffffc0202f62:	14a77e63          	bgeu	a4,a0,ffffffffc02030be <pmm_init+0x75c>
    pmm_manager->init_memmap(base, n);
ffffffffc0202f66:	000b3683          	ld	a3,0(s6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202f6a:	8c1d                	sub	s0,s0,a5
    return &pages[PPN(pa) - nbase];
ffffffffc0202f6c:	071a                	slli	a4,a4,0x6
ffffffffc0202f6e:	fe0007b7          	lui	a5,0xfe000
ffffffffc0202f72:	973e                	add	a4,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0202f74:	6a9c                	ld	a5,16(a3)
ffffffffc0202f76:	00c45593          	srli	a1,s0,0xc
ffffffffc0202f7a:	00e60533          	add	a0,a2,a4
ffffffffc0202f7e:	9782                	jalr	a5
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202f80:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202f84:	bcf1                	j	ffffffffc0202a60 <pmm_init+0xfe>
        intr_disable();
ffffffffc0202f86:	979fd0ef          	jal	ffffffffc02008fe <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202f8a:	000b3783          	ld	a5,0(s6)
ffffffffc0202f8e:	4505                	li	a0,1
ffffffffc0202f90:	6f9c                	ld	a5,24(a5)
ffffffffc0202f92:	9782                	jalr	a5
ffffffffc0202f94:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202f96:	963fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202f9a:	b119                	j	ffffffffc0202ba0 <pmm_init+0x23e>
        intr_disable();
ffffffffc0202f9c:	963fd0ef          	jal	ffffffffc02008fe <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202fa0:	000b3783          	ld	a5,0(s6)
ffffffffc0202fa4:	779c                	ld	a5,40(a5)
ffffffffc0202fa6:	9782                	jalr	a5
ffffffffc0202fa8:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202faa:	94ffd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202fae:	b345                	j	ffffffffc0202d4e <pmm_init+0x3ec>
        intr_disable();
ffffffffc0202fb0:	94ffd0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc0202fb4:	000b3783          	ld	a5,0(s6)
ffffffffc0202fb8:	779c                	ld	a5,40(a5)
ffffffffc0202fba:	9782                	jalr	a5
ffffffffc0202fbc:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202fbe:	93bfd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202fc2:	b3a5                	j	ffffffffc0202d2a <pmm_init+0x3c8>
ffffffffc0202fc4:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202fc6:	939fd0ef          	jal	ffffffffc02008fe <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202fca:	000b3783          	ld	a5,0(s6)
ffffffffc0202fce:	6522                	ld	a0,8(sp)
ffffffffc0202fd0:	4585                	li	a1,1
ffffffffc0202fd2:	739c                	ld	a5,32(a5)
ffffffffc0202fd4:	9782                	jalr	a5
        intr_enable();
ffffffffc0202fd6:	923fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202fda:	bb05                	j	ffffffffc0202d0a <pmm_init+0x3a8>
ffffffffc0202fdc:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202fde:	921fd0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc0202fe2:	000b3783          	ld	a5,0(s6)
ffffffffc0202fe6:	6522                	ld	a0,8(sp)
ffffffffc0202fe8:	4585                	li	a1,1
ffffffffc0202fea:	739c                	ld	a5,32(a5)
ffffffffc0202fec:	9782                	jalr	a5
        intr_enable();
ffffffffc0202fee:	90bfd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202ff2:	b1e5                	j	ffffffffc0202cda <pmm_init+0x378>
        intr_disable();
ffffffffc0202ff4:	90bfd0ef          	jal	ffffffffc02008fe <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202ff8:	000b3783          	ld	a5,0(s6)
ffffffffc0202ffc:	4505                	li	a0,1
ffffffffc0202ffe:	6f9c                	ld	a5,24(a5)
ffffffffc0203000:	9782                	jalr	a5
ffffffffc0203002:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203004:	8f5fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0203008:	b375                	j	ffffffffc0202db4 <pmm_init+0x452>
        intr_disable();
ffffffffc020300a:	8f5fd0ef          	jal	ffffffffc02008fe <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc020300e:	000b3783          	ld	a5,0(s6)
ffffffffc0203012:	779c                	ld	a5,40(a5)
ffffffffc0203014:	9782                	jalr	a5
ffffffffc0203016:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0203018:	8e1fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc020301c:	b5c5                	j	ffffffffc0202efc <pmm_init+0x59a>
ffffffffc020301e:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203020:	8dffd0ef          	jal	ffffffffc02008fe <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203024:	000b3783          	ld	a5,0(s6)
ffffffffc0203028:	6522                	ld	a0,8(sp)
ffffffffc020302a:	4585                	li	a1,1
ffffffffc020302c:	739c                	ld	a5,32(a5)
ffffffffc020302e:	9782                	jalr	a5
        intr_enable();
ffffffffc0203030:	8c9fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0203034:	b565                	j	ffffffffc0202edc <pmm_init+0x57a>
ffffffffc0203036:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0203038:	8c7fd0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc020303c:	000b3783          	ld	a5,0(s6)
ffffffffc0203040:	6522                	ld	a0,8(sp)
ffffffffc0203042:	4585                	li	a1,1
ffffffffc0203044:	739c                	ld	a5,32(a5)
ffffffffc0203046:	9782                	jalr	a5
        intr_enable();
ffffffffc0203048:	8b1fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc020304c:	b585                	j	ffffffffc0202eac <pmm_init+0x54a>
        intr_disable();
ffffffffc020304e:	8b1fd0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc0203052:	000b3783          	ld	a5,0(s6)
ffffffffc0203056:	8522                	mv	a0,s0
ffffffffc0203058:	4585                	li	a1,1
ffffffffc020305a:	739c                	ld	a5,32(a5)
ffffffffc020305c:	9782                	jalr	a5
        intr_enable();
ffffffffc020305e:	89bfd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0203062:	bd29                	j	ffffffffc0202e7c <pmm_init+0x51a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0203064:	86a2                	mv	a3,s0
ffffffffc0203066:	00004617          	auipc	a2,0x4
ffffffffc020306a:	50260613          	addi	a2,a2,1282 # ffffffffc0207568 <etext+0xe06>
ffffffffc020306e:	24f00593          	li	a1,591
ffffffffc0203072:	00004517          	auipc	a0,0x4
ffffffffc0203076:	5e650513          	addi	a0,a0,1510 # ffffffffc0207658 <etext+0xef6>
ffffffffc020307a:	bd0fd0ef          	jal	ffffffffc020044a <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc020307e:	00005697          	auipc	a3,0x5
ffffffffc0203082:	a9268693          	addi	a3,a3,-1390 # ffffffffc0207b10 <etext+0x13ae>
ffffffffc0203086:	00004617          	auipc	a2,0x4
ffffffffc020308a:	e8a60613          	addi	a2,a2,-374 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020308e:	25000593          	li	a1,592
ffffffffc0203092:	00004517          	auipc	a0,0x4
ffffffffc0203096:	5c650513          	addi	a0,a0,1478 # ffffffffc0207658 <etext+0xef6>
ffffffffc020309a:	bb0fd0ef          	jal	ffffffffc020044a <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc020309e:	00005697          	auipc	a3,0x5
ffffffffc02030a2:	a3268693          	addi	a3,a3,-1486 # ffffffffc0207ad0 <etext+0x136e>
ffffffffc02030a6:	00004617          	auipc	a2,0x4
ffffffffc02030aa:	e6a60613          	addi	a2,a2,-406 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02030ae:	24f00593          	li	a1,591
ffffffffc02030b2:	00004517          	auipc	a0,0x4
ffffffffc02030b6:	5a650513          	addi	a0,a0,1446 # ffffffffc0207658 <etext+0xef6>
ffffffffc02030ba:	b90fd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02030be:	deffe0ef          	jal	ffffffffc0201eac <pa2page.part.0>
        panic("pte2page called with invalid pte");
ffffffffc02030c2:	00004617          	auipc	a2,0x4
ffffffffc02030c6:	5ee60613          	addi	a2,a2,1518 # ffffffffc02076b0 <etext+0xf4e>
ffffffffc02030ca:	07f00593          	li	a1,127
ffffffffc02030ce:	00004517          	auipc	a0,0x4
ffffffffc02030d2:	4c250513          	addi	a0,a0,1218 # ffffffffc0207590 <etext+0xe2e>
ffffffffc02030d6:	b74fd0ef          	jal	ffffffffc020044a <__panic>
        panic("DTB memory info not available");
ffffffffc02030da:	00004617          	auipc	a2,0x4
ffffffffc02030de:	63660613          	addi	a2,a2,1590 # ffffffffc0207710 <etext+0xfae>
ffffffffc02030e2:	06400593          	li	a1,100
ffffffffc02030e6:	00004517          	auipc	a0,0x4
ffffffffc02030ea:	57250513          	addi	a0,a0,1394 # ffffffffc0207658 <etext+0xef6>
ffffffffc02030ee:	b5cfd0ef          	jal	ffffffffc020044a <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc02030f2:	00005697          	auipc	a3,0x5
ffffffffc02030f6:	99668693          	addi	a3,a3,-1642 # ffffffffc0207a88 <etext+0x1326>
ffffffffc02030fa:	00004617          	auipc	a2,0x4
ffffffffc02030fe:	e1660613          	addi	a2,a2,-490 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203102:	26a00593          	li	a1,618
ffffffffc0203106:	00004517          	auipc	a0,0x4
ffffffffc020310a:	55250513          	addi	a0,a0,1362 # ffffffffc0207658 <etext+0xef6>
ffffffffc020310e:	b3cfd0ef          	jal	ffffffffc020044a <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0203112:	00004697          	auipc	a3,0x4
ffffffffc0203116:	6b668693          	addi	a3,a3,1718 # ffffffffc02077c8 <etext+0x1066>
ffffffffc020311a:	00004617          	auipc	a2,0x4
ffffffffc020311e:	df660613          	addi	a2,a2,-522 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203122:	21100593          	li	a1,529
ffffffffc0203126:	00004517          	auipc	a0,0x4
ffffffffc020312a:	53250513          	addi	a0,a0,1330 # ffffffffc0207658 <etext+0xef6>
ffffffffc020312e:	b1cfd0ef          	jal	ffffffffc020044a <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203132:	00004697          	auipc	a3,0x4
ffffffffc0203136:	67668693          	addi	a3,a3,1654 # ffffffffc02077a8 <etext+0x1046>
ffffffffc020313a:	00004617          	auipc	a2,0x4
ffffffffc020313e:	dd660613          	addi	a2,a2,-554 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203142:	21000593          	li	a1,528
ffffffffc0203146:	00004517          	auipc	a0,0x4
ffffffffc020314a:	51250513          	addi	a0,a0,1298 # ffffffffc0207658 <etext+0xef6>
ffffffffc020314e:	afcfd0ef          	jal	ffffffffc020044a <__panic>
    return KADDR(page2pa(page));
ffffffffc0203152:	00004617          	auipc	a2,0x4
ffffffffc0203156:	41660613          	addi	a2,a2,1046 # ffffffffc0207568 <etext+0xe06>
ffffffffc020315a:	07100593          	li	a1,113
ffffffffc020315e:	00004517          	auipc	a0,0x4
ffffffffc0203162:	43250513          	addi	a0,a0,1074 # ffffffffc0207590 <etext+0xe2e>
ffffffffc0203166:	ae4fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc020316a:	00005697          	auipc	a3,0x5
ffffffffc020316e:	8ee68693          	addi	a3,a3,-1810 # ffffffffc0207a58 <etext+0x12f6>
ffffffffc0203172:	00004617          	auipc	a2,0x4
ffffffffc0203176:	d9e60613          	addi	a2,a2,-610 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020317a:	23800593          	li	a1,568
ffffffffc020317e:	00004517          	auipc	a0,0x4
ffffffffc0203182:	4da50513          	addi	a0,a0,1242 # ffffffffc0207658 <etext+0xef6>
ffffffffc0203186:	ac4fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020318a:	00005697          	auipc	a3,0x5
ffffffffc020318e:	88668693          	addi	a3,a3,-1914 # ffffffffc0207a10 <etext+0x12ae>
ffffffffc0203192:	00004617          	auipc	a2,0x4
ffffffffc0203196:	d7e60613          	addi	a2,a2,-642 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020319a:	23600593          	li	a1,566
ffffffffc020319e:	00004517          	auipc	a0,0x4
ffffffffc02031a2:	4ba50513          	addi	a0,a0,1210 # ffffffffc0207658 <etext+0xef6>
ffffffffc02031a6:	aa4fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02031aa:	00005697          	auipc	a3,0x5
ffffffffc02031ae:	89668693          	addi	a3,a3,-1898 # ffffffffc0207a40 <etext+0x12de>
ffffffffc02031b2:	00004617          	auipc	a2,0x4
ffffffffc02031b6:	d5e60613          	addi	a2,a2,-674 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02031ba:	23500593          	li	a1,565
ffffffffc02031be:	00004517          	auipc	a0,0x4
ffffffffc02031c2:	49a50513          	addi	a0,a0,1178 # ffffffffc0207658 <etext+0xef6>
ffffffffc02031c6:	a84fd0ef          	jal	ffffffffc020044a <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc02031ca:	00005697          	auipc	a3,0x5
ffffffffc02031ce:	95e68693          	addi	a3,a3,-1698 # ffffffffc0207b28 <etext+0x13c6>
ffffffffc02031d2:	00004617          	auipc	a2,0x4
ffffffffc02031d6:	d3e60613          	addi	a2,a2,-706 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02031da:	25300593          	li	a1,595
ffffffffc02031de:	00004517          	auipc	a0,0x4
ffffffffc02031e2:	47a50513          	addi	a0,a0,1146 # ffffffffc0207658 <etext+0xef6>
ffffffffc02031e6:	a64fd0ef          	jal	ffffffffc020044a <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc02031ea:	00005697          	auipc	a3,0x5
ffffffffc02031ee:	89e68693          	addi	a3,a3,-1890 # ffffffffc0207a88 <etext+0x1326>
ffffffffc02031f2:	00004617          	auipc	a2,0x4
ffffffffc02031f6:	d1e60613          	addi	a2,a2,-738 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02031fa:	24000593          	li	a1,576
ffffffffc02031fe:	00004517          	auipc	a0,0x4
ffffffffc0203202:	45a50513          	addi	a0,a0,1114 # ffffffffc0207658 <etext+0xef6>
ffffffffc0203206:	a44fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p) == 1);
ffffffffc020320a:	00005697          	auipc	a3,0x5
ffffffffc020320e:	97668693          	addi	a3,a3,-1674 # ffffffffc0207b80 <etext+0x141e>
ffffffffc0203212:	00004617          	auipc	a2,0x4
ffffffffc0203216:	cfe60613          	addi	a2,a2,-770 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020321a:	25800593          	li	a1,600
ffffffffc020321e:	00004517          	auipc	a0,0x4
ffffffffc0203222:	43a50513          	addi	a0,a0,1082 # ffffffffc0207658 <etext+0xef6>
ffffffffc0203226:	a24fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc020322a:	00005697          	auipc	a3,0x5
ffffffffc020322e:	91668693          	addi	a3,a3,-1770 # ffffffffc0207b40 <etext+0x13de>
ffffffffc0203232:	00004617          	auipc	a2,0x4
ffffffffc0203236:	cde60613          	addi	a2,a2,-802 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020323a:	25700593          	li	a1,599
ffffffffc020323e:	00004517          	auipc	a0,0x4
ffffffffc0203242:	41a50513          	addi	a0,a0,1050 # ffffffffc0207658 <etext+0xef6>
ffffffffc0203246:	a04fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc020324a:	00004697          	auipc	a3,0x4
ffffffffc020324e:	7c668693          	addi	a3,a3,1990 # ffffffffc0207a10 <etext+0x12ae>
ffffffffc0203252:	00004617          	auipc	a2,0x4
ffffffffc0203256:	cbe60613          	addi	a2,a2,-834 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020325a:	23200593          	li	a1,562
ffffffffc020325e:	00004517          	auipc	a0,0x4
ffffffffc0203262:	3fa50513          	addi	a0,a0,1018 # ffffffffc0207658 <etext+0xef6>
ffffffffc0203266:	9e4fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020326a:	00004697          	auipc	a3,0x4
ffffffffc020326e:	64668693          	addi	a3,a3,1606 # ffffffffc02078b0 <etext+0x114e>
ffffffffc0203272:	00004617          	auipc	a2,0x4
ffffffffc0203276:	c9e60613          	addi	a2,a2,-866 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020327a:	23100593          	li	a1,561
ffffffffc020327e:	00004517          	auipc	a0,0x4
ffffffffc0203282:	3da50513          	addi	a0,a0,986 # ffffffffc0207658 <etext+0xef6>
ffffffffc0203286:	9c4fd0ef          	jal	ffffffffc020044a <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc020328a:	00004697          	auipc	a3,0x4
ffffffffc020328e:	79e68693          	addi	a3,a3,1950 # ffffffffc0207a28 <etext+0x12c6>
ffffffffc0203292:	00004617          	auipc	a2,0x4
ffffffffc0203296:	c7e60613          	addi	a2,a2,-898 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020329a:	22e00593          	li	a1,558
ffffffffc020329e:	00004517          	auipc	a0,0x4
ffffffffc02032a2:	3ba50513          	addi	a0,a0,954 # ffffffffc0207658 <etext+0xef6>
ffffffffc02032a6:	9a4fd0ef          	jal	ffffffffc020044a <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02032aa:	00004697          	auipc	a3,0x4
ffffffffc02032ae:	5ee68693          	addi	a3,a3,1518 # ffffffffc0207898 <etext+0x1136>
ffffffffc02032b2:	00004617          	auipc	a2,0x4
ffffffffc02032b6:	c5e60613          	addi	a2,a2,-930 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02032ba:	22d00593          	li	a1,557
ffffffffc02032be:	00004517          	auipc	a0,0x4
ffffffffc02032c2:	39a50513          	addi	a0,a0,922 # ffffffffc0207658 <etext+0xef6>
ffffffffc02032c6:	984fd0ef          	jal	ffffffffc020044a <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02032ca:	00004697          	auipc	a3,0x4
ffffffffc02032ce:	66e68693          	addi	a3,a3,1646 # ffffffffc0207938 <etext+0x11d6>
ffffffffc02032d2:	00004617          	auipc	a2,0x4
ffffffffc02032d6:	c3e60613          	addi	a2,a2,-962 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02032da:	22c00593          	li	a1,556
ffffffffc02032de:	00004517          	auipc	a0,0x4
ffffffffc02032e2:	37a50513          	addi	a0,a0,890 # ffffffffc0207658 <etext+0xef6>
ffffffffc02032e6:	964fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02032ea:	00004697          	auipc	a3,0x4
ffffffffc02032ee:	72668693          	addi	a3,a3,1830 # ffffffffc0207a10 <etext+0x12ae>
ffffffffc02032f2:	00004617          	auipc	a2,0x4
ffffffffc02032f6:	c1e60613          	addi	a2,a2,-994 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02032fa:	22b00593          	li	a1,555
ffffffffc02032fe:	00004517          	auipc	a0,0x4
ffffffffc0203302:	35a50513          	addi	a0,a0,858 # ffffffffc0207658 <etext+0xef6>
ffffffffc0203306:	944fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p1) == 2);
ffffffffc020330a:	00004697          	auipc	a3,0x4
ffffffffc020330e:	6ee68693          	addi	a3,a3,1774 # ffffffffc02079f8 <etext+0x1296>
ffffffffc0203312:	00004617          	auipc	a2,0x4
ffffffffc0203316:	bfe60613          	addi	a2,a2,-1026 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020331a:	22a00593          	li	a1,554
ffffffffc020331e:	00004517          	auipc	a0,0x4
ffffffffc0203322:	33a50513          	addi	a0,a0,826 # ffffffffc0207658 <etext+0xef6>
ffffffffc0203326:	924fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc020332a:	00004697          	auipc	a3,0x4
ffffffffc020332e:	69e68693          	addi	a3,a3,1694 # ffffffffc02079c8 <etext+0x1266>
ffffffffc0203332:	00004617          	auipc	a2,0x4
ffffffffc0203336:	bde60613          	addi	a2,a2,-1058 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020333a:	22900593          	li	a1,553
ffffffffc020333e:	00004517          	auipc	a0,0x4
ffffffffc0203342:	31a50513          	addi	a0,a0,794 # ffffffffc0207658 <etext+0xef6>
ffffffffc0203346:	904fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p2) == 1);
ffffffffc020334a:	00004697          	auipc	a3,0x4
ffffffffc020334e:	66668693          	addi	a3,a3,1638 # ffffffffc02079b0 <etext+0x124e>
ffffffffc0203352:	00004617          	auipc	a2,0x4
ffffffffc0203356:	bbe60613          	addi	a2,a2,-1090 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020335a:	22700593          	li	a1,551
ffffffffc020335e:	00004517          	auipc	a0,0x4
ffffffffc0203362:	2fa50513          	addi	a0,a0,762 # ffffffffc0207658 <etext+0xef6>
ffffffffc0203366:	8e4fd0ef          	jal	ffffffffc020044a <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc020336a:	00004697          	auipc	a3,0x4
ffffffffc020336e:	62668693          	addi	a3,a3,1574 # ffffffffc0207990 <etext+0x122e>
ffffffffc0203372:	00004617          	auipc	a2,0x4
ffffffffc0203376:	b9e60613          	addi	a2,a2,-1122 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020337a:	22600593          	li	a1,550
ffffffffc020337e:	00004517          	auipc	a0,0x4
ffffffffc0203382:	2da50513          	addi	a0,a0,730 # ffffffffc0207658 <etext+0xef6>
ffffffffc0203386:	8c4fd0ef          	jal	ffffffffc020044a <__panic>
    assert(*ptep & PTE_W);
ffffffffc020338a:	00004697          	auipc	a3,0x4
ffffffffc020338e:	5f668693          	addi	a3,a3,1526 # ffffffffc0207980 <etext+0x121e>
ffffffffc0203392:	00004617          	auipc	a2,0x4
ffffffffc0203396:	b7e60613          	addi	a2,a2,-1154 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020339a:	22500593          	li	a1,549
ffffffffc020339e:	00004517          	auipc	a0,0x4
ffffffffc02033a2:	2ba50513          	addi	a0,a0,698 # ffffffffc0207658 <etext+0xef6>
ffffffffc02033a6:	8a4fd0ef          	jal	ffffffffc020044a <__panic>
    assert(*ptep & PTE_U);
ffffffffc02033aa:	00004697          	auipc	a3,0x4
ffffffffc02033ae:	5c668693          	addi	a3,a3,1478 # ffffffffc0207970 <etext+0x120e>
ffffffffc02033b2:	00004617          	auipc	a2,0x4
ffffffffc02033b6:	b5e60613          	addi	a2,a2,-1186 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02033ba:	22400593          	li	a1,548
ffffffffc02033be:	00004517          	auipc	a0,0x4
ffffffffc02033c2:	29a50513          	addi	a0,a0,666 # ffffffffc0207658 <etext+0xef6>
ffffffffc02033c6:	884fd0ef          	jal	ffffffffc020044a <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02033ca:	00004617          	auipc	a2,0x4
ffffffffc02033ce:	24660613          	addi	a2,a2,582 # ffffffffc0207610 <etext+0xeae>
ffffffffc02033d2:	08000593          	li	a1,128
ffffffffc02033d6:	00004517          	auipc	a0,0x4
ffffffffc02033da:	28250513          	addi	a0,a0,642 # ffffffffc0207658 <etext+0xef6>
ffffffffc02033de:	86cfd0ef          	jal	ffffffffc020044a <__panic>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02033e2:	00004697          	auipc	a3,0x4
ffffffffc02033e6:	4e668693          	addi	a3,a3,1254 # ffffffffc02078c8 <etext+0x1166>
ffffffffc02033ea:	00004617          	auipc	a2,0x4
ffffffffc02033ee:	b2660613          	addi	a2,a2,-1242 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02033f2:	21f00593          	li	a1,543
ffffffffc02033f6:	00004517          	auipc	a0,0x4
ffffffffc02033fa:	26250513          	addi	a0,a0,610 # ffffffffc0207658 <etext+0xef6>
ffffffffc02033fe:	84cfd0ef          	jal	ffffffffc020044a <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0203402:	00004697          	auipc	a3,0x4
ffffffffc0203406:	53668693          	addi	a3,a3,1334 # ffffffffc0207938 <etext+0x11d6>
ffffffffc020340a:	00004617          	auipc	a2,0x4
ffffffffc020340e:	b0660613          	addi	a2,a2,-1274 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203412:	22300593          	li	a1,547
ffffffffc0203416:	00004517          	auipc	a0,0x4
ffffffffc020341a:	24250513          	addi	a0,a0,578 # ffffffffc0207658 <etext+0xef6>
ffffffffc020341e:	82cfd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203422:	00004697          	auipc	a3,0x4
ffffffffc0203426:	4d668693          	addi	a3,a3,1238 # ffffffffc02078f8 <etext+0x1196>
ffffffffc020342a:	00004617          	auipc	a2,0x4
ffffffffc020342e:	ae660613          	addi	a2,a2,-1306 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203432:	22200593          	li	a1,546
ffffffffc0203436:	00004517          	auipc	a0,0x4
ffffffffc020343a:	22250513          	addi	a0,a0,546 # ffffffffc0207658 <etext+0xef6>
ffffffffc020343e:	80cfd0ef          	jal	ffffffffc020044a <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203442:	86d6                	mv	a3,s5
ffffffffc0203444:	00004617          	auipc	a2,0x4
ffffffffc0203448:	12460613          	addi	a2,a2,292 # ffffffffc0207568 <etext+0xe06>
ffffffffc020344c:	21e00593          	li	a1,542
ffffffffc0203450:	00004517          	auipc	a0,0x4
ffffffffc0203454:	20850513          	addi	a0,a0,520 # ffffffffc0207658 <etext+0xef6>
ffffffffc0203458:	ff3fc0ef          	jal	ffffffffc020044a <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc020345c:	00004617          	auipc	a2,0x4
ffffffffc0203460:	10c60613          	addi	a2,a2,268 # ffffffffc0207568 <etext+0xe06>
ffffffffc0203464:	21d00593          	li	a1,541
ffffffffc0203468:	00004517          	auipc	a0,0x4
ffffffffc020346c:	1f050513          	addi	a0,a0,496 # ffffffffc0207658 <etext+0xef6>
ffffffffc0203470:	fdbfc0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203474:	00004697          	auipc	a3,0x4
ffffffffc0203478:	43c68693          	addi	a3,a3,1084 # ffffffffc02078b0 <etext+0x114e>
ffffffffc020347c:	00004617          	auipc	a2,0x4
ffffffffc0203480:	a9460613          	addi	a2,a2,-1388 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203484:	21b00593          	li	a1,539
ffffffffc0203488:	00004517          	auipc	a0,0x4
ffffffffc020348c:	1d050513          	addi	a0,a0,464 # ffffffffc0207658 <etext+0xef6>
ffffffffc0203490:	fbbfc0ef          	jal	ffffffffc020044a <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203494:	00004697          	auipc	a3,0x4
ffffffffc0203498:	40468693          	addi	a3,a3,1028 # ffffffffc0207898 <etext+0x1136>
ffffffffc020349c:	00004617          	auipc	a2,0x4
ffffffffc02034a0:	a7460613          	addi	a2,a2,-1420 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02034a4:	21a00593          	li	a1,538
ffffffffc02034a8:	00004517          	auipc	a0,0x4
ffffffffc02034ac:	1b050513          	addi	a0,a0,432 # ffffffffc0207658 <etext+0xef6>
ffffffffc02034b0:	f9bfc0ef          	jal	ffffffffc020044a <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02034b4:	00004697          	auipc	a3,0x4
ffffffffc02034b8:	79468693          	addi	a3,a3,1940 # ffffffffc0207c48 <etext+0x14e6>
ffffffffc02034bc:	00004617          	auipc	a2,0x4
ffffffffc02034c0:	a5460613          	addi	a2,a2,-1452 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02034c4:	26100593          	li	a1,609
ffffffffc02034c8:	00004517          	auipc	a0,0x4
ffffffffc02034cc:	19050513          	addi	a0,a0,400 # ffffffffc0207658 <etext+0xef6>
ffffffffc02034d0:	f7bfc0ef          	jal	ffffffffc020044a <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02034d4:	00004697          	auipc	a3,0x4
ffffffffc02034d8:	73c68693          	addi	a3,a3,1852 # ffffffffc0207c10 <etext+0x14ae>
ffffffffc02034dc:	00004617          	auipc	a2,0x4
ffffffffc02034e0:	a3460613          	addi	a2,a2,-1484 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02034e4:	25e00593          	li	a1,606
ffffffffc02034e8:	00004517          	auipc	a0,0x4
ffffffffc02034ec:	17050513          	addi	a0,a0,368 # ffffffffc0207658 <etext+0xef6>
ffffffffc02034f0:	f5bfc0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p) == 2);
ffffffffc02034f4:	00004697          	auipc	a3,0x4
ffffffffc02034f8:	6ec68693          	addi	a3,a3,1772 # ffffffffc0207be0 <etext+0x147e>
ffffffffc02034fc:	00004617          	auipc	a2,0x4
ffffffffc0203500:	a1460613          	addi	a2,a2,-1516 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203504:	25a00593          	li	a1,602
ffffffffc0203508:	00004517          	auipc	a0,0x4
ffffffffc020350c:	15050513          	addi	a0,a0,336 # ffffffffc0207658 <etext+0xef6>
ffffffffc0203510:	f3bfc0ef          	jal	ffffffffc020044a <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0203514:	00004697          	auipc	a3,0x4
ffffffffc0203518:	68468693          	addi	a3,a3,1668 # ffffffffc0207b98 <etext+0x1436>
ffffffffc020351c:	00004617          	auipc	a2,0x4
ffffffffc0203520:	9f460613          	addi	a2,a2,-1548 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203524:	25900593          	li	a1,601
ffffffffc0203528:	00004517          	auipc	a0,0x4
ffffffffc020352c:	13050513          	addi	a0,a0,304 # ffffffffc0207658 <etext+0xef6>
ffffffffc0203530:	f1bfc0ef          	jal	ffffffffc020044a <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0203534:	00004697          	auipc	a3,0x4
ffffffffc0203538:	2d468693          	addi	a3,a3,724 # ffffffffc0207808 <etext+0x10a6>
ffffffffc020353c:	00004617          	auipc	a2,0x4
ffffffffc0203540:	9d460613          	addi	a2,a2,-1580 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203544:	21200593          	li	a1,530
ffffffffc0203548:	00004517          	auipc	a0,0x4
ffffffffc020354c:	11050513          	addi	a0,a0,272 # ffffffffc0207658 <etext+0xef6>
ffffffffc0203550:	efbfc0ef          	jal	ffffffffc020044a <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc0203554:	00004617          	auipc	a2,0x4
ffffffffc0203558:	0bc60613          	addi	a2,a2,188 # ffffffffc0207610 <etext+0xeae>
ffffffffc020355c:	0c800593          	li	a1,200
ffffffffc0203560:	00004517          	auipc	a0,0x4
ffffffffc0203564:	0f850513          	addi	a0,a0,248 # ffffffffc0207658 <etext+0xef6>
ffffffffc0203568:	ee3fc0ef          	jal	ffffffffc020044a <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc020356c:	00004697          	auipc	a3,0x4
ffffffffc0203570:	2fc68693          	addi	a3,a3,764 # ffffffffc0207868 <etext+0x1106>
ffffffffc0203574:	00004617          	auipc	a2,0x4
ffffffffc0203578:	99c60613          	addi	a2,a2,-1636 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020357c:	21900593          	li	a1,537
ffffffffc0203580:	00004517          	auipc	a0,0x4
ffffffffc0203584:	0d850513          	addi	a0,a0,216 # ffffffffc0207658 <etext+0xef6>
ffffffffc0203588:	ec3fc0ef          	jal	ffffffffc020044a <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc020358c:	00004697          	auipc	a3,0x4
ffffffffc0203590:	2ac68693          	addi	a3,a3,684 # ffffffffc0207838 <etext+0x10d6>
ffffffffc0203594:	00004617          	auipc	a2,0x4
ffffffffc0203598:	97c60613          	addi	a2,a2,-1668 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020359c:	21600593          	li	a1,534
ffffffffc02035a0:	00004517          	auipc	a0,0x4
ffffffffc02035a4:	0b850513          	addi	a0,a0,184 # ffffffffc0207658 <etext+0xef6>
ffffffffc02035a8:	ea3fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02035ac <pgdir_alloc_page>:
{
ffffffffc02035ac:	7139                	addi	sp,sp,-64
ffffffffc02035ae:	f426                	sd	s1,40(sp)
ffffffffc02035b0:	f04a                	sd	s2,32(sp)
ffffffffc02035b2:	ec4e                	sd	s3,24(sp)
ffffffffc02035b4:	fc06                	sd	ra,56(sp)
ffffffffc02035b6:	f822                	sd	s0,48(sp)
ffffffffc02035b8:	892a                	mv	s2,a0
ffffffffc02035ba:	84ae                	mv	s1,a1
ffffffffc02035bc:	89b2                	mv	s3,a2
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02035be:	100027f3          	csrr	a5,sstatus
ffffffffc02035c2:	8b89                	andi	a5,a5,2
ffffffffc02035c4:	ebb5                	bnez	a5,ffffffffc0203638 <pgdir_alloc_page+0x8c>
        page = pmm_manager->alloc_pages(n);
ffffffffc02035c6:	000c9417          	auipc	s0,0xc9
ffffffffc02035ca:	d5240413          	addi	s0,s0,-686 # ffffffffc02cc318 <pmm_manager>
ffffffffc02035ce:	601c                	ld	a5,0(s0)
ffffffffc02035d0:	4505                	li	a0,1
ffffffffc02035d2:	6f9c                	ld	a5,24(a5)
ffffffffc02035d4:	9782                	jalr	a5
ffffffffc02035d6:	85aa                	mv	a1,a0
    if (page != NULL)
ffffffffc02035d8:	c5b9                	beqz	a1,ffffffffc0203626 <pgdir_alloc_page+0x7a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc02035da:	86ce                	mv	a3,s3
ffffffffc02035dc:	854a                	mv	a0,s2
ffffffffc02035de:	8626                	mv	a2,s1
ffffffffc02035e0:	e42e                	sd	a1,8(sp)
ffffffffc02035e2:	a8aff0ef          	jal	ffffffffc020286c <page_insert>
ffffffffc02035e6:	65a2                	ld	a1,8(sp)
ffffffffc02035e8:	e515                	bnez	a0,ffffffffc0203614 <pgdir_alloc_page+0x68>
        assert(page_ref(page) == 1);
ffffffffc02035ea:	4198                	lw	a4,0(a1)
        page->pra_vaddr = la;
ffffffffc02035ec:	fd84                	sd	s1,56(a1)
        assert(page_ref(page) == 1);
ffffffffc02035ee:	4785                	li	a5,1
ffffffffc02035f0:	02f70c63          	beq	a4,a5,ffffffffc0203628 <pgdir_alloc_page+0x7c>
ffffffffc02035f4:	00004697          	auipc	a3,0x4
ffffffffc02035f8:	69c68693          	addi	a3,a3,1692 # ffffffffc0207c90 <etext+0x152e>
ffffffffc02035fc:	00004617          	auipc	a2,0x4
ffffffffc0203600:	91460613          	addi	a2,a2,-1772 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203604:	1f700593          	li	a1,503
ffffffffc0203608:	00004517          	auipc	a0,0x4
ffffffffc020360c:	05050513          	addi	a0,a0,80 # ffffffffc0207658 <etext+0xef6>
ffffffffc0203610:	e3bfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203614:	100027f3          	csrr	a5,sstatus
ffffffffc0203618:	8b89                	andi	a5,a5,2
ffffffffc020361a:	ef95                	bnez	a5,ffffffffc0203656 <pgdir_alloc_page+0xaa>
        pmm_manager->free_pages(base, n);
ffffffffc020361c:	601c                	ld	a5,0(s0)
ffffffffc020361e:	852e                	mv	a0,a1
ffffffffc0203620:	4585                	li	a1,1
ffffffffc0203622:	739c                	ld	a5,32(a5)
ffffffffc0203624:	9782                	jalr	a5
            return NULL;
ffffffffc0203626:	4581                	li	a1,0
}
ffffffffc0203628:	70e2                	ld	ra,56(sp)
ffffffffc020362a:	7442                	ld	s0,48(sp)
ffffffffc020362c:	74a2                	ld	s1,40(sp)
ffffffffc020362e:	7902                	ld	s2,32(sp)
ffffffffc0203630:	69e2                	ld	s3,24(sp)
ffffffffc0203632:	852e                	mv	a0,a1
ffffffffc0203634:	6121                	addi	sp,sp,64
ffffffffc0203636:	8082                	ret
        intr_disable();
ffffffffc0203638:	ac6fd0ef          	jal	ffffffffc02008fe <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc020363c:	000c9417          	auipc	s0,0xc9
ffffffffc0203640:	cdc40413          	addi	s0,s0,-804 # ffffffffc02cc318 <pmm_manager>
ffffffffc0203644:	601c                	ld	a5,0(s0)
ffffffffc0203646:	4505                	li	a0,1
ffffffffc0203648:	6f9c                	ld	a5,24(a5)
ffffffffc020364a:	9782                	jalr	a5
ffffffffc020364c:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc020364e:	aaafd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0203652:	65a2                	ld	a1,8(sp)
ffffffffc0203654:	b751                	j	ffffffffc02035d8 <pgdir_alloc_page+0x2c>
        intr_disable();
ffffffffc0203656:	aa8fd0ef          	jal	ffffffffc02008fe <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020365a:	601c                	ld	a5,0(s0)
ffffffffc020365c:	6522                	ld	a0,8(sp)
ffffffffc020365e:	4585                	li	a1,1
ffffffffc0203660:	739c                	ld	a5,32(a5)
ffffffffc0203662:	9782                	jalr	a5
        intr_enable();
ffffffffc0203664:	a94fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0203668:	bf7d                	j	ffffffffc0203626 <pgdir_alloc_page+0x7a>

ffffffffc020366a <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc020366a:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc020366c:	00004697          	auipc	a3,0x4
ffffffffc0203670:	63c68693          	addi	a3,a3,1596 # ffffffffc0207ca8 <etext+0x1546>
ffffffffc0203674:	00004617          	auipc	a2,0x4
ffffffffc0203678:	89c60613          	addi	a2,a2,-1892 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020367c:	07400593          	li	a1,116
ffffffffc0203680:	00004517          	auipc	a0,0x4
ffffffffc0203684:	64850513          	addi	a0,a0,1608 # ffffffffc0207cc8 <etext+0x1566>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0203688:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc020368a:	dc1fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020368e <mm_create>:
{
ffffffffc020368e:	1101                	addi	sp,sp,-32
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203690:	05800513          	li	a0,88
{
ffffffffc0203694:	ec06                	sd	ra,24(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203696:	e6efe0ef          	jal	ffffffffc0201d04 <kmalloc>
ffffffffc020369a:	87aa                	mv	a5,a0
    if (mm != NULL)
ffffffffc020369c:	c505                	beqz	a0,ffffffffc02036c4 <mm_create+0x36>
    elm->prev = elm->next = elm;
ffffffffc020369e:	e788                	sd	a0,8(a5)
ffffffffc02036a0:	e388                	sd	a0,0(a5)
        mm->mmap_cache = NULL;
ffffffffc02036a2:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02036a6:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02036aa:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc02036ae:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc02036b2:	02052823          	sw	zero,48(a0)
        sem_init(&(mm->mm_sem), 1);
ffffffffc02036b6:	4585                	li	a1,1
ffffffffc02036b8:	03850513          	addi	a0,a0,56
ffffffffc02036bc:	e43e                	sd	a5,8(sp)
ffffffffc02036be:	05c010ef          	jal	ffffffffc020471a <sem_init>
ffffffffc02036c2:	67a2                	ld	a5,8(sp)
}
ffffffffc02036c4:	60e2                	ld	ra,24(sp)
ffffffffc02036c6:	853e                	mv	a0,a5
ffffffffc02036c8:	6105                	addi	sp,sp,32
ffffffffc02036ca:	8082                	ret

ffffffffc02036cc <find_vma>:
    if (mm != NULL)
ffffffffc02036cc:	c505                	beqz	a0,ffffffffc02036f4 <find_vma+0x28>
        vma = mm->mmap_cache;
ffffffffc02036ce:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc02036d0:	c781                	beqz	a5,ffffffffc02036d8 <find_vma+0xc>
ffffffffc02036d2:	6798                	ld	a4,8(a5)
ffffffffc02036d4:	02e5f363          	bgeu	a1,a4,ffffffffc02036fa <find_vma+0x2e>
    return listelm->next;
ffffffffc02036d8:	651c                	ld	a5,8(a0)
            while ((le = list_next(le)) != list)
ffffffffc02036da:	00f50d63          	beq	a0,a5,ffffffffc02036f4 <find_vma+0x28>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc02036de:	fe87b703          	ld	a4,-24(a5) # fffffffffdffffe8 <end+0x3dd33c68>
ffffffffc02036e2:	00e5e663          	bltu	a1,a4,ffffffffc02036ee <find_vma+0x22>
ffffffffc02036e6:	ff07b703          	ld	a4,-16(a5)
ffffffffc02036ea:	00e5ee63          	bltu	a1,a4,ffffffffc0203706 <find_vma+0x3a>
ffffffffc02036ee:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc02036f0:	fef517e3          	bne	a0,a5,ffffffffc02036de <find_vma+0x12>
    struct vma_struct *vma = NULL;
ffffffffc02036f4:	4781                	li	a5,0
}
ffffffffc02036f6:	853e                	mv	a0,a5
ffffffffc02036f8:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc02036fa:	6b98                	ld	a4,16(a5)
ffffffffc02036fc:	fce5fee3          	bgeu	a1,a4,ffffffffc02036d8 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc0203700:	e91c                	sd	a5,16(a0)
}
ffffffffc0203702:	853e                	mv	a0,a5
ffffffffc0203704:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc0203706:	1781                	addi	a5,a5,-32
            mm->mmap_cache = vma;
ffffffffc0203708:	e91c                	sd	a5,16(a0)
ffffffffc020370a:	bfe5                	j	ffffffffc0203702 <find_vma+0x36>

ffffffffc020370c <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc020370c:	6590                	ld	a2,8(a1)
ffffffffc020370e:	0105b803          	ld	a6,16(a1)
{
ffffffffc0203712:	1141                	addi	sp,sp,-16
ffffffffc0203714:	e406                	sd	ra,8(sp)
ffffffffc0203716:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203718:	01066763          	bltu	a2,a6,ffffffffc0203726 <insert_vma_struct+0x1a>
ffffffffc020371c:	a8b9                	j	ffffffffc020377a <insert_vma_struct+0x6e>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc020371e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203722:	04e66763          	bltu	a2,a4,ffffffffc0203770 <insert_vma_struct+0x64>
ffffffffc0203726:	86be                	mv	a3,a5
ffffffffc0203728:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc020372a:	fef51ae3          	bne	a0,a5,ffffffffc020371e <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc020372e:	02a68463          	beq	a3,a0,ffffffffc0203756 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc0203732:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203736:	fe86b883          	ld	a7,-24(a3)
ffffffffc020373a:	08e8f063          	bgeu	a7,a4,ffffffffc02037ba <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020373e:	04e66e63          	bltu	a2,a4,ffffffffc020379a <insert_vma_struct+0x8e>
    }
    if (le_next != list)
ffffffffc0203742:	00f50a63          	beq	a0,a5,ffffffffc0203756 <insert_vma_struct+0x4a>
ffffffffc0203746:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc020374a:	05076863          	bltu	a4,a6,ffffffffc020379a <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc020374e:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203752:	02c77263          	bgeu	a4,a2,ffffffffc0203776 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc0203756:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0203758:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc020375a:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc020375e:	e390                	sd	a2,0(a5)
ffffffffc0203760:	e690                	sd	a2,8(a3)
}
ffffffffc0203762:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0203764:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203766:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc0203768:	2705                	addiw	a4,a4,1
ffffffffc020376a:	d118                	sw	a4,32(a0)
}
ffffffffc020376c:	0141                	addi	sp,sp,16
ffffffffc020376e:	8082                	ret
    if (le_prev != list)
ffffffffc0203770:	fca691e3          	bne	a3,a0,ffffffffc0203732 <insert_vma_struct+0x26>
ffffffffc0203774:	bfd9                	j	ffffffffc020374a <insert_vma_struct+0x3e>
ffffffffc0203776:	ef5ff0ef          	jal	ffffffffc020366a <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc020377a:	00004697          	auipc	a3,0x4
ffffffffc020377e:	55e68693          	addi	a3,a3,1374 # ffffffffc0207cd8 <etext+0x1576>
ffffffffc0203782:	00003617          	auipc	a2,0x3
ffffffffc0203786:	78e60613          	addi	a2,a2,1934 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020378a:	07a00593          	li	a1,122
ffffffffc020378e:	00004517          	auipc	a0,0x4
ffffffffc0203792:	53a50513          	addi	a0,a0,1338 # ffffffffc0207cc8 <etext+0x1566>
ffffffffc0203796:	cb5fc0ef          	jal	ffffffffc020044a <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020379a:	00004697          	auipc	a3,0x4
ffffffffc020379e:	57e68693          	addi	a3,a3,1406 # ffffffffc0207d18 <etext+0x15b6>
ffffffffc02037a2:	00003617          	auipc	a2,0x3
ffffffffc02037a6:	76e60613          	addi	a2,a2,1902 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02037aa:	07300593          	li	a1,115
ffffffffc02037ae:	00004517          	auipc	a0,0x4
ffffffffc02037b2:	51a50513          	addi	a0,a0,1306 # ffffffffc0207cc8 <etext+0x1566>
ffffffffc02037b6:	c95fc0ef          	jal	ffffffffc020044a <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02037ba:	00004697          	auipc	a3,0x4
ffffffffc02037be:	53e68693          	addi	a3,a3,1342 # ffffffffc0207cf8 <etext+0x1596>
ffffffffc02037c2:	00003617          	auipc	a2,0x3
ffffffffc02037c6:	74e60613          	addi	a2,a2,1870 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02037ca:	07200593          	li	a1,114
ffffffffc02037ce:	00004517          	auipc	a0,0x4
ffffffffc02037d2:	4fa50513          	addi	a0,a0,1274 # ffffffffc0207cc8 <etext+0x1566>
ffffffffc02037d6:	c75fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02037da <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc02037da:	591c                	lw	a5,48(a0)
{
ffffffffc02037dc:	1141                	addi	sp,sp,-16
ffffffffc02037de:	e406                	sd	ra,8(sp)
ffffffffc02037e0:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc02037e2:	e78d                	bnez	a5,ffffffffc020380c <mm_destroy+0x32>
ffffffffc02037e4:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc02037e6:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc02037e8:	00a40c63          	beq	s0,a0,ffffffffc0203800 <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc02037ec:	6118                	ld	a4,0(a0)
ffffffffc02037ee:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc02037f0:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc02037f2:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02037f4:	e398                	sd	a4,0(a5)
ffffffffc02037f6:	db4fe0ef          	jal	ffffffffc0201daa <kfree>
    return listelm->next;
ffffffffc02037fa:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc02037fc:	fea418e3          	bne	s0,a0,ffffffffc02037ec <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc0203800:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc0203802:	6402                	ld	s0,0(sp)
ffffffffc0203804:	60a2                	ld	ra,8(sp)
ffffffffc0203806:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc0203808:	da2fe06f          	j	ffffffffc0201daa <kfree>
    assert(mm_count(mm) == 0);
ffffffffc020380c:	00004697          	auipc	a3,0x4
ffffffffc0203810:	52c68693          	addi	a3,a3,1324 # ffffffffc0207d38 <etext+0x15d6>
ffffffffc0203814:	00003617          	auipc	a2,0x3
ffffffffc0203818:	6fc60613          	addi	a2,a2,1788 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020381c:	09e00593          	li	a1,158
ffffffffc0203820:	00004517          	auipc	a0,0x4
ffffffffc0203824:	4a850513          	addi	a0,a0,1192 # ffffffffc0207cc8 <etext+0x1566>
ffffffffc0203828:	c23fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020382c <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020382c:	6785                	lui	a5,0x1
ffffffffc020382e:	17fd                	addi	a5,a5,-1 # fff <_binary_obj___user_softint_out_size-0x80e9>
ffffffffc0203830:	963e                	add	a2,a2,a5
    if (!USER_ACCESS(start, end))
ffffffffc0203832:	4785                	li	a5,1
{
ffffffffc0203834:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0203836:	962e                	add	a2,a2,a1
ffffffffc0203838:	787d                	lui	a6,0xfffff
    if (!USER_ACCESS(start, end))
ffffffffc020383a:	07fe                	slli	a5,a5,0x1f
{
ffffffffc020383c:	f822                	sd	s0,48(sp)
ffffffffc020383e:	f426                	sd	s1,40(sp)
ffffffffc0203840:	01067433          	and	s0,a2,a6
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0203844:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end))
ffffffffc0203848:	0785                	addi	a5,a5,1
ffffffffc020384a:	0084b633          	sltu	a2,s1,s0
ffffffffc020384e:	00f437b3          	sltu	a5,s0,a5
ffffffffc0203852:	00163613          	seqz	a2,a2
ffffffffc0203856:	0017b793          	seqz	a5,a5
{
ffffffffc020385a:	fc06                	sd	ra,56(sp)
    if (!USER_ACCESS(start, end))
ffffffffc020385c:	8fd1                	or	a5,a5,a2
ffffffffc020385e:	ebbd                	bnez	a5,ffffffffc02038d4 <mm_map+0xa8>
ffffffffc0203860:	002007b7          	lui	a5,0x200
ffffffffc0203864:	06f4e863          	bltu	s1,a5,ffffffffc02038d4 <mm_map+0xa8>
ffffffffc0203868:	f04a                	sd	s2,32(sp)
ffffffffc020386a:	ec4e                	sd	s3,24(sp)
ffffffffc020386c:	e852                	sd	s4,16(sp)
ffffffffc020386e:	892a                	mv	s2,a0
ffffffffc0203870:	89ba                	mv	s3,a4
ffffffffc0203872:	8a36                	mv	s4,a3
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0203874:	c135                	beqz	a0,ffffffffc02038d8 <mm_map+0xac>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc0203876:	85a6                	mv	a1,s1
ffffffffc0203878:	e55ff0ef          	jal	ffffffffc02036cc <find_vma>
ffffffffc020387c:	c501                	beqz	a0,ffffffffc0203884 <mm_map+0x58>
ffffffffc020387e:	651c                	ld	a5,8(a0)
ffffffffc0203880:	0487e763          	bltu	a5,s0,ffffffffc02038ce <mm_map+0xa2>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203884:	03000513          	li	a0,48
ffffffffc0203888:	c7cfe0ef          	jal	ffffffffc0201d04 <kmalloc>
ffffffffc020388c:	85aa                	mv	a1,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc020388e:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc0203890:	c59d                	beqz	a1,ffffffffc02038be <mm_map+0x92>
        vma->vm_start = vm_start;
ffffffffc0203892:	e584                	sd	s1,8(a1)
        vma->vm_end = vm_end;
ffffffffc0203894:	e980                	sd	s0,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc0203896:	0145ac23          	sw	s4,24(a1)

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc020389a:	854a                	mv	a0,s2
ffffffffc020389c:	e42e                	sd	a1,8(sp)
ffffffffc020389e:	e6fff0ef          	jal	ffffffffc020370c <insert_vma_struct>
    if (vma_store != NULL)
ffffffffc02038a2:	65a2                	ld	a1,8(sp)
ffffffffc02038a4:	00098463          	beqz	s3,ffffffffc02038ac <mm_map+0x80>
    {
        *vma_store = vma;
ffffffffc02038a8:	00b9b023          	sd	a1,0(s3)
ffffffffc02038ac:	7902                	ld	s2,32(sp)
ffffffffc02038ae:	69e2                	ld	s3,24(sp)
ffffffffc02038b0:	6a42                	ld	s4,16(sp)
    }
    ret = 0;
ffffffffc02038b2:	4501                	li	a0,0

out:
    return ret;
}
ffffffffc02038b4:	70e2                	ld	ra,56(sp)
ffffffffc02038b6:	7442                	ld	s0,48(sp)
ffffffffc02038b8:	74a2                	ld	s1,40(sp)
ffffffffc02038ba:	6121                	addi	sp,sp,64
ffffffffc02038bc:	8082                	ret
ffffffffc02038be:	70e2                	ld	ra,56(sp)
ffffffffc02038c0:	7442                	ld	s0,48(sp)
ffffffffc02038c2:	7902                	ld	s2,32(sp)
ffffffffc02038c4:	69e2                	ld	s3,24(sp)
ffffffffc02038c6:	6a42                	ld	s4,16(sp)
ffffffffc02038c8:	74a2                	ld	s1,40(sp)
ffffffffc02038ca:	6121                	addi	sp,sp,64
ffffffffc02038cc:	8082                	ret
ffffffffc02038ce:	7902                	ld	s2,32(sp)
ffffffffc02038d0:	69e2                	ld	s3,24(sp)
ffffffffc02038d2:	6a42                	ld	s4,16(sp)
        return -E_INVAL;
ffffffffc02038d4:	5575                	li	a0,-3
ffffffffc02038d6:	bff9                	j	ffffffffc02038b4 <mm_map+0x88>
    assert(mm != NULL);
ffffffffc02038d8:	00004697          	auipc	a3,0x4
ffffffffc02038dc:	47868693          	addi	a3,a3,1144 # ffffffffc0207d50 <etext+0x15ee>
ffffffffc02038e0:	00003617          	auipc	a2,0x3
ffffffffc02038e4:	63060613          	addi	a2,a2,1584 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02038e8:	0b300593          	li	a1,179
ffffffffc02038ec:	00004517          	auipc	a0,0x4
ffffffffc02038f0:	3dc50513          	addi	a0,a0,988 # ffffffffc0207cc8 <etext+0x1566>
ffffffffc02038f4:	b57fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02038f8 <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc02038f8:	7139                	addi	sp,sp,-64
ffffffffc02038fa:	fc06                	sd	ra,56(sp)
ffffffffc02038fc:	f822                	sd	s0,48(sp)
ffffffffc02038fe:	f426                	sd	s1,40(sp)
ffffffffc0203900:	f04a                	sd	s2,32(sp)
ffffffffc0203902:	ec4e                	sd	s3,24(sp)
ffffffffc0203904:	e852                	sd	s4,16(sp)
ffffffffc0203906:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0203908:	c525                	beqz	a0,ffffffffc0203970 <dup_mmap+0x78>
ffffffffc020390a:	892a                	mv	s2,a0
ffffffffc020390c:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc020390e:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0203910:	c1a5                	beqz	a1,ffffffffc0203970 <dup_mmap+0x78>
    return listelm->prev;
ffffffffc0203912:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc0203914:	04848c63          	beq	s1,s0,ffffffffc020396c <dup_mmap+0x74>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203918:	03000513          	li	a0,48
    {
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc020391c:	fe843a83          	ld	s5,-24(s0)
ffffffffc0203920:	ff043a03          	ld	s4,-16(s0)
ffffffffc0203924:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203928:	bdcfe0ef          	jal	ffffffffc0201d04 <kmalloc>
    if (vma != NULL)
ffffffffc020392c:	c515                	beqz	a0,ffffffffc0203958 <dup_mmap+0x60>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc020392e:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc0203930:	01553423          	sd	s5,8(a0)
ffffffffc0203934:	01453823          	sd	s4,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203938:	01352c23          	sw	s3,24(a0)
        insert_vma_struct(to, nvma);
ffffffffc020393c:	854a                	mv	a0,s2
ffffffffc020393e:	dcfff0ef          	jal	ffffffffc020370c <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc0203942:	ff043683          	ld	a3,-16(s0)
ffffffffc0203946:	fe843603          	ld	a2,-24(s0)
ffffffffc020394a:	6c8c                	ld	a1,24(s1)
ffffffffc020394c:	01893503          	ld	a0,24(s2)
ffffffffc0203950:	4701                	li	a4,0
ffffffffc0203952:	cb9fe0ef          	jal	ffffffffc020260a <copy_range>
ffffffffc0203956:	dd55                	beqz	a0,ffffffffc0203912 <dup_mmap+0x1a>
            return -E_NO_MEM;
ffffffffc0203958:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc020395a:	70e2                	ld	ra,56(sp)
ffffffffc020395c:	7442                	ld	s0,48(sp)
ffffffffc020395e:	74a2                	ld	s1,40(sp)
ffffffffc0203960:	7902                	ld	s2,32(sp)
ffffffffc0203962:	69e2                	ld	s3,24(sp)
ffffffffc0203964:	6a42                	ld	s4,16(sp)
ffffffffc0203966:	6aa2                	ld	s5,8(sp)
ffffffffc0203968:	6121                	addi	sp,sp,64
ffffffffc020396a:	8082                	ret
    return 0;
ffffffffc020396c:	4501                	li	a0,0
ffffffffc020396e:	b7f5                	j	ffffffffc020395a <dup_mmap+0x62>
    assert(to != NULL && from != NULL);
ffffffffc0203970:	00004697          	auipc	a3,0x4
ffffffffc0203974:	3f068693          	addi	a3,a3,1008 # ffffffffc0207d60 <etext+0x15fe>
ffffffffc0203978:	00003617          	auipc	a2,0x3
ffffffffc020397c:	59860613          	addi	a2,a2,1432 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203980:	0cf00593          	li	a1,207
ffffffffc0203984:	00004517          	auipc	a0,0x4
ffffffffc0203988:	34450513          	addi	a0,a0,836 # ffffffffc0207cc8 <etext+0x1566>
ffffffffc020398c:	abffc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0203990 <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc0203990:	1101                	addi	sp,sp,-32
ffffffffc0203992:	ec06                	sd	ra,24(sp)
ffffffffc0203994:	e822                	sd	s0,16(sp)
ffffffffc0203996:	e426                	sd	s1,8(sp)
ffffffffc0203998:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc020399a:	c531                	beqz	a0,ffffffffc02039e6 <exit_mmap+0x56>
ffffffffc020399c:	591c                	lw	a5,48(a0)
ffffffffc020399e:	84aa                	mv	s1,a0
ffffffffc02039a0:	e3b9                	bnez	a5,ffffffffc02039e6 <exit_mmap+0x56>
    return listelm->next;
ffffffffc02039a2:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02039a4:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc02039a8:	02850663          	beq	a0,s0,ffffffffc02039d4 <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02039ac:	ff043603          	ld	a2,-16(s0)
ffffffffc02039b0:	fe843583          	ld	a1,-24(s0)
ffffffffc02039b4:	854a                	mv	a0,s2
ffffffffc02039b6:	86dfe0ef          	jal	ffffffffc0202222 <unmap_range>
ffffffffc02039ba:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc02039bc:	fe8498e3          	bne	s1,s0,ffffffffc02039ac <exit_mmap+0x1c>
ffffffffc02039c0:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc02039c2:	00848c63          	beq	s1,s0,ffffffffc02039da <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02039c6:	ff043603          	ld	a2,-16(s0)
ffffffffc02039ca:	fe843583          	ld	a1,-24(s0)
ffffffffc02039ce:	854a                	mv	a0,s2
ffffffffc02039d0:	987fe0ef          	jal	ffffffffc0202356 <exit_range>
ffffffffc02039d4:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc02039d6:	fe8498e3          	bne	s1,s0,ffffffffc02039c6 <exit_mmap+0x36>
    }
}
ffffffffc02039da:	60e2                	ld	ra,24(sp)
ffffffffc02039dc:	6442                	ld	s0,16(sp)
ffffffffc02039de:	64a2                	ld	s1,8(sp)
ffffffffc02039e0:	6902                	ld	s2,0(sp)
ffffffffc02039e2:	6105                	addi	sp,sp,32
ffffffffc02039e4:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02039e6:	00004697          	auipc	a3,0x4
ffffffffc02039ea:	39a68693          	addi	a3,a3,922 # ffffffffc0207d80 <etext+0x161e>
ffffffffc02039ee:	00003617          	auipc	a2,0x3
ffffffffc02039f2:	52260613          	addi	a2,a2,1314 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02039f6:	0e800593          	li	a1,232
ffffffffc02039fa:	00004517          	auipc	a0,0x4
ffffffffc02039fe:	2ce50513          	addi	a0,a0,718 # ffffffffc0207cc8 <etext+0x1566>
ffffffffc0203a02:	a49fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0203a06 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0203a06:	7179                	addi	sp,sp,-48
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203a08:	05800513          	li	a0,88
{
ffffffffc0203a0c:	f406                	sd	ra,40(sp)
ffffffffc0203a0e:	f022                	sd	s0,32(sp)
ffffffffc0203a10:	ec26                	sd	s1,24(sp)
ffffffffc0203a12:	e84a                	sd	s2,16(sp)
ffffffffc0203a14:	e44e                	sd	s3,8(sp)
ffffffffc0203a16:	e052                	sd	s4,0(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203a18:	aecfe0ef          	jal	ffffffffc0201d04 <kmalloc>
    if (mm != NULL)
ffffffffc0203a1c:	16050f63          	beqz	a0,ffffffffc0203b9a <vmm_init+0x194>
    elm->prev = elm->next = elm;
ffffffffc0203a20:	e508                	sd	a0,8(a0)
ffffffffc0203a22:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203a24:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203a28:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203a2c:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0203a30:	02053423          	sd	zero,40(a0)
ffffffffc0203a34:	02052823          	sw	zero,48(a0)
        sem_init(&(mm->mm_sem), 1);
ffffffffc0203a38:	842a                	mv	s0,a0
ffffffffc0203a3a:	4585                	li	a1,1
ffffffffc0203a3c:	03850513          	addi	a0,a0,56
ffffffffc0203a40:	4db000ef          	jal	ffffffffc020471a <sem_init>
ffffffffc0203a44:	03200493          	li	s1,50
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a48:	03000513          	li	a0,48
ffffffffc0203a4c:	ab8fe0ef          	jal	ffffffffc0201d04 <kmalloc>
    if (vma != NULL)
ffffffffc0203a50:	12050563          	beqz	a0,ffffffffc0203b7a <vmm_init+0x174>
        vma->vm_end = vm_end;
ffffffffc0203a54:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc0203a58:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203a5a:	00052c23          	sw	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc0203a5e:	e91c                	sd	a5,16(a0)
    int i;
    for (i = step1; i >= 1; i--)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203a60:	85aa                	mv	a1,a0
    for (i = step1; i >= 1; i--)
ffffffffc0203a62:	14ed                	addi	s1,s1,-5
        insert_vma_struct(mm, vma);
ffffffffc0203a64:	8522                	mv	a0,s0
ffffffffc0203a66:	ca7ff0ef          	jal	ffffffffc020370c <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0203a6a:	fcf9                	bnez	s1,ffffffffc0203a48 <vmm_init+0x42>
ffffffffc0203a6c:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203a70:	1f900913          	li	s2,505
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a74:	03000513          	li	a0,48
ffffffffc0203a78:	a8cfe0ef          	jal	ffffffffc0201d04 <kmalloc>
    if (vma != NULL)
ffffffffc0203a7c:	12050f63          	beqz	a0,ffffffffc0203bba <vmm_init+0x1b4>
        vma->vm_end = vm_end;
ffffffffc0203a80:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc0203a84:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203a86:	00052c23          	sw	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc0203a8a:	e91c                	sd	a5,16(a0)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203a8c:	85aa                	mv	a1,a0
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203a8e:	0495                	addi	s1,s1,5
        insert_vma_struct(mm, vma);
ffffffffc0203a90:	8522                	mv	a0,s0
ffffffffc0203a92:	c7bff0ef          	jal	ffffffffc020370c <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203a96:	fd249fe3          	bne	s1,s2,ffffffffc0203a74 <vmm_init+0x6e>
    return listelm->next;
ffffffffc0203a9a:	641c                	ld	a5,8(s0)
ffffffffc0203a9c:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0203a9e:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0203aa2:	1ef40c63          	beq	s0,a5,ffffffffc0203c9a <vmm_init+0x294>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203aa6:	fe87b603          	ld	a2,-24(a5) # 1fffe8 <_binary_obj___user_matrix_out_size+0x1f4900>
ffffffffc0203aaa:	ffe70693          	addi	a3,a4,-2
ffffffffc0203aae:	12d61663          	bne	a2,a3,ffffffffc0203bda <vmm_init+0x1d4>
ffffffffc0203ab2:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203ab6:	12e69263          	bne	a3,a4,ffffffffc0203bda <vmm_init+0x1d4>
    for (i = 1; i <= step2; i++)
ffffffffc0203aba:	0715                	addi	a4,a4,5
ffffffffc0203abc:	679c                	ld	a5,8(a5)
ffffffffc0203abe:	feb712e3          	bne	a4,a1,ffffffffc0203aa2 <vmm_init+0x9c>
ffffffffc0203ac2:	491d                	li	s2,7
ffffffffc0203ac4:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203ac6:	85a6                	mv	a1,s1
ffffffffc0203ac8:	8522                	mv	a0,s0
ffffffffc0203aca:	c03ff0ef          	jal	ffffffffc02036cc <find_vma>
ffffffffc0203ace:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0203ad0:	20050563          	beqz	a0,ffffffffc0203cda <vmm_init+0x2d4>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0203ad4:	00148593          	addi	a1,s1,1
ffffffffc0203ad8:	8522                	mv	a0,s0
ffffffffc0203ada:	bf3ff0ef          	jal	ffffffffc02036cc <find_vma>
ffffffffc0203ade:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203ae0:	1c050d63          	beqz	a0,ffffffffc0203cba <vmm_init+0x2b4>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0203ae4:	85ca                	mv	a1,s2
ffffffffc0203ae6:	8522                	mv	a0,s0
ffffffffc0203ae8:	be5ff0ef          	jal	ffffffffc02036cc <find_vma>
        assert(vma3 == NULL);
ffffffffc0203aec:	18051763          	bnez	a0,ffffffffc0203c7a <vmm_init+0x274>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0203af0:	00348593          	addi	a1,s1,3
ffffffffc0203af4:	8522                	mv	a0,s0
ffffffffc0203af6:	bd7ff0ef          	jal	ffffffffc02036cc <find_vma>
        assert(vma4 == NULL);
ffffffffc0203afa:	16051063          	bnez	a0,ffffffffc0203c5a <vmm_init+0x254>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0203afe:	00448593          	addi	a1,s1,4
ffffffffc0203b02:	8522                	mv	a0,s0
ffffffffc0203b04:	bc9ff0ef          	jal	ffffffffc02036cc <find_vma>
        assert(vma5 == NULL);
ffffffffc0203b08:	12051963          	bnez	a0,ffffffffc0203c3a <vmm_init+0x234>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203b0c:	008a3783          	ld	a5,8(s4)
ffffffffc0203b10:	10979563          	bne	a5,s1,ffffffffc0203c1a <vmm_init+0x214>
ffffffffc0203b14:	010a3783          	ld	a5,16(s4)
ffffffffc0203b18:	11279163          	bne	a5,s2,ffffffffc0203c1a <vmm_init+0x214>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203b1c:	0089b783          	ld	a5,8(s3)
ffffffffc0203b20:	0c979d63          	bne	a5,s1,ffffffffc0203bfa <vmm_init+0x1f4>
ffffffffc0203b24:	0109b783          	ld	a5,16(s3)
ffffffffc0203b28:	0d279963          	bne	a5,s2,ffffffffc0203bfa <vmm_init+0x1f4>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203b2c:	0495                	addi	s1,s1,5
ffffffffc0203b2e:	1f900793          	li	a5,505
ffffffffc0203b32:	0915                	addi	s2,s2,5
ffffffffc0203b34:	f8f499e3          	bne	s1,a5,ffffffffc0203ac6 <vmm_init+0xc0>
ffffffffc0203b38:	4491                	li	s1,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0203b3a:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0203b3c:	85a6                	mv	a1,s1
ffffffffc0203b3e:	8522                	mv	a0,s0
ffffffffc0203b40:	b8dff0ef          	jal	ffffffffc02036cc <find_vma>
        if (vma_below_5 != NULL)
ffffffffc0203b44:	1a051b63          	bnez	a0,ffffffffc0203cfa <vmm_init+0x2f4>
    for (i = 4; i >= 0; i--)
ffffffffc0203b48:	14fd                	addi	s1,s1,-1
ffffffffc0203b4a:	ff2499e3          	bne	s1,s2,ffffffffc0203b3c <vmm_init+0x136>
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
ffffffffc0203b4e:	8522                	mv	a0,s0
ffffffffc0203b50:	c8bff0ef          	jal	ffffffffc02037da <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203b54:	00004517          	auipc	a0,0x4
ffffffffc0203b58:	39c50513          	addi	a0,a0,924 # ffffffffc0207ef0 <etext+0x178e>
ffffffffc0203b5c:	e3cfc0ef          	jal	ffffffffc0200198 <cprintf>
}
ffffffffc0203b60:	7402                	ld	s0,32(sp)
ffffffffc0203b62:	70a2                	ld	ra,40(sp)
ffffffffc0203b64:	64e2                	ld	s1,24(sp)
ffffffffc0203b66:	6942                	ld	s2,16(sp)
ffffffffc0203b68:	69a2                	ld	s3,8(sp)
ffffffffc0203b6a:	6a02                	ld	s4,0(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203b6c:	00004517          	auipc	a0,0x4
ffffffffc0203b70:	3a450513          	addi	a0,a0,932 # ffffffffc0207f10 <etext+0x17ae>
}
ffffffffc0203b74:	6145                	addi	sp,sp,48
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203b76:	e22fc06f          	j	ffffffffc0200198 <cprintf>
        assert(vma != NULL);
ffffffffc0203b7a:	00004697          	auipc	a3,0x4
ffffffffc0203b7e:	22668693          	addi	a3,a3,550 # ffffffffc0207da0 <etext+0x163e>
ffffffffc0203b82:	00003617          	auipc	a2,0x3
ffffffffc0203b86:	38e60613          	addi	a2,a2,910 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203b8a:	12c00593          	li	a1,300
ffffffffc0203b8e:	00004517          	auipc	a0,0x4
ffffffffc0203b92:	13a50513          	addi	a0,a0,314 # ffffffffc0207cc8 <etext+0x1566>
ffffffffc0203b96:	8b5fc0ef          	jal	ffffffffc020044a <__panic>
    assert(mm != NULL);
ffffffffc0203b9a:	00004697          	auipc	a3,0x4
ffffffffc0203b9e:	1b668693          	addi	a3,a3,438 # ffffffffc0207d50 <etext+0x15ee>
ffffffffc0203ba2:	00003617          	auipc	a2,0x3
ffffffffc0203ba6:	36e60613          	addi	a2,a2,878 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203baa:	12400593          	li	a1,292
ffffffffc0203bae:	00004517          	auipc	a0,0x4
ffffffffc0203bb2:	11a50513          	addi	a0,a0,282 # ffffffffc0207cc8 <etext+0x1566>
ffffffffc0203bb6:	895fc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma != NULL);
ffffffffc0203bba:	00004697          	auipc	a3,0x4
ffffffffc0203bbe:	1e668693          	addi	a3,a3,486 # ffffffffc0207da0 <etext+0x163e>
ffffffffc0203bc2:	00003617          	auipc	a2,0x3
ffffffffc0203bc6:	34e60613          	addi	a2,a2,846 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203bca:	13300593          	li	a1,307
ffffffffc0203bce:	00004517          	auipc	a0,0x4
ffffffffc0203bd2:	0fa50513          	addi	a0,a0,250 # ffffffffc0207cc8 <etext+0x1566>
ffffffffc0203bd6:	875fc0ef          	jal	ffffffffc020044a <__panic>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203bda:	00004697          	auipc	a3,0x4
ffffffffc0203bde:	1ee68693          	addi	a3,a3,494 # ffffffffc0207dc8 <etext+0x1666>
ffffffffc0203be2:	00003617          	auipc	a2,0x3
ffffffffc0203be6:	32e60613          	addi	a2,a2,814 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203bea:	13d00593          	li	a1,317
ffffffffc0203bee:	00004517          	auipc	a0,0x4
ffffffffc0203bf2:	0da50513          	addi	a0,a0,218 # ffffffffc0207cc8 <etext+0x1566>
ffffffffc0203bf6:	855fc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203bfa:	00004697          	auipc	a3,0x4
ffffffffc0203bfe:	28668693          	addi	a3,a3,646 # ffffffffc0207e80 <etext+0x171e>
ffffffffc0203c02:	00003617          	auipc	a2,0x3
ffffffffc0203c06:	30e60613          	addi	a2,a2,782 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203c0a:	14f00593          	li	a1,335
ffffffffc0203c0e:	00004517          	auipc	a0,0x4
ffffffffc0203c12:	0ba50513          	addi	a0,a0,186 # ffffffffc0207cc8 <etext+0x1566>
ffffffffc0203c16:	835fc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203c1a:	00004697          	auipc	a3,0x4
ffffffffc0203c1e:	23668693          	addi	a3,a3,566 # ffffffffc0207e50 <etext+0x16ee>
ffffffffc0203c22:	00003617          	auipc	a2,0x3
ffffffffc0203c26:	2ee60613          	addi	a2,a2,750 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203c2a:	14e00593          	li	a1,334
ffffffffc0203c2e:	00004517          	auipc	a0,0x4
ffffffffc0203c32:	09a50513          	addi	a0,a0,154 # ffffffffc0207cc8 <etext+0x1566>
ffffffffc0203c36:	815fc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma5 == NULL);
ffffffffc0203c3a:	00004697          	auipc	a3,0x4
ffffffffc0203c3e:	20668693          	addi	a3,a3,518 # ffffffffc0207e40 <etext+0x16de>
ffffffffc0203c42:	00003617          	auipc	a2,0x3
ffffffffc0203c46:	2ce60613          	addi	a2,a2,718 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203c4a:	14c00593          	li	a1,332
ffffffffc0203c4e:	00004517          	auipc	a0,0x4
ffffffffc0203c52:	07a50513          	addi	a0,a0,122 # ffffffffc0207cc8 <etext+0x1566>
ffffffffc0203c56:	ff4fc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma4 == NULL);
ffffffffc0203c5a:	00004697          	auipc	a3,0x4
ffffffffc0203c5e:	1d668693          	addi	a3,a3,470 # ffffffffc0207e30 <etext+0x16ce>
ffffffffc0203c62:	00003617          	auipc	a2,0x3
ffffffffc0203c66:	2ae60613          	addi	a2,a2,686 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203c6a:	14a00593          	li	a1,330
ffffffffc0203c6e:	00004517          	auipc	a0,0x4
ffffffffc0203c72:	05a50513          	addi	a0,a0,90 # ffffffffc0207cc8 <etext+0x1566>
ffffffffc0203c76:	fd4fc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma3 == NULL);
ffffffffc0203c7a:	00004697          	auipc	a3,0x4
ffffffffc0203c7e:	1a668693          	addi	a3,a3,422 # ffffffffc0207e20 <etext+0x16be>
ffffffffc0203c82:	00003617          	auipc	a2,0x3
ffffffffc0203c86:	28e60613          	addi	a2,a2,654 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203c8a:	14800593          	li	a1,328
ffffffffc0203c8e:	00004517          	auipc	a0,0x4
ffffffffc0203c92:	03a50513          	addi	a0,a0,58 # ffffffffc0207cc8 <etext+0x1566>
ffffffffc0203c96:	fb4fc0ef          	jal	ffffffffc020044a <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203c9a:	00004697          	auipc	a3,0x4
ffffffffc0203c9e:	11668693          	addi	a3,a3,278 # ffffffffc0207db0 <etext+0x164e>
ffffffffc0203ca2:	00003617          	auipc	a2,0x3
ffffffffc0203ca6:	26e60613          	addi	a2,a2,622 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203caa:	13b00593          	li	a1,315
ffffffffc0203cae:	00004517          	auipc	a0,0x4
ffffffffc0203cb2:	01a50513          	addi	a0,a0,26 # ffffffffc0207cc8 <etext+0x1566>
ffffffffc0203cb6:	f94fc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma2 != NULL);
ffffffffc0203cba:	00004697          	auipc	a3,0x4
ffffffffc0203cbe:	15668693          	addi	a3,a3,342 # ffffffffc0207e10 <etext+0x16ae>
ffffffffc0203cc2:	00003617          	auipc	a2,0x3
ffffffffc0203cc6:	24e60613          	addi	a2,a2,590 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203cca:	14600593          	li	a1,326
ffffffffc0203cce:	00004517          	auipc	a0,0x4
ffffffffc0203cd2:	ffa50513          	addi	a0,a0,-6 # ffffffffc0207cc8 <etext+0x1566>
ffffffffc0203cd6:	f74fc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma1 != NULL);
ffffffffc0203cda:	00004697          	auipc	a3,0x4
ffffffffc0203cde:	12668693          	addi	a3,a3,294 # ffffffffc0207e00 <etext+0x169e>
ffffffffc0203ce2:	00003617          	auipc	a2,0x3
ffffffffc0203ce6:	22e60613          	addi	a2,a2,558 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203cea:	14400593          	li	a1,324
ffffffffc0203cee:	00004517          	auipc	a0,0x4
ffffffffc0203cf2:	fda50513          	addi	a0,a0,-38 # ffffffffc0207cc8 <etext+0x1566>
ffffffffc0203cf6:	f54fc0ef          	jal	ffffffffc020044a <__panic>
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203cfa:	6914                	ld	a3,16(a0)
ffffffffc0203cfc:	6510                	ld	a2,8(a0)
ffffffffc0203cfe:	0004859b          	sext.w	a1,s1
ffffffffc0203d02:	00004517          	auipc	a0,0x4
ffffffffc0203d06:	1ae50513          	addi	a0,a0,430 # ffffffffc0207eb0 <etext+0x174e>
ffffffffc0203d0a:	c8efc0ef          	jal	ffffffffc0200198 <cprintf>
        assert(vma_below_5 == NULL);
ffffffffc0203d0e:	00004697          	auipc	a3,0x4
ffffffffc0203d12:	1ca68693          	addi	a3,a3,458 # ffffffffc0207ed8 <etext+0x1776>
ffffffffc0203d16:	00003617          	auipc	a2,0x3
ffffffffc0203d1a:	1fa60613          	addi	a2,a2,506 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0203d1e:	15900593          	li	a1,345
ffffffffc0203d22:	00004517          	auipc	a0,0x4
ffffffffc0203d26:	fa650513          	addi	a0,a0,-90 # ffffffffc0207cc8 <etext+0x1566>
ffffffffc0203d2a:	f20fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0203d2e <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0203d2e:	7179                	addi	sp,sp,-48
ffffffffc0203d30:	f022                	sd	s0,32(sp)
ffffffffc0203d32:	f406                	sd	ra,40(sp)
ffffffffc0203d34:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0203d36:	c52d                	beqz	a0,ffffffffc0203da0 <user_mem_check+0x72>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0203d38:	002007b7          	lui	a5,0x200
ffffffffc0203d3c:	04f5ed63          	bltu	a1,a5,ffffffffc0203d96 <user_mem_check+0x68>
ffffffffc0203d40:	ec26                	sd	s1,24(sp)
ffffffffc0203d42:	00c584b3          	add	s1,a1,a2
ffffffffc0203d46:	0695ff63          	bgeu	a1,s1,ffffffffc0203dc4 <user_mem_check+0x96>
ffffffffc0203d4a:	4785                	li	a5,1
ffffffffc0203d4c:	07fe                	slli	a5,a5,0x1f
ffffffffc0203d4e:	0785                	addi	a5,a5,1 # 200001 <_binary_obj___user_matrix_out_size+0x1f4919>
ffffffffc0203d50:	06f4fa63          	bgeu	s1,a5,ffffffffc0203dc4 <user_mem_check+0x96>
ffffffffc0203d54:	e84a                	sd	s2,16(sp)
ffffffffc0203d56:	e44e                	sd	s3,8(sp)
ffffffffc0203d58:	8936                	mv	s2,a3
ffffffffc0203d5a:	89aa                	mv	s3,a0
ffffffffc0203d5c:	a829                	j	ffffffffc0203d76 <user_mem_check+0x48>
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203d5e:	6685                	lui	a3,0x1
ffffffffc0203d60:	9736                	add	a4,a4,a3
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203d62:	0027f693          	andi	a3,a5,2
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203d66:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203d68:	c685                	beqz	a3,ffffffffc0203d90 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203d6a:	c399                	beqz	a5,ffffffffc0203d70 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203d6c:	02e46263          	bltu	s0,a4,ffffffffc0203d90 <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0203d70:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc0203d72:	04947b63          	bgeu	s0,s1,ffffffffc0203dc8 <user_mem_check+0x9a>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc0203d76:	85a2                	mv	a1,s0
ffffffffc0203d78:	854e                	mv	a0,s3
ffffffffc0203d7a:	953ff0ef          	jal	ffffffffc02036cc <find_vma>
ffffffffc0203d7e:	c909                	beqz	a0,ffffffffc0203d90 <user_mem_check+0x62>
ffffffffc0203d80:	6518                	ld	a4,8(a0)
ffffffffc0203d82:	00e46763          	bltu	s0,a4,ffffffffc0203d90 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203d86:	4d1c                	lw	a5,24(a0)
ffffffffc0203d88:	fc091be3          	bnez	s2,ffffffffc0203d5e <user_mem_check+0x30>
ffffffffc0203d8c:	8b85                	andi	a5,a5,1
ffffffffc0203d8e:	f3ed                	bnez	a5,ffffffffc0203d70 <user_mem_check+0x42>
ffffffffc0203d90:	64e2                	ld	s1,24(sp)
ffffffffc0203d92:	6942                	ld	s2,16(sp)
ffffffffc0203d94:	69a2                	ld	s3,8(sp)
            return 0;
ffffffffc0203d96:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0203d98:	70a2                	ld	ra,40(sp)
ffffffffc0203d9a:	7402                	ld	s0,32(sp)
ffffffffc0203d9c:	6145                	addi	sp,sp,48
ffffffffc0203d9e:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203da0:	c02007b7          	lui	a5,0xc0200
ffffffffc0203da4:	fef5eae3          	bltu	a1,a5,ffffffffc0203d98 <user_mem_check+0x6a>
ffffffffc0203da8:	c80007b7          	lui	a5,0xc8000
ffffffffc0203dac:	962e                	add	a2,a2,a1
ffffffffc0203dae:	0785                	addi	a5,a5,1 # ffffffffc8000001 <end+0x7d33c81>
ffffffffc0203db0:	00c5b433          	sltu	s0,a1,a2
ffffffffc0203db4:	00f63633          	sltu	a2,a2,a5
}
ffffffffc0203db8:	70a2                	ld	ra,40(sp)
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203dba:	00867533          	and	a0,a2,s0
}
ffffffffc0203dbe:	7402                	ld	s0,32(sp)
ffffffffc0203dc0:	6145                	addi	sp,sp,48
ffffffffc0203dc2:	8082                	ret
ffffffffc0203dc4:	64e2                	ld	s1,24(sp)
ffffffffc0203dc6:	bfc1                	j	ffffffffc0203d96 <user_mem_check+0x68>
ffffffffc0203dc8:	64e2                	ld	s1,24(sp)
ffffffffc0203dca:	6942                	ld	s2,16(sp)
ffffffffc0203dcc:	69a2                	ld	s3,8(sp)
        return 1;
ffffffffc0203dce:	4505                	li	a0,1
ffffffffc0203dd0:	b7e1                	j	ffffffffc0203d98 <user_mem_check+0x6a>

ffffffffc0203dd2 <do_pgfault>:

volatile unsigned int pgfault_num = 0;
struct mm_struct *check_mm_struct = NULL;

int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203dd2:	7179                	addi	sp,sp,-48
ffffffffc0203dd4:	f022                	sd	s0,32(sp)
ffffffffc0203dd6:	842e                	mv	s0,a1
    int ret = -E_INVAL;
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203dd8:	85b2                	mv	a1,a2
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203dda:	ec26                	sd	s1,24(sp)
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203ddc:	e432                	sd	a2,8(sp)
int do_pgfault(struct mm_struct *mm, uint_t error_code, uintptr_t addr) {
ffffffffc0203dde:	f406                	sd	ra,40(sp)
ffffffffc0203de0:	84aa                	mv	s1,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203de2:	8ebff0ef          	jal	ffffffffc02036cc <find_vma>

    pgfault_num++;
ffffffffc0203de6:	000c8797          	auipc	a5,0xc8
ffffffffc0203dea:	56a7a783          	lw	a5,1386(a5) # ffffffffc02cc350 <pgfault_num>
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203dee:	6622                	ld	a2,8(sp)
    pgfault_num++;
ffffffffc0203df0:	2785                	addiw	a5,a5,1
ffffffffc0203df2:	000c8717          	auipc	a4,0xc8
ffffffffc0203df6:	54f72f23          	sw	a5,1374(a4) # ffffffffc02cc350 <pgfault_num>
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203dfa:	c94d                	beqz	a0,ffffffffc0203eac <do_pgfault+0xda>
ffffffffc0203dfc:	651c                	ld	a5,8(a0)
ffffffffc0203dfe:	0af66763          	bltu	a2,a5,ffffffffc0203eac <do_pgfault+0xda>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
        goto failed;
    }
    switch (error_code) {
ffffffffc0203e02:	47b5                	li	a5,13
ffffffffc0203e04:	08f40963          	beq	s0,a5,ffffffffc0203e96 <do_pgfault+0xc4>
ffffffffc0203e08:	47bd                	li	a5,15
ffffffffc0203e0a:	02f40663          	beq	s0,a5,ffffffffc0203e36 <do_pgfault+0x64>
ffffffffc0203e0e:	47b1                	li	a5,12
ffffffffc0203e10:	06f41763          	bne	s0,a5,ffffffffc0203e7e <do_pgfault+0xac>
    case CAUSE_FETCH_PAGE_FAULT:
        if (!(vma->vm_flags & VM_EXEC)) {
ffffffffc0203e14:	4d18                	lw	a4,24(a0)
ffffffffc0203e16:	00477793          	andi	a5,a4,4
ffffffffc0203e1a:	0e078363          	beqz	a5,ffffffffc0203f00 <do_pgfault+0x12e>
        cprintf("do_pgfault: error: unknown error code\n");
        goto failed;
    }

    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203e1e:	00277693          	andi	a3,a4,2
ffffffffc0203e22:	4479                	li	s0,30
ffffffffc0203e24:	e695                	bnez	a3,ffffffffc0203e50 <do_pgfault+0x7e>
        perm |= (PTE_R | PTE_W);
    }
    if (vma->vm_flags & VM_READ) {
ffffffffc0203e26:	8b05                	andi	a4,a4,1
ffffffffc0203e28:	0017171b          	slliw	a4,a4,0x1
ffffffffc0203e2c:	01076413          	ori	s0,a4,16
        perm |= PTE_R;
    }
    if (vma->vm_flags & VM_EXEC) {
        perm |= PTE_X;
ffffffffc0203e30:	00846413          	ori	s0,s0,8
ffffffffc0203e34:	a831                	j	ffffffffc0203e50 <do_pgfault+0x7e>
        if (!(vma->vm_flags & VM_WRITE)) {
ffffffffc0203e36:	4d1c                	lw	a5,24(a0)
ffffffffc0203e38:	0027f713          	andi	a4,a5,2
ffffffffc0203e3c:	cb71                	beqz	a4,ffffffffc0203f10 <do_pgfault+0x13e>
    if (vma->vm_flags & VM_EXEC) {
ffffffffc0203e3e:	0047f713          	andi	a4,a5,4
        perm |= (PTE_R | PTE_W);
ffffffffc0203e42:	46d9                	li	a3,22
    if (vma->vm_flags & VM_READ) {
ffffffffc0203e44:	8b85                	andi	a5,a5,1
ffffffffc0203e46:	0017979b          	slliw	a5,a5,0x1
ffffffffc0203e4a:	00d7e433          	or	s0,a5,a3
    if (vma->vm_flags & VM_EXEC) {
ffffffffc0203e4e:	f36d                	bnez	a4,ffffffffc0203e30 <do_pgfault+0x5e>
    addr = ROUNDDOWN(addr, PGSIZE);

    ret = -E_NO_MEM;
    pte_t *ptep = NULL;
    
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203e50:	6c88                	ld	a0,24(s1)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203e52:	75fd                	lui	a1,0xfffff
ffffffffc0203e54:	8df1                	and	a1,a1,a2
    if ((ptep = get_pte(mm->pgdir, addr, 1)) == NULL) {
ffffffffc0203e56:	4605                	li	a2,1
ffffffffc0203e58:	e42e                	sd	a1,8(sp)
ffffffffc0203e5a:	916fe0ef          	jal	ffffffffc0201f70 <get_pte>
ffffffffc0203e5e:	65a2                	ld	a1,8(sp)
ffffffffc0203e60:	c925                	beqz	a0,ffffffffc0203ed0 <do_pgfault+0xfe>
        cprintf("get_pte in do_pgfault failed\n");
        goto failed;
    }
    
    if (*ptep == 0) {
ffffffffc0203e62:	6118                	ld	a4,0(a0)
ffffffffc0203e64:	ef29                	bnez	a4,ffffffffc0203ebe <do_pgfault+0xec>
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203e66:	6c88                	ld	a0,24(s1)
ffffffffc0203e68:	8622                	mv	a2,s0
ffffffffc0203e6a:	f42ff0ef          	jal	ffffffffc02035ac <pgdir_alloc_page>
ffffffffc0203e6e:	87aa                	mv	a5,a0
        }
    } else {
        cprintf("do_pgfault: ptep %x exists, but swap not supported\n", *ptep);
        goto failed;
    }
   ret = 0;
ffffffffc0203e70:	4501                	li	a0,0
        if (pgdir_alloc_page(mm->pgdir, addr, perm) == NULL) {
ffffffffc0203e72:	c7bd                	beqz	a5,ffffffffc0203ee0 <do_pgfault+0x10e>
failed:
    return ret;
}
ffffffffc0203e74:	70a2                	ld	ra,40(sp)
ffffffffc0203e76:	7402                	ld	s0,32(sp)
ffffffffc0203e78:	64e2                	ld	s1,24(sp)
ffffffffc0203e7a:	6145                	addi	sp,sp,48
ffffffffc0203e7c:	8082                	ret
        cprintf("do_pgfault: error: unknown error code\n");
ffffffffc0203e7e:	00004517          	auipc	a0,0x4
ffffffffc0203e82:	15250513          	addi	a0,a0,338 # ffffffffc0207fd0 <etext+0x186e>
ffffffffc0203e86:	b12fc0ef          	jal	ffffffffc0200198 <cprintf>
    int ret = -E_INVAL;
ffffffffc0203e8a:	5575                	li	a0,-3
}
ffffffffc0203e8c:	70a2                	ld	ra,40(sp)
ffffffffc0203e8e:	7402                	ld	s0,32(sp)
ffffffffc0203e90:	64e2                	ld	s1,24(sp)
ffffffffc0203e92:	6145                	addi	sp,sp,48
ffffffffc0203e94:	8082                	ret
        if (!(vma->vm_flags & VM_READ)) {
ffffffffc0203e96:	4d18                	lw	a4,24(a0)
ffffffffc0203e98:	00177793          	andi	a5,a4,1
ffffffffc0203e9c:	cbb1                	beqz	a5,ffffffffc0203ef0 <do_pgfault+0x11e>
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203e9e:	00277593          	andi	a1,a4,2
        perm |= (PTE_R | PTE_W);
ffffffffc0203ea2:	46d9                	li	a3,22
    if (vma->vm_flags & VM_EXEC) {
ffffffffc0203ea4:	8b11                	andi	a4,a4,4
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203ea6:	f1c5                	bnez	a1,ffffffffc0203e46 <do_pgfault+0x74>
    uint32_t perm = PTE_U;
ffffffffc0203ea8:	46c1                	li	a3,16
ffffffffc0203eaa:	bf71                	j	ffffffffc0203e46 <do_pgfault+0x74>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203eac:	85b2                	mv	a1,a2
ffffffffc0203eae:	00004517          	auipc	a0,0x4
ffffffffc0203eb2:	07a50513          	addi	a0,a0,122 # ffffffffc0207f28 <etext+0x17c6>
ffffffffc0203eb6:	ae2fc0ef          	jal	ffffffffc0200198 <cprintf>
    int ret = -E_INVAL;
ffffffffc0203eba:	5575                	li	a0,-3
ffffffffc0203ebc:	bfc1                	j	ffffffffc0203e8c <do_pgfault+0xba>
        cprintf("do_pgfault: ptep %x exists, but swap not supported\n", *ptep);
ffffffffc0203ebe:	85ba                	mv	a1,a4
ffffffffc0203ec0:	00004517          	auipc	a0,0x4
ffffffffc0203ec4:	18050513          	addi	a0,a0,384 # ffffffffc0208040 <etext+0x18de>
ffffffffc0203ec8:	ad0fc0ef          	jal	ffffffffc0200198 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203ecc:	5571                	li	a0,-4
ffffffffc0203ece:	b75d                	j	ffffffffc0203e74 <do_pgfault+0xa2>
        cprintf("get_pte in do_pgfault failed\n");
ffffffffc0203ed0:	00004517          	auipc	a0,0x4
ffffffffc0203ed4:	12850513          	addi	a0,a0,296 # ffffffffc0207ff8 <etext+0x1896>
ffffffffc0203ed8:	ac0fc0ef          	jal	ffffffffc0200198 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203edc:	5571                	li	a0,-4
ffffffffc0203ede:	bf59                	j	ffffffffc0203e74 <do_pgfault+0xa2>
            cprintf("pgdir_alloc_page in do_pgfault failed\n");
ffffffffc0203ee0:	00004517          	auipc	a0,0x4
ffffffffc0203ee4:	13850513          	addi	a0,a0,312 # ffffffffc0208018 <etext+0x18b6>
ffffffffc0203ee8:	ab0fc0ef          	jal	ffffffffc0200198 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203eec:	5571                	li	a0,-4
ffffffffc0203eee:	b759                	j	ffffffffc0203e74 <do_pgfault+0xa2>
            cprintf("do_pgfault: error: not readable\n");
ffffffffc0203ef0:	00004517          	auipc	a0,0x4
ffffffffc0203ef4:	09050513          	addi	a0,a0,144 # ffffffffc0207f80 <etext+0x181e>
ffffffffc0203ef8:	aa0fc0ef          	jal	ffffffffc0200198 <cprintf>
    int ret = -E_INVAL;
ffffffffc0203efc:	5575                	li	a0,-3
ffffffffc0203efe:	b779                	j	ffffffffc0203e8c <do_pgfault+0xba>
            cprintf("do_pgfault: error: not executable\n");
ffffffffc0203f00:	00004517          	auipc	a0,0x4
ffffffffc0203f04:	05850513          	addi	a0,a0,88 # ffffffffc0207f58 <etext+0x17f6>
ffffffffc0203f08:	a90fc0ef          	jal	ffffffffc0200198 <cprintf>
    int ret = -E_INVAL;
ffffffffc0203f0c:	5575                	li	a0,-3
ffffffffc0203f0e:	bfbd                	j	ffffffffc0203e8c <do_pgfault+0xba>
            cprintf("do_pgfault: error: not writable\n");
ffffffffc0203f10:	00004517          	auipc	a0,0x4
ffffffffc0203f14:	09850513          	addi	a0,a0,152 # ffffffffc0207fa8 <etext+0x1846>
ffffffffc0203f18:	a80fc0ef          	jal	ffffffffc0200198 <cprintf>
    int ret = -E_INVAL;
ffffffffc0203f1c:	5575                	li	a0,-3
ffffffffc0203f1e:	b7bd                	j	ffffffffc0203e8c <do_pgfault+0xba>

ffffffffc0203f20 <phi_test_sema>:

struct proc_struct *philosopher_proc_sema[N];

void phi_test_sema(int i) /* i：哲学家号码从0到N-1 */
{ 
    if(state_sema[i]==HUNGRY&&state_sema[LEFT]!=EATING
ffffffffc0203f20:	00251793          	slli	a5,a0,0x2
ffffffffc0203f24:	000c4617          	auipc	a2,0xc4
ffffffffc0203f28:	37460613          	addi	a2,a2,884 # ffffffffc02c8298 <state_sema>
ffffffffc0203f2c:	97b2                	add	a5,a5,a2
ffffffffc0203f2e:	4394                	lw	a3,0(a5)
ffffffffc0203f30:	4705                	li	a4,1
ffffffffc0203f32:	00e68363          	beq	a3,a4,ffffffffc0203f38 <phi_test_sema+0x18>
            &&state_sema[RIGHT]!=EATING)
    {
        state_sema[i]=EATING;
        up(&s[i]);
    }
}
ffffffffc0203f36:	8082                	ret
    if(state_sema[i]==HUNGRY&&state_sema[LEFT]!=EATING
ffffffffc0203f38:	666666b7          	lui	a3,0x66666
ffffffffc0203f3c:	0045071b          	addiw	a4,a0,4
ffffffffc0203f40:	66768693          	addi	a3,a3,1639 # 66666667 <_binary_obj___user_matrix_out_size+0x6665af7f>
ffffffffc0203f44:	02d705b3          	mul	a1,a4,a3
ffffffffc0203f48:	41f7581b          	sraiw	a6,a4,0x1f
ffffffffc0203f4c:	4889                	li	a7,2
ffffffffc0203f4e:	9585                	srai	a1,a1,0x21
ffffffffc0203f50:	410585bb          	subw	a1,a1,a6
ffffffffc0203f54:	0025981b          	slliw	a6,a1,0x2
ffffffffc0203f58:	00b805bb          	addw	a1,a6,a1
ffffffffc0203f5c:	9f0d                	subw	a4,a4,a1
ffffffffc0203f5e:	070a                	slli	a4,a4,0x2
ffffffffc0203f60:	9732                	add	a4,a4,a2
ffffffffc0203f62:	4318                	lw	a4,0(a4)
ffffffffc0203f64:	fd1709e3          	beq	a4,a7,ffffffffc0203f36 <phi_test_sema+0x16>
            &&state_sema[RIGHT]!=EATING)
ffffffffc0203f68:	0015071b          	addiw	a4,a0,1
ffffffffc0203f6c:	02d706b3          	mul	a3,a4,a3
ffffffffc0203f70:	41f7559b          	sraiw	a1,a4,0x1f
ffffffffc0203f74:	9685                	srai	a3,a3,0x21
ffffffffc0203f76:	9e8d                	subw	a3,a3,a1
ffffffffc0203f78:	0026959b          	slliw	a1,a3,0x2
ffffffffc0203f7c:	9ead                	addw	a3,a3,a1
ffffffffc0203f7e:	9f15                	subw	a4,a4,a3
ffffffffc0203f80:	070a                	slli	a4,a4,0x2
ffffffffc0203f82:	963a                	add	a2,a2,a4
ffffffffc0203f84:	4218                	lw	a4,0(a2)
ffffffffc0203f86:	fb1708e3          	beq	a4,a7,ffffffffc0203f36 <phi_test_sema+0x16>
        up(&s[i]);
ffffffffc0203f8a:	00151713          	slli	a4,a0,0x1
ffffffffc0203f8e:	972a                	add	a4,a4,a0
ffffffffc0203f90:	070e                	slli	a4,a4,0x3
ffffffffc0203f92:	000c4517          	auipc	a0,0xc4
ffffffffc0203f96:	27650513          	addi	a0,a0,630 # ffffffffc02c8208 <s>
ffffffffc0203f9a:	953a                	add	a0,a0,a4
        state_sema[i]=EATING;
ffffffffc0203f9c:	0117a023          	sw	a7,0(a5)
        up(&s[i]);
ffffffffc0203fa0:	7800006f          	j	ffffffffc0204720 <up>

ffffffffc0203fa4 <philosopher_using_semaphore>:
        phi_test_sema(RIGHT); /* 看一下右邻居现在是否能进餐 */
        up(&mutex); /* 离开临界区 */
}

int philosopher_using_semaphore(void * arg) /* i：哲学家号码，从0到N-1 */
{
ffffffffc0203fa4:	715d                	addi	sp,sp,-80
ffffffffc0203fa6:	e0a2                	sd	s0,64(sp)
    int i, iter=0;
    i=(int)(long)arg;
ffffffffc0203fa8:	0005041b          	sext.w	s0,a0
    cprintf("I am No.%d philosopher_sema\n",i);
ffffffffc0203fac:	85a2                	mv	a1,s0
ffffffffc0203fae:	00004517          	auipc	a0,0x4
ffffffffc0203fb2:	0ca50513          	addi	a0,a0,202 # ffffffffc0208078 <etext+0x1916>
{
ffffffffc0203fb6:	fc26                	sd	s1,56(sp)
ffffffffc0203fb8:	f84a                	sd	s2,48(sp)
ffffffffc0203fba:	f44e                	sd	s3,40(sp)
ffffffffc0203fbc:	f052                	sd	s4,32(sp)
ffffffffc0203fbe:	ec56                	sd	s5,24(sp)
ffffffffc0203fc0:	e85a                	sd	s6,16(sp)
ffffffffc0203fc2:	e45e                	sd	s7,8(sp)
ffffffffc0203fc4:	e486                	sd	ra,72(sp)
    cprintf("I am No.%d philosopher_sema\n",i);
ffffffffc0203fc6:	9d2fc0ef          	jal	ffffffffc0200198 <cprintf>
        phi_test_sema(LEFT); /* 看一下左邻居现在是否能进餐 */
ffffffffc0203fca:	666667b7          	lui	a5,0x66666
ffffffffc0203fce:	00440a9b          	addiw	s5,s0,4
ffffffffc0203fd2:	66778793          	addi	a5,a5,1639 # 66666667 <_binary_obj___user_matrix_out_size+0x6665af7f>
ffffffffc0203fd6:	02fa8733          	mul	a4,s5,a5
        phi_test_sema(RIGHT); /* 看一下右邻居现在是否能进餐 */
ffffffffc0203fda:	00140a1b          	addiw	s4,s0,1
        phi_test_sema(LEFT); /* 看一下左邻居现在是否能进餐 */
ffffffffc0203fde:	41fad69b          	sraiw	a3,s5,0x1f
        phi_test_sema(RIGHT); /* 看一下右邻居现在是否能进餐 */
ffffffffc0203fe2:	41fa561b          	sraiw	a2,s4,0x1f
        down(&s[i]); /* 如果得不到叉子就阻塞 */
ffffffffc0203fe6:	00141993          	slli	s3,s0,0x1
ffffffffc0203fea:	99a2                	add	s3,s3,s0
ffffffffc0203fec:	098e                	slli	s3,s3,0x3
ffffffffc0203fee:	000c4517          	auipc	a0,0xc4
ffffffffc0203ff2:	21a50513          	addi	a0,a0,538 # ffffffffc02c8208 <s>
ffffffffc0203ff6:	00241593          	slli	a1,s0,0x2
ffffffffc0203ffa:	000c4917          	auipc	s2,0xc4
ffffffffc0203ffe:	29e90913          	addi	s2,s2,670 # ffffffffc02c8298 <state_sema>
        phi_test_sema(RIGHT); /* 看一下右邻居现在是否能进餐 */
ffffffffc0204002:	02fa07b3          	mul	a5,s4,a5
        phi_test_sema(LEFT); /* 看一下左邻居现在是否能进餐 */
ffffffffc0204006:	9705                	srai	a4,a4,0x21
ffffffffc0204008:	9f15                	subw	a4,a4,a3
ffffffffc020400a:	0027169b          	slliw	a3,a4,0x2
ffffffffc020400e:	9f35                	addw	a4,a4,a3
ffffffffc0204010:	40ea8abb          	subw	s5,s5,a4
    while(iter++<TIMES)
ffffffffc0204014:	4485                	li	s1,1
        down(&s[i]); /* 如果得不到叉子就阻塞 */
ffffffffc0204016:	99aa                	add	s3,s3,a0
        state_sema[i]=HUNGRY; /* 记录下哲学家i饥饿的事实 */
ffffffffc0204018:	992e                	add	s2,s2,a1
ffffffffc020401a:	8ba6                	mv	s7,s1
        phi_test_sema(RIGHT); /* 看一下右邻居现在是否能进餐 */
ffffffffc020401c:	9785                	srai	a5,a5,0x21
ffffffffc020401e:	9f91                	subw	a5,a5,a2
ffffffffc0204020:	0027971b          	slliw	a4,a5,0x2
ffffffffc0204024:	9fb9                	addw	a5,a5,a4
    while(iter++<TIMES)
ffffffffc0204026:	4b15                	li	s6,5
        phi_test_sema(RIGHT); /* 看一下右邻居现在是否能进餐 */
ffffffffc0204028:	40fa0a3b          	subw	s4,s4,a5
    { /* 无限循环 */
        cprintf("Iter %d, No.%d philosopher_sema is thinking\n",iter,i); /* 哲学家正在思考 */
ffffffffc020402c:	85a6                	mv	a1,s1
ffffffffc020402e:	8622                	mv	a2,s0
ffffffffc0204030:	00004517          	auipc	a0,0x4
ffffffffc0204034:	06850513          	addi	a0,a0,104 # ffffffffc0208098 <etext+0x1936>
ffffffffc0204038:	960fc0ef          	jal	ffffffffc0200198 <cprintf>
        do_sleep(SLEEP_TIME);
ffffffffc020403c:	4529                	li	a0,10
ffffffffc020403e:	309010ef          	jal	ffffffffc0205b46 <do_sleep>
        down(&mutex); /* 进入临界区 */
ffffffffc0204042:	000c4517          	auipc	a0,0xc4
ffffffffc0204046:	23e50513          	addi	a0,a0,574 # ffffffffc02c8280 <mutex>
ffffffffc020404a:	6da000ef          	jal	ffffffffc0204724 <down>
        phi_test_sema(i); /* 试图得到两只叉子 */
ffffffffc020404e:	8522                	mv	a0,s0
        state_sema[i]=HUNGRY; /* 记录下哲学家i饥饿的事实 */
ffffffffc0204050:	01792023          	sw	s7,0(s2)
        phi_test_sema(i); /* 试图得到两只叉子 */
ffffffffc0204054:	ecdff0ef          	jal	ffffffffc0203f20 <phi_test_sema>
        up(&mutex); /* 离开临界区 */
ffffffffc0204058:	000c4517          	auipc	a0,0xc4
ffffffffc020405c:	22850513          	addi	a0,a0,552 # ffffffffc02c8280 <mutex>
ffffffffc0204060:	6c0000ef          	jal	ffffffffc0204720 <up>
        down(&s[i]); /* 如果得不到叉子就阻塞 */
ffffffffc0204064:	854e                	mv	a0,s3
ffffffffc0204066:	6be000ef          	jal	ffffffffc0204724 <down>
        phi_take_forks_sema(i); 
        /* 需要两只叉子，或者阻塞 */
        cprintf("Iter %d, No.%d philosopher_sema is eating\n",iter,i); /* 进餐 */
ffffffffc020406a:	85a6                	mv	a1,s1
ffffffffc020406c:	8622                	mv	a2,s0
ffffffffc020406e:	00004517          	auipc	a0,0x4
ffffffffc0204072:	05a50513          	addi	a0,a0,90 # ffffffffc02080c8 <etext+0x1966>
ffffffffc0204076:	922fc0ef          	jal	ffffffffc0200198 <cprintf>
        do_sleep(SLEEP_TIME);
ffffffffc020407a:	4529                	li	a0,10
ffffffffc020407c:	2cb010ef          	jal	ffffffffc0205b46 <do_sleep>
        down(&mutex); /* 进入临界区 */
ffffffffc0204080:	000c4517          	auipc	a0,0xc4
ffffffffc0204084:	20050513          	addi	a0,a0,512 # ffffffffc02c8280 <mutex>
ffffffffc0204088:	69c000ef          	jal	ffffffffc0204724 <down>
        phi_test_sema(LEFT); /* 看一下左邻居现在是否能进餐 */
ffffffffc020408c:	8556                	mv	a0,s5
        state_sema[i]=THINKING; /* 哲学家进餐结束 */
ffffffffc020408e:	00092023          	sw	zero,0(s2)
        phi_test_sema(LEFT); /* 看一下左邻居现在是否能进餐 */
ffffffffc0204092:	e8fff0ef          	jal	ffffffffc0203f20 <phi_test_sema>
        phi_test_sema(RIGHT); /* 看一下右邻居现在是否能进餐 */
ffffffffc0204096:	8552                	mv	a0,s4
ffffffffc0204098:	e89ff0ef          	jal	ffffffffc0203f20 <phi_test_sema>
        up(&mutex); /* 离开临界区 */
ffffffffc020409c:	000c4517          	auipc	a0,0xc4
ffffffffc02040a0:	1e450513          	addi	a0,a0,484 # ffffffffc02c8280 <mutex>
    while(iter++<TIMES)
ffffffffc02040a4:	2485                	addiw	s1,s1,1
        up(&mutex); /* 离开临界区 */
ffffffffc02040a6:	67a000ef          	jal	ffffffffc0204720 <up>
    while(iter++<TIMES)
ffffffffc02040aa:	f96491e3          	bne	s1,s6,ffffffffc020402c <philosopher_using_semaphore+0x88>
        phi_put_forks_sema(i); 
        /* 把两把叉子同时放回桌子 */
    }
    cprintf("No.%d philosopher_sema quit\n",i);
ffffffffc02040ae:	85a2                	mv	a1,s0
ffffffffc02040b0:	00004517          	auipc	a0,0x4
ffffffffc02040b4:	04850513          	addi	a0,a0,72 # ffffffffc02080f8 <etext+0x1996>
ffffffffc02040b8:	8e0fc0ef          	jal	ffffffffc0200198 <cprintf>
    return 0;    
}
ffffffffc02040bc:	60a6                	ld	ra,72(sp)
ffffffffc02040be:	6406                	ld	s0,64(sp)
ffffffffc02040c0:	74e2                	ld	s1,56(sp)
ffffffffc02040c2:	7942                	ld	s2,48(sp)
ffffffffc02040c4:	79a2                	ld	s3,40(sp)
ffffffffc02040c6:	7a02                	ld	s4,32(sp)
ffffffffc02040c8:	6ae2                	ld	s5,24(sp)
ffffffffc02040ca:	6b42                	ld	s6,16(sp)
ffffffffc02040cc:	6ba2                	ld	s7,8(sp)
ffffffffc02040ce:	4501                	li	a0,0
ffffffffc02040d0:	6161                	addi	sp,sp,80
ffffffffc02040d2:	8082                	ret

ffffffffc02040d4 <phi_test_condvar>:
struct proc_struct *philosopher_proc_condvar[N]; // N philosopher
int state_condvar[N];                            // the philosopher's state: EATING, HUNGARY, THINKING  
monitor_t mt, *mtp=&mt;                          // monitor

void phi_test_condvar (int i) { 
    if(state_condvar[i]==HUNGRY&&state_condvar[LEFT]!=EATING
ffffffffc02040d4:	00251613          	slli	a2,a0,0x2
ffffffffc02040d8:	000c4697          	auipc	a3,0xc4
ffffffffc02040dc:	0c868693          	addi	a3,a3,200 # ffffffffc02c81a0 <state_condvar>
ffffffffc02040e0:	00c68833          	add	a6,a3,a2
ffffffffc02040e4:	00082703          	lw	a4,0(a6) # fffffffffffff000 <end+0x3fd32c80>
ffffffffc02040e8:	4785                	li	a5,1
ffffffffc02040ea:	00f70363          	beq	a4,a5,ffffffffc02040f0 <phi_test_condvar+0x1c>
ffffffffc02040ee:	8082                	ret
ffffffffc02040f0:	66666737          	lui	a4,0x66666
ffffffffc02040f4:	0045079b          	addiw	a5,a0,4
ffffffffc02040f8:	66770713          	addi	a4,a4,1639 # 66666667 <_binary_obj___user_matrix_out_size+0x6665af7f>
ffffffffc02040fc:	02e785b3          	mul	a1,a5,a4
ffffffffc0204100:	41f7d89b          	sraiw	a7,a5,0x1f
ffffffffc0204104:	4309                	li	t1,2
ffffffffc0204106:	9585                	srai	a1,a1,0x21
ffffffffc0204108:	411585bb          	subw	a1,a1,a7
ffffffffc020410c:	0025989b          	slliw	a7,a1,0x2
ffffffffc0204110:	00b885bb          	addw	a1,a7,a1
ffffffffc0204114:	9f8d                	subw	a5,a5,a1
ffffffffc0204116:	078a                	slli	a5,a5,0x2
ffffffffc0204118:	97b6                	add	a5,a5,a3
ffffffffc020411a:	439c                	lw	a5,0(a5)
ffffffffc020411c:	fc6789e3          	beq	a5,t1,ffffffffc02040ee <phi_test_condvar+0x1a>
            &&state_condvar[RIGHT]!=EATING) {
ffffffffc0204120:	0015079b          	addiw	a5,a0,1
ffffffffc0204124:	02e78733          	mul	a4,a5,a4
ffffffffc0204128:	41f7d59b          	sraiw	a1,a5,0x1f
ffffffffc020412c:	9705                	srai	a4,a4,0x21
ffffffffc020412e:	9f0d                	subw	a4,a4,a1
ffffffffc0204130:	0027159b          	slliw	a1,a4,0x2
ffffffffc0204134:	9f2d                	addw	a4,a4,a1
ffffffffc0204136:	9f99                	subw	a5,a5,a4
ffffffffc0204138:	078a                	slli	a5,a5,0x2
ffffffffc020413a:	96be                	add	a3,a3,a5
ffffffffc020413c:	429c                	lw	a5,0(a3)
ffffffffc020413e:	fa6788e3          	beq	a5,t1,ffffffffc02040ee <phi_test_condvar+0x1a>
void phi_test_condvar (int i) { 
ffffffffc0204142:	7179                	addi	sp,sp,-48
ffffffffc0204144:	85aa                	mv	a1,a0
        cprintf("phi_test_condvar: state_condvar[%d] will eating\n",i);
ffffffffc0204146:	e42a                	sd	a0,8(sp)
ffffffffc0204148:	00004517          	auipc	a0,0x4
ffffffffc020414c:	fd050513          	addi	a0,a0,-48 # ffffffffc0208118 <etext+0x19b6>
void phi_test_condvar (int i) { 
ffffffffc0204150:	f406                	sd	ra,40(sp)
        cprintf("phi_test_condvar: state_condvar[%d] will eating\n",i);
ffffffffc0204152:	e832                	sd	a2,16(sp)
ffffffffc0204154:	ec42                	sd	a6,24(sp)
ffffffffc0204156:	842fc0ef          	jal	ffffffffc0200198 <cprintf>
        state_condvar[i] = EATING ;
        cprintf("phi_test_condvar: signal self_cv[%d] \n",i);
ffffffffc020415a:	65a2                	ld	a1,8(sp)
        state_condvar[i] = EATING ;
ffffffffc020415c:	6862                	ld	a6,24(sp)
ffffffffc020415e:	4309                	li	t1,2
        cprintf("phi_test_condvar: signal self_cv[%d] \n",i);
ffffffffc0204160:	00004517          	auipc	a0,0x4
ffffffffc0204164:	ff050513          	addi	a0,a0,-16 # ffffffffc0208150 <etext+0x19ee>
        state_condvar[i] = EATING ;
ffffffffc0204168:	00682023          	sw	t1,0(a6)
        cprintf("phi_test_condvar: signal self_cv[%d] \n",i);
ffffffffc020416c:	82cfc0ef          	jal	ffffffffc0200198 <cprintf>
        cond_signal(&mtp->cv[i]) ;
ffffffffc0204170:	000c4797          	auipc	a5,0xc4
ffffffffc0204174:	bc87b783          	ld	a5,-1080(a5) # ffffffffc02c7d38 <mtp>
ffffffffc0204178:	65a2                	ld	a1,8(sp)
ffffffffc020417a:	6642                	ld	a2,16(sp)
ffffffffc020417c:	7f88                	ld	a0,56(a5)
    }
}
ffffffffc020417e:	70a2                	ld	ra,40(sp)
        cond_signal(&mtp->cv[i]) ;
ffffffffc0204180:	962e                	add	a2,a2,a1
ffffffffc0204182:	060e                	slli	a2,a2,0x3
ffffffffc0204184:	9532                	add	a0,a0,a2
}
ffffffffc0204186:	6145                	addi	sp,sp,48
        cond_signal(&mtp->cv[i]) ;
ffffffffc0204188:	a66d                	j	ffffffffc0204532 <cond_signal>

ffffffffc020418a <phi_take_forks_condvar>:


void phi_take_forks_condvar(int i) {
ffffffffc020418a:	7179                	addi	sp,sp,-48
ffffffffc020418c:	e84a                	sd	s2,16(sp)
     down(&(mtp->mutex));
ffffffffc020418e:	000c4917          	auipc	s2,0xc4
ffffffffc0204192:	baa90913          	addi	s2,s2,-1110 # ffffffffc02c7d38 <mtp>
void phi_take_forks_condvar(int i) {
ffffffffc0204196:	e44e                	sd	s3,8(sp)
ffffffffc0204198:	89aa                	mv	s3,a0
     down(&(mtp->mutex));
ffffffffc020419a:	00093503          	ld	a0,0(s2)
void phi_take_forks_condvar(int i) {
ffffffffc020419e:	f406                	sd	ra,40(sp)
ffffffffc02041a0:	f022                	sd	s0,32(sp)
ffffffffc02041a2:	ec26                	sd	s1,24(sp)
//--------into routine in monitor--------------
     // LAB7 EXERCISE1: 2312260
     // I am hungry
     // try to get fork
    state_condvar[i] = HUNGRY;
ffffffffc02041a4:	000c4417          	auipc	s0,0xc4
ffffffffc02041a8:	ffc40413          	addi	s0,s0,-4 # ffffffffc02c81a0 <state_condvar>
     down(&(mtp->mutex));
ffffffffc02041ac:	578000ef          	jal	ffffffffc0204724 <down>
    state_condvar[i] = HUNGRY;
ffffffffc02041b0:	00299493          	slli	s1,s3,0x2
ffffffffc02041b4:	4785                	li	a5,1
ffffffffc02041b6:	9426                	add	s0,s0,s1
    phi_test_condvar(i);
ffffffffc02041b8:	854e                	mv	a0,s3
    state_condvar[i] = HUNGRY;
ffffffffc02041ba:	c01c                	sw	a5,0(s0)
    phi_test_condvar(i);
ffffffffc02041bc:	f19ff0ef          	jal	ffffffffc02040d4 <phi_test_condvar>
    if (state_condvar[i] != EATING) {
ffffffffc02041c0:	4018                	lw	a4,0(s0)
ffffffffc02041c2:	4789                	li	a5,2
ffffffffc02041c4:	00f70a63          	beq	a4,a5,ffffffffc02041d8 <phi_take_forks_condvar+0x4e>
        cond_wait(&mtp->cv[i]);
ffffffffc02041c8:	00093783          	ld	a5,0(s2)
ffffffffc02041cc:	94ce                	add	s1,s1,s3
ffffffffc02041ce:	048e                	slli	s1,s1,0x3
ffffffffc02041d0:	7f88                	ld	a0,56(a5)
ffffffffc02041d2:	9526                	add	a0,a0,s1
ffffffffc02041d4:	3b4000ef          	jal	ffffffffc0204588 <cond_wait>
    }
//--------leave routine in monitor--------------
      if(mtp->next_count>0)
ffffffffc02041d8:	00093503          	ld	a0,0(s2)
ffffffffc02041dc:	591c                	lw	a5,48(a0)
ffffffffc02041de:	00f05363          	blez	a5,ffffffffc02041e4 <phi_take_forks_condvar+0x5a>
         up(&(mtp->next));
ffffffffc02041e2:	0561                	addi	a0,a0,24
      else
         up(&(mtp->mutex));
}
ffffffffc02041e4:	7402                	ld	s0,32(sp)
ffffffffc02041e6:	70a2                	ld	ra,40(sp)
ffffffffc02041e8:	64e2                	ld	s1,24(sp)
ffffffffc02041ea:	6942                	ld	s2,16(sp)
ffffffffc02041ec:	69a2                	ld	s3,8(sp)
ffffffffc02041ee:	6145                	addi	sp,sp,48
         up(&(mtp->mutex));
ffffffffc02041f0:	ab05                	j	ffffffffc0204720 <up>

ffffffffc02041f2 <phi_put_forks_condvar>:

void phi_put_forks_condvar(int i) {
ffffffffc02041f2:	1101                	addi	sp,sp,-32
ffffffffc02041f4:	e04a                	sd	s2,0(sp)
     down(&(mtp->mutex));
ffffffffc02041f6:	000c4917          	auipc	s2,0xc4
ffffffffc02041fa:	b4290913          	addi	s2,s2,-1214 # ffffffffc02c7d38 <mtp>
void phi_put_forks_condvar(int i) {
ffffffffc02041fe:	e426                	sd	s1,8(sp)
ffffffffc0204200:	84aa                	mv	s1,a0
     down(&(mtp->mutex));
ffffffffc0204202:	00093503          	ld	a0,0(s2)
void phi_put_forks_condvar(int i) {
ffffffffc0204206:	ec06                	sd	ra,24(sp)
ffffffffc0204208:	e822                	sd	s0,16(sp)
     down(&(mtp->mutex));
ffffffffc020420a:	51a000ef          	jal	ffffffffc0204724 <down>
//--------into routine in monitor--------------
     // LAB7 EXERCISE1: 2312260
     // I ate over
     // test left and right neighbors
    state_condvar[i] = THINKING;
    phi_test_condvar(LEFT);
ffffffffc020420e:	66666437          	lui	s0,0x66666
ffffffffc0204212:	0044851b          	addiw	a0,s1,4
ffffffffc0204216:	66740413          	addi	s0,s0,1639 # 66666667 <_binary_obj___user_matrix_out_size+0x6665af7f>
ffffffffc020421a:	028507b3          	mul	a5,a0,s0
    state_condvar[i] = THINKING;
ffffffffc020421e:	00249613          	slli	a2,s1,0x2
    phi_test_condvar(RIGHT);
ffffffffc0204222:	2485                	addiw	s1,s1,1
    phi_test_condvar(LEFT);
ffffffffc0204224:	41f5569b          	sraiw	a3,a0,0x1f
    state_condvar[i] = THINKING;
ffffffffc0204228:	000c4717          	auipc	a4,0xc4
ffffffffc020422c:	f7870713          	addi	a4,a4,-136 # ffffffffc02c81a0 <state_condvar>
ffffffffc0204230:	9732                	add	a4,a4,a2
ffffffffc0204232:	00072023          	sw	zero,0(a4)
    phi_test_condvar(RIGHT);
ffffffffc0204236:	02848433          	mul	s0,s1,s0
    phi_test_condvar(LEFT);
ffffffffc020423a:	9785                	srai	a5,a5,0x21
ffffffffc020423c:	9f95                	subw	a5,a5,a3
ffffffffc020423e:	0027971b          	slliw	a4,a5,0x2
ffffffffc0204242:	9fb9                	addw	a5,a5,a4
ffffffffc0204244:	9d1d                	subw	a0,a0,a5
ffffffffc0204246:	e8fff0ef          	jal	ffffffffc02040d4 <phi_test_condvar>
    phi_test_condvar(RIGHT);
ffffffffc020424a:	41f4d79b          	sraiw	a5,s1,0x1f
ffffffffc020424e:	9405                	srai	s0,s0,0x21
ffffffffc0204250:	9c1d                	subw	s0,s0,a5
ffffffffc0204252:	0024151b          	slliw	a0,s0,0x2
ffffffffc0204256:	9d21                	addw	a0,a0,s0
ffffffffc0204258:	40a4853b          	subw	a0,s1,a0
ffffffffc020425c:	e79ff0ef          	jal	ffffffffc02040d4 <phi_test_condvar>
//--------leave routine in monitor--------------
     if(mtp->next_count>0)
ffffffffc0204260:	00093503          	ld	a0,0(s2)
ffffffffc0204264:	591c                	lw	a5,48(a0)
ffffffffc0204266:	00f05363          	blez	a5,ffffffffc020426c <phi_put_forks_condvar+0x7a>
        up(&(mtp->next));
ffffffffc020426a:	0561                	addi	a0,a0,24
     else
        up(&(mtp->mutex));
}
ffffffffc020426c:	6442                	ld	s0,16(sp)
ffffffffc020426e:	60e2                	ld	ra,24(sp)
ffffffffc0204270:	64a2                	ld	s1,8(sp)
ffffffffc0204272:	6902                	ld	s2,0(sp)
ffffffffc0204274:	6105                	addi	sp,sp,32
        up(&(mtp->mutex));
ffffffffc0204276:	a16d                	j	ffffffffc0204720 <up>

ffffffffc0204278 <philosopher_using_condvar>:

//---------- philosophers using monitor (condition variable) ----------------------
int philosopher_using_condvar(void * arg) { /* arg is the No. of philosopher 0~N-1*/
ffffffffc0204278:	1101                	addi	sp,sp,-32
ffffffffc020427a:	e822                	sd	s0,16(sp)
  
    int i, iter=0;
    i=(int)(long)arg;
ffffffffc020427c:	0005041b          	sext.w	s0,a0
    cprintf("I am No.%d philosopher_condvar\n",i);
ffffffffc0204280:	85a2                	mv	a1,s0
ffffffffc0204282:	00004517          	auipc	a0,0x4
ffffffffc0204286:	ef650513          	addi	a0,a0,-266 # ffffffffc0208178 <etext+0x1a16>
int philosopher_using_condvar(void * arg) { /* arg is the No. of philosopher 0~N-1*/
ffffffffc020428a:	e426                	sd	s1,8(sp)
ffffffffc020428c:	e04a                	sd	s2,0(sp)
ffffffffc020428e:	ec06                	sd	ra,24(sp)
    while(iter++<TIMES)
ffffffffc0204290:	4485                	li	s1,1
    cprintf("I am No.%d philosopher_condvar\n",i);
ffffffffc0204292:	f07fb0ef          	jal	ffffffffc0200198 <cprintf>
    while(iter++<TIMES)
ffffffffc0204296:	4915                	li	s2,5
    { /* iterate*/
        cprintf("Iter %d, No.%d philosopher_condvar is thinking\n",iter,i); /* thinking*/
ffffffffc0204298:	85a6                	mv	a1,s1
ffffffffc020429a:	8622                	mv	a2,s0
ffffffffc020429c:	00004517          	auipc	a0,0x4
ffffffffc02042a0:	efc50513          	addi	a0,a0,-260 # ffffffffc0208198 <etext+0x1a36>
ffffffffc02042a4:	ef5fb0ef          	jal	ffffffffc0200198 <cprintf>
        do_sleep(SLEEP_TIME);
ffffffffc02042a8:	4529                	li	a0,10
ffffffffc02042aa:	09d010ef          	jal	ffffffffc0205b46 <do_sleep>
        phi_take_forks_condvar(i); 
ffffffffc02042ae:	8522                	mv	a0,s0
ffffffffc02042b0:	edbff0ef          	jal	ffffffffc020418a <phi_take_forks_condvar>
        /* need two forks, maybe blocked */
        cprintf("Iter %d, No.%d philosopher_condvar is eating\n",iter,i); /* eating*/
ffffffffc02042b4:	85a6                	mv	a1,s1
ffffffffc02042b6:	8622                	mv	a2,s0
ffffffffc02042b8:	00004517          	auipc	a0,0x4
ffffffffc02042bc:	f1050513          	addi	a0,a0,-240 # ffffffffc02081c8 <etext+0x1a66>
ffffffffc02042c0:	ed9fb0ef          	jal	ffffffffc0200198 <cprintf>
        do_sleep(SLEEP_TIME);
ffffffffc02042c4:	4529                	li	a0,10
ffffffffc02042c6:	081010ef          	jal	ffffffffc0205b46 <do_sleep>
        phi_put_forks_condvar(i); 
ffffffffc02042ca:	8522                	mv	a0,s0
    while(iter++<TIMES)
ffffffffc02042cc:	2485                	addiw	s1,s1,1
        phi_put_forks_condvar(i); 
ffffffffc02042ce:	f25ff0ef          	jal	ffffffffc02041f2 <phi_put_forks_condvar>
    while(iter++<TIMES)
ffffffffc02042d2:	fd2493e3          	bne	s1,s2,ffffffffc0204298 <philosopher_using_condvar+0x20>
        /* return two forks back*/
    }
    cprintf("No.%d philosopher_condvar quit\n",i);
ffffffffc02042d6:	85a2                	mv	a1,s0
ffffffffc02042d8:	00004517          	auipc	a0,0x4
ffffffffc02042dc:	f2050513          	addi	a0,a0,-224 # ffffffffc02081f8 <etext+0x1a96>
ffffffffc02042e0:	eb9fb0ef          	jal	ffffffffc0200198 <cprintf>
    return 0;    
}
ffffffffc02042e4:	60e2                	ld	ra,24(sp)
ffffffffc02042e6:	6442                	ld	s0,16(sp)
ffffffffc02042e8:	64a2                	ld	s1,8(sp)
ffffffffc02042ea:	6902                	ld	s2,0(sp)
ffffffffc02042ec:	4501                	li	a0,0
ffffffffc02042ee:	6105                	addi	sp,sp,32
ffffffffc02042f0:	8082                	ret

ffffffffc02042f2 <check_sync>:

void check_sync(void){
ffffffffc02042f2:	711d                	addi	sp,sp,-96
ffffffffc02042f4:	e8a2                	sd	s0,80(sp)

    int i, pids[N];

    //check semaphore
    sem_init(&mutex, 1);
ffffffffc02042f6:	4585                	li	a1,1
ffffffffc02042f8:	000c4517          	auipc	a0,0xc4
ffffffffc02042fc:	f8850513          	addi	a0,a0,-120 # ffffffffc02c8280 <mutex>
ffffffffc0204300:	0020                	addi	s0,sp,8
void check_sync(void){
ffffffffc0204302:	e4a6                	sd	s1,72(sp)
ffffffffc0204304:	e0ca                	sd	s2,64(sp)
ffffffffc0204306:	fc4e                	sd	s3,56(sp)
ffffffffc0204308:	f852                	sd	s4,48(sp)
ffffffffc020430a:	f456                	sd	s5,40(sp)
ffffffffc020430c:	ec86                	sd	ra,88(sp)
ffffffffc020430e:	f05a                	sd	s6,32(sp)
    sem_init(&mutex, 1);
ffffffffc0204310:	8a22                	mv	s4,s0
ffffffffc0204312:	408000ef          	jal	ffffffffc020471a <sem_init>
    for(i=0;i<N;i++){
ffffffffc0204316:	000c4997          	auipc	s3,0xc4
ffffffffc020431a:	ef298993          	addi	s3,s3,-270 # ffffffffc02c8208 <s>
ffffffffc020431e:	000c4917          	auipc	s2,0xc4
ffffffffc0204322:	ec290913          	addi	s2,s2,-318 # ffffffffc02c81e0 <philosopher_proc_sema>
    sem_init(&mutex, 1);
ffffffffc0204326:	4481                	li	s1,0
    for(i=0;i<N;i++){
ffffffffc0204328:	4a95                	li	s5,5
        sem_init(&s[i], 0);
ffffffffc020432a:	4581                	li	a1,0
ffffffffc020432c:	854e                	mv	a0,s3
ffffffffc020432e:	3ec000ef          	jal	ffffffffc020471a <sem_init>
        int pid = kernel_thread(philosopher_using_semaphore, (void *)(long)i, 0);
ffffffffc0204332:	85a6                	mv	a1,s1
ffffffffc0204334:	4601                	li	a2,0
ffffffffc0204336:	00000517          	auipc	a0,0x0
ffffffffc020433a:	c6e50513          	addi	a0,a0,-914 # ffffffffc0203fa4 <philosopher_using_semaphore>
ffffffffc020433e:	347000ef          	jal	ffffffffc0204e84 <kernel_thread>
        if (pid <= 0) {
ffffffffc0204342:	0ca05763          	blez	a0,ffffffffc0204410 <check_sync+0x11e>
            panic("create No.%d philosopher_using_semaphore failed.\n");
        }
        pids[i] = pid;
ffffffffc0204346:	00aa2023          	sw	a0,0(s4)
        philosopher_proc_sema[i] = find_proc(pid);
ffffffffc020434a:	6bc000ef          	jal	ffffffffc0204a06 <find_proc>
ffffffffc020434e:	00a93023          	sd	a0,0(s2)
        set_proc_name(philosopher_proc_sema[i], "philosopher_sema_proc");
ffffffffc0204352:	00004597          	auipc	a1,0x4
ffffffffc0204356:	f1658593          	addi	a1,a1,-234 # ffffffffc0208268 <etext+0x1b06>
    for(i=0;i<N;i++){
ffffffffc020435a:	0485                	addi	s1,s1,1
        set_proc_name(philosopher_proc_sema[i], "philosopher_sema_proc");
ffffffffc020435c:	61e000ef          	jal	ffffffffc020497a <set_proc_name>
    for(i=0;i<N;i++){
ffffffffc0204360:	09e1                	addi	s3,s3,24
ffffffffc0204362:	0a11                	addi	s4,s4,4
ffffffffc0204364:	0921                	addi	s2,s2,8
ffffffffc0204366:	fd5492e3          	bne	s1,s5,ffffffffc020432a <check_sync+0x38>
ffffffffc020436a:	01440a93          	addi	s5,s0,20
ffffffffc020436e:	84a2                	mv	s1,s0
    }
    for (i=0;i<N;i++)
        assert(do_wait(pids[i],NULL) == 0);
ffffffffc0204370:	4088                	lw	a0,0(s1)
ffffffffc0204372:	4581                	li	a1,0
ffffffffc0204374:	538010ef          	jal	ffffffffc02058ac <do_wait>
ffffffffc0204378:	0e051463          	bnez	a0,ffffffffc0204460 <check_sync+0x16e>
    for (i=0;i<N;i++)
ffffffffc020437c:	0491                	addi	s1,s1,4
ffffffffc020437e:	ff5499e3          	bne	s1,s5,ffffffffc0204370 <check_sync+0x7e>

    //check condition variable
    monitor_init(&mt, N);
ffffffffc0204382:	4595                	li	a1,5
ffffffffc0204384:	000c4517          	auipc	a0,0xc4
ffffffffc0204388:	ddc50513          	addi	a0,a0,-548 # ffffffffc02c8160 <mt>
ffffffffc020438c:	0f4000ef          	jal	ffffffffc0204480 <monitor_init>
ffffffffc0204390:	8a22                	mv	s4,s0
ffffffffc0204392:	000c4917          	auipc	s2,0xc4
ffffffffc0204396:	e0e90913          	addi	s2,s2,-498 # ffffffffc02c81a0 <state_condvar>
ffffffffc020439a:	000c4997          	auipc	s3,0xc4
ffffffffc020439e:	e1e98993          	addi	s3,s3,-482 # ffffffffc02c81b8 <philosopher_proc_condvar>
ffffffffc02043a2:	4481                	li	s1,0
    for(i=0;i<N;i++){
ffffffffc02043a4:	4b15                	li	s6,5
        state_condvar[i]=THINKING;
        int pid = kernel_thread(philosopher_using_condvar, (void *)(long)i, 0);
ffffffffc02043a6:	4601                	li	a2,0
ffffffffc02043a8:	85a6                	mv	a1,s1
ffffffffc02043aa:	00000517          	auipc	a0,0x0
ffffffffc02043ae:	ece50513          	addi	a0,a0,-306 # ffffffffc0204278 <philosopher_using_condvar>
        state_condvar[i]=THINKING;
ffffffffc02043b2:	00092023          	sw	zero,0(s2)
        int pid = kernel_thread(philosopher_using_condvar, (void *)(long)i, 0);
ffffffffc02043b6:	2cf000ef          	jal	ffffffffc0204e84 <kernel_thread>
        if (pid <= 0) {
ffffffffc02043ba:	08a05763          	blez	a0,ffffffffc0204448 <check_sync+0x156>
            panic("create No.%d philosopher_using_condvar failed.\n");
        }
        pids[i] = pid;
ffffffffc02043be:	00aa2023          	sw	a0,0(s4)
        philosopher_proc_condvar[i] = find_proc(pid);
ffffffffc02043c2:	644000ef          	jal	ffffffffc0204a06 <find_proc>
ffffffffc02043c6:	00a9b023          	sd	a0,0(s3)
        set_proc_name(philosopher_proc_condvar[i], "philosopher_condvar_proc");
ffffffffc02043ca:	00004597          	auipc	a1,0x4
ffffffffc02043ce:	f0658593          	addi	a1,a1,-250 # ffffffffc02082d0 <etext+0x1b6e>
    for(i=0;i<N;i++){
ffffffffc02043d2:	0485                	addi	s1,s1,1
        set_proc_name(philosopher_proc_condvar[i], "philosopher_condvar_proc");
ffffffffc02043d4:	5a6000ef          	jal	ffffffffc020497a <set_proc_name>
    for(i=0;i<N;i++){
ffffffffc02043d8:	0911                	addi	s2,s2,4
ffffffffc02043da:	0a11                	addi	s4,s4,4
ffffffffc02043dc:	09a1                	addi	s3,s3,8
ffffffffc02043de:	fd6494e3          	bne	s1,s6,ffffffffc02043a6 <check_sync+0xb4>
    }
    for (i=0;i<N;i++)
        assert(do_wait(pids[i],NULL) == 0);
ffffffffc02043e2:	4008                	lw	a0,0(s0)
ffffffffc02043e4:	4581                	li	a1,0
ffffffffc02043e6:	4c6010ef          	jal	ffffffffc02058ac <do_wait>
ffffffffc02043ea:	ed1d                	bnez	a0,ffffffffc0204428 <check_sync+0x136>
    for (i=0;i<N;i++)
ffffffffc02043ec:	0411                	addi	s0,s0,4
ffffffffc02043ee:	ff541ae3          	bne	s0,s5,ffffffffc02043e2 <check_sync+0xf0>
    monitor_free(&mt, N);
}
ffffffffc02043f2:	6446                	ld	s0,80(sp)
ffffffffc02043f4:	60e6                	ld	ra,88(sp)
ffffffffc02043f6:	64a6                	ld	s1,72(sp)
ffffffffc02043f8:	6906                	ld	s2,64(sp)
ffffffffc02043fa:	79e2                	ld	s3,56(sp)
ffffffffc02043fc:	7a42                	ld	s4,48(sp)
ffffffffc02043fe:	7aa2                	ld	s5,40(sp)
ffffffffc0204400:	7b02                	ld	s6,32(sp)
    monitor_free(&mt, N);
ffffffffc0204402:	4595                	li	a1,5
ffffffffc0204404:	000c4517          	auipc	a0,0xc4
ffffffffc0204408:	d5c50513          	addi	a0,a0,-676 # ffffffffc02c8160 <mt>
}
ffffffffc020440c:	6125                	addi	sp,sp,96
    monitor_free(&mt, N);
ffffffffc020440e:	aa39                	j	ffffffffc020452c <monitor_free>
            panic("create No.%d philosopher_using_semaphore failed.\n");
ffffffffc0204410:	00004617          	auipc	a2,0x4
ffffffffc0204414:	e0860613          	addi	a2,a2,-504 # ffffffffc0208218 <etext+0x1ab6>
ffffffffc0204418:	0f700593          	li	a1,247
ffffffffc020441c:	00004517          	auipc	a0,0x4
ffffffffc0204420:	e3450513          	addi	a0,a0,-460 # ffffffffc0208250 <etext+0x1aee>
ffffffffc0204424:	826fc0ef          	jal	ffffffffc020044a <__panic>
        assert(do_wait(pids[i],NULL) == 0);
ffffffffc0204428:	00004697          	auipc	a3,0x4
ffffffffc020442c:	e5868693          	addi	a3,a3,-424 # ffffffffc0208280 <etext+0x1b1e>
ffffffffc0204430:	00003617          	auipc	a2,0x3
ffffffffc0204434:	ae060613          	addi	a2,a2,-1312 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0204438:	10d00593          	li	a1,269
ffffffffc020443c:	00004517          	auipc	a0,0x4
ffffffffc0204440:	e1450513          	addi	a0,a0,-492 # ffffffffc0208250 <etext+0x1aee>
ffffffffc0204444:	806fc0ef          	jal	ffffffffc020044a <__panic>
            panic("create No.%d philosopher_using_condvar failed.\n");
ffffffffc0204448:	00004617          	auipc	a2,0x4
ffffffffc020444c:	e5860613          	addi	a2,a2,-424 # ffffffffc02082a0 <etext+0x1b3e>
ffffffffc0204450:	10600593          	li	a1,262
ffffffffc0204454:	00004517          	auipc	a0,0x4
ffffffffc0204458:	dfc50513          	addi	a0,a0,-516 # ffffffffc0208250 <etext+0x1aee>
ffffffffc020445c:	feffb0ef          	jal	ffffffffc020044a <__panic>
        assert(do_wait(pids[i],NULL) == 0);
ffffffffc0204460:	00004697          	auipc	a3,0x4
ffffffffc0204464:	e2068693          	addi	a3,a3,-480 # ffffffffc0208280 <etext+0x1b1e>
ffffffffc0204468:	00003617          	auipc	a2,0x3
ffffffffc020446c:	aa860613          	addi	a2,a2,-1368 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0204470:	0fe00593          	li	a1,254
ffffffffc0204474:	00004517          	auipc	a0,0x4
ffffffffc0204478:	ddc50513          	addi	a0,a0,-548 # ffffffffc0208250 <etext+0x1aee>
ffffffffc020447c:	fcffb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0204480 <monitor_init>:
#include <assert.h>


// Initialize monitor.
void     
monitor_init (monitor_t * mtp, size_t num_cv) {
ffffffffc0204480:	7179                	addi	sp,sp,-48
ffffffffc0204482:	f406                	sd	ra,40(sp)
ffffffffc0204484:	f022                	sd	s0,32(sp)
ffffffffc0204486:	ec26                	sd	s1,24(sp)
ffffffffc0204488:	e84a                	sd	s2,16(sp)
ffffffffc020448a:	e44e                	sd	s3,8(sp)
    int i;
    assert(num_cv>0);
ffffffffc020448c:	c1b5                	beqz	a1,ffffffffc02044f0 <monitor_init+0x70>
    mtp->next_count = 0;
ffffffffc020448e:	89ae                	mv	s3,a1
ffffffffc0204490:	02052823          	sw	zero,48(a0)
    mtp->cv = NULL;
ffffffffc0204494:	02053c23          	sd	zero,56(a0)
    sem_init(&(mtp->mutex), 1); //unlocked
ffffffffc0204498:	4585                	li	a1,1
ffffffffc020449a:	892a                	mv	s2,a0
ffffffffc020449c:	27e000ef          	jal	ffffffffc020471a <sem_init>
    sem_init(&(mtp->next), 0);
ffffffffc02044a0:	01890513          	addi	a0,s2,24
ffffffffc02044a4:	4581                	li	a1,0
ffffffffc02044a6:	274000ef          	jal	ffffffffc020471a <sem_init>
    mtp->cv =(condvar_t *) kmalloc(sizeof(condvar_t)*num_cv);
ffffffffc02044aa:	00299513          	slli	a0,s3,0x2
ffffffffc02044ae:	954e                	add	a0,a0,s3
ffffffffc02044b0:	050e                	slli	a0,a0,0x3
ffffffffc02044b2:	853fd0ef          	jal	ffffffffc0201d04 <kmalloc>
ffffffffc02044b6:	02a93c23          	sd	a0,56(s2)
    assert(mtp->cv!=NULL);
ffffffffc02044ba:	4401                	li	s0,0
ffffffffc02044bc:	4481                	li	s1,0
ffffffffc02044be:	c921                	beqz	a0,ffffffffc020450e <monitor_init+0x8e>
    for(i=0; i<num_cv; i++){
        mtp->cv[i].count=0;
ffffffffc02044c0:	9522                	add	a0,a0,s0
ffffffffc02044c2:	00052c23          	sw	zero,24(a0)
        sem_init(&(mtp->cv[i].sem),0);
ffffffffc02044c6:	4581                	li	a1,0
ffffffffc02044c8:	252000ef          	jal	ffffffffc020471a <sem_init>
        mtp->cv[i].owner=mtp;
ffffffffc02044cc:	03893503          	ld	a0,56(s2)
    for(i=0; i<num_cv; i++){
ffffffffc02044d0:	0485                	addi	s1,s1,1
        mtp->cv[i].owner=mtp;
ffffffffc02044d2:	008507b3          	add	a5,a0,s0
ffffffffc02044d6:	0327b023          	sd	s2,32(a5)
    for(i=0; i<num_cv; i++){
ffffffffc02044da:	02840413          	addi	s0,s0,40
ffffffffc02044de:	ff3491e3          	bne	s1,s3,ffffffffc02044c0 <monitor_init+0x40>
    }
}
ffffffffc02044e2:	70a2                	ld	ra,40(sp)
ffffffffc02044e4:	7402                	ld	s0,32(sp)
ffffffffc02044e6:	64e2                	ld	s1,24(sp)
ffffffffc02044e8:	6942                	ld	s2,16(sp)
ffffffffc02044ea:	69a2                	ld	s3,8(sp)
ffffffffc02044ec:	6145                	addi	sp,sp,48
ffffffffc02044ee:	8082                	ret
    assert(num_cv>0);
ffffffffc02044f0:	00004697          	auipc	a3,0x4
ffffffffc02044f4:	e0068693          	addi	a3,a3,-512 # ffffffffc02082f0 <etext+0x1b8e>
ffffffffc02044f8:	00003617          	auipc	a2,0x3
ffffffffc02044fc:	a1860613          	addi	a2,a2,-1512 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0204500:	45ad                	li	a1,11
ffffffffc0204502:	00004517          	auipc	a0,0x4
ffffffffc0204506:	dfe50513          	addi	a0,a0,-514 # ffffffffc0208300 <etext+0x1b9e>
ffffffffc020450a:	f41fb0ef          	jal	ffffffffc020044a <__panic>
    assert(mtp->cv!=NULL);
ffffffffc020450e:	00004697          	auipc	a3,0x4
ffffffffc0204512:	e0a68693          	addi	a3,a3,-502 # ffffffffc0208318 <etext+0x1bb6>
ffffffffc0204516:	00003617          	auipc	a2,0x3
ffffffffc020451a:	9fa60613          	addi	a2,a2,-1542 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020451e:	45c5                	li	a1,17
ffffffffc0204520:	00004517          	auipc	a0,0x4
ffffffffc0204524:	de050513          	addi	a0,a0,-544 # ffffffffc0208300 <etext+0x1b9e>
ffffffffc0204528:	f23fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020452c <monitor_free>:

// Free monitor.
void
monitor_free (monitor_t * mtp, size_t num_cv) {
    kfree(mtp->cv);
ffffffffc020452c:	7d08                	ld	a0,56(a0)
ffffffffc020452e:	87dfd06f          	j	ffffffffc0201daa <kfree>

ffffffffc0204532 <cond_signal>:

// Unlock one of threads waiting on the condition variable. 
void 
cond_signal (condvar_t *cvp) {
   //LAB7 EXERCISE1: 2312260
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
ffffffffc0204532:	711c                	ld	a5,32(a0)
ffffffffc0204534:	4d10                	lw	a2,24(a0)
cond_signal (condvar_t *cvp) {
ffffffffc0204536:	1141                	addi	sp,sp,-16
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
ffffffffc0204538:	5b94                	lw	a3,48(a5)
cond_signal (condvar_t *cvp) {
ffffffffc020453a:	e022                	sd	s0,0(sp)
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
ffffffffc020453c:	85aa                	mv	a1,a0
cond_signal (condvar_t *cvp) {
ffffffffc020453e:	842a                	mv	s0,a0
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
ffffffffc0204540:	00004517          	auipc	a0,0x4
ffffffffc0204544:	de850513          	addi	a0,a0,-536 # ffffffffc0208328 <etext+0x1bc6>
cond_signal (condvar_t *cvp) {
ffffffffc0204548:	e406                	sd	ra,8(sp)
   cprintf("cond_signal begin: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);  
ffffffffc020454a:	c4ffb0ef          	jal	ffffffffc0200198 <cprintf>
   *             mt.next_count--;
   *          }
   *       }
   */
   if(cvp->count > 0) {
      cvp->owner->next_count ++;
ffffffffc020454e:	701c                	ld	a5,32(s0)
   if(cvp->count > 0) {
ffffffffc0204550:	4c10                	lw	a2,24(s0)
      cvp->owner->next_count ++;
ffffffffc0204552:	5b94                	lw	a3,48(a5)
   if(cvp->count > 0) {
ffffffffc0204554:	02c05063          	blez	a2,ffffffffc0204574 <cond_signal+0x42>
      cvp->owner->next_count ++;
ffffffffc0204558:	2685                	addiw	a3,a3,1
ffffffffc020455a:	db94                	sw	a3,48(a5)
      up(&(cvp->sem));
ffffffffc020455c:	8522                	mv	a0,s0
ffffffffc020455e:	1c2000ef          	jal	ffffffffc0204720 <up>
      down(&(cvp->owner->next));
ffffffffc0204562:	7008                	ld	a0,32(s0)
ffffffffc0204564:	0561                	addi	a0,a0,24
ffffffffc0204566:	1be000ef          	jal	ffffffffc0204724 <down>
      cvp->owner->next_count --;
ffffffffc020456a:	701c                	ld	a5,32(s0)
   }
   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc020456c:	4c10                	lw	a2,24(s0)
      cvp->owner->next_count --;
ffffffffc020456e:	5b94                	lw	a3,48(a5)
ffffffffc0204570:	36fd                	addiw	a3,a3,-1
ffffffffc0204572:	db94                	sw	a3,48(a5)
   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0204574:	85a2                	mv	a1,s0
}
ffffffffc0204576:	6402                	ld	s0,0(sp)
ffffffffc0204578:	60a2                	ld	ra,8(sp)
   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc020457a:	00004517          	auipc	a0,0x4
ffffffffc020457e:	df650513          	addi	a0,a0,-522 # ffffffffc0208370 <etext+0x1c0e>
}
ffffffffc0204582:	0141                	addi	sp,sp,16
   cprintf("cond_signal end: cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0204584:	c15fb06f          	j	ffffffffc0200198 <cprintf>

ffffffffc0204588 <cond_wait>:
// Suspend calling thread on a condition variable waiting for condition Atomically unlocks 
// mutex and suspends calling thread on conditional variable after waking up locks mutex. Notice: mp is mutex semaphore for monitor's procedures
void
cond_wait (condvar_t *cvp) {
    //LAB7 EXERCISE1: 2312260
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0204588:	711c                	ld	a5,32(a0)
ffffffffc020458a:	4d10                	lw	a2,24(a0)
cond_wait (condvar_t *cvp) {
ffffffffc020458c:	1141                	addi	sp,sp,-16
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc020458e:	5b94                	lw	a3,48(a5)
cond_wait (condvar_t *cvp) {
ffffffffc0204590:	e022                	sd	s0,0(sp)
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0204592:	85aa                	mv	a1,a0
cond_wait (condvar_t *cvp) {
ffffffffc0204594:	842a                	mv	s0,a0
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc0204596:	00004517          	auipc	a0,0x4
ffffffffc020459a:	e2250513          	addi	a0,a0,-478 # ffffffffc02083b8 <etext+0x1c56>
cond_wait (condvar_t *cvp) {
ffffffffc020459e:	e406                	sd	ra,8(sp)
    cprintf("cond_wait begin:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc02045a0:	bf9fb0ef          	jal	ffffffffc0200198 <cprintf>
    *            signal(mt.mutex);
    *         wait(cv.sem);
    *         cv.count --;
    */
    cvp->count ++;
    if(cvp->owner->next_count > 0)
ffffffffc02045a4:	7008                	ld	a0,32(s0)
    cvp->count ++;
ffffffffc02045a6:	4c1c                	lw	a5,24(s0)
    if(cvp->owner->next_count > 0)
ffffffffc02045a8:	5918                	lw	a4,48(a0)
    cvp->count ++;
ffffffffc02045aa:	2785                	addiw	a5,a5,1
ffffffffc02045ac:	cc1c                	sw	a5,24(s0)
    if(cvp->owner->next_count > 0)
ffffffffc02045ae:	02e05763          	blez	a4,ffffffffc02045dc <cond_wait+0x54>
       up(&(cvp->owner->next));
ffffffffc02045b2:	0561                	addi	a0,a0,24
ffffffffc02045b4:	16c000ef          	jal	ffffffffc0204720 <up>
    else
       up(&(cvp->owner->mutex));
    down(&(cvp->sem));
ffffffffc02045b8:	8522                	mv	a0,s0
ffffffffc02045ba:	16a000ef          	jal	ffffffffc0204724 <down>
    cvp->count --;
ffffffffc02045be:	4c10                	lw	a2,24(s0)
    cprintf("cond_wait end:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc02045c0:	701c                	ld	a5,32(s0)
ffffffffc02045c2:	85a2                	mv	a1,s0
    cvp->count --;
ffffffffc02045c4:	367d                	addiw	a2,a2,-1
    cprintf("cond_wait end:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc02045c6:	5b94                	lw	a3,48(a5)
    cvp->count --;
ffffffffc02045c8:	cc10                	sw	a2,24(s0)
}
ffffffffc02045ca:	6402                	ld	s0,0(sp)
ffffffffc02045cc:	60a2                	ld	ra,8(sp)
    cprintf("cond_wait end:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc02045ce:	00004517          	auipc	a0,0x4
ffffffffc02045d2:	e3250513          	addi	a0,a0,-462 # ffffffffc0208400 <etext+0x1c9e>
}
ffffffffc02045d6:	0141                	addi	sp,sp,16
    cprintf("cond_wait end:  cvp %x, cvp->count %d, cvp->owner->next_count %d\n", cvp, cvp->count, cvp->owner->next_count);
ffffffffc02045d8:	bc1fb06f          	j	ffffffffc0200198 <cprintf>
       up(&(cvp->owner->mutex));
ffffffffc02045dc:	144000ef          	jal	ffffffffc0204720 <up>
ffffffffc02045e0:	bfe1                	j	ffffffffc02045b8 <cond_wait+0x30>

ffffffffc02045e2 <__down.constprop.0>:
        }
    }
    local_intr_restore(intr_flag);
}

static __noinline uint32_t __down(semaphore_t *sem, uint32_t wait_state) {
ffffffffc02045e2:	711d                	addi	sp,sp,-96
ffffffffc02045e4:	ec86                	sd	ra,88(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02045e6:	100027f3          	csrr	a5,sstatus
ffffffffc02045ea:	8b89                	andi	a5,a5,2
ffffffffc02045ec:	eba1                	bnez	a5,ffffffffc020463c <__down.constprop.0+0x5a>
    bool intr_flag;
    local_intr_save(intr_flag);
    if (sem->value > 0) {
ffffffffc02045ee:	411c                	lw	a5,0(a0)
ffffffffc02045f0:	00f05863          	blez	a5,ffffffffc0204600 <__down.constprop.0+0x1e>
        sem->value --;
ffffffffc02045f4:	37fd                	addiw	a5,a5,-1
ffffffffc02045f6:	c11c                	sw	a5,0(a0)

    if (wait->wakeup_flags != wait_state) {
        return wait->wakeup_flags;
    }
    return 0;
}
ffffffffc02045f8:	60e6                	ld	ra,88(sp)
        return 0;
ffffffffc02045fa:	4501                	li	a0,0
}
ffffffffc02045fc:	6125                	addi	sp,sp,96
ffffffffc02045fe:	8082                	ret
    wait_current_set(&(sem->wait_queue), wait, wait_state);
ffffffffc0204600:	0521                	addi	a0,a0,8
ffffffffc0204602:	082c                	addi	a1,sp,24
ffffffffc0204604:	10000613          	li	a2,256
ffffffffc0204608:	e8a2                	sd	s0,80(sp)
ffffffffc020460a:	e4a6                	sd	s1,72(sp)
ffffffffc020460c:	0820                	addi	s0,sp,24
ffffffffc020460e:	84aa                	mv	s1,a0
ffffffffc0204610:	1f4000ef          	jal	ffffffffc0204804 <wait_current_set>
    schedule();
ffffffffc0204614:	055010ef          	jal	ffffffffc0205e68 <schedule>
ffffffffc0204618:	100027f3          	csrr	a5,sstatus
ffffffffc020461c:	8b89                	andi	a5,a5,2
ffffffffc020461e:	efa9                	bnez	a5,ffffffffc0204678 <__down.constprop.0+0x96>
    wait_current_del(&(sem->wait_queue), wait);
ffffffffc0204620:	8522                	mv	a0,s0
ffffffffc0204622:	186000ef          	jal	ffffffffc02047a8 <wait_in_queue>
ffffffffc0204626:	e521                	bnez	a0,ffffffffc020466e <__down.constprop.0+0x8c>
    if (wait->wakeup_flags != wait_state) {
ffffffffc0204628:	5502                	lw	a0,32(sp)
ffffffffc020462a:	10000793          	li	a5,256
ffffffffc020462e:	6446                	ld	s0,80(sp)
ffffffffc0204630:	64a6                	ld	s1,72(sp)
ffffffffc0204632:	fcf503e3          	beq	a0,a5,ffffffffc02045f8 <__down.constprop.0+0x16>
}
ffffffffc0204636:	60e6                	ld	ra,88(sp)
ffffffffc0204638:	6125                	addi	sp,sp,96
ffffffffc020463a:	8082                	ret
ffffffffc020463c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc020463e:	ac0fc0ef          	jal	ffffffffc02008fe <intr_disable>
    if (sem->value > 0) {
ffffffffc0204642:	6522                	ld	a0,8(sp)
ffffffffc0204644:	411c                	lw	a5,0(a0)
ffffffffc0204646:	00f05763          	blez	a5,ffffffffc0204654 <__down.constprop.0+0x72>
        sem->value --;
ffffffffc020464a:	37fd                	addiw	a5,a5,-1
ffffffffc020464c:	c11c                	sw	a5,0(a0)
        intr_enable();
ffffffffc020464e:	aaafc0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0204652:	b75d                	j	ffffffffc02045f8 <__down.constprop.0+0x16>
    wait_current_set(&(sem->wait_queue), wait, wait_state);
ffffffffc0204654:	0521                	addi	a0,a0,8
ffffffffc0204656:	082c                	addi	a1,sp,24
ffffffffc0204658:	10000613          	li	a2,256
ffffffffc020465c:	e8a2                	sd	s0,80(sp)
ffffffffc020465e:	e4a6                	sd	s1,72(sp)
ffffffffc0204660:	0820                	addi	s0,sp,24
ffffffffc0204662:	84aa                	mv	s1,a0
ffffffffc0204664:	1a0000ef          	jal	ffffffffc0204804 <wait_current_set>
ffffffffc0204668:	a90fc0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc020466c:	b765                	j	ffffffffc0204614 <__down.constprop.0+0x32>
    wait_current_del(&(sem->wait_queue), wait);
ffffffffc020466e:	85a2                	mv	a1,s0
ffffffffc0204670:	8526                	mv	a0,s1
ffffffffc0204672:	0e8000ef          	jal	ffffffffc020475a <wait_queue_del>
    if (flag) {
ffffffffc0204676:	bf4d                	j	ffffffffc0204628 <__down.constprop.0+0x46>
        intr_disable();
ffffffffc0204678:	a86fc0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc020467c:	8522                	mv	a0,s0
ffffffffc020467e:	12a000ef          	jal	ffffffffc02047a8 <wait_in_queue>
ffffffffc0204682:	e501                	bnez	a0,ffffffffc020468a <__down.constprop.0+0xa8>
        intr_enable();
ffffffffc0204684:	a74fc0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0204688:	b745                	j	ffffffffc0204628 <__down.constprop.0+0x46>
ffffffffc020468a:	85a2                	mv	a1,s0
ffffffffc020468c:	8526                	mv	a0,s1
ffffffffc020468e:	0cc000ef          	jal	ffffffffc020475a <wait_queue_del>
    if (flag) {
ffffffffc0204692:	bfcd                	j	ffffffffc0204684 <__down.constprop.0+0xa2>

ffffffffc0204694 <__up.constprop.0>:
static __noinline void __up(semaphore_t *sem, uint32_t wait_state) {
ffffffffc0204694:	1101                	addi	sp,sp,-32
ffffffffc0204696:	e426                	sd	s1,8(sp)
ffffffffc0204698:	ec06                	sd	ra,24(sp)
ffffffffc020469a:	e822                	sd	s0,16(sp)
ffffffffc020469c:	e04a                	sd	s2,0(sp)
ffffffffc020469e:	84aa                	mv	s1,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02046a0:	100027f3          	csrr	a5,sstatus
ffffffffc02046a4:	8b89                	andi	a5,a5,2
ffffffffc02046a6:	4901                	li	s2,0
ffffffffc02046a8:	e7b1                	bnez	a5,ffffffffc02046f4 <__up.constprop.0+0x60>
        if ((wait = wait_queue_first(&(sem->wait_queue))) == NULL) {
ffffffffc02046aa:	00848413          	addi	s0,s1,8
ffffffffc02046ae:	8522                	mv	a0,s0
ffffffffc02046b0:	0e8000ef          	jal	ffffffffc0204798 <wait_queue_first>
ffffffffc02046b4:	cd05                	beqz	a0,ffffffffc02046ec <__up.constprop.0+0x58>
            assert(wait->proc->wait_state == wait_state);
ffffffffc02046b6:	6118                	ld	a4,0(a0)
ffffffffc02046b8:	10000793          	li	a5,256
ffffffffc02046bc:	0ec72603          	lw	a2,236(a4)
ffffffffc02046c0:	02f61e63          	bne	a2,a5,ffffffffc02046fc <__up.constprop.0+0x68>
            wakeup_wait(&(sem->wait_queue), wait, wait_state, 1);
ffffffffc02046c4:	85aa                	mv	a1,a0
ffffffffc02046c6:	4685                	li	a3,1
ffffffffc02046c8:	8522                	mv	a0,s0
ffffffffc02046ca:	0ec000ef          	jal	ffffffffc02047b6 <wakeup_wait>
    if (flag) {
ffffffffc02046ce:	00091863          	bnez	s2,ffffffffc02046de <__up.constprop.0+0x4a>
}
ffffffffc02046d2:	60e2                	ld	ra,24(sp)
ffffffffc02046d4:	6442                	ld	s0,16(sp)
ffffffffc02046d6:	64a2                	ld	s1,8(sp)
ffffffffc02046d8:	6902                	ld	s2,0(sp)
ffffffffc02046da:	6105                	addi	sp,sp,32
ffffffffc02046dc:	8082                	ret
ffffffffc02046de:	6442                	ld	s0,16(sp)
ffffffffc02046e0:	60e2                	ld	ra,24(sp)
ffffffffc02046e2:	64a2                	ld	s1,8(sp)
ffffffffc02046e4:	6902                	ld	s2,0(sp)
ffffffffc02046e6:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02046e8:	a10fc06f          	j	ffffffffc02008f8 <intr_enable>
            sem->value ++;
ffffffffc02046ec:	409c                	lw	a5,0(s1)
ffffffffc02046ee:	2785                	addiw	a5,a5,1
ffffffffc02046f0:	c09c                	sw	a5,0(s1)
ffffffffc02046f2:	bff1                	j	ffffffffc02046ce <__up.constprop.0+0x3a>
        intr_disable();
ffffffffc02046f4:	a0afc0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc02046f8:	4905                	li	s2,1
ffffffffc02046fa:	bf45                	j	ffffffffc02046aa <__up.constprop.0+0x16>
            assert(wait->proc->wait_state == wait_state);
ffffffffc02046fc:	00004697          	auipc	a3,0x4
ffffffffc0204700:	d4c68693          	addi	a3,a3,-692 # ffffffffc0208448 <etext+0x1ce6>
ffffffffc0204704:	00003617          	auipc	a2,0x3
ffffffffc0204708:	80c60613          	addi	a2,a2,-2036 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020470c:	45e5                	li	a1,25
ffffffffc020470e:	00004517          	auipc	a0,0x4
ffffffffc0204712:	d6250513          	addi	a0,a0,-670 # ffffffffc0208470 <etext+0x1d0e>
ffffffffc0204716:	d35fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020471a <sem_init>:
    sem->value = value;
ffffffffc020471a:	c10c                	sw	a1,0(a0)
    wait_queue_init(&(sem->wait_queue));
ffffffffc020471c:	0521                	addi	a0,a0,8
ffffffffc020471e:	a81d                	j	ffffffffc0204754 <wait_queue_init>

ffffffffc0204720 <up>:

void
up(semaphore_t *sem) {
    __up(sem, WT_KSEM);
ffffffffc0204720:	f75ff06f          	j	ffffffffc0204694 <__up.constprop.0>

ffffffffc0204724 <down>:
}

void
down(semaphore_t *sem) {
ffffffffc0204724:	1141                	addi	sp,sp,-16
ffffffffc0204726:	e406                	sd	ra,8(sp)
    uint32_t flags = __down(sem, WT_KSEM);
ffffffffc0204728:	ebbff0ef          	jal	ffffffffc02045e2 <__down.constprop.0>
    assert(flags == 0);
ffffffffc020472c:	e501                	bnez	a0,ffffffffc0204734 <down+0x10>
}
ffffffffc020472e:	60a2                	ld	ra,8(sp)
ffffffffc0204730:	0141                	addi	sp,sp,16
ffffffffc0204732:	8082                	ret
    assert(flags == 0);
ffffffffc0204734:	00004697          	auipc	a3,0x4
ffffffffc0204738:	d4c68693          	addi	a3,a3,-692 # ffffffffc0208480 <etext+0x1d1e>
ffffffffc020473c:	00002617          	auipc	a2,0x2
ffffffffc0204740:	7d460613          	addi	a2,a2,2004 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0204744:	04000593          	li	a1,64
ffffffffc0204748:	00004517          	auipc	a0,0x4
ffffffffc020474c:	d2850513          	addi	a0,a0,-728 # ffffffffc0208470 <etext+0x1d0e>
ffffffffc0204750:	cfbfb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0204754 <wait_queue_init>:
    elm->prev = elm->next = elm;
ffffffffc0204754:	e508                	sd	a0,8(a0)
ffffffffc0204756:	e108                	sd	a0,0(a0)
}

void
wait_queue_init(wait_queue_t *queue) {
    list_init(&(queue->wait_head));
}
ffffffffc0204758:	8082                	ret

ffffffffc020475a <wait_queue_del>:
    return list->next == list;
ffffffffc020475a:	7198                	ld	a4,32(a1)
    list_add_before(&(queue->wait_head), &(wait->wait_link));
}

void
wait_queue_del(wait_queue_t *queue, wait_t *wait) {
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
ffffffffc020475c:	01858793          	addi	a5,a1,24
ffffffffc0204760:	00e78b63          	beq	a5,a4,ffffffffc0204776 <wait_queue_del+0x1c>
ffffffffc0204764:	6994                	ld	a3,16(a1)
ffffffffc0204766:	00a69863          	bne	a3,a0,ffffffffc0204776 <wait_queue_del+0x1c>
    __list_del(listelm->prev, listelm->next);
ffffffffc020476a:	6d94                	ld	a3,24(a1)
    prev->next = next;
ffffffffc020476c:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc020476e:	e314                	sd	a3,0(a4)
    elm->prev = elm->next = elm;
ffffffffc0204770:	f19c                	sd	a5,32(a1)
ffffffffc0204772:	ed9c                	sd	a5,24(a1)
ffffffffc0204774:	8082                	ret
wait_queue_del(wait_queue_t *queue, wait_t *wait) {
ffffffffc0204776:	1141                	addi	sp,sp,-16
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
ffffffffc0204778:	00004697          	auipc	a3,0x4
ffffffffc020477c:	d6868693          	addi	a3,a3,-664 # ffffffffc02084e0 <etext+0x1d7e>
ffffffffc0204780:	00002617          	auipc	a2,0x2
ffffffffc0204784:	79060613          	addi	a2,a2,1936 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0204788:	45f1                	li	a1,28
ffffffffc020478a:	00004517          	auipc	a0,0x4
ffffffffc020478e:	d3e50513          	addi	a0,a0,-706 # ffffffffc02084c8 <etext+0x1d66>
wait_queue_del(wait_queue_t *queue, wait_t *wait) {
ffffffffc0204792:	e406                	sd	ra,8(sp)
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
ffffffffc0204794:	cb7fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0204798 <wait_queue_first>:
    return listelm->next;
ffffffffc0204798:	651c                	ld	a5,8(a0)
}

wait_t *
wait_queue_first(wait_queue_t *queue) {
    list_entry_t *le = list_next(&(queue->wait_head));
    if (le != &(queue->wait_head)) {
ffffffffc020479a:	00f50563          	beq	a0,a5,ffffffffc02047a4 <wait_queue_first+0xc>
        return le2wait(le, wait_link);
ffffffffc020479e:	fe878513          	addi	a0,a5,-24
ffffffffc02047a2:	8082                	ret
    }
    return NULL;
ffffffffc02047a4:	4501                	li	a0,0
}
ffffffffc02047a6:	8082                	ret

ffffffffc02047a8 <wait_in_queue>:
    return list_empty(&(queue->wait_head));
}

bool
wait_in_queue(wait_t *wait) {
    return !list_empty(&(wait->wait_link));
ffffffffc02047a8:	711c                	ld	a5,32(a0)
ffffffffc02047aa:	0561                	addi	a0,a0,24
ffffffffc02047ac:	40a78533          	sub	a0,a5,a0
}
ffffffffc02047b0:	00a03533          	snez	a0,a0
ffffffffc02047b4:	8082                	ret

ffffffffc02047b6 <wakeup_wait>:

void
wakeup_wait(wait_queue_t *queue, wait_t *wait, uint32_t wakeup_flags, bool del) {
    if (del) {
ffffffffc02047b6:	e689                	bnez	a3,ffffffffc02047c0 <wakeup_wait+0xa>
        wait_queue_del(queue, wait);
    }
    wait->wakeup_flags = wakeup_flags;
    wakeup_proc(wait->proc);
ffffffffc02047b8:	6188                	ld	a0,0(a1)
    wait->wakeup_flags = wakeup_flags;
ffffffffc02047ba:	c590                	sw	a2,8(a1)
    wakeup_proc(wait->proc);
ffffffffc02047bc:	5b40106f          	j	ffffffffc0205d70 <wakeup_proc>
    return list->next == list;
ffffffffc02047c0:	7198                	ld	a4,32(a1)
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
ffffffffc02047c2:	01858793          	addi	a5,a1,24
ffffffffc02047c6:	00e78e63          	beq	a5,a4,ffffffffc02047e2 <wakeup_wait+0x2c>
ffffffffc02047ca:	6994                	ld	a3,16(a1)
ffffffffc02047cc:	00d51b63          	bne	a0,a3,ffffffffc02047e2 <wakeup_wait+0x2c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02047d0:	6d94                	ld	a3,24(a1)
    wakeup_proc(wait->proc);
ffffffffc02047d2:	6188                	ld	a0,0(a1)
    prev->next = next;
ffffffffc02047d4:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02047d6:	e314                	sd	a3,0(a4)
    elm->prev = elm->next = elm;
ffffffffc02047d8:	f19c                	sd	a5,32(a1)
ffffffffc02047da:	ed9c                	sd	a5,24(a1)
    wait->wakeup_flags = wakeup_flags;
ffffffffc02047dc:	c590                	sw	a2,8(a1)
    wakeup_proc(wait->proc);
ffffffffc02047de:	5920106f          	j	ffffffffc0205d70 <wakeup_proc>
wakeup_wait(wait_queue_t *queue, wait_t *wait, uint32_t wakeup_flags, bool del) {
ffffffffc02047e2:	1141                	addi	sp,sp,-16
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
ffffffffc02047e4:	00004697          	auipc	a3,0x4
ffffffffc02047e8:	cfc68693          	addi	a3,a3,-772 # ffffffffc02084e0 <etext+0x1d7e>
ffffffffc02047ec:	00002617          	auipc	a2,0x2
ffffffffc02047f0:	72460613          	addi	a2,a2,1828 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02047f4:	45f1                	li	a1,28
ffffffffc02047f6:	00004517          	auipc	a0,0x4
ffffffffc02047fa:	cd250513          	addi	a0,a0,-814 # ffffffffc02084c8 <etext+0x1d66>
wakeup_wait(wait_queue_t *queue, wait_t *wait, uint32_t wakeup_flags, bool del) {
ffffffffc02047fe:	e406                	sd	ra,8(sp)
    assert(!list_empty(&(wait->wait_link)) && wait->wait_queue == queue);
ffffffffc0204800:	c4bfb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0204804 <wait_current_set>:
    }
}

void
wait_current_set(wait_queue_t *queue, wait_t *wait, uint32_t wait_state) {
    assert(current != NULL);
ffffffffc0204804:	000c8797          	auipc	a5,0xc8
ffffffffc0204808:	b547b783          	ld	a5,-1196(a5) # ffffffffc02cc358 <current>
ffffffffc020480c:	c39d                	beqz	a5,ffffffffc0204832 <wait_current_set+0x2e>
    wait->wakeup_flags = WT_INTERRUPTED;
ffffffffc020480e:	80000737          	lui	a4,0x80000
ffffffffc0204812:	c598                	sw	a4,8(a1)
    list_init(&(wait->wait_link));
ffffffffc0204814:	01858713          	addi	a4,a1,24
ffffffffc0204818:	ed98                	sd	a4,24(a1)
    wait->proc = proc;
ffffffffc020481a:	e19c                	sd	a5,0(a1)
    wait_init(wait, current);
    current->state = PROC_SLEEPING;
    current->wait_state = wait_state;
ffffffffc020481c:	0ec7a623          	sw	a2,236(a5)
    current->state = PROC_SLEEPING;
ffffffffc0204820:	4605                	li	a2,1
    __list_add(elm, listelm->prev, listelm);
ffffffffc0204822:	6114                	ld	a3,0(a0)
ffffffffc0204824:	c390                	sw	a2,0(a5)
    wait->wait_queue = queue;
ffffffffc0204826:	e988                	sd	a0,16(a1)
    prev->next = next->prev = elm;
ffffffffc0204828:	e118                	sd	a4,0(a0)
ffffffffc020482a:	e698                	sd	a4,8(a3)
    elm->prev = prev;
ffffffffc020482c:	ed94                	sd	a3,24(a1)
    elm->next = next;
ffffffffc020482e:	f188                	sd	a0,32(a1)
ffffffffc0204830:	8082                	ret
wait_current_set(wait_queue_t *queue, wait_t *wait, uint32_t wait_state) {
ffffffffc0204832:	1141                	addi	sp,sp,-16
    assert(current != NULL);
ffffffffc0204834:	00004697          	auipc	a3,0x4
ffffffffc0204838:	cec68693          	addi	a3,a3,-788 # ffffffffc0208520 <etext+0x1dbe>
ffffffffc020483c:	00002617          	auipc	a2,0x2
ffffffffc0204840:	6d460613          	addi	a2,a2,1748 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0204844:	07400593          	li	a1,116
ffffffffc0204848:	00004517          	auipc	a0,0x4
ffffffffc020484c:	c8050513          	addi	a0,a0,-896 # ffffffffc02084c8 <etext+0x1d66>
wait_current_set(wait_queue_t *queue, wait_t *wait, uint32_t wait_state) {
ffffffffc0204850:	e406                	sd	ra,8(sp)
    assert(current != NULL);
ffffffffc0204852:	bf9fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0204856 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0204856:	8526                	mv	a0,s1
	jalr s0
ffffffffc0204858:	9402                	jalr	s0

	jal do_exit
ffffffffc020485a:	67a000ef          	jal	ffffffffc0204ed4 <do_exit>

ffffffffc020485e <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc020485e:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204860:	14800513          	li	a0,328
{
ffffffffc0204864:	e022                	sd	s0,0(sp)
ffffffffc0204866:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0204868:	c9cfd0ef          	jal	ffffffffc0201d04 <kmalloc>
ffffffffc020486c:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc020486e:	cd35                	beqz	a0,ffffffffc02048ea <alloc_proc+0x8c>
         *       struct trapframe *tf;                       // Trap frame for current interrupt
         *       uintptr_t pgdir;                            // the base addr of Page Directroy Table(PDT)
         *       uint32_t flags;                             // Process flag
         *       char name[PROC_NAME_LEN + 1];               // Process name
         */
        proc->state = PROC_UNINIT;
ffffffffc0204870:	57fd                	li	a5,-1
ffffffffc0204872:	1782                	slli	a5,a5,0x20
ffffffffc0204874:	e11c                	sd	a5,0(a0)
        proc->pid = -1;
        proc->runs = 0;
ffffffffc0204876:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc020487a:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc020487e:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0204882:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0204886:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc020488a:	07000613          	li	a2,112
ffffffffc020488e:	4581                	li	a1,0
ffffffffc0204890:	03050513          	addi	a0,a0,48
ffffffffc0204894:	6a5010ef          	jal	ffffffffc0206738 <memset>
        proc->tf = NULL;
        proc->pgdir = boot_pgdir_pa;
ffffffffc0204898:	000c8797          	auipc	a5,0xc8
ffffffffc020489c:	a887b783          	ld	a5,-1400(a5) # ffffffffc02cc320 <boot_pgdir_pa>
        proc->tf = NULL;
ffffffffc02048a0:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;
ffffffffc02048a4:	0a042823          	sw	zero,176(s0)
        proc->pgdir = boot_pgdir_pa;
ffffffffc02048a8:	f45c                	sd	a5,168(s0)
        memset(proc->name, 0, sizeof(proc->name));
ffffffffc02048aa:	0b440513          	addi	a0,s0,180
ffffffffc02048ae:	4641                	li	a2,16
ffffffffc02048b0:	4581                	li	a1,0
ffffffffc02048b2:	687010ef          	jal	ffffffffc0206738 <memset>
         *       skew_heap_entry_t lab6_run_pool;            // entry in the run pool (lab6 stride)
         *       uint32_t lab6_stride;                       // stride value (lab6 stride)
         *       uint32_t lab6_priority;                     // priority value (lab6 stride)
         */
        proc->rq = NULL;
        list_init(&(proc->run_link));
ffffffffc02048b6:	11040793          	addi	a5,s0,272
        proc->wait_state = 0;
ffffffffc02048ba:	0e042623          	sw	zero,236(s0)
        proc->cptr = proc->optr = proc->yptr = NULL;
ffffffffc02048be:	0e043c23          	sd	zero,248(s0)
ffffffffc02048c2:	10043023          	sd	zero,256(s0)
ffffffffc02048c6:	0e043823          	sd	zero,240(s0)
        proc->rq = NULL;
ffffffffc02048ca:	10043423          	sd	zero,264(s0)
        proc->time_slice = 0;
ffffffffc02048ce:	12042023          	sw	zero,288(s0)
        proc->lab6_run_pool.left = proc->lab6_run_pool.right = proc->lab6_run_pool.parent = NULL;
ffffffffc02048d2:	12043423          	sd	zero,296(s0)
ffffffffc02048d6:	12043c23          	sd	zero,312(s0)
ffffffffc02048da:	12043823          	sd	zero,304(s0)
        proc->lab6_stride = 0;
ffffffffc02048de:	14043023          	sd	zero,320(s0)
    elm->prev = elm->next = elm;
ffffffffc02048e2:	10f43c23          	sd	a5,280(s0)
ffffffffc02048e6:	10f43823          	sd	a5,272(s0)
        proc->lab6_priority = 0;

        
    }
    return proc;
}
ffffffffc02048ea:	60a2                	ld	ra,8(sp)
ffffffffc02048ec:	8522                	mv	a0,s0
ffffffffc02048ee:	6402                	ld	s0,0(sp)
ffffffffc02048f0:	0141                	addi	sp,sp,16
ffffffffc02048f2:	8082                	ret

ffffffffc02048f4 <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc02048f4:	000c8797          	auipc	a5,0xc8
ffffffffc02048f8:	a647b783          	ld	a5,-1436(a5) # ffffffffc02cc358 <current>
ffffffffc02048fc:	73c8                	ld	a0,160(a5)
ffffffffc02048fe:	e94fc06f          	j	ffffffffc0200f92 <forkrets>

ffffffffc0204902 <put_pgdir.isra.0>:
    return 0;
}

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm)
ffffffffc0204902:	1141                	addi	sp,sp,-16
ffffffffc0204904:	e406                	sd	ra,8(sp)
    return pa2page(PADDR(kva));
ffffffffc0204906:	c02007b7          	lui	a5,0xc0200
ffffffffc020490a:	02f56f63          	bltu	a0,a5,ffffffffc0204948 <put_pgdir.isra.0+0x46>
ffffffffc020490e:	000c8797          	auipc	a5,0xc8
ffffffffc0204912:	a227b783          	ld	a5,-1502(a5) # ffffffffc02cc330 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc0204916:	000c8717          	auipc	a4,0xc8
ffffffffc020491a:	a2273703          	ld	a4,-1502(a4) # ffffffffc02cc338 <npage>
    return pa2page(PADDR(kva));
ffffffffc020491e:	8d1d                	sub	a0,a0,a5
    if (PPN(pa) >= npage)
ffffffffc0204920:	00c55793          	srli	a5,a0,0xc
ffffffffc0204924:	02e7ff63          	bgeu	a5,a4,ffffffffc0204962 <put_pgdir.isra.0+0x60>
    return &pages[PPN(pa) - nbase];
ffffffffc0204928:	00005717          	auipc	a4,0x5
ffffffffc020492c:	dd873703          	ld	a4,-552(a4) # ffffffffc0209700 <nbase>
ffffffffc0204930:	000c8517          	auipc	a0,0xc8
ffffffffc0204934:	a1053503          	ld	a0,-1520(a0) # ffffffffc02cc340 <pages>
{
    free_page(kva2page(mm->pgdir));
}
ffffffffc0204938:	60a2                	ld	ra,8(sp)
ffffffffc020493a:	8f99                	sub	a5,a5,a4
ffffffffc020493c:	079a                	slli	a5,a5,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc020493e:	4585                	li	a1,1
ffffffffc0204940:	953e                	add	a0,a0,a5
}
ffffffffc0204942:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0204944:	dbefd06f          	j	ffffffffc0201f02 <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0204948:	86aa                	mv	a3,a0
ffffffffc020494a:	00003617          	auipc	a2,0x3
ffffffffc020494e:	cc660613          	addi	a2,a2,-826 # ffffffffc0207610 <etext+0xeae>
ffffffffc0204952:	07700593          	li	a1,119
ffffffffc0204956:	00003517          	auipc	a0,0x3
ffffffffc020495a:	c3a50513          	addi	a0,a0,-966 # ffffffffc0207590 <etext+0xe2e>
ffffffffc020495e:	aedfb0ef          	jal	ffffffffc020044a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204962:	00003617          	auipc	a2,0x3
ffffffffc0204966:	cd660613          	addi	a2,a2,-810 # ffffffffc0207638 <etext+0xed6>
ffffffffc020496a:	06900593          	li	a1,105
ffffffffc020496e:	00003517          	auipc	a0,0x3
ffffffffc0204972:	c2250513          	addi	a0,a0,-990 # ffffffffc0207590 <etext+0xe2e>
ffffffffc0204976:	ad5fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020497a <set_proc_name>:
{
ffffffffc020497a:	1101                	addi	sp,sp,-32
ffffffffc020497c:	e822                	sd	s0,16(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020497e:	0b450413          	addi	s0,a0,180
{
ffffffffc0204982:	e426                	sd	s1,8(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204984:	8522                	mv	a0,s0
{
ffffffffc0204986:	84ae                	mv	s1,a1
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204988:	4641                	li	a2,16
ffffffffc020498a:	4581                	li	a1,0
{
ffffffffc020498c:	ec06                	sd	ra,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020498e:	5ab010ef          	jal	ffffffffc0206738 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204992:	8522                	mv	a0,s0
}
ffffffffc0204994:	6442                	ld	s0,16(sp)
ffffffffc0204996:	60e2                	ld	ra,24(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204998:	85a6                	mv	a1,s1
}
ffffffffc020499a:	64a2                	ld	s1,8(sp)
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020499c:	463d                	li	a2,15
}
ffffffffc020499e:	6105                	addi	sp,sp,32
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02049a0:	5ab0106f          	j	ffffffffc020674a <memcpy>

ffffffffc02049a4 <proc_run>:
    if (proc != current)
ffffffffc02049a4:	000c8697          	auipc	a3,0xc8
ffffffffc02049a8:	9b46b683          	ld	a3,-1612(a3) # ffffffffc02cc358 <current>
ffffffffc02049ac:	04a68463          	beq	a3,a0,ffffffffc02049f4 <proc_run+0x50>
{
ffffffffc02049b0:	1101                	addi	sp,sp,-32
ffffffffc02049b2:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02049b4:	100027f3          	csrr	a5,sstatus
ffffffffc02049b8:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02049ba:	4601                	li	a2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02049bc:	ef8d                	bnez	a5,ffffffffc02049f6 <proc_run+0x52>
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned long pgdir)
{
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc02049be:	755c                	ld	a5,168(a0)
ffffffffc02049c0:	577d                	li	a4,-1
ffffffffc02049c2:	177e                	slli	a4,a4,0x3f
ffffffffc02049c4:	83b1                	srli	a5,a5,0xc
ffffffffc02049c6:	e032                	sd	a2,0(sp)
            current = proc;
ffffffffc02049c8:	000c8597          	auipc	a1,0xc8
ffffffffc02049cc:	98a5b823          	sd	a0,-1648(a1) # ffffffffc02cc358 <current>
ffffffffc02049d0:	8fd9                	or	a5,a5,a4
ffffffffc02049d2:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc02049d6:	03050593          	addi	a1,a0,48
ffffffffc02049da:	03068513          	addi	a0,a3,48
ffffffffc02049de:	1ee010ef          	jal	ffffffffc0205bcc <switch_to>
    if (flag) {
ffffffffc02049e2:	6602                	ld	a2,0(sp)
ffffffffc02049e4:	e601                	bnez	a2,ffffffffc02049ec <proc_run+0x48>
}
ffffffffc02049e6:	60e2                	ld	ra,24(sp)
ffffffffc02049e8:	6105                	addi	sp,sp,32
ffffffffc02049ea:	8082                	ret
ffffffffc02049ec:	60e2                	ld	ra,24(sp)
ffffffffc02049ee:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02049f0:	f09fb06f          	j	ffffffffc02008f8 <intr_enable>
ffffffffc02049f4:	8082                	ret
ffffffffc02049f6:	e42a                	sd	a0,8(sp)
ffffffffc02049f8:	e036                	sd	a3,0(sp)
        intr_disable();
ffffffffc02049fa:	f05fb0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc02049fe:	6522                	ld	a0,8(sp)
ffffffffc0204a00:	6682                	ld	a3,0(sp)
ffffffffc0204a02:	4605                	li	a2,1
ffffffffc0204a04:	bf6d                	j	ffffffffc02049be <proc_run+0x1a>

ffffffffc0204a06 <find_proc>:
    if (0 < pid && pid < MAX_PID)
ffffffffc0204a06:	6789                	lui	a5,0x2
ffffffffc0204a08:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204a0c:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x70ea>
ffffffffc0204a0e:	02e7ef63          	bltu	a5,a4,ffffffffc0204a4c <find_proc+0x46>
{
ffffffffc0204a12:	1101                	addi	sp,sp,-32
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204a14:	45a9                	li	a1,10
{
ffffffffc0204a16:	ec06                	sd	ra,24(sp)
ffffffffc0204a18:	e42a                	sd	a0,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204a1a:	089010ef          	jal	ffffffffc02062a2 <hash32>
ffffffffc0204a1e:	02051793          	slli	a5,a0,0x20
ffffffffc0204a22:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0204a26:	000c4797          	auipc	a5,0xc4
ffffffffc0204a2a:	88a78793          	addi	a5,a5,-1910 # ffffffffc02c82b0 <hash_list>
ffffffffc0204a2e:	96be                	add	a3,a3,a5
        while ((le = list_next(le)) != list)
ffffffffc0204a30:	6622                	ld	a2,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204a32:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0204a34:	a029                	j	ffffffffc0204a3e <find_proc+0x38>
            if (proc->pid == pid)
ffffffffc0204a36:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0204a3a:	00c70b63          	beq	a4,a2,ffffffffc0204a50 <find_proc+0x4a>
    return listelm->next;
ffffffffc0204a3e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204a40:	fef69be3          	bne	a3,a5,ffffffffc0204a36 <find_proc+0x30>
}
ffffffffc0204a44:	60e2                	ld	ra,24(sp)
    return NULL;
ffffffffc0204a46:	4501                	li	a0,0
}
ffffffffc0204a48:	6105                	addi	sp,sp,32
ffffffffc0204a4a:	8082                	ret
    return NULL;
ffffffffc0204a4c:	4501                	li	a0,0
}
ffffffffc0204a4e:	8082                	ret
ffffffffc0204a50:	60e2                	ld	ra,24(sp)
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204a52:	f2878513          	addi	a0,a5,-216
}
ffffffffc0204a56:	6105                	addi	sp,sp,32
ffffffffc0204a58:	8082                	ret

ffffffffc0204a5a <do_fork>:
 */
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf)
{
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS)
ffffffffc0204a5a:	000c8717          	auipc	a4,0xc8
ffffffffc0204a5e:	8fa72703          	lw	a4,-1798(a4) # ffffffffc02cc354 <nr_process>
ffffffffc0204a62:	6785                	lui	a5,0x1
ffffffffc0204a64:	36f75763          	bge	a4,a5,ffffffffc0204dd2 <do_fork+0x378>
{
ffffffffc0204a68:	7159                	addi	sp,sp,-112
ffffffffc0204a6a:	f0a2                	sd	s0,96(sp)
ffffffffc0204a6c:	eca6                	sd	s1,88(sp)
ffffffffc0204a6e:	e8ca                	sd	s2,80(sp)
ffffffffc0204a70:	ec66                	sd	s9,24(sp)
ffffffffc0204a72:	f486                	sd	ra,104(sp)
ffffffffc0204a74:	892e                	mv	s2,a1
ffffffffc0204a76:	84b2                	mv	s1,a2
ffffffffc0204a78:	8caa                	mv	s9,a0
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid

    if ((proc = alloc_proc()) == NULL) {
ffffffffc0204a7a:	de5ff0ef          	jal	ffffffffc020485e <alloc_proc>
ffffffffc0204a7e:	842a                	mv	s0,a0
ffffffffc0204a80:	34050163          	beqz	a0,ffffffffc0204dc2 <do_fork+0x368>
        goto fork_out;
    }
    proc->parent = current;
ffffffffc0204a84:	fc56                	sd	s5,56(sp)
ffffffffc0204a86:	000c8a97          	auipc	s5,0xc8
ffffffffc0204a8a:	8d2a8a93          	addi	s5,s5,-1838 # ffffffffc02cc358 <current>
ffffffffc0204a8e:	000ab783          	ld	a5,0(s5)
    assert(current->wait_state == 0);
ffffffffc0204a92:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_softint_out_size-0x7ffc>
    proc->parent = current;
ffffffffc0204a96:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc0204a98:	32071f63          	bnez	a4,ffffffffc0204dd6 <do_fork+0x37c>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0204a9c:	4509                	li	a0,2
ffffffffc0204a9e:	c2afd0ef          	jal	ffffffffc0201ec8 <alloc_pages>
    if (page != NULL)
ffffffffc0204aa2:	30050c63          	beqz	a0,ffffffffc0204dba <do_fork+0x360>
    return page - pages + nbase;
ffffffffc0204aa6:	f85a                	sd	s6,48(sp)
ffffffffc0204aa8:	000c8b17          	auipc	s6,0xc8
ffffffffc0204aac:	898b0b13          	addi	s6,s6,-1896 # ffffffffc02cc340 <pages>
ffffffffc0204ab0:	000b3783          	ld	a5,0(s6)
ffffffffc0204ab4:	e4ce                	sd	s3,72(sp)
ffffffffc0204ab6:	00005997          	auipc	s3,0x5
ffffffffc0204aba:	c4a9b983          	ld	s3,-950(s3) # ffffffffc0209700 <nbase>
ffffffffc0204abe:	40f506b3          	sub	a3,a0,a5
ffffffffc0204ac2:	f45e                	sd	s7,40(sp)
    return KADDR(page2pa(page));
ffffffffc0204ac4:	000c8b97          	auipc	s7,0xc8
ffffffffc0204ac8:	874b8b93          	addi	s7,s7,-1932 # ffffffffc02cc338 <npage>
    return page - pages + nbase;
ffffffffc0204acc:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204ace:	57fd                	li	a5,-1
ffffffffc0204ad0:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc0204ad4:	96ce                	add	a3,a3,s3
    return KADDR(page2pa(page));
ffffffffc0204ad6:	83b1                	srli	a5,a5,0xc
ffffffffc0204ad8:	00f6f633          	and	a2,a3,a5
ffffffffc0204adc:	e0d2                	sd	s4,64(sp)
ffffffffc0204ade:	f062                	sd	s8,32(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ae0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204ae2:	34e67b63          	bgeu	a2,a4,ffffffffc0204e38 <do_fork+0x3de>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0204ae6:	000ab603          	ld	a2,0(s5)
ffffffffc0204aea:	000c8c17          	auipc	s8,0xc8
ffffffffc0204aee:	846c0c13          	addi	s8,s8,-1978 # ffffffffc02cc330 <va_pa_offset>
ffffffffc0204af2:	000c3703          	ld	a4,0(s8)
ffffffffc0204af6:	02863a03          	ld	s4,40(a2)
ffffffffc0204afa:	96ba                	add	a3,a3,a4
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204afc:	e814                	sd	a3,16(s0)
    if (oldmm == NULL)
ffffffffc0204afe:	020a0863          	beqz	s4,ffffffffc0204b2e <do_fork+0xd4>
    if (clone_flags & CLONE_VM)
ffffffffc0204b02:	100cf713          	andi	a4,s9,256
ffffffffc0204b06:	18070a63          	beqz	a4,ffffffffc0204c9a <do_fork+0x240>
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc0204b0a:	030a2703          	lw	a4,48(s4)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204b0e:	018a3783          	ld	a5,24(s4)
ffffffffc0204b12:	c02006b7          	lui	a3,0xc0200
ffffffffc0204b16:	2705                	addiw	a4,a4,1
ffffffffc0204b18:	02ea2823          	sw	a4,48(s4)
    proc->mm = mm;
ffffffffc0204b1c:	03443423          	sd	s4,40(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204b20:	2ed7ee63          	bltu	a5,a3,ffffffffc0204e1c <do_fork+0x3c2>
ffffffffc0204b24:	000c3703          	ld	a4,0(s8)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204b28:	6814                	ld	a3,16(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204b2a:	8f99                	sub	a5,a5,a4
ffffffffc0204b2c:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204b2e:	6789                	lui	a5,0x2
ffffffffc0204b30:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_softint_out_size-0x7208>
ffffffffc0204b34:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0204b36:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204b38:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0204b3a:	87b6                	mv	a5,a3
ffffffffc0204b3c:	12048713          	addi	a4,s1,288
ffffffffc0204b40:	6a0c                	ld	a1,16(a2)
ffffffffc0204b42:	00063803          	ld	a6,0(a2)
ffffffffc0204b46:	6608                	ld	a0,8(a2)
ffffffffc0204b48:	eb8c                	sd	a1,16(a5)
ffffffffc0204b4a:	0107b023          	sd	a6,0(a5)
ffffffffc0204b4e:	e788                	sd	a0,8(a5)
ffffffffc0204b50:	6e0c                	ld	a1,24(a2)
ffffffffc0204b52:	02060613          	addi	a2,a2,32
ffffffffc0204b56:	02078793          	addi	a5,a5,32
ffffffffc0204b5a:	feb7bc23          	sd	a1,-8(a5)
ffffffffc0204b5e:	fee611e3          	bne	a2,a4,ffffffffc0204b40 <do_fork+0xe6>
    proc->tf->gpr.a0 = 0;
ffffffffc0204b62:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x6>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204b66:	1a090c63          	beqz	s2,ffffffffc0204d1e <do_fork+0x2c4>
ffffffffc0204b6a:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204b6e:	00000797          	auipc	a5,0x0
ffffffffc0204b72:	d8678793          	addi	a5,a5,-634 # ffffffffc02048f4 <forkret>
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204b76:	fc14                	sd	a3,56(s0)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204b78:	f81c                	sd	a5,48(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204b7a:	100027f3          	csrr	a5,sstatus
ffffffffc0204b7e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204b80:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204b82:	1a079d63          	bnez	a5,ffffffffc0204d3c <do_fork+0x2e2>
    if (++last_pid >= MAX_PID)
ffffffffc0204b86:	000c3517          	auipc	a0,0xc3
ffffffffc0204b8a:	1be52503          	lw	a0,446(a0) # ffffffffc02c7d44 <last_pid.1>
ffffffffc0204b8e:	6789                	lui	a5,0x2
ffffffffc0204b90:	2505                	addiw	a0,a0,1
ffffffffc0204b92:	000c3717          	auipc	a4,0xc3
ffffffffc0204b96:	1aa72923          	sw	a0,434(a4) # ffffffffc02c7d44 <last_pid.1>
ffffffffc0204b9a:	1cf55063          	bge	a0,a5,ffffffffc0204d5a <do_fork+0x300>
    if (last_pid >= next_safe)
ffffffffc0204b9e:	000c3797          	auipc	a5,0xc3
ffffffffc0204ba2:	1a27a783          	lw	a5,418(a5) # ffffffffc02c7d40 <next_safe.0>
ffffffffc0204ba6:	000c7497          	auipc	s1,0xc7
ffffffffc0204baa:	70a48493          	addi	s1,s1,1802 # ffffffffc02cc2b0 <proc_list>
ffffffffc0204bae:	06f54563          	blt	a0,a5,ffffffffc0204c18 <do_fork+0x1be>
ffffffffc0204bb2:	000c7497          	auipc	s1,0xc7
ffffffffc0204bb6:	6fe48493          	addi	s1,s1,1790 # ffffffffc02cc2b0 <proc_list>
ffffffffc0204bba:	0084b883          	ld	a7,8(s1)
        next_safe = MAX_PID;
ffffffffc0204bbe:	6789                	lui	a5,0x2
ffffffffc0204bc0:	000c3717          	auipc	a4,0xc3
ffffffffc0204bc4:	18f72023          	sw	a5,384(a4) # ffffffffc02c7d40 <next_safe.0>
ffffffffc0204bc8:	86aa                	mv	a3,a0
ffffffffc0204bca:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc0204bcc:	04988063          	beq	a7,s1,ffffffffc0204c0c <do_fork+0x1b2>
ffffffffc0204bd0:	882e                	mv	a6,a1
ffffffffc0204bd2:	87c6                	mv	a5,a7
ffffffffc0204bd4:	6609                	lui	a2,0x2
ffffffffc0204bd6:	a811                	j	ffffffffc0204bea <do_fork+0x190>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc0204bd8:	00e6d663          	bge	a3,a4,ffffffffc0204be4 <do_fork+0x18a>
ffffffffc0204bdc:	00c75463          	bge	a4,a2,ffffffffc0204be4 <do_fork+0x18a>
                next_safe = proc->pid;
ffffffffc0204be0:	863a                	mv	a2,a4
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc0204be2:	4805                	li	a6,1
ffffffffc0204be4:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204be6:	00978d63          	beq	a5,s1,ffffffffc0204c00 <do_fork+0x1a6>
            if (proc->pid == last_pid)
ffffffffc0204bea:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_softint_out_size-0x71ac>
ffffffffc0204bee:	fee695e3          	bne	a3,a4,ffffffffc0204bd8 <do_fork+0x17e>
                if (++last_pid >= next_safe)
ffffffffc0204bf2:	2685                	addiw	a3,a3,1
ffffffffc0204bf4:	1cc6d963          	bge	a3,a2,ffffffffc0204dc6 <do_fork+0x36c>
ffffffffc0204bf8:	679c                	ld	a5,8(a5)
ffffffffc0204bfa:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc0204bfc:	fe9797e3          	bne	a5,s1,ffffffffc0204bea <do_fork+0x190>
ffffffffc0204c00:	00080663          	beqz	a6,ffffffffc0204c0c <do_fork+0x1b2>
ffffffffc0204c04:	000c3797          	auipc	a5,0xc3
ffffffffc0204c08:	12c7ae23          	sw	a2,316(a5) # ffffffffc02c7d40 <next_safe.0>
ffffffffc0204c0c:	c591                	beqz	a1,ffffffffc0204c18 <do_fork+0x1be>
ffffffffc0204c0e:	000c3797          	auipc	a5,0xc3
ffffffffc0204c12:	12d7ab23          	sw	a3,310(a5) # ffffffffc02c7d44 <last_pid.1>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc0204c16:	8536                	mv	a0,a3
    copy_thread(proc, stack, tf);

    bool intr_flag;
    local_intr_save(intr_flag);
    {
        proc->pid = get_pid();
ffffffffc0204c18:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204c1a:	45a9                	li	a1,10
ffffffffc0204c1c:	686010ef          	jal	ffffffffc02062a2 <hash32>
ffffffffc0204c20:	02051793          	slli	a5,a0,0x20
ffffffffc0204c24:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204c28:	000c3797          	auipc	a5,0xc3
ffffffffc0204c2c:	68878793          	addi	a5,a5,1672 # ffffffffc02c82b0 <hash_list>
ffffffffc0204c30:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc0204c32:	6518                	ld	a4,8(a0)
ffffffffc0204c34:	0d840793          	addi	a5,s0,216
ffffffffc0204c38:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc0204c3a:	e31c                	sd	a5,0(a4)
ffffffffc0204c3c:	e51c                	sd	a5,8(a0)
    elm->next = next;
ffffffffc0204c3e:	f078                	sd	a4,224(s0)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0204c40:	0c840793          	addi	a5,s0,200
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204c44:	7018                	ld	a4,32(s0)
    elm->prev = prev;
ffffffffc0204c46:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc0204c48:	e21c                	sd	a5,0(a2)
    proc->yptr = NULL;
ffffffffc0204c4a:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204c4e:	7b74                	ld	a3,240(a4)
ffffffffc0204c50:	e49c                	sd	a5,8(s1)
    elm->next = next;
ffffffffc0204c52:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc0204c54:	e464                	sd	s1,200(s0)
ffffffffc0204c56:	10d43023          	sd	a3,256(s0)
ffffffffc0204c5a:	c299                	beqz	a3,ffffffffc0204c60 <do_fork+0x206>
        proc->optr->yptr = proc;
ffffffffc0204c5c:	fee0                	sd	s0,248(a3)
    proc->parent->cptr = proc;
ffffffffc0204c5e:	7018                	ld	a4,32(s0)
    nr_process++;
ffffffffc0204c60:	000c7797          	auipc	a5,0xc7
ffffffffc0204c64:	6f47a783          	lw	a5,1780(a5) # ffffffffc02cc354 <nr_process>
    proc->parent->cptr = proc;
ffffffffc0204c68:	fb60                	sd	s0,240(a4)
    nr_process++;
ffffffffc0204c6a:	2785                	addiw	a5,a5,1
ffffffffc0204c6c:	000c7717          	auipc	a4,0xc7
ffffffffc0204c70:	6ef72423          	sw	a5,1768(a4) # ffffffffc02cc354 <nr_process>
    if (flag) {
ffffffffc0204c74:	0e091963          	bnez	s2,ffffffffc0204d66 <do_fork+0x30c>
        hash_proc(proc);
        set_links(proc);
    }
    local_intr_restore(intr_flag);

    wakeup_proc(proc);
ffffffffc0204c78:	8522                	mv	a0,s0
ffffffffc0204c7a:	0f6010ef          	jal	ffffffffc0205d70 <wakeup_proc>

    ret = proc->pid;
ffffffffc0204c7e:	4048                	lw	a0,4(s0)
ffffffffc0204c80:	69a6                	ld	s3,72(sp)
ffffffffc0204c82:	6a06                	ld	s4,64(sp)
ffffffffc0204c84:	7ae2                	ld	s5,56(sp)
ffffffffc0204c86:	7b42                	ld	s6,48(sp)
ffffffffc0204c88:	7ba2                	ld	s7,40(sp)
ffffffffc0204c8a:	7c02                	ld	s8,32(sp)
bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
ffffffffc0204c8c:	70a6                	ld	ra,104(sp)
ffffffffc0204c8e:	7406                	ld	s0,96(sp)
ffffffffc0204c90:	64e6                	ld	s1,88(sp)
ffffffffc0204c92:	6946                	ld	s2,80(sp)
ffffffffc0204c94:	6ce2                	ld	s9,24(sp)
ffffffffc0204c96:	6165                	addi	sp,sp,112
ffffffffc0204c98:	8082                	ret
    if ((mm = mm_create()) == NULL)
ffffffffc0204c9a:	9f5fe0ef          	jal	ffffffffc020368e <mm_create>
ffffffffc0204c9e:	8caa                	mv	s9,a0
ffffffffc0204ca0:	0e050163          	beqz	a0,ffffffffc0204d82 <do_fork+0x328>
    if ((page = alloc_page()) == NULL)
ffffffffc0204ca4:	4505                	li	a0,1
ffffffffc0204ca6:	a22fd0ef          	jal	ffffffffc0201ec8 <alloc_pages>
ffffffffc0204caa:	c969                	beqz	a0,ffffffffc0204d7c <do_fork+0x322>
    return page - pages + nbase;
ffffffffc0204cac:	000b3683          	ld	a3,0(s6)
    return KADDR(page2pa(page));
ffffffffc0204cb0:	57fd                	li	a5,-1
ffffffffc0204cb2:	000bb703          	ld	a4,0(s7)
    return page - pages + nbase;
ffffffffc0204cb6:	40d506b3          	sub	a3,a0,a3
ffffffffc0204cba:	8699                	srai	a3,a3,0x6
ffffffffc0204cbc:	96ce                	add	a3,a3,s3
    return KADDR(page2pa(page));
ffffffffc0204cbe:	83b1                	srli	a5,a5,0xc
ffffffffc0204cc0:	8ff5                	and	a5,a5,a3
ffffffffc0204cc2:	e86a                	sd	s10,16(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc0204cc4:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204cc6:	1ae7f363          	bgeu	a5,a4,ffffffffc0204e6c <do_fork+0x412>
ffffffffc0204cca:	000c3783          	ld	a5,0(s8)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204cce:	000c7597          	auipc	a1,0xc7
ffffffffc0204cd2:	65a5b583          	ld	a1,1626(a1) # ffffffffc02cc328 <boot_pgdir_va>
ffffffffc0204cd6:	6605                	lui	a2,0x1
ffffffffc0204cd8:	96be                	add	a3,a3,a5
ffffffffc0204cda:	8536                	mv	a0,a3
ffffffffc0204cdc:	e436                	sd	a3,8(sp)
ffffffffc0204cde:	26d010ef          	jal	ffffffffc020674a <memcpy>
    mm->pgdir = pgdir;
ffffffffc0204ce2:	66a2                	ld	a3,8(sp)
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        down(&(mm->mm_sem));
ffffffffc0204ce4:	038a0513          	addi	a0,s4,56
ffffffffc0204ce8:	038a0d13          	addi	s10,s4,56
ffffffffc0204cec:	00dcbc23          	sd	a3,24(s9) # 200018 <_binary_obj___user_matrix_out_size+0x1f4930>
ffffffffc0204cf0:	a35ff0ef          	jal	ffffffffc0204724 <down>
        if (current != NULL)
ffffffffc0204cf4:	000ab783          	ld	a5,0(s5)
ffffffffc0204cf8:	c781                	beqz	a5,ffffffffc0204d00 <do_fork+0x2a6>
        {
            mm->locked_by = current->pid;
ffffffffc0204cfa:	43dc                	lw	a5,4(a5)
ffffffffc0204cfc:	04fa2823          	sw	a5,80(s4)
        ret = dup_mmap(mm, oldmm);
ffffffffc0204d00:	85d2                	mv	a1,s4
ffffffffc0204d02:	8566                	mv	a0,s9
ffffffffc0204d04:	bf5fe0ef          	jal	ffffffffc02038f8 <dup_mmap>
ffffffffc0204d08:	8aaa                	mv	s5,a0
static inline void
unlock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        up(&(mm->mm_sem));
ffffffffc0204d0a:	856a                	mv	a0,s10
ffffffffc0204d0c:	a15ff0ef          	jal	ffffffffc0204720 <up>
        mm->locked_by = 0;
ffffffffc0204d10:	040a2823          	sw	zero,80(s4)
    if ((mm = mm_create()) == NULL)
ffffffffc0204d14:	8a66                	mv	s4,s9
    if (ret != 0)
ffffffffc0204d16:	040a9b63          	bnez	s5,ffffffffc0204d6c <do_fork+0x312>
ffffffffc0204d1a:	6d42                	ld	s10,16(sp)
ffffffffc0204d1c:	b3fd                	j	ffffffffc0204b0a <do_fork+0xb0>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204d1e:	8936                	mv	s2,a3
ffffffffc0204d20:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204d24:	00000797          	auipc	a5,0x0
ffffffffc0204d28:	bd078793          	addi	a5,a5,-1072 # ffffffffc02048f4 <forkret>
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0204d2c:	fc14                	sd	a3,56(s0)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204d2e:	f81c                	sd	a5,48(s0)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204d30:	100027f3          	csrr	a5,sstatus
ffffffffc0204d34:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204d36:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204d38:	e40787e3          	beqz	a5,ffffffffc0204b86 <do_fork+0x12c>
        intr_disable();
ffffffffc0204d3c:	bc3fb0ef          	jal	ffffffffc02008fe <intr_disable>
    if (++last_pid >= MAX_PID)
ffffffffc0204d40:	000c3517          	auipc	a0,0xc3
ffffffffc0204d44:	00452503          	lw	a0,4(a0) # ffffffffc02c7d44 <last_pid.1>
ffffffffc0204d48:	6789                	lui	a5,0x2
        return 1;
ffffffffc0204d4a:	4905                	li	s2,1
ffffffffc0204d4c:	2505                	addiw	a0,a0,1
ffffffffc0204d4e:	000c3717          	auipc	a4,0xc3
ffffffffc0204d52:	fea72b23          	sw	a0,-10(a4) # ffffffffc02c7d44 <last_pid.1>
ffffffffc0204d56:	e4f544e3          	blt	a0,a5,ffffffffc0204b9e <do_fork+0x144>
        last_pid = 1;
ffffffffc0204d5a:	4505                	li	a0,1
ffffffffc0204d5c:	000c3797          	auipc	a5,0xc3
ffffffffc0204d60:	fea7a423          	sw	a0,-24(a5) # ffffffffc02c7d44 <last_pid.1>
        goto inside;
ffffffffc0204d64:	b5b9                	j	ffffffffc0204bb2 <do_fork+0x158>
        intr_enable();
ffffffffc0204d66:	b93fb0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0204d6a:	b739                	j	ffffffffc0204c78 <do_fork+0x21e>
    exit_mmap(mm);
ffffffffc0204d6c:	8566                	mv	a0,s9
ffffffffc0204d6e:	c23fe0ef          	jal	ffffffffc0203990 <exit_mmap>
    put_pgdir(mm);
ffffffffc0204d72:	018cb503          	ld	a0,24(s9)
ffffffffc0204d76:	b8dff0ef          	jal	ffffffffc0204902 <put_pgdir.isra.0>
ffffffffc0204d7a:	6d42                	ld	s10,16(sp)
    mm_destroy(mm);
ffffffffc0204d7c:	8566                	mv	a0,s9
ffffffffc0204d7e:	a5dfe0ef          	jal	ffffffffc02037da <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204d82:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0204d84:	c02007b7          	lui	a5,0xc0200
ffffffffc0204d88:	0cf6e563          	bltu	a3,a5,ffffffffc0204e52 <do_fork+0x3f8>
ffffffffc0204d8c:	000c3783          	ld	a5,0(s8)
    if (PPN(pa) >= npage)
ffffffffc0204d90:	000bb703          	ld	a4,0(s7)
    return pa2page(PADDR(kva));
ffffffffc0204d94:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage)
ffffffffc0204d98:	83b1                	srli	a5,a5,0xc
ffffffffc0204d9a:	06e7f463          	bgeu	a5,a4,ffffffffc0204e02 <do_fork+0x3a8>
    return &pages[PPN(pa) - nbase];
ffffffffc0204d9e:	000b3503          	ld	a0,0(s6)
ffffffffc0204da2:	413787b3          	sub	a5,a5,s3
ffffffffc0204da6:	079a                	slli	a5,a5,0x6
ffffffffc0204da8:	953e                	add	a0,a0,a5
ffffffffc0204daa:	4589                	li	a1,2
ffffffffc0204dac:	956fd0ef          	jal	ffffffffc0201f02 <free_pages>
}
ffffffffc0204db0:	69a6                	ld	s3,72(sp)
ffffffffc0204db2:	6a06                	ld	s4,64(sp)
ffffffffc0204db4:	7b42                	ld	s6,48(sp)
ffffffffc0204db6:	7ba2                	ld	s7,40(sp)
ffffffffc0204db8:	7c02                	ld	s8,32(sp)
    kfree(proc);
ffffffffc0204dba:	8522                	mv	a0,s0
ffffffffc0204dbc:	feffc0ef          	jal	ffffffffc0201daa <kfree>
ffffffffc0204dc0:	7ae2                	ld	s5,56(sp)
    ret = -E_NO_MEM;
ffffffffc0204dc2:	5571                	li	a0,-4
    return ret;
ffffffffc0204dc4:	b5e1                	j	ffffffffc0204c8c <do_fork+0x232>
                    if (last_pid >= MAX_PID)
ffffffffc0204dc6:	6789                	lui	a5,0x2
ffffffffc0204dc8:	00f6c363          	blt	a3,a5,ffffffffc0204dce <do_fork+0x374>
                        last_pid = 1;
ffffffffc0204dcc:	4685                	li	a3,1
                    goto repeat;
ffffffffc0204dce:	4585                	li	a1,1
ffffffffc0204dd0:	bbf5                	j	ffffffffc0204bcc <do_fork+0x172>
    int ret = -E_NO_FREE_PROC;
ffffffffc0204dd2:	556d                	li	a0,-5
}
ffffffffc0204dd4:	8082                	ret
    assert(current->wait_state == 0);
ffffffffc0204dd6:	00003697          	auipc	a3,0x3
ffffffffc0204dda:	75a68693          	addi	a3,a3,1882 # ffffffffc0208530 <etext+0x1dce>
ffffffffc0204dde:	00002617          	auipc	a2,0x2
ffffffffc0204de2:	13260613          	addi	a2,a2,306 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0204de6:	1e600593          	li	a1,486
ffffffffc0204dea:	00003517          	auipc	a0,0x3
ffffffffc0204dee:	76650513          	addi	a0,a0,1894 # ffffffffc0208550 <etext+0x1dee>
ffffffffc0204df2:	e4ce                	sd	s3,72(sp)
ffffffffc0204df4:	e0d2                	sd	s4,64(sp)
ffffffffc0204df6:	f85a                	sd	s6,48(sp)
ffffffffc0204df8:	f45e                	sd	s7,40(sp)
ffffffffc0204dfa:	f062                	sd	s8,32(sp)
ffffffffc0204dfc:	e86a                	sd	s10,16(sp)
ffffffffc0204dfe:	e4cfb0ef          	jal	ffffffffc020044a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204e02:	00003617          	auipc	a2,0x3
ffffffffc0204e06:	83660613          	addi	a2,a2,-1994 # ffffffffc0207638 <etext+0xed6>
ffffffffc0204e0a:	06900593          	li	a1,105
ffffffffc0204e0e:	00002517          	auipc	a0,0x2
ffffffffc0204e12:	78250513          	addi	a0,a0,1922 # ffffffffc0207590 <etext+0xe2e>
ffffffffc0204e16:	e86a                	sd	s10,16(sp)
ffffffffc0204e18:	e32fb0ef          	jal	ffffffffc020044a <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204e1c:	86be                	mv	a3,a5
ffffffffc0204e1e:	00002617          	auipc	a2,0x2
ffffffffc0204e22:	7f260613          	addi	a2,a2,2034 # ffffffffc0207610 <etext+0xeae>
ffffffffc0204e26:	19f00593          	li	a1,415
ffffffffc0204e2a:	00003517          	auipc	a0,0x3
ffffffffc0204e2e:	72650513          	addi	a0,a0,1830 # ffffffffc0208550 <etext+0x1dee>
ffffffffc0204e32:	e86a                	sd	s10,16(sp)
ffffffffc0204e34:	e16fb0ef          	jal	ffffffffc020044a <__panic>
    return KADDR(page2pa(page));
ffffffffc0204e38:	00002617          	auipc	a2,0x2
ffffffffc0204e3c:	73060613          	addi	a2,a2,1840 # ffffffffc0207568 <etext+0xe06>
ffffffffc0204e40:	07100593          	li	a1,113
ffffffffc0204e44:	00002517          	auipc	a0,0x2
ffffffffc0204e48:	74c50513          	addi	a0,a0,1868 # ffffffffc0207590 <etext+0xe2e>
ffffffffc0204e4c:	e86a                	sd	s10,16(sp)
ffffffffc0204e4e:	dfcfb0ef          	jal	ffffffffc020044a <__panic>
    return pa2page(PADDR(kva));
ffffffffc0204e52:	00002617          	auipc	a2,0x2
ffffffffc0204e56:	7be60613          	addi	a2,a2,1982 # ffffffffc0207610 <etext+0xeae>
ffffffffc0204e5a:	07700593          	li	a1,119
ffffffffc0204e5e:	00002517          	auipc	a0,0x2
ffffffffc0204e62:	73250513          	addi	a0,a0,1842 # ffffffffc0207590 <etext+0xe2e>
ffffffffc0204e66:	e86a                	sd	s10,16(sp)
ffffffffc0204e68:	de2fb0ef          	jal	ffffffffc020044a <__panic>
    return KADDR(page2pa(page));
ffffffffc0204e6c:	00002617          	auipc	a2,0x2
ffffffffc0204e70:	6fc60613          	addi	a2,a2,1788 # ffffffffc0207568 <etext+0xe06>
ffffffffc0204e74:	07100593          	li	a1,113
ffffffffc0204e78:	00002517          	auipc	a0,0x2
ffffffffc0204e7c:	71850513          	addi	a0,a0,1816 # ffffffffc0207590 <etext+0xe2e>
ffffffffc0204e80:	dcafb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0204e84 <kernel_thread>:
{
ffffffffc0204e84:	7129                	addi	sp,sp,-320
ffffffffc0204e86:	fa22                	sd	s0,304(sp)
ffffffffc0204e88:	f626                	sd	s1,296(sp)
ffffffffc0204e8a:	f24a                	sd	s2,288(sp)
ffffffffc0204e8c:	842a                	mv	s0,a0
ffffffffc0204e8e:	84ae                	mv	s1,a1
ffffffffc0204e90:	8932                	mv	s2,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204e92:	850a                	mv	a0,sp
ffffffffc0204e94:	12000613          	li	a2,288
ffffffffc0204e98:	4581                	li	a1,0
{
ffffffffc0204e9a:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc0204e9c:	09d010ef          	jal	ffffffffc0206738 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc0204ea0:	e0a2                	sd	s0,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc0204ea2:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204ea4:	100027f3          	csrr	a5,sstatus
ffffffffc0204ea8:	edd7f793          	andi	a5,a5,-291
ffffffffc0204eac:	1207e793          	ori	a5,a5,288
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204eb0:	860a                	mv	a2,sp
ffffffffc0204eb2:	10096513          	ori	a0,s2,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204eb6:	00000717          	auipc	a4,0x0
ffffffffc0204eba:	9a070713          	addi	a4,a4,-1632 # ffffffffc0204856 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204ebe:	4581                	li	a1,0
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc0204ec0:	e23e                	sd	a5,256(sp)
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc0204ec2:	e63a                	sd	a4,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204ec4:	b97ff0ef          	jal	ffffffffc0204a5a <do_fork>
}
ffffffffc0204ec8:	70f2                	ld	ra,312(sp)
ffffffffc0204eca:	7452                	ld	s0,304(sp)
ffffffffc0204ecc:	74b2                	ld	s1,296(sp)
ffffffffc0204ece:	7912                	ld	s2,288(sp)
ffffffffc0204ed0:	6131                	addi	sp,sp,320
ffffffffc0204ed2:	8082                	ret

ffffffffc0204ed4 <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int do_exit(int error_code)
{
ffffffffc0204ed4:	7179                	addi	sp,sp,-48
ffffffffc0204ed6:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc0204ed8:	000c7417          	auipc	s0,0xc7
ffffffffc0204edc:	48040413          	addi	s0,s0,1152 # ffffffffc02cc358 <current>
ffffffffc0204ee0:	601c                	ld	a5,0(s0)
ffffffffc0204ee2:	000c7717          	auipc	a4,0xc7
ffffffffc0204ee6:	48673703          	ld	a4,1158(a4) # ffffffffc02cc368 <idleproc>
{
ffffffffc0204eea:	f406                	sd	ra,40(sp)
ffffffffc0204eec:	ec26                	sd	s1,24(sp)
    if (current == idleproc)
ffffffffc0204eee:	0ce78b63          	beq	a5,a4,ffffffffc0204fc4 <do_exit+0xf0>
    {
        panic("idleproc exit.\n");
    }
    if (current == initproc)
ffffffffc0204ef2:	000c7497          	auipc	s1,0xc7
ffffffffc0204ef6:	46e48493          	addi	s1,s1,1134 # ffffffffc02cc360 <initproc>
ffffffffc0204efa:	6098                	ld	a4,0(s1)
ffffffffc0204efc:	e84a                	sd	s2,16(sp)
ffffffffc0204efe:	0ee78c63          	beq	a5,a4,ffffffffc0204ff6 <do_exit+0x122>
    {
        panic("initproc exit.\n");
    }
    struct mm_struct *mm = current->mm;
ffffffffc0204f02:	7798                	ld	a4,40(a5)
ffffffffc0204f04:	892a                	mv	s2,a0
    if (mm != NULL)
ffffffffc0204f06:	c315                	beqz	a4,ffffffffc0204f2a <do_exit+0x56>
ffffffffc0204f08:	000c7797          	auipc	a5,0xc7
ffffffffc0204f0c:	4187b783          	ld	a5,1048(a5) # ffffffffc02cc320 <boot_pgdir_pa>
ffffffffc0204f10:	56fd                	li	a3,-1
ffffffffc0204f12:	16fe                	slli	a3,a3,0x3f
ffffffffc0204f14:	83b1                	srli	a5,a5,0xc
ffffffffc0204f16:	8fd5                	or	a5,a5,a3
ffffffffc0204f18:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0204f1c:	5b1c                	lw	a5,48(a4)
ffffffffc0204f1e:	37fd                	addiw	a5,a5,-1
ffffffffc0204f20:	db1c                	sw	a5,48(a4)
    {
        lsatp(boot_pgdir_pa);
        if (mm_count_dec(mm) == 0)
ffffffffc0204f22:	cfd5                	beqz	a5,ffffffffc0204fde <do_exit+0x10a>
        {
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
        }
        current->mm = NULL;
ffffffffc0204f24:	601c                	ld	a5,0(s0)
ffffffffc0204f26:	0207b423          	sd	zero,40(a5)
    }
    current->state = PROC_ZOMBIE;
ffffffffc0204f2a:	470d                	li	a4,3
    current->exit_code = error_code;
ffffffffc0204f2c:	0f27a423          	sw	s2,232(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0204f30:	c398                	sw	a4,0(a5)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f32:	100027f3          	csrr	a5,sstatus
ffffffffc0204f36:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204f38:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0204f3a:	ebf1                	bnez	a5,ffffffffc020500e <do_exit+0x13a>
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
    {
        proc = current->parent;
ffffffffc0204f3c:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204f3e:	800007b7          	lui	a5,0x80000
ffffffffc0204f42:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_obj___user_matrix_out_size+0xffffffff7fff4919>
        proc = current->parent;
ffffffffc0204f44:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204f46:	0ec52703          	lw	a4,236(a0)
ffffffffc0204f4a:	0cf70663          	beq	a4,a5,ffffffffc0205016 <do_exit+0x142>
        {
            wakeup_proc(proc);
        }
        while (current->cptr != NULL)
ffffffffc0204f4e:	6018                	ld	a4,0(s0)
            }
            proc->parent = initproc;
            initproc->cptr = proc;
            if (proc->state == PROC_ZOMBIE)
            {
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204f50:	800005b7          	lui	a1,0x80000
ffffffffc0204f54:	0585                	addi	a1,a1,1 # ffffffff80000001 <_binary_obj___user_matrix_out_size+0xffffffff7fff4919>
        while (current->cptr != NULL)
ffffffffc0204f56:	7b7c                	ld	a5,240(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204f58:	460d                	li	a2,3
        while (current->cptr != NULL)
ffffffffc0204f5a:	e789                	bnez	a5,ffffffffc0204f64 <do_exit+0x90>
ffffffffc0204f5c:	a83d                	j	ffffffffc0204f9a <do_exit+0xc6>
ffffffffc0204f5e:	6018                	ld	a4,0(s0)
ffffffffc0204f60:	7b7c                	ld	a5,240(a4)
ffffffffc0204f62:	cf85                	beqz	a5,ffffffffc0204f9a <do_exit+0xc6>
            current->cptr = proc->optr;
ffffffffc0204f64:	1007b683          	ld	a3,256(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204f68:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc0204f6a:	fb74                	sd	a3,240(a4)
            proc->yptr = NULL;
ffffffffc0204f6c:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204f70:	7978                	ld	a4,240(a0)
ffffffffc0204f72:	10e7b023          	sd	a4,256(a5)
ffffffffc0204f76:	c311                	beqz	a4,ffffffffc0204f7a <do_exit+0xa6>
                initproc->cptr->yptr = proc;
ffffffffc0204f78:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204f7a:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc0204f7c:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc0204f7e:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204f80:	fcc71fe3          	bne	a4,a2,ffffffffc0204f5e <do_exit+0x8a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204f84:	0ec52783          	lw	a5,236(a0)
ffffffffc0204f88:	fcb79be3          	bne	a5,a1,ffffffffc0204f5e <do_exit+0x8a>
                {
                    wakeup_proc(initproc);
ffffffffc0204f8c:	5e5000ef          	jal	ffffffffc0205d70 <wakeup_proc>
ffffffffc0204f90:	800005b7          	lui	a1,0x80000
ffffffffc0204f94:	0585                	addi	a1,a1,1 # ffffffff80000001 <_binary_obj___user_matrix_out_size+0xffffffff7fff4919>
ffffffffc0204f96:	460d                	li	a2,3
ffffffffc0204f98:	b7d9                	j	ffffffffc0204f5e <do_exit+0x8a>
    if (flag) {
ffffffffc0204f9a:	02091263          	bnez	s2,ffffffffc0204fbe <do_exit+0xea>
                }
            }
        }
    }
    local_intr_restore(intr_flag);
    schedule();
ffffffffc0204f9e:	6cb000ef          	jal	ffffffffc0205e68 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc0204fa2:	601c                	ld	a5,0(s0)
ffffffffc0204fa4:	00003617          	auipc	a2,0x3
ffffffffc0204fa8:	5e460613          	addi	a2,a2,1508 # ffffffffc0208588 <etext+0x1e26>
ffffffffc0204fac:	24d00593          	li	a1,589
ffffffffc0204fb0:	43d4                	lw	a3,4(a5)
ffffffffc0204fb2:	00003517          	auipc	a0,0x3
ffffffffc0204fb6:	59e50513          	addi	a0,a0,1438 # ffffffffc0208550 <etext+0x1dee>
ffffffffc0204fba:	c90fb0ef          	jal	ffffffffc020044a <__panic>
        intr_enable();
ffffffffc0204fbe:	93bfb0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0204fc2:	bff1                	j	ffffffffc0204f9e <do_exit+0xca>
        panic("idleproc exit.\n");
ffffffffc0204fc4:	00003617          	auipc	a2,0x3
ffffffffc0204fc8:	5a460613          	addi	a2,a2,1444 # ffffffffc0208568 <etext+0x1e06>
ffffffffc0204fcc:	21900593          	li	a1,537
ffffffffc0204fd0:	00003517          	auipc	a0,0x3
ffffffffc0204fd4:	58050513          	addi	a0,a0,1408 # ffffffffc0208550 <etext+0x1dee>
ffffffffc0204fd8:	e84a                	sd	s2,16(sp)
ffffffffc0204fda:	c70fb0ef          	jal	ffffffffc020044a <__panic>
            exit_mmap(mm);
ffffffffc0204fde:	853a                	mv	a0,a4
ffffffffc0204fe0:	e43a                	sd	a4,8(sp)
ffffffffc0204fe2:	9affe0ef          	jal	ffffffffc0203990 <exit_mmap>
            put_pgdir(mm);
ffffffffc0204fe6:	6722                	ld	a4,8(sp)
ffffffffc0204fe8:	6f08                	ld	a0,24(a4)
ffffffffc0204fea:	919ff0ef          	jal	ffffffffc0204902 <put_pgdir.isra.0>
            mm_destroy(mm);
ffffffffc0204fee:	6522                	ld	a0,8(sp)
ffffffffc0204ff0:	feafe0ef          	jal	ffffffffc02037da <mm_destroy>
ffffffffc0204ff4:	bf05                	j	ffffffffc0204f24 <do_exit+0x50>
        panic("initproc exit.\n");
ffffffffc0204ff6:	00003617          	auipc	a2,0x3
ffffffffc0204ffa:	58260613          	addi	a2,a2,1410 # ffffffffc0208578 <etext+0x1e16>
ffffffffc0204ffe:	21d00593          	li	a1,541
ffffffffc0205002:	00003517          	auipc	a0,0x3
ffffffffc0205006:	54e50513          	addi	a0,a0,1358 # ffffffffc0208550 <etext+0x1dee>
ffffffffc020500a:	c40fb0ef          	jal	ffffffffc020044a <__panic>
        intr_disable();
ffffffffc020500e:	8f1fb0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc0205012:	4905                	li	s2,1
ffffffffc0205014:	b725                	j	ffffffffc0204f3c <do_exit+0x68>
            wakeup_proc(proc);
ffffffffc0205016:	55b000ef          	jal	ffffffffc0205d70 <wakeup_proc>
ffffffffc020501a:	bf15                	j	ffffffffc0204f4e <do_exit+0x7a>

ffffffffc020501c <do_wait.part.0>:
}

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int do_wait(int pid, int *code_store)
ffffffffc020501c:	7179                	addi	sp,sp,-48
ffffffffc020501e:	ec26                	sd	s1,24(sp)
ffffffffc0205020:	e84a                	sd	s2,16(sp)
ffffffffc0205022:	e44e                	sd	s3,8(sp)
ffffffffc0205024:	f406                	sd	ra,40(sp)
ffffffffc0205026:	f022                	sd	s0,32(sp)
ffffffffc0205028:	84aa                	mv	s1,a0
ffffffffc020502a:	892e                	mv	s2,a1
ffffffffc020502c:	000c7997          	auipc	s3,0xc7
ffffffffc0205030:	32c98993          	addi	s3,s3,812 # ffffffffc02cc358 <current>

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
    if (pid != 0)
ffffffffc0205034:	cd19                	beqz	a0,ffffffffc0205052 <do_wait.part.0+0x36>
    if (0 < pid && pid < MAX_PID)
ffffffffc0205036:	6789                	lui	a5,0x2
ffffffffc0205038:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x70ea>
ffffffffc020503a:	fff5071b          	addiw	a4,a0,-1
ffffffffc020503e:	12e7f563          	bgeu	a5,a4,ffffffffc0205168 <do_wait.part.0+0x14c>
    }
    local_intr_restore(intr_flag);
    put_kstack(proc);
    kfree(proc);
    return 0;
}
ffffffffc0205042:	70a2                	ld	ra,40(sp)
ffffffffc0205044:	7402                	ld	s0,32(sp)
ffffffffc0205046:	64e2                	ld	s1,24(sp)
ffffffffc0205048:	6942                	ld	s2,16(sp)
ffffffffc020504a:	69a2                	ld	s3,8(sp)
    return -E_BAD_PROC;
ffffffffc020504c:	5579                	li	a0,-2
}
ffffffffc020504e:	6145                	addi	sp,sp,48
ffffffffc0205050:	8082                	ret
        proc = current->cptr;
ffffffffc0205052:	0009b703          	ld	a4,0(s3)
ffffffffc0205056:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr)
ffffffffc0205058:	d46d                	beqz	s0,ffffffffc0205042 <do_wait.part.0+0x26>
            if (proc->state == PROC_ZOMBIE)
ffffffffc020505a:	468d                	li	a3,3
ffffffffc020505c:	a021                	j	ffffffffc0205064 <do_wait.part.0+0x48>
        for (; proc != NULL; proc = proc->optr)
ffffffffc020505e:	10043403          	ld	s0,256(s0)
ffffffffc0205062:	c075                	beqz	s0,ffffffffc0205146 <do_wait.part.0+0x12a>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0205064:	401c                	lw	a5,0(s0)
ffffffffc0205066:	fed79ce3          	bne	a5,a3,ffffffffc020505e <do_wait.part.0+0x42>
    if (proc == idleproc || proc == initproc)
ffffffffc020506a:	000c7797          	auipc	a5,0xc7
ffffffffc020506e:	2fe7b783          	ld	a5,766(a5) # ffffffffc02cc368 <idleproc>
ffffffffc0205072:	14878263          	beq	a5,s0,ffffffffc02051b6 <do_wait.part.0+0x19a>
ffffffffc0205076:	000c7797          	auipc	a5,0xc7
ffffffffc020507a:	2ea7b783          	ld	a5,746(a5) # ffffffffc02cc360 <initproc>
ffffffffc020507e:	12f40c63          	beq	s0,a5,ffffffffc02051b6 <do_wait.part.0+0x19a>
    if (code_store != NULL)
ffffffffc0205082:	00090663          	beqz	s2,ffffffffc020508e <do_wait.part.0+0x72>
        *code_store = proc->exit_code;
ffffffffc0205086:	0e842783          	lw	a5,232(s0)
ffffffffc020508a:	00f92023          	sw	a5,0(s2)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020508e:	100027f3          	csrr	a5,sstatus
ffffffffc0205092:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0205094:	4601                	li	a2,0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205096:	10079963          	bnez	a5,ffffffffc02051a8 <do_wait.part.0+0x18c>
    __list_del(listelm->prev, listelm->next);
ffffffffc020509a:	6c74                	ld	a3,216(s0)
ffffffffc020509c:	7078                	ld	a4,224(s0)
    if (proc->optr != NULL)
ffffffffc020509e:	10043783          	ld	a5,256(s0)
    prev->next = next;
ffffffffc02050a2:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02050a4:	e314                	sd	a3,0(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc02050a6:	6474                	ld	a3,200(s0)
ffffffffc02050a8:	6878                	ld	a4,208(s0)
    prev->next = next;
ffffffffc02050aa:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02050ac:	e314                	sd	a3,0(a4)
ffffffffc02050ae:	c789                	beqz	a5,ffffffffc02050b8 <do_wait.part.0+0x9c>
        proc->optr->yptr = proc->yptr;
ffffffffc02050b0:	7c78                	ld	a4,248(s0)
ffffffffc02050b2:	fff8                	sd	a4,248(a5)
        proc->yptr->optr = proc->optr;
ffffffffc02050b4:	10043783          	ld	a5,256(s0)
    if (proc->yptr != NULL)
ffffffffc02050b8:	7c78                	ld	a4,248(s0)
ffffffffc02050ba:	c36d                	beqz	a4,ffffffffc020519c <do_wait.part.0+0x180>
        proc->yptr->optr = proc->optr;
ffffffffc02050bc:	10f73023          	sd	a5,256(a4)
    nr_process--;
ffffffffc02050c0:	000c7797          	auipc	a5,0xc7
ffffffffc02050c4:	2947a783          	lw	a5,660(a5) # ffffffffc02cc354 <nr_process>
ffffffffc02050c8:	37fd                	addiw	a5,a5,-1
ffffffffc02050ca:	000c7717          	auipc	a4,0xc7
ffffffffc02050ce:	28f72523          	sw	a5,650(a4) # ffffffffc02cc354 <nr_process>
    if (flag) {
ffffffffc02050d2:	e271                	bnez	a2,ffffffffc0205196 <do_wait.part.0+0x17a>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc02050d4:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc02050d6:	c02007b7          	lui	a5,0xc0200
ffffffffc02050da:	10f6e663          	bltu	a3,a5,ffffffffc02051e6 <do_wait.part.0+0x1ca>
ffffffffc02050de:	000c7717          	auipc	a4,0xc7
ffffffffc02050e2:	25273703          	ld	a4,594(a4) # ffffffffc02cc330 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc02050e6:	000c7797          	auipc	a5,0xc7
ffffffffc02050ea:	2527b783          	ld	a5,594(a5) # ffffffffc02cc338 <npage>
    return pa2page(PADDR(kva));
ffffffffc02050ee:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc02050f0:	82b1                	srli	a3,a3,0xc
ffffffffc02050f2:	0cf6fe63          	bgeu	a3,a5,ffffffffc02051ce <do_wait.part.0+0x1b2>
    return &pages[PPN(pa) - nbase];
ffffffffc02050f6:	00004797          	auipc	a5,0x4
ffffffffc02050fa:	60a7b783          	ld	a5,1546(a5) # ffffffffc0209700 <nbase>
ffffffffc02050fe:	000c7517          	auipc	a0,0xc7
ffffffffc0205102:	24253503          	ld	a0,578(a0) # ffffffffc02cc340 <pages>
ffffffffc0205106:	4589                	li	a1,2
ffffffffc0205108:	8e9d                	sub	a3,a3,a5
ffffffffc020510a:	069a                	slli	a3,a3,0x6
ffffffffc020510c:	9536                	add	a0,a0,a3
ffffffffc020510e:	df5fc0ef          	jal	ffffffffc0201f02 <free_pages>
    kfree(proc);
ffffffffc0205112:	8522                	mv	a0,s0
ffffffffc0205114:	c97fc0ef          	jal	ffffffffc0201daa <kfree>
}
ffffffffc0205118:	70a2                	ld	ra,40(sp)
ffffffffc020511a:	7402                	ld	s0,32(sp)
ffffffffc020511c:	64e2                	ld	s1,24(sp)
ffffffffc020511e:	6942                	ld	s2,16(sp)
ffffffffc0205120:	69a2                	ld	s3,8(sp)
    return 0;
ffffffffc0205122:	4501                	li	a0,0
}
ffffffffc0205124:	6145                	addi	sp,sp,48
ffffffffc0205126:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc0205128:	000c7997          	auipc	s3,0xc7
ffffffffc020512c:	23098993          	addi	s3,s3,560 # ffffffffc02cc358 <current>
ffffffffc0205130:	0009b703          	ld	a4,0(s3)
ffffffffc0205134:	f487b683          	ld	a3,-184(a5)
ffffffffc0205138:	f0e695e3          	bne	a3,a4,ffffffffc0205042 <do_wait.part.0+0x26>
            if (proc->state == PROC_ZOMBIE)
ffffffffc020513c:	f287a603          	lw	a2,-216(a5)
ffffffffc0205140:	468d                	li	a3,3
ffffffffc0205142:	06d60063          	beq	a2,a3,ffffffffc02051a2 <do_wait.part.0+0x186>
        current->wait_state = WT_CHILD;
ffffffffc0205146:	800007b7          	lui	a5,0x80000
ffffffffc020514a:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_obj___user_matrix_out_size+0xffffffff7fff4919>
        current->state = PROC_SLEEPING;
ffffffffc020514c:	4685                	li	a3,1
        current->wait_state = WT_CHILD;
ffffffffc020514e:	0ef72623          	sw	a5,236(a4)
        current->state = PROC_SLEEPING;
ffffffffc0205152:	c314                	sw	a3,0(a4)
        schedule();
ffffffffc0205154:	515000ef          	jal	ffffffffc0205e68 <schedule>
        if (current->flags & PF_EXITING)
ffffffffc0205158:	0009b783          	ld	a5,0(s3)
ffffffffc020515c:	0b07a783          	lw	a5,176(a5)
ffffffffc0205160:	8b85                	andi	a5,a5,1
ffffffffc0205162:	e7b9                	bnez	a5,ffffffffc02051b0 <do_wait.part.0+0x194>
    if (pid != 0)
ffffffffc0205164:	ee0487e3          	beqz	s1,ffffffffc0205052 <do_wait.part.0+0x36>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205168:	45a9                	li	a1,10
ffffffffc020516a:	8526                	mv	a0,s1
ffffffffc020516c:	136010ef          	jal	ffffffffc02062a2 <hash32>
ffffffffc0205170:	02051793          	slli	a5,a0,0x20
ffffffffc0205174:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205178:	000c3797          	auipc	a5,0xc3
ffffffffc020517c:	13878793          	addi	a5,a5,312 # ffffffffc02c82b0 <hash_list>
ffffffffc0205180:	953e                	add	a0,a0,a5
ffffffffc0205182:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc0205184:	a029                	j	ffffffffc020518e <do_wait.part.0+0x172>
            if (proc->pid == pid)
ffffffffc0205186:	f2c7a703          	lw	a4,-212(a5)
ffffffffc020518a:	f8970fe3          	beq	a4,s1,ffffffffc0205128 <do_wait.part.0+0x10c>
    return listelm->next;
ffffffffc020518e:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0205190:	fef51be3          	bne	a0,a5,ffffffffc0205186 <do_wait.part.0+0x16a>
ffffffffc0205194:	b57d                	j	ffffffffc0205042 <do_wait.part.0+0x26>
        intr_enable();
ffffffffc0205196:	f62fb0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc020519a:	bf2d                	j	ffffffffc02050d4 <do_wait.part.0+0xb8>
        proc->parent->cptr = proc->optr;
ffffffffc020519c:	7018                	ld	a4,32(s0)
ffffffffc020519e:	fb7c                	sd	a5,240(a4)
ffffffffc02051a0:	b705                	j	ffffffffc02050c0 <do_wait.part.0+0xa4>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02051a2:	f2878413          	addi	s0,a5,-216
ffffffffc02051a6:	b5d1                	j	ffffffffc020506a <do_wait.part.0+0x4e>
        intr_disable();
ffffffffc02051a8:	f56fb0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc02051ac:	4605                	li	a2,1
ffffffffc02051ae:	b5f5                	j	ffffffffc020509a <do_wait.part.0+0x7e>
            do_exit(-E_KILLED);
ffffffffc02051b0:	555d                	li	a0,-9
ffffffffc02051b2:	d23ff0ef          	jal	ffffffffc0204ed4 <do_exit>
        panic("wait idleproc or initproc.\n");
ffffffffc02051b6:	00003617          	auipc	a2,0x3
ffffffffc02051ba:	3f260613          	addi	a2,a2,1010 # ffffffffc02085a8 <etext+0x1e46>
ffffffffc02051be:	36f00593          	li	a1,879
ffffffffc02051c2:	00003517          	auipc	a0,0x3
ffffffffc02051c6:	38e50513          	addi	a0,a0,910 # ffffffffc0208550 <etext+0x1dee>
ffffffffc02051ca:	a80fb0ef          	jal	ffffffffc020044a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02051ce:	00002617          	auipc	a2,0x2
ffffffffc02051d2:	46a60613          	addi	a2,a2,1130 # ffffffffc0207638 <etext+0xed6>
ffffffffc02051d6:	06900593          	li	a1,105
ffffffffc02051da:	00002517          	auipc	a0,0x2
ffffffffc02051de:	3b650513          	addi	a0,a0,950 # ffffffffc0207590 <etext+0xe2e>
ffffffffc02051e2:	a68fb0ef          	jal	ffffffffc020044a <__panic>
    return pa2page(PADDR(kva));
ffffffffc02051e6:	00002617          	auipc	a2,0x2
ffffffffc02051ea:	42a60613          	addi	a2,a2,1066 # ffffffffc0207610 <etext+0xeae>
ffffffffc02051ee:	07700593          	li	a1,119
ffffffffc02051f2:	00002517          	auipc	a0,0x2
ffffffffc02051f6:	39e50513          	addi	a0,a0,926 # ffffffffc0207590 <etext+0xe2e>
ffffffffc02051fa:	a50fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02051fe <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc02051fe:	1141                	addi	sp,sp,-16
ffffffffc0205200:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc0205202:	d39fc0ef          	jal	ffffffffc0201f3a <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0205206:	afbfc0ef          	jal	ffffffffc0201d00 <kallocated>
    // if (pid <= 0)
    // {
    //     panic("create user_main failed.\n");
    // }
    extern void check_sync(void);
    check_sync(); // check philosopher sync problem
ffffffffc020520a:	8e8ff0ef          	jal	ffffffffc02042f2 <check_sync>

    while (do_wait(0, NULL) == 0)
ffffffffc020520e:	a019                	j	ffffffffc0205214 <init_main+0x16>
    {
        schedule();
ffffffffc0205210:	459000ef          	jal	ffffffffc0205e68 <schedule>
    if (code_store != NULL)
ffffffffc0205214:	4581                	li	a1,0
ffffffffc0205216:	4501                	li	a0,0
ffffffffc0205218:	e05ff0ef          	jal	ffffffffc020501c <do_wait.part.0>
    while (do_wait(0, NULL) == 0)
ffffffffc020521c:	d975                	beqz	a0,ffffffffc0205210 <init_main+0x12>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc020521e:	00003517          	auipc	a0,0x3
ffffffffc0205222:	3aa50513          	addi	a0,a0,938 # ffffffffc02085c8 <etext+0x1e66>
ffffffffc0205226:	f73fa0ef          	jal	ffffffffc0200198 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020522a:	000c7797          	auipc	a5,0xc7
ffffffffc020522e:	1367b783          	ld	a5,310(a5) # ffffffffc02cc360 <initproc>
ffffffffc0205232:	7bf8                	ld	a4,240(a5)
ffffffffc0205234:	e339                	bnez	a4,ffffffffc020527a <init_main+0x7c>
ffffffffc0205236:	7ff8                	ld	a4,248(a5)
ffffffffc0205238:	e329                	bnez	a4,ffffffffc020527a <init_main+0x7c>
ffffffffc020523a:	1007b703          	ld	a4,256(a5)
ffffffffc020523e:	ef15                	bnez	a4,ffffffffc020527a <init_main+0x7c>
    assert(nr_process == 2);
ffffffffc0205240:	000c7697          	auipc	a3,0xc7
ffffffffc0205244:	1146a683          	lw	a3,276(a3) # ffffffffc02cc354 <nr_process>
ffffffffc0205248:	4709                	li	a4,2
ffffffffc020524a:	08e69863          	bne	a3,a4,ffffffffc02052da <init_main+0xdc>
ffffffffc020524e:	000c7717          	auipc	a4,0xc7
ffffffffc0205252:	06270713          	addi	a4,a4,98 # ffffffffc02cc2b0 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0205256:	6714                	ld	a3,8(a4)
ffffffffc0205258:	0c878793          	addi	a5,a5,200
ffffffffc020525c:	04d79f63          	bne	a5,a3,ffffffffc02052ba <init_main+0xbc>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc0205260:	6318                	ld	a4,0(a4)
ffffffffc0205262:	02e79c63          	bne	a5,a4,ffffffffc020529a <init_main+0x9c>

    cprintf("init check memory pass.\n");
ffffffffc0205266:	00003517          	auipc	a0,0x3
ffffffffc020526a:	44a50513          	addi	a0,a0,1098 # ffffffffc02086b0 <etext+0x1f4e>
ffffffffc020526e:	f2bfa0ef          	jal	ffffffffc0200198 <cprintf>
    return 0;
}
ffffffffc0205272:	60a2                	ld	ra,8(sp)
ffffffffc0205274:	4501                	li	a0,0
ffffffffc0205276:	0141                	addi	sp,sp,16
ffffffffc0205278:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc020527a:	00003697          	auipc	a3,0x3
ffffffffc020527e:	37668693          	addi	a3,a3,886 # ffffffffc02085f0 <etext+0x1e8e>
ffffffffc0205282:	00002617          	auipc	a2,0x2
ffffffffc0205286:	c8e60613          	addi	a2,a2,-882 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020528a:	3de00593          	li	a1,990
ffffffffc020528e:	00003517          	auipc	a0,0x3
ffffffffc0205292:	2c250513          	addi	a0,a0,706 # ffffffffc0208550 <etext+0x1dee>
ffffffffc0205296:	9b4fb0ef          	jal	ffffffffc020044a <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020529a:	00003697          	auipc	a3,0x3
ffffffffc020529e:	3e668693          	addi	a3,a3,998 # ffffffffc0208680 <etext+0x1f1e>
ffffffffc02052a2:	00002617          	auipc	a2,0x2
ffffffffc02052a6:	c6e60613          	addi	a2,a2,-914 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02052aa:	3e100593          	li	a1,993
ffffffffc02052ae:	00003517          	auipc	a0,0x3
ffffffffc02052b2:	2a250513          	addi	a0,a0,674 # ffffffffc0208550 <etext+0x1dee>
ffffffffc02052b6:	994fb0ef          	jal	ffffffffc020044a <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc02052ba:	00003697          	auipc	a3,0x3
ffffffffc02052be:	39668693          	addi	a3,a3,918 # ffffffffc0208650 <etext+0x1eee>
ffffffffc02052c2:	00002617          	auipc	a2,0x2
ffffffffc02052c6:	c4e60613          	addi	a2,a2,-946 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02052ca:	3e000593          	li	a1,992
ffffffffc02052ce:	00003517          	auipc	a0,0x3
ffffffffc02052d2:	28250513          	addi	a0,a0,642 # ffffffffc0208550 <etext+0x1dee>
ffffffffc02052d6:	974fb0ef          	jal	ffffffffc020044a <__panic>
    assert(nr_process == 2);
ffffffffc02052da:	00003697          	auipc	a3,0x3
ffffffffc02052de:	36668693          	addi	a3,a3,870 # ffffffffc0208640 <etext+0x1ede>
ffffffffc02052e2:	00002617          	auipc	a2,0x2
ffffffffc02052e6:	c2e60613          	addi	a2,a2,-978 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc02052ea:	3df00593          	li	a1,991
ffffffffc02052ee:	00003517          	auipc	a0,0x3
ffffffffc02052f2:	26250513          	addi	a0,a0,610 # ffffffffc0208550 <etext+0x1dee>
ffffffffc02052f6:	954fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02052fa <do_execve>:
{
ffffffffc02052fa:	7171                	addi	sp,sp,-176
ffffffffc02052fc:	e8ea                	sd	s10,80(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02052fe:	000c7d17          	auipc	s10,0xc7
ffffffffc0205302:	05ad0d13          	addi	s10,s10,90 # ffffffffc02cc358 <current>
ffffffffc0205306:	000d3783          	ld	a5,0(s10)
{
ffffffffc020530a:	e94a                	sd	s2,144(sp)
ffffffffc020530c:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc020530e:	0287b903          	ld	s2,40(a5)
{
ffffffffc0205312:	84ae                	mv	s1,a1
ffffffffc0205314:	e54e                	sd	s3,136(sp)
ffffffffc0205316:	ec32                	sd	a2,24(sp)
ffffffffc0205318:	89aa                	mv	s3,a0
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc020531a:	85aa                	mv	a1,a0
ffffffffc020531c:	8626                	mv	a2,s1
ffffffffc020531e:	854a                	mv	a0,s2
ffffffffc0205320:	4681                	li	a3,0
{
ffffffffc0205322:	f506                	sd	ra,168(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0205324:	a0bfe0ef          	jal	ffffffffc0203d2e <user_mem_check>
ffffffffc0205328:	48050263          	beqz	a0,ffffffffc02057ac <do_execve+0x4b2>
    memset(local_name, 0, sizeof(local_name));
ffffffffc020532c:	4641                	li	a2,16
ffffffffc020532e:	1808                	addi	a0,sp,48
ffffffffc0205330:	4581                	li	a1,0
ffffffffc0205332:	406010ef          	jal	ffffffffc0206738 <memset>
    if (len > PROC_NAME_LEN)
ffffffffc0205336:	47bd                	li	a5,15
ffffffffc0205338:	8626                	mv	a2,s1
ffffffffc020533a:	0e97ef63          	bltu	a5,s1,ffffffffc0205438 <do_execve+0x13e>
    memcpy(local_name, name, len);
ffffffffc020533e:	85ce                	mv	a1,s3
ffffffffc0205340:	1808                	addi	a0,sp,48
ffffffffc0205342:	408010ef          	jal	ffffffffc020674a <memcpy>
    if (mm != NULL)
ffffffffc0205346:	10090063          	beqz	s2,ffffffffc0205446 <do_execve+0x14c>
        cputs("mm != NULL");
ffffffffc020534a:	00003517          	auipc	a0,0x3
ffffffffc020534e:	a0650513          	addi	a0,a0,-1530 # ffffffffc0207d50 <etext+0x15ee>
ffffffffc0205352:	e7dfa0ef          	jal	ffffffffc02001ce <cputs>
ffffffffc0205356:	000c7797          	auipc	a5,0xc7
ffffffffc020535a:	fca7b783          	ld	a5,-54(a5) # ffffffffc02cc320 <boot_pgdir_pa>
ffffffffc020535e:	577d                	li	a4,-1
ffffffffc0205360:	177e                	slli	a4,a4,0x3f
ffffffffc0205362:	83b1                	srli	a5,a5,0xc
ffffffffc0205364:	8fd9                	or	a5,a5,a4
ffffffffc0205366:	18079073          	csrw	satp,a5
ffffffffc020536a:	03092783          	lw	a5,48(s2)
ffffffffc020536e:	37fd                	addiw	a5,a5,-1
ffffffffc0205370:	02f92823          	sw	a5,48(s2)
        if (mm_count_dec(mm) == 0)
ffffffffc0205374:	30078763          	beqz	a5,ffffffffc0205682 <do_execve+0x388>
        current->mm = NULL;
ffffffffc0205378:	000d3783          	ld	a5,0(s10)
ffffffffc020537c:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc0205380:	b0efe0ef          	jal	ffffffffc020368e <mm_create>
ffffffffc0205384:	89aa                	mv	s3,a0
ffffffffc0205386:	22050063          	beqz	a0,ffffffffc02055a6 <do_execve+0x2ac>
    if ((page = alloc_page()) == NULL)
ffffffffc020538a:	4505                	li	a0,1
ffffffffc020538c:	b3dfc0ef          	jal	ffffffffc0201ec8 <alloc_pages>
ffffffffc0205390:	42050363          	beqz	a0,ffffffffc02057b6 <do_execve+0x4bc>
    return page - pages + nbase;
ffffffffc0205394:	f0e2                	sd	s8,96(sp)
ffffffffc0205396:	000c7c17          	auipc	s8,0xc7
ffffffffc020539a:	faac0c13          	addi	s8,s8,-86 # ffffffffc02cc340 <pages>
ffffffffc020539e:	000c3783          	ld	a5,0(s8)
ffffffffc02053a2:	f4de                	sd	s7,104(sp)
ffffffffc02053a4:	00004b97          	auipc	s7,0x4
ffffffffc02053a8:	35cbbb83          	ld	s7,860(s7) # ffffffffc0209700 <nbase>
ffffffffc02053ac:	40f506b3          	sub	a3,a0,a5
ffffffffc02053b0:	ece6                	sd	s9,88(sp)
    return KADDR(page2pa(page));
ffffffffc02053b2:	000c7c97          	auipc	s9,0xc7
ffffffffc02053b6:	f86c8c93          	addi	s9,s9,-122 # ffffffffc02cc338 <npage>
ffffffffc02053ba:	f8da                	sd	s6,112(sp)
    return page - pages + nbase;
ffffffffc02053bc:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02053be:	5b7d                	li	s6,-1
ffffffffc02053c0:	000cb783          	ld	a5,0(s9)
    return page - pages + nbase;
ffffffffc02053c4:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc02053c6:	00cb5713          	srli	a4,s6,0xc
ffffffffc02053ca:	e83a                	sd	a4,16(sp)
ffffffffc02053cc:	fcd6                	sd	s5,120(sp)
ffffffffc02053ce:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc02053d0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02053d2:	40f77563          	bgeu	a4,a5,ffffffffc02057dc <do_execve+0x4e2>
ffffffffc02053d6:	000c7a97          	auipc	s5,0xc7
ffffffffc02053da:	f5aa8a93          	addi	s5,s5,-166 # ffffffffc02cc330 <va_pa_offset>
ffffffffc02053de:	000ab783          	ld	a5,0(s5)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc02053e2:	000c7597          	auipc	a1,0xc7
ffffffffc02053e6:	f465b583          	ld	a1,-186(a1) # ffffffffc02cc328 <boot_pgdir_va>
ffffffffc02053ea:	6605                	lui	a2,0x1
ffffffffc02053ec:	00f68933          	add	s2,a3,a5
ffffffffc02053f0:	854a                	mv	a0,s2
ffffffffc02053f2:	358010ef          	jal	ffffffffc020674a <memcpy>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc02053f6:	66e2                	ld	a3,24(sp)
ffffffffc02053f8:	464c47b7          	lui	a5,0x464c4
ffffffffc02053fc:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_matrix_out_size+0x464b8e97>
ffffffffc0205400:	4298                	lw	a4,0(a3)
    mm->pgdir = pgdir;
ffffffffc0205402:	0129bc23          	sd	s2,24(s3)
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0205406:	06f70863          	beq	a4,a5,ffffffffc0205476 <do_execve+0x17c>
        ret = -E_INVAL_ELF;
ffffffffc020540a:	54e1                	li	s1,-8
    put_pgdir(mm);
ffffffffc020540c:	854a                	mv	a0,s2
ffffffffc020540e:	cf4ff0ef          	jal	ffffffffc0204902 <put_pgdir.isra.0>
ffffffffc0205412:	7ae6                	ld	s5,120(sp)
ffffffffc0205414:	7b46                	ld	s6,112(sp)
ffffffffc0205416:	7ba6                	ld	s7,104(sp)
ffffffffc0205418:	7c06                	ld	s8,96(sp)
ffffffffc020541a:	6ce6                	ld	s9,88(sp)
    mm_destroy(mm);
ffffffffc020541c:	854e                	mv	a0,s3
ffffffffc020541e:	bbcfe0ef          	jal	ffffffffc02037da <mm_destroy>
    do_exit(ret);
ffffffffc0205422:	8526                	mv	a0,s1
ffffffffc0205424:	f122                	sd	s0,160(sp)
ffffffffc0205426:	e152                	sd	s4,128(sp)
ffffffffc0205428:	fcd6                	sd	s5,120(sp)
ffffffffc020542a:	f8da                	sd	s6,112(sp)
ffffffffc020542c:	f4de                	sd	s7,104(sp)
ffffffffc020542e:	f0e2                	sd	s8,96(sp)
ffffffffc0205430:	ece6                	sd	s9,88(sp)
ffffffffc0205432:	e4ee                	sd	s11,72(sp)
ffffffffc0205434:	aa1ff0ef          	jal	ffffffffc0204ed4 <do_exit>
    if (len > PROC_NAME_LEN)
ffffffffc0205438:	863e                	mv	a2,a5
    memcpy(local_name, name, len);
ffffffffc020543a:	85ce                	mv	a1,s3
ffffffffc020543c:	1808                	addi	a0,sp,48
ffffffffc020543e:	30c010ef          	jal	ffffffffc020674a <memcpy>
    if (mm != NULL)
ffffffffc0205442:	f00914e3          	bnez	s2,ffffffffc020534a <do_execve+0x50>
    if (current->mm != NULL)
ffffffffc0205446:	000d3783          	ld	a5,0(s10)
ffffffffc020544a:	779c                	ld	a5,40(a5)
ffffffffc020544c:	db95                	beqz	a5,ffffffffc0205380 <do_execve+0x86>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc020544e:	00003617          	auipc	a2,0x3
ffffffffc0205452:	28260613          	addi	a2,a2,642 # ffffffffc02086d0 <etext+0x1f6e>
ffffffffc0205456:	25900593          	li	a1,601
ffffffffc020545a:	00003517          	auipc	a0,0x3
ffffffffc020545e:	0f650513          	addi	a0,a0,246 # ffffffffc0208550 <etext+0x1dee>
ffffffffc0205462:	f122                	sd	s0,160(sp)
ffffffffc0205464:	e152                	sd	s4,128(sp)
ffffffffc0205466:	fcd6                	sd	s5,120(sp)
ffffffffc0205468:	f8da                	sd	s6,112(sp)
ffffffffc020546a:	f4de                	sd	s7,104(sp)
ffffffffc020546c:	f0e2                	sd	s8,96(sp)
ffffffffc020546e:	ece6                	sd	s9,88(sp)
ffffffffc0205470:	e4ee                	sd	s11,72(sp)
ffffffffc0205472:	fd9fa0ef          	jal	ffffffffc020044a <__panic>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205476:	0386d703          	lhu	a4,56(a3)
ffffffffc020547a:	e152                	sd	s4,128(sp)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc020547c:	0206ba03          	ld	s4,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0205480:	00371793          	slli	a5,a4,0x3
ffffffffc0205484:	8f99                	sub	a5,a5,a4
ffffffffc0205486:	078e                	slli	a5,a5,0x3
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0205488:	9a36                	add	s4,s4,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc020548a:	97d2                	add	a5,a5,s4
ffffffffc020548c:	f122                	sd	s0,160(sp)
ffffffffc020548e:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph++)
ffffffffc0205490:	00fa7e63          	bgeu	s4,a5,ffffffffc02054ac <do_execve+0x1b2>
ffffffffc0205494:	e4ee                	sd	s11,72(sp)
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0205496:	000a2783          	lw	a5,0(s4)
ffffffffc020549a:	4705                	li	a4,1
ffffffffc020549c:	10e78763          	beq	a5,a4,ffffffffc02055aa <do_execve+0x2b0>
    for (; ph < ph_end; ph++)
ffffffffc02054a0:	77a2                	ld	a5,40(sp)
ffffffffc02054a2:	038a0a13          	addi	s4,s4,56
ffffffffc02054a6:	fefa68e3          	bltu	s4,a5,ffffffffc0205496 <do_execve+0x19c>
ffffffffc02054aa:	6da6                	ld	s11,72(sp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc02054ac:	4701                	li	a4,0
ffffffffc02054ae:	46ad                	li	a3,11
ffffffffc02054b0:	00100637          	lui	a2,0x100
ffffffffc02054b4:	7ff005b7          	lui	a1,0x7ff00
ffffffffc02054b8:	854e                	mv	a0,s3
ffffffffc02054ba:	b72fe0ef          	jal	ffffffffc020382c <mm_map>
ffffffffc02054be:	84aa                	mv	s1,a0
ffffffffc02054c0:	1a051963          	bnez	a0,ffffffffc0205672 <do_execve+0x378>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc02054c4:	0189b503          	ld	a0,24(s3)
ffffffffc02054c8:	467d                	li	a2,31
ffffffffc02054ca:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc02054ce:	8defe0ef          	jal	ffffffffc02035ac <pgdir_alloc_page>
ffffffffc02054d2:	3a050463          	beqz	a0,ffffffffc020587a <do_execve+0x580>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc02054d6:	0189b503          	ld	a0,24(s3)
ffffffffc02054da:	467d                	li	a2,31
ffffffffc02054dc:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc02054e0:	8ccfe0ef          	jal	ffffffffc02035ac <pgdir_alloc_page>
ffffffffc02054e4:	36050a63          	beqz	a0,ffffffffc0205858 <do_execve+0x55e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc02054e8:	0189b503          	ld	a0,24(s3)
ffffffffc02054ec:	467d                	li	a2,31
ffffffffc02054ee:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc02054f2:	8bafe0ef          	jal	ffffffffc02035ac <pgdir_alloc_page>
ffffffffc02054f6:	34050063          	beqz	a0,ffffffffc0205836 <do_execve+0x53c>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc02054fa:	0189b503          	ld	a0,24(s3)
ffffffffc02054fe:	467d                	li	a2,31
ffffffffc0205500:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0205504:	8a8fe0ef          	jal	ffffffffc02035ac <pgdir_alloc_page>
ffffffffc0205508:	30050663          	beqz	a0,ffffffffc0205814 <do_execve+0x51a>
    mm->mm_count += 1;
ffffffffc020550c:	0309a783          	lw	a5,48(s3)
    current->mm = mm;
ffffffffc0205510:	000d3603          	ld	a2,0(s10)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0205514:	0189b683          	ld	a3,24(s3)
ffffffffc0205518:	2785                	addiw	a5,a5,1
ffffffffc020551a:	02f9a823          	sw	a5,48(s3)
    current->mm = mm;
ffffffffc020551e:	03363423          	sd	s3,40(a2) # 100028 <_binary_obj___user_matrix_out_size+0xf4940>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0205522:	c02007b7          	lui	a5,0xc0200
ffffffffc0205526:	2cf6ea63          	bltu	a3,a5,ffffffffc02057fa <do_execve+0x500>
ffffffffc020552a:	000ab783          	ld	a5,0(s5)
ffffffffc020552e:	577d                	li	a4,-1
ffffffffc0205530:	177e                	slli	a4,a4,0x3f
ffffffffc0205532:	8e9d                	sub	a3,a3,a5
ffffffffc0205534:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205538:	f654                	sd	a3,168(a2)
ffffffffc020553a:	8fd9                	or	a5,a5,a4
ffffffffc020553c:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0205540:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0205542:	4581                	li	a1,0
ffffffffc0205544:	12000613          	li	a2,288
ffffffffc0205548:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc020554a:	10043903          	ld	s2,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc020554e:	1ea010ef          	jal	ffffffffc0206738 <memset>
    tf->epc = elf->e_entry;
ffffffffc0205552:	67e2                	ld	a5,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205554:	000d3983          	ld	s3,0(s10)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205558:	edf97913          	andi	s2,s2,-289
    tf->epc = elf->e_entry;
ffffffffc020555c:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc020555e:	4785                	li	a5,1
ffffffffc0205560:	07fe                	slli	a5,a5,0x1f
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0205562:	02096913          	ori	s2,s2,32
    tf->epc = elf->e_entry;
ffffffffc0205566:	10e43423          	sd	a4,264(s0)
    tf->gpr.sp = USTACKTOP;
ffffffffc020556a:	e81c                	sd	a5,16(s0)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc020556c:	11243023          	sd	s2,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205570:	4641                	li	a2,16
ffffffffc0205572:	4581                	li	a1,0
ffffffffc0205574:	0b498513          	addi	a0,s3,180
ffffffffc0205578:	1c0010ef          	jal	ffffffffc0206738 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc020557c:	180c                	addi	a1,sp,48
ffffffffc020557e:	0b498513          	addi	a0,s3,180
ffffffffc0205582:	463d                	li	a2,15
ffffffffc0205584:	1c6010ef          	jal	ffffffffc020674a <memcpy>
ffffffffc0205588:	740a                	ld	s0,160(sp)
ffffffffc020558a:	6a0a                	ld	s4,128(sp)
ffffffffc020558c:	7ae6                	ld	s5,120(sp)
ffffffffc020558e:	7b46                	ld	s6,112(sp)
ffffffffc0205590:	7ba6                	ld	s7,104(sp)
ffffffffc0205592:	7c06                	ld	s8,96(sp)
ffffffffc0205594:	6ce6                	ld	s9,88(sp)
}
ffffffffc0205596:	70aa                	ld	ra,168(sp)
ffffffffc0205598:	694a                	ld	s2,144(sp)
ffffffffc020559a:	69aa                	ld	s3,136(sp)
ffffffffc020559c:	6d46                	ld	s10,80(sp)
ffffffffc020559e:	8526                	mv	a0,s1
ffffffffc02055a0:	64ea                	ld	s1,152(sp)
ffffffffc02055a2:	614d                	addi	sp,sp,176
ffffffffc02055a4:	8082                	ret
    int ret = -E_NO_MEM;
ffffffffc02055a6:	54f1                	li	s1,-4
ffffffffc02055a8:	bdad                	j	ffffffffc0205422 <do_execve+0x128>
        if (ph->p_filesz > ph->p_memsz)
ffffffffc02055aa:	028a3603          	ld	a2,40(s4)
ffffffffc02055ae:	020a3783          	ld	a5,32(s4)
ffffffffc02055b2:	20f66663          	bltu	a2,a5,ffffffffc02057be <do_execve+0x4c4>
        if (ph->p_flags & ELF_PF_X)
ffffffffc02055b6:	004a2783          	lw	a5,4(s4)
ffffffffc02055ba:	0027971b          	slliw	a4,a5,0x2
        if (ph->p_flags & ELF_PF_W)
ffffffffc02055be:	0027f693          	andi	a3,a5,2
        if (ph->p_flags & ELF_PF_X)
ffffffffc02055c2:	8b11                	andi	a4,a4,4
        if (ph->p_flags & ELF_PF_R)
ffffffffc02055c4:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc02055c6:	cae9                	beqz	a3,ffffffffc0205698 <do_execve+0x39e>
        if (ph->p_flags & ELF_PF_R)
ffffffffc02055c8:	1c079a63          	bnez	a5,ffffffffc020579c <do_execve+0x4a2>
            perm |= (PTE_W | PTE_R);
ffffffffc02055cc:	47dd                	li	a5,23
            vm_flags |= VM_WRITE;
ffffffffc02055ce:	00276693          	ori	a3,a4,2
            perm |= (PTE_W | PTE_R);
ffffffffc02055d2:	e43e                	sd	a5,8(sp)
        if (vm_flags & VM_EXEC)
ffffffffc02055d4:	c709                	beqz	a4,ffffffffc02055de <do_execve+0x2e4>
            perm |= PTE_X;
ffffffffc02055d6:	67a2                	ld	a5,8(sp)
ffffffffc02055d8:	0087e793          	ori	a5,a5,8
ffffffffc02055dc:	e43e                	sd	a5,8(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc02055de:	010a3583          	ld	a1,16(s4)
ffffffffc02055e2:	4701                	li	a4,0
ffffffffc02055e4:	854e                	mv	a0,s3
ffffffffc02055e6:	a46fe0ef          	jal	ffffffffc020382c <mm_map>
ffffffffc02055ea:	84aa                	mv	s1,a0
ffffffffc02055ec:	1c051763          	bnez	a0,ffffffffc02057ba <do_execve+0x4c0>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02055f0:	010a3b03          	ld	s6,16(s4)
        end = ph->p_va + ph->p_filesz;
ffffffffc02055f4:	020a3483          	ld	s1,32(s4)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02055f8:	77fd                	lui	a5,0xfffff
ffffffffc02055fa:	00fb75b3          	and	a1,s6,a5
        end = ph->p_va + ph->p_filesz;
ffffffffc02055fe:	94da                	add	s1,s1,s6
        while (start < end)
ffffffffc0205600:	1a9b7863          	bgeu	s6,s1,ffffffffc02057b0 <do_execve+0x4b6>
        unsigned char *from = binary + ph->p_offset;
ffffffffc0205604:	008a3903          	ld	s2,8(s4)
ffffffffc0205608:	67e2                	ld	a5,24(sp)
ffffffffc020560a:	993e                	add	s2,s2,a5
ffffffffc020560c:	a881                	j	ffffffffc020565c <do_execve+0x362>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc020560e:	6785                	lui	a5,0x1
ffffffffc0205610:	00f58db3          	add	s11,a1,a5
                size -= la - end;
ffffffffc0205614:	41648633          	sub	a2,s1,s6
            if (end < la)
ffffffffc0205618:	01b4e463          	bltu	s1,s11,ffffffffc0205620 <do_execve+0x326>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc020561c:	416d8633          	sub	a2,s11,s6
    return page - pages + nbase;
ffffffffc0205620:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc0205624:	67c2                	ld	a5,16(sp)
ffffffffc0205626:	000cb503          	ld	a0,0(s9)
    return page - pages + nbase;
ffffffffc020562a:	40d406b3          	sub	a3,s0,a3
ffffffffc020562e:	8699                	srai	a3,a3,0x6
ffffffffc0205630:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0205632:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0205636:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205638:	18a87663          	bgeu	a6,a0,ffffffffc02057c4 <do_execve+0x4ca>
ffffffffc020563c:	000ab503          	ld	a0,0(s5)
ffffffffc0205640:	40bb05b3          	sub	a1,s6,a1
            memcpy(page2kva(page) + off, from, size);
ffffffffc0205644:	e032                	sd	a2,0(sp)
ffffffffc0205646:	9536                	add	a0,a0,a3
ffffffffc0205648:	952e                	add	a0,a0,a1
ffffffffc020564a:	85ca                	mv	a1,s2
ffffffffc020564c:	0fe010ef          	jal	ffffffffc020674a <memcpy>
            start += size, from += size;
ffffffffc0205650:	6602                	ld	a2,0(sp)
ffffffffc0205652:	9b32                	add	s6,s6,a2
ffffffffc0205654:	9932                	add	s2,s2,a2
        while (start < end)
ffffffffc0205656:	049b7863          	bgeu	s6,s1,ffffffffc02056a6 <do_execve+0x3ac>
ffffffffc020565a:	85ee                	mv	a1,s11
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc020565c:	0189b503          	ld	a0,24(s3)
ffffffffc0205660:	6622                	ld	a2,8(sp)
ffffffffc0205662:	e02e                	sd	a1,0(sp)
ffffffffc0205664:	f49fd0ef          	jal	ffffffffc02035ac <pgdir_alloc_page>
ffffffffc0205668:	6582                	ld	a1,0(sp)
ffffffffc020566a:	842a                	mv	s0,a0
ffffffffc020566c:	f14d                	bnez	a0,ffffffffc020560e <do_execve+0x314>
ffffffffc020566e:	6da6                	ld	s11,72(sp)
        ret = -E_NO_MEM;
ffffffffc0205670:	54f1                	li	s1,-4
    exit_mmap(mm);
ffffffffc0205672:	854e                	mv	a0,s3
ffffffffc0205674:	b1cfe0ef          	jal	ffffffffc0203990 <exit_mmap>
ffffffffc0205678:	0189b903          	ld	s2,24(s3)
ffffffffc020567c:	740a                	ld	s0,160(sp)
ffffffffc020567e:	6a0a                	ld	s4,128(sp)
ffffffffc0205680:	b371                	j	ffffffffc020540c <do_execve+0x112>
            exit_mmap(mm);
ffffffffc0205682:	854a                	mv	a0,s2
ffffffffc0205684:	b0cfe0ef          	jal	ffffffffc0203990 <exit_mmap>
            put_pgdir(mm);
ffffffffc0205688:	01893503          	ld	a0,24(s2)
ffffffffc020568c:	a76ff0ef          	jal	ffffffffc0204902 <put_pgdir.isra.0>
            mm_destroy(mm);
ffffffffc0205690:	854a                	mv	a0,s2
ffffffffc0205692:	948fe0ef          	jal	ffffffffc02037da <mm_destroy>
ffffffffc0205696:	b1cd                	j	ffffffffc0205378 <do_execve+0x7e>
        if (ph->p_flags & ELF_PF_R)
ffffffffc0205698:	0e078e63          	beqz	a5,ffffffffc0205794 <do_execve+0x49a>
            perm |= PTE_R;
ffffffffc020569c:	47cd                	li	a5,19
            vm_flags |= VM_READ;
ffffffffc020569e:	00176693          	ori	a3,a4,1
            perm |= PTE_R;
ffffffffc02056a2:	e43e                	sd	a5,8(sp)
ffffffffc02056a4:	bf05                	j	ffffffffc02055d4 <do_execve+0x2da>
        end = ph->p_va + ph->p_memsz;
ffffffffc02056a6:	010a3483          	ld	s1,16(s4)
ffffffffc02056aa:	028a3683          	ld	a3,40(s4)
ffffffffc02056ae:	94b6                	add	s1,s1,a3
        if (start < la)
ffffffffc02056b0:	07bb7c63          	bgeu	s6,s11,ffffffffc0205728 <do_execve+0x42e>
            if (start == end)
ffffffffc02056b4:	df6486e3          	beq	s1,s6,ffffffffc02054a0 <do_execve+0x1a6>
                size -= la - end;
ffffffffc02056b8:	41648933          	sub	s2,s1,s6
            if (end < la)
ffffffffc02056bc:	0fb4f563          	bgeu	s1,s11,ffffffffc02057a6 <do_execve+0x4ac>
    return page - pages + nbase;
ffffffffc02056c0:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc02056c4:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc02056c8:	40d406b3          	sub	a3,s0,a3
ffffffffc02056cc:	8699                	srai	a3,a3,0x6
ffffffffc02056ce:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc02056d0:	00c69593          	slli	a1,a3,0xc
ffffffffc02056d4:	81b1                	srli	a1,a1,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc02056d6:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02056d8:	0ec5f663          	bgeu	a1,a2,ffffffffc02057c4 <do_execve+0x4ca>
ffffffffc02056dc:	000ab603          	ld	a2,0(s5)
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc02056e0:	6505                	lui	a0,0x1
ffffffffc02056e2:	955a                	add	a0,a0,s6
ffffffffc02056e4:	96b2                	add	a3,a3,a2
ffffffffc02056e6:	41b50533          	sub	a0,a0,s11
            memset(page2kva(page) + off, 0, size);
ffffffffc02056ea:	9536                	add	a0,a0,a3
ffffffffc02056ec:	864a                	mv	a2,s2
ffffffffc02056ee:	4581                	li	a1,0
ffffffffc02056f0:	048010ef          	jal	ffffffffc0206738 <memset>
            start += size;
ffffffffc02056f4:	9b4a                	add	s6,s6,s2
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc02056f6:	01b4b6b3          	sltu	a3,s1,s11
ffffffffc02056fa:	01b4f463          	bgeu	s1,s11,ffffffffc0205702 <do_execve+0x408>
ffffffffc02056fe:	db6481e3          	beq	s1,s6,ffffffffc02054a0 <do_execve+0x1a6>
ffffffffc0205702:	e299                	bnez	a3,ffffffffc0205708 <do_execve+0x40e>
ffffffffc0205704:	03bb0263          	beq	s6,s11,ffffffffc0205728 <do_execve+0x42e>
ffffffffc0205708:	00003697          	auipc	a3,0x3
ffffffffc020570c:	ff068693          	addi	a3,a3,-16 # ffffffffc02086f8 <etext+0x1f96>
ffffffffc0205710:	00002617          	auipc	a2,0x2
ffffffffc0205714:	80060613          	addi	a2,a2,-2048 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0205718:	2c200593          	li	a1,706
ffffffffc020571c:	00003517          	auipc	a0,0x3
ffffffffc0205720:	e3450513          	addi	a0,a0,-460 # ffffffffc0208550 <etext+0x1dee>
ffffffffc0205724:	d27fa0ef          	jal	ffffffffc020044a <__panic>
        while (start < end)
ffffffffc0205728:	d69b7ce3          	bgeu	s6,s1,ffffffffc02054a0 <do_execve+0x1a6>
ffffffffc020572c:	56fd                	li	a3,-1
ffffffffc020572e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0205732:	f03e                	sd	a5,32(sp)
ffffffffc0205734:	a0b9                	j	ffffffffc0205782 <do_execve+0x488>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205736:	6785                	lui	a5,0x1
ffffffffc0205738:	00fd8833          	add	a6,s11,a5
                size -= la - end;
ffffffffc020573c:	41648933          	sub	s2,s1,s6
            if (end < la)
ffffffffc0205740:	0104e463          	bltu	s1,a6,ffffffffc0205748 <do_execve+0x44e>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0205744:	41680933          	sub	s2,a6,s6
    return page - pages + nbase;
ffffffffc0205748:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc020574c:	7782                	ld	a5,32(sp)
ffffffffc020574e:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0205752:	40d406b3          	sub	a3,s0,a3
ffffffffc0205756:	8699                	srai	a3,a3,0x6
ffffffffc0205758:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc020575a:	00f6f533          	and	a0,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc020575e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0205760:	06b57263          	bgeu	a0,a1,ffffffffc02057c4 <do_execve+0x4ca>
ffffffffc0205764:	000ab583          	ld	a1,0(s5)
ffffffffc0205768:	41bb0533          	sub	a0,s6,s11
            memset(page2kva(page) + off, 0, size);
ffffffffc020576c:	864a                	mv	a2,s2
ffffffffc020576e:	96ae                	add	a3,a3,a1
ffffffffc0205770:	9536                	add	a0,a0,a3
ffffffffc0205772:	4581                	li	a1,0
            start += size;
ffffffffc0205774:	9b4a                	add	s6,s6,s2
ffffffffc0205776:	e042                	sd	a6,0(sp)
            memset(page2kva(page) + off, 0, size);
ffffffffc0205778:	7c1000ef          	jal	ffffffffc0206738 <memset>
        while (start < end)
ffffffffc020577c:	d29b72e3          	bgeu	s6,s1,ffffffffc02054a0 <do_execve+0x1a6>
ffffffffc0205780:	6d82                	ld	s11,0(sp)
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0205782:	0189b503          	ld	a0,24(s3)
ffffffffc0205786:	6622                	ld	a2,8(sp)
ffffffffc0205788:	85ee                	mv	a1,s11
ffffffffc020578a:	e23fd0ef          	jal	ffffffffc02035ac <pgdir_alloc_page>
ffffffffc020578e:	842a                	mv	s0,a0
ffffffffc0205790:	f15d                	bnez	a0,ffffffffc0205736 <do_execve+0x43c>
ffffffffc0205792:	bdf1                	j	ffffffffc020566e <do_execve+0x374>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205794:	47c5                	li	a5,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc0205796:	86ba                	mv	a3,a4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0205798:	e43e                	sd	a5,8(sp)
ffffffffc020579a:	bd2d                	j	ffffffffc02055d4 <do_execve+0x2da>
            perm |= (PTE_W | PTE_R);
ffffffffc020579c:	47dd                	li	a5,23
            vm_flags |= VM_READ;
ffffffffc020579e:	00376693          	ori	a3,a4,3
            perm |= (PTE_W | PTE_R);
ffffffffc02057a2:	e43e                	sd	a5,8(sp)
ffffffffc02057a4:	bd05                	j	ffffffffc02055d4 <do_execve+0x2da>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc02057a6:	416d8933          	sub	s2,s11,s6
ffffffffc02057aa:	bf19                	j	ffffffffc02056c0 <do_execve+0x3c6>
        return -E_INVAL;
ffffffffc02057ac:	54f5                	li	s1,-3
ffffffffc02057ae:	b3e5                	j	ffffffffc0205596 <do_execve+0x29c>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc02057b0:	8dae                	mv	s11,a1
        while (start < end)
ffffffffc02057b2:	84da                	mv	s1,s6
ffffffffc02057b4:	bddd                	j	ffffffffc02056aa <do_execve+0x3b0>
    int ret = -E_NO_MEM;
ffffffffc02057b6:	54f1                	li	s1,-4
ffffffffc02057b8:	b195                	j	ffffffffc020541c <do_execve+0x122>
ffffffffc02057ba:	6da6                	ld	s11,72(sp)
ffffffffc02057bc:	bd5d                	j	ffffffffc0205672 <do_execve+0x378>
            ret = -E_INVAL_ELF;
ffffffffc02057be:	6da6                	ld	s11,72(sp)
ffffffffc02057c0:	54e1                	li	s1,-8
ffffffffc02057c2:	bd45                	j	ffffffffc0205672 <do_execve+0x378>
ffffffffc02057c4:	00002617          	auipc	a2,0x2
ffffffffc02057c8:	da460613          	addi	a2,a2,-604 # ffffffffc0207568 <etext+0xe06>
ffffffffc02057cc:	07100593          	li	a1,113
ffffffffc02057d0:	00002517          	auipc	a0,0x2
ffffffffc02057d4:	dc050513          	addi	a0,a0,-576 # ffffffffc0207590 <etext+0xe2e>
ffffffffc02057d8:	c73fa0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02057dc:	00002617          	auipc	a2,0x2
ffffffffc02057e0:	d8c60613          	addi	a2,a2,-628 # ffffffffc0207568 <etext+0xe06>
ffffffffc02057e4:	07100593          	li	a1,113
ffffffffc02057e8:	00002517          	auipc	a0,0x2
ffffffffc02057ec:	da850513          	addi	a0,a0,-600 # ffffffffc0207590 <etext+0xe2e>
ffffffffc02057f0:	f122                	sd	s0,160(sp)
ffffffffc02057f2:	e152                	sd	s4,128(sp)
ffffffffc02057f4:	e4ee                	sd	s11,72(sp)
ffffffffc02057f6:	c55fa0ef          	jal	ffffffffc020044a <__panic>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc02057fa:	00002617          	auipc	a2,0x2
ffffffffc02057fe:	e1660613          	addi	a2,a2,-490 # ffffffffc0207610 <etext+0xeae>
ffffffffc0205802:	2e100593          	li	a1,737
ffffffffc0205806:	00003517          	auipc	a0,0x3
ffffffffc020580a:	d4a50513          	addi	a0,a0,-694 # ffffffffc0208550 <etext+0x1dee>
ffffffffc020580e:	e4ee                	sd	s11,72(sp)
ffffffffc0205810:	c3bfa0ef          	jal	ffffffffc020044a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205814:	00003697          	auipc	a3,0x3
ffffffffc0205818:	ffc68693          	addi	a3,a3,-4 # ffffffffc0208810 <etext+0x20ae>
ffffffffc020581c:	00001617          	auipc	a2,0x1
ffffffffc0205820:	6f460613          	addi	a2,a2,1780 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0205824:	2dc00593          	li	a1,732
ffffffffc0205828:	00003517          	auipc	a0,0x3
ffffffffc020582c:	d2850513          	addi	a0,a0,-728 # ffffffffc0208550 <etext+0x1dee>
ffffffffc0205830:	e4ee                	sd	s11,72(sp)
ffffffffc0205832:	c19fa0ef          	jal	ffffffffc020044a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205836:	00003697          	auipc	a3,0x3
ffffffffc020583a:	f9268693          	addi	a3,a3,-110 # ffffffffc02087c8 <etext+0x2066>
ffffffffc020583e:	00001617          	auipc	a2,0x1
ffffffffc0205842:	6d260613          	addi	a2,a2,1746 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0205846:	2db00593          	li	a1,731
ffffffffc020584a:	00003517          	auipc	a0,0x3
ffffffffc020584e:	d0650513          	addi	a0,a0,-762 # ffffffffc0208550 <etext+0x1dee>
ffffffffc0205852:	e4ee                	sd	s11,72(sp)
ffffffffc0205854:	bf7fa0ef          	jal	ffffffffc020044a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0205858:	00003697          	auipc	a3,0x3
ffffffffc020585c:	f2868693          	addi	a3,a3,-216 # ffffffffc0208780 <etext+0x201e>
ffffffffc0205860:	00001617          	auipc	a2,0x1
ffffffffc0205864:	6b060613          	addi	a2,a2,1712 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0205868:	2da00593          	li	a1,730
ffffffffc020586c:	00003517          	auipc	a0,0x3
ffffffffc0205870:	ce450513          	addi	a0,a0,-796 # ffffffffc0208550 <etext+0x1dee>
ffffffffc0205874:	e4ee                	sd	s11,72(sp)
ffffffffc0205876:	bd5fa0ef          	jal	ffffffffc020044a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc020587a:	00003697          	auipc	a3,0x3
ffffffffc020587e:	ebe68693          	addi	a3,a3,-322 # ffffffffc0208738 <etext+0x1fd6>
ffffffffc0205882:	00001617          	auipc	a2,0x1
ffffffffc0205886:	68e60613          	addi	a2,a2,1678 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020588a:	2d900593          	li	a1,729
ffffffffc020588e:	00003517          	auipc	a0,0x3
ffffffffc0205892:	cc250513          	addi	a0,a0,-830 # ffffffffc0208550 <etext+0x1dee>
ffffffffc0205896:	e4ee                	sd	s11,72(sp)
ffffffffc0205898:	bb3fa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020589c <do_yield>:
    current->need_resched = 1;
ffffffffc020589c:	000c7797          	auipc	a5,0xc7
ffffffffc02058a0:	abc7b783          	ld	a5,-1348(a5) # ffffffffc02cc358 <current>
ffffffffc02058a4:	4705                	li	a4,1
}
ffffffffc02058a6:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc02058a8:	ef98                	sd	a4,24(a5)
}
ffffffffc02058aa:	8082                	ret

ffffffffc02058ac <do_wait>:
    if (code_store != NULL)
ffffffffc02058ac:	c59d                	beqz	a1,ffffffffc02058da <do_wait+0x2e>
{
ffffffffc02058ae:	1101                	addi	sp,sp,-32
ffffffffc02058b0:	e02a                	sd	a0,0(sp)
    struct mm_struct *mm = current->mm;
ffffffffc02058b2:	000c7517          	auipc	a0,0xc7
ffffffffc02058b6:	aa653503          	ld	a0,-1370(a0) # ffffffffc02cc358 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc02058ba:	4685                	li	a3,1
ffffffffc02058bc:	4611                	li	a2,4
ffffffffc02058be:	7508                	ld	a0,40(a0)
{
ffffffffc02058c0:	ec06                	sd	ra,24(sp)
ffffffffc02058c2:	e42e                	sd	a1,8(sp)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc02058c4:	c6afe0ef          	jal	ffffffffc0203d2e <user_mem_check>
ffffffffc02058c8:	6702                	ld	a4,0(sp)
ffffffffc02058ca:	67a2                	ld	a5,8(sp)
ffffffffc02058cc:	c909                	beqz	a0,ffffffffc02058de <do_wait+0x32>
}
ffffffffc02058ce:	60e2                	ld	ra,24(sp)
ffffffffc02058d0:	85be                	mv	a1,a5
ffffffffc02058d2:	853a                	mv	a0,a4
ffffffffc02058d4:	6105                	addi	sp,sp,32
ffffffffc02058d6:	f46ff06f          	j	ffffffffc020501c <do_wait.part.0>
ffffffffc02058da:	f42ff06f          	j	ffffffffc020501c <do_wait.part.0>
ffffffffc02058de:	60e2                	ld	ra,24(sp)
ffffffffc02058e0:	5575                	li	a0,-3
ffffffffc02058e2:	6105                	addi	sp,sp,32
ffffffffc02058e4:	8082                	ret

ffffffffc02058e6 <do_kill>:
    if (0 < pid && pid < MAX_PID)
ffffffffc02058e6:	6789                	lui	a5,0x2
ffffffffc02058e8:	fff5071b          	addiw	a4,a0,-1
ffffffffc02058ec:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x70ea>
ffffffffc02058ee:	06e7e463          	bltu	a5,a4,ffffffffc0205956 <do_kill+0x70>
{
ffffffffc02058f2:	1101                	addi	sp,sp,-32
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02058f4:	45a9                	li	a1,10
{
ffffffffc02058f6:	ec06                	sd	ra,24(sp)
ffffffffc02058f8:	e42a                	sd	a0,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02058fa:	1a9000ef          	jal	ffffffffc02062a2 <hash32>
ffffffffc02058fe:	02051793          	slli	a5,a0,0x20
ffffffffc0205902:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205906:	000c3797          	auipc	a5,0xc3
ffffffffc020590a:	9aa78793          	addi	a5,a5,-1622 # ffffffffc02c82b0 <hash_list>
ffffffffc020590e:	96be                	add	a3,a3,a5
        while ((le = list_next(le)) != list)
ffffffffc0205910:	6622                	ld	a2,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205912:	8536                	mv	a0,a3
        while ((le = list_next(le)) != list)
ffffffffc0205914:	a029                	j	ffffffffc020591e <do_kill+0x38>
            if (proc->pid == pid)
ffffffffc0205916:	f2c52703          	lw	a4,-212(a0)
ffffffffc020591a:	00c70963          	beq	a4,a2,ffffffffc020592c <do_kill+0x46>
ffffffffc020591e:	6508                	ld	a0,8(a0)
        while ((le = list_next(le)) != list)
ffffffffc0205920:	fea69be3          	bne	a3,a0,ffffffffc0205916 <do_kill+0x30>
}
ffffffffc0205924:	60e2                	ld	ra,24(sp)
    return -E_INVAL;
ffffffffc0205926:	5575                	li	a0,-3
}
ffffffffc0205928:	6105                	addi	sp,sp,32
ffffffffc020592a:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc020592c:	fd852703          	lw	a4,-40(a0)
ffffffffc0205930:	00177693          	andi	a3,a4,1
ffffffffc0205934:	e29d                	bnez	a3,ffffffffc020595a <do_kill+0x74>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0205936:	4954                	lw	a3,20(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205938:	00176713          	ori	a4,a4,1
ffffffffc020593c:	fce52c23          	sw	a4,-40(a0)
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0205940:	0006c663          	bltz	a3,ffffffffc020594c <do_kill+0x66>
            return 0;
ffffffffc0205944:	4501                	li	a0,0
}
ffffffffc0205946:	60e2                	ld	ra,24(sp)
ffffffffc0205948:	6105                	addi	sp,sp,32
ffffffffc020594a:	8082                	ret
                wakeup_proc(proc);
ffffffffc020594c:	f2850513          	addi	a0,a0,-216
ffffffffc0205950:	420000ef          	jal	ffffffffc0205d70 <wakeup_proc>
ffffffffc0205954:	bfc5                	j	ffffffffc0205944 <do_kill+0x5e>
    return -E_INVAL;
ffffffffc0205956:	5575                	li	a0,-3
}
ffffffffc0205958:	8082                	ret
        return -E_KILLED;
ffffffffc020595a:	555d                	li	a0,-9
ffffffffc020595c:	b7ed                	j	ffffffffc0205946 <do_kill+0x60>

ffffffffc020595e <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc020595e:	1101                	addi	sp,sp,-32
ffffffffc0205960:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205962:	000c7797          	auipc	a5,0xc7
ffffffffc0205966:	94e78793          	addi	a5,a5,-1714 # ffffffffc02cc2b0 <proc_list>
ffffffffc020596a:	ec06                	sd	ra,24(sp)
ffffffffc020596c:	e822                	sd	s0,16(sp)
ffffffffc020596e:	e04a                	sd	s2,0(sp)
ffffffffc0205970:	000c3497          	auipc	s1,0xc3
ffffffffc0205974:	94048493          	addi	s1,s1,-1728 # ffffffffc02c82b0 <hash_list>
ffffffffc0205978:	e79c                	sd	a5,8(a5)
ffffffffc020597a:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc020597c:	000c7717          	auipc	a4,0xc7
ffffffffc0205980:	93470713          	addi	a4,a4,-1740 # ffffffffc02cc2b0 <proc_list>
ffffffffc0205984:	87a6                	mv	a5,s1
ffffffffc0205986:	e79c                	sd	a5,8(a5)
ffffffffc0205988:	e39c                	sd	a5,0(a5)
ffffffffc020598a:	07c1                	addi	a5,a5,16
ffffffffc020598c:	fee79de3          	bne	a5,a4,ffffffffc0205986 <proc_init+0x28>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc0205990:	ecffe0ef          	jal	ffffffffc020485e <alloc_proc>
ffffffffc0205994:	000c7917          	auipc	s2,0xc7
ffffffffc0205998:	9d490913          	addi	s2,s2,-1580 # ffffffffc02cc368 <idleproc>
ffffffffc020599c:	00a93023          	sd	a0,0(s2)
ffffffffc02059a0:	10050363          	beqz	a0,ffffffffc0205aa6 <proc_init+0x148>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc02059a4:	4789                	li	a5,2
ffffffffc02059a6:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02059a8:	00004797          	auipc	a5,0x4
ffffffffc02059ac:	65878793          	addi	a5,a5,1624 # ffffffffc020a000 <bootstack>
ffffffffc02059b0:	e91c                	sd	a5,16(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02059b2:	0b450413          	addi	s0,a0,180
    idleproc->need_resched = 1;
ffffffffc02059b6:	4785                	li	a5,1
ffffffffc02059b8:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02059ba:	4641                	li	a2,16
ffffffffc02059bc:	8522                	mv	a0,s0
ffffffffc02059be:	4581                	li	a1,0
ffffffffc02059c0:	579000ef          	jal	ffffffffc0206738 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02059c4:	8522                	mv	a0,s0
ffffffffc02059c6:	463d                	li	a2,15
ffffffffc02059c8:	00003597          	auipc	a1,0x3
ffffffffc02059cc:	ea858593          	addi	a1,a1,-344 # ffffffffc0208870 <etext+0x210e>
ffffffffc02059d0:	57b000ef          	jal	ffffffffc020674a <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc02059d4:	000c7797          	auipc	a5,0xc7
ffffffffc02059d8:	9807a783          	lw	a5,-1664(a5) # ffffffffc02cc354 <nr_process>

    current = idleproc;
ffffffffc02059dc:	00093703          	ld	a4,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc02059e0:	4601                	li	a2,0
    nr_process++;
ffffffffc02059e2:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc02059e4:	4581                	li	a1,0
ffffffffc02059e6:	00000517          	auipc	a0,0x0
ffffffffc02059ea:	81850513          	addi	a0,a0,-2024 # ffffffffc02051fe <init_main>
    current = idleproc;
ffffffffc02059ee:	000c7697          	auipc	a3,0xc7
ffffffffc02059f2:	96e6b523          	sd	a4,-1686(a3) # ffffffffc02cc358 <current>
    nr_process++;
ffffffffc02059f6:	000c7717          	auipc	a4,0xc7
ffffffffc02059fa:	94f72f23          	sw	a5,-1698(a4) # ffffffffc02cc354 <nr_process>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc02059fe:	c86ff0ef          	jal	ffffffffc0204e84 <kernel_thread>
ffffffffc0205a02:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc0205a04:	08a05563          	blez	a0,ffffffffc0205a8e <proc_init+0x130>
    if (0 < pid && pid < MAX_PID)
ffffffffc0205a08:	6789                	lui	a5,0x2
ffffffffc0205a0a:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x70ea>
ffffffffc0205a0c:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205a10:	02e7e463          	bltu	a5,a4,ffffffffc0205a38 <proc_init+0xda>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205a14:	45a9                	li	a1,10
ffffffffc0205a16:	08d000ef          	jal	ffffffffc02062a2 <hash32>
ffffffffc0205a1a:	02051713          	slli	a4,a0,0x20
ffffffffc0205a1e:	01c75793          	srli	a5,a4,0x1c
ffffffffc0205a22:	00f486b3          	add	a3,s1,a5
ffffffffc0205a26:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0205a28:	a029                	j	ffffffffc0205a32 <proc_init+0xd4>
            if (proc->pid == pid)
ffffffffc0205a2a:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0205a2e:	04870d63          	beq	a4,s0,ffffffffc0205a88 <proc_init+0x12a>
    return listelm->next;
ffffffffc0205a32:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0205a34:	fef69be3          	bne	a3,a5,ffffffffc0205a2a <proc_init+0xcc>
    return NULL;
ffffffffc0205a38:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205a3a:	0b478413          	addi	s0,a5,180
ffffffffc0205a3e:	4641                	li	a2,16
ffffffffc0205a40:	4581                	li	a1,0
ffffffffc0205a42:	8522                	mv	a0,s0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205a44:	000c7717          	auipc	a4,0xc7
ffffffffc0205a48:	90f73e23          	sd	a5,-1764(a4) # ffffffffc02cc360 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0205a4c:	4ed000ef          	jal	ffffffffc0206738 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205a50:	8522                	mv	a0,s0
ffffffffc0205a52:	463d                	li	a2,15
ffffffffc0205a54:	00003597          	auipc	a1,0x3
ffffffffc0205a58:	e4458593          	addi	a1,a1,-444 # ffffffffc0208898 <etext+0x2136>
ffffffffc0205a5c:	4ef000ef          	jal	ffffffffc020674a <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205a60:	00093783          	ld	a5,0(s2)
ffffffffc0205a64:	cfad                	beqz	a5,ffffffffc0205ade <proc_init+0x180>
ffffffffc0205a66:	43dc                	lw	a5,4(a5)
ffffffffc0205a68:	ebbd                	bnez	a5,ffffffffc0205ade <proc_init+0x180>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205a6a:	000c7797          	auipc	a5,0xc7
ffffffffc0205a6e:	8f67b783          	ld	a5,-1802(a5) # ffffffffc02cc360 <initproc>
ffffffffc0205a72:	c7b1                	beqz	a5,ffffffffc0205abe <proc_init+0x160>
ffffffffc0205a74:	43d8                	lw	a4,4(a5)
ffffffffc0205a76:	4785                	li	a5,1
ffffffffc0205a78:	04f71363          	bne	a4,a5,ffffffffc0205abe <proc_init+0x160>
}
ffffffffc0205a7c:	60e2                	ld	ra,24(sp)
ffffffffc0205a7e:	6442                	ld	s0,16(sp)
ffffffffc0205a80:	64a2                	ld	s1,8(sp)
ffffffffc0205a82:	6902                	ld	s2,0(sp)
ffffffffc0205a84:	6105                	addi	sp,sp,32
ffffffffc0205a86:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0205a88:	f2878793          	addi	a5,a5,-216
ffffffffc0205a8c:	b77d                	j	ffffffffc0205a3a <proc_init+0xdc>
        panic("create init_main failed.\n");
ffffffffc0205a8e:	00003617          	auipc	a2,0x3
ffffffffc0205a92:	dea60613          	addi	a2,a2,-534 # ffffffffc0208878 <etext+0x2116>
ffffffffc0205a96:	40400593          	li	a1,1028
ffffffffc0205a9a:	00003517          	auipc	a0,0x3
ffffffffc0205a9e:	ab650513          	addi	a0,a0,-1354 # ffffffffc0208550 <etext+0x1dee>
ffffffffc0205aa2:	9a9fa0ef          	jal	ffffffffc020044a <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0205aa6:	00003617          	auipc	a2,0x3
ffffffffc0205aaa:	db260613          	addi	a2,a2,-590 # ffffffffc0208858 <etext+0x20f6>
ffffffffc0205aae:	3f500593          	li	a1,1013
ffffffffc0205ab2:	00003517          	auipc	a0,0x3
ffffffffc0205ab6:	a9e50513          	addi	a0,a0,-1378 # ffffffffc0208550 <etext+0x1dee>
ffffffffc0205aba:	991fa0ef          	jal	ffffffffc020044a <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0205abe:	00003697          	auipc	a3,0x3
ffffffffc0205ac2:	e0a68693          	addi	a3,a3,-502 # ffffffffc02088c8 <etext+0x2166>
ffffffffc0205ac6:	00001617          	auipc	a2,0x1
ffffffffc0205aca:	44a60613          	addi	a2,a2,1098 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0205ace:	40b00593          	li	a1,1035
ffffffffc0205ad2:	00003517          	auipc	a0,0x3
ffffffffc0205ad6:	a7e50513          	addi	a0,a0,-1410 # ffffffffc0208550 <etext+0x1dee>
ffffffffc0205ada:	971fa0ef          	jal	ffffffffc020044a <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0205ade:	00003697          	auipc	a3,0x3
ffffffffc0205ae2:	dc268693          	addi	a3,a3,-574 # ffffffffc02088a0 <etext+0x213e>
ffffffffc0205ae6:	00001617          	auipc	a2,0x1
ffffffffc0205aea:	42a60613          	addi	a2,a2,1066 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0205aee:	40a00593          	li	a1,1034
ffffffffc0205af2:	00003517          	auipc	a0,0x3
ffffffffc0205af6:	a5e50513          	addi	a0,a0,-1442 # ffffffffc0208550 <etext+0x1dee>
ffffffffc0205afa:	951fa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0205afe <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc0205afe:	1141                	addi	sp,sp,-16
ffffffffc0205b00:	e022                	sd	s0,0(sp)
ffffffffc0205b02:	e406                	sd	ra,8(sp)
ffffffffc0205b04:	000c7417          	auipc	s0,0xc7
ffffffffc0205b08:	85440413          	addi	s0,s0,-1964 # ffffffffc02cc358 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc0205b0c:	6018                	ld	a4,0(s0)
ffffffffc0205b0e:	6f1c                	ld	a5,24(a4)
ffffffffc0205b10:	dffd                	beqz	a5,ffffffffc0205b0e <cpu_idle+0x10>
        {
            schedule();
ffffffffc0205b12:	356000ef          	jal	ffffffffc0205e68 <schedule>
ffffffffc0205b16:	bfdd                	j	ffffffffc0205b0c <cpu_idle+0xe>

ffffffffc0205b18 <lab6_set_priority>:
        }
    }
}
// FOR LAB6, set the process's priority (bigger value will get more CPU time)
void lab6_set_priority(uint32_t priority)
{
ffffffffc0205b18:	1101                	addi	sp,sp,-32
ffffffffc0205b1a:	85aa                	mv	a1,a0
    cprintf("set priority to %d\n", priority);
ffffffffc0205b1c:	e42a                	sd	a0,8(sp)
ffffffffc0205b1e:	00003517          	auipc	a0,0x3
ffffffffc0205b22:	dd250513          	addi	a0,a0,-558 # ffffffffc02088f0 <etext+0x218e>
{
ffffffffc0205b26:	ec06                	sd	ra,24(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc0205b28:	e70fa0ef          	jal	ffffffffc0200198 <cprintf>
    if (priority == 0)
ffffffffc0205b2c:	65a2                	ld	a1,8(sp)
        current->lab6_priority = 1;
ffffffffc0205b2e:	000c7717          	auipc	a4,0xc7
ffffffffc0205b32:	82a73703          	ld	a4,-2006(a4) # ffffffffc02cc358 <current>
    if (priority == 0)
ffffffffc0205b36:	4785                	li	a5,1
ffffffffc0205b38:	c191                	beqz	a1,ffffffffc0205b3c <lab6_set_priority+0x24>
ffffffffc0205b3a:	87ae                	mv	a5,a1
    else
        current->lab6_priority = priority;
}
ffffffffc0205b3c:	60e2                	ld	ra,24(sp)
        current->lab6_priority = 1;
ffffffffc0205b3e:	14f72223          	sw	a5,324(a4)
}
ffffffffc0205b42:	6105                	addi	sp,sp,32
ffffffffc0205b44:	8082                	ret

ffffffffc0205b46 <do_sleep>:
// do_sleep - set current process state to sleep and add timer with "time"
//          - then call scheduler. if process run again, delete timer first.
int do_sleep(unsigned int time)
{
    if (time == 0)
ffffffffc0205b46:	c531                	beqz	a0,ffffffffc0205b92 <do_sleep+0x4c>
{
ffffffffc0205b48:	7139                	addi	sp,sp,-64
ffffffffc0205b4a:	fc06                	sd	ra,56(sp)
ffffffffc0205b4c:	f822                	sd	s0,48(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205b4e:	100027f3          	csrr	a5,sstatus
ffffffffc0205b52:	8b89                	andi	a5,a5,2
ffffffffc0205b54:	e3a9                	bnez	a5,ffffffffc0205b96 <do_sleep+0x50>
    {
        return 0;
    }
    bool intr_flag;
    local_intr_save(intr_flag);
    timer_t __timer, *timer = timer_init(&__timer, current, time);
ffffffffc0205b56:	000c7797          	auipc	a5,0xc7
ffffffffc0205b5a:	8027b783          	ld	a5,-2046(a5) # ffffffffc02cc358 <current>
    elm->prev = elm->next = elm;
ffffffffc0205b5e:	1014                	addi	a3,sp,32
    current->state = PROC_SLEEPING;
    current->wait_state = WT_TIMER;
ffffffffc0205b60:	80000737          	lui	a4,0x80000
to_struct((le), timer_t, member)

// init a timer
static inline timer_t *
timer_init(timer_t *timer, struct proc_struct *proc, int expires) {
    timer->expires = expires;
ffffffffc0205b64:	c82a                	sw	a0,16(sp)
ffffffffc0205b66:	f436                	sd	a3,40(sp)
ffffffffc0205b68:	f036                	sd	a3,32(sp)
    timer->proc = proc;
ffffffffc0205b6a:	ec3e                	sd	a5,24(sp)
    current->state = PROC_SLEEPING;
ffffffffc0205b6c:	4685                	li	a3,1
    current->wait_state = WT_TIMER;
ffffffffc0205b6e:	0709                	addi	a4,a4,2 # ffffffff80000002 <_binary_obj___user_matrix_out_size+0xffffffff7fff491a>
ffffffffc0205b70:	0808                	addi	a0,sp,16
    current->state = PROC_SLEEPING;
ffffffffc0205b72:	c394                	sw	a3,0(a5)
    current->wait_state = WT_TIMER;
ffffffffc0205b74:	0ee7a623          	sw	a4,236(a5)
ffffffffc0205b78:	842a                	mv	s0,a0
    add_timer(timer);
ffffffffc0205b7a:	3a4000ef          	jal	ffffffffc0205f1e <add_timer>
    local_intr_restore(intr_flag);

    schedule();
ffffffffc0205b7e:	2ea000ef          	jal	ffffffffc0205e68 <schedule>

    del_timer(timer);
ffffffffc0205b82:	8522                	mv	a0,s0
ffffffffc0205b84:	460000ef          	jal	ffffffffc0205fe4 <del_timer>
    return 0;
}
ffffffffc0205b88:	70e2                	ld	ra,56(sp)
ffffffffc0205b8a:	7442                	ld	s0,48(sp)
ffffffffc0205b8c:	4501                	li	a0,0
ffffffffc0205b8e:	6121                	addi	sp,sp,64
ffffffffc0205b90:	8082                	ret
ffffffffc0205b92:	4501                	li	a0,0
ffffffffc0205b94:	8082                	ret
        intr_disable();
ffffffffc0205b96:	e42a                	sd	a0,8(sp)
ffffffffc0205b98:	d67fa0ef          	jal	ffffffffc02008fe <intr_disable>
    timer_t __timer, *timer = timer_init(&__timer, current, time);
ffffffffc0205b9c:	000c6797          	auipc	a5,0xc6
ffffffffc0205ba0:	7bc7b783          	ld	a5,1980(a5) # ffffffffc02cc358 <current>
    timer->expires = expires;
ffffffffc0205ba4:	6522                	ld	a0,8(sp)
ffffffffc0205ba6:	1014                	addi	a3,sp,32
    current->wait_state = WT_TIMER;
ffffffffc0205ba8:	80000737          	lui	a4,0x80000
ffffffffc0205bac:	c82a                	sw	a0,16(sp)
ffffffffc0205bae:	f436                	sd	a3,40(sp)
ffffffffc0205bb0:	f036                	sd	a3,32(sp)
    timer->proc = proc;
ffffffffc0205bb2:	ec3e                	sd	a5,24(sp)
    current->state = PROC_SLEEPING;
ffffffffc0205bb4:	4685                	li	a3,1
    current->wait_state = WT_TIMER;
ffffffffc0205bb6:	0709                	addi	a4,a4,2 # ffffffff80000002 <_binary_obj___user_matrix_out_size+0xffffffff7fff491a>
ffffffffc0205bb8:	0808                	addi	a0,sp,16
    current->state = PROC_SLEEPING;
ffffffffc0205bba:	c394                	sw	a3,0(a5)
    current->wait_state = WT_TIMER;
ffffffffc0205bbc:	0ee7a623          	sw	a4,236(a5)
ffffffffc0205bc0:	842a                	mv	s0,a0
    add_timer(timer);
ffffffffc0205bc2:	35c000ef          	jal	ffffffffc0205f1e <add_timer>
        intr_enable();
ffffffffc0205bc6:	d33fa0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0205bca:	bf55                	j	ffffffffc0205b7e <do_sleep+0x38>

ffffffffc0205bcc <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205bcc:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0205bd0:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0205bd4:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0205bd6:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205bd8:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0205bdc:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0205be0:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0205be4:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0205be8:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0205bec:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0205bf0:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0205bf4:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0205bf8:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0205bfc:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0205c00:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0205c04:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0205c08:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0205c0a:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0205c0c:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0205c10:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc0205c14:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0205c18:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0205c1c:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0205c20:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc0205c24:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0205c28:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0205c2c:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0205c30:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc0205c34:	8082                	ret

ffffffffc0205c36 <RR_init>:
ffffffffc0205c36:	e508                	sd	a0,8(a0)
ffffffffc0205c38:	e108                	sd	a0,0(a0)
 */
static void
RR_init(struct run_queue *rq)
{
    list_init(&(rq->run_list));
    rq->proc_num = 0;
ffffffffc0205c3a:	00052823          	sw	zero,16(a0)
}
ffffffffc0205c3e:	8082                	ret

ffffffffc0205c40 <RR_pick_next>:
    return listelm->next;
ffffffffc0205c40:	651c                	ld	a5,8(a0)
 */
static struct proc_struct *
RR_pick_next(struct run_queue *rq)
{
    list_entry_t *le = list_next(&(rq->run_list));
    if (le != &(rq->run_list)) {
ffffffffc0205c42:	00f50563          	beq	a0,a5,ffffffffc0205c4c <RR_pick_next+0xc>
        return le2proc(le, run_link);
ffffffffc0205c46:	ef078513          	addi	a0,a5,-272
ffffffffc0205c4a:	8082                	ret
    }
    return NULL;
ffffffffc0205c4c:	4501                	li	a0,0
}
ffffffffc0205c4e:	8082                	ret

ffffffffc0205c50 <RR_proc_tick>:
 * is the flag variable for process switching.
 */
static void
RR_proc_tick(struct run_queue *rq, struct proc_struct *proc)
{
    if (proc->time_slice > 0) {
ffffffffc0205c50:	1205a783          	lw	a5,288(a1)
ffffffffc0205c54:	00f05563          	blez	a5,ffffffffc0205c5e <RR_proc_tick+0xe>
        proc->time_slice --;
ffffffffc0205c58:	37fd                	addiw	a5,a5,-1
ffffffffc0205c5a:	12f5a023          	sw	a5,288(a1)
    }
    if (proc->time_slice == 0) {
ffffffffc0205c5e:	e399                	bnez	a5,ffffffffc0205c64 <RR_proc_tick+0x14>
        proc->need_resched = 1;
ffffffffc0205c60:	4785                	li	a5,1
ffffffffc0205c62:	ed9c                	sd	a5,24(a1)
    }
}
ffffffffc0205c64:	8082                	ret

ffffffffc0205c66 <RR_dequeue>:
    return list->next == list;
ffffffffc0205c66:	1185b703          	ld	a4,280(a1)
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
ffffffffc0205c6a:	11058793          	addi	a5,a1,272
ffffffffc0205c6e:	02e78263          	beq	a5,a4,ffffffffc0205c92 <RR_dequeue+0x2c>
ffffffffc0205c72:	1085b683          	ld	a3,264(a1)
ffffffffc0205c76:	00a69e63          	bne	a3,a0,ffffffffc0205c92 <RR_dequeue+0x2c>
    __list_del(listelm->prev, listelm->next);
ffffffffc0205c7a:	1105b503          	ld	a0,272(a1)
    rq->proc_num --;
ffffffffc0205c7e:	4a90                	lw	a2,16(a3)
    prev->next = next;
ffffffffc0205c80:	e518                	sd	a4,8(a0)
    next->prev = prev;
ffffffffc0205c82:	e308                	sd	a0,0(a4)
    elm->prev = elm->next = elm;
ffffffffc0205c84:	10f5bc23          	sd	a5,280(a1)
ffffffffc0205c88:	10f5b823          	sd	a5,272(a1)
ffffffffc0205c8c:	367d                	addiw	a2,a2,-1
ffffffffc0205c8e:	ca90                	sw	a2,16(a3)
ffffffffc0205c90:	8082                	ret
{
ffffffffc0205c92:	1141                	addi	sp,sp,-16
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
ffffffffc0205c94:	00003697          	auipc	a3,0x3
ffffffffc0205c98:	c7468693          	addi	a3,a3,-908 # ffffffffc0208908 <etext+0x21a6>
ffffffffc0205c9c:	00001617          	auipc	a2,0x1
ffffffffc0205ca0:	27460613          	addi	a2,a2,628 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0205ca4:	03900593          	li	a1,57
ffffffffc0205ca8:	00003517          	auipc	a0,0x3
ffffffffc0205cac:	c9850513          	addi	a0,a0,-872 # ffffffffc0208940 <etext+0x21de>
{
ffffffffc0205cb0:	e406                	sd	ra,8(sp)
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
ffffffffc0205cb2:	f98fa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0205cb6 <RR_enqueue>:
    assert(list_empty(&(proc->run_link)));
ffffffffc0205cb6:	1185b703          	ld	a4,280(a1)
ffffffffc0205cba:	11058793          	addi	a5,a1,272
ffffffffc0205cbe:	02e79d63          	bne	a5,a4,ffffffffc0205cf8 <RR_enqueue+0x42>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0205cc2:	6118                	ld	a4,0(a0)
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc0205cc4:	1205a683          	lw	a3,288(a1)
    prev->next = next->prev = elm;
ffffffffc0205cc8:	e11c                	sd	a5,0(a0)
ffffffffc0205cca:	e71c                	sd	a5,8(a4)
    elm->prev = prev;
ffffffffc0205ccc:	10e5b823          	sd	a4,272(a1)
    elm->next = next;
ffffffffc0205cd0:	10a5bc23          	sd	a0,280(a1)
ffffffffc0205cd4:	495c                	lw	a5,20(a0)
ffffffffc0205cd6:	ea89                	bnez	a3,ffffffffc0205ce8 <RR_enqueue+0x32>
        proc->time_slice = rq->max_time_slice;
ffffffffc0205cd8:	12f5a023          	sw	a5,288(a1)
    rq->proc_num ++;
ffffffffc0205cdc:	491c                	lw	a5,16(a0)
    proc->rq = rq;
ffffffffc0205cde:	10a5b423          	sd	a0,264(a1)
    rq->proc_num ++;
ffffffffc0205ce2:	2785                	addiw	a5,a5,1
ffffffffc0205ce4:	c91c                	sw	a5,16(a0)
ffffffffc0205ce6:	8082                	ret
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc0205ce8:	fed7c8e3          	blt	a5,a3,ffffffffc0205cd8 <RR_enqueue+0x22>
    rq->proc_num ++;
ffffffffc0205cec:	491c                	lw	a5,16(a0)
    proc->rq = rq;
ffffffffc0205cee:	10a5b423          	sd	a0,264(a1)
    rq->proc_num ++;
ffffffffc0205cf2:	2785                	addiw	a5,a5,1
ffffffffc0205cf4:	c91c                	sw	a5,16(a0)
ffffffffc0205cf6:	8082                	ret
{
ffffffffc0205cf8:	1141                	addi	sp,sp,-16
    assert(list_empty(&(proc->run_link)));
ffffffffc0205cfa:	00003697          	auipc	a3,0x3
ffffffffc0205cfe:	c6668693          	addi	a3,a3,-922 # ffffffffc0208960 <etext+0x21fe>
ffffffffc0205d02:	00001617          	auipc	a2,0x1
ffffffffc0205d06:	20e60613          	addi	a2,a2,526 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0205d0a:	02600593          	li	a1,38
ffffffffc0205d0e:	00003517          	auipc	a0,0x3
ffffffffc0205d12:	c3250513          	addi	a0,a0,-974 # ffffffffc0208940 <etext+0x21de>
{
ffffffffc0205d16:	e406                	sd	ra,8(sp)
    assert(list_empty(&(proc->run_link)));
ffffffffc0205d18:	f32fa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0205d1c <sched_init>:

void
sched_init(void) {
    list_init(&timer_list);

    sched_class = &default_sched_class;
ffffffffc0205d1c:	000c2797          	auipc	a5,0xc2
ffffffffc0205d20:	fe478793          	addi	a5,a5,-28 # ffffffffc02c7d00 <default_sched_class>
sched_init(void) {
ffffffffc0205d24:	1141                	addi	sp,sp,-16

    rq = &__rq;
    rq->max_time_slice = MAX_TIME_SLICE;
    sched_class->init(rq);
ffffffffc0205d26:	6794                	ld	a3,8(a5)
    sched_class = &default_sched_class;
ffffffffc0205d28:	000c6717          	auipc	a4,0xc6
ffffffffc0205d2c:	64f73823          	sd	a5,1616(a4) # ffffffffc02cc378 <sched_class>
sched_init(void) {
ffffffffc0205d30:	e406                	sd	ra,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0205d32:	000c6797          	auipc	a5,0xc6
ffffffffc0205d36:	5ae78793          	addi	a5,a5,1454 # ffffffffc02cc2e0 <timer_list>
    rq = &__rq;
ffffffffc0205d3a:	000c6717          	auipc	a4,0xc6
ffffffffc0205d3e:	58670713          	addi	a4,a4,1414 # ffffffffc02cc2c0 <__rq>
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc0205d42:	4615                	li	a2,5
ffffffffc0205d44:	e79c                	sd	a5,8(a5)
ffffffffc0205d46:	e39c                	sd	a5,0(a5)
    sched_class->init(rq);
ffffffffc0205d48:	853a                	mv	a0,a4
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc0205d4a:	cb50                	sw	a2,20(a4)
    rq = &__rq;
ffffffffc0205d4c:	000c6797          	auipc	a5,0xc6
ffffffffc0205d50:	62e7b223          	sd	a4,1572(a5) # ffffffffc02cc370 <rq>
    sched_class->init(rq);
ffffffffc0205d54:	9682                	jalr	a3

    cprintf("sched class: %s\n", sched_class->name);
ffffffffc0205d56:	000c6797          	auipc	a5,0xc6
ffffffffc0205d5a:	6227b783          	ld	a5,1570(a5) # ffffffffc02cc378 <sched_class>
}
ffffffffc0205d5e:	60a2                	ld	ra,8(sp)
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc0205d60:	00003517          	auipc	a0,0x3
ffffffffc0205d64:	c3050513          	addi	a0,a0,-976 # ffffffffc0208990 <etext+0x222e>
ffffffffc0205d68:	638c                	ld	a1,0(a5)
}
ffffffffc0205d6a:	0141                	addi	sp,sp,16
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc0205d6c:	c2cfa06f          	j	ffffffffc0200198 <cprintf>

ffffffffc0205d70 <wakeup_proc>:

void
wakeup_proc(struct proc_struct *proc) {
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205d70:	4118                	lw	a4,0(a0)
wakeup_proc(struct proc_struct *proc) {
ffffffffc0205d72:	1101                	addi	sp,sp,-32
ffffffffc0205d74:	ec06                	sd	ra,24(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205d76:	478d                	li	a5,3
ffffffffc0205d78:	0cf70863          	beq	a4,a5,ffffffffc0205e48 <wakeup_proc+0xd8>
ffffffffc0205d7c:	85aa                	mv	a1,a0
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205d7e:	100027f3          	csrr	a5,sstatus
ffffffffc0205d82:	8b89                	andi	a5,a5,2
ffffffffc0205d84:	e3b1                	bnez	a5,ffffffffc0205dc8 <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205d86:	4789                	li	a5,2
ffffffffc0205d88:	08f70563          	beq	a4,a5,ffffffffc0205e12 <wakeup_proc+0xa2>
            proc->state = PROC_RUNNABLE;
            proc->wait_state = 0;
            if (proc != current) {
ffffffffc0205d8c:	000c6717          	auipc	a4,0xc6
ffffffffc0205d90:	5cc73703          	ld	a4,1484(a4) # ffffffffc02cc358 <current>
            proc->wait_state = 0;
ffffffffc0205d94:	0e052623          	sw	zero,236(a0)
            proc->state = PROC_RUNNABLE;
ffffffffc0205d98:	c11c                	sw	a5,0(a0)
            if (proc != current) {
ffffffffc0205d9a:	02e50463          	beq	a0,a4,ffffffffc0205dc2 <wakeup_proc+0x52>
    if (proc != idleproc) {
ffffffffc0205d9e:	000c6797          	auipc	a5,0xc6
ffffffffc0205da2:	5ca7b783          	ld	a5,1482(a5) # ffffffffc02cc368 <idleproc>
ffffffffc0205da6:	00f50e63          	beq	a0,a5,ffffffffc0205dc2 <wakeup_proc+0x52>
        sched_class->enqueue(rq, proc);
ffffffffc0205daa:	000c6797          	auipc	a5,0xc6
ffffffffc0205dae:	5ce7b783          	ld	a5,1486(a5) # ffffffffc02cc378 <sched_class>
        else {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205db2:	60e2                	ld	ra,24(sp)
        sched_class->enqueue(rq, proc);
ffffffffc0205db4:	000c6517          	auipc	a0,0xc6
ffffffffc0205db8:	5bc53503          	ld	a0,1468(a0) # ffffffffc02cc370 <rq>
ffffffffc0205dbc:	6b9c                	ld	a5,16(a5)
}
ffffffffc0205dbe:	6105                	addi	sp,sp,32
        sched_class->enqueue(rq, proc);
ffffffffc0205dc0:	8782                	jr	a5
}
ffffffffc0205dc2:	60e2                	ld	ra,24(sp)
ffffffffc0205dc4:	6105                	addi	sp,sp,32
ffffffffc0205dc6:	8082                	ret
        intr_disable();
ffffffffc0205dc8:	e42a                	sd	a0,8(sp)
ffffffffc0205dca:	b35fa0ef          	jal	ffffffffc02008fe <intr_disable>
        if (proc->state != PROC_RUNNABLE) {
ffffffffc0205dce:	65a2                	ld	a1,8(sp)
ffffffffc0205dd0:	4789                	li	a5,2
ffffffffc0205dd2:	4198                	lw	a4,0(a1)
ffffffffc0205dd4:	04f70d63          	beq	a4,a5,ffffffffc0205e2e <wakeup_proc+0xbe>
            if (proc != current) {
ffffffffc0205dd8:	000c6717          	auipc	a4,0xc6
ffffffffc0205ddc:	58073703          	ld	a4,1408(a4) # ffffffffc02cc358 <current>
            proc->wait_state = 0;
ffffffffc0205de0:	0e05a623          	sw	zero,236(a1)
            proc->state = PROC_RUNNABLE;
ffffffffc0205de4:	c19c                	sw	a5,0(a1)
            if (proc != current) {
ffffffffc0205de6:	02e58263          	beq	a1,a4,ffffffffc0205e0a <wakeup_proc+0x9a>
    if (proc != idleproc) {
ffffffffc0205dea:	000c6797          	auipc	a5,0xc6
ffffffffc0205dee:	57e7b783          	ld	a5,1406(a5) # ffffffffc02cc368 <idleproc>
ffffffffc0205df2:	00f58c63          	beq	a1,a5,ffffffffc0205e0a <wakeup_proc+0x9a>
        sched_class->enqueue(rq, proc);
ffffffffc0205df6:	000c6797          	auipc	a5,0xc6
ffffffffc0205dfa:	5827b783          	ld	a5,1410(a5) # ffffffffc02cc378 <sched_class>
ffffffffc0205dfe:	000c6517          	auipc	a0,0xc6
ffffffffc0205e02:	57253503          	ld	a0,1394(a0) # ffffffffc02cc370 <rq>
ffffffffc0205e06:	6b9c                	ld	a5,16(a5)
ffffffffc0205e08:	9782                	jalr	a5
}
ffffffffc0205e0a:	60e2                	ld	ra,24(sp)
ffffffffc0205e0c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205e0e:	aebfa06f          	j	ffffffffc02008f8 <intr_enable>
ffffffffc0205e12:	60e2                	ld	ra,24(sp)
            warn("wakeup runnable process.\n");
ffffffffc0205e14:	00003617          	auipc	a2,0x3
ffffffffc0205e18:	bcc60613          	addi	a2,a2,-1076 # ffffffffc02089e0 <etext+0x227e>
ffffffffc0205e1c:	04800593          	li	a1,72
ffffffffc0205e20:	00003517          	auipc	a0,0x3
ffffffffc0205e24:	ba850513          	addi	a0,a0,-1112 # ffffffffc02089c8 <etext+0x2266>
}
ffffffffc0205e28:	6105                	addi	sp,sp,32
            warn("wakeup runnable process.\n");
ffffffffc0205e2a:	e8afa06f          	j	ffffffffc02004b4 <__warn>
ffffffffc0205e2e:	00003617          	auipc	a2,0x3
ffffffffc0205e32:	bb260613          	addi	a2,a2,-1102 # ffffffffc02089e0 <etext+0x227e>
ffffffffc0205e36:	04800593          	li	a1,72
ffffffffc0205e3a:	00003517          	auipc	a0,0x3
ffffffffc0205e3e:	b8e50513          	addi	a0,a0,-1138 # ffffffffc02089c8 <etext+0x2266>
ffffffffc0205e42:	e72fa0ef          	jal	ffffffffc02004b4 <__warn>
    if (flag) {
ffffffffc0205e46:	b7d1                	j	ffffffffc0205e0a <wakeup_proc+0x9a>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205e48:	00003697          	auipc	a3,0x3
ffffffffc0205e4c:	b6068693          	addi	a3,a3,-1184 # ffffffffc02089a8 <etext+0x2246>
ffffffffc0205e50:	00001617          	auipc	a2,0x1
ffffffffc0205e54:	0c060613          	addi	a2,a2,192 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0205e58:	03c00593          	li	a1,60
ffffffffc0205e5c:	00003517          	auipc	a0,0x3
ffffffffc0205e60:	b6c50513          	addi	a0,a0,-1172 # ffffffffc02089c8 <etext+0x2266>
ffffffffc0205e64:	de6fa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0205e68 <schedule>:

void
schedule(void) {
ffffffffc0205e68:	7139                	addi	sp,sp,-64
ffffffffc0205e6a:	fc06                	sd	ra,56(sp)
ffffffffc0205e6c:	f822                	sd	s0,48(sp)
ffffffffc0205e6e:	f426                	sd	s1,40(sp)
ffffffffc0205e70:	f04a                	sd	s2,32(sp)
ffffffffc0205e72:	ec4e                	sd	s3,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205e74:	100027f3          	csrr	a5,sstatus
ffffffffc0205e78:	8b89                	andi	a5,a5,2
ffffffffc0205e7a:	4981                	li	s3,0
ffffffffc0205e7c:	efc9                	bnez	a5,ffffffffc0205f16 <schedule+0xae>
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205e7e:	000c6417          	auipc	s0,0xc6
ffffffffc0205e82:	4da40413          	addi	s0,s0,1242 # ffffffffc02cc358 <current>
ffffffffc0205e86:	600c                	ld	a1,0(s0)
        if (current->state == PROC_RUNNABLE) {
ffffffffc0205e88:	4789                	li	a5,2
ffffffffc0205e8a:	000c6497          	auipc	s1,0xc6
ffffffffc0205e8e:	4e648493          	addi	s1,s1,1254 # ffffffffc02cc370 <rq>
ffffffffc0205e92:	4198                	lw	a4,0(a1)
        current->need_resched = 0;
ffffffffc0205e94:	0005bc23          	sd	zero,24(a1)
        if (current->state == PROC_RUNNABLE) {
ffffffffc0205e98:	000c6917          	auipc	s2,0xc6
ffffffffc0205e9c:	4e090913          	addi	s2,s2,1248 # ffffffffc02cc378 <sched_class>
ffffffffc0205ea0:	04f70f63          	beq	a4,a5,ffffffffc0205efe <schedule+0x96>
    return sched_class->pick_next(rq);
ffffffffc0205ea4:	00093783          	ld	a5,0(s2)
ffffffffc0205ea8:	6088                	ld	a0,0(s1)
ffffffffc0205eaa:	739c                	ld	a5,32(a5)
ffffffffc0205eac:	9782                	jalr	a5
ffffffffc0205eae:	85aa                	mv	a1,a0
            sched_class_enqueue(current);
        }
        if ((next = sched_class_pick_next()) != NULL) {
ffffffffc0205eb0:	c131                	beqz	a0,ffffffffc0205ef4 <schedule+0x8c>
    sched_class->dequeue(rq, proc);
ffffffffc0205eb2:	00093783          	ld	a5,0(s2)
ffffffffc0205eb6:	6088                	ld	a0,0(s1)
ffffffffc0205eb8:	e42e                	sd	a1,8(sp)
ffffffffc0205eba:	6f9c                	ld	a5,24(a5)
ffffffffc0205ebc:	9782                	jalr	a5
ffffffffc0205ebe:	65a2                	ld	a1,8(sp)
            sched_class_dequeue(next);
        }
        if (next == NULL) {
            next = idleproc;
        }
        next->runs ++;
ffffffffc0205ec0:	459c                	lw	a5,8(a1)
        if (next != current) {
ffffffffc0205ec2:	6018                	ld	a4,0(s0)
        next->runs ++;
ffffffffc0205ec4:	2785                	addiw	a5,a5,1
ffffffffc0205ec6:	c59c                	sw	a5,8(a1)
        if (next != current) {
ffffffffc0205ec8:	00b70563          	beq	a4,a1,ffffffffc0205ed2 <schedule+0x6a>
            proc_run(next);
ffffffffc0205ecc:	852e                	mv	a0,a1
ffffffffc0205ece:	ad7fe0ef          	jal	ffffffffc02049a4 <proc_run>
    if (flag) {
ffffffffc0205ed2:	00099963          	bnez	s3,ffffffffc0205ee4 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205ed6:	70e2                	ld	ra,56(sp)
ffffffffc0205ed8:	7442                	ld	s0,48(sp)
ffffffffc0205eda:	74a2                	ld	s1,40(sp)
ffffffffc0205edc:	7902                	ld	s2,32(sp)
ffffffffc0205ede:	69e2                	ld	s3,24(sp)
ffffffffc0205ee0:	6121                	addi	sp,sp,64
ffffffffc0205ee2:	8082                	ret
ffffffffc0205ee4:	7442                	ld	s0,48(sp)
ffffffffc0205ee6:	70e2                	ld	ra,56(sp)
ffffffffc0205ee8:	74a2                	ld	s1,40(sp)
ffffffffc0205eea:	7902                	ld	s2,32(sp)
ffffffffc0205eec:	69e2                	ld	s3,24(sp)
ffffffffc0205eee:	6121                	addi	sp,sp,64
        intr_enable();
ffffffffc0205ef0:	a09fa06f          	j	ffffffffc02008f8 <intr_enable>
            next = idleproc;
ffffffffc0205ef4:	000c6597          	auipc	a1,0xc6
ffffffffc0205ef8:	4745b583          	ld	a1,1140(a1) # ffffffffc02cc368 <idleproc>
ffffffffc0205efc:	b7d1                	j	ffffffffc0205ec0 <schedule+0x58>
    if (proc != idleproc) {
ffffffffc0205efe:	000c6797          	auipc	a5,0xc6
ffffffffc0205f02:	46a7b783          	ld	a5,1130(a5) # ffffffffc02cc368 <idleproc>
ffffffffc0205f06:	f8f58fe3          	beq	a1,a5,ffffffffc0205ea4 <schedule+0x3c>
        sched_class->enqueue(rq, proc);
ffffffffc0205f0a:	00093783          	ld	a5,0(s2)
ffffffffc0205f0e:	6088                	ld	a0,0(s1)
ffffffffc0205f10:	6b9c                	ld	a5,16(a5)
ffffffffc0205f12:	9782                	jalr	a5
ffffffffc0205f14:	bf41                	j	ffffffffc0205ea4 <schedule+0x3c>
        intr_disable();
ffffffffc0205f16:	9e9fa0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc0205f1a:	4985                	li	s3,1
ffffffffc0205f1c:	b78d                	j	ffffffffc0205e7e <schedule+0x16>

ffffffffc0205f1e <add_timer>:

// add timer to timer_list
void
add_timer(timer_t *timer) {
ffffffffc0205f1e:	1101                	addi	sp,sp,-32
ffffffffc0205f20:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205f22:	100027f3          	csrr	a5,sstatus
ffffffffc0205f26:	8b89                	andi	a5,a5,2
ffffffffc0205f28:	4801                	li	a6,0
ffffffffc0205f2a:	e7bd                	bnez	a5,ffffffffc0205f98 <add_timer+0x7a>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        assert(timer->expires > 0 && timer->proc != NULL);
ffffffffc0205f2c:	4118                	lw	a4,0(a0)
ffffffffc0205f2e:	cb3d                	beqz	a4,ffffffffc0205fa4 <add_timer+0x86>
ffffffffc0205f30:	651c                	ld	a5,8(a0)
ffffffffc0205f32:	cbad                	beqz	a5,ffffffffc0205fa4 <add_timer+0x86>
        assert(list_empty(&(timer->timer_link)));
ffffffffc0205f34:	6d1c                	ld	a5,24(a0)
ffffffffc0205f36:	01050593          	addi	a1,a0,16
ffffffffc0205f3a:	08f59563          	bne	a1,a5,ffffffffc0205fc4 <add_timer+0xa6>
    return listelm->next;
ffffffffc0205f3e:	000c6617          	auipc	a2,0xc6
ffffffffc0205f42:	3a260613          	addi	a2,a2,930 # ffffffffc02cc2e0 <timer_list>
ffffffffc0205f46:	661c                	ld	a5,8(a2)
        list_entry_t *le = list_next(&timer_list);
        while (le != &timer_list) {
ffffffffc0205f48:	00c79863          	bne	a5,a2,ffffffffc0205f58 <add_timer+0x3a>
ffffffffc0205f4c:	a805                	j	ffffffffc0205f7c <add_timer+0x5e>
ffffffffc0205f4e:	679c                	ld	a5,8(a5)
            timer_t *next = le2timer(le, timer_link);
            if (timer->expires < next->expires) {
                next->expires -= timer->expires;
                break;
            }
            timer->expires -= next->expires;
ffffffffc0205f50:	9f15                	subw	a4,a4,a3
ffffffffc0205f52:	c118                	sw	a4,0(a0)
        while (le != &timer_list) {
ffffffffc0205f54:	02c78463          	beq	a5,a2,ffffffffc0205f7c <add_timer+0x5e>
            if (timer->expires < next->expires) {
ffffffffc0205f58:	ff07a683          	lw	a3,-16(a5)
ffffffffc0205f5c:	fed779e3          	bgeu	a4,a3,ffffffffc0205f4e <add_timer+0x30>
                next->expires -= timer->expires;
ffffffffc0205f60:	9e99                	subw	a3,a3,a4
    __list_add(elm, listelm->prev, listelm);
ffffffffc0205f62:	6398                	ld	a4,0(a5)
ffffffffc0205f64:	fed7a823          	sw	a3,-16(a5)
    prev->next = next->prev = elm;
ffffffffc0205f68:	e38c                	sd	a1,0(a5)
ffffffffc0205f6a:	e70c                	sd	a1,8(a4)
    elm->prev = prev;
ffffffffc0205f6c:	e918                	sd	a4,16(a0)
    elm->next = next;
ffffffffc0205f6e:	ed1c                	sd	a5,24(a0)
    if (flag) {
ffffffffc0205f70:	02080163          	beqz	a6,ffffffffc0205f92 <add_timer+0x74>
            le = list_next(le);
        }
        list_add_before(le, &(timer->timer_link));
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205f74:	60e2                	ld	ra,24(sp)
ffffffffc0205f76:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205f78:	981fa06f          	j	ffffffffc02008f8 <intr_enable>
        list_entry_t *le = list_next(&timer_list);
ffffffffc0205f7c:	000c6797          	auipc	a5,0xc6
ffffffffc0205f80:	36478793          	addi	a5,a5,868 # ffffffffc02cc2e0 <timer_list>
    __list_add(elm, listelm->prev, listelm);
ffffffffc0205f84:	6398                	ld	a4,0(a5)
    prev->next = next->prev = elm;
ffffffffc0205f86:	e38c                	sd	a1,0(a5)
ffffffffc0205f88:	e70c                	sd	a1,8(a4)
    elm->prev = prev;
ffffffffc0205f8a:	e918                	sd	a4,16(a0)
    elm->next = next;
ffffffffc0205f8c:	ed1c                	sd	a5,24(a0)
    if (flag) {
ffffffffc0205f8e:	fe0813e3          	bnez	a6,ffffffffc0205f74 <add_timer+0x56>
}
ffffffffc0205f92:	60e2                	ld	ra,24(sp)
ffffffffc0205f94:	6105                	addi	sp,sp,32
ffffffffc0205f96:	8082                	ret
ffffffffc0205f98:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0205f9a:	965fa0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc0205f9e:	6522                	ld	a0,8(sp)
ffffffffc0205fa0:	4805                	li	a6,1
ffffffffc0205fa2:	b769                	j	ffffffffc0205f2c <add_timer+0xe>
        assert(timer->expires > 0 && timer->proc != NULL);
ffffffffc0205fa4:	00003697          	auipc	a3,0x3
ffffffffc0205fa8:	a5c68693          	addi	a3,a3,-1444 # ffffffffc0208a00 <etext+0x229e>
ffffffffc0205fac:	00001617          	auipc	a2,0x1
ffffffffc0205fb0:	f6460613          	addi	a2,a2,-156 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0205fb4:	06c00593          	li	a1,108
ffffffffc0205fb8:	00003517          	auipc	a0,0x3
ffffffffc0205fbc:	a1050513          	addi	a0,a0,-1520 # ffffffffc02089c8 <etext+0x2266>
ffffffffc0205fc0:	c8afa0ef          	jal	ffffffffc020044a <__panic>
        assert(list_empty(&(timer->timer_link)));
ffffffffc0205fc4:	00003697          	auipc	a3,0x3
ffffffffc0205fc8:	a6c68693          	addi	a3,a3,-1428 # ffffffffc0208a30 <etext+0x22ce>
ffffffffc0205fcc:	00001617          	auipc	a2,0x1
ffffffffc0205fd0:	f4460613          	addi	a2,a2,-188 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc0205fd4:	06d00593          	li	a1,109
ffffffffc0205fd8:	00003517          	auipc	a0,0x3
ffffffffc0205fdc:	9f050513          	addi	a0,a0,-1552 # ffffffffc02089c8 <etext+0x2266>
ffffffffc0205fe0:	c6afa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0205fe4 <del_timer>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0205fe4:	100027f3          	csrr	a5,sstatus
ffffffffc0205fe8:	8b89                	andi	a5,a5,2
ffffffffc0205fea:	ef95                	bnez	a5,ffffffffc0206026 <del_timer+0x42>
    return list->next == list;
ffffffffc0205fec:	6d1c                	ld	a5,24(a0)
void
del_timer(timer_t *timer) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (!list_empty(&(timer->timer_link))) {
ffffffffc0205fee:	01050713          	addi	a4,a0,16
    return 0;
ffffffffc0205ff2:	4601                	li	a2,0
ffffffffc0205ff4:	02f70863          	beq	a4,a5,ffffffffc0206024 <del_timer+0x40>
            if (timer->expires != 0) {
                list_entry_t *le = list_next(&(timer->timer_link));
                if (le != &timer_list) {
ffffffffc0205ff8:	000c6597          	auipc	a1,0xc6
ffffffffc0205ffc:	2e858593          	addi	a1,a1,744 # ffffffffc02cc2e0 <timer_list>
            if (timer->expires != 0) {
ffffffffc0206000:	4114                	lw	a3,0(a0)
                if (le != &timer_list) {
ffffffffc0206002:	00b78863          	beq	a5,a1,ffffffffc0206012 <del_timer+0x2e>
ffffffffc0206006:	c691                	beqz	a3,ffffffffc0206012 <del_timer+0x2e>
                    timer_t *next = le2timer(le, timer_link);
                    next->expires += timer->expires;
ffffffffc0206008:	ff07a583          	lw	a1,-16(a5)
ffffffffc020600c:	9ead                	addw	a3,a3,a1
ffffffffc020600e:	fed7a823          	sw	a3,-16(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0206012:	6914                	ld	a3,16(a0)
    prev->next = next;
ffffffffc0206014:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc0206016:	e394                	sd	a3,0(a5)
    elm->prev = elm->next = elm;
ffffffffc0206018:	ed18                	sd	a4,24(a0)
ffffffffc020601a:	e918                	sd	a4,16(a0)
    if (flag) {
ffffffffc020601c:	e211                	bnez	a2,ffffffffc0206020 <del_timer+0x3c>
ffffffffc020601e:	8082                	ret
        intr_enable();
ffffffffc0206020:	8d9fa06f          	j	ffffffffc02008f8 <intr_enable>
ffffffffc0206024:	8082                	ret
del_timer(timer_t *timer) {
ffffffffc0206026:	1101                	addi	sp,sp,-32
ffffffffc0206028:	e42a                	sd	a0,8(sp)
ffffffffc020602a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc020602c:	8d3fa0ef          	jal	ffffffffc02008fe <intr_disable>
    return list->next == list;
ffffffffc0206030:	6522                	ld	a0,8(sp)
        return 1;
ffffffffc0206032:	4605                	li	a2,1
ffffffffc0206034:	6d1c                	ld	a5,24(a0)
        if (!list_empty(&(timer->timer_link))) {
ffffffffc0206036:	01050713          	addi	a4,a0,16
ffffffffc020603a:	02f70863          	beq	a4,a5,ffffffffc020606a <del_timer+0x86>
                if (le != &timer_list) {
ffffffffc020603e:	000c6597          	auipc	a1,0xc6
ffffffffc0206042:	2a258593          	addi	a1,a1,674 # ffffffffc02cc2e0 <timer_list>
            if (timer->expires != 0) {
ffffffffc0206046:	4114                	lw	a3,0(a0)
                if (le != &timer_list) {
ffffffffc0206048:	00b78863          	beq	a5,a1,ffffffffc0206058 <del_timer+0x74>
ffffffffc020604c:	c691                	beqz	a3,ffffffffc0206058 <del_timer+0x74>
                    next->expires += timer->expires;
ffffffffc020604e:	ff07a583          	lw	a1,-16(a5)
ffffffffc0206052:	9ead                	addw	a3,a3,a1
ffffffffc0206054:	fed7a823          	sw	a3,-16(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0206058:	6914                	ld	a3,16(a0)
    prev->next = next;
ffffffffc020605a:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc020605c:	e394                	sd	a3,0(a5)
    elm->prev = elm->next = elm;
ffffffffc020605e:	ed18                	sd	a4,24(a0)
ffffffffc0206060:	e918                	sd	a4,16(a0)
    if (flag) {
ffffffffc0206062:	e601                	bnez	a2,ffffffffc020606a <del_timer+0x86>
            }
            list_del_init(&(timer->timer_link));
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206064:	60e2                	ld	ra,24(sp)
ffffffffc0206066:	6105                	addi	sp,sp,32
ffffffffc0206068:	8082                	ret
ffffffffc020606a:	60e2                	ld	ra,24(sp)
ffffffffc020606c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020606e:	88bfa06f          	j	ffffffffc02008f8 <intr_enable>

ffffffffc0206072 <run_timer_list>:

// call scheduler to update tick related info, and check the timer is expired? If expired, then wakup proc
void
run_timer_list(void) {
ffffffffc0206072:	7179                	addi	sp,sp,-48
ffffffffc0206074:	f406                	sd	ra,40(sp)
ffffffffc0206076:	f022                	sd	s0,32(sp)
ffffffffc0206078:	e44e                	sd	s3,8(sp)
ffffffffc020607a:	e052                	sd	s4,0(sp)
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020607c:	100027f3          	csrr	a5,sstatus
ffffffffc0206080:	8b89                	andi	a5,a5,2
ffffffffc0206082:	4a01                	li	s4,0
ffffffffc0206084:	ebe1                	bnez	a5,ffffffffc0206154 <run_timer_list+0xe2>
    return listelm->next;
ffffffffc0206086:	000c6997          	auipc	s3,0xc6
ffffffffc020608a:	25a98993          	addi	s3,s3,602 # ffffffffc02cc2e0 <timer_list>
ffffffffc020608e:	0089b403          	ld	s0,8(s3)
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        list_entry_t *le = list_next(&timer_list);
        if (le != &timer_list) {
ffffffffc0206092:	07340b63          	beq	s0,s3,ffffffffc0206108 <run_timer_list+0x96>
            timer_t *timer = le2timer(le, timer_link);
            assert(timer->expires != 0);
ffffffffc0206096:	ff042783          	lw	a5,-16(s0)
ffffffffc020609a:	0e078163          	beqz	a5,ffffffffc020617c <run_timer_list+0x10a>
            timer->expires --;
ffffffffc020609e:	37fd                	addiw	a5,a5,-1
ffffffffc02060a0:	fef42823          	sw	a5,-16(s0)
            while (timer->expires == 0) {
ffffffffc02060a4:	e3b5                	bnez	a5,ffffffffc0206108 <run_timer_list+0x96>
ffffffffc02060a6:	e84a                	sd	s2,16(sp)
ffffffffc02060a8:	ec26                	sd	s1,24(sp)
            timer_t *timer = le2timer(le, timer_link);
ffffffffc02060aa:	ff040913          	addi	s2,s0,-16
ffffffffc02060ae:	a005                	j	ffffffffc02060ce <run_timer_list+0x5c>
                le = list_next(le);
                struct proc_struct *proc = timer->proc;
                if (proc->wait_state != 0) {
                    assert(proc->wait_state & WT_INTERRUPTED);
ffffffffc02060b0:	0a07d663          	bgez	a5,ffffffffc020615c <run_timer_list+0xea>
                }
                else {
                    warn("process %d's wait_state == 0.\n", proc->pid);
                }
                wakeup_proc(proc);
ffffffffc02060b4:	8526                	mv	a0,s1
ffffffffc02060b6:	cbbff0ef          	jal	ffffffffc0205d70 <wakeup_proc>
                del_timer(timer);
ffffffffc02060ba:	854a                	mv	a0,s2
ffffffffc02060bc:	f29ff0ef          	jal	ffffffffc0205fe4 <del_timer>
                if (le == &timer_list) {
ffffffffc02060c0:	05340263          	beq	s0,s3,ffffffffc0206104 <run_timer_list+0x92>
            while (timer->expires == 0) {
ffffffffc02060c4:	ff042783          	lw	a5,-16(s0)
                    break;
                }
                timer = le2timer(le, timer_link);
ffffffffc02060c8:	ff040913          	addi	s2,s0,-16
            while (timer->expires == 0) {
ffffffffc02060cc:	ef85                	bnez	a5,ffffffffc0206104 <run_timer_list+0x92>
                struct proc_struct *proc = timer->proc;
ffffffffc02060ce:	00893483          	ld	s1,8(s2)
ffffffffc02060d2:	6400                	ld	s0,8(s0)
                if (proc->wait_state != 0) {
ffffffffc02060d4:	0ec4a783          	lw	a5,236(s1)
ffffffffc02060d8:	ffe1                	bnez	a5,ffffffffc02060b0 <run_timer_list+0x3e>
                    warn("process %d's wait_state == 0.\n", proc->pid);
ffffffffc02060da:	40d4                	lw	a3,4(s1)
ffffffffc02060dc:	00003617          	auipc	a2,0x3
ffffffffc02060e0:	9bc60613          	addi	a2,a2,-1604 # ffffffffc0208a98 <etext+0x2336>
ffffffffc02060e4:	0a300593          	li	a1,163
ffffffffc02060e8:	00003517          	auipc	a0,0x3
ffffffffc02060ec:	8e050513          	addi	a0,a0,-1824 # ffffffffc02089c8 <etext+0x2266>
ffffffffc02060f0:	bc4fa0ef          	jal	ffffffffc02004b4 <__warn>
                wakeup_proc(proc);
ffffffffc02060f4:	8526                	mv	a0,s1
ffffffffc02060f6:	c7bff0ef          	jal	ffffffffc0205d70 <wakeup_proc>
                del_timer(timer);
ffffffffc02060fa:	854a                	mv	a0,s2
ffffffffc02060fc:	ee9ff0ef          	jal	ffffffffc0205fe4 <del_timer>
                if (le == &timer_list) {
ffffffffc0206100:	fd3412e3          	bne	s0,s3,ffffffffc02060c4 <run_timer_list+0x52>
ffffffffc0206104:	64e2                	ld	s1,24(sp)
ffffffffc0206106:	6942                	ld	s2,16(sp)
            }
        }
        sched_class_proc_tick(current);
ffffffffc0206108:	000c6597          	auipc	a1,0xc6
ffffffffc020610c:	2505b583          	ld	a1,592(a1) # ffffffffc02cc358 <current>
    if (proc != idleproc) {
ffffffffc0206110:	000c6797          	auipc	a5,0xc6
ffffffffc0206114:	2587b783          	ld	a5,600(a5) # ffffffffc02cc368 <idleproc>
ffffffffc0206118:	02f58b63          	beq	a1,a5,ffffffffc020614e <run_timer_list+0xdc>
        sched_class->proc_tick(rq, proc);
ffffffffc020611c:	000c6797          	auipc	a5,0xc6
ffffffffc0206120:	25c7b783          	ld	a5,604(a5) # ffffffffc02cc378 <sched_class>
ffffffffc0206124:	000c6517          	auipc	a0,0xc6
ffffffffc0206128:	24c53503          	ld	a0,588(a0) # ffffffffc02cc370 <rq>
ffffffffc020612c:	779c                	ld	a5,40(a5)
ffffffffc020612e:	9782                	jalr	a5
    if (flag) {
ffffffffc0206130:	000a1863          	bnez	s4,ffffffffc0206140 <run_timer_list+0xce>
    }
    local_intr_restore(intr_flag);
}
ffffffffc0206134:	70a2                	ld	ra,40(sp)
ffffffffc0206136:	7402                	ld	s0,32(sp)
ffffffffc0206138:	69a2                	ld	s3,8(sp)
ffffffffc020613a:	6a02                	ld	s4,0(sp)
ffffffffc020613c:	6145                	addi	sp,sp,48
ffffffffc020613e:	8082                	ret
ffffffffc0206140:	7402                	ld	s0,32(sp)
ffffffffc0206142:	70a2                	ld	ra,40(sp)
ffffffffc0206144:	69a2                	ld	s3,8(sp)
ffffffffc0206146:	6a02                	ld	s4,0(sp)
ffffffffc0206148:	6145                	addi	sp,sp,48
        intr_enable();
ffffffffc020614a:	faefa06f          	j	ffffffffc02008f8 <intr_enable>
        proc->need_resched = 1;
ffffffffc020614e:	4785                	li	a5,1
ffffffffc0206150:	ed9c                	sd	a5,24(a1)
ffffffffc0206152:	bff9                	j	ffffffffc0206130 <run_timer_list+0xbe>
        intr_disable();
ffffffffc0206154:	faafa0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc0206158:	4a05                	li	s4,1
ffffffffc020615a:	b735                	j	ffffffffc0206086 <run_timer_list+0x14>
                    assert(proc->wait_state & WT_INTERRUPTED);
ffffffffc020615c:	00003697          	auipc	a3,0x3
ffffffffc0206160:	91468693          	addi	a3,a3,-1772 # ffffffffc0208a70 <etext+0x230e>
ffffffffc0206164:	00001617          	auipc	a2,0x1
ffffffffc0206168:	dac60613          	addi	a2,a2,-596 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020616c:	0a000593          	li	a1,160
ffffffffc0206170:	00003517          	auipc	a0,0x3
ffffffffc0206174:	85850513          	addi	a0,a0,-1960 # ffffffffc02089c8 <etext+0x2266>
ffffffffc0206178:	ad2fa0ef          	jal	ffffffffc020044a <__panic>
            assert(timer->expires != 0);
ffffffffc020617c:	00003697          	auipc	a3,0x3
ffffffffc0206180:	8dc68693          	addi	a3,a3,-1828 # ffffffffc0208a58 <etext+0x22f6>
ffffffffc0206184:	00001617          	auipc	a2,0x1
ffffffffc0206188:	d8c60613          	addi	a2,a2,-628 # ffffffffc0206f10 <etext+0x7ae>
ffffffffc020618c:	09a00593          	li	a1,154
ffffffffc0206190:	00003517          	auipc	a0,0x3
ffffffffc0206194:	83850513          	addi	a0,a0,-1992 # ffffffffc02089c8 <etext+0x2266>
ffffffffc0206198:	ec26                	sd	s1,24(sp)
ffffffffc020619a:	e84a                	sd	s2,16(sp)
ffffffffc020619c:	aaefa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02061a0 <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc02061a0:	000c6797          	auipc	a5,0xc6
ffffffffc02061a4:	1b87b783          	ld	a5,440(a5) # ffffffffc02cc358 <current>
}
ffffffffc02061a8:	43c8                	lw	a0,4(a5)
ffffffffc02061aa:	8082                	ret

ffffffffc02061ac <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc02061ac:	4501                	li	a0,0
ffffffffc02061ae:	8082                	ret

ffffffffc02061b0 <sys_gettime>:
static int sys_gettime(uint64_t arg[]){
    return (int)ticks*10;
ffffffffc02061b0:	000c6797          	auipc	a5,0xc6
ffffffffc02061b4:	1487b783          	ld	a5,328(a5) # ffffffffc02cc2f8 <ticks>
ffffffffc02061b8:	0027951b          	slliw	a0,a5,0x2
ffffffffc02061bc:	9d3d                	addw	a0,a0,a5
ffffffffc02061be:	0015151b          	slliw	a0,a0,0x1
}
ffffffffc02061c2:	8082                	ret

ffffffffc02061c4 <sys_lab6_set_priority>:
static int sys_lab6_set_priority(uint64_t arg[]){
    uint64_t priority = (uint64_t)arg[0];
    lab6_set_priority(priority);
ffffffffc02061c4:	4108                	lw	a0,0(a0)
static int sys_lab6_set_priority(uint64_t arg[]){
ffffffffc02061c6:	1141                	addi	sp,sp,-16
ffffffffc02061c8:	e406                	sd	ra,8(sp)
    lab6_set_priority(priority);
ffffffffc02061ca:	94fff0ef          	jal	ffffffffc0205b18 <lab6_set_priority>
    return 0;
}
ffffffffc02061ce:	60a2                	ld	ra,8(sp)
ffffffffc02061d0:	4501                	li	a0,0
ffffffffc02061d2:	0141                	addi	sp,sp,16
ffffffffc02061d4:	8082                	ret

ffffffffc02061d6 <sys_putc>:
    cputchar(c);
ffffffffc02061d6:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc02061d8:	1141                	addi	sp,sp,-16
ffffffffc02061da:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc02061dc:	ff1f90ef          	jal	ffffffffc02001cc <cputchar>
}
ffffffffc02061e0:	60a2                	ld	ra,8(sp)
ffffffffc02061e2:	4501                	li	a0,0
ffffffffc02061e4:	0141                	addi	sp,sp,16
ffffffffc02061e6:	8082                	ret

ffffffffc02061e8 <sys_kill>:
    return do_kill(pid);
ffffffffc02061e8:	4108                	lw	a0,0(a0)
ffffffffc02061ea:	efcff06f          	j	ffffffffc02058e6 <do_kill>

ffffffffc02061ee <sys_sleep>:
static int
sys_sleep(uint64_t arg[]) {
    unsigned int time = (unsigned int)arg[0];
    return do_sleep(time);
ffffffffc02061ee:	4108                	lw	a0,0(a0)
ffffffffc02061f0:	957ff06f          	j	ffffffffc0205b46 <do_sleep>

ffffffffc02061f4 <sys_yield>:
    return do_yield();
ffffffffc02061f4:	ea8ff06f          	j	ffffffffc020589c <do_yield>

ffffffffc02061f8 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc02061f8:	6d14                	ld	a3,24(a0)
ffffffffc02061fa:	6910                	ld	a2,16(a0)
ffffffffc02061fc:	650c                	ld	a1,8(a0)
ffffffffc02061fe:	6108                	ld	a0,0(a0)
ffffffffc0206200:	8faff06f          	j	ffffffffc02052fa <do_execve>

ffffffffc0206204 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0206204:	650c                	ld	a1,8(a0)
ffffffffc0206206:	4108                	lw	a0,0(a0)
ffffffffc0206208:	ea4ff06f          	j	ffffffffc02058ac <do_wait>

ffffffffc020620c <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc020620c:	000c6797          	auipc	a5,0xc6
ffffffffc0206210:	14c7b783          	ld	a5,332(a5) # ffffffffc02cc358 <current>
    return do_fork(0, stack, tf);
ffffffffc0206214:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc0206216:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0206218:	6a0c                	ld	a1,16(a2)
ffffffffc020621a:	841fe06f          	j	ffffffffc0204a5a <do_fork>

ffffffffc020621e <sys_exit>:
    return do_exit(error_code);
ffffffffc020621e:	4108                	lw	a0,0(a0)
ffffffffc0206220:	cb5fe06f          	j	ffffffffc0204ed4 <do_exit>

ffffffffc0206224 <syscall>:

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
    struct trapframe *tf = current->tf;
ffffffffc0206224:	000c6697          	auipc	a3,0xc6
ffffffffc0206228:	1346b683          	ld	a3,308(a3) # ffffffffc02cc358 <current>
syscall(void) {
ffffffffc020622c:	715d                	addi	sp,sp,-80
ffffffffc020622e:	e0a2                	sd	s0,64(sp)
    struct trapframe *tf = current->tf;
ffffffffc0206230:	72c0                	ld	s0,160(a3)
syscall(void) {
ffffffffc0206232:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0206234:	0ff00793          	li	a5,255
    int num = tf->gpr.a0;
ffffffffc0206238:	4834                	lw	a3,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc020623a:	02d7ec63          	bltu	a5,a3,ffffffffc0206272 <syscall+0x4e>
        if (syscalls[num] != NULL) {
ffffffffc020623e:	00003797          	auipc	a5,0x3
ffffffffc0206242:	aa278793          	addi	a5,a5,-1374 # ffffffffc0208ce0 <syscalls>
ffffffffc0206246:	00369613          	slli	a2,a3,0x3
ffffffffc020624a:	97b2                	add	a5,a5,a2
ffffffffc020624c:	639c                	ld	a5,0(a5)
ffffffffc020624e:	c395                	beqz	a5,ffffffffc0206272 <syscall+0x4e>
            arg[0] = tf->gpr.a1;
ffffffffc0206250:	7028                	ld	a0,96(s0)
ffffffffc0206252:	742c                	ld	a1,104(s0)
ffffffffc0206254:	7830                	ld	a2,112(s0)
ffffffffc0206256:	7c34                	ld	a3,120(s0)
ffffffffc0206258:	6c38                	ld	a4,88(s0)
ffffffffc020625a:	f02a                	sd	a0,32(sp)
ffffffffc020625c:	f42e                	sd	a1,40(sp)
ffffffffc020625e:	f832                	sd	a2,48(sp)
ffffffffc0206260:	fc36                	sd	a3,56(sp)
ffffffffc0206262:	ec3a                	sd	a4,24(sp)
            arg[1] = tf->gpr.a2;
            arg[2] = tf->gpr.a3;
            arg[3] = tf->gpr.a4;
            arg[4] = tf->gpr.a5;
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0206264:	0828                	addi	a0,sp,24
ffffffffc0206266:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0206268:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc020626a:	e828                	sd	a0,80(s0)
}
ffffffffc020626c:	6406                	ld	s0,64(sp)
ffffffffc020626e:	6161                	addi	sp,sp,80
ffffffffc0206270:	8082                	ret
    print_trapframe(tf);
ffffffffc0206272:	8522                	mv	a0,s0
ffffffffc0206274:	e436                	sd	a3,8(sp)
ffffffffc0206276:	879fa0ef          	jal	ffffffffc0200aee <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc020627a:	000c6797          	auipc	a5,0xc6
ffffffffc020627e:	0de7b783          	ld	a5,222(a5) # ffffffffc02cc358 <current>
ffffffffc0206282:	66a2                	ld	a3,8(sp)
ffffffffc0206284:	00003617          	auipc	a2,0x3
ffffffffc0206288:	83460613          	addi	a2,a2,-1996 # ffffffffc0208ab8 <etext+0x2356>
ffffffffc020628c:	43d8                	lw	a4,4(a5)
ffffffffc020628e:	07300593          	li	a1,115
ffffffffc0206292:	0b478793          	addi	a5,a5,180
ffffffffc0206296:	00003517          	auipc	a0,0x3
ffffffffc020629a:	85250513          	addi	a0,a0,-1966 # ffffffffc0208ae8 <etext+0x2386>
ffffffffc020629e:	9acfa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02062a2 <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02062a2:	9e3707b7          	lui	a5,0x9e370
ffffffffc02062a6:	2785                	addiw	a5,a5,1 # ffffffff9e370001 <_binary_obj___user_matrix_out_size+0xffffffff9e364919>
ffffffffc02062a8:	02a787bb          	mulw	a5,a5,a0
    return (hash >> (32 - bits));
ffffffffc02062ac:	02000513          	li	a0,32
ffffffffc02062b0:	9d0d                	subw	a0,a0,a1
}
ffffffffc02062b2:	00a7d53b          	srlw	a0,a5,a0
ffffffffc02062b6:	8082                	ret

ffffffffc02062b8 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02062b8:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02062ba:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02062be:	f022                	sd	s0,32(sp)
ffffffffc02062c0:	ec26                	sd	s1,24(sp)
ffffffffc02062c2:	e84a                	sd	s2,16(sp)
ffffffffc02062c4:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02062c6:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02062ca:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
ffffffffc02062cc:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02062d0:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02062d4:	84aa                	mv	s1,a0
ffffffffc02062d6:	892e                	mv	s2,a1
    if (num >= base) {
ffffffffc02062d8:	03067d63          	bgeu	a2,a6,ffffffffc0206312 <printnum+0x5a>
ffffffffc02062dc:	e44e                	sd	s3,8(sp)
ffffffffc02062de:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02062e0:	4785                	li	a5,1
ffffffffc02062e2:	00e7d763          	bge	a5,a4,ffffffffc02062f0 <printnum+0x38>
            putch(padc, putdat);
ffffffffc02062e6:	85ca                	mv	a1,s2
ffffffffc02062e8:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc02062ea:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02062ec:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02062ee:	fc65                	bnez	s0,ffffffffc02062e6 <printnum+0x2e>
ffffffffc02062f0:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02062f2:	00003797          	auipc	a5,0x3
ffffffffc02062f6:	80e78793          	addi	a5,a5,-2034 # ffffffffc0208b00 <etext+0x239e>
ffffffffc02062fa:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02062fc:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02062fe:	0007c503          	lbu	a0,0(a5)
}
ffffffffc0206302:	70a2                	ld	ra,40(sp)
ffffffffc0206304:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206306:	85ca                	mv	a1,s2
ffffffffc0206308:	87a6                	mv	a5,s1
}
ffffffffc020630a:	6942                	ld	s2,16(sp)
ffffffffc020630c:	64e2                	ld	s1,24(sp)
ffffffffc020630e:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0206310:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0206312:	03065633          	divu	a2,a2,a6
ffffffffc0206316:	8722                	mv	a4,s0
ffffffffc0206318:	fa1ff0ef          	jal	ffffffffc02062b8 <printnum>
ffffffffc020631c:	bfd9                	j	ffffffffc02062f2 <printnum+0x3a>

ffffffffc020631e <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020631e:	7119                	addi	sp,sp,-128
ffffffffc0206320:	f4a6                	sd	s1,104(sp)
ffffffffc0206322:	f0ca                	sd	s2,96(sp)
ffffffffc0206324:	ecce                	sd	s3,88(sp)
ffffffffc0206326:	e8d2                	sd	s4,80(sp)
ffffffffc0206328:	e4d6                	sd	s5,72(sp)
ffffffffc020632a:	e0da                	sd	s6,64(sp)
ffffffffc020632c:	f862                	sd	s8,48(sp)
ffffffffc020632e:	fc86                	sd	ra,120(sp)
ffffffffc0206330:	f8a2                	sd	s0,112(sp)
ffffffffc0206332:	fc5e                	sd	s7,56(sp)
ffffffffc0206334:	f466                	sd	s9,40(sp)
ffffffffc0206336:	f06a                	sd	s10,32(sp)
ffffffffc0206338:	ec6e                	sd	s11,24(sp)
ffffffffc020633a:	84aa                	mv	s1,a0
ffffffffc020633c:	8c32                	mv	s8,a2
ffffffffc020633e:	8a36                	mv	s4,a3
ffffffffc0206340:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206342:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0206346:	05500b13          	li	s6,85
ffffffffc020634a:	00003a97          	auipc	s5,0x3
ffffffffc020634e:	196a8a93          	addi	s5,s5,406 # ffffffffc02094e0 <syscalls+0x800>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206352:	000c4503          	lbu	a0,0(s8)
ffffffffc0206356:	001c0413          	addi	s0,s8,1
ffffffffc020635a:	01350a63          	beq	a0,s3,ffffffffc020636e <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc020635e:	cd0d                	beqz	a0,ffffffffc0206398 <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc0206360:	85ca                	mv	a1,s2
ffffffffc0206362:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0206364:	00044503          	lbu	a0,0(s0)
ffffffffc0206368:	0405                	addi	s0,s0,1
ffffffffc020636a:	ff351ae3          	bne	a0,s3,ffffffffc020635e <vprintfmt+0x40>
        width = precision = -1;
ffffffffc020636e:	5cfd                	li	s9,-1
ffffffffc0206370:	8d66                	mv	s10,s9
        char padc = ' ';
ffffffffc0206372:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc0206376:	4b81                	li	s7,0
ffffffffc0206378:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020637a:	00044683          	lbu	a3,0(s0)
ffffffffc020637e:	00140c13          	addi	s8,s0,1
ffffffffc0206382:	fdd6859b          	addiw	a1,a3,-35
ffffffffc0206386:	0ff5f593          	zext.b	a1,a1
ffffffffc020638a:	02bb6663          	bltu	s6,a1,ffffffffc02063b6 <vprintfmt+0x98>
ffffffffc020638e:	058a                	slli	a1,a1,0x2
ffffffffc0206390:	95d6                	add	a1,a1,s5
ffffffffc0206392:	4198                	lw	a4,0(a1)
ffffffffc0206394:	9756                	add	a4,a4,s5
ffffffffc0206396:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0206398:	70e6                	ld	ra,120(sp)
ffffffffc020639a:	7446                	ld	s0,112(sp)
ffffffffc020639c:	74a6                	ld	s1,104(sp)
ffffffffc020639e:	7906                	ld	s2,96(sp)
ffffffffc02063a0:	69e6                	ld	s3,88(sp)
ffffffffc02063a2:	6a46                	ld	s4,80(sp)
ffffffffc02063a4:	6aa6                	ld	s5,72(sp)
ffffffffc02063a6:	6b06                	ld	s6,64(sp)
ffffffffc02063a8:	7be2                	ld	s7,56(sp)
ffffffffc02063aa:	7c42                	ld	s8,48(sp)
ffffffffc02063ac:	7ca2                	ld	s9,40(sp)
ffffffffc02063ae:	7d02                	ld	s10,32(sp)
ffffffffc02063b0:	6de2                	ld	s11,24(sp)
ffffffffc02063b2:	6109                	addi	sp,sp,128
ffffffffc02063b4:	8082                	ret
            putch('%', putdat);
ffffffffc02063b6:	85ca                	mv	a1,s2
ffffffffc02063b8:	02500513          	li	a0,37
ffffffffc02063bc:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02063be:	fff44783          	lbu	a5,-1(s0)
ffffffffc02063c2:	02500713          	li	a4,37
ffffffffc02063c6:	8c22                	mv	s8,s0
ffffffffc02063c8:	f8e785e3          	beq	a5,a4,ffffffffc0206352 <vprintfmt+0x34>
ffffffffc02063cc:	ffec4783          	lbu	a5,-2(s8)
ffffffffc02063d0:	1c7d                	addi	s8,s8,-1
ffffffffc02063d2:	fee79de3          	bne	a5,a4,ffffffffc02063cc <vprintfmt+0xae>
ffffffffc02063d6:	bfb5                	j	ffffffffc0206352 <vprintfmt+0x34>
                ch = *fmt;
ffffffffc02063d8:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc02063dc:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
ffffffffc02063de:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc02063e2:	fd06071b          	addiw	a4,a2,-48
ffffffffc02063e6:	24e56a63          	bltu	a0,a4,ffffffffc020663a <vprintfmt+0x31c>
                ch = *fmt;
ffffffffc02063ea:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02063ec:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
ffffffffc02063ee:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
ffffffffc02063f2:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02063f6:	0197073b          	addw	a4,a4,s9
ffffffffc02063fa:	0017171b          	slliw	a4,a4,0x1
ffffffffc02063fe:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
ffffffffc0206400:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0206404:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0206406:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc020640a:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
ffffffffc020640e:	feb570e3          	bgeu	a0,a1,ffffffffc02063ee <vprintfmt+0xd0>
            if (width < 0)
ffffffffc0206412:	f60d54e3          	bgez	s10,ffffffffc020637a <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc0206416:	8d66                	mv	s10,s9
ffffffffc0206418:	5cfd                	li	s9,-1
ffffffffc020641a:	b785                	j	ffffffffc020637a <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020641c:	8db6                	mv	s11,a3
ffffffffc020641e:	8462                	mv	s0,s8
ffffffffc0206420:	bfa9                	j	ffffffffc020637a <vprintfmt+0x5c>
ffffffffc0206422:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc0206424:	4b85                	li	s7,1
            goto reswitch;
ffffffffc0206426:	bf91                	j	ffffffffc020637a <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc0206428:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020642a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020642e:	00f74463          	blt	a4,a5,ffffffffc0206436 <vprintfmt+0x118>
    else if (lflag) {
ffffffffc0206432:	1a078763          	beqz	a5,ffffffffc02065e0 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
ffffffffc0206436:	000a3603          	ld	a2,0(s4)
ffffffffc020643a:	46c1                	li	a3,16
ffffffffc020643c:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020643e:	000d879b          	sext.w	a5,s11
ffffffffc0206442:	876a                	mv	a4,s10
ffffffffc0206444:	85ca                	mv	a1,s2
ffffffffc0206446:	8526                	mv	a0,s1
ffffffffc0206448:	e71ff0ef          	jal	ffffffffc02062b8 <printnum>
            break;
ffffffffc020644c:	b719                	j	ffffffffc0206352 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc020644e:	000a2503          	lw	a0,0(s4)
ffffffffc0206452:	85ca                	mv	a1,s2
ffffffffc0206454:	0a21                	addi	s4,s4,8
ffffffffc0206456:	9482                	jalr	s1
            break;
ffffffffc0206458:	bded                	j	ffffffffc0206352 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc020645a:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020645c:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0206460:	00f74463          	blt	a4,a5,ffffffffc0206468 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0206464:	16078963          	beqz	a5,ffffffffc02065d6 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
ffffffffc0206468:	000a3603          	ld	a2,0(s4)
ffffffffc020646c:	46a9                	li	a3,10
ffffffffc020646e:	8a2e                	mv	s4,a1
ffffffffc0206470:	b7f9                	j	ffffffffc020643e <vprintfmt+0x120>
            putch('0', putdat);
ffffffffc0206472:	85ca                	mv	a1,s2
ffffffffc0206474:	03000513          	li	a0,48
ffffffffc0206478:	9482                	jalr	s1
            putch('x', putdat);
ffffffffc020647a:	85ca                	mv	a1,s2
ffffffffc020647c:	07800513          	li	a0,120
ffffffffc0206480:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206482:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc0206486:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0206488:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc020648a:	bf55                	j	ffffffffc020643e <vprintfmt+0x120>
            putch(ch, putdat);
ffffffffc020648c:	85ca                	mv	a1,s2
ffffffffc020648e:	02500513          	li	a0,37
ffffffffc0206492:	9482                	jalr	s1
            break;
ffffffffc0206494:	bd7d                	j	ffffffffc0206352 <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc0206496:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020649a:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc020649c:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc020649e:	bf95                	j	ffffffffc0206412 <vprintfmt+0xf4>
    if (lflag >= 2) {
ffffffffc02064a0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02064a2:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02064a6:	00f74463          	blt	a4,a5,ffffffffc02064ae <vprintfmt+0x190>
    else if (lflag) {
ffffffffc02064aa:	12078163          	beqz	a5,ffffffffc02065cc <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
ffffffffc02064ae:	000a3603          	ld	a2,0(s4)
ffffffffc02064b2:	46a1                	li	a3,8
ffffffffc02064b4:	8a2e                	mv	s4,a1
ffffffffc02064b6:	b761                	j	ffffffffc020643e <vprintfmt+0x120>
            if (width < 0)
ffffffffc02064b8:	876a                	mv	a4,s10
ffffffffc02064ba:	000d5363          	bgez	s10,ffffffffc02064c0 <vprintfmt+0x1a2>
ffffffffc02064be:	4701                	li	a4,0
ffffffffc02064c0:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02064c4:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc02064c6:	bd55                	j	ffffffffc020637a <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
ffffffffc02064c8:	000d841b          	sext.w	s0,s11
ffffffffc02064cc:	fd340793          	addi	a5,s0,-45
ffffffffc02064d0:	00f037b3          	snez	a5,a5
ffffffffc02064d4:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02064d8:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
ffffffffc02064dc:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02064de:	008a0793          	addi	a5,s4,8
ffffffffc02064e2:	e43e                	sd	a5,8(sp)
ffffffffc02064e4:	100d8c63          	beqz	s11,ffffffffc02065fc <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc02064e8:	12071363          	bnez	a4,ffffffffc020660e <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02064ec:	000dc783          	lbu	a5,0(s11)
ffffffffc02064f0:	0007851b          	sext.w	a0,a5
ffffffffc02064f4:	c78d                	beqz	a5,ffffffffc020651e <vprintfmt+0x200>
ffffffffc02064f6:	0d85                	addi	s11,s11,1
ffffffffc02064f8:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02064fa:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02064fe:	000cc563          	bltz	s9,ffffffffc0206508 <vprintfmt+0x1ea>
ffffffffc0206502:	3cfd                	addiw	s9,s9,-1
ffffffffc0206504:	008c8d63          	beq	s9,s0,ffffffffc020651e <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206508:	020b9663          	bnez	s7,ffffffffc0206534 <vprintfmt+0x216>
                    putch(ch, putdat);
ffffffffc020650c:	85ca                	mv	a1,s2
ffffffffc020650e:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206510:	000dc783          	lbu	a5,0(s11)
ffffffffc0206514:	0d85                	addi	s11,s11,1
ffffffffc0206516:	3d7d                	addiw	s10,s10,-1
ffffffffc0206518:	0007851b          	sext.w	a0,a5
ffffffffc020651c:	f3ed                	bnez	a5,ffffffffc02064fe <vprintfmt+0x1e0>
            for (; width > 0; width --) {
ffffffffc020651e:	01a05963          	blez	s10,ffffffffc0206530 <vprintfmt+0x212>
                putch(' ', putdat);
ffffffffc0206522:	85ca                	mv	a1,s2
ffffffffc0206524:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc0206528:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
ffffffffc020652a:	9482                	jalr	s1
            for (; width > 0; width --) {
ffffffffc020652c:	fe0d1be3          	bnez	s10,ffffffffc0206522 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206530:	6a22                	ld	s4,8(sp)
ffffffffc0206532:	b505                	j	ffffffffc0206352 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0206534:	3781                	addiw	a5,a5,-32
ffffffffc0206536:	fcfa7be3          	bgeu	s4,a5,ffffffffc020650c <vprintfmt+0x1ee>
                    putch('?', putdat);
ffffffffc020653a:	03f00513          	li	a0,63
ffffffffc020653e:	85ca                	mv	a1,s2
ffffffffc0206540:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206542:	000dc783          	lbu	a5,0(s11)
ffffffffc0206546:	0d85                	addi	s11,s11,1
ffffffffc0206548:	3d7d                	addiw	s10,s10,-1
ffffffffc020654a:	0007851b          	sext.w	a0,a5
ffffffffc020654e:	dbe1                	beqz	a5,ffffffffc020651e <vprintfmt+0x200>
ffffffffc0206550:	fa0cd9e3          	bgez	s9,ffffffffc0206502 <vprintfmt+0x1e4>
ffffffffc0206554:	b7c5                	j	ffffffffc0206534 <vprintfmt+0x216>
            if (err < 0) {
ffffffffc0206556:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc020655a:	4661                	li	a2,24
            err = va_arg(ap, int);
ffffffffc020655c:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020655e:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc0206562:	8fb9                	xor	a5,a5,a4
ffffffffc0206564:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0206568:	02d64563          	blt	a2,a3,ffffffffc0206592 <vprintfmt+0x274>
ffffffffc020656c:	00003797          	auipc	a5,0x3
ffffffffc0206570:	0cc78793          	addi	a5,a5,204 # ffffffffc0209638 <error_string>
ffffffffc0206574:	00369713          	slli	a4,a3,0x3
ffffffffc0206578:	97ba                	add	a5,a5,a4
ffffffffc020657a:	639c                	ld	a5,0(a5)
ffffffffc020657c:	cb99                	beqz	a5,ffffffffc0206592 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
ffffffffc020657e:	86be                	mv	a3,a5
ffffffffc0206580:	00000617          	auipc	a2,0x0
ffffffffc0206584:	21060613          	addi	a2,a2,528 # ffffffffc0206790 <etext+0x2e>
ffffffffc0206588:	85ca                	mv	a1,s2
ffffffffc020658a:	8526                	mv	a0,s1
ffffffffc020658c:	0d8000ef          	jal	ffffffffc0206664 <printfmt>
ffffffffc0206590:	b3c9                	j	ffffffffc0206352 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0206592:	00002617          	auipc	a2,0x2
ffffffffc0206596:	58e60613          	addi	a2,a2,1422 # ffffffffc0208b20 <etext+0x23be>
ffffffffc020659a:	85ca                	mv	a1,s2
ffffffffc020659c:	8526                	mv	a0,s1
ffffffffc020659e:	0c6000ef          	jal	ffffffffc0206664 <printfmt>
ffffffffc02065a2:	bb45                	j	ffffffffc0206352 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc02065a4:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02065a6:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc02065aa:	00f74363          	blt	a4,a5,ffffffffc02065b0 <vprintfmt+0x292>
    else if (lflag) {
ffffffffc02065ae:	cf81                	beqz	a5,ffffffffc02065c6 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
ffffffffc02065b0:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02065b4:	02044b63          	bltz	s0,ffffffffc02065ea <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc02065b8:	8622                	mv	a2,s0
ffffffffc02065ba:	8a5e                	mv	s4,s7
ffffffffc02065bc:	46a9                	li	a3,10
ffffffffc02065be:	b541                	j	ffffffffc020643e <vprintfmt+0x120>
            lflag ++;
ffffffffc02065c0:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02065c2:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc02065c4:	bb5d                	j	ffffffffc020637a <vprintfmt+0x5c>
        return va_arg(*ap, int);
ffffffffc02065c6:	000a2403          	lw	s0,0(s4)
ffffffffc02065ca:	b7ed                	j	ffffffffc02065b4 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
ffffffffc02065cc:	000a6603          	lwu	a2,0(s4)
ffffffffc02065d0:	46a1                	li	a3,8
ffffffffc02065d2:	8a2e                	mv	s4,a1
ffffffffc02065d4:	b5ad                	j	ffffffffc020643e <vprintfmt+0x120>
ffffffffc02065d6:	000a6603          	lwu	a2,0(s4)
ffffffffc02065da:	46a9                	li	a3,10
ffffffffc02065dc:	8a2e                	mv	s4,a1
ffffffffc02065de:	b585                	j	ffffffffc020643e <vprintfmt+0x120>
ffffffffc02065e0:	000a6603          	lwu	a2,0(s4)
ffffffffc02065e4:	46c1                	li	a3,16
ffffffffc02065e6:	8a2e                	mv	s4,a1
ffffffffc02065e8:	bd99                	j	ffffffffc020643e <vprintfmt+0x120>
                putch('-', putdat);
ffffffffc02065ea:	85ca                	mv	a1,s2
ffffffffc02065ec:	02d00513          	li	a0,45
ffffffffc02065f0:	9482                	jalr	s1
                num = -(long long)num;
ffffffffc02065f2:	40800633          	neg	a2,s0
ffffffffc02065f6:	8a5e                	mv	s4,s7
ffffffffc02065f8:	46a9                	li	a3,10
ffffffffc02065fa:	b591                	j	ffffffffc020643e <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
ffffffffc02065fc:	e329                	bnez	a4,ffffffffc020663e <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02065fe:	02800793          	li	a5,40
ffffffffc0206602:	853e                	mv	a0,a5
ffffffffc0206604:	00002d97          	auipc	s11,0x2
ffffffffc0206608:	515d8d93          	addi	s11,s11,1301 # ffffffffc0208b19 <etext+0x23b7>
ffffffffc020660c:	b5f5                	j	ffffffffc02064f8 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020660e:	85e6                	mv	a1,s9
ffffffffc0206610:	856e                	mv	a0,s11
ffffffffc0206612:	08a000ef          	jal	ffffffffc020669c <strnlen>
ffffffffc0206616:	40ad0d3b          	subw	s10,s10,a0
ffffffffc020661a:	01a05863          	blez	s10,ffffffffc020662a <vprintfmt+0x30c>
                    putch(padc, putdat);
ffffffffc020661e:	85ca                	mv	a1,s2
ffffffffc0206620:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206622:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
ffffffffc0206624:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0206626:	fe0d1ce3          	bnez	s10,ffffffffc020661e <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020662a:	000dc783          	lbu	a5,0(s11)
ffffffffc020662e:	0007851b          	sext.w	a0,a5
ffffffffc0206632:	ec0792e3          	bnez	a5,ffffffffc02064f6 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0206636:	6a22                	ld	s4,8(sp)
ffffffffc0206638:	bb29                	j	ffffffffc0206352 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020663a:	8462                	mv	s0,s8
ffffffffc020663c:	bbd9                	j	ffffffffc0206412 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020663e:	85e6                	mv	a1,s9
ffffffffc0206640:	00002517          	auipc	a0,0x2
ffffffffc0206644:	4d850513          	addi	a0,a0,1240 # ffffffffc0208b18 <etext+0x23b6>
ffffffffc0206648:	054000ef          	jal	ffffffffc020669c <strnlen>
ffffffffc020664c:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0206650:	02800793          	li	a5,40
                p = "(null)";
ffffffffc0206654:	00002d97          	auipc	s11,0x2
ffffffffc0206658:	4c4d8d93          	addi	s11,s11,1220 # ffffffffc0208b18 <etext+0x23b6>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020665c:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020665e:	fda040e3          	bgtz	s10,ffffffffc020661e <vprintfmt+0x300>
ffffffffc0206662:	bd51                	j	ffffffffc02064f6 <vprintfmt+0x1d8>

ffffffffc0206664 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0206664:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0206666:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020666a:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020666c:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020666e:	ec06                	sd	ra,24(sp)
ffffffffc0206670:	f83a                	sd	a4,48(sp)
ffffffffc0206672:	fc3e                	sd	a5,56(sp)
ffffffffc0206674:	e0c2                	sd	a6,64(sp)
ffffffffc0206676:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0206678:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc020667a:	ca5ff0ef          	jal	ffffffffc020631e <vprintfmt>
}
ffffffffc020667e:	60e2                	ld	ra,24(sp)
ffffffffc0206680:	6161                	addi	sp,sp,80
ffffffffc0206682:	8082                	ret

ffffffffc0206684 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0206684:	00054783          	lbu	a5,0(a0)
ffffffffc0206688:	cb81                	beqz	a5,ffffffffc0206698 <strlen+0x14>
    size_t cnt = 0;
ffffffffc020668a:	4781                	li	a5,0
        cnt ++;
ffffffffc020668c:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc020668e:	00f50733          	add	a4,a0,a5
ffffffffc0206692:	00074703          	lbu	a4,0(a4)
ffffffffc0206696:	fb7d                	bnez	a4,ffffffffc020668c <strlen+0x8>
    }
    return cnt;
}
ffffffffc0206698:	853e                	mv	a0,a5
ffffffffc020669a:	8082                	ret

ffffffffc020669c <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc020669c:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc020669e:	e589                	bnez	a1,ffffffffc02066a8 <strnlen+0xc>
ffffffffc02066a0:	a811                	j	ffffffffc02066b4 <strnlen+0x18>
        cnt ++;
ffffffffc02066a2:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02066a4:	00f58863          	beq	a1,a5,ffffffffc02066b4 <strnlen+0x18>
ffffffffc02066a8:	00f50733          	add	a4,a0,a5
ffffffffc02066ac:	00074703          	lbu	a4,0(a4)
ffffffffc02066b0:	fb6d                	bnez	a4,ffffffffc02066a2 <strnlen+0x6>
ffffffffc02066b2:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02066b4:	852e                	mv	a0,a1
ffffffffc02066b6:	8082                	ret

ffffffffc02066b8 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02066b8:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02066ba:	0005c703          	lbu	a4,0(a1)
ffffffffc02066be:	0585                	addi	a1,a1,1
ffffffffc02066c0:	0785                	addi	a5,a5,1
ffffffffc02066c2:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02066c6:	fb75                	bnez	a4,ffffffffc02066ba <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02066c8:	8082                	ret

ffffffffc02066ca <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02066ca:	00054783          	lbu	a5,0(a0)
ffffffffc02066ce:	e791                	bnez	a5,ffffffffc02066da <strcmp+0x10>
ffffffffc02066d0:	a01d                	j	ffffffffc02066f6 <strcmp+0x2c>
ffffffffc02066d2:	00054783          	lbu	a5,0(a0)
ffffffffc02066d6:	cb99                	beqz	a5,ffffffffc02066ec <strcmp+0x22>
ffffffffc02066d8:	0585                	addi	a1,a1,1
ffffffffc02066da:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc02066de:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02066e0:	fef709e3          	beq	a4,a5,ffffffffc02066d2 <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02066e4:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02066e8:	9d19                	subw	a0,a0,a4
ffffffffc02066ea:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02066ec:	0015c703          	lbu	a4,1(a1)
ffffffffc02066f0:	4501                	li	a0,0
}
ffffffffc02066f2:	9d19                	subw	a0,a0,a4
ffffffffc02066f4:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02066f6:	0005c703          	lbu	a4,0(a1)
ffffffffc02066fa:	4501                	li	a0,0
ffffffffc02066fc:	b7f5                	j	ffffffffc02066e8 <strcmp+0x1e>

ffffffffc02066fe <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02066fe:	ce01                	beqz	a2,ffffffffc0206716 <strncmp+0x18>
ffffffffc0206700:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0206704:	167d                	addi	a2,a2,-1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0206706:	cb91                	beqz	a5,ffffffffc020671a <strncmp+0x1c>
ffffffffc0206708:	0005c703          	lbu	a4,0(a1)
ffffffffc020670c:	00f71763          	bne	a4,a5,ffffffffc020671a <strncmp+0x1c>
        n --, s1 ++, s2 ++;
ffffffffc0206710:	0505                	addi	a0,a0,1
ffffffffc0206712:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0206714:	f675                	bnez	a2,ffffffffc0206700 <strncmp+0x2>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0206716:	4501                	li	a0,0
ffffffffc0206718:	8082                	ret
ffffffffc020671a:	00054503          	lbu	a0,0(a0)
ffffffffc020671e:	0005c783          	lbu	a5,0(a1)
ffffffffc0206722:	9d1d                	subw	a0,a0,a5
}
ffffffffc0206724:	8082                	ret

ffffffffc0206726 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0206726:	a021                	j	ffffffffc020672e <strchr+0x8>
        if (*s == c) {
ffffffffc0206728:	00f58763          	beq	a1,a5,ffffffffc0206736 <strchr+0x10>
            return (char *)s;
        }
        s ++;
ffffffffc020672c:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020672e:	00054783          	lbu	a5,0(a0)
ffffffffc0206732:	fbfd                	bnez	a5,ffffffffc0206728 <strchr+0x2>
    }
    return NULL;
ffffffffc0206734:	4501                	li	a0,0
}
ffffffffc0206736:	8082                	ret

ffffffffc0206738 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0206738:	ca01                	beqz	a2,ffffffffc0206748 <memset+0x10>
ffffffffc020673a:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020673c:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020673e:	0785                	addi	a5,a5,1
ffffffffc0206740:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0206744:	fef61de3          	bne	a2,a5,ffffffffc020673e <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0206748:	8082                	ret

ffffffffc020674a <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc020674a:	ca19                	beqz	a2,ffffffffc0206760 <memcpy+0x16>
ffffffffc020674c:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020674e:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0206750:	0005c703          	lbu	a4,0(a1)
ffffffffc0206754:	0585                	addi	a1,a1,1
ffffffffc0206756:	0785                	addi	a5,a5,1
ffffffffc0206758:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc020675c:	feb61ae3          	bne	a2,a1,ffffffffc0206750 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0206760:	8082                	ret
