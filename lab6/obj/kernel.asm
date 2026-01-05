
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	0000c297          	auipc	t0,0xc
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc020c000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	0000c297          	auipc	t0,0xc
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc020c008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c020b2b7          	lui	t0,0xc020b
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
ffffffffc020003c:	c020b137          	lui	sp,0xc020b

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
ffffffffc020004a:	000b1517          	auipc	a0,0xb1
ffffffffc020004e:	19e50513          	addi	a0,a0,414 # ffffffffc02b11e8 <buf>
ffffffffc0200052:	000b5617          	auipc	a2,0xb5
ffffffffc0200056:	67660613          	addi	a2,a2,1654 # ffffffffc02b56c8 <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16 # ffffffffc020aff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	0cf050ef          	jal	ffffffffc0205930 <memset>
    cons_init(); // init the console
ffffffffc0200066:	4da000ef          	jal	ffffffffc0200540 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006a:	00006597          	auipc	a1,0x6
ffffffffc020006e:	8f658593          	addi	a1,a1,-1802 # ffffffffc0205960 <etext+0x6>
ffffffffc0200072:	00006517          	auipc	a0,0x6
ffffffffc0200076:	90e50513          	addi	a0,a0,-1778 # ffffffffc0205980 <etext+0x26>
ffffffffc020007a:	11e000ef          	jal	ffffffffc0200198 <cprintf>

    print_kerninfo();
ffffffffc020007e:	1ac000ef          	jal	ffffffffc020022a <print_kerninfo>

    // grade_backtrace();

    dtb_init(); // init dtb
ffffffffc0200082:	530000ef          	jal	ffffffffc02005b2 <dtb_init>

    pmm_init(); // init physical memory management
ffffffffc0200086:	007020ef          	jal	ffffffffc020288c <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	07b000ef          	jal	ffffffffc0200904 <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	079000ef          	jal	ffffffffc0200906 <idt_init>

    vmm_init(); // init virtual memory management
ffffffffc0200092:	091030ef          	jal	ffffffffc0203922 <vmm_init>
    sched_init();
ffffffffc0200096:	106050ef          	jal	ffffffffc020519c <sched_init>
    proc_init(); // init process table
ffffffffc020009a:	5a3040ef          	jal	ffffffffc0204e3c <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009e:	45a000ef          	jal	ffffffffc02004f8 <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc02000a2:	057000ef          	jal	ffffffffc02008f8 <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a6:	737040ef          	jal	ffffffffc0204fdc <cpu_idle>

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
ffffffffc02000be:	8ce50513          	addi	a0,a0,-1842 # ffffffffc0205988 <etext+0x2e>
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
ffffffffc02000ca:	000b1997          	auipc	s3,0xb1
ffffffffc02000ce:	11e98993          	addi	s3,s3,286 # ffffffffc02b11e8 <buf>
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
ffffffffc0200144:	000b1517          	auipc	a0,0xb1
ffffffffc0200148:	0a450513          	addi	a0,a0,164 # ffffffffc02b11e8 <buf>
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
ffffffffc020018c:	38a050ef          	jal	ffffffffc0205516 <vprintfmt>
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
ffffffffc02001c0:	356050ef          	jal	ffffffffc0205516 <vprintfmt>
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
ffffffffc020022c:	00005517          	auipc	a0,0x5
ffffffffc0200230:	76450513          	addi	a0,a0,1892 # ffffffffc0205990 <etext+0x36>
void print_kerninfo(void) {
ffffffffc0200234:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200236:	f63ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc020023a:	00000597          	auipc	a1,0x0
ffffffffc020023e:	e1058593          	addi	a1,a1,-496 # ffffffffc020004a <kern_init>
ffffffffc0200242:	00005517          	auipc	a0,0x5
ffffffffc0200246:	76e50513          	addi	a0,a0,1902 # ffffffffc02059b0 <etext+0x56>
ffffffffc020024a:	f4fff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020024e:	00005597          	auipc	a1,0x5
ffffffffc0200252:	70c58593          	addi	a1,a1,1804 # ffffffffc020595a <etext>
ffffffffc0200256:	00005517          	auipc	a0,0x5
ffffffffc020025a:	77a50513          	addi	a0,a0,1914 # ffffffffc02059d0 <etext+0x76>
ffffffffc020025e:	f3bff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc0200262:	000b1597          	auipc	a1,0xb1
ffffffffc0200266:	f8658593          	addi	a1,a1,-122 # ffffffffc02b11e8 <buf>
ffffffffc020026a:	00005517          	auipc	a0,0x5
ffffffffc020026e:	78650513          	addi	a0,a0,1926 # ffffffffc02059f0 <etext+0x96>
ffffffffc0200272:	f27ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200276:	000b5597          	auipc	a1,0xb5
ffffffffc020027a:	45258593          	addi	a1,a1,1106 # ffffffffc02b56c8 <end>
ffffffffc020027e:	00005517          	auipc	a0,0x5
ffffffffc0200282:	79250513          	addi	a0,a0,1938 # ffffffffc0205a10 <etext+0xb6>
ffffffffc0200286:	f13ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc020028a:	00000717          	auipc	a4,0x0
ffffffffc020028e:	dc070713          	addi	a4,a4,-576 # ffffffffc020004a <kern_init>
ffffffffc0200292:	000b6797          	auipc	a5,0xb6
ffffffffc0200296:	83578793          	addi	a5,a5,-1995 # ffffffffc02b5ac7 <end+0x3ff>
ffffffffc020029a:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020029c:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02002a0:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002a2:	3ff5f593          	andi	a1,a1,1023
ffffffffc02002a6:	95be                	add	a1,a1,a5
ffffffffc02002a8:	85a9                	srai	a1,a1,0xa
ffffffffc02002aa:	00005517          	auipc	a0,0x5
ffffffffc02002ae:	78650513          	addi	a0,a0,1926 # ffffffffc0205a30 <etext+0xd6>
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
ffffffffc02002b8:	00005617          	auipc	a2,0x5
ffffffffc02002bc:	7a860613          	addi	a2,a2,1960 # ffffffffc0205a60 <etext+0x106>
ffffffffc02002c0:	04d00593          	li	a1,77
ffffffffc02002c4:	00005517          	auipc	a0,0x5
ffffffffc02002c8:	7b450513          	addi	a0,a0,1972 # ffffffffc0205a78 <etext+0x11e>
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
ffffffffc02002da:	00007417          	auipc	s0,0x7
ffffffffc02002de:	4ce40413          	addi	s0,s0,1230 # ffffffffc02077a8 <commands>
ffffffffc02002e2:	00007497          	auipc	s1,0x7
ffffffffc02002e6:	50e48493          	addi	s1,s1,1294 # ffffffffc02077f0 <commands+0x48>
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002ea:	6410                	ld	a2,8(s0)
ffffffffc02002ec:	600c                	ld	a1,0(s0)
ffffffffc02002ee:	00005517          	auipc	a0,0x5
ffffffffc02002f2:	7a250513          	addi	a0,a0,1954 # ffffffffc0205a90 <etext+0x136>
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
ffffffffc0200332:	00005517          	auipc	a0,0x5
ffffffffc0200336:	76e50513          	addi	a0,a0,1902 # ffffffffc0205aa0 <etext+0x146>
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
ffffffffc020034a:	00005517          	auipc	a0,0x5
ffffffffc020034e:	77e50513          	addi	a0,a0,1918 # ffffffffc0205ac8 <etext+0x16e>
ffffffffc0200352:	e47ff0ef          	jal	ffffffffc0200198 <cprintf>
    if (tf != NULL) {
ffffffffc0200356:	000a0563          	beqz	s4,ffffffffc0200360 <kmonitor+0x34>
        print_trapframe(tf);
ffffffffc020035a:	8552                	mv	a0,s4
ffffffffc020035c:	792000ef          	jal	ffffffffc0200aee <print_trapframe>
ffffffffc0200360:	00007a97          	auipc	s5,0x7
ffffffffc0200364:	448a8a93          	addi	s5,s5,1096 # ffffffffc02077a8 <commands>
        if (argc == MAXARGS - 1) {
ffffffffc0200368:	49bd                	li	s3,15
        if ((buf = readline("K> ")) != NULL) {
ffffffffc020036a:	00005517          	auipc	a0,0x5
ffffffffc020036e:	78650513          	addi	a0,a0,1926 # ffffffffc0205af0 <etext+0x196>
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
ffffffffc0200388:	00007497          	auipc	s1,0x7
ffffffffc020038c:	42048493          	addi	s1,s1,1056 # ffffffffc02077a8 <commands>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200390:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200392:	6582                	ld	a1,0(sp)
ffffffffc0200394:	6088                	ld	a0,0(s1)
ffffffffc0200396:	52c050ef          	jal	ffffffffc02058c2 <strcmp>
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
ffffffffc02003a8:	00005517          	auipc	a0,0x5
ffffffffc02003ac:	77850513          	addi	a0,a0,1912 # ffffffffc0205b20 <etext+0x1c6>
ffffffffc02003b0:	de9ff0ef          	jal	ffffffffc0200198 <cprintf>
    return 0;
ffffffffc02003b4:	bf5d                	j	ffffffffc020036a <kmonitor+0x3e>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02003b6:	00005517          	auipc	a0,0x5
ffffffffc02003ba:	74250513          	addi	a0,a0,1858 # ffffffffc0205af8 <etext+0x19e>
ffffffffc02003be:	560050ef          	jal	ffffffffc020591e <strchr>
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
ffffffffc02003f8:	00005517          	auipc	a0,0x5
ffffffffc02003fc:	70050513          	addi	a0,a0,1792 # ffffffffc0205af8 <etext+0x19e>
ffffffffc0200400:	51e050ef          	jal	ffffffffc020591e <strchr>
ffffffffc0200404:	d575                	beqz	a0,ffffffffc02003f0 <kmonitor+0xc4>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200406:	00044583          	lbu	a1,0(s0)
ffffffffc020040a:	dda5                	beqz	a1,ffffffffc0200382 <kmonitor+0x56>
ffffffffc020040c:	b76d                	j	ffffffffc02003b6 <kmonitor+0x8a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020040e:	45c1                	li	a1,16
ffffffffc0200410:	00005517          	auipc	a0,0x5
ffffffffc0200414:	6f050513          	addi	a0,a0,1776 # ffffffffc0205b00 <etext+0x1a6>
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
ffffffffc020044a:	000b5317          	auipc	t1,0xb5
ffffffffc020044e:	1f633303          	ld	t1,502(t1) # ffffffffc02b5640 <is_panic>
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
ffffffffc0200470:	00005517          	auipc	a0,0x5
ffffffffc0200474:	75850513          	addi	a0,a0,1880 # ffffffffc0205bc8 <etext+0x26e>
    is_panic = 1;
ffffffffc0200478:	000b5697          	auipc	a3,0xb5
ffffffffc020047c:	1ce6b423          	sd	a4,456(a3) # ffffffffc02b5640 <is_panic>
    va_start(ap, fmt);
ffffffffc0200480:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200482:	d17ff0ef          	jal	ffffffffc0200198 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200486:	65a2                	ld	a1,8(sp)
ffffffffc0200488:	8522                	mv	a0,s0
ffffffffc020048a:	cefff0ef          	jal	ffffffffc0200178 <vcprintf>
    cprintf("\n");
ffffffffc020048e:	00005517          	auipc	a0,0x5
ffffffffc0200492:	75a50513          	addi	a0,a0,1882 # ffffffffc0205be8 <etext+0x28e>
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
ffffffffc02004c2:	00005517          	auipc	a0,0x5
ffffffffc02004c6:	72e50513          	addi	a0,a0,1838 # ffffffffc0205bf0 <etext+0x296>
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
ffffffffc02004e4:	00005517          	auipc	a0,0x5
ffffffffc02004e8:	70450513          	addi	a0,a0,1796 # ffffffffc0205be8 <etext+0x28e>
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
ffffffffc0200506:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_matrix_out_size+0xd160>
ffffffffc020050a:	953e                	add	a0,a0,a5
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc020050c:	4581                	li	a1,0
ffffffffc020050e:	4601                	li	a2,0
ffffffffc0200510:	4881                	li	a7,0
ffffffffc0200512:	00000073          	ecall
    cprintf("++ setup timer interrupts\n");
ffffffffc0200516:	00005517          	auipc	a0,0x5
ffffffffc020051a:	6fa50513          	addi	a0,a0,1786 # ffffffffc0205c10 <etext+0x2b6>
    ticks = 0;
ffffffffc020051e:	000b5797          	auipc	a5,0xb5
ffffffffc0200522:	1207b523          	sd	zero,298(a5) # ffffffffc02b5648 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200526:	b98d                	j	ffffffffc0200198 <cprintf>

ffffffffc0200528 <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200528:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020052c:	67e1                	lui	a5,0x18
ffffffffc020052e:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_matrix_out_size+0xd160>
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
#include <assert.h>
#include <atomic.h>

static inline bool __intr_save(void)
{
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0200542:	100027f3          	csrr	a5,sstatus
ffffffffc0200546:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc0200548:	0ff57513          	zext.b	a0,a0
ffffffffc020054c:	e799                	bnez	a5,ffffffffc020055a <cons_putc+0x18>
ffffffffc020054e:	4581                	li	a1,0
ffffffffc0200550:	4601                	li	a2,0
ffffffffc0200552:	4885                	li	a7,1
ffffffffc0200554:	00000073          	ecall
    return 0;
}

static inline void __intr_restore(bool flag)
{
    if (flag)
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
    {
        intr_enable();
ffffffffc0200574:	a651                	j	ffffffffc02008f8 <intr_enable>

ffffffffc0200576 <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE)
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
ffffffffc02005b4:	00005517          	auipc	a0,0x5
ffffffffc02005b8:	67c50513          	addi	a0,a0,1660 # ffffffffc0205c30 <etext+0x2d6>
void dtb_init(void) {
ffffffffc02005bc:	f406                	sd	ra,40(sp)
ffffffffc02005be:	f022                	sd	s0,32(sp)
    cprintf("DTB Init\n");
ffffffffc02005c0:	bd9ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc02005c4:	0000c597          	auipc	a1,0xc
ffffffffc02005c8:	a3c5b583          	ld	a1,-1476(a1) # ffffffffc020c000 <boot_hartid>
ffffffffc02005cc:	00005517          	auipc	a0,0x5
ffffffffc02005d0:	67450513          	addi	a0,a0,1652 # ffffffffc0205c40 <etext+0x2e6>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc02005d4:	0000c417          	auipc	s0,0xc
ffffffffc02005d8:	a3440413          	addi	s0,s0,-1484 # ffffffffc020c008 <boot_dtb>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc02005dc:	bbdff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc02005e0:	600c                	ld	a1,0(s0)
ffffffffc02005e2:	00005517          	auipc	a0,0x5
ffffffffc02005e6:	66e50513          	addi	a0,a0,1646 # ffffffffc0205c50 <etext+0x2f6>
ffffffffc02005ea:	bafff0ef          	jal	ffffffffc0200198 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc02005ee:	6018                	ld	a4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc02005f0:	00005517          	auipc	a0,0x5
ffffffffc02005f4:	67850513          	addi	a0,a0,1656 # ffffffffc0205c68 <etext+0x30e>
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
ffffffffc0200608:	eed68693          	addi	a3,a3,-275 # ffffffffd00dfeed <end+0xfe2a825>
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
ffffffffc02006e2:	00005517          	auipc	a0,0x5
ffffffffc02006e6:	64e50513          	addi	a0,a0,1614 # ffffffffc0205d30 <etext+0x3d6>
ffffffffc02006ea:	aafff0ef          	jal	ffffffffc0200198 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc02006ee:	64e2                	ld	s1,24(sp)
ffffffffc02006f0:	6942                	ld	s2,16(sp)
ffffffffc02006f2:	00005517          	auipc	a0,0x5
ffffffffc02006f6:	67650513          	addi	a0,a0,1654 # ffffffffc0205d68 <etext+0x40e>
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
ffffffffc0200706:	00005517          	auipc	a0,0x5
ffffffffc020070a:	58250513          	addi	a0,a0,1410 # ffffffffc0205c88 <etext+0x32e>
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
ffffffffc020074c:	130050ef          	jal	ffffffffc020587c <strlen>
ffffffffc0200750:	84aa                	mv	s1,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200752:	4619                	li	a2,6
ffffffffc0200754:	8522                	mv	a0,s0
ffffffffc0200756:	00005597          	auipc	a1,0x5
ffffffffc020075a:	55a58593          	addi	a1,a1,1370 # ffffffffc0205cb0 <etext+0x356>
ffffffffc020075e:	198050ef          	jal	ffffffffc02058f6 <strncmp>
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
ffffffffc0200782:	00005597          	auipc	a1,0x5
ffffffffc0200786:	53658593          	addi	a1,a1,1334 # ffffffffc0205cb8 <etext+0x35e>
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
ffffffffc02007b8:	10a050ef          	jal	ffffffffc02058c2 <strcmp>
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
ffffffffc02007d8:	00005517          	auipc	a0,0x5
ffffffffc02007dc:	4e850513          	addi	a0,a0,1256 # ffffffffc0205cc0 <etext+0x366>
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
ffffffffc02008a2:	00005517          	auipc	a0,0x5
ffffffffc02008a6:	43e50513          	addi	a0,a0,1086 # ffffffffc0205ce0 <etext+0x386>
ffffffffc02008aa:	8efff0ef          	jal	ffffffffc0200198 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc02008ae:	01445613          	srli	a2,s0,0x14
ffffffffc02008b2:	85a2                	mv	a1,s0
ffffffffc02008b4:	00005517          	auipc	a0,0x5
ffffffffc02008b8:	44450513          	addi	a0,a0,1092 # ffffffffc0205cf8 <etext+0x39e>
ffffffffc02008bc:	8ddff0ef          	jal	ffffffffc0200198 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc02008c0:	009405b3          	add	a1,s0,s1
ffffffffc02008c4:	15fd                	addi	a1,a1,-1
ffffffffc02008c6:	00005517          	auipc	a0,0x5
ffffffffc02008ca:	45250513          	addi	a0,a0,1106 # ffffffffc0205d18 <etext+0x3be>
ffffffffc02008ce:	8cbff0ef          	jal	ffffffffc0200198 <cprintf>
        memory_base = mem_base;
ffffffffc02008d2:	000b5797          	auipc	a5,0xb5
ffffffffc02008d6:	d897b323          	sd	s1,-634(a5) # ffffffffc02b5658 <memory_base>
        memory_size = mem_size;
ffffffffc02008da:	000b5797          	auipc	a5,0xb5
ffffffffc02008de:	d687bb23          	sd	s0,-650(a5) # ffffffffc02b5650 <memory_size>
ffffffffc02008e2:	b531                	j	ffffffffc02006ee <dtb_init+0x13c>

ffffffffc02008e4 <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02008e4:	000b5517          	auipc	a0,0xb5
ffffffffc02008e8:	d7453503          	ld	a0,-652(a0) # ffffffffc02b5658 <memory_base>
ffffffffc02008ec:	8082                	ret

ffffffffc02008ee <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc02008ee:	000b5517          	auipc	a0,0xb5
ffffffffc02008f2:	d6253503          	ld	a0,-670(a0) # ffffffffc02b5650 <memory_size>
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
ffffffffc020090e:	4ea78793          	addi	a5,a5,1258 # ffffffffc0200df4 <__alltraps>
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
ffffffffc0200928:	00005517          	auipc	a0,0x5
ffffffffc020092c:	45850513          	addi	a0,a0,1112 # ffffffffc0205d80 <etext+0x426>
{
ffffffffc0200930:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200932:	867ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc0200936:	640c                	ld	a1,8(s0)
ffffffffc0200938:	00005517          	auipc	a0,0x5
ffffffffc020093c:	46050513          	addi	a0,a0,1120 # ffffffffc0205d98 <etext+0x43e>
ffffffffc0200940:	859ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc0200944:	680c                	ld	a1,16(s0)
ffffffffc0200946:	00005517          	auipc	a0,0x5
ffffffffc020094a:	46a50513          	addi	a0,a0,1130 # ffffffffc0205db0 <etext+0x456>
ffffffffc020094e:	84bff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200952:	6c0c                	ld	a1,24(s0)
ffffffffc0200954:	00005517          	auipc	a0,0x5
ffffffffc0200958:	47450513          	addi	a0,a0,1140 # ffffffffc0205dc8 <etext+0x46e>
ffffffffc020095c:	83dff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200960:	700c                	ld	a1,32(s0)
ffffffffc0200962:	00005517          	auipc	a0,0x5
ffffffffc0200966:	47e50513          	addi	a0,a0,1150 # ffffffffc0205de0 <etext+0x486>
ffffffffc020096a:	82fff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc020096e:	740c                	ld	a1,40(s0)
ffffffffc0200970:	00005517          	auipc	a0,0x5
ffffffffc0200974:	48850513          	addi	a0,a0,1160 # ffffffffc0205df8 <etext+0x49e>
ffffffffc0200978:	821ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc020097c:	780c                	ld	a1,48(s0)
ffffffffc020097e:	00005517          	auipc	a0,0x5
ffffffffc0200982:	49250513          	addi	a0,a0,1170 # ffffffffc0205e10 <etext+0x4b6>
ffffffffc0200986:	813ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc020098a:	7c0c                	ld	a1,56(s0)
ffffffffc020098c:	00005517          	auipc	a0,0x5
ffffffffc0200990:	49c50513          	addi	a0,a0,1180 # ffffffffc0205e28 <etext+0x4ce>
ffffffffc0200994:	805ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200998:	602c                	ld	a1,64(s0)
ffffffffc020099a:	00005517          	auipc	a0,0x5
ffffffffc020099e:	4a650513          	addi	a0,a0,1190 # ffffffffc0205e40 <etext+0x4e6>
ffffffffc02009a2:	ff6ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02009a6:	642c                	ld	a1,72(s0)
ffffffffc02009a8:	00005517          	auipc	a0,0x5
ffffffffc02009ac:	4b050513          	addi	a0,a0,1200 # ffffffffc0205e58 <etext+0x4fe>
ffffffffc02009b0:	fe8ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02009b4:	682c                	ld	a1,80(s0)
ffffffffc02009b6:	00005517          	auipc	a0,0x5
ffffffffc02009ba:	4ba50513          	addi	a0,a0,1210 # ffffffffc0205e70 <etext+0x516>
ffffffffc02009be:	fdaff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02009c2:	6c2c                	ld	a1,88(s0)
ffffffffc02009c4:	00005517          	auipc	a0,0x5
ffffffffc02009c8:	4c450513          	addi	a0,a0,1220 # ffffffffc0205e88 <etext+0x52e>
ffffffffc02009cc:	fccff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02009d0:	702c                	ld	a1,96(s0)
ffffffffc02009d2:	00005517          	auipc	a0,0x5
ffffffffc02009d6:	4ce50513          	addi	a0,a0,1230 # ffffffffc0205ea0 <etext+0x546>
ffffffffc02009da:	fbeff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc02009de:	742c                	ld	a1,104(s0)
ffffffffc02009e0:	00005517          	auipc	a0,0x5
ffffffffc02009e4:	4d850513          	addi	a0,a0,1240 # ffffffffc0205eb8 <etext+0x55e>
ffffffffc02009e8:	fb0ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc02009ec:	782c                	ld	a1,112(s0)
ffffffffc02009ee:	00005517          	auipc	a0,0x5
ffffffffc02009f2:	4e250513          	addi	a0,a0,1250 # ffffffffc0205ed0 <etext+0x576>
ffffffffc02009f6:	fa2ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc02009fa:	7c2c                	ld	a1,120(s0)
ffffffffc02009fc:	00005517          	auipc	a0,0x5
ffffffffc0200a00:	4ec50513          	addi	a0,a0,1260 # ffffffffc0205ee8 <etext+0x58e>
ffffffffc0200a04:	f94ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200a08:	604c                	ld	a1,128(s0)
ffffffffc0200a0a:	00005517          	auipc	a0,0x5
ffffffffc0200a0e:	4f650513          	addi	a0,a0,1270 # ffffffffc0205f00 <etext+0x5a6>
ffffffffc0200a12:	f86ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200a16:	644c                	ld	a1,136(s0)
ffffffffc0200a18:	00005517          	auipc	a0,0x5
ffffffffc0200a1c:	50050513          	addi	a0,a0,1280 # ffffffffc0205f18 <etext+0x5be>
ffffffffc0200a20:	f78ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200a24:	684c                	ld	a1,144(s0)
ffffffffc0200a26:	00005517          	auipc	a0,0x5
ffffffffc0200a2a:	50a50513          	addi	a0,a0,1290 # ffffffffc0205f30 <etext+0x5d6>
ffffffffc0200a2e:	f6aff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200a32:	6c4c                	ld	a1,152(s0)
ffffffffc0200a34:	00005517          	auipc	a0,0x5
ffffffffc0200a38:	51450513          	addi	a0,a0,1300 # ffffffffc0205f48 <etext+0x5ee>
ffffffffc0200a3c:	f5cff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200a40:	704c                	ld	a1,160(s0)
ffffffffc0200a42:	00005517          	auipc	a0,0x5
ffffffffc0200a46:	51e50513          	addi	a0,a0,1310 # ffffffffc0205f60 <etext+0x606>
ffffffffc0200a4a:	f4eff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200a4e:	744c                	ld	a1,168(s0)
ffffffffc0200a50:	00005517          	auipc	a0,0x5
ffffffffc0200a54:	52850513          	addi	a0,a0,1320 # ffffffffc0205f78 <etext+0x61e>
ffffffffc0200a58:	f40ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200a5c:	784c                	ld	a1,176(s0)
ffffffffc0200a5e:	00005517          	auipc	a0,0x5
ffffffffc0200a62:	53250513          	addi	a0,a0,1330 # ffffffffc0205f90 <etext+0x636>
ffffffffc0200a66:	f32ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200a6a:	7c4c                	ld	a1,184(s0)
ffffffffc0200a6c:	00005517          	auipc	a0,0x5
ffffffffc0200a70:	53c50513          	addi	a0,a0,1340 # ffffffffc0205fa8 <etext+0x64e>
ffffffffc0200a74:	f24ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200a78:	606c                	ld	a1,192(s0)
ffffffffc0200a7a:	00005517          	auipc	a0,0x5
ffffffffc0200a7e:	54650513          	addi	a0,a0,1350 # ffffffffc0205fc0 <etext+0x666>
ffffffffc0200a82:	f16ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200a86:	646c                	ld	a1,200(s0)
ffffffffc0200a88:	00005517          	auipc	a0,0x5
ffffffffc0200a8c:	55050513          	addi	a0,a0,1360 # ffffffffc0205fd8 <etext+0x67e>
ffffffffc0200a90:	f08ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200a94:	686c                	ld	a1,208(s0)
ffffffffc0200a96:	00005517          	auipc	a0,0x5
ffffffffc0200a9a:	55a50513          	addi	a0,a0,1370 # ffffffffc0205ff0 <etext+0x696>
ffffffffc0200a9e:	efaff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200aa2:	6c6c                	ld	a1,216(s0)
ffffffffc0200aa4:	00005517          	auipc	a0,0x5
ffffffffc0200aa8:	56450513          	addi	a0,a0,1380 # ffffffffc0206008 <etext+0x6ae>
ffffffffc0200aac:	eecff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200ab0:	706c                	ld	a1,224(s0)
ffffffffc0200ab2:	00005517          	auipc	a0,0x5
ffffffffc0200ab6:	56e50513          	addi	a0,a0,1390 # ffffffffc0206020 <etext+0x6c6>
ffffffffc0200aba:	edeff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200abe:	746c                	ld	a1,232(s0)
ffffffffc0200ac0:	00005517          	auipc	a0,0x5
ffffffffc0200ac4:	57850513          	addi	a0,a0,1400 # ffffffffc0206038 <etext+0x6de>
ffffffffc0200ac8:	ed0ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200acc:	786c                	ld	a1,240(s0)
ffffffffc0200ace:	00005517          	auipc	a0,0x5
ffffffffc0200ad2:	58250513          	addi	a0,a0,1410 # ffffffffc0206050 <etext+0x6f6>
ffffffffc0200ad6:	ec2ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200ada:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200adc:	6402                	ld	s0,0(sp)
ffffffffc0200ade:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200ae0:	00005517          	auipc	a0,0x5
ffffffffc0200ae4:	58850513          	addi	a0,a0,1416 # ffffffffc0206068 <etext+0x70e>
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
ffffffffc0200af6:	00005517          	auipc	a0,0x5
ffffffffc0200afa:	58a50513          	addi	a0,a0,1418 # ffffffffc0206080 <etext+0x726>
{
ffffffffc0200afe:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200b00:	e98ff0ef          	jal	ffffffffc0200198 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200b04:	8522                	mv	a0,s0
ffffffffc0200b06:	e1bff0ef          	jal	ffffffffc0200920 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200b0a:	10043583          	ld	a1,256(s0)
ffffffffc0200b0e:	00005517          	auipc	a0,0x5
ffffffffc0200b12:	58a50513          	addi	a0,a0,1418 # ffffffffc0206098 <etext+0x73e>
ffffffffc0200b16:	e82ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200b1a:	10843583          	ld	a1,264(s0)
ffffffffc0200b1e:	00005517          	auipc	a0,0x5
ffffffffc0200b22:	59250513          	addi	a0,a0,1426 # ffffffffc02060b0 <etext+0x756>
ffffffffc0200b26:	e72ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200b2a:	11043583          	ld	a1,272(s0)
ffffffffc0200b2e:	00005517          	auipc	a0,0x5
ffffffffc0200b32:	59a50513          	addi	a0,a0,1434 # ffffffffc02060c8 <etext+0x76e>
ffffffffc0200b36:	e62ff0ef          	jal	ffffffffc0200198 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b3a:	11843583          	ld	a1,280(s0)
}
ffffffffc0200b3e:	6402                	ld	s0,0(sp)
ffffffffc0200b40:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b42:	00005517          	auipc	a0,0x5
ffffffffc0200b46:	59650513          	addi	a0,a0,1430 # ffffffffc02060d8 <etext+0x77e>
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
ffffffffc0200b5a:	0af76263          	bltu	a4,a5,ffffffffc0200bfe <interrupt_handler+0xae>
ffffffffc0200b5e:	00007717          	auipc	a4,0x7
ffffffffc0200b62:	c9270713          	addi	a4,a4,-878 # ffffffffc02077f0 <commands+0x48>
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
ffffffffc0200b70:	00005517          	auipc	a0,0x5
ffffffffc0200b74:	5e050513          	addi	a0,a0,1504 # ffffffffc0206150 <etext+0x7f6>
ffffffffc0200b78:	e20ff06f          	j	ffffffffc0200198 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200b7c:	00005517          	auipc	a0,0x5
ffffffffc0200b80:	5b450513          	addi	a0,a0,1460 # ffffffffc0206130 <etext+0x7d6>
ffffffffc0200b84:	e14ff06f          	j	ffffffffc0200198 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200b88:	00005517          	auipc	a0,0x5
ffffffffc0200b8c:	56850513          	addi	a0,a0,1384 # ffffffffc02060f0 <etext+0x796>
ffffffffc0200b90:	e08ff06f          	j	ffffffffc0200198 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200b94:	00005517          	auipc	a0,0x5
ffffffffc0200b98:	57c50513          	addi	a0,a0,1404 # ffffffffc0206110 <etext+0x7b6>
ffffffffc0200b9c:	dfcff06f          	j	ffffffffc0200198 <cprintf>
{
ffffffffc0200ba0:	1141                	addi	sp,sp,-16
ffffffffc0200ba2:	e406                	sd	ra,8(sp)
        /*(1)设置下次时钟中断- clock_set_next_event()
         *(2)计数器（ticks）加一
         *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
         * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
         */
        clock_set_next_event();
ffffffffc0200ba4:	985ff0ef          	jal	ffffffffc0200528 <clock_set_next_event>
        ticks++;
ffffffffc0200ba8:	000b5797          	auipc	a5,0xb5
ffffffffc0200bac:	aa078793          	addi	a5,a5,-1376 # ffffffffc02b5648 <ticks>
ffffffffc0200bb0:	6394                	ld	a3,0(a5)
        if (ticks % TICK_NUM == 0) {
ffffffffc0200bb2:	28f5c737          	lui	a4,0x28f5c
ffffffffc0200bb6:	28f70713          	addi	a4,a4,655 # 28f5c28f <_binary_obj___user_matrix_out_size+0x28f50d4f>
        ticks++;
ffffffffc0200bba:	0685                	addi	a3,a3,1
ffffffffc0200bbc:	e394                	sd	a3,0(a5)
        if (ticks % TICK_NUM == 0) {
ffffffffc0200bbe:	6390                	ld	a2,0(a5)
ffffffffc0200bc0:	5c28f6b7          	lui	a3,0x5c28f
ffffffffc0200bc4:	1702                	slli	a4,a4,0x20
ffffffffc0200bc6:	5c368693          	addi	a3,a3,1475 # 5c28f5c3 <_binary_obj___user_matrix_out_size+0x5c284083>
ffffffffc0200bca:	00265793          	srli	a5,a2,0x2
ffffffffc0200bce:	9736                	add	a4,a4,a3
ffffffffc0200bd0:	02e7b7b3          	mulhu	a5,a5,a4
ffffffffc0200bd4:	06400593          	li	a1,100
ffffffffc0200bd8:	8389                	srli	a5,a5,0x2
ffffffffc0200bda:	02b787b3          	mul	a5,a5,a1
ffffffffc0200bde:	02f60163          	beq	a2,a5,ffffffffc0200c00 <interrupt_handler+0xb0>
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200be2:	60a2                	ld	ra,8(sp)
        sched_class_proc_tick(current);
ffffffffc0200be4:	000b5517          	auipc	a0,0xb5
ffffffffc0200be8:	abc53503          	ld	a0,-1348(a0) # ffffffffc02b56a0 <current>
}
ffffffffc0200bec:	0141                	addi	sp,sp,16
        sched_class_proc_tick(current);
ffffffffc0200bee:	5860406f          	j	ffffffffc0205174 <sched_class_proc_tick>
        cprintf("Supervisor external interrupt\n");
ffffffffc0200bf2:	00005517          	auipc	a0,0x5
ffffffffc0200bf6:	58e50513          	addi	a0,a0,1422 # ffffffffc0206180 <etext+0x826>
ffffffffc0200bfa:	d9eff06f          	j	ffffffffc0200198 <cprintf>
        print_trapframe(tf);
ffffffffc0200bfe:	bdc5                	j	ffffffffc0200aee <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200c00:	00005517          	auipc	a0,0x5
ffffffffc0200c04:	57050513          	addi	a0,a0,1392 # ffffffffc0206170 <etext+0x816>
ffffffffc0200c08:	d90ff0ef          	jal	ffffffffc0200198 <cprintf>
}
ffffffffc0200c0c:	bfd9                	j	ffffffffc0200be2 <interrupt_handler+0x92>

ffffffffc0200c0e <exception_handler>:
void kernel_execve_ret(struct trapframe *tf, uintptr_t kstacktop);
void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200c0e:	11853783          	ld	a5,280(a0)
ffffffffc0200c12:	473d                	li	a4,15
ffffffffc0200c14:	14f76d63          	bltu	a4,a5,ffffffffc0200d6e <exception_handler+0x160>
ffffffffc0200c18:	00007717          	auipc	a4,0x7
ffffffffc0200c1c:	c0870713          	addi	a4,a4,-1016 # ffffffffc0207820 <commands+0x78>
ffffffffc0200c20:	078a                	slli	a5,a5,0x2
ffffffffc0200c22:	97ba                	add	a5,a5,a4
ffffffffc0200c24:	439c                	lw	a5,0(a5)
{
ffffffffc0200c26:	1101                	addi	sp,sp,-32
ffffffffc0200c28:	ec06                	sd	ra,24(sp)
    switch (tf->cause)
ffffffffc0200c2a:	97ba                	add	a5,a5,a4
ffffffffc0200c2c:	86aa                	mv	a3,a0
ffffffffc0200c2e:	8782                	jr	a5
ffffffffc0200c30:	e42a                	sd	a0,8(sp)
        // cprintf("Environment call from U-mode\n");
        tf->epc += 4;
        syscall();
        break;
    case CAUSE_SUPERVISOR_ECALL:
        cprintf("Environment call from S-mode\n");
ffffffffc0200c32:	00005517          	auipc	a0,0x5
ffffffffc0200c36:	65650513          	addi	a0,a0,1622 # ffffffffc0206288 <etext+0x92e>
ffffffffc0200c3a:	d5eff0ef          	jal	ffffffffc0200198 <cprintf>
        tf->epc += 4;
ffffffffc0200c3e:	66a2                	ld	a3,8(sp)
ffffffffc0200c40:	1086b783          	ld	a5,264(a3)
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200c44:	60e2                	ld	ra,24(sp)
        tf->epc += 4;
ffffffffc0200c46:	0791                	addi	a5,a5,4
ffffffffc0200c48:	10f6b423          	sd	a5,264(a3)
}
ffffffffc0200c4c:	6105                	addi	sp,sp,32
        syscall();
ffffffffc0200c4e:	7ce0406f          	j	ffffffffc020541c <syscall>
}
ffffffffc0200c52:	60e2                	ld	ra,24(sp)
        cprintf("Environment call from H-mode\n");
ffffffffc0200c54:	00005517          	auipc	a0,0x5
ffffffffc0200c58:	65450513          	addi	a0,a0,1620 # ffffffffc02062a8 <etext+0x94e>
}
ffffffffc0200c5c:	6105                	addi	sp,sp,32
        cprintf("Environment call from H-mode\n");
ffffffffc0200c5e:	d3aff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200c62:	60e2                	ld	ra,24(sp)
        cprintf("Environment call from M-mode\n");
ffffffffc0200c64:	00005517          	auipc	a0,0x5
ffffffffc0200c68:	66450513          	addi	a0,a0,1636 # ffffffffc02062c8 <etext+0x96e>
}
ffffffffc0200c6c:	6105                	addi	sp,sp,32
        cprintf("Environment call from M-mode\n");
ffffffffc0200c6e:	d2aff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200c72:	60e2                	ld	ra,24(sp)
        cprintf("Load page fault\n");
ffffffffc0200c74:	00005517          	auipc	a0,0x5
ffffffffc0200c78:	6dc50513          	addi	a0,a0,1756 # ffffffffc0206350 <etext+0x9f6>
}
ffffffffc0200c7c:	6105                	addi	sp,sp,32
        cprintf("Load page fault\n");
ffffffffc0200c7e:	d1aff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200c82:	60e2                	ld	ra,24(sp)
        cprintf("Store/AMO page fault\n");
ffffffffc0200c84:	00005517          	auipc	a0,0x5
ffffffffc0200c88:	6e450513          	addi	a0,a0,1764 # ffffffffc0206368 <etext+0xa0e>
}
ffffffffc0200c8c:	6105                	addi	sp,sp,32
        cprintf("Store/AMO page fault\n");
ffffffffc0200c8e:	d0aff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200c92:	60e2                	ld	ra,24(sp)
        cprintf("Instruction address misaligned\n");
ffffffffc0200c94:	00005517          	auipc	a0,0x5
ffffffffc0200c98:	50c50513          	addi	a0,a0,1292 # ffffffffc02061a0 <etext+0x846>
}
ffffffffc0200c9c:	6105                	addi	sp,sp,32
        cprintf("Instruction address misaligned\n");
ffffffffc0200c9e:	cfaff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200ca2:	60e2                	ld	ra,24(sp)
        cprintf("Instruction access fault\n");
ffffffffc0200ca4:	00005517          	auipc	a0,0x5
ffffffffc0200ca8:	51c50513          	addi	a0,a0,1308 # ffffffffc02061c0 <etext+0x866>
}
ffffffffc0200cac:	6105                	addi	sp,sp,32
        cprintf("Instruction access fault\n");
ffffffffc0200cae:	ceaff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200cb2:	60e2                	ld	ra,24(sp)
        cprintf("Illegal instruction\n");
ffffffffc0200cb4:	00005517          	auipc	a0,0x5
ffffffffc0200cb8:	52c50513          	addi	a0,a0,1324 # ffffffffc02061e0 <etext+0x886>
}
ffffffffc0200cbc:	6105                	addi	sp,sp,32
        cprintf("Illegal instruction\n");
ffffffffc0200cbe:	cdaff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200cc2:	60e2                	ld	ra,24(sp)
        cprintf("Breakpoint\n");
ffffffffc0200cc4:	00005517          	auipc	a0,0x5
ffffffffc0200cc8:	53450513          	addi	a0,a0,1332 # ffffffffc02061f8 <etext+0x89e>
}
ffffffffc0200ccc:	6105                	addi	sp,sp,32
        cprintf("Breakpoint\n");
ffffffffc0200cce:	ccaff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200cd2:	60e2                	ld	ra,24(sp)
        cprintf("Load address misaligned\n");
ffffffffc0200cd4:	00005517          	auipc	a0,0x5
ffffffffc0200cd8:	53450513          	addi	a0,a0,1332 # ffffffffc0206208 <etext+0x8ae>
}
ffffffffc0200cdc:	6105                	addi	sp,sp,32
        cprintf("Load address misaligned\n");
ffffffffc0200cde:	cbaff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200ce2:	60e2                	ld	ra,24(sp)
        cprintf("Load access fault\n");
ffffffffc0200ce4:	00005517          	auipc	a0,0x5
ffffffffc0200ce8:	54450513          	addi	a0,a0,1348 # ffffffffc0206228 <etext+0x8ce>
}
ffffffffc0200cec:	6105                	addi	sp,sp,32
        cprintf("Load access fault\n");
ffffffffc0200cee:	caaff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200cf2:	60e2                	ld	ra,24(sp)
        cprintf("Store/AMO access fault\n");
ffffffffc0200cf4:	00005517          	auipc	a0,0x5
ffffffffc0200cf8:	57c50513          	addi	a0,a0,1404 # ffffffffc0206270 <etext+0x916>
}
ffffffffc0200cfc:	6105                	addi	sp,sp,32
        cprintf("Store/AMO access fault\n");
ffffffffc0200cfe:	c9aff06f          	j	ffffffffc0200198 <cprintf>
}
ffffffffc0200d02:	60e2                	ld	ra,24(sp)
ffffffffc0200d04:	6105                	addi	sp,sp,32
        print_trapframe(tf);
ffffffffc0200d06:	b3e5                	j	ffffffffc0200aee <print_trapframe>
        cprintf("Instruction page fault\n");
ffffffffc0200d08:	e42a                	sd	a0,8(sp)
ffffffffc0200d0a:	00005517          	auipc	a0,0x5
ffffffffc0200d0e:	5de50513          	addi	a0,a0,1502 # ffffffffc02062e8 <etext+0x98e>
ffffffffc0200d12:	c86ff0ef          	jal	ffffffffc0200198 <cprintf>
        print_trapframe(tf);
ffffffffc0200d16:	6522                	ld	a0,8(sp)
ffffffffc0200d18:	dd7ff0ef          	jal	ffffffffc0200aee <print_trapframe>
        if (current != NULL) {
ffffffffc0200d1c:	000b5617          	auipc	a2,0xb5
ffffffffc0200d20:	98463603          	ld	a2,-1660(a2) # ffffffffc02b56a0 <current>
ffffffffc0200d24:	ce09                	beqz	a2,ffffffffc0200d3e <exception_handler+0x130>
            cprintf("Current process: pid=%d, name=\"%s\"\n", current->pid, current->name);
ffffffffc0200d26:	424c                	lw	a1,4(a2)
ffffffffc0200d28:	00005517          	auipc	a0,0x5
ffffffffc0200d2c:	5d850513          	addi	a0,a0,1496 # ffffffffc0206300 <etext+0x9a6>
ffffffffc0200d30:	0b460613          	addi	a2,a2,180
ffffffffc0200d34:	c64ff0ef          	jal	ffffffffc0200198 <cprintf>
            do_exit(-E_KILLED);
ffffffffc0200d38:	555d                	li	a0,-9
ffffffffc0200d3a:	5ca030ef          	jal	ffffffffc0204304 <do_exit>
        panic("Instruction page fault in kernel!");
ffffffffc0200d3e:	00005617          	auipc	a2,0x5
ffffffffc0200d42:	5ea60613          	addi	a2,a2,1514 # ffffffffc0206328 <etext+0x9ce>
ffffffffc0200d46:	0da00593          	li	a1,218
ffffffffc0200d4a:	00005517          	auipc	a0,0x5
ffffffffc0200d4e:	50e50513          	addi	a0,a0,1294 # ffffffffc0206258 <etext+0x8fe>
ffffffffc0200d52:	ef8ff0ef          	jal	ffffffffc020044a <__panic>
        panic("AMO address misaligned\n");
ffffffffc0200d56:	00005617          	auipc	a2,0x5
ffffffffc0200d5a:	4ea60613          	addi	a2,a2,1258 # ffffffffc0206240 <etext+0x8e6>
ffffffffc0200d5e:	0be00593          	li	a1,190
ffffffffc0200d62:	00005517          	auipc	a0,0x5
ffffffffc0200d66:	4f650513          	addi	a0,a0,1270 # ffffffffc0206258 <etext+0x8fe>
ffffffffc0200d6a:	ee0ff0ef          	jal	ffffffffc020044a <__panic>
        print_trapframe(tf);
ffffffffc0200d6e:	b341                	j	ffffffffc0200aee <print_trapframe>

ffffffffc0200d70 <trap>:
 * */
void trap(struct trapframe *tf)
{
    // dispatch based on what type of trap occurred
    //    cputs("some trap");
    if (current == NULL)
ffffffffc0200d70:	000b5717          	auipc	a4,0xb5
ffffffffc0200d74:	93073703          	ld	a4,-1744(a4) # ffffffffc02b56a0 <current>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200d78:	11853583          	ld	a1,280(a0)
    if (current == NULL)
ffffffffc0200d7c:	cf21                	beqz	a4,ffffffffc0200dd4 <trap+0x64>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200d7e:	10053603          	ld	a2,256(a0)
    {
        trap_dispatch(tf);
    }
    else
    {
        struct trapframe *otf = current->tf;
ffffffffc0200d82:	0a073803          	ld	a6,160(a4)
{
ffffffffc0200d86:	1101                	addi	sp,sp,-32
ffffffffc0200d88:	ec06                	sd	ra,24(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200d8a:	10067613          	andi	a2,a2,256
        current->tf = tf;
ffffffffc0200d8e:	f348                	sd	a0,160(a4)
    if ((intptr_t)tf->cause < 0)
ffffffffc0200d90:	e432                	sd	a2,8(sp)
ffffffffc0200d92:	e042                	sd	a6,0(sp)
ffffffffc0200d94:	0205c763          	bltz	a1,ffffffffc0200dc2 <trap+0x52>
        exception_handler(tf);
ffffffffc0200d98:	e77ff0ef          	jal	ffffffffc0200c0e <exception_handler>
ffffffffc0200d9c:	6622                	ld	a2,8(sp)
ffffffffc0200d9e:	6802                	ld	a6,0(sp)
ffffffffc0200da0:	000b5697          	auipc	a3,0xb5
ffffffffc0200da4:	90068693          	addi	a3,a3,-1792 # ffffffffc02b56a0 <current>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200da8:	6298                	ld	a4,0(a3)
ffffffffc0200daa:	0b073023          	sd	a6,160(a4)
        if (!in_kernel)
ffffffffc0200dae:	e619                	bnez	a2,ffffffffc0200dbc <trap+0x4c>
        {
            if (current->flags & PF_EXITING)
ffffffffc0200db0:	0b072783          	lw	a5,176(a4)
ffffffffc0200db4:	8b85                	andi	a5,a5,1
ffffffffc0200db6:	e79d                	bnez	a5,ffffffffc0200de4 <trap+0x74>
            {
                do_exit(-E_KILLED);
            }
            if (current->need_resched)
ffffffffc0200db8:	6f1c                	ld	a5,24(a4)
ffffffffc0200dba:	e38d                	bnez	a5,ffffffffc0200ddc <trap+0x6c>
            {
                schedule();
            }
        }
    }
}
ffffffffc0200dbc:	60e2                	ld	ra,24(sp)
ffffffffc0200dbe:	6105                	addi	sp,sp,32
ffffffffc0200dc0:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200dc2:	d8fff0ef          	jal	ffffffffc0200b50 <interrupt_handler>
ffffffffc0200dc6:	6802                	ld	a6,0(sp)
ffffffffc0200dc8:	6622                	ld	a2,8(sp)
ffffffffc0200dca:	000b5697          	auipc	a3,0xb5
ffffffffc0200dce:	8d668693          	addi	a3,a3,-1834 # ffffffffc02b56a0 <current>
ffffffffc0200dd2:	bfd9                	j	ffffffffc0200da8 <trap+0x38>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200dd4:	0005c363          	bltz	a1,ffffffffc0200dda <trap+0x6a>
        exception_handler(tf);
ffffffffc0200dd8:	bd1d                	j	ffffffffc0200c0e <exception_handler>
        interrupt_handler(tf);
ffffffffc0200dda:	bb9d                	j	ffffffffc0200b50 <interrupt_handler>
}
ffffffffc0200ddc:	60e2                	ld	ra,24(sp)
ffffffffc0200dde:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200de0:	5080406f          	j	ffffffffc02052e8 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200de4:	555d                	li	a0,-9
ffffffffc0200de6:	51e030ef          	jal	ffffffffc0204304 <do_exit>
            if (current->need_resched)
ffffffffc0200dea:	000b5717          	auipc	a4,0xb5
ffffffffc0200dee:	8b673703          	ld	a4,-1866(a4) # ffffffffc02b56a0 <current>
ffffffffc0200df2:	b7d9                	j	ffffffffc0200db8 <trap+0x48>

ffffffffc0200df4 <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200df4:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200df8:	00011463          	bnez	sp,ffffffffc0200e00 <__alltraps+0xc>
ffffffffc0200dfc:	14002173          	csrr	sp,sscratch
ffffffffc0200e00:	712d                	addi	sp,sp,-288
ffffffffc0200e02:	e002                	sd	zero,0(sp)
ffffffffc0200e04:	e406                	sd	ra,8(sp)
ffffffffc0200e06:	ec0e                	sd	gp,24(sp)
ffffffffc0200e08:	f012                	sd	tp,32(sp)
ffffffffc0200e0a:	f416                	sd	t0,40(sp)
ffffffffc0200e0c:	f81a                	sd	t1,48(sp)
ffffffffc0200e0e:	fc1e                	sd	t2,56(sp)
ffffffffc0200e10:	e0a2                	sd	s0,64(sp)
ffffffffc0200e12:	e4a6                	sd	s1,72(sp)
ffffffffc0200e14:	e8aa                	sd	a0,80(sp)
ffffffffc0200e16:	ecae                	sd	a1,88(sp)
ffffffffc0200e18:	f0b2                	sd	a2,96(sp)
ffffffffc0200e1a:	f4b6                	sd	a3,104(sp)
ffffffffc0200e1c:	f8ba                	sd	a4,112(sp)
ffffffffc0200e1e:	fcbe                	sd	a5,120(sp)
ffffffffc0200e20:	e142                	sd	a6,128(sp)
ffffffffc0200e22:	e546                	sd	a7,136(sp)
ffffffffc0200e24:	e94a                	sd	s2,144(sp)
ffffffffc0200e26:	ed4e                	sd	s3,152(sp)
ffffffffc0200e28:	f152                	sd	s4,160(sp)
ffffffffc0200e2a:	f556                	sd	s5,168(sp)
ffffffffc0200e2c:	f95a                	sd	s6,176(sp)
ffffffffc0200e2e:	fd5e                	sd	s7,184(sp)
ffffffffc0200e30:	e1e2                	sd	s8,192(sp)
ffffffffc0200e32:	e5e6                	sd	s9,200(sp)
ffffffffc0200e34:	e9ea                	sd	s10,208(sp)
ffffffffc0200e36:	edee                	sd	s11,216(sp)
ffffffffc0200e38:	f1f2                	sd	t3,224(sp)
ffffffffc0200e3a:	f5f6                	sd	t4,232(sp)
ffffffffc0200e3c:	f9fa                	sd	t5,240(sp)
ffffffffc0200e3e:	fdfe                	sd	t6,248(sp)
ffffffffc0200e40:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200e44:	100024f3          	csrr	s1,sstatus
ffffffffc0200e48:	14102973          	csrr	s2,sepc
ffffffffc0200e4c:	143029f3          	csrr	s3,stval
ffffffffc0200e50:	14202a73          	csrr	s4,scause
ffffffffc0200e54:	e822                	sd	s0,16(sp)
ffffffffc0200e56:	e226                	sd	s1,256(sp)
ffffffffc0200e58:	e64a                	sd	s2,264(sp)
ffffffffc0200e5a:	ea4e                	sd	s3,272(sp)
ffffffffc0200e5c:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200e5e:	850a                	mv	a0,sp
    jal trap
ffffffffc0200e60:	f11ff0ef          	jal	ffffffffc0200d70 <trap>

ffffffffc0200e64 <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200e64:	6492                	ld	s1,256(sp)
ffffffffc0200e66:	6932                	ld	s2,264(sp)
ffffffffc0200e68:	1004f413          	andi	s0,s1,256
ffffffffc0200e6c:	e401                	bnez	s0,ffffffffc0200e74 <__trapret+0x10>
ffffffffc0200e6e:	1200                	addi	s0,sp,288
ffffffffc0200e70:	14041073          	csrw	sscratch,s0
ffffffffc0200e74:	10049073          	csrw	sstatus,s1
ffffffffc0200e78:	14191073          	csrw	sepc,s2
ffffffffc0200e7c:	60a2                	ld	ra,8(sp)
ffffffffc0200e7e:	61e2                	ld	gp,24(sp)
ffffffffc0200e80:	7202                	ld	tp,32(sp)
ffffffffc0200e82:	72a2                	ld	t0,40(sp)
ffffffffc0200e84:	7342                	ld	t1,48(sp)
ffffffffc0200e86:	73e2                	ld	t2,56(sp)
ffffffffc0200e88:	6406                	ld	s0,64(sp)
ffffffffc0200e8a:	64a6                	ld	s1,72(sp)
ffffffffc0200e8c:	6546                	ld	a0,80(sp)
ffffffffc0200e8e:	65e6                	ld	a1,88(sp)
ffffffffc0200e90:	7606                	ld	a2,96(sp)
ffffffffc0200e92:	76a6                	ld	a3,104(sp)
ffffffffc0200e94:	7746                	ld	a4,112(sp)
ffffffffc0200e96:	77e6                	ld	a5,120(sp)
ffffffffc0200e98:	680a                	ld	a6,128(sp)
ffffffffc0200e9a:	68aa                	ld	a7,136(sp)
ffffffffc0200e9c:	694a                	ld	s2,144(sp)
ffffffffc0200e9e:	69ea                	ld	s3,152(sp)
ffffffffc0200ea0:	7a0a                	ld	s4,160(sp)
ffffffffc0200ea2:	7aaa                	ld	s5,168(sp)
ffffffffc0200ea4:	7b4a                	ld	s6,176(sp)
ffffffffc0200ea6:	7bea                	ld	s7,184(sp)
ffffffffc0200ea8:	6c0e                	ld	s8,192(sp)
ffffffffc0200eaa:	6cae                	ld	s9,200(sp)
ffffffffc0200eac:	6d4e                	ld	s10,208(sp)
ffffffffc0200eae:	6dee                	ld	s11,216(sp)
ffffffffc0200eb0:	7e0e                	ld	t3,224(sp)
ffffffffc0200eb2:	7eae                	ld	t4,232(sp)
ffffffffc0200eb4:	7f4e                	ld	t5,240(sp)
ffffffffc0200eb6:	7fee                	ld	t6,248(sp)
ffffffffc0200eb8:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200eba:	10200073          	sret

ffffffffc0200ebe <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200ebe:	812a                	mv	sp,a0
ffffffffc0200ec0:	b755                	j	ffffffffc0200e64 <__trapret>

ffffffffc0200ec2 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200ec2:	000b0797          	auipc	a5,0xb0
ffffffffc0200ec6:	72678793          	addi	a5,a5,1830 # ffffffffc02b15e8 <free_area>
ffffffffc0200eca:	e79c                	sd	a5,8(a5)
ffffffffc0200ecc:	e39c                	sd	a5,0(a5)

static void
default_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200ece:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200ed2:	8082                	ret

ffffffffc0200ed4 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc0200ed4:	000b0517          	auipc	a0,0xb0
ffffffffc0200ed8:	72456503          	lwu	a0,1828(a0) # ffffffffc02b15f8 <free_area+0x10>
ffffffffc0200edc:	8082                	ret

ffffffffc0200ede <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
ffffffffc0200ede:	711d                	addi	sp,sp,-96
ffffffffc0200ee0:	e0ca                	sd	s2,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200ee2:	000b0917          	auipc	s2,0xb0
ffffffffc0200ee6:	70690913          	addi	s2,s2,1798 # ffffffffc02b15e8 <free_area>
ffffffffc0200eea:	00893783          	ld	a5,8(s2)
ffffffffc0200eee:	ec86                	sd	ra,88(sp)
ffffffffc0200ef0:	e8a2                	sd	s0,80(sp)
ffffffffc0200ef2:	e4a6                	sd	s1,72(sp)
ffffffffc0200ef4:	fc4e                	sd	s3,56(sp)
ffffffffc0200ef6:	f852                	sd	s4,48(sp)
ffffffffc0200ef8:	f456                	sd	s5,40(sp)
ffffffffc0200efa:	f05a                	sd	s6,32(sp)
ffffffffc0200efc:	ec5e                	sd	s7,24(sp)
ffffffffc0200efe:	e862                	sd	s8,16(sp)
ffffffffc0200f00:	e466                	sd	s9,8(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0200f02:	2f278363          	beq	a5,s2,ffffffffc02011e8 <default_check+0x30a>
    int count = 0, total = 0;
ffffffffc0200f06:	4401                	li	s0,0
ffffffffc0200f08:	4481                	li	s1,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200f0a:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200f0e:	8b09                	andi	a4,a4,2
ffffffffc0200f10:	2e070063          	beqz	a4,ffffffffc02011f0 <default_check+0x312>
        count++, total += p->property;
ffffffffc0200f14:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200f18:	679c                	ld	a5,8(a5)
ffffffffc0200f1a:	2485                	addiw	s1,s1,1
ffffffffc0200f1c:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0200f1e:	ff2796e3          	bne	a5,s2,ffffffffc0200f0a <default_check+0x2c>
    }
    assert(total == nr_free_pages());
ffffffffc0200f22:	89a2                	mv	s3,s0
ffffffffc0200f24:	741000ef          	jal	ffffffffc0201e64 <nr_free_pages>
ffffffffc0200f28:	73351463          	bne	a0,s3,ffffffffc0201650 <default_check+0x772>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200f2c:	4505                	li	a0,1
ffffffffc0200f2e:	6c5000ef          	jal	ffffffffc0201df2 <alloc_pages>
ffffffffc0200f32:	8a2a                	mv	s4,a0
ffffffffc0200f34:	44050e63          	beqz	a0,ffffffffc0201390 <default_check+0x4b2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200f38:	4505                	li	a0,1
ffffffffc0200f3a:	6b9000ef          	jal	ffffffffc0201df2 <alloc_pages>
ffffffffc0200f3e:	89aa                	mv	s3,a0
ffffffffc0200f40:	72050863          	beqz	a0,ffffffffc0201670 <default_check+0x792>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200f44:	4505                	li	a0,1
ffffffffc0200f46:	6ad000ef          	jal	ffffffffc0201df2 <alloc_pages>
ffffffffc0200f4a:	8aaa                	mv	s5,a0
ffffffffc0200f4c:	4c050263          	beqz	a0,ffffffffc0201410 <default_check+0x532>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200f50:	40a987b3          	sub	a5,s3,a0
ffffffffc0200f54:	40aa0733          	sub	a4,s4,a0
ffffffffc0200f58:	0017b793          	seqz	a5,a5
ffffffffc0200f5c:	00173713          	seqz	a4,a4
ffffffffc0200f60:	8fd9                	or	a5,a5,a4
ffffffffc0200f62:	30079763          	bnez	a5,ffffffffc0201270 <default_check+0x392>
ffffffffc0200f66:	313a0563          	beq	s4,s3,ffffffffc0201270 <default_check+0x392>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200f6a:	000a2783          	lw	a5,0(s4)
ffffffffc0200f6e:	2a079163          	bnez	a5,ffffffffc0201210 <default_check+0x332>
ffffffffc0200f72:	0009a783          	lw	a5,0(s3)
ffffffffc0200f76:	28079d63          	bnez	a5,ffffffffc0201210 <default_check+0x332>
ffffffffc0200f7a:	411c                	lw	a5,0(a0)
ffffffffc0200f7c:	28079a63          	bnez	a5,ffffffffc0201210 <default_check+0x332>
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page)
{
    return page - pages + nbase;
ffffffffc0200f80:	000b4797          	auipc	a5,0xb4
ffffffffc0200f84:	7107b783          	ld	a5,1808(a5) # ffffffffc02b5690 <pages>
ffffffffc0200f88:	00007617          	auipc	a2,0x7
ffffffffc0200f8c:	33063603          	ld	a2,816(a2) # ffffffffc02082b8 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200f90:	000b4697          	auipc	a3,0xb4
ffffffffc0200f94:	6f86b683          	ld	a3,1784(a3) # ffffffffc02b5688 <npage>
ffffffffc0200f98:	40fa0733          	sub	a4,s4,a5
ffffffffc0200f9c:	8719                	srai	a4,a4,0x6
ffffffffc0200f9e:	9732                	add	a4,a4,a2
}

static inline uintptr_t
page2pa(struct Page *page)
{
    return page2ppn(page) << PGSHIFT;
ffffffffc0200fa0:	0732                	slli	a4,a4,0xc
ffffffffc0200fa2:	06b2                	slli	a3,a3,0xc
ffffffffc0200fa4:	2ad77663          	bgeu	a4,a3,ffffffffc0201250 <default_check+0x372>
    return page - pages + nbase;
ffffffffc0200fa8:	40f98733          	sub	a4,s3,a5
ffffffffc0200fac:	8719                	srai	a4,a4,0x6
ffffffffc0200fae:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200fb0:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200fb2:	4cd77f63          	bgeu	a4,a3,ffffffffc0201490 <default_check+0x5b2>
    return page - pages + nbase;
ffffffffc0200fb6:	40f507b3          	sub	a5,a0,a5
ffffffffc0200fba:	8799                	srai	a5,a5,0x6
ffffffffc0200fbc:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0200fbe:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200fc0:	32d7f863          	bgeu	a5,a3,ffffffffc02012f0 <default_check+0x412>
    assert(alloc_page() == NULL);
ffffffffc0200fc4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200fc6:	00093c03          	ld	s8,0(s2)
ffffffffc0200fca:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200fce:	000b0b17          	auipc	s6,0xb0
ffffffffc0200fd2:	62ab2b03          	lw	s6,1578(s6) # ffffffffc02b15f8 <free_area+0x10>
    elm->prev = elm->next = elm;
ffffffffc0200fd6:	01293023          	sd	s2,0(s2)
ffffffffc0200fda:	01293423          	sd	s2,8(s2)
    nr_free = 0;
ffffffffc0200fde:	000b0797          	auipc	a5,0xb0
ffffffffc0200fe2:	6007ad23          	sw	zero,1562(a5) # ffffffffc02b15f8 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200fe6:	60d000ef          	jal	ffffffffc0201df2 <alloc_pages>
ffffffffc0200fea:	2e051363          	bnez	a0,ffffffffc02012d0 <default_check+0x3f2>
    free_page(p0);
ffffffffc0200fee:	8552                	mv	a0,s4
ffffffffc0200ff0:	4585                	li	a1,1
ffffffffc0200ff2:	63b000ef          	jal	ffffffffc0201e2c <free_pages>
    free_page(p1);
ffffffffc0200ff6:	854e                	mv	a0,s3
ffffffffc0200ff8:	4585                	li	a1,1
ffffffffc0200ffa:	633000ef          	jal	ffffffffc0201e2c <free_pages>
    free_page(p2);
ffffffffc0200ffe:	8556                	mv	a0,s5
ffffffffc0201000:	4585                	li	a1,1
ffffffffc0201002:	62b000ef          	jal	ffffffffc0201e2c <free_pages>
    assert(nr_free == 3);
ffffffffc0201006:	000b0717          	auipc	a4,0xb0
ffffffffc020100a:	5f272703          	lw	a4,1522(a4) # ffffffffc02b15f8 <free_area+0x10>
ffffffffc020100e:	478d                	li	a5,3
ffffffffc0201010:	2af71063          	bne	a4,a5,ffffffffc02012b0 <default_check+0x3d2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201014:	4505                	li	a0,1
ffffffffc0201016:	5dd000ef          	jal	ffffffffc0201df2 <alloc_pages>
ffffffffc020101a:	89aa                	mv	s3,a0
ffffffffc020101c:	26050a63          	beqz	a0,ffffffffc0201290 <default_check+0x3b2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201020:	4505                	li	a0,1
ffffffffc0201022:	5d1000ef          	jal	ffffffffc0201df2 <alloc_pages>
ffffffffc0201026:	8aaa                	mv	s5,a0
ffffffffc0201028:	3c050463          	beqz	a0,ffffffffc02013f0 <default_check+0x512>
    assert((p2 = alloc_page()) != NULL);
ffffffffc020102c:	4505                	li	a0,1
ffffffffc020102e:	5c5000ef          	jal	ffffffffc0201df2 <alloc_pages>
ffffffffc0201032:	8a2a                	mv	s4,a0
ffffffffc0201034:	38050e63          	beqz	a0,ffffffffc02013d0 <default_check+0x4f2>
    assert(alloc_page() == NULL);
ffffffffc0201038:	4505                	li	a0,1
ffffffffc020103a:	5b9000ef          	jal	ffffffffc0201df2 <alloc_pages>
ffffffffc020103e:	36051963          	bnez	a0,ffffffffc02013b0 <default_check+0x4d2>
    free_page(p0);
ffffffffc0201042:	4585                	li	a1,1
ffffffffc0201044:	854e                	mv	a0,s3
ffffffffc0201046:	5e7000ef          	jal	ffffffffc0201e2c <free_pages>
    assert(!list_empty(&free_list));
ffffffffc020104a:	00893783          	ld	a5,8(s2)
ffffffffc020104e:	1f278163          	beq	a5,s2,ffffffffc0201230 <default_check+0x352>
    assert((p = alloc_page()) == p0);
ffffffffc0201052:	4505                	li	a0,1
ffffffffc0201054:	59f000ef          	jal	ffffffffc0201df2 <alloc_pages>
ffffffffc0201058:	8caa                	mv	s9,a0
ffffffffc020105a:	30a99b63          	bne	s3,a0,ffffffffc0201370 <default_check+0x492>
    assert(alloc_page() == NULL);
ffffffffc020105e:	4505                	li	a0,1
ffffffffc0201060:	593000ef          	jal	ffffffffc0201df2 <alloc_pages>
ffffffffc0201064:	2e051663          	bnez	a0,ffffffffc0201350 <default_check+0x472>
    assert(nr_free == 0);
ffffffffc0201068:	000b0797          	auipc	a5,0xb0
ffffffffc020106c:	5907a783          	lw	a5,1424(a5) # ffffffffc02b15f8 <free_area+0x10>
ffffffffc0201070:	2c079063          	bnez	a5,ffffffffc0201330 <default_check+0x452>
    free_page(p);
ffffffffc0201074:	8566                	mv	a0,s9
ffffffffc0201076:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0201078:	01893023          	sd	s8,0(s2)
ffffffffc020107c:	01793423          	sd	s7,8(s2)
    nr_free = nr_free_store;
ffffffffc0201080:	01692823          	sw	s6,16(s2)
    free_page(p);
ffffffffc0201084:	5a9000ef          	jal	ffffffffc0201e2c <free_pages>
    free_page(p1);
ffffffffc0201088:	8556                	mv	a0,s5
ffffffffc020108a:	4585                	li	a1,1
ffffffffc020108c:	5a1000ef          	jal	ffffffffc0201e2c <free_pages>
    free_page(p2);
ffffffffc0201090:	8552                	mv	a0,s4
ffffffffc0201092:	4585                	li	a1,1
ffffffffc0201094:	599000ef          	jal	ffffffffc0201e2c <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201098:	4515                	li	a0,5
ffffffffc020109a:	559000ef          	jal	ffffffffc0201df2 <alloc_pages>
ffffffffc020109e:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc02010a0:	26050863          	beqz	a0,ffffffffc0201310 <default_check+0x432>
ffffffffc02010a4:	651c                	ld	a5,8(a0)
    assert(!PageProperty(p0));
ffffffffc02010a6:	8b89                	andi	a5,a5,2
ffffffffc02010a8:	54079463          	bnez	a5,ffffffffc02015f0 <default_check+0x712>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc02010ac:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc02010ae:	00093b83          	ld	s7,0(s2)
ffffffffc02010b2:	00893b03          	ld	s6,8(s2)
ffffffffc02010b6:	01293023          	sd	s2,0(s2)
ffffffffc02010ba:	01293423          	sd	s2,8(s2)
    assert(alloc_page() == NULL);
ffffffffc02010be:	535000ef          	jal	ffffffffc0201df2 <alloc_pages>
ffffffffc02010c2:	50051763          	bnez	a0,ffffffffc02015d0 <default_check+0x6f2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc02010c6:	08098a13          	addi	s4,s3,128
ffffffffc02010ca:	8552                	mv	a0,s4
ffffffffc02010cc:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc02010ce:	000b0c17          	auipc	s8,0xb0
ffffffffc02010d2:	52ac2c03          	lw	s8,1322(s8) # ffffffffc02b15f8 <free_area+0x10>
    nr_free = 0;
ffffffffc02010d6:	000b0797          	auipc	a5,0xb0
ffffffffc02010da:	5207a123          	sw	zero,1314(a5) # ffffffffc02b15f8 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc02010de:	54f000ef          	jal	ffffffffc0201e2c <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc02010e2:	4511                	li	a0,4
ffffffffc02010e4:	50f000ef          	jal	ffffffffc0201df2 <alloc_pages>
ffffffffc02010e8:	4c051463          	bnez	a0,ffffffffc02015b0 <default_check+0x6d2>
ffffffffc02010ec:	0889b783          	ld	a5,136(s3)
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02010f0:	8b89                	andi	a5,a5,2
ffffffffc02010f2:	48078f63          	beqz	a5,ffffffffc0201590 <default_check+0x6b2>
ffffffffc02010f6:	0909a503          	lw	a0,144(s3)
ffffffffc02010fa:	478d                	li	a5,3
ffffffffc02010fc:	48f51a63          	bne	a0,a5,ffffffffc0201590 <default_check+0x6b2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201100:	4f3000ef          	jal	ffffffffc0201df2 <alloc_pages>
ffffffffc0201104:	8aaa                	mv	s5,a0
ffffffffc0201106:	46050563          	beqz	a0,ffffffffc0201570 <default_check+0x692>
    assert(alloc_page() == NULL);
ffffffffc020110a:	4505                	li	a0,1
ffffffffc020110c:	4e7000ef          	jal	ffffffffc0201df2 <alloc_pages>
ffffffffc0201110:	44051063          	bnez	a0,ffffffffc0201550 <default_check+0x672>
    assert(p0 + 2 == p1);
ffffffffc0201114:	415a1e63          	bne	s4,s5,ffffffffc0201530 <default_check+0x652>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201118:	4585                	li	a1,1
ffffffffc020111a:	854e                	mv	a0,s3
ffffffffc020111c:	511000ef          	jal	ffffffffc0201e2c <free_pages>
    free_pages(p1, 3);
ffffffffc0201120:	8552                	mv	a0,s4
ffffffffc0201122:	458d                	li	a1,3
ffffffffc0201124:	509000ef          	jal	ffffffffc0201e2c <free_pages>
ffffffffc0201128:	0089b783          	ld	a5,8(s3)
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc020112c:	8b89                	andi	a5,a5,2
ffffffffc020112e:	3e078163          	beqz	a5,ffffffffc0201510 <default_check+0x632>
ffffffffc0201132:	0109aa83          	lw	s5,16(s3)
ffffffffc0201136:	4785                	li	a5,1
ffffffffc0201138:	3cfa9c63          	bne	s5,a5,ffffffffc0201510 <default_check+0x632>
ffffffffc020113c:	008a3783          	ld	a5,8(s4)
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201140:	8b89                	andi	a5,a5,2
ffffffffc0201142:	3a078763          	beqz	a5,ffffffffc02014f0 <default_check+0x612>
ffffffffc0201146:	010a2703          	lw	a4,16(s4)
ffffffffc020114a:	478d                	li	a5,3
ffffffffc020114c:	3af71263          	bne	a4,a5,ffffffffc02014f0 <default_check+0x612>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201150:	8556                	mv	a0,s5
ffffffffc0201152:	4a1000ef          	jal	ffffffffc0201df2 <alloc_pages>
ffffffffc0201156:	36a99d63          	bne	s3,a0,ffffffffc02014d0 <default_check+0x5f2>
    free_page(p0);
ffffffffc020115a:	85d6                	mv	a1,s5
ffffffffc020115c:	4d1000ef          	jal	ffffffffc0201e2c <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201160:	4509                	li	a0,2
ffffffffc0201162:	491000ef          	jal	ffffffffc0201df2 <alloc_pages>
ffffffffc0201166:	34aa1563          	bne	s4,a0,ffffffffc02014b0 <default_check+0x5d2>

    free_pages(p0, 2);
ffffffffc020116a:	4589                	li	a1,2
ffffffffc020116c:	4c1000ef          	jal	ffffffffc0201e2c <free_pages>
    free_page(p2);
ffffffffc0201170:	04098513          	addi	a0,s3,64
ffffffffc0201174:	85d6                	mv	a1,s5
ffffffffc0201176:	4b7000ef          	jal	ffffffffc0201e2c <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc020117a:	4515                	li	a0,5
ffffffffc020117c:	477000ef          	jal	ffffffffc0201df2 <alloc_pages>
ffffffffc0201180:	89aa                	mv	s3,a0
ffffffffc0201182:	48050763          	beqz	a0,ffffffffc0201610 <default_check+0x732>
    assert(alloc_page() == NULL);
ffffffffc0201186:	8556                	mv	a0,s5
ffffffffc0201188:	46b000ef          	jal	ffffffffc0201df2 <alloc_pages>
ffffffffc020118c:	2e051263          	bnez	a0,ffffffffc0201470 <default_check+0x592>

    assert(nr_free == 0);
ffffffffc0201190:	000b0797          	auipc	a5,0xb0
ffffffffc0201194:	4687a783          	lw	a5,1128(a5) # ffffffffc02b15f8 <free_area+0x10>
ffffffffc0201198:	2a079c63          	bnez	a5,ffffffffc0201450 <default_check+0x572>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc020119c:	854e                	mv	a0,s3
ffffffffc020119e:	4595                	li	a1,5
    nr_free = nr_free_store;
ffffffffc02011a0:	01892823          	sw	s8,16(s2)
    free_list = free_list_store;
ffffffffc02011a4:	01793023          	sd	s7,0(s2)
ffffffffc02011a8:	01693423          	sd	s6,8(s2)
    free_pages(p0, 5);
ffffffffc02011ac:	481000ef          	jal	ffffffffc0201e2c <free_pages>
    return listelm->next;
ffffffffc02011b0:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc02011b4:	01278963          	beq	a5,s2,ffffffffc02011c6 <default_check+0x2e8>
    {
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc02011b8:	ff87a703          	lw	a4,-8(a5)
ffffffffc02011bc:	679c                	ld	a5,8(a5)
ffffffffc02011be:	34fd                	addiw	s1,s1,-1
ffffffffc02011c0:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc02011c2:	ff279be3          	bne	a5,s2,ffffffffc02011b8 <default_check+0x2da>
    }
    assert(count == 0);
ffffffffc02011c6:	26049563          	bnez	s1,ffffffffc0201430 <default_check+0x552>
    assert(total == 0);
ffffffffc02011ca:	46041363          	bnez	s0,ffffffffc0201630 <default_check+0x752>
}
ffffffffc02011ce:	60e6                	ld	ra,88(sp)
ffffffffc02011d0:	6446                	ld	s0,80(sp)
ffffffffc02011d2:	64a6                	ld	s1,72(sp)
ffffffffc02011d4:	6906                	ld	s2,64(sp)
ffffffffc02011d6:	79e2                	ld	s3,56(sp)
ffffffffc02011d8:	7a42                	ld	s4,48(sp)
ffffffffc02011da:	7aa2                	ld	s5,40(sp)
ffffffffc02011dc:	7b02                	ld	s6,32(sp)
ffffffffc02011de:	6be2                	ld	s7,24(sp)
ffffffffc02011e0:	6c42                	ld	s8,16(sp)
ffffffffc02011e2:	6ca2                	ld	s9,8(sp)
ffffffffc02011e4:	6125                	addi	sp,sp,96
ffffffffc02011e6:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc02011e8:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc02011ea:	4401                	li	s0,0
ffffffffc02011ec:	4481                	li	s1,0
ffffffffc02011ee:	bb1d                	j	ffffffffc0200f24 <default_check+0x46>
        assert(PageProperty(p));
ffffffffc02011f0:	00005697          	auipc	a3,0x5
ffffffffc02011f4:	19068693          	addi	a3,a3,400 # ffffffffc0206380 <etext+0xa26>
ffffffffc02011f8:	00005617          	auipc	a2,0x5
ffffffffc02011fc:	19860613          	addi	a2,a2,408 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201200:	11000593          	li	a1,272
ffffffffc0201204:	00005517          	auipc	a0,0x5
ffffffffc0201208:	1a450513          	addi	a0,a0,420 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020120c:	a3eff0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201210:	00005697          	auipc	a3,0x5
ffffffffc0201214:	25868693          	addi	a3,a3,600 # ffffffffc0206468 <etext+0xb0e>
ffffffffc0201218:	00005617          	auipc	a2,0x5
ffffffffc020121c:	17860613          	addi	a2,a2,376 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201220:	0dc00593          	li	a1,220
ffffffffc0201224:	00005517          	auipc	a0,0x5
ffffffffc0201228:	18450513          	addi	a0,a0,388 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020122c:	a1eff0ef          	jal	ffffffffc020044a <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201230:	00005697          	auipc	a3,0x5
ffffffffc0201234:	30068693          	addi	a3,a3,768 # ffffffffc0206530 <etext+0xbd6>
ffffffffc0201238:	00005617          	auipc	a2,0x5
ffffffffc020123c:	15860613          	addi	a2,a2,344 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201240:	0f700593          	li	a1,247
ffffffffc0201244:	00005517          	auipc	a0,0x5
ffffffffc0201248:	16450513          	addi	a0,a0,356 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020124c:	9feff0ef          	jal	ffffffffc020044a <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201250:	00005697          	auipc	a3,0x5
ffffffffc0201254:	25868693          	addi	a3,a3,600 # ffffffffc02064a8 <etext+0xb4e>
ffffffffc0201258:	00005617          	auipc	a2,0x5
ffffffffc020125c:	13860613          	addi	a2,a2,312 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201260:	0de00593          	li	a1,222
ffffffffc0201264:	00005517          	auipc	a0,0x5
ffffffffc0201268:	14450513          	addi	a0,a0,324 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020126c:	9deff0ef          	jal	ffffffffc020044a <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201270:	00005697          	auipc	a3,0x5
ffffffffc0201274:	1d068693          	addi	a3,a3,464 # ffffffffc0206440 <etext+0xae6>
ffffffffc0201278:	00005617          	auipc	a2,0x5
ffffffffc020127c:	11860613          	addi	a2,a2,280 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201280:	0db00593          	li	a1,219
ffffffffc0201284:	00005517          	auipc	a0,0x5
ffffffffc0201288:	12450513          	addi	a0,a0,292 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020128c:	9beff0ef          	jal	ffffffffc020044a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201290:	00005697          	auipc	a3,0x5
ffffffffc0201294:	15068693          	addi	a3,a3,336 # ffffffffc02063e0 <etext+0xa86>
ffffffffc0201298:	00005617          	auipc	a2,0x5
ffffffffc020129c:	0f860613          	addi	a2,a2,248 # ffffffffc0206390 <etext+0xa36>
ffffffffc02012a0:	0f000593          	li	a1,240
ffffffffc02012a4:	00005517          	auipc	a0,0x5
ffffffffc02012a8:	10450513          	addi	a0,a0,260 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc02012ac:	99eff0ef          	jal	ffffffffc020044a <__panic>
    assert(nr_free == 3);
ffffffffc02012b0:	00005697          	auipc	a3,0x5
ffffffffc02012b4:	27068693          	addi	a3,a3,624 # ffffffffc0206520 <etext+0xbc6>
ffffffffc02012b8:	00005617          	auipc	a2,0x5
ffffffffc02012bc:	0d860613          	addi	a2,a2,216 # ffffffffc0206390 <etext+0xa36>
ffffffffc02012c0:	0ee00593          	li	a1,238
ffffffffc02012c4:	00005517          	auipc	a0,0x5
ffffffffc02012c8:	0e450513          	addi	a0,a0,228 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc02012cc:	97eff0ef          	jal	ffffffffc020044a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02012d0:	00005697          	auipc	a3,0x5
ffffffffc02012d4:	23868693          	addi	a3,a3,568 # ffffffffc0206508 <etext+0xbae>
ffffffffc02012d8:	00005617          	auipc	a2,0x5
ffffffffc02012dc:	0b860613          	addi	a2,a2,184 # ffffffffc0206390 <etext+0xa36>
ffffffffc02012e0:	0e900593          	li	a1,233
ffffffffc02012e4:	00005517          	auipc	a0,0x5
ffffffffc02012e8:	0c450513          	addi	a0,a0,196 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc02012ec:	95eff0ef          	jal	ffffffffc020044a <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc02012f0:	00005697          	auipc	a3,0x5
ffffffffc02012f4:	1f868693          	addi	a3,a3,504 # ffffffffc02064e8 <etext+0xb8e>
ffffffffc02012f8:	00005617          	auipc	a2,0x5
ffffffffc02012fc:	09860613          	addi	a2,a2,152 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201300:	0e000593          	li	a1,224
ffffffffc0201304:	00005517          	auipc	a0,0x5
ffffffffc0201308:	0a450513          	addi	a0,a0,164 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020130c:	93eff0ef          	jal	ffffffffc020044a <__panic>
    assert(p0 != NULL);
ffffffffc0201310:	00005697          	auipc	a3,0x5
ffffffffc0201314:	26868693          	addi	a3,a3,616 # ffffffffc0206578 <etext+0xc1e>
ffffffffc0201318:	00005617          	auipc	a2,0x5
ffffffffc020131c:	07860613          	addi	a2,a2,120 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201320:	11800593          	li	a1,280
ffffffffc0201324:	00005517          	auipc	a0,0x5
ffffffffc0201328:	08450513          	addi	a0,a0,132 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020132c:	91eff0ef          	jal	ffffffffc020044a <__panic>
    assert(nr_free == 0);
ffffffffc0201330:	00005697          	auipc	a3,0x5
ffffffffc0201334:	23868693          	addi	a3,a3,568 # ffffffffc0206568 <etext+0xc0e>
ffffffffc0201338:	00005617          	auipc	a2,0x5
ffffffffc020133c:	05860613          	addi	a2,a2,88 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201340:	0fd00593          	li	a1,253
ffffffffc0201344:	00005517          	auipc	a0,0x5
ffffffffc0201348:	06450513          	addi	a0,a0,100 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020134c:	8feff0ef          	jal	ffffffffc020044a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201350:	00005697          	auipc	a3,0x5
ffffffffc0201354:	1b868693          	addi	a3,a3,440 # ffffffffc0206508 <etext+0xbae>
ffffffffc0201358:	00005617          	auipc	a2,0x5
ffffffffc020135c:	03860613          	addi	a2,a2,56 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201360:	0fb00593          	li	a1,251
ffffffffc0201364:	00005517          	auipc	a0,0x5
ffffffffc0201368:	04450513          	addi	a0,a0,68 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020136c:	8deff0ef          	jal	ffffffffc020044a <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201370:	00005697          	auipc	a3,0x5
ffffffffc0201374:	1d868693          	addi	a3,a3,472 # ffffffffc0206548 <etext+0xbee>
ffffffffc0201378:	00005617          	auipc	a2,0x5
ffffffffc020137c:	01860613          	addi	a2,a2,24 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201380:	0fa00593          	li	a1,250
ffffffffc0201384:	00005517          	auipc	a0,0x5
ffffffffc0201388:	02450513          	addi	a0,a0,36 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020138c:	8beff0ef          	jal	ffffffffc020044a <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201390:	00005697          	auipc	a3,0x5
ffffffffc0201394:	05068693          	addi	a3,a3,80 # ffffffffc02063e0 <etext+0xa86>
ffffffffc0201398:	00005617          	auipc	a2,0x5
ffffffffc020139c:	ff860613          	addi	a2,a2,-8 # ffffffffc0206390 <etext+0xa36>
ffffffffc02013a0:	0d700593          	li	a1,215
ffffffffc02013a4:	00005517          	auipc	a0,0x5
ffffffffc02013a8:	00450513          	addi	a0,a0,4 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc02013ac:	89eff0ef          	jal	ffffffffc020044a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013b0:	00005697          	auipc	a3,0x5
ffffffffc02013b4:	15868693          	addi	a3,a3,344 # ffffffffc0206508 <etext+0xbae>
ffffffffc02013b8:	00005617          	auipc	a2,0x5
ffffffffc02013bc:	fd860613          	addi	a2,a2,-40 # ffffffffc0206390 <etext+0xa36>
ffffffffc02013c0:	0f400593          	li	a1,244
ffffffffc02013c4:	00005517          	auipc	a0,0x5
ffffffffc02013c8:	fe450513          	addi	a0,a0,-28 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc02013cc:	87eff0ef          	jal	ffffffffc020044a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02013d0:	00005697          	auipc	a3,0x5
ffffffffc02013d4:	05068693          	addi	a3,a3,80 # ffffffffc0206420 <etext+0xac6>
ffffffffc02013d8:	00005617          	auipc	a2,0x5
ffffffffc02013dc:	fb860613          	addi	a2,a2,-72 # ffffffffc0206390 <etext+0xa36>
ffffffffc02013e0:	0f200593          	li	a1,242
ffffffffc02013e4:	00005517          	auipc	a0,0x5
ffffffffc02013e8:	fc450513          	addi	a0,a0,-60 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc02013ec:	85eff0ef          	jal	ffffffffc020044a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02013f0:	00005697          	auipc	a3,0x5
ffffffffc02013f4:	01068693          	addi	a3,a3,16 # ffffffffc0206400 <etext+0xaa6>
ffffffffc02013f8:	00005617          	auipc	a2,0x5
ffffffffc02013fc:	f9860613          	addi	a2,a2,-104 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201400:	0f100593          	li	a1,241
ffffffffc0201404:	00005517          	auipc	a0,0x5
ffffffffc0201408:	fa450513          	addi	a0,a0,-92 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020140c:	83eff0ef          	jal	ffffffffc020044a <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201410:	00005697          	auipc	a3,0x5
ffffffffc0201414:	01068693          	addi	a3,a3,16 # ffffffffc0206420 <etext+0xac6>
ffffffffc0201418:	00005617          	auipc	a2,0x5
ffffffffc020141c:	f7860613          	addi	a2,a2,-136 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201420:	0d900593          	li	a1,217
ffffffffc0201424:	00005517          	auipc	a0,0x5
ffffffffc0201428:	f8450513          	addi	a0,a0,-124 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020142c:	81eff0ef          	jal	ffffffffc020044a <__panic>
    assert(count == 0);
ffffffffc0201430:	00005697          	auipc	a3,0x5
ffffffffc0201434:	29868693          	addi	a3,a3,664 # ffffffffc02066c8 <etext+0xd6e>
ffffffffc0201438:	00005617          	auipc	a2,0x5
ffffffffc020143c:	f5860613          	addi	a2,a2,-168 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201440:	14600593          	li	a1,326
ffffffffc0201444:	00005517          	auipc	a0,0x5
ffffffffc0201448:	f6450513          	addi	a0,a0,-156 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020144c:	ffffe0ef          	jal	ffffffffc020044a <__panic>
    assert(nr_free == 0);
ffffffffc0201450:	00005697          	auipc	a3,0x5
ffffffffc0201454:	11868693          	addi	a3,a3,280 # ffffffffc0206568 <etext+0xc0e>
ffffffffc0201458:	00005617          	auipc	a2,0x5
ffffffffc020145c:	f3860613          	addi	a2,a2,-200 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201460:	13a00593          	li	a1,314
ffffffffc0201464:	00005517          	auipc	a0,0x5
ffffffffc0201468:	f4450513          	addi	a0,a0,-188 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020146c:	fdffe0ef          	jal	ffffffffc020044a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201470:	00005697          	auipc	a3,0x5
ffffffffc0201474:	09868693          	addi	a3,a3,152 # ffffffffc0206508 <etext+0xbae>
ffffffffc0201478:	00005617          	auipc	a2,0x5
ffffffffc020147c:	f1860613          	addi	a2,a2,-232 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201480:	13800593          	li	a1,312
ffffffffc0201484:	00005517          	auipc	a0,0x5
ffffffffc0201488:	f2450513          	addi	a0,a0,-220 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020148c:	fbffe0ef          	jal	ffffffffc020044a <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201490:	00005697          	auipc	a3,0x5
ffffffffc0201494:	03868693          	addi	a3,a3,56 # ffffffffc02064c8 <etext+0xb6e>
ffffffffc0201498:	00005617          	auipc	a2,0x5
ffffffffc020149c:	ef860613          	addi	a2,a2,-264 # ffffffffc0206390 <etext+0xa36>
ffffffffc02014a0:	0df00593          	li	a1,223
ffffffffc02014a4:	00005517          	auipc	a0,0x5
ffffffffc02014a8:	f0450513          	addi	a0,a0,-252 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc02014ac:	f9ffe0ef          	jal	ffffffffc020044a <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02014b0:	00005697          	auipc	a3,0x5
ffffffffc02014b4:	1d868693          	addi	a3,a3,472 # ffffffffc0206688 <etext+0xd2e>
ffffffffc02014b8:	00005617          	auipc	a2,0x5
ffffffffc02014bc:	ed860613          	addi	a2,a2,-296 # ffffffffc0206390 <etext+0xa36>
ffffffffc02014c0:	13200593          	li	a1,306
ffffffffc02014c4:	00005517          	auipc	a0,0x5
ffffffffc02014c8:	ee450513          	addi	a0,a0,-284 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc02014cc:	f7ffe0ef          	jal	ffffffffc020044a <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02014d0:	00005697          	auipc	a3,0x5
ffffffffc02014d4:	19868693          	addi	a3,a3,408 # ffffffffc0206668 <etext+0xd0e>
ffffffffc02014d8:	00005617          	auipc	a2,0x5
ffffffffc02014dc:	eb860613          	addi	a2,a2,-328 # ffffffffc0206390 <etext+0xa36>
ffffffffc02014e0:	13000593          	li	a1,304
ffffffffc02014e4:	00005517          	auipc	a0,0x5
ffffffffc02014e8:	ec450513          	addi	a0,a0,-316 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc02014ec:	f5ffe0ef          	jal	ffffffffc020044a <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02014f0:	00005697          	auipc	a3,0x5
ffffffffc02014f4:	15068693          	addi	a3,a3,336 # ffffffffc0206640 <etext+0xce6>
ffffffffc02014f8:	00005617          	auipc	a2,0x5
ffffffffc02014fc:	e9860613          	addi	a2,a2,-360 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201500:	12e00593          	li	a1,302
ffffffffc0201504:	00005517          	auipc	a0,0x5
ffffffffc0201508:	ea450513          	addi	a0,a0,-348 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020150c:	f3ffe0ef          	jal	ffffffffc020044a <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201510:	00005697          	auipc	a3,0x5
ffffffffc0201514:	10868693          	addi	a3,a3,264 # ffffffffc0206618 <etext+0xcbe>
ffffffffc0201518:	00005617          	auipc	a2,0x5
ffffffffc020151c:	e7860613          	addi	a2,a2,-392 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201520:	12d00593          	li	a1,301
ffffffffc0201524:	00005517          	auipc	a0,0x5
ffffffffc0201528:	e8450513          	addi	a0,a0,-380 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020152c:	f1ffe0ef          	jal	ffffffffc020044a <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201530:	00005697          	auipc	a3,0x5
ffffffffc0201534:	0d868693          	addi	a3,a3,216 # ffffffffc0206608 <etext+0xcae>
ffffffffc0201538:	00005617          	auipc	a2,0x5
ffffffffc020153c:	e5860613          	addi	a2,a2,-424 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201540:	12800593          	li	a1,296
ffffffffc0201544:	00005517          	auipc	a0,0x5
ffffffffc0201548:	e6450513          	addi	a0,a0,-412 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020154c:	efffe0ef          	jal	ffffffffc020044a <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201550:	00005697          	auipc	a3,0x5
ffffffffc0201554:	fb868693          	addi	a3,a3,-72 # ffffffffc0206508 <etext+0xbae>
ffffffffc0201558:	00005617          	auipc	a2,0x5
ffffffffc020155c:	e3860613          	addi	a2,a2,-456 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201560:	12700593          	li	a1,295
ffffffffc0201564:	00005517          	auipc	a0,0x5
ffffffffc0201568:	e4450513          	addi	a0,a0,-444 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020156c:	edffe0ef          	jal	ffffffffc020044a <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201570:	00005697          	auipc	a3,0x5
ffffffffc0201574:	07868693          	addi	a3,a3,120 # ffffffffc02065e8 <etext+0xc8e>
ffffffffc0201578:	00005617          	auipc	a2,0x5
ffffffffc020157c:	e1860613          	addi	a2,a2,-488 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201580:	12600593          	li	a1,294
ffffffffc0201584:	00005517          	auipc	a0,0x5
ffffffffc0201588:	e2450513          	addi	a0,a0,-476 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020158c:	ebffe0ef          	jal	ffffffffc020044a <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201590:	00005697          	auipc	a3,0x5
ffffffffc0201594:	02868693          	addi	a3,a3,40 # ffffffffc02065b8 <etext+0xc5e>
ffffffffc0201598:	00005617          	auipc	a2,0x5
ffffffffc020159c:	df860613          	addi	a2,a2,-520 # ffffffffc0206390 <etext+0xa36>
ffffffffc02015a0:	12500593          	li	a1,293
ffffffffc02015a4:	00005517          	auipc	a0,0x5
ffffffffc02015a8:	e0450513          	addi	a0,a0,-508 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc02015ac:	e9ffe0ef          	jal	ffffffffc020044a <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02015b0:	00005697          	auipc	a3,0x5
ffffffffc02015b4:	ff068693          	addi	a3,a3,-16 # ffffffffc02065a0 <etext+0xc46>
ffffffffc02015b8:	00005617          	auipc	a2,0x5
ffffffffc02015bc:	dd860613          	addi	a2,a2,-552 # ffffffffc0206390 <etext+0xa36>
ffffffffc02015c0:	12400593          	li	a1,292
ffffffffc02015c4:	00005517          	auipc	a0,0x5
ffffffffc02015c8:	de450513          	addi	a0,a0,-540 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc02015cc:	e7ffe0ef          	jal	ffffffffc020044a <__panic>
    assert(alloc_page() == NULL);
ffffffffc02015d0:	00005697          	auipc	a3,0x5
ffffffffc02015d4:	f3868693          	addi	a3,a3,-200 # ffffffffc0206508 <etext+0xbae>
ffffffffc02015d8:	00005617          	auipc	a2,0x5
ffffffffc02015dc:	db860613          	addi	a2,a2,-584 # ffffffffc0206390 <etext+0xa36>
ffffffffc02015e0:	11e00593          	li	a1,286
ffffffffc02015e4:	00005517          	auipc	a0,0x5
ffffffffc02015e8:	dc450513          	addi	a0,a0,-572 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc02015ec:	e5ffe0ef          	jal	ffffffffc020044a <__panic>
    assert(!PageProperty(p0));
ffffffffc02015f0:	00005697          	auipc	a3,0x5
ffffffffc02015f4:	f9868693          	addi	a3,a3,-104 # ffffffffc0206588 <etext+0xc2e>
ffffffffc02015f8:	00005617          	auipc	a2,0x5
ffffffffc02015fc:	d9860613          	addi	a2,a2,-616 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201600:	11900593          	li	a1,281
ffffffffc0201604:	00005517          	auipc	a0,0x5
ffffffffc0201608:	da450513          	addi	a0,a0,-604 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020160c:	e3ffe0ef          	jal	ffffffffc020044a <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201610:	00005697          	auipc	a3,0x5
ffffffffc0201614:	09868693          	addi	a3,a3,152 # ffffffffc02066a8 <etext+0xd4e>
ffffffffc0201618:	00005617          	auipc	a2,0x5
ffffffffc020161c:	d7860613          	addi	a2,a2,-648 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201620:	13700593          	li	a1,311
ffffffffc0201624:	00005517          	auipc	a0,0x5
ffffffffc0201628:	d8450513          	addi	a0,a0,-636 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020162c:	e1ffe0ef          	jal	ffffffffc020044a <__panic>
    assert(total == 0);
ffffffffc0201630:	00005697          	auipc	a3,0x5
ffffffffc0201634:	0a868693          	addi	a3,a3,168 # ffffffffc02066d8 <etext+0xd7e>
ffffffffc0201638:	00005617          	auipc	a2,0x5
ffffffffc020163c:	d5860613          	addi	a2,a2,-680 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201640:	14700593          	li	a1,327
ffffffffc0201644:	00005517          	auipc	a0,0x5
ffffffffc0201648:	d6450513          	addi	a0,a0,-668 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020164c:	dfffe0ef          	jal	ffffffffc020044a <__panic>
    assert(total == nr_free_pages());
ffffffffc0201650:	00005697          	auipc	a3,0x5
ffffffffc0201654:	d7068693          	addi	a3,a3,-656 # ffffffffc02063c0 <etext+0xa66>
ffffffffc0201658:	00005617          	auipc	a2,0x5
ffffffffc020165c:	d3860613          	addi	a2,a2,-712 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201660:	11300593          	li	a1,275
ffffffffc0201664:	00005517          	auipc	a0,0x5
ffffffffc0201668:	d4450513          	addi	a0,a0,-700 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020166c:	ddffe0ef          	jal	ffffffffc020044a <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201670:	00005697          	auipc	a3,0x5
ffffffffc0201674:	d9068693          	addi	a3,a3,-624 # ffffffffc0206400 <etext+0xaa6>
ffffffffc0201678:	00005617          	auipc	a2,0x5
ffffffffc020167c:	d1860613          	addi	a2,a2,-744 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201680:	0d800593          	li	a1,216
ffffffffc0201684:	00005517          	auipc	a0,0x5
ffffffffc0201688:	d2450513          	addi	a0,a0,-732 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc020168c:	dbffe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201690 <default_free_pages>:
{
ffffffffc0201690:	1141                	addi	sp,sp,-16
ffffffffc0201692:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201694:	14058663          	beqz	a1,ffffffffc02017e0 <default_free_pages+0x150>
    for (; p != base + n; p++)
ffffffffc0201698:	00659713          	slli	a4,a1,0x6
ffffffffc020169c:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc02016a0:	87aa                	mv	a5,a0
    for (; p != base + n; p++)
ffffffffc02016a2:	c30d                	beqz	a4,ffffffffc02016c4 <default_free_pages+0x34>
ffffffffc02016a4:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02016a6:	8b05                	andi	a4,a4,1
ffffffffc02016a8:	10071c63          	bnez	a4,ffffffffc02017c0 <default_free_pages+0x130>
ffffffffc02016ac:	6798                	ld	a4,8(a5)
ffffffffc02016ae:	8b09                	andi	a4,a4,2
ffffffffc02016b0:	10071863          	bnez	a4,ffffffffc02017c0 <default_free_pages+0x130>
        p->flags = 0;
ffffffffc02016b4:	0007b423          	sd	zero,8(a5)
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc02016b8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02016bc:	04078793          	addi	a5,a5,64
ffffffffc02016c0:	fed792e3          	bne	a5,a3,ffffffffc02016a4 <default_free_pages+0x14>
    base->property = n;
ffffffffc02016c4:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02016c6:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02016ca:	4789                	li	a5,2
ffffffffc02016cc:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02016d0:	000b0717          	auipc	a4,0xb0
ffffffffc02016d4:	f2872703          	lw	a4,-216(a4) # ffffffffc02b15f8 <free_area+0x10>
ffffffffc02016d8:	000b0697          	auipc	a3,0xb0
ffffffffc02016dc:	f1068693          	addi	a3,a3,-240 # ffffffffc02b15e8 <free_area>
    return list->next == list;
ffffffffc02016e0:	669c                	ld	a5,8(a3)
ffffffffc02016e2:	9f2d                	addw	a4,a4,a1
ffffffffc02016e4:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list))
ffffffffc02016e6:	0ad78163          	beq	a5,a3,ffffffffc0201788 <default_free_pages+0xf8>
            struct Page *page = le2page(le, page_link);
ffffffffc02016ea:	fe878713          	addi	a4,a5,-24
ffffffffc02016ee:	4581                	li	a1,0
ffffffffc02016f0:	01850613          	addi	a2,a0,24
            if (base < page)
ffffffffc02016f4:	00e56a63          	bltu	a0,a4,ffffffffc0201708 <default_free_pages+0x78>
    return listelm->next;
ffffffffc02016f8:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc02016fa:	04d70c63          	beq	a4,a3,ffffffffc0201752 <default_free_pages+0xc2>
    struct Page *p = base;
ffffffffc02016fe:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0201700:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0201704:	fee57ae3          	bgeu	a0,a4,ffffffffc02016f8 <default_free_pages+0x68>
ffffffffc0201708:	c199                	beqz	a1,ffffffffc020170e <default_free_pages+0x7e>
ffffffffc020170a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020170e:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201710:	e390                	sd	a2,0(a5)
ffffffffc0201712:	e710                	sd	a2,8(a4)
    elm->next = next;
    elm->prev = prev;
ffffffffc0201714:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc0201716:	f11c                	sd	a5,32(a0)
    if (le != &free_list)
ffffffffc0201718:	00d70d63          	beq	a4,a3,ffffffffc0201732 <default_free_pages+0xa2>
        if (p + p->property == base)
ffffffffc020171c:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc0201720:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base)
ffffffffc0201724:	02059813          	slli	a6,a1,0x20
ffffffffc0201728:	01a85793          	srli	a5,a6,0x1a
ffffffffc020172c:	97b2                	add	a5,a5,a2
ffffffffc020172e:	02f50c63          	beq	a0,a5,ffffffffc0201766 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc0201732:	711c                	ld	a5,32(a0)
    if (le != &free_list)
ffffffffc0201734:	00d78c63          	beq	a5,a3,ffffffffc020174c <default_free_pages+0xbc>
        if (base + base->property == p)
ffffffffc0201738:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc020173a:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p)
ffffffffc020173e:	02061593          	slli	a1,a2,0x20
ffffffffc0201742:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0201746:	972a                	add	a4,a4,a0
ffffffffc0201748:	04e68c63          	beq	a3,a4,ffffffffc02017a0 <default_free_pages+0x110>
}
ffffffffc020174c:	60a2                	ld	ra,8(sp)
ffffffffc020174e:	0141                	addi	sp,sp,16
ffffffffc0201750:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201752:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201754:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201756:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201758:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc020175a:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list)
ffffffffc020175c:	02d70f63          	beq	a4,a3,ffffffffc020179a <default_free_pages+0x10a>
ffffffffc0201760:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0201762:	87ba                	mv	a5,a4
ffffffffc0201764:	bf71                	j	ffffffffc0201700 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc0201766:	491c                	lw	a5,16(a0)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201768:	5875                	li	a6,-3
ffffffffc020176a:	9fad                	addw	a5,a5,a1
ffffffffc020176c:	fef72c23          	sw	a5,-8(a4)
ffffffffc0201770:	6108b02f          	amoand.d	zero,a6,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201774:	01853803          	ld	a6,24(a0)
ffffffffc0201778:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc020177a:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc020177c:	00b83423          	sd	a1,8(a6) # ff0008 <_binary_obj___user_matrix_out_size+0xfe4ac8>
    return listelm->next;
ffffffffc0201780:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0201782:	0105b023          	sd	a6,0(a1)
ffffffffc0201786:	b77d                	j	ffffffffc0201734 <default_free_pages+0xa4>
}
ffffffffc0201788:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020178a:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc020178e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201790:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc0201792:	e398                	sd	a4,0(a5)
ffffffffc0201794:	e798                	sd	a4,8(a5)
}
ffffffffc0201796:	0141                	addi	sp,sp,16
ffffffffc0201798:	8082                	ret
ffffffffc020179a:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020179c:	873e                	mv	a4,a5
ffffffffc020179e:	bfad                	j	ffffffffc0201718 <default_free_pages+0x88>
            base->property += p->property;
ffffffffc02017a0:	ff87a703          	lw	a4,-8(a5)
ffffffffc02017a4:	56f5                	li	a3,-3
ffffffffc02017a6:	9f31                	addw	a4,a4,a2
ffffffffc02017a8:	c918                	sw	a4,16(a0)
ffffffffc02017aa:	ff078713          	addi	a4,a5,-16
ffffffffc02017ae:	60d7302f          	amoand.d	zero,a3,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc02017b2:	6398                	ld	a4,0(a5)
ffffffffc02017b4:	679c                	ld	a5,8(a5)
}
ffffffffc02017b6:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02017b8:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc02017ba:	e398                	sd	a4,0(a5)
ffffffffc02017bc:	0141                	addi	sp,sp,16
ffffffffc02017be:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02017c0:	00005697          	auipc	a3,0x5
ffffffffc02017c4:	f3068693          	addi	a3,a3,-208 # ffffffffc02066f0 <etext+0xd96>
ffffffffc02017c8:	00005617          	auipc	a2,0x5
ffffffffc02017cc:	bc860613          	addi	a2,a2,-1080 # ffffffffc0206390 <etext+0xa36>
ffffffffc02017d0:	09400593          	li	a1,148
ffffffffc02017d4:	00005517          	auipc	a0,0x5
ffffffffc02017d8:	bd450513          	addi	a0,a0,-1068 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc02017dc:	c6ffe0ef          	jal	ffffffffc020044a <__panic>
    assert(n > 0);
ffffffffc02017e0:	00005697          	auipc	a3,0x5
ffffffffc02017e4:	f0868693          	addi	a3,a3,-248 # ffffffffc02066e8 <etext+0xd8e>
ffffffffc02017e8:	00005617          	auipc	a2,0x5
ffffffffc02017ec:	ba860613          	addi	a2,a2,-1112 # ffffffffc0206390 <etext+0xa36>
ffffffffc02017f0:	09000593          	li	a1,144
ffffffffc02017f4:	00005517          	auipc	a0,0x5
ffffffffc02017f8:	bb450513          	addi	a0,a0,-1100 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc02017fc:	c4ffe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201800 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201800:	c951                	beqz	a0,ffffffffc0201894 <default_alloc_pages+0x94>
    if (n > nr_free)
ffffffffc0201802:	000b0597          	auipc	a1,0xb0
ffffffffc0201806:	df65a583          	lw	a1,-522(a1) # ffffffffc02b15f8 <free_area+0x10>
ffffffffc020180a:	86aa                	mv	a3,a0
ffffffffc020180c:	02059793          	slli	a5,a1,0x20
ffffffffc0201810:	9381                	srli	a5,a5,0x20
ffffffffc0201812:	00a7ef63          	bltu	a5,a0,ffffffffc0201830 <default_alloc_pages+0x30>
    list_entry_t *le = &free_list;
ffffffffc0201816:	000b0617          	auipc	a2,0xb0
ffffffffc020181a:	dd260613          	addi	a2,a2,-558 # ffffffffc02b15e8 <free_area>
ffffffffc020181e:	87b2                	mv	a5,a2
ffffffffc0201820:	a029                	j	ffffffffc020182a <default_alloc_pages+0x2a>
        if (p->property >= n)
ffffffffc0201822:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0201826:	00d77763          	bgeu	a4,a3,ffffffffc0201834 <default_alloc_pages+0x34>
    return listelm->next;
ffffffffc020182a:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc020182c:	fec79be3          	bne	a5,a2,ffffffffc0201822 <default_alloc_pages+0x22>
        return NULL;
ffffffffc0201830:	4501                	li	a0,0
}
ffffffffc0201832:	8082                	ret
        if (page->property > n)
ffffffffc0201834:	ff87a883          	lw	a7,-8(a5)
    return listelm->prev;
ffffffffc0201838:	0007b803          	ld	a6,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc020183c:	6798                	ld	a4,8(a5)
ffffffffc020183e:	02089313          	slli	t1,a7,0x20
ffffffffc0201842:	02035313          	srli	t1,t1,0x20
    prev->next = next;
ffffffffc0201846:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc020184a:	01073023          	sd	a6,0(a4)
        struct Page *p = le2page(le, page_link);
ffffffffc020184e:	fe878513          	addi	a0,a5,-24
        if (page->property > n)
ffffffffc0201852:	0266fa63          	bgeu	a3,t1,ffffffffc0201886 <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc0201856:	00669713          	slli	a4,a3,0x6
            p->property = page->property - n;
ffffffffc020185a:	40d888bb          	subw	a7,a7,a3
            struct Page *p = page + n;
ffffffffc020185e:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201860:	01172823          	sw	a7,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201864:	00870313          	addi	t1,a4,8
ffffffffc0201868:	4889                	li	a7,2
ffffffffc020186a:	4113302f          	amoor.d	zero,a7,(t1)
    __list_add(elm, listelm, listelm->next);
ffffffffc020186e:	00883883          	ld	a7,8(a6)
            list_add(prev, &(p->page_link));
ffffffffc0201872:	01870313          	addi	t1,a4,24
    prev->next = next->prev = elm;
ffffffffc0201876:	0068b023          	sd	t1,0(a7)
ffffffffc020187a:	00683423          	sd	t1,8(a6)
    elm->next = next;
ffffffffc020187e:	03173023          	sd	a7,32(a4)
    elm->prev = prev;
ffffffffc0201882:	01073c23          	sd	a6,24(a4)
        nr_free -= n;
ffffffffc0201886:	9d95                	subw	a1,a1,a3
ffffffffc0201888:	ca0c                	sw	a1,16(a2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020188a:	5775                	li	a4,-3
ffffffffc020188c:	17c1                	addi	a5,a5,-16
ffffffffc020188e:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201892:	8082                	ret
{
ffffffffc0201894:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201896:	00005697          	auipc	a3,0x5
ffffffffc020189a:	e5268693          	addi	a3,a3,-430 # ffffffffc02066e8 <etext+0xd8e>
ffffffffc020189e:	00005617          	auipc	a2,0x5
ffffffffc02018a2:	af260613          	addi	a2,a2,-1294 # ffffffffc0206390 <etext+0xa36>
ffffffffc02018a6:	06c00593          	li	a1,108
ffffffffc02018aa:	00005517          	auipc	a0,0x5
ffffffffc02018ae:	afe50513          	addi	a0,a0,-1282 # ffffffffc02063a8 <etext+0xa4e>
{
ffffffffc02018b2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02018b4:	b97fe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02018b8 <default_init_memmap>:
{
ffffffffc02018b8:	1141                	addi	sp,sp,-16
ffffffffc02018ba:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02018bc:	c9e1                	beqz	a1,ffffffffc020198c <default_init_memmap+0xd4>
    for (; p != base + n; p++)
ffffffffc02018be:	00659713          	slli	a4,a1,0x6
ffffffffc02018c2:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc02018c6:	87aa                	mv	a5,a0
    for (; p != base + n; p++)
ffffffffc02018c8:	cf11                	beqz	a4,ffffffffc02018e4 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02018ca:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02018cc:	8b05                	andi	a4,a4,1
ffffffffc02018ce:	cf59                	beqz	a4,ffffffffc020196c <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc02018d0:	0007a823          	sw	zero,16(a5)
ffffffffc02018d4:	0007b423          	sd	zero,8(a5)
ffffffffc02018d8:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc02018dc:	04078793          	addi	a5,a5,64
ffffffffc02018e0:	fed795e3          	bne	a5,a3,ffffffffc02018ca <default_init_memmap+0x12>
    base->property = n;
ffffffffc02018e4:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02018e6:	4789                	li	a5,2
ffffffffc02018e8:	00850713          	addi	a4,a0,8
ffffffffc02018ec:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc02018f0:	000b0717          	auipc	a4,0xb0
ffffffffc02018f4:	d0872703          	lw	a4,-760(a4) # ffffffffc02b15f8 <free_area+0x10>
ffffffffc02018f8:	000b0697          	auipc	a3,0xb0
ffffffffc02018fc:	cf068693          	addi	a3,a3,-784 # ffffffffc02b15e8 <free_area>
    return list->next == list;
ffffffffc0201900:	669c                	ld	a5,8(a3)
ffffffffc0201902:	9f2d                	addw	a4,a4,a1
ffffffffc0201904:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list))
ffffffffc0201906:	04d78663          	beq	a5,a3,ffffffffc0201952 <default_init_memmap+0x9a>
            struct Page *page = le2page(le, page_link);
ffffffffc020190a:	fe878713          	addi	a4,a5,-24
ffffffffc020190e:	4581                	li	a1,0
ffffffffc0201910:	01850613          	addi	a2,a0,24
            if (base < page)
ffffffffc0201914:	00e56a63          	bltu	a0,a4,ffffffffc0201928 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0201918:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc020191a:	02d70263          	beq	a4,a3,ffffffffc020193e <default_init_memmap+0x86>
    struct Page *p = base;
ffffffffc020191e:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0201920:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0201924:	fee57ae3          	bgeu	a0,a4,ffffffffc0201918 <default_init_memmap+0x60>
ffffffffc0201928:	c199                	beqz	a1,ffffffffc020192e <default_init_memmap+0x76>
ffffffffc020192a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020192e:	6398                	ld	a4,0(a5)
}
ffffffffc0201930:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201932:	e390                	sd	a2,0(a5)
ffffffffc0201934:	e710                	sd	a2,8(a4)
    elm->prev = prev;
ffffffffc0201936:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc0201938:	f11c                	sd	a5,32(a0)
ffffffffc020193a:	0141                	addi	sp,sp,16
ffffffffc020193c:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020193e:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201940:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201942:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201944:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201946:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list)
ffffffffc0201948:	00d70e63          	beq	a4,a3,ffffffffc0201964 <default_init_memmap+0xac>
ffffffffc020194c:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc020194e:	87ba                	mv	a5,a4
ffffffffc0201950:	bfc1                	j	ffffffffc0201920 <default_init_memmap+0x68>
}
ffffffffc0201952:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201954:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc0201958:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc020195a:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc020195c:	e398                	sd	a4,0(a5)
ffffffffc020195e:	e798                	sd	a4,8(a5)
}
ffffffffc0201960:	0141                	addi	sp,sp,16
ffffffffc0201962:	8082                	ret
ffffffffc0201964:	60a2                	ld	ra,8(sp)
ffffffffc0201966:	e290                	sd	a2,0(a3)
ffffffffc0201968:	0141                	addi	sp,sp,16
ffffffffc020196a:	8082                	ret
        assert(PageReserved(p));
ffffffffc020196c:	00005697          	auipc	a3,0x5
ffffffffc0201970:	dac68693          	addi	a3,a3,-596 # ffffffffc0206718 <etext+0xdbe>
ffffffffc0201974:	00005617          	auipc	a2,0x5
ffffffffc0201978:	a1c60613          	addi	a2,a2,-1508 # ffffffffc0206390 <etext+0xa36>
ffffffffc020197c:	04b00593          	li	a1,75
ffffffffc0201980:	00005517          	auipc	a0,0x5
ffffffffc0201984:	a2850513          	addi	a0,a0,-1496 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc0201988:	ac3fe0ef          	jal	ffffffffc020044a <__panic>
    assert(n > 0);
ffffffffc020198c:	00005697          	auipc	a3,0x5
ffffffffc0201990:	d5c68693          	addi	a3,a3,-676 # ffffffffc02066e8 <etext+0xd8e>
ffffffffc0201994:	00005617          	auipc	a2,0x5
ffffffffc0201998:	9fc60613          	addi	a2,a2,-1540 # ffffffffc0206390 <etext+0xa36>
ffffffffc020199c:	04700593          	li	a1,71
ffffffffc02019a0:	00005517          	auipc	a0,0x5
ffffffffc02019a4:	a0850513          	addi	a0,a0,-1528 # ffffffffc02063a8 <etext+0xa4e>
ffffffffc02019a8:	aa3fe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02019ac <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc02019ac:	c531                	beqz	a0,ffffffffc02019f8 <slob_free+0x4c>
		return;

	if (size)
ffffffffc02019ae:	e9b9                	bnez	a1,ffffffffc0201a04 <slob_free+0x58>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02019b0:	100027f3          	csrr	a5,sstatus
ffffffffc02019b4:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02019b6:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02019b8:	efb1                	bnez	a5,ffffffffc0201a14 <slob_free+0x68>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019ba:	000b0797          	auipc	a5,0xb0
ffffffffc02019be:	81e7b783          	ld	a5,-2018(a5) # ffffffffc02b11d8 <slobfree>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019c2:	873e                	mv	a4,a5
ffffffffc02019c4:	679c                	ld	a5,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc02019c6:	02a77a63          	bgeu	a4,a0,ffffffffc02019fa <slob_free+0x4e>
ffffffffc02019ca:	00f56463          	bltu	a0,a5,ffffffffc02019d2 <slob_free+0x26>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019ce:	fef76ae3          	bltu	a4,a5,ffffffffc02019c2 <slob_free+0x16>
			break;

	if (b + b->units == cur->next)
ffffffffc02019d2:	4110                	lw	a2,0(a0)
ffffffffc02019d4:	00461693          	slli	a3,a2,0x4
ffffffffc02019d8:	96aa                	add	a3,a3,a0
ffffffffc02019da:	0ad78463          	beq	a5,a3,ffffffffc0201a82 <slob_free+0xd6>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc02019de:	4310                	lw	a2,0(a4)
ffffffffc02019e0:	e51c                	sd	a5,8(a0)
ffffffffc02019e2:	00461693          	slli	a3,a2,0x4
ffffffffc02019e6:	96ba                	add	a3,a3,a4
ffffffffc02019e8:	08d50163          	beq	a0,a3,ffffffffc0201a6a <slob_free+0xbe>
ffffffffc02019ec:	e708                	sd	a0,8(a4)
		cur->next = b->next;
	}
	else
		cur->next = b;

	slobfree = cur;
ffffffffc02019ee:	000af797          	auipc	a5,0xaf
ffffffffc02019f2:	7ee7b523          	sd	a4,2026(a5) # ffffffffc02b11d8 <slobfree>
    if (flag)
ffffffffc02019f6:	e9a5                	bnez	a1,ffffffffc0201a66 <slob_free+0xba>
ffffffffc02019f8:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc02019fa:	fcf574e3          	bgeu	a0,a5,ffffffffc02019c2 <slob_free+0x16>
ffffffffc02019fe:	fcf762e3          	bltu	a4,a5,ffffffffc02019c2 <slob_free+0x16>
ffffffffc0201a02:	bfc1                	j	ffffffffc02019d2 <slob_free+0x26>
		b->units = SLOB_UNITS(size);
ffffffffc0201a04:	25bd                	addiw	a1,a1,15
ffffffffc0201a06:	8191                	srli	a1,a1,0x4
ffffffffc0201a08:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201a0a:	100027f3          	csrr	a5,sstatus
ffffffffc0201a0e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201a10:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201a12:	d7c5                	beqz	a5,ffffffffc02019ba <slob_free+0xe>
{
ffffffffc0201a14:	1101                	addi	sp,sp,-32
ffffffffc0201a16:	e42a                	sd	a0,8(sp)
ffffffffc0201a18:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201a1a:	ee5fe0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc0201a1e:	6522                	ld	a0,8(sp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a20:	000af797          	auipc	a5,0xaf
ffffffffc0201a24:	7b87b783          	ld	a5,1976(a5) # ffffffffc02b11d8 <slobfree>
ffffffffc0201a28:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a2a:	873e                	mv	a4,a5
ffffffffc0201a2c:	679c                	ld	a5,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201a2e:	06a77663          	bgeu	a4,a0,ffffffffc0201a9a <slob_free+0xee>
ffffffffc0201a32:	00f56463          	bltu	a0,a5,ffffffffc0201a3a <slob_free+0x8e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a36:	fef76ae3          	bltu	a4,a5,ffffffffc0201a2a <slob_free+0x7e>
	if (b + b->units == cur->next)
ffffffffc0201a3a:	4110                	lw	a2,0(a0)
ffffffffc0201a3c:	00461693          	slli	a3,a2,0x4
ffffffffc0201a40:	96aa                	add	a3,a3,a0
ffffffffc0201a42:	06d78363          	beq	a5,a3,ffffffffc0201aa8 <slob_free+0xfc>
	if (cur + cur->units == b)
ffffffffc0201a46:	4310                	lw	a2,0(a4)
ffffffffc0201a48:	e51c                	sd	a5,8(a0)
ffffffffc0201a4a:	00461693          	slli	a3,a2,0x4
ffffffffc0201a4e:	96ba                	add	a3,a3,a4
ffffffffc0201a50:	06d50163          	beq	a0,a3,ffffffffc0201ab2 <slob_free+0x106>
ffffffffc0201a54:	e708                	sd	a0,8(a4)
	slobfree = cur;
ffffffffc0201a56:	000af797          	auipc	a5,0xaf
ffffffffc0201a5a:	78e7b123          	sd	a4,1922(a5) # ffffffffc02b11d8 <slobfree>
    if (flag)
ffffffffc0201a5e:	e1a9                	bnez	a1,ffffffffc0201aa0 <slob_free+0xf4>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201a60:	60e2                	ld	ra,24(sp)
ffffffffc0201a62:	6105                	addi	sp,sp,32
ffffffffc0201a64:	8082                	ret
        intr_enable();
ffffffffc0201a66:	e93fe06f          	j	ffffffffc02008f8 <intr_enable>
		cur->units += b->units;
ffffffffc0201a6a:	4114                	lw	a3,0(a0)
		cur->next = b->next;
ffffffffc0201a6c:	853e                	mv	a0,a5
ffffffffc0201a6e:	e708                	sd	a0,8(a4)
		cur->units += b->units;
ffffffffc0201a70:	00c687bb          	addw	a5,a3,a2
ffffffffc0201a74:	c31c                	sw	a5,0(a4)
	slobfree = cur;
ffffffffc0201a76:	000af797          	auipc	a5,0xaf
ffffffffc0201a7a:	76e7b123          	sd	a4,1890(a5) # ffffffffc02b11d8 <slobfree>
    if (flag)
ffffffffc0201a7e:	ddad                	beqz	a1,ffffffffc02019f8 <slob_free+0x4c>
ffffffffc0201a80:	b7dd                	j	ffffffffc0201a66 <slob_free+0xba>
		b->units += cur->next->units;
ffffffffc0201a82:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201a84:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201a86:	9eb1                	addw	a3,a3,a2
ffffffffc0201a88:	c114                	sw	a3,0(a0)
	if (cur + cur->units == b)
ffffffffc0201a8a:	4310                	lw	a2,0(a4)
ffffffffc0201a8c:	e51c                	sd	a5,8(a0)
ffffffffc0201a8e:	00461693          	slli	a3,a2,0x4
ffffffffc0201a92:	96ba                	add	a3,a3,a4
ffffffffc0201a94:	f4d51ce3          	bne	a0,a3,ffffffffc02019ec <slob_free+0x40>
ffffffffc0201a98:	bfc9                	j	ffffffffc0201a6a <slob_free+0xbe>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201a9a:	f8f56ee3          	bltu	a0,a5,ffffffffc0201a36 <slob_free+0x8a>
ffffffffc0201a9e:	b771                	j	ffffffffc0201a2a <slob_free+0x7e>
}
ffffffffc0201aa0:	60e2                	ld	ra,24(sp)
ffffffffc0201aa2:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201aa4:	e55fe06f          	j	ffffffffc02008f8 <intr_enable>
		b->units += cur->next->units;
ffffffffc0201aa8:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201aaa:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201aac:	9eb1                	addw	a3,a3,a2
ffffffffc0201aae:	c114                	sw	a3,0(a0)
		b->next = cur->next->next;
ffffffffc0201ab0:	bf59                	j	ffffffffc0201a46 <slob_free+0x9a>
		cur->units += b->units;
ffffffffc0201ab2:	4114                	lw	a3,0(a0)
		cur->next = b->next;
ffffffffc0201ab4:	853e                	mv	a0,a5
		cur->units += b->units;
ffffffffc0201ab6:	00c687bb          	addw	a5,a3,a2
ffffffffc0201aba:	c31c                	sw	a5,0(a4)
		cur->next = b->next;
ffffffffc0201abc:	bf61                	j	ffffffffc0201a54 <slob_free+0xa8>

ffffffffc0201abe <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201abe:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201ac0:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201ac2:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201ac6:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201ac8:	32a000ef          	jal	ffffffffc0201df2 <alloc_pages>
	if (!page)
ffffffffc0201acc:	c91d                	beqz	a0,ffffffffc0201b02 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201ace:	000b4697          	auipc	a3,0xb4
ffffffffc0201ad2:	bc26b683          	ld	a3,-1086(a3) # ffffffffc02b5690 <pages>
ffffffffc0201ad6:	00006797          	auipc	a5,0x6
ffffffffc0201ada:	7e27b783          	ld	a5,2018(a5) # ffffffffc02082b8 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201ade:	000b4717          	auipc	a4,0xb4
ffffffffc0201ae2:	baa73703          	ld	a4,-1110(a4) # ffffffffc02b5688 <npage>
    return page - pages + nbase;
ffffffffc0201ae6:	8d15                	sub	a0,a0,a3
ffffffffc0201ae8:	8519                	srai	a0,a0,0x6
ffffffffc0201aea:	953e                	add	a0,a0,a5
    return KADDR(page2pa(page));
ffffffffc0201aec:	00c51793          	slli	a5,a0,0xc
ffffffffc0201af0:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201af2:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201af4:	00e7fa63          	bgeu	a5,a4,ffffffffc0201b08 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201af8:	000b4797          	auipc	a5,0xb4
ffffffffc0201afc:	b887b783          	ld	a5,-1144(a5) # ffffffffc02b5680 <va_pa_offset>
ffffffffc0201b00:	953e                	add	a0,a0,a5
}
ffffffffc0201b02:	60a2                	ld	ra,8(sp)
ffffffffc0201b04:	0141                	addi	sp,sp,16
ffffffffc0201b06:	8082                	ret
ffffffffc0201b08:	86aa                	mv	a3,a0
ffffffffc0201b0a:	00005617          	auipc	a2,0x5
ffffffffc0201b0e:	c3660613          	addi	a2,a2,-970 # ffffffffc0206740 <etext+0xde6>
ffffffffc0201b12:	07100593          	li	a1,113
ffffffffc0201b16:	00005517          	auipc	a0,0x5
ffffffffc0201b1a:	c5250513          	addi	a0,a0,-942 # ffffffffc0206768 <etext+0xe0e>
ffffffffc0201b1e:	92dfe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201b22 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201b22:	7179                	addi	sp,sp,-48
ffffffffc0201b24:	f406                	sd	ra,40(sp)
ffffffffc0201b26:	f022                	sd	s0,32(sp)
ffffffffc0201b28:	ec26                	sd	s1,24(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201b2a:	01050713          	addi	a4,a0,16
ffffffffc0201b2e:	6785                	lui	a5,0x1
ffffffffc0201b30:	0af77e63          	bgeu	a4,a5,ffffffffc0201bec <slob_alloc.constprop.0+0xca>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201b34:	00f50413          	addi	s0,a0,15
ffffffffc0201b38:	8011                	srli	s0,s0,0x4
ffffffffc0201b3a:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b3c:	100025f3          	csrr	a1,sstatus
ffffffffc0201b40:	8989                	andi	a1,a1,2
ffffffffc0201b42:	edd1                	bnez	a1,ffffffffc0201bde <slob_alloc.constprop.0+0xbc>
	prev = slobfree;
ffffffffc0201b44:	000af497          	auipc	s1,0xaf
ffffffffc0201b48:	69448493          	addi	s1,s1,1684 # ffffffffc02b11d8 <slobfree>
ffffffffc0201b4c:	6090                	ld	a2,0(s1)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201b4e:	6618                	ld	a4,8(a2)
		if (cur->units >= units + delta)
ffffffffc0201b50:	4314                	lw	a3,0(a4)
ffffffffc0201b52:	0886da63          	bge	a3,s0,ffffffffc0201be6 <slob_alloc.constprop.0+0xc4>
		if (cur == slobfree)
ffffffffc0201b56:	00e60a63          	beq	a2,a4,ffffffffc0201b6a <slob_alloc.constprop.0+0x48>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201b5a:	671c                	ld	a5,8(a4)
		if (cur->units >= units + delta)
ffffffffc0201b5c:	4394                	lw	a3,0(a5)
ffffffffc0201b5e:	0286d863          	bge	a3,s0,ffffffffc0201b8e <slob_alloc.constprop.0+0x6c>
		if (cur == slobfree)
ffffffffc0201b62:	6090                	ld	a2,0(s1)
ffffffffc0201b64:	873e                	mv	a4,a5
ffffffffc0201b66:	fee61ae3          	bne	a2,a4,ffffffffc0201b5a <slob_alloc.constprop.0+0x38>
    if (flag)
ffffffffc0201b6a:	e9b1                	bnez	a1,ffffffffc0201bbe <slob_alloc.constprop.0+0x9c>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201b6c:	4501                	li	a0,0
ffffffffc0201b6e:	f51ff0ef          	jal	ffffffffc0201abe <__slob_get_free_pages.constprop.0>
ffffffffc0201b72:	87aa                	mv	a5,a0
			if (!cur)
ffffffffc0201b74:	c915                	beqz	a0,ffffffffc0201ba8 <slob_alloc.constprop.0+0x86>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201b76:	6585                	lui	a1,0x1
ffffffffc0201b78:	e35ff0ef          	jal	ffffffffc02019ac <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b7c:	100025f3          	csrr	a1,sstatus
ffffffffc0201b80:	8989                	andi	a1,a1,2
ffffffffc0201b82:	e98d                	bnez	a1,ffffffffc0201bb4 <slob_alloc.constprop.0+0x92>
			cur = slobfree;
ffffffffc0201b84:	6098                	ld	a4,0(s1)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201b86:	671c                	ld	a5,8(a4)
		if (cur->units >= units + delta)
ffffffffc0201b88:	4394                	lw	a3,0(a5)
ffffffffc0201b8a:	fc86cce3          	blt	a3,s0,ffffffffc0201b62 <slob_alloc.constprop.0+0x40>
			if (cur->units == units)	/* exact fit? */
ffffffffc0201b8e:	04d40563          	beq	s0,a3,ffffffffc0201bd8 <slob_alloc.constprop.0+0xb6>
				prev->next = cur + units;
ffffffffc0201b92:	00441613          	slli	a2,s0,0x4
ffffffffc0201b96:	963e                	add	a2,a2,a5
ffffffffc0201b98:	e710                	sd	a2,8(a4)
				prev->next->next = cur->next;
ffffffffc0201b9a:	6788                	ld	a0,8(a5)
				prev->next->units = cur->units - units;
ffffffffc0201b9c:	9e81                	subw	a3,a3,s0
ffffffffc0201b9e:	c214                	sw	a3,0(a2)
				prev->next->next = cur->next;
ffffffffc0201ba0:	e608                	sd	a0,8(a2)
				cur->units = units;
ffffffffc0201ba2:	c380                	sw	s0,0(a5)
			slobfree = prev;
ffffffffc0201ba4:	e098                	sd	a4,0(s1)
    if (flag)
ffffffffc0201ba6:	ed99                	bnez	a1,ffffffffc0201bc4 <slob_alloc.constprop.0+0xa2>
}
ffffffffc0201ba8:	70a2                	ld	ra,40(sp)
ffffffffc0201baa:	7402                	ld	s0,32(sp)
ffffffffc0201bac:	64e2                	ld	s1,24(sp)
ffffffffc0201bae:	853e                	mv	a0,a5
ffffffffc0201bb0:	6145                	addi	sp,sp,48
ffffffffc0201bb2:	8082                	ret
        intr_disable();
ffffffffc0201bb4:	d4bfe0ef          	jal	ffffffffc02008fe <intr_disable>
			cur = slobfree;
ffffffffc0201bb8:	6098                	ld	a4,0(s1)
        return 1;
ffffffffc0201bba:	4585                	li	a1,1
ffffffffc0201bbc:	b7e9                	j	ffffffffc0201b86 <slob_alloc.constprop.0+0x64>
        intr_enable();
ffffffffc0201bbe:	d3bfe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0201bc2:	b76d                	j	ffffffffc0201b6c <slob_alloc.constprop.0+0x4a>
ffffffffc0201bc4:	e43e                	sd	a5,8(sp)
ffffffffc0201bc6:	d33fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0201bca:	67a2                	ld	a5,8(sp)
}
ffffffffc0201bcc:	70a2                	ld	ra,40(sp)
ffffffffc0201bce:	7402                	ld	s0,32(sp)
ffffffffc0201bd0:	64e2                	ld	s1,24(sp)
ffffffffc0201bd2:	853e                	mv	a0,a5
ffffffffc0201bd4:	6145                	addi	sp,sp,48
ffffffffc0201bd6:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201bd8:	6794                	ld	a3,8(a5)
ffffffffc0201bda:	e714                	sd	a3,8(a4)
ffffffffc0201bdc:	b7e1                	j	ffffffffc0201ba4 <slob_alloc.constprop.0+0x82>
        intr_disable();
ffffffffc0201bde:	d21fe0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc0201be2:	4585                	li	a1,1
ffffffffc0201be4:	b785                	j	ffffffffc0201b44 <slob_alloc.constprop.0+0x22>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201be6:	87ba                	mv	a5,a4
	prev = slobfree;
ffffffffc0201be8:	8732                	mv	a4,a2
ffffffffc0201bea:	b755                	j	ffffffffc0201b8e <slob_alloc.constprop.0+0x6c>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201bec:	00005697          	auipc	a3,0x5
ffffffffc0201bf0:	b8c68693          	addi	a3,a3,-1140 # ffffffffc0206778 <etext+0xe1e>
ffffffffc0201bf4:	00004617          	auipc	a2,0x4
ffffffffc0201bf8:	79c60613          	addi	a2,a2,1948 # ffffffffc0206390 <etext+0xa36>
ffffffffc0201bfc:	06300593          	li	a1,99
ffffffffc0201c00:	00005517          	auipc	a0,0x5
ffffffffc0201c04:	b9850513          	addi	a0,a0,-1128 # ffffffffc0206798 <etext+0xe3e>
ffffffffc0201c08:	843fe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201c0c <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc0201c0c:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc0201c0e:	00005517          	auipc	a0,0x5
ffffffffc0201c12:	ba250513          	addi	a0,a0,-1118 # ffffffffc02067b0 <etext+0xe56>
{
ffffffffc0201c16:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc0201c18:	d80fe0ef          	jal	ffffffffc0200198 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201c1c:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c1e:	00005517          	auipc	a0,0x5
ffffffffc0201c22:	baa50513          	addi	a0,a0,-1110 # ffffffffc02067c8 <etext+0xe6e>
}
ffffffffc0201c26:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201c28:	d70fe06f          	j	ffffffffc0200198 <cprintf>

ffffffffc0201c2c <kallocated>:

size_t
kallocated(void)
{
	return slob_allocated();
}
ffffffffc0201c2c:	4501                	li	a0,0
ffffffffc0201c2e:	8082                	ret

ffffffffc0201c30 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201c30:	1101                	addi	sp,sp,-32
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201c32:	6685                	lui	a3,0x1
{
ffffffffc0201c34:	ec06                	sd	ra,24(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201c36:	16bd                	addi	a3,a3,-17 # fef <_binary_obj___user_softint_out_size-0x7f39>
ffffffffc0201c38:	04a6f963          	bgeu	a3,a0,ffffffffc0201c8a <kmalloc+0x5a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201c3c:	e42a                	sd	a0,8(sp)
ffffffffc0201c3e:	4561                	li	a0,24
ffffffffc0201c40:	e822                	sd	s0,16(sp)
ffffffffc0201c42:	ee1ff0ef          	jal	ffffffffc0201b22 <slob_alloc.constprop.0>
ffffffffc0201c46:	842a                	mv	s0,a0
	if (!bb)
ffffffffc0201c48:	c541                	beqz	a0,ffffffffc0201cd0 <kmalloc+0xa0>
	bb->order = find_order(size);
ffffffffc0201c4a:	47a2                	lw	a5,8(sp)
	for (; size > 4096; size >>= 1)
ffffffffc0201c4c:	6705                	lui	a4,0x1
	int order = 0;
ffffffffc0201c4e:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201c50:	00f75763          	bge	a4,a5,ffffffffc0201c5e <kmalloc+0x2e>
ffffffffc0201c54:	4017d79b          	sraiw	a5,a5,0x1
		order++;
ffffffffc0201c58:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc0201c5a:	fef74de3          	blt	a4,a5,ffffffffc0201c54 <kmalloc+0x24>
	bb->order = find_order(size);
ffffffffc0201c5e:	c008                	sw	a0,0(s0)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201c60:	e5fff0ef          	jal	ffffffffc0201abe <__slob_get_free_pages.constprop.0>
ffffffffc0201c64:	e408                	sd	a0,8(s0)
	if (bb->pages)
ffffffffc0201c66:	cd31                	beqz	a0,ffffffffc0201cc2 <kmalloc+0x92>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201c68:	100027f3          	csrr	a5,sstatus
ffffffffc0201c6c:	8b89                	andi	a5,a5,2
ffffffffc0201c6e:	eb85                	bnez	a5,ffffffffc0201c9e <kmalloc+0x6e>
		bb->next = bigblocks;
ffffffffc0201c70:	000b4797          	auipc	a5,0xb4
ffffffffc0201c74:	9f07b783          	ld	a5,-1552(a5) # ffffffffc02b5660 <bigblocks>
		bigblocks = bb;
ffffffffc0201c78:	000b4717          	auipc	a4,0xb4
ffffffffc0201c7c:	9e873423          	sd	s0,-1560(a4) # ffffffffc02b5660 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201c80:	e81c                	sd	a5,16(s0)
    if (flag)
ffffffffc0201c82:	6442                	ld	s0,16(sp)
	return __kmalloc(size, 0);
}
ffffffffc0201c84:	60e2                	ld	ra,24(sp)
ffffffffc0201c86:	6105                	addi	sp,sp,32
ffffffffc0201c88:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201c8a:	0541                	addi	a0,a0,16
ffffffffc0201c8c:	e97ff0ef          	jal	ffffffffc0201b22 <slob_alloc.constprop.0>
ffffffffc0201c90:	87aa                	mv	a5,a0
		return m ? (void *)(m + 1) : 0;
ffffffffc0201c92:	0541                	addi	a0,a0,16
ffffffffc0201c94:	fbe5                	bnez	a5,ffffffffc0201c84 <kmalloc+0x54>
		return 0;
ffffffffc0201c96:	4501                	li	a0,0
}
ffffffffc0201c98:	60e2                	ld	ra,24(sp)
ffffffffc0201c9a:	6105                	addi	sp,sp,32
ffffffffc0201c9c:	8082                	ret
        intr_disable();
ffffffffc0201c9e:	c61fe0ef          	jal	ffffffffc02008fe <intr_disable>
		bb->next = bigblocks;
ffffffffc0201ca2:	000b4797          	auipc	a5,0xb4
ffffffffc0201ca6:	9be7b783          	ld	a5,-1602(a5) # ffffffffc02b5660 <bigblocks>
		bigblocks = bb;
ffffffffc0201caa:	000b4717          	auipc	a4,0xb4
ffffffffc0201cae:	9a873b23          	sd	s0,-1610(a4) # ffffffffc02b5660 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201cb2:	e81c                	sd	a5,16(s0)
        intr_enable();
ffffffffc0201cb4:	c45fe0ef          	jal	ffffffffc02008f8 <intr_enable>
		return bb->pages;
ffffffffc0201cb8:	6408                	ld	a0,8(s0)
}
ffffffffc0201cba:	60e2                	ld	ra,24(sp)
		return bb->pages;
ffffffffc0201cbc:	6442                	ld	s0,16(sp)
}
ffffffffc0201cbe:	6105                	addi	sp,sp,32
ffffffffc0201cc0:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201cc2:	8522                	mv	a0,s0
ffffffffc0201cc4:	45e1                	li	a1,24
ffffffffc0201cc6:	ce7ff0ef          	jal	ffffffffc02019ac <slob_free>
		return 0;
ffffffffc0201cca:	4501                	li	a0,0
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201ccc:	6442                	ld	s0,16(sp)
ffffffffc0201cce:	b7e9                	j	ffffffffc0201c98 <kmalloc+0x68>
ffffffffc0201cd0:	6442                	ld	s0,16(sp)
		return 0;
ffffffffc0201cd2:	4501                	li	a0,0
ffffffffc0201cd4:	b7d1                	j	ffffffffc0201c98 <kmalloc+0x68>

ffffffffc0201cd6 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201cd6:	c571                	beqz	a0,ffffffffc0201da2 <kfree+0xcc>
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201cd8:	03451793          	slli	a5,a0,0x34
ffffffffc0201cdc:	e3e1                	bnez	a5,ffffffffc0201d9c <kfree+0xc6>
{
ffffffffc0201cde:	1101                	addi	sp,sp,-32
ffffffffc0201ce0:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201ce2:	100027f3          	csrr	a5,sstatus
ffffffffc0201ce6:	8b89                	andi	a5,a5,2
ffffffffc0201ce8:	e7c1                	bnez	a5,ffffffffc0201d70 <kfree+0x9a>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201cea:	000b4797          	auipc	a5,0xb4
ffffffffc0201cee:	9767b783          	ld	a5,-1674(a5) # ffffffffc02b5660 <bigblocks>
    return 0;
ffffffffc0201cf2:	4581                	li	a1,0
ffffffffc0201cf4:	cbad                	beqz	a5,ffffffffc0201d66 <kfree+0x90>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201cf6:	000b4617          	auipc	a2,0xb4
ffffffffc0201cfa:	96a60613          	addi	a2,a2,-1686 # ffffffffc02b5660 <bigblocks>
ffffffffc0201cfe:	a021                	j	ffffffffc0201d06 <kfree+0x30>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201d00:	01070613          	addi	a2,a4,16
ffffffffc0201d04:	c3a5                	beqz	a5,ffffffffc0201d64 <kfree+0x8e>
		{
			if (bb->pages == block)
ffffffffc0201d06:	6794                	ld	a3,8(a5)
ffffffffc0201d08:	873e                	mv	a4,a5
			{
				*last = bb->next;
ffffffffc0201d0a:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0201d0c:	fea69ae3          	bne	a3,a0,ffffffffc0201d00 <kfree+0x2a>
				*last = bb->next;
ffffffffc0201d10:	e21c                	sd	a5,0(a2)
    if (flag)
ffffffffc0201d12:	edb5                	bnez	a1,ffffffffc0201d8e <kfree+0xb8>
    return pa2page(PADDR(kva));
ffffffffc0201d14:	c02007b7          	lui	a5,0xc0200
ffffffffc0201d18:	0af56263          	bltu	a0,a5,ffffffffc0201dbc <kfree+0xe6>
ffffffffc0201d1c:	000b4797          	auipc	a5,0xb4
ffffffffc0201d20:	9647b783          	ld	a5,-1692(a5) # ffffffffc02b5680 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc0201d24:	000b4697          	auipc	a3,0xb4
ffffffffc0201d28:	9646b683          	ld	a3,-1692(a3) # ffffffffc02b5688 <npage>
    return pa2page(PADDR(kva));
ffffffffc0201d2c:	8d1d                	sub	a0,a0,a5
    if (PPN(pa) >= npage)
ffffffffc0201d2e:	00c55793          	srli	a5,a0,0xc
ffffffffc0201d32:	06d7f963          	bgeu	a5,a3,ffffffffc0201da4 <kfree+0xce>
    return &pages[PPN(pa) - nbase];
ffffffffc0201d36:	00006617          	auipc	a2,0x6
ffffffffc0201d3a:	58263603          	ld	a2,1410(a2) # ffffffffc02082b8 <nbase>
ffffffffc0201d3e:	000b4517          	auipc	a0,0xb4
ffffffffc0201d42:	95253503          	ld	a0,-1710(a0) # ffffffffc02b5690 <pages>
	free_pages(kva2page((void *)kva), 1 << order);
ffffffffc0201d46:	4314                	lw	a3,0(a4)
ffffffffc0201d48:	8f91                	sub	a5,a5,a2
ffffffffc0201d4a:	079a                	slli	a5,a5,0x6
ffffffffc0201d4c:	4585                	li	a1,1
ffffffffc0201d4e:	953e                	add	a0,a0,a5
ffffffffc0201d50:	00d595bb          	sllw	a1,a1,a3
ffffffffc0201d54:	e03a                	sd	a4,0(sp)
ffffffffc0201d56:	0d6000ef          	jal	ffffffffc0201e2c <free_pages>
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d5a:	6502                	ld	a0,0(sp)
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201d5c:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d5e:	45e1                	li	a1,24
}
ffffffffc0201d60:	6105                	addi	sp,sp,32
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201d62:	b1a9                	j	ffffffffc02019ac <slob_free>
ffffffffc0201d64:	e185                	bnez	a1,ffffffffc0201d84 <kfree+0xae>
}
ffffffffc0201d66:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d68:	1541                	addi	a0,a0,-16
ffffffffc0201d6a:	4581                	li	a1,0
}
ffffffffc0201d6c:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d6e:	b93d                	j	ffffffffc02019ac <slob_free>
        intr_disable();
ffffffffc0201d70:	e02a                	sd	a0,0(sp)
ffffffffc0201d72:	b8dfe0ef          	jal	ffffffffc02008fe <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201d76:	000b4797          	auipc	a5,0xb4
ffffffffc0201d7a:	8ea7b783          	ld	a5,-1814(a5) # ffffffffc02b5660 <bigblocks>
ffffffffc0201d7e:	6502                	ld	a0,0(sp)
        return 1;
ffffffffc0201d80:	4585                	li	a1,1
ffffffffc0201d82:	fbb5                	bnez	a5,ffffffffc0201cf6 <kfree+0x20>
ffffffffc0201d84:	e02a                	sd	a0,0(sp)
        intr_enable();
ffffffffc0201d86:	b73fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0201d8a:	6502                	ld	a0,0(sp)
ffffffffc0201d8c:	bfe9                	j	ffffffffc0201d66 <kfree+0x90>
ffffffffc0201d8e:	e42a                	sd	a0,8(sp)
ffffffffc0201d90:	e03a                	sd	a4,0(sp)
ffffffffc0201d92:	b67fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0201d96:	6522                	ld	a0,8(sp)
ffffffffc0201d98:	6702                	ld	a4,0(sp)
ffffffffc0201d9a:	bfad                	j	ffffffffc0201d14 <kfree+0x3e>
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201d9c:	1541                	addi	a0,a0,-16
ffffffffc0201d9e:	4581                	li	a1,0
ffffffffc0201da0:	b131                	j	ffffffffc02019ac <slob_free>
ffffffffc0201da2:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201da4:	00005617          	auipc	a2,0x5
ffffffffc0201da8:	a6c60613          	addi	a2,a2,-1428 # ffffffffc0206810 <etext+0xeb6>
ffffffffc0201dac:	06900593          	li	a1,105
ffffffffc0201db0:	00005517          	auipc	a0,0x5
ffffffffc0201db4:	9b850513          	addi	a0,a0,-1608 # ffffffffc0206768 <etext+0xe0e>
ffffffffc0201db8:	e92fe0ef          	jal	ffffffffc020044a <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201dbc:	86aa                	mv	a3,a0
ffffffffc0201dbe:	00005617          	auipc	a2,0x5
ffffffffc0201dc2:	a2a60613          	addi	a2,a2,-1494 # ffffffffc02067e8 <etext+0xe8e>
ffffffffc0201dc6:	07700593          	li	a1,119
ffffffffc0201dca:	00005517          	auipc	a0,0x5
ffffffffc0201dce:	99e50513          	addi	a0,a0,-1634 # ffffffffc0206768 <etext+0xe0e>
ffffffffc0201dd2:	e78fe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201dd6 <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc0201dd6:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201dd8:	00005617          	auipc	a2,0x5
ffffffffc0201ddc:	a3860613          	addi	a2,a2,-1480 # ffffffffc0206810 <etext+0xeb6>
ffffffffc0201de0:	06900593          	li	a1,105
ffffffffc0201de4:	00005517          	auipc	a0,0x5
ffffffffc0201de8:	98450513          	addi	a0,a0,-1660 # ffffffffc0206768 <etext+0xe0e>
pa2page(uintptr_t pa)
ffffffffc0201dec:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201dee:	e5cfe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201df2 <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201df2:	100027f3          	csrr	a5,sstatus
ffffffffc0201df6:	8b89                	andi	a5,a5,2
ffffffffc0201df8:	e799                	bnez	a5,ffffffffc0201e06 <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201dfa:	000b4797          	auipc	a5,0xb4
ffffffffc0201dfe:	86e7b783          	ld	a5,-1938(a5) # ffffffffc02b5668 <pmm_manager>
ffffffffc0201e02:	6f9c                	ld	a5,24(a5)
ffffffffc0201e04:	8782                	jr	a5
{
ffffffffc0201e06:	1101                	addi	sp,sp,-32
ffffffffc0201e08:	ec06                	sd	ra,24(sp)
ffffffffc0201e0a:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201e0c:	af3fe0ef          	jal	ffffffffc02008fe <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201e10:	000b4797          	auipc	a5,0xb4
ffffffffc0201e14:	8587b783          	ld	a5,-1960(a5) # ffffffffc02b5668 <pmm_manager>
ffffffffc0201e18:	6522                	ld	a0,8(sp)
ffffffffc0201e1a:	6f9c                	ld	a5,24(a5)
ffffffffc0201e1c:	9782                	jalr	a5
ffffffffc0201e1e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201e20:	ad9fe0ef          	jal	ffffffffc02008f8 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201e24:	60e2                	ld	ra,24(sp)
ffffffffc0201e26:	6522                	ld	a0,8(sp)
ffffffffc0201e28:	6105                	addi	sp,sp,32
ffffffffc0201e2a:	8082                	ret

ffffffffc0201e2c <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201e2c:	100027f3          	csrr	a5,sstatus
ffffffffc0201e30:	8b89                	andi	a5,a5,2
ffffffffc0201e32:	e799                	bnez	a5,ffffffffc0201e40 <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201e34:	000b4797          	auipc	a5,0xb4
ffffffffc0201e38:	8347b783          	ld	a5,-1996(a5) # ffffffffc02b5668 <pmm_manager>
ffffffffc0201e3c:	739c                	ld	a5,32(a5)
ffffffffc0201e3e:	8782                	jr	a5
{
ffffffffc0201e40:	1101                	addi	sp,sp,-32
ffffffffc0201e42:	ec06                	sd	ra,24(sp)
ffffffffc0201e44:	e42e                	sd	a1,8(sp)
ffffffffc0201e46:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0201e48:	ab7fe0ef          	jal	ffffffffc02008fe <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201e4c:	000b4797          	auipc	a5,0xb4
ffffffffc0201e50:	81c7b783          	ld	a5,-2020(a5) # ffffffffc02b5668 <pmm_manager>
ffffffffc0201e54:	65a2                	ld	a1,8(sp)
ffffffffc0201e56:	6502                	ld	a0,0(sp)
ffffffffc0201e58:	739c                	ld	a5,32(a5)
ffffffffc0201e5a:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201e5c:	60e2                	ld	ra,24(sp)
ffffffffc0201e5e:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201e60:	a99fe06f          	j	ffffffffc02008f8 <intr_enable>

ffffffffc0201e64 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201e64:	100027f3          	csrr	a5,sstatus
ffffffffc0201e68:	8b89                	andi	a5,a5,2
ffffffffc0201e6a:	e799                	bnez	a5,ffffffffc0201e78 <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201e6c:	000b3797          	auipc	a5,0xb3
ffffffffc0201e70:	7fc7b783          	ld	a5,2044(a5) # ffffffffc02b5668 <pmm_manager>
ffffffffc0201e74:	779c                	ld	a5,40(a5)
ffffffffc0201e76:	8782                	jr	a5
{
ffffffffc0201e78:	1101                	addi	sp,sp,-32
ffffffffc0201e7a:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201e7c:	a83fe0ef          	jal	ffffffffc02008fe <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201e80:	000b3797          	auipc	a5,0xb3
ffffffffc0201e84:	7e87b783          	ld	a5,2024(a5) # ffffffffc02b5668 <pmm_manager>
ffffffffc0201e88:	779c                	ld	a5,40(a5)
ffffffffc0201e8a:	9782                	jalr	a5
ffffffffc0201e8c:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201e8e:	a6bfe0ef          	jal	ffffffffc02008f8 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201e92:	60e2                	ld	ra,24(sp)
ffffffffc0201e94:	6522                	ld	a0,8(sp)
ffffffffc0201e96:	6105                	addi	sp,sp,32
ffffffffc0201e98:	8082                	ret

ffffffffc0201e9a <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc0201e9a:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0201e9e:	1ff7f793          	andi	a5,a5,511
ffffffffc0201ea2:	078e                	slli	a5,a5,0x3
ffffffffc0201ea4:	00f50733          	add	a4,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc0201ea8:	6314                	ld	a3,0(a4)
{
ffffffffc0201eaa:	7139                	addi	sp,sp,-64
ffffffffc0201eac:	f822                	sd	s0,48(sp)
ffffffffc0201eae:	f426                	sd	s1,40(sp)
ffffffffc0201eb0:	fc06                	sd	ra,56(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc0201eb2:	0016f793          	andi	a5,a3,1
{
ffffffffc0201eb6:	842e                	mv	s0,a1
ffffffffc0201eb8:	8832                	mv	a6,a2
ffffffffc0201eba:	000b3497          	auipc	s1,0xb3
ffffffffc0201ebe:	7ce48493          	addi	s1,s1,1998 # ffffffffc02b5688 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc0201ec2:	ebd1                	bnez	a5,ffffffffc0201f56 <get_pte+0xbc>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201ec4:	16060d63          	beqz	a2,ffffffffc020203e <get_pte+0x1a4>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201ec8:	100027f3          	csrr	a5,sstatus
ffffffffc0201ecc:	8b89                	andi	a5,a5,2
ffffffffc0201ece:	16079e63          	bnez	a5,ffffffffc020204a <get_pte+0x1b0>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201ed2:	000b3797          	auipc	a5,0xb3
ffffffffc0201ed6:	7967b783          	ld	a5,1942(a5) # ffffffffc02b5668 <pmm_manager>
ffffffffc0201eda:	4505                	li	a0,1
ffffffffc0201edc:	e43a                	sd	a4,8(sp)
ffffffffc0201ede:	6f9c                	ld	a5,24(a5)
ffffffffc0201ee0:	e832                	sd	a2,16(sp)
ffffffffc0201ee2:	9782                	jalr	a5
ffffffffc0201ee4:	6722                	ld	a4,8(sp)
ffffffffc0201ee6:	6842                	ld	a6,16(sp)
ffffffffc0201ee8:	87aa                	mv	a5,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201eea:	14078a63          	beqz	a5,ffffffffc020203e <get_pte+0x1a4>
    return page - pages + nbase;
ffffffffc0201eee:	000b3517          	auipc	a0,0xb3
ffffffffc0201ef2:	7a253503          	ld	a0,1954(a0) # ffffffffc02b5690 <pages>
ffffffffc0201ef6:	000808b7          	lui	a7,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201efa:	000b3497          	auipc	s1,0xb3
ffffffffc0201efe:	78e48493          	addi	s1,s1,1934 # ffffffffc02b5688 <npage>
ffffffffc0201f02:	40a78533          	sub	a0,a5,a0
ffffffffc0201f06:	8519                	srai	a0,a0,0x6
ffffffffc0201f08:	9546                	add	a0,a0,a7
ffffffffc0201f0a:	6090                	ld	a2,0(s1)
ffffffffc0201f0c:	00c51693          	slli	a3,a0,0xc
    page->ref = val;
ffffffffc0201f10:	4585                	li	a1,1
ffffffffc0201f12:	82b1                	srli	a3,a3,0xc
ffffffffc0201f14:	c38c                	sw	a1,0(a5)
    return page2ppn(page) << PGSHIFT;
ffffffffc0201f16:	0532                	slli	a0,a0,0xc
ffffffffc0201f18:	1ac6f763          	bgeu	a3,a2,ffffffffc02020c6 <get_pte+0x22c>
ffffffffc0201f1c:	000b3697          	auipc	a3,0xb3
ffffffffc0201f20:	7646b683          	ld	a3,1892(a3) # ffffffffc02b5680 <va_pa_offset>
ffffffffc0201f24:	6605                	lui	a2,0x1
ffffffffc0201f26:	4581                	li	a1,0
ffffffffc0201f28:	9536                	add	a0,a0,a3
ffffffffc0201f2a:	ec42                	sd	a6,24(sp)
ffffffffc0201f2c:	e83e                	sd	a5,16(sp)
ffffffffc0201f2e:	e43a                	sd	a4,8(sp)
ffffffffc0201f30:	201030ef          	jal	ffffffffc0205930 <memset>
    return page - pages + nbase;
ffffffffc0201f34:	000b3697          	auipc	a3,0xb3
ffffffffc0201f38:	75c6b683          	ld	a3,1884(a3) # ffffffffc02b5690 <pages>
ffffffffc0201f3c:	67c2                	ld	a5,16(sp)
ffffffffc0201f3e:	000808b7          	lui	a7,0x80
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201f42:	6722                	ld	a4,8(sp)
ffffffffc0201f44:	40d786b3          	sub	a3,a5,a3
ffffffffc0201f48:	8699                	srai	a3,a3,0x6
ffffffffc0201f4a:	96c6                	add	a3,a3,a7
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0201f4c:	06aa                	slli	a3,a3,0xa
ffffffffc0201f4e:	6862                	ld	a6,24(sp)
ffffffffc0201f50:	0116e693          	ori	a3,a3,17
ffffffffc0201f54:	e314                	sd	a3,0(a4)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0201f56:	c006f693          	andi	a3,a3,-1024
ffffffffc0201f5a:	6098                	ld	a4,0(s1)
ffffffffc0201f5c:	068a                	slli	a3,a3,0x2
ffffffffc0201f5e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0201f62:	14e7f663          	bgeu	a5,a4,ffffffffc02020ae <get_pte+0x214>
ffffffffc0201f66:	000b3897          	auipc	a7,0xb3
ffffffffc0201f6a:	71a88893          	addi	a7,a7,1818 # ffffffffc02b5680 <va_pa_offset>
ffffffffc0201f6e:	0008b603          	ld	a2,0(a7)
ffffffffc0201f72:	01545793          	srli	a5,s0,0x15
ffffffffc0201f76:	1ff7f793          	andi	a5,a5,511
ffffffffc0201f7a:	96b2                	add	a3,a3,a2
ffffffffc0201f7c:	078e                	slli	a5,a5,0x3
ffffffffc0201f7e:	97b6                	add	a5,a5,a3
    if (!(*pdep0 & PTE_V))
ffffffffc0201f80:	6394                	ld	a3,0(a5)
ffffffffc0201f82:	0016f613          	andi	a2,a3,1
ffffffffc0201f86:	e659                	bnez	a2,ffffffffc0202014 <get_pte+0x17a>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201f88:	0a080b63          	beqz	a6,ffffffffc020203e <get_pte+0x1a4>
ffffffffc0201f8c:	10002773          	csrr	a4,sstatus
ffffffffc0201f90:	8b09                	andi	a4,a4,2
ffffffffc0201f92:	ef71                	bnez	a4,ffffffffc020206e <get_pte+0x1d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201f94:	000b3717          	auipc	a4,0xb3
ffffffffc0201f98:	6d473703          	ld	a4,1748(a4) # ffffffffc02b5668 <pmm_manager>
ffffffffc0201f9c:	4505                	li	a0,1
ffffffffc0201f9e:	e43e                	sd	a5,8(sp)
ffffffffc0201fa0:	6f18                	ld	a4,24(a4)
ffffffffc0201fa2:	9702                	jalr	a4
ffffffffc0201fa4:	67a2                	ld	a5,8(sp)
ffffffffc0201fa6:	872a                	mv	a4,a0
ffffffffc0201fa8:	000b3897          	auipc	a7,0xb3
ffffffffc0201fac:	6d888893          	addi	a7,a7,1752 # ffffffffc02b5680 <va_pa_offset>
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0201fb0:	c759                	beqz	a4,ffffffffc020203e <get_pte+0x1a4>
    return page - pages + nbase;
ffffffffc0201fb2:	000b3697          	auipc	a3,0xb3
ffffffffc0201fb6:	6de6b683          	ld	a3,1758(a3) # ffffffffc02b5690 <pages>
ffffffffc0201fba:	00080837          	lui	a6,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0201fbe:	608c                	ld	a1,0(s1)
ffffffffc0201fc0:	40d706b3          	sub	a3,a4,a3
ffffffffc0201fc4:	8699                	srai	a3,a3,0x6
ffffffffc0201fc6:	96c2                	add	a3,a3,a6
ffffffffc0201fc8:	00c69613          	slli	a2,a3,0xc
    page->ref = val;
ffffffffc0201fcc:	4505                	li	a0,1
ffffffffc0201fce:	8231                	srli	a2,a2,0xc
ffffffffc0201fd0:	c308                	sw	a0,0(a4)
    return page2ppn(page) << PGSHIFT;
ffffffffc0201fd2:	06b2                	slli	a3,a3,0xc
ffffffffc0201fd4:	10b67663          	bgeu	a2,a1,ffffffffc02020e0 <get_pte+0x246>
ffffffffc0201fd8:	0008b503          	ld	a0,0(a7)
ffffffffc0201fdc:	6605                	lui	a2,0x1
ffffffffc0201fde:	4581                	li	a1,0
ffffffffc0201fe0:	9536                	add	a0,a0,a3
ffffffffc0201fe2:	e83a                	sd	a4,16(sp)
ffffffffc0201fe4:	e43e                	sd	a5,8(sp)
ffffffffc0201fe6:	14b030ef          	jal	ffffffffc0205930 <memset>
    return page - pages + nbase;
ffffffffc0201fea:	000b3697          	auipc	a3,0xb3
ffffffffc0201fee:	6a66b683          	ld	a3,1702(a3) # ffffffffc02b5690 <pages>
ffffffffc0201ff2:	6742                	ld	a4,16(sp)
ffffffffc0201ff4:	00080837          	lui	a6,0x80
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc0201ff8:	67a2                	ld	a5,8(sp)
ffffffffc0201ffa:	40d706b3          	sub	a3,a4,a3
ffffffffc0201ffe:	8699                	srai	a3,a3,0x6
ffffffffc0202000:	96c2                	add	a3,a3,a6
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202002:	06aa                	slli	a3,a3,0xa
ffffffffc0202004:	0116e693          	ori	a3,a3,17
ffffffffc0202008:	e394                	sd	a3,0(a5)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020200a:	6098                	ld	a4,0(s1)
ffffffffc020200c:	000b3897          	auipc	a7,0xb3
ffffffffc0202010:	67488893          	addi	a7,a7,1652 # ffffffffc02b5680 <va_pa_offset>
ffffffffc0202014:	c006f693          	andi	a3,a3,-1024
ffffffffc0202018:	068a                	slli	a3,a3,0x2
ffffffffc020201a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020201e:	06e7fc63          	bgeu	a5,a4,ffffffffc0202096 <get_pte+0x1fc>
ffffffffc0202022:	0008b783          	ld	a5,0(a7)
ffffffffc0202026:	8031                	srli	s0,s0,0xc
ffffffffc0202028:	1ff47413          	andi	s0,s0,511
ffffffffc020202c:	040e                	slli	s0,s0,0x3
ffffffffc020202e:	96be                	add	a3,a3,a5
}
ffffffffc0202030:	70e2                	ld	ra,56(sp)
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202032:	00868533          	add	a0,a3,s0
}
ffffffffc0202036:	7442                	ld	s0,48(sp)
ffffffffc0202038:	74a2                	ld	s1,40(sp)
ffffffffc020203a:	6121                	addi	sp,sp,64
ffffffffc020203c:	8082                	ret
ffffffffc020203e:	70e2                	ld	ra,56(sp)
ffffffffc0202040:	7442                	ld	s0,48(sp)
ffffffffc0202042:	74a2                	ld	s1,40(sp)
            return NULL;
ffffffffc0202044:	4501                	li	a0,0
}
ffffffffc0202046:	6121                	addi	sp,sp,64
ffffffffc0202048:	8082                	ret
        intr_disable();
ffffffffc020204a:	e83a                	sd	a4,16(sp)
ffffffffc020204c:	ec32                	sd	a2,24(sp)
ffffffffc020204e:	8b1fe0ef          	jal	ffffffffc02008fe <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202052:	000b3797          	auipc	a5,0xb3
ffffffffc0202056:	6167b783          	ld	a5,1558(a5) # ffffffffc02b5668 <pmm_manager>
ffffffffc020205a:	4505                	li	a0,1
ffffffffc020205c:	6f9c                	ld	a5,24(a5)
ffffffffc020205e:	9782                	jalr	a5
ffffffffc0202060:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0202062:	897fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202066:	6862                	ld	a6,24(sp)
ffffffffc0202068:	6742                	ld	a4,16(sp)
ffffffffc020206a:	67a2                	ld	a5,8(sp)
ffffffffc020206c:	bdbd                	j	ffffffffc0201eea <get_pte+0x50>
        intr_disable();
ffffffffc020206e:	e83e                	sd	a5,16(sp)
ffffffffc0202070:	88ffe0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc0202074:	000b3717          	auipc	a4,0xb3
ffffffffc0202078:	5f473703          	ld	a4,1524(a4) # ffffffffc02b5668 <pmm_manager>
ffffffffc020207c:	4505                	li	a0,1
ffffffffc020207e:	6f18                	ld	a4,24(a4)
ffffffffc0202080:	9702                	jalr	a4
ffffffffc0202082:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0202084:	875fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202088:	6722                	ld	a4,8(sp)
ffffffffc020208a:	67c2                	ld	a5,16(sp)
ffffffffc020208c:	000b3897          	auipc	a7,0xb3
ffffffffc0202090:	5f488893          	addi	a7,a7,1524 # ffffffffc02b5680 <va_pa_offset>
ffffffffc0202094:	bf31                	j	ffffffffc0201fb0 <get_pte+0x116>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202096:	00004617          	auipc	a2,0x4
ffffffffc020209a:	6aa60613          	addi	a2,a2,1706 # ffffffffc0206740 <etext+0xde6>
ffffffffc020209e:	0fa00593          	li	a1,250
ffffffffc02020a2:	00004517          	auipc	a0,0x4
ffffffffc02020a6:	78e50513          	addi	a0,a0,1934 # ffffffffc0206830 <etext+0xed6>
ffffffffc02020aa:	ba0fe0ef          	jal	ffffffffc020044a <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02020ae:	00004617          	auipc	a2,0x4
ffffffffc02020b2:	69260613          	addi	a2,a2,1682 # ffffffffc0206740 <etext+0xde6>
ffffffffc02020b6:	0ed00593          	li	a1,237
ffffffffc02020ba:	00004517          	auipc	a0,0x4
ffffffffc02020be:	77650513          	addi	a0,a0,1910 # ffffffffc0206830 <etext+0xed6>
ffffffffc02020c2:	b88fe0ef          	jal	ffffffffc020044a <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020c6:	86aa                	mv	a3,a0
ffffffffc02020c8:	00004617          	auipc	a2,0x4
ffffffffc02020cc:	67860613          	addi	a2,a2,1656 # ffffffffc0206740 <etext+0xde6>
ffffffffc02020d0:	0e900593          	li	a1,233
ffffffffc02020d4:	00004517          	auipc	a0,0x4
ffffffffc02020d8:	75c50513          	addi	a0,a0,1884 # ffffffffc0206830 <etext+0xed6>
ffffffffc02020dc:	b6efe0ef          	jal	ffffffffc020044a <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc02020e0:	00004617          	auipc	a2,0x4
ffffffffc02020e4:	66060613          	addi	a2,a2,1632 # ffffffffc0206740 <etext+0xde6>
ffffffffc02020e8:	0f700593          	li	a1,247
ffffffffc02020ec:	00004517          	auipc	a0,0x4
ffffffffc02020f0:	74450513          	addi	a0,a0,1860 # ffffffffc0206830 <etext+0xed6>
ffffffffc02020f4:	b56fe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02020f8 <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc02020f8:	1141                	addi	sp,sp,-16
ffffffffc02020fa:	e022                	sd	s0,0(sp)
ffffffffc02020fc:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02020fe:	4601                	li	a2,0
{
ffffffffc0202100:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202102:	d99ff0ef          	jal	ffffffffc0201e9a <get_pte>
    if (ptep_store != NULL)
ffffffffc0202106:	c011                	beqz	s0,ffffffffc020210a <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc0202108:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc020210a:	c511                	beqz	a0,ffffffffc0202116 <get_page+0x1e>
ffffffffc020210c:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc020210e:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202110:	0017f713          	andi	a4,a5,1
ffffffffc0202114:	e709                	bnez	a4,ffffffffc020211e <get_page+0x26>
}
ffffffffc0202116:	60a2                	ld	ra,8(sp)
ffffffffc0202118:	6402                	ld	s0,0(sp)
ffffffffc020211a:	0141                	addi	sp,sp,16
ffffffffc020211c:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc020211e:	000b3717          	auipc	a4,0xb3
ffffffffc0202122:	56a73703          	ld	a4,1386(a4) # ffffffffc02b5688 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc0202126:	078a                	slli	a5,a5,0x2
ffffffffc0202128:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020212a:	00e7ff63          	bgeu	a5,a4,ffffffffc0202148 <get_page+0x50>
    return &pages[PPN(pa) - nbase];
ffffffffc020212e:	000b3517          	auipc	a0,0xb3
ffffffffc0202132:	56253503          	ld	a0,1378(a0) # ffffffffc02b5690 <pages>
ffffffffc0202136:	60a2                	ld	ra,8(sp)
ffffffffc0202138:	6402                	ld	s0,0(sp)
ffffffffc020213a:	079a                	slli	a5,a5,0x6
ffffffffc020213c:	fe000737          	lui	a4,0xfe000
ffffffffc0202140:	97ba                	add	a5,a5,a4
ffffffffc0202142:	953e                	add	a0,a0,a5
ffffffffc0202144:	0141                	addi	sp,sp,16
ffffffffc0202146:	8082                	ret
ffffffffc0202148:	c8fff0ef          	jal	ffffffffc0201dd6 <pa2page.part.0>

ffffffffc020214c <unmap_range>:
        tlb_invalidate(pgdir, la); //(6) flush tlb
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc020214c:	715d                	addi	sp,sp,-80
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020214e:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202152:	e486                	sd	ra,72(sp)
ffffffffc0202154:	e0a2                	sd	s0,64(sp)
ffffffffc0202156:	fc26                	sd	s1,56(sp)
ffffffffc0202158:	f84a                	sd	s2,48(sp)
ffffffffc020215a:	f44e                	sd	s3,40(sp)
ffffffffc020215c:	f052                	sd	s4,32(sp)
ffffffffc020215e:	ec56                	sd	s5,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202160:	03479713          	slli	a4,a5,0x34
ffffffffc0202164:	ef61                	bnez	a4,ffffffffc020223c <unmap_range+0xf0>
    assert(USER_ACCESS(start, end));
ffffffffc0202166:	00200a37          	lui	s4,0x200
ffffffffc020216a:	00c5b7b3          	sltu	a5,a1,a2
ffffffffc020216e:	0145b733          	sltu	a4,a1,s4
ffffffffc0202172:	0017b793          	seqz	a5,a5
ffffffffc0202176:	8fd9                	or	a5,a5,a4
ffffffffc0202178:	842e                	mv	s0,a1
ffffffffc020217a:	84b2                	mv	s1,a2
ffffffffc020217c:	e3e5                	bnez	a5,ffffffffc020225c <unmap_range+0x110>
ffffffffc020217e:	4785                	li	a5,1
ffffffffc0202180:	07fe                	slli	a5,a5,0x1f
ffffffffc0202182:	0785                	addi	a5,a5,1
ffffffffc0202184:	892a                	mv	s2,a0
ffffffffc0202186:	6985                	lui	s3,0x1
    do
    {
        pte_t *ptep = get_pte(pgdir, start, 0);
        if (ptep == NULL)
        {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202188:	ffe00ab7          	lui	s5,0xffe00
    assert(USER_ACCESS(start, end));
ffffffffc020218c:	0cf67863          	bgeu	a2,a5,ffffffffc020225c <unmap_range+0x110>
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0202190:	4601                	li	a2,0
ffffffffc0202192:	85a2                	mv	a1,s0
ffffffffc0202194:	854a                	mv	a0,s2
ffffffffc0202196:	d05ff0ef          	jal	ffffffffc0201e9a <get_pte>
ffffffffc020219a:	87aa                	mv	a5,a0
        if (ptep == NULL)
ffffffffc020219c:	cd31                	beqz	a0,ffffffffc02021f8 <unmap_range+0xac>
            continue;
        }
        if (*ptep != 0)
ffffffffc020219e:	6118                	ld	a4,0(a0)
ffffffffc02021a0:	ef11                	bnez	a4,ffffffffc02021bc <unmap_range+0x70>
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc02021a2:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc02021a4:	c019                	beqz	s0,ffffffffc02021aa <unmap_range+0x5e>
ffffffffc02021a6:	fe9465e3          	bltu	s0,s1,ffffffffc0202190 <unmap_range+0x44>
}
ffffffffc02021aa:	60a6                	ld	ra,72(sp)
ffffffffc02021ac:	6406                	ld	s0,64(sp)
ffffffffc02021ae:	74e2                	ld	s1,56(sp)
ffffffffc02021b0:	7942                	ld	s2,48(sp)
ffffffffc02021b2:	79a2                	ld	s3,40(sp)
ffffffffc02021b4:	7a02                	ld	s4,32(sp)
ffffffffc02021b6:	6ae2                	ld	s5,24(sp)
ffffffffc02021b8:	6161                	addi	sp,sp,80
ffffffffc02021ba:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc02021bc:	00177693          	andi	a3,a4,1
ffffffffc02021c0:	d2ed                	beqz	a3,ffffffffc02021a2 <unmap_range+0x56>
    if (PPN(pa) >= npage)
ffffffffc02021c2:	000b3697          	auipc	a3,0xb3
ffffffffc02021c6:	4c66b683          	ld	a3,1222(a3) # ffffffffc02b5688 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc02021ca:	070a                	slli	a4,a4,0x2
ffffffffc02021cc:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc02021ce:	0ad77763          	bgeu	a4,a3,ffffffffc020227c <unmap_range+0x130>
    return &pages[PPN(pa) - nbase];
ffffffffc02021d2:	000b3517          	auipc	a0,0xb3
ffffffffc02021d6:	4be53503          	ld	a0,1214(a0) # ffffffffc02b5690 <pages>
ffffffffc02021da:	071a                	slli	a4,a4,0x6
ffffffffc02021dc:	fe0006b7          	lui	a3,0xfe000
ffffffffc02021e0:	9736                	add	a4,a4,a3
ffffffffc02021e2:	953a                	add	a0,a0,a4
    page->ref -= 1;
ffffffffc02021e4:	4118                	lw	a4,0(a0)
ffffffffc02021e6:	377d                	addiw	a4,a4,-1 # fffffffffdffffff <end+0x3dd4a937>
ffffffffc02021e8:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc02021ea:	cb19                	beqz	a4,ffffffffc0202200 <unmap_range+0xb4>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc02021ec:	0007b023          	sd	zero,0(a5)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02021f0:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc02021f4:	944e                	add	s0,s0,s3
ffffffffc02021f6:	b77d                	j	ffffffffc02021a4 <unmap_range+0x58>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02021f8:	9452                	add	s0,s0,s4
ffffffffc02021fa:	01547433          	and	s0,s0,s5
            continue;
ffffffffc02021fe:	b75d                	j	ffffffffc02021a4 <unmap_range+0x58>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202200:	10002773          	csrr	a4,sstatus
ffffffffc0202204:	8b09                	andi	a4,a4,2
ffffffffc0202206:	eb19                	bnez	a4,ffffffffc020221c <unmap_range+0xd0>
        pmm_manager->free_pages(base, n);
ffffffffc0202208:	000b3717          	auipc	a4,0xb3
ffffffffc020220c:	46073703          	ld	a4,1120(a4) # ffffffffc02b5668 <pmm_manager>
ffffffffc0202210:	4585                	li	a1,1
ffffffffc0202212:	e03e                	sd	a5,0(sp)
ffffffffc0202214:	7318                	ld	a4,32(a4)
ffffffffc0202216:	9702                	jalr	a4
    if (flag)
ffffffffc0202218:	6782                	ld	a5,0(sp)
ffffffffc020221a:	bfc9                	j	ffffffffc02021ec <unmap_range+0xa0>
        intr_disable();
ffffffffc020221c:	e43e                	sd	a5,8(sp)
ffffffffc020221e:	e02a                	sd	a0,0(sp)
ffffffffc0202220:	edefe0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc0202224:	000b3717          	auipc	a4,0xb3
ffffffffc0202228:	44473703          	ld	a4,1092(a4) # ffffffffc02b5668 <pmm_manager>
ffffffffc020222c:	6502                	ld	a0,0(sp)
ffffffffc020222e:	4585                	li	a1,1
ffffffffc0202230:	7318                	ld	a4,32(a4)
ffffffffc0202232:	9702                	jalr	a4
        intr_enable();
ffffffffc0202234:	ec4fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202238:	67a2                	ld	a5,8(sp)
ffffffffc020223a:	bf4d                	j	ffffffffc02021ec <unmap_range+0xa0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020223c:	00004697          	auipc	a3,0x4
ffffffffc0202240:	60468693          	addi	a3,a3,1540 # ffffffffc0206840 <etext+0xee6>
ffffffffc0202244:	00004617          	auipc	a2,0x4
ffffffffc0202248:	14c60613          	addi	a2,a2,332 # ffffffffc0206390 <etext+0xa36>
ffffffffc020224c:	12200593          	li	a1,290
ffffffffc0202250:	00004517          	auipc	a0,0x4
ffffffffc0202254:	5e050513          	addi	a0,a0,1504 # ffffffffc0206830 <etext+0xed6>
ffffffffc0202258:	9f2fe0ef          	jal	ffffffffc020044a <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc020225c:	00004697          	auipc	a3,0x4
ffffffffc0202260:	61468693          	addi	a3,a3,1556 # ffffffffc0206870 <etext+0xf16>
ffffffffc0202264:	00004617          	auipc	a2,0x4
ffffffffc0202268:	12c60613          	addi	a2,a2,300 # ffffffffc0206390 <etext+0xa36>
ffffffffc020226c:	12300593          	li	a1,291
ffffffffc0202270:	00004517          	auipc	a0,0x4
ffffffffc0202274:	5c050513          	addi	a0,a0,1472 # ffffffffc0206830 <etext+0xed6>
ffffffffc0202278:	9d2fe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc020227c:	b5bff0ef          	jal	ffffffffc0201dd6 <pa2page.part.0>

ffffffffc0202280 <exit_range>:
{
ffffffffc0202280:	7135                	addi	sp,sp,-160
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202282:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202286:	ed06                	sd	ra,152(sp)
ffffffffc0202288:	e922                	sd	s0,144(sp)
ffffffffc020228a:	e526                	sd	s1,136(sp)
ffffffffc020228c:	e14a                	sd	s2,128(sp)
ffffffffc020228e:	fcce                	sd	s3,120(sp)
ffffffffc0202290:	f8d2                	sd	s4,112(sp)
ffffffffc0202292:	f4d6                	sd	s5,104(sp)
ffffffffc0202294:	f0da                	sd	s6,96(sp)
ffffffffc0202296:	ecde                	sd	s7,88(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202298:	17d2                	slli	a5,a5,0x34
ffffffffc020229a:	22079263          	bnez	a5,ffffffffc02024be <exit_range+0x23e>
    assert(USER_ACCESS(start, end));
ffffffffc020229e:	00200937          	lui	s2,0x200
ffffffffc02022a2:	00c5b7b3          	sltu	a5,a1,a2
ffffffffc02022a6:	0125b733          	sltu	a4,a1,s2
ffffffffc02022aa:	0017b793          	seqz	a5,a5
ffffffffc02022ae:	8fd9                	or	a5,a5,a4
ffffffffc02022b0:	26079263          	bnez	a5,ffffffffc0202514 <exit_range+0x294>
ffffffffc02022b4:	4785                	li	a5,1
ffffffffc02022b6:	07fe                	slli	a5,a5,0x1f
ffffffffc02022b8:	0785                	addi	a5,a5,1
ffffffffc02022ba:	24f67d63          	bgeu	a2,a5,ffffffffc0202514 <exit_range+0x294>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02022be:	c00004b7          	lui	s1,0xc0000
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02022c2:	ffe007b7          	lui	a5,0xffe00
ffffffffc02022c6:	8a2a                	mv	s4,a0
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc02022c8:	8ced                	and	s1,s1,a1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc02022ca:	00f5f833          	and	a6,a1,a5
    if (PPN(pa) >= npage)
ffffffffc02022ce:	000b3a97          	auipc	s5,0xb3
ffffffffc02022d2:	3baa8a93          	addi	s5,s5,954 # ffffffffc02b5688 <npage>
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc02022d6:	400009b7          	lui	s3,0x40000
ffffffffc02022da:	a809                	j	ffffffffc02022ec <exit_range+0x6c>
        d1start += PDSIZE;
ffffffffc02022dc:	013487b3          	add	a5,s1,s3
ffffffffc02022e0:	400004b7          	lui	s1,0x40000
        d0start = d1start;
ffffffffc02022e4:	8826                	mv	a6,s1
    } while (d1start != 0 && d1start < end);
ffffffffc02022e6:	c3f1                	beqz	a5,ffffffffc02023aa <exit_range+0x12a>
ffffffffc02022e8:	0cc7f163          	bgeu	a5,a2,ffffffffc02023aa <exit_range+0x12a>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc02022ec:	01e4d413          	srli	s0,s1,0x1e
ffffffffc02022f0:	1ff47413          	andi	s0,s0,511
ffffffffc02022f4:	040e                	slli	s0,s0,0x3
ffffffffc02022f6:	9452                	add	s0,s0,s4
ffffffffc02022f8:	00043883          	ld	a7,0(s0)
        if (pde1 & PTE_V)
ffffffffc02022fc:	0018f793          	andi	a5,a7,1
ffffffffc0202300:	dff1                	beqz	a5,ffffffffc02022dc <exit_range+0x5c>
ffffffffc0202302:	000ab783          	ld	a5,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202306:	088a                	slli	a7,a7,0x2
ffffffffc0202308:	00c8d893          	srli	a7,a7,0xc
    if (PPN(pa) >= npage)
ffffffffc020230c:	20f8f263          	bgeu	a7,a5,ffffffffc0202510 <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc0202310:	fff802b7          	lui	t0,0xfff80
ffffffffc0202314:	00588f33          	add	t5,a7,t0
    return page - pages + nbase;
ffffffffc0202318:	000803b7          	lui	t2,0x80
ffffffffc020231c:	007f0733          	add	a4,t5,t2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202320:	00c71e13          	slli	t3,a4,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc0202324:	0f1a                	slli	t5,t5,0x6
    return KADDR(page2pa(page));
ffffffffc0202326:	1cf77863          	bgeu	a4,a5,ffffffffc02024f6 <exit_range+0x276>
ffffffffc020232a:	000b3f97          	auipc	t6,0xb3
ffffffffc020232e:	356f8f93          	addi	t6,t6,854 # ffffffffc02b5680 <va_pa_offset>
ffffffffc0202332:	000fb783          	ld	a5,0(t6)
            free_pd0 = 1;
ffffffffc0202336:	4e85                	li	t4,1
ffffffffc0202338:	6b05                	lui	s6,0x1
ffffffffc020233a:	9e3e                	add	t3,t3,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc020233c:	01348333          	add	t1,s1,s3
                pde0 = pd0[PDX0(d0start)];
ffffffffc0202340:	01585713          	srli	a4,a6,0x15
ffffffffc0202344:	1ff77713          	andi	a4,a4,511
ffffffffc0202348:	070e                	slli	a4,a4,0x3
ffffffffc020234a:	9772                	add	a4,a4,t3
ffffffffc020234c:	631c                	ld	a5,0(a4)
                if (pde0 & PTE_V)
ffffffffc020234e:	0017f693          	andi	a3,a5,1
ffffffffc0202352:	e6bd                	bnez	a3,ffffffffc02023c0 <exit_range+0x140>
                    free_pd0 = 0;
ffffffffc0202354:	4e81                	li	t4,0
                d0start += PTSIZE;
ffffffffc0202356:	984a                	add	a6,a6,s2
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202358:	00080863          	beqz	a6,ffffffffc0202368 <exit_range+0xe8>
ffffffffc020235c:	879a                	mv	a5,t1
ffffffffc020235e:	00667363          	bgeu	a2,t1,ffffffffc0202364 <exit_range+0xe4>
ffffffffc0202362:	87b2                	mv	a5,a2
ffffffffc0202364:	fcf86ee3          	bltu	a6,a5,ffffffffc0202340 <exit_range+0xc0>
            if (free_pd0)
ffffffffc0202368:	f60e8ae3          	beqz	t4,ffffffffc02022dc <exit_range+0x5c>
    if (PPN(pa) >= npage)
ffffffffc020236c:	000ab783          	ld	a5,0(s5)
ffffffffc0202370:	1af8f063          	bgeu	a7,a5,ffffffffc0202510 <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc0202374:	000b3517          	auipc	a0,0xb3
ffffffffc0202378:	31c53503          	ld	a0,796(a0) # ffffffffc02b5690 <pages>
ffffffffc020237c:	957a                	add	a0,a0,t5
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020237e:	100027f3          	csrr	a5,sstatus
ffffffffc0202382:	8b89                	andi	a5,a5,2
ffffffffc0202384:	10079b63          	bnez	a5,ffffffffc020249a <exit_range+0x21a>
        pmm_manager->free_pages(base, n);
ffffffffc0202388:	000b3797          	auipc	a5,0xb3
ffffffffc020238c:	2e07b783          	ld	a5,736(a5) # ffffffffc02b5668 <pmm_manager>
ffffffffc0202390:	4585                	li	a1,1
ffffffffc0202392:	e432                	sd	a2,8(sp)
ffffffffc0202394:	739c                	ld	a5,32(a5)
ffffffffc0202396:	9782                	jalr	a5
ffffffffc0202398:	6622                	ld	a2,8(sp)
                pgdir[PDX1(d1start)] = 0;
ffffffffc020239a:	00043023          	sd	zero,0(s0)
        d1start += PDSIZE;
ffffffffc020239e:	013487b3          	add	a5,s1,s3
ffffffffc02023a2:	400004b7          	lui	s1,0x40000
        d0start = d1start;
ffffffffc02023a6:	8826                	mv	a6,s1
    } while (d1start != 0 && d1start < end);
ffffffffc02023a8:	f3a1                	bnez	a5,ffffffffc02022e8 <exit_range+0x68>
}
ffffffffc02023aa:	60ea                	ld	ra,152(sp)
ffffffffc02023ac:	644a                	ld	s0,144(sp)
ffffffffc02023ae:	64aa                	ld	s1,136(sp)
ffffffffc02023b0:	690a                	ld	s2,128(sp)
ffffffffc02023b2:	79e6                	ld	s3,120(sp)
ffffffffc02023b4:	7a46                	ld	s4,112(sp)
ffffffffc02023b6:	7aa6                	ld	s5,104(sp)
ffffffffc02023b8:	7b06                	ld	s6,96(sp)
ffffffffc02023ba:	6be6                	ld	s7,88(sp)
ffffffffc02023bc:	610d                	addi	sp,sp,160
ffffffffc02023be:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc02023c0:	000ab503          	ld	a0,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc02023c4:	078a                	slli	a5,a5,0x2
ffffffffc02023c6:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02023c8:	14a7f463          	bgeu	a5,a0,ffffffffc0202510 <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc02023cc:	9796                	add	a5,a5,t0
    return page - pages + nbase;
ffffffffc02023ce:	00778bb3          	add	s7,a5,t2
    return &pages[PPN(pa) - nbase];
ffffffffc02023d2:	00679593          	slli	a1,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc02023d6:	00cb9693          	slli	a3,s7,0xc
    return KADDR(page2pa(page));
ffffffffc02023da:	10abf263          	bgeu	s7,a0,ffffffffc02024de <exit_range+0x25e>
ffffffffc02023de:	000fb783          	ld	a5,0(t6)
ffffffffc02023e2:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc02023e4:	01668533          	add	a0,a3,s6
                        if (pt[i] & PTE_V)
ffffffffc02023e8:	629c                	ld	a5,0(a3)
ffffffffc02023ea:	8b85                	andi	a5,a5,1
ffffffffc02023ec:	f7ad                	bnez	a5,ffffffffc0202356 <exit_range+0xd6>
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc02023ee:	06a1                	addi	a3,a3,8
ffffffffc02023f0:	fea69ce3          	bne	a3,a0,ffffffffc02023e8 <exit_range+0x168>
    return &pages[PPN(pa) - nbase];
ffffffffc02023f4:	000b3517          	auipc	a0,0xb3
ffffffffc02023f8:	29c53503          	ld	a0,668(a0) # ffffffffc02b5690 <pages>
ffffffffc02023fc:	952e                	add	a0,a0,a1
ffffffffc02023fe:	100027f3          	csrr	a5,sstatus
ffffffffc0202402:	8b89                	andi	a5,a5,2
ffffffffc0202404:	e3b9                	bnez	a5,ffffffffc020244a <exit_range+0x1ca>
        pmm_manager->free_pages(base, n);
ffffffffc0202406:	000b3797          	auipc	a5,0xb3
ffffffffc020240a:	2627b783          	ld	a5,610(a5) # ffffffffc02b5668 <pmm_manager>
ffffffffc020240e:	4585                	li	a1,1
ffffffffc0202410:	e0b2                	sd	a2,64(sp)
ffffffffc0202412:	739c                	ld	a5,32(a5)
ffffffffc0202414:	fc1a                	sd	t1,56(sp)
ffffffffc0202416:	f846                	sd	a7,48(sp)
ffffffffc0202418:	f47a                	sd	t5,40(sp)
ffffffffc020241a:	f072                	sd	t3,32(sp)
ffffffffc020241c:	ec76                	sd	t4,24(sp)
ffffffffc020241e:	e842                	sd	a6,16(sp)
ffffffffc0202420:	e43a                	sd	a4,8(sp)
ffffffffc0202422:	9782                	jalr	a5
    if (flag)
ffffffffc0202424:	6722                	ld	a4,8(sp)
ffffffffc0202426:	6842                	ld	a6,16(sp)
ffffffffc0202428:	6ee2                	ld	t4,24(sp)
ffffffffc020242a:	7e02                	ld	t3,32(sp)
ffffffffc020242c:	7f22                	ld	t5,40(sp)
ffffffffc020242e:	78c2                	ld	a7,48(sp)
ffffffffc0202430:	7362                	ld	t1,56(sp)
ffffffffc0202432:	6606                	ld	a2,64(sp)
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202434:	fff802b7          	lui	t0,0xfff80
ffffffffc0202438:	000803b7          	lui	t2,0x80
ffffffffc020243c:	000b3f97          	auipc	t6,0xb3
ffffffffc0202440:	244f8f93          	addi	t6,t6,580 # ffffffffc02b5680 <va_pa_offset>
ffffffffc0202444:	00073023          	sd	zero,0(a4)
ffffffffc0202448:	b739                	j	ffffffffc0202356 <exit_range+0xd6>
        intr_disable();
ffffffffc020244a:	e4b2                	sd	a2,72(sp)
ffffffffc020244c:	e09a                	sd	t1,64(sp)
ffffffffc020244e:	fc46                	sd	a7,56(sp)
ffffffffc0202450:	f47a                	sd	t5,40(sp)
ffffffffc0202452:	f072                	sd	t3,32(sp)
ffffffffc0202454:	ec76                	sd	t4,24(sp)
ffffffffc0202456:	e842                	sd	a6,16(sp)
ffffffffc0202458:	e43a                	sd	a4,8(sp)
ffffffffc020245a:	f82a                	sd	a0,48(sp)
ffffffffc020245c:	ca2fe0ef          	jal	ffffffffc02008fe <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202460:	000b3797          	auipc	a5,0xb3
ffffffffc0202464:	2087b783          	ld	a5,520(a5) # ffffffffc02b5668 <pmm_manager>
ffffffffc0202468:	7542                	ld	a0,48(sp)
ffffffffc020246a:	4585                	li	a1,1
ffffffffc020246c:	739c                	ld	a5,32(a5)
ffffffffc020246e:	9782                	jalr	a5
        intr_enable();
ffffffffc0202470:	c88fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202474:	6722                	ld	a4,8(sp)
ffffffffc0202476:	6626                	ld	a2,72(sp)
ffffffffc0202478:	6306                	ld	t1,64(sp)
ffffffffc020247a:	78e2                	ld	a7,56(sp)
ffffffffc020247c:	7f22                	ld	t5,40(sp)
ffffffffc020247e:	7e02                	ld	t3,32(sp)
ffffffffc0202480:	6ee2                	ld	t4,24(sp)
ffffffffc0202482:	6842                	ld	a6,16(sp)
ffffffffc0202484:	000b3f97          	auipc	t6,0xb3
ffffffffc0202488:	1fcf8f93          	addi	t6,t6,508 # ffffffffc02b5680 <va_pa_offset>
ffffffffc020248c:	000803b7          	lui	t2,0x80
ffffffffc0202490:	fff802b7          	lui	t0,0xfff80
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202494:	00073023          	sd	zero,0(a4)
ffffffffc0202498:	bd7d                	j	ffffffffc0202356 <exit_range+0xd6>
        intr_disable();
ffffffffc020249a:	e832                	sd	a2,16(sp)
ffffffffc020249c:	e42a                	sd	a0,8(sp)
ffffffffc020249e:	c60fe0ef          	jal	ffffffffc02008fe <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02024a2:	000b3797          	auipc	a5,0xb3
ffffffffc02024a6:	1c67b783          	ld	a5,454(a5) # ffffffffc02b5668 <pmm_manager>
ffffffffc02024aa:	6522                	ld	a0,8(sp)
ffffffffc02024ac:	4585                	li	a1,1
ffffffffc02024ae:	739c                	ld	a5,32(a5)
ffffffffc02024b0:	9782                	jalr	a5
        intr_enable();
ffffffffc02024b2:	c46fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc02024b6:	6642                	ld	a2,16(sp)
                pgdir[PDX1(d1start)] = 0;
ffffffffc02024b8:	00043023          	sd	zero,0(s0)
ffffffffc02024bc:	b5cd                	j	ffffffffc020239e <exit_range+0x11e>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02024be:	00004697          	auipc	a3,0x4
ffffffffc02024c2:	38268693          	addi	a3,a3,898 # ffffffffc0206840 <etext+0xee6>
ffffffffc02024c6:	00004617          	auipc	a2,0x4
ffffffffc02024ca:	eca60613          	addi	a2,a2,-310 # ffffffffc0206390 <etext+0xa36>
ffffffffc02024ce:	13700593          	li	a1,311
ffffffffc02024d2:	00004517          	auipc	a0,0x4
ffffffffc02024d6:	35e50513          	addi	a0,a0,862 # ffffffffc0206830 <etext+0xed6>
ffffffffc02024da:	f71fd0ef          	jal	ffffffffc020044a <__panic>
    return KADDR(page2pa(page));
ffffffffc02024de:	00004617          	auipc	a2,0x4
ffffffffc02024e2:	26260613          	addi	a2,a2,610 # ffffffffc0206740 <etext+0xde6>
ffffffffc02024e6:	07100593          	li	a1,113
ffffffffc02024ea:	00004517          	auipc	a0,0x4
ffffffffc02024ee:	27e50513          	addi	a0,a0,638 # ffffffffc0206768 <etext+0xe0e>
ffffffffc02024f2:	f59fd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02024f6:	86f2                	mv	a3,t3
ffffffffc02024f8:	00004617          	auipc	a2,0x4
ffffffffc02024fc:	24860613          	addi	a2,a2,584 # ffffffffc0206740 <etext+0xde6>
ffffffffc0202500:	07100593          	li	a1,113
ffffffffc0202504:	00004517          	auipc	a0,0x4
ffffffffc0202508:	26450513          	addi	a0,a0,612 # ffffffffc0206768 <etext+0xe0e>
ffffffffc020250c:	f3ffd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0202510:	8c7ff0ef          	jal	ffffffffc0201dd6 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0202514:	00004697          	auipc	a3,0x4
ffffffffc0202518:	35c68693          	addi	a3,a3,860 # ffffffffc0206870 <etext+0xf16>
ffffffffc020251c:	00004617          	auipc	a2,0x4
ffffffffc0202520:	e7460613          	addi	a2,a2,-396 # ffffffffc0206390 <etext+0xa36>
ffffffffc0202524:	13800593          	li	a1,312
ffffffffc0202528:	00004517          	auipc	a0,0x4
ffffffffc020252c:	30850513          	addi	a0,a0,776 # ffffffffc0206830 <etext+0xed6>
ffffffffc0202530:	f1bfd0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0202534 <copy_range>:
{
ffffffffc0202534:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202536:	00d667b3          	or	a5,a2,a3
{
ffffffffc020253a:	f486                	sd	ra,104(sp)
ffffffffc020253c:	f0a2                	sd	s0,96(sp)
ffffffffc020253e:	eca6                	sd	s1,88(sp)
ffffffffc0202540:	e8ca                	sd	s2,80(sp)
ffffffffc0202542:	e4ce                	sd	s3,72(sp)
ffffffffc0202544:	e0d2                	sd	s4,64(sp)
ffffffffc0202546:	fc56                	sd	s5,56(sp)
ffffffffc0202548:	f85a                	sd	s6,48(sp)
ffffffffc020254a:	f45e                	sd	s7,40(sp)
ffffffffc020254c:	f062                	sd	s8,32(sp)
ffffffffc020254e:	ec66                	sd	s9,24(sp)
ffffffffc0202550:	e86a                	sd	s10,16(sp)
ffffffffc0202552:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202554:	03479713          	slli	a4,a5,0x34
ffffffffc0202558:	18071163          	bnez	a4,ffffffffc02026da <copy_range+0x1a6>
    assert(USER_ACCESS(start, end));
ffffffffc020255c:	00200cb7          	lui	s9,0x200
ffffffffc0202560:	00d637b3          	sltu	a5,a2,a3
ffffffffc0202564:	01963733          	sltu	a4,a2,s9
ffffffffc0202568:	0017b793          	seqz	a5,a5
ffffffffc020256c:	8fd9                	or	a5,a5,a4
ffffffffc020256e:	8432                	mv	s0,a2
ffffffffc0202570:	84b6                	mv	s1,a3
ffffffffc0202572:	14079463          	bnez	a5,ffffffffc02026ba <copy_range+0x186>
ffffffffc0202576:	4785                	li	a5,1
ffffffffc0202578:	07fe                	slli	a5,a5,0x1f
ffffffffc020257a:	0785                	addi	a5,a5,1
ffffffffc020257c:	12f6ff63          	bgeu	a3,a5,ffffffffc02026ba <copy_range+0x186>
ffffffffc0202580:	8aaa                	mv	s5,a0
ffffffffc0202582:	892e                	mv	s2,a1
ffffffffc0202584:	6985                	lui	s3,0x1
    if (PPN(pa) >= npage)
ffffffffc0202586:	000b3c17          	auipc	s8,0xb3
ffffffffc020258a:	102c0c13          	addi	s8,s8,258 # ffffffffc02b5688 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc020258e:	000b3b97          	auipc	s7,0xb3
ffffffffc0202592:	102b8b93          	addi	s7,s7,258 # ffffffffc02b5690 <pages>
ffffffffc0202596:	fff80b37          	lui	s6,0xfff80
        page = pmm_manager->alloc_pages(n);
ffffffffc020259a:	000b3a17          	auipc	s4,0xb3
ffffffffc020259e:	0cea0a13          	addi	s4,s4,206 # ffffffffc02b5668 <pmm_manager>
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02025a2:	4601                	li	a2,0
ffffffffc02025a4:	85a2                	mv	a1,s0
ffffffffc02025a6:	854a                	mv	a0,s2
ffffffffc02025a8:	8f3ff0ef          	jal	ffffffffc0201e9a <get_pte>
ffffffffc02025ac:	8d2a                	mv	s10,a0
        if (ptep == NULL)
ffffffffc02025ae:	cd41                	beqz	a0,ffffffffc0202646 <copy_range+0x112>
        if (*ptep & PTE_V)
ffffffffc02025b0:	611c                	ld	a5,0(a0)
ffffffffc02025b2:	8b85                	andi	a5,a5,1
ffffffffc02025b4:	e78d                	bnez	a5,ffffffffc02025de <copy_range+0xaa>
        start += PGSIZE;
ffffffffc02025b6:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc02025b8:	c019                	beqz	s0,ffffffffc02025be <copy_range+0x8a>
ffffffffc02025ba:	fe9464e3          	bltu	s0,s1,ffffffffc02025a2 <copy_range+0x6e>
    return 0;
ffffffffc02025be:	4501                	li	a0,0
}
ffffffffc02025c0:	70a6                	ld	ra,104(sp)
ffffffffc02025c2:	7406                	ld	s0,96(sp)
ffffffffc02025c4:	64e6                	ld	s1,88(sp)
ffffffffc02025c6:	6946                	ld	s2,80(sp)
ffffffffc02025c8:	69a6                	ld	s3,72(sp)
ffffffffc02025ca:	6a06                	ld	s4,64(sp)
ffffffffc02025cc:	7ae2                	ld	s5,56(sp)
ffffffffc02025ce:	7b42                	ld	s6,48(sp)
ffffffffc02025d0:	7ba2                	ld	s7,40(sp)
ffffffffc02025d2:	7c02                	ld	s8,32(sp)
ffffffffc02025d4:	6ce2                	ld	s9,24(sp)
ffffffffc02025d6:	6d42                	ld	s10,16(sp)
ffffffffc02025d8:	6da2                	ld	s11,8(sp)
ffffffffc02025da:	6165                	addi	sp,sp,112
ffffffffc02025dc:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc02025de:	4605                	li	a2,1
ffffffffc02025e0:	85a2                	mv	a1,s0
ffffffffc02025e2:	8556                	mv	a0,s5
ffffffffc02025e4:	8b7ff0ef          	jal	ffffffffc0201e9a <get_pte>
ffffffffc02025e8:	cd3d                	beqz	a0,ffffffffc0202666 <copy_range+0x132>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc02025ea:	000d3783          	ld	a5,0(s10)
    if (!(pte & PTE_V))
ffffffffc02025ee:	0017f713          	andi	a4,a5,1
ffffffffc02025f2:	cf25                	beqz	a4,ffffffffc020266a <copy_range+0x136>
    if (PPN(pa) >= npage)
ffffffffc02025f4:	000c3703          	ld	a4,0(s8)
    return pa2page(PTE_ADDR(pte));
ffffffffc02025f8:	078a                	slli	a5,a5,0x2
ffffffffc02025fa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02025fc:	0ae7f363          	bgeu	a5,a4,ffffffffc02026a2 <copy_range+0x16e>
    return &pages[PPN(pa) - nbase];
ffffffffc0202600:	000bbd83          	ld	s11,0(s7)
ffffffffc0202604:	97da                	add	a5,a5,s6
ffffffffc0202606:	079a                	slli	a5,a5,0x6
ffffffffc0202608:	9dbe                	add	s11,s11,a5
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020260a:	100027f3          	csrr	a5,sstatus
ffffffffc020260e:	8b89                	andi	a5,a5,2
ffffffffc0202610:	e3a1                	bnez	a5,ffffffffc0202650 <copy_range+0x11c>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202612:	000a3783          	ld	a5,0(s4)
ffffffffc0202616:	4505                	li	a0,1
ffffffffc0202618:	6f9c                	ld	a5,24(a5)
ffffffffc020261a:	9782                	jalr	a5
ffffffffc020261c:	8d2a                	mv	s10,a0
            assert(page != NULL);
ffffffffc020261e:	060d8263          	beqz	s11,ffffffffc0202682 <copy_range+0x14e>
            assert(npage != NULL);
ffffffffc0202622:	f80d1ae3          	bnez	s10,ffffffffc02025b6 <copy_range+0x82>
ffffffffc0202626:	00004697          	auipc	a3,0x4
ffffffffc020262a:	29a68693          	addi	a3,a3,666 # ffffffffc02068c0 <etext+0xf66>
ffffffffc020262e:	00004617          	auipc	a2,0x4
ffffffffc0202632:	d6260613          	addi	a2,a2,-670 # ffffffffc0206390 <etext+0xa36>
ffffffffc0202636:	19700593          	li	a1,407
ffffffffc020263a:	00004517          	auipc	a0,0x4
ffffffffc020263e:	1f650513          	addi	a0,a0,502 # ffffffffc0206830 <etext+0xed6>
ffffffffc0202642:	e09fd0ef          	jal	ffffffffc020044a <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc0202646:	9466                	add	s0,s0,s9
ffffffffc0202648:	ffe007b7          	lui	a5,0xffe00
ffffffffc020264c:	8c7d                	and	s0,s0,a5
            continue;
ffffffffc020264e:	b7ad                	j	ffffffffc02025b8 <copy_range+0x84>
        intr_disable();
ffffffffc0202650:	aaefe0ef          	jal	ffffffffc02008fe <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202654:	000a3783          	ld	a5,0(s4)
ffffffffc0202658:	4505                	li	a0,1
ffffffffc020265a:	6f9c                	ld	a5,24(a5)
ffffffffc020265c:	9782                	jalr	a5
ffffffffc020265e:	8d2a                	mv	s10,a0
        intr_enable();
ffffffffc0202660:	a98fe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202664:	bf6d                	j	ffffffffc020261e <copy_range+0xea>
                return -E_NO_MEM;
ffffffffc0202666:	5571                	li	a0,-4
ffffffffc0202668:	bfa1                	j	ffffffffc02025c0 <copy_range+0x8c>
        panic("pte2page called with invalid pte");
ffffffffc020266a:	00004617          	auipc	a2,0x4
ffffffffc020266e:	21e60613          	addi	a2,a2,542 # ffffffffc0206888 <etext+0xf2e>
ffffffffc0202672:	07f00593          	li	a1,127
ffffffffc0202676:	00004517          	auipc	a0,0x4
ffffffffc020267a:	0f250513          	addi	a0,a0,242 # ffffffffc0206768 <etext+0xe0e>
ffffffffc020267e:	dcdfd0ef          	jal	ffffffffc020044a <__panic>
            assert(page != NULL);
ffffffffc0202682:	00004697          	auipc	a3,0x4
ffffffffc0202686:	22e68693          	addi	a3,a3,558 # ffffffffc02068b0 <etext+0xf56>
ffffffffc020268a:	00004617          	auipc	a2,0x4
ffffffffc020268e:	d0660613          	addi	a2,a2,-762 # ffffffffc0206390 <etext+0xa36>
ffffffffc0202692:	19600593          	li	a1,406
ffffffffc0202696:	00004517          	auipc	a0,0x4
ffffffffc020269a:	19a50513          	addi	a0,a0,410 # ffffffffc0206830 <etext+0xed6>
ffffffffc020269e:	dadfd0ef          	jal	ffffffffc020044a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02026a2:	00004617          	auipc	a2,0x4
ffffffffc02026a6:	16e60613          	addi	a2,a2,366 # ffffffffc0206810 <etext+0xeb6>
ffffffffc02026aa:	06900593          	li	a1,105
ffffffffc02026ae:	00004517          	auipc	a0,0x4
ffffffffc02026b2:	0ba50513          	addi	a0,a0,186 # ffffffffc0206768 <etext+0xe0e>
ffffffffc02026b6:	d95fd0ef          	jal	ffffffffc020044a <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02026ba:	00004697          	auipc	a3,0x4
ffffffffc02026be:	1b668693          	addi	a3,a3,438 # ffffffffc0206870 <etext+0xf16>
ffffffffc02026c2:	00004617          	auipc	a2,0x4
ffffffffc02026c6:	cce60613          	addi	a2,a2,-818 # ffffffffc0206390 <etext+0xa36>
ffffffffc02026ca:	17e00593          	li	a1,382
ffffffffc02026ce:	00004517          	auipc	a0,0x4
ffffffffc02026d2:	16250513          	addi	a0,a0,354 # ffffffffc0206830 <etext+0xed6>
ffffffffc02026d6:	d75fd0ef          	jal	ffffffffc020044a <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02026da:	00004697          	auipc	a3,0x4
ffffffffc02026de:	16668693          	addi	a3,a3,358 # ffffffffc0206840 <etext+0xee6>
ffffffffc02026e2:	00004617          	auipc	a2,0x4
ffffffffc02026e6:	cae60613          	addi	a2,a2,-850 # ffffffffc0206390 <etext+0xa36>
ffffffffc02026ea:	17d00593          	li	a1,381
ffffffffc02026ee:	00004517          	auipc	a0,0x4
ffffffffc02026f2:	14250513          	addi	a0,a0,322 # ffffffffc0206830 <etext+0xed6>
ffffffffc02026f6:	d55fd0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02026fa <page_remove>:
{
ffffffffc02026fa:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02026fc:	4601                	li	a2,0
{
ffffffffc02026fe:	e822                	sd	s0,16(sp)
ffffffffc0202700:	ec06                	sd	ra,24(sp)
ffffffffc0202702:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202704:	f96ff0ef          	jal	ffffffffc0201e9a <get_pte>
    if (ptep != NULL)
ffffffffc0202708:	c511                	beqz	a0,ffffffffc0202714 <page_remove+0x1a>
    if (*ptep & PTE_V)
ffffffffc020270a:	6118                	ld	a4,0(a0)
ffffffffc020270c:	87aa                	mv	a5,a0
ffffffffc020270e:	00177693          	andi	a3,a4,1
ffffffffc0202712:	e689                	bnez	a3,ffffffffc020271c <page_remove+0x22>
}
ffffffffc0202714:	60e2                	ld	ra,24(sp)
ffffffffc0202716:	6442                	ld	s0,16(sp)
ffffffffc0202718:	6105                	addi	sp,sp,32
ffffffffc020271a:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc020271c:	000b3697          	auipc	a3,0xb3
ffffffffc0202720:	f6c6b683          	ld	a3,-148(a3) # ffffffffc02b5688 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc0202724:	070a                	slli	a4,a4,0x2
ffffffffc0202726:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc0202728:	06d77563          	bgeu	a4,a3,ffffffffc0202792 <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc020272c:	000b3517          	auipc	a0,0xb3
ffffffffc0202730:	f6453503          	ld	a0,-156(a0) # ffffffffc02b5690 <pages>
ffffffffc0202734:	071a                	slli	a4,a4,0x6
ffffffffc0202736:	fe0006b7          	lui	a3,0xfe000
ffffffffc020273a:	9736                	add	a4,a4,a3
ffffffffc020273c:	953a                	add	a0,a0,a4
    page->ref -= 1;
ffffffffc020273e:	4118                	lw	a4,0(a0)
ffffffffc0202740:	377d                	addiw	a4,a4,-1
ffffffffc0202742:	c118                	sw	a4,0(a0)
        if (page_ref(page) ==
ffffffffc0202744:	cb09                	beqz	a4,ffffffffc0202756 <page_remove+0x5c>
        *ptep = 0;                 //(5) clear second page table entry
ffffffffc0202746:	0007b023          	sd	zero,0(a5) # ffffffffffe00000 <end+0x3fb4a938>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020274a:	12040073          	sfence.vma	s0
}
ffffffffc020274e:	60e2                	ld	ra,24(sp)
ffffffffc0202750:	6442                	ld	s0,16(sp)
ffffffffc0202752:	6105                	addi	sp,sp,32
ffffffffc0202754:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202756:	10002773          	csrr	a4,sstatus
ffffffffc020275a:	8b09                	andi	a4,a4,2
ffffffffc020275c:	eb19                	bnez	a4,ffffffffc0202772 <page_remove+0x78>
        pmm_manager->free_pages(base, n);
ffffffffc020275e:	000b3717          	auipc	a4,0xb3
ffffffffc0202762:	f0a73703          	ld	a4,-246(a4) # ffffffffc02b5668 <pmm_manager>
ffffffffc0202766:	4585                	li	a1,1
ffffffffc0202768:	e03e                	sd	a5,0(sp)
ffffffffc020276a:	7318                	ld	a4,32(a4)
ffffffffc020276c:	9702                	jalr	a4
    if (flag)
ffffffffc020276e:	6782                	ld	a5,0(sp)
ffffffffc0202770:	bfd9                	j	ffffffffc0202746 <page_remove+0x4c>
        intr_disable();
ffffffffc0202772:	e43e                	sd	a5,8(sp)
ffffffffc0202774:	e02a                	sd	a0,0(sp)
ffffffffc0202776:	988fe0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc020277a:	000b3717          	auipc	a4,0xb3
ffffffffc020277e:	eee73703          	ld	a4,-274(a4) # ffffffffc02b5668 <pmm_manager>
ffffffffc0202782:	6502                	ld	a0,0(sp)
ffffffffc0202784:	4585                	li	a1,1
ffffffffc0202786:	7318                	ld	a4,32(a4)
ffffffffc0202788:	9702                	jalr	a4
        intr_enable();
ffffffffc020278a:	96efe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc020278e:	67a2                	ld	a5,8(sp)
ffffffffc0202790:	bf5d                	j	ffffffffc0202746 <page_remove+0x4c>
ffffffffc0202792:	e44ff0ef          	jal	ffffffffc0201dd6 <pa2page.part.0>

ffffffffc0202796 <page_insert>:
{
ffffffffc0202796:	7139                	addi	sp,sp,-64
ffffffffc0202798:	f426                	sd	s1,40(sp)
ffffffffc020279a:	84b2                	mv	s1,a2
ffffffffc020279c:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020279e:	4605                	li	a2,1
{
ffffffffc02027a0:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02027a2:	85a6                	mv	a1,s1
{
ffffffffc02027a4:	fc06                	sd	ra,56(sp)
ffffffffc02027a6:	e436                	sd	a3,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc02027a8:	ef2ff0ef          	jal	ffffffffc0201e9a <get_pte>
    if (ptep == NULL)
ffffffffc02027ac:	cd61                	beqz	a0,ffffffffc0202884 <page_insert+0xee>
    page->ref += 1;
ffffffffc02027ae:	400c                	lw	a1,0(s0)
    if (*ptep & PTE_V)
ffffffffc02027b0:	611c                	ld	a5,0(a0)
ffffffffc02027b2:	66a2                	ld	a3,8(sp)
ffffffffc02027b4:	0015861b          	addiw	a2,a1,1 # 1001 <_binary_obj___user_softint_out_size-0x7f27>
ffffffffc02027b8:	c010                	sw	a2,0(s0)
ffffffffc02027ba:	0017f613          	andi	a2,a5,1
ffffffffc02027be:	872a                	mv	a4,a0
ffffffffc02027c0:	e61d                	bnez	a2,ffffffffc02027ee <page_insert+0x58>
    return &pages[PPN(pa) - nbase];
ffffffffc02027c2:	000b3617          	auipc	a2,0xb3
ffffffffc02027c6:	ece63603          	ld	a2,-306(a2) # ffffffffc02b5690 <pages>
    return page - pages + nbase;
ffffffffc02027ca:	8c11                	sub	s0,s0,a2
ffffffffc02027cc:	8419                	srai	s0,s0,0x6
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02027ce:	200007b7          	lui	a5,0x20000
ffffffffc02027d2:	042a                	slli	s0,s0,0xa
ffffffffc02027d4:	943e                	add	s0,s0,a5
ffffffffc02027d6:	8ec1                	or	a3,a3,s0
ffffffffc02027d8:	0016e693          	ori	a3,a3,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc02027dc:	e314                	sd	a3,0(a4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02027de:	12048073          	sfence.vma	s1
    return 0;
ffffffffc02027e2:	4501                	li	a0,0
}
ffffffffc02027e4:	70e2                	ld	ra,56(sp)
ffffffffc02027e6:	7442                	ld	s0,48(sp)
ffffffffc02027e8:	74a2                	ld	s1,40(sp)
ffffffffc02027ea:	6121                	addi	sp,sp,64
ffffffffc02027ec:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc02027ee:	000b3617          	auipc	a2,0xb3
ffffffffc02027f2:	e9a63603          	ld	a2,-358(a2) # ffffffffc02b5688 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc02027f6:	078a                	slli	a5,a5,0x2
ffffffffc02027f8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02027fa:	08c7f763          	bgeu	a5,a2,ffffffffc0202888 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc02027fe:	000b3617          	auipc	a2,0xb3
ffffffffc0202802:	e9263603          	ld	a2,-366(a2) # ffffffffc02b5690 <pages>
ffffffffc0202806:	fe000537          	lui	a0,0xfe000
ffffffffc020280a:	079a                	slli	a5,a5,0x6
ffffffffc020280c:	97aa                	add	a5,a5,a0
ffffffffc020280e:	00f60533          	add	a0,a2,a5
        if (p == page)
ffffffffc0202812:	00a40963          	beq	s0,a0,ffffffffc0202824 <page_insert+0x8e>
    page->ref -= 1;
ffffffffc0202816:	411c                	lw	a5,0(a0)
ffffffffc0202818:	37fd                	addiw	a5,a5,-1 # 1fffffff <_binary_obj___user_matrix_out_size+0x1fff4abf>
ffffffffc020281a:	c11c                	sw	a5,0(a0)
        if (page_ref(page) ==
ffffffffc020281c:	c791                	beqz	a5,ffffffffc0202828 <page_insert+0x92>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020281e:	12048073          	sfence.vma	s1
}
ffffffffc0202822:	b765                	j	ffffffffc02027ca <page_insert+0x34>
ffffffffc0202824:	c00c                	sw	a1,0(s0)
    return page->ref;
ffffffffc0202826:	b755                	j	ffffffffc02027ca <page_insert+0x34>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202828:	100027f3          	csrr	a5,sstatus
ffffffffc020282c:	8b89                	andi	a5,a5,2
ffffffffc020282e:	e39d                	bnez	a5,ffffffffc0202854 <page_insert+0xbe>
        pmm_manager->free_pages(base, n);
ffffffffc0202830:	000b3797          	auipc	a5,0xb3
ffffffffc0202834:	e387b783          	ld	a5,-456(a5) # ffffffffc02b5668 <pmm_manager>
ffffffffc0202838:	4585                	li	a1,1
ffffffffc020283a:	e83a                	sd	a4,16(sp)
ffffffffc020283c:	739c                	ld	a5,32(a5)
ffffffffc020283e:	e436                	sd	a3,8(sp)
ffffffffc0202840:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc0202842:	000b3617          	auipc	a2,0xb3
ffffffffc0202846:	e4e63603          	ld	a2,-434(a2) # ffffffffc02b5690 <pages>
ffffffffc020284a:	66a2                	ld	a3,8(sp)
ffffffffc020284c:	6742                	ld	a4,16(sp)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020284e:	12048073          	sfence.vma	s1
ffffffffc0202852:	bfa5                	j	ffffffffc02027ca <page_insert+0x34>
        intr_disable();
ffffffffc0202854:	ec3a                	sd	a4,24(sp)
ffffffffc0202856:	e836                	sd	a3,16(sp)
ffffffffc0202858:	e42a                	sd	a0,8(sp)
ffffffffc020285a:	8a4fe0ef          	jal	ffffffffc02008fe <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020285e:	000b3797          	auipc	a5,0xb3
ffffffffc0202862:	e0a7b783          	ld	a5,-502(a5) # ffffffffc02b5668 <pmm_manager>
ffffffffc0202866:	6522                	ld	a0,8(sp)
ffffffffc0202868:	4585                	li	a1,1
ffffffffc020286a:	739c                	ld	a5,32(a5)
ffffffffc020286c:	9782                	jalr	a5
        intr_enable();
ffffffffc020286e:	88afe0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202872:	000b3617          	auipc	a2,0xb3
ffffffffc0202876:	e1e63603          	ld	a2,-482(a2) # ffffffffc02b5690 <pages>
ffffffffc020287a:	6762                	ld	a4,24(sp)
ffffffffc020287c:	66c2                	ld	a3,16(sp)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020287e:	12048073          	sfence.vma	s1
ffffffffc0202882:	b7a1                	j	ffffffffc02027ca <page_insert+0x34>
        return -E_NO_MEM;
ffffffffc0202884:	5571                	li	a0,-4
ffffffffc0202886:	bfb9                	j	ffffffffc02027e4 <page_insert+0x4e>
ffffffffc0202888:	d4eff0ef          	jal	ffffffffc0201dd6 <pa2page.part.0>

ffffffffc020288c <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc020288c:	00005797          	auipc	a5,0x5
ffffffffc0202890:	fd478793          	addi	a5,a5,-44 # ffffffffc0207860 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202894:	638c                	ld	a1,0(a5)
{
ffffffffc0202896:	7159                	addi	sp,sp,-112
ffffffffc0202898:	f486                	sd	ra,104(sp)
ffffffffc020289a:	e8ca                	sd	s2,80(sp)
ffffffffc020289c:	e4ce                	sd	s3,72(sp)
ffffffffc020289e:	f85a                	sd	s6,48(sp)
ffffffffc02028a0:	f0a2                	sd	s0,96(sp)
ffffffffc02028a2:	eca6                	sd	s1,88(sp)
ffffffffc02028a4:	e0d2                	sd	s4,64(sp)
ffffffffc02028a6:	fc56                	sd	s5,56(sp)
ffffffffc02028a8:	f45e                	sd	s7,40(sp)
ffffffffc02028aa:	f062                	sd	s8,32(sp)
ffffffffc02028ac:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc02028ae:	000b3b17          	auipc	s6,0xb3
ffffffffc02028b2:	dbab0b13          	addi	s6,s6,-582 # ffffffffc02b5668 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02028b6:	00004517          	auipc	a0,0x4
ffffffffc02028ba:	01a50513          	addi	a0,a0,26 # ffffffffc02068d0 <etext+0xf76>
    pmm_manager = &default_pmm_manager;
ffffffffc02028be:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02028c2:	8d7fd0ef          	jal	ffffffffc0200198 <cprintf>
    pmm_manager->init();
ffffffffc02028c6:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02028ca:	000b3997          	auipc	s3,0xb3
ffffffffc02028ce:	db698993          	addi	s3,s3,-586 # ffffffffc02b5680 <va_pa_offset>
    pmm_manager->init();
ffffffffc02028d2:	679c                	ld	a5,8(a5)
ffffffffc02028d4:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02028d6:	57f5                	li	a5,-3
ffffffffc02028d8:	07fa                	slli	a5,a5,0x1e
ffffffffc02028da:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc02028de:	806fe0ef          	jal	ffffffffc02008e4 <get_memory_base>
ffffffffc02028e2:	892a                	mv	s2,a0
    uint64_t mem_size = get_memory_size();
ffffffffc02028e4:	80afe0ef          	jal	ffffffffc02008ee <get_memory_size>
    if (mem_size == 0)
ffffffffc02028e8:	70050e63          	beqz	a0,ffffffffc0203004 <pmm_init+0x778>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc02028ec:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc02028ee:	00004517          	auipc	a0,0x4
ffffffffc02028f2:	01a50513          	addi	a0,a0,26 # ffffffffc0206908 <etext+0xfae>
ffffffffc02028f6:	8a3fd0ef          	jal	ffffffffc0200198 <cprintf>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc02028fa:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02028fe:	864a                	mv	a2,s2
ffffffffc0202900:	85a6                	mv	a1,s1
ffffffffc0202902:	fff40693          	addi	a3,s0,-1
ffffffffc0202906:	00004517          	auipc	a0,0x4
ffffffffc020290a:	01a50513          	addi	a0,a0,26 # ffffffffc0206920 <etext+0xfc6>
ffffffffc020290e:	88bfd0ef          	jal	ffffffffc0200198 <cprintf>
    if (maxpa > KERNTOP)
ffffffffc0202912:	c80007b7          	lui	a5,0xc8000
ffffffffc0202916:	8522                	mv	a0,s0
ffffffffc0202918:	5287ed63          	bltu	a5,s0,ffffffffc0202e52 <pmm_init+0x5c6>
ffffffffc020291c:	77fd                	lui	a5,0xfffff
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020291e:	000b4617          	auipc	a2,0xb4
ffffffffc0202922:	da960613          	addi	a2,a2,-599 # ffffffffc02b66c7 <end+0xfff>
ffffffffc0202926:	8e7d                	and	a2,a2,a5
    npage = maxpa / PGSIZE;
ffffffffc0202928:	8131                	srli	a0,a0,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020292a:	000b3b97          	auipc	s7,0xb3
ffffffffc020292e:	d66b8b93          	addi	s7,s7,-666 # ffffffffc02b5690 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0202932:	000b3497          	auipc	s1,0xb3
ffffffffc0202936:	d5648493          	addi	s1,s1,-682 # ffffffffc02b5688 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020293a:	00cbb023          	sd	a2,0(s7)
    npage = maxpa / PGSIZE;
ffffffffc020293e:	e088                	sd	a0,0(s1)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202940:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202944:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202946:	02f50763          	beq	a0,a5,ffffffffc0202974 <pmm_init+0xe8>
ffffffffc020294a:	4701                	li	a4,0
ffffffffc020294c:	4585                	li	a1,1
ffffffffc020294e:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc0202952:	00671793          	slli	a5,a4,0x6
ffffffffc0202956:	97b2                	add	a5,a5,a2
ffffffffc0202958:	07a1                	addi	a5,a5,8 # 80008 <_binary_obj___user_matrix_out_size+0x74ac8>
ffffffffc020295a:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc020295e:	6088                	ld	a0,0(s1)
ffffffffc0202960:	0705                	addi	a4,a4,1
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202962:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202966:	00d507b3          	add	a5,a0,a3
ffffffffc020296a:	fef764e3          	bltu	a4,a5,ffffffffc0202952 <pmm_init+0xc6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020296e:	079a                	slli	a5,a5,0x6
ffffffffc0202970:	00f606b3          	add	a3,a2,a5
ffffffffc0202974:	c02007b7          	lui	a5,0xc0200
ffffffffc0202978:	16f6eee3          	bltu	a3,a5,ffffffffc02032f4 <pmm_init+0xa68>
ffffffffc020297c:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0202980:	77fd                	lui	a5,0xfffff
ffffffffc0202982:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202984:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc0202986:	4e86ed63          	bltu	a3,s0,ffffffffc0202e80 <pmm_init+0x5f4>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc020298a:	00004517          	auipc	a0,0x4
ffffffffc020298e:	fbe50513          	addi	a0,a0,-66 # ffffffffc0206948 <etext+0xfee>
ffffffffc0202992:	807fd0ef          	jal	ffffffffc0200198 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc0202996:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc020299a:	000b3917          	auipc	s2,0xb3
ffffffffc020299e:	cde90913          	addi	s2,s2,-802 # ffffffffc02b5678 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc02029a2:	7b9c                	ld	a5,48(a5)
ffffffffc02029a4:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc02029a6:	00004517          	auipc	a0,0x4
ffffffffc02029aa:	fba50513          	addi	a0,a0,-70 # ffffffffc0206960 <etext+0x1006>
ffffffffc02029ae:	feafd0ef          	jal	ffffffffc0200198 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc02029b2:	00008697          	auipc	a3,0x8
ffffffffc02029b6:	64e68693          	addi	a3,a3,1614 # ffffffffc020b000 <boot_page_table_sv39>
ffffffffc02029ba:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc02029be:	c02007b7          	lui	a5,0xc0200
ffffffffc02029c2:	2af6eee3          	bltu	a3,a5,ffffffffc020347e <pmm_init+0xbf2>
ffffffffc02029c6:	0009b783          	ld	a5,0(s3)
ffffffffc02029ca:	8e9d                	sub	a3,a3,a5
ffffffffc02029cc:	000b3797          	auipc	a5,0xb3
ffffffffc02029d0:	cad7b223          	sd	a3,-860(a5) # ffffffffc02b5670 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02029d4:	100027f3          	csrr	a5,sstatus
ffffffffc02029d8:	8b89                	andi	a5,a5,2
ffffffffc02029da:	48079963          	bnez	a5,ffffffffc0202e6c <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc02029de:	000b3783          	ld	a5,0(s6)
ffffffffc02029e2:	779c                	ld	a5,40(a5)
ffffffffc02029e4:	9782                	jalr	a5
ffffffffc02029e6:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02029e8:	6098                	ld	a4,0(s1)
ffffffffc02029ea:	c80007b7          	lui	a5,0xc8000
ffffffffc02029ee:	83b1                	srli	a5,a5,0xc
ffffffffc02029f0:	66e7e663          	bltu	a5,a4,ffffffffc020305c <pmm_init+0x7d0>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc02029f4:	00093503          	ld	a0,0(s2)
ffffffffc02029f8:	64050263          	beqz	a0,ffffffffc020303c <pmm_init+0x7b0>
ffffffffc02029fc:	03451793          	slli	a5,a0,0x34
ffffffffc0202a00:	62079e63          	bnez	a5,ffffffffc020303c <pmm_init+0x7b0>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc0202a04:	4601                	li	a2,0
ffffffffc0202a06:	4581                	li	a1,0
ffffffffc0202a08:	ef0ff0ef          	jal	ffffffffc02020f8 <get_page>
ffffffffc0202a0c:	240519e3          	bnez	a0,ffffffffc020345e <pmm_init+0xbd2>
ffffffffc0202a10:	100027f3          	csrr	a5,sstatus
ffffffffc0202a14:	8b89                	andi	a5,a5,2
ffffffffc0202a16:	44079063          	bnez	a5,ffffffffc0202e56 <pmm_init+0x5ca>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202a1a:	000b3783          	ld	a5,0(s6)
ffffffffc0202a1e:	4505                	li	a0,1
ffffffffc0202a20:	6f9c                	ld	a5,24(a5)
ffffffffc0202a22:	9782                	jalr	a5
ffffffffc0202a24:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0202a26:	00093503          	ld	a0,0(s2)
ffffffffc0202a2a:	4681                	li	a3,0
ffffffffc0202a2c:	4601                	li	a2,0
ffffffffc0202a2e:	85d2                	mv	a1,s4
ffffffffc0202a30:	d67ff0ef          	jal	ffffffffc0202796 <page_insert>
ffffffffc0202a34:	280511e3          	bnez	a0,ffffffffc02034b6 <pmm_init+0xc2a>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0202a38:	00093503          	ld	a0,0(s2)
ffffffffc0202a3c:	4601                	li	a2,0
ffffffffc0202a3e:	4581                	li	a1,0
ffffffffc0202a40:	c5aff0ef          	jal	ffffffffc0201e9a <get_pte>
ffffffffc0202a44:	240509e3          	beqz	a0,ffffffffc0203496 <pmm_init+0xc0a>
    assert(pte2page(*ptep) == p1);
ffffffffc0202a48:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202a4a:	0017f713          	andi	a4,a5,1
ffffffffc0202a4e:	58070f63          	beqz	a4,ffffffffc0202fec <pmm_init+0x760>
    if (PPN(pa) >= npage)
ffffffffc0202a52:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202a54:	078a                	slli	a5,a5,0x2
ffffffffc0202a56:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202a58:	58e7f863          	bgeu	a5,a4,ffffffffc0202fe8 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a5c:	000bb683          	ld	a3,0(s7)
ffffffffc0202a60:	079a                	slli	a5,a5,0x6
ffffffffc0202a62:	fe000637          	lui	a2,0xfe000
ffffffffc0202a66:	97b2                	add	a5,a5,a2
ffffffffc0202a68:	97b6                	add	a5,a5,a3
ffffffffc0202a6a:	14fa1ae3          	bne	s4,a5,ffffffffc02033be <pmm_init+0xb32>
    assert(page_ref(p1) == 1);
ffffffffc0202a6e:	000a2683          	lw	a3,0(s4)
ffffffffc0202a72:	4785                	li	a5,1
ffffffffc0202a74:	12f695e3          	bne	a3,a5,ffffffffc020339e <pmm_init+0xb12>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0202a78:	00093503          	ld	a0,0(s2)
ffffffffc0202a7c:	77fd                	lui	a5,0xfffff
ffffffffc0202a7e:	6114                	ld	a3,0(a0)
ffffffffc0202a80:	068a                	slli	a3,a3,0x2
ffffffffc0202a82:	8efd                	and	a3,a3,a5
ffffffffc0202a84:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202a88:	0ee67fe3          	bgeu	a2,a4,ffffffffc0203386 <pmm_init+0xafa>
ffffffffc0202a8c:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202a90:	96e2                	add	a3,a3,s8
ffffffffc0202a92:	0006ba83          	ld	s5,0(a3)
ffffffffc0202a96:	0a8a                	slli	s5,s5,0x2
ffffffffc0202a98:	00fafab3          	and	s5,s5,a5
ffffffffc0202a9c:	00cad793          	srli	a5,s5,0xc
ffffffffc0202aa0:	0ce7f6e3          	bgeu	a5,a4,ffffffffc020336c <pmm_init+0xae0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202aa4:	4601                	li	a2,0
ffffffffc0202aa6:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202aa8:	9c56                	add	s8,s8,s5
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202aaa:	bf0ff0ef          	jal	ffffffffc0201e9a <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202aae:	0c21                	addi	s8,s8,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202ab0:	05851ee3          	bne	a0,s8,ffffffffc020330c <pmm_init+0xa80>
ffffffffc0202ab4:	100027f3          	csrr	a5,sstatus
ffffffffc0202ab8:	8b89                	andi	a5,a5,2
ffffffffc0202aba:	3e079b63          	bnez	a5,ffffffffc0202eb0 <pmm_init+0x624>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202abe:	000b3783          	ld	a5,0(s6)
ffffffffc0202ac2:	4505                	li	a0,1
ffffffffc0202ac4:	6f9c                	ld	a5,24(a5)
ffffffffc0202ac6:	9782                	jalr	a5
ffffffffc0202ac8:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202aca:	00093503          	ld	a0,0(s2)
ffffffffc0202ace:	46d1                	li	a3,20
ffffffffc0202ad0:	6605                	lui	a2,0x1
ffffffffc0202ad2:	85e2                	mv	a1,s8
ffffffffc0202ad4:	cc3ff0ef          	jal	ffffffffc0202796 <page_insert>
ffffffffc0202ad8:	06051ae3          	bnez	a0,ffffffffc020334c <pmm_init+0xac0>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202adc:	00093503          	ld	a0,0(s2)
ffffffffc0202ae0:	4601                	li	a2,0
ffffffffc0202ae2:	6585                	lui	a1,0x1
ffffffffc0202ae4:	bb6ff0ef          	jal	ffffffffc0201e9a <get_pte>
ffffffffc0202ae8:	040502e3          	beqz	a0,ffffffffc020332c <pmm_init+0xaa0>
    assert(*ptep & PTE_U);
ffffffffc0202aec:	611c                	ld	a5,0(a0)
ffffffffc0202aee:	0107f713          	andi	a4,a5,16
ffffffffc0202af2:	7e070163          	beqz	a4,ffffffffc02032d4 <pmm_init+0xa48>
    assert(*ptep & PTE_W);
ffffffffc0202af6:	8b91                	andi	a5,a5,4
ffffffffc0202af8:	7a078e63          	beqz	a5,ffffffffc02032b4 <pmm_init+0xa28>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0202afc:	00093503          	ld	a0,0(s2)
ffffffffc0202b00:	611c                	ld	a5,0(a0)
ffffffffc0202b02:	8bc1                	andi	a5,a5,16
ffffffffc0202b04:	78078863          	beqz	a5,ffffffffc0203294 <pmm_init+0xa08>
    assert(page_ref(p2) == 1);
ffffffffc0202b08:	000c2703          	lw	a4,0(s8)
ffffffffc0202b0c:	4785                	li	a5,1
ffffffffc0202b0e:	76f71363          	bne	a4,a5,ffffffffc0203274 <pmm_init+0x9e8>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0202b12:	4681                	li	a3,0
ffffffffc0202b14:	6605                	lui	a2,0x1
ffffffffc0202b16:	85d2                	mv	a1,s4
ffffffffc0202b18:	c7fff0ef          	jal	ffffffffc0202796 <page_insert>
ffffffffc0202b1c:	72051c63          	bnez	a0,ffffffffc0203254 <pmm_init+0x9c8>
    assert(page_ref(p1) == 2);
ffffffffc0202b20:	000a2703          	lw	a4,0(s4)
ffffffffc0202b24:	4789                	li	a5,2
ffffffffc0202b26:	70f71763          	bne	a4,a5,ffffffffc0203234 <pmm_init+0x9a8>
    assert(page_ref(p2) == 0);
ffffffffc0202b2a:	000c2783          	lw	a5,0(s8)
ffffffffc0202b2e:	6e079363          	bnez	a5,ffffffffc0203214 <pmm_init+0x988>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202b32:	00093503          	ld	a0,0(s2)
ffffffffc0202b36:	4601                	li	a2,0
ffffffffc0202b38:	6585                	lui	a1,0x1
ffffffffc0202b3a:	b60ff0ef          	jal	ffffffffc0201e9a <get_pte>
ffffffffc0202b3e:	6a050b63          	beqz	a0,ffffffffc02031f4 <pmm_init+0x968>
    assert(pte2page(*ptep) == p1);
ffffffffc0202b42:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202b44:	00177793          	andi	a5,a4,1
ffffffffc0202b48:	4a078263          	beqz	a5,ffffffffc0202fec <pmm_init+0x760>
    if (PPN(pa) >= npage)
ffffffffc0202b4c:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202b4e:	00271793          	slli	a5,a4,0x2
ffffffffc0202b52:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b54:	48d7fa63          	bgeu	a5,a3,ffffffffc0202fe8 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b58:	000bb683          	ld	a3,0(s7)
ffffffffc0202b5c:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202b60:	97d6                	add	a5,a5,s5
ffffffffc0202b62:	079a                	slli	a5,a5,0x6
ffffffffc0202b64:	97b6                	add	a5,a5,a3
ffffffffc0202b66:	66fa1763          	bne	s4,a5,ffffffffc02031d4 <pmm_init+0x948>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202b6a:	8b41                	andi	a4,a4,16
ffffffffc0202b6c:	64071463          	bnez	a4,ffffffffc02031b4 <pmm_init+0x928>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc0202b70:	00093503          	ld	a0,0(s2)
ffffffffc0202b74:	4581                	li	a1,0
ffffffffc0202b76:	b85ff0ef          	jal	ffffffffc02026fa <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202b7a:	000a2c83          	lw	s9,0(s4)
ffffffffc0202b7e:	4785                	li	a5,1
ffffffffc0202b80:	60fc9a63          	bne	s9,a5,ffffffffc0203194 <pmm_init+0x908>
    assert(page_ref(p2) == 0);
ffffffffc0202b84:	000c2783          	lw	a5,0(s8)
ffffffffc0202b88:	5e079663          	bnez	a5,ffffffffc0203174 <pmm_init+0x8e8>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc0202b8c:	00093503          	ld	a0,0(s2)
ffffffffc0202b90:	6585                	lui	a1,0x1
ffffffffc0202b92:	b69ff0ef          	jal	ffffffffc02026fa <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202b96:	000a2783          	lw	a5,0(s4)
ffffffffc0202b9a:	52079d63          	bnez	a5,ffffffffc02030d4 <pmm_init+0x848>
    assert(page_ref(p2) == 0);
ffffffffc0202b9e:	000c2783          	lw	a5,0(s8)
ffffffffc0202ba2:	50079963          	bnez	a5,ffffffffc02030b4 <pmm_init+0x828>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202ba6:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202baa:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202bac:	000a3783          	ld	a5,0(s4)
ffffffffc0202bb0:	078a                	slli	a5,a5,0x2
ffffffffc0202bb2:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202bb4:	42e7fa63          	bgeu	a5,a4,ffffffffc0202fe8 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202bb8:	000bb503          	ld	a0,0(s7)
ffffffffc0202bbc:	97d6                	add	a5,a5,s5
ffffffffc0202bbe:	079a                	slli	a5,a5,0x6
    return page->ref;
ffffffffc0202bc0:	00f506b3          	add	a3,a0,a5
ffffffffc0202bc4:	4294                	lw	a3,0(a3)
ffffffffc0202bc6:	4d969763          	bne	a3,s9,ffffffffc0203094 <pmm_init+0x808>
    return page - pages + nbase;
ffffffffc0202bca:	8799                	srai	a5,a5,0x6
ffffffffc0202bcc:	00080637          	lui	a2,0x80
ffffffffc0202bd0:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202bd2:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202bd6:	4ae7f363          	bgeu	a5,a4,ffffffffc020307c <pmm_init+0x7f0>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202bda:	0009b783          	ld	a5,0(s3)
ffffffffc0202bde:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0202be0:	639c                	ld	a5,0(a5)
ffffffffc0202be2:	078a                	slli	a5,a5,0x2
ffffffffc0202be4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202be6:	40e7f163          	bgeu	a5,a4,ffffffffc0202fe8 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202bea:	8f91                	sub	a5,a5,a2
ffffffffc0202bec:	079a                	slli	a5,a5,0x6
ffffffffc0202bee:	953e                	add	a0,a0,a5
ffffffffc0202bf0:	100027f3          	csrr	a5,sstatus
ffffffffc0202bf4:	8b89                	andi	a5,a5,2
ffffffffc0202bf6:	30079863          	bnez	a5,ffffffffc0202f06 <pmm_init+0x67a>
        pmm_manager->free_pages(base, n);
ffffffffc0202bfa:	000b3783          	ld	a5,0(s6)
ffffffffc0202bfe:	4585                	li	a1,1
ffffffffc0202c00:	739c                	ld	a5,32(a5)
ffffffffc0202c02:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202c04:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202c08:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202c0a:	078a                	slli	a5,a5,0x2
ffffffffc0202c0c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202c0e:	3ce7fd63          	bgeu	a5,a4,ffffffffc0202fe8 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202c12:	000bb503          	ld	a0,0(s7)
ffffffffc0202c16:	fe000737          	lui	a4,0xfe000
ffffffffc0202c1a:	079a                	slli	a5,a5,0x6
ffffffffc0202c1c:	97ba                	add	a5,a5,a4
ffffffffc0202c1e:	953e                	add	a0,a0,a5
ffffffffc0202c20:	100027f3          	csrr	a5,sstatus
ffffffffc0202c24:	8b89                	andi	a5,a5,2
ffffffffc0202c26:	2c079463          	bnez	a5,ffffffffc0202eee <pmm_init+0x662>
ffffffffc0202c2a:	000b3783          	ld	a5,0(s6)
ffffffffc0202c2e:	4585                	li	a1,1
ffffffffc0202c30:	739c                	ld	a5,32(a5)
ffffffffc0202c32:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202c34:	00093783          	ld	a5,0(s2)
ffffffffc0202c38:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd49938>
    asm volatile("sfence.vma");
ffffffffc0202c3c:	12000073          	sfence.vma
ffffffffc0202c40:	100027f3          	csrr	a5,sstatus
ffffffffc0202c44:	8b89                	andi	a5,a5,2
ffffffffc0202c46:	28079a63          	bnez	a5,ffffffffc0202eda <pmm_init+0x64e>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202c4a:	000b3783          	ld	a5,0(s6)
ffffffffc0202c4e:	779c                	ld	a5,40(a5)
ffffffffc0202c50:	9782                	jalr	a5
ffffffffc0202c52:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202c54:	4d441063          	bne	s0,s4,ffffffffc0203114 <pmm_init+0x888>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202c58:	00004517          	auipc	a0,0x4
ffffffffc0202c5c:	03050513          	addi	a0,a0,48 # ffffffffc0206c88 <etext+0x132e>
ffffffffc0202c60:	d38fd0ef          	jal	ffffffffc0200198 <cprintf>
ffffffffc0202c64:	100027f3          	csrr	a5,sstatus
ffffffffc0202c68:	8b89                	andi	a5,a5,2
ffffffffc0202c6a:	24079e63          	bnez	a5,ffffffffc0202ec6 <pmm_init+0x63a>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202c6e:	000b3783          	ld	a5,0(s6)
ffffffffc0202c72:	779c                	ld	a5,40(a5)
ffffffffc0202c74:	9782                	jalr	a5
ffffffffc0202c76:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202c78:	609c                	ld	a5,0(s1)
ffffffffc0202c7a:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202c7e:	7a7d                	lui	s4,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202c80:	00c79713          	slli	a4,a5,0xc
ffffffffc0202c84:	6a85                	lui	s5,0x1
ffffffffc0202c86:	02e47c63          	bgeu	s0,a4,ffffffffc0202cbe <pmm_init+0x432>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202c8a:	00c45713          	srli	a4,s0,0xc
ffffffffc0202c8e:	30f77063          	bgeu	a4,a5,ffffffffc0202f8e <pmm_init+0x702>
ffffffffc0202c92:	0009b583          	ld	a1,0(s3)
ffffffffc0202c96:	00093503          	ld	a0,0(s2)
ffffffffc0202c9a:	4601                	li	a2,0
ffffffffc0202c9c:	95a2                	add	a1,a1,s0
ffffffffc0202c9e:	9fcff0ef          	jal	ffffffffc0201e9a <get_pte>
ffffffffc0202ca2:	32050363          	beqz	a0,ffffffffc0202fc8 <pmm_init+0x73c>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202ca6:	611c                	ld	a5,0(a0)
ffffffffc0202ca8:	078a                	slli	a5,a5,0x2
ffffffffc0202caa:	0147f7b3          	and	a5,a5,s4
ffffffffc0202cae:	2e879d63          	bne	a5,s0,ffffffffc0202fa8 <pmm_init+0x71c>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202cb2:	609c                	ld	a5,0(s1)
ffffffffc0202cb4:	9456                	add	s0,s0,s5
ffffffffc0202cb6:	00c79713          	slli	a4,a5,0xc
ffffffffc0202cba:	fce468e3          	bltu	s0,a4,ffffffffc0202c8a <pmm_init+0x3fe>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc0202cbe:	00093783          	ld	a5,0(s2)
ffffffffc0202cc2:	639c                	ld	a5,0(a5)
ffffffffc0202cc4:	42079863          	bnez	a5,ffffffffc02030f4 <pmm_init+0x868>
ffffffffc0202cc8:	100027f3          	csrr	a5,sstatus
ffffffffc0202ccc:	8b89                	andi	a5,a5,2
ffffffffc0202cce:	24079863          	bnez	a5,ffffffffc0202f1e <pmm_init+0x692>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202cd2:	000b3783          	ld	a5,0(s6)
ffffffffc0202cd6:	4505                	li	a0,1
ffffffffc0202cd8:	6f9c                	ld	a5,24(a5)
ffffffffc0202cda:	9782                	jalr	a5
ffffffffc0202cdc:	842a                	mv	s0,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202cde:	00093503          	ld	a0,0(s2)
ffffffffc0202ce2:	4699                	li	a3,6
ffffffffc0202ce4:	10000613          	li	a2,256
ffffffffc0202ce8:	85a2                	mv	a1,s0
ffffffffc0202cea:	aadff0ef          	jal	ffffffffc0202796 <page_insert>
ffffffffc0202cee:	46051363          	bnez	a0,ffffffffc0203154 <pmm_init+0x8c8>
    assert(page_ref(p) == 1);
ffffffffc0202cf2:	4018                	lw	a4,0(s0)
ffffffffc0202cf4:	4785                	li	a5,1
ffffffffc0202cf6:	42f71f63          	bne	a4,a5,ffffffffc0203134 <pmm_init+0x8a8>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202cfa:	00093503          	ld	a0,0(s2)
ffffffffc0202cfe:	6605                	lui	a2,0x1
ffffffffc0202d00:	10060613          	addi	a2,a2,256 # 1100 <_binary_obj___user_softint_out_size-0x7e28>
ffffffffc0202d04:	4699                	li	a3,6
ffffffffc0202d06:	85a2                	mv	a1,s0
ffffffffc0202d08:	a8fff0ef          	jal	ffffffffc0202796 <page_insert>
ffffffffc0202d0c:	72051963          	bnez	a0,ffffffffc020343e <pmm_init+0xbb2>
    assert(page_ref(p) == 2);
ffffffffc0202d10:	4018                	lw	a4,0(s0)
ffffffffc0202d12:	4789                	li	a5,2
ffffffffc0202d14:	70f71563          	bne	a4,a5,ffffffffc020341e <pmm_init+0xb92>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202d18:	00004597          	auipc	a1,0x4
ffffffffc0202d1c:	0b858593          	addi	a1,a1,184 # ffffffffc0206dd0 <etext+0x1476>
ffffffffc0202d20:	10000513          	li	a0,256
ffffffffc0202d24:	38d020ef          	jal	ffffffffc02058b0 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202d28:	6585                	lui	a1,0x1
ffffffffc0202d2a:	10058593          	addi	a1,a1,256 # 1100 <_binary_obj___user_softint_out_size-0x7e28>
ffffffffc0202d2e:	10000513          	li	a0,256
ffffffffc0202d32:	391020ef          	jal	ffffffffc02058c2 <strcmp>
ffffffffc0202d36:	6c051463          	bnez	a0,ffffffffc02033fe <pmm_init+0xb72>
    return page - pages + nbase;
ffffffffc0202d3a:	000bb683          	ld	a3,0(s7)
ffffffffc0202d3e:	000807b7          	lui	a5,0x80
    return KADDR(page2pa(page));
ffffffffc0202d42:	6098                	ld	a4,0(s1)
    return page - pages + nbase;
ffffffffc0202d44:	40d406b3          	sub	a3,s0,a3
ffffffffc0202d48:	8699                	srai	a3,a3,0x6
ffffffffc0202d4a:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0202d4c:	00c69793          	slli	a5,a3,0xc
ffffffffc0202d50:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d52:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202d54:	32e7f463          	bgeu	a5,a4,ffffffffc020307c <pmm_init+0x7f0>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202d58:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202d5c:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202d60:	97b6                	add	a5,a5,a3
ffffffffc0202d62:	10078023          	sb	zero,256(a5) # 80100 <_binary_obj___user_matrix_out_size+0x74bc0>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202d66:	317020ef          	jal	ffffffffc020587c <strlen>
ffffffffc0202d6a:	66051a63          	bnez	a0,ffffffffc02033de <pmm_init+0xb52>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0202d6e:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202d72:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d74:	000a3783          	ld	a5,0(s4) # fffffffffffff000 <end+0x3fd49938>
ffffffffc0202d78:	078a                	slli	a5,a5,0x2
ffffffffc0202d7a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202d7c:	26e7f663          	bgeu	a5,a4,ffffffffc0202fe8 <pmm_init+0x75c>
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d80:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202d84:	2ee7fc63          	bgeu	a5,a4,ffffffffc020307c <pmm_init+0x7f0>
ffffffffc0202d88:	0009b783          	ld	a5,0(s3)
ffffffffc0202d8c:	00f689b3          	add	s3,a3,a5
ffffffffc0202d90:	100027f3          	csrr	a5,sstatus
ffffffffc0202d94:	8b89                	andi	a5,a5,2
ffffffffc0202d96:	1e079163          	bnez	a5,ffffffffc0202f78 <pmm_init+0x6ec>
        pmm_manager->free_pages(base, n);
ffffffffc0202d9a:	000b3783          	ld	a5,0(s6)
ffffffffc0202d9e:	8522                	mv	a0,s0
ffffffffc0202da0:	4585                	li	a1,1
ffffffffc0202da2:	739c                	ld	a5,32(a5)
ffffffffc0202da4:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202da6:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage)
ffffffffc0202daa:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202dac:	078a                	slli	a5,a5,0x2
ffffffffc0202dae:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202db0:	22e7fc63          	bgeu	a5,a4,ffffffffc0202fe8 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202db4:	000bb503          	ld	a0,0(s7)
ffffffffc0202db8:	fe000737          	lui	a4,0xfe000
ffffffffc0202dbc:	079a                	slli	a5,a5,0x6
ffffffffc0202dbe:	97ba                	add	a5,a5,a4
ffffffffc0202dc0:	953e                	add	a0,a0,a5
ffffffffc0202dc2:	100027f3          	csrr	a5,sstatus
ffffffffc0202dc6:	8b89                	andi	a5,a5,2
ffffffffc0202dc8:	18079c63          	bnez	a5,ffffffffc0202f60 <pmm_init+0x6d4>
ffffffffc0202dcc:	000b3783          	ld	a5,0(s6)
ffffffffc0202dd0:	4585                	li	a1,1
ffffffffc0202dd2:	739c                	ld	a5,32(a5)
ffffffffc0202dd4:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202dd6:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202dda:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202ddc:	078a                	slli	a5,a5,0x2
ffffffffc0202dde:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202de0:	20e7f463          	bgeu	a5,a4,ffffffffc0202fe8 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202de4:	000bb503          	ld	a0,0(s7)
ffffffffc0202de8:	fe000737          	lui	a4,0xfe000
ffffffffc0202dec:	079a                	slli	a5,a5,0x6
ffffffffc0202dee:	97ba                	add	a5,a5,a4
ffffffffc0202df0:	953e                	add	a0,a0,a5
ffffffffc0202df2:	100027f3          	csrr	a5,sstatus
ffffffffc0202df6:	8b89                	andi	a5,a5,2
ffffffffc0202df8:	14079863          	bnez	a5,ffffffffc0202f48 <pmm_init+0x6bc>
ffffffffc0202dfc:	000b3783          	ld	a5,0(s6)
ffffffffc0202e00:	4585                	li	a1,1
ffffffffc0202e02:	739c                	ld	a5,32(a5)
ffffffffc0202e04:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202e06:	00093783          	ld	a5,0(s2)
ffffffffc0202e0a:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0202e0e:	12000073          	sfence.vma
ffffffffc0202e12:	100027f3          	csrr	a5,sstatus
ffffffffc0202e16:	8b89                	andi	a5,a5,2
ffffffffc0202e18:	10079e63          	bnez	a5,ffffffffc0202f34 <pmm_init+0x6a8>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202e1c:	000b3783          	ld	a5,0(s6)
ffffffffc0202e20:	779c                	ld	a5,40(a5)
ffffffffc0202e22:	9782                	jalr	a5
ffffffffc0202e24:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202e26:	1e8c1b63          	bne	s8,s0,ffffffffc020301c <pmm_init+0x790>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202e2a:	00004517          	auipc	a0,0x4
ffffffffc0202e2e:	01e50513          	addi	a0,a0,30 # ffffffffc0206e48 <etext+0x14ee>
ffffffffc0202e32:	b66fd0ef          	jal	ffffffffc0200198 <cprintf>
}
ffffffffc0202e36:	7406                	ld	s0,96(sp)
ffffffffc0202e38:	70a6                	ld	ra,104(sp)
ffffffffc0202e3a:	64e6                	ld	s1,88(sp)
ffffffffc0202e3c:	6946                	ld	s2,80(sp)
ffffffffc0202e3e:	69a6                	ld	s3,72(sp)
ffffffffc0202e40:	6a06                	ld	s4,64(sp)
ffffffffc0202e42:	7ae2                	ld	s5,56(sp)
ffffffffc0202e44:	7b42                	ld	s6,48(sp)
ffffffffc0202e46:	7ba2                	ld	s7,40(sp)
ffffffffc0202e48:	7c02                	ld	s8,32(sp)
ffffffffc0202e4a:	6ce2                	ld	s9,24(sp)
ffffffffc0202e4c:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0202e4e:	dbffe06f          	j	ffffffffc0201c0c <kmalloc_init>
    if (maxpa > KERNTOP)
ffffffffc0202e52:	853e                	mv	a0,a5
ffffffffc0202e54:	b4e1                	j	ffffffffc020291c <pmm_init+0x90>
        intr_disable();
ffffffffc0202e56:	aa9fd0ef          	jal	ffffffffc02008fe <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202e5a:	000b3783          	ld	a5,0(s6)
ffffffffc0202e5e:	4505                	li	a0,1
ffffffffc0202e60:	6f9c                	ld	a5,24(a5)
ffffffffc0202e62:	9782                	jalr	a5
ffffffffc0202e64:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202e66:	a93fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202e6a:	be75                	j	ffffffffc0202a26 <pmm_init+0x19a>
        intr_disable();
ffffffffc0202e6c:	a93fd0ef          	jal	ffffffffc02008fe <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202e70:	000b3783          	ld	a5,0(s6)
ffffffffc0202e74:	779c                	ld	a5,40(a5)
ffffffffc0202e76:	9782                	jalr	a5
ffffffffc0202e78:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202e7a:	a7ffd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202e7e:	b6ad                	j	ffffffffc02029e8 <pmm_init+0x15c>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202e80:	6705                	lui	a4,0x1
ffffffffc0202e82:	177d                	addi	a4,a4,-1 # fff <_binary_obj___user_softint_out_size-0x7f29>
ffffffffc0202e84:	96ba                	add	a3,a3,a4
ffffffffc0202e86:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc0202e88:	00c7d713          	srli	a4,a5,0xc
ffffffffc0202e8c:	14a77e63          	bgeu	a4,a0,ffffffffc0202fe8 <pmm_init+0x75c>
    pmm_manager->init_memmap(base, n);
ffffffffc0202e90:	000b3683          	ld	a3,0(s6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202e94:	8c1d                	sub	s0,s0,a5
    return &pages[PPN(pa) - nbase];
ffffffffc0202e96:	071a                	slli	a4,a4,0x6
ffffffffc0202e98:	fe0007b7          	lui	a5,0xfe000
ffffffffc0202e9c:	973e                	add	a4,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0202e9e:	6a9c                	ld	a5,16(a3)
ffffffffc0202ea0:	00c45593          	srli	a1,s0,0xc
ffffffffc0202ea4:	00e60533          	add	a0,a2,a4
ffffffffc0202ea8:	9782                	jalr	a5
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202eaa:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202eae:	bcf1                	j	ffffffffc020298a <pmm_init+0xfe>
        intr_disable();
ffffffffc0202eb0:	a4ffd0ef          	jal	ffffffffc02008fe <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202eb4:	000b3783          	ld	a5,0(s6)
ffffffffc0202eb8:	4505                	li	a0,1
ffffffffc0202eba:	6f9c                	ld	a5,24(a5)
ffffffffc0202ebc:	9782                	jalr	a5
ffffffffc0202ebe:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202ec0:	a39fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202ec4:	b119                	j	ffffffffc0202aca <pmm_init+0x23e>
        intr_disable();
ffffffffc0202ec6:	a39fd0ef          	jal	ffffffffc02008fe <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202eca:	000b3783          	ld	a5,0(s6)
ffffffffc0202ece:	779c                	ld	a5,40(a5)
ffffffffc0202ed0:	9782                	jalr	a5
ffffffffc0202ed2:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202ed4:	a25fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202ed8:	b345                	j	ffffffffc0202c78 <pmm_init+0x3ec>
        intr_disable();
ffffffffc0202eda:	a25fd0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc0202ede:	000b3783          	ld	a5,0(s6)
ffffffffc0202ee2:	779c                	ld	a5,40(a5)
ffffffffc0202ee4:	9782                	jalr	a5
ffffffffc0202ee6:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202ee8:	a11fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202eec:	b3a5                	j	ffffffffc0202c54 <pmm_init+0x3c8>
ffffffffc0202eee:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202ef0:	a0ffd0ef          	jal	ffffffffc02008fe <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202ef4:	000b3783          	ld	a5,0(s6)
ffffffffc0202ef8:	6522                	ld	a0,8(sp)
ffffffffc0202efa:	4585                	li	a1,1
ffffffffc0202efc:	739c                	ld	a5,32(a5)
ffffffffc0202efe:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f00:	9f9fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202f04:	bb05                	j	ffffffffc0202c34 <pmm_init+0x3a8>
ffffffffc0202f06:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202f08:	9f7fd0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc0202f0c:	000b3783          	ld	a5,0(s6)
ffffffffc0202f10:	6522                	ld	a0,8(sp)
ffffffffc0202f12:	4585                	li	a1,1
ffffffffc0202f14:	739c                	ld	a5,32(a5)
ffffffffc0202f16:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f18:	9e1fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202f1c:	b1e5                	j	ffffffffc0202c04 <pmm_init+0x378>
        intr_disable();
ffffffffc0202f1e:	9e1fd0ef          	jal	ffffffffc02008fe <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202f22:	000b3783          	ld	a5,0(s6)
ffffffffc0202f26:	4505                	li	a0,1
ffffffffc0202f28:	6f9c                	ld	a5,24(a5)
ffffffffc0202f2a:	9782                	jalr	a5
ffffffffc0202f2c:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202f2e:	9cbfd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202f32:	b375                	j	ffffffffc0202cde <pmm_init+0x452>
        intr_disable();
ffffffffc0202f34:	9cbfd0ef          	jal	ffffffffc02008fe <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202f38:	000b3783          	ld	a5,0(s6)
ffffffffc0202f3c:	779c                	ld	a5,40(a5)
ffffffffc0202f3e:	9782                	jalr	a5
ffffffffc0202f40:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202f42:	9b7fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202f46:	b5c5                	j	ffffffffc0202e26 <pmm_init+0x59a>
ffffffffc0202f48:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202f4a:	9b5fd0ef          	jal	ffffffffc02008fe <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202f4e:	000b3783          	ld	a5,0(s6)
ffffffffc0202f52:	6522                	ld	a0,8(sp)
ffffffffc0202f54:	4585                	li	a1,1
ffffffffc0202f56:	739c                	ld	a5,32(a5)
ffffffffc0202f58:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f5a:	99ffd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202f5e:	b565                	j	ffffffffc0202e06 <pmm_init+0x57a>
ffffffffc0202f60:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202f62:	99dfd0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc0202f66:	000b3783          	ld	a5,0(s6)
ffffffffc0202f6a:	6522                	ld	a0,8(sp)
ffffffffc0202f6c:	4585                	li	a1,1
ffffffffc0202f6e:	739c                	ld	a5,32(a5)
ffffffffc0202f70:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f72:	987fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202f76:	b585                	j	ffffffffc0202dd6 <pmm_init+0x54a>
        intr_disable();
ffffffffc0202f78:	987fd0ef          	jal	ffffffffc02008fe <intr_disable>
ffffffffc0202f7c:	000b3783          	ld	a5,0(s6)
ffffffffc0202f80:	8522                	mv	a0,s0
ffffffffc0202f82:	4585                	li	a1,1
ffffffffc0202f84:	739c                	ld	a5,32(a5)
ffffffffc0202f86:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f88:	971fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0202f8c:	bd29                	j	ffffffffc0202da6 <pmm_init+0x51a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202f8e:	86a2                	mv	a3,s0
ffffffffc0202f90:	00003617          	auipc	a2,0x3
ffffffffc0202f94:	7b060613          	addi	a2,a2,1968 # ffffffffc0206740 <etext+0xde6>
ffffffffc0202f98:	25000593          	li	a1,592
ffffffffc0202f9c:	00004517          	auipc	a0,0x4
ffffffffc0202fa0:	89450513          	addi	a0,a0,-1900 # ffffffffc0206830 <etext+0xed6>
ffffffffc0202fa4:	ca6fd0ef          	jal	ffffffffc020044a <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202fa8:	00004697          	auipc	a3,0x4
ffffffffc0202fac:	d4068693          	addi	a3,a3,-704 # ffffffffc0206ce8 <etext+0x138e>
ffffffffc0202fb0:	00003617          	auipc	a2,0x3
ffffffffc0202fb4:	3e060613          	addi	a2,a2,992 # ffffffffc0206390 <etext+0xa36>
ffffffffc0202fb8:	25100593          	li	a1,593
ffffffffc0202fbc:	00004517          	auipc	a0,0x4
ffffffffc0202fc0:	87450513          	addi	a0,a0,-1932 # ffffffffc0206830 <etext+0xed6>
ffffffffc0202fc4:	c86fd0ef          	jal	ffffffffc020044a <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202fc8:	00004697          	auipc	a3,0x4
ffffffffc0202fcc:	ce068693          	addi	a3,a3,-800 # ffffffffc0206ca8 <etext+0x134e>
ffffffffc0202fd0:	00003617          	auipc	a2,0x3
ffffffffc0202fd4:	3c060613          	addi	a2,a2,960 # ffffffffc0206390 <etext+0xa36>
ffffffffc0202fd8:	25000593          	li	a1,592
ffffffffc0202fdc:	00004517          	auipc	a0,0x4
ffffffffc0202fe0:	85450513          	addi	a0,a0,-1964 # ffffffffc0206830 <etext+0xed6>
ffffffffc0202fe4:	c66fd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0202fe8:	deffe0ef          	jal	ffffffffc0201dd6 <pa2page.part.0>
        panic("pte2page called with invalid pte");
ffffffffc0202fec:	00004617          	auipc	a2,0x4
ffffffffc0202ff0:	89c60613          	addi	a2,a2,-1892 # ffffffffc0206888 <etext+0xf2e>
ffffffffc0202ff4:	07f00593          	li	a1,127
ffffffffc0202ff8:	00003517          	auipc	a0,0x3
ffffffffc0202ffc:	77050513          	addi	a0,a0,1904 # ffffffffc0206768 <etext+0xe0e>
ffffffffc0203000:	c4afd0ef          	jal	ffffffffc020044a <__panic>
        panic("DTB memory info not available");
ffffffffc0203004:	00004617          	auipc	a2,0x4
ffffffffc0203008:	8e460613          	addi	a2,a2,-1820 # ffffffffc02068e8 <etext+0xf8e>
ffffffffc020300c:	06500593          	li	a1,101
ffffffffc0203010:	00004517          	auipc	a0,0x4
ffffffffc0203014:	82050513          	addi	a0,a0,-2016 # ffffffffc0206830 <etext+0xed6>
ffffffffc0203018:	c32fd0ef          	jal	ffffffffc020044a <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc020301c:	00004697          	auipc	a3,0x4
ffffffffc0203020:	c4468693          	addi	a3,a3,-956 # ffffffffc0206c60 <etext+0x1306>
ffffffffc0203024:	00003617          	auipc	a2,0x3
ffffffffc0203028:	36c60613          	addi	a2,a2,876 # ffffffffc0206390 <etext+0xa36>
ffffffffc020302c:	26b00593          	li	a1,619
ffffffffc0203030:	00004517          	auipc	a0,0x4
ffffffffc0203034:	80050513          	addi	a0,a0,-2048 # ffffffffc0206830 <etext+0xed6>
ffffffffc0203038:	c12fd0ef          	jal	ffffffffc020044a <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc020303c:	00004697          	auipc	a3,0x4
ffffffffc0203040:	96468693          	addi	a3,a3,-1692 # ffffffffc02069a0 <etext+0x1046>
ffffffffc0203044:	00003617          	auipc	a2,0x3
ffffffffc0203048:	34c60613          	addi	a2,a2,844 # ffffffffc0206390 <etext+0xa36>
ffffffffc020304c:	21200593          	li	a1,530
ffffffffc0203050:	00003517          	auipc	a0,0x3
ffffffffc0203054:	7e050513          	addi	a0,a0,2016 # ffffffffc0206830 <etext+0xed6>
ffffffffc0203058:	bf2fd0ef          	jal	ffffffffc020044a <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc020305c:	00004697          	auipc	a3,0x4
ffffffffc0203060:	92468693          	addi	a3,a3,-1756 # ffffffffc0206980 <etext+0x1026>
ffffffffc0203064:	00003617          	auipc	a2,0x3
ffffffffc0203068:	32c60613          	addi	a2,a2,812 # ffffffffc0206390 <etext+0xa36>
ffffffffc020306c:	21100593          	li	a1,529
ffffffffc0203070:	00003517          	auipc	a0,0x3
ffffffffc0203074:	7c050513          	addi	a0,a0,1984 # ffffffffc0206830 <etext+0xed6>
ffffffffc0203078:	bd2fd0ef          	jal	ffffffffc020044a <__panic>
    return KADDR(page2pa(page));
ffffffffc020307c:	00003617          	auipc	a2,0x3
ffffffffc0203080:	6c460613          	addi	a2,a2,1732 # ffffffffc0206740 <etext+0xde6>
ffffffffc0203084:	07100593          	li	a1,113
ffffffffc0203088:	00003517          	auipc	a0,0x3
ffffffffc020308c:	6e050513          	addi	a0,a0,1760 # ffffffffc0206768 <etext+0xe0e>
ffffffffc0203090:	bbafd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0203094:	00004697          	auipc	a3,0x4
ffffffffc0203098:	b9c68693          	addi	a3,a3,-1124 # ffffffffc0206c30 <etext+0x12d6>
ffffffffc020309c:	00003617          	auipc	a2,0x3
ffffffffc02030a0:	2f460613          	addi	a2,a2,756 # ffffffffc0206390 <etext+0xa36>
ffffffffc02030a4:	23900593          	li	a1,569
ffffffffc02030a8:	00003517          	auipc	a0,0x3
ffffffffc02030ac:	78850513          	addi	a0,a0,1928 # ffffffffc0206830 <etext+0xed6>
ffffffffc02030b0:	b9afd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02030b4:	00004697          	auipc	a3,0x4
ffffffffc02030b8:	b3468693          	addi	a3,a3,-1228 # ffffffffc0206be8 <etext+0x128e>
ffffffffc02030bc:	00003617          	auipc	a2,0x3
ffffffffc02030c0:	2d460613          	addi	a2,a2,724 # ffffffffc0206390 <etext+0xa36>
ffffffffc02030c4:	23700593          	li	a1,567
ffffffffc02030c8:	00003517          	auipc	a0,0x3
ffffffffc02030cc:	76850513          	addi	a0,a0,1896 # ffffffffc0206830 <etext+0xed6>
ffffffffc02030d0:	b7afd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p1) == 0);
ffffffffc02030d4:	00004697          	auipc	a3,0x4
ffffffffc02030d8:	b4468693          	addi	a3,a3,-1212 # ffffffffc0206c18 <etext+0x12be>
ffffffffc02030dc:	00003617          	auipc	a2,0x3
ffffffffc02030e0:	2b460613          	addi	a2,a2,692 # ffffffffc0206390 <etext+0xa36>
ffffffffc02030e4:	23600593          	li	a1,566
ffffffffc02030e8:	00003517          	auipc	a0,0x3
ffffffffc02030ec:	74850513          	addi	a0,a0,1864 # ffffffffc0206830 <etext+0xed6>
ffffffffc02030f0:	b5afd0ef          	jal	ffffffffc020044a <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc02030f4:	00004697          	auipc	a3,0x4
ffffffffc02030f8:	c0c68693          	addi	a3,a3,-1012 # ffffffffc0206d00 <etext+0x13a6>
ffffffffc02030fc:	00003617          	auipc	a2,0x3
ffffffffc0203100:	29460613          	addi	a2,a2,660 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203104:	25400593          	li	a1,596
ffffffffc0203108:	00003517          	auipc	a0,0x3
ffffffffc020310c:	72850513          	addi	a0,a0,1832 # ffffffffc0206830 <etext+0xed6>
ffffffffc0203110:	b3afd0ef          	jal	ffffffffc020044a <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0203114:	00004697          	auipc	a3,0x4
ffffffffc0203118:	b4c68693          	addi	a3,a3,-1204 # ffffffffc0206c60 <etext+0x1306>
ffffffffc020311c:	00003617          	auipc	a2,0x3
ffffffffc0203120:	27460613          	addi	a2,a2,628 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203124:	24100593          	li	a1,577
ffffffffc0203128:	00003517          	auipc	a0,0x3
ffffffffc020312c:	70850513          	addi	a0,a0,1800 # ffffffffc0206830 <etext+0xed6>
ffffffffc0203130:	b1afd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p) == 1);
ffffffffc0203134:	00004697          	auipc	a3,0x4
ffffffffc0203138:	c2468693          	addi	a3,a3,-988 # ffffffffc0206d58 <etext+0x13fe>
ffffffffc020313c:	00003617          	auipc	a2,0x3
ffffffffc0203140:	25460613          	addi	a2,a2,596 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203144:	25900593          	li	a1,601
ffffffffc0203148:	00003517          	auipc	a0,0x3
ffffffffc020314c:	6e850513          	addi	a0,a0,1768 # ffffffffc0206830 <etext+0xed6>
ffffffffc0203150:	afafd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203154:	00004697          	auipc	a3,0x4
ffffffffc0203158:	bc468693          	addi	a3,a3,-1084 # ffffffffc0206d18 <etext+0x13be>
ffffffffc020315c:	00003617          	auipc	a2,0x3
ffffffffc0203160:	23460613          	addi	a2,a2,564 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203164:	25800593          	li	a1,600
ffffffffc0203168:	00003517          	auipc	a0,0x3
ffffffffc020316c:	6c850513          	addi	a0,a0,1736 # ffffffffc0206830 <etext+0xed6>
ffffffffc0203170:	adafd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203174:	00004697          	auipc	a3,0x4
ffffffffc0203178:	a7468693          	addi	a3,a3,-1420 # ffffffffc0206be8 <etext+0x128e>
ffffffffc020317c:	00003617          	auipc	a2,0x3
ffffffffc0203180:	21460613          	addi	a2,a2,532 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203184:	23300593          	li	a1,563
ffffffffc0203188:	00003517          	auipc	a0,0x3
ffffffffc020318c:	6a850513          	addi	a0,a0,1704 # ffffffffc0206830 <etext+0xed6>
ffffffffc0203190:	abafd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203194:	00004697          	auipc	a3,0x4
ffffffffc0203198:	8f468693          	addi	a3,a3,-1804 # ffffffffc0206a88 <etext+0x112e>
ffffffffc020319c:	00003617          	auipc	a2,0x3
ffffffffc02031a0:	1f460613          	addi	a2,a2,500 # ffffffffc0206390 <etext+0xa36>
ffffffffc02031a4:	23200593          	li	a1,562
ffffffffc02031a8:	00003517          	auipc	a0,0x3
ffffffffc02031ac:	68850513          	addi	a0,a0,1672 # ffffffffc0206830 <etext+0xed6>
ffffffffc02031b0:	a9afd0ef          	jal	ffffffffc020044a <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc02031b4:	00004697          	auipc	a3,0x4
ffffffffc02031b8:	a4c68693          	addi	a3,a3,-1460 # ffffffffc0206c00 <etext+0x12a6>
ffffffffc02031bc:	00003617          	auipc	a2,0x3
ffffffffc02031c0:	1d460613          	addi	a2,a2,468 # ffffffffc0206390 <etext+0xa36>
ffffffffc02031c4:	22f00593          	li	a1,559
ffffffffc02031c8:	00003517          	auipc	a0,0x3
ffffffffc02031cc:	66850513          	addi	a0,a0,1640 # ffffffffc0206830 <etext+0xed6>
ffffffffc02031d0:	a7afd0ef          	jal	ffffffffc020044a <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02031d4:	00004697          	auipc	a3,0x4
ffffffffc02031d8:	89c68693          	addi	a3,a3,-1892 # ffffffffc0206a70 <etext+0x1116>
ffffffffc02031dc:	00003617          	auipc	a2,0x3
ffffffffc02031e0:	1b460613          	addi	a2,a2,436 # ffffffffc0206390 <etext+0xa36>
ffffffffc02031e4:	22e00593          	li	a1,558
ffffffffc02031e8:	00003517          	auipc	a0,0x3
ffffffffc02031ec:	64850513          	addi	a0,a0,1608 # ffffffffc0206830 <etext+0xed6>
ffffffffc02031f0:	a5afd0ef          	jal	ffffffffc020044a <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02031f4:	00004697          	auipc	a3,0x4
ffffffffc02031f8:	91c68693          	addi	a3,a3,-1764 # ffffffffc0206b10 <etext+0x11b6>
ffffffffc02031fc:	00003617          	auipc	a2,0x3
ffffffffc0203200:	19460613          	addi	a2,a2,404 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203204:	22d00593          	li	a1,557
ffffffffc0203208:	00003517          	auipc	a0,0x3
ffffffffc020320c:	62850513          	addi	a0,a0,1576 # ffffffffc0206830 <etext+0xed6>
ffffffffc0203210:	a3afd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203214:	00004697          	auipc	a3,0x4
ffffffffc0203218:	9d468693          	addi	a3,a3,-1580 # ffffffffc0206be8 <etext+0x128e>
ffffffffc020321c:	00003617          	auipc	a2,0x3
ffffffffc0203220:	17460613          	addi	a2,a2,372 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203224:	22c00593          	li	a1,556
ffffffffc0203228:	00003517          	auipc	a0,0x3
ffffffffc020322c:	60850513          	addi	a0,a0,1544 # ffffffffc0206830 <etext+0xed6>
ffffffffc0203230:	a1afd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p1) == 2);
ffffffffc0203234:	00004697          	auipc	a3,0x4
ffffffffc0203238:	99c68693          	addi	a3,a3,-1636 # ffffffffc0206bd0 <etext+0x1276>
ffffffffc020323c:	00003617          	auipc	a2,0x3
ffffffffc0203240:	15460613          	addi	a2,a2,340 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203244:	22b00593          	li	a1,555
ffffffffc0203248:	00003517          	auipc	a0,0x3
ffffffffc020324c:	5e850513          	addi	a0,a0,1512 # ffffffffc0206830 <etext+0xed6>
ffffffffc0203250:	9fafd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0203254:	00004697          	auipc	a3,0x4
ffffffffc0203258:	94c68693          	addi	a3,a3,-1716 # ffffffffc0206ba0 <etext+0x1246>
ffffffffc020325c:	00003617          	auipc	a2,0x3
ffffffffc0203260:	13460613          	addi	a2,a2,308 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203264:	22a00593          	li	a1,554
ffffffffc0203268:	00003517          	auipc	a0,0x3
ffffffffc020326c:	5c850513          	addi	a0,a0,1480 # ffffffffc0206830 <etext+0xed6>
ffffffffc0203270:	9dafd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203274:	00004697          	auipc	a3,0x4
ffffffffc0203278:	91468693          	addi	a3,a3,-1772 # ffffffffc0206b88 <etext+0x122e>
ffffffffc020327c:	00003617          	auipc	a2,0x3
ffffffffc0203280:	11460613          	addi	a2,a2,276 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203284:	22800593          	li	a1,552
ffffffffc0203288:	00003517          	auipc	a0,0x3
ffffffffc020328c:	5a850513          	addi	a0,a0,1448 # ffffffffc0206830 <etext+0xed6>
ffffffffc0203290:	9bafd0ef          	jal	ffffffffc020044a <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0203294:	00004697          	auipc	a3,0x4
ffffffffc0203298:	8d468693          	addi	a3,a3,-1836 # ffffffffc0206b68 <etext+0x120e>
ffffffffc020329c:	00003617          	auipc	a2,0x3
ffffffffc02032a0:	0f460613          	addi	a2,a2,244 # ffffffffc0206390 <etext+0xa36>
ffffffffc02032a4:	22700593          	li	a1,551
ffffffffc02032a8:	00003517          	auipc	a0,0x3
ffffffffc02032ac:	58850513          	addi	a0,a0,1416 # ffffffffc0206830 <etext+0xed6>
ffffffffc02032b0:	99afd0ef          	jal	ffffffffc020044a <__panic>
    assert(*ptep & PTE_W);
ffffffffc02032b4:	00004697          	auipc	a3,0x4
ffffffffc02032b8:	8a468693          	addi	a3,a3,-1884 # ffffffffc0206b58 <etext+0x11fe>
ffffffffc02032bc:	00003617          	auipc	a2,0x3
ffffffffc02032c0:	0d460613          	addi	a2,a2,212 # ffffffffc0206390 <etext+0xa36>
ffffffffc02032c4:	22600593          	li	a1,550
ffffffffc02032c8:	00003517          	auipc	a0,0x3
ffffffffc02032cc:	56850513          	addi	a0,a0,1384 # ffffffffc0206830 <etext+0xed6>
ffffffffc02032d0:	97afd0ef          	jal	ffffffffc020044a <__panic>
    assert(*ptep & PTE_U);
ffffffffc02032d4:	00004697          	auipc	a3,0x4
ffffffffc02032d8:	87468693          	addi	a3,a3,-1932 # ffffffffc0206b48 <etext+0x11ee>
ffffffffc02032dc:	00003617          	auipc	a2,0x3
ffffffffc02032e0:	0b460613          	addi	a2,a2,180 # ffffffffc0206390 <etext+0xa36>
ffffffffc02032e4:	22500593          	li	a1,549
ffffffffc02032e8:	00003517          	auipc	a0,0x3
ffffffffc02032ec:	54850513          	addi	a0,a0,1352 # ffffffffc0206830 <etext+0xed6>
ffffffffc02032f0:	95afd0ef          	jal	ffffffffc020044a <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02032f4:	00003617          	auipc	a2,0x3
ffffffffc02032f8:	4f460613          	addi	a2,a2,1268 # ffffffffc02067e8 <etext+0xe8e>
ffffffffc02032fc:	08100593          	li	a1,129
ffffffffc0203300:	00003517          	auipc	a0,0x3
ffffffffc0203304:	53050513          	addi	a0,a0,1328 # ffffffffc0206830 <etext+0xed6>
ffffffffc0203308:	942fd0ef          	jal	ffffffffc020044a <__panic>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc020330c:	00003697          	auipc	a3,0x3
ffffffffc0203310:	79468693          	addi	a3,a3,1940 # ffffffffc0206aa0 <etext+0x1146>
ffffffffc0203314:	00003617          	auipc	a2,0x3
ffffffffc0203318:	07c60613          	addi	a2,a2,124 # ffffffffc0206390 <etext+0xa36>
ffffffffc020331c:	22000593          	li	a1,544
ffffffffc0203320:	00003517          	auipc	a0,0x3
ffffffffc0203324:	51050513          	addi	a0,a0,1296 # ffffffffc0206830 <etext+0xed6>
ffffffffc0203328:	922fd0ef          	jal	ffffffffc020044a <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc020332c:	00003697          	auipc	a3,0x3
ffffffffc0203330:	7e468693          	addi	a3,a3,2020 # ffffffffc0206b10 <etext+0x11b6>
ffffffffc0203334:	00003617          	auipc	a2,0x3
ffffffffc0203338:	05c60613          	addi	a2,a2,92 # ffffffffc0206390 <etext+0xa36>
ffffffffc020333c:	22400593          	li	a1,548
ffffffffc0203340:	00003517          	auipc	a0,0x3
ffffffffc0203344:	4f050513          	addi	a0,a0,1264 # ffffffffc0206830 <etext+0xed6>
ffffffffc0203348:	902fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc020334c:	00003697          	auipc	a3,0x3
ffffffffc0203350:	78468693          	addi	a3,a3,1924 # ffffffffc0206ad0 <etext+0x1176>
ffffffffc0203354:	00003617          	auipc	a2,0x3
ffffffffc0203358:	03c60613          	addi	a2,a2,60 # ffffffffc0206390 <etext+0xa36>
ffffffffc020335c:	22300593          	li	a1,547
ffffffffc0203360:	00003517          	auipc	a0,0x3
ffffffffc0203364:	4d050513          	addi	a0,a0,1232 # ffffffffc0206830 <etext+0xed6>
ffffffffc0203368:	8e2fd0ef          	jal	ffffffffc020044a <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc020336c:	86d6                	mv	a3,s5
ffffffffc020336e:	00003617          	auipc	a2,0x3
ffffffffc0203372:	3d260613          	addi	a2,a2,978 # ffffffffc0206740 <etext+0xde6>
ffffffffc0203376:	21f00593          	li	a1,543
ffffffffc020337a:	00003517          	auipc	a0,0x3
ffffffffc020337e:	4b650513          	addi	a0,a0,1206 # ffffffffc0206830 <etext+0xed6>
ffffffffc0203382:	8c8fd0ef          	jal	ffffffffc020044a <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0203386:	00003617          	auipc	a2,0x3
ffffffffc020338a:	3ba60613          	addi	a2,a2,954 # ffffffffc0206740 <etext+0xde6>
ffffffffc020338e:	21e00593          	li	a1,542
ffffffffc0203392:	00003517          	auipc	a0,0x3
ffffffffc0203396:	49e50513          	addi	a0,a0,1182 # ffffffffc0206830 <etext+0xed6>
ffffffffc020339a:	8b0fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020339e:	00003697          	auipc	a3,0x3
ffffffffc02033a2:	6ea68693          	addi	a3,a3,1770 # ffffffffc0206a88 <etext+0x112e>
ffffffffc02033a6:	00003617          	auipc	a2,0x3
ffffffffc02033aa:	fea60613          	addi	a2,a2,-22 # ffffffffc0206390 <etext+0xa36>
ffffffffc02033ae:	21c00593          	li	a1,540
ffffffffc02033b2:	00003517          	auipc	a0,0x3
ffffffffc02033b6:	47e50513          	addi	a0,a0,1150 # ffffffffc0206830 <etext+0xed6>
ffffffffc02033ba:	890fd0ef          	jal	ffffffffc020044a <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc02033be:	00003697          	auipc	a3,0x3
ffffffffc02033c2:	6b268693          	addi	a3,a3,1714 # ffffffffc0206a70 <etext+0x1116>
ffffffffc02033c6:	00003617          	auipc	a2,0x3
ffffffffc02033ca:	fca60613          	addi	a2,a2,-54 # ffffffffc0206390 <etext+0xa36>
ffffffffc02033ce:	21b00593          	li	a1,539
ffffffffc02033d2:	00003517          	auipc	a0,0x3
ffffffffc02033d6:	45e50513          	addi	a0,a0,1118 # ffffffffc0206830 <etext+0xed6>
ffffffffc02033da:	870fd0ef          	jal	ffffffffc020044a <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc02033de:	00004697          	auipc	a3,0x4
ffffffffc02033e2:	a4268693          	addi	a3,a3,-1470 # ffffffffc0206e20 <etext+0x14c6>
ffffffffc02033e6:	00003617          	auipc	a2,0x3
ffffffffc02033ea:	faa60613          	addi	a2,a2,-86 # ffffffffc0206390 <etext+0xa36>
ffffffffc02033ee:	26200593          	li	a1,610
ffffffffc02033f2:	00003517          	auipc	a0,0x3
ffffffffc02033f6:	43e50513          	addi	a0,a0,1086 # ffffffffc0206830 <etext+0xed6>
ffffffffc02033fa:	850fd0ef          	jal	ffffffffc020044a <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02033fe:	00004697          	auipc	a3,0x4
ffffffffc0203402:	9ea68693          	addi	a3,a3,-1558 # ffffffffc0206de8 <etext+0x148e>
ffffffffc0203406:	00003617          	auipc	a2,0x3
ffffffffc020340a:	f8a60613          	addi	a2,a2,-118 # ffffffffc0206390 <etext+0xa36>
ffffffffc020340e:	25f00593          	li	a1,607
ffffffffc0203412:	00003517          	auipc	a0,0x3
ffffffffc0203416:	41e50513          	addi	a0,a0,1054 # ffffffffc0206830 <etext+0xed6>
ffffffffc020341a:	830fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_ref(p) == 2);
ffffffffc020341e:	00004697          	auipc	a3,0x4
ffffffffc0203422:	99a68693          	addi	a3,a3,-1638 # ffffffffc0206db8 <etext+0x145e>
ffffffffc0203426:	00003617          	auipc	a2,0x3
ffffffffc020342a:	f6a60613          	addi	a2,a2,-150 # ffffffffc0206390 <etext+0xa36>
ffffffffc020342e:	25b00593          	li	a1,603
ffffffffc0203432:	00003517          	auipc	a0,0x3
ffffffffc0203436:	3fe50513          	addi	a0,a0,1022 # ffffffffc0206830 <etext+0xed6>
ffffffffc020343a:	810fd0ef          	jal	ffffffffc020044a <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc020343e:	00004697          	auipc	a3,0x4
ffffffffc0203442:	93268693          	addi	a3,a3,-1742 # ffffffffc0206d70 <etext+0x1416>
ffffffffc0203446:	00003617          	auipc	a2,0x3
ffffffffc020344a:	f4a60613          	addi	a2,a2,-182 # ffffffffc0206390 <etext+0xa36>
ffffffffc020344e:	25a00593          	li	a1,602
ffffffffc0203452:	00003517          	auipc	a0,0x3
ffffffffc0203456:	3de50513          	addi	a0,a0,990 # ffffffffc0206830 <etext+0xed6>
ffffffffc020345a:	ff1fc0ef          	jal	ffffffffc020044a <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc020345e:	00003697          	auipc	a3,0x3
ffffffffc0203462:	58268693          	addi	a3,a3,1410 # ffffffffc02069e0 <etext+0x1086>
ffffffffc0203466:	00003617          	auipc	a2,0x3
ffffffffc020346a:	f2a60613          	addi	a2,a2,-214 # ffffffffc0206390 <etext+0xa36>
ffffffffc020346e:	21300593          	li	a1,531
ffffffffc0203472:	00003517          	auipc	a0,0x3
ffffffffc0203476:	3be50513          	addi	a0,a0,958 # ffffffffc0206830 <etext+0xed6>
ffffffffc020347a:	fd1fc0ef          	jal	ffffffffc020044a <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc020347e:	00003617          	auipc	a2,0x3
ffffffffc0203482:	36a60613          	addi	a2,a2,874 # ffffffffc02067e8 <etext+0xe8e>
ffffffffc0203486:	0c900593          	li	a1,201
ffffffffc020348a:	00003517          	auipc	a0,0x3
ffffffffc020348e:	3a650513          	addi	a0,a0,934 # ffffffffc0206830 <etext+0xed6>
ffffffffc0203492:	fb9fc0ef          	jal	ffffffffc020044a <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0203496:	00003697          	auipc	a3,0x3
ffffffffc020349a:	5aa68693          	addi	a3,a3,1450 # ffffffffc0206a40 <etext+0x10e6>
ffffffffc020349e:	00003617          	auipc	a2,0x3
ffffffffc02034a2:	ef260613          	addi	a2,a2,-270 # ffffffffc0206390 <etext+0xa36>
ffffffffc02034a6:	21a00593          	li	a1,538
ffffffffc02034aa:	00003517          	auipc	a0,0x3
ffffffffc02034ae:	38650513          	addi	a0,a0,902 # ffffffffc0206830 <etext+0xed6>
ffffffffc02034b2:	f99fc0ef          	jal	ffffffffc020044a <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc02034b6:	00003697          	auipc	a3,0x3
ffffffffc02034ba:	55a68693          	addi	a3,a3,1370 # ffffffffc0206a10 <etext+0x10b6>
ffffffffc02034be:	00003617          	auipc	a2,0x3
ffffffffc02034c2:	ed260613          	addi	a2,a2,-302 # ffffffffc0206390 <etext+0xa36>
ffffffffc02034c6:	21700593          	li	a1,535
ffffffffc02034ca:	00003517          	auipc	a0,0x3
ffffffffc02034ce:	36650513          	addi	a0,a0,870 # ffffffffc0206830 <etext+0xed6>
ffffffffc02034d2:	f79fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02034d6 <pgdir_alloc_page>:
{
ffffffffc02034d6:	7139                	addi	sp,sp,-64
ffffffffc02034d8:	f426                	sd	s1,40(sp)
ffffffffc02034da:	f04a                	sd	s2,32(sp)
ffffffffc02034dc:	ec4e                	sd	s3,24(sp)
ffffffffc02034de:	fc06                	sd	ra,56(sp)
ffffffffc02034e0:	f822                	sd	s0,48(sp)
ffffffffc02034e2:	892a                	mv	s2,a0
ffffffffc02034e4:	84ae                	mv	s1,a1
ffffffffc02034e6:	89b2                	mv	s3,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02034e8:	100027f3          	csrr	a5,sstatus
ffffffffc02034ec:	8b89                	andi	a5,a5,2
ffffffffc02034ee:	ebb5                	bnez	a5,ffffffffc0203562 <pgdir_alloc_page+0x8c>
        page = pmm_manager->alloc_pages(n);
ffffffffc02034f0:	000b2417          	auipc	s0,0xb2
ffffffffc02034f4:	17840413          	addi	s0,s0,376 # ffffffffc02b5668 <pmm_manager>
ffffffffc02034f8:	601c                	ld	a5,0(s0)
ffffffffc02034fa:	4505                	li	a0,1
ffffffffc02034fc:	6f9c                	ld	a5,24(a5)
ffffffffc02034fe:	9782                	jalr	a5
ffffffffc0203500:	85aa                	mv	a1,a0
    if (page != NULL)
ffffffffc0203502:	c5b9                	beqz	a1,ffffffffc0203550 <pgdir_alloc_page+0x7a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc0203504:	86ce                	mv	a3,s3
ffffffffc0203506:	854a                	mv	a0,s2
ffffffffc0203508:	8626                	mv	a2,s1
ffffffffc020350a:	e42e                	sd	a1,8(sp)
ffffffffc020350c:	a8aff0ef          	jal	ffffffffc0202796 <page_insert>
ffffffffc0203510:	65a2                	ld	a1,8(sp)
ffffffffc0203512:	e515                	bnez	a0,ffffffffc020353e <pgdir_alloc_page+0x68>
        assert(page_ref(page) == 1);
ffffffffc0203514:	4198                	lw	a4,0(a1)
        page->pra_vaddr = la;
ffffffffc0203516:	fd84                	sd	s1,56(a1)
        assert(page_ref(page) == 1);
ffffffffc0203518:	4785                	li	a5,1
ffffffffc020351a:	02f70c63          	beq	a4,a5,ffffffffc0203552 <pgdir_alloc_page+0x7c>
ffffffffc020351e:	00004697          	auipc	a3,0x4
ffffffffc0203522:	94a68693          	addi	a3,a3,-1718 # ffffffffc0206e68 <etext+0x150e>
ffffffffc0203526:	00003617          	auipc	a2,0x3
ffffffffc020352a:	e6a60613          	addi	a2,a2,-406 # ffffffffc0206390 <etext+0xa36>
ffffffffc020352e:	1f800593          	li	a1,504
ffffffffc0203532:	00003517          	auipc	a0,0x3
ffffffffc0203536:	2fe50513          	addi	a0,a0,766 # ffffffffc0206830 <etext+0xed6>
ffffffffc020353a:	f11fc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc020353e:	100027f3          	csrr	a5,sstatus
ffffffffc0203542:	8b89                	andi	a5,a5,2
ffffffffc0203544:	ef95                	bnez	a5,ffffffffc0203580 <pgdir_alloc_page+0xaa>
        pmm_manager->free_pages(base, n);
ffffffffc0203546:	601c                	ld	a5,0(s0)
ffffffffc0203548:	852e                	mv	a0,a1
ffffffffc020354a:	4585                	li	a1,1
ffffffffc020354c:	739c                	ld	a5,32(a5)
ffffffffc020354e:	9782                	jalr	a5
            return NULL;
ffffffffc0203550:	4581                	li	a1,0
}
ffffffffc0203552:	70e2                	ld	ra,56(sp)
ffffffffc0203554:	7442                	ld	s0,48(sp)
ffffffffc0203556:	74a2                	ld	s1,40(sp)
ffffffffc0203558:	7902                	ld	s2,32(sp)
ffffffffc020355a:	69e2                	ld	s3,24(sp)
ffffffffc020355c:	852e                	mv	a0,a1
ffffffffc020355e:	6121                	addi	sp,sp,64
ffffffffc0203560:	8082                	ret
        intr_disable();
ffffffffc0203562:	b9cfd0ef          	jal	ffffffffc02008fe <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203566:	000b2417          	auipc	s0,0xb2
ffffffffc020356a:	10240413          	addi	s0,s0,258 # ffffffffc02b5668 <pmm_manager>
ffffffffc020356e:	601c                	ld	a5,0(s0)
ffffffffc0203570:	4505                	li	a0,1
ffffffffc0203572:	6f9c                	ld	a5,24(a5)
ffffffffc0203574:	9782                	jalr	a5
ffffffffc0203576:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0203578:	b80fd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc020357c:	65a2                	ld	a1,8(sp)
ffffffffc020357e:	b751                	j	ffffffffc0203502 <pgdir_alloc_page+0x2c>
        intr_disable();
ffffffffc0203580:	b7efd0ef          	jal	ffffffffc02008fe <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0203584:	601c                	ld	a5,0(s0)
ffffffffc0203586:	6522                	ld	a0,8(sp)
ffffffffc0203588:	4585                	li	a1,1
ffffffffc020358a:	739c                	ld	a5,32(a5)
ffffffffc020358c:	9782                	jalr	a5
        intr_enable();
ffffffffc020358e:	b6afd0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc0203592:	bf7d                	j	ffffffffc0203550 <pgdir_alloc_page+0x7a>

ffffffffc0203594 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc0203594:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc0203596:	00004697          	auipc	a3,0x4
ffffffffc020359a:	8ea68693          	addi	a3,a3,-1814 # ffffffffc0206e80 <etext+0x1526>
ffffffffc020359e:	00003617          	auipc	a2,0x3
ffffffffc02035a2:	df260613          	addi	a2,a2,-526 # ffffffffc0206390 <etext+0xa36>
ffffffffc02035a6:	07400593          	li	a1,116
ffffffffc02035aa:	00004517          	auipc	a0,0x4
ffffffffc02035ae:	8f650513          	addi	a0,a0,-1802 # ffffffffc0206ea0 <etext+0x1546>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02035b2:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02035b4:	e97fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02035b8 <mm_create>:
{
ffffffffc02035b8:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02035ba:	04000513          	li	a0,64
{
ffffffffc02035be:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02035c0:	e70fe0ef          	jal	ffffffffc0201c30 <kmalloc>
    if (mm != NULL)
ffffffffc02035c4:	cd19                	beqz	a0,ffffffffc02035e2 <mm_create+0x2a>
    elm->prev = elm->next = elm;
ffffffffc02035c6:	e508                	sd	a0,8(a0)
ffffffffc02035c8:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02035ca:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02035ce:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02035d2:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc02035d6:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc02035da:	02052823          	sw	zero,48(a0)
typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
ffffffffc02035de:	02053c23          	sd	zero,56(a0)
}
ffffffffc02035e2:	60a2                	ld	ra,8(sp)
ffffffffc02035e4:	0141                	addi	sp,sp,16
ffffffffc02035e6:	8082                	ret

ffffffffc02035e8 <find_vma>:
    if (mm != NULL)
ffffffffc02035e8:	c505                	beqz	a0,ffffffffc0203610 <find_vma+0x28>
        vma = mm->mmap_cache;
ffffffffc02035ea:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc02035ec:	c781                	beqz	a5,ffffffffc02035f4 <find_vma+0xc>
ffffffffc02035ee:	6798                	ld	a4,8(a5)
ffffffffc02035f0:	02e5f363          	bgeu	a1,a4,ffffffffc0203616 <find_vma+0x2e>
    return listelm->next;
ffffffffc02035f4:	651c                	ld	a5,8(a0)
            while ((le = list_next(le)) != list)
ffffffffc02035f6:	00f50d63          	beq	a0,a5,ffffffffc0203610 <find_vma+0x28>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc02035fa:	fe87b703          	ld	a4,-24(a5) # fffffffffdffffe8 <end+0x3dd4a920>
ffffffffc02035fe:	00e5e663          	bltu	a1,a4,ffffffffc020360a <find_vma+0x22>
ffffffffc0203602:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203606:	00e5ee63          	bltu	a1,a4,ffffffffc0203622 <find_vma+0x3a>
ffffffffc020360a:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc020360c:	fef517e3          	bne	a0,a5,ffffffffc02035fa <find_vma+0x12>
    struct vma_struct *vma = NULL;
ffffffffc0203610:	4781                	li	a5,0
}
ffffffffc0203612:	853e                	mv	a0,a5
ffffffffc0203614:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0203616:	6b98                	ld	a4,16(a5)
ffffffffc0203618:	fce5fee3          	bgeu	a1,a4,ffffffffc02035f4 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc020361c:	e91c                	sd	a5,16(a0)
}
ffffffffc020361e:	853e                	mv	a0,a5
ffffffffc0203620:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc0203622:	1781                	addi	a5,a5,-32
            mm->mmap_cache = vma;
ffffffffc0203624:	e91c                	sd	a5,16(a0)
ffffffffc0203626:	bfe5                	j	ffffffffc020361e <find_vma+0x36>

ffffffffc0203628 <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203628:	6590                	ld	a2,8(a1)
ffffffffc020362a:	0105b803          	ld	a6,16(a1)
{
ffffffffc020362e:	1141                	addi	sp,sp,-16
ffffffffc0203630:	e406                	sd	ra,8(sp)
ffffffffc0203632:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203634:	01066763          	bltu	a2,a6,ffffffffc0203642 <insert_vma_struct+0x1a>
ffffffffc0203638:	a8b9                	j	ffffffffc0203696 <insert_vma_struct+0x6e>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc020363a:	fe87b703          	ld	a4,-24(a5)
ffffffffc020363e:	04e66763          	bltu	a2,a4,ffffffffc020368c <insert_vma_struct+0x64>
ffffffffc0203642:	86be                	mv	a3,a5
ffffffffc0203644:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc0203646:	fef51ae3          	bne	a0,a5,ffffffffc020363a <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc020364a:	02a68463          	beq	a3,a0,ffffffffc0203672 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020364e:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203652:	fe86b883          	ld	a7,-24(a3)
ffffffffc0203656:	08e8f063          	bgeu	a7,a4,ffffffffc02036d6 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc020365a:	04e66e63          	bltu	a2,a4,ffffffffc02036b6 <insert_vma_struct+0x8e>
    }
    if (le_next != list)
ffffffffc020365e:	00f50a63          	beq	a0,a5,ffffffffc0203672 <insert_vma_struct+0x4a>
ffffffffc0203662:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203666:	05076863          	bltu	a4,a6,ffffffffc02036b6 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc020366a:	ff07b603          	ld	a2,-16(a5)
ffffffffc020366e:	02c77263          	bgeu	a4,a2,ffffffffc0203692 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc0203672:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0203674:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203676:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc020367a:	e390                	sd	a2,0(a5)
ffffffffc020367c:	e690                	sd	a2,8(a3)
}
ffffffffc020367e:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0203680:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc0203682:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc0203684:	2705                	addiw	a4,a4,1
ffffffffc0203686:	d118                	sw	a4,32(a0)
}
ffffffffc0203688:	0141                	addi	sp,sp,16
ffffffffc020368a:	8082                	ret
    if (le_prev != list)
ffffffffc020368c:	fca691e3          	bne	a3,a0,ffffffffc020364e <insert_vma_struct+0x26>
ffffffffc0203690:	bfd9                	j	ffffffffc0203666 <insert_vma_struct+0x3e>
ffffffffc0203692:	f03ff0ef          	jal	ffffffffc0203594 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203696:	00004697          	auipc	a3,0x4
ffffffffc020369a:	81a68693          	addi	a3,a3,-2022 # ffffffffc0206eb0 <etext+0x1556>
ffffffffc020369e:	00003617          	auipc	a2,0x3
ffffffffc02036a2:	cf260613          	addi	a2,a2,-782 # ffffffffc0206390 <etext+0xa36>
ffffffffc02036a6:	07a00593          	li	a1,122
ffffffffc02036aa:	00003517          	auipc	a0,0x3
ffffffffc02036ae:	7f650513          	addi	a0,a0,2038 # ffffffffc0206ea0 <etext+0x1546>
ffffffffc02036b2:	d99fc0ef          	jal	ffffffffc020044a <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02036b6:	00004697          	auipc	a3,0x4
ffffffffc02036ba:	83a68693          	addi	a3,a3,-1990 # ffffffffc0206ef0 <etext+0x1596>
ffffffffc02036be:	00003617          	auipc	a2,0x3
ffffffffc02036c2:	cd260613          	addi	a2,a2,-814 # ffffffffc0206390 <etext+0xa36>
ffffffffc02036c6:	07300593          	li	a1,115
ffffffffc02036ca:	00003517          	auipc	a0,0x3
ffffffffc02036ce:	7d650513          	addi	a0,a0,2006 # ffffffffc0206ea0 <etext+0x1546>
ffffffffc02036d2:	d79fc0ef          	jal	ffffffffc020044a <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02036d6:	00003697          	auipc	a3,0x3
ffffffffc02036da:	7fa68693          	addi	a3,a3,2042 # ffffffffc0206ed0 <etext+0x1576>
ffffffffc02036de:	00003617          	auipc	a2,0x3
ffffffffc02036e2:	cb260613          	addi	a2,a2,-846 # ffffffffc0206390 <etext+0xa36>
ffffffffc02036e6:	07200593          	li	a1,114
ffffffffc02036ea:	00003517          	auipc	a0,0x3
ffffffffc02036ee:	7b650513          	addi	a0,a0,1974 # ffffffffc0206ea0 <etext+0x1546>
ffffffffc02036f2:	d59fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02036f6 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc02036f6:	591c                	lw	a5,48(a0)
{
ffffffffc02036f8:	1141                	addi	sp,sp,-16
ffffffffc02036fa:	e406                	sd	ra,8(sp)
ffffffffc02036fc:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc02036fe:	e78d                	bnez	a5,ffffffffc0203728 <mm_destroy+0x32>
ffffffffc0203700:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203702:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc0203704:	00a40c63          	beq	s0,a0,ffffffffc020371c <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203708:	6118                	ld	a4,0(a0)
ffffffffc020370a:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc020370c:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020370e:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc0203710:	e398                	sd	a4,0(a5)
ffffffffc0203712:	dc4fe0ef          	jal	ffffffffc0201cd6 <kfree>
    return listelm->next;
ffffffffc0203716:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc0203718:	fea418e3          	bne	s0,a0,ffffffffc0203708 <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc020371c:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc020371e:	6402                	ld	s0,0(sp)
ffffffffc0203720:	60a2                	ld	ra,8(sp)
ffffffffc0203722:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc0203724:	db2fe06f          	j	ffffffffc0201cd6 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0203728:	00003697          	auipc	a3,0x3
ffffffffc020372c:	7e868693          	addi	a3,a3,2024 # ffffffffc0206f10 <etext+0x15b6>
ffffffffc0203730:	00003617          	auipc	a2,0x3
ffffffffc0203734:	c6060613          	addi	a2,a2,-928 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203738:	09e00593          	li	a1,158
ffffffffc020373c:	00003517          	auipc	a0,0x3
ffffffffc0203740:	76450513          	addi	a0,a0,1892 # ffffffffc0206ea0 <etext+0x1546>
ffffffffc0203744:	d07fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0203748 <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0203748:	6785                	lui	a5,0x1
ffffffffc020374a:	17fd                	addi	a5,a5,-1 # fff <_binary_obj___user_softint_out_size-0x7f29>
ffffffffc020374c:	963e                	add	a2,a2,a5
    if (!USER_ACCESS(start, end))
ffffffffc020374e:	4785                	li	a5,1
{
ffffffffc0203750:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0203752:	962e                	add	a2,a2,a1
ffffffffc0203754:	787d                	lui	a6,0xfffff
    if (!USER_ACCESS(start, end))
ffffffffc0203756:	07fe                	slli	a5,a5,0x1f
{
ffffffffc0203758:	f822                	sd	s0,48(sp)
ffffffffc020375a:	f426                	sd	s1,40(sp)
ffffffffc020375c:	01067433          	and	s0,a2,a6
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0203760:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end))
ffffffffc0203764:	0785                	addi	a5,a5,1
ffffffffc0203766:	0084b633          	sltu	a2,s1,s0
ffffffffc020376a:	00f437b3          	sltu	a5,s0,a5
ffffffffc020376e:	00163613          	seqz	a2,a2
ffffffffc0203772:	0017b793          	seqz	a5,a5
{
ffffffffc0203776:	fc06                	sd	ra,56(sp)
    if (!USER_ACCESS(start, end))
ffffffffc0203778:	8fd1                	or	a5,a5,a2
ffffffffc020377a:	ebbd                	bnez	a5,ffffffffc02037f0 <mm_map+0xa8>
ffffffffc020377c:	002007b7          	lui	a5,0x200
ffffffffc0203780:	06f4e863          	bltu	s1,a5,ffffffffc02037f0 <mm_map+0xa8>
ffffffffc0203784:	f04a                	sd	s2,32(sp)
ffffffffc0203786:	ec4e                	sd	s3,24(sp)
ffffffffc0203788:	e852                	sd	s4,16(sp)
ffffffffc020378a:	892a                	mv	s2,a0
ffffffffc020378c:	89ba                	mv	s3,a4
ffffffffc020378e:	8a36                	mv	s4,a3
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc0203790:	c135                	beqz	a0,ffffffffc02037f4 <mm_map+0xac>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc0203792:	85a6                	mv	a1,s1
ffffffffc0203794:	e55ff0ef          	jal	ffffffffc02035e8 <find_vma>
ffffffffc0203798:	c501                	beqz	a0,ffffffffc02037a0 <mm_map+0x58>
ffffffffc020379a:	651c                	ld	a5,8(a0)
ffffffffc020379c:	0487e763          	bltu	a5,s0,ffffffffc02037ea <mm_map+0xa2>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02037a0:	03000513          	li	a0,48
ffffffffc02037a4:	c8cfe0ef          	jal	ffffffffc0201c30 <kmalloc>
ffffffffc02037a8:	85aa                	mv	a1,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02037aa:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc02037ac:	c59d                	beqz	a1,ffffffffc02037da <mm_map+0x92>
        vma->vm_start = vm_start;
ffffffffc02037ae:	e584                	sd	s1,8(a1)
        vma->vm_end = vm_end;
ffffffffc02037b0:	e980                	sd	s0,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc02037b2:	0145ac23          	sw	s4,24(a1)

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02037b6:	854a                	mv	a0,s2
ffffffffc02037b8:	e42e                	sd	a1,8(sp)
ffffffffc02037ba:	e6fff0ef          	jal	ffffffffc0203628 <insert_vma_struct>
    if (vma_store != NULL)
ffffffffc02037be:	65a2                	ld	a1,8(sp)
ffffffffc02037c0:	00098463          	beqz	s3,ffffffffc02037c8 <mm_map+0x80>
    {
        *vma_store = vma;
ffffffffc02037c4:	00b9b023          	sd	a1,0(s3)
ffffffffc02037c8:	7902                	ld	s2,32(sp)
ffffffffc02037ca:	69e2                	ld	s3,24(sp)
ffffffffc02037cc:	6a42                	ld	s4,16(sp)
    }
    ret = 0;
ffffffffc02037ce:	4501                	li	a0,0

out:
    return ret;
}
ffffffffc02037d0:	70e2                	ld	ra,56(sp)
ffffffffc02037d2:	7442                	ld	s0,48(sp)
ffffffffc02037d4:	74a2                	ld	s1,40(sp)
ffffffffc02037d6:	6121                	addi	sp,sp,64
ffffffffc02037d8:	8082                	ret
ffffffffc02037da:	70e2                	ld	ra,56(sp)
ffffffffc02037dc:	7442                	ld	s0,48(sp)
ffffffffc02037de:	7902                	ld	s2,32(sp)
ffffffffc02037e0:	69e2                	ld	s3,24(sp)
ffffffffc02037e2:	6a42                	ld	s4,16(sp)
ffffffffc02037e4:	74a2                	ld	s1,40(sp)
ffffffffc02037e6:	6121                	addi	sp,sp,64
ffffffffc02037e8:	8082                	ret
ffffffffc02037ea:	7902                	ld	s2,32(sp)
ffffffffc02037ec:	69e2                	ld	s3,24(sp)
ffffffffc02037ee:	6a42                	ld	s4,16(sp)
        return -E_INVAL;
ffffffffc02037f0:	5575                	li	a0,-3
ffffffffc02037f2:	bff9                	j	ffffffffc02037d0 <mm_map+0x88>
    assert(mm != NULL);
ffffffffc02037f4:	00003697          	auipc	a3,0x3
ffffffffc02037f8:	73468693          	addi	a3,a3,1844 # ffffffffc0206f28 <etext+0x15ce>
ffffffffc02037fc:	00003617          	auipc	a2,0x3
ffffffffc0203800:	b9460613          	addi	a2,a2,-1132 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203804:	0b300593          	li	a1,179
ffffffffc0203808:	00003517          	auipc	a0,0x3
ffffffffc020380c:	69850513          	addi	a0,a0,1688 # ffffffffc0206ea0 <etext+0x1546>
ffffffffc0203810:	c3bfc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0203814 <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc0203814:	7139                	addi	sp,sp,-64
ffffffffc0203816:	fc06                	sd	ra,56(sp)
ffffffffc0203818:	f822                	sd	s0,48(sp)
ffffffffc020381a:	f426                	sd	s1,40(sp)
ffffffffc020381c:	f04a                	sd	s2,32(sp)
ffffffffc020381e:	ec4e                	sd	s3,24(sp)
ffffffffc0203820:	e852                	sd	s4,16(sp)
ffffffffc0203822:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0203824:	c525                	beqz	a0,ffffffffc020388c <dup_mmap+0x78>
ffffffffc0203826:	892a                	mv	s2,a0
ffffffffc0203828:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc020382a:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc020382c:	c1a5                	beqz	a1,ffffffffc020388c <dup_mmap+0x78>
    return listelm->prev;
ffffffffc020382e:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc0203830:	04848c63          	beq	s1,s0,ffffffffc0203888 <dup_mmap+0x74>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203834:	03000513          	li	a0,48
    {
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0203838:	fe843a83          	ld	s5,-24(s0)
ffffffffc020383c:	ff043a03          	ld	s4,-16(s0)
ffffffffc0203840:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203844:	becfe0ef          	jal	ffffffffc0201c30 <kmalloc>
    if (vma != NULL)
ffffffffc0203848:	c515                	beqz	a0,ffffffffc0203874 <dup_mmap+0x60>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc020384a:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc020384c:	01553423          	sd	s5,8(a0)
ffffffffc0203850:	01453823          	sd	s4,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203854:	01352c23          	sw	s3,24(a0)
        insert_vma_struct(to, nvma);
ffffffffc0203858:	854a                	mv	a0,s2
ffffffffc020385a:	dcfff0ef          	jal	ffffffffc0203628 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc020385e:	ff043683          	ld	a3,-16(s0)
ffffffffc0203862:	fe843603          	ld	a2,-24(s0)
ffffffffc0203866:	6c8c                	ld	a1,24(s1)
ffffffffc0203868:	01893503          	ld	a0,24(s2)
ffffffffc020386c:	4701                	li	a4,0
ffffffffc020386e:	cc7fe0ef          	jal	ffffffffc0202534 <copy_range>
ffffffffc0203872:	dd55                	beqz	a0,ffffffffc020382e <dup_mmap+0x1a>
            return -E_NO_MEM;
ffffffffc0203874:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0203876:	70e2                	ld	ra,56(sp)
ffffffffc0203878:	7442                	ld	s0,48(sp)
ffffffffc020387a:	74a2                	ld	s1,40(sp)
ffffffffc020387c:	7902                	ld	s2,32(sp)
ffffffffc020387e:	69e2                	ld	s3,24(sp)
ffffffffc0203880:	6a42                	ld	s4,16(sp)
ffffffffc0203882:	6aa2                	ld	s5,8(sp)
ffffffffc0203884:	6121                	addi	sp,sp,64
ffffffffc0203886:	8082                	ret
    return 0;
ffffffffc0203888:	4501                	li	a0,0
ffffffffc020388a:	b7f5                	j	ffffffffc0203876 <dup_mmap+0x62>
    assert(to != NULL && from != NULL);
ffffffffc020388c:	00003697          	auipc	a3,0x3
ffffffffc0203890:	6ac68693          	addi	a3,a3,1708 # ffffffffc0206f38 <etext+0x15de>
ffffffffc0203894:	00003617          	auipc	a2,0x3
ffffffffc0203898:	afc60613          	addi	a2,a2,-1284 # ffffffffc0206390 <etext+0xa36>
ffffffffc020389c:	0cf00593          	li	a1,207
ffffffffc02038a0:	00003517          	auipc	a0,0x3
ffffffffc02038a4:	60050513          	addi	a0,a0,1536 # ffffffffc0206ea0 <etext+0x1546>
ffffffffc02038a8:	ba3fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02038ac <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc02038ac:	1101                	addi	sp,sp,-32
ffffffffc02038ae:	ec06                	sd	ra,24(sp)
ffffffffc02038b0:	e822                	sd	s0,16(sp)
ffffffffc02038b2:	e426                	sd	s1,8(sp)
ffffffffc02038b4:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc02038b6:	c531                	beqz	a0,ffffffffc0203902 <exit_mmap+0x56>
ffffffffc02038b8:	591c                	lw	a5,48(a0)
ffffffffc02038ba:	84aa                	mv	s1,a0
ffffffffc02038bc:	e3b9                	bnez	a5,ffffffffc0203902 <exit_mmap+0x56>
    return listelm->next;
ffffffffc02038be:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc02038c0:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc02038c4:	02850663          	beq	a0,s0,ffffffffc02038f0 <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02038c8:	ff043603          	ld	a2,-16(s0)
ffffffffc02038cc:	fe843583          	ld	a1,-24(s0)
ffffffffc02038d0:	854a                	mv	a0,s2
ffffffffc02038d2:	87bfe0ef          	jal	ffffffffc020214c <unmap_range>
ffffffffc02038d6:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc02038d8:	fe8498e3          	bne	s1,s0,ffffffffc02038c8 <exit_mmap+0x1c>
ffffffffc02038dc:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc02038de:	00848c63          	beq	s1,s0,ffffffffc02038f6 <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc02038e2:	ff043603          	ld	a2,-16(s0)
ffffffffc02038e6:	fe843583          	ld	a1,-24(s0)
ffffffffc02038ea:	854a                	mv	a0,s2
ffffffffc02038ec:	995fe0ef          	jal	ffffffffc0202280 <exit_range>
ffffffffc02038f0:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc02038f2:	fe8498e3          	bne	s1,s0,ffffffffc02038e2 <exit_mmap+0x36>
    }
}
ffffffffc02038f6:	60e2                	ld	ra,24(sp)
ffffffffc02038f8:	6442                	ld	s0,16(sp)
ffffffffc02038fa:	64a2                	ld	s1,8(sp)
ffffffffc02038fc:	6902                	ld	s2,0(sp)
ffffffffc02038fe:	6105                	addi	sp,sp,32
ffffffffc0203900:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203902:	00003697          	auipc	a3,0x3
ffffffffc0203906:	65668693          	addi	a3,a3,1622 # ffffffffc0206f58 <etext+0x15fe>
ffffffffc020390a:	00003617          	auipc	a2,0x3
ffffffffc020390e:	a8660613          	addi	a2,a2,-1402 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203912:	0e800593          	li	a1,232
ffffffffc0203916:	00003517          	auipc	a0,0x3
ffffffffc020391a:	58a50513          	addi	a0,a0,1418 # ffffffffc0206ea0 <etext+0x1546>
ffffffffc020391e:	b2dfc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0203922 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0203922:	7179                	addi	sp,sp,-48
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203924:	04000513          	li	a0,64
{
ffffffffc0203928:	f406                	sd	ra,40(sp)
ffffffffc020392a:	f022                	sd	s0,32(sp)
ffffffffc020392c:	ec26                	sd	s1,24(sp)
ffffffffc020392e:	e84a                	sd	s2,16(sp)
ffffffffc0203930:	e44e                	sd	s3,8(sp)
ffffffffc0203932:	e052                	sd	s4,0(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203934:	afcfe0ef          	jal	ffffffffc0201c30 <kmalloc>
    if (mm != NULL)
ffffffffc0203938:	16050c63          	beqz	a0,ffffffffc0203ab0 <vmm_init+0x18e>
ffffffffc020393c:	842a                	mv	s0,a0
    elm->prev = elm->next = elm;
ffffffffc020393e:	e508                	sd	a0,8(a0)
ffffffffc0203940:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203942:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203946:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc020394a:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc020394e:	02053423          	sd	zero,40(a0)
ffffffffc0203952:	02052823          	sw	zero,48(a0)
ffffffffc0203956:	02053c23          	sd	zero,56(a0)
ffffffffc020395a:	03200493          	li	s1,50
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020395e:	03000513          	li	a0,48
ffffffffc0203962:	acefe0ef          	jal	ffffffffc0201c30 <kmalloc>
    if (vma != NULL)
ffffffffc0203966:	12050563          	beqz	a0,ffffffffc0203a90 <vmm_init+0x16e>
        vma->vm_end = vm_end;
ffffffffc020396a:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc020396e:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203970:	00052c23          	sw	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc0203974:	e91c                	sd	a5,16(a0)
    int i;
    for (i = step1; i >= 1; i--)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203976:	85aa                	mv	a1,a0
    for (i = step1; i >= 1; i--)
ffffffffc0203978:	14ed                	addi	s1,s1,-5
        insert_vma_struct(mm, vma);
ffffffffc020397a:	8522                	mv	a0,s0
ffffffffc020397c:	cadff0ef          	jal	ffffffffc0203628 <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0203980:	fcf9                	bnez	s1,ffffffffc020395e <vmm_init+0x3c>
ffffffffc0203982:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203986:	1f900913          	li	s2,505
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc020398a:	03000513          	li	a0,48
ffffffffc020398e:	aa2fe0ef          	jal	ffffffffc0201c30 <kmalloc>
    if (vma != NULL)
ffffffffc0203992:	12050f63          	beqz	a0,ffffffffc0203ad0 <vmm_init+0x1ae>
        vma->vm_end = vm_end;
ffffffffc0203996:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc020399a:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc020399c:	00052c23          	sw	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc02039a0:	e91c                	sd	a5,16(a0)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc02039a2:	85aa                	mv	a1,a0
    for (i = step1 + 1; i <= step2; i++)
ffffffffc02039a4:	0495                	addi	s1,s1,5
        insert_vma_struct(mm, vma);
ffffffffc02039a6:	8522                	mv	a0,s0
ffffffffc02039a8:	c81ff0ef          	jal	ffffffffc0203628 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc02039ac:	fd249fe3          	bne	s1,s2,ffffffffc020398a <vmm_init+0x68>
    return listelm->next;
ffffffffc02039b0:	641c                	ld	a5,8(s0)
ffffffffc02039b2:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc02039b4:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc02039b8:	1ef40c63          	beq	s0,a5,ffffffffc0203bb0 <vmm_init+0x28e>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc02039bc:	fe87b603          	ld	a2,-24(a5) # 1fffe8 <_binary_obj___user_matrix_out_size+0x1f4aa8>
ffffffffc02039c0:	ffe70693          	addi	a3,a4,-2
ffffffffc02039c4:	12d61663          	bne	a2,a3,ffffffffc0203af0 <vmm_init+0x1ce>
ffffffffc02039c8:	ff07b683          	ld	a3,-16(a5)
ffffffffc02039cc:	12e69263          	bne	a3,a4,ffffffffc0203af0 <vmm_init+0x1ce>
    for (i = 1; i <= step2; i++)
ffffffffc02039d0:	0715                	addi	a4,a4,5
ffffffffc02039d2:	679c                	ld	a5,8(a5)
ffffffffc02039d4:	feb712e3          	bne	a4,a1,ffffffffc02039b8 <vmm_init+0x96>
ffffffffc02039d8:	491d                	li	s2,7
ffffffffc02039da:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc02039dc:	85a6                	mv	a1,s1
ffffffffc02039de:	8522                	mv	a0,s0
ffffffffc02039e0:	c09ff0ef          	jal	ffffffffc02035e8 <find_vma>
ffffffffc02039e4:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc02039e6:	20050563          	beqz	a0,ffffffffc0203bf0 <vmm_init+0x2ce>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc02039ea:	00148593          	addi	a1,s1,1
ffffffffc02039ee:	8522                	mv	a0,s0
ffffffffc02039f0:	bf9ff0ef          	jal	ffffffffc02035e8 <find_vma>
ffffffffc02039f4:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc02039f6:	1c050d63          	beqz	a0,ffffffffc0203bd0 <vmm_init+0x2ae>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc02039fa:	85ca                	mv	a1,s2
ffffffffc02039fc:	8522                	mv	a0,s0
ffffffffc02039fe:	bebff0ef          	jal	ffffffffc02035e8 <find_vma>
        assert(vma3 == NULL);
ffffffffc0203a02:	18051763          	bnez	a0,ffffffffc0203b90 <vmm_init+0x26e>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0203a06:	00348593          	addi	a1,s1,3
ffffffffc0203a0a:	8522                	mv	a0,s0
ffffffffc0203a0c:	bddff0ef          	jal	ffffffffc02035e8 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203a10:	16051063          	bnez	a0,ffffffffc0203b70 <vmm_init+0x24e>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0203a14:	00448593          	addi	a1,s1,4
ffffffffc0203a18:	8522                	mv	a0,s0
ffffffffc0203a1a:	bcfff0ef          	jal	ffffffffc02035e8 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203a1e:	12051963          	bnez	a0,ffffffffc0203b50 <vmm_init+0x22e>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203a22:	008a3783          	ld	a5,8(s4)
ffffffffc0203a26:	10979563          	bne	a5,s1,ffffffffc0203b30 <vmm_init+0x20e>
ffffffffc0203a2a:	010a3783          	ld	a5,16(s4)
ffffffffc0203a2e:	11279163          	bne	a5,s2,ffffffffc0203b30 <vmm_init+0x20e>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203a32:	0089b783          	ld	a5,8(s3)
ffffffffc0203a36:	0c979d63          	bne	a5,s1,ffffffffc0203b10 <vmm_init+0x1ee>
ffffffffc0203a3a:	0109b783          	ld	a5,16(s3)
ffffffffc0203a3e:	0d279963          	bne	a5,s2,ffffffffc0203b10 <vmm_init+0x1ee>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203a42:	0495                	addi	s1,s1,5
ffffffffc0203a44:	1f900793          	li	a5,505
ffffffffc0203a48:	0915                	addi	s2,s2,5
ffffffffc0203a4a:	f8f499e3          	bne	s1,a5,ffffffffc02039dc <vmm_init+0xba>
ffffffffc0203a4e:	4491                	li	s1,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0203a50:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0203a52:	85a6                	mv	a1,s1
ffffffffc0203a54:	8522                	mv	a0,s0
ffffffffc0203a56:	b93ff0ef          	jal	ffffffffc02035e8 <find_vma>
        if (vma_below_5 != NULL)
ffffffffc0203a5a:	1a051b63          	bnez	a0,ffffffffc0203c10 <vmm_init+0x2ee>
    for (i = 4; i >= 0; i--)
ffffffffc0203a5e:	14fd                	addi	s1,s1,-1
ffffffffc0203a60:	ff2499e3          	bne	s1,s2,ffffffffc0203a52 <vmm_init+0x130>
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
ffffffffc0203a64:	8522                	mv	a0,s0
ffffffffc0203a66:	c91ff0ef          	jal	ffffffffc02036f6 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203a6a:	00003517          	auipc	a0,0x3
ffffffffc0203a6e:	65e50513          	addi	a0,a0,1630 # ffffffffc02070c8 <etext+0x176e>
ffffffffc0203a72:	f26fc0ef          	jal	ffffffffc0200198 <cprintf>
}
ffffffffc0203a76:	7402                	ld	s0,32(sp)
ffffffffc0203a78:	70a2                	ld	ra,40(sp)
ffffffffc0203a7a:	64e2                	ld	s1,24(sp)
ffffffffc0203a7c:	6942                	ld	s2,16(sp)
ffffffffc0203a7e:	69a2                	ld	s3,8(sp)
ffffffffc0203a80:	6a02                	ld	s4,0(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203a82:	00003517          	auipc	a0,0x3
ffffffffc0203a86:	66650513          	addi	a0,a0,1638 # ffffffffc02070e8 <etext+0x178e>
}
ffffffffc0203a8a:	6145                	addi	sp,sp,48
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203a8c:	f0cfc06f          	j	ffffffffc0200198 <cprintf>
        assert(vma != NULL);
ffffffffc0203a90:	00003697          	auipc	a3,0x3
ffffffffc0203a94:	4e868693          	addi	a3,a3,1256 # ffffffffc0206f78 <etext+0x161e>
ffffffffc0203a98:	00003617          	auipc	a2,0x3
ffffffffc0203a9c:	8f860613          	addi	a2,a2,-1800 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203aa0:	12c00593          	li	a1,300
ffffffffc0203aa4:	00003517          	auipc	a0,0x3
ffffffffc0203aa8:	3fc50513          	addi	a0,a0,1020 # ffffffffc0206ea0 <etext+0x1546>
ffffffffc0203aac:	99ffc0ef          	jal	ffffffffc020044a <__panic>
    assert(mm != NULL);
ffffffffc0203ab0:	00003697          	auipc	a3,0x3
ffffffffc0203ab4:	47868693          	addi	a3,a3,1144 # ffffffffc0206f28 <etext+0x15ce>
ffffffffc0203ab8:	00003617          	auipc	a2,0x3
ffffffffc0203abc:	8d860613          	addi	a2,a2,-1832 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203ac0:	12400593          	li	a1,292
ffffffffc0203ac4:	00003517          	auipc	a0,0x3
ffffffffc0203ac8:	3dc50513          	addi	a0,a0,988 # ffffffffc0206ea0 <etext+0x1546>
ffffffffc0203acc:	97ffc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma != NULL);
ffffffffc0203ad0:	00003697          	auipc	a3,0x3
ffffffffc0203ad4:	4a868693          	addi	a3,a3,1192 # ffffffffc0206f78 <etext+0x161e>
ffffffffc0203ad8:	00003617          	auipc	a2,0x3
ffffffffc0203adc:	8b860613          	addi	a2,a2,-1864 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203ae0:	13300593          	li	a1,307
ffffffffc0203ae4:	00003517          	auipc	a0,0x3
ffffffffc0203ae8:	3bc50513          	addi	a0,a0,956 # ffffffffc0206ea0 <etext+0x1546>
ffffffffc0203aec:	95ffc0ef          	jal	ffffffffc020044a <__panic>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203af0:	00003697          	auipc	a3,0x3
ffffffffc0203af4:	4b068693          	addi	a3,a3,1200 # ffffffffc0206fa0 <etext+0x1646>
ffffffffc0203af8:	00003617          	auipc	a2,0x3
ffffffffc0203afc:	89860613          	addi	a2,a2,-1896 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203b00:	13d00593          	li	a1,317
ffffffffc0203b04:	00003517          	auipc	a0,0x3
ffffffffc0203b08:	39c50513          	addi	a0,a0,924 # ffffffffc0206ea0 <etext+0x1546>
ffffffffc0203b0c:	93ffc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203b10:	00003697          	auipc	a3,0x3
ffffffffc0203b14:	54868693          	addi	a3,a3,1352 # ffffffffc0207058 <etext+0x16fe>
ffffffffc0203b18:	00003617          	auipc	a2,0x3
ffffffffc0203b1c:	87860613          	addi	a2,a2,-1928 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203b20:	14f00593          	li	a1,335
ffffffffc0203b24:	00003517          	auipc	a0,0x3
ffffffffc0203b28:	37c50513          	addi	a0,a0,892 # ffffffffc0206ea0 <etext+0x1546>
ffffffffc0203b2c:	91ffc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203b30:	00003697          	auipc	a3,0x3
ffffffffc0203b34:	4f868693          	addi	a3,a3,1272 # ffffffffc0207028 <etext+0x16ce>
ffffffffc0203b38:	00003617          	auipc	a2,0x3
ffffffffc0203b3c:	85860613          	addi	a2,a2,-1960 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203b40:	14e00593          	li	a1,334
ffffffffc0203b44:	00003517          	auipc	a0,0x3
ffffffffc0203b48:	35c50513          	addi	a0,a0,860 # ffffffffc0206ea0 <etext+0x1546>
ffffffffc0203b4c:	8fffc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma5 == NULL);
ffffffffc0203b50:	00003697          	auipc	a3,0x3
ffffffffc0203b54:	4c868693          	addi	a3,a3,1224 # ffffffffc0207018 <etext+0x16be>
ffffffffc0203b58:	00003617          	auipc	a2,0x3
ffffffffc0203b5c:	83860613          	addi	a2,a2,-1992 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203b60:	14c00593          	li	a1,332
ffffffffc0203b64:	00003517          	auipc	a0,0x3
ffffffffc0203b68:	33c50513          	addi	a0,a0,828 # ffffffffc0206ea0 <etext+0x1546>
ffffffffc0203b6c:	8dffc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma4 == NULL);
ffffffffc0203b70:	00003697          	auipc	a3,0x3
ffffffffc0203b74:	49868693          	addi	a3,a3,1176 # ffffffffc0207008 <etext+0x16ae>
ffffffffc0203b78:	00003617          	auipc	a2,0x3
ffffffffc0203b7c:	81860613          	addi	a2,a2,-2024 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203b80:	14a00593          	li	a1,330
ffffffffc0203b84:	00003517          	auipc	a0,0x3
ffffffffc0203b88:	31c50513          	addi	a0,a0,796 # ffffffffc0206ea0 <etext+0x1546>
ffffffffc0203b8c:	8bffc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma3 == NULL);
ffffffffc0203b90:	00003697          	auipc	a3,0x3
ffffffffc0203b94:	46868693          	addi	a3,a3,1128 # ffffffffc0206ff8 <etext+0x169e>
ffffffffc0203b98:	00002617          	auipc	a2,0x2
ffffffffc0203b9c:	7f860613          	addi	a2,a2,2040 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203ba0:	14800593          	li	a1,328
ffffffffc0203ba4:	00003517          	auipc	a0,0x3
ffffffffc0203ba8:	2fc50513          	addi	a0,a0,764 # ffffffffc0206ea0 <etext+0x1546>
ffffffffc0203bac:	89ffc0ef          	jal	ffffffffc020044a <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203bb0:	00003697          	auipc	a3,0x3
ffffffffc0203bb4:	3d868693          	addi	a3,a3,984 # ffffffffc0206f88 <etext+0x162e>
ffffffffc0203bb8:	00002617          	auipc	a2,0x2
ffffffffc0203bbc:	7d860613          	addi	a2,a2,2008 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203bc0:	13b00593          	li	a1,315
ffffffffc0203bc4:	00003517          	auipc	a0,0x3
ffffffffc0203bc8:	2dc50513          	addi	a0,a0,732 # ffffffffc0206ea0 <etext+0x1546>
ffffffffc0203bcc:	87ffc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma2 != NULL);
ffffffffc0203bd0:	00003697          	auipc	a3,0x3
ffffffffc0203bd4:	41868693          	addi	a3,a3,1048 # ffffffffc0206fe8 <etext+0x168e>
ffffffffc0203bd8:	00002617          	auipc	a2,0x2
ffffffffc0203bdc:	7b860613          	addi	a2,a2,1976 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203be0:	14600593          	li	a1,326
ffffffffc0203be4:	00003517          	auipc	a0,0x3
ffffffffc0203be8:	2bc50513          	addi	a0,a0,700 # ffffffffc0206ea0 <etext+0x1546>
ffffffffc0203bec:	85ffc0ef          	jal	ffffffffc020044a <__panic>
        assert(vma1 != NULL);
ffffffffc0203bf0:	00003697          	auipc	a3,0x3
ffffffffc0203bf4:	3e868693          	addi	a3,a3,1000 # ffffffffc0206fd8 <etext+0x167e>
ffffffffc0203bf8:	00002617          	auipc	a2,0x2
ffffffffc0203bfc:	79860613          	addi	a2,a2,1944 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203c00:	14400593          	li	a1,324
ffffffffc0203c04:	00003517          	auipc	a0,0x3
ffffffffc0203c08:	29c50513          	addi	a0,a0,668 # ffffffffc0206ea0 <etext+0x1546>
ffffffffc0203c0c:	83ffc0ef          	jal	ffffffffc020044a <__panic>
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203c10:	6914                	ld	a3,16(a0)
ffffffffc0203c12:	6510                	ld	a2,8(a0)
ffffffffc0203c14:	0004859b          	sext.w	a1,s1
ffffffffc0203c18:	00003517          	auipc	a0,0x3
ffffffffc0203c1c:	47050513          	addi	a0,a0,1136 # ffffffffc0207088 <etext+0x172e>
ffffffffc0203c20:	d78fc0ef          	jal	ffffffffc0200198 <cprintf>
        assert(vma_below_5 == NULL);
ffffffffc0203c24:	00003697          	auipc	a3,0x3
ffffffffc0203c28:	48c68693          	addi	a3,a3,1164 # ffffffffc02070b0 <etext+0x1756>
ffffffffc0203c2c:	00002617          	auipc	a2,0x2
ffffffffc0203c30:	76460613          	addi	a2,a2,1892 # ffffffffc0206390 <etext+0xa36>
ffffffffc0203c34:	15900593          	li	a1,345
ffffffffc0203c38:	00003517          	auipc	a0,0x3
ffffffffc0203c3c:	26850513          	addi	a0,a0,616 # ffffffffc0206ea0 <etext+0x1546>
ffffffffc0203c40:	80bfc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0203c44 <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0203c44:	7179                	addi	sp,sp,-48
ffffffffc0203c46:	f022                	sd	s0,32(sp)
ffffffffc0203c48:	f406                	sd	ra,40(sp)
ffffffffc0203c4a:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0203c4c:	c52d                	beqz	a0,ffffffffc0203cb6 <user_mem_check+0x72>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0203c4e:	002007b7          	lui	a5,0x200
ffffffffc0203c52:	04f5ed63          	bltu	a1,a5,ffffffffc0203cac <user_mem_check+0x68>
ffffffffc0203c56:	ec26                	sd	s1,24(sp)
ffffffffc0203c58:	00c584b3          	add	s1,a1,a2
ffffffffc0203c5c:	0695ff63          	bgeu	a1,s1,ffffffffc0203cda <user_mem_check+0x96>
ffffffffc0203c60:	4785                	li	a5,1
ffffffffc0203c62:	07fe                	slli	a5,a5,0x1f
ffffffffc0203c64:	0785                	addi	a5,a5,1 # 200001 <_binary_obj___user_matrix_out_size+0x1f4ac1>
ffffffffc0203c66:	06f4fa63          	bgeu	s1,a5,ffffffffc0203cda <user_mem_check+0x96>
ffffffffc0203c6a:	e84a                	sd	s2,16(sp)
ffffffffc0203c6c:	e44e                	sd	s3,8(sp)
ffffffffc0203c6e:	8936                	mv	s2,a3
ffffffffc0203c70:	89aa                	mv	s3,a0
ffffffffc0203c72:	a829                	j	ffffffffc0203c8c <user_mem_check+0x48>
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203c74:	6685                	lui	a3,0x1
ffffffffc0203c76:	9736                	add	a4,a4,a3
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203c78:	0027f693          	andi	a3,a5,2
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203c7c:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203c7e:	c685                	beqz	a3,ffffffffc0203ca6 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203c80:	c399                	beqz	a5,ffffffffc0203c86 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203c82:	02e46263          	bltu	s0,a4,ffffffffc0203ca6 <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0203c86:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc0203c88:	04947b63          	bgeu	s0,s1,ffffffffc0203cde <user_mem_check+0x9a>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc0203c8c:	85a2                	mv	a1,s0
ffffffffc0203c8e:	854e                	mv	a0,s3
ffffffffc0203c90:	959ff0ef          	jal	ffffffffc02035e8 <find_vma>
ffffffffc0203c94:	c909                	beqz	a0,ffffffffc0203ca6 <user_mem_check+0x62>
ffffffffc0203c96:	6518                	ld	a4,8(a0)
ffffffffc0203c98:	00e46763          	bltu	s0,a4,ffffffffc0203ca6 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203c9c:	4d1c                	lw	a5,24(a0)
ffffffffc0203c9e:	fc091be3          	bnez	s2,ffffffffc0203c74 <user_mem_check+0x30>
ffffffffc0203ca2:	8b85                	andi	a5,a5,1
ffffffffc0203ca4:	f3ed                	bnez	a5,ffffffffc0203c86 <user_mem_check+0x42>
ffffffffc0203ca6:	64e2                	ld	s1,24(sp)
ffffffffc0203ca8:	6942                	ld	s2,16(sp)
ffffffffc0203caa:	69a2                	ld	s3,8(sp)
            return 0;
ffffffffc0203cac:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0203cae:	70a2                	ld	ra,40(sp)
ffffffffc0203cb0:	7402                	ld	s0,32(sp)
ffffffffc0203cb2:	6145                	addi	sp,sp,48
ffffffffc0203cb4:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203cb6:	c02007b7          	lui	a5,0xc0200
ffffffffc0203cba:	fef5eae3          	bltu	a1,a5,ffffffffc0203cae <user_mem_check+0x6a>
ffffffffc0203cbe:	c80007b7          	lui	a5,0xc8000
ffffffffc0203cc2:	962e                	add	a2,a2,a1
ffffffffc0203cc4:	0785                	addi	a5,a5,1 # ffffffffc8000001 <end+0x7d4a939>
ffffffffc0203cc6:	00c5b433          	sltu	s0,a1,a2
ffffffffc0203cca:	00f63633          	sltu	a2,a2,a5
}
ffffffffc0203cce:	70a2                	ld	ra,40(sp)
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203cd0:	00867533          	and	a0,a2,s0
}
ffffffffc0203cd4:	7402                	ld	s0,32(sp)
ffffffffc0203cd6:	6145                	addi	sp,sp,48
ffffffffc0203cd8:	8082                	ret
ffffffffc0203cda:	64e2                	ld	s1,24(sp)
ffffffffc0203cdc:	bfc1                	j	ffffffffc0203cac <user_mem_check+0x68>
ffffffffc0203cde:	64e2                	ld	s1,24(sp)
ffffffffc0203ce0:	6942                	ld	s2,16(sp)
ffffffffc0203ce2:	69a2                	ld	s3,8(sp)
        return 1;
ffffffffc0203ce4:	4505                	li	a0,1
ffffffffc0203ce6:	b7e1                	j	ffffffffc0203cae <user_mem_check+0x6a>

ffffffffc0203ce8 <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0203ce8:	8526                	mv	a0,s1
	jalr s0
ffffffffc0203cea:	9402                	jalr	s0

	jal do_exit
ffffffffc0203cec:	618000ef          	jal	ffffffffc0204304 <do_exit>

ffffffffc0203cf0 <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0203cf0:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203cf2:	14800513          	li	a0,328
{
ffffffffc0203cf6:	e022                	sd	s0,0(sp)
ffffffffc0203cf8:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203cfa:	f37fd0ef          	jal	ffffffffc0201c30 <kmalloc>
ffffffffc0203cfe:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0203d00:	cd35                	beqz	a0,ffffffffc0203d7c <alloc_proc+0x8c>
         *       struct trapframe *tf;                       // Trap frame for current interrupt
         *       uintptr_t pgdir;                            // the base addr of Page Directroy Table(PDT)
         *       uint32_t flags;                             // Process flag
         *       char name[PROC_NAME_LEN + 1];               // Process name
         */
        proc->state = PROC_UNINIT;
ffffffffc0203d02:	57fd                	li	a5,-1
ffffffffc0203d04:	1782                	slli	a5,a5,0x20
ffffffffc0203d06:	e11c                	sd	a5,0(a0)
        proc->pid = -1;
        proc->runs = 0;
ffffffffc0203d08:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0203d0c:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0203d10:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0203d14:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0203d18:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0203d1c:	07000613          	li	a2,112
ffffffffc0203d20:	4581                	li	a1,0
ffffffffc0203d22:	03050513          	addi	a0,a0,48
ffffffffc0203d26:	40b010ef          	jal	ffffffffc0205930 <memset>
        proc->tf = NULL;
        proc->pgdir = boot_pgdir_pa;
ffffffffc0203d2a:	000b2797          	auipc	a5,0xb2
ffffffffc0203d2e:	9467b783          	ld	a5,-1722(a5) # ffffffffc02b5670 <boot_pgdir_pa>
        proc->tf = NULL;
ffffffffc0203d32:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;
ffffffffc0203d36:	0a042823          	sw	zero,176(s0)
        proc->pgdir = boot_pgdir_pa;
ffffffffc0203d3a:	f45c                	sd	a5,168(s0)
        memset(proc->name, 0, sizeof(proc->name));
ffffffffc0203d3c:	0b440513          	addi	a0,s0,180
ffffffffc0203d40:	4641                	li	a2,16
ffffffffc0203d42:	4581                	li	a1,0
ffffffffc0203d44:	3ed010ef          	jal	ffffffffc0205930 <memset>
         *       skew_heap_entry_t lab6_run_pool;            // entry in the run pool (lab6 stride)
         *       uint32_t lab6_stride;                       // stride value (lab6 stride)
         *       uint32_t lab6_priority;                     // priority value (lab6 stride)
         */
        proc->rq = NULL;
        list_init(&(proc->run_link));
ffffffffc0203d48:	11040793          	addi	a5,s0,272
        proc->wait_state = 0;
ffffffffc0203d4c:	0e042623          	sw	zero,236(s0)
        proc->cptr = proc->optr = proc->yptr = NULL;
ffffffffc0203d50:	0e043c23          	sd	zero,248(s0)
ffffffffc0203d54:	10043023          	sd	zero,256(s0)
ffffffffc0203d58:	0e043823          	sd	zero,240(s0)
        proc->rq = NULL;
ffffffffc0203d5c:	10043423          	sd	zero,264(s0)
        proc->time_slice = 0;
ffffffffc0203d60:	12042023          	sw	zero,288(s0)
        proc->lab6_run_pool.left = proc->lab6_run_pool.right = proc->lab6_run_pool.parent = NULL;
ffffffffc0203d64:	12043423          	sd	zero,296(s0)
ffffffffc0203d68:	12043c23          	sd	zero,312(s0)
ffffffffc0203d6c:	12043823          	sd	zero,304(s0)
        proc->lab6_stride = 0;
ffffffffc0203d70:	14043023          	sd	zero,320(s0)
    elm->prev = elm->next = elm;
ffffffffc0203d74:	10f43c23          	sd	a5,280(s0)
ffffffffc0203d78:	10f43823          	sd	a5,272(s0)
        proc->lab6_priority = 0;
    }
    return proc;
}
ffffffffc0203d7c:	60a2                	ld	ra,8(sp)
ffffffffc0203d7e:	8522                	mv	a0,s0
ffffffffc0203d80:	6402                	ld	s0,0(sp)
ffffffffc0203d82:	0141                	addi	sp,sp,16
ffffffffc0203d84:	8082                	ret

ffffffffc0203d86 <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc0203d86:	000b2797          	auipc	a5,0xb2
ffffffffc0203d8a:	91a7b783          	ld	a5,-1766(a5) # ffffffffc02b56a0 <current>
ffffffffc0203d8e:	73c8                	ld	a0,160(a5)
ffffffffc0203d90:	92efd06f          	j	ffffffffc0200ebe <forkrets>

ffffffffc0203d94 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc0203d94:	6d14                	ld	a3,24(a0)
}

// put_pgdir - free the memory space of PDT
static void
put_pgdir(struct mm_struct *mm)
{
ffffffffc0203d96:	1141                	addi	sp,sp,-16
ffffffffc0203d98:	e406                	sd	ra,8(sp)
ffffffffc0203d9a:	c02007b7          	lui	a5,0xc0200
ffffffffc0203d9e:	02f6ee63          	bltu	a3,a5,ffffffffc0203dda <put_pgdir+0x46>
ffffffffc0203da2:	000b2717          	auipc	a4,0xb2
ffffffffc0203da6:	8de73703          	ld	a4,-1826(a4) # ffffffffc02b5680 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc0203daa:	000b2797          	auipc	a5,0xb2
ffffffffc0203dae:	8de7b783          	ld	a5,-1826(a5) # ffffffffc02b5688 <npage>
    return pa2page(PADDR(kva));
ffffffffc0203db2:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc0203db4:	82b1                	srli	a3,a3,0xc
ffffffffc0203db6:	02f6fe63          	bgeu	a3,a5,ffffffffc0203df2 <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc0203dba:	00004797          	auipc	a5,0x4
ffffffffc0203dbe:	4fe7b783          	ld	a5,1278(a5) # ffffffffc02082b8 <nbase>
ffffffffc0203dc2:	000b2517          	auipc	a0,0xb2
ffffffffc0203dc6:	8ce53503          	ld	a0,-1842(a0) # ffffffffc02b5690 <pages>
    free_page(kva2page(mm->pgdir));
}
ffffffffc0203dca:	60a2                	ld	ra,8(sp)
ffffffffc0203dcc:	8e9d                	sub	a3,a3,a5
ffffffffc0203dce:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc0203dd0:	4585                	li	a1,1
ffffffffc0203dd2:	9536                	add	a0,a0,a3
}
ffffffffc0203dd4:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc0203dd6:	856fe06f          	j	ffffffffc0201e2c <free_pages>
    return pa2page(PADDR(kva));
ffffffffc0203dda:	00003617          	auipc	a2,0x3
ffffffffc0203dde:	a0e60613          	addi	a2,a2,-1522 # ffffffffc02067e8 <etext+0xe8e>
ffffffffc0203de2:	07700593          	li	a1,119
ffffffffc0203de6:	00003517          	auipc	a0,0x3
ffffffffc0203dea:	98250513          	addi	a0,a0,-1662 # ffffffffc0206768 <etext+0xe0e>
ffffffffc0203dee:	e5cfc0ef          	jal	ffffffffc020044a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203df2:	00003617          	auipc	a2,0x3
ffffffffc0203df6:	a1e60613          	addi	a2,a2,-1506 # ffffffffc0206810 <etext+0xeb6>
ffffffffc0203dfa:	06900593          	li	a1,105
ffffffffc0203dfe:	00003517          	auipc	a0,0x3
ffffffffc0203e02:	96a50513          	addi	a0,a0,-1686 # ffffffffc0206768 <etext+0xe0e>
ffffffffc0203e06:	e44fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0203e0a <proc_run>:
    if (proc != current)
ffffffffc0203e0a:	000b2697          	auipc	a3,0xb2
ffffffffc0203e0e:	8966b683          	ld	a3,-1898(a3) # ffffffffc02b56a0 <current>
ffffffffc0203e12:	04a68563          	beq	a3,a0,ffffffffc0203e5c <proc_run+0x52>
{
ffffffffc0203e16:	1101                	addi	sp,sp,-32
ffffffffc0203e18:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203e1a:	100027f3          	csrr	a5,sstatus
ffffffffc0203e1e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203e20:	4601                	li	a2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203e22:	ef95                	bnez	a5,ffffffffc0203e5e <proc_run+0x54>
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned long pgdir)
{
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc0203e24:	755c                	ld	a5,168(a0)
ffffffffc0203e26:	577d                	li	a4,-1
ffffffffc0203e28:	177e                	slli	a4,a4,0x3f
ffffffffc0203e2a:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc0203e2e:	e032                	sd	a2,0(sp)
            current = proc;
ffffffffc0203e30:	000b2597          	auipc	a1,0xb2
ffffffffc0203e34:	86a5b823          	sd	a0,-1936(a1) # ffffffffc02b56a0 <current>
ffffffffc0203e38:	8fd9                	or	a5,a5,a4
ffffffffc0203e3a:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc0203e3e:	03050593          	addi	a1,a0,48
ffffffffc0203e42:	03068513          	addi	a0,a3,48
ffffffffc0203e46:	1de010ef          	jal	ffffffffc0205024 <switch_to>
    if (flag)
ffffffffc0203e4a:	6602                	ld	a2,0(sp)
ffffffffc0203e4c:	e601                	bnez	a2,ffffffffc0203e54 <proc_run+0x4a>
}
ffffffffc0203e4e:	60e2                	ld	ra,24(sp)
ffffffffc0203e50:	6105                	addi	sp,sp,32
ffffffffc0203e52:	8082                	ret
ffffffffc0203e54:	60e2                	ld	ra,24(sp)
ffffffffc0203e56:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0203e58:	aa1fc06f          	j	ffffffffc02008f8 <intr_enable>
ffffffffc0203e5c:	8082                	ret
ffffffffc0203e5e:	e42a                	sd	a0,8(sp)
ffffffffc0203e60:	e036                	sd	a3,0(sp)
        intr_disable();
ffffffffc0203e62:	a9dfc0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc0203e66:	6522                	ld	a0,8(sp)
ffffffffc0203e68:	6682                	ld	a3,0(sp)
ffffffffc0203e6a:	4605                	li	a2,1
ffffffffc0203e6c:	bf65                	j	ffffffffc0203e24 <proc_run+0x1a>

ffffffffc0203e6e <do_fork>:
 */
int do_fork(uint32_t clone_flags, uintptr_t stack, struct trapframe *tf)
{
    int ret = -E_NO_FREE_PROC;
    struct proc_struct *proc;
    if (nr_process >= MAX_PROCESS)
ffffffffc0203e6e:	000b2717          	auipc	a4,0xb2
ffffffffc0203e72:	82a72703          	lw	a4,-2006(a4) # ffffffffc02b5698 <nr_process>
ffffffffc0203e76:	6785                	lui	a5,0x1
ffffffffc0203e78:	36f75d63          	bge	a4,a5,ffffffffc02041f2 <do_fork+0x384>
{
ffffffffc0203e7c:	711d                	addi	sp,sp,-96
ffffffffc0203e7e:	e8a2                	sd	s0,80(sp)
ffffffffc0203e80:	e4a6                	sd	s1,72(sp)
ffffffffc0203e82:	e0ca                	sd	s2,64(sp)
ffffffffc0203e84:	e06a                	sd	s10,0(sp)
ffffffffc0203e86:	ec86                	sd	ra,88(sp)
ffffffffc0203e88:	892e                	mv	s2,a1
ffffffffc0203e8a:	84b2                	mv	s1,a2
ffffffffc0203e8c:	8d2a                	mv	s10,a0
    //    4. call copy_thread to setup tf & context in proc_struct
    //    5. insert proc_struct into hash_list && proc_list
    //    6. call wakeup_proc to make the new child process RUNNABLE
    //    7. set ret vaule using child proc's pid

    if ((proc = alloc_proc()) == NULL) {
ffffffffc0203e8e:	e63ff0ef          	jal	ffffffffc0203cf0 <alloc_proc>
ffffffffc0203e92:	842a                	mv	s0,a0
ffffffffc0203e94:	30050063          	beqz	a0,ffffffffc0204194 <do_fork+0x326>
        goto fork_out;
    }
    proc->parent = current;
ffffffffc0203e98:	f05a                	sd	s6,32(sp)
ffffffffc0203e9a:	000b2b17          	auipc	s6,0xb2
ffffffffc0203e9e:	806b0b13          	addi	s6,s6,-2042 # ffffffffc02b56a0 <current>
ffffffffc0203ea2:	000b3783          	ld	a5,0(s6)
    assert(current->wait_state == 0);
ffffffffc0203ea6:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_softint_out_size-0x7e3c>
    proc->parent = current;
ffffffffc0203eaa:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc0203eac:	3c071263          	bnez	a4,ffffffffc0204270 <do_fork+0x402>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc0203eb0:	4509                	li	a0,2
ffffffffc0203eb2:	f41fd0ef          	jal	ffffffffc0201df2 <alloc_pages>
    if (page != NULL)
ffffffffc0203eb6:	2c050b63          	beqz	a0,ffffffffc020418c <do_fork+0x31e>
ffffffffc0203eba:	fc4e                	sd	s3,56(sp)
    return page - pages + nbase;
ffffffffc0203ebc:	000b1997          	auipc	s3,0xb1
ffffffffc0203ec0:	7d498993          	addi	s3,s3,2004 # ffffffffc02b5690 <pages>
ffffffffc0203ec4:	0009b783          	ld	a5,0(s3)
ffffffffc0203ec8:	f852                	sd	s4,48(sp)
ffffffffc0203eca:	00004a17          	auipc	s4,0x4
ffffffffc0203ece:	3eea0a13          	addi	s4,s4,1006 # ffffffffc02082b8 <nbase>
ffffffffc0203ed2:	e466                	sd	s9,8(sp)
ffffffffc0203ed4:	000a3c83          	ld	s9,0(s4)
ffffffffc0203ed8:	40f506b3          	sub	a3,a0,a5
ffffffffc0203edc:	f456                	sd	s5,40(sp)
    return KADDR(page2pa(page));
ffffffffc0203ede:	000b1a97          	auipc	s5,0xb1
ffffffffc0203ee2:	7aaa8a93          	addi	s5,s5,1962 # ffffffffc02b5688 <npage>
ffffffffc0203ee6:	e862                	sd	s8,16(sp)
    return page - pages + nbase;
ffffffffc0203ee8:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0203eea:	5c7d                	li	s8,-1
ffffffffc0203eec:	000ab783          	ld	a5,0(s5)
    return page - pages + nbase;
ffffffffc0203ef0:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc0203ef2:	00cc5c13          	srli	s8,s8,0xc
ffffffffc0203ef6:	0186f733          	and	a4,a3,s8
ffffffffc0203efa:	ec5e                	sd	s7,24(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc0203efc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0203efe:	30f77863          	bgeu	a4,a5,ffffffffc020420e <do_fork+0x3a0>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc0203f02:	000b3703          	ld	a4,0(s6)
ffffffffc0203f06:	000b1b17          	auipc	s6,0xb1
ffffffffc0203f0a:	77ab0b13          	addi	s6,s6,1914 # ffffffffc02b5680 <va_pa_offset>
ffffffffc0203f0e:	000b3783          	ld	a5,0(s6)
ffffffffc0203f12:	02873b83          	ld	s7,40(a4)
ffffffffc0203f16:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0203f18:	e814                	sd	a3,16(s0)
    if (oldmm == NULL)
ffffffffc0203f1a:	020b8863          	beqz	s7,ffffffffc0203f4a <do_fork+0xdc>
    if (clone_flags & CLONE_VM)
ffffffffc0203f1e:	100d7793          	andi	a5,s10,256
ffffffffc0203f22:	18078b63          	beqz	a5,ffffffffc02040b8 <do_fork+0x24a>
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc0203f26:	030ba703          	lw	a4,48(s7)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0203f2a:	018bb783          	ld	a5,24(s7)
ffffffffc0203f2e:	c02006b7          	lui	a3,0xc0200
ffffffffc0203f32:	2705                	addiw	a4,a4,1
ffffffffc0203f34:	02eba823          	sw	a4,48(s7)
    proc->mm = mm;
ffffffffc0203f38:	03743423          	sd	s7,40(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0203f3c:	2ed7e563          	bltu	a5,a3,ffffffffc0204226 <do_fork+0x3b8>
ffffffffc0203f40:	000b3703          	ld	a4,0(s6)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0203f44:	6814                	ld	a3,16(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0203f46:	8f99                	sub	a5,a5,a4
ffffffffc0203f48:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0203f4a:	6789                	lui	a5,0x2
ffffffffc0203f4c:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_softint_out_size-0x7048>
ffffffffc0203f50:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc0203f52:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0203f54:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0203f56:	87b6                	mv	a5,a3
ffffffffc0203f58:	12048713          	addi	a4,s1,288
ffffffffc0203f5c:	6a0c                	ld	a1,16(a2)
ffffffffc0203f5e:	00063803          	ld	a6,0(a2)
ffffffffc0203f62:	6608                	ld	a0,8(a2)
ffffffffc0203f64:	eb8c                	sd	a1,16(a5)
ffffffffc0203f66:	0107b023          	sd	a6,0(a5)
ffffffffc0203f6a:	e788                	sd	a0,8(a5)
ffffffffc0203f6c:	6e0c                	ld	a1,24(a2)
ffffffffc0203f6e:	02060613          	addi	a2,a2,32
ffffffffc0203f72:	02078793          	addi	a5,a5,32
ffffffffc0203f76:	feb7bc23          	sd	a1,-8(a5)
ffffffffc0203f7a:	fee611e3          	bne	a2,a4,ffffffffc0203f5c <do_fork+0xee>
    proc->tf->gpr.a0 = 0;
ffffffffc0203f7e:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x6>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0203f82:	20090b63          	beqz	s2,ffffffffc0204198 <do_fork+0x32a>
ffffffffc0203f86:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0203f8a:	00000797          	auipc	a5,0x0
ffffffffc0203f8e:	dfc78793          	addi	a5,a5,-516 # ffffffffc0203d86 <forkret>
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc0203f92:	fc14                	sd	a3,56(s0)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0203f94:	f81c                	sd	a5,48(s0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203f96:	100027f3          	csrr	a5,sstatus
ffffffffc0203f9a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0203f9c:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203f9e:	20079c63          	bnez	a5,ffffffffc02041b6 <do_fork+0x348>
    if (++last_pid >= MAX_PID)
ffffffffc0203fa2:	000ad517          	auipc	a0,0xad
ffffffffc0203fa6:	24252503          	lw	a0,578(a0) # ffffffffc02b11e4 <last_pid.1>
ffffffffc0203faa:	6789                	lui	a5,0x2
ffffffffc0203fac:	2505                	addiw	a0,a0,1
ffffffffc0203fae:	000ad717          	auipc	a4,0xad
ffffffffc0203fb2:	22a72b23          	sw	a0,566(a4) # ffffffffc02b11e4 <last_pid.1>
ffffffffc0203fb6:	20f55f63          	bge	a0,a5,ffffffffc02041d4 <do_fork+0x366>
    if (last_pid >= next_safe)
ffffffffc0203fba:	000ad797          	auipc	a5,0xad
ffffffffc0203fbe:	2267a783          	lw	a5,550(a5) # ffffffffc02b11e0 <next_safe.0>
ffffffffc0203fc2:	000b1497          	auipc	s1,0xb1
ffffffffc0203fc6:	63e48493          	addi	s1,s1,1598 # ffffffffc02b5600 <proc_list>
ffffffffc0203fca:	06f54563          	blt	a0,a5,ffffffffc0204034 <do_fork+0x1c6>
    return listelm->next;
ffffffffc0203fce:	000b1497          	auipc	s1,0xb1
ffffffffc0203fd2:	63248493          	addi	s1,s1,1586 # ffffffffc02b5600 <proc_list>
ffffffffc0203fd6:	0084b883          	ld	a7,8(s1)
        next_safe = MAX_PID;
ffffffffc0203fda:	6789                	lui	a5,0x2
ffffffffc0203fdc:	000ad717          	auipc	a4,0xad
ffffffffc0203fe0:	20f72223          	sw	a5,516(a4) # ffffffffc02b11e0 <next_safe.0>
ffffffffc0203fe4:	86aa                	mv	a3,a0
ffffffffc0203fe6:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc0203fe8:	04988063          	beq	a7,s1,ffffffffc0204028 <do_fork+0x1ba>
ffffffffc0203fec:	882e                	mv	a6,a1
ffffffffc0203fee:	87c6                	mv	a5,a7
ffffffffc0203ff0:	6609                	lui	a2,0x2
ffffffffc0203ff2:	a811                	j	ffffffffc0204006 <do_fork+0x198>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc0203ff4:	00e6d663          	bge	a3,a4,ffffffffc0204000 <do_fork+0x192>
ffffffffc0203ff8:	00c75463          	bge	a4,a2,ffffffffc0204000 <do_fork+0x192>
                next_safe = proc->pid;
ffffffffc0203ffc:	863a                	mv	a2,a4
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc0203ffe:	4805                	li	a6,1
ffffffffc0204000:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204002:	00978d63          	beq	a5,s1,ffffffffc020401c <do_fork+0x1ae>
            if (proc->pid == last_pid)
ffffffffc0204006:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_softint_out_size-0x6fec>
ffffffffc020400a:	fed715e3          	bne	a4,a3,ffffffffc0203ff4 <do_fork+0x186>
                if (++last_pid >= next_safe)
ffffffffc020400e:	2685                	addiw	a3,a3,1
ffffffffc0204010:	1cc6db63          	bge	a3,a2,ffffffffc02041e6 <do_fork+0x378>
ffffffffc0204014:	679c                	ld	a5,8(a5)
ffffffffc0204016:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc0204018:	fe9797e3          	bne	a5,s1,ffffffffc0204006 <do_fork+0x198>
ffffffffc020401c:	00080663          	beqz	a6,ffffffffc0204028 <do_fork+0x1ba>
ffffffffc0204020:	000ad797          	auipc	a5,0xad
ffffffffc0204024:	1cc7a023          	sw	a2,448(a5) # ffffffffc02b11e0 <next_safe.0>
ffffffffc0204028:	c591                	beqz	a1,ffffffffc0204034 <do_fork+0x1c6>
ffffffffc020402a:	000ad797          	auipc	a5,0xad
ffffffffc020402e:	1ad7ad23          	sw	a3,442(a5) # ffffffffc02b11e4 <last_pid.1>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc0204032:	8536                	mv	a0,a3
    copy_thread(proc, stack, tf);

    bool intr_flag;
    local_intr_save(intr_flag);
    {
        proc->pid = get_pid();
ffffffffc0204034:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204036:	45a9                	li	a1,10
ffffffffc0204038:	462010ef          	jal	ffffffffc020549a <hash32>
ffffffffc020403c:	02051793          	slli	a5,a0,0x20
ffffffffc0204040:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204044:	000ad797          	auipc	a5,0xad
ffffffffc0204048:	5bc78793          	addi	a5,a5,1468 # ffffffffc02b1600 <hash_list>
ffffffffc020404c:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc020404e:	6518                	ld	a4,8(a0)
ffffffffc0204050:	0d840793          	addi	a5,s0,216
ffffffffc0204054:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc0204056:	e31c                	sd	a5,0(a4)
ffffffffc0204058:	e51c                	sd	a5,8(a0)
    elm->next = next;
ffffffffc020405a:	f078                	sd	a4,224(s0)
    list_add(&proc_list, &(proc->list_link));
ffffffffc020405c:	0c840793          	addi	a5,s0,200
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204060:	7018                	ld	a4,32(s0)
    elm->prev = prev;
ffffffffc0204062:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc0204064:	e21c                	sd	a5,0(a2)
    proc->yptr = NULL;
ffffffffc0204066:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc020406a:	7b74                	ld	a3,240(a4)
ffffffffc020406c:	e49c                	sd	a5,8(s1)
    elm->next = next;
ffffffffc020406e:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc0204070:	e464                	sd	s1,200(s0)
ffffffffc0204072:	10d43023          	sd	a3,256(s0)
ffffffffc0204076:	c299                	beqz	a3,ffffffffc020407c <do_fork+0x20e>
        proc->optr->yptr = proc;
ffffffffc0204078:	fee0                	sd	s0,248(a3)
    proc->parent->cptr = proc;
ffffffffc020407a:	7018                	ld	a4,32(s0)
    nr_process++;
ffffffffc020407c:	000b1797          	auipc	a5,0xb1
ffffffffc0204080:	61c7a783          	lw	a5,1564(a5) # ffffffffc02b5698 <nr_process>
    proc->parent->cptr = proc;
ffffffffc0204084:	fb60                	sd	s0,240(a4)
    nr_process++;
ffffffffc0204086:	2785                	addiw	a5,a5,1
ffffffffc0204088:	000b1717          	auipc	a4,0xb1
ffffffffc020408c:	60f72823          	sw	a5,1552(a4) # ffffffffc02b5698 <nr_process>
    if (flag)
ffffffffc0204090:	14091863          	bnez	s2,ffffffffc02041e0 <do_fork+0x372>
        hash_proc(proc);
        set_links(proc);
    }
    local_intr_restore(intr_flag);

    wakeup_proc(proc);
ffffffffc0204094:	8522                	mv	a0,s0
ffffffffc0204096:	15a010ef          	jal	ffffffffc02051f0 <wakeup_proc>

    ret = proc->pid;
ffffffffc020409a:	4048                	lw	a0,4(s0)
ffffffffc020409c:	79e2                	ld	s3,56(sp)
ffffffffc020409e:	7a42                	ld	s4,48(sp)
ffffffffc02040a0:	7aa2                	ld	s5,40(sp)
ffffffffc02040a2:	7b02                	ld	s6,32(sp)
ffffffffc02040a4:	6be2                	ld	s7,24(sp)
ffffffffc02040a6:	6c42                	ld	s8,16(sp)
ffffffffc02040a8:	6ca2                	ld	s9,8(sp)
bad_fork_cleanup_kstack:
    put_kstack(proc);
bad_fork_cleanup_proc:
    kfree(proc);
    goto fork_out;
}
ffffffffc02040aa:	60e6                	ld	ra,88(sp)
ffffffffc02040ac:	6446                	ld	s0,80(sp)
ffffffffc02040ae:	64a6                	ld	s1,72(sp)
ffffffffc02040b0:	6906                	ld	s2,64(sp)
ffffffffc02040b2:	6d02                	ld	s10,0(sp)
ffffffffc02040b4:	6125                	addi	sp,sp,96
ffffffffc02040b6:	8082                	ret
    if ((mm = mm_create()) == NULL)
ffffffffc02040b8:	d00ff0ef          	jal	ffffffffc02035b8 <mm_create>
ffffffffc02040bc:	8d2a                	mv	s10,a0
ffffffffc02040be:	c949                	beqz	a0,ffffffffc0204150 <do_fork+0x2e2>
    if ((page = alloc_page()) == NULL)
ffffffffc02040c0:	4505                	li	a0,1
ffffffffc02040c2:	d31fd0ef          	jal	ffffffffc0201df2 <alloc_pages>
ffffffffc02040c6:	c151                	beqz	a0,ffffffffc020414a <do_fork+0x2dc>
    return page - pages + nbase;
ffffffffc02040c8:	0009b703          	ld	a4,0(s3)
    return KADDR(page2pa(page));
ffffffffc02040cc:	000ab783          	ld	a5,0(s5)
    return page - pages + nbase;
ffffffffc02040d0:	40e506b3          	sub	a3,a0,a4
ffffffffc02040d4:	8699                	srai	a3,a3,0x6
ffffffffc02040d6:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc02040d8:	0186fc33          	and	s8,a3,s8
    return page2ppn(page) << PGSHIFT;
ffffffffc02040dc:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02040de:	1afc7f63          	bgeu	s8,a5,ffffffffc020429c <do_fork+0x42e>
ffffffffc02040e2:	000b3783          	ld	a5,0(s6)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc02040e6:	000b1597          	auipc	a1,0xb1
ffffffffc02040ea:	5925b583          	ld	a1,1426(a1) # ffffffffc02b5678 <boot_pgdir_va>
ffffffffc02040ee:	6605                	lui	a2,0x1
ffffffffc02040f0:	00f68c33          	add	s8,a3,a5
ffffffffc02040f4:	8562                	mv	a0,s8
ffffffffc02040f6:	04d010ef          	jal	ffffffffc0205942 <memcpy>
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
ffffffffc02040fa:	038b8c93          	addi	s9,s7,56
    mm->pgdir = pgdir;
ffffffffc02040fe:	018d3c23          	sd	s8,24(s10)
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0204102:	4c05                	li	s8,1
ffffffffc0204104:	418cb7af          	amoor.d	a5,s8,(s9)
}

static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))
ffffffffc0204108:	03f79713          	slli	a4,a5,0x3f
ffffffffc020410c:	03f75793          	srli	a5,a4,0x3f
ffffffffc0204110:	cb91                	beqz	a5,ffffffffc0204124 <do_fork+0x2b6>
    {
        schedule();
ffffffffc0204112:	1d6010ef          	jal	ffffffffc02052e8 <schedule>
ffffffffc0204116:	418cb7af          	amoor.d	a5,s8,(s9)
    while (!try_lock(lock))
ffffffffc020411a:	03f79713          	slli	a4,a5,0x3f
ffffffffc020411e:	03f75793          	srli	a5,a4,0x3f
ffffffffc0204122:	fbe5                	bnez	a5,ffffffffc0204112 <do_fork+0x2a4>
        ret = dup_mmap(mm, oldmm);
ffffffffc0204124:	85de                	mv	a1,s7
ffffffffc0204126:	856a                	mv	a0,s10
ffffffffc0204128:	eecff0ef          	jal	ffffffffc0203814 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc020412c:	57f9                	li	a5,-2
ffffffffc020412e:	60fcb7af          	amoand.d	a5,a5,(s9)
ffffffffc0204132:	8b85                	andi	a5,a5,1
}

static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))
ffffffffc0204134:	12078263          	beqz	a5,ffffffffc0204258 <do_fork+0x3ea>
    if ((mm = mm_create()) == NULL)
ffffffffc0204138:	8bea                	mv	s7,s10
    if (ret != 0)
ffffffffc020413a:	de0506e3          	beqz	a0,ffffffffc0203f26 <do_fork+0xb8>
    exit_mmap(mm);
ffffffffc020413e:	856a                	mv	a0,s10
ffffffffc0204140:	f6cff0ef          	jal	ffffffffc02038ac <exit_mmap>
    put_pgdir(mm);
ffffffffc0204144:	856a                	mv	a0,s10
ffffffffc0204146:	c4fff0ef          	jal	ffffffffc0203d94 <put_pgdir>
    mm_destroy(mm);
ffffffffc020414a:	856a                	mv	a0,s10
ffffffffc020414c:	daaff0ef          	jal	ffffffffc02036f6 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204150:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0204152:	c02007b7          	lui	a5,0xc0200
ffffffffc0204156:	0ef6e563          	bltu	a3,a5,ffffffffc0204240 <do_fork+0x3d2>
ffffffffc020415a:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage)
ffffffffc020415e:	000ab703          	ld	a4,0(s5)
    return pa2page(PADDR(kva));
ffffffffc0204162:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage)
ffffffffc0204166:	83b1                	srli	a5,a5,0xc
ffffffffc0204168:	08e7f763          	bgeu	a5,a4,ffffffffc02041f6 <do_fork+0x388>
    return &pages[PPN(pa) - nbase];
ffffffffc020416c:	000a3703          	ld	a4,0(s4)
ffffffffc0204170:	0009b503          	ld	a0,0(s3)
ffffffffc0204174:	4589                	li	a1,2
ffffffffc0204176:	8f99                	sub	a5,a5,a4
ffffffffc0204178:	079a                	slli	a5,a5,0x6
ffffffffc020417a:	953e                	add	a0,a0,a5
ffffffffc020417c:	cb1fd0ef          	jal	ffffffffc0201e2c <free_pages>
}
ffffffffc0204180:	79e2                	ld	s3,56(sp)
ffffffffc0204182:	7a42                	ld	s4,48(sp)
ffffffffc0204184:	7aa2                	ld	s5,40(sp)
ffffffffc0204186:	6be2                	ld	s7,24(sp)
ffffffffc0204188:	6c42                	ld	s8,16(sp)
ffffffffc020418a:	6ca2                	ld	s9,8(sp)
    kfree(proc);
ffffffffc020418c:	8522                	mv	a0,s0
ffffffffc020418e:	b49fd0ef          	jal	ffffffffc0201cd6 <kfree>
ffffffffc0204192:	7b02                	ld	s6,32(sp)
    ret = -E_NO_MEM;
ffffffffc0204194:	5571                	li	a0,-4
    return ret;
ffffffffc0204196:	bf11                	j	ffffffffc02040aa <do_fork+0x23c>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc0204198:	8936                	mv	s2,a3
ffffffffc020419a:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc020419e:	00000797          	auipc	a5,0x0
ffffffffc02041a2:	be878793          	addi	a5,a5,-1048 # ffffffffc0203d86 <forkret>
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02041a6:	fc14                	sd	a3,56(s0)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02041a8:	f81c                	sd	a5,48(s0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02041aa:	100027f3          	csrr	a5,sstatus
ffffffffc02041ae:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02041b0:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02041b2:	de0788e3          	beqz	a5,ffffffffc0203fa2 <do_fork+0x134>
        intr_disable();
ffffffffc02041b6:	f48fc0ef          	jal	ffffffffc02008fe <intr_disable>
    if (++last_pid >= MAX_PID)
ffffffffc02041ba:	000ad517          	auipc	a0,0xad
ffffffffc02041be:	02a52503          	lw	a0,42(a0) # ffffffffc02b11e4 <last_pid.1>
ffffffffc02041c2:	6789                	lui	a5,0x2
        return 1;
ffffffffc02041c4:	4905                	li	s2,1
ffffffffc02041c6:	2505                	addiw	a0,a0,1
ffffffffc02041c8:	000ad717          	auipc	a4,0xad
ffffffffc02041cc:	00a72e23          	sw	a0,28(a4) # ffffffffc02b11e4 <last_pid.1>
ffffffffc02041d0:	def545e3          	blt	a0,a5,ffffffffc0203fba <do_fork+0x14c>
        last_pid = 1;
ffffffffc02041d4:	4505                	li	a0,1
ffffffffc02041d6:	000ad797          	auipc	a5,0xad
ffffffffc02041da:	00a7a723          	sw	a0,14(a5) # ffffffffc02b11e4 <last_pid.1>
        goto inside;
ffffffffc02041de:	bbc5                	j	ffffffffc0203fce <do_fork+0x160>
        intr_enable();
ffffffffc02041e0:	f18fc0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc02041e4:	bd45                	j	ffffffffc0204094 <do_fork+0x226>
                    if (last_pid >= MAX_PID)
ffffffffc02041e6:	6789                	lui	a5,0x2
ffffffffc02041e8:	00f6c363          	blt	a3,a5,ffffffffc02041ee <do_fork+0x380>
                        last_pid = 1;
ffffffffc02041ec:	4685                	li	a3,1
                    goto repeat;
ffffffffc02041ee:	4585                	li	a1,1
ffffffffc02041f0:	bbe5                	j	ffffffffc0203fe8 <do_fork+0x17a>
    int ret = -E_NO_FREE_PROC;
ffffffffc02041f2:	556d                	li	a0,-5
}
ffffffffc02041f4:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc02041f6:	00002617          	auipc	a2,0x2
ffffffffc02041fa:	61a60613          	addi	a2,a2,1562 # ffffffffc0206810 <etext+0xeb6>
ffffffffc02041fe:	06900593          	li	a1,105
ffffffffc0204202:	00002517          	auipc	a0,0x2
ffffffffc0204206:	56650513          	addi	a0,a0,1382 # ffffffffc0206768 <etext+0xe0e>
ffffffffc020420a:	a40fc0ef          	jal	ffffffffc020044a <__panic>
    return KADDR(page2pa(page));
ffffffffc020420e:	00002617          	auipc	a2,0x2
ffffffffc0204212:	53260613          	addi	a2,a2,1330 # ffffffffc0206740 <etext+0xde6>
ffffffffc0204216:	07100593          	li	a1,113
ffffffffc020421a:	00002517          	auipc	a0,0x2
ffffffffc020421e:	54e50513          	addi	a0,a0,1358 # ffffffffc0206768 <etext+0xe0e>
ffffffffc0204222:	a28fc0ef          	jal	ffffffffc020044a <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204226:	86be                	mv	a3,a5
ffffffffc0204228:	00002617          	auipc	a2,0x2
ffffffffc020422c:	5c060613          	addi	a2,a2,1472 # ffffffffc02067e8 <etext+0xe8e>
ffffffffc0204230:	1a000593          	li	a1,416
ffffffffc0204234:	00003517          	auipc	a0,0x3
ffffffffc0204238:	eec50513          	addi	a0,a0,-276 # ffffffffc0207120 <etext+0x17c6>
ffffffffc020423c:	a0efc0ef          	jal	ffffffffc020044a <__panic>
    return pa2page(PADDR(kva));
ffffffffc0204240:	00002617          	auipc	a2,0x2
ffffffffc0204244:	5a860613          	addi	a2,a2,1448 # ffffffffc02067e8 <etext+0xe8e>
ffffffffc0204248:	07700593          	li	a1,119
ffffffffc020424c:	00002517          	auipc	a0,0x2
ffffffffc0204250:	51c50513          	addi	a0,a0,1308 # ffffffffc0206768 <etext+0xe0e>
ffffffffc0204254:	9f6fc0ef          	jal	ffffffffc020044a <__panic>
    {
        panic("Unlock failed.\n");
ffffffffc0204258:	00003617          	auipc	a2,0x3
ffffffffc020425c:	ee060613          	addi	a2,a2,-288 # ffffffffc0207138 <etext+0x17de>
ffffffffc0204260:	04000593          	li	a1,64
ffffffffc0204264:	00003517          	auipc	a0,0x3
ffffffffc0204268:	ee450513          	addi	a0,a0,-284 # ffffffffc0207148 <etext+0x17ee>
ffffffffc020426c:	9defc0ef          	jal	ffffffffc020044a <__panic>
    assert(current->wait_state == 0);
ffffffffc0204270:	00003697          	auipc	a3,0x3
ffffffffc0204274:	e9068693          	addi	a3,a3,-368 # ffffffffc0207100 <etext+0x17a6>
ffffffffc0204278:	00002617          	auipc	a2,0x2
ffffffffc020427c:	11860613          	addi	a2,a2,280 # ffffffffc0206390 <etext+0xa36>
ffffffffc0204280:	1e700593          	li	a1,487
ffffffffc0204284:	00003517          	auipc	a0,0x3
ffffffffc0204288:	e9c50513          	addi	a0,a0,-356 # ffffffffc0207120 <etext+0x17c6>
ffffffffc020428c:	fc4e                	sd	s3,56(sp)
ffffffffc020428e:	f852                	sd	s4,48(sp)
ffffffffc0204290:	f456                	sd	s5,40(sp)
ffffffffc0204292:	ec5e                	sd	s7,24(sp)
ffffffffc0204294:	e862                	sd	s8,16(sp)
ffffffffc0204296:	e466                	sd	s9,8(sp)
ffffffffc0204298:	9b2fc0ef          	jal	ffffffffc020044a <__panic>
    return KADDR(page2pa(page));
ffffffffc020429c:	00002617          	auipc	a2,0x2
ffffffffc02042a0:	4a460613          	addi	a2,a2,1188 # ffffffffc0206740 <etext+0xde6>
ffffffffc02042a4:	07100593          	li	a1,113
ffffffffc02042a8:	00002517          	auipc	a0,0x2
ffffffffc02042ac:	4c050513          	addi	a0,a0,1216 # ffffffffc0206768 <etext+0xe0e>
ffffffffc02042b0:	99afc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02042b4 <kernel_thread>:
{
ffffffffc02042b4:	7129                	addi	sp,sp,-320
ffffffffc02042b6:	fa22                	sd	s0,304(sp)
ffffffffc02042b8:	f626                	sd	s1,296(sp)
ffffffffc02042ba:	f24a                	sd	s2,288(sp)
ffffffffc02042bc:	842a                	mv	s0,a0
ffffffffc02042be:	84ae                	mv	s1,a1
ffffffffc02042c0:	8932                	mv	s2,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02042c2:	850a                	mv	a0,sp
ffffffffc02042c4:	12000613          	li	a2,288
ffffffffc02042c8:	4581                	li	a1,0
{
ffffffffc02042ca:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02042cc:	664010ef          	jal	ffffffffc0205930 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02042d0:	e0a2                	sd	s0,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02042d2:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02042d4:	100027f3          	csrr	a5,sstatus
ffffffffc02042d8:	edd7f793          	andi	a5,a5,-291
ffffffffc02042dc:	1207e793          	ori	a5,a5,288
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02042e0:	860a                	mv	a2,sp
ffffffffc02042e2:	10096513          	ori	a0,s2,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02042e6:	00000717          	auipc	a4,0x0
ffffffffc02042ea:	a0270713          	addi	a4,a4,-1534 # ffffffffc0203ce8 <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02042ee:	4581                	li	a1,0
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02042f0:	e23e                	sd	a5,256(sp)
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02042f2:	e63a                	sd	a4,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02042f4:	b7bff0ef          	jal	ffffffffc0203e6e <do_fork>
}
ffffffffc02042f8:	70f2                	ld	ra,312(sp)
ffffffffc02042fa:	7452                	ld	s0,304(sp)
ffffffffc02042fc:	74b2                	ld	s1,296(sp)
ffffffffc02042fe:	7912                	ld	s2,288(sp)
ffffffffc0204300:	6131                	addi	sp,sp,320
ffffffffc0204302:	8082                	ret

ffffffffc0204304 <do_exit>:
// do_exit - called by sys_exit
//   1. call exit_mmap & put_pgdir & mm_destroy to free the almost all memory space of process
//   2. set process' state as PROC_ZOMBIE, then call wakeup_proc(parent) to ask parent reclaim itself.
//   3. call scheduler to switch to other process
int do_exit(int error_code)
{
ffffffffc0204304:	7179                	addi	sp,sp,-48
ffffffffc0204306:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc0204308:	000b1417          	auipc	s0,0xb1
ffffffffc020430c:	39840413          	addi	s0,s0,920 # ffffffffc02b56a0 <current>
ffffffffc0204310:	601c                	ld	a5,0(s0)
ffffffffc0204312:	000b1717          	auipc	a4,0xb1
ffffffffc0204316:	39e73703          	ld	a4,926(a4) # ffffffffc02b56b0 <idleproc>
{
ffffffffc020431a:	f406                	sd	ra,40(sp)
ffffffffc020431c:	ec26                	sd	s1,24(sp)
    if (current == idleproc)
ffffffffc020431e:	0ce78b63          	beq	a5,a4,ffffffffc02043f4 <do_exit+0xf0>
    {
        panic("idleproc exit.\n");
    }
    if (current == initproc)
ffffffffc0204322:	000b1497          	auipc	s1,0xb1
ffffffffc0204326:	38648493          	addi	s1,s1,902 # ffffffffc02b56a8 <initproc>
ffffffffc020432a:	6098                	ld	a4,0(s1)
ffffffffc020432c:	e84a                	sd	s2,16(sp)
ffffffffc020432e:	0ee78a63          	beq	a5,a4,ffffffffc0204422 <do_exit+0x11e>
ffffffffc0204332:	892a                	mv	s2,a0
    {
        panic("initproc exit.\n");
    }
    struct mm_struct *mm = current->mm;
ffffffffc0204334:	7788                	ld	a0,40(a5)
    if (mm != NULL)
ffffffffc0204336:	c115                	beqz	a0,ffffffffc020435a <do_exit+0x56>
ffffffffc0204338:	000b1797          	auipc	a5,0xb1
ffffffffc020433c:	3387b783          	ld	a5,824(a5) # ffffffffc02b5670 <boot_pgdir_pa>
ffffffffc0204340:	577d                	li	a4,-1
ffffffffc0204342:	177e                	slli	a4,a4,0x3f
ffffffffc0204344:	83b1                	srli	a5,a5,0xc
ffffffffc0204346:	8fd9                	or	a5,a5,a4
ffffffffc0204348:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc020434c:	591c                	lw	a5,48(a0)
ffffffffc020434e:	37fd                	addiw	a5,a5,-1
ffffffffc0204350:	d91c                	sw	a5,48(a0)
    {
        lsatp(boot_pgdir_pa);
        if (mm_count_dec(mm) == 0)
ffffffffc0204352:	cfd5                	beqz	a5,ffffffffc020440e <do_exit+0x10a>
        {
            exit_mmap(mm);
            put_pgdir(mm);
            mm_destroy(mm);
        }
        current->mm = NULL;
ffffffffc0204354:	601c                	ld	a5,0(s0)
ffffffffc0204356:	0207b423          	sd	zero,40(a5)
    }
    current->state = PROC_ZOMBIE;
ffffffffc020435a:	470d                	li	a4,3
    current->exit_code = error_code;
ffffffffc020435c:	0f27a423          	sw	s2,232(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0204360:	c398                	sw	a4,0(a5)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204362:	100027f3          	csrr	a5,sstatus
ffffffffc0204366:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204368:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020436a:	ebe1                	bnez	a5,ffffffffc020443a <do_exit+0x136>
    bool intr_flag;
    struct proc_struct *proc;
    local_intr_save(intr_flag);
    {
        proc = current->parent;
ffffffffc020436c:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc020436e:	800007b7          	lui	a5,0x80000
ffffffffc0204372:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_obj___user_matrix_out_size+0xffffffff7fff4ac1>
        proc = current->parent;
ffffffffc0204374:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204376:	0ec52703          	lw	a4,236(a0)
ffffffffc020437a:	0cf70463          	beq	a4,a5,ffffffffc0204442 <do_exit+0x13e>
        {
            wakeup_proc(proc);
        }
        while (current->cptr != NULL)
ffffffffc020437e:	6018                	ld	a4,0(s0)
            }
            proc->parent = initproc;
            initproc->cptr = proc;
            if (proc->state == PROC_ZOMBIE)
            {
                if (initproc->wait_state == WT_CHILD)
ffffffffc0204380:	800005b7          	lui	a1,0x80000
ffffffffc0204384:	0585                	addi	a1,a1,1 # ffffffff80000001 <_binary_obj___user_matrix_out_size+0xffffffff7fff4ac1>
        while (current->cptr != NULL)
ffffffffc0204386:	7b7c                	ld	a5,240(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204388:	460d                	li	a2,3
        while (current->cptr != NULL)
ffffffffc020438a:	e789                	bnez	a5,ffffffffc0204394 <do_exit+0x90>
ffffffffc020438c:	a83d                	j	ffffffffc02043ca <do_exit+0xc6>
ffffffffc020438e:	6018                	ld	a4,0(s0)
ffffffffc0204390:	7b7c                	ld	a5,240(a4)
ffffffffc0204392:	cf85                	beqz	a5,ffffffffc02043ca <do_exit+0xc6>
            current->cptr = proc->optr;
ffffffffc0204394:	1007b683          	ld	a3,256(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc0204398:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc020439a:	fb74                	sd	a3,240(a4)
            proc->yptr = NULL;
ffffffffc020439c:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc02043a0:	7978                	ld	a4,240(a0)
ffffffffc02043a2:	10e7b023          	sd	a4,256(a5)
ffffffffc02043a6:	c311                	beqz	a4,ffffffffc02043aa <do_exit+0xa6>
                initproc->cptr->yptr = proc;
ffffffffc02043a8:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc02043aa:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02043ac:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02043ae:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc02043b0:	fcc71fe3          	bne	a4,a2,ffffffffc020438e <do_exit+0x8a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc02043b4:	0ec52783          	lw	a5,236(a0)
ffffffffc02043b8:	fcb79be3          	bne	a5,a1,ffffffffc020438e <do_exit+0x8a>
                {
                    wakeup_proc(initproc);
ffffffffc02043bc:	635000ef          	jal	ffffffffc02051f0 <wakeup_proc>
ffffffffc02043c0:	800005b7          	lui	a1,0x80000
ffffffffc02043c4:	0585                	addi	a1,a1,1 # ffffffff80000001 <_binary_obj___user_matrix_out_size+0xffffffff7fff4ac1>
ffffffffc02043c6:	460d                	li	a2,3
ffffffffc02043c8:	b7d9                	j	ffffffffc020438e <do_exit+0x8a>
    if (flag)
ffffffffc02043ca:	02091263          	bnez	s2,ffffffffc02043ee <do_exit+0xea>
                }
            }
        }
    }
    local_intr_restore(intr_flag);
    schedule();
ffffffffc02043ce:	71b000ef          	jal	ffffffffc02052e8 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02043d2:	601c                	ld	a5,0(s0)
ffffffffc02043d4:	00003617          	auipc	a2,0x3
ffffffffc02043d8:	dac60613          	addi	a2,a2,-596 # ffffffffc0207180 <etext+0x1826>
ffffffffc02043dc:	24e00593          	li	a1,590
ffffffffc02043e0:	43d4                	lw	a3,4(a5)
ffffffffc02043e2:	00003517          	auipc	a0,0x3
ffffffffc02043e6:	d3e50513          	addi	a0,a0,-706 # ffffffffc0207120 <etext+0x17c6>
ffffffffc02043ea:	860fc0ef          	jal	ffffffffc020044a <__panic>
        intr_enable();
ffffffffc02043ee:	d0afc0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc02043f2:	bff1                	j	ffffffffc02043ce <do_exit+0xca>
        panic("idleproc exit.\n");
ffffffffc02043f4:	00003617          	auipc	a2,0x3
ffffffffc02043f8:	d6c60613          	addi	a2,a2,-660 # ffffffffc0207160 <etext+0x1806>
ffffffffc02043fc:	21a00593          	li	a1,538
ffffffffc0204400:	00003517          	auipc	a0,0x3
ffffffffc0204404:	d2050513          	addi	a0,a0,-736 # ffffffffc0207120 <etext+0x17c6>
ffffffffc0204408:	e84a                	sd	s2,16(sp)
ffffffffc020440a:	840fc0ef          	jal	ffffffffc020044a <__panic>
            exit_mmap(mm);
ffffffffc020440e:	e42a                	sd	a0,8(sp)
ffffffffc0204410:	c9cff0ef          	jal	ffffffffc02038ac <exit_mmap>
            put_pgdir(mm);
ffffffffc0204414:	6522                	ld	a0,8(sp)
ffffffffc0204416:	97fff0ef          	jal	ffffffffc0203d94 <put_pgdir>
            mm_destroy(mm);
ffffffffc020441a:	6522                	ld	a0,8(sp)
ffffffffc020441c:	adaff0ef          	jal	ffffffffc02036f6 <mm_destroy>
ffffffffc0204420:	bf15                	j	ffffffffc0204354 <do_exit+0x50>
        panic("initproc exit.\n");
ffffffffc0204422:	00003617          	auipc	a2,0x3
ffffffffc0204426:	d4e60613          	addi	a2,a2,-690 # ffffffffc0207170 <etext+0x1816>
ffffffffc020442a:	21e00593          	li	a1,542
ffffffffc020442e:	00003517          	auipc	a0,0x3
ffffffffc0204432:	cf250513          	addi	a0,a0,-782 # ffffffffc0207120 <etext+0x17c6>
ffffffffc0204436:	814fc0ef          	jal	ffffffffc020044a <__panic>
        intr_disable();
ffffffffc020443a:	cc4fc0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc020443e:	4905                	li	s2,1
ffffffffc0204440:	b735                	j	ffffffffc020436c <do_exit+0x68>
            wakeup_proc(proc);
ffffffffc0204442:	5af000ef          	jal	ffffffffc02051f0 <wakeup_proc>
ffffffffc0204446:	bf25                	j	ffffffffc020437e <do_exit+0x7a>

ffffffffc0204448 <do_wait.part.0>:
}

// do_wait - wait one OR any children with PROC_ZOMBIE state, and free memory space of kernel stack
//         - proc struct of this child.
// NOTE: only after do_wait function, all resources of the child proces are free.
int do_wait(int pid, int *code_store)
ffffffffc0204448:	7179                	addi	sp,sp,-48
ffffffffc020444a:	ec26                	sd	s1,24(sp)
ffffffffc020444c:	e84a                	sd	s2,16(sp)
ffffffffc020444e:	e44e                	sd	s3,8(sp)
ffffffffc0204450:	f406                	sd	ra,40(sp)
ffffffffc0204452:	f022                	sd	s0,32(sp)
ffffffffc0204454:	84aa                	mv	s1,a0
ffffffffc0204456:	892e                	mv	s2,a1
ffffffffc0204458:	000b1997          	auipc	s3,0xb1
ffffffffc020445c:	24898993          	addi	s3,s3,584 # ffffffffc02b56a0 <current>

    struct proc_struct *proc;
    bool intr_flag, haskid;
repeat:
    haskid = 0;
    if (pid != 0)
ffffffffc0204460:	cd19                	beqz	a0,ffffffffc020447e <do_wait.part.0+0x36>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204462:	6789                	lui	a5,0x2
ffffffffc0204464:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x6f2a>
ffffffffc0204466:	fff5071b          	addiw	a4,a0,-1
ffffffffc020446a:	12e7f563          	bgeu	a5,a4,ffffffffc0204594 <do_wait.part.0+0x14c>
    }
    local_intr_restore(intr_flag);
    put_kstack(proc);
    kfree(proc);
    return 0;
}
ffffffffc020446e:	70a2                	ld	ra,40(sp)
ffffffffc0204470:	7402                	ld	s0,32(sp)
ffffffffc0204472:	64e2                	ld	s1,24(sp)
ffffffffc0204474:	6942                	ld	s2,16(sp)
ffffffffc0204476:	69a2                	ld	s3,8(sp)
    return -E_BAD_PROC;
ffffffffc0204478:	5579                	li	a0,-2
}
ffffffffc020447a:	6145                	addi	sp,sp,48
ffffffffc020447c:	8082                	ret
        proc = current->cptr;
ffffffffc020447e:	0009b703          	ld	a4,0(s3)
ffffffffc0204482:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr)
ffffffffc0204484:	d46d                	beqz	s0,ffffffffc020446e <do_wait.part.0+0x26>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204486:	468d                	li	a3,3
ffffffffc0204488:	a021                	j	ffffffffc0204490 <do_wait.part.0+0x48>
        for (; proc != NULL; proc = proc->optr)
ffffffffc020448a:	10043403          	ld	s0,256(s0)
ffffffffc020448e:	c075                	beqz	s0,ffffffffc0204572 <do_wait.part.0+0x12a>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204490:	401c                	lw	a5,0(s0)
ffffffffc0204492:	fed79ce3          	bne	a5,a3,ffffffffc020448a <do_wait.part.0+0x42>
    if (proc == idleproc || proc == initproc)
ffffffffc0204496:	000b1797          	auipc	a5,0xb1
ffffffffc020449a:	21a7b783          	ld	a5,538(a5) # ffffffffc02b56b0 <idleproc>
ffffffffc020449e:	14878263          	beq	a5,s0,ffffffffc02045e2 <do_wait.part.0+0x19a>
ffffffffc02044a2:	000b1797          	auipc	a5,0xb1
ffffffffc02044a6:	2067b783          	ld	a5,518(a5) # ffffffffc02b56a8 <initproc>
ffffffffc02044aa:	12f40c63          	beq	s0,a5,ffffffffc02045e2 <do_wait.part.0+0x19a>
    if (code_store != NULL)
ffffffffc02044ae:	00090663          	beqz	s2,ffffffffc02044ba <do_wait.part.0+0x72>
        *code_store = proc->exit_code;
ffffffffc02044b2:	0e842783          	lw	a5,232(s0)
ffffffffc02044b6:	00f92023          	sw	a5,0(s2)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02044ba:	100027f3          	csrr	a5,sstatus
ffffffffc02044be:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02044c0:	4601                	li	a2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02044c2:	10079963          	bnez	a5,ffffffffc02045d4 <do_wait.part.0+0x18c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02044c6:	6c74                	ld	a3,216(s0)
ffffffffc02044c8:	7078                	ld	a4,224(s0)
    if (proc->optr != NULL)
ffffffffc02044ca:	10043783          	ld	a5,256(s0)
    prev->next = next;
ffffffffc02044ce:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02044d0:	e314                	sd	a3,0(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc02044d2:	6474                	ld	a3,200(s0)
ffffffffc02044d4:	6878                	ld	a4,208(s0)
    prev->next = next;
ffffffffc02044d6:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02044d8:	e314                	sd	a3,0(a4)
ffffffffc02044da:	c789                	beqz	a5,ffffffffc02044e4 <do_wait.part.0+0x9c>
        proc->optr->yptr = proc->yptr;
ffffffffc02044dc:	7c78                	ld	a4,248(s0)
ffffffffc02044de:	fff8                	sd	a4,248(a5)
        proc->yptr->optr = proc->optr;
ffffffffc02044e0:	10043783          	ld	a5,256(s0)
    if (proc->yptr != NULL)
ffffffffc02044e4:	7c78                	ld	a4,248(s0)
ffffffffc02044e6:	c36d                	beqz	a4,ffffffffc02045c8 <do_wait.part.0+0x180>
        proc->yptr->optr = proc->optr;
ffffffffc02044e8:	10f73023          	sd	a5,256(a4)
    nr_process--;
ffffffffc02044ec:	000b1797          	auipc	a5,0xb1
ffffffffc02044f0:	1ac7a783          	lw	a5,428(a5) # ffffffffc02b5698 <nr_process>
ffffffffc02044f4:	37fd                	addiw	a5,a5,-1
ffffffffc02044f6:	000b1717          	auipc	a4,0xb1
ffffffffc02044fa:	1af72123          	sw	a5,418(a4) # ffffffffc02b5698 <nr_process>
    if (flag)
ffffffffc02044fe:	e271                	bnez	a2,ffffffffc02045c2 <do_wait.part.0+0x17a>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc0204500:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc0204502:	c02007b7          	lui	a5,0xc0200
ffffffffc0204506:	10f6e663          	bltu	a3,a5,ffffffffc0204612 <do_wait.part.0+0x1ca>
ffffffffc020450a:	000b1717          	auipc	a4,0xb1
ffffffffc020450e:	17673703          	ld	a4,374(a4) # ffffffffc02b5680 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc0204512:	000b1797          	auipc	a5,0xb1
ffffffffc0204516:	1767b783          	ld	a5,374(a5) # ffffffffc02b5688 <npage>
    return pa2page(PADDR(kva));
ffffffffc020451a:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc020451c:	82b1                	srli	a3,a3,0xc
ffffffffc020451e:	0cf6fe63          	bgeu	a3,a5,ffffffffc02045fa <do_wait.part.0+0x1b2>
    return &pages[PPN(pa) - nbase];
ffffffffc0204522:	00004797          	auipc	a5,0x4
ffffffffc0204526:	d967b783          	ld	a5,-618(a5) # ffffffffc02082b8 <nbase>
ffffffffc020452a:	000b1517          	auipc	a0,0xb1
ffffffffc020452e:	16653503          	ld	a0,358(a0) # ffffffffc02b5690 <pages>
ffffffffc0204532:	4589                	li	a1,2
ffffffffc0204534:	8e9d                	sub	a3,a3,a5
ffffffffc0204536:	069a                	slli	a3,a3,0x6
ffffffffc0204538:	9536                	add	a0,a0,a3
ffffffffc020453a:	8f3fd0ef          	jal	ffffffffc0201e2c <free_pages>
    kfree(proc);
ffffffffc020453e:	8522                	mv	a0,s0
ffffffffc0204540:	f96fd0ef          	jal	ffffffffc0201cd6 <kfree>
}
ffffffffc0204544:	70a2                	ld	ra,40(sp)
ffffffffc0204546:	7402                	ld	s0,32(sp)
ffffffffc0204548:	64e2                	ld	s1,24(sp)
ffffffffc020454a:	6942                	ld	s2,16(sp)
ffffffffc020454c:	69a2                	ld	s3,8(sp)
    return 0;
ffffffffc020454e:	4501                	li	a0,0
}
ffffffffc0204550:	6145                	addi	sp,sp,48
ffffffffc0204552:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc0204554:	000b1997          	auipc	s3,0xb1
ffffffffc0204558:	14c98993          	addi	s3,s3,332 # ffffffffc02b56a0 <current>
ffffffffc020455c:	0009b703          	ld	a4,0(s3)
ffffffffc0204560:	f487b683          	ld	a3,-184(a5)
ffffffffc0204564:	f0e695e3          	bne	a3,a4,ffffffffc020446e <do_wait.part.0+0x26>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204568:	f287a603          	lw	a2,-216(a5)
ffffffffc020456c:	468d                	li	a3,3
ffffffffc020456e:	06d60063          	beq	a2,a3,ffffffffc02045ce <do_wait.part.0+0x186>
        current->wait_state = WT_CHILD;
ffffffffc0204572:	800007b7          	lui	a5,0x80000
ffffffffc0204576:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_obj___user_matrix_out_size+0xffffffff7fff4ac1>
        current->state = PROC_SLEEPING;
ffffffffc0204578:	4685                	li	a3,1
        current->wait_state = WT_CHILD;
ffffffffc020457a:	0ef72623          	sw	a5,236(a4)
        current->state = PROC_SLEEPING;
ffffffffc020457e:	c314                	sw	a3,0(a4)
        schedule();
ffffffffc0204580:	569000ef          	jal	ffffffffc02052e8 <schedule>
        if (current->flags & PF_EXITING)
ffffffffc0204584:	0009b783          	ld	a5,0(s3)
ffffffffc0204588:	0b07a783          	lw	a5,176(a5)
ffffffffc020458c:	8b85                	andi	a5,a5,1
ffffffffc020458e:	e7b9                	bnez	a5,ffffffffc02045dc <do_wait.part.0+0x194>
    if (pid != 0)
ffffffffc0204590:	ee0487e3          	beqz	s1,ffffffffc020447e <do_wait.part.0+0x36>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204594:	45a9                	li	a1,10
ffffffffc0204596:	8526                	mv	a0,s1
ffffffffc0204598:	703000ef          	jal	ffffffffc020549a <hash32>
ffffffffc020459c:	02051793          	slli	a5,a0,0x20
ffffffffc02045a0:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02045a4:	000ad797          	auipc	a5,0xad
ffffffffc02045a8:	05c78793          	addi	a5,a5,92 # ffffffffc02b1600 <hash_list>
ffffffffc02045ac:	953e                	add	a0,a0,a5
ffffffffc02045ae:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc02045b0:	a029                	j	ffffffffc02045ba <do_wait.part.0+0x172>
            if (proc->pid == pid)
ffffffffc02045b2:	f2c7a703          	lw	a4,-212(a5)
ffffffffc02045b6:	f8970fe3          	beq	a4,s1,ffffffffc0204554 <do_wait.part.0+0x10c>
    return listelm->next;
ffffffffc02045ba:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02045bc:	fef51be3          	bne	a0,a5,ffffffffc02045b2 <do_wait.part.0+0x16a>
ffffffffc02045c0:	b57d                	j	ffffffffc020446e <do_wait.part.0+0x26>
        intr_enable();
ffffffffc02045c2:	b36fc0ef          	jal	ffffffffc02008f8 <intr_enable>
ffffffffc02045c6:	bf2d                	j	ffffffffc0204500 <do_wait.part.0+0xb8>
        proc->parent->cptr = proc->optr;
ffffffffc02045c8:	7018                	ld	a4,32(s0)
ffffffffc02045ca:	fb7c                	sd	a5,240(a4)
ffffffffc02045cc:	b705                	j	ffffffffc02044ec <do_wait.part.0+0xa4>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02045ce:	f2878413          	addi	s0,a5,-216
ffffffffc02045d2:	b5d1                	j	ffffffffc0204496 <do_wait.part.0+0x4e>
        intr_disable();
ffffffffc02045d4:	b2afc0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc02045d8:	4605                	li	a2,1
ffffffffc02045da:	b5f5                	j	ffffffffc02044c6 <do_wait.part.0+0x7e>
            do_exit(-E_KILLED);
ffffffffc02045dc:	555d                	li	a0,-9
ffffffffc02045de:	d27ff0ef          	jal	ffffffffc0204304 <do_exit>
        panic("wait idleproc or initproc.\n");
ffffffffc02045e2:	00003617          	auipc	a2,0x3
ffffffffc02045e6:	bbe60613          	addi	a2,a2,-1090 # ffffffffc02071a0 <etext+0x1846>
ffffffffc02045ea:	37000593          	li	a1,880
ffffffffc02045ee:	00003517          	auipc	a0,0x3
ffffffffc02045f2:	b3250513          	addi	a0,a0,-1230 # ffffffffc0207120 <etext+0x17c6>
ffffffffc02045f6:	e55fb0ef          	jal	ffffffffc020044a <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02045fa:	00002617          	auipc	a2,0x2
ffffffffc02045fe:	21660613          	addi	a2,a2,534 # ffffffffc0206810 <etext+0xeb6>
ffffffffc0204602:	06900593          	li	a1,105
ffffffffc0204606:	00002517          	auipc	a0,0x2
ffffffffc020460a:	16250513          	addi	a0,a0,354 # ffffffffc0206768 <etext+0xe0e>
ffffffffc020460e:	e3dfb0ef          	jal	ffffffffc020044a <__panic>
    return pa2page(PADDR(kva));
ffffffffc0204612:	00002617          	auipc	a2,0x2
ffffffffc0204616:	1d660613          	addi	a2,a2,470 # ffffffffc02067e8 <etext+0xe8e>
ffffffffc020461a:	07700593          	li	a1,119
ffffffffc020461e:	00002517          	auipc	a0,0x2
ffffffffc0204622:	14a50513          	addi	a0,a0,330 # ffffffffc0206768 <etext+0xe0e>
ffffffffc0204626:	e25fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020462a <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc020462a:	1141                	addi	sp,sp,-16
ffffffffc020462c:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020462e:	837fd0ef          	jal	ffffffffc0201e64 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc0204632:	dfafd0ef          	jal	ffffffffc0201c2c <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0204636:	4601                	li	a2,0
ffffffffc0204638:	4581                	li	a1,0
ffffffffc020463a:	00000517          	auipc	a0,0x0
ffffffffc020463e:	6b050513          	addi	a0,a0,1712 # ffffffffc0204cea <user_main>
ffffffffc0204642:	c73ff0ef          	jal	ffffffffc02042b4 <kernel_thread>
    if (pid <= 0)
ffffffffc0204646:	00a04563          	bgtz	a0,ffffffffc0204650 <init_main+0x26>
ffffffffc020464a:	a071                	j	ffffffffc02046d6 <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
ffffffffc020464c:	49d000ef          	jal	ffffffffc02052e8 <schedule>
    if (code_store != NULL)
ffffffffc0204650:	4581                	li	a1,0
ffffffffc0204652:	4501                	li	a0,0
ffffffffc0204654:	df5ff0ef          	jal	ffffffffc0204448 <do_wait.part.0>
    while (do_wait(0, NULL) == 0)
ffffffffc0204658:	d975                	beqz	a0,ffffffffc020464c <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc020465a:	00003517          	auipc	a0,0x3
ffffffffc020465e:	b8650513          	addi	a0,a0,-1146 # ffffffffc02071e0 <etext+0x1886>
ffffffffc0204662:	b37fb0ef          	jal	ffffffffc0200198 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204666:	000b1797          	auipc	a5,0xb1
ffffffffc020466a:	0427b783          	ld	a5,66(a5) # ffffffffc02b56a8 <initproc>
ffffffffc020466e:	7bf8                	ld	a4,240(a5)
ffffffffc0204670:	e339                	bnez	a4,ffffffffc02046b6 <init_main+0x8c>
ffffffffc0204672:	7ff8                	ld	a4,248(a5)
ffffffffc0204674:	e329                	bnez	a4,ffffffffc02046b6 <init_main+0x8c>
ffffffffc0204676:	1007b703          	ld	a4,256(a5)
ffffffffc020467a:	ef15                	bnez	a4,ffffffffc02046b6 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc020467c:	000b1697          	auipc	a3,0xb1
ffffffffc0204680:	01c6a683          	lw	a3,28(a3) # ffffffffc02b5698 <nr_process>
ffffffffc0204684:	4709                	li	a4,2
ffffffffc0204686:	0ae69463          	bne	a3,a4,ffffffffc020472e <init_main+0x104>
ffffffffc020468a:	000b1697          	auipc	a3,0xb1
ffffffffc020468e:	f7668693          	addi	a3,a3,-138 # ffffffffc02b5600 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204692:	6698                	ld	a4,8(a3)
ffffffffc0204694:	0c878793          	addi	a5,a5,200
ffffffffc0204698:	06f71b63          	bne	a4,a5,ffffffffc020470e <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc020469c:	629c                	ld	a5,0(a3)
ffffffffc020469e:	04f71863          	bne	a4,a5,ffffffffc02046ee <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc02046a2:	00003517          	auipc	a0,0x3
ffffffffc02046a6:	c2650513          	addi	a0,a0,-986 # ffffffffc02072c8 <etext+0x196e>
ffffffffc02046aa:	aeffb0ef          	jal	ffffffffc0200198 <cprintf>
    return 0;
}
ffffffffc02046ae:	60a2                	ld	ra,8(sp)
ffffffffc02046b0:	4501                	li	a0,0
ffffffffc02046b2:	0141                	addi	sp,sp,16
ffffffffc02046b4:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02046b6:	00003697          	auipc	a3,0x3
ffffffffc02046ba:	b5268693          	addi	a3,a3,-1198 # ffffffffc0207208 <etext+0x18ae>
ffffffffc02046be:	00002617          	auipc	a2,0x2
ffffffffc02046c2:	cd260613          	addi	a2,a2,-814 # ffffffffc0206390 <etext+0xa36>
ffffffffc02046c6:	3dc00593          	li	a1,988
ffffffffc02046ca:	00003517          	auipc	a0,0x3
ffffffffc02046ce:	a5650513          	addi	a0,a0,-1450 # ffffffffc0207120 <etext+0x17c6>
ffffffffc02046d2:	d79fb0ef          	jal	ffffffffc020044a <__panic>
        panic("create user_main failed.\n");
ffffffffc02046d6:	00003617          	auipc	a2,0x3
ffffffffc02046da:	aea60613          	addi	a2,a2,-1302 # ffffffffc02071c0 <etext+0x1866>
ffffffffc02046de:	3d300593          	li	a1,979
ffffffffc02046e2:	00003517          	auipc	a0,0x3
ffffffffc02046e6:	a3e50513          	addi	a0,a0,-1474 # ffffffffc0207120 <etext+0x17c6>
ffffffffc02046ea:	d61fb0ef          	jal	ffffffffc020044a <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02046ee:	00003697          	auipc	a3,0x3
ffffffffc02046f2:	baa68693          	addi	a3,a3,-1110 # ffffffffc0207298 <etext+0x193e>
ffffffffc02046f6:	00002617          	auipc	a2,0x2
ffffffffc02046fa:	c9a60613          	addi	a2,a2,-870 # ffffffffc0206390 <etext+0xa36>
ffffffffc02046fe:	3df00593          	li	a1,991
ffffffffc0204702:	00003517          	auipc	a0,0x3
ffffffffc0204706:	a1e50513          	addi	a0,a0,-1506 # ffffffffc0207120 <etext+0x17c6>
ffffffffc020470a:	d41fb0ef          	jal	ffffffffc020044a <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020470e:	00003697          	auipc	a3,0x3
ffffffffc0204712:	b5a68693          	addi	a3,a3,-1190 # ffffffffc0207268 <etext+0x190e>
ffffffffc0204716:	00002617          	auipc	a2,0x2
ffffffffc020471a:	c7a60613          	addi	a2,a2,-902 # ffffffffc0206390 <etext+0xa36>
ffffffffc020471e:	3de00593          	li	a1,990
ffffffffc0204722:	00003517          	auipc	a0,0x3
ffffffffc0204726:	9fe50513          	addi	a0,a0,-1538 # ffffffffc0207120 <etext+0x17c6>
ffffffffc020472a:	d21fb0ef          	jal	ffffffffc020044a <__panic>
    assert(nr_process == 2);
ffffffffc020472e:	00003697          	auipc	a3,0x3
ffffffffc0204732:	b2a68693          	addi	a3,a3,-1238 # ffffffffc0207258 <etext+0x18fe>
ffffffffc0204736:	00002617          	auipc	a2,0x2
ffffffffc020473a:	c5a60613          	addi	a2,a2,-934 # ffffffffc0206390 <etext+0xa36>
ffffffffc020473e:	3dd00593          	li	a1,989
ffffffffc0204742:	00003517          	auipc	a0,0x3
ffffffffc0204746:	9de50513          	addi	a0,a0,-1570 # ffffffffc0207120 <etext+0x17c6>
ffffffffc020474a:	d01fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020474e <do_execve>:
{
ffffffffc020474e:	7171                	addi	sp,sp,-176
ffffffffc0204750:	e8ea                	sd	s10,80(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204752:	000b1d17          	auipc	s10,0xb1
ffffffffc0204756:	f4ed0d13          	addi	s10,s10,-178 # ffffffffc02b56a0 <current>
ffffffffc020475a:	000d3783          	ld	a5,0(s10)
{
ffffffffc020475e:	e94a                	sd	s2,144(sp)
ffffffffc0204760:	ed26                	sd	s1,152(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204762:	0287b903          	ld	s2,40(a5)
{
ffffffffc0204766:	84ae                	mv	s1,a1
ffffffffc0204768:	e54e                	sd	s3,136(sp)
ffffffffc020476a:	ec32                	sd	a2,24(sp)
ffffffffc020476c:	89aa                	mv	s3,a0
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc020476e:	85aa                	mv	a1,a0
ffffffffc0204770:	8626                	mv	a2,s1
ffffffffc0204772:	854a                	mv	a0,s2
ffffffffc0204774:	4681                	li	a3,0
{
ffffffffc0204776:	f506                	sd	ra,168(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204778:	cccff0ef          	jal	ffffffffc0203c44 <user_mem_check>
ffffffffc020477c:	46050f63          	beqz	a0,ffffffffc0204bfa <do_execve+0x4ac>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0204780:	4641                	li	a2,16
ffffffffc0204782:	1808                	addi	a0,sp,48
ffffffffc0204784:	4581                	li	a1,0
ffffffffc0204786:	1aa010ef          	jal	ffffffffc0205930 <memset>
    if (len > PROC_NAME_LEN)
ffffffffc020478a:	47bd                	li	a5,15
ffffffffc020478c:	8626                	mv	a2,s1
ffffffffc020478e:	0e97ef63          	bltu	a5,s1,ffffffffc020488c <do_execve+0x13e>
    memcpy(local_name, name, len);
ffffffffc0204792:	85ce                	mv	a1,s3
ffffffffc0204794:	1808                	addi	a0,sp,48
ffffffffc0204796:	1ac010ef          	jal	ffffffffc0205942 <memcpy>
    if (mm != NULL)
ffffffffc020479a:	10090063          	beqz	s2,ffffffffc020489a <do_execve+0x14c>
        cputs("mm != NULL");
ffffffffc020479e:	00002517          	auipc	a0,0x2
ffffffffc02047a2:	78a50513          	addi	a0,a0,1930 # ffffffffc0206f28 <etext+0x15ce>
ffffffffc02047a6:	a29fb0ef          	jal	ffffffffc02001ce <cputs>
ffffffffc02047aa:	000b1797          	auipc	a5,0xb1
ffffffffc02047ae:	ec67b783          	ld	a5,-314(a5) # ffffffffc02b5670 <boot_pgdir_pa>
ffffffffc02047b2:	577d                	li	a4,-1
ffffffffc02047b4:	177e                	slli	a4,a4,0x3f
ffffffffc02047b6:	83b1                	srli	a5,a5,0xc
ffffffffc02047b8:	8fd9                	or	a5,a5,a4
ffffffffc02047ba:	18079073          	csrw	satp,a5
ffffffffc02047be:	03092783          	lw	a5,48(s2)
ffffffffc02047c2:	37fd                	addiw	a5,a5,-1
ffffffffc02047c4:	02f92823          	sw	a5,48(s2)
        if (mm_count_dec(mm) == 0)
ffffffffc02047c8:	30078563          	beqz	a5,ffffffffc0204ad2 <do_execve+0x384>
        current->mm = NULL;
ffffffffc02047cc:	000d3783          	ld	a5,0(s10)
ffffffffc02047d0:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc02047d4:	de5fe0ef          	jal	ffffffffc02035b8 <mm_create>
ffffffffc02047d8:	892a                	mv	s2,a0
ffffffffc02047da:	22050063          	beqz	a0,ffffffffc02049fa <do_execve+0x2ac>
    if ((page = alloc_page()) == NULL)
ffffffffc02047de:	4505                	li	a0,1
ffffffffc02047e0:	e12fd0ef          	jal	ffffffffc0201df2 <alloc_pages>
ffffffffc02047e4:	42050063          	beqz	a0,ffffffffc0204c04 <do_execve+0x4b6>
    return page - pages + nbase;
ffffffffc02047e8:	f0e2                	sd	s8,96(sp)
ffffffffc02047ea:	000b1c17          	auipc	s8,0xb1
ffffffffc02047ee:	ea6c0c13          	addi	s8,s8,-346 # ffffffffc02b5690 <pages>
ffffffffc02047f2:	000c3783          	ld	a5,0(s8)
ffffffffc02047f6:	f4de                	sd	s7,104(sp)
ffffffffc02047f8:	00004b97          	auipc	s7,0x4
ffffffffc02047fc:	ac0bbb83          	ld	s7,-1344(s7) # ffffffffc02082b8 <nbase>
ffffffffc0204800:	40f506b3          	sub	a3,a0,a5
ffffffffc0204804:	ece6                	sd	s9,88(sp)
    return KADDR(page2pa(page));
ffffffffc0204806:	000b1c97          	auipc	s9,0xb1
ffffffffc020480a:	e82c8c93          	addi	s9,s9,-382 # ffffffffc02b5688 <npage>
ffffffffc020480e:	f8da                	sd	s6,112(sp)
    return page - pages + nbase;
ffffffffc0204810:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204812:	5b7d                	li	s6,-1
ffffffffc0204814:	000cb783          	ld	a5,0(s9)
    return page - pages + nbase;
ffffffffc0204818:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc020481a:	00cb5713          	srli	a4,s6,0xc
ffffffffc020481e:	e83a                	sd	a4,16(sp)
ffffffffc0204820:	fcd6                	sd	s5,120(sp)
ffffffffc0204822:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204824:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204826:	40f77263          	bgeu	a4,a5,ffffffffc0204c2a <do_execve+0x4dc>
ffffffffc020482a:	000b1a97          	auipc	s5,0xb1
ffffffffc020482e:	e56a8a93          	addi	s5,s5,-426 # ffffffffc02b5680 <va_pa_offset>
ffffffffc0204832:	000ab783          	ld	a5,0(s5)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204836:	000b1597          	auipc	a1,0xb1
ffffffffc020483a:	e425b583          	ld	a1,-446(a1) # ffffffffc02b5678 <boot_pgdir_va>
ffffffffc020483e:	6605                	lui	a2,0x1
ffffffffc0204840:	00f684b3          	add	s1,a3,a5
ffffffffc0204844:	8526                	mv	a0,s1
ffffffffc0204846:	0fc010ef          	jal	ffffffffc0205942 <memcpy>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc020484a:	66e2                	ld	a3,24(sp)
ffffffffc020484c:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0204850:	00993c23          	sd	s1,24(s2)
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204854:	4298                	lw	a4,0(a3)
ffffffffc0204856:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_matrix_out_size+0x464b903f>
ffffffffc020485a:	06f70863          	beq	a4,a5,ffffffffc02048ca <do_execve+0x17c>
        ret = -E_INVAL_ELF;
ffffffffc020485e:	54e1                	li	s1,-8
    put_pgdir(mm);
ffffffffc0204860:	854a                	mv	a0,s2
ffffffffc0204862:	d32ff0ef          	jal	ffffffffc0203d94 <put_pgdir>
ffffffffc0204866:	7ae6                	ld	s5,120(sp)
ffffffffc0204868:	7b46                	ld	s6,112(sp)
ffffffffc020486a:	7ba6                	ld	s7,104(sp)
ffffffffc020486c:	7c06                	ld	s8,96(sp)
ffffffffc020486e:	6ce6                	ld	s9,88(sp)
    mm_destroy(mm);
ffffffffc0204870:	854a                	mv	a0,s2
ffffffffc0204872:	e85fe0ef          	jal	ffffffffc02036f6 <mm_destroy>
    do_exit(ret);
ffffffffc0204876:	8526                	mv	a0,s1
ffffffffc0204878:	f122                	sd	s0,160(sp)
ffffffffc020487a:	e152                	sd	s4,128(sp)
ffffffffc020487c:	fcd6                	sd	s5,120(sp)
ffffffffc020487e:	f8da                	sd	s6,112(sp)
ffffffffc0204880:	f4de                	sd	s7,104(sp)
ffffffffc0204882:	f0e2                	sd	s8,96(sp)
ffffffffc0204884:	ece6                	sd	s9,88(sp)
ffffffffc0204886:	e4ee                	sd	s11,72(sp)
ffffffffc0204888:	a7dff0ef          	jal	ffffffffc0204304 <do_exit>
    if (len > PROC_NAME_LEN)
ffffffffc020488c:	863e                	mv	a2,a5
    memcpy(local_name, name, len);
ffffffffc020488e:	85ce                	mv	a1,s3
ffffffffc0204890:	1808                	addi	a0,sp,48
ffffffffc0204892:	0b0010ef          	jal	ffffffffc0205942 <memcpy>
    if (mm != NULL)
ffffffffc0204896:	f00914e3          	bnez	s2,ffffffffc020479e <do_execve+0x50>
    if (current->mm != NULL)
ffffffffc020489a:	000d3783          	ld	a5,0(s10)
ffffffffc020489e:	779c                	ld	a5,40(a5)
ffffffffc02048a0:	db95                	beqz	a5,ffffffffc02047d4 <do_execve+0x86>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc02048a2:	00003617          	auipc	a2,0x3
ffffffffc02048a6:	a4660613          	addi	a2,a2,-1466 # ffffffffc02072e8 <etext+0x198e>
ffffffffc02048aa:	25a00593          	li	a1,602
ffffffffc02048ae:	00003517          	auipc	a0,0x3
ffffffffc02048b2:	87250513          	addi	a0,a0,-1934 # ffffffffc0207120 <etext+0x17c6>
ffffffffc02048b6:	f122                	sd	s0,160(sp)
ffffffffc02048b8:	e152                	sd	s4,128(sp)
ffffffffc02048ba:	fcd6                	sd	s5,120(sp)
ffffffffc02048bc:	f8da                	sd	s6,112(sp)
ffffffffc02048be:	f4de                	sd	s7,104(sp)
ffffffffc02048c0:	f0e2                	sd	s8,96(sp)
ffffffffc02048c2:	ece6                	sd	s9,88(sp)
ffffffffc02048c4:	e4ee                	sd	s11,72(sp)
ffffffffc02048c6:	b85fb0ef          	jal	ffffffffc020044a <__panic>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02048ca:	0386d703          	lhu	a4,56(a3)
ffffffffc02048ce:	e152                	sd	s4,128(sp)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02048d0:	0206ba03          	ld	s4,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02048d4:	00371793          	slli	a5,a4,0x3
ffffffffc02048d8:	8f99                	sub	a5,a5,a4
ffffffffc02048da:	078e                	slli	a5,a5,0x3
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc02048dc:	9a36                	add	s4,s4,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc02048de:	97d2                	add	a5,a5,s4
ffffffffc02048e0:	f122                	sd	s0,160(sp)
ffffffffc02048e2:	f43e                	sd	a5,40(sp)
    for (; ph < ph_end; ph++)
ffffffffc02048e4:	00fa7e63          	bgeu	s4,a5,ffffffffc0204900 <do_execve+0x1b2>
ffffffffc02048e8:	e4ee                	sd	s11,72(sp)
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc02048ea:	000a2783          	lw	a5,0(s4)
ffffffffc02048ee:	4705                	li	a4,1
ffffffffc02048f0:	10e78763          	beq	a5,a4,ffffffffc02049fe <do_execve+0x2b0>
    for (; ph < ph_end; ph++)
ffffffffc02048f4:	77a2                	ld	a5,40(sp)
ffffffffc02048f6:	038a0a13          	addi	s4,s4,56
ffffffffc02048fa:	fefa68e3          	bltu	s4,a5,ffffffffc02048ea <do_execve+0x19c>
ffffffffc02048fe:	6da6                	ld	s11,72(sp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc0204900:	4701                	li	a4,0
ffffffffc0204902:	46ad                	li	a3,11
ffffffffc0204904:	00100637          	lui	a2,0x100
ffffffffc0204908:	7ff005b7          	lui	a1,0x7ff00
ffffffffc020490c:	854a                	mv	a0,s2
ffffffffc020490e:	e3bfe0ef          	jal	ffffffffc0203748 <mm_map>
ffffffffc0204912:	84aa                	mv	s1,a0
ffffffffc0204914:	1a051963          	bnez	a0,ffffffffc0204ac6 <do_execve+0x378>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204918:	01893503          	ld	a0,24(s2)
ffffffffc020491c:	467d                	li	a2,31
ffffffffc020491e:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0204922:	bb5fe0ef          	jal	ffffffffc02034d6 <pgdir_alloc_page>
ffffffffc0204926:	3a050163          	beqz	a0,ffffffffc0204cc8 <do_execve+0x57a>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc020492a:	01893503          	ld	a0,24(s2)
ffffffffc020492e:	467d                	li	a2,31
ffffffffc0204930:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0204934:	ba3fe0ef          	jal	ffffffffc02034d6 <pgdir_alloc_page>
ffffffffc0204938:	36050763          	beqz	a0,ffffffffc0204ca6 <do_execve+0x558>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc020493c:	01893503          	ld	a0,24(s2)
ffffffffc0204940:	467d                	li	a2,31
ffffffffc0204942:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0204946:	b91fe0ef          	jal	ffffffffc02034d6 <pgdir_alloc_page>
ffffffffc020494a:	32050d63          	beqz	a0,ffffffffc0204c84 <do_execve+0x536>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc020494e:	01893503          	ld	a0,24(s2)
ffffffffc0204952:	467d                	li	a2,31
ffffffffc0204954:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0204958:	b7ffe0ef          	jal	ffffffffc02034d6 <pgdir_alloc_page>
ffffffffc020495c:	30050363          	beqz	a0,ffffffffc0204c62 <do_execve+0x514>
    mm->mm_count += 1;
ffffffffc0204960:	03092783          	lw	a5,48(s2)
    current->mm = mm;
ffffffffc0204964:	000d3603          	ld	a2,0(s10)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204968:	01893683          	ld	a3,24(s2)
ffffffffc020496c:	2785                	addiw	a5,a5,1
ffffffffc020496e:	02f92823          	sw	a5,48(s2)
    current->mm = mm;
ffffffffc0204972:	03263423          	sd	s2,40(a2) # 100028 <_binary_obj___user_matrix_out_size+0xf4ae8>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204976:	c02007b7          	lui	a5,0xc0200
ffffffffc020497a:	2cf6e763          	bltu	a3,a5,ffffffffc0204c48 <do_execve+0x4fa>
ffffffffc020497e:	000ab783          	ld	a5,0(s5)
ffffffffc0204982:	577d                	li	a4,-1
ffffffffc0204984:	177e                	slli	a4,a4,0x3f
ffffffffc0204986:	8e9d                	sub	a3,a3,a5
ffffffffc0204988:	00c6d793          	srli	a5,a3,0xc
ffffffffc020498c:	f654                	sd	a3,168(a2)
ffffffffc020498e:	8fd9                	or	a5,a5,a4
ffffffffc0204990:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0204994:	7240                	ld	s0,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204996:	4581                	li	a1,0
ffffffffc0204998:	12000613          	li	a2,288
ffffffffc020499c:	8522                	mv	a0,s0
    uintptr_t sstatus = tf->status;
ffffffffc020499e:	10043903          	ld	s2,256(s0)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc02049a2:	78f000ef          	jal	ffffffffc0205930 <memset>
    tf->epc = elf->e_entry;
ffffffffc02049a6:	67e2                	ld	a5,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02049a8:	000d3983          	ld	s3,0(s10)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc02049ac:	edf97913          	andi	s2,s2,-289
    tf->epc = elf->e_entry;
ffffffffc02049b0:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc02049b2:	4785                	li	a5,1
ffffffffc02049b4:	07fe                	slli	a5,a5,0x1f
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc02049b6:	02096913          	ori	s2,s2,32
    tf->epc = elf->e_entry;
ffffffffc02049ba:	10e43423          	sd	a4,264(s0)
    tf->gpr.sp = USTACKTOP;
ffffffffc02049be:	e81c                	sd	a5,16(s0)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc02049c0:	11243023          	sd	s2,256(s0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02049c4:	4641                	li	a2,16
ffffffffc02049c6:	4581                	li	a1,0
ffffffffc02049c8:	0b498513          	addi	a0,s3,180
ffffffffc02049cc:	765000ef          	jal	ffffffffc0205930 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc02049d0:	180c                	addi	a1,sp,48
ffffffffc02049d2:	0b498513          	addi	a0,s3,180
ffffffffc02049d6:	463d                	li	a2,15
ffffffffc02049d8:	76b000ef          	jal	ffffffffc0205942 <memcpy>
ffffffffc02049dc:	740a                	ld	s0,160(sp)
ffffffffc02049de:	6a0a                	ld	s4,128(sp)
ffffffffc02049e0:	7ae6                	ld	s5,120(sp)
ffffffffc02049e2:	7b46                	ld	s6,112(sp)
ffffffffc02049e4:	7ba6                	ld	s7,104(sp)
ffffffffc02049e6:	7c06                	ld	s8,96(sp)
ffffffffc02049e8:	6ce6                	ld	s9,88(sp)
}
ffffffffc02049ea:	70aa                	ld	ra,168(sp)
ffffffffc02049ec:	694a                	ld	s2,144(sp)
ffffffffc02049ee:	69aa                	ld	s3,136(sp)
ffffffffc02049f0:	6d46                	ld	s10,80(sp)
ffffffffc02049f2:	8526                	mv	a0,s1
ffffffffc02049f4:	64ea                	ld	s1,152(sp)
ffffffffc02049f6:	614d                	addi	sp,sp,176
ffffffffc02049f8:	8082                	ret
    int ret = -E_NO_MEM;
ffffffffc02049fa:	54f1                	li	s1,-4
ffffffffc02049fc:	bdad                	j	ffffffffc0204876 <do_execve+0x128>
        if (ph->p_filesz > ph->p_memsz)
ffffffffc02049fe:	028a3603          	ld	a2,40(s4)
ffffffffc0204a02:	020a3783          	ld	a5,32(s4)
ffffffffc0204a06:	20f66363          	bltu	a2,a5,ffffffffc0204c0c <do_execve+0x4be>
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204a0a:	004a2783          	lw	a5,4(s4)
ffffffffc0204a0e:	0027971b          	slliw	a4,a5,0x2
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204a12:	0027f693          	andi	a3,a5,2
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204a16:	8b11                	andi	a4,a4,4
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204a18:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204a1a:	c6f1                	beqz	a3,ffffffffc0204ae6 <do_execve+0x398>
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204a1c:	1c079763          	bnez	a5,ffffffffc0204bea <do_execve+0x49c>
            perm |= (PTE_W | PTE_R);
ffffffffc0204a20:	47dd                	li	a5,23
            vm_flags |= VM_WRITE;
ffffffffc0204a22:	00276693          	ori	a3,a4,2
            perm |= (PTE_W | PTE_R);
ffffffffc0204a26:	e43e                	sd	a5,8(sp)
        if (vm_flags & VM_EXEC)
ffffffffc0204a28:	c709                	beqz	a4,ffffffffc0204a32 <do_execve+0x2e4>
            perm |= PTE_X;
ffffffffc0204a2a:	67a2                	ld	a5,8(sp)
ffffffffc0204a2c:	0087e793          	ori	a5,a5,8
ffffffffc0204a30:	e43e                	sd	a5,8(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc0204a32:	010a3583          	ld	a1,16(s4)
ffffffffc0204a36:	4701                	li	a4,0
ffffffffc0204a38:	854a                	mv	a0,s2
ffffffffc0204a3a:	d0ffe0ef          	jal	ffffffffc0203748 <mm_map>
ffffffffc0204a3e:	84aa                	mv	s1,a0
ffffffffc0204a40:	1c051463          	bnez	a0,ffffffffc0204c08 <do_execve+0x4ba>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204a44:	010a3b03          	ld	s6,16(s4)
        end = ph->p_va + ph->p_filesz;
ffffffffc0204a48:	020a3483          	ld	s1,32(s4)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204a4c:	77fd                	lui	a5,0xfffff
ffffffffc0204a4e:	00fb75b3          	and	a1,s6,a5
        end = ph->p_va + ph->p_filesz;
ffffffffc0204a52:	94da                	add	s1,s1,s6
        while (start < end)
ffffffffc0204a54:	1a9b7563          	bgeu	s6,s1,ffffffffc0204bfe <do_execve+0x4b0>
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204a58:	008a3983          	ld	s3,8(s4)
ffffffffc0204a5c:	67e2                	ld	a5,24(sp)
ffffffffc0204a5e:	99be                	add	s3,s3,a5
ffffffffc0204a60:	a881                	j	ffffffffc0204ab0 <do_execve+0x362>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204a62:	6785                	lui	a5,0x1
ffffffffc0204a64:	00f58db3          	add	s11,a1,a5
                size -= la - end;
ffffffffc0204a68:	41648633          	sub	a2,s1,s6
            if (end < la)
ffffffffc0204a6c:	01b4e463          	bltu	s1,s11,ffffffffc0204a74 <do_execve+0x326>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204a70:	416d8633          	sub	a2,s11,s6
    return page - pages + nbase;
ffffffffc0204a74:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc0204a78:	67c2                	ld	a5,16(sp)
ffffffffc0204a7a:	000cb503          	ld	a0,0(s9)
    return page - pages + nbase;
ffffffffc0204a7e:	40d406b3          	sub	a3,s0,a3
ffffffffc0204a82:	8699                	srai	a3,a3,0x6
ffffffffc0204a84:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0204a86:	00f6f833          	and	a6,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204a8a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204a8c:	18a87363          	bgeu	a6,a0,ffffffffc0204c12 <do_execve+0x4c4>
ffffffffc0204a90:	000ab503          	ld	a0,0(s5)
ffffffffc0204a94:	40bb05b3          	sub	a1,s6,a1
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204a98:	e032                	sd	a2,0(sp)
ffffffffc0204a9a:	9536                	add	a0,a0,a3
ffffffffc0204a9c:	952e                	add	a0,a0,a1
ffffffffc0204a9e:	85ce                	mv	a1,s3
ffffffffc0204aa0:	6a3000ef          	jal	ffffffffc0205942 <memcpy>
            start += size, from += size;
ffffffffc0204aa4:	6602                	ld	a2,0(sp)
ffffffffc0204aa6:	9b32                	add	s6,s6,a2
ffffffffc0204aa8:	99b2                	add	s3,s3,a2
        while (start < end)
ffffffffc0204aaa:	049b7563          	bgeu	s6,s1,ffffffffc0204af4 <do_execve+0x3a6>
ffffffffc0204aae:	85ee                	mv	a1,s11
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204ab0:	01893503          	ld	a0,24(s2)
ffffffffc0204ab4:	6622                	ld	a2,8(sp)
ffffffffc0204ab6:	e02e                	sd	a1,0(sp)
ffffffffc0204ab8:	a1ffe0ef          	jal	ffffffffc02034d6 <pgdir_alloc_page>
ffffffffc0204abc:	6582                	ld	a1,0(sp)
ffffffffc0204abe:	842a                	mv	s0,a0
ffffffffc0204ac0:	f14d                	bnez	a0,ffffffffc0204a62 <do_execve+0x314>
ffffffffc0204ac2:	6da6                	ld	s11,72(sp)
        ret = -E_NO_MEM;
ffffffffc0204ac4:	54f1                	li	s1,-4
    exit_mmap(mm);
ffffffffc0204ac6:	854a                	mv	a0,s2
ffffffffc0204ac8:	de5fe0ef          	jal	ffffffffc02038ac <exit_mmap>
ffffffffc0204acc:	740a                	ld	s0,160(sp)
ffffffffc0204ace:	6a0a                	ld	s4,128(sp)
ffffffffc0204ad0:	bb41                	j	ffffffffc0204860 <do_execve+0x112>
            exit_mmap(mm);
ffffffffc0204ad2:	854a                	mv	a0,s2
ffffffffc0204ad4:	dd9fe0ef          	jal	ffffffffc02038ac <exit_mmap>
            put_pgdir(mm);
ffffffffc0204ad8:	854a                	mv	a0,s2
ffffffffc0204ada:	abaff0ef          	jal	ffffffffc0203d94 <put_pgdir>
            mm_destroy(mm);
ffffffffc0204ade:	854a                	mv	a0,s2
ffffffffc0204ae0:	c17fe0ef          	jal	ffffffffc02036f6 <mm_destroy>
ffffffffc0204ae4:	b1e5                	j	ffffffffc02047cc <do_execve+0x7e>
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204ae6:	0e078e63          	beqz	a5,ffffffffc0204be2 <do_execve+0x494>
            perm |= PTE_R;
ffffffffc0204aea:	47cd                	li	a5,19
            vm_flags |= VM_READ;
ffffffffc0204aec:	00176693          	ori	a3,a4,1
            perm |= PTE_R;
ffffffffc0204af0:	e43e                	sd	a5,8(sp)
ffffffffc0204af2:	bf1d                	j	ffffffffc0204a28 <do_execve+0x2da>
        end = ph->p_va + ph->p_memsz;
ffffffffc0204af4:	010a3483          	ld	s1,16(s4)
ffffffffc0204af8:	028a3683          	ld	a3,40(s4)
ffffffffc0204afc:	94b6                	add	s1,s1,a3
        if (start < la)
ffffffffc0204afe:	07bb7c63          	bgeu	s6,s11,ffffffffc0204b76 <do_execve+0x428>
            if (start == end)
ffffffffc0204b02:	df6489e3          	beq	s1,s6,ffffffffc02048f4 <do_execve+0x1a6>
                size -= la - end;
ffffffffc0204b06:	416489b3          	sub	s3,s1,s6
            if (end < la)
ffffffffc0204b0a:	0fb4f563          	bgeu	s1,s11,ffffffffc0204bf4 <do_execve+0x4a6>
    return page - pages + nbase;
ffffffffc0204b0e:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc0204b12:	000cb603          	ld	a2,0(s9)
    return page - pages + nbase;
ffffffffc0204b16:	40d406b3          	sub	a3,s0,a3
ffffffffc0204b1a:	8699                	srai	a3,a3,0x6
ffffffffc0204b1c:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0204b1e:	00c69593          	slli	a1,a3,0xc
ffffffffc0204b22:	81b1                	srli	a1,a1,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b24:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204b26:	0ec5f663          	bgeu	a1,a2,ffffffffc0204c12 <do_execve+0x4c4>
ffffffffc0204b2a:	000ab603          	ld	a2,0(s5)
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204b2e:	6505                	lui	a0,0x1
ffffffffc0204b30:	955a                	add	a0,a0,s6
ffffffffc0204b32:	96b2                	add	a3,a3,a2
ffffffffc0204b34:	41b50533          	sub	a0,a0,s11
            memset(page2kva(page) + off, 0, size);
ffffffffc0204b38:	9536                	add	a0,a0,a3
ffffffffc0204b3a:	864e                	mv	a2,s3
ffffffffc0204b3c:	4581                	li	a1,0
ffffffffc0204b3e:	5f3000ef          	jal	ffffffffc0205930 <memset>
            start += size;
ffffffffc0204b42:	9b4e                	add	s6,s6,s3
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0204b44:	01b4b6b3          	sltu	a3,s1,s11
ffffffffc0204b48:	01b4f463          	bgeu	s1,s11,ffffffffc0204b50 <do_execve+0x402>
ffffffffc0204b4c:	db6484e3          	beq	s1,s6,ffffffffc02048f4 <do_execve+0x1a6>
ffffffffc0204b50:	e299                	bnez	a3,ffffffffc0204b56 <do_execve+0x408>
ffffffffc0204b52:	03bb0263          	beq	s6,s11,ffffffffc0204b76 <do_execve+0x428>
ffffffffc0204b56:	00002697          	auipc	a3,0x2
ffffffffc0204b5a:	7ba68693          	addi	a3,a3,1978 # ffffffffc0207310 <etext+0x19b6>
ffffffffc0204b5e:	00002617          	auipc	a2,0x2
ffffffffc0204b62:	83260613          	addi	a2,a2,-1998 # ffffffffc0206390 <etext+0xa36>
ffffffffc0204b66:	2c300593          	li	a1,707
ffffffffc0204b6a:	00002517          	auipc	a0,0x2
ffffffffc0204b6e:	5b650513          	addi	a0,a0,1462 # ffffffffc0207120 <etext+0x17c6>
ffffffffc0204b72:	8d9fb0ef          	jal	ffffffffc020044a <__panic>
        while (start < end)
ffffffffc0204b76:	d69b7fe3          	bgeu	s6,s1,ffffffffc02048f4 <do_execve+0x1a6>
ffffffffc0204b7a:	56fd                	li	a3,-1
ffffffffc0204b7c:	00c6d793          	srli	a5,a3,0xc
ffffffffc0204b80:	f03e                	sd	a5,32(sp)
ffffffffc0204b82:	a0b9                	j	ffffffffc0204bd0 <do_execve+0x482>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204b84:	6785                	lui	a5,0x1
ffffffffc0204b86:	00fd8833          	add	a6,s11,a5
                size -= la - end;
ffffffffc0204b8a:	416489b3          	sub	s3,s1,s6
            if (end < la)
ffffffffc0204b8e:	0104e463          	bltu	s1,a6,ffffffffc0204b96 <do_execve+0x448>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204b92:	416809b3          	sub	s3,a6,s6
    return page - pages + nbase;
ffffffffc0204b96:	000c3683          	ld	a3,0(s8)
    return KADDR(page2pa(page));
ffffffffc0204b9a:	7782                	ld	a5,32(sp)
ffffffffc0204b9c:	000cb583          	ld	a1,0(s9)
    return page - pages + nbase;
ffffffffc0204ba0:	40d406b3          	sub	a3,s0,a3
ffffffffc0204ba4:	8699                	srai	a3,a3,0x6
ffffffffc0204ba6:	96de                	add	a3,a3,s7
    return KADDR(page2pa(page));
ffffffffc0204ba8:	00f6f533          	and	a0,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204bac:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204bae:	06b57263          	bgeu	a0,a1,ffffffffc0204c12 <do_execve+0x4c4>
ffffffffc0204bb2:	000ab583          	ld	a1,0(s5)
ffffffffc0204bb6:	41bb0533          	sub	a0,s6,s11
            memset(page2kva(page) + off, 0, size);
ffffffffc0204bba:	864e                	mv	a2,s3
ffffffffc0204bbc:	96ae                	add	a3,a3,a1
ffffffffc0204bbe:	9536                	add	a0,a0,a3
ffffffffc0204bc0:	4581                	li	a1,0
            start += size;
ffffffffc0204bc2:	9b4e                	add	s6,s6,s3
ffffffffc0204bc4:	e042                	sd	a6,0(sp)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204bc6:	56b000ef          	jal	ffffffffc0205930 <memset>
        while (start < end)
ffffffffc0204bca:	d29b75e3          	bgeu	s6,s1,ffffffffc02048f4 <do_execve+0x1a6>
ffffffffc0204bce:	6d82                	ld	s11,0(sp)
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204bd0:	01893503          	ld	a0,24(s2)
ffffffffc0204bd4:	6622                	ld	a2,8(sp)
ffffffffc0204bd6:	85ee                	mv	a1,s11
ffffffffc0204bd8:	8fffe0ef          	jal	ffffffffc02034d6 <pgdir_alloc_page>
ffffffffc0204bdc:	842a                	mv	s0,a0
ffffffffc0204bde:	f15d                	bnez	a0,ffffffffc0204b84 <do_execve+0x436>
ffffffffc0204be0:	b5cd                	j	ffffffffc0204ac2 <do_execve+0x374>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0204be2:	47c5                	li	a5,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204be4:	86ba                	mv	a3,a4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0204be6:	e43e                	sd	a5,8(sp)
ffffffffc0204be8:	b581                	j	ffffffffc0204a28 <do_execve+0x2da>
            perm |= (PTE_W | PTE_R);
ffffffffc0204bea:	47dd                	li	a5,23
            vm_flags |= VM_READ;
ffffffffc0204bec:	00376693          	ori	a3,a4,3
            perm |= (PTE_W | PTE_R);
ffffffffc0204bf0:	e43e                	sd	a5,8(sp)
ffffffffc0204bf2:	bd1d                	j	ffffffffc0204a28 <do_execve+0x2da>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204bf4:	416d89b3          	sub	s3,s11,s6
ffffffffc0204bf8:	bf19                	j	ffffffffc0204b0e <do_execve+0x3c0>
        return -E_INVAL;
ffffffffc0204bfa:	54f5                	li	s1,-3
ffffffffc0204bfc:	b3fd                	j	ffffffffc02049ea <do_execve+0x29c>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204bfe:	8dae                	mv	s11,a1
        while (start < end)
ffffffffc0204c00:	84da                	mv	s1,s6
ffffffffc0204c02:	bddd                	j	ffffffffc0204af8 <do_execve+0x3aa>
    int ret = -E_NO_MEM;
ffffffffc0204c04:	54f1                	li	s1,-4
ffffffffc0204c06:	b1ad                	j	ffffffffc0204870 <do_execve+0x122>
ffffffffc0204c08:	6da6                	ld	s11,72(sp)
ffffffffc0204c0a:	bd75                	j	ffffffffc0204ac6 <do_execve+0x378>
            ret = -E_INVAL_ELF;
ffffffffc0204c0c:	6da6                	ld	s11,72(sp)
ffffffffc0204c0e:	54e1                	li	s1,-8
ffffffffc0204c10:	bd5d                	j	ffffffffc0204ac6 <do_execve+0x378>
ffffffffc0204c12:	00002617          	auipc	a2,0x2
ffffffffc0204c16:	b2e60613          	addi	a2,a2,-1234 # ffffffffc0206740 <etext+0xde6>
ffffffffc0204c1a:	07100593          	li	a1,113
ffffffffc0204c1e:	00002517          	auipc	a0,0x2
ffffffffc0204c22:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0206768 <etext+0xe0e>
ffffffffc0204c26:	825fb0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0204c2a:	00002617          	auipc	a2,0x2
ffffffffc0204c2e:	b1660613          	addi	a2,a2,-1258 # ffffffffc0206740 <etext+0xde6>
ffffffffc0204c32:	07100593          	li	a1,113
ffffffffc0204c36:	00002517          	auipc	a0,0x2
ffffffffc0204c3a:	b3250513          	addi	a0,a0,-1230 # ffffffffc0206768 <etext+0xe0e>
ffffffffc0204c3e:	f122                	sd	s0,160(sp)
ffffffffc0204c40:	e152                	sd	s4,128(sp)
ffffffffc0204c42:	e4ee                	sd	s11,72(sp)
ffffffffc0204c44:	807fb0ef          	jal	ffffffffc020044a <__panic>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204c48:	00002617          	auipc	a2,0x2
ffffffffc0204c4c:	ba060613          	addi	a2,a2,-1120 # ffffffffc02067e8 <etext+0xe8e>
ffffffffc0204c50:	2e200593          	li	a1,738
ffffffffc0204c54:	00002517          	auipc	a0,0x2
ffffffffc0204c58:	4cc50513          	addi	a0,a0,1228 # ffffffffc0207120 <etext+0x17c6>
ffffffffc0204c5c:	e4ee                	sd	s11,72(sp)
ffffffffc0204c5e:	fecfb0ef          	jal	ffffffffc020044a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204c62:	00002697          	auipc	a3,0x2
ffffffffc0204c66:	7c668693          	addi	a3,a3,1990 # ffffffffc0207428 <etext+0x1ace>
ffffffffc0204c6a:	00001617          	auipc	a2,0x1
ffffffffc0204c6e:	72660613          	addi	a2,a2,1830 # ffffffffc0206390 <etext+0xa36>
ffffffffc0204c72:	2dd00593          	li	a1,733
ffffffffc0204c76:	00002517          	auipc	a0,0x2
ffffffffc0204c7a:	4aa50513          	addi	a0,a0,1194 # ffffffffc0207120 <etext+0x17c6>
ffffffffc0204c7e:	e4ee                	sd	s11,72(sp)
ffffffffc0204c80:	fcafb0ef          	jal	ffffffffc020044a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204c84:	00002697          	auipc	a3,0x2
ffffffffc0204c88:	75c68693          	addi	a3,a3,1884 # ffffffffc02073e0 <etext+0x1a86>
ffffffffc0204c8c:	00001617          	auipc	a2,0x1
ffffffffc0204c90:	70460613          	addi	a2,a2,1796 # ffffffffc0206390 <etext+0xa36>
ffffffffc0204c94:	2dc00593          	li	a1,732
ffffffffc0204c98:	00002517          	auipc	a0,0x2
ffffffffc0204c9c:	48850513          	addi	a0,a0,1160 # ffffffffc0207120 <etext+0x17c6>
ffffffffc0204ca0:	e4ee                	sd	s11,72(sp)
ffffffffc0204ca2:	fa8fb0ef          	jal	ffffffffc020044a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204ca6:	00002697          	auipc	a3,0x2
ffffffffc0204caa:	6f268693          	addi	a3,a3,1778 # ffffffffc0207398 <etext+0x1a3e>
ffffffffc0204cae:	00001617          	auipc	a2,0x1
ffffffffc0204cb2:	6e260613          	addi	a2,a2,1762 # ffffffffc0206390 <etext+0xa36>
ffffffffc0204cb6:	2db00593          	li	a1,731
ffffffffc0204cba:	00002517          	auipc	a0,0x2
ffffffffc0204cbe:	46650513          	addi	a0,a0,1126 # ffffffffc0207120 <etext+0x17c6>
ffffffffc0204cc2:	e4ee                	sd	s11,72(sp)
ffffffffc0204cc4:	f86fb0ef          	jal	ffffffffc020044a <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204cc8:	00002697          	auipc	a3,0x2
ffffffffc0204ccc:	68868693          	addi	a3,a3,1672 # ffffffffc0207350 <etext+0x19f6>
ffffffffc0204cd0:	00001617          	auipc	a2,0x1
ffffffffc0204cd4:	6c060613          	addi	a2,a2,1728 # ffffffffc0206390 <etext+0xa36>
ffffffffc0204cd8:	2da00593          	li	a1,730
ffffffffc0204cdc:	00002517          	auipc	a0,0x2
ffffffffc0204ce0:	44450513          	addi	a0,a0,1092 # ffffffffc0207120 <etext+0x17c6>
ffffffffc0204ce4:	e4ee                	sd	s11,72(sp)
ffffffffc0204ce6:	f64fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0204cea <user_main>:
{
ffffffffc0204cea:	1101                	addi	sp,sp,-32
ffffffffc0204cec:	e426                	sd	s1,8(sp)
    KERNEL_EXECVE(priority);
ffffffffc0204cee:	000b1497          	auipc	s1,0xb1
ffffffffc0204cf2:	9b248493          	addi	s1,s1,-1614 # ffffffffc02b56a0 <current>
ffffffffc0204cf6:	609c                	ld	a5,0(s1)
ffffffffc0204cf8:	00002617          	auipc	a2,0x2
ffffffffc0204cfc:	77860613          	addi	a2,a2,1912 # ffffffffc0207470 <etext+0x1b16>
ffffffffc0204d00:	00002517          	auipc	a0,0x2
ffffffffc0204d04:	78050513          	addi	a0,a0,1920 # ffffffffc0207480 <etext+0x1b26>
ffffffffc0204d08:	43cc                	lw	a1,4(a5)
{
ffffffffc0204d0a:	ec06                	sd	ra,24(sp)
ffffffffc0204d0c:	e822                	sd	s0,16(sp)
ffffffffc0204d0e:	e04a                	sd	s2,0(sp)
    KERNEL_EXECVE(priority);
ffffffffc0204d10:	c88fb0ef          	jal	ffffffffc0200198 <cprintf>
    size_t len = strlen(name);
ffffffffc0204d14:	00002517          	auipc	a0,0x2
ffffffffc0204d18:	75c50513          	addi	a0,a0,1884 # ffffffffc0207470 <etext+0x1b16>
ffffffffc0204d1c:	361000ef          	jal	ffffffffc020587c <strlen>
    struct trapframe *old_tf = current->tf;
ffffffffc0204d20:	6098                	ld	a4,0(s1)
    struct trapframe *new_tf = (struct trapframe *)(current->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204d22:	6789                	lui	a5,0x2
ffffffffc0204d24:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_softint_out_size-0x7048>
ffffffffc0204d28:	6b00                	ld	s0,16(a4)
    memcpy(new_tf, old_tf, sizeof(struct trapframe));
ffffffffc0204d2a:	734c                	ld	a1,160(a4)
    size_t len = strlen(name);
ffffffffc0204d2c:	892a                	mv	s2,a0
    struct trapframe *new_tf = (struct trapframe *)(current->kstack + KSTACKSIZE - sizeof(struct trapframe));
ffffffffc0204d2e:	943e                	add	s0,s0,a5
    memcpy(new_tf, old_tf, sizeof(struct trapframe));
ffffffffc0204d30:	12000613          	li	a2,288
ffffffffc0204d34:	8522                	mv	a0,s0
ffffffffc0204d36:	40d000ef          	jal	ffffffffc0205942 <memcpy>
    current->tf = new_tf;
ffffffffc0204d3a:	609c                	ld	a5,0(s1)
    ret = do_execve(name, len, binary, size);
ffffffffc0204d3c:	85ca                	mv	a1,s2
ffffffffc0204d3e:	3fe06697          	auipc	a3,0x3fe06
ffffffffc0204d42:	9da68693          	addi	a3,a3,-1574 # a718 <_binary_obj___user_priority_out_size>
    current->tf = new_tf;
ffffffffc0204d46:	f3c0                	sd	s0,160(a5)
    ret = do_execve(name, len, binary, size);
ffffffffc0204d48:	00072617          	auipc	a2,0x72
ffffffffc0204d4c:	c4860613          	addi	a2,a2,-952 # ffffffffc0276990 <_binary_obj___user_priority_out_start>
ffffffffc0204d50:	00002517          	auipc	a0,0x2
ffffffffc0204d54:	72050513          	addi	a0,a0,1824 # ffffffffc0207470 <etext+0x1b16>
ffffffffc0204d58:	9f7ff0ef          	jal	ffffffffc020474e <do_execve>
    asm volatile(
ffffffffc0204d5c:	8122                	mv	sp,s0
ffffffffc0204d5e:	906fc06f          	j	ffffffffc0200e64 <__trapret>
    panic("user_main execve failed.\n");
ffffffffc0204d62:	00002617          	auipc	a2,0x2
ffffffffc0204d66:	74660613          	addi	a2,a2,1862 # ffffffffc02074a8 <etext+0x1b4e>
ffffffffc0204d6a:	3c600593          	li	a1,966
ffffffffc0204d6e:	00002517          	auipc	a0,0x2
ffffffffc0204d72:	3b250513          	addi	a0,a0,946 # ffffffffc0207120 <etext+0x17c6>
ffffffffc0204d76:	ed4fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0204d7a <do_yield>:
    current->need_resched = 1;
ffffffffc0204d7a:	000b1797          	auipc	a5,0xb1
ffffffffc0204d7e:	9267b783          	ld	a5,-1754(a5) # ffffffffc02b56a0 <current>
ffffffffc0204d82:	4705                	li	a4,1
}
ffffffffc0204d84:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0204d86:	ef98                	sd	a4,24(a5)
}
ffffffffc0204d88:	8082                	ret

ffffffffc0204d8a <do_wait>:
    if (code_store != NULL)
ffffffffc0204d8a:	c59d                	beqz	a1,ffffffffc0204db8 <do_wait+0x2e>
{
ffffffffc0204d8c:	1101                	addi	sp,sp,-32
ffffffffc0204d8e:	e02a                	sd	a0,0(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204d90:	000b1517          	auipc	a0,0xb1
ffffffffc0204d94:	91053503          	ld	a0,-1776(a0) # ffffffffc02b56a0 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0204d98:	4685                	li	a3,1
ffffffffc0204d9a:	4611                	li	a2,4
ffffffffc0204d9c:	7508                	ld	a0,40(a0)
{
ffffffffc0204d9e:	ec06                	sd	ra,24(sp)
ffffffffc0204da0:	e42e                	sd	a1,8(sp)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0204da2:	ea3fe0ef          	jal	ffffffffc0203c44 <user_mem_check>
ffffffffc0204da6:	6702                	ld	a4,0(sp)
ffffffffc0204da8:	67a2                	ld	a5,8(sp)
ffffffffc0204daa:	c909                	beqz	a0,ffffffffc0204dbc <do_wait+0x32>
}
ffffffffc0204dac:	60e2                	ld	ra,24(sp)
ffffffffc0204dae:	85be                	mv	a1,a5
ffffffffc0204db0:	853a                	mv	a0,a4
ffffffffc0204db2:	6105                	addi	sp,sp,32
ffffffffc0204db4:	e94ff06f          	j	ffffffffc0204448 <do_wait.part.0>
ffffffffc0204db8:	e90ff06f          	j	ffffffffc0204448 <do_wait.part.0>
ffffffffc0204dbc:	60e2                	ld	ra,24(sp)
ffffffffc0204dbe:	5575                	li	a0,-3
ffffffffc0204dc0:	6105                	addi	sp,sp,32
ffffffffc0204dc2:	8082                	ret

ffffffffc0204dc4 <do_kill>:
    if (0 < pid && pid < MAX_PID)
ffffffffc0204dc4:	6789                	lui	a5,0x2
ffffffffc0204dc6:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204dca:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x6f2a>
ffffffffc0204dcc:	06e7e463          	bltu	a5,a4,ffffffffc0204e34 <do_kill+0x70>
{
ffffffffc0204dd0:	1101                	addi	sp,sp,-32
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204dd2:	45a9                	li	a1,10
{
ffffffffc0204dd4:	ec06                	sd	ra,24(sp)
ffffffffc0204dd6:	e42a                	sd	a0,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204dd8:	6c2000ef          	jal	ffffffffc020549a <hash32>
ffffffffc0204ddc:	02051793          	slli	a5,a0,0x20
ffffffffc0204de0:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0204de4:	000ad797          	auipc	a5,0xad
ffffffffc0204de8:	81c78793          	addi	a5,a5,-2020 # ffffffffc02b1600 <hash_list>
ffffffffc0204dec:	96be                	add	a3,a3,a5
        while ((le = list_next(le)) != list)
ffffffffc0204dee:	6622                	ld	a2,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204df0:	8536                	mv	a0,a3
        while ((le = list_next(le)) != list)
ffffffffc0204df2:	a029                	j	ffffffffc0204dfc <do_kill+0x38>
            if (proc->pid == pid)
ffffffffc0204df4:	f2c52703          	lw	a4,-212(a0)
ffffffffc0204df8:	00c70963          	beq	a4,a2,ffffffffc0204e0a <do_kill+0x46>
ffffffffc0204dfc:	6508                	ld	a0,8(a0)
        while ((le = list_next(le)) != list)
ffffffffc0204dfe:	fea69be3          	bne	a3,a0,ffffffffc0204df4 <do_kill+0x30>
}
ffffffffc0204e02:	60e2                	ld	ra,24(sp)
    return -E_INVAL;
ffffffffc0204e04:	5575                	li	a0,-3
}
ffffffffc0204e06:	6105                	addi	sp,sp,32
ffffffffc0204e08:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc0204e0a:	fd852703          	lw	a4,-40(a0)
ffffffffc0204e0e:	00177693          	andi	a3,a4,1
ffffffffc0204e12:	e29d                	bnez	a3,ffffffffc0204e38 <do_kill+0x74>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0204e14:	4954                	lw	a3,20(a0)
            proc->flags |= PF_EXITING;
ffffffffc0204e16:	00176713          	ori	a4,a4,1
ffffffffc0204e1a:	fce52c23          	sw	a4,-40(a0)
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0204e1e:	0006c663          	bltz	a3,ffffffffc0204e2a <do_kill+0x66>
            return 0;
ffffffffc0204e22:	4501                	li	a0,0
}
ffffffffc0204e24:	60e2                	ld	ra,24(sp)
ffffffffc0204e26:	6105                	addi	sp,sp,32
ffffffffc0204e28:	8082                	ret
                wakeup_proc(proc);
ffffffffc0204e2a:	f2850513          	addi	a0,a0,-216
ffffffffc0204e2e:	3c2000ef          	jal	ffffffffc02051f0 <wakeup_proc>
ffffffffc0204e32:	bfc5                	j	ffffffffc0204e22 <do_kill+0x5e>
    return -E_INVAL;
ffffffffc0204e34:	5575                	li	a0,-3
}
ffffffffc0204e36:	8082                	ret
        return -E_KILLED;
ffffffffc0204e38:	555d                	li	a0,-9
ffffffffc0204e3a:	b7ed                	j	ffffffffc0204e24 <do_kill+0x60>

ffffffffc0204e3c <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc0204e3c:	1101                	addi	sp,sp,-32
ffffffffc0204e3e:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc0204e40:	000b0797          	auipc	a5,0xb0
ffffffffc0204e44:	7c078793          	addi	a5,a5,1984 # ffffffffc02b5600 <proc_list>
ffffffffc0204e48:	ec06                	sd	ra,24(sp)
ffffffffc0204e4a:	e822                	sd	s0,16(sp)
ffffffffc0204e4c:	e04a                	sd	s2,0(sp)
ffffffffc0204e4e:	000ac497          	auipc	s1,0xac
ffffffffc0204e52:	7b248493          	addi	s1,s1,1970 # ffffffffc02b1600 <hash_list>
ffffffffc0204e56:	e79c                	sd	a5,8(a5)
ffffffffc0204e58:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc0204e5a:	000b0717          	auipc	a4,0xb0
ffffffffc0204e5e:	7a670713          	addi	a4,a4,1958 # ffffffffc02b5600 <proc_list>
ffffffffc0204e62:	87a6                	mv	a5,s1
ffffffffc0204e64:	e79c                	sd	a5,8(a5)
ffffffffc0204e66:	e39c                	sd	a5,0(a5)
ffffffffc0204e68:	07c1                	addi	a5,a5,16
ffffffffc0204e6a:	fee79de3          	bne	a5,a4,ffffffffc0204e64 <proc_init+0x28>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc0204e6e:	e83fe0ef          	jal	ffffffffc0203cf0 <alloc_proc>
ffffffffc0204e72:	000b1917          	auipc	s2,0xb1
ffffffffc0204e76:	83e90913          	addi	s2,s2,-1986 # ffffffffc02b56b0 <idleproc>
ffffffffc0204e7a:	00a93023          	sd	a0,0(s2)
ffffffffc0204e7e:	10050363          	beqz	a0,ffffffffc0204f84 <proc_init+0x148>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc0204e82:	4789                	li	a5,2
ffffffffc0204e84:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc0204e86:	00004797          	auipc	a5,0x4
ffffffffc0204e8a:	17a78793          	addi	a5,a5,378 # ffffffffc0209000 <bootstack>
ffffffffc0204e8e:	e91c                	sd	a5,16(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e90:	0b450413          	addi	s0,a0,180
    idleproc->need_resched = 1;
ffffffffc0204e94:	4785                	li	a5,1
ffffffffc0204e96:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204e98:	4641                	li	a2,16
ffffffffc0204e9a:	8522                	mv	a0,s0
ffffffffc0204e9c:	4581                	li	a1,0
ffffffffc0204e9e:	293000ef          	jal	ffffffffc0205930 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204ea2:	8522                	mv	a0,s0
ffffffffc0204ea4:	463d                	li	a2,15
ffffffffc0204ea6:	00002597          	auipc	a1,0x2
ffffffffc0204eaa:	63a58593          	addi	a1,a1,1594 # ffffffffc02074e0 <etext+0x1b86>
ffffffffc0204eae:	295000ef          	jal	ffffffffc0205942 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc0204eb2:	000b0797          	auipc	a5,0xb0
ffffffffc0204eb6:	7e67a783          	lw	a5,2022(a5) # ffffffffc02b5698 <nr_process>

    current = idleproc;
ffffffffc0204eba:	00093703          	ld	a4,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204ebe:	4601                	li	a2,0
    nr_process++;
ffffffffc0204ec0:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204ec2:	4581                	li	a1,0
ffffffffc0204ec4:	fffff517          	auipc	a0,0xfffff
ffffffffc0204ec8:	76650513          	addi	a0,a0,1894 # ffffffffc020462a <init_main>
    current = idleproc;
ffffffffc0204ecc:	000b0697          	auipc	a3,0xb0
ffffffffc0204ed0:	7ce6ba23          	sd	a4,2004(a3) # ffffffffc02b56a0 <current>
    nr_process++;
ffffffffc0204ed4:	000b0717          	auipc	a4,0xb0
ffffffffc0204ed8:	7cf72223          	sw	a5,1988(a4) # ffffffffc02b5698 <nr_process>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0204edc:	bd8ff0ef          	jal	ffffffffc02042b4 <kernel_thread>
ffffffffc0204ee0:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc0204ee2:	08a05563          	blez	a0,ffffffffc0204f6c <proc_init+0x130>
    if (0 < pid && pid < MAX_PID)
ffffffffc0204ee6:	6789                	lui	a5,0x2
ffffffffc0204ee8:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x6f2a>
ffffffffc0204eea:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204eee:	02e7e463          	bltu	a5,a4,ffffffffc0204f16 <proc_init+0xda>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0204ef2:	45a9                	li	a1,10
ffffffffc0204ef4:	5a6000ef          	jal	ffffffffc020549a <hash32>
ffffffffc0204ef8:	02051713          	slli	a4,a0,0x20
ffffffffc0204efc:	01c75793          	srli	a5,a4,0x1c
ffffffffc0204f00:	00f486b3          	add	a3,s1,a5
ffffffffc0204f04:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0204f06:	a029                	j	ffffffffc0204f10 <proc_init+0xd4>
            if (proc->pid == pid)
ffffffffc0204f08:	f2c7a703          	lw	a4,-212(a5)
ffffffffc0204f0c:	04870d63          	beq	a4,s0,ffffffffc0204f66 <proc_init+0x12a>
    return listelm->next;
ffffffffc0204f10:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0204f12:	fef69be3          	bne	a3,a5,ffffffffc0204f08 <proc_init+0xcc>
    return NULL;
ffffffffc0204f16:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f18:	0b478413          	addi	s0,a5,180
ffffffffc0204f1c:	4641                	li	a2,16
ffffffffc0204f1e:	4581                	li	a1,0
ffffffffc0204f20:	8522                	mv	a0,s0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0204f22:	000b0717          	auipc	a4,0xb0
ffffffffc0204f26:	78f73323          	sd	a5,1926(a4) # ffffffffc02b56a8 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204f2a:	207000ef          	jal	ffffffffc0205930 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204f2e:	8522                	mv	a0,s0
ffffffffc0204f30:	463d                	li	a2,15
ffffffffc0204f32:	00002597          	auipc	a1,0x2
ffffffffc0204f36:	5d658593          	addi	a1,a1,1494 # ffffffffc0207508 <etext+0x1bae>
ffffffffc0204f3a:	209000ef          	jal	ffffffffc0205942 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204f3e:	00093783          	ld	a5,0(s2)
ffffffffc0204f42:	cfad                	beqz	a5,ffffffffc0204fbc <proc_init+0x180>
ffffffffc0204f44:	43dc                	lw	a5,4(a5)
ffffffffc0204f46:	ebbd                	bnez	a5,ffffffffc0204fbc <proc_init+0x180>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204f48:	000b0797          	auipc	a5,0xb0
ffffffffc0204f4c:	7607b783          	ld	a5,1888(a5) # ffffffffc02b56a8 <initproc>
ffffffffc0204f50:	c7b1                	beqz	a5,ffffffffc0204f9c <proc_init+0x160>
ffffffffc0204f52:	43d8                	lw	a4,4(a5)
ffffffffc0204f54:	4785                	li	a5,1
ffffffffc0204f56:	04f71363          	bne	a4,a5,ffffffffc0204f9c <proc_init+0x160>
}
ffffffffc0204f5a:	60e2                	ld	ra,24(sp)
ffffffffc0204f5c:	6442                	ld	s0,16(sp)
ffffffffc0204f5e:	64a2                	ld	s1,8(sp)
ffffffffc0204f60:	6902                	ld	s2,0(sp)
ffffffffc0204f62:	6105                	addi	sp,sp,32
ffffffffc0204f64:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc0204f66:	f2878793          	addi	a5,a5,-216
ffffffffc0204f6a:	b77d                	j	ffffffffc0204f18 <proc_init+0xdc>
        panic("create init_main failed.\n");
ffffffffc0204f6c:	00002617          	auipc	a2,0x2
ffffffffc0204f70:	57c60613          	addi	a2,a2,1404 # ffffffffc02074e8 <etext+0x1b8e>
ffffffffc0204f74:	40200593          	li	a1,1026
ffffffffc0204f78:	00002517          	auipc	a0,0x2
ffffffffc0204f7c:	1a850513          	addi	a0,a0,424 # ffffffffc0207120 <etext+0x17c6>
ffffffffc0204f80:	ccafb0ef          	jal	ffffffffc020044a <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc0204f84:	00002617          	auipc	a2,0x2
ffffffffc0204f88:	54460613          	addi	a2,a2,1348 # ffffffffc02074c8 <etext+0x1b6e>
ffffffffc0204f8c:	3f300593          	li	a1,1011
ffffffffc0204f90:	00002517          	auipc	a0,0x2
ffffffffc0204f94:	19050513          	addi	a0,a0,400 # ffffffffc0207120 <etext+0x17c6>
ffffffffc0204f98:	cb2fb0ef          	jal	ffffffffc020044a <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc0204f9c:	00002697          	auipc	a3,0x2
ffffffffc0204fa0:	59c68693          	addi	a3,a3,1436 # ffffffffc0207538 <etext+0x1bde>
ffffffffc0204fa4:	00001617          	auipc	a2,0x1
ffffffffc0204fa8:	3ec60613          	addi	a2,a2,1004 # ffffffffc0206390 <etext+0xa36>
ffffffffc0204fac:	40900593          	li	a1,1033
ffffffffc0204fb0:	00002517          	auipc	a0,0x2
ffffffffc0204fb4:	17050513          	addi	a0,a0,368 # ffffffffc0207120 <etext+0x17c6>
ffffffffc0204fb8:	c92fb0ef          	jal	ffffffffc020044a <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc0204fbc:	00002697          	auipc	a3,0x2
ffffffffc0204fc0:	55468693          	addi	a3,a3,1364 # ffffffffc0207510 <etext+0x1bb6>
ffffffffc0204fc4:	00001617          	auipc	a2,0x1
ffffffffc0204fc8:	3cc60613          	addi	a2,a2,972 # ffffffffc0206390 <etext+0xa36>
ffffffffc0204fcc:	40800593          	li	a1,1032
ffffffffc0204fd0:	00002517          	auipc	a0,0x2
ffffffffc0204fd4:	15050513          	addi	a0,a0,336 # ffffffffc0207120 <etext+0x17c6>
ffffffffc0204fd8:	c72fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0204fdc <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc0204fdc:	1141                	addi	sp,sp,-16
ffffffffc0204fde:	e022                	sd	s0,0(sp)
ffffffffc0204fe0:	e406                	sd	ra,8(sp)
ffffffffc0204fe2:	000b0417          	auipc	s0,0xb0
ffffffffc0204fe6:	6be40413          	addi	s0,s0,1726 # ffffffffc02b56a0 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc0204fea:	6018                	ld	a4,0(s0)
ffffffffc0204fec:	6f1c                	ld	a5,24(a4)
ffffffffc0204fee:	dffd                	beqz	a5,ffffffffc0204fec <cpu_idle+0x10>
        {
            schedule();
ffffffffc0204ff0:	2f8000ef          	jal	ffffffffc02052e8 <schedule>
ffffffffc0204ff4:	bfdd                	j	ffffffffc0204fea <cpu_idle+0xe>

ffffffffc0204ff6 <lab6_set_priority>:
        }
    }
}
// FOR LAB6, set the process's priority (bigger value will get more CPU time)
void lab6_set_priority(uint32_t priority)
{
ffffffffc0204ff6:	1101                	addi	sp,sp,-32
ffffffffc0204ff8:	85aa                	mv	a1,a0
    cprintf("set priority to %d\n", priority);
ffffffffc0204ffa:	e42a                	sd	a0,8(sp)
ffffffffc0204ffc:	00002517          	auipc	a0,0x2
ffffffffc0205000:	56450513          	addi	a0,a0,1380 # ffffffffc0207560 <etext+0x1c06>
{
ffffffffc0205004:	ec06                	sd	ra,24(sp)
    cprintf("set priority to %d\n", priority);
ffffffffc0205006:	992fb0ef          	jal	ffffffffc0200198 <cprintf>
    if (priority == 0)
ffffffffc020500a:	65a2                	ld	a1,8(sp)
        current->lab6_priority = 1;
ffffffffc020500c:	000b0717          	auipc	a4,0xb0
ffffffffc0205010:	69473703          	ld	a4,1684(a4) # ffffffffc02b56a0 <current>
    if (priority == 0)
ffffffffc0205014:	4785                	li	a5,1
ffffffffc0205016:	c191                	beqz	a1,ffffffffc020501a <lab6_set_priority+0x24>
ffffffffc0205018:	87ae                	mv	a5,a1
    else
        current->lab6_priority = priority;
}
ffffffffc020501a:	60e2                	ld	ra,24(sp)
        current->lab6_priority = 1;
ffffffffc020501c:	14f72223          	sw	a5,324(a4)
}
ffffffffc0205020:	6105                	addi	sp,sp,32
ffffffffc0205022:	8082                	ret

ffffffffc0205024 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205024:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc0205028:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc020502c:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc020502e:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205030:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0205034:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc0205038:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc020503c:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0205040:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0205044:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc0205048:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc020504c:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0205050:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0205054:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc0205058:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc020505c:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0205060:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0205062:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0205064:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc0205068:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc020506c:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc0205070:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc0205074:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc0205078:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc020507c:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc0205080:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc0205084:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc0205088:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc020508c:	8082                	ret

ffffffffc020508e <RR_init>:
    elm->prev = elm->next = elm;
ffffffffc020508e:	e508                	sd	a0,8(a0)
ffffffffc0205090:	e108                	sd	a0,0(a0)
 */
static void
RR_init(struct run_queue *rq)
{
    list_init(&(rq->run_list));
    rq->proc_num = 0;
ffffffffc0205092:	00052823          	sw	zero,16(a0)
}
ffffffffc0205096:	8082                	ret

ffffffffc0205098 <RR_pick_next>:
    return listelm->next;
ffffffffc0205098:	651c                	ld	a5,8(a0)
 */
static struct proc_struct *
RR_pick_next(struct run_queue *rq)
{
    list_entry_t *le = list_next(&(rq->run_list));
    if (le != &(rq->run_list)) {
ffffffffc020509a:	00f50563          	beq	a0,a5,ffffffffc02050a4 <RR_pick_next+0xc>
        return le2proc(le, run_link);
ffffffffc020509e:	ef078513          	addi	a0,a5,-272
ffffffffc02050a2:	8082                	ret
    }
    return NULL;
ffffffffc02050a4:	4501                	li	a0,0
}
ffffffffc02050a6:	8082                	ret

ffffffffc02050a8 <RR_proc_tick>:
 * is the flag variable for process switching.
 */
static void
RR_proc_tick(struct run_queue *rq, struct proc_struct *proc)
{
    if (proc->time_slice > 0) {
ffffffffc02050a8:	1205a783          	lw	a5,288(a1)
ffffffffc02050ac:	00f05563          	blez	a5,ffffffffc02050b6 <RR_proc_tick+0xe>
        proc->time_slice --;
ffffffffc02050b0:	37fd                	addiw	a5,a5,-1
ffffffffc02050b2:	12f5a023          	sw	a5,288(a1)
    }
    if (proc->time_slice == 0) {
ffffffffc02050b6:	e399                	bnez	a5,ffffffffc02050bc <RR_proc_tick+0x14>
        proc->need_resched = 1;
ffffffffc02050b8:	4785                	li	a5,1
ffffffffc02050ba:	ed9c                	sd	a5,24(a1)
    }
}
ffffffffc02050bc:	8082                	ret

ffffffffc02050be <RR_dequeue>:
    return list->next == list;
ffffffffc02050be:	1185b703          	ld	a4,280(a1)
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
ffffffffc02050c2:	11058793          	addi	a5,a1,272
ffffffffc02050c6:	02e78263          	beq	a5,a4,ffffffffc02050ea <RR_dequeue+0x2c>
ffffffffc02050ca:	1085b683          	ld	a3,264(a1)
ffffffffc02050ce:	00a69e63          	bne	a3,a0,ffffffffc02050ea <RR_dequeue+0x2c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02050d2:	1105b503          	ld	a0,272(a1)
    rq->proc_num --;
ffffffffc02050d6:	4a90                	lw	a2,16(a3)
    prev->next = next;
ffffffffc02050d8:	e518                	sd	a4,8(a0)
    next->prev = prev;
ffffffffc02050da:	e308                	sd	a0,0(a4)
    elm->prev = elm->next = elm;
ffffffffc02050dc:	10f5bc23          	sd	a5,280(a1)
ffffffffc02050e0:	10f5b823          	sd	a5,272(a1)
ffffffffc02050e4:	367d                	addiw	a2,a2,-1
ffffffffc02050e6:	ca90                	sw	a2,16(a3)
ffffffffc02050e8:	8082                	ret
{
ffffffffc02050ea:	1141                	addi	sp,sp,-16
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
ffffffffc02050ec:	00002697          	auipc	a3,0x2
ffffffffc02050f0:	48c68693          	addi	a3,a3,1164 # ffffffffc0207578 <etext+0x1c1e>
ffffffffc02050f4:	00001617          	auipc	a2,0x1
ffffffffc02050f8:	29c60613          	addi	a2,a2,668 # ffffffffc0206390 <etext+0xa36>
ffffffffc02050fc:	03900593          	li	a1,57
ffffffffc0205100:	00002517          	auipc	a0,0x2
ffffffffc0205104:	4b050513          	addi	a0,a0,1200 # ffffffffc02075b0 <etext+0x1c56>
{
ffffffffc0205108:	e406                	sd	ra,8(sp)
    assert(!list_empty(&(proc->run_link)) && proc->rq == rq);
ffffffffc020510a:	b40fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020510e <RR_enqueue>:
    assert(list_empty(&(proc->run_link)));
ffffffffc020510e:	1185b703          	ld	a4,280(a1)
ffffffffc0205112:	11058793          	addi	a5,a1,272
ffffffffc0205116:	02e79d63          	bne	a5,a4,ffffffffc0205150 <RR_enqueue+0x42>
    __list_add(elm, listelm->prev, listelm);
ffffffffc020511a:	6118                	ld	a4,0(a0)
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc020511c:	1205a683          	lw	a3,288(a1)
    prev->next = next->prev = elm;
ffffffffc0205120:	e11c                	sd	a5,0(a0)
ffffffffc0205122:	e71c                	sd	a5,8(a4)
    elm->prev = prev;
ffffffffc0205124:	10e5b823          	sd	a4,272(a1)
    elm->next = next;
ffffffffc0205128:	10a5bc23          	sd	a0,280(a1)
ffffffffc020512c:	495c                	lw	a5,20(a0)
ffffffffc020512e:	ea89                	bnez	a3,ffffffffc0205140 <RR_enqueue+0x32>
        proc->time_slice = rq->max_time_slice;
ffffffffc0205130:	12f5a023          	sw	a5,288(a1)
    rq->proc_num ++;
ffffffffc0205134:	491c                	lw	a5,16(a0)
    proc->rq = rq;
ffffffffc0205136:	10a5b423          	sd	a0,264(a1)
    rq->proc_num ++;
ffffffffc020513a:	2785                	addiw	a5,a5,1
ffffffffc020513c:	c91c                	sw	a5,16(a0)
ffffffffc020513e:	8082                	ret
    if (proc->time_slice == 0 || proc->time_slice > rq->max_time_slice) {
ffffffffc0205140:	fed7c8e3          	blt	a5,a3,ffffffffc0205130 <RR_enqueue+0x22>
    rq->proc_num ++;
ffffffffc0205144:	491c                	lw	a5,16(a0)
    proc->rq = rq;
ffffffffc0205146:	10a5b423          	sd	a0,264(a1)
    rq->proc_num ++;
ffffffffc020514a:	2785                	addiw	a5,a5,1
ffffffffc020514c:	c91c                	sw	a5,16(a0)
ffffffffc020514e:	8082                	ret
{
ffffffffc0205150:	1141                	addi	sp,sp,-16
    assert(list_empty(&(proc->run_link)));
ffffffffc0205152:	00002697          	auipc	a3,0x2
ffffffffc0205156:	47e68693          	addi	a3,a3,1150 # ffffffffc02075d0 <etext+0x1c76>
ffffffffc020515a:	00001617          	auipc	a2,0x1
ffffffffc020515e:	23660613          	addi	a2,a2,566 # ffffffffc0206390 <etext+0xa36>
ffffffffc0205162:	02600593          	li	a1,38
ffffffffc0205166:	00002517          	auipc	a0,0x2
ffffffffc020516a:	44a50513          	addi	a0,a0,1098 # ffffffffc02075b0 <etext+0x1c56>
{
ffffffffc020516e:	e406                	sd	ra,8(sp)
    assert(list_empty(&(proc->run_link)));
ffffffffc0205170:	adafb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0205174 <sched_class_proc_tick>:
    return sched_class->pick_next(rq);
}

void sched_class_proc_tick(struct proc_struct *proc)
{
    if (proc != idleproc)
ffffffffc0205174:	000b0797          	auipc	a5,0xb0
ffffffffc0205178:	53c7b783          	ld	a5,1340(a5) # ffffffffc02b56b0 <idleproc>
{
ffffffffc020517c:	85aa                	mv	a1,a0
    if (proc != idleproc)
ffffffffc020517e:	00a78c63          	beq	a5,a0,ffffffffc0205196 <sched_class_proc_tick+0x22>
    {
        sched_class->proc_tick(rq, proc);
ffffffffc0205182:	000b0797          	auipc	a5,0xb0
ffffffffc0205186:	53e7b783          	ld	a5,1342(a5) # ffffffffc02b56c0 <sched_class>
ffffffffc020518a:	000b0517          	auipc	a0,0xb0
ffffffffc020518e:	52e53503          	ld	a0,1326(a0) # ffffffffc02b56b8 <rq>
ffffffffc0205192:	779c                	ld	a5,40(a5)
ffffffffc0205194:	8782                	jr	a5
    }
    else
    {
        proc->need_resched = 1;
ffffffffc0205196:	4705                	li	a4,1
ffffffffc0205198:	ef98                	sd	a4,24(a5)
    }
}
ffffffffc020519a:	8082                	ret

ffffffffc020519c <sched_init>:

void sched_init(void)
{
    list_init(&timer_list);

    sched_class = &default_sched_class;
ffffffffc020519c:	000ac797          	auipc	a5,0xac
ffffffffc02051a0:	00c78793          	addi	a5,a5,12 # ffffffffc02b11a8 <default_sched_class>
{
ffffffffc02051a4:	1141                	addi	sp,sp,-16

    rq = &__rq;
    rq->max_time_slice = MAX_TIME_SLICE;
    sched_class->init(rq);
ffffffffc02051a6:	6794                	ld	a3,8(a5)
    sched_class = &default_sched_class;
ffffffffc02051a8:	000b0717          	auipc	a4,0xb0
ffffffffc02051ac:	50f73c23          	sd	a5,1304(a4) # ffffffffc02b56c0 <sched_class>
{
ffffffffc02051b0:	e406                	sd	ra,8(sp)
    elm->prev = elm->next = elm;
ffffffffc02051b2:	000b0797          	auipc	a5,0xb0
ffffffffc02051b6:	47e78793          	addi	a5,a5,1150 # ffffffffc02b5630 <timer_list>
    rq = &__rq;
ffffffffc02051ba:	000b0717          	auipc	a4,0xb0
ffffffffc02051be:	45670713          	addi	a4,a4,1110 # ffffffffc02b5610 <__rq>
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc02051c2:	4615                	li	a2,5
ffffffffc02051c4:	e79c                	sd	a5,8(a5)
ffffffffc02051c6:	e39c                	sd	a5,0(a5)
    sched_class->init(rq);
ffffffffc02051c8:	853a                	mv	a0,a4
    rq->max_time_slice = MAX_TIME_SLICE;
ffffffffc02051ca:	cb50                	sw	a2,20(a4)
    rq = &__rq;
ffffffffc02051cc:	000b0797          	auipc	a5,0xb0
ffffffffc02051d0:	4ee7b623          	sd	a4,1260(a5) # ffffffffc02b56b8 <rq>
    sched_class->init(rq);
ffffffffc02051d4:	9682                	jalr	a3

    cprintf("sched class: %s\n", sched_class->name);
ffffffffc02051d6:	000b0797          	auipc	a5,0xb0
ffffffffc02051da:	4ea7b783          	ld	a5,1258(a5) # ffffffffc02b56c0 <sched_class>
}
ffffffffc02051de:	60a2                	ld	ra,8(sp)
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc02051e0:	00002517          	auipc	a0,0x2
ffffffffc02051e4:	42050513          	addi	a0,a0,1056 # ffffffffc0207600 <etext+0x1ca6>
ffffffffc02051e8:	638c                	ld	a1,0(a5)
}
ffffffffc02051ea:	0141                	addi	sp,sp,16
    cprintf("sched class: %s\n", sched_class->name);
ffffffffc02051ec:	fadfa06f          	j	ffffffffc0200198 <cprintf>

ffffffffc02051f0 <wakeup_proc>:

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02051f0:	4118                	lw	a4,0(a0)
{
ffffffffc02051f2:	1101                	addi	sp,sp,-32
ffffffffc02051f4:	ec06                	sd	ra,24(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02051f6:	478d                	li	a5,3
ffffffffc02051f8:	0cf70863          	beq	a4,a5,ffffffffc02052c8 <wakeup_proc+0xd8>
ffffffffc02051fc:	85aa                	mv	a1,a0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02051fe:	100027f3          	csrr	a5,sstatus
ffffffffc0205202:	8b89                	andi	a5,a5,2
ffffffffc0205204:	e3b1                	bnez	a5,ffffffffc0205248 <wakeup_proc+0x58>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
ffffffffc0205206:	4789                	li	a5,2
ffffffffc0205208:	08f70563          	beq	a4,a5,ffffffffc0205292 <wakeup_proc+0xa2>
        {
            proc->state = PROC_RUNNABLE;
            proc->wait_state = 0;
            if (proc != current)
ffffffffc020520c:	000b0717          	auipc	a4,0xb0
ffffffffc0205210:	49473703          	ld	a4,1172(a4) # ffffffffc02b56a0 <current>
            proc->wait_state = 0;
ffffffffc0205214:	0e052623          	sw	zero,236(a0)
            proc->state = PROC_RUNNABLE;
ffffffffc0205218:	c11c                	sw	a5,0(a0)
            if (proc != current)
ffffffffc020521a:	02e50463          	beq	a0,a4,ffffffffc0205242 <wakeup_proc+0x52>
    if (proc != idleproc)
ffffffffc020521e:	000b0797          	auipc	a5,0xb0
ffffffffc0205222:	4927b783          	ld	a5,1170(a5) # ffffffffc02b56b0 <idleproc>
ffffffffc0205226:	00f50e63          	beq	a0,a5,ffffffffc0205242 <wakeup_proc+0x52>
        sched_class->enqueue(rq, proc);
ffffffffc020522a:	000b0797          	auipc	a5,0xb0
ffffffffc020522e:	4967b783          	ld	a5,1174(a5) # ffffffffc02b56c0 <sched_class>
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205232:	60e2                	ld	ra,24(sp)
        sched_class->enqueue(rq, proc);
ffffffffc0205234:	000b0517          	auipc	a0,0xb0
ffffffffc0205238:	48453503          	ld	a0,1156(a0) # ffffffffc02b56b8 <rq>
ffffffffc020523c:	6b9c                	ld	a5,16(a5)
}
ffffffffc020523e:	6105                	addi	sp,sp,32
        sched_class->enqueue(rq, proc);
ffffffffc0205240:	8782                	jr	a5
}
ffffffffc0205242:	60e2                	ld	ra,24(sp)
ffffffffc0205244:	6105                	addi	sp,sp,32
ffffffffc0205246:	8082                	ret
        intr_disable();
ffffffffc0205248:	e42a                	sd	a0,8(sp)
ffffffffc020524a:	eb4fb0ef          	jal	ffffffffc02008fe <intr_disable>
        if (proc->state != PROC_RUNNABLE)
ffffffffc020524e:	65a2                	ld	a1,8(sp)
ffffffffc0205250:	4789                	li	a5,2
ffffffffc0205252:	4198                	lw	a4,0(a1)
ffffffffc0205254:	04f70d63          	beq	a4,a5,ffffffffc02052ae <wakeup_proc+0xbe>
            if (proc != current)
ffffffffc0205258:	000b0717          	auipc	a4,0xb0
ffffffffc020525c:	44873703          	ld	a4,1096(a4) # ffffffffc02b56a0 <current>
            proc->wait_state = 0;
ffffffffc0205260:	0e05a623          	sw	zero,236(a1)
            proc->state = PROC_RUNNABLE;
ffffffffc0205264:	c19c                	sw	a5,0(a1)
            if (proc != current)
ffffffffc0205266:	02e58263          	beq	a1,a4,ffffffffc020528a <wakeup_proc+0x9a>
    if (proc != idleproc)
ffffffffc020526a:	000b0797          	auipc	a5,0xb0
ffffffffc020526e:	4467b783          	ld	a5,1094(a5) # ffffffffc02b56b0 <idleproc>
ffffffffc0205272:	00f58c63          	beq	a1,a5,ffffffffc020528a <wakeup_proc+0x9a>
        sched_class->enqueue(rq, proc);
ffffffffc0205276:	000b0797          	auipc	a5,0xb0
ffffffffc020527a:	44a7b783          	ld	a5,1098(a5) # ffffffffc02b56c0 <sched_class>
ffffffffc020527e:	000b0517          	auipc	a0,0xb0
ffffffffc0205282:	43a53503          	ld	a0,1082(a0) # ffffffffc02b56b8 <rq>
ffffffffc0205286:	6b9c                	ld	a5,16(a5)
ffffffffc0205288:	9782                	jalr	a5
}
ffffffffc020528a:	60e2                	ld	ra,24(sp)
ffffffffc020528c:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc020528e:	e6afb06f          	j	ffffffffc02008f8 <intr_enable>
ffffffffc0205292:	60e2                	ld	ra,24(sp)
            warn("wakeup runnable process.\n");
ffffffffc0205294:	00002617          	auipc	a2,0x2
ffffffffc0205298:	3bc60613          	addi	a2,a2,956 # ffffffffc0207650 <etext+0x1cf6>
ffffffffc020529c:	05100593          	li	a1,81
ffffffffc02052a0:	00002517          	auipc	a0,0x2
ffffffffc02052a4:	39850513          	addi	a0,a0,920 # ffffffffc0207638 <etext+0x1cde>
}
ffffffffc02052a8:	6105                	addi	sp,sp,32
            warn("wakeup runnable process.\n");
ffffffffc02052aa:	a0afb06f          	j	ffffffffc02004b4 <__warn>
ffffffffc02052ae:	00002617          	auipc	a2,0x2
ffffffffc02052b2:	3a260613          	addi	a2,a2,930 # ffffffffc0207650 <etext+0x1cf6>
ffffffffc02052b6:	05100593          	li	a1,81
ffffffffc02052ba:	00002517          	auipc	a0,0x2
ffffffffc02052be:	37e50513          	addi	a0,a0,894 # ffffffffc0207638 <etext+0x1cde>
ffffffffc02052c2:	9f2fb0ef          	jal	ffffffffc02004b4 <__warn>
    if (flag)
ffffffffc02052c6:	b7d1                	j	ffffffffc020528a <wakeup_proc+0x9a>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02052c8:	00002697          	auipc	a3,0x2
ffffffffc02052cc:	35068693          	addi	a3,a3,848 # ffffffffc0207618 <etext+0x1cbe>
ffffffffc02052d0:	00001617          	auipc	a2,0x1
ffffffffc02052d4:	0c060613          	addi	a2,a2,192 # ffffffffc0206390 <etext+0xa36>
ffffffffc02052d8:	04200593          	li	a1,66
ffffffffc02052dc:	00002517          	auipc	a0,0x2
ffffffffc02052e0:	35c50513          	addi	a0,a0,860 # ffffffffc0207638 <etext+0x1cde>
ffffffffc02052e4:	966fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02052e8 <schedule>:

void schedule(void)
{
ffffffffc02052e8:	7139                	addi	sp,sp,-64
ffffffffc02052ea:	fc06                	sd	ra,56(sp)
ffffffffc02052ec:	f822                	sd	s0,48(sp)
ffffffffc02052ee:	f426                	sd	s1,40(sp)
ffffffffc02052f0:	f04a                	sd	s2,32(sp)
ffffffffc02052f2:	ec4e                	sd	s3,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02052f4:	100027f3          	csrr	a5,sstatus
ffffffffc02052f8:	8b89                	andi	a5,a5,2
ffffffffc02052fa:	4981                	li	s3,0
ffffffffc02052fc:	efc9                	bnez	a5,ffffffffc0205396 <schedule+0xae>
    bool intr_flag;
    struct proc_struct *next;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc02052fe:	000b0417          	auipc	s0,0xb0
ffffffffc0205302:	3a240413          	addi	s0,s0,930 # ffffffffc02b56a0 <current>
ffffffffc0205306:	600c                	ld	a1,0(s0)
        if (current->state == PROC_RUNNABLE)
ffffffffc0205308:	4789                	li	a5,2
ffffffffc020530a:	000b0497          	auipc	s1,0xb0
ffffffffc020530e:	3ae48493          	addi	s1,s1,942 # ffffffffc02b56b8 <rq>
ffffffffc0205312:	4198                	lw	a4,0(a1)
        current->need_resched = 0;
ffffffffc0205314:	0005bc23          	sd	zero,24(a1)
        if (current->state == PROC_RUNNABLE)
ffffffffc0205318:	000b0917          	auipc	s2,0xb0
ffffffffc020531c:	3a890913          	addi	s2,s2,936 # ffffffffc02b56c0 <sched_class>
ffffffffc0205320:	04f70f63          	beq	a4,a5,ffffffffc020537e <schedule+0x96>
    return sched_class->pick_next(rq);
ffffffffc0205324:	00093783          	ld	a5,0(s2)
ffffffffc0205328:	6088                	ld	a0,0(s1)
ffffffffc020532a:	739c                	ld	a5,32(a5)
ffffffffc020532c:	9782                	jalr	a5
ffffffffc020532e:	85aa                	mv	a1,a0
        {
            sched_class_enqueue(current);
        }
        if ((next = sched_class_pick_next()) != NULL)
ffffffffc0205330:	c131                	beqz	a0,ffffffffc0205374 <schedule+0x8c>
    sched_class->dequeue(rq, proc);
ffffffffc0205332:	00093783          	ld	a5,0(s2)
ffffffffc0205336:	6088                	ld	a0,0(s1)
ffffffffc0205338:	e42e                	sd	a1,8(sp)
ffffffffc020533a:	6f9c                	ld	a5,24(a5)
ffffffffc020533c:	9782                	jalr	a5
ffffffffc020533e:	65a2                	ld	a1,8(sp)
        }
        if (next == NULL)
        {
            next = idleproc;
        }
        next->runs++;
ffffffffc0205340:	459c                	lw	a5,8(a1)
        if (next != current)
ffffffffc0205342:	6018                	ld	a4,0(s0)
        next->runs++;
ffffffffc0205344:	2785                	addiw	a5,a5,1
ffffffffc0205346:	c59c                	sw	a5,8(a1)
        if (next != current)
ffffffffc0205348:	00b70563          	beq	a4,a1,ffffffffc0205352 <schedule+0x6a>
        {
            proc_run(next);
ffffffffc020534c:	852e                	mv	a0,a1
ffffffffc020534e:	abdfe0ef          	jal	ffffffffc0203e0a <proc_run>
    if (flag)
ffffffffc0205352:	00099963          	bnez	s3,ffffffffc0205364 <schedule+0x7c>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc0205356:	70e2                	ld	ra,56(sp)
ffffffffc0205358:	7442                	ld	s0,48(sp)
ffffffffc020535a:	74a2                	ld	s1,40(sp)
ffffffffc020535c:	7902                	ld	s2,32(sp)
ffffffffc020535e:	69e2                	ld	s3,24(sp)
ffffffffc0205360:	6121                	addi	sp,sp,64
ffffffffc0205362:	8082                	ret
ffffffffc0205364:	7442                	ld	s0,48(sp)
ffffffffc0205366:	70e2                	ld	ra,56(sp)
ffffffffc0205368:	74a2                	ld	s1,40(sp)
ffffffffc020536a:	7902                	ld	s2,32(sp)
ffffffffc020536c:	69e2                	ld	s3,24(sp)
ffffffffc020536e:	6121                	addi	sp,sp,64
        intr_enable();
ffffffffc0205370:	d88fb06f          	j	ffffffffc02008f8 <intr_enable>
            next = idleproc;
ffffffffc0205374:	000b0597          	auipc	a1,0xb0
ffffffffc0205378:	33c5b583          	ld	a1,828(a1) # ffffffffc02b56b0 <idleproc>
ffffffffc020537c:	b7d1                	j	ffffffffc0205340 <schedule+0x58>
    if (proc != idleproc)
ffffffffc020537e:	000b0797          	auipc	a5,0xb0
ffffffffc0205382:	3327b783          	ld	a5,818(a5) # ffffffffc02b56b0 <idleproc>
ffffffffc0205386:	f8f58fe3          	beq	a1,a5,ffffffffc0205324 <schedule+0x3c>
        sched_class->enqueue(rq, proc);
ffffffffc020538a:	00093783          	ld	a5,0(s2)
ffffffffc020538e:	6088                	ld	a0,0(s1)
ffffffffc0205390:	6b9c                	ld	a5,16(a5)
ffffffffc0205392:	9782                	jalr	a5
ffffffffc0205394:	bf41                	j	ffffffffc0205324 <schedule+0x3c>
        intr_disable();
ffffffffc0205396:	d68fb0ef          	jal	ffffffffc02008fe <intr_disable>
        return 1;
ffffffffc020539a:	4985                	li	s3,1
ffffffffc020539c:	b78d                	j	ffffffffc02052fe <schedule+0x16>

ffffffffc020539e <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc020539e:	000b0797          	auipc	a5,0xb0
ffffffffc02053a2:	3027b783          	ld	a5,770(a5) # ffffffffc02b56a0 <current>
}
ffffffffc02053a6:	43c8                	lw	a0,4(a5)
ffffffffc02053a8:	8082                	ret

ffffffffc02053aa <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc02053aa:	4501                	li	a0,0
ffffffffc02053ac:	8082                	ret

ffffffffc02053ae <sys_gettime>:
static int sys_gettime(uint64_t arg[]){
    return (int)ticks*10;
ffffffffc02053ae:	000b0797          	auipc	a5,0xb0
ffffffffc02053b2:	29a7b783          	ld	a5,666(a5) # ffffffffc02b5648 <ticks>
ffffffffc02053b6:	0027951b          	slliw	a0,a5,0x2
ffffffffc02053ba:	9d3d                	addw	a0,a0,a5
ffffffffc02053bc:	0015151b          	slliw	a0,a0,0x1
}
ffffffffc02053c0:	8082                	ret

ffffffffc02053c2 <sys_lab6_set_priority>:
static int sys_lab6_set_priority(uint64_t arg[]){
    uint64_t priority = (uint64_t)arg[0];
    lab6_set_priority(priority);
ffffffffc02053c2:	4108                	lw	a0,0(a0)
static int sys_lab6_set_priority(uint64_t arg[]){
ffffffffc02053c4:	1141                	addi	sp,sp,-16
ffffffffc02053c6:	e406                	sd	ra,8(sp)
    lab6_set_priority(priority);
ffffffffc02053c8:	c2fff0ef          	jal	ffffffffc0204ff6 <lab6_set_priority>
    return 0;
}
ffffffffc02053cc:	60a2                	ld	ra,8(sp)
ffffffffc02053ce:	4501                	li	a0,0
ffffffffc02053d0:	0141                	addi	sp,sp,16
ffffffffc02053d2:	8082                	ret

ffffffffc02053d4 <sys_putc>:
    cputchar(c);
ffffffffc02053d4:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc02053d6:	1141                	addi	sp,sp,-16
ffffffffc02053d8:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc02053da:	df3fa0ef          	jal	ffffffffc02001cc <cputchar>
}
ffffffffc02053de:	60a2                	ld	ra,8(sp)
ffffffffc02053e0:	4501                	li	a0,0
ffffffffc02053e2:	0141                	addi	sp,sp,16
ffffffffc02053e4:	8082                	ret

ffffffffc02053e6 <sys_kill>:
    return do_kill(pid);
ffffffffc02053e6:	4108                	lw	a0,0(a0)
ffffffffc02053e8:	9ddff06f          	j	ffffffffc0204dc4 <do_kill>

ffffffffc02053ec <sys_yield>:
    return do_yield();
ffffffffc02053ec:	98fff06f          	j	ffffffffc0204d7a <do_yield>

ffffffffc02053f0 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc02053f0:	6d14                	ld	a3,24(a0)
ffffffffc02053f2:	6910                	ld	a2,16(a0)
ffffffffc02053f4:	650c                	ld	a1,8(a0)
ffffffffc02053f6:	6108                	ld	a0,0(a0)
ffffffffc02053f8:	b56ff06f          	j	ffffffffc020474e <do_execve>

ffffffffc02053fc <sys_wait>:
    return do_wait(pid, store);
ffffffffc02053fc:	650c                	ld	a1,8(a0)
ffffffffc02053fe:	4108                	lw	a0,0(a0)
ffffffffc0205400:	98bff06f          	j	ffffffffc0204d8a <do_wait>

ffffffffc0205404 <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc0205404:	000b0797          	auipc	a5,0xb0
ffffffffc0205408:	29c7b783          	ld	a5,668(a5) # ffffffffc02b56a0 <current>
    return do_fork(0, stack, tf);
ffffffffc020540c:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc020540e:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0205410:	6a0c                	ld	a1,16(a2)
ffffffffc0205412:	a5dfe06f          	j	ffffffffc0203e6e <do_fork>

ffffffffc0205416 <sys_exit>:
    return do_exit(error_code);
ffffffffc0205416:	4108                	lw	a0,0(a0)
ffffffffc0205418:	eedfe06f          	j	ffffffffc0204304 <do_exit>

ffffffffc020541c <syscall>:

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
    struct trapframe *tf = current->tf;
ffffffffc020541c:	000b0697          	auipc	a3,0xb0
ffffffffc0205420:	2846b683          	ld	a3,644(a3) # ffffffffc02b56a0 <current>
syscall(void) {
ffffffffc0205424:	715d                	addi	sp,sp,-80
ffffffffc0205426:	e0a2                	sd	s0,64(sp)
    struct trapframe *tf = current->tf;
ffffffffc0205428:	72c0                	ld	s0,160(a3)
syscall(void) {
ffffffffc020542a:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc020542c:	0ff00793          	li	a5,255
    int num = tf->gpr.a0;
ffffffffc0205430:	4834                	lw	a3,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205432:	02d7ec63          	bltu	a5,a3,ffffffffc020546a <syscall+0x4e>
        if (syscalls[num] != NULL) {
ffffffffc0205436:	00002797          	auipc	a5,0x2
ffffffffc020543a:	46278793          	addi	a5,a5,1122 # ffffffffc0207898 <syscalls>
ffffffffc020543e:	00369613          	slli	a2,a3,0x3
ffffffffc0205442:	97b2                	add	a5,a5,a2
ffffffffc0205444:	639c                	ld	a5,0(a5)
ffffffffc0205446:	c395                	beqz	a5,ffffffffc020546a <syscall+0x4e>
            arg[0] = tf->gpr.a1;
ffffffffc0205448:	7028                	ld	a0,96(s0)
ffffffffc020544a:	742c                	ld	a1,104(s0)
ffffffffc020544c:	7830                	ld	a2,112(s0)
ffffffffc020544e:	7c34                	ld	a3,120(s0)
ffffffffc0205450:	6c38                	ld	a4,88(s0)
ffffffffc0205452:	f02a                	sd	a0,32(sp)
ffffffffc0205454:	f42e                	sd	a1,40(sp)
ffffffffc0205456:	f832                	sd	a2,48(sp)
ffffffffc0205458:	fc36                	sd	a3,56(sp)
ffffffffc020545a:	ec3a                	sd	a4,24(sp)
            arg[1] = tf->gpr.a2;
            arg[2] = tf->gpr.a3;
            arg[3] = tf->gpr.a4;
            arg[4] = tf->gpr.a5;
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc020545c:	0828                	addi	a0,sp,24
ffffffffc020545e:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0205460:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205462:	e828                	sd	a0,80(s0)
}
ffffffffc0205464:	6406                	ld	s0,64(sp)
ffffffffc0205466:	6161                	addi	sp,sp,80
ffffffffc0205468:	8082                	ret
    print_trapframe(tf);
ffffffffc020546a:	8522                	mv	a0,s0
ffffffffc020546c:	e436                	sd	a3,8(sp)
ffffffffc020546e:	e80fb0ef          	jal	ffffffffc0200aee <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0205472:	000b0797          	auipc	a5,0xb0
ffffffffc0205476:	22e7b783          	ld	a5,558(a5) # ffffffffc02b56a0 <current>
ffffffffc020547a:	66a2                	ld	a3,8(sp)
ffffffffc020547c:	00002617          	auipc	a2,0x2
ffffffffc0205480:	1f460613          	addi	a2,a2,500 # ffffffffc0207670 <etext+0x1d16>
ffffffffc0205484:	43d8                	lw	a4,4(a5)
ffffffffc0205486:	06c00593          	li	a1,108
ffffffffc020548a:	0b478793          	addi	a5,a5,180
ffffffffc020548e:	00002517          	auipc	a0,0x2
ffffffffc0205492:	21250513          	addi	a0,a0,530 # ffffffffc02076a0 <etext+0x1d46>
ffffffffc0205496:	fb5fa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020549a <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc020549a:	9e3707b7          	lui	a5,0x9e370
ffffffffc020549e:	2785                	addiw	a5,a5,1 # ffffffff9e370001 <_binary_obj___user_matrix_out_size+0xffffffff9e364ac1>
ffffffffc02054a0:	02a787bb          	mulw	a5,a5,a0
    return (hash >> (32 - bits));
ffffffffc02054a4:	02000513          	li	a0,32
ffffffffc02054a8:	9d0d                	subw	a0,a0,a1
}
ffffffffc02054aa:	00a7d53b          	srlw	a0,a5,a0
ffffffffc02054ae:	8082                	ret

ffffffffc02054b0 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02054b0:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02054b2:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02054b6:	f022                	sd	s0,32(sp)
ffffffffc02054b8:	ec26                	sd	s1,24(sp)
ffffffffc02054ba:	e84a                	sd	s2,16(sp)
ffffffffc02054bc:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02054be:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02054c2:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
ffffffffc02054c4:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02054c8:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02054cc:	84aa                	mv	s1,a0
ffffffffc02054ce:	892e                	mv	s2,a1
    if (num >= base) {
ffffffffc02054d0:	03067d63          	bgeu	a2,a6,ffffffffc020550a <printnum+0x5a>
ffffffffc02054d4:	e44e                	sd	s3,8(sp)
ffffffffc02054d6:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02054d8:	4785                	li	a5,1
ffffffffc02054da:	00e7d763          	bge	a5,a4,ffffffffc02054e8 <printnum+0x38>
            putch(padc, putdat);
ffffffffc02054de:	85ca                	mv	a1,s2
ffffffffc02054e0:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc02054e2:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc02054e4:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc02054e6:	fc65                	bnez	s0,ffffffffc02054de <printnum+0x2e>
ffffffffc02054e8:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02054ea:	00002797          	auipc	a5,0x2
ffffffffc02054ee:	1ce78793          	addi	a5,a5,462 # ffffffffc02076b8 <etext+0x1d5e>
ffffffffc02054f2:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc02054f4:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02054f6:	0007c503          	lbu	a0,0(a5)
}
ffffffffc02054fa:	70a2                	ld	ra,40(sp)
ffffffffc02054fc:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc02054fe:	85ca                	mv	a1,s2
ffffffffc0205500:	87a6                	mv	a5,s1
}
ffffffffc0205502:	6942                	ld	s2,16(sp)
ffffffffc0205504:	64e2                	ld	s1,24(sp)
ffffffffc0205506:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205508:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020550a:	03065633          	divu	a2,a2,a6
ffffffffc020550e:	8722                	mv	a4,s0
ffffffffc0205510:	fa1ff0ef          	jal	ffffffffc02054b0 <printnum>
ffffffffc0205514:	bfd9                	j	ffffffffc02054ea <printnum+0x3a>

ffffffffc0205516 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0205516:	7119                	addi	sp,sp,-128
ffffffffc0205518:	f4a6                	sd	s1,104(sp)
ffffffffc020551a:	f0ca                	sd	s2,96(sp)
ffffffffc020551c:	ecce                	sd	s3,88(sp)
ffffffffc020551e:	e8d2                	sd	s4,80(sp)
ffffffffc0205520:	e4d6                	sd	s5,72(sp)
ffffffffc0205522:	e0da                	sd	s6,64(sp)
ffffffffc0205524:	f862                	sd	s8,48(sp)
ffffffffc0205526:	fc86                	sd	ra,120(sp)
ffffffffc0205528:	f8a2                	sd	s0,112(sp)
ffffffffc020552a:	fc5e                	sd	s7,56(sp)
ffffffffc020552c:	f466                	sd	s9,40(sp)
ffffffffc020552e:	f06a                	sd	s10,32(sp)
ffffffffc0205530:	ec6e                	sd	s11,24(sp)
ffffffffc0205532:	84aa                	mv	s1,a0
ffffffffc0205534:	8c32                	mv	s8,a2
ffffffffc0205536:	8a36                	mv	s4,a3
ffffffffc0205538:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020553a:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc020553e:	05500b13          	li	s6,85
ffffffffc0205542:	00003a97          	auipc	s5,0x3
ffffffffc0205546:	b56a8a93          	addi	s5,s5,-1194 # ffffffffc0208098 <syscalls+0x800>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020554a:	000c4503          	lbu	a0,0(s8)
ffffffffc020554e:	001c0413          	addi	s0,s8,1
ffffffffc0205552:	01350a63          	beq	a0,s3,ffffffffc0205566 <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc0205556:	cd0d                	beqz	a0,ffffffffc0205590 <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc0205558:	85ca                	mv	a1,s2
ffffffffc020555a:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020555c:	00044503          	lbu	a0,0(s0)
ffffffffc0205560:	0405                	addi	s0,s0,1
ffffffffc0205562:	ff351ae3          	bne	a0,s3,ffffffffc0205556 <vprintfmt+0x40>
        width = precision = -1;
ffffffffc0205566:	5cfd                	li	s9,-1
ffffffffc0205568:	8d66                	mv	s10,s9
        char padc = ' ';
ffffffffc020556a:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc020556e:	4b81                	li	s7,0
ffffffffc0205570:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205572:	00044683          	lbu	a3,0(s0)
ffffffffc0205576:	00140c13          	addi	s8,s0,1
ffffffffc020557a:	fdd6859b          	addiw	a1,a3,-35
ffffffffc020557e:	0ff5f593          	zext.b	a1,a1
ffffffffc0205582:	02bb6663          	bltu	s6,a1,ffffffffc02055ae <vprintfmt+0x98>
ffffffffc0205586:	058a                	slli	a1,a1,0x2
ffffffffc0205588:	95d6                	add	a1,a1,s5
ffffffffc020558a:	4198                	lw	a4,0(a1)
ffffffffc020558c:	9756                	add	a4,a4,s5
ffffffffc020558e:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0205590:	70e6                	ld	ra,120(sp)
ffffffffc0205592:	7446                	ld	s0,112(sp)
ffffffffc0205594:	74a6                	ld	s1,104(sp)
ffffffffc0205596:	7906                	ld	s2,96(sp)
ffffffffc0205598:	69e6                	ld	s3,88(sp)
ffffffffc020559a:	6a46                	ld	s4,80(sp)
ffffffffc020559c:	6aa6                	ld	s5,72(sp)
ffffffffc020559e:	6b06                	ld	s6,64(sp)
ffffffffc02055a0:	7be2                	ld	s7,56(sp)
ffffffffc02055a2:	7c42                	ld	s8,48(sp)
ffffffffc02055a4:	7ca2                	ld	s9,40(sp)
ffffffffc02055a6:	7d02                	ld	s10,32(sp)
ffffffffc02055a8:	6de2                	ld	s11,24(sp)
ffffffffc02055aa:	6109                	addi	sp,sp,128
ffffffffc02055ac:	8082                	ret
            putch('%', putdat);
ffffffffc02055ae:	85ca                	mv	a1,s2
ffffffffc02055b0:	02500513          	li	a0,37
ffffffffc02055b4:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02055b6:	fff44783          	lbu	a5,-1(s0)
ffffffffc02055ba:	02500713          	li	a4,37
ffffffffc02055be:	8c22                	mv	s8,s0
ffffffffc02055c0:	f8e785e3          	beq	a5,a4,ffffffffc020554a <vprintfmt+0x34>
ffffffffc02055c4:	ffec4783          	lbu	a5,-2(s8)
ffffffffc02055c8:	1c7d                	addi	s8,s8,-1
ffffffffc02055ca:	fee79de3          	bne	a5,a4,ffffffffc02055c4 <vprintfmt+0xae>
ffffffffc02055ce:	bfb5                	j	ffffffffc020554a <vprintfmt+0x34>
                ch = *fmt;
ffffffffc02055d0:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc02055d4:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
ffffffffc02055d6:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc02055da:	fd06071b          	addiw	a4,a2,-48
ffffffffc02055de:	24e56a63          	bltu	a0,a4,ffffffffc0205832 <vprintfmt+0x31c>
                ch = *fmt;
ffffffffc02055e2:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02055e4:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
ffffffffc02055e6:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
ffffffffc02055ea:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc02055ee:	0197073b          	addw	a4,a4,s9
ffffffffc02055f2:	0017171b          	slliw	a4,a4,0x1
ffffffffc02055f6:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
ffffffffc02055f8:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc02055fc:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc02055fe:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0205602:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
ffffffffc0205606:	feb570e3          	bgeu	a0,a1,ffffffffc02055e6 <vprintfmt+0xd0>
            if (width < 0)
ffffffffc020560a:	f60d54e3          	bgez	s10,ffffffffc0205572 <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc020560e:	8d66                	mv	s10,s9
ffffffffc0205610:	5cfd                	li	s9,-1
ffffffffc0205612:	b785                	j	ffffffffc0205572 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205614:	8db6                	mv	s11,a3
ffffffffc0205616:	8462                	mv	s0,s8
ffffffffc0205618:	bfa9                	j	ffffffffc0205572 <vprintfmt+0x5c>
ffffffffc020561a:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc020561c:	4b85                	li	s7,1
            goto reswitch;
ffffffffc020561e:	bf91                	j	ffffffffc0205572 <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc0205620:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205622:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205626:	00f74463          	blt	a4,a5,ffffffffc020562e <vprintfmt+0x118>
    else if (lflag) {
ffffffffc020562a:	1a078763          	beqz	a5,ffffffffc02057d8 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
ffffffffc020562e:	000a3603          	ld	a2,0(s4)
ffffffffc0205632:	46c1                	li	a3,16
ffffffffc0205634:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0205636:	000d879b          	sext.w	a5,s11
ffffffffc020563a:	876a                	mv	a4,s10
ffffffffc020563c:	85ca                	mv	a1,s2
ffffffffc020563e:	8526                	mv	a0,s1
ffffffffc0205640:	e71ff0ef          	jal	ffffffffc02054b0 <printnum>
            break;
ffffffffc0205644:	b719                	j	ffffffffc020554a <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc0205646:	000a2503          	lw	a0,0(s4)
ffffffffc020564a:	85ca                	mv	a1,s2
ffffffffc020564c:	0a21                	addi	s4,s4,8
ffffffffc020564e:	9482                	jalr	s1
            break;
ffffffffc0205650:	bded                	j	ffffffffc020554a <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0205652:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205654:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0205658:	00f74463          	blt	a4,a5,ffffffffc0205660 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc020565c:	16078963          	beqz	a5,ffffffffc02057ce <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
ffffffffc0205660:	000a3603          	ld	a2,0(s4)
ffffffffc0205664:	46a9                	li	a3,10
ffffffffc0205666:	8a2e                	mv	s4,a1
ffffffffc0205668:	b7f9                	j	ffffffffc0205636 <vprintfmt+0x120>
            putch('0', putdat);
ffffffffc020566a:	85ca                	mv	a1,s2
ffffffffc020566c:	03000513          	li	a0,48
ffffffffc0205670:	9482                	jalr	s1
            putch('x', putdat);
ffffffffc0205672:	85ca                	mv	a1,s2
ffffffffc0205674:	07800513          	li	a0,120
ffffffffc0205678:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020567a:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc020567e:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0205680:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0205682:	bf55                	j	ffffffffc0205636 <vprintfmt+0x120>
            putch(ch, putdat);
ffffffffc0205684:	85ca                	mv	a1,s2
ffffffffc0205686:	02500513          	li	a0,37
ffffffffc020568a:	9482                	jalr	s1
            break;
ffffffffc020568c:	bd7d                	j	ffffffffc020554a <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc020568e:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205692:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc0205694:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc0205696:	bf95                	j	ffffffffc020560a <vprintfmt+0xf4>
    if (lflag >= 2) {
ffffffffc0205698:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020569a:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020569e:	00f74463          	blt	a4,a5,ffffffffc02056a6 <vprintfmt+0x190>
    else if (lflag) {
ffffffffc02056a2:	12078163          	beqz	a5,ffffffffc02057c4 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
ffffffffc02056a6:	000a3603          	ld	a2,0(s4)
ffffffffc02056aa:	46a1                	li	a3,8
ffffffffc02056ac:	8a2e                	mv	s4,a1
ffffffffc02056ae:	b761                	j	ffffffffc0205636 <vprintfmt+0x120>
            if (width < 0)
ffffffffc02056b0:	876a                	mv	a4,s10
ffffffffc02056b2:	000d5363          	bgez	s10,ffffffffc02056b8 <vprintfmt+0x1a2>
ffffffffc02056b6:	4701                	li	a4,0
ffffffffc02056b8:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02056bc:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc02056be:	bd55                	j	ffffffffc0205572 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
ffffffffc02056c0:	000d841b          	sext.w	s0,s11
ffffffffc02056c4:	fd340793          	addi	a5,s0,-45
ffffffffc02056c8:	00f037b3          	snez	a5,a5
ffffffffc02056cc:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02056d0:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
ffffffffc02056d4:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02056d6:	008a0793          	addi	a5,s4,8
ffffffffc02056da:	e43e                	sd	a5,8(sp)
ffffffffc02056dc:	100d8c63          	beqz	s11,ffffffffc02057f4 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc02056e0:	12071363          	bnez	a4,ffffffffc0205806 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02056e4:	000dc783          	lbu	a5,0(s11)
ffffffffc02056e8:	0007851b          	sext.w	a0,a5
ffffffffc02056ec:	c78d                	beqz	a5,ffffffffc0205716 <vprintfmt+0x200>
ffffffffc02056ee:	0d85                	addi	s11,s11,1
ffffffffc02056f0:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc02056f2:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02056f6:	000cc563          	bltz	s9,ffffffffc0205700 <vprintfmt+0x1ea>
ffffffffc02056fa:	3cfd                	addiw	s9,s9,-1
ffffffffc02056fc:	008c8d63          	beq	s9,s0,ffffffffc0205716 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205700:	020b9663          	bnez	s7,ffffffffc020572c <vprintfmt+0x216>
                    putch(ch, putdat);
ffffffffc0205704:	85ca                	mv	a1,s2
ffffffffc0205706:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205708:	000dc783          	lbu	a5,0(s11)
ffffffffc020570c:	0d85                	addi	s11,s11,1
ffffffffc020570e:	3d7d                	addiw	s10,s10,-1
ffffffffc0205710:	0007851b          	sext.w	a0,a5
ffffffffc0205714:	f3ed                	bnez	a5,ffffffffc02056f6 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
ffffffffc0205716:	01a05963          	blez	s10,ffffffffc0205728 <vprintfmt+0x212>
                putch(' ', putdat);
ffffffffc020571a:	85ca                	mv	a1,s2
ffffffffc020571c:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc0205720:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
ffffffffc0205722:	9482                	jalr	s1
            for (; width > 0; width --) {
ffffffffc0205724:	fe0d1be3          	bnez	s10,ffffffffc020571a <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0205728:	6a22                	ld	s4,8(sp)
ffffffffc020572a:	b505                	j	ffffffffc020554a <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc020572c:	3781                	addiw	a5,a5,-32
ffffffffc020572e:	fcfa7be3          	bgeu	s4,a5,ffffffffc0205704 <vprintfmt+0x1ee>
                    putch('?', putdat);
ffffffffc0205732:	03f00513          	li	a0,63
ffffffffc0205736:	85ca                	mv	a1,s2
ffffffffc0205738:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020573a:	000dc783          	lbu	a5,0(s11)
ffffffffc020573e:	0d85                	addi	s11,s11,1
ffffffffc0205740:	3d7d                	addiw	s10,s10,-1
ffffffffc0205742:	0007851b          	sext.w	a0,a5
ffffffffc0205746:	dbe1                	beqz	a5,ffffffffc0205716 <vprintfmt+0x200>
ffffffffc0205748:	fa0cd9e3          	bgez	s9,ffffffffc02056fa <vprintfmt+0x1e4>
ffffffffc020574c:	b7c5                	j	ffffffffc020572c <vprintfmt+0x216>
            if (err < 0) {
ffffffffc020574e:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205752:	4661                	li	a2,24
            err = va_arg(ap, int);
ffffffffc0205754:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0205756:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc020575a:	8fb9                	xor	a5,a5,a4
ffffffffc020575c:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205760:	02d64563          	blt	a2,a3,ffffffffc020578a <vprintfmt+0x274>
ffffffffc0205764:	00003797          	auipc	a5,0x3
ffffffffc0205768:	a8c78793          	addi	a5,a5,-1396 # ffffffffc02081f0 <error_string>
ffffffffc020576c:	00369713          	slli	a4,a3,0x3
ffffffffc0205770:	97ba                	add	a5,a5,a4
ffffffffc0205772:	639c                	ld	a5,0(a5)
ffffffffc0205774:	cb99                	beqz	a5,ffffffffc020578a <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
ffffffffc0205776:	86be                	mv	a3,a5
ffffffffc0205778:	00000617          	auipc	a2,0x0
ffffffffc020577c:	21060613          	addi	a2,a2,528 # ffffffffc0205988 <etext+0x2e>
ffffffffc0205780:	85ca                	mv	a1,s2
ffffffffc0205782:	8526                	mv	a0,s1
ffffffffc0205784:	0d8000ef          	jal	ffffffffc020585c <printfmt>
ffffffffc0205788:	b3c9                	j	ffffffffc020554a <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc020578a:	00002617          	auipc	a2,0x2
ffffffffc020578e:	f4e60613          	addi	a2,a2,-178 # ffffffffc02076d8 <etext+0x1d7e>
ffffffffc0205792:	85ca                	mv	a1,s2
ffffffffc0205794:	8526                	mv	a0,s1
ffffffffc0205796:	0c6000ef          	jal	ffffffffc020585c <printfmt>
ffffffffc020579a:	bb45                	j	ffffffffc020554a <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc020579c:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc020579e:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc02057a2:	00f74363          	blt	a4,a5,ffffffffc02057a8 <vprintfmt+0x292>
    else if (lflag) {
ffffffffc02057a6:	cf81                	beqz	a5,ffffffffc02057be <vprintfmt+0x2a8>
        return va_arg(*ap, long);
ffffffffc02057a8:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02057ac:	02044b63          	bltz	s0,ffffffffc02057e2 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc02057b0:	8622                	mv	a2,s0
ffffffffc02057b2:	8a5e                	mv	s4,s7
ffffffffc02057b4:	46a9                	li	a3,10
ffffffffc02057b6:	b541                	j	ffffffffc0205636 <vprintfmt+0x120>
            lflag ++;
ffffffffc02057b8:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02057ba:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc02057bc:	bb5d                	j	ffffffffc0205572 <vprintfmt+0x5c>
        return va_arg(*ap, int);
ffffffffc02057be:	000a2403          	lw	s0,0(s4)
ffffffffc02057c2:	b7ed                	j	ffffffffc02057ac <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
ffffffffc02057c4:	000a6603          	lwu	a2,0(s4)
ffffffffc02057c8:	46a1                	li	a3,8
ffffffffc02057ca:	8a2e                	mv	s4,a1
ffffffffc02057cc:	b5ad                	j	ffffffffc0205636 <vprintfmt+0x120>
ffffffffc02057ce:	000a6603          	lwu	a2,0(s4)
ffffffffc02057d2:	46a9                	li	a3,10
ffffffffc02057d4:	8a2e                	mv	s4,a1
ffffffffc02057d6:	b585                	j	ffffffffc0205636 <vprintfmt+0x120>
ffffffffc02057d8:	000a6603          	lwu	a2,0(s4)
ffffffffc02057dc:	46c1                	li	a3,16
ffffffffc02057de:	8a2e                	mv	s4,a1
ffffffffc02057e0:	bd99                	j	ffffffffc0205636 <vprintfmt+0x120>
                putch('-', putdat);
ffffffffc02057e2:	85ca                	mv	a1,s2
ffffffffc02057e4:	02d00513          	li	a0,45
ffffffffc02057e8:	9482                	jalr	s1
                num = -(long long)num;
ffffffffc02057ea:	40800633          	neg	a2,s0
ffffffffc02057ee:	8a5e                	mv	s4,s7
ffffffffc02057f0:	46a9                	li	a3,10
ffffffffc02057f2:	b591                	j	ffffffffc0205636 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
ffffffffc02057f4:	e329                	bnez	a4,ffffffffc0205836 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc02057f6:	02800793          	li	a5,40
ffffffffc02057fa:	853e                	mv	a0,a5
ffffffffc02057fc:	00002d97          	auipc	s11,0x2
ffffffffc0205800:	ed5d8d93          	addi	s11,s11,-299 # ffffffffc02076d1 <etext+0x1d77>
ffffffffc0205804:	b5f5                	j	ffffffffc02056f0 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205806:	85e6                	mv	a1,s9
ffffffffc0205808:	856e                	mv	a0,s11
ffffffffc020580a:	08a000ef          	jal	ffffffffc0205894 <strnlen>
ffffffffc020580e:	40ad0d3b          	subw	s10,s10,a0
ffffffffc0205812:	01a05863          	blez	s10,ffffffffc0205822 <vprintfmt+0x30c>
                    putch(padc, putdat);
ffffffffc0205816:	85ca                	mv	a1,s2
ffffffffc0205818:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020581a:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
ffffffffc020581c:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020581e:	fe0d1ce3          	bnez	s10,ffffffffc0205816 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205822:	000dc783          	lbu	a5,0(s11)
ffffffffc0205826:	0007851b          	sext.w	a0,a5
ffffffffc020582a:	ec0792e3          	bnez	a5,ffffffffc02056ee <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020582e:	6a22                	ld	s4,8(sp)
ffffffffc0205830:	bb29                	j	ffffffffc020554a <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205832:	8462                	mv	s0,s8
ffffffffc0205834:	bbd9                	j	ffffffffc020560a <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205836:	85e6                	mv	a1,s9
ffffffffc0205838:	00002517          	auipc	a0,0x2
ffffffffc020583c:	e9850513          	addi	a0,a0,-360 # ffffffffc02076d0 <etext+0x1d76>
ffffffffc0205840:	054000ef          	jal	ffffffffc0205894 <strnlen>
ffffffffc0205844:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205848:	02800793          	li	a5,40
                p = "(null)";
ffffffffc020584c:	00002d97          	auipc	s11,0x2
ffffffffc0205850:	e84d8d93          	addi	s11,s11,-380 # ffffffffc02076d0 <etext+0x1d76>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205854:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205856:	fda040e3          	bgtz	s10,ffffffffc0205816 <vprintfmt+0x300>
ffffffffc020585a:	bd51                	j	ffffffffc02056ee <vprintfmt+0x1d8>

ffffffffc020585c <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020585c:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc020585e:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205862:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205864:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205866:	ec06                	sd	ra,24(sp)
ffffffffc0205868:	f83a                	sd	a4,48(sp)
ffffffffc020586a:	fc3e                	sd	a5,56(sp)
ffffffffc020586c:	e0c2                	sd	a6,64(sp)
ffffffffc020586e:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0205870:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205872:	ca5ff0ef          	jal	ffffffffc0205516 <vprintfmt>
}
ffffffffc0205876:	60e2                	ld	ra,24(sp)
ffffffffc0205878:	6161                	addi	sp,sp,80
ffffffffc020587a:	8082                	ret

ffffffffc020587c <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc020587c:	00054783          	lbu	a5,0(a0)
ffffffffc0205880:	cb81                	beqz	a5,ffffffffc0205890 <strlen+0x14>
    size_t cnt = 0;
ffffffffc0205882:	4781                	li	a5,0
        cnt ++;
ffffffffc0205884:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0205886:	00f50733          	add	a4,a0,a5
ffffffffc020588a:	00074703          	lbu	a4,0(a4)
ffffffffc020588e:	fb7d                	bnez	a4,ffffffffc0205884 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0205890:	853e                	mv	a0,a5
ffffffffc0205892:	8082                	ret

ffffffffc0205894 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0205894:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0205896:	e589                	bnez	a1,ffffffffc02058a0 <strnlen+0xc>
ffffffffc0205898:	a811                	j	ffffffffc02058ac <strnlen+0x18>
        cnt ++;
ffffffffc020589a:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc020589c:	00f58863          	beq	a1,a5,ffffffffc02058ac <strnlen+0x18>
ffffffffc02058a0:	00f50733          	add	a4,a0,a5
ffffffffc02058a4:	00074703          	lbu	a4,0(a4)
ffffffffc02058a8:	fb6d                	bnez	a4,ffffffffc020589a <strnlen+0x6>
ffffffffc02058aa:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02058ac:	852e                	mv	a0,a1
ffffffffc02058ae:	8082                	ret

ffffffffc02058b0 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02058b0:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02058b2:	0005c703          	lbu	a4,0(a1)
ffffffffc02058b6:	0585                	addi	a1,a1,1
ffffffffc02058b8:	0785                	addi	a5,a5,1
ffffffffc02058ba:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02058be:	fb75                	bnez	a4,ffffffffc02058b2 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02058c0:	8082                	ret

ffffffffc02058c2 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02058c2:	00054783          	lbu	a5,0(a0)
ffffffffc02058c6:	e791                	bnez	a5,ffffffffc02058d2 <strcmp+0x10>
ffffffffc02058c8:	a01d                	j	ffffffffc02058ee <strcmp+0x2c>
ffffffffc02058ca:	00054783          	lbu	a5,0(a0)
ffffffffc02058ce:	cb99                	beqz	a5,ffffffffc02058e4 <strcmp+0x22>
ffffffffc02058d0:	0585                	addi	a1,a1,1
ffffffffc02058d2:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc02058d6:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02058d8:	fef709e3          	beq	a4,a5,ffffffffc02058ca <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02058dc:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc02058e0:	9d19                	subw	a0,a0,a4
ffffffffc02058e2:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02058e4:	0015c703          	lbu	a4,1(a1)
ffffffffc02058e8:	4501                	li	a0,0
}
ffffffffc02058ea:	9d19                	subw	a0,a0,a4
ffffffffc02058ec:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc02058ee:	0005c703          	lbu	a4,0(a1)
ffffffffc02058f2:	4501                	li	a0,0
ffffffffc02058f4:	b7f5                	j	ffffffffc02058e0 <strcmp+0x1e>

ffffffffc02058f6 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02058f6:	ce01                	beqz	a2,ffffffffc020590e <strncmp+0x18>
ffffffffc02058f8:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc02058fc:	167d                	addi	a2,a2,-1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc02058fe:	cb91                	beqz	a5,ffffffffc0205912 <strncmp+0x1c>
ffffffffc0205900:	0005c703          	lbu	a4,0(a1)
ffffffffc0205904:	00f71763          	bne	a4,a5,ffffffffc0205912 <strncmp+0x1c>
        n --, s1 ++, s2 ++;
ffffffffc0205908:	0505                	addi	a0,a0,1
ffffffffc020590a:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020590c:	f675                	bnez	a2,ffffffffc02058f8 <strncmp+0x2>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020590e:	4501                	li	a0,0
ffffffffc0205910:	8082                	ret
ffffffffc0205912:	00054503          	lbu	a0,0(a0)
ffffffffc0205916:	0005c783          	lbu	a5,0(a1)
ffffffffc020591a:	9d1d                	subw	a0,a0,a5
}
ffffffffc020591c:	8082                	ret

ffffffffc020591e <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc020591e:	a021                	j	ffffffffc0205926 <strchr+0x8>
        if (*s == c) {
ffffffffc0205920:	00f58763          	beq	a1,a5,ffffffffc020592e <strchr+0x10>
            return (char *)s;
        }
        s ++;
ffffffffc0205924:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0205926:	00054783          	lbu	a5,0(a0)
ffffffffc020592a:	fbfd                	bnez	a5,ffffffffc0205920 <strchr+0x2>
    }
    return NULL;
ffffffffc020592c:	4501                	li	a0,0
}
ffffffffc020592e:	8082                	ret

ffffffffc0205930 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0205930:	ca01                	beqz	a2,ffffffffc0205940 <memset+0x10>
ffffffffc0205932:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0205934:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0205936:	0785                	addi	a5,a5,1
ffffffffc0205938:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc020593c:	fef61de3          	bne	a2,a5,ffffffffc0205936 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0205940:	8082                	ret

ffffffffc0205942 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0205942:	ca19                	beqz	a2,ffffffffc0205958 <memcpy+0x16>
ffffffffc0205944:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc0205946:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc0205948:	0005c703          	lbu	a4,0(a1)
ffffffffc020594c:	0585                	addi	a1,a1,1
ffffffffc020594e:	0785                	addi	a5,a5,1
ffffffffc0205950:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0205954:	feb61ae3          	bne	a2,a1,ffffffffc0205948 <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc0205958:	8082                	ret
