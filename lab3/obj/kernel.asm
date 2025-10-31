
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00007297          	auipc	t0,0x7
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0207000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00007297          	auipc	t0,0x7
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0207008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02062b7          	lui	t0,0xc0206
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
ffffffffc020003c:	c0206137          	lui	sp,0xc0206

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 1. 使用临时寄存器 t1 计算栈顶的精确地址
    lui t1, %hi(bootstacktop)
ffffffffc0200040:	c0206337          	lui	t1,0xc0206
    addi t1, t1, %lo(bootstacktop)
ffffffffc0200044:	00030313          	mv	t1,t1
    # 2. 将精确地址一次性地、安全地传给 sp
    mv sp, t1
ffffffffc0200048:	811a                	mv	sp,t1
    # 现在栈指针已经完美设置，可以安全地调用任何C函数了
    # 然后跳转到 kern_init (不再返回)
    lui t0, %hi(kern_init)
ffffffffc020004a:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc020004e:	05428293          	addi	t0,t0,84 # ffffffffc0200054 <kern_init>
    jr t0
ffffffffc0200052:	8282                	jr	t0

ffffffffc0200054 <kern_init>:
void grade_backtrace(void);

int kern_init(void) {
    extern char edata[], end[];
    // 先清零 BSS，再读取并保存 DTB 的内存信息，避免被清零覆盖（为了解释变化 正式上传时我觉得应该删去这句话）
    memset(edata, 0, end - edata);
ffffffffc0200054:	00007517          	auipc	a0,0x7
ffffffffc0200058:	fd450513          	addi	a0,a0,-44 # ffffffffc0207028 <free_area>
ffffffffc020005c:	00007617          	auipc	a2,0x7
ffffffffc0200060:	43c60613          	addi	a2,a2,1084 # ffffffffc0207498 <end>
int kern_init(void) {
ffffffffc0200064:	1141                	addi	sp,sp,-16 # ffffffffc0205ff0 <bootstack+0x1ff0>
    memset(edata, 0, end - edata);
ffffffffc0200066:	8e09                	sub	a2,a2,a0
ffffffffc0200068:	4581                	li	a1,0
int kern_init(void) {
ffffffffc020006a:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc020006c:	77f010ef          	jal	ffffffffc0201fea <memset>
    dtb_init();
ffffffffc0200070:	3fc000ef          	jal	ffffffffc020046c <dtb_init>
    cons_init();  // init the console
ffffffffc0200074:	3ea000ef          	jal	ffffffffc020045e <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc0200078:	00003517          	auipc	a0,0x3
ffffffffc020007c:	ea850513          	addi	a0,a0,-344 # ffffffffc0202f20 <etext+0xf24>
ffffffffc0200080:	0c2000ef          	jal	ffffffffc0200142 <cputs>

    print_kerninfo();
ffffffffc0200084:	11a000ef          	jal	ffffffffc020019e <print_kerninfo>

    //grade_backtrace();
    idt_init();  // init interrupt descriptor table
ffffffffc0200088:	736000ef          	jal	ffffffffc02007be <idt_init>

    pmm_init();  // init physical memory management
ffffffffc020008c:	7f4010ef          	jal	ffffffffc0201880 <pmm_init>

    idt_init();  // init interrupt descriptor table
ffffffffc0200090:	72e000ef          	jal	ffffffffc02007be <idt_init>

    clock_init();   // init clock interrupt
ffffffffc0200094:	388000ef          	jal	ffffffffc020041c <clock_init>
    intr_enable();  // enable irq interrupt
ffffffffc0200098:	71a000ef          	jal	ffffffffc02007b2 <intr_enable>



    cprintf("CHALLENGE3 TEST Start:\n");
ffffffffc020009c:	00002517          	auipc	a0,0x2
ffffffffc02000a0:	f6450513          	addi	a0,a0,-156 # ffffffffc0202000 <etext+0x4>
ffffffffc02000a4:	068000ef          	jal	ffffffffc020010c <cprintf>
    cprintf("1. Execute a wrong instruction to trigger an exception.\n");
ffffffffc02000a8:	00002517          	auipc	a0,0x2
ffffffffc02000ac:	f7050513          	addi	a0,a0,-144 # ffffffffc0202018 <etext+0x1c>
ffffffffc02000b0:	05c000ef          	jal	ffffffffc020010c <cprintf>
    asm volatile(".word 0x00000000");
ffffffffc02000b4:	00000000          	.word	0x00000000
    cprintf("2. Ebreak.\n");
ffffffffc02000b8:	00002517          	auipc	a0,0x2
ffffffffc02000bc:	fa050513          	addi	a0,a0,-96 # ffffffffc0202058 <etext+0x5c>
ffffffffc02000c0:	04c000ef          	jal	ffffffffc020010c <cprintf>
    asm volatile("ebreak");
ffffffffc02000c4:	9002                	ebreak
    cprintf("CHALLENGE3 TEST End.\n");
ffffffffc02000c6:	00002517          	auipc	a0,0x2
ffffffffc02000ca:	fa250513          	addi	a0,a0,-94 # ffffffffc0202068 <etext+0x6c>
ffffffffc02000ce:	03e000ef          	jal	ffffffffc020010c <cprintf>
    while (1)
ffffffffc02000d2:	a001                	j	ffffffffc02000d2 <kern_init+0x7e>

ffffffffc02000d4 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc02000d4:	1101                	addi	sp,sp,-32
ffffffffc02000d6:	ec06                	sd	ra,24(sp)
ffffffffc02000d8:	e42e                	sd	a1,8(sp)
    cons_putc(c);
ffffffffc02000da:	386000ef          	jal	ffffffffc0200460 <cons_putc>
    (*cnt) ++;
ffffffffc02000de:	65a2                	ld	a1,8(sp)
}
ffffffffc02000e0:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
ffffffffc02000e2:	419c                	lw	a5,0(a1)
ffffffffc02000e4:	2785                	addiw	a5,a5,1
ffffffffc02000e6:	c19c                	sw	a5,0(a1)
}
ffffffffc02000e8:	6105                	addi	sp,sp,32
ffffffffc02000ea:	8082                	ret

ffffffffc02000ec <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000ec:	1101                	addi	sp,sp,-32
ffffffffc02000ee:	862a                	mv	a2,a0
ffffffffc02000f0:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc02000f2:	00000517          	auipc	a0,0x0
ffffffffc02000f6:	fe250513          	addi	a0,a0,-30 # ffffffffc02000d4 <cputch>
ffffffffc02000fa:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc02000fc:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc02000fe:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200100:	1c3010ef          	jal	ffffffffc0201ac2 <vprintfmt>
    return cnt;
}
ffffffffc0200104:	60e2                	ld	ra,24(sp)
ffffffffc0200106:	4532                	lw	a0,12(sp)
ffffffffc0200108:	6105                	addi	sp,sp,32
ffffffffc020010a:	8082                	ret

ffffffffc020010c <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc020010c:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc020010e:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
ffffffffc0200112:	f42e                	sd	a1,40(sp)
ffffffffc0200114:	f832                	sd	a2,48(sp)
ffffffffc0200116:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200118:	862a                	mv	a2,a0
ffffffffc020011a:	004c                	addi	a1,sp,4
ffffffffc020011c:	00000517          	auipc	a0,0x0
ffffffffc0200120:	fb850513          	addi	a0,a0,-72 # ffffffffc02000d4 <cputch>
ffffffffc0200124:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc0200126:	ec06                	sd	ra,24(sp)
ffffffffc0200128:	e0ba                	sd	a4,64(sp)
ffffffffc020012a:	e4be                	sd	a5,72(sp)
ffffffffc020012c:	e8c2                	sd	a6,80(sp)
ffffffffc020012e:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
ffffffffc0200130:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
ffffffffc0200132:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200134:	18f010ef          	jal	ffffffffc0201ac2 <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc0200138:	60e2                	ld	ra,24(sp)
ffffffffc020013a:	4512                	lw	a0,4(sp)
ffffffffc020013c:	6125                	addi	sp,sp,96
ffffffffc020013e:	8082                	ret

ffffffffc0200140 <cputchar>:

/* cputchar - writes a single character to stdout */
void
cputchar(int c) {
    cons_putc(c);
ffffffffc0200140:	a605                	j	ffffffffc0200460 <cons_putc>

ffffffffc0200142 <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc0200142:	1101                	addi	sp,sp,-32
ffffffffc0200144:	e822                	sd	s0,16(sp)
ffffffffc0200146:	ec06                	sd	ra,24(sp)
ffffffffc0200148:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc020014a:	00054503          	lbu	a0,0(a0)
ffffffffc020014e:	c51d                	beqz	a0,ffffffffc020017c <cputs+0x3a>
ffffffffc0200150:	e426                	sd	s1,8(sp)
ffffffffc0200152:	0405                	addi	s0,s0,1
    int cnt = 0;
ffffffffc0200154:	4481                	li	s1,0
    cons_putc(c);
ffffffffc0200156:	30a000ef          	jal	ffffffffc0200460 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc020015a:	00044503          	lbu	a0,0(s0)
ffffffffc020015e:	0405                	addi	s0,s0,1
ffffffffc0200160:	87a6                	mv	a5,s1
    (*cnt) ++;
ffffffffc0200162:	2485                	addiw	s1,s1,1
    while ((c = *str ++) != '\0') {
ffffffffc0200164:	f96d                	bnez	a0,ffffffffc0200156 <cputs+0x14>
    cons_putc(c);
ffffffffc0200166:	4529                	li	a0,10
    (*cnt) ++;
ffffffffc0200168:	0027841b          	addiw	s0,a5,2
ffffffffc020016c:	64a2                	ld	s1,8(sp)
    cons_putc(c);
ffffffffc020016e:	2f2000ef          	jal	ffffffffc0200460 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc0200172:	60e2                	ld	ra,24(sp)
ffffffffc0200174:	8522                	mv	a0,s0
ffffffffc0200176:	6442                	ld	s0,16(sp)
ffffffffc0200178:	6105                	addi	sp,sp,32
ffffffffc020017a:	8082                	ret
    cons_putc(c);
ffffffffc020017c:	4529                	li	a0,10
ffffffffc020017e:	2e2000ef          	jal	ffffffffc0200460 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200182:	4405                	li	s0,1
}
ffffffffc0200184:	60e2                	ld	ra,24(sp)
ffffffffc0200186:	8522                	mv	a0,s0
ffffffffc0200188:	6442                	ld	s0,16(sp)
ffffffffc020018a:	6105                	addi	sp,sp,32
ffffffffc020018c:	8082                	ret

ffffffffc020018e <getchar>:

/* getchar - reads a single non-zero character from stdin */
int
getchar(void) {
ffffffffc020018e:	1141                	addi	sp,sp,-16
ffffffffc0200190:	e406                	sd	ra,8(sp)
    int c;
    while ((c = cons_getc()) == 0)
ffffffffc0200192:	2d6000ef          	jal	ffffffffc0200468 <cons_getc>
ffffffffc0200196:	dd75                	beqz	a0,ffffffffc0200192 <getchar+0x4>
        /* do nothing */;
    return c;
}
ffffffffc0200198:	60a2                	ld	ra,8(sp)
ffffffffc020019a:	0141                	addi	sp,sp,16
ffffffffc020019c:	8082                	ret

ffffffffc020019e <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020019e:	1141                	addi	sp,sp,-16
    extern char etext[], edata[], end[], kern_init[];
    cprintf("Special kernel symbols:\n");
ffffffffc02001a0:	00002517          	auipc	a0,0x2
ffffffffc02001a4:	ee050513          	addi	a0,a0,-288 # ffffffffc0202080 <etext+0x84>
void print_kerninfo(void) {
ffffffffc02001a8:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc02001aa:	f63ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", kern_init);
ffffffffc02001ae:	00000597          	auipc	a1,0x0
ffffffffc02001b2:	ea658593          	addi	a1,a1,-346 # ffffffffc0200054 <kern_init>
ffffffffc02001b6:	00002517          	auipc	a0,0x2
ffffffffc02001ba:	eea50513          	addi	a0,a0,-278 # ffffffffc02020a0 <etext+0xa4>
ffffffffc02001be:	f4fff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc02001c2:	00002597          	auipc	a1,0x2
ffffffffc02001c6:	e3a58593          	addi	a1,a1,-454 # ffffffffc0201ffc <etext>
ffffffffc02001ca:	00002517          	auipc	a0,0x2
ffffffffc02001ce:	ef650513          	addi	a0,a0,-266 # ffffffffc02020c0 <etext+0xc4>
ffffffffc02001d2:	f3bff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc02001d6:	00007597          	auipc	a1,0x7
ffffffffc02001da:	e5258593          	addi	a1,a1,-430 # ffffffffc0207028 <free_area>
ffffffffc02001de:	00002517          	auipc	a0,0x2
ffffffffc02001e2:	f0250513          	addi	a0,a0,-254 # ffffffffc02020e0 <etext+0xe4>
ffffffffc02001e6:	f27ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc02001ea:	00007597          	auipc	a1,0x7
ffffffffc02001ee:	2ae58593          	addi	a1,a1,686 # ffffffffc0207498 <end>
ffffffffc02001f2:	00002517          	auipc	a0,0x2
ffffffffc02001f6:	f0e50513          	addi	a0,a0,-242 # ffffffffc0202100 <etext+0x104>
ffffffffc02001fa:	f13ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - kern_init + 1023) / 1024);
ffffffffc02001fe:	00000717          	auipc	a4,0x0
ffffffffc0200202:	e5670713          	addi	a4,a4,-426 # ffffffffc0200054 <kern_init>
ffffffffc0200206:	00007797          	auipc	a5,0x7
ffffffffc020020a:	69178793          	addi	a5,a5,1681 # ffffffffc0207897 <end+0x3ff>
ffffffffc020020e:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200210:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc0200214:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200216:	3ff5f593          	andi	a1,a1,1023
ffffffffc020021a:	95be                	add	a1,a1,a5
ffffffffc020021c:	85a9                	srai	a1,a1,0xa
ffffffffc020021e:	00002517          	auipc	a0,0x2
ffffffffc0200222:	f0250513          	addi	a0,a0,-254 # ffffffffc0202120 <etext+0x124>
}
ffffffffc0200226:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc0200228:	b5d5                	j	ffffffffc020010c <cprintf>

ffffffffc020022a <print_stackframe>:
 * Note that, the length of ebp-chain is limited. In boot/bootasm.S, before
 * jumping
 * to the kernel entry, the value of ebp has been set to zero, that's the
 * boundary.
 * */
void print_stackframe(void) {
ffffffffc020022a:	1141                	addi	sp,sp,-16
    panic("Not Implemented!");
ffffffffc020022c:	00002617          	auipc	a2,0x2
ffffffffc0200230:	f2460613          	addi	a2,a2,-220 # ffffffffc0202150 <etext+0x154>
ffffffffc0200234:	04d00593          	li	a1,77
ffffffffc0200238:	00002517          	auipc	a0,0x2
ffffffffc020023c:	f3050513          	addi	a0,a0,-208 # ffffffffc0202168 <etext+0x16c>
void print_stackframe(void) {
ffffffffc0200240:	e406                	sd	ra,8(sp)
    panic("Not Implemented!");
ffffffffc0200242:	17c000ef          	jal	ffffffffc02003be <__panic>

ffffffffc0200246 <mon_help>:
    }
}

/* mon_help - print the information about mon_* functions */
int
mon_help(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200246:	1101                	addi	sp,sp,-32
ffffffffc0200248:	e822                	sd	s0,16(sp)
ffffffffc020024a:	e426                	sd	s1,8(sp)
ffffffffc020024c:	ec06                	sd	ra,24(sp)
ffffffffc020024e:	00003417          	auipc	s0,0x3
ffffffffc0200252:	cf240413          	addi	s0,s0,-782 # ffffffffc0202f40 <commands>
ffffffffc0200256:	00003497          	auipc	s1,0x3
ffffffffc020025a:	d3248493          	addi	s1,s1,-718 # ffffffffc0202f88 <commands+0x48>
    int i;
    for (i = 0; i < NCOMMANDS; i ++) {
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020025e:	6410                	ld	a2,8(s0)
ffffffffc0200260:	600c                	ld	a1,0(s0)
ffffffffc0200262:	00002517          	auipc	a0,0x2
ffffffffc0200266:	f1e50513          	addi	a0,a0,-226 # ffffffffc0202180 <etext+0x184>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020026a:	0461                	addi	s0,s0,24
        cprintf("%s - %s\n", commands[i].name, commands[i].desc);
ffffffffc020026c:	ea1ff0ef          	jal	ffffffffc020010c <cprintf>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200270:	fe9417e3          	bne	s0,s1,ffffffffc020025e <mon_help+0x18>
    }
    return 0;
}
ffffffffc0200274:	60e2                	ld	ra,24(sp)
ffffffffc0200276:	6442                	ld	s0,16(sp)
ffffffffc0200278:	64a2                	ld	s1,8(sp)
ffffffffc020027a:	4501                	li	a0,0
ffffffffc020027c:	6105                	addi	sp,sp,32
ffffffffc020027e:	8082                	ret

ffffffffc0200280 <mon_kerninfo>:
/* *
 * mon_kerninfo - call print_kerninfo in kern/debug/kdebug.c to
 * print the memory occupancy in kernel.
 * */
int
mon_kerninfo(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200280:	1141                	addi	sp,sp,-16
ffffffffc0200282:	e406                	sd	ra,8(sp)
    print_kerninfo();
ffffffffc0200284:	f1bff0ef          	jal	ffffffffc020019e <print_kerninfo>
    return 0;
}
ffffffffc0200288:	60a2                	ld	ra,8(sp)
ffffffffc020028a:	4501                	li	a0,0
ffffffffc020028c:	0141                	addi	sp,sp,16
ffffffffc020028e:	8082                	ret

ffffffffc0200290 <mon_backtrace>:
/* *
 * mon_backtrace - call print_stackframe in kern/debug/kdebug.c to
 * print a backtrace of the stack.
 * */
int
mon_backtrace(int argc, char **argv, struct trapframe *tf) {
ffffffffc0200290:	1141                	addi	sp,sp,-16
ffffffffc0200292:	e406                	sd	ra,8(sp)
    print_stackframe();
ffffffffc0200294:	f97ff0ef          	jal	ffffffffc020022a <print_stackframe>
    return 0;
}
ffffffffc0200298:	60a2                	ld	ra,8(sp)
ffffffffc020029a:	4501                	li	a0,0
ffffffffc020029c:	0141                	addi	sp,sp,16
ffffffffc020029e:	8082                	ret

