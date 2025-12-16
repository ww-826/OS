
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	0000b297          	auipc	t0,0xb
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc020b000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	0000b297          	auipc	t0,0xb
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc020b008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c020a2b7          	lui	t0,0xc020a
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
ffffffffc020003c:	c020a137          	lui	sp,0xc020a

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
ffffffffc020004a:	00097517          	auipc	a0,0x97
ffffffffc020004e:	2c650513          	addi	a0,a0,710 # ffffffffc0297310 <buf>
ffffffffc0200052:	0009b617          	auipc	a2,0x9b
ffffffffc0200056:	76660613          	addi	a2,a2,1894 # ffffffffc029b7b8 <end>
{
ffffffffc020005a:	1141                	addi	sp,sp,-16 # ffffffffc0209ff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
{
ffffffffc0200060:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc0200062:	0f3050ef          	jal	ffffffffc0205954 <memset>
    dtb_init();
ffffffffc0200066:	552000ef          	jal	ffffffffc02005b8 <dtb_init>
    cons_init(); // init the console
ffffffffc020006a:	4dc000ef          	jal	ffffffffc0200546 <cons_init>

    const char *message = "(THU.CST) os is loading ...";
    cprintf("%s\n\n", message);
ffffffffc020006e:	00006597          	auipc	a1,0x6
ffffffffc0200072:	91258593          	addi	a1,a1,-1774 # ffffffffc0205980 <etext+0x2>
ffffffffc0200076:	00006517          	auipc	a0,0x6
ffffffffc020007a:	92a50513          	addi	a0,a0,-1750 # ffffffffc02059a0 <etext+0x22>
ffffffffc020007e:	116000ef          	jal	ffffffffc0200194 <cprintf>

    print_kerninfo();
ffffffffc0200082:	1a4000ef          	jal	ffffffffc0200226 <print_kerninfo>

    // grade_backtrace();

    pmm_init(); // init physical memory management
ffffffffc0200086:	7c2020ef          	jal	ffffffffc0202848 <pmm_init>

    pic_init(); // init interrupt controller
ffffffffc020008a:	081000ef          	jal	ffffffffc020090a <pic_init>
    idt_init(); // init interrupt descriptor table
ffffffffc020008e:	07f000ef          	jal	ffffffffc020090c <idt_init>

    vmm_init();  // init virtual memory management
ffffffffc0200092:	2af030ef          	jal	ffffffffc0203b40 <vmm_init>
    proc_init(); // init process table
ffffffffc0200096:	008050ef          	jal	ffffffffc020509e <proc_init>

    clock_init();  // init clock interrupt
ffffffffc020009a:	45a000ef          	jal	ffffffffc02004f4 <clock_init>
    intr_enable(); // enable irq interrupt
ffffffffc020009e:	061000ef          	jal	ffffffffc02008fe <intr_enable>

    cpu_idle(); // run idle process
ffffffffc02000a2:	19c050ef          	jal	ffffffffc020523e <cpu_idle>

ffffffffc02000a6 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc02000a6:	7179                	addi	sp,sp,-48
ffffffffc02000a8:	f406                	sd	ra,40(sp)
ffffffffc02000aa:	f022                	sd	s0,32(sp)
ffffffffc02000ac:	ec26                	sd	s1,24(sp)
ffffffffc02000ae:	e84a                	sd	s2,16(sp)
ffffffffc02000b0:	e44e                	sd	s3,8(sp)
    if (prompt != NULL) {
ffffffffc02000b2:	c901                	beqz	a0,ffffffffc02000c2 <readline+0x1c>
        cprintf("%s", prompt);
ffffffffc02000b4:	85aa                	mv	a1,a0
ffffffffc02000b6:	00006517          	auipc	a0,0x6
ffffffffc02000ba:	8f250513          	addi	a0,a0,-1806 # ffffffffc02059a8 <etext+0x2a>
ffffffffc02000be:	0d6000ef          	jal	ffffffffc0200194 <cprintf>
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
            cputchar(c);
            buf[i ++] = c;
ffffffffc02000c2:	4481                	li	s1,0
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000c4:	497d                	li	s2,31
            buf[i ++] = c;
ffffffffc02000c6:	00097997          	auipc	s3,0x97
ffffffffc02000ca:	24a98993          	addi	s3,s3,586 # ffffffffc0297310 <buf>
        c = getchar();
ffffffffc02000ce:	148000ef          	jal	ffffffffc0200216 <getchar>
ffffffffc02000d2:	842a                	mv	s0,a0
        }
        else if (c == '\b' && i > 0) {
ffffffffc02000d4:	ff850793          	addi	a5,a0,-8
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000d8:	3ff4a713          	slti	a4,s1,1023
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc02000dc:	ff650693          	addi	a3,a0,-10
ffffffffc02000e0:	ff350613          	addi	a2,a0,-13
        if (c < 0) {
ffffffffc02000e4:	02054963          	bltz	a0,ffffffffc0200116 <readline+0x70>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc02000e8:	02a95f63          	bge	s2,a0,ffffffffc0200126 <readline+0x80>
ffffffffc02000ec:	cf0d                	beqz	a4,ffffffffc0200126 <readline+0x80>
            cputchar(c);
ffffffffc02000ee:	0da000ef          	jal	ffffffffc02001c8 <cputchar>
            buf[i ++] = c;
ffffffffc02000f2:	009987b3          	add	a5,s3,s1
ffffffffc02000f6:	00878023          	sb	s0,0(a5)
ffffffffc02000fa:	2485                	addiw	s1,s1,1
        c = getchar();
ffffffffc02000fc:	11a000ef          	jal	ffffffffc0200216 <getchar>
ffffffffc0200100:	842a                	mv	s0,a0
        else if (c == '\b' && i > 0) {
ffffffffc0200102:	ff850793          	addi	a5,a0,-8
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0200106:	3ff4a713          	slti	a4,s1,1023
        else if (c == '\n' || c == '\r') {
ffffffffc020010a:	ff650693          	addi	a3,a0,-10
ffffffffc020010e:	ff350613          	addi	a2,a0,-13
        if (c < 0) {
ffffffffc0200112:	fc055be3          	bgez	a0,ffffffffc02000e8 <readline+0x42>
            cputchar(c);
            buf[i] = '\0';
            return buf;
        }
    }
}
ffffffffc0200116:	70a2                	ld	ra,40(sp)
ffffffffc0200118:	7402                	ld	s0,32(sp)
ffffffffc020011a:	64e2                	ld	s1,24(sp)
ffffffffc020011c:	6942                	ld	s2,16(sp)
ffffffffc020011e:	69a2                	ld	s3,8(sp)
            return NULL;
ffffffffc0200120:	4501                	li	a0,0
}
ffffffffc0200122:	6145                	addi	sp,sp,48
ffffffffc0200124:	8082                	ret
        else if (c == '\b' && i > 0) {
ffffffffc0200126:	eb81                	bnez	a5,ffffffffc0200136 <readline+0x90>
            cputchar(c);
ffffffffc0200128:	4521                	li	a0,8
        else if (c == '\b' && i > 0) {
ffffffffc020012a:	00905663          	blez	s1,ffffffffc0200136 <readline+0x90>
            cputchar(c);
ffffffffc020012e:	09a000ef          	jal	ffffffffc02001c8 <cputchar>
            i --;
ffffffffc0200132:	34fd                	addiw	s1,s1,-1
ffffffffc0200134:	bf69                	j	ffffffffc02000ce <readline+0x28>
        else if (c == '\n' || c == '\r') {
ffffffffc0200136:	c291                	beqz	a3,ffffffffc020013a <readline+0x94>
ffffffffc0200138:	fa59                	bnez	a2,ffffffffc02000ce <readline+0x28>
            cputchar(c);
ffffffffc020013a:	8522                	mv	a0,s0
ffffffffc020013c:	08c000ef          	jal	ffffffffc02001c8 <cputchar>
            buf[i] = '\0';
ffffffffc0200140:	00097517          	auipc	a0,0x97
ffffffffc0200144:	1d050513          	addi	a0,a0,464 # ffffffffc0297310 <buf>
ffffffffc0200148:	94aa                	add	s1,s1,a0
ffffffffc020014a:	00048023          	sb	zero,0(s1)
}
ffffffffc020014e:	70a2                	ld	ra,40(sp)
ffffffffc0200150:	7402                	ld	s0,32(sp)
ffffffffc0200152:	64e2                	ld	s1,24(sp)
ffffffffc0200154:	6942                	ld	s2,16(sp)
ffffffffc0200156:	69a2                	ld	s3,8(sp)
ffffffffc0200158:	6145                	addi	sp,sp,48
ffffffffc020015a:	8082                	ret

ffffffffc020015c <cputch>:
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt)
{
ffffffffc020015c:	1101                	addi	sp,sp,-32
ffffffffc020015e:	ec06                	sd	ra,24(sp)
ffffffffc0200160:	e42e                	sd	a1,8(sp)
    cons_putc(c);
ffffffffc0200162:	3e6000ef          	jal	ffffffffc0200548 <cons_putc>
    (*cnt)++;
ffffffffc0200166:	65a2                	ld	a1,8(sp)
}
ffffffffc0200168:	60e2                	ld	ra,24(sp)
    (*cnt)++;
ffffffffc020016a:	419c                	lw	a5,0(a1)
ffffffffc020016c:	2785                	addiw	a5,a5,1
ffffffffc020016e:	c19c                	sw	a5,0(a1)
}
ffffffffc0200170:	6105                	addi	sp,sp,32
ffffffffc0200172:	8082                	ret

ffffffffc0200174 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int vcprintf(const char *fmt, va_list ap)
{
ffffffffc0200174:	1101                	addi	sp,sp,-32
ffffffffc0200176:	862a                	mv	a2,a0
ffffffffc0200178:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc020017a:	00000517          	auipc	a0,0x0
ffffffffc020017e:	fe250513          	addi	a0,a0,-30 # ffffffffc020015c <cputch>
ffffffffc0200182:	006c                	addi	a1,sp,12
{
ffffffffc0200184:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc0200186:	c602                	sw	zero,12(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc0200188:	3b2050ef          	jal	ffffffffc020553a <vprintfmt>
    return cnt;
}
ffffffffc020018c:	60e2                	ld	ra,24(sp)
ffffffffc020018e:	4532                	lw	a0,12(sp)
ffffffffc0200190:	6105                	addi	sp,sp,32
ffffffffc0200192:	8082                	ret

ffffffffc0200194 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int cprintf(const char *fmt, ...)
{
ffffffffc0200194:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc0200196:	02810313          	addi	t1,sp,40
{
ffffffffc020019a:	f42e                	sd	a1,40(sp)
ffffffffc020019c:	f832                	sd	a2,48(sp)
ffffffffc020019e:	fc36                	sd	a3,56(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02001a0:	862a                	mv	a2,a0
ffffffffc02001a2:	004c                	addi	a1,sp,4
ffffffffc02001a4:	00000517          	auipc	a0,0x0
ffffffffc02001a8:	fb850513          	addi	a0,a0,-72 # ffffffffc020015c <cputch>
ffffffffc02001ac:	869a                	mv	a3,t1
{
ffffffffc02001ae:	ec06                	sd	ra,24(sp)
ffffffffc02001b0:	e0ba                	sd	a4,64(sp)
ffffffffc02001b2:	e4be                	sd	a5,72(sp)
ffffffffc02001b4:	e8c2                	sd	a6,80(sp)
ffffffffc02001b6:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
ffffffffc02001b8:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
ffffffffc02001ba:	e41a                	sd	t1,8(sp)
    vprintfmt((void *)cputch, &cnt, fmt, ap);
ffffffffc02001bc:	37e050ef          	jal	ffffffffc020553a <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc02001c0:	60e2                	ld	ra,24(sp)
ffffffffc02001c2:	4512                	lw	a0,4(sp)
ffffffffc02001c4:	6125                	addi	sp,sp,96
ffffffffc02001c6:	8082                	ret

ffffffffc02001c8 <cputchar>:

/* cputchar - writes a single character to stdout */
void cputchar(int c)
{
    cons_putc(c);
ffffffffc02001c8:	a641                	j	ffffffffc0200548 <cons_putc>

ffffffffc02001ca <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int cputs(const char *str)
{
ffffffffc02001ca:	1101                	addi	sp,sp,-32
ffffffffc02001cc:	e822                	sd	s0,16(sp)
ffffffffc02001ce:	ec06                	sd	ra,24(sp)
ffffffffc02001d0:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str++) != '\0')
ffffffffc02001d2:	00054503          	lbu	a0,0(a0)
ffffffffc02001d6:	c51d                	beqz	a0,ffffffffc0200204 <cputs+0x3a>
ffffffffc02001d8:	e426                	sd	s1,8(sp)
ffffffffc02001da:	0405                	addi	s0,s0,1
    int cnt = 0;
ffffffffc02001dc:	4481                	li	s1,0
    cons_putc(c);
ffffffffc02001de:	36a000ef          	jal	ffffffffc0200548 <cons_putc>
    while ((c = *str++) != '\0')
ffffffffc02001e2:	00044503          	lbu	a0,0(s0)
ffffffffc02001e6:	0405                	addi	s0,s0,1
ffffffffc02001e8:	87a6                	mv	a5,s1
    (*cnt)++;
ffffffffc02001ea:	2485                	addiw	s1,s1,1
    while ((c = *str++) != '\0')
ffffffffc02001ec:	f96d                	bnez	a0,ffffffffc02001de <cputs+0x14>
    cons_putc(c);
ffffffffc02001ee:	4529                	li	a0,10
    (*cnt)++;
ffffffffc02001f0:	0027841b          	addiw	s0,a5,2
ffffffffc02001f4:	64a2                	ld	s1,8(sp)
    cons_putc(c);
ffffffffc02001f6:	352000ef          	jal	ffffffffc0200548 <cons_putc>
    {
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001fa:	60e2                	ld	ra,24(sp)
ffffffffc02001fc:	8522                	mv	a0,s0
ffffffffc02001fe:	6442                	ld	s0,16(sp)
ffffffffc0200200:	6105                	addi	sp,sp,32
ffffffffc0200202:	8082                	ret
    cons_putc(c);
ffffffffc0200204:	4529                	li	a0,10
ffffffffc0200206:	342000ef          	jal	ffffffffc0200548 <cons_putc>
    while ((c = *str++) != '\0')
ffffffffc020020a:	4405                	li	s0,1
}
ffffffffc020020c:	60e2                	ld	ra,24(sp)
ffffffffc020020e:	8522                	mv	a0,s0
ffffffffc0200210:	6442                	ld	s0,16(sp)
ffffffffc0200212:	6105                	addi	sp,sp,32
ffffffffc0200214:	8082                	ret

ffffffffc0200216 <getchar>:

/* getchar - reads a single non-zero character from stdin */
int getchar(void)
{
ffffffffc0200216:	1141                	addi	sp,sp,-16
ffffffffc0200218:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc020021a:	362000ef          	jal	ffffffffc020057c <cons_getc>
ffffffffc020021e:	dd75                	beqz	a0,ffffffffc020021a <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200220:	60a2                	ld	ra,8(sp)
ffffffffc0200222:	0141                	addi	sp,sp,16
ffffffffc0200224:	8082                	ret

ffffffffc0200226 <print_kerninfo>:
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void)
{
ffffffffc0200226:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc0200228:	00005517          	auipc	a0,0x5
ffffffffc020022c:	78850513          	addi	a0,a0,1928 # ffffffffc02059b0 <etext+0x32>
{
ffffffffc0200230:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200232:	f63ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  entry  0x%08x (virtual)\n", kern_init);
ffffffffc0200236:	00000597          	auipc	a1,0x0
ffffffffc020023a:	e1458593          	addi	a1,a1,-492 # ffffffffc020004a <kern_init>
ffffffffc020023e:	00005517          	auipc	a0,0x5
ffffffffc0200242:	79250513          	addi	a0,a0,1938 # ffffffffc02059d0 <etext+0x52>
ffffffffc0200246:	f4fff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  etext  0x%08x (virtual)\n", etext);
ffffffffc020024a:	00005597          	auipc	a1,0x5
ffffffffc020024e:	73458593          	addi	a1,a1,1844 # ffffffffc020597e <etext>
ffffffffc0200252:	00005517          	auipc	a0,0x5
ffffffffc0200256:	79e50513          	addi	a0,a0,1950 # ffffffffc02059f0 <etext+0x72>
ffffffffc020025a:	f3bff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  edata  0x%08x (virtual)\n", edata);
ffffffffc020025e:	00097597          	auipc	a1,0x97
ffffffffc0200262:	0b258593          	addi	a1,a1,178 # ffffffffc0297310 <buf>
ffffffffc0200266:	00005517          	auipc	a0,0x5
ffffffffc020026a:	7aa50513          	addi	a0,a0,1962 # ffffffffc0205a10 <etext+0x92>
ffffffffc020026e:	f27ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  end    0x%08x (virtual)\n", end);
ffffffffc0200272:	0009b597          	auipc	a1,0x9b
ffffffffc0200276:	54658593          	addi	a1,a1,1350 # ffffffffc029b7b8 <end>
ffffffffc020027a:	00005517          	auipc	a0,0x5
ffffffffc020027e:	7b650513          	addi	a0,a0,1974 # ffffffffc0205a30 <etext+0xb2>
ffffffffc0200282:	f13ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc0200286:	00000717          	auipc	a4,0x0
ffffffffc020028a:	dc470713          	addi	a4,a4,-572 # ffffffffc020004a <kern_init>
ffffffffc020028e:	0009c797          	auipc	a5,0x9c
ffffffffc0200292:	92978793          	addi	a5,a5,-1751 # ffffffffc029bbb7 <end+0x3ff>
ffffffffc0200296:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200298:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc020029c:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc020029e:	3ff5f593          	andi	a1,a1,1023
ffffffffc02002a2:	95be                	add	a1,a1,a5
ffffffffc02002a4:	85a9                	srai	a1,a1,0xa
ffffffffc02002a6:	00005517          	auipc	a0,0x5
ffffffffc02002aa:	7aa50513          	addi	a0,a0,1962 # ffffffffc0205a50 <etext+0xd2>
}
ffffffffc02002ae:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02002b0:	b5d5                	j	ffffffffc0200194 <cprintf>

ffffffffc02002b2 <print_stackframe>:
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void)
{
ffffffffc02002b2:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc02002b4:	00005617          	auipc	a2,0x5
ffffffffc02002b8:	7cc60613          	addi	a2,a2,1996 # ffffffffc0205a80 <etext+0x102>
ffffffffc02002bc:	04f00593          	li	a1,79
ffffffffc02002c0:	00005517          	auipc	a0,0x5
ffffffffc02002c4:	7d850513          	addi	a0,a0,2008 # ffffffffc0205a98 <etext+0x11a>
{
ffffffffc02002c8:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc02002ca:	17c000ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02002ce <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int mon_help(int argc, char **argv, struct trapframe *tf)
{
ffffffffc02002ce:	1101                	addi	sp,sp,-32
ffffffffc02002d0:	e822                	sd	s0,16(sp)
ffffffffc02002d2:	e426                	sd	s1,8(sp)
ffffffffc02002d4:	ec06                	sd	ra,24(sp)
ffffffffc02002d6:	00007417          	auipc	s0,0x7
ffffffffc02002da:	47240413          	addi	s0,s0,1138 # ffffffffc0207748 <commands>
ffffffffc02002de:	00007497          	auipc	s1,0x7
ffffffffc02002e2:	4b248493          	addi	s1,s1,1202 # ffffffffc0207790 <commands+0x48>
    int i;
    for (i = 0; i < NCOMMANDS; i++)
    {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002e6:	6410                	ld	a2,8(s0)
ffffffffc02002e8:	600c                	ld	a1,0(s0)
ffffffffc02002ea:	00005517          	auipc	a0,0x5
ffffffffc02002ee:	7c650513          	addi	a0,a0,1990 # ffffffffc0205ab0 <etext+0x132>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc02002f2:	0461                	addi	s0,s0,24
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc02002f4:	ea1ff0ef          	jal	ffffffffc0200194 <cprintf>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc02002f8:	fe9417e3          	bne	s0,s1,ffffffffc02002e6 <mon_help+0x18>
    }
    return 0;
}
ffffffffc02002fc:	60e2                	ld	ra,24(sp)
ffffffffc02002fe:	6442                	ld	s0,16(sp)
ffffffffc0200300:	64a2                	ld	s1,8(sp)
ffffffffc0200302:	4501                	li	a0,0
ffffffffc0200304:	6105                	addi	sp,sp,32
ffffffffc0200306:	8082                	ret

ffffffffc0200308 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int mon_kerninfo(int argc, char **argv, struct trapframe *tf)
{
ffffffffc0200308:	1141                	addi	sp,sp,-16
ffffffffc020030a:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc020030c:	f1bff0ef          	jal	ffffffffc0200226 <print_kerninfo>
    return 0;
}
ffffffffc0200310:	60a2                	ld	ra,8(sp)
ffffffffc0200312:	4501                	li	a0,0
ffffffffc0200314:	0141                	addi	sp,sp,16
ffffffffc0200316:	8082                	ret

ffffffffc0200318 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int mon_backtrace(int argc, char **argv, struct trapframe *tf)
{
ffffffffc0200318:	1141                	addi	sp,sp,-16
ffffffffc020031a:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc020031c:	f97ff0ef          	jal	ffffffffc02002b2 <print_stackframe>
    return 0;
}
ffffffffc0200320:	60a2                	ld	ra,8(sp)
ffffffffc0200322:	4501                	li	a0,0
ffffffffc0200324:	0141                	addi	sp,sp,16
ffffffffc0200326:	8082                	ret

ffffffffc0200328 <kmonitor>:
{
ffffffffc0200328:	7131                	addi	sp,sp,-192
ffffffffc020032a:	e952                	sd	s4,144(sp)
ffffffffc020032c:	8a2a                	mv	s4,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc020032e:	00005517          	auipc	a0,0x5
ffffffffc0200332:	79250513          	addi	a0,a0,1938 # ffffffffc0205ac0 <etext+0x142>
{
ffffffffc0200336:	fd06                	sd	ra,184(sp)
ffffffffc0200338:	f922                	sd	s0,176(sp)
ffffffffc020033a:	f526                	sd	s1,168(sp)
ffffffffc020033c:	ed4e                	sd	s3,152(sp)
ffffffffc020033e:	e556                	sd	s5,136(sp)
ffffffffc0200340:	e15a                	sd	s6,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc0200342:	e53ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc0200346:	00005517          	auipc	a0,0x5
ffffffffc020034a:	7a250513          	addi	a0,a0,1954 # ffffffffc0205ae8 <etext+0x16a>
ffffffffc020034e:	e47ff0ef          	jal	ffffffffc0200194 <cprintf>
    if (tf != NULL)
ffffffffc0200352:	000a0563          	beqz	s4,ffffffffc020035c <kmonitor+0x34>
        print_trapframe(tf);
ffffffffc0200356:	8552                	mv	a0,s4
ffffffffc0200358:	79c000ef          	jal	ffffffffc0200af4 <print_trapframe>
ffffffffc020035c:	00007a97          	auipc	s5,0x7
ffffffffc0200360:	3eca8a93          	addi	s5,s5,1004 # ffffffffc0207748 <commands>
        if (argc == MAXARGS - 1)
ffffffffc0200364:	49bd                	li	s3,15
        if ((buf = readline("K> ")) != NULL)
ffffffffc0200366:	00005517          	auipc	a0,0x5
ffffffffc020036a:	7aa50513          	addi	a0,a0,1962 # ffffffffc0205b10 <etext+0x192>
ffffffffc020036e:	d39ff0ef          	jal	ffffffffc02000a6 <readline>
ffffffffc0200372:	842a                	mv	s0,a0
ffffffffc0200374:	d96d                	beqz	a0,ffffffffc0200366 <kmonitor+0x3e>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200376:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc020037a:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc020037c:	e99d                	bnez	a1,ffffffffc02003b2 <kmonitor+0x8a>
    int argc = 0;
ffffffffc020037e:	8b26                	mv	s6,s1
    if (argc == 0)
ffffffffc0200380:	fe0b03e3          	beqz	s6,ffffffffc0200366 <kmonitor+0x3e>
ffffffffc0200384:	00007497          	auipc	s1,0x7
ffffffffc0200388:	3c448493          	addi	s1,s1,964 # ffffffffc0207748 <commands>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc020038c:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc020038e:	6582                	ld	a1,0(sp)
ffffffffc0200390:	6088                	ld	a0,0(s1)
ffffffffc0200392:	554050ef          	jal	ffffffffc02058e6 <strcmp>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc0200396:	478d                	li	a5,3
        if (strcmp(commands[i].name, argv[0]) == 0)
ffffffffc0200398:	c149                	beqz	a0,ffffffffc020041a <kmonitor+0xf2>
    for (i = 0; i < NCOMMANDS; i++)
ffffffffc020039a:	2405                	addiw	s0,s0,1
ffffffffc020039c:	04e1                	addi	s1,s1,24
ffffffffc020039e:	fef418e3          	bne	s0,a5,ffffffffc020038e <kmonitor+0x66>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc02003a2:	6582                	ld	a1,0(sp)
ffffffffc02003a4:	00005517          	auipc	a0,0x5
ffffffffc02003a8:	79c50513          	addi	a0,a0,1948 # ffffffffc0205b40 <etext+0x1c2>
ffffffffc02003ac:	de9ff0ef          	jal	ffffffffc0200194 <cprintf>
    return 0;
ffffffffc02003b0:	bf5d                	j	ffffffffc0200366 <kmonitor+0x3e>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc02003b2:	00005517          	auipc	a0,0x5
ffffffffc02003b6:	76650513          	addi	a0,a0,1894 # ffffffffc0205b18 <etext+0x19a>
ffffffffc02003ba:	588050ef          	jal	ffffffffc0205942 <strchr>
ffffffffc02003be:	c901                	beqz	a0,ffffffffc02003ce <kmonitor+0xa6>
ffffffffc02003c0:	00144583          	lbu	a1,1(s0)
            *buf++ = '\0';
ffffffffc02003c4:	00040023          	sb	zero,0(s0)
ffffffffc02003c8:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc02003ca:	d9d5                	beqz	a1,ffffffffc020037e <kmonitor+0x56>
ffffffffc02003cc:	b7dd                	j	ffffffffc02003b2 <kmonitor+0x8a>
        if (*buf == '\0')
ffffffffc02003ce:	00044783          	lbu	a5,0(s0)
ffffffffc02003d2:	d7d5                	beqz	a5,ffffffffc020037e <kmonitor+0x56>
        if (argc == MAXARGS - 1)
ffffffffc02003d4:	03348b63          	beq	s1,s3,ffffffffc020040a <kmonitor+0xe2>
        argv[argc++] = buf;
ffffffffc02003d8:	00349793          	slli	a5,s1,0x3
ffffffffc02003dc:	978a                	add	a5,a5,sp
ffffffffc02003de:	e380                	sd	s0,0(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc02003e0:	00044583          	lbu	a1,0(s0)
        argv[argc++] = buf;
ffffffffc02003e4:	2485                	addiw	s1,s1,1
ffffffffc02003e6:	8b26                	mv	s6,s1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc02003e8:	e591                	bnez	a1,ffffffffc02003f4 <kmonitor+0xcc>
ffffffffc02003ea:	bf59                	j	ffffffffc0200380 <kmonitor+0x58>
ffffffffc02003ec:	00144583          	lbu	a1,1(s0)
            buf++;
ffffffffc02003f0:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL)
ffffffffc02003f2:	d5d1                	beqz	a1,ffffffffc020037e <kmonitor+0x56>
ffffffffc02003f4:	00005517          	auipc	a0,0x5
ffffffffc02003f8:	72450513          	addi	a0,a0,1828 # ffffffffc0205b18 <etext+0x19a>
ffffffffc02003fc:	546050ef          	jal	ffffffffc0205942 <strchr>
ffffffffc0200400:	d575                	beqz	a0,ffffffffc02003ec <kmonitor+0xc4>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL)
ffffffffc0200402:	00044583          	lbu	a1,0(s0)
ffffffffc0200406:	dda5                	beqz	a1,ffffffffc020037e <kmonitor+0x56>
ffffffffc0200408:	b76d                	j	ffffffffc02003b2 <kmonitor+0x8a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc020040a:	45c1                	li	a1,16
ffffffffc020040c:	00005517          	auipc	a0,0x5
ffffffffc0200410:	71450513          	addi	a0,a0,1812 # ffffffffc0205b20 <etext+0x1a2>
ffffffffc0200414:	d81ff0ef          	jal	ffffffffc0200194 <cprintf>
ffffffffc0200418:	b7c1                	j	ffffffffc02003d8 <kmonitor+0xb0>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc020041a:	00141793          	slli	a5,s0,0x1
ffffffffc020041e:	97a2                	add	a5,a5,s0
ffffffffc0200420:	078e                	slli	a5,a5,0x3
ffffffffc0200422:	97d6                	add	a5,a5,s5
ffffffffc0200424:	6b9c                	ld	a5,16(a5)
ffffffffc0200426:	fffb051b          	addiw	a0,s6,-1
ffffffffc020042a:	8652                	mv	a2,s4
ffffffffc020042c:	002c                	addi	a1,sp,8
ffffffffc020042e:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0)
ffffffffc0200430:	f2055be3          	bgez	a0,ffffffffc0200366 <kmonitor+0x3e>
}
ffffffffc0200434:	70ea                	ld	ra,184(sp)
ffffffffc0200436:	744a                	ld	s0,176(sp)
ffffffffc0200438:	74aa                	ld	s1,168(sp)
ffffffffc020043a:	69ea                	ld	s3,152(sp)
ffffffffc020043c:	6a4a                	ld	s4,144(sp)
ffffffffc020043e:	6aaa                	ld	s5,136(sp)
ffffffffc0200440:	6b0a                	ld	s6,128(sp)
ffffffffc0200442:	6129                	addi	sp,sp,192
ffffffffc0200444:	8082                	ret

ffffffffc0200446 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void __panic(const char *file, int line, const char *fmt, ...)
{
    if (is_panic)
ffffffffc0200446:	0009b317          	auipc	t1,0x9b
ffffffffc020044a:	2f233303          	ld	t1,754(t1) # ffffffffc029b738 <is_panic>
{
ffffffffc020044e:	715d                	addi	sp,sp,-80
ffffffffc0200450:	ec06                	sd	ra,24(sp)
ffffffffc0200452:	f436                	sd	a3,40(sp)
ffffffffc0200454:	f83a                	sd	a4,48(sp)
ffffffffc0200456:	fc3e                	sd	a5,56(sp)
ffffffffc0200458:	e0c2                	sd	a6,64(sp)
ffffffffc020045a:	e4c6                	sd	a7,72(sp)
    if (is_panic)
ffffffffc020045c:	02031e63          	bnez	t1,ffffffffc0200498 <__panic+0x52>
    {
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc0200460:	4705                	li	a4,1

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc0200462:	103c                	addi	a5,sp,40
ffffffffc0200464:	e822                	sd	s0,16(sp)
ffffffffc0200466:	8432                	mv	s0,a2
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200468:	862e                	mv	a2,a1
ffffffffc020046a:	85aa                	mv	a1,a0
ffffffffc020046c:	00005517          	auipc	a0,0x5
ffffffffc0200470:	77c50513          	addi	a0,a0,1916 # ffffffffc0205be8 <etext+0x26a>
    is_panic = 1;
ffffffffc0200474:	0009b697          	auipc	a3,0x9b
ffffffffc0200478:	2ce6b223          	sd	a4,708(a3) # ffffffffc029b738 <is_panic>
    va_start(ap, fmt);
ffffffffc020047c:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc020047e:	d17ff0ef          	jal	ffffffffc0200194 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200482:	65a2                	ld	a1,8(sp)
ffffffffc0200484:	8522                	mv	a0,s0
ffffffffc0200486:	cefff0ef          	jal	ffffffffc0200174 <vcprintf>
    cprintf("\n");
ffffffffc020048a:	00005517          	auipc	a0,0x5
ffffffffc020048e:	77e50513          	addi	a0,a0,1918 # ffffffffc0205c08 <etext+0x28a>
ffffffffc0200492:	d03ff0ef          	jal	ffffffffc0200194 <cprintf>
ffffffffc0200496:	6442                	ld	s0,16(sp)
#endif
}

static inline void sbi_shutdown(void)
{
	SBI_CALL_0(SBI_SHUTDOWN);
ffffffffc0200498:	4501                	li	a0,0
ffffffffc020049a:	4581                	li	a1,0
ffffffffc020049c:	4601                	li	a2,0
ffffffffc020049e:	48a1                	li	a7,8
ffffffffc02004a0:	00000073          	ecall
    va_end(ap);

panic_dead:
    // No debug monitor here
    sbi_shutdown();
    intr_disable();
ffffffffc02004a4:	460000ef          	jal	ffffffffc0200904 <intr_disable>
    while (1)
    {
        kmonitor(NULL);
ffffffffc02004a8:	4501                	li	a0,0
ffffffffc02004aa:	e7fff0ef          	jal	ffffffffc0200328 <kmonitor>
    while (1)
ffffffffc02004ae:	bfed                	j	ffffffffc02004a8 <__panic+0x62>

ffffffffc02004b0 <__warn>:
    }
}

/* __warn - like panic, but don't */
void __warn(const char *file, int line, const char *fmt, ...)
{
ffffffffc02004b0:	715d                	addi	sp,sp,-80
ffffffffc02004b2:	e822                	sd	s0,16(sp)
    va_list ap;
    va_start(ap, fmt);
ffffffffc02004b4:	02810313          	addi	t1,sp,40
{
ffffffffc02004b8:	8432                	mv	s0,a2
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004ba:	862e                	mv	a2,a1
ffffffffc02004bc:	85aa                	mv	a1,a0
ffffffffc02004be:	00005517          	auipc	a0,0x5
ffffffffc02004c2:	75250513          	addi	a0,a0,1874 # ffffffffc0205c10 <etext+0x292>
{
ffffffffc02004c6:	ec06                	sd	ra,24(sp)
ffffffffc02004c8:	f436                	sd	a3,40(sp)
ffffffffc02004ca:	f83a                	sd	a4,48(sp)
ffffffffc02004cc:	fc3e                	sd	a5,56(sp)
ffffffffc02004ce:	e0c2                	sd	a6,64(sp)
ffffffffc02004d0:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02004d2:	e41a                	sd	t1,8(sp)
    cprintf("kernel warning at %s:%d:\n    ", file, line);
ffffffffc02004d4:	cc1ff0ef          	jal	ffffffffc0200194 <cprintf>
    vcprintf(fmt, ap);
ffffffffc02004d8:	65a2                	ld	a1,8(sp)
ffffffffc02004da:	8522                	mv	a0,s0
ffffffffc02004dc:	c99ff0ef          	jal	ffffffffc0200174 <vcprintf>
    cprintf("\n");
ffffffffc02004e0:	00005517          	auipc	a0,0x5
ffffffffc02004e4:	72850513          	addi	a0,a0,1832 # ffffffffc0205c08 <etext+0x28a>
ffffffffc02004e8:	cadff0ef          	jal	ffffffffc0200194 <cprintf>
    va_end(ap);
}
ffffffffc02004ec:	60e2                	ld	ra,24(sp)
ffffffffc02004ee:	6442                	ld	s0,16(sp)
ffffffffc02004f0:	6161                	addi	sp,sp,80
ffffffffc02004f2:	8082                	ret

ffffffffc02004f4 <clock_init>:
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
    // divided by 500 when using Spike(2MHz)
    // divided by 100 when using QEMU(10MHz)
    timebase = 1e7 / 100;
ffffffffc02004f4:	67e1                	lui	a5,0x18
ffffffffc02004f6:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_obj___user_exit_out_size+0xe4e0>
ffffffffc02004fa:	0009b717          	auipc	a4,0x9b
ffffffffc02004fe:	24f73323          	sd	a5,582(a4) # ffffffffc029b740 <timebase>
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200502:	c0102573          	rdtime	a0
	SBI_CALL_1(SBI_SET_TIMER, stime_value);
ffffffffc0200506:	4581                	li	a1,0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200508:	953e                	add	a0,a0,a5
ffffffffc020050a:	4601                	li	a2,0
ffffffffc020050c:	4881                	li	a7,0
ffffffffc020050e:	00000073          	ecall
    set_csr(sie, MIP_STIP);
ffffffffc0200512:	02000793          	li	a5,32
ffffffffc0200516:	1047a7f3          	csrrs	a5,sie,a5
    cprintf("++ setup timer interrupts\n");
ffffffffc020051a:	00005517          	auipc	a0,0x5
ffffffffc020051e:	71650513          	addi	a0,a0,1814 # ffffffffc0205c30 <etext+0x2b2>
    ticks = 0;
ffffffffc0200522:	0009b797          	auipc	a5,0x9b
ffffffffc0200526:	2207b323          	sd	zero,550(a5) # ffffffffc029b748 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc020052a:	b1ad                	j	ffffffffc0200194 <cprintf>

ffffffffc020052c <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020052c:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200530:	0009b797          	auipc	a5,0x9b
ffffffffc0200534:	2107b783          	ld	a5,528(a5) # ffffffffc029b740 <timebase>
ffffffffc0200538:	4581                	li	a1,0
ffffffffc020053a:	4601                	li	a2,0
ffffffffc020053c:	953e                	add	a0,a0,a5
ffffffffc020053e:	4881                	li	a7,0
ffffffffc0200540:	00000073          	ecall
ffffffffc0200544:	8082                	ret

ffffffffc0200546 <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc0200546:	8082                	ret

ffffffffc0200548 <cons_putc>:
#include <riscv.h>
#include <assert.h>

static inline bool __intr_save(void)
{
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0200548:	100027f3          	csrr	a5,sstatus
ffffffffc020054c:	8b89                	andi	a5,a5,2
	SBI_CALL_1(SBI_CONSOLE_PUTCHAR, ch);
ffffffffc020054e:	0ff57513          	zext.b	a0,a0
ffffffffc0200552:	e799                	bnez	a5,ffffffffc0200560 <cons_putc+0x18>
ffffffffc0200554:	4581                	li	a1,0
ffffffffc0200556:	4601                	li	a2,0
ffffffffc0200558:	4885                	li	a7,1
ffffffffc020055a:	00000073          	ecall
    return 0;
}

static inline void __intr_restore(bool flag)
{
    if (flag)
ffffffffc020055e:	8082                	ret

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) {
ffffffffc0200560:	1101                	addi	sp,sp,-32
ffffffffc0200562:	ec06                	sd	ra,24(sp)
ffffffffc0200564:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0200566:	39e000ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc020056a:	6522                	ld	a0,8(sp)
ffffffffc020056c:	4581                	li	a1,0
ffffffffc020056e:	4601                	li	a2,0
ffffffffc0200570:	4885                	li	a7,1
ffffffffc0200572:	00000073          	ecall
    local_intr_save(intr_flag);
    {
        sbi_console_putchar((unsigned char)c);
    }
    local_intr_restore(intr_flag);
}
ffffffffc0200576:	60e2                	ld	ra,24(sp)
ffffffffc0200578:	6105                	addi	sp,sp,32
    {
        intr_enable();
ffffffffc020057a:	a651                	j	ffffffffc02008fe <intr_enable>

ffffffffc020057c <cons_getc>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020057c:	100027f3          	csrr	a5,sstatus
ffffffffc0200580:	8b89                	andi	a5,a5,2
ffffffffc0200582:	eb89                	bnez	a5,ffffffffc0200594 <cons_getc+0x18>
	return SBI_CALL_0(SBI_CONSOLE_GETCHAR);
ffffffffc0200584:	4501                	li	a0,0
ffffffffc0200586:	4581                	li	a1,0
ffffffffc0200588:	4601                	li	a2,0
ffffffffc020058a:	4889                	li	a7,2
ffffffffc020058c:	00000073          	ecall
ffffffffc0200590:	2501                	sext.w	a0,a0
    {
        c = sbi_console_getchar();
    }
    local_intr_restore(intr_flag);
    return c;
}
ffffffffc0200592:	8082                	ret
int cons_getc(void) {
ffffffffc0200594:	1101                	addi	sp,sp,-32
ffffffffc0200596:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0200598:	36c000ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc020059c:	4501                	li	a0,0
ffffffffc020059e:	4581                	li	a1,0
ffffffffc02005a0:	4601                	li	a2,0
ffffffffc02005a2:	4889                	li	a7,2
ffffffffc02005a4:	00000073          	ecall
ffffffffc02005a8:	2501                	sext.w	a0,a0
ffffffffc02005aa:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02005ac:	352000ef          	jal	ffffffffc02008fe <intr_enable>
}
ffffffffc02005b0:	60e2                	ld	ra,24(sp)
ffffffffc02005b2:	6522                	ld	a0,8(sp)
ffffffffc02005b4:	6105                	addi	sp,sp,32
ffffffffc02005b6:	8082                	ret

ffffffffc02005b8 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc02005b8:	7179                	addi	sp,sp,-48
    cprintf("DTB Init\n");
ffffffffc02005ba:	00005517          	auipc	a0,0x5
ffffffffc02005be:	69650513          	addi	a0,a0,1686 # ffffffffc0205c50 <etext+0x2d2>
void dtb_init(void) {
ffffffffc02005c2:	f406                	sd	ra,40(sp)
ffffffffc02005c4:	f022                	sd	s0,32(sp)
    cprintf("DTB Init\n");
ffffffffc02005c6:	bcfff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc02005ca:	0000b597          	auipc	a1,0xb
ffffffffc02005ce:	a365b583          	ld	a1,-1482(a1) # ffffffffc020b000 <boot_hartid>
ffffffffc02005d2:	00005517          	auipc	a0,0x5
ffffffffc02005d6:	68e50513          	addi	a0,a0,1678 # ffffffffc0205c60 <etext+0x2e2>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc02005da:	0000b417          	auipc	s0,0xb
ffffffffc02005de:	a2e40413          	addi	s0,s0,-1490 # ffffffffc020b008 <boot_dtb>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc02005e2:	bb3ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc02005e6:	600c                	ld	a1,0(s0)
ffffffffc02005e8:	00005517          	auipc	a0,0x5
ffffffffc02005ec:	68850513          	addi	a0,a0,1672 # ffffffffc0205c70 <etext+0x2f2>
ffffffffc02005f0:	ba5ff0ef          	jal	ffffffffc0200194 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc02005f4:	6018                	ld	a4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc02005f6:	00005517          	auipc	a0,0x5
ffffffffc02005fa:	69250513          	addi	a0,a0,1682 # ffffffffc0205c88 <etext+0x30a>
    if (boot_dtb == 0) {
ffffffffc02005fe:	10070163          	beqz	a4,ffffffffc0200700 <dtb_init+0x148>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200602:	57f5                	li	a5,-3
ffffffffc0200604:	07fa                	slli	a5,a5,0x1e
ffffffffc0200606:	973e                	add	a4,a4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc0200608:	431c                	lw	a5,0(a4)
    if (magic != 0xd00dfeed) {
ffffffffc020060a:	d00e06b7          	lui	a3,0xd00e0
ffffffffc020060e:	eed68693          	addi	a3,a3,-275 # ffffffffd00dfeed <end+0xfe44735>
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200612:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200616:	0187961b          	slliw	a2,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020061a:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020061e:	0ff5f593          	zext.b	a1,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200622:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200626:	05c2                	slli	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200628:	8e49                	or	a2,a2,a0
ffffffffc020062a:	0ff7f793          	zext.b	a5,a5
ffffffffc020062e:	8dd1                	or	a1,a1,a2
ffffffffc0200630:	07a2                	slli	a5,a5,0x8
ffffffffc0200632:	8ddd                	or	a1,a1,a5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200634:	00ff0837          	lui	a6,0xff0
    if (magic != 0xd00dfeed) {
ffffffffc0200638:	0cd59863          	bne	a1,a3,ffffffffc0200708 <dtb_init+0x150>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc020063c:	4710                	lw	a2,8(a4)
ffffffffc020063e:	4754                	lw	a3,12(a4)
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200640:	e84a                	sd	s2,16(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200642:	0086541b          	srliw	s0,a2,0x8
ffffffffc0200646:	0086d79b          	srliw	a5,a3,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020064a:	01865e1b          	srliw	t3,a2,0x18
ffffffffc020064e:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200652:	0186151b          	slliw	a0,a2,0x18
ffffffffc0200656:	0186959b          	slliw	a1,a3,0x18
ffffffffc020065a:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020065e:	0106561b          	srliw	a2,a2,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200662:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200666:	0106d69b          	srliw	a3,a3,0x10
ffffffffc020066a:	01c56533          	or	a0,a0,t3
ffffffffc020066e:	0115e5b3          	or	a1,a1,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200672:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200676:	0ff67613          	zext.b	a2,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020067a:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020067e:	0ff6f693          	zext.b	a3,a3
ffffffffc0200682:	8c49                	or	s0,s0,a0
ffffffffc0200684:	0622                	slli	a2,a2,0x8
ffffffffc0200686:	8fcd                	or	a5,a5,a1
ffffffffc0200688:	06a2                	slli	a3,a3,0x8
ffffffffc020068a:	8c51                	or	s0,s0,a2
ffffffffc020068c:	8fd5                	or	a5,a5,a3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020068e:	1402                	slli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200690:	1782                	slli	a5,a5,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200692:	9001                	srli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200694:	9381                	srli	a5,a5,0x20
ffffffffc0200696:	ec26                	sd	s1,24(sp)
    int in_memory_node = 0;
ffffffffc0200698:	4301                	li	t1,0
        switch (token) {
ffffffffc020069a:	488d                	li	a7,3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020069c:	943a                	add	s0,s0,a4
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020069e:	00e78933          	add	s2,a5,a4
        switch (token) {
ffffffffc02006a2:	4e05                	li	t3,1
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc02006a4:	4018                	lw	a4,0(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006a6:	0087579b          	srliw	a5,a4,0x8
ffffffffc02006aa:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006ae:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006b2:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006b6:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006ba:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006be:	8ed1                	or	a3,a3,a2
ffffffffc02006c0:	0ff77713          	zext.b	a4,a4
ffffffffc02006c4:	8fd5                	or	a5,a5,a3
ffffffffc02006c6:	0722                	slli	a4,a4,0x8
ffffffffc02006c8:	8fd9                	or	a5,a5,a4
        switch (token) {
ffffffffc02006ca:	05178763          	beq	a5,a7,ffffffffc0200718 <dtb_init+0x160>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc02006ce:	0411                	addi	s0,s0,4
        switch (token) {
ffffffffc02006d0:	00f8e963          	bltu	a7,a5,ffffffffc02006e2 <dtb_init+0x12a>
ffffffffc02006d4:	07c78d63          	beq	a5,t3,ffffffffc020074e <dtb_init+0x196>
ffffffffc02006d8:	4709                	li	a4,2
ffffffffc02006da:	00e79763          	bne	a5,a4,ffffffffc02006e8 <dtb_init+0x130>
ffffffffc02006de:	4301                	li	t1,0
ffffffffc02006e0:	b7d1                	j	ffffffffc02006a4 <dtb_init+0xec>
ffffffffc02006e2:	4711                	li	a4,4
ffffffffc02006e4:	fce780e3          	beq	a5,a4,ffffffffc02006a4 <dtb_init+0xec>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc02006e8:	00005517          	auipc	a0,0x5
ffffffffc02006ec:	66850513          	addi	a0,a0,1640 # ffffffffc0205d50 <etext+0x3d2>
ffffffffc02006f0:	aa5ff0ef          	jal	ffffffffc0200194 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc02006f4:	64e2                	ld	s1,24(sp)
ffffffffc02006f6:	6942                	ld	s2,16(sp)
ffffffffc02006f8:	00005517          	auipc	a0,0x5
ffffffffc02006fc:	69050513          	addi	a0,a0,1680 # ffffffffc0205d88 <etext+0x40a>
}
ffffffffc0200700:	7402                	ld	s0,32(sp)
ffffffffc0200702:	70a2                	ld	ra,40(sp)
ffffffffc0200704:	6145                	addi	sp,sp,48
    cprintf("DTB init completed\n");
ffffffffc0200706:	b479                	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200708:	7402                	ld	s0,32(sp)
ffffffffc020070a:	70a2                	ld	ra,40(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc020070c:	00005517          	auipc	a0,0x5
ffffffffc0200710:	59c50513          	addi	a0,a0,1436 # ffffffffc0205ca8 <etext+0x32a>
}
ffffffffc0200714:	6145                	addi	sp,sp,48
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200716:	bcbd                	j	ffffffffc0200194 <cprintf>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200718:	4058                	lw	a4,4(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020071a:	0087579b          	srliw	a5,a4,0x8
ffffffffc020071e:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200722:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200726:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020072a:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020072e:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200732:	8ed1                	or	a3,a3,a2
ffffffffc0200734:	0ff77713          	zext.b	a4,a4
ffffffffc0200738:	8fd5                	or	a5,a5,a3
ffffffffc020073a:	0722                	slli	a4,a4,0x8
ffffffffc020073c:	8fd9                	or	a5,a5,a4
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020073e:	04031463          	bnez	t1,ffffffffc0200786 <dtb_init+0x1ce>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc0200742:	1782                	slli	a5,a5,0x20
ffffffffc0200744:	9381                	srli	a5,a5,0x20
ffffffffc0200746:	043d                	addi	s0,s0,15
ffffffffc0200748:	943e                	add	s0,s0,a5
ffffffffc020074a:	9871                	andi	s0,s0,-4
                break;
ffffffffc020074c:	bfa1                	j	ffffffffc02006a4 <dtb_init+0xec>
                int name_len = strlen(name);
ffffffffc020074e:	8522                	mv	a0,s0
ffffffffc0200750:	e01a                	sd	t1,0(sp)
ffffffffc0200752:	14e050ef          	jal	ffffffffc02058a0 <strlen>
ffffffffc0200756:	84aa                	mv	s1,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200758:	4619                	li	a2,6
ffffffffc020075a:	8522                	mv	a0,s0
ffffffffc020075c:	00005597          	auipc	a1,0x5
ffffffffc0200760:	57458593          	addi	a1,a1,1396 # ffffffffc0205cd0 <etext+0x352>
ffffffffc0200764:	1b6050ef          	jal	ffffffffc020591a <strncmp>
ffffffffc0200768:	6302                	ld	t1,0(sp)
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc020076a:	0411                	addi	s0,s0,4
ffffffffc020076c:	0004879b          	sext.w	a5,s1
ffffffffc0200770:	943e                	add	s0,s0,a5
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200772:	00153513          	seqz	a0,a0
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc0200776:	9871                	andi	s0,s0,-4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200778:	00a36333          	or	t1,t1,a0
                break;
ffffffffc020077c:	00ff0837          	lui	a6,0xff0
ffffffffc0200780:	488d                	li	a7,3
ffffffffc0200782:	4e05                	li	t3,1
ffffffffc0200784:	b705                	j	ffffffffc02006a4 <dtb_init+0xec>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200786:	4418                	lw	a4,8(s0)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc0200788:	00005597          	auipc	a1,0x5
ffffffffc020078c:	55058593          	addi	a1,a1,1360 # ffffffffc0205cd8 <etext+0x35a>
ffffffffc0200790:	e43e                	sd	a5,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200792:	0087551b          	srliw	a0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200796:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020079a:	0187169b          	slliw	a3,a4,0x18
ffffffffc020079e:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007a2:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007a6:	01057533          	and	a0,a0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007aa:	8ed1                	or	a3,a3,a2
ffffffffc02007ac:	0ff77713          	zext.b	a4,a4
ffffffffc02007b0:	0722                	slli	a4,a4,0x8
ffffffffc02007b2:	8d55                	or	a0,a0,a3
ffffffffc02007b4:	8d59                	or	a0,a0,a4
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc02007b6:	1502                	slli	a0,a0,0x20
ffffffffc02007b8:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02007ba:	954a                	add	a0,a0,s2
ffffffffc02007bc:	e01a                	sd	t1,0(sp)
ffffffffc02007be:	128050ef          	jal	ffffffffc02058e6 <strcmp>
ffffffffc02007c2:	67a2                	ld	a5,8(sp)
ffffffffc02007c4:	473d                	li	a4,15
ffffffffc02007c6:	6302                	ld	t1,0(sp)
ffffffffc02007c8:	00ff0837          	lui	a6,0xff0
ffffffffc02007cc:	488d                	li	a7,3
ffffffffc02007ce:	4e05                	li	t3,1
ffffffffc02007d0:	f6f779e3          	bgeu	a4,a5,ffffffffc0200742 <dtb_init+0x18a>
ffffffffc02007d4:	f53d                	bnez	a0,ffffffffc0200742 <dtb_init+0x18a>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc02007d6:	00c43683          	ld	a3,12(s0)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc02007da:	01443703          	ld	a4,20(s0)
        cprintf("Physical Memory from DTB:\n");
ffffffffc02007de:	00005517          	auipc	a0,0x5
ffffffffc02007e2:	50250513          	addi	a0,a0,1282 # ffffffffc0205ce0 <etext+0x362>
           fdt32_to_cpu(x >> 32);
ffffffffc02007e6:	4206d793          	srai	a5,a3,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007ea:	0087d31b          	srliw	t1,a5,0x8
ffffffffc02007ee:	00871f93          	slli	t6,a4,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc02007f2:	42075893          	srai	a7,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02007f6:	0187df1b          	srliw	t5,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02007fa:	0187959b          	slliw	a1,a5,0x18
ffffffffc02007fe:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200802:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200806:	420fd613          	srai	a2,t6,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020080a:	0188de9b          	srliw	t4,a7,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020080e:	01037333          	and	t1,t1,a6
ffffffffc0200812:	01889e1b          	slliw	t3,a7,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200816:	01e5e5b3          	or	a1,a1,t5
ffffffffc020081a:	0ff7f793          	zext.b	a5,a5
ffffffffc020081e:	01de6e33          	or	t3,t3,t4
ffffffffc0200822:	0065e5b3          	or	a1,a1,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200826:	01067633          	and	a2,a2,a6
ffffffffc020082a:	0086d31b          	srliw	t1,a3,0x8
ffffffffc020082e:	0087541b          	srliw	s0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200832:	07a2                	slli	a5,a5,0x8
ffffffffc0200834:	0108d89b          	srliw	a7,a7,0x10
ffffffffc0200838:	0186df1b          	srliw	t5,a3,0x18
ffffffffc020083c:	01875e9b          	srliw	t4,a4,0x18
ffffffffc0200840:	8ddd                	or	a1,a1,a5
ffffffffc0200842:	01c66633          	or	a2,a2,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200846:	0186979b          	slliw	a5,a3,0x18
ffffffffc020084a:	01871e1b          	slliw	t3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020084e:	0ff8f893          	zext.b	a7,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200852:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200856:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020085a:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020085e:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200862:	01037333          	and	t1,t1,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200866:	08a2                	slli	a7,a7,0x8
ffffffffc0200868:	01e7e7b3          	or	a5,a5,t5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020086c:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200870:	0ff6f693          	zext.b	a3,a3
ffffffffc0200874:	01de6833          	or	a6,t3,t4
ffffffffc0200878:	0ff77713          	zext.b	a4,a4
ffffffffc020087c:	01166633          	or	a2,a2,a7
ffffffffc0200880:	0067e7b3          	or	a5,a5,t1
ffffffffc0200884:	06a2                	slli	a3,a3,0x8
ffffffffc0200886:	01046433          	or	s0,s0,a6
ffffffffc020088a:	0722                	slli	a4,a4,0x8
ffffffffc020088c:	8fd5                	or	a5,a5,a3
ffffffffc020088e:	8c59                	or	s0,s0,a4
           fdt32_to_cpu(x >> 32);
ffffffffc0200890:	1582                	slli	a1,a1,0x20
ffffffffc0200892:	1602                	slli	a2,a2,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200894:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200896:	9201                	srli	a2,a2,0x20
ffffffffc0200898:	9181                	srli	a1,a1,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020089a:	1402                	slli	s0,s0,0x20
ffffffffc020089c:	00b7e4b3          	or	s1,a5,a1
ffffffffc02008a0:	8c51                	or	s0,s0,a2
        cprintf("Physical Memory from DTB:\n");
ffffffffc02008a2:	8f3ff0ef          	jal	ffffffffc0200194 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc02008a6:	85a6                	mv	a1,s1
ffffffffc02008a8:	00005517          	auipc	a0,0x5
ffffffffc02008ac:	45850513          	addi	a0,a0,1112 # ffffffffc0205d00 <etext+0x382>
ffffffffc02008b0:	8e5ff0ef          	jal	ffffffffc0200194 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc02008b4:	01445613          	srli	a2,s0,0x14
ffffffffc02008b8:	85a2                	mv	a1,s0
ffffffffc02008ba:	00005517          	auipc	a0,0x5
ffffffffc02008be:	45e50513          	addi	a0,a0,1118 # ffffffffc0205d18 <etext+0x39a>
ffffffffc02008c2:	8d3ff0ef          	jal	ffffffffc0200194 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc02008c6:	009405b3          	add	a1,s0,s1
ffffffffc02008ca:	15fd                	addi	a1,a1,-1
ffffffffc02008cc:	00005517          	auipc	a0,0x5
ffffffffc02008d0:	46c50513          	addi	a0,a0,1132 # ffffffffc0205d38 <etext+0x3ba>
ffffffffc02008d4:	8c1ff0ef          	jal	ffffffffc0200194 <cprintf>
        memory_base = mem_base;
ffffffffc02008d8:	0009b797          	auipc	a5,0x9b
ffffffffc02008dc:	e897b023          	sd	s1,-384(a5) # ffffffffc029b758 <memory_base>
        memory_size = mem_size;
ffffffffc02008e0:	0009b797          	auipc	a5,0x9b
ffffffffc02008e4:	e687b823          	sd	s0,-400(a5) # ffffffffc029b750 <memory_size>
ffffffffc02008e8:	b531                	j	ffffffffc02006f4 <dtb_init+0x13c>

ffffffffc02008ea <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc02008ea:	0009b517          	auipc	a0,0x9b
ffffffffc02008ee:	e6e53503          	ld	a0,-402(a0) # ffffffffc029b758 <memory_base>
ffffffffc02008f2:	8082                	ret

ffffffffc02008f4 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc02008f4:	0009b517          	auipc	a0,0x9b
ffffffffc02008f8:	e5c53503          	ld	a0,-420(a0) # ffffffffc029b750 <memory_size>
ffffffffc02008fc:	8082                	ret

ffffffffc02008fe <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02008fe:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200902:	8082                	ret

ffffffffc0200904 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc0200904:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200908:	8082                	ret

ffffffffc020090a <pic_init>:
#include <picirq.h>

void pic_enable(unsigned int irq) {}

/* pic_init - initialize the 8259A interrupt controllers */
void pic_init(void) {}
ffffffffc020090a:	8082                	ret

ffffffffc020090c <idt_init>:
void idt_init(void)
{
    extern void __alltraps(void);
    /* Set sscratch register to 0, indicating to exception vector that we are
     * presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc020090c:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc0200910:	00000797          	auipc	a5,0x0
ffffffffc0200914:	5bc78793          	addi	a5,a5,1468 # ffffffffc0200ecc <__alltraps>
ffffffffc0200918:	10579073          	csrw	stvec,a5
    /* Allow kernel to access user memory */
    set_csr(sstatus, SSTATUS_SUM);
ffffffffc020091c:	000407b7          	lui	a5,0x40
ffffffffc0200920:	1007a7f3          	csrrs	a5,sstatus,a5
}
ffffffffc0200924:	8082                	ret

ffffffffc0200926 <print_regs>:
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr)
{
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200926:	610c                	ld	a1,0(a0)
{
ffffffffc0200928:	1141                	addi	sp,sp,-16
ffffffffc020092a:	e022                	sd	s0,0(sp)
ffffffffc020092c:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc020092e:	00005517          	auipc	a0,0x5
ffffffffc0200932:	47250513          	addi	a0,a0,1138 # ffffffffc0205da0 <etext+0x422>
{
ffffffffc0200936:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc0200938:	85dff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc020093c:	640c                	ld	a1,8(s0)
ffffffffc020093e:	00005517          	auipc	a0,0x5
ffffffffc0200942:	47a50513          	addi	a0,a0,1146 # ffffffffc0205db8 <etext+0x43a>
ffffffffc0200946:	84fff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc020094a:	680c                	ld	a1,16(s0)
ffffffffc020094c:	00005517          	auipc	a0,0x5
ffffffffc0200950:	48450513          	addi	a0,a0,1156 # ffffffffc0205dd0 <etext+0x452>
ffffffffc0200954:	841ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200958:	6c0c                	ld	a1,24(s0)
ffffffffc020095a:	00005517          	auipc	a0,0x5
ffffffffc020095e:	48e50513          	addi	a0,a0,1166 # ffffffffc0205de8 <etext+0x46a>
ffffffffc0200962:	833ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200966:	700c                	ld	a1,32(s0)
ffffffffc0200968:	00005517          	auipc	a0,0x5
ffffffffc020096c:	49850513          	addi	a0,a0,1176 # ffffffffc0205e00 <etext+0x482>
ffffffffc0200970:	825ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc0200974:	740c                	ld	a1,40(s0)
ffffffffc0200976:	00005517          	auipc	a0,0x5
ffffffffc020097a:	4a250513          	addi	a0,a0,1186 # ffffffffc0205e18 <etext+0x49a>
ffffffffc020097e:	817ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc0200982:	780c                	ld	a1,48(s0)
ffffffffc0200984:	00005517          	auipc	a0,0x5
ffffffffc0200988:	4ac50513          	addi	a0,a0,1196 # ffffffffc0205e30 <etext+0x4b2>
ffffffffc020098c:	809ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc0200990:	7c0c                	ld	a1,56(s0)
ffffffffc0200992:	00005517          	auipc	a0,0x5
ffffffffc0200996:	4b650513          	addi	a0,a0,1206 # ffffffffc0205e48 <etext+0x4ca>
ffffffffc020099a:	ffaff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc020099e:	602c                	ld	a1,64(s0)
ffffffffc02009a0:	00005517          	auipc	a0,0x5
ffffffffc02009a4:	4c050513          	addi	a0,a0,1216 # ffffffffc0205e60 <etext+0x4e2>
ffffffffc02009a8:	fecff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc02009ac:	642c                	ld	a1,72(s0)
ffffffffc02009ae:	00005517          	auipc	a0,0x5
ffffffffc02009b2:	4ca50513          	addi	a0,a0,1226 # ffffffffc0205e78 <etext+0x4fa>
ffffffffc02009b6:	fdeff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc02009ba:	682c                	ld	a1,80(s0)
ffffffffc02009bc:	00005517          	auipc	a0,0x5
ffffffffc02009c0:	4d450513          	addi	a0,a0,1236 # ffffffffc0205e90 <etext+0x512>
ffffffffc02009c4:	fd0ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc02009c8:	6c2c                	ld	a1,88(s0)
ffffffffc02009ca:	00005517          	auipc	a0,0x5
ffffffffc02009ce:	4de50513          	addi	a0,a0,1246 # ffffffffc0205ea8 <etext+0x52a>
ffffffffc02009d2:	fc2ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc02009d6:	702c                	ld	a1,96(s0)
ffffffffc02009d8:	00005517          	auipc	a0,0x5
ffffffffc02009dc:	4e850513          	addi	a0,a0,1256 # ffffffffc0205ec0 <etext+0x542>
ffffffffc02009e0:	fb4ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc02009e4:	742c                	ld	a1,104(s0)
ffffffffc02009e6:	00005517          	auipc	a0,0x5
ffffffffc02009ea:	4f250513          	addi	a0,a0,1266 # ffffffffc0205ed8 <etext+0x55a>
ffffffffc02009ee:	fa6ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc02009f2:	782c                	ld	a1,112(s0)
ffffffffc02009f4:	00005517          	auipc	a0,0x5
ffffffffc02009f8:	4fc50513          	addi	a0,a0,1276 # ffffffffc0205ef0 <etext+0x572>
ffffffffc02009fc:	f98ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc0200a00:	7c2c                	ld	a1,120(s0)
ffffffffc0200a02:	00005517          	auipc	a0,0x5
ffffffffc0200a06:	50650513          	addi	a0,a0,1286 # ffffffffc0205f08 <etext+0x58a>
ffffffffc0200a0a:	f8aff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc0200a0e:	604c                	ld	a1,128(s0)
ffffffffc0200a10:	00005517          	auipc	a0,0x5
ffffffffc0200a14:	51050513          	addi	a0,a0,1296 # ffffffffc0205f20 <etext+0x5a2>
ffffffffc0200a18:	f7cff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc0200a1c:	644c                	ld	a1,136(s0)
ffffffffc0200a1e:	00005517          	auipc	a0,0x5
ffffffffc0200a22:	51a50513          	addi	a0,a0,1306 # ffffffffc0205f38 <etext+0x5ba>
ffffffffc0200a26:	f6eff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc0200a2a:	684c                	ld	a1,144(s0)
ffffffffc0200a2c:	00005517          	auipc	a0,0x5
ffffffffc0200a30:	52450513          	addi	a0,a0,1316 # ffffffffc0205f50 <etext+0x5d2>
ffffffffc0200a34:	f60ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc0200a38:	6c4c                	ld	a1,152(s0)
ffffffffc0200a3a:	00005517          	auipc	a0,0x5
ffffffffc0200a3e:	52e50513          	addi	a0,a0,1326 # ffffffffc0205f68 <etext+0x5ea>
ffffffffc0200a42:	f52ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc0200a46:	704c                	ld	a1,160(s0)
ffffffffc0200a48:	00005517          	auipc	a0,0x5
ffffffffc0200a4c:	53850513          	addi	a0,a0,1336 # ffffffffc0205f80 <etext+0x602>
ffffffffc0200a50:	f44ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc0200a54:	744c                	ld	a1,168(s0)
ffffffffc0200a56:	00005517          	auipc	a0,0x5
ffffffffc0200a5a:	54250513          	addi	a0,a0,1346 # ffffffffc0205f98 <etext+0x61a>
ffffffffc0200a5e:	f36ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc0200a62:	784c                	ld	a1,176(s0)
ffffffffc0200a64:	00005517          	auipc	a0,0x5
ffffffffc0200a68:	54c50513          	addi	a0,a0,1356 # ffffffffc0205fb0 <etext+0x632>
ffffffffc0200a6c:	f28ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc0200a70:	7c4c                	ld	a1,184(s0)
ffffffffc0200a72:	00005517          	auipc	a0,0x5
ffffffffc0200a76:	55650513          	addi	a0,a0,1366 # ffffffffc0205fc8 <etext+0x64a>
ffffffffc0200a7a:	f1aff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200a7e:	606c                	ld	a1,192(s0)
ffffffffc0200a80:	00005517          	auipc	a0,0x5
ffffffffc0200a84:	56050513          	addi	a0,a0,1376 # ffffffffc0205fe0 <etext+0x662>
ffffffffc0200a88:	f0cff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200a8c:	646c                	ld	a1,200(s0)
ffffffffc0200a8e:	00005517          	auipc	a0,0x5
ffffffffc0200a92:	56a50513          	addi	a0,a0,1386 # ffffffffc0205ff8 <etext+0x67a>
ffffffffc0200a96:	efeff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200a9a:	686c                	ld	a1,208(s0)
ffffffffc0200a9c:	00005517          	auipc	a0,0x5
ffffffffc0200aa0:	57450513          	addi	a0,a0,1396 # ffffffffc0206010 <etext+0x692>
ffffffffc0200aa4:	ef0ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200aa8:	6c6c                	ld	a1,216(s0)
ffffffffc0200aaa:	00005517          	auipc	a0,0x5
ffffffffc0200aae:	57e50513          	addi	a0,a0,1406 # ffffffffc0206028 <etext+0x6aa>
ffffffffc0200ab2:	ee2ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200ab6:	706c                	ld	a1,224(s0)
ffffffffc0200ab8:	00005517          	auipc	a0,0x5
ffffffffc0200abc:	58850513          	addi	a0,a0,1416 # ffffffffc0206040 <etext+0x6c2>
ffffffffc0200ac0:	ed4ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc0200ac4:	746c                	ld	a1,232(s0)
ffffffffc0200ac6:	00005517          	auipc	a0,0x5
ffffffffc0200aca:	59250513          	addi	a0,a0,1426 # ffffffffc0206058 <etext+0x6da>
ffffffffc0200ace:	ec6ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc0200ad2:	786c                	ld	a1,240(s0)
ffffffffc0200ad4:	00005517          	auipc	a0,0x5
ffffffffc0200ad8:	59c50513          	addi	a0,a0,1436 # ffffffffc0206070 <etext+0x6f2>
ffffffffc0200adc:	eb8ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200ae0:	7c6c                	ld	a1,248(s0)
}
ffffffffc0200ae2:	6402                	ld	s0,0(sp)
ffffffffc0200ae4:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200ae6:	00005517          	auipc	a0,0x5
ffffffffc0200aea:	5a250513          	addi	a0,a0,1442 # ffffffffc0206088 <etext+0x70a>
}
ffffffffc0200aee:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200af0:	ea4ff06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0200af4 <print_trapframe>:
{
ffffffffc0200af4:	1141                	addi	sp,sp,-16
ffffffffc0200af6:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200af8:	85aa                	mv	a1,a0
{
ffffffffc0200afa:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc0200afc:	00005517          	auipc	a0,0x5
ffffffffc0200b00:	5a450513          	addi	a0,a0,1444 # ffffffffc02060a0 <etext+0x722>
{
ffffffffc0200b04:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc0200b06:	e8eff0ef          	jal	ffffffffc0200194 <cprintf>
    print_regs(&tf->gpr);
ffffffffc0200b0a:	8522                	mv	a0,s0
ffffffffc0200b0c:	e1bff0ef          	jal	ffffffffc0200926 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc0200b10:	10043583          	ld	a1,256(s0)
ffffffffc0200b14:	00005517          	auipc	a0,0x5
ffffffffc0200b18:	5a450513          	addi	a0,a0,1444 # ffffffffc02060b8 <etext+0x73a>
ffffffffc0200b1c:	e78ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc0200b20:	10843583          	ld	a1,264(s0)
ffffffffc0200b24:	00005517          	auipc	a0,0x5
ffffffffc0200b28:	5ac50513          	addi	a0,a0,1452 # ffffffffc02060d0 <etext+0x752>
ffffffffc0200b2c:	e68ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  tval 0x%08x\n", tf->tval);
ffffffffc0200b30:	11043583          	ld	a1,272(s0)
ffffffffc0200b34:	00005517          	auipc	a0,0x5
ffffffffc0200b38:	5b450513          	addi	a0,a0,1460 # ffffffffc02060e8 <etext+0x76a>
ffffffffc0200b3c:	e58ff0ef          	jal	ffffffffc0200194 <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b40:	11843583          	ld	a1,280(s0)
}
ffffffffc0200b44:	6402                	ld	s0,0(sp)
ffffffffc0200b46:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b48:	00005517          	auipc	a0,0x5
ffffffffc0200b4c:	5b050513          	addi	a0,a0,1456 # ffffffffc02060f8 <etext+0x77a>
}
ffffffffc0200b50:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc0200b52:	e42ff06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0200b56 <interrupt_handler>:
extern struct mm_struct *check_mm_struct;

void interrupt_handler(struct trapframe *tf)
{
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause)
ffffffffc0200b56:	11853783          	ld	a5,280(a0)
ffffffffc0200b5a:	472d                	li	a4,11
ffffffffc0200b5c:	0786                	slli	a5,a5,0x1
ffffffffc0200b5e:	8385                	srli	a5,a5,0x1
ffffffffc0200b60:	08f76d63          	bltu	a4,a5,ffffffffc0200bfa <interrupt_handler+0xa4>
ffffffffc0200b64:	00007717          	auipc	a4,0x7
ffffffffc0200b68:	c2c70713          	addi	a4,a4,-980 # ffffffffc0207790 <commands+0x48>
ffffffffc0200b6c:	078a                	slli	a5,a5,0x2
ffffffffc0200b6e:	97ba                	add	a5,a5,a4
ffffffffc0200b70:	439c                	lw	a5,0(a5)
ffffffffc0200b72:	97ba                	add	a5,a5,a4
ffffffffc0200b74:	8782                	jr	a5
        break;
    case IRQ_H_SOFT:
        cprintf("Hypervisor software interrupt\n");
        break;
    case IRQ_M_SOFT:
        cprintf("Machine software interrupt\n");
ffffffffc0200b76:	00005517          	auipc	a0,0x5
ffffffffc0200b7a:	5fa50513          	addi	a0,a0,1530 # ffffffffc0206170 <etext+0x7f2>
ffffffffc0200b7e:	e16ff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Hypervisor software interrupt\n");
ffffffffc0200b82:	00005517          	auipc	a0,0x5
ffffffffc0200b86:	5ce50513          	addi	a0,a0,1486 # ffffffffc0206150 <etext+0x7d2>
ffffffffc0200b8a:	e0aff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("User software interrupt\n");
ffffffffc0200b8e:	00005517          	auipc	a0,0x5
ffffffffc0200b92:	58250513          	addi	a0,a0,1410 # ffffffffc0206110 <etext+0x792>
ffffffffc0200b96:	dfeff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Supervisor software interrupt\n");
ffffffffc0200b9a:	00005517          	auipc	a0,0x5
ffffffffc0200b9e:	59650513          	addi	a0,a0,1430 # ffffffffc0206130 <etext+0x7b2>
ffffffffc0200ba2:	df2ff06f          	j	ffffffffc0200194 <cprintf>
{
ffffffffc0200ba6:	1141                	addi	sp,sp,-16
ffffffffc0200ba8:	e406                	sd	ra,8(sp)
        /*(1)设置下次时钟中断- clock_set_next_event()
         *(2)计数器（ticks）加一
         *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
         * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
         */
        clock_set_next_event();
ffffffffc0200baa:	983ff0ef          	jal	ffffffffc020052c <clock_set_next_event>
        ticks++;
ffffffffc0200bae:	0009b797          	auipc	a5,0x9b
ffffffffc0200bb2:	b9a78793          	addi	a5,a5,-1126 # ffffffffc029b748 <ticks>
ffffffffc0200bb6:	6394                	ld	a3,0(a5)
        if (ticks % TICK_NUM == 0) {
ffffffffc0200bb8:	28f5c737          	lui	a4,0x28f5c
ffffffffc0200bbc:	28f70713          	addi	a4,a4,655 # 28f5c28f <_binary_obj___user_exit_out_size+0x28f520cf>
        ticks++;
ffffffffc0200bc0:	0685                	addi	a3,a3,1
ffffffffc0200bc2:	e394                	sd	a3,0(a5)
        if (ticks % TICK_NUM == 0) {
ffffffffc0200bc4:	6390                	ld	a2,0(a5)
ffffffffc0200bc6:	5c28f6b7          	lui	a3,0x5c28f
ffffffffc0200bca:	1702                	slli	a4,a4,0x20
ffffffffc0200bcc:	5c368693          	addi	a3,a3,1475 # 5c28f5c3 <_binary_obj___user_exit_out_size+0x5c285403>
ffffffffc0200bd0:	00265793          	srli	a5,a2,0x2
ffffffffc0200bd4:	9736                	add	a4,a4,a3
ffffffffc0200bd6:	02e7b7b3          	mulhu	a5,a5,a4
ffffffffc0200bda:	06400593          	li	a1,100
ffffffffc0200bde:	8389                	srli	a5,a5,0x2
ffffffffc0200be0:	02b787b3          	mul	a5,a5,a1
ffffffffc0200be4:	00f60c63          	beq	a2,a5,ffffffffc0200bfc <interrupt_handler+0xa6>
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200be8:	60a2                	ld	ra,8(sp)
ffffffffc0200bea:	0141                	addi	sp,sp,16
ffffffffc0200bec:	8082                	ret
        cprintf("Supervisor external interrupt\n");
ffffffffc0200bee:	00005517          	auipc	a0,0x5
ffffffffc0200bf2:	5b250513          	addi	a0,a0,1458 # ffffffffc02061a0 <etext+0x822>
ffffffffc0200bf6:	d9eff06f          	j	ffffffffc0200194 <cprintf>
        print_trapframe(tf);
ffffffffc0200bfa:	bded                	j	ffffffffc0200af4 <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200bfc:	00005517          	auipc	a0,0x5
ffffffffc0200c00:	59450513          	addi	a0,a0,1428 # ffffffffc0206190 <etext+0x812>
ffffffffc0200c04:	d90ff0ef          	jal	ffffffffc0200194 <cprintf>
            current->need_resched = 1;
ffffffffc0200c08:	0009b797          	auipc	a5,0x9b
ffffffffc0200c0c:	b987b783          	ld	a5,-1128(a5) # ffffffffc029b7a0 <current>
ffffffffc0200c10:	4705                	li	a4,1
ffffffffc0200c12:	ef98                	sd	a4,24(a5)
ffffffffc0200c14:	bfd1                	j	ffffffffc0200be8 <interrupt_handler+0x92>

ffffffffc0200c16 <exception_handler>:
void kernel_execve_ret(struct trapframe *tf, uintptr_t kstacktop);
void exception_handler(struct trapframe *tf)
{
    int ret;
    switch (tf->cause)
ffffffffc0200c16:	11853783          	ld	a5,280(a0)
ffffffffc0200c1a:	473d                	li	a4,15
ffffffffc0200c1c:	20f76863          	bltu	a4,a5,ffffffffc0200e2c <exception_handler+0x216>
ffffffffc0200c20:	00007717          	auipc	a4,0x7
ffffffffc0200c24:	ba070713          	addi	a4,a4,-1120 # ffffffffc02077c0 <commands+0x78>
ffffffffc0200c28:	078a                	slli	a5,a5,0x2
ffffffffc0200c2a:	97ba                	add	a5,a5,a4
ffffffffc0200c2c:	439c                	lw	a5,0(a5)
{
ffffffffc0200c2e:	1101                	addi	sp,sp,-32
ffffffffc0200c30:	ec06                	sd	ra,24(sp)
    switch (tf->cause)
ffffffffc0200c32:	97ba                	add	a5,a5,a4
ffffffffc0200c34:	86aa                	mv	a3,a0
ffffffffc0200c36:	8782                	jr	a5
ffffffffc0200c38:	e42a                	sd	a0,8(sp)
        // cprintf("Environment call from U-mode\n");
        tf->epc += 4;
        syscall();
        break;
    case CAUSE_SUPERVISOR_ECALL:
        cprintf("Environment call from S-mode\n");
ffffffffc0200c3a:	00005517          	auipc	a0,0x5
ffffffffc0200c3e:	66e50513          	addi	a0,a0,1646 # ffffffffc02062a8 <etext+0x92a>
ffffffffc0200c42:	d52ff0ef          	jal	ffffffffc0200194 <cprintf>
        tf->epc += 4;
ffffffffc0200c46:	66a2                	ld	a3,8(sp)
ffffffffc0200c48:	1086b783          	ld	a5,264(a3)
        break;
    default:
        print_trapframe(tf);
        break;
    }
}
ffffffffc0200c4c:	60e2                	ld	ra,24(sp)
        tf->epc += 4;
ffffffffc0200c4e:	0791                	addi	a5,a5,4
ffffffffc0200c50:	10f6b423          	sd	a5,264(a3)
}
ffffffffc0200c54:	6105                	addi	sp,sp,32
        syscall();
ffffffffc0200c56:	7ec0406f          	j	ffffffffc0205442 <syscall>
}
ffffffffc0200c5a:	60e2                	ld	ra,24(sp)
        cprintf("Environment call from H-mode\n");
ffffffffc0200c5c:	00005517          	auipc	a0,0x5
ffffffffc0200c60:	66c50513          	addi	a0,a0,1644 # ffffffffc02062c8 <etext+0x94a>
}
ffffffffc0200c64:	6105                	addi	sp,sp,32
        cprintf("Environment call from H-mode\n");
ffffffffc0200c66:	d2eff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200c6a:	60e2                	ld	ra,24(sp)
        cprintf("Environment call from M-mode\n");
ffffffffc0200c6c:	00005517          	auipc	a0,0x5
ffffffffc0200c70:	67c50513          	addi	a0,a0,1660 # ffffffffc02062e8 <etext+0x96a>
}
ffffffffc0200c74:	6105                	addi	sp,sp,32
        cprintf("Environment call from M-mode\n");
ffffffffc0200c76:	d1eff06f          	j	ffffffffc0200194 <cprintf>
        cprintf("Instruction page fault\n");
ffffffffc0200c7a:	e42a                	sd	a0,8(sp)
ffffffffc0200c7c:	00005517          	auipc	a0,0x5
ffffffffc0200c80:	68c50513          	addi	a0,a0,1676 # ffffffffc0206308 <etext+0x98a>
ffffffffc0200c84:	d10ff0ef          	jal	ffffffffc0200194 <cprintf>
        if ((ret = do_pgfault(current->mm, tf->cause, tf->tval)) != 0) {
ffffffffc0200c88:	66a2                	ld	a3,8(sp)
ffffffffc0200c8a:	0009b797          	auipc	a5,0x9b
ffffffffc0200c8e:	b167b783          	ld	a5,-1258(a5) # ffffffffc029b7a0 <current>
ffffffffc0200c92:	1106b603          	ld	a2,272(a3)
ffffffffc0200c96:	1186a583          	lw	a1,280(a3)
ffffffffc0200c9a:	7788                	ld	a0,40(a5)
ffffffffc0200c9c:	26a030ef          	jal	ffffffffc0203f06 <do_pgfault>
ffffffffc0200ca0:	66a2                	ld	a3,8(sp)
ffffffffc0200ca2:	10050963          	beqz	a0,ffffffffc0200db4 <exception_handler+0x19e>
            print_trapframe(tf);
ffffffffc0200ca6:	e42a                	sd	a0,8(sp)
ffffffffc0200ca8:	8536                	mv	a0,a3
ffffffffc0200caa:	e4bff0ef          	jal	ffffffffc0200af4 <print_trapframe>
            if (current == NULL) {
ffffffffc0200cae:	0009b717          	auipc	a4,0x9b
ffffffffc0200cb2:	af273703          	ld	a4,-1294(a4) # ffffffffc029b7a0 <current>
ffffffffc0200cb6:	e755                	bnez	a4,ffffffffc0200d62 <exception_handler+0x14c>
                panic("kernel page fault.\n");
ffffffffc0200cb8:	00005617          	auipc	a2,0x5
ffffffffc0200cbc:	66860613          	addi	a2,a2,1640 # ffffffffc0206320 <etext+0x9a2>
ffffffffc0200cc0:	0d900593          	li	a1,217
ffffffffc0200cc4:	00005517          	auipc	a0,0x5
ffffffffc0200cc8:	5b450513          	addi	a0,a0,1460 # ffffffffc0206278 <etext+0x8fa>
ffffffffc0200ccc:	f7aff0ef          	jal	ffffffffc0200446 <__panic>
        cprintf("Load page fault\n");
ffffffffc0200cd0:	e42a                	sd	a0,8(sp)
ffffffffc0200cd2:	00005517          	auipc	a0,0x5
ffffffffc0200cd6:	66650513          	addi	a0,a0,1638 # ffffffffc0206338 <etext+0x9ba>
ffffffffc0200cda:	cbaff0ef          	jal	ffffffffc0200194 <cprintf>
        if ((ret = do_pgfault(current->mm, tf->cause, tf->tval)) != 0) {
ffffffffc0200cde:	66a2                	ld	a3,8(sp)
ffffffffc0200ce0:	0009b797          	auipc	a5,0x9b
ffffffffc0200ce4:	ac07b783          	ld	a5,-1344(a5) # ffffffffc029b7a0 <current>
ffffffffc0200ce8:	1106b603          	ld	a2,272(a3)
ffffffffc0200cec:	1186a583          	lw	a1,280(a3)
ffffffffc0200cf0:	7788                	ld	a0,40(a5)
ffffffffc0200cf2:	214030ef          	jal	ffffffffc0203f06 <do_pgfault>
ffffffffc0200cf6:	66a2                	ld	a3,8(sp)
ffffffffc0200cf8:	cd55                	beqz	a0,ffffffffc0200db4 <exception_handler+0x19e>
            print_trapframe(tf);
ffffffffc0200cfa:	e42a                	sd	a0,8(sp)
ffffffffc0200cfc:	8536                	mv	a0,a3
ffffffffc0200cfe:	df7ff0ef          	jal	ffffffffc0200af4 <print_trapframe>
            if (current == NULL) {
ffffffffc0200d02:	0009b717          	auipc	a4,0x9b
ffffffffc0200d06:	a9e73703          	ld	a4,-1378(a4) # ffffffffc029b7a0 <current>
ffffffffc0200d0a:	ef21                	bnez	a4,ffffffffc0200d62 <exception_handler+0x14c>
                panic("kernel page fault.\n");
ffffffffc0200d0c:	00005617          	auipc	a2,0x5
ffffffffc0200d10:	61460613          	addi	a2,a2,1556 # ffffffffc0206320 <etext+0x9a2>
ffffffffc0200d14:	0e300593          	li	a1,227
ffffffffc0200d18:	00005517          	auipc	a0,0x5
ffffffffc0200d1c:	56050513          	addi	a0,a0,1376 # ffffffffc0206278 <etext+0x8fa>
ffffffffc0200d20:	f26ff0ef          	jal	ffffffffc0200446 <__panic>
        cprintf("Store/AMO page fault\n");
ffffffffc0200d24:	e42a                	sd	a0,8(sp)
ffffffffc0200d26:	00005517          	auipc	a0,0x5
ffffffffc0200d2a:	62a50513          	addi	a0,a0,1578 # ffffffffc0206350 <etext+0x9d2>
ffffffffc0200d2e:	c66ff0ef          	jal	ffffffffc0200194 <cprintf>
        if ((ret = do_pgfault(current->mm, tf->cause, tf->tval)) != 0) {
ffffffffc0200d32:	66a2                	ld	a3,8(sp)
ffffffffc0200d34:	0009b797          	auipc	a5,0x9b
ffffffffc0200d38:	a6c7b783          	ld	a5,-1428(a5) # ffffffffc029b7a0 <current>
ffffffffc0200d3c:	1106b603          	ld	a2,272(a3)
ffffffffc0200d40:	1186a583          	lw	a1,280(a3)
ffffffffc0200d44:	7788                	ld	a0,40(a5)
ffffffffc0200d46:	1c0030ef          	jal	ffffffffc0203f06 <do_pgfault>
ffffffffc0200d4a:	66a2                	ld	a3,8(sp)
ffffffffc0200d4c:	c525                	beqz	a0,ffffffffc0200db4 <exception_handler+0x19e>
            print_trapframe(tf);
ffffffffc0200d4e:	e42a                	sd	a0,8(sp)
ffffffffc0200d50:	8536                	mv	a0,a3
ffffffffc0200d52:	da3ff0ef          	jal	ffffffffc0200af4 <print_trapframe>
            if (current == NULL) {
ffffffffc0200d56:	0009b717          	auipc	a4,0x9b
ffffffffc0200d5a:	a4a73703          	ld	a4,-1462(a4) # ffffffffc029b7a0 <current>
ffffffffc0200d5e:	0c070863          	beqz	a4,ffffffffc0200e2e <exception_handler+0x218>
            do_exit(ret);
ffffffffc0200d62:	6522                	ld	a0,8(sp)
}
ffffffffc0200d64:	60e2                	ld	ra,24(sp)
ffffffffc0200d66:	6105                	addi	sp,sp,32
            do_exit(ret);
ffffffffc0200d68:	0a90306f          	j	ffffffffc0204610 <do_exit>
}
ffffffffc0200d6c:	60e2                	ld	ra,24(sp)
        cprintf("Instruction address misaligned\n");
ffffffffc0200d6e:	00005517          	auipc	a0,0x5
ffffffffc0200d72:	45250513          	addi	a0,a0,1106 # ffffffffc02061c0 <etext+0x842>
}
ffffffffc0200d76:	6105                	addi	sp,sp,32
        cprintf("Instruction address misaligned\n");
ffffffffc0200d78:	c1cff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200d7c:	60e2                	ld	ra,24(sp)
        cprintf("Instruction access fault\n");
ffffffffc0200d7e:	00005517          	auipc	a0,0x5
ffffffffc0200d82:	46250513          	addi	a0,a0,1122 # ffffffffc02061e0 <etext+0x862>
}
ffffffffc0200d86:	6105                	addi	sp,sp,32
        cprintf("Instruction access fault\n");
ffffffffc0200d88:	c0cff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200d8c:	60e2                	ld	ra,24(sp)
        cprintf("Illegal instruction\n");
ffffffffc0200d8e:	00005517          	auipc	a0,0x5
ffffffffc0200d92:	47250513          	addi	a0,a0,1138 # ffffffffc0206200 <etext+0x882>
}
ffffffffc0200d96:	6105                	addi	sp,sp,32
        cprintf("Illegal instruction\n");
ffffffffc0200d98:	bfcff06f          	j	ffffffffc0200194 <cprintf>
ffffffffc0200d9c:	e42a                	sd	a0,8(sp)
        cprintf("Breakpoint\n");
ffffffffc0200d9e:	00005517          	auipc	a0,0x5
ffffffffc0200da2:	47a50513          	addi	a0,a0,1146 # ffffffffc0206218 <etext+0x89a>
ffffffffc0200da6:	beeff0ef          	jal	ffffffffc0200194 <cprintf>
        if (tf->gpr.a7 == 10)
ffffffffc0200daa:	66a2                	ld	a3,8(sp)
ffffffffc0200dac:	47a9                	li	a5,10
ffffffffc0200dae:	66d8                	ld	a4,136(a3)
ffffffffc0200db0:	04f70c63          	beq	a4,a5,ffffffffc0200e08 <exception_handler+0x1f2>
}
ffffffffc0200db4:	60e2                	ld	ra,24(sp)
ffffffffc0200db6:	6105                	addi	sp,sp,32
ffffffffc0200db8:	8082                	ret
ffffffffc0200dba:	60e2                	ld	ra,24(sp)
        cprintf("Load address misaligned\n");
ffffffffc0200dbc:	00005517          	auipc	a0,0x5
ffffffffc0200dc0:	46c50513          	addi	a0,a0,1132 # ffffffffc0206228 <etext+0x8aa>
}
ffffffffc0200dc4:	6105                	addi	sp,sp,32
        cprintf("Load address misaligned\n");
ffffffffc0200dc6:	bceff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200dca:	60e2                	ld	ra,24(sp)
        cprintf("Load access fault\n");
ffffffffc0200dcc:	00005517          	auipc	a0,0x5
ffffffffc0200dd0:	47c50513          	addi	a0,a0,1148 # ffffffffc0206248 <etext+0x8ca>
}
ffffffffc0200dd4:	6105                	addi	sp,sp,32
        cprintf("Load access fault\n");
ffffffffc0200dd6:	bbeff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200dda:	60e2                	ld	ra,24(sp)
        cprintf("Store/AMO access fault\n");
ffffffffc0200ddc:	00005517          	auipc	a0,0x5
ffffffffc0200de0:	4b450513          	addi	a0,a0,1204 # ffffffffc0206290 <etext+0x912>
}
ffffffffc0200de4:	6105                	addi	sp,sp,32
        cprintf("Store/AMO access fault\n");
ffffffffc0200de6:	baeff06f          	j	ffffffffc0200194 <cprintf>
}
ffffffffc0200dea:	60e2                	ld	ra,24(sp)
ffffffffc0200dec:	6105                	addi	sp,sp,32
        print_trapframe(tf);
ffffffffc0200dee:	b319                	j	ffffffffc0200af4 <print_trapframe>
        panic("AMO address misaligned\n");
ffffffffc0200df0:	00005617          	auipc	a2,0x5
ffffffffc0200df4:	47060613          	addi	a2,a2,1136 # ffffffffc0206260 <etext+0x8e2>
ffffffffc0200df8:	0bf00593          	li	a1,191
ffffffffc0200dfc:	00005517          	auipc	a0,0x5
ffffffffc0200e00:	47c50513          	addi	a0,a0,1148 # ffffffffc0206278 <etext+0x8fa>
ffffffffc0200e04:	e42ff0ef          	jal	ffffffffc0200446 <__panic>
            tf->epc += 4;
ffffffffc0200e08:	1086b783          	ld	a5,264(a3)
ffffffffc0200e0c:	0791                	addi	a5,a5,4
ffffffffc0200e0e:	10f6b423          	sd	a5,264(a3)
            syscall();
ffffffffc0200e12:	630040ef          	jal	ffffffffc0205442 <syscall>
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200e16:	0009b717          	auipc	a4,0x9b
ffffffffc0200e1a:	98a73703          	ld	a4,-1654(a4) # ffffffffc029b7a0 <current>
ffffffffc0200e1e:	6522                	ld	a0,8(sp)
}
ffffffffc0200e20:	60e2                	ld	ra,24(sp)
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200e22:	6b0c                	ld	a1,16(a4)
ffffffffc0200e24:	6789                	lui	a5,0x2
ffffffffc0200e26:	95be                	add	a1,a1,a5
}
ffffffffc0200e28:	6105                	addi	sp,sp,32
            kernel_execve_ret(tf, current->kstack + KSTACKSIZE);
ffffffffc0200e2a:	aa85                	j	ffffffffc0200f9a <kernel_execve_ret>
        print_trapframe(tf);
ffffffffc0200e2c:	b1e1                	j	ffffffffc0200af4 <print_trapframe>
                panic("kernel page fault.\n");
ffffffffc0200e2e:	00005617          	auipc	a2,0x5
ffffffffc0200e32:	4f260613          	addi	a2,a2,1266 # ffffffffc0206320 <etext+0x9a2>
ffffffffc0200e36:	0ed00593          	li	a1,237
ffffffffc0200e3a:	00005517          	auipc	a0,0x5
ffffffffc0200e3e:	43e50513          	addi	a0,a0,1086 # ffffffffc0206278 <etext+0x8fa>
ffffffffc0200e42:	e04ff0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0200e46 <trap>:
 * */
void trap(struct trapframe *tf)
{
    // dispatch based on what type of trap occurred
    //    cputs("some trap");
    if (current == NULL)
ffffffffc0200e46:	0009b717          	auipc	a4,0x9b
ffffffffc0200e4a:	95a73703          	ld	a4,-1702(a4) # ffffffffc029b7a0 <current>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200e4e:	11853583          	ld	a1,280(a0)
    if (current == NULL)
ffffffffc0200e52:	cf21                	beqz	a4,ffffffffc0200eaa <trap+0x64>
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200e54:	10053603          	ld	a2,256(a0)
    {
        trap_dispatch(tf);
    }
    else
    {
        struct trapframe *otf = current->tf;
ffffffffc0200e58:	0a073803          	ld	a6,160(a4)
{
ffffffffc0200e5c:	1101                	addi	sp,sp,-32
ffffffffc0200e5e:	ec06                	sd	ra,24(sp)
    return (tf->status & SSTATUS_SPP) != 0;
ffffffffc0200e60:	10067613          	andi	a2,a2,256
        current->tf = tf;
ffffffffc0200e64:	f348                	sd	a0,160(a4)
    if ((intptr_t)tf->cause < 0)
ffffffffc0200e66:	e432                	sd	a2,8(sp)
ffffffffc0200e68:	e042                	sd	a6,0(sp)
ffffffffc0200e6a:	0205c763          	bltz	a1,ffffffffc0200e98 <trap+0x52>
        exception_handler(tf);
ffffffffc0200e6e:	da9ff0ef          	jal	ffffffffc0200c16 <exception_handler>
ffffffffc0200e72:	6622                	ld	a2,8(sp)
ffffffffc0200e74:	6802                	ld	a6,0(sp)
ffffffffc0200e76:	0009b697          	auipc	a3,0x9b
ffffffffc0200e7a:	92a68693          	addi	a3,a3,-1750 # ffffffffc029b7a0 <current>

        bool in_kernel = trap_in_kernel(tf);

        trap_dispatch(tf);

        current->tf = otf;
ffffffffc0200e7e:	6298                	ld	a4,0(a3)
ffffffffc0200e80:	0b073023          	sd	a6,160(a4)
        if (!in_kernel)
ffffffffc0200e84:	e619                	bnez	a2,ffffffffc0200e92 <trap+0x4c>
        {
            if (current->flags & PF_EXITING)
ffffffffc0200e86:	0b072783          	lw	a5,176(a4)
ffffffffc0200e8a:	8b85                	andi	a5,a5,1
ffffffffc0200e8c:	e79d                	bnez	a5,ffffffffc0200eba <trap+0x74>
            {
                do_exit(-E_KILLED);
            }
            if (current->need_resched)
ffffffffc0200e8e:	6f1c                	ld	a5,24(a4)
ffffffffc0200e90:	e38d                	bnez	a5,ffffffffc0200eb2 <trap+0x6c>
            {
                schedule();
            }
        }
    }
}
ffffffffc0200e92:	60e2                	ld	ra,24(sp)
ffffffffc0200e94:	6105                	addi	sp,sp,32
ffffffffc0200e96:	8082                	ret
        interrupt_handler(tf);
ffffffffc0200e98:	cbfff0ef          	jal	ffffffffc0200b56 <interrupt_handler>
ffffffffc0200e9c:	6802                	ld	a6,0(sp)
ffffffffc0200e9e:	6622                	ld	a2,8(sp)
ffffffffc0200ea0:	0009b697          	auipc	a3,0x9b
ffffffffc0200ea4:	90068693          	addi	a3,a3,-1792 # ffffffffc029b7a0 <current>
ffffffffc0200ea8:	bfd9                	j	ffffffffc0200e7e <trap+0x38>
    if ((intptr_t)tf->cause < 0)
ffffffffc0200eaa:	0005c363          	bltz	a1,ffffffffc0200eb0 <trap+0x6a>
        exception_handler(tf);
ffffffffc0200eae:	b3a5                	j	ffffffffc0200c16 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200eb0:	b15d                	j	ffffffffc0200b56 <interrupt_handler>
}
ffffffffc0200eb2:	60e2                	ld	ra,24(sp)
ffffffffc0200eb4:	6105                	addi	sp,sp,32
                schedule();
ffffffffc0200eb6:	4a00406f          	j	ffffffffc0205356 <schedule>
                do_exit(-E_KILLED);
ffffffffc0200eba:	555d                	li	a0,-9
ffffffffc0200ebc:	754030ef          	jal	ffffffffc0204610 <do_exit>
            if (current->need_resched)
ffffffffc0200ec0:	0009b717          	auipc	a4,0x9b
ffffffffc0200ec4:	8e073703          	ld	a4,-1824(a4) # ffffffffc029b7a0 <current>
ffffffffc0200ec8:	b7d9                	j	ffffffffc0200e8e <trap+0x48>
	...

ffffffffc0200ecc <__alltraps>:
    LOAD x2, 2*REGBYTES(sp)
    .endm

    .globl __alltraps
__alltraps:
    SAVE_ALL
ffffffffc0200ecc:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0200ed0:	00011463          	bnez	sp,ffffffffc0200ed8 <__alltraps+0xc>
ffffffffc0200ed4:	14002173          	csrr	sp,sscratch
ffffffffc0200ed8:	712d                	addi	sp,sp,-288
ffffffffc0200eda:	e002                	sd	zero,0(sp)
ffffffffc0200edc:	e406                	sd	ra,8(sp)
ffffffffc0200ede:	ec0e                	sd	gp,24(sp)
ffffffffc0200ee0:	f012                	sd	tp,32(sp)
ffffffffc0200ee2:	f416                	sd	t0,40(sp)
ffffffffc0200ee4:	f81a                	sd	t1,48(sp)
ffffffffc0200ee6:	fc1e                	sd	t2,56(sp)
ffffffffc0200ee8:	e0a2                	sd	s0,64(sp)
ffffffffc0200eea:	e4a6                	sd	s1,72(sp)
ffffffffc0200eec:	e8aa                	sd	a0,80(sp)
ffffffffc0200eee:	ecae                	sd	a1,88(sp)
ffffffffc0200ef0:	f0b2                	sd	a2,96(sp)
ffffffffc0200ef2:	f4b6                	sd	a3,104(sp)
ffffffffc0200ef4:	f8ba                	sd	a4,112(sp)
ffffffffc0200ef6:	fcbe                	sd	a5,120(sp)
ffffffffc0200ef8:	e142                	sd	a6,128(sp)
ffffffffc0200efa:	e546                	sd	a7,136(sp)
ffffffffc0200efc:	e94a                	sd	s2,144(sp)
ffffffffc0200efe:	ed4e                	sd	s3,152(sp)
ffffffffc0200f00:	f152                	sd	s4,160(sp)
ffffffffc0200f02:	f556                	sd	s5,168(sp)
ffffffffc0200f04:	f95a                	sd	s6,176(sp)
ffffffffc0200f06:	fd5e                	sd	s7,184(sp)
ffffffffc0200f08:	e1e2                	sd	s8,192(sp)
ffffffffc0200f0a:	e5e6                	sd	s9,200(sp)
ffffffffc0200f0c:	e9ea                	sd	s10,208(sp)
ffffffffc0200f0e:	edee                	sd	s11,216(sp)
ffffffffc0200f10:	f1f2                	sd	t3,224(sp)
ffffffffc0200f12:	f5f6                	sd	t4,232(sp)
ffffffffc0200f14:	f9fa                	sd	t5,240(sp)
ffffffffc0200f16:	fdfe                	sd	t6,248(sp)
ffffffffc0200f18:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200f1c:	100024f3          	csrr	s1,sstatus
ffffffffc0200f20:	14102973          	csrr	s2,sepc
ffffffffc0200f24:	143029f3          	csrr	s3,stval
ffffffffc0200f28:	14202a73          	csrr	s4,scause
ffffffffc0200f2c:	e822                	sd	s0,16(sp)
ffffffffc0200f2e:	e226                	sd	s1,256(sp)
ffffffffc0200f30:	e64a                	sd	s2,264(sp)
ffffffffc0200f32:	ea4e                	sd	s3,272(sp)
ffffffffc0200f34:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200f36:	850a                	mv	a0,sp
    jal trap
ffffffffc0200f38:	f0fff0ef          	jal	ffffffffc0200e46 <trap>

ffffffffc0200f3c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200f3c:	6492                	ld	s1,256(sp)
ffffffffc0200f3e:	6932                	ld	s2,264(sp)
ffffffffc0200f40:	1004f413          	andi	s0,s1,256
ffffffffc0200f44:	e401                	bnez	s0,ffffffffc0200f4c <__trapret+0x10>
ffffffffc0200f46:	1200                	addi	s0,sp,288
ffffffffc0200f48:	14041073          	csrw	sscratch,s0
ffffffffc0200f4c:	10049073          	csrw	sstatus,s1
ffffffffc0200f50:	14191073          	csrw	sepc,s2
ffffffffc0200f54:	60a2                	ld	ra,8(sp)
ffffffffc0200f56:	61e2                	ld	gp,24(sp)
ffffffffc0200f58:	7202                	ld	tp,32(sp)
ffffffffc0200f5a:	72a2                	ld	t0,40(sp)
ffffffffc0200f5c:	7342                	ld	t1,48(sp)
ffffffffc0200f5e:	73e2                	ld	t2,56(sp)
ffffffffc0200f60:	6406                	ld	s0,64(sp)
ffffffffc0200f62:	64a6                	ld	s1,72(sp)
ffffffffc0200f64:	6546                	ld	a0,80(sp)
ffffffffc0200f66:	65e6                	ld	a1,88(sp)
ffffffffc0200f68:	7606                	ld	a2,96(sp)
ffffffffc0200f6a:	76a6                	ld	a3,104(sp)
ffffffffc0200f6c:	7746                	ld	a4,112(sp)
ffffffffc0200f6e:	77e6                	ld	a5,120(sp)
ffffffffc0200f70:	680a                	ld	a6,128(sp)
ffffffffc0200f72:	68aa                	ld	a7,136(sp)
ffffffffc0200f74:	694a                	ld	s2,144(sp)
ffffffffc0200f76:	69ea                	ld	s3,152(sp)
ffffffffc0200f78:	7a0a                	ld	s4,160(sp)
ffffffffc0200f7a:	7aaa                	ld	s5,168(sp)
ffffffffc0200f7c:	7b4a                	ld	s6,176(sp)
ffffffffc0200f7e:	7bea                	ld	s7,184(sp)
ffffffffc0200f80:	6c0e                	ld	s8,192(sp)
ffffffffc0200f82:	6cae                	ld	s9,200(sp)
ffffffffc0200f84:	6d4e                	ld	s10,208(sp)
ffffffffc0200f86:	6dee                	ld	s11,216(sp)
ffffffffc0200f88:	7e0e                	ld	t3,224(sp)
ffffffffc0200f8a:	7eae                	ld	t4,232(sp)
ffffffffc0200f8c:	7f4e                	ld	t5,240(sp)
ffffffffc0200f8e:	7fee                	ld	t6,248(sp)
ffffffffc0200f90:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200f92:	10200073          	sret

ffffffffc0200f96 <forkrets>:
 
    .globl forkrets
forkrets:
    # set stack to this new process's trapframe
    move sp, a0
ffffffffc0200f96:	812a                	mv	sp,a0
    j __trapret
ffffffffc0200f98:	b755                	j	ffffffffc0200f3c <__trapret>

ffffffffc0200f9a <kernel_execve_ret>:

    .global kernel_execve_ret
kernel_execve_ret:
    // adjust sp to beneath kstacktop of current process
    addi a1, a1, -36*REGBYTES
ffffffffc0200f9a:	ee058593          	addi	a1,a1,-288

    // copy from previous trapframe to new trapframe
    LOAD s1, 35*REGBYTES(a0)
ffffffffc0200f9e:	11853483          	ld	s1,280(a0)
    STORE s1, 35*REGBYTES(a1)
ffffffffc0200fa2:	1095bc23          	sd	s1,280(a1)
    LOAD s1, 34*REGBYTES(a0)
ffffffffc0200fa6:	11053483          	ld	s1,272(a0)
    STORE s1, 34*REGBYTES(a1)
ffffffffc0200faa:	1095b823          	sd	s1,272(a1)
    LOAD s1, 33*REGBYTES(a0)
ffffffffc0200fae:	10853483          	ld	s1,264(a0)
    STORE s1, 33*REGBYTES(a1)
ffffffffc0200fb2:	1095b423          	sd	s1,264(a1)
    LOAD s1, 32*REGBYTES(a0)
ffffffffc0200fb6:	10053483          	ld	s1,256(a0)
    STORE s1, 32*REGBYTES(a1)
ffffffffc0200fba:	1095b023          	sd	s1,256(a1)
    LOAD s1, 31*REGBYTES(a0)
ffffffffc0200fbe:	7d64                	ld	s1,248(a0)
    STORE s1, 31*REGBYTES(a1)
ffffffffc0200fc0:	fde4                	sd	s1,248(a1)
    LOAD s1, 30*REGBYTES(a0)
ffffffffc0200fc2:	7964                	ld	s1,240(a0)
    STORE s1, 30*REGBYTES(a1)
ffffffffc0200fc4:	f9e4                	sd	s1,240(a1)
    LOAD s1, 29*REGBYTES(a0)
ffffffffc0200fc6:	7564                	ld	s1,232(a0)
    STORE s1, 29*REGBYTES(a1)
ffffffffc0200fc8:	f5e4                	sd	s1,232(a1)
    LOAD s1, 28*REGBYTES(a0)
ffffffffc0200fca:	7164                	ld	s1,224(a0)
    STORE s1, 28*REGBYTES(a1)
ffffffffc0200fcc:	f1e4                	sd	s1,224(a1)
    LOAD s1, 27*REGBYTES(a0)
ffffffffc0200fce:	6d64                	ld	s1,216(a0)
    STORE s1, 27*REGBYTES(a1)
ffffffffc0200fd0:	ede4                	sd	s1,216(a1)
    LOAD s1, 26*REGBYTES(a0)
ffffffffc0200fd2:	6964                	ld	s1,208(a0)
    STORE s1, 26*REGBYTES(a1)
ffffffffc0200fd4:	e9e4                	sd	s1,208(a1)
    LOAD s1, 25*REGBYTES(a0)
ffffffffc0200fd6:	6564                	ld	s1,200(a0)
    STORE s1, 25*REGBYTES(a1)
ffffffffc0200fd8:	e5e4                	sd	s1,200(a1)
    LOAD s1, 24*REGBYTES(a0)
ffffffffc0200fda:	6164                	ld	s1,192(a0)
    STORE s1, 24*REGBYTES(a1)
ffffffffc0200fdc:	e1e4                	sd	s1,192(a1)
    LOAD s1, 23*REGBYTES(a0)
ffffffffc0200fde:	7d44                	ld	s1,184(a0)
    STORE s1, 23*REGBYTES(a1)
ffffffffc0200fe0:	fdc4                	sd	s1,184(a1)
    LOAD s1, 22*REGBYTES(a0)
ffffffffc0200fe2:	7944                	ld	s1,176(a0)
    STORE s1, 22*REGBYTES(a1)
ffffffffc0200fe4:	f9c4                	sd	s1,176(a1)
    LOAD s1, 21*REGBYTES(a0)
ffffffffc0200fe6:	7544                	ld	s1,168(a0)
    STORE s1, 21*REGBYTES(a1)
ffffffffc0200fe8:	f5c4                	sd	s1,168(a1)
    LOAD s1, 20*REGBYTES(a0)
ffffffffc0200fea:	7144                	ld	s1,160(a0)
    STORE s1, 20*REGBYTES(a1)
ffffffffc0200fec:	f1c4                	sd	s1,160(a1)
    LOAD s1, 19*REGBYTES(a0)
ffffffffc0200fee:	6d44                	ld	s1,152(a0)
    STORE s1, 19*REGBYTES(a1)
ffffffffc0200ff0:	edc4                	sd	s1,152(a1)
    LOAD s1, 18*REGBYTES(a0)
ffffffffc0200ff2:	6944                	ld	s1,144(a0)
    STORE s1, 18*REGBYTES(a1)
ffffffffc0200ff4:	e9c4                	sd	s1,144(a1)
    LOAD s1, 17*REGBYTES(a0)
ffffffffc0200ff6:	6544                	ld	s1,136(a0)
    STORE s1, 17*REGBYTES(a1)
ffffffffc0200ff8:	e5c4                	sd	s1,136(a1)
    LOAD s1, 16*REGBYTES(a0)
ffffffffc0200ffa:	6144                	ld	s1,128(a0)
    STORE s1, 16*REGBYTES(a1)
ffffffffc0200ffc:	e1c4                	sd	s1,128(a1)
    LOAD s1, 15*REGBYTES(a0)
ffffffffc0200ffe:	7d24                	ld	s1,120(a0)
    STORE s1, 15*REGBYTES(a1)
ffffffffc0201000:	fda4                	sd	s1,120(a1)
    LOAD s1, 14*REGBYTES(a0)
ffffffffc0201002:	7924                	ld	s1,112(a0)
    STORE s1, 14*REGBYTES(a1)
ffffffffc0201004:	f9a4                	sd	s1,112(a1)
    LOAD s1, 13*REGBYTES(a0)
ffffffffc0201006:	7524                	ld	s1,104(a0)
    STORE s1, 13*REGBYTES(a1)
ffffffffc0201008:	f5a4                	sd	s1,104(a1)
    LOAD s1, 12*REGBYTES(a0)
ffffffffc020100a:	7124                	ld	s1,96(a0)
    STORE s1, 12*REGBYTES(a1)
ffffffffc020100c:	f1a4                	sd	s1,96(a1)
    LOAD s1, 11*REGBYTES(a0)
ffffffffc020100e:	6d24                	ld	s1,88(a0)
    STORE s1, 11*REGBYTES(a1)
ffffffffc0201010:	eda4                	sd	s1,88(a1)
    LOAD s1, 10*REGBYTES(a0)
ffffffffc0201012:	6924                	ld	s1,80(a0)
    STORE s1, 10*REGBYTES(a1)
ffffffffc0201014:	e9a4                	sd	s1,80(a1)
    LOAD s1, 9*REGBYTES(a0)
ffffffffc0201016:	6524                	ld	s1,72(a0)
    STORE s1, 9*REGBYTES(a1)
ffffffffc0201018:	e5a4                	sd	s1,72(a1)
    LOAD s1, 8*REGBYTES(a0)
ffffffffc020101a:	6124                	ld	s1,64(a0)
    STORE s1, 8*REGBYTES(a1)
ffffffffc020101c:	e1a4                	sd	s1,64(a1)
    LOAD s1, 7*REGBYTES(a0)
ffffffffc020101e:	7d04                	ld	s1,56(a0)
    STORE s1, 7*REGBYTES(a1)
ffffffffc0201020:	fd84                	sd	s1,56(a1)
    LOAD s1, 6*REGBYTES(a0)
ffffffffc0201022:	7904                	ld	s1,48(a0)
    STORE s1, 6*REGBYTES(a1)
ffffffffc0201024:	f984                	sd	s1,48(a1)
    LOAD s1, 5*REGBYTES(a0)
ffffffffc0201026:	7504                	ld	s1,40(a0)
    STORE s1, 5*REGBYTES(a1)
ffffffffc0201028:	f584                	sd	s1,40(a1)
    LOAD s1, 4*REGBYTES(a0)
ffffffffc020102a:	7104                	ld	s1,32(a0)
    STORE s1, 4*REGBYTES(a1)
ffffffffc020102c:	f184                	sd	s1,32(a1)
    LOAD s1, 3*REGBYTES(a0)
ffffffffc020102e:	6d04                	ld	s1,24(a0)
    STORE s1, 3*REGBYTES(a1)
ffffffffc0201030:	ed84                	sd	s1,24(a1)
    LOAD s1, 2*REGBYTES(a0)
ffffffffc0201032:	6904                	ld	s1,16(a0)
    STORE s1, 2*REGBYTES(a1)
ffffffffc0201034:	e984                	sd	s1,16(a1)
    LOAD s1, 1*REGBYTES(a0)
ffffffffc0201036:	6504                	ld	s1,8(a0)
    STORE s1, 1*REGBYTES(a1)
ffffffffc0201038:	e584                	sd	s1,8(a1)
    LOAD s1, 0*REGBYTES(a0)
ffffffffc020103a:	6104                	ld	s1,0(a0)
    STORE s1, 0*REGBYTES(a1)
ffffffffc020103c:	e184                	sd	s1,0(a1)

    // acutually adjust sp
    move sp, a1
ffffffffc020103e:	812e                	mv	sp,a1
ffffffffc0201040:	bdf5                	j	ffffffffc0200f3c <__trapret>

ffffffffc0201042 <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0201042:	00096797          	auipc	a5,0x96
ffffffffc0201046:	6ce78793          	addi	a5,a5,1742 # ffffffffc0297710 <free_area>
ffffffffc020104a:	e79c                	sd	a5,8(a5)
ffffffffc020104c:	e39c                	sd	a5,0(a5)

static void
default_init(void)
{
    list_init(&free_list);
    nr_free = 0;
ffffffffc020104e:	0007a823          	sw	zero,16(a5)
}
ffffffffc0201052:	8082                	ret

ffffffffc0201054 <default_nr_free_pages>:

static size_t
default_nr_free_pages(void)
{
    return nr_free;
}
ffffffffc0201054:	00096517          	auipc	a0,0x96
ffffffffc0201058:	6cc56503          	lwu	a0,1740(a0) # ffffffffc0297720 <free_area+0x10>
ffffffffc020105c:	8082                	ret

ffffffffc020105e <default_check>:

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1)
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void)
{
ffffffffc020105e:	711d                	addi	sp,sp,-96
ffffffffc0201060:	e0ca                	sd	s2,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0201062:	00096917          	auipc	s2,0x96
ffffffffc0201066:	6ae90913          	addi	s2,s2,1710 # ffffffffc0297710 <free_area>
ffffffffc020106a:	00893783          	ld	a5,8(s2)
ffffffffc020106e:	ec86                	sd	ra,88(sp)
ffffffffc0201070:	e8a2                	sd	s0,80(sp)
ffffffffc0201072:	e4a6                	sd	s1,72(sp)
ffffffffc0201074:	fc4e                	sd	s3,56(sp)
ffffffffc0201076:	f852                	sd	s4,48(sp)
ffffffffc0201078:	f456                	sd	s5,40(sp)
ffffffffc020107a:	f05a                	sd	s6,32(sp)
ffffffffc020107c:	ec5e                	sd	s7,24(sp)
ffffffffc020107e:	e862                	sd	s8,16(sp)
ffffffffc0201080:	e466                	sd	s9,8(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0201082:	2f278363          	beq	a5,s2,ffffffffc0201368 <default_check+0x30a>
    int count = 0, total = 0;
ffffffffc0201086:	4401                	li	s0,0
ffffffffc0201088:	4481                	li	s1,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc020108a:	ff07b703          	ld	a4,-16(a5)
    {
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc020108e:	8b09                	andi	a4,a4,2
ffffffffc0201090:	2e070063          	beqz	a4,ffffffffc0201370 <default_check+0x312>
        count++, total += p->property;
ffffffffc0201094:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201098:	679c                	ld	a5,8(a5)
ffffffffc020109a:	2485                	addiw	s1,s1,1
ffffffffc020109c:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc020109e:	ff2796e3          	bne	a5,s2,ffffffffc020108a <default_check+0x2c>
    }
    assert(total == nr_free_pages());
ffffffffc02010a2:	89a2                	mv	s3,s0
ffffffffc02010a4:	743000ef          	jal	ffffffffc0201fe6 <nr_free_pages>
ffffffffc02010a8:	73351463          	bne	a0,s3,ffffffffc02017d0 <default_check+0x772>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02010ac:	4505                	li	a0,1
ffffffffc02010ae:	6c7000ef          	jal	ffffffffc0201f74 <alloc_pages>
ffffffffc02010b2:	8a2a                	mv	s4,a0
ffffffffc02010b4:	44050e63          	beqz	a0,ffffffffc0201510 <default_check+0x4b2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02010b8:	4505                	li	a0,1
ffffffffc02010ba:	6bb000ef          	jal	ffffffffc0201f74 <alloc_pages>
ffffffffc02010be:	89aa                	mv	s3,a0
ffffffffc02010c0:	72050863          	beqz	a0,ffffffffc02017f0 <default_check+0x792>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02010c4:	4505                	li	a0,1
ffffffffc02010c6:	6af000ef          	jal	ffffffffc0201f74 <alloc_pages>
ffffffffc02010ca:	8aaa                	mv	s5,a0
ffffffffc02010cc:	4c050263          	beqz	a0,ffffffffc0201590 <default_check+0x532>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02010d0:	40a987b3          	sub	a5,s3,a0
ffffffffc02010d4:	40aa0733          	sub	a4,s4,a0
ffffffffc02010d8:	0017b793          	seqz	a5,a5
ffffffffc02010dc:	00173713          	seqz	a4,a4
ffffffffc02010e0:	8fd9                	or	a5,a5,a4
ffffffffc02010e2:	30079763          	bnez	a5,ffffffffc02013f0 <default_check+0x392>
ffffffffc02010e6:	313a0563          	beq	s4,s3,ffffffffc02013f0 <default_check+0x392>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc02010ea:	000a2783          	lw	a5,0(s4)
ffffffffc02010ee:	2a079163          	bnez	a5,ffffffffc0201390 <default_check+0x332>
ffffffffc02010f2:	0009a783          	lw	a5,0(s3)
ffffffffc02010f6:	28079d63          	bnez	a5,ffffffffc0201390 <default_check+0x332>
ffffffffc02010fa:	411c                	lw	a5,0(a0)
ffffffffc02010fc:	28079a63          	bnez	a5,ffffffffc0201390 <default_check+0x332>
extern uint_t va_pa_offset;

static inline ppn_t
page2ppn(struct Page *page)
{
    return page - pages + nbase;
ffffffffc0201100:	0009a797          	auipc	a5,0x9a
ffffffffc0201104:	6907b783          	ld	a5,1680(a5) # ffffffffc029b790 <pages>
ffffffffc0201108:	00007617          	auipc	a2,0x7
ffffffffc020110c:	a5063603          	ld	a2,-1456(a2) # ffffffffc0207b58 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201110:	0009a697          	auipc	a3,0x9a
ffffffffc0201114:	6786b683          	ld	a3,1656(a3) # ffffffffc029b788 <npage>
ffffffffc0201118:	40fa0733          	sub	a4,s4,a5
ffffffffc020111c:	8719                	srai	a4,a4,0x6
ffffffffc020111e:	9732                	add	a4,a4,a2
}

static inline uintptr_t
page2pa(struct Page *page)
{
    return page2ppn(page) << PGSHIFT;
ffffffffc0201120:	0732                	slli	a4,a4,0xc
ffffffffc0201122:	06b2                	slli	a3,a3,0xc
ffffffffc0201124:	2ad77663          	bgeu	a4,a3,ffffffffc02013d0 <default_check+0x372>
    return page - pages + nbase;
ffffffffc0201128:	40f98733          	sub	a4,s3,a5
ffffffffc020112c:	8719                	srai	a4,a4,0x6
ffffffffc020112e:	9732                	add	a4,a4,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0201130:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201132:	4cd77f63          	bgeu	a4,a3,ffffffffc0201610 <default_check+0x5b2>
    return page - pages + nbase;
ffffffffc0201136:	40f507b3          	sub	a5,a0,a5
ffffffffc020113a:	8799                	srai	a5,a5,0x6
ffffffffc020113c:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc020113e:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201140:	32d7f863          	bgeu	a5,a3,ffffffffc0201470 <default_check+0x412>
    assert(alloc_page() == NULL);
ffffffffc0201144:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0201146:	00093c03          	ld	s8,0(s2)
ffffffffc020114a:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc020114e:	00096b17          	auipc	s6,0x96
ffffffffc0201152:	5d2b2b03          	lw	s6,1490(s6) # ffffffffc0297720 <free_area+0x10>
    elm->prev = elm->next = elm;
ffffffffc0201156:	01293023          	sd	s2,0(s2)
ffffffffc020115a:	01293423          	sd	s2,8(s2)
    nr_free = 0;
ffffffffc020115e:	00096797          	auipc	a5,0x96
ffffffffc0201162:	5c07a123          	sw	zero,1474(a5) # ffffffffc0297720 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0201166:	60f000ef          	jal	ffffffffc0201f74 <alloc_pages>
ffffffffc020116a:	2e051363          	bnez	a0,ffffffffc0201450 <default_check+0x3f2>
    free_page(p0);
ffffffffc020116e:	8552                	mv	a0,s4
ffffffffc0201170:	4585                	li	a1,1
ffffffffc0201172:	63d000ef          	jal	ffffffffc0201fae <free_pages>
    free_page(p1);
ffffffffc0201176:	854e                	mv	a0,s3
ffffffffc0201178:	4585                	li	a1,1
ffffffffc020117a:	635000ef          	jal	ffffffffc0201fae <free_pages>
    free_page(p2);
ffffffffc020117e:	8556                	mv	a0,s5
ffffffffc0201180:	4585                	li	a1,1
ffffffffc0201182:	62d000ef          	jal	ffffffffc0201fae <free_pages>
    assert(nr_free == 3);
ffffffffc0201186:	00096717          	auipc	a4,0x96
ffffffffc020118a:	59a72703          	lw	a4,1434(a4) # ffffffffc0297720 <free_area+0x10>
ffffffffc020118e:	478d                	li	a5,3
ffffffffc0201190:	2af71063          	bne	a4,a5,ffffffffc0201430 <default_check+0x3d2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201194:	4505                	li	a0,1
ffffffffc0201196:	5df000ef          	jal	ffffffffc0201f74 <alloc_pages>
ffffffffc020119a:	89aa                	mv	s3,a0
ffffffffc020119c:	26050a63          	beqz	a0,ffffffffc0201410 <default_check+0x3b2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02011a0:	4505                	li	a0,1
ffffffffc02011a2:	5d3000ef          	jal	ffffffffc0201f74 <alloc_pages>
ffffffffc02011a6:	8aaa                	mv	s5,a0
ffffffffc02011a8:	3c050463          	beqz	a0,ffffffffc0201570 <default_check+0x512>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02011ac:	4505                	li	a0,1
ffffffffc02011ae:	5c7000ef          	jal	ffffffffc0201f74 <alloc_pages>
ffffffffc02011b2:	8a2a                	mv	s4,a0
ffffffffc02011b4:	38050e63          	beqz	a0,ffffffffc0201550 <default_check+0x4f2>
    assert(alloc_page() == NULL);
ffffffffc02011b8:	4505                	li	a0,1
ffffffffc02011ba:	5bb000ef          	jal	ffffffffc0201f74 <alloc_pages>
ffffffffc02011be:	36051963          	bnez	a0,ffffffffc0201530 <default_check+0x4d2>
    free_page(p0);
ffffffffc02011c2:	4585                	li	a1,1
ffffffffc02011c4:	854e                	mv	a0,s3
ffffffffc02011c6:	5e9000ef          	jal	ffffffffc0201fae <free_pages>
    assert(!list_empty(&free_list));
ffffffffc02011ca:	00893783          	ld	a5,8(s2)
ffffffffc02011ce:	1f278163          	beq	a5,s2,ffffffffc02013b0 <default_check+0x352>
    assert((p = alloc_page()) == p0);
ffffffffc02011d2:	4505                	li	a0,1
ffffffffc02011d4:	5a1000ef          	jal	ffffffffc0201f74 <alloc_pages>
ffffffffc02011d8:	8caa                	mv	s9,a0
ffffffffc02011da:	30a99b63          	bne	s3,a0,ffffffffc02014f0 <default_check+0x492>
    assert(alloc_page() == NULL);
ffffffffc02011de:	4505                	li	a0,1
ffffffffc02011e0:	595000ef          	jal	ffffffffc0201f74 <alloc_pages>
ffffffffc02011e4:	2e051663          	bnez	a0,ffffffffc02014d0 <default_check+0x472>
    assert(nr_free == 0);
ffffffffc02011e8:	00096797          	auipc	a5,0x96
ffffffffc02011ec:	5387a783          	lw	a5,1336(a5) # ffffffffc0297720 <free_area+0x10>
ffffffffc02011f0:	2c079063          	bnez	a5,ffffffffc02014b0 <default_check+0x452>
    free_page(p);
ffffffffc02011f4:	8566                	mv	a0,s9
ffffffffc02011f6:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc02011f8:	01893023          	sd	s8,0(s2)
ffffffffc02011fc:	01793423          	sd	s7,8(s2)
    nr_free = nr_free_store;
ffffffffc0201200:	01692823          	sw	s6,16(s2)
    free_page(p);
ffffffffc0201204:	5ab000ef          	jal	ffffffffc0201fae <free_pages>
    free_page(p1);
ffffffffc0201208:	8556                	mv	a0,s5
ffffffffc020120a:	4585                	li	a1,1
ffffffffc020120c:	5a3000ef          	jal	ffffffffc0201fae <free_pages>
    free_page(p2);
ffffffffc0201210:	8552                	mv	a0,s4
ffffffffc0201212:	4585                	li	a1,1
ffffffffc0201214:	59b000ef          	jal	ffffffffc0201fae <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0201218:	4515                	li	a0,5
ffffffffc020121a:	55b000ef          	jal	ffffffffc0201f74 <alloc_pages>
ffffffffc020121e:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0201220:	26050863          	beqz	a0,ffffffffc0201490 <default_check+0x432>
ffffffffc0201224:	651c                	ld	a5,8(a0)
    assert(!PageProperty(p0));
ffffffffc0201226:	8b89                	andi	a5,a5,2
ffffffffc0201228:	54079463          	bnez	a5,ffffffffc0201770 <default_check+0x712>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc020122c:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc020122e:	00093b83          	ld	s7,0(s2)
ffffffffc0201232:	00893b03          	ld	s6,8(s2)
ffffffffc0201236:	01293023          	sd	s2,0(s2)
ffffffffc020123a:	01293423          	sd	s2,8(s2)
    assert(alloc_page() == NULL);
ffffffffc020123e:	537000ef          	jal	ffffffffc0201f74 <alloc_pages>
ffffffffc0201242:	50051763          	bnez	a0,ffffffffc0201750 <default_check+0x6f2>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0201246:	08098a13          	addi	s4,s3,128
ffffffffc020124a:	8552                	mv	a0,s4
ffffffffc020124c:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc020124e:	00096c17          	auipc	s8,0x96
ffffffffc0201252:	4d2c2c03          	lw	s8,1234(s8) # ffffffffc0297720 <free_area+0x10>
    nr_free = 0;
ffffffffc0201256:	00096797          	auipc	a5,0x96
ffffffffc020125a:	4c07a523          	sw	zero,1226(a5) # ffffffffc0297720 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc020125e:	551000ef          	jal	ffffffffc0201fae <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0201262:	4511                	li	a0,4
ffffffffc0201264:	511000ef          	jal	ffffffffc0201f74 <alloc_pages>
ffffffffc0201268:	4c051463          	bnez	a0,ffffffffc0201730 <default_check+0x6d2>
ffffffffc020126c:	0889b783          	ld	a5,136(s3)
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201270:	8b89                	andi	a5,a5,2
ffffffffc0201272:	48078f63          	beqz	a5,ffffffffc0201710 <default_check+0x6b2>
ffffffffc0201276:	0909a503          	lw	a0,144(s3)
ffffffffc020127a:	478d                	li	a5,3
ffffffffc020127c:	48f51a63          	bne	a0,a5,ffffffffc0201710 <default_check+0x6b2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201280:	4f5000ef          	jal	ffffffffc0201f74 <alloc_pages>
ffffffffc0201284:	8aaa                	mv	s5,a0
ffffffffc0201286:	46050563          	beqz	a0,ffffffffc02016f0 <default_check+0x692>
    assert(alloc_page() == NULL);
ffffffffc020128a:	4505                	li	a0,1
ffffffffc020128c:	4e9000ef          	jal	ffffffffc0201f74 <alloc_pages>
ffffffffc0201290:	44051063          	bnez	a0,ffffffffc02016d0 <default_check+0x672>
    assert(p0 + 2 == p1);
ffffffffc0201294:	415a1e63          	bne	s4,s5,ffffffffc02016b0 <default_check+0x652>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0201298:	4585                	li	a1,1
ffffffffc020129a:	854e                	mv	a0,s3
ffffffffc020129c:	513000ef          	jal	ffffffffc0201fae <free_pages>
    free_pages(p1, 3);
ffffffffc02012a0:	8552                	mv	a0,s4
ffffffffc02012a2:	458d                	li	a1,3
ffffffffc02012a4:	50b000ef          	jal	ffffffffc0201fae <free_pages>
ffffffffc02012a8:	0089b783          	ld	a5,8(s3)
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc02012ac:	8b89                	andi	a5,a5,2
ffffffffc02012ae:	3e078163          	beqz	a5,ffffffffc0201690 <default_check+0x632>
ffffffffc02012b2:	0109aa83          	lw	s5,16(s3)
ffffffffc02012b6:	4785                	li	a5,1
ffffffffc02012b8:	3cfa9c63          	bne	s5,a5,ffffffffc0201690 <default_check+0x632>
ffffffffc02012bc:	008a3783          	ld	a5,8(s4)
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc02012c0:	8b89                	andi	a5,a5,2
ffffffffc02012c2:	3a078763          	beqz	a5,ffffffffc0201670 <default_check+0x612>
ffffffffc02012c6:	010a2703          	lw	a4,16(s4)
ffffffffc02012ca:	478d                	li	a5,3
ffffffffc02012cc:	3af71263          	bne	a4,a5,ffffffffc0201670 <default_check+0x612>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02012d0:	8556                	mv	a0,s5
ffffffffc02012d2:	4a3000ef          	jal	ffffffffc0201f74 <alloc_pages>
ffffffffc02012d6:	36a99d63          	bne	s3,a0,ffffffffc0201650 <default_check+0x5f2>
    free_page(p0);
ffffffffc02012da:	85d6                	mv	a1,s5
ffffffffc02012dc:	4d3000ef          	jal	ffffffffc0201fae <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02012e0:	4509                	li	a0,2
ffffffffc02012e2:	493000ef          	jal	ffffffffc0201f74 <alloc_pages>
ffffffffc02012e6:	34aa1563          	bne	s4,a0,ffffffffc0201630 <default_check+0x5d2>

    free_pages(p0, 2);
ffffffffc02012ea:	4589                	li	a1,2
ffffffffc02012ec:	4c3000ef          	jal	ffffffffc0201fae <free_pages>
    free_page(p2);
ffffffffc02012f0:	04098513          	addi	a0,s3,64
ffffffffc02012f4:	85d6                	mv	a1,s5
ffffffffc02012f6:	4b9000ef          	jal	ffffffffc0201fae <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc02012fa:	4515                	li	a0,5
ffffffffc02012fc:	479000ef          	jal	ffffffffc0201f74 <alloc_pages>
ffffffffc0201300:	89aa                	mv	s3,a0
ffffffffc0201302:	48050763          	beqz	a0,ffffffffc0201790 <default_check+0x732>
    assert(alloc_page() == NULL);
ffffffffc0201306:	8556                	mv	a0,s5
ffffffffc0201308:	46d000ef          	jal	ffffffffc0201f74 <alloc_pages>
ffffffffc020130c:	2e051263          	bnez	a0,ffffffffc02015f0 <default_check+0x592>

    assert(nr_free == 0);
ffffffffc0201310:	00096797          	auipc	a5,0x96
ffffffffc0201314:	4107a783          	lw	a5,1040(a5) # ffffffffc0297720 <free_area+0x10>
ffffffffc0201318:	2a079c63          	bnez	a5,ffffffffc02015d0 <default_check+0x572>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc020131c:	854e                	mv	a0,s3
ffffffffc020131e:	4595                	li	a1,5
    nr_free = nr_free_store;
ffffffffc0201320:	01892823          	sw	s8,16(s2)
    free_list = free_list_store;
ffffffffc0201324:	01793023          	sd	s7,0(s2)
ffffffffc0201328:	01693423          	sd	s6,8(s2)
    free_pages(p0, 5);
ffffffffc020132c:	483000ef          	jal	ffffffffc0201fae <free_pages>
    return listelm->next;
ffffffffc0201330:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list)
ffffffffc0201334:	01278963          	beq	a5,s2,ffffffffc0201346 <default_check+0x2e8>
    {
        struct Page *p = le2page(le, page_link);
        count--, total -= p->property;
ffffffffc0201338:	ff87a703          	lw	a4,-8(a5)
ffffffffc020133c:	679c                	ld	a5,8(a5)
ffffffffc020133e:	34fd                	addiw	s1,s1,-1
ffffffffc0201340:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list)
ffffffffc0201342:	ff279be3          	bne	a5,s2,ffffffffc0201338 <default_check+0x2da>
    }
    assert(count == 0);
ffffffffc0201346:	26049563          	bnez	s1,ffffffffc02015b0 <default_check+0x552>
    assert(total == 0);
ffffffffc020134a:	46041363          	bnez	s0,ffffffffc02017b0 <default_check+0x752>
}
ffffffffc020134e:	60e6                	ld	ra,88(sp)
ffffffffc0201350:	6446                	ld	s0,80(sp)
ffffffffc0201352:	64a6                	ld	s1,72(sp)
ffffffffc0201354:	6906                	ld	s2,64(sp)
ffffffffc0201356:	79e2                	ld	s3,56(sp)
ffffffffc0201358:	7a42                	ld	s4,48(sp)
ffffffffc020135a:	7aa2                	ld	s5,40(sp)
ffffffffc020135c:	7b02                	ld	s6,32(sp)
ffffffffc020135e:	6be2                	ld	s7,24(sp)
ffffffffc0201360:	6c42                	ld	s8,16(sp)
ffffffffc0201362:	6ca2                	ld	s9,8(sp)
ffffffffc0201364:	6125                	addi	sp,sp,96
ffffffffc0201366:	8082                	ret
    while ((le = list_next(le)) != &free_list)
ffffffffc0201368:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc020136a:	4401                	li	s0,0
ffffffffc020136c:	4481                	li	s1,0
ffffffffc020136e:	bb1d                	j	ffffffffc02010a4 <default_check+0x46>
        assert(PageProperty(p));
ffffffffc0201370:	00005697          	auipc	a3,0x5
ffffffffc0201374:	ff868693          	addi	a3,a3,-8 # ffffffffc0206368 <etext+0x9ea>
ffffffffc0201378:	00005617          	auipc	a2,0x5
ffffffffc020137c:	00060613          	mv	a2,a2
ffffffffc0201380:	11000593          	li	a1,272
ffffffffc0201384:	00005517          	auipc	a0,0x5
ffffffffc0201388:	00c50513          	addi	a0,a0,12 # ffffffffc0206390 <etext+0xa12>
ffffffffc020138c:	8baff0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201390:	00005697          	auipc	a3,0x5
ffffffffc0201394:	0c068693          	addi	a3,a3,192 # ffffffffc0206450 <etext+0xad2>
ffffffffc0201398:	00005617          	auipc	a2,0x5
ffffffffc020139c:	fe060613          	addi	a2,a2,-32 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02013a0:	0dc00593          	li	a1,220
ffffffffc02013a4:	00005517          	auipc	a0,0x5
ffffffffc02013a8:	fec50513          	addi	a0,a0,-20 # ffffffffc0206390 <etext+0xa12>
ffffffffc02013ac:	89aff0ef          	jal	ffffffffc0200446 <__panic>
    assert(!list_empty(&free_list));
ffffffffc02013b0:	00005697          	auipc	a3,0x5
ffffffffc02013b4:	16868693          	addi	a3,a3,360 # ffffffffc0206518 <etext+0xb9a>
ffffffffc02013b8:	00005617          	auipc	a2,0x5
ffffffffc02013bc:	fc060613          	addi	a2,a2,-64 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02013c0:	0f700593          	li	a1,247
ffffffffc02013c4:	00005517          	auipc	a0,0x5
ffffffffc02013c8:	fcc50513          	addi	a0,a0,-52 # ffffffffc0206390 <etext+0xa12>
ffffffffc02013cc:	87aff0ef          	jal	ffffffffc0200446 <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc02013d0:	00005697          	auipc	a3,0x5
ffffffffc02013d4:	0c068693          	addi	a3,a3,192 # ffffffffc0206490 <etext+0xb12>
ffffffffc02013d8:	00005617          	auipc	a2,0x5
ffffffffc02013dc:	fa060613          	addi	a2,a2,-96 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02013e0:	0de00593          	li	a1,222
ffffffffc02013e4:	00005517          	auipc	a0,0x5
ffffffffc02013e8:	fac50513          	addi	a0,a0,-84 # ffffffffc0206390 <etext+0xa12>
ffffffffc02013ec:	85aff0ef          	jal	ffffffffc0200446 <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc02013f0:	00005697          	auipc	a3,0x5
ffffffffc02013f4:	03868693          	addi	a3,a3,56 # ffffffffc0206428 <etext+0xaaa>
ffffffffc02013f8:	00005617          	auipc	a2,0x5
ffffffffc02013fc:	f8060613          	addi	a2,a2,-128 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201400:	0db00593          	li	a1,219
ffffffffc0201404:	00005517          	auipc	a0,0x5
ffffffffc0201408:	f8c50513          	addi	a0,a0,-116 # ffffffffc0206390 <etext+0xa12>
ffffffffc020140c:	83aff0ef          	jal	ffffffffc0200446 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201410:	00005697          	auipc	a3,0x5
ffffffffc0201414:	fb868693          	addi	a3,a3,-72 # ffffffffc02063c8 <etext+0xa4a>
ffffffffc0201418:	00005617          	auipc	a2,0x5
ffffffffc020141c:	f6060613          	addi	a2,a2,-160 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201420:	0f000593          	li	a1,240
ffffffffc0201424:	00005517          	auipc	a0,0x5
ffffffffc0201428:	f6c50513          	addi	a0,a0,-148 # ffffffffc0206390 <etext+0xa12>
ffffffffc020142c:	81aff0ef          	jal	ffffffffc0200446 <__panic>
    assert(nr_free == 3);
ffffffffc0201430:	00005697          	auipc	a3,0x5
ffffffffc0201434:	0d868693          	addi	a3,a3,216 # ffffffffc0206508 <etext+0xb8a>
ffffffffc0201438:	00005617          	auipc	a2,0x5
ffffffffc020143c:	f4060613          	addi	a2,a2,-192 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201440:	0ee00593          	li	a1,238
ffffffffc0201444:	00005517          	auipc	a0,0x5
ffffffffc0201448:	f4c50513          	addi	a0,a0,-180 # ffffffffc0206390 <etext+0xa12>
ffffffffc020144c:	ffbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201450:	00005697          	auipc	a3,0x5
ffffffffc0201454:	0a068693          	addi	a3,a3,160 # ffffffffc02064f0 <etext+0xb72>
ffffffffc0201458:	00005617          	auipc	a2,0x5
ffffffffc020145c:	f2060613          	addi	a2,a2,-224 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201460:	0e900593          	li	a1,233
ffffffffc0201464:	00005517          	auipc	a0,0x5
ffffffffc0201468:	f2c50513          	addi	a0,a0,-212 # ffffffffc0206390 <etext+0xa12>
ffffffffc020146c:	fdbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201470:	00005697          	auipc	a3,0x5
ffffffffc0201474:	06068693          	addi	a3,a3,96 # ffffffffc02064d0 <etext+0xb52>
ffffffffc0201478:	00005617          	auipc	a2,0x5
ffffffffc020147c:	f0060613          	addi	a2,a2,-256 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201480:	0e000593          	li	a1,224
ffffffffc0201484:	00005517          	auipc	a0,0x5
ffffffffc0201488:	f0c50513          	addi	a0,a0,-244 # ffffffffc0206390 <etext+0xa12>
ffffffffc020148c:	fbbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(p0 != NULL);
ffffffffc0201490:	00005697          	auipc	a3,0x5
ffffffffc0201494:	0d068693          	addi	a3,a3,208 # ffffffffc0206560 <etext+0xbe2>
ffffffffc0201498:	00005617          	auipc	a2,0x5
ffffffffc020149c:	ee060613          	addi	a2,a2,-288 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02014a0:	11800593          	li	a1,280
ffffffffc02014a4:	00005517          	auipc	a0,0x5
ffffffffc02014a8:	eec50513          	addi	a0,a0,-276 # ffffffffc0206390 <etext+0xa12>
ffffffffc02014ac:	f9bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(nr_free == 0);
ffffffffc02014b0:	00005697          	auipc	a3,0x5
ffffffffc02014b4:	0a068693          	addi	a3,a3,160 # ffffffffc0206550 <etext+0xbd2>
ffffffffc02014b8:	00005617          	auipc	a2,0x5
ffffffffc02014bc:	ec060613          	addi	a2,a2,-320 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02014c0:	0fd00593          	li	a1,253
ffffffffc02014c4:	00005517          	auipc	a0,0x5
ffffffffc02014c8:	ecc50513          	addi	a0,a0,-308 # ffffffffc0206390 <etext+0xa12>
ffffffffc02014cc:	f7bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02014d0:	00005697          	auipc	a3,0x5
ffffffffc02014d4:	02068693          	addi	a3,a3,32 # ffffffffc02064f0 <etext+0xb72>
ffffffffc02014d8:	00005617          	auipc	a2,0x5
ffffffffc02014dc:	ea060613          	addi	a2,a2,-352 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02014e0:	0fb00593          	li	a1,251
ffffffffc02014e4:	00005517          	auipc	a0,0x5
ffffffffc02014e8:	eac50513          	addi	a0,a0,-340 # ffffffffc0206390 <etext+0xa12>
ffffffffc02014ec:	f5bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc02014f0:	00005697          	auipc	a3,0x5
ffffffffc02014f4:	04068693          	addi	a3,a3,64 # ffffffffc0206530 <etext+0xbb2>
ffffffffc02014f8:	00005617          	auipc	a2,0x5
ffffffffc02014fc:	e8060613          	addi	a2,a2,-384 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201500:	0fa00593          	li	a1,250
ffffffffc0201504:	00005517          	auipc	a0,0x5
ffffffffc0201508:	e8c50513          	addi	a0,a0,-372 # ffffffffc0206390 <etext+0xa12>
ffffffffc020150c:	f3bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0201510:	00005697          	auipc	a3,0x5
ffffffffc0201514:	eb868693          	addi	a3,a3,-328 # ffffffffc02063c8 <etext+0xa4a>
ffffffffc0201518:	00005617          	auipc	a2,0x5
ffffffffc020151c:	e6060613          	addi	a2,a2,-416 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201520:	0d700593          	li	a1,215
ffffffffc0201524:	00005517          	auipc	a0,0x5
ffffffffc0201528:	e6c50513          	addi	a0,a0,-404 # ffffffffc0206390 <etext+0xa12>
ffffffffc020152c:	f1bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201530:	00005697          	auipc	a3,0x5
ffffffffc0201534:	fc068693          	addi	a3,a3,-64 # ffffffffc02064f0 <etext+0xb72>
ffffffffc0201538:	00005617          	auipc	a2,0x5
ffffffffc020153c:	e4060613          	addi	a2,a2,-448 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201540:	0f400593          	li	a1,244
ffffffffc0201544:	00005517          	auipc	a0,0x5
ffffffffc0201548:	e4c50513          	addi	a0,a0,-436 # ffffffffc0206390 <etext+0xa12>
ffffffffc020154c:	efbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201550:	00005697          	auipc	a3,0x5
ffffffffc0201554:	eb868693          	addi	a3,a3,-328 # ffffffffc0206408 <etext+0xa8a>
ffffffffc0201558:	00005617          	auipc	a2,0x5
ffffffffc020155c:	e2060613          	addi	a2,a2,-480 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201560:	0f200593          	li	a1,242
ffffffffc0201564:	00005517          	auipc	a0,0x5
ffffffffc0201568:	e2c50513          	addi	a0,a0,-468 # ffffffffc0206390 <etext+0xa12>
ffffffffc020156c:	edbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201570:	00005697          	auipc	a3,0x5
ffffffffc0201574:	e7868693          	addi	a3,a3,-392 # ffffffffc02063e8 <etext+0xa6a>
ffffffffc0201578:	00005617          	auipc	a2,0x5
ffffffffc020157c:	e0060613          	addi	a2,a2,-512 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201580:	0f100593          	li	a1,241
ffffffffc0201584:	00005517          	auipc	a0,0x5
ffffffffc0201588:	e0c50513          	addi	a0,a0,-500 # ffffffffc0206390 <etext+0xa12>
ffffffffc020158c:	ebbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201590:	00005697          	auipc	a3,0x5
ffffffffc0201594:	e7868693          	addi	a3,a3,-392 # ffffffffc0206408 <etext+0xa8a>
ffffffffc0201598:	00005617          	auipc	a2,0x5
ffffffffc020159c:	de060613          	addi	a2,a2,-544 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02015a0:	0d900593          	li	a1,217
ffffffffc02015a4:	00005517          	auipc	a0,0x5
ffffffffc02015a8:	dec50513          	addi	a0,a0,-532 # ffffffffc0206390 <etext+0xa12>
ffffffffc02015ac:	e9bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(count == 0);
ffffffffc02015b0:	00005697          	auipc	a3,0x5
ffffffffc02015b4:	10068693          	addi	a3,a3,256 # ffffffffc02066b0 <etext+0xd32>
ffffffffc02015b8:	00005617          	auipc	a2,0x5
ffffffffc02015bc:	dc060613          	addi	a2,a2,-576 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02015c0:	14600593          	li	a1,326
ffffffffc02015c4:	00005517          	auipc	a0,0x5
ffffffffc02015c8:	dcc50513          	addi	a0,a0,-564 # ffffffffc0206390 <etext+0xa12>
ffffffffc02015cc:	e7bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(nr_free == 0);
ffffffffc02015d0:	00005697          	auipc	a3,0x5
ffffffffc02015d4:	f8068693          	addi	a3,a3,-128 # ffffffffc0206550 <etext+0xbd2>
ffffffffc02015d8:	00005617          	auipc	a2,0x5
ffffffffc02015dc:	da060613          	addi	a2,a2,-608 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02015e0:	13a00593          	li	a1,314
ffffffffc02015e4:	00005517          	auipc	a0,0x5
ffffffffc02015e8:	dac50513          	addi	a0,a0,-596 # ffffffffc0206390 <etext+0xa12>
ffffffffc02015ec:	e5bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02015f0:	00005697          	auipc	a3,0x5
ffffffffc02015f4:	f0068693          	addi	a3,a3,-256 # ffffffffc02064f0 <etext+0xb72>
ffffffffc02015f8:	00005617          	auipc	a2,0x5
ffffffffc02015fc:	d8060613          	addi	a2,a2,-640 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201600:	13800593          	li	a1,312
ffffffffc0201604:	00005517          	auipc	a0,0x5
ffffffffc0201608:	d8c50513          	addi	a0,a0,-628 # ffffffffc0206390 <etext+0xa12>
ffffffffc020160c:	e3bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0201610:	00005697          	auipc	a3,0x5
ffffffffc0201614:	ea068693          	addi	a3,a3,-352 # ffffffffc02064b0 <etext+0xb32>
ffffffffc0201618:	00005617          	auipc	a2,0x5
ffffffffc020161c:	d6060613          	addi	a2,a2,-672 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201620:	0df00593          	li	a1,223
ffffffffc0201624:	00005517          	auipc	a0,0x5
ffffffffc0201628:	d6c50513          	addi	a0,a0,-660 # ffffffffc0206390 <etext+0xa12>
ffffffffc020162c:	e1bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0201630:	00005697          	auipc	a3,0x5
ffffffffc0201634:	04068693          	addi	a3,a3,64 # ffffffffc0206670 <etext+0xcf2>
ffffffffc0201638:	00005617          	auipc	a2,0x5
ffffffffc020163c:	d4060613          	addi	a2,a2,-704 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201640:	13200593          	li	a1,306
ffffffffc0201644:	00005517          	auipc	a0,0x5
ffffffffc0201648:	d4c50513          	addi	a0,a0,-692 # ffffffffc0206390 <etext+0xa12>
ffffffffc020164c:	dfbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0201650:	00005697          	auipc	a3,0x5
ffffffffc0201654:	00068693          	mv	a3,a3
ffffffffc0201658:	00005617          	auipc	a2,0x5
ffffffffc020165c:	d2060613          	addi	a2,a2,-736 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201660:	13000593          	li	a1,304
ffffffffc0201664:	00005517          	auipc	a0,0x5
ffffffffc0201668:	d2c50513          	addi	a0,a0,-724 # ffffffffc0206390 <etext+0xa12>
ffffffffc020166c:	ddbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201670:	00005697          	auipc	a3,0x5
ffffffffc0201674:	fb868693          	addi	a3,a3,-72 # ffffffffc0206628 <etext+0xcaa>
ffffffffc0201678:	00005617          	auipc	a2,0x5
ffffffffc020167c:	d0060613          	addi	a2,a2,-768 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201680:	12e00593          	li	a1,302
ffffffffc0201684:	00005517          	auipc	a0,0x5
ffffffffc0201688:	d0c50513          	addi	a0,a0,-756 # ffffffffc0206390 <etext+0xa12>
ffffffffc020168c:	dbbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201690:	00005697          	auipc	a3,0x5
ffffffffc0201694:	f7068693          	addi	a3,a3,-144 # ffffffffc0206600 <etext+0xc82>
ffffffffc0201698:	00005617          	auipc	a2,0x5
ffffffffc020169c:	ce060613          	addi	a2,a2,-800 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02016a0:	12d00593          	li	a1,301
ffffffffc02016a4:	00005517          	auipc	a0,0x5
ffffffffc02016a8:	cec50513          	addi	a0,a0,-788 # ffffffffc0206390 <etext+0xa12>
ffffffffc02016ac:	d9bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(p0 + 2 == p1);
ffffffffc02016b0:	00005697          	auipc	a3,0x5
ffffffffc02016b4:	f4068693          	addi	a3,a3,-192 # ffffffffc02065f0 <etext+0xc72>
ffffffffc02016b8:	00005617          	auipc	a2,0x5
ffffffffc02016bc:	cc060613          	addi	a2,a2,-832 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02016c0:	12800593          	li	a1,296
ffffffffc02016c4:	00005517          	auipc	a0,0x5
ffffffffc02016c8:	ccc50513          	addi	a0,a0,-820 # ffffffffc0206390 <etext+0xa12>
ffffffffc02016cc:	d7bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc02016d0:	00005697          	auipc	a3,0x5
ffffffffc02016d4:	e2068693          	addi	a3,a3,-480 # ffffffffc02064f0 <etext+0xb72>
ffffffffc02016d8:	00005617          	auipc	a2,0x5
ffffffffc02016dc:	ca060613          	addi	a2,a2,-864 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02016e0:	12700593          	li	a1,295
ffffffffc02016e4:	00005517          	auipc	a0,0x5
ffffffffc02016e8:	cac50513          	addi	a0,a0,-852 # ffffffffc0206390 <etext+0xa12>
ffffffffc02016ec:	d5bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc02016f0:	00005697          	auipc	a3,0x5
ffffffffc02016f4:	ee068693          	addi	a3,a3,-288 # ffffffffc02065d0 <etext+0xc52>
ffffffffc02016f8:	00005617          	auipc	a2,0x5
ffffffffc02016fc:	c8060613          	addi	a2,a2,-896 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201700:	12600593          	li	a1,294
ffffffffc0201704:	00005517          	auipc	a0,0x5
ffffffffc0201708:	c8c50513          	addi	a0,a0,-884 # ffffffffc0206390 <etext+0xa12>
ffffffffc020170c:	d3bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0201710:	00005697          	auipc	a3,0x5
ffffffffc0201714:	e9068693          	addi	a3,a3,-368 # ffffffffc02065a0 <etext+0xc22>
ffffffffc0201718:	00005617          	auipc	a2,0x5
ffffffffc020171c:	c6060613          	addi	a2,a2,-928 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201720:	12500593          	li	a1,293
ffffffffc0201724:	00005517          	auipc	a0,0x5
ffffffffc0201728:	c6c50513          	addi	a0,a0,-916 # ffffffffc0206390 <etext+0xa12>
ffffffffc020172c:	d1bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc0201730:	00005697          	auipc	a3,0x5
ffffffffc0201734:	e5868693          	addi	a3,a3,-424 # ffffffffc0206588 <etext+0xc0a>
ffffffffc0201738:	00005617          	auipc	a2,0x5
ffffffffc020173c:	c4060613          	addi	a2,a2,-960 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201740:	12400593          	li	a1,292
ffffffffc0201744:	00005517          	auipc	a0,0x5
ffffffffc0201748:	c4c50513          	addi	a0,a0,-948 # ffffffffc0206390 <etext+0xa12>
ffffffffc020174c:	cfbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201750:	00005697          	auipc	a3,0x5
ffffffffc0201754:	da068693          	addi	a3,a3,-608 # ffffffffc02064f0 <etext+0xb72>
ffffffffc0201758:	00005617          	auipc	a2,0x5
ffffffffc020175c:	c2060613          	addi	a2,a2,-992 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201760:	11e00593          	li	a1,286
ffffffffc0201764:	00005517          	auipc	a0,0x5
ffffffffc0201768:	c2c50513          	addi	a0,a0,-980 # ffffffffc0206390 <etext+0xa12>
ffffffffc020176c:	cdbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(!PageProperty(p0));
ffffffffc0201770:	00005697          	auipc	a3,0x5
ffffffffc0201774:	e0068693          	addi	a3,a3,-512 # ffffffffc0206570 <etext+0xbf2>
ffffffffc0201778:	00005617          	auipc	a2,0x5
ffffffffc020177c:	c0060613          	addi	a2,a2,-1024 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201780:	11900593          	li	a1,281
ffffffffc0201784:	00005517          	auipc	a0,0x5
ffffffffc0201788:	c0c50513          	addi	a0,a0,-1012 # ffffffffc0206390 <etext+0xa12>
ffffffffc020178c:	cbbfe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201790:	00005697          	auipc	a3,0x5
ffffffffc0201794:	f0068693          	addi	a3,a3,-256 # ffffffffc0206690 <etext+0xd12>
ffffffffc0201798:	00005617          	auipc	a2,0x5
ffffffffc020179c:	be060613          	addi	a2,a2,-1056 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02017a0:	13700593          	li	a1,311
ffffffffc02017a4:	00005517          	auipc	a0,0x5
ffffffffc02017a8:	bec50513          	addi	a0,a0,-1044 # ffffffffc0206390 <etext+0xa12>
ffffffffc02017ac:	c9bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(total == 0);
ffffffffc02017b0:	00005697          	auipc	a3,0x5
ffffffffc02017b4:	f1068693          	addi	a3,a3,-240 # ffffffffc02066c0 <etext+0xd42>
ffffffffc02017b8:	00005617          	auipc	a2,0x5
ffffffffc02017bc:	bc060613          	addi	a2,a2,-1088 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02017c0:	14700593          	li	a1,327
ffffffffc02017c4:	00005517          	auipc	a0,0x5
ffffffffc02017c8:	bcc50513          	addi	a0,a0,-1076 # ffffffffc0206390 <etext+0xa12>
ffffffffc02017cc:	c7bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(total == nr_free_pages());
ffffffffc02017d0:	00005697          	auipc	a3,0x5
ffffffffc02017d4:	bd868693          	addi	a3,a3,-1064 # ffffffffc02063a8 <etext+0xa2a>
ffffffffc02017d8:	00005617          	auipc	a2,0x5
ffffffffc02017dc:	ba060613          	addi	a2,a2,-1120 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02017e0:	11300593          	li	a1,275
ffffffffc02017e4:	00005517          	auipc	a0,0x5
ffffffffc02017e8:	bac50513          	addi	a0,a0,-1108 # ffffffffc0206390 <etext+0xa12>
ffffffffc02017ec:	c5bfe0ef          	jal	ffffffffc0200446 <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc02017f0:	00005697          	auipc	a3,0x5
ffffffffc02017f4:	bf868693          	addi	a3,a3,-1032 # ffffffffc02063e8 <etext+0xa6a>
ffffffffc02017f8:	00005617          	auipc	a2,0x5
ffffffffc02017fc:	b8060613          	addi	a2,a2,-1152 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201800:	0d800593          	li	a1,216
ffffffffc0201804:	00005517          	auipc	a0,0x5
ffffffffc0201808:	b8c50513          	addi	a0,a0,-1140 # ffffffffc0206390 <etext+0xa12>
ffffffffc020180c:	c3bfe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0201810 <default_free_pages>:
{
ffffffffc0201810:	1141                	addi	sp,sp,-16
ffffffffc0201812:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201814:	14058663          	beqz	a1,ffffffffc0201960 <default_free_pages+0x150>
    for (; p != base + n; p++)
ffffffffc0201818:	00659713          	slli	a4,a1,0x6
ffffffffc020181c:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc0201820:	87aa                	mv	a5,a0
    for (; p != base + n; p++)
ffffffffc0201822:	c30d                	beqz	a4,ffffffffc0201844 <default_free_pages+0x34>
ffffffffc0201824:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201826:	8b05                	andi	a4,a4,1
ffffffffc0201828:	10071c63          	bnez	a4,ffffffffc0201940 <default_free_pages+0x130>
ffffffffc020182c:	6798                	ld	a4,8(a5)
ffffffffc020182e:	8b09                	andi	a4,a4,2
ffffffffc0201830:	10071863          	bnez	a4,ffffffffc0201940 <default_free_pages+0x130>
        p->flags = 0;
ffffffffc0201834:	0007b423          	sd	zero,8(a5)
}

static inline void
set_page_ref(struct Page *page, int val)
{
    page->ref = val;
ffffffffc0201838:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc020183c:	04078793          	addi	a5,a5,64
ffffffffc0201840:	fed792e3          	bne	a5,a3,ffffffffc0201824 <default_free_pages+0x14>
    base->property = n;
ffffffffc0201844:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc0201846:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020184a:	4789                	li	a5,2
ffffffffc020184c:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc0201850:	00096717          	auipc	a4,0x96
ffffffffc0201854:	ed072703          	lw	a4,-304(a4) # ffffffffc0297720 <free_area+0x10>
ffffffffc0201858:	00096697          	auipc	a3,0x96
ffffffffc020185c:	eb868693          	addi	a3,a3,-328 # ffffffffc0297710 <free_area>
    return list->next == list;
ffffffffc0201860:	669c                	ld	a5,8(a3)
ffffffffc0201862:	9f2d                	addw	a4,a4,a1
ffffffffc0201864:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list))
ffffffffc0201866:	0ad78163          	beq	a5,a3,ffffffffc0201908 <default_free_pages+0xf8>
            struct Page *page = le2page(le, page_link);
ffffffffc020186a:	fe878713          	addi	a4,a5,-24
ffffffffc020186e:	4581                	li	a1,0
ffffffffc0201870:	01850613          	addi	a2,a0,24
            if (base < page)
ffffffffc0201874:	00e56a63          	bltu	a0,a4,ffffffffc0201888 <default_free_pages+0x78>
    return listelm->next;
ffffffffc0201878:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc020187a:	04d70c63          	beq	a4,a3,ffffffffc02018d2 <default_free_pages+0xc2>
    struct Page *p = base;
ffffffffc020187e:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0201880:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0201884:	fee57ae3          	bgeu	a0,a4,ffffffffc0201878 <default_free_pages+0x68>
ffffffffc0201888:	c199                	beqz	a1,ffffffffc020188e <default_free_pages+0x7e>
ffffffffc020188a:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020188e:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc0201890:	e390                	sd	a2,0(a5)
ffffffffc0201892:	e710                	sd	a2,8(a4)
    elm->next = next;
    elm->prev = prev;
ffffffffc0201894:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc0201896:	f11c                	sd	a5,32(a0)
    if (le != &free_list)
ffffffffc0201898:	00d70d63          	beq	a4,a3,ffffffffc02018b2 <default_free_pages+0xa2>
        if (p + p->property == base)
ffffffffc020189c:	ff872583          	lw	a1,-8(a4)
        p = le2page(le, page_link);
ffffffffc02018a0:	fe870613          	addi	a2,a4,-24
        if (p + p->property == base)
ffffffffc02018a4:	02059813          	slli	a6,a1,0x20
ffffffffc02018a8:	01a85793          	srli	a5,a6,0x1a
ffffffffc02018ac:	97b2                	add	a5,a5,a2
ffffffffc02018ae:	02f50c63          	beq	a0,a5,ffffffffc02018e6 <default_free_pages+0xd6>
    return listelm->next;
ffffffffc02018b2:	711c                	ld	a5,32(a0)
    if (le != &free_list)
ffffffffc02018b4:	00d78c63          	beq	a5,a3,ffffffffc02018cc <default_free_pages+0xbc>
        if (base + base->property == p)
ffffffffc02018b8:	4910                	lw	a2,16(a0)
        p = le2page(le, page_link);
ffffffffc02018ba:	fe878693          	addi	a3,a5,-24
        if (base + base->property == p)
ffffffffc02018be:	02061593          	slli	a1,a2,0x20
ffffffffc02018c2:	01a5d713          	srli	a4,a1,0x1a
ffffffffc02018c6:	972a                	add	a4,a4,a0
ffffffffc02018c8:	04e68c63          	beq	a3,a4,ffffffffc0201920 <default_free_pages+0x110>
}
ffffffffc02018cc:	60a2                	ld	ra,8(sp)
ffffffffc02018ce:	0141                	addi	sp,sp,16
ffffffffc02018d0:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc02018d2:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc02018d4:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc02018d6:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc02018d8:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc02018da:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list)
ffffffffc02018dc:	02d70f63          	beq	a4,a3,ffffffffc020191a <default_free_pages+0x10a>
ffffffffc02018e0:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc02018e2:	87ba                	mv	a5,a4
ffffffffc02018e4:	bf71                	j	ffffffffc0201880 <default_free_pages+0x70>
            p->property += base->property;
ffffffffc02018e6:	491c                	lw	a5,16(a0)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02018e8:	5875                	li	a6,-3
ffffffffc02018ea:	9fad                	addw	a5,a5,a1
ffffffffc02018ec:	fef72c23          	sw	a5,-8(a4)
ffffffffc02018f0:	6108b02f          	amoand.d	zero,a6,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc02018f4:	01853803          	ld	a6,24(a0)
ffffffffc02018f8:	710c                	ld	a1,32(a0)
            base = p;
ffffffffc02018fa:	8532                	mv	a0,a2
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02018fc:	00b83423          	sd	a1,8(a6) # ff0008 <_binary_obj___user_exit_out_size+0xfe5e48>
    return listelm->next;
ffffffffc0201900:	671c                	ld	a5,8(a4)
    next->prev = prev;
ffffffffc0201902:	0105b023          	sd	a6,0(a1)
ffffffffc0201906:	b77d                	j	ffffffffc02018b4 <default_free_pages+0xa4>
}
ffffffffc0201908:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc020190a:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc020190e:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201910:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc0201912:	e398                	sd	a4,0(a5)
ffffffffc0201914:	e798                	sd	a4,8(a5)
}
ffffffffc0201916:	0141                	addi	sp,sp,16
ffffffffc0201918:	8082                	ret
ffffffffc020191a:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc020191c:	873e                	mv	a4,a5
ffffffffc020191e:	bfad                	j	ffffffffc0201898 <default_free_pages+0x88>
            base->property += p->property;
ffffffffc0201920:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201924:	56f5                	li	a3,-3
ffffffffc0201926:	9f31                	addw	a4,a4,a2
ffffffffc0201928:	c918                	sw	a4,16(a0)
ffffffffc020192a:	ff078713          	addi	a4,a5,-16
ffffffffc020192e:	60d7302f          	amoand.d	zero,a3,(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201932:	6398                	ld	a4,0(a5)
ffffffffc0201934:	679c                	ld	a5,8(a5)
}
ffffffffc0201936:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc0201938:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020193a:	e398                	sd	a4,0(a5)
ffffffffc020193c:	0141                	addi	sp,sp,16
ffffffffc020193e:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc0201940:	00005697          	auipc	a3,0x5
ffffffffc0201944:	d9868693          	addi	a3,a3,-616 # ffffffffc02066d8 <etext+0xd5a>
ffffffffc0201948:	00005617          	auipc	a2,0x5
ffffffffc020194c:	a3060613          	addi	a2,a2,-1488 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201950:	09400593          	li	a1,148
ffffffffc0201954:	00005517          	auipc	a0,0x5
ffffffffc0201958:	a3c50513          	addi	a0,a0,-1476 # ffffffffc0206390 <etext+0xa12>
ffffffffc020195c:	aebfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(n > 0);
ffffffffc0201960:	00005697          	auipc	a3,0x5
ffffffffc0201964:	d7068693          	addi	a3,a3,-656 # ffffffffc02066d0 <etext+0xd52>
ffffffffc0201968:	00005617          	auipc	a2,0x5
ffffffffc020196c:	a1060613          	addi	a2,a2,-1520 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201970:	09000593          	li	a1,144
ffffffffc0201974:	00005517          	auipc	a0,0x5
ffffffffc0201978:	a1c50513          	addi	a0,a0,-1508 # ffffffffc0206390 <etext+0xa12>
ffffffffc020197c:	acbfe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0201980 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201980:	c951                	beqz	a0,ffffffffc0201a14 <default_alloc_pages+0x94>
    if (n > nr_free)
ffffffffc0201982:	00096597          	auipc	a1,0x96
ffffffffc0201986:	d9e5a583          	lw	a1,-610(a1) # ffffffffc0297720 <free_area+0x10>
ffffffffc020198a:	86aa                	mv	a3,a0
ffffffffc020198c:	02059793          	slli	a5,a1,0x20
ffffffffc0201990:	9381                	srli	a5,a5,0x20
ffffffffc0201992:	00a7ef63          	bltu	a5,a0,ffffffffc02019b0 <default_alloc_pages+0x30>
    list_entry_t *le = &free_list;
ffffffffc0201996:	00096617          	auipc	a2,0x96
ffffffffc020199a:	d7a60613          	addi	a2,a2,-646 # ffffffffc0297710 <free_area>
ffffffffc020199e:	87b2                	mv	a5,a2
ffffffffc02019a0:	a029                	j	ffffffffc02019aa <default_alloc_pages+0x2a>
        if (p->property >= n)
ffffffffc02019a2:	ff87e703          	lwu	a4,-8(a5)
ffffffffc02019a6:	00d77763          	bgeu	a4,a3,ffffffffc02019b4 <default_alloc_pages+0x34>
    return listelm->next;
ffffffffc02019aa:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list)
ffffffffc02019ac:	fec79be3          	bne	a5,a2,ffffffffc02019a2 <default_alloc_pages+0x22>
        return NULL;
ffffffffc02019b0:	4501                	li	a0,0
}
ffffffffc02019b2:	8082                	ret
        if (page->property > n)
ffffffffc02019b4:	ff87a883          	lw	a7,-8(a5)
    return listelm->prev;
ffffffffc02019b8:	0007b803          	ld	a6,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02019bc:	6798                	ld	a4,8(a5)
ffffffffc02019be:	02089313          	slli	t1,a7,0x20
ffffffffc02019c2:	02035313          	srli	t1,t1,0x20
    prev->next = next;
ffffffffc02019c6:	00e83423          	sd	a4,8(a6)
    next->prev = prev;
ffffffffc02019ca:	01073023          	sd	a6,0(a4)
        struct Page *p = le2page(le, page_link);
ffffffffc02019ce:	fe878513          	addi	a0,a5,-24
        if (page->property > n)
ffffffffc02019d2:	0266fa63          	bgeu	a3,t1,ffffffffc0201a06 <default_alloc_pages+0x86>
            struct Page *p = page + n;
ffffffffc02019d6:	00669713          	slli	a4,a3,0x6
            p->property = page->property - n;
ffffffffc02019da:	40d888bb          	subw	a7,a7,a3
            struct Page *p = page + n;
ffffffffc02019de:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc02019e0:	01172823          	sw	a7,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02019e4:	00870313          	addi	t1,a4,8
ffffffffc02019e8:	4889                	li	a7,2
ffffffffc02019ea:	4113302f          	amoor.d	zero,a7,(t1)
    __list_add(elm, listelm, listelm->next);
ffffffffc02019ee:	00883883          	ld	a7,8(a6)
            list_add(prev, &(p->page_link));
ffffffffc02019f2:	01870313          	addi	t1,a4,24
    prev->next = next->prev = elm;
ffffffffc02019f6:	0068b023          	sd	t1,0(a7)
ffffffffc02019fa:	00683423          	sd	t1,8(a6)
    elm->next = next;
ffffffffc02019fe:	03173023          	sd	a7,32(a4)
    elm->prev = prev;
ffffffffc0201a02:	01073c23          	sd	a6,24(a4)
        nr_free -= n;
ffffffffc0201a06:	9d95                	subw	a1,a1,a3
ffffffffc0201a08:	ca0c                	sw	a1,16(a2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201a0a:	5775                	li	a4,-3
ffffffffc0201a0c:	17c1                	addi	a5,a5,-16
ffffffffc0201a0e:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc0201a12:	8082                	ret
{
ffffffffc0201a14:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc0201a16:	00005697          	auipc	a3,0x5
ffffffffc0201a1a:	cba68693          	addi	a3,a3,-838 # ffffffffc02066d0 <etext+0xd52>
ffffffffc0201a1e:	00005617          	auipc	a2,0x5
ffffffffc0201a22:	95a60613          	addi	a2,a2,-1702 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201a26:	06c00593          	li	a1,108
ffffffffc0201a2a:	00005517          	auipc	a0,0x5
ffffffffc0201a2e:	96650513          	addi	a0,a0,-1690 # ffffffffc0206390 <etext+0xa12>
{
ffffffffc0201a32:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201a34:	a13fe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0201a38 <default_init_memmap>:
{
ffffffffc0201a38:	1141                	addi	sp,sp,-16
ffffffffc0201a3a:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0201a3c:	c9e1                	beqz	a1,ffffffffc0201b0c <default_init_memmap+0xd4>
    for (; p != base + n; p++)
ffffffffc0201a3e:	00659713          	slli	a4,a1,0x6
ffffffffc0201a42:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc0201a46:	87aa                	mv	a5,a0
    for (; p != base + n; p++)
ffffffffc0201a48:	cf11                	beqz	a4,ffffffffc0201a64 <default_init_memmap+0x2c>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0201a4a:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc0201a4c:	8b05                	andi	a4,a4,1
ffffffffc0201a4e:	cf59                	beqz	a4,ffffffffc0201aec <default_init_memmap+0xb4>
        p->flags = p->property = 0;
ffffffffc0201a50:	0007a823          	sw	zero,16(a5)
ffffffffc0201a54:	0007b423          	sd	zero,8(a5)
ffffffffc0201a58:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p++)
ffffffffc0201a5c:	04078793          	addi	a5,a5,64
ffffffffc0201a60:	fed795e3          	bne	a5,a3,ffffffffc0201a4a <default_init_memmap+0x12>
    base->property = n;
ffffffffc0201a64:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201a66:	4789                	li	a5,2
ffffffffc0201a68:	00850713          	addi	a4,a0,8
ffffffffc0201a6c:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc0201a70:	00096717          	auipc	a4,0x96
ffffffffc0201a74:	cb072703          	lw	a4,-848(a4) # ffffffffc0297720 <free_area+0x10>
ffffffffc0201a78:	00096697          	auipc	a3,0x96
ffffffffc0201a7c:	c9868693          	addi	a3,a3,-872 # ffffffffc0297710 <free_area>
    return list->next == list;
ffffffffc0201a80:	669c                	ld	a5,8(a3)
ffffffffc0201a82:	9f2d                	addw	a4,a4,a1
ffffffffc0201a84:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list))
ffffffffc0201a86:	04d78663          	beq	a5,a3,ffffffffc0201ad2 <default_init_memmap+0x9a>
            struct Page *page = le2page(le, page_link);
ffffffffc0201a8a:	fe878713          	addi	a4,a5,-24
ffffffffc0201a8e:	4581                	li	a1,0
ffffffffc0201a90:	01850613          	addi	a2,a0,24
            if (base < page)
ffffffffc0201a94:	00e56a63          	bltu	a0,a4,ffffffffc0201aa8 <default_init_memmap+0x70>
    return listelm->next;
ffffffffc0201a98:	6798                	ld	a4,8(a5)
            else if (list_next(le) == &free_list)
ffffffffc0201a9a:	02d70263          	beq	a4,a3,ffffffffc0201abe <default_init_memmap+0x86>
    struct Page *p = base;
ffffffffc0201a9e:	87ba                	mv	a5,a4
            struct Page *page = le2page(le, page_link);
ffffffffc0201aa0:	fe878713          	addi	a4,a5,-24
            if (base < page)
ffffffffc0201aa4:	fee57ae3          	bgeu	a0,a4,ffffffffc0201a98 <default_init_memmap+0x60>
ffffffffc0201aa8:	c199                	beqz	a1,ffffffffc0201aae <default_init_memmap+0x76>
ffffffffc0201aaa:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc0201aae:	6398                	ld	a4,0(a5)
}
ffffffffc0201ab0:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc0201ab2:	e390                	sd	a2,0(a5)
ffffffffc0201ab4:	e710                	sd	a2,8(a4)
    elm->prev = prev;
ffffffffc0201ab6:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc0201ab8:	f11c                	sd	a5,32(a0)
ffffffffc0201aba:	0141                	addi	sp,sp,16
ffffffffc0201abc:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc0201abe:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc0201ac0:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc0201ac2:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201ac4:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201ac6:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list)
ffffffffc0201ac8:	00d70e63          	beq	a4,a3,ffffffffc0201ae4 <default_init_memmap+0xac>
ffffffffc0201acc:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc0201ace:	87ba                	mv	a5,a4
ffffffffc0201ad0:	bfc1                	j	ffffffffc0201aa0 <default_init_memmap+0x68>
}
ffffffffc0201ad2:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201ad4:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc0201ad8:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201ada:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc0201adc:	e398                	sd	a4,0(a5)
ffffffffc0201ade:	e798                	sd	a4,8(a5)
}
ffffffffc0201ae0:	0141                	addi	sp,sp,16
ffffffffc0201ae2:	8082                	ret
ffffffffc0201ae4:	60a2                	ld	ra,8(sp)
ffffffffc0201ae6:	e290                	sd	a2,0(a3)
ffffffffc0201ae8:	0141                	addi	sp,sp,16
ffffffffc0201aea:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201aec:	00005697          	auipc	a3,0x5
ffffffffc0201af0:	c1468693          	addi	a3,a3,-1004 # ffffffffc0206700 <etext+0xd82>
ffffffffc0201af4:	00005617          	auipc	a2,0x5
ffffffffc0201af8:	88460613          	addi	a2,a2,-1916 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201afc:	04b00593          	li	a1,75
ffffffffc0201b00:	00005517          	auipc	a0,0x5
ffffffffc0201b04:	89050513          	addi	a0,a0,-1904 # ffffffffc0206390 <etext+0xa12>
ffffffffc0201b08:	93ffe0ef          	jal	ffffffffc0200446 <__panic>
    assert(n > 0);
ffffffffc0201b0c:	00005697          	auipc	a3,0x5
ffffffffc0201b10:	bc468693          	addi	a3,a3,-1084 # ffffffffc02066d0 <etext+0xd52>
ffffffffc0201b14:	00005617          	auipc	a2,0x5
ffffffffc0201b18:	86460613          	addi	a2,a2,-1948 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201b1c:	04700593          	li	a1,71
ffffffffc0201b20:	00005517          	auipc	a0,0x5
ffffffffc0201b24:	87050513          	addi	a0,a0,-1936 # ffffffffc0206390 <etext+0xa12>
ffffffffc0201b28:	91ffe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0201b2c <slob_free>:
static void slob_free(void *block, int size)
{
	slob_t *cur, *b = (slob_t *)block;
	unsigned long flags;

	if (!block)
ffffffffc0201b2c:	c531                	beqz	a0,ffffffffc0201b78 <slob_free+0x4c>
		return;

	if (size)
ffffffffc0201b2e:	e9b9                	bnez	a1,ffffffffc0201b84 <slob_free+0x58>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b30:	100027f3          	csrr	a5,sstatus
ffffffffc0201b34:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201b36:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b38:	efb1                	bnez	a5,ffffffffc0201b94 <slob_free+0x68>
		b->units = SLOB_UNITS(size);

	/* Find reinsertion point */
	spin_lock_irqsave(&slob_lock, flags);
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201b3a:	00095797          	auipc	a5,0x95
ffffffffc0201b3e:	7c67b783          	ld	a5,1990(a5) # ffffffffc0297300 <slobfree>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201b42:	873e                	mv	a4,a5
ffffffffc0201b44:	679c                	ld	a5,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201b46:	02a77a63          	bgeu	a4,a0,ffffffffc0201b7a <slob_free+0x4e>
ffffffffc0201b4a:	00f56463          	bltu	a0,a5,ffffffffc0201b52 <slob_free+0x26>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201b4e:	fef76ae3          	bltu	a4,a5,ffffffffc0201b42 <slob_free+0x16>
			break;

	if (b + b->units == cur->next)
ffffffffc0201b52:	4110                	lw	a2,0(a0)
ffffffffc0201b54:	00461693          	slli	a3,a2,0x4
ffffffffc0201b58:	96aa                	add	a3,a3,a0
ffffffffc0201b5a:	0ad78463          	beq	a5,a3,ffffffffc0201c02 <slob_free+0xd6>
		b->next = cur->next->next;
	}
	else
		b->next = cur->next;

	if (cur + cur->units == b)
ffffffffc0201b5e:	4310                	lw	a2,0(a4)
ffffffffc0201b60:	e51c                	sd	a5,8(a0)
ffffffffc0201b62:	00461693          	slli	a3,a2,0x4
ffffffffc0201b66:	96ba                	add	a3,a3,a4
ffffffffc0201b68:	08d50163          	beq	a0,a3,ffffffffc0201bea <slob_free+0xbe>
ffffffffc0201b6c:	e708                	sd	a0,8(a4)
		cur->next = b->next;
	}
	else
		cur->next = b;

	slobfree = cur;
ffffffffc0201b6e:	00095797          	auipc	a5,0x95
ffffffffc0201b72:	78e7b923          	sd	a4,1938(a5) # ffffffffc0297300 <slobfree>
    if (flag)
ffffffffc0201b76:	e9a5                	bnez	a1,ffffffffc0201be6 <slob_free+0xba>
ffffffffc0201b78:	8082                	ret
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201b7a:	fcf574e3          	bgeu	a0,a5,ffffffffc0201b42 <slob_free+0x16>
ffffffffc0201b7e:	fcf762e3          	bltu	a4,a5,ffffffffc0201b42 <slob_free+0x16>
ffffffffc0201b82:	bfc1                	j	ffffffffc0201b52 <slob_free+0x26>
		b->units = SLOB_UNITS(size);
ffffffffc0201b84:	25bd                	addiw	a1,a1,15
ffffffffc0201b86:	8191                	srli	a1,a1,0x4
ffffffffc0201b88:	c10c                	sw	a1,0(a0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b8a:	100027f3          	csrr	a5,sstatus
ffffffffc0201b8e:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0201b90:	4581                	li	a1,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201b92:	d7c5                	beqz	a5,ffffffffc0201b3a <slob_free+0xe>
{
ffffffffc0201b94:	1101                	addi	sp,sp,-32
ffffffffc0201b96:	e42a                	sd	a0,8(sp)
ffffffffc0201b98:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201b9a:	d6bfe0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc0201b9e:	6522                	ld	a0,8(sp)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201ba0:	00095797          	auipc	a5,0x95
ffffffffc0201ba4:	7607b783          	ld	a5,1888(a5) # ffffffffc0297300 <slobfree>
ffffffffc0201ba8:	4585                	li	a1,1
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201baa:	873e                	mv	a4,a5
ffffffffc0201bac:	679c                	ld	a5,8(a5)
	for (cur = slobfree; !(b > cur && b < cur->next); cur = cur->next)
ffffffffc0201bae:	06a77663          	bgeu	a4,a0,ffffffffc0201c1a <slob_free+0xee>
ffffffffc0201bb2:	00f56463          	bltu	a0,a5,ffffffffc0201bba <slob_free+0x8e>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201bb6:	fef76ae3          	bltu	a4,a5,ffffffffc0201baa <slob_free+0x7e>
	if (b + b->units == cur->next)
ffffffffc0201bba:	4110                	lw	a2,0(a0)
ffffffffc0201bbc:	00461693          	slli	a3,a2,0x4
ffffffffc0201bc0:	96aa                	add	a3,a3,a0
ffffffffc0201bc2:	06d78363          	beq	a5,a3,ffffffffc0201c28 <slob_free+0xfc>
	if (cur + cur->units == b)
ffffffffc0201bc6:	4310                	lw	a2,0(a4)
ffffffffc0201bc8:	e51c                	sd	a5,8(a0)
ffffffffc0201bca:	00461693          	slli	a3,a2,0x4
ffffffffc0201bce:	96ba                	add	a3,a3,a4
ffffffffc0201bd0:	06d50163          	beq	a0,a3,ffffffffc0201c32 <slob_free+0x106>
ffffffffc0201bd4:	e708                	sd	a0,8(a4)
	slobfree = cur;
ffffffffc0201bd6:	00095797          	auipc	a5,0x95
ffffffffc0201bda:	72e7b523          	sd	a4,1834(a5) # ffffffffc0297300 <slobfree>
    if (flag)
ffffffffc0201bde:	e1a9                	bnez	a1,ffffffffc0201c20 <slob_free+0xf4>

	spin_unlock_irqrestore(&slob_lock, flags);
}
ffffffffc0201be0:	60e2                	ld	ra,24(sp)
ffffffffc0201be2:	6105                	addi	sp,sp,32
ffffffffc0201be4:	8082                	ret
        intr_enable();
ffffffffc0201be6:	d19fe06f          	j	ffffffffc02008fe <intr_enable>
		cur->units += b->units;
ffffffffc0201bea:	4114                	lw	a3,0(a0)
		cur->next = b->next;
ffffffffc0201bec:	853e                	mv	a0,a5
ffffffffc0201bee:	e708                	sd	a0,8(a4)
		cur->units += b->units;
ffffffffc0201bf0:	00c687bb          	addw	a5,a3,a2
ffffffffc0201bf4:	c31c                	sw	a5,0(a4)
	slobfree = cur;
ffffffffc0201bf6:	00095797          	auipc	a5,0x95
ffffffffc0201bfa:	70e7b523          	sd	a4,1802(a5) # ffffffffc0297300 <slobfree>
    if (flag)
ffffffffc0201bfe:	ddad                	beqz	a1,ffffffffc0201b78 <slob_free+0x4c>
ffffffffc0201c00:	b7dd                	j	ffffffffc0201be6 <slob_free+0xba>
		b->units += cur->next->units;
ffffffffc0201c02:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201c04:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201c06:	9eb1                	addw	a3,a3,a2
ffffffffc0201c08:	c114                	sw	a3,0(a0)
	if (cur + cur->units == b)
ffffffffc0201c0a:	4310                	lw	a2,0(a4)
ffffffffc0201c0c:	e51c                	sd	a5,8(a0)
ffffffffc0201c0e:	00461693          	slli	a3,a2,0x4
ffffffffc0201c12:	96ba                	add	a3,a3,a4
ffffffffc0201c14:	f4d51ce3          	bne	a0,a3,ffffffffc0201b6c <slob_free+0x40>
ffffffffc0201c18:	bfc9                	j	ffffffffc0201bea <slob_free+0xbe>
		if (cur >= cur->next && (b > cur || b < cur->next))
ffffffffc0201c1a:	f8f56ee3          	bltu	a0,a5,ffffffffc0201bb6 <slob_free+0x8a>
ffffffffc0201c1e:	b771                	j	ffffffffc0201baa <slob_free+0x7e>
}
ffffffffc0201c20:	60e2                	ld	ra,24(sp)
ffffffffc0201c22:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201c24:	cdbfe06f          	j	ffffffffc02008fe <intr_enable>
		b->units += cur->next->units;
ffffffffc0201c28:	4394                	lw	a3,0(a5)
		b->next = cur->next->next;
ffffffffc0201c2a:	679c                	ld	a5,8(a5)
		b->units += cur->next->units;
ffffffffc0201c2c:	9eb1                	addw	a3,a3,a2
ffffffffc0201c2e:	c114                	sw	a3,0(a0)
		b->next = cur->next->next;
ffffffffc0201c30:	bf59                	j	ffffffffc0201bc6 <slob_free+0x9a>
		cur->units += b->units;
ffffffffc0201c32:	4114                	lw	a3,0(a0)
		cur->next = b->next;
ffffffffc0201c34:	853e                	mv	a0,a5
		cur->units += b->units;
ffffffffc0201c36:	00c687bb          	addw	a5,a3,a2
ffffffffc0201c3a:	c31c                	sw	a5,0(a4)
		cur->next = b->next;
ffffffffc0201c3c:	bf61                	j	ffffffffc0201bd4 <slob_free+0xa8>

ffffffffc0201c3e <__slob_get_free_pages.constprop.0>:
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201c3e:	4785                	li	a5,1
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201c40:	1141                	addi	sp,sp,-16
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201c42:	00a7953b          	sllw	a0,a5,a0
static void *__slob_get_free_pages(gfp_t gfp, int order)
ffffffffc0201c46:	e406                	sd	ra,8(sp)
	struct Page *page = alloc_pages(1 << order);
ffffffffc0201c48:	32c000ef          	jal	ffffffffc0201f74 <alloc_pages>
	if (!page)
ffffffffc0201c4c:	c91d                	beqz	a0,ffffffffc0201c82 <__slob_get_free_pages.constprop.0+0x44>
    return page - pages + nbase;
ffffffffc0201c4e:	0009a697          	auipc	a3,0x9a
ffffffffc0201c52:	b426b683          	ld	a3,-1214(a3) # ffffffffc029b790 <pages>
ffffffffc0201c56:	00006797          	auipc	a5,0x6
ffffffffc0201c5a:	f027b783          	ld	a5,-254(a5) # ffffffffc0207b58 <nbase>
    return KADDR(page2pa(page));
ffffffffc0201c5e:	0009a717          	auipc	a4,0x9a
ffffffffc0201c62:	b2a73703          	ld	a4,-1238(a4) # ffffffffc029b788 <npage>
    return page - pages + nbase;
ffffffffc0201c66:	8d15                	sub	a0,a0,a3
ffffffffc0201c68:	8519                	srai	a0,a0,0x6
ffffffffc0201c6a:	953e                	add	a0,a0,a5
    return KADDR(page2pa(page));
ffffffffc0201c6c:	00c51793          	slli	a5,a0,0xc
ffffffffc0201c70:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0201c72:	0532                	slli	a0,a0,0xc
    return KADDR(page2pa(page));
ffffffffc0201c74:	00e7fa63          	bgeu	a5,a4,ffffffffc0201c88 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201c78:	0009a797          	auipc	a5,0x9a
ffffffffc0201c7c:	b087b783          	ld	a5,-1272(a5) # ffffffffc029b780 <va_pa_offset>
ffffffffc0201c80:	953e                	add	a0,a0,a5
}
ffffffffc0201c82:	60a2                	ld	ra,8(sp)
ffffffffc0201c84:	0141                	addi	sp,sp,16
ffffffffc0201c86:	8082                	ret
ffffffffc0201c88:	86aa                	mv	a3,a0
ffffffffc0201c8a:	00005617          	auipc	a2,0x5
ffffffffc0201c8e:	a9e60613          	addi	a2,a2,-1378 # ffffffffc0206728 <etext+0xdaa>
ffffffffc0201c92:	07100593          	li	a1,113
ffffffffc0201c96:	00005517          	auipc	a0,0x5
ffffffffc0201c9a:	aba50513          	addi	a0,a0,-1350 # ffffffffc0206750 <etext+0xdd2>
ffffffffc0201c9e:	fa8fe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0201ca2 <slob_alloc.constprop.0>:
static void *slob_alloc(size_t size, gfp_t gfp, int align)
ffffffffc0201ca2:	7179                	addi	sp,sp,-48
ffffffffc0201ca4:	f406                	sd	ra,40(sp)
ffffffffc0201ca6:	f022                	sd	s0,32(sp)
ffffffffc0201ca8:	ec26                	sd	s1,24(sp)
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201caa:	01050713          	addi	a4,a0,16
ffffffffc0201cae:	6785                	lui	a5,0x1
ffffffffc0201cb0:	0af77e63          	bgeu	a4,a5,ffffffffc0201d6c <slob_alloc.constprop.0+0xca>
	int delta = 0, units = SLOB_UNITS(size);
ffffffffc0201cb4:	00f50413          	addi	s0,a0,15
ffffffffc0201cb8:	8011                	srli	s0,s0,0x4
ffffffffc0201cba:	2401                	sext.w	s0,s0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201cbc:	100025f3          	csrr	a1,sstatus
ffffffffc0201cc0:	8989                	andi	a1,a1,2
ffffffffc0201cc2:	edd1                	bnez	a1,ffffffffc0201d5e <slob_alloc.constprop.0+0xbc>
	prev = slobfree;
ffffffffc0201cc4:	00095497          	auipc	s1,0x95
ffffffffc0201cc8:	63c48493          	addi	s1,s1,1596 # ffffffffc0297300 <slobfree>
ffffffffc0201ccc:	6090                	ld	a2,0(s1)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201cce:	6618                	ld	a4,8(a2)
		if (cur->units >= units + delta)
ffffffffc0201cd0:	4314                	lw	a3,0(a4)
ffffffffc0201cd2:	0886da63          	bge	a3,s0,ffffffffc0201d66 <slob_alloc.constprop.0+0xc4>
		if (cur == slobfree)
ffffffffc0201cd6:	00e60a63          	beq	a2,a4,ffffffffc0201cea <slob_alloc.constprop.0+0x48>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201cda:	671c                	ld	a5,8(a4)
		if (cur->units >= units + delta)
ffffffffc0201cdc:	4394                	lw	a3,0(a5)
ffffffffc0201cde:	0286d863          	bge	a3,s0,ffffffffc0201d0e <slob_alloc.constprop.0+0x6c>
		if (cur == slobfree)
ffffffffc0201ce2:	6090                	ld	a2,0(s1)
ffffffffc0201ce4:	873e                	mv	a4,a5
ffffffffc0201ce6:	fee61ae3          	bne	a2,a4,ffffffffc0201cda <slob_alloc.constprop.0+0x38>
    if (flag)
ffffffffc0201cea:	e9b1                	bnez	a1,ffffffffc0201d3e <slob_alloc.constprop.0+0x9c>
			cur = (slob_t *)__slob_get_free_page(gfp);
ffffffffc0201cec:	4501                	li	a0,0
ffffffffc0201cee:	f51ff0ef          	jal	ffffffffc0201c3e <__slob_get_free_pages.constprop.0>
ffffffffc0201cf2:	87aa                	mv	a5,a0
			if (!cur)
ffffffffc0201cf4:	c915                	beqz	a0,ffffffffc0201d28 <slob_alloc.constprop.0+0x86>
			slob_free(cur, PAGE_SIZE);
ffffffffc0201cf6:	6585                	lui	a1,0x1
ffffffffc0201cf8:	e35ff0ef          	jal	ffffffffc0201b2c <slob_free>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201cfc:	100025f3          	csrr	a1,sstatus
ffffffffc0201d00:	8989                	andi	a1,a1,2
ffffffffc0201d02:	e98d                	bnez	a1,ffffffffc0201d34 <slob_alloc.constprop.0+0x92>
			cur = slobfree;
ffffffffc0201d04:	6098                	ld	a4,0(s1)
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201d06:	671c                	ld	a5,8(a4)
		if (cur->units >= units + delta)
ffffffffc0201d08:	4394                	lw	a3,0(a5)
ffffffffc0201d0a:	fc86cce3          	blt	a3,s0,ffffffffc0201ce2 <slob_alloc.constprop.0+0x40>
			if (cur->units == units)	/* exact fit? */
ffffffffc0201d0e:	04d40563          	beq	s0,a3,ffffffffc0201d58 <slob_alloc.constprop.0+0xb6>
				prev->next = cur + units;
ffffffffc0201d12:	00441613          	slli	a2,s0,0x4
ffffffffc0201d16:	963e                	add	a2,a2,a5
ffffffffc0201d18:	e710                	sd	a2,8(a4)
				prev->next->next = cur->next;
ffffffffc0201d1a:	6788                	ld	a0,8(a5)
				prev->next->units = cur->units - units;
ffffffffc0201d1c:	9e81                	subw	a3,a3,s0
ffffffffc0201d1e:	c214                	sw	a3,0(a2)
				prev->next->next = cur->next;
ffffffffc0201d20:	e608                	sd	a0,8(a2)
				cur->units = units;
ffffffffc0201d22:	c380                	sw	s0,0(a5)
			slobfree = prev;
ffffffffc0201d24:	e098                	sd	a4,0(s1)
    if (flag)
ffffffffc0201d26:	ed99                	bnez	a1,ffffffffc0201d44 <slob_alloc.constprop.0+0xa2>
}
ffffffffc0201d28:	70a2                	ld	ra,40(sp)
ffffffffc0201d2a:	7402                	ld	s0,32(sp)
ffffffffc0201d2c:	64e2                	ld	s1,24(sp)
ffffffffc0201d2e:	853e                	mv	a0,a5
ffffffffc0201d30:	6145                	addi	sp,sp,48
ffffffffc0201d32:	8082                	ret
        intr_disable();
ffffffffc0201d34:	bd1fe0ef          	jal	ffffffffc0200904 <intr_disable>
			cur = slobfree;
ffffffffc0201d38:	6098                	ld	a4,0(s1)
        return 1;
ffffffffc0201d3a:	4585                	li	a1,1
ffffffffc0201d3c:	b7e9                	j	ffffffffc0201d06 <slob_alloc.constprop.0+0x64>
        intr_enable();
ffffffffc0201d3e:	bc1fe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0201d42:	b76d                	j	ffffffffc0201cec <slob_alloc.constprop.0+0x4a>
ffffffffc0201d44:	e43e                	sd	a5,8(sp)
ffffffffc0201d46:	bb9fe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0201d4a:	67a2                	ld	a5,8(sp)
}
ffffffffc0201d4c:	70a2                	ld	ra,40(sp)
ffffffffc0201d4e:	7402                	ld	s0,32(sp)
ffffffffc0201d50:	64e2                	ld	s1,24(sp)
ffffffffc0201d52:	853e                	mv	a0,a5
ffffffffc0201d54:	6145                	addi	sp,sp,48
ffffffffc0201d56:	8082                	ret
				prev->next = cur->next; /* unlink */
ffffffffc0201d58:	6794                	ld	a3,8(a5)
ffffffffc0201d5a:	e714                	sd	a3,8(a4)
ffffffffc0201d5c:	b7e1                	j	ffffffffc0201d24 <slob_alloc.constprop.0+0x82>
        intr_disable();
ffffffffc0201d5e:	ba7fe0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc0201d62:	4585                	li	a1,1
ffffffffc0201d64:	b785                	j	ffffffffc0201cc4 <slob_alloc.constprop.0+0x22>
	for (cur = prev->next;; prev = cur, cur = cur->next)
ffffffffc0201d66:	87ba                	mv	a5,a4
	prev = slobfree;
ffffffffc0201d68:	8732                	mv	a4,a2
ffffffffc0201d6a:	b755                	j	ffffffffc0201d0e <slob_alloc.constprop.0+0x6c>
	assert((size + SLOB_UNIT) < PAGE_SIZE);
ffffffffc0201d6c:	00005697          	auipc	a3,0x5
ffffffffc0201d70:	9f468693          	addi	a3,a3,-1548 # ffffffffc0206760 <etext+0xde2>
ffffffffc0201d74:	00004617          	auipc	a2,0x4
ffffffffc0201d78:	60460613          	addi	a2,a2,1540 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0201d7c:	06300593          	li	a1,99
ffffffffc0201d80:	00005517          	auipc	a0,0x5
ffffffffc0201d84:	a0050513          	addi	a0,a0,-1536 # ffffffffc0206780 <etext+0xe02>
ffffffffc0201d88:	ebefe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0201d8c <kmalloc_init>:
	cprintf("use SLOB allocator\n");
}

inline void
kmalloc_init(void)
{
ffffffffc0201d8c:	1141                	addi	sp,sp,-16
	cprintf("use SLOB allocator\n");
ffffffffc0201d8e:	00005517          	auipc	a0,0x5
ffffffffc0201d92:	a0a50513          	addi	a0,a0,-1526 # ffffffffc0206798 <etext+0xe1a>
{
ffffffffc0201d96:	e406                	sd	ra,8(sp)
	cprintf("use SLOB allocator\n");
ffffffffc0201d98:	bfcfe0ef          	jal	ffffffffc0200194 <cprintf>
	slob_init();
	cprintf("kmalloc_init() succeeded!\n");
}
ffffffffc0201d9c:	60a2                	ld	ra,8(sp)
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201d9e:	00005517          	auipc	a0,0x5
ffffffffc0201da2:	a1250513          	addi	a0,a0,-1518 # ffffffffc02067b0 <etext+0xe32>
}
ffffffffc0201da6:	0141                	addi	sp,sp,16
	cprintf("kmalloc_init() succeeded!\n");
ffffffffc0201da8:	becfe06f          	j	ffffffffc0200194 <cprintf>

ffffffffc0201dac <kallocated>:

size_t
kallocated(void)
{
	return slob_allocated();
}
ffffffffc0201dac:	4501                	li	a0,0
ffffffffc0201dae:	8082                	ret

ffffffffc0201db0 <kmalloc>:
	return 0;
}

void *
kmalloc(size_t size)
{
ffffffffc0201db0:	1101                	addi	sp,sp,-32
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201db2:	6685                	lui	a3,0x1
{
ffffffffc0201db4:	ec06                	sd	ra,24(sp)
	if (size < PAGE_SIZE - SLOB_UNIT)
ffffffffc0201db6:	16bd                	addi	a3,a3,-17 # fef <_binary_obj___user_softint_out_size-0x7be1>
ffffffffc0201db8:	04a6f963          	bgeu	a3,a0,ffffffffc0201e0a <kmalloc+0x5a>
	bb = slob_alloc(sizeof(bigblock_t), gfp, 0);
ffffffffc0201dbc:	e42a                	sd	a0,8(sp)
ffffffffc0201dbe:	4561                	li	a0,24
ffffffffc0201dc0:	e822                	sd	s0,16(sp)
ffffffffc0201dc2:	ee1ff0ef          	jal	ffffffffc0201ca2 <slob_alloc.constprop.0>
ffffffffc0201dc6:	842a                	mv	s0,a0
	if (!bb)
ffffffffc0201dc8:	c541                	beqz	a0,ffffffffc0201e50 <kmalloc+0xa0>
	bb->order = find_order(size);
ffffffffc0201dca:	47a2                	lw	a5,8(sp)
	for (; size > 4096; size >>= 1)
ffffffffc0201dcc:	6705                	lui	a4,0x1
	int order = 0;
ffffffffc0201dce:	4501                	li	a0,0
	for (; size > 4096; size >>= 1)
ffffffffc0201dd0:	00f75763          	bge	a4,a5,ffffffffc0201dde <kmalloc+0x2e>
ffffffffc0201dd4:	4017d79b          	sraiw	a5,a5,0x1
		order++;
ffffffffc0201dd8:	2505                	addiw	a0,a0,1
	for (; size > 4096; size >>= 1)
ffffffffc0201dda:	fef74de3          	blt	a4,a5,ffffffffc0201dd4 <kmalloc+0x24>
	bb->order = find_order(size);
ffffffffc0201dde:	c008                	sw	a0,0(s0)
	bb->pages = (void *)__slob_get_free_pages(gfp, bb->order);
ffffffffc0201de0:	e5fff0ef          	jal	ffffffffc0201c3e <__slob_get_free_pages.constprop.0>
ffffffffc0201de4:	e408                	sd	a0,8(s0)
	if (bb->pages)
ffffffffc0201de6:	cd31                	beqz	a0,ffffffffc0201e42 <kmalloc+0x92>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201de8:	100027f3          	csrr	a5,sstatus
ffffffffc0201dec:	8b89                	andi	a5,a5,2
ffffffffc0201dee:	eb85                	bnez	a5,ffffffffc0201e1e <kmalloc+0x6e>
		bb->next = bigblocks;
ffffffffc0201df0:	0009a797          	auipc	a5,0x9a
ffffffffc0201df4:	9707b783          	ld	a5,-1680(a5) # ffffffffc029b760 <bigblocks>
		bigblocks = bb;
ffffffffc0201df8:	0009a717          	auipc	a4,0x9a
ffffffffc0201dfc:	96873423          	sd	s0,-1688(a4) # ffffffffc029b760 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201e00:	e81c                	sd	a5,16(s0)
    if (flag)
ffffffffc0201e02:	6442                	ld	s0,16(sp)
	return __kmalloc(size, 0);
}
ffffffffc0201e04:	60e2                	ld	ra,24(sp)
ffffffffc0201e06:	6105                	addi	sp,sp,32
ffffffffc0201e08:	8082                	ret
		m = slob_alloc(size + SLOB_UNIT, gfp, 0);
ffffffffc0201e0a:	0541                	addi	a0,a0,16
ffffffffc0201e0c:	e97ff0ef          	jal	ffffffffc0201ca2 <slob_alloc.constprop.0>
ffffffffc0201e10:	87aa                	mv	a5,a0
		return m ? (void *)(m + 1) : 0;
ffffffffc0201e12:	0541                	addi	a0,a0,16
ffffffffc0201e14:	fbe5                	bnez	a5,ffffffffc0201e04 <kmalloc+0x54>
		return 0;
ffffffffc0201e16:	4501                	li	a0,0
}
ffffffffc0201e18:	60e2                	ld	ra,24(sp)
ffffffffc0201e1a:	6105                	addi	sp,sp,32
ffffffffc0201e1c:	8082                	ret
        intr_disable();
ffffffffc0201e1e:	ae7fe0ef          	jal	ffffffffc0200904 <intr_disable>
		bb->next = bigblocks;
ffffffffc0201e22:	0009a797          	auipc	a5,0x9a
ffffffffc0201e26:	93e7b783          	ld	a5,-1730(a5) # ffffffffc029b760 <bigblocks>
		bigblocks = bb;
ffffffffc0201e2a:	0009a717          	auipc	a4,0x9a
ffffffffc0201e2e:	92873b23          	sd	s0,-1738(a4) # ffffffffc029b760 <bigblocks>
		bb->next = bigblocks;
ffffffffc0201e32:	e81c                	sd	a5,16(s0)
        intr_enable();
ffffffffc0201e34:	acbfe0ef          	jal	ffffffffc02008fe <intr_enable>
		return bb->pages;
ffffffffc0201e38:	6408                	ld	a0,8(s0)
}
ffffffffc0201e3a:	60e2                	ld	ra,24(sp)
		return bb->pages;
ffffffffc0201e3c:	6442                	ld	s0,16(sp)
}
ffffffffc0201e3e:	6105                	addi	sp,sp,32
ffffffffc0201e40:	8082                	ret
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201e42:	8522                	mv	a0,s0
ffffffffc0201e44:	45e1                	li	a1,24
ffffffffc0201e46:	ce7ff0ef          	jal	ffffffffc0201b2c <slob_free>
		return 0;
ffffffffc0201e4a:	4501                	li	a0,0
	slob_free(bb, sizeof(bigblock_t));
ffffffffc0201e4c:	6442                	ld	s0,16(sp)
ffffffffc0201e4e:	b7e9                	j	ffffffffc0201e18 <kmalloc+0x68>
ffffffffc0201e50:	6442                	ld	s0,16(sp)
		return 0;
ffffffffc0201e52:	4501                	li	a0,0
ffffffffc0201e54:	b7d1                	j	ffffffffc0201e18 <kmalloc+0x68>

ffffffffc0201e56 <kfree>:
void kfree(void *block)
{
	bigblock_t *bb, **last = &bigblocks;
	unsigned long flags;

	if (!block)
ffffffffc0201e56:	c579                	beqz	a0,ffffffffc0201f24 <kfree+0xce>
		return;

	if (!((unsigned long)block & (PAGE_SIZE - 1)))
ffffffffc0201e58:	03451793          	slli	a5,a0,0x34
ffffffffc0201e5c:	e3e1                	bnez	a5,ffffffffc0201f1c <kfree+0xc6>
{
ffffffffc0201e5e:	1101                	addi	sp,sp,-32
ffffffffc0201e60:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201e62:	100027f3          	csrr	a5,sstatus
ffffffffc0201e66:	8b89                	andi	a5,a5,2
ffffffffc0201e68:	e7c1                	bnez	a5,ffffffffc0201ef0 <kfree+0x9a>
	{
		/* might be on the big block list */
		spin_lock_irqsave(&block_lock, flags);
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201e6a:	0009a797          	auipc	a5,0x9a
ffffffffc0201e6e:	8f67b783          	ld	a5,-1802(a5) # ffffffffc029b760 <bigblocks>
    return 0;
ffffffffc0201e72:	4581                	li	a1,0
ffffffffc0201e74:	cbad                	beqz	a5,ffffffffc0201ee6 <kfree+0x90>
	bigblock_t *bb, **last = &bigblocks;
ffffffffc0201e76:	0009a617          	auipc	a2,0x9a
ffffffffc0201e7a:	8ea60613          	addi	a2,a2,-1814 # ffffffffc029b760 <bigblocks>
ffffffffc0201e7e:	a021                	j	ffffffffc0201e86 <kfree+0x30>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201e80:	01070613          	addi	a2,a4,16
ffffffffc0201e84:	c3a5                	beqz	a5,ffffffffc0201ee4 <kfree+0x8e>
		{
			if (bb->pages == block)
ffffffffc0201e86:	6794                	ld	a3,8(a5)
ffffffffc0201e88:	873e                	mv	a4,a5
			{
				*last = bb->next;
ffffffffc0201e8a:	6b9c                	ld	a5,16(a5)
			if (bb->pages == block)
ffffffffc0201e8c:	fea69ae3          	bne	a3,a0,ffffffffc0201e80 <kfree+0x2a>
				*last = bb->next;
ffffffffc0201e90:	e21c                	sd	a5,0(a2)
    if (flag)
ffffffffc0201e92:	edb5                	bnez	a1,ffffffffc0201f0e <kfree+0xb8>
    return pa2page(PADDR(kva));
ffffffffc0201e94:	c02007b7          	lui	a5,0xc0200
ffffffffc0201e98:	0af56363          	bltu	a0,a5,ffffffffc0201f3e <kfree+0xe8>
ffffffffc0201e9c:	0009a797          	auipc	a5,0x9a
ffffffffc0201ea0:	8e47b783          	ld	a5,-1820(a5) # ffffffffc029b780 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc0201ea4:	0009a697          	auipc	a3,0x9a
ffffffffc0201ea8:	8e46b683          	ld	a3,-1820(a3) # ffffffffc029b788 <npage>
    return pa2page(PADDR(kva));
ffffffffc0201eac:	8d1d                	sub	a0,a0,a5
    if (PPN(pa) >= npage)
ffffffffc0201eae:	00c55793          	srli	a5,a0,0xc
ffffffffc0201eb2:	06d7fa63          	bgeu	a5,a3,ffffffffc0201f26 <kfree+0xd0>
    return &pages[PPN(pa) - nbase];
ffffffffc0201eb6:	00006617          	auipc	a2,0x6
ffffffffc0201eba:	ca263603          	ld	a2,-862(a2) # ffffffffc0207b58 <nbase>
ffffffffc0201ebe:	0009a517          	auipc	a0,0x9a
ffffffffc0201ec2:	8d253503          	ld	a0,-1838(a0) # ffffffffc029b790 <pages>
	free_pages(kva2page((void *)kva), 1 << order);
ffffffffc0201ec6:	4314                	lw	a3,0(a4)
ffffffffc0201ec8:	8f91                	sub	a5,a5,a2
ffffffffc0201eca:	079a                	slli	a5,a5,0x6
ffffffffc0201ecc:	4585                	li	a1,1
ffffffffc0201ece:	953e                	add	a0,a0,a5
ffffffffc0201ed0:	00d595bb          	sllw	a1,a1,a3
ffffffffc0201ed4:	e03a                	sd	a4,0(sp)
ffffffffc0201ed6:	0d8000ef          	jal	ffffffffc0201fae <free_pages>
				spin_unlock_irqrestore(&block_lock, flags);
				__slob_free_pages((unsigned long)block, bb->order);
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201eda:	6502                	ld	a0,0(sp)
		spin_unlock_irqrestore(&block_lock, flags);
	}

	slob_free((slob_t *)block - 1, 0);
	return;
}
ffffffffc0201edc:	60e2                	ld	ra,24(sp)
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201ede:	45e1                	li	a1,24
}
ffffffffc0201ee0:	6105                	addi	sp,sp,32
				slob_free(bb, sizeof(bigblock_t));
ffffffffc0201ee2:	b1a9                	j	ffffffffc0201b2c <slob_free>
ffffffffc0201ee4:	e185                	bnez	a1,ffffffffc0201f04 <kfree+0xae>
}
ffffffffc0201ee6:	60e2                	ld	ra,24(sp)
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201ee8:	1541                	addi	a0,a0,-16
ffffffffc0201eea:	4581                	li	a1,0
}
ffffffffc0201eec:	6105                	addi	sp,sp,32
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201eee:	b93d                	j	ffffffffc0201b2c <slob_free>
        intr_disable();
ffffffffc0201ef0:	e02a                	sd	a0,0(sp)
ffffffffc0201ef2:	a13fe0ef          	jal	ffffffffc0200904 <intr_disable>
		for (bb = bigblocks; bb; last = &bb->next, bb = bb->next)
ffffffffc0201ef6:	0009a797          	auipc	a5,0x9a
ffffffffc0201efa:	86a7b783          	ld	a5,-1942(a5) # ffffffffc029b760 <bigblocks>
ffffffffc0201efe:	6502                	ld	a0,0(sp)
        return 1;
ffffffffc0201f00:	4585                	li	a1,1
ffffffffc0201f02:	fbb5                	bnez	a5,ffffffffc0201e76 <kfree+0x20>
ffffffffc0201f04:	e02a                	sd	a0,0(sp)
        intr_enable();
ffffffffc0201f06:	9f9fe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0201f0a:	6502                	ld	a0,0(sp)
ffffffffc0201f0c:	bfe9                	j	ffffffffc0201ee6 <kfree+0x90>
ffffffffc0201f0e:	e42a                	sd	a0,8(sp)
ffffffffc0201f10:	e03a                	sd	a4,0(sp)
ffffffffc0201f12:	9edfe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0201f16:	6522                	ld	a0,8(sp)
ffffffffc0201f18:	6702                	ld	a4,0(sp)
ffffffffc0201f1a:	bfad                	j	ffffffffc0201e94 <kfree+0x3e>
	slob_free((slob_t *)block - 1, 0);
ffffffffc0201f1c:	1541                	addi	a0,a0,-16
ffffffffc0201f1e:	4581                	li	a1,0
ffffffffc0201f20:	c0dff06f          	j	ffffffffc0201b2c <slob_free>
ffffffffc0201f24:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0201f26:	00005617          	auipc	a2,0x5
ffffffffc0201f2a:	8d260613          	addi	a2,a2,-1838 # ffffffffc02067f8 <etext+0xe7a>
ffffffffc0201f2e:	06900593          	li	a1,105
ffffffffc0201f32:	00005517          	auipc	a0,0x5
ffffffffc0201f36:	81e50513          	addi	a0,a0,-2018 # ffffffffc0206750 <etext+0xdd2>
ffffffffc0201f3a:	d0cfe0ef          	jal	ffffffffc0200446 <__panic>
    return pa2page(PADDR(kva));
ffffffffc0201f3e:	86aa                	mv	a3,a0
ffffffffc0201f40:	00005617          	auipc	a2,0x5
ffffffffc0201f44:	89060613          	addi	a2,a2,-1904 # ffffffffc02067d0 <etext+0xe52>
ffffffffc0201f48:	07700593          	li	a1,119
ffffffffc0201f4c:	00005517          	auipc	a0,0x5
ffffffffc0201f50:	80450513          	addi	a0,a0,-2044 # ffffffffc0206750 <etext+0xdd2>
ffffffffc0201f54:	cf2fe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0201f58 <pa2page.part.0>:
pa2page(uintptr_t pa)
ffffffffc0201f58:	1141                	addi	sp,sp,-16
        panic("pa2page called with invalid pa");
ffffffffc0201f5a:	00005617          	auipc	a2,0x5
ffffffffc0201f5e:	89e60613          	addi	a2,a2,-1890 # ffffffffc02067f8 <etext+0xe7a>
ffffffffc0201f62:	06900593          	li	a1,105
ffffffffc0201f66:	00004517          	auipc	a0,0x4
ffffffffc0201f6a:	7ea50513          	addi	a0,a0,2026 # ffffffffc0206750 <etext+0xdd2>
pa2page(uintptr_t pa)
ffffffffc0201f6e:	e406                	sd	ra,8(sp)
        panic("pa2page called with invalid pa");
ffffffffc0201f70:	cd6fe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0201f74 <alloc_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201f74:	100027f3          	csrr	a5,sstatus
ffffffffc0201f78:	8b89                	andi	a5,a5,2
ffffffffc0201f7a:	e799                	bnez	a5,ffffffffc0201f88 <alloc_pages+0x14>
{
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc0201f7c:	00099797          	auipc	a5,0x99
ffffffffc0201f80:	7ec7b783          	ld	a5,2028(a5) # ffffffffc029b768 <pmm_manager>
ffffffffc0201f84:	6f9c                	ld	a5,24(a5)
ffffffffc0201f86:	8782                	jr	a5
{
ffffffffc0201f88:	1101                	addi	sp,sp,-32
ffffffffc0201f8a:	ec06                	sd	ra,24(sp)
ffffffffc0201f8c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0201f8e:	977fe0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0201f92:	00099797          	auipc	a5,0x99
ffffffffc0201f96:	7d67b783          	ld	a5,2006(a5) # ffffffffc029b768 <pmm_manager>
ffffffffc0201f9a:	6522                	ld	a0,8(sp)
ffffffffc0201f9c:	6f9c                	ld	a5,24(a5)
ffffffffc0201f9e:	9782                	jalr	a5
ffffffffc0201fa0:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201fa2:	95dfe0ef          	jal	ffffffffc02008fe <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc0201fa6:	60e2                	ld	ra,24(sp)
ffffffffc0201fa8:	6522                	ld	a0,8(sp)
ffffffffc0201faa:	6105                	addi	sp,sp,32
ffffffffc0201fac:	8082                	ret

ffffffffc0201fae <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201fae:	100027f3          	csrr	a5,sstatus
ffffffffc0201fb2:	8b89                	andi	a5,a5,2
ffffffffc0201fb4:	e799                	bnez	a5,ffffffffc0201fc2 <free_pages+0x14>
void free_pages(struct Page *base, size_t n)
{
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc0201fb6:	00099797          	auipc	a5,0x99
ffffffffc0201fba:	7b27b783          	ld	a5,1970(a5) # ffffffffc029b768 <pmm_manager>
ffffffffc0201fbe:	739c                	ld	a5,32(a5)
ffffffffc0201fc0:	8782                	jr	a5
{
ffffffffc0201fc2:	1101                	addi	sp,sp,-32
ffffffffc0201fc4:	ec06                	sd	ra,24(sp)
ffffffffc0201fc6:	e42e                	sd	a1,8(sp)
ffffffffc0201fc8:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc0201fca:	93bfe0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201fce:	00099797          	auipc	a5,0x99
ffffffffc0201fd2:	79a7b783          	ld	a5,1946(a5) # ffffffffc029b768 <pmm_manager>
ffffffffc0201fd6:	65a2                	ld	a1,8(sp)
ffffffffc0201fd8:	6502                	ld	a0,0(sp)
ffffffffc0201fda:	739c                	ld	a5,32(a5)
ffffffffc0201fdc:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201fde:	60e2                	ld	ra,24(sp)
ffffffffc0201fe0:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201fe2:	91dfe06f          	j	ffffffffc02008fe <intr_enable>

ffffffffc0201fe6 <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0201fe6:	100027f3          	csrr	a5,sstatus
ffffffffc0201fea:	8b89                	andi	a5,a5,2
ffffffffc0201fec:	e799                	bnez	a5,ffffffffc0201ffa <nr_free_pages+0x14>
{
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201fee:	00099797          	auipc	a5,0x99
ffffffffc0201ff2:	77a7b783          	ld	a5,1914(a5) # ffffffffc029b768 <pmm_manager>
ffffffffc0201ff6:	779c                	ld	a5,40(a5)
ffffffffc0201ff8:	8782                	jr	a5
{
ffffffffc0201ffa:	1101                	addi	sp,sp,-32
ffffffffc0201ffc:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201ffe:	907fe0ef          	jal	ffffffffc0200904 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202002:	00099797          	auipc	a5,0x99
ffffffffc0202006:	7667b783          	ld	a5,1894(a5) # ffffffffc029b768 <pmm_manager>
ffffffffc020200a:	779c                	ld	a5,40(a5)
ffffffffc020200c:	9782                	jalr	a5
ffffffffc020200e:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0202010:	8effe0ef          	jal	ffffffffc02008fe <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0202014:	60e2                	ld	ra,24(sp)
ffffffffc0202016:	6522                	ld	a0,8(sp)
ffffffffc0202018:	6105                	addi	sp,sp,32
ffffffffc020201a:	8082                	ret

ffffffffc020201c <get_pte>:
//  la:     the linear address need to map
//  create: a logical value to decide if alloc a page for PT
// return vaule: the kernel virtual address of this pte
pte_t *get_pte(pde_t *pgdir, uintptr_t la, bool create)
{
    pde_t *pdep1 = &pgdir[PDX1(la)];
ffffffffc020201c:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202020:	1ff7f793          	andi	a5,a5,511
ffffffffc0202024:	078e                	slli	a5,a5,0x3
ffffffffc0202026:	00f50733          	add	a4,a0,a5
    if (!(*pdep1 & PTE_V))
ffffffffc020202a:	6314                	ld	a3,0(a4)
{
ffffffffc020202c:	7139                	addi	sp,sp,-64
ffffffffc020202e:	f822                	sd	s0,48(sp)
ffffffffc0202030:	f426                	sd	s1,40(sp)
ffffffffc0202032:	fc06                	sd	ra,56(sp)
    if (!(*pdep1 & PTE_V))
ffffffffc0202034:	0016f793          	andi	a5,a3,1
{
ffffffffc0202038:	842e                	mv	s0,a1
ffffffffc020203a:	8832                	mv	a6,a2
ffffffffc020203c:	00099497          	auipc	s1,0x99
ffffffffc0202040:	74c48493          	addi	s1,s1,1868 # ffffffffc029b788 <npage>
    if (!(*pdep1 & PTE_V))
ffffffffc0202044:	ebd1                	bnez	a5,ffffffffc02020d8 <get_pte+0xbc>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202046:	16060d63          	beqz	a2,ffffffffc02021c0 <get_pte+0x1a4>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020204a:	100027f3          	csrr	a5,sstatus
ffffffffc020204e:	8b89                	andi	a5,a5,2
ffffffffc0202050:	16079e63          	bnez	a5,ffffffffc02021cc <get_pte+0x1b0>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202054:	00099797          	auipc	a5,0x99
ffffffffc0202058:	7147b783          	ld	a5,1812(a5) # ffffffffc029b768 <pmm_manager>
ffffffffc020205c:	4505                	li	a0,1
ffffffffc020205e:	e43a                	sd	a4,8(sp)
ffffffffc0202060:	6f9c                	ld	a5,24(a5)
ffffffffc0202062:	e832                	sd	a2,16(sp)
ffffffffc0202064:	9782                	jalr	a5
ffffffffc0202066:	6722                	ld	a4,8(sp)
ffffffffc0202068:	6842                	ld	a6,16(sp)
ffffffffc020206a:	87aa                	mv	a5,a0
        if (!create || (page = alloc_page()) == NULL)
ffffffffc020206c:	14078a63          	beqz	a5,ffffffffc02021c0 <get_pte+0x1a4>
    return page - pages + nbase;
ffffffffc0202070:	00099517          	auipc	a0,0x99
ffffffffc0202074:	72053503          	ld	a0,1824(a0) # ffffffffc029b790 <pages>
ffffffffc0202078:	000808b7          	lui	a7,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc020207c:	00099497          	auipc	s1,0x99
ffffffffc0202080:	70c48493          	addi	s1,s1,1804 # ffffffffc029b788 <npage>
ffffffffc0202084:	40a78533          	sub	a0,a5,a0
ffffffffc0202088:	8519                	srai	a0,a0,0x6
ffffffffc020208a:	9546                	add	a0,a0,a7
ffffffffc020208c:	6090                	ld	a2,0(s1)
ffffffffc020208e:	00c51693          	slli	a3,a0,0xc
    page->ref = val;
ffffffffc0202092:	4585                	li	a1,1
ffffffffc0202094:	82b1                	srli	a3,a3,0xc
ffffffffc0202096:	c38c                	sw	a1,0(a5)
    return page2ppn(page) << PGSHIFT;
ffffffffc0202098:	0532                	slli	a0,a0,0xc
ffffffffc020209a:	1ac6f763          	bgeu	a3,a2,ffffffffc0202248 <get_pte+0x22c>
ffffffffc020209e:	00099697          	auipc	a3,0x99
ffffffffc02020a2:	6e26b683          	ld	a3,1762(a3) # ffffffffc029b780 <va_pa_offset>
ffffffffc02020a6:	6605                	lui	a2,0x1
ffffffffc02020a8:	4581                	li	a1,0
ffffffffc02020aa:	9536                	add	a0,a0,a3
ffffffffc02020ac:	ec42                	sd	a6,24(sp)
ffffffffc02020ae:	e83e                	sd	a5,16(sp)
ffffffffc02020b0:	e43a                	sd	a4,8(sp)
ffffffffc02020b2:	0a3030ef          	jal	ffffffffc0205954 <memset>
    return page - pages + nbase;
ffffffffc02020b6:	00099697          	auipc	a3,0x99
ffffffffc02020ba:	6da6b683          	ld	a3,1754(a3) # ffffffffc029b790 <pages>
ffffffffc02020be:	67c2                	ld	a5,16(sp)
ffffffffc02020c0:	000808b7          	lui	a7,0x80
        *pdep1 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc02020c4:	6722                	ld	a4,8(sp)
ffffffffc02020c6:	40d786b3          	sub	a3,a5,a3
ffffffffc02020ca:	8699                	srai	a3,a3,0x6
ffffffffc02020cc:	96c6                	add	a3,a3,a7
}

// construct PTE from a page and permission bits
static inline pte_t pte_create(uintptr_t ppn, int type)
{
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc02020ce:	06aa                	slli	a3,a3,0xa
ffffffffc02020d0:	6862                	ld	a6,24(sp)
ffffffffc02020d2:	0116e693          	ori	a3,a3,17
ffffffffc02020d6:	e314                	sd	a3,0(a4)
    }

    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc02020d8:	c006f693          	andi	a3,a3,-1024
ffffffffc02020dc:	6098                	ld	a4,0(s1)
ffffffffc02020de:	068a                	slli	a3,a3,0x2
ffffffffc02020e0:	00c6d793          	srli	a5,a3,0xc
ffffffffc02020e4:	14e7f663          	bgeu	a5,a4,ffffffffc0202230 <get_pte+0x214>
ffffffffc02020e8:	00099897          	auipc	a7,0x99
ffffffffc02020ec:	69888893          	addi	a7,a7,1688 # ffffffffc029b780 <va_pa_offset>
ffffffffc02020f0:	0008b603          	ld	a2,0(a7)
ffffffffc02020f4:	01545793          	srli	a5,s0,0x15
ffffffffc02020f8:	1ff7f793          	andi	a5,a5,511
ffffffffc02020fc:	96b2                	add	a3,a3,a2
ffffffffc02020fe:	078e                	slli	a5,a5,0x3
ffffffffc0202100:	97b6                	add	a5,a5,a3
    if (!(*pdep0 & PTE_V))
ffffffffc0202102:	6394                	ld	a3,0(a5)
ffffffffc0202104:	0016f613          	andi	a2,a3,1
ffffffffc0202108:	e659                	bnez	a2,ffffffffc0202196 <get_pte+0x17a>
    {
        struct Page *page;
        if (!create || (page = alloc_page()) == NULL)
ffffffffc020210a:	0a080b63          	beqz	a6,ffffffffc02021c0 <get_pte+0x1a4>
ffffffffc020210e:	10002773          	csrr	a4,sstatus
ffffffffc0202112:	8b09                	andi	a4,a4,2
ffffffffc0202114:	ef71                	bnez	a4,ffffffffc02021f0 <get_pte+0x1d4>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202116:	00099717          	auipc	a4,0x99
ffffffffc020211a:	65273703          	ld	a4,1618(a4) # ffffffffc029b768 <pmm_manager>
ffffffffc020211e:	4505                	li	a0,1
ffffffffc0202120:	e43e                	sd	a5,8(sp)
ffffffffc0202122:	6f18                	ld	a4,24(a4)
ffffffffc0202124:	9702                	jalr	a4
ffffffffc0202126:	67a2                	ld	a5,8(sp)
ffffffffc0202128:	872a                	mv	a4,a0
ffffffffc020212a:	00099897          	auipc	a7,0x99
ffffffffc020212e:	65688893          	addi	a7,a7,1622 # ffffffffc029b780 <va_pa_offset>
        if (!create || (page = alloc_page()) == NULL)
ffffffffc0202132:	c759                	beqz	a4,ffffffffc02021c0 <get_pte+0x1a4>
    return page - pages + nbase;
ffffffffc0202134:	00099697          	auipc	a3,0x99
ffffffffc0202138:	65c6b683          	ld	a3,1628(a3) # ffffffffc029b790 <pages>
ffffffffc020213c:	00080837          	lui	a6,0x80
        {
            return NULL;
        }
        set_page_ref(page, 1);
        uintptr_t pa = page2pa(page);
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202140:	608c                	ld	a1,0(s1)
ffffffffc0202142:	40d706b3          	sub	a3,a4,a3
ffffffffc0202146:	8699                	srai	a3,a3,0x6
ffffffffc0202148:	96c2                	add	a3,a3,a6
ffffffffc020214a:	00c69613          	slli	a2,a3,0xc
    page->ref = val;
ffffffffc020214e:	4505                	li	a0,1
ffffffffc0202150:	8231                	srli	a2,a2,0xc
ffffffffc0202152:	c308                	sw	a0,0(a4)
    return page2ppn(page) << PGSHIFT;
ffffffffc0202154:	06b2                	slli	a3,a3,0xc
ffffffffc0202156:	10b67663          	bgeu	a2,a1,ffffffffc0202262 <get_pte+0x246>
ffffffffc020215a:	0008b503          	ld	a0,0(a7)
ffffffffc020215e:	6605                	lui	a2,0x1
ffffffffc0202160:	4581                	li	a1,0
ffffffffc0202162:	9536                	add	a0,a0,a3
ffffffffc0202164:	e83a                	sd	a4,16(sp)
ffffffffc0202166:	e43e                	sd	a5,8(sp)
ffffffffc0202168:	7ec030ef          	jal	ffffffffc0205954 <memset>
    return page - pages + nbase;
ffffffffc020216c:	00099697          	auipc	a3,0x99
ffffffffc0202170:	6246b683          	ld	a3,1572(a3) # ffffffffc029b790 <pages>
ffffffffc0202174:	6742                	ld	a4,16(sp)
ffffffffc0202176:	00080837          	lui	a6,0x80
        *pdep0 = pte_create(page2ppn(page), PTE_U | PTE_V);
ffffffffc020217a:	67a2                	ld	a5,8(sp)
ffffffffc020217c:	40d706b3          	sub	a3,a4,a3
ffffffffc0202180:	8699                	srai	a3,a3,0x6
ffffffffc0202182:	96c2                	add	a3,a3,a6
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc0202184:	06aa                	slli	a3,a3,0xa
ffffffffc0202186:	0116e693          	ori	a3,a3,17
ffffffffc020218a:	e394                	sd	a3,0(a5)
    }
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc020218c:	6098                	ld	a4,0(s1)
ffffffffc020218e:	00099897          	auipc	a7,0x99
ffffffffc0202192:	5f288893          	addi	a7,a7,1522 # ffffffffc029b780 <va_pa_offset>
ffffffffc0202196:	c006f693          	andi	a3,a3,-1024
ffffffffc020219a:	068a                	slli	a3,a3,0x2
ffffffffc020219c:	00c6d793          	srli	a5,a3,0xc
ffffffffc02021a0:	06e7fc63          	bgeu	a5,a4,ffffffffc0202218 <get_pte+0x1fc>
ffffffffc02021a4:	0008b783          	ld	a5,0(a7)
ffffffffc02021a8:	8031                	srli	s0,s0,0xc
ffffffffc02021aa:	1ff47413          	andi	s0,s0,511
ffffffffc02021ae:	040e                	slli	s0,s0,0x3
ffffffffc02021b0:	96be                	add	a3,a3,a5
}
ffffffffc02021b2:	70e2                	ld	ra,56(sp)
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc02021b4:	00868533          	add	a0,a3,s0
}
ffffffffc02021b8:	7442                	ld	s0,48(sp)
ffffffffc02021ba:	74a2                	ld	s1,40(sp)
ffffffffc02021bc:	6121                	addi	sp,sp,64
ffffffffc02021be:	8082                	ret
ffffffffc02021c0:	70e2                	ld	ra,56(sp)
ffffffffc02021c2:	7442                	ld	s0,48(sp)
ffffffffc02021c4:	74a2                	ld	s1,40(sp)
            return NULL;
ffffffffc02021c6:	4501                	li	a0,0
}
ffffffffc02021c8:	6121                	addi	sp,sp,64
ffffffffc02021ca:	8082                	ret
        intr_disable();
ffffffffc02021cc:	e83a                	sd	a4,16(sp)
ffffffffc02021ce:	ec32                	sd	a2,24(sp)
ffffffffc02021d0:	f34fe0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02021d4:	00099797          	auipc	a5,0x99
ffffffffc02021d8:	5947b783          	ld	a5,1428(a5) # ffffffffc029b768 <pmm_manager>
ffffffffc02021dc:	4505                	li	a0,1
ffffffffc02021de:	6f9c                	ld	a5,24(a5)
ffffffffc02021e0:	9782                	jalr	a5
ffffffffc02021e2:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc02021e4:	f1afe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc02021e8:	6862                	ld	a6,24(sp)
ffffffffc02021ea:	6742                	ld	a4,16(sp)
ffffffffc02021ec:	67a2                	ld	a5,8(sp)
ffffffffc02021ee:	bdbd                	j	ffffffffc020206c <get_pte+0x50>
        intr_disable();
ffffffffc02021f0:	e83e                	sd	a5,16(sp)
ffffffffc02021f2:	f12fe0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc02021f6:	00099717          	auipc	a4,0x99
ffffffffc02021fa:	57273703          	ld	a4,1394(a4) # ffffffffc029b768 <pmm_manager>
ffffffffc02021fe:	4505                	li	a0,1
ffffffffc0202200:	6f18                	ld	a4,24(a4)
ffffffffc0202202:	9702                	jalr	a4
ffffffffc0202204:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0202206:	ef8fe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc020220a:	6722                	ld	a4,8(sp)
ffffffffc020220c:	67c2                	ld	a5,16(sp)
ffffffffc020220e:	00099897          	auipc	a7,0x99
ffffffffc0202212:	57288893          	addi	a7,a7,1394 # ffffffffc029b780 <va_pa_offset>
ffffffffc0202216:	bf31                	j	ffffffffc0202132 <get_pte+0x116>
    return &((pte_t *)KADDR(PDE_ADDR(*pdep0)))[PTX(la)];
ffffffffc0202218:	00004617          	auipc	a2,0x4
ffffffffc020221c:	51060613          	addi	a2,a2,1296 # ffffffffc0206728 <etext+0xdaa>
ffffffffc0202220:	0fa00593          	li	a1,250
ffffffffc0202224:	00004517          	auipc	a0,0x4
ffffffffc0202228:	5f450513          	addi	a0,a0,1524 # ffffffffc0206818 <etext+0xe9a>
ffffffffc020222c:	a1afe0ef          	jal	ffffffffc0200446 <__panic>
    pde_t *pdep0 = &((pde_t *)KADDR(PDE_ADDR(*pdep1)))[PDX0(la)];
ffffffffc0202230:	00004617          	auipc	a2,0x4
ffffffffc0202234:	4f860613          	addi	a2,a2,1272 # ffffffffc0206728 <etext+0xdaa>
ffffffffc0202238:	0ed00593          	li	a1,237
ffffffffc020223c:	00004517          	auipc	a0,0x4
ffffffffc0202240:	5dc50513          	addi	a0,a0,1500 # ffffffffc0206818 <etext+0xe9a>
ffffffffc0202244:	a02fe0ef          	jal	ffffffffc0200446 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202248:	86aa                	mv	a3,a0
ffffffffc020224a:	00004617          	auipc	a2,0x4
ffffffffc020224e:	4de60613          	addi	a2,a2,1246 # ffffffffc0206728 <etext+0xdaa>
ffffffffc0202252:	0e900593          	li	a1,233
ffffffffc0202256:	00004517          	auipc	a0,0x4
ffffffffc020225a:	5c250513          	addi	a0,a0,1474 # ffffffffc0206818 <etext+0xe9a>
ffffffffc020225e:	9e8fe0ef          	jal	ffffffffc0200446 <__panic>
        memset(KADDR(pa), 0, PGSIZE);
ffffffffc0202262:	00004617          	auipc	a2,0x4
ffffffffc0202266:	4c660613          	addi	a2,a2,1222 # ffffffffc0206728 <etext+0xdaa>
ffffffffc020226a:	0f700593          	li	a1,247
ffffffffc020226e:	00004517          	auipc	a0,0x4
ffffffffc0202272:	5aa50513          	addi	a0,a0,1450 # ffffffffc0206818 <etext+0xe9a>
ffffffffc0202276:	9d0fe0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc020227a <get_page>:

// get_page - get related Page struct for linear address la using PDT pgdir
struct Page *get_page(pde_t *pgdir, uintptr_t la, pte_t **ptep_store)
{
ffffffffc020227a:	1141                	addi	sp,sp,-16
ffffffffc020227c:	e022                	sd	s0,0(sp)
ffffffffc020227e:	8432                	mv	s0,a2
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202280:	4601                	li	a2,0
{
ffffffffc0202282:	e406                	sd	ra,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc0202284:	d99ff0ef          	jal	ffffffffc020201c <get_pte>
    if (ptep_store != NULL)
ffffffffc0202288:	c011                	beqz	s0,ffffffffc020228c <get_page+0x12>
    {
        *ptep_store = ptep;
ffffffffc020228a:	e008                	sd	a0,0(s0)
    }
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc020228c:	c511                	beqz	a0,ffffffffc0202298 <get_page+0x1e>
ffffffffc020228e:	611c                	ld	a5,0(a0)
    {
        return pte2page(*ptep);
    }
    return NULL;
ffffffffc0202290:	4501                	li	a0,0
    if (ptep != NULL && *ptep & PTE_V)
ffffffffc0202292:	0017f713          	andi	a4,a5,1
ffffffffc0202296:	e709                	bnez	a4,ffffffffc02022a0 <get_page+0x26>
}
ffffffffc0202298:	60a2                	ld	ra,8(sp)
ffffffffc020229a:	6402                	ld	s0,0(sp)
ffffffffc020229c:	0141                	addi	sp,sp,16
ffffffffc020229e:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc02022a0:	00099717          	auipc	a4,0x99
ffffffffc02022a4:	4e873703          	ld	a4,1256(a4) # ffffffffc029b788 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc02022a8:	078a                	slli	a5,a5,0x2
ffffffffc02022aa:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02022ac:	00e7ff63          	bgeu	a5,a4,ffffffffc02022ca <get_page+0x50>
    return &pages[PPN(pa) - nbase];
ffffffffc02022b0:	00099517          	auipc	a0,0x99
ffffffffc02022b4:	4e053503          	ld	a0,1248(a0) # ffffffffc029b790 <pages>
ffffffffc02022b8:	60a2                	ld	ra,8(sp)
ffffffffc02022ba:	6402                	ld	s0,0(sp)
ffffffffc02022bc:	079a                	slli	a5,a5,0x6
ffffffffc02022be:	fe000737          	lui	a4,0xfe000
ffffffffc02022c2:	97ba                	add	a5,a5,a4
ffffffffc02022c4:	953e                	add	a0,a0,a5
ffffffffc02022c6:	0141                	addi	sp,sp,16
ffffffffc02022c8:	8082                	ret
ffffffffc02022ca:	c8fff0ef          	jal	ffffffffc0201f58 <pa2page.part.0>

ffffffffc02022ce <unmap_range>:
        tlb_invalidate(pgdir, la);
    }
}

void unmap_range(pde_t *pgdir, uintptr_t start, uintptr_t end)
{
ffffffffc02022ce:	715d                	addi	sp,sp,-80
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022d0:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc02022d4:	e486                	sd	ra,72(sp)
ffffffffc02022d6:	e0a2                	sd	s0,64(sp)
ffffffffc02022d8:	fc26                	sd	s1,56(sp)
ffffffffc02022da:	f84a                	sd	s2,48(sp)
ffffffffc02022dc:	f44e                	sd	s3,40(sp)
ffffffffc02022de:	f052                	sd	s4,32(sp)
ffffffffc02022e0:	ec56                	sd	s5,24(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02022e2:	03479713          	slli	a4,a5,0x34
ffffffffc02022e6:	ef61                	bnez	a4,ffffffffc02023be <unmap_range+0xf0>
    assert(USER_ACCESS(start, end));
ffffffffc02022e8:	00200a37          	lui	s4,0x200
ffffffffc02022ec:	00c5b7b3          	sltu	a5,a1,a2
ffffffffc02022f0:	0145b733          	sltu	a4,a1,s4
ffffffffc02022f4:	0017b793          	seqz	a5,a5
ffffffffc02022f8:	8fd9                	or	a5,a5,a4
ffffffffc02022fa:	842e                	mv	s0,a1
ffffffffc02022fc:	84b2                	mv	s1,a2
ffffffffc02022fe:	e3e5                	bnez	a5,ffffffffc02023de <unmap_range+0x110>
ffffffffc0202300:	4785                	li	a5,1
ffffffffc0202302:	07fe                	slli	a5,a5,0x1f
ffffffffc0202304:	0785                	addi	a5,a5,1
ffffffffc0202306:	892a                	mv	s2,a0
ffffffffc0202308:	6985                	lui	s3,0x1
    do
    {
        pte_t *ptep = get_pte(pgdir, start, 0);
        if (ptep == NULL)
        {
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020230a:	ffe00ab7          	lui	s5,0xffe00
    assert(USER_ACCESS(start, end));
ffffffffc020230e:	0cf67863          	bgeu	a2,a5,ffffffffc02023de <unmap_range+0x110>
        pte_t *ptep = get_pte(pgdir, start, 0);
ffffffffc0202312:	4601                	li	a2,0
ffffffffc0202314:	85a2                	mv	a1,s0
ffffffffc0202316:	854a                	mv	a0,s2
ffffffffc0202318:	d05ff0ef          	jal	ffffffffc020201c <get_pte>
ffffffffc020231c:	87aa                	mv	a5,a0
        if (ptep == NULL)
ffffffffc020231e:	cd31                	beqz	a0,ffffffffc020237a <unmap_range+0xac>
            continue;
        }
        if (*ptep != 0)
ffffffffc0202320:	6118                	ld	a4,0(a0)
ffffffffc0202322:	ef11                	bnez	a4,ffffffffc020233e <unmap_range+0x70>
        {
            page_remove_pte(pgdir, start, ptep);
        }
        start += PGSIZE;
ffffffffc0202324:	944e                	add	s0,s0,s3
    } while (start != 0 && start < end);
ffffffffc0202326:	c019                	beqz	s0,ffffffffc020232c <unmap_range+0x5e>
ffffffffc0202328:	fe9465e3          	bltu	s0,s1,ffffffffc0202312 <unmap_range+0x44>
}
ffffffffc020232c:	60a6                	ld	ra,72(sp)
ffffffffc020232e:	6406                	ld	s0,64(sp)
ffffffffc0202330:	74e2                	ld	s1,56(sp)
ffffffffc0202332:	7942                	ld	s2,48(sp)
ffffffffc0202334:	79a2                	ld	s3,40(sp)
ffffffffc0202336:	7a02                	ld	s4,32(sp)
ffffffffc0202338:	6ae2                	ld	s5,24(sp)
ffffffffc020233a:	6161                	addi	sp,sp,80
ffffffffc020233c:	8082                	ret
    if (*ptep & PTE_V)
ffffffffc020233e:	00177693          	andi	a3,a4,1
ffffffffc0202342:	d2ed                	beqz	a3,ffffffffc0202324 <unmap_range+0x56>
    if (PPN(pa) >= npage)
ffffffffc0202344:	00099697          	auipc	a3,0x99
ffffffffc0202348:	4446b683          	ld	a3,1092(a3) # ffffffffc029b788 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc020234c:	070a                	slli	a4,a4,0x2
ffffffffc020234e:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc0202350:	0ad77763          	bgeu	a4,a3,ffffffffc02023fe <unmap_range+0x130>
    return &pages[PPN(pa) - nbase];
ffffffffc0202354:	00099517          	auipc	a0,0x99
ffffffffc0202358:	43c53503          	ld	a0,1084(a0) # ffffffffc029b790 <pages>
ffffffffc020235c:	071a                	slli	a4,a4,0x6
ffffffffc020235e:	fe0006b7          	lui	a3,0xfe000
ffffffffc0202362:	9736                	add	a4,a4,a3
ffffffffc0202364:	953a                	add	a0,a0,a4
    page->ref -= 1;
ffffffffc0202366:	4118                	lw	a4,0(a0)
ffffffffc0202368:	377d                	addiw	a4,a4,-1 # fffffffffdffffff <end+0x3dd64847>
ffffffffc020236a:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc020236c:	cb19                	beqz	a4,ffffffffc0202382 <unmap_range+0xb4>
        *ptep = 0;
ffffffffc020236e:	0007b023          	sd	zero,0(a5)

// invalidate a TLB entry, but only if the page tables being
// edited are the ones currently in use by the processor.
void tlb_invalidate(pde_t *pgdir, uintptr_t la)
{
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202372:	12040073          	sfence.vma	s0
        start += PGSIZE;
ffffffffc0202376:	944e                	add	s0,s0,s3
ffffffffc0202378:	b77d                	j	ffffffffc0202326 <unmap_range+0x58>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc020237a:	9452                	add	s0,s0,s4
ffffffffc020237c:	01547433          	and	s0,s0,s5
            continue;
ffffffffc0202380:	b75d                	j	ffffffffc0202326 <unmap_range+0x58>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202382:	10002773          	csrr	a4,sstatus
ffffffffc0202386:	8b09                	andi	a4,a4,2
ffffffffc0202388:	eb19                	bnez	a4,ffffffffc020239e <unmap_range+0xd0>
        pmm_manager->free_pages(base, n);
ffffffffc020238a:	00099717          	auipc	a4,0x99
ffffffffc020238e:	3de73703          	ld	a4,990(a4) # ffffffffc029b768 <pmm_manager>
ffffffffc0202392:	4585                	li	a1,1
ffffffffc0202394:	e03e                	sd	a5,0(sp)
ffffffffc0202396:	7318                	ld	a4,32(a4)
ffffffffc0202398:	9702                	jalr	a4
    if (flag)
ffffffffc020239a:	6782                	ld	a5,0(sp)
ffffffffc020239c:	bfc9                	j	ffffffffc020236e <unmap_range+0xa0>
        intr_disable();
ffffffffc020239e:	e43e                	sd	a5,8(sp)
ffffffffc02023a0:	e02a                	sd	a0,0(sp)
ffffffffc02023a2:	d62fe0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc02023a6:	00099717          	auipc	a4,0x99
ffffffffc02023aa:	3c273703          	ld	a4,962(a4) # ffffffffc029b768 <pmm_manager>
ffffffffc02023ae:	6502                	ld	a0,0(sp)
ffffffffc02023b0:	4585                	li	a1,1
ffffffffc02023b2:	7318                	ld	a4,32(a4)
ffffffffc02023b4:	9702                	jalr	a4
        intr_enable();
ffffffffc02023b6:	d48fe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc02023ba:	67a2                	ld	a5,8(sp)
ffffffffc02023bc:	bf4d                	j	ffffffffc020236e <unmap_range+0xa0>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02023be:	00004697          	auipc	a3,0x4
ffffffffc02023c2:	46a68693          	addi	a3,a3,1130 # ffffffffc0206828 <etext+0xeaa>
ffffffffc02023c6:	00004617          	auipc	a2,0x4
ffffffffc02023ca:	fb260613          	addi	a2,a2,-78 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02023ce:	12000593          	li	a1,288
ffffffffc02023d2:	00004517          	auipc	a0,0x4
ffffffffc02023d6:	44650513          	addi	a0,a0,1094 # ffffffffc0206818 <etext+0xe9a>
ffffffffc02023da:	86cfe0ef          	jal	ffffffffc0200446 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02023de:	00004697          	auipc	a3,0x4
ffffffffc02023e2:	47a68693          	addi	a3,a3,1146 # ffffffffc0206858 <etext+0xeda>
ffffffffc02023e6:	00004617          	auipc	a2,0x4
ffffffffc02023ea:	f9260613          	addi	a2,a2,-110 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02023ee:	12100593          	li	a1,289
ffffffffc02023f2:	00004517          	auipc	a0,0x4
ffffffffc02023f6:	42650513          	addi	a0,a0,1062 # ffffffffc0206818 <etext+0xe9a>
ffffffffc02023fa:	84cfe0ef          	jal	ffffffffc0200446 <__panic>
ffffffffc02023fe:	b5bff0ef          	jal	ffffffffc0201f58 <pa2page.part.0>

ffffffffc0202402 <exit_range>:
{
ffffffffc0202402:	7135                	addi	sp,sp,-160
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202404:	00c5e7b3          	or	a5,a1,a2
{
ffffffffc0202408:	ed06                	sd	ra,152(sp)
ffffffffc020240a:	e922                	sd	s0,144(sp)
ffffffffc020240c:	e526                	sd	s1,136(sp)
ffffffffc020240e:	e14a                	sd	s2,128(sp)
ffffffffc0202410:	fcce                	sd	s3,120(sp)
ffffffffc0202412:	f8d2                	sd	s4,112(sp)
ffffffffc0202414:	f4d6                	sd	s5,104(sp)
ffffffffc0202416:	f0da                	sd	s6,96(sp)
ffffffffc0202418:	ecde                	sd	s7,88(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc020241a:	17d2                	slli	a5,a5,0x34
ffffffffc020241c:	22079263          	bnez	a5,ffffffffc0202640 <exit_range+0x23e>
    assert(USER_ACCESS(start, end));
ffffffffc0202420:	00200937          	lui	s2,0x200
ffffffffc0202424:	00c5b7b3          	sltu	a5,a1,a2
ffffffffc0202428:	0125b733          	sltu	a4,a1,s2
ffffffffc020242c:	0017b793          	seqz	a5,a5
ffffffffc0202430:	8fd9                	or	a5,a5,a4
ffffffffc0202432:	26079263          	bnez	a5,ffffffffc0202696 <exit_range+0x294>
ffffffffc0202436:	4785                	li	a5,1
ffffffffc0202438:	07fe                	slli	a5,a5,0x1f
ffffffffc020243a:	0785                	addi	a5,a5,1
ffffffffc020243c:	24f67d63          	bgeu	a2,a5,ffffffffc0202696 <exit_range+0x294>
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc0202440:	c00004b7          	lui	s1,0xc0000
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc0202444:	ffe007b7          	lui	a5,0xffe00
ffffffffc0202448:	8a2a                	mv	s4,a0
    d1start = ROUNDDOWN(start, PDSIZE);
ffffffffc020244a:	8ced                	and	s1,s1,a1
    d0start = ROUNDDOWN(start, PTSIZE);
ffffffffc020244c:	00f5f833          	and	a6,a1,a5
    if (PPN(pa) >= npage)
ffffffffc0202450:	00099a97          	auipc	s5,0x99
ffffffffc0202454:	338a8a93          	addi	s5,s5,824 # ffffffffc029b788 <npage>
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc0202458:	400009b7          	lui	s3,0x40000
ffffffffc020245c:	a809                	j	ffffffffc020246e <exit_range+0x6c>
        d1start += PDSIZE;
ffffffffc020245e:	013487b3          	add	a5,s1,s3
ffffffffc0202462:	400004b7          	lui	s1,0x40000
        d0start = d1start;
ffffffffc0202466:	8826                	mv	a6,s1
    } while (d1start != 0 && d1start < end);
ffffffffc0202468:	c3f1                	beqz	a5,ffffffffc020252c <exit_range+0x12a>
ffffffffc020246a:	0cc7f163          	bgeu	a5,a2,ffffffffc020252c <exit_range+0x12a>
        pde1 = pgdir[PDX1(d1start)];
ffffffffc020246e:	01e4d413          	srli	s0,s1,0x1e
ffffffffc0202472:	1ff47413          	andi	s0,s0,511
ffffffffc0202476:	040e                	slli	s0,s0,0x3
ffffffffc0202478:	9452                	add	s0,s0,s4
ffffffffc020247a:	00043883          	ld	a7,0(s0)
        if (pde1 & PTE_V)
ffffffffc020247e:	0018f793          	andi	a5,a7,1
ffffffffc0202482:	dff1                	beqz	a5,ffffffffc020245e <exit_range+0x5c>
ffffffffc0202484:	000ab783          	ld	a5,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202488:	088a                	slli	a7,a7,0x2
ffffffffc020248a:	00c8d893          	srli	a7,a7,0xc
    if (PPN(pa) >= npage)
ffffffffc020248e:	20f8f263          	bgeu	a7,a5,ffffffffc0202692 <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc0202492:	fff802b7          	lui	t0,0xfff80
ffffffffc0202496:	00588f33          	add	t5,a7,t0
    return page - pages + nbase;
ffffffffc020249a:	000803b7          	lui	t2,0x80
ffffffffc020249e:	007f0733          	add	a4,t5,t2
    return page2ppn(page) << PGSHIFT;
ffffffffc02024a2:	00c71e13          	slli	t3,a4,0xc
    return &pages[PPN(pa) - nbase];
ffffffffc02024a6:	0f1a                	slli	t5,t5,0x6
    return KADDR(page2pa(page));
ffffffffc02024a8:	1cf77863          	bgeu	a4,a5,ffffffffc0202678 <exit_range+0x276>
ffffffffc02024ac:	00099f97          	auipc	t6,0x99
ffffffffc02024b0:	2d4f8f93          	addi	t6,t6,724 # ffffffffc029b780 <va_pa_offset>
ffffffffc02024b4:	000fb783          	ld	a5,0(t6)
            free_pd0 = 1;
ffffffffc02024b8:	4e85                	li	t4,1
ffffffffc02024ba:	6b05                	lui	s6,0x1
ffffffffc02024bc:	9e3e                	add	t3,t3,a5
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc02024be:	01348333          	add	t1,s1,s3
                pde0 = pd0[PDX0(d0start)];
ffffffffc02024c2:	01585713          	srli	a4,a6,0x15
ffffffffc02024c6:	1ff77713          	andi	a4,a4,511
ffffffffc02024ca:	070e                	slli	a4,a4,0x3
ffffffffc02024cc:	9772                	add	a4,a4,t3
ffffffffc02024ce:	631c                	ld	a5,0(a4)
                if (pde0 & PTE_V)
ffffffffc02024d0:	0017f693          	andi	a3,a5,1
ffffffffc02024d4:	e6bd                	bnez	a3,ffffffffc0202542 <exit_range+0x140>
                    free_pd0 = 0;
ffffffffc02024d6:	4e81                	li	t4,0
                d0start += PTSIZE;
ffffffffc02024d8:	984a                	add	a6,a6,s2
            } while (d0start != 0 && d0start < d1start + PDSIZE && d0start < end);
ffffffffc02024da:	00080863          	beqz	a6,ffffffffc02024ea <exit_range+0xe8>
ffffffffc02024de:	879a                	mv	a5,t1
ffffffffc02024e0:	00667363          	bgeu	a2,t1,ffffffffc02024e6 <exit_range+0xe4>
ffffffffc02024e4:	87b2                	mv	a5,a2
ffffffffc02024e6:	fcf86ee3          	bltu	a6,a5,ffffffffc02024c2 <exit_range+0xc0>
            if (free_pd0)
ffffffffc02024ea:	f60e8ae3          	beqz	t4,ffffffffc020245e <exit_range+0x5c>
    if (PPN(pa) >= npage)
ffffffffc02024ee:	000ab783          	ld	a5,0(s5)
ffffffffc02024f2:	1af8f063          	bgeu	a7,a5,ffffffffc0202692 <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc02024f6:	00099517          	auipc	a0,0x99
ffffffffc02024fa:	29a53503          	ld	a0,666(a0) # ffffffffc029b790 <pages>
ffffffffc02024fe:	957a                	add	a0,a0,t5
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202500:	100027f3          	csrr	a5,sstatus
ffffffffc0202504:	8b89                	andi	a5,a5,2
ffffffffc0202506:	10079b63          	bnez	a5,ffffffffc020261c <exit_range+0x21a>
        pmm_manager->free_pages(base, n);
ffffffffc020250a:	00099797          	auipc	a5,0x99
ffffffffc020250e:	25e7b783          	ld	a5,606(a5) # ffffffffc029b768 <pmm_manager>
ffffffffc0202512:	4585                	li	a1,1
ffffffffc0202514:	e432                	sd	a2,8(sp)
ffffffffc0202516:	739c                	ld	a5,32(a5)
ffffffffc0202518:	9782                	jalr	a5
ffffffffc020251a:	6622                	ld	a2,8(sp)
                pgdir[PDX1(d1start)] = 0;
ffffffffc020251c:	00043023          	sd	zero,0(s0)
        d1start += PDSIZE;
ffffffffc0202520:	013487b3          	add	a5,s1,s3
ffffffffc0202524:	400004b7          	lui	s1,0x40000
        d0start = d1start;
ffffffffc0202528:	8826                	mv	a6,s1
    } while (d1start != 0 && d1start < end);
ffffffffc020252a:	f3a1                	bnez	a5,ffffffffc020246a <exit_range+0x68>
}
ffffffffc020252c:	60ea                	ld	ra,152(sp)
ffffffffc020252e:	644a                	ld	s0,144(sp)
ffffffffc0202530:	64aa                	ld	s1,136(sp)
ffffffffc0202532:	690a                	ld	s2,128(sp)
ffffffffc0202534:	79e6                	ld	s3,120(sp)
ffffffffc0202536:	7a46                	ld	s4,112(sp)
ffffffffc0202538:	7aa6                	ld	s5,104(sp)
ffffffffc020253a:	7b06                	ld	s6,96(sp)
ffffffffc020253c:	6be6                	ld	s7,88(sp)
ffffffffc020253e:	610d                	addi	sp,sp,160
ffffffffc0202540:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc0202542:	000ab503          	ld	a0,0(s5)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202546:	078a                	slli	a5,a5,0x2
ffffffffc0202548:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020254a:	14a7f463          	bgeu	a5,a0,ffffffffc0202692 <exit_range+0x290>
    return &pages[PPN(pa) - nbase];
ffffffffc020254e:	9796                	add	a5,a5,t0
    return page - pages + nbase;
ffffffffc0202550:	00778bb3          	add	s7,a5,t2
    return &pages[PPN(pa) - nbase];
ffffffffc0202554:	00679593          	slli	a1,a5,0x6
    return page2ppn(page) << PGSHIFT;
ffffffffc0202558:	00cb9693          	slli	a3,s7,0xc
    return KADDR(page2pa(page));
ffffffffc020255c:	10abf263          	bgeu	s7,a0,ffffffffc0202660 <exit_range+0x25e>
ffffffffc0202560:	000fb783          	ld	a5,0(t6)
ffffffffc0202564:	96be                	add	a3,a3,a5
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc0202566:	01668533          	add	a0,a3,s6
                        if (pt[i] & PTE_V)
ffffffffc020256a:	629c                	ld	a5,0(a3)
ffffffffc020256c:	8b85                	andi	a5,a5,1
ffffffffc020256e:	f7ad                	bnez	a5,ffffffffc02024d8 <exit_range+0xd6>
                    for (int i = 0; i < NPTEENTRY; i++)
ffffffffc0202570:	06a1                	addi	a3,a3,8
ffffffffc0202572:	fea69ce3          	bne	a3,a0,ffffffffc020256a <exit_range+0x168>
    return &pages[PPN(pa) - nbase];
ffffffffc0202576:	00099517          	auipc	a0,0x99
ffffffffc020257a:	21a53503          	ld	a0,538(a0) # ffffffffc029b790 <pages>
ffffffffc020257e:	952e                	add	a0,a0,a1
ffffffffc0202580:	100027f3          	csrr	a5,sstatus
ffffffffc0202584:	8b89                	andi	a5,a5,2
ffffffffc0202586:	e3b9                	bnez	a5,ffffffffc02025cc <exit_range+0x1ca>
        pmm_manager->free_pages(base, n);
ffffffffc0202588:	00099797          	auipc	a5,0x99
ffffffffc020258c:	1e07b783          	ld	a5,480(a5) # ffffffffc029b768 <pmm_manager>
ffffffffc0202590:	4585                	li	a1,1
ffffffffc0202592:	e0b2                	sd	a2,64(sp)
ffffffffc0202594:	739c                	ld	a5,32(a5)
ffffffffc0202596:	fc1a                	sd	t1,56(sp)
ffffffffc0202598:	f846                	sd	a7,48(sp)
ffffffffc020259a:	f47a                	sd	t5,40(sp)
ffffffffc020259c:	f072                	sd	t3,32(sp)
ffffffffc020259e:	ec76                	sd	t4,24(sp)
ffffffffc02025a0:	e842                	sd	a6,16(sp)
ffffffffc02025a2:	e43a                	sd	a4,8(sp)
ffffffffc02025a4:	9782                	jalr	a5
    if (flag)
ffffffffc02025a6:	6722                	ld	a4,8(sp)
ffffffffc02025a8:	6842                	ld	a6,16(sp)
ffffffffc02025aa:	6ee2                	ld	t4,24(sp)
ffffffffc02025ac:	7e02                	ld	t3,32(sp)
ffffffffc02025ae:	7f22                	ld	t5,40(sp)
ffffffffc02025b0:	78c2                	ld	a7,48(sp)
ffffffffc02025b2:	7362                	ld	t1,56(sp)
ffffffffc02025b4:	6606                	ld	a2,64(sp)
                        pd0[PDX0(d0start)] = 0;
ffffffffc02025b6:	fff802b7          	lui	t0,0xfff80
ffffffffc02025ba:	000803b7          	lui	t2,0x80
ffffffffc02025be:	00099f97          	auipc	t6,0x99
ffffffffc02025c2:	1c2f8f93          	addi	t6,t6,450 # ffffffffc029b780 <va_pa_offset>
ffffffffc02025c6:	00073023          	sd	zero,0(a4)
ffffffffc02025ca:	b739                	j	ffffffffc02024d8 <exit_range+0xd6>
        intr_disable();
ffffffffc02025cc:	e4b2                	sd	a2,72(sp)
ffffffffc02025ce:	e09a                	sd	t1,64(sp)
ffffffffc02025d0:	fc46                	sd	a7,56(sp)
ffffffffc02025d2:	f47a                	sd	t5,40(sp)
ffffffffc02025d4:	f072                	sd	t3,32(sp)
ffffffffc02025d6:	ec76                	sd	t4,24(sp)
ffffffffc02025d8:	e842                	sd	a6,16(sp)
ffffffffc02025da:	e43a                	sd	a4,8(sp)
ffffffffc02025dc:	f82a                	sd	a0,48(sp)
ffffffffc02025de:	b26fe0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02025e2:	00099797          	auipc	a5,0x99
ffffffffc02025e6:	1867b783          	ld	a5,390(a5) # ffffffffc029b768 <pmm_manager>
ffffffffc02025ea:	7542                	ld	a0,48(sp)
ffffffffc02025ec:	4585                	li	a1,1
ffffffffc02025ee:	739c                	ld	a5,32(a5)
ffffffffc02025f0:	9782                	jalr	a5
        intr_enable();
ffffffffc02025f2:	b0cfe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc02025f6:	6722                	ld	a4,8(sp)
ffffffffc02025f8:	6626                	ld	a2,72(sp)
ffffffffc02025fa:	6306                	ld	t1,64(sp)
ffffffffc02025fc:	78e2                	ld	a7,56(sp)
ffffffffc02025fe:	7f22                	ld	t5,40(sp)
ffffffffc0202600:	7e02                	ld	t3,32(sp)
ffffffffc0202602:	6ee2                	ld	t4,24(sp)
ffffffffc0202604:	6842                	ld	a6,16(sp)
ffffffffc0202606:	00099f97          	auipc	t6,0x99
ffffffffc020260a:	17af8f93          	addi	t6,t6,378 # ffffffffc029b780 <va_pa_offset>
ffffffffc020260e:	000803b7          	lui	t2,0x80
ffffffffc0202612:	fff802b7          	lui	t0,0xfff80
                        pd0[PDX0(d0start)] = 0;
ffffffffc0202616:	00073023          	sd	zero,0(a4)
ffffffffc020261a:	bd7d                	j	ffffffffc02024d8 <exit_range+0xd6>
        intr_disable();
ffffffffc020261c:	e832                	sd	a2,16(sp)
ffffffffc020261e:	e42a                	sd	a0,8(sp)
ffffffffc0202620:	ae4fe0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202624:	00099797          	auipc	a5,0x99
ffffffffc0202628:	1447b783          	ld	a5,324(a5) # ffffffffc029b768 <pmm_manager>
ffffffffc020262c:	6522                	ld	a0,8(sp)
ffffffffc020262e:	4585                	li	a1,1
ffffffffc0202630:	739c                	ld	a5,32(a5)
ffffffffc0202632:	9782                	jalr	a5
        intr_enable();
ffffffffc0202634:	acafe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202638:	6642                	ld	a2,16(sp)
                pgdir[PDX1(d1start)] = 0;
ffffffffc020263a:	00043023          	sd	zero,0(s0)
ffffffffc020263e:	b5cd                	j	ffffffffc0202520 <exit_range+0x11e>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0202640:	00004697          	auipc	a3,0x4
ffffffffc0202644:	1e868693          	addi	a3,a3,488 # ffffffffc0206828 <etext+0xeaa>
ffffffffc0202648:	00004617          	auipc	a2,0x4
ffffffffc020264c:	d3060613          	addi	a2,a2,-720 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0202650:	13500593          	li	a1,309
ffffffffc0202654:	00004517          	auipc	a0,0x4
ffffffffc0202658:	1c450513          	addi	a0,a0,452 # ffffffffc0206818 <etext+0xe9a>
ffffffffc020265c:	debfd0ef          	jal	ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc0202660:	00004617          	auipc	a2,0x4
ffffffffc0202664:	0c860613          	addi	a2,a2,200 # ffffffffc0206728 <etext+0xdaa>
ffffffffc0202668:	07100593          	li	a1,113
ffffffffc020266c:	00004517          	auipc	a0,0x4
ffffffffc0202670:	0e450513          	addi	a0,a0,228 # ffffffffc0206750 <etext+0xdd2>
ffffffffc0202674:	dd3fd0ef          	jal	ffffffffc0200446 <__panic>
ffffffffc0202678:	86f2                	mv	a3,t3
ffffffffc020267a:	00004617          	auipc	a2,0x4
ffffffffc020267e:	0ae60613          	addi	a2,a2,174 # ffffffffc0206728 <etext+0xdaa>
ffffffffc0202682:	07100593          	li	a1,113
ffffffffc0202686:	00004517          	auipc	a0,0x4
ffffffffc020268a:	0ca50513          	addi	a0,a0,202 # ffffffffc0206750 <etext+0xdd2>
ffffffffc020268e:	db9fd0ef          	jal	ffffffffc0200446 <__panic>
ffffffffc0202692:	8c7ff0ef          	jal	ffffffffc0201f58 <pa2page.part.0>
    assert(USER_ACCESS(start, end));
ffffffffc0202696:	00004697          	auipc	a3,0x4
ffffffffc020269a:	1c268693          	addi	a3,a3,450 # ffffffffc0206858 <etext+0xeda>
ffffffffc020269e:	00004617          	auipc	a2,0x4
ffffffffc02026a2:	cda60613          	addi	a2,a2,-806 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02026a6:	13600593          	li	a1,310
ffffffffc02026aa:	00004517          	auipc	a0,0x4
ffffffffc02026ae:	16e50513          	addi	a0,a0,366 # ffffffffc0206818 <etext+0xe9a>
ffffffffc02026b2:	d95fd0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02026b6 <page_remove>:
{
ffffffffc02026b6:	1101                	addi	sp,sp,-32
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02026b8:	4601                	li	a2,0
{
ffffffffc02026ba:	e822                	sd	s0,16(sp)
ffffffffc02026bc:	ec06                	sd	ra,24(sp)
ffffffffc02026be:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 0);
ffffffffc02026c0:	95dff0ef          	jal	ffffffffc020201c <get_pte>
    if (ptep != NULL)
ffffffffc02026c4:	c511                	beqz	a0,ffffffffc02026d0 <page_remove+0x1a>
    if (*ptep & PTE_V)
ffffffffc02026c6:	6118                	ld	a4,0(a0)
ffffffffc02026c8:	87aa                	mv	a5,a0
ffffffffc02026ca:	00177693          	andi	a3,a4,1
ffffffffc02026ce:	e689                	bnez	a3,ffffffffc02026d8 <page_remove+0x22>
}
ffffffffc02026d0:	60e2                	ld	ra,24(sp)
ffffffffc02026d2:	6442                	ld	s0,16(sp)
ffffffffc02026d4:	6105                	addi	sp,sp,32
ffffffffc02026d6:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc02026d8:	00099697          	auipc	a3,0x99
ffffffffc02026dc:	0b06b683          	ld	a3,176(a3) # ffffffffc029b788 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc02026e0:	070a                	slli	a4,a4,0x2
ffffffffc02026e2:	8331                	srli	a4,a4,0xc
    if (PPN(pa) >= npage)
ffffffffc02026e4:	06d77563          	bgeu	a4,a3,ffffffffc020274e <page_remove+0x98>
    return &pages[PPN(pa) - nbase];
ffffffffc02026e8:	00099517          	auipc	a0,0x99
ffffffffc02026ec:	0a853503          	ld	a0,168(a0) # ffffffffc029b790 <pages>
ffffffffc02026f0:	071a                	slli	a4,a4,0x6
ffffffffc02026f2:	fe0006b7          	lui	a3,0xfe000
ffffffffc02026f6:	9736                	add	a4,a4,a3
ffffffffc02026f8:	953a                	add	a0,a0,a4
    page->ref -= 1;
ffffffffc02026fa:	4118                	lw	a4,0(a0)
ffffffffc02026fc:	377d                	addiw	a4,a4,-1
ffffffffc02026fe:	c118                	sw	a4,0(a0)
        if (page_ref(page) == 0)
ffffffffc0202700:	cb09                	beqz	a4,ffffffffc0202712 <page_remove+0x5c>
        *ptep = 0;
ffffffffc0202702:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc0202706:	12040073          	sfence.vma	s0
}
ffffffffc020270a:	60e2                	ld	ra,24(sp)
ffffffffc020270c:	6442                	ld	s0,16(sp)
ffffffffc020270e:	6105                	addi	sp,sp,32
ffffffffc0202710:	8082                	ret
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202712:	10002773          	csrr	a4,sstatus
ffffffffc0202716:	8b09                	andi	a4,a4,2
ffffffffc0202718:	eb19                	bnez	a4,ffffffffc020272e <page_remove+0x78>
        pmm_manager->free_pages(base, n);
ffffffffc020271a:	00099717          	auipc	a4,0x99
ffffffffc020271e:	04e73703          	ld	a4,78(a4) # ffffffffc029b768 <pmm_manager>
ffffffffc0202722:	4585                	li	a1,1
ffffffffc0202724:	e03e                	sd	a5,0(sp)
ffffffffc0202726:	7318                	ld	a4,32(a4)
ffffffffc0202728:	9702                	jalr	a4
    if (flag)
ffffffffc020272a:	6782                	ld	a5,0(sp)
ffffffffc020272c:	bfd9                	j	ffffffffc0202702 <page_remove+0x4c>
        intr_disable();
ffffffffc020272e:	e43e                	sd	a5,8(sp)
ffffffffc0202730:	e02a                	sd	a0,0(sp)
ffffffffc0202732:	9d2fe0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc0202736:	00099717          	auipc	a4,0x99
ffffffffc020273a:	03273703          	ld	a4,50(a4) # ffffffffc029b768 <pmm_manager>
ffffffffc020273e:	6502                	ld	a0,0(sp)
ffffffffc0202740:	4585                	li	a1,1
ffffffffc0202742:	7318                	ld	a4,32(a4)
ffffffffc0202744:	9702                	jalr	a4
        intr_enable();
ffffffffc0202746:	9b8fe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc020274a:	67a2                	ld	a5,8(sp)
ffffffffc020274c:	bf5d                	j	ffffffffc0202702 <page_remove+0x4c>
ffffffffc020274e:	80bff0ef          	jal	ffffffffc0201f58 <pa2page.part.0>

ffffffffc0202752 <page_insert>:
{
ffffffffc0202752:	7139                	addi	sp,sp,-64
ffffffffc0202754:	f426                	sd	s1,40(sp)
ffffffffc0202756:	84b2                	mv	s1,a2
ffffffffc0202758:	f822                	sd	s0,48(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020275a:	4605                	li	a2,1
{
ffffffffc020275c:	842e                	mv	s0,a1
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc020275e:	85a6                	mv	a1,s1
{
ffffffffc0202760:	fc06                	sd	ra,56(sp)
ffffffffc0202762:	e436                	sd	a3,8(sp)
    pte_t *ptep = get_pte(pgdir, la, 1);
ffffffffc0202764:	8b9ff0ef          	jal	ffffffffc020201c <get_pte>
    if (ptep == NULL)
ffffffffc0202768:	cd61                	beqz	a0,ffffffffc0202840 <page_insert+0xee>
    page->ref += 1;
ffffffffc020276a:	400c                	lw	a1,0(s0)
    if (*ptep & PTE_V)
ffffffffc020276c:	611c                	ld	a5,0(a0)
ffffffffc020276e:	66a2                	ld	a3,8(sp)
ffffffffc0202770:	0015861b          	addiw	a2,a1,1 # 1001 <_binary_obj___user_softint_out_size-0x7bcf>
ffffffffc0202774:	c010                	sw	a2,0(s0)
ffffffffc0202776:	0017f613          	andi	a2,a5,1
ffffffffc020277a:	872a                	mv	a4,a0
ffffffffc020277c:	e61d                	bnez	a2,ffffffffc02027aa <page_insert+0x58>
    return &pages[PPN(pa) - nbase];
ffffffffc020277e:	00099617          	auipc	a2,0x99
ffffffffc0202782:	01263603          	ld	a2,18(a2) # ffffffffc029b790 <pages>
    return page - pages + nbase;
ffffffffc0202786:	8c11                	sub	s0,s0,a2
ffffffffc0202788:	8419                	srai	s0,s0,0x6
    return (ppn << PTE_PPN_SHIFT) | PTE_V | type;
ffffffffc020278a:	200007b7          	lui	a5,0x20000
ffffffffc020278e:	042a                	slli	s0,s0,0xa
ffffffffc0202790:	943e                	add	s0,s0,a5
ffffffffc0202792:	8ec1                	or	a3,a3,s0
ffffffffc0202794:	0016e693          	ori	a3,a3,1
    *ptep = pte_create(page2ppn(page), PTE_V | perm);
ffffffffc0202798:	e314                	sd	a3,0(a4)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020279a:	12048073          	sfence.vma	s1
    return 0;
ffffffffc020279e:	4501                	li	a0,0
}
ffffffffc02027a0:	70e2                	ld	ra,56(sp)
ffffffffc02027a2:	7442                	ld	s0,48(sp)
ffffffffc02027a4:	74a2                	ld	s1,40(sp)
ffffffffc02027a6:	6121                	addi	sp,sp,64
ffffffffc02027a8:	8082                	ret
    if (PPN(pa) >= npage)
ffffffffc02027aa:	00099617          	auipc	a2,0x99
ffffffffc02027ae:	fde63603          	ld	a2,-34(a2) # ffffffffc029b788 <npage>
    return pa2page(PTE_ADDR(pte));
ffffffffc02027b2:	078a                	slli	a5,a5,0x2
ffffffffc02027b4:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc02027b6:	08c7f763          	bgeu	a5,a2,ffffffffc0202844 <page_insert+0xf2>
    return &pages[PPN(pa) - nbase];
ffffffffc02027ba:	00099617          	auipc	a2,0x99
ffffffffc02027be:	fd663603          	ld	a2,-42(a2) # ffffffffc029b790 <pages>
ffffffffc02027c2:	fe000537          	lui	a0,0xfe000
ffffffffc02027c6:	079a                	slli	a5,a5,0x6
ffffffffc02027c8:	97aa                	add	a5,a5,a0
ffffffffc02027ca:	00f60533          	add	a0,a2,a5
        if (p == page)
ffffffffc02027ce:	00a40963          	beq	s0,a0,ffffffffc02027e0 <page_insert+0x8e>
    page->ref -= 1;
ffffffffc02027d2:	411c                	lw	a5,0(a0)
ffffffffc02027d4:	37fd                	addiw	a5,a5,-1 # 1fffffff <_binary_obj___user_exit_out_size+0x1fff5e3f>
ffffffffc02027d6:	c11c                	sw	a5,0(a0)
        if (page_ref(page) == 0)
ffffffffc02027d8:	c791                	beqz	a5,ffffffffc02027e4 <page_insert+0x92>
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc02027da:	12048073          	sfence.vma	s1
}
ffffffffc02027de:	b765                	j	ffffffffc0202786 <page_insert+0x34>
ffffffffc02027e0:	c00c                	sw	a1,0(s0)
    return page->ref;
ffffffffc02027e2:	b755                	j	ffffffffc0202786 <page_insert+0x34>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02027e4:	100027f3          	csrr	a5,sstatus
ffffffffc02027e8:	8b89                	andi	a5,a5,2
ffffffffc02027ea:	e39d                	bnez	a5,ffffffffc0202810 <page_insert+0xbe>
        pmm_manager->free_pages(base, n);
ffffffffc02027ec:	00099797          	auipc	a5,0x99
ffffffffc02027f0:	f7c7b783          	ld	a5,-132(a5) # ffffffffc029b768 <pmm_manager>
ffffffffc02027f4:	4585                	li	a1,1
ffffffffc02027f6:	e83a                	sd	a4,16(sp)
ffffffffc02027f8:	739c                	ld	a5,32(a5)
ffffffffc02027fa:	e436                	sd	a3,8(sp)
ffffffffc02027fc:	9782                	jalr	a5
    return page - pages + nbase;
ffffffffc02027fe:	00099617          	auipc	a2,0x99
ffffffffc0202802:	f9263603          	ld	a2,-110(a2) # ffffffffc029b790 <pages>
ffffffffc0202806:	66a2                	ld	a3,8(sp)
ffffffffc0202808:	6742                	ld	a4,16(sp)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020280a:	12048073          	sfence.vma	s1
ffffffffc020280e:	bfa5                	j	ffffffffc0202786 <page_insert+0x34>
        intr_disable();
ffffffffc0202810:	ec3a                	sd	a4,24(sp)
ffffffffc0202812:	e836                	sd	a3,16(sp)
ffffffffc0202814:	e42a                	sd	a0,8(sp)
ffffffffc0202816:	8eefe0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc020281a:	00099797          	auipc	a5,0x99
ffffffffc020281e:	f4e7b783          	ld	a5,-178(a5) # ffffffffc029b768 <pmm_manager>
ffffffffc0202822:	6522                	ld	a0,8(sp)
ffffffffc0202824:	4585                	li	a1,1
ffffffffc0202826:	739c                	ld	a5,32(a5)
ffffffffc0202828:	9782                	jalr	a5
        intr_enable();
ffffffffc020282a:	8d4fe0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc020282e:	00099617          	auipc	a2,0x99
ffffffffc0202832:	f6263603          	ld	a2,-158(a2) # ffffffffc029b790 <pages>
ffffffffc0202836:	6762                	ld	a4,24(sp)
ffffffffc0202838:	66c2                	ld	a3,16(sp)
    asm volatile("sfence.vma %0" : : "r"(la));
ffffffffc020283a:	12048073          	sfence.vma	s1
ffffffffc020283e:	b7a1                	j	ffffffffc0202786 <page_insert+0x34>
        return -E_NO_MEM;
ffffffffc0202840:	5571                	li	a0,-4
ffffffffc0202842:	bfb9                	j	ffffffffc02027a0 <page_insert+0x4e>
ffffffffc0202844:	f14ff0ef          	jal	ffffffffc0201f58 <pa2page.part.0>

ffffffffc0202848 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0202848:	00005797          	auipc	a5,0x5
ffffffffc020284c:	fb878793          	addi	a5,a5,-72 # ffffffffc0207800 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202850:	638c                	ld	a1,0(a5)
{
ffffffffc0202852:	7159                	addi	sp,sp,-112
ffffffffc0202854:	f486                	sd	ra,104(sp)
ffffffffc0202856:	e8ca                	sd	s2,80(sp)
ffffffffc0202858:	e4ce                	sd	s3,72(sp)
ffffffffc020285a:	f85a                	sd	s6,48(sp)
ffffffffc020285c:	f0a2                	sd	s0,96(sp)
ffffffffc020285e:	eca6                	sd	s1,88(sp)
ffffffffc0202860:	e0d2                	sd	s4,64(sp)
ffffffffc0202862:	fc56                	sd	s5,56(sp)
ffffffffc0202864:	f45e                	sd	s7,40(sp)
ffffffffc0202866:	f062                	sd	s8,32(sp)
ffffffffc0202868:	ec66                	sd	s9,24(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc020286a:	00099b17          	auipc	s6,0x99
ffffffffc020286e:	efeb0b13          	addi	s6,s6,-258 # ffffffffc029b768 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0202872:	00004517          	auipc	a0,0x4
ffffffffc0202876:	ffe50513          	addi	a0,a0,-2 # ffffffffc0206870 <etext+0xef2>
    pmm_manager = &default_pmm_manager;
ffffffffc020287a:	00fb3023          	sd	a5,0(s6)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020287e:	917fd0ef          	jal	ffffffffc0200194 <cprintf>
    pmm_manager->init();
ffffffffc0202882:	000b3783          	ld	a5,0(s6)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0202886:	00099997          	auipc	s3,0x99
ffffffffc020288a:	efa98993          	addi	s3,s3,-262 # ffffffffc029b780 <va_pa_offset>
    pmm_manager->init();
ffffffffc020288e:	679c                	ld	a5,8(a5)
ffffffffc0202890:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc0202892:	57f5                	li	a5,-3
ffffffffc0202894:	07fa                	slli	a5,a5,0x1e
ffffffffc0202896:	00f9b023          	sd	a5,0(s3)
    uint64_t mem_begin = get_memory_base();
ffffffffc020289a:	850fe0ef          	jal	ffffffffc02008ea <get_memory_base>
ffffffffc020289e:	892a                	mv	s2,a0
    uint64_t mem_size = get_memory_size();
ffffffffc02028a0:	854fe0ef          	jal	ffffffffc02008f4 <get_memory_size>
    if (mem_size == 0)
ffffffffc02028a4:	70050e63          	beqz	a0,ffffffffc0202fc0 <pmm_init+0x778>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc02028a8:	84aa                	mv	s1,a0
    cprintf("physcial memory map:\n");
ffffffffc02028aa:	00004517          	auipc	a0,0x4
ffffffffc02028ae:	ffe50513          	addi	a0,a0,-2 # ffffffffc02068a8 <etext+0xf2a>
ffffffffc02028b2:	8e3fd0ef          	jal	ffffffffc0200194 <cprintf>
    uint64_t mem_end = mem_begin + mem_size;
ffffffffc02028b6:	00990433          	add	s0,s2,s1
    cprintf("  memory: 0x%08lx, [0x%08lx, 0x%08lx].\n", mem_size, mem_begin,
ffffffffc02028ba:	864a                	mv	a2,s2
ffffffffc02028bc:	85a6                	mv	a1,s1
ffffffffc02028be:	fff40693          	addi	a3,s0,-1
ffffffffc02028c2:	00004517          	auipc	a0,0x4
ffffffffc02028c6:	ffe50513          	addi	a0,a0,-2 # ffffffffc02068c0 <etext+0xf42>
ffffffffc02028ca:	8cbfd0ef          	jal	ffffffffc0200194 <cprintf>
    if (maxpa > KERNTOP)
ffffffffc02028ce:	c80007b7          	lui	a5,0xc8000
ffffffffc02028d2:	8522                	mv	a0,s0
ffffffffc02028d4:	5287ed63          	bltu	a5,s0,ffffffffc0202e0e <pmm_init+0x5c6>
ffffffffc02028d8:	77fd                	lui	a5,0xfffff
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02028da:	0009a617          	auipc	a2,0x9a
ffffffffc02028de:	edd60613          	addi	a2,a2,-291 # ffffffffc029c7b7 <end+0xfff>
ffffffffc02028e2:	8e7d                	and	a2,a2,a5
    npage = maxpa / PGSIZE;
ffffffffc02028e4:	8131                	srli	a0,a0,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02028e6:	00099b97          	auipc	s7,0x99
ffffffffc02028ea:	eaab8b93          	addi	s7,s7,-342 # ffffffffc029b790 <pages>
    npage = maxpa / PGSIZE;
ffffffffc02028ee:	00099497          	auipc	s1,0x99
ffffffffc02028f2:	e9a48493          	addi	s1,s1,-358 # ffffffffc029b788 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02028f6:	00cbb023          	sd	a2,0(s7)
    npage = maxpa / PGSIZE;
ffffffffc02028fa:	e088                	sd	a0,0(s1)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc02028fc:	000807b7          	lui	a5,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0202900:	86b2                	mv	a3,a2
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202902:	02f50763          	beq	a0,a5,ffffffffc0202930 <pmm_init+0xe8>
ffffffffc0202906:	4701                	li	a4,0
ffffffffc0202908:	4585                	li	a1,1
ffffffffc020290a:	fff806b7          	lui	a3,0xfff80
        SetPageReserved(pages + i);
ffffffffc020290e:	00671793          	slli	a5,a4,0x6
ffffffffc0202912:	97b2                	add	a5,a5,a2
ffffffffc0202914:	07a1                	addi	a5,a5,8 # 80008 <_binary_obj___user_exit_out_size+0x75e48>
ffffffffc0202916:	40b7b02f          	amoor.d	zero,a1,(a5)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc020291a:	6088                	ld	a0,0(s1)
ffffffffc020291c:	0705                	addi	a4,a4,1
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020291e:	000bb603          	ld	a2,0(s7)
    for (size_t i = 0; i < npage - nbase; i++)
ffffffffc0202922:	00d507b3          	add	a5,a0,a3
ffffffffc0202926:	fef764e3          	bltu	a4,a5,ffffffffc020290e <pmm_init+0xc6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020292a:	079a                	slli	a5,a5,0x6
ffffffffc020292c:	00f606b3          	add	a3,a2,a5
ffffffffc0202930:	c02007b7          	lui	a5,0xc0200
ffffffffc0202934:	16f6eee3          	bltu	a3,a5,ffffffffc02032b0 <pmm_init+0xa68>
ffffffffc0202938:	0009b583          	ld	a1,0(s3)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc020293c:	77fd                	lui	a5,0xfffff
ffffffffc020293e:	8c7d                	and	s0,s0,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0202940:	8e8d                	sub	a3,a3,a1
    if (freemem < mem_end)
ffffffffc0202942:	4e86ed63          	bltu	a3,s0,ffffffffc0202e3c <pmm_init+0x5f4>
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202946:	00004517          	auipc	a0,0x4
ffffffffc020294a:	fa250513          	addi	a0,a0,-94 # ffffffffc02068e8 <etext+0xf6a>
ffffffffc020294e:	847fd0ef          	jal	ffffffffc0200194 <cprintf>
    return page;
}

static void check_alloc_page(void)
{
    pmm_manager->check();
ffffffffc0202952:	000b3783          	ld	a5,0(s6)
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc0202956:	00099917          	auipc	s2,0x99
ffffffffc020295a:	e2290913          	addi	s2,s2,-478 # ffffffffc029b778 <boot_pgdir_va>
    pmm_manager->check();
ffffffffc020295e:	7b9c                	ld	a5,48(a5)
ffffffffc0202960:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0202962:	00004517          	auipc	a0,0x4
ffffffffc0202966:	f9e50513          	addi	a0,a0,-98 # ffffffffc0206900 <etext+0xf82>
ffffffffc020296a:	82bfd0ef          	jal	ffffffffc0200194 <cprintf>
    boot_pgdir_va = (pte_t *)boot_page_table_sv39;
ffffffffc020296e:	00007697          	auipc	a3,0x7
ffffffffc0202972:	69268693          	addi	a3,a3,1682 # ffffffffc020a000 <boot_page_table_sv39>
ffffffffc0202976:	00d93023          	sd	a3,0(s2)
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc020297a:	c02007b7          	lui	a5,0xc0200
ffffffffc020297e:	2af6eee3          	bltu	a3,a5,ffffffffc020343a <pmm_init+0xbf2>
ffffffffc0202982:	0009b783          	ld	a5,0(s3)
ffffffffc0202986:	8e9d                	sub	a3,a3,a5
ffffffffc0202988:	00099797          	auipc	a5,0x99
ffffffffc020298c:	ded7b423          	sd	a3,-536(a5) # ffffffffc029b770 <boot_pgdir_pa>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0202990:	100027f3          	csrr	a5,sstatus
ffffffffc0202994:	8b89                	andi	a5,a5,2
ffffffffc0202996:	48079963          	bnez	a5,ffffffffc0202e28 <pmm_init+0x5e0>
        ret = pmm_manager->nr_free_pages();
ffffffffc020299a:	000b3783          	ld	a5,0(s6)
ffffffffc020299e:	779c                	ld	a5,40(a5)
ffffffffc02029a0:	9782                	jalr	a5
ffffffffc02029a2:	842a                	mv	s0,a0
    // so npage is always larger than KMEMSIZE / PGSIZE
    size_t nr_free_store;

    nr_free_store = nr_free_pages();

    assert(npage <= KERNTOP / PGSIZE);
ffffffffc02029a4:	6098                	ld	a4,0(s1)
ffffffffc02029a6:	c80007b7          	lui	a5,0xc8000
ffffffffc02029aa:	83b1                	srli	a5,a5,0xc
ffffffffc02029ac:	66e7e663          	bltu	a5,a4,ffffffffc0203018 <pmm_init+0x7d0>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc02029b0:	00093503          	ld	a0,0(s2)
ffffffffc02029b4:	64050263          	beqz	a0,ffffffffc0202ff8 <pmm_init+0x7b0>
ffffffffc02029b8:	03451793          	slli	a5,a0,0x34
ffffffffc02029bc:	62079e63          	bnez	a5,ffffffffc0202ff8 <pmm_init+0x7b0>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc02029c0:	4601                	li	a2,0
ffffffffc02029c2:	4581                	li	a1,0
ffffffffc02029c4:	8b7ff0ef          	jal	ffffffffc020227a <get_page>
ffffffffc02029c8:	240519e3          	bnez	a0,ffffffffc020341a <pmm_init+0xbd2>
ffffffffc02029cc:	100027f3          	csrr	a5,sstatus
ffffffffc02029d0:	8b89                	andi	a5,a5,2
ffffffffc02029d2:	44079063          	bnez	a5,ffffffffc0202e12 <pmm_init+0x5ca>
        page = pmm_manager->alloc_pages(n);
ffffffffc02029d6:	000b3783          	ld	a5,0(s6)
ffffffffc02029da:	4505                	li	a0,1
ffffffffc02029dc:	6f9c                	ld	a5,24(a5)
ffffffffc02029de:	9782                	jalr	a5
ffffffffc02029e0:	8a2a                	mv	s4,a0

    struct Page *p1, *p2;
    p1 = alloc_page();
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc02029e2:	00093503          	ld	a0,0(s2)
ffffffffc02029e6:	4681                	li	a3,0
ffffffffc02029e8:	4601                	li	a2,0
ffffffffc02029ea:	85d2                	mv	a1,s4
ffffffffc02029ec:	d67ff0ef          	jal	ffffffffc0202752 <page_insert>
ffffffffc02029f0:	280511e3          	bnez	a0,ffffffffc0203472 <pmm_init+0xc2a>

    pte_t *ptep;
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc02029f4:	00093503          	ld	a0,0(s2)
ffffffffc02029f8:	4601                	li	a2,0
ffffffffc02029fa:	4581                	li	a1,0
ffffffffc02029fc:	e20ff0ef          	jal	ffffffffc020201c <get_pte>
ffffffffc0202a00:	240509e3          	beqz	a0,ffffffffc0203452 <pmm_init+0xc0a>
    assert(pte2page(*ptep) == p1);
ffffffffc0202a04:	611c                	ld	a5,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202a06:	0017f713          	andi	a4,a5,1
ffffffffc0202a0a:	58070f63          	beqz	a4,ffffffffc0202fa8 <pmm_init+0x760>
    if (PPN(pa) >= npage)
ffffffffc0202a0e:	6098                	ld	a4,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202a10:	078a                	slli	a5,a5,0x2
ffffffffc0202a12:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202a14:	58e7f863          	bgeu	a5,a4,ffffffffc0202fa4 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202a18:	000bb683          	ld	a3,0(s7)
ffffffffc0202a1c:	079a                	slli	a5,a5,0x6
ffffffffc0202a1e:	fe000637          	lui	a2,0xfe000
ffffffffc0202a22:	97b2                	add	a5,a5,a2
ffffffffc0202a24:	97b6                	add	a5,a5,a3
ffffffffc0202a26:	14fa1ae3          	bne	s4,a5,ffffffffc020337a <pmm_init+0xb32>
    assert(page_ref(p1) == 1);
ffffffffc0202a2a:	000a2683          	lw	a3,0(s4) # 200000 <_binary_obj___user_exit_out_size+0x1f5e40>
ffffffffc0202a2e:	4785                	li	a5,1
ffffffffc0202a30:	12f695e3          	bne	a3,a5,ffffffffc020335a <pmm_init+0xb12>

    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0202a34:	00093503          	ld	a0,0(s2)
ffffffffc0202a38:	77fd                	lui	a5,0xfffff
ffffffffc0202a3a:	6114                	ld	a3,0(a0)
ffffffffc0202a3c:	068a                	slli	a3,a3,0x2
ffffffffc0202a3e:	8efd                	and	a3,a3,a5
ffffffffc0202a40:	00c6d613          	srli	a2,a3,0xc
ffffffffc0202a44:	0ee67fe3          	bgeu	a2,a4,ffffffffc0203342 <pmm_init+0xafa>
ffffffffc0202a48:	0009bc03          	ld	s8,0(s3)
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202a4c:	96e2                	add	a3,a3,s8
ffffffffc0202a4e:	0006ba83          	ld	s5,0(a3)
ffffffffc0202a52:	0a8a                	slli	s5,s5,0x2
ffffffffc0202a54:	00fafab3          	and	s5,s5,a5
ffffffffc0202a58:	00cad793          	srli	a5,s5,0xc
ffffffffc0202a5c:	0ce7f6e3          	bgeu	a5,a4,ffffffffc0203328 <pmm_init+0xae0>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202a60:	4601                	li	a2,0
ffffffffc0202a62:	6585                	lui	a1,0x1
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202a64:	9c56                	add	s8,s8,s5
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202a66:	db6ff0ef          	jal	ffffffffc020201c <get_pte>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0202a6a:	0c21                	addi	s8,s8,8
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc0202a6c:	05851ee3          	bne	a0,s8,ffffffffc02032c8 <pmm_init+0xa80>
ffffffffc0202a70:	100027f3          	csrr	a5,sstatus
ffffffffc0202a74:	8b89                	andi	a5,a5,2
ffffffffc0202a76:	3e079b63          	bnez	a5,ffffffffc0202e6c <pmm_init+0x624>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202a7a:	000b3783          	ld	a5,0(s6)
ffffffffc0202a7e:	4505                	li	a0,1
ffffffffc0202a80:	6f9c                	ld	a5,24(a5)
ffffffffc0202a82:	9782                	jalr	a5
ffffffffc0202a84:	8c2a                	mv	s8,a0

    p2 = alloc_page();
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0202a86:	00093503          	ld	a0,0(s2)
ffffffffc0202a8a:	46d1                	li	a3,20
ffffffffc0202a8c:	6605                	lui	a2,0x1
ffffffffc0202a8e:	85e2                	mv	a1,s8
ffffffffc0202a90:	cc3ff0ef          	jal	ffffffffc0202752 <page_insert>
ffffffffc0202a94:	06051ae3          	bnez	a0,ffffffffc0203308 <pmm_init+0xac0>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202a98:	00093503          	ld	a0,0(s2)
ffffffffc0202a9c:	4601                	li	a2,0
ffffffffc0202a9e:	6585                	lui	a1,0x1
ffffffffc0202aa0:	d7cff0ef          	jal	ffffffffc020201c <get_pte>
ffffffffc0202aa4:	040502e3          	beqz	a0,ffffffffc02032e8 <pmm_init+0xaa0>
    assert(*ptep & PTE_U);
ffffffffc0202aa8:	611c                	ld	a5,0(a0)
ffffffffc0202aaa:	0107f713          	andi	a4,a5,16
ffffffffc0202aae:	7e070163          	beqz	a4,ffffffffc0203290 <pmm_init+0xa48>
    assert(*ptep & PTE_W);
ffffffffc0202ab2:	8b91                	andi	a5,a5,4
ffffffffc0202ab4:	7a078e63          	beqz	a5,ffffffffc0203270 <pmm_init+0xa28>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0202ab8:	00093503          	ld	a0,0(s2)
ffffffffc0202abc:	611c                	ld	a5,0(a0)
ffffffffc0202abe:	8bc1                	andi	a5,a5,16
ffffffffc0202ac0:	78078863          	beqz	a5,ffffffffc0203250 <pmm_init+0xa08>
    assert(page_ref(p2) == 1);
ffffffffc0202ac4:	000c2703          	lw	a4,0(s8)
ffffffffc0202ac8:	4785                	li	a5,1
ffffffffc0202aca:	76f71363          	bne	a4,a5,ffffffffc0203230 <pmm_init+0x9e8>

    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0202ace:	4681                	li	a3,0
ffffffffc0202ad0:	6605                	lui	a2,0x1
ffffffffc0202ad2:	85d2                	mv	a1,s4
ffffffffc0202ad4:	c7fff0ef          	jal	ffffffffc0202752 <page_insert>
ffffffffc0202ad8:	72051c63          	bnez	a0,ffffffffc0203210 <pmm_init+0x9c8>
    assert(page_ref(p1) == 2);
ffffffffc0202adc:	000a2703          	lw	a4,0(s4)
ffffffffc0202ae0:	4789                	li	a5,2
ffffffffc0202ae2:	70f71763          	bne	a4,a5,ffffffffc02031f0 <pmm_init+0x9a8>
    assert(page_ref(p2) == 0);
ffffffffc0202ae6:	000c2783          	lw	a5,0(s8)
ffffffffc0202aea:	6e079363          	bnez	a5,ffffffffc02031d0 <pmm_init+0x988>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc0202aee:	00093503          	ld	a0,0(s2)
ffffffffc0202af2:	4601                	li	a2,0
ffffffffc0202af4:	6585                	lui	a1,0x1
ffffffffc0202af6:	d26ff0ef          	jal	ffffffffc020201c <get_pte>
ffffffffc0202afa:	6a050b63          	beqz	a0,ffffffffc02031b0 <pmm_init+0x968>
    assert(pte2page(*ptep) == p1);
ffffffffc0202afe:	6118                	ld	a4,0(a0)
    if (!(pte & PTE_V))
ffffffffc0202b00:	00177793          	andi	a5,a4,1
ffffffffc0202b04:	4a078263          	beqz	a5,ffffffffc0202fa8 <pmm_init+0x760>
    if (PPN(pa) >= npage)
ffffffffc0202b08:	6094                	ld	a3,0(s1)
    return pa2page(PTE_ADDR(pte));
ffffffffc0202b0a:	00271793          	slli	a5,a4,0x2
ffffffffc0202b0e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b10:	48d7fa63          	bgeu	a5,a3,ffffffffc0202fa4 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b14:	000bb683          	ld	a3,0(s7)
ffffffffc0202b18:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202b1c:	97d6                	add	a5,a5,s5
ffffffffc0202b1e:	079a                	slli	a5,a5,0x6
ffffffffc0202b20:	97b6                	add	a5,a5,a3
ffffffffc0202b22:	66fa1763          	bne	s4,a5,ffffffffc0203190 <pmm_init+0x948>
    assert((*ptep & PTE_U) == 0);
ffffffffc0202b26:	8b41                	andi	a4,a4,16
ffffffffc0202b28:	64071463          	bnez	a4,ffffffffc0203170 <pmm_init+0x928>

    page_remove(boot_pgdir_va, 0x0);
ffffffffc0202b2c:	00093503          	ld	a0,0(s2)
ffffffffc0202b30:	4581                	li	a1,0
ffffffffc0202b32:	b85ff0ef          	jal	ffffffffc02026b6 <page_remove>
    assert(page_ref(p1) == 1);
ffffffffc0202b36:	000a2c83          	lw	s9,0(s4)
ffffffffc0202b3a:	4785                	li	a5,1
ffffffffc0202b3c:	60fc9a63          	bne	s9,a5,ffffffffc0203150 <pmm_init+0x908>
    assert(page_ref(p2) == 0);
ffffffffc0202b40:	000c2783          	lw	a5,0(s8)
ffffffffc0202b44:	5e079663          	bnez	a5,ffffffffc0203130 <pmm_init+0x8e8>

    page_remove(boot_pgdir_va, PGSIZE);
ffffffffc0202b48:	00093503          	ld	a0,0(s2)
ffffffffc0202b4c:	6585                	lui	a1,0x1
ffffffffc0202b4e:	b69ff0ef          	jal	ffffffffc02026b6 <page_remove>
    assert(page_ref(p1) == 0);
ffffffffc0202b52:	000a2783          	lw	a5,0(s4)
ffffffffc0202b56:	52079d63          	bnez	a5,ffffffffc0203090 <pmm_init+0x848>
    assert(page_ref(p2) == 0);
ffffffffc0202b5a:	000c2783          	lw	a5,0(s8)
ffffffffc0202b5e:	50079963          	bnez	a5,ffffffffc0203070 <pmm_init+0x828>

    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0202b62:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202b66:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b68:	000a3783          	ld	a5,0(s4)
ffffffffc0202b6c:	078a                	slli	a5,a5,0x2
ffffffffc0202b6e:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202b70:	42e7fa63          	bgeu	a5,a4,ffffffffc0202fa4 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202b74:	000bb503          	ld	a0,0(s7)
ffffffffc0202b78:	97d6                	add	a5,a5,s5
ffffffffc0202b7a:	079a                	slli	a5,a5,0x6
    return page->ref;
ffffffffc0202b7c:	00f506b3          	add	a3,a0,a5
ffffffffc0202b80:	4294                	lw	a3,0(a3)
ffffffffc0202b82:	4d969763          	bne	a3,s9,ffffffffc0203050 <pmm_init+0x808>
    return page - pages + nbase;
ffffffffc0202b86:	8799                	srai	a5,a5,0x6
ffffffffc0202b88:	00080637          	lui	a2,0x80
ffffffffc0202b8c:	97b2                	add	a5,a5,a2
    return page2ppn(page) << PGSHIFT;
ffffffffc0202b8e:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202b92:	4ae7f363          	bgeu	a5,a4,ffffffffc0203038 <pmm_init+0x7f0>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
    free_page(pde2page(pd0[0]));
ffffffffc0202b96:	0009b783          	ld	a5,0(s3)
ffffffffc0202b9a:	97b6                	add	a5,a5,a3
    return pa2page(PDE_ADDR(pde));
ffffffffc0202b9c:	639c                	ld	a5,0(a5)
ffffffffc0202b9e:	078a                	slli	a5,a5,0x2
ffffffffc0202ba0:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202ba2:	40e7f163          	bgeu	a5,a4,ffffffffc0202fa4 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202ba6:	8f91                	sub	a5,a5,a2
ffffffffc0202ba8:	079a                	slli	a5,a5,0x6
ffffffffc0202baa:	953e                	add	a0,a0,a5
ffffffffc0202bac:	100027f3          	csrr	a5,sstatus
ffffffffc0202bb0:	8b89                	andi	a5,a5,2
ffffffffc0202bb2:	30079863          	bnez	a5,ffffffffc0202ec2 <pmm_init+0x67a>
        pmm_manager->free_pages(base, n);
ffffffffc0202bb6:	000b3783          	ld	a5,0(s6)
ffffffffc0202bba:	4585                	li	a1,1
ffffffffc0202bbc:	739c                	ld	a5,32(a5)
ffffffffc0202bbe:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202bc0:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202bc4:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202bc6:	078a                	slli	a5,a5,0x2
ffffffffc0202bc8:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202bca:	3ce7fd63          	bgeu	a5,a4,ffffffffc0202fa4 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202bce:	000bb503          	ld	a0,0(s7)
ffffffffc0202bd2:	fe000737          	lui	a4,0xfe000
ffffffffc0202bd6:	079a                	slli	a5,a5,0x6
ffffffffc0202bd8:	97ba                	add	a5,a5,a4
ffffffffc0202bda:	953e                	add	a0,a0,a5
ffffffffc0202bdc:	100027f3          	csrr	a5,sstatus
ffffffffc0202be0:	8b89                	andi	a5,a5,2
ffffffffc0202be2:	2c079463          	bnez	a5,ffffffffc0202eaa <pmm_init+0x662>
ffffffffc0202be6:	000b3783          	ld	a5,0(s6)
ffffffffc0202bea:	4585                	li	a1,1
ffffffffc0202bec:	739c                	ld	a5,32(a5)
ffffffffc0202bee:	9782                	jalr	a5
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202bf0:	00093783          	ld	a5,0(s2)
ffffffffc0202bf4:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd63848>
    asm volatile("sfence.vma");
ffffffffc0202bf8:	12000073          	sfence.vma
ffffffffc0202bfc:	100027f3          	csrr	a5,sstatus
ffffffffc0202c00:	8b89                	andi	a5,a5,2
ffffffffc0202c02:	28079a63          	bnez	a5,ffffffffc0202e96 <pmm_init+0x64e>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202c06:	000b3783          	ld	a5,0(s6)
ffffffffc0202c0a:	779c                	ld	a5,40(a5)
ffffffffc0202c0c:	9782                	jalr	a5
ffffffffc0202c0e:	8a2a                	mv	s4,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202c10:	4d441063          	bne	s0,s4,ffffffffc02030d0 <pmm_init+0x888>

    cprintf("check_pgdir() succeeded!\n");
ffffffffc0202c14:	00004517          	auipc	a0,0x4
ffffffffc0202c18:	03c50513          	addi	a0,a0,60 # ffffffffc0206c50 <etext+0x12d2>
ffffffffc0202c1c:	d78fd0ef          	jal	ffffffffc0200194 <cprintf>
ffffffffc0202c20:	100027f3          	csrr	a5,sstatus
ffffffffc0202c24:	8b89                	andi	a5,a5,2
ffffffffc0202c26:	24079e63          	bnez	a5,ffffffffc0202e82 <pmm_init+0x63a>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202c2a:	000b3783          	ld	a5,0(s6)
ffffffffc0202c2e:	779c                	ld	a5,40(a5)
ffffffffc0202c30:	9782                	jalr	a5
ffffffffc0202c32:	8c2a                	mv	s8,a0
    pte_t *ptep;
    int i;

    nr_free_store = nr_free_pages();

    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202c34:	609c                	ld	a5,0(s1)
ffffffffc0202c36:	c0200437          	lui	s0,0xc0200
    {
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202c3a:	7a7d                	lui	s4,0xfffff
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202c3c:	00c79713          	slli	a4,a5,0xc
ffffffffc0202c40:	6a85                	lui	s5,0x1
ffffffffc0202c42:	02e47c63          	bgeu	s0,a4,ffffffffc0202c7a <pmm_init+0x432>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202c46:	00c45713          	srli	a4,s0,0xc
ffffffffc0202c4a:	30f77063          	bgeu	a4,a5,ffffffffc0202f4a <pmm_init+0x702>
ffffffffc0202c4e:	0009b583          	ld	a1,0(s3)
ffffffffc0202c52:	00093503          	ld	a0,0(s2)
ffffffffc0202c56:	4601                	li	a2,0
ffffffffc0202c58:	95a2                	add	a1,a1,s0
ffffffffc0202c5a:	bc2ff0ef          	jal	ffffffffc020201c <get_pte>
ffffffffc0202c5e:	32050363          	beqz	a0,ffffffffc0202f84 <pmm_init+0x73c>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202c62:	611c                	ld	a5,0(a0)
ffffffffc0202c64:	078a                	slli	a5,a5,0x2
ffffffffc0202c66:	0147f7b3          	and	a5,a5,s4
ffffffffc0202c6a:	2e879d63          	bne	a5,s0,ffffffffc0202f64 <pmm_init+0x71c>
    for (i = ROUNDDOWN(KERNBASE, PGSIZE); i < npage * PGSIZE; i += PGSIZE)
ffffffffc0202c6e:	609c                	ld	a5,0(s1)
ffffffffc0202c70:	9456                	add	s0,s0,s5
ffffffffc0202c72:	00c79713          	slli	a4,a5,0xc
ffffffffc0202c76:	fce468e3          	bltu	s0,a4,ffffffffc0202c46 <pmm_init+0x3fe>
    }

    assert(boot_pgdir_va[0] == 0);
ffffffffc0202c7a:	00093783          	ld	a5,0(s2)
ffffffffc0202c7e:	639c                	ld	a5,0(a5)
ffffffffc0202c80:	42079863          	bnez	a5,ffffffffc02030b0 <pmm_init+0x868>
ffffffffc0202c84:	100027f3          	csrr	a5,sstatus
ffffffffc0202c88:	8b89                	andi	a5,a5,2
ffffffffc0202c8a:	24079863          	bnez	a5,ffffffffc0202eda <pmm_init+0x692>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202c8e:	000b3783          	ld	a5,0(s6)
ffffffffc0202c92:	4505                	li	a0,1
ffffffffc0202c94:	6f9c                	ld	a5,24(a5)
ffffffffc0202c96:	9782                	jalr	a5
ffffffffc0202c98:	842a                	mv	s0,a0

    struct Page *p;
    p = alloc_page();
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0202c9a:	00093503          	ld	a0,0(s2)
ffffffffc0202c9e:	4699                	li	a3,6
ffffffffc0202ca0:	10000613          	li	a2,256
ffffffffc0202ca4:	85a2                	mv	a1,s0
ffffffffc0202ca6:	aadff0ef          	jal	ffffffffc0202752 <page_insert>
ffffffffc0202caa:	46051363          	bnez	a0,ffffffffc0203110 <pmm_init+0x8c8>
    assert(page_ref(p) == 1);
ffffffffc0202cae:	4018                	lw	a4,0(s0)
ffffffffc0202cb0:	4785                	li	a5,1
ffffffffc0202cb2:	42f71f63          	bne	a4,a5,ffffffffc02030f0 <pmm_init+0x8a8>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc0202cb6:	00093503          	ld	a0,0(s2)
ffffffffc0202cba:	6605                	lui	a2,0x1
ffffffffc0202cbc:	10060613          	addi	a2,a2,256 # 1100 <_binary_obj___user_softint_out_size-0x7ad0>
ffffffffc0202cc0:	4699                	li	a3,6
ffffffffc0202cc2:	85a2                	mv	a1,s0
ffffffffc0202cc4:	a8fff0ef          	jal	ffffffffc0202752 <page_insert>
ffffffffc0202cc8:	72051963          	bnez	a0,ffffffffc02033fa <pmm_init+0xbb2>
    assert(page_ref(p) == 2);
ffffffffc0202ccc:	4018                	lw	a4,0(s0)
ffffffffc0202cce:	4789                	li	a5,2
ffffffffc0202cd0:	70f71563          	bne	a4,a5,ffffffffc02033da <pmm_init+0xb92>

    const char *str = "ucore: Hello world!!";
    strcpy((void *)0x100, str);
ffffffffc0202cd4:	00004597          	auipc	a1,0x4
ffffffffc0202cd8:	0c458593          	addi	a1,a1,196 # ffffffffc0206d98 <etext+0x141a>
ffffffffc0202cdc:	10000513          	li	a0,256
ffffffffc0202ce0:	3f5020ef          	jal	ffffffffc02058d4 <strcpy>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc0202ce4:	6585                	lui	a1,0x1
ffffffffc0202ce6:	10058593          	addi	a1,a1,256 # 1100 <_binary_obj___user_softint_out_size-0x7ad0>
ffffffffc0202cea:	10000513          	li	a0,256
ffffffffc0202cee:	3f9020ef          	jal	ffffffffc02058e6 <strcmp>
ffffffffc0202cf2:	6c051463          	bnez	a0,ffffffffc02033ba <pmm_init+0xb72>
    return page - pages + nbase;
ffffffffc0202cf6:	000bb683          	ld	a3,0(s7)
ffffffffc0202cfa:	000807b7          	lui	a5,0x80
    return KADDR(page2pa(page));
ffffffffc0202cfe:	6098                	ld	a4,0(s1)
    return page - pages + nbase;
ffffffffc0202d00:	40d406b3          	sub	a3,s0,a3
ffffffffc0202d04:	8699                	srai	a3,a3,0x6
ffffffffc0202d06:	96be                	add	a3,a3,a5
    return KADDR(page2pa(page));
ffffffffc0202d08:	00c69793          	slli	a5,a3,0xc
ffffffffc0202d0c:	83b1                	srli	a5,a5,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d0e:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0202d10:	32e7f463          	bgeu	a5,a4,ffffffffc0203038 <pmm_init+0x7f0>

    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202d14:	0009b783          	ld	a5,0(s3)
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202d18:	10000513          	li	a0,256
    *(char *)(page2kva(p) + 0x100) = '\0';
ffffffffc0202d1c:	97b6                	add	a5,a5,a3
ffffffffc0202d1e:	10078023          	sb	zero,256(a5) # 80100 <_binary_obj___user_exit_out_size+0x75f40>
    assert(strlen((const char *)0x100) == 0);
ffffffffc0202d22:	37f020ef          	jal	ffffffffc02058a0 <strlen>
ffffffffc0202d26:	66051a63          	bnez	a0,ffffffffc020339a <pmm_init+0xb52>

    pde_t *pd1 = boot_pgdir_va, *pd0 = page2kva(pde2page(boot_pgdir_va[0]));
ffffffffc0202d2a:	00093a03          	ld	s4,0(s2)
    if (PPN(pa) >= npage)
ffffffffc0202d2e:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d30:	000a3783          	ld	a5,0(s4) # fffffffffffff000 <end+0x3fd63848>
ffffffffc0202d34:	078a                	slli	a5,a5,0x2
ffffffffc0202d36:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202d38:	26e7f663          	bgeu	a5,a4,ffffffffc0202fa4 <pmm_init+0x75c>
    return page2ppn(page) << PGSHIFT;
ffffffffc0202d3c:	00c79693          	slli	a3,a5,0xc
    return KADDR(page2pa(page));
ffffffffc0202d40:	2ee7fc63          	bgeu	a5,a4,ffffffffc0203038 <pmm_init+0x7f0>
ffffffffc0202d44:	0009b783          	ld	a5,0(s3)
ffffffffc0202d48:	00f689b3          	add	s3,a3,a5
ffffffffc0202d4c:	100027f3          	csrr	a5,sstatus
ffffffffc0202d50:	8b89                	andi	a5,a5,2
ffffffffc0202d52:	1e079163          	bnez	a5,ffffffffc0202f34 <pmm_init+0x6ec>
        pmm_manager->free_pages(base, n);
ffffffffc0202d56:	000b3783          	ld	a5,0(s6)
ffffffffc0202d5a:	8522                	mv	a0,s0
ffffffffc0202d5c:	4585                	li	a1,1
ffffffffc0202d5e:	739c                	ld	a5,32(a5)
ffffffffc0202d60:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d62:	0009b783          	ld	a5,0(s3)
    if (PPN(pa) >= npage)
ffffffffc0202d66:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d68:	078a                	slli	a5,a5,0x2
ffffffffc0202d6a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202d6c:	22e7fc63          	bgeu	a5,a4,ffffffffc0202fa4 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202d70:	000bb503          	ld	a0,0(s7)
ffffffffc0202d74:	fe000737          	lui	a4,0xfe000
ffffffffc0202d78:	079a                	slli	a5,a5,0x6
ffffffffc0202d7a:	97ba                	add	a5,a5,a4
ffffffffc0202d7c:	953e                	add	a0,a0,a5
ffffffffc0202d7e:	100027f3          	csrr	a5,sstatus
ffffffffc0202d82:	8b89                	andi	a5,a5,2
ffffffffc0202d84:	18079c63          	bnez	a5,ffffffffc0202f1c <pmm_init+0x6d4>
ffffffffc0202d88:	000b3783          	ld	a5,0(s6)
ffffffffc0202d8c:	4585                	li	a1,1
ffffffffc0202d8e:	739c                	ld	a5,32(a5)
ffffffffc0202d90:	9782                	jalr	a5
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d92:	000a3783          	ld	a5,0(s4)
    if (PPN(pa) >= npage)
ffffffffc0202d96:	6098                	ld	a4,0(s1)
    return pa2page(PDE_ADDR(pde));
ffffffffc0202d98:	078a                	slli	a5,a5,0x2
ffffffffc0202d9a:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc0202d9c:	20e7f463          	bgeu	a5,a4,ffffffffc0202fa4 <pmm_init+0x75c>
    return &pages[PPN(pa) - nbase];
ffffffffc0202da0:	000bb503          	ld	a0,0(s7)
ffffffffc0202da4:	fe000737          	lui	a4,0xfe000
ffffffffc0202da8:	079a                	slli	a5,a5,0x6
ffffffffc0202daa:	97ba                	add	a5,a5,a4
ffffffffc0202dac:	953e                	add	a0,a0,a5
ffffffffc0202dae:	100027f3          	csrr	a5,sstatus
ffffffffc0202db2:	8b89                	andi	a5,a5,2
ffffffffc0202db4:	14079863          	bnez	a5,ffffffffc0202f04 <pmm_init+0x6bc>
ffffffffc0202db8:	000b3783          	ld	a5,0(s6)
ffffffffc0202dbc:	4585                	li	a1,1
ffffffffc0202dbe:	739c                	ld	a5,32(a5)
ffffffffc0202dc0:	9782                	jalr	a5
    free_page(p);
    free_page(pde2page(pd0[0]));
    free_page(pde2page(pd1[0]));
    boot_pgdir_va[0] = 0;
ffffffffc0202dc2:	00093783          	ld	a5,0(s2)
ffffffffc0202dc6:	0007b023          	sd	zero,0(a5)
    asm volatile("sfence.vma");
ffffffffc0202dca:	12000073          	sfence.vma
ffffffffc0202dce:	100027f3          	csrr	a5,sstatus
ffffffffc0202dd2:	8b89                	andi	a5,a5,2
ffffffffc0202dd4:	10079e63          	bnez	a5,ffffffffc0202ef0 <pmm_init+0x6a8>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202dd8:	000b3783          	ld	a5,0(s6)
ffffffffc0202ddc:	779c                	ld	a5,40(a5)
ffffffffc0202dde:	9782                	jalr	a5
ffffffffc0202de0:	842a                	mv	s0,a0
    flush_tlb();

    assert(nr_free_store == nr_free_pages());
ffffffffc0202de2:	1e8c1b63          	bne	s8,s0,ffffffffc0202fd8 <pmm_init+0x790>

    cprintf("check_boot_pgdir() succeeded!\n");
ffffffffc0202de6:	00004517          	auipc	a0,0x4
ffffffffc0202dea:	02a50513          	addi	a0,a0,42 # ffffffffc0206e10 <etext+0x1492>
ffffffffc0202dee:	ba6fd0ef          	jal	ffffffffc0200194 <cprintf>
}
ffffffffc0202df2:	7406                	ld	s0,96(sp)
ffffffffc0202df4:	70a6                	ld	ra,104(sp)
ffffffffc0202df6:	64e6                	ld	s1,88(sp)
ffffffffc0202df8:	6946                	ld	s2,80(sp)
ffffffffc0202dfa:	69a6                	ld	s3,72(sp)
ffffffffc0202dfc:	6a06                	ld	s4,64(sp)
ffffffffc0202dfe:	7ae2                	ld	s5,56(sp)
ffffffffc0202e00:	7b42                	ld	s6,48(sp)
ffffffffc0202e02:	7ba2                	ld	s7,40(sp)
ffffffffc0202e04:	7c02                	ld	s8,32(sp)
ffffffffc0202e06:	6ce2                	ld	s9,24(sp)
ffffffffc0202e08:	6165                	addi	sp,sp,112
    kmalloc_init();
ffffffffc0202e0a:	f83fe06f          	j	ffffffffc0201d8c <kmalloc_init>
    if (maxpa > KERNTOP)
ffffffffc0202e0e:	853e                	mv	a0,a5
ffffffffc0202e10:	b4e1                	j	ffffffffc02028d8 <pmm_init+0x90>
        intr_disable();
ffffffffc0202e12:	af3fd0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202e16:	000b3783          	ld	a5,0(s6)
ffffffffc0202e1a:	4505                	li	a0,1
ffffffffc0202e1c:	6f9c                	ld	a5,24(a5)
ffffffffc0202e1e:	9782                	jalr	a5
ffffffffc0202e20:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202e22:	addfd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202e26:	be75                	j	ffffffffc02029e2 <pmm_init+0x19a>
        intr_disable();
ffffffffc0202e28:	addfd0ef          	jal	ffffffffc0200904 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202e2c:	000b3783          	ld	a5,0(s6)
ffffffffc0202e30:	779c                	ld	a5,40(a5)
ffffffffc0202e32:	9782                	jalr	a5
ffffffffc0202e34:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202e36:	ac9fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202e3a:	b6ad                	j	ffffffffc02029a4 <pmm_init+0x15c>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0202e3c:	6705                	lui	a4,0x1
ffffffffc0202e3e:	177d                	addi	a4,a4,-1 # fff <_binary_obj___user_softint_out_size-0x7bd1>
ffffffffc0202e40:	96ba                	add	a3,a3,a4
ffffffffc0202e42:	8ff5                	and	a5,a5,a3
    if (PPN(pa) >= npage)
ffffffffc0202e44:	00c7d713          	srli	a4,a5,0xc
ffffffffc0202e48:	14a77e63          	bgeu	a4,a0,ffffffffc0202fa4 <pmm_init+0x75c>
    pmm_manager->init_memmap(base, n);
ffffffffc0202e4c:	000b3683          	ld	a3,0(s6)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0202e50:	8c1d                	sub	s0,s0,a5
    return &pages[PPN(pa) - nbase];
ffffffffc0202e52:	071a                	slli	a4,a4,0x6
ffffffffc0202e54:	fe0007b7          	lui	a5,0xfe000
ffffffffc0202e58:	973e                	add	a4,a4,a5
    pmm_manager->init_memmap(base, n);
ffffffffc0202e5a:	6a9c                	ld	a5,16(a3)
ffffffffc0202e5c:	00c45593          	srli	a1,s0,0xc
ffffffffc0202e60:	00e60533          	add	a0,a2,a4
ffffffffc0202e64:	9782                	jalr	a5
    cprintf("vapaofset is %llu\n", va_pa_offset);
ffffffffc0202e66:	0009b583          	ld	a1,0(s3)
}
ffffffffc0202e6a:	bcf1                	j	ffffffffc0202946 <pmm_init+0xfe>
        intr_disable();
ffffffffc0202e6c:	a99fd0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202e70:	000b3783          	ld	a5,0(s6)
ffffffffc0202e74:	4505                	li	a0,1
ffffffffc0202e76:	6f9c                	ld	a5,24(a5)
ffffffffc0202e78:	9782                	jalr	a5
ffffffffc0202e7a:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202e7c:	a83fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202e80:	b119                	j	ffffffffc0202a86 <pmm_init+0x23e>
        intr_disable();
ffffffffc0202e82:	a83fd0ef          	jal	ffffffffc0200904 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202e86:	000b3783          	ld	a5,0(s6)
ffffffffc0202e8a:	779c                	ld	a5,40(a5)
ffffffffc0202e8c:	9782                	jalr	a5
ffffffffc0202e8e:	8c2a                	mv	s8,a0
        intr_enable();
ffffffffc0202e90:	a6ffd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202e94:	b345                	j	ffffffffc0202c34 <pmm_init+0x3ec>
        intr_disable();
ffffffffc0202e96:	a6ffd0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc0202e9a:	000b3783          	ld	a5,0(s6)
ffffffffc0202e9e:	779c                	ld	a5,40(a5)
ffffffffc0202ea0:	9782                	jalr	a5
ffffffffc0202ea2:	8a2a                	mv	s4,a0
        intr_enable();
ffffffffc0202ea4:	a5bfd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202ea8:	b3a5                	j	ffffffffc0202c10 <pmm_init+0x3c8>
ffffffffc0202eaa:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202eac:	a59fd0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202eb0:	000b3783          	ld	a5,0(s6)
ffffffffc0202eb4:	6522                	ld	a0,8(sp)
ffffffffc0202eb6:	4585                	li	a1,1
ffffffffc0202eb8:	739c                	ld	a5,32(a5)
ffffffffc0202eba:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ebc:	a43fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202ec0:	bb05                	j	ffffffffc0202bf0 <pmm_init+0x3a8>
ffffffffc0202ec2:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202ec4:	a41fd0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc0202ec8:	000b3783          	ld	a5,0(s6)
ffffffffc0202ecc:	6522                	ld	a0,8(sp)
ffffffffc0202ece:	4585                	li	a1,1
ffffffffc0202ed0:	739c                	ld	a5,32(a5)
ffffffffc0202ed2:	9782                	jalr	a5
        intr_enable();
ffffffffc0202ed4:	a2bfd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202ed8:	b1e5                	j	ffffffffc0202bc0 <pmm_init+0x378>
        intr_disable();
ffffffffc0202eda:	a2bfd0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0202ede:	000b3783          	ld	a5,0(s6)
ffffffffc0202ee2:	4505                	li	a0,1
ffffffffc0202ee4:	6f9c                	ld	a5,24(a5)
ffffffffc0202ee6:	9782                	jalr	a5
ffffffffc0202ee8:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202eea:	a15fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202eee:	b375                	j	ffffffffc0202c9a <pmm_init+0x452>
        intr_disable();
ffffffffc0202ef0:	a15fd0ef          	jal	ffffffffc0200904 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0202ef4:	000b3783          	ld	a5,0(s6)
ffffffffc0202ef8:	779c                	ld	a5,40(a5)
ffffffffc0202efa:	9782                	jalr	a5
ffffffffc0202efc:	842a                	mv	s0,a0
        intr_enable();
ffffffffc0202efe:	a01fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202f02:	b5c5                	j	ffffffffc0202de2 <pmm_init+0x59a>
ffffffffc0202f04:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202f06:	9fffd0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0202f0a:	000b3783          	ld	a5,0(s6)
ffffffffc0202f0e:	6522                	ld	a0,8(sp)
ffffffffc0202f10:	4585                	li	a1,1
ffffffffc0202f12:	739c                	ld	a5,32(a5)
ffffffffc0202f14:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f16:	9e9fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202f1a:	b565                	j	ffffffffc0202dc2 <pmm_init+0x57a>
ffffffffc0202f1c:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc0202f1e:	9e7fd0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc0202f22:	000b3783          	ld	a5,0(s6)
ffffffffc0202f26:	6522                	ld	a0,8(sp)
ffffffffc0202f28:	4585                	li	a1,1
ffffffffc0202f2a:	739c                	ld	a5,32(a5)
ffffffffc0202f2c:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f2e:	9d1fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202f32:	b585                	j	ffffffffc0202d92 <pmm_init+0x54a>
        intr_disable();
ffffffffc0202f34:	9d1fd0ef          	jal	ffffffffc0200904 <intr_disable>
ffffffffc0202f38:	000b3783          	ld	a5,0(s6)
ffffffffc0202f3c:	8522                	mv	a0,s0
ffffffffc0202f3e:	4585                	li	a1,1
ffffffffc0202f40:	739c                	ld	a5,32(a5)
ffffffffc0202f42:	9782                	jalr	a5
        intr_enable();
ffffffffc0202f44:	9bbfd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0202f48:	bd29                	j	ffffffffc0202d62 <pmm_init+0x51a>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202f4a:	86a2                	mv	a3,s0
ffffffffc0202f4c:	00003617          	auipc	a2,0x3
ffffffffc0202f50:	7dc60613          	addi	a2,a2,2012 # ffffffffc0206728 <etext+0xdaa>
ffffffffc0202f54:	24e00593          	li	a1,590
ffffffffc0202f58:	00004517          	auipc	a0,0x4
ffffffffc0202f5c:	8c050513          	addi	a0,a0,-1856 # ffffffffc0206818 <etext+0xe9a>
ffffffffc0202f60:	ce6fd0ef          	jal	ffffffffc0200446 <__panic>
        assert(PTE_ADDR(*ptep) == i);
ffffffffc0202f64:	00004697          	auipc	a3,0x4
ffffffffc0202f68:	d4c68693          	addi	a3,a3,-692 # ffffffffc0206cb0 <etext+0x1332>
ffffffffc0202f6c:	00003617          	auipc	a2,0x3
ffffffffc0202f70:	40c60613          	addi	a2,a2,1036 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0202f74:	24f00593          	li	a1,591
ffffffffc0202f78:	00004517          	auipc	a0,0x4
ffffffffc0202f7c:	8a050513          	addi	a0,a0,-1888 # ffffffffc0206818 <etext+0xe9a>
ffffffffc0202f80:	cc6fd0ef          	jal	ffffffffc0200446 <__panic>
        assert((ptep = get_pte(boot_pgdir_va, (uintptr_t)KADDR(i), 0)) != NULL);
ffffffffc0202f84:	00004697          	auipc	a3,0x4
ffffffffc0202f88:	cec68693          	addi	a3,a3,-788 # ffffffffc0206c70 <etext+0x12f2>
ffffffffc0202f8c:	00003617          	auipc	a2,0x3
ffffffffc0202f90:	3ec60613          	addi	a2,a2,1004 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0202f94:	24e00593          	li	a1,590
ffffffffc0202f98:	00004517          	auipc	a0,0x4
ffffffffc0202f9c:	88050513          	addi	a0,a0,-1920 # ffffffffc0206818 <etext+0xe9a>
ffffffffc0202fa0:	ca6fd0ef          	jal	ffffffffc0200446 <__panic>
ffffffffc0202fa4:	fb5fe0ef          	jal	ffffffffc0201f58 <pa2page.part.0>
        panic("pte2page called with invalid pte");
ffffffffc0202fa8:	00004617          	auipc	a2,0x4
ffffffffc0202fac:	a6860613          	addi	a2,a2,-1432 # ffffffffc0206a10 <etext+0x1092>
ffffffffc0202fb0:	07f00593          	li	a1,127
ffffffffc0202fb4:	00003517          	auipc	a0,0x3
ffffffffc0202fb8:	79c50513          	addi	a0,a0,1948 # ffffffffc0206750 <etext+0xdd2>
ffffffffc0202fbc:	c8afd0ef          	jal	ffffffffc0200446 <__panic>
        panic("DTB memory info not available");
ffffffffc0202fc0:	00004617          	auipc	a2,0x4
ffffffffc0202fc4:	8c860613          	addi	a2,a2,-1848 # ffffffffc0206888 <etext+0xf0a>
ffffffffc0202fc8:	06500593          	li	a1,101
ffffffffc0202fcc:	00004517          	auipc	a0,0x4
ffffffffc0202fd0:	84c50513          	addi	a0,a0,-1972 # ffffffffc0206818 <etext+0xe9a>
ffffffffc0202fd4:	c72fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc0202fd8:	00004697          	auipc	a3,0x4
ffffffffc0202fdc:	c5068693          	addi	a3,a3,-944 # ffffffffc0206c28 <etext+0x12aa>
ffffffffc0202fe0:	00003617          	auipc	a2,0x3
ffffffffc0202fe4:	39860613          	addi	a2,a2,920 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0202fe8:	26900593          	li	a1,617
ffffffffc0202fec:	00004517          	auipc	a0,0x4
ffffffffc0202ff0:	82c50513          	addi	a0,a0,-2004 # ffffffffc0206818 <etext+0xe9a>
ffffffffc0202ff4:	c52fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(boot_pgdir_va != NULL && (uint32_t)PGOFF(boot_pgdir_va) == 0);
ffffffffc0202ff8:	00004697          	auipc	a3,0x4
ffffffffc0202ffc:	94868693          	addi	a3,a3,-1720 # ffffffffc0206940 <etext+0xfc2>
ffffffffc0203000:	00003617          	auipc	a2,0x3
ffffffffc0203004:	37860613          	addi	a2,a2,888 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203008:	21000593          	li	a1,528
ffffffffc020300c:	00004517          	auipc	a0,0x4
ffffffffc0203010:	80c50513          	addi	a0,a0,-2036 # ffffffffc0206818 <etext+0xe9a>
ffffffffc0203014:	c32fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(npage <= KERNTOP / PGSIZE);
ffffffffc0203018:	00004697          	auipc	a3,0x4
ffffffffc020301c:	90868693          	addi	a3,a3,-1784 # ffffffffc0206920 <etext+0xfa2>
ffffffffc0203020:	00003617          	auipc	a2,0x3
ffffffffc0203024:	35860613          	addi	a2,a2,856 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203028:	20f00593          	li	a1,527
ffffffffc020302c:	00003517          	auipc	a0,0x3
ffffffffc0203030:	7ec50513          	addi	a0,a0,2028 # ffffffffc0206818 <etext+0xe9a>
ffffffffc0203034:	c12fd0ef          	jal	ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc0203038:	00003617          	auipc	a2,0x3
ffffffffc020303c:	6f060613          	addi	a2,a2,1776 # ffffffffc0206728 <etext+0xdaa>
ffffffffc0203040:	07100593          	li	a1,113
ffffffffc0203044:	00003517          	auipc	a0,0x3
ffffffffc0203048:	70c50513          	addi	a0,a0,1804 # ffffffffc0206750 <etext+0xdd2>
ffffffffc020304c:	bfafd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(pde2page(boot_pgdir_va[0])) == 1);
ffffffffc0203050:	00004697          	auipc	a3,0x4
ffffffffc0203054:	ba868693          	addi	a3,a3,-1112 # ffffffffc0206bf8 <etext+0x127a>
ffffffffc0203058:	00003617          	auipc	a2,0x3
ffffffffc020305c:	32060613          	addi	a2,a2,800 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203060:	23700593          	li	a1,567
ffffffffc0203064:	00003517          	auipc	a0,0x3
ffffffffc0203068:	7b450513          	addi	a0,a0,1972 # ffffffffc0206818 <etext+0xe9a>
ffffffffc020306c:	bdafd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203070:	00004697          	auipc	a3,0x4
ffffffffc0203074:	b4068693          	addi	a3,a3,-1216 # ffffffffc0206bb0 <etext+0x1232>
ffffffffc0203078:	00003617          	auipc	a2,0x3
ffffffffc020307c:	30060613          	addi	a2,a2,768 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203080:	23500593          	li	a1,565
ffffffffc0203084:	00003517          	auipc	a0,0x3
ffffffffc0203088:	79450513          	addi	a0,a0,1940 # ffffffffc0206818 <etext+0xe9a>
ffffffffc020308c:	bbafd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 0);
ffffffffc0203090:	00004697          	auipc	a3,0x4
ffffffffc0203094:	b5068693          	addi	a3,a3,-1200 # ffffffffc0206be0 <etext+0x1262>
ffffffffc0203098:	00003617          	auipc	a2,0x3
ffffffffc020309c:	2e060613          	addi	a2,a2,736 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02030a0:	23400593          	li	a1,564
ffffffffc02030a4:	00003517          	auipc	a0,0x3
ffffffffc02030a8:	77450513          	addi	a0,a0,1908 # ffffffffc0206818 <etext+0xe9a>
ffffffffc02030ac:	b9afd0ef          	jal	ffffffffc0200446 <__panic>
    assert(boot_pgdir_va[0] == 0);
ffffffffc02030b0:	00004697          	auipc	a3,0x4
ffffffffc02030b4:	c1868693          	addi	a3,a3,-1000 # ffffffffc0206cc8 <etext+0x134a>
ffffffffc02030b8:	00003617          	auipc	a2,0x3
ffffffffc02030bc:	2c060613          	addi	a2,a2,704 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02030c0:	25200593          	li	a1,594
ffffffffc02030c4:	00003517          	auipc	a0,0x3
ffffffffc02030c8:	75450513          	addi	a0,a0,1876 # ffffffffc0206818 <etext+0xe9a>
ffffffffc02030cc:	b7afd0ef          	jal	ffffffffc0200446 <__panic>
    assert(nr_free_store == nr_free_pages());
ffffffffc02030d0:	00004697          	auipc	a3,0x4
ffffffffc02030d4:	b5868693          	addi	a3,a3,-1192 # ffffffffc0206c28 <etext+0x12aa>
ffffffffc02030d8:	00003617          	auipc	a2,0x3
ffffffffc02030dc:	2a060613          	addi	a2,a2,672 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02030e0:	23f00593          	li	a1,575
ffffffffc02030e4:	00003517          	auipc	a0,0x3
ffffffffc02030e8:	73450513          	addi	a0,a0,1844 # ffffffffc0206818 <etext+0xe9a>
ffffffffc02030ec:	b5afd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p) == 1);
ffffffffc02030f0:	00004697          	auipc	a3,0x4
ffffffffc02030f4:	c3068693          	addi	a3,a3,-976 # ffffffffc0206d20 <etext+0x13a2>
ffffffffc02030f8:	00003617          	auipc	a2,0x3
ffffffffc02030fc:	28060613          	addi	a2,a2,640 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203100:	25700593          	li	a1,599
ffffffffc0203104:	00003517          	auipc	a0,0x3
ffffffffc0203108:	71450513          	addi	a0,a0,1812 # ffffffffc0206818 <etext+0xe9a>
ffffffffc020310c:	b3afd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100, PTE_W | PTE_R) == 0);
ffffffffc0203110:	00004697          	auipc	a3,0x4
ffffffffc0203114:	bd068693          	addi	a3,a3,-1072 # ffffffffc0206ce0 <etext+0x1362>
ffffffffc0203118:	00003617          	auipc	a2,0x3
ffffffffc020311c:	26060613          	addi	a2,a2,608 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203120:	25600593          	li	a1,598
ffffffffc0203124:	00003517          	auipc	a0,0x3
ffffffffc0203128:	6f450513          	addi	a0,a0,1780 # ffffffffc0206818 <etext+0xe9a>
ffffffffc020312c:	b1afd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc0203130:	00004697          	auipc	a3,0x4
ffffffffc0203134:	a8068693          	addi	a3,a3,-1408 # ffffffffc0206bb0 <etext+0x1232>
ffffffffc0203138:	00003617          	auipc	a2,0x3
ffffffffc020313c:	24060613          	addi	a2,a2,576 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203140:	23100593          	li	a1,561
ffffffffc0203144:	00003517          	auipc	a0,0x3
ffffffffc0203148:	6d450513          	addi	a0,a0,1748 # ffffffffc0206818 <etext+0xe9a>
ffffffffc020314c:	afafd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc0203150:	00004697          	auipc	a3,0x4
ffffffffc0203154:	90068693          	addi	a3,a3,-1792 # ffffffffc0206a50 <etext+0x10d2>
ffffffffc0203158:	00003617          	auipc	a2,0x3
ffffffffc020315c:	22060613          	addi	a2,a2,544 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203160:	23000593          	li	a1,560
ffffffffc0203164:	00003517          	auipc	a0,0x3
ffffffffc0203168:	6b450513          	addi	a0,a0,1716 # ffffffffc0206818 <etext+0xe9a>
ffffffffc020316c:	adafd0ef          	jal	ffffffffc0200446 <__panic>
    assert((*ptep & PTE_U) == 0);
ffffffffc0203170:	00004697          	auipc	a3,0x4
ffffffffc0203174:	a5868693          	addi	a3,a3,-1448 # ffffffffc0206bc8 <etext+0x124a>
ffffffffc0203178:	00003617          	auipc	a2,0x3
ffffffffc020317c:	20060613          	addi	a2,a2,512 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203180:	22d00593          	li	a1,557
ffffffffc0203184:	00003517          	auipc	a0,0x3
ffffffffc0203188:	69450513          	addi	a0,a0,1684 # ffffffffc0206818 <etext+0xe9a>
ffffffffc020318c:	abafd0ef          	jal	ffffffffc0200446 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc0203190:	00004697          	auipc	a3,0x4
ffffffffc0203194:	8a868693          	addi	a3,a3,-1880 # ffffffffc0206a38 <etext+0x10ba>
ffffffffc0203198:	00003617          	auipc	a2,0x3
ffffffffc020319c:	1e060613          	addi	a2,a2,480 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02031a0:	22c00593          	li	a1,556
ffffffffc02031a4:	00003517          	auipc	a0,0x3
ffffffffc02031a8:	67450513          	addi	a0,a0,1652 # ffffffffc0206818 <etext+0xe9a>
ffffffffc02031ac:	a9afd0ef          	jal	ffffffffc0200446 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02031b0:	00004697          	auipc	a3,0x4
ffffffffc02031b4:	92868693          	addi	a3,a3,-1752 # ffffffffc0206ad8 <etext+0x115a>
ffffffffc02031b8:	00003617          	auipc	a2,0x3
ffffffffc02031bc:	1c060613          	addi	a2,a2,448 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02031c0:	22b00593          	li	a1,555
ffffffffc02031c4:	00003517          	auipc	a0,0x3
ffffffffc02031c8:	65450513          	addi	a0,a0,1620 # ffffffffc0206818 <etext+0xe9a>
ffffffffc02031cc:	a7afd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 0);
ffffffffc02031d0:	00004697          	auipc	a3,0x4
ffffffffc02031d4:	9e068693          	addi	a3,a3,-1568 # ffffffffc0206bb0 <etext+0x1232>
ffffffffc02031d8:	00003617          	auipc	a2,0x3
ffffffffc02031dc:	1a060613          	addi	a2,a2,416 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02031e0:	22a00593          	li	a1,554
ffffffffc02031e4:	00003517          	auipc	a0,0x3
ffffffffc02031e8:	63450513          	addi	a0,a0,1588 # ffffffffc0206818 <etext+0xe9a>
ffffffffc02031ec:	a5afd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 2);
ffffffffc02031f0:	00004697          	auipc	a3,0x4
ffffffffc02031f4:	9a868693          	addi	a3,a3,-1624 # ffffffffc0206b98 <etext+0x121a>
ffffffffc02031f8:	00003617          	auipc	a2,0x3
ffffffffc02031fc:	18060613          	addi	a2,a2,384 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203200:	22900593          	li	a1,553
ffffffffc0203204:	00003517          	auipc	a0,0x3
ffffffffc0203208:	61450513          	addi	a0,a0,1556 # ffffffffc0206818 <etext+0xe9a>
ffffffffc020320c:	a3afd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir_va, p1, PGSIZE, 0) == 0);
ffffffffc0203210:	00004697          	auipc	a3,0x4
ffffffffc0203214:	95868693          	addi	a3,a3,-1704 # ffffffffc0206b68 <etext+0x11ea>
ffffffffc0203218:	00003617          	auipc	a2,0x3
ffffffffc020321c:	16060613          	addi	a2,a2,352 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203220:	22800593          	li	a1,552
ffffffffc0203224:	00003517          	auipc	a0,0x3
ffffffffc0203228:	5f450513          	addi	a0,a0,1524 # ffffffffc0206818 <etext+0xe9a>
ffffffffc020322c:	a1afd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p2) == 1);
ffffffffc0203230:	00004697          	auipc	a3,0x4
ffffffffc0203234:	92068693          	addi	a3,a3,-1760 # ffffffffc0206b50 <etext+0x11d2>
ffffffffc0203238:	00003617          	auipc	a2,0x3
ffffffffc020323c:	14060613          	addi	a2,a2,320 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203240:	22600593          	li	a1,550
ffffffffc0203244:	00003517          	auipc	a0,0x3
ffffffffc0203248:	5d450513          	addi	a0,a0,1492 # ffffffffc0206818 <etext+0xe9a>
ffffffffc020324c:	9fafd0ef          	jal	ffffffffc0200446 <__panic>
    assert(boot_pgdir_va[0] & PTE_U);
ffffffffc0203250:	00004697          	auipc	a3,0x4
ffffffffc0203254:	8e068693          	addi	a3,a3,-1824 # ffffffffc0206b30 <etext+0x11b2>
ffffffffc0203258:	00003617          	auipc	a2,0x3
ffffffffc020325c:	12060613          	addi	a2,a2,288 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203260:	22500593          	li	a1,549
ffffffffc0203264:	00003517          	auipc	a0,0x3
ffffffffc0203268:	5b450513          	addi	a0,a0,1460 # ffffffffc0206818 <etext+0xe9a>
ffffffffc020326c:	9dafd0ef          	jal	ffffffffc0200446 <__panic>
    assert(*ptep & PTE_W);
ffffffffc0203270:	00004697          	auipc	a3,0x4
ffffffffc0203274:	8b068693          	addi	a3,a3,-1872 # ffffffffc0206b20 <etext+0x11a2>
ffffffffc0203278:	00003617          	auipc	a2,0x3
ffffffffc020327c:	10060613          	addi	a2,a2,256 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203280:	22400593          	li	a1,548
ffffffffc0203284:	00003517          	auipc	a0,0x3
ffffffffc0203288:	59450513          	addi	a0,a0,1428 # ffffffffc0206818 <etext+0xe9a>
ffffffffc020328c:	9bafd0ef          	jal	ffffffffc0200446 <__panic>
    assert(*ptep & PTE_U);
ffffffffc0203290:	00004697          	auipc	a3,0x4
ffffffffc0203294:	88068693          	addi	a3,a3,-1920 # ffffffffc0206b10 <etext+0x1192>
ffffffffc0203298:	00003617          	auipc	a2,0x3
ffffffffc020329c:	0e060613          	addi	a2,a2,224 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02032a0:	22300593          	li	a1,547
ffffffffc02032a4:	00003517          	auipc	a0,0x3
ffffffffc02032a8:	57450513          	addi	a0,a0,1396 # ffffffffc0206818 <etext+0xe9a>
ffffffffc02032ac:	99afd0ef          	jal	ffffffffc0200446 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02032b0:	00003617          	auipc	a2,0x3
ffffffffc02032b4:	52060613          	addi	a2,a2,1312 # ffffffffc02067d0 <etext+0xe52>
ffffffffc02032b8:	08100593          	li	a1,129
ffffffffc02032bc:	00003517          	auipc	a0,0x3
ffffffffc02032c0:	55c50513          	addi	a0,a0,1372 # ffffffffc0206818 <etext+0xe9a>
ffffffffc02032c4:	982fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(get_pte(boot_pgdir_va, PGSIZE, 0) == ptep);
ffffffffc02032c8:	00003697          	auipc	a3,0x3
ffffffffc02032cc:	7a068693          	addi	a3,a3,1952 # ffffffffc0206a68 <etext+0x10ea>
ffffffffc02032d0:	00003617          	auipc	a2,0x3
ffffffffc02032d4:	0a860613          	addi	a2,a2,168 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02032d8:	21e00593          	li	a1,542
ffffffffc02032dc:	00003517          	auipc	a0,0x3
ffffffffc02032e0:	53c50513          	addi	a0,a0,1340 # ffffffffc0206818 <etext+0xe9a>
ffffffffc02032e4:	962fd0ef          	jal	ffffffffc0200446 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, PGSIZE, 0)) != NULL);
ffffffffc02032e8:	00003697          	auipc	a3,0x3
ffffffffc02032ec:	7f068693          	addi	a3,a3,2032 # ffffffffc0206ad8 <etext+0x115a>
ffffffffc02032f0:	00003617          	auipc	a2,0x3
ffffffffc02032f4:	08860613          	addi	a2,a2,136 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02032f8:	22200593          	li	a1,546
ffffffffc02032fc:	00003517          	auipc	a0,0x3
ffffffffc0203300:	51c50513          	addi	a0,a0,1308 # ffffffffc0206818 <etext+0xe9a>
ffffffffc0203304:	942fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir_va, p2, PGSIZE, PTE_U | PTE_W) == 0);
ffffffffc0203308:	00003697          	auipc	a3,0x3
ffffffffc020330c:	79068693          	addi	a3,a3,1936 # ffffffffc0206a98 <etext+0x111a>
ffffffffc0203310:	00003617          	auipc	a2,0x3
ffffffffc0203314:	06860613          	addi	a2,a2,104 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203318:	22100593          	li	a1,545
ffffffffc020331c:	00003517          	auipc	a0,0x3
ffffffffc0203320:	4fc50513          	addi	a0,a0,1276 # ffffffffc0206818 <etext+0xe9a>
ffffffffc0203324:	922fd0ef          	jal	ffffffffc0200446 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(ptep[0])) + 1;
ffffffffc0203328:	86d6                	mv	a3,s5
ffffffffc020332a:	00003617          	auipc	a2,0x3
ffffffffc020332e:	3fe60613          	addi	a2,a2,1022 # ffffffffc0206728 <etext+0xdaa>
ffffffffc0203332:	21d00593          	li	a1,541
ffffffffc0203336:	00003517          	auipc	a0,0x3
ffffffffc020333a:	4e250513          	addi	a0,a0,1250 # ffffffffc0206818 <etext+0xe9a>
ffffffffc020333e:	908fd0ef          	jal	ffffffffc0200446 <__panic>
    ptep = (pte_t *)KADDR(PDE_ADDR(boot_pgdir_va[0]));
ffffffffc0203342:	00003617          	auipc	a2,0x3
ffffffffc0203346:	3e660613          	addi	a2,a2,998 # ffffffffc0206728 <etext+0xdaa>
ffffffffc020334a:	21c00593          	li	a1,540
ffffffffc020334e:	00003517          	auipc	a0,0x3
ffffffffc0203352:	4ca50513          	addi	a0,a0,1226 # ffffffffc0206818 <etext+0xe9a>
ffffffffc0203356:	8f0fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p1) == 1);
ffffffffc020335a:	00003697          	auipc	a3,0x3
ffffffffc020335e:	6f668693          	addi	a3,a3,1782 # ffffffffc0206a50 <etext+0x10d2>
ffffffffc0203362:	00003617          	auipc	a2,0x3
ffffffffc0203366:	01660613          	addi	a2,a2,22 # ffffffffc0206378 <etext+0x9fa>
ffffffffc020336a:	21a00593          	li	a1,538
ffffffffc020336e:	00003517          	auipc	a0,0x3
ffffffffc0203372:	4aa50513          	addi	a0,a0,1194 # ffffffffc0206818 <etext+0xe9a>
ffffffffc0203376:	8d0fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(pte2page(*ptep) == p1);
ffffffffc020337a:	00003697          	auipc	a3,0x3
ffffffffc020337e:	6be68693          	addi	a3,a3,1726 # ffffffffc0206a38 <etext+0x10ba>
ffffffffc0203382:	00003617          	auipc	a2,0x3
ffffffffc0203386:	ff660613          	addi	a2,a2,-10 # ffffffffc0206378 <etext+0x9fa>
ffffffffc020338a:	21900593          	li	a1,537
ffffffffc020338e:	00003517          	auipc	a0,0x3
ffffffffc0203392:	48a50513          	addi	a0,a0,1162 # ffffffffc0206818 <etext+0xe9a>
ffffffffc0203396:	8b0fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(strlen((const char *)0x100) == 0);
ffffffffc020339a:	00004697          	auipc	a3,0x4
ffffffffc020339e:	a4e68693          	addi	a3,a3,-1458 # ffffffffc0206de8 <etext+0x146a>
ffffffffc02033a2:	00003617          	auipc	a2,0x3
ffffffffc02033a6:	fd660613          	addi	a2,a2,-42 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02033aa:	26000593          	li	a1,608
ffffffffc02033ae:	00003517          	auipc	a0,0x3
ffffffffc02033b2:	46a50513          	addi	a0,a0,1130 # ffffffffc0206818 <etext+0xe9a>
ffffffffc02033b6:	890fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(strcmp((void *)0x100, (void *)(0x100 + PGSIZE)) == 0);
ffffffffc02033ba:	00004697          	auipc	a3,0x4
ffffffffc02033be:	9f668693          	addi	a3,a3,-1546 # ffffffffc0206db0 <etext+0x1432>
ffffffffc02033c2:	00003617          	auipc	a2,0x3
ffffffffc02033c6:	fb660613          	addi	a2,a2,-74 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02033ca:	25d00593          	li	a1,605
ffffffffc02033ce:	00003517          	auipc	a0,0x3
ffffffffc02033d2:	44a50513          	addi	a0,a0,1098 # ffffffffc0206818 <etext+0xe9a>
ffffffffc02033d6:	870fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_ref(p) == 2);
ffffffffc02033da:	00004697          	auipc	a3,0x4
ffffffffc02033de:	9a668693          	addi	a3,a3,-1626 # ffffffffc0206d80 <etext+0x1402>
ffffffffc02033e2:	00003617          	auipc	a2,0x3
ffffffffc02033e6:	f9660613          	addi	a2,a2,-106 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02033ea:	25900593          	li	a1,601
ffffffffc02033ee:	00003517          	auipc	a0,0x3
ffffffffc02033f2:	42a50513          	addi	a0,a0,1066 # ffffffffc0206818 <etext+0xe9a>
ffffffffc02033f6:	850fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir_va, p, 0x100 + PGSIZE, PTE_W | PTE_R) == 0);
ffffffffc02033fa:	00004697          	auipc	a3,0x4
ffffffffc02033fe:	93e68693          	addi	a3,a3,-1730 # ffffffffc0206d38 <etext+0x13ba>
ffffffffc0203402:	00003617          	auipc	a2,0x3
ffffffffc0203406:	f7660613          	addi	a2,a2,-138 # ffffffffc0206378 <etext+0x9fa>
ffffffffc020340a:	25800593          	li	a1,600
ffffffffc020340e:	00003517          	auipc	a0,0x3
ffffffffc0203412:	40a50513          	addi	a0,a0,1034 # ffffffffc0206818 <etext+0xe9a>
ffffffffc0203416:	830fd0ef          	jal	ffffffffc0200446 <__panic>
    assert(get_page(boot_pgdir_va, 0x0, NULL) == NULL);
ffffffffc020341a:	00003697          	auipc	a3,0x3
ffffffffc020341e:	56668693          	addi	a3,a3,1382 # ffffffffc0206980 <etext+0x1002>
ffffffffc0203422:	00003617          	auipc	a2,0x3
ffffffffc0203426:	f5660613          	addi	a2,a2,-170 # ffffffffc0206378 <etext+0x9fa>
ffffffffc020342a:	21100593          	li	a1,529
ffffffffc020342e:	00003517          	auipc	a0,0x3
ffffffffc0203432:	3ea50513          	addi	a0,a0,1002 # ffffffffc0206818 <etext+0xe9a>
ffffffffc0203436:	810fd0ef          	jal	ffffffffc0200446 <__panic>
    boot_pgdir_pa = PADDR(boot_pgdir_va);
ffffffffc020343a:	00003617          	auipc	a2,0x3
ffffffffc020343e:	39660613          	addi	a2,a2,918 # ffffffffc02067d0 <etext+0xe52>
ffffffffc0203442:	0c900593          	li	a1,201
ffffffffc0203446:	00003517          	auipc	a0,0x3
ffffffffc020344a:	3d250513          	addi	a0,a0,978 # ffffffffc0206818 <etext+0xe9a>
ffffffffc020344e:	ff9fc0ef          	jal	ffffffffc0200446 <__panic>
    assert((ptep = get_pte(boot_pgdir_va, 0x0, 0)) != NULL);
ffffffffc0203452:	00003697          	auipc	a3,0x3
ffffffffc0203456:	58e68693          	addi	a3,a3,1422 # ffffffffc02069e0 <etext+0x1062>
ffffffffc020345a:	00003617          	auipc	a2,0x3
ffffffffc020345e:	f1e60613          	addi	a2,a2,-226 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203462:	21800593          	li	a1,536
ffffffffc0203466:	00003517          	auipc	a0,0x3
ffffffffc020346a:	3b250513          	addi	a0,a0,946 # ffffffffc0206818 <etext+0xe9a>
ffffffffc020346e:	fd9fc0ef          	jal	ffffffffc0200446 <__panic>
    assert(page_insert(boot_pgdir_va, p1, 0x0, 0) == 0);
ffffffffc0203472:	00003697          	auipc	a3,0x3
ffffffffc0203476:	53e68693          	addi	a3,a3,1342 # ffffffffc02069b0 <etext+0x1032>
ffffffffc020347a:	00003617          	auipc	a2,0x3
ffffffffc020347e:	efe60613          	addi	a2,a2,-258 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203482:	21500593          	li	a1,533
ffffffffc0203486:	00003517          	auipc	a0,0x3
ffffffffc020348a:	39250513          	addi	a0,a0,914 # ffffffffc0206818 <etext+0xe9a>
ffffffffc020348e:	fb9fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0203492 <copy_range>:
{
ffffffffc0203492:	7159                	addi	sp,sp,-112
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc0203494:	00d667b3          	or	a5,a2,a3
{
ffffffffc0203498:	f486                	sd	ra,104(sp)
ffffffffc020349a:	f0a2                	sd	s0,96(sp)
ffffffffc020349c:	eca6                	sd	s1,88(sp)
ffffffffc020349e:	e8ca                	sd	s2,80(sp)
ffffffffc02034a0:	e4ce                	sd	s3,72(sp)
ffffffffc02034a2:	e0d2                	sd	s4,64(sp)
ffffffffc02034a4:	fc56                	sd	s5,56(sp)
ffffffffc02034a6:	f85a                	sd	s6,48(sp)
ffffffffc02034a8:	f45e                	sd	s7,40(sp)
ffffffffc02034aa:	f062                	sd	s8,32(sp)
ffffffffc02034ac:	ec66                	sd	s9,24(sp)
ffffffffc02034ae:	e86a                	sd	s10,16(sp)
ffffffffc02034b0:	e46e                	sd	s11,8(sp)
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02034b2:	03479713          	slli	a4,a5,0x34
ffffffffc02034b6:	20071f63          	bnez	a4,ffffffffc02036d4 <copy_range+0x242>
    assert(USER_ACCESS(start, end));
ffffffffc02034ba:	002007b7          	lui	a5,0x200
ffffffffc02034be:	00d63733          	sltu	a4,a2,a3
ffffffffc02034c2:	00f637b3          	sltu	a5,a2,a5
ffffffffc02034c6:	00173713          	seqz	a4,a4
ffffffffc02034ca:	8fd9                	or	a5,a5,a4
ffffffffc02034cc:	8432                	mv	s0,a2
ffffffffc02034ce:	8936                	mv	s2,a3
ffffffffc02034d0:	1e079263          	bnez	a5,ffffffffc02036b4 <copy_range+0x222>
ffffffffc02034d4:	4785                	li	a5,1
ffffffffc02034d6:	07fe                	slli	a5,a5,0x1f
ffffffffc02034d8:	0785                	addi	a5,a5,1 # 200001 <_binary_obj___user_exit_out_size+0x1f5e41>
ffffffffc02034da:	1cf6fd63          	bgeu	a3,a5,ffffffffc02036b4 <copy_range+0x222>
ffffffffc02034de:	5b7d                	li	s6,-1
ffffffffc02034e0:	8baa                	mv	s7,a0
ffffffffc02034e2:	8a2e                	mv	s4,a1
ffffffffc02034e4:	6a85                	lui	s5,0x1
ffffffffc02034e6:	00cb5b13          	srli	s6,s6,0xc
    if (PPN(pa) >= npage)
ffffffffc02034ea:	00098c97          	auipc	s9,0x98
ffffffffc02034ee:	29ec8c93          	addi	s9,s9,670 # ffffffffc029b788 <npage>
    return &pages[PPN(pa) - nbase];
ffffffffc02034f2:	00098c17          	auipc	s8,0x98
ffffffffc02034f6:	29ec0c13          	addi	s8,s8,670 # ffffffffc029b790 <pages>
ffffffffc02034fa:	fff80d37          	lui	s10,0xfff80
        pte_t *ptep = get_pte(from, start, 0), *nptep;
ffffffffc02034fe:	4601                	li	a2,0
ffffffffc0203500:	85a2                	mv	a1,s0
ffffffffc0203502:	8552                	mv	a0,s4
ffffffffc0203504:	b19fe0ef          	jal	ffffffffc020201c <get_pte>
ffffffffc0203508:	84aa                	mv	s1,a0
        if (ptep == NULL)
ffffffffc020350a:	0e050a63          	beqz	a0,ffffffffc02035fe <copy_range+0x16c>
        if (*ptep & PTE_V)
ffffffffc020350e:	611c                	ld	a5,0(a0)
ffffffffc0203510:	8b85                	andi	a5,a5,1
ffffffffc0203512:	e78d                	bnez	a5,ffffffffc020353c <copy_range+0xaa>
        start += PGSIZE;
ffffffffc0203514:	9456                	add	s0,s0,s5
    } while (start != 0 && start < end);
ffffffffc0203516:	c019                	beqz	s0,ffffffffc020351c <copy_range+0x8a>
ffffffffc0203518:	ff2463e3          	bltu	s0,s2,ffffffffc02034fe <copy_range+0x6c>
    return 0;
ffffffffc020351c:	4501                	li	a0,0
}
ffffffffc020351e:	70a6                	ld	ra,104(sp)
ffffffffc0203520:	7406                	ld	s0,96(sp)
ffffffffc0203522:	64e6                	ld	s1,88(sp)
ffffffffc0203524:	6946                	ld	s2,80(sp)
ffffffffc0203526:	69a6                	ld	s3,72(sp)
ffffffffc0203528:	6a06                	ld	s4,64(sp)
ffffffffc020352a:	7ae2                	ld	s5,56(sp)
ffffffffc020352c:	7b42                	ld	s6,48(sp)
ffffffffc020352e:	7ba2                	ld	s7,40(sp)
ffffffffc0203530:	7c02                	ld	s8,32(sp)
ffffffffc0203532:	6ce2                	ld	s9,24(sp)
ffffffffc0203534:	6d42                	ld	s10,16(sp)
ffffffffc0203536:	6da2                	ld	s11,8(sp)
ffffffffc0203538:	6165                	addi	sp,sp,112
ffffffffc020353a:	8082                	ret
            if ((nptep = get_pte(to, start, 1)) == NULL)
ffffffffc020353c:	4605                	li	a2,1
ffffffffc020353e:	85a2                	mv	a1,s0
ffffffffc0203540:	855e                	mv	a0,s7
ffffffffc0203542:	adbfe0ef          	jal	ffffffffc020201c <get_pte>
ffffffffc0203546:	c165                	beqz	a0,ffffffffc0203626 <copy_range+0x194>
            uint32_t perm = (*ptep & PTE_USER);
ffffffffc0203548:	0004b983          	ld	s3,0(s1)
    if (!(pte & PTE_V))
ffffffffc020354c:	0019f793          	andi	a5,s3,1
ffffffffc0203550:	14078663          	beqz	a5,ffffffffc020369c <copy_range+0x20a>
    if (PPN(pa) >= npage)
ffffffffc0203554:	000cb703          	ld	a4,0(s9)
    return pa2page(PTE_ADDR(pte));
ffffffffc0203558:	00299793          	slli	a5,s3,0x2
ffffffffc020355c:	83b1                	srli	a5,a5,0xc
    if (PPN(pa) >= npage)
ffffffffc020355e:	12e7f363          	bgeu	a5,a4,ffffffffc0203684 <copy_range+0x1f2>
    return &pages[PPN(pa) - nbase];
ffffffffc0203562:	000c3483          	ld	s1,0(s8)
ffffffffc0203566:	97ea                	add	a5,a5,s10
ffffffffc0203568:	079a                	slli	a5,a5,0x6
ffffffffc020356a:	94be                	add	s1,s1,a5
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020356c:	100027f3          	csrr	a5,sstatus
ffffffffc0203570:	8b89                	andi	a5,a5,2
ffffffffc0203572:	efc9                	bnez	a5,ffffffffc020360c <copy_range+0x17a>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203574:	00098797          	auipc	a5,0x98
ffffffffc0203578:	1f47b783          	ld	a5,500(a5) # ffffffffc029b768 <pmm_manager>
ffffffffc020357c:	4505                	li	a0,1
ffffffffc020357e:	6f9c                	ld	a5,24(a5)
ffffffffc0203580:	9782                	jalr	a5
ffffffffc0203582:	8daa                	mv	s11,a0
            assert(page != NULL);
ffffffffc0203584:	c0e5                	beqz	s1,ffffffffc0203664 <copy_range+0x1d2>
            assert(npage != NULL);
ffffffffc0203586:	0a0d8f63          	beqz	s11,ffffffffc0203644 <copy_range+0x1b2>
    return page - pages + nbase;
ffffffffc020358a:	000c3783          	ld	a5,0(s8)
ffffffffc020358e:	00080637          	lui	a2,0x80
    return KADDR(page2pa(page));
ffffffffc0203592:	000cb703          	ld	a4,0(s9)
    return page - pages + nbase;
ffffffffc0203596:	40f486b3          	sub	a3,s1,a5
ffffffffc020359a:	8699                	srai	a3,a3,0x6
ffffffffc020359c:	96b2                	add	a3,a3,a2
    return KADDR(page2pa(page));
ffffffffc020359e:	0166f5b3          	and	a1,a3,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02035a2:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02035a4:	08e5f463          	bgeu	a1,a4,ffffffffc020362c <copy_range+0x19a>
    return page - pages + nbase;
ffffffffc02035a8:	40fd87b3          	sub	a5,s11,a5
ffffffffc02035ac:	8799                	srai	a5,a5,0x6
ffffffffc02035ae:	97b2                	add	a5,a5,a2
    return KADDR(page2pa(page));
ffffffffc02035b0:	0167f633          	and	a2,a5,s6
    return page2ppn(page) << PGSHIFT;
ffffffffc02035b4:	07b2                	slli	a5,a5,0xc
    return KADDR(page2pa(page));
ffffffffc02035b6:	06e67a63          	bgeu	a2,a4,ffffffffc020362a <copy_range+0x198>
ffffffffc02035ba:	00098517          	auipc	a0,0x98
ffffffffc02035be:	1c653503          	ld	a0,454(a0) # ffffffffc029b780 <va_pa_offset>
            memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
ffffffffc02035c2:	6605                	lui	a2,0x1
ffffffffc02035c4:	00a685b3          	add	a1,a3,a0
ffffffffc02035c8:	953e                	add	a0,a0,a5
ffffffffc02035ca:	39c020ef          	jal	ffffffffc0205966 <memcpy>
            ret = page_insert(to, npage, start, perm);
ffffffffc02035ce:	01f9f693          	andi	a3,s3,31
ffffffffc02035d2:	85ee                	mv	a1,s11
ffffffffc02035d4:	8622                	mv	a2,s0
ffffffffc02035d6:	855e                	mv	a0,s7
ffffffffc02035d8:	97aff0ef          	jal	ffffffffc0202752 <page_insert>
            assert(ret == 0);
ffffffffc02035dc:	dd05                	beqz	a0,ffffffffc0203514 <copy_range+0x82>
ffffffffc02035de:	00004697          	auipc	a3,0x4
ffffffffc02035e2:	87268693          	addi	a3,a3,-1934 # ffffffffc0206e50 <etext+0x14d2>
ffffffffc02035e6:	00003617          	auipc	a2,0x3
ffffffffc02035ea:	d9260613          	addi	a2,a2,-622 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02035ee:	1ad00593          	li	a1,429
ffffffffc02035f2:	00003517          	auipc	a0,0x3
ffffffffc02035f6:	22650513          	addi	a0,a0,550 # ffffffffc0206818 <etext+0xe9a>
ffffffffc02035fa:	e4dfc0ef          	jal	ffffffffc0200446 <__panic>
            start = ROUNDDOWN(start + PTSIZE, PTSIZE);
ffffffffc02035fe:	002007b7          	lui	a5,0x200
ffffffffc0203602:	97a2                	add	a5,a5,s0
ffffffffc0203604:	ffe00437          	lui	s0,0xffe00
ffffffffc0203608:	8c7d                	and	s0,s0,a5
            continue;
ffffffffc020360a:	b731                	j	ffffffffc0203516 <copy_range+0x84>
        intr_disable();
ffffffffc020360c:	af8fd0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203610:	00098797          	auipc	a5,0x98
ffffffffc0203614:	1587b783          	ld	a5,344(a5) # ffffffffc029b768 <pmm_manager>
ffffffffc0203618:	4505                	li	a0,1
ffffffffc020361a:	6f9c                	ld	a5,24(a5)
ffffffffc020361c:	9782                	jalr	a5
ffffffffc020361e:	8daa                	mv	s11,a0
        intr_enable();
ffffffffc0203620:	adefd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc0203624:	b785                	j	ffffffffc0203584 <copy_range+0xf2>
                return -E_NO_MEM;
ffffffffc0203626:	5571                	li	a0,-4
ffffffffc0203628:	bddd                	j	ffffffffc020351e <copy_range+0x8c>
ffffffffc020362a:	86be                	mv	a3,a5
ffffffffc020362c:	00003617          	auipc	a2,0x3
ffffffffc0203630:	0fc60613          	addi	a2,a2,252 # ffffffffc0206728 <etext+0xdaa>
ffffffffc0203634:	07100593          	li	a1,113
ffffffffc0203638:	00003517          	auipc	a0,0x3
ffffffffc020363c:	11850513          	addi	a0,a0,280 # ffffffffc0206750 <etext+0xdd2>
ffffffffc0203640:	e07fc0ef          	jal	ffffffffc0200446 <__panic>
            assert(npage != NULL);
ffffffffc0203644:	00003697          	auipc	a3,0x3
ffffffffc0203648:	7fc68693          	addi	a3,a3,2044 # ffffffffc0206e40 <etext+0x14c2>
ffffffffc020364c:	00003617          	auipc	a2,0x3
ffffffffc0203650:	d2c60613          	addi	a2,a2,-724 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203654:	19500593          	li	a1,405
ffffffffc0203658:	00003517          	auipc	a0,0x3
ffffffffc020365c:	1c050513          	addi	a0,a0,448 # ffffffffc0206818 <etext+0xe9a>
ffffffffc0203660:	de7fc0ef          	jal	ffffffffc0200446 <__panic>
            assert(page != NULL);
ffffffffc0203664:	00003697          	auipc	a3,0x3
ffffffffc0203668:	7cc68693          	addi	a3,a3,1996 # ffffffffc0206e30 <etext+0x14b2>
ffffffffc020366c:	00003617          	auipc	a2,0x3
ffffffffc0203670:	d0c60613          	addi	a2,a2,-756 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203674:	19400593          	li	a1,404
ffffffffc0203678:	00003517          	auipc	a0,0x3
ffffffffc020367c:	1a050513          	addi	a0,a0,416 # ffffffffc0206818 <etext+0xe9a>
ffffffffc0203680:	dc7fc0ef          	jal	ffffffffc0200446 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0203684:	00003617          	auipc	a2,0x3
ffffffffc0203688:	17460613          	addi	a2,a2,372 # ffffffffc02067f8 <etext+0xe7a>
ffffffffc020368c:	06900593          	li	a1,105
ffffffffc0203690:	00003517          	auipc	a0,0x3
ffffffffc0203694:	0c050513          	addi	a0,a0,192 # ffffffffc0206750 <etext+0xdd2>
ffffffffc0203698:	daffc0ef          	jal	ffffffffc0200446 <__panic>
        panic("pte2page called with invalid pte");
ffffffffc020369c:	00003617          	auipc	a2,0x3
ffffffffc02036a0:	37460613          	addi	a2,a2,884 # ffffffffc0206a10 <etext+0x1092>
ffffffffc02036a4:	07f00593          	li	a1,127
ffffffffc02036a8:	00003517          	auipc	a0,0x3
ffffffffc02036ac:	0a850513          	addi	a0,a0,168 # ffffffffc0206750 <etext+0xdd2>
ffffffffc02036b0:	d97fc0ef          	jal	ffffffffc0200446 <__panic>
    assert(USER_ACCESS(start, end));
ffffffffc02036b4:	00003697          	auipc	a3,0x3
ffffffffc02036b8:	1a468693          	addi	a3,a3,420 # ffffffffc0206858 <etext+0xeda>
ffffffffc02036bc:	00003617          	auipc	a2,0x3
ffffffffc02036c0:	cbc60613          	addi	a2,a2,-836 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02036c4:	17c00593          	li	a1,380
ffffffffc02036c8:	00003517          	auipc	a0,0x3
ffffffffc02036cc:	15050513          	addi	a0,a0,336 # ffffffffc0206818 <etext+0xe9a>
ffffffffc02036d0:	d77fc0ef          	jal	ffffffffc0200446 <__panic>
    assert(start % PGSIZE == 0 && end % PGSIZE == 0);
ffffffffc02036d4:	00003697          	auipc	a3,0x3
ffffffffc02036d8:	15468693          	addi	a3,a3,340 # ffffffffc0206828 <etext+0xeaa>
ffffffffc02036dc:	00003617          	auipc	a2,0x3
ffffffffc02036e0:	c9c60613          	addi	a2,a2,-868 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02036e4:	17b00593          	li	a1,379
ffffffffc02036e8:	00003517          	auipc	a0,0x3
ffffffffc02036ec:	13050513          	addi	a0,a0,304 # ffffffffc0206818 <etext+0xe9a>
ffffffffc02036f0:	d57fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02036f4 <pgdir_alloc_page>:
{
ffffffffc02036f4:	7139                	addi	sp,sp,-64
ffffffffc02036f6:	f426                	sd	s1,40(sp)
ffffffffc02036f8:	f04a                	sd	s2,32(sp)
ffffffffc02036fa:	ec4e                	sd	s3,24(sp)
ffffffffc02036fc:	fc06                	sd	ra,56(sp)
ffffffffc02036fe:	f822                	sd	s0,48(sp)
ffffffffc0203700:	892a                	mv	s2,a0
ffffffffc0203702:	84ae                	mv	s1,a1
ffffffffc0203704:	89b2                	mv	s3,a2
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0203706:	100027f3          	csrr	a5,sstatus
ffffffffc020370a:	8b89                	andi	a5,a5,2
ffffffffc020370c:	ebb5                	bnez	a5,ffffffffc0203780 <pgdir_alloc_page+0x8c>
        page = pmm_manager->alloc_pages(n);
ffffffffc020370e:	00098417          	auipc	s0,0x98
ffffffffc0203712:	05a40413          	addi	s0,s0,90 # ffffffffc029b768 <pmm_manager>
ffffffffc0203716:	601c                	ld	a5,0(s0)
ffffffffc0203718:	4505                	li	a0,1
ffffffffc020371a:	6f9c                	ld	a5,24(a5)
ffffffffc020371c:	9782                	jalr	a5
ffffffffc020371e:	85aa                	mv	a1,a0
    if (page != NULL)
ffffffffc0203720:	c5b9                	beqz	a1,ffffffffc020376e <pgdir_alloc_page+0x7a>
        if (page_insert(pgdir, page, la, perm) != 0)
ffffffffc0203722:	86ce                	mv	a3,s3
ffffffffc0203724:	854a                	mv	a0,s2
ffffffffc0203726:	8626                	mv	a2,s1
ffffffffc0203728:	e42e                	sd	a1,8(sp)
ffffffffc020372a:	828ff0ef          	jal	ffffffffc0202752 <page_insert>
ffffffffc020372e:	65a2                	ld	a1,8(sp)
ffffffffc0203730:	e515                	bnez	a0,ffffffffc020375c <pgdir_alloc_page+0x68>
        assert(page_ref(page) == 1);
ffffffffc0203732:	4198                	lw	a4,0(a1)
        page->pra_vaddr = la;
ffffffffc0203734:	fd84                	sd	s1,56(a1)
        assert(page_ref(page) == 1);
ffffffffc0203736:	4785                	li	a5,1
ffffffffc0203738:	02f70c63          	beq	a4,a5,ffffffffc0203770 <pgdir_alloc_page+0x7c>
ffffffffc020373c:	00003697          	auipc	a3,0x3
ffffffffc0203740:	72468693          	addi	a3,a3,1828 # ffffffffc0206e60 <etext+0x14e2>
ffffffffc0203744:	00003617          	auipc	a2,0x3
ffffffffc0203748:	c3460613          	addi	a2,a2,-972 # ffffffffc0206378 <etext+0x9fa>
ffffffffc020374c:	1f600593          	li	a1,502
ffffffffc0203750:	00003517          	auipc	a0,0x3
ffffffffc0203754:	0c850513          	addi	a0,a0,200 # ffffffffc0206818 <etext+0xe9a>
ffffffffc0203758:	ceffc0ef          	jal	ffffffffc0200446 <__panic>
ffffffffc020375c:	100027f3          	csrr	a5,sstatus
ffffffffc0203760:	8b89                	andi	a5,a5,2
ffffffffc0203762:	ef95                	bnez	a5,ffffffffc020379e <pgdir_alloc_page+0xaa>
        pmm_manager->free_pages(base, n);
ffffffffc0203764:	601c                	ld	a5,0(s0)
ffffffffc0203766:	852e                	mv	a0,a1
ffffffffc0203768:	4585                	li	a1,1
ffffffffc020376a:	739c                	ld	a5,32(a5)
ffffffffc020376c:	9782                	jalr	a5
            return NULL;
ffffffffc020376e:	4581                	li	a1,0
}
ffffffffc0203770:	70e2                	ld	ra,56(sp)
ffffffffc0203772:	7442                	ld	s0,48(sp)
ffffffffc0203774:	74a2                	ld	s1,40(sp)
ffffffffc0203776:	7902                	ld	s2,32(sp)
ffffffffc0203778:	69e2                	ld	s3,24(sp)
ffffffffc020377a:	852e                	mv	a0,a1
ffffffffc020377c:	6121                	addi	sp,sp,64
ffffffffc020377e:	8082                	ret
        intr_disable();
ffffffffc0203780:	984fd0ef          	jal	ffffffffc0200904 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc0203784:	00098417          	auipc	s0,0x98
ffffffffc0203788:	fe440413          	addi	s0,s0,-28 # ffffffffc029b768 <pmm_manager>
ffffffffc020378c:	601c                	ld	a5,0(s0)
ffffffffc020378e:	4505                	li	a0,1
ffffffffc0203790:	6f9c                	ld	a5,24(a5)
ffffffffc0203792:	9782                	jalr	a5
ffffffffc0203794:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0203796:	968fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc020379a:	65a2                	ld	a1,8(sp)
ffffffffc020379c:	b751                	j	ffffffffc0203720 <pgdir_alloc_page+0x2c>
        intr_disable();
ffffffffc020379e:	966fd0ef          	jal	ffffffffc0200904 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc02037a2:	601c                	ld	a5,0(s0)
ffffffffc02037a4:	6522                	ld	a0,8(sp)
ffffffffc02037a6:	4585                	li	a1,1
ffffffffc02037a8:	739c                	ld	a5,32(a5)
ffffffffc02037aa:	9782                	jalr	a5
        intr_enable();
ffffffffc02037ac:	952fd0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc02037b0:	bf7d                	j	ffffffffc020376e <pgdir_alloc_page+0x7a>

ffffffffc02037b2 <check_vma_overlap.part.0>:
    return vma;
}

// check_vma_overlap - check if vma1 overlaps vma2 ?
static inline void
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02037b2:	1141                	addi	sp,sp,-16
{
    assert(prev->vm_start < prev->vm_end);
    assert(prev->vm_end <= next->vm_start);
    assert(next->vm_start < next->vm_end);
ffffffffc02037b4:	00003697          	auipc	a3,0x3
ffffffffc02037b8:	6c468693          	addi	a3,a3,1732 # ffffffffc0206e78 <etext+0x14fa>
ffffffffc02037bc:	00003617          	auipc	a2,0x3
ffffffffc02037c0:	bbc60613          	addi	a2,a2,-1092 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02037c4:	07400593          	li	a1,116
ffffffffc02037c8:	00003517          	auipc	a0,0x3
ffffffffc02037cc:	6d050513          	addi	a0,a0,1744 # ffffffffc0206e98 <etext+0x151a>
check_vma_overlap(struct vma_struct *prev, struct vma_struct *next)
ffffffffc02037d0:	e406                	sd	ra,8(sp)
    assert(next->vm_start < next->vm_end);
ffffffffc02037d2:	c75fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02037d6 <mm_create>:
{
ffffffffc02037d6:	1141                	addi	sp,sp,-16
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02037d8:	04000513          	li	a0,64
{
ffffffffc02037dc:	e406                	sd	ra,8(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc02037de:	dd2fe0ef          	jal	ffffffffc0201db0 <kmalloc>
    if (mm != NULL)
ffffffffc02037e2:	cd19                	beqz	a0,ffffffffc0203800 <mm_create+0x2a>
    elm->prev = elm->next = elm;
ffffffffc02037e4:	e508                	sd	a0,8(a0)
ffffffffc02037e6:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc02037e8:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc02037ec:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc02037f0:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc02037f4:	02053423          	sd	zero,40(a0)
}

static inline void
set_mm_count(struct mm_struct *mm, int val)
{
    mm->mm_count = val;
ffffffffc02037f8:	02052823          	sw	zero,48(a0)
typedef volatile bool lock_t;

static inline void
lock_init(lock_t *lock)
{
    *lock = 0;
ffffffffc02037fc:	02053c23          	sd	zero,56(a0)
}
ffffffffc0203800:	60a2                	ld	ra,8(sp)
ffffffffc0203802:	0141                	addi	sp,sp,16
ffffffffc0203804:	8082                	ret

ffffffffc0203806 <find_vma>:
    if (mm != NULL)
ffffffffc0203806:	c505                	beqz	a0,ffffffffc020382e <find_vma+0x28>
        vma = mm->mmap_cache;
ffffffffc0203808:	691c                	ld	a5,16(a0)
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc020380a:	c781                	beqz	a5,ffffffffc0203812 <find_vma+0xc>
ffffffffc020380c:	6798                	ld	a4,8(a5)
ffffffffc020380e:	02e5f363          	bgeu	a1,a4,ffffffffc0203834 <find_vma+0x2e>
    return listelm->next;
ffffffffc0203812:	651c                	ld	a5,8(a0)
            while ((le = list_next(le)) != list)
ffffffffc0203814:	00f50d63          	beq	a0,a5,ffffffffc020382e <find_vma+0x28>
                if (vma->vm_start <= addr && addr < vma->vm_end)
ffffffffc0203818:	fe87b703          	ld	a4,-24(a5)
ffffffffc020381c:	00e5e663          	bltu	a1,a4,ffffffffc0203828 <find_vma+0x22>
ffffffffc0203820:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203824:	00e5ee63          	bltu	a1,a4,ffffffffc0203840 <find_vma+0x3a>
ffffffffc0203828:	679c                	ld	a5,8(a5)
            while ((le = list_next(le)) != list)
ffffffffc020382a:	fef517e3          	bne	a0,a5,ffffffffc0203818 <find_vma+0x12>
    struct vma_struct *vma = NULL;
ffffffffc020382e:	4781                	li	a5,0
}
ffffffffc0203830:	853e                	mv	a0,a5
ffffffffc0203832:	8082                	ret
        if (!(vma != NULL && vma->vm_start <= addr && vma->vm_end > addr))
ffffffffc0203834:	6b98                	ld	a4,16(a5)
ffffffffc0203836:	fce5fee3          	bgeu	a1,a4,ffffffffc0203812 <find_vma+0xc>
            mm->mmap_cache = vma;
ffffffffc020383a:	e91c                	sd	a5,16(a0)
}
ffffffffc020383c:	853e                	mv	a0,a5
ffffffffc020383e:	8082                	ret
                vma = le2vma(le, list_link);
ffffffffc0203840:	1781                	addi	a5,a5,-32
            mm->mmap_cache = vma;
ffffffffc0203842:	e91c                	sd	a5,16(a0)
ffffffffc0203844:	bfe5                	j	ffffffffc020383c <find_vma+0x36>

ffffffffc0203846 <insert_vma_struct>:
}

// insert_vma_struct -insert vma in mm's list link
void insert_vma_struct(struct mm_struct *mm, struct vma_struct *vma)
{
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203846:	6590                	ld	a2,8(a1)
ffffffffc0203848:	0105b803          	ld	a6,16(a1)
{
ffffffffc020384c:	1141                	addi	sp,sp,-16
ffffffffc020384e:	e406                	sd	ra,8(sp)
ffffffffc0203850:	87aa                	mv	a5,a0
    assert(vma->vm_start < vma->vm_end);
ffffffffc0203852:	01066763          	bltu	a2,a6,ffffffffc0203860 <insert_vma_struct+0x1a>
ffffffffc0203856:	a8b9                	j	ffffffffc02038b4 <insert_vma_struct+0x6e>

    list_entry_t *le = list;
    while ((le = list_next(le)) != list)
    {
        struct vma_struct *mmap_prev = le2vma(le, list_link);
        if (mmap_prev->vm_start > vma->vm_start)
ffffffffc0203858:	fe87b703          	ld	a4,-24(a5)
ffffffffc020385c:	04e66763          	bltu	a2,a4,ffffffffc02038aa <insert_vma_struct+0x64>
ffffffffc0203860:	86be                	mv	a3,a5
ffffffffc0203862:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != list)
ffffffffc0203864:	fef51ae3          	bne	a0,a5,ffffffffc0203858 <insert_vma_struct+0x12>
    }

    le_next = list_next(le_prev);

    /* check overlap */
    if (le_prev != list)
ffffffffc0203868:	02a68463          	beq	a3,a0,ffffffffc0203890 <insert_vma_struct+0x4a>
    {
        check_vma_overlap(le2vma(le_prev, list_link), vma);
ffffffffc020386c:	ff06b703          	ld	a4,-16(a3)
    assert(prev->vm_start < prev->vm_end);
ffffffffc0203870:	fe86b883          	ld	a7,-24(a3)
ffffffffc0203874:	08e8f063          	bgeu	a7,a4,ffffffffc02038f4 <insert_vma_struct+0xae>
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203878:	04e66e63          	bltu	a2,a4,ffffffffc02038d4 <insert_vma_struct+0x8e>
    }
    if (le_next != list)
ffffffffc020387c:	00f50a63          	beq	a0,a5,ffffffffc0203890 <insert_vma_struct+0x4a>
ffffffffc0203880:	fe87b703          	ld	a4,-24(a5)
    assert(prev->vm_end <= next->vm_start);
ffffffffc0203884:	05076863          	bltu	a4,a6,ffffffffc02038d4 <insert_vma_struct+0x8e>
    assert(next->vm_start < next->vm_end);
ffffffffc0203888:	ff07b603          	ld	a2,-16(a5)
ffffffffc020388c:	02c77263          	bgeu	a4,a2,ffffffffc02038b0 <insert_vma_struct+0x6a>
    }

    vma->vm_mm = mm;
    list_add_after(le_prev, &(vma->list_link));

    mm->map_count++;
ffffffffc0203890:	5118                	lw	a4,32(a0)
    vma->vm_mm = mm;
ffffffffc0203892:	e188                	sd	a0,0(a1)
    list_add_after(le_prev, &(vma->list_link));
ffffffffc0203894:	02058613          	addi	a2,a1,32
    prev->next = next->prev = elm;
ffffffffc0203898:	e390                	sd	a2,0(a5)
ffffffffc020389a:	e690                	sd	a2,8(a3)
}
ffffffffc020389c:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc020389e:	f59c                	sd	a5,40(a1)
    elm->prev = prev;
ffffffffc02038a0:	f194                	sd	a3,32(a1)
    mm->map_count++;
ffffffffc02038a2:	2705                	addiw	a4,a4,1
ffffffffc02038a4:	d118                	sw	a4,32(a0)
}
ffffffffc02038a6:	0141                	addi	sp,sp,16
ffffffffc02038a8:	8082                	ret
    if (le_prev != list)
ffffffffc02038aa:	fca691e3          	bne	a3,a0,ffffffffc020386c <insert_vma_struct+0x26>
ffffffffc02038ae:	bfd9                	j	ffffffffc0203884 <insert_vma_struct+0x3e>
ffffffffc02038b0:	f03ff0ef          	jal	ffffffffc02037b2 <check_vma_overlap.part.0>
    assert(vma->vm_start < vma->vm_end);
ffffffffc02038b4:	00003697          	auipc	a3,0x3
ffffffffc02038b8:	5f468693          	addi	a3,a3,1524 # ffffffffc0206ea8 <etext+0x152a>
ffffffffc02038bc:	00003617          	auipc	a2,0x3
ffffffffc02038c0:	abc60613          	addi	a2,a2,-1348 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02038c4:	07a00593          	li	a1,122
ffffffffc02038c8:	00003517          	auipc	a0,0x3
ffffffffc02038cc:	5d050513          	addi	a0,a0,1488 # ffffffffc0206e98 <etext+0x151a>
ffffffffc02038d0:	b77fc0ef          	jal	ffffffffc0200446 <__panic>
    assert(prev->vm_end <= next->vm_start);
ffffffffc02038d4:	00003697          	auipc	a3,0x3
ffffffffc02038d8:	61468693          	addi	a3,a3,1556 # ffffffffc0206ee8 <etext+0x156a>
ffffffffc02038dc:	00003617          	auipc	a2,0x3
ffffffffc02038e0:	a9c60613          	addi	a2,a2,-1380 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02038e4:	07300593          	li	a1,115
ffffffffc02038e8:	00003517          	auipc	a0,0x3
ffffffffc02038ec:	5b050513          	addi	a0,a0,1456 # ffffffffc0206e98 <etext+0x151a>
ffffffffc02038f0:	b57fc0ef          	jal	ffffffffc0200446 <__panic>
    assert(prev->vm_start < prev->vm_end);
ffffffffc02038f4:	00003697          	auipc	a3,0x3
ffffffffc02038f8:	5d468693          	addi	a3,a3,1492 # ffffffffc0206ec8 <etext+0x154a>
ffffffffc02038fc:	00003617          	auipc	a2,0x3
ffffffffc0203900:	a7c60613          	addi	a2,a2,-1412 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203904:	07200593          	li	a1,114
ffffffffc0203908:	00003517          	auipc	a0,0x3
ffffffffc020390c:	59050513          	addi	a0,a0,1424 # ffffffffc0206e98 <etext+0x151a>
ffffffffc0203910:	b37fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0203914 <mm_destroy>:

// mm_destroy - free mm and mm internal fields
void mm_destroy(struct mm_struct *mm)
{
    assert(mm_count(mm) == 0);
ffffffffc0203914:	591c                	lw	a5,48(a0)
{
ffffffffc0203916:	1141                	addi	sp,sp,-16
ffffffffc0203918:	e406                	sd	ra,8(sp)
ffffffffc020391a:	e022                	sd	s0,0(sp)
    assert(mm_count(mm) == 0);
ffffffffc020391c:	e78d                	bnez	a5,ffffffffc0203946 <mm_destroy+0x32>
ffffffffc020391e:	842a                	mv	s0,a0
    return listelm->next;
ffffffffc0203920:	6508                	ld	a0,8(a0)

    list_entry_t *list = &(mm->mmap_list), *le;
    while ((le = list_next(list)) != list)
ffffffffc0203922:	00a40c63          	beq	s0,a0,ffffffffc020393a <mm_destroy+0x26>
    __list_del(listelm->prev, listelm->next);
ffffffffc0203926:	6118                	ld	a4,0(a0)
ffffffffc0203928:	651c                	ld	a5,8(a0)
    {
        list_del(le);
        kfree(le2vma(le, list_link)); // kfree vma
ffffffffc020392a:	1501                	addi	a0,a0,-32
    prev->next = next;
ffffffffc020392c:	e71c                	sd	a5,8(a4)
    next->prev = prev;
ffffffffc020392e:	e398                	sd	a4,0(a5)
ffffffffc0203930:	d26fe0ef          	jal	ffffffffc0201e56 <kfree>
    return listelm->next;
ffffffffc0203934:	6408                	ld	a0,8(s0)
    while ((le = list_next(list)) != list)
ffffffffc0203936:	fea418e3          	bne	s0,a0,ffffffffc0203926 <mm_destroy+0x12>
    }
    kfree(mm); // kfree mm
ffffffffc020393a:	8522                	mv	a0,s0
    mm = NULL;
}
ffffffffc020393c:	6402                	ld	s0,0(sp)
ffffffffc020393e:	60a2                	ld	ra,8(sp)
ffffffffc0203940:	0141                	addi	sp,sp,16
    kfree(mm); // kfree mm
ffffffffc0203942:	d14fe06f          	j	ffffffffc0201e56 <kfree>
    assert(mm_count(mm) == 0);
ffffffffc0203946:	00003697          	auipc	a3,0x3
ffffffffc020394a:	5c268693          	addi	a3,a3,1474 # ffffffffc0206f08 <etext+0x158a>
ffffffffc020394e:	00003617          	auipc	a2,0x3
ffffffffc0203952:	a2a60613          	addi	a2,a2,-1494 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203956:	09e00593          	li	a1,158
ffffffffc020395a:	00003517          	auipc	a0,0x3
ffffffffc020395e:	53e50513          	addi	a0,a0,1342 # ffffffffc0206e98 <etext+0x151a>
ffffffffc0203962:	ae5fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0203966 <mm_map>:

int mm_map(struct mm_struct *mm, uintptr_t addr, size_t len, uint32_t vm_flags,
           struct vma_struct **vma_store)
{
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0203966:	6785                	lui	a5,0x1
ffffffffc0203968:	17fd                	addi	a5,a5,-1 # fff <_binary_obj___user_softint_out_size-0x7bd1>
ffffffffc020396a:	963e                	add	a2,a2,a5
    if (!USER_ACCESS(start, end))
ffffffffc020396c:	4785                	li	a5,1
{
ffffffffc020396e:	7139                	addi	sp,sp,-64
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc0203970:	962e                	add	a2,a2,a1
ffffffffc0203972:	787d                	lui	a6,0xfffff
    if (!USER_ACCESS(start, end))
ffffffffc0203974:	07fe                	slli	a5,a5,0x1f
{
ffffffffc0203976:	f822                	sd	s0,48(sp)
ffffffffc0203978:	f426                	sd	s1,40(sp)
ffffffffc020397a:	01067433          	and	s0,a2,a6
    uintptr_t start = ROUNDDOWN(addr, PGSIZE), end = ROUNDUP(addr + len, PGSIZE);
ffffffffc020397e:	0105f4b3          	and	s1,a1,a6
    if (!USER_ACCESS(start, end))
ffffffffc0203982:	0785                	addi	a5,a5,1
ffffffffc0203984:	0084b633          	sltu	a2,s1,s0
ffffffffc0203988:	00f437b3          	sltu	a5,s0,a5
ffffffffc020398c:	00163613          	seqz	a2,a2
ffffffffc0203990:	0017b793          	seqz	a5,a5
{
ffffffffc0203994:	fc06                	sd	ra,56(sp)
    if (!USER_ACCESS(start, end))
ffffffffc0203996:	8fd1                	or	a5,a5,a2
ffffffffc0203998:	ebbd                	bnez	a5,ffffffffc0203a0e <mm_map+0xa8>
ffffffffc020399a:	002007b7          	lui	a5,0x200
ffffffffc020399e:	06f4e863          	bltu	s1,a5,ffffffffc0203a0e <mm_map+0xa8>
ffffffffc02039a2:	f04a                	sd	s2,32(sp)
ffffffffc02039a4:	ec4e                	sd	s3,24(sp)
ffffffffc02039a6:	e852                	sd	s4,16(sp)
ffffffffc02039a8:	892a                	mv	s2,a0
ffffffffc02039aa:	89ba                	mv	s3,a4
ffffffffc02039ac:	8a36                	mv	s4,a3
    {
        return -E_INVAL;
    }

    assert(mm != NULL);
ffffffffc02039ae:	c135                	beqz	a0,ffffffffc0203a12 <mm_map+0xac>

    int ret = -E_INVAL;

    struct vma_struct *vma;
    if ((vma = find_vma(mm, start)) != NULL && end > vma->vm_start)
ffffffffc02039b0:	85a6                	mv	a1,s1
ffffffffc02039b2:	e55ff0ef          	jal	ffffffffc0203806 <find_vma>
ffffffffc02039b6:	c501                	beqz	a0,ffffffffc02039be <mm_map+0x58>
ffffffffc02039b8:	651c                	ld	a5,8(a0)
ffffffffc02039ba:	0487e763          	bltu	a5,s0,ffffffffc0203a08 <mm_map+0xa2>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc02039be:	03000513          	li	a0,48
ffffffffc02039c2:	beefe0ef          	jal	ffffffffc0201db0 <kmalloc>
ffffffffc02039c6:	85aa                	mv	a1,a0
    {
        goto out;
    }
    ret = -E_NO_MEM;
ffffffffc02039c8:	5571                	li	a0,-4
    if (vma != NULL)
ffffffffc02039ca:	c59d                	beqz	a1,ffffffffc02039f8 <mm_map+0x92>
        vma->vm_start = vm_start;
ffffffffc02039cc:	e584                	sd	s1,8(a1)
        vma->vm_end = vm_end;
ffffffffc02039ce:	e980                	sd	s0,16(a1)
        vma->vm_flags = vm_flags;
ffffffffc02039d0:	0145ac23          	sw	s4,24(a1)

    if ((vma = vma_create(start, end, vm_flags)) == NULL)
    {
        goto out;
    }
    insert_vma_struct(mm, vma);
ffffffffc02039d4:	854a                	mv	a0,s2
ffffffffc02039d6:	e42e                	sd	a1,8(sp)
ffffffffc02039d8:	e6fff0ef          	jal	ffffffffc0203846 <insert_vma_struct>
    if (vma_store != NULL)
ffffffffc02039dc:	65a2                	ld	a1,8(sp)
ffffffffc02039de:	00098463          	beqz	s3,ffffffffc02039e6 <mm_map+0x80>
    {
        *vma_store = vma;
ffffffffc02039e2:	00b9b023          	sd	a1,0(s3)
ffffffffc02039e6:	7902                	ld	s2,32(sp)
ffffffffc02039e8:	69e2                	ld	s3,24(sp)
ffffffffc02039ea:	6a42                	ld	s4,16(sp)
    }
    ret = 0;
ffffffffc02039ec:	4501                	li	a0,0

out:
    return ret;
}
ffffffffc02039ee:	70e2                	ld	ra,56(sp)
ffffffffc02039f0:	7442                	ld	s0,48(sp)
ffffffffc02039f2:	74a2                	ld	s1,40(sp)
ffffffffc02039f4:	6121                	addi	sp,sp,64
ffffffffc02039f6:	8082                	ret
ffffffffc02039f8:	70e2                	ld	ra,56(sp)
ffffffffc02039fa:	7442                	ld	s0,48(sp)
ffffffffc02039fc:	7902                	ld	s2,32(sp)
ffffffffc02039fe:	69e2                	ld	s3,24(sp)
ffffffffc0203a00:	6a42                	ld	s4,16(sp)
ffffffffc0203a02:	74a2                	ld	s1,40(sp)
ffffffffc0203a04:	6121                	addi	sp,sp,64
ffffffffc0203a06:	8082                	ret
ffffffffc0203a08:	7902                	ld	s2,32(sp)
ffffffffc0203a0a:	69e2                	ld	s3,24(sp)
ffffffffc0203a0c:	6a42                	ld	s4,16(sp)
        return -E_INVAL;
ffffffffc0203a0e:	5575                	li	a0,-3
ffffffffc0203a10:	bff9                	j	ffffffffc02039ee <mm_map+0x88>
    assert(mm != NULL);
ffffffffc0203a12:	00003697          	auipc	a3,0x3
ffffffffc0203a16:	50e68693          	addi	a3,a3,1294 # ffffffffc0206f20 <etext+0x15a2>
ffffffffc0203a1a:	00003617          	auipc	a2,0x3
ffffffffc0203a1e:	95e60613          	addi	a2,a2,-1698 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203a22:	0b300593          	li	a1,179
ffffffffc0203a26:	00003517          	auipc	a0,0x3
ffffffffc0203a2a:	47250513          	addi	a0,a0,1138 # ffffffffc0206e98 <etext+0x151a>
ffffffffc0203a2e:	a19fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0203a32 <dup_mmap>:

int dup_mmap(struct mm_struct *to, struct mm_struct *from)
{
ffffffffc0203a32:	7139                	addi	sp,sp,-64
ffffffffc0203a34:	fc06                	sd	ra,56(sp)
ffffffffc0203a36:	f822                	sd	s0,48(sp)
ffffffffc0203a38:	f426                	sd	s1,40(sp)
ffffffffc0203a3a:	f04a                	sd	s2,32(sp)
ffffffffc0203a3c:	ec4e                	sd	s3,24(sp)
ffffffffc0203a3e:	e852                	sd	s4,16(sp)
ffffffffc0203a40:	e456                	sd	s5,8(sp)
    assert(to != NULL && from != NULL);
ffffffffc0203a42:	c525                	beqz	a0,ffffffffc0203aaa <dup_mmap+0x78>
ffffffffc0203a44:	892a                	mv	s2,a0
ffffffffc0203a46:	84ae                	mv	s1,a1
    list_entry_t *list = &(from->mmap_list), *le = list;
ffffffffc0203a48:	842e                	mv	s0,a1
    assert(to != NULL && from != NULL);
ffffffffc0203a4a:	c1a5                	beqz	a1,ffffffffc0203aaa <dup_mmap+0x78>
    return listelm->prev;
ffffffffc0203a4c:	6000                	ld	s0,0(s0)
    while ((le = list_prev(le)) != list)
ffffffffc0203a4e:	04848c63          	beq	s1,s0,ffffffffc0203aa6 <dup_mmap+0x74>
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a52:	03000513          	li	a0,48
    {
        struct vma_struct *vma, *nvma;
        vma = le2vma(le, list_link);
        nvma = vma_create(vma->vm_start, vma->vm_end, vma->vm_flags);
ffffffffc0203a56:	fe843a83          	ld	s5,-24(s0)
ffffffffc0203a5a:	ff043a03          	ld	s4,-16(s0)
ffffffffc0203a5e:	ff842983          	lw	s3,-8(s0)
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203a62:	b4efe0ef          	jal	ffffffffc0201db0 <kmalloc>
    if (vma != NULL)
ffffffffc0203a66:	c515                	beqz	a0,ffffffffc0203a92 <dup_mmap+0x60>
        if (nvma == NULL)
        {
            return -E_NO_MEM;
        }

        insert_vma_struct(to, nvma);
ffffffffc0203a68:	85aa                	mv	a1,a0
        vma->vm_start = vm_start;
ffffffffc0203a6a:	01553423          	sd	s5,8(a0)
ffffffffc0203a6e:	01453823          	sd	s4,16(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203a72:	01352c23          	sw	s3,24(a0)
        insert_vma_struct(to, nvma);
ffffffffc0203a76:	854a                	mv	a0,s2
ffffffffc0203a78:	dcfff0ef          	jal	ffffffffc0203846 <insert_vma_struct>

        bool share = 0;
        if (copy_range(to->pgdir, from->pgdir, vma->vm_start, vma->vm_end, share) != 0)
ffffffffc0203a7c:	ff043683          	ld	a3,-16(s0)
ffffffffc0203a80:	fe843603          	ld	a2,-24(s0)
ffffffffc0203a84:	6c8c                	ld	a1,24(s1)
ffffffffc0203a86:	01893503          	ld	a0,24(s2)
ffffffffc0203a8a:	4701                	li	a4,0
ffffffffc0203a8c:	a07ff0ef          	jal	ffffffffc0203492 <copy_range>
ffffffffc0203a90:	dd55                	beqz	a0,ffffffffc0203a4c <dup_mmap+0x1a>
            return -E_NO_MEM;
ffffffffc0203a92:	5571                	li	a0,-4
        {
            return -E_NO_MEM;
        }
    }
    return 0;
}
ffffffffc0203a94:	70e2                	ld	ra,56(sp)
ffffffffc0203a96:	7442                	ld	s0,48(sp)
ffffffffc0203a98:	74a2                	ld	s1,40(sp)
ffffffffc0203a9a:	7902                	ld	s2,32(sp)
ffffffffc0203a9c:	69e2                	ld	s3,24(sp)
ffffffffc0203a9e:	6a42                	ld	s4,16(sp)
ffffffffc0203aa0:	6aa2                	ld	s5,8(sp)
ffffffffc0203aa2:	6121                	addi	sp,sp,64
ffffffffc0203aa4:	8082                	ret
    return 0;
ffffffffc0203aa6:	4501                	li	a0,0
ffffffffc0203aa8:	b7f5                	j	ffffffffc0203a94 <dup_mmap+0x62>
    assert(to != NULL && from != NULL);
ffffffffc0203aaa:	00003697          	auipc	a3,0x3
ffffffffc0203aae:	48668693          	addi	a3,a3,1158 # ffffffffc0206f30 <etext+0x15b2>
ffffffffc0203ab2:	00003617          	auipc	a2,0x3
ffffffffc0203ab6:	8c660613          	addi	a2,a2,-1850 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203aba:	0cf00593          	li	a1,207
ffffffffc0203abe:	00003517          	auipc	a0,0x3
ffffffffc0203ac2:	3da50513          	addi	a0,a0,986 # ffffffffc0206e98 <etext+0x151a>
ffffffffc0203ac6:	981fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0203aca <exit_mmap>:

void exit_mmap(struct mm_struct *mm)
{
ffffffffc0203aca:	1101                	addi	sp,sp,-32
ffffffffc0203acc:	ec06                	sd	ra,24(sp)
ffffffffc0203ace:	e822                	sd	s0,16(sp)
ffffffffc0203ad0:	e426                	sd	s1,8(sp)
ffffffffc0203ad2:	e04a                	sd	s2,0(sp)
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203ad4:	c531                	beqz	a0,ffffffffc0203b20 <exit_mmap+0x56>
ffffffffc0203ad6:	591c                	lw	a5,48(a0)
ffffffffc0203ad8:	84aa                	mv	s1,a0
ffffffffc0203ada:	e3b9                	bnez	a5,ffffffffc0203b20 <exit_mmap+0x56>
    return listelm->next;
ffffffffc0203adc:	6500                	ld	s0,8(a0)
    pde_t *pgdir = mm->pgdir;
ffffffffc0203ade:	01853903          	ld	s2,24(a0)
    list_entry_t *list = &(mm->mmap_list), *le = list;
    while ((le = list_next(le)) != list)
ffffffffc0203ae2:	02850663          	beq	a0,s0,ffffffffc0203b0e <exit_mmap+0x44>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        unmap_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0203ae6:	ff043603          	ld	a2,-16(s0)
ffffffffc0203aea:	fe843583          	ld	a1,-24(s0)
ffffffffc0203aee:	854a                	mv	a0,s2
ffffffffc0203af0:	fdefe0ef          	jal	ffffffffc02022ce <unmap_range>
ffffffffc0203af4:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203af6:	fe8498e3          	bne	s1,s0,ffffffffc0203ae6 <exit_mmap+0x1c>
ffffffffc0203afa:	6400                	ld	s0,8(s0)
    }
    while ((le = list_next(le)) != list)
ffffffffc0203afc:	00848c63          	beq	s1,s0,ffffffffc0203b14 <exit_mmap+0x4a>
    {
        struct vma_struct *vma = le2vma(le, list_link);
        exit_range(pgdir, vma->vm_start, vma->vm_end);
ffffffffc0203b00:	ff043603          	ld	a2,-16(s0)
ffffffffc0203b04:	fe843583          	ld	a1,-24(s0)
ffffffffc0203b08:	854a                	mv	a0,s2
ffffffffc0203b0a:	8f9fe0ef          	jal	ffffffffc0202402 <exit_range>
ffffffffc0203b0e:	6400                	ld	s0,8(s0)
    while ((le = list_next(le)) != list)
ffffffffc0203b10:	fe8498e3          	bne	s1,s0,ffffffffc0203b00 <exit_mmap+0x36>
    }
}
ffffffffc0203b14:	60e2                	ld	ra,24(sp)
ffffffffc0203b16:	6442                	ld	s0,16(sp)
ffffffffc0203b18:	64a2                	ld	s1,8(sp)
ffffffffc0203b1a:	6902                	ld	s2,0(sp)
ffffffffc0203b1c:	6105                	addi	sp,sp,32
ffffffffc0203b1e:	8082                	ret
    assert(mm != NULL && mm_count(mm) == 0);
ffffffffc0203b20:	00003697          	auipc	a3,0x3
ffffffffc0203b24:	43068693          	addi	a3,a3,1072 # ffffffffc0206f50 <etext+0x15d2>
ffffffffc0203b28:	00003617          	auipc	a2,0x3
ffffffffc0203b2c:	85060613          	addi	a2,a2,-1968 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203b30:	0e800593          	li	a1,232
ffffffffc0203b34:	00003517          	auipc	a0,0x3
ffffffffc0203b38:	36450513          	addi	a0,a0,868 # ffffffffc0206e98 <etext+0x151a>
ffffffffc0203b3c:	90bfc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0203b40 <vmm_init>:
}

// vmm_init - initialize virtual memory management
//          - now just call check_vmm to check correctness of vmm
void vmm_init(void)
{
ffffffffc0203b40:	7179                	addi	sp,sp,-48
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203b42:	04000513          	li	a0,64
{
ffffffffc0203b46:	f406                	sd	ra,40(sp)
ffffffffc0203b48:	f022                	sd	s0,32(sp)
ffffffffc0203b4a:	ec26                	sd	s1,24(sp)
ffffffffc0203b4c:	e84a                	sd	s2,16(sp)
ffffffffc0203b4e:	e44e                	sd	s3,8(sp)
ffffffffc0203b50:	e052                	sd	s4,0(sp)
    struct mm_struct *mm = kmalloc(sizeof(struct mm_struct));
ffffffffc0203b52:	a5efe0ef          	jal	ffffffffc0201db0 <kmalloc>
    if (mm != NULL)
ffffffffc0203b56:	16050c63          	beqz	a0,ffffffffc0203cce <vmm_init+0x18e>
ffffffffc0203b5a:	842a                	mv	s0,a0
    elm->prev = elm->next = elm;
ffffffffc0203b5c:	e508                	sd	a0,8(a0)
ffffffffc0203b5e:	e108                	sd	a0,0(a0)
        mm->mmap_cache = NULL;
ffffffffc0203b60:	00053823          	sd	zero,16(a0)
        mm->pgdir = NULL;
ffffffffc0203b64:	00053c23          	sd	zero,24(a0)
        mm->map_count = 0;
ffffffffc0203b68:	02052023          	sw	zero,32(a0)
        mm->sm_priv = NULL;
ffffffffc0203b6c:	02053423          	sd	zero,40(a0)
ffffffffc0203b70:	02052823          	sw	zero,48(a0)
ffffffffc0203b74:	02053c23          	sd	zero,56(a0)
ffffffffc0203b78:	03200493          	li	s1,50
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203b7c:	03000513          	li	a0,48
ffffffffc0203b80:	a30fe0ef          	jal	ffffffffc0201db0 <kmalloc>
    if (vma != NULL)
ffffffffc0203b84:	12050563          	beqz	a0,ffffffffc0203cae <vmm_init+0x16e>
        vma->vm_end = vm_end;
ffffffffc0203b88:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc0203b8c:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203b8e:	00052c23          	sw	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc0203b92:	e91c                	sd	a5,16(a0)
    int i;
    for (i = step1; i >= 1; i--)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203b94:	85aa                	mv	a1,a0
    for (i = step1; i >= 1; i--)
ffffffffc0203b96:	14ed                	addi	s1,s1,-5
        insert_vma_struct(mm, vma);
ffffffffc0203b98:	8522                	mv	a0,s0
ffffffffc0203b9a:	cadff0ef          	jal	ffffffffc0203846 <insert_vma_struct>
    for (i = step1; i >= 1; i--)
ffffffffc0203b9e:	fcf9                	bnez	s1,ffffffffc0203b7c <vmm_init+0x3c>
ffffffffc0203ba0:	03700493          	li	s1,55
    }

    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203ba4:	1f900913          	li	s2,505
    struct vma_struct *vma = kmalloc(sizeof(struct vma_struct));
ffffffffc0203ba8:	03000513          	li	a0,48
ffffffffc0203bac:	a04fe0ef          	jal	ffffffffc0201db0 <kmalloc>
    if (vma != NULL)
ffffffffc0203bb0:	12050f63          	beqz	a0,ffffffffc0203cee <vmm_init+0x1ae>
        vma->vm_end = vm_end;
ffffffffc0203bb4:	00248793          	addi	a5,s1,2
        vma->vm_start = vm_start;
ffffffffc0203bb8:	e504                	sd	s1,8(a0)
        vma->vm_flags = vm_flags;
ffffffffc0203bba:	00052c23          	sw	zero,24(a0)
        vma->vm_end = vm_end;
ffffffffc0203bbe:	e91c                	sd	a5,16(a0)
    {
        struct vma_struct *vma = vma_create(i * 5, i * 5 + 2, 0);
        assert(vma != NULL);
        insert_vma_struct(mm, vma);
ffffffffc0203bc0:	85aa                	mv	a1,a0
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203bc2:	0495                	addi	s1,s1,5
        insert_vma_struct(mm, vma);
ffffffffc0203bc4:	8522                	mv	a0,s0
ffffffffc0203bc6:	c81ff0ef          	jal	ffffffffc0203846 <insert_vma_struct>
    for (i = step1 + 1; i <= step2; i++)
ffffffffc0203bca:	fd249fe3          	bne	s1,s2,ffffffffc0203ba8 <vmm_init+0x68>
    return listelm->next;
ffffffffc0203bce:	641c                	ld	a5,8(s0)
ffffffffc0203bd0:	471d                	li	a4,7
    }

    list_entry_t *le = list_next(&(mm->mmap_list));

    for (i = 1; i <= step2; i++)
ffffffffc0203bd2:	1fb00593          	li	a1,507
    {
        assert(le != &(mm->mmap_list));
ffffffffc0203bd6:	1ef40c63          	beq	s0,a5,ffffffffc0203dce <vmm_init+0x28e>
        struct vma_struct *mmap = le2vma(le, list_link);
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203bda:	fe87b603          	ld	a2,-24(a5) # 1fffe8 <_binary_obj___user_exit_out_size+0x1f5e28>
ffffffffc0203bde:	ffe70693          	addi	a3,a4,-2
ffffffffc0203be2:	12d61663          	bne	a2,a3,ffffffffc0203d0e <vmm_init+0x1ce>
ffffffffc0203be6:	ff07b683          	ld	a3,-16(a5)
ffffffffc0203bea:	12e69263          	bne	a3,a4,ffffffffc0203d0e <vmm_init+0x1ce>
    for (i = 1; i <= step2; i++)
ffffffffc0203bee:	0715                	addi	a4,a4,5
ffffffffc0203bf0:	679c                	ld	a5,8(a5)
ffffffffc0203bf2:	feb712e3          	bne	a4,a1,ffffffffc0203bd6 <vmm_init+0x96>
ffffffffc0203bf6:	491d                	li	s2,7
ffffffffc0203bf8:	4495                	li	s1,5
        le = list_next(le);
    }

    for (i = 5; i <= 5 * step2; i += 5)
    {
        struct vma_struct *vma1 = find_vma(mm, i);
ffffffffc0203bfa:	85a6                	mv	a1,s1
ffffffffc0203bfc:	8522                	mv	a0,s0
ffffffffc0203bfe:	c09ff0ef          	jal	ffffffffc0203806 <find_vma>
ffffffffc0203c02:	8a2a                	mv	s4,a0
        assert(vma1 != NULL);
ffffffffc0203c04:	20050563          	beqz	a0,ffffffffc0203e0e <vmm_init+0x2ce>
        struct vma_struct *vma2 = find_vma(mm, i + 1);
ffffffffc0203c08:	00148593          	addi	a1,s1,1
ffffffffc0203c0c:	8522                	mv	a0,s0
ffffffffc0203c0e:	bf9ff0ef          	jal	ffffffffc0203806 <find_vma>
ffffffffc0203c12:	89aa                	mv	s3,a0
        assert(vma2 != NULL);
ffffffffc0203c14:	1c050d63          	beqz	a0,ffffffffc0203dee <vmm_init+0x2ae>
        struct vma_struct *vma3 = find_vma(mm, i + 2);
ffffffffc0203c18:	85ca                	mv	a1,s2
ffffffffc0203c1a:	8522                	mv	a0,s0
ffffffffc0203c1c:	bebff0ef          	jal	ffffffffc0203806 <find_vma>
        assert(vma3 == NULL);
ffffffffc0203c20:	18051763          	bnez	a0,ffffffffc0203dae <vmm_init+0x26e>
        struct vma_struct *vma4 = find_vma(mm, i + 3);
ffffffffc0203c24:	00348593          	addi	a1,s1,3
ffffffffc0203c28:	8522                	mv	a0,s0
ffffffffc0203c2a:	bddff0ef          	jal	ffffffffc0203806 <find_vma>
        assert(vma4 == NULL);
ffffffffc0203c2e:	16051063          	bnez	a0,ffffffffc0203d8e <vmm_init+0x24e>
        struct vma_struct *vma5 = find_vma(mm, i + 4);
ffffffffc0203c32:	00448593          	addi	a1,s1,4
ffffffffc0203c36:	8522                	mv	a0,s0
ffffffffc0203c38:	bcfff0ef          	jal	ffffffffc0203806 <find_vma>
        assert(vma5 == NULL);
ffffffffc0203c3c:	12051963          	bnez	a0,ffffffffc0203d6e <vmm_init+0x22e>

        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203c40:	008a3783          	ld	a5,8(s4)
ffffffffc0203c44:	10979563          	bne	a5,s1,ffffffffc0203d4e <vmm_init+0x20e>
ffffffffc0203c48:	010a3783          	ld	a5,16(s4)
ffffffffc0203c4c:	11279163          	bne	a5,s2,ffffffffc0203d4e <vmm_init+0x20e>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203c50:	0089b783          	ld	a5,8(s3)
ffffffffc0203c54:	0c979d63          	bne	a5,s1,ffffffffc0203d2e <vmm_init+0x1ee>
ffffffffc0203c58:	0109b783          	ld	a5,16(s3)
ffffffffc0203c5c:	0d279963          	bne	a5,s2,ffffffffc0203d2e <vmm_init+0x1ee>
    for (i = 5; i <= 5 * step2; i += 5)
ffffffffc0203c60:	0495                	addi	s1,s1,5
ffffffffc0203c62:	1f900793          	li	a5,505
ffffffffc0203c66:	0915                	addi	s2,s2,5
ffffffffc0203c68:	f8f499e3          	bne	s1,a5,ffffffffc0203bfa <vmm_init+0xba>
ffffffffc0203c6c:	4491                	li	s1,4
    }

    for (i = 4; i >= 0; i--)
ffffffffc0203c6e:	597d                	li	s2,-1
    {
        struct vma_struct *vma_below_5 = find_vma(mm, i);
ffffffffc0203c70:	85a6                	mv	a1,s1
ffffffffc0203c72:	8522                	mv	a0,s0
ffffffffc0203c74:	b93ff0ef          	jal	ffffffffc0203806 <find_vma>
        if (vma_below_5 != NULL)
ffffffffc0203c78:	1a051b63          	bnez	a0,ffffffffc0203e2e <vmm_init+0x2ee>
    for (i = 4; i >= 0; i--)
ffffffffc0203c7c:	14fd                	addi	s1,s1,-1
ffffffffc0203c7e:	ff2499e3          	bne	s1,s2,ffffffffc0203c70 <vmm_init+0x130>
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
        }
        assert(vma_below_5 == NULL);
    }

    mm_destroy(mm);
ffffffffc0203c82:	8522                	mv	a0,s0
ffffffffc0203c84:	c91ff0ef          	jal	ffffffffc0203914 <mm_destroy>

    cprintf("check_vma_struct() succeeded!\n");
ffffffffc0203c88:	00003517          	auipc	a0,0x3
ffffffffc0203c8c:	43850513          	addi	a0,a0,1080 # ffffffffc02070c0 <etext+0x1742>
ffffffffc0203c90:	d04fc0ef          	jal	ffffffffc0200194 <cprintf>
}
ffffffffc0203c94:	7402                	ld	s0,32(sp)
ffffffffc0203c96:	70a2                	ld	ra,40(sp)
ffffffffc0203c98:	64e2                	ld	s1,24(sp)
ffffffffc0203c9a:	6942                	ld	s2,16(sp)
ffffffffc0203c9c:	69a2                	ld	s3,8(sp)
ffffffffc0203c9e:	6a02                	ld	s4,0(sp)
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203ca0:	00003517          	auipc	a0,0x3
ffffffffc0203ca4:	44050513          	addi	a0,a0,1088 # ffffffffc02070e0 <etext+0x1762>
}
ffffffffc0203ca8:	6145                	addi	sp,sp,48
    cprintf("check_vmm() succeeded.\n");
ffffffffc0203caa:	ceafc06f          	j	ffffffffc0200194 <cprintf>
        assert(vma != NULL);
ffffffffc0203cae:	00003697          	auipc	a3,0x3
ffffffffc0203cb2:	2c268693          	addi	a3,a3,706 # ffffffffc0206f70 <etext+0x15f2>
ffffffffc0203cb6:	00002617          	auipc	a2,0x2
ffffffffc0203cba:	6c260613          	addi	a2,a2,1730 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203cbe:	12c00593          	li	a1,300
ffffffffc0203cc2:	00003517          	auipc	a0,0x3
ffffffffc0203cc6:	1d650513          	addi	a0,a0,470 # ffffffffc0206e98 <etext+0x151a>
ffffffffc0203cca:	f7cfc0ef          	jal	ffffffffc0200446 <__panic>
    assert(mm != NULL);
ffffffffc0203cce:	00003697          	auipc	a3,0x3
ffffffffc0203cd2:	25268693          	addi	a3,a3,594 # ffffffffc0206f20 <etext+0x15a2>
ffffffffc0203cd6:	00002617          	auipc	a2,0x2
ffffffffc0203cda:	6a260613          	addi	a2,a2,1698 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203cde:	12400593          	li	a1,292
ffffffffc0203ce2:	00003517          	auipc	a0,0x3
ffffffffc0203ce6:	1b650513          	addi	a0,a0,438 # ffffffffc0206e98 <etext+0x151a>
ffffffffc0203cea:	f5cfc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma != NULL);
ffffffffc0203cee:	00003697          	auipc	a3,0x3
ffffffffc0203cf2:	28268693          	addi	a3,a3,642 # ffffffffc0206f70 <etext+0x15f2>
ffffffffc0203cf6:	00002617          	auipc	a2,0x2
ffffffffc0203cfa:	68260613          	addi	a2,a2,1666 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203cfe:	13300593          	li	a1,307
ffffffffc0203d02:	00003517          	auipc	a0,0x3
ffffffffc0203d06:	19650513          	addi	a0,a0,406 # ffffffffc0206e98 <etext+0x151a>
ffffffffc0203d0a:	f3cfc0ef          	jal	ffffffffc0200446 <__panic>
        assert(mmap->vm_start == i * 5 && mmap->vm_end == i * 5 + 2);
ffffffffc0203d0e:	00003697          	auipc	a3,0x3
ffffffffc0203d12:	28a68693          	addi	a3,a3,650 # ffffffffc0206f98 <etext+0x161a>
ffffffffc0203d16:	00002617          	auipc	a2,0x2
ffffffffc0203d1a:	66260613          	addi	a2,a2,1634 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203d1e:	13d00593          	li	a1,317
ffffffffc0203d22:	00003517          	auipc	a0,0x3
ffffffffc0203d26:	17650513          	addi	a0,a0,374 # ffffffffc0206e98 <etext+0x151a>
ffffffffc0203d2a:	f1cfc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma2->vm_start == i && vma2->vm_end == i + 2);
ffffffffc0203d2e:	00003697          	auipc	a3,0x3
ffffffffc0203d32:	32268693          	addi	a3,a3,802 # ffffffffc0207050 <etext+0x16d2>
ffffffffc0203d36:	00002617          	auipc	a2,0x2
ffffffffc0203d3a:	64260613          	addi	a2,a2,1602 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203d3e:	14f00593          	li	a1,335
ffffffffc0203d42:	00003517          	auipc	a0,0x3
ffffffffc0203d46:	15650513          	addi	a0,a0,342 # ffffffffc0206e98 <etext+0x151a>
ffffffffc0203d4a:	efcfc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma1->vm_start == i && vma1->vm_end == i + 2);
ffffffffc0203d4e:	00003697          	auipc	a3,0x3
ffffffffc0203d52:	2d268693          	addi	a3,a3,722 # ffffffffc0207020 <etext+0x16a2>
ffffffffc0203d56:	00002617          	auipc	a2,0x2
ffffffffc0203d5a:	62260613          	addi	a2,a2,1570 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203d5e:	14e00593          	li	a1,334
ffffffffc0203d62:	00003517          	auipc	a0,0x3
ffffffffc0203d66:	13650513          	addi	a0,a0,310 # ffffffffc0206e98 <etext+0x151a>
ffffffffc0203d6a:	edcfc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma5 == NULL);
ffffffffc0203d6e:	00003697          	auipc	a3,0x3
ffffffffc0203d72:	2a268693          	addi	a3,a3,674 # ffffffffc0207010 <etext+0x1692>
ffffffffc0203d76:	00002617          	auipc	a2,0x2
ffffffffc0203d7a:	60260613          	addi	a2,a2,1538 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203d7e:	14c00593          	li	a1,332
ffffffffc0203d82:	00003517          	auipc	a0,0x3
ffffffffc0203d86:	11650513          	addi	a0,a0,278 # ffffffffc0206e98 <etext+0x151a>
ffffffffc0203d8a:	ebcfc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma4 == NULL);
ffffffffc0203d8e:	00003697          	auipc	a3,0x3
ffffffffc0203d92:	27268693          	addi	a3,a3,626 # ffffffffc0207000 <etext+0x1682>
ffffffffc0203d96:	00002617          	auipc	a2,0x2
ffffffffc0203d9a:	5e260613          	addi	a2,a2,1506 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203d9e:	14a00593          	li	a1,330
ffffffffc0203da2:	00003517          	auipc	a0,0x3
ffffffffc0203da6:	0f650513          	addi	a0,a0,246 # ffffffffc0206e98 <etext+0x151a>
ffffffffc0203daa:	e9cfc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma3 == NULL);
ffffffffc0203dae:	00003697          	auipc	a3,0x3
ffffffffc0203db2:	24268693          	addi	a3,a3,578 # ffffffffc0206ff0 <etext+0x1672>
ffffffffc0203db6:	00002617          	auipc	a2,0x2
ffffffffc0203dba:	5c260613          	addi	a2,a2,1474 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203dbe:	14800593          	li	a1,328
ffffffffc0203dc2:	00003517          	auipc	a0,0x3
ffffffffc0203dc6:	0d650513          	addi	a0,a0,214 # ffffffffc0206e98 <etext+0x151a>
ffffffffc0203dca:	e7cfc0ef          	jal	ffffffffc0200446 <__panic>
        assert(le != &(mm->mmap_list));
ffffffffc0203dce:	00003697          	auipc	a3,0x3
ffffffffc0203dd2:	1b268693          	addi	a3,a3,434 # ffffffffc0206f80 <etext+0x1602>
ffffffffc0203dd6:	00002617          	auipc	a2,0x2
ffffffffc0203dda:	5a260613          	addi	a2,a2,1442 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203dde:	13b00593          	li	a1,315
ffffffffc0203de2:	00003517          	auipc	a0,0x3
ffffffffc0203de6:	0b650513          	addi	a0,a0,182 # ffffffffc0206e98 <etext+0x151a>
ffffffffc0203dea:	e5cfc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma2 != NULL);
ffffffffc0203dee:	00003697          	auipc	a3,0x3
ffffffffc0203df2:	1f268693          	addi	a3,a3,498 # ffffffffc0206fe0 <etext+0x1662>
ffffffffc0203df6:	00002617          	auipc	a2,0x2
ffffffffc0203dfa:	58260613          	addi	a2,a2,1410 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203dfe:	14600593          	li	a1,326
ffffffffc0203e02:	00003517          	auipc	a0,0x3
ffffffffc0203e06:	09650513          	addi	a0,a0,150 # ffffffffc0206e98 <etext+0x151a>
ffffffffc0203e0a:	e3cfc0ef          	jal	ffffffffc0200446 <__panic>
        assert(vma1 != NULL);
ffffffffc0203e0e:	00003697          	auipc	a3,0x3
ffffffffc0203e12:	1c268693          	addi	a3,a3,450 # ffffffffc0206fd0 <etext+0x1652>
ffffffffc0203e16:	00002617          	auipc	a2,0x2
ffffffffc0203e1a:	56260613          	addi	a2,a2,1378 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203e1e:	14400593          	li	a1,324
ffffffffc0203e22:	00003517          	auipc	a0,0x3
ffffffffc0203e26:	07650513          	addi	a0,a0,118 # ffffffffc0206e98 <etext+0x151a>
ffffffffc0203e2a:	e1cfc0ef          	jal	ffffffffc0200446 <__panic>
            cprintf("vma_below_5: i %x, start %x, end %x\n", i, vma_below_5->vm_start, vma_below_5->vm_end);
ffffffffc0203e2e:	6914                	ld	a3,16(a0)
ffffffffc0203e30:	6510                	ld	a2,8(a0)
ffffffffc0203e32:	0004859b          	sext.w	a1,s1
ffffffffc0203e36:	00003517          	auipc	a0,0x3
ffffffffc0203e3a:	24a50513          	addi	a0,a0,586 # ffffffffc0207080 <etext+0x1702>
ffffffffc0203e3e:	b56fc0ef          	jal	ffffffffc0200194 <cprintf>
        assert(vma_below_5 == NULL);
ffffffffc0203e42:	00003697          	auipc	a3,0x3
ffffffffc0203e46:	26668693          	addi	a3,a3,614 # ffffffffc02070a8 <etext+0x172a>
ffffffffc0203e4a:	00002617          	auipc	a2,0x2
ffffffffc0203e4e:	52e60613          	addi	a2,a2,1326 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0203e52:	15900593          	li	a1,345
ffffffffc0203e56:	00003517          	auipc	a0,0x3
ffffffffc0203e5a:	04250513          	addi	a0,a0,66 # ffffffffc0206e98 <etext+0x151a>
ffffffffc0203e5e:	de8fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0203e62 <user_mem_check>:
}
bool user_mem_check(struct mm_struct *mm, uintptr_t addr, size_t len, bool write)
{
ffffffffc0203e62:	7179                	addi	sp,sp,-48
ffffffffc0203e64:	f022                	sd	s0,32(sp)
ffffffffc0203e66:	f406                	sd	ra,40(sp)
ffffffffc0203e68:	842e                	mv	s0,a1
    if (mm != NULL)
ffffffffc0203e6a:	c52d                	beqz	a0,ffffffffc0203ed4 <user_mem_check+0x72>
    {
        if (!USER_ACCESS(addr, addr + len))
ffffffffc0203e6c:	002007b7          	lui	a5,0x200
ffffffffc0203e70:	04f5ed63          	bltu	a1,a5,ffffffffc0203eca <user_mem_check+0x68>
ffffffffc0203e74:	ec26                	sd	s1,24(sp)
ffffffffc0203e76:	00c584b3          	add	s1,a1,a2
ffffffffc0203e7a:	0695ff63          	bgeu	a1,s1,ffffffffc0203ef8 <user_mem_check+0x96>
ffffffffc0203e7e:	4785                	li	a5,1
ffffffffc0203e80:	07fe                	slli	a5,a5,0x1f
ffffffffc0203e82:	0785                	addi	a5,a5,1 # 200001 <_binary_obj___user_exit_out_size+0x1f5e41>
ffffffffc0203e84:	06f4fa63          	bgeu	s1,a5,ffffffffc0203ef8 <user_mem_check+0x96>
ffffffffc0203e88:	e84a                	sd	s2,16(sp)
ffffffffc0203e8a:	e44e                	sd	s3,8(sp)
ffffffffc0203e8c:	8936                	mv	s2,a3
ffffffffc0203e8e:	89aa                	mv	s3,a0
ffffffffc0203e90:	a829                	j	ffffffffc0203eaa <user_mem_check+0x48>
            {
                return 0;
            }
            if (write && (vma->vm_flags & VM_STACK))
            {
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203e92:	6685                	lui	a3,0x1
ffffffffc0203e94:	9736                	add	a4,a4,a3
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203e96:	0027f693          	andi	a3,a5,2
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203e9a:	8ba1                	andi	a5,a5,8
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203e9c:	c685                	beqz	a3,ffffffffc0203ec4 <user_mem_check+0x62>
            if (write && (vma->vm_flags & VM_STACK))
ffffffffc0203e9e:	c399                	beqz	a5,ffffffffc0203ea4 <user_mem_check+0x42>
                if (start < vma->vm_start + PGSIZE)
ffffffffc0203ea0:	02e46263          	bltu	s0,a4,ffffffffc0203ec4 <user_mem_check+0x62>
                { // check stack start & size
                    return 0;
                }
            }
            start = vma->vm_end;
ffffffffc0203ea4:	6900                	ld	s0,16(a0)
        while (start < end)
ffffffffc0203ea6:	04947b63          	bgeu	s0,s1,ffffffffc0203efc <user_mem_check+0x9a>
            if ((vma = find_vma(mm, start)) == NULL || start < vma->vm_start)
ffffffffc0203eaa:	85a2                	mv	a1,s0
ffffffffc0203eac:	854e                	mv	a0,s3
ffffffffc0203eae:	959ff0ef          	jal	ffffffffc0203806 <find_vma>
ffffffffc0203eb2:	c909                	beqz	a0,ffffffffc0203ec4 <user_mem_check+0x62>
ffffffffc0203eb4:	6518                	ld	a4,8(a0)
ffffffffc0203eb6:	00e46763          	bltu	s0,a4,ffffffffc0203ec4 <user_mem_check+0x62>
            if (!(vma->vm_flags & ((write) ? VM_WRITE : VM_READ)))
ffffffffc0203eba:	4d1c                	lw	a5,24(a0)
ffffffffc0203ebc:	fc091be3          	bnez	s2,ffffffffc0203e92 <user_mem_check+0x30>
ffffffffc0203ec0:	8b85                	andi	a5,a5,1
ffffffffc0203ec2:	f3ed                	bnez	a5,ffffffffc0203ea4 <user_mem_check+0x42>
ffffffffc0203ec4:	64e2                	ld	s1,24(sp)
ffffffffc0203ec6:	6942                	ld	s2,16(sp)
ffffffffc0203ec8:	69a2                	ld	s3,8(sp)
            return 0;
ffffffffc0203eca:	4501                	li	a0,0
        }
        return 1;
    }
    return KERN_ACCESS(addr, addr + len);
}
ffffffffc0203ecc:	70a2                	ld	ra,40(sp)
ffffffffc0203ece:	7402                	ld	s0,32(sp)
ffffffffc0203ed0:	6145                	addi	sp,sp,48
ffffffffc0203ed2:	8082                	ret
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203ed4:	c02007b7          	lui	a5,0xc0200
ffffffffc0203ed8:	fef5eae3          	bltu	a1,a5,ffffffffc0203ecc <user_mem_check+0x6a>
ffffffffc0203edc:	c80007b7          	lui	a5,0xc8000
ffffffffc0203ee0:	962e                	add	a2,a2,a1
ffffffffc0203ee2:	0785                	addi	a5,a5,1 # ffffffffc8000001 <end+0x7d64849>
ffffffffc0203ee4:	00c5b433          	sltu	s0,a1,a2
ffffffffc0203ee8:	00f63633          	sltu	a2,a2,a5
}
ffffffffc0203eec:	70a2                	ld	ra,40(sp)
    return KERN_ACCESS(addr, addr + len);
ffffffffc0203eee:	00867533          	and	a0,a2,s0
}
ffffffffc0203ef2:	7402                	ld	s0,32(sp)
ffffffffc0203ef4:	6145                	addi	sp,sp,48
ffffffffc0203ef6:	8082                	ret
ffffffffc0203ef8:	64e2                	ld	s1,24(sp)
ffffffffc0203efa:	bfc1                	j	ffffffffc0203eca <user_mem_check+0x68>
ffffffffc0203efc:	64e2                	ld	s1,24(sp)
ffffffffc0203efe:	6942                	ld	s2,16(sp)
ffffffffc0203f00:	69a2                	ld	s3,8(sp)
        return 1;
ffffffffc0203f02:	4505                	li	a0,1
ffffffffc0203f04:	b7e1                	j	ffffffffc0203ecc <user_mem_check+0x6a>

ffffffffc0203f06 <do_pgfault>:
 *         -- The W/R flag (bit 1) indicates whether the memory access that caused the exception
 *            was a read (0) or write (1).
 *         -- The U/S flag (bit 2) indicates whether the processor was executing at user mode (1)
 *            or supervisor mode (0) at the time of the exception.
 */
int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203f06:	1101                	addi	sp,sp,-32
ffffffffc0203f08:	85b2                	mv	a1,a2
ffffffffc0203f0a:	e822                	sd	s0,16(sp)
ffffffffc0203f0c:	ec06                	sd	ra,24(sp)
    int ret = -E_INVAL;
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203f0e:	e432                	sd	a2,8(sp)
int do_pgfault(struct mm_struct *mm, uint32_t error_code, uintptr_t addr) {
ffffffffc0203f10:	842a                	mv	s0,a0
    struct vma_struct *vma = find_vma(mm, addr);
ffffffffc0203f12:	8f5ff0ef          	jal	ffffffffc0203806 <find_vma>

    pgfault_num++;
ffffffffc0203f16:	00098797          	auipc	a5,0x98
ffffffffc0203f1a:	8827a783          	lw	a5,-1918(a5) # ffffffffc029b798 <pgfault_num>
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203f1e:	65a2                	ld	a1,8(sp)
    pgfault_num++;
ffffffffc0203f20:	2785                	addiw	a5,a5,1
ffffffffc0203f22:	00098717          	auipc	a4,0x98
ffffffffc0203f26:	86f72b23          	sw	a5,-1930(a4) # ffffffffc029b798 <pgfault_num>
    if (vma == NULL || vma->vm_start > addr) {
ffffffffc0203f2a:	c921                	beqz	a0,ffffffffc0203f7a <do_pgfault+0x74>
ffffffffc0203f2c:	651c                	ld	a5,8(a0)
ffffffffc0203f2e:	04f5e663          	bltu	a1,a5,ffffffffc0203f7a <do_pgfault+0x74>
    
    // If we are here, it means the address is within a valid VMA.
    // We should check permissions and allocate a page.
    
    uint32_t perm = PTE_U;
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203f32:	4d1c                	lw	a5,24(a0)
        perm |= (PTE_R | PTE_W);
ffffffffc0203f34:	4759                	li	a4,22
    if (vma->vm_flags & VM_WRITE) {
ffffffffc0203f36:	0027f693          	andi	a3,a5,2
ffffffffc0203f3a:	c69d                	beqz	a3,ffffffffc0203f68 <do_pgfault+0x62>
    }
    if (vma->vm_flags & VM_READ) {
ffffffffc0203f3c:	0017f613          	andi	a2,a5,1
ffffffffc0203f40:	0016161b          	slliw	a2,a2,0x1
        perm |= PTE_R;
    }
    if (vma->vm_flags & VM_EXEC) {
ffffffffc0203f44:	8b91                	andi	a5,a5,4
    if (vma->vm_flags & VM_READ) {
ffffffffc0203f46:	8e59                	or	a2,a2,a4
    if (vma->vm_flags & VM_EXEC) {
ffffffffc0203f48:	ef89                	bnez	a5,ffffffffc0203f62 <do_pgfault+0x5c>
    pte_t *ptep = NULL;
    
    // Since we don't have get_pte easily available without looking up headers,
    // and we want to be safe, let's just use pgdir_alloc_page which does everything.
    
    if ((page = pgdir_alloc_page(mm->pgdir, addr, perm)) == NULL) {
ffffffffc0203f4a:	6c08                	ld	a0,24(s0)
    addr = ROUNDDOWN(addr, PGSIZE);
ffffffffc0203f4c:	77fd                	lui	a5,0xfffff
    if ((page = pgdir_alloc_page(mm->pgdir, addr, perm)) == NULL) {
ffffffffc0203f4e:	8dfd                	and	a1,a1,a5
ffffffffc0203f50:	fa4ff0ef          	jal	ffffffffc02036f4 <pgdir_alloc_page>
ffffffffc0203f54:	87aa                	mv	a5,a0
        cprintf("pgdir_alloc_page failed\n");
        goto failed;
    }
    
    ret = 0;
ffffffffc0203f56:	4501                	li	a0,0
    if ((page = pgdir_alloc_page(mm->pgdir, addr, perm)) == NULL) {
ffffffffc0203f58:	cb8d                	beqz	a5,ffffffffc0203f8a <do_pgfault+0x84>

failed:
    return ret;
ffffffffc0203f5a:	60e2                	ld	ra,24(sp)
ffffffffc0203f5c:	6442                	ld	s0,16(sp)
ffffffffc0203f5e:	6105                	addi	sp,sp,32
ffffffffc0203f60:	8082                	ret
        perm |= PTE_X;
ffffffffc0203f62:	00866613          	ori	a2,a2,8
ffffffffc0203f66:	b7d5                	j	ffffffffc0203f4a <do_pgfault+0x44>
    if (vma->vm_flags & VM_READ) {
ffffffffc0203f68:	0017f613          	andi	a2,a5,1
    uint32_t perm = PTE_U;
ffffffffc0203f6c:	4741                	li	a4,16
    if (vma->vm_flags & VM_READ) {
ffffffffc0203f6e:	0016161b          	slliw	a2,a2,0x1
    if (vma->vm_flags & VM_EXEC) {
ffffffffc0203f72:	8b91                	andi	a5,a5,4
    if (vma->vm_flags & VM_READ) {
ffffffffc0203f74:	8e59                	or	a2,a2,a4
    if (vma->vm_flags & VM_EXEC) {
ffffffffc0203f76:	dbf1                	beqz	a5,ffffffffc0203f4a <do_pgfault+0x44>
ffffffffc0203f78:	b7ed                	j	ffffffffc0203f62 <do_pgfault+0x5c>
        cprintf("not valid addr %x, and  can not find it in vma\n", addr);
ffffffffc0203f7a:	00003517          	auipc	a0,0x3
ffffffffc0203f7e:	17e50513          	addi	a0,a0,382 # ffffffffc02070f8 <etext+0x177a>
ffffffffc0203f82:	a12fc0ef          	jal	ffffffffc0200194 <cprintf>
    int ret = -E_INVAL;
ffffffffc0203f86:	5575                	li	a0,-3
        goto failed;
ffffffffc0203f88:	bfc9                	j	ffffffffc0203f5a <do_pgfault+0x54>
        cprintf("pgdir_alloc_page failed\n");
ffffffffc0203f8a:	00003517          	auipc	a0,0x3
ffffffffc0203f8e:	19e50513          	addi	a0,a0,414 # ffffffffc0207128 <etext+0x17aa>
ffffffffc0203f92:	a02fc0ef          	jal	ffffffffc0200194 <cprintf>
    ret = -E_NO_MEM;
ffffffffc0203f96:	5571                	li	a0,-4
        goto failed;
ffffffffc0203f98:	b7c9                	j	ffffffffc0203f5a <do_pgfault+0x54>

ffffffffc0203f9a <kernel_thread_entry>:
.text
.globl kernel_thread_entry
kernel_thread_entry:        # void kernel_thread(void)
	move a0, s1
ffffffffc0203f9a:	8526                	mv	a0,s1
	jalr s0
ffffffffc0203f9c:	9402                	jalr	s0

	jal do_exit
ffffffffc0203f9e:	672000ef          	jal	ffffffffc0204610 <do_exit>

ffffffffc0203fa2 <alloc_proc>:
void switch_to(struct context *from, struct context *to);

// alloc_proc - alloc a proc_struct and init all fields of proc_struct
static struct proc_struct *
alloc_proc(void)
{
ffffffffc0203fa2:	1141                	addi	sp,sp,-16
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203fa4:	10800513          	li	a0,264
{
ffffffffc0203fa8:	e022                	sd	s0,0(sp)
ffffffffc0203faa:	e406                	sd	ra,8(sp)
    struct proc_struct *proc = kmalloc(sizeof(struct proc_struct));
ffffffffc0203fac:	e05fd0ef          	jal	ffffffffc0201db0 <kmalloc>
ffffffffc0203fb0:	842a                	mv	s0,a0
    if (proc != NULL)
ffffffffc0203fb2:	cd21                	beqz	a0,ffffffffc020400a <alloc_proc+0x68>
         *       struct trapframe *tf;                       // Trap frame for current interrupt
         *       uintptr_t pgdir;                            // the base addr of Page Directroy Table(PDT)
         *       uint32_t flags;                             // Process flag
         *       char name[PROC_NAME_LEN + 1];               // Process name
         */
        proc->state = PROC_UNINIT;
ffffffffc0203fb4:	57fd                	li	a5,-1
ffffffffc0203fb6:	1782                	slli	a5,a5,0x20
ffffffffc0203fb8:	e11c                	sd	a5,0(a0)
        proc->pid = -1;
        proc->runs = 0;
ffffffffc0203fba:	00052423          	sw	zero,8(a0)
        proc->kstack = 0;
ffffffffc0203fbe:	00053823          	sd	zero,16(a0)
        proc->need_resched = 0;
ffffffffc0203fc2:	00053c23          	sd	zero,24(a0)
        proc->parent = NULL;
ffffffffc0203fc6:	02053023          	sd	zero,32(a0)
        proc->mm = NULL;
ffffffffc0203fca:	02053423          	sd	zero,40(a0)
        memset(&(proc->context), 0, sizeof(struct context));
ffffffffc0203fce:	07000613          	li	a2,112
ffffffffc0203fd2:	4581                	li	a1,0
ffffffffc0203fd4:	03050513          	addi	a0,a0,48
ffffffffc0203fd8:	17d010ef          	jal	ffffffffc0205954 <memset>
        proc->tf = NULL;
        proc->pgdir = boot_pgdir_pa;
ffffffffc0203fdc:	00097797          	auipc	a5,0x97
ffffffffc0203fe0:	7947b783          	ld	a5,1940(a5) # ffffffffc029b770 <boot_pgdir_pa>
        proc->tf = NULL;
ffffffffc0203fe4:	0a043023          	sd	zero,160(s0)
        proc->flags = 0;
ffffffffc0203fe8:	0a042823          	sw	zero,176(s0)
        proc->pgdir = boot_pgdir_pa;
ffffffffc0203fec:	f45c                	sd	a5,168(s0)
        memset(proc->name, 0, sizeof(proc->name));
ffffffffc0203fee:	0b440513          	addi	a0,s0,180
ffffffffc0203ff2:	4641                	li	a2,16
ffffffffc0203ff4:	4581                	li	a1,0
ffffffffc0203ff6:	15f010ef          	jal	ffffffffc0205954 <memset>
        /*
         * below fields(add in LAB5) in proc_struct need to be initialized
         *       uint32_t wait_state;                        // waiting state
         *       struct proc_struct *cptr, *yptr, *optr;     // relations between processes
         */
        proc->wait_state = 0;
ffffffffc0203ffa:	0e042623          	sw	zero,236(s0)
        proc->cptr = proc->optr = proc->yptr = NULL;
ffffffffc0203ffe:	0e043c23          	sd	zero,248(s0)
ffffffffc0204002:	10043023          	sd	zero,256(s0)
ffffffffc0204006:	0e043823          	sd	zero,240(s0)
    }
    return proc;
}
ffffffffc020400a:	60a2                	ld	ra,8(sp)
ffffffffc020400c:	8522                	mv	a0,s0
ffffffffc020400e:	6402                	ld	s0,0(sp)
ffffffffc0204010:	0141                	addi	sp,sp,16
ffffffffc0204012:	8082                	ret

ffffffffc0204014 <forkret>:
// NOTE: the addr of forkret is setted in copy_thread function
//       after switch_to, the current proc will execute here.
static void
forkret(void)
{
    forkrets(current->tf);
ffffffffc0204014:	00097797          	auipc	a5,0x97
ffffffffc0204018:	78c7b783          	ld	a5,1932(a5) # ffffffffc029b7a0 <current>
ffffffffc020401c:	73c8                	ld	a0,160(a5)
ffffffffc020401e:	f79fc06f          	j	ffffffffc0200f96 <forkrets>

ffffffffc0204022 <user_main>:
// user_main - kernel thread used to exec a user program
static int
user_main(void *arg)
{
#ifdef TEST
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204022:	00097797          	auipc	a5,0x97
ffffffffc0204026:	77e7b783          	ld	a5,1918(a5) # ffffffffc029b7a0 <current>
{
ffffffffc020402a:	7139                	addi	sp,sp,-64
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc020402c:	00003617          	auipc	a2,0x3
ffffffffc0204030:	11c60613          	addi	a2,a2,284 # ffffffffc0207148 <etext+0x17ca>
ffffffffc0204034:	43cc                	lw	a1,4(a5)
ffffffffc0204036:	00003517          	auipc	a0,0x3
ffffffffc020403a:	12250513          	addi	a0,a0,290 # ffffffffc0207158 <etext+0x17da>
{
ffffffffc020403e:	fc06                	sd	ra,56(sp)
    KERNEL_EXECVE2(TEST, TESTSTART, TESTSIZE);
ffffffffc0204040:	954fc0ef          	jal	ffffffffc0200194 <cprintf>
ffffffffc0204044:	3fe06797          	auipc	a5,0x3fe06
ffffffffc0204048:	8ac78793          	addi	a5,a5,-1876 # 98f0 <_binary_obj___user_forktest_out_size>
ffffffffc020404c:	e43e                	sd	a5,8(sp)
kernel_execve(const char *name, unsigned char *binary, size_t size)
ffffffffc020404e:	00003517          	auipc	a0,0x3
ffffffffc0204052:	0fa50513          	addi	a0,a0,250 # ffffffffc0207148 <etext+0x17ca>
ffffffffc0204056:	0003f797          	auipc	a5,0x3f
ffffffffc020405a:	63278793          	addi	a5,a5,1586 # ffffffffc0243688 <_binary_obj___user_forktest_out_start>
ffffffffc020405e:	f03e                	sd	a5,32(sp)
ffffffffc0204060:	f42a                	sd	a0,40(sp)
    int64_t ret = 0, len = strlen(name);
ffffffffc0204062:	e802                	sd	zero,16(sp)
ffffffffc0204064:	03d010ef          	jal	ffffffffc02058a0 <strlen>
ffffffffc0204068:	ec2a                	sd	a0,24(sp)
    asm volatile(
ffffffffc020406a:	4511                	li	a0,4
ffffffffc020406c:	55a2                	lw	a1,40(sp)
ffffffffc020406e:	4662                	lw	a2,24(sp)
ffffffffc0204070:	5682                	lw	a3,32(sp)
ffffffffc0204072:	4722                	lw	a4,8(sp)
ffffffffc0204074:	48a9                	li	a7,10
ffffffffc0204076:	9002                	ebreak
ffffffffc0204078:	c82a                	sw	a0,16(sp)
    cprintf("ret = %d\n", ret);
ffffffffc020407a:	65c2                	ld	a1,16(sp)
ffffffffc020407c:	00003517          	auipc	a0,0x3
ffffffffc0204080:	10450513          	addi	a0,a0,260 # ffffffffc0207180 <etext+0x1802>
ffffffffc0204084:	910fc0ef          	jal	ffffffffc0200194 <cprintf>
#else
    KERNEL_EXECVE(exit);
#endif
    panic("user_main execve failed.\n");
ffffffffc0204088:	00003617          	auipc	a2,0x3
ffffffffc020408c:	10860613          	addi	a2,a2,264 # ffffffffc0207190 <etext+0x1812>
ffffffffc0204090:	3af00593          	li	a1,943
ffffffffc0204094:	00003517          	auipc	a0,0x3
ffffffffc0204098:	11c50513          	addi	a0,a0,284 # ffffffffc02071b0 <etext+0x1832>
ffffffffc020409c:	baafc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02040a0 <put_pgdir>:
    return pa2page(PADDR(kva));
ffffffffc02040a0:	6d14                	ld	a3,24(a0)
{
ffffffffc02040a2:	1141                	addi	sp,sp,-16
ffffffffc02040a4:	e406                	sd	ra,8(sp)
ffffffffc02040a6:	c02007b7          	lui	a5,0xc0200
ffffffffc02040aa:	02f6ee63          	bltu	a3,a5,ffffffffc02040e6 <put_pgdir+0x46>
ffffffffc02040ae:	00097717          	auipc	a4,0x97
ffffffffc02040b2:	6d273703          	ld	a4,1746(a4) # ffffffffc029b780 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc02040b6:	00097797          	auipc	a5,0x97
ffffffffc02040ba:	6d27b783          	ld	a5,1746(a5) # ffffffffc029b788 <npage>
    return pa2page(PADDR(kva));
ffffffffc02040be:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc02040c0:	82b1                	srli	a3,a3,0xc
ffffffffc02040c2:	02f6fe63          	bgeu	a3,a5,ffffffffc02040fe <put_pgdir+0x5e>
    return &pages[PPN(pa) - nbase];
ffffffffc02040c6:	00004797          	auipc	a5,0x4
ffffffffc02040ca:	a927b783          	ld	a5,-1390(a5) # ffffffffc0207b58 <nbase>
ffffffffc02040ce:	00097517          	auipc	a0,0x97
ffffffffc02040d2:	6c253503          	ld	a0,1730(a0) # ffffffffc029b790 <pages>
}
ffffffffc02040d6:	60a2                	ld	ra,8(sp)
ffffffffc02040d8:	8e9d                	sub	a3,a3,a5
ffffffffc02040da:	069a                	slli	a3,a3,0x6
    free_page(kva2page(mm->pgdir));
ffffffffc02040dc:	4585                	li	a1,1
ffffffffc02040de:	9536                	add	a0,a0,a3
}
ffffffffc02040e0:	0141                	addi	sp,sp,16
    free_page(kva2page(mm->pgdir));
ffffffffc02040e2:	ecdfd06f          	j	ffffffffc0201fae <free_pages>
    return pa2page(PADDR(kva));
ffffffffc02040e6:	00002617          	auipc	a2,0x2
ffffffffc02040ea:	6ea60613          	addi	a2,a2,1770 # ffffffffc02067d0 <etext+0xe52>
ffffffffc02040ee:	07700593          	li	a1,119
ffffffffc02040f2:	00002517          	auipc	a0,0x2
ffffffffc02040f6:	65e50513          	addi	a0,a0,1630 # ffffffffc0206750 <etext+0xdd2>
ffffffffc02040fa:	b4cfc0ef          	jal	ffffffffc0200446 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc02040fe:	00002617          	auipc	a2,0x2
ffffffffc0204102:	6fa60613          	addi	a2,a2,1786 # ffffffffc02067f8 <etext+0xe7a>
ffffffffc0204106:	06900593          	li	a1,105
ffffffffc020410a:	00002517          	auipc	a0,0x2
ffffffffc020410e:	64650513          	addi	a0,a0,1606 # ffffffffc0206750 <etext+0xdd2>
ffffffffc0204112:	b34fc0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0204116 <proc_run>:
    if (proc != current)
ffffffffc0204116:	00097697          	auipc	a3,0x97
ffffffffc020411a:	68a6b683          	ld	a3,1674(a3) # ffffffffc029b7a0 <current>
ffffffffc020411e:	04a68563          	beq	a3,a0,ffffffffc0204168 <proc_run+0x52>
{
ffffffffc0204122:	1101                	addi	sp,sp,-32
ffffffffc0204124:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204126:	100027f3          	csrr	a5,sstatus
ffffffffc020412a:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc020412c:	4601                	li	a2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020412e:	ef95                	bnez	a5,ffffffffc020416a <proc_run+0x54>
#define barrier() __asm__ __volatile__("fence" ::: "memory")

static inline void
lsatp(unsigned long pgdir)
{
  write_csr(satp, 0x8000000000000000 | (pgdir >> RISCV_PGSHIFT));
ffffffffc0204130:	755c                	ld	a5,168(a0)
ffffffffc0204132:	577d                	li	a4,-1
ffffffffc0204134:	177e                	slli	a4,a4,0x3f
ffffffffc0204136:	00c7d79b          	srliw	a5,a5,0xc
ffffffffc020413a:	e032                	sd	a2,0(sp)
            current = proc;
ffffffffc020413c:	00097597          	auipc	a1,0x97
ffffffffc0204140:	66a5b223          	sd	a0,1636(a1) # ffffffffc029b7a0 <current>
ffffffffc0204144:	8fd9                	or	a5,a5,a4
ffffffffc0204146:	18079073          	csrw	satp,a5
            switch_to(&(prev->context), &(next->context));
ffffffffc020414a:	03050593          	addi	a1,a0,48
ffffffffc020414e:	03068513          	addi	a0,a3,48
ffffffffc0204152:	106010ef          	jal	ffffffffc0205258 <switch_to>
    if (flag)
ffffffffc0204156:	6602                	ld	a2,0(sp)
ffffffffc0204158:	e601                	bnez	a2,ffffffffc0204160 <proc_run+0x4a>
}
ffffffffc020415a:	60e2                	ld	ra,24(sp)
ffffffffc020415c:	6105                	addi	sp,sp,32
ffffffffc020415e:	8082                	ret
ffffffffc0204160:	60e2                	ld	ra,24(sp)
ffffffffc0204162:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0204164:	f9afc06f          	j	ffffffffc02008fe <intr_enable>
ffffffffc0204168:	8082                	ret
ffffffffc020416a:	e42a                	sd	a0,8(sp)
ffffffffc020416c:	e036                	sd	a3,0(sp)
        intr_disable();
ffffffffc020416e:	f96fc0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc0204172:	6522                	ld	a0,8(sp)
ffffffffc0204174:	6682                	ld	a3,0(sp)
ffffffffc0204176:	4605                	li	a2,1
ffffffffc0204178:	bf65                	j	ffffffffc0204130 <proc_run+0x1a>

ffffffffc020417a <do_fork>:
    if (nr_process >= MAX_PROCESS)
ffffffffc020417a:	00097717          	auipc	a4,0x97
ffffffffc020417e:	62272703          	lw	a4,1570(a4) # ffffffffc029b79c <nr_process>
ffffffffc0204182:	6785                	lui	a5,0x1
ffffffffc0204184:	36f75d63          	bge	a4,a5,ffffffffc02044fe <do_fork+0x384>
{
ffffffffc0204188:	711d                	addi	sp,sp,-96
ffffffffc020418a:	e8a2                	sd	s0,80(sp)
ffffffffc020418c:	e4a6                	sd	s1,72(sp)
ffffffffc020418e:	e0ca                	sd	s2,64(sp)
ffffffffc0204190:	e06a                	sd	s10,0(sp)
ffffffffc0204192:	ec86                	sd	ra,88(sp)
ffffffffc0204194:	892e                	mv	s2,a1
ffffffffc0204196:	84b2                	mv	s1,a2
ffffffffc0204198:	8d2a                	mv	s10,a0
    if ((proc = alloc_proc()) == NULL) {
ffffffffc020419a:	e09ff0ef          	jal	ffffffffc0203fa2 <alloc_proc>
ffffffffc020419e:	842a                	mv	s0,a0
ffffffffc02041a0:	30050063          	beqz	a0,ffffffffc02044a0 <do_fork+0x326>
    proc->parent = current;
ffffffffc02041a4:	f05a                	sd	s6,32(sp)
ffffffffc02041a6:	00097b17          	auipc	s6,0x97
ffffffffc02041aa:	5fab0b13          	addi	s6,s6,1530 # ffffffffc029b7a0 <current>
ffffffffc02041ae:	000b3783          	ld	a5,0(s6)
    assert(current->wait_state == 0);
ffffffffc02041b2:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_obj___user_softint_out_size-0x7ae4>
    proc->parent = current;
ffffffffc02041b6:	f11c                	sd	a5,32(a0)
    assert(current->wait_state == 0);
ffffffffc02041b8:	3c071263          	bnez	a4,ffffffffc020457c <do_fork+0x402>
    struct Page *page = alloc_pages(KSTACKPAGE);
ffffffffc02041bc:	4509                	li	a0,2
ffffffffc02041be:	db7fd0ef          	jal	ffffffffc0201f74 <alloc_pages>
    if (page != NULL)
ffffffffc02041c2:	2c050b63          	beqz	a0,ffffffffc0204498 <do_fork+0x31e>
ffffffffc02041c6:	fc4e                	sd	s3,56(sp)
    return page - pages + nbase;
ffffffffc02041c8:	00097997          	auipc	s3,0x97
ffffffffc02041cc:	5c898993          	addi	s3,s3,1480 # ffffffffc029b790 <pages>
ffffffffc02041d0:	0009b783          	ld	a5,0(s3)
ffffffffc02041d4:	f852                	sd	s4,48(sp)
ffffffffc02041d6:	00004a17          	auipc	s4,0x4
ffffffffc02041da:	982a0a13          	addi	s4,s4,-1662 # ffffffffc0207b58 <nbase>
ffffffffc02041de:	e466                	sd	s9,8(sp)
ffffffffc02041e0:	000a3c83          	ld	s9,0(s4)
ffffffffc02041e4:	40f506b3          	sub	a3,a0,a5
ffffffffc02041e8:	f456                	sd	s5,40(sp)
    return KADDR(page2pa(page));
ffffffffc02041ea:	00097a97          	auipc	s5,0x97
ffffffffc02041ee:	59ea8a93          	addi	s5,s5,1438 # ffffffffc029b788 <npage>
ffffffffc02041f2:	e862                	sd	s8,16(sp)
    return page - pages + nbase;
ffffffffc02041f4:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc02041f6:	5c7d                	li	s8,-1
ffffffffc02041f8:	000ab783          	ld	a5,0(s5)
    return page - pages + nbase;
ffffffffc02041fc:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc02041fe:	00cc5c13          	srli	s8,s8,0xc
ffffffffc0204202:	0186f733          	and	a4,a3,s8
ffffffffc0204206:	ec5e                	sd	s7,24(sp)
    return page2ppn(page) << PGSHIFT;
ffffffffc0204208:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc020420a:	30f77863          	bgeu	a4,a5,ffffffffc020451a <do_fork+0x3a0>
    struct mm_struct *mm, *oldmm = current->mm;
ffffffffc020420e:	000b3703          	ld	a4,0(s6)
ffffffffc0204212:	00097b17          	auipc	s6,0x97
ffffffffc0204216:	56eb0b13          	addi	s6,s6,1390 # ffffffffc029b780 <va_pa_offset>
ffffffffc020421a:	000b3783          	ld	a5,0(s6)
ffffffffc020421e:	02873b83          	ld	s7,40(a4)
ffffffffc0204222:	96be                	add	a3,a3,a5
        proc->kstack = (uintptr_t)page2kva(page);
ffffffffc0204224:	e814                	sd	a3,16(s0)
    if (oldmm == NULL)
ffffffffc0204226:	020b8863          	beqz	s7,ffffffffc0204256 <do_fork+0xdc>
    if (clone_flags & CLONE_VM)
ffffffffc020422a:	100d7793          	andi	a5,s10,256
ffffffffc020422e:	18078b63          	beqz	a5,ffffffffc02043c4 <do_fork+0x24a>
}

static inline int
mm_count_inc(struct mm_struct *mm)
{
    mm->mm_count += 1;
ffffffffc0204232:	030ba703          	lw	a4,48(s7)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204236:	018bb783          	ld	a5,24(s7)
ffffffffc020423a:	c02006b7          	lui	a3,0xc0200
ffffffffc020423e:	2705                	addiw	a4,a4,1
ffffffffc0204240:	02eba823          	sw	a4,48(s7)
    proc->mm = mm;
ffffffffc0204244:	03743423          	sd	s7,40(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204248:	2ed7e563          	bltu	a5,a3,ffffffffc0204532 <do_fork+0x3b8>
ffffffffc020424c:	000b3703          	ld	a4,0(s6)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204250:	6814                	ld	a3,16(s0)
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204252:	8f99                	sub	a5,a5,a4
ffffffffc0204254:	f45c                	sd	a5,168(s0)
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204256:	6789                	lui	a5,0x2
ffffffffc0204258:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_obj___user_softint_out_size-0x6cf0>
ffffffffc020425c:	96be                	add	a3,a3,a5
    *(proc->tf) = *tf;
ffffffffc020425e:	8626                	mv	a2,s1
    proc->tf = (struct trapframe *)(proc->kstack + KSTACKSIZE) - 1;
ffffffffc0204260:	f054                	sd	a3,160(s0)
    *(proc->tf) = *tf;
ffffffffc0204262:	87b6                	mv	a5,a3
ffffffffc0204264:	12048713          	addi	a4,s1,288
ffffffffc0204268:	6a0c                	ld	a1,16(a2)
ffffffffc020426a:	00063803          	ld	a6,0(a2)
ffffffffc020426e:	6608                	ld	a0,8(a2)
ffffffffc0204270:	eb8c                	sd	a1,16(a5)
ffffffffc0204272:	0107b023          	sd	a6,0(a5)
ffffffffc0204276:	e788                	sd	a0,8(a5)
ffffffffc0204278:	6e0c                	ld	a1,24(a2)
ffffffffc020427a:	02060613          	addi	a2,a2,32
ffffffffc020427e:	02078793          	addi	a5,a5,32
ffffffffc0204282:	feb7bc23          	sd	a1,-8(a5)
ffffffffc0204286:	fee611e3          	bne	a2,a4,ffffffffc0204268 <do_fork+0xee>
    proc->tf->gpr.a0 = 0;
ffffffffc020428a:	0406b823          	sd	zero,80(a3) # ffffffffc0200050 <kern_init+0x6>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc020428e:	20090b63          	beqz	s2,ffffffffc02044a4 <do_fork+0x32a>
ffffffffc0204292:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc0204296:	00000797          	auipc	a5,0x0
ffffffffc020429a:	d7e78793          	addi	a5,a5,-642 # ffffffffc0204014 <forkret>
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc020429e:	fc14                	sd	a3,56(s0)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02042a0:	f81c                	sd	a5,48(s0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02042a2:	100027f3          	csrr	a5,sstatus
ffffffffc02042a6:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02042a8:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02042aa:	20079c63          	bnez	a5,ffffffffc02044c2 <do_fork+0x348>
    if (++last_pid >= MAX_PID)
ffffffffc02042ae:	00093517          	auipc	a0,0x93
ffffffffc02042b2:	05e52503          	lw	a0,94(a0) # ffffffffc029730c <last_pid.1>
ffffffffc02042b6:	6789                	lui	a5,0x2
ffffffffc02042b8:	2505                	addiw	a0,a0,1
ffffffffc02042ba:	00093717          	auipc	a4,0x93
ffffffffc02042be:	04a72923          	sw	a0,82(a4) # ffffffffc029730c <last_pid.1>
ffffffffc02042c2:	20f55f63          	bge	a0,a5,ffffffffc02044e0 <do_fork+0x366>
    if (last_pid >= next_safe)
ffffffffc02042c6:	00093797          	auipc	a5,0x93
ffffffffc02042ca:	0427a783          	lw	a5,66(a5) # ffffffffc0297308 <next_safe.0>
ffffffffc02042ce:	00097497          	auipc	s1,0x97
ffffffffc02042d2:	45a48493          	addi	s1,s1,1114 # ffffffffc029b728 <proc_list>
ffffffffc02042d6:	06f54563          	blt	a0,a5,ffffffffc0204340 <do_fork+0x1c6>
ffffffffc02042da:	00097497          	auipc	s1,0x97
ffffffffc02042de:	44e48493          	addi	s1,s1,1102 # ffffffffc029b728 <proc_list>
ffffffffc02042e2:	0084b883          	ld	a7,8(s1)
        next_safe = MAX_PID;
ffffffffc02042e6:	6789                	lui	a5,0x2
ffffffffc02042e8:	00093717          	auipc	a4,0x93
ffffffffc02042ec:	02f72023          	sw	a5,32(a4) # ffffffffc0297308 <next_safe.0>
ffffffffc02042f0:	86aa                	mv	a3,a0
ffffffffc02042f2:	4581                	li	a1,0
        while ((le = list_next(le)) != list)
ffffffffc02042f4:	04988063          	beq	a7,s1,ffffffffc0204334 <do_fork+0x1ba>
ffffffffc02042f8:	882e                	mv	a6,a1
ffffffffc02042fa:	87c6                	mv	a5,a7
ffffffffc02042fc:	6609                	lui	a2,0x2
ffffffffc02042fe:	a811                	j	ffffffffc0204312 <do_fork+0x198>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc0204300:	00e6d663          	bge	a3,a4,ffffffffc020430c <do_fork+0x192>
ffffffffc0204304:	00c75463          	bge	a4,a2,ffffffffc020430c <do_fork+0x192>
                next_safe = proc->pid;
ffffffffc0204308:	863a                	mv	a2,a4
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc020430a:	4805                	li	a6,1
ffffffffc020430c:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc020430e:	00978d63          	beq	a5,s1,ffffffffc0204328 <do_fork+0x1ae>
            if (proc->pid == last_pid)
ffffffffc0204312:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_obj___user_softint_out_size-0x6c94>
ffffffffc0204316:	fed715e3          	bne	a4,a3,ffffffffc0204300 <do_fork+0x186>
                if (++last_pid >= next_safe)
ffffffffc020431a:	2685                	addiw	a3,a3,1
ffffffffc020431c:	1cc6db63          	bge	a3,a2,ffffffffc02044f2 <do_fork+0x378>
ffffffffc0204320:	679c                	ld	a5,8(a5)
ffffffffc0204322:	4585                	li	a1,1
        while ((le = list_next(le)) != list)
ffffffffc0204324:	fe9797e3          	bne	a5,s1,ffffffffc0204312 <do_fork+0x198>
ffffffffc0204328:	00080663          	beqz	a6,ffffffffc0204334 <do_fork+0x1ba>
ffffffffc020432c:	00093797          	auipc	a5,0x93
ffffffffc0204330:	fcc7ae23          	sw	a2,-36(a5) # ffffffffc0297308 <next_safe.0>
ffffffffc0204334:	c591                	beqz	a1,ffffffffc0204340 <do_fork+0x1c6>
ffffffffc0204336:	00093797          	auipc	a5,0x93
ffffffffc020433a:	fcd7ab23          	sw	a3,-42(a5) # ffffffffc029730c <last_pid.1>
            else if (proc->pid > last_pid && next_safe > proc->pid)
ffffffffc020433e:	8536                	mv	a0,a3
        proc->pid = get_pid();
ffffffffc0204340:	c048                	sw	a0,4(s0)
    list_add(hash_list + pid_hashfn(proc->pid), &(proc->hash_link));
ffffffffc0204342:	45a9                	li	a1,10
ffffffffc0204344:	17a010ef          	jal	ffffffffc02054be <hash32>
ffffffffc0204348:	02051793          	slli	a5,a0,0x20
ffffffffc020434c:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0204350:	00093797          	auipc	a5,0x93
ffffffffc0204354:	3d878793          	addi	a5,a5,984 # ffffffffc0297728 <hash_list>
ffffffffc0204358:	953e                	add	a0,a0,a5
    __list_add(elm, listelm, listelm->next);
ffffffffc020435a:	6518                	ld	a4,8(a0)
ffffffffc020435c:	0d840793          	addi	a5,s0,216
ffffffffc0204360:	6490                	ld	a2,8(s1)
    prev->next = next->prev = elm;
ffffffffc0204362:	e31c                	sd	a5,0(a4)
ffffffffc0204364:	e51c                	sd	a5,8(a0)
    elm->next = next;
ffffffffc0204366:	f078                	sd	a4,224(s0)
    list_add(&proc_list, &(proc->list_link));
ffffffffc0204368:	0c840793          	addi	a5,s0,200
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc020436c:	7018                	ld	a4,32(s0)
    elm->prev = prev;
ffffffffc020436e:	ec68                	sd	a0,216(s0)
    prev->next = next->prev = elm;
ffffffffc0204370:	e21c                	sd	a5,0(a2)
    proc->yptr = NULL;
ffffffffc0204372:	0e043c23          	sd	zero,248(s0)
    if ((proc->optr = proc->parent->cptr) != NULL)
ffffffffc0204376:	7b74                	ld	a3,240(a4)
ffffffffc0204378:	e49c                	sd	a5,8(s1)
    elm->next = next;
ffffffffc020437a:	e870                	sd	a2,208(s0)
    elm->prev = prev;
ffffffffc020437c:	e464                	sd	s1,200(s0)
ffffffffc020437e:	10d43023          	sd	a3,256(s0)
ffffffffc0204382:	c299                	beqz	a3,ffffffffc0204388 <do_fork+0x20e>
        proc->optr->yptr = proc;
ffffffffc0204384:	fee0                	sd	s0,248(a3)
    proc->parent->cptr = proc;
ffffffffc0204386:	7018                	ld	a4,32(s0)
    nr_process++;
ffffffffc0204388:	00097797          	auipc	a5,0x97
ffffffffc020438c:	4147a783          	lw	a5,1044(a5) # ffffffffc029b79c <nr_process>
    proc->parent->cptr = proc;
ffffffffc0204390:	fb60                	sd	s0,240(a4)
    nr_process++;
ffffffffc0204392:	2785                	addiw	a5,a5,1
ffffffffc0204394:	00097717          	auipc	a4,0x97
ffffffffc0204398:	40f72423          	sw	a5,1032(a4) # ffffffffc029b79c <nr_process>
    if (flag)
ffffffffc020439c:	14091863          	bnez	s2,ffffffffc02044ec <do_fork+0x372>
    wakeup_proc(proc);
ffffffffc02043a0:	8522                	mv	a0,s0
ffffffffc02043a2:	721000ef          	jal	ffffffffc02052c2 <wakeup_proc>
    ret = proc->pid;
ffffffffc02043a6:	4048                	lw	a0,4(s0)
ffffffffc02043a8:	79e2                	ld	s3,56(sp)
ffffffffc02043aa:	7a42                	ld	s4,48(sp)
ffffffffc02043ac:	7aa2                	ld	s5,40(sp)
ffffffffc02043ae:	7b02                	ld	s6,32(sp)
ffffffffc02043b0:	6be2                	ld	s7,24(sp)
ffffffffc02043b2:	6c42                	ld	s8,16(sp)
ffffffffc02043b4:	6ca2                	ld	s9,8(sp)
}
ffffffffc02043b6:	60e6                	ld	ra,88(sp)
ffffffffc02043b8:	6446                	ld	s0,80(sp)
ffffffffc02043ba:	64a6                	ld	s1,72(sp)
ffffffffc02043bc:	6906                	ld	s2,64(sp)
ffffffffc02043be:	6d02                	ld	s10,0(sp)
ffffffffc02043c0:	6125                	addi	sp,sp,96
ffffffffc02043c2:	8082                	ret
    if ((mm = mm_create()) == NULL)
ffffffffc02043c4:	c12ff0ef          	jal	ffffffffc02037d6 <mm_create>
ffffffffc02043c8:	8d2a                	mv	s10,a0
ffffffffc02043ca:	c949                	beqz	a0,ffffffffc020445c <do_fork+0x2e2>
    if ((page = alloc_page()) == NULL)
ffffffffc02043cc:	4505                	li	a0,1
ffffffffc02043ce:	ba7fd0ef          	jal	ffffffffc0201f74 <alloc_pages>
ffffffffc02043d2:	c151                	beqz	a0,ffffffffc0204456 <do_fork+0x2dc>
    return page - pages + nbase;
ffffffffc02043d4:	0009b703          	ld	a4,0(s3)
    return KADDR(page2pa(page));
ffffffffc02043d8:	000ab783          	ld	a5,0(s5)
    return page - pages + nbase;
ffffffffc02043dc:	40e506b3          	sub	a3,a0,a4
ffffffffc02043e0:	8699                	srai	a3,a3,0x6
ffffffffc02043e2:	96e6                	add	a3,a3,s9
    return KADDR(page2pa(page));
ffffffffc02043e4:	0186fc33          	and	s8,a3,s8
    return page2ppn(page) << PGSHIFT;
ffffffffc02043e8:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc02043ea:	1afc7f63          	bgeu	s8,a5,ffffffffc02045a8 <do_fork+0x42e>
ffffffffc02043ee:	000b3783          	ld	a5,0(s6)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc02043f2:	00097597          	auipc	a1,0x97
ffffffffc02043f6:	3865b583          	ld	a1,902(a1) # ffffffffc029b778 <boot_pgdir_va>
ffffffffc02043fa:	6605                	lui	a2,0x1
ffffffffc02043fc:	00f68c33          	add	s8,a3,a5
ffffffffc0204400:	8562                	mv	a0,s8
ffffffffc0204402:	564010ef          	jal	ffffffffc0205966 <memcpy>
static inline void
lock_mm(struct mm_struct *mm)
{
    if (mm != NULL)
    {
        lock(&(mm->mm_lock));
ffffffffc0204406:	038b8c93          	addi	s9,s7,56
    mm->pgdir = pgdir;
ffffffffc020440a:	018d3c23          	sd	s8,24(s10) # fffffffffff80018 <end+0x3fce4860>
 * test_and_set_bit - Atomically set a bit and return its old value
 * @nr:     the bit to set
 * @addr:   the address to count from
 * */
static inline bool test_and_set_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020440e:	4c05                	li	s8,1
ffffffffc0204410:	418cb7af          	amoor.d	a5,s8,(s9)
}

static inline void
lock(lock_t *lock)
{
    while (!try_lock(lock))
ffffffffc0204414:	03f79713          	slli	a4,a5,0x3f
ffffffffc0204418:	03f75793          	srli	a5,a4,0x3f
ffffffffc020441c:	cb91                	beqz	a5,ffffffffc0204430 <do_fork+0x2b6>
    {
        schedule();
ffffffffc020441e:	739000ef          	jal	ffffffffc0205356 <schedule>
ffffffffc0204422:	418cb7af          	amoor.d	a5,s8,(s9)
    while (!try_lock(lock))
ffffffffc0204426:	03f79713          	slli	a4,a5,0x3f
ffffffffc020442a:	03f75793          	srli	a5,a4,0x3f
ffffffffc020442e:	fbe5                	bnez	a5,ffffffffc020441e <do_fork+0x2a4>
        ret = dup_mmap(mm, oldmm);
ffffffffc0204430:	85de                	mv	a1,s7
ffffffffc0204432:	856a                	mv	a0,s10
ffffffffc0204434:	dfeff0ef          	jal	ffffffffc0203a32 <dup_mmap>
 * test_and_clear_bit - Atomically clear a bit and return its old value
 * @nr:     the bit to clear
 * @addr:   the address to count from
 * */
static inline bool test_and_clear_bit(int nr, volatile void *addr) {
    return __test_and_op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0204438:	57f9                	li	a5,-2
ffffffffc020443a:	60fcb7af          	amoand.d	a5,a5,(s9)
ffffffffc020443e:	8b85                	andi	a5,a5,1
}

static inline void
unlock(lock_t *lock)
{
    if (!test_and_clear_bit(0, lock))
ffffffffc0204440:	12078263          	beqz	a5,ffffffffc0204564 <do_fork+0x3ea>
    if ((mm = mm_create()) == NULL)
ffffffffc0204444:	8bea                	mv	s7,s10
    if (ret != 0)
ffffffffc0204446:	de0506e3          	beqz	a0,ffffffffc0204232 <do_fork+0xb8>
    exit_mmap(mm);
ffffffffc020444a:	856a                	mv	a0,s10
ffffffffc020444c:	e7eff0ef          	jal	ffffffffc0203aca <exit_mmap>
    put_pgdir(mm);
ffffffffc0204450:	856a                	mv	a0,s10
ffffffffc0204452:	c4fff0ef          	jal	ffffffffc02040a0 <put_pgdir>
    mm_destroy(mm);
ffffffffc0204456:	856a                	mv	a0,s10
ffffffffc0204458:	cbcff0ef          	jal	ffffffffc0203914 <mm_destroy>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020445c:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc020445e:	c02007b7          	lui	a5,0xc0200
ffffffffc0204462:	0ef6e563          	bltu	a3,a5,ffffffffc020454c <do_fork+0x3d2>
ffffffffc0204466:	000b3783          	ld	a5,0(s6)
    if (PPN(pa) >= npage)
ffffffffc020446a:	000ab703          	ld	a4,0(s5)
    return pa2page(PADDR(kva));
ffffffffc020446e:	40f687b3          	sub	a5,a3,a5
    if (PPN(pa) >= npage)
ffffffffc0204472:	83b1                	srli	a5,a5,0xc
ffffffffc0204474:	08e7f763          	bgeu	a5,a4,ffffffffc0204502 <do_fork+0x388>
    return &pages[PPN(pa) - nbase];
ffffffffc0204478:	000a3703          	ld	a4,0(s4)
ffffffffc020447c:	0009b503          	ld	a0,0(s3)
ffffffffc0204480:	4589                	li	a1,2
ffffffffc0204482:	8f99                	sub	a5,a5,a4
ffffffffc0204484:	079a                	slli	a5,a5,0x6
ffffffffc0204486:	953e                	add	a0,a0,a5
ffffffffc0204488:	b27fd0ef          	jal	ffffffffc0201fae <free_pages>
}
ffffffffc020448c:	79e2                	ld	s3,56(sp)
ffffffffc020448e:	7a42                	ld	s4,48(sp)
ffffffffc0204490:	7aa2                	ld	s5,40(sp)
ffffffffc0204492:	6be2                	ld	s7,24(sp)
ffffffffc0204494:	6c42                	ld	s8,16(sp)
ffffffffc0204496:	6ca2                	ld	s9,8(sp)
    kfree(proc);
ffffffffc0204498:	8522                	mv	a0,s0
ffffffffc020449a:	9bdfd0ef          	jal	ffffffffc0201e56 <kfree>
ffffffffc020449e:	7b02                	ld	s6,32(sp)
    ret = -E_NO_MEM;
ffffffffc02044a0:	5571                	li	a0,-4
    return ret;
ffffffffc02044a2:	bf11                	j	ffffffffc02043b6 <do_fork+0x23c>
    proc->tf->gpr.sp = (esp == 0) ? (uintptr_t)proc->tf : esp;
ffffffffc02044a4:	8936                	mv	s2,a3
ffffffffc02044a6:	0126b823          	sd	s2,16(a3)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02044aa:	00000797          	auipc	a5,0x0
ffffffffc02044ae:	b6a78793          	addi	a5,a5,-1174 # ffffffffc0204014 <forkret>
    proc->context.sp = (uintptr_t)(proc->tf);
ffffffffc02044b2:	fc14                	sd	a3,56(s0)
    proc->context.ra = (uintptr_t)forkret;
ffffffffc02044b4:	f81c                	sd	a5,48(s0)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02044b6:	100027f3          	csrr	a5,sstatus
ffffffffc02044ba:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02044bc:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02044be:	de0788e3          	beqz	a5,ffffffffc02042ae <do_fork+0x134>
        intr_disable();
ffffffffc02044c2:	c42fc0ef          	jal	ffffffffc0200904 <intr_disable>
    if (++last_pid >= MAX_PID)
ffffffffc02044c6:	00093517          	auipc	a0,0x93
ffffffffc02044ca:	e4652503          	lw	a0,-442(a0) # ffffffffc029730c <last_pid.1>
ffffffffc02044ce:	6789                	lui	a5,0x2
        return 1;
ffffffffc02044d0:	4905                	li	s2,1
ffffffffc02044d2:	2505                	addiw	a0,a0,1
ffffffffc02044d4:	00093717          	auipc	a4,0x93
ffffffffc02044d8:	e2a72c23          	sw	a0,-456(a4) # ffffffffc029730c <last_pid.1>
ffffffffc02044dc:	def545e3          	blt	a0,a5,ffffffffc02042c6 <do_fork+0x14c>
        last_pid = 1;
ffffffffc02044e0:	4505                	li	a0,1
ffffffffc02044e2:	00093797          	auipc	a5,0x93
ffffffffc02044e6:	e2a7a523          	sw	a0,-470(a5) # ffffffffc029730c <last_pid.1>
        goto inside;
ffffffffc02044ea:	bbc5                	j	ffffffffc02042da <do_fork+0x160>
        intr_enable();
ffffffffc02044ec:	c12fc0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc02044f0:	bd45                	j	ffffffffc02043a0 <do_fork+0x226>
                    if (last_pid >= MAX_PID)
ffffffffc02044f2:	6789                	lui	a5,0x2
ffffffffc02044f4:	00f6c363          	blt	a3,a5,ffffffffc02044fa <do_fork+0x380>
                        last_pid = 1;
ffffffffc02044f8:	4685                	li	a3,1
                    goto repeat;
ffffffffc02044fa:	4585                	li	a1,1
ffffffffc02044fc:	bbe5                	j	ffffffffc02042f4 <do_fork+0x17a>
    int ret = -E_NO_FREE_PROC;
ffffffffc02044fe:	556d                	li	a0,-5
}
ffffffffc0204500:	8082                	ret
        panic("pa2page called with invalid pa");
ffffffffc0204502:	00002617          	auipc	a2,0x2
ffffffffc0204506:	2f660613          	addi	a2,a2,758 # ffffffffc02067f8 <etext+0xe7a>
ffffffffc020450a:	06900593          	li	a1,105
ffffffffc020450e:	00002517          	auipc	a0,0x2
ffffffffc0204512:	24250513          	addi	a0,a0,578 # ffffffffc0206750 <etext+0xdd2>
ffffffffc0204516:	f31fb0ef          	jal	ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc020451a:	00002617          	auipc	a2,0x2
ffffffffc020451e:	20e60613          	addi	a2,a2,526 # ffffffffc0206728 <etext+0xdaa>
ffffffffc0204522:	07100593          	li	a1,113
ffffffffc0204526:	00002517          	auipc	a0,0x2
ffffffffc020452a:	22a50513          	addi	a0,a0,554 # ffffffffc0206750 <etext+0xdd2>
ffffffffc020452e:	f19fb0ef          	jal	ffffffffc0200446 <__panic>
    proc->pgdir = PADDR(mm->pgdir);
ffffffffc0204532:	86be                	mv	a3,a5
ffffffffc0204534:	00002617          	auipc	a2,0x2
ffffffffc0204538:	29c60613          	addi	a2,a2,668 # ffffffffc02067d0 <etext+0xe52>
ffffffffc020453c:	18900593          	li	a1,393
ffffffffc0204540:	00003517          	auipc	a0,0x3
ffffffffc0204544:	c7050513          	addi	a0,a0,-912 # ffffffffc02071b0 <etext+0x1832>
ffffffffc0204548:	efffb0ef          	jal	ffffffffc0200446 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020454c:	00002617          	auipc	a2,0x2
ffffffffc0204550:	28460613          	addi	a2,a2,644 # ffffffffc02067d0 <etext+0xe52>
ffffffffc0204554:	07700593          	li	a1,119
ffffffffc0204558:	00002517          	auipc	a0,0x2
ffffffffc020455c:	1f850513          	addi	a0,a0,504 # ffffffffc0206750 <etext+0xdd2>
ffffffffc0204560:	ee7fb0ef          	jal	ffffffffc0200446 <__panic>
    {
        panic("Unlock failed.\n");
ffffffffc0204564:	00003617          	auipc	a2,0x3
ffffffffc0204568:	c8460613          	addi	a2,a2,-892 # ffffffffc02071e8 <etext+0x186a>
ffffffffc020456c:	03f00593          	li	a1,63
ffffffffc0204570:	00003517          	auipc	a0,0x3
ffffffffc0204574:	c8850513          	addi	a0,a0,-888 # ffffffffc02071f8 <etext+0x187a>
ffffffffc0204578:	ecffb0ef          	jal	ffffffffc0200446 <__panic>
    assert(current->wait_state == 0);
ffffffffc020457c:	00003697          	auipc	a3,0x3
ffffffffc0204580:	c4c68693          	addi	a3,a3,-948 # ffffffffc02071c8 <etext+0x184a>
ffffffffc0204584:	00002617          	auipc	a2,0x2
ffffffffc0204588:	df460613          	addi	a2,a2,-524 # ffffffffc0206378 <etext+0x9fa>
ffffffffc020458c:	1c900593          	li	a1,457
ffffffffc0204590:	00003517          	auipc	a0,0x3
ffffffffc0204594:	c2050513          	addi	a0,a0,-992 # ffffffffc02071b0 <etext+0x1832>
ffffffffc0204598:	fc4e                	sd	s3,56(sp)
ffffffffc020459a:	f852                	sd	s4,48(sp)
ffffffffc020459c:	f456                	sd	s5,40(sp)
ffffffffc020459e:	ec5e                	sd	s7,24(sp)
ffffffffc02045a0:	e862                	sd	s8,16(sp)
ffffffffc02045a2:	e466                	sd	s9,8(sp)
ffffffffc02045a4:	ea3fb0ef          	jal	ffffffffc0200446 <__panic>
    return KADDR(page2pa(page));
ffffffffc02045a8:	00002617          	auipc	a2,0x2
ffffffffc02045ac:	18060613          	addi	a2,a2,384 # ffffffffc0206728 <etext+0xdaa>
ffffffffc02045b0:	07100593          	li	a1,113
ffffffffc02045b4:	00002517          	auipc	a0,0x2
ffffffffc02045b8:	19c50513          	addi	a0,a0,412 # ffffffffc0206750 <etext+0xdd2>
ffffffffc02045bc:	e8bfb0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02045c0 <kernel_thread>:
{
ffffffffc02045c0:	7129                	addi	sp,sp,-320
ffffffffc02045c2:	fa22                	sd	s0,304(sp)
ffffffffc02045c4:	f626                	sd	s1,296(sp)
ffffffffc02045c6:	f24a                	sd	s2,288(sp)
ffffffffc02045c8:	842a                	mv	s0,a0
ffffffffc02045ca:	84ae                	mv	s1,a1
ffffffffc02045cc:	8932                	mv	s2,a2
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02045ce:	850a                	mv	a0,sp
ffffffffc02045d0:	12000613          	li	a2,288
ffffffffc02045d4:	4581                	li	a1,0
{
ffffffffc02045d6:	fe06                	sd	ra,312(sp)
    memset(&tf, 0, sizeof(struct trapframe));
ffffffffc02045d8:	37c010ef          	jal	ffffffffc0205954 <memset>
    tf.gpr.s0 = (uintptr_t)fn;
ffffffffc02045dc:	e0a2                	sd	s0,64(sp)
    tf.gpr.s1 = (uintptr_t)arg;
ffffffffc02045de:	e4a6                	sd	s1,72(sp)
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02045e0:	100027f3          	csrr	a5,sstatus
ffffffffc02045e4:	edd7f793          	andi	a5,a5,-291
ffffffffc02045e8:	1207e793          	ori	a5,a5,288
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02045ec:	860a                	mv	a2,sp
ffffffffc02045ee:	10096513          	ori	a0,s2,256
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02045f2:	00000717          	auipc	a4,0x0
ffffffffc02045f6:	9a870713          	addi	a4,a4,-1624 # ffffffffc0203f9a <kernel_thread_entry>
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc02045fa:	4581                	li	a1,0
    tf.status = (read_csr(sstatus) | SSTATUS_SPP | SSTATUS_SPIE) & ~SSTATUS_SIE;
ffffffffc02045fc:	e23e                	sd	a5,256(sp)
    tf.epc = (uintptr_t)kernel_thread_entry;
ffffffffc02045fe:	e63a                	sd	a4,264(sp)
    return do_fork(clone_flags | CLONE_VM, 0, &tf);
ffffffffc0204600:	b7bff0ef          	jal	ffffffffc020417a <do_fork>
}
ffffffffc0204604:	70f2                	ld	ra,312(sp)
ffffffffc0204606:	7452                	ld	s0,304(sp)
ffffffffc0204608:	74b2                	ld	s1,296(sp)
ffffffffc020460a:	7912                	ld	s2,288(sp)
ffffffffc020460c:	6131                	addi	sp,sp,320
ffffffffc020460e:	8082                	ret

ffffffffc0204610 <do_exit>:
{
ffffffffc0204610:	7179                	addi	sp,sp,-48
ffffffffc0204612:	f022                	sd	s0,32(sp)
    if (current == idleproc)
ffffffffc0204614:	00097417          	auipc	s0,0x97
ffffffffc0204618:	18c40413          	addi	s0,s0,396 # ffffffffc029b7a0 <current>
ffffffffc020461c:	601c                	ld	a5,0(s0)
ffffffffc020461e:	00097717          	auipc	a4,0x97
ffffffffc0204622:	19273703          	ld	a4,402(a4) # ffffffffc029b7b0 <idleproc>
{
ffffffffc0204626:	f406                	sd	ra,40(sp)
ffffffffc0204628:	ec26                	sd	s1,24(sp)
    if (current == idleproc)
ffffffffc020462a:	0ce78b63          	beq	a5,a4,ffffffffc0204700 <do_exit+0xf0>
    if (current == initproc)
ffffffffc020462e:	00097497          	auipc	s1,0x97
ffffffffc0204632:	17a48493          	addi	s1,s1,378 # ffffffffc029b7a8 <initproc>
ffffffffc0204636:	6098                	ld	a4,0(s1)
ffffffffc0204638:	e84a                	sd	s2,16(sp)
ffffffffc020463a:	0ee78a63          	beq	a5,a4,ffffffffc020472e <do_exit+0x11e>
ffffffffc020463e:	892a                	mv	s2,a0
    struct mm_struct *mm = current->mm;
ffffffffc0204640:	7788                	ld	a0,40(a5)
    if (mm != NULL)
ffffffffc0204642:	c115                	beqz	a0,ffffffffc0204666 <do_exit+0x56>
ffffffffc0204644:	00097797          	auipc	a5,0x97
ffffffffc0204648:	12c7b783          	ld	a5,300(a5) # ffffffffc029b770 <boot_pgdir_pa>
ffffffffc020464c:	577d                	li	a4,-1
ffffffffc020464e:	177e                	slli	a4,a4,0x3f
ffffffffc0204650:	83b1                	srli	a5,a5,0xc
ffffffffc0204652:	8fd9                	or	a5,a5,a4
ffffffffc0204654:	18079073          	csrw	satp,a5
    mm->mm_count -= 1;
ffffffffc0204658:	591c                	lw	a5,48(a0)
ffffffffc020465a:	37fd                	addiw	a5,a5,-1
ffffffffc020465c:	d91c                	sw	a5,48(a0)
        if (mm_count_dec(mm) == 0)
ffffffffc020465e:	cfd5                	beqz	a5,ffffffffc020471a <do_exit+0x10a>
        current->mm = NULL;
ffffffffc0204660:	601c                	ld	a5,0(s0)
ffffffffc0204662:	0207b423          	sd	zero,40(a5)
    current->state = PROC_ZOMBIE;
ffffffffc0204666:	470d                	li	a4,3
    current->exit_code = error_code;
ffffffffc0204668:	0f27a423          	sw	s2,232(a5)
    current->state = PROC_ZOMBIE;
ffffffffc020466c:	c398                	sw	a4,0(a5)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020466e:	100027f3          	csrr	a5,sstatus
ffffffffc0204672:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc0204674:	4901                	li	s2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc0204676:	ebe1                	bnez	a5,ffffffffc0204746 <do_exit+0x136>
        proc = current->parent;
ffffffffc0204678:	6018                	ld	a4,0(s0)
        if (proc->wait_state == WT_CHILD)
ffffffffc020467a:	800007b7          	lui	a5,0x80000
ffffffffc020467e:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_obj___user_exit_out_size+0xffffffff7fff5e41>
        proc = current->parent;
ffffffffc0204680:	7308                	ld	a0,32(a4)
        if (proc->wait_state == WT_CHILD)
ffffffffc0204682:	0ec52703          	lw	a4,236(a0)
ffffffffc0204686:	0cf70463          	beq	a4,a5,ffffffffc020474e <do_exit+0x13e>
        while (current->cptr != NULL)
ffffffffc020468a:	6018                	ld	a4,0(s0)
                if (initproc->wait_state == WT_CHILD)
ffffffffc020468c:	800005b7          	lui	a1,0x80000
ffffffffc0204690:	0585                	addi	a1,a1,1 # ffffffff80000001 <_binary_obj___user_exit_out_size+0xffffffff7fff5e41>
        while (current->cptr != NULL)
ffffffffc0204692:	7b7c                	ld	a5,240(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204694:	460d                	li	a2,3
        while (current->cptr != NULL)
ffffffffc0204696:	e789                	bnez	a5,ffffffffc02046a0 <do_exit+0x90>
ffffffffc0204698:	a83d                	j	ffffffffc02046d6 <do_exit+0xc6>
ffffffffc020469a:	6018                	ld	a4,0(s0)
ffffffffc020469c:	7b7c                	ld	a5,240(a4)
ffffffffc020469e:	cf85                	beqz	a5,ffffffffc02046d6 <do_exit+0xc6>
            current->cptr = proc->optr;
ffffffffc02046a0:	1007b683          	ld	a3,256(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc02046a4:	6088                	ld	a0,0(s1)
            current->cptr = proc->optr;
ffffffffc02046a6:	fb74                	sd	a3,240(a4)
            proc->yptr = NULL;
ffffffffc02046a8:	0e07bc23          	sd	zero,248(a5)
            if ((proc->optr = initproc->cptr) != NULL)
ffffffffc02046ac:	7978                	ld	a4,240(a0)
ffffffffc02046ae:	10e7b023          	sd	a4,256(a5)
ffffffffc02046b2:	c311                	beqz	a4,ffffffffc02046b6 <do_exit+0xa6>
                initproc->cptr->yptr = proc;
ffffffffc02046b4:	ff7c                	sd	a5,248(a4)
            if (proc->state == PROC_ZOMBIE)
ffffffffc02046b6:	4398                	lw	a4,0(a5)
            proc->parent = initproc;
ffffffffc02046b8:	f388                	sd	a0,32(a5)
            initproc->cptr = proc;
ffffffffc02046ba:	f97c                	sd	a5,240(a0)
            if (proc->state == PROC_ZOMBIE)
ffffffffc02046bc:	fcc71fe3          	bne	a4,a2,ffffffffc020469a <do_exit+0x8a>
                if (initproc->wait_state == WT_CHILD)
ffffffffc02046c0:	0ec52783          	lw	a5,236(a0)
ffffffffc02046c4:	fcb79be3          	bne	a5,a1,ffffffffc020469a <do_exit+0x8a>
                    wakeup_proc(initproc);
ffffffffc02046c8:	3fb000ef          	jal	ffffffffc02052c2 <wakeup_proc>
ffffffffc02046cc:	800005b7          	lui	a1,0x80000
ffffffffc02046d0:	0585                	addi	a1,a1,1 # ffffffff80000001 <_binary_obj___user_exit_out_size+0xffffffff7fff5e41>
ffffffffc02046d2:	460d                	li	a2,3
ffffffffc02046d4:	b7d9                	j	ffffffffc020469a <do_exit+0x8a>
    if (flag)
ffffffffc02046d6:	02091263          	bnez	s2,ffffffffc02046fa <do_exit+0xea>
    schedule();
ffffffffc02046da:	47d000ef          	jal	ffffffffc0205356 <schedule>
    panic("do_exit will not return!! %d.\n", current->pid);
ffffffffc02046de:	601c                	ld	a5,0(s0)
ffffffffc02046e0:	00003617          	auipc	a2,0x3
ffffffffc02046e4:	b5060613          	addi	a2,a2,-1200 # ffffffffc0207230 <etext+0x18b2>
ffffffffc02046e8:	23700593          	li	a1,567
ffffffffc02046ec:	43d4                	lw	a3,4(a5)
ffffffffc02046ee:	00003517          	auipc	a0,0x3
ffffffffc02046f2:	ac250513          	addi	a0,a0,-1342 # ffffffffc02071b0 <etext+0x1832>
ffffffffc02046f6:	d51fb0ef          	jal	ffffffffc0200446 <__panic>
        intr_enable();
ffffffffc02046fa:	a04fc0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc02046fe:	bff1                	j	ffffffffc02046da <do_exit+0xca>
        panic("idleproc exit.\n");
ffffffffc0204700:	00003617          	auipc	a2,0x3
ffffffffc0204704:	b1060613          	addi	a2,a2,-1264 # ffffffffc0207210 <etext+0x1892>
ffffffffc0204708:	20300593          	li	a1,515
ffffffffc020470c:	00003517          	auipc	a0,0x3
ffffffffc0204710:	aa450513          	addi	a0,a0,-1372 # ffffffffc02071b0 <etext+0x1832>
ffffffffc0204714:	e84a                	sd	s2,16(sp)
ffffffffc0204716:	d31fb0ef          	jal	ffffffffc0200446 <__panic>
            exit_mmap(mm);
ffffffffc020471a:	e42a                	sd	a0,8(sp)
ffffffffc020471c:	baeff0ef          	jal	ffffffffc0203aca <exit_mmap>
            put_pgdir(mm);
ffffffffc0204720:	6522                	ld	a0,8(sp)
ffffffffc0204722:	97fff0ef          	jal	ffffffffc02040a0 <put_pgdir>
            mm_destroy(mm);
ffffffffc0204726:	6522                	ld	a0,8(sp)
ffffffffc0204728:	9ecff0ef          	jal	ffffffffc0203914 <mm_destroy>
ffffffffc020472c:	bf15                	j	ffffffffc0204660 <do_exit+0x50>
        panic("initproc exit.\n");
ffffffffc020472e:	00003617          	auipc	a2,0x3
ffffffffc0204732:	af260613          	addi	a2,a2,-1294 # ffffffffc0207220 <etext+0x18a2>
ffffffffc0204736:	20700593          	li	a1,519
ffffffffc020473a:	00003517          	auipc	a0,0x3
ffffffffc020473e:	a7650513          	addi	a0,a0,-1418 # ffffffffc02071b0 <etext+0x1832>
ffffffffc0204742:	d05fb0ef          	jal	ffffffffc0200446 <__panic>
        intr_disable();
ffffffffc0204746:	9befc0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc020474a:	4905                	li	s2,1
ffffffffc020474c:	b735                	j	ffffffffc0204678 <do_exit+0x68>
            wakeup_proc(proc);
ffffffffc020474e:	375000ef          	jal	ffffffffc02052c2 <wakeup_proc>
ffffffffc0204752:	bf25                	j	ffffffffc020468a <do_exit+0x7a>

ffffffffc0204754 <do_wait.part.0>:
int do_wait(int pid, int *code_store)
ffffffffc0204754:	7179                	addi	sp,sp,-48
ffffffffc0204756:	ec26                	sd	s1,24(sp)
ffffffffc0204758:	e84a                	sd	s2,16(sp)
ffffffffc020475a:	e44e                	sd	s3,8(sp)
ffffffffc020475c:	f406                	sd	ra,40(sp)
ffffffffc020475e:	f022                	sd	s0,32(sp)
ffffffffc0204760:	84aa                	mv	s1,a0
ffffffffc0204762:	892e                	mv	s2,a1
ffffffffc0204764:	00097997          	auipc	s3,0x97
ffffffffc0204768:	03c98993          	addi	s3,s3,60 # ffffffffc029b7a0 <current>
    if (pid != 0)
ffffffffc020476c:	cd19                	beqz	a0,ffffffffc020478a <do_wait.part.0+0x36>
    if (0 < pid && pid < MAX_PID)
ffffffffc020476e:	6789                	lui	a5,0x2
ffffffffc0204770:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x6bd2>
ffffffffc0204772:	fff5071b          	addiw	a4,a0,-1
ffffffffc0204776:	12e7f563          	bgeu	a5,a4,ffffffffc02048a0 <do_wait.part.0+0x14c>
}
ffffffffc020477a:	70a2                	ld	ra,40(sp)
ffffffffc020477c:	7402                	ld	s0,32(sp)
ffffffffc020477e:	64e2                	ld	s1,24(sp)
ffffffffc0204780:	6942                	ld	s2,16(sp)
ffffffffc0204782:	69a2                	ld	s3,8(sp)
    return -E_BAD_PROC;
ffffffffc0204784:	5579                	li	a0,-2
}
ffffffffc0204786:	6145                	addi	sp,sp,48
ffffffffc0204788:	8082                	ret
        proc = current->cptr;
ffffffffc020478a:	0009b703          	ld	a4,0(s3)
ffffffffc020478e:	7b60                	ld	s0,240(a4)
        for (; proc != NULL; proc = proc->optr)
ffffffffc0204790:	d46d                	beqz	s0,ffffffffc020477a <do_wait.part.0+0x26>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204792:	468d                	li	a3,3
ffffffffc0204794:	a021                	j	ffffffffc020479c <do_wait.part.0+0x48>
        for (; proc != NULL; proc = proc->optr)
ffffffffc0204796:	10043403          	ld	s0,256(s0)
ffffffffc020479a:	c075                	beqz	s0,ffffffffc020487e <do_wait.part.0+0x12a>
            if (proc->state == PROC_ZOMBIE)
ffffffffc020479c:	401c                	lw	a5,0(s0)
ffffffffc020479e:	fed79ce3          	bne	a5,a3,ffffffffc0204796 <do_wait.part.0+0x42>
    if (proc == idleproc || proc == initproc)
ffffffffc02047a2:	00097797          	auipc	a5,0x97
ffffffffc02047a6:	00e7b783          	ld	a5,14(a5) # ffffffffc029b7b0 <idleproc>
ffffffffc02047aa:	14878263          	beq	a5,s0,ffffffffc02048ee <do_wait.part.0+0x19a>
ffffffffc02047ae:	00097797          	auipc	a5,0x97
ffffffffc02047b2:	ffa7b783          	ld	a5,-6(a5) # ffffffffc029b7a8 <initproc>
ffffffffc02047b6:	12f40c63          	beq	s0,a5,ffffffffc02048ee <do_wait.part.0+0x19a>
    if (code_store != NULL)
ffffffffc02047ba:	00090663          	beqz	s2,ffffffffc02047c6 <do_wait.part.0+0x72>
        *code_store = proc->exit_code;
ffffffffc02047be:	0e842783          	lw	a5,232(s0)
ffffffffc02047c2:	00f92023          	sw	a5,0(s2)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02047c6:	100027f3          	csrr	a5,sstatus
ffffffffc02047ca:	8b89                	andi	a5,a5,2
    return 0;
ffffffffc02047cc:	4601                	li	a2,0
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02047ce:	10079963          	bnez	a5,ffffffffc02048e0 <do_wait.part.0+0x18c>
    __list_del(listelm->prev, listelm->next);
ffffffffc02047d2:	6c74                	ld	a3,216(s0)
ffffffffc02047d4:	7078                	ld	a4,224(s0)
    if (proc->optr != NULL)
ffffffffc02047d6:	10043783          	ld	a5,256(s0)
    prev->next = next;
ffffffffc02047da:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02047dc:	e314                	sd	a3,0(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc02047de:	6474                	ld	a3,200(s0)
ffffffffc02047e0:	6878                	ld	a4,208(s0)
    prev->next = next;
ffffffffc02047e2:	e698                	sd	a4,8(a3)
    next->prev = prev;
ffffffffc02047e4:	e314                	sd	a3,0(a4)
ffffffffc02047e6:	c789                	beqz	a5,ffffffffc02047f0 <do_wait.part.0+0x9c>
        proc->optr->yptr = proc->yptr;
ffffffffc02047e8:	7c78                	ld	a4,248(s0)
ffffffffc02047ea:	fff8                	sd	a4,248(a5)
        proc->yptr->optr = proc->optr;
ffffffffc02047ec:	10043783          	ld	a5,256(s0)
    if (proc->yptr != NULL)
ffffffffc02047f0:	7c78                	ld	a4,248(s0)
ffffffffc02047f2:	c36d                	beqz	a4,ffffffffc02048d4 <do_wait.part.0+0x180>
        proc->yptr->optr = proc->optr;
ffffffffc02047f4:	10f73023          	sd	a5,256(a4)
    nr_process--;
ffffffffc02047f8:	00097797          	auipc	a5,0x97
ffffffffc02047fc:	fa47a783          	lw	a5,-92(a5) # ffffffffc029b79c <nr_process>
ffffffffc0204800:	37fd                	addiw	a5,a5,-1
ffffffffc0204802:	00097717          	auipc	a4,0x97
ffffffffc0204806:	f8f72d23          	sw	a5,-102(a4) # ffffffffc029b79c <nr_process>
    if (flag)
ffffffffc020480a:	e271                	bnez	a2,ffffffffc02048ce <do_wait.part.0+0x17a>
    free_pages(kva2page((void *)(proc->kstack)), KSTACKPAGE);
ffffffffc020480c:	6814                	ld	a3,16(s0)
    return pa2page(PADDR(kva));
ffffffffc020480e:	c02007b7          	lui	a5,0xc0200
ffffffffc0204812:	10f6e663          	bltu	a3,a5,ffffffffc020491e <do_wait.part.0+0x1ca>
ffffffffc0204816:	00097717          	auipc	a4,0x97
ffffffffc020481a:	f6a73703          	ld	a4,-150(a4) # ffffffffc029b780 <va_pa_offset>
    if (PPN(pa) >= npage)
ffffffffc020481e:	00097797          	auipc	a5,0x97
ffffffffc0204822:	f6a7b783          	ld	a5,-150(a5) # ffffffffc029b788 <npage>
    return pa2page(PADDR(kva));
ffffffffc0204826:	8e99                	sub	a3,a3,a4
    if (PPN(pa) >= npage)
ffffffffc0204828:	82b1                	srli	a3,a3,0xc
ffffffffc020482a:	0cf6fe63          	bgeu	a3,a5,ffffffffc0204906 <do_wait.part.0+0x1b2>
    return &pages[PPN(pa) - nbase];
ffffffffc020482e:	00003797          	auipc	a5,0x3
ffffffffc0204832:	32a7b783          	ld	a5,810(a5) # ffffffffc0207b58 <nbase>
ffffffffc0204836:	00097517          	auipc	a0,0x97
ffffffffc020483a:	f5a53503          	ld	a0,-166(a0) # ffffffffc029b790 <pages>
ffffffffc020483e:	4589                	li	a1,2
ffffffffc0204840:	8e9d                	sub	a3,a3,a5
ffffffffc0204842:	069a                	slli	a3,a3,0x6
ffffffffc0204844:	9536                	add	a0,a0,a3
ffffffffc0204846:	f68fd0ef          	jal	ffffffffc0201fae <free_pages>
    kfree(proc);
ffffffffc020484a:	8522                	mv	a0,s0
ffffffffc020484c:	e0afd0ef          	jal	ffffffffc0201e56 <kfree>
}
ffffffffc0204850:	70a2                	ld	ra,40(sp)
ffffffffc0204852:	7402                	ld	s0,32(sp)
ffffffffc0204854:	64e2                	ld	s1,24(sp)
ffffffffc0204856:	6942                	ld	s2,16(sp)
ffffffffc0204858:	69a2                	ld	s3,8(sp)
    return 0;
ffffffffc020485a:	4501                	li	a0,0
}
ffffffffc020485c:	6145                	addi	sp,sp,48
ffffffffc020485e:	8082                	ret
        if (proc != NULL && proc->parent == current)
ffffffffc0204860:	00097997          	auipc	s3,0x97
ffffffffc0204864:	f4098993          	addi	s3,s3,-192 # ffffffffc029b7a0 <current>
ffffffffc0204868:	0009b703          	ld	a4,0(s3)
ffffffffc020486c:	f487b683          	ld	a3,-184(a5)
ffffffffc0204870:	f0e695e3          	bne	a3,a4,ffffffffc020477a <do_wait.part.0+0x26>
            if (proc->state == PROC_ZOMBIE)
ffffffffc0204874:	f287a603          	lw	a2,-216(a5)
ffffffffc0204878:	468d                	li	a3,3
ffffffffc020487a:	06d60063          	beq	a2,a3,ffffffffc02048da <do_wait.part.0+0x186>
        current->wait_state = WT_CHILD;
ffffffffc020487e:	800007b7          	lui	a5,0x80000
ffffffffc0204882:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_obj___user_exit_out_size+0xffffffff7fff5e41>
        current->state = PROC_SLEEPING;
ffffffffc0204884:	4685                	li	a3,1
        current->wait_state = WT_CHILD;
ffffffffc0204886:	0ef72623          	sw	a5,236(a4)
        current->state = PROC_SLEEPING;
ffffffffc020488a:	c314                	sw	a3,0(a4)
        schedule();
ffffffffc020488c:	2cb000ef          	jal	ffffffffc0205356 <schedule>
        if (current->flags & PF_EXITING)
ffffffffc0204890:	0009b783          	ld	a5,0(s3)
ffffffffc0204894:	0b07a783          	lw	a5,176(a5)
ffffffffc0204898:	8b85                	andi	a5,a5,1
ffffffffc020489a:	e7b9                	bnez	a5,ffffffffc02048e8 <do_wait.part.0+0x194>
    if (pid != 0)
ffffffffc020489c:	ee0487e3          	beqz	s1,ffffffffc020478a <do_wait.part.0+0x36>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc02048a0:	45a9                	li	a1,10
ffffffffc02048a2:	8526                	mv	a0,s1
ffffffffc02048a4:	41b000ef          	jal	ffffffffc02054be <hash32>
ffffffffc02048a8:	02051793          	slli	a5,a0,0x20
ffffffffc02048ac:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02048b0:	00093797          	auipc	a5,0x93
ffffffffc02048b4:	e7878793          	addi	a5,a5,-392 # ffffffffc0297728 <hash_list>
ffffffffc02048b8:	953e                	add	a0,a0,a5
ffffffffc02048ba:	87aa                	mv	a5,a0
        while ((le = list_next(le)) != list)
ffffffffc02048bc:	a029                	j	ffffffffc02048c6 <do_wait.part.0+0x172>
            if (proc->pid == pid)
ffffffffc02048be:	f2c7a703          	lw	a4,-212(a5)
ffffffffc02048c2:	f8970fe3          	beq	a4,s1,ffffffffc0204860 <do_wait.part.0+0x10c>
    return listelm->next;
ffffffffc02048c6:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc02048c8:	fef51be3          	bne	a0,a5,ffffffffc02048be <do_wait.part.0+0x16a>
ffffffffc02048cc:	b57d                	j	ffffffffc020477a <do_wait.part.0+0x26>
        intr_enable();
ffffffffc02048ce:	830fc0ef          	jal	ffffffffc02008fe <intr_enable>
ffffffffc02048d2:	bf2d                	j	ffffffffc020480c <do_wait.part.0+0xb8>
        proc->parent->cptr = proc->optr;
ffffffffc02048d4:	7018                	ld	a4,32(s0)
ffffffffc02048d6:	fb7c                	sd	a5,240(a4)
ffffffffc02048d8:	b705                	j	ffffffffc02047f8 <do_wait.part.0+0xa4>
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02048da:	f2878413          	addi	s0,a5,-216
ffffffffc02048de:	b5d1                	j	ffffffffc02047a2 <do_wait.part.0+0x4e>
        intr_disable();
ffffffffc02048e0:	824fc0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc02048e4:	4605                	li	a2,1
ffffffffc02048e6:	b5f5                	j	ffffffffc02047d2 <do_wait.part.0+0x7e>
            do_exit(-E_KILLED);
ffffffffc02048e8:	555d                	li	a0,-9
ffffffffc02048ea:	d27ff0ef          	jal	ffffffffc0204610 <do_exit>
        panic("wait idleproc or initproc.\n");
ffffffffc02048ee:	00003617          	auipc	a2,0x3
ffffffffc02048f2:	96260613          	addi	a2,a2,-1694 # ffffffffc0207250 <etext+0x18d2>
ffffffffc02048f6:	35700593          	li	a1,855
ffffffffc02048fa:	00003517          	auipc	a0,0x3
ffffffffc02048fe:	8b650513          	addi	a0,a0,-1866 # ffffffffc02071b0 <etext+0x1832>
ffffffffc0204902:	b45fb0ef          	jal	ffffffffc0200446 <__panic>
        panic("pa2page called with invalid pa");
ffffffffc0204906:	00002617          	auipc	a2,0x2
ffffffffc020490a:	ef260613          	addi	a2,a2,-270 # ffffffffc02067f8 <etext+0xe7a>
ffffffffc020490e:	06900593          	li	a1,105
ffffffffc0204912:	00002517          	auipc	a0,0x2
ffffffffc0204916:	e3e50513          	addi	a0,a0,-450 # ffffffffc0206750 <etext+0xdd2>
ffffffffc020491a:	b2dfb0ef          	jal	ffffffffc0200446 <__panic>
    return pa2page(PADDR(kva));
ffffffffc020491e:	00002617          	auipc	a2,0x2
ffffffffc0204922:	eb260613          	addi	a2,a2,-334 # ffffffffc02067d0 <etext+0xe52>
ffffffffc0204926:	07700593          	li	a1,119
ffffffffc020492a:	00002517          	auipc	a0,0x2
ffffffffc020492e:	e2650513          	addi	a0,a0,-474 # ffffffffc0206750 <etext+0xdd2>
ffffffffc0204932:	b15fb0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0204936 <init_main>:
}

// init_main - the second kernel thread used to create user_main kernel threads
static int
init_main(void *arg)
{
ffffffffc0204936:	1141                	addi	sp,sp,-16
ffffffffc0204938:	e406                	sd	ra,8(sp)
    size_t nr_free_pages_store = nr_free_pages();
ffffffffc020493a:	eacfd0ef          	jal	ffffffffc0201fe6 <nr_free_pages>
    size_t kernel_allocated_store = kallocated();
ffffffffc020493e:	c6efd0ef          	jal	ffffffffc0201dac <kallocated>

    int pid = kernel_thread(user_main, NULL, 0);
ffffffffc0204942:	4601                	li	a2,0
ffffffffc0204944:	4581                	li	a1,0
ffffffffc0204946:	fffff517          	auipc	a0,0xfffff
ffffffffc020494a:	6dc50513          	addi	a0,a0,1756 # ffffffffc0204022 <user_main>
ffffffffc020494e:	c73ff0ef          	jal	ffffffffc02045c0 <kernel_thread>
    if (pid <= 0)
ffffffffc0204952:	00a04563          	bgtz	a0,ffffffffc020495c <init_main+0x26>
ffffffffc0204956:	a071                	j	ffffffffc02049e2 <init_main+0xac>
        panic("create user_main failed.\n");
    }

    while (do_wait(0, NULL) == 0)
    {
        schedule();
ffffffffc0204958:	1ff000ef          	jal	ffffffffc0205356 <schedule>
    if (code_store != NULL)
ffffffffc020495c:	4581                	li	a1,0
ffffffffc020495e:	4501                	li	a0,0
ffffffffc0204960:	df5ff0ef          	jal	ffffffffc0204754 <do_wait.part.0>
    while (do_wait(0, NULL) == 0)
ffffffffc0204964:	d975                	beqz	a0,ffffffffc0204958 <init_main+0x22>
    }

    cprintf("all user-mode processes have quit.\n");
ffffffffc0204966:	00003517          	auipc	a0,0x3
ffffffffc020496a:	92a50513          	addi	a0,a0,-1750 # ffffffffc0207290 <etext+0x1912>
ffffffffc020496e:	827fb0ef          	jal	ffffffffc0200194 <cprintf>
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc0204972:	00097797          	auipc	a5,0x97
ffffffffc0204976:	e367b783          	ld	a5,-458(a5) # ffffffffc029b7a8 <initproc>
ffffffffc020497a:	7bf8                	ld	a4,240(a5)
ffffffffc020497c:	e339                	bnez	a4,ffffffffc02049c2 <init_main+0x8c>
ffffffffc020497e:	7ff8                	ld	a4,248(a5)
ffffffffc0204980:	e329                	bnez	a4,ffffffffc02049c2 <init_main+0x8c>
ffffffffc0204982:	1007b703          	ld	a4,256(a5)
ffffffffc0204986:	ef15                	bnez	a4,ffffffffc02049c2 <init_main+0x8c>
    assert(nr_process == 2);
ffffffffc0204988:	00097697          	auipc	a3,0x97
ffffffffc020498c:	e146a683          	lw	a3,-492(a3) # ffffffffc029b79c <nr_process>
ffffffffc0204990:	4709                	li	a4,2
ffffffffc0204992:	0ae69463          	bne	a3,a4,ffffffffc0204a3a <init_main+0x104>
ffffffffc0204996:	00097697          	auipc	a3,0x97
ffffffffc020499a:	d9268693          	addi	a3,a3,-622 # ffffffffc029b728 <proc_list>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc020499e:	6698                	ld	a4,8(a3)
ffffffffc02049a0:	0c878793          	addi	a5,a5,200
ffffffffc02049a4:	06f71b63          	bne	a4,a5,ffffffffc0204a1a <init_main+0xe4>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02049a8:	629c                	ld	a5,0(a3)
ffffffffc02049aa:	04f71863          	bne	a4,a5,ffffffffc02049fa <init_main+0xc4>

    cprintf("init check memory pass.\n");
ffffffffc02049ae:	00003517          	auipc	a0,0x3
ffffffffc02049b2:	9ca50513          	addi	a0,a0,-1590 # ffffffffc0207378 <etext+0x19fa>
ffffffffc02049b6:	fdefb0ef          	jal	ffffffffc0200194 <cprintf>
    return 0;
}
ffffffffc02049ba:	60a2                	ld	ra,8(sp)
ffffffffc02049bc:	4501                	li	a0,0
ffffffffc02049be:	0141                	addi	sp,sp,16
ffffffffc02049c0:	8082                	ret
    assert(initproc->cptr == NULL && initproc->yptr == NULL && initproc->optr == NULL);
ffffffffc02049c2:	00003697          	auipc	a3,0x3
ffffffffc02049c6:	8f668693          	addi	a3,a3,-1802 # ffffffffc02072b8 <etext+0x193a>
ffffffffc02049ca:	00002617          	auipc	a2,0x2
ffffffffc02049ce:	9ae60613          	addi	a2,a2,-1618 # ffffffffc0206378 <etext+0x9fa>
ffffffffc02049d2:	3c500593          	li	a1,965
ffffffffc02049d6:	00002517          	auipc	a0,0x2
ffffffffc02049da:	7da50513          	addi	a0,a0,2010 # ffffffffc02071b0 <etext+0x1832>
ffffffffc02049de:	a69fb0ef          	jal	ffffffffc0200446 <__panic>
        panic("create user_main failed.\n");
ffffffffc02049e2:	00003617          	auipc	a2,0x3
ffffffffc02049e6:	88e60613          	addi	a2,a2,-1906 # ffffffffc0207270 <etext+0x18f2>
ffffffffc02049ea:	3bc00593          	li	a1,956
ffffffffc02049ee:	00002517          	auipc	a0,0x2
ffffffffc02049f2:	7c250513          	addi	a0,a0,1986 # ffffffffc02071b0 <etext+0x1832>
ffffffffc02049f6:	a51fb0ef          	jal	ffffffffc0200446 <__panic>
    assert(list_prev(&proc_list) == &(initproc->list_link));
ffffffffc02049fa:	00003697          	auipc	a3,0x3
ffffffffc02049fe:	94e68693          	addi	a3,a3,-1714 # ffffffffc0207348 <etext+0x19ca>
ffffffffc0204a02:	00002617          	auipc	a2,0x2
ffffffffc0204a06:	97660613          	addi	a2,a2,-1674 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0204a0a:	3c800593          	li	a1,968
ffffffffc0204a0e:	00002517          	auipc	a0,0x2
ffffffffc0204a12:	7a250513          	addi	a0,a0,1954 # ffffffffc02071b0 <etext+0x1832>
ffffffffc0204a16:	a31fb0ef          	jal	ffffffffc0200446 <__panic>
    assert(list_next(&proc_list) == &(initproc->list_link));
ffffffffc0204a1a:	00003697          	auipc	a3,0x3
ffffffffc0204a1e:	8fe68693          	addi	a3,a3,-1794 # ffffffffc0207318 <etext+0x199a>
ffffffffc0204a22:	00002617          	auipc	a2,0x2
ffffffffc0204a26:	95660613          	addi	a2,a2,-1706 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0204a2a:	3c700593          	li	a1,967
ffffffffc0204a2e:	00002517          	auipc	a0,0x2
ffffffffc0204a32:	78250513          	addi	a0,a0,1922 # ffffffffc02071b0 <etext+0x1832>
ffffffffc0204a36:	a11fb0ef          	jal	ffffffffc0200446 <__panic>
    assert(nr_process == 2);
ffffffffc0204a3a:	00003697          	auipc	a3,0x3
ffffffffc0204a3e:	8ce68693          	addi	a3,a3,-1842 # ffffffffc0207308 <etext+0x198a>
ffffffffc0204a42:	00002617          	auipc	a2,0x2
ffffffffc0204a46:	93660613          	addi	a2,a2,-1738 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0204a4a:	3c600593          	li	a1,966
ffffffffc0204a4e:	00002517          	auipc	a0,0x2
ffffffffc0204a52:	76250513          	addi	a0,a0,1890 # ffffffffc02071b0 <etext+0x1832>
ffffffffc0204a56:	9f1fb0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0204a5a <do_execve>:
{
ffffffffc0204a5a:	7171                	addi	sp,sp,-176
ffffffffc0204a5c:	e8ea                	sd	s10,80(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204a5e:	00097d17          	auipc	s10,0x97
ffffffffc0204a62:	d42d0d13          	addi	s10,s10,-702 # ffffffffc029b7a0 <current>
ffffffffc0204a66:	000d3783          	ld	a5,0(s10)
{
ffffffffc0204a6a:	ed26                	sd	s1,152(sp)
ffffffffc0204a6c:	f122                	sd	s0,160(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204a6e:	7784                	ld	s1,40(a5)
{
ffffffffc0204a70:	842e                	mv	s0,a1
ffffffffc0204a72:	e94a                	sd	s2,144(sp)
ffffffffc0204a74:	ec32                	sd	a2,24(sp)
ffffffffc0204a76:	892a                	mv	s2,a0
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204a78:	85aa                	mv	a1,a0
ffffffffc0204a7a:	8622                	mv	a2,s0
ffffffffc0204a7c:	8526                	mv	a0,s1
ffffffffc0204a7e:	4681                	li	a3,0
{
ffffffffc0204a80:	f506                	sd	ra,168(sp)
    if (!user_mem_check(mm, (uintptr_t)name, len, 0))
ffffffffc0204a82:	be0ff0ef          	jal	ffffffffc0203e62 <user_mem_check>
ffffffffc0204a86:	46050363          	beqz	a0,ffffffffc0204eec <do_execve+0x492>
    memset(local_name, 0, sizeof(local_name));
ffffffffc0204a8a:	4641                	li	a2,16
ffffffffc0204a8c:	1808                	addi	a0,sp,48
ffffffffc0204a8e:	4581                	li	a1,0
ffffffffc0204a90:	6c5000ef          	jal	ffffffffc0205954 <memset>
    if (len > PROC_NAME_LEN)
ffffffffc0204a94:	47bd                	li	a5,15
ffffffffc0204a96:	8622                	mv	a2,s0
ffffffffc0204a98:	0e87ec63          	bltu	a5,s0,ffffffffc0204b90 <do_execve+0x136>
    memcpy(local_name, name, len);
ffffffffc0204a9c:	85ca                	mv	a1,s2
ffffffffc0204a9e:	1808                	addi	a0,sp,48
ffffffffc0204aa0:	6c7000ef          	jal	ffffffffc0205966 <memcpy>
    if (mm != NULL)
ffffffffc0204aa4:	0e048d63          	beqz	s1,ffffffffc0204b9e <do_execve+0x144>
        cputs("mm != NULL");
ffffffffc0204aa8:	00002517          	auipc	a0,0x2
ffffffffc0204aac:	47850513          	addi	a0,a0,1144 # ffffffffc0206f20 <etext+0x15a2>
ffffffffc0204ab0:	f1afb0ef          	jal	ffffffffc02001ca <cputs>
ffffffffc0204ab4:	00097797          	auipc	a5,0x97
ffffffffc0204ab8:	cbc7b783          	ld	a5,-836(a5) # ffffffffc029b770 <boot_pgdir_pa>
ffffffffc0204abc:	577d                	li	a4,-1
ffffffffc0204abe:	177e                	slli	a4,a4,0x3f
ffffffffc0204ac0:	83b1                	srli	a5,a5,0xc
ffffffffc0204ac2:	8fd9                	or	a5,a5,a4
ffffffffc0204ac4:	18079073          	csrw	satp,a5
ffffffffc0204ac8:	589c                	lw	a5,48(s1)
ffffffffc0204aca:	37fd                	addiw	a5,a5,-1
ffffffffc0204acc:	d89c                	sw	a5,48(s1)
        if (mm_count_dec(mm) == 0)
ffffffffc0204ace:	2e078c63          	beqz	a5,ffffffffc0204dc6 <do_execve+0x36c>
        current->mm = NULL;
ffffffffc0204ad2:	000d3783          	ld	a5,0(s10)
ffffffffc0204ad6:	0207b423          	sd	zero,40(a5)
    if ((mm = mm_create()) == NULL)
ffffffffc0204ada:	cfdfe0ef          	jal	ffffffffc02037d6 <mm_create>
ffffffffc0204ade:	84aa                	mv	s1,a0
ffffffffc0204ae0:	20050863          	beqz	a0,ffffffffc0204cf0 <do_execve+0x296>
    if ((page = alloc_page()) == NULL)
ffffffffc0204ae4:	4505                	li	a0,1
ffffffffc0204ae6:	c8efd0ef          	jal	ffffffffc0201f74 <alloc_pages>
ffffffffc0204aea:	40050663          	beqz	a0,ffffffffc0204ef6 <do_execve+0x49c>
    return page - pages + nbase;
ffffffffc0204aee:	f4de                	sd	s7,104(sp)
ffffffffc0204af0:	00097b97          	auipc	s7,0x97
ffffffffc0204af4:	ca0b8b93          	addi	s7,s7,-864 # ffffffffc029b790 <pages>
ffffffffc0204af8:	000bb783          	ld	a5,0(s7)
ffffffffc0204afc:	f8da                	sd	s6,112(sp)
ffffffffc0204afe:	00003b17          	auipc	s6,0x3
ffffffffc0204b02:	05ab3b03          	ld	s6,90(s6) # ffffffffc0207b58 <nbase>
ffffffffc0204b06:	40f506b3          	sub	a3,a0,a5
ffffffffc0204b0a:	f0e2                	sd	s8,96(sp)
    return KADDR(page2pa(page));
ffffffffc0204b0c:	00097c17          	auipc	s8,0x97
ffffffffc0204b10:	c7cc0c13          	addi	s8,s8,-900 # ffffffffc029b788 <npage>
ffffffffc0204b14:	fcd6                	sd	s5,120(sp)
    return page - pages + nbase;
ffffffffc0204b16:	8699                	srai	a3,a3,0x6
    return KADDR(page2pa(page));
ffffffffc0204b18:	5afd                	li	s5,-1
ffffffffc0204b1a:	000c3783          	ld	a5,0(s8)
    return page - pages + nbase;
ffffffffc0204b1e:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc0204b20:	00cad713          	srli	a4,s5,0xc
ffffffffc0204b24:	e83a                	sd	a4,16(sp)
ffffffffc0204b26:	e152                	sd	s4,128(sp)
ffffffffc0204b28:	8f75                	and	a4,a4,a3
    return page2ppn(page) << PGSHIFT;
ffffffffc0204b2a:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204b2c:	3ef77863          	bgeu	a4,a5,ffffffffc0204f1c <do_execve+0x4c2>
ffffffffc0204b30:	00097a17          	auipc	s4,0x97
ffffffffc0204b34:	c50a0a13          	addi	s4,s4,-944 # ffffffffc029b780 <va_pa_offset>
ffffffffc0204b38:	000a3783          	ld	a5,0(s4)
    memcpy(pgdir, boot_pgdir_va, PGSIZE);
ffffffffc0204b3c:	00097597          	auipc	a1,0x97
ffffffffc0204b40:	c3c5b583          	ld	a1,-964(a1) # ffffffffc029b778 <boot_pgdir_va>
ffffffffc0204b44:	6605                	lui	a2,0x1
ffffffffc0204b46:	00f68433          	add	s0,a3,a5
ffffffffc0204b4a:	8522                	mv	a0,s0
ffffffffc0204b4c:	61b000ef          	jal	ffffffffc0205966 <memcpy>
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204b50:	66e2                	ld	a3,24(sp)
ffffffffc0204b52:	464c47b7          	lui	a5,0x464c4
    mm->pgdir = pgdir;
ffffffffc0204b56:	ec80                	sd	s0,24(s1)
    if (elf->e_magic != ELF_MAGIC)
ffffffffc0204b58:	4298                	lw	a4,0(a3)
ffffffffc0204b5a:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_obj___user_exit_out_size+0x464ba3bf>
ffffffffc0204b5e:	06f70863          	beq	a4,a5,ffffffffc0204bce <do_execve+0x174>
        ret = -E_INVAL_ELF;
ffffffffc0204b62:	5461                	li	s0,-8
    put_pgdir(mm);
ffffffffc0204b64:	8526                	mv	a0,s1
ffffffffc0204b66:	d3aff0ef          	jal	ffffffffc02040a0 <put_pgdir>
ffffffffc0204b6a:	6a0a                	ld	s4,128(sp)
ffffffffc0204b6c:	7ae6                	ld	s5,120(sp)
ffffffffc0204b6e:	7b46                	ld	s6,112(sp)
ffffffffc0204b70:	7ba6                	ld	s7,104(sp)
ffffffffc0204b72:	7c06                	ld	s8,96(sp)
    mm_destroy(mm);
ffffffffc0204b74:	8526                	mv	a0,s1
ffffffffc0204b76:	d9ffe0ef          	jal	ffffffffc0203914 <mm_destroy>
    do_exit(ret);
ffffffffc0204b7a:	8522                	mv	a0,s0
ffffffffc0204b7c:	e54e                	sd	s3,136(sp)
ffffffffc0204b7e:	e152                	sd	s4,128(sp)
ffffffffc0204b80:	fcd6                	sd	s5,120(sp)
ffffffffc0204b82:	f8da                	sd	s6,112(sp)
ffffffffc0204b84:	f4de                	sd	s7,104(sp)
ffffffffc0204b86:	f0e2                	sd	s8,96(sp)
ffffffffc0204b88:	ece6                	sd	s9,88(sp)
ffffffffc0204b8a:	e4ee                	sd	s11,72(sp)
ffffffffc0204b8c:	a85ff0ef          	jal	ffffffffc0204610 <do_exit>
    if (len > PROC_NAME_LEN)
ffffffffc0204b90:	863e                	mv	a2,a5
    memcpy(local_name, name, len);
ffffffffc0204b92:	85ca                	mv	a1,s2
ffffffffc0204b94:	1808                	addi	a0,sp,48
ffffffffc0204b96:	5d1000ef          	jal	ffffffffc0205966 <memcpy>
    if (mm != NULL)
ffffffffc0204b9a:	f00497e3          	bnez	s1,ffffffffc0204aa8 <do_execve+0x4e>
    if (current->mm != NULL)
ffffffffc0204b9e:	000d3783          	ld	a5,0(s10)
ffffffffc0204ba2:	779c                	ld	a5,40(a5)
ffffffffc0204ba4:	db9d                	beqz	a5,ffffffffc0204ada <do_execve+0x80>
        panic("load_icode: current->mm must be empty.\n");
ffffffffc0204ba6:	00002617          	auipc	a2,0x2
ffffffffc0204baa:	7f260613          	addi	a2,a2,2034 # ffffffffc0207398 <etext+0x1a1a>
ffffffffc0204bae:	24300593          	li	a1,579
ffffffffc0204bb2:	00002517          	auipc	a0,0x2
ffffffffc0204bb6:	5fe50513          	addi	a0,a0,1534 # ffffffffc02071b0 <etext+0x1832>
ffffffffc0204bba:	e54e                	sd	s3,136(sp)
ffffffffc0204bbc:	e152                	sd	s4,128(sp)
ffffffffc0204bbe:	fcd6                	sd	s5,120(sp)
ffffffffc0204bc0:	f8da                	sd	s6,112(sp)
ffffffffc0204bc2:	f4de                	sd	s7,104(sp)
ffffffffc0204bc4:	f0e2                	sd	s8,96(sp)
ffffffffc0204bc6:	ece6                	sd	s9,88(sp)
ffffffffc0204bc8:	e4ee                	sd	s11,72(sp)
ffffffffc0204bca:	87dfb0ef          	jal	ffffffffc0200446 <__panic>
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204bce:	0386d703          	lhu	a4,56(a3)
ffffffffc0204bd2:	e54e                	sd	s3,136(sp)
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204bd4:	0206b983          	ld	s3,32(a3)
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204bd8:	00371793          	slli	a5,a4,0x3
ffffffffc0204bdc:	8f99                	sub	a5,a5,a4
ffffffffc0204bde:	078e                	slli	a5,a5,0x3
    struct proghdr *ph = (struct proghdr *)(binary + elf->e_phoff);
ffffffffc0204be0:	99b6                	add	s3,s3,a3
    struct proghdr *ph_end = ph + elf->e_phnum;
ffffffffc0204be2:	97ce                	add	a5,a5,s3
ffffffffc0204be4:	ece6                	sd	s9,88(sp)
ffffffffc0204be6:	f43e                	sd	a5,40(sp)
    struct Page *page = NULL;
ffffffffc0204be8:	4c81                	li	s9,0
    for (; ph < ph_end; ph++)
ffffffffc0204bea:	00f9fe63          	bgeu	s3,a5,ffffffffc0204c06 <do_execve+0x1ac>
ffffffffc0204bee:	e4ee                	sd	s11,72(sp)
        if (ph->p_type != ELF_PT_LOAD)
ffffffffc0204bf0:	0009a783          	lw	a5,0(s3)
ffffffffc0204bf4:	4705                	li	a4,1
ffffffffc0204bf6:	0ee78f63          	beq	a5,a4,ffffffffc0204cf4 <do_execve+0x29a>
    for (; ph < ph_end; ph++)
ffffffffc0204bfa:	77a2                	ld	a5,40(sp)
ffffffffc0204bfc:	03898993          	addi	s3,s3,56
ffffffffc0204c00:	fef9e8e3          	bltu	s3,a5,ffffffffc0204bf0 <do_execve+0x196>
ffffffffc0204c04:	6da6                	ld	s11,72(sp)
    if ((ret = mm_map(mm, USTACKTOP - USTACKSIZE, USTACKSIZE, vm_flags, NULL)) != 0)
ffffffffc0204c06:	4701                	li	a4,0
ffffffffc0204c08:	46ad                	li	a3,11
ffffffffc0204c0a:	00100637          	lui	a2,0x100
ffffffffc0204c0e:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0204c12:	8526                	mv	a0,s1
ffffffffc0204c14:	d53fe0ef          	jal	ffffffffc0203966 <mm_map>
ffffffffc0204c18:	842a                	mv	s0,a0
ffffffffc0204c1a:	1a051063          	bnez	a0,ffffffffc0204dba <do_execve+0x360>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204c1e:	6c88                	ld	a0,24(s1)
ffffffffc0204c20:	467d                	li	a2,31
ffffffffc0204c22:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc0204c26:	acffe0ef          	jal	ffffffffc02036f4 <pgdir_alloc_page>
ffffffffc0204c2a:	38050863          	beqz	a0,ffffffffc0204fba <do_execve+0x560>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204c2e:	6c88                	ld	a0,24(s1)
ffffffffc0204c30:	467d                	li	a2,31
ffffffffc0204c32:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc0204c36:	abffe0ef          	jal	ffffffffc02036f4 <pgdir_alloc_page>
ffffffffc0204c3a:	34050f63          	beqz	a0,ffffffffc0204f98 <do_execve+0x53e>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204c3e:	6c88                	ld	a0,24(s1)
ffffffffc0204c40:	467d                	li	a2,31
ffffffffc0204c42:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc0204c46:	aaffe0ef          	jal	ffffffffc02036f4 <pgdir_alloc_page>
ffffffffc0204c4a:	32050663          	beqz	a0,ffffffffc0204f76 <do_execve+0x51c>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204c4e:	6c88                	ld	a0,24(s1)
ffffffffc0204c50:	467d                	li	a2,31
ffffffffc0204c52:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc0204c56:	a9ffe0ef          	jal	ffffffffc02036f4 <pgdir_alloc_page>
ffffffffc0204c5a:	2e050d63          	beqz	a0,ffffffffc0204f54 <do_execve+0x4fa>
    mm->mm_count += 1;
ffffffffc0204c5e:	589c                	lw	a5,48(s1)
    current->mm = mm;
ffffffffc0204c60:	000d3603          	ld	a2,0(s10)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204c64:	6c94                	ld	a3,24(s1)
ffffffffc0204c66:	2785                	addiw	a5,a5,1
ffffffffc0204c68:	d89c                	sw	a5,48(s1)
    current->mm = mm;
ffffffffc0204c6a:	f604                	sd	s1,40(a2)
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204c6c:	c02007b7          	lui	a5,0xc0200
ffffffffc0204c70:	2cf6e563          	bltu	a3,a5,ffffffffc0204f3a <do_execve+0x4e0>
ffffffffc0204c74:	000a3783          	ld	a5,0(s4)
ffffffffc0204c78:	577d                	li	a4,-1
ffffffffc0204c7a:	177e                	slli	a4,a4,0x3f
ffffffffc0204c7c:	8e9d                	sub	a3,a3,a5
ffffffffc0204c7e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0204c82:	f654                	sd	a3,168(a2)
ffffffffc0204c84:	8fd9                	or	a5,a5,a4
ffffffffc0204c86:	18079073          	csrw	satp,a5
    struct trapframe *tf = current->tf;
ffffffffc0204c8a:	7244                	ld	s1,160(a2)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204c8c:	4581                	li	a1,0
ffffffffc0204c8e:	12000613          	li	a2,288
ffffffffc0204c92:	8526                	mv	a0,s1
    uintptr_t sstatus = tf->status;
ffffffffc0204c94:	1004b903          	ld	s2,256(s1)
    memset(tf, 0, sizeof(struct trapframe));
ffffffffc0204c98:	4bd000ef          	jal	ffffffffc0205954 <memset>
    tf->epc = elf->e_entry;
ffffffffc0204c9c:	67e2                	ld	a5,24(sp)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204c9e:	000d3983          	ld	s3,0(s10)
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204ca2:	edf97913          	andi	s2,s2,-289
    tf->epc = elf->e_entry;
ffffffffc0204ca6:	6f98                	ld	a4,24(a5)
    tf->gpr.sp = USTACKTOP;
ffffffffc0204ca8:	4785                	li	a5,1
ffffffffc0204caa:	07fe                	slli	a5,a5,0x1f
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204cac:	02096913          	ori	s2,s2,32
    tf->epc = elf->e_entry;
ffffffffc0204cb0:	10e4b423          	sd	a4,264(s1)
    tf->gpr.sp = USTACKTOP;
ffffffffc0204cb4:	e89c                	sd	a5,16(s1)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204cb6:	0b498513          	addi	a0,s3,180
ffffffffc0204cba:	4641                	li	a2,16
ffffffffc0204cbc:	4581                	li	a1,0
    tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
ffffffffc0204cbe:	1124b023          	sd	s2,256(s1)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc0204cc2:	493000ef          	jal	ffffffffc0205954 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0204cc6:	0b498513          	addi	a0,s3,180
ffffffffc0204cca:	180c                	addi	a1,sp,48
ffffffffc0204ccc:	463d                	li	a2,15
ffffffffc0204cce:	499000ef          	jal	ffffffffc0205966 <memcpy>
ffffffffc0204cd2:	69aa                	ld	s3,136(sp)
ffffffffc0204cd4:	6a0a                	ld	s4,128(sp)
ffffffffc0204cd6:	7ae6                	ld	s5,120(sp)
ffffffffc0204cd8:	7b46                	ld	s6,112(sp)
ffffffffc0204cda:	7ba6                	ld	s7,104(sp)
ffffffffc0204cdc:	7c06                	ld	s8,96(sp)
ffffffffc0204cde:	6ce6                	ld	s9,88(sp)
}
ffffffffc0204ce0:	70aa                	ld	ra,168(sp)
ffffffffc0204ce2:	8522                	mv	a0,s0
ffffffffc0204ce4:	740a                	ld	s0,160(sp)
ffffffffc0204ce6:	64ea                	ld	s1,152(sp)
ffffffffc0204ce8:	694a                	ld	s2,144(sp)
ffffffffc0204cea:	6d46                	ld	s10,80(sp)
ffffffffc0204cec:	614d                	addi	sp,sp,176
ffffffffc0204cee:	8082                	ret
    int ret = -E_NO_MEM;
ffffffffc0204cf0:	5471                	li	s0,-4
ffffffffc0204cf2:	b561                	j	ffffffffc0204b7a <do_execve+0x120>
        if (ph->p_filesz > ph->p_memsz)
ffffffffc0204cf4:	0289b603          	ld	a2,40(s3)
ffffffffc0204cf8:	0209b783          	ld	a5,32(s3)
ffffffffc0204cfc:	20f66163          	bltu	a2,a5,ffffffffc0204efe <do_execve+0x4a4>
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204d00:	0049a783          	lw	a5,4(s3)
ffffffffc0204d04:	0027971b          	slliw	a4,a5,0x2
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204d08:	0027f693          	andi	a3,a5,2
        if (ph->p_flags & ELF_PF_X)
ffffffffc0204d0c:	8b11                	andi	a4,a4,4
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204d0e:	8b91                	andi	a5,a5,4
        if (ph->p_flags & ELF_PF_W)
ffffffffc0204d10:	c6e9                	beqz	a3,ffffffffc0204dda <do_execve+0x380>
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204d12:	1c079563          	bnez	a5,ffffffffc0204edc <do_execve+0x482>
            perm |= (PTE_W | PTE_R);
ffffffffc0204d16:	47dd                	li	a5,23
            vm_flags |= VM_WRITE;
ffffffffc0204d18:	00276693          	ori	a3,a4,2
            perm |= (PTE_W | PTE_R);
ffffffffc0204d1c:	e43e                	sd	a5,8(sp)
        if (vm_flags & VM_EXEC)
ffffffffc0204d1e:	c709                	beqz	a4,ffffffffc0204d28 <do_execve+0x2ce>
            perm |= PTE_X;
ffffffffc0204d20:	67a2                	ld	a5,8(sp)
ffffffffc0204d22:	0087e793          	ori	a5,a5,8
ffffffffc0204d26:	e43e                	sd	a5,8(sp)
        if ((ret = mm_map(mm, ph->p_va, ph->p_memsz, vm_flags, NULL)) != 0)
ffffffffc0204d28:	0109b583          	ld	a1,16(s3)
ffffffffc0204d2c:	4701                	li	a4,0
ffffffffc0204d2e:	8526                	mv	a0,s1
ffffffffc0204d30:	c37fe0ef          	jal	ffffffffc0203966 <mm_map>
ffffffffc0204d34:	842a                	mv	s0,a0
ffffffffc0204d36:	1c051263          	bnez	a0,ffffffffc0204efa <do_execve+0x4a0>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204d3a:	0109ba83          	ld	s5,16(s3)
        end = ph->p_va + ph->p_filesz;
ffffffffc0204d3e:	0209b403          	ld	s0,32(s3)
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204d42:	77fd                	lui	a5,0xfffff
ffffffffc0204d44:	00faf5b3          	and	a1,s5,a5
        end = ph->p_va + ph->p_filesz;
ffffffffc0204d48:	9456                	add	s0,s0,s5
        while (start < end)
ffffffffc0204d4a:	1a8af363          	bgeu	s5,s0,ffffffffc0204ef0 <do_execve+0x496>
        unsigned char *from = binary + ph->p_offset;
ffffffffc0204d4e:	0089b903          	ld	s2,8(s3)
ffffffffc0204d52:	67e2                	ld	a5,24(sp)
ffffffffc0204d54:	993e                	add	s2,s2,a5
ffffffffc0204d56:	a881                	j	ffffffffc0204da6 <do_execve+0x34c>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204d58:	6785                	lui	a5,0x1
ffffffffc0204d5a:	00f58db3          	add	s11,a1,a5
                size -= la - end;
ffffffffc0204d5e:	41540633          	sub	a2,s0,s5
            if (end < la)
ffffffffc0204d62:	01b46463          	bltu	s0,s11,ffffffffc0204d6a <do_execve+0x310>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204d66:	415d8633          	sub	a2,s11,s5
    return page - pages + nbase;
ffffffffc0204d6a:	000bb683          	ld	a3,0(s7)
    return KADDR(page2pa(page));
ffffffffc0204d6e:	67c2                	ld	a5,16(sp)
ffffffffc0204d70:	000c3503          	ld	a0,0(s8)
    return page - pages + nbase;
ffffffffc0204d74:	40dc86b3          	sub	a3,s9,a3
ffffffffc0204d78:	8699                	srai	a3,a3,0x6
ffffffffc0204d7a:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc0204d7c:	00f6f8b3          	and	a7,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204d80:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204d82:	18a8f163          	bgeu	a7,a0,ffffffffc0204f04 <do_execve+0x4aa>
ffffffffc0204d86:	000a3503          	ld	a0,0(s4)
ffffffffc0204d8a:	40ba85b3          	sub	a1,s5,a1
            memcpy(page2kva(page) + off, from, size);
ffffffffc0204d8e:	e032                	sd	a2,0(sp)
ffffffffc0204d90:	9536                	add	a0,a0,a3
ffffffffc0204d92:	952e                	add	a0,a0,a1
ffffffffc0204d94:	85ca                	mv	a1,s2
ffffffffc0204d96:	3d1000ef          	jal	ffffffffc0205966 <memcpy>
            start += size, from += size;
ffffffffc0204d9a:	6602                	ld	a2,0(sp)
ffffffffc0204d9c:	9ab2                	add	s5,s5,a2
ffffffffc0204d9e:	9932                	add	s2,s2,a2
        while (start < end)
ffffffffc0204da0:	048af463          	bgeu	s5,s0,ffffffffc0204de8 <do_execve+0x38e>
ffffffffc0204da4:	85ee                	mv	a1,s11
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204da6:	6c88                	ld	a0,24(s1)
ffffffffc0204da8:	6622                	ld	a2,8(sp)
ffffffffc0204daa:	e02e                	sd	a1,0(sp)
ffffffffc0204dac:	949fe0ef          	jal	ffffffffc02036f4 <pgdir_alloc_page>
ffffffffc0204db0:	6582                	ld	a1,0(sp)
ffffffffc0204db2:	8caa                	mv	s9,a0
ffffffffc0204db4:	f155                	bnez	a0,ffffffffc0204d58 <do_execve+0x2fe>
ffffffffc0204db6:	6da6                	ld	s11,72(sp)
        ret = -E_NO_MEM;
ffffffffc0204db8:	5471                	li	s0,-4
    exit_mmap(mm);
ffffffffc0204dba:	8526                	mv	a0,s1
ffffffffc0204dbc:	d0ffe0ef          	jal	ffffffffc0203aca <exit_mmap>
ffffffffc0204dc0:	69aa                	ld	s3,136(sp)
ffffffffc0204dc2:	6ce6                	ld	s9,88(sp)
ffffffffc0204dc4:	b345                	j	ffffffffc0204b64 <do_execve+0x10a>
            exit_mmap(mm);
ffffffffc0204dc6:	8526                	mv	a0,s1
ffffffffc0204dc8:	d03fe0ef          	jal	ffffffffc0203aca <exit_mmap>
            put_pgdir(mm);
ffffffffc0204dcc:	8526                	mv	a0,s1
ffffffffc0204dce:	ad2ff0ef          	jal	ffffffffc02040a0 <put_pgdir>
            mm_destroy(mm);
ffffffffc0204dd2:	8526                	mv	a0,s1
ffffffffc0204dd4:	b41fe0ef          	jal	ffffffffc0203914 <mm_destroy>
ffffffffc0204dd8:	b9ed                	j	ffffffffc0204ad2 <do_execve+0x78>
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204dda:	0e078d63          	beqz	a5,ffffffffc0204ed4 <do_execve+0x47a>
            perm |= PTE_R;
ffffffffc0204dde:	47cd                	li	a5,19
            vm_flags |= VM_READ;
ffffffffc0204de0:	00176693          	ori	a3,a4,1
            perm |= PTE_R;
ffffffffc0204de4:	e43e                	sd	a5,8(sp)
ffffffffc0204de6:	bf25                	j	ffffffffc0204d1e <do_execve+0x2c4>
        end = ph->p_va + ph->p_memsz;
ffffffffc0204de8:	0109b403          	ld	s0,16(s3)
ffffffffc0204dec:	0289b683          	ld	a3,40(s3)
ffffffffc0204df0:	9436                	add	s0,s0,a3
        if (start < la)
ffffffffc0204df2:	07bafc63          	bgeu	s5,s11,ffffffffc0204e6a <do_execve+0x410>
            if (start == end)
ffffffffc0204df6:	e15402e3          	beq	s0,s5,ffffffffc0204bfa <do_execve+0x1a0>
                size -= la - end;
ffffffffc0204dfa:	41540933          	sub	s2,s0,s5
            if (end < la)
ffffffffc0204dfe:	0fb47463          	bgeu	s0,s11,ffffffffc0204ee6 <do_execve+0x48c>
    return page - pages + nbase;
ffffffffc0204e02:	000bb683          	ld	a3,0(s7)
    return KADDR(page2pa(page));
ffffffffc0204e06:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204e0a:	40dc86b3          	sub	a3,s9,a3
ffffffffc0204e0e:	8699                	srai	a3,a3,0x6
ffffffffc0204e10:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc0204e12:	00c69613          	slli	a2,a3,0xc
ffffffffc0204e16:	8231                	srli	a2,a2,0xc
    return page2ppn(page) << PGSHIFT;
ffffffffc0204e18:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204e1a:	0eb67563          	bgeu	a2,a1,ffffffffc0204f04 <do_execve+0x4aa>
ffffffffc0204e1e:	000a3603          	ld	a2,0(s4)
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204e22:	6505                	lui	a0,0x1
ffffffffc0204e24:	9556                	add	a0,a0,s5
ffffffffc0204e26:	96b2                	add	a3,a3,a2
ffffffffc0204e28:	41b50533          	sub	a0,a0,s11
            memset(page2kva(page) + off, 0, size);
ffffffffc0204e2c:	9536                	add	a0,a0,a3
ffffffffc0204e2e:	864a                	mv	a2,s2
ffffffffc0204e30:	4581                	li	a1,0
ffffffffc0204e32:	323000ef          	jal	ffffffffc0205954 <memset>
            start += size;
ffffffffc0204e36:	9aca                	add	s5,s5,s2
            assert((end < la && start == end) || (end >= la && start == la));
ffffffffc0204e38:	01b436b3          	sltu	a3,s0,s11
ffffffffc0204e3c:	01b47463          	bgeu	s0,s11,ffffffffc0204e44 <do_execve+0x3ea>
ffffffffc0204e40:	db540de3          	beq	s0,s5,ffffffffc0204bfa <do_execve+0x1a0>
ffffffffc0204e44:	e299                	bnez	a3,ffffffffc0204e4a <do_execve+0x3f0>
ffffffffc0204e46:	03ba8263          	beq	s5,s11,ffffffffc0204e6a <do_execve+0x410>
ffffffffc0204e4a:	00002697          	auipc	a3,0x2
ffffffffc0204e4e:	57668693          	addi	a3,a3,1398 # ffffffffc02073c0 <etext+0x1a42>
ffffffffc0204e52:	00001617          	auipc	a2,0x1
ffffffffc0204e56:	52660613          	addi	a2,a2,1318 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0204e5a:	2ac00593          	li	a1,684
ffffffffc0204e5e:	00002517          	auipc	a0,0x2
ffffffffc0204e62:	35250513          	addi	a0,a0,850 # ffffffffc02071b0 <etext+0x1832>
ffffffffc0204e66:	de0fb0ef          	jal	ffffffffc0200446 <__panic>
        while (start < end)
ffffffffc0204e6a:	d88af8e3          	bgeu	s5,s0,ffffffffc0204bfa <do_execve+0x1a0>
ffffffffc0204e6e:	56fd                	li	a3,-1
ffffffffc0204e70:	00c6d793          	srli	a5,a3,0xc
ffffffffc0204e74:	f03e                	sd	a5,32(sp)
ffffffffc0204e76:	a0b9                	j	ffffffffc0204ec4 <do_execve+0x46a>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204e78:	6785                	lui	a5,0x1
ffffffffc0204e7a:	00fd88b3          	add	a7,s11,a5
                size -= la - end;
ffffffffc0204e7e:	41540933          	sub	s2,s0,s5
            if (end < la)
ffffffffc0204e82:	01146463          	bltu	s0,a7,ffffffffc0204e8a <do_execve+0x430>
            off = start - la, size = PGSIZE - off, la += PGSIZE;
ffffffffc0204e86:	41588933          	sub	s2,a7,s5
    return page - pages + nbase;
ffffffffc0204e8a:	000bb683          	ld	a3,0(s7)
    return KADDR(page2pa(page));
ffffffffc0204e8e:	7782                	ld	a5,32(sp)
ffffffffc0204e90:	000c3583          	ld	a1,0(s8)
    return page - pages + nbase;
ffffffffc0204e94:	40dc86b3          	sub	a3,s9,a3
ffffffffc0204e98:	8699                	srai	a3,a3,0x6
ffffffffc0204e9a:	96da                	add	a3,a3,s6
    return KADDR(page2pa(page));
ffffffffc0204e9c:	00f6f533          	and	a0,a3,a5
    return page2ppn(page) << PGSHIFT;
ffffffffc0204ea0:	06b2                	slli	a3,a3,0xc
    return KADDR(page2pa(page));
ffffffffc0204ea2:	06b57163          	bgeu	a0,a1,ffffffffc0204f04 <do_execve+0x4aa>
ffffffffc0204ea6:	000a3583          	ld	a1,0(s4)
ffffffffc0204eaa:	41ba8533          	sub	a0,s5,s11
            memset(page2kva(page) + off, 0, size);
ffffffffc0204eae:	864a                	mv	a2,s2
ffffffffc0204eb0:	96ae                	add	a3,a3,a1
ffffffffc0204eb2:	9536                	add	a0,a0,a3
ffffffffc0204eb4:	4581                	li	a1,0
            start += size;
ffffffffc0204eb6:	9aca                	add	s5,s5,s2
ffffffffc0204eb8:	e046                	sd	a7,0(sp)
            memset(page2kva(page) + off, 0, size);
ffffffffc0204eba:	29b000ef          	jal	ffffffffc0205954 <memset>
        while (start < end)
ffffffffc0204ebe:	d28afee3          	bgeu	s5,s0,ffffffffc0204bfa <do_execve+0x1a0>
ffffffffc0204ec2:	6d82                	ld	s11,0(sp)
            if ((page = pgdir_alloc_page(mm->pgdir, la, perm)) == NULL)
ffffffffc0204ec4:	6c88                	ld	a0,24(s1)
ffffffffc0204ec6:	6622                	ld	a2,8(sp)
ffffffffc0204ec8:	85ee                	mv	a1,s11
ffffffffc0204eca:	82bfe0ef          	jal	ffffffffc02036f4 <pgdir_alloc_page>
ffffffffc0204ece:	8caa                	mv	s9,a0
ffffffffc0204ed0:	f545                	bnez	a0,ffffffffc0204e78 <do_execve+0x41e>
ffffffffc0204ed2:	b5d5                	j	ffffffffc0204db6 <do_execve+0x35c>
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0204ed4:	47c5                	li	a5,17
        if (ph->p_flags & ELF_PF_R)
ffffffffc0204ed6:	86ba                	mv	a3,a4
        vm_flags = 0, perm = PTE_U | PTE_V;
ffffffffc0204ed8:	e43e                	sd	a5,8(sp)
ffffffffc0204eda:	b591                	j	ffffffffc0204d1e <do_execve+0x2c4>
            perm |= (PTE_W | PTE_R);
ffffffffc0204edc:	47dd                	li	a5,23
            vm_flags |= VM_READ;
ffffffffc0204ede:	00376693          	ori	a3,a4,3
            perm |= (PTE_W | PTE_R);
ffffffffc0204ee2:	e43e                	sd	a5,8(sp)
ffffffffc0204ee4:	bd2d                	j	ffffffffc0204d1e <do_execve+0x2c4>
            off = start + PGSIZE - la, size = PGSIZE - off;
ffffffffc0204ee6:	415d8933          	sub	s2,s11,s5
ffffffffc0204eea:	bf21                	j	ffffffffc0204e02 <do_execve+0x3a8>
        return -E_INVAL;
ffffffffc0204eec:	5475                	li	s0,-3
ffffffffc0204eee:	bbcd                	j	ffffffffc0204ce0 <do_execve+0x286>
        uintptr_t start = ph->p_va, end, la = ROUNDDOWN(start, PGSIZE);
ffffffffc0204ef0:	8dae                	mv	s11,a1
        while (start < end)
ffffffffc0204ef2:	8456                	mv	s0,s5
ffffffffc0204ef4:	bde5                	j	ffffffffc0204dec <do_execve+0x392>
    int ret = -E_NO_MEM;
ffffffffc0204ef6:	5471                	li	s0,-4
ffffffffc0204ef8:	b9b5                	j	ffffffffc0204b74 <do_execve+0x11a>
ffffffffc0204efa:	6da6                	ld	s11,72(sp)
ffffffffc0204efc:	bd7d                	j	ffffffffc0204dba <do_execve+0x360>
            ret = -E_INVAL_ELF;
ffffffffc0204efe:	6da6                	ld	s11,72(sp)
ffffffffc0204f00:	5461                	li	s0,-8
ffffffffc0204f02:	bd65                	j	ffffffffc0204dba <do_execve+0x360>
ffffffffc0204f04:	00002617          	auipc	a2,0x2
ffffffffc0204f08:	82460613          	addi	a2,a2,-2012 # ffffffffc0206728 <etext+0xdaa>
ffffffffc0204f0c:	07100593          	li	a1,113
ffffffffc0204f10:	00002517          	auipc	a0,0x2
ffffffffc0204f14:	84050513          	addi	a0,a0,-1984 # ffffffffc0206750 <etext+0xdd2>
ffffffffc0204f18:	d2efb0ef          	jal	ffffffffc0200446 <__panic>
ffffffffc0204f1c:	00002617          	auipc	a2,0x2
ffffffffc0204f20:	80c60613          	addi	a2,a2,-2036 # ffffffffc0206728 <etext+0xdaa>
ffffffffc0204f24:	07100593          	li	a1,113
ffffffffc0204f28:	00002517          	auipc	a0,0x2
ffffffffc0204f2c:	82850513          	addi	a0,a0,-2008 # ffffffffc0206750 <etext+0xdd2>
ffffffffc0204f30:	e54e                	sd	s3,136(sp)
ffffffffc0204f32:	ece6                	sd	s9,88(sp)
ffffffffc0204f34:	e4ee                	sd	s11,72(sp)
ffffffffc0204f36:	d10fb0ef          	jal	ffffffffc0200446 <__panic>
    current->pgdir = PADDR(mm->pgdir);
ffffffffc0204f3a:	00002617          	auipc	a2,0x2
ffffffffc0204f3e:	89660613          	addi	a2,a2,-1898 # ffffffffc02067d0 <etext+0xe52>
ffffffffc0204f42:	2cb00593          	li	a1,715
ffffffffc0204f46:	00002517          	auipc	a0,0x2
ffffffffc0204f4a:	26a50513          	addi	a0,a0,618 # ffffffffc02071b0 <etext+0x1832>
ffffffffc0204f4e:	e4ee                	sd	s11,72(sp)
ffffffffc0204f50:	cf6fb0ef          	jal	ffffffffc0200446 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 4 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204f54:	00002697          	auipc	a3,0x2
ffffffffc0204f58:	58468693          	addi	a3,a3,1412 # ffffffffc02074d8 <etext+0x1b5a>
ffffffffc0204f5c:	00001617          	auipc	a2,0x1
ffffffffc0204f60:	41c60613          	addi	a2,a2,1052 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0204f64:	2c600593          	li	a1,710
ffffffffc0204f68:	00002517          	auipc	a0,0x2
ffffffffc0204f6c:	24850513          	addi	a0,a0,584 # ffffffffc02071b0 <etext+0x1832>
ffffffffc0204f70:	e4ee                	sd	s11,72(sp)
ffffffffc0204f72:	cd4fb0ef          	jal	ffffffffc0200446 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 3 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204f76:	00002697          	auipc	a3,0x2
ffffffffc0204f7a:	51a68693          	addi	a3,a3,1306 # ffffffffc0207490 <etext+0x1b12>
ffffffffc0204f7e:	00001617          	auipc	a2,0x1
ffffffffc0204f82:	3fa60613          	addi	a2,a2,1018 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0204f86:	2c500593          	li	a1,709
ffffffffc0204f8a:	00002517          	auipc	a0,0x2
ffffffffc0204f8e:	22650513          	addi	a0,a0,550 # ffffffffc02071b0 <etext+0x1832>
ffffffffc0204f92:	e4ee                	sd	s11,72(sp)
ffffffffc0204f94:	cb2fb0ef          	jal	ffffffffc0200446 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - 2 * PGSIZE, PTE_USER) != NULL);
ffffffffc0204f98:	00002697          	auipc	a3,0x2
ffffffffc0204f9c:	4b068693          	addi	a3,a3,1200 # ffffffffc0207448 <etext+0x1aca>
ffffffffc0204fa0:	00001617          	auipc	a2,0x1
ffffffffc0204fa4:	3d860613          	addi	a2,a2,984 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0204fa8:	2c400593          	li	a1,708
ffffffffc0204fac:	00002517          	auipc	a0,0x2
ffffffffc0204fb0:	20450513          	addi	a0,a0,516 # ffffffffc02071b0 <etext+0x1832>
ffffffffc0204fb4:	e4ee                	sd	s11,72(sp)
ffffffffc0204fb6:	c90fb0ef          	jal	ffffffffc0200446 <__panic>
    assert(pgdir_alloc_page(mm->pgdir, USTACKTOP - PGSIZE, PTE_USER) != NULL);
ffffffffc0204fba:	00002697          	auipc	a3,0x2
ffffffffc0204fbe:	44668693          	addi	a3,a3,1094 # ffffffffc0207400 <etext+0x1a82>
ffffffffc0204fc2:	00001617          	auipc	a2,0x1
ffffffffc0204fc6:	3b660613          	addi	a2,a2,950 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0204fca:	2c300593          	li	a1,707
ffffffffc0204fce:	00002517          	auipc	a0,0x2
ffffffffc0204fd2:	1e250513          	addi	a0,a0,482 # ffffffffc02071b0 <etext+0x1832>
ffffffffc0204fd6:	e4ee                	sd	s11,72(sp)
ffffffffc0204fd8:	c6efb0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0204fdc <do_yield>:
    current->need_resched = 1;
ffffffffc0204fdc:	00096797          	auipc	a5,0x96
ffffffffc0204fe0:	7c47b783          	ld	a5,1988(a5) # ffffffffc029b7a0 <current>
ffffffffc0204fe4:	4705                	li	a4,1
}
ffffffffc0204fe6:	4501                	li	a0,0
    current->need_resched = 1;
ffffffffc0204fe8:	ef98                	sd	a4,24(a5)
}
ffffffffc0204fea:	8082                	ret

ffffffffc0204fec <do_wait>:
    if (code_store != NULL)
ffffffffc0204fec:	c59d                	beqz	a1,ffffffffc020501a <do_wait+0x2e>
{
ffffffffc0204fee:	1101                	addi	sp,sp,-32
ffffffffc0204ff0:	e02a                	sd	a0,0(sp)
    struct mm_struct *mm = current->mm;
ffffffffc0204ff2:	00096517          	auipc	a0,0x96
ffffffffc0204ff6:	7ae53503          	ld	a0,1966(a0) # ffffffffc029b7a0 <current>
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0204ffa:	4685                	li	a3,1
ffffffffc0204ffc:	4611                	li	a2,4
ffffffffc0204ffe:	7508                	ld	a0,40(a0)
{
ffffffffc0205000:	ec06                	sd	ra,24(sp)
ffffffffc0205002:	e42e                	sd	a1,8(sp)
        if (!user_mem_check(mm, (uintptr_t)code_store, sizeof(int), 1))
ffffffffc0205004:	e5ffe0ef          	jal	ffffffffc0203e62 <user_mem_check>
ffffffffc0205008:	6702                	ld	a4,0(sp)
ffffffffc020500a:	67a2                	ld	a5,8(sp)
ffffffffc020500c:	c909                	beqz	a0,ffffffffc020501e <do_wait+0x32>
}
ffffffffc020500e:	60e2                	ld	ra,24(sp)
ffffffffc0205010:	85be                	mv	a1,a5
ffffffffc0205012:	853a                	mv	a0,a4
ffffffffc0205014:	6105                	addi	sp,sp,32
ffffffffc0205016:	f3eff06f          	j	ffffffffc0204754 <do_wait.part.0>
ffffffffc020501a:	f3aff06f          	j	ffffffffc0204754 <do_wait.part.0>
ffffffffc020501e:	60e2                	ld	ra,24(sp)
ffffffffc0205020:	5575                	li	a0,-3
ffffffffc0205022:	6105                	addi	sp,sp,32
ffffffffc0205024:	8082                	ret

ffffffffc0205026 <do_kill>:
    if (0 < pid && pid < MAX_PID)
ffffffffc0205026:	6789                	lui	a5,0x2
ffffffffc0205028:	fff5071b          	addiw	a4,a0,-1
ffffffffc020502c:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x6bd2>
ffffffffc020502e:	06e7e463          	bltu	a5,a4,ffffffffc0205096 <do_kill+0x70>
{
ffffffffc0205032:	1101                	addi	sp,sp,-32
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205034:	45a9                	li	a1,10
{
ffffffffc0205036:	ec06                	sd	ra,24(sp)
ffffffffc0205038:	e42a                	sd	a0,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc020503a:	484000ef          	jal	ffffffffc02054be <hash32>
ffffffffc020503e:	02051793          	slli	a5,a0,0x20
ffffffffc0205042:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0205046:	00092797          	auipc	a5,0x92
ffffffffc020504a:	6e278793          	addi	a5,a5,1762 # ffffffffc0297728 <hash_list>
ffffffffc020504e:	96be                	add	a3,a3,a5
        while ((le = list_next(le)) != list)
ffffffffc0205050:	6622                	ld	a2,8(sp)
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205052:	8536                	mv	a0,a3
        while ((le = list_next(le)) != list)
ffffffffc0205054:	a029                	j	ffffffffc020505e <do_kill+0x38>
            if (proc->pid == pid)
ffffffffc0205056:	f2c52703          	lw	a4,-212(a0)
ffffffffc020505a:	00c70963          	beq	a4,a2,ffffffffc020506c <do_kill+0x46>
ffffffffc020505e:	6508                	ld	a0,8(a0)
        while ((le = list_next(le)) != list)
ffffffffc0205060:	fea69be3          	bne	a3,a0,ffffffffc0205056 <do_kill+0x30>
}
ffffffffc0205064:	60e2                	ld	ra,24(sp)
    return -E_INVAL;
ffffffffc0205066:	5575                	li	a0,-3
}
ffffffffc0205068:	6105                	addi	sp,sp,32
ffffffffc020506a:	8082                	ret
        if (!(proc->flags & PF_EXITING))
ffffffffc020506c:	fd852703          	lw	a4,-40(a0)
ffffffffc0205070:	00177693          	andi	a3,a4,1
ffffffffc0205074:	e29d                	bnez	a3,ffffffffc020509a <do_kill+0x74>
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0205076:	4954                	lw	a3,20(a0)
            proc->flags |= PF_EXITING;
ffffffffc0205078:	00176713          	ori	a4,a4,1
ffffffffc020507c:	fce52c23          	sw	a4,-40(a0)
            if (proc->wait_state & WT_INTERRUPTED)
ffffffffc0205080:	0006c663          	bltz	a3,ffffffffc020508c <do_kill+0x66>
            return 0;
ffffffffc0205084:	4501                	li	a0,0
}
ffffffffc0205086:	60e2                	ld	ra,24(sp)
ffffffffc0205088:	6105                	addi	sp,sp,32
ffffffffc020508a:	8082                	ret
                wakeup_proc(proc);
ffffffffc020508c:	f2850513          	addi	a0,a0,-216
ffffffffc0205090:	232000ef          	jal	ffffffffc02052c2 <wakeup_proc>
ffffffffc0205094:	bfc5                	j	ffffffffc0205084 <do_kill+0x5e>
    return -E_INVAL;
ffffffffc0205096:	5575                	li	a0,-3
}
ffffffffc0205098:	8082                	ret
        return -E_KILLED;
ffffffffc020509a:	555d                	li	a0,-9
ffffffffc020509c:	b7ed                	j	ffffffffc0205086 <do_kill+0x60>

ffffffffc020509e <proc_init>:

// proc_init - set up the first kernel thread idleproc "idle" by itself and
//           - create the second kernel thread init_main
void proc_init(void)
{
ffffffffc020509e:	1101                	addi	sp,sp,-32
ffffffffc02050a0:	e426                	sd	s1,8(sp)
    elm->prev = elm->next = elm;
ffffffffc02050a2:	00096797          	auipc	a5,0x96
ffffffffc02050a6:	68678793          	addi	a5,a5,1670 # ffffffffc029b728 <proc_list>
ffffffffc02050aa:	ec06                	sd	ra,24(sp)
ffffffffc02050ac:	e822                	sd	s0,16(sp)
ffffffffc02050ae:	e04a                	sd	s2,0(sp)
ffffffffc02050b0:	00092497          	auipc	s1,0x92
ffffffffc02050b4:	67848493          	addi	s1,s1,1656 # ffffffffc0297728 <hash_list>
ffffffffc02050b8:	e79c                	sd	a5,8(a5)
ffffffffc02050ba:	e39c                	sd	a5,0(a5)
    int i;

    list_init(&proc_list);
    for (i = 0; i < HASH_LIST_SIZE; i++)
ffffffffc02050bc:	00096717          	auipc	a4,0x96
ffffffffc02050c0:	66c70713          	addi	a4,a4,1644 # ffffffffc029b728 <proc_list>
ffffffffc02050c4:	87a6                	mv	a5,s1
ffffffffc02050c6:	e79c                	sd	a5,8(a5)
ffffffffc02050c8:	e39c                	sd	a5,0(a5)
ffffffffc02050ca:	07c1                	addi	a5,a5,16
ffffffffc02050cc:	fee79de3          	bne	a5,a4,ffffffffc02050c6 <proc_init+0x28>
    {
        list_init(hash_list + i);
    }

    if ((idleproc = alloc_proc()) == NULL)
ffffffffc02050d0:	ed3fe0ef          	jal	ffffffffc0203fa2 <alloc_proc>
ffffffffc02050d4:	00096917          	auipc	s2,0x96
ffffffffc02050d8:	6dc90913          	addi	s2,s2,1756 # ffffffffc029b7b0 <idleproc>
ffffffffc02050dc:	00a93023          	sd	a0,0(s2)
ffffffffc02050e0:	10050363          	beqz	a0,ffffffffc02051e6 <proc_init+0x148>
    {
        panic("cannot alloc idleproc.\n");
    }

    idleproc->pid = 0;
    idleproc->state = PROC_RUNNABLE;
ffffffffc02050e4:	4789                	li	a5,2
ffffffffc02050e6:	e11c                	sd	a5,0(a0)
    idleproc->kstack = (uintptr_t)bootstack;
ffffffffc02050e8:	00003797          	auipc	a5,0x3
ffffffffc02050ec:	f1878793          	addi	a5,a5,-232 # ffffffffc0208000 <bootstack>
ffffffffc02050f0:	e91c                	sd	a5,16(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02050f2:	0b450413          	addi	s0,a0,180
    idleproc->need_resched = 1;
ffffffffc02050f6:	4785                	li	a5,1
ffffffffc02050f8:	ed1c                	sd	a5,24(a0)
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc02050fa:	4641                	li	a2,16
ffffffffc02050fc:	8522                	mv	a0,s0
ffffffffc02050fe:	4581                	li	a1,0
ffffffffc0205100:	055000ef          	jal	ffffffffc0205954 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205104:	8522                	mv	a0,s0
ffffffffc0205106:	463d                	li	a2,15
ffffffffc0205108:	00002597          	auipc	a1,0x2
ffffffffc020510c:	43058593          	addi	a1,a1,1072 # ffffffffc0207538 <etext+0x1bba>
ffffffffc0205110:	057000ef          	jal	ffffffffc0205966 <memcpy>
    set_proc_name(idleproc, "idle");
    nr_process++;
ffffffffc0205114:	00096797          	auipc	a5,0x96
ffffffffc0205118:	6887a783          	lw	a5,1672(a5) # ffffffffc029b79c <nr_process>

    current = idleproc;
ffffffffc020511c:	00093703          	ld	a4,0(s2)

    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205120:	4601                	li	a2,0
    nr_process++;
ffffffffc0205122:	2785                	addiw	a5,a5,1
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc0205124:	4581                	li	a1,0
ffffffffc0205126:	00000517          	auipc	a0,0x0
ffffffffc020512a:	81050513          	addi	a0,a0,-2032 # ffffffffc0204936 <init_main>
    current = idleproc;
ffffffffc020512e:	00096697          	auipc	a3,0x96
ffffffffc0205132:	66e6b923          	sd	a4,1650(a3) # ffffffffc029b7a0 <current>
    nr_process++;
ffffffffc0205136:	00096717          	auipc	a4,0x96
ffffffffc020513a:	66f72323          	sw	a5,1638(a4) # ffffffffc029b79c <nr_process>
    int pid = kernel_thread(init_main, NULL, 0);
ffffffffc020513e:	c82ff0ef          	jal	ffffffffc02045c0 <kernel_thread>
ffffffffc0205142:	842a                	mv	s0,a0
    if (pid <= 0)
ffffffffc0205144:	08a05563          	blez	a0,ffffffffc02051ce <proc_init+0x130>
    if (0 < pid && pid < MAX_PID)
ffffffffc0205148:	6789                	lui	a5,0x2
ffffffffc020514a:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_obj___user_softint_out_size-0x6bd2>
ffffffffc020514c:	fff5071b          	addiw	a4,a0,-1
ffffffffc0205150:	02e7e463          	bltu	a5,a4,ffffffffc0205178 <proc_init+0xda>
        list_entry_t *list = hash_list + pid_hashfn(pid), *le = list;
ffffffffc0205154:	45a9                	li	a1,10
ffffffffc0205156:	368000ef          	jal	ffffffffc02054be <hash32>
ffffffffc020515a:	02051713          	slli	a4,a0,0x20
ffffffffc020515e:	01c75793          	srli	a5,a4,0x1c
ffffffffc0205162:	00f486b3          	add	a3,s1,a5
ffffffffc0205166:	87b6                	mv	a5,a3
        while ((le = list_next(le)) != list)
ffffffffc0205168:	a029                	j	ffffffffc0205172 <proc_init+0xd4>
            if (proc->pid == pid)
ffffffffc020516a:	f2c7a703          	lw	a4,-212(a5)
ffffffffc020516e:	04870d63          	beq	a4,s0,ffffffffc02051c8 <proc_init+0x12a>
    return listelm->next;
ffffffffc0205172:	679c                	ld	a5,8(a5)
        while ((le = list_next(le)) != list)
ffffffffc0205174:	fef69be3          	bne	a3,a5,ffffffffc020516a <proc_init+0xcc>
    return NULL;
ffffffffc0205178:	4781                	li	a5,0
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020517a:	0b478413          	addi	s0,a5,180
ffffffffc020517e:	4641                	li	a2,16
ffffffffc0205180:	4581                	li	a1,0
ffffffffc0205182:	8522                	mv	a0,s0
    {
        panic("create init_main failed.\n");
    }

    initproc = find_proc(pid);
ffffffffc0205184:	00096717          	auipc	a4,0x96
ffffffffc0205188:	62f73223          	sd	a5,1572(a4) # ffffffffc029b7a8 <initproc>
    memset(proc->name, 0, sizeof(proc->name));
ffffffffc020518c:	7c8000ef          	jal	ffffffffc0205954 <memset>
    return memcpy(proc->name, name, PROC_NAME_LEN);
ffffffffc0205190:	8522                	mv	a0,s0
ffffffffc0205192:	463d                	li	a2,15
ffffffffc0205194:	00002597          	auipc	a1,0x2
ffffffffc0205198:	3cc58593          	addi	a1,a1,972 # ffffffffc0207560 <etext+0x1be2>
ffffffffc020519c:	7ca000ef          	jal	ffffffffc0205966 <memcpy>
    set_proc_name(initproc, "init");

    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc02051a0:	00093783          	ld	a5,0(s2)
ffffffffc02051a4:	cfad                	beqz	a5,ffffffffc020521e <proc_init+0x180>
ffffffffc02051a6:	43dc                	lw	a5,4(a5)
ffffffffc02051a8:	ebbd                	bnez	a5,ffffffffc020521e <proc_init+0x180>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02051aa:	00096797          	auipc	a5,0x96
ffffffffc02051ae:	5fe7b783          	ld	a5,1534(a5) # ffffffffc029b7a8 <initproc>
ffffffffc02051b2:	c7b1                	beqz	a5,ffffffffc02051fe <proc_init+0x160>
ffffffffc02051b4:	43d8                	lw	a4,4(a5)
ffffffffc02051b6:	4785                	li	a5,1
ffffffffc02051b8:	04f71363          	bne	a4,a5,ffffffffc02051fe <proc_init+0x160>
}
ffffffffc02051bc:	60e2                	ld	ra,24(sp)
ffffffffc02051be:	6442                	ld	s0,16(sp)
ffffffffc02051c0:	64a2                	ld	s1,8(sp)
ffffffffc02051c2:	6902                	ld	s2,0(sp)
ffffffffc02051c4:	6105                	addi	sp,sp,32
ffffffffc02051c6:	8082                	ret
            struct proc_struct *proc = le2proc(le, hash_link);
ffffffffc02051c8:	f2878793          	addi	a5,a5,-216
ffffffffc02051cc:	b77d                	j	ffffffffc020517a <proc_init+0xdc>
        panic("create init_main failed.\n");
ffffffffc02051ce:	00002617          	auipc	a2,0x2
ffffffffc02051d2:	37260613          	addi	a2,a2,882 # ffffffffc0207540 <etext+0x1bc2>
ffffffffc02051d6:	3eb00593          	li	a1,1003
ffffffffc02051da:	00002517          	auipc	a0,0x2
ffffffffc02051de:	fd650513          	addi	a0,a0,-42 # ffffffffc02071b0 <etext+0x1832>
ffffffffc02051e2:	a64fb0ef          	jal	ffffffffc0200446 <__panic>
        panic("cannot alloc idleproc.\n");
ffffffffc02051e6:	00002617          	auipc	a2,0x2
ffffffffc02051ea:	33a60613          	addi	a2,a2,826 # ffffffffc0207520 <etext+0x1ba2>
ffffffffc02051ee:	3dc00593          	li	a1,988
ffffffffc02051f2:	00002517          	auipc	a0,0x2
ffffffffc02051f6:	fbe50513          	addi	a0,a0,-66 # ffffffffc02071b0 <etext+0x1832>
ffffffffc02051fa:	a4cfb0ef          	jal	ffffffffc0200446 <__panic>
    assert(initproc != NULL && initproc->pid == 1);
ffffffffc02051fe:	00002697          	auipc	a3,0x2
ffffffffc0205202:	39268693          	addi	a3,a3,914 # ffffffffc0207590 <etext+0x1c12>
ffffffffc0205206:	00001617          	auipc	a2,0x1
ffffffffc020520a:	17260613          	addi	a2,a2,370 # ffffffffc0206378 <etext+0x9fa>
ffffffffc020520e:	3f200593          	li	a1,1010
ffffffffc0205212:	00002517          	auipc	a0,0x2
ffffffffc0205216:	f9e50513          	addi	a0,a0,-98 # ffffffffc02071b0 <etext+0x1832>
ffffffffc020521a:	a2cfb0ef          	jal	ffffffffc0200446 <__panic>
    assert(idleproc != NULL && idleproc->pid == 0);
ffffffffc020521e:	00002697          	auipc	a3,0x2
ffffffffc0205222:	34a68693          	addi	a3,a3,842 # ffffffffc0207568 <etext+0x1bea>
ffffffffc0205226:	00001617          	auipc	a2,0x1
ffffffffc020522a:	15260613          	addi	a2,a2,338 # ffffffffc0206378 <etext+0x9fa>
ffffffffc020522e:	3f100593          	li	a1,1009
ffffffffc0205232:	00002517          	auipc	a0,0x2
ffffffffc0205236:	f7e50513          	addi	a0,a0,-130 # ffffffffc02071b0 <etext+0x1832>
ffffffffc020523a:	a0cfb0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc020523e <cpu_idle>:

// cpu_idle - at the end of kern_init, the first kernel thread idleproc will do below works
void cpu_idle(void)
{
ffffffffc020523e:	1141                	addi	sp,sp,-16
ffffffffc0205240:	e022                	sd	s0,0(sp)
ffffffffc0205242:	e406                	sd	ra,8(sp)
ffffffffc0205244:	00096417          	auipc	s0,0x96
ffffffffc0205248:	55c40413          	addi	s0,s0,1372 # ffffffffc029b7a0 <current>
    while (1)
    {
        if (current->need_resched)
ffffffffc020524c:	6018                	ld	a4,0(s0)
ffffffffc020524e:	6f1c                	ld	a5,24(a4)
ffffffffc0205250:	dffd                	beqz	a5,ffffffffc020524e <cpu_idle+0x10>
        {
            schedule();
ffffffffc0205252:	104000ef          	jal	ffffffffc0205356 <schedule>
ffffffffc0205256:	bfdd                	j	ffffffffc020524c <cpu_idle+0xe>

ffffffffc0205258 <switch_to>:
.text
# void switch_to(struct proc_struct* from, struct proc_struct* to)
.globl switch_to
switch_to:
    # save from's registers
    STORE ra, 0*REGBYTES(a0)
ffffffffc0205258:	00153023          	sd	ra,0(a0)
    STORE sp, 1*REGBYTES(a0)
ffffffffc020525c:	00253423          	sd	sp,8(a0)
    STORE s0, 2*REGBYTES(a0)
ffffffffc0205260:	e900                	sd	s0,16(a0)
    STORE s1, 3*REGBYTES(a0)
ffffffffc0205262:	ed04                	sd	s1,24(a0)
    STORE s2, 4*REGBYTES(a0)
ffffffffc0205264:	03253023          	sd	s2,32(a0)
    STORE s3, 5*REGBYTES(a0)
ffffffffc0205268:	03353423          	sd	s3,40(a0)
    STORE s4, 6*REGBYTES(a0)
ffffffffc020526c:	03453823          	sd	s4,48(a0)
    STORE s5, 7*REGBYTES(a0)
ffffffffc0205270:	03553c23          	sd	s5,56(a0)
    STORE s6, 8*REGBYTES(a0)
ffffffffc0205274:	05653023          	sd	s6,64(a0)
    STORE s7, 9*REGBYTES(a0)
ffffffffc0205278:	05753423          	sd	s7,72(a0)
    STORE s8, 10*REGBYTES(a0)
ffffffffc020527c:	05853823          	sd	s8,80(a0)
    STORE s9, 11*REGBYTES(a0)
ffffffffc0205280:	05953c23          	sd	s9,88(a0)
    STORE s10, 12*REGBYTES(a0)
ffffffffc0205284:	07a53023          	sd	s10,96(a0)
    STORE s11, 13*REGBYTES(a0)
ffffffffc0205288:	07b53423          	sd	s11,104(a0)

    # restore to's registers
    LOAD ra, 0*REGBYTES(a1)
ffffffffc020528c:	0005b083          	ld	ra,0(a1)
    LOAD sp, 1*REGBYTES(a1)
ffffffffc0205290:	0085b103          	ld	sp,8(a1)
    LOAD s0, 2*REGBYTES(a1)
ffffffffc0205294:	6980                	ld	s0,16(a1)
    LOAD s1, 3*REGBYTES(a1)
ffffffffc0205296:	6d84                	ld	s1,24(a1)
    LOAD s2, 4*REGBYTES(a1)
ffffffffc0205298:	0205b903          	ld	s2,32(a1)
    LOAD s3, 5*REGBYTES(a1)
ffffffffc020529c:	0285b983          	ld	s3,40(a1)
    LOAD s4, 6*REGBYTES(a1)
ffffffffc02052a0:	0305ba03          	ld	s4,48(a1)
    LOAD s5, 7*REGBYTES(a1)
ffffffffc02052a4:	0385ba83          	ld	s5,56(a1)
    LOAD s6, 8*REGBYTES(a1)
ffffffffc02052a8:	0405bb03          	ld	s6,64(a1)
    LOAD s7, 9*REGBYTES(a1)
ffffffffc02052ac:	0485bb83          	ld	s7,72(a1)
    LOAD s8, 10*REGBYTES(a1)
ffffffffc02052b0:	0505bc03          	ld	s8,80(a1)
    LOAD s9, 11*REGBYTES(a1)
ffffffffc02052b4:	0585bc83          	ld	s9,88(a1)
    LOAD s10, 12*REGBYTES(a1)
ffffffffc02052b8:	0605bd03          	ld	s10,96(a1)
    LOAD s11, 13*REGBYTES(a1)
ffffffffc02052bc:	0685bd83          	ld	s11,104(a1)

    ret
ffffffffc02052c0:	8082                	ret

ffffffffc02052c2 <wakeup_proc>:
#include <sched.h>
#include <assert.h>

void wakeup_proc(struct proc_struct *proc)
{
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02052c2:	4118                	lw	a4,0(a0)
{
ffffffffc02052c4:	1101                	addi	sp,sp,-32
ffffffffc02052c6:	ec06                	sd	ra,24(sp)
    assert(proc->state != PROC_ZOMBIE);
ffffffffc02052c8:	478d                	li	a5,3
ffffffffc02052ca:	06f70763          	beq	a4,a5,ffffffffc0205338 <wakeup_proc+0x76>
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc02052ce:	100027f3          	csrr	a5,sstatus
ffffffffc02052d2:	8b89                	andi	a5,a5,2
ffffffffc02052d4:	eb91                	bnez	a5,ffffffffc02052e8 <wakeup_proc+0x26>
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        if (proc->state != PROC_RUNNABLE)
ffffffffc02052d6:	4789                	li	a5,2
ffffffffc02052d8:	02f70763          	beq	a4,a5,ffffffffc0205306 <wakeup_proc+0x44>
        {
            warn("wakeup runnable process.\n");
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02052dc:	60e2                	ld	ra,24(sp)
            proc->state = PROC_RUNNABLE;
ffffffffc02052de:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc02052e0:	0e052623          	sw	zero,236(a0)
}
ffffffffc02052e4:	6105                	addi	sp,sp,32
ffffffffc02052e6:	8082                	ret
        intr_disable();
ffffffffc02052e8:	e42a                	sd	a0,8(sp)
ffffffffc02052ea:	e1afb0ef          	jal	ffffffffc0200904 <intr_disable>
        if (proc->state != PROC_RUNNABLE)
ffffffffc02052ee:	6522                	ld	a0,8(sp)
ffffffffc02052f0:	4789                	li	a5,2
ffffffffc02052f2:	4118                	lw	a4,0(a0)
ffffffffc02052f4:	02f70663          	beq	a4,a5,ffffffffc0205320 <wakeup_proc+0x5e>
            proc->state = PROC_RUNNABLE;
ffffffffc02052f8:	c11c                	sw	a5,0(a0)
            proc->wait_state = 0;
ffffffffc02052fa:	0e052623          	sw	zero,236(a0)
}
ffffffffc02052fe:	60e2                	ld	ra,24(sp)
ffffffffc0205300:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0205302:	dfcfb06f          	j	ffffffffc02008fe <intr_enable>
ffffffffc0205306:	60e2                	ld	ra,24(sp)
            warn("wakeup runnable process.\n");
ffffffffc0205308:	00002617          	auipc	a2,0x2
ffffffffc020530c:	2e860613          	addi	a2,a2,744 # ffffffffc02075f0 <etext+0x1c72>
ffffffffc0205310:	45d1                	li	a1,20
ffffffffc0205312:	00002517          	auipc	a0,0x2
ffffffffc0205316:	2c650513          	addi	a0,a0,710 # ffffffffc02075d8 <etext+0x1c5a>
}
ffffffffc020531a:	6105                	addi	sp,sp,32
            warn("wakeup runnable process.\n");
ffffffffc020531c:	994fb06f          	j	ffffffffc02004b0 <__warn>
ffffffffc0205320:	00002617          	auipc	a2,0x2
ffffffffc0205324:	2d060613          	addi	a2,a2,720 # ffffffffc02075f0 <etext+0x1c72>
ffffffffc0205328:	45d1                	li	a1,20
ffffffffc020532a:	00002517          	auipc	a0,0x2
ffffffffc020532e:	2ae50513          	addi	a0,a0,686 # ffffffffc02075d8 <etext+0x1c5a>
ffffffffc0205332:	97efb0ef          	jal	ffffffffc02004b0 <__warn>
    if (flag)
ffffffffc0205336:	b7e1                	j	ffffffffc02052fe <wakeup_proc+0x3c>
    assert(proc->state != PROC_ZOMBIE);
ffffffffc0205338:	00002697          	auipc	a3,0x2
ffffffffc020533c:	28068693          	addi	a3,a3,640 # ffffffffc02075b8 <etext+0x1c3a>
ffffffffc0205340:	00001617          	auipc	a2,0x1
ffffffffc0205344:	03860613          	addi	a2,a2,56 # ffffffffc0206378 <etext+0x9fa>
ffffffffc0205348:	45a5                	li	a1,9
ffffffffc020534a:	00002517          	auipc	a0,0x2
ffffffffc020534e:	28e50513          	addi	a0,a0,654 # ffffffffc02075d8 <etext+0x1c5a>
ffffffffc0205352:	8f4fb0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc0205356 <schedule>:

void schedule(void)
{
ffffffffc0205356:	1101                	addi	sp,sp,-32
ffffffffc0205358:	ec06                	sd	ra,24(sp)
    if (read_csr(sstatus) & SSTATUS_SIE)
ffffffffc020535a:	100027f3          	csrr	a5,sstatus
ffffffffc020535e:	8b89                	andi	a5,a5,2
ffffffffc0205360:	4301                	li	t1,0
ffffffffc0205362:	e3c1                	bnez	a5,ffffffffc02053e2 <schedule+0x8c>
    bool intr_flag;
    list_entry_t *le, *last;
    struct proc_struct *next = NULL;
    local_intr_save(intr_flag);
    {
        current->need_resched = 0;
ffffffffc0205364:	00096897          	auipc	a7,0x96
ffffffffc0205368:	43c8b883          	ld	a7,1084(a7) # ffffffffc029b7a0 <current>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc020536c:	00096517          	auipc	a0,0x96
ffffffffc0205370:	44453503          	ld	a0,1092(a0) # ffffffffc029b7b0 <idleproc>
        current->need_resched = 0;
ffffffffc0205374:	0008bc23          	sd	zero,24(a7)
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc0205378:	04a88f63          	beq	a7,a0,ffffffffc02053d6 <schedule+0x80>
ffffffffc020537c:	0c888693          	addi	a3,a7,200
ffffffffc0205380:	00096617          	auipc	a2,0x96
ffffffffc0205384:	3a860613          	addi	a2,a2,936 # ffffffffc029b728 <proc_list>
        le = last;
ffffffffc0205388:	87b6                	mv	a5,a3
    struct proc_struct *next = NULL;
ffffffffc020538a:	4581                	li	a1,0
        do
        {
            if ((le = list_next(le)) != &proc_list)
            {
                next = le2proc(le, list_link);
                if (next->state == PROC_RUNNABLE)
ffffffffc020538c:	4809                	li	a6,2
ffffffffc020538e:	679c                	ld	a5,8(a5)
            if ((le = list_next(le)) != &proc_list)
ffffffffc0205390:	00c78863          	beq	a5,a2,ffffffffc02053a0 <schedule+0x4a>
                if (next->state == PROC_RUNNABLE)
ffffffffc0205394:	f387a703          	lw	a4,-200(a5)
                next = le2proc(le, list_link);
ffffffffc0205398:	f3878593          	addi	a1,a5,-200
                if (next->state == PROC_RUNNABLE)
ffffffffc020539c:	03070363          	beq	a4,a6,ffffffffc02053c2 <schedule+0x6c>
                {
                    break;
                }
            }
        } while (le != last);
ffffffffc02053a0:	fef697e3          	bne	a3,a5,ffffffffc020538e <schedule+0x38>
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc02053a4:	ed99                	bnez	a1,ffffffffc02053c2 <schedule+0x6c>
        {
            next = idleproc;
        }
        next->runs++;
ffffffffc02053a6:	451c                	lw	a5,8(a0)
ffffffffc02053a8:	2785                	addiw	a5,a5,1
ffffffffc02053aa:	c51c                	sw	a5,8(a0)
        if (next != current)
ffffffffc02053ac:	00a88663          	beq	a7,a0,ffffffffc02053b8 <schedule+0x62>
ffffffffc02053b0:	e41a                	sd	t1,8(sp)
        {
            proc_run(next);
ffffffffc02053b2:	d65fe0ef          	jal	ffffffffc0204116 <proc_run>
ffffffffc02053b6:	6322                	ld	t1,8(sp)
    if (flag)
ffffffffc02053b8:	00031b63          	bnez	t1,ffffffffc02053ce <schedule+0x78>
        }
    }
    local_intr_restore(intr_flag);
}
ffffffffc02053bc:	60e2                	ld	ra,24(sp)
ffffffffc02053be:	6105                	addi	sp,sp,32
ffffffffc02053c0:	8082                	ret
        if (next == NULL || next->state != PROC_RUNNABLE)
ffffffffc02053c2:	4198                	lw	a4,0(a1)
ffffffffc02053c4:	4789                	li	a5,2
ffffffffc02053c6:	fef710e3          	bne	a4,a5,ffffffffc02053a6 <schedule+0x50>
ffffffffc02053ca:	852e                	mv	a0,a1
ffffffffc02053cc:	bfe9                	j	ffffffffc02053a6 <schedule+0x50>
}
ffffffffc02053ce:	60e2                	ld	ra,24(sp)
ffffffffc02053d0:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc02053d2:	d2cfb06f          	j	ffffffffc02008fe <intr_enable>
        last = (current == idleproc) ? &proc_list : &(current->list_link);
ffffffffc02053d6:	00096617          	auipc	a2,0x96
ffffffffc02053da:	35260613          	addi	a2,a2,850 # ffffffffc029b728 <proc_list>
ffffffffc02053de:	86b2                	mv	a3,a2
ffffffffc02053e0:	b765                	j	ffffffffc0205388 <schedule+0x32>
        intr_disable();
ffffffffc02053e2:	d22fb0ef          	jal	ffffffffc0200904 <intr_disable>
        return 1;
ffffffffc02053e6:	4305                	li	t1,1
ffffffffc02053e8:	bfb5                	j	ffffffffc0205364 <schedule+0xe>

ffffffffc02053ea <sys_getpid>:
    return do_kill(pid);
}

static int
sys_getpid(uint64_t arg[]) {
    return current->pid;
ffffffffc02053ea:	00096797          	auipc	a5,0x96
ffffffffc02053ee:	3b67b783          	ld	a5,950(a5) # ffffffffc029b7a0 <current>
}
ffffffffc02053f2:	43c8                	lw	a0,4(a5)
ffffffffc02053f4:	8082                	ret

ffffffffc02053f6 <sys_pgdir>:

static int
sys_pgdir(uint64_t arg[]) {
    //print_pgdir();
    return 0;
}
ffffffffc02053f6:	4501                	li	a0,0
ffffffffc02053f8:	8082                	ret

ffffffffc02053fa <sys_putc>:
    cputchar(c);
ffffffffc02053fa:	4108                	lw	a0,0(a0)
sys_putc(uint64_t arg[]) {
ffffffffc02053fc:	1141                	addi	sp,sp,-16
ffffffffc02053fe:	e406                	sd	ra,8(sp)
    cputchar(c);
ffffffffc0205400:	dc9fa0ef          	jal	ffffffffc02001c8 <cputchar>
}
ffffffffc0205404:	60a2                	ld	ra,8(sp)
ffffffffc0205406:	4501                	li	a0,0
ffffffffc0205408:	0141                	addi	sp,sp,16
ffffffffc020540a:	8082                	ret

ffffffffc020540c <sys_kill>:
    return do_kill(pid);
ffffffffc020540c:	4108                	lw	a0,0(a0)
ffffffffc020540e:	c19ff06f          	j	ffffffffc0205026 <do_kill>

ffffffffc0205412 <sys_yield>:
    return do_yield();
ffffffffc0205412:	bcbff06f          	j	ffffffffc0204fdc <do_yield>

ffffffffc0205416 <sys_exec>:
    return do_execve(name, len, binary, size);
ffffffffc0205416:	6d14                	ld	a3,24(a0)
ffffffffc0205418:	6910                	ld	a2,16(a0)
ffffffffc020541a:	650c                	ld	a1,8(a0)
ffffffffc020541c:	6108                	ld	a0,0(a0)
ffffffffc020541e:	e3cff06f          	j	ffffffffc0204a5a <do_execve>

ffffffffc0205422 <sys_wait>:
    return do_wait(pid, store);
ffffffffc0205422:	650c                	ld	a1,8(a0)
ffffffffc0205424:	4108                	lw	a0,0(a0)
ffffffffc0205426:	bc7ff06f          	j	ffffffffc0204fec <do_wait>

ffffffffc020542a <sys_fork>:
    struct trapframe *tf = current->tf;
ffffffffc020542a:	00096797          	auipc	a5,0x96
ffffffffc020542e:	3767b783          	ld	a5,886(a5) # ffffffffc029b7a0 <current>
    return do_fork(0, stack, tf);
ffffffffc0205432:	4501                	li	a0,0
    struct trapframe *tf = current->tf;
ffffffffc0205434:	73d0                	ld	a2,160(a5)
    return do_fork(0, stack, tf);
ffffffffc0205436:	6a0c                	ld	a1,16(a2)
ffffffffc0205438:	d43fe06f          	j	ffffffffc020417a <do_fork>

ffffffffc020543c <sys_exit>:
    return do_exit(error_code);
ffffffffc020543c:	4108                	lw	a0,0(a0)
ffffffffc020543e:	9d2ff06f          	j	ffffffffc0204610 <do_exit>

ffffffffc0205442 <syscall>:

#define NUM_SYSCALLS        ((sizeof(syscalls)) / (sizeof(syscalls[0])))

void
syscall(void) {
    struct trapframe *tf = current->tf;
ffffffffc0205442:	00096697          	auipc	a3,0x96
ffffffffc0205446:	35e6b683          	ld	a3,862(a3) # ffffffffc029b7a0 <current>
syscall(void) {
ffffffffc020544a:	715d                	addi	sp,sp,-80
ffffffffc020544c:	e0a2                	sd	s0,64(sp)
    struct trapframe *tf = current->tf;
ffffffffc020544e:	72c0                	ld	s0,160(a3)
syscall(void) {
ffffffffc0205450:	e486                	sd	ra,72(sp)
    uint64_t arg[5];
    int num = tf->gpr.a0;
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205452:	47fd                	li	a5,31
    int num = tf->gpr.a0;
ffffffffc0205454:	4834                	lw	a3,80(s0)
    if (num >= 0 && num < NUM_SYSCALLS) {
ffffffffc0205456:	02d7ec63          	bltu	a5,a3,ffffffffc020548e <syscall+0x4c>
        if (syscalls[num] != NULL) {
ffffffffc020545a:	00002797          	auipc	a5,0x2
ffffffffc020545e:	3de78793          	addi	a5,a5,990 # ffffffffc0207838 <syscalls>
ffffffffc0205462:	00369613          	slli	a2,a3,0x3
ffffffffc0205466:	97b2                	add	a5,a5,a2
ffffffffc0205468:	639c                	ld	a5,0(a5)
ffffffffc020546a:	c395                	beqz	a5,ffffffffc020548e <syscall+0x4c>
            arg[0] = tf->gpr.a1;
ffffffffc020546c:	7028                	ld	a0,96(s0)
ffffffffc020546e:	742c                	ld	a1,104(s0)
ffffffffc0205470:	7830                	ld	a2,112(s0)
ffffffffc0205472:	7c34                	ld	a3,120(s0)
ffffffffc0205474:	6c38                	ld	a4,88(s0)
ffffffffc0205476:	f02a                	sd	a0,32(sp)
ffffffffc0205478:	f42e                	sd	a1,40(sp)
ffffffffc020547a:	f832                	sd	a2,48(sp)
ffffffffc020547c:	fc36                	sd	a3,56(sp)
ffffffffc020547e:	ec3a                	sd	a4,24(sp)
            arg[1] = tf->gpr.a2;
            arg[2] = tf->gpr.a3;
            arg[3] = tf->gpr.a4;
            arg[4] = tf->gpr.a5;
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205480:	0828                	addi	a0,sp,24
ffffffffc0205482:	9782                	jalr	a5
        }
    }
    print_trapframe(tf);
    panic("undefined syscall %d, pid = %d, name = %s.\n",
            num, current->pid, current->name);
}
ffffffffc0205484:	60a6                	ld	ra,72(sp)
            tf->gpr.a0 = syscalls[num](arg);
ffffffffc0205486:	e828                	sd	a0,80(s0)
}
ffffffffc0205488:	6406                	ld	s0,64(sp)
ffffffffc020548a:	6161                	addi	sp,sp,80
ffffffffc020548c:	8082                	ret
    print_trapframe(tf);
ffffffffc020548e:	8522                	mv	a0,s0
ffffffffc0205490:	e436                	sd	a3,8(sp)
ffffffffc0205492:	e62fb0ef          	jal	ffffffffc0200af4 <print_trapframe>
    panic("undefined syscall %d, pid = %d, name = %s.\n",
ffffffffc0205496:	00096797          	auipc	a5,0x96
ffffffffc020549a:	30a7b783          	ld	a5,778(a5) # ffffffffc029b7a0 <current>
ffffffffc020549e:	66a2                	ld	a3,8(sp)
ffffffffc02054a0:	00002617          	auipc	a2,0x2
ffffffffc02054a4:	17060613          	addi	a2,a2,368 # ffffffffc0207610 <etext+0x1c92>
ffffffffc02054a8:	43d8                	lw	a4,4(a5)
ffffffffc02054aa:	06200593          	li	a1,98
ffffffffc02054ae:	0b478793          	addi	a5,a5,180
ffffffffc02054b2:	00002517          	auipc	a0,0x2
ffffffffc02054b6:	18e50513          	addi	a0,a0,398 # ffffffffc0207640 <etext+0x1cc2>
ffffffffc02054ba:	f8dfa0ef          	jal	ffffffffc0200446 <__panic>

ffffffffc02054be <hash32>:
 *
 * High bits are more random, so we use them.
 * */
uint32_t
hash32(uint32_t val, unsigned int bits) {
    uint32_t hash = val * GOLDEN_RATIO_PRIME_32;
ffffffffc02054be:	9e3707b7          	lui	a5,0x9e370
ffffffffc02054c2:	2785                	addiw	a5,a5,1 # ffffffff9e370001 <_binary_obj___user_exit_out_size+0xffffffff9e365e41>
ffffffffc02054c4:	02a787bb          	mulw	a5,a5,a0
    return (hash >> (32 - bits));
ffffffffc02054c8:	02000513          	li	a0,32
ffffffffc02054cc:	9d0d                	subw	a0,a0,a1
}
ffffffffc02054ce:	00a7d53b          	srlw	a0,a5,a0
ffffffffc02054d2:	8082                	ret

ffffffffc02054d4 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02054d4:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02054d6:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02054da:	f022                	sd	s0,32(sp)
ffffffffc02054dc:	ec26                	sd	s1,24(sp)
ffffffffc02054de:	e84a                	sd	s2,16(sp)
ffffffffc02054e0:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02054e2:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02054e6:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
ffffffffc02054e8:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02054ec:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02054f0:	84aa                	mv	s1,a0
ffffffffc02054f2:	892e                	mv	s2,a1
    if (num >= base) {
ffffffffc02054f4:	03067d63          	bgeu	a2,a6,ffffffffc020552e <printnum+0x5a>
ffffffffc02054f8:	e44e                	sd	s3,8(sp)
ffffffffc02054fa:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc02054fc:	4785                	li	a5,1
ffffffffc02054fe:	00e7d763          	bge	a5,a4,ffffffffc020550c <printnum+0x38>
            putch(padc, putdat);
ffffffffc0205502:	85ca                	mv	a1,s2
ffffffffc0205504:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc0205506:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0205508:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020550a:	fc65                	bnez	s0,ffffffffc0205502 <printnum+0x2e>
ffffffffc020550c:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020550e:	00002797          	auipc	a5,0x2
ffffffffc0205512:	14a78793          	addi	a5,a5,330 # ffffffffc0207658 <etext+0x1cda>
ffffffffc0205516:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
ffffffffc0205518:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020551a:	0007c503          	lbu	a0,0(a5)
}
ffffffffc020551e:	70a2                	ld	ra,40(sp)
ffffffffc0205520:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0205522:	85ca                	mv	a1,s2
ffffffffc0205524:	87a6                	mv	a5,s1
}
ffffffffc0205526:	6942                	ld	s2,16(sp)
ffffffffc0205528:	64e2                	ld	s1,24(sp)
ffffffffc020552a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020552c:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020552e:	03065633          	divu	a2,a2,a6
ffffffffc0205532:	8722                	mv	a4,s0
ffffffffc0205534:	fa1ff0ef          	jal	ffffffffc02054d4 <printnum>
ffffffffc0205538:	bfd9                	j	ffffffffc020550e <printnum+0x3a>

ffffffffc020553a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020553a:	7119                	addi	sp,sp,-128
ffffffffc020553c:	f4a6                	sd	s1,104(sp)
ffffffffc020553e:	f0ca                	sd	s2,96(sp)
ffffffffc0205540:	ecce                	sd	s3,88(sp)
ffffffffc0205542:	e8d2                	sd	s4,80(sp)
ffffffffc0205544:	e4d6                	sd	s5,72(sp)
ffffffffc0205546:	e0da                	sd	s6,64(sp)
ffffffffc0205548:	f862                	sd	s8,48(sp)
ffffffffc020554a:	fc86                	sd	ra,120(sp)
ffffffffc020554c:	f8a2                	sd	s0,112(sp)
ffffffffc020554e:	fc5e                	sd	s7,56(sp)
ffffffffc0205550:	f466                	sd	s9,40(sp)
ffffffffc0205552:	f06a                	sd	s10,32(sp)
ffffffffc0205554:	ec6e                	sd	s11,24(sp)
ffffffffc0205556:	84aa                	mv	s1,a0
ffffffffc0205558:	8c32                	mv	s8,a2
ffffffffc020555a:	8a36                	mv	s4,a3
ffffffffc020555c:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020555e:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205562:	05500b13          	li	s6,85
ffffffffc0205566:	00002a97          	auipc	s5,0x2
ffffffffc020556a:	3d2a8a93          	addi	s5,s5,978 # ffffffffc0207938 <syscalls+0x100>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020556e:	000c4503          	lbu	a0,0(s8)
ffffffffc0205572:	001c0413          	addi	s0,s8,1
ffffffffc0205576:	01350a63          	beq	a0,s3,ffffffffc020558a <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc020557a:	cd0d                	beqz	a0,ffffffffc02055b4 <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc020557c:	85ca                	mv	a1,s2
ffffffffc020557e:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0205580:	00044503          	lbu	a0,0(s0)
ffffffffc0205584:	0405                	addi	s0,s0,1
ffffffffc0205586:	ff351ae3          	bne	a0,s3,ffffffffc020557a <vprintfmt+0x40>
        width = precision = -1;
ffffffffc020558a:	5cfd                	li	s9,-1
ffffffffc020558c:	8d66                	mv	s10,s9
        char padc = ' ';
ffffffffc020558e:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc0205592:	4b81                	li	s7,0
ffffffffc0205594:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205596:	00044683          	lbu	a3,0(s0)
ffffffffc020559a:	00140c13          	addi	s8,s0,1
ffffffffc020559e:	fdd6859b          	addiw	a1,a3,-35
ffffffffc02055a2:	0ff5f593          	zext.b	a1,a1
ffffffffc02055a6:	02bb6663          	bltu	s6,a1,ffffffffc02055d2 <vprintfmt+0x98>
ffffffffc02055aa:	058a                	slli	a1,a1,0x2
ffffffffc02055ac:	95d6                	add	a1,a1,s5
ffffffffc02055ae:	4198                	lw	a4,0(a1)
ffffffffc02055b0:	9756                	add	a4,a4,s5
ffffffffc02055b2:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02055b4:	70e6                	ld	ra,120(sp)
ffffffffc02055b6:	7446                	ld	s0,112(sp)
ffffffffc02055b8:	74a6                	ld	s1,104(sp)
ffffffffc02055ba:	7906                	ld	s2,96(sp)
ffffffffc02055bc:	69e6                	ld	s3,88(sp)
ffffffffc02055be:	6a46                	ld	s4,80(sp)
ffffffffc02055c0:	6aa6                	ld	s5,72(sp)
ffffffffc02055c2:	6b06                	ld	s6,64(sp)
ffffffffc02055c4:	7be2                	ld	s7,56(sp)
ffffffffc02055c6:	7c42                	ld	s8,48(sp)
ffffffffc02055c8:	7ca2                	ld	s9,40(sp)
ffffffffc02055ca:	7d02                	ld	s10,32(sp)
ffffffffc02055cc:	6de2                	ld	s11,24(sp)
ffffffffc02055ce:	6109                	addi	sp,sp,128
ffffffffc02055d0:	8082                	ret
            putch('%', putdat);
ffffffffc02055d2:	85ca                	mv	a1,s2
ffffffffc02055d4:	02500513          	li	a0,37
ffffffffc02055d8:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02055da:	fff44783          	lbu	a5,-1(s0)
ffffffffc02055de:	02500713          	li	a4,37
ffffffffc02055e2:	8c22                	mv	s8,s0
ffffffffc02055e4:	f8e785e3          	beq	a5,a4,ffffffffc020556e <vprintfmt+0x34>
ffffffffc02055e8:	ffec4783          	lbu	a5,-2(s8)
ffffffffc02055ec:	1c7d                	addi	s8,s8,-1
ffffffffc02055ee:	fee79de3          	bne	a5,a4,ffffffffc02055e8 <vprintfmt+0xae>
ffffffffc02055f2:	bfb5                	j	ffffffffc020556e <vprintfmt+0x34>
                ch = *fmt;
ffffffffc02055f4:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc02055f8:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
ffffffffc02055fa:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc02055fe:	fd06071b          	addiw	a4,a2,-48
ffffffffc0205602:	24e56a63          	bltu	a0,a4,ffffffffc0205856 <vprintfmt+0x31c>
                ch = *fmt;
ffffffffc0205606:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205608:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
ffffffffc020560a:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
ffffffffc020560e:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0205612:	0197073b          	addw	a4,a4,s9
ffffffffc0205616:	0017171b          	slliw	a4,a4,0x1
ffffffffc020561a:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
ffffffffc020561c:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0205620:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0205622:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0205626:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
ffffffffc020562a:	feb570e3          	bgeu	a0,a1,ffffffffc020560a <vprintfmt+0xd0>
            if (width < 0)
ffffffffc020562e:	f60d54e3          	bgez	s10,ffffffffc0205596 <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc0205632:	8d66                	mv	s10,s9
ffffffffc0205634:	5cfd                	li	s9,-1
ffffffffc0205636:	b785                	j	ffffffffc0205596 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205638:	8db6                	mv	s11,a3
ffffffffc020563a:	8462                	mv	s0,s8
ffffffffc020563c:	bfa9                	j	ffffffffc0205596 <vprintfmt+0x5c>
ffffffffc020563e:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc0205640:	4b85                	li	s7,1
            goto reswitch;
ffffffffc0205642:	bf91                	j	ffffffffc0205596 <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc0205644:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205646:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020564a:	00f74463          	blt	a4,a5,ffffffffc0205652 <vprintfmt+0x118>
    else if (lflag) {
ffffffffc020564e:	1a078763          	beqz	a5,ffffffffc02057fc <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
ffffffffc0205652:	000a3603          	ld	a2,0(s4)
ffffffffc0205656:	46c1                	li	a3,16
ffffffffc0205658:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020565a:	000d879b          	sext.w	a5,s11
ffffffffc020565e:	876a                	mv	a4,s10
ffffffffc0205660:	85ca                	mv	a1,s2
ffffffffc0205662:	8526                	mv	a0,s1
ffffffffc0205664:	e71ff0ef          	jal	ffffffffc02054d4 <printnum>
            break;
ffffffffc0205668:	b719                	j	ffffffffc020556e <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc020566a:	000a2503          	lw	a0,0(s4)
ffffffffc020566e:	85ca                	mv	a1,s2
ffffffffc0205670:	0a21                	addi	s4,s4,8
ffffffffc0205672:	9482                	jalr	s1
            break;
ffffffffc0205674:	bded                	j	ffffffffc020556e <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0205676:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0205678:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020567c:	00f74463          	blt	a4,a5,ffffffffc0205684 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0205680:	16078963          	beqz	a5,ffffffffc02057f2 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
ffffffffc0205684:	000a3603          	ld	a2,0(s4)
ffffffffc0205688:	46a9                	li	a3,10
ffffffffc020568a:	8a2e                	mv	s4,a1
ffffffffc020568c:	b7f9                	j	ffffffffc020565a <vprintfmt+0x120>
            putch('0', putdat);
ffffffffc020568e:	85ca                	mv	a1,s2
ffffffffc0205690:	03000513          	li	a0,48
ffffffffc0205694:	9482                	jalr	s1
            putch('x', putdat);
ffffffffc0205696:	85ca                	mv	a1,s2
ffffffffc0205698:	07800513          	li	a0,120
ffffffffc020569c:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc020569e:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc02056a2:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02056a4:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02056a6:	bf55                	j	ffffffffc020565a <vprintfmt+0x120>
            putch(ch, putdat);
ffffffffc02056a8:	85ca                	mv	a1,s2
ffffffffc02056aa:	02500513          	li	a0,37
ffffffffc02056ae:	9482                	jalr	s1
            break;
ffffffffc02056b0:	bd7d                	j	ffffffffc020556e <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc02056b2:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02056b6:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc02056b8:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc02056ba:	bf95                	j	ffffffffc020562e <vprintfmt+0xf4>
    if (lflag >= 2) {
ffffffffc02056bc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02056be:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02056c2:	00f74463          	blt	a4,a5,ffffffffc02056ca <vprintfmt+0x190>
    else if (lflag) {
ffffffffc02056c6:	12078163          	beqz	a5,ffffffffc02057e8 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
ffffffffc02056ca:	000a3603          	ld	a2,0(s4)
ffffffffc02056ce:	46a1                	li	a3,8
ffffffffc02056d0:	8a2e                	mv	s4,a1
ffffffffc02056d2:	b761                	j	ffffffffc020565a <vprintfmt+0x120>
            if (width < 0)
ffffffffc02056d4:	876a                	mv	a4,s10
ffffffffc02056d6:	000d5363          	bgez	s10,ffffffffc02056dc <vprintfmt+0x1a2>
ffffffffc02056da:	4701                	li	a4,0
ffffffffc02056dc:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02056e0:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc02056e2:	bd55                	j	ffffffffc0205596 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
ffffffffc02056e4:	000d841b          	sext.w	s0,s11
ffffffffc02056e8:	fd340793          	addi	a5,s0,-45
ffffffffc02056ec:	00f037b3          	snez	a5,a5
ffffffffc02056f0:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02056f4:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
ffffffffc02056f8:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc02056fa:	008a0793          	addi	a5,s4,8
ffffffffc02056fe:	e43e                	sd	a5,8(sp)
ffffffffc0205700:	100d8c63          	beqz	s11,ffffffffc0205818 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc0205704:	12071363          	bnez	a4,ffffffffc020582a <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205708:	000dc783          	lbu	a5,0(s11)
ffffffffc020570c:	0007851b          	sext.w	a0,a5
ffffffffc0205710:	c78d                	beqz	a5,ffffffffc020573a <vprintfmt+0x200>
ffffffffc0205712:	0d85                	addi	s11,s11,1
ffffffffc0205714:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205716:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020571a:	000cc563          	bltz	s9,ffffffffc0205724 <vprintfmt+0x1ea>
ffffffffc020571e:	3cfd                	addiw	s9,s9,-1
ffffffffc0205720:	008c8d63          	beq	s9,s0,ffffffffc020573a <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205724:	020b9663          	bnez	s7,ffffffffc0205750 <vprintfmt+0x216>
                    putch(ch, putdat);
ffffffffc0205728:	85ca                	mv	a1,s2
ffffffffc020572a:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020572c:	000dc783          	lbu	a5,0(s11)
ffffffffc0205730:	0d85                	addi	s11,s11,1
ffffffffc0205732:	3d7d                	addiw	s10,s10,-1
ffffffffc0205734:	0007851b          	sext.w	a0,a5
ffffffffc0205738:	f3ed                	bnez	a5,ffffffffc020571a <vprintfmt+0x1e0>
            for (; width > 0; width --) {
ffffffffc020573a:	01a05963          	blez	s10,ffffffffc020574c <vprintfmt+0x212>
                putch(' ', putdat);
ffffffffc020573e:	85ca                	mv	a1,s2
ffffffffc0205740:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc0205744:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
ffffffffc0205746:	9482                	jalr	s1
            for (; width > 0; width --) {
ffffffffc0205748:	fe0d1be3          	bnez	s10,ffffffffc020573e <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020574c:	6a22                	ld	s4,8(sp)
ffffffffc020574e:	b505                	j	ffffffffc020556e <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0205750:	3781                	addiw	a5,a5,-32
ffffffffc0205752:	fcfa7be3          	bgeu	s4,a5,ffffffffc0205728 <vprintfmt+0x1ee>
                    putch('?', putdat);
ffffffffc0205756:	03f00513          	li	a0,63
ffffffffc020575a:	85ca                	mv	a1,s2
ffffffffc020575c:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020575e:	000dc783          	lbu	a5,0(s11)
ffffffffc0205762:	0d85                	addi	s11,s11,1
ffffffffc0205764:	3d7d                	addiw	s10,s10,-1
ffffffffc0205766:	0007851b          	sext.w	a0,a5
ffffffffc020576a:	dbe1                	beqz	a5,ffffffffc020573a <vprintfmt+0x200>
ffffffffc020576c:	fa0cd9e3          	bgez	s9,ffffffffc020571e <vprintfmt+0x1e4>
ffffffffc0205770:	b7c5                	j	ffffffffc0205750 <vprintfmt+0x216>
            if (err < 0) {
ffffffffc0205772:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205776:	4661                	li	a2,24
            err = va_arg(ap, int);
ffffffffc0205778:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020577a:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc020577e:	8fb9                	xor	a5,a5,a4
ffffffffc0205780:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0205784:	02d64563          	blt	a2,a3,ffffffffc02057ae <vprintfmt+0x274>
ffffffffc0205788:	00002797          	auipc	a5,0x2
ffffffffc020578c:	30878793          	addi	a5,a5,776 # ffffffffc0207a90 <error_string>
ffffffffc0205790:	00369713          	slli	a4,a3,0x3
ffffffffc0205794:	97ba                	add	a5,a5,a4
ffffffffc0205796:	639c                	ld	a5,0(a5)
ffffffffc0205798:	cb99                	beqz	a5,ffffffffc02057ae <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
ffffffffc020579a:	86be                	mv	a3,a5
ffffffffc020579c:	00000617          	auipc	a2,0x0
ffffffffc02057a0:	20c60613          	addi	a2,a2,524 # ffffffffc02059a8 <etext+0x2a>
ffffffffc02057a4:	85ca                	mv	a1,s2
ffffffffc02057a6:	8526                	mv	a0,s1
ffffffffc02057a8:	0d8000ef          	jal	ffffffffc0205880 <printfmt>
ffffffffc02057ac:	b3c9                	j	ffffffffc020556e <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02057ae:	00002617          	auipc	a2,0x2
ffffffffc02057b2:	eca60613          	addi	a2,a2,-310 # ffffffffc0207678 <etext+0x1cfa>
ffffffffc02057b6:	85ca                	mv	a1,s2
ffffffffc02057b8:	8526                	mv	a0,s1
ffffffffc02057ba:	0c6000ef          	jal	ffffffffc0205880 <printfmt>
ffffffffc02057be:	bb45                	j	ffffffffc020556e <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc02057c0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02057c2:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc02057c6:	00f74363          	blt	a4,a5,ffffffffc02057cc <vprintfmt+0x292>
    else if (lflag) {
ffffffffc02057ca:	cf81                	beqz	a5,ffffffffc02057e2 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
ffffffffc02057cc:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02057d0:	02044b63          	bltz	s0,ffffffffc0205806 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc02057d4:	8622                	mv	a2,s0
ffffffffc02057d6:	8a5e                	mv	s4,s7
ffffffffc02057d8:	46a9                	li	a3,10
ffffffffc02057da:	b541                	j	ffffffffc020565a <vprintfmt+0x120>
            lflag ++;
ffffffffc02057dc:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02057de:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc02057e0:	bb5d                	j	ffffffffc0205596 <vprintfmt+0x5c>
        return va_arg(*ap, int);
ffffffffc02057e2:	000a2403          	lw	s0,0(s4)
ffffffffc02057e6:	b7ed                	j	ffffffffc02057d0 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
ffffffffc02057e8:	000a6603          	lwu	a2,0(s4)
ffffffffc02057ec:	46a1                	li	a3,8
ffffffffc02057ee:	8a2e                	mv	s4,a1
ffffffffc02057f0:	b5ad                	j	ffffffffc020565a <vprintfmt+0x120>
ffffffffc02057f2:	000a6603          	lwu	a2,0(s4)
ffffffffc02057f6:	46a9                	li	a3,10
ffffffffc02057f8:	8a2e                	mv	s4,a1
ffffffffc02057fa:	b585                	j	ffffffffc020565a <vprintfmt+0x120>
ffffffffc02057fc:	000a6603          	lwu	a2,0(s4)
ffffffffc0205800:	46c1                	li	a3,16
ffffffffc0205802:	8a2e                	mv	s4,a1
ffffffffc0205804:	bd99                	j	ffffffffc020565a <vprintfmt+0x120>
                putch('-', putdat);
ffffffffc0205806:	85ca                	mv	a1,s2
ffffffffc0205808:	02d00513          	li	a0,45
ffffffffc020580c:	9482                	jalr	s1
                num = -(long long)num;
ffffffffc020580e:	40800633          	neg	a2,s0
ffffffffc0205812:	8a5e                	mv	s4,s7
ffffffffc0205814:	46a9                	li	a3,10
ffffffffc0205816:	b591                	j	ffffffffc020565a <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
ffffffffc0205818:	e329                	bnez	a4,ffffffffc020585a <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020581a:	02800793          	li	a5,40
ffffffffc020581e:	853e                	mv	a0,a5
ffffffffc0205820:	00002d97          	auipc	s11,0x2
ffffffffc0205824:	e51d8d93          	addi	s11,s11,-431 # ffffffffc0207671 <etext+0x1cf3>
ffffffffc0205828:	b5f5                	j	ffffffffc0205714 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020582a:	85e6                	mv	a1,s9
ffffffffc020582c:	856e                	mv	a0,s11
ffffffffc020582e:	08a000ef          	jal	ffffffffc02058b8 <strnlen>
ffffffffc0205832:	40ad0d3b          	subw	s10,s10,a0
ffffffffc0205836:	01a05863          	blez	s10,ffffffffc0205846 <vprintfmt+0x30c>
                    putch(padc, putdat);
ffffffffc020583a:	85ca                	mv	a1,s2
ffffffffc020583c:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020583e:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
ffffffffc0205840:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0205842:	fe0d1ce3          	bnez	s10,ffffffffc020583a <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205846:	000dc783          	lbu	a5,0(s11)
ffffffffc020584a:	0007851b          	sext.w	a0,a5
ffffffffc020584e:	ec0792e3          	bnez	a5,ffffffffc0205712 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0205852:	6a22                	ld	s4,8(sp)
ffffffffc0205854:	bb29                	j	ffffffffc020556e <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0205856:	8462                	mv	s0,s8
ffffffffc0205858:	bbd9                	j	ffffffffc020562e <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020585a:	85e6                	mv	a1,s9
ffffffffc020585c:	00002517          	auipc	a0,0x2
ffffffffc0205860:	e1450513          	addi	a0,a0,-492 # ffffffffc0207670 <etext+0x1cf2>
ffffffffc0205864:	054000ef          	jal	ffffffffc02058b8 <strnlen>
ffffffffc0205868:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020586c:	02800793          	li	a5,40
                p = "(null)";
ffffffffc0205870:	00002d97          	auipc	s11,0x2
ffffffffc0205874:	e00d8d93          	addi	s11,s11,-512 # ffffffffc0207670 <etext+0x1cf2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0205878:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020587a:	fda040e3          	bgtz	s10,ffffffffc020583a <vprintfmt+0x300>
ffffffffc020587e:	bd51                	j	ffffffffc0205712 <vprintfmt+0x1d8>

ffffffffc0205880 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205880:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0205882:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0205886:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205888:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020588a:	ec06                	sd	ra,24(sp)
ffffffffc020588c:	f83a                	sd	a4,48(sp)
ffffffffc020588e:	fc3e                	sd	a5,56(sp)
ffffffffc0205890:	e0c2                	sd	a6,64(sp)
ffffffffc0205892:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0205894:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0205896:	ca5ff0ef          	jal	ffffffffc020553a <vprintfmt>
}
ffffffffc020589a:	60e2                	ld	ra,24(sp)
ffffffffc020589c:	6161                	addi	sp,sp,80
ffffffffc020589e:	8082                	ret

ffffffffc02058a0 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02058a0:	00054783          	lbu	a5,0(a0)
ffffffffc02058a4:	cb81                	beqz	a5,ffffffffc02058b4 <strlen+0x14>
    size_t cnt = 0;
ffffffffc02058a6:	4781                	li	a5,0
        cnt ++;
ffffffffc02058a8:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc02058aa:	00f50733          	add	a4,a0,a5
ffffffffc02058ae:	00074703          	lbu	a4,0(a4)
ffffffffc02058b2:	fb7d                	bnez	a4,ffffffffc02058a8 <strlen+0x8>
    }
    return cnt;
}
ffffffffc02058b4:	853e                	mv	a0,a5
ffffffffc02058b6:	8082                	ret

ffffffffc02058b8 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02058b8:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02058ba:	e589                	bnez	a1,ffffffffc02058c4 <strnlen+0xc>
ffffffffc02058bc:	a811                	j	ffffffffc02058d0 <strnlen+0x18>
        cnt ++;
ffffffffc02058be:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02058c0:	00f58863          	beq	a1,a5,ffffffffc02058d0 <strnlen+0x18>
ffffffffc02058c4:	00f50733          	add	a4,a0,a5
ffffffffc02058c8:	00074703          	lbu	a4,0(a4)
ffffffffc02058cc:	fb6d                	bnez	a4,ffffffffc02058be <strnlen+0x6>
ffffffffc02058ce:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02058d0:	852e                	mv	a0,a1
ffffffffc02058d2:	8082                	ret

ffffffffc02058d4 <strcpy>:
char *
strcpy(char *dst, const char *src) {
#ifdef __HAVE_ARCH_STRCPY
    return __strcpy(dst, src);
#else
    char *p = dst;
ffffffffc02058d4:	87aa                	mv	a5,a0
    while ((*p ++ = *src ++) != '\0')
ffffffffc02058d6:	0005c703          	lbu	a4,0(a1)
ffffffffc02058da:	0585                	addi	a1,a1,1
ffffffffc02058dc:	0785                	addi	a5,a5,1
ffffffffc02058de:	fee78fa3          	sb	a4,-1(a5)
ffffffffc02058e2:	fb75                	bnez	a4,ffffffffc02058d6 <strcpy+0x2>
        /* nothing */;
    return dst;
#endif /* __HAVE_ARCH_STRCPY */
}
ffffffffc02058e4:	8082                	ret

ffffffffc02058e6 <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02058e6:	00054783          	lbu	a5,0(a0)
ffffffffc02058ea:	e791                	bnez	a5,ffffffffc02058f6 <strcmp+0x10>
ffffffffc02058ec:	a01d                	j	ffffffffc0205912 <strcmp+0x2c>
ffffffffc02058ee:	00054783          	lbu	a5,0(a0)
ffffffffc02058f2:	cb99                	beqz	a5,ffffffffc0205908 <strcmp+0x22>
ffffffffc02058f4:	0585                	addi	a1,a1,1
ffffffffc02058f6:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc02058fa:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02058fc:	fef709e3          	beq	a4,a5,ffffffffc02058ee <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205900:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0205904:	9d19                	subw	a0,a0,a4
ffffffffc0205906:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205908:	0015c703          	lbu	a4,1(a1)
ffffffffc020590c:	4501                	li	a0,0
}
ffffffffc020590e:	9d19                	subw	a0,a0,a4
ffffffffc0205910:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205912:	0005c703          	lbu	a4,0(a1)
ffffffffc0205916:	4501                	li	a0,0
ffffffffc0205918:	b7f5                	j	ffffffffc0205904 <strcmp+0x1e>

ffffffffc020591a <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020591a:	ce01                	beqz	a2,ffffffffc0205932 <strncmp+0x18>
ffffffffc020591c:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0205920:	167d                	addi	a2,a2,-1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205922:	cb91                	beqz	a5,ffffffffc0205936 <strncmp+0x1c>
ffffffffc0205924:	0005c703          	lbu	a4,0(a1)
ffffffffc0205928:	00f71763          	bne	a4,a5,ffffffffc0205936 <strncmp+0x1c>
        n --, s1 ++, s2 ++;
ffffffffc020592c:	0505                	addi	a0,a0,1
ffffffffc020592e:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0205930:	f675                	bnez	a2,ffffffffc020591c <strncmp+0x2>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0205932:	4501                	li	a0,0
ffffffffc0205934:	8082                	ret
ffffffffc0205936:	00054503          	lbu	a0,0(a0)
ffffffffc020593a:	0005c783          	lbu	a5,0(a1)
ffffffffc020593e:	9d1d                	subw	a0,a0,a5
}
ffffffffc0205940:	8082                	ret

ffffffffc0205942 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0205942:	a021                	j	ffffffffc020594a <strchr+0x8>
        if (*s == c) {
ffffffffc0205944:	00f58763          	beq	a1,a5,ffffffffc0205952 <strchr+0x10>
            return (char *)s;
        }
        s ++;
ffffffffc0205948:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc020594a:	00054783          	lbu	a5,0(a0)
ffffffffc020594e:	fbfd                	bnez	a5,ffffffffc0205944 <strchr+0x2>
    }
    return NULL;
ffffffffc0205950:	4501                	li	a0,0
}
ffffffffc0205952:	8082                	ret

ffffffffc0205954 <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0205954:	ca01                	beqz	a2,ffffffffc0205964 <memset+0x10>
ffffffffc0205956:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0205958:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc020595a:	0785                	addi	a5,a5,1
ffffffffc020595c:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0205960:	fef61de3          	bne	a2,a5,ffffffffc020595a <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0205964:	8082                	ret

ffffffffc0205966 <memcpy>:
#ifdef __HAVE_ARCH_MEMCPY
    return __memcpy(dst, src, n);
#else
    const char *s = src;
    char *d = dst;
    while (n -- > 0) {
ffffffffc0205966:	ca19                	beqz	a2,ffffffffc020597c <memcpy+0x16>
ffffffffc0205968:	962e                	add	a2,a2,a1
    char *d = dst;
ffffffffc020596a:	87aa                	mv	a5,a0
        *d ++ = *s ++;
ffffffffc020596c:	0005c703          	lbu	a4,0(a1)
ffffffffc0205970:	0585                	addi	a1,a1,1
ffffffffc0205972:	0785                	addi	a5,a5,1
ffffffffc0205974:	fee78fa3          	sb	a4,-1(a5)
    while (n -- > 0) {
ffffffffc0205978:	feb61ae3          	bne	a2,a1,ffffffffc020596c <memcpy+0x6>
    }
    return dst;
#endif /* __HAVE_ARCH_MEMCPY */
}
ffffffffc020597c:	8082                	ret
