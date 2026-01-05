
obj/__user_sleepkill.out:     file format elf64-littleriscv


Disassembly of section .text:

0000000000800020 <_start>:
    # move down the esp register
    # since it may cause page fault in backtrace
    // subl $0x20, %esp

    # call user-program function
    call umain
  800020:	12a000ef          	jal	80014a <umain>
1:  j 1b
  800024:	a001                	j	800024 <_start+0x4>

0000000000800026 <__panic>:
#include <stdio.h>
#include <ulib.h>
#include <error.h>

void
__panic(const char *file, int line, const char *fmt, ...) {
  800026:	715d                	addi	sp,sp,-80
    // print the 'message'
    va_list ap;
    va_start(ap, fmt);
  800028:	02810313          	addi	t1,sp,40
__panic(const char *file, int line, const char *fmt, ...) {
  80002c:	e822                	sd	s0,16(sp)
  80002e:	8432                	mv	s0,a2
    cprintf("user panic at %s:%d:\n    ", file, line);
  800030:	862e                	mv	a2,a1
  800032:	85aa                	mv	a1,a0
  800034:	00000517          	auipc	a0,0x0
  800038:	59450513          	addi	a0,a0,1428 # 8005c8 <main+0x8a>
__panic(const char *file, int line, const char *fmt, ...) {
  80003c:	ec06                	sd	ra,24(sp)
  80003e:	f436                	sd	a3,40(sp)
  800040:	f83a                	sd	a4,48(sp)
  800042:	fc3e                	sd	a5,56(sp)
  800044:	e0c2                	sd	a6,64(sp)
  800046:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800048:	e41a                	sd	t1,8(sp)
    cprintf("user panic at %s:%d:\n    ", file, line);
  80004a:	056000ef          	jal	8000a0 <cprintf>
    vcprintf(fmt, ap);
  80004e:	65a2                	ld	a1,8(sp)
  800050:	8522                	mv	a0,s0
  800052:	02e000ef          	jal	800080 <vcprintf>
    cprintf("\n");
  800056:	00000517          	auipc	a0,0x0
  80005a:	59250513          	addi	a0,a0,1426 # 8005e8 <main+0xaa>
  80005e:	042000ef          	jal	8000a0 <cprintf>
    va_end(ap);
    exit(-E_PANIC);
  800062:	5559                	li	a0,-10
  800064:	0c6000ef          	jal	80012a <exit>

0000000000800068 <cputch>:
/* *
 * cputch - writes a single character @c to stdout, and it will
 * increace the value of counter pointed by @cnt.
 * */
static void
cputch(int c, int *cnt) {
  800068:	1101                	addi	sp,sp,-32
  80006a:	ec06                	sd	ra,24(sp)
  80006c:	e42e                	sd	a1,8(sp)
    sys_putc(c);
  80006e:	0b0000ef          	jal	80011e <sys_putc>
    (*cnt) ++;
  800072:	65a2                	ld	a1,8(sp)
}
  800074:	60e2                	ld	ra,24(sp)
    (*cnt) ++;
  800076:	419c                	lw	a5,0(a1)
  800078:	2785                	addiw	a5,a5,1
  80007a:	c19c                	sw	a5,0(a1)
}
  80007c:	6105                	addi	sp,sp,32
  80007e:	8082                	ret

0000000000800080 <vcprintf>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want cprintf() instead.
 * */
int
vcprintf(const char *fmt, va_list ap) {
  800080:	1101                	addi	sp,sp,-32
  800082:	862a                	mv	a2,a0
  800084:	86ae                	mv	a3,a1
    int cnt = 0;
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800086:	00000517          	auipc	a0,0x0
  80008a:	fe250513          	addi	a0,a0,-30 # 800068 <cputch>
  80008e:	006c                	addi	a1,sp,12
vcprintf(const char *fmt, va_list ap) {
  800090:	ec06                	sd	ra,24(sp)
    int cnt = 0;
  800092:	c602                	sw	zero,12(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  800094:	128000ef          	jal	8001bc <vprintfmt>
    return cnt;
}
  800098:	60e2                	ld	ra,24(sp)
  80009a:	4532                	lw	a0,12(sp)
  80009c:	6105                	addi	sp,sp,32
  80009e:	8082                	ret

00000000008000a0 <cprintf>:
 *
 * The return value is the number of characters which would be
 * written to stdout.
 * */
int
cprintf(const char *fmt, ...) {
  8000a0:	711d                	addi	sp,sp,-96
    va_list ap;

    va_start(ap, fmt);
  8000a2:	02810313          	addi	t1,sp,40
cprintf(const char *fmt, ...) {
  8000a6:	f42e                	sd	a1,40(sp)
  8000a8:	f832                	sd	a2,48(sp)
  8000aa:	fc36                	sd	a3,56(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000ac:	862a                	mv	a2,a0
  8000ae:	004c                	addi	a1,sp,4
  8000b0:	00000517          	auipc	a0,0x0
  8000b4:	fb850513          	addi	a0,a0,-72 # 800068 <cputch>
  8000b8:	869a                	mv	a3,t1
cprintf(const char *fmt, ...) {
  8000ba:	ec06                	sd	ra,24(sp)
  8000bc:	e0ba                	sd	a4,64(sp)
  8000be:	e4be                	sd	a5,72(sp)
  8000c0:	e8c2                	sd	a6,80(sp)
  8000c2:	ecc6                	sd	a7,88(sp)
    int cnt = 0;
  8000c4:	c202                	sw	zero,4(sp)
    va_start(ap, fmt);
  8000c6:	e41a                	sd	t1,8(sp)
    vprintfmt((void*)cputch, &cnt, fmt, ap);
  8000c8:	0f4000ef          	jal	8001bc <vprintfmt>
    int cnt = vcprintf(fmt, ap);
    va_end(ap);

    return cnt;
}
  8000cc:	60e2                	ld	ra,24(sp)
  8000ce:	4512                	lw	a0,4(sp)
  8000d0:	6125                	addi	sp,sp,96
  8000d2:	8082                	ret

00000000008000d4 <syscall>:
#include <syscall.h>

#define MAX_ARGS            5

static inline int
syscall(int64_t num, ...) {
  8000d4:	7175                	addi	sp,sp,-144
    va_list ap;
    va_start(ap, num);
    uint64_t a[MAX_ARGS];
    int i, ret;
    for (i = 0; i < MAX_ARGS; i ++) {
        a[i] = va_arg(ap, uint64_t);
  8000d6:	08010313          	addi	t1,sp,128
syscall(int64_t num, ...) {
  8000da:	e42a                	sd	a0,8(sp)
  8000dc:	ecae                	sd	a1,88(sp)
        a[i] = va_arg(ap, uint64_t);
  8000de:	f42e                	sd	a1,40(sp)
syscall(int64_t num, ...) {
  8000e0:	f0b2                	sd	a2,96(sp)
        a[i] = va_arg(ap, uint64_t);
  8000e2:	f832                	sd	a2,48(sp)
syscall(int64_t num, ...) {
  8000e4:	f4b6                	sd	a3,104(sp)
        a[i] = va_arg(ap, uint64_t);
  8000e6:	fc36                	sd	a3,56(sp)
syscall(int64_t num, ...) {
  8000e8:	f8ba                	sd	a4,112(sp)
        a[i] = va_arg(ap, uint64_t);
  8000ea:	e0ba                	sd	a4,64(sp)
syscall(int64_t num, ...) {
  8000ec:	fcbe                	sd	a5,120(sp)
        a[i] = va_arg(ap, uint64_t);
  8000ee:	e4be                	sd	a5,72(sp)
syscall(int64_t num, ...) {
  8000f0:	e142                	sd	a6,128(sp)
  8000f2:	e546                	sd	a7,136(sp)
        a[i] = va_arg(ap, uint64_t);
  8000f4:	f01a                	sd	t1,32(sp)
    }
    va_end(ap);

    asm volatile (
  8000f6:	4522                	lw	a0,8(sp)
  8000f8:	55a2                	lw	a1,40(sp)
  8000fa:	5642                	lw	a2,48(sp)
  8000fc:	56e2                	lw	a3,56(sp)
  8000fe:	4706                	lw	a4,64(sp)
  800100:	47a6                	lw	a5,72(sp)
  800102:	00000073          	ecall
  800106:	ce2a                	sw	a0,28(sp)
          "m" (a[3]),
          "m" (a[4])
        : "memory"
      );
    return ret;
}
  800108:	4572                	lw	a0,28(sp)
  80010a:	6149                	addi	sp,sp,144
  80010c:	8082                	ret

000000000080010e <sys_exit>:

int
sys_exit(int64_t error_code) {
  80010e:	85aa                	mv	a1,a0
    return syscall(SYS_exit, error_code);
  800110:	4505                	li	a0,1
  800112:	b7c9                	j	8000d4 <syscall>

0000000000800114 <sys_fork>:
}

int
sys_fork(void) {
    return syscall(SYS_fork);
  800114:	4509                	li	a0,2
  800116:	bf7d                	j	8000d4 <syscall>

0000000000800118 <sys_kill>:
sys_yield(void) {
    return syscall(SYS_yield);
}

int
sys_kill(int64_t pid) {
  800118:	85aa                	mv	a1,a0
    return syscall(SYS_kill, pid);
  80011a:	4531                	li	a0,12
  80011c:	bf65                	j	8000d4 <syscall>

000000000080011e <sys_putc>:
sys_getpid(void) {
    return syscall(SYS_getpid);
}

int
sys_putc(int64_t c) {
  80011e:	85aa                	mv	a1,a0
    return syscall(SYS_putc, c);
  800120:	4579                	li	a0,30
  800122:	bf4d                	j	8000d4 <syscall>

0000000000800124 <sys_sleep>:
{
    syscall(SYS_lab6_set_priority, priority);
}

int
sys_sleep(uint64_t time) {
  800124:	85aa                	mv	a1,a0
    return syscall(SYS_sleep, time);
  800126:	452d                	li	a0,11
  800128:	b775                	j	8000d4 <syscall>

000000000080012a <exit>:
#include <syscall.h>
#include <stdio.h>
#include <ulib.h>

void
exit(int error_code) {
  80012a:	1141                	addi	sp,sp,-16
  80012c:	e406                	sd	ra,8(sp)
    sys_exit(error_code);
  80012e:	fe1ff0ef          	jal	80010e <sys_exit>
    cprintf("BUG: exit failed.\n");
  800132:	00000517          	auipc	a0,0x0
  800136:	4be50513          	addi	a0,a0,1214 # 8005f0 <main+0xb2>
  80013a:	f67ff0ef          	jal	8000a0 <cprintf>
    while (1);
  80013e:	a001                	j	80013e <exit+0x14>

0000000000800140 <fork>:
}

int
fork(void) {
    return sys_fork();
  800140:	bfd1                	j	800114 <sys_fork>

0000000000800142 <kill>:
    sys_yield();
}

int
kill(int pid) {
    return sys_kill(pid);
  800142:	bfd9                	j	800118 <sys_kill>

0000000000800144 <sleep>:
    sys_lab6_set_priority(priority);
}

int
sleep(unsigned int time) {
    return sys_sleep(time);
  800144:	1502                	slli	a0,a0,0x20
  800146:	9101                	srli	a0,a0,0x20
  800148:	bff1                	j	800124 <sys_sleep>

000000000080014a <umain>:
#include <ulib.h>

int main(void);

void
umain(void) {
  80014a:	1141                	addi	sp,sp,-16
  80014c:	e406                	sd	ra,8(sp)
    int ret = main();
  80014e:	3f0000ef          	jal	80053e <main>
    exit(ret);
  800152:	fd9ff0ef          	jal	80012a <exit>

0000000000800156 <printnum>:
 * @width:      maximum number of digits, if the actual width is less than @width, use @padc instead
 * @padc:       character that padded on the left if the actual width is less than @width
 * */
static void
printnum(void (*putch)(int, void*), void *putdat,
        unsigned long long num, unsigned base, int width, int padc) {
  800156:	7179                	addi	sp,sp,-48
    unsigned long long result = num;
    unsigned mod = do_div(result, base);
  800158:	02069813          	slli	a6,a3,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  80015c:	f022                	sd	s0,32(sp)
  80015e:	ec26                	sd	s1,24(sp)
  800160:	e84a                	sd	s2,16(sp)
  800162:	e052                	sd	s4,0(sp)
    unsigned mod = do_div(result, base);
  800164:	02085813          	srli	a6,a6,0x20
        unsigned long long num, unsigned base, int width, int padc) {
  800168:	f406                	sd	ra,40(sp)
    unsigned mod = do_div(result, base);
  80016a:	03067a33          	remu	s4,a2,a6
    // first recursively print all preceding (more significant) digits
    if (num >= base) {
        printnum(putch, putdat, result, base, width - 1, padc);
    } else {
        // print any needed pad characters before first digit
        while (-- width > 0)
  80016e:	fff7041b          	addiw	s0,a4,-1
        unsigned long long num, unsigned base, int width, int padc) {
  800172:	84aa                	mv	s1,a0
  800174:	892e                	mv	s2,a1
    if (num >= base) {
  800176:	03067d63          	bgeu	a2,a6,8001b0 <printnum+0x5a>
  80017a:	e44e                	sd	s3,8(sp)
  80017c:	89be                	mv	s3,a5
        while (-- width > 0)
  80017e:	4785                	li	a5,1
  800180:	00e7d763          	bge	a5,a4,80018e <printnum+0x38>
            putch(padc, putdat);
  800184:	85ca                	mv	a1,s2
  800186:	854e                	mv	a0,s3
        while (-- width > 0)
  800188:	347d                	addiw	s0,s0,-1
            putch(padc, putdat);
  80018a:	9482                	jalr	s1
        while (-- width > 0)
  80018c:	fc65                	bnez	s0,800184 <printnum+0x2e>
  80018e:	69a2                	ld	s3,8(sp)
    }
    // then print this (the least significant) digit
    putch("0123456789abcdef"[mod], putdat);
  800190:	00000797          	auipc	a5,0x0
  800194:	47878793          	addi	a5,a5,1144 # 800608 <main+0xca>
  800198:	97d2                	add	a5,a5,s4
    // Crashes if num >= base. No idea what going on here
    // Here is a quick fix
    // update: Stack grows downward and destory the SBI
    // sbi_console_putchar("0123456789abcdef"[mod]);
    // (*(int *)putdat)++;
}
  80019a:	7402                	ld	s0,32(sp)
    putch("0123456789abcdef"[mod], putdat);
  80019c:	0007c503          	lbu	a0,0(a5)
}
  8001a0:	70a2                	ld	ra,40(sp)
  8001a2:	6a02                	ld	s4,0(sp)
    putch("0123456789abcdef"[mod], putdat);
  8001a4:	85ca                	mv	a1,s2
  8001a6:	87a6                	mv	a5,s1
}
  8001a8:	6942                	ld	s2,16(sp)
  8001aa:	64e2                	ld	s1,24(sp)
  8001ac:	6145                	addi	sp,sp,48
    putch("0123456789abcdef"[mod], putdat);
  8001ae:	8782                	jr	a5
        printnum(putch, putdat, result, base, width - 1, padc);
  8001b0:	03065633          	divu	a2,a2,a6
  8001b4:	8722                	mv	a4,s0
  8001b6:	fa1ff0ef          	jal	800156 <printnum>
  8001ba:	bfd9                	j	800190 <printnum+0x3a>

00000000008001bc <vprintfmt>:
 *
 * Call this function if you are already dealing with a va_list.
 * Or you probably want printfmt() instead.
 * */
void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap) {
  8001bc:	7119                	addi	sp,sp,-128
  8001be:	f4a6                	sd	s1,104(sp)
  8001c0:	f0ca                	sd	s2,96(sp)
  8001c2:	ecce                	sd	s3,88(sp)
  8001c4:	e8d2                	sd	s4,80(sp)
  8001c6:	e4d6                	sd	s5,72(sp)
  8001c8:	e0da                	sd	s6,64(sp)
  8001ca:	f862                	sd	s8,48(sp)
  8001cc:	fc86                	sd	ra,120(sp)
  8001ce:	f8a2                	sd	s0,112(sp)
  8001d0:	fc5e                	sd	s7,56(sp)
  8001d2:	f466                	sd	s9,40(sp)
  8001d4:	f06a                	sd	s10,32(sp)
  8001d6:	ec6e                	sd	s11,24(sp)
  8001d8:	84aa                	mv	s1,a0
  8001da:	8c32                	mv	s8,a2
  8001dc:	8a36                	mv	s4,a3
  8001de:	892e                	mv	s2,a1
    register int ch, err;
    unsigned long long num;
    int base, width, precision, lflag, altflag;

    while (1) {
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001e0:	02500993          	li	s3,37
        char padc = ' ';
        width = precision = -1;
        lflag = altflag = 0;

    reswitch:
        switch (ch = *(unsigned char *)fmt ++) {
  8001e4:	05500b13          	li	s6,85
  8001e8:	00000a97          	auipc	s5,0x0
  8001ec:	574a8a93          	addi	s5,s5,1396 # 80075c <main+0x21e>
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  8001f0:	000c4503          	lbu	a0,0(s8)
  8001f4:	001c0413          	addi	s0,s8,1
  8001f8:	01350a63          	beq	a0,s3,80020c <vprintfmt+0x50>
            if (ch == '\0') {
  8001fc:	cd0d                	beqz	a0,800236 <vprintfmt+0x7a>
            putch(ch, putdat);
  8001fe:	85ca                	mv	a1,s2
  800200:	9482                	jalr	s1
        while ((ch = *(unsigned char *)fmt ++) != '%') {
  800202:	00044503          	lbu	a0,0(s0)
  800206:	0405                	addi	s0,s0,1
  800208:	ff351ae3          	bne	a0,s3,8001fc <vprintfmt+0x40>
        width = precision = -1;
  80020c:	5cfd                	li	s9,-1
  80020e:	8d66                	mv	s10,s9
        char padc = ' ';
  800210:	02000d93          	li	s11,32
        lflag = altflag = 0;
  800214:	4b81                	li	s7,0
  800216:	4781                	li	a5,0
        switch (ch = *(unsigned char *)fmt ++) {
  800218:	00044683          	lbu	a3,0(s0)
  80021c:	00140c13          	addi	s8,s0,1
  800220:	fdd6859b          	addiw	a1,a3,-35
  800224:	0ff5f593          	zext.b	a1,a1
  800228:	02bb6663          	bltu	s6,a1,800254 <vprintfmt+0x98>
  80022c:	058a                	slli	a1,a1,0x2
  80022e:	95d6                	add	a1,a1,s5
  800230:	4198                	lw	a4,0(a1)
  800232:	9756                	add	a4,a4,s5
  800234:	8702                	jr	a4
            for (fmt --; fmt[-1] != '%'; fmt --)
                /* do nothing */;
            break;
        }
    }
}
  800236:	70e6                	ld	ra,120(sp)
  800238:	7446                	ld	s0,112(sp)
  80023a:	74a6                	ld	s1,104(sp)
  80023c:	7906                	ld	s2,96(sp)
  80023e:	69e6                	ld	s3,88(sp)
  800240:	6a46                	ld	s4,80(sp)
  800242:	6aa6                	ld	s5,72(sp)
  800244:	6b06                	ld	s6,64(sp)
  800246:	7be2                	ld	s7,56(sp)
  800248:	7c42                	ld	s8,48(sp)
  80024a:	7ca2                	ld	s9,40(sp)
  80024c:	7d02                	ld	s10,32(sp)
  80024e:	6de2                	ld	s11,24(sp)
  800250:	6109                	addi	sp,sp,128
  800252:	8082                	ret
            putch('%', putdat);
  800254:	85ca                	mv	a1,s2
  800256:	02500513          	li	a0,37
  80025a:	9482                	jalr	s1
            for (fmt --; fmt[-1] != '%'; fmt --)
  80025c:	fff44783          	lbu	a5,-1(s0)
  800260:	02500713          	li	a4,37
  800264:	8c22                	mv	s8,s0
  800266:	f8e785e3          	beq	a5,a4,8001f0 <vprintfmt+0x34>
  80026a:	ffec4783          	lbu	a5,-2(s8)
  80026e:	1c7d                	addi	s8,s8,-1
  800270:	fee79de3          	bne	a5,a4,80026a <vprintfmt+0xae>
  800274:	bfb5                	j	8001f0 <vprintfmt+0x34>
                ch = *fmt;
  800276:	00144603          	lbu	a2,1(s0)
                if (ch < '0' || ch > '9') {
  80027a:	4525                	li	a0,9
                precision = precision * 10 + ch - '0';
  80027c:	fd068c9b          	addiw	s9,a3,-48
                if (ch < '0' || ch > '9') {
  800280:	fd06071b          	addiw	a4,a2,-48
  800284:	24e56a63          	bltu	a0,a4,8004d8 <vprintfmt+0x31c>
                ch = *fmt;
  800288:	2601                	sext.w	a2,a2
        switch (ch = *(unsigned char *)fmt ++) {
  80028a:	8462                	mv	s0,s8
                precision = precision * 10 + ch - '0';
  80028c:	002c971b          	slliw	a4,s9,0x2
                ch = *fmt;
  800290:	00144683          	lbu	a3,1(s0)
                precision = precision * 10 + ch - '0';
  800294:	0197073b          	addw	a4,a4,s9
  800298:	0017171b          	slliw	a4,a4,0x1
  80029c:	9f31                	addw	a4,a4,a2
                if (ch < '0' || ch > '9') {
  80029e:	fd06859b          	addiw	a1,a3,-48
            for (precision = 0; ; ++ fmt) {
  8002a2:	0405                	addi	s0,s0,1
                precision = precision * 10 + ch - '0';
  8002a4:	fd070c9b          	addiw	s9,a4,-48
                ch = *fmt;
  8002a8:	0006861b          	sext.w	a2,a3
                if (ch < '0' || ch > '9') {
  8002ac:	feb570e3          	bgeu	a0,a1,80028c <vprintfmt+0xd0>
            if (width < 0)
  8002b0:	f60d54e3          	bgez	s10,800218 <vprintfmt+0x5c>
                width = precision, precision = -1;
  8002b4:	8d66                	mv	s10,s9
  8002b6:	5cfd                	li	s9,-1
  8002b8:	b785                	j	800218 <vprintfmt+0x5c>
        switch (ch = *(unsigned char *)fmt ++) {
  8002ba:	8db6                	mv	s11,a3
  8002bc:	8462                	mv	s0,s8
  8002be:	bfa9                	j	800218 <vprintfmt+0x5c>
  8002c0:	8462                	mv	s0,s8
            altflag = 1;
  8002c2:	4b85                	li	s7,1
            goto reswitch;
  8002c4:	bf91                	j	800218 <vprintfmt+0x5c>
    if (lflag >= 2) {
  8002c6:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002c8:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002cc:	00f74463          	blt	a4,a5,8002d4 <vprintfmt+0x118>
    else if (lflag) {
  8002d0:	1a078763          	beqz	a5,80047e <vprintfmt+0x2c2>
        return va_arg(*ap, unsigned long);
  8002d4:	000a3603          	ld	a2,0(s4)
  8002d8:	46c1                	li	a3,16
  8002da:	8a2e                	mv	s4,a1
            printnum(putch, putdat, num, base, width, padc);
  8002dc:	000d879b          	sext.w	a5,s11
  8002e0:	876a                	mv	a4,s10
  8002e2:	85ca                	mv	a1,s2
  8002e4:	8526                	mv	a0,s1
  8002e6:	e71ff0ef          	jal	800156 <printnum>
            break;
  8002ea:	b719                	j	8001f0 <vprintfmt+0x34>
            putch(va_arg(ap, int), putdat);
  8002ec:	000a2503          	lw	a0,0(s4)
  8002f0:	85ca                	mv	a1,s2
  8002f2:	0a21                	addi	s4,s4,8
  8002f4:	9482                	jalr	s1
            break;
  8002f6:	bded                	j	8001f0 <vprintfmt+0x34>
    if (lflag >= 2) {
  8002f8:	4705                	li	a4,1
            precision = va_arg(ap, int);
  8002fa:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  8002fe:	00f74463          	blt	a4,a5,800306 <vprintfmt+0x14a>
    else if (lflag) {
  800302:	16078963          	beqz	a5,800474 <vprintfmt+0x2b8>
        return va_arg(*ap, unsigned long);
  800306:	000a3603          	ld	a2,0(s4)
  80030a:	46a9                	li	a3,10
  80030c:	8a2e                	mv	s4,a1
  80030e:	b7f9                	j	8002dc <vprintfmt+0x120>
            putch('0', putdat);
  800310:	85ca                	mv	a1,s2
  800312:	03000513          	li	a0,48
  800316:	9482                	jalr	s1
            putch('x', putdat);
  800318:	85ca                	mv	a1,s2
  80031a:	07800513          	li	a0,120
  80031e:	9482                	jalr	s1
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800320:	000a3603          	ld	a2,0(s4)
            goto number;
  800324:	46c1                	li	a3,16
            num = (unsigned long long)(uintptr_t)va_arg(ap, void *);
  800326:	0a21                	addi	s4,s4,8
            goto number;
  800328:	bf55                	j	8002dc <vprintfmt+0x120>
            putch(ch, putdat);
  80032a:	85ca                	mv	a1,s2
  80032c:	02500513          	li	a0,37
  800330:	9482                	jalr	s1
            break;
  800332:	bd7d                	j	8001f0 <vprintfmt+0x34>
            precision = va_arg(ap, int);
  800334:	000a2c83          	lw	s9,0(s4)
        switch (ch = *(unsigned char *)fmt ++) {
  800338:	8462                	mv	s0,s8
            precision = va_arg(ap, int);
  80033a:	0a21                	addi	s4,s4,8
            goto process_precision;
  80033c:	bf95                	j	8002b0 <vprintfmt+0xf4>
    if (lflag >= 2) {
  80033e:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800340:	008a0593          	addi	a1,s4,8
    if (lflag >= 2) {
  800344:	00f74463          	blt	a4,a5,80034c <vprintfmt+0x190>
    else if (lflag) {
  800348:	12078163          	beqz	a5,80046a <vprintfmt+0x2ae>
        return va_arg(*ap, unsigned long);
  80034c:	000a3603          	ld	a2,0(s4)
  800350:	46a1                	li	a3,8
  800352:	8a2e                	mv	s4,a1
  800354:	b761                	j	8002dc <vprintfmt+0x120>
            if (width < 0)
  800356:	876a                	mv	a4,s10
  800358:	000d5363          	bgez	s10,80035e <vprintfmt+0x1a2>
  80035c:	4701                	li	a4,0
  80035e:	00070d1b          	sext.w	s10,a4
        switch (ch = *(unsigned char *)fmt ++) {
  800362:	8462                	mv	s0,s8
            goto reswitch;
  800364:	bd55                	j	800218 <vprintfmt+0x5c>
            if (width > 0 && padc != '-') {
  800366:	000d841b          	sext.w	s0,s11
  80036a:	fd340793          	addi	a5,s0,-45
  80036e:	00f037b3          	snez	a5,a5
  800372:	01a02733          	sgtz	a4,s10
            if ((p = va_arg(ap, char *)) == NULL) {
  800376:	000a3d83          	ld	s11,0(s4)
            if (width > 0 && padc != '-') {
  80037a:	8f7d                	and	a4,a4,a5
            if ((p = va_arg(ap, char *)) == NULL) {
  80037c:	008a0793          	addi	a5,s4,8
  800380:	e43e                	sd	a5,8(sp)
  800382:	100d8c63          	beqz	s11,80049a <vprintfmt+0x2de>
            if (width > 0 && padc != '-') {
  800386:	12071363          	bnez	a4,8004ac <vprintfmt+0x2f0>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80038a:	000dc783          	lbu	a5,0(s11)
  80038e:	0007851b          	sext.w	a0,a5
  800392:	c78d                	beqz	a5,8003bc <vprintfmt+0x200>
  800394:	0d85                	addi	s11,s11,1
  800396:	547d                	li	s0,-1
                if (altflag && (ch < ' ' || ch > '~')) {
  800398:	05e00a13          	li	s4,94
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80039c:	000cc563          	bltz	s9,8003a6 <vprintfmt+0x1ea>
  8003a0:	3cfd                	addiw	s9,s9,-1
  8003a2:	008c8d63          	beq	s9,s0,8003bc <vprintfmt+0x200>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003a6:	020b9663          	bnez	s7,8003d2 <vprintfmt+0x216>
                    putch(ch, putdat);
  8003aa:	85ca                	mv	a1,s2
  8003ac:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003ae:	000dc783          	lbu	a5,0(s11)
  8003b2:	0d85                	addi	s11,s11,1
  8003b4:	3d7d                	addiw	s10,s10,-1
  8003b6:	0007851b          	sext.w	a0,a5
  8003ba:	f3ed                	bnez	a5,80039c <vprintfmt+0x1e0>
            for (; width > 0; width --) {
  8003bc:	01a05963          	blez	s10,8003ce <vprintfmt+0x212>
                putch(' ', putdat);
  8003c0:	85ca                	mv	a1,s2
  8003c2:	02000513          	li	a0,32
            for (; width > 0; width --) {
  8003c6:	3d7d                	addiw	s10,s10,-1
                putch(' ', putdat);
  8003c8:	9482                	jalr	s1
            for (; width > 0; width --) {
  8003ca:	fe0d1be3          	bnez	s10,8003c0 <vprintfmt+0x204>
            if ((p = va_arg(ap, char *)) == NULL) {
  8003ce:	6a22                	ld	s4,8(sp)
  8003d0:	b505                	j	8001f0 <vprintfmt+0x34>
                if (altflag && (ch < ' ' || ch > '~')) {
  8003d2:	3781                	addiw	a5,a5,-32
  8003d4:	fcfa7be3          	bgeu	s4,a5,8003aa <vprintfmt+0x1ee>
                    putch('?', putdat);
  8003d8:	03f00513          	li	a0,63
  8003dc:	85ca                	mv	a1,s2
  8003de:	9482                	jalr	s1
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8003e0:	000dc783          	lbu	a5,0(s11)
  8003e4:	0d85                	addi	s11,s11,1
  8003e6:	3d7d                	addiw	s10,s10,-1
  8003e8:	0007851b          	sext.w	a0,a5
  8003ec:	dbe1                	beqz	a5,8003bc <vprintfmt+0x200>
  8003ee:	fa0cd9e3          	bgez	s9,8003a0 <vprintfmt+0x1e4>
  8003f2:	b7c5                	j	8003d2 <vprintfmt+0x216>
            if (err < 0) {
  8003f4:	000a2783          	lw	a5,0(s4)
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  8003f8:	4661                	li	a2,24
            err = va_arg(ap, int);
  8003fa:	0a21                	addi	s4,s4,8
            if (err < 0) {
  8003fc:	41f7d71b          	sraiw	a4,a5,0x1f
  800400:	8fb9                	xor	a5,a5,a4
  800402:	40e786bb          	subw	a3,a5,a4
            if (err > MAXERROR || (p = error_string[err]) == NULL) {
  800406:	02d64563          	blt	a2,a3,800430 <vprintfmt+0x274>
  80040a:	00000797          	auipc	a5,0x0
  80040e:	4ae78793          	addi	a5,a5,1198 # 8008b8 <error_string>
  800412:	00369713          	slli	a4,a3,0x3
  800416:	97ba                	add	a5,a5,a4
  800418:	639c                	ld	a5,0(a5)
  80041a:	cb99                	beqz	a5,800430 <vprintfmt+0x274>
                printfmt(putch, putdat, "%s", p);
  80041c:	86be                	mv	a3,a5
  80041e:	00000617          	auipc	a2,0x0
  800422:	21a60613          	addi	a2,a2,538 # 800638 <main+0xfa>
  800426:	85ca                	mv	a1,s2
  800428:	8526                	mv	a0,s1
  80042a:	0d8000ef          	jal	800502 <printfmt>
  80042e:	b3c9                	j	8001f0 <vprintfmt+0x34>
                printfmt(putch, putdat, "error %d", err);
  800430:	00000617          	auipc	a2,0x0
  800434:	1f860613          	addi	a2,a2,504 # 800628 <main+0xea>
  800438:	85ca                	mv	a1,s2
  80043a:	8526                	mv	a0,s1
  80043c:	0c6000ef          	jal	800502 <printfmt>
  800440:	bb45                	j	8001f0 <vprintfmt+0x34>
    if (lflag >= 2) {
  800442:	4705                	li	a4,1
            precision = va_arg(ap, int);
  800444:	008a0b93          	addi	s7,s4,8
    if (lflag >= 2) {
  800448:	00f74363          	blt	a4,a5,80044e <vprintfmt+0x292>
    else if (lflag) {
  80044c:	cf81                	beqz	a5,800464 <vprintfmt+0x2a8>
        return va_arg(*ap, long);
  80044e:	000a3403          	ld	s0,0(s4)
            if ((long long)num < 0) {
  800452:	02044b63          	bltz	s0,800488 <vprintfmt+0x2cc>
            num = getint(&ap, lflag);
  800456:	8622                	mv	a2,s0
  800458:	8a5e                	mv	s4,s7
  80045a:	46a9                	li	a3,10
  80045c:	b541                	j	8002dc <vprintfmt+0x120>
            lflag ++;
  80045e:	2785                	addiw	a5,a5,1
        switch (ch = *(unsigned char *)fmt ++) {
  800460:	8462                	mv	s0,s8
            goto reswitch;
  800462:	bb5d                	j	800218 <vprintfmt+0x5c>
        return va_arg(*ap, int);
  800464:	000a2403          	lw	s0,0(s4)
  800468:	b7ed                	j	800452 <vprintfmt+0x296>
        return va_arg(*ap, unsigned int);
  80046a:	000a6603          	lwu	a2,0(s4)
  80046e:	46a1                	li	a3,8
  800470:	8a2e                	mv	s4,a1
  800472:	b5ad                	j	8002dc <vprintfmt+0x120>
  800474:	000a6603          	lwu	a2,0(s4)
  800478:	46a9                	li	a3,10
  80047a:	8a2e                	mv	s4,a1
  80047c:	b585                	j	8002dc <vprintfmt+0x120>
  80047e:	000a6603          	lwu	a2,0(s4)
  800482:	46c1                	li	a3,16
  800484:	8a2e                	mv	s4,a1
  800486:	bd99                	j	8002dc <vprintfmt+0x120>
                putch('-', putdat);
  800488:	85ca                	mv	a1,s2
  80048a:	02d00513          	li	a0,45
  80048e:	9482                	jalr	s1
                num = -(long long)num;
  800490:	40800633          	neg	a2,s0
  800494:	8a5e                	mv	s4,s7
  800496:	46a9                	li	a3,10
  800498:	b591                	j	8002dc <vprintfmt+0x120>
            if (width > 0 && padc != '-') {
  80049a:	e329                	bnez	a4,8004dc <vprintfmt+0x320>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  80049c:	02800793          	li	a5,40
  8004a0:	853e                	mv	a0,a5
  8004a2:	00000d97          	auipc	s11,0x0
  8004a6:	17fd8d93          	addi	s11,s11,383 # 800621 <main+0xe3>
  8004aa:	b5f5                	j	800396 <vprintfmt+0x1da>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004ac:	85e6                	mv	a1,s9
  8004ae:	856e                	mv	a0,s11
  8004b0:	072000ef          	jal	800522 <strnlen>
  8004b4:	40ad0d3b          	subw	s10,s10,a0
  8004b8:	01a05863          	blez	s10,8004c8 <vprintfmt+0x30c>
                    putch(padc, putdat);
  8004bc:	85ca                	mv	a1,s2
  8004be:	8522                	mv	a0,s0
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c0:	3d7d                	addiw	s10,s10,-1
                    putch(padc, putdat);
  8004c2:	9482                	jalr	s1
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004c4:	fe0d1ce3          	bnez	s10,8004bc <vprintfmt+0x300>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004c8:	000dc783          	lbu	a5,0(s11)
  8004cc:	0007851b          	sext.w	a0,a5
  8004d0:	ec0792e3          	bnez	a5,800394 <vprintfmt+0x1d8>
            if ((p = va_arg(ap, char *)) == NULL) {
  8004d4:	6a22                	ld	s4,8(sp)
  8004d6:	bb29                	j	8001f0 <vprintfmt+0x34>
        switch (ch = *(unsigned char *)fmt ++) {
  8004d8:	8462                	mv	s0,s8
  8004da:	bbd9                	j	8002b0 <vprintfmt+0xf4>
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004dc:	85e6                	mv	a1,s9
  8004de:	00000517          	auipc	a0,0x0
  8004e2:	14250513          	addi	a0,a0,322 # 800620 <main+0xe2>
  8004e6:	03c000ef          	jal	800522 <strnlen>
  8004ea:	40ad0d3b          	subw	s10,s10,a0
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004ee:	02800793          	li	a5,40
                p = "(null)";
  8004f2:	00000d97          	auipc	s11,0x0
  8004f6:	12ed8d93          	addi	s11,s11,302 # 800620 <main+0xe2>
            for (; (ch = *p ++) != '\0' && (precision < 0 || -- precision >= 0); width --) {
  8004fa:	853e                	mv	a0,a5
                for (width -= strnlen(p, precision); width > 0; width --) {
  8004fc:	fda040e3          	bgtz	s10,8004bc <vprintfmt+0x300>
  800500:	bd51                	j	800394 <vprintfmt+0x1d8>

0000000000800502 <printfmt>:
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800502:	715d                	addi	sp,sp,-80
    va_start(ap, fmt);
  800504:	02810313          	addi	t1,sp,40
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  800508:	f436                	sd	a3,40(sp)
    vprintfmt(putch, putdat, fmt, ap);
  80050a:	869a                	mv	a3,t1
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...) {
  80050c:	ec06                	sd	ra,24(sp)
  80050e:	f83a                	sd	a4,48(sp)
  800510:	fc3e                	sd	a5,56(sp)
  800512:	e0c2                	sd	a6,64(sp)
  800514:	e4c6                	sd	a7,72(sp)
    va_start(ap, fmt);
  800516:	e41a                	sd	t1,8(sp)
    vprintfmt(putch, putdat, fmt, ap);
  800518:	ca5ff0ef          	jal	8001bc <vprintfmt>
}
  80051c:	60e2                	ld	ra,24(sp)
  80051e:	6161                	addi	sp,sp,80
  800520:	8082                	ret

0000000000800522 <strnlen>:
 * @len if there is no '\0' character among the first @len characters
 * pointed by @s.
 * */
size_t
strnlen(const char *s, size_t len) {
    size_t cnt = 0;
  800522:	4781                	li	a5,0
    while (cnt < len && *s ++ != '\0') {
  800524:	e589                	bnez	a1,80052e <strnlen+0xc>
  800526:	a811                	j	80053a <strnlen+0x18>
        cnt ++;
  800528:	0785                	addi	a5,a5,1
    while (cnt < len && *s ++ != '\0') {
  80052a:	00f58863          	beq	a1,a5,80053a <strnlen+0x18>
  80052e:	00f50733          	add	a4,a0,a5
  800532:	00074703          	lbu	a4,0(a4)
  800536:	fb6d                	bnez	a4,800528 <strnlen+0x6>
  800538:	85be                	mv	a1,a5
    }
    return cnt;
}
  80053a:	852e                	mv	a0,a1
  80053c:	8082                	ret

000000000080053e <main>:
#include <stdio.h>
#include <ulib.h>

int
main(void) {
  80053e:	1141                	addi	sp,sp,-16
  800540:	e406                	sd	ra,8(sp)
  800542:	e022                	sd	s0,0(sp)
    int pid;
    if ((pid = fork()) == 0) {
  800544:	bfdff0ef          	jal	800140 <fork>
  800548:	c51d                	beqz	a0,800576 <main+0x38>
  80054a:	842a                	mv	s0,a0
        sleep(~0);
        exit(0xdead);
    }
    assert(pid > 0);
  80054c:	04a05c63          	blez	a0,8005a4 <main+0x66>

    sleep(100);
  800550:	06400513          	li	a0,100
  800554:	bf1ff0ef          	jal	800144 <sleep>
    assert(kill(pid) == 0);
  800558:	8522                	mv	a0,s0
  80055a:	be9ff0ef          	jal	800142 <kill>
  80055e:	e505                	bnez	a0,800586 <main+0x48>
    cprintf("sleepkill pass.\n");
  800560:	00000517          	auipc	a0,0x0
  800564:	1e850513          	addi	a0,a0,488 # 800748 <main+0x20a>
  800568:	b39ff0ef          	jal	8000a0 <cprintf>
    return 0;
}
  80056c:	60a2                	ld	ra,8(sp)
  80056e:	6402                	ld	s0,0(sp)
  800570:	4501                	li	a0,0
  800572:	0141                	addi	sp,sp,16
  800574:	8082                	ret
        sleep(~0);
  800576:	557d                	li	a0,-1
  800578:	bcdff0ef          	jal	800144 <sleep>
        exit(0xdead);
  80057c:	6539                	lui	a0,0xe
  80057e:	ead50513          	addi	a0,a0,-339 # dead <_start-0x7f2173>
  800582:	ba9ff0ef          	jal	80012a <exit>
    assert(kill(pid) == 0);
  800586:	00000697          	auipc	a3,0x0
  80058a:	1b268693          	addi	a3,a3,434 # 800738 <main+0x1fa>
  80058e:	00000617          	auipc	a2,0x0
  800592:	17a60613          	addi	a2,a2,378 # 800708 <main+0x1ca>
  800596:	45b9                	li	a1,14
  800598:	00000517          	auipc	a0,0x0
  80059c:	18850513          	addi	a0,a0,392 # 800720 <main+0x1e2>
  8005a0:	a87ff0ef          	jal	800026 <__panic>
    assert(pid > 0);
  8005a4:	00000697          	auipc	a3,0x0
  8005a8:	15c68693          	addi	a3,a3,348 # 800700 <main+0x1c2>
  8005ac:	00000617          	auipc	a2,0x0
  8005b0:	15c60613          	addi	a2,a2,348 # 800708 <main+0x1ca>
  8005b4:	45ad                	li	a1,11
  8005b6:	00000517          	auipc	a0,0x0
  8005ba:	16a50513          	addi	a0,a0,362 # 800720 <main+0x1e2>
  8005be:	a69ff0ef          	jal	800026 <__panic>
