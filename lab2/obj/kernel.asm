
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
    .globl kern_entry
kern_entry:
    # a0: hartid
    # a1: dtb physical address
    # save hartid and dtb address
    la t0, boot_hartid
ffffffffc0200000:	00006297          	auipc	t0,0x6
ffffffffc0200004:	00028293          	mv	t0,t0
    sd a0, 0(t0)
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0206000 <boot_hartid>
    la t0, boot_dtb
ffffffffc020000c:	00006297          	auipc	t0,0x6
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0206008 <boot_dtb>
    sd a1, 0(t0)
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)

    # t0 := 三级页表的虚拟地址
    lui     t0, %hi(boot_page_table_sv39)
ffffffffc0200018:	c02052b7          	lui	t0,0xc0205
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
ffffffffc020003c:	c0205137          	lui	sp,0xc0205

    # 我们在虚拟内存空间中：随意跳转到虚拟地址！
    # 跳转到 kern_init
    lui t0, %hi(kern_init)
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
    addi t0, t0, %lo(kern_init)
ffffffffc0200044:	0d628293          	addi	t0,t0,214 # ffffffffc02000d6 <kern_init>
    jr t0
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <print_kerninfo>:
/* *
 * print_kerninfo - print the information about kernel, including the location
 * of kernel entry, the start addresses of data and text segements, the start
 * address of free memory and how many memory that kernel has used.
 * */
void print_kerninfo(void) {
ffffffffc020004a:	1141                	addi	sp,sp,-16 # ffffffffc0204ff0 <bootstack+0x1ff0>
    extern char etext[], edata[], end[];
    cprintf("Special kernel symbols:\n");
ffffffffc020004c:	00001517          	auipc	a0,0x1
ffffffffc0200050:	72450513          	addi	a0,a0,1828 # ffffffffc0201770 <etext+0x4>
void print_kerninfo(void) {
ffffffffc0200054:	e406                	sd	ra,8(sp)
    cprintf("Special kernel symbols:\n");
ffffffffc0200056:	0f2000ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("  entry  0x%016lx (virtual)\n", (uintptr_t)kern_init);
ffffffffc020005a:	00000597          	auipc	a1,0x0
ffffffffc020005e:	07c58593          	addi	a1,a1,124 # ffffffffc02000d6 <kern_init>
ffffffffc0200062:	00001517          	auipc	a0,0x1
ffffffffc0200066:	72e50513          	addi	a0,a0,1838 # ffffffffc0201790 <etext+0x24>
ffffffffc020006a:	0de000ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("  etext  0x%016lx (virtual)\n", etext);
ffffffffc020006e:	00001597          	auipc	a1,0x1
ffffffffc0200072:	6fe58593          	addi	a1,a1,1790 # ffffffffc020176c <etext>
ffffffffc0200076:	00001517          	auipc	a0,0x1
ffffffffc020007a:	73a50513          	addi	a0,a0,1850 # ffffffffc02017b0 <etext+0x44>
ffffffffc020007e:	0ca000ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("  edata  0x%016lx (virtual)\n", edata);
ffffffffc0200082:	00006597          	auipc	a1,0x6
ffffffffc0200086:	f9658593          	addi	a1,a1,-106 # ffffffffc0206018 <free_area>
ffffffffc020008a:	00001517          	auipc	a0,0x1
ffffffffc020008e:	74650513          	addi	a0,a0,1862 # ffffffffc02017d0 <etext+0x64>
ffffffffc0200092:	0b6000ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("  end    0x%016lx (virtual)\n", end);
ffffffffc0200096:	00006597          	auipc	a1,0x6
ffffffffc020009a:	13a58593          	addi	a1,a1,314 # ffffffffc02061d0 <end>
ffffffffc020009e:	00001517          	auipc	a0,0x1
ffffffffc02000a2:	75250513          	addi	a0,a0,1874 # ffffffffc02017f0 <etext+0x84>
ffffffffc02000a6:	0a2000ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("Kernel executable memory footprint: %dKB\n",
            (end - (char*)kern_init + 1023) / 1024);
ffffffffc02000aa:	00000717          	auipc	a4,0x0
ffffffffc02000ae:	02c70713          	addi	a4,a4,44 # ffffffffc02000d6 <kern_init>
ffffffffc02000b2:	00006797          	auipc	a5,0x6
ffffffffc02000b6:	51d78793          	addi	a5,a5,1309 # ffffffffc02065cf <end+0x3ff>
ffffffffc02000ba:	8f99                	sub	a5,a5,a4
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000bc:	43f7d593          	srai	a1,a5,0x3f
}
ffffffffc02000c0:	60a2                	ld	ra,8(sp)
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000c2:	3ff5f593          	andi	a1,a1,1023
ffffffffc02000c6:	95be                	add	a1,a1,a5
ffffffffc02000c8:	85a9                	srai	a1,a1,0xa
ffffffffc02000ca:	00001517          	auipc	a0,0x1
ffffffffc02000ce:	74650513          	addi	a0,a0,1862 # ffffffffc0201810 <etext+0xa4>
}
ffffffffc02000d2:	0141                	addi	sp,sp,16
    cprintf("Kernel executable memory footprint: %dKB\n",
ffffffffc02000d4:	a895                	j	ffffffffc0200148 <cprintf>

ffffffffc02000d6 <kern_init>:

int kern_init(void) {
    extern char edata[], end[];
    memset(edata, 0, end - edata);
ffffffffc02000d6:	00006517          	auipc	a0,0x6
ffffffffc02000da:	f4250513          	addi	a0,a0,-190 # ffffffffc0206018 <free_area>
ffffffffc02000de:	00006617          	auipc	a2,0x6
ffffffffc02000e2:	0f260613          	addi	a2,a2,242 # ffffffffc02061d0 <end>
int kern_init(void) {
ffffffffc02000e6:	1141                	addi	sp,sp,-16
    memset(edata, 0, end - edata);
ffffffffc02000e8:	8e09                	sub	a2,a2,a0
ffffffffc02000ea:	4581                	li	a1,0
int kern_init(void) {
ffffffffc02000ec:	e406                	sd	ra,8(sp)
    memset(edata, 0, end - edata);
ffffffffc02000ee:	66c010ef          	jal	ffffffffc020175a <memset>
    dtb_init();
ffffffffc02000f2:	136000ef          	jal	ffffffffc0200228 <dtb_init>
    cons_init();  // init the console
ffffffffc02000f6:	128000ef          	jal	ffffffffc020021e <cons_init>
    const char *message = "(THU.CST) os is loading ...\0";
    //cprintf("%s\n\n", message);
    cputs(message);
ffffffffc02000fa:	00002517          	auipc	a0,0x2
ffffffffc02000fe:	24650513          	addi	a0,a0,582 # ffffffffc0202340 <etext+0xbd4>
ffffffffc0200102:	07a000ef          	jal	ffffffffc020017c <cputs>

    print_kerninfo();
ffffffffc0200106:	f45ff0ef          	jal	ffffffffc020004a <print_kerninfo>

    // grade_backtrace();
    pmm_init();  // init physical memory management
ffffffffc020010a:	006010ef          	jal	ffffffffc0201110 <pmm_init>

    /* do nothing */
    while (1)
ffffffffc020010e:	a001                	j	ffffffffc020010e <kern_init+0x38>

ffffffffc0200110 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
ffffffffc0200110:	1101                	addi	sp,sp,-32
ffffffffc0200112:	ec06                	sd	ra,24(sp)
ffffffffc0200114:	e42e                	sd	a1,8(sp)
    cons_putc(c);
ffffffffc0200116:	10a000ef          	jal	ffffffffc0200220 <cons_putc>
    (*cnt) ++;
ffffffffc020011a:	65a2                	ld	a1,8(sp)
}
ffffffffc020011c:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
ffffffffc020011e:	419c                	lw	a5,0(a1)
ffffffffc0200120:	2785                	addiw	a5,a5,1
ffffffffc0200122:	c19c                	sw	a5,0(a1)
}
ffffffffc0200124:	6105                	addi	sp,sp,32
ffffffffc0200126:	8082                	ret

ffffffffc0200128 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200128:	1101                	addi	sp,sp,-32
ffffffffc020012a:	862a                	mv	a2,a0
ffffffffc020012c:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020012e:	00000517          	auipc	a0,0x0
ffffffffc0200132:	fe250513          	addi	a0,a0,-30 # ffffffffc0200110 <cputch>
ffffffffc0200136:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
ffffffffc0200138:	ec06                	sd	ra,24(sp)
    int cnt = 0;
ffffffffc020013a:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc020013c:	20e010ef          	jal	ffffffffc020134a <vprintfmt>
    return cnt;
}
ffffffffc0200140:	60e2                	ld	ra,24(sp)
ffffffffc0200142:	4532                	lw	a0,12(sp)
ffffffffc0200144:	6105                	addi	sp,sp,32
ffffffffc0200146:	8082                	ret

ffffffffc0200148 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
ffffffffc0200148:	711d                	addi	sp,sp,-96
    va_list ap;
    int cnt;
    va_start(ap, fmt);
ffffffffc020014a:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
ffffffffc020014e:	f42e                	sd	a1,40(sp)
ffffffffc0200150:	f832                	sd	a2,48(sp)
ffffffffc0200152:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200154:	862a                	mv	a2,a0
ffffffffc0200156:	004c                	addi	a1,sp,4
ffffffffc0200158:	00000517          	auipc	a0,0x0
ffffffffc020015c:	fb850513          	addi	a0,a0,-72 # ffffffffc0200110 <cputch>
ffffffffc0200160:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
ffffffffc0200162:	ec06                	sd	ra,24(sp)
ffffffffc0200164:	e0ba                	sd	a4,64(sp)
ffffffffc0200166:	e4be                	sd	a5,72(sp)
ffffffffc0200168:	e8c2                	sd	a6,80(sp)
ffffffffc020016a:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
ffffffffc020016c:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
ffffffffc020016e:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
ffffffffc0200170:	1da010ef          	jal	ffffffffc020134a <vprintfmt>
    cnt = vcprintf(fmt, ap);
    va_end(ap);
    return cnt;
}
ffffffffc0200174:	60e2                	ld	ra,24(sp)
ffffffffc0200176:	4512                	lw	a0,4(sp)
ffffffffc0200178:	6125                	addi	sp,sp,96
ffffffffc020017a:	8082                	ret

ffffffffc020017c <cputs>:
/* *
 * cputs- writes the string pointed by @str to stdout and
 * appends a newline character.
 * */