ffffffffc02002a0 <kmonitor>:
kmonitor(struct trapframe *tf) {
ffffffffc02002a0:	7131                	addi	sp,sp,-192
ffffffffc02002a2:	e952                	sd	s4,144(sp)
ffffffffc02002a4:	8a2a                	mv	s4,a0
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002a6:	00002517          	auipc	a0,0x2
ffffffffc02002aa:	eea50513          	addi	a0,a0,-278 # ffffffffc0202190 <etext+0x194>
kmonitor(struct trapframe *tf) {
ffffffffc02002ae:	fd06                	sd	ra,184(sp)
ffffffffc02002b0:	f922                	sd	s0,176(sp)
ffffffffc02002b2:	f526                	sd	s1,168(sp)
ffffffffc02002b4:	ed4e                	sd	s3,152(sp)
ffffffffc02002b6:	e556                	sd	s5,136(sp)
ffffffffc02002b8:	e15a                	sd	s6,128(sp)
    cprintf("Welcome to the kernel debug monitor!!\n");
ffffffffc02002ba:	e53ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("Type 'help' for a list of commands.\n");
ffffffffc02002be:	00002517          	auipc	a0,0x2
ffffffffc02002c2:	efa50513          	addi	a0,a0,-262 # ffffffffc02021b8 <etext+0x1bc>
ffffffffc02002c6:	e47ff0ef          	jal	ffffffffc020010c <cprintf>
    if (tf != NULL) {
ffffffffc02002ca:	000a0563          	beqz	s4,ffffffffc02002d4 <kmonitor+0x34>
        print_trapframe(tf);
ffffffffc02002ce:	8552                	mv	a0,s4
ffffffffc02002d0:	6ce000ef          	jal	ffffffffc020099e <print_trapframe>
ffffffffc02002d4:	00003a97          	auipc	s5,0x3
ffffffffc02002d8:	c6ca8a93          	addi	s5,s5,-916 # ffffffffc0202f40 <commands>
        if (argc == MAXARGS - 1) {
ffffffffc02002dc:	49bd                	li	s3,15
        if ((buf = readline("K> ")) != NULL) {
ffffffffc02002de:	00002517          	auipc	a0,0x2
ffffffffc02002e2:	f0250513          	addi	a0,a0,-254 # ffffffffc02021e0 <etext+0x1e4>
ffffffffc02002e6:	343010ef          	jal	ffffffffc0201e28 <readline>
ffffffffc02002ea:	842a                	mv	s0,a0
ffffffffc02002ec:	d96d                	beqz	a0,ffffffffc02002de <kmonitor+0x3e>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002ee:	00054583          	lbu	a1,0(a0)
    int argc = 0;
ffffffffc02002f2:	4481                	li	s1,0
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc02002f4:	e99d                	bnez	a1,ffffffffc020032a <kmonitor+0x8a>
    int argc = 0;
ffffffffc02002f6:	8b26                	mv	s6,s1
    if (argc == 0) {
ffffffffc02002f8:	fe0b03e3          	beqz	s6,ffffffffc02002de <kmonitor+0x3e>
ffffffffc02002fc:	00003497          	auipc	s1,0x3
ffffffffc0200300:	c4448493          	addi	s1,s1,-956 # ffffffffc0202f40 <commands>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200304:	4401                	li	s0,0
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200306:	6582                	ld	a1,0(sp)
ffffffffc0200308:	6088                	ld	a0,0(s1)
ffffffffc020030a:	473010ef          	jal	ffffffffc0201f7c <strcmp>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc020030e:	478d                	li	a5,3
        if (strcmp(commands[i].name, argv[0]) == 0) {
ffffffffc0200310:	c149                	beqz	a0,ffffffffc0200392 <kmonitor+0xf2>
    for (i = 0; i < NCOMMANDS; i ++) {
ffffffffc0200312:	2405                	addiw	s0,s0,1
ffffffffc0200314:	04e1                	addi	s1,s1,24
ffffffffc0200316:	fef418e3          	bne	s0,a5,ffffffffc0200306 <kmonitor+0x66>
    cprintf("Unknown command '%s'\n", argv[0]);
ffffffffc020031a:	6582                	ld	a1,0(sp)
ffffffffc020031c:	00002517          	auipc	a0,0x2
ffffffffc0200320:	ef450513          	addi	a0,a0,-268 # ffffffffc0202210 <etext+0x214>
ffffffffc0200324:	de9ff0ef          	jal	ffffffffc020010c <cprintf>
    return 0;
ffffffffc0200328:	bf5d                	j	ffffffffc02002de <kmonitor+0x3e>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020032a:	00002517          	auipc	a0,0x2
ffffffffc020032e:	ebe50513          	addi	a0,a0,-322 # ffffffffc02021e8 <etext+0x1ec>
ffffffffc0200332:	4a7010ef          	jal	ffffffffc0201fd8 <strchr>
ffffffffc0200336:	c901                	beqz	a0,ffffffffc0200346 <kmonitor+0xa6>
ffffffffc0200338:	00144583          	lbu	a1,1(s0)
            *buf ++ = '\0';
ffffffffc020033c:	00040023          	sb	zero,0(s0)
ffffffffc0200340:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc0200342:	d9d5                	beqz	a1,ffffffffc02002f6 <kmonitor+0x56>
ffffffffc0200344:	b7dd                	j	ffffffffc020032a <kmonitor+0x8a>
        if (*buf == '\0') {
ffffffffc0200346:	00044783          	lbu	a5,0(s0)
ffffffffc020034a:	d7d5                	beqz	a5,ffffffffc02002f6 <kmonitor+0x56>
        if (argc == MAXARGS - 1) {
ffffffffc020034c:	03348b63          	beq	s1,s3,ffffffffc0200382 <kmonitor+0xe2>
        argv[argc ++] = buf;
ffffffffc0200350:	00349793          	slli	a5,s1,0x3
ffffffffc0200354:	978a                	add	a5,a5,sp
ffffffffc0200356:	e380                	sd	s0,0(a5)
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200358:	00044583          	lbu	a1,0(s0)
        argv[argc ++] = buf;
ffffffffc020035c:	2485                	addiw	s1,s1,1
ffffffffc020035e:	8b26                	mv	s6,s1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc0200360:	e591                	bnez	a1,ffffffffc020036c <kmonitor+0xcc>
ffffffffc0200362:	bf59                	j	ffffffffc02002f8 <kmonitor+0x58>
ffffffffc0200364:	00144583          	lbu	a1,1(s0)
            buf ++;
ffffffffc0200368:	0405                	addi	s0,s0,1
        while (*buf != '\0' && strchr(WHITESPACE, *buf) == NULL) {
ffffffffc020036a:	d5d1                	beqz	a1,ffffffffc02002f6 <kmonitor+0x56>
ffffffffc020036c:	00002517          	auipc	a0,0x2
ffffffffc0200370:	e7c50513          	addi	a0,a0,-388 # ffffffffc02021e8 <etext+0x1ec>
ffffffffc0200374:	465010ef          	jal	ffffffffc0201fd8 <strchr>
ffffffffc0200378:	d575                	beqz	a0,ffffffffc0200364 <kmonitor+0xc4>
        while (*buf != '\0' && strchr(WHITESPACE, *buf) != NULL) {
ffffffffc020037a:	00044583          	lbu	a1,0(s0)
ffffffffc020037e:	dda5                	beqz	a1,ffffffffc02002f6 <kmonitor+0x56>
ffffffffc0200380:	b76d                	j	ffffffffc020032a <kmonitor+0x8a>
            cprintf("Too many arguments (max %d).\n", MAXARGS);
ffffffffc0200382:	45c1                	li	a1,16
ffffffffc0200384:	00002517          	auipc	a0,0x2
ffffffffc0200388:	e6c50513          	addi	a0,a0,-404 # ffffffffc02021f0 <etext+0x1f4>
ffffffffc020038c:	d81ff0ef          	jal	ffffffffc020010c <cprintf>
ffffffffc0200390:	b7c1                	j	ffffffffc0200350 <kmonitor+0xb0>
            return commands[i].func(argc - 1, argv + 1, tf);
ffffffffc0200392:	00141793          	slli	a5,s0,0x1
ffffffffc0200396:	97a2                	add	a5,a5,s0
ffffffffc0200398:	078e                	slli	a5,a5,0x3
ffffffffc020039a:	97d6                	add	a5,a5,s5
ffffffffc020039c:	6b9c                	ld	a5,16(a5)
ffffffffc020039e:	fffb051b          	addiw	a0,s6,-1
ffffffffc02003a2:	8652                	mv	a2,s4
ffffffffc02003a4:	002c                	addi	a1,sp,8
ffffffffc02003a6:	9782                	jalr	a5
            if (runcmd(buf, tf) < 0) {
ffffffffc02003a8:	f2055be3          	bgez	a0,ffffffffc02002de <kmonitor+0x3e>
}
ffffffffc02003ac:	70ea                	ld	ra,184(sp)
ffffffffc02003ae:	744a                	ld	s0,176(sp)
ffffffffc02003b0:	74aa                	ld	s1,168(sp)
ffffffffc02003b2:	69ea                	ld	s3,152(sp)
ffffffffc02003b4:	6a4a                	ld	s4,144(sp)
ffffffffc02003b6:	6aaa                	ld	s5,136(sp)
ffffffffc02003b8:	6b0a                	ld	s6,128(sp)
ffffffffc02003ba:	6129                	addi	sp,sp,192
ffffffffc02003bc:	8082                	ret

ffffffffc02003be <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02003be:	00007317          	auipc	t1,0x7
ffffffffc02003c2:	08232303          	lw	t1,130(t1) # ffffffffc0207440 <is_panic>
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02003c6:	715d                	addi	sp,sp,-80
ffffffffc02003c8:	ec06                	sd	ra,24(sp)
ffffffffc02003ca:	f436                	sd	a3,40(sp)
ffffffffc02003cc:	f83a                	sd	a4,48(sp)
ffffffffc02003ce:	fc3e                	sd	a5,56(sp)
ffffffffc02003d0:	e0c2                	sd	a6,64(sp)
ffffffffc02003d2:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02003d4:	02031e63          	bnez	t1,ffffffffc0200410 <__panic+0x52>
        goto panic_dead;
    }
    is_panic = 1;
ffffffffc02003d8:	4705                	li	a4,1

    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
ffffffffc02003da:	103c                	addi	a5,sp,40
ffffffffc02003dc:	e822                	sd	s0,16(sp)
ffffffffc02003de:	8432                	mv	s0,a2
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003e0:	862e                	mv	a2,a1
ffffffffc02003e2:	85aa                	mv	a1,a0
ffffffffc02003e4:	00002517          	auipc	a0,0x2
ffffffffc02003e8:	ed450513          	addi	a0,a0,-300 # ffffffffc02022b8 <etext+0x2bc>
    is_panic = 1;
ffffffffc02003ec:	00007697          	auipc	a3,0x7
ffffffffc02003f0:	04e6aa23          	sw	a4,84(a3) # ffffffffc0207440 <is_panic>
    va_start(ap, fmt);
ffffffffc02003f4:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02003f6:	d17ff0ef          	jal	ffffffffc020010c <cprintf>
    vcprintf(fmt, ap);
ffffffffc02003fa:	65a2                	ld	a1,8(sp)
ffffffffc02003fc:	8522                	mv	a0,s0
ffffffffc02003fe:	cefff0ef          	jal	ffffffffc02000ec <vcprintf>
    cprintf("\n");
ffffffffc0200402:	00002517          	auipc	a0,0x2
ffffffffc0200406:	ed650513          	addi	a0,a0,-298 # ffffffffc02022d8 <etext+0x2dc>
ffffffffc020040a:	d03ff0ef          	jal	ffffffffc020010c <cprintf>
ffffffffc020040e:	6442                	ld	s0,16(sp)
    va_end(ap);

panic_dead:
    intr_disable();
ffffffffc0200410:	3a8000ef          	jal	ffffffffc02007b8 <intr_disable>
    while (1) {
        kmonitor(NULL);
ffffffffc0200414:	4501                	li	a0,0
ffffffffc0200416:	e8bff0ef          	jal	ffffffffc02002a0 <kmonitor>
    while (1) {
ffffffffc020041a:	bfed                	j	ffffffffc0200414 <__panic+0x56>

ffffffffc020041c <clock_init>:

/* *
 * clock_init - initialize 8253 clock to interrupt 100 times per second,
 * and then enable IRQ_TIMER.
 * */
void clock_init(void) {
ffffffffc020041c:	1141                	addi	sp,sp,-16
ffffffffc020041e:	e406                	sd	ra,8(sp)
    // enable timer interrupt in sie
    set_csr(sie, MIP_STIP);
ffffffffc0200420:	02000793          	li	a5,32
ffffffffc0200424:	1047a7f3          	csrrs	a5,sie,a5
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc0200428:	c0102573          	rdtime	a0
    ticks = 0;

    cprintf("++ setup timer interrupts\n");
}

void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc020042c:	67e1                	lui	a5,0x18
ffffffffc020042e:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200432:	953e                	add	a0,a0,a5
ffffffffc0200434:	2c5010ef          	jal	ffffffffc0201ef8 <sbi_set_timer>
}
ffffffffc0200438:	60a2                	ld	ra,8(sp)
    ticks = 0;
ffffffffc020043a:	00007797          	auipc	a5,0x7
ffffffffc020043e:	0007b723          	sd	zero,14(a5) # ffffffffc0207448 <ticks>
    cprintf("++ setup timer interrupts\n");
ffffffffc0200442:	00002517          	auipc	a0,0x2
ffffffffc0200446:	e9e50513          	addi	a0,a0,-354 # ffffffffc02022e0 <etext+0x2e4>
}
ffffffffc020044a:	0141                	addi	sp,sp,16
    cprintf("++ setup timer interrupts\n");
ffffffffc020044c:	b1c1                	j	ffffffffc020010c <cprintf>

ffffffffc020044e <clock_set_next_event>:
    __asm__ __volatile__("rdtime %0" : "=r"(n));
ffffffffc020044e:	c0102573          	rdtime	a0
void clock_set_next_event(void) { sbi_set_timer(get_cycles() + timebase); }
ffffffffc0200452:	67e1                	lui	a5,0x18
ffffffffc0200454:	6a078793          	addi	a5,a5,1696 # 186a0 <kern_entry-0xffffffffc01e7960>
ffffffffc0200458:	953e                	add	a0,a0,a5
ffffffffc020045a:	29f0106f          	j	ffffffffc0201ef8 <sbi_set_timer>

ffffffffc020045e <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020045e:	8082                	ret

ffffffffc0200460 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200460:	0ff57513          	zext.b	a0,a0
ffffffffc0200464:	27b0106f          	j	ffffffffc0201ede <sbi_console_putchar>

ffffffffc0200468 <cons_getc>:
 * cons_getc - return the next input character from console,
 * or 0 if none waiting.
 * */
int cons_getc(void) {
    int c = 0;
    c = sbi_console_getchar();
ffffffffc0200468:	2ab0106f          	j	ffffffffc0201f12 <sbi_console_getchar>

ffffffffc020046c <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc020046c:	7179                	addi	sp,sp,-48
    cprintf("DTB Init\n");
ffffffffc020046e:	00002517          	auipc	a0,0x2
ffffffffc0200472:	e9250513          	addi	a0,a0,-366 # ffffffffc0202300 <etext+0x304>
void dtb_init(void) {
ffffffffc0200476:	f406                	sd	ra,40(sp)
ffffffffc0200478:	f022                	sd	s0,32(sp)
    cprintf("DTB Init\n");
ffffffffc020047a:	c93ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc020047e:	00007597          	auipc	a1,0x7
ffffffffc0200482:	b825b583          	ld	a1,-1150(a1) # ffffffffc0207000 <boot_hartid>
ffffffffc0200486:	00002517          	auipc	a0,0x2
ffffffffc020048a:	e8a50513          	addi	a0,a0,-374 # ffffffffc0202310 <etext+0x314>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020048e:	00007417          	auipc	s0,0x7
ffffffffc0200492:	b7a40413          	addi	s0,s0,-1158 # ffffffffc0207008 <boot_dtb>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200496:	c77ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020049a:	600c                	ld	a1,0(s0)
ffffffffc020049c:	00002517          	auipc	a0,0x2
ffffffffc02004a0:	e8450513          	addi	a0,a0,-380 # ffffffffc0202320 <etext+0x324>
ffffffffc02004a4:	c69ff0ef          	jal	ffffffffc020010c <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc02004a8:	6018                	ld	a4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc02004aa:	00002517          	auipc	a0,0x2
ffffffffc02004ae:	e8e50513          	addi	a0,a0,-370 # ffffffffc0202338 <etext+0x33c>
    if (boot_dtb == 0) {
ffffffffc02004b2:	10070163          	beqz	a4,ffffffffc02005b4 <dtb_init+0x148>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc02004b6:	57f5                	li	a5,-3
ffffffffc02004b8:	07fa                	slli	a5,a5,0x1e
ffffffffc02004ba:	973e                	add	a4,a4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc02004bc:	431c                	lw	a5,0(a4)
    if (magic != 0xd00dfeed) {
ffffffffc02004be:	d00e06b7          	lui	a3,0xd00e0
ffffffffc02004c2:	eed68693          	addi	a3,a3,-275 # ffffffffd00dfeed <end+0xfed8a55>
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004c6:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02004ca:	0187961b          	slliw	a2,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ce:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004d2:	0ff5f593          	zext.b	a1,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004d6:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004da:	05c2                	slli	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004dc:	8e49                	or	a2,a2,a0
ffffffffc02004de:	0ff7f793          	zext.b	a5,a5
ffffffffc02004e2:	8dd1                	or	a1,a1,a2
ffffffffc02004e4:	07a2                	slli	a5,a5,0x8
ffffffffc02004e6:	8ddd                	or	a1,a1,a5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004e8:	00ff0837          	lui	a6,0xff0
    if (magic != 0xd00dfeed) {
ffffffffc02004ec:	0cd59863          	bne	a1,a3,ffffffffc02005bc <dtb_init+0x150>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc02004f0:	4710                	lw	a2,8(a4)
ffffffffc02004f2:	4754                	lw	a3,12(a4)
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02004f4:	e84a                	sd	s2,16(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004f6:	0086541b          	srliw	s0,a2,0x8
ffffffffc02004fa:	0086d79b          	srliw	a5,a3,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004fe:	01865e1b          	srliw	t3,a2,0x18
ffffffffc0200502:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200506:	0186151b          	slliw	a0,a2,0x18
ffffffffc020050a:	0186959b          	slliw	a1,a3,0x18
ffffffffc020050e:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200512:	0106561b          	srliw	a2,a2,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200516:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020051a:	0106d69b          	srliw	a3,a3,0x10
ffffffffc020051e:	01c56533          	or	a0,a0,t3
ffffffffc0200522:	0115e5b3          	or	a1,a1,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200526:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020052a:	0ff67613          	zext.b	a2,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020052e:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200532:	0ff6f693          	zext.b	a3,a3
ffffffffc0200536:	8c49                	or	s0,s0,a0
ffffffffc0200538:	0622                	slli	a2,a2,0x8
ffffffffc020053a:	8fcd                	or	a5,a5,a1
ffffffffc020053c:	06a2                	slli	a3,a3,0x8
ffffffffc020053e:	8c51                	or	s0,s0,a2
ffffffffc0200540:	8fd5                	or	a5,a5,a3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200542:	1402                	slli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200544:	1782                	slli	a5,a5,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200546:	9001                	srli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200548:	9381                	srli	a5,a5,0x20
ffffffffc020054a:	ec26                	sd	s1,24(sp)
    int in_memory_node = 0;
ffffffffc020054c:	4301                	li	t1,0
        switch (token) {
ffffffffc020054e:	488d                	li	a7,3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200550:	943a                	add	s0,s0,a4
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200552:	00e78933          	add	s2,a5,a4
        switch (token) {
ffffffffc0200556:	4e05                	li	t3,1
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200558:	4018                	lw	a4,0(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020055a:	0087579b          	srliw	a5,a4,0x8
ffffffffc020055e:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200562:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200566:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020056a:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020056e:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200572:	8ed1                	or	a3,a3,a2
ffffffffc0200574:	0ff77713          	zext.b	a4,a4
ffffffffc0200578:	8fd5                	or	a5,a5,a3
ffffffffc020057a:	0722                	slli	a4,a4,0x8
ffffffffc020057c:	8fd9                	or	a5,a5,a4
        switch (token) {
ffffffffc020057e:	05178763          	beq	a5,a7,ffffffffc02005cc <dtb_init+0x160>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200582:	0411                	addi	s0,s0,4
        switch (token) {
ffffffffc0200584:	00f8e963          	bltu	a7,a5,ffffffffc0200596 <dtb_init+0x12a>
ffffffffc0200588:	07c78d63          	beq	a5,t3,ffffffffc0200602 <dtb_init+0x196>
ffffffffc020058c:	4709                	li	a4,2
ffffffffc020058e:	00e79763          	bne	a5,a4,ffffffffc020059c <dtb_init+0x130>
ffffffffc0200592:	4301                	li	t1,0
ffffffffc0200594:	b7d1                	j	ffffffffc0200558 <dtb_init+0xec>
ffffffffc0200596:	4711                	li	a4,4
ffffffffc0200598:	fce780e3          	beq	a5,a4,ffffffffc0200558 <dtb_init+0xec>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc020059c:	00002517          	auipc	a0,0x2
ffffffffc02005a0:	e6450513          	addi	a0,a0,-412 # ffffffffc0202400 <etext+0x404>
ffffffffc02005a4:	b69ff0ef          	jal	ffffffffc020010c <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc02005a8:	64e2                	ld	s1,24(sp)
ffffffffc02005aa:	6942                	ld	s2,16(sp)
ffffffffc02005ac:	00002517          	auipc	a0,0x2
ffffffffc02005b0:	e8c50513          	addi	a0,a0,-372 # ffffffffc0202438 <etext+0x43c>
}
ffffffffc02005b4:	7402                	ld	s0,32(sp)
ffffffffc02005b6:	70a2                	ld	ra,40(sp)
ffffffffc02005b8:	6145                	addi	sp,sp,48
    cprintf("DTB init completed\n");
ffffffffc02005ba:	be89                	j	ffffffffc020010c <cprintf>
}
ffffffffc02005bc:	7402                	ld	s0,32(sp)
ffffffffc02005be:	70a2                	ld	ra,40(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02005c0:	00002517          	auipc	a0,0x2
ffffffffc02005c4:	d9850513          	addi	a0,a0,-616 # ffffffffc0202358 <etext+0x35c>
}
ffffffffc02005c8:	6145                	addi	sp,sp,48
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc02005ca:	b689                	j	ffffffffc020010c <cprintf>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc02005cc:	4058                	lw	a4,4(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005ce:	0087579b          	srliw	a5,a4,0x8
ffffffffc02005d2:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005d6:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005da:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005de:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02005e2:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02005e6:	8ed1                	or	a3,a3,a2
ffffffffc02005e8:	0ff77713          	zext.b	a4,a4
ffffffffc02005ec:	8fd5                	or	a5,a5,a3
ffffffffc02005ee:	0722                	slli	a4,a4,0x8
ffffffffc02005f0:	8fd9                	or	a5,a5,a4
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02005f2:	04031463          	bnez	t1,ffffffffc020063a <dtb_init+0x1ce>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc02005f6:	1782                	slli	a5,a5,0x20
ffffffffc02005f8:	9381                	srli	a5,a5,0x20
ffffffffc02005fa:	043d                	addi	s0,s0,15
ffffffffc02005fc:	943e                	add	s0,s0,a5
ffffffffc02005fe:	9871                	andi	s0,s0,-4
                break;
ffffffffc0200600:	bfa1                	j	ffffffffc0200558 <dtb_init+0xec>
                int name_len = strlen(name);
ffffffffc0200602:	8522                	mv	a0,s0
ffffffffc0200604:	e01a                	sd	t1,0(sp)
ffffffffc0200606:	143010ef          	jal	ffffffffc0201f48 <strlen>
ffffffffc020060a:	84aa                	mv	s1,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020060c:	4619                	li	a2,6
ffffffffc020060e:	8522                	mv	a0,s0
ffffffffc0200610:	00002597          	auipc	a1,0x2
ffffffffc0200614:	d7058593          	addi	a1,a1,-656 # ffffffffc0202380 <etext+0x384>
ffffffffc0200618:	199010ef          	jal	ffffffffc0201fb0 <strncmp>
ffffffffc020061c:	6302                	ld	t1,0(sp)
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc020061e:	0411                	addi	s0,s0,4
ffffffffc0200620:	0004879b          	sext.w	a5,s1
ffffffffc0200624:	943e                	add	s0,s0,a5
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc0200626:	00153513          	seqz	a0,a0
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc020062a:	9871                	andi	s0,s0,-4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc020062c:	00a36333          	or	t1,t1,a0
                break;
ffffffffc0200630:	00ff0837          	lui	a6,0xff0
ffffffffc0200634:	488d                	li	a7,3
ffffffffc0200636:	4e05                	li	t3,1
ffffffffc0200638:	b705                	j	ffffffffc0200558 <dtb_init+0xec>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc020063a:	4418                	lw	a4,8(s0)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020063c:	00002597          	auipc	a1,0x2
ffffffffc0200640:	d4c58593          	addi	a1,a1,-692 # ffffffffc0202388 <etext+0x38c>
ffffffffc0200644:	e43e                	sd	a5,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200646:	0087551b          	srliw	a0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020064a:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020064e:	0187169b          	slliw	a3,a4,0x18
ffffffffc0200652:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200656:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020065a:	01057533          	and	a0,a0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020065e:	8ed1                	or	a3,a3,a2
ffffffffc0200660:	0ff77713          	zext.b	a4,a4
ffffffffc0200664:	0722                	slli	a4,a4,0x8
ffffffffc0200666:	8d55                	or	a0,a0,a3
ffffffffc0200668:	8d59                	or	a0,a0,a4
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc020066a:	1502                	slli	a0,a0,0x20
ffffffffc020066c:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020066e:	954a                	add	a0,a0,s2
ffffffffc0200670:	e01a                	sd	t1,0(sp)
ffffffffc0200672:	10b010ef          	jal	ffffffffc0201f7c <strcmp>
ffffffffc0200676:	67a2                	ld	a5,8(sp)
ffffffffc0200678:	473d                	li	a4,15
ffffffffc020067a:	6302                	ld	t1,0(sp)
ffffffffc020067c:	00ff0837          	lui	a6,0xff0
ffffffffc0200680:	488d                	li	a7,3
ffffffffc0200682:	4e05                	li	t3,1
ffffffffc0200684:	f6f779e3          	bgeu	a4,a5,ffffffffc02005f6 <dtb_init+0x18a>
ffffffffc0200688:	f53d                	bnez	a0,ffffffffc02005f6 <dtb_init+0x18a>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc020068a:	00c43683          	ld	a3,12(s0)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc020068e:	01443703          	ld	a4,20(s0)
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200692:	00002517          	auipc	a0,0x2
ffffffffc0200696:	cfe50513          	addi	a0,a0,-770 # ffffffffc0202390 <etext+0x394>
           fdt32_to_cpu(x >> 32);
ffffffffc020069a:	4206d793          	srai	a5,a3,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020069e:	0087d31b          	srliw	t1,a5,0x8
ffffffffc02006a2:	00871f93          	slli	t6,a4,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc02006a6:	42075893          	srai	a7,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006aa:	0187df1b          	srliw	t5,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006ae:	0187959b          	slliw	a1,a5,0x18
ffffffffc02006b2:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006b6:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006ba:	420fd613          	srai	a2,t6,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006be:	0188de9b          	srliw	t4,a7,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006c2:	01037333          	and	t1,t1,a6
ffffffffc02006c6:	01889e1b          	slliw	t3,a7,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006ca:	01e5e5b3          	or	a1,a1,t5
ffffffffc02006ce:	0ff7f793          	zext.b	a5,a5
ffffffffc02006d2:	01de6e33          	or	t3,t3,t4
ffffffffc02006d6:	0065e5b3          	or	a1,a1,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006da:	01067633          	and	a2,a2,a6
ffffffffc02006de:	0086d31b          	srliw	t1,a3,0x8
ffffffffc02006e2:	0087541b          	srliw	s0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02006e6:	07a2                	slli	a5,a5,0x8
ffffffffc02006e8:	0108d89b          	srliw	a7,a7,0x10
ffffffffc02006ec:	0186df1b          	srliw	t5,a3,0x18
ffffffffc02006f0:	01875e9b          	srliw	t4,a4,0x18
ffffffffc02006f4:	8ddd                	or	a1,a1,a5
ffffffffc02006f6:	01c66633          	or	a2,a2,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02006fa:	0186979b          	slliw	a5,a3,0x18
ffffffffc02006fe:	01871e1b          	slliw	t3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200702:	0ff8f893          	zext.b	a7,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200706:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020070a:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020070e:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200712:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200716:	01037333          	and	t1,t1,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020071a:	08a2                	slli	a7,a7,0x8
ffffffffc020071c:	01e7e7b3          	or	a5,a5,t5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200720:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200724:	0ff6f693          	zext.b	a3,a3
ffffffffc0200728:	01de6833          	or	a6,t3,t4
ffffffffc020072c:	0ff77713          	zext.b	a4,a4
ffffffffc0200730:	01166633          	or	a2,a2,a7
ffffffffc0200734:	0067e7b3          	or	a5,a5,t1
ffffffffc0200738:	06a2                	slli	a3,a3,0x8
ffffffffc020073a:	01046433          	or	s0,s0,a6
ffffffffc020073e:	0722                	slli	a4,a4,0x8
ffffffffc0200740:	8fd5                	or	a5,a5,a3
ffffffffc0200742:	8c59                	or	s0,s0,a4
           fdt32_to_cpu(x >> 32);
ffffffffc0200744:	1582                	slli	a1,a1,0x20
ffffffffc0200746:	1602                	slli	a2,a2,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200748:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc020074a:	9201                	srli	a2,a2,0x20
ffffffffc020074c:	9181                	srli	a1,a1,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020074e:	1402                	slli	s0,s0,0x20
ffffffffc0200750:	00b7e4b3          	or	s1,a5,a1
ffffffffc0200754:	8c51                	or	s0,s0,a2
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200756:	9b7ff0ef          	jal	ffffffffc020010c <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc020075a:	85a6                	mv	a1,s1
ffffffffc020075c:	00002517          	auipc	a0,0x2
ffffffffc0200760:	c5450513          	addi	a0,a0,-940 # ffffffffc02023b0 <etext+0x3b4>
ffffffffc0200764:	9a9ff0ef          	jal	ffffffffc020010c <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200768:	01445613          	srli	a2,s0,0x14
ffffffffc020076c:	85a2                	mv	a1,s0
ffffffffc020076e:	00002517          	auipc	a0,0x2
ffffffffc0200772:	c5a50513          	addi	a0,a0,-934 # ffffffffc02023c8 <etext+0x3cc>
ffffffffc0200776:	997ff0ef          	jal	ffffffffc020010c <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc020077a:	009405b3          	add	a1,s0,s1
ffffffffc020077e:	15fd                	addi	a1,a1,-1
ffffffffc0200780:	00002517          	auipc	a0,0x2
ffffffffc0200784:	c6850513          	addi	a0,a0,-920 # ffffffffc02023e8 <etext+0x3ec>
ffffffffc0200788:	985ff0ef          	jal	ffffffffc020010c <cprintf>
        memory_base = mem_base;
ffffffffc020078c:	00007797          	auipc	a5,0x7
ffffffffc0200790:	cc97b623          	sd	s1,-820(a5) # ffffffffc0207458 <memory_base>
        memory_size = mem_size;
ffffffffc0200794:	00007797          	auipc	a5,0x7
ffffffffc0200798:	ca87be23          	sd	s0,-836(a5) # ffffffffc0207450 <memory_size>
ffffffffc020079c:	b531                	j	ffffffffc02005a8 <dtb_init+0x13c>

ffffffffc020079e <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc020079e:	00007517          	auipc	a0,0x7
ffffffffc02007a2:	cba53503          	ld	a0,-838(a0) # ffffffffc0207458 <memory_base>
ffffffffc02007a6:	8082                	ret

ffffffffc02007a8 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
}
ffffffffc02007a8:	00007517          	auipc	a0,0x7
ffffffffc02007ac:	ca853503          	ld	a0,-856(a0) # ffffffffc0207450 <memory_size>
ffffffffc02007b0:	8082                	ret

ffffffffc02007b2 <intr_enable>:
#include <intr.h>
#include <riscv.h>

/* intr_enable - enable irq interrupt */
void intr_enable(void) { set_csr(sstatus, SSTATUS_SIE); }
ffffffffc02007b2:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc02007b6:	8082                	ret

ffffffffc02007b8 <intr_disable>:

/* intr_disable - disable irq interrupt */
void intr_disable(void) { clear_csr(sstatus, SSTATUS_SIE); }
ffffffffc02007b8:	100177f3          	csrrci	a5,sstatus,2
ffffffffc02007bc:	8082                	ret

ffffffffc02007be <idt_init>:
     */

    extern void __alltraps(void);
    /* Set sup0 scratch register to 0, indicating to exception vector
       that we are presently executing in the kernel */
    write_csr(sscratch, 0);
ffffffffc02007be:	14005073          	csrwi	sscratch,0
    /* Set the exception vector address */
    write_csr(stvec, &__alltraps);
ffffffffc02007c2:	00000797          	auipc	a5,0x0
ffffffffc02007c6:	43278793          	addi	a5,a5,1074 # ffffffffc0200bf4 <__alltraps>
ffffffffc02007ca:	10579073          	csrw	stvec,a5
}
ffffffffc02007ce:	8082                	ret

ffffffffc02007d0 <print_regs>:
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
    cprintf("  cause    0x%08x\n", tf->cause);
}

void print_regs(struct pushregs *gpr) {
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02007d0:	610c                	ld	a1,0(a0)
void print_regs(struct pushregs *gpr) {
ffffffffc02007d2:	1141                	addi	sp,sp,-16
ffffffffc02007d4:	e022                	sd	s0,0(sp)
ffffffffc02007d6:	842a                	mv	s0,a0
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02007d8:	00002517          	auipc	a0,0x2
ffffffffc02007dc:	c7850513          	addi	a0,a0,-904 # ffffffffc0202450 <etext+0x454>
void print_regs(struct pushregs *gpr) {
ffffffffc02007e0:	e406                	sd	ra,8(sp)
    cprintf("  zero     0x%08x\n", gpr->zero);
ffffffffc02007e2:	92bff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  ra       0x%08x\n", gpr->ra);
ffffffffc02007e6:	640c                	ld	a1,8(s0)
ffffffffc02007e8:	00002517          	auipc	a0,0x2
ffffffffc02007ec:	c8050513          	addi	a0,a0,-896 # ffffffffc0202468 <etext+0x46c>
ffffffffc02007f0:	91dff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  sp       0x%08x\n", gpr->sp);
ffffffffc02007f4:	680c                	ld	a1,16(s0)
ffffffffc02007f6:	00002517          	auipc	a0,0x2
ffffffffc02007fa:	c8a50513          	addi	a0,a0,-886 # ffffffffc0202480 <etext+0x484>
ffffffffc02007fe:	90fff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  gp       0x%08x\n", gpr->gp);
ffffffffc0200802:	6c0c                	ld	a1,24(s0)
ffffffffc0200804:	00002517          	auipc	a0,0x2
ffffffffc0200808:	c9450513          	addi	a0,a0,-876 # ffffffffc0202498 <etext+0x49c>
ffffffffc020080c:	901ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  tp       0x%08x\n", gpr->tp);
ffffffffc0200810:	700c                	ld	a1,32(s0)
ffffffffc0200812:	00002517          	auipc	a0,0x2
ffffffffc0200816:	c9e50513          	addi	a0,a0,-866 # ffffffffc02024b0 <etext+0x4b4>
ffffffffc020081a:	8f3ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  t0       0x%08x\n", gpr->t0);
ffffffffc020081e:	740c                	ld	a1,40(s0)
ffffffffc0200820:	00002517          	auipc	a0,0x2
ffffffffc0200824:	ca850513          	addi	a0,a0,-856 # ffffffffc02024c8 <etext+0x4cc>
ffffffffc0200828:	8e5ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  t1       0x%08x\n", gpr->t1);
ffffffffc020082c:	780c                	ld	a1,48(s0)
ffffffffc020082e:	00002517          	auipc	a0,0x2
ffffffffc0200832:	cb250513          	addi	a0,a0,-846 # ffffffffc02024e0 <etext+0x4e4>
ffffffffc0200836:	8d7ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  t2       0x%08x\n", gpr->t2);
ffffffffc020083a:	7c0c                	ld	a1,56(s0)
ffffffffc020083c:	00002517          	auipc	a0,0x2
ffffffffc0200840:	cbc50513          	addi	a0,a0,-836 # ffffffffc02024f8 <etext+0x4fc>
ffffffffc0200844:	8c9ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  s0       0x%08x\n", gpr->s0);
ffffffffc0200848:	602c                	ld	a1,64(s0)
ffffffffc020084a:	00002517          	auipc	a0,0x2
ffffffffc020084e:	cc650513          	addi	a0,a0,-826 # ffffffffc0202510 <etext+0x514>
ffffffffc0200852:	8bbff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  s1       0x%08x\n", gpr->s1);
ffffffffc0200856:	642c                	ld	a1,72(s0)
ffffffffc0200858:	00002517          	auipc	a0,0x2
ffffffffc020085c:	cd050513          	addi	a0,a0,-816 # ffffffffc0202528 <etext+0x52c>
ffffffffc0200860:	8adff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  a0       0x%08x\n", gpr->a0);
ffffffffc0200864:	682c                	ld	a1,80(s0)
ffffffffc0200866:	00002517          	auipc	a0,0x2
ffffffffc020086a:	cda50513          	addi	a0,a0,-806 # ffffffffc0202540 <etext+0x544>
ffffffffc020086e:	89fff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  a1       0x%08x\n", gpr->a1);
ffffffffc0200872:	6c2c                	ld	a1,88(s0)
ffffffffc0200874:	00002517          	auipc	a0,0x2
ffffffffc0200878:	ce450513          	addi	a0,a0,-796 # ffffffffc0202558 <etext+0x55c>
ffffffffc020087c:	891ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  a2       0x%08x\n", gpr->a2);
ffffffffc0200880:	702c                	ld	a1,96(s0)
ffffffffc0200882:	00002517          	auipc	a0,0x2
ffffffffc0200886:	cee50513          	addi	a0,a0,-786 # ffffffffc0202570 <etext+0x574>
ffffffffc020088a:	883ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  a3       0x%08x\n", gpr->a3);
ffffffffc020088e:	742c                	ld	a1,104(s0)
ffffffffc0200890:	00002517          	auipc	a0,0x2
ffffffffc0200894:	cf850513          	addi	a0,a0,-776 # ffffffffc0202588 <etext+0x58c>
ffffffffc0200898:	875ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  a4       0x%08x\n", gpr->a4);
ffffffffc020089c:	782c                	ld	a1,112(s0)
ffffffffc020089e:	00002517          	auipc	a0,0x2
ffffffffc02008a2:	d0250513          	addi	a0,a0,-766 # ffffffffc02025a0 <etext+0x5a4>
ffffffffc02008a6:	867ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  a5       0x%08x\n", gpr->a5);
ffffffffc02008aa:	7c2c                	ld	a1,120(s0)
ffffffffc02008ac:	00002517          	auipc	a0,0x2
ffffffffc02008b0:	d0c50513          	addi	a0,a0,-756 # ffffffffc02025b8 <etext+0x5bc>
ffffffffc02008b4:	859ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  a6       0x%08x\n", gpr->a6);
ffffffffc02008b8:	604c                	ld	a1,128(s0)
ffffffffc02008ba:	00002517          	auipc	a0,0x2
ffffffffc02008be:	d1650513          	addi	a0,a0,-746 # ffffffffc02025d0 <etext+0x5d4>
ffffffffc02008c2:	84bff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  a7       0x%08x\n", gpr->a7);
ffffffffc02008c6:	644c                	ld	a1,136(s0)
ffffffffc02008c8:	00002517          	auipc	a0,0x2
ffffffffc02008cc:	d2050513          	addi	a0,a0,-736 # ffffffffc02025e8 <etext+0x5ec>
ffffffffc02008d0:	83dff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  s2       0x%08x\n", gpr->s2);
ffffffffc02008d4:	684c                	ld	a1,144(s0)
ffffffffc02008d6:	00002517          	auipc	a0,0x2
ffffffffc02008da:	d2a50513          	addi	a0,a0,-726 # ffffffffc0202600 <etext+0x604>
ffffffffc02008de:	82fff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  s3       0x%08x\n", gpr->s3);
ffffffffc02008e2:	6c4c                	ld	a1,152(s0)
ffffffffc02008e4:	00002517          	auipc	a0,0x2
ffffffffc02008e8:	d3450513          	addi	a0,a0,-716 # ffffffffc0202618 <etext+0x61c>
ffffffffc02008ec:	821ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  s4       0x%08x\n", gpr->s4);
ffffffffc02008f0:	704c                	ld	a1,160(s0)
ffffffffc02008f2:	00002517          	auipc	a0,0x2
ffffffffc02008f6:	d3e50513          	addi	a0,a0,-706 # ffffffffc0202630 <etext+0x634>
ffffffffc02008fa:	813ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  s5       0x%08x\n", gpr->s5);
ffffffffc02008fe:	744c                	ld	a1,168(s0)
ffffffffc0200900:	00002517          	auipc	a0,0x2
ffffffffc0200904:	d4850513          	addi	a0,a0,-696 # ffffffffc0202648 <etext+0x64c>
ffffffffc0200908:	805ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  s6       0x%08x\n", gpr->s6);
ffffffffc020090c:	784c                	ld	a1,176(s0)
ffffffffc020090e:	00002517          	auipc	a0,0x2
ffffffffc0200912:	d5250513          	addi	a0,a0,-686 # ffffffffc0202660 <etext+0x664>
ffffffffc0200916:	ff6ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  s7       0x%08x\n", gpr->s7);
ffffffffc020091a:	7c4c                	ld	a1,184(s0)
ffffffffc020091c:	00002517          	auipc	a0,0x2
ffffffffc0200920:	d5c50513          	addi	a0,a0,-676 # ffffffffc0202678 <etext+0x67c>
ffffffffc0200924:	fe8ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  s8       0x%08x\n", gpr->s8);
ffffffffc0200928:	606c                	ld	a1,192(s0)
ffffffffc020092a:	00002517          	auipc	a0,0x2
ffffffffc020092e:	d6650513          	addi	a0,a0,-666 # ffffffffc0202690 <etext+0x694>
ffffffffc0200932:	fdaff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  s9       0x%08x\n", gpr->s9);
ffffffffc0200936:	646c                	ld	a1,200(s0)
ffffffffc0200938:	00002517          	auipc	a0,0x2
ffffffffc020093c:	d7050513          	addi	a0,a0,-656 # ffffffffc02026a8 <etext+0x6ac>
ffffffffc0200940:	fccff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  s10      0x%08x\n", gpr->s10);
ffffffffc0200944:	686c                	ld	a1,208(s0)
ffffffffc0200946:	00002517          	auipc	a0,0x2
ffffffffc020094a:	d7a50513          	addi	a0,a0,-646 # ffffffffc02026c0 <etext+0x6c4>
ffffffffc020094e:	fbeff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  s11      0x%08x\n", gpr->s11);
ffffffffc0200952:	6c6c                	ld	a1,216(s0)
ffffffffc0200954:	00002517          	auipc	a0,0x2
ffffffffc0200958:	d8450513          	addi	a0,a0,-636 # ffffffffc02026d8 <etext+0x6dc>
ffffffffc020095c:	fb0ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  t3       0x%08x\n", gpr->t3);
ffffffffc0200960:	706c                	ld	a1,224(s0)
ffffffffc0200962:	00002517          	auipc	a0,0x2
ffffffffc0200966:	d8e50513          	addi	a0,a0,-626 # ffffffffc02026f0 <etext+0x6f4>
ffffffffc020096a:	fa2ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  t4       0x%08x\n", gpr->t4);
ffffffffc020096e:	746c                	ld	a1,232(s0)
ffffffffc0200970:	00002517          	auipc	a0,0x2
ffffffffc0200974:	d9850513          	addi	a0,a0,-616 # ffffffffc0202708 <etext+0x70c>
ffffffffc0200978:	f94ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  t5       0x%08x\n", gpr->t5);
ffffffffc020097c:	786c                	ld	a1,240(s0)
ffffffffc020097e:	00002517          	auipc	a0,0x2
ffffffffc0200982:	da250513          	addi	a0,a0,-606 # ffffffffc0202720 <etext+0x724>
ffffffffc0200986:	f86ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020098a:	7c6c                	ld	a1,248(s0)
}
ffffffffc020098c:	6402                	ld	s0,0(sp)
ffffffffc020098e:	60a2                	ld	ra,8(sp)
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc0200990:	00002517          	auipc	a0,0x2
ffffffffc0200994:	da850513          	addi	a0,a0,-600 # ffffffffc0202738 <etext+0x73c>
}
ffffffffc0200998:	0141                	addi	sp,sp,16
    cprintf("  t6       0x%08x\n", gpr->t6);
ffffffffc020099a:	f72ff06f          	j	ffffffffc020010c <cprintf>

ffffffffc020099e <print_trapframe>:
void print_trapframe(struct trapframe *tf) {
ffffffffc020099e:	1141                	addi	sp,sp,-16
ffffffffc02009a0:	e022                	sd	s0,0(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc02009a2:	85aa                	mv	a1,a0
void print_trapframe(struct trapframe *tf) {
ffffffffc02009a4:	842a                	mv	s0,a0
    cprintf("trapframe at %p\n", tf);
ffffffffc02009a6:	00002517          	auipc	a0,0x2
ffffffffc02009aa:	daa50513          	addi	a0,a0,-598 # ffffffffc0202750 <etext+0x754>
void print_trapframe(struct trapframe *tf) {
ffffffffc02009ae:	e406                	sd	ra,8(sp)
    cprintf("trapframe at %p\n", tf);
ffffffffc02009b0:	f5cff0ef          	jal	ffffffffc020010c <cprintf>
    print_regs(&tf->gpr);
ffffffffc02009b4:	8522                	mv	a0,s0
ffffffffc02009b6:	e1bff0ef          	jal	ffffffffc02007d0 <print_regs>
    cprintf("  status   0x%08x\n", tf->status);
ffffffffc02009ba:	10043583          	ld	a1,256(s0)
ffffffffc02009be:	00002517          	auipc	a0,0x2
ffffffffc02009c2:	daa50513          	addi	a0,a0,-598 # ffffffffc0202768 <etext+0x76c>
ffffffffc02009c6:	f46ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  epc      0x%08x\n", tf->epc);
ffffffffc02009ca:	10843583          	ld	a1,264(s0)
ffffffffc02009ce:	00002517          	auipc	a0,0x2
ffffffffc02009d2:	db250513          	addi	a0,a0,-590 # ffffffffc0202780 <etext+0x784>
ffffffffc02009d6:	f36ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  badvaddr 0x%08x\n", tf->badvaddr);
ffffffffc02009da:	11043583          	ld	a1,272(s0)
ffffffffc02009de:	00002517          	auipc	a0,0x2
ffffffffc02009e2:	dba50513          	addi	a0,a0,-582 # ffffffffc0202798 <etext+0x79c>
ffffffffc02009e6:	f26ff0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02009ea:	11843583          	ld	a1,280(s0)
}
ffffffffc02009ee:	6402                	ld	s0,0(sp)
ffffffffc02009f0:	60a2                	ld	ra,8(sp)
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02009f2:	00002517          	auipc	a0,0x2
ffffffffc02009f6:	dbe50513          	addi	a0,a0,-578 # ffffffffc02027b0 <etext+0x7b4>
}
ffffffffc02009fa:	0141                	addi	sp,sp,16
    cprintf("  cause    0x%08x\n", tf->cause);
ffffffffc02009fc:	f10ff06f          	j	ffffffffc020010c <cprintf>

ffffffffc0200a00 <interrupt_handler>:
        return 2;
    }
}
void interrupt_handler(struct trapframe *tf) {
    intptr_t cause = (tf->cause << 1) >> 1;
    switch (cause) {
ffffffffc0200a00:	11853783          	ld	a5,280(a0)
ffffffffc0200a04:	472d                	li	a4,11
ffffffffc0200a06:	0786                	slli	a5,a5,0x1
ffffffffc0200a08:	8385                	srli	a5,a5,0x1
ffffffffc0200a0a:	0af76363          	bltu	a4,a5,ffffffffc0200ab0 <interrupt_handler+0xb0>
ffffffffc0200a0e:	00002717          	auipc	a4,0x2
ffffffffc0200a12:	57a70713          	addi	a4,a4,1402 # ffffffffc0202f88 <commands+0x48>
ffffffffc0200a16:	078a                	slli	a5,a5,0x2
ffffffffc0200a18:	97ba                	add	a5,a5,a4
ffffffffc0200a1a:	439c                	lw	a5,0(a5)
ffffffffc0200a1c:	97ba                	add	a5,a5,a4
ffffffffc0200a1e:	8782                	jr	a5
            break;
        case IRQ_H_SOFT:
            cprintf("Hypervisor software interrupt\n");
            break;
        case IRQ_M_SOFT:
            cprintf("Machine software interrupt\n");
ffffffffc0200a20:	00002517          	auipc	a0,0x2
ffffffffc0200a24:	e0850513          	addi	a0,a0,-504 # ffffffffc0202828 <etext+0x82c>
ffffffffc0200a28:	ee4ff06f          	j	ffffffffc020010c <cprintf>
            cprintf("Hypervisor software interrupt\n");
ffffffffc0200a2c:	00002517          	auipc	a0,0x2
ffffffffc0200a30:	ddc50513          	addi	a0,a0,-548 # ffffffffc0202808 <etext+0x80c>
ffffffffc0200a34:	ed8ff06f          	j	ffffffffc020010c <cprintf>
            cprintf("User software interrupt\n");
ffffffffc0200a38:	00002517          	auipc	a0,0x2
ffffffffc0200a3c:	d9050513          	addi	a0,a0,-624 # ffffffffc02027c8 <etext+0x7cc>
ffffffffc0200a40:	eccff06f          	j	ffffffffc020010c <cprintf>
            break;
        case IRQ_U_TIMER:
            cprintf("User Timer interrupt\n");
ffffffffc0200a44:	00002517          	auipc	a0,0x2
ffffffffc0200a48:	e0450513          	addi	a0,a0,-508 # ffffffffc0202848 <etext+0x84c>
ffffffffc0200a4c:	ec0ff06f          	j	ffffffffc020010c <cprintf>
void interrupt_handler(struct trapframe *tf) {
ffffffffc0200a50:	1141                	addi	sp,sp,-16
ffffffffc0200a52:	e406                	sd	ra,8(sp)
            /*(1)设置下次时钟中断- clock_set_next_event()
             *(2)计数器（ticks）加一
             *(3)当计数器加到100的时候，我们会输出一个`100ticks`表示我们触发了100次时钟中断，同时打印次数（num）加一
            * (4)判断打印次数，当打印次数为10时，调用<sbi.h>中的关机函数关机
            */
            clock_set_next_event();
ffffffffc0200a54:	9fbff0ef          	jal	ffffffffc020044e <clock_set_next_event>
            ticks++;
ffffffffc0200a58:	00007697          	auipc	a3,0x7
ffffffffc0200a5c:	9f068693          	addi	a3,a3,-1552 # ffffffffc0207448 <ticks>
ffffffffc0200a60:	629c                	ld	a5,0(a3)
            if(ticks%100==0){
ffffffffc0200a62:	28f5c737          	lui	a4,0x28f5c
ffffffffc0200a66:	28f70713          	addi	a4,a4,655 # 28f5c28f <kern_entry-0xffffffff972a3d71>
            ticks++;
ffffffffc0200a6a:	0785                	addi	a5,a5,1
ffffffffc0200a6c:	e29c                	sd	a5,0(a3)
            if(ticks%100==0){
ffffffffc0200a6e:	6288                	ld	a0,0(a3)
ffffffffc0200a70:	5c28f637          	lui	a2,0x5c28f
ffffffffc0200a74:	1702                	slli	a4,a4,0x20
ffffffffc0200a76:	5c360613          	addi	a2,a2,1475 # 5c28f5c3 <kern_entry-0xffffffff63f70a3d>
ffffffffc0200a7a:	00255793          	srli	a5,a0,0x2
ffffffffc0200a7e:	9732                	add	a4,a4,a2
ffffffffc0200a80:	02e7b7b3          	mulhu	a5,a5,a4
ffffffffc0200a84:	06400593          	li	a1,100
ffffffffc0200a88:	8389                	srli	a5,a5,0x2
ffffffffc0200a8a:	02b787b3          	mul	a5,a5,a1
ffffffffc0200a8e:	02f50263          	beq	a0,a5,ffffffffc0200ab2 <interrupt_handler+0xb2>
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200a92:	60a2                	ld	ra,8(sp)
ffffffffc0200a94:	0141                	addi	sp,sp,16
ffffffffc0200a96:	8082                	ret
            cprintf("Supervisor external interrupt\n");
ffffffffc0200a98:	00002517          	auipc	a0,0x2
ffffffffc0200a9c:	dd850513          	addi	a0,a0,-552 # ffffffffc0202870 <etext+0x874>
ffffffffc0200aa0:	e6cff06f          	j	ffffffffc020010c <cprintf>
            cprintf("Supervisor software interrupt\n");
ffffffffc0200aa4:	00002517          	auipc	a0,0x2
ffffffffc0200aa8:	d4450513          	addi	a0,a0,-700 # ffffffffc02027e8 <etext+0x7ec>
ffffffffc0200aac:	e60ff06f          	j	ffffffffc020010c <cprintf>
            print_trapframe(tf);
ffffffffc0200ab0:	b5fd                	j	ffffffffc020099e <print_trapframe>
    cprintf("%d ticks\n", TICK_NUM);
ffffffffc0200ab2:	00002517          	auipc	a0,0x2
ffffffffc0200ab6:	dae50513          	addi	a0,a0,-594 # ffffffffc0202860 <etext+0x864>
ffffffffc0200aba:	e52ff0ef          	jal	ffffffffc020010c <cprintf>
                if(ticks/100>=10){
ffffffffc0200abe:	00007717          	auipc	a4,0x7
ffffffffc0200ac2:	98a73703          	ld	a4,-1654(a4) # ffffffffc0207448 <ticks>
ffffffffc0200ac6:	3e700793          	li	a5,999
ffffffffc0200aca:	fce7f4e3          	bgeu	a5,a4,ffffffffc0200a92 <interrupt_handler+0x92>
}
ffffffffc0200ace:	60a2                	ld	ra,8(sp)
ffffffffc0200ad0:	0141                	addi	sp,sp,16
                    sbi_shutdown();
ffffffffc0200ad2:	45c0106f          	j	ffffffffc0201f2e <sbi_shutdown>

ffffffffc0200ad6 <exception_handler>:

void exception_handler(struct trapframe *tf) {
    switch (tf->cause) {
ffffffffc0200ad6:	11853783          	ld	a5,280(a0)
void exception_handler(struct trapframe *tf) {
ffffffffc0200ada:	1101                	addi	sp,sp,-32
ffffffffc0200adc:	e822                	sd	s0,16(sp)
ffffffffc0200ade:	ec06                	sd	ra,24(sp)
    switch (tf->cause) {
ffffffffc0200ae0:	470d                	li	a4,3
void exception_handler(struct trapframe *tf) {
ffffffffc0200ae2:	842a                	mv	s0,a0
    switch (tf->cause) {
ffffffffc0200ae4:	06e78f63          	beq	a5,a4,ffffffffc0200b62 <exception_handler+0x8c>
ffffffffc0200ae8:	06f76563          	bltu	a4,a5,ffffffffc0200b52 <exception_handler+0x7c>
ffffffffc0200aec:	4689                	li	a3,2
ffffffffc0200aee:	04d79e63          	bne	a5,a3,ffffffffc0200b4a <exception_handler+0x74>
             /* LAB3 CHALLENGE3   2312260 :  */
            /*(1)输出指令异常类型（ Illegal instruction）
             *(2)输出异常指令地址
             *(3)更新 tf->epc寄存器
            */
            cprintf("Exception type:Illegal instruction\n");
ffffffffc0200af2:	00002517          	auipc	a0,0x2
ffffffffc0200af6:	d9e50513          	addi	a0,a0,-610 # ffffffffc0202890 <etext+0x894>
ffffffffc0200afa:	e43e                	sd	a5,8(sp)
ffffffffc0200afc:	e10ff0ef          	jal	ffffffffc020010c <cprintf>
            cprintf("Illegal instruction caught at 0x%016lx\n", tf->epc);
ffffffffc0200b00:	10843583          	ld	a1,264(s0)
ffffffffc0200b04:	00002517          	auipc	a0,0x2
ffffffffc0200b08:	db450513          	addi	a0,a0,-588 # ffffffffc02028b8 <etext+0x8bc>
ffffffffc0200b0c:	e00ff0ef          	jal	ffffffffc020010c <cprintf>
    uint16_t *inst_ptr = (uint16_t *)epc;
ffffffffc0200b10:	10843683          	ld	a3,264(s0)
    if ((inst_word & 0x3) == 0x3) {
ffffffffc0200b14:	470d                	li	a4,3
    uint16_t inst_word = *inst_ptr;
ffffffffc0200b16:	0006d583          	lhu	a1,0(a3)
    if ((inst_word & 0x3) == 0x3) {
ffffffffc0200b1a:	0035f613          	andi	a2,a1,3
ffffffffc0200b1e:	0ae60b63          	beq	a2,a4,ffffffffc0200bd4 <exception_handler+0xfe>
            if(get_instruction_length(tf->epc) == 2) {
                cprintf("INSTRUCTION:%04x(length:%d)\n", *(uint16_t *)(tf->epc),2);
ffffffffc0200b22:	6622                	ld	a2,8(sp)
ffffffffc0200b24:	00002517          	auipc	a0,0x2
ffffffffc0200b28:	ddc50513          	addi	a0,a0,-548 # ffffffffc0202900 <etext+0x904>
ffffffffc0200b2c:	de0ff0ef          	jal	ffffffffc020010c <cprintf>
ffffffffc0200b30:	67a2                	ld	a5,8(sp)
            } else {
                cprintf("INSTRUCTION:%08x(length:%d)\n", *(uint32_t *)(tf->epc),4);
            }
            tf->epc += get_instruction_length(tf->epc);  // 更新 tf->epc寄存器
ffffffffc0200b32:	10843703          	ld	a4,264(s0)
    if ((inst_word & 0x3) == 0x3) {
ffffffffc0200b36:	460d                	li	a2,3
ffffffffc0200b38:	00075683          	lhu	a3,0(a4)
ffffffffc0200b3c:	8ef1                	and	a3,a3,a2
ffffffffc0200b3e:	00c69363          	bne	a3,a2,ffffffffc0200b44 <exception_handler+0x6e>
        return 4;
ffffffffc0200b42:	4791                	li	a5,4
            tf->epc += get_instruction_length(tf->epc);  // 更新 tf->epc寄存器
ffffffffc0200b44:	973e                	add	a4,a4,a5
ffffffffc0200b46:	10e43423          	sd	a4,264(s0)
            break;
        default:
            print_trapframe(tf);
            break;
    }
}
ffffffffc0200b4a:	60e2                	ld	ra,24(sp)
ffffffffc0200b4c:	6442                	ld	s0,16(sp)
ffffffffc0200b4e:	6105                	addi	sp,sp,32
ffffffffc0200b50:	8082                	ret
    switch (tf->cause) {
ffffffffc0200b52:	17f1                	addi	a5,a5,-4
ffffffffc0200b54:	471d                	li	a4,7
ffffffffc0200b56:	fef77ae3          	bgeu	a4,a5,ffffffffc0200b4a <exception_handler+0x74>
}
ffffffffc0200b5a:	6442                	ld	s0,16(sp)
ffffffffc0200b5c:	60e2                	ld	ra,24(sp)
ffffffffc0200b5e:	6105                	addi	sp,sp,32
            print_trapframe(tf);
ffffffffc0200b60:	bd3d                	j	ffffffffc020099e <print_trapframe>
            cprintf("Exception type:Breakpoint\n");
ffffffffc0200b62:	00002517          	auipc	a0,0x2
ffffffffc0200b66:	dbe50513          	addi	a0,a0,-578 # ffffffffc0202920 <etext+0x924>
ffffffffc0200b6a:	e43e                	sd	a5,8(sp)
ffffffffc0200b6c:	da0ff0ef          	jal	ffffffffc020010c <cprintf>
            cprintf("ebreak caught at 0x%016lx\n", tf->epc);
ffffffffc0200b70:	10843583          	ld	a1,264(s0)
ffffffffc0200b74:	00002517          	auipc	a0,0x2
ffffffffc0200b78:	dcc50513          	addi	a0,a0,-564 # ffffffffc0202940 <etext+0x944>
ffffffffc0200b7c:	d90ff0ef          	jal	ffffffffc020010c <cprintf>
    uint16_t *inst_ptr = (uint16_t *)epc;
ffffffffc0200b80:	10843703          	ld	a4,264(s0)
    if ((inst_word & 0x3) == 0x3) {
ffffffffc0200b84:	67a2                	ld	a5,8(sp)
    uint16_t inst_word = *inst_ptr;
ffffffffc0200b86:	00075583          	lhu	a1,0(a4)
    if ((inst_word & 0x3) == 0x3) {
ffffffffc0200b8a:	0035f693          	andi	a3,a1,3
ffffffffc0200b8e:	02f68a63          	beq	a3,a5,ffffffffc0200bc2 <exception_handler+0xec>
                cprintf("INSTRUCTION:%04x(length:%d)\n", *(uint16_t *)(tf->epc),2);
ffffffffc0200b92:	4609                	li	a2,2
ffffffffc0200b94:	00002517          	auipc	a0,0x2
ffffffffc0200b98:	d6c50513          	addi	a0,a0,-660 # ffffffffc0202900 <etext+0x904>
ffffffffc0200b9c:	d70ff0ef          	jal	ffffffffc020010c <cprintf>
            tf->epc += get_instruction_length(tf->epc);  // 更新 tf->epc寄存器
ffffffffc0200ba0:	10843783          	ld	a5,264(s0)
    if ((inst_word & 0x3) == 0x3) {
ffffffffc0200ba4:	460d                	li	a2,3
        return 2;
ffffffffc0200ba6:	4689                	li	a3,2
    if ((inst_word & 0x3) == 0x3) {
ffffffffc0200ba8:	0007d703          	lhu	a4,0(a5)
ffffffffc0200bac:	8f71                	and	a4,a4,a2
ffffffffc0200bae:	00c71363          	bne	a4,a2,ffffffffc0200bb4 <exception_handler+0xde>
        return 4;
ffffffffc0200bb2:	4691                	li	a3,4
            tf->epc += get_instruction_length(tf->epc);  // 更新 tf->epc寄存器
ffffffffc0200bb4:	97b6                	add	a5,a5,a3
}
ffffffffc0200bb6:	60e2                	ld	ra,24(sp)
            tf->epc += get_instruction_length(tf->epc);  // 更新 tf->epc寄存器
ffffffffc0200bb8:	10f43423          	sd	a5,264(s0)
}
ffffffffc0200bbc:	6442                	ld	s0,16(sp)
ffffffffc0200bbe:	6105                	addi	sp,sp,32
ffffffffc0200bc0:	8082                	ret
                cprintf("INSTRUCTION:%08x(length:%d)\n", *(uint32_t *)(tf->epc),4);
ffffffffc0200bc2:	430c                	lw	a1,0(a4)
ffffffffc0200bc4:	4611                	li	a2,4
ffffffffc0200bc6:	00002517          	auipc	a0,0x2
ffffffffc0200bca:	d1a50513          	addi	a0,a0,-742 # ffffffffc02028e0 <etext+0x8e4>
ffffffffc0200bce:	d3eff0ef          	jal	ffffffffc020010c <cprintf>
ffffffffc0200bd2:	b7f9                	j	ffffffffc0200ba0 <exception_handler+0xca>
                cprintf("INSTRUCTION:%08x(length:%d)\n", *(uint32_t *)(tf->epc),4);
ffffffffc0200bd4:	428c                	lw	a1,0(a3)
ffffffffc0200bd6:	4611                	li	a2,4
ffffffffc0200bd8:	00002517          	auipc	a0,0x2
ffffffffc0200bdc:	d0850513          	addi	a0,a0,-760 # ffffffffc02028e0 <etext+0x8e4>
ffffffffc0200be0:	d2cff0ef          	jal	ffffffffc020010c <cprintf>
ffffffffc0200be4:	67a2                	ld	a5,8(sp)
ffffffffc0200be6:	b7b1                	j	ffffffffc0200b32 <exception_handler+0x5c>

ffffffffc0200be8 <trap>:

static inline void trap_dispatch(struct trapframe *tf) {
    if ((intptr_t)tf->cause < 0) {
ffffffffc0200be8:	11853783          	ld	a5,280(a0)
ffffffffc0200bec:	0007c363          	bltz	a5,ffffffffc0200bf2 <trap+0xa>
        // interrupts
        interrupt_handler(tf);
    } else {
        // exceptions
        exception_handler(tf);
ffffffffc0200bf0:	b5dd                	j	ffffffffc0200ad6 <exception_handler>
        interrupt_handler(tf);
ffffffffc0200bf2:	b539                	j	ffffffffc0200a00 <interrupt_handler>

ffffffffc0200bf4 <__alltraps>:
    .endm

    .globl __alltraps
    .align(2)
__alltraps:
    SAVE_ALL
ffffffffc0200bf4:	14011073          	csrw	sscratch,sp
ffffffffc0200bf8:	712d                	addi	sp,sp,-288
ffffffffc0200bfa:	e002                	sd	zero,0(sp)
ffffffffc0200bfc:	e406                	sd	ra,8(sp)
ffffffffc0200bfe:	ec0e                	sd	gp,24(sp)
ffffffffc0200c00:	f012                	sd	tp,32(sp)
ffffffffc0200c02:	f416                	sd	t0,40(sp)
ffffffffc0200c04:	f81a                	sd	t1,48(sp)
ffffffffc0200c06:	fc1e                	sd	t2,56(sp)
ffffffffc0200c08:	e0a2                	sd	s0,64(sp)
ffffffffc0200c0a:	e4a6                	sd	s1,72(sp)
ffffffffc0200c0c:	e8aa                	sd	a0,80(sp)
ffffffffc0200c0e:	ecae                	sd	a1,88(sp)
ffffffffc0200c10:	f0b2                	sd	a2,96(sp)
ffffffffc0200c12:	f4b6                	sd	a3,104(sp)
ffffffffc0200c14:	f8ba                	sd	a4,112(sp)
ffffffffc0200c16:	fcbe                	sd	a5,120(sp)
ffffffffc0200c18:	e142                	sd	a6,128(sp)
ffffffffc0200c1a:	e546                	sd	a7,136(sp)
ffffffffc0200c1c:	e94a                	sd	s2,144(sp)
ffffffffc0200c1e:	ed4e                	sd	s3,152(sp)
ffffffffc0200c20:	f152                	sd	s4,160(sp)
ffffffffc0200c22:	f556                	sd	s5,168(sp)
ffffffffc0200c24:	f95a                	sd	s6,176(sp)
ffffffffc0200c26:	fd5e                	sd	s7,184(sp)
ffffffffc0200c28:	e1e2                	sd	s8,192(sp)
ffffffffc0200c2a:	e5e6                	sd	s9,200(sp)
ffffffffc0200c2c:	e9ea                	sd	s10,208(sp)
ffffffffc0200c2e:	edee                	sd	s11,216(sp)
ffffffffc0200c30:	f1f2                	sd	t3,224(sp)
ffffffffc0200c32:	f5f6                	sd	t4,232(sp)
ffffffffc0200c34:	f9fa                	sd	t5,240(sp)
ffffffffc0200c36:	fdfe                	sd	t6,248(sp)
ffffffffc0200c38:	14001473          	csrrw	s0,sscratch,zero
ffffffffc0200c3c:	100024f3          	csrr	s1,sstatus
ffffffffc0200c40:	14102973          	csrr	s2,sepc
ffffffffc0200c44:	143029f3          	csrr	s3,stval
ffffffffc0200c48:	14202a73          	csrr	s4,scause
ffffffffc0200c4c:	e822                	sd	s0,16(sp)
ffffffffc0200c4e:	e226                	sd	s1,256(sp)
ffffffffc0200c50:	e64a                	sd	s2,264(sp)
ffffffffc0200c52:	ea4e                	sd	s3,272(sp)
ffffffffc0200c54:	ee52                	sd	s4,280(sp)

    move  a0, sp
ffffffffc0200c56:	850a                	mv	a0,sp
    jal trap
ffffffffc0200c58:	f91ff0ef          	jal	ffffffffc0200be8 <trap>

ffffffffc0200c5c <__trapret>:
    # sp should be the same as before "jal trap"

    .globl __trapret
__trapret:
    RESTORE_ALL
ffffffffc0200c5c:	6492                	ld	s1,256(sp)
ffffffffc0200c5e:	6932                	ld	s2,264(sp)
ffffffffc0200c60:	10049073          	csrw	sstatus,s1
ffffffffc0200c64:	14191073          	csrw	sepc,s2
ffffffffc0200c68:	60a2                	ld	ra,8(sp)
ffffffffc0200c6a:	61e2                	ld	gp,24(sp)
ffffffffc0200c6c:	7202                	ld	tp,32(sp)
ffffffffc0200c6e:	72a2                	ld	t0,40(sp)
ffffffffc0200c70:	7342                	ld	t1,48(sp)
ffffffffc0200c72:	73e2                	ld	t2,56(sp)
ffffffffc0200c74:	6406                	ld	s0,64(sp)
ffffffffc0200c76:	64a6                	ld	s1,72(sp)
ffffffffc0200c78:	6546                	ld	a0,80(sp)
ffffffffc0200c7a:	65e6                	ld	a1,88(sp)
ffffffffc0200c7c:	7606                	ld	a2,96(sp)
ffffffffc0200c7e:	76a6                	ld	a3,104(sp)
ffffffffc0200c80:	7746                	ld	a4,112(sp)
ffffffffc0200c82:	77e6                	ld	a5,120(sp)
ffffffffc0200c84:	680a                	ld	a6,128(sp)
ffffffffc0200c86:	68aa                	ld	a7,136(sp)
ffffffffc0200c88:	694a                	ld	s2,144(sp)
ffffffffc0200c8a:	69ea                	ld	s3,152(sp)
ffffffffc0200c8c:	7a0a                	ld	s4,160(sp)
ffffffffc0200c8e:	7aaa                	ld	s5,168(sp)
ffffffffc0200c90:	7b4a                	ld	s6,176(sp)
ffffffffc0200c92:	7bea                	ld	s7,184(sp)
ffffffffc0200c94:	6c0e                	ld	s8,192(sp)
ffffffffc0200c96:	6cae                	ld	s9,200(sp)
ffffffffc0200c98:	6d4e                	ld	s10,208(sp)
ffffffffc0200c9a:	6dee                	ld	s11,216(sp)
ffffffffc0200c9c:	7e0e                	ld	t3,224(sp)
ffffffffc0200c9e:	7eae                	ld	t4,232(sp)
ffffffffc0200ca0:	7f4e                	ld	t5,240(sp)
ffffffffc0200ca2:	7fee                	ld	t6,248(sp)
ffffffffc0200ca4:	6142                	ld	sp,16(sp)
    # return from supervisor call
    sret
ffffffffc0200ca6:	10200073          	sret

ffffffffc0200caa <default_init>:
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc0200caa:	00006797          	auipc	a5,0x6
ffffffffc0200cae:	37e78793          	addi	a5,a5,894 # ffffffffc0207028 <free_area>
ffffffffc0200cb2:	e79c                	sd	a5,8(a5)
ffffffffc0200cb4:	e39c                	sd	a5,0(a5)
#define nr_free (free_area.nr_free)

static void
default_init(void) {
    list_init(&free_list);
    nr_free = 0;
ffffffffc0200cb6:	0007a823          	sw	zero,16(a5)
}
ffffffffc0200cba:	8082                	ret

ffffffffc0200cbc <default_nr_free_pages>:
}

static size_t
default_nr_free_pages(void) {
    return nr_free;
}
ffffffffc0200cbc:	00006517          	auipc	a0,0x6
ffffffffc0200cc0:	37c56503          	lwu	a0,892(a0) # ffffffffc0207038 <free_area+0x10>
ffffffffc0200cc4:	8082                	ret

ffffffffc0200cc6 <default_check>:
}

// LAB2: below code is used to check the first fit allocation algorithm (your EXERCISE 1) 
// NOTICE: You SHOULD NOT CHANGE basic_check, default_check functions!
static void
default_check(void) {
ffffffffc0200cc6:	711d                	addi	sp,sp,-96
ffffffffc0200cc8:	e0ca                	sd	s2,64(sp)
 * list_next - get the next entry
 * @listelm:    the list head
 **/
static inline list_entry_t *
list_next(list_entry_t *listelm) {
    return listelm->next;
ffffffffc0200cca:	00006917          	auipc	s2,0x6
ffffffffc0200cce:	35e90913          	addi	s2,s2,862 # ffffffffc0207028 <free_area>
ffffffffc0200cd2:	00893783          	ld	a5,8(s2)
ffffffffc0200cd6:	ec86                	sd	ra,88(sp)
ffffffffc0200cd8:	e8a2                	sd	s0,80(sp)
ffffffffc0200cda:	e4a6                	sd	s1,72(sp)
ffffffffc0200cdc:	fc4e                	sd	s3,56(sp)
ffffffffc0200cde:	f852                	sd	s4,48(sp)
ffffffffc0200ce0:	f456                	sd	s5,40(sp)
ffffffffc0200ce2:	f05a                	sd	s6,32(sp)
ffffffffc0200ce4:	ec5e                	sd	s7,24(sp)
ffffffffc0200ce6:	e862                	sd	s8,16(sp)
ffffffffc0200ce8:	e466                	sd	s9,8(sp)
    int count = 0, total = 0;
    list_entry_t *le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200cea:	31278b63          	beq	a5,s2,ffffffffc0201000 <default_check+0x33a>
    int count = 0, total = 0;
ffffffffc0200cee:	4401                	li	s0,0
ffffffffc0200cf0:	4481                	li	s1,0
 * test_bit - Determine whether a bit is set
 * @nr:     the bit to test
 * @addr:   the address to count from
 * */
static inline bool test_bit(int nr, volatile void *addr) {
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc0200cf2:	ff07b703          	ld	a4,-16(a5)
        struct Page *p = le2page(le, page_link);
        assert(PageProperty(p));
ffffffffc0200cf6:	8b09                	andi	a4,a4,2
ffffffffc0200cf8:	30070863          	beqz	a4,ffffffffc0201008 <default_check+0x342>
        count ++, total += p->property;
ffffffffc0200cfc:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200d00:	679c                	ld	a5,8(a5)
ffffffffc0200d02:	2485                	addiw	s1,s1,1
ffffffffc0200d04:	9c39                	addw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200d06:	ff2796e3          	bne	a5,s2,ffffffffc0200cf2 <default_check+0x2c>
    }
    assert(total == nr_free_pages());
ffffffffc0200d0a:	89a2                	mv	s3,s0
ffffffffc0200d0c:	33f000ef          	jal	ffffffffc020184a <nr_free_pages>
ffffffffc0200d10:	75351c63          	bne	a0,s3,ffffffffc0201468 <default_check+0x7a2>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200d14:	4505                	li	a0,1
ffffffffc0200d16:	2c3000ef          	jal	ffffffffc02017d8 <alloc_pages>
ffffffffc0200d1a:	8aaa                	mv	s5,a0
ffffffffc0200d1c:	48050663          	beqz	a0,ffffffffc02011a8 <default_check+0x4e2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200d20:	4505                	li	a0,1
ffffffffc0200d22:	2b7000ef          	jal	ffffffffc02017d8 <alloc_pages>
ffffffffc0200d26:	89aa                	mv	s3,a0
ffffffffc0200d28:	76050063          	beqz	a0,ffffffffc0201488 <default_check+0x7c2>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200d2c:	4505                	li	a0,1
ffffffffc0200d2e:	2ab000ef          	jal	ffffffffc02017d8 <alloc_pages>
ffffffffc0200d32:	8a2a                	mv	s4,a0
ffffffffc0200d34:	4e050a63          	beqz	a0,ffffffffc0201228 <default_check+0x562>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0200d38:	40aa87b3          	sub	a5,s5,a0
ffffffffc0200d3c:	40a98733          	sub	a4,s3,a0
ffffffffc0200d40:	0017b793          	seqz	a5,a5
ffffffffc0200d44:	00173713          	seqz	a4,a4
ffffffffc0200d48:	8fd9                	or	a5,a5,a4
ffffffffc0200d4a:	32079f63          	bnez	a5,ffffffffc0201088 <default_check+0x3c2>
ffffffffc0200d4e:	333a8d63          	beq	s5,s3,ffffffffc0201088 <default_check+0x3c2>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0200d52:	000aa783          	lw	a5,0(s5)
ffffffffc0200d56:	2c079963          	bnez	a5,ffffffffc0201028 <default_check+0x362>
ffffffffc0200d5a:	0009a783          	lw	a5,0(s3)
ffffffffc0200d5e:	2c079563          	bnez	a5,ffffffffc0201028 <default_check+0x362>
ffffffffc0200d62:	411c                	lw	a5,0(a0)
ffffffffc0200d64:	2c079263          	bnez	a5,ffffffffc0201028 <default_check+0x362>
extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
extern uint64_t va_pa_offset;

static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200d68:	00006797          	auipc	a5,0x6
ffffffffc0200d6c:	7207b783          	ld	a5,1824(a5) # ffffffffc0207488 <pages>
ffffffffc0200d70:	ccccd737          	lui	a4,0xccccd
ffffffffc0200d74:	ccd70713          	addi	a4,a4,-819 # ffffffffcccccccd <end+0xcac5835>
ffffffffc0200d78:	02071693          	slli	a3,a4,0x20
ffffffffc0200d7c:	96ba                	add	a3,a3,a4
ffffffffc0200d7e:	40fa8733          	sub	a4,s5,a5
ffffffffc0200d82:	870d                	srai	a4,a4,0x3
ffffffffc0200d84:	02d70733          	mul	a4,a4,a3
ffffffffc0200d88:	00002517          	auipc	a0,0x2
ffffffffc0200d8c:	3f853503          	ld	a0,1016(a0) # ffffffffc0203180 <nbase>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0200d90:	00006697          	auipc	a3,0x6
ffffffffc0200d94:	6f06b683          	ld	a3,1776(a3) # ffffffffc0207480 <npage>
ffffffffc0200d98:	06b2                	slli	a3,a3,0xc
ffffffffc0200d9a:	972a                	add	a4,a4,a0

static inline uintptr_t page2pa(struct Page *page) {
    return page2ppn(page) << PGSHIFT;
ffffffffc0200d9c:	0732                	slli	a4,a4,0xc
ffffffffc0200d9e:	2cd77563          	bgeu	a4,a3,ffffffffc0201068 <default_check+0x3a2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200da2:	ccccd5b7          	lui	a1,0xccccd
ffffffffc0200da6:	ccd58593          	addi	a1,a1,-819 # ffffffffcccccccd <end+0xcac5835>
ffffffffc0200daa:	02059613          	slli	a2,a1,0x20
ffffffffc0200dae:	40f98733          	sub	a4,s3,a5
ffffffffc0200db2:	962e                	add	a2,a2,a1
ffffffffc0200db4:	870d                	srai	a4,a4,0x3
ffffffffc0200db6:	02c70733          	mul	a4,a4,a2
ffffffffc0200dba:	972a                	add	a4,a4,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0200dbc:	0732                	slli	a4,a4,0xc
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc0200dbe:	4ed77563          	bgeu	a4,a3,ffffffffc02012a8 <default_check+0x5e2>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200dc2:	40fa07b3          	sub	a5,s4,a5
ffffffffc0200dc6:	878d                	srai	a5,a5,0x3
ffffffffc0200dc8:	02c787b3          	mul	a5,a5,a2
ffffffffc0200dcc:	97aa                	add	a5,a5,a0
    return page2ppn(page) << PGSHIFT;
ffffffffc0200dce:	07b2                	slli	a5,a5,0xc
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0200dd0:	32d7fc63          	bgeu	a5,a3,ffffffffc0201108 <default_check+0x442>
    assert(alloc_page() == NULL);
ffffffffc0200dd4:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200dd6:	00093c03          	ld	s8,0(s2)
ffffffffc0200dda:	00893b83          	ld	s7,8(s2)
    unsigned int nr_free_store = nr_free;
ffffffffc0200dde:	00006b17          	auipc	s6,0x6
ffffffffc0200de2:	25ab2b03          	lw	s6,602(s6) # ffffffffc0207038 <free_area+0x10>
    elm->prev = elm->next = elm;
ffffffffc0200de6:	01293023          	sd	s2,0(s2)
ffffffffc0200dea:	01293423          	sd	s2,8(s2)
    nr_free = 0;
ffffffffc0200dee:	00006797          	auipc	a5,0x6
ffffffffc0200df2:	2407a523          	sw	zero,586(a5) # ffffffffc0207038 <free_area+0x10>
    assert(alloc_page() == NULL);
ffffffffc0200df6:	1e3000ef          	jal	ffffffffc02017d8 <alloc_pages>
ffffffffc0200dfa:	2e051763          	bnez	a0,ffffffffc02010e8 <default_check+0x422>
    free_page(p0);
ffffffffc0200dfe:	8556                	mv	a0,s5
ffffffffc0200e00:	4585                	li	a1,1
ffffffffc0200e02:	211000ef          	jal	ffffffffc0201812 <free_pages>
    free_page(p1);
ffffffffc0200e06:	854e                	mv	a0,s3
ffffffffc0200e08:	4585                	li	a1,1
ffffffffc0200e0a:	209000ef          	jal	ffffffffc0201812 <free_pages>
    free_page(p2);
ffffffffc0200e0e:	8552                	mv	a0,s4
ffffffffc0200e10:	4585                	li	a1,1
ffffffffc0200e12:	201000ef          	jal	ffffffffc0201812 <free_pages>
    assert(nr_free == 3);
ffffffffc0200e16:	00006717          	auipc	a4,0x6
ffffffffc0200e1a:	22272703          	lw	a4,546(a4) # ffffffffc0207038 <free_area+0x10>
ffffffffc0200e1e:	478d                	li	a5,3
ffffffffc0200e20:	2af71463          	bne	a4,a5,ffffffffc02010c8 <default_check+0x402>
    assert((p0 = alloc_page()) != NULL);
ffffffffc0200e24:	4505                	li	a0,1
ffffffffc0200e26:	1b3000ef          	jal	ffffffffc02017d8 <alloc_pages>
ffffffffc0200e2a:	89aa                	mv	s3,a0
ffffffffc0200e2c:	26050e63          	beqz	a0,ffffffffc02010a8 <default_check+0x3e2>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0200e30:	4505                	li	a0,1
ffffffffc0200e32:	1a7000ef          	jal	ffffffffc02017d8 <alloc_pages>
ffffffffc0200e36:	8aaa                	mv	s5,a0
ffffffffc0200e38:	3c050863          	beqz	a0,ffffffffc0201208 <default_check+0x542>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0200e3c:	4505                	li	a0,1
ffffffffc0200e3e:	19b000ef          	jal	ffffffffc02017d8 <alloc_pages>
ffffffffc0200e42:	8a2a                	mv	s4,a0
ffffffffc0200e44:	3a050263          	beqz	a0,ffffffffc02011e8 <default_check+0x522>
    assert(alloc_page() == NULL);
ffffffffc0200e48:	4505                	li	a0,1
ffffffffc0200e4a:	18f000ef          	jal	ffffffffc02017d8 <alloc_pages>
ffffffffc0200e4e:	36051d63          	bnez	a0,ffffffffc02011c8 <default_check+0x502>
    free_page(p0);
ffffffffc0200e52:	4585                	li	a1,1
ffffffffc0200e54:	854e                	mv	a0,s3
ffffffffc0200e56:	1bd000ef          	jal	ffffffffc0201812 <free_pages>
    assert(!list_empty(&free_list));
ffffffffc0200e5a:	00893783          	ld	a5,8(s2)
ffffffffc0200e5e:	1f278563          	beq	a5,s2,ffffffffc0201048 <default_check+0x382>
    assert((p = alloc_page()) == p0);
ffffffffc0200e62:	4505                	li	a0,1
ffffffffc0200e64:	175000ef          	jal	ffffffffc02017d8 <alloc_pages>
ffffffffc0200e68:	8caa                	mv	s9,a0
ffffffffc0200e6a:	30a99f63          	bne	s3,a0,ffffffffc0201188 <default_check+0x4c2>
    assert(alloc_page() == NULL);
ffffffffc0200e6e:	4505                	li	a0,1
ffffffffc0200e70:	169000ef          	jal	ffffffffc02017d8 <alloc_pages>
ffffffffc0200e74:	2e051a63          	bnez	a0,ffffffffc0201168 <default_check+0x4a2>
    assert(nr_free == 0);
ffffffffc0200e78:	00006797          	auipc	a5,0x6
ffffffffc0200e7c:	1c07a783          	lw	a5,448(a5) # ffffffffc0207038 <free_area+0x10>
ffffffffc0200e80:	2c079463          	bnez	a5,ffffffffc0201148 <default_check+0x482>
    free_page(p);
ffffffffc0200e84:	8566                	mv	a0,s9
ffffffffc0200e86:	4585                	li	a1,1
    free_list = free_list_store;
ffffffffc0200e88:	01893023          	sd	s8,0(s2)
ffffffffc0200e8c:	01793423          	sd	s7,8(s2)
    nr_free = nr_free_store;
ffffffffc0200e90:	01692823          	sw	s6,16(s2)
    free_page(p);
ffffffffc0200e94:	17f000ef          	jal	ffffffffc0201812 <free_pages>
    free_page(p1);
ffffffffc0200e98:	8556                	mv	a0,s5
ffffffffc0200e9a:	4585                	li	a1,1
ffffffffc0200e9c:	177000ef          	jal	ffffffffc0201812 <free_pages>
    free_page(p2);
ffffffffc0200ea0:	8552                	mv	a0,s4
ffffffffc0200ea2:	4585                	li	a1,1
ffffffffc0200ea4:	16f000ef          	jal	ffffffffc0201812 <free_pages>

    basic_check();

    struct Page *p0 = alloc_pages(5), *p1, *p2;
ffffffffc0200ea8:	4515                	li	a0,5
ffffffffc0200eaa:	12f000ef          	jal	ffffffffc02017d8 <alloc_pages>
ffffffffc0200eae:	89aa                	mv	s3,a0
    assert(p0 != NULL);
ffffffffc0200eb0:	26050c63          	beqz	a0,ffffffffc0201128 <default_check+0x462>
ffffffffc0200eb4:	651c                	ld	a5,8(a0)
ffffffffc0200eb6:	8385                	srli	a5,a5,0x1
    assert(!PageProperty(p0));
ffffffffc0200eb8:	8b85                	andi	a5,a5,1
ffffffffc0200eba:	54079763          	bnez	a5,ffffffffc0201408 <default_check+0x742>

    list_entry_t free_list_store = free_list;
    list_init(&free_list);
    assert(list_empty(&free_list));
    assert(alloc_page() == NULL);
ffffffffc0200ebe:	4505                	li	a0,1
    list_entry_t free_list_store = free_list;
ffffffffc0200ec0:	00093b83          	ld	s7,0(s2)
ffffffffc0200ec4:	00893b03          	ld	s6,8(s2)
ffffffffc0200ec8:	01293023          	sd	s2,0(s2)
ffffffffc0200ecc:	01293423          	sd	s2,8(s2)
    assert(alloc_page() == NULL);
ffffffffc0200ed0:	109000ef          	jal	ffffffffc02017d8 <alloc_pages>
ffffffffc0200ed4:	50051a63          	bnez	a0,ffffffffc02013e8 <default_check+0x722>

    unsigned int nr_free_store = nr_free;
    nr_free = 0;

    free_pages(p0 + 2, 3);
ffffffffc0200ed8:	05098a13          	addi	s4,s3,80
ffffffffc0200edc:	8552                	mv	a0,s4
ffffffffc0200ede:	458d                	li	a1,3
    unsigned int nr_free_store = nr_free;
ffffffffc0200ee0:	00006c17          	auipc	s8,0x6
ffffffffc0200ee4:	158c2c03          	lw	s8,344(s8) # ffffffffc0207038 <free_area+0x10>
    nr_free = 0;
ffffffffc0200ee8:	00006797          	auipc	a5,0x6
ffffffffc0200eec:	1407a823          	sw	zero,336(a5) # ffffffffc0207038 <free_area+0x10>
    free_pages(p0 + 2, 3);
ffffffffc0200ef0:	123000ef          	jal	ffffffffc0201812 <free_pages>
    assert(alloc_pages(4) == NULL);
ffffffffc0200ef4:	4511                	li	a0,4
ffffffffc0200ef6:	0e3000ef          	jal	ffffffffc02017d8 <alloc_pages>
ffffffffc0200efa:	4c051763          	bnez	a0,ffffffffc02013c8 <default_check+0x702>
ffffffffc0200efe:	0589b783          	ld	a5,88(s3)
ffffffffc0200f02:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc0200f04:	8b85                	andi	a5,a5,1
ffffffffc0200f06:	4a078163          	beqz	a5,ffffffffc02013a8 <default_check+0x6e2>
ffffffffc0200f0a:	0609a503          	lw	a0,96(s3)
ffffffffc0200f0e:	478d                	li	a5,3
ffffffffc0200f10:	48f51c63          	bne	a0,a5,ffffffffc02013a8 <default_check+0x6e2>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0200f14:	0c5000ef          	jal	ffffffffc02017d8 <alloc_pages>
ffffffffc0200f18:	8aaa                	mv	s5,a0
ffffffffc0200f1a:	46050763          	beqz	a0,ffffffffc0201388 <default_check+0x6c2>
    assert(alloc_page() == NULL);
ffffffffc0200f1e:	4505                	li	a0,1
ffffffffc0200f20:	0b9000ef          	jal	ffffffffc02017d8 <alloc_pages>
ffffffffc0200f24:	44051263          	bnez	a0,ffffffffc0201368 <default_check+0x6a2>
    assert(p0 + 2 == p1);
ffffffffc0200f28:	435a1063          	bne	s4,s5,ffffffffc0201348 <default_check+0x682>

    p2 = p0 + 1;
    free_page(p0);
ffffffffc0200f2c:	4585                	li	a1,1
ffffffffc0200f2e:	854e                	mv	a0,s3
ffffffffc0200f30:	0e3000ef          	jal	ffffffffc0201812 <free_pages>
    free_pages(p1, 3);
ffffffffc0200f34:	8552                	mv	a0,s4
ffffffffc0200f36:	458d                	li	a1,3
ffffffffc0200f38:	0db000ef          	jal	ffffffffc0201812 <free_pages>
ffffffffc0200f3c:	0089b783          	ld	a5,8(s3)
ffffffffc0200f40:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0200f42:	8b85                	andi	a5,a5,1
ffffffffc0200f44:	3e078263          	beqz	a5,ffffffffc0201328 <default_check+0x662>
ffffffffc0200f48:	0109aa83          	lw	s5,16(s3)
ffffffffc0200f4c:	4785                	li	a5,1
ffffffffc0200f4e:	3cfa9d63          	bne	s5,a5,ffffffffc0201328 <default_check+0x662>
ffffffffc0200f52:	008a3783          	ld	a5,8(s4)
ffffffffc0200f56:	8385                	srli	a5,a5,0x1
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0200f58:	8b85                	andi	a5,a5,1
ffffffffc0200f5a:	3a078763          	beqz	a5,ffffffffc0201308 <default_check+0x642>
ffffffffc0200f5e:	010a2703          	lw	a4,16(s4)
ffffffffc0200f62:	478d                	li	a5,3
ffffffffc0200f64:	3af71263          	bne	a4,a5,ffffffffc0201308 <default_check+0x642>

    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc0200f68:	8556                	mv	a0,s5
ffffffffc0200f6a:	06f000ef          	jal	ffffffffc02017d8 <alloc_pages>
ffffffffc0200f6e:	36a99d63          	bne	s3,a0,ffffffffc02012e8 <default_check+0x622>
    free_page(p0);
ffffffffc0200f72:	85d6                	mv	a1,s5
ffffffffc0200f74:	09f000ef          	jal	ffffffffc0201812 <free_pages>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc0200f78:	4509                	li	a0,2
ffffffffc0200f7a:	05f000ef          	jal	ffffffffc02017d8 <alloc_pages>
ffffffffc0200f7e:	34aa1563          	bne	s4,a0,ffffffffc02012c8 <default_check+0x602>

    free_pages(p0, 2);
ffffffffc0200f82:	4589                	li	a1,2
ffffffffc0200f84:	08f000ef          	jal	ffffffffc0201812 <free_pages>
    free_page(p2);
ffffffffc0200f88:	02898513          	addi	a0,s3,40
ffffffffc0200f8c:	85d6                	mv	a1,s5
ffffffffc0200f8e:	085000ef          	jal	ffffffffc0201812 <free_pages>

    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0200f92:	4515                	li	a0,5
ffffffffc0200f94:	045000ef          	jal	ffffffffc02017d8 <alloc_pages>
ffffffffc0200f98:	89aa                	mv	s3,a0
ffffffffc0200f9a:	48050763          	beqz	a0,ffffffffc0201428 <default_check+0x762>
    assert(alloc_page() == NULL);
ffffffffc0200f9e:	8556                	mv	a0,s5
ffffffffc0200fa0:	039000ef          	jal	ffffffffc02017d8 <alloc_pages>
ffffffffc0200fa4:	2e051263          	bnez	a0,ffffffffc0201288 <default_check+0x5c2>

    assert(nr_free == 0);
ffffffffc0200fa8:	00006797          	auipc	a5,0x6
ffffffffc0200fac:	0907a783          	lw	a5,144(a5) # ffffffffc0207038 <free_area+0x10>
ffffffffc0200fb0:	2a079c63          	bnez	a5,ffffffffc0201268 <default_check+0x5a2>
    nr_free = nr_free_store;

    free_list = free_list_store;
    free_pages(p0, 5);
ffffffffc0200fb4:	854e                	mv	a0,s3
ffffffffc0200fb6:	4595                	li	a1,5
    nr_free = nr_free_store;
ffffffffc0200fb8:	01892823          	sw	s8,16(s2)
    free_list = free_list_store;
ffffffffc0200fbc:	01793023          	sd	s7,0(s2)
ffffffffc0200fc0:	01693423          	sd	s6,8(s2)
    free_pages(p0, 5);
ffffffffc0200fc4:	04f000ef          	jal	ffffffffc0201812 <free_pages>
    return listelm->next;
ffffffffc0200fc8:	00893783          	ld	a5,8(s2)

    le = &free_list;
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200fcc:	01278963          	beq	a5,s2,ffffffffc0200fde <default_check+0x318>
        struct Page *p = le2page(le, page_link);
        count --, total -= p->property;
ffffffffc0200fd0:	ff87a703          	lw	a4,-8(a5)
ffffffffc0200fd4:	679c                	ld	a5,8(a5)
ffffffffc0200fd6:	34fd                	addiw	s1,s1,-1
ffffffffc0200fd8:	9c19                	subw	s0,s0,a4
    while ((le = list_next(le)) != &free_list) {
ffffffffc0200fda:	ff279be3          	bne	a5,s2,ffffffffc0200fd0 <default_check+0x30a>
    }
    assert(count == 0);
ffffffffc0200fde:	26049563          	bnez	s1,ffffffffc0201248 <default_check+0x582>
    assert(total == 0);
ffffffffc0200fe2:	46041363          	bnez	s0,ffffffffc0201448 <default_check+0x782>
}
ffffffffc0200fe6:	60e6                	ld	ra,88(sp)
ffffffffc0200fe8:	6446                	ld	s0,80(sp)
ffffffffc0200fea:	64a6                	ld	s1,72(sp)
ffffffffc0200fec:	6906                	ld	s2,64(sp)
ffffffffc0200fee:	79e2                	ld	s3,56(sp)
ffffffffc0200ff0:	7a42                	ld	s4,48(sp)
ffffffffc0200ff2:	7aa2                	ld	s5,40(sp)
ffffffffc0200ff4:	7b02                	ld	s6,32(sp)
ffffffffc0200ff6:	6be2                	ld	s7,24(sp)
ffffffffc0200ff8:	6c42                	ld	s8,16(sp)
ffffffffc0200ffa:	6ca2                	ld	s9,8(sp)
ffffffffc0200ffc:	6125                	addi	sp,sp,96
ffffffffc0200ffe:	8082                	ret
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201000:	4981                	li	s3,0
    int count = 0, total = 0;
ffffffffc0201002:	4401                	li	s0,0
ffffffffc0201004:	4481                	li	s1,0
ffffffffc0201006:	b319                	j	ffffffffc0200d0c <default_check+0x46>
        assert(PageProperty(p));
ffffffffc0201008:	00002697          	auipc	a3,0x2
ffffffffc020100c:	95868693          	addi	a3,a3,-1704 # ffffffffc0202960 <etext+0x964>
ffffffffc0201010:	00002617          	auipc	a2,0x2
ffffffffc0201014:	96060613          	addi	a2,a2,-1696 # ffffffffc0202970 <etext+0x974>
ffffffffc0201018:	0f000593          	li	a1,240
ffffffffc020101c:	00002517          	auipc	a0,0x2
ffffffffc0201020:	96c50513          	addi	a0,a0,-1684 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201024:	b9aff0ef          	jal	ffffffffc02003be <__panic>
    assert(page_ref(p0) == 0 && page_ref(p1) == 0 && page_ref(p2) == 0);
ffffffffc0201028:	00002697          	auipc	a3,0x2
ffffffffc020102c:	a2068693          	addi	a3,a3,-1504 # ffffffffc0202a48 <etext+0xa4c>
ffffffffc0201030:	00002617          	auipc	a2,0x2
ffffffffc0201034:	94060613          	addi	a2,a2,-1728 # ffffffffc0202970 <etext+0x974>
ffffffffc0201038:	0be00593          	li	a1,190
ffffffffc020103c:	00002517          	auipc	a0,0x2
ffffffffc0201040:	94c50513          	addi	a0,a0,-1716 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201044:	b7aff0ef          	jal	ffffffffc02003be <__panic>
    assert(!list_empty(&free_list));
ffffffffc0201048:	00002697          	auipc	a3,0x2
ffffffffc020104c:	ac868693          	addi	a3,a3,-1336 # ffffffffc0202b10 <etext+0xb14>
ffffffffc0201050:	00002617          	auipc	a2,0x2
ffffffffc0201054:	92060613          	addi	a2,a2,-1760 # ffffffffc0202970 <etext+0x974>
ffffffffc0201058:	0d900593          	li	a1,217
ffffffffc020105c:	00002517          	auipc	a0,0x2
ffffffffc0201060:	92c50513          	addi	a0,a0,-1748 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201064:	b5aff0ef          	jal	ffffffffc02003be <__panic>
    assert(page2pa(p0) < npage * PGSIZE);
ffffffffc0201068:	00002697          	auipc	a3,0x2
ffffffffc020106c:	a2068693          	addi	a3,a3,-1504 # ffffffffc0202a88 <etext+0xa8c>
ffffffffc0201070:	00002617          	auipc	a2,0x2
ffffffffc0201074:	90060613          	addi	a2,a2,-1792 # ffffffffc0202970 <etext+0x974>
ffffffffc0201078:	0c000593          	li	a1,192
ffffffffc020107c:	00002517          	auipc	a0,0x2
ffffffffc0201080:	90c50513          	addi	a0,a0,-1780 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201084:	b3aff0ef          	jal	ffffffffc02003be <__panic>
    assert(p0 != p1 && p0 != p2 && p1 != p2);
ffffffffc0201088:	00002697          	auipc	a3,0x2
ffffffffc020108c:	99868693          	addi	a3,a3,-1640 # ffffffffc0202a20 <etext+0xa24>
ffffffffc0201090:	00002617          	auipc	a2,0x2
ffffffffc0201094:	8e060613          	addi	a2,a2,-1824 # ffffffffc0202970 <etext+0x974>
ffffffffc0201098:	0bd00593          	li	a1,189
ffffffffc020109c:	00002517          	auipc	a0,0x2
ffffffffc02010a0:	8ec50513          	addi	a0,a0,-1812 # ffffffffc0202988 <etext+0x98c>
ffffffffc02010a4:	b1aff0ef          	jal	ffffffffc02003be <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02010a8:	00002697          	auipc	a3,0x2
ffffffffc02010ac:	91868693          	addi	a3,a3,-1768 # ffffffffc02029c0 <etext+0x9c4>
ffffffffc02010b0:	00002617          	auipc	a2,0x2
ffffffffc02010b4:	8c060613          	addi	a2,a2,-1856 # ffffffffc0202970 <etext+0x974>
ffffffffc02010b8:	0d200593          	li	a1,210
ffffffffc02010bc:	00002517          	auipc	a0,0x2
ffffffffc02010c0:	8cc50513          	addi	a0,a0,-1844 # ffffffffc0202988 <etext+0x98c>
ffffffffc02010c4:	afaff0ef          	jal	ffffffffc02003be <__panic>
    assert(nr_free == 3);
ffffffffc02010c8:	00002697          	auipc	a3,0x2
ffffffffc02010cc:	a3868693          	addi	a3,a3,-1480 # ffffffffc0202b00 <etext+0xb04>
ffffffffc02010d0:	00002617          	auipc	a2,0x2
ffffffffc02010d4:	8a060613          	addi	a2,a2,-1888 # ffffffffc0202970 <etext+0x974>
ffffffffc02010d8:	0d000593          	li	a1,208
ffffffffc02010dc:	00002517          	auipc	a0,0x2
ffffffffc02010e0:	8ac50513          	addi	a0,a0,-1876 # ffffffffc0202988 <etext+0x98c>
ffffffffc02010e4:	adaff0ef          	jal	ffffffffc02003be <__panic>
    assert(alloc_page() == NULL);
ffffffffc02010e8:	00002697          	auipc	a3,0x2
ffffffffc02010ec:	a0068693          	addi	a3,a3,-1536 # ffffffffc0202ae8 <etext+0xaec>
ffffffffc02010f0:	00002617          	auipc	a2,0x2
ffffffffc02010f4:	88060613          	addi	a2,a2,-1920 # ffffffffc0202970 <etext+0x974>
ffffffffc02010f8:	0cb00593          	li	a1,203
ffffffffc02010fc:	00002517          	auipc	a0,0x2
ffffffffc0201100:	88c50513          	addi	a0,a0,-1908 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201104:	abaff0ef          	jal	ffffffffc02003be <__panic>
    assert(page2pa(p2) < npage * PGSIZE);
ffffffffc0201108:	00002697          	auipc	a3,0x2
ffffffffc020110c:	9c068693          	addi	a3,a3,-1600 # ffffffffc0202ac8 <etext+0xacc>
ffffffffc0201110:	00002617          	auipc	a2,0x2
ffffffffc0201114:	86060613          	addi	a2,a2,-1952 # ffffffffc0202970 <etext+0x974>
ffffffffc0201118:	0c200593          	li	a1,194
ffffffffc020111c:	00002517          	auipc	a0,0x2
ffffffffc0201120:	86c50513          	addi	a0,a0,-1940 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201124:	a9aff0ef          	jal	ffffffffc02003be <__panic>
    assert(p0 != NULL);
ffffffffc0201128:	00002697          	auipc	a3,0x2
ffffffffc020112c:	a3068693          	addi	a3,a3,-1488 # ffffffffc0202b58 <etext+0xb5c>
ffffffffc0201130:	00002617          	auipc	a2,0x2
ffffffffc0201134:	84060613          	addi	a2,a2,-1984 # ffffffffc0202970 <etext+0x974>
ffffffffc0201138:	0f800593          	li	a1,248
ffffffffc020113c:	00002517          	auipc	a0,0x2
ffffffffc0201140:	84c50513          	addi	a0,a0,-1972 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201144:	a7aff0ef          	jal	ffffffffc02003be <__panic>
    assert(nr_free == 0);
ffffffffc0201148:	00002697          	auipc	a3,0x2
ffffffffc020114c:	a0068693          	addi	a3,a3,-1536 # ffffffffc0202b48 <etext+0xb4c>
ffffffffc0201150:	00002617          	auipc	a2,0x2
ffffffffc0201154:	82060613          	addi	a2,a2,-2016 # ffffffffc0202970 <etext+0x974>
ffffffffc0201158:	0df00593          	li	a1,223
ffffffffc020115c:	00002517          	auipc	a0,0x2
ffffffffc0201160:	82c50513          	addi	a0,a0,-2004 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201164:	a5aff0ef          	jal	ffffffffc02003be <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201168:	00002697          	auipc	a3,0x2
ffffffffc020116c:	98068693          	addi	a3,a3,-1664 # ffffffffc0202ae8 <etext+0xaec>
ffffffffc0201170:	00002617          	auipc	a2,0x2
ffffffffc0201174:	80060613          	addi	a2,a2,-2048 # ffffffffc0202970 <etext+0x974>
ffffffffc0201178:	0dd00593          	li	a1,221
ffffffffc020117c:	00002517          	auipc	a0,0x2
ffffffffc0201180:	80c50513          	addi	a0,a0,-2036 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201184:	a3aff0ef          	jal	ffffffffc02003be <__panic>
    assert((p = alloc_page()) == p0);
ffffffffc0201188:	00002697          	auipc	a3,0x2
ffffffffc020118c:	9a068693          	addi	a3,a3,-1632 # ffffffffc0202b28 <etext+0xb2c>
ffffffffc0201190:	00001617          	auipc	a2,0x1
ffffffffc0201194:	7e060613          	addi	a2,a2,2016 # ffffffffc0202970 <etext+0x974>
ffffffffc0201198:	0dc00593          	li	a1,220
ffffffffc020119c:	00001517          	auipc	a0,0x1
ffffffffc02011a0:	7ec50513          	addi	a0,a0,2028 # ffffffffc0202988 <etext+0x98c>
ffffffffc02011a4:	a1aff0ef          	jal	ffffffffc02003be <__panic>
    assert((p0 = alloc_page()) != NULL);
ffffffffc02011a8:	00002697          	auipc	a3,0x2
ffffffffc02011ac:	81868693          	addi	a3,a3,-2024 # ffffffffc02029c0 <etext+0x9c4>
ffffffffc02011b0:	00001617          	auipc	a2,0x1
ffffffffc02011b4:	7c060613          	addi	a2,a2,1984 # ffffffffc0202970 <etext+0x974>
ffffffffc02011b8:	0b900593          	li	a1,185
ffffffffc02011bc:	00001517          	auipc	a0,0x1
ffffffffc02011c0:	7cc50513          	addi	a0,a0,1996 # ffffffffc0202988 <etext+0x98c>
ffffffffc02011c4:	9faff0ef          	jal	ffffffffc02003be <__panic>
    assert(alloc_page() == NULL);
ffffffffc02011c8:	00002697          	auipc	a3,0x2
ffffffffc02011cc:	92068693          	addi	a3,a3,-1760 # ffffffffc0202ae8 <etext+0xaec>
ffffffffc02011d0:	00001617          	auipc	a2,0x1
ffffffffc02011d4:	7a060613          	addi	a2,a2,1952 # ffffffffc0202970 <etext+0x974>
ffffffffc02011d8:	0d600593          	li	a1,214
ffffffffc02011dc:	00001517          	auipc	a0,0x1
ffffffffc02011e0:	7ac50513          	addi	a0,a0,1964 # ffffffffc0202988 <etext+0x98c>
ffffffffc02011e4:	9daff0ef          	jal	ffffffffc02003be <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc02011e8:	00002697          	auipc	a3,0x2
ffffffffc02011ec:	81868693          	addi	a3,a3,-2024 # ffffffffc0202a00 <etext+0xa04>
ffffffffc02011f0:	00001617          	auipc	a2,0x1
ffffffffc02011f4:	78060613          	addi	a2,a2,1920 # ffffffffc0202970 <etext+0x974>
ffffffffc02011f8:	0d400593          	li	a1,212
ffffffffc02011fc:	00001517          	auipc	a0,0x1
ffffffffc0201200:	78c50513          	addi	a0,a0,1932 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201204:	9baff0ef          	jal	ffffffffc02003be <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201208:	00001697          	auipc	a3,0x1
ffffffffc020120c:	7d868693          	addi	a3,a3,2008 # ffffffffc02029e0 <etext+0x9e4>
ffffffffc0201210:	00001617          	auipc	a2,0x1
ffffffffc0201214:	76060613          	addi	a2,a2,1888 # ffffffffc0202970 <etext+0x974>
ffffffffc0201218:	0d300593          	li	a1,211
ffffffffc020121c:	00001517          	auipc	a0,0x1
ffffffffc0201220:	76c50513          	addi	a0,a0,1900 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201224:	99aff0ef          	jal	ffffffffc02003be <__panic>
    assert((p2 = alloc_page()) != NULL);
ffffffffc0201228:	00001697          	auipc	a3,0x1
ffffffffc020122c:	7d868693          	addi	a3,a3,2008 # ffffffffc0202a00 <etext+0xa04>
ffffffffc0201230:	00001617          	auipc	a2,0x1
ffffffffc0201234:	74060613          	addi	a2,a2,1856 # ffffffffc0202970 <etext+0x974>
ffffffffc0201238:	0bb00593          	li	a1,187
ffffffffc020123c:	00001517          	auipc	a0,0x1
ffffffffc0201240:	74c50513          	addi	a0,a0,1868 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201244:	97aff0ef          	jal	ffffffffc02003be <__panic>
    assert(count == 0);
ffffffffc0201248:	00002697          	auipc	a3,0x2
ffffffffc020124c:	a6068693          	addi	a3,a3,-1440 # ffffffffc0202ca8 <etext+0xcac>
ffffffffc0201250:	00001617          	auipc	a2,0x1
ffffffffc0201254:	72060613          	addi	a2,a2,1824 # ffffffffc0202970 <etext+0x974>
ffffffffc0201258:	12500593          	li	a1,293
ffffffffc020125c:	00001517          	auipc	a0,0x1
ffffffffc0201260:	72c50513          	addi	a0,a0,1836 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201264:	95aff0ef          	jal	ffffffffc02003be <__panic>
    assert(nr_free == 0);
ffffffffc0201268:	00002697          	auipc	a3,0x2
ffffffffc020126c:	8e068693          	addi	a3,a3,-1824 # ffffffffc0202b48 <etext+0xb4c>
ffffffffc0201270:	00001617          	auipc	a2,0x1
ffffffffc0201274:	70060613          	addi	a2,a2,1792 # ffffffffc0202970 <etext+0x974>
ffffffffc0201278:	11a00593          	li	a1,282
ffffffffc020127c:	00001517          	auipc	a0,0x1
ffffffffc0201280:	70c50513          	addi	a0,a0,1804 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201284:	93aff0ef          	jal	ffffffffc02003be <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201288:	00002697          	auipc	a3,0x2
ffffffffc020128c:	86068693          	addi	a3,a3,-1952 # ffffffffc0202ae8 <etext+0xaec>
ffffffffc0201290:	00001617          	auipc	a2,0x1
ffffffffc0201294:	6e060613          	addi	a2,a2,1760 # ffffffffc0202970 <etext+0x974>
ffffffffc0201298:	11800593          	li	a1,280
ffffffffc020129c:	00001517          	auipc	a0,0x1
ffffffffc02012a0:	6ec50513          	addi	a0,a0,1772 # ffffffffc0202988 <etext+0x98c>
ffffffffc02012a4:	91aff0ef          	jal	ffffffffc02003be <__panic>
    assert(page2pa(p1) < npage * PGSIZE);
ffffffffc02012a8:	00002697          	auipc	a3,0x2
ffffffffc02012ac:	80068693          	addi	a3,a3,-2048 # ffffffffc0202aa8 <etext+0xaac>
ffffffffc02012b0:	00001617          	auipc	a2,0x1
ffffffffc02012b4:	6c060613          	addi	a2,a2,1728 # ffffffffc0202970 <etext+0x974>
ffffffffc02012b8:	0c100593          	li	a1,193
ffffffffc02012bc:	00001517          	auipc	a0,0x1
ffffffffc02012c0:	6cc50513          	addi	a0,a0,1740 # ffffffffc0202988 <etext+0x98c>
ffffffffc02012c4:	8faff0ef          	jal	ffffffffc02003be <__panic>
    assert((p0 = alloc_pages(2)) == p2 + 1);
ffffffffc02012c8:	00002697          	auipc	a3,0x2
ffffffffc02012cc:	9a068693          	addi	a3,a3,-1632 # ffffffffc0202c68 <etext+0xc6c>
ffffffffc02012d0:	00001617          	auipc	a2,0x1
ffffffffc02012d4:	6a060613          	addi	a2,a2,1696 # ffffffffc0202970 <etext+0x974>
ffffffffc02012d8:	11200593          	li	a1,274
ffffffffc02012dc:	00001517          	auipc	a0,0x1
ffffffffc02012e0:	6ac50513          	addi	a0,a0,1708 # ffffffffc0202988 <etext+0x98c>
ffffffffc02012e4:	8daff0ef          	jal	ffffffffc02003be <__panic>
    assert((p0 = alloc_page()) == p2 - 1);
ffffffffc02012e8:	00002697          	auipc	a3,0x2
ffffffffc02012ec:	96068693          	addi	a3,a3,-1696 # ffffffffc0202c48 <etext+0xc4c>
ffffffffc02012f0:	00001617          	auipc	a2,0x1
ffffffffc02012f4:	68060613          	addi	a2,a2,1664 # ffffffffc0202970 <etext+0x974>
ffffffffc02012f8:	11000593          	li	a1,272
ffffffffc02012fc:	00001517          	auipc	a0,0x1
ffffffffc0201300:	68c50513          	addi	a0,a0,1676 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201304:	8baff0ef          	jal	ffffffffc02003be <__panic>
    assert(PageProperty(p1) && p1->property == 3);
ffffffffc0201308:	00002697          	auipc	a3,0x2
ffffffffc020130c:	91868693          	addi	a3,a3,-1768 # ffffffffc0202c20 <etext+0xc24>
ffffffffc0201310:	00001617          	auipc	a2,0x1
ffffffffc0201314:	66060613          	addi	a2,a2,1632 # ffffffffc0202970 <etext+0x974>
ffffffffc0201318:	10e00593          	li	a1,270
ffffffffc020131c:	00001517          	auipc	a0,0x1
ffffffffc0201320:	66c50513          	addi	a0,a0,1644 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201324:	89aff0ef          	jal	ffffffffc02003be <__panic>
    assert(PageProperty(p0) && p0->property == 1);
ffffffffc0201328:	00002697          	auipc	a3,0x2
ffffffffc020132c:	8d068693          	addi	a3,a3,-1840 # ffffffffc0202bf8 <etext+0xbfc>
ffffffffc0201330:	00001617          	auipc	a2,0x1
ffffffffc0201334:	64060613          	addi	a2,a2,1600 # ffffffffc0202970 <etext+0x974>
ffffffffc0201338:	10d00593          	li	a1,269
ffffffffc020133c:	00001517          	auipc	a0,0x1
ffffffffc0201340:	64c50513          	addi	a0,a0,1612 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201344:	87aff0ef          	jal	ffffffffc02003be <__panic>
    assert(p0 + 2 == p1);
ffffffffc0201348:	00002697          	auipc	a3,0x2
ffffffffc020134c:	8a068693          	addi	a3,a3,-1888 # ffffffffc0202be8 <etext+0xbec>
ffffffffc0201350:	00001617          	auipc	a2,0x1
ffffffffc0201354:	62060613          	addi	a2,a2,1568 # ffffffffc0202970 <etext+0x974>
ffffffffc0201358:	10800593          	li	a1,264
ffffffffc020135c:	00001517          	auipc	a0,0x1
ffffffffc0201360:	62c50513          	addi	a0,a0,1580 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201364:	85aff0ef          	jal	ffffffffc02003be <__panic>
    assert(alloc_page() == NULL);
ffffffffc0201368:	00001697          	auipc	a3,0x1
ffffffffc020136c:	78068693          	addi	a3,a3,1920 # ffffffffc0202ae8 <etext+0xaec>
ffffffffc0201370:	00001617          	auipc	a2,0x1
ffffffffc0201374:	60060613          	addi	a2,a2,1536 # ffffffffc0202970 <etext+0x974>
ffffffffc0201378:	10700593          	li	a1,263
ffffffffc020137c:	00001517          	auipc	a0,0x1
ffffffffc0201380:	60c50513          	addi	a0,a0,1548 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201384:	83aff0ef          	jal	ffffffffc02003be <__panic>
    assert((p1 = alloc_pages(3)) != NULL);
ffffffffc0201388:	00002697          	auipc	a3,0x2
ffffffffc020138c:	84068693          	addi	a3,a3,-1984 # ffffffffc0202bc8 <etext+0xbcc>
ffffffffc0201390:	00001617          	auipc	a2,0x1
ffffffffc0201394:	5e060613          	addi	a2,a2,1504 # ffffffffc0202970 <etext+0x974>
ffffffffc0201398:	10600593          	li	a1,262
ffffffffc020139c:	00001517          	auipc	a0,0x1
ffffffffc02013a0:	5ec50513          	addi	a0,a0,1516 # ffffffffc0202988 <etext+0x98c>
ffffffffc02013a4:	81aff0ef          	jal	ffffffffc02003be <__panic>
    assert(PageProperty(p0 + 2) && p0[2].property == 3);
ffffffffc02013a8:	00001697          	auipc	a3,0x1
ffffffffc02013ac:	7f068693          	addi	a3,a3,2032 # ffffffffc0202b98 <etext+0xb9c>
ffffffffc02013b0:	00001617          	auipc	a2,0x1
ffffffffc02013b4:	5c060613          	addi	a2,a2,1472 # ffffffffc0202970 <etext+0x974>
ffffffffc02013b8:	10500593          	li	a1,261
ffffffffc02013bc:	00001517          	auipc	a0,0x1
ffffffffc02013c0:	5cc50513          	addi	a0,a0,1484 # ffffffffc0202988 <etext+0x98c>
ffffffffc02013c4:	ffbfe0ef          	jal	ffffffffc02003be <__panic>
    assert(alloc_pages(4) == NULL);
ffffffffc02013c8:	00001697          	auipc	a3,0x1
ffffffffc02013cc:	7b868693          	addi	a3,a3,1976 # ffffffffc0202b80 <etext+0xb84>
ffffffffc02013d0:	00001617          	auipc	a2,0x1
ffffffffc02013d4:	5a060613          	addi	a2,a2,1440 # ffffffffc0202970 <etext+0x974>
ffffffffc02013d8:	10400593          	li	a1,260
ffffffffc02013dc:	00001517          	auipc	a0,0x1
ffffffffc02013e0:	5ac50513          	addi	a0,a0,1452 # ffffffffc0202988 <etext+0x98c>
ffffffffc02013e4:	fdbfe0ef          	jal	ffffffffc02003be <__panic>
    assert(alloc_page() == NULL);
ffffffffc02013e8:	00001697          	auipc	a3,0x1
ffffffffc02013ec:	70068693          	addi	a3,a3,1792 # ffffffffc0202ae8 <etext+0xaec>
ffffffffc02013f0:	00001617          	auipc	a2,0x1
ffffffffc02013f4:	58060613          	addi	a2,a2,1408 # ffffffffc0202970 <etext+0x974>
ffffffffc02013f8:	0fe00593          	li	a1,254
ffffffffc02013fc:	00001517          	auipc	a0,0x1
ffffffffc0201400:	58c50513          	addi	a0,a0,1420 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201404:	fbbfe0ef          	jal	ffffffffc02003be <__panic>
    assert(!PageProperty(p0));
ffffffffc0201408:	00001697          	auipc	a3,0x1
ffffffffc020140c:	76068693          	addi	a3,a3,1888 # ffffffffc0202b68 <etext+0xb6c>
ffffffffc0201410:	00001617          	auipc	a2,0x1
ffffffffc0201414:	56060613          	addi	a2,a2,1376 # ffffffffc0202970 <etext+0x974>
ffffffffc0201418:	0f900593          	li	a1,249
ffffffffc020141c:	00001517          	auipc	a0,0x1
ffffffffc0201420:	56c50513          	addi	a0,a0,1388 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201424:	f9bfe0ef          	jal	ffffffffc02003be <__panic>
    assert((p0 = alloc_pages(5)) != NULL);
ffffffffc0201428:	00002697          	auipc	a3,0x2
ffffffffc020142c:	86068693          	addi	a3,a3,-1952 # ffffffffc0202c88 <etext+0xc8c>
ffffffffc0201430:	00001617          	auipc	a2,0x1
ffffffffc0201434:	54060613          	addi	a2,a2,1344 # ffffffffc0202970 <etext+0x974>
ffffffffc0201438:	11700593          	li	a1,279
ffffffffc020143c:	00001517          	auipc	a0,0x1
ffffffffc0201440:	54c50513          	addi	a0,a0,1356 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201444:	f7bfe0ef          	jal	ffffffffc02003be <__panic>
    assert(total == 0);
ffffffffc0201448:	00002697          	auipc	a3,0x2
ffffffffc020144c:	87068693          	addi	a3,a3,-1936 # ffffffffc0202cb8 <etext+0xcbc>
ffffffffc0201450:	00001617          	auipc	a2,0x1
ffffffffc0201454:	52060613          	addi	a2,a2,1312 # ffffffffc0202970 <etext+0x974>
ffffffffc0201458:	12600593          	li	a1,294
ffffffffc020145c:	00001517          	auipc	a0,0x1
ffffffffc0201460:	52c50513          	addi	a0,a0,1324 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201464:	f5bfe0ef          	jal	ffffffffc02003be <__panic>
    assert(total == nr_free_pages());
ffffffffc0201468:	00001697          	auipc	a3,0x1
ffffffffc020146c:	53868693          	addi	a3,a3,1336 # ffffffffc02029a0 <etext+0x9a4>
ffffffffc0201470:	00001617          	auipc	a2,0x1
ffffffffc0201474:	50060613          	addi	a2,a2,1280 # ffffffffc0202970 <etext+0x974>
ffffffffc0201478:	0f300593          	li	a1,243
ffffffffc020147c:	00001517          	auipc	a0,0x1
ffffffffc0201480:	50c50513          	addi	a0,a0,1292 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201484:	f3bfe0ef          	jal	ffffffffc02003be <__panic>
    assert((p1 = alloc_page()) != NULL);
ffffffffc0201488:	00001697          	auipc	a3,0x1
ffffffffc020148c:	55868693          	addi	a3,a3,1368 # ffffffffc02029e0 <etext+0x9e4>
ffffffffc0201490:	00001617          	auipc	a2,0x1
ffffffffc0201494:	4e060613          	addi	a2,a2,1248 # ffffffffc0202970 <etext+0x974>
ffffffffc0201498:	0ba00593          	li	a1,186
ffffffffc020149c:	00001517          	auipc	a0,0x1
ffffffffc02014a0:	4ec50513          	addi	a0,a0,1260 # ffffffffc0202988 <etext+0x98c>
ffffffffc02014a4:	f1bfe0ef          	jal	ffffffffc02003be <__panic>

ffffffffc02014a8 <default_free_pages>:
default_free_pages(struct Page *base, size_t n) {
ffffffffc02014a8:	1141                	addi	sp,sp,-16
ffffffffc02014aa:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02014ac:	14058c63          	beqz	a1,ffffffffc0201604 <default_free_pages+0x15c>
    for (; p != base + n; p ++) {
ffffffffc02014b0:	00259713          	slli	a4,a1,0x2
ffffffffc02014b4:	972e                	add	a4,a4,a1
ffffffffc02014b6:	070e                	slli	a4,a4,0x3
ffffffffc02014b8:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc02014bc:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc02014be:	c30d                	beqz	a4,ffffffffc02014e0 <default_free_pages+0x38>
ffffffffc02014c0:	6798                	ld	a4,8(a5)
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02014c2:	8b05                	andi	a4,a4,1
ffffffffc02014c4:	12071063          	bnez	a4,ffffffffc02015e4 <default_free_pages+0x13c>
ffffffffc02014c8:	6798                	ld	a4,8(a5)
ffffffffc02014ca:	8b09                	andi	a4,a4,2
ffffffffc02014cc:	10071c63          	bnez	a4,ffffffffc02015e4 <default_free_pages+0x13c>
        p->flags = 0;
ffffffffc02014d0:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc02014d4:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc02014d8:	02878793          	addi	a5,a5,40
ffffffffc02014dc:	fed792e3          	bne	a5,a3,ffffffffc02014c0 <default_free_pages+0x18>
    base->property = n;
ffffffffc02014e0:	c90c                	sw	a1,16(a0)
    SetPageProperty(base);
ffffffffc02014e2:	00850893          	addi	a7,a0,8
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc02014e6:	4789                	li	a5,2
ffffffffc02014e8:	40f8b02f          	amoor.d	zero,a5,(a7)
    nr_free += n;
ffffffffc02014ec:	00006717          	auipc	a4,0x6
ffffffffc02014f0:	b4c72703          	lw	a4,-1204(a4) # ffffffffc0207038 <free_area+0x10>
ffffffffc02014f4:	00006697          	auipc	a3,0x6
ffffffffc02014f8:	b3468693          	addi	a3,a3,-1228 # ffffffffc0207028 <free_area>
    return list->next == list;
ffffffffc02014fc:	669c                	ld	a5,8(a3)
ffffffffc02014fe:	9f2d                	addw	a4,a4,a1
ffffffffc0201500:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201502:	0ad78563          	beq	a5,a3,ffffffffc02015ac <default_free_pages+0x104>
            struct Page* page = le2page(le, page_link);
ffffffffc0201506:	fe878713          	addi	a4,a5,-24
ffffffffc020150a:	4581                	li	a1,0
ffffffffc020150c:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201510:	00e56a63          	bltu	a0,a4,ffffffffc0201524 <default_free_pages+0x7c>
    return listelm->next;
ffffffffc0201514:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201516:	06d70263          	beq	a4,a3,ffffffffc020157a <default_free_pages+0xd2>
    struct Page *p = base;
ffffffffc020151a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020151c:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201520:	fee57ae3          	bgeu	a0,a4,ffffffffc0201514 <default_free_pages+0x6c>
ffffffffc0201524:	c199                	beqz	a1,ffffffffc020152a <default_free_pages+0x82>
ffffffffc0201526:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020152a:	6398                	ld	a4,0(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc020152c:	e390                	sd	a2,0(a5)
ffffffffc020152e:	e710                	sd	a2,8(a4)
    elm->next = next;
    elm->prev = prev;
ffffffffc0201530:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc0201532:	f11c                	sd	a5,32(a0)
    if (le != &free_list) {
ffffffffc0201534:	02d70063          	beq	a4,a3,ffffffffc0201554 <default_free_pages+0xac>
        if (p + p->property == base) {
ffffffffc0201538:	ff872803          	lw	a6,-8(a4)
        p = le2page(le, page_link);
ffffffffc020153c:	fe870593          	addi	a1,a4,-24
        if (p + p->property == base) {
ffffffffc0201540:	02081613          	slli	a2,a6,0x20
ffffffffc0201544:	9201                	srli	a2,a2,0x20
ffffffffc0201546:	00261793          	slli	a5,a2,0x2
ffffffffc020154a:	97b2                	add	a5,a5,a2
ffffffffc020154c:	078e                	slli	a5,a5,0x3
ffffffffc020154e:	97ae                	add	a5,a5,a1
ffffffffc0201550:	02f50f63          	beq	a0,a5,ffffffffc020158e <default_free_pages+0xe6>
    return listelm->next;
ffffffffc0201554:	7118                	ld	a4,32(a0)
    if (le != &free_list) {
ffffffffc0201556:	00d70f63          	beq	a4,a3,ffffffffc0201574 <default_free_pages+0xcc>
        if (base + base->property == p) {
ffffffffc020155a:	490c                	lw	a1,16(a0)
        p = le2page(le, page_link);
ffffffffc020155c:	fe870693          	addi	a3,a4,-24
        if (base + base->property == p) {
ffffffffc0201560:	02059613          	slli	a2,a1,0x20
ffffffffc0201564:	9201                	srli	a2,a2,0x20
ffffffffc0201566:	00261793          	slli	a5,a2,0x2
ffffffffc020156a:	97b2                	add	a5,a5,a2
ffffffffc020156c:	078e                	slli	a5,a5,0x3
ffffffffc020156e:	97aa                	add	a5,a5,a0
ffffffffc0201570:	04f68a63          	beq	a3,a5,ffffffffc02015c4 <default_free_pages+0x11c>
}
ffffffffc0201574:	60a2                	ld	ra,8(sp)
ffffffffc0201576:	0141                	addi	sp,sp,16
ffffffffc0201578:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020157a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020157c:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020157e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201580:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201582:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201584:	02d70d63          	beq	a4,a3,ffffffffc02015be <default_free_pages+0x116>
ffffffffc0201588:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc020158a:	87ba                	mv	a5,a4
ffffffffc020158c:	bf41                	j	ffffffffc020151c <default_free_pages+0x74>
            p->property += base->property;
ffffffffc020158e:	491c                	lw	a5,16(a0)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc0201590:	5675                	li	a2,-3
ffffffffc0201592:	010787bb          	addw	a5,a5,a6
ffffffffc0201596:	fef72c23          	sw	a5,-8(a4)
ffffffffc020159a:	60c8b02f          	amoand.d	zero,a2,(a7)
    __list_del(listelm->prev, listelm->next);
ffffffffc020159e:	6d10                	ld	a2,24(a0)
ffffffffc02015a0:	711c                	ld	a5,32(a0)
            base = p;
ffffffffc02015a2:	852e                	mv	a0,a1
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02015a4:	e61c                	sd	a5,8(a2)
    return listelm->next;
ffffffffc02015a6:	6718                	ld	a4,8(a4)
    next->prev = prev;
ffffffffc02015a8:	e390                	sd	a2,0(a5)
ffffffffc02015aa:	b775                	j	ffffffffc0201556 <default_free_pages+0xae>
}
ffffffffc02015ac:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc02015ae:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc02015b2:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc02015b4:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc02015b6:	e398                	sd	a4,0(a5)
ffffffffc02015b8:	e798                	sd	a4,8(a5)
}
ffffffffc02015ba:	0141                	addi	sp,sp,16
ffffffffc02015bc:	8082                	ret
ffffffffc02015be:	e290                	sd	a2,0(a3)
    return listelm->prev;
ffffffffc02015c0:	873e                	mv	a4,a5
ffffffffc02015c2:	bf8d                	j	ffffffffc0201534 <default_free_pages+0x8c>
            base->property += p->property;
ffffffffc02015c4:	ff872783          	lw	a5,-8(a4)
ffffffffc02015c8:	56f5                	li	a3,-3
ffffffffc02015ca:	9fad                	addw	a5,a5,a1
ffffffffc02015cc:	c91c                	sw	a5,16(a0)
ffffffffc02015ce:	ff070793          	addi	a5,a4,-16
ffffffffc02015d2:	60d7b02f          	amoand.d	zero,a3,(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc02015d6:	6314                	ld	a3,0(a4)
ffffffffc02015d8:	671c                	ld	a5,8(a4)
}
ffffffffc02015da:	60a2                	ld	ra,8(sp)
    prev->next = next;
ffffffffc02015dc:	e69c                	sd	a5,8(a3)
    next->prev = prev;
ffffffffc02015de:	e394                	sd	a3,0(a5)
ffffffffc02015e0:	0141                	addi	sp,sp,16
ffffffffc02015e2:	8082                	ret
        assert(!PageReserved(p) && !PageProperty(p));
ffffffffc02015e4:	00001697          	auipc	a3,0x1
ffffffffc02015e8:	6ec68693          	addi	a3,a3,1772 # ffffffffc0202cd0 <etext+0xcd4>
ffffffffc02015ec:	00001617          	auipc	a2,0x1
ffffffffc02015f0:	38460613          	addi	a2,a2,900 # ffffffffc0202970 <etext+0x974>
ffffffffc02015f4:	08300593          	li	a1,131
ffffffffc02015f8:	00001517          	auipc	a0,0x1
ffffffffc02015fc:	39050513          	addi	a0,a0,912 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201600:	dbffe0ef          	jal	ffffffffc02003be <__panic>
    assert(n > 0);
ffffffffc0201604:	00001697          	auipc	a3,0x1
ffffffffc0201608:	6c468693          	addi	a3,a3,1732 # ffffffffc0202cc8 <etext+0xccc>
ffffffffc020160c:	00001617          	auipc	a2,0x1
ffffffffc0201610:	36460613          	addi	a2,a2,868 # ffffffffc0202970 <etext+0x974>
ffffffffc0201614:	08000593          	li	a1,128
ffffffffc0201618:	00001517          	auipc	a0,0x1
ffffffffc020161c:	37050513          	addi	a0,a0,880 # ffffffffc0202988 <etext+0x98c>
ffffffffc0201620:	d9ffe0ef          	jal	ffffffffc02003be <__panic>

ffffffffc0201624 <default_alloc_pages>:
    assert(n > 0);
ffffffffc0201624:	cd41                	beqz	a0,ffffffffc02016bc <default_alloc_pages+0x98>
    if (n > nr_free) {
ffffffffc0201626:	00006597          	auipc	a1,0x6
ffffffffc020162a:	a125a583          	lw	a1,-1518(a1) # ffffffffc0207038 <free_area+0x10>
ffffffffc020162e:	86aa                	mv	a3,a0
ffffffffc0201630:	02059793          	slli	a5,a1,0x20
ffffffffc0201634:	9381                	srli	a5,a5,0x20
ffffffffc0201636:	00a7ef63          	bltu	a5,a0,ffffffffc0201654 <default_alloc_pages+0x30>
    list_entry_t *le = &free_list;
ffffffffc020163a:	00006617          	auipc	a2,0x6
ffffffffc020163e:	9ee60613          	addi	a2,a2,-1554 # ffffffffc0207028 <free_area>
ffffffffc0201642:	87b2                	mv	a5,a2
ffffffffc0201644:	a029                	j	ffffffffc020164e <default_alloc_pages+0x2a>
        if (p->property >= n) {
ffffffffc0201646:	ff87e703          	lwu	a4,-8(a5)
ffffffffc020164a:	00d77763          	bgeu	a4,a3,ffffffffc0201658 <default_alloc_pages+0x34>
    return listelm->next;
ffffffffc020164e:	679c                	ld	a5,8(a5)
    while ((le = list_next(le)) != &free_list) {
ffffffffc0201650:	fec79be3          	bne	a5,a2,ffffffffc0201646 <default_alloc_pages+0x22>
        return NULL;
ffffffffc0201654:	4501                	li	a0,0
}
ffffffffc0201656:	8082                	ret
        if (page->property > n) {
ffffffffc0201658:	ff87a883          	lw	a7,-8(a5)
    return listelm->prev;
ffffffffc020165c:	0007b803          	ld	a6,0(a5)
    __list_del(listelm->prev, listelm->next);
ffffffffc0201660:	6798                	ld	a4,8(a5)
ffffffffc0201662:	02089313          	slli	t1,a7,0x20
ffffffffc0201666:	02035313          	srli	t1,t1,0x20
    prev->next = next;
ffffffffc020166a:	00e83423          	sd	a4,8(a6) # ff0008 <kern_entry-0xffffffffbf20fff8>
    next->prev = prev;
ffffffffc020166e:	01073023          	sd	a6,0(a4)
        struct Page *p = le2page(le, page_link);
ffffffffc0201672:	fe878513          	addi	a0,a5,-24
        if (page->property > n) {
ffffffffc0201676:	0266fc63          	bgeu	a3,t1,ffffffffc02016ae <default_alloc_pages+0x8a>
            struct Page *p = page + n;
ffffffffc020167a:	00269713          	slli	a4,a3,0x2
ffffffffc020167e:	9736                	add	a4,a4,a3
ffffffffc0201680:	070e                	slli	a4,a4,0x3
            p->property = page->property - n;
ffffffffc0201682:	40d888bb          	subw	a7,a7,a3
            struct Page *p = page + n;
ffffffffc0201686:	972a                	add	a4,a4,a0
            p->property = page->property - n;
ffffffffc0201688:	01172823          	sw	a7,16(a4)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc020168c:	00870313          	addi	t1,a4,8
ffffffffc0201690:	4889                	li	a7,2
ffffffffc0201692:	4113302f          	amoor.d	zero,a7,(t1)
    __list_add(elm, listelm, listelm->next);
ffffffffc0201696:	00883883          	ld	a7,8(a6)
            list_add(prev, &(p->page_link));
ffffffffc020169a:	01870313          	addi	t1,a4,24
    prev->next = next->prev = elm;
ffffffffc020169e:	0068b023          	sd	t1,0(a7)
ffffffffc02016a2:	00683423          	sd	t1,8(a6)
    elm->next = next;
ffffffffc02016a6:	03173023          	sd	a7,32(a4)
    elm->prev = prev;
ffffffffc02016aa:	01073c23          	sd	a6,24(a4)
        nr_free -= n;
ffffffffc02016ae:	9d95                	subw	a1,a1,a3
ffffffffc02016b0:	ca0c                	sw	a1,16(a2)
    __op_bit(and, __NOT, nr, ((volatile unsigned long *)addr));
ffffffffc02016b2:	5775                	li	a4,-3
ffffffffc02016b4:	17c1                	addi	a5,a5,-16
ffffffffc02016b6:	60e7b02f          	amoand.d	zero,a4,(a5)
}
ffffffffc02016ba:	8082                	ret
default_alloc_pages(size_t n) {
ffffffffc02016bc:	1141                	addi	sp,sp,-16
    assert(n > 0);
ffffffffc02016be:	00001697          	auipc	a3,0x1
ffffffffc02016c2:	60a68693          	addi	a3,a3,1546 # ffffffffc0202cc8 <etext+0xccc>
ffffffffc02016c6:	00001617          	auipc	a2,0x1
ffffffffc02016ca:	2aa60613          	addi	a2,a2,682 # ffffffffc0202970 <etext+0x974>
ffffffffc02016ce:	06200593          	li	a1,98
ffffffffc02016d2:	00001517          	auipc	a0,0x1
ffffffffc02016d6:	2b650513          	addi	a0,a0,694 # ffffffffc0202988 <etext+0x98c>
default_alloc_pages(size_t n) {
ffffffffc02016da:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02016dc:	ce3fe0ef          	jal	ffffffffc02003be <__panic>

ffffffffc02016e0 <default_init_memmap>:
default_init_memmap(struct Page *base, size_t n) {
ffffffffc02016e0:	1141                	addi	sp,sp,-16
ffffffffc02016e2:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc02016e4:	c9f1                	beqz	a1,ffffffffc02017b8 <default_init_memmap+0xd8>
    for (; p != base + n; p ++) {
ffffffffc02016e6:	00259713          	slli	a4,a1,0x2
ffffffffc02016ea:	972e                	add	a4,a4,a1
ffffffffc02016ec:	070e                	slli	a4,a4,0x3
ffffffffc02016ee:	00e506b3          	add	a3,a0,a4
    struct Page *p = base;
ffffffffc02016f2:	87aa                	mv	a5,a0
    for (; p != base + n; p ++) {
ffffffffc02016f4:	cf11                	beqz	a4,ffffffffc0201710 <default_init_memmap+0x30>
    return (((*(volatile unsigned long *)addr) >> nr) & 1);
ffffffffc02016f6:	6798                	ld	a4,8(a5)
        assert(PageReserved(p));
ffffffffc02016f8:	8b05                	andi	a4,a4,1
ffffffffc02016fa:	cf59                	beqz	a4,ffffffffc0201798 <default_init_memmap+0xb8>
        p->flags = p->property = 0;
ffffffffc02016fc:	0007a823          	sw	zero,16(a5)
ffffffffc0201700:	0007b423          	sd	zero,8(a5)
ffffffffc0201704:	0007a023          	sw	zero,0(a5)
    for (; p != base + n; p ++) {
ffffffffc0201708:	02878793          	addi	a5,a5,40
ffffffffc020170c:	fed795e3          	bne	a5,a3,ffffffffc02016f6 <default_init_memmap+0x16>
    base->property = n;
ffffffffc0201710:	c90c                	sw	a1,16(a0)
    __op_bit(or, __NOP, nr, ((volatile unsigned long *)addr));
ffffffffc0201712:	4789                	li	a5,2
ffffffffc0201714:	00850713          	addi	a4,a0,8
ffffffffc0201718:	40f7302f          	amoor.d	zero,a5,(a4)
    nr_free += n;
ffffffffc020171c:	00006717          	auipc	a4,0x6
ffffffffc0201720:	91c72703          	lw	a4,-1764(a4) # ffffffffc0207038 <free_area+0x10>
ffffffffc0201724:	00006697          	auipc	a3,0x6
ffffffffc0201728:	90468693          	addi	a3,a3,-1788 # ffffffffc0207028 <free_area>
    return list->next == list;
ffffffffc020172c:	669c                	ld	a5,8(a3)
ffffffffc020172e:	9f2d                	addw	a4,a4,a1
ffffffffc0201730:	ca98                	sw	a4,16(a3)
    if (list_empty(&free_list)) {
ffffffffc0201732:	04d78663          	beq	a5,a3,ffffffffc020177e <default_init_memmap+0x9e>
            struct Page* page = le2page(le, page_link);
ffffffffc0201736:	fe878713          	addi	a4,a5,-24
ffffffffc020173a:	4581                	li	a1,0
ffffffffc020173c:	01850613          	addi	a2,a0,24
            if (base < page) {
ffffffffc0201740:	00e56a63          	bltu	a0,a4,ffffffffc0201754 <default_init_memmap+0x74>
    return listelm->next;
ffffffffc0201744:	6798                	ld	a4,8(a5)
            } else if (list_next(le) == &free_list) {
ffffffffc0201746:	02d70263          	beq	a4,a3,ffffffffc020176a <default_init_memmap+0x8a>
    struct Page *p = base;
ffffffffc020174a:	87ba                	mv	a5,a4
            struct Page* page = le2page(le, page_link);
ffffffffc020174c:	fe878713          	addi	a4,a5,-24
            if (base < page) {
ffffffffc0201750:	fee57ae3          	bgeu	a0,a4,ffffffffc0201744 <default_init_memmap+0x64>
ffffffffc0201754:	c199                	beqz	a1,ffffffffc020175a <default_init_memmap+0x7a>
ffffffffc0201756:	0106b023          	sd	a6,0(a3)
    __list_add(elm, listelm->prev, listelm);
ffffffffc020175a:	6398                	ld	a4,0(a5)
}
ffffffffc020175c:	60a2                	ld	ra,8(sp)
    prev->next = next->prev = elm;
ffffffffc020175e:	e390                	sd	a2,0(a5)
ffffffffc0201760:	e710                	sd	a2,8(a4)
    elm->prev = prev;
ffffffffc0201762:	ed18                	sd	a4,24(a0)
    elm->next = next;
ffffffffc0201764:	f11c                	sd	a5,32(a0)
ffffffffc0201766:	0141                	addi	sp,sp,16
ffffffffc0201768:	8082                	ret
    prev->next = next->prev = elm;
ffffffffc020176a:	e790                	sd	a2,8(a5)
    elm->next = next;
ffffffffc020176c:	f114                	sd	a3,32(a0)
    return listelm->next;
ffffffffc020176e:	6798                	ld	a4,8(a5)
    elm->prev = prev;
ffffffffc0201770:	ed1c                	sd	a5,24(a0)
                list_add(le, &(base->page_link));
ffffffffc0201772:	8832                	mv	a6,a2
        while ((le = list_next(le)) != &free_list) {
ffffffffc0201774:	00d70e63          	beq	a4,a3,ffffffffc0201790 <default_init_memmap+0xb0>
ffffffffc0201778:	4585                	li	a1,1
    struct Page *p = base;
ffffffffc020177a:	87ba                	mv	a5,a4
ffffffffc020177c:	bfc1                	j	ffffffffc020174c <default_init_memmap+0x6c>
}
ffffffffc020177e:	60a2                	ld	ra,8(sp)
        list_add(&free_list, &(base->page_link));
ffffffffc0201780:	01850713          	addi	a4,a0,24
    elm->next = next;
ffffffffc0201784:	f11c                	sd	a5,32(a0)
    elm->prev = prev;
ffffffffc0201786:	ed1c                	sd	a5,24(a0)
    prev->next = next->prev = elm;
ffffffffc0201788:	e398                	sd	a4,0(a5)
ffffffffc020178a:	e798                	sd	a4,8(a5)
}
ffffffffc020178c:	0141                	addi	sp,sp,16
ffffffffc020178e:	8082                	ret
ffffffffc0201790:	60a2                	ld	ra,8(sp)
ffffffffc0201792:	e290                	sd	a2,0(a3)
ffffffffc0201794:	0141                	addi	sp,sp,16
ffffffffc0201796:	8082                	ret
        assert(PageReserved(p));
ffffffffc0201798:	00001697          	auipc	a3,0x1
ffffffffc020179c:	56068693          	addi	a3,a3,1376 # ffffffffc0202cf8 <etext+0xcfc>
ffffffffc02017a0:	00001617          	auipc	a2,0x1
ffffffffc02017a4:	1d060613          	addi	a2,a2,464 # ffffffffc0202970 <etext+0x974>
ffffffffc02017a8:	04900593          	li	a1,73
ffffffffc02017ac:	00001517          	auipc	a0,0x1
ffffffffc02017b0:	1dc50513          	addi	a0,a0,476 # ffffffffc0202988 <etext+0x98c>
ffffffffc02017b4:	c0bfe0ef          	jal	ffffffffc02003be <__panic>
    assert(n > 0);
ffffffffc02017b8:	00001697          	auipc	a3,0x1
ffffffffc02017bc:	51068693          	addi	a3,a3,1296 # ffffffffc0202cc8 <etext+0xccc>
ffffffffc02017c0:	00001617          	auipc	a2,0x1
ffffffffc02017c4:	1b060613          	addi	a2,a2,432 # ffffffffc0202970 <etext+0x974>
ffffffffc02017c8:	04600593          	li	a1,70
ffffffffc02017cc:	00001517          	auipc	a0,0x1
ffffffffc02017d0:	1bc50513          	addi	a0,a0,444 # ffffffffc0202988 <etext+0x98c>
ffffffffc02017d4:	bebfe0ef          	jal	ffffffffc02003be <__panic>

ffffffffc02017d8 <alloc_pages>:
#include <defs.h>
#include <intr.h>
#include <riscv.h>

static inline bool __intr_save(void) {
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc02017d8:	100027f3          	csrr	a5,sstatus
ffffffffc02017dc:	8b89                	andi	a5,a5,2
ffffffffc02017de:	e799                	bnez	a5,ffffffffc02017ec <alloc_pages+0x14>
struct Page *alloc_pages(size_t n) {
    struct Page *page = NULL;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        page = pmm_manager->alloc_pages(n);
ffffffffc02017e0:	00006797          	auipc	a5,0x6
ffffffffc02017e4:	c807b783          	ld	a5,-896(a5) # ffffffffc0207460 <pmm_manager>
ffffffffc02017e8:	6f9c                	ld	a5,24(a5)
ffffffffc02017ea:	8782                	jr	a5
struct Page *alloc_pages(size_t n) {
ffffffffc02017ec:	1101                	addi	sp,sp,-32
ffffffffc02017ee:	ec06                	sd	ra,24(sp)
ffffffffc02017f0:	e42a                	sd	a0,8(sp)
        intr_disable();
ffffffffc02017f2:	fc7fe0ef          	jal	ffffffffc02007b8 <intr_disable>
        page = pmm_manager->alloc_pages(n);
ffffffffc02017f6:	00006797          	auipc	a5,0x6
ffffffffc02017fa:	c6a7b783          	ld	a5,-918(a5) # ffffffffc0207460 <pmm_manager>
ffffffffc02017fe:	6522                	ld	a0,8(sp)
ffffffffc0201800:	6f9c                	ld	a5,24(a5)
ffffffffc0201802:	9782                	jalr	a5
ffffffffc0201804:	e42a                	sd	a0,8(sp)
    return 0;
}

static inline void __intr_restore(bool flag) {
    if (flag) {
        intr_enable();
ffffffffc0201806:	fadfe0ef          	jal	ffffffffc02007b2 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return page;
}
ffffffffc020180a:	60e2                	ld	ra,24(sp)
ffffffffc020180c:	6522                	ld	a0,8(sp)
ffffffffc020180e:	6105                	addi	sp,sp,32
ffffffffc0201810:	8082                	ret

ffffffffc0201812 <free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc0201812:	100027f3          	csrr	a5,sstatus
ffffffffc0201816:	8b89                	andi	a5,a5,2
ffffffffc0201818:	e799                	bnez	a5,ffffffffc0201826 <free_pages+0x14>
// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        pmm_manager->free_pages(base, n);
ffffffffc020181a:	00006797          	auipc	a5,0x6
ffffffffc020181e:	c467b783          	ld	a5,-954(a5) # ffffffffc0207460 <pmm_manager>
ffffffffc0201822:	739c                	ld	a5,32(a5)
ffffffffc0201824:	8782                	jr	a5
void free_pages(struct Page *base, size_t n) {
ffffffffc0201826:	1101                	addi	sp,sp,-32
ffffffffc0201828:	ec06                	sd	ra,24(sp)
ffffffffc020182a:	e42e                	sd	a1,8(sp)
ffffffffc020182c:	e02a                	sd	a0,0(sp)
        intr_disable();
ffffffffc020182e:	f8bfe0ef          	jal	ffffffffc02007b8 <intr_disable>
        pmm_manager->free_pages(base, n);
ffffffffc0201832:	00006797          	auipc	a5,0x6
ffffffffc0201836:	c2e7b783          	ld	a5,-978(a5) # ffffffffc0207460 <pmm_manager>
ffffffffc020183a:	65a2                	ld	a1,8(sp)
ffffffffc020183c:	6502                	ld	a0,0(sp)
ffffffffc020183e:	739c                	ld	a5,32(a5)
ffffffffc0201840:	9782                	jalr	a5
    }
    local_intr_restore(intr_flag);
}
ffffffffc0201842:	60e2                	ld	ra,24(sp)
ffffffffc0201844:	6105                	addi	sp,sp,32
        intr_enable();
ffffffffc0201846:	f6dfe06f          	j	ffffffffc02007b2 <intr_enable>

ffffffffc020184a <nr_free_pages>:
    if (read_csr(sstatus) & SSTATUS_SIE) {
ffffffffc020184a:	100027f3          	csrr	a5,sstatus
ffffffffc020184e:	8b89                	andi	a5,a5,2
ffffffffc0201850:	e799                	bnez	a5,ffffffffc020185e <nr_free_pages+0x14>
size_t nr_free_pages(void) {
    size_t ret;
    bool intr_flag;
    local_intr_save(intr_flag);
    {
        ret = pmm_manager->nr_free_pages();
ffffffffc0201852:	00006797          	auipc	a5,0x6
ffffffffc0201856:	c0e7b783          	ld	a5,-1010(a5) # ffffffffc0207460 <pmm_manager>
ffffffffc020185a:	779c                	ld	a5,40(a5)
ffffffffc020185c:	8782                	jr	a5
size_t nr_free_pages(void) {
ffffffffc020185e:	1101                	addi	sp,sp,-32
ffffffffc0201860:	ec06                	sd	ra,24(sp)
        intr_disable();
ffffffffc0201862:	f57fe0ef          	jal	ffffffffc02007b8 <intr_disable>
        ret = pmm_manager->nr_free_pages();
ffffffffc0201866:	00006797          	auipc	a5,0x6
ffffffffc020186a:	bfa7b783          	ld	a5,-1030(a5) # ffffffffc0207460 <pmm_manager>
ffffffffc020186e:	779c                	ld	a5,40(a5)
ffffffffc0201870:	9782                	jalr	a5
ffffffffc0201872:	e42a                	sd	a0,8(sp)
        intr_enable();
ffffffffc0201874:	f3ffe0ef          	jal	ffffffffc02007b2 <intr_enable>
    }
    local_intr_restore(intr_flag);
    return ret;
}
ffffffffc0201878:	60e2                	ld	ra,24(sp)
ffffffffc020187a:	6522                	ld	a0,8(sp)
ffffffffc020187c:	6105                	addi	sp,sp,32
ffffffffc020187e:	8082                	ret

ffffffffc0201880 <pmm_init>:
    pmm_manager = &default_pmm_manager;
ffffffffc0201880:	00001797          	auipc	a5,0x1
ffffffffc0201884:	73878793          	addi	a5,a5,1848 # ffffffffc0202fb8 <default_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201888:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc020188a:	7139                	addi	sp,sp,-64
ffffffffc020188c:	fc06                	sd	ra,56(sp)
ffffffffc020188e:	f822                	sd	s0,48(sp)
ffffffffc0201890:	f426                	sd	s1,40(sp)
ffffffffc0201892:	ec4e                	sd	s3,24(sp)
ffffffffc0201894:	f04a                	sd	s2,32(sp)
    pmm_manager = &default_pmm_manager;
ffffffffc0201896:	00006417          	auipc	s0,0x6
ffffffffc020189a:	bca40413          	addi	s0,s0,-1078 # ffffffffc0207460 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020189e:	00001517          	auipc	a0,0x1
ffffffffc02018a2:	48250513          	addi	a0,a0,1154 # ffffffffc0202d20 <etext+0xd24>
    pmm_manager = &default_pmm_manager;
ffffffffc02018a6:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc02018a8:	865fe0ef          	jal	ffffffffc020010c <cprintf>
    pmm_manager->init();
ffffffffc02018ac:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02018ae:	00006497          	auipc	s1,0x6
ffffffffc02018b2:	bca48493          	addi	s1,s1,-1078 # ffffffffc0207478 <va_pa_offset>
    pmm_manager->init();
ffffffffc02018b6:	679c                	ld	a5,8(a5)
ffffffffc02018b8:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc02018ba:	57f5                	li	a5,-3
ffffffffc02018bc:	07fa                	slli	a5,a5,0x1e
ffffffffc02018be:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc02018c0:	edffe0ef          	jal	ffffffffc020079e <get_memory_base>
ffffffffc02018c4:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc02018c6:	ee3fe0ef          	jal	ffffffffc02007a8 <get_memory_size>
    if (mem_size == 0) {
ffffffffc02018ca:	16050063          	beqz	a0,ffffffffc0201a2a <pmm_init+0x1aa>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc02018ce:	00a98933          	add	s2,s3,a0
ffffffffc02018d2:	e42a                	sd	a0,8(sp)
    cprintf("physcial memory map:\n");
ffffffffc02018d4:	00001517          	auipc	a0,0x1
ffffffffc02018d8:	49450513          	addi	a0,a0,1172 # ffffffffc0202d68 <etext+0xd6c>
ffffffffc02018dc:	831fe0ef          	jal	ffffffffc020010c <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc02018e0:	65a2                	ld	a1,8(sp)
ffffffffc02018e2:	864e                	mv	a2,s3
ffffffffc02018e4:	fff90693          	addi	a3,s2,-1
ffffffffc02018e8:	00001517          	auipc	a0,0x1
ffffffffc02018ec:	49850513          	addi	a0,a0,1176 # ffffffffc0202d80 <etext+0xd84>
ffffffffc02018f0:	81dfe0ef          	jal	ffffffffc020010c <cprintf>
    if (maxpa > KERNTOP) {
ffffffffc02018f4:	c80007b7          	lui	a5,0xc8000
ffffffffc02018f8:	864a                	mv	a2,s2
ffffffffc02018fa:	0d27e563          	bltu	a5,s2,ffffffffc02019c4 <pmm_init+0x144>
ffffffffc02018fe:	77fd                	lui	a5,0xfffff
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201900:	00007697          	auipc	a3,0x7
ffffffffc0201904:	b9768693          	addi	a3,a3,-1129 # ffffffffc0208497 <end+0xfff>
ffffffffc0201908:	8efd                	and	a3,a3,a5
    npage = maxpa / PGSIZE;
ffffffffc020190a:	8231                	srli	a2,a2,0xc
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020190c:	00006817          	auipc	a6,0x6
ffffffffc0201910:	b7c80813          	addi	a6,a6,-1156 # ffffffffc0207488 <pages>
    npage = maxpa / PGSIZE;
ffffffffc0201914:	00006517          	auipc	a0,0x6
ffffffffc0201918:	b6c50513          	addi	a0,a0,-1172 # ffffffffc0207480 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc020191c:	00d83023          	sd	a3,0(a6)
    npage = maxpa / PGSIZE;
ffffffffc0201920:	e110                	sd	a2,0(a0)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201922:	00080737          	lui	a4,0x80
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201926:	87b6                	mv	a5,a3
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201928:	02e60a63          	beq	a2,a4,ffffffffc020195c <pmm_init+0xdc>
ffffffffc020192c:	4701                	li	a4,0
ffffffffc020192e:	4781                	li	a5,0
ffffffffc0201930:	4305                	li	t1,1
ffffffffc0201932:	fff808b7          	lui	a7,0xfff80
        SetPageReserved(pages + i);
ffffffffc0201936:	96ba                	add	a3,a3,a4
ffffffffc0201938:	06a1                	addi	a3,a3,8
ffffffffc020193a:	4066b02f          	amoor.d	zero,t1,(a3)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020193e:	6110                	ld	a2,0(a0)
ffffffffc0201940:	0785                	addi	a5,a5,1 # fffffffffffff001 <end+0x3fdf7b69>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201942:	00083683          	ld	a3,0(a6)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc0201946:	011605b3          	add	a1,a2,a7
ffffffffc020194a:	02870713          	addi	a4,a4,40 # 80028 <kern_entry-0xffffffffc017ffd8>
ffffffffc020194e:	feb7e4e3          	bltu	a5,a1,ffffffffc0201936 <pmm_init+0xb6>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201952:	00259793          	slli	a5,a1,0x2
ffffffffc0201956:	97ae                	add	a5,a5,a1
ffffffffc0201958:	078e                	slli	a5,a5,0x3
ffffffffc020195a:	97b6                	add	a5,a5,a3
ffffffffc020195c:	c0200737          	lui	a4,0xc0200
ffffffffc0201960:	0ae7e863          	bltu	a5,a4,ffffffffc0201a10 <pmm_init+0x190>
ffffffffc0201964:	608c                	ld	a1,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc0201966:	777d                	lui	a4,0xfffff
ffffffffc0201968:	00e97933          	and	s2,s2,a4
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020196c:	8f8d                	sub	a5,a5,a1
    if (freemem < mem_end) {
ffffffffc020196e:	0527ed63          	bltu	a5,s2,ffffffffc02019c8 <pmm_init+0x148>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc0201972:	601c                	ld	a5,0(s0)
ffffffffc0201974:	7b9c                	ld	a5,48(a5)
ffffffffc0201976:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201978:	00001517          	auipc	a0,0x1
ffffffffc020197c:	49050513          	addi	a0,a0,1168 # ffffffffc0202e08 <etext+0xe0c>
ffffffffc0201980:	f8cfe0ef          	jal	ffffffffc020010c <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc0201984:	00004597          	auipc	a1,0x4
ffffffffc0201988:	67c58593          	addi	a1,a1,1660 # ffffffffc0206000 <boot_page_table_sv39>
ffffffffc020198c:	00006797          	auipc	a5,0x6
ffffffffc0201990:	aeb7b223          	sd	a1,-1308(a5) # ffffffffc0207470 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201994:	c02007b7          	lui	a5,0xc0200
ffffffffc0201998:	0af5e563          	bltu	a1,a5,ffffffffc0201a42 <pmm_init+0x1c2>
ffffffffc020199c:	609c                	ld	a5,0(s1)
}
ffffffffc020199e:	7442                	ld	s0,48(sp)
ffffffffc02019a0:	70e2                	ld	ra,56(sp)
ffffffffc02019a2:	74a2                	ld	s1,40(sp)
ffffffffc02019a4:	7902                	ld	s2,32(sp)
ffffffffc02019a6:	69e2                	ld	s3,24(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc02019a8:	40f586b3          	sub	a3,a1,a5
ffffffffc02019ac:	00006797          	auipc	a5,0x6
ffffffffc02019b0:	aad7be23          	sd	a3,-1348(a5) # ffffffffc0207468 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02019b4:	00001517          	auipc	a0,0x1
ffffffffc02019b8:	47450513          	addi	a0,a0,1140 # ffffffffc0202e28 <etext+0xe2c>
ffffffffc02019bc:	8636                	mv	a2,a3
}
ffffffffc02019be:	6121                	addi	sp,sp,64
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc02019c0:	f4cfe06f          	j	ffffffffc020010c <cprintf>
    if (maxpa > KERNTOP) {
ffffffffc02019c4:	863e                	mv	a2,a5
ffffffffc02019c6:	bf25                	j	ffffffffc02018fe <pmm_init+0x7e>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc02019c8:	6585                	lui	a1,0x1
ffffffffc02019ca:	15fd                	addi	a1,a1,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc02019cc:	97ae                	add	a5,a5,a1
ffffffffc02019ce:	8ff9                	and	a5,a5,a4
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc02019d0:	00c7d713          	srli	a4,a5,0xc
ffffffffc02019d4:	02c77263          	bgeu	a4,a2,ffffffffc02019f8 <pmm_init+0x178>
    pmm_manager->init_memmap(base, n);
ffffffffc02019d8:	6010                	ld	a2,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc02019da:	fff805b7          	lui	a1,0xfff80
ffffffffc02019de:	972e                	add	a4,a4,a1
ffffffffc02019e0:	00271513          	slli	a0,a4,0x2
ffffffffc02019e4:	953a                	add	a0,a0,a4
ffffffffc02019e6:	6a18                	ld	a4,16(a2)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc02019e8:	40f90933          	sub	s2,s2,a5
ffffffffc02019ec:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc02019ee:	00c95593          	srli	a1,s2,0xc
ffffffffc02019f2:	9536                	add	a0,a0,a3
ffffffffc02019f4:	9702                	jalr	a4
}
ffffffffc02019f6:	bfb5                	j	ffffffffc0201972 <pmm_init+0xf2>
        panic("pa2page called with invalid pa");
ffffffffc02019f8:	00001617          	auipc	a2,0x1
ffffffffc02019fc:	3e060613          	addi	a2,a2,992 # ffffffffc0202dd8 <etext+0xddc>
ffffffffc0201a00:	06b00593          	li	a1,107
ffffffffc0201a04:	00001517          	auipc	a0,0x1
ffffffffc0201a08:	3f450513          	addi	a0,a0,1012 # ffffffffc0202df8 <etext+0xdfc>
ffffffffc0201a0c:	9b3fe0ef          	jal	ffffffffc02003be <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc0201a10:	86be                	mv	a3,a5
ffffffffc0201a12:	00001617          	auipc	a2,0x1
ffffffffc0201a16:	39e60613          	addi	a2,a2,926 # ffffffffc0202db0 <etext+0xdb4>
ffffffffc0201a1a:	07100593          	li	a1,113
ffffffffc0201a1e:	00001517          	auipc	a0,0x1
ffffffffc0201a22:	33a50513          	addi	a0,a0,826 # ffffffffc0202d58 <etext+0xd5c>
ffffffffc0201a26:	999fe0ef          	jal	ffffffffc02003be <__panic>
        panic("DTB memory info not available");
ffffffffc0201a2a:	00001617          	auipc	a2,0x1
ffffffffc0201a2e:	30e60613          	addi	a2,a2,782 # ffffffffc0202d38 <etext+0xd3c>
ffffffffc0201a32:	05a00593          	li	a1,90
ffffffffc0201a36:	00001517          	auipc	a0,0x1
ffffffffc0201a3a:	32250513          	addi	a0,a0,802 # ffffffffc0202d58 <etext+0xd5c>
ffffffffc0201a3e:	981fe0ef          	jal	ffffffffc02003be <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc0201a42:	86ae                	mv	a3,a1
ffffffffc0201a44:	00001617          	auipc	a2,0x1
ffffffffc0201a48:	36c60613          	addi	a2,a2,876 # ffffffffc0202db0 <etext+0xdb4>
ffffffffc0201a4c:	08c00593          	li	a1,140
ffffffffc0201a50:	00001517          	auipc	a0,0x1
ffffffffc0201a54:	30850513          	addi	a0,a0,776 # ffffffffc0202d58 <etext+0xd5c>
ffffffffc0201a58:	967fe0ef          	jal	ffffffffc02003be <__panic>

ffffffffc0201a5c <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201a5c:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc0201a5e:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201a62:	f022                	sd	s0,32(sp)
ffffffffc0201a64:	ec26                	sd	s1,24(sp)
ffffffffc0201a66:	e84a                	sd	s2,16(sp)
ffffffffc0201a68:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201a6a:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201a6e:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
ffffffffc0201a70:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc0201a74:	fff7041b          	addiw	s0,a4,-1 # ffffffffffffefff <end+0x3fdf7b67>
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201a78:	84aa                	mv	s1,a0
ffffffffc0201a7a:	892e                	mv	s2,a1
    if (num >= base) {
ffffffffc0201a7c:	03067d63          	bgeu	a2,a6,ffffffffc0201ab6 <printnum+0x5a>
ffffffffc0201a80:	e44e                	sd	s3,8(sp)
ffffffffc0201a82:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc0201a84:	4785                	li	a5,1
ffffffffc0201a86:	00e7d763          	bge	a5,a4,ffffffffc0201a94 <printnum+0x38>
            putch(padc, putdat);
ffffffffc0201a8a:	85ca                	mv	a1,s2
ffffffffc0201a8c:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc0201a8e:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201a90:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc0201a92:	fc65                	bnez	s0,ffffffffc0201a8a <printnum+0x2e>
ffffffffc0201a94:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201a96:	00001797          	auipc	a5,0x1
ffffffffc0201a9a:	3d278793          	addi	a5,a5,978 # ffffffffc0202e68 <etext+0xe6c>
ffffffffc0201a9e:	97d2                	add	a5,a5,s4
}
ffffffffc0201aa0:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201aa2:	0007c503          	lbu	a0,0(a5)
}
ffffffffc0201aa6:	70a2                	ld	ra,40(sp)
ffffffffc0201aa8:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201aaa:	85ca                	mv	a1,s2
ffffffffc0201aac:	87a6                	mv	a5,s1
}
ffffffffc0201aae:	6942                	ld	s2,16(sp)
ffffffffc0201ab0:	64e2                	ld	s1,24(sp)
ffffffffc0201ab2:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201ab4:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc0201ab6:	03065633          	divu	a2,a2,a6
ffffffffc0201aba:	8722                	mv	a4,s0
ffffffffc0201abc:	fa1ff0ef          	jal	ffffffffc0201a5c <printnum>
ffffffffc0201ac0:	bfd9                	j	ffffffffc0201a96 <printnum+0x3a>

ffffffffc0201ac2 <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc0201ac2:	7119                	addi	sp,sp,-128
ffffffffc0201ac4:	f4a6                	sd	s1,104(sp)
ffffffffc0201ac6:	f0ca                	sd	s2,96(sp)
ffffffffc0201ac8:	ecce                	sd	s3,88(sp)
ffffffffc0201aca:	e8d2                	sd	s4,80(sp)
ffffffffc0201acc:	e4d6                	sd	s5,72(sp)
ffffffffc0201ace:	e0da                	sd	s6,64(sp)
ffffffffc0201ad0:	f862                	sd	s8,48(sp)
ffffffffc0201ad2:	fc86                	sd	ra,120(sp)
ffffffffc0201ad4:	f8a2                	sd	s0,112(sp)
ffffffffc0201ad6:	fc5e                	sd	s7,56(sp)
ffffffffc0201ad8:	f466                	sd	s9,40(sp)
ffffffffc0201ada:	f06a                	sd	s10,32(sp)
ffffffffc0201adc:	ec6e                	sd	s11,24(sp)
ffffffffc0201ade:	84aa                	mv	s1,a0
ffffffffc0201ae0:	8c32                	mv	s8,a2
ffffffffc0201ae2:	8a36                	mv	s4,a3
ffffffffc0201ae4:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201ae6:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201aea:	05500b13          	li	s6,85
ffffffffc0201aee:	00001a97          	auipc	s5,0x1
ffffffffc0201af2:	502a8a93          	addi	s5,s5,1282 # ffffffffc0202ff0 <default_pmm_manager+0x38>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201af6:	000c4503          	lbu	a0,0(s8)
ffffffffc0201afa:	001c0413          	addi	s0,s8,1
ffffffffc0201afe:	01350a63          	beq	a0,s3,ffffffffc0201b12 <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc0201b02:	cd0d                	beqz	a0,ffffffffc0201b3c <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc0201b04:	85ca                	mv	a1,s2
ffffffffc0201b06:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201b08:	00044503          	lbu	a0,0(s0)
ffffffffc0201b0c:	0405                	addi	s0,s0,1
ffffffffc0201b0e:	ff351ae3          	bne	a0,s3,ffffffffc0201b02 <vprintfmt+0x40>
        width = precision = -1;
ffffffffc0201b12:	5cfd                	li	s9,-1
ffffffffc0201b14:	8d66                	mv	s10,s9
        char padc = ' ';
ffffffffc0201b16:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc0201b1a:	4b81                	li	s7,0
ffffffffc0201b1c:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b1e:	00044683          	lbu	a3,0(s0)
ffffffffc0201b22:	00140c13          	addi	s8,s0,1
ffffffffc0201b26:	fdd6859b          	addiw	a1,a3,-35
ffffffffc0201b2a:	0ff5f593          	zext.b	a1,a1
ffffffffc0201b2e:	02bb6663          	bltu	s6,a1,ffffffffc0201b5a <vprintfmt+0x98>
ffffffffc0201b32:	058a                	slli	a1,a1,0x2
ffffffffc0201b34:	95d6                	add	a1,a1,s5
ffffffffc0201b36:	4198                	lw	a4,0(a1)
ffffffffc0201b38:	9756                	add	a4,a4,s5
ffffffffc0201b3a:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc0201b3c:	70e6                	ld	ra,120(sp)
ffffffffc0201b3e:	7446                	ld	s0,112(sp)
ffffffffc0201b40:	74a6                	ld	s1,104(sp)
ffffffffc0201b42:	7906                	ld	s2,96(sp)
ffffffffc0201b44:	69e6                	ld	s3,88(sp)
ffffffffc0201b46:	6a46                	ld	s4,80(sp)
ffffffffc0201b48:	6aa6                	ld	s5,72(sp)
ffffffffc0201b4a:	6b06                	ld	s6,64(sp)
ffffffffc0201b4c:	7be2                	ld	s7,56(sp)
ffffffffc0201b4e:	7c42                	ld	s8,48(sp)
ffffffffc0201b50:	7ca2                	ld	s9,40(sp)
ffffffffc0201b52:	7d02                	ld	s10,32(sp)
ffffffffc0201b54:	6de2                	ld	s11,24(sp)
ffffffffc0201b56:	6109                	addi	sp,sp,128
ffffffffc0201b58:	8082                	ret
            putch('%', putdat);
ffffffffc0201b5a:	85ca                	mv	a1,s2
ffffffffc0201b5c:	02500513          	li	a0,37
ffffffffc0201b60:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc0201b62:	fff44783          	lbu	a5,-1(s0)
ffffffffc0201b66:	02500713          	li	a4,37
ffffffffc0201b6a:	8c22                	mv	s8,s0
ffffffffc0201b6c:	f8e785e3          	beq	a5,a4,ffffffffc0201af6 <vprintfmt+0x34>
ffffffffc0201b70:	ffec4783          	lbu	a5,-2(s8)
ffffffffc0201b74:	1c7d                	addi	s8,s8,-1
ffffffffc0201b76:	fee79de3          	bne	a5,a4,ffffffffc0201b70 <vprintfmt+0xae>
ffffffffc0201b7a:	bfb5                	j	ffffffffc0201af6 <vprintfmt+0x34>
                ch = *fmt;
ffffffffc0201b7c:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc0201b80:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
ffffffffc0201b82:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc0201b86:	fd06071b          	addiw	a4,a2,-48
ffffffffc0201b8a:	24e56a63          	bltu	a0,a4,ffffffffc0201dde <vprintfmt+0x31c>
                ch = *fmt;
ffffffffc0201b8e:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201b90:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
ffffffffc0201b92:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
ffffffffc0201b96:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201b9a:	0197073b          	addw	a4,a4,s9
ffffffffc0201b9e:	0017171b          	slliw	a4,a4,0x1
ffffffffc0201ba2:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
ffffffffc0201ba4:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201ba8:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201baa:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201bae:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
ffffffffc0201bb2:	feb570e3          	bgeu	a0,a1,ffffffffc0201b92 <vprintfmt+0xd0>
            if (width < 0)
ffffffffc0201bb6:	f60d54e3          	bgez	s10,ffffffffc0201b1e <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc0201bba:	8d66                	mv	s10,s9
ffffffffc0201bbc:	5cfd                	li	s9,-1
ffffffffc0201bbe:	b785                	j	ffffffffc0201b1e <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201bc0:	8db6                	mv	s11,a3
ffffffffc0201bc2:	8462                	mv	s0,s8
ffffffffc0201bc4:	bfa9                	j	ffffffffc0201b1e <vprintfmt+0x5c>
ffffffffc0201bc6:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc0201bc8:	4b85                	li	s7,1
            goto reswitch;
ffffffffc0201bca:	bf91                	j	ffffffffc0201b1e <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc0201bcc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201bce:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201bd2:	00f74463          	blt	a4,a5,ffffffffc0201bda <vprintfmt+0x118>
    else if (lflag) {
ffffffffc0201bd6:	1a078763          	beqz	a5,ffffffffc0201d84 <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
ffffffffc0201bda:	000a3603          	ld	a2,0(s4)
ffffffffc0201bde:	46c1                	li	a3,16
ffffffffc0201be0:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc0201be2:	000d879b          	sext.w	a5,s11
ffffffffc0201be6:	876a                	mv	a4,s10
ffffffffc0201be8:	85ca                	mv	a1,s2
ffffffffc0201bea:	8526                	mv	a0,s1
ffffffffc0201bec:	e71ff0ef          	jal	ffffffffc0201a5c <printnum>
            break;
ffffffffc0201bf0:	b719                	j	ffffffffc0201af6 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc0201bf2:	000a2503          	lw	a0,0(s4)
ffffffffc0201bf6:	85ca                	mv	a1,s2
ffffffffc0201bf8:	0a21                	addi	s4,s4,8
ffffffffc0201bfa:	9482                	jalr	s1
            break;
ffffffffc0201bfc:	bded                	j	ffffffffc0201af6 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0201bfe:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201c00:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201c04:	00f74463          	blt	a4,a5,ffffffffc0201c0c <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201c08:	16078963          	beqz	a5,ffffffffc0201d7a <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
ffffffffc0201c0c:	000a3603          	ld	a2,0(s4)
ffffffffc0201c10:	46a9                	li	a3,10
ffffffffc0201c12:	8a2e                	mv	s4,a1
ffffffffc0201c14:	b7f9                	j	ffffffffc0201be2 <vprintfmt+0x120>
            putch('0', putdat);
ffffffffc0201c16:	85ca                	mv	a1,s2
ffffffffc0201c18:	03000513          	li	a0,48
ffffffffc0201c1c:	9482                	jalr	s1
            putch('x', putdat);
ffffffffc0201c1e:	85ca                	mv	a1,s2
ffffffffc0201c20:	07800513          	li	a0,120
ffffffffc0201c24:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201c26:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc0201c2a:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc0201c2c:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc0201c2e:	bf55                	j	ffffffffc0201be2 <vprintfmt+0x120>
            putch(ch, putdat);
ffffffffc0201c30:	85ca                	mv	a1,s2
ffffffffc0201c32:	02500513          	li	a0,37
ffffffffc0201c36:	9482                	jalr	s1
            break;
ffffffffc0201c38:	bd7d                	j	ffffffffc0201af6 <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc0201c3a:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c3e:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc0201c40:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc0201c42:	bf95                	j	ffffffffc0201bb6 <vprintfmt+0xf4>
    if (lflag >= 2) {
ffffffffc0201c44:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201c46:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc0201c4a:	00f74463          	blt	a4,a5,ffffffffc0201c52 <vprintfmt+0x190>
    else if (lflag) {
ffffffffc0201c4e:	12078163          	beqz	a5,ffffffffc0201d70 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
ffffffffc0201c52:	000a3603          	ld	a2,0(s4)
ffffffffc0201c56:	46a1                	li	a3,8
ffffffffc0201c58:	8a2e                	mv	s4,a1
ffffffffc0201c5a:	b761                	j	ffffffffc0201be2 <vprintfmt+0x120>
            if (width < 0)
ffffffffc0201c5c:	876a                	mv	a4,s10
ffffffffc0201c5e:	000d5363          	bgez	s10,ffffffffc0201c64 <vprintfmt+0x1a2>
ffffffffc0201c62:	4701                	li	a4,0
ffffffffc0201c64:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201c68:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0201c6a:	bd55                	j	ffffffffc0201b1e <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
ffffffffc0201c6c:	000d841b          	sext.w	s0,s11
ffffffffc0201c70:	fd340793          	addi	a5,s0,-45
ffffffffc0201c74:	00f037b3          	snez	a5,a5
ffffffffc0201c78:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201c7c:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
ffffffffc0201c80:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201c82:	008a0793          	addi	a5,s4,8
ffffffffc0201c86:	e43e                	sd	a5,8(sp)
ffffffffc0201c88:	100d8c63          	beqz	s11,ffffffffc0201da0 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc0201c8c:	12071363          	bnez	a4,ffffffffc0201db2 <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201c90:	000dc783          	lbu	a5,0(s11)
ffffffffc0201c94:	0007851b          	sext.w	a0,a5
ffffffffc0201c98:	c78d                	beqz	a5,ffffffffc0201cc2 <vprintfmt+0x200>
ffffffffc0201c9a:	0d85                	addi	s11,s11,1
ffffffffc0201c9c:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201c9e:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201ca2:	000cc563          	bltz	s9,ffffffffc0201cac <vprintfmt+0x1ea>
ffffffffc0201ca6:	3cfd                	addiw	s9,s9,-1
ffffffffc0201ca8:	008c8d63          	beq	s9,s0,ffffffffc0201cc2 <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201cac:	020b9663          	bnez	s7,ffffffffc0201cd8 <vprintfmt+0x216>
                    putch(ch, putdat);
ffffffffc0201cb0:	85ca                	mv	a1,s2
ffffffffc0201cb2:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201cb4:	000dc783          	lbu	a5,0(s11)
ffffffffc0201cb8:	0d85                	addi	s11,s11,1
ffffffffc0201cba:	3d7d                	addiw	s10,s10,-1
ffffffffc0201cbc:	0007851b          	sext.w	a0,a5
ffffffffc0201cc0:	f3ed                	bnez	a5,ffffffffc0201ca2 <vprintfmt+0x1e0>
            for (; width > 0; width --) {
ffffffffc0201cc2:	01a05963          	blez	s10,ffffffffc0201cd4 <vprintfmt+0x212>
                putch(' ', putdat);
ffffffffc0201cc6:	85ca                	mv	a1,s2
ffffffffc0201cc8:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc0201ccc:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
ffffffffc0201cce:	9482                	jalr	s1
            for (; width > 0; width --) {
ffffffffc0201cd0:	fe0d1be3          	bnez	s10,ffffffffc0201cc6 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201cd4:	6a22                	ld	s4,8(sp)
ffffffffc0201cd6:	b505                	j	ffffffffc0201af6 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201cd8:	3781                	addiw	a5,a5,-32
ffffffffc0201cda:	fcfa7be3          	bgeu	s4,a5,ffffffffc0201cb0 <vprintfmt+0x1ee>
                    putch('?', putdat);
ffffffffc0201cde:	03f00513          	li	a0,63
ffffffffc0201ce2:	85ca                	mv	a1,s2
ffffffffc0201ce4:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201ce6:	000dc783          	lbu	a5,0(s11)
ffffffffc0201cea:	0d85                	addi	s11,s11,1
ffffffffc0201cec:	3d7d                	addiw	s10,s10,-1
ffffffffc0201cee:	0007851b          	sext.w	a0,a5
ffffffffc0201cf2:	dbe1                	beqz	a5,ffffffffc0201cc2 <vprintfmt+0x200>
ffffffffc0201cf4:	fa0cd9e3          	bgez	s9,ffffffffc0201ca6 <vprintfmt+0x1e4>
ffffffffc0201cf8:	b7c5                	j	ffffffffc0201cd8 <vprintfmt+0x216>
            if (err < 0) {
ffffffffc0201cfa:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201cfe:	4619                	li	a2,6
            err = va_arg(ap, int);
ffffffffc0201d00:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc0201d02:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc0201d06:	8fb9                	xor	a5,a5,a4
ffffffffc0201d08:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201d0c:	02d64563          	blt	a2,a3,ffffffffc0201d36 <vprintfmt+0x274>
ffffffffc0201d10:	00001797          	auipc	a5,0x1
ffffffffc0201d14:	43878793          	addi	a5,a5,1080 # ffffffffc0203148 <error_string>
ffffffffc0201d18:	00369713          	slli	a4,a3,0x3
ffffffffc0201d1c:	97ba                	add	a5,a5,a4
ffffffffc0201d1e:	639c                	ld	a5,0(a5)
ffffffffc0201d20:	cb99                	beqz	a5,ffffffffc0201d36 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
ffffffffc0201d22:	86be                	mv	a3,a5
ffffffffc0201d24:	00001617          	auipc	a2,0x1
ffffffffc0201d28:	17460613          	addi	a2,a2,372 # ffffffffc0202e98 <etext+0xe9c>
ffffffffc0201d2c:	85ca                	mv	a1,s2
ffffffffc0201d2e:	8526                	mv	a0,s1
ffffffffc0201d30:	0d8000ef          	jal	ffffffffc0201e08 <printfmt>
ffffffffc0201d34:	b3c9                	j	ffffffffc0201af6 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc0201d36:	00001617          	auipc	a2,0x1
ffffffffc0201d3a:	15260613          	addi	a2,a2,338 # ffffffffc0202e88 <etext+0xe8c>
ffffffffc0201d3e:	85ca                	mv	a1,s2
ffffffffc0201d40:	8526                	mv	a0,s1
ffffffffc0201d42:	0c6000ef          	jal	ffffffffc0201e08 <printfmt>
ffffffffc0201d46:	bb45                	j	ffffffffc0201af6 <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0201d48:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201d4a:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc0201d4e:	00f74363          	blt	a4,a5,ffffffffc0201d54 <vprintfmt+0x292>
    else if (lflag) {
ffffffffc0201d52:	cf81                	beqz	a5,ffffffffc0201d6a <vprintfmt+0x2a8>
        return va_arg(*ap, long);
ffffffffc0201d54:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc0201d58:	02044b63          	bltz	s0,ffffffffc0201d8e <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc0201d5c:	8622                	mv	a2,s0
ffffffffc0201d5e:	8a5e                	mv	s4,s7
ffffffffc0201d60:	46a9                	li	a3,10
ffffffffc0201d62:	b541                	j	ffffffffc0201be2 <vprintfmt+0x120>
            lflag ++;
ffffffffc0201d64:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201d66:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc0201d68:	bb5d                	j	ffffffffc0201b1e <vprintfmt+0x5c>
        return va_arg(*ap, int);
ffffffffc0201d6a:	000a2403          	lw	s0,0(s4)
ffffffffc0201d6e:	b7ed                	j	ffffffffc0201d58 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
ffffffffc0201d70:	000a6603          	lwu	a2,0(s4)
ffffffffc0201d74:	46a1                	li	a3,8
ffffffffc0201d76:	8a2e                	mv	s4,a1
ffffffffc0201d78:	b5ad                	j	ffffffffc0201be2 <vprintfmt+0x120>
ffffffffc0201d7a:	000a6603          	lwu	a2,0(s4)
ffffffffc0201d7e:	46a9                	li	a3,10
ffffffffc0201d80:	8a2e                	mv	s4,a1
ffffffffc0201d82:	b585                	j	ffffffffc0201be2 <vprintfmt+0x120>
ffffffffc0201d84:	000a6603          	lwu	a2,0(s4)
ffffffffc0201d88:	46c1                	li	a3,16
ffffffffc0201d8a:	8a2e                	mv	s4,a1
ffffffffc0201d8c:	bd99                	j	ffffffffc0201be2 <vprintfmt+0x120>
                putch('-', putdat);
ffffffffc0201d8e:	85ca                	mv	a1,s2
ffffffffc0201d90:	02d00513          	li	a0,45
ffffffffc0201d94:	9482                	jalr	s1
                num = -(long long)num;
ffffffffc0201d96:	40800633          	neg	a2,s0
ffffffffc0201d9a:	8a5e                	mv	s4,s7
ffffffffc0201d9c:	46a9                	li	a3,10
ffffffffc0201d9e:	b591                	j	ffffffffc0201be2 <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
ffffffffc0201da0:	e329                	bnez	a4,ffffffffc0201de2 <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201da2:	02800793          	li	a5,40
ffffffffc0201da6:	853e                	mv	a0,a5
ffffffffc0201da8:	00001d97          	auipc	s11,0x1
ffffffffc0201dac:	0d9d8d93          	addi	s11,s11,217 # ffffffffc0202e81 <etext+0xe85>
ffffffffc0201db0:	b5f5                	j	ffffffffc0201c9c <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201db2:	85e6                	mv	a1,s9
ffffffffc0201db4:	856e                	mv	a0,s11
ffffffffc0201db6:	1aa000ef          	jal	ffffffffc0201f60 <strnlen>
ffffffffc0201dba:	40ad0d3b          	subw	s10,s10,a0
ffffffffc0201dbe:	01a05863          	blez	s10,ffffffffc0201dce <vprintfmt+0x30c>
                    putch(padc, putdat);
ffffffffc0201dc2:	85ca                	mv	a1,s2
ffffffffc0201dc4:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201dc6:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
ffffffffc0201dc8:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201dca:	fe0d1ce3          	bnez	s10,ffffffffc0201dc2 <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201dce:	000dc783          	lbu	a5,0(s11)
ffffffffc0201dd2:	0007851b          	sext.w	a0,a5
ffffffffc0201dd6:	ec0792e3          	bnez	a5,ffffffffc0201c9a <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201dda:	6a22                	ld	s4,8(sp)
ffffffffc0201ddc:	bb29                	j	ffffffffc0201af6 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201dde:	8462                	mv	s0,s8
ffffffffc0201de0:	bbd9                	j	ffffffffc0201bb6 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201de2:	85e6                	mv	a1,s9
ffffffffc0201de4:	00001517          	auipc	a0,0x1
ffffffffc0201de8:	09c50513          	addi	a0,a0,156 # ffffffffc0202e80 <etext+0xe84>
ffffffffc0201dec:	174000ef          	jal	ffffffffc0201f60 <strnlen>
ffffffffc0201df0:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201df4:	02800793          	li	a5,40
                p = "(null)";
ffffffffc0201df8:	00001d97          	auipc	s11,0x1
ffffffffc0201dfc:	088d8d93          	addi	s11,s11,136 # ffffffffc0202e80 <etext+0xe84>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201e00:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201e02:	fda040e3          	bgtz	s10,ffffffffc0201dc2 <vprintfmt+0x300>
ffffffffc0201e06:	bd51                	j	ffffffffc0201c9a <vprintfmt+0x1d8>

ffffffffc0201e08 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201e08:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201e0a:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201e0e:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201e10:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201e12:	ec06                	sd	ra,24(sp)
ffffffffc0201e14:	f83a                	sd	a4,48(sp)
ffffffffc0201e16:	fc3e                	sd	a5,56(sp)
ffffffffc0201e18:	e0c2                	sd	a6,64(sp)
ffffffffc0201e1a:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc0201e1c:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201e1e:	ca5ff0ef          	jal	ffffffffc0201ac2 <vprintfmt>
}
ffffffffc0201e22:	60e2                	ld	ra,24(sp)
ffffffffc0201e24:	6161                	addi	sp,sp,80
ffffffffc0201e26:	8082                	ret

ffffffffc0201e28 <readline>:
 * The readline() function returns the text of the line read. If some errors
 * are happened, NULL is returned. The return value is a global variable,
 * thus it should be copied before it is used.
 * */
char *
readline(const char *prompt) {
ffffffffc0201e28:	7179                	addi	sp,sp,-48
ffffffffc0201e2a:	f406                	sd	ra,40(sp)
ffffffffc0201e2c:	f022                	sd	s0,32(sp)
ffffffffc0201e2e:	ec26                	sd	s1,24(sp)
ffffffffc0201e30:	e84a                	sd	s2,16(sp)
ffffffffc0201e32:	e44e                	sd	s3,8(sp)
    if (prompt != NULL) {
ffffffffc0201e34:	c901                	beqz	a0,ffffffffc0201e44 <readline+0x1c>
        cprintf("%s", prompt);
ffffffffc0201e36:	85aa                	mv	a1,a0
ffffffffc0201e38:	00001517          	auipc	a0,0x1
ffffffffc0201e3c:	06050513          	addi	a0,a0,96 # ffffffffc0202e98 <etext+0xe9c>
ffffffffc0201e40:	accfe0ef          	jal	ffffffffc020010c <cprintf>
        if (c < 0) {
            return NULL;
        }
        else if (c >= ' ' && i < BUFSIZE - 1) {
            cputchar(c);
            buf[i ++] = c;
ffffffffc0201e44:	4481                	li	s1,0
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201e46:	497d                	li	s2,31
            buf[i ++] = c;
ffffffffc0201e48:	00005997          	auipc	s3,0x5
ffffffffc0201e4c:	1f898993          	addi	s3,s3,504 # ffffffffc0207040 <buf>
        c = getchar();
ffffffffc0201e50:	b3efe0ef          	jal	ffffffffc020018e <getchar>
ffffffffc0201e54:	842a                	mv	s0,a0
        }
        else if (c == '\b' && i > 0) {
ffffffffc0201e56:	ff850793          	addi	a5,a0,-8
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201e5a:	3ff4a713          	slti	a4,s1,1023
            cputchar(c);
            i --;
        }
        else if (c == '\n' || c == '\r') {
ffffffffc0201e5e:	ff650693          	addi	a3,a0,-10
ffffffffc0201e62:	ff350613          	addi	a2,a0,-13
        if (c < 0) {
ffffffffc0201e66:	02054963          	bltz	a0,ffffffffc0201e98 <readline+0x70>
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201e6a:	02a95f63          	bge	s2,a0,ffffffffc0201ea8 <readline+0x80>
ffffffffc0201e6e:	cf0d                	beqz	a4,ffffffffc0201ea8 <readline+0x80>
            cputchar(c);
ffffffffc0201e70:	ad0fe0ef          	jal	ffffffffc0200140 <cputchar>
            buf[i ++] = c;
ffffffffc0201e74:	009987b3          	add	a5,s3,s1
ffffffffc0201e78:	00878023          	sb	s0,0(a5)
ffffffffc0201e7c:	2485                	addiw	s1,s1,1
        c = getchar();
ffffffffc0201e7e:	b10fe0ef          	jal	ffffffffc020018e <getchar>
ffffffffc0201e82:	842a                	mv	s0,a0
        else if (c == '\b' && i > 0) {
ffffffffc0201e84:	ff850793          	addi	a5,a0,-8
        else if (c >= ' ' && i < BUFSIZE - 1) {
ffffffffc0201e88:	3ff4a713          	slti	a4,s1,1023
        else if (c == '\n' || c == '\r') {
ffffffffc0201e8c:	ff650693          	addi	a3,a0,-10
ffffffffc0201e90:	ff350613          	addi	a2,a0,-13
        if (c < 0) {
ffffffffc0201e94:	fc055be3          	bgez	a0,ffffffffc0201e6a <readline+0x42>
            cputchar(c);
            buf[i] = '\0';
            return buf;
        }
    }
}
ffffffffc0201e98:	70a2                	ld	ra,40(sp)
ffffffffc0201e9a:	7402                	ld	s0,32(sp)
ffffffffc0201e9c:	64e2                	ld	s1,24(sp)
ffffffffc0201e9e:	6942                	ld	s2,16(sp)
ffffffffc0201ea0:	69a2                	ld	s3,8(sp)
            return NULL;
ffffffffc0201ea2:	4501                	li	a0,0
}
ffffffffc0201ea4:	6145                	addi	sp,sp,48
ffffffffc0201ea6:	8082                	ret
        else if (c == '\b' && i > 0) {
ffffffffc0201ea8:	eb81                	bnez	a5,ffffffffc0201eb8 <readline+0x90>
            cputchar(c);
ffffffffc0201eaa:	4521                	li	a0,8
        else if (c == '\b' && i > 0) {
ffffffffc0201eac:	00905663          	blez	s1,ffffffffc0201eb8 <readline+0x90>
            cputchar(c);
ffffffffc0201eb0:	a90fe0ef          	jal	ffffffffc0200140 <cputchar>
            i --;
ffffffffc0201eb4:	34fd                	addiw	s1,s1,-1
ffffffffc0201eb6:	bf69                	j	ffffffffc0201e50 <readline+0x28>
        else if (c == '\n' || c == '\r') {
ffffffffc0201eb8:	c291                	beqz	a3,ffffffffc0201ebc <readline+0x94>
ffffffffc0201eba:	fa59                	bnez	a2,ffffffffc0201e50 <readline+0x28>
            cputchar(c);
ffffffffc0201ebc:	8522                	mv	a0,s0
ffffffffc0201ebe:	a82fe0ef          	jal	ffffffffc0200140 <cputchar>
            buf[i] = '\0';
ffffffffc0201ec2:	00005517          	auipc	a0,0x5
ffffffffc0201ec6:	17e50513          	addi	a0,a0,382 # ffffffffc0207040 <buf>
ffffffffc0201eca:	94aa                	add	s1,s1,a0
ffffffffc0201ecc:	00048023          	sb	zero,0(s1)
}
ffffffffc0201ed0:	70a2                	ld	ra,40(sp)
ffffffffc0201ed2:	7402                	ld	s0,32(sp)
ffffffffc0201ed4:	64e2                	ld	s1,24(sp)
ffffffffc0201ed6:	6942                	ld	s2,16(sp)
ffffffffc0201ed8:	69a2                	ld	s3,8(sp)
ffffffffc0201eda:	6145                	addi	sp,sp,48
ffffffffc0201edc:	8082                	ret

ffffffffc0201ede <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc0201ede:	00005717          	auipc	a4,0x5
ffffffffc0201ee2:	14273703          	ld	a4,322(a4) # ffffffffc0207020 <SBI_CONSOLE_PUTCHAR>
ffffffffc0201ee6:	4781                	li	a5,0
ffffffffc0201ee8:	88ba                	mv	a7,a4
ffffffffc0201eea:	852a                	mv	a0,a0
ffffffffc0201eec:	85be                	mv	a1,a5
ffffffffc0201eee:	863e                	mv	a2,a5
ffffffffc0201ef0:	00000073          	ecall
ffffffffc0201ef4:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc0201ef6:	8082                	ret

ffffffffc0201ef8 <sbi_set_timer>:
    __asm__ volatile (
ffffffffc0201ef8:	00005717          	auipc	a4,0x5
ffffffffc0201efc:	59873703          	ld	a4,1432(a4) # ffffffffc0207490 <SBI_SET_TIMER>
ffffffffc0201f00:	4781                	li	a5,0
ffffffffc0201f02:	88ba                	mv	a7,a4
ffffffffc0201f04:	852a                	mv	a0,a0
ffffffffc0201f06:	85be                	mv	a1,a5
ffffffffc0201f08:	863e                	mv	a2,a5
ffffffffc0201f0a:	00000073          	ecall
ffffffffc0201f0e:	87aa                	mv	a5,a0

void sbi_set_timer(unsigned long long stime_value) {
    sbi_call(SBI_SET_TIMER, stime_value, 0, 0);
}
ffffffffc0201f10:	8082                	ret

ffffffffc0201f12 <sbi_console_getchar>:
    __asm__ volatile (
ffffffffc0201f12:	00005797          	auipc	a5,0x5
ffffffffc0201f16:	1067b783          	ld	a5,262(a5) # ffffffffc0207018 <SBI_CONSOLE_GETCHAR>
ffffffffc0201f1a:	4501                	li	a0,0
ffffffffc0201f1c:	88be                	mv	a7,a5
ffffffffc0201f1e:	852a                	mv	a0,a0
ffffffffc0201f20:	85aa                	mv	a1,a0
ffffffffc0201f22:	862a                	mv	a2,a0
ffffffffc0201f24:	00000073          	ecall
ffffffffc0201f28:	852a                	mv	a0,a0

int sbi_console_getchar(void) {
    return sbi_call(SBI_CONSOLE_GETCHAR, 0, 0, 0);
}
ffffffffc0201f2a:	2501                	sext.w	a0,a0
ffffffffc0201f2c:	8082                	ret

ffffffffc0201f2e <sbi_shutdown>:
    __asm__ volatile (
ffffffffc0201f2e:	00005717          	auipc	a4,0x5
ffffffffc0201f32:	0e273703          	ld	a4,226(a4) # ffffffffc0207010 <SBI_SHUTDOWN>
ffffffffc0201f36:	4781                	li	a5,0
ffffffffc0201f38:	88ba                	mv	a7,a4
ffffffffc0201f3a:	853e                	mv	a0,a5
ffffffffc0201f3c:	85be                	mv	a1,a5
ffffffffc0201f3e:	863e                	mv	a2,a5
ffffffffc0201f40:	00000073          	ecall
ffffffffc0201f44:	87aa                	mv	a5,a0

void sbi_shutdown(void)
{
	sbi_call(SBI_SHUTDOWN, 0, 0, 0);
ffffffffc0201f46:	8082                	ret

ffffffffc0201f48 <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc0201f48:	00054783          	lbu	a5,0(a0)
ffffffffc0201f4c:	cb81                	beqz	a5,ffffffffc0201f5c <strlen+0x14>
    size_t cnt = 0;
ffffffffc0201f4e:	4781                	li	a5,0
        cnt ++;
ffffffffc0201f50:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc0201f52:	00f50733          	add	a4,a0,a5
ffffffffc0201f56:	00074703          	lbu	a4,0(a4)
ffffffffc0201f5a:	fb7d                	bnez	a4,ffffffffc0201f50 <strlen+0x8>
    }
    return cnt;
}
ffffffffc0201f5c:	853e                	mv	a0,a5
ffffffffc0201f5e:	8082                	ret

ffffffffc0201f60 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc0201f60:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201f62:	e589                	bnez	a1,ffffffffc0201f6c <strnlen+0xc>
ffffffffc0201f64:	a811                	j	ffffffffc0201f78 <strnlen+0x18>
        cnt ++;
ffffffffc0201f66:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc0201f68:	00f58863          	beq	a1,a5,ffffffffc0201f78 <strnlen+0x18>
ffffffffc0201f6c:	00f50733          	add	a4,a0,a5
ffffffffc0201f70:	00074703          	lbu	a4,0(a4)
ffffffffc0201f74:	fb6d                	bnez	a4,ffffffffc0201f66 <strnlen+0x6>
ffffffffc0201f76:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc0201f78:	852e                	mv	a0,a1
ffffffffc0201f7a:	8082                	ret

ffffffffc0201f7c <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201f7c:	00054783          	lbu	a5,0(a0)
ffffffffc0201f80:	e791                	bnez	a5,ffffffffc0201f8c <strcmp+0x10>
ffffffffc0201f82:	a01d                	j	ffffffffc0201fa8 <strcmp+0x2c>
ffffffffc0201f84:	00054783          	lbu	a5,0(a0)
ffffffffc0201f88:	cb99                	beqz	a5,ffffffffc0201f9e <strcmp+0x22>
ffffffffc0201f8a:	0585                	addi	a1,a1,1 # fffffffffff80001 <end+0x3fd78b69>
ffffffffc0201f8c:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc0201f90:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201f92:	fef709e3          	beq	a4,a5,ffffffffc0201f84 <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201f96:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc0201f9a:	9d19                	subw	a0,a0,a4
ffffffffc0201f9c:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201f9e:	0015c703          	lbu	a4,1(a1)
ffffffffc0201fa2:	4501                	li	a0,0
}
ffffffffc0201fa4:	9d19                	subw	a0,a0,a4
ffffffffc0201fa6:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201fa8:	0005c703          	lbu	a4,0(a1)
ffffffffc0201fac:	4501                	li	a0,0
ffffffffc0201fae:	b7f5                	j	ffffffffc0201f9a <strcmp+0x1e>

ffffffffc0201fb0 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201fb0:	ce01                	beqz	a2,ffffffffc0201fc8 <strncmp+0x18>
ffffffffc0201fb2:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0201fb6:	167d                	addi	a2,a2,-1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201fb8:	cb91                	beqz	a5,ffffffffc0201fcc <strncmp+0x1c>
ffffffffc0201fba:	0005c703          	lbu	a4,0(a1)
ffffffffc0201fbe:	00f71763          	bne	a4,a5,ffffffffc0201fcc <strncmp+0x1c>
        n --, s1 ++, s2 ++;
ffffffffc0201fc2:	0505                	addi	a0,a0,1
ffffffffc0201fc4:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201fc6:	f675                	bnez	a2,ffffffffc0201fb2 <strncmp+0x2>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201fc8:	4501                	li	a0,0
ffffffffc0201fca:	8082                	ret
ffffffffc0201fcc:	00054503          	lbu	a0,0(a0)
ffffffffc0201fd0:	0005c783          	lbu	a5,0(a1)
ffffffffc0201fd4:	9d1d                	subw	a0,a0,a5
}
ffffffffc0201fd6:	8082                	ret

ffffffffc0201fd8 <strchr>:
 * The strchr() function returns a pointer to the first occurrence of
 * character in @s. If the value is not found, the function returns 'NULL'.
 * */
char *
strchr(const char *s, char c) {
    while (*s != '\0') {
ffffffffc0201fd8:	a021                	j	ffffffffc0201fe0 <strchr+0x8>
        if (*s == c) {
ffffffffc0201fda:	00f58763          	beq	a1,a5,ffffffffc0201fe8 <strchr+0x10>
            return (char *)s;
        }
        s ++;
ffffffffc0201fde:	0505                	addi	a0,a0,1
    while (*s != '\0') {
ffffffffc0201fe0:	00054783          	lbu	a5,0(a0)
ffffffffc0201fe4:	fbfd                	bnez	a5,ffffffffc0201fda <strchr+0x2>
    }
    return NULL;
ffffffffc0201fe6:	4501                	li	a0,0
}
ffffffffc0201fe8:	8082                	ret

ffffffffc0201fea <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc0201fea:	ca01                	beqz	a2,ffffffffc0201ffa <memset+0x10>
ffffffffc0201fec:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc0201fee:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201ff0:	0785                	addi	a5,a5,1
ffffffffc0201ff2:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201ff6:	fef61de3          	bne	a2,a5,ffffffffc0201ff0 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc0201ffa:	8082                	ret