int
cputs(const char *str) {
ffffffffc020017c:	1101                	addi	sp,sp,-32
ffffffffc020017e:	e822                	sd	s0,16(sp)
ffffffffc0200180:	ec06                	sd	ra,24(sp)
ffffffffc0200182:	842a                	mv	s0,a0
    int cnt = 0;
    char c;
    while ((c = *str ++) != '\0') {
ffffffffc0200184:	00054503          	lbu	a0,0(a0)
ffffffffc0200188:	c51d                	beqz	a0,ffffffffc02001b6 <cputs+0x3a>
ffffffffc020018a:	e426                	sd	s1,8(sp)
ffffffffc020018c:	0405                	addi	s0,s0,1
    int cnt = 0;
ffffffffc020018e:	4481                	li	s1,0
    cons_putc(c);
ffffffffc0200190:	090000ef          	jal	ffffffffc0200220 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc0200194:	00044503          	lbu	a0,0(s0)
ffffffffc0200198:	0405                	addi	s0,s0,1
ffffffffc020019a:	87a6                	mv	a5,s1
    (*cnt) ++;
ffffffffc020019c:	2485                	addiw	s1,s1,1
    while ((c = *str ++) != '\0') {
ffffffffc020019e:	f96d                	bnez	a0,ffffffffc0200190 <cputs+0x14>
    cons_putc(c);
ffffffffc02001a0:	4529                	li	a0,10
    (*cnt) ++;
ffffffffc02001a2:	0027841b          	addiw	s0,a5,2
ffffffffc02001a6:	64a2                	ld	s1,8(sp)
    cons_putc(c);
ffffffffc02001a8:	078000ef          	jal	ffffffffc0200220 <cons_putc>
        cputch(c, &cnt);
    }
    cputch('\n', &cnt);
    return cnt;
}
ffffffffc02001ac:	60e2                	ld	ra,24(sp)
ffffffffc02001ae:	8522                	mv	a0,s0
ffffffffc02001b0:	6442                	ld	s0,16(sp)
ffffffffc02001b2:	6105                	addi	sp,sp,32
ffffffffc02001b4:	8082                	ret
    cons_putc(c);
ffffffffc02001b6:	4529                	li	a0,10
ffffffffc02001b8:	068000ef          	jal	ffffffffc0200220 <cons_putc>
    while ((c = *str ++) != '\0') {
ffffffffc02001bc:	4405                	li	s0,1
}
ffffffffc02001be:	60e2                	ld	ra,24(sp)
ffffffffc02001c0:	8522                	mv	a0,s0
ffffffffc02001c2:	6442                	ld	s0,16(sp)
ffffffffc02001c4:	6105                	addi	sp,sp,32
ffffffffc02001c6:	8082                	ret

ffffffffc02001c8 <__panic>:
 * __panic - __panic is called on unresolvable fatal errors. it prints
 * "panic: 'message'", and then enters the kernel monitor.
 * */
void
__panic(const char *file, int line, const char *fmt, ...) {
    if (is_panic) {
ffffffffc02001c8:	00006317          	auipc	t1,0x6
ffffffffc02001cc:	fb832303          	lw	t1,-72(t1) # ffffffffc0206180 <is_panic>
__panic(const char *file, int line, const char *fmt, ...) {
ffffffffc02001d0:	715d                	addi	sp,sp,-80
ffffffffc02001d2:	ec06                	sd	ra,24(sp)
ffffffffc02001d4:	f436                	sd	a3,40(sp)
ffffffffc02001d6:	f83a                	sd	a4,48(sp)
ffffffffc02001d8:	fc3e                	sd	a5,56(sp)
ffffffffc02001da:	e0c2                	sd	a6,64(sp)
ffffffffc02001dc:	e4c6                	sd	a7,72(sp)
    if (is_panic) {
ffffffffc02001de:	00030363          	beqz	t1,ffffffffc02001e4 <__panic+0x1c>
    vcprintf(fmt, ap);
    cprintf("\n");
    va_end(ap);

panic_dead:
    while (1) {
ffffffffc02001e2:	a001                	j	ffffffffc02001e2 <__panic+0x1a>
    is_panic = 1;
ffffffffc02001e4:	4705                	li	a4,1
    va_start(ap, fmt);
ffffffffc02001e6:	103c                	addi	a5,sp,40
ffffffffc02001e8:	e822                	sd	s0,16(sp)
ffffffffc02001ea:	8432                	mv	s0,a2
ffffffffc02001ec:	862e                	mv	a2,a1
ffffffffc02001ee:	85aa                	mv	a1,a0
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc02001f0:	00001517          	auipc	a0,0x1
ffffffffc02001f4:	65050513          	addi	a0,a0,1616 # ffffffffc0201840 <etext+0xd4>
    is_panic = 1;
ffffffffc02001f8:	00006697          	auipc	a3,0x6
ffffffffc02001fc:	f8e6a423          	sw	a4,-120(a3) # ffffffffc0206180 <is_panic>
    va_start(ap, fmt);
ffffffffc0200200:	e43e                	sd	a5,8(sp)
    cprintf("kernel panic at %s:%d:\n    ", file, line);
ffffffffc0200202:	f47ff0ef          	jal	ffffffffc0200148 <cprintf>
    vcprintf(fmt, ap);
ffffffffc0200206:	65a2                	ld	a1,8(sp)
ffffffffc0200208:	8522                	mv	a0,s0
ffffffffc020020a:	f1fff0ef          	jal	ffffffffc0200128 <vcprintf>
    cprintf("\n");
ffffffffc020020e:	00001517          	auipc	a0,0x1
ffffffffc0200212:	65250513          	addi	a0,a0,1618 # ffffffffc0201860 <etext+0xf4>
ffffffffc0200216:	f33ff0ef          	jal	ffffffffc0200148 <cprintf>
ffffffffc020021a:	6442                	ld	s0,16(sp)
ffffffffc020021c:	b7d9                	j	ffffffffc02001e2 <__panic+0x1a>

ffffffffc020021e <cons_init>:

/* serial_intr - try to feed input characters from serial port */
void serial_intr(void) {}

/* cons_init - initializes the console devices */
void cons_init(void) {}
ffffffffc020021e:	8082                	ret

ffffffffc0200220 <cons_putc>:

/* cons_putc - print a single character @c to console devices */
void cons_putc(int c) { sbi_console_putchar((unsigned char)c); }
ffffffffc0200220:	0ff57513          	zext.b	a0,a0
ffffffffc0200224:	48c0106f          	j	ffffffffc02016b0 <sbi_console_putchar>

ffffffffc0200228 <dtb_init>:

// 保存解析出的系统物理内存信息
static uint64_t memory_base = 0;
static uint64_t memory_size = 0;

void dtb_init(void) {
ffffffffc0200228:	7179                	addi	sp,sp,-48
    cprintf("DTB Init\n");
ffffffffc020022a:	00001517          	auipc	a0,0x1
ffffffffc020022e:	63e50513          	addi	a0,a0,1598 # ffffffffc0201868 <etext+0xfc>
void dtb_init(void) {
ffffffffc0200232:	f406                	sd	ra,40(sp)
ffffffffc0200234:	f022                	sd	s0,32(sp)
    cprintf("DTB Init\n");
ffffffffc0200236:	f13ff0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc020023a:	00006597          	auipc	a1,0x6
ffffffffc020023e:	dc65b583          	ld	a1,-570(a1) # ffffffffc0206000 <boot_hartid>
ffffffffc0200242:	00001517          	auipc	a0,0x1
ffffffffc0200246:	63650513          	addi	a0,a0,1590 # ffffffffc0201878 <etext+0x10c>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc020024a:	00006417          	auipc	s0,0x6
ffffffffc020024e:	dbe40413          	addi	s0,s0,-578 # ffffffffc0206008 <boot_dtb>
    cprintf("HartID: %ld\n", boot_hartid);
ffffffffc0200252:	ef7ff0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("DTB Address: 0x%lx\n", boot_dtb);
ffffffffc0200256:	600c                	ld	a1,0(s0)
ffffffffc0200258:	00001517          	auipc	a0,0x1
ffffffffc020025c:	63050513          	addi	a0,a0,1584 # ffffffffc0201888 <etext+0x11c>
ffffffffc0200260:	ee9ff0ef          	jal	ffffffffc0200148 <cprintf>
    
    if (boot_dtb == 0) {
ffffffffc0200264:	6018                	ld	a4,0(s0)
        cprintf("Error: DTB address is null\n");
ffffffffc0200266:	00001517          	auipc	a0,0x1
ffffffffc020026a:	63a50513          	addi	a0,a0,1594 # ffffffffc02018a0 <etext+0x134>
    if (boot_dtb == 0) {
ffffffffc020026e:	10070163          	beqz	a4,ffffffffc0200370 <dtb_init+0x148>
        return;
    }
    
    // 转换为虚拟地址
    uintptr_t dtb_vaddr = boot_dtb + PHYSICAL_MEMORY_OFFSET;
ffffffffc0200272:	57f5                	li	a5,-3
ffffffffc0200274:	07fa                	slli	a5,a5,0x1e
ffffffffc0200276:	973e                	add	a4,a4,a5
    const struct fdt_header *header = (const struct fdt_header *)dtb_vaddr;
    
    // 验证DTB
    uint32_t magic = fdt32_to_cpu(header->magic);
ffffffffc0200278:	431c                	lw	a5,0(a4)
    if (magic != 0xd00dfeed) {
ffffffffc020027a:	d00e06b7          	lui	a3,0xd00e0
ffffffffc020027e:	eed68693          	addi	a3,a3,-275 # ffffffffd00dfeed <end+0xfed9d1d>
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200282:	0087d59b          	srliw	a1,a5,0x8
ffffffffc0200286:	0187961b          	slliw	a2,a5,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020028a:	0187d51b          	srliw	a0,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020028e:	0ff5f593          	zext.b	a1,a1
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200292:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200296:	05c2                	slli	a1,a1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200298:	8e49                	or	a2,a2,a0
ffffffffc020029a:	0ff7f793          	zext.b	a5,a5
ffffffffc020029e:	8dd1                	or	a1,a1,a2
ffffffffc02002a0:	07a2                	slli	a5,a5,0x8
ffffffffc02002a2:	8ddd                	or	a1,a1,a5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002a4:	00ff0837          	lui	a6,0xff0
    if (magic != 0xd00dfeed) {
ffffffffc02002a8:	0cd59863          	bne	a1,a3,ffffffffc0200378 <dtb_init+0x150>
        return;
    }
    
    // 提取内存信息
    uint64_t mem_base, mem_size;
    if (extract_memory_info(dtb_vaddr, header, &mem_base, &mem_size) == 0) {
ffffffffc02002ac:	4710                	lw	a2,8(a4)
ffffffffc02002ae:	4754                	lw	a3,12(a4)
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc02002b0:	e84a                	sd	s2,16(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002b2:	0086541b          	srliw	s0,a2,0x8
ffffffffc02002b6:	0086d79b          	srliw	a5,a3,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002ba:	01865e1b          	srliw	t3,a2,0x18
ffffffffc02002be:	0186d89b          	srliw	a7,a3,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002c2:	0186151b          	slliw	a0,a2,0x18
ffffffffc02002c6:	0186959b          	slliw	a1,a3,0x18
ffffffffc02002ca:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002ce:	0106561b          	srliw	a2,a2,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002d2:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002d6:	0106d69b          	srliw	a3,a3,0x10
ffffffffc02002da:	01c56533          	or	a0,a0,t3
ffffffffc02002de:	0115e5b3          	or	a1,a1,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002e2:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002e6:	0ff67613          	zext.b	a2,a2
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02002ea:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02002ee:	0ff6f693          	zext.b	a3,a3
ffffffffc02002f2:	8c49                	or	s0,s0,a0
ffffffffc02002f4:	0622                	slli	a2,a2,0x8
ffffffffc02002f6:	8fcd                	or	a5,a5,a1
ffffffffc02002f8:	06a2                	slli	a3,a3,0x8
ffffffffc02002fa:	8c51                	or	s0,s0,a2
ffffffffc02002fc:	8fd5                	or	a5,a5,a3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc02002fe:	1402                	slli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200300:	1782                	slli	a5,a5,0x20
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc0200302:	9001                	srli	s0,s0,0x20
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc0200304:	9381                	srli	a5,a5,0x20
ffffffffc0200306:	ec26                	sd	s1,24(sp)
    int in_memory_node = 0;
ffffffffc0200308:	4301                	li	t1,0
        switch (token) {
ffffffffc020030a:	488d                	li	a7,3
    const uint32_t *struct_ptr = (const uint32_t *)(dtb_vaddr + struct_offset);
ffffffffc020030c:	943a                	add	s0,s0,a4
    const char *strings_base = (const char *)(dtb_vaddr + strings_offset);
ffffffffc020030e:	00e78933          	add	s2,a5,a4
        switch (token) {
ffffffffc0200312:	4e05                	li	t3,1
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200314:	4018                	lw	a4,0(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200316:	0087579b          	srliw	a5,a4,0x8
ffffffffc020031a:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020031e:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200322:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200326:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020032a:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020032e:	8ed1                	or	a3,a3,a2
ffffffffc0200330:	0ff77713          	zext.b	a4,a4
ffffffffc0200334:	8fd5                	or	a5,a5,a3
ffffffffc0200336:	0722                	slli	a4,a4,0x8
ffffffffc0200338:	8fd9                	or	a5,a5,a4
        switch (token) {
ffffffffc020033a:	05178763          	beq	a5,a7,ffffffffc0200388 <dtb_init+0x160>
        uint32_t token = fdt32_to_cpu(*struct_ptr++);
ffffffffc020033e:	0411                	addi	s0,s0,4
        switch (token) {
ffffffffc0200340:	00f8e963          	bltu	a7,a5,ffffffffc0200352 <dtb_init+0x12a>
ffffffffc0200344:	07c78d63          	beq	a5,t3,ffffffffc02003be <dtb_init+0x196>
ffffffffc0200348:	4709                	li	a4,2
ffffffffc020034a:	00e79763          	bne	a5,a4,ffffffffc0200358 <dtb_init+0x130>
ffffffffc020034e:	4301                	li	t1,0
ffffffffc0200350:	b7d1                	j	ffffffffc0200314 <dtb_init+0xec>
ffffffffc0200352:	4711                	li	a4,4
ffffffffc0200354:	fce780e3          	beq	a5,a4,ffffffffc0200314 <dtb_init+0xec>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
        // 保存到全局变量，供 PMM 查询
        memory_base = mem_base;
        memory_size = mem_size;
    } else {
        cprintf("Warning: Could not extract memory info from DTB\n");
ffffffffc0200358:	00001517          	auipc	a0,0x1
ffffffffc020035c:	61050513          	addi	a0,a0,1552 # ffffffffc0201968 <etext+0x1fc>
ffffffffc0200360:	de9ff0ef          	jal	ffffffffc0200148 <cprintf>
    }
    cprintf("DTB init completed\n");
ffffffffc0200364:	64e2                	ld	s1,24(sp)
ffffffffc0200366:	6942                	ld	s2,16(sp)
ffffffffc0200368:	00001517          	auipc	a0,0x1
ffffffffc020036c:	63850513          	addi	a0,a0,1592 # ffffffffc02019a0 <etext+0x234>
}
ffffffffc0200370:	7402                	ld	s0,32(sp)
ffffffffc0200372:	70a2                	ld	ra,40(sp)
ffffffffc0200374:	6145                	addi	sp,sp,48
    cprintf("DTB init completed\n");
ffffffffc0200376:	bbc9                	j	ffffffffc0200148 <cprintf>
}
ffffffffc0200378:	7402                	ld	s0,32(sp)
ffffffffc020037a:	70a2                	ld	ra,40(sp)
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc020037c:	00001517          	auipc	a0,0x1
ffffffffc0200380:	54450513          	addi	a0,a0,1348 # ffffffffc02018c0 <etext+0x154>
}
ffffffffc0200384:	6145                	addi	sp,sp,48
        cprintf("Error: Invalid DTB magic number: 0x%x\n", magic);
ffffffffc0200386:	b3c9                	j	ffffffffc0200148 <cprintf>
                uint32_t prop_len = fdt32_to_cpu(*struct_ptr++);
ffffffffc0200388:	4058                	lw	a4,4(s0)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020038a:	0087579b          	srliw	a5,a4,0x8
ffffffffc020038e:	0187169b          	slliw	a3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200392:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200396:	0107979b          	slliw	a5,a5,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020039a:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020039e:	0107f7b3          	and	a5,a5,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02003a2:	8ed1                	or	a3,a3,a2
ffffffffc02003a4:	0ff77713          	zext.b	a4,a4
ffffffffc02003a8:	8fd5                	or	a5,a5,a3
ffffffffc02003aa:	0722                	slli	a4,a4,0x8
ffffffffc02003ac:	8fd9                	or	a5,a5,a4
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02003ae:	04031463          	bnez	t1,ffffffffc02003f6 <dtb_init+0x1ce>
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + prop_len + 3) & ~3);
ffffffffc02003b2:	1782                	slli	a5,a5,0x20
ffffffffc02003b4:	9381                	srli	a5,a5,0x20
ffffffffc02003b6:	043d                	addi	s0,s0,15
ffffffffc02003b8:	943e                	add	s0,s0,a5
ffffffffc02003ba:	9871                	andi	s0,s0,-4
                break;
ffffffffc02003bc:	bfa1                	j	ffffffffc0200314 <dtb_init+0xec>
                int name_len = strlen(name);
ffffffffc02003be:	8522                	mv	a0,s0
ffffffffc02003c0:	e01a                	sd	t1,0(sp)
ffffffffc02003c2:	308010ef          	jal	ffffffffc02016ca <strlen>
ffffffffc02003c6:	84aa                	mv	s1,a0
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003c8:	4619                	li	a2,6
ffffffffc02003ca:	8522                	mv	a0,s0
ffffffffc02003cc:	00001597          	auipc	a1,0x1
ffffffffc02003d0:	51c58593          	addi	a1,a1,1308 # ffffffffc02018e8 <etext+0x17c>
ffffffffc02003d4:	35e010ef          	jal	ffffffffc0201732 <strncmp>
ffffffffc02003d8:	6302                	ld	t1,0(sp)
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02003da:	0411                	addi	s0,s0,4
ffffffffc02003dc:	0004879b          	sext.w	a5,s1
ffffffffc02003e0:	943e                	add	s0,s0,a5
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003e2:	00153513          	seqz	a0,a0
                struct_ptr = (const uint32_t *)(((uintptr_t)struct_ptr + name_len + 4) & ~3);
ffffffffc02003e6:	9871                	andi	s0,s0,-4
                if (strncmp(name, "memory", 6) == 0) {
ffffffffc02003e8:	00a36333          	or	t1,t1,a0
                break;
ffffffffc02003ec:	00ff0837          	lui	a6,0xff0
ffffffffc02003f0:	488d                	li	a7,3
ffffffffc02003f2:	4e05                	li	t3,1
ffffffffc02003f4:	b705                	j	ffffffffc0200314 <dtb_init+0xec>
                uint32_t prop_nameoff = fdt32_to_cpu(*struct_ptr++);
ffffffffc02003f6:	4418                	lw	a4,8(s0)
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc02003f8:	00001597          	auipc	a1,0x1
ffffffffc02003fc:	4f858593          	addi	a1,a1,1272 # ffffffffc02018f0 <etext+0x184>
ffffffffc0200400:	e43e                	sd	a5,8(sp)
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200402:	0087551b          	srliw	a0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200406:	0187561b          	srliw	a2,a4,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020040a:	0187169b          	slliw	a3,a4,0x18
ffffffffc020040e:	0105151b          	slliw	a0,a0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200412:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200416:	01057533          	and	a0,a0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020041a:	8ed1                	or	a3,a3,a2
ffffffffc020041c:	0ff77713          	zext.b	a4,a4
ffffffffc0200420:	0722                	slli	a4,a4,0x8
ffffffffc0200422:	8d55                	or	a0,a0,a3
ffffffffc0200424:	8d59                	or	a0,a0,a4
                const char *prop_name = strings_base + prop_nameoff;
ffffffffc0200426:	1502                	slli	a0,a0,0x20
ffffffffc0200428:	9101                	srli	a0,a0,0x20
                if (in_memory_node && strcmp(prop_name, "reg") == 0 && prop_len >= 16) {
ffffffffc020042a:	954a                	add	a0,a0,s2
ffffffffc020042c:	e01a                	sd	t1,0(sp)
ffffffffc020042e:	2d0010ef          	jal	ffffffffc02016fe <strcmp>
ffffffffc0200432:	67a2                	ld	a5,8(sp)
ffffffffc0200434:	473d                	li	a4,15
ffffffffc0200436:	6302                	ld	t1,0(sp)
ffffffffc0200438:	00ff0837          	lui	a6,0xff0
ffffffffc020043c:	488d                	li	a7,3
ffffffffc020043e:	4e05                	li	t3,1
ffffffffc0200440:	f6f779e3          	bgeu	a4,a5,ffffffffc02003b2 <dtb_init+0x18a>
ffffffffc0200444:	f53d                	bnez	a0,ffffffffc02003b2 <dtb_init+0x18a>
                    *mem_base = fdt64_to_cpu(reg_data[0]);
ffffffffc0200446:	00c43683          	ld	a3,12(s0)
                    *mem_size = fdt64_to_cpu(reg_data[1]);
ffffffffc020044a:	01443703          	ld	a4,20(s0)
        cprintf("Physical Memory from DTB:\n");
ffffffffc020044e:	00001517          	auipc	a0,0x1
ffffffffc0200452:	4aa50513          	addi	a0,a0,1194 # ffffffffc02018f8 <etext+0x18c>
           fdt32_to_cpu(x >> 32);
ffffffffc0200456:	4206d793          	srai	a5,a3,0x20
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020045a:	0087d31b          	srliw	t1,a5,0x8
ffffffffc020045e:	00871f93          	slli	t6,a4,0x8
           fdt32_to_cpu(x >> 32);
ffffffffc0200462:	42075893          	srai	a7,a4,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200466:	0187df1b          	srliw	t5,a5,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020046a:	0187959b          	slliw	a1,a5,0x18
ffffffffc020046e:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200472:	0107d79b          	srliw	a5,a5,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200476:	420fd613          	srai	a2,t6,0x20
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc020047a:	0188de9b          	srliw	t4,a7,0x18
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc020047e:	01037333          	and	t1,t1,a6
ffffffffc0200482:	01889e1b          	slliw	t3,a7,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc0200486:	01e5e5b3          	or	a1,a1,t5
ffffffffc020048a:	0ff7f793          	zext.b	a5,a5
ffffffffc020048e:	01de6e33          	or	t3,t3,t4
ffffffffc0200492:	0065e5b3          	or	a1,a1,t1
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc0200496:	01067633          	and	a2,a2,a6
ffffffffc020049a:	0086d31b          	srliw	t1,a3,0x8
ffffffffc020049e:	0087541b          	srliw	s0,a4,0x8
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004a2:	07a2                	slli	a5,a5,0x8
ffffffffc02004a4:	0108d89b          	srliw	a7,a7,0x10
ffffffffc02004a8:	0186df1b          	srliw	t5,a3,0x18
ffffffffc02004ac:	01875e9b          	srliw	t4,a4,0x18
ffffffffc02004b0:	8ddd                	or	a1,a1,a5
ffffffffc02004b2:	01c66633          	or	a2,a2,t3
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004b6:	0186979b          	slliw	a5,a3,0x18
ffffffffc02004ba:	01871e1b          	slliw	t3,a4,0x18
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004be:	0ff8f893          	zext.b	a7,a7
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004c2:	0103131b          	slliw	t1,t1,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004c6:	0106d69b          	srliw	a3,a3,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004ca:	0104141b          	slliw	s0,s0,0x10
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004ce:	0107571b          	srliw	a4,a4,0x10
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004d2:	01037333          	and	t1,t1,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004d6:	08a2                	slli	a7,a7,0x8
ffffffffc02004d8:	01e7e7b3          	or	a5,a5,t5
    return ((x & 0xff) << 24) | (((x >> 8) & 0xff) << 16) | 
ffffffffc02004dc:	01047433          	and	s0,s0,a6
           (((x >> 16) & 0xff) << 8) | ((x >> 24) & 0xff);
ffffffffc02004e0:	0ff6f693          	zext.b	a3,a3
ffffffffc02004e4:	01de6833          	or	a6,t3,t4
ffffffffc02004e8:	0ff77713          	zext.b	a4,a4
ffffffffc02004ec:	01166633          	or	a2,a2,a7
ffffffffc02004f0:	0067e7b3          	or	a5,a5,t1
ffffffffc02004f4:	06a2                	slli	a3,a3,0x8
ffffffffc02004f6:	01046433          	or	s0,s0,a6
ffffffffc02004fa:	0722                	slli	a4,a4,0x8
ffffffffc02004fc:	8fd5                	or	a5,a5,a3
ffffffffc02004fe:	8c59                	or	s0,s0,a4
           fdt32_to_cpu(x >> 32);
ffffffffc0200500:	1582                	slli	a1,a1,0x20
ffffffffc0200502:	1602                	slli	a2,a2,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc0200504:	1782                	slli	a5,a5,0x20
           fdt32_to_cpu(x >> 32);
ffffffffc0200506:	9201                	srli	a2,a2,0x20
ffffffffc0200508:	9181                	srli	a1,a1,0x20
    return ((uint64_t)fdt32_to_cpu(x & 0xffffffff) << 32) | 
ffffffffc020050a:	1402                	slli	s0,s0,0x20
ffffffffc020050c:	00b7e4b3          	or	s1,a5,a1
ffffffffc0200510:	8c51                	or	s0,s0,a2
        cprintf("Physical Memory from DTB:\n");
ffffffffc0200512:	c37ff0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("  Base: 0x%016lx\n", mem_base);
ffffffffc0200516:	85a6                	mv	a1,s1
ffffffffc0200518:	00001517          	auipc	a0,0x1
ffffffffc020051c:	40050513          	addi	a0,a0,1024 # ffffffffc0201918 <etext+0x1ac>
ffffffffc0200520:	c29ff0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("  Size: 0x%016lx (%ld MB)\n", mem_size, mem_size / (1024 * 1024));
ffffffffc0200524:	01445613          	srli	a2,s0,0x14
ffffffffc0200528:	85a2                	mv	a1,s0
ffffffffc020052a:	00001517          	auipc	a0,0x1
ffffffffc020052e:	40650513          	addi	a0,a0,1030 # ffffffffc0201930 <etext+0x1c4>
ffffffffc0200532:	c17ff0ef          	jal	ffffffffc0200148 <cprintf>
        cprintf("  End:  0x%016lx\n", mem_base + mem_size - 1);
ffffffffc0200536:	009405b3          	add	a1,s0,s1
ffffffffc020053a:	15fd                	addi	a1,a1,-1
ffffffffc020053c:	00001517          	auipc	a0,0x1
ffffffffc0200540:	41450513          	addi	a0,a0,1044 # ffffffffc0201950 <etext+0x1e4>
ffffffffc0200544:	c05ff0ef          	jal	ffffffffc0200148 <cprintf>
        memory_base = mem_base;
ffffffffc0200548:	00006797          	auipc	a5,0x6
ffffffffc020054c:	c497b423          	sd	s1,-952(a5) # ffffffffc0206190 <memory_base>
        memory_size = mem_size;
ffffffffc0200550:	00006797          	auipc	a5,0x6
ffffffffc0200554:	c287bc23          	sd	s0,-968(a5) # ffffffffc0206188 <memory_size>
ffffffffc0200558:	b531                	j	ffffffffc0200364 <dtb_init+0x13c>

ffffffffc020055a <get_memory_base>:

uint64_t get_memory_base(void) {
    return memory_base;
}
ffffffffc020055a:	00006517          	auipc	a0,0x6
ffffffffc020055e:	c3653503          	ld	a0,-970(a0) # ffffffffc0206190 <memory_base>
ffffffffc0200562:	8082                	ret

ffffffffc0200564 <get_memory_size>:

uint64_t get_memory_size(void) {
    return memory_size;
ffffffffc0200564:	00006517          	auipc	a0,0x6
ffffffffc0200568:	c2453503          	ld	a0,-988(a0) # ffffffffc0206188 <memory_size>
ffffffffc020056c:	8082                	ret

ffffffffc020056e <buddy_system_init>:
    return 0;
}
static size_t total_nr_free;
static void
buddy_system_init(void) {
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc020056e:	00006797          	auipc	a5,0x6
ffffffffc0200572:	aaa78793          	addi	a5,a5,-1366 # ffffffffc0206018 <free_area>
ffffffffc0200576:	00006717          	auipc	a4,0x6
ffffffffc020057a:	c0a70713          	addi	a4,a4,-1014 # ffffffffc0206180 <is_panic>
 * list_init - initialize a new entry
 * @elm:        new entry to be initialized
 * */
static inline void
list_init(list_entry_t *elm) {
    elm->prev = elm->next = elm;
ffffffffc020057e:	e79c                	sd	a5,8(a5)
ffffffffc0200580:	e39c                	sd	a5,0(a5)
        list_init(&free_list(i));
        nr_free(i) = 0;
ffffffffc0200582:	0007a823          	sw	zero,16(a5)
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200586:	07e1                	addi	a5,a5,24
ffffffffc0200588:	fee79be3          	bne	a5,a4,ffffffffc020057e <buddy_system_init+0x10>
    }
    total_nr_free = 0;
ffffffffc020058c:	00006797          	auipc	a5,0x6
ffffffffc0200590:	c007b623          	sd	zero,-1012(a5) # ffffffffc0206198 <total_nr_free>
}
ffffffffc0200594:	8082                	ret

ffffffffc0200596 <buddy_system_nr_free_pages>:
}

static size_t
buddy_system_nr_free_pages(void) {
    return total_nr_free;
}
ffffffffc0200596:	00006517          	auipc	a0,0x6
ffffffffc020059a:	c0253503          	ld	a0,-1022(a0) # ffffffffc0206198 <total_nr_free>
ffffffffc020059e:	8082                	ret

ffffffffc02005a0 <print_buddy_system_status>:
//借助AI生成的验证函数
static void print_buddy_system_status(void) {
ffffffffc02005a0:	1101                	addi	sp,sp,-32
    cprintf("  [Buddy Status] nr_free per order:\n");
ffffffffc02005a2:	00001517          	auipc	a0,0x1
ffffffffc02005a6:	41650513          	addi	a0,a0,1046 # ffffffffc02019b8 <etext+0x24c>
static void print_buddy_system_status(void) {
ffffffffc02005aa:	e822                	sd	s0,16(sp)
ffffffffc02005ac:	e426                	sd	s1,8(sp)
ffffffffc02005ae:	e04a                	sd	s2,0(sp)
ffffffffc02005b0:	ec06                	sd	ra,24(sp)
ffffffffc02005b2:	00006497          	auipc	s1,0x6
ffffffffc02005b6:	a7648493          	addi	s1,s1,-1418 # ffffffffc0206028 <free_area+0x10>
    cprintf("  [Buddy Status] nr_free per order:\n");
ffffffffc02005ba:	b8fff0ef          	jal	ffffffffc0200148 <cprintf>
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc02005be:	4401                	li	s0,0
ffffffffc02005c0:	493d                	li	s2,15
ffffffffc02005c2:	a029                	j	ffffffffc02005cc <print_buddy_system_status+0x2c>
ffffffffc02005c4:	2405                	addiw	s0,s0,1
ffffffffc02005c6:	04e1                	addi	s1,s1,24
ffffffffc02005c8:	01240f63          	beq	s0,s2,ffffffffc02005e6 <print_buddy_system_status+0x46>
        if (nr_free(i) > 0) {
ffffffffc02005cc:	4090                	lw	a2,0(s1)
ffffffffc02005ce:	da7d                	beqz	a2,ffffffffc02005c4 <print_buddy_system_status+0x24>
            cprintf("    order-%-2d: %u\n", i, nr_free(i));
ffffffffc02005d0:	85a2                	mv	a1,s0
ffffffffc02005d2:	00001517          	auipc	a0,0x1
ffffffffc02005d6:	40e50513          	addi	a0,a0,1038 # ffffffffc02019e0 <etext+0x274>
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc02005da:	2405                	addiw	s0,s0,1
            cprintf("    order-%-2d: %u\n", i, nr_free(i));
ffffffffc02005dc:	b6dff0ef          	jal	ffffffffc0200148 <cprintf>
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc02005e0:	04e1                	addi	s1,s1,24
ffffffffc02005e2:	ff2415e3          	bne	s0,s2,ffffffffc02005cc <print_buddy_system_status+0x2c>
        }
    }
    cprintf("  Total free pages: %u\n", total_nr_free);
}
ffffffffc02005e6:	6442                	ld	s0,16(sp)
ffffffffc02005e8:	60e2                	ld	ra,24(sp)
ffffffffc02005ea:	64a2                	ld	s1,8(sp)
ffffffffc02005ec:	6902                	ld	s2,0(sp)
    cprintf("  Total free pages: %u\n", total_nr_free);
ffffffffc02005ee:	00006597          	auipc	a1,0x6
ffffffffc02005f2:	baa5b583          	ld	a1,-1110(a1) # ffffffffc0206198 <total_nr_free>
ffffffffc02005f6:	00001517          	auipc	a0,0x1
ffffffffc02005fa:	40250513          	addi	a0,a0,1026 # ffffffffc02019f8 <etext+0x28c>
}
ffffffffc02005fe:	6105                	addi	sp,sp,32
    cprintf("  Total free pages: %u\n", total_nr_free);
ffffffffc0200600:	b6a1                	j	ffffffffc0200148 <cprintf>

ffffffffc0200602 <buddy_system_init_memmap>:
buddy_system_init_memmap(struct Page *base, size_t n) {
ffffffffc0200602:	1141                	addi	sp,sp,-16
ffffffffc0200604:	e406                	sd	ra,8(sp)
ffffffffc0200606:	e022                	sd	s0,0(sp)
    assert(n > 0);
ffffffffc0200608:	10058d63          	beqz	a1,ffffffffc0200722 <buddy_system_init_memmap+0x120>
    for (struct Page *p = base; p < base + n; p++) {
ffffffffc020060c:	00259693          	slli	a3,a1,0x2
ffffffffc0200610:	96ae                	add	a3,a3,a1
ffffffffc0200612:	068e                	slli	a3,a3,0x3
ffffffffc0200614:	96aa                	add	a3,a3,a0
ffffffffc0200616:	87aa                	mv	a5,a0
ffffffffc0200618:	00d57d63          	bgeu	a0,a3,ffffffffc0200632 <buddy_system_init_memmap+0x30>
        assert(PageReserved(p));
ffffffffc020061c:	6798                	ld	a4,8(a5)
ffffffffc020061e:	8b05                	andi	a4,a4,1
ffffffffc0200620:	c36d                	beqz	a4,ffffffffc0200702 <buddy_system_init_memmap+0x100>
        p->flags = 0;
ffffffffc0200622:	0007b423          	sd	zero,8(a5)



static inline int page_ref(struct Page *page) { return page->ref; }

static inline void set_page_ref(struct Page *page, int val) { page->ref = val; }
ffffffffc0200626:	0007a023          	sw	zero,0(a5)
    for (struct Page *p = base; p < base + n; p++) {
ffffffffc020062a:	02878793          	addi	a5,a5,40
ffffffffc020062e:	fed7e7e3          	bltu	a5,a3,ffffffffc020061c <buddy_system_init_memmap+0x1a>
            if (((current_page - pages) % block_size) == 0) {
ffffffffc0200632:	ccccd7b7          	lui	a5,0xccccd
ffffffffc0200636:	ccd78793          	addi	a5,a5,-819 # ffffffffcccccccd <end+0xcac6afd>
ffffffffc020063a:	00006397          	auipc	t2,0x6
ffffffffc020063e:	b8e3b383          	ld	t2,-1138(t2) # ffffffffc02061c8 <pages>
ffffffffc0200642:	00006f17          	auipc	t5,0x6
ffffffffc0200646:	b56f3f03          	ld	t5,-1194(t5) # ffffffffc0206198 <total_nr_free>
ffffffffc020064a:	02079293          	slli	t0,a5,0x20
ffffffffc020064e:	92be                	add	t0,t0,a5
    size_t current_pos = 0;
ffffffffc0200650:	4e81                	li	t4,0
ffffffffc0200652:	00006f97          	auipc	t6,0x6
ffffffffc0200656:	9c6f8f93          	addi	t6,t6,-1594 # ffffffffc0206018 <free_area>
            size_t block_size = ORDER2SIZE(order);
ffffffffc020065a:	4305                	li	t1,1
        for (int order = MAX_ORDER; order >= 0; order--) {
ffffffffc020065c:	5e7d                	li	t3,-1
        struct Page *current_page = base + current_pos;
ffffffffc020065e:	002e9813          	slli	a6,t4,0x2
ffffffffc0200662:	9876                	add	a6,a6,t4
ffffffffc0200664:	080e                	slli	a6,a6,0x3
ffffffffc0200666:	982a                	add	a6,a6,a0
            if (((current_page - pages) % block_size) == 0) {
ffffffffc0200668:	40780633          	sub	a2,a6,t2
ffffffffc020066c:	860d                	srai	a2,a2,0x3
ffffffffc020066e:	02560633          	mul	a2,a2,t0
        for (int order = MAX_ORDER; order >= 0; order--) {
ffffffffc0200672:	4739                	li	a4,14
            size_t block_size = ORDER2SIZE(order);
ffffffffc0200674:	00e316bb          	sllw	a3,t1,a4
            if (((current_page - pages) % block_size) == 0) {
ffffffffc0200678:	fff6879b          	addiw	a5,a3,-1
ffffffffc020067c:	1782                	slli	a5,a5,0x20
ffffffffc020067e:	9381                	srli	a5,a5,0x20
ffffffffc0200680:	8ff1                	and	a5,a5,a2
ffffffffc0200682:	e799                	bnez	a5,ffffffffc0200690 <buddy_system_init_memmap+0x8e>
            size_t block_size = ORDER2SIZE(order);
ffffffffc0200684:	1682                	slli	a3,a3,0x20
ffffffffc0200686:	9281                	srli	a3,a3,0x20
                if (current_pos + block_size <= n) {
ffffffffc0200688:	01d688b3          	add	a7,a3,t4
ffffffffc020068c:	0715f263          	bgeu	a1,a7,ffffffffc02006f0 <buddy_system_init_memmap+0xee>
        for (int order = MAX_ORDER; order >= 0; order--) {
ffffffffc0200690:	377d                	addiw	a4,a4,-1
ffffffffc0200692:	ffc711e3          	bne	a4,t3,ffffffffc0200674 <buddy_system_init_memmap+0x72>
        current_pos += block_size;
ffffffffc0200696:	0e85                	addi	t4,t4,1
ffffffffc0200698:	00006617          	auipc	a2,0x6
ffffffffc020069c:	98060613          	addi	a2,a2,-1664 # ffffffffc0206018 <free_area>
ffffffffc02006a0:	4401                	li	s0,0
ffffffffc02006a2:	4685                	li	a3,1
        int max_possible_order = 0;
ffffffffc02006a4:	4701                	li	a4,0
ffffffffc02006a6:	4781                	li	a5,0
 * Insert the new element @elm *after* the element @listelm which
 * is already in the list.
 * */
static inline void
list_add_after(list_entry_t *listelm, list_entry_t *elm) {
    __list_add(elm, listelm, listelm->next);
ffffffffc02006a8:	97ba                	add	a5,a5,a4
ffffffffc02006aa:	078e                	slli	a5,a5,0x3
        SetPageProperty(current_page);
ffffffffc02006ac:	00883703          	ld	a4,8(a6) # ff0008 <kern_entry-0xffffffffbf20fff8>
ffffffffc02006b0:	97fe                	add	a5,a5,t6
ffffffffc02006b2:	0087b883          	ld	a7,8(a5)
ffffffffc02006b6:	00276713          	ori	a4,a4,2
        current_page->property = max_possible_order;
ffffffffc02006ba:	00882823          	sw	s0,16(a6)
        SetPageProperty(current_page);
ffffffffc02006be:	00e83423          	sd	a4,8(a6)
        list_add(&free_list(max_possible_order), &(current_page->page_link));
ffffffffc02006c2:	01880413          	addi	s0,a6,24
        nr_free(max_possible_order)++;
ffffffffc02006c6:	4b98                	lw	a4,16(a5)
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_add(list_entry_t *elm, list_entry_t *prev, list_entry_t *next) {
    prev->next = next->prev = elm;
ffffffffc02006c8:	0088b023          	sd	s0,0(a7)
ffffffffc02006cc:	e780                	sd	s0,8(a5)
    elm->next = next;
ffffffffc02006ce:	03183023          	sd	a7,32(a6)
    elm->prev = prev;
ffffffffc02006d2:	00c83c23          	sd	a2,24(a6)
ffffffffc02006d6:	2705                	addiw	a4,a4,1
ffffffffc02006d8:	cb98                	sw	a4,16(a5)
        total_nr_free += block_size;
ffffffffc02006da:	9f36                	add	t5,t5,a3
    while (current_pos < n) {
ffffffffc02006dc:	f8bee1e3          	bltu	t4,a1,ffffffffc020065e <buddy_system_init_memmap+0x5c>
}
ffffffffc02006e0:	60a2                	ld	ra,8(sp)
ffffffffc02006e2:	6402                	ld	s0,0(sp)
ffffffffc02006e4:	00006797          	auipc	a5,0x6
ffffffffc02006e8:	abe7ba23          	sd	t5,-1356(a5) # ffffffffc0206198 <total_nr_free>
ffffffffc02006ec:	0141                	addi	sp,sp,16
ffffffffc02006ee:	8082                	ret
        list_add(&free_list(max_possible_order), &(current_page->page_link));
ffffffffc02006f0:	00171793          	slli	a5,a4,0x1
ffffffffc02006f4:	00e78633          	add	a2,a5,a4
ffffffffc02006f8:	060e                	slli	a2,a2,0x3
ffffffffc02006fa:	8ec6                	mv	t4,a7
ffffffffc02006fc:	967e                	add	a2,a2,t6
        current_page->property = max_possible_order;
ffffffffc02006fe:	843a                	mv	s0,a4
ffffffffc0200700:	b765                	j	ffffffffc02006a8 <buddy_system_init_memmap+0xa6>
        assert(PageReserved(p));
ffffffffc0200702:	00001697          	auipc	a3,0x1
ffffffffc0200706:	34668693          	addi	a3,a3,838 # ffffffffc0201a48 <etext+0x2dc>
ffffffffc020070a:	00001617          	auipc	a2,0x1
ffffffffc020070e:	30e60613          	addi	a2,a2,782 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc0200712:	03f00593          	li	a1,63
ffffffffc0200716:	00001517          	auipc	a0,0x1
ffffffffc020071a:	31a50513          	addi	a0,a0,794 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc020071e:	aabff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(n > 0);
ffffffffc0200722:	00001697          	auipc	a3,0x1
ffffffffc0200726:	2ee68693          	addi	a3,a3,750 # ffffffffc0201a10 <etext+0x2a4>
ffffffffc020072a:	00001617          	auipc	a2,0x1
ffffffffc020072e:	2ee60613          	addi	a2,a2,750 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc0200732:	03b00593          	li	a1,59
ffffffffc0200736:	00001517          	auipc	a0,0x1
ffffffffc020073a:	2fa50513          	addi	a0,a0,762 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc020073e:	a8bff0ef          	jal	ffffffffc02001c8 <__panic>

ffffffffc0200742 <buddy_system_free_pages>:
buddy_system_free_pages(struct Page *base, size_t n) {
ffffffffc0200742:	1141                	addi	sp,sp,-16
ffffffffc0200744:	e406                	sd	ra,8(sp)
    assert(n > 0);
ffffffffc0200746:	12058463          	beqz	a1,ffffffffc020086e <buddy_system_free_pages+0x12c>
    while (size < n) {
ffffffffc020074a:	4785                	li	a5,1
    size_t order = 0;
ffffffffc020074c:	4701                	li	a4,0
    while (size < n) {
ffffffffc020074e:	10f58c63          	beq	a1,a5,ffffffffc0200866 <buddy_system_free_pages+0x124>
        size <<= 1;
ffffffffc0200752:	0786                	slli	a5,a5,0x1
        order++;
ffffffffc0200754:	0705                	addi	a4,a4,1
    while (size < n) {
ffffffffc0200756:	feb7eee3          	bltu	a5,a1,ffffffffc0200752 <buddy_system_free_pages+0x10>
    assert(page->property == order);
ffffffffc020075a:	491c                	lw	a5,16(a0)
ffffffffc020075c:	0007081b          	sext.w	a6,a4
ffffffffc0200760:	13079763          	bne	a5,a6,ffffffffc020088e <buddy_system_free_pages+0x14c>
    while (order < MAX_ORDER) {
ffffffffc0200764:	47b5                	li	a5,13
    int order = get_order(n);
ffffffffc0200766:	86c2                	mv	a3,a6
    while (order < MAX_ORDER) {
ffffffffc0200768:	00006397          	auipc	t2,0x6
ffffffffc020076c:	8b038393          	addi	t2,t2,-1872 # ffffffffc0206018 <free_area>
ffffffffc0200770:	0b07c363          	blt	a5,a6,ffffffffc0200816 <buddy_system_free_pages+0xd4>
    if(buddy_idx >= (npage - nbase)) {
ffffffffc0200774:	00006f17          	auipc	t5,0x6
ffffffffc0200778:	a4cf3f03          	ld	t5,-1460(t5) # ffffffffc02061c0 <npage>
ffffffffc020077c:	00002717          	auipc	a4,0x2
ffffffffc0200780:	dac73703          	ld	a4,-596(a4) # ffffffffc0202528 <nbase>
ffffffffc0200784:	00169613          	slli	a2,a3,0x1
    size_t page_idx = base - pages; 
ffffffffc0200788:	ccccd7b7          	lui	a5,0xccccd
ffffffffc020078c:	ccd78793          	addi	a5,a5,-819 # ffffffffcccccccd <end+0xcac6afd>
ffffffffc0200790:	9636                	add	a2,a2,a3
ffffffffc0200792:	060e                	slli	a2,a2,0x3
ffffffffc0200794:	00006397          	auipc	t2,0x6
ffffffffc0200798:	88438393          	addi	t2,t2,-1916 # ffffffffc0206018 <free_area>
ffffffffc020079c:	02079e93          	slli	t4,a5,0x20
ffffffffc02007a0:	00006e17          	auipc	t3,0x6
ffffffffc02007a4:	a28e3e03          	ld	t3,-1496(t3) # ffffffffc02061c8 <pages>
    if(buddy_idx >= (npage - nbase)) {
ffffffffc02007a8:	40ef0f33          	sub	t5,t5,a4
    size_t page_idx = base - pages; 
ffffffffc02007ac:	9ebe                	add	t4,t4,a5
ffffffffc02007ae:	961e                	add	a2,a2,t2
    size_t buddy_idx = page_idx ^ (1 << order); 
ffffffffc02007b0:	4f85                	li	t6,1
    while (order < MAX_ORDER) {
ffffffffc02007b2:	42b9                	li	t0,14
ffffffffc02007b4:	a0b1                	j	ffffffffc0200800 <buddy_system_free_pages+0xbe>
    struct Page *buddy = pages + buddy_idx;
ffffffffc02007b6:	00271793          	slli	a5,a4,0x2
ffffffffc02007ba:	97ba                	add	a5,a5,a4
ffffffffc02007bc:	078e                	slli	a5,a5,0x3
ffffffffc02007be:	97f2                	add	a5,a5,t3
        if(buddy == NULL) {
ffffffffc02007c0:	cbb9                	beqz	a5,ffffffffc0200816 <buddy_system_free_pages+0xd4>
        if (!PageProperty(buddy) || buddy->property != order) {
ffffffffc02007c2:	6798                	ld	a4,8(a5)
ffffffffc02007c4:	00277893          	andi	a7,a4,2
ffffffffc02007c8:	04088763          	beqz	a7,ffffffffc0200816 <buddy_system_free_pages+0xd4>
ffffffffc02007cc:	0107a883          	lw	a7,16(a5)
ffffffffc02007d0:	04d89363          	bne	a7,a3,ffffffffc0200816 <buddy_system_free_pages+0xd4>
    __list_del(listelm->prev, listelm->next);
ffffffffc02007d4:	0187b303          	ld	t1,24(a5)
ffffffffc02007d8:	0207b883          	ld	a7,32(a5)
        nr_free(order)--;
ffffffffc02007dc:	01062803          	lw	a6,16(a2)
        ClearPageProperty(buddy);
ffffffffc02007e0:	9b75                	andi	a4,a4,-3
 * This is only for internal list manipulation where we know
 * the prev/next entries already!
 * */
static inline void
__list_del(list_entry_t *prev, list_entry_t *next) {
    prev->next = next;
ffffffffc02007e2:	01133423          	sd	a7,8(t1)
    next->prev = prev;
ffffffffc02007e6:	0068b023          	sd	t1,0(a7)
ffffffffc02007ea:	e798                	sd	a4,8(a5)
        nr_free(order)--;
ffffffffc02007ec:	fff8071b          	addiw	a4,a6,-1
ffffffffc02007f0:	ca18                	sw	a4,16(a2)
        if (buddy < page) {
ffffffffc02007f2:	00a7f363          	bgeu	a5,a0,ffffffffc02007f8 <buddy_system_free_pages+0xb6>
ffffffffc02007f6:	853e                	mv	a0,a5
        order++;
ffffffffc02007f8:	2685                	addiw	a3,a3,1
    while (order < MAX_ORDER) {
ffffffffc02007fa:	0661                	addi	a2,a2,24
ffffffffc02007fc:	06568363          	beq	a3,t0,ffffffffc0200862 <buddy_system_free_pages+0x120>
    size_t page_idx = base - pages; 
ffffffffc0200800:	41c50733          	sub	a4,a0,t3
ffffffffc0200804:	870d                	srai	a4,a4,0x3
ffffffffc0200806:	03d70733          	mul	a4,a4,t4
    size_t buddy_idx = page_idx ^ (1 << order); 
ffffffffc020080a:	00df97bb          	sllw	a5,t6,a3
ffffffffc020080e:	8836                	mv	a6,a3
ffffffffc0200810:	8f3d                	xor	a4,a4,a5
    if(buddy_idx >= (npage - nbase)) {
ffffffffc0200812:	fbe762e3          	bltu	a4,t5,ffffffffc02007b6 <buddy_system_free_pages+0x74>
    __list_add(elm, listelm, listelm->next);
ffffffffc0200816:	00169793          	slli	a5,a3,0x1
ffffffffc020081a:	97b6                	add	a5,a5,a3
    SetPageProperty(page);
ffffffffc020081c:	6518                	ld	a4,8(a0)
ffffffffc020081e:	078e                	slli	a5,a5,0x3
ffffffffc0200820:	93be                	add	t2,t2,a5
ffffffffc0200822:	0083b683          	ld	a3,8(t2)
ffffffffc0200826:	00276793          	ori	a5,a4,2
ffffffffc020082a:	e51c                	sd	a5,8(a0)
    nr_free(order)++;
ffffffffc020082c:	0103a703          	lw	a4,16(t2)
    page->property = order;
ffffffffc0200830:	01052823          	sw	a6,16(a0)
    total_nr_free += n;
ffffffffc0200834:	00006797          	auipc	a5,0x6
ffffffffc0200838:	9647b783          	ld	a5,-1692(a5) # ffffffffc0206198 <total_nr_free>
    list_add(&free_list(order), &(page->page_link));
ffffffffc020083c:	01850613          	addi	a2,a0,24
    prev->next = next->prev = elm;
ffffffffc0200840:	e290                	sd	a2,0(a3)
ffffffffc0200842:	00c3b423          	sd	a2,8(t2)
}
ffffffffc0200846:	60a2                	ld	ra,8(sp)
    elm->next = next;
ffffffffc0200848:	f114                	sd	a3,32(a0)
    elm->prev = prev;
ffffffffc020084a:	00753c23          	sd	t2,24(a0)
    nr_free(order)++;
ffffffffc020084e:	2705                	addiw	a4,a4,1
    total_nr_free += n;
ffffffffc0200850:	97ae                	add	a5,a5,a1
    nr_free(order)++;
ffffffffc0200852:	00e3a823          	sw	a4,16(t2)
    total_nr_free += n;
ffffffffc0200856:	00006717          	auipc	a4,0x6
ffffffffc020085a:	94f73123          	sd	a5,-1726(a4) # ffffffffc0206198 <total_nr_free>
}
ffffffffc020085e:	0141                	addi	sp,sp,16
ffffffffc0200860:	8082                	ret
ffffffffc0200862:	8836                	mv	a6,a3
ffffffffc0200864:	bf4d                	j	ffffffffc0200816 <buddy_system_free_pages+0xd4>
    assert(page->property == order);
ffffffffc0200866:	491c                	lw	a5,16(a0)
ffffffffc0200868:	e39d                	bnez	a5,ffffffffc020088e <buddy_system_free_pages+0x14c>
    int order = get_order(n);
ffffffffc020086a:	4681                	li	a3,0
ffffffffc020086c:	b721                	j	ffffffffc0200774 <buddy_system_free_pages+0x32>
    assert(n > 0);
ffffffffc020086e:	00001697          	auipc	a3,0x1
ffffffffc0200872:	1a268693          	addi	a3,a3,418 # ffffffffc0201a10 <etext+0x2a4>
ffffffffc0200876:	00001617          	auipc	a2,0x1
ffffffffc020087a:	1a260613          	addi	a2,a2,418 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc020087e:	08e00593          	li	a1,142
ffffffffc0200882:	00001517          	auipc	a0,0x1
ffffffffc0200886:	1ae50513          	addi	a0,a0,430 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc020088a:	93fff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(page->property == order);
ffffffffc020088e:	00001697          	auipc	a3,0x1
ffffffffc0200892:	1ca68693          	addi	a3,a3,458 # ffffffffc0201a58 <etext+0x2ec>
ffffffffc0200896:	00001617          	auipc	a2,0x1
ffffffffc020089a:	18260613          	addi	a2,a2,386 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc020089e:	09100593          	li	a1,145
ffffffffc02008a2:	00001517          	auipc	a0,0x1
ffffffffc02008a6:	18e50513          	addi	a0,a0,398 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc02008aa:	91fff0ef          	jal	ffffffffc02001c8 <__panic>

ffffffffc02008ae <buddy_system_alloc_pages>:
    if(n == 0) {
ffffffffc02008ae:	1c050463          	beqz	a0,ffffffffc0200a76 <buddy_system_alloc_pages+0x1c8>
buddy_system_alloc_pages(size_t n) {
ffffffffc02008b2:	1141                	addi	sp,sp,-16
ffffffffc02008b4:	e406                	sd	ra,8(sp)
ffffffffc02008b6:	88aa                	mv	a7,a0
ffffffffc02008b8:	00005597          	auipc	a1,0x5
ffffffffc02008bc:	76058593          	addi	a1,a1,1888 # ffffffffc0206018 <free_area>
ffffffffc02008c0:	00006797          	auipc	a5,0x6
ffffffffc02008c4:	8b878793          	addi	a5,a5,-1864 # ffffffffc0206178 <free_area+0x160>
    for (int order = MAX_ORDER; order >= 0; order--) {
ffffffffc02008c8:	4739                	li	a4,14
ffffffffc02008ca:	567d                	li	a2,-1
        if (nr_free(order) > 0) {
ffffffffc02008cc:	4394                	lw	a3,0(a5)
ffffffffc02008ce:	14069663          	bnez	a3,ffffffffc0200a1a <buddy_system_alloc_pages+0x16c>
    for (int order = MAX_ORDER; order >= 0; order--) {
ffffffffc02008d2:	377d                	addiw	a4,a4,-1
ffffffffc02008d4:	17a1                	addi	a5,a5,-24
ffffffffc02008d6:	fec71be3          	bne	a4,a2,ffffffffc02008cc <buddy_system_alloc_pages+0x1e>
    if (n > ORDER2SIZE(get_current_max_order())) {
ffffffffc02008da:	4785                	li	a5,1
ffffffffc02008dc:	18f89963          	bne	a7,a5,ffffffffc0200a6e <buddy_system_alloc_pages+0x1c0>
    size_t order = 0;
ffffffffc02008e0:	4e01                	li	t3,0
    int order = get_order(n);
ffffffffc02008e2:	4301                	li	t1,0
ffffffffc02008e4:	00131713          	slli	a4,t1,0x1
ffffffffc02008e8:	971a                	add	a4,a4,t1
ffffffffc02008ea:	070e                	slli	a4,a4,0x3
ffffffffc02008ec:	972e                	add	a4,a4,a1
    for (current_order = order; current_order <= MAX_ORDER; current_order++) {
ffffffffc02008ee:	879a                	mv	a5,t1
ffffffffc02008f0:	463d                	li	a2,15
ffffffffc02008f2:	a029                	j	ffffffffc02008fc <buddy_system_alloc_pages+0x4e>
ffffffffc02008f4:	2785                	addiw	a5,a5,1
ffffffffc02008f6:	0761                	addi	a4,a4,24
ffffffffc02008f8:	14c78a63          	beq	a5,a2,ffffffffc0200a4c <buddy_system_alloc_pages+0x19e>
        if (nr_free(current_order) > 0) {
ffffffffc02008fc:	4b14                	lw	a3,16(a4)
ffffffffc02008fe:	dafd                	beqz	a3,ffffffffc02008f4 <buddy_system_alloc_pages+0x46>
    return listelm->next;
ffffffffc0200900:	00179713          	slli	a4,a5,0x1
ffffffffc0200904:	973e                	add	a4,a4,a5
ffffffffc0200906:	070e                	slli	a4,a4,0x3
ffffffffc0200908:	972e                	add	a4,a4,a1
ffffffffc020090a:	00873383          	ld	t2,8(a4)
    nr_free(current_order)--;
ffffffffc020090e:	4b14                	lw	a3,16(a4)
    __list_del(listelm->prev, listelm->next);
ffffffffc0200910:	0003b583          	ld	a1,0(t2)
ffffffffc0200914:	0083b603          	ld	a2,8(t2)
ffffffffc0200918:	36fd                	addiw	a3,a3,-1
    struct Page *page = le2page(le, page_link);
ffffffffc020091a:	fe838513          	addi	a0,t2,-24
    prev->next = next;
ffffffffc020091e:	e590                	sd	a2,8(a1)
    next->prev = prev;
ffffffffc0200920:	e20c                	sd	a1,0(a2)
    nr_free(current_order)--;
ffffffffc0200922:	cb14                	sw	a3,16(a4)
    while (current_order > order) {
ffffffffc0200924:	0cf35763          	bge	t1,a5,ffffffffc02009f2 <buddy_system_alloc_pages+0x144>
    size_t page_idx = base - pages; 
ffffffffc0200928:	00006297          	auipc	t0,0x6
ffffffffc020092c:	8a02b283          	ld	t0,-1888(t0) # ffffffffc02061c8 <pages>
ffffffffc0200930:	ccccd737          	lui	a4,0xccccd
ffffffffc0200934:	ccd70713          	addi	a4,a4,-819 # ffffffffcccccccd <end+0xcac6afd>
ffffffffc0200938:	fff7861b          	addiw	a2,a5,-1
ffffffffc020093c:	02071693          	slli	a3,a4,0x20
ffffffffc0200940:	40550eb3          	sub	t4,a0,t0
ffffffffc0200944:	9736                	add	a4,a4,a3
ffffffffc0200946:	8f91                	sub	a5,a5,a2
ffffffffc0200948:	403ede93          	srai	t4,t4,0x3
ffffffffc020094c:	00179f13          	slli	t5,a5,0x1
ffffffffc0200950:	02ee8eb3          	mul	t4,t4,a4
    if(buddy_idx >= (npage - nbase)) {
ffffffffc0200954:	00006f97          	auipc	t6,0x6
ffffffffc0200958:	86cfbf83          	ld	t6,-1940(t6) # ffffffffc02061c0 <npage>
ffffffffc020095c:	00002697          	auipc	a3,0x2
ffffffffc0200960:	bcc6b683          	ld	a3,-1076(a3) # ffffffffc0202528 <nbase>
ffffffffc0200964:	00161713          	slli	a4,a2,0x1
ffffffffc0200968:	9732                	add	a4,a4,a2
ffffffffc020096a:	9f3e                	add	t5,t5,a5
        list_add(&free_list(current_order), &(buddy->page_link));
ffffffffc020096c:	0f0e                	slli	t5,t5,0x3
ffffffffc020096e:	00371793          	slli	a5,a4,0x3
ffffffffc0200972:	00005717          	auipc	a4,0x5
ffffffffc0200976:	6ae70713          	addi	a4,a4,1710 # ffffffffc0206020 <free_area+0x8>
ffffffffc020097a:	e022                	sd	s0,0(sp)
ffffffffc020097c:	1f01                	addi	t5,t5,-32
ffffffffc020097e:	973e                	add	a4,a4,a5
    if(buddy_idx >= (npage - nbase)) {
ffffffffc0200980:	40df8fb3          	sub	t6,t6,a3
    size_t buddy_idx = page_idx ^ (1 << order); 
ffffffffc0200984:	4405                	li	s0,1
ffffffffc0200986:	a83d                	j	ffffffffc02009c4 <buddy_system_alloc_pages+0x116>
    struct Page *buddy = pages + buddy_idx;
ffffffffc0200988:	00269793          	slli	a5,a3,0x2
ffffffffc020098c:	97b6                	add	a5,a5,a3
ffffffffc020098e:	078e                	slli	a5,a5,0x3
ffffffffc0200990:	9796                	add	a5,a5,t0
        assert(buddy != NULL);
ffffffffc0200992:	cf9d                	beqz	a5,ffffffffc02009d0 <buddy_system_alloc_pages+0x122>
        SetPageProperty(buddy);
ffffffffc0200994:	6794                	ld	a3,8(a5)
    __list_add(elm, listelm, listelm->next);
ffffffffc0200996:	630c                	ld	a1,0(a4)
        buddy->property = current_order;
ffffffffc0200998:	cb90                	sw	a2,16(a5)
        SetPageProperty(buddy);
ffffffffc020099a:	0026e693          	ori	a3,a3,2
ffffffffc020099e:	e794                	sd	a3,8(a5)
        list_add(&free_list(current_order), &(buddy->page_link));
ffffffffc02009a0:	01878813          	addi	a6,a5,24
        nr_free(current_order)++;
ffffffffc02009a4:	4714                	lw	a3,8(a4)
    prev->next = next->prev = elm;
ffffffffc02009a6:	0105b023          	sd	a6,0(a1)
ffffffffc02009aa:	01073023          	sd	a6,0(a4)
        list_add(&free_list(current_order), &(buddy->page_link));
ffffffffc02009ae:	00ef0833          	add	a6,t5,a4
    elm->next = next;
ffffffffc02009b2:	f38c                	sd	a1,32(a5)
        nr_free(current_order)++;
ffffffffc02009b4:	2685                	addiw	a3,a3,1
    elm->prev = prev;
ffffffffc02009b6:	0107bc23          	sd	a6,24(a5)
ffffffffc02009ba:	c714                	sw	a3,8(a4)
    while (current_order > order) {
ffffffffc02009bc:	1721                	addi	a4,a4,-24
ffffffffc02009be:	02c30963          	beq	t1,a2,ffffffffc02009f0 <buddy_system_alloc_pages+0x142>
ffffffffc02009c2:	367d                	addiw	a2,a2,-1
    size_t buddy_idx = page_idx ^ (1 << order); 
ffffffffc02009c4:	00c416bb          	sllw	a3,s0,a2
ffffffffc02009c8:	01d6c6b3          	xor	a3,a3,t4
    if(buddy_idx >= (npage - nbase)) {
ffffffffc02009cc:	fbf6eee3          	bltu	a3,t6,ffffffffc0200988 <buddy_system_alloc_pages+0xda>
        assert(buddy != NULL);
ffffffffc02009d0:	00001697          	auipc	a3,0x1
ffffffffc02009d4:	0c068693          	addi	a3,a3,192 # ffffffffc0201a90 <etext+0x324>
ffffffffc02009d8:	00001617          	auipc	a2,0x1
ffffffffc02009dc:	04060613          	addi	a2,a2,64 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc02009e0:	08000593          	li	a1,128
ffffffffc02009e4:	00001517          	auipc	a0,0x1
ffffffffc02009e8:	04c50513          	addi	a0,a0,76 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc02009ec:	fdcff0ef          	jal	ffffffffc02001c8 <__panic>
ffffffffc02009f0:	6402                	ld	s0,0(sp)
    ClearPageProperty(page);
ffffffffc02009f2:	ff03b703          	ld	a4,-16(t2)
    total_nr_free -= n;
ffffffffc02009f6:	00005797          	auipc	a5,0x5
ffffffffc02009fa:	7a27b783          	ld	a5,1954(a5) # ffffffffc0206198 <total_nr_free>
}
ffffffffc02009fe:	60a2                	ld	ra,8(sp)
    ClearPageProperty(page);
ffffffffc0200a00:	9b75                	andi	a4,a4,-3
    total_nr_free -= n;
ffffffffc0200a02:	411787b3          	sub	a5,a5,a7
    ClearPageProperty(page);
ffffffffc0200a06:	fee3b823          	sd	a4,-16(t2)
    page->property = order;
ffffffffc0200a0a:	ffc3ac23          	sw	t3,-8(t2)
    total_nr_free -= n;
ffffffffc0200a0e:	00005717          	auipc	a4,0x5
ffffffffc0200a12:	78f73523          	sd	a5,1930(a4) # ffffffffc0206198 <total_nr_free>
}
ffffffffc0200a16:	0141                	addi	sp,sp,16
ffffffffc0200a18:	8082                	ret
    if (n > ORDER2SIZE(get_current_max_order())) {
ffffffffc0200a1a:	4785                	li	a5,1
ffffffffc0200a1c:	00e797bb          	sllw	a5,a5,a4
ffffffffc0200a20:	1782                	slli	a5,a5,0x20
ffffffffc0200a22:	9381                	srli	a5,a5,0x20
ffffffffc0200a24:	0517e563          	bltu	a5,a7,ffffffffc0200a6e <buddy_system_alloc_pages+0x1c0>
    if( !IS_POWER_OF_2(n)) {
ffffffffc0200a28:	fff88e13          	addi	t3,a7,-1
ffffffffc0200a2c:	011e7e33          	and	t3,t3,a7
ffffffffc0200a30:	020e1f63          	bnez	t3,ffffffffc0200a6e <buddy_system_alloc_pages+0x1c0>
    while (size < n) {
ffffffffc0200a34:	4785                	li	a5,1
ffffffffc0200a36:	04f88163          	beq	a7,a5,ffffffffc0200a78 <buddy_system_alloc_pages+0x1ca>
        size <<= 1;
ffffffffc0200a3a:	0786                	slli	a5,a5,0x1
        order++;
ffffffffc0200a3c:	0e05                	addi	t3,t3,1
    while (size < n) {
ffffffffc0200a3e:	ff17eee3          	bltu	a5,a7,ffffffffc0200a3a <buddy_system_alloc_pages+0x18c>
    int order = get_order(n);
ffffffffc0200a42:	000e031b          	sext.w	t1,t3
    for (current_order = order; current_order <= MAX_ORDER; current_order++) {
ffffffffc0200a46:	47b9                	li	a5,14
ffffffffc0200a48:	e867dee3          	bge	a5,t1,ffffffffc02008e4 <buddy_system_alloc_pages+0x36>
    assert(current_order <= MAX_ORDER);
ffffffffc0200a4c:	00001697          	auipc	a3,0x1
ffffffffc0200a50:	02468693          	addi	a3,a3,36 # ffffffffc0201a70 <etext+0x304>
ffffffffc0200a54:	00001617          	auipc	a2,0x1
ffffffffc0200a58:	fc460613          	addi	a2,a2,-60 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc0200a5c:	07600593          	li	a1,118
ffffffffc0200a60:	00001517          	auipc	a0,0x1
ffffffffc0200a64:	fd050513          	addi	a0,a0,-48 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc0200a68:	e022                	sd	s0,0(sp)
ffffffffc0200a6a:	f5eff0ef          	jal	ffffffffc02001c8 <__panic>
}
ffffffffc0200a6e:	60a2                	ld	ra,8(sp)
        return NULL;
ffffffffc0200a70:	4501                	li	a0,0
}
ffffffffc0200a72:	0141                	addi	sp,sp,16
ffffffffc0200a74:	8082                	ret
ffffffffc0200a76:	8082                	ret
    int order = get_order(n);
ffffffffc0200a78:	4301                	li	t1,0
ffffffffc0200a7a:	b5ad                	j	ffffffffc02008e4 <buddy_system_alloc_pages+0x36>

ffffffffc0200a7c <buddy_system_check>:
static void
buddy_system_check(void) {
ffffffffc0200a7c:	711d                	addi	sp,sp,-96
    cprintf("==================================================\n");
ffffffffc0200a7e:	00001517          	auipc	a0,0x1
ffffffffc0200a82:	02250513          	addi	a0,a0,34 # ffffffffc0201aa0 <etext+0x334>
buddy_system_check(void) {
ffffffffc0200a86:	ec86                	sd	ra,88(sp)
ffffffffc0200a88:	e8a2                	sd	s0,80(sp)
ffffffffc0200a8a:	e4a6                	sd	s1,72(sp)
ffffffffc0200a8c:	e0ca                	sd	s2,64(sp)
ffffffffc0200a8e:	fc4e                	sd	s3,56(sp)
ffffffffc0200a90:	f852                	sd	s4,48(sp)
ffffffffc0200a92:	f456                	sd	s5,40(sp)
ffffffffc0200a94:	f05a                	sd	s6,32(sp)
ffffffffc0200a96:	ec5e                	sd	s7,24(sp)
ffffffffc0200a98:	e862                	sd	s8,16(sp)
ffffffffc0200a9a:	e466                	sd	s9,8(sp)
ffffffffc0200a9c:	e06a                	sd	s10,0(sp)
    cprintf("==================================================\n");
ffffffffc0200a9e:	eaaff0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("buddy_system_check() starting...\n");
ffffffffc0200aa2:	00001517          	auipc	a0,0x1
ffffffffc0200aa6:	03650513          	addi	a0,a0,54 # ffffffffc0201ad8 <etext+0x36c>
ffffffffc0200aaa:	e9eff0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("==================================================\n");
ffffffffc0200aae:	00001517          	auipc	a0,0x1
ffffffffc0200ab2:	ff250513          	addi	a0,a0,-14 # ffffffffc0201aa0 <etext+0x334>
ffffffffc0200ab6:	e92ff0ef          	jal	ffffffffc0200148 <cprintf>
    size_t min_idx = -1, max_idx = 0;
    for (int i = 0; i <= MAX_ORDER; i++) {
        list_entry_t *le = &free_list(i);
        while ((le = list_next(le)) != &free_list(i)) {
            struct Page *p = le2page(le, page_link);
            size_t current_idx = p - pages;
ffffffffc0200aba:	00005417          	auipc	s0,0x5
ffffffffc0200abe:	70e40413          	addi	s0,s0,1806 # ffffffffc02061c8 <pages>
ffffffffc0200ac2:	ccccd7b7          	lui	a5,0xccccd
ffffffffc0200ac6:	ccd78793          	addi	a5,a5,-819 # ffffffffcccccccd <end+0xcac6afd>
ffffffffc0200aca:	00043883          	ld	a7,0(s0)
ffffffffc0200ace:	02079813          	slli	a6,a5,0x20
ffffffffc0200ad2:	983e                	add	a6,a6,a5
ffffffffc0200ad4:	00005697          	auipc	a3,0x5
ffffffffc0200ad8:	54468693          	addi	a3,a3,1348 # ffffffffc0206018 <free_area>
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200adc:	4301                	li	t1,0
    size_t min_idx = -1, max_idx = 0;
ffffffffc0200ade:	4601                	li	a2,0
ffffffffc0200ae0:	55fd                	li	a1,-1
            if (current_idx < min_idx) min_idx = current_idx;
            if (current_idx > max_idx) max_idx = current_idx + ORDER2SIZE(i) - 1;
ffffffffc0200ae2:	4e85                	li	t4,1
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200ae4:	4e3d                	li	t3,15
    return listelm->next;
ffffffffc0200ae6:	6698                	ld	a4,8(a3)
        while ((le = list_next(le)) != &free_list(i)) {
ffffffffc0200ae8:	02e68863          	beq	a3,a4,ffffffffc0200b18 <buddy_system_check+0x9c>
            if (current_idx > max_idx) max_idx = current_idx + ORDER2SIZE(i) - 1;
ffffffffc0200aec:	006e953b          	sllw	a0,t4,t1
ffffffffc0200af0:	1502                	slli	a0,a0,0x20
ffffffffc0200af2:	9101                	srli	a0,a0,0x20
ffffffffc0200af4:	157d                	addi	a0,a0,-1
            struct Page *p = le2page(le, page_link);
ffffffffc0200af6:	fe870793          	addi	a5,a4,-24
            size_t current_idx = p - pages;
ffffffffc0200afa:	411787b3          	sub	a5,a5,a7
ffffffffc0200afe:	878d                	srai	a5,a5,0x3
ffffffffc0200b00:	030787b3          	mul	a5,a5,a6
            if (current_idx < min_idx) min_idx = current_idx;
ffffffffc0200b04:	00b7f363          	bgeu	a5,a1,ffffffffc0200b0a <buddy_system_check+0x8e>
ffffffffc0200b08:	85be                	mv	a1,a5
            if (current_idx > max_idx) max_idx = current_idx + ORDER2SIZE(i) - 1;
ffffffffc0200b0a:	00f67463          	bgeu	a2,a5,ffffffffc0200b12 <buddy_system_check+0x96>
ffffffffc0200b0e:	00f50633          	add	a2,a0,a5
ffffffffc0200b12:	6718                	ld	a4,8(a4)
        while ((le = list_next(le)) != &free_list(i)) {
ffffffffc0200b14:	fed711e3          	bne	a4,a3,ffffffffc0200af6 <buddy_system_check+0x7a>
    for (int i = 0; i <= MAX_ORDER; i++) {
ffffffffc0200b18:	2305                	addiw	t1,t1,1
ffffffffc0200b1a:	06e1                	addi	a3,a3,24
ffffffffc0200b1c:	fdc315e3          	bne	t1,t3,ffffffffc0200ae6 <buddy_system_check+0x6a>
        }
    }
    cprintf("Initial available page index range: [%u, %u]\n", min_idx, max_idx);
ffffffffc0200b20:	00001517          	auipc	a0,0x1
ffffffffc0200b24:	fe050513          	addi	a0,a0,-32 # ffffffffc0201b00 <etext+0x394>
ffffffffc0200b28:	e20ff0ef          	jal	ffffffffc0200148 <cprintf>
    print_buddy_system_status();
ffffffffc0200b2c:	a75ff0ef          	jal	ffffffffc02005a0 <print_buddy_system_status>
    cprintf("\n");
ffffffffc0200b30:	00001517          	auipc	a0,0x1
ffffffffc0200b34:	d3050513          	addi	a0,a0,-720 # ffffffffc0201860 <etext+0xf4>
ffffffffc0200b38:	e10ff0ef          	jal	ffffffffc0200148 <cprintf>
    return total_nr_free;
ffffffffc0200b3c:	00005917          	auipc	s2,0x5
ffffffffc0200b40:	65c90913          	addi	s2,s2,1628 # ffffffffc0206198 <total_nr_free>

    size_t initial_free = buddy_system_nr_free_pages();

    // --- 1. 基本分配和释放测试 ---
    cprintf("--- 1. Basic alloc/free test ---\n");
ffffffffc0200b44:	00001517          	auipc	a0,0x1
ffffffffc0200b48:	fec50513          	addi	a0,a0,-20 # ffffffffc0201b30 <etext+0x3c4>
    return total_nr_free;
ffffffffc0200b4c:	00093983          	ld	s3,0(s2)
    cprintf("--- 1. Basic alloc/free test ---\n");
ffffffffc0200b50:	df8ff0ef          	jal	ffffffffc0200148 <cprintf>
    struct Page *p1, *p2, *p4;
    p1 = alloc_pages(1); assert(p1 != NULL);
ffffffffc0200b54:	4505                	li	a0,1
ffffffffc0200b56:	5a2000ef          	jal	ffffffffc02010f8 <alloc_pages>
ffffffffc0200b5a:	8a2a                	mv	s4,a0
ffffffffc0200b5c:	34050e63          	beqz	a0,ffffffffc0200eb8 <buddy_system_check+0x43c>
    p2 = alloc_pages(2); assert(p2 != NULL);
ffffffffc0200b60:	4509                	li	a0,2
ffffffffc0200b62:	596000ef          	jal	ffffffffc02010f8 <alloc_pages>
ffffffffc0200b66:	8aaa                	mv	s5,a0
ffffffffc0200b68:	56050863          	beqz	a0,ffffffffc02010d8 <buddy_system_check+0x65c>
    p4 = alloc_pages(4); assert(p4 != NULL);
ffffffffc0200b6c:	4511                	li	a0,4
ffffffffc0200b6e:	58a000ef          	jal	ffffffffc02010f8 <alloc_pages>
ffffffffc0200b72:	84aa                	mv	s1,a0
ffffffffc0200b74:	54050263          	beqz	a0,ffffffffc02010b8 <buddy_system_check+0x63c>
    assert(p1 != p2 && p1 != p4 && p2 != p4);
ffffffffc0200b78:	40aa07b3          	sub	a5,s4,a0
ffffffffc0200b7c:	40aa8733          	sub	a4,s5,a0
ffffffffc0200b80:	0017b793          	seqz	a5,a5
ffffffffc0200b84:	00173713          	seqz	a4,a4
ffffffffc0200b88:	8fd9                	or	a5,a5,a4
ffffffffc0200b8a:	50079763          	bnez	a5,ffffffffc0201098 <buddy_system_check+0x61c>
ffffffffc0200b8e:	515a0563          	beq	s4,s5,ffffffffc0201098 <buddy_system_check+0x61c>
    cprintf("  After allocating 1, 2, 4 pages:\n");
ffffffffc0200b92:	00001517          	auipc	a0,0x1
ffffffffc0200b96:	01e50513          	addi	a0,a0,30 # ffffffffc0201bb0 <etext+0x444>
ffffffffc0200b9a:	daeff0ef          	jal	ffffffffc0200148 <cprintf>
    print_buddy_system_status();
ffffffffc0200b9e:	a03ff0ef          	jal	ffffffffc02005a0 <print_buddy_system_status>

    free_pages(p1, 1);
ffffffffc0200ba2:	8552                	mv	a0,s4
ffffffffc0200ba4:	4585                	li	a1,1
ffffffffc0200ba6:	55e000ef          	jal	ffffffffc0201104 <free_pages>
    free_pages(p2, 2);
ffffffffc0200baa:	8556                	mv	a0,s5
ffffffffc0200bac:	4589                	li	a1,2
ffffffffc0200bae:	556000ef          	jal	ffffffffc0201104 <free_pages>
    free_pages(p4, 4);
ffffffffc0200bb2:	8526                	mv	a0,s1
ffffffffc0200bb4:	4591                	li	a1,4
ffffffffc0200bb6:	54e000ef          	jal	ffffffffc0201104 <free_pages>
    assert(buddy_system_nr_free_pages() == initial_free);
ffffffffc0200bba:	00093483          	ld	s1,0(s2)
ffffffffc0200bbe:	4b349d63          	bne	s1,s3,ffffffffc0201078 <buddy_system_check+0x5fc>
    cprintf("  After freeing all pages:\n");
ffffffffc0200bc2:	00001517          	auipc	a0,0x1
ffffffffc0200bc6:	04650513          	addi	a0,a0,70 # ffffffffc0201c08 <etext+0x49c>
ffffffffc0200bca:	d7eff0ef          	jal	ffffffffc0200148 <cprintf>
    print_buddy_system_status();
ffffffffc0200bce:	9d3ff0ef          	jal	ffffffffc02005a0 <print_buddy_system_status>
    cprintf("buddy_system_check(): basic alloc/free pass.\n\n");
ffffffffc0200bd2:	00001517          	auipc	a0,0x1
ffffffffc0200bd6:	05650513          	addi	a0,a0,86 # ffffffffc0201c28 <etext+0x4bc>
ffffffffc0200bda:	d6eff0ef          	jal	ffffffffc0200148 <cprintf>

    // --- 2. 边界条件和非法请求测试 ---
    cprintf("--- 2. Edge case and invalid request test ---\n");
ffffffffc0200bde:	00001517          	auipc	a0,0x1
ffffffffc0200be2:	07a50513          	addi	a0,a0,122 # ffffffffc0201c58 <etext+0x4ec>
ffffffffc0200be6:	d62ff0ef          	jal	ffffffffc0200148 <cprintf>
    assert(alloc_pages(3) == NULL); // 非2的幂次
ffffffffc0200bea:	450d                	li	a0,3
ffffffffc0200bec:	50c000ef          	jal	ffffffffc02010f8 <alloc_pages>
ffffffffc0200bf0:	46051463          	bnez	a0,ffffffffc0201058 <buddy_system_check+0x5dc>
    assert(alloc_pages(0) == NULL);
ffffffffc0200bf4:	504000ef          	jal	ffffffffc02010f8 <alloc_pages>
    
    size_t max_alloc_size = 1;
    // 找到一个小于总空闲页数一半的最大2的幂次
    while(max_alloc_size * 2 <= initial_free / 2) {
ffffffffc0200bf8:	0014d713          	srli	a4,s1,0x1
    size_t max_alloc_size = 1;
ffffffffc0200bfc:	4785                	li	a5,1
    assert(alloc_pages(0) == NULL);
ffffffffc0200bfe:	42051d63          	bnez	a0,ffffffffc0201038 <buddy_system_check+0x5bc>
    while(max_alloc_size * 2 <= initial_free / 2) {
ffffffffc0200c02:	84be                	mv	s1,a5
ffffffffc0200c04:	0786                	slli	a5,a5,0x1
ffffffffc0200c06:	fef77ee3          	bgeu	a4,a5,ffffffffc0200c02 <buddy_system_check+0x186>
        max_alloc_size *= 2;
    }
    p1 = alloc_pages(max_alloc_size);
ffffffffc0200c0a:	8526                	mv	a0,s1
ffffffffc0200c0c:	4ec000ef          	jal	ffffffffc02010f8 <alloc_pages>
ffffffffc0200c10:	8a2a                	mv	s4,a0
    assert(p1 != NULL);
ffffffffc0200c12:	40050363          	beqz	a0,ffffffffc0201018 <buddy_system_check+0x59c>
    cprintf("  After allocating max_alloc_size (%u pages):\n", max_alloc_size);
ffffffffc0200c16:	85a6                	mv	a1,s1
ffffffffc0200c18:	00001517          	auipc	a0,0x1
ffffffffc0200c1c:	0a050513          	addi	a0,a0,160 # ffffffffc0201cb8 <etext+0x54c>
ffffffffc0200c20:	d28ff0ef          	jal	ffffffffc0200148 <cprintf>
    print_buddy_system_status();
ffffffffc0200c24:	97dff0ef          	jal	ffffffffc02005a0 <print_buddy_system_status>

    free_pages(p1, max_alloc_size);
ffffffffc0200c28:	85a6                	mv	a1,s1
ffffffffc0200c2a:	8552                	mv	a0,s4
ffffffffc0200c2c:	4d8000ef          	jal	ffffffffc0201104 <free_pages>
    assert(buddy_system_nr_free_pages() == initial_free);
ffffffffc0200c30:	00093783          	ld	a5,0(s2)
ffffffffc0200c34:	3d379263          	bne	a5,s3,ffffffffc0200ff8 <buddy_system_check+0x57c>
    cprintf("  After freeing max_alloc_size:\n");
ffffffffc0200c38:	00001517          	auipc	a0,0x1
ffffffffc0200c3c:	0b050513          	addi	a0,a0,176 # ffffffffc0201ce8 <etext+0x57c>
ffffffffc0200c40:	d08ff0ef          	jal	ffffffffc0200148 <cprintf>
    print_buddy_system_status();
ffffffffc0200c44:	95dff0ef          	jal	ffffffffc02005a0 <print_buddy_system_status>
    cprintf("buddy_system_check(): edge case and invalid request pass.\n\n");
ffffffffc0200c48:	00001517          	auipc	a0,0x1
ffffffffc0200c4c:	0c850513          	addi	a0,a0,200 # ffffffffc0201d10 <etext+0x5a4>
ffffffffc0200c50:	cf8ff0ef          	jal	ffffffffc0200148 <cprintf>

    // --- 3. 分裂与合并的深度测试 ---
    cprintf("--- 3. Split and merge test ---\n");
ffffffffc0200c54:	00001517          	auipc	a0,0x1
ffffffffc0200c58:	0fc50513          	addi	a0,a0,252 # ffffffffc0201d50 <etext+0x5e4>
ffffffffc0200c5c:	cecff0ef          	jal	ffffffffc0200148 <cprintf>
    
    cprintf("  a. Clearing smaller blocks to ensure a clean test environment...\n");
ffffffffc0200c60:	00001517          	auipc	a0,0x1
ffffffffc0200c64:	11850513          	addi	a0,a0,280 # ffffffffc0201d78 <etext+0x60c>
ffffffffc0200c68:	ce0ff0ef          	jal	ffffffffc0200148 <cprintf>
    struct Page *p_temp1, *p_temp2, *p_temp4;
    p_temp1 = alloc_pages(1);
ffffffffc0200c6c:	4505                	li	a0,1
ffffffffc0200c6e:	48a000ef          	jal	ffffffffc02010f8 <alloc_pages>
ffffffffc0200c72:	8baa                	mv	s7,a0
    p_temp2 = alloc_pages(2);
ffffffffc0200c74:	4509                	li	a0,2
ffffffffc0200c76:	482000ef          	jal	ffffffffc02010f8 <alloc_pages>
ffffffffc0200c7a:	8b2a                	mv	s6,a0
    p_temp4 = alloc_pages(4);
ffffffffc0200c7c:	4511                	li	a0,4
ffffffffc0200c7e:	47a000ef          	jal	ffffffffc02010f8 <alloc_pages>
ffffffffc0200c82:	8aaa                	mv	s5,a0
    cprintf("     After clearing temp blocks:\n");
ffffffffc0200c84:	00001517          	auipc	a0,0x1
ffffffffc0200c88:	13c50513          	addi	a0,a0,316 # ffffffffc0201dc0 <etext+0x654>
ffffffffc0200c8c:	cbcff0ef          	jal	ffffffffc0200148 <cprintf>
    print_buddy_system_status();
ffffffffc0200c90:	911ff0ef          	jal	ffffffffc02005a0 <print_buddy_system_status>

    cprintf("  b. Preparing a clean 8-page block...\n");
ffffffffc0200c94:	00001517          	auipc	a0,0x1
ffffffffc0200c98:	15450513          	addi	a0,a0,340 # ffffffffc0201de8 <etext+0x67c>
ffffffffc0200c9c:	cacff0ef          	jal	ffffffffc0200148 <cprintf>
    p1 = alloc_pages(8);
ffffffffc0200ca0:	4521                	li	a0,8
ffffffffc0200ca2:	456000ef          	jal	ffffffffc02010f8 <alloc_pages>
ffffffffc0200ca6:	84aa                	mv	s1,a0
    assert(p1 != NULL);
ffffffffc0200ca8:	32050863          	beqz	a0,ffffffffc0200fd8 <buddy_system_check+0x55c>
static inline ppn_t page2ppn(struct Page *page) { return page - pages + nbase; }
ffffffffc0200cac:	6010                	ld	a2,0(s0)
ffffffffc0200cae:	ccccd7b7          	lui	a5,0xccccd
ffffffffc0200cb2:	ccd78793          	addi	a5,a5,-819 # ffffffffcccccccd <end+0xcac6afd>
ffffffffc0200cb6:	02079c93          	slli	s9,a5,0x20
ffffffffc0200cba:	40c50633          	sub	a2,a0,a2
ffffffffc0200cbe:	9cbe                	add	s9,s9,a5
ffffffffc0200cc0:	860d                	srai	a2,a2,0x3
ffffffffc0200cc2:	03960633          	mul	a2,a2,s9
ffffffffc0200cc6:	00002c17          	auipc	s8,0x2
ffffffffc0200cca:	862c3c03          	ld	s8,-1950(s8) # ffffffffc0202528 <nbase>
    cprintf("     Allocated p1(8): pa=0x%lx, page_idx=%u\n", page2pa(p1), p1 - pages);
ffffffffc0200cce:	00001517          	auipc	a0,0x1
ffffffffc0200cd2:	14250513          	addi	a0,a0,322 # ffffffffc0201e10 <etext+0x6a4>
ffffffffc0200cd6:	018605b3          	add	a1,a2,s8
ffffffffc0200cda:	05b2                	slli	a1,a1,0xc
ffffffffc0200cdc:	c6cff0ef          	jal	ffffffffc0200148 <cprintf>
    print_buddy_system_status();
ffffffffc0200ce0:	8c1ff0ef          	jal	ffffffffc02005a0 <print_buddy_system_status>
    free_pages(p1, 8);
ffffffffc0200ce4:	8526                	mv	a0,s1
ffffffffc0200ce6:	45a1                	li	a1,8
ffffffffc0200ce8:	41c000ef          	jal	ffffffffc0201104 <free_pages>
    return total_nr_free;
ffffffffc0200cec:	00093a03          	ld	s4,0(s2)
    size_t free_after_prepare = buddy_system_nr_free_pages();
    cprintf("     Freed p1(8). Current free pages: %u\n", free_after_prepare);
ffffffffc0200cf0:	00001517          	auipc	a0,0x1
ffffffffc0200cf4:	15050513          	addi	a0,a0,336 # ffffffffc0201e40 <etext+0x6d4>
ffffffffc0200cf8:	85d2                	mv	a1,s4
ffffffffc0200cfa:	c4eff0ef          	jal	ffffffffc0200148 <cprintf>
    print_buddy_system_status();
ffffffffc0200cfe:	8a3ff0ef          	jal	ffffffffc02005a0 <print_buddy_system_status>

    cprintf("  c. Triggering split...\n");
ffffffffc0200d02:	00001517          	auipc	a0,0x1
ffffffffc0200d06:	16e50513          	addi	a0,a0,366 # ffffffffc0201e70 <etext+0x704>
ffffffffc0200d0a:	c3eff0ef          	jal	ffffffffc0200148 <cprintf>
    struct Page *p_left = alloc_pages(4);
ffffffffc0200d0e:	4511                	li	a0,4
ffffffffc0200d10:	3e8000ef          	jal	ffffffffc02010f8 <alloc_pages>
ffffffffc0200d14:	8d2a                	mv	s10,a0
    assert(p_left != NULL);
ffffffffc0200d16:	2a050163          	beqz	a0,ffffffffc0200fb8 <buddy_system_check+0x53c>
ffffffffc0200d1a:	6010                	ld	a2,0(s0)
    cprintf("     Allocated p_left(4): pa=0x%lx, page_idx=%u\n", page2pa(p_left), p_left - pages);
ffffffffc0200d1c:	00001517          	auipc	a0,0x1
ffffffffc0200d20:	18450513          	addi	a0,a0,388 # ffffffffc0201ea0 <etext+0x734>
ffffffffc0200d24:	40cd0633          	sub	a2,s10,a2
ffffffffc0200d28:	860d                	srai	a2,a2,0x3
ffffffffc0200d2a:	03960633          	mul	a2,a2,s9
ffffffffc0200d2e:	018605b3          	add	a1,a2,s8
ffffffffc0200d32:	05b2                	slli	a1,a1,0xc
ffffffffc0200d34:	c14ff0ef          	jal	ffffffffc0200148 <cprintf>
    print_buddy_system_status();
ffffffffc0200d38:	869ff0ef          	jal	ffffffffc02005a0 <print_buddy_system_status>
    assert(p_left == p1);
ffffffffc0200d3c:	25a49e63          	bne	s1,s10,ffffffffc0200f98 <buddy_system_check+0x51c>

    struct Page *p_right = alloc_pages(4);
ffffffffc0200d40:	4511                	li	a0,4
ffffffffc0200d42:	3b6000ef          	jal	ffffffffc02010f8 <alloc_pages>
ffffffffc0200d46:	8d2a                	mv	s10,a0
    assert(p_right != NULL);
ffffffffc0200d48:	22050863          	beqz	a0,ffffffffc0200f78 <buddy_system_check+0x4fc>
ffffffffc0200d4c:	6010                	ld	a2,0(s0)
    cprintf("     Allocated p_right(4): pa=0x%lx, page_idx=%u\n", page2pa(p_right), p_right - pages);
ffffffffc0200d4e:	00001517          	auipc	a0,0x1
ffffffffc0200d52:	1aa50513          	addi	a0,a0,426 # ffffffffc0201ef8 <etext+0x78c>
ffffffffc0200d56:	40cd0633          	sub	a2,s10,a2
ffffffffc0200d5a:	860d                	srai	a2,a2,0x3
ffffffffc0200d5c:	03960633          	mul	a2,a2,s9
ffffffffc0200d60:	018605b3          	add	a1,a2,s8
ffffffffc0200d64:	05b2                	slli	a1,a1,0xc
ffffffffc0200d66:	be2ff0ef          	jal	ffffffffc0200148 <cprintf>
    print_buddy_system_status();
ffffffffc0200d6a:	837ff0ef          	jal	ffffffffc02005a0 <print_buddy_system_status>
    size_t page_idx = base - pages; 
ffffffffc0200d6e:	6014                	ld	a3,0(s0)
    if(buddy_idx >= (npage - nbase)) {
ffffffffc0200d70:	00005717          	auipc	a4,0x5
ffffffffc0200d74:	45073703          	ld	a4,1104(a4) # ffffffffc02061c0 <npage>
    size_t page_idx = base - pages; 
ffffffffc0200d78:	40d487b3          	sub	a5,s1,a3
ffffffffc0200d7c:	878d                	srai	a5,a5,0x3
ffffffffc0200d7e:	039787b3          	mul	a5,a5,s9
    if(buddy_idx >= (npage - nbase)) {
ffffffffc0200d82:	41870733          	sub	a4,a4,s8
    size_t buddy_idx = page_idx ^ (1 << order); 
ffffffffc0200d86:	0047c793          	xori	a5,a5,4
    if(buddy_idx >= (npage - nbase)) {
ffffffffc0200d8a:	1ce7f763          	bgeu	a5,a4,ffffffffc0200f58 <buddy_system_check+0x4dc>
    struct Page *buddy = pages + buddy_idx;
ffffffffc0200d8e:	00279713          	slli	a4,a5,0x2
ffffffffc0200d92:	97ba                	add	a5,a5,a4
ffffffffc0200d94:	078e                	slli	a5,a5,0x3
ffffffffc0200d96:	96be                	add	a3,a3,a5
    assert(p_right == get_buddy_addr(p_left, 2)); 
ffffffffc0200d98:	1cdd1063          	bne	s10,a3,ffffffffc0200f58 <buddy_system_check+0x4dc>
    
    cprintf("  d. Triggering merge...\n");
ffffffffc0200d9c:	00001517          	auipc	a0,0x1
ffffffffc0200da0:	1bc50513          	addi	a0,a0,444 # ffffffffc0201f58 <etext+0x7ec>
ffffffffc0200da4:	ba4ff0ef          	jal	ffffffffc0200148 <cprintf>
    free_pages(p_left, 4);
ffffffffc0200da8:	4591                	li	a1,4
ffffffffc0200daa:	8526                	mv	a0,s1
ffffffffc0200dac:	358000ef          	jal	ffffffffc0201104 <free_pages>
    cprintf("     Freed p_left(4):\n");
ffffffffc0200db0:	00001517          	auipc	a0,0x1
ffffffffc0200db4:	1c850513          	addi	a0,a0,456 # ffffffffc0201f78 <etext+0x80c>
ffffffffc0200db8:	b90ff0ef          	jal	ffffffffc0200148 <cprintf>
    print_buddy_system_status();
ffffffffc0200dbc:	fe4ff0ef          	jal	ffffffffc02005a0 <print_buddy_system_status>
    free_pages(p_right, 4);
ffffffffc0200dc0:	4591                	li	a1,4
ffffffffc0200dc2:	856a                	mv	a0,s10
ffffffffc0200dc4:	340000ef          	jal	ffffffffc0201104 <free_pages>
    cprintf("     Freed p_right(4), should trigger merge:\n");
ffffffffc0200dc8:	00001517          	auipc	a0,0x1
ffffffffc0200dcc:	1c850513          	addi	a0,a0,456 # ffffffffc0201f90 <etext+0x824>
ffffffffc0200dd0:	b78ff0ef          	jal	ffffffffc0200148 <cprintf>
    print_buddy_system_status();
ffffffffc0200dd4:	fccff0ef          	jal	ffffffffc02005a0 <print_buddy_system_status>
    assert(buddy_system_nr_free_pages() == free_after_prepare);
ffffffffc0200dd8:	00093783          	ld	a5,0(s2)
ffffffffc0200ddc:	14fa1e63          	bne	s4,a5,ffffffffc0200f38 <buddy_system_check+0x4bc>

    cprintf("  e. Verifying merge result...\n");
ffffffffc0200de0:	00001517          	auipc	a0,0x1
ffffffffc0200de4:	21850513          	addi	a0,a0,536 # ffffffffc0201ff8 <etext+0x88c>
ffffffffc0200de8:	b60ff0ef          	jal	ffffffffc0200148 <cprintf>
    struct Page *p_merged = alloc_pages(8);
ffffffffc0200dec:	4521                	li	a0,8
ffffffffc0200dee:	30a000ef          	jal	ffffffffc02010f8 <alloc_pages>
    assert(p_merged == p1);
ffffffffc0200df2:	12a49363          	bne	s1,a0,ffffffffc0200f18 <buddy_system_check+0x49c>
    cprintf("     Allocated merged block p_merged(8):\n");
ffffffffc0200df6:	00001517          	auipc	a0,0x1
ffffffffc0200dfa:	23250513          	addi	a0,a0,562 # ffffffffc0202028 <etext+0x8bc>
ffffffffc0200dfe:	b4aff0ef          	jal	ffffffffc0200148 <cprintf>
    print_buddy_system_status();
ffffffffc0200e02:	f9eff0ef          	jal	ffffffffc02005a0 <print_buddy_system_status>
    free_pages(p_merged, 8);
ffffffffc0200e06:	8526                	mv	a0,s1
ffffffffc0200e08:	45a1                	li	a1,8
ffffffffc0200e0a:	2fa000ef          	jal	ffffffffc0201104 <free_pages>
    assert(buddy_system_nr_free_pages() == free_after_prepare);
ffffffffc0200e0e:	00093783          	ld	a5,0(s2)
ffffffffc0200e12:	0efa1363          	bne	s4,a5,ffffffffc0200ef8 <buddy_system_check+0x47c>
    cprintf("     Freed merged block:\n");
ffffffffc0200e16:	00001517          	auipc	a0,0x1
ffffffffc0200e1a:	24250513          	addi	a0,a0,578 # ffffffffc0202058 <etext+0x8ec>
ffffffffc0200e1e:	b2aff0ef          	jal	ffffffffc0200148 <cprintf>
    print_buddy_system_status();
ffffffffc0200e22:	f7eff0ef          	jal	ffffffffc02005a0 <print_buddy_system_status>

    cprintf("  f. Restoring smaller blocks...\n");
ffffffffc0200e26:	00001517          	auipc	a0,0x1
ffffffffc0200e2a:	25250513          	addi	a0,a0,594 # ffffffffc0202078 <etext+0x90c>
ffffffffc0200e2e:	b1aff0ef          	jal	ffffffffc0200148 <cprintf>
    if (p_temp1) free_pages(p_temp1, 1);
ffffffffc0200e32:	000b8663          	beqz	s7,ffffffffc0200e3e <buddy_system_check+0x3c2>
ffffffffc0200e36:	855e                	mv	a0,s7
ffffffffc0200e38:	4585                	li	a1,1
ffffffffc0200e3a:	2ca000ef          	jal	ffffffffc0201104 <free_pages>
    if (p_temp2) free_pages(p_temp2, 2);
ffffffffc0200e3e:	000b0663          	beqz	s6,ffffffffc0200e4a <buddy_system_check+0x3ce>
ffffffffc0200e42:	855a                	mv	a0,s6
ffffffffc0200e44:	4589                	li	a1,2
ffffffffc0200e46:	2be000ef          	jal	ffffffffc0201104 <free_pages>
    if (p_temp4) free_pages(p_temp4, 4);
ffffffffc0200e4a:	000a8663          	beqz	s5,ffffffffc0200e56 <buddy_system_check+0x3da>
ffffffffc0200e4e:	8556                	mv	a0,s5
ffffffffc0200e50:	4591                	li	a1,4
ffffffffc0200e52:	2b2000ef          	jal	ffffffffc0201104 <free_pages>
    assert(buddy_system_nr_free_pages() == initial_free);
ffffffffc0200e56:	00093783          	ld	a5,0(s2)
ffffffffc0200e5a:	06f99f63          	bne	s3,a5,ffffffffc0200ed8 <buddy_system_check+0x45c>
    cprintf("     Final state after all tests:\n");
ffffffffc0200e5e:	00001517          	auipc	a0,0x1
ffffffffc0200e62:	24250513          	addi	a0,a0,578 # ffffffffc02020a0 <etext+0x934>
ffffffffc0200e66:	ae2ff0ef          	jal	ffffffffc0200148 <cprintf>
    print_buddy_system_status();
ffffffffc0200e6a:	f36ff0ef          	jal	ffffffffc02005a0 <print_buddy_system_status>

    cprintf("buddy_system_check(): split and merge pass.\n");
ffffffffc0200e6e:	00001517          	auipc	a0,0x1
ffffffffc0200e72:	25a50513          	addi	a0,a0,602 # ffffffffc02020c8 <etext+0x95c>
ffffffffc0200e76:	ad2ff0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("==================================================\n");
ffffffffc0200e7a:	00001517          	auipc	a0,0x1
ffffffffc0200e7e:	c2650513          	addi	a0,a0,-986 # ffffffffc0201aa0 <etext+0x334>
ffffffffc0200e82:	ac6ff0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("buddy_system_check() ALL PASSED!\n");
ffffffffc0200e86:	00001517          	auipc	a0,0x1
ffffffffc0200e8a:	27250513          	addi	a0,a0,626 # ffffffffc02020f8 <etext+0x98c>
ffffffffc0200e8e:	abaff0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("==================================================\n");
}
ffffffffc0200e92:	6446                	ld	s0,80(sp)
ffffffffc0200e94:	60e6                	ld	ra,88(sp)
ffffffffc0200e96:	64a6                	ld	s1,72(sp)
ffffffffc0200e98:	6906                	ld	s2,64(sp)
ffffffffc0200e9a:	79e2                	ld	s3,56(sp)
ffffffffc0200e9c:	7a42                	ld	s4,48(sp)
ffffffffc0200e9e:	7aa2                	ld	s5,40(sp)
ffffffffc0200ea0:	7b02                	ld	s6,32(sp)
ffffffffc0200ea2:	6be2                	ld	s7,24(sp)
ffffffffc0200ea4:	6c42                	ld	s8,16(sp)
ffffffffc0200ea6:	6ca2                	ld	s9,8(sp)
ffffffffc0200ea8:	6d02                	ld	s10,0(sp)
    cprintf("==================================================\n");
ffffffffc0200eaa:	00001517          	auipc	a0,0x1
ffffffffc0200eae:	bf650513          	addi	a0,a0,-1034 # ffffffffc0201aa0 <etext+0x334>
}
ffffffffc0200eb2:	6125                	addi	sp,sp,96
    cprintf("==================================================\n");
ffffffffc0200eb4:	a94ff06f          	j	ffffffffc0200148 <cprintf>
    p1 = alloc_pages(1); assert(p1 != NULL);
ffffffffc0200eb8:	00001697          	auipc	a3,0x1
ffffffffc0200ebc:	ca068693          	addi	a3,a3,-864 # ffffffffc0201b58 <etext+0x3ec>
ffffffffc0200ec0:	00001617          	auipc	a2,0x1
ffffffffc0200ec4:	b5860613          	addi	a2,a2,-1192 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc0200ec8:	0d200593          	li	a1,210
ffffffffc0200ecc:	00001517          	auipc	a0,0x1
ffffffffc0200ed0:	b6450513          	addi	a0,a0,-1180 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc0200ed4:	af4ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(buddy_system_nr_free_pages() == initial_free);
ffffffffc0200ed8:	00001697          	auipc	a3,0x1
ffffffffc0200edc:	d0068693          	addi	a3,a3,-768 # ffffffffc0201bd8 <etext+0x46c>
ffffffffc0200ee0:	00001617          	auipc	a2,0x1
ffffffffc0200ee4:	b3860613          	addi	a2,a2,-1224 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc0200ee8:	12f00593          	li	a1,303
ffffffffc0200eec:	00001517          	auipc	a0,0x1
ffffffffc0200ef0:	b4450513          	addi	a0,a0,-1212 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc0200ef4:	ad4ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(buddy_system_nr_free_pages() == free_after_prepare);
ffffffffc0200ef8:	00001697          	auipc	a3,0x1
ffffffffc0200efc:	0c868693          	addi	a3,a3,200 # ffffffffc0201fc0 <etext+0x854>
ffffffffc0200f00:	00001617          	auipc	a2,0x1
ffffffffc0200f04:	b1860613          	addi	a2,a2,-1256 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc0200f08:	12700593          	li	a1,295
ffffffffc0200f0c:	00001517          	auipc	a0,0x1
ffffffffc0200f10:	b2450513          	addi	a0,a0,-1244 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc0200f14:	ab4ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(p_merged == p1);
ffffffffc0200f18:	00001697          	auipc	a3,0x1
ffffffffc0200f1c:	10068693          	addi	a3,a3,256 # ffffffffc0202018 <etext+0x8ac>
ffffffffc0200f20:	00001617          	auipc	a2,0x1
ffffffffc0200f24:	af860613          	addi	a2,a2,-1288 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc0200f28:	12300593          	li	a1,291
ffffffffc0200f2c:	00001517          	auipc	a0,0x1
ffffffffc0200f30:	b0450513          	addi	a0,a0,-1276 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc0200f34:	a94ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(buddy_system_nr_free_pages() == free_after_prepare);
ffffffffc0200f38:	00001697          	auipc	a3,0x1
ffffffffc0200f3c:	08868693          	addi	a3,a3,136 # ffffffffc0201fc0 <etext+0x854>
ffffffffc0200f40:	00001617          	auipc	a2,0x1
ffffffffc0200f44:	ad860613          	addi	a2,a2,-1320 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc0200f48:	11f00593          	li	a1,287
ffffffffc0200f4c:	00001517          	auipc	a0,0x1
ffffffffc0200f50:	ae450513          	addi	a0,a0,-1308 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc0200f54:	a74ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(p_right == get_buddy_addr(p_left, 2)); 
ffffffffc0200f58:	00001697          	auipc	a3,0x1
ffffffffc0200f5c:	fd868693          	addi	a3,a3,-40 # ffffffffc0201f30 <etext+0x7c4>
ffffffffc0200f60:	00001617          	auipc	a2,0x1
ffffffffc0200f64:	ab860613          	addi	a2,a2,-1352 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc0200f68:	11600593          	li	a1,278
ffffffffc0200f6c:	00001517          	auipc	a0,0x1
ffffffffc0200f70:	ac450513          	addi	a0,a0,-1340 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc0200f74:	a54ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(p_right != NULL);
ffffffffc0200f78:	00001697          	auipc	a3,0x1
ffffffffc0200f7c:	f7068693          	addi	a3,a3,-144 # ffffffffc0201ee8 <etext+0x77c>
ffffffffc0200f80:	00001617          	auipc	a2,0x1
ffffffffc0200f84:	a9860613          	addi	a2,a2,-1384 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc0200f88:	11300593          	li	a1,275
ffffffffc0200f8c:	00001517          	auipc	a0,0x1
ffffffffc0200f90:	aa450513          	addi	a0,a0,-1372 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc0200f94:	a34ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(p_left == p1);
ffffffffc0200f98:	00001697          	auipc	a3,0x1
ffffffffc0200f9c:	f4068693          	addi	a3,a3,-192 # ffffffffc0201ed8 <etext+0x76c>
ffffffffc0200fa0:	00001617          	auipc	a2,0x1
ffffffffc0200fa4:	a7860613          	addi	a2,a2,-1416 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc0200fa8:	11000593          	li	a1,272
ffffffffc0200fac:	00001517          	auipc	a0,0x1
ffffffffc0200fb0:	a8450513          	addi	a0,a0,-1404 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc0200fb4:	a14ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(p_left != NULL);
ffffffffc0200fb8:	00001697          	auipc	a3,0x1
ffffffffc0200fbc:	ed868693          	addi	a3,a3,-296 # ffffffffc0201e90 <etext+0x724>
ffffffffc0200fc0:	00001617          	auipc	a2,0x1
ffffffffc0200fc4:	a5860613          	addi	a2,a2,-1448 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc0200fc8:	10d00593          	li	a1,269
ffffffffc0200fcc:	00001517          	auipc	a0,0x1
ffffffffc0200fd0:	a6450513          	addi	a0,a0,-1436 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc0200fd4:	9f4ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(p1 != NULL);
ffffffffc0200fd8:	00001697          	auipc	a3,0x1
ffffffffc0200fdc:	b8068693          	addi	a3,a3,-1152 # ffffffffc0201b58 <etext+0x3ec>
ffffffffc0200fe0:	00001617          	auipc	a2,0x1
ffffffffc0200fe4:	a3860613          	addi	a2,a2,-1480 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc0200fe8:	10300593          	li	a1,259
ffffffffc0200fec:	00001517          	auipc	a0,0x1
ffffffffc0200ff0:	a4450513          	addi	a0,a0,-1468 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc0200ff4:	9d4ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(buddy_system_nr_free_pages() == initial_free);
ffffffffc0200ff8:	00001697          	auipc	a3,0x1
ffffffffc0200ffc:	be068693          	addi	a3,a3,-1056 # ffffffffc0201bd8 <etext+0x46c>
ffffffffc0201000:	00001617          	auipc	a2,0x1
ffffffffc0201004:	a1860613          	addi	a2,a2,-1512 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc0201008:	0f100593          	li	a1,241
ffffffffc020100c:	00001517          	auipc	a0,0x1
ffffffffc0201010:	a2450513          	addi	a0,a0,-1500 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc0201014:	9b4ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(p1 != NULL);
ffffffffc0201018:	00001697          	auipc	a3,0x1
ffffffffc020101c:	b4068693          	addi	a3,a3,-1216 # ffffffffc0201b58 <etext+0x3ec>
ffffffffc0201020:	00001617          	auipc	a2,0x1
ffffffffc0201024:	9f860613          	addi	a2,a2,-1544 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc0201028:	0ec00593          	li	a1,236
ffffffffc020102c:	00001517          	auipc	a0,0x1
ffffffffc0201030:	a0450513          	addi	a0,a0,-1532 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc0201034:	994ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(alloc_pages(0) == NULL);
ffffffffc0201038:	00001697          	auipc	a3,0x1
ffffffffc020103c:	c6868693          	addi	a3,a3,-920 # ffffffffc0201ca0 <etext+0x534>
ffffffffc0201040:	00001617          	auipc	a2,0x1
ffffffffc0201044:	9d860613          	addi	a2,a2,-1576 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc0201048:	0e400593          	li	a1,228
ffffffffc020104c:	00001517          	auipc	a0,0x1
ffffffffc0201050:	9e450513          	addi	a0,a0,-1564 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc0201054:	974ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(alloc_pages(3) == NULL); // 非2的幂次
ffffffffc0201058:	00001697          	auipc	a3,0x1
ffffffffc020105c:	c3068693          	addi	a3,a3,-976 # ffffffffc0201c88 <etext+0x51c>
ffffffffc0201060:	00001617          	auipc	a2,0x1
ffffffffc0201064:	9b860613          	addi	a2,a2,-1608 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc0201068:	0e300593          	li	a1,227
ffffffffc020106c:	00001517          	auipc	a0,0x1
ffffffffc0201070:	9c450513          	addi	a0,a0,-1596 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc0201074:	954ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(buddy_system_nr_free_pages() == initial_free);
ffffffffc0201078:	00001697          	auipc	a3,0x1
ffffffffc020107c:	b6068693          	addi	a3,a3,-1184 # ffffffffc0201bd8 <etext+0x46c>
ffffffffc0201080:	00001617          	auipc	a2,0x1
ffffffffc0201084:	99860613          	addi	a2,a2,-1640 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc0201088:	0dc00593          	li	a1,220
ffffffffc020108c:	00001517          	auipc	a0,0x1
ffffffffc0201090:	9a450513          	addi	a0,a0,-1628 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc0201094:	934ff0ef          	jal	ffffffffc02001c8 <__panic>
    assert(p1 != p2 && p1 != p4 && p2 != p4);
ffffffffc0201098:	00001697          	auipc	a3,0x1
ffffffffc020109c:	af068693          	addi	a3,a3,-1296 # ffffffffc0201b88 <etext+0x41c>
ffffffffc02010a0:	00001617          	auipc	a2,0x1
ffffffffc02010a4:	97860613          	addi	a2,a2,-1672 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc02010a8:	0d500593          	li	a1,213
ffffffffc02010ac:	00001517          	auipc	a0,0x1
ffffffffc02010b0:	98450513          	addi	a0,a0,-1660 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc02010b4:	914ff0ef          	jal	ffffffffc02001c8 <__panic>
    p4 = alloc_pages(4); assert(p4 != NULL);
ffffffffc02010b8:	00001697          	auipc	a3,0x1
ffffffffc02010bc:	ac068693          	addi	a3,a3,-1344 # ffffffffc0201b78 <etext+0x40c>
ffffffffc02010c0:	00001617          	auipc	a2,0x1
ffffffffc02010c4:	95860613          	addi	a2,a2,-1704 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc02010c8:	0d400593          	li	a1,212
ffffffffc02010cc:	00001517          	auipc	a0,0x1
ffffffffc02010d0:	96450513          	addi	a0,a0,-1692 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc02010d4:	8f4ff0ef          	jal	ffffffffc02001c8 <__panic>
    p2 = alloc_pages(2); assert(p2 != NULL);
ffffffffc02010d8:	00001697          	auipc	a3,0x1
ffffffffc02010dc:	a9068693          	addi	a3,a3,-1392 # ffffffffc0201b68 <etext+0x3fc>
ffffffffc02010e0:	00001617          	auipc	a2,0x1
ffffffffc02010e4:	93860613          	addi	a2,a2,-1736 # ffffffffc0201a18 <etext+0x2ac>
ffffffffc02010e8:	0d300593          	li	a1,211
ffffffffc02010ec:	00001517          	auipc	a0,0x1
ffffffffc02010f0:	94450513          	addi	a0,a0,-1724 # ffffffffc0201a30 <etext+0x2c4>
ffffffffc02010f4:	8d4ff0ef          	jal	ffffffffc02001c8 <__panic>

ffffffffc02010f8 <alloc_pages>:
}

// alloc_pages - call pmm->alloc_pages to allocate a continuous n*PAGESIZE
// memory
struct Page *alloc_pages(size_t n) {
    return pmm_manager->alloc_pages(n);
ffffffffc02010f8:	00005797          	auipc	a5,0x5
ffffffffc02010fc:	0a87b783          	ld	a5,168(a5) # ffffffffc02061a0 <pmm_manager>
ffffffffc0201100:	6f9c                	ld	a5,24(a5)
ffffffffc0201102:	8782                	jr	a5

ffffffffc0201104 <free_pages>:
}

// free_pages - call pmm->free_pages to free a continuous n*PAGESIZE memory
void free_pages(struct Page *base, size_t n) {
    pmm_manager->free_pages(base, n);
ffffffffc0201104:	00005797          	auipc	a5,0x5
ffffffffc0201108:	09c7b783          	ld	a5,156(a5) # ffffffffc02061a0 <pmm_manager>
ffffffffc020110c:	739c                	ld	a5,32(a5)
ffffffffc020110e:	8782                	jr	a5

ffffffffc0201110 <pmm_init>:
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0201110:	00001797          	auipc	a5,0x1
ffffffffc0201114:	25078793          	addi	a5,a5,592 # ffffffffc0202360 <buddy_system_pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201118:	638c                	ld	a1,0(a5)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
    }
}

/* pmm_init - initialize the physical memory management */
void pmm_init(void) {
ffffffffc020111a:	7139                	addi	sp,sp,-64
ffffffffc020111c:	fc06                	sd	ra,56(sp)
ffffffffc020111e:	f822                	sd	s0,48(sp)
ffffffffc0201120:	f426                	sd	s1,40(sp)
ffffffffc0201122:	ec4e                	sd	s3,24(sp)
ffffffffc0201124:	f04a                	sd	s2,32(sp)
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0201126:	00005417          	auipc	s0,0x5
ffffffffc020112a:	07a40413          	addi	s0,s0,122 # ffffffffc02061a0 <pmm_manager>
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc020112e:	00001517          	auipc	a0,0x1
ffffffffc0201132:	01250513          	addi	a0,a0,18 # ffffffffc0202140 <etext+0x9d4>
    pmm_manager = &buddy_system_pmm_manager;
ffffffffc0201136:	e01c                	sd	a5,0(s0)
    cprintf("memory management: %s\n", pmm_manager->name);
ffffffffc0201138:	810ff0ef          	jal	ffffffffc0200148 <cprintf>
    pmm_manager->init();
ffffffffc020113c:	601c                	ld	a5,0(s0)
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020113e:	00005497          	auipc	s1,0x5
ffffffffc0201142:	07a48493          	addi	s1,s1,122 # ffffffffc02061b8 <va_pa_offset>
    pmm_manager->init();
ffffffffc0201146:	679c                	ld	a5,8(a5)
ffffffffc0201148:	9782                	jalr	a5
    va_pa_offset = PHYSICAL_MEMORY_OFFSET;
ffffffffc020114a:	57f5                	li	a5,-3
ffffffffc020114c:	07fa                	slli	a5,a5,0x1e
ffffffffc020114e:	e09c                	sd	a5,0(s1)
    uint64_t mem_begin = get_memory_base();
ffffffffc0201150:	c0aff0ef          	jal	ffffffffc020055a <get_memory_base>
ffffffffc0201154:	89aa                	mv	s3,a0
    uint64_t mem_size  = get_memory_size();
ffffffffc0201156:	c0eff0ef          	jal	ffffffffc0200564 <get_memory_size>
    if (mem_size == 0) {
ffffffffc020115a:	14050c63          	beqz	a0,ffffffffc02012b2 <pmm_init+0x1a2>
    uint64_t mem_end   = mem_begin + mem_size;
ffffffffc020115e:	00a98933          	add	s2,s3,a0
ffffffffc0201162:	e42a                	sd	a0,8(sp)
    cprintf("physcial memory map:\n");
ffffffffc0201164:	00001517          	auipc	a0,0x1
ffffffffc0201168:	02450513          	addi	a0,a0,36 # ffffffffc0202188 <etext+0xa1c>
ffffffffc020116c:	fddfe0ef          	jal	ffffffffc0200148 <cprintf>
    cprintf("  memory: 0x%016lx, [0x%016lx, 0x%016lx].\n", mem_size, mem_begin,
ffffffffc0201170:	65a2                	ld	a1,8(sp)
ffffffffc0201172:	864e                	mv	a2,s3
ffffffffc0201174:	fff90693          	addi	a3,s2,-1
ffffffffc0201178:	00001517          	auipc	a0,0x1
ffffffffc020117c:	02850513          	addi	a0,a0,40 # ffffffffc02021a0 <etext+0xa34>
ffffffffc0201180:	fc9fe0ef          	jal	ffffffffc0200148 <cprintf>
    if (maxpa > KERNTOP) {
ffffffffc0201184:	c80007b7          	lui	a5,0xc8000
ffffffffc0201188:	85ca                	mv	a1,s2
ffffffffc020118a:	0d27e263          	bltu	a5,s2,ffffffffc020124e <pmm_init+0x13e>
ffffffffc020118e:	77fd                	lui	a5,0xfffff
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc0201190:	00006697          	auipc	a3,0x6
ffffffffc0201194:	03f68693          	addi	a3,a3,63 # ffffffffc02071cf <end+0xfff>
ffffffffc0201198:	8efd                	and	a3,a3,a5
    npage = maxpa / PGSIZE;
ffffffffc020119a:	81b1                	srli	a1,a1,0xc
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc020119c:	fff80837          	lui	a6,0xfff80
    npage = maxpa / PGSIZE;
ffffffffc02011a0:	00005797          	auipc	a5,0x5
ffffffffc02011a4:	02b7b023          	sd	a1,32(a5) # ffffffffc02061c0 <npage>
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02011a8:	00005797          	auipc	a5,0x5
ffffffffc02011ac:	02d7b023          	sd	a3,32(a5) # ffffffffc02061c8 <pages>
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02011b0:	982e                	add	a6,a6,a1
    pages = (struct Page *)ROUNDUP((void *)end, PGSIZE);
ffffffffc02011b2:	88b6                	mv	a7,a3
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02011b4:	02080963          	beqz	a6,ffffffffc02011e6 <pmm_init+0xd6>
ffffffffc02011b8:	00259613          	slli	a2,a1,0x2
ffffffffc02011bc:	962e                	add	a2,a2,a1
ffffffffc02011be:	fec007b7          	lui	a5,0xfec00
ffffffffc02011c2:	97b6                	add	a5,a5,a3
ffffffffc02011c4:	060e                	slli	a2,a2,0x3
ffffffffc02011c6:	963e                	add	a2,a2,a5
ffffffffc02011c8:	87b6                	mv	a5,a3
        SetPageReserved(pages + i);
ffffffffc02011ca:	6798                	ld	a4,8(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02011cc:	02878793          	addi	a5,a5,40 # fffffffffec00028 <end+0x3e9f9e58>
        SetPageReserved(pages + i);
ffffffffc02011d0:	00176713          	ori	a4,a4,1
ffffffffc02011d4:	fee7b023          	sd	a4,-32(a5)
    for (size_t i = 0; i < npage - nbase; i++) {
ffffffffc02011d8:	fec799e3          	bne	a5,a2,ffffffffc02011ca <pmm_init+0xba>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02011dc:	00281793          	slli	a5,a6,0x2
ffffffffc02011e0:	97c2                	add	a5,a5,a6
ffffffffc02011e2:	078e                	slli	a5,a5,0x3
ffffffffc02011e4:	96be                	add	a3,a3,a5
ffffffffc02011e6:	c02007b7          	lui	a5,0xc0200
ffffffffc02011ea:	0af6e863          	bltu	a3,a5,ffffffffc020129a <pmm_init+0x18a>
ffffffffc02011ee:	6098                	ld	a4,0(s1)
    mem_end = ROUNDDOWN(mem_end, PGSIZE);
ffffffffc02011f0:	77fd                	lui	a5,0xfffff
ffffffffc02011f2:	00f97933          	and	s2,s2,a5
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc02011f6:	8e99                	sub	a3,a3,a4
    if (freemem < mem_end) {
ffffffffc02011f8:	0526ed63          	bltu	a3,s2,ffffffffc0201252 <pmm_init+0x142>
    satp_physical = PADDR(satp_virtual);
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
}

static void check_alloc_page(void) {
    pmm_manager->check();
ffffffffc02011fc:	601c                	ld	a5,0(s0)
ffffffffc02011fe:	7b9c                	ld	a5,48(a5)
ffffffffc0201200:	9782                	jalr	a5
    cprintf("check_alloc_page() succeeded!\n");
ffffffffc0201202:	00001517          	auipc	a0,0x1
ffffffffc0201206:	02650513          	addi	a0,a0,38 # ffffffffc0202228 <etext+0xabc>
ffffffffc020120a:	f3ffe0ef          	jal	ffffffffc0200148 <cprintf>
    satp_virtual = (pte_t*)boot_page_table_sv39;
ffffffffc020120e:	00004597          	auipc	a1,0x4
ffffffffc0201212:	df258593          	addi	a1,a1,-526 # ffffffffc0205000 <boot_page_table_sv39>
ffffffffc0201216:	00005797          	auipc	a5,0x5
ffffffffc020121a:	f8b7bd23          	sd	a1,-102(a5) # ffffffffc02061b0 <satp_virtual>
    satp_physical = PADDR(satp_virtual);
ffffffffc020121e:	c02007b7          	lui	a5,0xc0200
ffffffffc0201222:	0af5e463          	bltu	a1,a5,ffffffffc02012ca <pmm_init+0x1ba>
ffffffffc0201226:	609c                	ld	a5,0(s1)
}
ffffffffc0201228:	7442                	ld	s0,48(sp)
ffffffffc020122a:	70e2                	ld	ra,56(sp)
ffffffffc020122c:	74a2                	ld	s1,40(sp)
ffffffffc020122e:	7902                	ld	s2,32(sp)
ffffffffc0201230:	69e2                	ld	s3,24(sp)
    satp_physical = PADDR(satp_virtual);
ffffffffc0201232:	40f586b3          	sub	a3,a1,a5
ffffffffc0201236:	00005797          	auipc	a5,0x5
ffffffffc020123a:	f6d7b923          	sd	a3,-142(a5) # ffffffffc02061a8 <satp_physical>
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020123e:	00001517          	auipc	a0,0x1
ffffffffc0201242:	00a50513          	addi	a0,a0,10 # ffffffffc0202248 <etext+0xadc>
ffffffffc0201246:	8636                	mv	a2,a3
}
ffffffffc0201248:	6121                	addi	sp,sp,64
    cprintf("satp virtual address: 0x%016lx\nsatp physical address: 0x%016lx\n", satp_virtual, satp_physical);
ffffffffc020124a:	efffe06f          	j	ffffffffc0200148 <cprintf>
    if (maxpa > KERNTOP) {
ffffffffc020124e:	85be                	mv	a1,a5
ffffffffc0201250:	bf3d                	j	ffffffffc020118e <pmm_init+0x7e>
    mem_begin = ROUNDUP(freemem, PGSIZE);
ffffffffc0201252:	6705                	lui	a4,0x1
ffffffffc0201254:	177d                	addi	a4,a4,-1 # fff <kern_entry-0xffffffffc01ff001>
ffffffffc0201256:	96ba                	add	a3,a3,a4
ffffffffc0201258:	8efd                	and	a3,a3,a5
static inline int page_ref_dec(struct Page *page) {
    page->ref -= 1;
    return page->ref;
}
static inline struct Page *pa2page(uintptr_t pa) {
    if (PPN(pa) >= npage) {
ffffffffc020125a:	00c6d793          	srli	a5,a3,0xc
ffffffffc020125e:	02b7f263          	bgeu	a5,a1,ffffffffc0201282 <pmm_init+0x172>
    pmm_manager->init_memmap(base, n);
ffffffffc0201262:	6018                	ld	a4,0(s0)
        panic("pa2page called with invalid pa");
    }
    return &pages[PPN(pa) - nbase];
ffffffffc0201264:	fff80637          	lui	a2,0xfff80
ffffffffc0201268:	97b2                	add	a5,a5,a2
ffffffffc020126a:	00279513          	slli	a0,a5,0x2
ffffffffc020126e:	953e                	add	a0,a0,a5
ffffffffc0201270:	6b1c                	ld	a5,16(a4)
        init_memmap(pa2page(mem_begin), (mem_end - mem_begin) / PGSIZE);
ffffffffc0201272:	40d90933          	sub	s2,s2,a3
ffffffffc0201276:	050e                	slli	a0,a0,0x3
    pmm_manager->init_memmap(base, n);
ffffffffc0201278:	00c95593          	srli	a1,s2,0xc
ffffffffc020127c:	9546                	add	a0,a0,a7
ffffffffc020127e:	9782                	jalr	a5
}
ffffffffc0201280:	bfb5                	j	ffffffffc02011fc <pmm_init+0xec>
        panic("pa2page called with invalid pa");
ffffffffc0201282:	00001617          	auipc	a2,0x1
ffffffffc0201286:	f7660613          	addi	a2,a2,-138 # ffffffffc02021f8 <etext+0xa8c>
ffffffffc020128a:	06a00593          	li	a1,106
ffffffffc020128e:	00001517          	auipc	a0,0x1
ffffffffc0201292:	f8a50513          	addi	a0,a0,-118 # ffffffffc0202218 <etext+0xaac>
ffffffffc0201296:	f33fe0ef          	jal	ffffffffc02001c8 <__panic>
    uintptr_t freemem = PADDR((uintptr_t)pages + sizeof(struct Page) * (npage - nbase));
ffffffffc020129a:	00001617          	auipc	a2,0x1
ffffffffc020129e:	f3660613          	addi	a2,a2,-202 # ffffffffc02021d0 <etext+0xa64>
ffffffffc02012a2:	05f00593          	li	a1,95
ffffffffc02012a6:	00001517          	auipc	a0,0x1
ffffffffc02012aa:	ed250513          	addi	a0,a0,-302 # ffffffffc0202178 <etext+0xa0c>
ffffffffc02012ae:	f1bfe0ef          	jal	ffffffffc02001c8 <__panic>
        panic("DTB memory info not available");
ffffffffc02012b2:	00001617          	auipc	a2,0x1
ffffffffc02012b6:	ea660613          	addi	a2,a2,-346 # ffffffffc0202158 <etext+0x9ec>
ffffffffc02012ba:	04700593          	li	a1,71
ffffffffc02012be:	00001517          	auipc	a0,0x1
ffffffffc02012c2:	eba50513          	addi	a0,a0,-326 # ffffffffc0202178 <etext+0xa0c>
ffffffffc02012c6:	f03fe0ef          	jal	ffffffffc02001c8 <__panic>
    satp_physical = PADDR(satp_virtual);
ffffffffc02012ca:	86ae                	mv	a3,a1
ffffffffc02012cc:	00001617          	auipc	a2,0x1
ffffffffc02012d0:	f0460613          	addi	a2,a2,-252 # ffffffffc02021d0 <etext+0xa64>
ffffffffc02012d4:	07a00593          	li	a1,122
ffffffffc02012d8:	00001517          	auipc	a0,0x1
ffffffffc02012dc:	ea050513          	addi	a0,a0,-352 # ffffffffc0202178 <etext+0xa0c>
ffffffffc02012e0:	ee9fe0ef          	jal	ffffffffc02001c8 <__panic>

ffffffffc02012e4 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02012e4:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
ffffffffc02012e6:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02012ea:	f022                	sd	s0,32(sp)
ffffffffc02012ec:	ec26                	sd	s1,24(sp)
ffffffffc02012ee:	e84a                	sd	s2,16(sp)
ffffffffc02012f0:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
ffffffffc02012f2:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc02012f6:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
ffffffffc02012f8:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
ffffffffc02012fc:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
ffffffffc0201300:	84aa                	mv	s1,a0
ffffffffc0201302:	892e                	mv	s2,a1
    if (num >= base) {
ffffffffc0201304:	03067d63          	bgeu	a2,a6,ffffffffc020133e <printnum+0x5a>
ffffffffc0201308:	e44e                	sd	s3,8(sp)
ffffffffc020130a:	89be                	mv	s3,a5
        while (-- width > 0)
ffffffffc020130c:	4785                	li	a5,1
ffffffffc020130e:	00e7d763          	bge	a5,a4,ffffffffc020131c <printnum+0x38>
            putch(padc, putdat);
ffffffffc0201312:	85ca                	mv	a1,s2
ffffffffc0201314:	854e                	mv	a0,s3
        while (-- width > 0)
ffffffffc0201316:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
ffffffffc0201318:	9482                	jalr	s1
        while (-- width > 0)
ffffffffc020131a:	fc65                	bnez	s0,ffffffffc0201312 <printnum+0x2e>
ffffffffc020131c:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020131e:	00001797          	auipc	a5,0x1
ffffffffc0201322:	f6a78793          	addi	a5,a5,-150 # ffffffffc0202288 <etext+0xb1c>
ffffffffc0201326:	97d2                	add	a5,a5,s4
}
ffffffffc0201328:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020132a:	0007c503          	lbu	a0,0(a5)
}
ffffffffc020132e:	70a2                	ld	ra,40(sp)
ffffffffc0201330:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
ffffffffc0201332:	85ca                	mv	a1,s2
ffffffffc0201334:	87a6                	mv	a5,s1
}
ffffffffc0201336:	6942                	ld	s2,16(sp)
ffffffffc0201338:	64e2                	ld	s1,24(sp)
ffffffffc020133a:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
ffffffffc020133c:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
ffffffffc020133e:	03065633          	divu	a2,a2,a6
ffffffffc0201342:	8722                	mv	a4,s0
ffffffffc0201344:	fa1ff0ef          	jal	ffffffffc02012e4 <printnum>
ffffffffc0201348:	bfd9                	j	ffffffffc020131e <printnum+0x3a>

ffffffffc020134a <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
ffffffffc020134a:	7119                	addi	sp,sp,-128
ffffffffc020134c:	f4a6                	sd	s1,104(sp)
ffffffffc020134e:	f0ca                	sd	s2,96(sp)
ffffffffc0201350:	ecce                	sd	s3,88(sp)
ffffffffc0201352:	e8d2                	sd	s4,80(sp)
ffffffffc0201354:	e4d6                	sd	s5,72(sp)
ffffffffc0201356:	e0da                	sd	s6,64(sp)
ffffffffc0201358:	f862                	sd	s8,48(sp)
ffffffffc020135a:	fc86                	sd	ra,120(sp)
ffffffffc020135c:	f8a2                	sd	s0,112(sp)
ffffffffc020135e:	fc5e                	sd	s7,56(sp)
ffffffffc0201360:	f466                	sd	s9,40(sp)
ffffffffc0201362:	f06a                	sd	s10,32(sp)
ffffffffc0201364:	ec6e                	sd	s11,24(sp)
ffffffffc0201366:	84aa                	mv	s1,a0
ffffffffc0201368:	8c32                	mv	s8,a2
ffffffffc020136a:	8a36                	mv	s4,a3
ffffffffc020136c:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020136e:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201372:	05500b13          	li	s6,85
ffffffffc0201376:	00001a97          	auipc	s5,0x1
ffffffffc020137a:	022a8a93          	addi	s5,s5,34 # ffffffffc0202398 <buddy_system_pmm_manager+0x38>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc020137e:	000c4503          	lbu	a0,0(s8)
ffffffffc0201382:	001c0413          	addi	s0,s8,1
ffffffffc0201386:	01350a63          	beq	a0,s3,ffffffffc020139a <vprintfmt+0x50>
            if (ch == '\0') {
ffffffffc020138a:	cd0d                	beqz	a0,ffffffffc02013c4 <vprintfmt+0x7a>
            putch(ch, putdat);
ffffffffc020138c:	85ca                	mv	a1,s2
ffffffffc020138e:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
ffffffffc0201390:	00044503          	lbu	a0,0(s0)
ffffffffc0201394:	0405                	addi	s0,s0,1
ffffffffc0201396:	ff351ae3          	bne	a0,s3,ffffffffc020138a <vprintfmt+0x40>
        width = precision = -1;
ffffffffc020139a:	5cfd                	li	s9,-1
ffffffffc020139c:	8d66                	mv	s10,s9
        char padc = ' ';
ffffffffc020139e:	02000d93          	li	s11,32
        lflag = altflag = 0;
ffffffffc02013a2:	4b81                	li	s7,0
ffffffffc02013a4:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02013a6:	00044683          	lbu	a3,0(s0)
ffffffffc02013aa:	00140c13          	addi	s8,s0,1
ffffffffc02013ae:	fdd6859b          	addiw	a1,a3,-35
ffffffffc02013b2:	0ff5f593          	zext.b	a1,a1
ffffffffc02013b6:	02bb6663          	bltu	s6,a1,ffffffffc02013e2 <vprintfmt+0x98>
ffffffffc02013ba:	058a                	slli	a1,a1,0x2
ffffffffc02013bc:	95d6                	add	a1,a1,s5
ffffffffc02013be:	4198                	lw	a4,0(a1)
ffffffffc02013c0:	9756                	add	a4,a4,s5
ffffffffc02013c2:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
ffffffffc02013c4:	70e6                	ld	ra,120(sp)
ffffffffc02013c6:	7446                	ld	s0,112(sp)
ffffffffc02013c8:	74a6                	ld	s1,104(sp)
ffffffffc02013ca:	7906                	ld	s2,96(sp)
ffffffffc02013cc:	69e6                	ld	s3,88(sp)
ffffffffc02013ce:	6a46                	ld	s4,80(sp)
ffffffffc02013d0:	6aa6                	ld	s5,72(sp)
ffffffffc02013d2:	6b06                	ld	s6,64(sp)
ffffffffc02013d4:	7be2                	ld	s7,56(sp)
ffffffffc02013d6:	7c42                	ld	s8,48(sp)
ffffffffc02013d8:	7ca2                	ld	s9,40(sp)
ffffffffc02013da:	7d02                	ld	s10,32(sp)
ffffffffc02013dc:	6de2                	ld	s11,24(sp)
ffffffffc02013de:	6109                	addi	sp,sp,128
ffffffffc02013e0:	8082                	ret
            putch('%', putdat);
ffffffffc02013e2:	85ca                	mv	a1,s2
ffffffffc02013e4:	02500513          	li	a0,37
ffffffffc02013e8:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
ffffffffc02013ea:	fff44783          	lbu	a5,-1(s0)
ffffffffc02013ee:	02500713          	li	a4,37
ffffffffc02013f2:	8c22                	mv	s8,s0
ffffffffc02013f4:	f8e785e3          	beq	a5,a4,ffffffffc020137e <vprintfmt+0x34>
ffffffffc02013f8:	ffec4783          	lbu	a5,-2(s8)
ffffffffc02013fc:	1c7d                	addi	s8,s8,-1
ffffffffc02013fe:	fee79de3          	bne	a5,a4,ffffffffc02013f8 <vprintfmt+0xae>
ffffffffc0201402:	bfb5                	j	ffffffffc020137e <vprintfmt+0x34>
                ch = *fmt;
ffffffffc0201404:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
ffffffffc0201408:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
ffffffffc020140a:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
ffffffffc020140e:	fd06071b          	addiw	a4,a2,-48
ffffffffc0201412:	24e56a63          	bltu	a0,a4,ffffffffc0201666 <vprintfmt+0x31c>
                ch = *fmt;
ffffffffc0201416:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201418:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
ffffffffc020141a:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
ffffffffc020141e:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
ffffffffc0201422:	0197073b          	addw	a4,a4,s9
ffffffffc0201426:	0017171b          	slliw	a4,a4,0x1
ffffffffc020142a:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
ffffffffc020142c:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
ffffffffc0201430:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
ffffffffc0201432:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
ffffffffc0201436:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
ffffffffc020143a:	feb570e3          	bgeu	a0,a1,ffffffffc020141a <vprintfmt+0xd0>
            if (width < 0)
ffffffffc020143e:	f60d54e3          	bgez	s10,ffffffffc02013a6 <vprintfmt+0x5c>
                width = precision, precision = -1;
ffffffffc0201442:	8d66                	mv	s10,s9
ffffffffc0201444:	5cfd                	li	s9,-1
ffffffffc0201446:	b785                	j	ffffffffc02013a6 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201448:	8db6                	mv	s11,a3
ffffffffc020144a:	8462                	mv	s0,s8
ffffffffc020144c:	bfa9                	j	ffffffffc02013a6 <vprintfmt+0x5c>
ffffffffc020144e:	8462                	mv	s0,s8
            altflag = 1;
ffffffffc0201450:	4b85                	li	s7,1
            goto reswitch;
ffffffffc0201452:	bf91                	j	ffffffffc02013a6 <vprintfmt+0x5c>
    if (lflag >= 2) {
ffffffffc0201454:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201456:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020145a:	00f74463          	blt	a4,a5,ffffffffc0201462 <vprintfmt+0x118>
    else if (lflag) {
ffffffffc020145e:	1a078763          	beqz	a5,ffffffffc020160c <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
ffffffffc0201462:	000a3603          	ld	a2,0(s4)
ffffffffc0201466:	46c1                	li	a3,16
ffffffffc0201468:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
ffffffffc020146a:	000d879b          	sext.w	a5,s11
ffffffffc020146e:	876a                	mv	a4,s10
ffffffffc0201470:	85ca                	mv	a1,s2
ffffffffc0201472:	8526                	mv	a0,s1
ffffffffc0201474:	e71ff0ef          	jal	ffffffffc02012e4 <printnum>
            break;
ffffffffc0201478:	b719                	j	ffffffffc020137e <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
ffffffffc020147a:	000a2503          	lw	a0,0(s4)
ffffffffc020147e:	85ca                	mv	a1,s2
ffffffffc0201480:	0a21                	addi	s4,s4,8
ffffffffc0201482:	9482                	jalr	s1
            break;
ffffffffc0201484:	bded                	j	ffffffffc020137e <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc0201486:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc0201488:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc020148c:	00f74463          	blt	a4,a5,ffffffffc0201494 <vprintfmt+0x14a>
    else if (lflag) {
ffffffffc0201490:	16078963          	beqz	a5,ffffffffc0201602 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
ffffffffc0201494:	000a3603          	ld	a2,0(s4)
ffffffffc0201498:	46a9                	li	a3,10
ffffffffc020149a:	8a2e                	mv	s4,a1
ffffffffc020149c:	b7f9                	j	ffffffffc020146a <vprintfmt+0x120>
            putch('0', putdat);
ffffffffc020149e:	85ca                	mv	a1,s2
ffffffffc02014a0:	03000513          	li	a0,48
ffffffffc02014a4:	9482                	jalr	s1
            putch('x', putdat);
ffffffffc02014a6:	85ca                	mv	a1,s2
ffffffffc02014a8:	07800513          	li	a0,120
ffffffffc02014ac:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02014ae:	000a3603          	ld	a2,0(s4)
            goto number;
ffffffffc02014b2:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
ffffffffc02014b4:	0a21                	addi	s4,s4,8
            goto number;
ffffffffc02014b6:	bf55                	j	ffffffffc020146a <vprintfmt+0x120>
            putch(ch, putdat);
ffffffffc02014b8:	85ca                	mv	a1,s2
ffffffffc02014ba:	02500513          	li	a0,37
ffffffffc02014be:	9482                	jalr	s1
            break;
ffffffffc02014c0:	bd7d                	j	ffffffffc020137e <vprintfmt+0x34>
            precision = va_arg(ap, int);
ffffffffc02014c2:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014c6:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
ffffffffc02014c8:	0a21                	addi	s4,s4,8
            goto process_precision;
ffffffffc02014ca:	bf95                	j	ffffffffc020143e <vprintfmt+0xf4>
    if (lflag >= 2) {
ffffffffc02014cc:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02014ce:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
ffffffffc02014d2:	00f74463          	blt	a4,a5,ffffffffc02014da <vprintfmt+0x190>
    else if (lflag) {
ffffffffc02014d6:	12078163          	beqz	a5,ffffffffc02015f8 <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
ffffffffc02014da:	000a3603          	ld	a2,0(s4)
ffffffffc02014de:	46a1                	li	a3,8
ffffffffc02014e0:	8a2e                	mv	s4,a1
ffffffffc02014e2:	b761                	j	ffffffffc020146a <vprintfmt+0x120>
            if (width < 0)
ffffffffc02014e4:	876a                	mv	a4,s10
ffffffffc02014e6:	000d5363          	bgez	s10,ffffffffc02014ec <vprintfmt+0x1a2>
ffffffffc02014ea:	4701                	li	a4,0
ffffffffc02014ec:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02014f0:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc02014f2:	bd55                	j	ffffffffc02013a6 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
ffffffffc02014f4:	000d841b          	sext.w	s0,s11
ffffffffc02014f8:	fd340793          	addi	a5,s0,-45
ffffffffc02014fc:	00f037b3          	snez	a5,a5
ffffffffc0201500:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201504:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
ffffffffc0201508:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020150a:	008a0793          	addi	a5,s4,8
ffffffffc020150e:	e43e                	sd	a5,8(sp)
ffffffffc0201510:	100d8c63          	beqz	s11,ffffffffc0201628 <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
ffffffffc0201514:	12071363          	bnez	a4,ffffffffc020163a <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201518:	000dc783          	lbu	a5,0(s11)
ffffffffc020151c:	0007851b          	sext.w	a0,a5
ffffffffc0201520:	c78d                	beqz	a5,ffffffffc020154a <vprintfmt+0x200>
ffffffffc0201522:	0d85                	addi	s11,s11,1
ffffffffc0201524:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201526:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020152a:	000cc563          	bltz	s9,ffffffffc0201534 <vprintfmt+0x1ea>
ffffffffc020152e:	3cfd                	addiw	s9,s9,-1
ffffffffc0201530:	008c8d63          	beq	s9,s0,ffffffffc020154a <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201534:	020b9663          	bnez	s7,ffffffffc0201560 <vprintfmt+0x216>
                    putch(ch, putdat);
ffffffffc0201538:	85ca                	mv	a1,s2
ffffffffc020153a:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020153c:	000dc783          	lbu	a5,0(s11)
ffffffffc0201540:	0d85                	addi	s11,s11,1
ffffffffc0201542:	3d7d                	addiw	s10,s10,-1
ffffffffc0201544:	0007851b          	sext.w	a0,a5
ffffffffc0201548:	f3ed                	bnez	a5,ffffffffc020152a <vprintfmt+0x1e0>
            for (; width > 0; width --) {
ffffffffc020154a:	01a05963          	blez	s10,ffffffffc020155c <vprintfmt+0x212>
                putch(' ', putdat);
ffffffffc020154e:	85ca                	mv	a1,s2
ffffffffc0201550:	02000513          	li	a0,32
            for (; width > 0; width --) {
ffffffffc0201554:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
ffffffffc0201556:	9482                	jalr	s1
            for (; width > 0; width --) {
ffffffffc0201558:	fe0d1be3          	bnez	s10,ffffffffc020154e <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc020155c:	6a22                	ld	s4,8(sp)
ffffffffc020155e:	b505                	j	ffffffffc020137e <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
ffffffffc0201560:	3781                	addiw	a5,a5,-32
ffffffffc0201562:	fcfa7be3          	bgeu	s4,a5,ffffffffc0201538 <vprintfmt+0x1ee>
                    putch('?', putdat);
ffffffffc0201566:	03f00513          	li	a0,63
ffffffffc020156a:	85ca                	mv	a1,s2
ffffffffc020156c:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020156e:	000dc783          	lbu	a5,0(s11)
ffffffffc0201572:	0d85                	addi	s11,s11,1
ffffffffc0201574:	3d7d                	addiw	s10,s10,-1
ffffffffc0201576:	0007851b          	sext.w	a0,a5
ffffffffc020157a:	dbe1                	beqz	a5,ffffffffc020154a <vprintfmt+0x200>
ffffffffc020157c:	fa0cd9e3          	bgez	s9,ffffffffc020152e <vprintfmt+0x1e4>
ffffffffc0201580:	b7c5                	j	ffffffffc0201560 <vprintfmt+0x216>
            if (err < 0) {
ffffffffc0201582:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201586:	4619                	li	a2,6
            err = va_arg(ap, int);
ffffffffc0201588:	0a21                	addi	s4,s4,8
            if (err < 0) {
ffffffffc020158a:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc020158e:	8fb9                	xor	a5,a5,a4
ffffffffc0201590:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
ffffffffc0201594:	02d64563          	blt	a2,a3,ffffffffc02015be <vprintfmt+0x274>
ffffffffc0201598:	00001797          	auipc	a5,0x1
ffffffffc020159c:	f5878793          	addi	a5,a5,-168 # ffffffffc02024f0 <error_string>
ffffffffc02015a0:	00369713          	slli	a4,a3,0x3
ffffffffc02015a4:	97ba                	add	a5,a5,a4
ffffffffc02015a6:	639c                	ld	a5,0(a5)
ffffffffc02015a8:	cb99                	beqz	a5,ffffffffc02015be <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
ffffffffc02015aa:	86be                	mv	a3,a5
ffffffffc02015ac:	00001617          	auipc	a2,0x1
ffffffffc02015b0:	d0c60613          	addi	a2,a2,-756 # ffffffffc02022b8 <etext+0xb4c>
ffffffffc02015b4:	85ca                	mv	a1,s2
ffffffffc02015b6:	8526                	mv	a0,s1
ffffffffc02015b8:	0d8000ef          	jal	ffffffffc0201690 <printfmt>
ffffffffc02015bc:	b3c9                	j	ffffffffc020137e <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
ffffffffc02015be:	00001617          	auipc	a2,0x1
ffffffffc02015c2:	cea60613          	addi	a2,a2,-790 # ffffffffc02022a8 <etext+0xb3c>
ffffffffc02015c6:	85ca                	mv	a1,s2
ffffffffc02015c8:	8526                	mv	a0,s1
ffffffffc02015ca:	0c6000ef          	jal	ffffffffc0201690 <printfmt>
ffffffffc02015ce:	bb45                	j	ffffffffc020137e <vprintfmt+0x34>
    if (lflag >= 2) {
ffffffffc02015d0:	4705                	li	a4,1
            precision = va_arg(ap, int);
ffffffffc02015d2:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
ffffffffc02015d6:	00f74363          	blt	a4,a5,ffffffffc02015dc <vprintfmt+0x292>
    else if (lflag) {
ffffffffc02015da:	cf81                	beqz	a5,ffffffffc02015f2 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
ffffffffc02015dc:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
ffffffffc02015e0:	02044b63          	bltz	s0,ffffffffc0201616 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
ffffffffc02015e4:	8622                	mv	a2,s0
ffffffffc02015e6:	8a5e                	mv	s4,s7
ffffffffc02015e8:	46a9                	li	a3,10
ffffffffc02015ea:	b541                	j	ffffffffc020146a <vprintfmt+0x120>
            lflag ++;
ffffffffc02015ec:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc02015ee:	8462                	mv	s0,s8
            goto reswitch;
ffffffffc02015f0:	bb5d                	j	ffffffffc02013a6 <vprintfmt+0x5c>
        return va_arg(*ap, int);
ffffffffc02015f2:	000a2403          	lw	s0,0(s4)
ffffffffc02015f6:	b7ed                	j	ffffffffc02015e0 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
ffffffffc02015f8:	000a6603          	lwu	a2,0(s4)
ffffffffc02015fc:	46a1                	li	a3,8
ffffffffc02015fe:	8a2e                	mv	s4,a1
ffffffffc0201600:	b5ad                	j	ffffffffc020146a <vprintfmt+0x120>
ffffffffc0201602:	000a6603          	lwu	a2,0(s4)
ffffffffc0201606:	46a9                	li	a3,10
ffffffffc0201608:	8a2e                	mv	s4,a1
ffffffffc020160a:	b585                	j	ffffffffc020146a <vprintfmt+0x120>
ffffffffc020160c:	000a6603          	lwu	a2,0(s4)
ffffffffc0201610:	46c1                	li	a3,16
ffffffffc0201612:	8a2e                	mv	s4,a1
ffffffffc0201614:	bd99                	j	ffffffffc020146a <vprintfmt+0x120>
                putch('-', putdat);
ffffffffc0201616:	85ca                	mv	a1,s2
ffffffffc0201618:	02d00513          	li	a0,45
ffffffffc020161c:	9482                	jalr	s1
                num = -(long long)num;
ffffffffc020161e:	40800633          	neg	a2,s0
ffffffffc0201622:	8a5e                	mv	s4,s7
ffffffffc0201624:	46a9                	li	a3,10
ffffffffc0201626:	b591                	j	ffffffffc020146a <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
ffffffffc0201628:	e329                	bnez	a4,ffffffffc020166a <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020162a:	02800793          	li	a5,40
ffffffffc020162e:	853e                	mv	a0,a5
ffffffffc0201630:	00001d97          	auipc	s11,0x1
ffffffffc0201634:	c71d8d93          	addi	s11,s11,-911 # ffffffffc02022a1 <etext+0xb35>
ffffffffc0201638:	b5f5                	j	ffffffffc0201524 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020163a:	85e6                	mv	a1,s9
ffffffffc020163c:	856e                	mv	a0,s11
ffffffffc020163e:	0a4000ef          	jal	ffffffffc02016e2 <strnlen>
ffffffffc0201642:	40ad0d3b          	subw	s10,s10,a0
ffffffffc0201646:	01a05863          	blez	s10,ffffffffc0201656 <vprintfmt+0x30c>
                    putch(padc, putdat);
ffffffffc020164a:	85ca                	mv	a1,s2
ffffffffc020164c:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020164e:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
ffffffffc0201650:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc0201652:	fe0d1ce3          	bnez	s10,ffffffffc020164a <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201656:	000dc783          	lbu	a5,0(s11)
ffffffffc020165a:	0007851b          	sext.w	a0,a5
ffffffffc020165e:	ec0792e3          	bnez	a5,ffffffffc0201522 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
ffffffffc0201662:	6a22                	ld	s4,8(sp)
ffffffffc0201664:	bb29                	j	ffffffffc020137e <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
ffffffffc0201666:	8462                	mv	s0,s8
ffffffffc0201668:	bbd9                	j	ffffffffc020143e <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020166a:	85e6                	mv	a1,s9
ffffffffc020166c:	00001517          	auipc	a0,0x1
ffffffffc0201670:	c3450513          	addi	a0,a0,-972 # ffffffffc02022a0 <etext+0xb34>
ffffffffc0201674:	06e000ef          	jal	ffffffffc02016e2 <strnlen>
ffffffffc0201678:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc020167c:	02800793          	li	a5,40
                p = "(null)";
ffffffffc0201680:	00001d97          	auipc	s11,0x1
ffffffffc0201684:	c20d8d93          	addi	s11,s11,-992 # ffffffffc02022a0 <etext+0xb34>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
ffffffffc0201688:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
ffffffffc020168a:	fda040e3          	bgtz	s10,ffffffffc020164a <vprintfmt+0x300>
ffffffffc020168e:	bd51                	j	ffffffffc0201522 <vprintfmt+0x1d8>

ffffffffc0201690 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201690:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
ffffffffc0201692:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc0201696:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc0201698:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
ffffffffc020169a:	ec06                	sd	ra,24(sp)
ffffffffc020169c:	f83a                	sd	a4,48(sp)
ffffffffc020169e:	fc3e                	sd	a5,56(sp)
ffffffffc02016a0:	e0c2                	sd	a6,64(sp)
ffffffffc02016a2:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
ffffffffc02016a4:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
ffffffffc02016a6:	ca5ff0ef          	jal	ffffffffc020134a <vprintfmt>
}
ffffffffc02016aa:	60e2                	ld	ra,24(sp)
ffffffffc02016ac:	6161                	addi	sp,sp,80
ffffffffc02016ae:	8082                	ret

ffffffffc02016b0 <sbi_console_putchar>:
uint64_t SBI_REMOTE_SFENCE_VMA_ASID = 7;
uint64_t SBI_SHUTDOWN = 8;

uint64_t sbi_call(uint64_t sbi_type, uint64_t arg0, uint64_t arg1, uint64_t arg2) {
    uint64_t ret_val;
    __asm__ volatile (
ffffffffc02016b0:	00005717          	auipc	a4,0x5
ffffffffc02016b4:	96073703          	ld	a4,-1696(a4) # ffffffffc0206010 <SBI_CONSOLE_PUTCHAR>
ffffffffc02016b8:	4781                	li	a5,0
ffffffffc02016ba:	88ba                	mv	a7,a4
ffffffffc02016bc:	852a                	mv	a0,a0
ffffffffc02016be:	85be                	mv	a1,a5
ffffffffc02016c0:	863e                	mv	a2,a5
ffffffffc02016c2:	00000073          	ecall
ffffffffc02016c6:	87aa                	mv	a5,a0
    return ret_val;
}

void sbi_console_putchar(unsigned char ch) {
    sbi_call(SBI_CONSOLE_PUTCHAR, ch, 0, 0);
}
ffffffffc02016c8:	8082                	ret

ffffffffc02016ca <strlen>:
 * The strlen() function returns the length of string @s.
 * */
size_t
strlen(const char *s) {
    size_t cnt = 0;
    while (*s ++ != '\0') {
ffffffffc02016ca:	00054783          	lbu	a5,0(a0)
ffffffffc02016ce:	cb81                	beqz	a5,ffffffffc02016de <strlen+0x14>
    size_t cnt = 0;
ffffffffc02016d0:	4781                	li	a5,0
        cnt ++;
ffffffffc02016d2:	0785                	addi	a5,a5,1
    while (*s ++ != '\0') {
ffffffffc02016d4:	00f50733          	add	a4,a0,a5
ffffffffc02016d8:	00074703          	lbu	a4,0(a4)
ffffffffc02016dc:	fb7d                	bnez	a4,ffffffffc02016d2 <strlen+0x8>
    }
    return cnt;
}
ffffffffc02016de:	853e                	mv	a0,a5
ffffffffc02016e0:	8082                	ret

ffffffffc02016e2 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
ffffffffc02016e2:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
ffffffffc02016e4:	e589                	bnez	a1,ffffffffc02016ee <strnlen+0xc>
ffffffffc02016e6:	a811                	j	ffffffffc02016fa <strnlen+0x18>
        cnt ++;
ffffffffc02016e8:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
ffffffffc02016ea:	00f58863          	beq	a1,a5,ffffffffc02016fa <strnlen+0x18>
ffffffffc02016ee:	00f50733          	add	a4,a0,a5
ffffffffc02016f2:	00074703          	lbu	a4,0(a4)
ffffffffc02016f6:	fb6d                	bnez	a4,ffffffffc02016e8 <strnlen+0x6>
ffffffffc02016f8:	85be                	mv	a1,a5
    }
    return cnt;
}
ffffffffc02016fa:	852e                	mv	a0,a1
ffffffffc02016fc:	8082                	ret

ffffffffc02016fe <strcmp>:
int
strcmp(const char *s1, const char *s2) {
#ifdef __HAVE_ARCH_STRCMP
    return __strcmp(s1, s2);
#else
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc02016fe:	00054783          	lbu	a5,0(a0)
ffffffffc0201702:	e791                	bnez	a5,ffffffffc020170e <strcmp+0x10>
ffffffffc0201704:	a01d                	j	ffffffffc020172a <strcmp+0x2c>
ffffffffc0201706:	00054783          	lbu	a5,0(a0)
ffffffffc020170a:	cb99                	beqz	a5,ffffffffc0201720 <strcmp+0x22>
ffffffffc020170c:	0585                	addi	a1,a1,1
ffffffffc020170e:	0005c703          	lbu	a4,0(a1)
        s1 ++, s2 ++;
ffffffffc0201712:	0505                	addi	a0,a0,1
    while (*s1 != '\0' && *s1 == *s2) {
ffffffffc0201714:	fef709e3          	beq	a4,a5,ffffffffc0201706 <strcmp+0x8>
    }
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201718:	0007851b          	sext.w	a0,a5
#endif /* __HAVE_ARCH_STRCMP */
}
ffffffffc020171c:	9d19                	subw	a0,a0,a4
ffffffffc020171e:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc0201720:	0015c703          	lbu	a4,1(a1)
ffffffffc0201724:	4501                	li	a0,0
}
ffffffffc0201726:	9d19                	subw	a0,a0,a4
ffffffffc0201728:	8082                	ret
    return (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020172a:	0005c703          	lbu	a4,0(a1)
ffffffffc020172e:	4501                	li	a0,0
ffffffffc0201730:	b7f5                	j	ffffffffc020171c <strcmp+0x1e>

ffffffffc0201732 <strncmp>:
 * the characters differ, until a terminating null-character is reached, or
 * until @n characters match in both strings, whichever happens first.
 * */
int
strncmp(const char *s1, const char *s2, size_t n) {
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201732:	ce01                	beqz	a2,ffffffffc020174a <strncmp+0x18>
ffffffffc0201734:	00054783          	lbu	a5,0(a0)
        n --, s1 ++, s2 ++;
ffffffffc0201738:	167d                	addi	a2,a2,-1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc020173a:	cb91                	beqz	a5,ffffffffc020174e <strncmp+0x1c>
ffffffffc020173c:	0005c703          	lbu	a4,0(a1)
ffffffffc0201740:	00f71763          	bne	a4,a5,ffffffffc020174e <strncmp+0x1c>
        n --, s1 ++, s2 ++;
ffffffffc0201744:	0505                	addi	a0,a0,1
ffffffffc0201746:	0585                	addi	a1,a1,1
    while (n > 0 && *s1 != '\0' && *s1 == *s2) {
ffffffffc0201748:	f675                	bnez	a2,ffffffffc0201734 <strncmp+0x2>
    }
    return (n == 0) ? 0 : (int)((unsigned char)*s1 - (unsigned char)*s2);
ffffffffc020174a:	4501                	li	a0,0
ffffffffc020174c:	8082                	ret
ffffffffc020174e:	00054503          	lbu	a0,0(a0)
ffffffffc0201752:	0005c783          	lbu	a5,0(a1)
ffffffffc0201756:	9d1d                	subw	a0,a0,a5
}
ffffffffc0201758:	8082                	ret

ffffffffc020175a <memset>:
memset(void *s, char c, size_t n) {
#ifdef __HAVE_ARCH_MEMSET
    return __memset(s, c, n);
#else
    char *p = s;
    while (n -- > 0) {
ffffffffc020175a:	ca01                	beqz	a2,ffffffffc020176a <memset+0x10>
ffffffffc020175c:	962a                	add	a2,a2,a0
    char *p = s;
ffffffffc020175e:	87aa                	mv	a5,a0
        *p ++ = c;
ffffffffc0201760:	0785                	addi	a5,a5,1
ffffffffc0201762:	feb78fa3          	sb	a1,-1(a5)
    while (n -- > 0) {
ffffffffc0201766:	fef61de3          	bne	a2,a5,ffffffffc0201760 <memset+0x6>
    }
    return s;
#endif /* __HAVE_ARCH_MEMSET */
}
ffffffffc020176a:	8082                	ret
