
bin/kernel:     file format elf64-littleriscv


Disassembly of section .text:

ffffffffc0200000 <kern_entry>:
ffffffffc0200000:	00014297          	auipc	t0,0x14
ffffffffc0200004:	00028293          	mv	t0,t0
ffffffffc0200008:	00a2b023          	sd	a0,0(t0) # ffffffffc0214000 <boot_hartid>
ffffffffc020000c:	00014297          	auipc	t0,0x14
ffffffffc0200010:	ffc28293          	addi	t0,t0,-4 # ffffffffc0214008 <boot_dtb>
ffffffffc0200014:	00b2b023          	sd	a1,0(t0)
ffffffffc0200018:	c02132b7          	lui	t0,0xc0213
ffffffffc020001c:	ffd0031b          	addiw	t1,zero,-3
ffffffffc0200020:	037a                	slli	t1,t1,0x1e
ffffffffc0200022:	406282b3          	sub	t0,t0,t1
ffffffffc0200026:	00c2d293          	srli	t0,t0,0xc
ffffffffc020002a:	fff0031b          	addiw	t1,zero,-1
ffffffffc020002e:	137e                	slli	t1,t1,0x3f
ffffffffc0200030:	0062e2b3          	or	t0,t0,t1
ffffffffc0200034:	18029073          	csrw	satp,t0
ffffffffc0200038:	12000073          	sfence.vma
ffffffffc020003c:	c0213137          	lui	sp,0xc0213
ffffffffc0200040:	c02002b7          	lui	t0,0xc0200
ffffffffc0200044:	04a28293          	addi	t0,t0,74 # ffffffffc020004a <kern_init>
ffffffffc0200048:	8282                	jr	t0

ffffffffc020004a <kern_init>:
ffffffffc020004a:	00091517          	auipc	a0,0x91
ffffffffc020004e:	01650513          	addi	a0,a0,22 # ffffffffc0291060 <buf>
ffffffffc0200052:	00097617          	auipc	a2,0x97
ffffffffc0200056:	8be60613          	addi	a2,a2,-1858 # ffffffffc0296910 <end>
ffffffffc020005a:	1141                	addi	sp,sp,-16 # ffffffffc0212ff0 <bootstack+0x1ff0>
ffffffffc020005c:	8e09                	sub	a2,a2,a0
ffffffffc020005e:	4581                	li	a1,0
ffffffffc0200060:	e406                	sd	ra,8(sp)
ffffffffc0200062:	7960b0ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc0200066:	4da000ef          	jal	ffffffffc0200540 <cons_init>
ffffffffc020006a:	0000b597          	auipc	a1,0xb
ffffffffc020006e:	7f658593          	addi	a1,a1,2038 # ffffffffc020b860 <etext>
ffffffffc0200072:	0000c517          	auipc	a0,0xc
ffffffffc0200076:	80e50513          	addi	a0,a0,-2034 # ffffffffc020b880 <etext+0x20>
ffffffffc020007a:	12c000ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc020007e:	1ac000ef          	jal	ffffffffc020022a <print_kerninfo>
ffffffffc0200082:	5f4000ef          	jal	ffffffffc0200676 <dtb_init>
ffffffffc0200086:	29b020ef          	jal	ffffffffc0202b20 <pmm_init>
ffffffffc020008a:	355000ef          	jal	ffffffffc0200bde <pic_init>
ffffffffc020008e:	477000ef          	jal	ffffffffc0200d04 <idt_init>
ffffffffc0200092:	75d030ef          	jal	ffffffffc0203fee <vmm_init>
ffffffffc0200096:	35c070ef          	jal	ffffffffc02073f2 <sched_init>
ffffffffc020009a:	767060ef          	jal	ffffffffc0207000 <proc_init>
ffffffffc020009e:	11f000ef          	jal	ffffffffc02009bc <ide_init>
ffffffffc02000a2:	1b2050ef          	jal	ffffffffc0205254 <fs_init>
ffffffffc02000a6:	452000ef          	jal	ffffffffc02004f8 <clock_init>
ffffffffc02000aa:	329000ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc02000ae:	126070ef          	jal	ffffffffc02071d4 <cpu_idle>

ffffffffc02000b2 <readline>:
ffffffffc02000b2:	7179                	addi	sp,sp,-48
ffffffffc02000b4:	f406                	sd	ra,40(sp)
ffffffffc02000b6:	f022                	sd	s0,32(sp)
ffffffffc02000b8:	ec26                	sd	s1,24(sp)
ffffffffc02000ba:	e84a                	sd	s2,16(sp)
ffffffffc02000bc:	e44e                	sd	s3,8(sp)
ffffffffc02000be:	c901                	beqz	a0,ffffffffc02000ce <readline+0x1c>
ffffffffc02000c0:	85aa                	mv	a1,a0
ffffffffc02000c2:	0000b517          	auipc	a0,0xb
ffffffffc02000c6:	7c650513          	addi	a0,a0,1990 # ffffffffc020b888 <etext+0x28>
ffffffffc02000ca:	0dc000ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc02000ce:	4481                	li	s1,0
ffffffffc02000d0:	497d                	li	s2,31
ffffffffc02000d2:	00091997          	auipc	s3,0x91
ffffffffc02000d6:	f8e98993          	addi	s3,s3,-114 # ffffffffc0291060 <buf>
ffffffffc02000da:	108000ef          	jal	ffffffffc02001e2 <getchar>
ffffffffc02000de:	842a                	mv	s0,a0
ffffffffc02000e0:	ff850793          	addi	a5,a0,-8
ffffffffc02000e4:	3ff4a713          	slti	a4,s1,1023
ffffffffc02000e8:	ff650693          	addi	a3,a0,-10
ffffffffc02000ec:	ff350613          	addi	a2,a0,-13
ffffffffc02000f0:	02054963          	bltz	a0,ffffffffc0200122 <readline+0x70>
ffffffffc02000f4:	02a95f63          	bge	s2,a0,ffffffffc0200132 <readline+0x80>
ffffffffc02000f8:	cf0d                	beqz	a4,ffffffffc0200132 <readline+0x80>
ffffffffc02000fa:	0e6000ef          	jal	ffffffffc02001e0 <cputchar>
ffffffffc02000fe:	009987b3          	add	a5,s3,s1
ffffffffc0200102:	00878023          	sb	s0,0(a5)
ffffffffc0200106:	2485                	addiw	s1,s1,1
ffffffffc0200108:	0da000ef          	jal	ffffffffc02001e2 <getchar>
ffffffffc020010c:	842a                	mv	s0,a0
ffffffffc020010e:	ff850793          	addi	a5,a0,-8
ffffffffc0200112:	3ff4a713          	slti	a4,s1,1023
ffffffffc0200116:	ff650693          	addi	a3,a0,-10
ffffffffc020011a:	ff350613          	addi	a2,a0,-13
ffffffffc020011e:	fc055be3          	bgez	a0,ffffffffc02000f4 <readline+0x42>
ffffffffc0200122:	70a2                	ld	ra,40(sp)
ffffffffc0200124:	7402                	ld	s0,32(sp)
ffffffffc0200126:	64e2                	ld	s1,24(sp)
ffffffffc0200128:	6942                	ld	s2,16(sp)
ffffffffc020012a:	69a2                	ld	s3,8(sp)
ffffffffc020012c:	4501                	li	a0,0
ffffffffc020012e:	6145                	addi	sp,sp,48
ffffffffc0200130:	8082                	ret
ffffffffc0200132:	eb81                	bnez	a5,ffffffffc0200142 <readline+0x90>
ffffffffc0200134:	4521                	li	a0,8
ffffffffc0200136:	00905663          	blez	s1,ffffffffc0200142 <readline+0x90>
ffffffffc020013a:	0a6000ef          	jal	ffffffffc02001e0 <cputchar>
ffffffffc020013e:	34fd                	addiw	s1,s1,-1
ffffffffc0200140:	bf69                	j	ffffffffc02000da <readline+0x28>
ffffffffc0200142:	c291                	beqz	a3,ffffffffc0200146 <readline+0x94>
ffffffffc0200144:	fa59                	bnez	a2,ffffffffc02000da <readline+0x28>
ffffffffc0200146:	8522                	mv	a0,s0
ffffffffc0200148:	098000ef          	jal	ffffffffc02001e0 <cputchar>
ffffffffc020014c:	00091517          	auipc	a0,0x91
ffffffffc0200150:	f1450513          	addi	a0,a0,-236 # ffffffffc0291060 <buf>
ffffffffc0200154:	94aa                	add	s1,s1,a0
ffffffffc0200156:	00048023          	sb	zero,0(s1)
ffffffffc020015a:	70a2                	ld	ra,40(sp)
ffffffffc020015c:	7402                	ld	s0,32(sp)
ffffffffc020015e:	64e2                	ld	s1,24(sp)
ffffffffc0200160:	6942                	ld	s2,16(sp)
ffffffffc0200162:	69a2                	ld	s3,8(sp)
ffffffffc0200164:	6145                	addi	sp,sp,48
ffffffffc0200166:	8082                	ret

ffffffffc0200168 <cputch>:
ffffffffc0200168:	1101                	addi	sp,sp,-32
ffffffffc020016a:	ec06                	sd	ra,24(sp)
ffffffffc020016c:	e42e                	sd	a1,8(sp)
ffffffffc020016e:	3e0000ef          	jal	ffffffffc020054e <cons_putc>
ffffffffc0200172:	65a2                	ld	a1,8(sp)
ffffffffc0200174:	60e2                	ld	ra,24(sp)
ffffffffc0200176:	419c                	lw	a5,0(a1)
ffffffffc0200178:	2785                	addiw	a5,a5,1
ffffffffc020017a:	c19c                	sw	a5,0(a1)
ffffffffc020017c:	6105                	addi	sp,sp,32
ffffffffc020017e:	8082                	ret

ffffffffc0200180 <vcprintf>:
ffffffffc0200180:	1101                	addi	sp,sp,-32
ffffffffc0200182:	872e                	mv	a4,a1
ffffffffc0200184:	75dd                	lui	a1,0xffff7
ffffffffc0200186:	86aa                	mv	a3,a0
ffffffffc0200188:	0070                	addi	a2,sp,12
ffffffffc020018a:	00000517          	auipc	a0,0x0
ffffffffc020018e:	fde50513          	addi	a0,a0,-34 # ffffffffc0200168 <cputch>
ffffffffc0200192:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <end+0x3fd601c9>
ffffffffc0200196:	ec06                	sd	ra,24(sp)
ffffffffc0200198:	c602                	sw	zero,12(sp)
ffffffffc020019a:	1c20b0ef          	jal	ffffffffc020b35c <vprintfmt>
ffffffffc020019e:	60e2                	ld	ra,24(sp)
ffffffffc02001a0:	4532                	lw	a0,12(sp)
ffffffffc02001a2:	6105                	addi	sp,sp,32
ffffffffc02001a4:	8082                	ret

ffffffffc02001a6 <cprintf>:
ffffffffc02001a6:	711d                	addi	sp,sp,-96
ffffffffc02001a8:	02810313          	addi	t1,sp,40
ffffffffc02001ac:	f42e                	sd	a1,40(sp)
ffffffffc02001ae:	75dd                	lui	a1,0xffff7
ffffffffc02001b0:	f832                	sd	a2,48(sp)
ffffffffc02001b2:	fc36                	sd	a3,56(sp)
ffffffffc02001b4:	e0ba                	sd	a4,64(sp)
ffffffffc02001b6:	86aa                	mv	a3,a0
ffffffffc02001b8:	0050                	addi	a2,sp,4
ffffffffc02001ba:	00000517          	auipc	a0,0x0
ffffffffc02001be:	fae50513          	addi	a0,a0,-82 # ffffffffc0200168 <cputch>
ffffffffc02001c2:	871a                	mv	a4,t1
ffffffffc02001c4:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <end+0x3fd601c9>
ffffffffc02001c8:	ec06                	sd	ra,24(sp)
ffffffffc02001ca:	e4be                	sd	a5,72(sp)
ffffffffc02001cc:	e8c2                	sd	a6,80(sp)
ffffffffc02001ce:	ecc6                	sd	a7,88(sp)
ffffffffc02001d0:	c202                	sw	zero,4(sp)
ffffffffc02001d2:	e41a                	sd	t1,8(sp)
ffffffffc02001d4:	1880b0ef          	jal	ffffffffc020b35c <vprintfmt>
ffffffffc02001d8:	60e2                	ld	ra,24(sp)
ffffffffc02001da:	4512                	lw	a0,4(sp)
ffffffffc02001dc:	6125                	addi	sp,sp,96
ffffffffc02001de:	8082                	ret

ffffffffc02001e0 <cputchar>:
ffffffffc02001e0:	a6bd                	j	ffffffffc020054e <cons_putc>

ffffffffc02001e2 <getchar>:
ffffffffc02001e2:	1141                	addi	sp,sp,-16
ffffffffc02001e4:	e406                	sd	ra,8(sp)
ffffffffc02001e6:	3d0000ef          	jal	ffffffffc02005b6 <cons_getc>
ffffffffc02001ea:	dd75                	beqz	a0,ffffffffc02001e6 <getchar+0x4>
ffffffffc02001ec:	60a2                	ld	ra,8(sp)
ffffffffc02001ee:	0141                	addi	sp,sp,16
ffffffffc02001f0:	8082                	ret

ffffffffc02001f2 <strdup>:
ffffffffc02001f2:	7179                	addi	sp,sp,-48
ffffffffc02001f4:	f406                	sd	ra,40(sp)
ffffffffc02001f6:	f022                	sd	s0,32(sp)
ffffffffc02001f8:	ec26                	sd	s1,24(sp)
ffffffffc02001fa:	84aa                	mv	s1,a0
ffffffffc02001fc:	5480b0ef          	jal	ffffffffc020b744 <strlen>
ffffffffc0200200:	842a                	mv	s0,a0
ffffffffc0200202:	0505                	addi	a0,a0,1
ffffffffc0200204:	5bd010ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc0200208:	87aa                	mv	a5,a0
ffffffffc020020a:	c911                	beqz	a0,ffffffffc020021e <strdup+0x2c>
ffffffffc020020c:	8622                	mv	a2,s0
ffffffffc020020e:	85a6                	mv	a1,s1
ffffffffc0200210:	e42a                	sd	a0,8(sp)
ffffffffc0200212:	6360b0ef          	jal	ffffffffc020b848 <memcpy>
ffffffffc0200216:	67a2                	ld	a5,8(sp)
ffffffffc0200218:	943e                	add	s0,s0,a5
ffffffffc020021a:	00040023          	sb	zero,0(s0)
ffffffffc020021e:	70a2                	ld	ra,40(sp)
ffffffffc0200220:	7402                	ld	s0,32(sp)
ffffffffc0200222:	64e2                	ld	s1,24(sp)
ffffffffc0200224:	853e                	mv	a0,a5
ffffffffc0200226:	6145                	addi	sp,sp,48
ffffffffc0200228:	8082                	ret

ffffffffc020022a <print_kerninfo>:
ffffffffc020022a:	1141                	addi	sp,sp,-16
ffffffffc020022c:	0000b517          	auipc	a0,0xb
ffffffffc0200230:	66450513          	addi	a0,a0,1636 # ffffffffc020b890 <etext+0x30>
ffffffffc0200234:	e406                	sd	ra,8(sp)
ffffffffc0200236:	f71ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc020023a:	00000597          	auipc	a1,0x0
ffffffffc020023e:	e1058593          	addi	a1,a1,-496 # ffffffffc020004a <kern_init>
ffffffffc0200242:	0000b517          	auipc	a0,0xb
ffffffffc0200246:	66e50513          	addi	a0,a0,1646 # ffffffffc020b8b0 <etext+0x50>
ffffffffc020024a:	f5dff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc020024e:	0000b597          	auipc	a1,0xb
ffffffffc0200252:	61258593          	addi	a1,a1,1554 # ffffffffc020b860 <etext>
ffffffffc0200256:	0000b517          	auipc	a0,0xb
ffffffffc020025a:	67a50513          	addi	a0,a0,1658 # ffffffffc020b8d0 <etext+0x70>
ffffffffc020025e:	f49ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200262:	00091597          	auipc	a1,0x91
ffffffffc0200266:	dfe58593          	addi	a1,a1,-514 # ffffffffc0291060 <buf>
ffffffffc020026a:	0000b517          	auipc	a0,0xb
ffffffffc020026e:	68650513          	addi	a0,a0,1670 # ffffffffc020b8f0 <etext+0x90>
ffffffffc0200272:	f35ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200276:	00096597          	auipc	a1,0x96
ffffffffc020027a:	69a58593          	addi	a1,a1,1690 # ffffffffc0296910 <end>
ffffffffc020027e:	0000b517          	auipc	a0,0xb
ffffffffc0200282:	69250513          	addi	a0,a0,1682 # ffffffffc020b910 <etext+0xb0>
ffffffffc0200286:	f21ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc020028a:	00000717          	auipc	a4,0x0
ffffffffc020028e:	dc070713          	addi	a4,a4,-576 # ffffffffc020004a <kern_init>
ffffffffc0200292:	00097797          	auipc	a5,0x97
ffffffffc0200296:	a7d78793          	addi	a5,a5,-1411 # ffffffffc0296d0f <end+0x3ff>
ffffffffc020029a:	8f99                	sub	a5,a5,a4
ffffffffc020029c:	43f7d593          	srai	a1,a5,0x3f
ffffffffc02002a0:	60a2                	ld	ra,8(sp)
ffffffffc02002a2:	3ff5f593          	andi	a1,a1,1023
ffffffffc02002a6:	95be                	add	a1,a1,a5
ffffffffc02002a8:	85a9                	srai	a1,a1,0xa
ffffffffc02002aa:	0000b517          	auipc	a0,0xb
ffffffffc02002ae:	68650513          	addi	a0,a0,1670 # ffffffffc020b930 <etext+0xd0>
ffffffffc02002b2:	0141                	addi	sp,sp,16
ffffffffc02002b4:	bdcd                	j	ffffffffc02001a6 <cprintf>

ffffffffc02002b6 <print_stackframe>:
ffffffffc02002b6:	1141                	addi	sp,sp,-16
ffffffffc02002b8:	0000b617          	auipc	a2,0xb
ffffffffc02002bc:	6a860613          	addi	a2,a2,1704 # ffffffffc020b960 <etext+0x100>
ffffffffc02002c0:	04e00593          	li	a1,78
ffffffffc02002c4:	0000b517          	auipc	a0,0xb
ffffffffc02002c8:	6b450513          	addi	a0,a0,1716 # ffffffffc020b978 <etext+0x118>
ffffffffc02002cc:	e406                	sd	ra,8(sp)
ffffffffc02002ce:	17c000ef          	jal	ffffffffc020044a <__panic>

ffffffffc02002d2 <mon_help>:
ffffffffc02002d2:	1101                	addi	sp,sp,-32
ffffffffc02002d4:	e822                	sd	s0,16(sp)
ffffffffc02002d6:	e426                	sd	s1,8(sp)
ffffffffc02002d8:	ec06                	sd	ra,24(sp)
ffffffffc02002da:	0000f417          	auipc	s0,0xf
ffffffffc02002de:	bbe40413          	addi	s0,s0,-1090 # ffffffffc020ee98 <commands>
ffffffffc02002e2:	0000f497          	auipc	s1,0xf
ffffffffc02002e6:	bfe48493          	addi	s1,s1,-1026 # ffffffffc020eee0 <commands+0x48>
ffffffffc02002ea:	6410                	ld	a2,8(s0)
ffffffffc02002ec:	600c                	ld	a1,0(s0)
ffffffffc02002ee:	0000b517          	auipc	a0,0xb
ffffffffc02002f2:	6a250513          	addi	a0,a0,1698 # ffffffffc020b990 <etext+0x130>
ffffffffc02002f6:	0461                	addi	s0,s0,24
ffffffffc02002f8:	eafff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc02002fc:	fe9417e3          	bne	s0,s1,ffffffffc02002ea <mon_help+0x18>
ffffffffc0200300:	60e2                	ld	ra,24(sp)
ffffffffc0200302:	6442                	ld	s0,16(sp)
ffffffffc0200304:	64a2                	ld	s1,8(sp)
ffffffffc0200306:	4501                	li	a0,0
ffffffffc0200308:	6105                	addi	sp,sp,32
ffffffffc020030a:	8082                	ret

ffffffffc020030c <mon_kerninfo>:
ffffffffc020030c:	1141                	addi	sp,sp,-16
ffffffffc020030e:	e406                	sd	ra,8(sp)
ffffffffc0200310:	f1bff0ef          	jal	ffffffffc020022a <print_kerninfo>
ffffffffc0200314:	60a2                	ld	ra,8(sp)
ffffffffc0200316:	4501                	li	a0,0
ffffffffc0200318:	0141                	addi	sp,sp,16
ffffffffc020031a:	8082                	ret

ffffffffc020031c <mon_backtrace>:
ffffffffc020031c:	1141                	addi	sp,sp,-16
ffffffffc020031e:	e406                	sd	ra,8(sp)
ffffffffc0200320:	f97ff0ef          	jal	ffffffffc02002b6 <print_stackframe>
ffffffffc0200324:	60a2                	ld	ra,8(sp)
ffffffffc0200326:	4501                	li	a0,0
ffffffffc0200328:	0141                	addi	sp,sp,16
ffffffffc020032a:	8082                	ret

ffffffffc020032c <kmonitor>:
ffffffffc020032c:	7131                	addi	sp,sp,-192
ffffffffc020032e:	e952                	sd	s4,144(sp)
ffffffffc0200330:	8a2a                	mv	s4,a0
ffffffffc0200332:	0000b517          	auipc	a0,0xb
ffffffffc0200336:	66e50513          	addi	a0,a0,1646 # ffffffffc020b9a0 <etext+0x140>
ffffffffc020033a:	fd06                	sd	ra,184(sp)
ffffffffc020033c:	f922                	sd	s0,176(sp)
ffffffffc020033e:	f526                	sd	s1,168(sp)
ffffffffc0200340:	ed4e                	sd	s3,152(sp)
ffffffffc0200342:	e556                	sd	s5,136(sp)
ffffffffc0200344:	e15a                	sd	s6,128(sp)
ffffffffc0200346:	e61ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc020034a:	0000b517          	auipc	a0,0xb
ffffffffc020034e:	67e50513          	addi	a0,a0,1662 # ffffffffc020b9c8 <etext+0x168>
ffffffffc0200352:	e55ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200356:	000a0563          	beqz	s4,ffffffffc0200360 <kmonitor+0x34>
ffffffffc020035a:	8552                	mv	a0,s4
ffffffffc020035c:	391000ef          	jal	ffffffffc0200eec <print_trapframe>
ffffffffc0200360:	0000fa97          	auipc	s5,0xf
ffffffffc0200364:	b38a8a93          	addi	s5,s5,-1224 # ffffffffc020ee98 <commands>
ffffffffc0200368:	49bd                	li	s3,15
ffffffffc020036a:	0000b517          	auipc	a0,0xb
ffffffffc020036e:	68650513          	addi	a0,a0,1670 # ffffffffc020b9f0 <etext+0x190>
ffffffffc0200372:	d41ff0ef          	jal	ffffffffc02000b2 <readline>
ffffffffc0200376:	842a                	mv	s0,a0
ffffffffc0200378:	d96d                	beqz	a0,ffffffffc020036a <kmonitor+0x3e>
ffffffffc020037a:	00054583          	lbu	a1,0(a0)
ffffffffc020037e:	4481                	li	s1,0
ffffffffc0200380:	e99d                	bnez	a1,ffffffffc02003b6 <kmonitor+0x8a>
ffffffffc0200382:	8b26                	mv	s6,s1
ffffffffc0200384:	fe0b03e3          	beqz	s6,ffffffffc020036a <kmonitor+0x3e>
ffffffffc0200388:	0000f497          	auipc	s1,0xf
ffffffffc020038c:	b1048493          	addi	s1,s1,-1264 # ffffffffc020ee98 <commands>
ffffffffc0200390:	4401                	li	s0,0
ffffffffc0200392:	6582                	ld	a1,0(sp)
ffffffffc0200394:	6088                	ld	a0,0(s1)
ffffffffc0200396:	3f40b0ef          	jal	ffffffffc020b78a <strcmp>
ffffffffc020039a:	478d                	li	a5,3
ffffffffc020039c:	c149                	beqz	a0,ffffffffc020041e <kmonitor+0xf2>
ffffffffc020039e:	2405                	addiw	s0,s0,1
ffffffffc02003a0:	04e1                	addi	s1,s1,24
ffffffffc02003a2:	fef418e3          	bne	s0,a5,ffffffffc0200392 <kmonitor+0x66>
ffffffffc02003a6:	6582                	ld	a1,0(sp)
ffffffffc02003a8:	0000b517          	auipc	a0,0xb
ffffffffc02003ac:	67850513          	addi	a0,a0,1656 # ffffffffc020ba20 <etext+0x1c0>
ffffffffc02003b0:	df7ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc02003b4:	bf5d                	j	ffffffffc020036a <kmonitor+0x3e>
ffffffffc02003b6:	0000b517          	auipc	a0,0xb
ffffffffc02003ba:	64250513          	addi	a0,a0,1602 # ffffffffc020b9f8 <etext+0x198>
ffffffffc02003be:	4280b0ef          	jal	ffffffffc020b7e6 <strchr>
ffffffffc02003c2:	c901                	beqz	a0,ffffffffc02003d2 <kmonitor+0xa6>
ffffffffc02003c4:	00144583          	lbu	a1,1(s0)
ffffffffc02003c8:	00040023          	sb	zero,0(s0)
ffffffffc02003cc:	0405                	addi	s0,s0,1
ffffffffc02003ce:	d9d5                	beqz	a1,ffffffffc0200382 <kmonitor+0x56>
ffffffffc02003d0:	b7dd                	j	ffffffffc02003b6 <kmonitor+0x8a>
ffffffffc02003d2:	00044783          	lbu	a5,0(s0)
ffffffffc02003d6:	d7d5                	beqz	a5,ffffffffc0200382 <kmonitor+0x56>
ffffffffc02003d8:	03348b63          	beq	s1,s3,ffffffffc020040e <kmonitor+0xe2>
ffffffffc02003dc:	00349793          	slli	a5,s1,0x3
ffffffffc02003e0:	978a                	add	a5,a5,sp
ffffffffc02003e2:	e380                	sd	s0,0(a5)
ffffffffc02003e4:	00044583          	lbu	a1,0(s0)
ffffffffc02003e8:	2485                	addiw	s1,s1,1
ffffffffc02003ea:	8b26                	mv	s6,s1
ffffffffc02003ec:	e591                	bnez	a1,ffffffffc02003f8 <kmonitor+0xcc>
ffffffffc02003ee:	bf59                	j	ffffffffc0200384 <kmonitor+0x58>
ffffffffc02003f0:	00144583          	lbu	a1,1(s0)
ffffffffc02003f4:	0405                	addi	s0,s0,1
ffffffffc02003f6:	d5d1                	beqz	a1,ffffffffc0200382 <kmonitor+0x56>
ffffffffc02003f8:	0000b517          	auipc	a0,0xb
ffffffffc02003fc:	60050513          	addi	a0,a0,1536 # ffffffffc020b9f8 <etext+0x198>
ffffffffc0200400:	3e60b0ef          	jal	ffffffffc020b7e6 <strchr>
ffffffffc0200404:	d575                	beqz	a0,ffffffffc02003f0 <kmonitor+0xc4>
ffffffffc0200406:	00044583          	lbu	a1,0(s0)
ffffffffc020040a:	dda5                	beqz	a1,ffffffffc0200382 <kmonitor+0x56>
ffffffffc020040c:	b76d                	j	ffffffffc02003b6 <kmonitor+0x8a>
ffffffffc020040e:	45c1                	li	a1,16
ffffffffc0200410:	0000b517          	auipc	a0,0xb
ffffffffc0200414:	5f050513          	addi	a0,a0,1520 # ffffffffc020ba00 <etext+0x1a0>
ffffffffc0200418:	d8fff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc020041c:	b7c1                	j	ffffffffc02003dc <kmonitor+0xb0>
ffffffffc020041e:	00141793          	slli	a5,s0,0x1
ffffffffc0200422:	97a2                	add	a5,a5,s0
ffffffffc0200424:	078e                	slli	a5,a5,0x3
ffffffffc0200426:	97d6                	add	a5,a5,s5
ffffffffc0200428:	6b9c                	ld	a5,16(a5)
ffffffffc020042a:	fffb051b          	addiw	a0,s6,-1
ffffffffc020042e:	8652                	mv	a2,s4
ffffffffc0200430:	002c                	addi	a1,sp,8
ffffffffc0200432:	9782                	jalr	a5
ffffffffc0200434:	f2055be3          	bgez	a0,ffffffffc020036a <kmonitor+0x3e>
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
ffffffffc020044a:	00096317          	auipc	t1,0x96
ffffffffc020044e:	41e33303          	ld	t1,1054(t1) # ffffffffc0296868 <is_panic>
ffffffffc0200452:	715d                	addi	sp,sp,-80
ffffffffc0200454:	ec06                	sd	ra,24(sp)
ffffffffc0200456:	f436                	sd	a3,40(sp)
ffffffffc0200458:	f83a                	sd	a4,48(sp)
ffffffffc020045a:	fc3e                	sd	a5,56(sp)
ffffffffc020045c:	e0c2                	sd	a6,64(sp)
ffffffffc020045e:	e4c6                	sd	a7,72(sp)
ffffffffc0200460:	02031e63          	bnez	t1,ffffffffc020049c <__panic+0x52>
ffffffffc0200464:	4705                	li	a4,1
ffffffffc0200466:	103c                	addi	a5,sp,40
ffffffffc0200468:	e822                	sd	s0,16(sp)
ffffffffc020046a:	8432                	mv	s0,a2
ffffffffc020046c:	862e                	mv	a2,a1
ffffffffc020046e:	85aa                	mv	a1,a0
ffffffffc0200470:	0000b517          	auipc	a0,0xb
ffffffffc0200474:	65850513          	addi	a0,a0,1624 # ffffffffc020bac8 <etext+0x268>
ffffffffc0200478:	00096697          	auipc	a3,0x96
ffffffffc020047c:	3ee6b823          	sd	a4,1008(a3) # ffffffffc0296868 <is_panic>
ffffffffc0200480:	e43e                	sd	a5,8(sp)
ffffffffc0200482:	d25ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200486:	65a2                	ld	a1,8(sp)
ffffffffc0200488:	8522                	mv	a0,s0
ffffffffc020048a:	cf7ff0ef          	jal	ffffffffc0200180 <vcprintf>
ffffffffc020048e:	0000b517          	auipc	a0,0xb
ffffffffc0200492:	65a50513          	addi	a0,a0,1626 # ffffffffc020bae8 <etext+0x288>
ffffffffc0200496:	d11ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc020049a:	6442                	ld	s0,16(sp)
ffffffffc020049c:	4501                	li	a0,0
ffffffffc020049e:	4581                	li	a1,0
ffffffffc02004a0:	4601                	li	a2,0
ffffffffc02004a2:	48a1                	li	a7,8
ffffffffc02004a4:	00000073          	ecall
ffffffffc02004a8:	730000ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc02004ac:	4501                	li	a0,0
ffffffffc02004ae:	e7fff0ef          	jal	ffffffffc020032c <kmonitor>
ffffffffc02004b2:	bfed                	j	ffffffffc02004ac <__panic+0x62>

ffffffffc02004b4 <__warn>:
ffffffffc02004b4:	715d                	addi	sp,sp,-80
ffffffffc02004b6:	e822                	sd	s0,16(sp)
ffffffffc02004b8:	02810313          	addi	t1,sp,40
ffffffffc02004bc:	8432                	mv	s0,a2
ffffffffc02004be:	862e                	mv	a2,a1
ffffffffc02004c0:	85aa                	mv	a1,a0
ffffffffc02004c2:	0000b517          	auipc	a0,0xb
ffffffffc02004c6:	62e50513          	addi	a0,a0,1582 # ffffffffc020baf0 <etext+0x290>
ffffffffc02004ca:	ec06                	sd	ra,24(sp)
ffffffffc02004cc:	f436                	sd	a3,40(sp)
ffffffffc02004ce:	f83a                	sd	a4,48(sp)
ffffffffc02004d0:	fc3e                	sd	a5,56(sp)
ffffffffc02004d2:	e0c2                	sd	a6,64(sp)
ffffffffc02004d4:	e4c6                	sd	a7,72(sp)
ffffffffc02004d6:	e41a                	sd	t1,8(sp)
ffffffffc02004d8:	ccfff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc02004dc:	65a2                	ld	a1,8(sp)
ffffffffc02004de:	8522                	mv	a0,s0
ffffffffc02004e0:	ca1ff0ef          	jal	ffffffffc0200180 <vcprintf>
ffffffffc02004e4:	0000b517          	auipc	a0,0xb
ffffffffc02004e8:	60450513          	addi	a0,a0,1540 # ffffffffc020bae8 <etext+0x288>
ffffffffc02004ec:	cbbff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc02004f0:	60e2                	ld	ra,24(sp)
ffffffffc02004f2:	6442                	ld	s0,16(sp)
ffffffffc02004f4:	6161                	addi	sp,sp,80
ffffffffc02004f6:	8082                	ret

ffffffffc02004f8 <clock_init>:
ffffffffc02004f8:	02000793          	li	a5,32
ffffffffc02004fc:	1047a7f3          	csrrs	a5,sie,a5
ffffffffc0200500:	c0102573          	rdtime	a0
ffffffffc0200504:	67e1                	lui	a5,0x18
ffffffffc0200506:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_bin_swap_img_size+0x109a0>
ffffffffc020050a:	953e                	add	a0,a0,a5
ffffffffc020050c:	4581                	li	a1,0
ffffffffc020050e:	4601                	li	a2,0
ffffffffc0200510:	4881                	li	a7,0
ffffffffc0200512:	00000073          	ecall
ffffffffc0200516:	0000b517          	auipc	a0,0xb
ffffffffc020051a:	5fa50513          	addi	a0,a0,1530 # ffffffffc020bb10 <etext+0x2b0>
ffffffffc020051e:	00096797          	auipc	a5,0x96
ffffffffc0200522:	3407b923          	sd	zero,850(a5) # ffffffffc0296870 <ticks>
ffffffffc0200526:	b141                	j	ffffffffc02001a6 <cprintf>

ffffffffc0200528 <clock_set_next_event>:
ffffffffc0200528:	c0102573          	rdtime	a0
ffffffffc020052c:	67e1                	lui	a5,0x18
ffffffffc020052e:	6a078793          	addi	a5,a5,1696 # 186a0 <_binary_bin_swap_img_size+0x109a0>
ffffffffc0200532:	953e                	add	a0,a0,a5
ffffffffc0200534:	4581                	li	a1,0
ffffffffc0200536:	4601                	li	a2,0
ffffffffc0200538:	4881                	li	a7,0
ffffffffc020053a:	00000073          	ecall
ffffffffc020053e:	8082                	ret

ffffffffc0200540 <cons_init>:
ffffffffc0200540:	4501                	li	a0,0
ffffffffc0200542:	4581                	li	a1,0
ffffffffc0200544:	4601                	li	a2,0
ffffffffc0200546:	4889                	li	a7,2
ffffffffc0200548:	00000073          	ecall
ffffffffc020054c:	8082                	ret

ffffffffc020054e <cons_putc>:
ffffffffc020054e:	1101                	addi	sp,sp,-32
ffffffffc0200550:	ec06                	sd	ra,24(sp)
ffffffffc0200552:	100027f3          	csrr	a5,sstatus
ffffffffc0200556:	8b89                	andi	a5,a5,2
ffffffffc0200558:	ef95                	bnez	a5,ffffffffc0200594 <cons_putc+0x46>
ffffffffc020055a:	47a1                	li	a5,8
ffffffffc020055c:	00f50a63          	beq	a0,a5,ffffffffc0200570 <cons_putc+0x22>
ffffffffc0200560:	4581                	li	a1,0
ffffffffc0200562:	4601                	li	a2,0
ffffffffc0200564:	4885                	li	a7,1
ffffffffc0200566:	00000073          	ecall
ffffffffc020056a:	60e2                	ld	ra,24(sp)
ffffffffc020056c:	6105                	addi	sp,sp,32
ffffffffc020056e:	8082                	ret
ffffffffc0200570:	4781                	li	a5,0
ffffffffc0200572:	4521                	li	a0,8
ffffffffc0200574:	4581                	li	a1,0
ffffffffc0200576:	4601                	li	a2,0
ffffffffc0200578:	4885                	li	a7,1
ffffffffc020057a:	00000073          	ecall
ffffffffc020057e:	02000513          	li	a0,32
ffffffffc0200582:	00000073          	ecall
ffffffffc0200586:	4521                	li	a0,8
ffffffffc0200588:	00000073          	ecall
ffffffffc020058c:	dff9                	beqz	a5,ffffffffc020056a <cons_putc+0x1c>
ffffffffc020058e:	60e2                	ld	ra,24(sp)
ffffffffc0200590:	6105                	addi	sp,sp,32
ffffffffc0200592:	a581                	j	ffffffffc0200bd2 <intr_enable>
ffffffffc0200594:	e42a                	sd	a0,8(sp)
ffffffffc0200596:	642000ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc020059a:	6522                	ld	a0,8(sp)
ffffffffc020059c:	47a1                	li	a5,8
ffffffffc020059e:	00f50a63          	beq	a0,a5,ffffffffc02005b2 <cons_putc+0x64>
ffffffffc02005a2:	4581                	li	a1,0
ffffffffc02005a4:	4601                	li	a2,0
ffffffffc02005a6:	4885                	li	a7,1
ffffffffc02005a8:	00000073          	ecall
ffffffffc02005ac:	60e2                	ld	ra,24(sp)
ffffffffc02005ae:	6105                	addi	sp,sp,32
ffffffffc02005b0:	a50d                	j	ffffffffc0200bd2 <intr_enable>
ffffffffc02005b2:	4785                	li	a5,1
ffffffffc02005b4:	bf7d                	j	ffffffffc0200572 <cons_putc+0x24>

ffffffffc02005b6 <cons_getc>:
ffffffffc02005b6:	1101                	addi	sp,sp,-32
ffffffffc02005b8:	ec06                	sd	ra,24(sp)
ffffffffc02005ba:	100027f3          	csrr	a5,sstatus
ffffffffc02005be:	8b89                	andi	a5,a5,2
ffffffffc02005c0:	4801                	li	a6,0
ffffffffc02005c2:	e7d5                	bnez	a5,ffffffffc020066e <cons_getc+0xb8>
ffffffffc02005c4:	00091697          	auipc	a3,0x91
ffffffffc02005c8:	e9c68693          	addi	a3,a3,-356 # ffffffffc0291460 <cons>
ffffffffc02005cc:	07f00713          	li	a4,127
ffffffffc02005d0:	4501                	li	a0,0
ffffffffc02005d2:	4581                	li	a1,0
ffffffffc02005d4:	4601                	li	a2,0
ffffffffc02005d6:	4889                	li	a7,2
ffffffffc02005d8:	00000073          	ecall
ffffffffc02005dc:	0005079b          	sext.w	a5,a0
ffffffffc02005e0:	0207cd63          	bltz	a5,ffffffffc020061a <cons_getc+0x64>
ffffffffc02005e4:	02e78963          	beq	a5,a4,ffffffffc0200616 <cons_getc+0x60>
ffffffffc02005e8:	d7e5                	beqz	a5,ffffffffc02005d0 <cons_getc+0x1a>
ffffffffc02005ea:	00091797          	auipc	a5,0x91
ffffffffc02005ee:	07a7a783          	lw	a5,122(a5) # ffffffffc0291664 <cons+0x204>
ffffffffc02005f2:	20000593          	li	a1,512
ffffffffc02005f6:	02079613          	slli	a2,a5,0x20
ffffffffc02005fa:	9201                	srli	a2,a2,0x20
ffffffffc02005fc:	2785                	addiw	a5,a5,1
ffffffffc02005fe:	9636                	add	a2,a2,a3
ffffffffc0200600:	20f6a223          	sw	a5,516(a3)
ffffffffc0200604:	00a60023          	sb	a0,0(a2)
ffffffffc0200608:	fcb794e3          	bne	a5,a1,ffffffffc02005d0 <cons_getc+0x1a>
ffffffffc020060c:	00091797          	auipc	a5,0x91
ffffffffc0200610:	0407ac23          	sw	zero,88(a5) # ffffffffc0291664 <cons+0x204>
ffffffffc0200614:	bf75                	j	ffffffffc02005d0 <cons_getc+0x1a>
ffffffffc0200616:	4521                	li	a0,8
ffffffffc0200618:	bfc9                	j	ffffffffc02005ea <cons_getc+0x34>
ffffffffc020061a:	00091797          	auipc	a5,0x91
ffffffffc020061e:	0467a783          	lw	a5,70(a5) # ffffffffc0291660 <cons+0x200>
ffffffffc0200622:	00091717          	auipc	a4,0x91
ffffffffc0200626:	04272703          	lw	a4,66(a4) # ffffffffc0291664 <cons+0x204>
ffffffffc020062a:	4501                	li	a0,0
ffffffffc020062c:	00f70f63          	beq	a4,a5,ffffffffc020064a <cons_getc+0x94>
ffffffffc0200630:	02079713          	slli	a4,a5,0x20
ffffffffc0200634:	9301                	srli	a4,a4,0x20
ffffffffc0200636:	2785                	addiw	a5,a5,1
ffffffffc0200638:	20f6a023          	sw	a5,512(a3)
ffffffffc020063c:	96ba                	add	a3,a3,a4
ffffffffc020063e:	20000713          	li	a4,512
ffffffffc0200642:	0006c503          	lbu	a0,0(a3)
ffffffffc0200646:	00e78763          	beq	a5,a4,ffffffffc0200654 <cons_getc+0x9e>
ffffffffc020064a:	00081b63          	bnez	a6,ffffffffc0200660 <cons_getc+0xaa>
ffffffffc020064e:	60e2                	ld	ra,24(sp)
ffffffffc0200650:	6105                	addi	sp,sp,32
ffffffffc0200652:	8082                	ret
ffffffffc0200654:	00091797          	auipc	a5,0x91
ffffffffc0200658:	0007a623          	sw	zero,12(a5) # ffffffffc0291660 <cons+0x200>
ffffffffc020065c:	fe0809e3          	beqz	a6,ffffffffc020064e <cons_getc+0x98>
ffffffffc0200660:	e42a                	sd	a0,8(sp)
ffffffffc0200662:	570000ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0200666:	60e2                	ld	ra,24(sp)
ffffffffc0200668:	6522                	ld	a0,8(sp)
ffffffffc020066a:	6105                	addi	sp,sp,32
ffffffffc020066c:	8082                	ret
ffffffffc020066e:	56a000ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0200672:	4805                	li	a6,1
ffffffffc0200674:	bf81                	j	ffffffffc02005c4 <cons_getc+0xe>

ffffffffc0200676 <dtb_init>:
ffffffffc0200676:	7179                	addi	sp,sp,-48
ffffffffc0200678:	0000b517          	auipc	a0,0xb
ffffffffc020067c:	4b850513          	addi	a0,a0,1208 # ffffffffc020bb30 <etext+0x2d0>
ffffffffc0200680:	f406                	sd	ra,40(sp)
ffffffffc0200682:	f022                	sd	s0,32(sp)
ffffffffc0200684:	b23ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200688:	00014597          	auipc	a1,0x14
ffffffffc020068c:	9785b583          	ld	a1,-1672(a1) # ffffffffc0214000 <boot_hartid>
ffffffffc0200690:	0000b517          	auipc	a0,0xb
ffffffffc0200694:	4b050513          	addi	a0,a0,1200 # ffffffffc020bb40 <etext+0x2e0>
ffffffffc0200698:	00014417          	auipc	s0,0x14
ffffffffc020069c:	97040413          	addi	s0,s0,-1680 # ffffffffc0214008 <boot_dtb>
ffffffffc02006a0:	b07ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc02006a4:	600c                	ld	a1,0(s0)
ffffffffc02006a6:	0000b517          	auipc	a0,0xb
ffffffffc02006aa:	4aa50513          	addi	a0,a0,1194 # ffffffffc020bb50 <etext+0x2f0>
ffffffffc02006ae:	af9ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc02006b2:	6018                	ld	a4,0(s0)
ffffffffc02006b4:	0000b517          	auipc	a0,0xb
ffffffffc02006b8:	4b450513          	addi	a0,a0,1204 # ffffffffc020bb68 <etext+0x308>
ffffffffc02006bc:	10070163          	beqz	a4,ffffffffc02007be <dtb_init+0x148>
ffffffffc02006c0:	57f5                	li	a5,-3
ffffffffc02006c2:	07fa                	slli	a5,a5,0x1e
ffffffffc02006c4:	973e                	add	a4,a4,a5
ffffffffc02006c6:	431c                	lw	a5,0(a4)
ffffffffc02006c8:	d00e06b7          	lui	a3,0xd00e0
ffffffffc02006cc:	eed68693          	addi	a3,a3,-275 # ffffffffd00dfeed <end+0xfe495dd>
ffffffffc02006d0:	0087d59b          	srliw	a1,a5,0x8
ffffffffc02006d4:	0187961b          	slliw	a2,a5,0x18
ffffffffc02006d8:	0187d51b          	srliw	a0,a5,0x18
ffffffffc02006dc:	0ff5f593          	zext.b	a1,a1
ffffffffc02006e0:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02006e4:	05c2                	slli	a1,a1,0x10
ffffffffc02006e6:	8e49                	or	a2,a2,a0
ffffffffc02006e8:	0ff7f793          	zext.b	a5,a5
ffffffffc02006ec:	8dd1                	or	a1,a1,a2
ffffffffc02006ee:	07a2                	slli	a5,a5,0x8
ffffffffc02006f0:	8ddd                	or	a1,a1,a5
ffffffffc02006f2:	00ff0837          	lui	a6,0xff0
ffffffffc02006f6:	0cd59863          	bne	a1,a3,ffffffffc02007c6 <dtb_init+0x150>
ffffffffc02006fa:	4710                	lw	a2,8(a4)
ffffffffc02006fc:	4754                	lw	a3,12(a4)
ffffffffc02006fe:	e84a                	sd	s2,16(sp)
ffffffffc0200700:	0086541b          	srliw	s0,a2,0x8
ffffffffc0200704:	0086d79b          	srliw	a5,a3,0x8
ffffffffc0200708:	01865e1b          	srliw	t3,a2,0x18
ffffffffc020070c:	0186d89b          	srliw	a7,a3,0x18
ffffffffc0200710:	0186151b          	slliw	a0,a2,0x18
ffffffffc0200714:	0186959b          	slliw	a1,a3,0x18
ffffffffc0200718:	0104141b          	slliw	s0,s0,0x10
ffffffffc020071c:	0106561b          	srliw	a2,a2,0x10
ffffffffc0200720:	0107979b          	slliw	a5,a5,0x10
ffffffffc0200724:	0106d69b          	srliw	a3,a3,0x10
ffffffffc0200728:	01c56533          	or	a0,a0,t3
ffffffffc020072c:	0115e5b3          	or	a1,a1,a7
ffffffffc0200730:	01047433          	and	s0,s0,a6
ffffffffc0200734:	0ff67613          	zext.b	a2,a2
ffffffffc0200738:	0107f7b3          	and	a5,a5,a6
ffffffffc020073c:	0ff6f693          	zext.b	a3,a3
ffffffffc0200740:	8c49                	or	s0,s0,a0
ffffffffc0200742:	0622                	slli	a2,a2,0x8
ffffffffc0200744:	8fcd                	or	a5,a5,a1
ffffffffc0200746:	06a2                	slli	a3,a3,0x8
ffffffffc0200748:	8c51                	or	s0,s0,a2
ffffffffc020074a:	8fd5                	or	a5,a5,a3
ffffffffc020074c:	1402                	slli	s0,s0,0x20
ffffffffc020074e:	1782                	slli	a5,a5,0x20
ffffffffc0200750:	9001                	srli	s0,s0,0x20
ffffffffc0200752:	9381                	srli	a5,a5,0x20
ffffffffc0200754:	ec26                	sd	s1,24(sp)
ffffffffc0200756:	4301                	li	t1,0
ffffffffc0200758:	488d                	li	a7,3
ffffffffc020075a:	943a                	add	s0,s0,a4
ffffffffc020075c:	00e78933          	add	s2,a5,a4
ffffffffc0200760:	4e05                	li	t3,1
ffffffffc0200762:	4018                	lw	a4,0(s0)
ffffffffc0200764:	0087579b          	srliw	a5,a4,0x8
ffffffffc0200768:	0187169b          	slliw	a3,a4,0x18
ffffffffc020076c:	0187561b          	srliw	a2,a4,0x18
ffffffffc0200770:	0107979b          	slliw	a5,a5,0x10
ffffffffc0200774:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200778:	0107f7b3          	and	a5,a5,a6
ffffffffc020077c:	8ed1                	or	a3,a3,a2
ffffffffc020077e:	0ff77713          	zext.b	a4,a4
ffffffffc0200782:	8fd5                	or	a5,a5,a3
ffffffffc0200784:	0722                	slli	a4,a4,0x8
ffffffffc0200786:	8fd9                	or	a5,a5,a4
ffffffffc0200788:	05178763          	beq	a5,a7,ffffffffc02007d6 <dtb_init+0x160>
ffffffffc020078c:	0411                	addi	s0,s0,4
ffffffffc020078e:	00f8e963          	bltu	a7,a5,ffffffffc02007a0 <dtb_init+0x12a>
ffffffffc0200792:	07c78d63          	beq	a5,t3,ffffffffc020080c <dtb_init+0x196>
ffffffffc0200796:	4709                	li	a4,2
ffffffffc0200798:	00e79763          	bne	a5,a4,ffffffffc02007a6 <dtb_init+0x130>
ffffffffc020079c:	4301                	li	t1,0
ffffffffc020079e:	b7d1                	j	ffffffffc0200762 <dtb_init+0xec>
ffffffffc02007a0:	4711                	li	a4,4
ffffffffc02007a2:	fce780e3          	beq	a5,a4,ffffffffc0200762 <dtb_init+0xec>
ffffffffc02007a6:	0000b517          	auipc	a0,0xb
ffffffffc02007aa:	48a50513          	addi	a0,a0,1162 # ffffffffc020bc30 <etext+0x3d0>
ffffffffc02007ae:	9f9ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc02007b2:	64e2                	ld	s1,24(sp)
ffffffffc02007b4:	6942                	ld	s2,16(sp)
ffffffffc02007b6:	0000b517          	auipc	a0,0xb
ffffffffc02007ba:	4b250513          	addi	a0,a0,1202 # ffffffffc020bc68 <etext+0x408>
ffffffffc02007be:	7402                	ld	s0,32(sp)
ffffffffc02007c0:	70a2                	ld	ra,40(sp)
ffffffffc02007c2:	6145                	addi	sp,sp,48
ffffffffc02007c4:	b2cd                	j	ffffffffc02001a6 <cprintf>
ffffffffc02007c6:	7402                	ld	s0,32(sp)
ffffffffc02007c8:	70a2                	ld	ra,40(sp)
ffffffffc02007ca:	0000b517          	auipc	a0,0xb
ffffffffc02007ce:	3be50513          	addi	a0,a0,958 # ffffffffc020bb88 <etext+0x328>
ffffffffc02007d2:	6145                	addi	sp,sp,48
ffffffffc02007d4:	bac9                	j	ffffffffc02001a6 <cprintf>
ffffffffc02007d6:	4058                	lw	a4,4(s0)
ffffffffc02007d8:	0087579b          	srliw	a5,a4,0x8
ffffffffc02007dc:	0187169b          	slliw	a3,a4,0x18
ffffffffc02007e0:	0187561b          	srliw	a2,a4,0x18
ffffffffc02007e4:	0107979b          	slliw	a5,a5,0x10
ffffffffc02007e8:	0107571b          	srliw	a4,a4,0x10
ffffffffc02007ec:	0107f7b3          	and	a5,a5,a6
ffffffffc02007f0:	8ed1                	or	a3,a3,a2
ffffffffc02007f2:	0ff77713          	zext.b	a4,a4
ffffffffc02007f6:	8fd5                	or	a5,a5,a3
ffffffffc02007f8:	0722                	slli	a4,a4,0x8
ffffffffc02007fa:	8fd9                	or	a5,a5,a4
ffffffffc02007fc:	04031463          	bnez	t1,ffffffffc0200844 <dtb_init+0x1ce>
ffffffffc0200800:	1782                	slli	a5,a5,0x20
ffffffffc0200802:	9381                	srli	a5,a5,0x20
ffffffffc0200804:	043d                	addi	s0,s0,15
ffffffffc0200806:	943e                	add	s0,s0,a5
ffffffffc0200808:	9871                	andi	s0,s0,-4
ffffffffc020080a:	bfa1                	j	ffffffffc0200762 <dtb_init+0xec>
ffffffffc020080c:	8522                	mv	a0,s0
ffffffffc020080e:	e01a                	sd	t1,0(sp)
ffffffffc0200810:	7350a0ef          	jal	ffffffffc020b744 <strlen>
ffffffffc0200814:	84aa                	mv	s1,a0
ffffffffc0200816:	4619                	li	a2,6
ffffffffc0200818:	8522                	mv	a0,s0
ffffffffc020081a:	0000b597          	auipc	a1,0xb
ffffffffc020081e:	39658593          	addi	a1,a1,918 # ffffffffc020bbb0 <etext+0x350>
ffffffffc0200822:	79d0a0ef          	jal	ffffffffc020b7be <strncmp>
ffffffffc0200826:	6302                	ld	t1,0(sp)
ffffffffc0200828:	0411                	addi	s0,s0,4
ffffffffc020082a:	0004879b          	sext.w	a5,s1
ffffffffc020082e:	943e                	add	s0,s0,a5
ffffffffc0200830:	00153513          	seqz	a0,a0
ffffffffc0200834:	9871                	andi	s0,s0,-4
ffffffffc0200836:	00a36333          	or	t1,t1,a0
ffffffffc020083a:	00ff0837          	lui	a6,0xff0
ffffffffc020083e:	488d                	li	a7,3
ffffffffc0200840:	4e05                	li	t3,1
ffffffffc0200842:	b705                	j	ffffffffc0200762 <dtb_init+0xec>
ffffffffc0200844:	4418                	lw	a4,8(s0)
ffffffffc0200846:	0000b597          	auipc	a1,0xb
ffffffffc020084a:	37258593          	addi	a1,a1,882 # ffffffffc020bbb8 <etext+0x358>
ffffffffc020084e:	e43e                	sd	a5,8(sp)
ffffffffc0200850:	0087551b          	srliw	a0,a4,0x8
ffffffffc0200854:	0187561b          	srliw	a2,a4,0x18
ffffffffc0200858:	0187169b          	slliw	a3,a4,0x18
ffffffffc020085c:	0105151b          	slliw	a0,a0,0x10
ffffffffc0200860:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200864:	01057533          	and	a0,a0,a6
ffffffffc0200868:	8ed1                	or	a3,a3,a2
ffffffffc020086a:	0ff77713          	zext.b	a4,a4
ffffffffc020086e:	0722                	slli	a4,a4,0x8
ffffffffc0200870:	8d55                	or	a0,a0,a3
ffffffffc0200872:	8d59                	or	a0,a0,a4
ffffffffc0200874:	1502                	slli	a0,a0,0x20
ffffffffc0200876:	9101                	srli	a0,a0,0x20
ffffffffc0200878:	954a                	add	a0,a0,s2
ffffffffc020087a:	e01a                	sd	t1,0(sp)
ffffffffc020087c:	70f0a0ef          	jal	ffffffffc020b78a <strcmp>
ffffffffc0200880:	67a2                	ld	a5,8(sp)
ffffffffc0200882:	473d                	li	a4,15
ffffffffc0200884:	6302                	ld	t1,0(sp)
ffffffffc0200886:	00ff0837          	lui	a6,0xff0
ffffffffc020088a:	488d                	li	a7,3
ffffffffc020088c:	4e05                	li	t3,1
ffffffffc020088e:	f6f779e3          	bgeu	a4,a5,ffffffffc0200800 <dtb_init+0x18a>
ffffffffc0200892:	f53d                	bnez	a0,ffffffffc0200800 <dtb_init+0x18a>
ffffffffc0200894:	00c43683          	ld	a3,12(s0)
ffffffffc0200898:	01443703          	ld	a4,20(s0)
ffffffffc020089c:	0000b517          	auipc	a0,0xb
ffffffffc02008a0:	32450513          	addi	a0,a0,804 # ffffffffc020bbc0 <etext+0x360>
ffffffffc02008a4:	4206d793          	srai	a5,a3,0x20
ffffffffc02008a8:	0087d31b          	srliw	t1,a5,0x8
ffffffffc02008ac:	00871f93          	slli	t6,a4,0x8
ffffffffc02008b0:	42075893          	srai	a7,a4,0x20
ffffffffc02008b4:	0187df1b          	srliw	t5,a5,0x18
ffffffffc02008b8:	0187959b          	slliw	a1,a5,0x18
ffffffffc02008bc:	0103131b          	slliw	t1,t1,0x10
ffffffffc02008c0:	0107d79b          	srliw	a5,a5,0x10
ffffffffc02008c4:	420fd613          	srai	a2,t6,0x20
ffffffffc02008c8:	0188de9b          	srliw	t4,a7,0x18
ffffffffc02008cc:	01037333          	and	t1,t1,a6
ffffffffc02008d0:	01889e1b          	slliw	t3,a7,0x18
ffffffffc02008d4:	01e5e5b3          	or	a1,a1,t5
ffffffffc02008d8:	0ff7f793          	zext.b	a5,a5
ffffffffc02008dc:	01de6e33          	or	t3,t3,t4
ffffffffc02008e0:	0065e5b3          	or	a1,a1,t1
ffffffffc02008e4:	01067633          	and	a2,a2,a6
ffffffffc02008e8:	0086d31b          	srliw	t1,a3,0x8
ffffffffc02008ec:	0087541b          	srliw	s0,a4,0x8
ffffffffc02008f0:	07a2                	slli	a5,a5,0x8
ffffffffc02008f2:	0108d89b          	srliw	a7,a7,0x10
ffffffffc02008f6:	0186df1b          	srliw	t5,a3,0x18
ffffffffc02008fa:	01875e9b          	srliw	t4,a4,0x18
ffffffffc02008fe:	8ddd                	or	a1,a1,a5
ffffffffc0200900:	01c66633          	or	a2,a2,t3
ffffffffc0200904:	0186979b          	slliw	a5,a3,0x18
ffffffffc0200908:	01871e1b          	slliw	t3,a4,0x18
ffffffffc020090c:	0ff8f893          	zext.b	a7,a7
ffffffffc0200910:	0103131b          	slliw	t1,t1,0x10
ffffffffc0200914:	0106d69b          	srliw	a3,a3,0x10
ffffffffc0200918:	0104141b          	slliw	s0,s0,0x10
ffffffffc020091c:	0107571b          	srliw	a4,a4,0x10
ffffffffc0200920:	01037333          	and	t1,t1,a6
ffffffffc0200924:	08a2                	slli	a7,a7,0x8
ffffffffc0200926:	01e7e7b3          	or	a5,a5,t5
ffffffffc020092a:	01047433          	and	s0,s0,a6
ffffffffc020092e:	0ff6f693          	zext.b	a3,a3
ffffffffc0200932:	01de6833          	or	a6,t3,t4
ffffffffc0200936:	0ff77713          	zext.b	a4,a4
ffffffffc020093a:	01166633          	or	a2,a2,a7
ffffffffc020093e:	0067e7b3          	or	a5,a5,t1
ffffffffc0200942:	06a2                	slli	a3,a3,0x8
ffffffffc0200944:	01046433          	or	s0,s0,a6
ffffffffc0200948:	0722                	slli	a4,a4,0x8
ffffffffc020094a:	8fd5                	or	a5,a5,a3
ffffffffc020094c:	8c59                	or	s0,s0,a4
ffffffffc020094e:	1582                	slli	a1,a1,0x20
ffffffffc0200950:	1602                	slli	a2,a2,0x20
ffffffffc0200952:	1782                	slli	a5,a5,0x20
ffffffffc0200954:	9201                	srli	a2,a2,0x20
ffffffffc0200956:	9181                	srli	a1,a1,0x20
ffffffffc0200958:	1402                	slli	s0,s0,0x20
ffffffffc020095a:	00b7e4b3          	or	s1,a5,a1
ffffffffc020095e:	8c51                	or	s0,s0,a2
ffffffffc0200960:	847ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200964:	85a6                	mv	a1,s1
ffffffffc0200966:	0000b517          	auipc	a0,0xb
ffffffffc020096a:	27a50513          	addi	a0,a0,634 # ffffffffc020bbe0 <etext+0x380>
ffffffffc020096e:	839ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200972:	01445613          	srli	a2,s0,0x14
ffffffffc0200976:	85a2                	mv	a1,s0
ffffffffc0200978:	0000b517          	auipc	a0,0xb
ffffffffc020097c:	28050513          	addi	a0,a0,640 # ffffffffc020bbf8 <etext+0x398>
ffffffffc0200980:	827ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200984:	009405b3          	add	a1,s0,s1
ffffffffc0200988:	15fd                	addi	a1,a1,-1
ffffffffc020098a:	0000b517          	auipc	a0,0xb
ffffffffc020098e:	28e50513          	addi	a0,a0,654 # ffffffffc020bc18 <etext+0x3b8>
ffffffffc0200992:	815ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200996:	00096797          	auipc	a5,0x96
ffffffffc020099a:	ee97b523          	sd	s1,-278(a5) # ffffffffc0296880 <memory_base>
ffffffffc020099e:	00096797          	auipc	a5,0x96
ffffffffc02009a2:	ec87bd23          	sd	s0,-294(a5) # ffffffffc0296878 <memory_size>
ffffffffc02009a6:	b531                	j	ffffffffc02007b2 <dtb_init+0x13c>

ffffffffc02009a8 <get_memory_base>:
ffffffffc02009a8:	00096517          	auipc	a0,0x96
ffffffffc02009ac:	ed853503          	ld	a0,-296(a0) # ffffffffc0296880 <memory_base>
ffffffffc02009b0:	8082                	ret

ffffffffc02009b2 <get_memory_size>:
ffffffffc02009b2:	00096517          	auipc	a0,0x96
ffffffffc02009b6:	ec653503          	ld	a0,-314(a0) # ffffffffc0296878 <memory_size>
ffffffffc02009ba:	8082                	ret

ffffffffc02009bc <ide_init>:
ffffffffc02009bc:	1141                	addi	sp,sp,-16
ffffffffc02009be:	00091597          	auipc	a1,0x91
ffffffffc02009c2:	cfa58593          	addi	a1,a1,-774 # ffffffffc02916b8 <ide_devices+0x50>
ffffffffc02009c6:	4505                	li	a0,1
ffffffffc02009c8:	00091797          	auipc	a5,0x91
ffffffffc02009cc:	ca07a023          	sw	zero,-864(a5) # ffffffffc0291668 <ide_devices>
ffffffffc02009d0:	00091797          	auipc	a5,0x91
ffffffffc02009d4:	ce07a423          	sw	zero,-792(a5) # ffffffffc02916b8 <ide_devices+0x50>
ffffffffc02009d8:	00091797          	auipc	a5,0x91
ffffffffc02009dc:	d207a823          	sw	zero,-720(a5) # ffffffffc0291708 <ide_devices+0xa0>
ffffffffc02009e0:	00091797          	auipc	a5,0x91
ffffffffc02009e4:	d607ac23          	sw	zero,-648(a5) # ffffffffc0291758 <ide_devices+0xf0>
ffffffffc02009e8:	e406                	sd	ra,8(sp)
ffffffffc02009ea:	24c000ef          	jal	ffffffffc0200c36 <ramdisk_init>
ffffffffc02009ee:	00091797          	auipc	a5,0x91
ffffffffc02009f2:	cca7a783          	lw	a5,-822(a5) # ffffffffc02916b8 <ide_devices+0x50>
ffffffffc02009f6:	c385                	beqz	a5,ffffffffc0200a16 <ide_init+0x5a>
ffffffffc02009f8:	00091597          	auipc	a1,0x91
ffffffffc02009fc:	d1058593          	addi	a1,a1,-752 # ffffffffc0291708 <ide_devices+0xa0>
ffffffffc0200a00:	4509                	li	a0,2
ffffffffc0200a02:	234000ef          	jal	ffffffffc0200c36 <ramdisk_init>
ffffffffc0200a06:	00091797          	auipc	a5,0x91
ffffffffc0200a0a:	d027a783          	lw	a5,-766(a5) # ffffffffc0291708 <ide_devices+0xa0>
ffffffffc0200a0e:	c39d                	beqz	a5,ffffffffc0200a34 <ide_init+0x78>
ffffffffc0200a10:	60a2                	ld	ra,8(sp)
ffffffffc0200a12:	0141                	addi	sp,sp,16
ffffffffc0200a14:	8082                	ret
ffffffffc0200a16:	0000b697          	auipc	a3,0xb
ffffffffc0200a1a:	26a68693          	addi	a3,a3,618 # ffffffffc020bc80 <etext+0x420>
ffffffffc0200a1e:	0000b617          	auipc	a2,0xb
ffffffffc0200a22:	27a60613          	addi	a2,a2,634 # ffffffffc020bc98 <etext+0x438>
ffffffffc0200a26:	45c5                	li	a1,17
ffffffffc0200a28:	0000b517          	auipc	a0,0xb
ffffffffc0200a2c:	28850513          	addi	a0,a0,648 # ffffffffc020bcb0 <etext+0x450>
ffffffffc0200a30:	a1bff0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0200a34:	0000b697          	auipc	a3,0xb
ffffffffc0200a38:	29468693          	addi	a3,a3,660 # ffffffffc020bcc8 <etext+0x468>
ffffffffc0200a3c:	0000b617          	auipc	a2,0xb
ffffffffc0200a40:	25c60613          	addi	a2,a2,604 # ffffffffc020bc98 <etext+0x438>
ffffffffc0200a44:	45d1                	li	a1,20
ffffffffc0200a46:	0000b517          	auipc	a0,0xb
ffffffffc0200a4a:	26a50513          	addi	a0,a0,618 # ffffffffc020bcb0 <etext+0x450>
ffffffffc0200a4e:	9fdff0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0200a52 <ide_device_valid>:
ffffffffc0200a52:	478d                	li	a5,3
ffffffffc0200a54:	00a7ef63          	bltu	a5,a0,ffffffffc0200a72 <ide_device_valid+0x20>
ffffffffc0200a58:	00251793          	slli	a5,a0,0x2
ffffffffc0200a5c:	97aa                	add	a5,a5,a0
ffffffffc0200a5e:	00091717          	auipc	a4,0x91
ffffffffc0200a62:	c0a70713          	addi	a4,a4,-1014 # ffffffffc0291668 <ide_devices>
ffffffffc0200a66:	0792                	slli	a5,a5,0x4
ffffffffc0200a68:	97ba                	add	a5,a5,a4
ffffffffc0200a6a:	4388                	lw	a0,0(a5)
ffffffffc0200a6c:	00a03533          	snez	a0,a0
ffffffffc0200a70:	8082                	ret
ffffffffc0200a72:	4501                	li	a0,0
ffffffffc0200a74:	8082                	ret

ffffffffc0200a76 <ide_device_size>:
ffffffffc0200a76:	478d                	li	a5,3
ffffffffc0200a78:	02a7e163          	bltu	a5,a0,ffffffffc0200a9a <ide_device_size+0x24>
ffffffffc0200a7c:	00251793          	slli	a5,a0,0x2
ffffffffc0200a80:	97aa                	add	a5,a5,a0
ffffffffc0200a82:	00091717          	auipc	a4,0x91
ffffffffc0200a86:	be670713          	addi	a4,a4,-1050 # ffffffffc0291668 <ide_devices>
ffffffffc0200a8a:	0792                	slli	a5,a5,0x4
ffffffffc0200a8c:	97ba                	add	a5,a5,a4
ffffffffc0200a8e:	4398                	lw	a4,0(a5)
ffffffffc0200a90:	4501                	li	a0,0
ffffffffc0200a92:	c709                	beqz	a4,ffffffffc0200a9c <ide_device_size+0x26>
ffffffffc0200a94:	0087e503          	lwu	a0,8(a5)
ffffffffc0200a98:	8082                	ret
ffffffffc0200a9a:	4501                	li	a0,0
ffffffffc0200a9c:	8082                	ret

ffffffffc0200a9e <ide_read_secs>:
ffffffffc0200a9e:	1141                	addi	sp,sp,-16
ffffffffc0200aa0:	e406                	sd	ra,8(sp)
ffffffffc0200aa2:	0816b793          	sltiu	a5,a3,129
ffffffffc0200aa6:	cba9                	beqz	a5,ffffffffc0200af8 <ide_read_secs+0x5a>
ffffffffc0200aa8:	478d                	li	a5,3
ffffffffc0200aaa:	0005081b          	sext.w	a6,a0
ffffffffc0200aae:	04a7e563          	bltu	a5,a0,ffffffffc0200af8 <ide_read_secs+0x5a>
ffffffffc0200ab2:	00281793          	slli	a5,a6,0x2
ffffffffc0200ab6:	97c2                	add	a5,a5,a6
ffffffffc0200ab8:	0792                	slli	a5,a5,0x4
ffffffffc0200aba:	00091817          	auipc	a6,0x91
ffffffffc0200abe:	bae80813          	addi	a6,a6,-1106 # ffffffffc0291668 <ide_devices>
ffffffffc0200ac2:	97c2                	add	a5,a5,a6
ffffffffc0200ac4:	0007a883          	lw	a7,0(a5)
ffffffffc0200ac8:	02088863          	beqz	a7,ffffffffc0200af8 <ide_read_secs+0x5a>
ffffffffc0200acc:	100008b7          	lui	a7,0x10000
ffffffffc0200ad0:	0515f463          	bgeu	a1,a7,ffffffffc0200b18 <ide_read_secs+0x7a>
ffffffffc0200ad4:	1582                	slli	a1,a1,0x20
ffffffffc0200ad6:	9181                	srli	a1,a1,0x20
ffffffffc0200ad8:	00d58733          	add	a4,a1,a3
ffffffffc0200adc:	02e8ee63          	bltu	a7,a4,ffffffffc0200b18 <ide_read_secs+0x7a>
ffffffffc0200ae0:	00251713          	slli	a4,a0,0x2
ffffffffc0200ae4:	0407b883          	ld	a7,64(a5)
ffffffffc0200ae8:	60a2                	ld	ra,8(sp)
ffffffffc0200aea:	00a707b3          	add	a5,a4,a0
ffffffffc0200aee:	0792                	slli	a5,a5,0x4
ffffffffc0200af0:	00f80533          	add	a0,a6,a5
ffffffffc0200af4:	0141                	addi	sp,sp,16
ffffffffc0200af6:	8882                	jr	a7
ffffffffc0200af8:	0000b697          	auipc	a3,0xb
ffffffffc0200afc:	1e868693          	addi	a3,a3,488 # ffffffffc020bce0 <etext+0x480>
ffffffffc0200b00:	0000b617          	auipc	a2,0xb
ffffffffc0200b04:	19860613          	addi	a2,a2,408 # ffffffffc020bc98 <etext+0x438>
ffffffffc0200b08:	02200593          	li	a1,34
ffffffffc0200b0c:	0000b517          	auipc	a0,0xb
ffffffffc0200b10:	1a450513          	addi	a0,a0,420 # ffffffffc020bcb0 <etext+0x450>
ffffffffc0200b14:	937ff0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0200b18:	0000b697          	auipc	a3,0xb
ffffffffc0200b1c:	1f068693          	addi	a3,a3,496 # ffffffffc020bd08 <etext+0x4a8>
ffffffffc0200b20:	0000b617          	auipc	a2,0xb
ffffffffc0200b24:	17860613          	addi	a2,a2,376 # ffffffffc020bc98 <etext+0x438>
ffffffffc0200b28:	02300593          	li	a1,35
ffffffffc0200b2c:	0000b517          	auipc	a0,0xb
ffffffffc0200b30:	18450513          	addi	a0,a0,388 # ffffffffc020bcb0 <etext+0x450>
ffffffffc0200b34:	917ff0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0200b38 <ide_write_secs>:
ffffffffc0200b38:	1141                	addi	sp,sp,-16
ffffffffc0200b3a:	e406                	sd	ra,8(sp)
ffffffffc0200b3c:	0816b793          	sltiu	a5,a3,129
ffffffffc0200b40:	cba9                	beqz	a5,ffffffffc0200b92 <ide_write_secs+0x5a>
ffffffffc0200b42:	478d                	li	a5,3
ffffffffc0200b44:	0005081b          	sext.w	a6,a0
ffffffffc0200b48:	04a7e563          	bltu	a5,a0,ffffffffc0200b92 <ide_write_secs+0x5a>
ffffffffc0200b4c:	00281793          	slli	a5,a6,0x2
ffffffffc0200b50:	97c2                	add	a5,a5,a6
ffffffffc0200b52:	0792                	slli	a5,a5,0x4
ffffffffc0200b54:	00091817          	auipc	a6,0x91
ffffffffc0200b58:	b1480813          	addi	a6,a6,-1260 # ffffffffc0291668 <ide_devices>
ffffffffc0200b5c:	97c2                	add	a5,a5,a6
ffffffffc0200b5e:	0007a883          	lw	a7,0(a5)
ffffffffc0200b62:	02088863          	beqz	a7,ffffffffc0200b92 <ide_write_secs+0x5a>
ffffffffc0200b66:	100008b7          	lui	a7,0x10000
ffffffffc0200b6a:	0515f463          	bgeu	a1,a7,ffffffffc0200bb2 <ide_write_secs+0x7a>
ffffffffc0200b6e:	1582                	slli	a1,a1,0x20
ffffffffc0200b70:	9181                	srli	a1,a1,0x20
ffffffffc0200b72:	00d58733          	add	a4,a1,a3
ffffffffc0200b76:	02e8ee63          	bltu	a7,a4,ffffffffc0200bb2 <ide_write_secs+0x7a>
ffffffffc0200b7a:	00251713          	slli	a4,a0,0x2
ffffffffc0200b7e:	0487b883          	ld	a7,72(a5)
ffffffffc0200b82:	60a2                	ld	ra,8(sp)
ffffffffc0200b84:	00a707b3          	add	a5,a4,a0
ffffffffc0200b88:	0792                	slli	a5,a5,0x4
ffffffffc0200b8a:	00f80533          	add	a0,a6,a5
ffffffffc0200b8e:	0141                	addi	sp,sp,16
ffffffffc0200b90:	8882                	jr	a7
ffffffffc0200b92:	0000b697          	auipc	a3,0xb
ffffffffc0200b96:	14e68693          	addi	a3,a3,334 # ffffffffc020bce0 <etext+0x480>
ffffffffc0200b9a:	0000b617          	auipc	a2,0xb
ffffffffc0200b9e:	0fe60613          	addi	a2,a2,254 # ffffffffc020bc98 <etext+0x438>
ffffffffc0200ba2:	02900593          	li	a1,41
ffffffffc0200ba6:	0000b517          	auipc	a0,0xb
ffffffffc0200baa:	10a50513          	addi	a0,a0,266 # ffffffffc020bcb0 <etext+0x450>
ffffffffc0200bae:	89dff0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0200bb2:	0000b697          	auipc	a3,0xb
ffffffffc0200bb6:	15668693          	addi	a3,a3,342 # ffffffffc020bd08 <etext+0x4a8>
ffffffffc0200bba:	0000b617          	auipc	a2,0xb
ffffffffc0200bbe:	0de60613          	addi	a2,a2,222 # ffffffffc020bc98 <etext+0x438>
ffffffffc0200bc2:	02a00593          	li	a1,42
ffffffffc0200bc6:	0000b517          	auipc	a0,0xb
ffffffffc0200bca:	0ea50513          	addi	a0,a0,234 # ffffffffc020bcb0 <etext+0x450>
ffffffffc0200bce:	87dff0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0200bd2 <intr_enable>:
ffffffffc0200bd2:	100167f3          	csrrsi	a5,sstatus,2
ffffffffc0200bd6:	8082                	ret

ffffffffc0200bd8 <intr_disable>:
ffffffffc0200bd8:	100177f3          	csrrci	a5,sstatus,2
ffffffffc0200bdc:	8082                	ret

ffffffffc0200bde <pic_init>:
ffffffffc0200bde:	8082                	ret

ffffffffc0200be0 <ramdisk_write>:
ffffffffc0200be0:	00856783          	lwu	a5,8(a0)
ffffffffc0200be4:	1141                	addi	sp,sp,-16
ffffffffc0200be6:	e406                	sd	ra,8(sp)
ffffffffc0200be8:	8f8d                	sub	a5,a5,a1
ffffffffc0200bea:	8732                	mv	a4,a2
ffffffffc0200bec:	00f6f363          	bgeu	a3,a5,ffffffffc0200bf2 <ramdisk_write+0x12>
ffffffffc0200bf0:	87b6                	mv	a5,a3
ffffffffc0200bf2:	6914                	ld	a3,16(a0)
ffffffffc0200bf4:	00959513          	slli	a0,a1,0x9
ffffffffc0200bf8:	00979613          	slli	a2,a5,0x9
ffffffffc0200bfc:	9536                	add	a0,a0,a3
ffffffffc0200bfe:	85ba                	mv	a1,a4
ffffffffc0200c00:	4490a0ef          	jal	ffffffffc020b848 <memcpy>
ffffffffc0200c04:	60a2                	ld	ra,8(sp)
ffffffffc0200c06:	4501                	li	a0,0
ffffffffc0200c08:	0141                	addi	sp,sp,16
ffffffffc0200c0a:	8082                	ret

ffffffffc0200c0c <ramdisk_read>:
ffffffffc0200c0c:	00856783          	lwu	a5,8(a0)
ffffffffc0200c10:	1141                	addi	sp,sp,-16
ffffffffc0200c12:	e406                	sd	ra,8(sp)
ffffffffc0200c14:	8f8d                	sub	a5,a5,a1
ffffffffc0200c16:	872a                	mv	a4,a0
ffffffffc0200c18:	8532                	mv	a0,a2
ffffffffc0200c1a:	00f6f363          	bgeu	a3,a5,ffffffffc0200c20 <ramdisk_read+0x14>
ffffffffc0200c1e:	87b6                	mv	a5,a3
ffffffffc0200c20:	6b18                	ld	a4,16(a4)
ffffffffc0200c22:	05a6                	slli	a1,a1,0x9
ffffffffc0200c24:	00979613          	slli	a2,a5,0x9
ffffffffc0200c28:	95ba                	add	a1,a1,a4
ffffffffc0200c2a:	41f0a0ef          	jal	ffffffffc020b848 <memcpy>
ffffffffc0200c2e:	60a2                	ld	ra,8(sp)
ffffffffc0200c30:	4501                	li	a0,0
ffffffffc0200c32:	0141                	addi	sp,sp,16
ffffffffc0200c34:	8082                	ret

ffffffffc0200c36 <ramdisk_init>:
ffffffffc0200c36:	7179                	addi	sp,sp,-48
ffffffffc0200c38:	f022                	sd	s0,32(sp)
ffffffffc0200c3a:	ec26                	sd	s1,24(sp)
ffffffffc0200c3c:	842e                	mv	s0,a1
ffffffffc0200c3e:	84aa                	mv	s1,a0
ffffffffc0200c40:	05000613          	li	a2,80
ffffffffc0200c44:	852e                	mv	a0,a1
ffffffffc0200c46:	4581                	li	a1,0
ffffffffc0200c48:	f406                	sd	ra,40(sp)
ffffffffc0200c4a:	3af0a0ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc0200c4e:	4785                	li	a5,1
ffffffffc0200c50:	06f48a63          	beq	s1,a5,ffffffffc0200cc4 <ramdisk_init+0x8e>
ffffffffc0200c54:	4789                	li	a5,2
ffffffffc0200c56:	00090617          	auipc	a2,0x90
ffffffffc0200c5a:	3ba60613          	addi	a2,a2,954 # ffffffffc0291010 <arena>
ffffffffc0200c5e:	0001b597          	auipc	a1,0x1b
ffffffffc0200c62:	0b258593          	addi	a1,a1,178 # ffffffffc021bd10 <_binary_bin_sfs_img_start>
ffffffffc0200c66:	08f49363          	bne	s1,a5,ffffffffc0200cec <ramdisk_init+0xb6>
ffffffffc0200c6a:	06c58763          	beq	a1,a2,ffffffffc0200cd8 <ramdisk_init+0xa2>
ffffffffc0200c6e:	40b604b3          	sub	s1,a2,a1
ffffffffc0200c72:	86a6                	mv	a3,s1
ffffffffc0200c74:	167d                	addi	a2,a2,-1
ffffffffc0200c76:	0000b517          	auipc	a0,0xb
ffffffffc0200c7a:	0ea50513          	addi	a0,a0,234 # ffffffffc020bd60 <etext+0x500>
ffffffffc0200c7e:	e42e                	sd	a1,8(sp)
ffffffffc0200c80:	d26ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200c84:	65a2                	ld	a1,8(sp)
ffffffffc0200c86:	57fd                	li	a5,-1
ffffffffc0200c88:	1782                	slli	a5,a5,0x20
ffffffffc0200c8a:	0094d69b          	srliw	a3,s1,0x9
ffffffffc0200c8e:	0785                	addi	a5,a5,1
ffffffffc0200c90:	e80c                	sd	a1,16(s0)
ffffffffc0200c92:	e01c                	sd	a5,0(s0)
ffffffffc0200c94:	c414                	sw	a3,8(s0)
ffffffffc0200c96:	02040513          	addi	a0,s0,32
ffffffffc0200c9a:	0000b597          	auipc	a1,0xb
ffffffffc0200c9e:	11e58593          	addi	a1,a1,286 # ffffffffc020bdb8 <etext+0x558>
ffffffffc0200ca2:	2d70a0ef          	jal	ffffffffc020b778 <strcpy>
ffffffffc0200ca6:	00000717          	auipc	a4,0x0
ffffffffc0200caa:	f6670713          	addi	a4,a4,-154 # ffffffffc0200c0c <ramdisk_read>
ffffffffc0200cae:	00000797          	auipc	a5,0x0
ffffffffc0200cb2:	f3278793          	addi	a5,a5,-206 # ffffffffc0200be0 <ramdisk_write>
ffffffffc0200cb6:	70a2                	ld	ra,40(sp)
ffffffffc0200cb8:	e038                	sd	a4,64(s0)
ffffffffc0200cba:	e43c                	sd	a5,72(s0)
ffffffffc0200cbc:	7402                	ld	s0,32(sp)
ffffffffc0200cbe:	64e2                	ld	s1,24(sp)
ffffffffc0200cc0:	6145                	addi	sp,sp,48
ffffffffc0200cc2:	8082                	ret
ffffffffc0200cc4:	0001b617          	auipc	a2,0x1b
ffffffffc0200cc8:	04c60613          	addi	a2,a2,76 # ffffffffc021bd10 <_binary_bin_sfs_img_start>
ffffffffc0200ccc:	00013597          	auipc	a1,0x13
ffffffffc0200cd0:	34458593          	addi	a1,a1,836 # ffffffffc0214010 <_binary_bin_swap_img_start>
ffffffffc0200cd4:	f8c59de3          	bne	a1,a2,ffffffffc0200c6e <ramdisk_init+0x38>
ffffffffc0200cd8:	7402                	ld	s0,32(sp)
ffffffffc0200cda:	70a2                	ld	ra,40(sp)
ffffffffc0200cdc:	64e2                	ld	s1,24(sp)
ffffffffc0200cde:	0000b517          	auipc	a0,0xb
ffffffffc0200ce2:	06a50513          	addi	a0,a0,106 # ffffffffc020bd48 <etext+0x4e8>
ffffffffc0200ce6:	6145                	addi	sp,sp,48
ffffffffc0200ce8:	cbeff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc0200cec:	0000b617          	auipc	a2,0xb
ffffffffc0200cf0:	09c60613          	addi	a2,a2,156 # ffffffffc020bd88 <etext+0x528>
ffffffffc0200cf4:	03200593          	li	a1,50
ffffffffc0200cf8:	0000b517          	auipc	a0,0xb
ffffffffc0200cfc:	0a850513          	addi	a0,a0,168 # ffffffffc020bda0 <etext+0x540>
ffffffffc0200d00:	f4aff0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0200d04 <idt_init>:
ffffffffc0200d04:	14005073          	csrwi	sscratch,0
ffffffffc0200d08:	00000797          	auipc	a5,0x0
ffffffffc0200d0c:	47c78793          	addi	a5,a5,1148 # ffffffffc0201184 <__alltraps>
ffffffffc0200d10:	10579073          	csrw	stvec,a5
ffffffffc0200d14:	000407b7          	lui	a5,0x40
ffffffffc0200d18:	1007a7f3          	csrrs	a5,sstatus,a5
ffffffffc0200d1c:	8082                	ret

ffffffffc0200d1e <print_regs>:
ffffffffc0200d1e:	610c                	ld	a1,0(a0)
ffffffffc0200d20:	1141                	addi	sp,sp,-16
ffffffffc0200d22:	e022                	sd	s0,0(sp)
ffffffffc0200d24:	842a                	mv	s0,a0
ffffffffc0200d26:	0000b517          	auipc	a0,0xb
ffffffffc0200d2a:	0a250513          	addi	a0,a0,162 # ffffffffc020bdc8 <etext+0x568>
ffffffffc0200d2e:	e406                	sd	ra,8(sp)
ffffffffc0200d30:	c76ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200d34:	640c                	ld	a1,8(s0)
ffffffffc0200d36:	0000b517          	auipc	a0,0xb
ffffffffc0200d3a:	0aa50513          	addi	a0,a0,170 # ffffffffc020bde0 <etext+0x580>
ffffffffc0200d3e:	c68ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200d42:	680c                	ld	a1,16(s0)
ffffffffc0200d44:	0000b517          	auipc	a0,0xb
ffffffffc0200d48:	0b450513          	addi	a0,a0,180 # ffffffffc020bdf8 <etext+0x598>
ffffffffc0200d4c:	c5aff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200d50:	6c0c                	ld	a1,24(s0)
ffffffffc0200d52:	0000b517          	auipc	a0,0xb
ffffffffc0200d56:	0be50513          	addi	a0,a0,190 # ffffffffc020be10 <etext+0x5b0>
ffffffffc0200d5a:	c4cff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200d5e:	700c                	ld	a1,32(s0)
ffffffffc0200d60:	0000b517          	auipc	a0,0xb
ffffffffc0200d64:	0c850513          	addi	a0,a0,200 # ffffffffc020be28 <etext+0x5c8>
ffffffffc0200d68:	c3eff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200d6c:	740c                	ld	a1,40(s0)
ffffffffc0200d6e:	0000b517          	auipc	a0,0xb
ffffffffc0200d72:	0d250513          	addi	a0,a0,210 # ffffffffc020be40 <etext+0x5e0>
ffffffffc0200d76:	c30ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200d7a:	780c                	ld	a1,48(s0)
ffffffffc0200d7c:	0000b517          	auipc	a0,0xb
ffffffffc0200d80:	0dc50513          	addi	a0,a0,220 # ffffffffc020be58 <etext+0x5f8>
ffffffffc0200d84:	c22ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200d88:	7c0c                	ld	a1,56(s0)
ffffffffc0200d8a:	0000b517          	auipc	a0,0xb
ffffffffc0200d8e:	0e650513          	addi	a0,a0,230 # ffffffffc020be70 <etext+0x610>
ffffffffc0200d92:	c14ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200d96:	602c                	ld	a1,64(s0)
ffffffffc0200d98:	0000b517          	auipc	a0,0xb
ffffffffc0200d9c:	0f050513          	addi	a0,a0,240 # ffffffffc020be88 <etext+0x628>
ffffffffc0200da0:	c06ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200da4:	642c                	ld	a1,72(s0)
ffffffffc0200da6:	0000b517          	auipc	a0,0xb
ffffffffc0200daa:	0fa50513          	addi	a0,a0,250 # ffffffffc020bea0 <etext+0x640>
ffffffffc0200dae:	bf8ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200db2:	682c                	ld	a1,80(s0)
ffffffffc0200db4:	0000b517          	auipc	a0,0xb
ffffffffc0200db8:	10450513          	addi	a0,a0,260 # ffffffffc020beb8 <etext+0x658>
ffffffffc0200dbc:	beaff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200dc0:	6c2c                	ld	a1,88(s0)
ffffffffc0200dc2:	0000b517          	auipc	a0,0xb
ffffffffc0200dc6:	10e50513          	addi	a0,a0,270 # ffffffffc020bed0 <etext+0x670>
ffffffffc0200dca:	bdcff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200dce:	702c                	ld	a1,96(s0)
ffffffffc0200dd0:	0000b517          	auipc	a0,0xb
ffffffffc0200dd4:	11850513          	addi	a0,a0,280 # ffffffffc020bee8 <etext+0x688>
ffffffffc0200dd8:	bceff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200ddc:	742c                	ld	a1,104(s0)
ffffffffc0200dde:	0000b517          	auipc	a0,0xb
ffffffffc0200de2:	12250513          	addi	a0,a0,290 # ffffffffc020bf00 <etext+0x6a0>
ffffffffc0200de6:	bc0ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200dea:	782c                	ld	a1,112(s0)
ffffffffc0200dec:	0000b517          	auipc	a0,0xb
ffffffffc0200df0:	12c50513          	addi	a0,a0,300 # ffffffffc020bf18 <etext+0x6b8>
ffffffffc0200df4:	bb2ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200df8:	7c2c                	ld	a1,120(s0)
ffffffffc0200dfa:	0000b517          	auipc	a0,0xb
ffffffffc0200dfe:	13650513          	addi	a0,a0,310 # ffffffffc020bf30 <etext+0x6d0>
ffffffffc0200e02:	ba4ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200e06:	604c                	ld	a1,128(s0)
ffffffffc0200e08:	0000b517          	auipc	a0,0xb
ffffffffc0200e0c:	14050513          	addi	a0,a0,320 # ffffffffc020bf48 <etext+0x6e8>
ffffffffc0200e10:	b96ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200e14:	644c                	ld	a1,136(s0)
ffffffffc0200e16:	0000b517          	auipc	a0,0xb
ffffffffc0200e1a:	14a50513          	addi	a0,a0,330 # ffffffffc020bf60 <etext+0x700>
ffffffffc0200e1e:	b88ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200e22:	684c                	ld	a1,144(s0)
ffffffffc0200e24:	0000b517          	auipc	a0,0xb
ffffffffc0200e28:	15450513          	addi	a0,a0,340 # ffffffffc020bf78 <etext+0x718>
ffffffffc0200e2c:	b7aff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200e30:	6c4c                	ld	a1,152(s0)
ffffffffc0200e32:	0000b517          	auipc	a0,0xb
ffffffffc0200e36:	15e50513          	addi	a0,a0,350 # ffffffffc020bf90 <etext+0x730>
ffffffffc0200e3a:	b6cff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200e3e:	704c                	ld	a1,160(s0)
ffffffffc0200e40:	0000b517          	auipc	a0,0xb
ffffffffc0200e44:	16850513          	addi	a0,a0,360 # ffffffffc020bfa8 <etext+0x748>
ffffffffc0200e48:	b5eff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200e4c:	744c                	ld	a1,168(s0)
ffffffffc0200e4e:	0000b517          	auipc	a0,0xb
ffffffffc0200e52:	17250513          	addi	a0,a0,370 # ffffffffc020bfc0 <etext+0x760>
ffffffffc0200e56:	b50ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200e5a:	784c                	ld	a1,176(s0)
ffffffffc0200e5c:	0000b517          	auipc	a0,0xb
ffffffffc0200e60:	17c50513          	addi	a0,a0,380 # ffffffffc020bfd8 <etext+0x778>
ffffffffc0200e64:	b42ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200e68:	7c4c                	ld	a1,184(s0)
ffffffffc0200e6a:	0000b517          	auipc	a0,0xb
ffffffffc0200e6e:	18650513          	addi	a0,a0,390 # ffffffffc020bff0 <etext+0x790>
ffffffffc0200e72:	b34ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200e76:	606c                	ld	a1,192(s0)
ffffffffc0200e78:	0000b517          	auipc	a0,0xb
ffffffffc0200e7c:	19050513          	addi	a0,a0,400 # ffffffffc020c008 <etext+0x7a8>
ffffffffc0200e80:	b26ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200e84:	646c                	ld	a1,200(s0)
ffffffffc0200e86:	0000b517          	auipc	a0,0xb
ffffffffc0200e8a:	19a50513          	addi	a0,a0,410 # ffffffffc020c020 <etext+0x7c0>
ffffffffc0200e8e:	b18ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200e92:	686c                	ld	a1,208(s0)
ffffffffc0200e94:	0000b517          	auipc	a0,0xb
ffffffffc0200e98:	1a450513          	addi	a0,a0,420 # ffffffffc020c038 <etext+0x7d8>
ffffffffc0200e9c:	b0aff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200ea0:	6c6c                	ld	a1,216(s0)
ffffffffc0200ea2:	0000b517          	auipc	a0,0xb
ffffffffc0200ea6:	1ae50513          	addi	a0,a0,430 # ffffffffc020c050 <etext+0x7f0>
ffffffffc0200eaa:	afcff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200eae:	706c                	ld	a1,224(s0)
ffffffffc0200eb0:	0000b517          	auipc	a0,0xb
ffffffffc0200eb4:	1b850513          	addi	a0,a0,440 # ffffffffc020c068 <etext+0x808>
ffffffffc0200eb8:	aeeff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200ebc:	746c                	ld	a1,232(s0)
ffffffffc0200ebe:	0000b517          	auipc	a0,0xb
ffffffffc0200ec2:	1c250513          	addi	a0,a0,450 # ffffffffc020c080 <etext+0x820>
ffffffffc0200ec6:	ae0ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200eca:	786c                	ld	a1,240(s0)
ffffffffc0200ecc:	0000b517          	auipc	a0,0xb
ffffffffc0200ed0:	1cc50513          	addi	a0,a0,460 # ffffffffc020c098 <etext+0x838>
ffffffffc0200ed4:	ad2ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200ed8:	7c6c                	ld	a1,248(s0)
ffffffffc0200eda:	6402                	ld	s0,0(sp)
ffffffffc0200edc:	60a2                	ld	ra,8(sp)
ffffffffc0200ede:	0000b517          	auipc	a0,0xb
ffffffffc0200ee2:	1d250513          	addi	a0,a0,466 # ffffffffc020c0b0 <etext+0x850>
ffffffffc0200ee6:	0141                	addi	sp,sp,16
ffffffffc0200ee8:	abeff06f          	j	ffffffffc02001a6 <cprintf>

ffffffffc0200eec <print_trapframe>:
ffffffffc0200eec:	1141                	addi	sp,sp,-16
ffffffffc0200eee:	e022                	sd	s0,0(sp)
ffffffffc0200ef0:	85aa                	mv	a1,a0
ffffffffc0200ef2:	842a                	mv	s0,a0
ffffffffc0200ef4:	0000b517          	auipc	a0,0xb
ffffffffc0200ef8:	1d450513          	addi	a0,a0,468 # ffffffffc020c0c8 <etext+0x868>
ffffffffc0200efc:	e406                	sd	ra,8(sp)
ffffffffc0200efe:	aa8ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200f02:	8522                	mv	a0,s0
ffffffffc0200f04:	e1bff0ef          	jal	ffffffffc0200d1e <print_regs>
ffffffffc0200f08:	10043583          	ld	a1,256(s0)
ffffffffc0200f0c:	0000b517          	auipc	a0,0xb
ffffffffc0200f10:	1d450513          	addi	a0,a0,468 # ffffffffc020c0e0 <etext+0x880>
ffffffffc0200f14:	a92ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200f18:	10843583          	ld	a1,264(s0)
ffffffffc0200f1c:	0000b517          	auipc	a0,0xb
ffffffffc0200f20:	1dc50513          	addi	a0,a0,476 # ffffffffc020c0f8 <etext+0x898>
ffffffffc0200f24:	a82ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200f28:	11043583          	ld	a1,272(s0)
ffffffffc0200f2c:	0000b517          	auipc	a0,0xb
ffffffffc0200f30:	1e450513          	addi	a0,a0,484 # ffffffffc020c110 <etext+0x8b0>
ffffffffc0200f34:	a72ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0200f38:	11843583          	ld	a1,280(s0)
ffffffffc0200f3c:	6402                	ld	s0,0(sp)
ffffffffc0200f3e:	60a2                	ld	ra,8(sp)
ffffffffc0200f40:	0000b517          	auipc	a0,0xb
ffffffffc0200f44:	1e050513          	addi	a0,a0,480 # ffffffffc020c120 <etext+0x8c0>
ffffffffc0200f48:	0141                	addi	sp,sp,16
ffffffffc0200f4a:	a5cff06f          	j	ffffffffc02001a6 <cprintf>

ffffffffc0200f4e <interrupt_handler>:
ffffffffc0200f4e:	11853783          	ld	a5,280(a0)
ffffffffc0200f52:	472d                	li	a4,11
ffffffffc0200f54:	0786                	slli	a5,a5,0x1
ffffffffc0200f56:	8385                	srli	a5,a5,0x1
ffffffffc0200f58:	08f76063          	bltu	a4,a5,ffffffffc0200fd8 <interrupt_handler+0x8a>
ffffffffc0200f5c:	0000e717          	auipc	a4,0xe
ffffffffc0200f60:	f8470713          	addi	a4,a4,-124 # ffffffffc020eee0 <commands+0x48>
ffffffffc0200f64:	078a                	slli	a5,a5,0x2
ffffffffc0200f66:	97ba                	add	a5,a5,a4
ffffffffc0200f68:	439c                	lw	a5,0(a5)
ffffffffc0200f6a:	97ba                	add	a5,a5,a4
ffffffffc0200f6c:	8782                	jr	a5
ffffffffc0200f6e:	0000b517          	auipc	a0,0xb
ffffffffc0200f72:	22a50513          	addi	a0,a0,554 # ffffffffc020c198 <etext+0x938>
ffffffffc0200f76:	a30ff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc0200f7a:	0000b517          	auipc	a0,0xb
ffffffffc0200f7e:	1fe50513          	addi	a0,a0,510 # ffffffffc020c178 <etext+0x918>
ffffffffc0200f82:	a24ff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc0200f86:	0000b517          	auipc	a0,0xb
ffffffffc0200f8a:	1b250513          	addi	a0,a0,434 # ffffffffc020c138 <etext+0x8d8>
ffffffffc0200f8e:	a18ff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc0200f92:	0000b517          	auipc	a0,0xb
ffffffffc0200f96:	1c650513          	addi	a0,a0,454 # ffffffffc020c158 <etext+0x8f8>
ffffffffc0200f9a:	a0cff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc0200f9e:	1141                	addi	sp,sp,-16
ffffffffc0200fa0:	e406                	sd	ra,8(sp)
ffffffffc0200fa2:	d86ff0ef          	jal	ffffffffc0200528 <clock_set_next_event>
ffffffffc0200fa6:	00096797          	auipc	a5,0x96
ffffffffc0200faa:	8ca7b783          	ld	a5,-1846(a5) # ffffffffc0296870 <ticks>
ffffffffc0200fae:	0785                	addi	a5,a5,1
ffffffffc0200fb0:	00096717          	auipc	a4,0x96
ffffffffc0200fb4:	8cf73023          	sd	a5,-1856(a4) # ffffffffc0296870 <ticks>
ffffffffc0200fb8:	790060ef          	jal	ffffffffc0207748 <run_timer_list>
ffffffffc0200fbc:	dfaff0ef          	jal	ffffffffc02005b6 <cons_getc>
ffffffffc0200fc0:	60a2                	ld	ra,8(sp)
ffffffffc0200fc2:	0ff57513          	zext.b	a0,a0
ffffffffc0200fc6:	0141                	addi	sp,sp,16
ffffffffc0200fc8:	6a70706f          	j	ffffffffc0208e6e <dev_stdin_write>
ffffffffc0200fcc:	0000b517          	auipc	a0,0xb
ffffffffc0200fd0:	1ec50513          	addi	a0,a0,492 # ffffffffc020c1b8 <etext+0x958>
ffffffffc0200fd4:	9d2ff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc0200fd8:	bf11                	j	ffffffffc0200eec <print_trapframe>

ffffffffc0200fda <exception_handler>:
ffffffffc0200fda:	11853783          	ld	a5,280(a0)
ffffffffc0200fde:	473d                	li	a4,15
ffffffffc0200fe0:	10f76e63          	bltu	a4,a5,ffffffffc02010fc <exception_handler+0x122>
ffffffffc0200fe4:	0000e717          	auipc	a4,0xe
ffffffffc0200fe8:	f2c70713          	addi	a4,a4,-212 # ffffffffc020ef10 <commands+0x78>
ffffffffc0200fec:	078a                	slli	a5,a5,0x2
ffffffffc0200fee:	97ba                	add	a5,a5,a4
ffffffffc0200ff0:	439c                	lw	a5,0(a5)
ffffffffc0200ff2:	1101                	addi	sp,sp,-32
ffffffffc0200ff4:	ec06                	sd	ra,24(sp)
ffffffffc0200ff6:	97ba                	add	a5,a5,a4
ffffffffc0200ff8:	86aa                	mv	a3,a0
ffffffffc0200ffa:	8782                	jr	a5
ffffffffc0200ffc:	e42a                	sd	a0,8(sp)
ffffffffc0200ffe:	0000b517          	auipc	a0,0xb
ffffffffc0201002:	2c250513          	addi	a0,a0,706 # ffffffffc020c2c0 <etext+0xa60>
ffffffffc0201006:	9a0ff0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc020100a:	66a2                	ld	a3,8(sp)
ffffffffc020100c:	1086b783          	ld	a5,264(a3)
ffffffffc0201010:	60e2                	ld	ra,24(sp)
ffffffffc0201012:	0791                	addi	a5,a5,4
ffffffffc0201014:	10f6b423          	sd	a5,264(a3)
ffffffffc0201018:	6105                	addi	sp,sp,32
ffffffffc020101a:	17f0606f          	j	ffffffffc0207998 <syscall>
ffffffffc020101e:	60e2                	ld	ra,24(sp)
ffffffffc0201020:	0000b517          	auipc	a0,0xb
ffffffffc0201024:	2c050513          	addi	a0,a0,704 # ffffffffc020c2e0 <etext+0xa80>
ffffffffc0201028:	6105                	addi	sp,sp,32
ffffffffc020102a:	97cff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc020102e:	60e2                	ld	ra,24(sp)
ffffffffc0201030:	0000b517          	auipc	a0,0xb
ffffffffc0201034:	2d050513          	addi	a0,a0,720 # ffffffffc020c300 <etext+0xaa0>
ffffffffc0201038:	6105                	addi	sp,sp,32
ffffffffc020103a:	96cff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc020103e:	60e2                	ld	ra,24(sp)
ffffffffc0201040:	0000b517          	auipc	a0,0xb
ffffffffc0201044:	2e050513          	addi	a0,a0,736 # ffffffffc020c320 <etext+0xac0>
ffffffffc0201048:	6105                	addi	sp,sp,32
ffffffffc020104a:	95cff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc020104e:	60e2                	ld	ra,24(sp)
ffffffffc0201050:	0000b517          	auipc	a0,0xb
ffffffffc0201054:	2e850513          	addi	a0,a0,744 # ffffffffc020c338 <etext+0xad8>
ffffffffc0201058:	6105                	addi	sp,sp,32
ffffffffc020105a:	94cff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc020105e:	60e2                	ld	ra,24(sp)
ffffffffc0201060:	0000b517          	auipc	a0,0xb
ffffffffc0201064:	2f050513          	addi	a0,a0,752 # ffffffffc020c350 <etext+0xaf0>
ffffffffc0201068:	6105                	addi	sp,sp,32
ffffffffc020106a:	93cff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc020106e:	60e2                	ld	ra,24(sp)
ffffffffc0201070:	0000b517          	auipc	a0,0xb
ffffffffc0201074:	16850513          	addi	a0,a0,360 # ffffffffc020c1d8 <etext+0x978>
ffffffffc0201078:	6105                	addi	sp,sp,32
ffffffffc020107a:	92cff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc020107e:	60e2                	ld	ra,24(sp)
ffffffffc0201080:	0000b517          	auipc	a0,0xb
ffffffffc0201084:	17850513          	addi	a0,a0,376 # ffffffffc020c1f8 <etext+0x998>
ffffffffc0201088:	6105                	addi	sp,sp,32
ffffffffc020108a:	91cff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc020108e:	60e2                	ld	ra,24(sp)
ffffffffc0201090:	0000b517          	auipc	a0,0xb
ffffffffc0201094:	18850513          	addi	a0,a0,392 # ffffffffc020c218 <etext+0x9b8>
ffffffffc0201098:	6105                	addi	sp,sp,32
ffffffffc020109a:	90cff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc020109e:	60e2                	ld	ra,24(sp)
ffffffffc02010a0:	0000b517          	auipc	a0,0xb
ffffffffc02010a4:	19050513          	addi	a0,a0,400 # ffffffffc020c230 <etext+0x9d0>
ffffffffc02010a8:	6105                	addi	sp,sp,32
ffffffffc02010aa:	8fcff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc02010ae:	60e2                	ld	ra,24(sp)
ffffffffc02010b0:	0000b517          	auipc	a0,0xb
ffffffffc02010b4:	19050513          	addi	a0,a0,400 # ffffffffc020c240 <etext+0x9e0>
ffffffffc02010b8:	6105                	addi	sp,sp,32
ffffffffc02010ba:	8ecff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc02010be:	60e2                	ld	ra,24(sp)
ffffffffc02010c0:	0000b517          	auipc	a0,0xb
ffffffffc02010c4:	1a050513          	addi	a0,a0,416 # ffffffffc020c260 <etext+0xa00>
ffffffffc02010c8:	6105                	addi	sp,sp,32
ffffffffc02010ca:	8dcff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc02010ce:	60e2                	ld	ra,24(sp)
ffffffffc02010d0:	0000b517          	auipc	a0,0xb
ffffffffc02010d4:	1d850513          	addi	a0,a0,472 # ffffffffc020c2a8 <etext+0xa48>
ffffffffc02010d8:	6105                	addi	sp,sp,32
ffffffffc02010da:	8ccff06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc02010de:	60e2                	ld	ra,24(sp)
ffffffffc02010e0:	6105                	addi	sp,sp,32
ffffffffc02010e2:	b529                	j	ffffffffc0200eec <print_trapframe>
ffffffffc02010e4:	0000b617          	auipc	a2,0xb
ffffffffc02010e8:	19460613          	addi	a2,a2,404 # ffffffffc020c278 <etext+0xa18>
ffffffffc02010ec:	0b300593          	li	a1,179
ffffffffc02010f0:	0000b517          	auipc	a0,0xb
ffffffffc02010f4:	1a050513          	addi	a0,a0,416 # ffffffffc020c290 <etext+0xa30>
ffffffffc02010f8:	b52ff0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02010fc:	bbc5                	j	ffffffffc0200eec <print_trapframe>

ffffffffc02010fe <trap>:
ffffffffc02010fe:	00095717          	auipc	a4,0x95
ffffffffc0201102:	7ca73703          	ld	a4,1994(a4) # ffffffffc02968c8 <current>
ffffffffc0201106:	11853583          	ld	a1,280(a0)
ffffffffc020110a:	cf21                	beqz	a4,ffffffffc0201162 <trap+0x64>
ffffffffc020110c:	10053603          	ld	a2,256(a0)
ffffffffc0201110:	0a073803          	ld	a6,160(a4)
ffffffffc0201114:	1101                	addi	sp,sp,-32
ffffffffc0201116:	ec06                	sd	ra,24(sp)
ffffffffc0201118:	10067613          	andi	a2,a2,256
ffffffffc020111c:	f348                	sd	a0,160(a4)
ffffffffc020111e:	e432                	sd	a2,8(sp)
ffffffffc0201120:	e042                	sd	a6,0(sp)
ffffffffc0201122:	0205c763          	bltz	a1,ffffffffc0201150 <trap+0x52>
ffffffffc0201126:	eb5ff0ef          	jal	ffffffffc0200fda <exception_handler>
ffffffffc020112a:	6622                	ld	a2,8(sp)
ffffffffc020112c:	6802                	ld	a6,0(sp)
ffffffffc020112e:	00095697          	auipc	a3,0x95
ffffffffc0201132:	79a68693          	addi	a3,a3,1946 # ffffffffc02968c8 <current>
ffffffffc0201136:	6298                	ld	a4,0(a3)
ffffffffc0201138:	0b073023          	sd	a6,160(a4)
ffffffffc020113c:	e619                	bnez	a2,ffffffffc020114a <trap+0x4c>
ffffffffc020113e:	0b072783          	lw	a5,176(a4)
ffffffffc0201142:	8b85                	andi	a5,a5,1
ffffffffc0201144:	e79d                	bnez	a5,ffffffffc0201172 <trap+0x74>
ffffffffc0201146:	6f1c                	ld	a5,24(a4)
ffffffffc0201148:	e38d                	bnez	a5,ffffffffc020116a <trap+0x6c>
ffffffffc020114a:	60e2                	ld	ra,24(sp)
ffffffffc020114c:	6105                	addi	sp,sp,32
ffffffffc020114e:	8082                	ret
ffffffffc0201150:	dffff0ef          	jal	ffffffffc0200f4e <interrupt_handler>
ffffffffc0201154:	6802                	ld	a6,0(sp)
ffffffffc0201156:	6622                	ld	a2,8(sp)
ffffffffc0201158:	00095697          	auipc	a3,0x95
ffffffffc020115c:	77068693          	addi	a3,a3,1904 # ffffffffc02968c8 <current>
ffffffffc0201160:	bfd9                	j	ffffffffc0201136 <trap+0x38>
ffffffffc0201162:	0005c363          	bltz	a1,ffffffffc0201168 <trap+0x6a>
ffffffffc0201166:	bd95                	j	ffffffffc0200fda <exception_handler>
ffffffffc0201168:	b3dd                	j	ffffffffc0200f4e <interrupt_handler>
ffffffffc020116a:	60e2                	ld	ra,24(sp)
ffffffffc020116c:	6105                	addi	sp,sp,32
ffffffffc020116e:	3d00606f          	j	ffffffffc020753e <schedule>
ffffffffc0201172:	555d                	li	a0,-9
ffffffffc0201174:	072050ef          	jal	ffffffffc02061e6 <do_exit>
ffffffffc0201178:	00095717          	auipc	a4,0x95
ffffffffc020117c:	75073703          	ld	a4,1872(a4) # ffffffffc02968c8 <current>
ffffffffc0201180:	b7d9                	j	ffffffffc0201146 <trap+0x48>
	...

ffffffffc0201184 <__alltraps>:
ffffffffc0201184:	14011173          	csrrw	sp,sscratch,sp
ffffffffc0201188:	00011463          	bnez	sp,ffffffffc0201190 <__alltraps+0xc>
ffffffffc020118c:	14002173          	csrr	sp,sscratch
ffffffffc0201190:	712d                	addi	sp,sp,-288
ffffffffc0201192:	e002                	sd	zero,0(sp)
ffffffffc0201194:	e406                	sd	ra,8(sp)
ffffffffc0201196:	ec0e                	sd	gp,24(sp)
ffffffffc0201198:	f012                	sd	tp,32(sp)
ffffffffc020119a:	f416                	sd	t0,40(sp)
ffffffffc020119c:	f81a                	sd	t1,48(sp)
ffffffffc020119e:	fc1e                	sd	t2,56(sp)
ffffffffc02011a0:	e0a2                	sd	s0,64(sp)
ffffffffc02011a2:	e4a6                	sd	s1,72(sp)
ffffffffc02011a4:	e8aa                	sd	a0,80(sp)
ffffffffc02011a6:	ecae                	sd	a1,88(sp)
ffffffffc02011a8:	f0b2                	sd	a2,96(sp)
ffffffffc02011aa:	f4b6                	sd	a3,104(sp)
ffffffffc02011ac:	f8ba                	sd	a4,112(sp)
ffffffffc02011ae:	fcbe                	sd	a5,120(sp)
ffffffffc02011b0:	e142                	sd	a6,128(sp)
ffffffffc02011b2:	e546                	sd	a7,136(sp)
ffffffffc02011b4:	e94a                	sd	s2,144(sp)
ffffffffc02011b6:	ed4e                	sd	s3,152(sp)
ffffffffc02011b8:	f152                	sd	s4,160(sp)
ffffffffc02011ba:	f556                	sd	s5,168(sp)
ffffffffc02011bc:	f95a                	sd	s6,176(sp)
ffffffffc02011be:	fd5e                	sd	s7,184(sp)
ffffffffc02011c0:	e1e2                	sd	s8,192(sp)
ffffffffc02011c2:	e5e6                	sd	s9,200(sp)
ffffffffc02011c4:	e9ea                	sd	s10,208(sp)
ffffffffc02011c6:	edee                	sd	s11,216(sp)
ffffffffc02011c8:	f1f2                	sd	t3,224(sp)
ffffffffc02011ca:	f5f6                	sd	t4,232(sp)
ffffffffc02011cc:	f9fa                	sd	t5,240(sp)
ffffffffc02011ce:	fdfe                	sd	t6,248(sp)
ffffffffc02011d0:	14001473          	csrrw	s0,sscratch,zero
ffffffffc02011d4:	100024f3          	csrr	s1,sstatus
ffffffffc02011d8:	14102973          	csrr	s2,sepc
ffffffffc02011dc:	143029f3          	csrr	s3,stval
ffffffffc02011e0:	14202a73          	csrr	s4,scause
ffffffffc02011e4:	e822                	sd	s0,16(sp)
ffffffffc02011e6:	e226                	sd	s1,256(sp)
ffffffffc02011e8:	e64a                	sd	s2,264(sp)
ffffffffc02011ea:	ea4e                	sd	s3,272(sp)
ffffffffc02011ec:	ee52                	sd	s4,280(sp)
ffffffffc02011ee:	850a                	mv	a0,sp
ffffffffc02011f0:	f0fff0ef          	jal	ffffffffc02010fe <trap>

ffffffffc02011f4 <__trapret>:
ffffffffc02011f4:	6492                	ld	s1,256(sp)
ffffffffc02011f6:	6932                	ld	s2,264(sp)
ffffffffc02011f8:	1004f413          	andi	s0,s1,256
ffffffffc02011fc:	e401                	bnez	s0,ffffffffc0201204 <__trapret+0x10>
ffffffffc02011fe:	1200                	addi	s0,sp,288
ffffffffc0201200:	14041073          	csrw	sscratch,s0
ffffffffc0201204:	10049073          	csrw	sstatus,s1
ffffffffc0201208:	14191073          	csrw	sepc,s2
ffffffffc020120c:	60a2                	ld	ra,8(sp)
ffffffffc020120e:	61e2                	ld	gp,24(sp)
ffffffffc0201210:	7202                	ld	tp,32(sp)
ffffffffc0201212:	72a2                	ld	t0,40(sp)
ffffffffc0201214:	7342                	ld	t1,48(sp)
ffffffffc0201216:	73e2                	ld	t2,56(sp)
ffffffffc0201218:	6406                	ld	s0,64(sp)
ffffffffc020121a:	64a6                	ld	s1,72(sp)
ffffffffc020121c:	6546                	ld	a0,80(sp)
ffffffffc020121e:	65e6                	ld	a1,88(sp)
ffffffffc0201220:	7606                	ld	a2,96(sp)
ffffffffc0201222:	76a6                	ld	a3,104(sp)
ffffffffc0201224:	7746                	ld	a4,112(sp)
ffffffffc0201226:	77e6                	ld	a5,120(sp)
ffffffffc0201228:	680a                	ld	a6,128(sp)
ffffffffc020122a:	68aa                	ld	a7,136(sp)
ffffffffc020122c:	694a                	ld	s2,144(sp)
ffffffffc020122e:	69ea                	ld	s3,152(sp)
ffffffffc0201230:	7a0a                	ld	s4,160(sp)
ffffffffc0201232:	7aaa                	ld	s5,168(sp)
ffffffffc0201234:	7b4a                	ld	s6,176(sp)
ffffffffc0201236:	7bea                	ld	s7,184(sp)
ffffffffc0201238:	6c0e                	ld	s8,192(sp)
ffffffffc020123a:	6cae                	ld	s9,200(sp)
ffffffffc020123c:	6d4e                	ld	s10,208(sp)
ffffffffc020123e:	6dee                	ld	s11,216(sp)
ffffffffc0201240:	7e0e                	ld	t3,224(sp)
ffffffffc0201242:	7eae                	ld	t4,232(sp)
ffffffffc0201244:	7f4e                	ld	t5,240(sp)
ffffffffc0201246:	7fee                	ld	t6,248(sp)
ffffffffc0201248:	6142                	ld	sp,16(sp)
ffffffffc020124a:	10200073          	sret

ffffffffc020124e <forkrets>:
ffffffffc020124e:	812a                	mv	sp,a0
ffffffffc0201250:	b755                	j	ffffffffc02011f4 <__trapret>

ffffffffc0201252 <default_init>:
ffffffffc0201252:	00090797          	auipc	a5,0x90
ffffffffc0201256:	55678793          	addi	a5,a5,1366 # ffffffffc02917a8 <free_area>
ffffffffc020125a:	e79c                	sd	a5,8(a5)
ffffffffc020125c:	e39c                	sd	a5,0(a5)
ffffffffc020125e:	0007a823          	sw	zero,16(a5)
ffffffffc0201262:	8082                	ret

ffffffffc0201264 <default_nr_free_pages>:
ffffffffc0201264:	00090517          	auipc	a0,0x90
ffffffffc0201268:	55456503          	lwu	a0,1364(a0) # ffffffffc02917b8 <free_area+0x10>
ffffffffc020126c:	8082                	ret

ffffffffc020126e <default_check>:
ffffffffc020126e:	711d                	addi	sp,sp,-96
ffffffffc0201270:	e0ca                	sd	s2,64(sp)
ffffffffc0201272:	00090917          	auipc	s2,0x90
ffffffffc0201276:	53690913          	addi	s2,s2,1334 # ffffffffc02917a8 <free_area>
ffffffffc020127a:	00893783          	ld	a5,8(s2)
ffffffffc020127e:	ec86                	sd	ra,88(sp)
ffffffffc0201280:	e8a2                	sd	s0,80(sp)
ffffffffc0201282:	e4a6                	sd	s1,72(sp)
ffffffffc0201284:	fc4e                	sd	s3,56(sp)
ffffffffc0201286:	f852                	sd	s4,48(sp)
ffffffffc0201288:	f456                	sd	s5,40(sp)
ffffffffc020128a:	f05a                	sd	s6,32(sp)
ffffffffc020128c:	ec5e                	sd	s7,24(sp)
ffffffffc020128e:	e862                	sd	s8,16(sp)
ffffffffc0201290:	e466                	sd	s9,8(sp)
ffffffffc0201292:	2f278363          	beq	a5,s2,ffffffffc0201578 <default_check+0x30a>
ffffffffc0201296:	4401                	li	s0,0
ffffffffc0201298:	4481                	li	s1,0
ffffffffc020129a:	ff07b703          	ld	a4,-16(a5)
ffffffffc020129e:	8b09                	andi	a4,a4,2
ffffffffc02012a0:	2e070063          	beqz	a4,ffffffffc0201580 <default_check+0x312>
ffffffffc02012a4:	ff87a703          	lw	a4,-8(a5)
ffffffffc02012a8:	679c                	ld	a5,8(a5)
ffffffffc02012aa:	2485                	addiw	s1,s1,1
ffffffffc02012ac:	9c39                	addw	s0,s0,a4
ffffffffc02012ae:	ff2796e3          	bne	a5,s2,ffffffffc020129a <default_check+0x2c>
ffffffffc02012b2:	89a2                	mv	s3,s0
ffffffffc02012b4:	743000ef          	jal	ffffffffc02021f6 <nr_free_pages>
ffffffffc02012b8:	73351463          	bne	a0,s3,ffffffffc02019e0 <default_check+0x772>
ffffffffc02012bc:	4505                	li	a0,1
ffffffffc02012be:	6c7000ef          	jal	ffffffffc0202184 <alloc_pages>
ffffffffc02012c2:	8a2a                	mv	s4,a0
ffffffffc02012c4:	44050e63          	beqz	a0,ffffffffc0201720 <default_check+0x4b2>
ffffffffc02012c8:	4505                	li	a0,1
ffffffffc02012ca:	6bb000ef          	jal	ffffffffc0202184 <alloc_pages>
ffffffffc02012ce:	89aa                	mv	s3,a0
ffffffffc02012d0:	72050863          	beqz	a0,ffffffffc0201a00 <default_check+0x792>
ffffffffc02012d4:	4505                	li	a0,1
ffffffffc02012d6:	6af000ef          	jal	ffffffffc0202184 <alloc_pages>
ffffffffc02012da:	8aaa                	mv	s5,a0
ffffffffc02012dc:	4c050263          	beqz	a0,ffffffffc02017a0 <default_check+0x532>
ffffffffc02012e0:	40a987b3          	sub	a5,s3,a0
ffffffffc02012e4:	40aa0733          	sub	a4,s4,a0
ffffffffc02012e8:	0017b793          	seqz	a5,a5
ffffffffc02012ec:	00173713          	seqz	a4,a4
ffffffffc02012f0:	8fd9                	or	a5,a5,a4
ffffffffc02012f2:	30079763          	bnez	a5,ffffffffc0201600 <default_check+0x392>
ffffffffc02012f6:	313a0563          	beq	s4,s3,ffffffffc0201600 <default_check+0x392>
ffffffffc02012fa:	000a2783          	lw	a5,0(s4)
ffffffffc02012fe:	2a079163          	bnez	a5,ffffffffc02015a0 <default_check+0x332>
ffffffffc0201302:	0009a783          	lw	a5,0(s3)
ffffffffc0201306:	28079d63          	bnez	a5,ffffffffc02015a0 <default_check+0x332>
ffffffffc020130a:	411c                	lw	a5,0(a0)
ffffffffc020130c:	28079a63          	bnez	a5,ffffffffc02015a0 <default_check+0x332>
ffffffffc0201310:	00095797          	auipc	a5,0x95
ffffffffc0201314:	5a87b783          	ld	a5,1448(a5) # ffffffffc02968b8 <pages>
ffffffffc0201318:	0000f617          	auipc	a2,0xf
ffffffffc020131c:	84063603          	ld	a2,-1984(a2) # ffffffffc020fb58 <nbase>
ffffffffc0201320:	00095697          	auipc	a3,0x95
ffffffffc0201324:	5906b683          	ld	a3,1424(a3) # ffffffffc02968b0 <npage>
ffffffffc0201328:	40fa0733          	sub	a4,s4,a5
ffffffffc020132c:	8719                	srai	a4,a4,0x6
ffffffffc020132e:	9732                	add	a4,a4,a2
ffffffffc0201330:	0732                	slli	a4,a4,0xc
ffffffffc0201332:	06b2                	slli	a3,a3,0xc
ffffffffc0201334:	2ad77663          	bgeu	a4,a3,ffffffffc02015e0 <default_check+0x372>
ffffffffc0201338:	40f98733          	sub	a4,s3,a5
ffffffffc020133c:	8719                	srai	a4,a4,0x6
ffffffffc020133e:	9732                	add	a4,a4,a2
ffffffffc0201340:	0732                	slli	a4,a4,0xc
ffffffffc0201342:	4cd77f63          	bgeu	a4,a3,ffffffffc0201820 <default_check+0x5b2>
ffffffffc0201346:	40f507b3          	sub	a5,a0,a5
ffffffffc020134a:	8799                	srai	a5,a5,0x6
ffffffffc020134c:	97b2                	add	a5,a5,a2
ffffffffc020134e:	07b2                	slli	a5,a5,0xc
ffffffffc0201350:	32d7f863          	bgeu	a5,a3,ffffffffc0201680 <default_check+0x412>
ffffffffc0201354:	4505                	li	a0,1
ffffffffc0201356:	00093c03          	ld	s8,0(s2)
ffffffffc020135a:	00893b83          	ld	s7,8(s2)
ffffffffc020135e:	00090b17          	auipc	s6,0x90
ffffffffc0201362:	45ab2b03          	lw	s6,1114(s6) # ffffffffc02917b8 <free_area+0x10>
ffffffffc0201366:	01293023          	sd	s2,0(s2)
ffffffffc020136a:	01293423          	sd	s2,8(s2)
ffffffffc020136e:	00090797          	auipc	a5,0x90
ffffffffc0201372:	4407a523          	sw	zero,1098(a5) # ffffffffc02917b8 <free_area+0x10>
ffffffffc0201376:	60f000ef          	jal	ffffffffc0202184 <alloc_pages>
ffffffffc020137a:	2e051363          	bnez	a0,ffffffffc0201660 <default_check+0x3f2>
ffffffffc020137e:	8552                	mv	a0,s4
ffffffffc0201380:	4585                	li	a1,1
ffffffffc0201382:	63d000ef          	jal	ffffffffc02021be <free_pages>
ffffffffc0201386:	854e                	mv	a0,s3
ffffffffc0201388:	4585                	li	a1,1
ffffffffc020138a:	635000ef          	jal	ffffffffc02021be <free_pages>
ffffffffc020138e:	8556                	mv	a0,s5
ffffffffc0201390:	4585                	li	a1,1
ffffffffc0201392:	62d000ef          	jal	ffffffffc02021be <free_pages>
ffffffffc0201396:	00090717          	auipc	a4,0x90
ffffffffc020139a:	42272703          	lw	a4,1058(a4) # ffffffffc02917b8 <free_area+0x10>
ffffffffc020139e:	478d                	li	a5,3
ffffffffc02013a0:	2af71063          	bne	a4,a5,ffffffffc0201640 <default_check+0x3d2>
ffffffffc02013a4:	4505                	li	a0,1
ffffffffc02013a6:	5df000ef          	jal	ffffffffc0202184 <alloc_pages>
ffffffffc02013aa:	89aa                	mv	s3,a0
ffffffffc02013ac:	26050a63          	beqz	a0,ffffffffc0201620 <default_check+0x3b2>
ffffffffc02013b0:	4505                	li	a0,1
ffffffffc02013b2:	5d3000ef          	jal	ffffffffc0202184 <alloc_pages>
ffffffffc02013b6:	8aaa                	mv	s5,a0
ffffffffc02013b8:	3c050463          	beqz	a0,ffffffffc0201780 <default_check+0x512>
ffffffffc02013bc:	4505                	li	a0,1
ffffffffc02013be:	5c7000ef          	jal	ffffffffc0202184 <alloc_pages>
ffffffffc02013c2:	8a2a                	mv	s4,a0
ffffffffc02013c4:	38050e63          	beqz	a0,ffffffffc0201760 <default_check+0x4f2>
ffffffffc02013c8:	4505                	li	a0,1
ffffffffc02013ca:	5bb000ef          	jal	ffffffffc0202184 <alloc_pages>
ffffffffc02013ce:	36051963          	bnez	a0,ffffffffc0201740 <default_check+0x4d2>
ffffffffc02013d2:	4585                	li	a1,1
ffffffffc02013d4:	854e                	mv	a0,s3
ffffffffc02013d6:	5e9000ef          	jal	ffffffffc02021be <free_pages>
ffffffffc02013da:	00893783          	ld	a5,8(s2)
ffffffffc02013de:	1f278163          	beq	a5,s2,ffffffffc02015c0 <default_check+0x352>
ffffffffc02013e2:	4505                	li	a0,1
ffffffffc02013e4:	5a1000ef          	jal	ffffffffc0202184 <alloc_pages>
ffffffffc02013e8:	8caa                	mv	s9,a0
ffffffffc02013ea:	30a99b63          	bne	s3,a0,ffffffffc0201700 <default_check+0x492>
ffffffffc02013ee:	4505                	li	a0,1
ffffffffc02013f0:	595000ef          	jal	ffffffffc0202184 <alloc_pages>
ffffffffc02013f4:	2e051663          	bnez	a0,ffffffffc02016e0 <default_check+0x472>
ffffffffc02013f8:	00090797          	auipc	a5,0x90
ffffffffc02013fc:	3c07a783          	lw	a5,960(a5) # ffffffffc02917b8 <free_area+0x10>
ffffffffc0201400:	2c079063          	bnez	a5,ffffffffc02016c0 <default_check+0x452>
ffffffffc0201404:	8566                	mv	a0,s9
ffffffffc0201406:	4585                	li	a1,1
ffffffffc0201408:	01893023          	sd	s8,0(s2)
ffffffffc020140c:	01793423          	sd	s7,8(s2)
ffffffffc0201410:	01692823          	sw	s6,16(s2)
ffffffffc0201414:	5ab000ef          	jal	ffffffffc02021be <free_pages>
ffffffffc0201418:	8556                	mv	a0,s5
ffffffffc020141a:	4585                	li	a1,1
ffffffffc020141c:	5a3000ef          	jal	ffffffffc02021be <free_pages>
ffffffffc0201420:	8552                	mv	a0,s4
ffffffffc0201422:	4585                	li	a1,1
ffffffffc0201424:	59b000ef          	jal	ffffffffc02021be <free_pages>
ffffffffc0201428:	4515                	li	a0,5
ffffffffc020142a:	55b000ef          	jal	ffffffffc0202184 <alloc_pages>
ffffffffc020142e:	89aa                	mv	s3,a0
ffffffffc0201430:	26050863          	beqz	a0,ffffffffc02016a0 <default_check+0x432>
ffffffffc0201434:	651c                	ld	a5,8(a0)
ffffffffc0201436:	8b89                	andi	a5,a5,2
ffffffffc0201438:	54079463          	bnez	a5,ffffffffc0201980 <default_check+0x712>
ffffffffc020143c:	4505                	li	a0,1
ffffffffc020143e:	00093b83          	ld	s7,0(s2)
ffffffffc0201442:	00893b03          	ld	s6,8(s2)
ffffffffc0201446:	01293023          	sd	s2,0(s2)
ffffffffc020144a:	01293423          	sd	s2,8(s2)
ffffffffc020144e:	537000ef          	jal	ffffffffc0202184 <alloc_pages>
ffffffffc0201452:	50051763          	bnez	a0,ffffffffc0201960 <default_check+0x6f2>
ffffffffc0201456:	08098a13          	addi	s4,s3,128
ffffffffc020145a:	8552                	mv	a0,s4
ffffffffc020145c:	458d                	li	a1,3
ffffffffc020145e:	00090c17          	auipc	s8,0x90
ffffffffc0201462:	35ac2c03          	lw	s8,858(s8) # ffffffffc02917b8 <free_area+0x10>
ffffffffc0201466:	00090797          	auipc	a5,0x90
ffffffffc020146a:	3407a923          	sw	zero,850(a5) # ffffffffc02917b8 <free_area+0x10>
ffffffffc020146e:	551000ef          	jal	ffffffffc02021be <free_pages>
ffffffffc0201472:	4511                	li	a0,4
ffffffffc0201474:	511000ef          	jal	ffffffffc0202184 <alloc_pages>
ffffffffc0201478:	4c051463          	bnez	a0,ffffffffc0201940 <default_check+0x6d2>
ffffffffc020147c:	0889b783          	ld	a5,136(s3)
ffffffffc0201480:	8b89                	andi	a5,a5,2
ffffffffc0201482:	48078f63          	beqz	a5,ffffffffc0201920 <default_check+0x6b2>
ffffffffc0201486:	0909a503          	lw	a0,144(s3)
ffffffffc020148a:	478d                	li	a5,3
ffffffffc020148c:	48f51a63          	bne	a0,a5,ffffffffc0201920 <default_check+0x6b2>
ffffffffc0201490:	4f5000ef          	jal	ffffffffc0202184 <alloc_pages>
ffffffffc0201494:	8aaa                	mv	s5,a0
ffffffffc0201496:	46050563          	beqz	a0,ffffffffc0201900 <default_check+0x692>
ffffffffc020149a:	4505                	li	a0,1
ffffffffc020149c:	4e9000ef          	jal	ffffffffc0202184 <alloc_pages>
ffffffffc02014a0:	44051063          	bnez	a0,ffffffffc02018e0 <default_check+0x672>
ffffffffc02014a4:	415a1e63          	bne	s4,s5,ffffffffc02018c0 <default_check+0x652>
ffffffffc02014a8:	4585                	li	a1,1
ffffffffc02014aa:	854e                	mv	a0,s3
ffffffffc02014ac:	513000ef          	jal	ffffffffc02021be <free_pages>
ffffffffc02014b0:	8552                	mv	a0,s4
ffffffffc02014b2:	458d                	li	a1,3
ffffffffc02014b4:	50b000ef          	jal	ffffffffc02021be <free_pages>
ffffffffc02014b8:	0089b783          	ld	a5,8(s3)
ffffffffc02014bc:	8b89                	andi	a5,a5,2
ffffffffc02014be:	3e078163          	beqz	a5,ffffffffc02018a0 <default_check+0x632>
ffffffffc02014c2:	0109aa83          	lw	s5,16(s3)
ffffffffc02014c6:	4785                	li	a5,1
ffffffffc02014c8:	3cfa9c63          	bne	s5,a5,ffffffffc02018a0 <default_check+0x632>
ffffffffc02014cc:	008a3783          	ld	a5,8(s4)
ffffffffc02014d0:	8b89                	andi	a5,a5,2
ffffffffc02014d2:	3a078763          	beqz	a5,ffffffffc0201880 <default_check+0x612>
ffffffffc02014d6:	010a2703          	lw	a4,16(s4)
ffffffffc02014da:	478d                	li	a5,3
ffffffffc02014dc:	3af71263          	bne	a4,a5,ffffffffc0201880 <default_check+0x612>
ffffffffc02014e0:	8556                	mv	a0,s5
ffffffffc02014e2:	4a3000ef          	jal	ffffffffc0202184 <alloc_pages>
ffffffffc02014e6:	36a99d63          	bne	s3,a0,ffffffffc0201860 <default_check+0x5f2>
ffffffffc02014ea:	85d6                	mv	a1,s5
ffffffffc02014ec:	4d3000ef          	jal	ffffffffc02021be <free_pages>
ffffffffc02014f0:	4509                	li	a0,2
ffffffffc02014f2:	493000ef          	jal	ffffffffc0202184 <alloc_pages>
ffffffffc02014f6:	34aa1563          	bne	s4,a0,ffffffffc0201840 <default_check+0x5d2>
ffffffffc02014fa:	4589                	li	a1,2
ffffffffc02014fc:	4c3000ef          	jal	ffffffffc02021be <free_pages>
ffffffffc0201500:	04098513          	addi	a0,s3,64
ffffffffc0201504:	85d6                	mv	a1,s5
ffffffffc0201506:	4b9000ef          	jal	ffffffffc02021be <free_pages>
ffffffffc020150a:	4515                	li	a0,5
ffffffffc020150c:	479000ef          	jal	ffffffffc0202184 <alloc_pages>
ffffffffc0201510:	89aa                	mv	s3,a0
ffffffffc0201512:	48050763          	beqz	a0,ffffffffc02019a0 <default_check+0x732>
ffffffffc0201516:	8556                	mv	a0,s5
ffffffffc0201518:	46d000ef          	jal	ffffffffc0202184 <alloc_pages>
ffffffffc020151c:	2e051263          	bnez	a0,ffffffffc0201800 <default_check+0x592>
ffffffffc0201520:	00090797          	auipc	a5,0x90
ffffffffc0201524:	2987a783          	lw	a5,664(a5) # ffffffffc02917b8 <free_area+0x10>
ffffffffc0201528:	2a079c63          	bnez	a5,ffffffffc02017e0 <default_check+0x572>
ffffffffc020152c:	854e                	mv	a0,s3
ffffffffc020152e:	4595                	li	a1,5
ffffffffc0201530:	01892823          	sw	s8,16(s2)
ffffffffc0201534:	01793023          	sd	s7,0(s2)
ffffffffc0201538:	01693423          	sd	s6,8(s2)
ffffffffc020153c:	483000ef          	jal	ffffffffc02021be <free_pages>
ffffffffc0201540:	00893783          	ld	a5,8(s2)
ffffffffc0201544:	01278963          	beq	a5,s2,ffffffffc0201556 <default_check+0x2e8>
ffffffffc0201548:	ff87a703          	lw	a4,-8(a5)
ffffffffc020154c:	679c                	ld	a5,8(a5)
ffffffffc020154e:	34fd                	addiw	s1,s1,-1
ffffffffc0201550:	9c19                	subw	s0,s0,a4
ffffffffc0201552:	ff279be3          	bne	a5,s2,ffffffffc0201548 <default_check+0x2da>
ffffffffc0201556:	26049563          	bnez	s1,ffffffffc02017c0 <default_check+0x552>
ffffffffc020155a:	46041363          	bnez	s0,ffffffffc02019c0 <default_check+0x752>
ffffffffc020155e:	60e6                	ld	ra,88(sp)
ffffffffc0201560:	6446                	ld	s0,80(sp)
ffffffffc0201562:	64a6                	ld	s1,72(sp)
ffffffffc0201564:	6906                	ld	s2,64(sp)
ffffffffc0201566:	79e2                	ld	s3,56(sp)
ffffffffc0201568:	7a42                	ld	s4,48(sp)
ffffffffc020156a:	7aa2                	ld	s5,40(sp)
ffffffffc020156c:	7b02                	ld	s6,32(sp)
ffffffffc020156e:	6be2                	ld	s7,24(sp)
ffffffffc0201570:	6c42                	ld	s8,16(sp)
ffffffffc0201572:	6ca2                	ld	s9,8(sp)
ffffffffc0201574:	6125                	addi	sp,sp,96
ffffffffc0201576:	8082                	ret
ffffffffc0201578:	4981                	li	s3,0
ffffffffc020157a:	4401                	li	s0,0
ffffffffc020157c:	4481                	li	s1,0
ffffffffc020157e:	bb1d                	j	ffffffffc02012b4 <default_check+0x46>
ffffffffc0201580:	0000b697          	auipc	a3,0xb
ffffffffc0201584:	de868693          	addi	a3,a3,-536 # ffffffffc020c368 <etext+0xb08>
ffffffffc0201588:	0000a617          	auipc	a2,0xa
ffffffffc020158c:	71060613          	addi	a2,a2,1808 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201590:	0ef00593          	li	a1,239
ffffffffc0201594:	0000b517          	auipc	a0,0xb
ffffffffc0201598:	de450513          	addi	a0,a0,-540 # ffffffffc020c378 <etext+0xb18>
ffffffffc020159c:	eaffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02015a0:	0000b697          	auipc	a3,0xb
ffffffffc02015a4:	e9868693          	addi	a3,a3,-360 # ffffffffc020c438 <etext+0xbd8>
ffffffffc02015a8:	0000a617          	auipc	a2,0xa
ffffffffc02015ac:	6f060613          	addi	a2,a2,1776 # ffffffffc020bc98 <etext+0x438>
ffffffffc02015b0:	0bd00593          	li	a1,189
ffffffffc02015b4:	0000b517          	auipc	a0,0xb
ffffffffc02015b8:	dc450513          	addi	a0,a0,-572 # ffffffffc020c378 <etext+0xb18>
ffffffffc02015bc:	e8ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02015c0:	0000b697          	auipc	a3,0xb
ffffffffc02015c4:	f4068693          	addi	a3,a3,-192 # ffffffffc020c500 <etext+0xca0>
ffffffffc02015c8:	0000a617          	auipc	a2,0xa
ffffffffc02015cc:	6d060613          	addi	a2,a2,1744 # ffffffffc020bc98 <etext+0x438>
ffffffffc02015d0:	0d800593          	li	a1,216
ffffffffc02015d4:	0000b517          	auipc	a0,0xb
ffffffffc02015d8:	da450513          	addi	a0,a0,-604 # ffffffffc020c378 <etext+0xb18>
ffffffffc02015dc:	e6ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02015e0:	0000b697          	auipc	a3,0xb
ffffffffc02015e4:	e9868693          	addi	a3,a3,-360 # ffffffffc020c478 <etext+0xc18>
ffffffffc02015e8:	0000a617          	auipc	a2,0xa
ffffffffc02015ec:	6b060613          	addi	a2,a2,1712 # ffffffffc020bc98 <etext+0x438>
ffffffffc02015f0:	0bf00593          	li	a1,191
ffffffffc02015f4:	0000b517          	auipc	a0,0xb
ffffffffc02015f8:	d8450513          	addi	a0,a0,-636 # ffffffffc020c378 <etext+0xb18>
ffffffffc02015fc:	e4ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201600:	0000b697          	auipc	a3,0xb
ffffffffc0201604:	e1068693          	addi	a3,a3,-496 # ffffffffc020c410 <etext+0xbb0>
ffffffffc0201608:	0000a617          	auipc	a2,0xa
ffffffffc020160c:	69060613          	addi	a2,a2,1680 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201610:	0bc00593          	li	a1,188
ffffffffc0201614:	0000b517          	auipc	a0,0xb
ffffffffc0201618:	d6450513          	addi	a0,a0,-668 # ffffffffc020c378 <etext+0xb18>
ffffffffc020161c:	e2ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201620:	0000b697          	auipc	a3,0xb
ffffffffc0201624:	d9068693          	addi	a3,a3,-624 # ffffffffc020c3b0 <etext+0xb50>
ffffffffc0201628:	0000a617          	auipc	a2,0xa
ffffffffc020162c:	67060613          	addi	a2,a2,1648 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201630:	0d100593          	li	a1,209
ffffffffc0201634:	0000b517          	auipc	a0,0xb
ffffffffc0201638:	d4450513          	addi	a0,a0,-700 # ffffffffc020c378 <etext+0xb18>
ffffffffc020163c:	e0ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201640:	0000b697          	auipc	a3,0xb
ffffffffc0201644:	eb068693          	addi	a3,a3,-336 # ffffffffc020c4f0 <etext+0xc90>
ffffffffc0201648:	0000a617          	auipc	a2,0xa
ffffffffc020164c:	65060613          	addi	a2,a2,1616 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201650:	0cf00593          	li	a1,207
ffffffffc0201654:	0000b517          	auipc	a0,0xb
ffffffffc0201658:	d2450513          	addi	a0,a0,-732 # ffffffffc020c378 <etext+0xb18>
ffffffffc020165c:	deffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201660:	0000b697          	auipc	a3,0xb
ffffffffc0201664:	e7868693          	addi	a3,a3,-392 # ffffffffc020c4d8 <etext+0xc78>
ffffffffc0201668:	0000a617          	auipc	a2,0xa
ffffffffc020166c:	63060613          	addi	a2,a2,1584 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201670:	0ca00593          	li	a1,202
ffffffffc0201674:	0000b517          	auipc	a0,0xb
ffffffffc0201678:	d0450513          	addi	a0,a0,-764 # ffffffffc020c378 <etext+0xb18>
ffffffffc020167c:	dcffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201680:	0000b697          	auipc	a3,0xb
ffffffffc0201684:	e3868693          	addi	a3,a3,-456 # ffffffffc020c4b8 <etext+0xc58>
ffffffffc0201688:	0000a617          	auipc	a2,0xa
ffffffffc020168c:	61060613          	addi	a2,a2,1552 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201690:	0c100593          	li	a1,193
ffffffffc0201694:	0000b517          	auipc	a0,0xb
ffffffffc0201698:	ce450513          	addi	a0,a0,-796 # ffffffffc020c378 <etext+0xb18>
ffffffffc020169c:	daffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02016a0:	0000b697          	auipc	a3,0xb
ffffffffc02016a4:	ea868693          	addi	a3,a3,-344 # ffffffffc020c548 <etext+0xce8>
ffffffffc02016a8:	0000a617          	auipc	a2,0xa
ffffffffc02016ac:	5f060613          	addi	a2,a2,1520 # ffffffffc020bc98 <etext+0x438>
ffffffffc02016b0:	0f700593          	li	a1,247
ffffffffc02016b4:	0000b517          	auipc	a0,0xb
ffffffffc02016b8:	cc450513          	addi	a0,a0,-828 # ffffffffc020c378 <etext+0xb18>
ffffffffc02016bc:	d8ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02016c0:	0000b697          	auipc	a3,0xb
ffffffffc02016c4:	e7868693          	addi	a3,a3,-392 # ffffffffc020c538 <etext+0xcd8>
ffffffffc02016c8:	0000a617          	auipc	a2,0xa
ffffffffc02016cc:	5d060613          	addi	a2,a2,1488 # ffffffffc020bc98 <etext+0x438>
ffffffffc02016d0:	0de00593          	li	a1,222
ffffffffc02016d4:	0000b517          	auipc	a0,0xb
ffffffffc02016d8:	ca450513          	addi	a0,a0,-860 # ffffffffc020c378 <etext+0xb18>
ffffffffc02016dc:	d6ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02016e0:	0000b697          	auipc	a3,0xb
ffffffffc02016e4:	df868693          	addi	a3,a3,-520 # ffffffffc020c4d8 <etext+0xc78>
ffffffffc02016e8:	0000a617          	auipc	a2,0xa
ffffffffc02016ec:	5b060613          	addi	a2,a2,1456 # ffffffffc020bc98 <etext+0x438>
ffffffffc02016f0:	0dc00593          	li	a1,220
ffffffffc02016f4:	0000b517          	auipc	a0,0xb
ffffffffc02016f8:	c8450513          	addi	a0,a0,-892 # ffffffffc020c378 <etext+0xb18>
ffffffffc02016fc:	d4ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201700:	0000b697          	auipc	a3,0xb
ffffffffc0201704:	e1868693          	addi	a3,a3,-488 # ffffffffc020c518 <etext+0xcb8>
ffffffffc0201708:	0000a617          	auipc	a2,0xa
ffffffffc020170c:	59060613          	addi	a2,a2,1424 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201710:	0db00593          	li	a1,219
ffffffffc0201714:	0000b517          	auipc	a0,0xb
ffffffffc0201718:	c6450513          	addi	a0,a0,-924 # ffffffffc020c378 <etext+0xb18>
ffffffffc020171c:	d2ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201720:	0000b697          	auipc	a3,0xb
ffffffffc0201724:	c9068693          	addi	a3,a3,-880 # ffffffffc020c3b0 <etext+0xb50>
ffffffffc0201728:	0000a617          	auipc	a2,0xa
ffffffffc020172c:	57060613          	addi	a2,a2,1392 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201730:	0b800593          	li	a1,184
ffffffffc0201734:	0000b517          	auipc	a0,0xb
ffffffffc0201738:	c4450513          	addi	a0,a0,-956 # ffffffffc020c378 <etext+0xb18>
ffffffffc020173c:	d0ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201740:	0000b697          	auipc	a3,0xb
ffffffffc0201744:	d9868693          	addi	a3,a3,-616 # ffffffffc020c4d8 <etext+0xc78>
ffffffffc0201748:	0000a617          	auipc	a2,0xa
ffffffffc020174c:	55060613          	addi	a2,a2,1360 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201750:	0d500593          	li	a1,213
ffffffffc0201754:	0000b517          	auipc	a0,0xb
ffffffffc0201758:	c2450513          	addi	a0,a0,-988 # ffffffffc020c378 <etext+0xb18>
ffffffffc020175c:	ceffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201760:	0000b697          	auipc	a3,0xb
ffffffffc0201764:	c9068693          	addi	a3,a3,-880 # ffffffffc020c3f0 <etext+0xb90>
ffffffffc0201768:	0000a617          	auipc	a2,0xa
ffffffffc020176c:	53060613          	addi	a2,a2,1328 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201770:	0d300593          	li	a1,211
ffffffffc0201774:	0000b517          	auipc	a0,0xb
ffffffffc0201778:	c0450513          	addi	a0,a0,-1020 # ffffffffc020c378 <etext+0xb18>
ffffffffc020177c:	ccffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201780:	0000b697          	auipc	a3,0xb
ffffffffc0201784:	c5068693          	addi	a3,a3,-944 # ffffffffc020c3d0 <etext+0xb70>
ffffffffc0201788:	0000a617          	auipc	a2,0xa
ffffffffc020178c:	51060613          	addi	a2,a2,1296 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201790:	0d200593          	li	a1,210
ffffffffc0201794:	0000b517          	auipc	a0,0xb
ffffffffc0201798:	be450513          	addi	a0,a0,-1052 # ffffffffc020c378 <etext+0xb18>
ffffffffc020179c:	caffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02017a0:	0000b697          	auipc	a3,0xb
ffffffffc02017a4:	c5068693          	addi	a3,a3,-944 # ffffffffc020c3f0 <etext+0xb90>
ffffffffc02017a8:	0000a617          	auipc	a2,0xa
ffffffffc02017ac:	4f060613          	addi	a2,a2,1264 # ffffffffc020bc98 <etext+0x438>
ffffffffc02017b0:	0ba00593          	li	a1,186
ffffffffc02017b4:	0000b517          	auipc	a0,0xb
ffffffffc02017b8:	bc450513          	addi	a0,a0,-1084 # ffffffffc020c378 <etext+0xb18>
ffffffffc02017bc:	c8ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02017c0:	0000b697          	auipc	a3,0xb
ffffffffc02017c4:	ed868693          	addi	a3,a3,-296 # ffffffffc020c698 <etext+0xe38>
ffffffffc02017c8:	0000a617          	auipc	a2,0xa
ffffffffc02017cc:	4d060613          	addi	a2,a2,1232 # ffffffffc020bc98 <etext+0x438>
ffffffffc02017d0:	12400593          	li	a1,292
ffffffffc02017d4:	0000b517          	auipc	a0,0xb
ffffffffc02017d8:	ba450513          	addi	a0,a0,-1116 # ffffffffc020c378 <etext+0xb18>
ffffffffc02017dc:	c6ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02017e0:	0000b697          	auipc	a3,0xb
ffffffffc02017e4:	d5868693          	addi	a3,a3,-680 # ffffffffc020c538 <etext+0xcd8>
ffffffffc02017e8:	0000a617          	auipc	a2,0xa
ffffffffc02017ec:	4b060613          	addi	a2,a2,1200 # ffffffffc020bc98 <etext+0x438>
ffffffffc02017f0:	11900593          	li	a1,281
ffffffffc02017f4:	0000b517          	auipc	a0,0xb
ffffffffc02017f8:	b8450513          	addi	a0,a0,-1148 # ffffffffc020c378 <etext+0xb18>
ffffffffc02017fc:	c4ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201800:	0000b697          	auipc	a3,0xb
ffffffffc0201804:	cd868693          	addi	a3,a3,-808 # ffffffffc020c4d8 <etext+0xc78>
ffffffffc0201808:	0000a617          	auipc	a2,0xa
ffffffffc020180c:	49060613          	addi	a2,a2,1168 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201810:	11700593          	li	a1,279
ffffffffc0201814:	0000b517          	auipc	a0,0xb
ffffffffc0201818:	b6450513          	addi	a0,a0,-1180 # ffffffffc020c378 <etext+0xb18>
ffffffffc020181c:	c2ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201820:	0000b697          	auipc	a3,0xb
ffffffffc0201824:	c7868693          	addi	a3,a3,-904 # ffffffffc020c498 <etext+0xc38>
ffffffffc0201828:	0000a617          	auipc	a2,0xa
ffffffffc020182c:	47060613          	addi	a2,a2,1136 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201830:	0c000593          	li	a1,192
ffffffffc0201834:	0000b517          	auipc	a0,0xb
ffffffffc0201838:	b4450513          	addi	a0,a0,-1212 # ffffffffc020c378 <etext+0xb18>
ffffffffc020183c:	c0ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201840:	0000b697          	auipc	a3,0xb
ffffffffc0201844:	e1868693          	addi	a3,a3,-488 # ffffffffc020c658 <etext+0xdf8>
ffffffffc0201848:	0000a617          	auipc	a2,0xa
ffffffffc020184c:	45060613          	addi	a2,a2,1104 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201850:	11100593          	li	a1,273
ffffffffc0201854:	0000b517          	auipc	a0,0xb
ffffffffc0201858:	b2450513          	addi	a0,a0,-1244 # ffffffffc020c378 <etext+0xb18>
ffffffffc020185c:	beffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201860:	0000b697          	auipc	a3,0xb
ffffffffc0201864:	dd868693          	addi	a3,a3,-552 # ffffffffc020c638 <etext+0xdd8>
ffffffffc0201868:	0000a617          	auipc	a2,0xa
ffffffffc020186c:	43060613          	addi	a2,a2,1072 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201870:	10f00593          	li	a1,271
ffffffffc0201874:	0000b517          	auipc	a0,0xb
ffffffffc0201878:	b0450513          	addi	a0,a0,-1276 # ffffffffc020c378 <etext+0xb18>
ffffffffc020187c:	bcffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201880:	0000b697          	auipc	a3,0xb
ffffffffc0201884:	d9068693          	addi	a3,a3,-624 # ffffffffc020c610 <etext+0xdb0>
ffffffffc0201888:	0000a617          	auipc	a2,0xa
ffffffffc020188c:	41060613          	addi	a2,a2,1040 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201890:	10d00593          	li	a1,269
ffffffffc0201894:	0000b517          	auipc	a0,0xb
ffffffffc0201898:	ae450513          	addi	a0,a0,-1308 # ffffffffc020c378 <etext+0xb18>
ffffffffc020189c:	baffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02018a0:	0000b697          	auipc	a3,0xb
ffffffffc02018a4:	d4868693          	addi	a3,a3,-696 # ffffffffc020c5e8 <etext+0xd88>
ffffffffc02018a8:	0000a617          	auipc	a2,0xa
ffffffffc02018ac:	3f060613          	addi	a2,a2,1008 # ffffffffc020bc98 <etext+0x438>
ffffffffc02018b0:	10c00593          	li	a1,268
ffffffffc02018b4:	0000b517          	auipc	a0,0xb
ffffffffc02018b8:	ac450513          	addi	a0,a0,-1340 # ffffffffc020c378 <etext+0xb18>
ffffffffc02018bc:	b8ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02018c0:	0000b697          	auipc	a3,0xb
ffffffffc02018c4:	d1868693          	addi	a3,a3,-744 # ffffffffc020c5d8 <etext+0xd78>
ffffffffc02018c8:	0000a617          	auipc	a2,0xa
ffffffffc02018cc:	3d060613          	addi	a2,a2,976 # ffffffffc020bc98 <etext+0x438>
ffffffffc02018d0:	10700593          	li	a1,263
ffffffffc02018d4:	0000b517          	auipc	a0,0xb
ffffffffc02018d8:	aa450513          	addi	a0,a0,-1372 # ffffffffc020c378 <etext+0xb18>
ffffffffc02018dc:	b6ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02018e0:	0000b697          	auipc	a3,0xb
ffffffffc02018e4:	bf868693          	addi	a3,a3,-1032 # ffffffffc020c4d8 <etext+0xc78>
ffffffffc02018e8:	0000a617          	auipc	a2,0xa
ffffffffc02018ec:	3b060613          	addi	a2,a2,944 # ffffffffc020bc98 <etext+0x438>
ffffffffc02018f0:	10600593          	li	a1,262
ffffffffc02018f4:	0000b517          	auipc	a0,0xb
ffffffffc02018f8:	a8450513          	addi	a0,a0,-1404 # ffffffffc020c378 <etext+0xb18>
ffffffffc02018fc:	b4ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201900:	0000b697          	auipc	a3,0xb
ffffffffc0201904:	cb868693          	addi	a3,a3,-840 # ffffffffc020c5b8 <etext+0xd58>
ffffffffc0201908:	0000a617          	auipc	a2,0xa
ffffffffc020190c:	39060613          	addi	a2,a2,912 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201910:	10500593          	li	a1,261
ffffffffc0201914:	0000b517          	auipc	a0,0xb
ffffffffc0201918:	a6450513          	addi	a0,a0,-1436 # ffffffffc020c378 <etext+0xb18>
ffffffffc020191c:	b2ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201920:	0000b697          	auipc	a3,0xb
ffffffffc0201924:	c6868693          	addi	a3,a3,-920 # ffffffffc020c588 <etext+0xd28>
ffffffffc0201928:	0000a617          	auipc	a2,0xa
ffffffffc020192c:	37060613          	addi	a2,a2,880 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201930:	10400593          	li	a1,260
ffffffffc0201934:	0000b517          	auipc	a0,0xb
ffffffffc0201938:	a4450513          	addi	a0,a0,-1468 # ffffffffc020c378 <etext+0xb18>
ffffffffc020193c:	b0ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201940:	0000b697          	auipc	a3,0xb
ffffffffc0201944:	c3068693          	addi	a3,a3,-976 # ffffffffc020c570 <etext+0xd10>
ffffffffc0201948:	0000a617          	auipc	a2,0xa
ffffffffc020194c:	35060613          	addi	a2,a2,848 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201950:	10300593          	li	a1,259
ffffffffc0201954:	0000b517          	auipc	a0,0xb
ffffffffc0201958:	a2450513          	addi	a0,a0,-1500 # ffffffffc020c378 <etext+0xb18>
ffffffffc020195c:	aeffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201960:	0000b697          	auipc	a3,0xb
ffffffffc0201964:	b7868693          	addi	a3,a3,-1160 # ffffffffc020c4d8 <etext+0xc78>
ffffffffc0201968:	0000a617          	auipc	a2,0xa
ffffffffc020196c:	33060613          	addi	a2,a2,816 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201970:	0fd00593          	li	a1,253
ffffffffc0201974:	0000b517          	auipc	a0,0xb
ffffffffc0201978:	a0450513          	addi	a0,a0,-1532 # ffffffffc020c378 <etext+0xb18>
ffffffffc020197c:	acffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201980:	0000b697          	auipc	a3,0xb
ffffffffc0201984:	bd868693          	addi	a3,a3,-1064 # ffffffffc020c558 <etext+0xcf8>
ffffffffc0201988:	0000a617          	auipc	a2,0xa
ffffffffc020198c:	31060613          	addi	a2,a2,784 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201990:	0f800593          	li	a1,248
ffffffffc0201994:	0000b517          	auipc	a0,0xb
ffffffffc0201998:	9e450513          	addi	a0,a0,-1564 # ffffffffc020c378 <etext+0xb18>
ffffffffc020199c:	aaffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02019a0:	0000b697          	auipc	a3,0xb
ffffffffc02019a4:	cd868693          	addi	a3,a3,-808 # ffffffffc020c678 <etext+0xe18>
ffffffffc02019a8:	0000a617          	auipc	a2,0xa
ffffffffc02019ac:	2f060613          	addi	a2,a2,752 # ffffffffc020bc98 <etext+0x438>
ffffffffc02019b0:	11600593          	li	a1,278
ffffffffc02019b4:	0000b517          	auipc	a0,0xb
ffffffffc02019b8:	9c450513          	addi	a0,a0,-1596 # ffffffffc020c378 <etext+0xb18>
ffffffffc02019bc:	a8ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02019c0:	0000b697          	auipc	a3,0xb
ffffffffc02019c4:	ce868693          	addi	a3,a3,-792 # ffffffffc020c6a8 <etext+0xe48>
ffffffffc02019c8:	0000a617          	auipc	a2,0xa
ffffffffc02019cc:	2d060613          	addi	a2,a2,720 # ffffffffc020bc98 <etext+0x438>
ffffffffc02019d0:	12500593          	li	a1,293
ffffffffc02019d4:	0000b517          	auipc	a0,0xb
ffffffffc02019d8:	9a450513          	addi	a0,a0,-1628 # ffffffffc020c378 <etext+0xb18>
ffffffffc02019dc:	a6ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02019e0:	0000b697          	auipc	a3,0xb
ffffffffc02019e4:	9b068693          	addi	a3,a3,-1616 # ffffffffc020c390 <etext+0xb30>
ffffffffc02019e8:	0000a617          	auipc	a2,0xa
ffffffffc02019ec:	2b060613          	addi	a2,a2,688 # ffffffffc020bc98 <etext+0x438>
ffffffffc02019f0:	0f200593          	li	a1,242
ffffffffc02019f4:	0000b517          	auipc	a0,0xb
ffffffffc02019f8:	98450513          	addi	a0,a0,-1660 # ffffffffc020c378 <etext+0xb18>
ffffffffc02019fc:	a4ffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201a00:	0000b697          	auipc	a3,0xb
ffffffffc0201a04:	9d068693          	addi	a3,a3,-1584 # ffffffffc020c3d0 <etext+0xb70>
ffffffffc0201a08:	0000a617          	auipc	a2,0xa
ffffffffc0201a0c:	29060613          	addi	a2,a2,656 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201a10:	0b900593          	li	a1,185
ffffffffc0201a14:	0000b517          	auipc	a0,0xb
ffffffffc0201a18:	96450513          	addi	a0,a0,-1692 # ffffffffc020c378 <etext+0xb18>
ffffffffc0201a1c:	a2ffe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201a20 <default_free_pages>:
ffffffffc0201a20:	1141                	addi	sp,sp,-16
ffffffffc0201a22:	e406                	sd	ra,8(sp)
ffffffffc0201a24:	14058663          	beqz	a1,ffffffffc0201b70 <default_free_pages+0x150>
ffffffffc0201a28:	00659713          	slli	a4,a1,0x6
ffffffffc0201a2c:	00e506b3          	add	a3,a0,a4
ffffffffc0201a30:	87aa                	mv	a5,a0
ffffffffc0201a32:	c30d                	beqz	a4,ffffffffc0201a54 <default_free_pages+0x34>
ffffffffc0201a34:	6798                	ld	a4,8(a5)
ffffffffc0201a36:	8b05                	andi	a4,a4,1
ffffffffc0201a38:	10071c63          	bnez	a4,ffffffffc0201b50 <default_free_pages+0x130>
ffffffffc0201a3c:	6798                	ld	a4,8(a5)
ffffffffc0201a3e:	8b09                	andi	a4,a4,2
ffffffffc0201a40:	10071863          	bnez	a4,ffffffffc0201b50 <default_free_pages+0x130>
ffffffffc0201a44:	0007b423          	sd	zero,8(a5)
ffffffffc0201a48:	0007a023          	sw	zero,0(a5)
ffffffffc0201a4c:	04078793          	addi	a5,a5,64
ffffffffc0201a50:	fed792e3          	bne	a5,a3,ffffffffc0201a34 <default_free_pages+0x14>
ffffffffc0201a54:	c90c                	sw	a1,16(a0)
ffffffffc0201a56:	00850893          	addi	a7,a0,8
ffffffffc0201a5a:	4789                	li	a5,2
ffffffffc0201a5c:	40f8b02f          	amoor.d	zero,a5,(a7)
ffffffffc0201a60:	00090717          	auipc	a4,0x90
ffffffffc0201a64:	d5872703          	lw	a4,-680(a4) # ffffffffc02917b8 <free_area+0x10>
ffffffffc0201a68:	00090697          	auipc	a3,0x90
ffffffffc0201a6c:	d4068693          	addi	a3,a3,-704 # ffffffffc02917a8 <free_area>
ffffffffc0201a70:	669c                	ld	a5,8(a3)
ffffffffc0201a72:	9f2d                	addw	a4,a4,a1
ffffffffc0201a74:	ca98                	sw	a4,16(a3)
ffffffffc0201a76:	0ad78163          	beq	a5,a3,ffffffffc0201b18 <default_free_pages+0xf8>
ffffffffc0201a7a:	fe878713          	addi	a4,a5,-24
ffffffffc0201a7e:	4581                	li	a1,0
ffffffffc0201a80:	01850613          	addi	a2,a0,24
ffffffffc0201a84:	00e56a63          	bltu	a0,a4,ffffffffc0201a98 <default_free_pages+0x78>
ffffffffc0201a88:	6798                	ld	a4,8(a5)
ffffffffc0201a8a:	04d70c63          	beq	a4,a3,ffffffffc0201ae2 <default_free_pages+0xc2>
ffffffffc0201a8e:	87ba                	mv	a5,a4
ffffffffc0201a90:	fe878713          	addi	a4,a5,-24
ffffffffc0201a94:	fee57ae3          	bgeu	a0,a4,ffffffffc0201a88 <default_free_pages+0x68>
ffffffffc0201a98:	c199                	beqz	a1,ffffffffc0201a9e <default_free_pages+0x7e>
ffffffffc0201a9a:	0106b023          	sd	a6,0(a3)
ffffffffc0201a9e:	6398                	ld	a4,0(a5)
ffffffffc0201aa0:	e390                	sd	a2,0(a5)
ffffffffc0201aa2:	e710                	sd	a2,8(a4)
ffffffffc0201aa4:	ed18                	sd	a4,24(a0)
ffffffffc0201aa6:	f11c                	sd	a5,32(a0)
ffffffffc0201aa8:	00d70d63          	beq	a4,a3,ffffffffc0201ac2 <default_free_pages+0xa2>
ffffffffc0201aac:	ff872583          	lw	a1,-8(a4)
ffffffffc0201ab0:	fe870613          	addi	a2,a4,-24
ffffffffc0201ab4:	02059813          	slli	a6,a1,0x20
ffffffffc0201ab8:	01a85793          	srli	a5,a6,0x1a
ffffffffc0201abc:	97b2                	add	a5,a5,a2
ffffffffc0201abe:	02f50c63          	beq	a0,a5,ffffffffc0201af6 <default_free_pages+0xd6>
ffffffffc0201ac2:	711c                	ld	a5,32(a0)
ffffffffc0201ac4:	00d78c63          	beq	a5,a3,ffffffffc0201adc <default_free_pages+0xbc>
ffffffffc0201ac8:	4910                	lw	a2,16(a0)
ffffffffc0201aca:	fe878693          	addi	a3,a5,-24
ffffffffc0201ace:	02061593          	slli	a1,a2,0x20
ffffffffc0201ad2:	01a5d713          	srli	a4,a1,0x1a
ffffffffc0201ad6:	972a                	add	a4,a4,a0
ffffffffc0201ad8:	04e68c63          	beq	a3,a4,ffffffffc0201b30 <default_free_pages+0x110>
ffffffffc0201adc:	60a2                	ld	ra,8(sp)
ffffffffc0201ade:	0141                	addi	sp,sp,16
ffffffffc0201ae0:	8082                	ret
ffffffffc0201ae2:	e790                	sd	a2,8(a5)
ffffffffc0201ae4:	f114                	sd	a3,32(a0)
ffffffffc0201ae6:	6798                	ld	a4,8(a5)
ffffffffc0201ae8:	ed1c                	sd	a5,24(a0)
ffffffffc0201aea:	8832                	mv	a6,a2
ffffffffc0201aec:	02d70f63          	beq	a4,a3,ffffffffc0201b2a <default_free_pages+0x10a>
ffffffffc0201af0:	4585                	li	a1,1
ffffffffc0201af2:	87ba                	mv	a5,a4
ffffffffc0201af4:	bf71                	j	ffffffffc0201a90 <default_free_pages+0x70>
ffffffffc0201af6:	491c                	lw	a5,16(a0)
ffffffffc0201af8:	5875                	li	a6,-3
ffffffffc0201afa:	9fad                	addw	a5,a5,a1
ffffffffc0201afc:	fef72c23          	sw	a5,-8(a4)
ffffffffc0201b00:	6108b02f          	amoand.d	zero,a6,(a7)
ffffffffc0201b04:	01853803          	ld	a6,24(a0)
ffffffffc0201b08:	710c                	ld	a1,32(a0)
ffffffffc0201b0a:	8532                	mv	a0,a2
ffffffffc0201b0c:	00b83423          	sd	a1,8(a6)
ffffffffc0201b10:	671c                	ld	a5,8(a4)
ffffffffc0201b12:	0105b023          	sd	a6,0(a1)
ffffffffc0201b16:	b77d                	j	ffffffffc0201ac4 <default_free_pages+0xa4>
ffffffffc0201b18:	60a2                	ld	ra,8(sp)
ffffffffc0201b1a:	01850713          	addi	a4,a0,24
ffffffffc0201b1e:	f11c                	sd	a5,32(a0)
ffffffffc0201b20:	ed1c                	sd	a5,24(a0)
ffffffffc0201b22:	e398                	sd	a4,0(a5)
ffffffffc0201b24:	e798                	sd	a4,8(a5)
ffffffffc0201b26:	0141                	addi	sp,sp,16
ffffffffc0201b28:	8082                	ret
ffffffffc0201b2a:	e290                	sd	a2,0(a3)
ffffffffc0201b2c:	873e                	mv	a4,a5
ffffffffc0201b2e:	bfad                	j	ffffffffc0201aa8 <default_free_pages+0x88>
ffffffffc0201b30:	ff87a703          	lw	a4,-8(a5)
ffffffffc0201b34:	56f5                	li	a3,-3
ffffffffc0201b36:	9f31                	addw	a4,a4,a2
ffffffffc0201b38:	c918                	sw	a4,16(a0)
ffffffffc0201b3a:	ff078713          	addi	a4,a5,-16
ffffffffc0201b3e:	60d7302f          	amoand.d	zero,a3,(a4)
ffffffffc0201b42:	6398                	ld	a4,0(a5)
ffffffffc0201b44:	679c                	ld	a5,8(a5)
ffffffffc0201b46:	60a2                	ld	ra,8(sp)
ffffffffc0201b48:	e71c                	sd	a5,8(a4)
ffffffffc0201b4a:	e398                	sd	a4,0(a5)
ffffffffc0201b4c:	0141                	addi	sp,sp,16
ffffffffc0201b4e:	8082                	ret
ffffffffc0201b50:	0000b697          	auipc	a3,0xb
ffffffffc0201b54:	b7068693          	addi	a3,a3,-1168 # ffffffffc020c6c0 <etext+0xe60>
ffffffffc0201b58:	0000a617          	auipc	a2,0xa
ffffffffc0201b5c:	14060613          	addi	a2,a2,320 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201b60:	08200593          	li	a1,130
ffffffffc0201b64:	0000b517          	auipc	a0,0xb
ffffffffc0201b68:	81450513          	addi	a0,a0,-2028 # ffffffffc020c378 <etext+0xb18>
ffffffffc0201b6c:	8dffe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201b70:	0000b697          	auipc	a3,0xb
ffffffffc0201b74:	b4868693          	addi	a3,a3,-1208 # ffffffffc020c6b8 <etext+0xe58>
ffffffffc0201b78:	0000a617          	auipc	a2,0xa
ffffffffc0201b7c:	12060613          	addi	a2,a2,288 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201b80:	07f00593          	li	a1,127
ffffffffc0201b84:	0000a517          	auipc	a0,0xa
ffffffffc0201b88:	7f450513          	addi	a0,a0,2036 # ffffffffc020c378 <etext+0xb18>
ffffffffc0201b8c:	8bffe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201b90 <default_alloc_pages>:
ffffffffc0201b90:	c951                	beqz	a0,ffffffffc0201c24 <default_alloc_pages+0x94>
ffffffffc0201b92:	00090597          	auipc	a1,0x90
ffffffffc0201b96:	c265a583          	lw	a1,-986(a1) # ffffffffc02917b8 <free_area+0x10>
ffffffffc0201b9a:	86aa                	mv	a3,a0
ffffffffc0201b9c:	02059793          	slli	a5,a1,0x20
ffffffffc0201ba0:	9381                	srli	a5,a5,0x20
ffffffffc0201ba2:	00a7ef63          	bltu	a5,a0,ffffffffc0201bc0 <default_alloc_pages+0x30>
ffffffffc0201ba6:	00090617          	auipc	a2,0x90
ffffffffc0201baa:	c0260613          	addi	a2,a2,-1022 # ffffffffc02917a8 <free_area>
ffffffffc0201bae:	87b2                	mv	a5,a2
ffffffffc0201bb0:	a029                	j	ffffffffc0201bba <default_alloc_pages+0x2a>
ffffffffc0201bb2:	ff87e703          	lwu	a4,-8(a5)
ffffffffc0201bb6:	00d77763          	bgeu	a4,a3,ffffffffc0201bc4 <default_alloc_pages+0x34>
ffffffffc0201bba:	679c                	ld	a5,8(a5)
ffffffffc0201bbc:	fec79be3          	bne	a5,a2,ffffffffc0201bb2 <default_alloc_pages+0x22>
ffffffffc0201bc0:	4501                	li	a0,0
ffffffffc0201bc2:	8082                	ret
ffffffffc0201bc4:	ff87a883          	lw	a7,-8(a5)
ffffffffc0201bc8:	0007b803          	ld	a6,0(a5)
ffffffffc0201bcc:	6798                	ld	a4,8(a5)
ffffffffc0201bce:	02089313          	slli	t1,a7,0x20
ffffffffc0201bd2:	02035313          	srli	t1,t1,0x20
ffffffffc0201bd6:	00e83423          	sd	a4,8(a6)
ffffffffc0201bda:	01073023          	sd	a6,0(a4)
ffffffffc0201bde:	fe878513          	addi	a0,a5,-24
ffffffffc0201be2:	0266fa63          	bgeu	a3,t1,ffffffffc0201c16 <default_alloc_pages+0x86>
ffffffffc0201be6:	00669713          	slli	a4,a3,0x6
ffffffffc0201bea:	40d888bb          	subw	a7,a7,a3
ffffffffc0201bee:	972a                	add	a4,a4,a0
ffffffffc0201bf0:	01172823          	sw	a7,16(a4)
ffffffffc0201bf4:	00870313          	addi	t1,a4,8
ffffffffc0201bf8:	4889                	li	a7,2
ffffffffc0201bfa:	4113302f          	amoor.d	zero,a7,(t1)
ffffffffc0201bfe:	00883883          	ld	a7,8(a6)
ffffffffc0201c02:	01870313          	addi	t1,a4,24
ffffffffc0201c06:	0068b023          	sd	t1,0(a7) # 10000000 <_binary_bin_sfs_img_size+0xff8ad00>
ffffffffc0201c0a:	00683423          	sd	t1,8(a6)
ffffffffc0201c0e:	03173023          	sd	a7,32(a4)
ffffffffc0201c12:	01073c23          	sd	a6,24(a4)
ffffffffc0201c16:	9d95                	subw	a1,a1,a3
ffffffffc0201c18:	ca0c                	sw	a1,16(a2)
ffffffffc0201c1a:	5775                	li	a4,-3
ffffffffc0201c1c:	17c1                	addi	a5,a5,-16
ffffffffc0201c1e:	60e7b02f          	amoand.d	zero,a4,(a5)
ffffffffc0201c22:	8082                	ret
ffffffffc0201c24:	1141                	addi	sp,sp,-16
ffffffffc0201c26:	0000b697          	auipc	a3,0xb
ffffffffc0201c2a:	a9268693          	addi	a3,a3,-1390 # ffffffffc020c6b8 <etext+0xe58>
ffffffffc0201c2e:	0000a617          	auipc	a2,0xa
ffffffffc0201c32:	06a60613          	addi	a2,a2,106 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201c36:	06100593          	li	a1,97
ffffffffc0201c3a:	0000a517          	auipc	a0,0xa
ffffffffc0201c3e:	73e50513          	addi	a0,a0,1854 # ffffffffc020c378 <etext+0xb18>
ffffffffc0201c42:	e406                	sd	ra,8(sp)
ffffffffc0201c44:	807fe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201c48 <default_init_memmap>:
ffffffffc0201c48:	1141                	addi	sp,sp,-16
ffffffffc0201c4a:	e406                	sd	ra,8(sp)
ffffffffc0201c4c:	c9e1                	beqz	a1,ffffffffc0201d1c <default_init_memmap+0xd4>
ffffffffc0201c4e:	00659713          	slli	a4,a1,0x6
ffffffffc0201c52:	00e506b3          	add	a3,a0,a4
ffffffffc0201c56:	87aa                	mv	a5,a0
ffffffffc0201c58:	cf11                	beqz	a4,ffffffffc0201c74 <default_init_memmap+0x2c>
ffffffffc0201c5a:	6798                	ld	a4,8(a5)
ffffffffc0201c5c:	8b05                	andi	a4,a4,1
ffffffffc0201c5e:	cf59                	beqz	a4,ffffffffc0201cfc <default_init_memmap+0xb4>
ffffffffc0201c60:	0007a823          	sw	zero,16(a5)
ffffffffc0201c64:	0007b423          	sd	zero,8(a5)
ffffffffc0201c68:	0007a023          	sw	zero,0(a5)
ffffffffc0201c6c:	04078793          	addi	a5,a5,64
ffffffffc0201c70:	fed795e3          	bne	a5,a3,ffffffffc0201c5a <default_init_memmap+0x12>
ffffffffc0201c74:	c90c                	sw	a1,16(a0)
ffffffffc0201c76:	4789                	li	a5,2
ffffffffc0201c78:	00850713          	addi	a4,a0,8
ffffffffc0201c7c:	40f7302f          	amoor.d	zero,a5,(a4)
ffffffffc0201c80:	00090717          	auipc	a4,0x90
ffffffffc0201c84:	b3872703          	lw	a4,-1224(a4) # ffffffffc02917b8 <free_area+0x10>
ffffffffc0201c88:	00090697          	auipc	a3,0x90
ffffffffc0201c8c:	b2068693          	addi	a3,a3,-1248 # ffffffffc02917a8 <free_area>
ffffffffc0201c90:	669c                	ld	a5,8(a3)
ffffffffc0201c92:	9f2d                	addw	a4,a4,a1
ffffffffc0201c94:	ca98                	sw	a4,16(a3)
ffffffffc0201c96:	04d78663          	beq	a5,a3,ffffffffc0201ce2 <default_init_memmap+0x9a>
ffffffffc0201c9a:	fe878713          	addi	a4,a5,-24
ffffffffc0201c9e:	4581                	li	a1,0
ffffffffc0201ca0:	01850613          	addi	a2,a0,24
ffffffffc0201ca4:	00e56a63          	bltu	a0,a4,ffffffffc0201cb8 <default_init_memmap+0x70>
ffffffffc0201ca8:	6798                	ld	a4,8(a5)
ffffffffc0201caa:	02d70263          	beq	a4,a3,ffffffffc0201cce <default_init_memmap+0x86>
ffffffffc0201cae:	87ba                	mv	a5,a4
ffffffffc0201cb0:	fe878713          	addi	a4,a5,-24
ffffffffc0201cb4:	fee57ae3          	bgeu	a0,a4,ffffffffc0201ca8 <default_init_memmap+0x60>
ffffffffc0201cb8:	c199                	beqz	a1,ffffffffc0201cbe <default_init_memmap+0x76>
ffffffffc0201cba:	0106b023          	sd	a6,0(a3)
ffffffffc0201cbe:	6398                	ld	a4,0(a5)
ffffffffc0201cc0:	60a2                	ld	ra,8(sp)
ffffffffc0201cc2:	e390                	sd	a2,0(a5)
ffffffffc0201cc4:	e710                	sd	a2,8(a4)
ffffffffc0201cc6:	ed18                	sd	a4,24(a0)
ffffffffc0201cc8:	f11c                	sd	a5,32(a0)
ffffffffc0201cca:	0141                	addi	sp,sp,16
ffffffffc0201ccc:	8082                	ret
ffffffffc0201cce:	e790                	sd	a2,8(a5)
ffffffffc0201cd0:	f114                	sd	a3,32(a0)
ffffffffc0201cd2:	6798                	ld	a4,8(a5)
ffffffffc0201cd4:	ed1c                	sd	a5,24(a0)
ffffffffc0201cd6:	8832                	mv	a6,a2
ffffffffc0201cd8:	00d70e63          	beq	a4,a3,ffffffffc0201cf4 <default_init_memmap+0xac>
ffffffffc0201cdc:	4585                	li	a1,1
ffffffffc0201cde:	87ba                	mv	a5,a4
ffffffffc0201ce0:	bfc1                	j	ffffffffc0201cb0 <default_init_memmap+0x68>
ffffffffc0201ce2:	60a2                	ld	ra,8(sp)
ffffffffc0201ce4:	01850713          	addi	a4,a0,24
ffffffffc0201ce8:	f11c                	sd	a5,32(a0)
ffffffffc0201cea:	ed1c                	sd	a5,24(a0)
ffffffffc0201cec:	e398                	sd	a4,0(a5)
ffffffffc0201cee:	e798                	sd	a4,8(a5)
ffffffffc0201cf0:	0141                	addi	sp,sp,16
ffffffffc0201cf2:	8082                	ret
ffffffffc0201cf4:	60a2                	ld	ra,8(sp)
ffffffffc0201cf6:	e290                	sd	a2,0(a3)
ffffffffc0201cf8:	0141                	addi	sp,sp,16
ffffffffc0201cfa:	8082                	ret
ffffffffc0201cfc:	0000b697          	auipc	a3,0xb
ffffffffc0201d00:	9ec68693          	addi	a3,a3,-1556 # ffffffffc020c6e8 <etext+0xe88>
ffffffffc0201d04:	0000a617          	auipc	a2,0xa
ffffffffc0201d08:	f9460613          	addi	a2,a2,-108 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201d0c:	04800593          	li	a1,72
ffffffffc0201d10:	0000a517          	auipc	a0,0xa
ffffffffc0201d14:	66850513          	addi	a0,a0,1640 # ffffffffc020c378 <etext+0xb18>
ffffffffc0201d18:	f32fe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0201d1c:	0000b697          	auipc	a3,0xb
ffffffffc0201d20:	99c68693          	addi	a3,a3,-1636 # ffffffffc020c6b8 <etext+0xe58>
ffffffffc0201d24:	0000a617          	auipc	a2,0xa
ffffffffc0201d28:	f7460613          	addi	a2,a2,-140 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201d2c:	04500593          	li	a1,69
ffffffffc0201d30:	0000a517          	auipc	a0,0xa
ffffffffc0201d34:	64850513          	addi	a0,a0,1608 # ffffffffc020c378 <etext+0xb18>
ffffffffc0201d38:	f12fe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201d3c <slob_free>:
ffffffffc0201d3c:	c531                	beqz	a0,ffffffffc0201d88 <slob_free+0x4c>
ffffffffc0201d3e:	e9b9                	bnez	a1,ffffffffc0201d94 <slob_free+0x58>
ffffffffc0201d40:	100027f3          	csrr	a5,sstatus
ffffffffc0201d44:	8b89                	andi	a5,a5,2
ffffffffc0201d46:	4581                	li	a1,0
ffffffffc0201d48:	efb1                	bnez	a5,ffffffffc0201da4 <slob_free+0x68>
ffffffffc0201d4a:	0008f797          	auipc	a5,0x8f
ffffffffc0201d4e:	3067b783          	ld	a5,774(a5) # ffffffffc0291050 <slobfree>
ffffffffc0201d52:	873e                	mv	a4,a5
ffffffffc0201d54:	679c                	ld	a5,8(a5)
ffffffffc0201d56:	02a77a63          	bgeu	a4,a0,ffffffffc0201d8a <slob_free+0x4e>
ffffffffc0201d5a:	00f56463          	bltu	a0,a5,ffffffffc0201d62 <slob_free+0x26>
ffffffffc0201d5e:	fef76ae3          	bltu	a4,a5,ffffffffc0201d52 <slob_free+0x16>
ffffffffc0201d62:	4110                	lw	a2,0(a0)
ffffffffc0201d64:	00461693          	slli	a3,a2,0x4
ffffffffc0201d68:	96aa                	add	a3,a3,a0
ffffffffc0201d6a:	0ad78463          	beq	a5,a3,ffffffffc0201e12 <slob_free+0xd6>
ffffffffc0201d6e:	4310                	lw	a2,0(a4)
ffffffffc0201d70:	e51c                	sd	a5,8(a0)
ffffffffc0201d72:	00461693          	slli	a3,a2,0x4
ffffffffc0201d76:	96ba                	add	a3,a3,a4
ffffffffc0201d78:	08d50163          	beq	a0,a3,ffffffffc0201dfa <slob_free+0xbe>
ffffffffc0201d7c:	e708                	sd	a0,8(a4)
ffffffffc0201d7e:	0008f797          	auipc	a5,0x8f
ffffffffc0201d82:	2ce7b923          	sd	a4,722(a5) # ffffffffc0291050 <slobfree>
ffffffffc0201d86:	e9a5                	bnez	a1,ffffffffc0201df6 <slob_free+0xba>
ffffffffc0201d88:	8082                	ret
ffffffffc0201d8a:	fcf574e3          	bgeu	a0,a5,ffffffffc0201d52 <slob_free+0x16>
ffffffffc0201d8e:	fcf762e3          	bltu	a4,a5,ffffffffc0201d52 <slob_free+0x16>
ffffffffc0201d92:	bfc1                	j	ffffffffc0201d62 <slob_free+0x26>
ffffffffc0201d94:	25bd                	addiw	a1,a1,15
ffffffffc0201d96:	8191                	srli	a1,a1,0x4
ffffffffc0201d98:	c10c                	sw	a1,0(a0)
ffffffffc0201d9a:	100027f3          	csrr	a5,sstatus
ffffffffc0201d9e:	8b89                	andi	a5,a5,2
ffffffffc0201da0:	4581                	li	a1,0
ffffffffc0201da2:	d7c5                	beqz	a5,ffffffffc0201d4a <slob_free+0xe>
ffffffffc0201da4:	1101                	addi	sp,sp,-32
ffffffffc0201da6:	e42a                	sd	a0,8(sp)
ffffffffc0201da8:	ec06                	sd	ra,24(sp)
ffffffffc0201daa:	e2ffe0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0201dae:	6522                	ld	a0,8(sp)
ffffffffc0201db0:	0008f797          	auipc	a5,0x8f
ffffffffc0201db4:	2a07b783          	ld	a5,672(a5) # ffffffffc0291050 <slobfree>
ffffffffc0201db8:	4585                	li	a1,1
ffffffffc0201dba:	873e                	mv	a4,a5
ffffffffc0201dbc:	679c                	ld	a5,8(a5)
ffffffffc0201dbe:	06a77663          	bgeu	a4,a0,ffffffffc0201e2a <slob_free+0xee>
ffffffffc0201dc2:	00f56463          	bltu	a0,a5,ffffffffc0201dca <slob_free+0x8e>
ffffffffc0201dc6:	fef76ae3          	bltu	a4,a5,ffffffffc0201dba <slob_free+0x7e>
ffffffffc0201dca:	4110                	lw	a2,0(a0)
ffffffffc0201dcc:	00461693          	slli	a3,a2,0x4
ffffffffc0201dd0:	96aa                	add	a3,a3,a0
ffffffffc0201dd2:	06d78363          	beq	a5,a3,ffffffffc0201e38 <slob_free+0xfc>
ffffffffc0201dd6:	4310                	lw	a2,0(a4)
ffffffffc0201dd8:	e51c                	sd	a5,8(a0)
ffffffffc0201dda:	00461693          	slli	a3,a2,0x4
ffffffffc0201dde:	96ba                	add	a3,a3,a4
ffffffffc0201de0:	06d50163          	beq	a0,a3,ffffffffc0201e42 <slob_free+0x106>
ffffffffc0201de4:	e708                	sd	a0,8(a4)
ffffffffc0201de6:	0008f797          	auipc	a5,0x8f
ffffffffc0201dea:	26e7b523          	sd	a4,618(a5) # ffffffffc0291050 <slobfree>
ffffffffc0201dee:	e1a9                	bnez	a1,ffffffffc0201e30 <slob_free+0xf4>
ffffffffc0201df0:	60e2                	ld	ra,24(sp)
ffffffffc0201df2:	6105                	addi	sp,sp,32
ffffffffc0201df4:	8082                	ret
ffffffffc0201df6:	dddfe06f          	j	ffffffffc0200bd2 <intr_enable>
ffffffffc0201dfa:	4114                	lw	a3,0(a0)
ffffffffc0201dfc:	853e                	mv	a0,a5
ffffffffc0201dfe:	e708                	sd	a0,8(a4)
ffffffffc0201e00:	00c687bb          	addw	a5,a3,a2
ffffffffc0201e04:	c31c                	sw	a5,0(a4)
ffffffffc0201e06:	0008f797          	auipc	a5,0x8f
ffffffffc0201e0a:	24e7b523          	sd	a4,586(a5) # ffffffffc0291050 <slobfree>
ffffffffc0201e0e:	ddad                	beqz	a1,ffffffffc0201d88 <slob_free+0x4c>
ffffffffc0201e10:	b7dd                	j	ffffffffc0201df6 <slob_free+0xba>
ffffffffc0201e12:	4394                	lw	a3,0(a5)
ffffffffc0201e14:	679c                	ld	a5,8(a5)
ffffffffc0201e16:	9eb1                	addw	a3,a3,a2
ffffffffc0201e18:	c114                	sw	a3,0(a0)
ffffffffc0201e1a:	4310                	lw	a2,0(a4)
ffffffffc0201e1c:	e51c                	sd	a5,8(a0)
ffffffffc0201e1e:	00461693          	slli	a3,a2,0x4
ffffffffc0201e22:	96ba                	add	a3,a3,a4
ffffffffc0201e24:	f4d51ce3          	bne	a0,a3,ffffffffc0201d7c <slob_free+0x40>
ffffffffc0201e28:	bfc9                	j	ffffffffc0201dfa <slob_free+0xbe>
ffffffffc0201e2a:	f8f56ee3          	bltu	a0,a5,ffffffffc0201dc6 <slob_free+0x8a>
ffffffffc0201e2e:	b771                	j	ffffffffc0201dba <slob_free+0x7e>
ffffffffc0201e30:	60e2                	ld	ra,24(sp)
ffffffffc0201e32:	6105                	addi	sp,sp,32
ffffffffc0201e34:	d9ffe06f          	j	ffffffffc0200bd2 <intr_enable>
ffffffffc0201e38:	4394                	lw	a3,0(a5)
ffffffffc0201e3a:	679c                	ld	a5,8(a5)
ffffffffc0201e3c:	9eb1                	addw	a3,a3,a2
ffffffffc0201e3e:	c114                	sw	a3,0(a0)
ffffffffc0201e40:	bf59                	j	ffffffffc0201dd6 <slob_free+0x9a>
ffffffffc0201e42:	4114                	lw	a3,0(a0)
ffffffffc0201e44:	853e                	mv	a0,a5
ffffffffc0201e46:	00c687bb          	addw	a5,a3,a2
ffffffffc0201e4a:	c31c                	sw	a5,0(a4)
ffffffffc0201e4c:	bf61                	j	ffffffffc0201de4 <slob_free+0xa8>

ffffffffc0201e4e <__slob_get_free_pages.constprop.0>:
ffffffffc0201e4e:	4785                	li	a5,1
ffffffffc0201e50:	1141                	addi	sp,sp,-16
ffffffffc0201e52:	00a7953b          	sllw	a0,a5,a0
ffffffffc0201e56:	e406                	sd	ra,8(sp)
ffffffffc0201e58:	32c000ef          	jal	ffffffffc0202184 <alloc_pages>
ffffffffc0201e5c:	c91d                	beqz	a0,ffffffffc0201e92 <__slob_get_free_pages.constprop.0+0x44>
ffffffffc0201e5e:	00095697          	auipc	a3,0x95
ffffffffc0201e62:	a5a6b683          	ld	a3,-1446(a3) # ffffffffc02968b8 <pages>
ffffffffc0201e66:	0000e797          	auipc	a5,0xe
ffffffffc0201e6a:	cf27b783          	ld	a5,-782(a5) # ffffffffc020fb58 <nbase>
ffffffffc0201e6e:	00095717          	auipc	a4,0x95
ffffffffc0201e72:	a4273703          	ld	a4,-1470(a4) # ffffffffc02968b0 <npage>
ffffffffc0201e76:	8d15                	sub	a0,a0,a3
ffffffffc0201e78:	8519                	srai	a0,a0,0x6
ffffffffc0201e7a:	953e                	add	a0,a0,a5
ffffffffc0201e7c:	00c51793          	slli	a5,a0,0xc
ffffffffc0201e80:	83b1                	srli	a5,a5,0xc
ffffffffc0201e82:	0532                	slli	a0,a0,0xc
ffffffffc0201e84:	00e7fa63          	bgeu	a5,a4,ffffffffc0201e98 <__slob_get_free_pages.constprop.0+0x4a>
ffffffffc0201e88:	00095797          	auipc	a5,0x95
ffffffffc0201e8c:	a207b783          	ld	a5,-1504(a5) # ffffffffc02968a8 <va_pa_offset>
ffffffffc0201e90:	953e                	add	a0,a0,a5
ffffffffc0201e92:	60a2                	ld	ra,8(sp)
ffffffffc0201e94:	0141                	addi	sp,sp,16
ffffffffc0201e96:	8082                	ret
ffffffffc0201e98:	86aa                	mv	a3,a0
ffffffffc0201e9a:	0000b617          	auipc	a2,0xb
ffffffffc0201e9e:	87660613          	addi	a2,a2,-1930 # ffffffffc020c710 <etext+0xeb0>
ffffffffc0201ea2:	07100593          	li	a1,113
ffffffffc0201ea6:	0000b517          	auipc	a0,0xb
ffffffffc0201eaa:	89250513          	addi	a0,a0,-1902 # ffffffffc020c738 <etext+0xed8>
ffffffffc0201eae:	d9cfe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201eb2 <slob_alloc.constprop.0>:
ffffffffc0201eb2:	7179                	addi	sp,sp,-48
ffffffffc0201eb4:	f406                	sd	ra,40(sp)
ffffffffc0201eb6:	f022                	sd	s0,32(sp)
ffffffffc0201eb8:	ec26                	sd	s1,24(sp)
ffffffffc0201eba:	01050713          	addi	a4,a0,16
ffffffffc0201ebe:	6785                	lui	a5,0x1
ffffffffc0201ec0:	0af77e63          	bgeu	a4,a5,ffffffffc0201f7c <slob_alloc.constprop.0+0xca>
ffffffffc0201ec4:	00f50413          	addi	s0,a0,15
ffffffffc0201ec8:	8011                	srli	s0,s0,0x4
ffffffffc0201eca:	2401                	sext.w	s0,s0
ffffffffc0201ecc:	100025f3          	csrr	a1,sstatus
ffffffffc0201ed0:	8989                	andi	a1,a1,2
ffffffffc0201ed2:	edd1                	bnez	a1,ffffffffc0201f6e <slob_alloc.constprop.0+0xbc>
ffffffffc0201ed4:	0008f497          	auipc	s1,0x8f
ffffffffc0201ed8:	17c48493          	addi	s1,s1,380 # ffffffffc0291050 <slobfree>
ffffffffc0201edc:	6090                	ld	a2,0(s1)
ffffffffc0201ede:	6618                	ld	a4,8(a2)
ffffffffc0201ee0:	4314                	lw	a3,0(a4)
ffffffffc0201ee2:	0886da63          	bge	a3,s0,ffffffffc0201f76 <slob_alloc.constprop.0+0xc4>
ffffffffc0201ee6:	00e60a63          	beq	a2,a4,ffffffffc0201efa <slob_alloc.constprop.0+0x48>
ffffffffc0201eea:	671c                	ld	a5,8(a4)
ffffffffc0201eec:	4394                	lw	a3,0(a5)
ffffffffc0201eee:	0286d863          	bge	a3,s0,ffffffffc0201f1e <slob_alloc.constprop.0+0x6c>
ffffffffc0201ef2:	6090                	ld	a2,0(s1)
ffffffffc0201ef4:	873e                	mv	a4,a5
ffffffffc0201ef6:	fee61ae3          	bne	a2,a4,ffffffffc0201eea <slob_alloc.constprop.0+0x38>
ffffffffc0201efa:	e9b1                	bnez	a1,ffffffffc0201f4e <slob_alloc.constprop.0+0x9c>
ffffffffc0201efc:	4501                	li	a0,0
ffffffffc0201efe:	f51ff0ef          	jal	ffffffffc0201e4e <__slob_get_free_pages.constprop.0>
ffffffffc0201f02:	87aa                	mv	a5,a0
ffffffffc0201f04:	c915                	beqz	a0,ffffffffc0201f38 <slob_alloc.constprop.0+0x86>
ffffffffc0201f06:	6585                	lui	a1,0x1
ffffffffc0201f08:	e35ff0ef          	jal	ffffffffc0201d3c <slob_free>
ffffffffc0201f0c:	100025f3          	csrr	a1,sstatus
ffffffffc0201f10:	8989                	andi	a1,a1,2
ffffffffc0201f12:	e98d                	bnez	a1,ffffffffc0201f44 <slob_alloc.constprop.0+0x92>
ffffffffc0201f14:	6098                	ld	a4,0(s1)
ffffffffc0201f16:	671c                	ld	a5,8(a4)
ffffffffc0201f18:	4394                	lw	a3,0(a5)
ffffffffc0201f1a:	fc86cce3          	blt	a3,s0,ffffffffc0201ef2 <slob_alloc.constprop.0+0x40>
ffffffffc0201f1e:	04d40563          	beq	s0,a3,ffffffffc0201f68 <slob_alloc.constprop.0+0xb6>
ffffffffc0201f22:	00441613          	slli	a2,s0,0x4
ffffffffc0201f26:	963e                	add	a2,a2,a5
ffffffffc0201f28:	e710                	sd	a2,8(a4)
ffffffffc0201f2a:	6788                	ld	a0,8(a5)
ffffffffc0201f2c:	9e81                	subw	a3,a3,s0
ffffffffc0201f2e:	c214                	sw	a3,0(a2)
ffffffffc0201f30:	e608                	sd	a0,8(a2)
ffffffffc0201f32:	c380                	sw	s0,0(a5)
ffffffffc0201f34:	e098                	sd	a4,0(s1)
ffffffffc0201f36:	ed99                	bnez	a1,ffffffffc0201f54 <slob_alloc.constprop.0+0xa2>
ffffffffc0201f38:	70a2                	ld	ra,40(sp)
ffffffffc0201f3a:	7402                	ld	s0,32(sp)
ffffffffc0201f3c:	64e2                	ld	s1,24(sp)
ffffffffc0201f3e:	853e                	mv	a0,a5
ffffffffc0201f40:	6145                	addi	sp,sp,48
ffffffffc0201f42:	8082                	ret
ffffffffc0201f44:	c95fe0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0201f48:	6098                	ld	a4,0(s1)
ffffffffc0201f4a:	4585                	li	a1,1
ffffffffc0201f4c:	b7e9                	j	ffffffffc0201f16 <slob_alloc.constprop.0+0x64>
ffffffffc0201f4e:	c85fe0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0201f52:	b76d                	j	ffffffffc0201efc <slob_alloc.constprop.0+0x4a>
ffffffffc0201f54:	e43e                	sd	a5,8(sp)
ffffffffc0201f56:	c7dfe0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0201f5a:	67a2                	ld	a5,8(sp)
ffffffffc0201f5c:	70a2                	ld	ra,40(sp)
ffffffffc0201f5e:	7402                	ld	s0,32(sp)
ffffffffc0201f60:	64e2                	ld	s1,24(sp)
ffffffffc0201f62:	853e                	mv	a0,a5
ffffffffc0201f64:	6145                	addi	sp,sp,48
ffffffffc0201f66:	8082                	ret
ffffffffc0201f68:	6794                	ld	a3,8(a5)
ffffffffc0201f6a:	e714                	sd	a3,8(a4)
ffffffffc0201f6c:	b7e1                	j	ffffffffc0201f34 <slob_alloc.constprop.0+0x82>
ffffffffc0201f6e:	c6bfe0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0201f72:	4585                	li	a1,1
ffffffffc0201f74:	b785                	j	ffffffffc0201ed4 <slob_alloc.constprop.0+0x22>
ffffffffc0201f76:	87ba                	mv	a5,a4
ffffffffc0201f78:	8732                	mv	a4,a2
ffffffffc0201f7a:	b755                	j	ffffffffc0201f1e <slob_alloc.constprop.0+0x6c>
ffffffffc0201f7c:	0000a697          	auipc	a3,0xa
ffffffffc0201f80:	7cc68693          	addi	a3,a3,1996 # ffffffffc020c748 <etext+0xee8>
ffffffffc0201f84:	0000a617          	auipc	a2,0xa
ffffffffc0201f88:	d1460613          	addi	a2,a2,-748 # ffffffffc020bc98 <etext+0x438>
ffffffffc0201f8c:	06300593          	li	a1,99
ffffffffc0201f90:	0000a517          	auipc	a0,0xa
ffffffffc0201f94:	7d850513          	addi	a0,a0,2008 # ffffffffc020c768 <etext+0xf08>
ffffffffc0201f98:	cb2fe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0201f9c <kmalloc_init>:
ffffffffc0201f9c:	1141                	addi	sp,sp,-16
ffffffffc0201f9e:	0000a517          	auipc	a0,0xa
ffffffffc0201fa2:	7e250513          	addi	a0,a0,2018 # ffffffffc020c780 <etext+0xf20>
ffffffffc0201fa6:	e406                	sd	ra,8(sp)
ffffffffc0201fa8:	9fefe0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0201fac:	60a2                	ld	ra,8(sp)
ffffffffc0201fae:	0000a517          	auipc	a0,0xa
ffffffffc0201fb2:	7ea50513          	addi	a0,a0,2026 # ffffffffc020c798 <etext+0xf38>
ffffffffc0201fb6:	0141                	addi	sp,sp,16
ffffffffc0201fb8:	9eefe06f          	j	ffffffffc02001a6 <cprintf>

ffffffffc0201fbc <kallocated>:
ffffffffc0201fbc:	4501                	li	a0,0
ffffffffc0201fbe:	8082                	ret

ffffffffc0201fc0 <kmalloc>:
ffffffffc0201fc0:	1101                	addi	sp,sp,-32
ffffffffc0201fc2:	6685                	lui	a3,0x1
ffffffffc0201fc4:	ec06                	sd	ra,24(sp)
ffffffffc0201fc6:	16bd                	addi	a3,a3,-17 # fef <_binary_bin_swap_img_size-0x6d11>
ffffffffc0201fc8:	04a6f963          	bgeu	a3,a0,ffffffffc020201a <kmalloc+0x5a>
ffffffffc0201fcc:	e42a                	sd	a0,8(sp)
ffffffffc0201fce:	4561                	li	a0,24
ffffffffc0201fd0:	e822                	sd	s0,16(sp)
ffffffffc0201fd2:	ee1ff0ef          	jal	ffffffffc0201eb2 <slob_alloc.constprop.0>
ffffffffc0201fd6:	842a                	mv	s0,a0
ffffffffc0201fd8:	c541                	beqz	a0,ffffffffc0202060 <kmalloc+0xa0>
ffffffffc0201fda:	47a2                	lw	a5,8(sp)
ffffffffc0201fdc:	6705                	lui	a4,0x1
ffffffffc0201fde:	4501                	li	a0,0
ffffffffc0201fe0:	00f75763          	bge	a4,a5,ffffffffc0201fee <kmalloc+0x2e>
ffffffffc0201fe4:	4017d79b          	sraiw	a5,a5,0x1
ffffffffc0201fe8:	2505                	addiw	a0,a0,1
ffffffffc0201fea:	fef74de3          	blt	a4,a5,ffffffffc0201fe4 <kmalloc+0x24>
ffffffffc0201fee:	c008                	sw	a0,0(s0)
ffffffffc0201ff0:	e5fff0ef          	jal	ffffffffc0201e4e <__slob_get_free_pages.constprop.0>
ffffffffc0201ff4:	e408                	sd	a0,8(s0)
ffffffffc0201ff6:	cd31                	beqz	a0,ffffffffc0202052 <kmalloc+0x92>
ffffffffc0201ff8:	100027f3          	csrr	a5,sstatus
ffffffffc0201ffc:	8b89                	andi	a5,a5,2
ffffffffc0201ffe:	eb85                	bnez	a5,ffffffffc020202e <kmalloc+0x6e>
ffffffffc0202000:	00095797          	auipc	a5,0x95
ffffffffc0202004:	8887b783          	ld	a5,-1912(a5) # ffffffffc0296888 <bigblocks>
ffffffffc0202008:	00095717          	auipc	a4,0x95
ffffffffc020200c:	88873023          	sd	s0,-1920(a4) # ffffffffc0296888 <bigblocks>
ffffffffc0202010:	e81c                	sd	a5,16(s0)
ffffffffc0202012:	6442                	ld	s0,16(sp)
ffffffffc0202014:	60e2                	ld	ra,24(sp)
ffffffffc0202016:	6105                	addi	sp,sp,32
ffffffffc0202018:	8082                	ret
ffffffffc020201a:	0541                	addi	a0,a0,16
ffffffffc020201c:	e97ff0ef          	jal	ffffffffc0201eb2 <slob_alloc.constprop.0>
ffffffffc0202020:	87aa                	mv	a5,a0
ffffffffc0202022:	0541                	addi	a0,a0,16
ffffffffc0202024:	fbe5                	bnez	a5,ffffffffc0202014 <kmalloc+0x54>
ffffffffc0202026:	4501                	li	a0,0
ffffffffc0202028:	60e2                	ld	ra,24(sp)
ffffffffc020202a:	6105                	addi	sp,sp,32
ffffffffc020202c:	8082                	ret
ffffffffc020202e:	babfe0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0202032:	00095797          	auipc	a5,0x95
ffffffffc0202036:	8567b783          	ld	a5,-1962(a5) # ffffffffc0296888 <bigblocks>
ffffffffc020203a:	00095717          	auipc	a4,0x95
ffffffffc020203e:	84873723          	sd	s0,-1970(a4) # ffffffffc0296888 <bigblocks>
ffffffffc0202042:	e81c                	sd	a5,16(s0)
ffffffffc0202044:	b8ffe0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0202048:	6408                	ld	a0,8(s0)
ffffffffc020204a:	60e2                	ld	ra,24(sp)
ffffffffc020204c:	6442                	ld	s0,16(sp)
ffffffffc020204e:	6105                	addi	sp,sp,32
ffffffffc0202050:	8082                	ret
ffffffffc0202052:	8522                	mv	a0,s0
ffffffffc0202054:	45e1                	li	a1,24
ffffffffc0202056:	ce7ff0ef          	jal	ffffffffc0201d3c <slob_free>
ffffffffc020205a:	4501                	li	a0,0
ffffffffc020205c:	6442                	ld	s0,16(sp)
ffffffffc020205e:	b7e9                	j	ffffffffc0202028 <kmalloc+0x68>
ffffffffc0202060:	6442                	ld	s0,16(sp)
ffffffffc0202062:	4501                	li	a0,0
ffffffffc0202064:	b7d1                	j	ffffffffc0202028 <kmalloc+0x68>

ffffffffc0202066 <kfree>:
ffffffffc0202066:	c579                	beqz	a0,ffffffffc0202134 <kfree+0xce>
ffffffffc0202068:	03451793          	slli	a5,a0,0x34
ffffffffc020206c:	e3e1                	bnez	a5,ffffffffc020212c <kfree+0xc6>
ffffffffc020206e:	1101                	addi	sp,sp,-32
ffffffffc0202070:	ec06                	sd	ra,24(sp)
ffffffffc0202072:	100027f3          	csrr	a5,sstatus
ffffffffc0202076:	8b89                	andi	a5,a5,2
ffffffffc0202078:	e7c1                	bnez	a5,ffffffffc0202100 <kfree+0x9a>
ffffffffc020207a:	00095797          	auipc	a5,0x95
ffffffffc020207e:	80e7b783          	ld	a5,-2034(a5) # ffffffffc0296888 <bigblocks>
ffffffffc0202082:	4581                	li	a1,0
ffffffffc0202084:	cbad                	beqz	a5,ffffffffc02020f6 <kfree+0x90>
ffffffffc0202086:	00095617          	auipc	a2,0x95
ffffffffc020208a:	80260613          	addi	a2,a2,-2046 # ffffffffc0296888 <bigblocks>
ffffffffc020208e:	a021                	j	ffffffffc0202096 <kfree+0x30>
ffffffffc0202090:	01070613          	addi	a2,a4,16
ffffffffc0202094:	c3a5                	beqz	a5,ffffffffc02020f4 <kfree+0x8e>
ffffffffc0202096:	6794                	ld	a3,8(a5)
ffffffffc0202098:	873e                	mv	a4,a5
ffffffffc020209a:	6b9c                	ld	a5,16(a5)
ffffffffc020209c:	fea69ae3          	bne	a3,a0,ffffffffc0202090 <kfree+0x2a>
ffffffffc02020a0:	e21c                	sd	a5,0(a2)
ffffffffc02020a2:	edb5                	bnez	a1,ffffffffc020211e <kfree+0xb8>
ffffffffc02020a4:	c02007b7          	lui	a5,0xc0200
ffffffffc02020a8:	0af56363          	bltu	a0,a5,ffffffffc020214e <kfree+0xe8>
ffffffffc02020ac:	00094797          	auipc	a5,0x94
ffffffffc02020b0:	7fc7b783          	ld	a5,2044(a5) # ffffffffc02968a8 <va_pa_offset>
ffffffffc02020b4:	00094697          	auipc	a3,0x94
ffffffffc02020b8:	7fc6b683          	ld	a3,2044(a3) # ffffffffc02968b0 <npage>
ffffffffc02020bc:	8d1d                	sub	a0,a0,a5
ffffffffc02020be:	00c55793          	srli	a5,a0,0xc
ffffffffc02020c2:	06d7fa63          	bgeu	a5,a3,ffffffffc0202136 <kfree+0xd0>
ffffffffc02020c6:	0000e617          	auipc	a2,0xe
ffffffffc02020ca:	a9263603          	ld	a2,-1390(a2) # ffffffffc020fb58 <nbase>
ffffffffc02020ce:	00094517          	auipc	a0,0x94
ffffffffc02020d2:	7ea53503          	ld	a0,2026(a0) # ffffffffc02968b8 <pages>
ffffffffc02020d6:	4314                	lw	a3,0(a4)
ffffffffc02020d8:	8f91                	sub	a5,a5,a2
ffffffffc02020da:	079a                	slli	a5,a5,0x6
ffffffffc02020dc:	4585                	li	a1,1
ffffffffc02020de:	953e                	add	a0,a0,a5
ffffffffc02020e0:	00d595bb          	sllw	a1,a1,a3
ffffffffc02020e4:	e03a                	sd	a4,0(sp)
ffffffffc02020e6:	0d8000ef          	jal	ffffffffc02021be <free_pages>
ffffffffc02020ea:	6502                	ld	a0,0(sp)
ffffffffc02020ec:	60e2                	ld	ra,24(sp)
ffffffffc02020ee:	45e1                	li	a1,24
ffffffffc02020f0:	6105                	addi	sp,sp,32
ffffffffc02020f2:	b1a9                	j	ffffffffc0201d3c <slob_free>
ffffffffc02020f4:	e185                	bnez	a1,ffffffffc0202114 <kfree+0xae>
ffffffffc02020f6:	60e2                	ld	ra,24(sp)
ffffffffc02020f8:	1541                	addi	a0,a0,-16
ffffffffc02020fa:	4581                	li	a1,0
ffffffffc02020fc:	6105                	addi	sp,sp,32
ffffffffc02020fe:	b93d                	j	ffffffffc0201d3c <slob_free>
ffffffffc0202100:	e02a                	sd	a0,0(sp)
ffffffffc0202102:	ad7fe0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0202106:	00094797          	auipc	a5,0x94
ffffffffc020210a:	7827b783          	ld	a5,1922(a5) # ffffffffc0296888 <bigblocks>
ffffffffc020210e:	6502                	ld	a0,0(sp)
ffffffffc0202110:	4585                	li	a1,1
ffffffffc0202112:	fbb5                	bnez	a5,ffffffffc0202086 <kfree+0x20>
ffffffffc0202114:	e02a                	sd	a0,0(sp)
ffffffffc0202116:	abdfe0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc020211a:	6502                	ld	a0,0(sp)
ffffffffc020211c:	bfe9                	j	ffffffffc02020f6 <kfree+0x90>
ffffffffc020211e:	e42a                	sd	a0,8(sp)
ffffffffc0202120:	e03a                	sd	a4,0(sp)
ffffffffc0202122:	ab1fe0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0202126:	6522                	ld	a0,8(sp)
ffffffffc0202128:	6702                	ld	a4,0(sp)
ffffffffc020212a:	bfad                	j	ffffffffc02020a4 <kfree+0x3e>
ffffffffc020212c:	1541                	addi	a0,a0,-16
ffffffffc020212e:	4581                	li	a1,0
ffffffffc0202130:	c0dff06f          	j	ffffffffc0201d3c <slob_free>
ffffffffc0202134:	8082                	ret
ffffffffc0202136:	0000a617          	auipc	a2,0xa
ffffffffc020213a:	6aa60613          	addi	a2,a2,1706 # ffffffffc020c7e0 <etext+0xf80>
ffffffffc020213e:	06900593          	li	a1,105
ffffffffc0202142:	0000a517          	auipc	a0,0xa
ffffffffc0202146:	5f650513          	addi	a0,a0,1526 # ffffffffc020c738 <etext+0xed8>
ffffffffc020214a:	b00fe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc020214e:	86aa                	mv	a3,a0
ffffffffc0202150:	0000a617          	auipc	a2,0xa
ffffffffc0202154:	66860613          	addi	a2,a2,1640 # ffffffffc020c7b8 <etext+0xf58>
ffffffffc0202158:	07700593          	li	a1,119
ffffffffc020215c:	0000a517          	auipc	a0,0xa
ffffffffc0202160:	5dc50513          	addi	a0,a0,1500 # ffffffffc020c738 <etext+0xed8>
ffffffffc0202164:	ae6fe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0202168 <pa2page.part.0>:
ffffffffc0202168:	1141                	addi	sp,sp,-16
ffffffffc020216a:	0000a617          	auipc	a2,0xa
ffffffffc020216e:	67660613          	addi	a2,a2,1654 # ffffffffc020c7e0 <etext+0xf80>
ffffffffc0202172:	06900593          	li	a1,105
ffffffffc0202176:	0000a517          	auipc	a0,0xa
ffffffffc020217a:	5c250513          	addi	a0,a0,1474 # ffffffffc020c738 <etext+0xed8>
ffffffffc020217e:	e406                	sd	ra,8(sp)
ffffffffc0202180:	acafe0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0202184 <alloc_pages>:
ffffffffc0202184:	100027f3          	csrr	a5,sstatus
ffffffffc0202188:	8b89                	andi	a5,a5,2
ffffffffc020218a:	e799                	bnez	a5,ffffffffc0202198 <alloc_pages+0x14>
ffffffffc020218c:	00094797          	auipc	a5,0x94
ffffffffc0202190:	7047b783          	ld	a5,1796(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc0202194:	6f9c                	ld	a5,24(a5)
ffffffffc0202196:	8782                	jr	a5
ffffffffc0202198:	1101                	addi	sp,sp,-32
ffffffffc020219a:	ec06                	sd	ra,24(sp)
ffffffffc020219c:	e42a                	sd	a0,8(sp)
ffffffffc020219e:	a3bfe0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc02021a2:	00094797          	auipc	a5,0x94
ffffffffc02021a6:	6ee7b783          	ld	a5,1774(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc02021aa:	6522                	ld	a0,8(sp)
ffffffffc02021ac:	6f9c                	ld	a5,24(a5)
ffffffffc02021ae:	9782                	jalr	a5
ffffffffc02021b0:	e42a                	sd	a0,8(sp)
ffffffffc02021b2:	a21fe0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc02021b6:	60e2                	ld	ra,24(sp)
ffffffffc02021b8:	6522                	ld	a0,8(sp)
ffffffffc02021ba:	6105                	addi	sp,sp,32
ffffffffc02021bc:	8082                	ret

ffffffffc02021be <free_pages>:
ffffffffc02021be:	100027f3          	csrr	a5,sstatus
ffffffffc02021c2:	8b89                	andi	a5,a5,2
ffffffffc02021c4:	e799                	bnez	a5,ffffffffc02021d2 <free_pages+0x14>
ffffffffc02021c6:	00094797          	auipc	a5,0x94
ffffffffc02021ca:	6ca7b783          	ld	a5,1738(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc02021ce:	739c                	ld	a5,32(a5)
ffffffffc02021d0:	8782                	jr	a5
ffffffffc02021d2:	1101                	addi	sp,sp,-32
ffffffffc02021d4:	ec06                	sd	ra,24(sp)
ffffffffc02021d6:	e42e                	sd	a1,8(sp)
ffffffffc02021d8:	e02a                	sd	a0,0(sp)
ffffffffc02021da:	9fffe0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc02021de:	00094797          	auipc	a5,0x94
ffffffffc02021e2:	6b27b783          	ld	a5,1714(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc02021e6:	65a2                	ld	a1,8(sp)
ffffffffc02021e8:	6502                	ld	a0,0(sp)
ffffffffc02021ea:	739c                	ld	a5,32(a5)
ffffffffc02021ec:	9782                	jalr	a5
ffffffffc02021ee:	60e2                	ld	ra,24(sp)
ffffffffc02021f0:	6105                	addi	sp,sp,32
ffffffffc02021f2:	9e1fe06f          	j	ffffffffc0200bd2 <intr_enable>

ffffffffc02021f6 <nr_free_pages>:
ffffffffc02021f6:	100027f3          	csrr	a5,sstatus
ffffffffc02021fa:	8b89                	andi	a5,a5,2
ffffffffc02021fc:	e799                	bnez	a5,ffffffffc020220a <nr_free_pages+0x14>
ffffffffc02021fe:	00094797          	auipc	a5,0x94
ffffffffc0202202:	6927b783          	ld	a5,1682(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc0202206:	779c                	ld	a5,40(a5)
ffffffffc0202208:	8782                	jr	a5
ffffffffc020220a:	1101                	addi	sp,sp,-32
ffffffffc020220c:	ec06                	sd	ra,24(sp)
ffffffffc020220e:	9cbfe0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0202212:	00094797          	auipc	a5,0x94
ffffffffc0202216:	67e7b783          	ld	a5,1662(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc020221a:	779c                	ld	a5,40(a5)
ffffffffc020221c:	9782                	jalr	a5
ffffffffc020221e:	e42a                	sd	a0,8(sp)
ffffffffc0202220:	9b3fe0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0202224:	60e2                	ld	ra,24(sp)
ffffffffc0202226:	6522                	ld	a0,8(sp)
ffffffffc0202228:	6105                	addi	sp,sp,32
ffffffffc020222a:	8082                	ret

ffffffffc020222c <get_pte>:
ffffffffc020222c:	01e5d793          	srli	a5,a1,0x1e
ffffffffc0202230:	1ff7f793          	andi	a5,a5,511
ffffffffc0202234:	078e                	slli	a5,a5,0x3
ffffffffc0202236:	00f50733          	add	a4,a0,a5
ffffffffc020223a:	6314                	ld	a3,0(a4)
ffffffffc020223c:	7139                	addi	sp,sp,-64
ffffffffc020223e:	f822                	sd	s0,48(sp)
ffffffffc0202240:	f426                	sd	s1,40(sp)
ffffffffc0202242:	fc06                	sd	ra,56(sp)
ffffffffc0202244:	0016f793          	andi	a5,a3,1
ffffffffc0202248:	842e                	mv	s0,a1
ffffffffc020224a:	8832                	mv	a6,a2
ffffffffc020224c:	00094497          	auipc	s1,0x94
ffffffffc0202250:	66448493          	addi	s1,s1,1636 # ffffffffc02968b0 <npage>
ffffffffc0202254:	ebd1                	bnez	a5,ffffffffc02022e8 <get_pte+0xbc>
ffffffffc0202256:	16060d63          	beqz	a2,ffffffffc02023d0 <get_pte+0x1a4>
ffffffffc020225a:	100027f3          	csrr	a5,sstatus
ffffffffc020225e:	8b89                	andi	a5,a5,2
ffffffffc0202260:	16079e63          	bnez	a5,ffffffffc02023dc <get_pte+0x1b0>
ffffffffc0202264:	00094797          	auipc	a5,0x94
ffffffffc0202268:	62c7b783          	ld	a5,1580(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc020226c:	4505                	li	a0,1
ffffffffc020226e:	e43a                	sd	a4,8(sp)
ffffffffc0202270:	6f9c                	ld	a5,24(a5)
ffffffffc0202272:	e832                	sd	a2,16(sp)
ffffffffc0202274:	9782                	jalr	a5
ffffffffc0202276:	6722                	ld	a4,8(sp)
ffffffffc0202278:	6842                	ld	a6,16(sp)
ffffffffc020227a:	87aa                	mv	a5,a0
ffffffffc020227c:	14078a63          	beqz	a5,ffffffffc02023d0 <get_pte+0x1a4>
ffffffffc0202280:	00094517          	auipc	a0,0x94
ffffffffc0202284:	63853503          	ld	a0,1592(a0) # ffffffffc02968b8 <pages>
ffffffffc0202288:	000808b7          	lui	a7,0x80
ffffffffc020228c:	00094497          	auipc	s1,0x94
ffffffffc0202290:	62448493          	addi	s1,s1,1572 # ffffffffc02968b0 <npage>
ffffffffc0202294:	40a78533          	sub	a0,a5,a0
ffffffffc0202298:	8519                	srai	a0,a0,0x6
ffffffffc020229a:	9546                	add	a0,a0,a7
ffffffffc020229c:	6090                	ld	a2,0(s1)
ffffffffc020229e:	00c51693          	slli	a3,a0,0xc
ffffffffc02022a2:	4585                	li	a1,1
ffffffffc02022a4:	82b1                	srli	a3,a3,0xc
ffffffffc02022a6:	c38c                	sw	a1,0(a5)
ffffffffc02022a8:	0532                	slli	a0,a0,0xc
ffffffffc02022aa:	1ac6f763          	bgeu	a3,a2,ffffffffc0202458 <get_pte+0x22c>
ffffffffc02022ae:	00094697          	auipc	a3,0x94
ffffffffc02022b2:	5fa6b683          	ld	a3,1530(a3) # ffffffffc02968a8 <va_pa_offset>
ffffffffc02022b6:	6605                	lui	a2,0x1
ffffffffc02022b8:	4581                	li	a1,0
ffffffffc02022ba:	9536                	add	a0,a0,a3
ffffffffc02022bc:	ec42                	sd	a6,24(sp)
ffffffffc02022be:	e83e                	sd	a5,16(sp)
ffffffffc02022c0:	e43a                	sd	a4,8(sp)
ffffffffc02022c2:	536090ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc02022c6:	00094697          	auipc	a3,0x94
ffffffffc02022ca:	5f26b683          	ld	a3,1522(a3) # ffffffffc02968b8 <pages>
ffffffffc02022ce:	67c2                	ld	a5,16(sp)
ffffffffc02022d0:	000808b7          	lui	a7,0x80
ffffffffc02022d4:	6722                	ld	a4,8(sp)
ffffffffc02022d6:	40d786b3          	sub	a3,a5,a3
ffffffffc02022da:	8699                	srai	a3,a3,0x6
ffffffffc02022dc:	96c6                	add	a3,a3,a7
ffffffffc02022de:	06aa                	slli	a3,a3,0xa
ffffffffc02022e0:	6862                	ld	a6,24(sp)
ffffffffc02022e2:	0116e693          	ori	a3,a3,17
ffffffffc02022e6:	e314                	sd	a3,0(a4)
ffffffffc02022e8:	c006f693          	andi	a3,a3,-1024
ffffffffc02022ec:	6098                	ld	a4,0(s1)
ffffffffc02022ee:	068a                	slli	a3,a3,0x2
ffffffffc02022f0:	00c6d793          	srli	a5,a3,0xc
ffffffffc02022f4:	14e7f663          	bgeu	a5,a4,ffffffffc0202440 <get_pte+0x214>
ffffffffc02022f8:	00094897          	auipc	a7,0x94
ffffffffc02022fc:	5b088893          	addi	a7,a7,1456 # ffffffffc02968a8 <va_pa_offset>
ffffffffc0202300:	0008b603          	ld	a2,0(a7)
ffffffffc0202304:	01545793          	srli	a5,s0,0x15
ffffffffc0202308:	1ff7f793          	andi	a5,a5,511
ffffffffc020230c:	96b2                	add	a3,a3,a2
ffffffffc020230e:	078e                	slli	a5,a5,0x3
ffffffffc0202310:	97b6                	add	a5,a5,a3
ffffffffc0202312:	6394                	ld	a3,0(a5)
ffffffffc0202314:	0016f613          	andi	a2,a3,1
ffffffffc0202318:	e659                	bnez	a2,ffffffffc02023a6 <get_pte+0x17a>
ffffffffc020231a:	0a080b63          	beqz	a6,ffffffffc02023d0 <get_pte+0x1a4>
ffffffffc020231e:	10002773          	csrr	a4,sstatus
ffffffffc0202322:	8b09                	andi	a4,a4,2
ffffffffc0202324:	ef71                	bnez	a4,ffffffffc0202400 <get_pte+0x1d4>
ffffffffc0202326:	00094717          	auipc	a4,0x94
ffffffffc020232a:	56a73703          	ld	a4,1386(a4) # ffffffffc0296890 <pmm_manager>
ffffffffc020232e:	4505                	li	a0,1
ffffffffc0202330:	e43e                	sd	a5,8(sp)
ffffffffc0202332:	6f18                	ld	a4,24(a4)
ffffffffc0202334:	9702                	jalr	a4
ffffffffc0202336:	67a2                	ld	a5,8(sp)
ffffffffc0202338:	872a                	mv	a4,a0
ffffffffc020233a:	00094897          	auipc	a7,0x94
ffffffffc020233e:	56e88893          	addi	a7,a7,1390 # ffffffffc02968a8 <va_pa_offset>
ffffffffc0202342:	c759                	beqz	a4,ffffffffc02023d0 <get_pte+0x1a4>
ffffffffc0202344:	00094697          	auipc	a3,0x94
ffffffffc0202348:	5746b683          	ld	a3,1396(a3) # ffffffffc02968b8 <pages>
ffffffffc020234c:	00080837          	lui	a6,0x80
ffffffffc0202350:	608c                	ld	a1,0(s1)
ffffffffc0202352:	40d706b3          	sub	a3,a4,a3
ffffffffc0202356:	8699                	srai	a3,a3,0x6
ffffffffc0202358:	96c2                	add	a3,a3,a6
ffffffffc020235a:	00c69613          	slli	a2,a3,0xc
ffffffffc020235e:	4505                	li	a0,1
ffffffffc0202360:	8231                	srli	a2,a2,0xc
ffffffffc0202362:	c308                	sw	a0,0(a4)
ffffffffc0202364:	06b2                	slli	a3,a3,0xc
ffffffffc0202366:	10b67663          	bgeu	a2,a1,ffffffffc0202472 <get_pte+0x246>
ffffffffc020236a:	0008b503          	ld	a0,0(a7)
ffffffffc020236e:	6605                	lui	a2,0x1
ffffffffc0202370:	4581                	li	a1,0
ffffffffc0202372:	9536                	add	a0,a0,a3
ffffffffc0202374:	e83a                	sd	a4,16(sp)
ffffffffc0202376:	e43e                	sd	a5,8(sp)
ffffffffc0202378:	480090ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc020237c:	00094697          	auipc	a3,0x94
ffffffffc0202380:	53c6b683          	ld	a3,1340(a3) # ffffffffc02968b8 <pages>
ffffffffc0202384:	6742                	ld	a4,16(sp)
ffffffffc0202386:	00080837          	lui	a6,0x80
ffffffffc020238a:	67a2                	ld	a5,8(sp)
ffffffffc020238c:	40d706b3          	sub	a3,a4,a3
ffffffffc0202390:	8699                	srai	a3,a3,0x6
ffffffffc0202392:	96c2                	add	a3,a3,a6
ffffffffc0202394:	06aa                	slli	a3,a3,0xa
ffffffffc0202396:	0116e693          	ori	a3,a3,17
ffffffffc020239a:	e394                	sd	a3,0(a5)
ffffffffc020239c:	6098                	ld	a4,0(s1)
ffffffffc020239e:	00094897          	auipc	a7,0x94
ffffffffc02023a2:	50a88893          	addi	a7,a7,1290 # ffffffffc02968a8 <va_pa_offset>
ffffffffc02023a6:	c006f693          	andi	a3,a3,-1024
ffffffffc02023aa:	068a                	slli	a3,a3,0x2
ffffffffc02023ac:	00c6d793          	srli	a5,a3,0xc
ffffffffc02023b0:	06e7fc63          	bgeu	a5,a4,ffffffffc0202428 <get_pte+0x1fc>
ffffffffc02023b4:	0008b783          	ld	a5,0(a7)
ffffffffc02023b8:	8031                	srli	s0,s0,0xc
ffffffffc02023ba:	1ff47413          	andi	s0,s0,511
ffffffffc02023be:	040e                	slli	s0,s0,0x3
ffffffffc02023c0:	96be                	add	a3,a3,a5
ffffffffc02023c2:	70e2                	ld	ra,56(sp)
ffffffffc02023c4:	00868533          	add	a0,a3,s0
ffffffffc02023c8:	7442                	ld	s0,48(sp)
ffffffffc02023ca:	74a2                	ld	s1,40(sp)
ffffffffc02023cc:	6121                	addi	sp,sp,64
ffffffffc02023ce:	8082                	ret
ffffffffc02023d0:	70e2                	ld	ra,56(sp)
ffffffffc02023d2:	7442                	ld	s0,48(sp)
ffffffffc02023d4:	74a2                	ld	s1,40(sp)
ffffffffc02023d6:	4501                	li	a0,0
ffffffffc02023d8:	6121                	addi	sp,sp,64
ffffffffc02023da:	8082                	ret
ffffffffc02023dc:	e83a                	sd	a4,16(sp)
ffffffffc02023de:	ec32                	sd	a2,24(sp)
ffffffffc02023e0:	ff8fe0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc02023e4:	00094797          	auipc	a5,0x94
ffffffffc02023e8:	4ac7b783          	ld	a5,1196(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc02023ec:	4505                	li	a0,1
ffffffffc02023ee:	6f9c                	ld	a5,24(a5)
ffffffffc02023f0:	9782                	jalr	a5
ffffffffc02023f2:	e42a                	sd	a0,8(sp)
ffffffffc02023f4:	fdefe0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc02023f8:	6862                	ld	a6,24(sp)
ffffffffc02023fa:	6742                	ld	a4,16(sp)
ffffffffc02023fc:	67a2                	ld	a5,8(sp)
ffffffffc02023fe:	bdbd                	j	ffffffffc020227c <get_pte+0x50>
ffffffffc0202400:	e83e                	sd	a5,16(sp)
ffffffffc0202402:	fd6fe0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0202406:	00094717          	auipc	a4,0x94
ffffffffc020240a:	48a73703          	ld	a4,1162(a4) # ffffffffc0296890 <pmm_manager>
ffffffffc020240e:	4505                	li	a0,1
ffffffffc0202410:	6f18                	ld	a4,24(a4)
ffffffffc0202412:	9702                	jalr	a4
ffffffffc0202414:	e42a                	sd	a0,8(sp)
ffffffffc0202416:	fbcfe0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc020241a:	6722                	ld	a4,8(sp)
ffffffffc020241c:	67c2                	ld	a5,16(sp)
ffffffffc020241e:	00094897          	auipc	a7,0x94
ffffffffc0202422:	48a88893          	addi	a7,a7,1162 # ffffffffc02968a8 <va_pa_offset>
ffffffffc0202426:	bf31                	j	ffffffffc0202342 <get_pte+0x116>
ffffffffc0202428:	0000a617          	auipc	a2,0xa
ffffffffc020242c:	2e860613          	addi	a2,a2,744 # ffffffffc020c710 <etext+0xeb0>
ffffffffc0202430:	13300593          	li	a1,307
ffffffffc0202434:	0000a517          	auipc	a0,0xa
ffffffffc0202438:	3cc50513          	addi	a0,a0,972 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020243c:	80efe0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0202440:	0000a617          	auipc	a2,0xa
ffffffffc0202444:	2d060613          	addi	a2,a2,720 # ffffffffc020c710 <etext+0xeb0>
ffffffffc0202448:	12600593          	li	a1,294
ffffffffc020244c:	0000a517          	auipc	a0,0xa
ffffffffc0202450:	3b450513          	addi	a0,a0,948 # ffffffffc020c800 <etext+0xfa0>
ffffffffc0202454:	ff7fd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0202458:	86aa                	mv	a3,a0
ffffffffc020245a:	0000a617          	auipc	a2,0xa
ffffffffc020245e:	2b660613          	addi	a2,a2,694 # ffffffffc020c710 <etext+0xeb0>
ffffffffc0202462:	12200593          	li	a1,290
ffffffffc0202466:	0000a517          	auipc	a0,0xa
ffffffffc020246a:	39a50513          	addi	a0,a0,922 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020246e:	fddfd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0202472:	0000a617          	auipc	a2,0xa
ffffffffc0202476:	29e60613          	addi	a2,a2,670 # ffffffffc020c710 <etext+0xeb0>
ffffffffc020247a:	13000593          	li	a1,304
ffffffffc020247e:	0000a517          	auipc	a0,0xa
ffffffffc0202482:	38250513          	addi	a0,a0,898 # ffffffffc020c800 <etext+0xfa0>
ffffffffc0202486:	fc5fd0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020248a <boot_map_segment>:
ffffffffc020248a:	7139                	addi	sp,sp,-64
ffffffffc020248c:	f04a                	sd	s2,32(sp)
ffffffffc020248e:	6905                	lui	s2,0x1
ffffffffc0202490:	00d5c833          	xor	a6,a1,a3
ffffffffc0202494:	fff90793          	addi	a5,s2,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc0202498:	fc06                	sd	ra,56(sp)
ffffffffc020249a:	00f87833          	and	a6,a6,a5
ffffffffc020249e:	08081563          	bnez	a6,ffffffffc0202528 <boot_map_segment+0x9e>
ffffffffc02024a2:	f426                	sd	s1,40(sp)
ffffffffc02024a4:	963e                	add	a2,a2,a5
ffffffffc02024a6:	00f5f4b3          	and	s1,a1,a5
ffffffffc02024aa:	94b2                	add	s1,s1,a2
ffffffffc02024ac:	80b1                	srli	s1,s1,0xc
ffffffffc02024ae:	c8a1                	beqz	s1,ffffffffc02024fe <boot_map_segment+0x74>
ffffffffc02024b0:	77fd                	lui	a5,0xfffff
ffffffffc02024b2:	00176713          	ori	a4,a4,1
ffffffffc02024b6:	f822                	sd	s0,48(sp)
ffffffffc02024b8:	e852                	sd	s4,16(sp)
ffffffffc02024ba:	8efd                	and	a3,a3,a5
ffffffffc02024bc:	02071a13          	slli	s4,a4,0x20
ffffffffc02024c0:	00f5f433          	and	s0,a1,a5
ffffffffc02024c4:	ec4e                	sd	s3,24(sp)
ffffffffc02024c6:	e456                	sd	s5,8(sp)
ffffffffc02024c8:	89aa                	mv	s3,a0
ffffffffc02024ca:	020a5a13          	srli	s4,s4,0x20
ffffffffc02024ce:	40868ab3          	sub	s5,a3,s0
ffffffffc02024d2:	4605                	li	a2,1
ffffffffc02024d4:	85a2                	mv	a1,s0
ffffffffc02024d6:	854e                	mv	a0,s3
ffffffffc02024d8:	d55ff0ef          	jal	ffffffffc020222c <get_pte>
ffffffffc02024dc:	c515                	beqz	a0,ffffffffc0202508 <boot_map_segment+0x7e>
ffffffffc02024de:	008a87b3          	add	a5,s5,s0
ffffffffc02024e2:	83b1                	srli	a5,a5,0xc
ffffffffc02024e4:	07aa                	slli	a5,a5,0xa
ffffffffc02024e6:	0147e7b3          	or	a5,a5,s4
ffffffffc02024ea:	0017e793          	ori	a5,a5,1
ffffffffc02024ee:	14fd                	addi	s1,s1,-1
ffffffffc02024f0:	e11c                	sd	a5,0(a0)
ffffffffc02024f2:	944a                	add	s0,s0,s2
ffffffffc02024f4:	fcf9                	bnez	s1,ffffffffc02024d2 <boot_map_segment+0x48>
ffffffffc02024f6:	7442                	ld	s0,48(sp)
ffffffffc02024f8:	69e2                	ld	s3,24(sp)
ffffffffc02024fa:	6a42                	ld	s4,16(sp)
ffffffffc02024fc:	6aa2                	ld	s5,8(sp)
ffffffffc02024fe:	70e2                	ld	ra,56(sp)
ffffffffc0202500:	74a2                	ld	s1,40(sp)
ffffffffc0202502:	7902                	ld	s2,32(sp)
ffffffffc0202504:	6121                	addi	sp,sp,64
ffffffffc0202506:	8082                	ret
ffffffffc0202508:	0000a697          	auipc	a3,0xa
ffffffffc020250c:	32068693          	addi	a3,a3,800 # ffffffffc020c828 <etext+0xfc8>
ffffffffc0202510:	00009617          	auipc	a2,0x9
ffffffffc0202514:	78860613          	addi	a2,a2,1928 # ffffffffc020bc98 <etext+0x438>
ffffffffc0202518:	09c00593          	li	a1,156
ffffffffc020251c:	0000a517          	auipc	a0,0xa
ffffffffc0202520:	2e450513          	addi	a0,a0,740 # ffffffffc020c800 <etext+0xfa0>
ffffffffc0202524:	f27fd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0202528:	0000a697          	auipc	a3,0xa
ffffffffc020252c:	2e868693          	addi	a3,a3,744 # ffffffffc020c810 <etext+0xfb0>
ffffffffc0202530:	00009617          	auipc	a2,0x9
ffffffffc0202534:	76860613          	addi	a2,a2,1896 # ffffffffc020bc98 <etext+0x438>
ffffffffc0202538:	09500593          	li	a1,149
ffffffffc020253c:	0000a517          	auipc	a0,0xa
ffffffffc0202540:	2c450513          	addi	a0,a0,708 # ffffffffc020c800 <etext+0xfa0>
ffffffffc0202544:	f822                	sd	s0,48(sp)
ffffffffc0202546:	f426                	sd	s1,40(sp)
ffffffffc0202548:	ec4e                	sd	s3,24(sp)
ffffffffc020254a:	e852                	sd	s4,16(sp)
ffffffffc020254c:	e456                	sd	s5,8(sp)
ffffffffc020254e:	efdfd0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0202552 <get_page>:
ffffffffc0202552:	1141                	addi	sp,sp,-16
ffffffffc0202554:	e022                	sd	s0,0(sp)
ffffffffc0202556:	8432                	mv	s0,a2
ffffffffc0202558:	4601                	li	a2,0
ffffffffc020255a:	e406                	sd	ra,8(sp)
ffffffffc020255c:	cd1ff0ef          	jal	ffffffffc020222c <get_pte>
ffffffffc0202560:	c011                	beqz	s0,ffffffffc0202564 <get_page+0x12>
ffffffffc0202562:	e008                	sd	a0,0(s0)
ffffffffc0202564:	c511                	beqz	a0,ffffffffc0202570 <get_page+0x1e>
ffffffffc0202566:	611c                	ld	a5,0(a0)
ffffffffc0202568:	4501                	li	a0,0
ffffffffc020256a:	0017f713          	andi	a4,a5,1
ffffffffc020256e:	e709                	bnez	a4,ffffffffc0202578 <get_page+0x26>
ffffffffc0202570:	60a2                	ld	ra,8(sp)
ffffffffc0202572:	6402                	ld	s0,0(sp)
ffffffffc0202574:	0141                	addi	sp,sp,16
ffffffffc0202576:	8082                	ret
ffffffffc0202578:	00094717          	auipc	a4,0x94
ffffffffc020257c:	33873703          	ld	a4,824(a4) # ffffffffc02968b0 <npage>
ffffffffc0202580:	078a                	slli	a5,a5,0x2
ffffffffc0202582:	83b1                	srli	a5,a5,0xc
ffffffffc0202584:	00e7ff63          	bgeu	a5,a4,ffffffffc02025a2 <get_page+0x50>
ffffffffc0202588:	00094517          	auipc	a0,0x94
ffffffffc020258c:	33053503          	ld	a0,816(a0) # ffffffffc02968b8 <pages>
ffffffffc0202590:	60a2                	ld	ra,8(sp)
ffffffffc0202592:	6402                	ld	s0,0(sp)
ffffffffc0202594:	079a                	slli	a5,a5,0x6
ffffffffc0202596:	fe000737          	lui	a4,0xfe000
ffffffffc020259a:	97ba                	add	a5,a5,a4
ffffffffc020259c:	953e                	add	a0,a0,a5
ffffffffc020259e:	0141                	addi	sp,sp,16
ffffffffc02025a0:	8082                	ret
ffffffffc02025a2:	bc7ff0ef          	jal	ffffffffc0202168 <pa2page.part.0>

ffffffffc02025a6 <unmap_range>:
ffffffffc02025a6:	715d                	addi	sp,sp,-80
ffffffffc02025a8:	00c5e7b3          	or	a5,a1,a2
ffffffffc02025ac:	e486                	sd	ra,72(sp)
ffffffffc02025ae:	e0a2                	sd	s0,64(sp)
ffffffffc02025b0:	fc26                	sd	s1,56(sp)
ffffffffc02025b2:	f84a                	sd	s2,48(sp)
ffffffffc02025b4:	f44e                	sd	s3,40(sp)
ffffffffc02025b6:	f052                	sd	s4,32(sp)
ffffffffc02025b8:	ec56                	sd	s5,24(sp)
ffffffffc02025ba:	03479713          	slli	a4,a5,0x34
ffffffffc02025be:	ef61                	bnez	a4,ffffffffc0202696 <unmap_range+0xf0>
ffffffffc02025c0:	00200a37          	lui	s4,0x200
ffffffffc02025c4:	00c5b7b3          	sltu	a5,a1,a2
ffffffffc02025c8:	0145b733          	sltu	a4,a1,s4
ffffffffc02025cc:	0017b793          	seqz	a5,a5
ffffffffc02025d0:	8fd9                	or	a5,a5,a4
ffffffffc02025d2:	842e                	mv	s0,a1
ffffffffc02025d4:	84b2                	mv	s1,a2
ffffffffc02025d6:	e3e5                	bnez	a5,ffffffffc02026b6 <unmap_range+0x110>
ffffffffc02025d8:	4785                	li	a5,1
ffffffffc02025da:	07fe                	slli	a5,a5,0x1f
ffffffffc02025dc:	0785                	addi	a5,a5,1 # fffffffffffff001 <end+0x3fd686f1>
ffffffffc02025de:	892a                	mv	s2,a0
ffffffffc02025e0:	6985                	lui	s3,0x1
ffffffffc02025e2:	ffe00ab7          	lui	s5,0xffe00
ffffffffc02025e6:	0cf67863          	bgeu	a2,a5,ffffffffc02026b6 <unmap_range+0x110>
ffffffffc02025ea:	4601                	li	a2,0
ffffffffc02025ec:	85a2                	mv	a1,s0
ffffffffc02025ee:	854a                	mv	a0,s2
ffffffffc02025f0:	c3dff0ef          	jal	ffffffffc020222c <get_pte>
ffffffffc02025f4:	87aa                	mv	a5,a0
ffffffffc02025f6:	cd31                	beqz	a0,ffffffffc0202652 <unmap_range+0xac>
ffffffffc02025f8:	6118                	ld	a4,0(a0)
ffffffffc02025fa:	ef11                	bnez	a4,ffffffffc0202616 <unmap_range+0x70>
ffffffffc02025fc:	944e                	add	s0,s0,s3
ffffffffc02025fe:	c019                	beqz	s0,ffffffffc0202604 <unmap_range+0x5e>
ffffffffc0202600:	fe9465e3          	bltu	s0,s1,ffffffffc02025ea <unmap_range+0x44>
ffffffffc0202604:	60a6                	ld	ra,72(sp)
ffffffffc0202606:	6406                	ld	s0,64(sp)
ffffffffc0202608:	74e2                	ld	s1,56(sp)
ffffffffc020260a:	7942                	ld	s2,48(sp)
ffffffffc020260c:	79a2                	ld	s3,40(sp)
ffffffffc020260e:	7a02                	ld	s4,32(sp)
ffffffffc0202610:	6ae2                	ld	s5,24(sp)
ffffffffc0202612:	6161                	addi	sp,sp,80
ffffffffc0202614:	8082                	ret
ffffffffc0202616:	00177693          	andi	a3,a4,1
ffffffffc020261a:	d2ed                	beqz	a3,ffffffffc02025fc <unmap_range+0x56>
ffffffffc020261c:	00094697          	auipc	a3,0x94
ffffffffc0202620:	2946b683          	ld	a3,660(a3) # ffffffffc02968b0 <npage>
ffffffffc0202624:	070a                	slli	a4,a4,0x2
ffffffffc0202626:	8331                	srli	a4,a4,0xc
ffffffffc0202628:	0ad77763          	bgeu	a4,a3,ffffffffc02026d6 <unmap_range+0x130>
ffffffffc020262c:	00094517          	auipc	a0,0x94
ffffffffc0202630:	28c53503          	ld	a0,652(a0) # ffffffffc02968b8 <pages>
ffffffffc0202634:	071a                	slli	a4,a4,0x6
ffffffffc0202636:	fe0006b7          	lui	a3,0xfe000
ffffffffc020263a:	9736                	add	a4,a4,a3
ffffffffc020263c:	953a                	add	a0,a0,a4
ffffffffc020263e:	4118                	lw	a4,0(a0)
ffffffffc0202640:	377d                	addiw	a4,a4,-1 # fffffffffdffffff <end+0x3dd696ef>
ffffffffc0202642:	c118                	sw	a4,0(a0)
ffffffffc0202644:	cb19                	beqz	a4,ffffffffc020265a <unmap_range+0xb4>
ffffffffc0202646:	0007b023          	sd	zero,0(a5)
ffffffffc020264a:	12040073          	sfence.vma	s0
ffffffffc020264e:	944e                	add	s0,s0,s3
ffffffffc0202650:	b77d                	j	ffffffffc02025fe <unmap_range+0x58>
ffffffffc0202652:	9452                	add	s0,s0,s4
ffffffffc0202654:	01547433          	and	s0,s0,s5
ffffffffc0202658:	b75d                	j	ffffffffc02025fe <unmap_range+0x58>
ffffffffc020265a:	10002773          	csrr	a4,sstatus
ffffffffc020265e:	8b09                	andi	a4,a4,2
ffffffffc0202660:	eb19                	bnez	a4,ffffffffc0202676 <unmap_range+0xd0>
ffffffffc0202662:	00094717          	auipc	a4,0x94
ffffffffc0202666:	22e73703          	ld	a4,558(a4) # ffffffffc0296890 <pmm_manager>
ffffffffc020266a:	4585                	li	a1,1
ffffffffc020266c:	e03e                	sd	a5,0(sp)
ffffffffc020266e:	7318                	ld	a4,32(a4)
ffffffffc0202670:	9702                	jalr	a4
ffffffffc0202672:	6782                	ld	a5,0(sp)
ffffffffc0202674:	bfc9                	j	ffffffffc0202646 <unmap_range+0xa0>
ffffffffc0202676:	e43e                	sd	a5,8(sp)
ffffffffc0202678:	e02a                	sd	a0,0(sp)
ffffffffc020267a:	d5efe0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc020267e:	00094717          	auipc	a4,0x94
ffffffffc0202682:	21273703          	ld	a4,530(a4) # ffffffffc0296890 <pmm_manager>
ffffffffc0202686:	6502                	ld	a0,0(sp)
ffffffffc0202688:	4585                	li	a1,1
ffffffffc020268a:	7318                	ld	a4,32(a4)
ffffffffc020268c:	9702                	jalr	a4
ffffffffc020268e:	d44fe0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0202692:	67a2                	ld	a5,8(sp)
ffffffffc0202694:	bf4d                	j	ffffffffc0202646 <unmap_range+0xa0>
ffffffffc0202696:	0000a697          	auipc	a3,0xa
ffffffffc020269a:	1a268693          	addi	a3,a3,418 # ffffffffc020c838 <etext+0xfd8>
ffffffffc020269e:	00009617          	auipc	a2,0x9
ffffffffc02026a2:	5fa60613          	addi	a2,a2,1530 # ffffffffc020bc98 <etext+0x438>
ffffffffc02026a6:	15b00593          	li	a1,347
ffffffffc02026aa:	0000a517          	auipc	a0,0xa
ffffffffc02026ae:	15650513          	addi	a0,a0,342 # ffffffffc020c800 <etext+0xfa0>
ffffffffc02026b2:	d99fd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02026b6:	0000a697          	auipc	a3,0xa
ffffffffc02026ba:	1b268693          	addi	a3,a3,434 # ffffffffc020c868 <etext+0x1008>
ffffffffc02026be:	00009617          	auipc	a2,0x9
ffffffffc02026c2:	5da60613          	addi	a2,a2,1498 # ffffffffc020bc98 <etext+0x438>
ffffffffc02026c6:	15c00593          	li	a1,348
ffffffffc02026ca:	0000a517          	auipc	a0,0xa
ffffffffc02026ce:	13650513          	addi	a0,a0,310 # ffffffffc020c800 <etext+0xfa0>
ffffffffc02026d2:	d79fd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02026d6:	a93ff0ef          	jal	ffffffffc0202168 <pa2page.part.0>

ffffffffc02026da <exit_range>:
ffffffffc02026da:	7135                	addi	sp,sp,-160
ffffffffc02026dc:	00c5e7b3          	or	a5,a1,a2
ffffffffc02026e0:	ed06                	sd	ra,152(sp)
ffffffffc02026e2:	e922                	sd	s0,144(sp)
ffffffffc02026e4:	e526                	sd	s1,136(sp)
ffffffffc02026e6:	e14a                	sd	s2,128(sp)
ffffffffc02026e8:	fcce                	sd	s3,120(sp)
ffffffffc02026ea:	f8d2                	sd	s4,112(sp)
ffffffffc02026ec:	f4d6                	sd	s5,104(sp)
ffffffffc02026ee:	f0da                	sd	s6,96(sp)
ffffffffc02026f0:	ecde                	sd	s7,88(sp)
ffffffffc02026f2:	17d2                	slli	a5,a5,0x34
ffffffffc02026f4:	22079263          	bnez	a5,ffffffffc0202918 <exit_range+0x23e>
ffffffffc02026f8:	00200937          	lui	s2,0x200
ffffffffc02026fc:	00c5b7b3          	sltu	a5,a1,a2
ffffffffc0202700:	0125b733          	sltu	a4,a1,s2
ffffffffc0202704:	0017b793          	seqz	a5,a5
ffffffffc0202708:	8fd9                	or	a5,a5,a4
ffffffffc020270a:	26079263          	bnez	a5,ffffffffc020296e <exit_range+0x294>
ffffffffc020270e:	4785                	li	a5,1
ffffffffc0202710:	07fe                	slli	a5,a5,0x1f
ffffffffc0202712:	0785                	addi	a5,a5,1
ffffffffc0202714:	24f67d63          	bgeu	a2,a5,ffffffffc020296e <exit_range+0x294>
ffffffffc0202718:	c00004b7          	lui	s1,0xc0000
ffffffffc020271c:	ffe007b7          	lui	a5,0xffe00
ffffffffc0202720:	8a2a                	mv	s4,a0
ffffffffc0202722:	8ced                	and	s1,s1,a1
ffffffffc0202724:	00f5f833          	and	a6,a1,a5
ffffffffc0202728:	00094a97          	auipc	s5,0x94
ffffffffc020272c:	188a8a93          	addi	s5,s5,392 # ffffffffc02968b0 <npage>
ffffffffc0202730:	400009b7          	lui	s3,0x40000
ffffffffc0202734:	a809                	j	ffffffffc0202746 <exit_range+0x6c>
ffffffffc0202736:	013487b3          	add	a5,s1,s3
ffffffffc020273a:	400004b7          	lui	s1,0x40000
ffffffffc020273e:	8826                	mv	a6,s1
ffffffffc0202740:	c3f1                	beqz	a5,ffffffffc0202804 <exit_range+0x12a>
ffffffffc0202742:	0cc7f163          	bgeu	a5,a2,ffffffffc0202804 <exit_range+0x12a>
ffffffffc0202746:	01e4d413          	srli	s0,s1,0x1e
ffffffffc020274a:	1ff47413          	andi	s0,s0,511
ffffffffc020274e:	040e                	slli	s0,s0,0x3
ffffffffc0202750:	9452                	add	s0,s0,s4
ffffffffc0202752:	00043883          	ld	a7,0(s0)
ffffffffc0202756:	0018f793          	andi	a5,a7,1
ffffffffc020275a:	dff1                	beqz	a5,ffffffffc0202736 <exit_range+0x5c>
ffffffffc020275c:	000ab783          	ld	a5,0(s5)
ffffffffc0202760:	088a                	slli	a7,a7,0x2
ffffffffc0202762:	00c8d893          	srli	a7,a7,0xc
ffffffffc0202766:	20f8f263          	bgeu	a7,a5,ffffffffc020296a <exit_range+0x290>
ffffffffc020276a:	fff802b7          	lui	t0,0xfff80
ffffffffc020276e:	00588f33          	add	t5,a7,t0
ffffffffc0202772:	000803b7          	lui	t2,0x80
ffffffffc0202776:	007f0733          	add	a4,t5,t2
ffffffffc020277a:	00c71e13          	slli	t3,a4,0xc
ffffffffc020277e:	0f1a                	slli	t5,t5,0x6
ffffffffc0202780:	1cf77863          	bgeu	a4,a5,ffffffffc0202950 <exit_range+0x276>
ffffffffc0202784:	00094f97          	auipc	t6,0x94
ffffffffc0202788:	124f8f93          	addi	t6,t6,292 # ffffffffc02968a8 <va_pa_offset>
ffffffffc020278c:	000fb783          	ld	a5,0(t6)
ffffffffc0202790:	4e85                	li	t4,1
ffffffffc0202792:	6b05                	lui	s6,0x1
ffffffffc0202794:	9e3e                	add	t3,t3,a5
ffffffffc0202796:	01348333          	add	t1,s1,s3
ffffffffc020279a:	01585713          	srli	a4,a6,0x15
ffffffffc020279e:	1ff77713          	andi	a4,a4,511
ffffffffc02027a2:	070e                	slli	a4,a4,0x3
ffffffffc02027a4:	9772                	add	a4,a4,t3
ffffffffc02027a6:	631c                	ld	a5,0(a4)
ffffffffc02027a8:	0017f693          	andi	a3,a5,1
ffffffffc02027ac:	e6bd                	bnez	a3,ffffffffc020281a <exit_range+0x140>
ffffffffc02027ae:	4e81                	li	t4,0
ffffffffc02027b0:	984a                	add	a6,a6,s2
ffffffffc02027b2:	00080863          	beqz	a6,ffffffffc02027c2 <exit_range+0xe8>
ffffffffc02027b6:	879a                	mv	a5,t1
ffffffffc02027b8:	00667363          	bgeu	a2,t1,ffffffffc02027be <exit_range+0xe4>
ffffffffc02027bc:	87b2                	mv	a5,a2
ffffffffc02027be:	fcf86ee3          	bltu	a6,a5,ffffffffc020279a <exit_range+0xc0>
ffffffffc02027c2:	f60e8ae3          	beqz	t4,ffffffffc0202736 <exit_range+0x5c>
ffffffffc02027c6:	000ab783          	ld	a5,0(s5)
ffffffffc02027ca:	1af8f063          	bgeu	a7,a5,ffffffffc020296a <exit_range+0x290>
ffffffffc02027ce:	00094517          	auipc	a0,0x94
ffffffffc02027d2:	0ea53503          	ld	a0,234(a0) # ffffffffc02968b8 <pages>
ffffffffc02027d6:	957a                	add	a0,a0,t5
ffffffffc02027d8:	100027f3          	csrr	a5,sstatus
ffffffffc02027dc:	8b89                	andi	a5,a5,2
ffffffffc02027de:	10079b63          	bnez	a5,ffffffffc02028f4 <exit_range+0x21a>
ffffffffc02027e2:	00094797          	auipc	a5,0x94
ffffffffc02027e6:	0ae7b783          	ld	a5,174(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc02027ea:	4585                	li	a1,1
ffffffffc02027ec:	e432                	sd	a2,8(sp)
ffffffffc02027ee:	739c                	ld	a5,32(a5)
ffffffffc02027f0:	9782                	jalr	a5
ffffffffc02027f2:	6622                	ld	a2,8(sp)
ffffffffc02027f4:	00043023          	sd	zero,0(s0)
ffffffffc02027f8:	013487b3          	add	a5,s1,s3
ffffffffc02027fc:	400004b7          	lui	s1,0x40000
ffffffffc0202800:	8826                	mv	a6,s1
ffffffffc0202802:	f3a1                	bnez	a5,ffffffffc0202742 <exit_range+0x68>
ffffffffc0202804:	60ea                	ld	ra,152(sp)
ffffffffc0202806:	644a                	ld	s0,144(sp)
ffffffffc0202808:	64aa                	ld	s1,136(sp)
ffffffffc020280a:	690a                	ld	s2,128(sp)
ffffffffc020280c:	79e6                	ld	s3,120(sp)
ffffffffc020280e:	7a46                	ld	s4,112(sp)
ffffffffc0202810:	7aa6                	ld	s5,104(sp)
ffffffffc0202812:	7b06                	ld	s6,96(sp)
ffffffffc0202814:	6be6                	ld	s7,88(sp)
ffffffffc0202816:	610d                	addi	sp,sp,160
ffffffffc0202818:	8082                	ret
ffffffffc020281a:	000ab503          	ld	a0,0(s5)
ffffffffc020281e:	078a                	slli	a5,a5,0x2
ffffffffc0202820:	83b1                	srli	a5,a5,0xc
ffffffffc0202822:	14a7f463          	bgeu	a5,a0,ffffffffc020296a <exit_range+0x290>
ffffffffc0202826:	9796                	add	a5,a5,t0
ffffffffc0202828:	00778bb3          	add	s7,a5,t2
ffffffffc020282c:	00679593          	slli	a1,a5,0x6
ffffffffc0202830:	00cb9693          	slli	a3,s7,0xc
ffffffffc0202834:	10abf263          	bgeu	s7,a0,ffffffffc0202938 <exit_range+0x25e>
ffffffffc0202838:	000fb783          	ld	a5,0(t6)
ffffffffc020283c:	96be                	add	a3,a3,a5
ffffffffc020283e:	01668533          	add	a0,a3,s6
ffffffffc0202842:	629c                	ld	a5,0(a3)
ffffffffc0202844:	8b85                	andi	a5,a5,1
ffffffffc0202846:	f7ad                	bnez	a5,ffffffffc02027b0 <exit_range+0xd6>
ffffffffc0202848:	06a1                	addi	a3,a3,8
ffffffffc020284a:	fea69ce3          	bne	a3,a0,ffffffffc0202842 <exit_range+0x168>
ffffffffc020284e:	00094517          	auipc	a0,0x94
ffffffffc0202852:	06a53503          	ld	a0,106(a0) # ffffffffc02968b8 <pages>
ffffffffc0202856:	952e                	add	a0,a0,a1
ffffffffc0202858:	100027f3          	csrr	a5,sstatus
ffffffffc020285c:	8b89                	andi	a5,a5,2
ffffffffc020285e:	e3b9                	bnez	a5,ffffffffc02028a4 <exit_range+0x1ca>
ffffffffc0202860:	00094797          	auipc	a5,0x94
ffffffffc0202864:	0307b783          	ld	a5,48(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc0202868:	4585                	li	a1,1
ffffffffc020286a:	e0b2                	sd	a2,64(sp)
ffffffffc020286c:	739c                	ld	a5,32(a5)
ffffffffc020286e:	fc1a                	sd	t1,56(sp)
ffffffffc0202870:	f846                	sd	a7,48(sp)
ffffffffc0202872:	f47a                	sd	t5,40(sp)
ffffffffc0202874:	f072                	sd	t3,32(sp)
ffffffffc0202876:	ec76                	sd	t4,24(sp)
ffffffffc0202878:	e842                	sd	a6,16(sp)
ffffffffc020287a:	e43a                	sd	a4,8(sp)
ffffffffc020287c:	9782                	jalr	a5
ffffffffc020287e:	6722                	ld	a4,8(sp)
ffffffffc0202880:	6842                	ld	a6,16(sp)
ffffffffc0202882:	6ee2                	ld	t4,24(sp)
ffffffffc0202884:	7e02                	ld	t3,32(sp)
ffffffffc0202886:	7f22                	ld	t5,40(sp)
ffffffffc0202888:	78c2                	ld	a7,48(sp)
ffffffffc020288a:	7362                	ld	t1,56(sp)
ffffffffc020288c:	6606                	ld	a2,64(sp)
ffffffffc020288e:	fff802b7          	lui	t0,0xfff80
ffffffffc0202892:	000803b7          	lui	t2,0x80
ffffffffc0202896:	00094f97          	auipc	t6,0x94
ffffffffc020289a:	012f8f93          	addi	t6,t6,18 # ffffffffc02968a8 <va_pa_offset>
ffffffffc020289e:	00073023          	sd	zero,0(a4)
ffffffffc02028a2:	b739                	j	ffffffffc02027b0 <exit_range+0xd6>
ffffffffc02028a4:	e4b2                	sd	a2,72(sp)
ffffffffc02028a6:	e09a                	sd	t1,64(sp)
ffffffffc02028a8:	fc46                	sd	a7,56(sp)
ffffffffc02028aa:	f47a                	sd	t5,40(sp)
ffffffffc02028ac:	f072                	sd	t3,32(sp)
ffffffffc02028ae:	ec76                	sd	t4,24(sp)
ffffffffc02028b0:	e842                	sd	a6,16(sp)
ffffffffc02028b2:	e43a                	sd	a4,8(sp)
ffffffffc02028b4:	f82a                	sd	a0,48(sp)
ffffffffc02028b6:	b22fe0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc02028ba:	00094797          	auipc	a5,0x94
ffffffffc02028be:	fd67b783          	ld	a5,-42(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc02028c2:	7542                	ld	a0,48(sp)
ffffffffc02028c4:	4585                	li	a1,1
ffffffffc02028c6:	739c                	ld	a5,32(a5)
ffffffffc02028c8:	9782                	jalr	a5
ffffffffc02028ca:	b08fe0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc02028ce:	6722                	ld	a4,8(sp)
ffffffffc02028d0:	6626                	ld	a2,72(sp)
ffffffffc02028d2:	6306                	ld	t1,64(sp)
ffffffffc02028d4:	78e2                	ld	a7,56(sp)
ffffffffc02028d6:	7f22                	ld	t5,40(sp)
ffffffffc02028d8:	7e02                	ld	t3,32(sp)
ffffffffc02028da:	6ee2                	ld	t4,24(sp)
ffffffffc02028dc:	6842                	ld	a6,16(sp)
ffffffffc02028de:	00094f97          	auipc	t6,0x94
ffffffffc02028e2:	fcaf8f93          	addi	t6,t6,-54 # ffffffffc02968a8 <va_pa_offset>
ffffffffc02028e6:	000803b7          	lui	t2,0x80
ffffffffc02028ea:	fff802b7          	lui	t0,0xfff80
ffffffffc02028ee:	00073023          	sd	zero,0(a4)
ffffffffc02028f2:	bd7d                	j	ffffffffc02027b0 <exit_range+0xd6>
ffffffffc02028f4:	e832                	sd	a2,16(sp)
ffffffffc02028f6:	e42a                	sd	a0,8(sp)
ffffffffc02028f8:	ae0fe0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc02028fc:	00094797          	auipc	a5,0x94
ffffffffc0202900:	f947b783          	ld	a5,-108(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc0202904:	6522                	ld	a0,8(sp)
ffffffffc0202906:	4585                	li	a1,1
ffffffffc0202908:	739c                	ld	a5,32(a5)
ffffffffc020290a:	9782                	jalr	a5
ffffffffc020290c:	ac6fe0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0202910:	6642                	ld	a2,16(sp)
ffffffffc0202912:	00043023          	sd	zero,0(s0)
ffffffffc0202916:	b5cd                	j	ffffffffc02027f8 <exit_range+0x11e>
ffffffffc0202918:	0000a697          	auipc	a3,0xa
ffffffffc020291c:	f2068693          	addi	a3,a3,-224 # ffffffffc020c838 <etext+0xfd8>
ffffffffc0202920:	00009617          	auipc	a2,0x9
ffffffffc0202924:	37860613          	addi	a2,a2,888 # ffffffffc020bc98 <etext+0x438>
ffffffffc0202928:	17000593          	li	a1,368
ffffffffc020292c:	0000a517          	auipc	a0,0xa
ffffffffc0202930:	ed450513          	addi	a0,a0,-300 # ffffffffc020c800 <etext+0xfa0>
ffffffffc0202934:	b17fd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0202938:	0000a617          	auipc	a2,0xa
ffffffffc020293c:	dd860613          	addi	a2,a2,-552 # ffffffffc020c710 <etext+0xeb0>
ffffffffc0202940:	07100593          	li	a1,113
ffffffffc0202944:	0000a517          	auipc	a0,0xa
ffffffffc0202948:	df450513          	addi	a0,a0,-524 # ffffffffc020c738 <etext+0xed8>
ffffffffc020294c:	afffd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0202950:	86f2                	mv	a3,t3
ffffffffc0202952:	0000a617          	auipc	a2,0xa
ffffffffc0202956:	dbe60613          	addi	a2,a2,-578 # ffffffffc020c710 <etext+0xeb0>
ffffffffc020295a:	07100593          	li	a1,113
ffffffffc020295e:	0000a517          	auipc	a0,0xa
ffffffffc0202962:	dda50513          	addi	a0,a0,-550 # ffffffffc020c738 <etext+0xed8>
ffffffffc0202966:	ae5fd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc020296a:	ffeff0ef          	jal	ffffffffc0202168 <pa2page.part.0>
ffffffffc020296e:	0000a697          	auipc	a3,0xa
ffffffffc0202972:	efa68693          	addi	a3,a3,-262 # ffffffffc020c868 <etext+0x1008>
ffffffffc0202976:	00009617          	auipc	a2,0x9
ffffffffc020297a:	32260613          	addi	a2,a2,802 # ffffffffc020bc98 <etext+0x438>
ffffffffc020297e:	17100593          	li	a1,369
ffffffffc0202982:	0000a517          	auipc	a0,0xa
ffffffffc0202986:	e7e50513          	addi	a0,a0,-386 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020298a:	ac1fd0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020298e <page_remove>:
ffffffffc020298e:	1101                	addi	sp,sp,-32
ffffffffc0202990:	4601                	li	a2,0
ffffffffc0202992:	e822                	sd	s0,16(sp)
ffffffffc0202994:	ec06                	sd	ra,24(sp)
ffffffffc0202996:	842e                	mv	s0,a1
ffffffffc0202998:	895ff0ef          	jal	ffffffffc020222c <get_pte>
ffffffffc020299c:	c511                	beqz	a0,ffffffffc02029a8 <page_remove+0x1a>
ffffffffc020299e:	6118                	ld	a4,0(a0)
ffffffffc02029a0:	87aa                	mv	a5,a0
ffffffffc02029a2:	00177693          	andi	a3,a4,1
ffffffffc02029a6:	e689                	bnez	a3,ffffffffc02029b0 <page_remove+0x22>
ffffffffc02029a8:	60e2                	ld	ra,24(sp)
ffffffffc02029aa:	6442                	ld	s0,16(sp)
ffffffffc02029ac:	6105                	addi	sp,sp,32
ffffffffc02029ae:	8082                	ret
ffffffffc02029b0:	00094697          	auipc	a3,0x94
ffffffffc02029b4:	f006b683          	ld	a3,-256(a3) # ffffffffc02968b0 <npage>
ffffffffc02029b8:	070a                	slli	a4,a4,0x2
ffffffffc02029ba:	8331                	srli	a4,a4,0xc
ffffffffc02029bc:	06d77563          	bgeu	a4,a3,ffffffffc0202a26 <page_remove+0x98>
ffffffffc02029c0:	00094517          	auipc	a0,0x94
ffffffffc02029c4:	ef853503          	ld	a0,-264(a0) # ffffffffc02968b8 <pages>
ffffffffc02029c8:	071a                	slli	a4,a4,0x6
ffffffffc02029ca:	fe0006b7          	lui	a3,0xfe000
ffffffffc02029ce:	9736                	add	a4,a4,a3
ffffffffc02029d0:	953a                	add	a0,a0,a4
ffffffffc02029d2:	4118                	lw	a4,0(a0)
ffffffffc02029d4:	377d                	addiw	a4,a4,-1
ffffffffc02029d6:	c118                	sw	a4,0(a0)
ffffffffc02029d8:	cb09                	beqz	a4,ffffffffc02029ea <page_remove+0x5c>
ffffffffc02029da:	0007b023          	sd	zero,0(a5)
ffffffffc02029de:	12040073          	sfence.vma	s0
ffffffffc02029e2:	60e2                	ld	ra,24(sp)
ffffffffc02029e4:	6442                	ld	s0,16(sp)
ffffffffc02029e6:	6105                	addi	sp,sp,32
ffffffffc02029e8:	8082                	ret
ffffffffc02029ea:	10002773          	csrr	a4,sstatus
ffffffffc02029ee:	8b09                	andi	a4,a4,2
ffffffffc02029f0:	eb19                	bnez	a4,ffffffffc0202a06 <page_remove+0x78>
ffffffffc02029f2:	00094717          	auipc	a4,0x94
ffffffffc02029f6:	e9e73703          	ld	a4,-354(a4) # ffffffffc0296890 <pmm_manager>
ffffffffc02029fa:	4585                	li	a1,1
ffffffffc02029fc:	e03e                	sd	a5,0(sp)
ffffffffc02029fe:	7318                	ld	a4,32(a4)
ffffffffc0202a00:	9702                	jalr	a4
ffffffffc0202a02:	6782                	ld	a5,0(sp)
ffffffffc0202a04:	bfd9                	j	ffffffffc02029da <page_remove+0x4c>
ffffffffc0202a06:	e43e                	sd	a5,8(sp)
ffffffffc0202a08:	e02a                	sd	a0,0(sp)
ffffffffc0202a0a:	9cefe0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0202a0e:	00094717          	auipc	a4,0x94
ffffffffc0202a12:	e8273703          	ld	a4,-382(a4) # ffffffffc0296890 <pmm_manager>
ffffffffc0202a16:	6502                	ld	a0,0(sp)
ffffffffc0202a18:	4585                	li	a1,1
ffffffffc0202a1a:	7318                	ld	a4,32(a4)
ffffffffc0202a1c:	9702                	jalr	a4
ffffffffc0202a1e:	9b4fe0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0202a22:	67a2                	ld	a5,8(sp)
ffffffffc0202a24:	bf5d                	j	ffffffffc02029da <page_remove+0x4c>
ffffffffc0202a26:	f42ff0ef          	jal	ffffffffc0202168 <pa2page.part.0>

ffffffffc0202a2a <page_insert>:
ffffffffc0202a2a:	7139                	addi	sp,sp,-64
ffffffffc0202a2c:	f426                	sd	s1,40(sp)
ffffffffc0202a2e:	84b2                	mv	s1,a2
ffffffffc0202a30:	f822                	sd	s0,48(sp)
ffffffffc0202a32:	4605                	li	a2,1
ffffffffc0202a34:	842e                	mv	s0,a1
ffffffffc0202a36:	85a6                	mv	a1,s1
ffffffffc0202a38:	fc06                	sd	ra,56(sp)
ffffffffc0202a3a:	e436                	sd	a3,8(sp)
ffffffffc0202a3c:	ff0ff0ef          	jal	ffffffffc020222c <get_pte>
ffffffffc0202a40:	cd61                	beqz	a0,ffffffffc0202b18 <page_insert+0xee>
ffffffffc0202a42:	400c                	lw	a1,0(s0)
ffffffffc0202a44:	611c                	ld	a5,0(a0)
ffffffffc0202a46:	66a2                	ld	a3,8(sp)
ffffffffc0202a48:	0015861b          	addiw	a2,a1,1 # 1001 <_binary_bin_swap_img_size-0x6cff>
ffffffffc0202a4c:	c010                	sw	a2,0(s0)
ffffffffc0202a4e:	0017f613          	andi	a2,a5,1
ffffffffc0202a52:	872a                	mv	a4,a0
ffffffffc0202a54:	e61d                	bnez	a2,ffffffffc0202a82 <page_insert+0x58>
ffffffffc0202a56:	00094617          	auipc	a2,0x94
ffffffffc0202a5a:	e6263603          	ld	a2,-414(a2) # ffffffffc02968b8 <pages>
ffffffffc0202a5e:	8c11                	sub	s0,s0,a2
ffffffffc0202a60:	8419                	srai	s0,s0,0x6
ffffffffc0202a62:	200007b7          	lui	a5,0x20000
ffffffffc0202a66:	042a                	slli	s0,s0,0xa
ffffffffc0202a68:	943e                	add	s0,s0,a5
ffffffffc0202a6a:	8ec1                	or	a3,a3,s0
ffffffffc0202a6c:	0016e693          	ori	a3,a3,1
ffffffffc0202a70:	e314                	sd	a3,0(a4)
ffffffffc0202a72:	12048073          	sfence.vma	s1
ffffffffc0202a76:	4501                	li	a0,0
ffffffffc0202a78:	70e2                	ld	ra,56(sp)
ffffffffc0202a7a:	7442                	ld	s0,48(sp)
ffffffffc0202a7c:	74a2                	ld	s1,40(sp)
ffffffffc0202a7e:	6121                	addi	sp,sp,64
ffffffffc0202a80:	8082                	ret
ffffffffc0202a82:	00094617          	auipc	a2,0x94
ffffffffc0202a86:	e2e63603          	ld	a2,-466(a2) # ffffffffc02968b0 <npage>
ffffffffc0202a8a:	078a                	slli	a5,a5,0x2
ffffffffc0202a8c:	83b1                	srli	a5,a5,0xc
ffffffffc0202a8e:	08c7f763          	bgeu	a5,a2,ffffffffc0202b1c <page_insert+0xf2>
ffffffffc0202a92:	00094617          	auipc	a2,0x94
ffffffffc0202a96:	e2663603          	ld	a2,-474(a2) # ffffffffc02968b8 <pages>
ffffffffc0202a9a:	fe000537          	lui	a0,0xfe000
ffffffffc0202a9e:	079a                	slli	a5,a5,0x6
ffffffffc0202aa0:	97aa                	add	a5,a5,a0
ffffffffc0202aa2:	00f60533          	add	a0,a2,a5
ffffffffc0202aa6:	00a40963          	beq	s0,a0,ffffffffc0202ab8 <page_insert+0x8e>
ffffffffc0202aaa:	411c                	lw	a5,0(a0)
ffffffffc0202aac:	37fd                	addiw	a5,a5,-1 # 1fffffff <_binary_bin_sfs_img_size+0x1ff8acff>
ffffffffc0202aae:	c11c                	sw	a5,0(a0)
ffffffffc0202ab0:	c791                	beqz	a5,ffffffffc0202abc <page_insert+0x92>
ffffffffc0202ab2:	12048073          	sfence.vma	s1
ffffffffc0202ab6:	b765                	j	ffffffffc0202a5e <page_insert+0x34>
ffffffffc0202ab8:	c00c                	sw	a1,0(s0)
ffffffffc0202aba:	b755                	j	ffffffffc0202a5e <page_insert+0x34>
ffffffffc0202abc:	100027f3          	csrr	a5,sstatus
ffffffffc0202ac0:	8b89                	andi	a5,a5,2
ffffffffc0202ac2:	e39d                	bnez	a5,ffffffffc0202ae8 <page_insert+0xbe>
ffffffffc0202ac4:	00094797          	auipc	a5,0x94
ffffffffc0202ac8:	dcc7b783          	ld	a5,-564(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc0202acc:	4585                	li	a1,1
ffffffffc0202ace:	e83a                	sd	a4,16(sp)
ffffffffc0202ad0:	739c                	ld	a5,32(a5)
ffffffffc0202ad2:	e436                	sd	a3,8(sp)
ffffffffc0202ad4:	9782                	jalr	a5
ffffffffc0202ad6:	00094617          	auipc	a2,0x94
ffffffffc0202ada:	de263603          	ld	a2,-542(a2) # ffffffffc02968b8 <pages>
ffffffffc0202ade:	66a2                	ld	a3,8(sp)
ffffffffc0202ae0:	6742                	ld	a4,16(sp)
ffffffffc0202ae2:	12048073          	sfence.vma	s1
ffffffffc0202ae6:	bfa5                	j	ffffffffc0202a5e <page_insert+0x34>
ffffffffc0202ae8:	ec3a                	sd	a4,24(sp)
ffffffffc0202aea:	e836                	sd	a3,16(sp)
ffffffffc0202aec:	e42a                	sd	a0,8(sp)
ffffffffc0202aee:	8eafe0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0202af2:	00094797          	auipc	a5,0x94
ffffffffc0202af6:	d9e7b783          	ld	a5,-610(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc0202afa:	6522                	ld	a0,8(sp)
ffffffffc0202afc:	4585                	li	a1,1
ffffffffc0202afe:	739c                	ld	a5,32(a5)
ffffffffc0202b00:	9782                	jalr	a5
ffffffffc0202b02:	8d0fe0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0202b06:	00094617          	auipc	a2,0x94
ffffffffc0202b0a:	db263603          	ld	a2,-590(a2) # ffffffffc02968b8 <pages>
ffffffffc0202b0e:	6762                	ld	a4,24(sp)
ffffffffc0202b10:	66c2                	ld	a3,16(sp)
ffffffffc0202b12:	12048073          	sfence.vma	s1
ffffffffc0202b16:	b7a1                	j	ffffffffc0202a5e <page_insert+0x34>
ffffffffc0202b18:	5571                	li	a0,-4
ffffffffc0202b1a:	bfb9                	j	ffffffffc0202a78 <page_insert+0x4e>
ffffffffc0202b1c:	e4cff0ef          	jal	ffffffffc0202168 <pa2page.part.0>

ffffffffc0202b20 <pmm_init>:
ffffffffc0202b20:	0000c797          	auipc	a5,0xc
ffffffffc0202b24:	43078793          	addi	a5,a5,1072 # ffffffffc020ef50 <default_pmm_manager>
ffffffffc0202b28:	638c                	ld	a1,0(a5)
ffffffffc0202b2a:	7159                	addi	sp,sp,-112
ffffffffc0202b2c:	f486                	sd	ra,104(sp)
ffffffffc0202b2e:	e8ca                	sd	s2,80(sp)
ffffffffc0202b30:	e4ce                	sd	s3,72(sp)
ffffffffc0202b32:	f85a                	sd	s6,48(sp)
ffffffffc0202b34:	f0a2                	sd	s0,96(sp)
ffffffffc0202b36:	eca6                	sd	s1,88(sp)
ffffffffc0202b38:	e0d2                	sd	s4,64(sp)
ffffffffc0202b3a:	fc56                	sd	s5,56(sp)
ffffffffc0202b3c:	f45e                	sd	s7,40(sp)
ffffffffc0202b3e:	f062                	sd	s8,32(sp)
ffffffffc0202b40:	ec66                	sd	s9,24(sp)
ffffffffc0202b42:	00094b17          	auipc	s6,0x94
ffffffffc0202b46:	d4eb0b13          	addi	s6,s6,-690 # ffffffffc0296890 <pmm_manager>
ffffffffc0202b4a:	0000a517          	auipc	a0,0xa
ffffffffc0202b4e:	d3650513          	addi	a0,a0,-714 # ffffffffc020c880 <etext+0x1020>
ffffffffc0202b52:	00fb3023          	sd	a5,0(s6)
ffffffffc0202b56:	e50fd0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0202b5a:	000b3783          	ld	a5,0(s6)
ffffffffc0202b5e:	00094997          	auipc	s3,0x94
ffffffffc0202b62:	d4a98993          	addi	s3,s3,-694 # ffffffffc02968a8 <va_pa_offset>
ffffffffc0202b66:	679c                	ld	a5,8(a5)
ffffffffc0202b68:	9782                	jalr	a5
ffffffffc0202b6a:	57f5                	li	a5,-3
ffffffffc0202b6c:	07fa                	slli	a5,a5,0x1e
ffffffffc0202b6e:	00f9b023          	sd	a5,0(s3)
ffffffffc0202b72:	e37fd0ef          	jal	ffffffffc02009a8 <get_memory_base>
ffffffffc0202b76:	892a                	mv	s2,a0
ffffffffc0202b78:	e3bfd0ef          	jal	ffffffffc02009b2 <get_memory_size>
ffffffffc0202b7c:	4e0506e3          	beqz	a0,ffffffffc0203868 <pmm_init+0xd48>
ffffffffc0202b80:	84aa                	mv	s1,a0
ffffffffc0202b82:	0000a517          	auipc	a0,0xa
ffffffffc0202b86:	d3650513          	addi	a0,a0,-714 # ffffffffc020c8b8 <etext+0x1058>
ffffffffc0202b8a:	e1cfd0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0202b8e:	00990433          	add	s0,s2,s1
ffffffffc0202b92:	864a                	mv	a2,s2
ffffffffc0202b94:	85a6                	mv	a1,s1
ffffffffc0202b96:	fff40693          	addi	a3,s0,-1
ffffffffc0202b9a:	0000a517          	auipc	a0,0xa
ffffffffc0202b9e:	d3650513          	addi	a0,a0,-714 # ffffffffc020c8d0 <etext+0x1070>
ffffffffc0202ba2:	e04fd0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0202ba6:	c80007b7          	lui	a5,0xc8000
ffffffffc0202baa:	8522                	mv	a0,s0
ffffffffc0202bac:	6087e463          	bltu	a5,s0,ffffffffc02031b4 <pmm_init+0x694>
ffffffffc0202bb0:	77fd                	lui	a5,0xfffff
ffffffffc0202bb2:	00095617          	auipc	a2,0x95
ffffffffc0202bb6:	d5d60613          	addi	a2,a2,-675 # ffffffffc029790f <end+0xfff>
ffffffffc0202bba:	8e7d                	and	a2,a2,a5
ffffffffc0202bbc:	8131                	srli	a0,a0,0xc
ffffffffc0202bbe:	00094b97          	auipc	s7,0x94
ffffffffc0202bc2:	cfab8b93          	addi	s7,s7,-774 # ffffffffc02968b8 <pages>
ffffffffc0202bc6:	00094497          	auipc	s1,0x94
ffffffffc0202bca:	cea48493          	addi	s1,s1,-790 # ffffffffc02968b0 <npage>
ffffffffc0202bce:	00cbb023          	sd	a2,0(s7)
ffffffffc0202bd2:	e088                	sd	a0,0(s1)
ffffffffc0202bd4:	000807b7          	lui	a5,0x80
ffffffffc0202bd8:	86b2                	mv	a3,a2
ffffffffc0202bda:	02f50763          	beq	a0,a5,ffffffffc0202c08 <pmm_init+0xe8>
ffffffffc0202bde:	4701                	li	a4,0
ffffffffc0202be0:	4585                	li	a1,1
ffffffffc0202be2:	fff806b7          	lui	a3,0xfff80
ffffffffc0202be6:	00671793          	slli	a5,a4,0x6
ffffffffc0202bea:	97b2                	add	a5,a5,a2
ffffffffc0202bec:	07a1                	addi	a5,a5,8 # 80008 <_binary_bin_sfs_img_size+0xad08>
ffffffffc0202bee:	40b7b02f          	amoor.d	zero,a1,(a5)
ffffffffc0202bf2:	6088                	ld	a0,0(s1)
ffffffffc0202bf4:	0705                	addi	a4,a4,1
ffffffffc0202bf6:	000bb603          	ld	a2,0(s7)
ffffffffc0202bfa:	00d507b3          	add	a5,a0,a3
ffffffffc0202bfe:	fef764e3          	bltu	a4,a5,ffffffffc0202be6 <pmm_init+0xc6>
ffffffffc0202c02:	079a                	slli	a5,a5,0x6
ffffffffc0202c04:	00f606b3          	add	a3,a2,a5
ffffffffc0202c08:	c02007b7          	lui	a5,0xc0200
ffffffffc0202c0c:	3ef6e6e3          	bltu	a3,a5,ffffffffc02037f8 <pmm_init+0xcd8>
ffffffffc0202c10:	0009b583          	ld	a1,0(s3)
ffffffffc0202c14:	77fd                	lui	a5,0xfffff
ffffffffc0202c16:	8c7d                	and	s0,s0,a5
ffffffffc0202c18:	8e8d                	sub	a3,a3,a1
ffffffffc0202c1a:	5a86ea63          	bltu	a3,s0,ffffffffc02031ce <pmm_init+0x6ae>
ffffffffc0202c1e:	0000a517          	auipc	a0,0xa
ffffffffc0202c22:	cda50513          	addi	a0,a0,-806 # ffffffffc020c8f8 <etext+0x1098>
ffffffffc0202c26:	d80fd0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0202c2a:	000b3783          	ld	a5,0(s6)
ffffffffc0202c2e:	7b9c                	ld	a5,48(a5)
ffffffffc0202c30:	9782                	jalr	a5
ffffffffc0202c32:	0000a517          	auipc	a0,0xa
ffffffffc0202c36:	cde50513          	addi	a0,a0,-802 # ffffffffc020c910 <etext+0x10b0>
ffffffffc0202c3a:	d6cfd0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0202c3e:	100027f3          	csrr	a5,sstatus
ffffffffc0202c42:	8b89                	andi	a5,a5,2
ffffffffc0202c44:	56079a63          	bnez	a5,ffffffffc02031b8 <pmm_init+0x698>
ffffffffc0202c48:	000b3783          	ld	a5,0(s6)
ffffffffc0202c4c:	4505                	li	a0,1
ffffffffc0202c4e:	6f9c                	ld	a5,24(a5)
ffffffffc0202c50:	9782                	jalr	a5
ffffffffc0202c52:	842a                	mv	s0,a0
ffffffffc0202c54:	340406e3          	beqz	s0,ffffffffc02037a0 <pmm_init+0xc80>
ffffffffc0202c58:	000bb703          	ld	a4,0(s7)
ffffffffc0202c5c:	000807b7          	lui	a5,0x80
ffffffffc0202c60:	5a7d                	li	s4,-1
ffffffffc0202c62:	40e406b3          	sub	a3,s0,a4
ffffffffc0202c66:	8699                	srai	a3,a3,0x6
ffffffffc0202c68:	6098                	ld	a4,0(s1)
ffffffffc0202c6a:	96be                	add	a3,a3,a5
ffffffffc0202c6c:	00ca5793          	srli	a5,s4,0xc
ffffffffc0202c70:	8ff5                	and	a5,a5,a3
ffffffffc0202c72:	06b2                	slli	a3,a3,0xc
ffffffffc0202c74:	16e7fde3          	bgeu	a5,a4,ffffffffc02035ee <pmm_init+0xace>
ffffffffc0202c78:	0009b783          	ld	a5,0(s3)
ffffffffc0202c7c:	6605                	lui	a2,0x1
ffffffffc0202c7e:	4581                	li	a1,0
ffffffffc0202c80:	00f68433          	add	s0,a3,a5
ffffffffc0202c84:	8522                	mv	a0,s0
ffffffffc0202c86:	373080ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc0202c8a:	0009b683          	ld	a3,0(s3)
ffffffffc0202c8e:	0000a917          	auipc	s2,0xa
ffffffffc0202c92:	bd190913          	addi	s2,s2,-1071 # ffffffffc020c85f <etext+0xfff>
ffffffffc0202c96:	77fd                	lui	a5,0xfffff
ffffffffc0202c98:	c0200ab7          	lui	s5,0xc0200
ffffffffc0202c9c:	00f97933          	and	s2,s2,a5
ffffffffc0202ca0:	3fe00637          	lui	a2,0x3fe00
ffffffffc0202ca4:	40da86b3          	sub	a3,s5,a3
ffffffffc0202ca8:	8522                	mv	a0,s0
ffffffffc0202caa:	964a                	add	a2,a2,s2
ffffffffc0202cac:	85d6                	mv	a1,s5
ffffffffc0202cae:	4729                	li	a4,10
ffffffffc0202cb0:	fdaff0ef          	jal	ffffffffc020248a <boot_map_segment>
ffffffffc0202cb4:	135960e3          	bltu	s2,s5,ffffffffc02035d4 <pmm_init+0xab4>
ffffffffc0202cb8:	0009b683          	ld	a3,0(s3)
ffffffffc0202cbc:	c8000637          	lui	a2,0xc8000
ffffffffc0202cc0:	41260633          	sub	a2,a2,s2
ffffffffc0202cc4:	40d906b3          	sub	a3,s2,a3
ffffffffc0202cc8:	85ca                	mv	a1,s2
ffffffffc0202cca:	4719                	li	a4,6
ffffffffc0202ccc:	8522                	mv	a0,s0
ffffffffc0202cce:	00094917          	auipc	s2,0x94
ffffffffc0202cd2:	bd290913          	addi	s2,s2,-1070 # ffffffffc02968a0 <boot_pgdir_va>
ffffffffc0202cd6:	fb4ff0ef          	jal	ffffffffc020248a <boot_map_segment>
ffffffffc0202cda:	00893023          	sd	s0,0(s2)
ffffffffc0202cde:	3f546de3          	bltu	s0,s5,ffffffffc02038d8 <pmm_init+0xdb8>
ffffffffc0202ce2:	0009b783          	ld	a5,0(s3)
ffffffffc0202ce6:	1a7e                	slli	s4,s4,0x3f
ffffffffc0202ce8:	8c1d                	sub	s0,s0,a5
ffffffffc0202cea:	00c45793          	srli	a5,s0,0xc
ffffffffc0202cee:	00094717          	auipc	a4,0x94
ffffffffc0202cf2:	ba873523          	sd	s0,-1110(a4) # ffffffffc0296898 <boot_pgdir_pa>
ffffffffc0202cf6:	0147e7b3          	or	a5,a5,s4
ffffffffc0202cfa:	18079073          	csrw	satp,a5
ffffffffc0202cfe:	12000073          	sfence.vma
ffffffffc0202d02:	0000a517          	auipc	a0,0xa
ffffffffc0202d06:	c4e50513          	addi	a0,a0,-946 # ffffffffc020c950 <etext+0x10f0>
ffffffffc0202d0a:	c9cfd0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0202d0e:	0000e717          	auipc	a4,0xe
ffffffffc0202d12:	2f270713          	addi	a4,a4,754 # ffffffffc0211000 <bootstack>
ffffffffc0202d16:	0000e797          	auipc	a5,0xe
ffffffffc0202d1a:	2ea78793          	addi	a5,a5,746 # ffffffffc0211000 <bootstack>
ffffffffc0202d1e:	00f71c63          	bne	a4,a5,ffffffffc0202d36 <pmm_init+0x216>
ffffffffc0202d22:	00010797          	auipc	a5,0x10
ffffffffc0202d26:	2de78793          	addi	a5,a5,734 # ffffffffc0213000 <boot_page_table_sv39>
ffffffffc0202d2a:	00010717          	auipc	a4,0x10
ffffffffc0202d2e:	2d670713          	addi	a4,a4,726 # ffffffffc0213000 <boot_page_table_sv39>
ffffffffc0202d32:	5cf70a63          	beq	a4,a5,ffffffffc0203306 <pmm_init+0x7e6>
ffffffffc0202d36:	100027f3          	csrr	a5,sstatus
ffffffffc0202d3a:	8b89                	andi	a5,a5,2
ffffffffc0202d3c:	4c079c63          	bnez	a5,ffffffffc0203214 <pmm_init+0x6f4>
ffffffffc0202d40:	000b3783          	ld	a5,0(s6)
ffffffffc0202d44:	779c                	ld	a5,40(a5)
ffffffffc0202d46:	9782                	jalr	a5
ffffffffc0202d48:	842a                	mv	s0,a0
ffffffffc0202d4a:	6098                	ld	a4,0(s1)
ffffffffc0202d4c:	c80007b7          	lui	a5,0xc8000
ffffffffc0202d50:	83b1                	srli	a5,a5,0xc
ffffffffc0202d52:	0ae7eae3          	bltu	a5,a4,ffffffffc0203606 <pmm_init+0xae6>
ffffffffc0202d56:	00093503          	ld	a0,0(s2)
ffffffffc0202d5a:	26050fe3          	beqz	a0,ffffffffc02037d8 <pmm_init+0xcb8>
ffffffffc0202d5e:	03451793          	slli	a5,a0,0x34
ffffffffc0202d62:	26079be3          	bnez	a5,ffffffffc02037d8 <pmm_init+0xcb8>
ffffffffc0202d66:	4601                	li	a2,0
ffffffffc0202d68:	4581                	li	a1,0
ffffffffc0202d6a:	fe8ff0ef          	jal	ffffffffc0202552 <get_page>
ffffffffc0202d6e:	240515e3          	bnez	a0,ffffffffc02037b8 <pmm_init+0xc98>
ffffffffc0202d72:	100027f3          	csrr	a5,sstatus
ffffffffc0202d76:	8b89                	andi	a5,a5,2
ffffffffc0202d78:	48079363          	bnez	a5,ffffffffc02031fe <pmm_init+0x6de>
ffffffffc0202d7c:	000b3783          	ld	a5,0(s6)
ffffffffc0202d80:	4505                	li	a0,1
ffffffffc0202d82:	6f9c                	ld	a5,24(a5)
ffffffffc0202d84:	9782                	jalr	a5
ffffffffc0202d86:	8a2a                	mv	s4,a0
ffffffffc0202d88:	00093503          	ld	a0,0(s2)
ffffffffc0202d8c:	4681                	li	a3,0
ffffffffc0202d8e:	4601                	li	a2,0
ffffffffc0202d90:	85d2                	mv	a1,s4
ffffffffc0202d92:	c99ff0ef          	jal	ffffffffc0202a2a <page_insert>
ffffffffc0202d96:	26051de3          	bnez	a0,ffffffffc0203810 <pmm_init+0xcf0>
ffffffffc0202d9a:	00093503          	ld	a0,0(s2)
ffffffffc0202d9e:	4601                	li	a2,0
ffffffffc0202da0:	4581                	li	a1,0
ffffffffc0202da2:	c8aff0ef          	jal	ffffffffc020222c <get_pte>
ffffffffc0202da6:	2a0501e3          	beqz	a0,ffffffffc0203848 <pmm_init+0xd28>
ffffffffc0202daa:	611c                	ld	a5,0(a0)
ffffffffc0202dac:	0017f713          	andi	a4,a5,1
ffffffffc0202db0:	280700e3          	beqz	a4,ffffffffc0203830 <pmm_init+0xd10>
ffffffffc0202db4:	6090                	ld	a2,0(s1)
ffffffffc0202db6:	078a                	slli	a5,a5,0x2
ffffffffc0202db8:	83b1                	srli	a5,a5,0xc
ffffffffc0202dba:	62c7f163          	bgeu	a5,a2,ffffffffc02033dc <pmm_init+0x8bc>
ffffffffc0202dbe:	000bb703          	ld	a4,0(s7)
ffffffffc0202dc2:	079a                	slli	a5,a5,0x6
ffffffffc0202dc4:	fe0006b7          	lui	a3,0xfe000
ffffffffc0202dc8:	97b6                	add	a5,a5,a3
ffffffffc0202dca:	97ba                	add	a5,a5,a4
ffffffffc0202dcc:	2afa1ae3          	bne	s4,a5,ffffffffc0203880 <pmm_init+0xd60>
ffffffffc0202dd0:	000a2703          	lw	a4,0(s4) # 200000 <_binary_bin_sfs_img_size+0x18ad00>
ffffffffc0202dd4:	4785                	li	a5,1
ffffffffc0202dd6:	2ef711e3          	bne	a4,a5,ffffffffc02038b8 <pmm_init+0xd98>
ffffffffc0202dda:	00093503          	ld	a0,0(s2)
ffffffffc0202dde:	77fd                	lui	a5,0xfffff
ffffffffc0202de0:	6114                	ld	a3,0(a0)
ffffffffc0202de2:	068a                	slli	a3,a3,0x2
ffffffffc0202de4:	8efd                	and	a3,a3,a5
ffffffffc0202de6:	00c6d713          	srli	a4,a3,0xc
ffffffffc0202dea:	2ac77be3          	bgeu	a4,a2,ffffffffc02038a0 <pmm_init+0xd80>
ffffffffc0202dee:	0009bc03          	ld	s8,0(s3)
ffffffffc0202df2:	96e2                	add	a3,a3,s8
ffffffffc0202df4:	0006ba83          	ld	s5,0(a3) # fffffffffe000000 <end+0x3dd696f0>
ffffffffc0202df8:	0a8a                	slli	s5,s5,0x2
ffffffffc0202dfa:	00fafab3          	and	s5,s5,a5
ffffffffc0202dfe:	00cad793          	srli	a5,s5,0xc
ffffffffc0202e02:	06c7f2e3          	bgeu	a5,a2,ffffffffc0203666 <pmm_init+0xb46>
ffffffffc0202e06:	4601                	li	a2,0
ffffffffc0202e08:	6585                	lui	a1,0x1
ffffffffc0202e0a:	9c56                	add	s8,s8,s5
ffffffffc0202e0c:	c20ff0ef          	jal	ffffffffc020222c <get_pte>
ffffffffc0202e10:	0c21                	addi	s8,s8,8
ffffffffc0202e12:	03851ae3          	bne	a0,s8,ffffffffc0203646 <pmm_init+0xb26>
ffffffffc0202e16:	100027f3          	csrr	a5,sstatus
ffffffffc0202e1a:	8b89                	andi	a5,a5,2
ffffffffc0202e1c:	40079663          	bnez	a5,ffffffffc0203228 <pmm_init+0x708>
ffffffffc0202e20:	000b3783          	ld	a5,0(s6)
ffffffffc0202e24:	4505                	li	a0,1
ffffffffc0202e26:	6f9c                	ld	a5,24(a5)
ffffffffc0202e28:	9782                	jalr	a5
ffffffffc0202e2a:	8c2a                	mv	s8,a0
ffffffffc0202e2c:	00093503          	ld	a0,0(s2)
ffffffffc0202e30:	46d1                	li	a3,20
ffffffffc0202e32:	6605                	lui	a2,0x1
ffffffffc0202e34:	85e2                	mv	a1,s8
ffffffffc0202e36:	bf5ff0ef          	jal	ffffffffc0202a2a <page_insert>
ffffffffc0202e3a:	7e051663          	bnez	a0,ffffffffc0203626 <pmm_init+0xb06>
ffffffffc0202e3e:	00093503          	ld	a0,0(s2)
ffffffffc0202e42:	4601                	li	a2,0
ffffffffc0202e44:	6585                	lui	a1,0x1
ffffffffc0202e46:	be6ff0ef          	jal	ffffffffc020222c <get_pte>
ffffffffc0202e4a:	10050be3          	beqz	a0,ffffffffc0203760 <pmm_init+0xc40>
ffffffffc0202e4e:	611c                	ld	a5,0(a0)
ffffffffc0202e50:	0107f713          	andi	a4,a5,16
ffffffffc0202e54:	0e0706e3          	beqz	a4,ffffffffc0203740 <pmm_init+0xc20>
ffffffffc0202e58:	8b91                	andi	a5,a5,4
ffffffffc0202e5a:	0c0783e3          	beqz	a5,ffffffffc0203720 <pmm_init+0xc00>
ffffffffc0202e5e:	00093503          	ld	a0,0(s2)
ffffffffc0202e62:	611c                	ld	a5,0(a0)
ffffffffc0202e64:	8bc1                	andi	a5,a5,16
ffffffffc0202e66:	08078de3          	beqz	a5,ffffffffc0203700 <pmm_init+0xbe0>
ffffffffc0202e6a:	000c2703          	lw	a4,0(s8)
ffffffffc0202e6e:	4785                	li	a5,1
ffffffffc0202e70:	06f718e3          	bne	a4,a5,ffffffffc02036e0 <pmm_init+0xbc0>
ffffffffc0202e74:	4681                	li	a3,0
ffffffffc0202e76:	6605                	lui	a2,0x1
ffffffffc0202e78:	85d2                	mv	a1,s4
ffffffffc0202e7a:	bb1ff0ef          	jal	ffffffffc0202a2a <page_insert>
ffffffffc0202e7e:	040511e3          	bnez	a0,ffffffffc02036c0 <pmm_init+0xba0>
ffffffffc0202e82:	000a2703          	lw	a4,0(s4)
ffffffffc0202e86:	4789                	li	a5,2
ffffffffc0202e88:	00f71ce3          	bne	a4,a5,ffffffffc02036a0 <pmm_init+0xb80>
ffffffffc0202e8c:	000c2783          	lw	a5,0(s8)
ffffffffc0202e90:	7e079863          	bnez	a5,ffffffffc0203680 <pmm_init+0xb60>
ffffffffc0202e94:	00093503          	ld	a0,0(s2)
ffffffffc0202e98:	4601                	li	a2,0
ffffffffc0202e9a:	6585                	lui	a1,0x1
ffffffffc0202e9c:	b90ff0ef          	jal	ffffffffc020222c <get_pte>
ffffffffc0202ea0:	54050063          	beqz	a0,ffffffffc02033e0 <pmm_init+0x8c0>
ffffffffc0202ea4:	6118                	ld	a4,0(a0)
ffffffffc0202ea6:	00177793          	andi	a5,a4,1
ffffffffc0202eaa:	180783e3          	beqz	a5,ffffffffc0203830 <pmm_init+0xd10>
ffffffffc0202eae:	6094                	ld	a3,0(s1)
ffffffffc0202eb0:	00271793          	slli	a5,a4,0x2
ffffffffc0202eb4:	83b1                	srli	a5,a5,0xc
ffffffffc0202eb6:	52d7f363          	bgeu	a5,a3,ffffffffc02033dc <pmm_init+0x8bc>
ffffffffc0202eba:	000bb683          	ld	a3,0(s7)
ffffffffc0202ebe:	fff80ab7          	lui	s5,0xfff80
ffffffffc0202ec2:	97d6                	add	a5,a5,s5
ffffffffc0202ec4:	079a                	slli	a5,a5,0x6
ffffffffc0202ec6:	97b6                	add	a5,a5,a3
ffffffffc0202ec8:	58fa1c63          	bne	s4,a5,ffffffffc0203460 <pmm_init+0x940>
ffffffffc0202ecc:	8b41                	andi	a4,a4,16
ffffffffc0202ece:	56071963          	bnez	a4,ffffffffc0203440 <pmm_init+0x920>
ffffffffc0202ed2:	00093503          	ld	a0,0(s2)
ffffffffc0202ed6:	4581                	li	a1,0
ffffffffc0202ed8:	ab7ff0ef          	jal	ffffffffc020298e <page_remove>
ffffffffc0202edc:	000a2c83          	lw	s9,0(s4)
ffffffffc0202ee0:	4785                	li	a5,1
ffffffffc0202ee2:	5afc9f63          	bne	s9,a5,ffffffffc02034a0 <pmm_init+0x980>
ffffffffc0202ee6:	000c2783          	lw	a5,0(s8)
ffffffffc0202eea:	58079b63          	bnez	a5,ffffffffc0203480 <pmm_init+0x960>
ffffffffc0202eee:	00093503          	ld	a0,0(s2)
ffffffffc0202ef2:	6585                	lui	a1,0x1
ffffffffc0202ef4:	a9bff0ef          	jal	ffffffffc020298e <page_remove>
ffffffffc0202ef8:	000a2783          	lw	a5,0(s4)
ffffffffc0202efc:	20079be3          	bnez	a5,ffffffffc0203912 <pmm_init+0xdf2>
ffffffffc0202f00:	000c2783          	lw	a5,0(s8)
ffffffffc0202f04:	1e0797e3          	bnez	a5,ffffffffc02038f2 <pmm_init+0xdd2>
ffffffffc0202f08:	00093a03          	ld	s4,0(s2)
ffffffffc0202f0c:	6098                	ld	a4,0(s1)
ffffffffc0202f0e:	000a3783          	ld	a5,0(s4)
ffffffffc0202f12:	078a                	slli	a5,a5,0x2
ffffffffc0202f14:	83b1                	srli	a5,a5,0xc
ffffffffc0202f16:	4ce7f363          	bgeu	a5,a4,ffffffffc02033dc <pmm_init+0x8bc>
ffffffffc0202f1a:	000bb503          	ld	a0,0(s7)
ffffffffc0202f1e:	97d6                	add	a5,a5,s5
ffffffffc0202f20:	079a                	slli	a5,a5,0x6
ffffffffc0202f22:	00f506b3          	add	a3,a0,a5
ffffffffc0202f26:	4294                	lw	a3,0(a3)
ffffffffc0202f28:	4f969c63          	bne	a3,s9,ffffffffc0203420 <pmm_init+0x900>
ffffffffc0202f2c:	8799                	srai	a5,a5,0x6
ffffffffc0202f2e:	00080637          	lui	a2,0x80
ffffffffc0202f32:	97b2                	add	a5,a5,a2
ffffffffc0202f34:	00c79693          	slli	a3,a5,0xc
ffffffffc0202f38:	6ae7fb63          	bgeu	a5,a4,ffffffffc02035ee <pmm_init+0xace>
ffffffffc0202f3c:	0009b783          	ld	a5,0(s3)
ffffffffc0202f40:	97b6                	add	a5,a5,a3
ffffffffc0202f42:	639c                	ld	a5,0(a5)
ffffffffc0202f44:	078a                	slli	a5,a5,0x2
ffffffffc0202f46:	83b1                	srli	a5,a5,0xc
ffffffffc0202f48:	48e7fa63          	bgeu	a5,a4,ffffffffc02033dc <pmm_init+0x8bc>
ffffffffc0202f4c:	8f91                	sub	a5,a5,a2
ffffffffc0202f4e:	079a                	slli	a5,a5,0x6
ffffffffc0202f50:	953e                	add	a0,a0,a5
ffffffffc0202f52:	100027f3          	csrr	a5,sstatus
ffffffffc0202f56:	8b89                	andi	a5,a5,2
ffffffffc0202f58:	32079363          	bnez	a5,ffffffffc020327e <pmm_init+0x75e>
ffffffffc0202f5c:	000b3783          	ld	a5,0(s6)
ffffffffc0202f60:	4585                	li	a1,1
ffffffffc0202f62:	739c                	ld	a5,32(a5)
ffffffffc0202f64:	9782                	jalr	a5
ffffffffc0202f66:	000a3783          	ld	a5,0(s4)
ffffffffc0202f6a:	6098                	ld	a4,0(s1)
ffffffffc0202f6c:	078a                	slli	a5,a5,0x2
ffffffffc0202f6e:	83b1                	srli	a5,a5,0xc
ffffffffc0202f70:	46e7f663          	bgeu	a5,a4,ffffffffc02033dc <pmm_init+0x8bc>
ffffffffc0202f74:	000bb503          	ld	a0,0(s7)
ffffffffc0202f78:	fe000737          	lui	a4,0xfe000
ffffffffc0202f7c:	079a                	slli	a5,a5,0x6
ffffffffc0202f7e:	97ba                	add	a5,a5,a4
ffffffffc0202f80:	953e                	add	a0,a0,a5
ffffffffc0202f82:	100027f3          	csrr	a5,sstatus
ffffffffc0202f86:	8b89                	andi	a5,a5,2
ffffffffc0202f88:	2c079f63          	bnez	a5,ffffffffc0203266 <pmm_init+0x746>
ffffffffc0202f8c:	000b3783          	ld	a5,0(s6)
ffffffffc0202f90:	4585                	li	a1,1
ffffffffc0202f92:	739c                	ld	a5,32(a5)
ffffffffc0202f94:	9782                	jalr	a5
ffffffffc0202f96:	00093783          	ld	a5,0(s2)
ffffffffc0202f9a:	0007b023          	sd	zero,0(a5) # fffffffffffff000 <end+0x3fd686f0>
ffffffffc0202f9e:	12000073          	sfence.vma
ffffffffc0202fa2:	100027f3          	csrr	a5,sstatus
ffffffffc0202fa6:	8b89                	andi	a5,a5,2
ffffffffc0202fa8:	2a079563          	bnez	a5,ffffffffc0203252 <pmm_init+0x732>
ffffffffc0202fac:	000b3783          	ld	a5,0(s6)
ffffffffc0202fb0:	779c                	ld	a5,40(a5)
ffffffffc0202fb2:	9782                	jalr	a5
ffffffffc0202fb4:	8a2a                	mv	s4,a0
ffffffffc0202fb6:	51441563          	bne	s0,s4,ffffffffc02034c0 <pmm_init+0x9a0>
ffffffffc0202fba:	0000a517          	auipc	a0,0xa
ffffffffc0202fbe:	d1650513          	addi	a0,a0,-746 # ffffffffc020ccd0 <etext+0x1470>
ffffffffc0202fc2:	9e4fd0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0202fc6:	100027f3          	csrr	a5,sstatus
ffffffffc0202fca:	8b89                	andi	a5,a5,2
ffffffffc0202fcc:	26079963          	bnez	a5,ffffffffc020323e <pmm_init+0x71e>
ffffffffc0202fd0:	000b3783          	ld	a5,0(s6)
ffffffffc0202fd4:	779c                	ld	a5,40(a5)
ffffffffc0202fd6:	9782                	jalr	a5
ffffffffc0202fd8:	8c2a                	mv	s8,a0
ffffffffc0202fda:	609c                	ld	a5,0(s1)
ffffffffc0202fdc:	c0200437          	lui	s0,0xc0200
ffffffffc0202fe0:	7a7d                	lui	s4,0xfffff
ffffffffc0202fe2:	00c79713          	slli	a4,a5,0xc
ffffffffc0202fe6:	6a85                	lui	s5,0x1
ffffffffc0202fe8:	02e47c63          	bgeu	s0,a4,ffffffffc0203020 <pmm_init+0x500>
ffffffffc0202fec:	00c45713          	srli	a4,s0,0xc
ffffffffc0202ff0:	38f77963          	bgeu	a4,a5,ffffffffc0203382 <pmm_init+0x862>
ffffffffc0202ff4:	0009b583          	ld	a1,0(s3)
ffffffffc0202ff8:	00093503          	ld	a0,0(s2)
ffffffffc0202ffc:	4601                	li	a2,0
ffffffffc0202ffe:	95a2                	add	a1,a1,s0
ffffffffc0203000:	a2cff0ef          	jal	ffffffffc020222c <get_pte>
ffffffffc0203004:	3a050c63          	beqz	a0,ffffffffc02033bc <pmm_init+0x89c>
ffffffffc0203008:	611c                	ld	a5,0(a0)
ffffffffc020300a:	078a                	slli	a5,a5,0x2
ffffffffc020300c:	0147f7b3          	and	a5,a5,s4
ffffffffc0203010:	38879663          	bne	a5,s0,ffffffffc020339c <pmm_init+0x87c>
ffffffffc0203014:	609c                	ld	a5,0(s1)
ffffffffc0203016:	9456                	add	s0,s0,s5
ffffffffc0203018:	00c79713          	slli	a4,a5,0xc
ffffffffc020301c:	fce468e3          	bltu	s0,a4,ffffffffc0202fec <pmm_init+0x4cc>
ffffffffc0203020:	00093783          	ld	a5,0(s2)
ffffffffc0203024:	639c                	ld	a5,0(a5)
ffffffffc0203026:	74079d63          	bnez	a5,ffffffffc0203780 <pmm_init+0xc60>
ffffffffc020302a:	100027f3          	csrr	a5,sstatus
ffffffffc020302e:	8b89                	andi	a5,a5,2
ffffffffc0203030:	26079363          	bnez	a5,ffffffffc0203296 <pmm_init+0x776>
ffffffffc0203034:	000b3783          	ld	a5,0(s6)
ffffffffc0203038:	4505                	li	a0,1
ffffffffc020303a:	6f9c                	ld	a5,24(a5)
ffffffffc020303c:	9782                	jalr	a5
ffffffffc020303e:	842a                	mv	s0,a0
ffffffffc0203040:	00093503          	ld	a0,0(s2)
ffffffffc0203044:	4699                	li	a3,6
ffffffffc0203046:	10000613          	li	a2,256
ffffffffc020304a:	85a2                	mv	a1,s0
ffffffffc020304c:	9dfff0ef          	jal	ffffffffc0202a2a <page_insert>
ffffffffc0203050:	4a051863          	bnez	a0,ffffffffc0203500 <pmm_init+0x9e0>
ffffffffc0203054:	4018                	lw	a4,0(s0)
ffffffffc0203056:	4785                	li	a5,1
ffffffffc0203058:	48f71463          	bne	a4,a5,ffffffffc02034e0 <pmm_init+0x9c0>
ffffffffc020305c:	00093503          	ld	a0,0(s2)
ffffffffc0203060:	6605                	lui	a2,0x1
ffffffffc0203062:	10060613          	addi	a2,a2,256 # 1100 <_binary_bin_swap_img_size-0x6c00>
ffffffffc0203066:	4699                	li	a3,6
ffffffffc0203068:	85a2                	mv	a1,s0
ffffffffc020306a:	9c1ff0ef          	jal	ffffffffc0202a2a <page_insert>
ffffffffc020306e:	38051963          	bnez	a0,ffffffffc0203400 <pmm_init+0x8e0>
ffffffffc0203072:	4018                	lw	a4,0(s0)
ffffffffc0203074:	4789                	li	a5,2
ffffffffc0203076:	4ef71563          	bne	a4,a5,ffffffffc0203560 <pmm_init+0xa40>
ffffffffc020307a:	0000a597          	auipc	a1,0xa
ffffffffc020307e:	d9e58593          	addi	a1,a1,-610 # ffffffffc020ce18 <etext+0x15b8>
ffffffffc0203082:	10000513          	li	a0,256
ffffffffc0203086:	6f2080ef          	jal	ffffffffc020b778 <strcpy>
ffffffffc020308a:	6585                	lui	a1,0x1
ffffffffc020308c:	10058593          	addi	a1,a1,256 # 1100 <_binary_bin_swap_img_size-0x6c00>
ffffffffc0203090:	10000513          	li	a0,256
ffffffffc0203094:	6f6080ef          	jal	ffffffffc020b78a <strcmp>
ffffffffc0203098:	4a051463          	bnez	a0,ffffffffc0203540 <pmm_init+0xa20>
ffffffffc020309c:	000bb683          	ld	a3,0(s7)
ffffffffc02030a0:	000807b7          	lui	a5,0x80
ffffffffc02030a4:	6098                	ld	a4,0(s1)
ffffffffc02030a6:	40d406b3          	sub	a3,s0,a3
ffffffffc02030aa:	8699                	srai	a3,a3,0x6
ffffffffc02030ac:	96be                	add	a3,a3,a5
ffffffffc02030ae:	00c69793          	slli	a5,a3,0xc
ffffffffc02030b2:	83b1                	srli	a5,a5,0xc
ffffffffc02030b4:	06b2                	slli	a3,a3,0xc
ffffffffc02030b6:	52e7fc63          	bgeu	a5,a4,ffffffffc02035ee <pmm_init+0xace>
ffffffffc02030ba:	0009b783          	ld	a5,0(s3)
ffffffffc02030be:	10000513          	li	a0,256
ffffffffc02030c2:	97b6                	add	a5,a5,a3
ffffffffc02030c4:	10078023          	sb	zero,256(a5) # 80100 <_binary_bin_sfs_img_size+0xae00>
ffffffffc02030c8:	67c080ef          	jal	ffffffffc020b744 <strlen>
ffffffffc02030cc:	44051a63          	bnez	a0,ffffffffc0203520 <pmm_init+0xa00>
ffffffffc02030d0:	00093a03          	ld	s4,0(s2)
ffffffffc02030d4:	6098                	ld	a4,0(s1)
ffffffffc02030d6:	000a3783          	ld	a5,0(s4) # fffffffffffff000 <end+0x3fd686f0>
ffffffffc02030da:	078a                	slli	a5,a5,0x2
ffffffffc02030dc:	83b1                	srli	a5,a5,0xc
ffffffffc02030de:	2ee7ff63          	bgeu	a5,a4,ffffffffc02033dc <pmm_init+0x8bc>
ffffffffc02030e2:	00c79693          	slli	a3,a5,0xc
ffffffffc02030e6:	50e7f463          	bgeu	a5,a4,ffffffffc02035ee <pmm_init+0xace>
ffffffffc02030ea:	0009b783          	ld	a5,0(s3)
ffffffffc02030ee:	00f689b3          	add	s3,a3,a5
ffffffffc02030f2:	100027f3          	csrr	a5,sstatus
ffffffffc02030f6:	8b89                	andi	a5,a5,2
ffffffffc02030f8:	1e079c63          	bnez	a5,ffffffffc02032f0 <pmm_init+0x7d0>
ffffffffc02030fc:	000b3783          	ld	a5,0(s6)
ffffffffc0203100:	8522                	mv	a0,s0
ffffffffc0203102:	4585                	li	a1,1
ffffffffc0203104:	739c                	ld	a5,32(a5)
ffffffffc0203106:	9782                	jalr	a5
ffffffffc0203108:	0009b783          	ld	a5,0(s3)
ffffffffc020310c:	6098                	ld	a4,0(s1)
ffffffffc020310e:	078a                	slli	a5,a5,0x2
ffffffffc0203110:	83b1                	srli	a5,a5,0xc
ffffffffc0203112:	2ce7f563          	bgeu	a5,a4,ffffffffc02033dc <pmm_init+0x8bc>
ffffffffc0203116:	000bb503          	ld	a0,0(s7)
ffffffffc020311a:	fe000737          	lui	a4,0xfe000
ffffffffc020311e:	079a                	slli	a5,a5,0x6
ffffffffc0203120:	97ba                	add	a5,a5,a4
ffffffffc0203122:	953e                	add	a0,a0,a5
ffffffffc0203124:	100027f3          	csrr	a5,sstatus
ffffffffc0203128:	8b89                	andi	a5,a5,2
ffffffffc020312a:	1a079763          	bnez	a5,ffffffffc02032d8 <pmm_init+0x7b8>
ffffffffc020312e:	000b3783          	ld	a5,0(s6)
ffffffffc0203132:	4585                	li	a1,1
ffffffffc0203134:	739c                	ld	a5,32(a5)
ffffffffc0203136:	9782                	jalr	a5
ffffffffc0203138:	000a3783          	ld	a5,0(s4)
ffffffffc020313c:	6098                	ld	a4,0(s1)
ffffffffc020313e:	078a                	slli	a5,a5,0x2
ffffffffc0203140:	83b1                	srli	a5,a5,0xc
ffffffffc0203142:	28e7fd63          	bgeu	a5,a4,ffffffffc02033dc <pmm_init+0x8bc>
ffffffffc0203146:	000bb503          	ld	a0,0(s7)
ffffffffc020314a:	fe000737          	lui	a4,0xfe000
ffffffffc020314e:	079a                	slli	a5,a5,0x6
ffffffffc0203150:	97ba                	add	a5,a5,a4
ffffffffc0203152:	953e                	add	a0,a0,a5
ffffffffc0203154:	100027f3          	csrr	a5,sstatus
ffffffffc0203158:	8b89                	andi	a5,a5,2
ffffffffc020315a:	16079363          	bnez	a5,ffffffffc02032c0 <pmm_init+0x7a0>
ffffffffc020315e:	000b3783          	ld	a5,0(s6)
ffffffffc0203162:	4585                	li	a1,1
ffffffffc0203164:	739c                	ld	a5,32(a5)
ffffffffc0203166:	9782                	jalr	a5
ffffffffc0203168:	00093783          	ld	a5,0(s2)
ffffffffc020316c:	0007b023          	sd	zero,0(a5)
ffffffffc0203170:	12000073          	sfence.vma
ffffffffc0203174:	100027f3          	csrr	a5,sstatus
ffffffffc0203178:	8b89                	andi	a5,a5,2
ffffffffc020317a:	12079963          	bnez	a5,ffffffffc02032ac <pmm_init+0x78c>
ffffffffc020317e:	000b3783          	ld	a5,0(s6)
ffffffffc0203182:	779c                	ld	a5,40(a5)
ffffffffc0203184:	9782                	jalr	a5
ffffffffc0203186:	842a                	mv	s0,a0
ffffffffc0203188:	428c1663          	bne	s8,s0,ffffffffc02035b4 <pmm_init+0xa94>
ffffffffc020318c:	0000a517          	auipc	a0,0xa
ffffffffc0203190:	d0450513          	addi	a0,a0,-764 # ffffffffc020ce90 <etext+0x1630>
ffffffffc0203194:	812fd0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0203198:	7406                	ld	s0,96(sp)
ffffffffc020319a:	70a6                	ld	ra,104(sp)
ffffffffc020319c:	64e6                	ld	s1,88(sp)
ffffffffc020319e:	6946                	ld	s2,80(sp)
ffffffffc02031a0:	69a6                	ld	s3,72(sp)
ffffffffc02031a2:	6a06                	ld	s4,64(sp)
ffffffffc02031a4:	7ae2                	ld	s5,56(sp)
ffffffffc02031a6:	7b42                	ld	s6,48(sp)
ffffffffc02031a8:	7ba2                	ld	s7,40(sp)
ffffffffc02031aa:	7c02                	ld	s8,32(sp)
ffffffffc02031ac:	6ce2                	ld	s9,24(sp)
ffffffffc02031ae:	6165                	addi	sp,sp,112
ffffffffc02031b0:	dedfe06f          	j	ffffffffc0201f9c <kmalloc_init>
ffffffffc02031b4:	853e                	mv	a0,a5
ffffffffc02031b6:	baed                	j	ffffffffc0202bb0 <pmm_init+0x90>
ffffffffc02031b8:	a21fd0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc02031bc:	000b3783          	ld	a5,0(s6)
ffffffffc02031c0:	4505                	li	a0,1
ffffffffc02031c2:	6f9c                	ld	a5,24(a5)
ffffffffc02031c4:	9782                	jalr	a5
ffffffffc02031c6:	842a                	mv	s0,a0
ffffffffc02031c8:	a0bfd0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc02031cc:	b461                	j	ffffffffc0202c54 <pmm_init+0x134>
ffffffffc02031ce:	6705                	lui	a4,0x1
ffffffffc02031d0:	177d                	addi	a4,a4,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc02031d2:	96ba                	add	a3,a3,a4
ffffffffc02031d4:	8ff5                	and	a5,a5,a3
ffffffffc02031d6:	00c7d713          	srli	a4,a5,0xc
ffffffffc02031da:	20a77163          	bgeu	a4,a0,ffffffffc02033dc <pmm_init+0x8bc>
ffffffffc02031de:	000b3683          	ld	a3,0(s6)
ffffffffc02031e2:	8c1d                	sub	s0,s0,a5
ffffffffc02031e4:	071a                	slli	a4,a4,0x6
ffffffffc02031e6:	fe0007b7          	lui	a5,0xfe000
ffffffffc02031ea:	973e                	add	a4,a4,a5
ffffffffc02031ec:	6a9c                	ld	a5,16(a3)
ffffffffc02031ee:	00c45593          	srli	a1,s0,0xc
ffffffffc02031f2:	00e60533          	add	a0,a2,a4
ffffffffc02031f6:	9782                	jalr	a5
ffffffffc02031f8:	0009b583          	ld	a1,0(s3)
ffffffffc02031fc:	b40d                	j	ffffffffc0202c1e <pmm_init+0xfe>
ffffffffc02031fe:	9dbfd0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0203202:	000b3783          	ld	a5,0(s6)
ffffffffc0203206:	4505                	li	a0,1
ffffffffc0203208:	6f9c                	ld	a5,24(a5)
ffffffffc020320a:	9782                	jalr	a5
ffffffffc020320c:	8a2a                	mv	s4,a0
ffffffffc020320e:	9c5fd0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0203212:	be9d                	j	ffffffffc0202d88 <pmm_init+0x268>
ffffffffc0203214:	9c5fd0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0203218:	000b3783          	ld	a5,0(s6)
ffffffffc020321c:	779c                	ld	a5,40(a5)
ffffffffc020321e:	9782                	jalr	a5
ffffffffc0203220:	842a                	mv	s0,a0
ffffffffc0203222:	9b1fd0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0203226:	b615                	j	ffffffffc0202d4a <pmm_init+0x22a>
ffffffffc0203228:	9b1fd0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc020322c:	000b3783          	ld	a5,0(s6)
ffffffffc0203230:	4505                	li	a0,1
ffffffffc0203232:	6f9c                	ld	a5,24(a5)
ffffffffc0203234:	9782                	jalr	a5
ffffffffc0203236:	8c2a                	mv	s8,a0
ffffffffc0203238:	99bfd0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc020323c:	bec5                	j	ffffffffc0202e2c <pmm_init+0x30c>
ffffffffc020323e:	99bfd0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0203242:	000b3783          	ld	a5,0(s6)
ffffffffc0203246:	779c                	ld	a5,40(a5)
ffffffffc0203248:	9782                	jalr	a5
ffffffffc020324a:	8c2a                	mv	s8,a0
ffffffffc020324c:	987fd0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0203250:	b369                	j	ffffffffc0202fda <pmm_init+0x4ba>
ffffffffc0203252:	987fd0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0203256:	000b3783          	ld	a5,0(s6)
ffffffffc020325a:	779c                	ld	a5,40(a5)
ffffffffc020325c:	9782                	jalr	a5
ffffffffc020325e:	8a2a                	mv	s4,a0
ffffffffc0203260:	973fd0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0203264:	bb89                	j	ffffffffc0202fb6 <pmm_init+0x496>
ffffffffc0203266:	e42a                	sd	a0,8(sp)
ffffffffc0203268:	971fd0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc020326c:	000b3783          	ld	a5,0(s6)
ffffffffc0203270:	6522                	ld	a0,8(sp)
ffffffffc0203272:	4585                	li	a1,1
ffffffffc0203274:	739c                	ld	a5,32(a5)
ffffffffc0203276:	9782                	jalr	a5
ffffffffc0203278:	95bfd0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc020327c:	bb29                	j	ffffffffc0202f96 <pmm_init+0x476>
ffffffffc020327e:	e42a                	sd	a0,8(sp)
ffffffffc0203280:	959fd0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0203284:	000b3783          	ld	a5,0(s6)
ffffffffc0203288:	6522                	ld	a0,8(sp)
ffffffffc020328a:	4585                	li	a1,1
ffffffffc020328c:	739c                	ld	a5,32(a5)
ffffffffc020328e:	9782                	jalr	a5
ffffffffc0203290:	943fd0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0203294:	b9c9                	j	ffffffffc0202f66 <pmm_init+0x446>
ffffffffc0203296:	943fd0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc020329a:	000b3783          	ld	a5,0(s6)
ffffffffc020329e:	4505                	li	a0,1
ffffffffc02032a0:	6f9c                	ld	a5,24(a5)
ffffffffc02032a2:	9782                	jalr	a5
ffffffffc02032a4:	842a                	mv	s0,a0
ffffffffc02032a6:	92dfd0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc02032aa:	bb59                	j	ffffffffc0203040 <pmm_init+0x520>
ffffffffc02032ac:	92dfd0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc02032b0:	000b3783          	ld	a5,0(s6)
ffffffffc02032b4:	779c                	ld	a5,40(a5)
ffffffffc02032b6:	9782                	jalr	a5
ffffffffc02032b8:	842a                	mv	s0,a0
ffffffffc02032ba:	919fd0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc02032be:	b5e9                	j	ffffffffc0203188 <pmm_init+0x668>
ffffffffc02032c0:	e42a                	sd	a0,8(sp)
ffffffffc02032c2:	917fd0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc02032c6:	000b3783          	ld	a5,0(s6)
ffffffffc02032ca:	6522                	ld	a0,8(sp)
ffffffffc02032cc:	4585                	li	a1,1
ffffffffc02032ce:	739c                	ld	a5,32(a5)
ffffffffc02032d0:	9782                	jalr	a5
ffffffffc02032d2:	901fd0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc02032d6:	bd49                	j	ffffffffc0203168 <pmm_init+0x648>
ffffffffc02032d8:	e42a                	sd	a0,8(sp)
ffffffffc02032da:	8fffd0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc02032de:	000b3783          	ld	a5,0(s6)
ffffffffc02032e2:	6522                	ld	a0,8(sp)
ffffffffc02032e4:	4585                	li	a1,1
ffffffffc02032e6:	739c                	ld	a5,32(a5)
ffffffffc02032e8:	9782                	jalr	a5
ffffffffc02032ea:	8e9fd0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc02032ee:	b5a9                	j	ffffffffc0203138 <pmm_init+0x618>
ffffffffc02032f0:	8e9fd0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc02032f4:	000b3783          	ld	a5,0(s6)
ffffffffc02032f8:	8522                	mv	a0,s0
ffffffffc02032fa:	4585                	li	a1,1
ffffffffc02032fc:	739c                	ld	a5,32(a5)
ffffffffc02032fe:	9782                	jalr	a5
ffffffffc0203300:	8d3fd0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0203304:	b511                	j	ffffffffc0203108 <pmm_init+0x5e8>
ffffffffc0203306:	6605                	lui	a2,0x1
ffffffffc0203308:	4581                	li	a1,0
ffffffffc020330a:	853a                	mv	a0,a4
ffffffffc020330c:	4ec080ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc0203310:	0000e797          	auipc	a5,0xe
ffffffffc0203314:	ce0787a3          	sb	zero,-785(a5) # ffffffffc0210fff <bootstackguard+0xfff>
ffffffffc0203318:	0000d797          	auipc	a5,0xd
ffffffffc020331c:	ce078423          	sb	zero,-792(a5) # ffffffffc0210000 <bootstackguard>
ffffffffc0203320:	0000d797          	auipc	a5,0xd
ffffffffc0203324:	ce078793          	addi	a5,a5,-800 # ffffffffc0210000 <bootstackguard>
ffffffffc0203328:	2757e963          	bltu	a5,s5,ffffffffc020359a <pmm_init+0xa7a>
ffffffffc020332c:	0009b683          	ld	a3,0(s3)
ffffffffc0203330:	00093503          	ld	a0,0(s2)
ffffffffc0203334:	0000d597          	auipc	a1,0xd
ffffffffc0203338:	ccc58593          	addi	a1,a1,-820 # ffffffffc0210000 <bootstackguard>
ffffffffc020333c:	40d586b3          	sub	a3,a1,a3
ffffffffc0203340:	4701                	li	a4,0
ffffffffc0203342:	6605                	lui	a2,0x1
ffffffffc0203344:	946ff0ef          	jal	ffffffffc020248a <boot_map_segment>
ffffffffc0203348:	00010797          	auipc	a5,0x10
ffffffffc020334c:	cb878793          	addi	a5,a5,-840 # ffffffffc0213000 <boot_page_table_sv39>
ffffffffc0203350:	2357e863          	bltu	a5,s5,ffffffffc0203580 <pmm_init+0xa60>
ffffffffc0203354:	0009b683          	ld	a3,0(s3)
ffffffffc0203358:	00093503          	ld	a0,0(s2)
ffffffffc020335c:	00010597          	auipc	a1,0x10
ffffffffc0203360:	ca458593          	addi	a1,a1,-860 # ffffffffc0213000 <boot_page_table_sv39>
ffffffffc0203364:	40d586b3          	sub	a3,a1,a3
ffffffffc0203368:	4701                	li	a4,0
ffffffffc020336a:	6605                	lui	a2,0x1
ffffffffc020336c:	91eff0ef          	jal	ffffffffc020248a <boot_map_segment>
ffffffffc0203370:	12000073          	sfence.vma
ffffffffc0203374:	00009517          	auipc	a0,0x9
ffffffffc0203378:	60450513          	addi	a0,a0,1540 # ffffffffc020c978 <etext+0x1118>
ffffffffc020337c:	e2bfc0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0203380:	ba5d                	j	ffffffffc0202d36 <pmm_init+0x216>
ffffffffc0203382:	86a2                	mv	a3,s0
ffffffffc0203384:	00009617          	auipc	a2,0x9
ffffffffc0203388:	38c60613          	addi	a2,a2,908 # ffffffffc020c710 <etext+0xeb0>
ffffffffc020338c:	28a00593          	li	a1,650
ffffffffc0203390:	00009517          	auipc	a0,0x9
ffffffffc0203394:	47050513          	addi	a0,a0,1136 # ffffffffc020c800 <etext+0xfa0>
ffffffffc0203398:	8b2fd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc020339c:	0000a697          	auipc	a3,0xa
ffffffffc02033a0:	99468693          	addi	a3,a3,-1644 # ffffffffc020cd30 <etext+0x14d0>
ffffffffc02033a4:	00009617          	auipc	a2,0x9
ffffffffc02033a8:	8f460613          	addi	a2,a2,-1804 # ffffffffc020bc98 <etext+0x438>
ffffffffc02033ac:	28b00593          	li	a1,651
ffffffffc02033b0:	00009517          	auipc	a0,0x9
ffffffffc02033b4:	45050513          	addi	a0,a0,1104 # ffffffffc020c800 <etext+0xfa0>
ffffffffc02033b8:	892fd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02033bc:	0000a697          	auipc	a3,0xa
ffffffffc02033c0:	93468693          	addi	a3,a3,-1740 # ffffffffc020ccf0 <etext+0x1490>
ffffffffc02033c4:	00009617          	auipc	a2,0x9
ffffffffc02033c8:	8d460613          	addi	a2,a2,-1836 # ffffffffc020bc98 <etext+0x438>
ffffffffc02033cc:	28a00593          	li	a1,650
ffffffffc02033d0:	00009517          	auipc	a0,0x9
ffffffffc02033d4:	43050513          	addi	a0,a0,1072 # ffffffffc020c800 <etext+0xfa0>
ffffffffc02033d8:	872fd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02033dc:	d8dfe0ef          	jal	ffffffffc0202168 <pa2page.part.0>
ffffffffc02033e0:	00009697          	auipc	a3,0x9
ffffffffc02033e4:	77868693          	addi	a3,a3,1912 # ffffffffc020cb58 <etext+0x12f8>
ffffffffc02033e8:	00009617          	auipc	a2,0x9
ffffffffc02033ec:	8b060613          	addi	a2,a2,-1872 # ffffffffc020bc98 <etext+0x438>
ffffffffc02033f0:	26700593          	li	a1,615
ffffffffc02033f4:	00009517          	auipc	a0,0x9
ffffffffc02033f8:	40c50513          	addi	a0,a0,1036 # ffffffffc020c800 <etext+0xfa0>
ffffffffc02033fc:	84efd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203400:	0000a697          	auipc	a3,0xa
ffffffffc0203404:	9b868693          	addi	a3,a3,-1608 # ffffffffc020cdb8 <etext+0x1558>
ffffffffc0203408:	00009617          	auipc	a2,0x9
ffffffffc020340c:	89060613          	addi	a2,a2,-1904 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203410:	29400593          	li	a1,660
ffffffffc0203414:	00009517          	auipc	a0,0x9
ffffffffc0203418:	3ec50513          	addi	a0,a0,1004 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020341c:	82efd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203420:	0000a697          	auipc	a3,0xa
ffffffffc0203424:	85868693          	addi	a3,a3,-1960 # ffffffffc020cc78 <etext+0x1418>
ffffffffc0203428:	00009617          	auipc	a2,0x9
ffffffffc020342c:	87060613          	addi	a2,a2,-1936 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203430:	27300593          	li	a1,627
ffffffffc0203434:	00009517          	auipc	a0,0x9
ffffffffc0203438:	3cc50513          	addi	a0,a0,972 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020343c:	80efd0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203440:	0000a697          	auipc	a3,0xa
ffffffffc0203444:	80868693          	addi	a3,a3,-2040 # ffffffffc020cc48 <etext+0x13e8>
ffffffffc0203448:	00009617          	auipc	a2,0x9
ffffffffc020344c:	85060613          	addi	a2,a2,-1968 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203450:	26900593          	li	a1,617
ffffffffc0203454:	00009517          	auipc	a0,0x9
ffffffffc0203458:	3ac50513          	addi	a0,a0,940 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020345c:	feffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203460:	00009697          	auipc	a3,0x9
ffffffffc0203464:	65868693          	addi	a3,a3,1624 # ffffffffc020cab8 <etext+0x1258>
ffffffffc0203468:	00009617          	auipc	a2,0x9
ffffffffc020346c:	83060613          	addi	a2,a2,-2000 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203470:	26800593          	li	a1,616
ffffffffc0203474:	00009517          	auipc	a0,0x9
ffffffffc0203478:	38c50513          	addi	a0,a0,908 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020347c:	fcffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203480:	00009697          	auipc	a3,0x9
ffffffffc0203484:	7b068693          	addi	a3,a3,1968 # ffffffffc020cc30 <etext+0x13d0>
ffffffffc0203488:	00009617          	auipc	a2,0x9
ffffffffc020348c:	81060613          	addi	a2,a2,-2032 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203490:	26d00593          	li	a1,621
ffffffffc0203494:	00009517          	auipc	a0,0x9
ffffffffc0203498:	36c50513          	addi	a0,a0,876 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020349c:	faffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02034a0:	00009697          	auipc	a3,0x9
ffffffffc02034a4:	63068693          	addi	a3,a3,1584 # ffffffffc020cad0 <etext+0x1270>
ffffffffc02034a8:	00008617          	auipc	a2,0x8
ffffffffc02034ac:	7f060613          	addi	a2,a2,2032 # ffffffffc020bc98 <etext+0x438>
ffffffffc02034b0:	26c00593          	li	a1,620
ffffffffc02034b4:	00009517          	auipc	a0,0x9
ffffffffc02034b8:	34c50513          	addi	a0,a0,844 # ffffffffc020c800 <etext+0xfa0>
ffffffffc02034bc:	f8ffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02034c0:	00009697          	auipc	a3,0x9
ffffffffc02034c4:	7e868693          	addi	a3,a3,2024 # ffffffffc020cca8 <etext+0x1448>
ffffffffc02034c8:	00008617          	auipc	a2,0x8
ffffffffc02034cc:	7d060613          	addi	a2,a2,2000 # ffffffffc020bc98 <etext+0x438>
ffffffffc02034d0:	27b00593          	li	a1,635
ffffffffc02034d4:	00009517          	auipc	a0,0x9
ffffffffc02034d8:	32c50513          	addi	a0,a0,812 # ffffffffc020c800 <etext+0xfa0>
ffffffffc02034dc:	f6ffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02034e0:	0000a697          	auipc	a3,0xa
ffffffffc02034e4:	8c068693          	addi	a3,a3,-1856 # ffffffffc020cda0 <etext+0x1540>
ffffffffc02034e8:	00008617          	auipc	a2,0x8
ffffffffc02034ec:	7b060613          	addi	a2,a2,1968 # ffffffffc020bc98 <etext+0x438>
ffffffffc02034f0:	29300593          	li	a1,659
ffffffffc02034f4:	00009517          	auipc	a0,0x9
ffffffffc02034f8:	30c50513          	addi	a0,a0,780 # ffffffffc020c800 <etext+0xfa0>
ffffffffc02034fc:	f4ffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203500:	0000a697          	auipc	a3,0xa
ffffffffc0203504:	86068693          	addi	a3,a3,-1952 # ffffffffc020cd60 <etext+0x1500>
ffffffffc0203508:	00008617          	auipc	a2,0x8
ffffffffc020350c:	79060613          	addi	a2,a2,1936 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203510:	29200593          	li	a1,658
ffffffffc0203514:	00009517          	auipc	a0,0x9
ffffffffc0203518:	2ec50513          	addi	a0,a0,748 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020351c:	f2ffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203520:	0000a697          	auipc	a3,0xa
ffffffffc0203524:	94868693          	addi	a3,a3,-1720 # ffffffffc020ce68 <etext+0x1608>
ffffffffc0203528:	00008617          	auipc	a2,0x8
ffffffffc020352c:	77060613          	addi	a2,a2,1904 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203530:	29c00593          	li	a1,668
ffffffffc0203534:	00009517          	auipc	a0,0x9
ffffffffc0203538:	2cc50513          	addi	a0,a0,716 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020353c:	f0ffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203540:	0000a697          	auipc	a3,0xa
ffffffffc0203544:	8f068693          	addi	a3,a3,-1808 # ffffffffc020ce30 <etext+0x15d0>
ffffffffc0203548:	00008617          	auipc	a2,0x8
ffffffffc020354c:	75060613          	addi	a2,a2,1872 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203550:	29900593          	li	a1,665
ffffffffc0203554:	00009517          	auipc	a0,0x9
ffffffffc0203558:	2ac50513          	addi	a0,a0,684 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020355c:	eeffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203560:	0000a697          	auipc	a3,0xa
ffffffffc0203564:	8a068693          	addi	a3,a3,-1888 # ffffffffc020ce00 <etext+0x15a0>
ffffffffc0203568:	00008617          	auipc	a2,0x8
ffffffffc020356c:	73060613          	addi	a2,a2,1840 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203570:	29500593          	li	a1,661
ffffffffc0203574:	00009517          	auipc	a0,0x9
ffffffffc0203578:	28c50513          	addi	a0,a0,652 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020357c:	ecffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203580:	86be                	mv	a3,a5
ffffffffc0203582:	00009617          	auipc	a2,0x9
ffffffffc0203586:	23660613          	addi	a2,a2,566 # ffffffffc020c7b8 <etext+0xf58>
ffffffffc020358a:	0dd00593          	li	a1,221
ffffffffc020358e:	00009517          	auipc	a0,0x9
ffffffffc0203592:	27250513          	addi	a0,a0,626 # ffffffffc020c800 <etext+0xfa0>
ffffffffc0203596:	eb5fc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc020359a:	86be                	mv	a3,a5
ffffffffc020359c:	00009617          	auipc	a2,0x9
ffffffffc02035a0:	21c60613          	addi	a2,a2,540 # ffffffffc020c7b8 <etext+0xf58>
ffffffffc02035a4:	0dc00593          	li	a1,220
ffffffffc02035a8:	00009517          	auipc	a0,0x9
ffffffffc02035ac:	25850513          	addi	a0,a0,600 # ffffffffc020c800 <etext+0xfa0>
ffffffffc02035b0:	e9bfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02035b4:	00009697          	auipc	a3,0x9
ffffffffc02035b8:	6f468693          	addi	a3,a3,1780 # ffffffffc020cca8 <etext+0x1448>
ffffffffc02035bc:	00008617          	auipc	a2,0x8
ffffffffc02035c0:	6dc60613          	addi	a2,a2,1756 # ffffffffc020bc98 <etext+0x438>
ffffffffc02035c4:	2a500593          	li	a1,677
ffffffffc02035c8:	00009517          	auipc	a0,0x9
ffffffffc02035cc:	23850513          	addi	a0,a0,568 # ffffffffc020c800 <etext+0xfa0>
ffffffffc02035d0:	e7bfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02035d4:	86ca                	mv	a3,s2
ffffffffc02035d6:	00009617          	auipc	a2,0x9
ffffffffc02035da:	1e260613          	addi	a2,a2,482 # ffffffffc020c7b8 <etext+0xf58>
ffffffffc02035de:	0c600593          	li	a1,198
ffffffffc02035e2:	00009517          	auipc	a0,0x9
ffffffffc02035e6:	21e50513          	addi	a0,a0,542 # ffffffffc020c800 <etext+0xfa0>
ffffffffc02035ea:	e61fc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02035ee:	00009617          	auipc	a2,0x9
ffffffffc02035f2:	12260613          	addi	a2,a2,290 # ffffffffc020c710 <etext+0xeb0>
ffffffffc02035f6:	07100593          	li	a1,113
ffffffffc02035fa:	00009517          	auipc	a0,0x9
ffffffffc02035fe:	13e50513          	addi	a0,a0,318 # ffffffffc020c738 <etext+0xed8>
ffffffffc0203602:	e49fc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203606:	00009697          	auipc	a3,0x9
ffffffffc020360a:	39a68693          	addi	a3,a3,922 # ffffffffc020c9a0 <etext+0x1140>
ffffffffc020360e:	00008617          	auipc	a2,0x8
ffffffffc0203612:	68a60613          	addi	a2,a2,1674 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203616:	24b00593          	li	a1,587
ffffffffc020361a:	00009517          	auipc	a0,0x9
ffffffffc020361e:	1e650513          	addi	a0,a0,486 # ffffffffc020c800 <etext+0xfa0>
ffffffffc0203622:	e29fc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203626:	00009697          	auipc	a3,0x9
ffffffffc020362a:	4f268693          	addi	a3,a3,1266 # ffffffffc020cb18 <etext+0x12b8>
ffffffffc020362e:	00008617          	auipc	a2,0x8
ffffffffc0203632:	66a60613          	addi	a2,a2,1642 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203636:	25d00593          	li	a1,605
ffffffffc020363a:	00009517          	auipc	a0,0x9
ffffffffc020363e:	1c650513          	addi	a0,a0,454 # ffffffffc020c800 <etext+0xfa0>
ffffffffc0203642:	e09fc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203646:	00009697          	auipc	a3,0x9
ffffffffc020364a:	4a268693          	addi	a3,a3,1186 # ffffffffc020cae8 <etext+0x1288>
ffffffffc020364e:	00008617          	auipc	a2,0x8
ffffffffc0203652:	64a60613          	addi	a2,a2,1610 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203656:	25a00593          	li	a1,602
ffffffffc020365a:	00009517          	auipc	a0,0x9
ffffffffc020365e:	1a650513          	addi	a0,a0,422 # ffffffffc020c800 <etext+0xfa0>
ffffffffc0203662:	de9fc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203666:	86d6                	mv	a3,s5
ffffffffc0203668:	00009617          	auipc	a2,0x9
ffffffffc020366c:	0a860613          	addi	a2,a2,168 # ffffffffc020c710 <etext+0xeb0>
ffffffffc0203670:	25900593          	li	a1,601
ffffffffc0203674:	00009517          	auipc	a0,0x9
ffffffffc0203678:	18c50513          	addi	a0,a0,396 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020367c:	dcffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203680:	00009697          	auipc	a3,0x9
ffffffffc0203684:	5b068693          	addi	a3,a3,1456 # ffffffffc020cc30 <etext+0x13d0>
ffffffffc0203688:	00008617          	auipc	a2,0x8
ffffffffc020368c:	61060613          	addi	a2,a2,1552 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203690:	26600593          	li	a1,614
ffffffffc0203694:	00009517          	auipc	a0,0x9
ffffffffc0203698:	16c50513          	addi	a0,a0,364 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020369c:	daffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02036a0:	00009697          	auipc	a3,0x9
ffffffffc02036a4:	57868693          	addi	a3,a3,1400 # ffffffffc020cc18 <etext+0x13b8>
ffffffffc02036a8:	00008617          	auipc	a2,0x8
ffffffffc02036ac:	5f060613          	addi	a2,a2,1520 # ffffffffc020bc98 <etext+0x438>
ffffffffc02036b0:	26500593          	li	a1,613
ffffffffc02036b4:	00009517          	auipc	a0,0x9
ffffffffc02036b8:	14c50513          	addi	a0,a0,332 # ffffffffc020c800 <etext+0xfa0>
ffffffffc02036bc:	d8ffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02036c0:	00009697          	auipc	a3,0x9
ffffffffc02036c4:	52868693          	addi	a3,a3,1320 # ffffffffc020cbe8 <etext+0x1388>
ffffffffc02036c8:	00008617          	auipc	a2,0x8
ffffffffc02036cc:	5d060613          	addi	a2,a2,1488 # ffffffffc020bc98 <etext+0x438>
ffffffffc02036d0:	26400593          	li	a1,612
ffffffffc02036d4:	00009517          	auipc	a0,0x9
ffffffffc02036d8:	12c50513          	addi	a0,a0,300 # ffffffffc020c800 <etext+0xfa0>
ffffffffc02036dc:	d6ffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02036e0:	00009697          	auipc	a3,0x9
ffffffffc02036e4:	4f068693          	addi	a3,a3,1264 # ffffffffc020cbd0 <etext+0x1370>
ffffffffc02036e8:	00008617          	auipc	a2,0x8
ffffffffc02036ec:	5b060613          	addi	a2,a2,1456 # ffffffffc020bc98 <etext+0x438>
ffffffffc02036f0:	26200593          	li	a1,610
ffffffffc02036f4:	00009517          	auipc	a0,0x9
ffffffffc02036f8:	10c50513          	addi	a0,a0,268 # ffffffffc020c800 <etext+0xfa0>
ffffffffc02036fc:	d4ffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203700:	00009697          	auipc	a3,0x9
ffffffffc0203704:	4b068693          	addi	a3,a3,1200 # ffffffffc020cbb0 <etext+0x1350>
ffffffffc0203708:	00008617          	auipc	a2,0x8
ffffffffc020370c:	59060613          	addi	a2,a2,1424 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203710:	26100593          	li	a1,609
ffffffffc0203714:	00009517          	auipc	a0,0x9
ffffffffc0203718:	0ec50513          	addi	a0,a0,236 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020371c:	d2ffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203720:	00009697          	auipc	a3,0x9
ffffffffc0203724:	48068693          	addi	a3,a3,1152 # ffffffffc020cba0 <etext+0x1340>
ffffffffc0203728:	00008617          	auipc	a2,0x8
ffffffffc020372c:	57060613          	addi	a2,a2,1392 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203730:	26000593          	li	a1,608
ffffffffc0203734:	00009517          	auipc	a0,0x9
ffffffffc0203738:	0cc50513          	addi	a0,a0,204 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020373c:	d0ffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203740:	00009697          	auipc	a3,0x9
ffffffffc0203744:	45068693          	addi	a3,a3,1104 # ffffffffc020cb90 <etext+0x1330>
ffffffffc0203748:	00008617          	auipc	a2,0x8
ffffffffc020374c:	55060613          	addi	a2,a2,1360 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203750:	25f00593          	li	a1,607
ffffffffc0203754:	00009517          	auipc	a0,0x9
ffffffffc0203758:	0ac50513          	addi	a0,a0,172 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020375c:	ceffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203760:	00009697          	auipc	a3,0x9
ffffffffc0203764:	3f868693          	addi	a3,a3,1016 # ffffffffc020cb58 <etext+0x12f8>
ffffffffc0203768:	00008617          	auipc	a2,0x8
ffffffffc020376c:	53060613          	addi	a2,a2,1328 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203770:	25e00593          	li	a1,606
ffffffffc0203774:	00009517          	auipc	a0,0x9
ffffffffc0203778:	08c50513          	addi	a0,a0,140 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020377c:	ccffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203780:	00009697          	auipc	a3,0x9
ffffffffc0203784:	5c868693          	addi	a3,a3,1480 # ffffffffc020cd48 <etext+0x14e8>
ffffffffc0203788:	00008617          	auipc	a2,0x8
ffffffffc020378c:	51060613          	addi	a2,a2,1296 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203790:	28e00593          	li	a1,654
ffffffffc0203794:	00009517          	auipc	a0,0x9
ffffffffc0203798:	06c50513          	addi	a0,a0,108 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020379c:	caffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02037a0:	00009617          	auipc	a2,0x9
ffffffffc02037a4:	19060613          	addi	a2,a2,400 # ffffffffc020c930 <etext+0x10d0>
ffffffffc02037a8:	0aa00593          	li	a1,170
ffffffffc02037ac:	00009517          	auipc	a0,0x9
ffffffffc02037b0:	05450513          	addi	a0,a0,84 # ffffffffc020c800 <etext+0xfa0>
ffffffffc02037b4:	c97fc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02037b8:	00009697          	auipc	a3,0x9
ffffffffc02037bc:	24868693          	addi	a3,a3,584 # ffffffffc020ca00 <etext+0x11a0>
ffffffffc02037c0:	00008617          	auipc	a2,0x8
ffffffffc02037c4:	4d860613          	addi	a2,a2,1240 # ffffffffc020bc98 <etext+0x438>
ffffffffc02037c8:	24d00593          	li	a1,589
ffffffffc02037cc:	00009517          	auipc	a0,0x9
ffffffffc02037d0:	03450513          	addi	a0,a0,52 # ffffffffc020c800 <etext+0xfa0>
ffffffffc02037d4:	c77fc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02037d8:	00009697          	auipc	a3,0x9
ffffffffc02037dc:	1e868693          	addi	a3,a3,488 # ffffffffc020c9c0 <etext+0x1160>
ffffffffc02037e0:	00008617          	auipc	a2,0x8
ffffffffc02037e4:	4b860613          	addi	a2,a2,1208 # ffffffffc020bc98 <etext+0x438>
ffffffffc02037e8:	24c00593          	li	a1,588
ffffffffc02037ec:	00009517          	auipc	a0,0x9
ffffffffc02037f0:	01450513          	addi	a0,a0,20 # ffffffffc020c800 <etext+0xfa0>
ffffffffc02037f4:	c57fc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02037f8:	00009617          	auipc	a2,0x9
ffffffffc02037fc:	fc060613          	addi	a2,a2,-64 # ffffffffc020c7b8 <etext+0xf58>
ffffffffc0203800:	08100593          	li	a1,129
ffffffffc0203804:	00009517          	auipc	a0,0x9
ffffffffc0203808:	ffc50513          	addi	a0,a0,-4 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020380c:	c3ffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203810:	00009697          	auipc	a3,0x9
ffffffffc0203814:	22068693          	addi	a3,a3,544 # ffffffffc020ca30 <etext+0x11d0>
ffffffffc0203818:	00008617          	auipc	a2,0x8
ffffffffc020381c:	48060613          	addi	a2,a2,1152 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203820:	25100593          	li	a1,593
ffffffffc0203824:	00009517          	auipc	a0,0x9
ffffffffc0203828:	fdc50513          	addi	a0,a0,-36 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020382c:	c1ffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203830:	00009617          	auipc	a2,0x9
ffffffffc0203834:	26060613          	addi	a2,a2,608 # ffffffffc020ca90 <etext+0x1230>
ffffffffc0203838:	07f00593          	li	a1,127
ffffffffc020383c:	00009517          	auipc	a0,0x9
ffffffffc0203840:	efc50513          	addi	a0,a0,-260 # ffffffffc020c738 <etext+0xed8>
ffffffffc0203844:	c07fc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203848:	00009697          	auipc	a3,0x9
ffffffffc020384c:	21868693          	addi	a3,a3,536 # ffffffffc020ca60 <etext+0x1200>
ffffffffc0203850:	00008617          	auipc	a2,0x8
ffffffffc0203854:	44860613          	addi	a2,a2,1096 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203858:	25400593          	li	a1,596
ffffffffc020385c:	00009517          	auipc	a0,0x9
ffffffffc0203860:	fa450513          	addi	a0,a0,-92 # ffffffffc020c800 <etext+0xfa0>
ffffffffc0203864:	be7fc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203868:	00009617          	auipc	a2,0x9
ffffffffc020386c:	03060613          	addi	a2,a2,48 # ffffffffc020c898 <etext+0x1038>
ffffffffc0203870:	06500593          	li	a1,101
ffffffffc0203874:	00009517          	auipc	a0,0x9
ffffffffc0203878:	f8c50513          	addi	a0,a0,-116 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020387c:	bcffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203880:	00009697          	auipc	a3,0x9
ffffffffc0203884:	23868693          	addi	a3,a3,568 # ffffffffc020cab8 <etext+0x1258>
ffffffffc0203888:	00008617          	auipc	a2,0x8
ffffffffc020388c:	41060613          	addi	a2,a2,1040 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203890:	25500593          	li	a1,597
ffffffffc0203894:	00009517          	auipc	a0,0x9
ffffffffc0203898:	f6c50513          	addi	a0,a0,-148 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020389c:	baffc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02038a0:	00009617          	auipc	a2,0x9
ffffffffc02038a4:	e7060613          	addi	a2,a2,-400 # ffffffffc020c710 <etext+0xeb0>
ffffffffc02038a8:	25800593          	li	a1,600
ffffffffc02038ac:	00009517          	auipc	a0,0x9
ffffffffc02038b0:	f5450513          	addi	a0,a0,-172 # ffffffffc020c800 <etext+0xfa0>
ffffffffc02038b4:	b97fc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02038b8:	00009697          	auipc	a3,0x9
ffffffffc02038bc:	21868693          	addi	a3,a3,536 # ffffffffc020cad0 <etext+0x1270>
ffffffffc02038c0:	00008617          	auipc	a2,0x8
ffffffffc02038c4:	3d860613          	addi	a2,a2,984 # ffffffffc020bc98 <etext+0x438>
ffffffffc02038c8:	25600593          	li	a1,598
ffffffffc02038cc:	00009517          	auipc	a0,0x9
ffffffffc02038d0:	f3450513          	addi	a0,a0,-204 # ffffffffc020c800 <etext+0xfa0>
ffffffffc02038d4:	b77fc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02038d8:	86a2                	mv	a3,s0
ffffffffc02038da:	00009617          	auipc	a2,0x9
ffffffffc02038de:	ede60613          	addi	a2,a2,-290 # ffffffffc020c7b8 <etext+0xf58>
ffffffffc02038e2:	0ca00593          	li	a1,202
ffffffffc02038e6:	00009517          	auipc	a0,0x9
ffffffffc02038ea:	f1a50513          	addi	a0,a0,-230 # ffffffffc020c800 <etext+0xfa0>
ffffffffc02038ee:	b5dfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02038f2:	00009697          	auipc	a3,0x9
ffffffffc02038f6:	33e68693          	addi	a3,a3,830 # ffffffffc020cc30 <etext+0x13d0>
ffffffffc02038fa:	00008617          	auipc	a2,0x8
ffffffffc02038fe:	39e60613          	addi	a2,a2,926 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203902:	27100593          	li	a1,625
ffffffffc0203906:	00009517          	auipc	a0,0x9
ffffffffc020390a:	efa50513          	addi	a0,a0,-262 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020390e:	b3dfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203912:	00009697          	auipc	a3,0x9
ffffffffc0203916:	34e68693          	addi	a3,a3,846 # ffffffffc020cc60 <etext+0x1400>
ffffffffc020391a:	00008617          	auipc	a2,0x8
ffffffffc020391e:	37e60613          	addi	a2,a2,894 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203922:	27000593          	li	a1,624
ffffffffc0203926:	00009517          	auipc	a0,0x9
ffffffffc020392a:	eda50513          	addi	a0,a0,-294 # ffffffffc020c800 <etext+0xfa0>
ffffffffc020392e:	b1dfc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0203932 <copy_range>:
ffffffffc0203932:	7159                	addi	sp,sp,-112
ffffffffc0203934:	00d667b3          	or	a5,a2,a3
ffffffffc0203938:	f486                	sd	ra,104(sp)
ffffffffc020393a:	f0a2                	sd	s0,96(sp)
ffffffffc020393c:	eca6                	sd	s1,88(sp)
ffffffffc020393e:	e8ca                	sd	s2,80(sp)
ffffffffc0203940:	e4ce                	sd	s3,72(sp)
ffffffffc0203942:	e0d2                	sd	s4,64(sp)
ffffffffc0203944:	fc56                	sd	s5,56(sp)
ffffffffc0203946:	f85a                	sd	s6,48(sp)
ffffffffc0203948:	f45e                	sd	s7,40(sp)
ffffffffc020394a:	f062                	sd	s8,32(sp)
ffffffffc020394c:	ec66                	sd	s9,24(sp)
ffffffffc020394e:	e86a                	sd	s10,16(sp)
ffffffffc0203950:	e46e                	sd	s11,8(sp)
ffffffffc0203952:	03479713          	slli	a4,a5,0x34
ffffffffc0203956:	20071f63          	bnez	a4,ffffffffc0203b74 <copy_range+0x242>
ffffffffc020395a:	002007b7          	lui	a5,0x200
ffffffffc020395e:	00d63733          	sltu	a4,a2,a3
ffffffffc0203962:	00f637b3          	sltu	a5,a2,a5
ffffffffc0203966:	00173713          	seqz	a4,a4
ffffffffc020396a:	8fd9                	or	a5,a5,a4
ffffffffc020396c:	8432                	mv	s0,a2
ffffffffc020396e:	8936                	mv	s2,a3
ffffffffc0203970:	1e079263          	bnez	a5,ffffffffc0203b54 <copy_range+0x222>
ffffffffc0203974:	4785                	li	a5,1
ffffffffc0203976:	07fe                	slli	a5,a5,0x1f
ffffffffc0203978:	0785                	addi	a5,a5,1 # 200001 <_binary_bin_sfs_img_size+0x18ad01>
ffffffffc020397a:	1cf6fd63          	bgeu	a3,a5,ffffffffc0203b54 <copy_range+0x222>
ffffffffc020397e:	5b7d                	li	s6,-1
ffffffffc0203980:	8baa                	mv	s7,a0
ffffffffc0203982:	8a2e                	mv	s4,a1
ffffffffc0203984:	6a85                	lui	s5,0x1
ffffffffc0203986:	00cb5b13          	srli	s6,s6,0xc
ffffffffc020398a:	00093c97          	auipc	s9,0x93
ffffffffc020398e:	f26c8c93          	addi	s9,s9,-218 # ffffffffc02968b0 <npage>
ffffffffc0203992:	00093c17          	auipc	s8,0x93
ffffffffc0203996:	f26c0c13          	addi	s8,s8,-218 # ffffffffc02968b8 <pages>
ffffffffc020399a:	fff80d37          	lui	s10,0xfff80
ffffffffc020399e:	4601                	li	a2,0
ffffffffc02039a0:	85a2                	mv	a1,s0
ffffffffc02039a2:	8552                	mv	a0,s4
ffffffffc02039a4:	889fe0ef          	jal	ffffffffc020222c <get_pte>
ffffffffc02039a8:	84aa                	mv	s1,a0
ffffffffc02039aa:	0e050a63          	beqz	a0,ffffffffc0203a9e <copy_range+0x16c>
ffffffffc02039ae:	611c                	ld	a5,0(a0)
ffffffffc02039b0:	8b85                	andi	a5,a5,1
ffffffffc02039b2:	e78d                	bnez	a5,ffffffffc02039dc <copy_range+0xaa>
ffffffffc02039b4:	9456                	add	s0,s0,s5
ffffffffc02039b6:	c019                	beqz	s0,ffffffffc02039bc <copy_range+0x8a>
ffffffffc02039b8:	ff2463e3          	bltu	s0,s2,ffffffffc020399e <copy_range+0x6c>
ffffffffc02039bc:	4501                	li	a0,0
ffffffffc02039be:	70a6                	ld	ra,104(sp)
ffffffffc02039c0:	7406                	ld	s0,96(sp)
ffffffffc02039c2:	64e6                	ld	s1,88(sp)
ffffffffc02039c4:	6946                	ld	s2,80(sp)
ffffffffc02039c6:	69a6                	ld	s3,72(sp)
ffffffffc02039c8:	6a06                	ld	s4,64(sp)
ffffffffc02039ca:	7ae2                	ld	s5,56(sp)
ffffffffc02039cc:	7b42                	ld	s6,48(sp)
ffffffffc02039ce:	7ba2                	ld	s7,40(sp)
ffffffffc02039d0:	7c02                	ld	s8,32(sp)
ffffffffc02039d2:	6ce2                	ld	s9,24(sp)
ffffffffc02039d4:	6d42                	ld	s10,16(sp)
ffffffffc02039d6:	6da2                	ld	s11,8(sp)
ffffffffc02039d8:	6165                	addi	sp,sp,112
ffffffffc02039da:	8082                	ret
ffffffffc02039dc:	4605                	li	a2,1
ffffffffc02039de:	85a2                	mv	a1,s0
ffffffffc02039e0:	855e                	mv	a0,s7
ffffffffc02039e2:	84bfe0ef          	jal	ffffffffc020222c <get_pte>
ffffffffc02039e6:	c165                	beqz	a0,ffffffffc0203ac6 <copy_range+0x194>
ffffffffc02039e8:	0004b983          	ld	s3,0(s1)
ffffffffc02039ec:	0019f793          	andi	a5,s3,1
ffffffffc02039f0:	14078663          	beqz	a5,ffffffffc0203b3c <copy_range+0x20a>
ffffffffc02039f4:	000cb703          	ld	a4,0(s9)
ffffffffc02039f8:	00299793          	slli	a5,s3,0x2
ffffffffc02039fc:	83b1                	srli	a5,a5,0xc
ffffffffc02039fe:	12e7f363          	bgeu	a5,a4,ffffffffc0203b24 <copy_range+0x1f2>
ffffffffc0203a02:	000c3483          	ld	s1,0(s8)
ffffffffc0203a06:	97ea                	add	a5,a5,s10
ffffffffc0203a08:	079a                	slli	a5,a5,0x6
ffffffffc0203a0a:	94be                	add	s1,s1,a5
ffffffffc0203a0c:	100027f3          	csrr	a5,sstatus
ffffffffc0203a10:	8b89                	andi	a5,a5,2
ffffffffc0203a12:	efc9                	bnez	a5,ffffffffc0203aac <copy_range+0x17a>
ffffffffc0203a14:	00093797          	auipc	a5,0x93
ffffffffc0203a18:	e7c7b783          	ld	a5,-388(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc0203a1c:	4505                	li	a0,1
ffffffffc0203a1e:	6f9c                	ld	a5,24(a5)
ffffffffc0203a20:	9782                	jalr	a5
ffffffffc0203a22:	8daa                	mv	s11,a0
ffffffffc0203a24:	c0e5                	beqz	s1,ffffffffc0203b04 <copy_range+0x1d2>
ffffffffc0203a26:	0a0d8f63          	beqz	s11,ffffffffc0203ae4 <copy_range+0x1b2>
ffffffffc0203a2a:	000c3783          	ld	a5,0(s8)
ffffffffc0203a2e:	00080637          	lui	a2,0x80
ffffffffc0203a32:	000cb703          	ld	a4,0(s9)
ffffffffc0203a36:	40f486b3          	sub	a3,s1,a5
ffffffffc0203a3a:	8699                	srai	a3,a3,0x6
ffffffffc0203a3c:	96b2                	add	a3,a3,a2
ffffffffc0203a3e:	0166f5b3          	and	a1,a3,s6
ffffffffc0203a42:	06b2                	slli	a3,a3,0xc
ffffffffc0203a44:	08e5f463          	bgeu	a1,a4,ffffffffc0203acc <copy_range+0x19a>
ffffffffc0203a48:	40fd87b3          	sub	a5,s11,a5
ffffffffc0203a4c:	8799                	srai	a5,a5,0x6
ffffffffc0203a4e:	97b2                	add	a5,a5,a2
ffffffffc0203a50:	0167f633          	and	a2,a5,s6
ffffffffc0203a54:	07b2                	slli	a5,a5,0xc
ffffffffc0203a56:	06e67a63          	bgeu	a2,a4,ffffffffc0203aca <copy_range+0x198>
ffffffffc0203a5a:	00093517          	auipc	a0,0x93
ffffffffc0203a5e:	e4e53503          	ld	a0,-434(a0) # ffffffffc02968a8 <va_pa_offset>
ffffffffc0203a62:	6605                	lui	a2,0x1
ffffffffc0203a64:	00a685b3          	add	a1,a3,a0
ffffffffc0203a68:	953e                	add	a0,a0,a5
ffffffffc0203a6a:	5df070ef          	jal	ffffffffc020b848 <memcpy>
ffffffffc0203a6e:	01f9f693          	andi	a3,s3,31
ffffffffc0203a72:	85ee                	mv	a1,s11
ffffffffc0203a74:	8622                	mv	a2,s0
ffffffffc0203a76:	855e                	mv	a0,s7
ffffffffc0203a78:	fb3fe0ef          	jal	ffffffffc0202a2a <page_insert>
ffffffffc0203a7c:	dd05                	beqz	a0,ffffffffc02039b4 <copy_range+0x82>
ffffffffc0203a7e:	00009697          	auipc	a3,0x9
ffffffffc0203a82:	45268693          	addi	a3,a3,1106 # ffffffffc020ced0 <etext+0x1670>
ffffffffc0203a86:	00008617          	auipc	a2,0x8
ffffffffc0203a8a:	21260613          	addi	a2,a2,530 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203a8e:	1e800593          	li	a1,488
ffffffffc0203a92:	00009517          	auipc	a0,0x9
ffffffffc0203a96:	d6e50513          	addi	a0,a0,-658 # ffffffffc020c800 <etext+0xfa0>
ffffffffc0203a9a:	9b1fc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203a9e:	002007b7          	lui	a5,0x200
ffffffffc0203aa2:	97a2                	add	a5,a5,s0
ffffffffc0203aa4:	ffe00437          	lui	s0,0xffe00
ffffffffc0203aa8:	8c7d                	and	s0,s0,a5
ffffffffc0203aaa:	b731                	j	ffffffffc02039b6 <copy_range+0x84>
ffffffffc0203aac:	92cfd0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0203ab0:	00093797          	auipc	a5,0x93
ffffffffc0203ab4:	de07b783          	ld	a5,-544(a5) # ffffffffc0296890 <pmm_manager>
ffffffffc0203ab8:	4505                	li	a0,1
ffffffffc0203aba:	6f9c                	ld	a5,24(a5)
ffffffffc0203abc:	9782                	jalr	a5
ffffffffc0203abe:	8daa                	mv	s11,a0
ffffffffc0203ac0:	912fd0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0203ac4:	b785                	j	ffffffffc0203a24 <copy_range+0xf2>
ffffffffc0203ac6:	5571                	li	a0,-4
ffffffffc0203ac8:	bddd                	j	ffffffffc02039be <copy_range+0x8c>
ffffffffc0203aca:	86be                	mv	a3,a5
ffffffffc0203acc:	00009617          	auipc	a2,0x9
ffffffffc0203ad0:	c4460613          	addi	a2,a2,-956 # ffffffffc020c710 <etext+0xeb0>
ffffffffc0203ad4:	07100593          	li	a1,113
ffffffffc0203ad8:	00009517          	auipc	a0,0x9
ffffffffc0203adc:	c6050513          	addi	a0,a0,-928 # ffffffffc020c738 <etext+0xed8>
ffffffffc0203ae0:	96bfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203ae4:	00009697          	auipc	a3,0x9
ffffffffc0203ae8:	3dc68693          	addi	a3,a3,988 # ffffffffc020cec0 <etext+0x1660>
ffffffffc0203aec:	00008617          	auipc	a2,0x8
ffffffffc0203af0:	1ac60613          	addi	a2,a2,428 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203af4:	1d000593          	li	a1,464
ffffffffc0203af8:	00009517          	auipc	a0,0x9
ffffffffc0203afc:	d0850513          	addi	a0,a0,-760 # ffffffffc020c800 <etext+0xfa0>
ffffffffc0203b00:	94bfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203b04:	00009697          	auipc	a3,0x9
ffffffffc0203b08:	3ac68693          	addi	a3,a3,940 # ffffffffc020ceb0 <etext+0x1650>
ffffffffc0203b0c:	00008617          	auipc	a2,0x8
ffffffffc0203b10:	18c60613          	addi	a2,a2,396 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203b14:	1cf00593          	li	a1,463
ffffffffc0203b18:	00009517          	auipc	a0,0x9
ffffffffc0203b1c:	ce850513          	addi	a0,a0,-792 # ffffffffc020c800 <etext+0xfa0>
ffffffffc0203b20:	92bfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203b24:	00009617          	auipc	a2,0x9
ffffffffc0203b28:	cbc60613          	addi	a2,a2,-836 # ffffffffc020c7e0 <etext+0xf80>
ffffffffc0203b2c:	06900593          	li	a1,105
ffffffffc0203b30:	00009517          	auipc	a0,0x9
ffffffffc0203b34:	c0850513          	addi	a0,a0,-1016 # ffffffffc020c738 <etext+0xed8>
ffffffffc0203b38:	913fc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203b3c:	00009617          	auipc	a2,0x9
ffffffffc0203b40:	f5460613          	addi	a2,a2,-172 # ffffffffc020ca90 <etext+0x1230>
ffffffffc0203b44:	07f00593          	li	a1,127
ffffffffc0203b48:	00009517          	auipc	a0,0x9
ffffffffc0203b4c:	bf050513          	addi	a0,a0,-1040 # ffffffffc020c738 <etext+0xed8>
ffffffffc0203b50:	8fbfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203b54:	00009697          	auipc	a3,0x9
ffffffffc0203b58:	d1468693          	addi	a3,a3,-748 # ffffffffc020c868 <etext+0x1008>
ffffffffc0203b5c:	00008617          	auipc	a2,0x8
ffffffffc0203b60:	13c60613          	addi	a2,a2,316 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203b64:	1b700593          	li	a1,439
ffffffffc0203b68:	00009517          	auipc	a0,0x9
ffffffffc0203b6c:	c9850513          	addi	a0,a0,-872 # ffffffffc020c800 <etext+0xfa0>
ffffffffc0203b70:	8dbfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203b74:	00009697          	auipc	a3,0x9
ffffffffc0203b78:	cc468693          	addi	a3,a3,-828 # ffffffffc020c838 <etext+0xfd8>
ffffffffc0203b7c:	00008617          	auipc	a2,0x8
ffffffffc0203b80:	11c60613          	addi	a2,a2,284 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203b84:	1b600593          	li	a1,438
ffffffffc0203b88:	00009517          	auipc	a0,0x9
ffffffffc0203b8c:	c7850513          	addi	a0,a0,-904 # ffffffffc020c800 <etext+0xfa0>
ffffffffc0203b90:	8bbfc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0203b94 <pgdir_alloc_page>:
ffffffffc0203b94:	7139                	addi	sp,sp,-64
ffffffffc0203b96:	f426                	sd	s1,40(sp)
ffffffffc0203b98:	f04a                	sd	s2,32(sp)
ffffffffc0203b9a:	ec4e                	sd	s3,24(sp)
ffffffffc0203b9c:	fc06                	sd	ra,56(sp)
ffffffffc0203b9e:	f822                	sd	s0,48(sp)
ffffffffc0203ba0:	892a                	mv	s2,a0
ffffffffc0203ba2:	84ae                	mv	s1,a1
ffffffffc0203ba4:	89b2                	mv	s3,a2
ffffffffc0203ba6:	100027f3          	csrr	a5,sstatus
ffffffffc0203baa:	8b89                	andi	a5,a5,2
ffffffffc0203bac:	ebb5                	bnez	a5,ffffffffc0203c20 <pgdir_alloc_page+0x8c>
ffffffffc0203bae:	00093417          	auipc	s0,0x93
ffffffffc0203bb2:	ce240413          	addi	s0,s0,-798 # ffffffffc0296890 <pmm_manager>
ffffffffc0203bb6:	601c                	ld	a5,0(s0)
ffffffffc0203bb8:	4505                	li	a0,1
ffffffffc0203bba:	6f9c                	ld	a5,24(a5)
ffffffffc0203bbc:	9782                	jalr	a5
ffffffffc0203bbe:	85aa                	mv	a1,a0
ffffffffc0203bc0:	c5b9                	beqz	a1,ffffffffc0203c0e <pgdir_alloc_page+0x7a>
ffffffffc0203bc2:	86ce                	mv	a3,s3
ffffffffc0203bc4:	854a                	mv	a0,s2
ffffffffc0203bc6:	8626                	mv	a2,s1
ffffffffc0203bc8:	e42e                	sd	a1,8(sp)
ffffffffc0203bca:	e61fe0ef          	jal	ffffffffc0202a2a <page_insert>
ffffffffc0203bce:	65a2                	ld	a1,8(sp)
ffffffffc0203bd0:	e515                	bnez	a0,ffffffffc0203bfc <pgdir_alloc_page+0x68>
ffffffffc0203bd2:	4198                	lw	a4,0(a1)
ffffffffc0203bd4:	fd84                	sd	s1,56(a1)
ffffffffc0203bd6:	4785                	li	a5,1
ffffffffc0203bd8:	02f70c63          	beq	a4,a5,ffffffffc0203c10 <pgdir_alloc_page+0x7c>
ffffffffc0203bdc:	00009697          	auipc	a3,0x9
ffffffffc0203be0:	30468693          	addi	a3,a3,772 # ffffffffc020cee0 <etext+0x1680>
ffffffffc0203be4:	00008617          	auipc	a2,0x8
ffffffffc0203be8:	0b460613          	addi	a2,a2,180 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203bec:	23200593          	li	a1,562
ffffffffc0203bf0:	00009517          	auipc	a0,0x9
ffffffffc0203bf4:	c1050513          	addi	a0,a0,-1008 # ffffffffc020c800 <etext+0xfa0>
ffffffffc0203bf8:	853fc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203bfc:	100027f3          	csrr	a5,sstatus
ffffffffc0203c00:	8b89                	andi	a5,a5,2
ffffffffc0203c02:	ef95                	bnez	a5,ffffffffc0203c3e <pgdir_alloc_page+0xaa>
ffffffffc0203c04:	601c                	ld	a5,0(s0)
ffffffffc0203c06:	852e                	mv	a0,a1
ffffffffc0203c08:	4585                	li	a1,1
ffffffffc0203c0a:	739c                	ld	a5,32(a5)
ffffffffc0203c0c:	9782                	jalr	a5
ffffffffc0203c0e:	4581                	li	a1,0
ffffffffc0203c10:	70e2                	ld	ra,56(sp)
ffffffffc0203c12:	7442                	ld	s0,48(sp)
ffffffffc0203c14:	74a2                	ld	s1,40(sp)
ffffffffc0203c16:	7902                	ld	s2,32(sp)
ffffffffc0203c18:	69e2                	ld	s3,24(sp)
ffffffffc0203c1a:	852e                	mv	a0,a1
ffffffffc0203c1c:	6121                	addi	sp,sp,64
ffffffffc0203c1e:	8082                	ret
ffffffffc0203c20:	fb9fc0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0203c24:	00093417          	auipc	s0,0x93
ffffffffc0203c28:	c6c40413          	addi	s0,s0,-916 # ffffffffc0296890 <pmm_manager>
ffffffffc0203c2c:	601c                	ld	a5,0(s0)
ffffffffc0203c2e:	4505                	li	a0,1
ffffffffc0203c30:	6f9c                	ld	a5,24(a5)
ffffffffc0203c32:	9782                	jalr	a5
ffffffffc0203c34:	e42a                	sd	a0,8(sp)
ffffffffc0203c36:	f9dfc0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0203c3a:	65a2                	ld	a1,8(sp)
ffffffffc0203c3c:	b751                	j	ffffffffc0203bc0 <pgdir_alloc_page+0x2c>
ffffffffc0203c3e:	f9bfc0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0203c42:	601c                	ld	a5,0(s0)
ffffffffc0203c44:	6522                	ld	a0,8(sp)
ffffffffc0203c46:	4585                	li	a1,1
ffffffffc0203c48:	739c                	ld	a5,32(a5)
ffffffffc0203c4a:	9782                	jalr	a5
ffffffffc0203c4c:	f87fc0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0203c50:	bf7d                	j	ffffffffc0203c0e <pgdir_alloc_page+0x7a>

ffffffffc0203c52 <check_vma_overlap.part.0>:
ffffffffc0203c52:	1141                	addi	sp,sp,-16
ffffffffc0203c54:	00009697          	auipc	a3,0x9
ffffffffc0203c58:	2a468693          	addi	a3,a3,676 # ffffffffc020cef8 <etext+0x1698>
ffffffffc0203c5c:	00008617          	auipc	a2,0x8
ffffffffc0203c60:	03c60613          	addi	a2,a2,60 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203c64:	07400593          	li	a1,116
ffffffffc0203c68:	00009517          	auipc	a0,0x9
ffffffffc0203c6c:	2b050513          	addi	a0,a0,688 # ffffffffc020cf18 <etext+0x16b8>
ffffffffc0203c70:	e406                	sd	ra,8(sp)
ffffffffc0203c72:	fd8fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0203c76 <mm_create>:
ffffffffc0203c76:	1101                	addi	sp,sp,-32
ffffffffc0203c78:	05800513          	li	a0,88
ffffffffc0203c7c:	ec06                	sd	ra,24(sp)
ffffffffc0203c7e:	b42fe0ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc0203c82:	87aa                	mv	a5,a0
ffffffffc0203c84:	c505                	beqz	a0,ffffffffc0203cac <mm_create+0x36>
ffffffffc0203c86:	e788                	sd	a0,8(a5)
ffffffffc0203c88:	e388                	sd	a0,0(a5)
ffffffffc0203c8a:	00053823          	sd	zero,16(a0)
ffffffffc0203c8e:	00053c23          	sd	zero,24(a0)
ffffffffc0203c92:	02052023          	sw	zero,32(a0)
ffffffffc0203c96:	02053423          	sd	zero,40(a0)
ffffffffc0203c9a:	02052823          	sw	zero,48(a0)
ffffffffc0203c9e:	4585                	li	a1,1
ffffffffc0203ca0:	03850513          	addi	a0,a0,56
ffffffffc0203ca4:	e43e                	sd	a5,8(sp)
ffffffffc0203ca6:	147000ef          	jal	ffffffffc02045ec <sem_init>
ffffffffc0203caa:	67a2                	ld	a5,8(sp)
ffffffffc0203cac:	60e2                	ld	ra,24(sp)
ffffffffc0203cae:	853e                	mv	a0,a5
ffffffffc0203cb0:	6105                	addi	sp,sp,32
ffffffffc0203cb2:	8082                	ret

ffffffffc0203cb4 <find_vma>:
ffffffffc0203cb4:	c505                	beqz	a0,ffffffffc0203cdc <find_vma+0x28>
ffffffffc0203cb6:	691c                	ld	a5,16(a0)
ffffffffc0203cb8:	c781                	beqz	a5,ffffffffc0203cc0 <find_vma+0xc>
ffffffffc0203cba:	6798                	ld	a4,8(a5)
ffffffffc0203cbc:	02e5f363          	bgeu	a1,a4,ffffffffc0203ce2 <find_vma+0x2e>
ffffffffc0203cc0:	651c                	ld	a5,8(a0)
ffffffffc0203cc2:	00f50d63          	beq	a0,a5,ffffffffc0203cdc <find_vma+0x28>
ffffffffc0203cc6:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203cca:	00e5e663          	bltu	a1,a4,ffffffffc0203cd6 <find_vma+0x22>
ffffffffc0203cce:	ff07b703          	ld	a4,-16(a5)
ffffffffc0203cd2:	00e5ee63          	bltu	a1,a4,ffffffffc0203cee <find_vma+0x3a>
ffffffffc0203cd6:	679c                	ld	a5,8(a5)
ffffffffc0203cd8:	fef517e3          	bne	a0,a5,ffffffffc0203cc6 <find_vma+0x12>
ffffffffc0203cdc:	4781                	li	a5,0
ffffffffc0203cde:	853e                	mv	a0,a5
ffffffffc0203ce0:	8082                	ret
ffffffffc0203ce2:	6b98                	ld	a4,16(a5)
ffffffffc0203ce4:	fce5fee3          	bgeu	a1,a4,ffffffffc0203cc0 <find_vma+0xc>
ffffffffc0203ce8:	e91c                	sd	a5,16(a0)
ffffffffc0203cea:	853e                	mv	a0,a5
ffffffffc0203cec:	8082                	ret
ffffffffc0203cee:	1781                	addi	a5,a5,-32
ffffffffc0203cf0:	e91c                	sd	a5,16(a0)
ffffffffc0203cf2:	bfe5                	j	ffffffffc0203cea <find_vma+0x36>

ffffffffc0203cf4 <insert_vma_struct>:
ffffffffc0203cf4:	6590                	ld	a2,8(a1)
ffffffffc0203cf6:	0105b803          	ld	a6,16(a1)
ffffffffc0203cfa:	1141                	addi	sp,sp,-16
ffffffffc0203cfc:	e406                	sd	ra,8(sp)
ffffffffc0203cfe:	87aa                	mv	a5,a0
ffffffffc0203d00:	01066763          	bltu	a2,a6,ffffffffc0203d0e <insert_vma_struct+0x1a>
ffffffffc0203d04:	a8b9                	j	ffffffffc0203d62 <insert_vma_struct+0x6e>
ffffffffc0203d06:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203d0a:	04e66763          	bltu	a2,a4,ffffffffc0203d58 <insert_vma_struct+0x64>
ffffffffc0203d0e:	86be                	mv	a3,a5
ffffffffc0203d10:	679c                	ld	a5,8(a5)
ffffffffc0203d12:	fef51ae3          	bne	a0,a5,ffffffffc0203d06 <insert_vma_struct+0x12>
ffffffffc0203d16:	02a68463          	beq	a3,a0,ffffffffc0203d3e <insert_vma_struct+0x4a>
ffffffffc0203d1a:	ff06b703          	ld	a4,-16(a3)
ffffffffc0203d1e:	fe86b883          	ld	a7,-24(a3)
ffffffffc0203d22:	08e8f063          	bgeu	a7,a4,ffffffffc0203da2 <insert_vma_struct+0xae>
ffffffffc0203d26:	04e66e63          	bltu	a2,a4,ffffffffc0203d82 <insert_vma_struct+0x8e>
ffffffffc0203d2a:	00f50a63          	beq	a0,a5,ffffffffc0203d3e <insert_vma_struct+0x4a>
ffffffffc0203d2e:	fe87b703          	ld	a4,-24(a5)
ffffffffc0203d32:	05076863          	bltu	a4,a6,ffffffffc0203d82 <insert_vma_struct+0x8e>
ffffffffc0203d36:	ff07b603          	ld	a2,-16(a5)
ffffffffc0203d3a:	02c77263          	bgeu	a4,a2,ffffffffc0203d5e <insert_vma_struct+0x6a>
ffffffffc0203d3e:	5118                	lw	a4,32(a0)
ffffffffc0203d40:	e188                	sd	a0,0(a1)
ffffffffc0203d42:	02058613          	addi	a2,a1,32
ffffffffc0203d46:	e390                	sd	a2,0(a5)
ffffffffc0203d48:	e690                	sd	a2,8(a3)
ffffffffc0203d4a:	60a2                	ld	ra,8(sp)
ffffffffc0203d4c:	f59c                	sd	a5,40(a1)
ffffffffc0203d4e:	f194                	sd	a3,32(a1)
ffffffffc0203d50:	2705                	addiw	a4,a4,1
ffffffffc0203d52:	d118                	sw	a4,32(a0)
ffffffffc0203d54:	0141                	addi	sp,sp,16
ffffffffc0203d56:	8082                	ret
ffffffffc0203d58:	fca691e3          	bne	a3,a0,ffffffffc0203d1a <insert_vma_struct+0x26>
ffffffffc0203d5c:	bfd9                	j	ffffffffc0203d32 <insert_vma_struct+0x3e>
ffffffffc0203d5e:	ef5ff0ef          	jal	ffffffffc0203c52 <check_vma_overlap.part.0>
ffffffffc0203d62:	00009697          	auipc	a3,0x9
ffffffffc0203d66:	1c668693          	addi	a3,a3,454 # ffffffffc020cf28 <etext+0x16c8>
ffffffffc0203d6a:	00008617          	auipc	a2,0x8
ffffffffc0203d6e:	f2e60613          	addi	a2,a2,-210 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203d72:	07a00593          	li	a1,122
ffffffffc0203d76:	00009517          	auipc	a0,0x9
ffffffffc0203d7a:	1a250513          	addi	a0,a0,418 # ffffffffc020cf18 <etext+0x16b8>
ffffffffc0203d7e:	eccfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203d82:	00009697          	auipc	a3,0x9
ffffffffc0203d86:	1e668693          	addi	a3,a3,486 # ffffffffc020cf68 <etext+0x1708>
ffffffffc0203d8a:	00008617          	auipc	a2,0x8
ffffffffc0203d8e:	f0e60613          	addi	a2,a2,-242 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203d92:	07300593          	li	a1,115
ffffffffc0203d96:	00009517          	auipc	a0,0x9
ffffffffc0203d9a:	18250513          	addi	a0,a0,386 # ffffffffc020cf18 <etext+0x16b8>
ffffffffc0203d9e:	eacfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0203da2:	00009697          	auipc	a3,0x9
ffffffffc0203da6:	1a668693          	addi	a3,a3,422 # ffffffffc020cf48 <etext+0x16e8>
ffffffffc0203daa:	00008617          	auipc	a2,0x8
ffffffffc0203dae:	eee60613          	addi	a2,a2,-274 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203db2:	07200593          	li	a1,114
ffffffffc0203db6:	00009517          	auipc	a0,0x9
ffffffffc0203dba:	16250513          	addi	a0,a0,354 # ffffffffc020cf18 <etext+0x16b8>
ffffffffc0203dbe:	e8cfc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0203dc2 <mm_destroy>:
ffffffffc0203dc2:	591c                	lw	a5,48(a0)
ffffffffc0203dc4:	1141                	addi	sp,sp,-16
ffffffffc0203dc6:	e406                	sd	ra,8(sp)
ffffffffc0203dc8:	e022                	sd	s0,0(sp)
ffffffffc0203dca:	e78d                	bnez	a5,ffffffffc0203df4 <mm_destroy+0x32>
ffffffffc0203dcc:	842a                	mv	s0,a0
ffffffffc0203dce:	6508                	ld	a0,8(a0)
ffffffffc0203dd0:	00a40c63          	beq	s0,a0,ffffffffc0203de8 <mm_destroy+0x26>
ffffffffc0203dd4:	6118                	ld	a4,0(a0)
ffffffffc0203dd6:	651c                	ld	a5,8(a0)
ffffffffc0203dd8:	1501                	addi	a0,a0,-32
ffffffffc0203dda:	e71c                	sd	a5,8(a4)
ffffffffc0203ddc:	e398                	sd	a4,0(a5)
ffffffffc0203dde:	a88fe0ef          	jal	ffffffffc0202066 <kfree>
ffffffffc0203de2:	6408                	ld	a0,8(s0)
ffffffffc0203de4:	fea418e3          	bne	s0,a0,ffffffffc0203dd4 <mm_destroy+0x12>
ffffffffc0203de8:	8522                	mv	a0,s0
ffffffffc0203dea:	6402                	ld	s0,0(sp)
ffffffffc0203dec:	60a2                	ld	ra,8(sp)
ffffffffc0203dee:	0141                	addi	sp,sp,16
ffffffffc0203df0:	a76fe06f          	j	ffffffffc0202066 <kfree>
ffffffffc0203df4:	00009697          	auipc	a3,0x9
ffffffffc0203df8:	19468693          	addi	a3,a3,404 # ffffffffc020cf88 <etext+0x1728>
ffffffffc0203dfc:	00008617          	auipc	a2,0x8
ffffffffc0203e00:	e9c60613          	addi	a2,a2,-356 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203e04:	09e00593          	li	a1,158
ffffffffc0203e08:	00009517          	auipc	a0,0x9
ffffffffc0203e0c:	11050513          	addi	a0,a0,272 # ffffffffc020cf18 <etext+0x16b8>
ffffffffc0203e10:	e3afc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0203e14 <mm_map>:
ffffffffc0203e14:	6785                	lui	a5,0x1
ffffffffc0203e16:	17fd                	addi	a5,a5,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc0203e18:	963e                	add	a2,a2,a5
ffffffffc0203e1a:	4785                	li	a5,1
ffffffffc0203e1c:	7139                	addi	sp,sp,-64
ffffffffc0203e1e:	962e                	add	a2,a2,a1
ffffffffc0203e20:	787d                	lui	a6,0xfffff
ffffffffc0203e22:	07fe                	slli	a5,a5,0x1f
ffffffffc0203e24:	f822                	sd	s0,48(sp)
ffffffffc0203e26:	f426                	sd	s1,40(sp)
ffffffffc0203e28:	01067433          	and	s0,a2,a6
ffffffffc0203e2c:	0105f4b3          	and	s1,a1,a6
ffffffffc0203e30:	0785                	addi	a5,a5,1
ffffffffc0203e32:	0084b633          	sltu	a2,s1,s0
ffffffffc0203e36:	00f437b3          	sltu	a5,s0,a5
ffffffffc0203e3a:	00163613          	seqz	a2,a2
ffffffffc0203e3e:	0017b793          	seqz	a5,a5
ffffffffc0203e42:	fc06                	sd	ra,56(sp)
ffffffffc0203e44:	8fd1                	or	a5,a5,a2
ffffffffc0203e46:	ebbd                	bnez	a5,ffffffffc0203ebc <mm_map+0xa8>
ffffffffc0203e48:	002007b7          	lui	a5,0x200
ffffffffc0203e4c:	06f4e863          	bltu	s1,a5,ffffffffc0203ebc <mm_map+0xa8>
ffffffffc0203e50:	f04a                	sd	s2,32(sp)
ffffffffc0203e52:	ec4e                	sd	s3,24(sp)
ffffffffc0203e54:	e852                	sd	s4,16(sp)
ffffffffc0203e56:	892a                	mv	s2,a0
ffffffffc0203e58:	89ba                	mv	s3,a4
ffffffffc0203e5a:	8a36                	mv	s4,a3
ffffffffc0203e5c:	c135                	beqz	a0,ffffffffc0203ec0 <mm_map+0xac>
ffffffffc0203e5e:	85a6                	mv	a1,s1
ffffffffc0203e60:	e55ff0ef          	jal	ffffffffc0203cb4 <find_vma>
ffffffffc0203e64:	c501                	beqz	a0,ffffffffc0203e6c <mm_map+0x58>
ffffffffc0203e66:	651c                	ld	a5,8(a0)
ffffffffc0203e68:	0487e763          	bltu	a5,s0,ffffffffc0203eb6 <mm_map+0xa2>
ffffffffc0203e6c:	03000513          	li	a0,48
ffffffffc0203e70:	950fe0ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc0203e74:	85aa                	mv	a1,a0
ffffffffc0203e76:	5571                	li	a0,-4
ffffffffc0203e78:	c59d                	beqz	a1,ffffffffc0203ea6 <mm_map+0x92>
ffffffffc0203e7a:	e584                	sd	s1,8(a1)
ffffffffc0203e7c:	e980                	sd	s0,16(a1)
ffffffffc0203e7e:	0145ac23          	sw	s4,24(a1)
ffffffffc0203e82:	854a                	mv	a0,s2
ffffffffc0203e84:	e42e                	sd	a1,8(sp)
ffffffffc0203e86:	e6fff0ef          	jal	ffffffffc0203cf4 <insert_vma_struct>
ffffffffc0203e8a:	65a2                	ld	a1,8(sp)
ffffffffc0203e8c:	00098463          	beqz	s3,ffffffffc0203e94 <mm_map+0x80>
ffffffffc0203e90:	00b9b023          	sd	a1,0(s3)
ffffffffc0203e94:	7902                	ld	s2,32(sp)
ffffffffc0203e96:	69e2                	ld	s3,24(sp)
ffffffffc0203e98:	6a42                	ld	s4,16(sp)
ffffffffc0203e9a:	4501                	li	a0,0
ffffffffc0203e9c:	70e2                	ld	ra,56(sp)
ffffffffc0203e9e:	7442                	ld	s0,48(sp)
ffffffffc0203ea0:	74a2                	ld	s1,40(sp)
ffffffffc0203ea2:	6121                	addi	sp,sp,64
ffffffffc0203ea4:	8082                	ret
ffffffffc0203ea6:	70e2                	ld	ra,56(sp)
ffffffffc0203ea8:	7442                	ld	s0,48(sp)
ffffffffc0203eaa:	7902                	ld	s2,32(sp)
ffffffffc0203eac:	69e2                	ld	s3,24(sp)
ffffffffc0203eae:	6a42                	ld	s4,16(sp)
ffffffffc0203eb0:	74a2                	ld	s1,40(sp)
ffffffffc0203eb2:	6121                	addi	sp,sp,64
ffffffffc0203eb4:	8082                	ret
ffffffffc0203eb6:	7902                	ld	s2,32(sp)
ffffffffc0203eb8:	69e2                	ld	s3,24(sp)
ffffffffc0203eba:	6a42                	ld	s4,16(sp)
ffffffffc0203ebc:	5575                	li	a0,-3
ffffffffc0203ebe:	bff9                	j	ffffffffc0203e9c <mm_map+0x88>
ffffffffc0203ec0:	00009697          	auipc	a3,0x9
ffffffffc0203ec4:	0e068693          	addi	a3,a3,224 # ffffffffc020cfa0 <etext+0x1740>
ffffffffc0203ec8:	00008617          	auipc	a2,0x8
ffffffffc0203ecc:	dd060613          	addi	a2,a2,-560 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203ed0:	0b300593          	li	a1,179
ffffffffc0203ed4:	00009517          	auipc	a0,0x9
ffffffffc0203ed8:	04450513          	addi	a0,a0,68 # ffffffffc020cf18 <etext+0x16b8>
ffffffffc0203edc:	d6efc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0203ee0 <dup_mmap>:
ffffffffc0203ee0:	7139                	addi	sp,sp,-64
ffffffffc0203ee2:	fc06                	sd	ra,56(sp)
ffffffffc0203ee4:	f822                	sd	s0,48(sp)
ffffffffc0203ee6:	f426                	sd	s1,40(sp)
ffffffffc0203ee8:	f04a                	sd	s2,32(sp)
ffffffffc0203eea:	ec4e                	sd	s3,24(sp)
ffffffffc0203eec:	e852                	sd	s4,16(sp)
ffffffffc0203eee:	e456                	sd	s5,8(sp)
ffffffffc0203ef0:	c525                	beqz	a0,ffffffffc0203f58 <dup_mmap+0x78>
ffffffffc0203ef2:	892a                	mv	s2,a0
ffffffffc0203ef4:	84ae                	mv	s1,a1
ffffffffc0203ef6:	842e                	mv	s0,a1
ffffffffc0203ef8:	c1a5                	beqz	a1,ffffffffc0203f58 <dup_mmap+0x78>
ffffffffc0203efa:	6000                	ld	s0,0(s0)
ffffffffc0203efc:	04848c63          	beq	s1,s0,ffffffffc0203f54 <dup_mmap+0x74>
ffffffffc0203f00:	03000513          	li	a0,48
ffffffffc0203f04:	fe843a83          	ld	s5,-24(s0)
ffffffffc0203f08:	ff043a03          	ld	s4,-16(s0)
ffffffffc0203f0c:	ff842983          	lw	s3,-8(s0)
ffffffffc0203f10:	8b0fe0ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc0203f14:	c515                	beqz	a0,ffffffffc0203f40 <dup_mmap+0x60>
ffffffffc0203f16:	85aa                	mv	a1,a0
ffffffffc0203f18:	01553423          	sd	s5,8(a0)
ffffffffc0203f1c:	01453823          	sd	s4,16(a0)
ffffffffc0203f20:	01352c23          	sw	s3,24(a0)
ffffffffc0203f24:	854a                	mv	a0,s2
ffffffffc0203f26:	dcfff0ef          	jal	ffffffffc0203cf4 <insert_vma_struct>
ffffffffc0203f2a:	ff043683          	ld	a3,-16(s0)
ffffffffc0203f2e:	fe843603          	ld	a2,-24(s0)
ffffffffc0203f32:	6c8c                	ld	a1,24(s1)
ffffffffc0203f34:	01893503          	ld	a0,24(s2)
ffffffffc0203f38:	4701                	li	a4,0
ffffffffc0203f3a:	9f9ff0ef          	jal	ffffffffc0203932 <copy_range>
ffffffffc0203f3e:	dd55                	beqz	a0,ffffffffc0203efa <dup_mmap+0x1a>
ffffffffc0203f40:	5571                	li	a0,-4
ffffffffc0203f42:	70e2                	ld	ra,56(sp)
ffffffffc0203f44:	7442                	ld	s0,48(sp)
ffffffffc0203f46:	74a2                	ld	s1,40(sp)
ffffffffc0203f48:	7902                	ld	s2,32(sp)
ffffffffc0203f4a:	69e2                	ld	s3,24(sp)
ffffffffc0203f4c:	6a42                	ld	s4,16(sp)
ffffffffc0203f4e:	6aa2                	ld	s5,8(sp)
ffffffffc0203f50:	6121                	addi	sp,sp,64
ffffffffc0203f52:	8082                	ret
ffffffffc0203f54:	4501                	li	a0,0
ffffffffc0203f56:	b7f5                	j	ffffffffc0203f42 <dup_mmap+0x62>
ffffffffc0203f58:	00009697          	auipc	a3,0x9
ffffffffc0203f5c:	05868693          	addi	a3,a3,88 # ffffffffc020cfb0 <etext+0x1750>
ffffffffc0203f60:	00008617          	auipc	a2,0x8
ffffffffc0203f64:	d3860613          	addi	a2,a2,-712 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203f68:	0cf00593          	li	a1,207
ffffffffc0203f6c:	00009517          	auipc	a0,0x9
ffffffffc0203f70:	fac50513          	addi	a0,a0,-84 # ffffffffc020cf18 <etext+0x16b8>
ffffffffc0203f74:	cd6fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0203f78 <exit_mmap>:
ffffffffc0203f78:	1101                	addi	sp,sp,-32
ffffffffc0203f7a:	ec06                	sd	ra,24(sp)
ffffffffc0203f7c:	e822                	sd	s0,16(sp)
ffffffffc0203f7e:	e426                	sd	s1,8(sp)
ffffffffc0203f80:	e04a                	sd	s2,0(sp)
ffffffffc0203f82:	c531                	beqz	a0,ffffffffc0203fce <exit_mmap+0x56>
ffffffffc0203f84:	591c                	lw	a5,48(a0)
ffffffffc0203f86:	84aa                	mv	s1,a0
ffffffffc0203f88:	e3b9                	bnez	a5,ffffffffc0203fce <exit_mmap+0x56>
ffffffffc0203f8a:	6500                	ld	s0,8(a0)
ffffffffc0203f8c:	01853903          	ld	s2,24(a0)
ffffffffc0203f90:	02850663          	beq	a0,s0,ffffffffc0203fbc <exit_mmap+0x44>
ffffffffc0203f94:	ff043603          	ld	a2,-16(s0)
ffffffffc0203f98:	fe843583          	ld	a1,-24(s0)
ffffffffc0203f9c:	854a                	mv	a0,s2
ffffffffc0203f9e:	e08fe0ef          	jal	ffffffffc02025a6 <unmap_range>
ffffffffc0203fa2:	6400                	ld	s0,8(s0)
ffffffffc0203fa4:	fe8498e3          	bne	s1,s0,ffffffffc0203f94 <exit_mmap+0x1c>
ffffffffc0203fa8:	6400                	ld	s0,8(s0)
ffffffffc0203faa:	00848c63          	beq	s1,s0,ffffffffc0203fc2 <exit_mmap+0x4a>
ffffffffc0203fae:	ff043603          	ld	a2,-16(s0)
ffffffffc0203fb2:	fe843583          	ld	a1,-24(s0)
ffffffffc0203fb6:	854a                	mv	a0,s2
ffffffffc0203fb8:	f22fe0ef          	jal	ffffffffc02026da <exit_range>
ffffffffc0203fbc:	6400                	ld	s0,8(s0)
ffffffffc0203fbe:	fe8498e3          	bne	s1,s0,ffffffffc0203fae <exit_mmap+0x36>
ffffffffc0203fc2:	60e2                	ld	ra,24(sp)
ffffffffc0203fc4:	6442                	ld	s0,16(sp)
ffffffffc0203fc6:	64a2                	ld	s1,8(sp)
ffffffffc0203fc8:	6902                	ld	s2,0(sp)
ffffffffc0203fca:	6105                	addi	sp,sp,32
ffffffffc0203fcc:	8082                	ret
ffffffffc0203fce:	00009697          	auipc	a3,0x9
ffffffffc0203fd2:	00268693          	addi	a3,a3,2 # ffffffffc020cfd0 <etext+0x1770>
ffffffffc0203fd6:	00008617          	auipc	a2,0x8
ffffffffc0203fda:	cc260613          	addi	a2,a2,-830 # ffffffffc020bc98 <etext+0x438>
ffffffffc0203fde:	0e800593          	li	a1,232
ffffffffc0203fe2:	00009517          	auipc	a0,0x9
ffffffffc0203fe6:	f3650513          	addi	a0,a0,-202 # ffffffffc020cf18 <etext+0x16b8>
ffffffffc0203fea:	c60fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0203fee <vmm_init>:
ffffffffc0203fee:	7179                	addi	sp,sp,-48
ffffffffc0203ff0:	05800513          	li	a0,88
ffffffffc0203ff4:	f406                	sd	ra,40(sp)
ffffffffc0203ff6:	f022                	sd	s0,32(sp)
ffffffffc0203ff8:	ec26                	sd	s1,24(sp)
ffffffffc0203ffa:	e84a                	sd	s2,16(sp)
ffffffffc0203ffc:	e44e                	sd	s3,8(sp)
ffffffffc0203ffe:	e052                	sd	s4,0(sp)
ffffffffc0204000:	fc1fd0ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc0204004:	16050f63          	beqz	a0,ffffffffc0204182 <vmm_init+0x194>
ffffffffc0204008:	e508                	sd	a0,8(a0)
ffffffffc020400a:	e108                	sd	a0,0(a0)
ffffffffc020400c:	00053823          	sd	zero,16(a0)
ffffffffc0204010:	00053c23          	sd	zero,24(a0)
ffffffffc0204014:	02052023          	sw	zero,32(a0)
ffffffffc0204018:	02053423          	sd	zero,40(a0)
ffffffffc020401c:	02052823          	sw	zero,48(a0)
ffffffffc0204020:	842a                	mv	s0,a0
ffffffffc0204022:	4585                	li	a1,1
ffffffffc0204024:	03850513          	addi	a0,a0,56
ffffffffc0204028:	5c4000ef          	jal	ffffffffc02045ec <sem_init>
ffffffffc020402c:	03200493          	li	s1,50
ffffffffc0204030:	03000513          	li	a0,48
ffffffffc0204034:	f8dfd0ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc0204038:	12050563          	beqz	a0,ffffffffc0204162 <vmm_init+0x174>
ffffffffc020403c:	00248793          	addi	a5,s1,2
ffffffffc0204040:	e504                	sd	s1,8(a0)
ffffffffc0204042:	00052c23          	sw	zero,24(a0)
ffffffffc0204046:	e91c                	sd	a5,16(a0)
ffffffffc0204048:	85aa                	mv	a1,a0
ffffffffc020404a:	14ed                	addi	s1,s1,-5
ffffffffc020404c:	8522                	mv	a0,s0
ffffffffc020404e:	ca7ff0ef          	jal	ffffffffc0203cf4 <insert_vma_struct>
ffffffffc0204052:	fcf9                	bnez	s1,ffffffffc0204030 <vmm_init+0x42>
ffffffffc0204054:	03700493          	li	s1,55
ffffffffc0204058:	1f900913          	li	s2,505
ffffffffc020405c:	03000513          	li	a0,48
ffffffffc0204060:	f61fd0ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc0204064:	12050f63          	beqz	a0,ffffffffc02041a2 <vmm_init+0x1b4>
ffffffffc0204068:	00248793          	addi	a5,s1,2
ffffffffc020406c:	e504                	sd	s1,8(a0)
ffffffffc020406e:	00052c23          	sw	zero,24(a0)
ffffffffc0204072:	e91c                	sd	a5,16(a0)
ffffffffc0204074:	85aa                	mv	a1,a0
ffffffffc0204076:	0495                	addi	s1,s1,5
ffffffffc0204078:	8522                	mv	a0,s0
ffffffffc020407a:	c7bff0ef          	jal	ffffffffc0203cf4 <insert_vma_struct>
ffffffffc020407e:	fd249fe3          	bne	s1,s2,ffffffffc020405c <vmm_init+0x6e>
ffffffffc0204082:	641c                	ld	a5,8(s0)
ffffffffc0204084:	471d                	li	a4,7
ffffffffc0204086:	1fb00593          	li	a1,507
ffffffffc020408a:	1ef40c63          	beq	s0,a5,ffffffffc0204282 <vmm_init+0x294>
ffffffffc020408e:	fe87b603          	ld	a2,-24(a5) # 1fffe8 <_binary_bin_sfs_img_size+0x18ace8>
ffffffffc0204092:	ffe70693          	addi	a3,a4,-2
ffffffffc0204096:	12d61663          	bne	a2,a3,ffffffffc02041c2 <vmm_init+0x1d4>
ffffffffc020409a:	ff07b683          	ld	a3,-16(a5)
ffffffffc020409e:	12e69263          	bne	a3,a4,ffffffffc02041c2 <vmm_init+0x1d4>
ffffffffc02040a2:	0715                	addi	a4,a4,5
ffffffffc02040a4:	679c                	ld	a5,8(a5)
ffffffffc02040a6:	feb712e3          	bne	a4,a1,ffffffffc020408a <vmm_init+0x9c>
ffffffffc02040aa:	491d                	li	s2,7
ffffffffc02040ac:	4495                	li	s1,5
ffffffffc02040ae:	85a6                	mv	a1,s1
ffffffffc02040b0:	8522                	mv	a0,s0
ffffffffc02040b2:	c03ff0ef          	jal	ffffffffc0203cb4 <find_vma>
ffffffffc02040b6:	8a2a                	mv	s4,a0
ffffffffc02040b8:	20050563          	beqz	a0,ffffffffc02042c2 <vmm_init+0x2d4>
ffffffffc02040bc:	00148593          	addi	a1,s1,1
ffffffffc02040c0:	8522                	mv	a0,s0
ffffffffc02040c2:	bf3ff0ef          	jal	ffffffffc0203cb4 <find_vma>
ffffffffc02040c6:	89aa                	mv	s3,a0
ffffffffc02040c8:	1c050d63          	beqz	a0,ffffffffc02042a2 <vmm_init+0x2b4>
ffffffffc02040cc:	85ca                	mv	a1,s2
ffffffffc02040ce:	8522                	mv	a0,s0
ffffffffc02040d0:	be5ff0ef          	jal	ffffffffc0203cb4 <find_vma>
ffffffffc02040d4:	18051763          	bnez	a0,ffffffffc0204262 <vmm_init+0x274>
ffffffffc02040d8:	00348593          	addi	a1,s1,3
ffffffffc02040dc:	8522                	mv	a0,s0
ffffffffc02040de:	bd7ff0ef          	jal	ffffffffc0203cb4 <find_vma>
ffffffffc02040e2:	16051063          	bnez	a0,ffffffffc0204242 <vmm_init+0x254>
ffffffffc02040e6:	00448593          	addi	a1,s1,4
ffffffffc02040ea:	8522                	mv	a0,s0
ffffffffc02040ec:	bc9ff0ef          	jal	ffffffffc0203cb4 <find_vma>
ffffffffc02040f0:	12051963          	bnez	a0,ffffffffc0204222 <vmm_init+0x234>
ffffffffc02040f4:	008a3783          	ld	a5,8(s4)
ffffffffc02040f8:	10979563          	bne	a5,s1,ffffffffc0204202 <vmm_init+0x214>
ffffffffc02040fc:	010a3783          	ld	a5,16(s4)
ffffffffc0204100:	11279163          	bne	a5,s2,ffffffffc0204202 <vmm_init+0x214>
ffffffffc0204104:	0089b783          	ld	a5,8(s3)
ffffffffc0204108:	0c979d63          	bne	a5,s1,ffffffffc02041e2 <vmm_init+0x1f4>
ffffffffc020410c:	0109b783          	ld	a5,16(s3)
ffffffffc0204110:	0d279963          	bne	a5,s2,ffffffffc02041e2 <vmm_init+0x1f4>
ffffffffc0204114:	0495                	addi	s1,s1,5
ffffffffc0204116:	1f900793          	li	a5,505
ffffffffc020411a:	0915                	addi	s2,s2,5
ffffffffc020411c:	f8f499e3          	bne	s1,a5,ffffffffc02040ae <vmm_init+0xc0>
ffffffffc0204120:	4491                	li	s1,4
ffffffffc0204122:	597d                	li	s2,-1
ffffffffc0204124:	85a6                	mv	a1,s1
ffffffffc0204126:	8522                	mv	a0,s0
ffffffffc0204128:	b8dff0ef          	jal	ffffffffc0203cb4 <find_vma>
ffffffffc020412c:	1a051b63          	bnez	a0,ffffffffc02042e2 <vmm_init+0x2f4>
ffffffffc0204130:	14fd                	addi	s1,s1,-1
ffffffffc0204132:	ff2499e3          	bne	s1,s2,ffffffffc0204124 <vmm_init+0x136>
ffffffffc0204136:	8522                	mv	a0,s0
ffffffffc0204138:	c8bff0ef          	jal	ffffffffc0203dc2 <mm_destroy>
ffffffffc020413c:	00009517          	auipc	a0,0x9
ffffffffc0204140:	00450513          	addi	a0,a0,4 # ffffffffc020d140 <etext+0x18e0>
ffffffffc0204144:	862fc0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0204148:	7402                	ld	s0,32(sp)
ffffffffc020414a:	70a2                	ld	ra,40(sp)
ffffffffc020414c:	64e2                	ld	s1,24(sp)
ffffffffc020414e:	6942                	ld	s2,16(sp)
ffffffffc0204150:	69a2                	ld	s3,8(sp)
ffffffffc0204152:	6a02                	ld	s4,0(sp)
ffffffffc0204154:	00009517          	auipc	a0,0x9
ffffffffc0204158:	00c50513          	addi	a0,a0,12 # ffffffffc020d160 <etext+0x1900>
ffffffffc020415c:	6145                	addi	sp,sp,48
ffffffffc020415e:	848fc06f          	j	ffffffffc02001a6 <cprintf>
ffffffffc0204162:	00009697          	auipc	a3,0x9
ffffffffc0204166:	e8e68693          	addi	a3,a3,-370 # ffffffffc020cff0 <etext+0x1790>
ffffffffc020416a:	00008617          	auipc	a2,0x8
ffffffffc020416e:	b2e60613          	addi	a2,a2,-1234 # ffffffffc020bc98 <etext+0x438>
ffffffffc0204172:	12c00593          	li	a1,300
ffffffffc0204176:	00009517          	auipc	a0,0x9
ffffffffc020417a:	da250513          	addi	a0,a0,-606 # ffffffffc020cf18 <etext+0x16b8>
ffffffffc020417e:	accfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0204182:	00009697          	auipc	a3,0x9
ffffffffc0204186:	e1e68693          	addi	a3,a3,-482 # ffffffffc020cfa0 <etext+0x1740>
ffffffffc020418a:	00008617          	auipc	a2,0x8
ffffffffc020418e:	b0e60613          	addi	a2,a2,-1266 # ffffffffc020bc98 <etext+0x438>
ffffffffc0204192:	12400593          	li	a1,292
ffffffffc0204196:	00009517          	auipc	a0,0x9
ffffffffc020419a:	d8250513          	addi	a0,a0,-638 # ffffffffc020cf18 <etext+0x16b8>
ffffffffc020419e:	aacfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02041a2:	00009697          	auipc	a3,0x9
ffffffffc02041a6:	e4e68693          	addi	a3,a3,-434 # ffffffffc020cff0 <etext+0x1790>
ffffffffc02041aa:	00008617          	auipc	a2,0x8
ffffffffc02041ae:	aee60613          	addi	a2,a2,-1298 # ffffffffc020bc98 <etext+0x438>
ffffffffc02041b2:	13300593          	li	a1,307
ffffffffc02041b6:	00009517          	auipc	a0,0x9
ffffffffc02041ba:	d6250513          	addi	a0,a0,-670 # ffffffffc020cf18 <etext+0x16b8>
ffffffffc02041be:	a8cfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02041c2:	00009697          	auipc	a3,0x9
ffffffffc02041c6:	e5668693          	addi	a3,a3,-426 # ffffffffc020d018 <etext+0x17b8>
ffffffffc02041ca:	00008617          	auipc	a2,0x8
ffffffffc02041ce:	ace60613          	addi	a2,a2,-1330 # ffffffffc020bc98 <etext+0x438>
ffffffffc02041d2:	13d00593          	li	a1,317
ffffffffc02041d6:	00009517          	auipc	a0,0x9
ffffffffc02041da:	d4250513          	addi	a0,a0,-702 # ffffffffc020cf18 <etext+0x16b8>
ffffffffc02041de:	a6cfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02041e2:	00009697          	auipc	a3,0x9
ffffffffc02041e6:	eee68693          	addi	a3,a3,-274 # ffffffffc020d0d0 <etext+0x1870>
ffffffffc02041ea:	00008617          	auipc	a2,0x8
ffffffffc02041ee:	aae60613          	addi	a2,a2,-1362 # ffffffffc020bc98 <etext+0x438>
ffffffffc02041f2:	14f00593          	li	a1,335
ffffffffc02041f6:	00009517          	auipc	a0,0x9
ffffffffc02041fa:	d2250513          	addi	a0,a0,-734 # ffffffffc020cf18 <etext+0x16b8>
ffffffffc02041fe:	a4cfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0204202:	00009697          	auipc	a3,0x9
ffffffffc0204206:	e9e68693          	addi	a3,a3,-354 # ffffffffc020d0a0 <etext+0x1840>
ffffffffc020420a:	00008617          	auipc	a2,0x8
ffffffffc020420e:	a8e60613          	addi	a2,a2,-1394 # ffffffffc020bc98 <etext+0x438>
ffffffffc0204212:	14e00593          	li	a1,334
ffffffffc0204216:	00009517          	auipc	a0,0x9
ffffffffc020421a:	d0250513          	addi	a0,a0,-766 # ffffffffc020cf18 <etext+0x16b8>
ffffffffc020421e:	a2cfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0204222:	00009697          	auipc	a3,0x9
ffffffffc0204226:	e6e68693          	addi	a3,a3,-402 # ffffffffc020d090 <etext+0x1830>
ffffffffc020422a:	00008617          	auipc	a2,0x8
ffffffffc020422e:	a6e60613          	addi	a2,a2,-1426 # ffffffffc020bc98 <etext+0x438>
ffffffffc0204232:	14c00593          	li	a1,332
ffffffffc0204236:	00009517          	auipc	a0,0x9
ffffffffc020423a:	ce250513          	addi	a0,a0,-798 # ffffffffc020cf18 <etext+0x16b8>
ffffffffc020423e:	a0cfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0204242:	00009697          	auipc	a3,0x9
ffffffffc0204246:	e3e68693          	addi	a3,a3,-450 # ffffffffc020d080 <etext+0x1820>
ffffffffc020424a:	00008617          	auipc	a2,0x8
ffffffffc020424e:	a4e60613          	addi	a2,a2,-1458 # ffffffffc020bc98 <etext+0x438>
ffffffffc0204252:	14a00593          	li	a1,330
ffffffffc0204256:	00009517          	auipc	a0,0x9
ffffffffc020425a:	cc250513          	addi	a0,a0,-830 # ffffffffc020cf18 <etext+0x16b8>
ffffffffc020425e:	9ecfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0204262:	00009697          	auipc	a3,0x9
ffffffffc0204266:	e0e68693          	addi	a3,a3,-498 # ffffffffc020d070 <etext+0x1810>
ffffffffc020426a:	00008617          	auipc	a2,0x8
ffffffffc020426e:	a2e60613          	addi	a2,a2,-1490 # ffffffffc020bc98 <etext+0x438>
ffffffffc0204272:	14800593          	li	a1,328
ffffffffc0204276:	00009517          	auipc	a0,0x9
ffffffffc020427a:	ca250513          	addi	a0,a0,-862 # ffffffffc020cf18 <etext+0x16b8>
ffffffffc020427e:	9ccfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0204282:	00009697          	auipc	a3,0x9
ffffffffc0204286:	d7e68693          	addi	a3,a3,-642 # ffffffffc020d000 <etext+0x17a0>
ffffffffc020428a:	00008617          	auipc	a2,0x8
ffffffffc020428e:	a0e60613          	addi	a2,a2,-1522 # ffffffffc020bc98 <etext+0x438>
ffffffffc0204292:	13b00593          	li	a1,315
ffffffffc0204296:	00009517          	auipc	a0,0x9
ffffffffc020429a:	c8250513          	addi	a0,a0,-894 # ffffffffc020cf18 <etext+0x16b8>
ffffffffc020429e:	9acfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02042a2:	00009697          	auipc	a3,0x9
ffffffffc02042a6:	dbe68693          	addi	a3,a3,-578 # ffffffffc020d060 <etext+0x1800>
ffffffffc02042aa:	00008617          	auipc	a2,0x8
ffffffffc02042ae:	9ee60613          	addi	a2,a2,-1554 # ffffffffc020bc98 <etext+0x438>
ffffffffc02042b2:	14600593          	li	a1,326
ffffffffc02042b6:	00009517          	auipc	a0,0x9
ffffffffc02042ba:	c6250513          	addi	a0,a0,-926 # ffffffffc020cf18 <etext+0x16b8>
ffffffffc02042be:	98cfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02042c2:	00009697          	auipc	a3,0x9
ffffffffc02042c6:	d8e68693          	addi	a3,a3,-626 # ffffffffc020d050 <etext+0x17f0>
ffffffffc02042ca:	00008617          	auipc	a2,0x8
ffffffffc02042ce:	9ce60613          	addi	a2,a2,-1586 # ffffffffc020bc98 <etext+0x438>
ffffffffc02042d2:	14400593          	li	a1,324
ffffffffc02042d6:	00009517          	auipc	a0,0x9
ffffffffc02042da:	c4250513          	addi	a0,a0,-958 # ffffffffc020cf18 <etext+0x16b8>
ffffffffc02042de:	96cfc0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02042e2:	6914                	ld	a3,16(a0)
ffffffffc02042e4:	6510                	ld	a2,8(a0)
ffffffffc02042e6:	0004859b          	sext.w	a1,s1
ffffffffc02042ea:	00009517          	auipc	a0,0x9
ffffffffc02042ee:	e1650513          	addi	a0,a0,-490 # ffffffffc020d100 <etext+0x18a0>
ffffffffc02042f2:	eb5fb0ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc02042f6:	00009697          	auipc	a3,0x9
ffffffffc02042fa:	e3268693          	addi	a3,a3,-462 # ffffffffc020d128 <etext+0x18c8>
ffffffffc02042fe:	00008617          	auipc	a2,0x8
ffffffffc0204302:	99a60613          	addi	a2,a2,-1638 # ffffffffc020bc98 <etext+0x438>
ffffffffc0204306:	15900593          	li	a1,345
ffffffffc020430a:	00009517          	auipc	a0,0x9
ffffffffc020430e:	c0e50513          	addi	a0,a0,-1010 # ffffffffc020cf18 <etext+0x16b8>
ffffffffc0204312:	938fc0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0204316 <user_mem_check>:
ffffffffc0204316:	7179                	addi	sp,sp,-48
ffffffffc0204318:	f022                	sd	s0,32(sp)
ffffffffc020431a:	f406                	sd	ra,40(sp)
ffffffffc020431c:	842e                	mv	s0,a1
ffffffffc020431e:	c52d                	beqz	a0,ffffffffc0204388 <user_mem_check+0x72>
ffffffffc0204320:	002007b7          	lui	a5,0x200
ffffffffc0204324:	04f5ed63          	bltu	a1,a5,ffffffffc020437e <user_mem_check+0x68>
ffffffffc0204328:	ec26                	sd	s1,24(sp)
ffffffffc020432a:	00c584b3          	add	s1,a1,a2
ffffffffc020432e:	0695ff63          	bgeu	a1,s1,ffffffffc02043ac <user_mem_check+0x96>
ffffffffc0204332:	4785                	li	a5,1
ffffffffc0204334:	07fe                	slli	a5,a5,0x1f
ffffffffc0204336:	0785                	addi	a5,a5,1 # 200001 <_binary_bin_sfs_img_size+0x18ad01>
ffffffffc0204338:	06f4fa63          	bgeu	s1,a5,ffffffffc02043ac <user_mem_check+0x96>
ffffffffc020433c:	e84a                	sd	s2,16(sp)
ffffffffc020433e:	e44e                	sd	s3,8(sp)
ffffffffc0204340:	8936                	mv	s2,a3
ffffffffc0204342:	89aa                	mv	s3,a0
ffffffffc0204344:	a829                	j	ffffffffc020435e <user_mem_check+0x48>
ffffffffc0204346:	6685                	lui	a3,0x1
ffffffffc0204348:	9736                	add	a4,a4,a3
ffffffffc020434a:	0027f693          	andi	a3,a5,2
ffffffffc020434e:	8ba1                	andi	a5,a5,8
ffffffffc0204350:	c685                	beqz	a3,ffffffffc0204378 <user_mem_check+0x62>
ffffffffc0204352:	c399                	beqz	a5,ffffffffc0204358 <user_mem_check+0x42>
ffffffffc0204354:	02e46263          	bltu	s0,a4,ffffffffc0204378 <user_mem_check+0x62>
ffffffffc0204358:	6900                	ld	s0,16(a0)
ffffffffc020435a:	04947b63          	bgeu	s0,s1,ffffffffc02043b0 <user_mem_check+0x9a>
ffffffffc020435e:	85a2                	mv	a1,s0
ffffffffc0204360:	854e                	mv	a0,s3
ffffffffc0204362:	953ff0ef          	jal	ffffffffc0203cb4 <find_vma>
ffffffffc0204366:	c909                	beqz	a0,ffffffffc0204378 <user_mem_check+0x62>
ffffffffc0204368:	6518                	ld	a4,8(a0)
ffffffffc020436a:	00e46763          	bltu	s0,a4,ffffffffc0204378 <user_mem_check+0x62>
ffffffffc020436e:	4d1c                	lw	a5,24(a0)
ffffffffc0204370:	fc091be3          	bnez	s2,ffffffffc0204346 <user_mem_check+0x30>
ffffffffc0204374:	8b85                	andi	a5,a5,1
ffffffffc0204376:	f3ed                	bnez	a5,ffffffffc0204358 <user_mem_check+0x42>
ffffffffc0204378:	64e2                	ld	s1,24(sp)
ffffffffc020437a:	6942                	ld	s2,16(sp)
ffffffffc020437c:	69a2                	ld	s3,8(sp)
ffffffffc020437e:	4501                	li	a0,0
ffffffffc0204380:	70a2                	ld	ra,40(sp)
ffffffffc0204382:	7402                	ld	s0,32(sp)
ffffffffc0204384:	6145                	addi	sp,sp,48
ffffffffc0204386:	8082                	ret
ffffffffc0204388:	c02007b7          	lui	a5,0xc0200
ffffffffc020438c:	fef5eae3          	bltu	a1,a5,ffffffffc0204380 <user_mem_check+0x6a>
ffffffffc0204390:	c80007b7          	lui	a5,0xc8000
ffffffffc0204394:	962e                	add	a2,a2,a1
ffffffffc0204396:	0785                	addi	a5,a5,1 # ffffffffc8000001 <end+0x7d696f1>
ffffffffc0204398:	00c5b433          	sltu	s0,a1,a2
ffffffffc020439c:	00f63633          	sltu	a2,a2,a5
ffffffffc02043a0:	70a2                	ld	ra,40(sp)
ffffffffc02043a2:	00867533          	and	a0,a2,s0
ffffffffc02043a6:	7402                	ld	s0,32(sp)
ffffffffc02043a8:	6145                	addi	sp,sp,48
ffffffffc02043aa:	8082                	ret
ffffffffc02043ac:	64e2                	ld	s1,24(sp)
ffffffffc02043ae:	bfc1                	j	ffffffffc020437e <user_mem_check+0x68>
ffffffffc02043b0:	64e2                	ld	s1,24(sp)
ffffffffc02043b2:	6942                	ld	s2,16(sp)
ffffffffc02043b4:	69a2                	ld	s3,8(sp)
ffffffffc02043b6:	4505                	li	a0,1
ffffffffc02043b8:	b7e1                	j	ffffffffc0204380 <user_mem_check+0x6a>

ffffffffc02043ba <copy_from_user>:
ffffffffc02043ba:	7179                	addi	sp,sp,-48
ffffffffc02043bc:	f022                	sd	s0,32(sp)
ffffffffc02043be:	8432                	mv	s0,a2
ffffffffc02043c0:	ec26                	sd	s1,24(sp)
ffffffffc02043c2:	8636                	mv	a2,a3
ffffffffc02043c4:	84ae                	mv	s1,a1
ffffffffc02043c6:	86ba                	mv	a3,a4
ffffffffc02043c8:	85a2                	mv	a1,s0
ffffffffc02043ca:	f406                	sd	ra,40(sp)
ffffffffc02043cc:	e032                	sd	a2,0(sp)
ffffffffc02043ce:	f49ff0ef          	jal	ffffffffc0204316 <user_mem_check>
ffffffffc02043d2:	87aa                	mv	a5,a0
ffffffffc02043d4:	c901                	beqz	a0,ffffffffc02043e4 <copy_from_user+0x2a>
ffffffffc02043d6:	6602                	ld	a2,0(sp)
ffffffffc02043d8:	e42a                	sd	a0,8(sp)
ffffffffc02043da:	85a2                	mv	a1,s0
ffffffffc02043dc:	8526                	mv	a0,s1
ffffffffc02043de:	46a070ef          	jal	ffffffffc020b848 <memcpy>
ffffffffc02043e2:	67a2                	ld	a5,8(sp)
ffffffffc02043e4:	70a2                	ld	ra,40(sp)
ffffffffc02043e6:	7402                	ld	s0,32(sp)
ffffffffc02043e8:	64e2                	ld	s1,24(sp)
ffffffffc02043ea:	853e                	mv	a0,a5
ffffffffc02043ec:	6145                	addi	sp,sp,48
ffffffffc02043ee:	8082                	ret

ffffffffc02043f0 <copy_to_user>:
ffffffffc02043f0:	7179                	addi	sp,sp,-48
ffffffffc02043f2:	f022                	sd	s0,32(sp)
ffffffffc02043f4:	8436                	mv	s0,a3
ffffffffc02043f6:	e84a                	sd	s2,16(sp)
ffffffffc02043f8:	4685                	li	a3,1
ffffffffc02043fa:	8932                	mv	s2,a2
ffffffffc02043fc:	8622                	mv	a2,s0
ffffffffc02043fe:	ec26                	sd	s1,24(sp)
ffffffffc0204400:	f406                	sd	ra,40(sp)
ffffffffc0204402:	84ae                	mv	s1,a1
ffffffffc0204404:	f13ff0ef          	jal	ffffffffc0204316 <user_mem_check>
ffffffffc0204408:	87aa                	mv	a5,a0
ffffffffc020440a:	c901                	beqz	a0,ffffffffc020441a <copy_to_user+0x2a>
ffffffffc020440c:	e42a                	sd	a0,8(sp)
ffffffffc020440e:	8622                	mv	a2,s0
ffffffffc0204410:	85ca                	mv	a1,s2
ffffffffc0204412:	8526                	mv	a0,s1
ffffffffc0204414:	434070ef          	jal	ffffffffc020b848 <memcpy>
ffffffffc0204418:	67a2                	ld	a5,8(sp)
ffffffffc020441a:	70a2                	ld	ra,40(sp)
ffffffffc020441c:	7402                	ld	s0,32(sp)
ffffffffc020441e:	64e2                	ld	s1,24(sp)
ffffffffc0204420:	6942                	ld	s2,16(sp)
ffffffffc0204422:	853e                	mv	a0,a5
ffffffffc0204424:	6145                	addi	sp,sp,48
ffffffffc0204426:	8082                	ret

ffffffffc0204428 <copy_string>:
ffffffffc0204428:	7139                	addi	sp,sp,-64
ffffffffc020442a:	e852                	sd	s4,16(sp)
ffffffffc020442c:	6a05                	lui	s4,0x1
ffffffffc020442e:	9a32                	add	s4,s4,a2
ffffffffc0204430:	77fd                	lui	a5,0xfffff
ffffffffc0204432:	00fa7a33          	and	s4,s4,a5
ffffffffc0204436:	f426                	sd	s1,40(sp)
ffffffffc0204438:	f04a                	sd	s2,32(sp)
ffffffffc020443a:	e456                	sd	s5,8(sp)
ffffffffc020443c:	e05a                	sd	s6,0(sp)
ffffffffc020443e:	fc06                	sd	ra,56(sp)
ffffffffc0204440:	f822                	sd	s0,48(sp)
ffffffffc0204442:	ec4e                	sd	s3,24(sp)
ffffffffc0204444:	84b2                	mv	s1,a2
ffffffffc0204446:	8aae                	mv	s5,a1
ffffffffc0204448:	8936                	mv	s2,a3
ffffffffc020444a:	8b2a                	mv	s6,a0
ffffffffc020444c:	40ca0a33          	sub	s4,s4,a2
ffffffffc0204450:	a015                	j	ffffffffc0204474 <copy_string+0x4c>
ffffffffc0204452:	30a070ef          	jal	ffffffffc020b75c <strnlen>
ffffffffc0204456:	87aa                	mv	a5,a0
ffffffffc0204458:	8622                	mv	a2,s0
ffffffffc020445a:	85a6                	mv	a1,s1
ffffffffc020445c:	8556                	mv	a0,s5
ffffffffc020445e:	0487e663          	bltu	a5,s0,ffffffffc02044aa <copy_string+0x82>
ffffffffc0204462:	032a7863          	bgeu	s4,s2,ffffffffc0204492 <copy_string+0x6a>
ffffffffc0204466:	3e2070ef          	jal	ffffffffc020b848 <memcpy>
ffffffffc020446a:	9aa2                	add	s5,s5,s0
ffffffffc020446c:	94a2                	add	s1,s1,s0
ffffffffc020446e:	40890933          	sub	s2,s2,s0
ffffffffc0204472:	6a05                	lui	s4,0x1
ffffffffc0204474:	4681                	li	a3,0
ffffffffc0204476:	85a6                	mv	a1,s1
ffffffffc0204478:	855a                	mv	a0,s6
ffffffffc020447a:	844a                	mv	s0,s2
ffffffffc020447c:	012a7363          	bgeu	s4,s2,ffffffffc0204482 <copy_string+0x5a>
ffffffffc0204480:	8452                	mv	s0,s4
ffffffffc0204482:	8622                	mv	a2,s0
ffffffffc0204484:	e93ff0ef          	jal	ffffffffc0204316 <user_mem_check>
ffffffffc0204488:	89aa                	mv	s3,a0
ffffffffc020448a:	85a2                	mv	a1,s0
ffffffffc020448c:	8526                	mv	a0,s1
ffffffffc020448e:	fc0992e3          	bnez	s3,ffffffffc0204452 <copy_string+0x2a>
ffffffffc0204492:	4981                	li	s3,0
ffffffffc0204494:	70e2                	ld	ra,56(sp)
ffffffffc0204496:	7442                	ld	s0,48(sp)
ffffffffc0204498:	74a2                	ld	s1,40(sp)
ffffffffc020449a:	7902                	ld	s2,32(sp)
ffffffffc020449c:	6a42                	ld	s4,16(sp)
ffffffffc020449e:	6aa2                	ld	s5,8(sp)
ffffffffc02044a0:	6b02                	ld	s6,0(sp)
ffffffffc02044a2:	854e                	mv	a0,s3
ffffffffc02044a4:	69e2                	ld	s3,24(sp)
ffffffffc02044a6:	6121                	addi	sp,sp,64
ffffffffc02044a8:	8082                	ret
ffffffffc02044aa:	00178613          	addi	a2,a5,1 # fffffffffffff001 <end+0x3fd686f1>
ffffffffc02044ae:	39a070ef          	jal	ffffffffc020b848 <memcpy>
ffffffffc02044b2:	b7cd                	j	ffffffffc0204494 <copy_string+0x6c>

ffffffffc02044b4 <__down.constprop.0>:
ffffffffc02044b4:	711d                	addi	sp,sp,-96
ffffffffc02044b6:	ec86                	sd	ra,88(sp)
ffffffffc02044b8:	100027f3          	csrr	a5,sstatus
ffffffffc02044bc:	8b89                	andi	a5,a5,2
ffffffffc02044be:	eba1                	bnez	a5,ffffffffc020450e <__down.constprop.0+0x5a>
ffffffffc02044c0:	411c                	lw	a5,0(a0)
ffffffffc02044c2:	00f05863          	blez	a5,ffffffffc02044d2 <__down.constprop.0+0x1e>
ffffffffc02044c6:	37fd                	addiw	a5,a5,-1
ffffffffc02044c8:	c11c                	sw	a5,0(a0)
ffffffffc02044ca:	60e6                	ld	ra,88(sp)
ffffffffc02044cc:	4501                	li	a0,0
ffffffffc02044ce:	6125                	addi	sp,sp,96
ffffffffc02044d0:	8082                	ret
ffffffffc02044d2:	0521                	addi	a0,a0,8
ffffffffc02044d4:	082c                	addi	a1,sp,24
ffffffffc02044d6:	10000613          	li	a2,256
ffffffffc02044da:	e8a2                	sd	s0,80(sp)
ffffffffc02044dc:	e4a6                	sd	s1,72(sp)
ffffffffc02044de:	0820                	addi	s0,sp,24
ffffffffc02044e0:	84aa                	mv	s1,a0
ffffffffc02044e2:	2d0000ef          	jal	ffffffffc02047b2 <wait_current_set>
ffffffffc02044e6:	058030ef          	jal	ffffffffc020753e <schedule>
ffffffffc02044ea:	100027f3          	csrr	a5,sstatus
ffffffffc02044ee:	8b89                	andi	a5,a5,2
ffffffffc02044f0:	efa9                	bnez	a5,ffffffffc020454a <__down.constprop.0+0x96>
ffffffffc02044f2:	8522                	mv	a0,s0
ffffffffc02044f4:	192000ef          	jal	ffffffffc0204686 <wait_in_queue>
ffffffffc02044f8:	e521                	bnez	a0,ffffffffc0204540 <__down.constprop.0+0x8c>
ffffffffc02044fa:	5502                	lw	a0,32(sp)
ffffffffc02044fc:	10000793          	li	a5,256
ffffffffc0204500:	6446                	ld	s0,80(sp)
ffffffffc0204502:	64a6                	ld	s1,72(sp)
ffffffffc0204504:	fcf503e3          	beq	a0,a5,ffffffffc02044ca <__down.constprop.0+0x16>
ffffffffc0204508:	60e6                	ld	ra,88(sp)
ffffffffc020450a:	6125                	addi	sp,sp,96
ffffffffc020450c:	8082                	ret
ffffffffc020450e:	e42a                	sd	a0,8(sp)
ffffffffc0204510:	ec8fc0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0204514:	6522                	ld	a0,8(sp)
ffffffffc0204516:	411c                	lw	a5,0(a0)
ffffffffc0204518:	00f05763          	blez	a5,ffffffffc0204526 <__down.constprop.0+0x72>
ffffffffc020451c:	37fd                	addiw	a5,a5,-1
ffffffffc020451e:	c11c                	sw	a5,0(a0)
ffffffffc0204520:	eb2fc0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0204524:	b75d                	j	ffffffffc02044ca <__down.constprop.0+0x16>
ffffffffc0204526:	0521                	addi	a0,a0,8
ffffffffc0204528:	082c                	addi	a1,sp,24
ffffffffc020452a:	10000613          	li	a2,256
ffffffffc020452e:	e8a2                	sd	s0,80(sp)
ffffffffc0204530:	e4a6                	sd	s1,72(sp)
ffffffffc0204532:	0820                	addi	s0,sp,24
ffffffffc0204534:	84aa                	mv	s1,a0
ffffffffc0204536:	27c000ef          	jal	ffffffffc02047b2 <wait_current_set>
ffffffffc020453a:	e98fc0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc020453e:	b765                	j	ffffffffc02044e6 <__down.constprop.0+0x32>
ffffffffc0204540:	85a2                	mv	a1,s0
ffffffffc0204542:	8526                	mv	a0,s1
ffffffffc0204544:	0e8000ef          	jal	ffffffffc020462c <wait_queue_del>
ffffffffc0204548:	bf4d                	j	ffffffffc02044fa <__down.constprop.0+0x46>
ffffffffc020454a:	e8efc0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc020454e:	8522                	mv	a0,s0
ffffffffc0204550:	136000ef          	jal	ffffffffc0204686 <wait_in_queue>
ffffffffc0204554:	e501                	bnez	a0,ffffffffc020455c <__down.constprop.0+0xa8>
ffffffffc0204556:	e7cfc0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc020455a:	b745                	j	ffffffffc02044fa <__down.constprop.0+0x46>
ffffffffc020455c:	85a2                	mv	a1,s0
ffffffffc020455e:	8526                	mv	a0,s1
ffffffffc0204560:	0cc000ef          	jal	ffffffffc020462c <wait_queue_del>
ffffffffc0204564:	bfcd                	j	ffffffffc0204556 <__down.constprop.0+0xa2>

ffffffffc0204566 <__up.constprop.0>:
ffffffffc0204566:	1101                	addi	sp,sp,-32
ffffffffc0204568:	e426                	sd	s1,8(sp)
ffffffffc020456a:	ec06                	sd	ra,24(sp)
ffffffffc020456c:	e822                	sd	s0,16(sp)
ffffffffc020456e:	e04a                	sd	s2,0(sp)
ffffffffc0204570:	84aa                	mv	s1,a0
ffffffffc0204572:	100027f3          	csrr	a5,sstatus
ffffffffc0204576:	8b89                	andi	a5,a5,2
ffffffffc0204578:	4901                	li	s2,0
ffffffffc020457a:	e7b1                	bnez	a5,ffffffffc02045c6 <__up.constprop.0+0x60>
ffffffffc020457c:	00848413          	addi	s0,s1,8
ffffffffc0204580:	8522                	mv	a0,s0
ffffffffc0204582:	0e8000ef          	jal	ffffffffc020466a <wait_queue_first>
ffffffffc0204586:	cd05                	beqz	a0,ffffffffc02045be <__up.constprop.0+0x58>
ffffffffc0204588:	6118                	ld	a4,0(a0)
ffffffffc020458a:	10000793          	li	a5,256
ffffffffc020458e:	0ec72603          	lw	a2,236(a4)
ffffffffc0204592:	02f61e63          	bne	a2,a5,ffffffffc02045ce <__up.constprop.0+0x68>
ffffffffc0204596:	85aa                	mv	a1,a0
ffffffffc0204598:	4685                	li	a3,1
ffffffffc020459a:	8522                	mv	a0,s0
ffffffffc020459c:	0f8000ef          	jal	ffffffffc0204694 <wakeup_wait>
ffffffffc02045a0:	00091863          	bnez	s2,ffffffffc02045b0 <__up.constprop.0+0x4a>
ffffffffc02045a4:	60e2                	ld	ra,24(sp)
ffffffffc02045a6:	6442                	ld	s0,16(sp)
ffffffffc02045a8:	64a2                	ld	s1,8(sp)
ffffffffc02045aa:	6902                	ld	s2,0(sp)
ffffffffc02045ac:	6105                	addi	sp,sp,32
ffffffffc02045ae:	8082                	ret
ffffffffc02045b0:	6442                	ld	s0,16(sp)
ffffffffc02045b2:	60e2                	ld	ra,24(sp)
ffffffffc02045b4:	64a2                	ld	s1,8(sp)
ffffffffc02045b6:	6902                	ld	s2,0(sp)
ffffffffc02045b8:	6105                	addi	sp,sp,32
ffffffffc02045ba:	e18fc06f          	j	ffffffffc0200bd2 <intr_enable>
ffffffffc02045be:	409c                	lw	a5,0(s1)
ffffffffc02045c0:	2785                	addiw	a5,a5,1
ffffffffc02045c2:	c09c                	sw	a5,0(s1)
ffffffffc02045c4:	bff1                	j	ffffffffc02045a0 <__up.constprop.0+0x3a>
ffffffffc02045c6:	e12fc0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc02045ca:	4905                	li	s2,1
ffffffffc02045cc:	bf45                	j	ffffffffc020457c <__up.constprop.0+0x16>
ffffffffc02045ce:	00009697          	auipc	a3,0x9
ffffffffc02045d2:	baa68693          	addi	a3,a3,-1110 # ffffffffc020d178 <etext+0x1918>
ffffffffc02045d6:	00007617          	auipc	a2,0x7
ffffffffc02045da:	6c260613          	addi	a2,a2,1730 # ffffffffc020bc98 <etext+0x438>
ffffffffc02045de:	45e5                	li	a1,25
ffffffffc02045e0:	00009517          	auipc	a0,0x9
ffffffffc02045e4:	bc050513          	addi	a0,a0,-1088 # ffffffffc020d1a0 <etext+0x1940>
ffffffffc02045e8:	e63fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02045ec <sem_init>:
ffffffffc02045ec:	c10c                	sw	a1,0(a0)
ffffffffc02045ee:	0521                	addi	a0,a0,8
ffffffffc02045f0:	a81d                	j	ffffffffc0204626 <wait_queue_init>

ffffffffc02045f2 <up>:
ffffffffc02045f2:	f75ff06f          	j	ffffffffc0204566 <__up.constprop.0>

ffffffffc02045f6 <down>:
ffffffffc02045f6:	1141                	addi	sp,sp,-16
ffffffffc02045f8:	e406                	sd	ra,8(sp)
ffffffffc02045fa:	ebbff0ef          	jal	ffffffffc02044b4 <__down.constprop.0>
ffffffffc02045fe:	e501                	bnez	a0,ffffffffc0204606 <down+0x10>
ffffffffc0204600:	60a2                	ld	ra,8(sp)
ffffffffc0204602:	0141                	addi	sp,sp,16
ffffffffc0204604:	8082                	ret
ffffffffc0204606:	00009697          	auipc	a3,0x9
ffffffffc020460a:	baa68693          	addi	a3,a3,-1110 # ffffffffc020d1b0 <etext+0x1950>
ffffffffc020460e:	00007617          	auipc	a2,0x7
ffffffffc0204612:	68a60613          	addi	a2,a2,1674 # ffffffffc020bc98 <etext+0x438>
ffffffffc0204616:	04000593          	li	a1,64
ffffffffc020461a:	00009517          	auipc	a0,0x9
ffffffffc020461e:	b8650513          	addi	a0,a0,-1146 # ffffffffc020d1a0 <etext+0x1940>
ffffffffc0204622:	e29fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0204626 <wait_queue_init>:
ffffffffc0204626:	e508                	sd	a0,8(a0)
ffffffffc0204628:	e108                	sd	a0,0(a0)
ffffffffc020462a:	8082                	ret

ffffffffc020462c <wait_queue_del>:
ffffffffc020462c:	7198                	ld	a4,32(a1)
ffffffffc020462e:	01858793          	addi	a5,a1,24
ffffffffc0204632:	00e78b63          	beq	a5,a4,ffffffffc0204648 <wait_queue_del+0x1c>
ffffffffc0204636:	6994                	ld	a3,16(a1)
ffffffffc0204638:	00a69863          	bne	a3,a0,ffffffffc0204648 <wait_queue_del+0x1c>
ffffffffc020463c:	6d94                	ld	a3,24(a1)
ffffffffc020463e:	e698                	sd	a4,8(a3)
ffffffffc0204640:	e314                	sd	a3,0(a4)
ffffffffc0204642:	f19c                	sd	a5,32(a1)
ffffffffc0204644:	ed9c                	sd	a5,24(a1)
ffffffffc0204646:	8082                	ret
ffffffffc0204648:	1141                	addi	sp,sp,-16
ffffffffc020464a:	00009697          	auipc	a3,0x9
ffffffffc020464e:	bc668693          	addi	a3,a3,-1082 # ffffffffc020d210 <etext+0x19b0>
ffffffffc0204652:	00007617          	auipc	a2,0x7
ffffffffc0204656:	64660613          	addi	a2,a2,1606 # ffffffffc020bc98 <etext+0x438>
ffffffffc020465a:	45f1                	li	a1,28
ffffffffc020465c:	00009517          	auipc	a0,0x9
ffffffffc0204660:	b9c50513          	addi	a0,a0,-1124 # ffffffffc020d1f8 <etext+0x1998>
ffffffffc0204664:	e406                	sd	ra,8(sp)
ffffffffc0204666:	de5fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020466a <wait_queue_first>:
ffffffffc020466a:	651c                	ld	a5,8(a0)
ffffffffc020466c:	00f50563          	beq	a0,a5,ffffffffc0204676 <wait_queue_first+0xc>
ffffffffc0204670:	fe878513          	addi	a0,a5,-24
ffffffffc0204674:	8082                	ret
ffffffffc0204676:	4501                	li	a0,0
ffffffffc0204678:	8082                	ret

ffffffffc020467a <wait_queue_empty>:
ffffffffc020467a:	651c                	ld	a5,8(a0)
ffffffffc020467c:	40a78533          	sub	a0,a5,a0
ffffffffc0204680:	00153513          	seqz	a0,a0
ffffffffc0204684:	8082                	ret

ffffffffc0204686 <wait_in_queue>:
ffffffffc0204686:	711c                	ld	a5,32(a0)
ffffffffc0204688:	0561                	addi	a0,a0,24
ffffffffc020468a:	40a78533          	sub	a0,a5,a0
ffffffffc020468e:	00a03533          	snez	a0,a0
ffffffffc0204692:	8082                	ret

ffffffffc0204694 <wakeup_wait>:
ffffffffc0204694:	e689                	bnez	a3,ffffffffc020469e <wakeup_wait+0xa>
ffffffffc0204696:	6188                	ld	a0,0(a1)
ffffffffc0204698:	c590                	sw	a2,8(a1)
ffffffffc020469a:	5ad0206f          	j	ffffffffc0207446 <wakeup_proc>
ffffffffc020469e:	7198                	ld	a4,32(a1)
ffffffffc02046a0:	01858793          	addi	a5,a1,24
ffffffffc02046a4:	00e78e63          	beq	a5,a4,ffffffffc02046c0 <wakeup_wait+0x2c>
ffffffffc02046a8:	6994                	ld	a3,16(a1)
ffffffffc02046aa:	00d51b63          	bne	a0,a3,ffffffffc02046c0 <wakeup_wait+0x2c>
ffffffffc02046ae:	6d94                	ld	a3,24(a1)
ffffffffc02046b0:	6188                	ld	a0,0(a1)
ffffffffc02046b2:	e698                	sd	a4,8(a3)
ffffffffc02046b4:	e314                	sd	a3,0(a4)
ffffffffc02046b6:	f19c                	sd	a5,32(a1)
ffffffffc02046b8:	ed9c                	sd	a5,24(a1)
ffffffffc02046ba:	c590                	sw	a2,8(a1)
ffffffffc02046bc:	58b0206f          	j	ffffffffc0207446 <wakeup_proc>
ffffffffc02046c0:	1141                	addi	sp,sp,-16
ffffffffc02046c2:	00009697          	auipc	a3,0x9
ffffffffc02046c6:	b4e68693          	addi	a3,a3,-1202 # ffffffffc020d210 <etext+0x19b0>
ffffffffc02046ca:	00007617          	auipc	a2,0x7
ffffffffc02046ce:	5ce60613          	addi	a2,a2,1486 # ffffffffc020bc98 <etext+0x438>
ffffffffc02046d2:	45f1                	li	a1,28
ffffffffc02046d4:	00009517          	auipc	a0,0x9
ffffffffc02046d8:	b2450513          	addi	a0,a0,-1244 # ffffffffc020d1f8 <etext+0x1998>
ffffffffc02046dc:	e406                	sd	ra,8(sp)
ffffffffc02046de:	d6dfb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02046e2 <wakeup_queue>:
ffffffffc02046e2:	651c                	ld	a5,8(a0)
ffffffffc02046e4:	0aa78763          	beq	a5,a0,ffffffffc0204792 <wakeup_queue+0xb0>
ffffffffc02046e8:	1101                	addi	sp,sp,-32
ffffffffc02046ea:	e822                	sd	s0,16(sp)
ffffffffc02046ec:	e426                	sd	s1,8(sp)
ffffffffc02046ee:	e04a                	sd	s2,0(sp)
ffffffffc02046f0:	ec06                	sd	ra,24(sp)
ffffffffc02046f2:	892e                	mv	s2,a1
ffffffffc02046f4:	84aa                	mv	s1,a0
ffffffffc02046f6:	fe878413          	addi	s0,a5,-24
ffffffffc02046fa:	ee29                	bnez	a2,ffffffffc0204754 <wakeup_queue+0x72>
ffffffffc02046fc:	6008                	ld	a0,0(s0)
ffffffffc02046fe:	01242423          	sw	s2,8(s0)
ffffffffc0204702:	545020ef          	jal	ffffffffc0207446 <wakeup_proc>
ffffffffc0204706:	701c                	ld	a5,32(s0)
ffffffffc0204708:	01840713          	addi	a4,s0,24
ffffffffc020470c:	02e78463          	beq	a5,a4,ffffffffc0204734 <wakeup_queue+0x52>
ffffffffc0204710:	6818                	ld	a4,16(s0)
ffffffffc0204712:	02e49163          	bne	s1,a4,ffffffffc0204734 <wakeup_queue+0x52>
ffffffffc0204716:	06f48863          	beq	s1,a5,ffffffffc0204786 <wakeup_queue+0xa4>
ffffffffc020471a:	fe87b503          	ld	a0,-24(a5)
ffffffffc020471e:	ff27a823          	sw	s2,-16(a5)
ffffffffc0204722:	fe878413          	addi	s0,a5,-24
ffffffffc0204726:	521020ef          	jal	ffffffffc0207446 <wakeup_proc>
ffffffffc020472a:	701c                	ld	a5,32(s0)
ffffffffc020472c:	01840713          	addi	a4,s0,24
ffffffffc0204730:	fee790e3          	bne	a5,a4,ffffffffc0204710 <wakeup_queue+0x2e>
ffffffffc0204734:	00009697          	auipc	a3,0x9
ffffffffc0204738:	adc68693          	addi	a3,a3,-1316 # ffffffffc020d210 <etext+0x19b0>
ffffffffc020473c:	00007617          	auipc	a2,0x7
ffffffffc0204740:	55c60613          	addi	a2,a2,1372 # ffffffffc020bc98 <etext+0x438>
ffffffffc0204744:	02200593          	li	a1,34
ffffffffc0204748:	00009517          	auipc	a0,0x9
ffffffffc020474c:	ab050513          	addi	a0,a0,-1360 # ffffffffc020d1f8 <etext+0x1998>
ffffffffc0204750:	cfbfb0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0204754:	6798                	ld	a4,8(a5)
ffffffffc0204756:	00e79863          	bne	a5,a4,ffffffffc0204766 <wakeup_queue+0x84>
ffffffffc020475a:	a82d                	j	ffffffffc0204794 <wakeup_queue+0xb2>
ffffffffc020475c:	6418                	ld	a4,8(s0)
ffffffffc020475e:	87a2                	mv	a5,s0
ffffffffc0204760:	1421                	addi	s0,s0,-24
ffffffffc0204762:	02e78963          	beq	a5,a4,ffffffffc0204794 <wakeup_queue+0xb2>
ffffffffc0204766:	6814                	ld	a3,16(s0)
ffffffffc0204768:	02d49663          	bne	s1,a3,ffffffffc0204794 <wakeup_queue+0xb2>
ffffffffc020476c:	6c14                	ld	a3,24(s0)
ffffffffc020476e:	6008                	ld	a0,0(s0)
ffffffffc0204770:	e698                	sd	a4,8(a3)
ffffffffc0204772:	e314                	sd	a3,0(a4)
ffffffffc0204774:	f01c                	sd	a5,32(s0)
ffffffffc0204776:	ec1c                	sd	a5,24(s0)
ffffffffc0204778:	01242423          	sw	s2,8(s0)
ffffffffc020477c:	4cb020ef          	jal	ffffffffc0207446 <wakeup_proc>
ffffffffc0204780:	6480                	ld	s0,8(s1)
ffffffffc0204782:	fc849de3          	bne	s1,s0,ffffffffc020475c <wakeup_queue+0x7a>
ffffffffc0204786:	60e2                	ld	ra,24(sp)
ffffffffc0204788:	6442                	ld	s0,16(sp)
ffffffffc020478a:	64a2                	ld	s1,8(sp)
ffffffffc020478c:	6902                	ld	s2,0(sp)
ffffffffc020478e:	6105                	addi	sp,sp,32
ffffffffc0204790:	8082                	ret
ffffffffc0204792:	8082                	ret
ffffffffc0204794:	00009697          	auipc	a3,0x9
ffffffffc0204798:	a7c68693          	addi	a3,a3,-1412 # ffffffffc020d210 <etext+0x19b0>
ffffffffc020479c:	00007617          	auipc	a2,0x7
ffffffffc02047a0:	4fc60613          	addi	a2,a2,1276 # ffffffffc020bc98 <etext+0x438>
ffffffffc02047a4:	45f1                	li	a1,28
ffffffffc02047a6:	00009517          	auipc	a0,0x9
ffffffffc02047aa:	a5250513          	addi	a0,a0,-1454 # ffffffffc020d1f8 <etext+0x1998>
ffffffffc02047ae:	c9dfb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02047b2 <wait_current_set>:
ffffffffc02047b2:	00092797          	auipc	a5,0x92
ffffffffc02047b6:	1167b783          	ld	a5,278(a5) # ffffffffc02968c8 <current>
ffffffffc02047ba:	c39d                	beqz	a5,ffffffffc02047e0 <wait_current_set+0x2e>
ffffffffc02047bc:	80000737          	lui	a4,0x80000
ffffffffc02047c0:	c598                	sw	a4,8(a1)
ffffffffc02047c2:	01858713          	addi	a4,a1,24
ffffffffc02047c6:	ed98                	sd	a4,24(a1)
ffffffffc02047c8:	e19c                	sd	a5,0(a1)
ffffffffc02047ca:	0ec7a623          	sw	a2,236(a5)
ffffffffc02047ce:	4605                	li	a2,1
ffffffffc02047d0:	6114                	ld	a3,0(a0)
ffffffffc02047d2:	c390                	sw	a2,0(a5)
ffffffffc02047d4:	e988                	sd	a0,16(a1)
ffffffffc02047d6:	e118                	sd	a4,0(a0)
ffffffffc02047d8:	e698                	sd	a4,8(a3)
ffffffffc02047da:	ed94                	sd	a3,24(a1)
ffffffffc02047dc:	f188                	sd	a0,32(a1)
ffffffffc02047de:	8082                	ret
ffffffffc02047e0:	1141                	addi	sp,sp,-16
ffffffffc02047e2:	00009697          	auipc	a3,0x9
ffffffffc02047e6:	a6e68693          	addi	a3,a3,-1426 # ffffffffc020d250 <etext+0x19f0>
ffffffffc02047ea:	00007617          	auipc	a2,0x7
ffffffffc02047ee:	4ae60613          	addi	a2,a2,1198 # ffffffffc020bc98 <etext+0x438>
ffffffffc02047f2:	07400593          	li	a1,116
ffffffffc02047f6:	00009517          	auipc	a0,0x9
ffffffffc02047fa:	a0250513          	addi	a0,a0,-1534 # ffffffffc020d1f8 <etext+0x1998>
ffffffffc02047fe:	e406                	sd	ra,8(sp)
ffffffffc0204800:	c4bfb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0204804 <get_fd_array.part.0>:
ffffffffc0204804:	1141                	addi	sp,sp,-16
ffffffffc0204806:	00009697          	auipc	a3,0x9
ffffffffc020480a:	a5a68693          	addi	a3,a3,-1446 # ffffffffc020d260 <etext+0x1a00>
ffffffffc020480e:	00007617          	auipc	a2,0x7
ffffffffc0204812:	48a60613          	addi	a2,a2,1162 # ffffffffc020bc98 <etext+0x438>
ffffffffc0204816:	45d1                	li	a1,20
ffffffffc0204818:	00009517          	auipc	a0,0x9
ffffffffc020481c:	a7850513          	addi	a0,a0,-1416 # ffffffffc020d290 <etext+0x1a30>
ffffffffc0204820:	e406                	sd	ra,8(sp)
ffffffffc0204822:	c29fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0204826 <fd_array_alloc>:
ffffffffc0204826:	00092797          	auipc	a5,0x92
ffffffffc020482a:	0a27b783          	ld	a5,162(a5) # ffffffffc02968c8 <current>
ffffffffc020482e:	1141                	addi	sp,sp,-16
ffffffffc0204830:	e406                	sd	ra,8(sp)
ffffffffc0204832:	1487b783          	ld	a5,328(a5)
ffffffffc0204836:	cfb9                	beqz	a5,ffffffffc0204894 <fd_array_alloc+0x6e>
ffffffffc0204838:	4b98                	lw	a4,16(a5)
ffffffffc020483a:	04e05d63          	blez	a4,ffffffffc0204894 <fd_array_alloc+0x6e>
ffffffffc020483e:	775d                	lui	a4,0xffff7
ffffffffc0204840:	ad970713          	addi	a4,a4,-1319 # ffffffffffff6ad9 <end+0x3fd601c9>
ffffffffc0204844:	679c                	ld	a5,8(a5)
ffffffffc0204846:	02e50763          	beq	a0,a4,ffffffffc0204874 <fd_array_alloc+0x4e>
ffffffffc020484a:	04700713          	li	a4,71
ffffffffc020484e:	04a76163          	bltu	a4,a0,ffffffffc0204890 <fd_array_alloc+0x6a>
ffffffffc0204852:	00351713          	slli	a4,a0,0x3
ffffffffc0204856:	8f09                	sub	a4,a4,a0
ffffffffc0204858:	070e                	slli	a4,a4,0x3
ffffffffc020485a:	97ba                	add	a5,a5,a4
ffffffffc020485c:	4398                	lw	a4,0(a5)
ffffffffc020485e:	e71d                	bnez	a4,ffffffffc020488c <fd_array_alloc+0x66>
ffffffffc0204860:	5b88                	lw	a0,48(a5)
ffffffffc0204862:	e91d                	bnez	a0,ffffffffc0204898 <fd_array_alloc+0x72>
ffffffffc0204864:	4705                	li	a4,1
ffffffffc0204866:	0207b423          	sd	zero,40(a5)
ffffffffc020486a:	c398                	sw	a4,0(a5)
ffffffffc020486c:	e19c                	sd	a5,0(a1)
ffffffffc020486e:	60a2                	ld	ra,8(sp)
ffffffffc0204870:	0141                	addi	sp,sp,16
ffffffffc0204872:	8082                	ret
ffffffffc0204874:	7ff78693          	addi	a3,a5,2047
ffffffffc0204878:	7c168693          	addi	a3,a3,1985
ffffffffc020487c:	4398                	lw	a4,0(a5)
ffffffffc020487e:	d36d                	beqz	a4,ffffffffc0204860 <fd_array_alloc+0x3a>
ffffffffc0204880:	03878793          	addi	a5,a5,56
ffffffffc0204884:	fed79ce3          	bne	a5,a3,ffffffffc020487c <fd_array_alloc+0x56>
ffffffffc0204888:	5529                	li	a0,-22
ffffffffc020488a:	b7d5                	j	ffffffffc020486e <fd_array_alloc+0x48>
ffffffffc020488c:	5545                	li	a0,-15
ffffffffc020488e:	b7c5                	j	ffffffffc020486e <fd_array_alloc+0x48>
ffffffffc0204890:	5575                	li	a0,-3
ffffffffc0204892:	bff1                	j	ffffffffc020486e <fd_array_alloc+0x48>
ffffffffc0204894:	f71ff0ef          	jal	ffffffffc0204804 <get_fd_array.part.0>
ffffffffc0204898:	00009697          	auipc	a3,0x9
ffffffffc020489c:	a0868693          	addi	a3,a3,-1528 # ffffffffc020d2a0 <etext+0x1a40>
ffffffffc02048a0:	00007617          	auipc	a2,0x7
ffffffffc02048a4:	3f860613          	addi	a2,a2,1016 # ffffffffc020bc98 <etext+0x438>
ffffffffc02048a8:	03b00593          	li	a1,59
ffffffffc02048ac:	00009517          	auipc	a0,0x9
ffffffffc02048b0:	9e450513          	addi	a0,a0,-1564 # ffffffffc020d290 <etext+0x1a30>
ffffffffc02048b4:	b97fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02048b8 <fd_array_free>:
ffffffffc02048b8:	4118                	lw	a4,0(a0)
ffffffffc02048ba:	1101                	addi	sp,sp,-32
ffffffffc02048bc:	ec06                	sd	ra,24(sp)
ffffffffc02048be:	4685                	li	a3,1
ffffffffc02048c0:	ffd77613          	andi	a2,a4,-3
ffffffffc02048c4:	04d61763          	bne	a2,a3,ffffffffc0204912 <fd_array_free+0x5a>
ffffffffc02048c8:	5914                	lw	a3,48(a0)
ffffffffc02048ca:	87aa                	mv	a5,a0
ffffffffc02048cc:	e29d                	bnez	a3,ffffffffc02048f2 <fd_array_free+0x3a>
ffffffffc02048ce:	468d                	li	a3,3
ffffffffc02048d0:	00d70763          	beq	a4,a3,ffffffffc02048de <fd_array_free+0x26>
ffffffffc02048d4:	60e2                	ld	ra,24(sp)
ffffffffc02048d6:	0007a023          	sw	zero,0(a5)
ffffffffc02048da:	6105                	addi	sp,sp,32
ffffffffc02048dc:	8082                	ret
ffffffffc02048de:	7508                	ld	a0,40(a0)
ffffffffc02048e0:	e43e                	sd	a5,8(sp)
ffffffffc02048e2:	29f030ef          	jal	ffffffffc0208380 <vfs_close>
ffffffffc02048e6:	67a2                	ld	a5,8(sp)
ffffffffc02048e8:	60e2                	ld	ra,24(sp)
ffffffffc02048ea:	0007a023          	sw	zero,0(a5)
ffffffffc02048ee:	6105                	addi	sp,sp,32
ffffffffc02048f0:	8082                	ret
ffffffffc02048f2:	00009697          	auipc	a3,0x9
ffffffffc02048f6:	9ae68693          	addi	a3,a3,-1618 # ffffffffc020d2a0 <etext+0x1a40>
ffffffffc02048fa:	00007617          	auipc	a2,0x7
ffffffffc02048fe:	39e60613          	addi	a2,a2,926 # ffffffffc020bc98 <etext+0x438>
ffffffffc0204902:	04500593          	li	a1,69
ffffffffc0204906:	00009517          	auipc	a0,0x9
ffffffffc020490a:	98a50513          	addi	a0,a0,-1654 # ffffffffc020d290 <etext+0x1a30>
ffffffffc020490e:	b3dfb0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0204912:	00009697          	auipc	a3,0x9
ffffffffc0204916:	9c668693          	addi	a3,a3,-1594 # ffffffffc020d2d8 <etext+0x1a78>
ffffffffc020491a:	00007617          	auipc	a2,0x7
ffffffffc020491e:	37e60613          	addi	a2,a2,894 # ffffffffc020bc98 <etext+0x438>
ffffffffc0204922:	04400593          	li	a1,68
ffffffffc0204926:	00009517          	auipc	a0,0x9
ffffffffc020492a:	96a50513          	addi	a0,a0,-1686 # ffffffffc020d290 <etext+0x1a30>
ffffffffc020492e:	b1dfb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0204932 <fd_array_release>:
ffffffffc0204932:	411c                	lw	a5,0(a0)
ffffffffc0204934:	1141                	addi	sp,sp,-16
ffffffffc0204936:	e406                	sd	ra,8(sp)
ffffffffc0204938:	4685                	li	a3,1
ffffffffc020493a:	37f9                	addiw	a5,a5,-2
ffffffffc020493c:	02f6ef63          	bltu	a3,a5,ffffffffc020497a <fd_array_release+0x48>
ffffffffc0204940:	591c                	lw	a5,48(a0)
ffffffffc0204942:	00f05c63          	blez	a5,ffffffffc020495a <fd_array_release+0x28>
ffffffffc0204946:	37fd                	addiw	a5,a5,-1
ffffffffc0204948:	d91c                	sw	a5,48(a0)
ffffffffc020494a:	c781                	beqz	a5,ffffffffc0204952 <fd_array_release+0x20>
ffffffffc020494c:	60a2                	ld	ra,8(sp)
ffffffffc020494e:	0141                	addi	sp,sp,16
ffffffffc0204950:	8082                	ret
ffffffffc0204952:	60a2                	ld	ra,8(sp)
ffffffffc0204954:	0141                	addi	sp,sp,16
ffffffffc0204956:	f63ff06f          	j	ffffffffc02048b8 <fd_array_free>
ffffffffc020495a:	00009697          	auipc	a3,0x9
ffffffffc020495e:	9ee68693          	addi	a3,a3,-1554 # ffffffffc020d348 <etext+0x1ae8>
ffffffffc0204962:	00007617          	auipc	a2,0x7
ffffffffc0204966:	33660613          	addi	a2,a2,822 # ffffffffc020bc98 <etext+0x438>
ffffffffc020496a:	05600593          	li	a1,86
ffffffffc020496e:	00009517          	auipc	a0,0x9
ffffffffc0204972:	92250513          	addi	a0,a0,-1758 # ffffffffc020d290 <etext+0x1a30>
ffffffffc0204976:	ad5fb0ef          	jal	ffffffffc020044a <__panic>
ffffffffc020497a:	00009697          	auipc	a3,0x9
ffffffffc020497e:	99668693          	addi	a3,a3,-1642 # ffffffffc020d310 <etext+0x1ab0>
ffffffffc0204982:	00007617          	auipc	a2,0x7
ffffffffc0204986:	31660613          	addi	a2,a2,790 # ffffffffc020bc98 <etext+0x438>
ffffffffc020498a:	05500593          	li	a1,85
ffffffffc020498e:	00009517          	auipc	a0,0x9
ffffffffc0204992:	90250513          	addi	a0,a0,-1790 # ffffffffc020d290 <etext+0x1a30>
ffffffffc0204996:	ab5fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020499a <fd_array_open.part.0>:
ffffffffc020499a:	1141                	addi	sp,sp,-16
ffffffffc020499c:	00009697          	auipc	a3,0x9
ffffffffc02049a0:	9c468693          	addi	a3,a3,-1596 # ffffffffc020d360 <etext+0x1b00>
ffffffffc02049a4:	00007617          	auipc	a2,0x7
ffffffffc02049a8:	2f460613          	addi	a2,a2,756 # ffffffffc020bc98 <etext+0x438>
ffffffffc02049ac:	05f00593          	li	a1,95
ffffffffc02049b0:	00009517          	auipc	a0,0x9
ffffffffc02049b4:	8e050513          	addi	a0,a0,-1824 # ffffffffc020d290 <etext+0x1a30>
ffffffffc02049b8:	e406                	sd	ra,8(sp)
ffffffffc02049ba:	a91fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02049be <fd_array_init>:
ffffffffc02049be:	4781                	li	a5,0
ffffffffc02049c0:	04800713          	li	a4,72
ffffffffc02049c4:	cd1c                	sw	a5,24(a0)
ffffffffc02049c6:	02052823          	sw	zero,48(a0)
ffffffffc02049ca:	00052023          	sw	zero,0(a0)
ffffffffc02049ce:	2785                	addiw	a5,a5,1
ffffffffc02049d0:	03850513          	addi	a0,a0,56
ffffffffc02049d4:	fee798e3          	bne	a5,a4,ffffffffc02049c4 <fd_array_init+0x6>
ffffffffc02049d8:	8082                	ret

ffffffffc02049da <fd_array_close>:
ffffffffc02049da:	4114                	lw	a3,0(a0)
ffffffffc02049dc:	1101                	addi	sp,sp,-32
ffffffffc02049de:	ec06                	sd	ra,24(sp)
ffffffffc02049e0:	4789                	li	a5,2
ffffffffc02049e2:	04f69863          	bne	a3,a5,ffffffffc0204a32 <fd_array_close+0x58>
ffffffffc02049e6:	591c                	lw	a5,48(a0)
ffffffffc02049e8:	872a                	mv	a4,a0
ffffffffc02049ea:	02f05463          	blez	a5,ffffffffc0204a12 <fd_array_close+0x38>
ffffffffc02049ee:	37fd                	addiw	a5,a5,-1
ffffffffc02049f0:	468d                	li	a3,3
ffffffffc02049f2:	d91c                	sw	a5,48(a0)
ffffffffc02049f4:	c114                	sw	a3,0(a0)
ffffffffc02049f6:	c781                	beqz	a5,ffffffffc02049fe <fd_array_close+0x24>
ffffffffc02049f8:	60e2                	ld	ra,24(sp)
ffffffffc02049fa:	6105                	addi	sp,sp,32
ffffffffc02049fc:	8082                	ret
ffffffffc02049fe:	7508                	ld	a0,40(a0)
ffffffffc0204a00:	e43a                	sd	a4,8(sp)
ffffffffc0204a02:	17f030ef          	jal	ffffffffc0208380 <vfs_close>
ffffffffc0204a06:	6722                	ld	a4,8(sp)
ffffffffc0204a08:	60e2                	ld	ra,24(sp)
ffffffffc0204a0a:	00072023          	sw	zero,0(a4)
ffffffffc0204a0e:	6105                	addi	sp,sp,32
ffffffffc0204a10:	8082                	ret
ffffffffc0204a12:	00009697          	auipc	a3,0x9
ffffffffc0204a16:	93668693          	addi	a3,a3,-1738 # ffffffffc020d348 <etext+0x1ae8>
ffffffffc0204a1a:	00007617          	auipc	a2,0x7
ffffffffc0204a1e:	27e60613          	addi	a2,a2,638 # ffffffffc020bc98 <etext+0x438>
ffffffffc0204a22:	06800593          	li	a1,104
ffffffffc0204a26:	00009517          	auipc	a0,0x9
ffffffffc0204a2a:	86a50513          	addi	a0,a0,-1942 # ffffffffc020d290 <etext+0x1a30>
ffffffffc0204a2e:	a1dfb0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0204a32:	00009697          	auipc	a3,0x9
ffffffffc0204a36:	88668693          	addi	a3,a3,-1914 # ffffffffc020d2b8 <etext+0x1a58>
ffffffffc0204a3a:	00007617          	auipc	a2,0x7
ffffffffc0204a3e:	25e60613          	addi	a2,a2,606 # ffffffffc020bc98 <etext+0x438>
ffffffffc0204a42:	06700593          	li	a1,103
ffffffffc0204a46:	00009517          	auipc	a0,0x9
ffffffffc0204a4a:	84a50513          	addi	a0,a0,-1974 # ffffffffc020d290 <etext+0x1a30>
ffffffffc0204a4e:	9fdfb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0204a52 <fd_array_dup>:
ffffffffc0204a52:	4118                	lw	a4,0(a0)
ffffffffc0204a54:	1101                	addi	sp,sp,-32
ffffffffc0204a56:	ec06                	sd	ra,24(sp)
ffffffffc0204a58:	e822                	sd	s0,16(sp)
ffffffffc0204a5a:	e426                	sd	s1,8(sp)
ffffffffc0204a5c:	e04a                	sd	s2,0(sp)
ffffffffc0204a5e:	4785                	li	a5,1
ffffffffc0204a60:	04f71563          	bne	a4,a5,ffffffffc0204aaa <fd_array_dup+0x58>
ffffffffc0204a64:	0005a903          	lw	s2,0(a1)
ffffffffc0204a68:	4789                	li	a5,2
ffffffffc0204a6a:	04f91063          	bne	s2,a5,ffffffffc0204aaa <fd_array_dup+0x58>
ffffffffc0204a6e:	719c                	ld	a5,32(a1)
ffffffffc0204a70:	7584                	ld	s1,40(a1)
ffffffffc0204a72:	842a                	mv	s0,a0
ffffffffc0204a74:	f11c                	sd	a5,32(a0)
ffffffffc0204a76:	699c                	ld	a5,16(a1)
ffffffffc0204a78:	6598                	ld	a4,8(a1)
ffffffffc0204a7a:	8526                	mv	a0,s1
ffffffffc0204a7c:	e81c                	sd	a5,16(s0)
ffffffffc0204a7e:	e418                	sd	a4,8(s0)
ffffffffc0204a80:	014030ef          	jal	ffffffffc0207a94 <inode_ref_inc>
ffffffffc0204a84:	8526                	mv	a0,s1
ffffffffc0204a86:	018030ef          	jal	ffffffffc0207a9e <inode_open_inc>
ffffffffc0204a8a:	401c                	lw	a5,0(s0)
ffffffffc0204a8c:	f404                	sd	s1,40(s0)
ffffffffc0204a8e:	17fd                	addi	a5,a5,-1
ffffffffc0204a90:	ef8d                	bnez	a5,ffffffffc0204aca <fd_array_dup+0x78>
ffffffffc0204a92:	cc85                	beqz	s1,ffffffffc0204aca <fd_array_dup+0x78>
ffffffffc0204a94:	581c                	lw	a5,48(s0)
ffffffffc0204a96:	01242023          	sw	s2,0(s0)
ffffffffc0204a9a:	60e2                	ld	ra,24(sp)
ffffffffc0204a9c:	2785                	addiw	a5,a5,1
ffffffffc0204a9e:	d81c                	sw	a5,48(s0)
ffffffffc0204aa0:	6442                	ld	s0,16(sp)
ffffffffc0204aa2:	64a2                	ld	s1,8(sp)
ffffffffc0204aa4:	6902                	ld	s2,0(sp)
ffffffffc0204aa6:	6105                	addi	sp,sp,32
ffffffffc0204aa8:	8082                	ret
ffffffffc0204aaa:	00009697          	auipc	a3,0x9
ffffffffc0204aae:	8e668693          	addi	a3,a3,-1818 # ffffffffc020d390 <etext+0x1b30>
ffffffffc0204ab2:	00007617          	auipc	a2,0x7
ffffffffc0204ab6:	1e660613          	addi	a2,a2,486 # ffffffffc020bc98 <etext+0x438>
ffffffffc0204aba:	07300593          	li	a1,115
ffffffffc0204abe:	00008517          	auipc	a0,0x8
ffffffffc0204ac2:	7d250513          	addi	a0,a0,2002 # ffffffffc020d290 <etext+0x1a30>
ffffffffc0204ac6:	985fb0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0204aca:	ed1ff0ef          	jal	ffffffffc020499a <fd_array_open.part.0>

ffffffffc0204ace <file_testfd>:
ffffffffc0204ace:	04700793          	li	a5,71
ffffffffc0204ad2:	04a7e263          	bltu	a5,a0,ffffffffc0204b16 <file_testfd+0x48>
ffffffffc0204ad6:	00092797          	auipc	a5,0x92
ffffffffc0204ada:	df27b783          	ld	a5,-526(a5) # ffffffffc02968c8 <current>
ffffffffc0204ade:	1487b783          	ld	a5,328(a5)
ffffffffc0204ae2:	cf85                	beqz	a5,ffffffffc0204b1a <file_testfd+0x4c>
ffffffffc0204ae4:	4b98                	lw	a4,16(a5)
ffffffffc0204ae6:	02e05a63          	blez	a4,ffffffffc0204b1a <file_testfd+0x4c>
ffffffffc0204aea:	6798                	ld	a4,8(a5)
ffffffffc0204aec:	00351793          	slli	a5,a0,0x3
ffffffffc0204af0:	8f89                	sub	a5,a5,a0
ffffffffc0204af2:	078e                	slli	a5,a5,0x3
ffffffffc0204af4:	97ba                	add	a5,a5,a4
ffffffffc0204af6:	4394                	lw	a3,0(a5)
ffffffffc0204af8:	4709                	li	a4,2
ffffffffc0204afa:	00e69e63          	bne	a3,a4,ffffffffc0204b16 <file_testfd+0x48>
ffffffffc0204afe:	4f98                	lw	a4,24(a5)
ffffffffc0204b00:	00a71b63          	bne	a4,a0,ffffffffc0204b16 <file_testfd+0x48>
ffffffffc0204b04:	c199                	beqz	a1,ffffffffc0204b0a <file_testfd+0x3c>
ffffffffc0204b06:	6788                	ld	a0,8(a5)
ffffffffc0204b08:	c901                	beqz	a0,ffffffffc0204b18 <file_testfd+0x4a>
ffffffffc0204b0a:	4505                	li	a0,1
ffffffffc0204b0c:	c611                	beqz	a2,ffffffffc0204b18 <file_testfd+0x4a>
ffffffffc0204b0e:	6b88                	ld	a0,16(a5)
ffffffffc0204b10:	00a03533          	snez	a0,a0
ffffffffc0204b14:	8082                	ret
ffffffffc0204b16:	4501                	li	a0,0
ffffffffc0204b18:	8082                	ret
ffffffffc0204b1a:	1141                	addi	sp,sp,-16
ffffffffc0204b1c:	e406                	sd	ra,8(sp)
ffffffffc0204b1e:	ce7ff0ef          	jal	ffffffffc0204804 <get_fd_array.part.0>

ffffffffc0204b22 <file_open>:
ffffffffc0204b22:	0035f793          	andi	a5,a1,3
ffffffffc0204b26:	470d                	li	a4,3
ffffffffc0204b28:	0ee78563          	beq	a5,a4,ffffffffc0204c12 <file_open+0xf0>
ffffffffc0204b2c:	078e                	slli	a5,a5,0x3
ffffffffc0204b2e:	0000a717          	auipc	a4,0xa
ffffffffc0204b32:	45a70713          	addi	a4,a4,1114 # ffffffffc020ef88 <CSWTCH.79>
ffffffffc0204b36:	0000a697          	auipc	a3,0xa
ffffffffc0204b3a:	46a68693          	addi	a3,a3,1130 # ffffffffc020efa0 <CSWTCH.78>
ffffffffc0204b3e:	96be                	add	a3,a3,a5
ffffffffc0204b40:	97ba                	add	a5,a5,a4
ffffffffc0204b42:	7159                	addi	sp,sp,-112
ffffffffc0204b44:	639c                	ld	a5,0(a5)
ffffffffc0204b46:	6298                	ld	a4,0(a3)
ffffffffc0204b48:	eca6                	sd	s1,88(sp)
ffffffffc0204b4a:	84aa                	mv	s1,a0
ffffffffc0204b4c:	755d                	lui	a0,0xffff7
ffffffffc0204b4e:	f0a2                	sd	s0,96(sp)
ffffffffc0204b50:	ad950513          	addi	a0,a0,-1319 # ffffffffffff6ad9 <end+0x3fd601c9>
ffffffffc0204b54:	842e                	mv	s0,a1
ffffffffc0204b56:	080c                	addi	a1,sp,16
ffffffffc0204b58:	e8ca                	sd	s2,80(sp)
ffffffffc0204b5a:	e4ce                	sd	s3,72(sp)
ffffffffc0204b5c:	f486                	sd	ra,104(sp)
ffffffffc0204b5e:	89be                	mv	s3,a5
ffffffffc0204b60:	893a                	mv	s2,a4
ffffffffc0204b62:	cc5ff0ef          	jal	ffffffffc0204826 <fd_array_alloc>
ffffffffc0204b66:	87aa                	mv	a5,a0
ffffffffc0204b68:	c909                	beqz	a0,ffffffffc0204b7a <file_open+0x58>
ffffffffc0204b6a:	70a6                	ld	ra,104(sp)
ffffffffc0204b6c:	7406                	ld	s0,96(sp)
ffffffffc0204b6e:	64e6                	ld	s1,88(sp)
ffffffffc0204b70:	6946                	ld	s2,80(sp)
ffffffffc0204b72:	69a6                	ld	s3,72(sp)
ffffffffc0204b74:	853e                	mv	a0,a5
ffffffffc0204b76:	6165                	addi	sp,sp,112
ffffffffc0204b78:	8082                	ret
ffffffffc0204b7a:	8526                	mv	a0,s1
ffffffffc0204b7c:	0830                	addi	a2,sp,24
ffffffffc0204b7e:	85a2                	mv	a1,s0
ffffffffc0204b80:	62a030ef          	jal	ffffffffc02081aa <vfs_open>
ffffffffc0204b84:	6742                	ld	a4,16(sp)
ffffffffc0204b86:	e141                	bnez	a0,ffffffffc0204c06 <file_open+0xe4>
ffffffffc0204b88:	02073023          	sd	zero,32(a4)
ffffffffc0204b8c:	02047593          	andi	a1,s0,32
ffffffffc0204b90:	c98d                	beqz	a1,ffffffffc0204bc2 <file_open+0xa0>
ffffffffc0204b92:	6562                	ld	a0,24(sp)
ffffffffc0204b94:	c541                	beqz	a0,ffffffffc0204c1c <file_open+0xfa>
ffffffffc0204b96:	793c                	ld	a5,112(a0)
ffffffffc0204b98:	c3d1                	beqz	a5,ffffffffc0204c1c <file_open+0xfa>
ffffffffc0204b9a:	779c                	ld	a5,40(a5)
ffffffffc0204b9c:	c3c1                	beqz	a5,ffffffffc0204c1c <file_open+0xfa>
ffffffffc0204b9e:	00009597          	auipc	a1,0x9
ffffffffc0204ba2:	87a58593          	addi	a1,a1,-1926 # ffffffffc020d418 <etext+0x1bb8>
ffffffffc0204ba6:	e43a                	sd	a4,8(sp)
ffffffffc0204ba8:	e02a                	sd	a0,0(sp)
ffffffffc0204baa:	6ff020ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc0204bae:	6502                	ld	a0,0(sp)
ffffffffc0204bb0:	100c                	addi	a1,sp,32
ffffffffc0204bb2:	793c                	ld	a5,112(a0)
ffffffffc0204bb4:	6562                	ld	a0,24(sp)
ffffffffc0204bb6:	779c                	ld	a5,40(a5)
ffffffffc0204bb8:	9782                	jalr	a5
ffffffffc0204bba:	6722                	ld	a4,8(sp)
ffffffffc0204bbc:	e91d                	bnez	a0,ffffffffc0204bf2 <file_open+0xd0>
ffffffffc0204bbe:	77e2                	ld	a5,56(sp)
ffffffffc0204bc0:	f31c                	sd	a5,32(a4)
ffffffffc0204bc2:	66e2                	ld	a3,24(sp)
ffffffffc0204bc4:	431c                	lw	a5,0(a4)
ffffffffc0204bc6:	01273423          	sd	s2,8(a4)
ffffffffc0204bca:	01373823          	sd	s3,16(a4)
ffffffffc0204bce:	f714                	sd	a3,40(a4)
ffffffffc0204bd0:	17fd                	addi	a5,a5,-1
ffffffffc0204bd2:	e3b9                	bnez	a5,ffffffffc0204c18 <file_open+0xf6>
ffffffffc0204bd4:	c2b1                	beqz	a3,ffffffffc0204c18 <file_open+0xf6>
ffffffffc0204bd6:	5b1c                	lw	a5,48(a4)
ffffffffc0204bd8:	70a6                	ld	ra,104(sp)
ffffffffc0204bda:	7406                	ld	s0,96(sp)
ffffffffc0204bdc:	2785                	addiw	a5,a5,1
ffffffffc0204bde:	db1c                	sw	a5,48(a4)
ffffffffc0204be0:	4f1c                	lw	a5,24(a4)
ffffffffc0204be2:	4689                	li	a3,2
ffffffffc0204be4:	c314                	sw	a3,0(a4)
ffffffffc0204be6:	64e6                	ld	s1,88(sp)
ffffffffc0204be8:	6946                	ld	s2,80(sp)
ffffffffc0204bea:	69a6                	ld	s3,72(sp)
ffffffffc0204bec:	853e                	mv	a0,a5
ffffffffc0204bee:	6165                	addi	sp,sp,112
ffffffffc0204bf0:	8082                	ret
ffffffffc0204bf2:	e42a                	sd	a0,8(sp)
ffffffffc0204bf4:	6562                	ld	a0,24(sp)
ffffffffc0204bf6:	e03a                	sd	a4,0(sp)
ffffffffc0204bf8:	788030ef          	jal	ffffffffc0208380 <vfs_close>
ffffffffc0204bfc:	6502                	ld	a0,0(sp)
ffffffffc0204bfe:	cbbff0ef          	jal	ffffffffc02048b8 <fd_array_free>
ffffffffc0204c02:	67a2                	ld	a5,8(sp)
ffffffffc0204c04:	b79d                	j	ffffffffc0204b6a <file_open+0x48>
ffffffffc0204c06:	e02a                	sd	a0,0(sp)
ffffffffc0204c08:	853a                	mv	a0,a4
ffffffffc0204c0a:	cafff0ef          	jal	ffffffffc02048b8 <fd_array_free>
ffffffffc0204c0e:	6782                	ld	a5,0(sp)
ffffffffc0204c10:	bfa9                	j	ffffffffc0204b6a <file_open+0x48>
ffffffffc0204c12:	57f5                	li	a5,-3
ffffffffc0204c14:	853e                	mv	a0,a5
ffffffffc0204c16:	8082                	ret
ffffffffc0204c18:	d83ff0ef          	jal	ffffffffc020499a <fd_array_open.part.0>
ffffffffc0204c1c:	00008697          	auipc	a3,0x8
ffffffffc0204c20:	7ac68693          	addi	a3,a3,1964 # ffffffffc020d3c8 <etext+0x1b68>
ffffffffc0204c24:	00007617          	auipc	a2,0x7
ffffffffc0204c28:	07460613          	addi	a2,a2,116 # ffffffffc020bc98 <etext+0x438>
ffffffffc0204c2c:	0b500593          	li	a1,181
ffffffffc0204c30:	00008517          	auipc	a0,0x8
ffffffffc0204c34:	66050513          	addi	a0,a0,1632 # ffffffffc020d290 <etext+0x1a30>
ffffffffc0204c38:	813fb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0204c3c <file_close>:
ffffffffc0204c3c:	04700793          	li	a5,71
ffffffffc0204c40:	04a7e663          	bltu	a5,a0,ffffffffc0204c8c <file_close+0x50>
ffffffffc0204c44:	00092717          	auipc	a4,0x92
ffffffffc0204c48:	c8473703          	ld	a4,-892(a4) # ffffffffc02968c8 <current>
ffffffffc0204c4c:	1141                	addi	sp,sp,-16
ffffffffc0204c4e:	e406                	sd	ra,8(sp)
ffffffffc0204c50:	14873703          	ld	a4,328(a4)
ffffffffc0204c54:	87aa                	mv	a5,a0
ffffffffc0204c56:	cf0d                	beqz	a4,ffffffffc0204c90 <file_close+0x54>
ffffffffc0204c58:	4b14                	lw	a3,16(a4)
ffffffffc0204c5a:	02d05b63          	blez	a3,ffffffffc0204c90 <file_close+0x54>
ffffffffc0204c5e:	6708                	ld	a0,8(a4)
ffffffffc0204c60:	00379713          	slli	a4,a5,0x3
ffffffffc0204c64:	8f1d                	sub	a4,a4,a5
ffffffffc0204c66:	070e                	slli	a4,a4,0x3
ffffffffc0204c68:	953a                	add	a0,a0,a4
ffffffffc0204c6a:	4114                	lw	a3,0(a0)
ffffffffc0204c6c:	4709                	li	a4,2
ffffffffc0204c6e:	00e69b63          	bne	a3,a4,ffffffffc0204c84 <file_close+0x48>
ffffffffc0204c72:	4d18                	lw	a4,24(a0)
ffffffffc0204c74:	00f71863          	bne	a4,a5,ffffffffc0204c84 <file_close+0x48>
ffffffffc0204c78:	d63ff0ef          	jal	ffffffffc02049da <fd_array_close>
ffffffffc0204c7c:	60a2                	ld	ra,8(sp)
ffffffffc0204c7e:	4501                	li	a0,0
ffffffffc0204c80:	0141                	addi	sp,sp,16
ffffffffc0204c82:	8082                	ret
ffffffffc0204c84:	60a2                	ld	ra,8(sp)
ffffffffc0204c86:	5575                	li	a0,-3
ffffffffc0204c88:	0141                	addi	sp,sp,16
ffffffffc0204c8a:	8082                	ret
ffffffffc0204c8c:	5575                	li	a0,-3
ffffffffc0204c8e:	8082                	ret
ffffffffc0204c90:	b75ff0ef          	jal	ffffffffc0204804 <get_fd_array.part.0>

ffffffffc0204c94 <file_read>:
ffffffffc0204c94:	711d                	addi	sp,sp,-96
ffffffffc0204c96:	ec86                	sd	ra,88(sp)
ffffffffc0204c98:	e0ca                	sd	s2,64(sp)
ffffffffc0204c9a:	0006b023          	sd	zero,0(a3)
ffffffffc0204c9e:	04700793          	li	a5,71
ffffffffc0204ca2:	0aa7ec63          	bltu	a5,a0,ffffffffc0204d5a <file_read+0xc6>
ffffffffc0204ca6:	00092797          	auipc	a5,0x92
ffffffffc0204caa:	c227b783          	ld	a5,-990(a5) # ffffffffc02968c8 <current>
ffffffffc0204cae:	e4a6                	sd	s1,72(sp)
ffffffffc0204cb0:	e8a2                	sd	s0,80(sp)
ffffffffc0204cb2:	1487b783          	ld	a5,328(a5)
ffffffffc0204cb6:	fc4e                	sd	s3,56(sp)
ffffffffc0204cb8:	84b6                	mv	s1,a3
ffffffffc0204cba:	c3f1                	beqz	a5,ffffffffc0204d7e <file_read+0xea>
ffffffffc0204cbc:	4b98                	lw	a4,16(a5)
ffffffffc0204cbe:	0ce05063          	blez	a4,ffffffffc0204d7e <file_read+0xea>
ffffffffc0204cc2:	6780                	ld	s0,8(a5)
ffffffffc0204cc4:	00351793          	slli	a5,a0,0x3
ffffffffc0204cc8:	8f89                	sub	a5,a5,a0
ffffffffc0204cca:	078e                	slli	a5,a5,0x3
ffffffffc0204ccc:	943e                	add	s0,s0,a5
ffffffffc0204cce:	00042983          	lw	s3,0(s0)
ffffffffc0204cd2:	4789                	li	a5,2
ffffffffc0204cd4:	06f99a63          	bne	s3,a5,ffffffffc0204d48 <file_read+0xb4>
ffffffffc0204cd8:	4c1c                	lw	a5,24(s0)
ffffffffc0204cda:	06a79763          	bne	a5,a0,ffffffffc0204d48 <file_read+0xb4>
ffffffffc0204cde:	641c                	ld	a5,8(s0)
ffffffffc0204ce0:	c7a5                	beqz	a5,ffffffffc0204d48 <file_read+0xb4>
ffffffffc0204ce2:	581c                	lw	a5,48(s0)
ffffffffc0204ce4:	7014                	ld	a3,32(s0)
ffffffffc0204ce6:	0808                	addi	a0,sp,16
ffffffffc0204ce8:	2785                	addiw	a5,a5,1
ffffffffc0204cea:	d81c                	sw	a5,48(s0)
ffffffffc0204cec:	7a0000ef          	jal	ffffffffc020548c <iobuf_init>
ffffffffc0204cf0:	892a                	mv	s2,a0
ffffffffc0204cf2:	7408                	ld	a0,40(s0)
ffffffffc0204cf4:	c52d                	beqz	a0,ffffffffc0204d5e <file_read+0xca>
ffffffffc0204cf6:	793c                	ld	a5,112(a0)
ffffffffc0204cf8:	c3bd                	beqz	a5,ffffffffc0204d5e <file_read+0xca>
ffffffffc0204cfa:	6f9c                	ld	a5,24(a5)
ffffffffc0204cfc:	c3ad                	beqz	a5,ffffffffc0204d5e <file_read+0xca>
ffffffffc0204cfe:	00008597          	auipc	a1,0x8
ffffffffc0204d02:	77258593          	addi	a1,a1,1906 # ffffffffc020d470 <etext+0x1c10>
ffffffffc0204d06:	e42a                	sd	a0,8(sp)
ffffffffc0204d08:	5a1020ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc0204d0c:	6522                	ld	a0,8(sp)
ffffffffc0204d0e:	85ca                	mv	a1,s2
ffffffffc0204d10:	793c                	ld	a5,112(a0)
ffffffffc0204d12:	7408                	ld	a0,40(s0)
ffffffffc0204d14:	6f9c                	ld	a5,24(a5)
ffffffffc0204d16:	9782                	jalr	a5
ffffffffc0204d18:	01093783          	ld	a5,16(s2)
ffffffffc0204d1c:	01893683          	ld	a3,24(s2)
ffffffffc0204d20:	4018                	lw	a4,0(s0)
ffffffffc0204d22:	892a                	mv	s2,a0
ffffffffc0204d24:	8f95                	sub	a5,a5,a3
ffffffffc0204d26:	01371563          	bne	a4,s3,ffffffffc0204d30 <file_read+0x9c>
ffffffffc0204d2a:	7018                	ld	a4,32(s0)
ffffffffc0204d2c:	973e                	add	a4,a4,a5
ffffffffc0204d2e:	f018                	sd	a4,32(s0)
ffffffffc0204d30:	e09c                	sd	a5,0(s1)
ffffffffc0204d32:	8522                	mv	a0,s0
ffffffffc0204d34:	bffff0ef          	jal	ffffffffc0204932 <fd_array_release>
ffffffffc0204d38:	6446                	ld	s0,80(sp)
ffffffffc0204d3a:	64a6                	ld	s1,72(sp)
ffffffffc0204d3c:	79e2                	ld	s3,56(sp)
ffffffffc0204d3e:	60e6                	ld	ra,88(sp)
ffffffffc0204d40:	854a                	mv	a0,s2
ffffffffc0204d42:	6906                	ld	s2,64(sp)
ffffffffc0204d44:	6125                	addi	sp,sp,96
ffffffffc0204d46:	8082                	ret
ffffffffc0204d48:	6446                	ld	s0,80(sp)
ffffffffc0204d4a:	60e6                	ld	ra,88(sp)
ffffffffc0204d4c:	5975                	li	s2,-3
ffffffffc0204d4e:	64a6                	ld	s1,72(sp)
ffffffffc0204d50:	79e2                	ld	s3,56(sp)
ffffffffc0204d52:	854a                	mv	a0,s2
ffffffffc0204d54:	6906                	ld	s2,64(sp)
ffffffffc0204d56:	6125                	addi	sp,sp,96
ffffffffc0204d58:	8082                	ret
ffffffffc0204d5a:	5975                	li	s2,-3
ffffffffc0204d5c:	b7cd                	j	ffffffffc0204d3e <file_read+0xaa>
ffffffffc0204d5e:	00008697          	auipc	a3,0x8
ffffffffc0204d62:	6c268693          	addi	a3,a3,1730 # ffffffffc020d420 <etext+0x1bc0>
ffffffffc0204d66:	00007617          	auipc	a2,0x7
ffffffffc0204d6a:	f3260613          	addi	a2,a2,-206 # ffffffffc020bc98 <etext+0x438>
ffffffffc0204d6e:	0de00593          	li	a1,222
ffffffffc0204d72:	00008517          	auipc	a0,0x8
ffffffffc0204d76:	51e50513          	addi	a0,a0,1310 # ffffffffc020d290 <etext+0x1a30>
ffffffffc0204d7a:	ed0fb0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0204d7e:	a87ff0ef          	jal	ffffffffc0204804 <get_fd_array.part.0>

ffffffffc0204d82 <file_write>:
ffffffffc0204d82:	711d                	addi	sp,sp,-96
ffffffffc0204d84:	ec86                	sd	ra,88(sp)
ffffffffc0204d86:	e0ca                	sd	s2,64(sp)
ffffffffc0204d88:	0006b023          	sd	zero,0(a3)
ffffffffc0204d8c:	04700793          	li	a5,71
ffffffffc0204d90:	0aa7ec63          	bltu	a5,a0,ffffffffc0204e48 <file_write+0xc6>
ffffffffc0204d94:	00092797          	auipc	a5,0x92
ffffffffc0204d98:	b347b783          	ld	a5,-1228(a5) # ffffffffc02968c8 <current>
ffffffffc0204d9c:	e4a6                	sd	s1,72(sp)
ffffffffc0204d9e:	e8a2                	sd	s0,80(sp)
ffffffffc0204da0:	1487b783          	ld	a5,328(a5)
ffffffffc0204da4:	fc4e                	sd	s3,56(sp)
ffffffffc0204da6:	84b6                	mv	s1,a3
ffffffffc0204da8:	c3f1                	beqz	a5,ffffffffc0204e6c <file_write+0xea>
ffffffffc0204daa:	4b98                	lw	a4,16(a5)
ffffffffc0204dac:	0ce05063          	blez	a4,ffffffffc0204e6c <file_write+0xea>
ffffffffc0204db0:	6780                	ld	s0,8(a5)
ffffffffc0204db2:	00351793          	slli	a5,a0,0x3
ffffffffc0204db6:	8f89                	sub	a5,a5,a0
ffffffffc0204db8:	078e                	slli	a5,a5,0x3
ffffffffc0204dba:	943e                	add	s0,s0,a5
ffffffffc0204dbc:	00042983          	lw	s3,0(s0)
ffffffffc0204dc0:	4789                	li	a5,2
ffffffffc0204dc2:	06f99a63          	bne	s3,a5,ffffffffc0204e36 <file_write+0xb4>
ffffffffc0204dc6:	4c1c                	lw	a5,24(s0)
ffffffffc0204dc8:	06a79763          	bne	a5,a0,ffffffffc0204e36 <file_write+0xb4>
ffffffffc0204dcc:	681c                	ld	a5,16(s0)
ffffffffc0204dce:	c7a5                	beqz	a5,ffffffffc0204e36 <file_write+0xb4>
ffffffffc0204dd0:	581c                	lw	a5,48(s0)
ffffffffc0204dd2:	7014                	ld	a3,32(s0)
ffffffffc0204dd4:	0808                	addi	a0,sp,16
ffffffffc0204dd6:	2785                	addiw	a5,a5,1
ffffffffc0204dd8:	d81c                	sw	a5,48(s0)
ffffffffc0204dda:	6b2000ef          	jal	ffffffffc020548c <iobuf_init>
ffffffffc0204dde:	892a                	mv	s2,a0
ffffffffc0204de0:	7408                	ld	a0,40(s0)
ffffffffc0204de2:	c52d                	beqz	a0,ffffffffc0204e4c <file_write+0xca>
ffffffffc0204de4:	793c                	ld	a5,112(a0)
ffffffffc0204de6:	c3bd                	beqz	a5,ffffffffc0204e4c <file_write+0xca>
ffffffffc0204de8:	739c                	ld	a5,32(a5)
ffffffffc0204dea:	c3ad                	beqz	a5,ffffffffc0204e4c <file_write+0xca>
ffffffffc0204dec:	00008597          	auipc	a1,0x8
ffffffffc0204df0:	6dc58593          	addi	a1,a1,1756 # ffffffffc020d4c8 <etext+0x1c68>
ffffffffc0204df4:	e42a                	sd	a0,8(sp)
ffffffffc0204df6:	4b3020ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc0204dfa:	6522                	ld	a0,8(sp)
ffffffffc0204dfc:	85ca                	mv	a1,s2
ffffffffc0204dfe:	793c                	ld	a5,112(a0)
ffffffffc0204e00:	7408                	ld	a0,40(s0)
ffffffffc0204e02:	739c                	ld	a5,32(a5)
ffffffffc0204e04:	9782                	jalr	a5
ffffffffc0204e06:	01093783          	ld	a5,16(s2)
ffffffffc0204e0a:	01893683          	ld	a3,24(s2)
ffffffffc0204e0e:	4018                	lw	a4,0(s0)
ffffffffc0204e10:	892a                	mv	s2,a0
ffffffffc0204e12:	8f95                	sub	a5,a5,a3
ffffffffc0204e14:	01371563          	bne	a4,s3,ffffffffc0204e1e <file_write+0x9c>
ffffffffc0204e18:	7018                	ld	a4,32(s0)
ffffffffc0204e1a:	973e                	add	a4,a4,a5
ffffffffc0204e1c:	f018                	sd	a4,32(s0)
ffffffffc0204e1e:	e09c                	sd	a5,0(s1)
ffffffffc0204e20:	8522                	mv	a0,s0
ffffffffc0204e22:	b11ff0ef          	jal	ffffffffc0204932 <fd_array_release>
ffffffffc0204e26:	6446                	ld	s0,80(sp)
ffffffffc0204e28:	64a6                	ld	s1,72(sp)
ffffffffc0204e2a:	79e2                	ld	s3,56(sp)
ffffffffc0204e2c:	60e6                	ld	ra,88(sp)
ffffffffc0204e2e:	854a                	mv	a0,s2
ffffffffc0204e30:	6906                	ld	s2,64(sp)
ffffffffc0204e32:	6125                	addi	sp,sp,96
ffffffffc0204e34:	8082                	ret
ffffffffc0204e36:	6446                	ld	s0,80(sp)
ffffffffc0204e38:	60e6                	ld	ra,88(sp)
ffffffffc0204e3a:	5975                	li	s2,-3
ffffffffc0204e3c:	64a6                	ld	s1,72(sp)
ffffffffc0204e3e:	79e2                	ld	s3,56(sp)
ffffffffc0204e40:	854a                	mv	a0,s2
ffffffffc0204e42:	6906                	ld	s2,64(sp)
ffffffffc0204e44:	6125                	addi	sp,sp,96
ffffffffc0204e46:	8082                	ret
ffffffffc0204e48:	5975                	li	s2,-3
ffffffffc0204e4a:	b7cd                	j	ffffffffc0204e2c <file_write+0xaa>
ffffffffc0204e4c:	00008697          	auipc	a3,0x8
ffffffffc0204e50:	62c68693          	addi	a3,a3,1580 # ffffffffc020d478 <etext+0x1c18>
ffffffffc0204e54:	00007617          	auipc	a2,0x7
ffffffffc0204e58:	e4460613          	addi	a2,a2,-444 # ffffffffc020bc98 <etext+0x438>
ffffffffc0204e5c:	0f800593          	li	a1,248
ffffffffc0204e60:	00008517          	auipc	a0,0x8
ffffffffc0204e64:	43050513          	addi	a0,a0,1072 # ffffffffc020d290 <etext+0x1a30>
ffffffffc0204e68:	de2fb0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0204e6c:	999ff0ef          	jal	ffffffffc0204804 <get_fd_array.part.0>

ffffffffc0204e70 <file_seek>:
ffffffffc0204e70:	7139                	addi	sp,sp,-64
ffffffffc0204e72:	fc06                	sd	ra,56(sp)
ffffffffc0204e74:	f426                	sd	s1,40(sp)
ffffffffc0204e76:	04700793          	li	a5,71
ffffffffc0204e7a:	0ca7e563          	bltu	a5,a0,ffffffffc0204f44 <file_seek+0xd4>
ffffffffc0204e7e:	00092797          	auipc	a5,0x92
ffffffffc0204e82:	a4a7b783          	ld	a5,-1462(a5) # ffffffffc02968c8 <current>
ffffffffc0204e86:	f822                	sd	s0,48(sp)
ffffffffc0204e88:	1487b783          	ld	a5,328(a5)
ffffffffc0204e8c:	c3e9                	beqz	a5,ffffffffc0204f4e <file_seek+0xde>
ffffffffc0204e8e:	4b98                	lw	a4,16(a5)
ffffffffc0204e90:	0ae05f63          	blez	a4,ffffffffc0204f4e <file_seek+0xde>
ffffffffc0204e94:	6780                	ld	s0,8(a5)
ffffffffc0204e96:	00351793          	slli	a5,a0,0x3
ffffffffc0204e9a:	8f89                	sub	a5,a5,a0
ffffffffc0204e9c:	078e                	slli	a5,a5,0x3
ffffffffc0204e9e:	943e                	add	s0,s0,a5
ffffffffc0204ea0:	4018                	lw	a4,0(s0)
ffffffffc0204ea2:	4789                	li	a5,2
ffffffffc0204ea4:	0af71263          	bne	a4,a5,ffffffffc0204f48 <file_seek+0xd8>
ffffffffc0204ea8:	4c1c                	lw	a5,24(s0)
ffffffffc0204eaa:	f04a                	sd	s2,32(sp)
ffffffffc0204eac:	08a79863          	bne	a5,a0,ffffffffc0204f3c <file_seek+0xcc>
ffffffffc0204eb0:	581c                	lw	a5,48(s0)
ffffffffc0204eb2:	4685                	li	a3,1
ffffffffc0204eb4:	892e                	mv	s2,a1
ffffffffc0204eb6:	2785                	addiw	a5,a5,1
ffffffffc0204eb8:	d81c                	sw	a5,48(s0)
ffffffffc0204eba:	06d60d63          	beq	a2,a3,ffffffffc0204f34 <file_seek+0xc4>
ffffffffc0204ebe:	04e60463          	beq	a2,a4,ffffffffc0204f06 <file_seek+0x96>
ffffffffc0204ec2:	54f5                	li	s1,-3
ffffffffc0204ec4:	e61d                	bnez	a2,ffffffffc0204ef2 <file_seek+0x82>
ffffffffc0204ec6:	7404                	ld	s1,40(s0)
ffffffffc0204ec8:	c4d1                	beqz	s1,ffffffffc0204f54 <file_seek+0xe4>
ffffffffc0204eca:	78bc                	ld	a5,112(s1)
ffffffffc0204ecc:	c7c1                	beqz	a5,ffffffffc0204f54 <file_seek+0xe4>
ffffffffc0204ece:	6fbc                	ld	a5,88(a5)
ffffffffc0204ed0:	c3d1                	beqz	a5,ffffffffc0204f54 <file_seek+0xe4>
ffffffffc0204ed2:	8526                	mv	a0,s1
ffffffffc0204ed4:	00008597          	auipc	a1,0x8
ffffffffc0204ed8:	64c58593          	addi	a1,a1,1612 # ffffffffc020d520 <etext+0x1cc0>
ffffffffc0204edc:	3cd020ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc0204ee0:	78bc                	ld	a5,112(s1)
ffffffffc0204ee2:	7408                	ld	a0,40(s0)
ffffffffc0204ee4:	85ca                	mv	a1,s2
ffffffffc0204ee6:	6fbc                	ld	a5,88(a5)
ffffffffc0204ee8:	9782                	jalr	a5
ffffffffc0204eea:	84aa                	mv	s1,a0
ffffffffc0204eec:	e119                	bnez	a0,ffffffffc0204ef2 <file_seek+0x82>
ffffffffc0204eee:	03243023          	sd	s2,32(s0)
ffffffffc0204ef2:	8522                	mv	a0,s0
ffffffffc0204ef4:	a3fff0ef          	jal	ffffffffc0204932 <fd_array_release>
ffffffffc0204ef8:	7442                	ld	s0,48(sp)
ffffffffc0204efa:	7902                	ld	s2,32(sp)
ffffffffc0204efc:	70e2                	ld	ra,56(sp)
ffffffffc0204efe:	8526                	mv	a0,s1
ffffffffc0204f00:	74a2                	ld	s1,40(sp)
ffffffffc0204f02:	6121                	addi	sp,sp,64
ffffffffc0204f04:	8082                	ret
ffffffffc0204f06:	7404                	ld	s1,40(s0)
ffffffffc0204f08:	c4b5                	beqz	s1,ffffffffc0204f74 <file_seek+0x104>
ffffffffc0204f0a:	78bc                	ld	a5,112(s1)
ffffffffc0204f0c:	c7a5                	beqz	a5,ffffffffc0204f74 <file_seek+0x104>
ffffffffc0204f0e:	779c                	ld	a5,40(a5)
ffffffffc0204f10:	c3b5                	beqz	a5,ffffffffc0204f74 <file_seek+0x104>
ffffffffc0204f12:	8526                	mv	a0,s1
ffffffffc0204f14:	00008597          	auipc	a1,0x8
ffffffffc0204f18:	50458593          	addi	a1,a1,1284 # ffffffffc020d418 <etext+0x1bb8>
ffffffffc0204f1c:	38d020ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc0204f20:	78bc                	ld	a5,112(s1)
ffffffffc0204f22:	7408                	ld	a0,40(s0)
ffffffffc0204f24:	858a                	mv	a1,sp
ffffffffc0204f26:	779c                	ld	a5,40(a5)
ffffffffc0204f28:	9782                	jalr	a5
ffffffffc0204f2a:	84aa                	mv	s1,a0
ffffffffc0204f2c:	f179                	bnez	a0,ffffffffc0204ef2 <file_seek+0x82>
ffffffffc0204f2e:	67e2                	ld	a5,24(sp)
ffffffffc0204f30:	993e                	add	s2,s2,a5
ffffffffc0204f32:	bf51                	j	ffffffffc0204ec6 <file_seek+0x56>
ffffffffc0204f34:	701c                	ld	a5,32(s0)
ffffffffc0204f36:	00f58933          	add	s2,a1,a5
ffffffffc0204f3a:	b771                	j	ffffffffc0204ec6 <file_seek+0x56>
ffffffffc0204f3c:	7442                	ld	s0,48(sp)
ffffffffc0204f3e:	7902                	ld	s2,32(sp)
ffffffffc0204f40:	54f5                	li	s1,-3
ffffffffc0204f42:	bf6d                	j	ffffffffc0204efc <file_seek+0x8c>
ffffffffc0204f44:	54f5                	li	s1,-3
ffffffffc0204f46:	bf5d                	j	ffffffffc0204efc <file_seek+0x8c>
ffffffffc0204f48:	7442                	ld	s0,48(sp)
ffffffffc0204f4a:	54f5                	li	s1,-3
ffffffffc0204f4c:	bf45                	j	ffffffffc0204efc <file_seek+0x8c>
ffffffffc0204f4e:	f04a                	sd	s2,32(sp)
ffffffffc0204f50:	8b5ff0ef          	jal	ffffffffc0204804 <get_fd_array.part.0>
ffffffffc0204f54:	00008697          	auipc	a3,0x8
ffffffffc0204f58:	57c68693          	addi	a3,a3,1404 # ffffffffc020d4d0 <etext+0x1c70>
ffffffffc0204f5c:	00007617          	auipc	a2,0x7
ffffffffc0204f60:	d3c60613          	addi	a2,a2,-708 # ffffffffc020bc98 <etext+0x438>
ffffffffc0204f64:	11a00593          	li	a1,282
ffffffffc0204f68:	00008517          	auipc	a0,0x8
ffffffffc0204f6c:	32850513          	addi	a0,a0,808 # ffffffffc020d290 <etext+0x1a30>
ffffffffc0204f70:	cdafb0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0204f74:	00008697          	auipc	a3,0x8
ffffffffc0204f78:	45468693          	addi	a3,a3,1108 # ffffffffc020d3c8 <etext+0x1b68>
ffffffffc0204f7c:	00007617          	auipc	a2,0x7
ffffffffc0204f80:	d1c60613          	addi	a2,a2,-740 # ffffffffc020bc98 <etext+0x438>
ffffffffc0204f84:	11200593          	li	a1,274
ffffffffc0204f88:	00008517          	auipc	a0,0x8
ffffffffc0204f8c:	30850513          	addi	a0,a0,776 # ffffffffc020d290 <etext+0x1a30>
ffffffffc0204f90:	cbafb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0204f94 <file_fstat>:
ffffffffc0204f94:	7179                	addi	sp,sp,-48
ffffffffc0204f96:	f406                	sd	ra,40(sp)
ffffffffc0204f98:	f022                	sd	s0,32(sp)
ffffffffc0204f9a:	04700793          	li	a5,71
ffffffffc0204f9e:	08a7e363          	bltu	a5,a0,ffffffffc0205024 <file_fstat+0x90>
ffffffffc0204fa2:	00092797          	auipc	a5,0x92
ffffffffc0204fa6:	9267b783          	ld	a5,-1754(a5) # ffffffffc02968c8 <current>
ffffffffc0204faa:	ec26                	sd	s1,24(sp)
ffffffffc0204fac:	84ae                	mv	s1,a1
ffffffffc0204fae:	1487b783          	ld	a5,328(a5)
ffffffffc0204fb2:	cbd9                	beqz	a5,ffffffffc0205048 <file_fstat+0xb4>
ffffffffc0204fb4:	4b98                	lw	a4,16(a5)
ffffffffc0204fb6:	08e05963          	blez	a4,ffffffffc0205048 <file_fstat+0xb4>
ffffffffc0204fba:	6780                	ld	s0,8(a5)
ffffffffc0204fbc:	00351793          	slli	a5,a0,0x3
ffffffffc0204fc0:	8f89                	sub	a5,a5,a0
ffffffffc0204fc2:	078e                	slli	a5,a5,0x3
ffffffffc0204fc4:	943e                	add	s0,s0,a5
ffffffffc0204fc6:	4018                	lw	a4,0(s0)
ffffffffc0204fc8:	4789                	li	a5,2
ffffffffc0204fca:	04f71663          	bne	a4,a5,ffffffffc0205016 <file_fstat+0x82>
ffffffffc0204fce:	4c1c                	lw	a5,24(s0)
ffffffffc0204fd0:	04a79363          	bne	a5,a0,ffffffffc0205016 <file_fstat+0x82>
ffffffffc0204fd4:	581c                	lw	a5,48(s0)
ffffffffc0204fd6:	7408                	ld	a0,40(s0)
ffffffffc0204fd8:	2785                	addiw	a5,a5,1
ffffffffc0204fda:	d81c                	sw	a5,48(s0)
ffffffffc0204fdc:	c531                	beqz	a0,ffffffffc0205028 <file_fstat+0x94>
ffffffffc0204fde:	793c                	ld	a5,112(a0)
ffffffffc0204fe0:	c7a1                	beqz	a5,ffffffffc0205028 <file_fstat+0x94>
ffffffffc0204fe2:	779c                	ld	a5,40(a5)
ffffffffc0204fe4:	c3b1                	beqz	a5,ffffffffc0205028 <file_fstat+0x94>
ffffffffc0204fe6:	00008597          	auipc	a1,0x8
ffffffffc0204fea:	43258593          	addi	a1,a1,1074 # ffffffffc020d418 <etext+0x1bb8>
ffffffffc0204fee:	e42a                	sd	a0,8(sp)
ffffffffc0204ff0:	2b9020ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc0204ff4:	6522                	ld	a0,8(sp)
ffffffffc0204ff6:	85a6                	mv	a1,s1
ffffffffc0204ff8:	793c                	ld	a5,112(a0)
ffffffffc0204ffa:	7408                	ld	a0,40(s0)
ffffffffc0204ffc:	779c                	ld	a5,40(a5)
ffffffffc0204ffe:	9782                	jalr	a5
ffffffffc0205000:	87aa                	mv	a5,a0
ffffffffc0205002:	8522                	mv	a0,s0
ffffffffc0205004:	843e                	mv	s0,a5
ffffffffc0205006:	92dff0ef          	jal	ffffffffc0204932 <fd_array_release>
ffffffffc020500a:	64e2                	ld	s1,24(sp)
ffffffffc020500c:	70a2                	ld	ra,40(sp)
ffffffffc020500e:	8522                	mv	a0,s0
ffffffffc0205010:	7402                	ld	s0,32(sp)
ffffffffc0205012:	6145                	addi	sp,sp,48
ffffffffc0205014:	8082                	ret
ffffffffc0205016:	5475                	li	s0,-3
ffffffffc0205018:	70a2                	ld	ra,40(sp)
ffffffffc020501a:	8522                	mv	a0,s0
ffffffffc020501c:	7402                	ld	s0,32(sp)
ffffffffc020501e:	64e2                	ld	s1,24(sp)
ffffffffc0205020:	6145                	addi	sp,sp,48
ffffffffc0205022:	8082                	ret
ffffffffc0205024:	5475                	li	s0,-3
ffffffffc0205026:	b7dd                	j	ffffffffc020500c <file_fstat+0x78>
ffffffffc0205028:	00008697          	auipc	a3,0x8
ffffffffc020502c:	3a068693          	addi	a3,a3,928 # ffffffffc020d3c8 <etext+0x1b68>
ffffffffc0205030:	00007617          	auipc	a2,0x7
ffffffffc0205034:	c6860613          	addi	a2,a2,-920 # ffffffffc020bc98 <etext+0x438>
ffffffffc0205038:	12c00593          	li	a1,300
ffffffffc020503c:	00008517          	auipc	a0,0x8
ffffffffc0205040:	25450513          	addi	a0,a0,596 # ffffffffc020d290 <etext+0x1a30>
ffffffffc0205044:	c06fb0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0205048:	fbcff0ef          	jal	ffffffffc0204804 <get_fd_array.part.0>

ffffffffc020504c <file_fsync>:
ffffffffc020504c:	1101                	addi	sp,sp,-32
ffffffffc020504e:	ec06                	sd	ra,24(sp)
ffffffffc0205050:	e822                	sd	s0,16(sp)
ffffffffc0205052:	04700793          	li	a5,71
ffffffffc0205056:	06a7e863          	bltu	a5,a0,ffffffffc02050c6 <file_fsync+0x7a>
ffffffffc020505a:	00092797          	auipc	a5,0x92
ffffffffc020505e:	86e7b783          	ld	a5,-1938(a5) # ffffffffc02968c8 <current>
ffffffffc0205062:	1487b783          	ld	a5,328(a5)
ffffffffc0205066:	c7d1                	beqz	a5,ffffffffc02050f2 <file_fsync+0xa6>
ffffffffc0205068:	4b98                	lw	a4,16(a5)
ffffffffc020506a:	08e05463          	blez	a4,ffffffffc02050f2 <file_fsync+0xa6>
ffffffffc020506e:	6780                	ld	s0,8(a5)
ffffffffc0205070:	00351793          	slli	a5,a0,0x3
ffffffffc0205074:	8f89                	sub	a5,a5,a0
ffffffffc0205076:	078e                	slli	a5,a5,0x3
ffffffffc0205078:	943e                	add	s0,s0,a5
ffffffffc020507a:	4018                	lw	a4,0(s0)
ffffffffc020507c:	4789                	li	a5,2
ffffffffc020507e:	04f71463          	bne	a4,a5,ffffffffc02050c6 <file_fsync+0x7a>
ffffffffc0205082:	4c1c                	lw	a5,24(s0)
ffffffffc0205084:	04a79163          	bne	a5,a0,ffffffffc02050c6 <file_fsync+0x7a>
ffffffffc0205088:	581c                	lw	a5,48(s0)
ffffffffc020508a:	7408                	ld	a0,40(s0)
ffffffffc020508c:	2785                	addiw	a5,a5,1
ffffffffc020508e:	d81c                	sw	a5,48(s0)
ffffffffc0205090:	c129                	beqz	a0,ffffffffc02050d2 <file_fsync+0x86>
ffffffffc0205092:	793c                	ld	a5,112(a0)
ffffffffc0205094:	cf9d                	beqz	a5,ffffffffc02050d2 <file_fsync+0x86>
ffffffffc0205096:	7b9c                	ld	a5,48(a5)
ffffffffc0205098:	cf8d                	beqz	a5,ffffffffc02050d2 <file_fsync+0x86>
ffffffffc020509a:	00008597          	auipc	a1,0x8
ffffffffc020509e:	4de58593          	addi	a1,a1,1246 # ffffffffc020d578 <etext+0x1d18>
ffffffffc02050a2:	e42a                	sd	a0,8(sp)
ffffffffc02050a4:	205020ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc02050a8:	6522                	ld	a0,8(sp)
ffffffffc02050aa:	793c                	ld	a5,112(a0)
ffffffffc02050ac:	7408                	ld	a0,40(s0)
ffffffffc02050ae:	7b9c                	ld	a5,48(a5)
ffffffffc02050b0:	9782                	jalr	a5
ffffffffc02050b2:	87aa                	mv	a5,a0
ffffffffc02050b4:	8522                	mv	a0,s0
ffffffffc02050b6:	843e                	mv	s0,a5
ffffffffc02050b8:	87bff0ef          	jal	ffffffffc0204932 <fd_array_release>
ffffffffc02050bc:	60e2                	ld	ra,24(sp)
ffffffffc02050be:	8522                	mv	a0,s0
ffffffffc02050c0:	6442                	ld	s0,16(sp)
ffffffffc02050c2:	6105                	addi	sp,sp,32
ffffffffc02050c4:	8082                	ret
ffffffffc02050c6:	5475                	li	s0,-3
ffffffffc02050c8:	60e2                	ld	ra,24(sp)
ffffffffc02050ca:	8522                	mv	a0,s0
ffffffffc02050cc:	6442                	ld	s0,16(sp)
ffffffffc02050ce:	6105                	addi	sp,sp,32
ffffffffc02050d0:	8082                	ret
ffffffffc02050d2:	00008697          	auipc	a3,0x8
ffffffffc02050d6:	45668693          	addi	a3,a3,1110 # ffffffffc020d528 <etext+0x1cc8>
ffffffffc02050da:	00007617          	auipc	a2,0x7
ffffffffc02050de:	bbe60613          	addi	a2,a2,-1090 # ffffffffc020bc98 <etext+0x438>
ffffffffc02050e2:	13a00593          	li	a1,314
ffffffffc02050e6:	00008517          	auipc	a0,0x8
ffffffffc02050ea:	1aa50513          	addi	a0,a0,426 # ffffffffc020d290 <etext+0x1a30>
ffffffffc02050ee:	b5cfb0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02050f2:	f12ff0ef          	jal	ffffffffc0204804 <get_fd_array.part.0>

ffffffffc02050f6 <file_getdirentry>:
ffffffffc02050f6:	715d                	addi	sp,sp,-80
ffffffffc02050f8:	e486                	sd	ra,72(sp)
ffffffffc02050fa:	f84a                	sd	s2,48(sp)
ffffffffc02050fc:	04700793          	li	a5,71
ffffffffc0205100:	0aa7e963          	bltu	a5,a0,ffffffffc02051b2 <file_getdirentry+0xbc>
ffffffffc0205104:	00091797          	auipc	a5,0x91
ffffffffc0205108:	7c47b783          	ld	a5,1988(a5) # ffffffffc02968c8 <current>
ffffffffc020510c:	fc26                	sd	s1,56(sp)
ffffffffc020510e:	e0a2                	sd	s0,64(sp)
ffffffffc0205110:	1487b783          	ld	a5,328(a5)
ffffffffc0205114:	84ae                	mv	s1,a1
ffffffffc0205116:	c7e1                	beqz	a5,ffffffffc02051de <file_getdirentry+0xe8>
ffffffffc0205118:	4b98                	lw	a4,16(a5)
ffffffffc020511a:	0ce05263          	blez	a4,ffffffffc02051de <file_getdirentry+0xe8>
ffffffffc020511e:	6780                	ld	s0,8(a5)
ffffffffc0205120:	00351793          	slli	a5,a0,0x3
ffffffffc0205124:	8f89                	sub	a5,a5,a0
ffffffffc0205126:	078e                	slli	a5,a5,0x3
ffffffffc0205128:	943e                	add	s0,s0,a5
ffffffffc020512a:	4018                	lw	a4,0(s0)
ffffffffc020512c:	4789                	li	a5,2
ffffffffc020512e:	08f71463          	bne	a4,a5,ffffffffc02051b6 <file_getdirentry+0xc0>
ffffffffc0205132:	4c1c                	lw	a5,24(s0)
ffffffffc0205134:	f44e                	sd	s3,40(sp)
ffffffffc0205136:	06a79963          	bne	a5,a0,ffffffffc02051a8 <file_getdirentry+0xb2>
ffffffffc020513a:	581c                	lw	a5,48(s0)
ffffffffc020513c:	6194                	ld	a3,0(a1)
ffffffffc020513e:	10000613          	li	a2,256
ffffffffc0205142:	2785                	addiw	a5,a5,1
ffffffffc0205144:	d81c                	sw	a5,48(s0)
ffffffffc0205146:	05a1                	addi	a1,a1,8
ffffffffc0205148:	850a                	mv	a0,sp
ffffffffc020514a:	342000ef          	jal	ffffffffc020548c <iobuf_init>
ffffffffc020514e:	02843903          	ld	s2,40(s0)
ffffffffc0205152:	89aa                	mv	s3,a0
ffffffffc0205154:	06090563          	beqz	s2,ffffffffc02051be <file_getdirentry+0xc8>
ffffffffc0205158:	07093783          	ld	a5,112(s2)
ffffffffc020515c:	c3ad                	beqz	a5,ffffffffc02051be <file_getdirentry+0xc8>
ffffffffc020515e:	63bc                	ld	a5,64(a5)
ffffffffc0205160:	cfb9                	beqz	a5,ffffffffc02051be <file_getdirentry+0xc8>
ffffffffc0205162:	854a                	mv	a0,s2
ffffffffc0205164:	00008597          	auipc	a1,0x8
ffffffffc0205168:	47458593          	addi	a1,a1,1140 # ffffffffc020d5d8 <etext+0x1d78>
ffffffffc020516c:	13d020ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc0205170:	07093783          	ld	a5,112(s2)
ffffffffc0205174:	7408                	ld	a0,40(s0)
ffffffffc0205176:	85ce                	mv	a1,s3
ffffffffc0205178:	63bc                	ld	a5,64(a5)
ffffffffc020517a:	9782                	jalr	a5
ffffffffc020517c:	892a                	mv	s2,a0
ffffffffc020517e:	cd01                	beqz	a0,ffffffffc0205196 <file_getdirentry+0xa0>
ffffffffc0205180:	8522                	mv	a0,s0
ffffffffc0205182:	fb0ff0ef          	jal	ffffffffc0204932 <fd_array_release>
ffffffffc0205186:	6406                	ld	s0,64(sp)
ffffffffc0205188:	74e2                	ld	s1,56(sp)
ffffffffc020518a:	79a2                	ld	s3,40(sp)
ffffffffc020518c:	60a6                	ld	ra,72(sp)
ffffffffc020518e:	854a                	mv	a0,s2
ffffffffc0205190:	7942                	ld	s2,48(sp)
ffffffffc0205192:	6161                	addi	sp,sp,80
ffffffffc0205194:	8082                	ret
ffffffffc0205196:	609c                	ld	a5,0(s1)
ffffffffc0205198:	0109b683          	ld	a3,16(s3)
ffffffffc020519c:	0189b703          	ld	a4,24(s3)
ffffffffc02051a0:	97b6                	add	a5,a5,a3
ffffffffc02051a2:	8f99                	sub	a5,a5,a4
ffffffffc02051a4:	e09c                	sd	a5,0(s1)
ffffffffc02051a6:	bfe9                	j	ffffffffc0205180 <file_getdirentry+0x8a>
ffffffffc02051a8:	6406                	ld	s0,64(sp)
ffffffffc02051aa:	74e2                	ld	s1,56(sp)
ffffffffc02051ac:	79a2                	ld	s3,40(sp)
ffffffffc02051ae:	5975                	li	s2,-3
ffffffffc02051b0:	bff1                	j	ffffffffc020518c <file_getdirentry+0x96>
ffffffffc02051b2:	5975                	li	s2,-3
ffffffffc02051b4:	bfe1                	j	ffffffffc020518c <file_getdirentry+0x96>
ffffffffc02051b6:	6406                	ld	s0,64(sp)
ffffffffc02051b8:	74e2                	ld	s1,56(sp)
ffffffffc02051ba:	5975                	li	s2,-3
ffffffffc02051bc:	bfc1                	j	ffffffffc020518c <file_getdirentry+0x96>
ffffffffc02051be:	00008697          	auipc	a3,0x8
ffffffffc02051c2:	3c268693          	addi	a3,a3,962 # ffffffffc020d580 <etext+0x1d20>
ffffffffc02051c6:	00007617          	auipc	a2,0x7
ffffffffc02051ca:	ad260613          	addi	a2,a2,-1326 # ffffffffc020bc98 <etext+0x438>
ffffffffc02051ce:	14a00593          	li	a1,330
ffffffffc02051d2:	00008517          	auipc	a0,0x8
ffffffffc02051d6:	0be50513          	addi	a0,a0,190 # ffffffffc020d290 <etext+0x1a30>
ffffffffc02051da:	a70fb0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02051de:	f44e                	sd	s3,40(sp)
ffffffffc02051e0:	e24ff0ef          	jal	ffffffffc0204804 <get_fd_array.part.0>

ffffffffc02051e4 <file_dup>:
ffffffffc02051e4:	04700713          	li	a4,71
ffffffffc02051e8:	06a76263          	bltu	a4,a0,ffffffffc020524c <file_dup+0x68>
ffffffffc02051ec:	00091717          	auipc	a4,0x91
ffffffffc02051f0:	6dc73703          	ld	a4,1756(a4) # ffffffffc02968c8 <current>
ffffffffc02051f4:	7179                	addi	sp,sp,-48
ffffffffc02051f6:	f406                	sd	ra,40(sp)
ffffffffc02051f8:	14873703          	ld	a4,328(a4)
ffffffffc02051fc:	f022                	sd	s0,32(sp)
ffffffffc02051fe:	87aa                	mv	a5,a0
ffffffffc0205200:	852e                	mv	a0,a1
ffffffffc0205202:	c739                	beqz	a4,ffffffffc0205250 <file_dup+0x6c>
ffffffffc0205204:	4b14                	lw	a3,16(a4)
ffffffffc0205206:	04d05563          	blez	a3,ffffffffc0205250 <file_dup+0x6c>
ffffffffc020520a:	6700                	ld	s0,8(a4)
ffffffffc020520c:	00379713          	slli	a4,a5,0x3
ffffffffc0205210:	8f1d                	sub	a4,a4,a5
ffffffffc0205212:	070e                	slli	a4,a4,0x3
ffffffffc0205214:	943a                	add	s0,s0,a4
ffffffffc0205216:	4014                	lw	a3,0(s0)
ffffffffc0205218:	4709                	li	a4,2
ffffffffc020521a:	02e69463          	bne	a3,a4,ffffffffc0205242 <file_dup+0x5e>
ffffffffc020521e:	4c18                	lw	a4,24(s0)
ffffffffc0205220:	02f71163          	bne	a4,a5,ffffffffc0205242 <file_dup+0x5e>
ffffffffc0205224:	082c                	addi	a1,sp,24
ffffffffc0205226:	e00ff0ef          	jal	ffffffffc0204826 <fd_array_alloc>
ffffffffc020522a:	e901                	bnez	a0,ffffffffc020523a <file_dup+0x56>
ffffffffc020522c:	6562                	ld	a0,24(sp)
ffffffffc020522e:	85a2                	mv	a1,s0
ffffffffc0205230:	e42a                	sd	a0,8(sp)
ffffffffc0205232:	821ff0ef          	jal	ffffffffc0204a52 <fd_array_dup>
ffffffffc0205236:	6522                	ld	a0,8(sp)
ffffffffc0205238:	4d08                	lw	a0,24(a0)
ffffffffc020523a:	70a2                	ld	ra,40(sp)
ffffffffc020523c:	7402                	ld	s0,32(sp)
ffffffffc020523e:	6145                	addi	sp,sp,48
ffffffffc0205240:	8082                	ret
ffffffffc0205242:	70a2                	ld	ra,40(sp)
ffffffffc0205244:	7402                	ld	s0,32(sp)
ffffffffc0205246:	5575                	li	a0,-3
ffffffffc0205248:	6145                	addi	sp,sp,48
ffffffffc020524a:	8082                	ret
ffffffffc020524c:	5575                	li	a0,-3
ffffffffc020524e:	8082                	ret
ffffffffc0205250:	db4ff0ef          	jal	ffffffffc0204804 <get_fd_array.part.0>

ffffffffc0205254 <fs_init>:
ffffffffc0205254:	1141                	addi	sp,sp,-16
ffffffffc0205256:	e406                	sd	ra,8(sp)
ffffffffc0205258:	25b020ef          	jal	ffffffffc0207cb2 <vfs_init>
ffffffffc020525c:	768030ef          	jal	ffffffffc02089c4 <dev_init>
ffffffffc0205260:	60a2                	ld	ra,8(sp)
ffffffffc0205262:	0141                	addi	sp,sp,16
ffffffffc0205264:	0dc0406f          	j	ffffffffc0209340 <sfs_init>

ffffffffc0205268 <fs_cleanup>:
ffffffffc0205268:	4c70206f          	j	ffffffffc0207f2e <vfs_cleanup>

ffffffffc020526c <lock_files>:
ffffffffc020526c:	0561                	addi	a0,a0,24
ffffffffc020526e:	b88ff06f          	j	ffffffffc02045f6 <down>

ffffffffc0205272 <unlock_files>:
ffffffffc0205272:	0561                	addi	a0,a0,24
ffffffffc0205274:	b7eff06f          	j	ffffffffc02045f2 <up>

ffffffffc0205278 <files_create>:
ffffffffc0205278:	1141                	addi	sp,sp,-16
ffffffffc020527a:	6505                	lui	a0,0x1
ffffffffc020527c:	e022                	sd	s0,0(sp)
ffffffffc020527e:	e406                	sd	ra,8(sp)
ffffffffc0205280:	d41fc0ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc0205284:	842a                	mv	s0,a0
ffffffffc0205286:	cd19                	beqz	a0,ffffffffc02052a4 <files_create+0x2c>
ffffffffc0205288:	03050793          	addi	a5,a0,48 # 1030 <_binary_bin_swap_img_size-0x6cd0>
ffffffffc020528c:	e51c                	sd	a5,8(a0)
ffffffffc020528e:	00053023          	sd	zero,0(a0)
ffffffffc0205292:	00052823          	sw	zero,16(a0)
ffffffffc0205296:	4585                	li	a1,1
ffffffffc0205298:	0561                	addi	a0,a0,24
ffffffffc020529a:	b52ff0ef          	jal	ffffffffc02045ec <sem_init>
ffffffffc020529e:	6408                	ld	a0,8(s0)
ffffffffc02052a0:	f1eff0ef          	jal	ffffffffc02049be <fd_array_init>
ffffffffc02052a4:	60a2                	ld	ra,8(sp)
ffffffffc02052a6:	8522                	mv	a0,s0
ffffffffc02052a8:	6402                	ld	s0,0(sp)
ffffffffc02052aa:	0141                	addi	sp,sp,16
ffffffffc02052ac:	8082                	ret

ffffffffc02052ae <files_destroy>:
ffffffffc02052ae:	7179                	addi	sp,sp,-48
ffffffffc02052b0:	f406                	sd	ra,40(sp)
ffffffffc02052b2:	f022                	sd	s0,32(sp)
ffffffffc02052b4:	ec26                	sd	s1,24(sp)
ffffffffc02052b6:	e84a                	sd	s2,16(sp)
ffffffffc02052b8:	e44e                	sd	s3,8(sp)
ffffffffc02052ba:	c52d                	beqz	a0,ffffffffc0205324 <files_destroy+0x76>
ffffffffc02052bc:	491c                	lw	a5,16(a0)
ffffffffc02052be:	89aa                	mv	s3,a0
ffffffffc02052c0:	e3b5                	bnez	a5,ffffffffc0205324 <files_destroy+0x76>
ffffffffc02052c2:	6108                	ld	a0,0(a0)
ffffffffc02052c4:	c119                	beqz	a0,ffffffffc02052ca <files_destroy+0x1c>
ffffffffc02052c6:	09d020ef          	jal	ffffffffc0207b62 <inode_ref_dec>
ffffffffc02052ca:	0089b403          	ld	s0,8(s3)
ffffffffc02052ce:	4909                	li	s2,2
ffffffffc02052d0:	7ff40493          	addi	s1,s0,2047
ffffffffc02052d4:	7c148493          	addi	s1,s1,1985
ffffffffc02052d8:	401c                	lw	a5,0(s0)
ffffffffc02052da:	03278063          	beq	a5,s2,ffffffffc02052fa <files_destroy+0x4c>
ffffffffc02052de:	e39d                	bnez	a5,ffffffffc0205304 <files_destroy+0x56>
ffffffffc02052e0:	03840413          	addi	s0,s0,56
ffffffffc02052e4:	fe941ae3          	bne	s0,s1,ffffffffc02052d8 <files_destroy+0x2a>
ffffffffc02052e8:	7402                	ld	s0,32(sp)
ffffffffc02052ea:	70a2                	ld	ra,40(sp)
ffffffffc02052ec:	64e2                	ld	s1,24(sp)
ffffffffc02052ee:	6942                	ld	s2,16(sp)
ffffffffc02052f0:	854e                	mv	a0,s3
ffffffffc02052f2:	69a2                	ld	s3,8(sp)
ffffffffc02052f4:	6145                	addi	sp,sp,48
ffffffffc02052f6:	d71fc06f          	j	ffffffffc0202066 <kfree>
ffffffffc02052fa:	8522                	mv	a0,s0
ffffffffc02052fc:	edeff0ef          	jal	ffffffffc02049da <fd_array_close>
ffffffffc0205300:	401c                	lw	a5,0(s0)
ffffffffc0205302:	bff1                	j	ffffffffc02052de <files_destroy+0x30>
ffffffffc0205304:	00008697          	auipc	a3,0x8
ffffffffc0205308:	32468693          	addi	a3,a3,804 # ffffffffc020d628 <etext+0x1dc8>
ffffffffc020530c:	00007617          	auipc	a2,0x7
ffffffffc0205310:	98c60613          	addi	a2,a2,-1652 # ffffffffc020bc98 <etext+0x438>
ffffffffc0205314:	03d00593          	li	a1,61
ffffffffc0205318:	00008517          	auipc	a0,0x8
ffffffffc020531c:	30050513          	addi	a0,a0,768 # ffffffffc020d618 <etext+0x1db8>
ffffffffc0205320:	92afb0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0205324:	00008697          	auipc	a3,0x8
ffffffffc0205328:	2c468693          	addi	a3,a3,708 # ffffffffc020d5e8 <etext+0x1d88>
ffffffffc020532c:	00007617          	auipc	a2,0x7
ffffffffc0205330:	96c60613          	addi	a2,a2,-1684 # ffffffffc020bc98 <etext+0x438>
ffffffffc0205334:	03300593          	li	a1,51
ffffffffc0205338:	00008517          	auipc	a0,0x8
ffffffffc020533c:	2e050513          	addi	a0,a0,736 # ffffffffc020d618 <etext+0x1db8>
ffffffffc0205340:	90afb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0205344 <files_closeall>:
ffffffffc0205344:	1101                	addi	sp,sp,-32
ffffffffc0205346:	ec06                	sd	ra,24(sp)
ffffffffc0205348:	e822                	sd	s0,16(sp)
ffffffffc020534a:	e426                	sd	s1,8(sp)
ffffffffc020534c:	e04a                	sd	s2,0(sp)
ffffffffc020534e:	c129                	beqz	a0,ffffffffc0205390 <files_closeall+0x4c>
ffffffffc0205350:	491c                	lw	a5,16(a0)
ffffffffc0205352:	02f05f63          	blez	a5,ffffffffc0205390 <files_closeall+0x4c>
ffffffffc0205356:	6500                	ld	s0,8(a0)
ffffffffc0205358:	4909                	li	s2,2
ffffffffc020535a:	7ff40493          	addi	s1,s0,2047
ffffffffc020535e:	7c148493          	addi	s1,s1,1985
ffffffffc0205362:	07040413          	addi	s0,s0,112
ffffffffc0205366:	a029                	j	ffffffffc0205370 <files_closeall+0x2c>
ffffffffc0205368:	03840413          	addi	s0,s0,56
ffffffffc020536c:	00940c63          	beq	s0,s1,ffffffffc0205384 <files_closeall+0x40>
ffffffffc0205370:	401c                	lw	a5,0(s0)
ffffffffc0205372:	ff279be3          	bne	a5,s2,ffffffffc0205368 <files_closeall+0x24>
ffffffffc0205376:	8522                	mv	a0,s0
ffffffffc0205378:	03840413          	addi	s0,s0,56
ffffffffc020537c:	e5eff0ef          	jal	ffffffffc02049da <fd_array_close>
ffffffffc0205380:	fe9418e3          	bne	s0,s1,ffffffffc0205370 <files_closeall+0x2c>
ffffffffc0205384:	60e2                	ld	ra,24(sp)
ffffffffc0205386:	6442                	ld	s0,16(sp)
ffffffffc0205388:	64a2                	ld	s1,8(sp)
ffffffffc020538a:	6902                	ld	s2,0(sp)
ffffffffc020538c:	6105                	addi	sp,sp,32
ffffffffc020538e:	8082                	ret
ffffffffc0205390:	00008697          	auipc	a3,0x8
ffffffffc0205394:	ed068693          	addi	a3,a3,-304 # ffffffffc020d260 <etext+0x1a00>
ffffffffc0205398:	00007617          	auipc	a2,0x7
ffffffffc020539c:	90060613          	addi	a2,a2,-1792 # ffffffffc020bc98 <etext+0x438>
ffffffffc02053a0:	04500593          	li	a1,69
ffffffffc02053a4:	00008517          	auipc	a0,0x8
ffffffffc02053a8:	27450513          	addi	a0,a0,628 # ffffffffc020d618 <etext+0x1db8>
ffffffffc02053ac:	89efb0ef          	jal	ffffffffc020044a <__panic>

ffffffffc02053b0 <dup_files>:
ffffffffc02053b0:	7179                	addi	sp,sp,-48
ffffffffc02053b2:	f406                	sd	ra,40(sp)
ffffffffc02053b4:	f022                	sd	s0,32(sp)
ffffffffc02053b6:	ec26                	sd	s1,24(sp)
ffffffffc02053b8:	e84a                	sd	s2,16(sp)
ffffffffc02053ba:	e44e                	sd	s3,8(sp)
ffffffffc02053bc:	e052                	sd	s4,0(sp)
ffffffffc02053be:	c52d                	beqz	a0,ffffffffc0205428 <dup_files+0x78>
ffffffffc02053c0:	842e                	mv	s0,a1
ffffffffc02053c2:	c1bd                	beqz	a1,ffffffffc0205428 <dup_files+0x78>
ffffffffc02053c4:	491c                	lw	a5,16(a0)
ffffffffc02053c6:	84aa                	mv	s1,a0
ffffffffc02053c8:	e3c1                	bnez	a5,ffffffffc0205448 <dup_files+0x98>
ffffffffc02053ca:	499c                	lw	a5,16(a1)
ffffffffc02053cc:	06f05e63          	blez	a5,ffffffffc0205448 <dup_files+0x98>
ffffffffc02053d0:	6188                	ld	a0,0(a1)
ffffffffc02053d2:	e088                	sd	a0,0(s1)
ffffffffc02053d4:	c119                	beqz	a0,ffffffffc02053da <dup_files+0x2a>
ffffffffc02053d6:	6be020ef          	jal	ffffffffc0207a94 <inode_ref_inc>
ffffffffc02053da:	6400                	ld	s0,8(s0)
ffffffffc02053dc:	6484                	ld	s1,8(s1)
ffffffffc02053de:	4989                	li	s3,2
ffffffffc02053e0:	7ff40913          	addi	s2,s0,2047
ffffffffc02053e4:	7c190913          	addi	s2,s2,1985
ffffffffc02053e8:	4a05                	li	s4,1
ffffffffc02053ea:	a039                	j	ffffffffc02053f8 <dup_files+0x48>
ffffffffc02053ec:	03840413          	addi	s0,s0,56
ffffffffc02053f0:	03848493          	addi	s1,s1,56
ffffffffc02053f4:	03240163          	beq	s0,s2,ffffffffc0205416 <dup_files+0x66>
ffffffffc02053f8:	401c                	lw	a5,0(s0)
ffffffffc02053fa:	ff3799e3          	bne	a5,s3,ffffffffc02053ec <dup_files+0x3c>
ffffffffc02053fe:	0144a023          	sw	s4,0(s1)
ffffffffc0205402:	85a2                	mv	a1,s0
ffffffffc0205404:	8526                	mv	a0,s1
ffffffffc0205406:	03840413          	addi	s0,s0,56
ffffffffc020540a:	e48ff0ef          	jal	ffffffffc0204a52 <fd_array_dup>
ffffffffc020540e:	03848493          	addi	s1,s1,56
ffffffffc0205412:	ff2413e3          	bne	s0,s2,ffffffffc02053f8 <dup_files+0x48>
ffffffffc0205416:	70a2                	ld	ra,40(sp)
ffffffffc0205418:	7402                	ld	s0,32(sp)
ffffffffc020541a:	64e2                	ld	s1,24(sp)
ffffffffc020541c:	6942                	ld	s2,16(sp)
ffffffffc020541e:	69a2                	ld	s3,8(sp)
ffffffffc0205420:	6a02                	ld	s4,0(sp)
ffffffffc0205422:	4501                	li	a0,0
ffffffffc0205424:	6145                	addi	sp,sp,48
ffffffffc0205426:	8082                	ret
ffffffffc0205428:	00008697          	auipc	a3,0x8
ffffffffc020542c:	b8868693          	addi	a3,a3,-1144 # ffffffffc020cfb0 <etext+0x1750>
ffffffffc0205430:	00007617          	auipc	a2,0x7
ffffffffc0205434:	86860613          	addi	a2,a2,-1944 # ffffffffc020bc98 <etext+0x438>
ffffffffc0205438:	05300593          	li	a1,83
ffffffffc020543c:	00008517          	auipc	a0,0x8
ffffffffc0205440:	1dc50513          	addi	a0,a0,476 # ffffffffc020d618 <etext+0x1db8>
ffffffffc0205444:	806fb0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0205448:	00008697          	auipc	a3,0x8
ffffffffc020544c:	1f868693          	addi	a3,a3,504 # ffffffffc020d640 <etext+0x1de0>
ffffffffc0205450:	00007617          	auipc	a2,0x7
ffffffffc0205454:	84860613          	addi	a2,a2,-1976 # ffffffffc020bc98 <etext+0x438>
ffffffffc0205458:	05400593          	li	a1,84
ffffffffc020545c:	00008517          	auipc	a0,0x8
ffffffffc0205460:	1bc50513          	addi	a0,a0,444 # ffffffffc020d618 <etext+0x1db8>
ffffffffc0205464:	fe7fa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0205468 <iobuf_skip.part.0>:
ffffffffc0205468:	1141                	addi	sp,sp,-16
ffffffffc020546a:	00008697          	auipc	a3,0x8
ffffffffc020546e:	20668693          	addi	a3,a3,518 # ffffffffc020d670 <etext+0x1e10>
ffffffffc0205472:	00007617          	auipc	a2,0x7
ffffffffc0205476:	82660613          	addi	a2,a2,-2010 # ffffffffc020bc98 <etext+0x438>
ffffffffc020547a:	04a00593          	li	a1,74
ffffffffc020547e:	00008517          	auipc	a0,0x8
ffffffffc0205482:	20a50513          	addi	a0,a0,522 # ffffffffc020d688 <etext+0x1e28>
ffffffffc0205486:	e406                	sd	ra,8(sp)
ffffffffc0205488:	fc3fa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020548c <iobuf_init>:
ffffffffc020548c:	e10c                	sd	a1,0(a0)
ffffffffc020548e:	e514                	sd	a3,8(a0)
ffffffffc0205490:	ed10                	sd	a2,24(a0)
ffffffffc0205492:	e910                	sd	a2,16(a0)
ffffffffc0205494:	8082                	ret

ffffffffc0205496 <iobuf_move>:
ffffffffc0205496:	6d1c                	ld	a5,24(a0)
ffffffffc0205498:	88aa                	mv	a7,a0
ffffffffc020549a:	8832                	mv	a6,a2
ffffffffc020549c:	00f67363          	bgeu	a2,a5,ffffffffc02054a2 <iobuf_move+0xc>
ffffffffc02054a0:	87b2                	mv	a5,a2
ffffffffc02054a2:	cfa1                	beqz	a5,ffffffffc02054fa <iobuf_move+0x64>
ffffffffc02054a4:	7179                	addi	sp,sp,-48
ffffffffc02054a6:	f406                	sd	ra,40(sp)
ffffffffc02054a8:	0008b503          	ld	a0,0(a7)
ffffffffc02054ac:	cea9                	beqz	a3,ffffffffc0205506 <iobuf_move+0x70>
ffffffffc02054ae:	863e                	mv	a2,a5
ffffffffc02054b0:	ec3a                	sd	a4,24(sp)
ffffffffc02054b2:	e846                	sd	a7,16(sp)
ffffffffc02054b4:	e442                	sd	a6,8(sp)
ffffffffc02054b6:	e03e                	sd	a5,0(sp)
ffffffffc02054b8:	352060ef          	jal	ffffffffc020b80a <memmove>
ffffffffc02054bc:	68c2                	ld	a7,16(sp)
ffffffffc02054be:	6782                	ld	a5,0(sp)
ffffffffc02054c0:	6822                	ld	a6,8(sp)
ffffffffc02054c2:	0188b683          	ld	a3,24(a7)
ffffffffc02054c6:	6762                	ld	a4,24(sp)
ffffffffc02054c8:	04f6e763          	bltu	a3,a5,ffffffffc0205516 <iobuf_move+0x80>
ffffffffc02054cc:	0008b583          	ld	a1,0(a7)
ffffffffc02054d0:	0088b603          	ld	a2,8(a7)
ffffffffc02054d4:	8e9d                	sub	a3,a3,a5
ffffffffc02054d6:	95be                	add	a1,a1,a5
ffffffffc02054d8:	963e                	add	a2,a2,a5
ffffffffc02054da:	00d8bc23          	sd	a3,24(a7)
ffffffffc02054de:	00b8b023          	sd	a1,0(a7)
ffffffffc02054e2:	00c8b423          	sd	a2,8(a7)
ffffffffc02054e6:	40f80833          	sub	a6,a6,a5
ffffffffc02054ea:	c311                	beqz	a4,ffffffffc02054ee <iobuf_move+0x58>
ffffffffc02054ec:	e31c                	sd	a5,0(a4)
ffffffffc02054ee:	02081263          	bnez	a6,ffffffffc0205512 <iobuf_move+0x7c>
ffffffffc02054f2:	4501                	li	a0,0
ffffffffc02054f4:	70a2                	ld	ra,40(sp)
ffffffffc02054f6:	6145                	addi	sp,sp,48
ffffffffc02054f8:	8082                	ret
ffffffffc02054fa:	c311                	beqz	a4,ffffffffc02054fe <iobuf_move+0x68>
ffffffffc02054fc:	e31c                	sd	a5,0(a4)
ffffffffc02054fe:	00081863          	bnez	a6,ffffffffc020550e <iobuf_move+0x78>
ffffffffc0205502:	4501                	li	a0,0
ffffffffc0205504:	8082                	ret
ffffffffc0205506:	86ae                	mv	a3,a1
ffffffffc0205508:	85aa                	mv	a1,a0
ffffffffc020550a:	8536                	mv	a0,a3
ffffffffc020550c:	b74d                	j	ffffffffc02054ae <iobuf_move+0x18>
ffffffffc020550e:	5571                	li	a0,-4
ffffffffc0205510:	8082                	ret
ffffffffc0205512:	5571                	li	a0,-4
ffffffffc0205514:	b7c5                	j	ffffffffc02054f4 <iobuf_move+0x5e>
ffffffffc0205516:	f53ff0ef          	jal	ffffffffc0205468 <iobuf_skip.part.0>

ffffffffc020551a <iobuf_skip>:
ffffffffc020551a:	6d1c                	ld	a5,24(a0)
ffffffffc020551c:	00b7eb63          	bltu	a5,a1,ffffffffc0205532 <iobuf_skip+0x18>
ffffffffc0205520:	6114                	ld	a3,0(a0)
ffffffffc0205522:	6518                	ld	a4,8(a0)
ffffffffc0205524:	8f8d                	sub	a5,a5,a1
ffffffffc0205526:	96ae                	add	a3,a3,a1
ffffffffc0205528:	972e                	add	a4,a4,a1
ffffffffc020552a:	ed1c                	sd	a5,24(a0)
ffffffffc020552c:	e114                	sd	a3,0(a0)
ffffffffc020552e:	e518                	sd	a4,8(a0)
ffffffffc0205530:	8082                	ret
ffffffffc0205532:	1141                	addi	sp,sp,-16
ffffffffc0205534:	e406                	sd	ra,8(sp)
ffffffffc0205536:	f33ff0ef          	jal	ffffffffc0205468 <iobuf_skip.part.0>

ffffffffc020553a <copy_path>:
ffffffffc020553a:	7139                	addi	sp,sp,-64
ffffffffc020553c:	f04a                	sd	s2,32(sp)
ffffffffc020553e:	00091917          	auipc	s2,0x91
ffffffffc0205542:	38a90913          	addi	s2,s2,906 # ffffffffc02968c8 <current>
ffffffffc0205546:	00093783          	ld	a5,0(s2)
ffffffffc020554a:	e852                	sd	s4,16(sp)
ffffffffc020554c:	8a2a                	mv	s4,a0
ffffffffc020554e:	6505                	lui	a0,0x1
ffffffffc0205550:	f426                	sd	s1,40(sp)
ffffffffc0205552:	ec4e                	sd	s3,24(sp)
ffffffffc0205554:	fc06                	sd	ra,56(sp)
ffffffffc0205556:	7784                	ld	s1,40(a5)
ffffffffc0205558:	89ae                	mv	s3,a1
ffffffffc020555a:	a67fc0ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc020555e:	c92d                	beqz	a0,ffffffffc02055d0 <copy_path+0x96>
ffffffffc0205560:	f822                	sd	s0,48(sp)
ffffffffc0205562:	842a                	mv	s0,a0
ffffffffc0205564:	c0b1                	beqz	s1,ffffffffc02055a8 <copy_path+0x6e>
ffffffffc0205566:	03848513          	addi	a0,s1,56
ffffffffc020556a:	88cff0ef          	jal	ffffffffc02045f6 <down>
ffffffffc020556e:	00093783          	ld	a5,0(s2)
ffffffffc0205572:	c399                	beqz	a5,ffffffffc0205578 <copy_path+0x3e>
ffffffffc0205574:	43dc                	lw	a5,4(a5)
ffffffffc0205576:	c8bc                	sw	a5,80(s1)
ffffffffc0205578:	864e                	mv	a2,s3
ffffffffc020557a:	6685                	lui	a3,0x1
ffffffffc020557c:	85a2                	mv	a1,s0
ffffffffc020557e:	8526                	mv	a0,s1
ffffffffc0205580:	ea9fe0ef          	jal	ffffffffc0204428 <copy_string>
ffffffffc0205584:	cd1d                	beqz	a0,ffffffffc02055c2 <copy_path+0x88>
ffffffffc0205586:	03848513          	addi	a0,s1,56
ffffffffc020558a:	868ff0ef          	jal	ffffffffc02045f2 <up>
ffffffffc020558e:	0404a823          	sw	zero,80(s1)
ffffffffc0205592:	008a3023          	sd	s0,0(s4) # 1000 <_binary_bin_swap_img_size-0x6d00>
ffffffffc0205596:	7442                	ld	s0,48(sp)
ffffffffc0205598:	4501                	li	a0,0
ffffffffc020559a:	70e2                	ld	ra,56(sp)
ffffffffc020559c:	74a2                	ld	s1,40(sp)
ffffffffc020559e:	7902                	ld	s2,32(sp)
ffffffffc02055a0:	69e2                	ld	s3,24(sp)
ffffffffc02055a2:	6a42                	ld	s4,16(sp)
ffffffffc02055a4:	6121                	addi	sp,sp,64
ffffffffc02055a6:	8082                	ret
ffffffffc02055a8:	85aa                	mv	a1,a0
ffffffffc02055aa:	864e                	mv	a2,s3
ffffffffc02055ac:	6685                	lui	a3,0x1
ffffffffc02055ae:	4501                	li	a0,0
ffffffffc02055b0:	e79fe0ef          	jal	ffffffffc0204428 <copy_string>
ffffffffc02055b4:	fd79                	bnez	a0,ffffffffc0205592 <copy_path+0x58>
ffffffffc02055b6:	8522                	mv	a0,s0
ffffffffc02055b8:	aaffc0ef          	jal	ffffffffc0202066 <kfree>
ffffffffc02055bc:	5575                	li	a0,-3
ffffffffc02055be:	7442                	ld	s0,48(sp)
ffffffffc02055c0:	bfe9                	j	ffffffffc020559a <copy_path+0x60>
ffffffffc02055c2:	03848513          	addi	a0,s1,56
ffffffffc02055c6:	82cff0ef          	jal	ffffffffc02045f2 <up>
ffffffffc02055ca:	0404a823          	sw	zero,80(s1)
ffffffffc02055ce:	b7e5                	j	ffffffffc02055b6 <copy_path+0x7c>
ffffffffc02055d0:	5571                	li	a0,-4
ffffffffc02055d2:	b7e1                	j	ffffffffc020559a <copy_path+0x60>

ffffffffc02055d4 <sysfile_open>:
ffffffffc02055d4:	7179                	addi	sp,sp,-48
ffffffffc02055d6:	f022                	sd	s0,32(sp)
ffffffffc02055d8:	842e                	mv	s0,a1
ffffffffc02055da:	85aa                	mv	a1,a0
ffffffffc02055dc:	0828                	addi	a0,sp,24
ffffffffc02055de:	f406                	sd	ra,40(sp)
ffffffffc02055e0:	f5bff0ef          	jal	ffffffffc020553a <copy_path>
ffffffffc02055e4:	87aa                	mv	a5,a0
ffffffffc02055e6:	ed09                	bnez	a0,ffffffffc0205600 <sysfile_open+0x2c>
ffffffffc02055e8:	6762                	ld	a4,24(sp)
ffffffffc02055ea:	85a2                	mv	a1,s0
ffffffffc02055ec:	853a                	mv	a0,a4
ffffffffc02055ee:	e43a                	sd	a4,8(sp)
ffffffffc02055f0:	d32ff0ef          	jal	ffffffffc0204b22 <file_open>
ffffffffc02055f4:	6722                	ld	a4,8(sp)
ffffffffc02055f6:	e42a                	sd	a0,8(sp)
ffffffffc02055f8:	853a                	mv	a0,a4
ffffffffc02055fa:	a6dfc0ef          	jal	ffffffffc0202066 <kfree>
ffffffffc02055fe:	67a2                	ld	a5,8(sp)
ffffffffc0205600:	70a2                	ld	ra,40(sp)
ffffffffc0205602:	7402                	ld	s0,32(sp)
ffffffffc0205604:	853e                	mv	a0,a5
ffffffffc0205606:	6145                	addi	sp,sp,48
ffffffffc0205608:	8082                	ret

ffffffffc020560a <sysfile_close>:
ffffffffc020560a:	e32ff06f          	j	ffffffffc0204c3c <file_close>

ffffffffc020560e <sysfile_read>:
ffffffffc020560e:	7119                	addi	sp,sp,-128
ffffffffc0205610:	f466                	sd	s9,40(sp)
ffffffffc0205612:	fc86                	sd	ra,120(sp)
ffffffffc0205614:	4c81                	li	s9,0
ffffffffc0205616:	e611                	bnez	a2,ffffffffc0205622 <sysfile_read+0x14>
ffffffffc0205618:	70e6                	ld	ra,120(sp)
ffffffffc020561a:	8566                	mv	a0,s9
ffffffffc020561c:	7ca2                	ld	s9,40(sp)
ffffffffc020561e:	6109                	addi	sp,sp,128
ffffffffc0205620:	8082                	ret
ffffffffc0205622:	f862                	sd	s8,48(sp)
ffffffffc0205624:	00091c17          	auipc	s8,0x91
ffffffffc0205628:	2a4c0c13          	addi	s8,s8,676 # ffffffffc02968c8 <current>
ffffffffc020562c:	000c3783          	ld	a5,0(s8)
ffffffffc0205630:	f8a2                	sd	s0,112(sp)
ffffffffc0205632:	f0ca                	sd	s2,96(sp)
ffffffffc0205634:	8432                	mv	s0,a2
ffffffffc0205636:	892e                	mv	s2,a1
ffffffffc0205638:	4601                	li	a2,0
ffffffffc020563a:	4585                	li	a1,1
ffffffffc020563c:	f4a6                	sd	s1,104(sp)
ffffffffc020563e:	e8d2                	sd	s4,80(sp)
ffffffffc0205640:	7784                	ld	s1,40(a5)
ffffffffc0205642:	8a2a                	mv	s4,a0
ffffffffc0205644:	c8aff0ef          	jal	ffffffffc0204ace <file_testfd>
ffffffffc0205648:	c969                	beqz	a0,ffffffffc020571a <sysfile_read+0x10c>
ffffffffc020564a:	6505                	lui	a0,0x1
ffffffffc020564c:	ecce                	sd	s3,88(sp)
ffffffffc020564e:	973fc0ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc0205652:	89aa                	mv	s3,a0
ffffffffc0205654:	c971                	beqz	a0,ffffffffc0205728 <sysfile_read+0x11a>
ffffffffc0205656:	e4d6                	sd	s5,72(sp)
ffffffffc0205658:	e0da                	sd	s6,64(sp)
ffffffffc020565a:	6a85                	lui	s5,0x1
ffffffffc020565c:	4b01                	li	s6,0
ffffffffc020565e:	09546863          	bltu	s0,s5,ffffffffc02056ee <sysfile_read+0xe0>
ffffffffc0205662:	6785                	lui	a5,0x1
ffffffffc0205664:	863e                	mv	a2,a5
ffffffffc0205666:	0834                	addi	a3,sp,24
ffffffffc0205668:	85ce                	mv	a1,s3
ffffffffc020566a:	8552                	mv	a0,s4
ffffffffc020566c:	ec3e                	sd	a5,24(sp)
ffffffffc020566e:	e26ff0ef          	jal	ffffffffc0204c94 <file_read>
ffffffffc0205672:	66e2                	ld	a3,24(sp)
ffffffffc0205674:	8caa                	mv	s9,a0
ffffffffc0205676:	e68d                	bnez	a3,ffffffffc02056a0 <sysfile_read+0x92>
ffffffffc0205678:	854e                	mv	a0,s3
ffffffffc020567a:	9edfc0ef          	jal	ffffffffc0202066 <kfree>
ffffffffc020567e:	000b0463          	beqz	s6,ffffffffc0205686 <sysfile_read+0x78>
ffffffffc0205682:	000b0c9b          	sext.w	s9,s6
ffffffffc0205686:	7446                	ld	s0,112(sp)
ffffffffc0205688:	70e6                	ld	ra,120(sp)
ffffffffc020568a:	74a6                	ld	s1,104(sp)
ffffffffc020568c:	7906                	ld	s2,96(sp)
ffffffffc020568e:	69e6                	ld	s3,88(sp)
ffffffffc0205690:	6a46                	ld	s4,80(sp)
ffffffffc0205692:	6aa6                	ld	s5,72(sp)
ffffffffc0205694:	6b06                	ld	s6,64(sp)
ffffffffc0205696:	7c42                	ld	s8,48(sp)
ffffffffc0205698:	8566                	mv	a0,s9
ffffffffc020569a:	7ca2                	ld	s9,40(sp)
ffffffffc020569c:	6109                	addi	sp,sp,128
ffffffffc020569e:	8082                	ret
ffffffffc02056a0:	c899                	beqz	s1,ffffffffc02056b6 <sysfile_read+0xa8>
ffffffffc02056a2:	03848513          	addi	a0,s1,56
ffffffffc02056a6:	f51fe0ef          	jal	ffffffffc02045f6 <down>
ffffffffc02056aa:	000c3783          	ld	a5,0(s8)
ffffffffc02056ae:	66e2                	ld	a3,24(sp)
ffffffffc02056b0:	c399                	beqz	a5,ffffffffc02056b6 <sysfile_read+0xa8>
ffffffffc02056b2:	43dc                	lw	a5,4(a5)
ffffffffc02056b4:	c8bc                	sw	a5,80(s1)
ffffffffc02056b6:	864e                	mv	a2,s3
ffffffffc02056b8:	85ca                	mv	a1,s2
ffffffffc02056ba:	8526                	mv	a0,s1
ffffffffc02056bc:	d35fe0ef          	jal	ffffffffc02043f0 <copy_to_user>
ffffffffc02056c0:	c915                	beqz	a0,ffffffffc02056f4 <sysfile_read+0xe6>
ffffffffc02056c2:	67e2                	ld	a5,24(sp)
ffffffffc02056c4:	06f46a63          	bltu	s0,a5,ffffffffc0205738 <sysfile_read+0x12a>
ffffffffc02056c8:	9b3e                	add	s6,s6,a5
ffffffffc02056ca:	c889                	beqz	s1,ffffffffc02056dc <sysfile_read+0xce>
ffffffffc02056cc:	03848513          	addi	a0,s1,56
ffffffffc02056d0:	e43e                	sd	a5,8(sp)
ffffffffc02056d2:	f21fe0ef          	jal	ffffffffc02045f2 <up>
ffffffffc02056d6:	67a2                	ld	a5,8(sp)
ffffffffc02056d8:	0404a823          	sw	zero,80(s1)
ffffffffc02056dc:	f80c9ee3          	bnez	s9,ffffffffc0205678 <sysfile_read+0x6a>
ffffffffc02056e0:	6762                	ld	a4,24(sp)
ffffffffc02056e2:	db59                	beqz	a4,ffffffffc0205678 <sysfile_read+0x6a>
ffffffffc02056e4:	8c1d                	sub	s0,s0,a5
ffffffffc02056e6:	d849                	beqz	s0,ffffffffc0205678 <sysfile_read+0x6a>
ffffffffc02056e8:	993e                	add	s2,s2,a5
ffffffffc02056ea:	f7547ce3          	bgeu	s0,s5,ffffffffc0205662 <sysfile_read+0x54>
ffffffffc02056ee:	87a2                	mv	a5,s0
ffffffffc02056f0:	8622                	mv	a2,s0
ffffffffc02056f2:	bf95                	j	ffffffffc0205666 <sysfile_read+0x58>
ffffffffc02056f4:	000c8a63          	beqz	s9,ffffffffc0205708 <sysfile_read+0xfa>
ffffffffc02056f8:	d0c1                	beqz	s1,ffffffffc0205678 <sysfile_read+0x6a>
ffffffffc02056fa:	03848513          	addi	a0,s1,56
ffffffffc02056fe:	ef5fe0ef          	jal	ffffffffc02045f2 <up>
ffffffffc0205702:	0404a823          	sw	zero,80(s1)
ffffffffc0205706:	bf8d                	j	ffffffffc0205678 <sysfile_read+0x6a>
ffffffffc0205708:	c499                	beqz	s1,ffffffffc0205716 <sysfile_read+0x108>
ffffffffc020570a:	03848513          	addi	a0,s1,56
ffffffffc020570e:	ee5fe0ef          	jal	ffffffffc02045f2 <up>
ffffffffc0205712:	0404a823          	sw	zero,80(s1)
ffffffffc0205716:	5cf5                	li	s9,-3
ffffffffc0205718:	b785                	j	ffffffffc0205678 <sysfile_read+0x6a>
ffffffffc020571a:	7446                	ld	s0,112(sp)
ffffffffc020571c:	74a6                	ld	s1,104(sp)
ffffffffc020571e:	7906                	ld	s2,96(sp)
ffffffffc0205720:	6a46                	ld	s4,80(sp)
ffffffffc0205722:	7c42                	ld	s8,48(sp)
ffffffffc0205724:	5cf5                	li	s9,-3
ffffffffc0205726:	bdcd                	j	ffffffffc0205618 <sysfile_read+0xa>
ffffffffc0205728:	7446                	ld	s0,112(sp)
ffffffffc020572a:	74a6                	ld	s1,104(sp)
ffffffffc020572c:	7906                	ld	s2,96(sp)
ffffffffc020572e:	69e6                	ld	s3,88(sp)
ffffffffc0205730:	6a46                	ld	s4,80(sp)
ffffffffc0205732:	7c42                	ld	s8,48(sp)
ffffffffc0205734:	5cf1                	li	s9,-4
ffffffffc0205736:	b5cd                	j	ffffffffc0205618 <sysfile_read+0xa>
ffffffffc0205738:	00008697          	auipc	a3,0x8
ffffffffc020573c:	f6068693          	addi	a3,a3,-160 # ffffffffc020d698 <etext+0x1e38>
ffffffffc0205740:	00006617          	auipc	a2,0x6
ffffffffc0205744:	55860613          	addi	a2,a2,1368 # ffffffffc020bc98 <etext+0x438>
ffffffffc0205748:	05500593          	li	a1,85
ffffffffc020574c:	00008517          	auipc	a0,0x8
ffffffffc0205750:	f5c50513          	addi	a0,a0,-164 # ffffffffc020d6a8 <etext+0x1e48>
ffffffffc0205754:	fc5e                	sd	s7,56(sp)
ffffffffc0205756:	cf5fa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020575a <sysfile_write>:
ffffffffc020575a:	e601                	bnez	a2,ffffffffc0205762 <sysfile_write+0x8>
ffffffffc020575c:	4701                	li	a4,0
ffffffffc020575e:	853a                	mv	a0,a4
ffffffffc0205760:	8082                	ret
ffffffffc0205762:	7159                	addi	sp,sp,-112
ffffffffc0205764:	f062                	sd	s8,32(sp)
ffffffffc0205766:	00091c17          	auipc	s8,0x91
ffffffffc020576a:	162c0c13          	addi	s8,s8,354 # ffffffffc02968c8 <current>
ffffffffc020576e:	000c3783          	ld	a5,0(s8)
ffffffffc0205772:	f0a2                	sd	s0,96(sp)
ffffffffc0205774:	eca6                	sd	s1,88(sp)
ffffffffc0205776:	8432                	mv	s0,a2
ffffffffc0205778:	84ae                	mv	s1,a1
ffffffffc020577a:	4605                	li	a2,1
ffffffffc020577c:	4581                	li	a1,0
ffffffffc020577e:	e8ca                	sd	s2,80(sp)
ffffffffc0205780:	e0d2                	sd	s4,64(sp)
ffffffffc0205782:	f486                	sd	ra,104(sp)
ffffffffc0205784:	0287b903          	ld	s2,40(a5) # 1028 <_binary_bin_swap_img_size-0x6cd8>
ffffffffc0205788:	8a2a                	mv	s4,a0
ffffffffc020578a:	b44ff0ef          	jal	ffffffffc0204ace <file_testfd>
ffffffffc020578e:	c969                	beqz	a0,ffffffffc0205860 <sysfile_write+0x106>
ffffffffc0205790:	6505                	lui	a0,0x1
ffffffffc0205792:	e4ce                	sd	s3,72(sp)
ffffffffc0205794:	82dfc0ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc0205798:	89aa                	mv	s3,a0
ffffffffc020579a:	c569                	beqz	a0,ffffffffc0205864 <sysfile_write+0x10a>
ffffffffc020579c:	fc56                	sd	s5,56(sp)
ffffffffc020579e:	f45e                	sd	s7,40(sp)
ffffffffc02057a0:	4a81                	li	s5,0
ffffffffc02057a2:	6b85                	lui	s7,0x1
ffffffffc02057a4:	86a2                	mv	a3,s0
ffffffffc02057a6:	008bf363          	bgeu	s7,s0,ffffffffc02057ac <sysfile_write+0x52>
ffffffffc02057aa:	6685                	lui	a3,0x1
ffffffffc02057ac:	ec36                	sd	a3,24(sp)
ffffffffc02057ae:	04090e63          	beqz	s2,ffffffffc020580a <sysfile_write+0xb0>
ffffffffc02057b2:	03890513          	addi	a0,s2,56
ffffffffc02057b6:	e41fe0ef          	jal	ffffffffc02045f6 <down>
ffffffffc02057ba:	000c3783          	ld	a5,0(s8)
ffffffffc02057be:	c781                	beqz	a5,ffffffffc02057c6 <sysfile_write+0x6c>
ffffffffc02057c0:	43dc                	lw	a5,4(a5)
ffffffffc02057c2:	04f92823          	sw	a5,80(s2)
ffffffffc02057c6:	66e2                	ld	a3,24(sp)
ffffffffc02057c8:	4701                	li	a4,0
ffffffffc02057ca:	8626                	mv	a2,s1
ffffffffc02057cc:	85ce                	mv	a1,s3
ffffffffc02057ce:	854a                	mv	a0,s2
ffffffffc02057d0:	bebfe0ef          	jal	ffffffffc02043ba <copy_from_user>
ffffffffc02057d4:	ed3d                	bnez	a0,ffffffffc0205852 <sysfile_write+0xf8>
ffffffffc02057d6:	03890513          	addi	a0,s2,56
ffffffffc02057da:	e19fe0ef          	jal	ffffffffc02045f2 <up>
ffffffffc02057de:	04092823          	sw	zero,80(s2)
ffffffffc02057e2:	5775                	li	a4,-3
ffffffffc02057e4:	854e                	mv	a0,s3
ffffffffc02057e6:	e43a                	sd	a4,8(sp)
ffffffffc02057e8:	87ffc0ef          	jal	ffffffffc0202066 <kfree>
ffffffffc02057ec:	6722                	ld	a4,8(sp)
ffffffffc02057ee:	040a9c63          	bnez	s5,ffffffffc0205846 <sysfile_write+0xec>
ffffffffc02057f2:	69a6                	ld	s3,72(sp)
ffffffffc02057f4:	7ae2                	ld	s5,56(sp)
ffffffffc02057f6:	7ba2                	ld	s7,40(sp)
ffffffffc02057f8:	70a6                	ld	ra,104(sp)
ffffffffc02057fa:	7406                	ld	s0,96(sp)
ffffffffc02057fc:	64e6                	ld	s1,88(sp)
ffffffffc02057fe:	6946                	ld	s2,80(sp)
ffffffffc0205800:	6a06                	ld	s4,64(sp)
ffffffffc0205802:	7c02                	ld	s8,32(sp)
ffffffffc0205804:	853a                	mv	a0,a4
ffffffffc0205806:	6165                	addi	sp,sp,112
ffffffffc0205808:	8082                	ret
ffffffffc020580a:	4701                	li	a4,0
ffffffffc020580c:	8626                	mv	a2,s1
ffffffffc020580e:	85ce                	mv	a1,s3
ffffffffc0205810:	4501                	li	a0,0
ffffffffc0205812:	ba9fe0ef          	jal	ffffffffc02043ba <copy_from_user>
ffffffffc0205816:	d571                	beqz	a0,ffffffffc02057e2 <sysfile_write+0x88>
ffffffffc0205818:	6662                	ld	a2,24(sp)
ffffffffc020581a:	0834                	addi	a3,sp,24
ffffffffc020581c:	85ce                	mv	a1,s3
ffffffffc020581e:	8552                	mv	a0,s4
ffffffffc0205820:	d62ff0ef          	jal	ffffffffc0204d82 <file_write>
ffffffffc0205824:	67e2                	ld	a5,24(sp)
ffffffffc0205826:	872a                	mv	a4,a0
ffffffffc0205828:	dfd5                	beqz	a5,ffffffffc02057e4 <sysfile_write+0x8a>
ffffffffc020582a:	04f46063          	bltu	s0,a5,ffffffffc020586a <sysfile_write+0x110>
ffffffffc020582e:	9abe                	add	s5,s5,a5
ffffffffc0205830:	f955                	bnez	a0,ffffffffc02057e4 <sysfile_write+0x8a>
ffffffffc0205832:	8c1d                	sub	s0,s0,a5
ffffffffc0205834:	94be                	add	s1,s1,a5
ffffffffc0205836:	f43d                	bnez	s0,ffffffffc02057a4 <sysfile_write+0x4a>
ffffffffc0205838:	854e                	mv	a0,s3
ffffffffc020583a:	e43a                	sd	a4,8(sp)
ffffffffc020583c:	82bfc0ef          	jal	ffffffffc0202066 <kfree>
ffffffffc0205840:	6722                	ld	a4,8(sp)
ffffffffc0205842:	fa0a88e3          	beqz	s5,ffffffffc02057f2 <sysfile_write+0x98>
ffffffffc0205846:	000a871b          	sext.w	a4,s5
ffffffffc020584a:	69a6                	ld	s3,72(sp)
ffffffffc020584c:	7ae2                	ld	s5,56(sp)
ffffffffc020584e:	7ba2                	ld	s7,40(sp)
ffffffffc0205850:	b765                	j	ffffffffc02057f8 <sysfile_write+0x9e>
ffffffffc0205852:	03890513          	addi	a0,s2,56
ffffffffc0205856:	d9dfe0ef          	jal	ffffffffc02045f2 <up>
ffffffffc020585a:	04092823          	sw	zero,80(s2)
ffffffffc020585e:	bf6d                	j	ffffffffc0205818 <sysfile_write+0xbe>
ffffffffc0205860:	5775                	li	a4,-3
ffffffffc0205862:	bf59                	j	ffffffffc02057f8 <sysfile_write+0x9e>
ffffffffc0205864:	69a6                	ld	s3,72(sp)
ffffffffc0205866:	5771                	li	a4,-4
ffffffffc0205868:	bf41                	j	ffffffffc02057f8 <sysfile_write+0x9e>
ffffffffc020586a:	00008697          	auipc	a3,0x8
ffffffffc020586e:	e2e68693          	addi	a3,a3,-466 # ffffffffc020d698 <etext+0x1e38>
ffffffffc0205872:	00006617          	auipc	a2,0x6
ffffffffc0205876:	42660613          	addi	a2,a2,1062 # ffffffffc020bc98 <etext+0x438>
ffffffffc020587a:	08a00593          	li	a1,138
ffffffffc020587e:	00008517          	auipc	a0,0x8
ffffffffc0205882:	e2a50513          	addi	a0,a0,-470 # ffffffffc020d6a8 <etext+0x1e48>
ffffffffc0205886:	f85a                	sd	s6,48(sp)
ffffffffc0205888:	bc3fa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc020588c <sysfile_seek>:
ffffffffc020588c:	de4ff06f          	j	ffffffffc0204e70 <file_seek>

ffffffffc0205890 <sysfile_fstat>:
ffffffffc0205890:	715d                	addi	sp,sp,-80
ffffffffc0205892:	f84a                	sd	s2,48(sp)
ffffffffc0205894:	00091917          	auipc	s2,0x91
ffffffffc0205898:	03490913          	addi	s2,s2,52 # ffffffffc02968c8 <current>
ffffffffc020589c:	00093783          	ld	a5,0(s2)
ffffffffc02058a0:	f44e                	sd	s3,40(sp)
ffffffffc02058a2:	89ae                	mv	s3,a1
ffffffffc02058a4:	858a                	mv	a1,sp
ffffffffc02058a6:	e0a2                	sd	s0,64(sp)
ffffffffc02058a8:	fc26                	sd	s1,56(sp)
ffffffffc02058aa:	e486                	sd	ra,72(sp)
ffffffffc02058ac:	7784                	ld	s1,40(a5)
ffffffffc02058ae:	ee6ff0ef          	jal	ffffffffc0204f94 <file_fstat>
ffffffffc02058b2:	842a                	mv	s0,a0
ffffffffc02058b4:	e915                	bnez	a0,ffffffffc02058e8 <sysfile_fstat+0x58>
ffffffffc02058b6:	c0a9                	beqz	s1,ffffffffc02058f8 <sysfile_fstat+0x68>
ffffffffc02058b8:	03848513          	addi	a0,s1,56
ffffffffc02058bc:	d3bfe0ef          	jal	ffffffffc02045f6 <down>
ffffffffc02058c0:	00093783          	ld	a5,0(s2)
ffffffffc02058c4:	c399                	beqz	a5,ffffffffc02058ca <sysfile_fstat+0x3a>
ffffffffc02058c6:	43dc                	lw	a5,4(a5)
ffffffffc02058c8:	c8bc                	sw	a5,80(s1)
ffffffffc02058ca:	860a                	mv	a2,sp
ffffffffc02058cc:	85ce                	mv	a1,s3
ffffffffc02058ce:	02000693          	li	a3,32
ffffffffc02058d2:	8526                	mv	a0,s1
ffffffffc02058d4:	b1dfe0ef          	jal	ffffffffc02043f0 <copy_to_user>
ffffffffc02058d8:	e111                	bnez	a0,ffffffffc02058dc <sysfile_fstat+0x4c>
ffffffffc02058da:	5475                	li	s0,-3
ffffffffc02058dc:	03848513          	addi	a0,s1,56
ffffffffc02058e0:	d13fe0ef          	jal	ffffffffc02045f2 <up>
ffffffffc02058e4:	0404a823          	sw	zero,80(s1)
ffffffffc02058e8:	60a6                	ld	ra,72(sp)
ffffffffc02058ea:	8522                	mv	a0,s0
ffffffffc02058ec:	6406                	ld	s0,64(sp)
ffffffffc02058ee:	74e2                	ld	s1,56(sp)
ffffffffc02058f0:	7942                	ld	s2,48(sp)
ffffffffc02058f2:	79a2                	ld	s3,40(sp)
ffffffffc02058f4:	6161                	addi	sp,sp,80
ffffffffc02058f6:	8082                	ret
ffffffffc02058f8:	860a                	mv	a2,sp
ffffffffc02058fa:	85ce                	mv	a1,s3
ffffffffc02058fc:	02000693          	li	a3,32
ffffffffc0205900:	af1fe0ef          	jal	ffffffffc02043f0 <copy_to_user>
ffffffffc0205904:	f175                	bnez	a0,ffffffffc02058e8 <sysfile_fstat+0x58>
ffffffffc0205906:	5475                	li	s0,-3
ffffffffc0205908:	60a6                	ld	ra,72(sp)
ffffffffc020590a:	8522                	mv	a0,s0
ffffffffc020590c:	6406                	ld	s0,64(sp)
ffffffffc020590e:	74e2                	ld	s1,56(sp)
ffffffffc0205910:	7942                	ld	s2,48(sp)
ffffffffc0205912:	79a2                	ld	s3,40(sp)
ffffffffc0205914:	6161                	addi	sp,sp,80
ffffffffc0205916:	8082                	ret

ffffffffc0205918 <sysfile_fsync>:
ffffffffc0205918:	f34ff06f          	j	ffffffffc020504c <file_fsync>

ffffffffc020591c <sysfile_getcwd>:
ffffffffc020591c:	c1d5                	beqz	a1,ffffffffc02059c0 <sysfile_getcwd+0xa4>
ffffffffc020591e:	00091717          	auipc	a4,0x91
ffffffffc0205922:	faa73703          	ld	a4,-86(a4) # ffffffffc02968c8 <current>
ffffffffc0205926:	711d                	addi	sp,sp,-96
ffffffffc0205928:	e8a2                	sd	s0,80(sp)
ffffffffc020592a:	7700                	ld	s0,40(a4)
ffffffffc020592c:	e4a6                	sd	s1,72(sp)
ffffffffc020592e:	e0ca                	sd	s2,64(sp)
ffffffffc0205930:	ec86                	sd	ra,88(sp)
ffffffffc0205932:	892a                	mv	s2,a0
ffffffffc0205934:	84ae                	mv	s1,a1
ffffffffc0205936:	c039                	beqz	s0,ffffffffc020597c <sysfile_getcwd+0x60>
ffffffffc0205938:	03840513          	addi	a0,s0,56
ffffffffc020593c:	cbbfe0ef          	jal	ffffffffc02045f6 <down>
ffffffffc0205940:	00091797          	auipc	a5,0x91
ffffffffc0205944:	f887b783          	ld	a5,-120(a5) # ffffffffc02968c8 <current>
ffffffffc0205948:	c399                	beqz	a5,ffffffffc020594e <sysfile_getcwd+0x32>
ffffffffc020594a:	43dc                	lw	a5,4(a5)
ffffffffc020594c:	c83c                	sw	a5,80(s0)
ffffffffc020594e:	4685                	li	a3,1
ffffffffc0205950:	8626                	mv	a2,s1
ffffffffc0205952:	85ca                	mv	a1,s2
ffffffffc0205954:	8522                	mv	a0,s0
ffffffffc0205956:	9c1fe0ef          	jal	ffffffffc0204316 <user_mem_check>
ffffffffc020595a:	57f5                	li	a5,-3
ffffffffc020595c:	e921                	bnez	a0,ffffffffc02059ac <sysfile_getcwd+0x90>
ffffffffc020595e:	03840513          	addi	a0,s0,56
ffffffffc0205962:	e43e                	sd	a5,8(sp)
ffffffffc0205964:	c8ffe0ef          	jal	ffffffffc02045f2 <up>
ffffffffc0205968:	67a2                	ld	a5,8(sp)
ffffffffc020596a:	04042823          	sw	zero,80(s0)
ffffffffc020596e:	60e6                	ld	ra,88(sp)
ffffffffc0205970:	6446                	ld	s0,80(sp)
ffffffffc0205972:	64a6                	ld	s1,72(sp)
ffffffffc0205974:	6906                	ld	s2,64(sp)
ffffffffc0205976:	853e                	mv	a0,a5
ffffffffc0205978:	6125                	addi	sp,sp,96
ffffffffc020597a:	8082                	ret
ffffffffc020597c:	862e                	mv	a2,a1
ffffffffc020597e:	4685                	li	a3,1
ffffffffc0205980:	85aa                	mv	a1,a0
ffffffffc0205982:	4501                	li	a0,0
ffffffffc0205984:	993fe0ef          	jal	ffffffffc0204316 <user_mem_check>
ffffffffc0205988:	57f5                	li	a5,-3
ffffffffc020598a:	d175                	beqz	a0,ffffffffc020596e <sysfile_getcwd+0x52>
ffffffffc020598c:	8626                	mv	a2,s1
ffffffffc020598e:	85ca                	mv	a1,s2
ffffffffc0205990:	4681                	li	a3,0
ffffffffc0205992:	0808                	addi	a0,sp,16
ffffffffc0205994:	af9ff0ef          	jal	ffffffffc020548c <iobuf_init>
ffffffffc0205998:	4e3020ef          	jal	ffffffffc020867a <vfs_getcwd>
ffffffffc020599c:	60e6                	ld	ra,88(sp)
ffffffffc020599e:	6446                	ld	s0,80(sp)
ffffffffc02059a0:	87aa                	mv	a5,a0
ffffffffc02059a2:	64a6                	ld	s1,72(sp)
ffffffffc02059a4:	6906                	ld	s2,64(sp)
ffffffffc02059a6:	853e                	mv	a0,a5
ffffffffc02059a8:	6125                	addi	sp,sp,96
ffffffffc02059aa:	8082                	ret
ffffffffc02059ac:	8626                	mv	a2,s1
ffffffffc02059ae:	85ca                	mv	a1,s2
ffffffffc02059b0:	4681                	li	a3,0
ffffffffc02059b2:	0808                	addi	a0,sp,16
ffffffffc02059b4:	ad9ff0ef          	jal	ffffffffc020548c <iobuf_init>
ffffffffc02059b8:	4c3020ef          	jal	ffffffffc020867a <vfs_getcwd>
ffffffffc02059bc:	87aa                	mv	a5,a0
ffffffffc02059be:	b745                	j	ffffffffc020595e <sysfile_getcwd+0x42>
ffffffffc02059c0:	57f5                	li	a5,-3
ffffffffc02059c2:	853e                	mv	a0,a5
ffffffffc02059c4:	8082                	ret

ffffffffc02059c6 <sysfile_getdirentry>:
ffffffffc02059c6:	7139                	addi	sp,sp,-64
ffffffffc02059c8:	ec4e                	sd	s3,24(sp)
ffffffffc02059ca:	00091997          	auipc	s3,0x91
ffffffffc02059ce:	efe98993          	addi	s3,s3,-258 # ffffffffc02968c8 <current>
ffffffffc02059d2:	0009b783          	ld	a5,0(s3)
ffffffffc02059d6:	f04a                	sd	s2,32(sp)
ffffffffc02059d8:	892a                	mv	s2,a0
ffffffffc02059da:	10800513          	li	a0,264
ffffffffc02059de:	f426                	sd	s1,40(sp)
ffffffffc02059e0:	e852                	sd	s4,16(sp)
ffffffffc02059e2:	fc06                	sd	ra,56(sp)
ffffffffc02059e4:	7784                	ld	s1,40(a5)
ffffffffc02059e6:	8a2e                	mv	s4,a1
ffffffffc02059e8:	dd8fc0ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc02059ec:	c179                	beqz	a0,ffffffffc0205ab2 <sysfile_getdirentry+0xec>
ffffffffc02059ee:	f822                	sd	s0,48(sp)
ffffffffc02059f0:	842a                	mv	s0,a0
ffffffffc02059f2:	c8d1                	beqz	s1,ffffffffc0205a86 <sysfile_getdirentry+0xc0>
ffffffffc02059f4:	03848513          	addi	a0,s1,56
ffffffffc02059f8:	bfffe0ef          	jal	ffffffffc02045f6 <down>
ffffffffc02059fc:	0009b783          	ld	a5,0(s3)
ffffffffc0205a00:	c399                	beqz	a5,ffffffffc0205a06 <sysfile_getdirentry+0x40>
ffffffffc0205a02:	43dc                	lw	a5,4(a5)
ffffffffc0205a04:	c8bc                	sw	a5,80(s1)
ffffffffc0205a06:	4705                	li	a4,1
ffffffffc0205a08:	46a1                	li	a3,8
ffffffffc0205a0a:	8652                	mv	a2,s4
ffffffffc0205a0c:	85a2                	mv	a1,s0
ffffffffc0205a0e:	8526                	mv	a0,s1
ffffffffc0205a10:	9abfe0ef          	jal	ffffffffc02043ba <copy_from_user>
ffffffffc0205a14:	e505                	bnez	a0,ffffffffc0205a3c <sysfile_getdirentry+0x76>
ffffffffc0205a16:	03848513          	addi	a0,s1,56
ffffffffc0205a1a:	bd9fe0ef          	jal	ffffffffc02045f2 <up>
ffffffffc0205a1e:	0404a823          	sw	zero,80(s1)
ffffffffc0205a22:	5975                	li	s2,-3
ffffffffc0205a24:	8522                	mv	a0,s0
ffffffffc0205a26:	e40fc0ef          	jal	ffffffffc0202066 <kfree>
ffffffffc0205a2a:	7442                	ld	s0,48(sp)
ffffffffc0205a2c:	70e2                	ld	ra,56(sp)
ffffffffc0205a2e:	74a2                	ld	s1,40(sp)
ffffffffc0205a30:	69e2                	ld	s3,24(sp)
ffffffffc0205a32:	6a42                	ld	s4,16(sp)
ffffffffc0205a34:	854a                	mv	a0,s2
ffffffffc0205a36:	7902                	ld	s2,32(sp)
ffffffffc0205a38:	6121                	addi	sp,sp,64
ffffffffc0205a3a:	8082                	ret
ffffffffc0205a3c:	03848513          	addi	a0,s1,56
ffffffffc0205a40:	bb3fe0ef          	jal	ffffffffc02045f2 <up>
ffffffffc0205a44:	854a                	mv	a0,s2
ffffffffc0205a46:	0404a823          	sw	zero,80(s1)
ffffffffc0205a4a:	85a2                	mv	a1,s0
ffffffffc0205a4c:	eaaff0ef          	jal	ffffffffc02050f6 <file_getdirentry>
ffffffffc0205a50:	892a                	mv	s2,a0
ffffffffc0205a52:	f969                	bnez	a0,ffffffffc0205a24 <sysfile_getdirentry+0x5e>
ffffffffc0205a54:	03848513          	addi	a0,s1,56
ffffffffc0205a58:	b9ffe0ef          	jal	ffffffffc02045f6 <down>
ffffffffc0205a5c:	0009b783          	ld	a5,0(s3)
ffffffffc0205a60:	c399                	beqz	a5,ffffffffc0205a66 <sysfile_getdirentry+0xa0>
ffffffffc0205a62:	43dc                	lw	a5,4(a5)
ffffffffc0205a64:	c8bc                	sw	a5,80(s1)
ffffffffc0205a66:	85d2                	mv	a1,s4
ffffffffc0205a68:	10800693          	li	a3,264
ffffffffc0205a6c:	8622                	mv	a2,s0
ffffffffc0205a6e:	8526                	mv	a0,s1
ffffffffc0205a70:	981fe0ef          	jal	ffffffffc02043f0 <copy_to_user>
ffffffffc0205a74:	e111                	bnez	a0,ffffffffc0205a78 <sysfile_getdirentry+0xb2>
ffffffffc0205a76:	5975                	li	s2,-3
ffffffffc0205a78:	03848513          	addi	a0,s1,56
ffffffffc0205a7c:	b77fe0ef          	jal	ffffffffc02045f2 <up>
ffffffffc0205a80:	0404a823          	sw	zero,80(s1)
ffffffffc0205a84:	b745                	j	ffffffffc0205a24 <sysfile_getdirentry+0x5e>
ffffffffc0205a86:	85aa                	mv	a1,a0
ffffffffc0205a88:	4705                	li	a4,1
ffffffffc0205a8a:	46a1                	li	a3,8
ffffffffc0205a8c:	8652                	mv	a2,s4
ffffffffc0205a8e:	4501                	li	a0,0
ffffffffc0205a90:	92bfe0ef          	jal	ffffffffc02043ba <copy_from_user>
ffffffffc0205a94:	d559                	beqz	a0,ffffffffc0205a22 <sysfile_getdirentry+0x5c>
ffffffffc0205a96:	854a                	mv	a0,s2
ffffffffc0205a98:	85a2                	mv	a1,s0
ffffffffc0205a9a:	e5cff0ef          	jal	ffffffffc02050f6 <file_getdirentry>
ffffffffc0205a9e:	892a                	mv	s2,a0
ffffffffc0205aa0:	f151                	bnez	a0,ffffffffc0205a24 <sysfile_getdirentry+0x5e>
ffffffffc0205aa2:	85d2                	mv	a1,s4
ffffffffc0205aa4:	10800693          	li	a3,264
ffffffffc0205aa8:	8622                	mv	a2,s0
ffffffffc0205aaa:	947fe0ef          	jal	ffffffffc02043f0 <copy_to_user>
ffffffffc0205aae:	f93d                	bnez	a0,ffffffffc0205a24 <sysfile_getdirentry+0x5e>
ffffffffc0205ab0:	bf8d                	j	ffffffffc0205a22 <sysfile_getdirentry+0x5c>
ffffffffc0205ab2:	5971                	li	s2,-4
ffffffffc0205ab4:	bfa5                	j	ffffffffc0205a2c <sysfile_getdirentry+0x66>

ffffffffc0205ab6 <sysfile_dup>:
ffffffffc0205ab6:	f2eff06f          	j	ffffffffc02051e4 <file_dup>

ffffffffc0205aba <kernel_thread_entry>:
ffffffffc0205aba:	8526                	mv	a0,s1
ffffffffc0205abc:	9402                	jalr	s0
ffffffffc0205abe:	728000ef          	jal	ffffffffc02061e6 <do_exit>

ffffffffc0205ac2 <alloc_proc>:
ffffffffc0205ac2:	1101                	addi	sp,sp,-32
ffffffffc0205ac4:	15000513          	li	a0,336
ffffffffc0205ac8:	e822                	sd	s0,16(sp)
ffffffffc0205aca:	ec06                	sd	ra,24(sp)
ffffffffc0205acc:	cf4fc0ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc0205ad0:	842a                	mv	s0,a0
ffffffffc0205ad2:	10050063          	beqz	a0,ffffffffc0205bd2 <alloc_proc+0x110>
ffffffffc0205ad6:	57fd                	li	a5,-1
ffffffffc0205ad8:	03050693          	addi	a3,a0,48
ffffffffc0205adc:	1782                	slli	a5,a5,0x20
ffffffffc0205ade:	e11c                	sd	a5,0(a0)
ffffffffc0205ae0:	00052423          	sw	zero,8(a0)
ffffffffc0205ae4:	00053823          	sd	zero,16(a0)
ffffffffc0205ae8:	00053c23          	sd	zero,24(a0)
ffffffffc0205aec:	02053023          	sd	zero,32(a0)
ffffffffc0205af0:	02053423          	sd	zero,40(a0)
ffffffffc0205af4:	07000613          	li	a2,112
ffffffffc0205af8:	8536                	mv	a0,a3
ffffffffc0205afa:	4581                	li	a1,0
ffffffffc0205afc:	e036                	sd	a3,0(sp)
ffffffffc0205afe:	4fb050ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc0205b02:	00091617          	auipc	a2,0x91
ffffffffc0205b06:	d9663603          	ld	a2,-618(a2) # ffffffffc0296898 <boot_pgdir_pa>
ffffffffc0205b0a:	0b440713          	addi	a4,s0,180
ffffffffc0205b0e:	853a                	mv	a0,a4
ffffffffc0205b10:	f450                	sd	a2,168(s0)
ffffffffc0205b12:	4581                	li	a1,0
ffffffffc0205b14:	4641                	li	a2,16
ffffffffc0205b16:	0a043023          	sd	zero,160(s0)
ffffffffc0205b1a:	0a042823          	sw	zero,176(s0)
ffffffffc0205b1e:	e43a                	sd	a4,8(sp)
ffffffffc0205b20:	4d9050ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc0205b24:	57fd                	li	a5,-1
ffffffffc0205b26:	6502                	ld	a0,0(sp)
ffffffffc0205b28:	1782                	slli	a5,a5,0x20
ffffffffc0205b2a:	e01c                	sd	a5,0(s0)
ffffffffc0205b2c:	11040793          	addi	a5,s0,272
ffffffffc0205b30:	10f43c23          	sd	a5,280(s0)
ffffffffc0205b34:	10f43823          	sd	a5,272(s0)
ffffffffc0205b38:	07000613          	li	a2,112
ffffffffc0205b3c:	4581                	li	a1,0
ffffffffc0205b3e:	0e042623          	sw	zero,236(s0)
ffffffffc0205b42:	0e043c23          	sd	zero,248(s0)
ffffffffc0205b46:	10043023          	sd	zero,256(s0)
ffffffffc0205b4a:	0e043823          	sd	zero,240(s0)
ffffffffc0205b4e:	10043423          	sd	zero,264(s0)
ffffffffc0205b52:	12042023          	sw	zero,288(s0)
ffffffffc0205b56:	12043423          	sd	zero,296(s0)
ffffffffc0205b5a:	12043c23          	sd	zero,312(s0)
ffffffffc0205b5e:	12043823          	sd	zero,304(s0)
ffffffffc0205b62:	14043023          	sd	zero,320(s0)
ffffffffc0205b66:	14043423          	sd	zero,328(s0)
ffffffffc0205b6a:	00042423          	sw	zero,8(s0)
ffffffffc0205b6e:	00043823          	sd	zero,16(s0)
ffffffffc0205b72:	00043c23          	sd	zero,24(s0)
ffffffffc0205b76:	02043023          	sd	zero,32(s0)
ffffffffc0205b7a:	02043423          	sd	zero,40(s0)
ffffffffc0205b7e:	e03e                	sd	a5,0(sp)
ffffffffc0205b80:	479050ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc0205b84:	00091697          	auipc	a3,0x91
ffffffffc0205b88:	d146b683          	ld	a3,-748(a3) # ffffffffc0296898 <boot_pgdir_pa>
ffffffffc0205b8c:	6522                	ld	a0,8(sp)
ffffffffc0205b8e:	0a043023          	sd	zero,160(s0)
ffffffffc0205b92:	0a042823          	sw	zero,176(s0)
ffffffffc0205b96:	f454                	sd	a3,168(s0)
ffffffffc0205b98:	463d                	li	a2,15
ffffffffc0205b9a:	4581                	li	a1,0
ffffffffc0205b9c:	45d050ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc0205ba0:	6782                	ld	a5,0(sp)
ffffffffc0205ba2:	0e042623          	sw	zero,236(s0)
ffffffffc0205ba6:	0e043c23          	sd	zero,248(s0)
ffffffffc0205baa:	10043023          	sd	zero,256(s0)
ffffffffc0205bae:	0e043823          	sd	zero,240(s0)
ffffffffc0205bb2:	10043423          	sd	zero,264(s0)
ffffffffc0205bb6:	10f43c23          	sd	a5,280(s0)
ffffffffc0205bba:	10f43823          	sd	a5,272(s0)
ffffffffc0205bbe:	12042023          	sw	zero,288(s0)
ffffffffc0205bc2:	12043423          	sd	zero,296(s0)
ffffffffc0205bc6:	12043c23          	sd	zero,312(s0)
ffffffffc0205bca:	12043823          	sd	zero,304(s0)
ffffffffc0205bce:	14043023          	sd	zero,320(s0)
ffffffffc0205bd2:	60e2                	ld	ra,24(sp)
ffffffffc0205bd4:	8522                	mv	a0,s0
ffffffffc0205bd6:	6442                	ld	s0,16(sp)
ffffffffc0205bd8:	6105                	addi	sp,sp,32
ffffffffc0205bda:	8082                	ret

ffffffffc0205bdc <forkret>:
ffffffffc0205bdc:	00091797          	auipc	a5,0x91
ffffffffc0205be0:	cec7b783          	ld	a5,-788(a5) # ffffffffc02968c8 <current>
ffffffffc0205be4:	73c8                	ld	a0,160(a5)
ffffffffc0205be6:	e68fb06f          	j	ffffffffc020124e <forkrets>

ffffffffc0205bea <put_pgdir.isra.0>:
ffffffffc0205bea:	1141                	addi	sp,sp,-16
ffffffffc0205bec:	e406                	sd	ra,8(sp)
ffffffffc0205bee:	c02007b7          	lui	a5,0xc0200
ffffffffc0205bf2:	02f56f63          	bltu	a0,a5,ffffffffc0205c30 <put_pgdir.isra.0+0x46>
ffffffffc0205bf6:	00091797          	auipc	a5,0x91
ffffffffc0205bfa:	cb27b783          	ld	a5,-846(a5) # ffffffffc02968a8 <va_pa_offset>
ffffffffc0205bfe:	00091717          	auipc	a4,0x91
ffffffffc0205c02:	cb273703          	ld	a4,-846(a4) # ffffffffc02968b0 <npage>
ffffffffc0205c06:	8d1d                	sub	a0,a0,a5
ffffffffc0205c08:	00c55793          	srli	a5,a0,0xc
ffffffffc0205c0c:	02e7ff63          	bgeu	a5,a4,ffffffffc0205c4a <put_pgdir.isra.0+0x60>
ffffffffc0205c10:	0000a717          	auipc	a4,0xa
ffffffffc0205c14:	f4873703          	ld	a4,-184(a4) # ffffffffc020fb58 <nbase>
ffffffffc0205c18:	00091517          	auipc	a0,0x91
ffffffffc0205c1c:	ca053503          	ld	a0,-864(a0) # ffffffffc02968b8 <pages>
ffffffffc0205c20:	60a2                	ld	ra,8(sp)
ffffffffc0205c22:	8f99                	sub	a5,a5,a4
ffffffffc0205c24:	079a                	slli	a5,a5,0x6
ffffffffc0205c26:	4585                	li	a1,1
ffffffffc0205c28:	953e                	add	a0,a0,a5
ffffffffc0205c2a:	0141                	addi	sp,sp,16
ffffffffc0205c2c:	d92fc06f          	j	ffffffffc02021be <free_pages>
ffffffffc0205c30:	86aa                	mv	a3,a0
ffffffffc0205c32:	00007617          	auipc	a2,0x7
ffffffffc0205c36:	b8660613          	addi	a2,a2,-1146 # ffffffffc020c7b8 <etext+0xf58>
ffffffffc0205c3a:	07700593          	li	a1,119
ffffffffc0205c3e:	00007517          	auipc	a0,0x7
ffffffffc0205c42:	afa50513          	addi	a0,a0,-1286 # ffffffffc020c738 <etext+0xed8>
ffffffffc0205c46:	805fa0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0205c4a:	00007617          	auipc	a2,0x7
ffffffffc0205c4e:	b9660613          	addi	a2,a2,-1130 # ffffffffc020c7e0 <etext+0xf80>
ffffffffc0205c52:	06900593          	li	a1,105
ffffffffc0205c56:	00007517          	auipc	a0,0x7
ffffffffc0205c5a:	ae250513          	addi	a0,a0,-1310 # ffffffffc020c738 <etext+0xed8>
ffffffffc0205c5e:	fecfa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0205c62 <setup_pgdir>:
ffffffffc0205c62:	1101                	addi	sp,sp,-32
ffffffffc0205c64:	e426                	sd	s1,8(sp)
ffffffffc0205c66:	84aa                	mv	s1,a0
ffffffffc0205c68:	4505                	li	a0,1
ffffffffc0205c6a:	ec06                	sd	ra,24(sp)
ffffffffc0205c6c:	d18fc0ef          	jal	ffffffffc0202184 <alloc_pages>
ffffffffc0205c70:	cd29                	beqz	a0,ffffffffc0205cca <setup_pgdir+0x68>
ffffffffc0205c72:	00091697          	auipc	a3,0x91
ffffffffc0205c76:	c466b683          	ld	a3,-954(a3) # ffffffffc02968b8 <pages>
ffffffffc0205c7a:	0000a797          	auipc	a5,0xa
ffffffffc0205c7e:	ede7b783          	ld	a5,-290(a5) # ffffffffc020fb58 <nbase>
ffffffffc0205c82:	00091717          	auipc	a4,0x91
ffffffffc0205c86:	c2e73703          	ld	a4,-978(a4) # ffffffffc02968b0 <npage>
ffffffffc0205c8a:	40d506b3          	sub	a3,a0,a3
ffffffffc0205c8e:	8699                	srai	a3,a3,0x6
ffffffffc0205c90:	96be                	add	a3,a3,a5
ffffffffc0205c92:	00c69793          	slli	a5,a3,0xc
ffffffffc0205c96:	e822                	sd	s0,16(sp)
ffffffffc0205c98:	83b1                	srli	a5,a5,0xc
ffffffffc0205c9a:	06b2                	slli	a3,a3,0xc
ffffffffc0205c9c:	02e7f963          	bgeu	a5,a4,ffffffffc0205cce <setup_pgdir+0x6c>
ffffffffc0205ca0:	00091797          	auipc	a5,0x91
ffffffffc0205ca4:	c087b783          	ld	a5,-1016(a5) # ffffffffc02968a8 <va_pa_offset>
ffffffffc0205ca8:	00091597          	auipc	a1,0x91
ffffffffc0205cac:	bf85b583          	ld	a1,-1032(a1) # ffffffffc02968a0 <boot_pgdir_va>
ffffffffc0205cb0:	6605                	lui	a2,0x1
ffffffffc0205cb2:	00f68433          	add	s0,a3,a5
ffffffffc0205cb6:	8522                	mv	a0,s0
ffffffffc0205cb8:	391050ef          	jal	ffffffffc020b848 <memcpy>
ffffffffc0205cbc:	ec80                	sd	s0,24(s1)
ffffffffc0205cbe:	6442                	ld	s0,16(sp)
ffffffffc0205cc0:	4501                	li	a0,0
ffffffffc0205cc2:	60e2                	ld	ra,24(sp)
ffffffffc0205cc4:	64a2                	ld	s1,8(sp)
ffffffffc0205cc6:	6105                	addi	sp,sp,32
ffffffffc0205cc8:	8082                	ret
ffffffffc0205cca:	5571                	li	a0,-4
ffffffffc0205ccc:	bfdd                	j	ffffffffc0205cc2 <setup_pgdir+0x60>
ffffffffc0205cce:	00007617          	auipc	a2,0x7
ffffffffc0205cd2:	a4260613          	addi	a2,a2,-1470 # ffffffffc020c710 <etext+0xeb0>
ffffffffc0205cd6:	07100593          	li	a1,113
ffffffffc0205cda:	00007517          	auipc	a0,0x7
ffffffffc0205cde:	a5e50513          	addi	a0,a0,-1442 # ffffffffc020c738 <etext+0xed8>
ffffffffc0205ce2:	f68fa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0205ce6 <proc_run>:
ffffffffc0205ce6:	00091697          	auipc	a3,0x91
ffffffffc0205cea:	be26b683          	ld	a3,-1054(a3) # ffffffffc02968c8 <current>
ffffffffc0205cee:	04a68663          	beq	a3,a0,ffffffffc0205d3a <proc_run+0x54>
ffffffffc0205cf2:	1101                	addi	sp,sp,-32
ffffffffc0205cf4:	ec06                	sd	ra,24(sp)
ffffffffc0205cf6:	100027f3          	csrr	a5,sstatus
ffffffffc0205cfa:	8b89                	andi	a5,a5,2
ffffffffc0205cfc:	4601                	li	a2,0
ffffffffc0205cfe:	ef9d                	bnez	a5,ffffffffc0205d3c <proc_run+0x56>
ffffffffc0205d00:	755c                	ld	a5,168(a0)
ffffffffc0205d02:	577d                	li	a4,-1
ffffffffc0205d04:	177e                	slli	a4,a4,0x3f
ffffffffc0205d06:	83b1                	srli	a5,a5,0xc
ffffffffc0205d08:	e032                	sd	a2,0(sp)
ffffffffc0205d0a:	00091597          	auipc	a1,0x91
ffffffffc0205d0e:	baa5bf23          	sd	a0,-1090(a1) # ffffffffc02968c8 <current>
ffffffffc0205d12:	8fd9                	or	a5,a5,a4
ffffffffc0205d14:	18079073          	csrw	satp,a5
ffffffffc0205d18:	12000073          	sfence.vma
ffffffffc0205d1c:	03050593          	addi	a1,a0,48
ffffffffc0205d20:	03068513          	addi	a0,a3,48
ffffffffc0205d24:	57e010ef          	jal	ffffffffc02072a2 <switch_to>
ffffffffc0205d28:	6602                	ld	a2,0(sp)
ffffffffc0205d2a:	e601                	bnez	a2,ffffffffc0205d32 <proc_run+0x4c>
ffffffffc0205d2c:	60e2                	ld	ra,24(sp)
ffffffffc0205d2e:	6105                	addi	sp,sp,32
ffffffffc0205d30:	8082                	ret
ffffffffc0205d32:	60e2                	ld	ra,24(sp)
ffffffffc0205d34:	6105                	addi	sp,sp,32
ffffffffc0205d36:	e9dfa06f          	j	ffffffffc0200bd2 <intr_enable>
ffffffffc0205d3a:	8082                	ret
ffffffffc0205d3c:	e42a                	sd	a0,8(sp)
ffffffffc0205d3e:	e036                	sd	a3,0(sp)
ffffffffc0205d40:	e99fa0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0205d44:	6522                	ld	a0,8(sp)
ffffffffc0205d46:	6682                	ld	a3,0(sp)
ffffffffc0205d48:	4605                	li	a2,1
ffffffffc0205d4a:	bf5d                	j	ffffffffc0205d00 <proc_run+0x1a>

ffffffffc0205d4c <do_fork>:
ffffffffc0205d4c:	00091717          	auipc	a4,0x91
ffffffffc0205d50:	b7472703          	lw	a4,-1164(a4) # ffffffffc02968c0 <nr_process>
ffffffffc0205d54:	6785                	lui	a5,0x1
ffffffffc0205d56:	36f75b63          	bge	a4,a5,ffffffffc02060cc <do_fork+0x380>
ffffffffc0205d5a:	7119                	addi	sp,sp,-128
ffffffffc0205d5c:	f8a2                	sd	s0,112(sp)
ffffffffc0205d5e:	f4a6                	sd	s1,104(sp)
ffffffffc0205d60:	f0ca                	sd	s2,96(sp)
ffffffffc0205d62:	ecce                	sd	s3,88(sp)
ffffffffc0205d64:	fc86                	sd	ra,120(sp)
ffffffffc0205d66:	892e                	mv	s2,a1
ffffffffc0205d68:	84b2                	mv	s1,a2
ffffffffc0205d6a:	89aa                	mv	s3,a0
ffffffffc0205d6c:	d57ff0ef          	jal	ffffffffc0205ac2 <alloc_proc>
ffffffffc0205d70:	842a                	mv	s0,a0
ffffffffc0205d72:	2a050863          	beqz	a0,ffffffffc0206022 <do_fork+0x2d6>
ffffffffc0205d76:	f466                	sd	s9,40(sp)
ffffffffc0205d78:	00091c97          	auipc	s9,0x91
ffffffffc0205d7c:	b50c8c93          	addi	s9,s9,-1200 # ffffffffc02968c8 <current>
ffffffffc0205d80:	000cb783          	ld	a5,0(s9)
ffffffffc0205d84:	0ec7a703          	lw	a4,236(a5) # 10ec <_binary_bin_swap_img_size-0x6c14>
ffffffffc0205d88:	f11c                	sd	a5,32(a0)
ffffffffc0205d8a:	3a071363          	bnez	a4,ffffffffc0206130 <do_fork+0x3e4>
ffffffffc0205d8e:	4509                	li	a0,2
ffffffffc0205d90:	bf4fc0ef          	jal	ffffffffc0202184 <alloc_pages>
ffffffffc0205d94:	28050363          	beqz	a0,ffffffffc020601a <do_fork+0x2ce>
ffffffffc0205d98:	e4d6                	sd	s5,72(sp)
ffffffffc0205d9a:	00091a97          	auipc	s5,0x91
ffffffffc0205d9e:	b1ea8a93          	addi	s5,s5,-1250 # ffffffffc02968b8 <pages>
ffffffffc0205da2:	000ab783          	ld	a5,0(s5)
ffffffffc0205da6:	e8d2                	sd	s4,80(sp)
ffffffffc0205da8:	0000aa17          	auipc	s4,0xa
ffffffffc0205dac:	db0a3a03          	ld	s4,-592(s4) # ffffffffc020fb58 <nbase>
ffffffffc0205db0:	40f506b3          	sub	a3,a0,a5
ffffffffc0205db4:	e0da                	sd	s6,64(sp)
ffffffffc0205db6:	8699                	srai	a3,a3,0x6
ffffffffc0205db8:	00091b17          	auipc	s6,0x91
ffffffffc0205dbc:	af8b0b13          	addi	s6,s6,-1288 # ffffffffc02968b0 <npage>
ffffffffc0205dc0:	96d2                	add	a3,a3,s4
ffffffffc0205dc2:	000b3703          	ld	a4,0(s6)
ffffffffc0205dc6:	00c69793          	slli	a5,a3,0xc
ffffffffc0205dca:	fc5e                	sd	s7,56(sp)
ffffffffc0205dcc:	f862                	sd	s8,48(sp)
ffffffffc0205dce:	83b1                	srli	a5,a5,0xc
ffffffffc0205dd0:	06b2                	slli	a3,a3,0xc
ffffffffc0205dd2:	34e7f163          	bgeu	a5,a4,ffffffffc0206114 <do_fork+0x3c8>
ffffffffc0205dd6:	000cb703          	ld	a4,0(s9)
ffffffffc0205dda:	00091c17          	auipc	s8,0x91
ffffffffc0205dde:	acec0c13          	addi	s8,s8,-1330 # ffffffffc02968a8 <va_pa_offset>
ffffffffc0205de2:	000c3783          	ld	a5,0(s8)
ffffffffc0205de6:	02873b83          	ld	s7,40(a4)
ffffffffc0205dea:	97b6                	add	a5,a5,a3
ffffffffc0205dec:	e81c                	sd	a5,16(s0)
ffffffffc0205dee:	020b8963          	beqz	s7,ffffffffc0205e20 <do_fork+0xd4>
ffffffffc0205df2:	1009f793          	andi	a5,s3,256
ffffffffc0205df6:	1c078963          	beqz	a5,ffffffffc0205fc8 <do_fork+0x27c>
ffffffffc0205dfa:	030ba783          	lw	a5,48(s7) # 1030 <_binary_bin_swap_img_size-0x6cd0>
ffffffffc0205dfe:	018bb683          	ld	a3,24(s7)
ffffffffc0205e02:	c0200737          	lui	a4,0xc0200
ffffffffc0205e06:	2785                	addiw	a5,a5,1
ffffffffc0205e08:	02fba823          	sw	a5,48(s7)
ffffffffc0205e0c:	03743423          	sd	s7,40(s0)
ffffffffc0205e10:	2ee6e463          	bltu	a3,a4,ffffffffc02060f8 <do_fork+0x3ac>
ffffffffc0205e14:	000c3783          	ld	a5,0(s8)
ffffffffc0205e18:	000cb703          	ld	a4,0(s9)
ffffffffc0205e1c:	8e9d                	sub	a3,a3,a5
ffffffffc0205e1e:	f454                	sd	a3,168(s0)
ffffffffc0205e20:	14873b83          	ld	s7,328(a4) # ffffffffc0200148 <readline+0x96>
ffffffffc0205e24:	2a0b8863          	beqz	s7,ffffffffc02060d4 <do_fork+0x388>
ffffffffc0205e28:	03499793          	slli	a5,s3,0x34
ffffffffc0205e2c:	1807d063          	bgez	a5,ffffffffc0205fac <do_fork+0x260>
ffffffffc0205e30:	010ba683          	lw	a3,16(s7)
ffffffffc0205e34:	681c                	ld	a5,16(s0)
ffffffffc0205e36:	6709                	lui	a4,0x2
ffffffffc0205e38:	2685                	addiw	a3,a3,1
ffffffffc0205e3a:	ee070713          	addi	a4,a4,-288 # 1ee0 <_binary_bin_swap_img_size-0x5e20>
ffffffffc0205e3e:	00dba823          	sw	a3,16(s7)
ffffffffc0205e42:	97ba                	add	a5,a5,a4
ffffffffc0205e44:	8626                	mv	a2,s1
ffffffffc0205e46:	15743423          	sd	s7,328(s0)
ffffffffc0205e4a:	f05c                	sd	a5,160(s0)
ffffffffc0205e4c:	873e                	mv	a4,a5
ffffffffc0205e4e:	12048693          	addi	a3,s1,288
ffffffffc0205e52:	6a0c                	ld	a1,16(a2)
ffffffffc0205e54:	00063803          	ld	a6,0(a2)
ffffffffc0205e58:	6608                	ld	a0,8(a2)
ffffffffc0205e5a:	eb0c                	sd	a1,16(a4)
ffffffffc0205e5c:	01073023          	sd	a6,0(a4)
ffffffffc0205e60:	e708                	sd	a0,8(a4)
ffffffffc0205e62:	6e0c                	ld	a1,24(a2)
ffffffffc0205e64:	02060613          	addi	a2,a2,32
ffffffffc0205e68:	02070713          	addi	a4,a4,32
ffffffffc0205e6c:	feb73c23          	sd	a1,-8(a4)
ffffffffc0205e70:	fed611e3          	bne	a2,a3,ffffffffc0205e52 <do_fork+0x106>
ffffffffc0205e74:	0407b823          	sd	zero,80(a5)
ffffffffc0205e78:	1a090763          	beqz	s2,ffffffffc0206026 <do_fork+0x2da>
ffffffffc0205e7c:	0127b823          	sd	s2,16(a5)
ffffffffc0205e80:	fc1c                	sd	a5,56(s0)
ffffffffc0205e82:	00000797          	auipc	a5,0x0
ffffffffc0205e86:	d5a78793          	addi	a5,a5,-678 # ffffffffc0205bdc <forkret>
ffffffffc0205e8a:	f81c                	sd	a5,48(s0)
ffffffffc0205e8c:	100027f3          	csrr	a5,sstatus
ffffffffc0205e90:	8b89                	andi	a5,a5,2
ffffffffc0205e92:	4901                	li	s2,0
ffffffffc0205e94:	1a079863          	bnez	a5,ffffffffc0206044 <do_fork+0x2f8>
ffffffffc0205e98:	0008b517          	auipc	a0,0x8b
ffffffffc0205e9c:	1c452503          	lw	a0,452(a0) # ffffffffc029105c <last_pid.1>
ffffffffc0205ea0:	6789                	lui	a5,0x2
ffffffffc0205ea2:	2505                	addiw	a0,a0,1
ffffffffc0205ea4:	0008b717          	auipc	a4,0x8b
ffffffffc0205ea8:	1aa72c23          	sw	a0,440(a4) # ffffffffc029105c <last_pid.1>
ffffffffc0205eac:	1af55b63          	bge	a0,a5,ffffffffc0206062 <do_fork+0x316>
ffffffffc0205eb0:	0008b797          	auipc	a5,0x8b
ffffffffc0205eb4:	1a87a783          	lw	a5,424(a5) # ffffffffc0291058 <next_safe.0>
ffffffffc0205eb8:	00090497          	auipc	s1,0x90
ffffffffc0205ebc:	90848493          	addi	s1,s1,-1784 # ffffffffc02957c0 <proc_list>
ffffffffc0205ec0:	06f54563          	blt	a0,a5,ffffffffc0205f2a <do_fork+0x1de>
ffffffffc0205ec4:	00090497          	auipc	s1,0x90
ffffffffc0205ec8:	8fc48493          	addi	s1,s1,-1796 # ffffffffc02957c0 <proc_list>
ffffffffc0205ecc:	0084b883          	ld	a7,8(s1)
ffffffffc0205ed0:	6789                	lui	a5,0x2
ffffffffc0205ed2:	0008b717          	auipc	a4,0x8b
ffffffffc0205ed6:	18f72323          	sw	a5,390(a4) # ffffffffc0291058 <next_safe.0>
ffffffffc0205eda:	86aa                	mv	a3,a0
ffffffffc0205edc:	4581                	li	a1,0
ffffffffc0205ede:	04988063          	beq	a7,s1,ffffffffc0205f1e <do_fork+0x1d2>
ffffffffc0205ee2:	882e                	mv	a6,a1
ffffffffc0205ee4:	87c6                	mv	a5,a7
ffffffffc0205ee6:	6609                	lui	a2,0x2
ffffffffc0205ee8:	a811                	j	ffffffffc0205efc <do_fork+0x1b0>
ffffffffc0205eea:	00e6d663          	bge	a3,a4,ffffffffc0205ef6 <do_fork+0x1aa>
ffffffffc0205eee:	00c75463          	bge	a4,a2,ffffffffc0205ef6 <do_fork+0x1aa>
ffffffffc0205ef2:	863a                	mv	a2,a4
ffffffffc0205ef4:	4805                	li	a6,1
ffffffffc0205ef6:	679c                	ld	a5,8(a5)
ffffffffc0205ef8:	00978d63          	beq	a5,s1,ffffffffc0205f12 <do_fork+0x1c6>
ffffffffc0205efc:	f3c7a703          	lw	a4,-196(a5) # 1f3c <_binary_bin_swap_img_size-0x5dc4>
ffffffffc0205f00:	fed715e3          	bne	a4,a3,ffffffffc0205eea <do_fork+0x19e>
ffffffffc0205f04:	2685                	addiw	a3,a3,1
ffffffffc0205f06:	1ac6d463          	bge	a3,a2,ffffffffc02060ae <do_fork+0x362>
ffffffffc0205f0a:	679c                	ld	a5,8(a5)
ffffffffc0205f0c:	4585                	li	a1,1
ffffffffc0205f0e:	fe9797e3          	bne	a5,s1,ffffffffc0205efc <do_fork+0x1b0>
ffffffffc0205f12:	00080663          	beqz	a6,ffffffffc0205f1e <do_fork+0x1d2>
ffffffffc0205f16:	0008b797          	auipc	a5,0x8b
ffffffffc0205f1a:	14c7a123          	sw	a2,322(a5) # ffffffffc0291058 <next_safe.0>
ffffffffc0205f1e:	c591                	beqz	a1,ffffffffc0205f2a <do_fork+0x1de>
ffffffffc0205f20:	0008b797          	auipc	a5,0x8b
ffffffffc0205f24:	12d7ae23          	sw	a3,316(a5) # ffffffffc029105c <last_pid.1>
ffffffffc0205f28:	8536                	mv	a0,a3
ffffffffc0205f2a:	c048                	sw	a0,4(s0)
ffffffffc0205f2c:	45a9                	li	a1,10
ffffffffc0205f2e:	38e050ef          	jal	ffffffffc020b2bc <hash32>
ffffffffc0205f32:	02051793          	slli	a5,a0,0x20
ffffffffc0205f36:	01c7d513          	srli	a0,a5,0x1c
ffffffffc0205f3a:	0008c797          	auipc	a5,0x8c
ffffffffc0205f3e:	88678793          	addi	a5,a5,-1914 # ffffffffc02917c0 <hash_list>
ffffffffc0205f42:	953e                	add	a0,a0,a5
ffffffffc0205f44:	6518                	ld	a4,8(a0)
ffffffffc0205f46:	0d840793          	addi	a5,s0,216
ffffffffc0205f4a:	6490                	ld	a2,8(s1)
ffffffffc0205f4c:	e31c                	sd	a5,0(a4)
ffffffffc0205f4e:	e51c                	sd	a5,8(a0)
ffffffffc0205f50:	f078                	sd	a4,224(s0)
ffffffffc0205f52:	0c840793          	addi	a5,s0,200
ffffffffc0205f56:	7018                	ld	a4,32(s0)
ffffffffc0205f58:	ec68                	sd	a0,216(s0)
ffffffffc0205f5a:	e21c                	sd	a5,0(a2)
ffffffffc0205f5c:	0e043c23          	sd	zero,248(s0)
ffffffffc0205f60:	7b74                	ld	a3,240(a4)
ffffffffc0205f62:	e49c                	sd	a5,8(s1)
ffffffffc0205f64:	e870                	sd	a2,208(s0)
ffffffffc0205f66:	e464                	sd	s1,200(s0)
ffffffffc0205f68:	10d43023          	sd	a3,256(s0)
ffffffffc0205f6c:	c299                	beqz	a3,ffffffffc0205f72 <do_fork+0x226>
ffffffffc0205f6e:	fee0                	sd	s0,248(a3)
ffffffffc0205f70:	7018                	ld	a4,32(s0)
ffffffffc0205f72:	00091797          	auipc	a5,0x91
ffffffffc0205f76:	94e7a783          	lw	a5,-1714(a5) # ffffffffc02968c0 <nr_process>
ffffffffc0205f7a:	fb60                	sd	s0,240(a4)
ffffffffc0205f7c:	2785                	addiw	a5,a5,1
ffffffffc0205f7e:	00091717          	auipc	a4,0x91
ffffffffc0205f82:	94f72123          	sw	a5,-1726(a4) # ffffffffc02968c0 <nr_process>
ffffffffc0205f86:	0e091463          	bnez	s2,ffffffffc020606e <do_fork+0x322>
ffffffffc0205f8a:	8522                	mv	a0,s0
ffffffffc0205f8c:	4ba010ef          	jal	ffffffffc0207446 <wakeup_proc>
ffffffffc0205f90:	4048                	lw	a0,4(s0)
ffffffffc0205f92:	6a46                	ld	s4,80(sp)
ffffffffc0205f94:	6aa6                	ld	s5,72(sp)
ffffffffc0205f96:	6b06                	ld	s6,64(sp)
ffffffffc0205f98:	7be2                	ld	s7,56(sp)
ffffffffc0205f9a:	7c42                	ld	s8,48(sp)
ffffffffc0205f9c:	7ca2                	ld	s9,40(sp)
ffffffffc0205f9e:	70e6                	ld	ra,120(sp)
ffffffffc0205fa0:	7446                	ld	s0,112(sp)
ffffffffc0205fa2:	74a6                	ld	s1,104(sp)
ffffffffc0205fa4:	7906                	ld	s2,96(sp)
ffffffffc0205fa6:	69e6                	ld	s3,88(sp)
ffffffffc0205fa8:	6109                	addi	sp,sp,128
ffffffffc0205faa:	8082                	ret
ffffffffc0205fac:	accff0ef          	jal	ffffffffc0205278 <files_create>
ffffffffc0205fb0:	89aa                	mv	s3,a0
ffffffffc0205fb2:	c905                	beqz	a0,ffffffffc0205fe2 <do_fork+0x296>
ffffffffc0205fb4:	85de                	mv	a1,s7
ffffffffc0205fb6:	bfaff0ef          	jal	ffffffffc02053b0 <dup_files>
ffffffffc0205fba:	8bce                	mv	s7,s3
ffffffffc0205fbc:	e6050ae3          	beqz	a0,ffffffffc0205e30 <do_fork+0xe4>
ffffffffc0205fc0:	854e                	mv	a0,s3
ffffffffc0205fc2:	aecff0ef          	jal	ffffffffc02052ae <files_destroy>
ffffffffc0205fc6:	a831                	j	ffffffffc0205fe2 <do_fork+0x296>
ffffffffc0205fc8:	f06a                	sd	s10,32(sp)
ffffffffc0205fca:	cadfd0ef          	jal	ffffffffc0203c76 <mm_create>
ffffffffc0205fce:	8d2a                	mv	s10,a0
ffffffffc0205fd0:	10050063          	beqz	a0,ffffffffc02060d0 <do_fork+0x384>
ffffffffc0205fd4:	c8fff0ef          	jal	ffffffffc0205c62 <setup_pgdir>
ffffffffc0205fd8:	cd51                	beqz	a0,ffffffffc0206074 <do_fork+0x328>
ffffffffc0205fda:	856a                	mv	a0,s10
ffffffffc0205fdc:	de7fd0ef          	jal	ffffffffc0203dc2 <mm_destroy>
ffffffffc0205fe0:	7d02                	ld	s10,32(sp)
ffffffffc0205fe2:	6814                	ld	a3,16(s0)
ffffffffc0205fe4:	c02007b7          	lui	a5,0xc0200
ffffffffc0205fe8:	16f6eb63          	bltu	a3,a5,ffffffffc020615e <do_fork+0x412>
ffffffffc0205fec:	000c3783          	ld	a5,0(s8)
ffffffffc0205ff0:	000b3703          	ld	a4,0(s6)
ffffffffc0205ff4:	40f687b3          	sub	a5,a3,a5
ffffffffc0205ff8:	83b1                	srli	a5,a5,0xc
ffffffffc0205ffa:	18e7f063          	bgeu	a5,a4,ffffffffc020617a <do_fork+0x42e>
ffffffffc0205ffe:	000ab503          	ld	a0,0(s5)
ffffffffc0206002:	414787b3          	sub	a5,a5,s4
ffffffffc0206006:	079a                	slli	a5,a5,0x6
ffffffffc0206008:	953e                	add	a0,a0,a5
ffffffffc020600a:	4589                	li	a1,2
ffffffffc020600c:	9b2fc0ef          	jal	ffffffffc02021be <free_pages>
ffffffffc0206010:	6a46                	ld	s4,80(sp)
ffffffffc0206012:	6aa6                	ld	s5,72(sp)
ffffffffc0206014:	6b06                	ld	s6,64(sp)
ffffffffc0206016:	7be2                	ld	s7,56(sp)
ffffffffc0206018:	7c42                	ld	s8,48(sp)
ffffffffc020601a:	8522                	mv	a0,s0
ffffffffc020601c:	84afc0ef          	jal	ffffffffc0202066 <kfree>
ffffffffc0206020:	7ca2                	ld	s9,40(sp)
ffffffffc0206022:	5571                	li	a0,-4
ffffffffc0206024:	bfad                	j	ffffffffc0205f9e <do_fork+0x252>
ffffffffc0206026:	893e                	mv	s2,a5
ffffffffc0206028:	0127b823          	sd	s2,16(a5) # ffffffffc0200010 <kern_entry+0x10>
ffffffffc020602c:	fc1c                	sd	a5,56(s0)
ffffffffc020602e:	00000797          	auipc	a5,0x0
ffffffffc0206032:	bae78793          	addi	a5,a5,-1106 # ffffffffc0205bdc <forkret>
ffffffffc0206036:	f81c                	sd	a5,48(s0)
ffffffffc0206038:	100027f3          	csrr	a5,sstatus
ffffffffc020603c:	8b89                	andi	a5,a5,2
ffffffffc020603e:	4901                	li	s2,0
ffffffffc0206040:	e4078ce3          	beqz	a5,ffffffffc0205e98 <do_fork+0x14c>
ffffffffc0206044:	b95fa0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0206048:	0008b517          	auipc	a0,0x8b
ffffffffc020604c:	01452503          	lw	a0,20(a0) # ffffffffc029105c <last_pid.1>
ffffffffc0206050:	6789                	lui	a5,0x2
ffffffffc0206052:	4905                	li	s2,1
ffffffffc0206054:	2505                	addiw	a0,a0,1
ffffffffc0206056:	0008b717          	auipc	a4,0x8b
ffffffffc020605a:	00a72323          	sw	a0,6(a4) # ffffffffc029105c <last_pid.1>
ffffffffc020605e:	e4f549e3          	blt	a0,a5,ffffffffc0205eb0 <do_fork+0x164>
ffffffffc0206062:	4505                	li	a0,1
ffffffffc0206064:	0008b797          	auipc	a5,0x8b
ffffffffc0206068:	fea7ac23          	sw	a0,-8(a5) # ffffffffc029105c <last_pid.1>
ffffffffc020606c:	bda1                	j	ffffffffc0205ec4 <do_fork+0x178>
ffffffffc020606e:	b65fa0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0206072:	bf21                	j	ffffffffc0205f8a <do_fork+0x23e>
ffffffffc0206074:	038b8793          	addi	a5,s7,56
ffffffffc0206078:	853e                	mv	a0,a5
ffffffffc020607a:	e43e                	sd	a5,8(sp)
ffffffffc020607c:	ec6e                	sd	s11,24(sp)
ffffffffc020607e:	d78fe0ef          	jal	ffffffffc02045f6 <down>
ffffffffc0206082:	000cb783          	ld	a5,0(s9)
ffffffffc0206086:	c781                	beqz	a5,ffffffffc020608e <do_fork+0x342>
ffffffffc0206088:	43dc                	lw	a5,4(a5)
ffffffffc020608a:	04fba823          	sw	a5,80(s7)
ffffffffc020608e:	85de                	mv	a1,s7
ffffffffc0206090:	856a                	mv	a0,s10
ffffffffc0206092:	e4ffd0ef          	jal	ffffffffc0203ee0 <dup_mmap>
ffffffffc0206096:	8daa                	mv	s11,a0
ffffffffc0206098:	6522                	ld	a0,8(sp)
ffffffffc020609a:	d58fe0ef          	jal	ffffffffc02045f2 <up>
ffffffffc020609e:	040ba823          	sw	zero,80(s7)
ffffffffc02060a2:	8bea                	mv	s7,s10
ffffffffc02060a4:	000d9b63          	bnez	s11,ffffffffc02060ba <do_fork+0x36e>
ffffffffc02060a8:	7d02                	ld	s10,32(sp)
ffffffffc02060aa:	6de2                	ld	s11,24(sp)
ffffffffc02060ac:	b3b9                	j	ffffffffc0205dfa <do_fork+0xae>
ffffffffc02060ae:	6789                	lui	a5,0x2
ffffffffc02060b0:	00f6c363          	blt	a3,a5,ffffffffc02060b6 <do_fork+0x36a>
ffffffffc02060b4:	4685                	li	a3,1
ffffffffc02060b6:	4585                	li	a1,1
ffffffffc02060b8:	b51d                	j	ffffffffc0205ede <do_fork+0x192>
ffffffffc02060ba:	856a                	mv	a0,s10
ffffffffc02060bc:	ebdfd0ef          	jal	ffffffffc0203f78 <exit_mmap>
ffffffffc02060c0:	018d3503          	ld	a0,24(s10) # fffffffffff80018 <end+0x3fce9708>
ffffffffc02060c4:	b27ff0ef          	jal	ffffffffc0205bea <put_pgdir.isra.0>
ffffffffc02060c8:	6de2                	ld	s11,24(sp)
ffffffffc02060ca:	bf01                	j	ffffffffc0205fda <do_fork+0x28e>
ffffffffc02060cc:	556d                	li	a0,-5
ffffffffc02060ce:	8082                	ret
ffffffffc02060d0:	7d02                	ld	s10,32(sp)
ffffffffc02060d2:	bf01                	j	ffffffffc0205fe2 <do_fork+0x296>
ffffffffc02060d4:	00007697          	auipc	a3,0x7
ffffffffc02060d8:	62468693          	addi	a3,a3,1572 # ffffffffc020d6f8 <etext+0x1e98>
ffffffffc02060dc:	00006617          	auipc	a2,0x6
ffffffffc02060e0:	bbc60613          	addi	a2,a2,-1092 # ffffffffc020bc98 <etext+0x438>
ffffffffc02060e4:	1e400593          	li	a1,484
ffffffffc02060e8:	00007517          	auipc	a0,0x7
ffffffffc02060ec:	5f850513          	addi	a0,a0,1528 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc02060f0:	f06a                	sd	s10,32(sp)
ffffffffc02060f2:	ec6e                	sd	s11,24(sp)
ffffffffc02060f4:	b56fa0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02060f8:	00006617          	auipc	a2,0x6
ffffffffc02060fc:	6c060613          	addi	a2,a2,1728 # ffffffffc020c7b8 <etext+0xf58>
ffffffffc0206100:	1c400593          	li	a1,452
ffffffffc0206104:	00007517          	auipc	a0,0x7
ffffffffc0206108:	5dc50513          	addi	a0,a0,1500 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc020610c:	f06a                	sd	s10,32(sp)
ffffffffc020610e:	ec6e                	sd	s11,24(sp)
ffffffffc0206110:	b3afa0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0206114:	00006617          	auipc	a2,0x6
ffffffffc0206118:	5fc60613          	addi	a2,a2,1532 # ffffffffc020c710 <etext+0xeb0>
ffffffffc020611c:	07100593          	li	a1,113
ffffffffc0206120:	00006517          	auipc	a0,0x6
ffffffffc0206124:	61850513          	addi	a0,a0,1560 # ffffffffc020c738 <etext+0xed8>
ffffffffc0206128:	f06a                	sd	s10,32(sp)
ffffffffc020612a:	ec6e                	sd	s11,24(sp)
ffffffffc020612c:	b1efa0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0206130:	00007697          	auipc	a3,0x7
ffffffffc0206134:	59068693          	addi	a3,a3,1424 # ffffffffc020d6c0 <etext+0x1e60>
ffffffffc0206138:	00006617          	auipc	a2,0x6
ffffffffc020613c:	b6060613          	addi	a2,a2,-1184 # ffffffffc020bc98 <etext+0x438>
ffffffffc0206140:	23d00593          	li	a1,573
ffffffffc0206144:	00007517          	auipc	a0,0x7
ffffffffc0206148:	59c50513          	addi	a0,a0,1436 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc020614c:	e8d2                	sd	s4,80(sp)
ffffffffc020614e:	e4d6                	sd	s5,72(sp)
ffffffffc0206150:	e0da                	sd	s6,64(sp)
ffffffffc0206152:	fc5e                	sd	s7,56(sp)
ffffffffc0206154:	f862                	sd	s8,48(sp)
ffffffffc0206156:	f06a                	sd	s10,32(sp)
ffffffffc0206158:	ec6e                	sd	s11,24(sp)
ffffffffc020615a:	af0fa0ef          	jal	ffffffffc020044a <__panic>
ffffffffc020615e:	00006617          	auipc	a2,0x6
ffffffffc0206162:	65a60613          	addi	a2,a2,1626 # ffffffffc020c7b8 <etext+0xf58>
ffffffffc0206166:	07700593          	li	a1,119
ffffffffc020616a:	00006517          	auipc	a0,0x6
ffffffffc020616e:	5ce50513          	addi	a0,a0,1486 # ffffffffc020c738 <etext+0xed8>
ffffffffc0206172:	f06a                	sd	s10,32(sp)
ffffffffc0206174:	ec6e                	sd	s11,24(sp)
ffffffffc0206176:	ad4fa0ef          	jal	ffffffffc020044a <__panic>
ffffffffc020617a:	00006617          	auipc	a2,0x6
ffffffffc020617e:	66660613          	addi	a2,a2,1638 # ffffffffc020c7e0 <etext+0xf80>
ffffffffc0206182:	06900593          	li	a1,105
ffffffffc0206186:	00006517          	auipc	a0,0x6
ffffffffc020618a:	5b250513          	addi	a0,a0,1458 # ffffffffc020c738 <etext+0xed8>
ffffffffc020618e:	f06a                	sd	s10,32(sp)
ffffffffc0206190:	ec6e                	sd	s11,24(sp)
ffffffffc0206192:	ab8fa0ef          	jal	ffffffffc020044a <__panic>

ffffffffc0206196 <kernel_thread>:
ffffffffc0206196:	7129                	addi	sp,sp,-320
ffffffffc0206198:	fa22                	sd	s0,304(sp)
ffffffffc020619a:	f626                	sd	s1,296(sp)
ffffffffc020619c:	f24a                	sd	s2,288(sp)
ffffffffc020619e:	842a                	mv	s0,a0
ffffffffc02061a0:	84ae                	mv	s1,a1
ffffffffc02061a2:	8932                	mv	s2,a2
ffffffffc02061a4:	850a                	mv	a0,sp
ffffffffc02061a6:	12000613          	li	a2,288
ffffffffc02061aa:	4581                	li	a1,0
ffffffffc02061ac:	fe06                	sd	ra,312(sp)
ffffffffc02061ae:	64a050ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc02061b2:	e0a2                	sd	s0,64(sp)
ffffffffc02061b4:	e4a6                	sd	s1,72(sp)
ffffffffc02061b6:	100027f3          	csrr	a5,sstatus
ffffffffc02061ba:	edd7f793          	andi	a5,a5,-291
ffffffffc02061be:	1207e793          	ori	a5,a5,288
ffffffffc02061c2:	860a                	mv	a2,sp
ffffffffc02061c4:	10096513          	ori	a0,s2,256
ffffffffc02061c8:	00000717          	auipc	a4,0x0
ffffffffc02061cc:	8f270713          	addi	a4,a4,-1806 # ffffffffc0205aba <kernel_thread_entry>
ffffffffc02061d0:	4581                	li	a1,0
ffffffffc02061d2:	e23e                	sd	a5,256(sp)
ffffffffc02061d4:	e63a                	sd	a4,264(sp)
ffffffffc02061d6:	b77ff0ef          	jal	ffffffffc0205d4c <do_fork>
ffffffffc02061da:	70f2                	ld	ra,312(sp)
ffffffffc02061dc:	7452                	ld	s0,304(sp)
ffffffffc02061de:	74b2                	ld	s1,296(sp)
ffffffffc02061e0:	7912                	ld	s2,288(sp)
ffffffffc02061e2:	6131                	addi	sp,sp,320
ffffffffc02061e4:	8082                	ret

ffffffffc02061e6 <do_exit>:
ffffffffc02061e6:	7179                	addi	sp,sp,-48
ffffffffc02061e8:	f022                	sd	s0,32(sp)
ffffffffc02061ea:	00090417          	auipc	s0,0x90
ffffffffc02061ee:	6de40413          	addi	s0,s0,1758 # ffffffffc02968c8 <current>
ffffffffc02061f2:	601c                	ld	a5,0(s0)
ffffffffc02061f4:	00090717          	auipc	a4,0x90
ffffffffc02061f8:	6e473703          	ld	a4,1764(a4) # ffffffffc02968d8 <idleproc>
ffffffffc02061fc:	f406                	sd	ra,40(sp)
ffffffffc02061fe:	ec26                	sd	s1,24(sp)
ffffffffc0206200:	0ee78763          	beq	a5,a4,ffffffffc02062ee <do_exit+0x108>
ffffffffc0206204:	00090497          	auipc	s1,0x90
ffffffffc0206208:	6cc48493          	addi	s1,s1,1740 # ffffffffc02968d0 <initproc>
ffffffffc020620c:	6098                	ld	a4,0(s1)
ffffffffc020620e:	e84a                	sd	s2,16(sp)
ffffffffc0206210:	10e78863          	beq	a5,a4,ffffffffc0206320 <do_exit+0x13a>
ffffffffc0206214:	7798                	ld	a4,40(a5)
ffffffffc0206216:	892a                	mv	s2,a0
ffffffffc0206218:	cb0d                	beqz	a4,ffffffffc020624a <do_exit+0x64>
ffffffffc020621a:	00090797          	auipc	a5,0x90
ffffffffc020621e:	67e7b783          	ld	a5,1662(a5) # ffffffffc0296898 <boot_pgdir_pa>
ffffffffc0206222:	56fd                	li	a3,-1
ffffffffc0206224:	16fe                	slli	a3,a3,0x3f
ffffffffc0206226:	83b1                	srli	a5,a5,0xc
ffffffffc0206228:	8fd5                	or	a5,a5,a3
ffffffffc020622a:	18079073          	csrw	satp,a5
ffffffffc020622e:	5b1c                	lw	a5,48(a4)
ffffffffc0206230:	37fd                	addiw	a5,a5,-1
ffffffffc0206232:	db1c                	sw	a5,48(a4)
ffffffffc0206234:	cbf1                	beqz	a5,ffffffffc0206308 <do_exit+0x122>
ffffffffc0206236:	601c                	ld	a5,0(s0)
ffffffffc0206238:	1487b503          	ld	a0,328(a5)
ffffffffc020623c:	0207b423          	sd	zero,40(a5)
ffffffffc0206240:	c509                	beqz	a0,ffffffffc020624a <do_exit+0x64>
ffffffffc0206242:	491c                	lw	a5,16(a0)
ffffffffc0206244:	37fd                	addiw	a5,a5,-1
ffffffffc0206246:	c91c                	sw	a5,16(a0)
ffffffffc0206248:	c3c5                	beqz	a5,ffffffffc02062e8 <do_exit+0x102>
ffffffffc020624a:	601c                	ld	a5,0(s0)
ffffffffc020624c:	470d                	li	a4,3
ffffffffc020624e:	0f27a423          	sw	s2,232(a5)
ffffffffc0206252:	c398                	sw	a4,0(a5)
ffffffffc0206254:	100027f3          	csrr	a5,sstatus
ffffffffc0206258:	8b89                	andi	a5,a5,2
ffffffffc020625a:	4901                	li	s2,0
ffffffffc020625c:	0c079e63          	bnez	a5,ffffffffc0206338 <do_exit+0x152>
ffffffffc0206260:	6018                	ld	a4,0(s0)
ffffffffc0206262:	800007b7          	lui	a5,0x80000
ffffffffc0206266:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_bin_sfs_img_size+0xffffffff7ff8ad01>
ffffffffc0206268:	7308                	ld	a0,32(a4)
ffffffffc020626a:	0ec52703          	lw	a4,236(a0)
ffffffffc020626e:	0cf70963          	beq	a4,a5,ffffffffc0206340 <do_exit+0x15a>
ffffffffc0206272:	6018                	ld	a4,0(s0)
ffffffffc0206274:	7b7c                	ld	a5,240(a4)
ffffffffc0206276:	c7a1                	beqz	a5,ffffffffc02062be <do_exit+0xd8>
ffffffffc0206278:	800005b7          	lui	a1,0x80000
ffffffffc020627c:	0585                	addi	a1,a1,1 # ffffffff80000001 <_binary_bin_sfs_img_size+0xffffffff7ff8ad01>
ffffffffc020627e:	460d                	li	a2,3
ffffffffc0206280:	a021                	j	ffffffffc0206288 <do_exit+0xa2>
ffffffffc0206282:	6018                	ld	a4,0(s0)
ffffffffc0206284:	7b7c                	ld	a5,240(a4)
ffffffffc0206286:	cf85                	beqz	a5,ffffffffc02062be <do_exit+0xd8>
ffffffffc0206288:	1007b683          	ld	a3,256(a5)
ffffffffc020628c:	6088                	ld	a0,0(s1)
ffffffffc020628e:	fb74                	sd	a3,240(a4)
ffffffffc0206290:	0e07bc23          	sd	zero,248(a5)
ffffffffc0206294:	7978                	ld	a4,240(a0)
ffffffffc0206296:	10e7b023          	sd	a4,256(a5)
ffffffffc020629a:	c311                	beqz	a4,ffffffffc020629e <do_exit+0xb8>
ffffffffc020629c:	ff7c                	sd	a5,248(a4)
ffffffffc020629e:	4398                	lw	a4,0(a5)
ffffffffc02062a0:	f388                	sd	a0,32(a5)
ffffffffc02062a2:	f97c                	sd	a5,240(a0)
ffffffffc02062a4:	fcc71fe3          	bne	a4,a2,ffffffffc0206282 <do_exit+0x9c>
ffffffffc02062a8:	0ec52783          	lw	a5,236(a0)
ffffffffc02062ac:	fcb79be3          	bne	a5,a1,ffffffffc0206282 <do_exit+0x9c>
ffffffffc02062b0:	196010ef          	jal	ffffffffc0207446 <wakeup_proc>
ffffffffc02062b4:	800005b7          	lui	a1,0x80000
ffffffffc02062b8:	0585                	addi	a1,a1,1 # ffffffff80000001 <_binary_bin_sfs_img_size+0xffffffff7ff8ad01>
ffffffffc02062ba:	460d                	li	a2,3
ffffffffc02062bc:	b7d9                	j	ffffffffc0206282 <do_exit+0x9c>
ffffffffc02062be:	02091263          	bnez	s2,ffffffffc02062e2 <do_exit+0xfc>
ffffffffc02062c2:	27c010ef          	jal	ffffffffc020753e <schedule>
ffffffffc02062c6:	601c                	ld	a5,0(s0)
ffffffffc02062c8:	00007617          	auipc	a2,0x7
ffffffffc02062cc:	46860613          	addi	a2,a2,1128 # ffffffffc020d730 <etext+0x1ed0>
ffffffffc02062d0:	2ab00593          	li	a1,683
ffffffffc02062d4:	43d4                	lw	a3,4(a5)
ffffffffc02062d6:	00007517          	auipc	a0,0x7
ffffffffc02062da:	40a50513          	addi	a0,a0,1034 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc02062de:	96cfa0ef          	jal	ffffffffc020044a <__panic>
ffffffffc02062e2:	8f1fa0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc02062e6:	bff1                	j	ffffffffc02062c2 <do_exit+0xdc>
ffffffffc02062e8:	fc7fe0ef          	jal	ffffffffc02052ae <files_destroy>
ffffffffc02062ec:	bfb9                	j	ffffffffc020624a <do_exit+0x64>
ffffffffc02062ee:	00007617          	auipc	a2,0x7
ffffffffc02062f2:	42260613          	addi	a2,a2,1058 # ffffffffc020d710 <etext+0x1eb0>
ffffffffc02062f6:	27600593          	li	a1,630
ffffffffc02062fa:	00007517          	auipc	a0,0x7
ffffffffc02062fe:	3e650513          	addi	a0,a0,998 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc0206302:	e84a                	sd	s2,16(sp)
ffffffffc0206304:	946fa0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0206308:	853a                	mv	a0,a4
ffffffffc020630a:	e43a                	sd	a4,8(sp)
ffffffffc020630c:	c6dfd0ef          	jal	ffffffffc0203f78 <exit_mmap>
ffffffffc0206310:	6722                	ld	a4,8(sp)
ffffffffc0206312:	6f08                	ld	a0,24(a4)
ffffffffc0206314:	8d7ff0ef          	jal	ffffffffc0205bea <put_pgdir.isra.0>
ffffffffc0206318:	6522                	ld	a0,8(sp)
ffffffffc020631a:	aa9fd0ef          	jal	ffffffffc0203dc2 <mm_destroy>
ffffffffc020631e:	bf21                	j	ffffffffc0206236 <do_exit+0x50>
ffffffffc0206320:	00007617          	auipc	a2,0x7
ffffffffc0206324:	40060613          	addi	a2,a2,1024 # ffffffffc020d720 <etext+0x1ec0>
ffffffffc0206328:	27a00593          	li	a1,634
ffffffffc020632c:	00007517          	auipc	a0,0x7
ffffffffc0206330:	3b450513          	addi	a0,a0,948 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc0206334:	916fa0ef          	jal	ffffffffc020044a <__panic>
ffffffffc0206338:	8a1fa0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc020633c:	4905                	li	s2,1
ffffffffc020633e:	b70d                	j	ffffffffc0206260 <do_exit+0x7a>
ffffffffc0206340:	106010ef          	jal	ffffffffc0207446 <wakeup_proc>
ffffffffc0206344:	b73d                	j	ffffffffc0206272 <do_exit+0x8c>

ffffffffc0206346 <do_wait.part.0>:
ffffffffc0206346:	7179                	addi	sp,sp,-48
ffffffffc0206348:	ec26                	sd	s1,24(sp)
ffffffffc020634a:	e84a                	sd	s2,16(sp)
ffffffffc020634c:	e44e                	sd	s3,8(sp)
ffffffffc020634e:	f406                	sd	ra,40(sp)
ffffffffc0206350:	f022                	sd	s0,32(sp)
ffffffffc0206352:	84aa                	mv	s1,a0
ffffffffc0206354:	892e                	mv	s2,a1
ffffffffc0206356:	00090997          	auipc	s3,0x90
ffffffffc020635a:	57298993          	addi	s3,s3,1394 # ffffffffc02968c8 <current>
ffffffffc020635e:	cd19                	beqz	a0,ffffffffc020637c <do_wait.part.0+0x36>
ffffffffc0206360:	6789                	lui	a5,0x2
ffffffffc0206362:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_bin_swap_img_size-0x5d02>
ffffffffc0206364:	fff5071b          	addiw	a4,a0,-1
ffffffffc0206368:	12e7f563          	bgeu	a5,a4,ffffffffc0206492 <do_wait.part.0+0x14c>
ffffffffc020636c:	70a2                	ld	ra,40(sp)
ffffffffc020636e:	7402                	ld	s0,32(sp)
ffffffffc0206370:	64e2                	ld	s1,24(sp)
ffffffffc0206372:	6942                	ld	s2,16(sp)
ffffffffc0206374:	69a2                	ld	s3,8(sp)
ffffffffc0206376:	5579                	li	a0,-2
ffffffffc0206378:	6145                	addi	sp,sp,48
ffffffffc020637a:	8082                	ret
ffffffffc020637c:	0009b703          	ld	a4,0(s3)
ffffffffc0206380:	7b60                	ld	s0,240(a4)
ffffffffc0206382:	d46d                	beqz	s0,ffffffffc020636c <do_wait.part.0+0x26>
ffffffffc0206384:	468d                	li	a3,3
ffffffffc0206386:	a021                	j	ffffffffc020638e <do_wait.part.0+0x48>
ffffffffc0206388:	10043403          	ld	s0,256(s0)
ffffffffc020638c:	c075                	beqz	s0,ffffffffc0206470 <do_wait.part.0+0x12a>
ffffffffc020638e:	401c                	lw	a5,0(s0)
ffffffffc0206390:	fed79ce3          	bne	a5,a3,ffffffffc0206388 <do_wait.part.0+0x42>
ffffffffc0206394:	00090797          	auipc	a5,0x90
ffffffffc0206398:	5447b783          	ld	a5,1348(a5) # ffffffffc02968d8 <idleproc>
ffffffffc020639c:	14878263          	beq	a5,s0,ffffffffc02064e0 <do_wait.part.0+0x19a>
ffffffffc02063a0:	00090797          	auipc	a5,0x90
ffffffffc02063a4:	5307b783          	ld	a5,1328(a5) # ffffffffc02968d0 <initproc>
ffffffffc02063a8:	12f40c63          	beq	s0,a5,ffffffffc02064e0 <do_wait.part.0+0x19a>
ffffffffc02063ac:	00090663          	beqz	s2,ffffffffc02063b8 <do_wait.part.0+0x72>
ffffffffc02063b0:	0e842783          	lw	a5,232(s0)
ffffffffc02063b4:	00f92023          	sw	a5,0(s2)
ffffffffc02063b8:	100027f3          	csrr	a5,sstatus
ffffffffc02063bc:	8b89                	andi	a5,a5,2
ffffffffc02063be:	4601                	li	a2,0
ffffffffc02063c0:	10079963          	bnez	a5,ffffffffc02064d2 <do_wait.part.0+0x18c>
ffffffffc02063c4:	6c74                	ld	a3,216(s0)
ffffffffc02063c6:	7078                	ld	a4,224(s0)
ffffffffc02063c8:	10043783          	ld	a5,256(s0)
ffffffffc02063cc:	e698                	sd	a4,8(a3)
ffffffffc02063ce:	e314                	sd	a3,0(a4)
ffffffffc02063d0:	6474                	ld	a3,200(s0)
ffffffffc02063d2:	6878                	ld	a4,208(s0)
ffffffffc02063d4:	e698                	sd	a4,8(a3)
ffffffffc02063d6:	e314                	sd	a3,0(a4)
ffffffffc02063d8:	c789                	beqz	a5,ffffffffc02063e2 <do_wait.part.0+0x9c>
ffffffffc02063da:	7c78                	ld	a4,248(s0)
ffffffffc02063dc:	fff8                	sd	a4,248(a5)
ffffffffc02063de:	10043783          	ld	a5,256(s0)
ffffffffc02063e2:	7c78                	ld	a4,248(s0)
ffffffffc02063e4:	c36d                	beqz	a4,ffffffffc02064c6 <do_wait.part.0+0x180>
ffffffffc02063e6:	10f73023          	sd	a5,256(a4)
ffffffffc02063ea:	00090797          	auipc	a5,0x90
ffffffffc02063ee:	4d67a783          	lw	a5,1238(a5) # ffffffffc02968c0 <nr_process>
ffffffffc02063f2:	37fd                	addiw	a5,a5,-1
ffffffffc02063f4:	00090717          	auipc	a4,0x90
ffffffffc02063f8:	4cf72623          	sw	a5,1228(a4) # ffffffffc02968c0 <nr_process>
ffffffffc02063fc:	e271                	bnez	a2,ffffffffc02064c0 <do_wait.part.0+0x17a>
ffffffffc02063fe:	6814                	ld	a3,16(s0)
ffffffffc0206400:	c02007b7          	lui	a5,0xc0200
ffffffffc0206404:	10f6e663          	bltu	a3,a5,ffffffffc0206510 <do_wait.part.0+0x1ca>
ffffffffc0206408:	00090717          	auipc	a4,0x90
ffffffffc020640c:	4a073703          	ld	a4,1184(a4) # ffffffffc02968a8 <va_pa_offset>
ffffffffc0206410:	00090797          	auipc	a5,0x90
ffffffffc0206414:	4a07b783          	ld	a5,1184(a5) # ffffffffc02968b0 <npage>
ffffffffc0206418:	8e99                	sub	a3,a3,a4
ffffffffc020641a:	82b1                	srli	a3,a3,0xc
ffffffffc020641c:	0cf6fe63          	bgeu	a3,a5,ffffffffc02064f8 <do_wait.part.0+0x1b2>
ffffffffc0206420:	00009797          	auipc	a5,0x9
ffffffffc0206424:	7387b783          	ld	a5,1848(a5) # ffffffffc020fb58 <nbase>
ffffffffc0206428:	00090517          	auipc	a0,0x90
ffffffffc020642c:	49053503          	ld	a0,1168(a0) # ffffffffc02968b8 <pages>
ffffffffc0206430:	4589                	li	a1,2
ffffffffc0206432:	8e9d                	sub	a3,a3,a5
ffffffffc0206434:	069a                	slli	a3,a3,0x6
ffffffffc0206436:	9536                	add	a0,a0,a3
ffffffffc0206438:	d87fb0ef          	jal	ffffffffc02021be <free_pages>
ffffffffc020643c:	8522                	mv	a0,s0
ffffffffc020643e:	c29fb0ef          	jal	ffffffffc0202066 <kfree>
ffffffffc0206442:	70a2                	ld	ra,40(sp)
ffffffffc0206444:	7402                	ld	s0,32(sp)
ffffffffc0206446:	64e2                	ld	s1,24(sp)
ffffffffc0206448:	6942                	ld	s2,16(sp)
ffffffffc020644a:	69a2                	ld	s3,8(sp)
ffffffffc020644c:	4501                	li	a0,0
ffffffffc020644e:	6145                	addi	sp,sp,48
ffffffffc0206450:	8082                	ret
ffffffffc0206452:	00090997          	auipc	s3,0x90
ffffffffc0206456:	47698993          	addi	s3,s3,1142 # ffffffffc02968c8 <current>
ffffffffc020645a:	0009b703          	ld	a4,0(s3)
ffffffffc020645e:	f487b683          	ld	a3,-184(a5)
ffffffffc0206462:	f0e695e3          	bne	a3,a4,ffffffffc020636c <do_wait.part.0+0x26>
ffffffffc0206466:	f287a603          	lw	a2,-216(a5)
ffffffffc020646a:	468d                	li	a3,3
ffffffffc020646c:	06d60063          	beq	a2,a3,ffffffffc02064cc <do_wait.part.0+0x186>
ffffffffc0206470:	800007b7          	lui	a5,0x80000
ffffffffc0206474:	0785                	addi	a5,a5,1 # ffffffff80000001 <_binary_bin_sfs_img_size+0xffffffff7ff8ad01>
ffffffffc0206476:	4685                	li	a3,1
ffffffffc0206478:	0ef72623          	sw	a5,236(a4)
ffffffffc020647c:	c314                	sw	a3,0(a4)
ffffffffc020647e:	0c0010ef          	jal	ffffffffc020753e <schedule>
ffffffffc0206482:	0009b783          	ld	a5,0(s3)
ffffffffc0206486:	0b07a783          	lw	a5,176(a5)
ffffffffc020648a:	8b85                	andi	a5,a5,1
ffffffffc020648c:	e7b9                	bnez	a5,ffffffffc02064da <do_wait.part.0+0x194>
ffffffffc020648e:	ee0487e3          	beqz	s1,ffffffffc020637c <do_wait.part.0+0x36>
ffffffffc0206492:	45a9                	li	a1,10
ffffffffc0206494:	8526                	mv	a0,s1
ffffffffc0206496:	627040ef          	jal	ffffffffc020b2bc <hash32>
ffffffffc020649a:	02051793          	slli	a5,a0,0x20
ffffffffc020649e:	01c7d513          	srli	a0,a5,0x1c
ffffffffc02064a2:	0008b797          	auipc	a5,0x8b
ffffffffc02064a6:	31e78793          	addi	a5,a5,798 # ffffffffc02917c0 <hash_list>
ffffffffc02064aa:	953e                	add	a0,a0,a5
ffffffffc02064ac:	87aa                	mv	a5,a0
ffffffffc02064ae:	a029                	j	ffffffffc02064b8 <do_wait.part.0+0x172>
ffffffffc02064b0:	f2c7a703          	lw	a4,-212(a5)
ffffffffc02064b4:	f8970fe3          	beq	a4,s1,ffffffffc0206452 <do_wait.part.0+0x10c>
ffffffffc02064b8:	679c                	ld	a5,8(a5)
ffffffffc02064ba:	fef51be3          	bne	a0,a5,ffffffffc02064b0 <do_wait.part.0+0x16a>
ffffffffc02064be:	b57d                	j	ffffffffc020636c <do_wait.part.0+0x26>
ffffffffc02064c0:	f12fa0ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc02064c4:	bf2d                	j	ffffffffc02063fe <do_wait.part.0+0xb8>
ffffffffc02064c6:	7018                	ld	a4,32(s0)
ffffffffc02064c8:	fb7c                	sd	a5,240(a4)
ffffffffc02064ca:	b705                	j	ffffffffc02063ea <do_wait.part.0+0xa4>
ffffffffc02064cc:	f2878413          	addi	s0,a5,-216
ffffffffc02064d0:	b5d1                	j	ffffffffc0206394 <do_wait.part.0+0x4e>
ffffffffc02064d2:	f06fa0ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc02064d6:	4605                	li	a2,1
ffffffffc02064d8:	b5f5                	j	ffffffffc02063c4 <do_wait.part.0+0x7e>
ffffffffc02064da:	555d                	li	a0,-9
ffffffffc02064dc:	d0bff0ef          	jal	ffffffffc02061e6 <do_exit>
ffffffffc02064e0:	00007617          	auipc	a2,0x7
ffffffffc02064e4:	27060613          	addi	a2,a2,624 # ffffffffc020d750 <etext+0x1ef0>
ffffffffc02064e8:	42800593          	li	a1,1064
ffffffffc02064ec:	00007517          	auipc	a0,0x7
ffffffffc02064f0:	1f450513          	addi	a0,a0,500 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc02064f4:	f57f90ef          	jal	ffffffffc020044a <__panic>
ffffffffc02064f8:	00006617          	auipc	a2,0x6
ffffffffc02064fc:	2e860613          	addi	a2,a2,744 # ffffffffc020c7e0 <etext+0xf80>
ffffffffc0206500:	06900593          	li	a1,105
ffffffffc0206504:	00006517          	auipc	a0,0x6
ffffffffc0206508:	23450513          	addi	a0,a0,564 # ffffffffc020c738 <etext+0xed8>
ffffffffc020650c:	f3ff90ef          	jal	ffffffffc020044a <__panic>
ffffffffc0206510:	00006617          	auipc	a2,0x6
ffffffffc0206514:	2a860613          	addi	a2,a2,680 # ffffffffc020c7b8 <etext+0xf58>
ffffffffc0206518:	07700593          	li	a1,119
ffffffffc020651c:	00006517          	auipc	a0,0x6
ffffffffc0206520:	21c50513          	addi	a0,a0,540 # ffffffffc020c738 <etext+0xed8>
ffffffffc0206524:	f27f90ef          	jal	ffffffffc020044a <__panic>

ffffffffc0206528 <init_main>:
ffffffffc0206528:	1141                	addi	sp,sp,-16
ffffffffc020652a:	00007517          	auipc	a0,0x7
ffffffffc020652e:	24650513          	addi	a0,a0,582 # ffffffffc020d770 <etext+0x1f10>
ffffffffc0206532:	e406                	sd	ra,8(sp)
ffffffffc0206534:	796010ef          	jal	ffffffffc0207cca <vfs_set_bootfs>
ffffffffc0206538:	e179                	bnez	a0,ffffffffc02065fe <init_main+0xd6>
ffffffffc020653a:	cbdfb0ef          	jal	ffffffffc02021f6 <nr_free_pages>
ffffffffc020653e:	a7ffb0ef          	jal	ffffffffc0201fbc <kallocated>
ffffffffc0206542:	4601                	li	a2,0
ffffffffc0206544:	4581                	li	a1,0
ffffffffc0206546:	00001517          	auipc	a0,0x1
ffffffffc020654a:	96450513          	addi	a0,a0,-1692 # ffffffffc0206eaa <user_main>
ffffffffc020654e:	c49ff0ef          	jal	ffffffffc0206196 <kernel_thread>
ffffffffc0206552:	00a04563          	bgtz	a0,ffffffffc020655c <init_main+0x34>
ffffffffc0206556:	a841                	j	ffffffffc02065e6 <init_main+0xbe>
ffffffffc0206558:	7e7000ef          	jal	ffffffffc020753e <schedule>
ffffffffc020655c:	4581                	li	a1,0
ffffffffc020655e:	4501                	li	a0,0
ffffffffc0206560:	de7ff0ef          	jal	ffffffffc0206346 <do_wait.part.0>
ffffffffc0206564:	d975                	beqz	a0,ffffffffc0206558 <init_main+0x30>
ffffffffc0206566:	d03fe0ef          	jal	ffffffffc0205268 <fs_cleanup>
ffffffffc020656a:	00007517          	auipc	a0,0x7
ffffffffc020656e:	24e50513          	addi	a0,a0,590 # ffffffffc020d7b8 <etext+0x1f58>
ffffffffc0206572:	c35f90ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0206576:	00090797          	auipc	a5,0x90
ffffffffc020657a:	35a7b783          	ld	a5,858(a5) # ffffffffc02968d0 <initproc>
ffffffffc020657e:	7bf8                	ld	a4,240(a5)
ffffffffc0206580:	e339                	bnez	a4,ffffffffc02065c6 <init_main+0x9e>
ffffffffc0206582:	7ff8                	ld	a4,248(a5)
ffffffffc0206584:	e329                	bnez	a4,ffffffffc02065c6 <init_main+0x9e>
ffffffffc0206586:	1007b703          	ld	a4,256(a5)
ffffffffc020658a:	ef15                	bnez	a4,ffffffffc02065c6 <init_main+0x9e>
ffffffffc020658c:	00090697          	auipc	a3,0x90
ffffffffc0206590:	3346a683          	lw	a3,820(a3) # ffffffffc02968c0 <nr_process>
ffffffffc0206594:	4709                	li	a4,2
ffffffffc0206596:	0ce69163          	bne	a3,a4,ffffffffc0206658 <init_main+0x130>
ffffffffc020659a:	0008f717          	auipc	a4,0x8f
ffffffffc020659e:	22670713          	addi	a4,a4,550 # ffffffffc02957c0 <proc_list>
ffffffffc02065a2:	6714                	ld	a3,8(a4)
ffffffffc02065a4:	0c878793          	addi	a5,a5,200
ffffffffc02065a8:	08d79863          	bne	a5,a3,ffffffffc0206638 <init_main+0x110>
ffffffffc02065ac:	6318                	ld	a4,0(a4)
ffffffffc02065ae:	06e79563          	bne	a5,a4,ffffffffc0206618 <init_main+0xf0>
ffffffffc02065b2:	00007517          	auipc	a0,0x7
ffffffffc02065b6:	2ee50513          	addi	a0,a0,750 # ffffffffc020d8a0 <etext+0x2040>
ffffffffc02065ba:	bedf90ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc02065be:	60a2                	ld	ra,8(sp)
ffffffffc02065c0:	4501                	li	a0,0
ffffffffc02065c2:	0141                	addi	sp,sp,16
ffffffffc02065c4:	8082                	ret
ffffffffc02065c6:	00007697          	auipc	a3,0x7
ffffffffc02065ca:	21a68693          	addi	a3,a3,538 # ffffffffc020d7e0 <etext+0x1f80>
ffffffffc02065ce:	00005617          	auipc	a2,0x5
ffffffffc02065d2:	6ca60613          	addi	a2,a2,1738 # ffffffffc020bc98 <etext+0x438>
ffffffffc02065d6:	49e00593          	li	a1,1182
ffffffffc02065da:	00007517          	auipc	a0,0x7
ffffffffc02065de:	10650513          	addi	a0,a0,262 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc02065e2:	e69f90ef          	jal	ffffffffc020044a <__panic>
ffffffffc02065e6:	00007617          	auipc	a2,0x7
ffffffffc02065ea:	1b260613          	addi	a2,a2,434 # ffffffffc020d798 <etext+0x1f38>
ffffffffc02065ee:	49100593          	li	a1,1169
ffffffffc02065f2:	00007517          	auipc	a0,0x7
ffffffffc02065f6:	0ee50513          	addi	a0,a0,238 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc02065fa:	e51f90ef          	jal	ffffffffc020044a <__panic>
ffffffffc02065fe:	86aa                	mv	a3,a0
ffffffffc0206600:	00007617          	auipc	a2,0x7
ffffffffc0206604:	17860613          	addi	a2,a2,376 # ffffffffc020d778 <etext+0x1f18>
ffffffffc0206608:	48900593          	li	a1,1161
ffffffffc020660c:	00007517          	auipc	a0,0x7
ffffffffc0206610:	0d450513          	addi	a0,a0,212 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc0206614:	e37f90ef          	jal	ffffffffc020044a <__panic>
ffffffffc0206618:	00007697          	auipc	a3,0x7
ffffffffc020661c:	25868693          	addi	a3,a3,600 # ffffffffc020d870 <etext+0x2010>
ffffffffc0206620:	00005617          	auipc	a2,0x5
ffffffffc0206624:	67860613          	addi	a2,a2,1656 # ffffffffc020bc98 <etext+0x438>
ffffffffc0206628:	4a100593          	li	a1,1185
ffffffffc020662c:	00007517          	auipc	a0,0x7
ffffffffc0206630:	0b450513          	addi	a0,a0,180 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc0206634:	e17f90ef          	jal	ffffffffc020044a <__panic>
ffffffffc0206638:	00007697          	auipc	a3,0x7
ffffffffc020663c:	20868693          	addi	a3,a3,520 # ffffffffc020d840 <etext+0x1fe0>
ffffffffc0206640:	00005617          	auipc	a2,0x5
ffffffffc0206644:	65860613          	addi	a2,a2,1624 # ffffffffc020bc98 <etext+0x438>
ffffffffc0206648:	4a000593          	li	a1,1184
ffffffffc020664c:	00007517          	auipc	a0,0x7
ffffffffc0206650:	09450513          	addi	a0,a0,148 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc0206654:	df7f90ef          	jal	ffffffffc020044a <__panic>
ffffffffc0206658:	00007697          	auipc	a3,0x7
ffffffffc020665c:	1d868693          	addi	a3,a3,472 # ffffffffc020d830 <etext+0x1fd0>
ffffffffc0206660:	00005617          	auipc	a2,0x5
ffffffffc0206664:	63860613          	addi	a2,a2,1592 # ffffffffc020bc98 <etext+0x438>
ffffffffc0206668:	49f00593          	li	a1,1183
ffffffffc020666c:	00007517          	auipc	a0,0x7
ffffffffc0206670:	07450513          	addi	a0,a0,116 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc0206674:	dd7f90ef          	jal	ffffffffc020044a <__panic>

ffffffffc0206678 <do_execve>:
ffffffffc0206678:	db010113          	addi	sp,sp,-592
ffffffffc020667c:	21513c23          	sd	s5,536(sp)
ffffffffc0206680:	24113423          	sd	ra,584(sp)
ffffffffc0206684:	f7ee                	sd	s11,488(sp)
ffffffffc0206686:	fff58a9b          	addiw	s5,a1,-1
ffffffffc020668a:	47fd                	li	a5,31
ffffffffc020668c:	5f57e063          	bltu	a5,s5,ffffffffc0206c6c <do_execve+0x5f4>
ffffffffc0206690:	23213823          	sd	s2,560(sp)
ffffffffc0206694:	00090917          	auipc	s2,0x90
ffffffffc0206698:	23490913          	addi	s2,s2,564 # ffffffffc02968c8 <current>
ffffffffc020669c:	00093783          	ld	a5,0(s2)
ffffffffc02066a0:	21713423          	sd	s7,520(sp)
ffffffffc02066a4:	24813023          	sd	s0,576(sp)
ffffffffc02066a8:	0287bb83          	ld	s7,40(a5)
ffffffffc02066ac:	22913c23          	sd	s1,568(sp)
ffffffffc02066b0:	ffe6                	sd	s9,504(sp)
ffffffffc02066b2:	84aa                	mv	s1,a0
ffffffffc02066b4:	8cb2                	mv	s9,a2
ffffffffc02066b6:	842e                	mv	s0,a1
ffffffffc02066b8:	08a8                	addi	a0,sp,88
ffffffffc02066ba:	4641                	li	a2,16
ffffffffc02066bc:	4581                	li	a1,0
ffffffffc02066be:	13a050ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc02066c2:	000b8c63          	beqz	s7,ffffffffc02066da <do_execve+0x62>
ffffffffc02066c6:	038b8513          	addi	a0,s7,56
ffffffffc02066ca:	f2dfd0ef          	jal	ffffffffc02045f6 <down>
ffffffffc02066ce:	00093783          	ld	a5,0(s2)
ffffffffc02066d2:	c781                	beqz	a5,ffffffffc02066da <do_execve+0x62>
ffffffffc02066d4:	43dc                	lw	a5,4(a5)
ffffffffc02066d6:	04fba823          	sw	a5,80(s7)
ffffffffc02066da:	1c048963          	beqz	s1,ffffffffc02068ac <do_execve+0x234>
ffffffffc02066de:	8626                	mv	a2,s1
ffffffffc02066e0:	46c1                	li	a3,16
ffffffffc02066e2:	08ac                	addi	a1,sp,88
ffffffffc02066e4:	855e                	mv	a0,s7
ffffffffc02066e6:	d43fd0ef          	jal	ffffffffc0204428 <copy_string>
ffffffffc02066ea:	56050063          	beqz	a0,ffffffffc0206c4a <do_execve+0x5d2>
ffffffffc02066ee:	21613823          	sd	s6,528(sp)
ffffffffc02066f2:	fbea                	sd	s10,496(sp)
ffffffffc02066f4:	00341d13          	slli	s10,s0,0x3
ffffffffc02066f8:	866a                	mv	a2,s10
ffffffffc02066fa:	4681                	li	a3,0
ffffffffc02066fc:	85e6                	mv	a1,s9
ffffffffc02066fe:	855e                	mv	a0,s7
ffffffffc0206700:	8b66                	mv	s6,s9
ffffffffc0206702:	c15fd0ef          	jal	ffffffffc0204316 <user_mem_check>
ffffffffc0206706:	6a050063          	beqz	a0,ffffffffc0206da6 <do_execve+0x72e>
ffffffffc020670a:	23313423          	sd	s3,552(sp)
ffffffffc020670e:	21813023          	sd	s8,512(sp)
ffffffffc0206712:	4981                	li	s3,0
ffffffffc0206714:	0e010c13          	addi	s8,sp,224
ffffffffc0206718:	6505                	lui	a0,0x1
ffffffffc020671a:	8a7fb0ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc020671e:	84aa                	mv	s1,a0
ffffffffc0206720:	10050963          	beqz	a0,ffffffffc0206832 <do_execve+0x1ba>
ffffffffc0206724:	000b3603          	ld	a2,0(s6)
ffffffffc0206728:	85aa                	mv	a1,a0
ffffffffc020672a:	6685                	lui	a3,0x1
ffffffffc020672c:	855e                	mv	a0,s7
ffffffffc020672e:	cfbfd0ef          	jal	ffffffffc0204428 <copy_string>
ffffffffc0206732:	16050863          	beqz	a0,ffffffffc02068a2 <do_execve+0x22a>
ffffffffc0206736:	009c3023          	sd	s1,0(s8)
ffffffffc020673a:	2985                	addiw	s3,s3,1
ffffffffc020673c:	0c21                	addi	s8,s8,8
ffffffffc020673e:	0b21                	addi	s6,s6,8
ffffffffc0206740:	fd341ce3          	bne	s0,s3,ffffffffc0206718 <do_execve+0xa0>
ffffffffc0206744:	23413023          	sd	s4,544(sp)
ffffffffc0206748:	000cb483          	ld	s1,0(s9)
ffffffffc020674c:	0a0b8663          	beqz	s7,ffffffffc02067f8 <do_execve+0x180>
ffffffffc0206750:	038b8513          	addi	a0,s7,56
ffffffffc0206754:	e9ffd0ef          	jal	ffffffffc02045f2 <up>
ffffffffc0206758:	00093783          	ld	a5,0(s2)
ffffffffc020675c:	040ba823          	sw	zero,80(s7)
ffffffffc0206760:	1487b503          	ld	a0,328(a5)
ffffffffc0206764:	be1fe0ef          	jal	ffffffffc0205344 <files_closeall>
ffffffffc0206768:	8526                	mv	a0,s1
ffffffffc020676a:	4581                	li	a1,0
ffffffffc020676c:	e69fe0ef          	jal	ffffffffc02055d4 <sysfile_open>
ffffffffc0206770:	8b2a                	mv	s6,a0
ffffffffc0206772:	6a054a63          	bltz	a0,ffffffffc0206e26 <do_execve+0x7ae>
ffffffffc0206776:	00090797          	auipc	a5,0x90
ffffffffc020677a:	1227b783          	ld	a5,290(a5) # ffffffffc0296898 <boot_pgdir_pa>
ffffffffc020677e:	577d                	li	a4,-1
ffffffffc0206780:	177e                	slli	a4,a4,0x3f
ffffffffc0206782:	83b1                	srli	a5,a5,0xc
ffffffffc0206784:	8fd9                	or	a5,a5,a4
ffffffffc0206786:	18079073          	csrw	satp,a5
ffffffffc020678a:	030ba783          	lw	a5,48(s7)
ffffffffc020678e:	37fd                	addiw	a5,a5,-1
ffffffffc0206790:	02fba823          	sw	a5,48(s7)
ffffffffc0206794:	14078e63          	beqz	a5,ffffffffc02068f0 <do_execve+0x278>
ffffffffc0206798:	00093783          	ld	a5,0(s2)
ffffffffc020679c:	0207b423          	sd	zero,40(a5)
ffffffffc02067a0:	cd6fd0ef          	jal	ffffffffc0203c76 <mm_create>
ffffffffc02067a4:	89aa                	mv	s3,a0
ffffffffc02067a6:	5df1                	li	s11,-4
ffffffffc02067a8:	c505                	beqz	a0,ffffffffc02067d0 <do_execve+0x158>
ffffffffc02067aa:	cb8ff0ef          	jal	ffffffffc0205c62 <setup_pgdir>
ffffffffc02067ae:	5df1                	li	s11,-4
ffffffffc02067b0:	ed09                	bnez	a0,ffffffffc02067ca <do_execve+0x152>
ffffffffc02067b2:	4601                	li	a2,0
ffffffffc02067b4:	4581                	li	a1,0
ffffffffc02067b6:	855a                	mv	a0,s6
ffffffffc02067b8:	8d4ff0ef          	jal	ffffffffc020588c <sysfile_seek>
ffffffffc02067bc:	8daa                	mv	s11,a0
ffffffffc02067be:	10050863          	beqz	a0,ffffffffc02068ce <do_execve+0x256>
ffffffffc02067c2:	0189b503          	ld	a0,24(s3)
ffffffffc02067c6:	c24ff0ef          	jal	ffffffffc0205bea <put_pgdir.isra.0>
ffffffffc02067ca:	854e                	mv	a0,s3
ffffffffc02067cc:	df6fd0ef          	jal	ffffffffc0203dc2 <mm_destroy>
ffffffffc02067d0:	0d010913          	addi	s2,sp,208
ffffffffc02067d4:	020a9713          	slli	a4,s5,0x20
ffffffffc02067d8:	01d75793          	srli	a5,a4,0x1d
ffffffffc02067dc:	996a                	add	s2,s2,s10
ffffffffc02067de:	09a0                	addi	s0,sp,216
ffffffffc02067e0:	40f90933          	sub	s2,s2,a5
ffffffffc02067e4:	946a                	add	s0,s0,s10
ffffffffc02067e6:	6008                	ld	a0,0(s0)
ffffffffc02067e8:	1461                	addi	s0,s0,-8
ffffffffc02067ea:	87dfb0ef          	jal	ffffffffc0202066 <kfree>
ffffffffc02067ee:	ff241ce3          	bne	s0,s2,ffffffffc02067e6 <do_execve+0x16e>
ffffffffc02067f2:	856e                	mv	a0,s11
ffffffffc02067f4:	9f3ff0ef          	jal	ffffffffc02061e6 <do_exit>
ffffffffc02067f8:	00093783          	ld	a5,0(s2)
ffffffffc02067fc:	1487b503          	ld	a0,328(a5)
ffffffffc0206800:	b45fe0ef          	jal	ffffffffc0205344 <files_closeall>
ffffffffc0206804:	8526                	mv	a0,s1
ffffffffc0206806:	4581                	li	a1,0
ffffffffc0206808:	dcdfe0ef          	jal	ffffffffc02055d4 <sysfile_open>
ffffffffc020680c:	8b2a                	mv	s6,a0
ffffffffc020680e:	0a054e63          	bltz	a0,ffffffffc02068ca <do_execve+0x252>
ffffffffc0206812:	00093783          	ld	a5,0(s2)
ffffffffc0206816:	779c                	ld	a5,40(a5)
ffffffffc0206818:	d7c1                	beqz	a5,ffffffffc02067a0 <do_execve+0x128>
ffffffffc020681a:	00007617          	auipc	a2,0x7
ffffffffc020681e:	0b660613          	addi	a2,a2,182 # ffffffffc020d8d0 <etext+0x2070>
ffffffffc0206822:	2de00593          	li	a1,734
ffffffffc0206826:	00007517          	auipc	a0,0x7
ffffffffc020682a:	eba50513          	addi	a0,a0,-326 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc020682e:	c1df90ef          	jal	ffffffffc020044a <__panic>
ffffffffc0206832:	5df1                	li	s11,-4
ffffffffc0206834:	02098663          	beqz	s3,ffffffffc0206860 <do_execve+0x1e8>
ffffffffc0206838:	00399793          	slli	a5,s3,0x3
ffffffffc020683c:	39fd                	addiw	s3,s3,-1
ffffffffc020683e:	0d010913          	addi	s2,sp,208
ffffffffc0206842:	02099713          	slli	a4,s3,0x20
ffffffffc0206846:	01d75993          	srli	s3,a4,0x1d
ffffffffc020684a:	993e                	add	s2,s2,a5
ffffffffc020684c:	09a0                	addi	s0,sp,216
ffffffffc020684e:	41390933          	sub	s2,s2,s3
ffffffffc0206852:	943e                	add	s0,s0,a5
ffffffffc0206854:	6008                	ld	a0,0(s0)
ffffffffc0206856:	1461                	addi	s0,s0,-8
ffffffffc0206858:	80ffb0ef          	jal	ffffffffc0202066 <kfree>
ffffffffc020685c:	ff241ce3          	bne	s0,s2,ffffffffc0206854 <do_execve+0x1dc>
ffffffffc0206860:	22813983          	ld	s3,552(sp)
ffffffffc0206864:	20013c03          	ld	s8,512(sp)
ffffffffc0206868:	000b8863          	beqz	s7,ffffffffc0206878 <do_execve+0x200>
ffffffffc020686c:	038b8513          	addi	a0,s7,56
ffffffffc0206870:	d83fd0ef          	jal	ffffffffc02045f2 <up>
ffffffffc0206874:	040ba823          	sw	zero,80(s7)
ffffffffc0206878:	24013403          	ld	s0,576(sp)
ffffffffc020687c:	23813483          	ld	s1,568(sp)
ffffffffc0206880:	23013903          	ld	s2,560(sp)
ffffffffc0206884:	21013b03          	ld	s6,528(sp)
ffffffffc0206888:	20813b83          	ld	s7,520(sp)
ffffffffc020688c:	7cfe                	ld	s9,504(sp)
ffffffffc020688e:	7d5e                	ld	s10,496(sp)
ffffffffc0206890:	24813083          	ld	ra,584(sp)
ffffffffc0206894:	21813a83          	ld	s5,536(sp)
ffffffffc0206898:	856e                	mv	a0,s11
ffffffffc020689a:	7dbe                	ld	s11,488(sp)
ffffffffc020689c:	25010113          	addi	sp,sp,592
ffffffffc02068a0:	8082                	ret
ffffffffc02068a2:	8526                	mv	a0,s1
ffffffffc02068a4:	fc2fb0ef          	jal	ffffffffc0202066 <kfree>
ffffffffc02068a8:	5df5                	li	s11,-3
ffffffffc02068aa:	b769                	j	ffffffffc0206834 <do_execve+0x1bc>
ffffffffc02068ac:	00093783          	ld	a5,0(s2)
ffffffffc02068b0:	00007617          	auipc	a2,0x7
ffffffffc02068b4:	01060613          	addi	a2,a2,16 # ffffffffc020d8c0 <etext+0x2060>
ffffffffc02068b8:	45c1                	li	a1,16
ffffffffc02068ba:	43d4                	lw	a3,4(a5)
ffffffffc02068bc:	08a8                	addi	a0,sp,88
ffffffffc02068be:	21613823          	sd	s6,528(sp)
ffffffffc02068c2:	fbea                	sd	s10,496(sp)
ffffffffc02068c4:	633040ef          	jal	ffffffffc020b6f6 <snprintf>
ffffffffc02068c8:	b535                	j	ffffffffc02066f4 <do_execve+0x7c>
ffffffffc02068ca:	8daa                	mv	s11,a0
ffffffffc02068cc:	b711                	j	ffffffffc02067d0 <do_execve+0x158>
ffffffffc02068ce:	04000613          	li	a2,64
ffffffffc02068d2:	110c                	addi	a1,sp,160
ffffffffc02068d4:	855a                	mv	a0,s6
ffffffffc02068d6:	d39fe0ef          	jal	ffffffffc020560e <sysfile_read>
ffffffffc02068da:	04000793          	li	a5,64
ffffffffc02068de:	02f50463          	beq	a0,a5,ffffffffc0206906 <do_execve+0x28e>
ffffffffc02068e2:	84aa                	mv	s1,a0
ffffffffc02068e4:	00054363          	bltz	a0,ffffffffc02068ea <do_execve+0x272>
ffffffffc02068e8:	54fd                	li	s1,-1
ffffffffc02068ea:	00048d9b          	sext.w	s11,s1
ffffffffc02068ee:	bdd1                	j	ffffffffc02067c2 <do_execve+0x14a>
ffffffffc02068f0:	855e                	mv	a0,s7
ffffffffc02068f2:	e86fd0ef          	jal	ffffffffc0203f78 <exit_mmap>
ffffffffc02068f6:	018bb503          	ld	a0,24(s7)
ffffffffc02068fa:	af0ff0ef          	jal	ffffffffc0205bea <put_pgdir.isra.0>
ffffffffc02068fe:	855e                	mv	a0,s7
ffffffffc0206900:	cc2fd0ef          	jal	ffffffffc0203dc2 <mm_destroy>
ffffffffc0206904:	bd51                	j	ffffffffc0206798 <do_execve+0x120>
ffffffffc0206906:	570a                	lw	a4,160(sp)
ffffffffc0206908:	464c47b7          	lui	a5,0x464c4
ffffffffc020690c:	57f78793          	addi	a5,a5,1407 # 464c457f <_binary_bin_sfs_img_size+0x4644f27f>
ffffffffc0206910:	30f71963          	bne	a4,a5,ffffffffc0206c22 <do_execve+0x5aa>
ffffffffc0206914:	0d815783          	lhu	a5,216(sp)
ffffffffc0206918:	f402                	sd	zero,40(sp)
ffffffffc020691a:	e082                	sd	zero,64(sp)
ffffffffc020691c:	c7a5                	beqz	a5,ffffffffc0206984 <do_execve+0x30c>
ffffffffc020691e:	f06a                	sd	s10,32(sp)
ffffffffc0206920:	e45a                	sd	s6,8(sp)
ffffffffc0206922:	e4a2                	sd	s0,72(sp)
ffffffffc0206924:	658e                	ld	a1,192(sp)
ffffffffc0206926:	6422                	ld	s0,8(sp)
ffffffffc0206928:	77a2                	ld	a5,40(sp)
ffffffffc020692a:	4601                	li	a2,0
ffffffffc020692c:	8522                	mv	a0,s0
ffffffffc020692e:	95be                	add	a1,a1,a5
ffffffffc0206930:	f5dfe0ef          	jal	ffffffffc020588c <sysfile_seek>
ffffffffc0206934:	20051063          	bnez	a0,ffffffffc0206b34 <do_execve+0x4bc>
ffffffffc0206938:	03800613          	li	a2,56
ffffffffc020693c:	10ac                	addi	a1,sp,104
ffffffffc020693e:	8522                	mv	a0,s0
ffffffffc0206940:	ccffe0ef          	jal	ffffffffc020560e <sysfile_read>
ffffffffc0206944:	03800793          	li	a5,56
ffffffffc0206948:	00f50d63          	beq	a0,a5,ffffffffc0206962 <do_execve+0x2ea>
ffffffffc020694c:	7d02                	ld	s10,32(sp)
ffffffffc020694e:	84aa                	mv	s1,a0
ffffffffc0206950:	00054363          	bltz	a0,ffffffffc0206956 <do_execve+0x2de>
ffffffffc0206954:	54fd                	li	s1,-1
ffffffffc0206956:	00048d9b          	sext.w	s11,s1
ffffffffc020695a:	854e                	mv	a0,s3
ffffffffc020695c:	e1cfd0ef          	jal	ffffffffc0203f78 <exit_mmap>
ffffffffc0206960:	b58d                	j	ffffffffc02067c2 <do_execve+0x14a>
ffffffffc0206962:	57a6                	lw	a5,104(sp)
ffffffffc0206964:	4705                	li	a4,1
ffffffffc0206966:	1ce78a63          	beq	a5,a4,ffffffffc0206b3a <do_execve+0x4c2>
ffffffffc020696a:	6706                	ld	a4,64(sp)
ffffffffc020696c:	76a2                	ld	a3,40(sp)
ffffffffc020696e:	0d815783          	lhu	a5,216(sp)
ffffffffc0206972:	2705                	addiw	a4,a4,1
ffffffffc0206974:	03868693          	addi	a3,a3,56 # 1038 <_binary_bin_swap_img_size-0x6cc8>
ffffffffc0206978:	e0ba                	sd	a4,64(sp)
ffffffffc020697a:	f436                	sd	a3,40(sp)
ffffffffc020697c:	faf764e3          	bltu	a4,a5,ffffffffc0206924 <do_execve+0x2ac>
ffffffffc0206980:	7d02                	ld	s10,32(sp)
ffffffffc0206982:	6426                	ld	s0,72(sp)
ffffffffc0206984:	4701                	li	a4,0
ffffffffc0206986:	46ad                	li	a3,11
ffffffffc0206988:	00100637          	lui	a2,0x100
ffffffffc020698c:	7ff005b7          	lui	a1,0x7ff00
ffffffffc0206990:	854e                	mv	a0,s3
ffffffffc0206992:	c82fd0ef          	jal	ffffffffc0203e14 <mm_map>
ffffffffc0206996:	8daa                	mv	s11,a0
ffffffffc0206998:	f169                	bnez	a0,ffffffffc020695a <do_execve+0x2e2>
ffffffffc020699a:	0189b503          	ld	a0,24(s3)
ffffffffc020699e:	467d                	li	a2,31
ffffffffc02069a0:	7ffff5b7          	lui	a1,0x7ffff
ffffffffc02069a4:	9f0fd0ef          	jal	ffffffffc0203b94 <pgdir_alloc_page>
ffffffffc02069a8:	4e050163          	beqz	a0,ffffffffc0206e8a <do_execve+0x812>
ffffffffc02069ac:	0189b503          	ld	a0,24(s3)
ffffffffc02069b0:	467d                	li	a2,31
ffffffffc02069b2:	7fffe5b7          	lui	a1,0x7fffe
ffffffffc02069b6:	9defd0ef          	jal	ffffffffc0203b94 <pgdir_alloc_page>
ffffffffc02069ba:	4a050863          	beqz	a0,ffffffffc0206e6a <do_execve+0x7f2>
ffffffffc02069be:	0189b503          	ld	a0,24(s3)
ffffffffc02069c2:	467d                	li	a2,31
ffffffffc02069c4:	7fffd5b7          	lui	a1,0x7fffd
ffffffffc02069c8:	9ccfd0ef          	jal	ffffffffc0203b94 <pgdir_alloc_page>
ffffffffc02069cc:	46050f63          	beqz	a0,ffffffffc0206e4a <do_execve+0x7d2>
ffffffffc02069d0:	0189b503          	ld	a0,24(s3)
ffffffffc02069d4:	467d                	li	a2,31
ffffffffc02069d6:	7fffc5b7          	lui	a1,0x7fffc
ffffffffc02069da:	9bafd0ef          	jal	ffffffffc0203b94 <pgdir_alloc_page>
ffffffffc02069de:	44050663          	beqz	a0,ffffffffc0206e2a <do_execve+0x7b2>
ffffffffc02069e2:	0309a783          	lw	a5,48(s3)
ffffffffc02069e6:	00093603          	ld	a2,0(s2)
ffffffffc02069ea:	0189b683          	ld	a3,24(s3)
ffffffffc02069ee:	2785                	addiw	a5,a5,1
ffffffffc02069f0:	02f9a823          	sw	a5,48(s3)
ffffffffc02069f4:	03363423          	sd	s3,40(a2) # 100028 <_binary_bin_sfs_img_size+0x8ad28>
ffffffffc02069f8:	c02007b7          	lui	a5,0xc0200
ffffffffc02069fc:	3ef6ec63          	bltu	a3,a5,ffffffffc0206df4 <do_execve+0x77c>
ffffffffc0206a00:	00090797          	auipc	a5,0x90
ffffffffc0206a04:	ea87b783          	ld	a5,-344(a5) # ffffffffc02968a8 <va_pa_offset>
ffffffffc0206a08:	577d                	li	a4,-1
ffffffffc0206a0a:	177e                	slli	a4,a4,0x3f
ffffffffc0206a0c:	8e9d                	sub	a3,a3,a5
ffffffffc0206a0e:	00c6d793          	srli	a5,a3,0xc
ffffffffc0206a12:	f654                	sd	a3,168(a2)
ffffffffc0206a14:	8fd9                	or	a5,a5,a4
ffffffffc0206a16:	18079073          	csrw	satp,a5
ffffffffc0206a1a:	4b01                	li	s6,0
ffffffffc0206a1c:	0e010a13          	addi	s4,sp,224
ffffffffc0206a20:	4981                	li	s3,0
ffffffffc0206a22:	000a3503          	ld	a0,0(s4)
ffffffffc0206a26:	6585                	lui	a1,0x1
ffffffffc0206a28:	2985                	addiw	s3,s3,1
ffffffffc0206a2a:	533040ef          	jal	ffffffffc020b75c <strnlen>
ffffffffc0206a2e:	00150793          	addi	a5,a0,1
ffffffffc0206a32:	0a21                	addi	s4,s4,8
ffffffffc0206a34:	01678b3b          	addw	s6,a5,s6
ffffffffc0206a38:	fe89e5e3          	bltu	s3,s0,ffffffffc0206a22 <do_execve+0x3aa>
ffffffffc0206a3c:	80000a37          	lui	s4,0x80000
ffffffffc0206a40:	416a0a3b          	subw	s4,s4,s6
ffffffffc0206a44:	1a02                	slli	s4,s4,0x20
ffffffffc0206a46:	020a5a13          	srli	s4,s4,0x20
ffffffffc0206a4a:	0e010993          	addi	s3,sp,224
ffffffffc0206a4e:	41aa0cb3          	sub	s9,s4,s10
ffffffffc0206a52:	4b81                	li	s7,0
ffffffffc0206a54:	413c8c33          	sub	s8,s9,s3
ffffffffc0206a58:	4b01                	li	s6,0
ffffffffc0206a5a:	0009b483          	ld	s1,0(s3)
ffffffffc0206a5e:	020b1513          	slli	a0,s6,0x20
ffffffffc0206a62:	9101                	srli	a0,a0,0x20
ffffffffc0206a64:	85a6                	mv	a1,s1
ffffffffc0206a66:	9552                	add	a0,a0,s4
ffffffffc0206a68:	511040ef          	jal	ffffffffc020b778 <strcpy>
ffffffffc0206a6c:	013c07b3          	add	a5,s8,s3
ffffffffc0206a70:	872a                	mv	a4,a0
ffffffffc0206a72:	e398                	sd	a4,0(a5)
ffffffffc0206a74:	8526                	mv	a0,s1
ffffffffc0206a76:	6585                	lui	a1,0x1
ffffffffc0206a78:	4e5040ef          	jal	ffffffffc020b75c <strnlen>
ffffffffc0206a7c:	00150793          	addi	a5,a0,1
ffffffffc0206a80:	2b85                	addiw	s7,s7,1
ffffffffc0206a82:	09a1                	addi	s3,s3,8
ffffffffc0206a84:	01678b3b          	addw	s6,a5,s6
ffffffffc0206a88:	fc8be9e3          	bltu	s7,s0,ffffffffc0206a5a <do_execve+0x3e2>
ffffffffc0206a8c:	00093783          	ld	a5,0(s2)
ffffffffc0206a90:	fe8cae23          	sw	s0,-4(s9)
ffffffffc0206a94:	12000613          	li	a2,288
ffffffffc0206a98:	0a07ba03          	ld	s4,160(a5)
ffffffffc0206a9c:	4581                	li	a1,0
ffffffffc0206a9e:	0d010993          	addi	s3,sp,208
ffffffffc0206aa2:	100a3403          	ld	s0,256(s4) # ffffffff80000100 <_binary_bin_sfs_img_size+0xffffffff7ff8ae00>
ffffffffc0206aa6:	8552                	mv	a0,s4
ffffffffc0206aa8:	551040ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc0206aac:	776a                	ld	a4,184(sp)
ffffffffc0206aae:	edf47793          	andi	a5,s0,-289
ffffffffc0206ab2:	020a9613          	slli	a2,s5,0x20
ffffffffc0206ab6:	1cf1                	addi	s9,s9,-4
ffffffffc0206ab8:	0207e793          	ori	a5,a5,32
ffffffffc0206abc:	01d65693          	srli	a3,a2,0x1d
ffffffffc0206ac0:	99ea                	add	s3,s3,s10
ffffffffc0206ac2:	09a0                	addi	s0,sp,216
ffffffffc0206ac4:	10fa3023          	sd	a5,256(s4)
ffffffffc0206ac8:	019a3823          	sd	s9,16(s4)
ffffffffc0206acc:	40d989b3          	sub	s3,s3,a3
ffffffffc0206ad0:	946a                	add	s0,s0,s10
ffffffffc0206ad2:	10ea3423          	sd	a4,264(s4)
ffffffffc0206ad6:	6008                	ld	a0,0(s0)
ffffffffc0206ad8:	1461                	addi	s0,s0,-8
ffffffffc0206ada:	d8cfb0ef          	jal	ffffffffc0202066 <kfree>
ffffffffc0206ade:	ff341ce3          	bne	s0,s3,ffffffffc0206ad6 <do_execve+0x45e>
ffffffffc0206ae2:	00093403          	ld	s0,0(s2)
ffffffffc0206ae6:	4641                	li	a2,16
ffffffffc0206ae8:	4581                	li	a1,0
ffffffffc0206aea:	0b440413          	addi	s0,s0,180
ffffffffc0206aee:	8522                	mv	a0,s0
ffffffffc0206af0:	509040ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc0206af4:	08ac                	addi	a1,sp,88
ffffffffc0206af6:	8522                	mv	a0,s0
ffffffffc0206af8:	463d                	li	a2,15
ffffffffc0206afa:	54f040ef          	jal	ffffffffc020b848 <memcpy>
ffffffffc0206afe:	24813083          	ld	ra,584(sp)
ffffffffc0206b02:	24013403          	ld	s0,576(sp)
ffffffffc0206b06:	23813483          	ld	s1,568(sp)
ffffffffc0206b0a:	23013903          	ld	s2,560(sp)
ffffffffc0206b0e:	22813983          	ld	s3,552(sp)
ffffffffc0206b12:	22013a03          	ld	s4,544(sp)
ffffffffc0206b16:	21013b03          	ld	s6,528(sp)
ffffffffc0206b1a:	20813b83          	ld	s7,520(sp)
ffffffffc0206b1e:	20013c03          	ld	s8,512(sp)
ffffffffc0206b22:	7cfe                	ld	s9,504(sp)
ffffffffc0206b24:	7d5e                	ld	s10,496(sp)
ffffffffc0206b26:	21813a83          	ld	s5,536(sp)
ffffffffc0206b2a:	856e                	mv	a0,s11
ffffffffc0206b2c:	7dbe                	ld	s11,488(sp)
ffffffffc0206b2e:	25010113          	addi	sp,sp,592
ffffffffc0206b32:	8082                	ret
ffffffffc0206b34:	7d02                	ld	s10,32(sp)
ffffffffc0206b36:	8daa                	mv	s11,a0
ffffffffc0206b38:	b50d                	j	ffffffffc020695a <do_execve+0x2e2>
ffffffffc0206b3a:	664a                	ld	a2,144(sp)
ffffffffc0206b3c:	67aa                	ld	a5,136(sp)
ffffffffc0206b3e:	26f66b63          	bltu	a2,a5,ffffffffc0206db4 <do_execve+0x73c>
ffffffffc0206b42:	57b6                	lw	a5,108(sp)
ffffffffc0206b44:	0027971b          	slliw	a4,a5,0x2
ffffffffc0206b48:	0027f693          	andi	a3,a5,2
ffffffffc0206b4c:	8b11                	andi	a4,a4,4
ffffffffc0206b4e:	8b91                	andi	a5,a5,4
ffffffffc0206b50:	caf9                	beqz	a3,ffffffffc0206c26 <do_execve+0x5ae>
ffffffffc0206b52:	24079363          	bnez	a5,ffffffffc0206d98 <do_execve+0x720>
ffffffffc0206b56:	47dd                	li	a5,23
ffffffffc0206b58:	00276693          	ori	a3,a4,2
ffffffffc0206b5c:	ec3e                	sd	a5,24(sp)
ffffffffc0206b5e:	c709                	beqz	a4,ffffffffc0206b68 <do_execve+0x4f0>
ffffffffc0206b60:	67e2                	ld	a5,24(sp)
ffffffffc0206b62:	0087e793          	ori	a5,a5,8
ffffffffc0206b66:	ec3e                	sd	a5,24(sp)
ffffffffc0206b68:	75e6                	ld	a1,120(sp)
ffffffffc0206b6a:	4701                	li	a4,0
ffffffffc0206b6c:	854e                	mv	a0,s3
ffffffffc0206b6e:	aa6fd0ef          	jal	ffffffffc0203e14 <mm_map>
ffffffffc0206b72:	f169                	bnez	a0,ffffffffc0206b34 <do_execve+0x4bc>
ffffffffc0206b74:	74e6                	ld	s1,120(sp)
ffffffffc0206b76:	662a                	ld	a2,136(sp)
ffffffffc0206b78:	77fd                	lui	a5,0xfffff
ffffffffc0206b7a:	00f4fb33          	and	s6,s1,a5
ffffffffc0206b7e:	00c48c33          	add	s8,s1,a2
ffffffffc0206b82:	2384f663          	bgeu	s1,s8,ffffffffc0206dae <do_execve+0x736>
ffffffffc0206b86:	577d                	li	a4,-1
ffffffffc0206b88:	7bc6                	ld	s7,112(sp)
ffffffffc0206b8a:	00c75793          	srli	a5,a4,0xc
ffffffffc0206b8e:	f83e                	sd	a5,48(sp)
ffffffffc0206b90:	00090d97          	auipc	s11,0x90
ffffffffc0206b94:	d28d8d93          	addi	s11,s11,-728 # ffffffffc02968b8 <pages>
ffffffffc0206b98:	00009c97          	auipc	s9,0x9
ffffffffc0206b9c:	fc0c8c93          	addi	s9,s9,-64 # ffffffffc020fb58 <nbase>
ffffffffc0206ba0:	fc56                	sd	s5,56(sp)
ffffffffc0206ba2:	e84e                	sd	s3,16(sp)
ffffffffc0206ba4:	67c2                	ld	a5,16(sp)
ffffffffc0206ba6:	6662                	ld	a2,24(sp)
ffffffffc0206ba8:	85da                	mv	a1,s6
ffffffffc0206baa:	6f88                	ld	a0,24(a5)
ffffffffc0206bac:	fe9fc0ef          	jal	ffffffffc0203b94 <pgdir_alloc_page>
ffffffffc0206bb0:	8d2a                	mv	s10,a0
ffffffffc0206bb2:	cd5d                	beqz	a0,ffffffffc0206c70 <do_execve+0x5f8>
ffffffffc0206bb4:	6785                	lui	a5,0x1
ffffffffc0206bb6:	00fb0ab3          	add	s5,s6,a5
ffffffffc0206bba:	409c09b3          	sub	s3,s8,s1
ffffffffc0206bbe:	015c6463          	bltu	s8,s5,ffffffffc0206bc6 <do_execve+0x54e>
ffffffffc0206bc2:	409a89b3          	sub	s3,s5,s1
ffffffffc0206bc6:	000db403          	ld	s0,0(s11)
ffffffffc0206bca:	000cb583          	ld	a1,0(s9)
ffffffffc0206bce:	77c2                	ld	a5,48(sp)
ffffffffc0206bd0:	408d0433          	sub	s0,s10,s0
ffffffffc0206bd4:	8419                	srai	s0,s0,0x6
ffffffffc0206bd6:	00090617          	auipc	a2,0x90
ffffffffc0206bda:	cda63603          	ld	a2,-806(a2) # ffffffffc02968b0 <npage>
ffffffffc0206bde:	942e                	add	s0,s0,a1
ffffffffc0206be0:	00f475b3          	and	a1,s0,a5
ffffffffc0206be4:	0432                	slli	s0,s0,0xc
ffffffffc0206be6:	22c5f363          	bgeu	a1,a2,ffffffffc0206e0c <do_execve+0x794>
ffffffffc0206bea:	6522                	ld	a0,8(sp)
ffffffffc0206bec:	4601                	li	a2,0
ffffffffc0206bee:	85de                	mv	a1,s7
ffffffffc0206bf0:	00090a17          	auipc	s4,0x90
ffffffffc0206bf4:	cb8a3a03          	ld	s4,-840(s4) # ffffffffc02968a8 <va_pa_offset>
ffffffffc0206bf8:	c95fe0ef          	jal	ffffffffc020588c <sysfile_seek>
ffffffffc0206bfc:	e131                	bnez	a0,ffffffffc0206c40 <do_execve+0x5c8>
ffffffffc0206bfe:	6522                	ld	a0,8(sp)
ffffffffc0206c00:	9a22                	add	s4,s4,s0
ffffffffc0206c02:	416485b3          	sub	a1,s1,s6
ffffffffc0206c06:	95d2                	add	a1,a1,s4
ffffffffc0206c08:	864e                	mv	a2,s3
ffffffffc0206c0a:	a05fe0ef          	jal	ffffffffc020560e <sysfile_read>
ffffffffc0206c0e:	02a98363          	beq	s3,a0,ffffffffc0206c34 <do_execve+0x5bc>
ffffffffc0206c12:	7d02                	ld	s10,32(sp)
ffffffffc0206c14:	7ae2                	ld	s5,56(sp)
ffffffffc0206c16:	69c2                	ld	s3,16(sp)
ffffffffc0206c18:	84aa                	mv	s1,a0
ffffffffc0206c1a:	d2054ee3          	bltz	a0,ffffffffc0206956 <do_execve+0x2de>
ffffffffc0206c1e:	54fd                	li	s1,-1
ffffffffc0206c20:	bb1d                	j	ffffffffc0206956 <do_execve+0x2de>
ffffffffc0206c22:	5de1                	li	s11,-8
ffffffffc0206c24:	be79                	j	ffffffffc02067c2 <do_execve+0x14a>
ffffffffc0206c26:	16078563          	beqz	a5,ffffffffc0206d90 <do_execve+0x718>
ffffffffc0206c2a:	47cd                	li	a5,19
ffffffffc0206c2c:	00176693          	ori	a3,a4,1
ffffffffc0206c30:	ec3e                	sd	a5,24(sp)
ffffffffc0206c32:	b735                	j	ffffffffc0206b5e <do_execve+0x4e6>
ffffffffc0206c34:	94ce                	add	s1,s1,s3
ffffffffc0206c36:	9bce                	add	s7,s7,s3
ffffffffc0206c38:	0584f163          	bgeu	s1,s8,ffffffffc0206c7a <do_execve+0x602>
ffffffffc0206c3c:	8b56                	mv	s6,s5
ffffffffc0206c3e:	b79d                	j	ffffffffc0206ba4 <do_execve+0x52c>
ffffffffc0206c40:	7d02                	ld	s10,32(sp)
ffffffffc0206c42:	7ae2                	ld	s5,56(sp)
ffffffffc0206c44:	69c2                	ld	s3,16(sp)
ffffffffc0206c46:	8daa                	mv	s11,a0
ffffffffc0206c48:	bb09                	j	ffffffffc020695a <do_execve+0x2e2>
ffffffffc0206c4a:	000b8863          	beqz	s7,ffffffffc0206c5a <do_execve+0x5e2>
ffffffffc0206c4e:	038b8513          	addi	a0,s7,56
ffffffffc0206c52:	9a1fd0ef          	jal	ffffffffc02045f2 <up>
ffffffffc0206c56:	040ba823          	sw	zero,80(s7)
ffffffffc0206c5a:	24013403          	ld	s0,576(sp)
ffffffffc0206c5e:	23813483          	ld	s1,568(sp)
ffffffffc0206c62:	23013903          	ld	s2,560(sp)
ffffffffc0206c66:	20813b83          	ld	s7,520(sp)
ffffffffc0206c6a:	7cfe                	ld	s9,504(sp)
ffffffffc0206c6c:	5df5                	li	s11,-3
ffffffffc0206c6e:	b10d                	j	ffffffffc0206890 <do_execve+0x218>
ffffffffc0206c70:	7d02                	ld	s10,32(sp)
ffffffffc0206c72:	7ae2                	ld	s5,56(sp)
ffffffffc0206c74:	69c2                	ld	s3,16(sp)
ffffffffc0206c76:	5df1                	li	s11,-4
ffffffffc0206c78:	b1cd                	j	ffffffffc020695a <do_execve+0x2e2>
ffffffffc0206c7a:	8a6a                	mv	s4,s10
ffffffffc0206c7c:	69c2                	ld	s3,16(sp)
ffffffffc0206c7e:	8d56                	mv	s10,s5
ffffffffc0206c80:	7866                	ld	a6,120(sp)
ffffffffc0206c82:	7ae2                	ld	s5,56(sp)
ffffffffc0206c84:	66ca                	ld	a3,144(sp)
ffffffffc0206c86:	00d80433          	add	s0,a6,a3
ffffffffc0206c8a:	07a4f863          	bgeu	s1,s10,ffffffffc0206cfa <do_execve+0x682>
ffffffffc0206c8e:	cc940ee3          	beq	s0,s1,ffffffffc020696a <do_execve+0x2f2>
ffffffffc0206c92:	40940b33          	sub	s6,s0,s1
ffffffffc0206c96:	01a46463          	bltu	s0,s10,ffffffffc0206c9e <do_execve+0x626>
ffffffffc0206c9a:	409d0b33          	sub	s6,s10,s1
ffffffffc0206c9e:	00090697          	auipc	a3,0x90
ffffffffc0206ca2:	c1a6b683          	ld	a3,-998(a3) # ffffffffc02968b8 <pages>
ffffffffc0206ca6:	00009617          	auipc	a2,0x9
ffffffffc0206caa:	eb263603          	ld	a2,-334(a2) # ffffffffc020fb58 <nbase>
ffffffffc0206cae:	00090597          	auipc	a1,0x90
ffffffffc0206cb2:	c025b583          	ld	a1,-1022(a1) # ffffffffc02968b0 <npage>
ffffffffc0206cb6:	40da06b3          	sub	a3,s4,a3
ffffffffc0206cba:	8699                	srai	a3,a3,0x6
ffffffffc0206cbc:	96b2                	add	a3,a3,a2
ffffffffc0206cbe:	00c69613          	slli	a2,a3,0xc
ffffffffc0206cc2:	8231                	srli	a2,a2,0xc
ffffffffc0206cc4:	06b2                	slli	a3,a3,0xc
ffffffffc0206cc6:	0eb67b63          	bgeu	a2,a1,ffffffffc0206dbc <do_execve+0x744>
ffffffffc0206cca:	00090617          	auipc	a2,0x90
ffffffffc0206cce:	bde63603          	ld	a2,-1058(a2) # ffffffffc02968a8 <va_pa_offset>
ffffffffc0206cd2:	6505                	lui	a0,0x1
ffffffffc0206cd4:	9526                	add	a0,a0,s1
ffffffffc0206cd6:	96b2                	add	a3,a3,a2
ffffffffc0206cd8:	41a50533          	sub	a0,a0,s10
ffffffffc0206cdc:	9536                	add	a0,a0,a3
ffffffffc0206cde:	865a                	mv	a2,s6
ffffffffc0206ce0:	4581                	li	a1,0
ffffffffc0206ce2:	317040ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc0206ce6:	94da                	add	s1,s1,s6
ffffffffc0206ce8:	01a436b3          	sltu	a3,s0,s10
ffffffffc0206cec:	01a47463          	bgeu	s0,s10,ffffffffc0206cf4 <do_execve+0x67c>
ffffffffc0206cf0:	c6940de3          	beq	s0,s1,ffffffffc020696a <do_execve+0x2f2>
ffffffffc0206cf4:	e2e5                	bnez	a3,ffffffffc0206dd4 <do_execve+0x75c>
ffffffffc0206cf6:	0da49f63          	bne	s1,s10,ffffffffc0206dd4 <do_execve+0x75c>
ffffffffc0206cfa:	c684f8e3          	bgeu	s1,s0,ffffffffc020696a <do_execve+0x2f2>
ffffffffc0206cfe:	57fd                	li	a5,-1
ffffffffc0206d00:	83b1                	srli	a5,a5,0xc
ffffffffc0206d02:	e83e                	sd	a5,16(sp)
ffffffffc0206d04:	00090c97          	auipc	s9,0x90
ffffffffc0206d08:	bb4c8c93          	addi	s9,s9,-1100 # ffffffffc02968b8 <pages>
ffffffffc0206d0c:	00009c17          	auipc	s8,0x9
ffffffffc0206d10:	e4cc0c13          	addi	s8,s8,-436 # ffffffffc020fb58 <nbase>
ffffffffc0206d14:	00090b97          	auipc	s7,0x90
ffffffffc0206d18:	b9cb8b93          	addi	s7,s7,-1124 # ffffffffc02968b0 <npage>
ffffffffc0206d1c:	00090d97          	auipc	s11,0x90
ffffffffc0206d20:	b8cd8d93          	addi	s11,s11,-1140 # ffffffffc02968a8 <va_pa_offset>
ffffffffc0206d24:	f856                	sd	s5,48(sp)
ffffffffc0206d26:	a889                	j	ffffffffc0206d78 <do_execve+0x700>
ffffffffc0206d28:	6785                	lui	a5,0x1
ffffffffc0206d2a:	00fd0b33          	add	s6,s10,a5
ffffffffc0206d2e:	40940ab3          	sub	s5,s0,s1
ffffffffc0206d32:	01646463          	bltu	s0,s6,ffffffffc0206d3a <do_execve+0x6c2>
ffffffffc0206d36:	409b0ab3          	sub	s5,s6,s1
ffffffffc0206d3a:	000cb783          	ld	a5,0(s9)
ffffffffc0206d3e:	000c3583          	ld	a1,0(s8)
ffffffffc0206d42:	6742                	ld	a4,16(sp)
ffffffffc0206d44:	40fa07b3          	sub	a5,s4,a5
ffffffffc0206d48:	8799                	srai	a5,a5,0x6
ffffffffc0206d4a:	000bb683          	ld	a3,0(s7)
ffffffffc0206d4e:	97ae                	add	a5,a5,a1
ffffffffc0206d50:	00e7f5b3          	and	a1,a5,a4
ffffffffc0206d54:	07b2                	slli	a5,a5,0xc
ffffffffc0206d56:	06d5f263          	bgeu	a1,a3,ffffffffc0206dba <do_execve+0x742>
ffffffffc0206d5a:	000db683          	ld	a3,0(s11)
ffffffffc0206d5e:	41a48d33          	sub	s10,s1,s10
ffffffffc0206d62:	8656                	mv	a2,s5
ffffffffc0206d64:	97b6                	add	a5,a5,a3
ffffffffc0206d66:	01a78533          	add	a0,a5,s10
ffffffffc0206d6a:	4581                	li	a1,0
ffffffffc0206d6c:	94d6                	add	s1,s1,s5
ffffffffc0206d6e:	28b040ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc0206d72:	0284f863          	bgeu	s1,s0,ffffffffc0206da2 <do_execve+0x72a>
ffffffffc0206d76:	8d5a                	mv	s10,s6
ffffffffc0206d78:	0189b503          	ld	a0,24(s3)
ffffffffc0206d7c:	6662                	ld	a2,24(sp)
ffffffffc0206d7e:	85ea                	mv	a1,s10
ffffffffc0206d80:	e15fc0ef          	jal	ffffffffc0203b94 <pgdir_alloc_page>
ffffffffc0206d84:	8a2a                	mv	s4,a0
ffffffffc0206d86:	f14d                	bnez	a0,ffffffffc0206d28 <do_execve+0x6b0>
ffffffffc0206d88:	7d02                	ld	s10,32(sp)
ffffffffc0206d8a:	7ac2                	ld	s5,48(sp)
ffffffffc0206d8c:	5df1                	li	s11,-4
ffffffffc0206d8e:	b6f1                	j	ffffffffc020695a <do_execve+0x2e2>
ffffffffc0206d90:	47c5                	li	a5,17
ffffffffc0206d92:	86ba                	mv	a3,a4
ffffffffc0206d94:	ec3e                	sd	a5,24(sp)
ffffffffc0206d96:	b3e1                	j	ffffffffc0206b5e <do_execve+0x4e6>
ffffffffc0206d98:	47dd                	li	a5,23
ffffffffc0206d9a:	00376693          	ori	a3,a4,3
ffffffffc0206d9e:	ec3e                	sd	a5,24(sp)
ffffffffc0206da0:	bb7d                	j	ffffffffc0206b5e <do_execve+0x4e6>
ffffffffc0206da2:	7ac2                	ld	s5,48(sp)
ffffffffc0206da4:	b6d9                	j	ffffffffc020696a <do_execve+0x2f2>
ffffffffc0206da6:	5df5                	li	s11,-3
ffffffffc0206da8:	ac0b92e3          	bnez	s7,ffffffffc020686c <do_execve+0x1f4>
ffffffffc0206dac:	b4f1                	j	ffffffffc0206878 <do_execve+0x200>
ffffffffc0206dae:	8d5a                	mv	s10,s6
ffffffffc0206db0:	8826                	mv	a6,s1
ffffffffc0206db2:	bdc9                	j	ffffffffc0206c84 <do_execve+0x60c>
ffffffffc0206db4:	7d02                	ld	s10,32(sp)
ffffffffc0206db6:	5de1                	li	s11,-8
ffffffffc0206db8:	b64d                	j	ffffffffc020695a <do_execve+0x2e2>
ffffffffc0206dba:	86be                	mv	a3,a5
ffffffffc0206dbc:	00006617          	auipc	a2,0x6
ffffffffc0206dc0:	95460613          	addi	a2,a2,-1708 # ffffffffc020c710 <etext+0xeb0>
ffffffffc0206dc4:	07100593          	li	a1,113
ffffffffc0206dc8:	00006517          	auipc	a0,0x6
ffffffffc0206dcc:	97050513          	addi	a0,a0,-1680 # ffffffffc020c738 <etext+0xed8>
ffffffffc0206dd0:	e7af90ef          	jal	ffffffffc020044a <__panic>
ffffffffc0206dd4:	00007697          	auipc	a3,0x7
ffffffffc0206dd8:	b2468693          	addi	a3,a3,-1244 # ffffffffc020d8f8 <etext+0x2098>
ffffffffc0206ddc:	00005617          	auipc	a2,0x5
ffffffffc0206de0:	ebc60613          	addi	a2,a2,-324 # ffffffffc020bc98 <etext+0x438>
ffffffffc0206de4:	33100593          	li	a1,817
ffffffffc0206de8:	00007517          	auipc	a0,0x7
ffffffffc0206dec:	8f850513          	addi	a0,a0,-1800 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc0206df0:	e5af90ef          	jal	ffffffffc020044a <__panic>
ffffffffc0206df4:	00006617          	auipc	a2,0x6
ffffffffc0206df8:	9c460613          	addi	a2,a2,-1596 # ffffffffc020c7b8 <etext+0xf58>
ffffffffc0206dfc:	34c00593          	li	a1,844
ffffffffc0206e00:	00007517          	auipc	a0,0x7
ffffffffc0206e04:	8e050513          	addi	a0,a0,-1824 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc0206e08:	e42f90ef          	jal	ffffffffc020044a <__panic>
ffffffffc0206e0c:	86a2                	mv	a3,s0
ffffffffc0206e0e:	00006617          	auipc	a2,0x6
ffffffffc0206e12:	90260613          	addi	a2,a2,-1790 # ffffffffc020c710 <etext+0xeb0>
ffffffffc0206e16:	07100593          	li	a1,113
ffffffffc0206e1a:	00006517          	auipc	a0,0x6
ffffffffc0206e1e:	91e50513          	addi	a0,a0,-1762 # ffffffffc020c738 <etext+0xed8>
ffffffffc0206e22:	e28f90ef          	jal	ffffffffc020044a <__panic>
ffffffffc0206e26:	8daa                	mv	s11,a0
ffffffffc0206e28:	b265                	j	ffffffffc02067d0 <do_execve+0x158>
ffffffffc0206e2a:	00007697          	auipc	a3,0x7
ffffffffc0206e2e:	be668693          	addi	a3,a3,-1050 # ffffffffc020da10 <etext+0x21b0>
ffffffffc0206e32:	00005617          	auipc	a2,0x5
ffffffffc0206e36:	e6660613          	addi	a2,a2,-410 # ffffffffc020bc98 <etext+0x438>
ffffffffc0206e3a:	34800593          	li	a1,840
ffffffffc0206e3e:	00007517          	auipc	a0,0x7
ffffffffc0206e42:	8a250513          	addi	a0,a0,-1886 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc0206e46:	e04f90ef          	jal	ffffffffc020044a <__panic>
ffffffffc0206e4a:	00007697          	auipc	a3,0x7
ffffffffc0206e4e:	b7e68693          	addi	a3,a3,-1154 # ffffffffc020d9c8 <etext+0x2168>
ffffffffc0206e52:	00005617          	auipc	a2,0x5
ffffffffc0206e56:	e4660613          	addi	a2,a2,-442 # ffffffffc020bc98 <etext+0x438>
ffffffffc0206e5a:	34700593          	li	a1,839
ffffffffc0206e5e:	00007517          	auipc	a0,0x7
ffffffffc0206e62:	88250513          	addi	a0,a0,-1918 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc0206e66:	de4f90ef          	jal	ffffffffc020044a <__panic>
ffffffffc0206e6a:	00007697          	auipc	a3,0x7
ffffffffc0206e6e:	b1668693          	addi	a3,a3,-1258 # ffffffffc020d980 <etext+0x2120>
ffffffffc0206e72:	00005617          	auipc	a2,0x5
ffffffffc0206e76:	e2660613          	addi	a2,a2,-474 # ffffffffc020bc98 <etext+0x438>
ffffffffc0206e7a:	34600593          	li	a1,838
ffffffffc0206e7e:	00007517          	auipc	a0,0x7
ffffffffc0206e82:	86250513          	addi	a0,a0,-1950 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc0206e86:	dc4f90ef          	jal	ffffffffc020044a <__panic>
ffffffffc0206e8a:	00007697          	auipc	a3,0x7
ffffffffc0206e8e:	aae68693          	addi	a3,a3,-1362 # ffffffffc020d938 <etext+0x20d8>
ffffffffc0206e92:	00005617          	auipc	a2,0x5
ffffffffc0206e96:	e0660613          	addi	a2,a2,-506 # ffffffffc020bc98 <etext+0x438>
ffffffffc0206e9a:	34500593          	li	a1,837
ffffffffc0206e9e:	00007517          	auipc	a0,0x7
ffffffffc0206ea2:	84250513          	addi	a0,a0,-1982 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc0206ea6:	da4f90ef          	jal	ffffffffc020044a <__panic>

ffffffffc0206eaa <user_main>:
ffffffffc0206eaa:	7179                	addi	sp,sp,-48
ffffffffc0206eac:	e84a                	sd	s2,16(sp)
ffffffffc0206eae:	00090917          	auipc	s2,0x90
ffffffffc0206eb2:	a1a90913          	addi	s2,s2,-1510 # ffffffffc02968c8 <current>
ffffffffc0206eb6:	00093783          	ld	a5,0(s2)
ffffffffc0206eba:	00007617          	auipc	a2,0x7
ffffffffc0206ebe:	b9e60613          	addi	a2,a2,-1122 # ffffffffc020da58 <etext+0x21f8>
ffffffffc0206ec2:	00007517          	auipc	a0,0x7
ffffffffc0206ec6:	b9e50513          	addi	a0,a0,-1122 # ffffffffc020da60 <etext+0x2200>
ffffffffc0206eca:	43cc                	lw	a1,4(a5)
ffffffffc0206ecc:	f406                	sd	ra,40(sp)
ffffffffc0206ece:	f022                	sd	s0,32(sp)
ffffffffc0206ed0:	ec26                	sd	s1,24(sp)
ffffffffc0206ed2:	e402                	sd	zero,8(sp)
ffffffffc0206ed4:	e032                	sd	a2,0(sp)
ffffffffc0206ed6:	ad0f90ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0206eda:	6782                	ld	a5,0(sp)
ffffffffc0206edc:	cfb9                	beqz	a5,ffffffffc0206f3a <user_main+0x90>
ffffffffc0206ede:	003c                	addi	a5,sp,8
ffffffffc0206ee0:	4401                	li	s0,0
ffffffffc0206ee2:	6398                	ld	a4,0(a5)
ffffffffc0206ee4:	07a1                	addi	a5,a5,8 # 1008 <_binary_bin_swap_img_size-0x6cf8>
ffffffffc0206ee6:	0405                	addi	s0,s0,1
ffffffffc0206ee8:	ff6d                	bnez	a4,ffffffffc0206ee2 <user_main+0x38>
ffffffffc0206eea:	00093703          	ld	a4,0(s2)
ffffffffc0206eee:	6789                	lui	a5,0x2
ffffffffc0206ef0:	ee078793          	addi	a5,a5,-288 # 1ee0 <_binary_bin_swap_img_size-0x5e20>
ffffffffc0206ef4:	6b04                	ld	s1,16(a4)
ffffffffc0206ef6:	734c                	ld	a1,160(a4)
ffffffffc0206ef8:	12000613          	li	a2,288
ffffffffc0206efc:	94be                	add	s1,s1,a5
ffffffffc0206efe:	8526                	mv	a0,s1
ffffffffc0206f00:	149040ef          	jal	ffffffffc020b848 <memcpy>
ffffffffc0206f04:	00093783          	ld	a5,0(s2)
ffffffffc0206f08:	0004059b          	sext.w	a1,s0
ffffffffc0206f0c:	860a                	mv	a2,sp
ffffffffc0206f0e:	f3c4                	sd	s1,160(a5)
ffffffffc0206f10:	00007517          	auipc	a0,0x7
ffffffffc0206f14:	b4850513          	addi	a0,a0,-1208 # ffffffffc020da58 <etext+0x21f8>
ffffffffc0206f18:	f60ff0ef          	jal	ffffffffc0206678 <do_execve>
ffffffffc0206f1c:	8126                	mv	sp,s1
ffffffffc0206f1e:	ad6fa06f          	j	ffffffffc02011f4 <__trapret>
ffffffffc0206f22:	00007617          	auipc	a2,0x7
ffffffffc0206f26:	b6660613          	addi	a2,a2,-1178 # ffffffffc020da88 <etext+0x2228>
ffffffffc0206f2a:	47f00593          	li	a1,1151
ffffffffc0206f2e:	00006517          	auipc	a0,0x6
ffffffffc0206f32:	7b250513          	addi	a0,a0,1970 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc0206f36:	d14f90ef          	jal	ffffffffc020044a <__panic>
ffffffffc0206f3a:	4401                	li	s0,0
ffffffffc0206f3c:	b77d                	j	ffffffffc0206eea <user_main+0x40>

ffffffffc0206f3e <do_yield>:
ffffffffc0206f3e:	00090797          	auipc	a5,0x90
ffffffffc0206f42:	98a7b783          	ld	a5,-1654(a5) # ffffffffc02968c8 <current>
ffffffffc0206f46:	4705                	li	a4,1
ffffffffc0206f48:	4501                	li	a0,0
ffffffffc0206f4a:	ef98                	sd	a4,24(a5)
ffffffffc0206f4c:	8082                	ret

ffffffffc0206f4e <do_wait>:
ffffffffc0206f4e:	c59d                	beqz	a1,ffffffffc0206f7c <do_wait+0x2e>
ffffffffc0206f50:	1101                	addi	sp,sp,-32
ffffffffc0206f52:	e02a                	sd	a0,0(sp)
ffffffffc0206f54:	00090517          	auipc	a0,0x90
ffffffffc0206f58:	97453503          	ld	a0,-1676(a0) # ffffffffc02968c8 <current>
ffffffffc0206f5c:	4685                	li	a3,1
ffffffffc0206f5e:	4611                	li	a2,4
ffffffffc0206f60:	7508                	ld	a0,40(a0)
ffffffffc0206f62:	ec06                	sd	ra,24(sp)
ffffffffc0206f64:	e42e                	sd	a1,8(sp)
ffffffffc0206f66:	bb0fd0ef          	jal	ffffffffc0204316 <user_mem_check>
ffffffffc0206f6a:	6702                	ld	a4,0(sp)
ffffffffc0206f6c:	67a2                	ld	a5,8(sp)
ffffffffc0206f6e:	c909                	beqz	a0,ffffffffc0206f80 <do_wait+0x32>
ffffffffc0206f70:	60e2                	ld	ra,24(sp)
ffffffffc0206f72:	85be                	mv	a1,a5
ffffffffc0206f74:	853a                	mv	a0,a4
ffffffffc0206f76:	6105                	addi	sp,sp,32
ffffffffc0206f78:	bceff06f          	j	ffffffffc0206346 <do_wait.part.0>
ffffffffc0206f7c:	bcaff06f          	j	ffffffffc0206346 <do_wait.part.0>
ffffffffc0206f80:	60e2                	ld	ra,24(sp)
ffffffffc0206f82:	5575                	li	a0,-3
ffffffffc0206f84:	6105                	addi	sp,sp,32
ffffffffc0206f86:	8082                	ret

ffffffffc0206f88 <do_kill>:
ffffffffc0206f88:	6789                	lui	a5,0x2
ffffffffc0206f8a:	fff5071b          	addiw	a4,a0,-1
ffffffffc0206f8e:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_bin_swap_img_size-0x5d02>
ffffffffc0206f90:	06e7e463          	bltu	a5,a4,ffffffffc0206ff8 <do_kill+0x70>
ffffffffc0206f94:	1101                	addi	sp,sp,-32
ffffffffc0206f96:	45a9                	li	a1,10
ffffffffc0206f98:	ec06                	sd	ra,24(sp)
ffffffffc0206f9a:	e42a                	sd	a0,8(sp)
ffffffffc0206f9c:	320040ef          	jal	ffffffffc020b2bc <hash32>
ffffffffc0206fa0:	02051793          	slli	a5,a0,0x20
ffffffffc0206fa4:	01c7d693          	srli	a3,a5,0x1c
ffffffffc0206fa8:	0008b797          	auipc	a5,0x8b
ffffffffc0206fac:	81878793          	addi	a5,a5,-2024 # ffffffffc02917c0 <hash_list>
ffffffffc0206fb0:	96be                	add	a3,a3,a5
ffffffffc0206fb2:	6622                	ld	a2,8(sp)
ffffffffc0206fb4:	8536                	mv	a0,a3
ffffffffc0206fb6:	a029                	j	ffffffffc0206fc0 <do_kill+0x38>
ffffffffc0206fb8:	f2c52703          	lw	a4,-212(a0)
ffffffffc0206fbc:	00c70963          	beq	a4,a2,ffffffffc0206fce <do_kill+0x46>
ffffffffc0206fc0:	6508                	ld	a0,8(a0)
ffffffffc0206fc2:	fea69be3          	bne	a3,a0,ffffffffc0206fb8 <do_kill+0x30>
ffffffffc0206fc6:	60e2                	ld	ra,24(sp)
ffffffffc0206fc8:	5575                	li	a0,-3
ffffffffc0206fca:	6105                	addi	sp,sp,32
ffffffffc0206fcc:	8082                	ret
ffffffffc0206fce:	fd852703          	lw	a4,-40(a0)
ffffffffc0206fd2:	00177693          	andi	a3,a4,1
ffffffffc0206fd6:	e29d                	bnez	a3,ffffffffc0206ffc <do_kill+0x74>
ffffffffc0206fd8:	4954                	lw	a3,20(a0)
ffffffffc0206fda:	00176713          	ori	a4,a4,1
ffffffffc0206fde:	fce52c23          	sw	a4,-40(a0)
ffffffffc0206fe2:	0006c663          	bltz	a3,ffffffffc0206fee <do_kill+0x66>
ffffffffc0206fe6:	4501                	li	a0,0
ffffffffc0206fe8:	60e2                	ld	ra,24(sp)
ffffffffc0206fea:	6105                	addi	sp,sp,32
ffffffffc0206fec:	8082                	ret
ffffffffc0206fee:	f2850513          	addi	a0,a0,-216
ffffffffc0206ff2:	454000ef          	jal	ffffffffc0207446 <wakeup_proc>
ffffffffc0206ff6:	bfc5                	j	ffffffffc0206fe6 <do_kill+0x5e>
ffffffffc0206ff8:	5575                	li	a0,-3
ffffffffc0206ffa:	8082                	ret
ffffffffc0206ffc:	555d                	li	a0,-9
ffffffffc0206ffe:	b7ed                	j	ffffffffc0206fe8 <do_kill+0x60>

ffffffffc0207000 <proc_init>:
ffffffffc0207000:	1101                	addi	sp,sp,-32
ffffffffc0207002:	e426                	sd	s1,8(sp)
ffffffffc0207004:	0008e797          	auipc	a5,0x8e
ffffffffc0207008:	7bc78793          	addi	a5,a5,1980 # ffffffffc02957c0 <proc_list>
ffffffffc020700c:	ec06                	sd	ra,24(sp)
ffffffffc020700e:	e822                	sd	s0,16(sp)
ffffffffc0207010:	e04a                	sd	s2,0(sp)
ffffffffc0207012:	0008a497          	auipc	s1,0x8a
ffffffffc0207016:	7ae48493          	addi	s1,s1,1966 # ffffffffc02917c0 <hash_list>
ffffffffc020701a:	e79c                	sd	a5,8(a5)
ffffffffc020701c:	e39c                	sd	a5,0(a5)
ffffffffc020701e:	0008e717          	auipc	a4,0x8e
ffffffffc0207022:	7a270713          	addi	a4,a4,1954 # ffffffffc02957c0 <proc_list>
ffffffffc0207026:	87a6                	mv	a5,s1
ffffffffc0207028:	e79c                	sd	a5,8(a5)
ffffffffc020702a:	e39c                	sd	a5,0(a5)
ffffffffc020702c:	07c1                	addi	a5,a5,16
ffffffffc020702e:	fee79de3          	bne	a5,a4,ffffffffc0207028 <proc_init+0x28>
ffffffffc0207032:	a91fe0ef          	jal	ffffffffc0205ac2 <alloc_proc>
ffffffffc0207036:	00090917          	auipc	s2,0x90
ffffffffc020703a:	8a290913          	addi	s2,s2,-1886 # ffffffffc02968d8 <idleproc>
ffffffffc020703e:	00a93023          	sd	a0,0(s2)
ffffffffc0207042:	842a                	mv	s0,a0
ffffffffc0207044:	12050c63          	beqz	a0,ffffffffc020717c <proc_init+0x17c>
ffffffffc0207048:	4689                	li	a3,2
ffffffffc020704a:	0000a717          	auipc	a4,0xa
ffffffffc020704e:	fb670713          	addi	a4,a4,-74 # ffffffffc0211000 <bootstack>
ffffffffc0207052:	4785                	li	a5,1
ffffffffc0207054:	e114                	sd	a3,0(a0)
ffffffffc0207056:	e918                	sd	a4,16(a0)
ffffffffc0207058:	ed1c                	sd	a5,24(a0)
ffffffffc020705a:	a1efe0ef          	jal	ffffffffc0205278 <files_create>
ffffffffc020705e:	14a43423          	sd	a0,328(s0)
ffffffffc0207062:	10050163          	beqz	a0,ffffffffc0207164 <proc_init+0x164>
ffffffffc0207066:	00093403          	ld	s0,0(s2)
ffffffffc020706a:	4641                	li	a2,16
ffffffffc020706c:	4581                	li	a1,0
ffffffffc020706e:	14843703          	ld	a4,328(s0)
ffffffffc0207072:	0b440413          	addi	s0,s0,180
ffffffffc0207076:	8522                	mv	a0,s0
ffffffffc0207078:	4b1c                	lw	a5,16(a4)
ffffffffc020707a:	2785                	addiw	a5,a5,1
ffffffffc020707c:	cb1c                	sw	a5,16(a4)
ffffffffc020707e:	77a040ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc0207082:	8522                	mv	a0,s0
ffffffffc0207084:	463d                	li	a2,15
ffffffffc0207086:	00007597          	auipc	a1,0x7
ffffffffc020708a:	a6258593          	addi	a1,a1,-1438 # ffffffffc020dae8 <etext+0x2288>
ffffffffc020708e:	7ba040ef          	jal	ffffffffc020b848 <memcpy>
ffffffffc0207092:	00090797          	auipc	a5,0x90
ffffffffc0207096:	82e7a783          	lw	a5,-2002(a5) # ffffffffc02968c0 <nr_process>
ffffffffc020709a:	00093703          	ld	a4,0(s2)
ffffffffc020709e:	4601                	li	a2,0
ffffffffc02070a0:	2785                	addiw	a5,a5,1
ffffffffc02070a2:	4581                	li	a1,0
ffffffffc02070a4:	fffff517          	auipc	a0,0xfffff
ffffffffc02070a8:	48450513          	addi	a0,a0,1156 # ffffffffc0206528 <init_main>
ffffffffc02070ac:	00090697          	auipc	a3,0x90
ffffffffc02070b0:	80e6be23          	sd	a4,-2020(a3) # ffffffffc02968c8 <current>
ffffffffc02070b4:	00090717          	auipc	a4,0x90
ffffffffc02070b8:	80f72623          	sw	a5,-2036(a4) # ffffffffc02968c0 <nr_process>
ffffffffc02070bc:	8daff0ef          	jal	ffffffffc0206196 <kernel_thread>
ffffffffc02070c0:	842a                	mv	s0,a0
ffffffffc02070c2:	08a05563          	blez	a0,ffffffffc020714c <proc_init+0x14c>
ffffffffc02070c6:	6789                	lui	a5,0x2
ffffffffc02070c8:	17f9                	addi	a5,a5,-2 # 1ffe <_binary_bin_swap_img_size-0x5d02>
ffffffffc02070ca:	fff5071b          	addiw	a4,a0,-1
ffffffffc02070ce:	02e7e463          	bltu	a5,a4,ffffffffc02070f6 <proc_init+0xf6>
ffffffffc02070d2:	45a9                	li	a1,10
ffffffffc02070d4:	1e8040ef          	jal	ffffffffc020b2bc <hash32>
ffffffffc02070d8:	02051713          	slli	a4,a0,0x20
ffffffffc02070dc:	01c75793          	srli	a5,a4,0x1c
ffffffffc02070e0:	00f486b3          	add	a3,s1,a5
ffffffffc02070e4:	87b6                	mv	a5,a3
ffffffffc02070e6:	a029                	j	ffffffffc02070f0 <proc_init+0xf0>
ffffffffc02070e8:	f2c7a703          	lw	a4,-212(a5)
ffffffffc02070ec:	04870d63          	beq	a4,s0,ffffffffc0207146 <proc_init+0x146>
ffffffffc02070f0:	679c                	ld	a5,8(a5)
ffffffffc02070f2:	fef69be3          	bne	a3,a5,ffffffffc02070e8 <proc_init+0xe8>
ffffffffc02070f6:	4781                	li	a5,0
ffffffffc02070f8:	0b478413          	addi	s0,a5,180
ffffffffc02070fc:	4641                	li	a2,16
ffffffffc02070fe:	4581                	li	a1,0
ffffffffc0207100:	8522                	mv	a0,s0
ffffffffc0207102:	0008f717          	auipc	a4,0x8f
ffffffffc0207106:	7cf73723          	sd	a5,1998(a4) # ffffffffc02968d0 <initproc>
ffffffffc020710a:	6ee040ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc020710e:	8522                	mv	a0,s0
ffffffffc0207110:	463d                	li	a2,15
ffffffffc0207112:	00007597          	auipc	a1,0x7
ffffffffc0207116:	9fe58593          	addi	a1,a1,-1538 # ffffffffc020db10 <etext+0x22b0>
ffffffffc020711a:	72e040ef          	jal	ffffffffc020b848 <memcpy>
ffffffffc020711e:	00093783          	ld	a5,0(s2)
ffffffffc0207122:	cbc9                	beqz	a5,ffffffffc02071b4 <proc_init+0x1b4>
ffffffffc0207124:	43dc                	lw	a5,4(a5)
ffffffffc0207126:	e7d9                	bnez	a5,ffffffffc02071b4 <proc_init+0x1b4>
ffffffffc0207128:	0008f797          	auipc	a5,0x8f
ffffffffc020712c:	7a87b783          	ld	a5,1960(a5) # ffffffffc02968d0 <initproc>
ffffffffc0207130:	c3b5                	beqz	a5,ffffffffc0207194 <proc_init+0x194>
ffffffffc0207132:	43d8                	lw	a4,4(a5)
ffffffffc0207134:	4785                	li	a5,1
ffffffffc0207136:	04f71f63          	bne	a4,a5,ffffffffc0207194 <proc_init+0x194>
ffffffffc020713a:	60e2                	ld	ra,24(sp)
ffffffffc020713c:	6442                	ld	s0,16(sp)
ffffffffc020713e:	64a2                	ld	s1,8(sp)
ffffffffc0207140:	6902                	ld	s2,0(sp)
ffffffffc0207142:	6105                	addi	sp,sp,32
ffffffffc0207144:	8082                	ret
ffffffffc0207146:	f2878793          	addi	a5,a5,-216
ffffffffc020714a:	b77d                	j	ffffffffc02070f8 <proc_init+0xf8>
ffffffffc020714c:	00007617          	auipc	a2,0x7
ffffffffc0207150:	9a460613          	addi	a2,a2,-1628 # ffffffffc020daf0 <etext+0x2290>
ffffffffc0207154:	4cb00593          	li	a1,1227
ffffffffc0207158:	00006517          	auipc	a0,0x6
ffffffffc020715c:	58850513          	addi	a0,a0,1416 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc0207160:	aeaf90ef          	jal	ffffffffc020044a <__panic>
ffffffffc0207164:	00007617          	auipc	a2,0x7
ffffffffc0207168:	95c60613          	addi	a2,a2,-1700 # ffffffffc020dac0 <etext+0x2260>
ffffffffc020716c:	4bf00593          	li	a1,1215
ffffffffc0207170:	00006517          	auipc	a0,0x6
ffffffffc0207174:	57050513          	addi	a0,a0,1392 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc0207178:	ad2f90ef          	jal	ffffffffc020044a <__panic>
ffffffffc020717c:	00007617          	auipc	a2,0x7
ffffffffc0207180:	92c60613          	addi	a2,a2,-1748 # ffffffffc020daa8 <etext+0x2248>
ffffffffc0207184:	4b500593          	li	a1,1205
ffffffffc0207188:	00006517          	auipc	a0,0x6
ffffffffc020718c:	55850513          	addi	a0,a0,1368 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc0207190:	abaf90ef          	jal	ffffffffc020044a <__panic>
ffffffffc0207194:	00007697          	auipc	a3,0x7
ffffffffc0207198:	9ac68693          	addi	a3,a3,-1620 # ffffffffc020db40 <etext+0x22e0>
ffffffffc020719c:	00005617          	auipc	a2,0x5
ffffffffc02071a0:	afc60613          	addi	a2,a2,-1284 # ffffffffc020bc98 <etext+0x438>
ffffffffc02071a4:	4d200593          	li	a1,1234
ffffffffc02071a8:	00006517          	auipc	a0,0x6
ffffffffc02071ac:	53850513          	addi	a0,a0,1336 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc02071b0:	a9af90ef          	jal	ffffffffc020044a <__panic>
ffffffffc02071b4:	00007697          	auipc	a3,0x7
ffffffffc02071b8:	96468693          	addi	a3,a3,-1692 # ffffffffc020db18 <etext+0x22b8>
ffffffffc02071bc:	00005617          	auipc	a2,0x5
ffffffffc02071c0:	adc60613          	addi	a2,a2,-1316 # ffffffffc020bc98 <etext+0x438>
ffffffffc02071c4:	4d100593          	li	a1,1233
ffffffffc02071c8:	00006517          	auipc	a0,0x6
ffffffffc02071cc:	51850513          	addi	a0,a0,1304 # ffffffffc020d6e0 <etext+0x1e80>
ffffffffc02071d0:	a7af90ef          	jal	ffffffffc020044a <__panic>

ffffffffc02071d4 <cpu_idle>:
ffffffffc02071d4:	1141                	addi	sp,sp,-16
ffffffffc02071d6:	e022                	sd	s0,0(sp)
ffffffffc02071d8:	e406                	sd	ra,8(sp)
ffffffffc02071da:	0008f417          	auipc	s0,0x8f
ffffffffc02071de:	6ee40413          	addi	s0,s0,1774 # ffffffffc02968c8 <current>
ffffffffc02071e2:	6018                	ld	a4,0(s0)
ffffffffc02071e4:	6f1c                	ld	a5,24(a4)
ffffffffc02071e6:	dffd                	beqz	a5,ffffffffc02071e4 <cpu_idle+0x10>
ffffffffc02071e8:	356000ef          	jal	ffffffffc020753e <schedule>
ffffffffc02071ec:	bfdd                	j	ffffffffc02071e2 <cpu_idle+0xe>

ffffffffc02071ee <lab6_set_priority>:
ffffffffc02071ee:	1101                	addi	sp,sp,-32
ffffffffc02071f0:	85aa                	mv	a1,a0
ffffffffc02071f2:	e42a                	sd	a0,8(sp)
ffffffffc02071f4:	00007517          	auipc	a0,0x7
ffffffffc02071f8:	97450513          	addi	a0,a0,-1676 # ffffffffc020db68 <etext+0x2308>
ffffffffc02071fc:	ec06                	sd	ra,24(sp)
ffffffffc02071fe:	fa9f80ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0207202:	65a2                	ld	a1,8(sp)
ffffffffc0207204:	0008f717          	auipc	a4,0x8f
ffffffffc0207208:	6c473703          	ld	a4,1732(a4) # ffffffffc02968c8 <current>
ffffffffc020720c:	4785                	li	a5,1
ffffffffc020720e:	c191                	beqz	a1,ffffffffc0207212 <lab6_set_priority+0x24>
ffffffffc0207210:	87ae                	mv	a5,a1
ffffffffc0207212:	60e2                	ld	ra,24(sp)
ffffffffc0207214:	14f72223          	sw	a5,324(a4)
ffffffffc0207218:	6105                	addi	sp,sp,32
ffffffffc020721a:	8082                	ret

ffffffffc020721c <do_sleep>:
ffffffffc020721c:	c531                	beqz	a0,ffffffffc0207268 <do_sleep+0x4c>
ffffffffc020721e:	7139                	addi	sp,sp,-64
ffffffffc0207220:	fc06                	sd	ra,56(sp)
ffffffffc0207222:	f822                	sd	s0,48(sp)
ffffffffc0207224:	100027f3          	csrr	a5,sstatus
ffffffffc0207228:	8b89                	andi	a5,a5,2
ffffffffc020722a:	e3a9                	bnez	a5,ffffffffc020726c <do_sleep+0x50>
ffffffffc020722c:	0008f797          	auipc	a5,0x8f
ffffffffc0207230:	69c7b783          	ld	a5,1692(a5) # ffffffffc02968c8 <current>
ffffffffc0207234:	1014                	addi	a3,sp,32
ffffffffc0207236:	80000737          	lui	a4,0x80000
ffffffffc020723a:	c82a                	sw	a0,16(sp)
ffffffffc020723c:	f436                	sd	a3,40(sp)
ffffffffc020723e:	f036                	sd	a3,32(sp)
ffffffffc0207240:	ec3e                	sd	a5,24(sp)
ffffffffc0207242:	4685                	li	a3,1
ffffffffc0207244:	0709                	addi	a4,a4,2 # ffffffff80000002 <_binary_bin_sfs_img_size+0xffffffff7ff8ad02>
ffffffffc0207246:	0808                	addi	a0,sp,16
ffffffffc0207248:	c394                	sw	a3,0(a5)
ffffffffc020724a:	0ee7a623          	sw	a4,236(a5)
ffffffffc020724e:	842a                	mv	s0,a0
ffffffffc0207250:	3a4000ef          	jal	ffffffffc02075f4 <add_timer>
ffffffffc0207254:	2ea000ef          	jal	ffffffffc020753e <schedule>
ffffffffc0207258:	8522                	mv	a0,s0
ffffffffc020725a:	460000ef          	jal	ffffffffc02076ba <del_timer>
ffffffffc020725e:	70e2                	ld	ra,56(sp)
ffffffffc0207260:	7442                	ld	s0,48(sp)
ffffffffc0207262:	4501                	li	a0,0
ffffffffc0207264:	6121                	addi	sp,sp,64
ffffffffc0207266:	8082                	ret
ffffffffc0207268:	4501                	li	a0,0
ffffffffc020726a:	8082                	ret
ffffffffc020726c:	e42a                	sd	a0,8(sp)
ffffffffc020726e:	96bf90ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0207272:	0008f797          	auipc	a5,0x8f
ffffffffc0207276:	6567b783          	ld	a5,1622(a5) # ffffffffc02968c8 <current>
ffffffffc020727a:	6522                	ld	a0,8(sp)
ffffffffc020727c:	1014                	addi	a3,sp,32
ffffffffc020727e:	80000737          	lui	a4,0x80000
ffffffffc0207282:	c82a                	sw	a0,16(sp)
ffffffffc0207284:	f436                	sd	a3,40(sp)
ffffffffc0207286:	f036                	sd	a3,32(sp)
ffffffffc0207288:	ec3e                	sd	a5,24(sp)
ffffffffc020728a:	4685                	li	a3,1
ffffffffc020728c:	0709                	addi	a4,a4,2 # ffffffff80000002 <_binary_bin_sfs_img_size+0xffffffff7ff8ad02>
ffffffffc020728e:	0808                	addi	a0,sp,16
ffffffffc0207290:	c394                	sw	a3,0(a5)
ffffffffc0207292:	0ee7a623          	sw	a4,236(a5)
ffffffffc0207296:	842a                	mv	s0,a0
ffffffffc0207298:	35c000ef          	jal	ffffffffc02075f4 <add_timer>
ffffffffc020729c:	937f90ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc02072a0:	bf55                	j	ffffffffc0207254 <do_sleep+0x38>

ffffffffc02072a2 <switch_to>:
ffffffffc02072a2:	00153023          	sd	ra,0(a0)
ffffffffc02072a6:	00253423          	sd	sp,8(a0)
ffffffffc02072aa:	e900                	sd	s0,16(a0)
ffffffffc02072ac:	ed04                	sd	s1,24(a0)
ffffffffc02072ae:	03253023          	sd	s2,32(a0)
ffffffffc02072b2:	03353423          	sd	s3,40(a0)
ffffffffc02072b6:	03453823          	sd	s4,48(a0)
ffffffffc02072ba:	03553c23          	sd	s5,56(a0)
ffffffffc02072be:	05653023          	sd	s6,64(a0)
ffffffffc02072c2:	05753423          	sd	s7,72(a0)
ffffffffc02072c6:	05853823          	sd	s8,80(a0)
ffffffffc02072ca:	05953c23          	sd	s9,88(a0)
ffffffffc02072ce:	07a53023          	sd	s10,96(a0)
ffffffffc02072d2:	07b53423          	sd	s11,104(a0)
ffffffffc02072d6:	0005b083          	ld	ra,0(a1)
ffffffffc02072da:	0085b103          	ld	sp,8(a1)
ffffffffc02072de:	6980                	ld	s0,16(a1)
ffffffffc02072e0:	6d84                	ld	s1,24(a1)
ffffffffc02072e2:	0205b903          	ld	s2,32(a1)
ffffffffc02072e6:	0285b983          	ld	s3,40(a1)
ffffffffc02072ea:	0305ba03          	ld	s4,48(a1)
ffffffffc02072ee:	0385ba83          	ld	s5,56(a1)
ffffffffc02072f2:	0405bb03          	ld	s6,64(a1)
ffffffffc02072f6:	0485bb83          	ld	s7,72(a1)
ffffffffc02072fa:	0505bc03          	ld	s8,80(a1)
ffffffffc02072fe:	0585bc83          	ld	s9,88(a1)
ffffffffc0207302:	0605bd03          	ld	s10,96(a1)
ffffffffc0207306:	0685bd83          	ld	s11,104(a1)
ffffffffc020730a:	8082                	ret

ffffffffc020730c <RR_init>:
ffffffffc020730c:	e508                	sd	a0,8(a0)
ffffffffc020730e:	e108                	sd	a0,0(a0)
ffffffffc0207310:	00052823          	sw	zero,16(a0)
ffffffffc0207314:	8082                	ret

ffffffffc0207316 <RR_pick_next>:
ffffffffc0207316:	651c                	ld	a5,8(a0)
ffffffffc0207318:	00f50563          	beq	a0,a5,ffffffffc0207322 <RR_pick_next+0xc>
ffffffffc020731c:	ef078513          	addi	a0,a5,-272
ffffffffc0207320:	8082                	ret
ffffffffc0207322:	4501                	li	a0,0
ffffffffc0207324:	8082                	ret

ffffffffc0207326 <RR_proc_tick>:
ffffffffc0207326:	1205a783          	lw	a5,288(a1)
ffffffffc020732a:	00f05563          	blez	a5,ffffffffc0207334 <RR_proc_tick+0xe>
ffffffffc020732e:	37fd                	addiw	a5,a5,-1
ffffffffc0207330:	12f5a023          	sw	a5,288(a1)
ffffffffc0207334:	e399                	bnez	a5,ffffffffc020733a <RR_proc_tick+0x14>
ffffffffc0207336:	4785                	li	a5,1
ffffffffc0207338:	ed9c                	sd	a5,24(a1)
ffffffffc020733a:	8082                	ret

ffffffffc020733c <RR_dequeue>:
ffffffffc020733c:	1185b703          	ld	a4,280(a1)
ffffffffc0207340:	11058793          	addi	a5,a1,272
ffffffffc0207344:	02e78263          	beq	a5,a4,ffffffffc0207368 <RR_dequeue+0x2c>
ffffffffc0207348:	1085b683          	ld	a3,264(a1)
ffffffffc020734c:	00a69e63          	bne	a3,a0,ffffffffc0207368 <RR_dequeue+0x2c>
ffffffffc0207350:	1105b503          	ld	a0,272(a1)
ffffffffc0207354:	4a90                	lw	a2,16(a3)
ffffffffc0207356:	e518                	sd	a4,8(a0)
ffffffffc0207358:	e308                	sd	a0,0(a4)
ffffffffc020735a:	10f5bc23          	sd	a5,280(a1)
ffffffffc020735e:	10f5b823          	sd	a5,272(a1)
ffffffffc0207362:	367d                	addiw	a2,a2,-1
ffffffffc0207364:	ca90                	sw	a2,16(a3)
ffffffffc0207366:	8082                	ret
ffffffffc0207368:	1141                	addi	sp,sp,-16
ffffffffc020736a:	00007697          	auipc	a3,0x7
ffffffffc020736e:	81668693          	addi	a3,a3,-2026 # ffffffffc020db80 <etext+0x2320>
ffffffffc0207372:	00005617          	auipc	a2,0x5
ffffffffc0207376:	92660613          	addi	a2,a2,-1754 # ffffffffc020bc98 <etext+0x438>
ffffffffc020737a:	03c00593          	li	a1,60
ffffffffc020737e:	00007517          	auipc	a0,0x7
ffffffffc0207382:	83a50513          	addi	a0,a0,-1990 # ffffffffc020dbb8 <etext+0x2358>
ffffffffc0207386:	e406                	sd	ra,8(sp)
ffffffffc0207388:	8c2f90ef          	jal	ffffffffc020044a <__panic>

ffffffffc020738c <RR_enqueue>:
ffffffffc020738c:	1185b703          	ld	a4,280(a1)
ffffffffc0207390:	11058793          	addi	a5,a1,272
ffffffffc0207394:	02e79d63          	bne	a5,a4,ffffffffc02073ce <RR_enqueue+0x42>
ffffffffc0207398:	6118                	ld	a4,0(a0)
ffffffffc020739a:	1205a683          	lw	a3,288(a1)
ffffffffc020739e:	e11c                	sd	a5,0(a0)
ffffffffc02073a0:	e71c                	sd	a5,8(a4)
ffffffffc02073a2:	10e5b823          	sd	a4,272(a1)
ffffffffc02073a6:	10a5bc23          	sd	a0,280(a1)
ffffffffc02073aa:	495c                	lw	a5,20(a0)
ffffffffc02073ac:	ea89                	bnez	a3,ffffffffc02073be <RR_enqueue+0x32>
ffffffffc02073ae:	12f5a023          	sw	a5,288(a1)
ffffffffc02073b2:	491c                	lw	a5,16(a0)
ffffffffc02073b4:	10a5b423          	sd	a0,264(a1)
ffffffffc02073b8:	2785                	addiw	a5,a5,1
ffffffffc02073ba:	c91c                	sw	a5,16(a0)
ffffffffc02073bc:	8082                	ret
ffffffffc02073be:	fed7c8e3          	blt	a5,a3,ffffffffc02073ae <RR_enqueue+0x22>
ffffffffc02073c2:	491c                	lw	a5,16(a0)
ffffffffc02073c4:	10a5b423          	sd	a0,264(a1)
ffffffffc02073c8:	2785                	addiw	a5,a5,1
ffffffffc02073ca:	c91c                	sw	a5,16(a0)
ffffffffc02073cc:	8082                	ret
ffffffffc02073ce:	1141                	addi	sp,sp,-16
ffffffffc02073d0:	00007697          	auipc	a3,0x7
ffffffffc02073d4:	80868693          	addi	a3,a3,-2040 # ffffffffc020dbd8 <etext+0x2378>
ffffffffc02073d8:	00005617          	auipc	a2,0x5
ffffffffc02073dc:	8c060613          	addi	a2,a2,-1856 # ffffffffc020bc98 <etext+0x438>
ffffffffc02073e0:	02800593          	li	a1,40
ffffffffc02073e4:	00006517          	auipc	a0,0x6
ffffffffc02073e8:	7d450513          	addi	a0,a0,2004 # ffffffffc020dbb8 <etext+0x2358>
ffffffffc02073ec:	e406                	sd	ra,8(sp)
ffffffffc02073ee:	85cf90ef          	jal	ffffffffc020044a <__panic>

ffffffffc02073f2 <sched_init>:
ffffffffc02073f2:	0008a797          	auipc	a5,0x8a
ffffffffc02073f6:	c2e78793          	addi	a5,a5,-978 # ffffffffc0291020 <default_sched_class>
ffffffffc02073fa:	1141                	addi	sp,sp,-16
ffffffffc02073fc:	6794                	ld	a3,8(a5)
ffffffffc02073fe:	0008f717          	auipc	a4,0x8f
ffffffffc0207402:	4ef73523          	sd	a5,1258(a4) # ffffffffc02968e8 <sched_class>
ffffffffc0207406:	e406                	sd	ra,8(sp)
ffffffffc0207408:	0008e797          	auipc	a5,0x8e
ffffffffc020740c:	3e878793          	addi	a5,a5,1000 # ffffffffc02957f0 <timer_list>
ffffffffc0207410:	0008e717          	auipc	a4,0x8e
ffffffffc0207414:	3c070713          	addi	a4,a4,960 # ffffffffc02957d0 <__rq>
ffffffffc0207418:	4615                	li	a2,5
ffffffffc020741a:	e79c                	sd	a5,8(a5)
ffffffffc020741c:	e39c                	sd	a5,0(a5)
ffffffffc020741e:	853a                	mv	a0,a4
ffffffffc0207420:	cb50                	sw	a2,20(a4)
ffffffffc0207422:	0008f797          	auipc	a5,0x8f
ffffffffc0207426:	4ae7bf23          	sd	a4,1214(a5) # ffffffffc02968e0 <rq>
ffffffffc020742a:	9682                	jalr	a3
ffffffffc020742c:	0008f797          	auipc	a5,0x8f
ffffffffc0207430:	4bc7b783          	ld	a5,1212(a5) # ffffffffc02968e8 <sched_class>
ffffffffc0207434:	60a2                	ld	ra,8(sp)
ffffffffc0207436:	00006517          	auipc	a0,0x6
ffffffffc020743a:	7d250513          	addi	a0,a0,2002 # ffffffffc020dc08 <etext+0x23a8>
ffffffffc020743e:	638c                	ld	a1,0(a5)
ffffffffc0207440:	0141                	addi	sp,sp,16
ffffffffc0207442:	d65f806f          	j	ffffffffc02001a6 <cprintf>

ffffffffc0207446 <wakeup_proc>:
ffffffffc0207446:	4118                	lw	a4,0(a0)
ffffffffc0207448:	1101                	addi	sp,sp,-32
ffffffffc020744a:	ec06                	sd	ra,24(sp)
ffffffffc020744c:	478d                	li	a5,3
ffffffffc020744e:	0cf70863          	beq	a4,a5,ffffffffc020751e <wakeup_proc+0xd8>
ffffffffc0207452:	85aa                	mv	a1,a0
ffffffffc0207454:	100027f3          	csrr	a5,sstatus
ffffffffc0207458:	8b89                	andi	a5,a5,2
ffffffffc020745a:	e3b1                	bnez	a5,ffffffffc020749e <wakeup_proc+0x58>
ffffffffc020745c:	4789                	li	a5,2
ffffffffc020745e:	08f70563          	beq	a4,a5,ffffffffc02074e8 <wakeup_proc+0xa2>
ffffffffc0207462:	0008f717          	auipc	a4,0x8f
ffffffffc0207466:	46673703          	ld	a4,1126(a4) # ffffffffc02968c8 <current>
ffffffffc020746a:	0e052623          	sw	zero,236(a0)
ffffffffc020746e:	c11c                	sw	a5,0(a0)
ffffffffc0207470:	02e50463          	beq	a0,a4,ffffffffc0207498 <wakeup_proc+0x52>
ffffffffc0207474:	0008f797          	auipc	a5,0x8f
ffffffffc0207478:	4647b783          	ld	a5,1124(a5) # ffffffffc02968d8 <idleproc>
ffffffffc020747c:	00f50e63          	beq	a0,a5,ffffffffc0207498 <wakeup_proc+0x52>
ffffffffc0207480:	0008f797          	auipc	a5,0x8f
ffffffffc0207484:	4687b783          	ld	a5,1128(a5) # ffffffffc02968e8 <sched_class>
ffffffffc0207488:	60e2                	ld	ra,24(sp)
ffffffffc020748a:	0008f517          	auipc	a0,0x8f
ffffffffc020748e:	45653503          	ld	a0,1110(a0) # ffffffffc02968e0 <rq>
ffffffffc0207492:	6b9c                	ld	a5,16(a5)
ffffffffc0207494:	6105                	addi	sp,sp,32
ffffffffc0207496:	8782                	jr	a5
ffffffffc0207498:	60e2                	ld	ra,24(sp)
ffffffffc020749a:	6105                	addi	sp,sp,32
ffffffffc020749c:	8082                	ret
ffffffffc020749e:	e42a                	sd	a0,8(sp)
ffffffffc02074a0:	f38f90ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc02074a4:	65a2                	ld	a1,8(sp)
ffffffffc02074a6:	4789                	li	a5,2
ffffffffc02074a8:	4198                	lw	a4,0(a1)
ffffffffc02074aa:	04f70d63          	beq	a4,a5,ffffffffc0207504 <wakeup_proc+0xbe>
ffffffffc02074ae:	0008f717          	auipc	a4,0x8f
ffffffffc02074b2:	41a73703          	ld	a4,1050(a4) # ffffffffc02968c8 <current>
ffffffffc02074b6:	0e05a623          	sw	zero,236(a1)
ffffffffc02074ba:	c19c                	sw	a5,0(a1)
ffffffffc02074bc:	02e58263          	beq	a1,a4,ffffffffc02074e0 <wakeup_proc+0x9a>
ffffffffc02074c0:	0008f797          	auipc	a5,0x8f
ffffffffc02074c4:	4187b783          	ld	a5,1048(a5) # ffffffffc02968d8 <idleproc>
ffffffffc02074c8:	00f58c63          	beq	a1,a5,ffffffffc02074e0 <wakeup_proc+0x9a>
ffffffffc02074cc:	0008f797          	auipc	a5,0x8f
ffffffffc02074d0:	41c7b783          	ld	a5,1052(a5) # ffffffffc02968e8 <sched_class>
ffffffffc02074d4:	0008f517          	auipc	a0,0x8f
ffffffffc02074d8:	40c53503          	ld	a0,1036(a0) # ffffffffc02968e0 <rq>
ffffffffc02074dc:	6b9c                	ld	a5,16(a5)
ffffffffc02074de:	9782                	jalr	a5
ffffffffc02074e0:	60e2                	ld	ra,24(sp)
ffffffffc02074e2:	6105                	addi	sp,sp,32
ffffffffc02074e4:	eeef906f          	j	ffffffffc0200bd2 <intr_enable>
ffffffffc02074e8:	60e2                	ld	ra,24(sp)
ffffffffc02074ea:	00006617          	auipc	a2,0x6
ffffffffc02074ee:	76e60613          	addi	a2,a2,1902 # ffffffffc020dc58 <etext+0x23f8>
ffffffffc02074f2:	05200593          	li	a1,82
ffffffffc02074f6:	00006517          	auipc	a0,0x6
ffffffffc02074fa:	74a50513          	addi	a0,a0,1866 # ffffffffc020dc40 <etext+0x23e0>
ffffffffc02074fe:	6105                	addi	sp,sp,32
ffffffffc0207500:	fb5f806f          	j	ffffffffc02004b4 <__warn>
ffffffffc0207504:	00006617          	auipc	a2,0x6
ffffffffc0207508:	75460613          	addi	a2,a2,1876 # ffffffffc020dc58 <etext+0x23f8>
ffffffffc020750c:	05200593          	li	a1,82
ffffffffc0207510:	00006517          	auipc	a0,0x6
ffffffffc0207514:	73050513          	addi	a0,a0,1840 # ffffffffc020dc40 <etext+0x23e0>
ffffffffc0207518:	f9df80ef          	jal	ffffffffc02004b4 <__warn>
ffffffffc020751c:	b7d1                	j	ffffffffc02074e0 <wakeup_proc+0x9a>
ffffffffc020751e:	00006697          	auipc	a3,0x6
ffffffffc0207522:	70268693          	addi	a3,a3,1794 # ffffffffc020dc20 <etext+0x23c0>
ffffffffc0207526:	00004617          	auipc	a2,0x4
ffffffffc020752a:	77260613          	addi	a2,a2,1906 # ffffffffc020bc98 <etext+0x438>
ffffffffc020752e:	04300593          	li	a1,67
ffffffffc0207532:	00006517          	auipc	a0,0x6
ffffffffc0207536:	70e50513          	addi	a0,a0,1806 # ffffffffc020dc40 <etext+0x23e0>
ffffffffc020753a:	f11f80ef          	jal	ffffffffc020044a <__panic>

ffffffffc020753e <schedule>:
ffffffffc020753e:	7139                	addi	sp,sp,-64
ffffffffc0207540:	fc06                	sd	ra,56(sp)
ffffffffc0207542:	f822                	sd	s0,48(sp)
ffffffffc0207544:	f426                	sd	s1,40(sp)
ffffffffc0207546:	f04a                	sd	s2,32(sp)
ffffffffc0207548:	ec4e                	sd	s3,24(sp)
ffffffffc020754a:	100027f3          	csrr	a5,sstatus
ffffffffc020754e:	8b89                	andi	a5,a5,2
ffffffffc0207550:	4981                	li	s3,0
ffffffffc0207552:	efc9                	bnez	a5,ffffffffc02075ec <schedule+0xae>
ffffffffc0207554:	0008f417          	auipc	s0,0x8f
ffffffffc0207558:	37440413          	addi	s0,s0,884 # ffffffffc02968c8 <current>
ffffffffc020755c:	600c                	ld	a1,0(s0)
ffffffffc020755e:	4789                	li	a5,2
ffffffffc0207560:	0008f497          	auipc	s1,0x8f
ffffffffc0207564:	38048493          	addi	s1,s1,896 # ffffffffc02968e0 <rq>
ffffffffc0207568:	4198                	lw	a4,0(a1)
ffffffffc020756a:	0005bc23          	sd	zero,24(a1)
ffffffffc020756e:	0008f917          	auipc	s2,0x8f
ffffffffc0207572:	37a90913          	addi	s2,s2,890 # ffffffffc02968e8 <sched_class>
ffffffffc0207576:	04f70f63          	beq	a4,a5,ffffffffc02075d4 <schedule+0x96>
ffffffffc020757a:	00093783          	ld	a5,0(s2)
ffffffffc020757e:	6088                	ld	a0,0(s1)
ffffffffc0207580:	739c                	ld	a5,32(a5)
ffffffffc0207582:	9782                	jalr	a5
ffffffffc0207584:	85aa                	mv	a1,a0
ffffffffc0207586:	c131                	beqz	a0,ffffffffc02075ca <schedule+0x8c>
ffffffffc0207588:	00093783          	ld	a5,0(s2)
ffffffffc020758c:	6088                	ld	a0,0(s1)
ffffffffc020758e:	e42e                	sd	a1,8(sp)
ffffffffc0207590:	6f9c                	ld	a5,24(a5)
ffffffffc0207592:	9782                	jalr	a5
ffffffffc0207594:	65a2                	ld	a1,8(sp)
ffffffffc0207596:	459c                	lw	a5,8(a1)
ffffffffc0207598:	6018                	ld	a4,0(s0)
ffffffffc020759a:	2785                	addiw	a5,a5,1
ffffffffc020759c:	c59c                	sw	a5,8(a1)
ffffffffc020759e:	00b70563          	beq	a4,a1,ffffffffc02075a8 <schedule+0x6a>
ffffffffc02075a2:	852e                	mv	a0,a1
ffffffffc02075a4:	f42fe0ef          	jal	ffffffffc0205ce6 <proc_run>
ffffffffc02075a8:	00099963          	bnez	s3,ffffffffc02075ba <schedule+0x7c>
ffffffffc02075ac:	70e2                	ld	ra,56(sp)
ffffffffc02075ae:	7442                	ld	s0,48(sp)
ffffffffc02075b0:	74a2                	ld	s1,40(sp)
ffffffffc02075b2:	7902                	ld	s2,32(sp)
ffffffffc02075b4:	69e2                	ld	s3,24(sp)
ffffffffc02075b6:	6121                	addi	sp,sp,64
ffffffffc02075b8:	8082                	ret
ffffffffc02075ba:	7442                	ld	s0,48(sp)
ffffffffc02075bc:	70e2                	ld	ra,56(sp)
ffffffffc02075be:	74a2                	ld	s1,40(sp)
ffffffffc02075c0:	7902                	ld	s2,32(sp)
ffffffffc02075c2:	69e2                	ld	s3,24(sp)
ffffffffc02075c4:	6121                	addi	sp,sp,64
ffffffffc02075c6:	e0cf906f          	j	ffffffffc0200bd2 <intr_enable>
ffffffffc02075ca:	0008f597          	auipc	a1,0x8f
ffffffffc02075ce:	30e5b583          	ld	a1,782(a1) # ffffffffc02968d8 <idleproc>
ffffffffc02075d2:	b7d1                	j	ffffffffc0207596 <schedule+0x58>
ffffffffc02075d4:	0008f797          	auipc	a5,0x8f
ffffffffc02075d8:	3047b783          	ld	a5,772(a5) # ffffffffc02968d8 <idleproc>
ffffffffc02075dc:	f8f58fe3          	beq	a1,a5,ffffffffc020757a <schedule+0x3c>
ffffffffc02075e0:	00093783          	ld	a5,0(s2)
ffffffffc02075e4:	6088                	ld	a0,0(s1)
ffffffffc02075e6:	6b9c                	ld	a5,16(a5)
ffffffffc02075e8:	9782                	jalr	a5
ffffffffc02075ea:	bf41                	j	ffffffffc020757a <schedule+0x3c>
ffffffffc02075ec:	decf90ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc02075f0:	4985                	li	s3,1
ffffffffc02075f2:	b78d                	j	ffffffffc0207554 <schedule+0x16>

ffffffffc02075f4 <add_timer>:
ffffffffc02075f4:	1101                	addi	sp,sp,-32
ffffffffc02075f6:	ec06                	sd	ra,24(sp)
ffffffffc02075f8:	100027f3          	csrr	a5,sstatus
ffffffffc02075fc:	8b89                	andi	a5,a5,2
ffffffffc02075fe:	4801                	li	a6,0
ffffffffc0207600:	e7bd                	bnez	a5,ffffffffc020766e <add_timer+0x7a>
ffffffffc0207602:	4118                	lw	a4,0(a0)
ffffffffc0207604:	cb3d                	beqz	a4,ffffffffc020767a <add_timer+0x86>
ffffffffc0207606:	651c                	ld	a5,8(a0)
ffffffffc0207608:	cbad                	beqz	a5,ffffffffc020767a <add_timer+0x86>
ffffffffc020760a:	6d1c                	ld	a5,24(a0)
ffffffffc020760c:	01050593          	addi	a1,a0,16
ffffffffc0207610:	08f59563          	bne	a1,a5,ffffffffc020769a <add_timer+0xa6>
ffffffffc0207614:	0008e617          	auipc	a2,0x8e
ffffffffc0207618:	1dc60613          	addi	a2,a2,476 # ffffffffc02957f0 <timer_list>
ffffffffc020761c:	661c                	ld	a5,8(a2)
ffffffffc020761e:	00c79863          	bne	a5,a2,ffffffffc020762e <add_timer+0x3a>
ffffffffc0207622:	a805                	j	ffffffffc0207652 <add_timer+0x5e>
ffffffffc0207624:	679c                	ld	a5,8(a5)
ffffffffc0207626:	9f15                	subw	a4,a4,a3
ffffffffc0207628:	c118                	sw	a4,0(a0)
ffffffffc020762a:	02c78463          	beq	a5,a2,ffffffffc0207652 <add_timer+0x5e>
ffffffffc020762e:	ff07a683          	lw	a3,-16(a5)
ffffffffc0207632:	fed779e3          	bgeu	a4,a3,ffffffffc0207624 <add_timer+0x30>
ffffffffc0207636:	9e99                	subw	a3,a3,a4
ffffffffc0207638:	6398                	ld	a4,0(a5)
ffffffffc020763a:	fed7a823          	sw	a3,-16(a5)
ffffffffc020763e:	e38c                	sd	a1,0(a5)
ffffffffc0207640:	e70c                	sd	a1,8(a4)
ffffffffc0207642:	e918                	sd	a4,16(a0)
ffffffffc0207644:	ed1c                	sd	a5,24(a0)
ffffffffc0207646:	02080163          	beqz	a6,ffffffffc0207668 <add_timer+0x74>
ffffffffc020764a:	60e2                	ld	ra,24(sp)
ffffffffc020764c:	6105                	addi	sp,sp,32
ffffffffc020764e:	d84f906f          	j	ffffffffc0200bd2 <intr_enable>
ffffffffc0207652:	0008e797          	auipc	a5,0x8e
ffffffffc0207656:	19e78793          	addi	a5,a5,414 # ffffffffc02957f0 <timer_list>
ffffffffc020765a:	6398                	ld	a4,0(a5)
ffffffffc020765c:	e38c                	sd	a1,0(a5)
ffffffffc020765e:	e70c                	sd	a1,8(a4)
ffffffffc0207660:	e918                	sd	a4,16(a0)
ffffffffc0207662:	ed1c                	sd	a5,24(a0)
ffffffffc0207664:	fe0813e3          	bnez	a6,ffffffffc020764a <add_timer+0x56>
ffffffffc0207668:	60e2                	ld	ra,24(sp)
ffffffffc020766a:	6105                	addi	sp,sp,32
ffffffffc020766c:	8082                	ret
ffffffffc020766e:	e42a                	sd	a0,8(sp)
ffffffffc0207670:	d68f90ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0207674:	6522                	ld	a0,8(sp)
ffffffffc0207676:	4805                	li	a6,1
ffffffffc0207678:	b769                	j	ffffffffc0207602 <add_timer+0xe>
ffffffffc020767a:	00006697          	auipc	a3,0x6
ffffffffc020767e:	5fe68693          	addi	a3,a3,1534 # ffffffffc020dc78 <etext+0x2418>
ffffffffc0207682:	00004617          	auipc	a2,0x4
ffffffffc0207686:	61660613          	addi	a2,a2,1558 # ffffffffc020bc98 <etext+0x438>
ffffffffc020768a:	07a00593          	li	a1,122
ffffffffc020768e:	00006517          	auipc	a0,0x6
ffffffffc0207692:	5b250513          	addi	a0,a0,1458 # ffffffffc020dc40 <etext+0x23e0>
ffffffffc0207696:	db5f80ef          	jal	ffffffffc020044a <__panic>
ffffffffc020769a:	00006697          	auipc	a3,0x6
ffffffffc020769e:	60e68693          	addi	a3,a3,1550 # ffffffffc020dca8 <etext+0x2448>
ffffffffc02076a2:	00004617          	auipc	a2,0x4
ffffffffc02076a6:	5f660613          	addi	a2,a2,1526 # ffffffffc020bc98 <etext+0x438>
ffffffffc02076aa:	07b00593          	li	a1,123
ffffffffc02076ae:	00006517          	auipc	a0,0x6
ffffffffc02076b2:	59250513          	addi	a0,a0,1426 # ffffffffc020dc40 <etext+0x23e0>
ffffffffc02076b6:	d95f80ef          	jal	ffffffffc020044a <__panic>

ffffffffc02076ba <del_timer>:
ffffffffc02076ba:	100027f3          	csrr	a5,sstatus
ffffffffc02076be:	8b89                	andi	a5,a5,2
ffffffffc02076c0:	ef95                	bnez	a5,ffffffffc02076fc <del_timer+0x42>
ffffffffc02076c2:	6d1c                	ld	a5,24(a0)
ffffffffc02076c4:	01050713          	addi	a4,a0,16
ffffffffc02076c8:	4601                	li	a2,0
ffffffffc02076ca:	02f70863          	beq	a4,a5,ffffffffc02076fa <del_timer+0x40>
ffffffffc02076ce:	0008e597          	auipc	a1,0x8e
ffffffffc02076d2:	12258593          	addi	a1,a1,290 # ffffffffc02957f0 <timer_list>
ffffffffc02076d6:	4114                	lw	a3,0(a0)
ffffffffc02076d8:	00b78863          	beq	a5,a1,ffffffffc02076e8 <del_timer+0x2e>
ffffffffc02076dc:	c691                	beqz	a3,ffffffffc02076e8 <del_timer+0x2e>
ffffffffc02076de:	ff07a583          	lw	a1,-16(a5)
ffffffffc02076e2:	9ead                	addw	a3,a3,a1
ffffffffc02076e4:	fed7a823          	sw	a3,-16(a5)
ffffffffc02076e8:	6914                	ld	a3,16(a0)
ffffffffc02076ea:	e69c                	sd	a5,8(a3)
ffffffffc02076ec:	e394                	sd	a3,0(a5)
ffffffffc02076ee:	ed18                	sd	a4,24(a0)
ffffffffc02076f0:	e918                	sd	a4,16(a0)
ffffffffc02076f2:	e211                	bnez	a2,ffffffffc02076f6 <del_timer+0x3c>
ffffffffc02076f4:	8082                	ret
ffffffffc02076f6:	cdcf906f          	j	ffffffffc0200bd2 <intr_enable>
ffffffffc02076fa:	8082                	ret
ffffffffc02076fc:	1101                	addi	sp,sp,-32
ffffffffc02076fe:	e42a                	sd	a0,8(sp)
ffffffffc0207700:	ec06                	sd	ra,24(sp)
ffffffffc0207702:	cd6f90ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0207706:	6522                	ld	a0,8(sp)
ffffffffc0207708:	4605                	li	a2,1
ffffffffc020770a:	6d1c                	ld	a5,24(a0)
ffffffffc020770c:	01050713          	addi	a4,a0,16
ffffffffc0207710:	02f70863          	beq	a4,a5,ffffffffc0207740 <del_timer+0x86>
ffffffffc0207714:	0008e597          	auipc	a1,0x8e
ffffffffc0207718:	0dc58593          	addi	a1,a1,220 # ffffffffc02957f0 <timer_list>
ffffffffc020771c:	4114                	lw	a3,0(a0)
ffffffffc020771e:	00b78863          	beq	a5,a1,ffffffffc020772e <del_timer+0x74>
ffffffffc0207722:	c691                	beqz	a3,ffffffffc020772e <del_timer+0x74>
ffffffffc0207724:	ff07a583          	lw	a1,-16(a5)
ffffffffc0207728:	9ead                	addw	a3,a3,a1
ffffffffc020772a:	fed7a823          	sw	a3,-16(a5)
ffffffffc020772e:	6914                	ld	a3,16(a0)
ffffffffc0207730:	e69c                	sd	a5,8(a3)
ffffffffc0207732:	e394                	sd	a3,0(a5)
ffffffffc0207734:	ed18                	sd	a4,24(a0)
ffffffffc0207736:	e918                	sd	a4,16(a0)
ffffffffc0207738:	e601                	bnez	a2,ffffffffc0207740 <del_timer+0x86>
ffffffffc020773a:	60e2                	ld	ra,24(sp)
ffffffffc020773c:	6105                	addi	sp,sp,32
ffffffffc020773e:	8082                	ret
ffffffffc0207740:	60e2                	ld	ra,24(sp)
ffffffffc0207742:	6105                	addi	sp,sp,32
ffffffffc0207744:	c8ef906f          	j	ffffffffc0200bd2 <intr_enable>

ffffffffc0207748 <run_timer_list>:
ffffffffc0207748:	7179                	addi	sp,sp,-48
ffffffffc020774a:	f406                	sd	ra,40(sp)
ffffffffc020774c:	f022                	sd	s0,32(sp)
ffffffffc020774e:	e44e                	sd	s3,8(sp)
ffffffffc0207750:	e052                	sd	s4,0(sp)
ffffffffc0207752:	100027f3          	csrr	a5,sstatus
ffffffffc0207756:	8b89                	andi	a5,a5,2
ffffffffc0207758:	0e079b63          	bnez	a5,ffffffffc020784e <run_timer_list+0x106>
ffffffffc020775c:	0008e997          	auipc	s3,0x8e
ffffffffc0207760:	09498993          	addi	s3,s3,148 # ffffffffc02957f0 <timer_list>
ffffffffc0207764:	0089b403          	ld	s0,8(s3)
ffffffffc0207768:	4a01                	li	s4,0
ffffffffc020776a:	0d340463          	beq	s0,s3,ffffffffc0207832 <run_timer_list+0xea>
ffffffffc020776e:	ff042783          	lw	a5,-16(s0)
ffffffffc0207772:	12078763          	beqz	a5,ffffffffc02078a0 <run_timer_list+0x158>
ffffffffc0207776:	e84a                	sd	s2,16(sp)
ffffffffc0207778:	37fd                	addiw	a5,a5,-1
ffffffffc020777a:	fef42823          	sw	a5,-16(s0)
ffffffffc020777e:	ff040913          	addi	s2,s0,-16
ffffffffc0207782:	efb1                	bnez	a5,ffffffffc02077de <run_timer_list+0x96>
ffffffffc0207784:	ec26                	sd	s1,24(sp)
ffffffffc0207786:	a005                	j	ffffffffc02077a6 <run_timer_list+0x5e>
ffffffffc0207788:	0e07dc63          	bgez	a5,ffffffffc0207880 <run_timer_list+0x138>
ffffffffc020778c:	8526                	mv	a0,s1
ffffffffc020778e:	cb9ff0ef          	jal	ffffffffc0207446 <wakeup_proc>
ffffffffc0207792:	854a                	mv	a0,s2
ffffffffc0207794:	f27ff0ef          	jal	ffffffffc02076ba <del_timer>
ffffffffc0207798:	05340263          	beq	s0,s3,ffffffffc02077dc <run_timer_list+0x94>
ffffffffc020779c:	ff042783          	lw	a5,-16(s0)
ffffffffc02077a0:	ff040913          	addi	s2,s0,-16
ffffffffc02077a4:	ef85                	bnez	a5,ffffffffc02077dc <run_timer_list+0x94>
ffffffffc02077a6:	00893483          	ld	s1,8(s2)
ffffffffc02077aa:	6400                	ld	s0,8(s0)
ffffffffc02077ac:	0ec4a783          	lw	a5,236(s1)
ffffffffc02077b0:	ffe1                	bnez	a5,ffffffffc0207788 <run_timer_list+0x40>
ffffffffc02077b2:	40d4                	lw	a3,4(s1)
ffffffffc02077b4:	00006617          	auipc	a2,0x6
ffffffffc02077b8:	55c60613          	addi	a2,a2,1372 # ffffffffc020dd10 <etext+0x24b0>
ffffffffc02077bc:	0ba00593          	li	a1,186
ffffffffc02077c0:	00006517          	auipc	a0,0x6
ffffffffc02077c4:	48050513          	addi	a0,a0,1152 # ffffffffc020dc40 <etext+0x23e0>
ffffffffc02077c8:	cedf80ef          	jal	ffffffffc02004b4 <__warn>
ffffffffc02077cc:	8526                	mv	a0,s1
ffffffffc02077ce:	c79ff0ef          	jal	ffffffffc0207446 <wakeup_proc>
ffffffffc02077d2:	854a                	mv	a0,s2
ffffffffc02077d4:	ee7ff0ef          	jal	ffffffffc02076ba <del_timer>
ffffffffc02077d8:	fd3412e3          	bne	s0,s3,ffffffffc020779c <run_timer_list+0x54>
ffffffffc02077dc:	64e2                	ld	s1,24(sp)
ffffffffc02077de:	0008f597          	auipc	a1,0x8f
ffffffffc02077e2:	0ea5b583          	ld	a1,234(a1) # ffffffffc02968c8 <current>
ffffffffc02077e6:	cd85                	beqz	a1,ffffffffc020781e <run_timer_list+0xd6>
ffffffffc02077e8:	0008f797          	auipc	a5,0x8f
ffffffffc02077ec:	0f07b783          	ld	a5,240(a5) # ffffffffc02968d8 <idleproc>
ffffffffc02077f0:	02f58563          	beq	a1,a5,ffffffffc020781a <run_timer_list+0xd2>
ffffffffc02077f4:	6942                	ld	s2,16(sp)
ffffffffc02077f6:	0008f797          	auipc	a5,0x8f
ffffffffc02077fa:	0f27b783          	ld	a5,242(a5) # ffffffffc02968e8 <sched_class>
ffffffffc02077fe:	0008f517          	auipc	a0,0x8f
ffffffffc0207802:	0e253503          	ld	a0,226(a0) # ffffffffc02968e0 <rq>
ffffffffc0207806:	779c                	ld	a5,40(a5)
ffffffffc0207808:	9782                	jalr	a5
ffffffffc020780a:	000a1d63          	bnez	s4,ffffffffc0207824 <run_timer_list+0xdc>
ffffffffc020780e:	70a2                	ld	ra,40(sp)
ffffffffc0207810:	7402                	ld	s0,32(sp)
ffffffffc0207812:	69a2                	ld	s3,8(sp)
ffffffffc0207814:	6a02                	ld	s4,0(sp)
ffffffffc0207816:	6145                	addi	sp,sp,48
ffffffffc0207818:	8082                	ret
ffffffffc020781a:	4785                	li	a5,1
ffffffffc020781c:	ed9c                	sd	a5,24(a1)
ffffffffc020781e:	6942                	ld	s2,16(sp)
ffffffffc0207820:	fe0a07e3          	beqz	s4,ffffffffc020780e <run_timer_list+0xc6>
ffffffffc0207824:	7402                	ld	s0,32(sp)
ffffffffc0207826:	70a2                	ld	ra,40(sp)
ffffffffc0207828:	69a2                	ld	s3,8(sp)
ffffffffc020782a:	6a02                	ld	s4,0(sp)
ffffffffc020782c:	6145                	addi	sp,sp,48
ffffffffc020782e:	ba4f906f          	j	ffffffffc0200bd2 <intr_enable>
ffffffffc0207832:	0008f597          	auipc	a1,0x8f
ffffffffc0207836:	0965b583          	ld	a1,150(a1) # ffffffffc02968c8 <current>
ffffffffc020783a:	d9f1                	beqz	a1,ffffffffc020780e <run_timer_list+0xc6>
ffffffffc020783c:	0008f797          	auipc	a5,0x8f
ffffffffc0207840:	09c7b783          	ld	a5,156(a5) # ffffffffc02968d8 <idleproc>
ffffffffc0207844:	fab799e3          	bne	a5,a1,ffffffffc02077f6 <run_timer_list+0xae>
ffffffffc0207848:	4705                	li	a4,1
ffffffffc020784a:	ef98                	sd	a4,24(a5)
ffffffffc020784c:	b7c9                	j	ffffffffc020780e <run_timer_list+0xc6>
ffffffffc020784e:	0008e997          	auipc	s3,0x8e
ffffffffc0207852:	fa298993          	addi	s3,s3,-94 # ffffffffc02957f0 <timer_list>
ffffffffc0207856:	b82f90ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc020785a:	0089b403          	ld	s0,8(s3)
ffffffffc020785e:	4a05                	li	s4,1
ffffffffc0207860:	f13417e3          	bne	s0,s3,ffffffffc020776e <run_timer_list+0x26>
ffffffffc0207864:	0008f597          	auipc	a1,0x8f
ffffffffc0207868:	0645b583          	ld	a1,100(a1) # ffffffffc02968c8 <current>
ffffffffc020786c:	ddc5                	beqz	a1,ffffffffc0207824 <run_timer_list+0xdc>
ffffffffc020786e:	0008f797          	auipc	a5,0x8f
ffffffffc0207872:	06a7b783          	ld	a5,106(a5) # ffffffffc02968d8 <idleproc>
ffffffffc0207876:	f8f590e3          	bne	a1,a5,ffffffffc02077f6 <run_timer_list+0xae>
ffffffffc020787a:	0145bc23          	sd	s4,24(a1)
ffffffffc020787e:	b75d                	j	ffffffffc0207824 <run_timer_list+0xdc>
ffffffffc0207880:	00006697          	auipc	a3,0x6
ffffffffc0207884:	46868693          	addi	a3,a3,1128 # ffffffffc020dce8 <etext+0x2488>
ffffffffc0207888:	00004617          	auipc	a2,0x4
ffffffffc020788c:	41060613          	addi	a2,a2,1040 # ffffffffc020bc98 <etext+0x438>
ffffffffc0207890:	0b600593          	li	a1,182
ffffffffc0207894:	00006517          	auipc	a0,0x6
ffffffffc0207898:	3ac50513          	addi	a0,a0,940 # ffffffffc020dc40 <etext+0x23e0>
ffffffffc020789c:	baff80ef          	jal	ffffffffc020044a <__panic>
ffffffffc02078a0:	00006697          	auipc	a3,0x6
ffffffffc02078a4:	43068693          	addi	a3,a3,1072 # ffffffffc020dcd0 <etext+0x2470>
ffffffffc02078a8:	00004617          	auipc	a2,0x4
ffffffffc02078ac:	3f060613          	addi	a2,a2,1008 # ffffffffc020bc98 <etext+0x438>
ffffffffc02078b0:	0ae00593          	li	a1,174
ffffffffc02078b4:	00006517          	auipc	a0,0x6
ffffffffc02078b8:	38c50513          	addi	a0,a0,908 # ffffffffc020dc40 <etext+0x23e0>
ffffffffc02078bc:	ec26                	sd	s1,24(sp)
ffffffffc02078be:	e84a                	sd	s2,16(sp)
ffffffffc02078c0:	b8bf80ef          	jal	ffffffffc020044a <__panic>

ffffffffc02078c4 <sys_getpid>:
ffffffffc02078c4:	0008f797          	auipc	a5,0x8f
ffffffffc02078c8:	0047b783          	ld	a5,4(a5) # ffffffffc02968c8 <current>
ffffffffc02078cc:	43c8                	lw	a0,4(a5)
ffffffffc02078ce:	8082                	ret

ffffffffc02078d0 <sys_pgdir>:
ffffffffc02078d0:	4501                	li	a0,0
ffffffffc02078d2:	8082                	ret

ffffffffc02078d4 <sys_gettime>:
ffffffffc02078d4:	0008f797          	auipc	a5,0x8f
ffffffffc02078d8:	f9c7b783          	ld	a5,-100(a5) # ffffffffc0296870 <ticks>
ffffffffc02078dc:	0027951b          	slliw	a0,a5,0x2
ffffffffc02078e0:	9d3d                	addw	a0,a0,a5
ffffffffc02078e2:	0015151b          	slliw	a0,a0,0x1
ffffffffc02078e6:	8082                	ret

ffffffffc02078e8 <sys_lab6_set_priority>:
ffffffffc02078e8:	4108                	lw	a0,0(a0)
ffffffffc02078ea:	1141                	addi	sp,sp,-16
ffffffffc02078ec:	e406                	sd	ra,8(sp)
ffffffffc02078ee:	901ff0ef          	jal	ffffffffc02071ee <lab6_set_priority>
ffffffffc02078f2:	60a2                	ld	ra,8(sp)
ffffffffc02078f4:	4501                	li	a0,0
ffffffffc02078f6:	0141                	addi	sp,sp,16
ffffffffc02078f8:	8082                	ret

ffffffffc02078fa <sys_dup>:
ffffffffc02078fa:	450c                	lw	a1,8(a0)
ffffffffc02078fc:	4108                	lw	a0,0(a0)
ffffffffc02078fe:	9b8fe06f          	j	ffffffffc0205ab6 <sysfile_dup>

ffffffffc0207902 <sys_getdirentry>:
ffffffffc0207902:	650c                	ld	a1,8(a0)
ffffffffc0207904:	4108                	lw	a0,0(a0)
ffffffffc0207906:	8c0fe06f          	j	ffffffffc02059c6 <sysfile_getdirentry>

ffffffffc020790a <sys_getcwd>:
ffffffffc020790a:	650c                	ld	a1,8(a0)
ffffffffc020790c:	6108                	ld	a0,0(a0)
ffffffffc020790e:	80efe06f          	j	ffffffffc020591c <sysfile_getcwd>

ffffffffc0207912 <sys_fsync>:
ffffffffc0207912:	4108                	lw	a0,0(a0)
ffffffffc0207914:	804fe06f          	j	ffffffffc0205918 <sysfile_fsync>

ffffffffc0207918 <sys_fstat>:
ffffffffc0207918:	650c                	ld	a1,8(a0)
ffffffffc020791a:	4108                	lw	a0,0(a0)
ffffffffc020791c:	f75fd06f          	j	ffffffffc0205890 <sysfile_fstat>

ffffffffc0207920 <sys_seek>:
ffffffffc0207920:	4910                	lw	a2,16(a0)
ffffffffc0207922:	650c                	ld	a1,8(a0)
ffffffffc0207924:	4108                	lw	a0,0(a0)
ffffffffc0207926:	f67fd06f          	j	ffffffffc020588c <sysfile_seek>

ffffffffc020792a <sys_write>:
ffffffffc020792a:	6910                	ld	a2,16(a0)
ffffffffc020792c:	650c                	ld	a1,8(a0)
ffffffffc020792e:	4108                	lw	a0,0(a0)
ffffffffc0207930:	e2bfd06f          	j	ffffffffc020575a <sysfile_write>

ffffffffc0207934 <sys_read>:
ffffffffc0207934:	6910                	ld	a2,16(a0)
ffffffffc0207936:	650c                	ld	a1,8(a0)
ffffffffc0207938:	4108                	lw	a0,0(a0)
ffffffffc020793a:	cd5fd06f          	j	ffffffffc020560e <sysfile_read>

ffffffffc020793e <sys_close>:
ffffffffc020793e:	4108                	lw	a0,0(a0)
ffffffffc0207940:	ccbfd06f          	j	ffffffffc020560a <sysfile_close>

ffffffffc0207944 <sys_open>:
ffffffffc0207944:	450c                	lw	a1,8(a0)
ffffffffc0207946:	6108                	ld	a0,0(a0)
ffffffffc0207948:	c8dfd06f          	j	ffffffffc02055d4 <sysfile_open>

ffffffffc020794c <sys_putc>:
ffffffffc020794c:	4108                	lw	a0,0(a0)
ffffffffc020794e:	1141                	addi	sp,sp,-16
ffffffffc0207950:	e406                	sd	ra,8(sp)
ffffffffc0207952:	88ff80ef          	jal	ffffffffc02001e0 <cputchar>
ffffffffc0207956:	60a2                	ld	ra,8(sp)
ffffffffc0207958:	4501                	li	a0,0
ffffffffc020795a:	0141                	addi	sp,sp,16
ffffffffc020795c:	8082                	ret

ffffffffc020795e <sys_kill>:
ffffffffc020795e:	4108                	lw	a0,0(a0)
ffffffffc0207960:	e28ff06f          	j	ffffffffc0206f88 <do_kill>

ffffffffc0207964 <sys_sleep>:
ffffffffc0207964:	4108                	lw	a0,0(a0)
ffffffffc0207966:	8b7ff06f          	j	ffffffffc020721c <do_sleep>

ffffffffc020796a <sys_yield>:
ffffffffc020796a:	dd4ff06f          	j	ffffffffc0206f3e <do_yield>

ffffffffc020796e <sys_exec>:
ffffffffc020796e:	6910                	ld	a2,16(a0)
ffffffffc0207970:	450c                	lw	a1,8(a0)
ffffffffc0207972:	6108                	ld	a0,0(a0)
ffffffffc0207974:	d05fe06f          	j	ffffffffc0206678 <do_execve>

ffffffffc0207978 <sys_wait>:
ffffffffc0207978:	650c                	ld	a1,8(a0)
ffffffffc020797a:	4108                	lw	a0,0(a0)
ffffffffc020797c:	dd2ff06f          	j	ffffffffc0206f4e <do_wait>

ffffffffc0207980 <sys_fork>:
ffffffffc0207980:	0008f797          	auipc	a5,0x8f
ffffffffc0207984:	f487b783          	ld	a5,-184(a5) # ffffffffc02968c8 <current>
ffffffffc0207988:	4501                	li	a0,0
ffffffffc020798a:	73d0                	ld	a2,160(a5)
ffffffffc020798c:	6a0c                	ld	a1,16(a2)
ffffffffc020798e:	bbefe06f          	j	ffffffffc0205d4c <do_fork>

ffffffffc0207992 <sys_exit>:
ffffffffc0207992:	4108                	lw	a0,0(a0)
ffffffffc0207994:	853fe06f          	j	ffffffffc02061e6 <do_exit>

ffffffffc0207998 <syscall>:
ffffffffc0207998:	0008f697          	auipc	a3,0x8f
ffffffffc020799c:	f306b683          	ld	a3,-208(a3) # ffffffffc02968c8 <current>
ffffffffc02079a0:	715d                	addi	sp,sp,-80
ffffffffc02079a2:	e0a2                	sd	s0,64(sp)
ffffffffc02079a4:	72c0                	ld	s0,160(a3)
ffffffffc02079a6:	e486                	sd	ra,72(sp)
ffffffffc02079a8:	0ff00793          	li	a5,255
ffffffffc02079ac:	4834                	lw	a3,80(s0)
ffffffffc02079ae:	02d7ec63          	bltu	a5,a3,ffffffffc02079e6 <syscall+0x4e>
ffffffffc02079b2:	00007797          	auipc	a5,0x7
ffffffffc02079b6:	60678793          	addi	a5,a5,1542 # ffffffffc020efb8 <syscalls>
ffffffffc02079ba:	00369613          	slli	a2,a3,0x3
ffffffffc02079be:	97b2                	add	a5,a5,a2
ffffffffc02079c0:	639c                	ld	a5,0(a5)
ffffffffc02079c2:	c395                	beqz	a5,ffffffffc02079e6 <syscall+0x4e>
ffffffffc02079c4:	7028                	ld	a0,96(s0)
ffffffffc02079c6:	742c                	ld	a1,104(s0)
ffffffffc02079c8:	7830                	ld	a2,112(s0)
ffffffffc02079ca:	7c34                	ld	a3,120(s0)
ffffffffc02079cc:	6c38                	ld	a4,88(s0)
ffffffffc02079ce:	f02a                	sd	a0,32(sp)
ffffffffc02079d0:	f42e                	sd	a1,40(sp)
ffffffffc02079d2:	f832                	sd	a2,48(sp)
ffffffffc02079d4:	fc36                	sd	a3,56(sp)
ffffffffc02079d6:	ec3a                	sd	a4,24(sp)
ffffffffc02079d8:	0828                	addi	a0,sp,24
ffffffffc02079da:	9782                	jalr	a5
ffffffffc02079dc:	60a6                	ld	ra,72(sp)
ffffffffc02079de:	e828                	sd	a0,80(s0)
ffffffffc02079e0:	6406                	ld	s0,64(sp)
ffffffffc02079e2:	6161                	addi	sp,sp,80
ffffffffc02079e4:	8082                	ret
ffffffffc02079e6:	8522                	mv	a0,s0
ffffffffc02079e8:	e436                	sd	a3,8(sp)
ffffffffc02079ea:	d02f90ef          	jal	ffffffffc0200eec <print_trapframe>
ffffffffc02079ee:	0008f797          	auipc	a5,0x8f
ffffffffc02079f2:	eda7b783          	ld	a5,-294(a5) # ffffffffc02968c8 <current>
ffffffffc02079f6:	66a2                	ld	a3,8(sp)
ffffffffc02079f8:	00006617          	auipc	a2,0x6
ffffffffc02079fc:	33860613          	addi	a2,a2,824 # ffffffffc020dd30 <etext+0x24d0>
ffffffffc0207a00:	43d8                	lw	a4,4(a5)
ffffffffc0207a02:	0d800593          	li	a1,216
ffffffffc0207a06:	0b478793          	addi	a5,a5,180
ffffffffc0207a0a:	00006517          	auipc	a0,0x6
ffffffffc0207a0e:	35650513          	addi	a0,a0,854 # ffffffffc020dd60 <etext+0x2500>
ffffffffc0207a12:	a39f80ef          	jal	ffffffffc020044a <__panic>

ffffffffc0207a16 <__alloc_inode>:
ffffffffc0207a16:	1141                	addi	sp,sp,-16
ffffffffc0207a18:	e022                	sd	s0,0(sp)
ffffffffc0207a1a:	842a                	mv	s0,a0
ffffffffc0207a1c:	07800513          	li	a0,120
ffffffffc0207a20:	e406                	sd	ra,8(sp)
ffffffffc0207a22:	d9efa0ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc0207a26:	c111                	beqz	a0,ffffffffc0207a2a <__alloc_inode+0x14>
ffffffffc0207a28:	cd20                	sw	s0,88(a0)
ffffffffc0207a2a:	60a2                	ld	ra,8(sp)
ffffffffc0207a2c:	6402                	ld	s0,0(sp)
ffffffffc0207a2e:	0141                	addi	sp,sp,16
ffffffffc0207a30:	8082                	ret

ffffffffc0207a32 <inode_init>:
ffffffffc0207a32:	4785                	li	a5,1
ffffffffc0207a34:	06052023          	sw	zero,96(a0)
ffffffffc0207a38:	f92c                	sd	a1,112(a0)
ffffffffc0207a3a:	f530                	sd	a2,104(a0)
ffffffffc0207a3c:	cd7c                	sw	a5,92(a0)
ffffffffc0207a3e:	8082                	ret

ffffffffc0207a40 <inode_kill>:
ffffffffc0207a40:	4d78                	lw	a4,92(a0)
ffffffffc0207a42:	1141                	addi	sp,sp,-16
ffffffffc0207a44:	e406                	sd	ra,8(sp)
ffffffffc0207a46:	e719                	bnez	a4,ffffffffc0207a54 <inode_kill+0x14>
ffffffffc0207a48:	513c                	lw	a5,96(a0)
ffffffffc0207a4a:	e78d                	bnez	a5,ffffffffc0207a74 <inode_kill+0x34>
ffffffffc0207a4c:	60a2                	ld	ra,8(sp)
ffffffffc0207a4e:	0141                	addi	sp,sp,16
ffffffffc0207a50:	e16fa06f          	j	ffffffffc0202066 <kfree>
ffffffffc0207a54:	00006697          	auipc	a3,0x6
ffffffffc0207a58:	32468693          	addi	a3,a3,804 # ffffffffc020dd78 <etext+0x2518>
ffffffffc0207a5c:	00004617          	auipc	a2,0x4
ffffffffc0207a60:	23c60613          	addi	a2,a2,572 # ffffffffc020bc98 <etext+0x438>
ffffffffc0207a64:	02900593          	li	a1,41
ffffffffc0207a68:	00006517          	auipc	a0,0x6
ffffffffc0207a6c:	33050513          	addi	a0,a0,816 # ffffffffc020dd98 <etext+0x2538>
ffffffffc0207a70:	9dbf80ef          	jal	ffffffffc020044a <__panic>
ffffffffc0207a74:	00006697          	auipc	a3,0x6
ffffffffc0207a78:	33c68693          	addi	a3,a3,828 # ffffffffc020ddb0 <etext+0x2550>
ffffffffc0207a7c:	00004617          	auipc	a2,0x4
ffffffffc0207a80:	21c60613          	addi	a2,a2,540 # ffffffffc020bc98 <etext+0x438>
ffffffffc0207a84:	02a00593          	li	a1,42
ffffffffc0207a88:	00006517          	auipc	a0,0x6
ffffffffc0207a8c:	31050513          	addi	a0,a0,784 # ffffffffc020dd98 <etext+0x2538>
ffffffffc0207a90:	9bbf80ef          	jal	ffffffffc020044a <__panic>

ffffffffc0207a94 <inode_ref_inc>:
ffffffffc0207a94:	4d7c                	lw	a5,92(a0)
ffffffffc0207a96:	2785                	addiw	a5,a5,1
ffffffffc0207a98:	cd7c                	sw	a5,92(a0)
ffffffffc0207a9a:	853e                	mv	a0,a5
ffffffffc0207a9c:	8082                	ret

ffffffffc0207a9e <inode_open_inc>:
ffffffffc0207a9e:	513c                	lw	a5,96(a0)
ffffffffc0207aa0:	2785                	addiw	a5,a5,1
ffffffffc0207aa2:	d13c                	sw	a5,96(a0)
ffffffffc0207aa4:	853e                	mv	a0,a5
ffffffffc0207aa6:	8082                	ret

ffffffffc0207aa8 <inode_check>:
ffffffffc0207aa8:	1141                	addi	sp,sp,-16
ffffffffc0207aaa:	e406                	sd	ra,8(sp)
ffffffffc0207aac:	c91d                	beqz	a0,ffffffffc0207ae2 <inode_check+0x3a>
ffffffffc0207aae:	793c                	ld	a5,112(a0)
ffffffffc0207ab0:	cb8d                	beqz	a5,ffffffffc0207ae2 <inode_check+0x3a>
ffffffffc0207ab2:	6398                	ld	a4,0(a5)
ffffffffc0207ab4:	4625d7b7          	lui	a5,0x4625d
ffffffffc0207ab8:	0786                	slli	a5,a5,0x1
ffffffffc0207aba:	47678793          	addi	a5,a5,1142 # 4625d476 <_binary_bin_sfs_img_size+0x461e8176>
ffffffffc0207abe:	08f71263          	bne	a4,a5,ffffffffc0207b42 <inode_check+0x9a>
ffffffffc0207ac2:	4d74                	lw	a3,92(a0)
ffffffffc0207ac4:	5138                	lw	a4,96(a0)
ffffffffc0207ac6:	04e6ce63          	blt	a3,a4,ffffffffc0207b22 <inode_check+0x7a>
ffffffffc0207aca:	01f7579b          	srliw	a5,a4,0x1f
ffffffffc0207ace:	ebb1                	bnez	a5,ffffffffc0207b22 <inode_check+0x7a>
ffffffffc0207ad0:	67c1                	lui	a5,0x10
ffffffffc0207ad2:	17fd                	addi	a5,a5,-1 # ffff <_binary_bin_swap_img_size+0x82ff>
ffffffffc0207ad4:	02d7c763          	blt	a5,a3,ffffffffc0207b02 <inode_check+0x5a>
ffffffffc0207ad8:	02e7c563          	blt	a5,a4,ffffffffc0207b02 <inode_check+0x5a>
ffffffffc0207adc:	60a2                	ld	ra,8(sp)
ffffffffc0207ade:	0141                	addi	sp,sp,16
ffffffffc0207ae0:	8082                	ret
ffffffffc0207ae2:	00006697          	auipc	a3,0x6
ffffffffc0207ae6:	2ee68693          	addi	a3,a3,750 # ffffffffc020ddd0 <etext+0x2570>
ffffffffc0207aea:	00004617          	auipc	a2,0x4
ffffffffc0207aee:	1ae60613          	addi	a2,a2,430 # ffffffffc020bc98 <etext+0x438>
ffffffffc0207af2:	06e00593          	li	a1,110
ffffffffc0207af6:	00006517          	auipc	a0,0x6
ffffffffc0207afa:	2a250513          	addi	a0,a0,674 # ffffffffc020dd98 <etext+0x2538>
ffffffffc0207afe:	94df80ef          	jal	ffffffffc020044a <__panic>
ffffffffc0207b02:	00006697          	auipc	a3,0x6
ffffffffc0207b06:	34e68693          	addi	a3,a3,846 # ffffffffc020de50 <etext+0x25f0>
ffffffffc0207b0a:	00004617          	auipc	a2,0x4
ffffffffc0207b0e:	18e60613          	addi	a2,a2,398 # ffffffffc020bc98 <etext+0x438>
ffffffffc0207b12:	07200593          	li	a1,114
ffffffffc0207b16:	00006517          	auipc	a0,0x6
ffffffffc0207b1a:	28250513          	addi	a0,a0,642 # ffffffffc020dd98 <etext+0x2538>
ffffffffc0207b1e:	92df80ef          	jal	ffffffffc020044a <__panic>
ffffffffc0207b22:	00006697          	auipc	a3,0x6
ffffffffc0207b26:	2fe68693          	addi	a3,a3,766 # ffffffffc020de20 <etext+0x25c0>
ffffffffc0207b2a:	00004617          	auipc	a2,0x4
ffffffffc0207b2e:	16e60613          	addi	a2,a2,366 # ffffffffc020bc98 <etext+0x438>
ffffffffc0207b32:	07100593          	li	a1,113
ffffffffc0207b36:	00006517          	auipc	a0,0x6
ffffffffc0207b3a:	26250513          	addi	a0,a0,610 # ffffffffc020dd98 <etext+0x2538>
ffffffffc0207b3e:	90df80ef          	jal	ffffffffc020044a <__panic>
ffffffffc0207b42:	00006697          	auipc	a3,0x6
ffffffffc0207b46:	2b668693          	addi	a3,a3,694 # ffffffffc020ddf8 <etext+0x2598>
ffffffffc0207b4a:	00004617          	auipc	a2,0x4
ffffffffc0207b4e:	14e60613          	addi	a2,a2,334 # ffffffffc020bc98 <etext+0x438>
ffffffffc0207b52:	06f00593          	li	a1,111
ffffffffc0207b56:	00006517          	auipc	a0,0x6
ffffffffc0207b5a:	24250513          	addi	a0,a0,578 # ffffffffc020dd98 <etext+0x2538>
ffffffffc0207b5e:	8edf80ef          	jal	ffffffffc020044a <__panic>

ffffffffc0207b62 <inode_ref_dec>:
ffffffffc0207b62:	4d7c                	lw	a5,92(a0)
ffffffffc0207b64:	7179                	addi	sp,sp,-48
ffffffffc0207b66:	f406                	sd	ra,40(sp)
ffffffffc0207b68:	06f05b63          	blez	a5,ffffffffc0207bde <inode_ref_dec+0x7c>
ffffffffc0207b6c:	37fd                	addiw	a5,a5,-1
ffffffffc0207b6e:	cd7c                	sw	a5,92(a0)
ffffffffc0207b70:	e795                	bnez	a5,ffffffffc0207b9c <inode_ref_dec+0x3a>
ffffffffc0207b72:	7934                	ld	a3,112(a0)
ffffffffc0207b74:	c6a9                	beqz	a3,ffffffffc0207bbe <inode_ref_dec+0x5c>
ffffffffc0207b76:	66b4                	ld	a3,72(a3)
ffffffffc0207b78:	c2b9                	beqz	a3,ffffffffc0207bbe <inode_ref_dec+0x5c>
ffffffffc0207b7a:	00006597          	auipc	a1,0x6
ffffffffc0207b7e:	38658593          	addi	a1,a1,902 # ffffffffc020df00 <etext+0x26a0>
ffffffffc0207b82:	e83e                	sd	a5,16(sp)
ffffffffc0207b84:	ec2a                	sd	a0,24(sp)
ffffffffc0207b86:	e436                	sd	a3,8(sp)
ffffffffc0207b88:	f21ff0ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc0207b8c:	6562                	ld	a0,24(sp)
ffffffffc0207b8e:	66a2                	ld	a3,8(sp)
ffffffffc0207b90:	9682                	jalr	a3
ffffffffc0207b92:	00f50713          	addi	a4,a0,15
ffffffffc0207b96:	67c2                	ld	a5,16(sp)
ffffffffc0207b98:	c311                	beqz	a4,ffffffffc0207b9c <inode_ref_dec+0x3a>
ffffffffc0207b9a:	e509                	bnez	a0,ffffffffc0207ba4 <inode_ref_dec+0x42>
ffffffffc0207b9c:	70a2                	ld	ra,40(sp)
ffffffffc0207b9e:	853e                	mv	a0,a5
ffffffffc0207ba0:	6145                	addi	sp,sp,48
ffffffffc0207ba2:	8082                	ret
ffffffffc0207ba4:	85aa                	mv	a1,a0
ffffffffc0207ba6:	00006517          	auipc	a0,0x6
ffffffffc0207baa:	36250513          	addi	a0,a0,866 # ffffffffc020df08 <etext+0x26a8>
ffffffffc0207bae:	e43e                	sd	a5,8(sp)
ffffffffc0207bb0:	df6f80ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0207bb4:	67a2                	ld	a5,8(sp)
ffffffffc0207bb6:	70a2                	ld	ra,40(sp)
ffffffffc0207bb8:	853e                	mv	a0,a5
ffffffffc0207bba:	6145                	addi	sp,sp,48
ffffffffc0207bbc:	8082                	ret
ffffffffc0207bbe:	00006697          	auipc	a3,0x6
ffffffffc0207bc2:	2f268693          	addi	a3,a3,754 # ffffffffc020deb0 <etext+0x2650>
ffffffffc0207bc6:	00004617          	auipc	a2,0x4
ffffffffc0207bca:	0d260613          	addi	a2,a2,210 # ffffffffc020bc98 <etext+0x438>
ffffffffc0207bce:	04400593          	li	a1,68
ffffffffc0207bd2:	00006517          	auipc	a0,0x6
ffffffffc0207bd6:	1c650513          	addi	a0,a0,454 # ffffffffc020dd98 <etext+0x2538>
ffffffffc0207bda:	871f80ef          	jal	ffffffffc020044a <__panic>
ffffffffc0207bde:	00006697          	auipc	a3,0x6
ffffffffc0207be2:	2b268693          	addi	a3,a3,690 # ffffffffc020de90 <etext+0x2630>
ffffffffc0207be6:	00004617          	auipc	a2,0x4
ffffffffc0207bea:	0b260613          	addi	a2,a2,178 # ffffffffc020bc98 <etext+0x438>
ffffffffc0207bee:	03f00593          	li	a1,63
ffffffffc0207bf2:	00006517          	auipc	a0,0x6
ffffffffc0207bf6:	1a650513          	addi	a0,a0,422 # ffffffffc020dd98 <etext+0x2538>
ffffffffc0207bfa:	851f80ef          	jal	ffffffffc020044a <__panic>

ffffffffc0207bfe <inode_open_dec>:
ffffffffc0207bfe:	513c                	lw	a5,96(a0)
ffffffffc0207c00:	7179                	addi	sp,sp,-48
ffffffffc0207c02:	f406                	sd	ra,40(sp)
ffffffffc0207c04:	06f05863          	blez	a5,ffffffffc0207c74 <inode_open_dec+0x76>
ffffffffc0207c08:	37fd                	addiw	a5,a5,-1
ffffffffc0207c0a:	d13c                	sw	a5,96(a0)
ffffffffc0207c0c:	e39d                	bnez	a5,ffffffffc0207c32 <inode_open_dec+0x34>
ffffffffc0207c0e:	7934                	ld	a3,112(a0)
ffffffffc0207c10:	c2b1                	beqz	a3,ffffffffc0207c54 <inode_open_dec+0x56>
ffffffffc0207c12:	6a94                	ld	a3,16(a3)
ffffffffc0207c14:	c2a1                	beqz	a3,ffffffffc0207c54 <inode_open_dec+0x56>
ffffffffc0207c16:	00006597          	auipc	a1,0x6
ffffffffc0207c1a:	38258593          	addi	a1,a1,898 # ffffffffc020df98 <etext+0x2738>
ffffffffc0207c1e:	e83e                	sd	a5,16(sp)
ffffffffc0207c20:	ec2a                	sd	a0,24(sp)
ffffffffc0207c22:	e436                	sd	a3,8(sp)
ffffffffc0207c24:	e85ff0ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc0207c28:	6562                	ld	a0,24(sp)
ffffffffc0207c2a:	66a2                	ld	a3,8(sp)
ffffffffc0207c2c:	9682                	jalr	a3
ffffffffc0207c2e:	67c2                	ld	a5,16(sp)
ffffffffc0207c30:	e509                	bnez	a0,ffffffffc0207c3a <inode_open_dec+0x3c>
ffffffffc0207c32:	70a2                	ld	ra,40(sp)
ffffffffc0207c34:	853e                	mv	a0,a5
ffffffffc0207c36:	6145                	addi	sp,sp,48
ffffffffc0207c38:	8082                	ret
ffffffffc0207c3a:	85aa                	mv	a1,a0
ffffffffc0207c3c:	00006517          	auipc	a0,0x6
ffffffffc0207c40:	36450513          	addi	a0,a0,868 # ffffffffc020dfa0 <etext+0x2740>
ffffffffc0207c44:	e43e                	sd	a5,8(sp)
ffffffffc0207c46:	d60f80ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0207c4a:	67a2                	ld	a5,8(sp)
ffffffffc0207c4c:	70a2                	ld	ra,40(sp)
ffffffffc0207c4e:	853e                	mv	a0,a5
ffffffffc0207c50:	6145                	addi	sp,sp,48
ffffffffc0207c52:	8082                	ret
ffffffffc0207c54:	00006697          	auipc	a3,0x6
ffffffffc0207c58:	2f468693          	addi	a3,a3,756 # ffffffffc020df48 <etext+0x26e8>
ffffffffc0207c5c:	00004617          	auipc	a2,0x4
ffffffffc0207c60:	03c60613          	addi	a2,a2,60 # ffffffffc020bc98 <etext+0x438>
ffffffffc0207c64:	06100593          	li	a1,97
ffffffffc0207c68:	00006517          	auipc	a0,0x6
ffffffffc0207c6c:	13050513          	addi	a0,a0,304 # ffffffffc020dd98 <etext+0x2538>
ffffffffc0207c70:	fdaf80ef          	jal	ffffffffc020044a <__panic>
ffffffffc0207c74:	00006697          	auipc	a3,0x6
ffffffffc0207c78:	2b468693          	addi	a3,a3,692 # ffffffffc020df28 <etext+0x26c8>
ffffffffc0207c7c:	00004617          	auipc	a2,0x4
ffffffffc0207c80:	01c60613          	addi	a2,a2,28 # ffffffffc020bc98 <etext+0x438>
ffffffffc0207c84:	05c00593          	li	a1,92
ffffffffc0207c88:	00006517          	auipc	a0,0x6
ffffffffc0207c8c:	11050513          	addi	a0,a0,272 # ffffffffc020dd98 <etext+0x2538>
ffffffffc0207c90:	fbaf80ef          	jal	ffffffffc020044a <__panic>

ffffffffc0207c94 <__alloc_fs>:
ffffffffc0207c94:	1141                	addi	sp,sp,-16
ffffffffc0207c96:	e022                	sd	s0,0(sp)
ffffffffc0207c98:	842a                	mv	s0,a0
ffffffffc0207c9a:	0d800513          	li	a0,216
ffffffffc0207c9e:	e406                	sd	ra,8(sp)
ffffffffc0207ca0:	b20fa0ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc0207ca4:	c119                	beqz	a0,ffffffffc0207caa <__alloc_fs+0x16>
ffffffffc0207ca6:	0a852823          	sw	s0,176(a0)
ffffffffc0207caa:	60a2                	ld	ra,8(sp)
ffffffffc0207cac:	6402                	ld	s0,0(sp)
ffffffffc0207cae:	0141                	addi	sp,sp,16
ffffffffc0207cb0:	8082                	ret

ffffffffc0207cb2 <vfs_init>:
ffffffffc0207cb2:	1141                	addi	sp,sp,-16
ffffffffc0207cb4:	4585                	li	a1,1
ffffffffc0207cb6:	0008e517          	auipc	a0,0x8e
ffffffffc0207cba:	b4a50513          	addi	a0,a0,-1206 # ffffffffc0295800 <bootfs_sem>
ffffffffc0207cbe:	e406                	sd	ra,8(sp)
ffffffffc0207cc0:	92dfc0ef          	jal	ffffffffc02045ec <sem_init>
ffffffffc0207cc4:	60a2                	ld	ra,8(sp)
ffffffffc0207cc6:	0141                	addi	sp,sp,16
ffffffffc0207cc8:	a4b1                	j	ffffffffc0207f14 <vfs_devlist_init>

ffffffffc0207cca <vfs_set_bootfs>:
ffffffffc0207cca:	7179                	addi	sp,sp,-48
ffffffffc0207ccc:	f022                	sd	s0,32(sp)
ffffffffc0207cce:	f406                	sd	ra,40(sp)
ffffffffc0207cd0:	ec02                	sd	zero,24(sp)
ffffffffc0207cd2:	842a                	mv	s0,a0
ffffffffc0207cd4:	c515                	beqz	a0,ffffffffc0207d00 <vfs_set_bootfs+0x36>
ffffffffc0207cd6:	03a00593          	li	a1,58
ffffffffc0207cda:	30d030ef          	jal	ffffffffc020b7e6 <strchr>
ffffffffc0207cde:	c125                	beqz	a0,ffffffffc0207d3e <vfs_set_bootfs+0x74>
ffffffffc0207ce0:	00154783          	lbu	a5,1(a0)
ffffffffc0207ce4:	efa9                	bnez	a5,ffffffffc0207d3e <vfs_set_bootfs+0x74>
ffffffffc0207ce6:	8522                	mv	a0,s0
ffffffffc0207ce8:	163000ef          	jal	ffffffffc020864a <vfs_chdir>
ffffffffc0207cec:	c509                	beqz	a0,ffffffffc0207cf6 <vfs_set_bootfs+0x2c>
ffffffffc0207cee:	70a2                	ld	ra,40(sp)
ffffffffc0207cf0:	7402                	ld	s0,32(sp)
ffffffffc0207cf2:	6145                	addi	sp,sp,48
ffffffffc0207cf4:	8082                	ret
ffffffffc0207cf6:	0828                	addi	a0,sp,24
ffffffffc0207cf8:	05f000ef          	jal	ffffffffc0208556 <vfs_get_curdir>
ffffffffc0207cfc:	f96d                	bnez	a0,ffffffffc0207cee <vfs_set_bootfs+0x24>
ffffffffc0207cfe:	6462                	ld	s0,24(sp)
ffffffffc0207d00:	0008e517          	auipc	a0,0x8e
ffffffffc0207d04:	b0050513          	addi	a0,a0,-1280 # ffffffffc0295800 <bootfs_sem>
ffffffffc0207d08:	8effc0ef          	jal	ffffffffc02045f6 <down>
ffffffffc0207d0c:	0008f797          	auipc	a5,0x8f
ffffffffc0207d10:	be47b783          	ld	a5,-1052(a5) # ffffffffc02968f0 <bootfs_node>
ffffffffc0207d14:	0008e517          	auipc	a0,0x8e
ffffffffc0207d18:	aec50513          	addi	a0,a0,-1300 # ffffffffc0295800 <bootfs_sem>
ffffffffc0207d1c:	0008f717          	auipc	a4,0x8f
ffffffffc0207d20:	bc873a23          	sd	s0,-1068(a4) # ffffffffc02968f0 <bootfs_node>
ffffffffc0207d24:	e43e                	sd	a5,8(sp)
ffffffffc0207d26:	8cdfc0ef          	jal	ffffffffc02045f2 <up>
ffffffffc0207d2a:	67a2                	ld	a5,8(sp)
ffffffffc0207d2c:	c781                	beqz	a5,ffffffffc0207d34 <vfs_set_bootfs+0x6a>
ffffffffc0207d2e:	853e                	mv	a0,a5
ffffffffc0207d30:	e33ff0ef          	jal	ffffffffc0207b62 <inode_ref_dec>
ffffffffc0207d34:	70a2                	ld	ra,40(sp)
ffffffffc0207d36:	7402                	ld	s0,32(sp)
ffffffffc0207d38:	4501                	li	a0,0
ffffffffc0207d3a:	6145                	addi	sp,sp,48
ffffffffc0207d3c:	8082                	ret
ffffffffc0207d3e:	5575                	li	a0,-3
ffffffffc0207d40:	b77d                	j	ffffffffc0207cee <vfs_set_bootfs+0x24>

ffffffffc0207d42 <vfs_get_bootfs>:
ffffffffc0207d42:	1101                	addi	sp,sp,-32
ffffffffc0207d44:	e426                	sd	s1,8(sp)
ffffffffc0207d46:	0008f497          	auipc	s1,0x8f
ffffffffc0207d4a:	baa48493          	addi	s1,s1,-1110 # ffffffffc02968f0 <bootfs_node>
ffffffffc0207d4e:	609c                	ld	a5,0(s1)
ffffffffc0207d50:	ec06                	sd	ra,24(sp)
ffffffffc0207d52:	c3b1                	beqz	a5,ffffffffc0207d96 <vfs_get_bootfs+0x54>
ffffffffc0207d54:	e822                	sd	s0,16(sp)
ffffffffc0207d56:	842a                	mv	s0,a0
ffffffffc0207d58:	0008e517          	auipc	a0,0x8e
ffffffffc0207d5c:	aa850513          	addi	a0,a0,-1368 # ffffffffc0295800 <bootfs_sem>
ffffffffc0207d60:	897fc0ef          	jal	ffffffffc02045f6 <down>
ffffffffc0207d64:	6084                	ld	s1,0(s1)
ffffffffc0207d66:	c08d                	beqz	s1,ffffffffc0207d88 <vfs_get_bootfs+0x46>
ffffffffc0207d68:	8526                	mv	a0,s1
ffffffffc0207d6a:	d2bff0ef          	jal	ffffffffc0207a94 <inode_ref_inc>
ffffffffc0207d6e:	0008e517          	auipc	a0,0x8e
ffffffffc0207d72:	a9250513          	addi	a0,a0,-1390 # ffffffffc0295800 <bootfs_sem>
ffffffffc0207d76:	87dfc0ef          	jal	ffffffffc02045f2 <up>
ffffffffc0207d7a:	60e2                	ld	ra,24(sp)
ffffffffc0207d7c:	e004                	sd	s1,0(s0)
ffffffffc0207d7e:	6442                	ld	s0,16(sp)
ffffffffc0207d80:	64a2                	ld	s1,8(sp)
ffffffffc0207d82:	4501                	li	a0,0
ffffffffc0207d84:	6105                	addi	sp,sp,32
ffffffffc0207d86:	8082                	ret
ffffffffc0207d88:	0008e517          	auipc	a0,0x8e
ffffffffc0207d8c:	a7850513          	addi	a0,a0,-1416 # ffffffffc0295800 <bootfs_sem>
ffffffffc0207d90:	863fc0ef          	jal	ffffffffc02045f2 <up>
ffffffffc0207d94:	6442                	ld	s0,16(sp)
ffffffffc0207d96:	60e2                	ld	ra,24(sp)
ffffffffc0207d98:	64a2                	ld	s1,8(sp)
ffffffffc0207d9a:	5541                	li	a0,-16
ffffffffc0207d9c:	6105                	addi	sp,sp,32
ffffffffc0207d9e:	8082                	ret

ffffffffc0207da0 <vfs_do_add>:
ffffffffc0207da0:	7139                	addi	sp,sp,-64
ffffffffc0207da2:	fc06                	sd	ra,56(sp)
ffffffffc0207da4:	f822                	sd	s0,48(sp)
ffffffffc0207da6:	e852                	sd	s4,16(sp)
ffffffffc0207da8:	e456                	sd	s5,8(sp)
ffffffffc0207daa:	e05a                	sd	s6,0(sp)
ffffffffc0207dac:	10050f63          	beqz	a0,ffffffffc0207eca <vfs_do_add+0x12a>
ffffffffc0207db0:	00d5e7b3          	or	a5,a1,a3
ffffffffc0207db4:	842a                	mv	s0,a0
ffffffffc0207db6:	8a2e                	mv	s4,a1
ffffffffc0207db8:	8b32                	mv	s6,a2
ffffffffc0207dba:	8ab6                	mv	s5,a3
ffffffffc0207dbc:	cb89                	beqz	a5,ffffffffc0207dce <vfs_do_add+0x2e>
ffffffffc0207dbe:	0e058363          	beqz	a1,ffffffffc0207ea4 <vfs_do_add+0x104>
ffffffffc0207dc2:	4db8                	lw	a4,88(a1)
ffffffffc0207dc4:	6785                	lui	a5,0x1
ffffffffc0207dc6:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0207dca:	0cf71d63          	bne	a4,a5,ffffffffc0207ea4 <vfs_do_add+0x104>
ffffffffc0207dce:	8522                	mv	a0,s0
ffffffffc0207dd0:	175030ef          	jal	ffffffffc020b744 <strlen>
ffffffffc0207dd4:	47fd                	li	a5,31
ffffffffc0207dd6:	0ca7e263          	bltu	a5,a0,ffffffffc0207e9a <vfs_do_add+0xfa>
ffffffffc0207dda:	8522                	mv	a0,s0
ffffffffc0207ddc:	f426                	sd	s1,40(sp)
ffffffffc0207dde:	c14f80ef          	jal	ffffffffc02001f2 <strdup>
ffffffffc0207de2:	84aa                	mv	s1,a0
ffffffffc0207de4:	cd4d                	beqz	a0,ffffffffc0207e9e <vfs_do_add+0xfe>
ffffffffc0207de6:	03000513          	li	a0,48
ffffffffc0207dea:	ec4e                	sd	s3,24(sp)
ffffffffc0207dec:	9d4fa0ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc0207df0:	89aa                	mv	s3,a0
ffffffffc0207df2:	c935                	beqz	a0,ffffffffc0207e66 <vfs_do_add+0xc6>
ffffffffc0207df4:	f04a                	sd	s2,32(sp)
ffffffffc0207df6:	0008e517          	auipc	a0,0x8e
ffffffffc0207dfa:	a2250513          	addi	a0,a0,-1502 # ffffffffc0295818 <vdev_list_sem>
ffffffffc0207dfe:	0008e917          	auipc	s2,0x8e
ffffffffc0207e02:	a3290913          	addi	s2,s2,-1486 # ffffffffc0295830 <vdev_list>
ffffffffc0207e06:	ff0fc0ef          	jal	ffffffffc02045f6 <down>
ffffffffc0207e0a:	844a                	mv	s0,s2
ffffffffc0207e0c:	a039                	j	ffffffffc0207e1a <vfs_do_add+0x7a>
ffffffffc0207e0e:	fe043503          	ld	a0,-32(s0)
ffffffffc0207e12:	85a6                	mv	a1,s1
ffffffffc0207e14:	177030ef          	jal	ffffffffc020b78a <strcmp>
ffffffffc0207e18:	c52d                	beqz	a0,ffffffffc0207e82 <vfs_do_add+0xe2>
ffffffffc0207e1a:	6400                	ld	s0,8(s0)
ffffffffc0207e1c:	ff2419e3          	bne	s0,s2,ffffffffc0207e0e <vfs_do_add+0x6e>
ffffffffc0207e20:	6418                	ld	a4,8(s0)
ffffffffc0207e22:	02098793          	addi	a5,s3,32
ffffffffc0207e26:	0099b023          	sd	s1,0(s3)
ffffffffc0207e2a:	0149b423          	sd	s4,8(s3)
ffffffffc0207e2e:	0159bc23          	sd	s5,24(s3)
ffffffffc0207e32:	0169b823          	sd	s6,16(s3)
ffffffffc0207e36:	e31c                	sd	a5,0(a4)
ffffffffc0207e38:	0289b023          	sd	s0,32(s3)
ffffffffc0207e3c:	02e9b423          	sd	a4,40(s3)
ffffffffc0207e40:	0008e517          	auipc	a0,0x8e
ffffffffc0207e44:	9d850513          	addi	a0,a0,-1576 # ffffffffc0295818 <vdev_list_sem>
ffffffffc0207e48:	e41c                	sd	a5,8(s0)
ffffffffc0207e4a:	fa8fc0ef          	jal	ffffffffc02045f2 <up>
ffffffffc0207e4e:	74a2                	ld	s1,40(sp)
ffffffffc0207e50:	7902                	ld	s2,32(sp)
ffffffffc0207e52:	69e2                	ld	s3,24(sp)
ffffffffc0207e54:	4401                	li	s0,0
ffffffffc0207e56:	70e2                	ld	ra,56(sp)
ffffffffc0207e58:	8522                	mv	a0,s0
ffffffffc0207e5a:	7442                	ld	s0,48(sp)
ffffffffc0207e5c:	6a42                	ld	s4,16(sp)
ffffffffc0207e5e:	6aa2                	ld	s5,8(sp)
ffffffffc0207e60:	6b02                	ld	s6,0(sp)
ffffffffc0207e62:	6121                	addi	sp,sp,64
ffffffffc0207e64:	8082                	ret
ffffffffc0207e66:	5471                	li	s0,-4
ffffffffc0207e68:	8526                	mv	a0,s1
ffffffffc0207e6a:	9fcfa0ef          	jal	ffffffffc0202066 <kfree>
ffffffffc0207e6e:	70e2                	ld	ra,56(sp)
ffffffffc0207e70:	8522                	mv	a0,s0
ffffffffc0207e72:	7442                	ld	s0,48(sp)
ffffffffc0207e74:	74a2                	ld	s1,40(sp)
ffffffffc0207e76:	69e2                	ld	s3,24(sp)
ffffffffc0207e78:	6a42                	ld	s4,16(sp)
ffffffffc0207e7a:	6aa2                	ld	s5,8(sp)
ffffffffc0207e7c:	6b02                	ld	s6,0(sp)
ffffffffc0207e7e:	6121                	addi	sp,sp,64
ffffffffc0207e80:	8082                	ret
ffffffffc0207e82:	0008e517          	auipc	a0,0x8e
ffffffffc0207e86:	99650513          	addi	a0,a0,-1642 # ffffffffc0295818 <vdev_list_sem>
ffffffffc0207e8a:	f68fc0ef          	jal	ffffffffc02045f2 <up>
ffffffffc0207e8e:	854e                	mv	a0,s3
ffffffffc0207e90:	9d6fa0ef          	jal	ffffffffc0202066 <kfree>
ffffffffc0207e94:	5425                	li	s0,-23
ffffffffc0207e96:	7902                	ld	s2,32(sp)
ffffffffc0207e98:	bfc1                	j	ffffffffc0207e68 <vfs_do_add+0xc8>
ffffffffc0207e9a:	5451                	li	s0,-12
ffffffffc0207e9c:	bf6d                	j	ffffffffc0207e56 <vfs_do_add+0xb6>
ffffffffc0207e9e:	74a2                	ld	s1,40(sp)
ffffffffc0207ea0:	5471                	li	s0,-4
ffffffffc0207ea2:	bf55                	j	ffffffffc0207e56 <vfs_do_add+0xb6>
ffffffffc0207ea4:	00006697          	auipc	a3,0x6
ffffffffc0207ea8:	14468693          	addi	a3,a3,324 # ffffffffc020dfe8 <etext+0x2788>
ffffffffc0207eac:	00004617          	auipc	a2,0x4
ffffffffc0207eb0:	dec60613          	addi	a2,a2,-532 # ffffffffc020bc98 <etext+0x438>
ffffffffc0207eb4:	08f00593          	li	a1,143
ffffffffc0207eb8:	00006517          	auipc	a0,0x6
ffffffffc0207ebc:	11850513          	addi	a0,a0,280 # ffffffffc020dfd0 <etext+0x2770>
ffffffffc0207ec0:	f426                	sd	s1,40(sp)
ffffffffc0207ec2:	f04a                	sd	s2,32(sp)
ffffffffc0207ec4:	ec4e                	sd	s3,24(sp)
ffffffffc0207ec6:	d84f80ef          	jal	ffffffffc020044a <__panic>
ffffffffc0207eca:	00006697          	auipc	a3,0x6
ffffffffc0207ece:	0f668693          	addi	a3,a3,246 # ffffffffc020dfc0 <etext+0x2760>
ffffffffc0207ed2:	00004617          	auipc	a2,0x4
ffffffffc0207ed6:	dc660613          	addi	a2,a2,-570 # ffffffffc020bc98 <etext+0x438>
ffffffffc0207eda:	08e00593          	li	a1,142
ffffffffc0207ede:	00006517          	auipc	a0,0x6
ffffffffc0207ee2:	0f250513          	addi	a0,a0,242 # ffffffffc020dfd0 <etext+0x2770>
ffffffffc0207ee6:	f426                	sd	s1,40(sp)
ffffffffc0207ee8:	f04a                	sd	s2,32(sp)
ffffffffc0207eea:	ec4e                	sd	s3,24(sp)
ffffffffc0207eec:	d5ef80ef          	jal	ffffffffc020044a <__panic>

ffffffffc0207ef0 <find_mount.part.0>:
ffffffffc0207ef0:	1141                	addi	sp,sp,-16
ffffffffc0207ef2:	00006697          	auipc	a3,0x6
ffffffffc0207ef6:	0ce68693          	addi	a3,a3,206 # ffffffffc020dfc0 <etext+0x2760>
ffffffffc0207efa:	00004617          	auipc	a2,0x4
ffffffffc0207efe:	d9e60613          	addi	a2,a2,-610 # ffffffffc020bc98 <etext+0x438>
ffffffffc0207f02:	0cd00593          	li	a1,205
ffffffffc0207f06:	00006517          	auipc	a0,0x6
ffffffffc0207f0a:	0ca50513          	addi	a0,a0,202 # ffffffffc020dfd0 <etext+0x2770>
ffffffffc0207f0e:	e406                	sd	ra,8(sp)
ffffffffc0207f10:	d3af80ef          	jal	ffffffffc020044a <__panic>

ffffffffc0207f14 <vfs_devlist_init>:
ffffffffc0207f14:	0008e797          	auipc	a5,0x8e
ffffffffc0207f18:	91c78793          	addi	a5,a5,-1764 # ffffffffc0295830 <vdev_list>
ffffffffc0207f1c:	4585                	li	a1,1
ffffffffc0207f1e:	0008e517          	auipc	a0,0x8e
ffffffffc0207f22:	8fa50513          	addi	a0,a0,-1798 # ffffffffc0295818 <vdev_list_sem>
ffffffffc0207f26:	e79c                	sd	a5,8(a5)
ffffffffc0207f28:	e39c                	sd	a5,0(a5)
ffffffffc0207f2a:	ec2fc06f          	j	ffffffffc02045ec <sem_init>

ffffffffc0207f2e <vfs_cleanup>:
ffffffffc0207f2e:	1101                	addi	sp,sp,-32
ffffffffc0207f30:	e426                	sd	s1,8(sp)
ffffffffc0207f32:	0008e497          	auipc	s1,0x8e
ffffffffc0207f36:	8fe48493          	addi	s1,s1,-1794 # ffffffffc0295830 <vdev_list>
ffffffffc0207f3a:	649c                	ld	a5,8(s1)
ffffffffc0207f3c:	ec06                	sd	ra,24(sp)
ffffffffc0207f3e:	02978f63          	beq	a5,s1,ffffffffc0207f7c <vfs_cleanup+0x4e>
ffffffffc0207f42:	0008e517          	auipc	a0,0x8e
ffffffffc0207f46:	8d650513          	addi	a0,a0,-1834 # ffffffffc0295818 <vdev_list_sem>
ffffffffc0207f4a:	e822                	sd	s0,16(sp)
ffffffffc0207f4c:	eaafc0ef          	jal	ffffffffc02045f6 <down>
ffffffffc0207f50:	6480                	ld	s0,8(s1)
ffffffffc0207f52:	00940b63          	beq	s0,s1,ffffffffc0207f68 <vfs_cleanup+0x3a>
ffffffffc0207f56:	ff043783          	ld	a5,-16(s0)
ffffffffc0207f5a:	853e                	mv	a0,a5
ffffffffc0207f5c:	c399                	beqz	a5,ffffffffc0207f62 <vfs_cleanup+0x34>
ffffffffc0207f5e:	6bfc                	ld	a5,208(a5)
ffffffffc0207f60:	9782                	jalr	a5
ffffffffc0207f62:	6400                	ld	s0,8(s0)
ffffffffc0207f64:	fe9419e3          	bne	s0,s1,ffffffffc0207f56 <vfs_cleanup+0x28>
ffffffffc0207f68:	6442                	ld	s0,16(sp)
ffffffffc0207f6a:	60e2                	ld	ra,24(sp)
ffffffffc0207f6c:	64a2                	ld	s1,8(sp)
ffffffffc0207f6e:	0008e517          	auipc	a0,0x8e
ffffffffc0207f72:	8aa50513          	addi	a0,a0,-1878 # ffffffffc0295818 <vdev_list_sem>
ffffffffc0207f76:	6105                	addi	sp,sp,32
ffffffffc0207f78:	e7afc06f          	j	ffffffffc02045f2 <up>
ffffffffc0207f7c:	60e2                	ld	ra,24(sp)
ffffffffc0207f7e:	64a2                	ld	s1,8(sp)
ffffffffc0207f80:	6105                	addi	sp,sp,32
ffffffffc0207f82:	8082                	ret

ffffffffc0207f84 <vfs_get_root>:
ffffffffc0207f84:	7179                	addi	sp,sp,-48
ffffffffc0207f86:	f406                	sd	ra,40(sp)
ffffffffc0207f88:	c949                	beqz	a0,ffffffffc020801a <vfs_get_root+0x96>
ffffffffc0207f8a:	e84a                	sd	s2,16(sp)
ffffffffc0207f8c:	0008e917          	auipc	s2,0x8e
ffffffffc0207f90:	8a490913          	addi	s2,s2,-1884 # ffffffffc0295830 <vdev_list>
ffffffffc0207f94:	00893783          	ld	a5,8(s2)
ffffffffc0207f98:	ec26                	sd	s1,24(sp)
ffffffffc0207f9a:	07278e63          	beq	a5,s2,ffffffffc0208016 <vfs_get_root+0x92>
ffffffffc0207f9e:	e44e                	sd	s3,8(sp)
ffffffffc0207fa0:	89aa                	mv	s3,a0
ffffffffc0207fa2:	0008e517          	auipc	a0,0x8e
ffffffffc0207fa6:	87650513          	addi	a0,a0,-1930 # ffffffffc0295818 <vdev_list_sem>
ffffffffc0207faa:	f022                	sd	s0,32(sp)
ffffffffc0207fac:	e052                	sd	s4,0(sp)
ffffffffc0207fae:	844a                	mv	s0,s2
ffffffffc0207fb0:	8a2e                	mv	s4,a1
ffffffffc0207fb2:	e44fc0ef          	jal	ffffffffc02045f6 <down>
ffffffffc0207fb6:	a801                	j	ffffffffc0207fc6 <vfs_get_root+0x42>
ffffffffc0207fb8:	fe043583          	ld	a1,-32(s0)
ffffffffc0207fbc:	854e                	mv	a0,s3
ffffffffc0207fbe:	7cc030ef          	jal	ffffffffc020b78a <strcmp>
ffffffffc0207fc2:	84aa                	mv	s1,a0
ffffffffc0207fc4:	c505                	beqz	a0,ffffffffc0207fec <vfs_get_root+0x68>
ffffffffc0207fc6:	6400                	ld	s0,8(s0)
ffffffffc0207fc8:	ff2418e3          	bne	s0,s2,ffffffffc0207fb8 <vfs_get_root+0x34>
ffffffffc0207fcc:	54cd                	li	s1,-13
ffffffffc0207fce:	0008e517          	auipc	a0,0x8e
ffffffffc0207fd2:	84a50513          	addi	a0,a0,-1974 # ffffffffc0295818 <vdev_list_sem>
ffffffffc0207fd6:	e1cfc0ef          	jal	ffffffffc02045f2 <up>
ffffffffc0207fda:	7402                	ld	s0,32(sp)
ffffffffc0207fdc:	69a2                	ld	s3,8(sp)
ffffffffc0207fde:	6a02                	ld	s4,0(sp)
ffffffffc0207fe0:	70a2                	ld	ra,40(sp)
ffffffffc0207fe2:	6942                	ld	s2,16(sp)
ffffffffc0207fe4:	8526                	mv	a0,s1
ffffffffc0207fe6:	64e2                	ld	s1,24(sp)
ffffffffc0207fe8:	6145                	addi	sp,sp,48
ffffffffc0207fea:	8082                	ret
ffffffffc0207fec:	ff043503          	ld	a0,-16(s0)
ffffffffc0207ff0:	c519                	beqz	a0,ffffffffc0207ffe <vfs_get_root+0x7a>
ffffffffc0207ff2:	617c                	ld	a5,192(a0)
ffffffffc0207ff4:	9782                	jalr	a5
ffffffffc0207ff6:	c519                	beqz	a0,ffffffffc0208004 <vfs_get_root+0x80>
ffffffffc0207ff8:	00aa3023          	sd	a0,0(s4)
ffffffffc0207ffc:	bfc9                	j	ffffffffc0207fce <vfs_get_root+0x4a>
ffffffffc0207ffe:	ff843783          	ld	a5,-8(s0)
ffffffffc0208002:	c399                	beqz	a5,ffffffffc0208008 <vfs_get_root+0x84>
ffffffffc0208004:	54c9                	li	s1,-14
ffffffffc0208006:	b7e1                	j	ffffffffc0207fce <vfs_get_root+0x4a>
ffffffffc0208008:	fe843503          	ld	a0,-24(s0)
ffffffffc020800c:	a89ff0ef          	jal	ffffffffc0207a94 <inode_ref_inc>
ffffffffc0208010:	fe843503          	ld	a0,-24(s0)
ffffffffc0208014:	b7cd                	j	ffffffffc0207ff6 <vfs_get_root+0x72>
ffffffffc0208016:	54cd                	li	s1,-13
ffffffffc0208018:	b7e1                	j	ffffffffc0207fe0 <vfs_get_root+0x5c>
ffffffffc020801a:	00006697          	auipc	a3,0x6
ffffffffc020801e:	fa668693          	addi	a3,a3,-90 # ffffffffc020dfc0 <etext+0x2760>
ffffffffc0208022:	00004617          	auipc	a2,0x4
ffffffffc0208026:	c7660613          	addi	a2,a2,-906 # ffffffffc020bc98 <etext+0x438>
ffffffffc020802a:	04500593          	li	a1,69
ffffffffc020802e:	00006517          	auipc	a0,0x6
ffffffffc0208032:	fa250513          	addi	a0,a0,-94 # ffffffffc020dfd0 <etext+0x2770>
ffffffffc0208036:	f022                	sd	s0,32(sp)
ffffffffc0208038:	ec26                	sd	s1,24(sp)
ffffffffc020803a:	e84a                	sd	s2,16(sp)
ffffffffc020803c:	e44e                	sd	s3,8(sp)
ffffffffc020803e:	e052                	sd	s4,0(sp)
ffffffffc0208040:	c0af80ef          	jal	ffffffffc020044a <__panic>

ffffffffc0208044 <vfs_get_devname>:
ffffffffc0208044:	0008d697          	auipc	a3,0x8d
ffffffffc0208048:	7ec68693          	addi	a3,a3,2028 # ffffffffc0295830 <vdev_list>
ffffffffc020804c:	87b6                	mv	a5,a3
ffffffffc020804e:	e511                	bnez	a0,ffffffffc020805a <vfs_get_devname+0x16>
ffffffffc0208050:	a829                	j	ffffffffc020806a <vfs_get_devname+0x26>
ffffffffc0208052:	ff07b703          	ld	a4,-16(a5)
ffffffffc0208056:	00a70763          	beq	a4,a0,ffffffffc0208064 <vfs_get_devname+0x20>
ffffffffc020805a:	679c                	ld	a5,8(a5)
ffffffffc020805c:	fed79be3          	bne	a5,a3,ffffffffc0208052 <vfs_get_devname+0xe>
ffffffffc0208060:	4501                	li	a0,0
ffffffffc0208062:	8082                	ret
ffffffffc0208064:	fe07b503          	ld	a0,-32(a5)
ffffffffc0208068:	8082                	ret
ffffffffc020806a:	1141                	addi	sp,sp,-16
ffffffffc020806c:	00006697          	auipc	a3,0x6
ffffffffc0208070:	fdc68693          	addi	a3,a3,-36 # ffffffffc020e048 <etext+0x27e8>
ffffffffc0208074:	00004617          	auipc	a2,0x4
ffffffffc0208078:	c2460613          	addi	a2,a2,-988 # ffffffffc020bc98 <etext+0x438>
ffffffffc020807c:	06a00593          	li	a1,106
ffffffffc0208080:	00006517          	auipc	a0,0x6
ffffffffc0208084:	f5050513          	addi	a0,a0,-176 # ffffffffc020dfd0 <etext+0x2770>
ffffffffc0208088:	e406                	sd	ra,8(sp)
ffffffffc020808a:	bc0f80ef          	jal	ffffffffc020044a <__panic>

ffffffffc020808e <vfs_add_dev>:
ffffffffc020808e:	86b2                	mv	a3,a2
ffffffffc0208090:	4601                	li	a2,0
ffffffffc0208092:	d0fff06f          	j	ffffffffc0207da0 <vfs_do_add>

ffffffffc0208096 <vfs_mount>:
ffffffffc0208096:	7179                	addi	sp,sp,-48
ffffffffc0208098:	e84a                	sd	s2,16(sp)
ffffffffc020809a:	892a                	mv	s2,a0
ffffffffc020809c:	0008d517          	auipc	a0,0x8d
ffffffffc02080a0:	77c50513          	addi	a0,a0,1916 # ffffffffc0295818 <vdev_list_sem>
ffffffffc02080a4:	e44e                	sd	s3,8(sp)
ffffffffc02080a6:	f406                	sd	ra,40(sp)
ffffffffc02080a8:	f022                	sd	s0,32(sp)
ffffffffc02080aa:	ec26                	sd	s1,24(sp)
ffffffffc02080ac:	89ae                	mv	s3,a1
ffffffffc02080ae:	d48fc0ef          	jal	ffffffffc02045f6 <down>
ffffffffc02080b2:	0c090a63          	beqz	s2,ffffffffc0208186 <vfs_mount+0xf0>
ffffffffc02080b6:	0008d497          	auipc	s1,0x8d
ffffffffc02080ba:	77a48493          	addi	s1,s1,1914 # ffffffffc0295830 <vdev_list>
ffffffffc02080be:	6480                	ld	s0,8(s1)
ffffffffc02080c0:	00941663          	bne	s0,s1,ffffffffc02080cc <vfs_mount+0x36>
ffffffffc02080c4:	a8ad                	j	ffffffffc020813e <vfs_mount+0xa8>
ffffffffc02080c6:	6400                	ld	s0,8(s0)
ffffffffc02080c8:	06940b63          	beq	s0,s1,ffffffffc020813e <vfs_mount+0xa8>
ffffffffc02080cc:	ff843783          	ld	a5,-8(s0)
ffffffffc02080d0:	dbfd                	beqz	a5,ffffffffc02080c6 <vfs_mount+0x30>
ffffffffc02080d2:	fe043503          	ld	a0,-32(s0)
ffffffffc02080d6:	85ca                	mv	a1,s2
ffffffffc02080d8:	6b2030ef          	jal	ffffffffc020b78a <strcmp>
ffffffffc02080dc:	f56d                	bnez	a0,ffffffffc02080c6 <vfs_mount+0x30>
ffffffffc02080de:	ff043783          	ld	a5,-16(s0)
ffffffffc02080e2:	e3a5                	bnez	a5,ffffffffc0208142 <vfs_mount+0xac>
ffffffffc02080e4:	fe043783          	ld	a5,-32(s0)
ffffffffc02080e8:	cfbd                	beqz	a5,ffffffffc0208166 <vfs_mount+0xd0>
ffffffffc02080ea:	ff843783          	ld	a5,-8(s0)
ffffffffc02080ee:	cfa5                	beqz	a5,ffffffffc0208166 <vfs_mount+0xd0>
ffffffffc02080f0:	fe843503          	ld	a0,-24(s0)
ffffffffc02080f4:	c929                	beqz	a0,ffffffffc0208146 <vfs_mount+0xb0>
ffffffffc02080f6:	4d38                	lw	a4,88(a0)
ffffffffc02080f8:	6785                	lui	a5,0x1
ffffffffc02080fa:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc02080fe:	04f71463          	bne	a4,a5,ffffffffc0208146 <vfs_mount+0xb0>
ffffffffc0208102:	ff040593          	addi	a1,s0,-16
ffffffffc0208106:	9982                	jalr	s3
ffffffffc0208108:	84aa                	mv	s1,a0
ffffffffc020810a:	ed01                	bnez	a0,ffffffffc0208122 <vfs_mount+0x8c>
ffffffffc020810c:	ff043783          	ld	a5,-16(s0)
ffffffffc0208110:	cfad                	beqz	a5,ffffffffc020818a <vfs_mount+0xf4>
ffffffffc0208112:	fe043583          	ld	a1,-32(s0)
ffffffffc0208116:	00006517          	auipc	a0,0x6
ffffffffc020811a:	fc250513          	addi	a0,a0,-62 # ffffffffc020e0d8 <etext+0x2878>
ffffffffc020811e:	888f80ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0208122:	0008d517          	auipc	a0,0x8d
ffffffffc0208126:	6f650513          	addi	a0,a0,1782 # ffffffffc0295818 <vdev_list_sem>
ffffffffc020812a:	cc8fc0ef          	jal	ffffffffc02045f2 <up>
ffffffffc020812e:	70a2                	ld	ra,40(sp)
ffffffffc0208130:	7402                	ld	s0,32(sp)
ffffffffc0208132:	6942                	ld	s2,16(sp)
ffffffffc0208134:	69a2                	ld	s3,8(sp)
ffffffffc0208136:	8526                	mv	a0,s1
ffffffffc0208138:	64e2                	ld	s1,24(sp)
ffffffffc020813a:	6145                	addi	sp,sp,48
ffffffffc020813c:	8082                	ret
ffffffffc020813e:	54cd                	li	s1,-13
ffffffffc0208140:	b7cd                	j	ffffffffc0208122 <vfs_mount+0x8c>
ffffffffc0208142:	54c5                	li	s1,-15
ffffffffc0208144:	bff9                	j	ffffffffc0208122 <vfs_mount+0x8c>
ffffffffc0208146:	00006697          	auipc	a3,0x6
ffffffffc020814a:	f4268693          	addi	a3,a3,-190 # ffffffffc020e088 <etext+0x2828>
ffffffffc020814e:	00004617          	auipc	a2,0x4
ffffffffc0208152:	b4a60613          	addi	a2,a2,-1206 # ffffffffc020bc98 <etext+0x438>
ffffffffc0208156:	0ed00593          	li	a1,237
ffffffffc020815a:	00006517          	auipc	a0,0x6
ffffffffc020815e:	e7650513          	addi	a0,a0,-394 # ffffffffc020dfd0 <etext+0x2770>
ffffffffc0208162:	ae8f80ef          	jal	ffffffffc020044a <__panic>
ffffffffc0208166:	00006697          	auipc	a3,0x6
ffffffffc020816a:	ef268693          	addi	a3,a3,-270 # ffffffffc020e058 <etext+0x27f8>
ffffffffc020816e:	00004617          	auipc	a2,0x4
ffffffffc0208172:	b2a60613          	addi	a2,a2,-1238 # ffffffffc020bc98 <etext+0x438>
ffffffffc0208176:	0eb00593          	li	a1,235
ffffffffc020817a:	00006517          	auipc	a0,0x6
ffffffffc020817e:	e5650513          	addi	a0,a0,-426 # ffffffffc020dfd0 <etext+0x2770>
ffffffffc0208182:	ac8f80ef          	jal	ffffffffc020044a <__panic>
ffffffffc0208186:	d6bff0ef          	jal	ffffffffc0207ef0 <find_mount.part.0>
ffffffffc020818a:	00006697          	auipc	a3,0x6
ffffffffc020818e:	f3668693          	addi	a3,a3,-202 # ffffffffc020e0c0 <etext+0x2860>
ffffffffc0208192:	00004617          	auipc	a2,0x4
ffffffffc0208196:	b0660613          	addi	a2,a2,-1274 # ffffffffc020bc98 <etext+0x438>
ffffffffc020819a:	0ef00593          	li	a1,239
ffffffffc020819e:	00006517          	auipc	a0,0x6
ffffffffc02081a2:	e3250513          	addi	a0,a0,-462 # ffffffffc020dfd0 <etext+0x2770>
ffffffffc02081a6:	aa4f80ef          	jal	ffffffffc020044a <__panic>

ffffffffc02081aa <vfs_open>:
ffffffffc02081aa:	7159                	addi	sp,sp,-112
ffffffffc02081ac:	f486                	sd	ra,104(sp)
ffffffffc02081ae:	e0d2                	sd	s4,64(sp)
ffffffffc02081b0:	0035f793          	andi	a5,a1,3
ffffffffc02081b4:	10078363          	beqz	a5,ffffffffc02082ba <vfs_open+0x110>
ffffffffc02081b8:	470d                	li	a4,3
ffffffffc02081ba:	12e78163          	beq	a5,a4,ffffffffc02082dc <vfs_open+0x132>
ffffffffc02081be:	f0a2                	sd	s0,96(sp)
ffffffffc02081c0:	eca6                	sd	s1,88(sp)
ffffffffc02081c2:	e8ca                	sd	s2,80(sp)
ffffffffc02081c4:	e4ce                	sd	s3,72(sp)
ffffffffc02081c6:	fc56                	sd	s5,56(sp)
ffffffffc02081c8:	f85a                	sd	s6,48(sp)
ffffffffc02081ca:	0105fa13          	andi	s4,a1,16
ffffffffc02081ce:	842e                	mv	s0,a1
ffffffffc02081d0:	00447793          	andi	a5,s0,4
ffffffffc02081d4:	8b32                	mv	s6,a2
ffffffffc02081d6:	082c                	addi	a1,sp,24
ffffffffc02081d8:	00345613          	srli	a2,s0,0x3
ffffffffc02081dc:	8abe                	mv	s5,a5
ffffffffc02081de:	0027d493          	srli	s1,a5,0x2
ffffffffc02081e2:	892a                	mv	s2,a0
ffffffffc02081e4:	00167993          	andi	s3,a2,1
ffffffffc02081e8:	2ba000ef          	jal	ffffffffc02084a2 <vfs_lookup>
ffffffffc02081ec:	87aa                	mv	a5,a0
ffffffffc02081ee:	c175                	beqz	a0,ffffffffc02082d2 <vfs_open+0x128>
ffffffffc02081f0:	01050713          	addi	a4,a0,16
ffffffffc02081f4:	eb45                	bnez	a4,ffffffffc02082a4 <vfs_open+0xfa>
ffffffffc02081f6:	c4dd                	beqz	s1,ffffffffc02082a4 <vfs_open+0xfa>
ffffffffc02081f8:	854a                	mv	a0,s2
ffffffffc02081fa:	1010                	addi	a2,sp,32
ffffffffc02081fc:	102c                	addi	a1,sp,40
ffffffffc02081fe:	32e000ef          	jal	ffffffffc020852c <vfs_lookup_parent>
ffffffffc0208202:	87aa                	mv	a5,a0
ffffffffc0208204:	e145                	bnez	a0,ffffffffc02082a4 <vfs_open+0xfa>
ffffffffc0208206:	7522                	ld	a0,40(sp)
ffffffffc0208208:	14050c63          	beqz	a0,ffffffffc0208360 <vfs_open+0x1b6>
ffffffffc020820c:	793c                	ld	a5,112(a0)
ffffffffc020820e:	14078963          	beqz	a5,ffffffffc0208360 <vfs_open+0x1b6>
ffffffffc0208212:	77bc                	ld	a5,104(a5)
ffffffffc0208214:	14078663          	beqz	a5,ffffffffc0208360 <vfs_open+0x1b6>
ffffffffc0208218:	00006597          	auipc	a1,0x6
ffffffffc020821c:	f3858593          	addi	a1,a1,-200 # ffffffffc020e150 <etext+0x28f0>
ffffffffc0208220:	e42a                	sd	a0,8(sp)
ffffffffc0208222:	887ff0ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc0208226:	6522                	ld	a0,8(sp)
ffffffffc0208228:	7582                	ld	a1,32(sp)
ffffffffc020822a:	0834                	addi	a3,sp,24
ffffffffc020822c:	793c                	ld	a5,112(a0)
ffffffffc020822e:	7522                	ld	a0,40(sp)
ffffffffc0208230:	864e                	mv	a2,s3
ffffffffc0208232:	77bc                	ld	a5,104(a5)
ffffffffc0208234:	9782                	jalr	a5
ffffffffc0208236:	6562                	ld	a0,24(sp)
ffffffffc0208238:	10050463          	beqz	a0,ffffffffc0208340 <vfs_open+0x196>
ffffffffc020823c:	793c                	ld	a5,112(a0)
ffffffffc020823e:	c3e9                	beqz	a5,ffffffffc0208300 <vfs_open+0x156>
ffffffffc0208240:	679c                	ld	a5,8(a5)
ffffffffc0208242:	cfdd                	beqz	a5,ffffffffc0208300 <vfs_open+0x156>
ffffffffc0208244:	00006597          	auipc	a1,0x6
ffffffffc0208248:	f7458593          	addi	a1,a1,-140 # ffffffffc020e1b8 <etext+0x2958>
ffffffffc020824c:	e42a                	sd	a0,8(sp)
ffffffffc020824e:	85bff0ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc0208252:	6522                	ld	a0,8(sp)
ffffffffc0208254:	85a2                	mv	a1,s0
ffffffffc0208256:	793c                	ld	a5,112(a0)
ffffffffc0208258:	6562                	ld	a0,24(sp)
ffffffffc020825a:	679c                	ld	a5,8(a5)
ffffffffc020825c:	9782                	jalr	a5
ffffffffc020825e:	87aa                	mv	a5,a0
ffffffffc0208260:	e43e                	sd	a5,8(sp)
ffffffffc0208262:	6562                	ld	a0,24(sp)
ffffffffc0208264:	e3d1                	bnez	a5,ffffffffc02082e8 <vfs_open+0x13e>
ffffffffc0208266:	839ff0ef          	jal	ffffffffc0207a9e <inode_open_inc>
ffffffffc020826a:	014ae733          	or	a4,s5,s4
ffffffffc020826e:	67a2                	ld	a5,8(sp)
ffffffffc0208270:	c71d                	beqz	a4,ffffffffc020829e <vfs_open+0xf4>
ffffffffc0208272:	6462                	ld	s0,24(sp)
ffffffffc0208274:	c455                	beqz	s0,ffffffffc0208320 <vfs_open+0x176>
ffffffffc0208276:	7838                	ld	a4,112(s0)
ffffffffc0208278:	c745                	beqz	a4,ffffffffc0208320 <vfs_open+0x176>
ffffffffc020827a:	7338                	ld	a4,96(a4)
ffffffffc020827c:	c355                	beqz	a4,ffffffffc0208320 <vfs_open+0x176>
ffffffffc020827e:	8522                	mv	a0,s0
ffffffffc0208280:	00006597          	auipc	a1,0x6
ffffffffc0208284:	f9858593          	addi	a1,a1,-104 # ffffffffc020e218 <etext+0x29b8>
ffffffffc0208288:	e43e                	sd	a5,8(sp)
ffffffffc020828a:	81fff0ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc020828e:	7838                	ld	a4,112(s0)
ffffffffc0208290:	6562                	ld	a0,24(sp)
ffffffffc0208292:	4581                	li	a1,0
ffffffffc0208294:	7338                	ld	a4,96(a4)
ffffffffc0208296:	9702                	jalr	a4
ffffffffc0208298:	67a2                	ld	a5,8(sp)
ffffffffc020829a:	842a                	mv	s0,a0
ffffffffc020829c:	e931                	bnez	a0,ffffffffc02082f0 <vfs_open+0x146>
ffffffffc020829e:	6762                	ld	a4,24(sp)
ffffffffc02082a0:	00eb3023          	sd	a4,0(s6)
ffffffffc02082a4:	7406                	ld	s0,96(sp)
ffffffffc02082a6:	64e6                	ld	s1,88(sp)
ffffffffc02082a8:	6946                	ld	s2,80(sp)
ffffffffc02082aa:	69a6                	ld	s3,72(sp)
ffffffffc02082ac:	7ae2                	ld	s5,56(sp)
ffffffffc02082ae:	7b42                	ld	s6,48(sp)
ffffffffc02082b0:	70a6                	ld	ra,104(sp)
ffffffffc02082b2:	6a06                	ld	s4,64(sp)
ffffffffc02082b4:	853e                	mv	a0,a5
ffffffffc02082b6:	6165                	addi	sp,sp,112
ffffffffc02082b8:	8082                	ret
ffffffffc02082ba:	0105f713          	andi	a4,a1,16
ffffffffc02082be:	8a3a                	mv	s4,a4
ffffffffc02082c0:	57f5                	li	a5,-3
ffffffffc02082c2:	f77d                	bnez	a4,ffffffffc02082b0 <vfs_open+0x106>
ffffffffc02082c4:	f0a2                	sd	s0,96(sp)
ffffffffc02082c6:	eca6                	sd	s1,88(sp)
ffffffffc02082c8:	e8ca                	sd	s2,80(sp)
ffffffffc02082ca:	e4ce                	sd	s3,72(sp)
ffffffffc02082cc:	fc56                	sd	s5,56(sp)
ffffffffc02082ce:	f85a                	sd	s6,48(sp)
ffffffffc02082d0:	bdfd                	j	ffffffffc02081ce <vfs_open+0x24>
ffffffffc02082d2:	f60982e3          	beqz	s3,ffffffffc0208236 <vfs_open+0x8c>
ffffffffc02082d6:	d0a5                	beqz	s1,ffffffffc0208236 <vfs_open+0x8c>
ffffffffc02082d8:	57a5                	li	a5,-23
ffffffffc02082da:	b7e9                	j	ffffffffc02082a4 <vfs_open+0xfa>
ffffffffc02082dc:	70a6                	ld	ra,104(sp)
ffffffffc02082de:	57f5                	li	a5,-3
ffffffffc02082e0:	6a06                	ld	s4,64(sp)
ffffffffc02082e2:	853e                	mv	a0,a5
ffffffffc02082e4:	6165                	addi	sp,sp,112
ffffffffc02082e6:	8082                	ret
ffffffffc02082e8:	87bff0ef          	jal	ffffffffc0207b62 <inode_ref_dec>
ffffffffc02082ec:	67a2                	ld	a5,8(sp)
ffffffffc02082ee:	bf5d                	j	ffffffffc02082a4 <vfs_open+0xfa>
ffffffffc02082f0:	6562                	ld	a0,24(sp)
ffffffffc02082f2:	90dff0ef          	jal	ffffffffc0207bfe <inode_open_dec>
ffffffffc02082f6:	6562                	ld	a0,24(sp)
ffffffffc02082f8:	86bff0ef          	jal	ffffffffc0207b62 <inode_ref_dec>
ffffffffc02082fc:	87a2                	mv	a5,s0
ffffffffc02082fe:	b75d                	j	ffffffffc02082a4 <vfs_open+0xfa>
ffffffffc0208300:	00006697          	auipc	a3,0x6
ffffffffc0208304:	e6868693          	addi	a3,a3,-408 # ffffffffc020e168 <etext+0x2908>
ffffffffc0208308:	00004617          	auipc	a2,0x4
ffffffffc020830c:	99060613          	addi	a2,a2,-1648 # ffffffffc020bc98 <etext+0x438>
ffffffffc0208310:	03300593          	li	a1,51
ffffffffc0208314:	00006517          	auipc	a0,0x6
ffffffffc0208318:	e2450513          	addi	a0,a0,-476 # ffffffffc020e138 <etext+0x28d8>
ffffffffc020831c:	92ef80ef          	jal	ffffffffc020044a <__panic>
ffffffffc0208320:	00006697          	auipc	a3,0x6
ffffffffc0208324:	ea068693          	addi	a3,a3,-352 # ffffffffc020e1c0 <etext+0x2960>
ffffffffc0208328:	00004617          	auipc	a2,0x4
ffffffffc020832c:	97060613          	addi	a2,a2,-1680 # ffffffffc020bc98 <etext+0x438>
ffffffffc0208330:	03a00593          	li	a1,58
ffffffffc0208334:	00006517          	auipc	a0,0x6
ffffffffc0208338:	e0450513          	addi	a0,a0,-508 # ffffffffc020e138 <etext+0x28d8>
ffffffffc020833c:	90ef80ef          	jal	ffffffffc020044a <__panic>
ffffffffc0208340:	00006697          	auipc	a3,0x6
ffffffffc0208344:	e1868693          	addi	a3,a3,-488 # ffffffffc020e158 <etext+0x28f8>
ffffffffc0208348:	00004617          	auipc	a2,0x4
ffffffffc020834c:	95060613          	addi	a2,a2,-1712 # ffffffffc020bc98 <etext+0x438>
ffffffffc0208350:	03100593          	li	a1,49
ffffffffc0208354:	00006517          	auipc	a0,0x6
ffffffffc0208358:	de450513          	addi	a0,a0,-540 # ffffffffc020e138 <etext+0x28d8>
ffffffffc020835c:	8eef80ef          	jal	ffffffffc020044a <__panic>
ffffffffc0208360:	00006697          	auipc	a3,0x6
ffffffffc0208364:	d8868693          	addi	a3,a3,-632 # ffffffffc020e0e8 <etext+0x2888>
ffffffffc0208368:	00004617          	auipc	a2,0x4
ffffffffc020836c:	93060613          	addi	a2,a2,-1744 # ffffffffc020bc98 <etext+0x438>
ffffffffc0208370:	02c00593          	li	a1,44
ffffffffc0208374:	00006517          	auipc	a0,0x6
ffffffffc0208378:	dc450513          	addi	a0,a0,-572 # ffffffffc020e138 <etext+0x28d8>
ffffffffc020837c:	8cef80ef          	jal	ffffffffc020044a <__panic>

ffffffffc0208380 <vfs_close>:
ffffffffc0208380:	1141                	addi	sp,sp,-16
ffffffffc0208382:	e406                	sd	ra,8(sp)
ffffffffc0208384:	e022                	sd	s0,0(sp)
ffffffffc0208386:	842a                	mv	s0,a0
ffffffffc0208388:	877ff0ef          	jal	ffffffffc0207bfe <inode_open_dec>
ffffffffc020838c:	8522                	mv	a0,s0
ffffffffc020838e:	fd4ff0ef          	jal	ffffffffc0207b62 <inode_ref_dec>
ffffffffc0208392:	60a2                	ld	ra,8(sp)
ffffffffc0208394:	6402                	ld	s0,0(sp)
ffffffffc0208396:	4501                	li	a0,0
ffffffffc0208398:	0141                	addi	sp,sp,16
ffffffffc020839a:	8082                	ret

ffffffffc020839c <get_device>:
ffffffffc020839c:	00054e03          	lbu	t3,0(a0)
ffffffffc02083a0:	020e0463          	beqz	t3,ffffffffc02083c8 <get_device+0x2c>
ffffffffc02083a4:	00150693          	addi	a3,a0,1
ffffffffc02083a8:	8736                	mv	a4,a3
ffffffffc02083aa:	87f2                	mv	a5,t3
ffffffffc02083ac:	4801                	li	a6,0
ffffffffc02083ae:	03a00893          	li	a7,58
ffffffffc02083b2:	02f00313          	li	t1,47
ffffffffc02083b6:	01178c63          	beq	a5,a7,ffffffffc02083ce <get_device+0x32>
ffffffffc02083ba:	02678e63          	beq	a5,t1,ffffffffc02083f6 <get_device+0x5a>
ffffffffc02083be:	00074783          	lbu	a5,0(a4)
ffffffffc02083c2:	0705                	addi	a4,a4,1
ffffffffc02083c4:	2805                	addiw	a6,a6,1 # fffffffffffff001 <end+0x3fd686f1>
ffffffffc02083c6:	fbe5                	bnez	a5,ffffffffc02083b6 <get_device+0x1a>
ffffffffc02083c8:	e188                	sd	a0,0(a1)
ffffffffc02083ca:	8532                	mv	a0,a2
ffffffffc02083cc:	a269                	j	ffffffffc0208556 <vfs_get_curdir>
ffffffffc02083ce:	02080663          	beqz	a6,ffffffffc02083fa <get_device+0x5e>
ffffffffc02083d2:	01050733          	add	a4,a0,a6
ffffffffc02083d6:	010687b3          	add	a5,a3,a6
ffffffffc02083da:	00070023          	sb	zero,0(a4)
ffffffffc02083de:	02f00813          	li	a6,47
ffffffffc02083e2:	86be                	mv	a3,a5
ffffffffc02083e4:	0007c703          	lbu	a4,0(a5)
ffffffffc02083e8:	0785                	addi	a5,a5,1
ffffffffc02083ea:	ff070ce3          	beq	a4,a6,ffffffffc02083e2 <get_device+0x46>
ffffffffc02083ee:	e194                	sd	a3,0(a1)
ffffffffc02083f0:	85b2                	mv	a1,a2
ffffffffc02083f2:	b93ff06f          	j	ffffffffc0207f84 <vfs_get_root>
ffffffffc02083f6:	fc0819e3          	bnez	a6,ffffffffc02083c8 <get_device+0x2c>
ffffffffc02083fa:	7139                	addi	sp,sp,-64
ffffffffc02083fc:	f822                	sd	s0,48(sp)
ffffffffc02083fe:	f426                	sd	s1,40(sp)
ffffffffc0208400:	fc06                	sd	ra,56(sp)
ffffffffc0208402:	02f00793          	li	a5,47
ffffffffc0208406:	8432                	mv	s0,a2
ffffffffc0208408:	84ae                	mv	s1,a1
ffffffffc020840a:	04fe0563          	beq	t3,a5,ffffffffc0208454 <get_device+0xb8>
ffffffffc020840e:	03a00793          	li	a5,58
ffffffffc0208412:	06fe1863          	bne	t3,a5,ffffffffc0208482 <get_device+0xe6>
ffffffffc0208416:	0828                	addi	a0,sp,24
ffffffffc0208418:	e436                	sd	a3,8(sp)
ffffffffc020841a:	13c000ef          	jal	ffffffffc0208556 <vfs_get_curdir>
ffffffffc020841e:	e515                	bnez	a0,ffffffffc020844a <get_device+0xae>
ffffffffc0208420:	67e2                	ld	a5,24(sp)
ffffffffc0208422:	77a8                	ld	a0,104(a5)
ffffffffc0208424:	cd1d                	beqz	a0,ffffffffc0208462 <get_device+0xc6>
ffffffffc0208426:	617c                	ld	a5,192(a0)
ffffffffc0208428:	9782                	jalr	a5
ffffffffc020842a:	87aa                	mv	a5,a0
ffffffffc020842c:	6562                	ld	a0,24(sp)
ffffffffc020842e:	e01c                	sd	a5,0(s0)
ffffffffc0208430:	f32ff0ef          	jal	ffffffffc0207b62 <inode_ref_dec>
ffffffffc0208434:	66a2                	ld	a3,8(sp)
ffffffffc0208436:	02f00713          	li	a4,47
ffffffffc020843a:	a011                	j	ffffffffc020843e <get_device+0xa2>
ffffffffc020843c:	0685                	addi	a3,a3,1
ffffffffc020843e:	0006c783          	lbu	a5,0(a3)
ffffffffc0208442:	fee78de3          	beq	a5,a4,ffffffffc020843c <get_device+0xa0>
ffffffffc0208446:	e094                	sd	a3,0(s1)
ffffffffc0208448:	4501                	li	a0,0
ffffffffc020844a:	70e2                	ld	ra,56(sp)
ffffffffc020844c:	7442                	ld	s0,48(sp)
ffffffffc020844e:	74a2                	ld	s1,40(sp)
ffffffffc0208450:	6121                	addi	sp,sp,64
ffffffffc0208452:	8082                	ret
ffffffffc0208454:	8532                	mv	a0,a2
ffffffffc0208456:	e436                	sd	a3,8(sp)
ffffffffc0208458:	8ebff0ef          	jal	ffffffffc0207d42 <vfs_get_bootfs>
ffffffffc020845c:	66a2                	ld	a3,8(sp)
ffffffffc020845e:	dd61                	beqz	a0,ffffffffc0208436 <get_device+0x9a>
ffffffffc0208460:	b7ed                	j	ffffffffc020844a <get_device+0xae>
ffffffffc0208462:	00006697          	auipc	a3,0x6
ffffffffc0208466:	dee68693          	addi	a3,a3,-530 # ffffffffc020e250 <etext+0x29f0>
ffffffffc020846a:	00004617          	auipc	a2,0x4
ffffffffc020846e:	82e60613          	addi	a2,a2,-2002 # ffffffffc020bc98 <etext+0x438>
ffffffffc0208472:	03900593          	li	a1,57
ffffffffc0208476:	00006517          	auipc	a0,0x6
ffffffffc020847a:	dc250513          	addi	a0,a0,-574 # ffffffffc020e238 <etext+0x29d8>
ffffffffc020847e:	fcdf70ef          	jal	ffffffffc020044a <__panic>
ffffffffc0208482:	00006697          	auipc	a3,0x6
ffffffffc0208486:	da668693          	addi	a3,a3,-602 # ffffffffc020e228 <etext+0x29c8>
ffffffffc020848a:	00004617          	auipc	a2,0x4
ffffffffc020848e:	80e60613          	addi	a2,a2,-2034 # ffffffffc020bc98 <etext+0x438>
ffffffffc0208492:	03300593          	li	a1,51
ffffffffc0208496:	00006517          	auipc	a0,0x6
ffffffffc020849a:	da250513          	addi	a0,a0,-606 # ffffffffc020e238 <etext+0x29d8>
ffffffffc020849e:	fadf70ef          	jal	ffffffffc020044a <__panic>

ffffffffc02084a2 <vfs_lookup>:
ffffffffc02084a2:	7139                	addi	sp,sp,-64
ffffffffc02084a4:	f822                	sd	s0,48(sp)
ffffffffc02084a6:	1030                	addi	a2,sp,40
ffffffffc02084a8:	842e                	mv	s0,a1
ffffffffc02084aa:	082c                	addi	a1,sp,24
ffffffffc02084ac:	fc06                	sd	ra,56(sp)
ffffffffc02084ae:	ec2a                	sd	a0,24(sp)
ffffffffc02084b0:	eedff0ef          	jal	ffffffffc020839c <get_device>
ffffffffc02084b4:	87aa                	mv	a5,a0
ffffffffc02084b6:	e121                	bnez	a0,ffffffffc02084f6 <vfs_lookup+0x54>
ffffffffc02084b8:	6762                	ld	a4,24(sp)
ffffffffc02084ba:	7522                	ld	a0,40(sp)
ffffffffc02084bc:	00074683          	lbu	a3,0(a4)
ffffffffc02084c0:	c2a1                	beqz	a3,ffffffffc0208500 <vfs_lookup+0x5e>
ffffffffc02084c2:	c529                	beqz	a0,ffffffffc020850c <vfs_lookup+0x6a>
ffffffffc02084c4:	793c                	ld	a5,112(a0)
ffffffffc02084c6:	c3b9                	beqz	a5,ffffffffc020850c <vfs_lookup+0x6a>
ffffffffc02084c8:	7bbc                	ld	a5,112(a5)
ffffffffc02084ca:	c3a9                	beqz	a5,ffffffffc020850c <vfs_lookup+0x6a>
ffffffffc02084cc:	00006597          	auipc	a1,0x6
ffffffffc02084d0:	dec58593          	addi	a1,a1,-532 # ffffffffc020e2b8 <etext+0x2a58>
ffffffffc02084d4:	e83a                	sd	a4,16(sp)
ffffffffc02084d6:	e42a                	sd	a0,8(sp)
ffffffffc02084d8:	dd0ff0ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc02084dc:	6522                	ld	a0,8(sp)
ffffffffc02084de:	65c2                	ld	a1,16(sp)
ffffffffc02084e0:	8622                	mv	a2,s0
ffffffffc02084e2:	793c                	ld	a5,112(a0)
ffffffffc02084e4:	7522                	ld	a0,40(sp)
ffffffffc02084e6:	7bbc                	ld	a5,112(a5)
ffffffffc02084e8:	9782                	jalr	a5
ffffffffc02084ea:	87aa                	mv	a5,a0
ffffffffc02084ec:	7522                	ld	a0,40(sp)
ffffffffc02084ee:	e43e                	sd	a5,8(sp)
ffffffffc02084f0:	e72ff0ef          	jal	ffffffffc0207b62 <inode_ref_dec>
ffffffffc02084f4:	67a2                	ld	a5,8(sp)
ffffffffc02084f6:	70e2                	ld	ra,56(sp)
ffffffffc02084f8:	7442                	ld	s0,48(sp)
ffffffffc02084fa:	853e                	mv	a0,a5
ffffffffc02084fc:	6121                	addi	sp,sp,64
ffffffffc02084fe:	8082                	ret
ffffffffc0208500:	e008                	sd	a0,0(s0)
ffffffffc0208502:	70e2                	ld	ra,56(sp)
ffffffffc0208504:	7442                	ld	s0,48(sp)
ffffffffc0208506:	853e                	mv	a0,a5
ffffffffc0208508:	6121                	addi	sp,sp,64
ffffffffc020850a:	8082                	ret
ffffffffc020850c:	00006697          	auipc	a3,0x6
ffffffffc0208510:	d5c68693          	addi	a3,a3,-676 # ffffffffc020e268 <etext+0x2a08>
ffffffffc0208514:	00003617          	auipc	a2,0x3
ffffffffc0208518:	78460613          	addi	a2,a2,1924 # ffffffffc020bc98 <etext+0x438>
ffffffffc020851c:	04f00593          	li	a1,79
ffffffffc0208520:	00006517          	auipc	a0,0x6
ffffffffc0208524:	d1850513          	addi	a0,a0,-744 # ffffffffc020e238 <etext+0x29d8>
ffffffffc0208528:	f23f70ef          	jal	ffffffffc020044a <__panic>

ffffffffc020852c <vfs_lookup_parent>:
ffffffffc020852c:	7139                	addi	sp,sp,-64
ffffffffc020852e:	f822                	sd	s0,48(sp)
ffffffffc0208530:	f426                	sd	s1,40(sp)
ffffffffc0208532:	8432                	mv	s0,a2
ffffffffc0208534:	84ae                	mv	s1,a1
ffffffffc0208536:	0830                	addi	a2,sp,24
ffffffffc0208538:	002c                	addi	a1,sp,8
ffffffffc020853a:	fc06                	sd	ra,56(sp)
ffffffffc020853c:	e42a                	sd	a0,8(sp)
ffffffffc020853e:	e5fff0ef          	jal	ffffffffc020839c <get_device>
ffffffffc0208542:	e509                	bnez	a0,ffffffffc020854c <vfs_lookup_parent+0x20>
ffffffffc0208544:	6722                	ld	a4,8(sp)
ffffffffc0208546:	67e2                	ld	a5,24(sp)
ffffffffc0208548:	e018                	sd	a4,0(s0)
ffffffffc020854a:	e09c                	sd	a5,0(s1)
ffffffffc020854c:	70e2                	ld	ra,56(sp)
ffffffffc020854e:	7442                	ld	s0,48(sp)
ffffffffc0208550:	74a2                	ld	s1,40(sp)
ffffffffc0208552:	6121                	addi	sp,sp,64
ffffffffc0208554:	8082                	ret

ffffffffc0208556 <vfs_get_curdir>:
ffffffffc0208556:	0008e797          	auipc	a5,0x8e
ffffffffc020855a:	3727b783          	ld	a5,882(a5) # ffffffffc02968c8 <current>
ffffffffc020855e:	1101                	addi	sp,sp,-32
ffffffffc0208560:	e822                	sd	s0,16(sp)
ffffffffc0208562:	1487b783          	ld	a5,328(a5)
ffffffffc0208566:	ec06                	sd	ra,24(sp)
ffffffffc0208568:	6380                	ld	s0,0(a5)
ffffffffc020856a:	cc09                	beqz	s0,ffffffffc0208584 <vfs_get_curdir+0x2e>
ffffffffc020856c:	e426                	sd	s1,8(sp)
ffffffffc020856e:	84aa                	mv	s1,a0
ffffffffc0208570:	8522                	mv	a0,s0
ffffffffc0208572:	d22ff0ef          	jal	ffffffffc0207a94 <inode_ref_inc>
ffffffffc0208576:	e080                	sd	s0,0(s1)
ffffffffc0208578:	64a2                	ld	s1,8(sp)
ffffffffc020857a:	4501                	li	a0,0
ffffffffc020857c:	60e2                	ld	ra,24(sp)
ffffffffc020857e:	6442                	ld	s0,16(sp)
ffffffffc0208580:	6105                	addi	sp,sp,32
ffffffffc0208582:	8082                	ret
ffffffffc0208584:	5541                	li	a0,-16
ffffffffc0208586:	bfdd                	j	ffffffffc020857c <vfs_get_curdir+0x26>

ffffffffc0208588 <vfs_set_curdir>:
ffffffffc0208588:	7139                	addi	sp,sp,-64
ffffffffc020858a:	f04a                	sd	s2,32(sp)
ffffffffc020858c:	0008e917          	auipc	s2,0x8e
ffffffffc0208590:	33c90913          	addi	s2,s2,828 # ffffffffc02968c8 <current>
ffffffffc0208594:	00093783          	ld	a5,0(s2)
ffffffffc0208598:	f822                	sd	s0,48(sp)
ffffffffc020859a:	842a                	mv	s0,a0
ffffffffc020859c:	1487b503          	ld	a0,328(a5)
ffffffffc02085a0:	fc06                	sd	ra,56(sp)
ffffffffc02085a2:	f426                	sd	s1,40(sp)
ffffffffc02085a4:	cc9fc0ef          	jal	ffffffffc020526c <lock_files>
ffffffffc02085a8:	00093783          	ld	a5,0(s2)
ffffffffc02085ac:	1487b503          	ld	a0,328(a5)
ffffffffc02085b0:	611c                	ld	a5,0(a0)
ffffffffc02085b2:	06f40a63          	beq	s0,a5,ffffffffc0208626 <vfs_set_curdir+0x9e>
ffffffffc02085b6:	c02d                	beqz	s0,ffffffffc0208618 <vfs_set_curdir+0x90>
ffffffffc02085b8:	7838                	ld	a4,112(s0)
ffffffffc02085ba:	cb25                	beqz	a4,ffffffffc020862a <vfs_set_curdir+0xa2>
ffffffffc02085bc:	6b38                	ld	a4,80(a4)
ffffffffc02085be:	c735                	beqz	a4,ffffffffc020862a <vfs_set_curdir+0xa2>
ffffffffc02085c0:	00006597          	auipc	a1,0x6
ffffffffc02085c4:	d6858593          	addi	a1,a1,-664 # ffffffffc020e328 <etext+0x2ac8>
ffffffffc02085c8:	8522                	mv	a0,s0
ffffffffc02085ca:	e43e                	sd	a5,8(sp)
ffffffffc02085cc:	cdcff0ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc02085d0:	7838                	ld	a4,112(s0)
ffffffffc02085d2:	086c                	addi	a1,sp,28
ffffffffc02085d4:	8522                	mv	a0,s0
ffffffffc02085d6:	6b38                	ld	a4,80(a4)
ffffffffc02085d8:	9702                	jalr	a4
ffffffffc02085da:	84aa                	mv	s1,a0
ffffffffc02085dc:	e909                	bnez	a0,ffffffffc02085ee <vfs_set_curdir+0x66>
ffffffffc02085de:	4772                	lw	a4,28(sp)
ffffffffc02085e0:	4609                	li	a2,2
ffffffffc02085e2:	54b9                	li	s1,-18
ffffffffc02085e4:	40c75693          	srai	a3,a4,0xc
ffffffffc02085e8:	8a9d                	andi	a3,a3,7
ffffffffc02085ea:	00c68f63          	beq	a3,a2,ffffffffc0208608 <vfs_set_curdir+0x80>
ffffffffc02085ee:	00093783          	ld	a5,0(s2)
ffffffffc02085f2:	1487b503          	ld	a0,328(a5)
ffffffffc02085f6:	c7dfc0ef          	jal	ffffffffc0205272 <unlock_files>
ffffffffc02085fa:	70e2                	ld	ra,56(sp)
ffffffffc02085fc:	7442                	ld	s0,48(sp)
ffffffffc02085fe:	7902                	ld	s2,32(sp)
ffffffffc0208600:	8526                	mv	a0,s1
ffffffffc0208602:	74a2                	ld	s1,40(sp)
ffffffffc0208604:	6121                	addi	sp,sp,64
ffffffffc0208606:	8082                	ret
ffffffffc0208608:	8522                	mv	a0,s0
ffffffffc020860a:	c8aff0ef          	jal	ffffffffc0207a94 <inode_ref_inc>
ffffffffc020860e:	00093703          	ld	a4,0(s2)
ffffffffc0208612:	67a2                	ld	a5,8(sp)
ffffffffc0208614:	14873503          	ld	a0,328(a4)
ffffffffc0208618:	e100                	sd	s0,0(a0)
ffffffffc020861a:	4481                	li	s1,0
ffffffffc020861c:	dfe9                	beqz	a5,ffffffffc02085f6 <vfs_set_curdir+0x6e>
ffffffffc020861e:	853e                	mv	a0,a5
ffffffffc0208620:	d42ff0ef          	jal	ffffffffc0207b62 <inode_ref_dec>
ffffffffc0208624:	b7e9                	j	ffffffffc02085ee <vfs_set_curdir+0x66>
ffffffffc0208626:	4481                	li	s1,0
ffffffffc0208628:	b7f9                	j	ffffffffc02085f6 <vfs_set_curdir+0x6e>
ffffffffc020862a:	00006697          	auipc	a3,0x6
ffffffffc020862e:	c9668693          	addi	a3,a3,-874 # ffffffffc020e2c0 <etext+0x2a60>
ffffffffc0208632:	00003617          	auipc	a2,0x3
ffffffffc0208636:	66660613          	addi	a2,a2,1638 # ffffffffc020bc98 <etext+0x438>
ffffffffc020863a:	04300593          	li	a1,67
ffffffffc020863e:	00006517          	auipc	a0,0x6
ffffffffc0208642:	cd250513          	addi	a0,a0,-814 # ffffffffc020e310 <etext+0x2ab0>
ffffffffc0208646:	e05f70ef          	jal	ffffffffc020044a <__panic>

ffffffffc020864a <vfs_chdir>:
ffffffffc020864a:	7179                	addi	sp,sp,-48
ffffffffc020864c:	082c                	addi	a1,sp,24
ffffffffc020864e:	f406                	sd	ra,40(sp)
ffffffffc0208650:	e53ff0ef          	jal	ffffffffc02084a2 <vfs_lookup>
ffffffffc0208654:	87aa                	mv	a5,a0
ffffffffc0208656:	c509                	beqz	a0,ffffffffc0208660 <vfs_chdir+0x16>
ffffffffc0208658:	70a2                	ld	ra,40(sp)
ffffffffc020865a:	853e                	mv	a0,a5
ffffffffc020865c:	6145                	addi	sp,sp,48
ffffffffc020865e:	8082                	ret
ffffffffc0208660:	6562                	ld	a0,24(sp)
ffffffffc0208662:	f27ff0ef          	jal	ffffffffc0208588 <vfs_set_curdir>
ffffffffc0208666:	87aa                	mv	a5,a0
ffffffffc0208668:	6562                	ld	a0,24(sp)
ffffffffc020866a:	e43e                	sd	a5,8(sp)
ffffffffc020866c:	cf6ff0ef          	jal	ffffffffc0207b62 <inode_ref_dec>
ffffffffc0208670:	67a2                	ld	a5,8(sp)
ffffffffc0208672:	70a2                	ld	ra,40(sp)
ffffffffc0208674:	853e                	mv	a0,a5
ffffffffc0208676:	6145                	addi	sp,sp,48
ffffffffc0208678:	8082                	ret

ffffffffc020867a <vfs_getcwd>:
ffffffffc020867a:	0008e797          	auipc	a5,0x8e
ffffffffc020867e:	24e7b783          	ld	a5,590(a5) # ffffffffc02968c8 <current>
ffffffffc0208682:	7179                	addi	sp,sp,-48
ffffffffc0208684:	ec26                	sd	s1,24(sp)
ffffffffc0208686:	1487b783          	ld	a5,328(a5)
ffffffffc020868a:	f406                	sd	ra,40(sp)
ffffffffc020868c:	f022                	sd	s0,32(sp)
ffffffffc020868e:	6384                	ld	s1,0(a5)
ffffffffc0208690:	c0c1                	beqz	s1,ffffffffc0208710 <vfs_getcwd+0x96>
ffffffffc0208692:	e84a                	sd	s2,16(sp)
ffffffffc0208694:	892a                	mv	s2,a0
ffffffffc0208696:	8526                	mv	a0,s1
ffffffffc0208698:	bfcff0ef          	jal	ffffffffc0207a94 <inode_ref_inc>
ffffffffc020869c:	74a8                	ld	a0,104(s1)
ffffffffc020869e:	c93d                	beqz	a0,ffffffffc0208714 <vfs_getcwd+0x9a>
ffffffffc02086a0:	9a5ff0ef          	jal	ffffffffc0208044 <vfs_get_devname>
ffffffffc02086a4:	842a                	mv	s0,a0
ffffffffc02086a6:	09e030ef          	jal	ffffffffc020b744 <strlen>
ffffffffc02086aa:	862a                	mv	a2,a0
ffffffffc02086ac:	85a2                	mv	a1,s0
ffffffffc02086ae:	854a                	mv	a0,s2
ffffffffc02086b0:	4701                	li	a4,0
ffffffffc02086b2:	4685                	li	a3,1
ffffffffc02086b4:	de3fc0ef          	jal	ffffffffc0205496 <iobuf_move>
ffffffffc02086b8:	842a                	mv	s0,a0
ffffffffc02086ba:	c919                	beqz	a0,ffffffffc02086d0 <vfs_getcwd+0x56>
ffffffffc02086bc:	8526                	mv	a0,s1
ffffffffc02086be:	ca4ff0ef          	jal	ffffffffc0207b62 <inode_ref_dec>
ffffffffc02086c2:	6942                	ld	s2,16(sp)
ffffffffc02086c4:	70a2                	ld	ra,40(sp)
ffffffffc02086c6:	8522                	mv	a0,s0
ffffffffc02086c8:	7402                	ld	s0,32(sp)
ffffffffc02086ca:	64e2                	ld	s1,24(sp)
ffffffffc02086cc:	6145                	addi	sp,sp,48
ffffffffc02086ce:	8082                	ret
ffffffffc02086d0:	4685                	li	a3,1
ffffffffc02086d2:	03a00793          	li	a5,58
ffffffffc02086d6:	8636                	mv	a2,a3
ffffffffc02086d8:	4701                	li	a4,0
ffffffffc02086da:	00f10593          	addi	a1,sp,15
ffffffffc02086de:	854a                	mv	a0,s2
ffffffffc02086e0:	00f107a3          	sb	a5,15(sp)
ffffffffc02086e4:	db3fc0ef          	jal	ffffffffc0205496 <iobuf_move>
ffffffffc02086e8:	842a                	mv	s0,a0
ffffffffc02086ea:	f969                	bnez	a0,ffffffffc02086bc <vfs_getcwd+0x42>
ffffffffc02086ec:	78bc                	ld	a5,112(s1)
ffffffffc02086ee:	c3b9                	beqz	a5,ffffffffc0208734 <vfs_getcwd+0xba>
ffffffffc02086f0:	7f9c                	ld	a5,56(a5)
ffffffffc02086f2:	c3a9                	beqz	a5,ffffffffc0208734 <vfs_getcwd+0xba>
ffffffffc02086f4:	00006597          	auipc	a1,0x6
ffffffffc02086f8:	c9458593          	addi	a1,a1,-876 # ffffffffc020e388 <etext+0x2b28>
ffffffffc02086fc:	8526                	mv	a0,s1
ffffffffc02086fe:	baaff0ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc0208702:	78bc                	ld	a5,112(s1)
ffffffffc0208704:	85ca                	mv	a1,s2
ffffffffc0208706:	8526                	mv	a0,s1
ffffffffc0208708:	7f9c                	ld	a5,56(a5)
ffffffffc020870a:	9782                	jalr	a5
ffffffffc020870c:	842a                	mv	s0,a0
ffffffffc020870e:	b77d                	j	ffffffffc02086bc <vfs_getcwd+0x42>
ffffffffc0208710:	5441                	li	s0,-16
ffffffffc0208712:	bf4d                	j	ffffffffc02086c4 <vfs_getcwd+0x4a>
ffffffffc0208714:	00006697          	auipc	a3,0x6
ffffffffc0208718:	b3c68693          	addi	a3,a3,-1220 # ffffffffc020e250 <etext+0x29f0>
ffffffffc020871c:	00003617          	auipc	a2,0x3
ffffffffc0208720:	57c60613          	addi	a2,a2,1404 # ffffffffc020bc98 <etext+0x438>
ffffffffc0208724:	06e00593          	li	a1,110
ffffffffc0208728:	00006517          	auipc	a0,0x6
ffffffffc020872c:	be850513          	addi	a0,a0,-1048 # ffffffffc020e310 <etext+0x2ab0>
ffffffffc0208730:	d1bf70ef          	jal	ffffffffc020044a <__panic>
ffffffffc0208734:	00006697          	auipc	a3,0x6
ffffffffc0208738:	bfc68693          	addi	a3,a3,-1028 # ffffffffc020e330 <etext+0x2ad0>
ffffffffc020873c:	00003617          	auipc	a2,0x3
ffffffffc0208740:	55c60613          	addi	a2,a2,1372 # ffffffffc020bc98 <etext+0x438>
ffffffffc0208744:	07800593          	li	a1,120
ffffffffc0208748:	00006517          	auipc	a0,0x6
ffffffffc020874c:	bc850513          	addi	a0,a0,-1080 # ffffffffc020e310 <etext+0x2ab0>
ffffffffc0208750:	cfbf70ef          	jal	ffffffffc020044a <__panic>

ffffffffc0208754 <dev_lookup>:
ffffffffc0208754:	0005c703          	lbu	a4,0(a1)
ffffffffc0208758:	ef11                	bnez	a4,ffffffffc0208774 <dev_lookup+0x20>
ffffffffc020875a:	1101                	addi	sp,sp,-32
ffffffffc020875c:	ec06                	sd	ra,24(sp)
ffffffffc020875e:	e032                	sd	a2,0(sp)
ffffffffc0208760:	e42a                	sd	a0,8(sp)
ffffffffc0208762:	b32ff0ef          	jal	ffffffffc0207a94 <inode_ref_inc>
ffffffffc0208766:	6602                	ld	a2,0(sp)
ffffffffc0208768:	67a2                	ld	a5,8(sp)
ffffffffc020876a:	60e2                	ld	ra,24(sp)
ffffffffc020876c:	4501                	li	a0,0
ffffffffc020876e:	e21c                	sd	a5,0(a2)
ffffffffc0208770:	6105                	addi	sp,sp,32
ffffffffc0208772:	8082                	ret
ffffffffc0208774:	5541                	li	a0,-16
ffffffffc0208776:	8082                	ret

ffffffffc0208778 <dev_fstat>:
ffffffffc0208778:	1101                	addi	sp,sp,-32
ffffffffc020877a:	e822                	sd	s0,16(sp)
ffffffffc020877c:	e426                	sd	s1,8(sp)
ffffffffc020877e:	842a                	mv	s0,a0
ffffffffc0208780:	84ae                	mv	s1,a1
ffffffffc0208782:	852e                	mv	a0,a1
ffffffffc0208784:	02000613          	li	a2,32
ffffffffc0208788:	4581                	li	a1,0
ffffffffc020878a:	ec06                	sd	ra,24(sp)
ffffffffc020878c:	06c030ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc0208790:	c429                	beqz	s0,ffffffffc02087da <dev_fstat+0x62>
ffffffffc0208792:	783c                	ld	a5,112(s0)
ffffffffc0208794:	c3b9                	beqz	a5,ffffffffc02087da <dev_fstat+0x62>
ffffffffc0208796:	6bbc                	ld	a5,80(a5)
ffffffffc0208798:	c3a9                	beqz	a5,ffffffffc02087da <dev_fstat+0x62>
ffffffffc020879a:	00006597          	auipc	a1,0x6
ffffffffc020879e:	b8e58593          	addi	a1,a1,-1138 # ffffffffc020e328 <etext+0x2ac8>
ffffffffc02087a2:	8522                	mv	a0,s0
ffffffffc02087a4:	b04ff0ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc02087a8:	783c                	ld	a5,112(s0)
ffffffffc02087aa:	85a6                	mv	a1,s1
ffffffffc02087ac:	8522                	mv	a0,s0
ffffffffc02087ae:	6bbc                	ld	a5,80(a5)
ffffffffc02087b0:	9782                	jalr	a5
ffffffffc02087b2:	ed19                	bnez	a0,ffffffffc02087d0 <dev_fstat+0x58>
ffffffffc02087b4:	4c38                	lw	a4,88(s0)
ffffffffc02087b6:	6785                	lui	a5,0x1
ffffffffc02087b8:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc02087bc:	02f71f63          	bne	a4,a5,ffffffffc02087fa <dev_fstat+0x82>
ffffffffc02087c0:	6018                	ld	a4,0(s0)
ffffffffc02087c2:	641c                	ld	a5,8(s0)
ffffffffc02087c4:	4685                	li	a3,1
ffffffffc02087c6:	e898                	sd	a4,16(s1)
ffffffffc02087c8:	02e787b3          	mul	a5,a5,a4
ffffffffc02087cc:	e494                	sd	a3,8(s1)
ffffffffc02087ce:	ec9c                	sd	a5,24(s1)
ffffffffc02087d0:	60e2                	ld	ra,24(sp)
ffffffffc02087d2:	6442                	ld	s0,16(sp)
ffffffffc02087d4:	64a2                	ld	s1,8(sp)
ffffffffc02087d6:	6105                	addi	sp,sp,32
ffffffffc02087d8:	8082                	ret
ffffffffc02087da:	00006697          	auipc	a3,0x6
ffffffffc02087de:	ae668693          	addi	a3,a3,-1306 # ffffffffc020e2c0 <etext+0x2a60>
ffffffffc02087e2:	00003617          	auipc	a2,0x3
ffffffffc02087e6:	4b660613          	addi	a2,a2,1206 # ffffffffc020bc98 <etext+0x438>
ffffffffc02087ea:	04200593          	li	a1,66
ffffffffc02087ee:	00006517          	auipc	a0,0x6
ffffffffc02087f2:	baa50513          	addi	a0,a0,-1110 # ffffffffc020e398 <etext+0x2b38>
ffffffffc02087f6:	c55f70ef          	jal	ffffffffc020044a <__panic>
ffffffffc02087fa:	00006697          	auipc	a3,0x6
ffffffffc02087fe:	88e68693          	addi	a3,a3,-1906 # ffffffffc020e088 <etext+0x2828>
ffffffffc0208802:	00003617          	auipc	a2,0x3
ffffffffc0208806:	49660613          	addi	a2,a2,1174 # ffffffffc020bc98 <etext+0x438>
ffffffffc020880a:	04500593          	li	a1,69
ffffffffc020880e:	00006517          	auipc	a0,0x6
ffffffffc0208812:	b8a50513          	addi	a0,a0,-1142 # ffffffffc020e398 <etext+0x2b38>
ffffffffc0208816:	c35f70ef          	jal	ffffffffc020044a <__panic>

ffffffffc020881a <dev_ioctl>:
ffffffffc020881a:	c909                	beqz	a0,ffffffffc020882c <dev_ioctl+0x12>
ffffffffc020881c:	4d34                	lw	a3,88(a0)
ffffffffc020881e:	6705                	lui	a4,0x1
ffffffffc0208820:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208824:	00e69463          	bne	a3,a4,ffffffffc020882c <dev_ioctl+0x12>
ffffffffc0208828:	751c                	ld	a5,40(a0)
ffffffffc020882a:	8782                	jr	a5
ffffffffc020882c:	1141                	addi	sp,sp,-16
ffffffffc020882e:	00006697          	auipc	a3,0x6
ffffffffc0208832:	85a68693          	addi	a3,a3,-1958 # ffffffffc020e088 <etext+0x2828>
ffffffffc0208836:	00003617          	auipc	a2,0x3
ffffffffc020883a:	46260613          	addi	a2,a2,1122 # ffffffffc020bc98 <etext+0x438>
ffffffffc020883e:	03500593          	li	a1,53
ffffffffc0208842:	00006517          	auipc	a0,0x6
ffffffffc0208846:	b5650513          	addi	a0,a0,-1194 # ffffffffc020e398 <etext+0x2b38>
ffffffffc020884a:	e406                	sd	ra,8(sp)
ffffffffc020884c:	bfff70ef          	jal	ffffffffc020044a <__panic>

ffffffffc0208850 <dev_tryseek>:
ffffffffc0208850:	c51d                	beqz	a0,ffffffffc020887e <dev_tryseek+0x2e>
ffffffffc0208852:	4d38                	lw	a4,88(a0)
ffffffffc0208854:	6785                	lui	a5,0x1
ffffffffc0208856:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc020885a:	02f71263          	bne	a4,a5,ffffffffc020887e <dev_tryseek+0x2e>
ffffffffc020885e:	611c                	ld	a5,0(a0)
ffffffffc0208860:	cf89                	beqz	a5,ffffffffc020887a <dev_tryseek+0x2a>
ffffffffc0208862:	6518                	ld	a4,8(a0)
ffffffffc0208864:	02e5f6b3          	remu	a3,a1,a4
ffffffffc0208868:	ea89                	bnez	a3,ffffffffc020887a <dev_tryseek+0x2a>
ffffffffc020886a:	0005c863          	bltz	a1,ffffffffc020887a <dev_tryseek+0x2a>
ffffffffc020886e:	02e787b3          	mul	a5,a5,a4
ffffffffc0208872:	4501                	li	a0,0
ffffffffc0208874:	00f5f363          	bgeu	a1,a5,ffffffffc020887a <dev_tryseek+0x2a>
ffffffffc0208878:	8082                	ret
ffffffffc020887a:	5575                	li	a0,-3
ffffffffc020887c:	8082                	ret
ffffffffc020887e:	1141                	addi	sp,sp,-16
ffffffffc0208880:	00006697          	auipc	a3,0x6
ffffffffc0208884:	80868693          	addi	a3,a3,-2040 # ffffffffc020e088 <etext+0x2828>
ffffffffc0208888:	00003617          	auipc	a2,0x3
ffffffffc020888c:	41060613          	addi	a2,a2,1040 # ffffffffc020bc98 <etext+0x438>
ffffffffc0208890:	05f00593          	li	a1,95
ffffffffc0208894:	00006517          	auipc	a0,0x6
ffffffffc0208898:	b0450513          	addi	a0,a0,-1276 # ffffffffc020e398 <etext+0x2b38>
ffffffffc020889c:	e406                	sd	ra,8(sp)
ffffffffc020889e:	badf70ef          	jal	ffffffffc020044a <__panic>

ffffffffc02088a2 <dev_gettype>:
ffffffffc02088a2:	cd11                	beqz	a0,ffffffffc02088be <dev_gettype+0x1c>
ffffffffc02088a4:	4d38                	lw	a4,88(a0)
ffffffffc02088a6:	6785                	lui	a5,0x1
ffffffffc02088a8:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc02088ac:	00f71963          	bne	a4,a5,ffffffffc02088be <dev_gettype+0x1c>
ffffffffc02088b0:	6118                	ld	a4,0(a0)
ffffffffc02088b2:	6791                	lui	a5,0x4
ffffffffc02088b4:	c311                	beqz	a4,ffffffffc02088b8 <dev_gettype+0x16>
ffffffffc02088b6:	6795                	lui	a5,0x5
ffffffffc02088b8:	c19c                	sw	a5,0(a1)
ffffffffc02088ba:	4501                	li	a0,0
ffffffffc02088bc:	8082                	ret
ffffffffc02088be:	1141                	addi	sp,sp,-16
ffffffffc02088c0:	00005697          	auipc	a3,0x5
ffffffffc02088c4:	7c868693          	addi	a3,a3,1992 # ffffffffc020e088 <etext+0x2828>
ffffffffc02088c8:	00003617          	auipc	a2,0x3
ffffffffc02088cc:	3d060613          	addi	a2,a2,976 # ffffffffc020bc98 <etext+0x438>
ffffffffc02088d0:	05300593          	li	a1,83
ffffffffc02088d4:	00006517          	auipc	a0,0x6
ffffffffc02088d8:	ac450513          	addi	a0,a0,-1340 # ffffffffc020e398 <etext+0x2b38>
ffffffffc02088dc:	e406                	sd	ra,8(sp)
ffffffffc02088de:	b6df70ef          	jal	ffffffffc020044a <__panic>

ffffffffc02088e2 <dev_write>:
ffffffffc02088e2:	c911                	beqz	a0,ffffffffc02088f6 <dev_write+0x14>
ffffffffc02088e4:	4d34                	lw	a3,88(a0)
ffffffffc02088e6:	6705                	lui	a4,0x1
ffffffffc02088e8:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc02088ec:	00e69563          	bne	a3,a4,ffffffffc02088f6 <dev_write+0x14>
ffffffffc02088f0:	711c                	ld	a5,32(a0)
ffffffffc02088f2:	4605                	li	a2,1
ffffffffc02088f4:	8782                	jr	a5
ffffffffc02088f6:	1141                	addi	sp,sp,-16
ffffffffc02088f8:	00005697          	auipc	a3,0x5
ffffffffc02088fc:	79068693          	addi	a3,a3,1936 # ffffffffc020e088 <etext+0x2828>
ffffffffc0208900:	00003617          	auipc	a2,0x3
ffffffffc0208904:	39860613          	addi	a2,a2,920 # ffffffffc020bc98 <etext+0x438>
ffffffffc0208908:	02c00593          	li	a1,44
ffffffffc020890c:	00006517          	auipc	a0,0x6
ffffffffc0208910:	a8c50513          	addi	a0,a0,-1396 # ffffffffc020e398 <etext+0x2b38>
ffffffffc0208914:	e406                	sd	ra,8(sp)
ffffffffc0208916:	b35f70ef          	jal	ffffffffc020044a <__panic>

ffffffffc020891a <dev_read>:
ffffffffc020891a:	c911                	beqz	a0,ffffffffc020892e <dev_read+0x14>
ffffffffc020891c:	4d34                	lw	a3,88(a0)
ffffffffc020891e:	6705                	lui	a4,0x1
ffffffffc0208920:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208924:	00e69563          	bne	a3,a4,ffffffffc020892e <dev_read+0x14>
ffffffffc0208928:	711c                	ld	a5,32(a0)
ffffffffc020892a:	4601                	li	a2,0
ffffffffc020892c:	8782                	jr	a5
ffffffffc020892e:	1141                	addi	sp,sp,-16
ffffffffc0208930:	00005697          	auipc	a3,0x5
ffffffffc0208934:	75868693          	addi	a3,a3,1880 # ffffffffc020e088 <etext+0x2828>
ffffffffc0208938:	00003617          	auipc	a2,0x3
ffffffffc020893c:	36060613          	addi	a2,a2,864 # ffffffffc020bc98 <etext+0x438>
ffffffffc0208940:	02300593          	li	a1,35
ffffffffc0208944:	00006517          	auipc	a0,0x6
ffffffffc0208948:	a5450513          	addi	a0,a0,-1452 # ffffffffc020e398 <etext+0x2b38>
ffffffffc020894c:	e406                	sd	ra,8(sp)
ffffffffc020894e:	afdf70ef          	jal	ffffffffc020044a <__panic>

ffffffffc0208952 <dev_close>:
ffffffffc0208952:	c909                	beqz	a0,ffffffffc0208964 <dev_close+0x12>
ffffffffc0208954:	4d34                	lw	a3,88(a0)
ffffffffc0208956:	6705                	lui	a4,0x1
ffffffffc0208958:	23470713          	addi	a4,a4,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc020895c:	00e69463          	bne	a3,a4,ffffffffc0208964 <dev_close+0x12>
ffffffffc0208960:	6d1c                	ld	a5,24(a0)
ffffffffc0208962:	8782                	jr	a5
ffffffffc0208964:	1141                	addi	sp,sp,-16
ffffffffc0208966:	00005697          	auipc	a3,0x5
ffffffffc020896a:	72268693          	addi	a3,a3,1826 # ffffffffc020e088 <etext+0x2828>
ffffffffc020896e:	00003617          	auipc	a2,0x3
ffffffffc0208972:	32a60613          	addi	a2,a2,810 # ffffffffc020bc98 <etext+0x438>
ffffffffc0208976:	45e9                	li	a1,26
ffffffffc0208978:	00006517          	auipc	a0,0x6
ffffffffc020897c:	a2050513          	addi	a0,a0,-1504 # ffffffffc020e398 <etext+0x2b38>
ffffffffc0208980:	e406                	sd	ra,8(sp)
ffffffffc0208982:	ac9f70ef          	jal	ffffffffc020044a <__panic>

ffffffffc0208986 <dev_open>:
ffffffffc0208986:	03c5f793          	andi	a5,a1,60
ffffffffc020898a:	eb91                	bnez	a5,ffffffffc020899e <dev_open+0x18>
ffffffffc020898c:	c919                	beqz	a0,ffffffffc02089a2 <dev_open+0x1c>
ffffffffc020898e:	4d34                	lw	a3,88(a0)
ffffffffc0208990:	6785                	lui	a5,0x1
ffffffffc0208992:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208996:	00f69663          	bne	a3,a5,ffffffffc02089a2 <dev_open+0x1c>
ffffffffc020899a:	691c                	ld	a5,16(a0)
ffffffffc020899c:	8782                	jr	a5
ffffffffc020899e:	5575                	li	a0,-3
ffffffffc02089a0:	8082                	ret
ffffffffc02089a2:	1141                	addi	sp,sp,-16
ffffffffc02089a4:	00005697          	auipc	a3,0x5
ffffffffc02089a8:	6e468693          	addi	a3,a3,1764 # ffffffffc020e088 <etext+0x2828>
ffffffffc02089ac:	00003617          	auipc	a2,0x3
ffffffffc02089b0:	2ec60613          	addi	a2,a2,748 # ffffffffc020bc98 <etext+0x438>
ffffffffc02089b4:	45c5                	li	a1,17
ffffffffc02089b6:	00006517          	auipc	a0,0x6
ffffffffc02089ba:	9e250513          	addi	a0,a0,-1566 # ffffffffc020e398 <etext+0x2b38>
ffffffffc02089be:	e406                	sd	ra,8(sp)
ffffffffc02089c0:	a8bf70ef          	jal	ffffffffc020044a <__panic>

ffffffffc02089c4 <dev_init>:
ffffffffc02089c4:	1141                	addi	sp,sp,-16
ffffffffc02089c6:	e406                	sd	ra,8(sp)
ffffffffc02089c8:	544000ef          	jal	ffffffffc0208f0c <dev_init_stdin>
ffffffffc02089cc:	65c000ef          	jal	ffffffffc0209028 <dev_init_stdout>
ffffffffc02089d0:	60a2                	ld	ra,8(sp)
ffffffffc02089d2:	0141                	addi	sp,sp,16
ffffffffc02089d4:	ac01                	j	ffffffffc0208be4 <dev_init_disk0>

ffffffffc02089d6 <dev_create_inode>:
ffffffffc02089d6:	6505                	lui	a0,0x1
ffffffffc02089d8:	1101                	addi	sp,sp,-32
ffffffffc02089da:	23450513          	addi	a0,a0,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc02089de:	ec06                	sd	ra,24(sp)
ffffffffc02089e0:	836ff0ef          	jal	ffffffffc0207a16 <__alloc_inode>
ffffffffc02089e4:	87aa                	mv	a5,a0
ffffffffc02089e6:	c911                	beqz	a0,ffffffffc02089fa <dev_create_inode+0x24>
ffffffffc02089e8:	4601                	li	a2,0
ffffffffc02089ea:	00007597          	auipc	a1,0x7
ffffffffc02089ee:	dce58593          	addi	a1,a1,-562 # ffffffffc020f7b8 <dev_node_ops>
ffffffffc02089f2:	e42a                	sd	a0,8(sp)
ffffffffc02089f4:	83eff0ef          	jal	ffffffffc0207a32 <inode_init>
ffffffffc02089f8:	67a2                	ld	a5,8(sp)
ffffffffc02089fa:	60e2                	ld	ra,24(sp)
ffffffffc02089fc:	853e                	mv	a0,a5
ffffffffc02089fe:	6105                	addi	sp,sp,32
ffffffffc0208a00:	8082                	ret

ffffffffc0208a02 <disk0_open>:
ffffffffc0208a02:	4501                	li	a0,0
ffffffffc0208a04:	8082                	ret

ffffffffc0208a06 <disk0_close>:
ffffffffc0208a06:	4501                	li	a0,0
ffffffffc0208a08:	8082                	ret

ffffffffc0208a0a <disk0_ioctl>:
ffffffffc0208a0a:	5531                	li	a0,-20
ffffffffc0208a0c:	8082                	ret

ffffffffc0208a0e <disk0_io>:
ffffffffc0208a0e:	711d                	addi	sp,sp,-96
ffffffffc0208a10:	6594                	ld	a3,8(a1)
ffffffffc0208a12:	e8a2                	sd	s0,80(sp)
ffffffffc0208a14:	6d80                	ld	s0,24(a1)
ffffffffc0208a16:	6785                	lui	a5,0x1
ffffffffc0208a18:	17fd                	addi	a5,a5,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc0208a1a:	0086e733          	or	a4,a3,s0
ffffffffc0208a1e:	ec86                	sd	ra,88(sp)
ffffffffc0208a20:	8f7d                	and	a4,a4,a5
ffffffffc0208a22:	14071663          	bnez	a4,ffffffffc0208b6e <disk0_io+0x160>
ffffffffc0208a26:	e0ca                	sd	s2,64(sp)
ffffffffc0208a28:	43f6d913          	srai	s2,a3,0x3f
ffffffffc0208a2c:	00f97933          	and	s2,s2,a5
ffffffffc0208a30:	9936                	add	s2,s2,a3
ffffffffc0208a32:	40c95913          	srai	s2,s2,0xc
ffffffffc0208a36:	00c45793          	srli	a5,s0,0xc
ffffffffc0208a3a:	0127873b          	addw	a4,a5,s2
ffffffffc0208a3e:	6114                	ld	a3,0(a0)
ffffffffc0208a40:	1702                	slli	a4,a4,0x20
ffffffffc0208a42:	9301                	srli	a4,a4,0x20
ffffffffc0208a44:	2901                	sext.w	s2,s2
ffffffffc0208a46:	2781                	sext.w	a5,a5
ffffffffc0208a48:	12e6e063          	bltu	a3,a4,ffffffffc0208b68 <disk0_io+0x15a>
ffffffffc0208a4c:	e799                	bnez	a5,ffffffffc0208a5a <disk0_io+0x4c>
ffffffffc0208a4e:	6906                	ld	s2,64(sp)
ffffffffc0208a50:	4501                	li	a0,0
ffffffffc0208a52:	60e6                	ld	ra,88(sp)
ffffffffc0208a54:	6446                	ld	s0,80(sp)
ffffffffc0208a56:	6125                	addi	sp,sp,96
ffffffffc0208a58:	8082                	ret
ffffffffc0208a5a:	0008d517          	auipc	a0,0x8d
ffffffffc0208a5e:	de650513          	addi	a0,a0,-538 # ffffffffc0295840 <disk0_sem>
ffffffffc0208a62:	e4a6                	sd	s1,72(sp)
ffffffffc0208a64:	f852                	sd	s4,48(sp)
ffffffffc0208a66:	f456                	sd	s5,40(sp)
ffffffffc0208a68:	84b2                	mv	s1,a2
ffffffffc0208a6a:	8aae                	mv	s5,a1
ffffffffc0208a6c:	0008ea17          	auipc	s4,0x8e
ffffffffc0208a70:	e8ca0a13          	addi	s4,s4,-372 # ffffffffc02968f8 <disk0_buffer>
ffffffffc0208a74:	b83fb0ef          	jal	ffffffffc02045f6 <down>
ffffffffc0208a78:	000a3603          	ld	a2,0(s4)
ffffffffc0208a7c:	e8ad                	bnez	s1,ffffffffc0208aee <disk0_io+0xe0>
ffffffffc0208a7e:	e862                	sd	s8,16(sp)
ffffffffc0208a80:	fc4e                	sd	s3,56(sp)
ffffffffc0208a82:	ec5e                	sd	s7,24(sp)
ffffffffc0208a84:	6c11                	lui	s8,0x4
ffffffffc0208a86:	a029                	j	ffffffffc0208a90 <disk0_io+0x82>
ffffffffc0208a88:	000a3603          	ld	a2,0(s4)
ffffffffc0208a8c:	0129893b          	addw	s2,s3,s2
ffffffffc0208a90:	84a2                	mv	s1,s0
ffffffffc0208a92:	008c7363          	bgeu	s8,s0,ffffffffc0208a98 <disk0_io+0x8a>
ffffffffc0208a96:	6491                	lui	s1,0x4
ffffffffc0208a98:	00c4d993          	srli	s3,s1,0xc
ffffffffc0208a9c:	2981                	sext.w	s3,s3
ffffffffc0208a9e:	00399b9b          	slliw	s7,s3,0x3
ffffffffc0208aa2:	020b9693          	slli	a3,s7,0x20
ffffffffc0208aa6:	9281                	srli	a3,a3,0x20
ffffffffc0208aa8:	0039159b          	slliw	a1,s2,0x3
ffffffffc0208aac:	4509                	li	a0,2
ffffffffc0208aae:	ff1f70ef          	jal	ffffffffc0200a9e <ide_read_secs>
ffffffffc0208ab2:	e16d                	bnez	a0,ffffffffc0208b94 <disk0_io+0x186>
ffffffffc0208ab4:	000a3583          	ld	a1,0(s4)
ffffffffc0208ab8:	0038                	addi	a4,sp,8
ffffffffc0208aba:	4685                	li	a3,1
ffffffffc0208abc:	8626                	mv	a2,s1
ffffffffc0208abe:	8556                	mv	a0,s5
ffffffffc0208ac0:	9d7fc0ef          	jal	ffffffffc0205496 <iobuf_move>
ffffffffc0208ac4:	67a2                	ld	a5,8(sp)
ffffffffc0208ac6:	0a979663          	bne	a5,s1,ffffffffc0208b72 <disk0_io+0x164>
ffffffffc0208aca:	03449793          	slli	a5,s1,0x34
ffffffffc0208ace:	e3d5                	bnez	a5,ffffffffc0208b72 <disk0_io+0x164>
ffffffffc0208ad0:	8c05                	sub	s0,s0,s1
ffffffffc0208ad2:	f85d                	bnez	s0,ffffffffc0208a88 <disk0_io+0x7a>
ffffffffc0208ad4:	79e2                	ld	s3,56(sp)
ffffffffc0208ad6:	6be2                	ld	s7,24(sp)
ffffffffc0208ad8:	6c42                	ld	s8,16(sp)
ffffffffc0208ada:	0008d517          	auipc	a0,0x8d
ffffffffc0208ade:	d6650513          	addi	a0,a0,-666 # ffffffffc0295840 <disk0_sem>
ffffffffc0208ae2:	b11fb0ef          	jal	ffffffffc02045f2 <up>
ffffffffc0208ae6:	64a6                	ld	s1,72(sp)
ffffffffc0208ae8:	7a42                	ld	s4,48(sp)
ffffffffc0208aea:	7aa2                	ld	s5,40(sp)
ffffffffc0208aec:	b78d                	j	ffffffffc0208a4e <disk0_io+0x40>
ffffffffc0208aee:	f05a                	sd	s6,32(sp)
ffffffffc0208af0:	a029                	j	ffffffffc0208afa <disk0_io+0xec>
ffffffffc0208af2:	000a3603          	ld	a2,0(s4)
ffffffffc0208af6:	0124893b          	addw	s2,s1,s2
ffffffffc0208afa:	85b2                	mv	a1,a2
ffffffffc0208afc:	0038                	addi	a4,sp,8
ffffffffc0208afe:	4681                	li	a3,0
ffffffffc0208b00:	6611                	lui	a2,0x4
ffffffffc0208b02:	8556                	mv	a0,s5
ffffffffc0208b04:	993fc0ef          	jal	ffffffffc0205496 <iobuf_move>
ffffffffc0208b08:	67a2                	ld	a5,8(sp)
ffffffffc0208b0a:	fff78713          	addi	a4,a5,-1
ffffffffc0208b0e:	02877a63          	bgeu	a4,s0,ffffffffc0208b42 <disk0_io+0x134>
ffffffffc0208b12:	03479713          	slli	a4,a5,0x34
ffffffffc0208b16:	e715                	bnez	a4,ffffffffc0208b42 <disk0_io+0x134>
ffffffffc0208b18:	83b1                	srli	a5,a5,0xc
ffffffffc0208b1a:	0007849b          	sext.w	s1,a5
ffffffffc0208b1e:	00349b1b          	slliw	s6,s1,0x3
ffffffffc0208b22:	000a3603          	ld	a2,0(s4)
ffffffffc0208b26:	020b1693          	slli	a3,s6,0x20
ffffffffc0208b2a:	9281                	srli	a3,a3,0x20
ffffffffc0208b2c:	0039159b          	slliw	a1,s2,0x3
ffffffffc0208b30:	4509                	li	a0,2
ffffffffc0208b32:	806f80ef          	jal	ffffffffc0200b38 <ide_write_secs>
ffffffffc0208b36:	e151                	bnez	a0,ffffffffc0208bba <disk0_io+0x1ac>
ffffffffc0208b38:	67a2                	ld	a5,8(sp)
ffffffffc0208b3a:	8c1d                	sub	s0,s0,a5
ffffffffc0208b3c:	f85d                	bnez	s0,ffffffffc0208af2 <disk0_io+0xe4>
ffffffffc0208b3e:	7b02                	ld	s6,32(sp)
ffffffffc0208b40:	bf69                	j	ffffffffc0208ada <disk0_io+0xcc>
ffffffffc0208b42:	00006697          	auipc	a3,0x6
ffffffffc0208b46:	86e68693          	addi	a3,a3,-1938 # ffffffffc020e3b0 <etext+0x2b50>
ffffffffc0208b4a:	00003617          	auipc	a2,0x3
ffffffffc0208b4e:	14e60613          	addi	a2,a2,334 # ffffffffc020bc98 <etext+0x438>
ffffffffc0208b52:	05700593          	li	a1,87
ffffffffc0208b56:	00006517          	auipc	a0,0x6
ffffffffc0208b5a:	89a50513          	addi	a0,a0,-1894 # ffffffffc020e3f0 <etext+0x2b90>
ffffffffc0208b5e:	fc4e                	sd	s3,56(sp)
ffffffffc0208b60:	ec5e                	sd	s7,24(sp)
ffffffffc0208b62:	e862                	sd	s8,16(sp)
ffffffffc0208b64:	8e7f70ef          	jal	ffffffffc020044a <__panic>
ffffffffc0208b68:	6906                	ld	s2,64(sp)
ffffffffc0208b6a:	5575                	li	a0,-3
ffffffffc0208b6c:	b5dd                	j	ffffffffc0208a52 <disk0_io+0x44>
ffffffffc0208b6e:	5575                	li	a0,-3
ffffffffc0208b70:	b5cd                	j	ffffffffc0208a52 <disk0_io+0x44>
ffffffffc0208b72:	00006697          	auipc	a3,0x6
ffffffffc0208b76:	93668693          	addi	a3,a3,-1738 # ffffffffc020e4a8 <etext+0x2c48>
ffffffffc0208b7a:	00003617          	auipc	a2,0x3
ffffffffc0208b7e:	11e60613          	addi	a2,a2,286 # ffffffffc020bc98 <etext+0x438>
ffffffffc0208b82:	06200593          	li	a1,98
ffffffffc0208b86:	00006517          	auipc	a0,0x6
ffffffffc0208b8a:	86a50513          	addi	a0,a0,-1942 # ffffffffc020e3f0 <etext+0x2b90>
ffffffffc0208b8e:	f05a                	sd	s6,32(sp)
ffffffffc0208b90:	8bbf70ef          	jal	ffffffffc020044a <__panic>
ffffffffc0208b94:	88aa                	mv	a7,a0
ffffffffc0208b96:	885e                	mv	a6,s7
ffffffffc0208b98:	87ce                	mv	a5,s3
ffffffffc0208b9a:	0039171b          	slliw	a4,s2,0x3
ffffffffc0208b9e:	86ca                	mv	a3,s2
ffffffffc0208ba0:	00006617          	auipc	a2,0x6
ffffffffc0208ba4:	8c060613          	addi	a2,a2,-1856 # ffffffffc020e460 <etext+0x2c00>
ffffffffc0208ba8:	02d00593          	li	a1,45
ffffffffc0208bac:	00006517          	auipc	a0,0x6
ffffffffc0208bb0:	84450513          	addi	a0,a0,-1980 # ffffffffc020e3f0 <etext+0x2b90>
ffffffffc0208bb4:	f05a                	sd	s6,32(sp)
ffffffffc0208bb6:	895f70ef          	jal	ffffffffc020044a <__panic>
ffffffffc0208bba:	88aa                	mv	a7,a0
ffffffffc0208bbc:	885a                	mv	a6,s6
ffffffffc0208bbe:	87a6                	mv	a5,s1
ffffffffc0208bc0:	0039171b          	slliw	a4,s2,0x3
ffffffffc0208bc4:	86ca                	mv	a3,s2
ffffffffc0208bc6:	00006617          	auipc	a2,0x6
ffffffffc0208bca:	84a60613          	addi	a2,a2,-1974 # ffffffffc020e410 <etext+0x2bb0>
ffffffffc0208bce:	03700593          	li	a1,55
ffffffffc0208bd2:	00006517          	auipc	a0,0x6
ffffffffc0208bd6:	81e50513          	addi	a0,a0,-2018 # ffffffffc020e3f0 <etext+0x2b90>
ffffffffc0208bda:	fc4e                	sd	s3,56(sp)
ffffffffc0208bdc:	ec5e                	sd	s7,24(sp)
ffffffffc0208bde:	e862                	sd	s8,16(sp)
ffffffffc0208be0:	86bf70ef          	jal	ffffffffc020044a <__panic>

ffffffffc0208be4 <dev_init_disk0>:
ffffffffc0208be4:	1101                	addi	sp,sp,-32
ffffffffc0208be6:	ec06                	sd	ra,24(sp)
ffffffffc0208be8:	e822                	sd	s0,16(sp)
ffffffffc0208bea:	e426                	sd	s1,8(sp)
ffffffffc0208bec:	debff0ef          	jal	ffffffffc02089d6 <dev_create_inode>
ffffffffc0208bf0:	c541                	beqz	a0,ffffffffc0208c78 <dev_init_disk0+0x94>
ffffffffc0208bf2:	4d38                	lw	a4,88(a0)
ffffffffc0208bf4:	6785                	lui	a5,0x1
ffffffffc0208bf6:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208bfa:	842a                	mv	s0,a0
ffffffffc0208bfc:	6485                	lui	s1,0x1
ffffffffc0208bfe:	0cf71e63          	bne	a4,a5,ffffffffc0208cda <dev_init_disk0+0xf6>
ffffffffc0208c02:	4509                	li	a0,2
ffffffffc0208c04:	e4ff70ef          	jal	ffffffffc0200a52 <ide_device_valid>
ffffffffc0208c08:	cd4d                	beqz	a0,ffffffffc0208cc2 <dev_init_disk0+0xde>
ffffffffc0208c0a:	4509                	li	a0,2
ffffffffc0208c0c:	e6bf70ef          	jal	ffffffffc0200a76 <ide_device_size>
ffffffffc0208c10:	00000797          	auipc	a5,0x0
ffffffffc0208c14:	dfa78793          	addi	a5,a5,-518 # ffffffffc0208a0a <disk0_ioctl>
ffffffffc0208c18:	00000617          	auipc	a2,0x0
ffffffffc0208c1c:	dea60613          	addi	a2,a2,-534 # ffffffffc0208a02 <disk0_open>
ffffffffc0208c20:	00000697          	auipc	a3,0x0
ffffffffc0208c24:	de668693          	addi	a3,a3,-538 # ffffffffc0208a06 <disk0_close>
ffffffffc0208c28:	00000717          	auipc	a4,0x0
ffffffffc0208c2c:	de670713          	addi	a4,a4,-538 # ffffffffc0208a0e <disk0_io>
ffffffffc0208c30:	810d                	srli	a0,a0,0x3
ffffffffc0208c32:	f41c                	sd	a5,40(s0)
ffffffffc0208c34:	e008                	sd	a0,0(s0)
ffffffffc0208c36:	e810                	sd	a2,16(s0)
ffffffffc0208c38:	ec14                	sd	a3,24(s0)
ffffffffc0208c3a:	f018                	sd	a4,32(s0)
ffffffffc0208c3c:	4585                	li	a1,1
ffffffffc0208c3e:	0008d517          	auipc	a0,0x8d
ffffffffc0208c42:	c0250513          	addi	a0,a0,-1022 # ffffffffc0295840 <disk0_sem>
ffffffffc0208c46:	e404                	sd	s1,8(s0)
ffffffffc0208c48:	9a5fb0ef          	jal	ffffffffc02045ec <sem_init>
ffffffffc0208c4c:	6511                	lui	a0,0x4
ffffffffc0208c4e:	b72f90ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc0208c52:	0008e797          	auipc	a5,0x8e
ffffffffc0208c56:	caa7b323          	sd	a0,-858(a5) # ffffffffc02968f8 <disk0_buffer>
ffffffffc0208c5a:	c921                	beqz	a0,ffffffffc0208caa <dev_init_disk0+0xc6>
ffffffffc0208c5c:	85a2                	mv	a1,s0
ffffffffc0208c5e:	4605                	li	a2,1
ffffffffc0208c60:	00006517          	auipc	a0,0x6
ffffffffc0208c64:	8d850513          	addi	a0,a0,-1832 # ffffffffc020e538 <etext+0x2cd8>
ffffffffc0208c68:	c26ff0ef          	jal	ffffffffc020808e <vfs_add_dev>
ffffffffc0208c6c:	e115                	bnez	a0,ffffffffc0208c90 <dev_init_disk0+0xac>
ffffffffc0208c6e:	60e2                	ld	ra,24(sp)
ffffffffc0208c70:	6442                	ld	s0,16(sp)
ffffffffc0208c72:	64a2                	ld	s1,8(sp)
ffffffffc0208c74:	6105                	addi	sp,sp,32
ffffffffc0208c76:	8082                	ret
ffffffffc0208c78:	00006617          	auipc	a2,0x6
ffffffffc0208c7c:	86060613          	addi	a2,a2,-1952 # ffffffffc020e4d8 <etext+0x2c78>
ffffffffc0208c80:	08700593          	li	a1,135
ffffffffc0208c84:	00005517          	auipc	a0,0x5
ffffffffc0208c88:	76c50513          	addi	a0,a0,1900 # ffffffffc020e3f0 <etext+0x2b90>
ffffffffc0208c8c:	fbef70ef          	jal	ffffffffc020044a <__panic>
ffffffffc0208c90:	86aa                	mv	a3,a0
ffffffffc0208c92:	00006617          	auipc	a2,0x6
ffffffffc0208c96:	8ae60613          	addi	a2,a2,-1874 # ffffffffc020e540 <etext+0x2ce0>
ffffffffc0208c9a:	08d00593          	li	a1,141
ffffffffc0208c9e:	00005517          	auipc	a0,0x5
ffffffffc0208ca2:	75250513          	addi	a0,a0,1874 # ffffffffc020e3f0 <etext+0x2b90>
ffffffffc0208ca6:	fa4f70ef          	jal	ffffffffc020044a <__panic>
ffffffffc0208caa:	00006617          	auipc	a2,0x6
ffffffffc0208cae:	86e60613          	addi	a2,a2,-1938 # ffffffffc020e518 <etext+0x2cb8>
ffffffffc0208cb2:	07f00593          	li	a1,127
ffffffffc0208cb6:	00005517          	auipc	a0,0x5
ffffffffc0208cba:	73a50513          	addi	a0,a0,1850 # ffffffffc020e3f0 <etext+0x2b90>
ffffffffc0208cbe:	f8cf70ef          	jal	ffffffffc020044a <__panic>
ffffffffc0208cc2:	00006617          	auipc	a2,0x6
ffffffffc0208cc6:	83660613          	addi	a2,a2,-1994 # ffffffffc020e4f8 <etext+0x2c98>
ffffffffc0208cca:	07300593          	li	a1,115
ffffffffc0208cce:	00005517          	auipc	a0,0x5
ffffffffc0208cd2:	72250513          	addi	a0,a0,1826 # ffffffffc020e3f0 <etext+0x2b90>
ffffffffc0208cd6:	f74f70ef          	jal	ffffffffc020044a <__panic>
ffffffffc0208cda:	00005697          	auipc	a3,0x5
ffffffffc0208cde:	3ae68693          	addi	a3,a3,942 # ffffffffc020e088 <etext+0x2828>
ffffffffc0208ce2:	00003617          	auipc	a2,0x3
ffffffffc0208ce6:	fb660613          	addi	a2,a2,-74 # ffffffffc020bc98 <etext+0x438>
ffffffffc0208cea:	08900593          	li	a1,137
ffffffffc0208cee:	00005517          	auipc	a0,0x5
ffffffffc0208cf2:	70250513          	addi	a0,a0,1794 # ffffffffc020e3f0 <etext+0x2b90>
ffffffffc0208cf6:	f54f70ef          	jal	ffffffffc020044a <__panic>

ffffffffc0208cfa <stdin_open>:
ffffffffc0208cfa:	e199                	bnez	a1,ffffffffc0208d00 <stdin_open+0x6>
ffffffffc0208cfc:	4501                	li	a0,0
ffffffffc0208cfe:	8082                	ret
ffffffffc0208d00:	5575                	li	a0,-3
ffffffffc0208d02:	8082                	ret

ffffffffc0208d04 <stdin_close>:
ffffffffc0208d04:	4501                	li	a0,0
ffffffffc0208d06:	8082                	ret

ffffffffc0208d08 <stdin_ioctl>:
ffffffffc0208d08:	5575                	li	a0,-3
ffffffffc0208d0a:	8082                	ret

ffffffffc0208d0c <stdin_io>:
ffffffffc0208d0c:	14061f63          	bnez	a2,ffffffffc0208e6a <stdin_io+0x15e>
ffffffffc0208d10:	7175                	addi	sp,sp,-144
ffffffffc0208d12:	ecd6                	sd	s5,88(sp)
ffffffffc0208d14:	e8da                	sd	s6,80(sp)
ffffffffc0208d16:	e4de                	sd	s7,72(sp)
ffffffffc0208d18:	0185bb03          	ld	s6,24(a1)
ffffffffc0208d1c:	0005bb83          	ld	s7,0(a1)
ffffffffc0208d20:	e506                	sd	ra,136(sp)
ffffffffc0208d22:	e122                	sd	s0,128(sp)
ffffffffc0208d24:	8aae                	mv	s5,a1
ffffffffc0208d26:	100027f3          	csrr	a5,sstatus
ffffffffc0208d2a:	8b89                	andi	a5,a5,2
ffffffffc0208d2c:	12079663          	bnez	a5,ffffffffc0208e58 <stdin_io+0x14c>
ffffffffc0208d30:	4401                	li	s0,0
ffffffffc0208d32:	120b0a63          	beqz	s6,ffffffffc0208e66 <stdin_io+0x15a>
ffffffffc0208d36:	f8ca                	sd	s2,112(sp)
ffffffffc0208d38:	0008e917          	auipc	s2,0x8e
ffffffffc0208d3c:	bd090913          	addi	s2,s2,-1072 # ffffffffc0296908 <p_rpos>
ffffffffc0208d40:	00093783          	ld	a5,0(s2)
ffffffffc0208d44:	fca6                	sd	s1,120(sp)
ffffffffc0208d46:	6705                	lui	a4,0x1
ffffffffc0208d48:	800004b7          	lui	s1,0x80000
ffffffffc0208d4c:	f4ce                	sd	s3,104(sp)
ffffffffc0208d4e:	f0d2                	sd	s4,96(sp)
ffffffffc0208d50:	e0e2                	sd	s8,64(sp)
ffffffffc0208d52:	0491                	addi	s1,s1,4 # ffffffff80000004 <_binary_bin_sfs_img_size+0xffffffff7ff8ad04>
ffffffffc0208d54:	fff70c13          	addi	s8,a4,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc0208d58:	4a01                	li	s4,0
ffffffffc0208d5a:	0008e997          	auipc	s3,0x8e
ffffffffc0208d5e:	ba698993          	addi	s3,s3,-1114 # ffffffffc0296900 <p_wpos>
ffffffffc0208d62:	0009b703          	ld	a4,0(s3)
ffffffffc0208d66:	02e7d763          	bge	a5,a4,ffffffffc0208d94 <stdin_io+0x88>
ffffffffc0208d6a:	a045                	j	ffffffffc0208e0a <stdin_io+0xfe>
ffffffffc0208d6c:	fd2fe0ef          	jal	ffffffffc020753e <schedule>
ffffffffc0208d70:	100027f3          	csrr	a5,sstatus
ffffffffc0208d74:	8b89                	andi	a5,a5,2
ffffffffc0208d76:	4401                	li	s0,0
ffffffffc0208d78:	e3b1                	bnez	a5,ffffffffc0208dbc <stdin_io+0xb0>
ffffffffc0208d7a:	0828                	addi	a0,sp,24
ffffffffc0208d7c:	90bfb0ef          	jal	ffffffffc0204686 <wait_in_queue>
ffffffffc0208d80:	e529                	bnez	a0,ffffffffc0208dca <stdin_io+0xbe>
ffffffffc0208d82:	5782                	lw	a5,32(sp)
ffffffffc0208d84:	04979d63          	bne	a5,s1,ffffffffc0208dde <stdin_io+0xd2>
ffffffffc0208d88:	00093783          	ld	a5,0(s2)
ffffffffc0208d8c:	0009b703          	ld	a4,0(s3)
ffffffffc0208d90:	06e7cd63          	blt	a5,a4,ffffffffc0208e0a <stdin_io+0xfe>
ffffffffc0208d94:	80000637          	lui	a2,0x80000
ffffffffc0208d98:	0611                	addi	a2,a2,4 # ffffffff80000004 <_binary_bin_sfs_img_size+0xffffffff7ff8ad04>
ffffffffc0208d9a:	082c                	addi	a1,sp,24
ffffffffc0208d9c:	0008d517          	auipc	a0,0x8d
ffffffffc0208da0:	abc50513          	addi	a0,a0,-1348 # ffffffffc0295858 <__wait_queue>
ffffffffc0208da4:	a0ffb0ef          	jal	ffffffffc02047b2 <wait_current_set>
ffffffffc0208da8:	d071                	beqz	s0,ffffffffc0208d6c <stdin_io+0x60>
ffffffffc0208daa:	e29f70ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0208dae:	f90fe0ef          	jal	ffffffffc020753e <schedule>
ffffffffc0208db2:	100027f3          	csrr	a5,sstatus
ffffffffc0208db6:	8b89                	andi	a5,a5,2
ffffffffc0208db8:	4401                	li	s0,0
ffffffffc0208dba:	d3e1                	beqz	a5,ffffffffc0208d7a <stdin_io+0x6e>
ffffffffc0208dbc:	e1df70ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0208dc0:	0828                	addi	a0,sp,24
ffffffffc0208dc2:	4405                	li	s0,1
ffffffffc0208dc4:	8c3fb0ef          	jal	ffffffffc0204686 <wait_in_queue>
ffffffffc0208dc8:	dd4d                	beqz	a0,ffffffffc0208d82 <stdin_io+0x76>
ffffffffc0208dca:	082c                	addi	a1,sp,24
ffffffffc0208dcc:	0008d517          	auipc	a0,0x8d
ffffffffc0208dd0:	a8c50513          	addi	a0,a0,-1396 # ffffffffc0295858 <__wait_queue>
ffffffffc0208dd4:	859fb0ef          	jal	ffffffffc020462c <wait_queue_del>
ffffffffc0208dd8:	5782                	lw	a5,32(sp)
ffffffffc0208dda:	fa9787e3          	beq	a5,s1,ffffffffc0208d88 <stdin_io+0x7c>
ffffffffc0208dde:	000a051b          	sext.w	a0,s4
ffffffffc0208de2:	e42d                	bnez	s0,ffffffffc0208e4c <stdin_io+0x140>
ffffffffc0208de4:	c519                	beqz	a0,ffffffffc0208df2 <stdin_io+0xe6>
ffffffffc0208de6:	018ab783          	ld	a5,24(s5)
ffffffffc0208dea:	414787b3          	sub	a5,a5,s4
ffffffffc0208dee:	00fabc23          	sd	a5,24(s5)
ffffffffc0208df2:	74e6                	ld	s1,120(sp)
ffffffffc0208df4:	7946                	ld	s2,112(sp)
ffffffffc0208df6:	79a6                	ld	s3,104(sp)
ffffffffc0208df8:	7a06                	ld	s4,96(sp)
ffffffffc0208dfa:	6c06                	ld	s8,64(sp)
ffffffffc0208dfc:	60aa                	ld	ra,136(sp)
ffffffffc0208dfe:	640a                	ld	s0,128(sp)
ffffffffc0208e00:	6ae6                	ld	s5,88(sp)
ffffffffc0208e02:	6b46                	ld	s6,80(sp)
ffffffffc0208e04:	6ba6                	ld	s7,72(sp)
ffffffffc0208e06:	6149                	addi	sp,sp,144
ffffffffc0208e08:	8082                	ret
ffffffffc0208e0a:	43f7d693          	srai	a3,a5,0x3f
ffffffffc0208e0e:	92d1                	srli	a3,a3,0x34
ffffffffc0208e10:	00d78733          	add	a4,a5,a3
ffffffffc0208e14:	01877733          	and	a4,a4,s8
ffffffffc0208e18:	8f15                	sub	a4,a4,a3
ffffffffc0208e1a:	0008d697          	auipc	a3,0x8d
ffffffffc0208e1e:	a4e68693          	addi	a3,a3,-1458 # ffffffffc0295868 <stdin_buffer>
ffffffffc0208e22:	9736                	add	a4,a4,a3
ffffffffc0208e24:	00074683          	lbu	a3,0(a4)
ffffffffc0208e28:	0785                	addi	a5,a5,1
ffffffffc0208e2a:	014b8733          	add	a4,s7,s4
ffffffffc0208e2e:	001a051b          	addiw	a0,s4,1
ffffffffc0208e32:	00f93023          	sd	a5,0(s2)
ffffffffc0208e36:	00d70023          	sb	a3,0(a4)
ffffffffc0208e3a:	0a05                	addi	s4,s4,1
ffffffffc0208e3c:	f36a63e3          	bltu	s4,s6,ffffffffc0208d62 <stdin_io+0x56>
ffffffffc0208e40:	d05d                	beqz	s0,ffffffffc0208de6 <stdin_io+0xda>
ffffffffc0208e42:	e42a                	sd	a0,8(sp)
ffffffffc0208e44:	d8ff70ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0208e48:	6522                	ld	a0,8(sp)
ffffffffc0208e4a:	bf71                	j	ffffffffc0208de6 <stdin_io+0xda>
ffffffffc0208e4c:	e42a                	sd	a0,8(sp)
ffffffffc0208e4e:	d85f70ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0208e52:	6522                	ld	a0,8(sp)
ffffffffc0208e54:	f949                	bnez	a0,ffffffffc0208de6 <stdin_io+0xda>
ffffffffc0208e56:	bf71                	j	ffffffffc0208df2 <stdin_io+0xe6>
ffffffffc0208e58:	d81f70ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0208e5c:	4405                	li	s0,1
ffffffffc0208e5e:	ec0b1ce3          	bnez	s6,ffffffffc0208d36 <stdin_io+0x2a>
ffffffffc0208e62:	d71f70ef          	jal	ffffffffc0200bd2 <intr_enable>
ffffffffc0208e66:	4501                	li	a0,0
ffffffffc0208e68:	bf51                	j	ffffffffc0208dfc <stdin_io+0xf0>
ffffffffc0208e6a:	5575                	li	a0,-3
ffffffffc0208e6c:	8082                	ret

ffffffffc0208e6e <dev_stdin_write>:
ffffffffc0208e6e:	e111                	bnez	a0,ffffffffc0208e72 <dev_stdin_write+0x4>
ffffffffc0208e70:	8082                	ret
ffffffffc0208e72:	1101                	addi	sp,sp,-32
ffffffffc0208e74:	ec06                	sd	ra,24(sp)
ffffffffc0208e76:	e822                	sd	s0,16(sp)
ffffffffc0208e78:	100027f3          	csrr	a5,sstatus
ffffffffc0208e7c:	8b89                	andi	a5,a5,2
ffffffffc0208e7e:	4401                	li	s0,0
ffffffffc0208e80:	e3c1                	bnez	a5,ffffffffc0208f00 <dev_stdin_write+0x92>
ffffffffc0208e82:	0008e717          	auipc	a4,0x8e
ffffffffc0208e86:	a7e73703          	ld	a4,-1410(a4) # ffffffffc0296900 <p_wpos>
ffffffffc0208e8a:	6585                	lui	a1,0x1
ffffffffc0208e8c:	fff58613          	addi	a2,a1,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc0208e90:	43f75693          	srai	a3,a4,0x3f
ffffffffc0208e94:	92d1                	srli	a3,a3,0x34
ffffffffc0208e96:	00d707b3          	add	a5,a4,a3
ffffffffc0208e9a:	8ff1                	and	a5,a5,a2
ffffffffc0208e9c:	0008e617          	auipc	a2,0x8e
ffffffffc0208ea0:	a6c63603          	ld	a2,-1428(a2) # ffffffffc0296908 <p_rpos>
ffffffffc0208ea4:	8f95                	sub	a5,a5,a3
ffffffffc0208ea6:	0008d697          	auipc	a3,0x8d
ffffffffc0208eaa:	9c268693          	addi	a3,a3,-1598 # ffffffffc0295868 <stdin_buffer>
ffffffffc0208eae:	97b6                	add	a5,a5,a3
ffffffffc0208eb0:	00a78023          	sb	a0,0(a5)
ffffffffc0208eb4:	40c707b3          	sub	a5,a4,a2
ffffffffc0208eb8:	00b7d763          	bge	a5,a1,ffffffffc0208ec6 <dev_stdin_write+0x58>
ffffffffc0208ebc:	0705                	addi	a4,a4,1
ffffffffc0208ebe:	0008e797          	auipc	a5,0x8e
ffffffffc0208ec2:	a4e7b123          	sd	a4,-1470(a5) # ffffffffc0296900 <p_wpos>
ffffffffc0208ec6:	0008d517          	auipc	a0,0x8d
ffffffffc0208eca:	99250513          	addi	a0,a0,-1646 # ffffffffc0295858 <__wait_queue>
ffffffffc0208ece:	facfb0ef          	jal	ffffffffc020467a <wait_queue_empty>
ffffffffc0208ed2:	c919                	beqz	a0,ffffffffc0208ee8 <dev_stdin_write+0x7a>
ffffffffc0208ed4:	e409                	bnez	s0,ffffffffc0208ede <dev_stdin_write+0x70>
ffffffffc0208ed6:	60e2                	ld	ra,24(sp)
ffffffffc0208ed8:	6442                	ld	s0,16(sp)
ffffffffc0208eda:	6105                	addi	sp,sp,32
ffffffffc0208edc:	8082                	ret
ffffffffc0208ede:	6442                	ld	s0,16(sp)
ffffffffc0208ee0:	60e2                	ld	ra,24(sp)
ffffffffc0208ee2:	6105                	addi	sp,sp,32
ffffffffc0208ee4:	ceff706f          	j	ffffffffc0200bd2 <intr_enable>
ffffffffc0208ee8:	800005b7          	lui	a1,0x80000
ffffffffc0208eec:	0591                	addi	a1,a1,4 # ffffffff80000004 <_binary_bin_sfs_img_size+0xffffffff7ff8ad04>
ffffffffc0208eee:	4605                	li	a2,1
ffffffffc0208ef0:	0008d517          	auipc	a0,0x8d
ffffffffc0208ef4:	96850513          	addi	a0,a0,-1688 # ffffffffc0295858 <__wait_queue>
ffffffffc0208ef8:	feafb0ef          	jal	ffffffffc02046e2 <wakeup_queue>
ffffffffc0208efc:	dc69                	beqz	s0,ffffffffc0208ed6 <dev_stdin_write+0x68>
ffffffffc0208efe:	b7c5                	j	ffffffffc0208ede <dev_stdin_write+0x70>
ffffffffc0208f00:	e42a                	sd	a0,8(sp)
ffffffffc0208f02:	cd7f70ef          	jal	ffffffffc0200bd8 <intr_disable>
ffffffffc0208f06:	6522                	ld	a0,8(sp)
ffffffffc0208f08:	4405                	li	s0,1
ffffffffc0208f0a:	bfa5                	j	ffffffffc0208e82 <dev_stdin_write+0x14>

ffffffffc0208f0c <dev_init_stdin>:
ffffffffc0208f0c:	1101                	addi	sp,sp,-32
ffffffffc0208f0e:	ec06                	sd	ra,24(sp)
ffffffffc0208f10:	ac7ff0ef          	jal	ffffffffc02089d6 <dev_create_inode>
ffffffffc0208f14:	c935                	beqz	a0,ffffffffc0208f88 <dev_init_stdin+0x7c>
ffffffffc0208f16:	4d38                	lw	a4,88(a0)
ffffffffc0208f18:	6785                	lui	a5,0x1
ffffffffc0208f1a:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc0208f1e:	08f71e63          	bne	a4,a5,ffffffffc0208fba <dev_init_stdin+0xae>
ffffffffc0208f22:	4785                	li	a5,1
ffffffffc0208f24:	e51c                	sd	a5,8(a0)
ffffffffc0208f26:	00000797          	auipc	a5,0x0
ffffffffc0208f2a:	dd478793          	addi	a5,a5,-556 # ffffffffc0208cfa <stdin_open>
ffffffffc0208f2e:	e91c                	sd	a5,16(a0)
ffffffffc0208f30:	00000797          	auipc	a5,0x0
ffffffffc0208f34:	dd478793          	addi	a5,a5,-556 # ffffffffc0208d04 <stdin_close>
ffffffffc0208f38:	ed1c                	sd	a5,24(a0)
ffffffffc0208f3a:	00000797          	auipc	a5,0x0
ffffffffc0208f3e:	dd278793          	addi	a5,a5,-558 # ffffffffc0208d0c <stdin_io>
ffffffffc0208f42:	f11c                	sd	a5,32(a0)
ffffffffc0208f44:	00000797          	auipc	a5,0x0
ffffffffc0208f48:	dc478793          	addi	a5,a5,-572 # ffffffffc0208d08 <stdin_ioctl>
ffffffffc0208f4c:	f51c                	sd	a5,40(a0)
ffffffffc0208f4e:	00053023          	sd	zero,0(a0)
ffffffffc0208f52:	e42a                	sd	a0,8(sp)
ffffffffc0208f54:	0008d517          	auipc	a0,0x8d
ffffffffc0208f58:	90450513          	addi	a0,a0,-1788 # ffffffffc0295858 <__wait_queue>
ffffffffc0208f5c:	0008e797          	auipc	a5,0x8e
ffffffffc0208f60:	9a07b223          	sd	zero,-1628(a5) # ffffffffc0296900 <p_wpos>
ffffffffc0208f64:	0008e797          	auipc	a5,0x8e
ffffffffc0208f68:	9a07b223          	sd	zero,-1628(a5) # ffffffffc0296908 <p_rpos>
ffffffffc0208f6c:	ebafb0ef          	jal	ffffffffc0204626 <wait_queue_init>
ffffffffc0208f70:	65a2                	ld	a1,8(sp)
ffffffffc0208f72:	4601                	li	a2,0
ffffffffc0208f74:	00005517          	auipc	a0,0x5
ffffffffc0208f78:	62c50513          	addi	a0,a0,1580 # ffffffffc020e5a0 <etext+0x2d40>
ffffffffc0208f7c:	912ff0ef          	jal	ffffffffc020808e <vfs_add_dev>
ffffffffc0208f80:	e105                	bnez	a0,ffffffffc0208fa0 <dev_init_stdin+0x94>
ffffffffc0208f82:	60e2                	ld	ra,24(sp)
ffffffffc0208f84:	6105                	addi	sp,sp,32
ffffffffc0208f86:	8082                	ret
ffffffffc0208f88:	00005617          	auipc	a2,0x5
ffffffffc0208f8c:	5d860613          	addi	a2,a2,1496 # ffffffffc020e560 <etext+0x2d00>
ffffffffc0208f90:	07500593          	li	a1,117
ffffffffc0208f94:	00005517          	auipc	a0,0x5
ffffffffc0208f98:	5ec50513          	addi	a0,a0,1516 # ffffffffc020e580 <etext+0x2d20>
ffffffffc0208f9c:	caef70ef          	jal	ffffffffc020044a <__panic>
ffffffffc0208fa0:	86aa                	mv	a3,a0
ffffffffc0208fa2:	00005617          	auipc	a2,0x5
ffffffffc0208fa6:	60660613          	addi	a2,a2,1542 # ffffffffc020e5a8 <etext+0x2d48>
ffffffffc0208faa:	07b00593          	li	a1,123
ffffffffc0208fae:	00005517          	auipc	a0,0x5
ffffffffc0208fb2:	5d250513          	addi	a0,a0,1490 # ffffffffc020e580 <etext+0x2d20>
ffffffffc0208fb6:	c94f70ef          	jal	ffffffffc020044a <__panic>
ffffffffc0208fba:	00005697          	auipc	a3,0x5
ffffffffc0208fbe:	0ce68693          	addi	a3,a3,206 # ffffffffc020e088 <etext+0x2828>
ffffffffc0208fc2:	00003617          	auipc	a2,0x3
ffffffffc0208fc6:	cd660613          	addi	a2,a2,-810 # ffffffffc020bc98 <etext+0x438>
ffffffffc0208fca:	07700593          	li	a1,119
ffffffffc0208fce:	00005517          	auipc	a0,0x5
ffffffffc0208fd2:	5b250513          	addi	a0,a0,1458 # ffffffffc020e580 <etext+0x2d20>
ffffffffc0208fd6:	c74f70ef          	jal	ffffffffc020044a <__panic>

ffffffffc0208fda <stdout_open>:
ffffffffc0208fda:	4785                	li	a5,1
ffffffffc0208fdc:	00f59463          	bne	a1,a5,ffffffffc0208fe4 <stdout_open+0xa>
ffffffffc0208fe0:	4501                	li	a0,0
ffffffffc0208fe2:	8082                	ret
ffffffffc0208fe4:	5575                	li	a0,-3
ffffffffc0208fe6:	8082                	ret

ffffffffc0208fe8 <stdout_close>:
ffffffffc0208fe8:	4501                	li	a0,0
ffffffffc0208fea:	8082                	ret

ffffffffc0208fec <stdout_ioctl>:
ffffffffc0208fec:	5575                	li	a0,-3
ffffffffc0208fee:	8082                	ret

ffffffffc0208ff0 <stdout_io>:
ffffffffc0208ff0:	ca15                	beqz	a2,ffffffffc0209024 <stdout_io+0x34>
ffffffffc0208ff2:	6d9c                	ld	a5,24(a1)
ffffffffc0208ff4:	c795                	beqz	a5,ffffffffc0209020 <stdout_io+0x30>
ffffffffc0208ff6:	1101                	addi	sp,sp,-32
ffffffffc0208ff8:	e822                	sd	s0,16(sp)
ffffffffc0208ffa:	6180                	ld	s0,0(a1)
ffffffffc0208ffc:	e426                	sd	s1,8(sp)
ffffffffc0208ffe:	ec06                	sd	ra,24(sp)
ffffffffc0209000:	84ae                	mv	s1,a1
ffffffffc0209002:	00044503          	lbu	a0,0(s0)
ffffffffc0209006:	0405                	addi	s0,s0,1
ffffffffc0209008:	9d8f70ef          	jal	ffffffffc02001e0 <cputchar>
ffffffffc020900c:	6c9c                	ld	a5,24(s1)
ffffffffc020900e:	17fd                	addi	a5,a5,-1
ffffffffc0209010:	ec9c                	sd	a5,24(s1)
ffffffffc0209012:	fbe5                	bnez	a5,ffffffffc0209002 <stdout_io+0x12>
ffffffffc0209014:	60e2                	ld	ra,24(sp)
ffffffffc0209016:	6442                	ld	s0,16(sp)
ffffffffc0209018:	64a2                	ld	s1,8(sp)
ffffffffc020901a:	4501                	li	a0,0
ffffffffc020901c:	6105                	addi	sp,sp,32
ffffffffc020901e:	8082                	ret
ffffffffc0209020:	4501                	li	a0,0
ffffffffc0209022:	8082                	ret
ffffffffc0209024:	5575                	li	a0,-3
ffffffffc0209026:	8082                	ret

ffffffffc0209028 <dev_init_stdout>:
ffffffffc0209028:	1141                	addi	sp,sp,-16
ffffffffc020902a:	e406                	sd	ra,8(sp)
ffffffffc020902c:	9abff0ef          	jal	ffffffffc02089d6 <dev_create_inode>
ffffffffc0209030:	c939                	beqz	a0,ffffffffc0209086 <dev_init_stdout+0x5e>
ffffffffc0209032:	4d38                	lw	a4,88(a0)
ffffffffc0209034:	6785                	lui	a5,0x1
ffffffffc0209036:	23478793          	addi	a5,a5,564 # 1234 <_binary_bin_swap_img_size-0x6acc>
ffffffffc020903a:	06f71f63          	bne	a4,a5,ffffffffc02090b8 <dev_init_stdout+0x90>
ffffffffc020903e:	4785                	li	a5,1
ffffffffc0209040:	e51c                	sd	a5,8(a0)
ffffffffc0209042:	00000797          	auipc	a5,0x0
ffffffffc0209046:	f9878793          	addi	a5,a5,-104 # ffffffffc0208fda <stdout_open>
ffffffffc020904a:	e91c                	sd	a5,16(a0)
ffffffffc020904c:	00000797          	auipc	a5,0x0
ffffffffc0209050:	f9c78793          	addi	a5,a5,-100 # ffffffffc0208fe8 <stdout_close>
ffffffffc0209054:	ed1c                	sd	a5,24(a0)
ffffffffc0209056:	00000797          	auipc	a5,0x0
ffffffffc020905a:	f9a78793          	addi	a5,a5,-102 # ffffffffc0208ff0 <stdout_io>
ffffffffc020905e:	f11c                	sd	a5,32(a0)
ffffffffc0209060:	00000797          	auipc	a5,0x0
ffffffffc0209064:	f8c78793          	addi	a5,a5,-116 # ffffffffc0208fec <stdout_ioctl>
ffffffffc0209068:	f51c                	sd	a5,40(a0)
ffffffffc020906a:	00053023          	sd	zero,0(a0)
ffffffffc020906e:	85aa                	mv	a1,a0
ffffffffc0209070:	4601                	li	a2,0
ffffffffc0209072:	00005517          	auipc	a0,0x5
ffffffffc0209076:	59650513          	addi	a0,a0,1430 # ffffffffc020e608 <etext+0x2da8>
ffffffffc020907a:	814ff0ef          	jal	ffffffffc020808e <vfs_add_dev>
ffffffffc020907e:	e105                	bnez	a0,ffffffffc020909e <dev_init_stdout+0x76>
ffffffffc0209080:	60a2                	ld	ra,8(sp)
ffffffffc0209082:	0141                	addi	sp,sp,16
ffffffffc0209084:	8082                	ret
ffffffffc0209086:	00005617          	auipc	a2,0x5
ffffffffc020908a:	54260613          	addi	a2,a2,1346 # ffffffffc020e5c8 <etext+0x2d68>
ffffffffc020908e:	03700593          	li	a1,55
ffffffffc0209092:	00005517          	auipc	a0,0x5
ffffffffc0209096:	55650513          	addi	a0,a0,1366 # ffffffffc020e5e8 <etext+0x2d88>
ffffffffc020909a:	bb0f70ef          	jal	ffffffffc020044a <__panic>
ffffffffc020909e:	86aa                	mv	a3,a0
ffffffffc02090a0:	00005617          	auipc	a2,0x5
ffffffffc02090a4:	57060613          	addi	a2,a2,1392 # ffffffffc020e610 <etext+0x2db0>
ffffffffc02090a8:	03d00593          	li	a1,61
ffffffffc02090ac:	00005517          	auipc	a0,0x5
ffffffffc02090b0:	53c50513          	addi	a0,a0,1340 # ffffffffc020e5e8 <etext+0x2d88>
ffffffffc02090b4:	b96f70ef          	jal	ffffffffc020044a <__panic>
ffffffffc02090b8:	00005697          	auipc	a3,0x5
ffffffffc02090bc:	fd068693          	addi	a3,a3,-48 # ffffffffc020e088 <etext+0x2828>
ffffffffc02090c0:	00003617          	auipc	a2,0x3
ffffffffc02090c4:	bd860613          	addi	a2,a2,-1064 # ffffffffc020bc98 <etext+0x438>
ffffffffc02090c8:	03900593          	li	a1,57
ffffffffc02090cc:	00005517          	auipc	a0,0x5
ffffffffc02090d0:	51c50513          	addi	a0,a0,1308 # ffffffffc020e5e8 <etext+0x2d88>
ffffffffc02090d4:	b76f70ef          	jal	ffffffffc020044a <__panic>

ffffffffc02090d8 <bitmap_translate.part.0>:
ffffffffc02090d8:	1141                	addi	sp,sp,-16
ffffffffc02090da:	00005697          	auipc	a3,0x5
ffffffffc02090de:	55668693          	addi	a3,a3,1366 # ffffffffc020e630 <etext+0x2dd0>
ffffffffc02090e2:	00003617          	auipc	a2,0x3
ffffffffc02090e6:	bb660613          	addi	a2,a2,-1098 # ffffffffc020bc98 <etext+0x438>
ffffffffc02090ea:	04c00593          	li	a1,76
ffffffffc02090ee:	00005517          	auipc	a0,0x5
ffffffffc02090f2:	55a50513          	addi	a0,a0,1370 # ffffffffc020e648 <etext+0x2de8>
ffffffffc02090f6:	e406                	sd	ra,8(sp)
ffffffffc02090f8:	b52f70ef          	jal	ffffffffc020044a <__panic>

ffffffffc02090fc <bitmap_create>:
ffffffffc02090fc:	7139                	addi	sp,sp,-64
ffffffffc02090fe:	fc06                	sd	ra,56(sp)
ffffffffc0209100:	f822                	sd	s0,48(sp)
ffffffffc0209102:	f426                	sd	s1,40(sp)
ffffffffc0209104:	c179                	beqz	a0,ffffffffc02091ca <bitmap_create+0xce>
ffffffffc0209106:	842a                	mv	s0,a0
ffffffffc0209108:	4541                	li	a0,16
ffffffffc020910a:	eb7f80ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc020910e:	84aa                	mv	s1,a0
ffffffffc0209110:	c555                	beqz	a0,ffffffffc02091bc <bitmap_create+0xc0>
ffffffffc0209112:	e852                	sd	s4,16(sp)
ffffffffc0209114:	02041a13          	slli	s4,s0,0x20
ffffffffc0209118:	020a5a13          	srli	s4,s4,0x20
ffffffffc020911c:	f04a                	sd	s2,32(sp)
ffffffffc020911e:	01fa0913          	addi	s2,s4,31
ffffffffc0209122:	ec4e                	sd	s3,24(sp)
ffffffffc0209124:	00595993          	srli	s3,s2,0x5
ffffffffc0209128:	00299613          	slli	a2,s3,0x2
ffffffffc020912c:	8532                	mv	a0,a2
ffffffffc020912e:	e432                	sd	a2,8(sp)
ffffffffc0209130:	e91f80ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc0209134:	6622                	ld	a2,8(sp)
ffffffffc0209136:	cd2d                	beqz	a0,ffffffffc02091b0 <bitmap_create+0xb4>
ffffffffc0209138:	c080                	sw	s0,0(s1)
ffffffffc020913a:	0134a223          	sw	s3,4(s1)
ffffffffc020913e:	0ff00593          	li	a1,255
ffffffffc0209142:	6b6020ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc0209146:	4785                	li	a5,1
ffffffffc0209148:	1796                	slli	a5,a5,0x25
ffffffffc020914a:	1781                	addi	a5,a5,-32
ffffffffc020914c:	e488                	sd	a0,8(s1)
ffffffffc020914e:	00f97933          	and	s2,s2,a5
ffffffffc0209152:	052a0663          	beq	s4,s2,ffffffffc020919e <bitmap_create+0xa2>
ffffffffc0209156:	39fd                	addiw	s3,s3,-1
ffffffffc0209158:	0054571b          	srliw	a4,s0,0x5
ffffffffc020915c:	0b371963          	bne	a4,s3,ffffffffc020920e <bitmap_create+0x112>
ffffffffc0209160:	0057179b          	slliw	a5,a4,0x5
ffffffffc0209164:	40f407bb          	subw	a5,s0,a5
ffffffffc0209168:	fff7861b          	addiw	a2,a5,-1
ffffffffc020916c:	46f9                	li	a3,30
ffffffffc020916e:	08c6e063          	bltu	a3,a2,ffffffffc02091ee <bitmap_create+0xf2>
ffffffffc0209172:	070a                	slli	a4,a4,0x2
ffffffffc0209174:	953a                	add	a0,a0,a4
ffffffffc0209176:	4118                	lw	a4,0(a0)
ffffffffc0209178:	4585                	li	a1,1
ffffffffc020917a:	02000613          	li	a2,32
ffffffffc020917e:	00f596bb          	sllw	a3,a1,a5
ffffffffc0209182:	2785                	addiw	a5,a5,1
ffffffffc0209184:	8f35                	xor	a4,a4,a3
ffffffffc0209186:	fec79ce3          	bne	a5,a2,ffffffffc020917e <bitmap_create+0x82>
ffffffffc020918a:	7442                	ld	s0,48(sp)
ffffffffc020918c:	70e2                	ld	ra,56(sp)
ffffffffc020918e:	c118                	sw	a4,0(a0)
ffffffffc0209190:	7902                	ld	s2,32(sp)
ffffffffc0209192:	69e2                	ld	s3,24(sp)
ffffffffc0209194:	6a42                	ld	s4,16(sp)
ffffffffc0209196:	8526                	mv	a0,s1
ffffffffc0209198:	74a2                	ld	s1,40(sp)
ffffffffc020919a:	6121                	addi	sp,sp,64
ffffffffc020919c:	8082                	ret
ffffffffc020919e:	7442                	ld	s0,48(sp)
ffffffffc02091a0:	70e2                	ld	ra,56(sp)
ffffffffc02091a2:	7902                	ld	s2,32(sp)
ffffffffc02091a4:	69e2                	ld	s3,24(sp)
ffffffffc02091a6:	6a42                	ld	s4,16(sp)
ffffffffc02091a8:	8526                	mv	a0,s1
ffffffffc02091aa:	74a2                	ld	s1,40(sp)
ffffffffc02091ac:	6121                	addi	sp,sp,64
ffffffffc02091ae:	8082                	ret
ffffffffc02091b0:	8526                	mv	a0,s1
ffffffffc02091b2:	eb5f80ef          	jal	ffffffffc0202066 <kfree>
ffffffffc02091b6:	7902                	ld	s2,32(sp)
ffffffffc02091b8:	69e2                	ld	s3,24(sp)
ffffffffc02091ba:	6a42                	ld	s4,16(sp)
ffffffffc02091bc:	7442                	ld	s0,48(sp)
ffffffffc02091be:	70e2                	ld	ra,56(sp)
ffffffffc02091c0:	4481                	li	s1,0
ffffffffc02091c2:	8526                	mv	a0,s1
ffffffffc02091c4:	74a2                	ld	s1,40(sp)
ffffffffc02091c6:	6121                	addi	sp,sp,64
ffffffffc02091c8:	8082                	ret
ffffffffc02091ca:	00005697          	auipc	a3,0x5
ffffffffc02091ce:	49668693          	addi	a3,a3,1174 # ffffffffc020e660 <etext+0x2e00>
ffffffffc02091d2:	00003617          	auipc	a2,0x3
ffffffffc02091d6:	ac660613          	addi	a2,a2,-1338 # ffffffffc020bc98 <etext+0x438>
ffffffffc02091da:	45d5                	li	a1,21
ffffffffc02091dc:	00005517          	auipc	a0,0x5
ffffffffc02091e0:	46c50513          	addi	a0,a0,1132 # ffffffffc020e648 <etext+0x2de8>
ffffffffc02091e4:	f04a                	sd	s2,32(sp)
ffffffffc02091e6:	ec4e                	sd	s3,24(sp)
ffffffffc02091e8:	e852                	sd	s4,16(sp)
ffffffffc02091ea:	a60f70ef          	jal	ffffffffc020044a <__panic>
ffffffffc02091ee:	00005697          	auipc	a3,0x5
ffffffffc02091f2:	4b268693          	addi	a3,a3,1202 # ffffffffc020e6a0 <etext+0x2e40>
ffffffffc02091f6:	00003617          	auipc	a2,0x3
ffffffffc02091fa:	aa260613          	addi	a2,a2,-1374 # ffffffffc020bc98 <etext+0x438>
ffffffffc02091fe:	02b00593          	li	a1,43
ffffffffc0209202:	00005517          	auipc	a0,0x5
ffffffffc0209206:	44650513          	addi	a0,a0,1094 # ffffffffc020e648 <etext+0x2de8>
ffffffffc020920a:	a40f70ef          	jal	ffffffffc020044a <__panic>
ffffffffc020920e:	00005697          	auipc	a3,0x5
ffffffffc0209212:	47a68693          	addi	a3,a3,1146 # ffffffffc020e688 <etext+0x2e28>
ffffffffc0209216:	00003617          	auipc	a2,0x3
ffffffffc020921a:	a8260613          	addi	a2,a2,-1406 # ffffffffc020bc98 <etext+0x438>
ffffffffc020921e:	02a00593          	li	a1,42
ffffffffc0209222:	00005517          	auipc	a0,0x5
ffffffffc0209226:	42650513          	addi	a0,a0,1062 # ffffffffc020e648 <etext+0x2de8>
ffffffffc020922a:	a20f70ef          	jal	ffffffffc020044a <__panic>

ffffffffc020922e <bitmap_alloc>:
ffffffffc020922e:	4150                	lw	a2,4(a0)
ffffffffc0209230:	c229                	beqz	a2,ffffffffc0209272 <bitmap_alloc+0x44>
ffffffffc0209232:	6518                	ld	a4,8(a0)
ffffffffc0209234:	4781                	li	a5,0
ffffffffc0209236:	a029                	j	ffffffffc0209240 <bitmap_alloc+0x12>
ffffffffc0209238:	2785                	addiw	a5,a5,1
ffffffffc020923a:	0711                	addi	a4,a4,4
ffffffffc020923c:	02f60b63          	beq	a2,a5,ffffffffc0209272 <bitmap_alloc+0x44>
ffffffffc0209240:	4314                	lw	a3,0(a4)
ffffffffc0209242:	dafd                	beqz	a3,ffffffffc0209238 <bitmap_alloc+0xa>
ffffffffc0209244:	0016f613          	andi	a2,a3,1
ffffffffc0209248:	ea29                	bnez	a2,ffffffffc020929a <bitmap_alloc+0x6c>
ffffffffc020924a:	02000893          	li	a7,32
ffffffffc020924e:	4305                	li	t1,1
ffffffffc0209250:	2605                	addiw	a2,a2,1
ffffffffc0209252:	03160263          	beq	a2,a7,ffffffffc0209276 <bitmap_alloc+0x48>
ffffffffc0209256:	00c3153b          	sllw	a0,t1,a2
ffffffffc020925a:	00a6f833          	and	a6,a3,a0
ffffffffc020925e:	fe0809e3          	beqz	a6,ffffffffc0209250 <bitmap_alloc+0x22>
ffffffffc0209262:	8ea9                	xor	a3,a3,a0
ffffffffc0209264:	0057979b          	slliw	a5,a5,0x5
ffffffffc0209268:	c314                	sw	a3,0(a4)
ffffffffc020926a:	9fb1                	addw	a5,a5,a2
ffffffffc020926c:	c19c                	sw	a5,0(a1)
ffffffffc020926e:	4501                	li	a0,0
ffffffffc0209270:	8082                	ret
ffffffffc0209272:	5571                	li	a0,-4
ffffffffc0209274:	8082                	ret
ffffffffc0209276:	1141                	addi	sp,sp,-16
ffffffffc0209278:	00005697          	auipc	a3,0x5
ffffffffc020927c:	45068693          	addi	a3,a3,1104 # ffffffffc020e6c8 <etext+0x2e68>
ffffffffc0209280:	00003617          	auipc	a2,0x3
ffffffffc0209284:	a1860613          	addi	a2,a2,-1512 # ffffffffc020bc98 <etext+0x438>
ffffffffc0209288:	04300593          	li	a1,67
ffffffffc020928c:	00005517          	auipc	a0,0x5
ffffffffc0209290:	3bc50513          	addi	a0,a0,956 # ffffffffc020e648 <etext+0x2de8>
ffffffffc0209294:	e406                	sd	ra,8(sp)
ffffffffc0209296:	9b4f70ef          	jal	ffffffffc020044a <__panic>
ffffffffc020929a:	8532                	mv	a0,a2
ffffffffc020929c:	4601                	li	a2,0
ffffffffc020929e:	b7d1                	j	ffffffffc0209262 <bitmap_alloc+0x34>

ffffffffc02092a0 <bitmap_test>:
ffffffffc02092a0:	411c                	lw	a5,0(a0)
ffffffffc02092a2:	00f5ff63          	bgeu	a1,a5,ffffffffc02092c0 <bitmap_test+0x20>
ffffffffc02092a6:	651c                	ld	a5,8(a0)
ffffffffc02092a8:	0055d71b          	srliw	a4,a1,0x5
ffffffffc02092ac:	070a                	slli	a4,a4,0x2
ffffffffc02092ae:	97ba                	add	a5,a5,a4
ffffffffc02092b0:	439c                	lw	a5,0(a5)
ffffffffc02092b2:	4505                	li	a0,1
ffffffffc02092b4:	00b5153b          	sllw	a0,a0,a1
ffffffffc02092b8:	8d7d                	and	a0,a0,a5
ffffffffc02092ba:	1502                	slli	a0,a0,0x20
ffffffffc02092bc:	9101                	srli	a0,a0,0x20
ffffffffc02092be:	8082                	ret
ffffffffc02092c0:	1141                	addi	sp,sp,-16
ffffffffc02092c2:	e406                	sd	ra,8(sp)
ffffffffc02092c4:	e15ff0ef          	jal	ffffffffc02090d8 <bitmap_translate.part.0>

ffffffffc02092c8 <bitmap_free>:
ffffffffc02092c8:	411c                	lw	a5,0(a0)
ffffffffc02092ca:	1141                	addi	sp,sp,-16
ffffffffc02092cc:	e406                	sd	ra,8(sp)
ffffffffc02092ce:	02f5f363          	bgeu	a1,a5,ffffffffc02092f4 <bitmap_free+0x2c>
ffffffffc02092d2:	651c                	ld	a5,8(a0)
ffffffffc02092d4:	0055d71b          	srliw	a4,a1,0x5
ffffffffc02092d8:	070a                	slli	a4,a4,0x2
ffffffffc02092da:	97ba                	add	a5,a5,a4
ffffffffc02092dc:	4394                	lw	a3,0(a5)
ffffffffc02092de:	4705                	li	a4,1
ffffffffc02092e0:	00b715bb          	sllw	a1,a4,a1
ffffffffc02092e4:	00b6f733          	and	a4,a3,a1
ffffffffc02092e8:	eb01                	bnez	a4,ffffffffc02092f8 <bitmap_free+0x30>
ffffffffc02092ea:	60a2                	ld	ra,8(sp)
ffffffffc02092ec:	8ecd                	or	a3,a3,a1
ffffffffc02092ee:	c394                	sw	a3,0(a5)
ffffffffc02092f0:	0141                	addi	sp,sp,16
ffffffffc02092f2:	8082                	ret
ffffffffc02092f4:	de5ff0ef          	jal	ffffffffc02090d8 <bitmap_translate.part.0>
ffffffffc02092f8:	00005697          	auipc	a3,0x5
ffffffffc02092fc:	3d868693          	addi	a3,a3,984 # ffffffffc020e6d0 <etext+0x2e70>
ffffffffc0209300:	00003617          	auipc	a2,0x3
ffffffffc0209304:	99860613          	addi	a2,a2,-1640 # ffffffffc020bc98 <etext+0x438>
ffffffffc0209308:	05f00593          	li	a1,95
ffffffffc020930c:	00005517          	auipc	a0,0x5
ffffffffc0209310:	33c50513          	addi	a0,a0,828 # ffffffffc020e648 <etext+0x2de8>
ffffffffc0209314:	936f70ef          	jal	ffffffffc020044a <__panic>

ffffffffc0209318 <bitmap_destroy>:
ffffffffc0209318:	1141                	addi	sp,sp,-16
ffffffffc020931a:	e022                	sd	s0,0(sp)
ffffffffc020931c:	842a                	mv	s0,a0
ffffffffc020931e:	6508                	ld	a0,8(a0)
ffffffffc0209320:	e406                	sd	ra,8(sp)
ffffffffc0209322:	d45f80ef          	jal	ffffffffc0202066 <kfree>
ffffffffc0209326:	8522                	mv	a0,s0
ffffffffc0209328:	6402                	ld	s0,0(sp)
ffffffffc020932a:	60a2                	ld	ra,8(sp)
ffffffffc020932c:	0141                	addi	sp,sp,16
ffffffffc020932e:	d39f806f          	j	ffffffffc0202066 <kfree>

ffffffffc0209332 <bitmap_getdata>:
ffffffffc0209332:	c589                	beqz	a1,ffffffffc020933c <bitmap_getdata+0xa>
ffffffffc0209334:	00456783          	lwu	a5,4(a0)
ffffffffc0209338:	078a                	slli	a5,a5,0x2
ffffffffc020933a:	e19c                	sd	a5,0(a1)
ffffffffc020933c:	6508                	ld	a0,8(a0)
ffffffffc020933e:	8082                	ret

ffffffffc0209340 <sfs_init>:
ffffffffc0209340:	1141                	addi	sp,sp,-16
ffffffffc0209342:	00005517          	auipc	a0,0x5
ffffffffc0209346:	1f650513          	addi	a0,a0,502 # ffffffffc020e538 <etext+0x2cd8>
ffffffffc020934a:	e406                	sd	ra,8(sp)
ffffffffc020934c:	576000ef          	jal	ffffffffc02098c2 <sfs_mount>
ffffffffc0209350:	e501                	bnez	a0,ffffffffc0209358 <sfs_init+0x18>
ffffffffc0209352:	60a2                	ld	ra,8(sp)
ffffffffc0209354:	0141                	addi	sp,sp,16
ffffffffc0209356:	8082                	ret
ffffffffc0209358:	86aa                	mv	a3,a0
ffffffffc020935a:	00005617          	auipc	a2,0x5
ffffffffc020935e:	38660613          	addi	a2,a2,902 # ffffffffc020e6e0 <etext+0x2e80>
ffffffffc0209362:	45c1                	li	a1,16
ffffffffc0209364:	00005517          	auipc	a0,0x5
ffffffffc0209368:	39c50513          	addi	a0,a0,924 # ffffffffc020e700 <etext+0x2ea0>
ffffffffc020936c:	8def70ef          	jal	ffffffffc020044a <__panic>

ffffffffc0209370 <sfs_unmount>:
ffffffffc0209370:	1141                	addi	sp,sp,-16
ffffffffc0209372:	e406                	sd	ra,8(sp)
ffffffffc0209374:	e022                	sd	s0,0(sp)
ffffffffc0209376:	cd1d                	beqz	a0,ffffffffc02093b4 <sfs_unmount+0x44>
ffffffffc0209378:	0b052783          	lw	a5,176(a0)
ffffffffc020937c:	842a                	mv	s0,a0
ffffffffc020937e:	eb9d                	bnez	a5,ffffffffc02093b4 <sfs_unmount+0x44>
ffffffffc0209380:	7158                	ld	a4,160(a0)
ffffffffc0209382:	09850793          	addi	a5,a0,152
ffffffffc0209386:	02f71563          	bne	a4,a5,ffffffffc02093b0 <sfs_unmount+0x40>
ffffffffc020938a:	613c                	ld	a5,64(a0)
ffffffffc020938c:	e7a1                	bnez	a5,ffffffffc02093d4 <sfs_unmount+0x64>
ffffffffc020938e:	7d08                	ld	a0,56(a0)
ffffffffc0209390:	f89ff0ef          	jal	ffffffffc0209318 <bitmap_destroy>
ffffffffc0209394:	6428                	ld	a0,72(s0)
ffffffffc0209396:	cd1f80ef          	jal	ffffffffc0202066 <kfree>
ffffffffc020939a:	7448                	ld	a0,168(s0)
ffffffffc020939c:	ccbf80ef          	jal	ffffffffc0202066 <kfree>
ffffffffc02093a0:	8522                	mv	a0,s0
ffffffffc02093a2:	cc5f80ef          	jal	ffffffffc0202066 <kfree>
ffffffffc02093a6:	4501                	li	a0,0
ffffffffc02093a8:	60a2                	ld	ra,8(sp)
ffffffffc02093aa:	6402                	ld	s0,0(sp)
ffffffffc02093ac:	0141                	addi	sp,sp,16
ffffffffc02093ae:	8082                	ret
ffffffffc02093b0:	5545                	li	a0,-15
ffffffffc02093b2:	bfdd                	j	ffffffffc02093a8 <sfs_unmount+0x38>
ffffffffc02093b4:	00005697          	auipc	a3,0x5
ffffffffc02093b8:	36468693          	addi	a3,a3,868 # ffffffffc020e718 <etext+0x2eb8>
ffffffffc02093bc:	00003617          	auipc	a2,0x3
ffffffffc02093c0:	8dc60613          	addi	a2,a2,-1828 # ffffffffc020bc98 <etext+0x438>
ffffffffc02093c4:	04100593          	li	a1,65
ffffffffc02093c8:	00005517          	auipc	a0,0x5
ffffffffc02093cc:	38050513          	addi	a0,a0,896 # ffffffffc020e748 <etext+0x2ee8>
ffffffffc02093d0:	87af70ef          	jal	ffffffffc020044a <__panic>
ffffffffc02093d4:	00005697          	auipc	a3,0x5
ffffffffc02093d8:	38c68693          	addi	a3,a3,908 # ffffffffc020e760 <etext+0x2f00>
ffffffffc02093dc:	00003617          	auipc	a2,0x3
ffffffffc02093e0:	8bc60613          	addi	a2,a2,-1860 # ffffffffc020bc98 <etext+0x438>
ffffffffc02093e4:	04500593          	li	a1,69
ffffffffc02093e8:	00005517          	auipc	a0,0x5
ffffffffc02093ec:	36050513          	addi	a0,a0,864 # ffffffffc020e748 <etext+0x2ee8>
ffffffffc02093f0:	85af70ef          	jal	ffffffffc020044a <__panic>

ffffffffc02093f4 <sfs_cleanup>:
ffffffffc02093f4:	1101                	addi	sp,sp,-32
ffffffffc02093f6:	ec06                	sd	ra,24(sp)
ffffffffc02093f8:	e426                	sd	s1,8(sp)
ffffffffc02093fa:	c13d                	beqz	a0,ffffffffc0209460 <sfs_cleanup+0x6c>
ffffffffc02093fc:	0b052783          	lw	a5,176(a0)
ffffffffc0209400:	84aa                	mv	s1,a0
ffffffffc0209402:	efb9                	bnez	a5,ffffffffc0209460 <sfs_cleanup+0x6c>
ffffffffc0209404:	4158                	lw	a4,4(a0)
ffffffffc0209406:	4514                	lw	a3,8(a0)
ffffffffc0209408:	00c50593          	addi	a1,a0,12
ffffffffc020940c:	00005517          	auipc	a0,0x5
ffffffffc0209410:	36c50513          	addi	a0,a0,876 # ffffffffc020e778 <etext+0x2f18>
ffffffffc0209414:	40d7063b          	subw	a2,a4,a3
ffffffffc0209418:	e822                	sd	s0,16(sp)
ffffffffc020941a:	d8df60ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc020941e:	02000413          	li	s0,32
ffffffffc0209422:	a019                	j	ffffffffc0209428 <sfs_cleanup+0x34>
ffffffffc0209424:	347d                	addiw	s0,s0,-1
ffffffffc0209426:	c811                	beqz	s0,ffffffffc020943a <sfs_cleanup+0x46>
ffffffffc0209428:	7cdc                	ld	a5,184(s1)
ffffffffc020942a:	8526                	mv	a0,s1
ffffffffc020942c:	9782                	jalr	a5
ffffffffc020942e:	f97d                	bnez	a0,ffffffffc0209424 <sfs_cleanup+0x30>
ffffffffc0209430:	6442                	ld	s0,16(sp)
ffffffffc0209432:	60e2                	ld	ra,24(sp)
ffffffffc0209434:	64a2                	ld	s1,8(sp)
ffffffffc0209436:	6105                	addi	sp,sp,32
ffffffffc0209438:	8082                	ret
ffffffffc020943a:	6442                	ld	s0,16(sp)
ffffffffc020943c:	60e2                	ld	ra,24(sp)
ffffffffc020943e:	00c48693          	addi	a3,s1,12
ffffffffc0209442:	64a2                	ld	s1,8(sp)
ffffffffc0209444:	872a                	mv	a4,a0
ffffffffc0209446:	00005617          	auipc	a2,0x5
ffffffffc020944a:	35260613          	addi	a2,a2,850 # ffffffffc020e798 <etext+0x2f38>
ffffffffc020944e:	05f00593          	li	a1,95
ffffffffc0209452:	00005517          	auipc	a0,0x5
ffffffffc0209456:	2f650513          	addi	a0,a0,758 # ffffffffc020e748 <etext+0x2ee8>
ffffffffc020945a:	6105                	addi	sp,sp,32
ffffffffc020945c:	858f706f          	j	ffffffffc02004b4 <__warn>
ffffffffc0209460:	00005697          	auipc	a3,0x5
ffffffffc0209464:	2b868693          	addi	a3,a3,696 # ffffffffc020e718 <etext+0x2eb8>
ffffffffc0209468:	00003617          	auipc	a2,0x3
ffffffffc020946c:	83060613          	addi	a2,a2,-2000 # ffffffffc020bc98 <etext+0x438>
ffffffffc0209470:	05400593          	li	a1,84
ffffffffc0209474:	00005517          	auipc	a0,0x5
ffffffffc0209478:	2d450513          	addi	a0,a0,724 # ffffffffc020e748 <etext+0x2ee8>
ffffffffc020947c:	e822                	sd	s0,16(sp)
ffffffffc020947e:	e04a                	sd	s2,0(sp)
ffffffffc0209480:	fcbf60ef          	jal	ffffffffc020044a <__panic>

ffffffffc0209484 <sfs_sync>:
ffffffffc0209484:	7179                	addi	sp,sp,-48
ffffffffc0209486:	f406                	sd	ra,40(sp)
ffffffffc0209488:	e44e                	sd	s3,8(sp)
ffffffffc020948a:	c94d                	beqz	a0,ffffffffc020953c <sfs_sync+0xb8>
ffffffffc020948c:	0b052783          	lw	a5,176(a0)
ffffffffc0209490:	89aa                	mv	s3,a0
ffffffffc0209492:	e7cd                	bnez	a5,ffffffffc020953c <sfs_sync+0xb8>
ffffffffc0209494:	f022                	sd	s0,32(sp)
ffffffffc0209496:	e84a                	sd	s2,16(sp)
ffffffffc0209498:	605010ef          	jal	ffffffffc020b29c <lock_sfs_fs>
ffffffffc020949c:	0a09b403          	ld	s0,160(s3)
ffffffffc02094a0:	09898913          	addi	s2,s3,152
ffffffffc02094a4:	02890663          	beq	s2,s0,ffffffffc02094d0 <sfs_sync+0x4c>
ffffffffc02094a8:	7c1c                	ld	a5,56(s0)
ffffffffc02094aa:	cbad                	beqz	a5,ffffffffc020951c <sfs_sync+0x98>
ffffffffc02094ac:	7b9c                	ld	a5,48(a5)
ffffffffc02094ae:	c7bd                	beqz	a5,ffffffffc020951c <sfs_sync+0x98>
ffffffffc02094b0:	fc840513          	addi	a0,s0,-56
ffffffffc02094b4:	00004597          	auipc	a1,0x4
ffffffffc02094b8:	0c458593          	addi	a1,a1,196 # ffffffffc020d578 <etext+0x1d18>
ffffffffc02094bc:	decfe0ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc02094c0:	7c1c                	ld	a5,56(s0)
ffffffffc02094c2:	fc840513          	addi	a0,s0,-56
ffffffffc02094c6:	7b9c                	ld	a5,48(a5)
ffffffffc02094c8:	9782                	jalr	a5
ffffffffc02094ca:	6400                	ld	s0,8(s0)
ffffffffc02094cc:	fc891ee3          	bne	s2,s0,ffffffffc02094a8 <sfs_sync+0x24>
ffffffffc02094d0:	854e                	mv	a0,s3
ffffffffc02094d2:	5db010ef          	jal	ffffffffc020b2ac <unlock_sfs_fs>
ffffffffc02094d6:	0409b783          	ld	a5,64(s3)
ffffffffc02094da:	4501                	li	a0,0
ffffffffc02094dc:	e799                	bnez	a5,ffffffffc02094ea <sfs_sync+0x66>
ffffffffc02094de:	7402                	ld	s0,32(sp)
ffffffffc02094e0:	70a2                	ld	ra,40(sp)
ffffffffc02094e2:	6942                	ld	s2,16(sp)
ffffffffc02094e4:	69a2                	ld	s3,8(sp)
ffffffffc02094e6:	6145                	addi	sp,sp,48
ffffffffc02094e8:	8082                	ret
ffffffffc02094ea:	0409b023          	sd	zero,64(s3)
ffffffffc02094ee:	854e                	mv	a0,s3
ffffffffc02094f0:	48d010ef          	jal	ffffffffc020b17c <sfs_sync_super>
ffffffffc02094f4:	c911                	beqz	a0,ffffffffc0209508 <sfs_sync+0x84>
ffffffffc02094f6:	7402                	ld	s0,32(sp)
ffffffffc02094f8:	70a2                	ld	ra,40(sp)
ffffffffc02094fa:	4785                	li	a5,1
ffffffffc02094fc:	04f9b023          	sd	a5,64(s3)
ffffffffc0209500:	6942                	ld	s2,16(sp)
ffffffffc0209502:	69a2                	ld	s3,8(sp)
ffffffffc0209504:	6145                	addi	sp,sp,48
ffffffffc0209506:	8082                	ret
ffffffffc0209508:	854e                	mv	a0,s3
ffffffffc020950a:	4b9010ef          	jal	ffffffffc020b1c2 <sfs_sync_freemap>
ffffffffc020950e:	f565                	bnez	a0,ffffffffc02094f6 <sfs_sync+0x72>
ffffffffc0209510:	7402                	ld	s0,32(sp)
ffffffffc0209512:	70a2                	ld	ra,40(sp)
ffffffffc0209514:	6942                	ld	s2,16(sp)
ffffffffc0209516:	69a2                	ld	s3,8(sp)
ffffffffc0209518:	6145                	addi	sp,sp,48
ffffffffc020951a:	8082                	ret
ffffffffc020951c:	00004697          	auipc	a3,0x4
ffffffffc0209520:	00c68693          	addi	a3,a3,12 # ffffffffc020d528 <etext+0x1cc8>
ffffffffc0209524:	00002617          	auipc	a2,0x2
ffffffffc0209528:	77460613          	addi	a2,a2,1908 # ffffffffc020bc98 <etext+0x438>
ffffffffc020952c:	45ed                	li	a1,27
ffffffffc020952e:	00005517          	auipc	a0,0x5
ffffffffc0209532:	21a50513          	addi	a0,a0,538 # ffffffffc020e748 <etext+0x2ee8>
ffffffffc0209536:	ec26                	sd	s1,24(sp)
ffffffffc0209538:	f13f60ef          	jal	ffffffffc020044a <__panic>
ffffffffc020953c:	00005697          	auipc	a3,0x5
ffffffffc0209540:	1dc68693          	addi	a3,a3,476 # ffffffffc020e718 <etext+0x2eb8>
ffffffffc0209544:	00002617          	auipc	a2,0x2
ffffffffc0209548:	75460613          	addi	a2,a2,1876 # ffffffffc020bc98 <etext+0x438>
ffffffffc020954c:	45d5                	li	a1,21
ffffffffc020954e:	00005517          	auipc	a0,0x5
ffffffffc0209552:	1fa50513          	addi	a0,a0,506 # ffffffffc020e748 <etext+0x2ee8>
ffffffffc0209556:	f022                	sd	s0,32(sp)
ffffffffc0209558:	ec26                	sd	s1,24(sp)
ffffffffc020955a:	e84a                	sd	s2,16(sp)
ffffffffc020955c:	eeff60ef          	jal	ffffffffc020044a <__panic>

ffffffffc0209560 <sfs_get_root>:
ffffffffc0209560:	1101                	addi	sp,sp,-32
ffffffffc0209562:	ec06                	sd	ra,24(sp)
ffffffffc0209564:	cd09                	beqz	a0,ffffffffc020957e <sfs_get_root+0x1e>
ffffffffc0209566:	0b052783          	lw	a5,176(a0)
ffffffffc020956a:	eb91                	bnez	a5,ffffffffc020957e <sfs_get_root+0x1e>
ffffffffc020956c:	4605                	li	a2,1
ffffffffc020956e:	002c                	addi	a1,sp,8
ffffffffc0209570:	36a010ef          	jal	ffffffffc020a8da <sfs_load_inode>
ffffffffc0209574:	e50d                	bnez	a0,ffffffffc020959e <sfs_get_root+0x3e>
ffffffffc0209576:	60e2                	ld	ra,24(sp)
ffffffffc0209578:	6522                	ld	a0,8(sp)
ffffffffc020957a:	6105                	addi	sp,sp,32
ffffffffc020957c:	8082                	ret
ffffffffc020957e:	00005697          	auipc	a3,0x5
ffffffffc0209582:	19a68693          	addi	a3,a3,410 # ffffffffc020e718 <etext+0x2eb8>
ffffffffc0209586:	00002617          	auipc	a2,0x2
ffffffffc020958a:	71260613          	addi	a2,a2,1810 # ffffffffc020bc98 <etext+0x438>
ffffffffc020958e:	03600593          	li	a1,54
ffffffffc0209592:	00005517          	auipc	a0,0x5
ffffffffc0209596:	1b650513          	addi	a0,a0,438 # ffffffffc020e748 <etext+0x2ee8>
ffffffffc020959a:	eb1f60ef          	jal	ffffffffc020044a <__panic>
ffffffffc020959e:	86aa                	mv	a3,a0
ffffffffc02095a0:	00005617          	auipc	a2,0x5
ffffffffc02095a4:	21860613          	addi	a2,a2,536 # ffffffffc020e7b8 <etext+0x2f58>
ffffffffc02095a8:	03700593          	li	a1,55
ffffffffc02095ac:	00005517          	auipc	a0,0x5
ffffffffc02095b0:	19c50513          	addi	a0,a0,412 # ffffffffc020e748 <etext+0x2ee8>
ffffffffc02095b4:	e97f60ef          	jal	ffffffffc020044a <__panic>

ffffffffc02095b8 <sfs_do_mount>:
ffffffffc02095b8:	7171                	addi	sp,sp,-176
ffffffffc02095ba:	e54e                	sd	s3,136(sp)
ffffffffc02095bc:	00853983          	ld	s3,8(a0)
ffffffffc02095c0:	f506                	sd	ra,168(sp)
ffffffffc02095c2:	6785                	lui	a5,0x1
ffffffffc02095c4:	26f99a63          	bne	s3,a5,ffffffffc0209838 <sfs_do_mount+0x280>
ffffffffc02095c8:	ed26                	sd	s1,152(sp)
ffffffffc02095ca:	84aa                	mv	s1,a0
ffffffffc02095cc:	4501                	li	a0,0
ffffffffc02095ce:	f122                	sd	s0,160(sp)
ffffffffc02095d0:	f4de                	sd	s7,104(sp)
ffffffffc02095d2:	8bae                	mv	s7,a1
ffffffffc02095d4:	ec0fe0ef          	jal	ffffffffc0207c94 <__alloc_fs>
ffffffffc02095d8:	842a                	mv	s0,a0
ffffffffc02095da:	26050663          	beqz	a0,ffffffffc0209846 <sfs_do_mount+0x28e>
ffffffffc02095de:	e152                	sd	s4,128(sp)
ffffffffc02095e0:	0b052a03          	lw	s4,176(a0)
ffffffffc02095e4:	e94a                	sd	s2,144(sp)
ffffffffc02095e6:	280a1763          	bnez	s4,ffffffffc0209874 <sfs_do_mount+0x2bc>
ffffffffc02095ea:	f904                	sd	s1,48(a0)
ffffffffc02095ec:	854e                	mv	a0,s3
ffffffffc02095ee:	9d3f80ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc02095f2:	e428                	sd	a0,72(s0)
ffffffffc02095f4:	892a                	mv	s2,a0
ffffffffc02095f6:	16050863          	beqz	a0,ffffffffc0209766 <sfs_do_mount+0x1ae>
ffffffffc02095fa:	864e                	mv	a2,s3
ffffffffc02095fc:	4681                	li	a3,0
ffffffffc02095fe:	85ca                	mv	a1,s2
ffffffffc0209600:	1008                	addi	a0,sp,32
ffffffffc0209602:	e8bfb0ef          	jal	ffffffffc020548c <iobuf_init>
ffffffffc0209606:	709c                	ld	a5,32(s1)
ffffffffc0209608:	85aa                	mv	a1,a0
ffffffffc020960a:	4601                	li	a2,0
ffffffffc020960c:	8526                	mv	a0,s1
ffffffffc020960e:	9782                	jalr	a5
ffffffffc0209610:	89aa                	mv	s3,a0
ffffffffc0209612:	12051a63          	bnez	a0,ffffffffc0209746 <sfs_do_mount+0x18e>
ffffffffc0209616:	00092583          	lw	a1,0(s2)
ffffffffc020961a:	2f8dc637          	lui	a2,0x2f8dc
ffffffffc020961e:	e2a60613          	addi	a2,a2,-470 # 2f8dbe2a <_binary_bin_sfs_img_size+0x2f866b2a>
ffffffffc0209622:	14c59d63          	bne	a1,a2,ffffffffc020977c <sfs_do_mount+0x1c4>
ffffffffc0209626:	00492783          	lw	a5,4(s2)
ffffffffc020962a:	6090                	ld	a2,0(s1)
ffffffffc020962c:	02079713          	slli	a4,a5,0x20
ffffffffc0209630:	9301                	srli	a4,a4,0x20
ffffffffc0209632:	12e66c63          	bltu	a2,a4,ffffffffc020976a <sfs_do_mount+0x1b2>
ffffffffc0209636:	e4ee                	sd	s11,72(sp)
ffffffffc0209638:	01892503          	lw	a0,24(s2)
ffffffffc020963c:	00892e03          	lw	t3,8(s2)
ffffffffc0209640:	00c92303          	lw	t1,12(s2)
ffffffffc0209644:	01092883          	lw	a7,16(s2)
ffffffffc0209648:	01492803          	lw	a6,20(s2)
ffffffffc020964c:	01c92603          	lw	a2,28(s2)
ffffffffc0209650:	02092683          	lw	a3,32(s2)
ffffffffc0209654:	02492703          	lw	a4,36(s2)
ffffffffc0209658:	020905a3          	sb	zero,43(s2)
ffffffffc020965c:	cc08                	sw	a0,24(s0)
ffffffffc020965e:	01c42423          	sw	t3,8(s0)
ffffffffc0209662:	00642623          	sw	t1,12(s0)
ffffffffc0209666:	01142823          	sw	a7,16(s0)
ffffffffc020966a:	01042a23          	sw	a6,20(s0)
ffffffffc020966e:	cc50                	sw	a2,28(s0)
ffffffffc0209670:	d014                	sw	a3,32(s0)
ffffffffc0209672:	d058                	sw	a4,36(s0)
ffffffffc0209674:	c00c                	sw	a1,0(s0)
ffffffffc0209676:	c05c                	sw	a5,4(s0)
ffffffffc0209678:	02892783          	lw	a5,40(s2)
ffffffffc020967c:	6511                	lui	a0,0x4
ffffffffc020967e:	d41c                	sw	a5,40(s0)
ffffffffc0209680:	941f80ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc0209684:	f448                	sd	a0,168(s0)
ffffffffc0209686:	87aa                	mv	a5,a0
ffffffffc0209688:	8daa                	mv	s11,a0
ffffffffc020968a:	1a050963          	beqz	a0,ffffffffc020983c <sfs_do_mount+0x284>
ffffffffc020968e:	6711                	lui	a4,0x4
ffffffffc0209690:	fcd6                	sd	s5,120(sp)
ffffffffc0209692:	ece6                	sd	s9,88(sp)
ffffffffc0209694:	e8ea                	sd	s10,80(sp)
ffffffffc0209696:	972a                	add	a4,a4,a0
ffffffffc0209698:	e79c                	sd	a5,8(a5)
ffffffffc020969a:	e39c                	sd	a5,0(a5)
ffffffffc020969c:	07c1                	addi	a5,a5,16 # 1010 <_binary_bin_swap_img_size-0x6cf0>
ffffffffc020969e:	fee79de3          	bne	a5,a4,ffffffffc0209698 <sfs_do_mount+0xe0>
ffffffffc02096a2:	00496783          	lwu	a5,4(s2)
ffffffffc02096a6:	6721                	lui	a4,0x8
ffffffffc02096a8:	fff70a93          	addi	s5,a4,-1 # 7fff <_binary_bin_swap_img_size+0x2ff>
ffffffffc02096ac:	97d6                	add	a5,a5,s5
ffffffffc02096ae:	7761                	lui	a4,0xffff8
ffffffffc02096b0:	8ff9                	and	a5,a5,a4
ffffffffc02096b2:	0007851b          	sext.w	a0,a5
ffffffffc02096b6:	00078c9b          	sext.w	s9,a5
ffffffffc02096ba:	a43ff0ef          	jal	ffffffffc02090fc <bitmap_create>
ffffffffc02096be:	fc08                	sd	a0,56(s0)
ffffffffc02096c0:	8d2a                	mv	s10,a0
ffffffffc02096c2:	16050963          	beqz	a0,ffffffffc0209834 <sfs_do_mount+0x27c>
ffffffffc02096c6:	00492783          	lw	a5,4(s2)
ffffffffc02096ca:	082c                	addi	a1,sp,24
ffffffffc02096cc:	e43e                	sd	a5,8(sp)
ffffffffc02096ce:	c65ff0ef          	jal	ffffffffc0209332 <bitmap_getdata>
ffffffffc02096d2:	16050f63          	beqz	a0,ffffffffc0209850 <sfs_do_mount+0x298>
ffffffffc02096d6:	00816783          	lwu	a5,8(sp)
ffffffffc02096da:	66e2                	ld	a3,24(sp)
ffffffffc02096dc:	97d6                	add	a5,a5,s5
ffffffffc02096de:	83bd                	srli	a5,a5,0xf
ffffffffc02096e0:	00c7971b          	slliw	a4,a5,0xc
ffffffffc02096e4:	1702                	slli	a4,a4,0x20
ffffffffc02096e6:	9301                	srli	a4,a4,0x20
ffffffffc02096e8:	16d71463          	bne	a4,a3,ffffffffc0209850 <sfs_do_mount+0x298>
ffffffffc02096ec:	f0e2                	sd	s8,96(sp)
ffffffffc02096ee:	00c79713          	slli	a4,a5,0xc
ffffffffc02096f2:	00e50c33          	add	s8,a0,a4
ffffffffc02096f6:	8aaa                	mv	s5,a0
ffffffffc02096f8:	cbd9                	beqz	a5,ffffffffc020978e <sfs_do_mount+0x1d6>
ffffffffc02096fa:	6789                	lui	a5,0x2
ffffffffc02096fc:	f8da                	sd	s6,112(sp)
ffffffffc02096fe:	40a78b3b          	subw	s6,a5,a0
ffffffffc0209702:	a029                	j	ffffffffc020970c <sfs_do_mount+0x154>
ffffffffc0209704:	6785                	lui	a5,0x1
ffffffffc0209706:	9abe                	add	s5,s5,a5
ffffffffc0209708:	098a8263          	beq	s5,s8,ffffffffc020978c <sfs_do_mount+0x1d4>
ffffffffc020970c:	015b06bb          	addw	a3,s6,s5
ffffffffc0209710:	1682                	slli	a3,a3,0x20
ffffffffc0209712:	6605                	lui	a2,0x1
ffffffffc0209714:	85d6                	mv	a1,s5
ffffffffc0209716:	9281                	srli	a3,a3,0x20
ffffffffc0209718:	1008                	addi	a0,sp,32
ffffffffc020971a:	d73fb0ef          	jal	ffffffffc020548c <iobuf_init>
ffffffffc020971e:	709c                	ld	a5,32(s1)
ffffffffc0209720:	85aa                	mv	a1,a0
ffffffffc0209722:	4601                	li	a2,0
ffffffffc0209724:	8526                	mv	a0,s1
ffffffffc0209726:	9782                	jalr	a5
ffffffffc0209728:	dd71                	beqz	a0,ffffffffc0209704 <sfs_do_mount+0x14c>
ffffffffc020972a:	e42a                	sd	a0,8(sp)
ffffffffc020972c:	856a                	mv	a0,s10
ffffffffc020972e:	bebff0ef          	jal	ffffffffc0209318 <bitmap_destroy>
ffffffffc0209732:	69a2                	ld	s3,8(sp)
ffffffffc0209734:	7b46                	ld	s6,112(sp)
ffffffffc0209736:	7c06                	ld	s8,96(sp)
ffffffffc0209738:	856e                	mv	a0,s11
ffffffffc020973a:	92df80ef          	jal	ffffffffc0202066 <kfree>
ffffffffc020973e:	7ae6                	ld	s5,120(sp)
ffffffffc0209740:	6ce6                	ld	s9,88(sp)
ffffffffc0209742:	6d46                	ld	s10,80(sp)
ffffffffc0209744:	6da6                	ld	s11,72(sp)
ffffffffc0209746:	854a                	mv	a0,s2
ffffffffc0209748:	91ff80ef          	jal	ffffffffc0202066 <kfree>
ffffffffc020974c:	8522                	mv	a0,s0
ffffffffc020974e:	919f80ef          	jal	ffffffffc0202066 <kfree>
ffffffffc0209752:	740a                	ld	s0,160(sp)
ffffffffc0209754:	64ea                	ld	s1,152(sp)
ffffffffc0209756:	694a                	ld	s2,144(sp)
ffffffffc0209758:	6a0a                	ld	s4,128(sp)
ffffffffc020975a:	7ba6                	ld	s7,104(sp)
ffffffffc020975c:	70aa                	ld	ra,168(sp)
ffffffffc020975e:	854e                	mv	a0,s3
ffffffffc0209760:	69aa                	ld	s3,136(sp)
ffffffffc0209762:	614d                	addi	sp,sp,176
ffffffffc0209764:	8082                	ret
ffffffffc0209766:	59f1                	li	s3,-4
ffffffffc0209768:	b7d5                	j	ffffffffc020974c <sfs_do_mount+0x194>
ffffffffc020976a:	85be                	mv	a1,a5
ffffffffc020976c:	00005517          	auipc	a0,0x5
ffffffffc0209770:	0a450513          	addi	a0,a0,164 # ffffffffc020e810 <etext+0x2fb0>
ffffffffc0209774:	a33f60ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0209778:	59f5                	li	s3,-3
ffffffffc020977a:	b7f1                	j	ffffffffc0209746 <sfs_do_mount+0x18e>
ffffffffc020977c:	00005517          	auipc	a0,0x5
ffffffffc0209780:	05c50513          	addi	a0,a0,92 # ffffffffc020e7d8 <etext+0x2f78>
ffffffffc0209784:	a23f60ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc0209788:	59f5                	li	s3,-3
ffffffffc020978a:	bf75                	j	ffffffffc0209746 <sfs_do_mount+0x18e>
ffffffffc020978c:	7b46                	ld	s6,112(sp)
ffffffffc020978e:	00442903          	lw	s2,4(s0)
ffffffffc0209792:	0a0c8863          	beqz	s9,ffffffffc0209842 <sfs_do_mount+0x28a>
ffffffffc0209796:	4481                	li	s1,0
ffffffffc0209798:	85a6                	mv	a1,s1
ffffffffc020979a:	856a                	mv	a0,s10
ffffffffc020979c:	b05ff0ef          	jal	ffffffffc02092a0 <bitmap_test>
ffffffffc02097a0:	c111                	beqz	a0,ffffffffc02097a4 <sfs_do_mount+0x1ec>
ffffffffc02097a2:	2a05                	addiw	s4,s4,1
ffffffffc02097a4:	2485                	addiw	s1,s1,1
ffffffffc02097a6:	fe9c99e3          	bne	s9,s1,ffffffffc0209798 <sfs_do_mount+0x1e0>
ffffffffc02097aa:	441c                	lw	a5,8(s0)
ffffffffc02097ac:	0f479a63          	bne	a5,s4,ffffffffc02098a0 <sfs_do_mount+0x2e8>
ffffffffc02097b0:	05040513          	addi	a0,s0,80
ffffffffc02097b4:	04043023          	sd	zero,64(s0)
ffffffffc02097b8:	4585                	li	a1,1
ffffffffc02097ba:	e33fa0ef          	jal	ffffffffc02045ec <sem_init>
ffffffffc02097be:	06840513          	addi	a0,s0,104
ffffffffc02097c2:	4585                	li	a1,1
ffffffffc02097c4:	e29fa0ef          	jal	ffffffffc02045ec <sem_init>
ffffffffc02097c8:	08040513          	addi	a0,s0,128
ffffffffc02097cc:	4585                	li	a1,1
ffffffffc02097ce:	e1ffa0ef          	jal	ffffffffc02045ec <sem_init>
ffffffffc02097d2:	09840793          	addi	a5,s0,152
ffffffffc02097d6:	4149063b          	subw	a2,s2,s4
ffffffffc02097da:	f05c                	sd	a5,160(s0)
ffffffffc02097dc:	ec5c                	sd	a5,152(s0)
ffffffffc02097de:	874a                	mv	a4,s2
ffffffffc02097e0:	86d2                	mv	a3,s4
ffffffffc02097e2:	00c40593          	addi	a1,s0,12
ffffffffc02097e6:	00005517          	auipc	a0,0x5
ffffffffc02097ea:	0ba50513          	addi	a0,a0,186 # ffffffffc020e8a0 <etext+0x3040>
ffffffffc02097ee:	9b9f60ef          	jal	ffffffffc02001a6 <cprintf>
ffffffffc02097f2:	00000617          	auipc	a2,0x0
ffffffffc02097f6:	c9260613          	addi	a2,a2,-878 # ffffffffc0209484 <sfs_sync>
ffffffffc02097fa:	00000697          	auipc	a3,0x0
ffffffffc02097fe:	d6668693          	addi	a3,a3,-666 # ffffffffc0209560 <sfs_get_root>
ffffffffc0209802:	00000717          	auipc	a4,0x0
ffffffffc0209806:	b6e70713          	addi	a4,a4,-1170 # ffffffffc0209370 <sfs_unmount>
ffffffffc020980a:	00000797          	auipc	a5,0x0
ffffffffc020980e:	bea78793          	addi	a5,a5,-1046 # ffffffffc02093f4 <sfs_cleanup>
ffffffffc0209812:	fc50                	sd	a2,184(s0)
ffffffffc0209814:	e074                	sd	a3,192(s0)
ffffffffc0209816:	e478                	sd	a4,200(s0)
ffffffffc0209818:	e87c                	sd	a5,208(s0)
ffffffffc020981a:	008bb023          	sd	s0,0(s7)
ffffffffc020981e:	64ea                	ld	s1,152(sp)
ffffffffc0209820:	740a                	ld	s0,160(sp)
ffffffffc0209822:	694a                	ld	s2,144(sp)
ffffffffc0209824:	6a0a                	ld	s4,128(sp)
ffffffffc0209826:	7ae6                	ld	s5,120(sp)
ffffffffc0209828:	7ba6                	ld	s7,104(sp)
ffffffffc020982a:	7c06                	ld	s8,96(sp)
ffffffffc020982c:	6ce6                	ld	s9,88(sp)
ffffffffc020982e:	6d46                	ld	s10,80(sp)
ffffffffc0209830:	6da6                	ld	s11,72(sp)
ffffffffc0209832:	b72d                	j	ffffffffc020975c <sfs_do_mount+0x1a4>
ffffffffc0209834:	59f1                	li	s3,-4
ffffffffc0209836:	b709                	j	ffffffffc0209738 <sfs_do_mount+0x180>
ffffffffc0209838:	59c9                	li	s3,-14
ffffffffc020983a:	b70d                	j	ffffffffc020975c <sfs_do_mount+0x1a4>
ffffffffc020983c:	6da6                	ld	s11,72(sp)
ffffffffc020983e:	59f1                	li	s3,-4
ffffffffc0209840:	b719                	j	ffffffffc0209746 <sfs_do_mount+0x18e>
ffffffffc0209842:	4a01                	li	s4,0
ffffffffc0209844:	b79d                	j	ffffffffc02097aa <sfs_do_mount+0x1f2>
ffffffffc0209846:	740a                	ld	s0,160(sp)
ffffffffc0209848:	64ea                	ld	s1,152(sp)
ffffffffc020984a:	7ba6                	ld	s7,104(sp)
ffffffffc020984c:	59f1                	li	s3,-4
ffffffffc020984e:	b739                	j	ffffffffc020975c <sfs_do_mount+0x1a4>
ffffffffc0209850:	00005697          	auipc	a3,0x5
ffffffffc0209854:	ff068693          	addi	a3,a3,-16 # ffffffffc020e840 <etext+0x2fe0>
ffffffffc0209858:	00002617          	auipc	a2,0x2
ffffffffc020985c:	44060613          	addi	a2,a2,1088 # ffffffffc020bc98 <etext+0x438>
ffffffffc0209860:	08300593          	li	a1,131
ffffffffc0209864:	00005517          	auipc	a0,0x5
ffffffffc0209868:	ee450513          	addi	a0,a0,-284 # ffffffffc020e748 <etext+0x2ee8>
ffffffffc020986c:	f8da                	sd	s6,112(sp)
ffffffffc020986e:	f0e2                	sd	s8,96(sp)
ffffffffc0209870:	bdbf60ef          	jal	ffffffffc020044a <__panic>
ffffffffc0209874:	00005697          	auipc	a3,0x5
ffffffffc0209878:	ea468693          	addi	a3,a3,-348 # ffffffffc020e718 <etext+0x2eb8>
ffffffffc020987c:	00002617          	auipc	a2,0x2
ffffffffc0209880:	41c60613          	addi	a2,a2,1052 # ffffffffc020bc98 <etext+0x438>
ffffffffc0209884:	0a300593          	li	a1,163
ffffffffc0209888:	00005517          	auipc	a0,0x5
ffffffffc020988c:	ec050513          	addi	a0,a0,-320 # ffffffffc020e748 <etext+0x2ee8>
ffffffffc0209890:	fcd6                	sd	s5,120(sp)
ffffffffc0209892:	f8da                	sd	s6,112(sp)
ffffffffc0209894:	f0e2                	sd	s8,96(sp)
ffffffffc0209896:	ece6                	sd	s9,88(sp)
ffffffffc0209898:	e8ea                	sd	s10,80(sp)
ffffffffc020989a:	e4ee                	sd	s11,72(sp)
ffffffffc020989c:	baff60ef          	jal	ffffffffc020044a <__panic>
ffffffffc02098a0:	00005697          	auipc	a3,0x5
ffffffffc02098a4:	fd068693          	addi	a3,a3,-48 # ffffffffc020e870 <etext+0x3010>
ffffffffc02098a8:	00002617          	auipc	a2,0x2
ffffffffc02098ac:	3f060613          	addi	a2,a2,1008 # ffffffffc020bc98 <etext+0x438>
ffffffffc02098b0:	0e000593          	li	a1,224
ffffffffc02098b4:	00005517          	auipc	a0,0x5
ffffffffc02098b8:	e9450513          	addi	a0,a0,-364 # ffffffffc020e748 <etext+0x2ee8>
ffffffffc02098bc:	f8da                	sd	s6,112(sp)
ffffffffc02098be:	b8df60ef          	jal	ffffffffc020044a <__panic>

ffffffffc02098c2 <sfs_mount>:
ffffffffc02098c2:	00000597          	auipc	a1,0x0
ffffffffc02098c6:	cf658593          	addi	a1,a1,-778 # ffffffffc02095b8 <sfs_do_mount>
ffffffffc02098ca:	fccfe06f          	j	ffffffffc0208096 <vfs_mount>

ffffffffc02098ce <sfs_opendir>:
ffffffffc02098ce:	0235f593          	andi	a1,a1,35
ffffffffc02098d2:	e199                	bnez	a1,ffffffffc02098d8 <sfs_opendir+0xa>
ffffffffc02098d4:	4501                	li	a0,0
ffffffffc02098d6:	8082                	ret
ffffffffc02098d8:	553d                	li	a0,-17
ffffffffc02098da:	8082                	ret

ffffffffc02098dc <sfs_openfile>:
ffffffffc02098dc:	4501                	li	a0,0
ffffffffc02098de:	8082                	ret

ffffffffc02098e0 <sfs_gettype>:
ffffffffc02098e0:	1141                	addi	sp,sp,-16
ffffffffc02098e2:	e406                	sd	ra,8(sp)
ffffffffc02098e4:	c529                	beqz	a0,ffffffffc020992e <sfs_gettype+0x4e>
ffffffffc02098e6:	4d38                	lw	a4,88(a0)
ffffffffc02098e8:	6785                	lui	a5,0x1
ffffffffc02098ea:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc02098ee:	04f71063          	bne	a4,a5,ffffffffc020992e <sfs_gettype+0x4e>
ffffffffc02098f2:	6118                	ld	a4,0(a0)
ffffffffc02098f4:	4789                	li	a5,2
ffffffffc02098f6:	00475683          	lhu	a3,4(a4)
ffffffffc02098fa:	02f68463          	beq	a3,a5,ffffffffc0209922 <sfs_gettype+0x42>
ffffffffc02098fe:	478d                	li	a5,3
ffffffffc0209900:	00f68b63          	beq	a3,a5,ffffffffc0209916 <sfs_gettype+0x36>
ffffffffc0209904:	4705                	li	a4,1
ffffffffc0209906:	6785                	lui	a5,0x1
ffffffffc0209908:	04e69363          	bne	a3,a4,ffffffffc020994e <sfs_gettype+0x6e>
ffffffffc020990c:	60a2                	ld	ra,8(sp)
ffffffffc020990e:	c19c                	sw	a5,0(a1)
ffffffffc0209910:	4501                	li	a0,0
ffffffffc0209912:	0141                	addi	sp,sp,16
ffffffffc0209914:	8082                	ret
ffffffffc0209916:	60a2                	ld	ra,8(sp)
ffffffffc0209918:	678d                	lui	a5,0x3
ffffffffc020991a:	c19c                	sw	a5,0(a1)
ffffffffc020991c:	4501                	li	a0,0
ffffffffc020991e:	0141                	addi	sp,sp,16
ffffffffc0209920:	8082                	ret
ffffffffc0209922:	60a2                	ld	ra,8(sp)
ffffffffc0209924:	6789                	lui	a5,0x2
ffffffffc0209926:	c19c                	sw	a5,0(a1)
ffffffffc0209928:	4501                	li	a0,0
ffffffffc020992a:	0141                	addi	sp,sp,16
ffffffffc020992c:	8082                	ret
ffffffffc020992e:	00005697          	auipc	a3,0x5
ffffffffc0209932:	f9268693          	addi	a3,a3,-110 # ffffffffc020e8c0 <etext+0x3060>
ffffffffc0209936:	00002617          	auipc	a2,0x2
ffffffffc020993a:	36260613          	addi	a2,a2,866 # ffffffffc020bc98 <etext+0x438>
ffffffffc020993e:	37b00593          	li	a1,891
ffffffffc0209942:	00005517          	auipc	a0,0x5
ffffffffc0209946:	fb650513          	addi	a0,a0,-74 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020994a:	b01f60ef          	jal	ffffffffc020044a <__panic>
ffffffffc020994e:	00005617          	auipc	a2,0x5
ffffffffc0209952:	fc260613          	addi	a2,a2,-62 # ffffffffc020e910 <etext+0x30b0>
ffffffffc0209956:	38700593          	li	a1,903
ffffffffc020995a:	00005517          	auipc	a0,0x5
ffffffffc020995e:	f9e50513          	addi	a0,a0,-98 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc0209962:	ae9f60ef          	jal	ffffffffc020044a <__panic>

ffffffffc0209966 <sfs_fsync>:
ffffffffc0209966:	7530                	ld	a2,104(a0)
ffffffffc0209968:	7179                	addi	sp,sp,-48
ffffffffc020996a:	f406                	sd	ra,40(sp)
ffffffffc020996c:	ca2d                	beqz	a2,ffffffffc02099de <sfs_fsync+0x78>
ffffffffc020996e:	0b062703          	lw	a4,176(a2)
ffffffffc0209972:	e735                	bnez	a4,ffffffffc02099de <sfs_fsync+0x78>
ffffffffc0209974:	4d34                	lw	a3,88(a0)
ffffffffc0209976:	6705                	lui	a4,0x1
ffffffffc0209978:	23570713          	addi	a4,a4,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020997c:	08e69263          	bne	a3,a4,ffffffffc0209a00 <sfs_fsync+0x9a>
ffffffffc0209980:	6914                	ld	a3,16(a0)
ffffffffc0209982:	4701                	li	a4,0
ffffffffc0209984:	e689                	bnez	a3,ffffffffc020998e <sfs_fsync+0x28>
ffffffffc0209986:	70a2                	ld	ra,40(sp)
ffffffffc0209988:	853a                	mv	a0,a4
ffffffffc020998a:	6145                	addi	sp,sp,48
ffffffffc020998c:	8082                	ret
ffffffffc020998e:	f022                	sd	s0,32(sp)
ffffffffc0209990:	e42a                	sd	a0,8(sp)
ffffffffc0209992:	02050413          	addi	s0,a0,32
ffffffffc0209996:	02050513          	addi	a0,a0,32
ffffffffc020999a:	ec3a                	sd	a4,24(sp)
ffffffffc020999c:	e832                	sd	a2,16(sp)
ffffffffc020999e:	c59fa0ef          	jal	ffffffffc02045f6 <down>
ffffffffc02099a2:	67a2                	ld	a5,8(sp)
ffffffffc02099a4:	6762                	ld	a4,24(sp)
ffffffffc02099a6:	6b94                	ld	a3,16(a5)
ffffffffc02099a8:	ea99                	bnez	a3,ffffffffc02099be <sfs_fsync+0x58>
ffffffffc02099aa:	8522                	mv	a0,s0
ffffffffc02099ac:	e43a                	sd	a4,8(sp)
ffffffffc02099ae:	c45fa0ef          	jal	ffffffffc02045f2 <up>
ffffffffc02099b2:	6722                	ld	a4,8(sp)
ffffffffc02099b4:	7402                	ld	s0,32(sp)
ffffffffc02099b6:	70a2                	ld	ra,40(sp)
ffffffffc02099b8:	853a                	mv	a0,a4
ffffffffc02099ba:	6145                	addi	sp,sp,48
ffffffffc02099bc:	8082                	ret
ffffffffc02099be:	4794                	lw	a3,8(a5)
ffffffffc02099c0:	638c                	ld	a1,0(a5)
ffffffffc02099c2:	6542                	ld	a0,16(sp)
ffffffffc02099c4:	4701                	li	a4,0
ffffffffc02099c6:	0007b823          	sd	zero,16(a5) # 2010 <_binary_bin_swap_img_size-0x5cf0>
ffffffffc02099ca:	04000613          	li	a2,64
ffffffffc02099ce:	71a010ef          	jal	ffffffffc020b0e8 <sfs_wbuf>
ffffffffc02099d2:	872a                	mv	a4,a0
ffffffffc02099d4:	d979                	beqz	a0,ffffffffc02099aa <sfs_fsync+0x44>
ffffffffc02099d6:	67a2                	ld	a5,8(sp)
ffffffffc02099d8:	4685                	li	a3,1
ffffffffc02099da:	eb94                	sd	a3,16(a5)
ffffffffc02099dc:	b7f9                	j	ffffffffc02099aa <sfs_fsync+0x44>
ffffffffc02099de:	00005697          	auipc	a3,0x5
ffffffffc02099e2:	d3a68693          	addi	a3,a3,-710 # ffffffffc020e718 <etext+0x2eb8>
ffffffffc02099e6:	00002617          	auipc	a2,0x2
ffffffffc02099ea:	2b260613          	addi	a2,a2,690 # ffffffffc020bc98 <etext+0x438>
ffffffffc02099ee:	2bf00593          	li	a1,703
ffffffffc02099f2:	00005517          	auipc	a0,0x5
ffffffffc02099f6:	f0650513          	addi	a0,a0,-250 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc02099fa:	f022                	sd	s0,32(sp)
ffffffffc02099fc:	a4ff60ef          	jal	ffffffffc020044a <__panic>
ffffffffc0209a00:	00005697          	auipc	a3,0x5
ffffffffc0209a04:	ec068693          	addi	a3,a3,-320 # ffffffffc020e8c0 <etext+0x3060>
ffffffffc0209a08:	00002617          	auipc	a2,0x2
ffffffffc0209a0c:	29060613          	addi	a2,a2,656 # ffffffffc020bc98 <etext+0x438>
ffffffffc0209a10:	2c000593          	li	a1,704
ffffffffc0209a14:	00005517          	auipc	a0,0x5
ffffffffc0209a18:	ee450513          	addi	a0,a0,-284 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc0209a1c:	f022                	sd	s0,32(sp)
ffffffffc0209a1e:	a2df60ef          	jal	ffffffffc020044a <__panic>

ffffffffc0209a22 <sfs_fstat>:
ffffffffc0209a22:	1101                	addi	sp,sp,-32
ffffffffc0209a24:	e822                	sd	s0,16(sp)
ffffffffc0209a26:	e426                	sd	s1,8(sp)
ffffffffc0209a28:	842a                	mv	s0,a0
ffffffffc0209a2a:	84ae                	mv	s1,a1
ffffffffc0209a2c:	852e                	mv	a0,a1
ffffffffc0209a2e:	02000613          	li	a2,32
ffffffffc0209a32:	4581                	li	a1,0
ffffffffc0209a34:	ec06                	sd	ra,24(sp)
ffffffffc0209a36:	5c3010ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc0209a3a:	c439                	beqz	s0,ffffffffc0209a88 <sfs_fstat+0x66>
ffffffffc0209a3c:	783c                	ld	a5,112(s0)
ffffffffc0209a3e:	c7a9                	beqz	a5,ffffffffc0209a88 <sfs_fstat+0x66>
ffffffffc0209a40:	6bbc                	ld	a5,80(a5)
ffffffffc0209a42:	c3b9                	beqz	a5,ffffffffc0209a88 <sfs_fstat+0x66>
ffffffffc0209a44:	00005597          	auipc	a1,0x5
ffffffffc0209a48:	8e458593          	addi	a1,a1,-1820 # ffffffffc020e328 <etext+0x2ac8>
ffffffffc0209a4c:	8522                	mv	a0,s0
ffffffffc0209a4e:	85afe0ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc0209a52:	783c                	ld	a5,112(s0)
ffffffffc0209a54:	85a6                	mv	a1,s1
ffffffffc0209a56:	8522                	mv	a0,s0
ffffffffc0209a58:	6bbc                	ld	a5,80(a5)
ffffffffc0209a5a:	9782                	jalr	a5
ffffffffc0209a5c:	e10d                	bnez	a0,ffffffffc0209a7e <sfs_fstat+0x5c>
ffffffffc0209a5e:	4c38                	lw	a4,88(s0)
ffffffffc0209a60:	6785                	lui	a5,0x1
ffffffffc0209a62:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc0209a66:	04f71163          	bne	a4,a5,ffffffffc0209aa8 <sfs_fstat+0x86>
ffffffffc0209a6a:	601c                	ld	a5,0(s0)
ffffffffc0209a6c:	0067d683          	lhu	a3,6(a5)
ffffffffc0209a70:	0087e703          	lwu	a4,8(a5)
ffffffffc0209a74:	0007e783          	lwu	a5,0(a5)
ffffffffc0209a78:	e494                	sd	a3,8(s1)
ffffffffc0209a7a:	e898                	sd	a4,16(s1)
ffffffffc0209a7c:	ec9c                	sd	a5,24(s1)
ffffffffc0209a7e:	60e2                	ld	ra,24(sp)
ffffffffc0209a80:	6442                	ld	s0,16(sp)
ffffffffc0209a82:	64a2                	ld	s1,8(sp)
ffffffffc0209a84:	6105                	addi	sp,sp,32
ffffffffc0209a86:	8082                	ret
ffffffffc0209a88:	00005697          	auipc	a3,0x5
ffffffffc0209a8c:	83868693          	addi	a3,a3,-1992 # ffffffffc020e2c0 <etext+0x2a60>
ffffffffc0209a90:	00002617          	auipc	a2,0x2
ffffffffc0209a94:	20860613          	addi	a2,a2,520 # ffffffffc020bc98 <etext+0x438>
ffffffffc0209a98:	2b000593          	li	a1,688
ffffffffc0209a9c:	00005517          	auipc	a0,0x5
ffffffffc0209aa0:	e5c50513          	addi	a0,a0,-420 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc0209aa4:	9a7f60ef          	jal	ffffffffc020044a <__panic>
ffffffffc0209aa8:	00005697          	auipc	a3,0x5
ffffffffc0209aac:	e1868693          	addi	a3,a3,-488 # ffffffffc020e8c0 <etext+0x3060>
ffffffffc0209ab0:	00002617          	auipc	a2,0x2
ffffffffc0209ab4:	1e860613          	addi	a2,a2,488 # ffffffffc020bc98 <etext+0x438>
ffffffffc0209ab8:	2b300593          	li	a1,691
ffffffffc0209abc:	00005517          	auipc	a0,0x5
ffffffffc0209ac0:	e3c50513          	addi	a0,a0,-452 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc0209ac4:	987f60ef          	jal	ffffffffc020044a <__panic>

ffffffffc0209ac8 <sfs_tryseek>:
ffffffffc0209ac8:	08000737          	lui	a4,0x8000
ffffffffc0209acc:	04e5f863          	bgeu	a1,a4,ffffffffc0209b1c <sfs_tryseek+0x54>
ffffffffc0209ad0:	1101                	addi	sp,sp,-32
ffffffffc0209ad2:	ec06                	sd	ra,24(sp)
ffffffffc0209ad4:	c531                	beqz	a0,ffffffffc0209b20 <sfs_tryseek+0x58>
ffffffffc0209ad6:	4d30                	lw	a2,88(a0)
ffffffffc0209ad8:	6685                	lui	a3,0x1
ffffffffc0209ada:	23568693          	addi	a3,a3,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc0209ade:	04d61163          	bne	a2,a3,ffffffffc0209b20 <sfs_tryseek+0x58>
ffffffffc0209ae2:	6114                	ld	a3,0(a0)
ffffffffc0209ae4:	0006e683          	lwu	a3,0(a3)
ffffffffc0209ae8:	02b6d663          	bge	a3,a1,ffffffffc0209b14 <sfs_tryseek+0x4c>
ffffffffc0209aec:	7934                	ld	a3,112(a0)
ffffffffc0209aee:	caa9                	beqz	a3,ffffffffc0209b40 <sfs_tryseek+0x78>
ffffffffc0209af0:	72b4                	ld	a3,96(a3)
ffffffffc0209af2:	c6b9                	beqz	a3,ffffffffc0209b40 <sfs_tryseek+0x78>
ffffffffc0209af4:	e02e                	sd	a1,0(sp)
ffffffffc0209af6:	00004597          	auipc	a1,0x4
ffffffffc0209afa:	72258593          	addi	a1,a1,1826 # ffffffffc020e218 <etext+0x29b8>
ffffffffc0209afe:	e42a                	sd	a0,8(sp)
ffffffffc0209b00:	fa9fd0ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc0209b04:	67a2                	ld	a5,8(sp)
ffffffffc0209b06:	6582                	ld	a1,0(sp)
ffffffffc0209b08:	60e2                	ld	ra,24(sp)
ffffffffc0209b0a:	7bb4                	ld	a3,112(a5)
ffffffffc0209b0c:	853e                	mv	a0,a5
ffffffffc0209b0e:	72bc                	ld	a5,96(a3)
ffffffffc0209b10:	6105                	addi	sp,sp,32
ffffffffc0209b12:	8782                	jr	a5
ffffffffc0209b14:	60e2                	ld	ra,24(sp)
ffffffffc0209b16:	4501                	li	a0,0
ffffffffc0209b18:	6105                	addi	sp,sp,32
ffffffffc0209b1a:	8082                	ret
ffffffffc0209b1c:	5575                	li	a0,-3
ffffffffc0209b1e:	8082                	ret
ffffffffc0209b20:	00005697          	auipc	a3,0x5
ffffffffc0209b24:	da068693          	addi	a3,a3,-608 # ffffffffc020e8c0 <etext+0x3060>
ffffffffc0209b28:	00002617          	auipc	a2,0x2
ffffffffc0209b2c:	17060613          	addi	a2,a2,368 # ffffffffc020bc98 <etext+0x438>
ffffffffc0209b30:	39200593          	li	a1,914
ffffffffc0209b34:	00005517          	auipc	a0,0x5
ffffffffc0209b38:	dc450513          	addi	a0,a0,-572 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc0209b3c:	90ff60ef          	jal	ffffffffc020044a <__panic>
ffffffffc0209b40:	00004697          	auipc	a3,0x4
ffffffffc0209b44:	68068693          	addi	a3,a3,1664 # ffffffffc020e1c0 <etext+0x2960>
ffffffffc0209b48:	00002617          	auipc	a2,0x2
ffffffffc0209b4c:	15060613          	addi	a2,a2,336 # ffffffffc020bc98 <etext+0x438>
ffffffffc0209b50:	39400593          	li	a1,916
ffffffffc0209b54:	00005517          	auipc	a0,0x5
ffffffffc0209b58:	da450513          	addi	a0,a0,-604 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc0209b5c:	8eff60ef          	jal	ffffffffc020044a <__panic>

ffffffffc0209b60 <sfs_close>:
ffffffffc0209b60:	1141                	addi	sp,sp,-16
ffffffffc0209b62:	e406                	sd	ra,8(sp)
ffffffffc0209b64:	e022                	sd	s0,0(sp)
ffffffffc0209b66:	c11d                	beqz	a0,ffffffffc0209b8c <sfs_close+0x2c>
ffffffffc0209b68:	793c                	ld	a5,112(a0)
ffffffffc0209b6a:	842a                	mv	s0,a0
ffffffffc0209b6c:	c385                	beqz	a5,ffffffffc0209b8c <sfs_close+0x2c>
ffffffffc0209b6e:	7b9c                	ld	a5,48(a5)
ffffffffc0209b70:	cf91                	beqz	a5,ffffffffc0209b8c <sfs_close+0x2c>
ffffffffc0209b72:	00004597          	auipc	a1,0x4
ffffffffc0209b76:	a0658593          	addi	a1,a1,-1530 # ffffffffc020d578 <etext+0x1d18>
ffffffffc0209b7a:	f2ffd0ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc0209b7e:	783c                	ld	a5,112(s0)
ffffffffc0209b80:	8522                	mv	a0,s0
ffffffffc0209b82:	6402                	ld	s0,0(sp)
ffffffffc0209b84:	60a2                	ld	ra,8(sp)
ffffffffc0209b86:	7b9c                	ld	a5,48(a5)
ffffffffc0209b88:	0141                	addi	sp,sp,16
ffffffffc0209b8a:	8782                	jr	a5
ffffffffc0209b8c:	00004697          	auipc	a3,0x4
ffffffffc0209b90:	99c68693          	addi	a3,a3,-1636 # ffffffffc020d528 <etext+0x1cc8>
ffffffffc0209b94:	00002617          	auipc	a2,0x2
ffffffffc0209b98:	10460613          	addi	a2,a2,260 # ffffffffc020bc98 <etext+0x438>
ffffffffc0209b9c:	21c00593          	li	a1,540
ffffffffc0209ba0:	00005517          	auipc	a0,0x5
ffffffffc0209ba4:	d5850513          	addi	a0,a0,-680 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc0209ba8:	8a3f60ef          	jal	ffffffffc020044a <__panic>

ffffffffc0209bac <sfs_io.part.0>:
ffffffffc0209bac:	1141                	addi	sp,sp,-16
ffffffffc0209bae:	00005697          	auipc	a3,0x5
ffffffffc0209bb2:	d1268693          	addi	a3,a3,-750 # ffffffffc020e8c0 <etext+0x3060>
ffffffffc0209bb6:	00002617          	auipc	a2,0x2
ffffffffc0209bba:	0e260613          	addi	a2,a2,226 # ffffffffc020bc98 <etext+0x438>
ffffffffc0209bbe:	28f00593          	li	a1,655
ffffffffc0209bc2:	00005517          	auipc	a0,0x5
ffffffffc0209bc6:	d3650513          	addi	a0,a0,-714 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc0209bca:	e406                	sd	ra,8(sp)
ffffffffc0209bcc:	87ff60ef          	jal	ffffffffc020044a <__panic>

ffffffffc0209bd0 <sfs_block_free>:
ffffffffc0209bd0:	1101                	addi	sp,sp,-32
ffffffffc0209bd2:	e822                	sd	s0,16(sp)
ffffffffc0209bd4:	e426                	sd	s1,8(sp)
ffffffffc0209bd6:	ec06                	sd	ra,24(sp)
ffffffffc0209bd8:	84ae                	mv	s1,a1
ffffffffc0209bda:	842a                	mv	s0,a0
ffffffffc0209bdc:	c595                	beqz	a1,ffffffffc0209c08 <sfs_block_free+0x38>
ffffffffc0209bde:	415c                	lw	a5,4(a0)
ffffffffc0209be0:	02f5f463          	bgeu	a1,a5,ffffffffc0209c08 <sfs_block_free+0x38>
ffffffffc0209be4:	7d08                	ld	a0,56(a0)
ffffffffc0209be6:	ebaff0ef          	jal	ffffffffc02092a0 <bitmap_test>
ffffffffc0209bea:	ed0d                	bnez	a0,ffffffffc0209c24 <sfs_block_free+0x54>
ffffffffc0209bec:	7c08                	ld	a0,56(s0)
ffffffffc0209bee:	85a6                	mv	a1,s1
ffffffffc0209bf0:	ed8ff0ef          	jal	ffffffffc02092c8 <bitmap_free>
ffffffffc0209bf4:	441c                	lw	a5,8(s0)
ffffffffc0209bf6:	4705                	li	a4,1
ffffffffc0209bf8:	60e2                	ld	ra,24(sp)
ffffffffc0209bfa:	2785                	addiw	a5,a5,1
ffffffffc0209bfc:	e038                	sd	a4,64(s0)
ffffffffc0209bfe:	c41c                	sw	a5,8(s0)
ffffffffc0209c00:	6442                	ld	s0,16(sp)
ffffffffc0209c02:	64a2                	ld	s1,8(sp)
ffffffffc0209c04:	6105                	addi	sp,sp,32
ffffffffc0209c06:	8082                	ret
ffffffffc0209c08:	4054                	lw	a3,4(s0)
ffffffffc0209c0a:	8726                	mv	a4,s1
ffffffffc0209c0c:	00005617          	auipc	a2,0x5
ffffffffc0209c10:	d1c60613          	addi	a2,a2,-740 # ffffffffc020e928 <etext+0x30c8>
ffffffffc0209c14:	05300593          	li	a1,83
ffffffffc0209c18:	00005517          	auipc	a0,0x5
ffffffffc0209c1c:	ce050513          	addi	a0,a0,-800 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc0209c20:	82bf60ef          	jal	ffffffffc020044a <__panic>
ffffffffc0209c24:	00005697          	auipc	a3,0x5
ffffffffc0209c28:	d3c68693          	addi	a3,a3,-708 # ffffffffc020e960 <etext+0x3100>
ffffffffc0209c2c:	00002617          	auipc	a2,0x2
ffffffffc0209c30:	06c60613          	addi	a2,a2,108 # ffffffffc020bc98 <etext+0x438>
ffffffffc0209c34:	06a00593          	li	a1,106
ffffffffc0209c38:	00005517          	auipc	a0,0x5
ffffffffc0209c3c:	cc050513          	addi	a0,a0,-832 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc0209c40:	80bf60ef          	jal	ffffffffc020044a <__panic>

ffffffffc0209c44 <sfs_reclaim>:
ffffffffc0209c44:	1101                	addi	sp,sp,-32
ffffffffc0209c46:	e426                	sd	s1,8(sp)
ffffffffc0209c48:	7524                	ld	s1,104(a0)
ffffffffc0209c4a:	ec06                	sd	ra,24(sp)
ffffffffc0209c4c:	e822                	sd	s0,16(sp)
ffffffffc0209c4e:	e04a                	sd	s2,0(sp)
ffffffffc0209c50:	0e048963          	beqz	s1,ffffffffc0209d42 <sfs_reclaim+0xfe>
ffffffffc0209c54:	0b04a783          	lw	a5,176(s1)
ffffffffc0209c58:	0e079563          	bnez	a5,ffffffffc0209d42 <sfs_reclaim+0xfe>
ffffffffc0209c5c:	4d38                	lw	a4,88(a0)
ffffffffc0209c5e:	6785                	lui	a5,0x1
ffffffffc0209c60:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc0209c64:	842a                	mv	s0,a0
ffffffffc0209c66:	10f71e63          	bne	a4,a5,ffffffffc0209d82 <sfs_reclaim+0x13e>
ffffffffc0209c6a:	8526                	mv	a0,s1
ffffffffc0209c6c:	630010ef          	jal	ffffffffc020b29c <lock_sfs_fs>
ffffffffc0209c70:	4c1c                	lw	a5,24(s0)
ffffffffc0209c72:	0ef05863          	blez	a5,ffffffffc0209d62 <sfs_reclaim+0x11e>
ffffffffc0209c76:	37fd                	addiw	a5,a5,-1
ffffffffc0209c78:	cc1c                	sw	a5,24(s0)
ffffffffc0209c7a:	ebd9                	bnez	a5,ffffffffc0209d10 <sfs_reclaim+0xcc>
ffffffffc0209c7c:	05c42903          	lw	s2,92(s0)
ffffffffc0209c80:	08091863          	bnez	s2,ffffffffc0209d10 <sfs_reclaim+0xcc>
ffffffffc0209c84:	601c                	ld	a5,0(s0)
ffffffffc0209c86:	0067d783          	lhu	a5,6(a5)
ffffffffc0209c8a:	e785                	bnez	a5,ffffffffc0209cb2 <sfs_reclaim+0x6e>
ffffffffc0209c8c:	783c                	ld	a5,112(s0)
ffffffffc0209c8e:	10078a63          	beqz	a5,ffffffffc0209da2 <sfs_reclaim+0x15e>
ffffffffc0209c92:	73bc                	ld	a5,96(a5)
ffffffffc0209c94:	10078763          	beqz	a5,ffffffffc0209da2 <sfs_reclaim+0x15e>
ffffffffc0209c98:	00004597          	auipc	a1,0x4
ffffffffc0209c9c:	58058593          	addi	a1,a1,1408 # ffffffffc020e218 <etext+0x29b8>
ffffffffc0209ca0:	8522                	mv	a0,s0
ffffffffc0209ca2:	e07fd0ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc0209ca6:	783c                	ld	a5,112(s0)
ffffffffc0209ca8:	8522                	mv	a0,s0
ffffffffc0209caa:	4581                	li	a1,0
ffffffffc0209cac:	73bc                	ld	a5,96(a5)
ffffffffc0209cae:	9782                	jalr	a5
ffffffffc0209cb0:	e559                	bnez	a0,ffffffffc0209d3e <sfs_reclaim+0xfa>
ffffffffc0209cb2:	681c                	ld	a5,16(s0)
ffffffffc0209cb4:	c39d                	beqz	a5,ffffffffc0209cda <sfs_reclaim+0x96>
ffffffffc0209cb6:	783c                	ld	a5,112(s0)
ffffffffc0209cb8:	10078563          	beqz	a5,ffffffffc0209dc2 <sfs_reclaim+0x17e>
ffffffffc0209cbc:	7b9c                	ld	a5,48(a5)
ffffffffc0209cbe:	10078263          	beqz	a5,ffffffffc0209dc2 <sfs_reclaim+0x17e>
ffffffffc0209cc2:	8522                	mv	a0,s0
ffffffffc0209cc4:	00004597          	auipc	a1,0x4
ffffffffc0209cc8:	8b458593          	addi	a1,a1,-1868 # ffffffffc020d578 <etext+0x1d18>
ffffffffc0209ccc:	dddfd0ef          	jal	ffffffffc0207aa8 <inode_check>
ffffffffc0209cd0:	783c                	ld	a5,112(s0)
ffffffffc0209cd2:	8522                	mv	a0,s0
ffffffffc0209cd4:	7b9c                	ld	a5,48(a5)
ffffffffc0209cd6:	9782                	jalr	a5
ffffffffc0209cd8:	e13d                	bnez	a0,ffffffffc0209d3e <sfs_reclaim+0xfa>
ffffffffc0209cda:	7c18                	ld	a4,56(s0)
ffffffffc0209cdc:	603c                	ld	a5,64(s0)
ffffffffc0209cde:	8526                	mv	a0,s1
ffffffffc0209ce0:	e71c                	sd	a5,8(a4)
ffffffffc0209ce2:	e398                	sd	a4,0(a5)
ffffffffc0209ce4:	6438                	ld	a4,72(s0)
ffffffffc0209ce6:	683c                	ld	a5,80(s0)
ffffffffc0209ce8:	e71c                	sd	a5,8(a4)
ffffffffc0209cea:	e398                	sd	a4,0(a5)
ffffffffc0209cec:	5c0010ef          	jal	ffffffffc020b2ac <unlock_sfs_fs>
ffffffffc0209cf0:	6008                	ld	a0,0(s0)
ffffffffc0209cf2:	00655783          	lhu	a5,6(a0)
ffffffffc0209cf6:	cb85                	beqz	a5,ffffffffc0209d26 <sfs_reclaim+0xe2>
ffffffffc0209cf8:	b6ef80ef          	jal	ffffffffc0202066 <kfree>
ffffffffc0209cfc:	8522                	mv	a0,s0
ffffffffc0209cfe:	d43fd0ef          	jal	ffffffffc0207a40 <inode_kill>
ffffffffc0209d02:	60e2                	ld	ra,24(sp)
ffffffffc0209d04:	6442                	ld	s0,16(sp)
ffffffffc0209d06:	64a2                	ld	s1,8(sp)
ffffffffc0209d08:	854a                	mv	a0,s2
ffffffffc0209d0a:	6902                	ld	s2,0(sp)
ffffffffc0209d0c:	6105                	addi	sp,sp,32
ffffffffc0209d0e:	8082                	ret
ffffffffc0209d10:	5945                	li	s2,-15
ffffffffc0209d12:	8526                	mv	a0,s1
ffffffffc0209d14:	598010ef          	jal	ffffffffc020b2ac <unlock_sfs_fs>
ffffffffc0209d18:	60e2                	ld	ra,24(sp)
ffffffffc0209d1a:	6442                	ld	s0,16(sp)
ffffffffc0209d1c:	64a2                	ld	s1,8(sp)
ffffffffc0209d1e:	854a                	mv	a0,s2
ffffffffc0209d20:	6902                	ld	s2,0(sp)
ffffffffc0209d22:	6105                	addi	sp,sp,32
ffffffffc0209d24:	8082                	ret
ffffffffc0209d26:	440c                	lw	a1,8(s0)
ffffffffc0209d28:	8526                	mv	a0,s1
ffffffffc0209d2a:	ea7ff0ef          	jal	ffffffffc0209bd0 <sfs_block_free>
ffffffffc0209d2e:	6008                	ld	a0,0(s0)
ffffffffc0209d30:	5d4c                	lw	a1,60(a0)
ffffffffc0209d32:	d1f9                	beqz	a1,ffffffffc0209cf8 <sfs_reclaim+0xb4>
ffffffffc0209d34:	8526                	mv	a0,s1
ffffffffc0209d36:	e9bff0ef          	jal	ffffffffc0209bd0 <sfs_block_free>
ffffffffc0209d3a:	6008                	ld	a0,0(s0)
ffffffffc0209d3c:	bf75                	j	ffffffffc0209cf8 <sfs_reclaim+0xb4>
ffffffffc0209d3e:	892a                	mv	s2,a0
ffffffffc0209d40:	bfc9                	j	ffffffffc0209d12 <sfs_reclaim+0xce>
ffffffffc0209d42:	00005697          	auipc	a3,0x5
ffffffffc0209d46:	9d668693          	addi	a3,a3,-1578 # ffffffffc020e718 <etext+0x2eb8>
ffffffffc0209d4a:	00002617          	auipc	a2,0x2
ffffffffc0209d4e:	f4e60613          	addi	a2,a2,-178 # ffffffffc020bc98 <etext+0x438>
ffffffffc0209d52:	35000593          	li	a1,848
ffffffffc0209d56:	00005517          	auipc	a0,0x5
ffffffffc0209d5a:	ba250513          	addi	a0,a0,-1118 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc0209d5e:	eecf60ef          	jal	ffffffffc020044a <__panic>
ffffffffc0209d62:	00005697          	auipc	a3,0x5
ffffffffc0209d66:	c1e68693          	addi	a3,a3,-994 # ffffffffc020e980 <etext+0x3120>
ffffffffc0209d6a:	00002617          	auipc	a2,0x2
ffffffffc0209d6e:	f2e60613          	addi	a2,a2,-210 # ffffffffc020bc98 <etext+0x438>
ffffffffc0209d72:	35600593          	li	a1,854
ffffffffc0209d76:	00005517          	auipc	a0,0x5
ffffffffc0209d7a:	b8250513          	addi	a0,a0,-1150 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc0209d7e:	eccf60ef          	jal	ffffffffc020044a <__panic>
ffffffffc0209d82:	00005697          	auipc	a3,0x5
ffffffffc0209d86:	b3e68693          	addi	a3,a3,-1218 # ffffffffc020e8c0 <etext+0x3060>
ffffffffc0209d8a:	00002617          	auipc	a2,0x2
ffffffffc0209d8e:	f0e60613          	addi	a2,a2,-242 # ffffffffc020bc98 <etext+0x438>
ffffffffc0209d92:	35100593          	li	a1,849
ffffffffc0209d96:	00005517          	auipc	a0,0x5
ffffffffc0209d9a:	b6250513          	addi	a0,a0,-1182 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc0209d9e:	eacf60ef          	jal	ffffffffc020044a <__panic>
ffffffffc0209da2:	00004697          	auipc	a3,0x4
ffffffffc0209da6:	41e68693          	addi	a3,a3,1054 # ffffffffc020e1c0 <etext+0x2960>
ffffffffc0209daa:	00002617          	auipc	a2,0x2
ffffffffc0209dae:	eee60613          	addi	a2,a2,-274 # ffffffffc020bc98 <etext+0x438>
ffffffffc0209db2:	35b00593          	li	a1,859
ffffffffc0209db6:	00005517          	auipc	a0,0x5
ffffffffc0209dba:	b4250513          	addi	a0,a0,-1214 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc0209dbe:	e8cf60ef          	jal	ffffffffc020044a <__panic>
ffffffffc0209dc2:	00003697          	auipc	a3,0x3
ffffffffc0209dc6:	76668693          	addi	a3,a3,1894 # ffffffffc020d528 <etext+0x1cc8>
ffffffffc0209dca:	00002617          	auipc	a2,0x2
ffffffffc0209dce:	ece60613          	addi	a2,a2,-306 # ffffffffc020bc98 <etext+0x438>
ffffffffc0209dd2:	36000593          	li	a1,864
ffffffffc0209dd6:	00005517          	auipc	a0,0x5
ffffffffc0209dda:	b2250513          	addi	a0,a0,-1246 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc0209dde:	e6cf60ef          	jal	ffffffffc020044a <__panic>

ffffffffc0209de2 <sfs_block_alloc>:
ffffffffc0209de2:	1101                	addi	sp,sp,-32
ffffffffc0209de4:	e822                	sd	s0,16(sp)
ffffffffc0209de6:	842a                	mv	s0,a0
ffffffffc0209de8:	7d08                	ld	a0,56(a0)
ffffffffc0209dea:	e426                	sd	s1,8(sp)
ffffffffc0209dec:	ec06                	sd	ra,24(sp)
ffffffffc0209dee:	84ae                	mv	s1,a1
ffffffffc0209df0:	c3eff0ef          	jal	ffffffffc020922e <bitmap_alloc>
ffffffffc0209df4:	e90d                	bnez	a0,ffffffffc0209e26 <sfs_block_alloc+0x44>
ffffffffc0209df6:	441c                	lw	a5,8(s0)
ffffffffc0209df8:	cbb5                	beqz	a5,ffffffffc0209e6c <sfs_block_alloc+0x8a>
ffffffffc0209dfa:	37fd                	addiw	a5,a5,-1
ffffffffc0209dfc:	c41c                	sw	a5,8(s0)
ffffffffc0209dfe:	408c                	lw	a1,0(s1)
ffffffffc0209e00:	4605                	li	a2,1
ffffffffc0209e02:	e030                	sd	a2,64(s0)
ffffffffc0209e04:	c595                	beqz	a1,ffffffffc0209e30 <sfs_block_alloc+0x4e>
ffffffffc0209e06:	405c                	lw	a5,4(s0)
ffffffffc0209e08:	02f5f463          	bgeu	a1,a5,ffffffffc0209e30 <sfs_block_alloc+0x4e>
ffffffffc0209e0c:	7c08                	ld	a0,56(s0)
ffffffffc0209e0e:	c92ff0ef          	jal	ffffffffc02092a0 <bitmap_test>
ffffffffc0209e12:	4605                	li	a2,1
ffffffffc0209e14:	ed05                	bnez	a0,ffffffffc0209e4c <sfs_block_alloc+0x6a>
ffffffffc0209e16:	8522                	mv	a0,s0
ffffffffc0209e18:	6442                	ld	s0,16(sp)
ffffffffc0209e1a:	408c                	lw	a1,0(s1)
ffffffffc0209e1c:	60e2                	ld	ra,24(sp)
ffffffffc0209e1e:	64a2                	ld	s1,8(sp)
ffffffffc0209e20:	6105                	addi	sp,sp,32
ffffffffc0209e22:	41a0106f          	j	ffffffffc020b23c <sfs_clear_block>
ffffffffc0209e26:	60e2                	ld	ra,24(sp)
ffffffffc0209e28:	6442                	ld	s0,16(sp)
ffffffffc0209e2a:	64a2                	ld	s1,8(sp)
ffffffffc0209e2c:	6105                	addi	sp,sp,32
ffffffffc0209e2e:	8082                	ret
ffffffffc0209e30:	4054                	lw	a3,4(s0)
ffffffffc0209e32:	872e                	mv	a4,a1
ffffffffc0209e34:	00005617          	auipc	a2,0x5
ffffffffc0209e38:	af460613          	addi	a2,a2,-1292 # ffffffffc020e928 <etext+0x30c8>
ffffffffc0209e3c:	05300593          	li	a1,83
ffffffffc0209e40:	00005517          	auipc	a0,0x5
ffffffffc0209e44:	ab850513          	addi	a0,a0,-1352 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc0209e48:	e02f60ef          	jal	ffffffffc020044a <__panic>
ffffffffc0209e4c:	00005697          	auipc	a3,0x5
ffffffffc0209e50:	b6c68693          	addi	a3,a3,-1172 # ffffffffc020e9b8 <etext+0x3158>
ffffffffc0209e54:	00002617          	auipc	a2,0x2
ffffffffc0209e58:	e4460613          	addi	a2,a2,-444 # ffffffffc020bc98 <etext+0x438>
ffffffffc0209e5c:	06100593          	li	a1,97
ffffffffc0209e60:	00005517          	auipc	a0,0x5
ffffffffc0209e64:	a9850513          	addi	a0,a0,-1384 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc0209e68:	de2f60ef          	jal	ffffffffc020044a <__panic>
ffffffffc0209e6c:	00005697          	auipc	a3,0x5
ffffffffc0209e70:	b2c68693          	addi	a3,a3,-1236 # ffffffffc020e998 <etext+0x3138>
ffffffffc0209e74:	00002617          	auipc	a2,0x2
ffffffffc0209e78:	e2460613          	addi	a2,a2,-476 # ffffffffc020bc98 <etext+0x438>
ffffffffc0209e7c:	05f00593          	li	a1,95
ffffffffc0209e80:	00005517          	auipc	a0,0x5
ffffffffc0209e84:	a7850513          	addi	a0,a0,-1416 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc0209e88:	dc2f60ef          	jal	ffffffffc020044a <__panic>

ffffffffc0209e8c <sfs_bmap_load_nolock>:
ffffffffc0209e8c:	711d                	addi	sp,sp,-96
ffffffffc0209e8e:	e4a6                	sd	s1,72(sp)
ffffffffc0209e90:	6184                	ld	s1,0(a1)
ffffffffc0209e92:	e0ca                	sd	s2,64(sp)
ffffffffc0209e94:	ec86                	sd	ra,88(sp)
ffffffffc0209e96:	0084a903          	lw	s2,8(s1)
ffffffffc0209e9a:	e8a2                	sd	s0,80(sp)
ffffffffc0209e9c:	fc4e                	sd	s3,56(sp)
ffffffffc0209e9e:	f852                	sd	s4,48(sp)
ffffffffc0209ea0:	1ac96663          	bltu	s2,a2,ffffffffc020a04c <sfs_bmap_load_nolock+0x1c0>
ffffffffc0209ea4:	47ad                	li	a5,11
ffffffffc0209ea6:	882e                	mv	a6,a1
ffffffffc0209ea8:	8432                	mv	s0,a2
ffffffffc0209eaa:	8a36                	mv	s4,a3
ffffffffc0209eac:	89aa                	mv	s3,a0
ffffffffc0209eae:	04c7f963          	bgeu	a5,a2,ffffffffc0209f00 <sfs_bmap_load_nolock+0x74>
ffffffffc0209eb2:	ff46079b          	addiw	a5,a2,-12
ffffffffc0209eb6:	3ff00713          	li	a4,1023
ffffffffc0209eba:	f456                	sd	s5,40(sp)
ffffffffc0209ebc:	1af76a63          	bltu	a4,a5,ffffffffc020a070 <sfs_bmap_load_nolock+0x1e4>
ffffffffc0209ec0:	03c4a883          	lw	a7,60(s1)
ffffffffc0209ec4:	02079713          	slli	a4,a5,0x20
ffffffffc0209ec8:	01e75793          	srli	a5,a4,0x1e
ffffffffc0209ecc:	ce02                	sw	zero,28(sp)
ffffffffc0209ece:	cc46                	sw	a7,24(sp)
ffffffffc0209ed0:	8abe                	mv	s5,a5
ffffffffc0209ed2:	12089063          	bnez	a7,ffffffffc0209ff2 <sfs_bmap_load_nolock+0x166>
ffffffffc0209ed6:	08c90c63          	beq	s2,a2,ffffffffc0209f6e <sfs_bmap_load_nolock+0xe2>
ffffffffc0209eda:	7aa2                	ld	s5,40(sp)
ffffffffc0209edc:	4581                	li	a1,0
ffffffffc0209ede:	0049a683          	lw	a3,4(s3)
ffffffffc0209ee2:	f456                	sd	s5,40(sp)
ffffffffc0209ee4:	f05a                	sd	s6,32(sp)
ffffffffc0209ee6:	872e                	mv	a4,a1
ffffffffc0209ee8:	00005617          	auipc	a2,0x5
ffffffffc0209eec:	a4060613          	addi	a2,a2,-1472 # ffffffffc020e928 <etext+0x30c8>
ffffffffc0209ef0:	05300593          	li	a1,83
ffffffffc0209ef4:	00005517          	auipc	a0,0x5
ffffffffc0209ef8:	a0450513          	addi	a0,a0,-1532 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc0209efc:	d4ef60ef          	jal	ffffffffc020044a <__panic>
ffffffffc0209f00:	02061793          	slli	a5,a2,0x20
ffffffffc0209f04:	01e7d713          	srli	a4,a5,0x1e
ffffffffc0209f08:	9726                	add	a4,a4,s1
ffffffffc0209f0a:	474c                	lw	a1,12(a4)
ffffffffc0209f0c:	ca2e                	sw	a1,20(sp)
ffffffffc0209f0e:	e581                	bnez	a1,ffffffffc0209f16 <sfs_bmap_load_nolock+0x8a>
ffffffffc0209f10:	0cc90063          	beq	s2,a2,ffffffffc0209fd0 <sfs_bmap_load_nolock+0x144>
ffffffffc0209f14:	d5e1                	beqz	a1,ffffffffc0209edc <sfs_bmap_load_nolock+0x50>
ffffffffc0209f16:	0049a683          	lw	a3,4(s3)
ffffffffc0209f1a:	16d5f863          	bgeu	a1,a3,ffffffffc020a08a <sfs_bmap_load_nolock+0x1fe>
ffffffffc0209f1e:	0389b503          	ld	a0,56(s3)
ffffffffc0209f22:	b7eff0ef          	jal	ffffffffc02092a0 <bitmap_test>
ffffffffc0209f26:	18051763          	bnez	a0,ffffffffc020a0b4 <sfs_bmap_load_nolock+0x228>
ffffffffc0209f2a:	45d2                	lw	a1,20(sp)
ffffffffc0209f2c:	0049a783          	lw	a5,4(s3)
ffffffffc0209f30:	d5d5                	beqz	a1,ffffffffc0209edc <sfs_bmap_load_nolock+0x50>
ffffffffc0209f32:	faf5f6e3          	bgeu	a1,a5,ffffffffc0209ede <sfs_bmap_load_nolock+0x52>
ffffffffc0209f36:	0389b503          	ld	a0,56(s3)
ffffffffc0209f3a:	e02e                	sd	a1,0(sp)
ffffffffc0209f3c:	b64ff0ef          	jal	ffffffffc02092a0 <bitmap_test>
ffffffffc0209f40:	6582                	ld	a1,0(sp)
ffffffffc0209f42:	14051763          	bnez	a0,ffffffffc020a090 <sfs_bmap_load_nolock+0x204>
ffffffffc0209f46:	02890063          	beq	s2,s0,ffffffffc0209f66 <sfs_bmap_load_nolock+0xda>
ffffffffc0209f4a:	000a0463          	beqz	s4,ffffffffc0209f52 <sfs_bmap_load_nolock+0xc6>
ffffffffc0209f4e:	00ba2023          	sw	a1,0(s4)
ffffffffc0209f52:	4781                	li	a5,0
ffffffffc0209f54:	6446                	ld	s0,80(sp)
ffffffffc0209f56:	60e6                	ld	ra,88(sp)
ffffffffc0209f58:	79e2                	ld	s3,56(sp)
ffffffffc0209f5a:	7a42                	ld	s4,48(sp)
ffffffffc0209f5c:	64a6                	ld	s1,72(sp)
ffffffffc0209f5e:	6906                	ld	s2,64(sp)
ffffffffc0209f60:	853e                	mv	a0,a5
ffffffffc0209f62:	6125                	addi	sp,sp,96
ffffffffc0209f64:	8082                	ret
ffffffffc0209f66:	449c                	lw	a5,8(s1)
ffffffffc0209f68:	2785                	addiw	a5,a5,1
ffffffffc0209f6a:	c49c                	sw	a5,8(s1)
ffffffffc0209f6c:	bff9                	j	ffffffffc0209f4a <sfs_bmap_load_nolock+0xbe>
ffffffffc0209f6e:	082c                	addi	a1,sp,24
ffffffffc0209f70:	e046                	sd	a7,0(sp)
ffffffffc0209f72:	e442                	sd	a6,8(sp)
ffffffffc0209f74:	e6fff0ef          	jal	ffffffffc0209de2 <sfs_block_alloc>
ffffffffc0209f78:	87aa                	mv	a5,a0
ffffffffc0209f7a:	ed5d                	bnez	a0,ffffffffc020a038 <sfs_bmap_load_nolock+0x1ac>
ffffffffc0209f7c:	6882                	ld	a7,0(sp)
ffffffffc0209f7e:	6822                	ld	a6,8(sp)
ffffffffc0209f80:	f05a                	sd	s6,32(sp)
ffffffffc0209f82:	01c10b13          	addi	s6,sp,28
ffffffffc0209f86:	85da                	mv	a1,s6
ffffffffc0209f88:	854e                	mv	a0,s3
ffffffffc0209f8a:	e046                	sd	a7,0(sp)
ffffffffc0209f8c:	e442                	sd	a6,8(sp)
ffffffffc0209f8e:	e55ff0ef          	jal	ffffffffc0209de2 <sfs_block_alloc>
ffffffffc0209f92:	6882                	ld	a7,0(sp)
ffffffffc0209f94:	87aa                	mv	a5,a0
ffffffffc0209f96:	e959                	bnez	a0,ffffffffc020a02c <sfs_bmap_load_nolock+0x1a0>
ffffffffc0209f98:	46e2                	lw	a3,24(sp)
ffffffffc0209f9a:	85da                	mv	a1,s6
ffffffffc0209f9c:	8756                	mv	a4,s5
ffffffffc0209f9e:	4611                	li	a2,4
ffffffffc0209fa0:	854e                	mv	a0,s3
ffffffffc0209fa2:	e046                	sd	a7,0(sp)
ffffffffc0209fa4:	144010ef          	jal	ffffffffc020b0e8 <sfs_wbuf>
ffffffffc0209fa8:	45f2                	lw	a1,28(sp)
ffffffffc0209faa:	6882                	ld	a7,0(sp)
ffffffffc0209fac:	e92d                	bnez	a0,ffffffffc020a01e <sfs_bmap_load_nolock+0x192>
ffffffffc0209fae:	5cd8                	lw	a4,60(s1)
ffffffffc0209fb0:	47e2                	lw	a5,24(sp)
ffffffffc0209fb2:	6822                	ld	a6,8(sp)
ffffffffc0209fb4:	ca2e                	sw	a1,20(sp)
ffffffffc0209fb6:	00f70863          	beq	a4,a5,ffffffffc0209fc6 <sfs_bmap_load_nolock+0x13a>
ffffffffc0209fba:	10071f63          	bnez	a4,ffffffffc020a0d8 <sfs_bmap_load_nolock+0x24c>
ffffffffc0209fbe:	dcdc                	sw	a5,60(s1)
ffffffffc0209fc0:	4785                	li	a5,1
ffffffffc0209fc2:	00f83823          	sd	a5,16(a6)
ffffffffc0209fc6:	7aa2                	ld	s5,40(sp)
ffffffffc0209fc8:	7b02                	ld	s6,32(sp)
ffffffffc0209fca:	f00589e3          	beqz	a1,ffffffffc0209edc <sfs_bmap_load_nolock+0x50>
ffffffffc0209fce:	b7a1                	j	ffffffffc0209f16 <sfs_bmap_load_nolock+0x8a>
ffffffffc0209fd0:	084c                	addi	a1,sp,20
ffffffffc0209fd2:	e03a                	sd	a4,0(sp)
ffffffffc0209fd4:	e442                	sd	a6,8(sp)
ffffffffc0209fd6:	e0dff0ef          	jal	ffffffffc0209de2 <sfs_block_alloc>
ffffffffc0209fda:	87aa                	mv	a5,a0
ffffffffc0209fdc:	fd25                	bnez	a0,ffffffffc0209f54 <sfs_bmap_load_nolock+0xc8>
ffffffffc0209fde:	45d2                	lw	a1,20(sp)
ffffffffc0209fe0:	6702                	ld	a4,0(sp)
ffffffffc0209fe2:	6822                	ld	a6,8(sp)
ffffffffc0209fe4:	4785                	li	a5,1
ffffffffc0209fe6:	c74c                	sw	a1,12(a4)
ffffffffc0209fe8:	00f83823          	sd	a5,16(a6)
ffffffffc0209fec:	ee0588e3          	beqz	a1,ffffffffc0209edc <sfs_bmap_load_nolock+0x50>
ffffffffc0209ff0:	b71d                	j	ffffffffc0209f16 <sfs_bmap_load_nolock+0x8a>
ffffffffc0209ff2:	e02e                	sd	a1,0(sp)
ffffffffc0209ff4:	873e                	mv	a4,a5
ffffffffc0209ff6:	086c                	addi	a1,sp,28
ffffffffc0209ff8:	86c6                	mv	a3,a7
ffffffffc0209ffa:	4611                	li	a2,4
ffffffffc0209ffc:	f05a                	sd	s6,32(sp)
ffffffffc0209ffe:	e446                	sd	a7,8(sp)
ffffffffc020a000:	068010ef          	jal	ffffffffc020b068 <sfs_rbuf>
ffffffffc020a004:	01c10b13          	addi	s6,sp,28
ffffffffc020a008:	87aa                	mv	a5,a0
ffffffffc020a00a:	e505                	bnez	a0,ffffffffc020a032 <sfs_bmap_load_nolock+0x1a6>
ffffffffc020a00c:	45f2                	lw	a1,28(sp)
ffffffffc020a00e:	6802                	ld	a6,0(sp)
ffffffffc020a010:	00891463          	bne	s2,s0,ffffffffc020a018 <sfs_bmap_load_nolock+0x18c>
ffffffffc020a014:	68a2                	ld	a7,8(sp)
ffffffffc020a016:	d9a5                	beqz	a1,ffffffffc0209f86 <sfs_bmap_load_nolock+0xfa>
ffffffffc020a018:	5cd8                	lw	a4,60(s1)
ffffffffc020a01a:	47e2                	lw	a5,24(sp)
ffffffffc020a01c:	bf61                	j	ffffffffc0209fb4 <sfs_bmap_load_nolock+0x128>
ffffffffc020a01e:	e42a                	sd	a0,8(sp)
ffffffffc020a020:	854e                	mv	a0,s3
ffffffffc020a022:	e046                	sd	a7,0(sp)
ffffffffc020a024:	badff0ef          	jal	ffffffffc0209bd0 <sfs_block_free>
ffffffffc020a028:	6882                	ld	a7,0(sp)
ffffffffc020a02a:	67a2                	ld	a5,8(sp)
ffffffffc020a02c:	45e2                	lw	a1,24(sp)
ffffffffc020a02e:	00b89763          	bne	a7,a1,ffffffffc020a03c <sfs_bmap_load_nolock+0x1b0>
ffffffffc020a032:	7aa2                	ld	s5,40(sp)
ffffffffc020a034:	7b02                	ld	s6,32(sp)
ffffffffc020a036:	bf39                	j	ffffffffc0209f54 <sfs_bmap_load_nolock+0xc8>
ffffffffc020a038:	7aa2                	ld	s5,40(sp)
ffffffffc020a03a:	bf29                	j	ffffffffc0209f54 <sfs_bmap_load_nolock+0xc8>
ffffffffc020a03c:	854e                	mv	a0,s3
ffffffffc020a03e:	e03e                	sd	a5,0(sp)
ffffffffc020a040:	b91ff0ef          	jal	ffffffffc0209bd0 <sfs_block_free>
ffffffffc020a044:	6782                	ld	a5,0(sp)
ffffffffc020a046:	7aa2                	ld	s5,40(sp)
ffffffffc020a048:	7b02                	ld	s6,32(sp)
ffffffffc020a04a:	b729                	j	ffffffffc0209f54 <sfs_bmap_load_nolock+0xc8>
ffffffffc020a04c:	00005697          	auipc	a3,0x5
ffffffffc020a050:	99468693          	addi	a3,a3,-1644 # ffffffffc020e9e0 <etext+0x3180>
ffffffffc020a054:	00002617          	auipc	a2,0x2
ffffffffc020a058:	c4460613          	addi	a2,a2,-956 # ffffffffc020bc98 <etext+0x438>
ffffffffc020a05c:	16400593          	li	a1,356
ffffffffc020a060:	00005517          	auipc	a0,0x5
ffffffffc020a064:	89850513          	addi	a0,a0,-1896 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020a068:	f456                	sd	s5,40(sp)
ffffffffc020a06a:	f05a                	sd	s6,32(sp)
ffffffffc020a06c:	bdef60ef          	jal	ffffffffc020044a <__panic>
ffffffffc020a070:	00005617          	auipc	a2,0x5
ffffffffc020a074:	9a060613          	addi	a2,a2,-1632 # ffffffffc020ea10 <etext+0x31b0>
ffffffffc020a078:	11e00593          	li	a1,286
ffffffffc020a07c:	00005517          	auipc	a0,0x5
ffffffffc020a080:	87c50513          	addi	a0,a0,-1924 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020a084:	f05a                	sd	s6,32(sp)
ffffffffc020a086:	bc4f60ef          	jal	ffffffffc020044a <__panic>
ffffffffc020a08a:	f456                	sd	s5,40(sp)
ffffffffc020a08c:	f05a                	sd	s6,32(sp)
ffffffffc020a08e:	bda1                	j	ffffffffc0209ee6 <sfs_bmap_load_nolock+0x5a>
ffffffffc020a090:	00005697          	auipc	a3,0x5
ffffffffc020a094:	8d068693          	addi	a3,a3,-1840 # ffffffffc020e960 <etext+0x3100>
ffffffffc020a098:	00002617          	auipc	a2,0x2
ffffffffc020a09c:	c0060613          	addi	a2,a2,-1024 # ffffffffc020bc98 <etext+0x438>
ffffffffc020a0a0:	16b00593          	li	a1,363
ffffffffc020a0a4:	00005517          	auipc	a0,0x5
ffffffffc020a0a8:	85450513          	addi	a0,a0,-1964 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020a0ac:	f456                	sd	s5,40(sp)
ffffffffc020a0ae:	f05a                	sd	s6,32(sp)
ffffffffc020a0b0:	b9af60ef          	jal	ffffffffc020044a <__panic>
ffffffffc020a0b4:	00005697          	auipc	a3,0x5
ffffffffc020a0b8:	98c68693          	addi	a3,a3,-1652 # ffffffffc020ea40 <etext+0x31e0>
ffffffffc020a0bc:	00002617          	auipc	a2,0x2
ffffffffc020a0c0:	bdc60613          	addi	a2,a2,-1060 # ffffffffc020bc98 <etext+0x438>
ffffffffc020a0c4:	12100593          	li	a1,289
ffffffffc020a0c8:	00005517          	auipc	a0,0x5
ffffffffc020a0cc:	83050513          	addi	a0,a0,-2000 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020a0d0:	f456                	sd	s5,40(sp)
ffffffffc020a0d2:	f05a                	sd	s6,32(sp)
ffffffffc020a0d4:	b76f60ef          	jal	ffffffffc020044a <__panic>
ffffffffc020a0d8:	00005697          	auipc	a3,0x5
ffffffffc020a0dc:	92068693          	addi	a3,a3,-1760 # ffffffffc020e9f8 <etext+0x3198>
ffffffffc020a0e0:	00002617          	auipc	a2,0x2
ffffffffc020a0e4:	bb860613          	addi	a2,a2,-1096 # ffffffffc020bc98 <etext+0x438>
ffffffffc020a0e8:	11800593          	li	a1,280
ffffffffc020a0ec:	00005517          	auipc	a0,0x5
ffffffffc020a0f0:	80c50513          	addi	a0,a0,-2036 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020a0f4:	b56f60ef          	jal	ffffffffc020044a <__panic>

ffffffffc020a0f8 <sfs_io_nolock>:
ffffffffc020a0f8:	7175                	addi	sp,sp,-144
ffffffffc020a0fa:	e4de                	sd	s7,72(sp)
ffffffffc020a0fc:	8bae                	mv	s7,a1
ffffffffc020a0fe:	618c                	ld	a1,0(a1)
ffffffffc020a100:	e506                	sd	ra,136(sp)
ffffffffc020a102:	4809                	li	a6,2
ffffffffc020a104:	0045d883          	lhu	a7,4(a1)
ffffffffc020a108:	1d088763          	beq	a7,a6,ffffffffc020a2d6 <sfs_io_nolock+0x1de>
ffffffffc020a10c:	ecd6                	sd	s5,88(sp)
ffffffffc020a10e:	00073a83          	ld	s5,0(a4) # 8000000 <_binary_bin_sfs_img_size+0x7f8ad00>
ffffffffc020a112:	f4ce                	sd	s3,104(sp)
ffffffffc020a114:	f86a                	sd	s10,48(sp)
ffffffffc020a116:	8d3a                	mv	s10,a4
ffffffffc020a118:	000d3023          	sd	zero,0(s10)
ffffffffc020a11c:	08000737          	lui	a4,0x8000
ffffffffc020a120:	89b6                	mv	s3,a3
ffffffffc020a122:	9ab6                	add	s5,s5,a3
ffffffffc020a124:	8836                	mv	a6,a3
ffffffffc020a126:	1ae6f663          	bgeu	a3,a4,ffffffffc020a2d2 <sfs_io_nolock+0x1da>
ffffffffc020a12a:	1adac463          	blt	s5,a3,ffffffffc020a2d2 <sfs_io_nolock+0x1da>
ffffffffc020a12e:	f0d2                	sd	s4,96(sp)
ffffffffc020a130:	8a2a                	mv	s4,a0
ffffffffc020a132:	4501                	li	a0,0
ffffffffc020a134:	13568163          	beq	a3,s5,ffffffffc020a256 <sfs_io_nolock+0x15e>
ffffffffc020a138:	fca6                	sd	s1,120(sp)
ffffffffc020a13a:	fc66                	sd	s9,56(sp)
ffffffffc020a13c:	f46e                	sd	s11,40(sp)
ffffffffc020a13e:	84b2                	mv	s1,a2
ffffffffc020a140:	01577363          	bgeu	a4,s5,ffffffffc020a146 <sfs_io_nolock+0x4e>
ffffffffc020a144:	8aba                	mv	s5,a4
ffffffffc020a146:	c3f5                	beqz	a5,ffffffffc020a22a <sfs_io_nolock+0x132>
ffffffffc020a148:	e122                	sd	s0,128(sp)
ffffffffc020a14a:	f8ca                	sd	s2,112(sp)
ffffffffc020a14c:	e8da                	sd	s6,80(sp)
ffffffffc020a14e:	e0e2                	sd	s8,64(sp)
ffffffffc020a150:	00001c97          	auipc	s9,0x1
ffffffffc020a154:	eb6c8c93          	addi	s9,s9,-330 # ffffffffc020b006 <sfs_wblock>
ffffffffc020a158:	00001d97          	auipc	s11,0x1
ffffffffc020a15c:	f90d8d93          	addi	s11,s11,-112 # ffffffffc020b0e8 <sfs_wbuf>
ffffffffc020a160:	6705                	lui	a4,0x1
ffffffffc020a162:	40c9d413          	srai	s0,s3,0xc
ffffffffc020a166:	fff70c13          	addi	s8,a4,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc020a16a:	40cadb13          	srai	s6,s5,0xc
ffffffffc020a16e:	408b0b3b          	subw	s6,s6,s0
ffffffffc020a172:	0189fc33          	and	s8,s3,s8
ffffffffc020a176:	2401                	sext.w	s0,s0
ffffffffc020a178:	87da                	mv	a5,s6
ffffffffc020a17a:	0c0c0c63          	beqz	s8,ffffffffc020a252 <sfs_io_nolock+0x15a>
ffffffffc020a17e:	413a87b3          	sub	a5,s5,s3
ffffffffc020a182:	0e0b1263          	bnez	s6,ffffffffc020a266 <sfs_io_nolock+0x16e>
ffffffffc020a186:	0874                	addi	a3,sp,28
ffffffffc020a188:	8622                	mv	a2,s0
ffffffffc020a18a:	85de                	mv	a1,s7
ffffffffc020a18c:	8552                	mv	a0,s4
ffffffffc020a18e:	e042                	sd	a6,0(sp)
ffffffffc020a190:	e43e                	sd	a5,8(sp)
ffffffffc020a192:	cfbff0ef          	jal	ffffffffc0209e8c <sfs_bmap_load_nolock>
ffffffffc020a196:	6802                	ld	a6,0(sp)
ffffffffc020a198:	4901                	li	s2,0
ffffffffc020a19a:	e931                	bnez	a0,ffffffffc020a1ee <sfs_io_nolock+0xf6>
ffffffffc020a19c:	6922                	ld	s2,8(sp)
ffffffffc020a19e:	46f2                	lw	a3,28(sp)
ffffffffc020a1a0:	8762                	mv	a4,s8
ffffffffc020a1a2:	864a                	mv	a2,s2
ffffffffc020a1a4:	85a6                	mv	a1,s1
ffffffffc020a1a6:	8552                	mv	a0,s4
ffffffffc020a1a8:	9d82                	jalr	s11
ffffffffc020a1aa:	6802                	ld	a6,0(sp)
ffffffffc020a1ac:	e971                	bnez	a0,ffffffffc020a280 <sfs_io_nolock+0x188>
ffffffffc020a1ae:	020b0e63          	beqz	s6,ffffffffc020a1ea <sfs_io_nolock+0xf2>
ffffffffc020a1b2:	94ca                	add	s1,s1,s2
ffffffffc020a1b4:	2405                	addiw	s0,s0,1
ffffffffc020a1b6:	fffb079b          	addiw	a5,s6,-1
ffffffffc020a1ba:	c7e9                	beqz	a5,ffffffffc020a284 <sfs_io_nolock+0x18c>
ffffffffc020a1bc:	00878c3b          	addw	s8,a5,s0
ffffffffc020a1c0:	e062                	sd	s8,0(sp)
ffffffffc020a1c2:	6b05                	lui	s6,0x1
ffffffffc020a1c4:	a821                	j	ffffffffc020a1dc <sfs_io_nolock+0xe4>
ffffffffc020a1c6:	4672                	lw	a2,28(sp)
ffffffffc020a1c8:	4685                	li	a3,1
ffffffffc020a1ca:	85a6                	mv	a1,s1
ffffffffc020a1cc:	8552                	mv	a0,s4
ffffffffc020a1ce:	9c82                	jalr	s9
ffffffffc020a1d0:	ed09                	bnez	a0,ffffffffc020a1ea <sfs_io_nolock+0xf2>
ffffffffc020a1d2:	2405                	addiw	s0,s0,1
ffffffffc020a1d4:	995a                	add	s2,s2,s6
ffffffffc020a1d6:	94da                	add	s1,s1,s6
ffffffffc020a1d8:	0a8c0763          	beq	s8,s0,ffffffffc020a286 <sfs_io_nolock+0x18e>
ffffffffc020a1dc:	0874                	addi	a3,sp,28
ffffffffc020a1de:	8622                	mv	a2,s0
ffffffffc020a1e0:	85de                	mv	a1,s7
ffffffffc020a1e2:	8552                	mv	a0,s4
ffffffffc020a1e4:	ca9ff0ef          	jal	ffffffffc0209e8c <sfs_bmap_load_nolock>
ffffffffc020a1e8:	dd79                	beqz	a0,ffffffffc020a1c6 <sfs_io_nolock+0xce>
ffffffffc020a1ea:	01298833          	add	a6,s3,s2
ffffffffc020a1ee:	000bb783          	ld	a5,0(s7)
ffffffffc020a1f2:	012d3023          	sd	s2,0(s10)
ffffffffc020a1f6:	0007e703          	lwu	a4,0(a5)
ffffffffc020a1fa:	01077963          	bgeu	a4,a6,ffffffffc020a20c <sfs_io_nolock+0x114>
ffffffffc020a1fe:	012989bb          	addw	s3,s3,s2
ffffffffc020a202:	0137a023          	sw	s3,0(a5)
ffffffffc020a206:	4785                	li	a5,1
ffffffffc020a208:	00fbb823          	sd	a5,16(s7)
ffffffffc020a20c:	640a                	ld	s0,128(sp)
ffffffffc020a20e:	74e6                	ld	s1,120(sp)
ffffffffc020a210:	7946                	ld	s2,112(sp)
ffffffffc020a212:	7a06                	ld	s4,96(sp)
ffffffffc020a214:	6b46                	ld	s6,80(sp)
ffffffffc020a216:	6c06                	ld	s8,64(sp)
ffffffffc020a218:	7ce2                	ld	s9,56(sp)
ffffffffc020a21a:	7da2                	ld	s11,40(sp)
ffffffffc020a21c:	60aa                	ld	ra,136(sp)
ffffffffc020a21e:	79a6                	ld	s3,104(sp)
ffffffffc020a220:	6ae6                	ld	s5,88(sp)
ffffffffc020a222:	7d42                	ld	s10,48(sp)
ffffffffc020a224:	6ba6                	ld	s7,72(sp)
ffffffffc020a226:	6149                	addi	sp,sp,144
ffffffffc020a228:	8082                	ret
ffffffffc020a22a:	0005e783          	lwu	a5,0(a1)
ffffffffc020a22e:	4501                	li	a0,0
ffffffffc020a230:	06f9d463          	bge	s3,a5,ffffffffc020a298 <sfs_io_nolock+0x1a0>
ffffffffc020a234:	e122                	sd	s0,128(sp)
ffffffffc020a236:	f8ca                	sd	s2,112(sp)
ffffffffc020a238:	e8da                	sd	s6,80(sp)
ffffffffc020a23a:	e0e2                	sd	s8,64(sp)
ffffffffc020a23c:	0357c863          	blt	a5,s5,ffffffffc020a26c <sfs_io_nolock+0x174>
ffffffffc020a240:	00001c97          	auipc	s9,0x1
ffffffffc020a244:	d64c8c93          	addi	s9,s9,-668 # ffffffffc020afa4 <sfs_rblock>
ffffffffc020a248:	00001d97          	auipc	s11,0x1
ffffffffc020a24c:	e20d8d93          	addi	s11,s11,-480 # ffffffffc020b068 <sfs_rbuf>
ffffffffc020a250:	bf01                	j	ffffffffc020a160 <sfs_io_nolock+0x68>
ffffffffc020a252:	4901                	li	s2,0
ffffffffc020a254:	b79d                	j	ffffffffc020a1ba <sfs_io_nolock+0xc2>
ffffffffc020a256:	60aa                	ld	ra,136(sp)
ffffffffc020a258:	7a06                	ld	s4,96(sp)
ffffffffc020a25a:	79a6                	ld	s3,104(sp)
ffffffffc020a25c:	6ae6                	ld	s5,88(sp)
ffffffffc020a25e:	7d42                	ld	s10,48(sp)
ffffffffc020a260:	6ba6                	ld	s7,72(sp)
ffffffffc020a262:	6149                	addi	sp,sp,144
ffffffffc020a264:	8082                	ret
ffffffffc020a266:	418707b3          	sub	a5,a4,s8
ffffffffc020a26a:	bf31                	j	ffffffffc020a186 <sfs_io_nolock+0x8e>
ffffffffc020a26c:	8abe                	mv	s5,a5
ffffffffc020a26e:	00001c97          	auipc	s9,0x1
ffffffffc020a272:	d36c8c93          	addi	s9,s9,-714 # ffffffffc020afa4 <sfs_rblock>
ffffffffc020a276:	00001d97          	auipc	s11,0x1
ffffffffc020a27a:	df2d8d93          	addi	s11,s11,-526 # ffffffffc020b068 <sfs_rbuf>
ffffffffc020a27e:	b5cd                	j	ffffffffc020a160 <sfs_io_nolock+0x68>
ffffffffc020a280:	4901                	li	s2,0
ffffffffc020a282:	b7b5                	j	ffffffffc020a1ee <sfs_io_nolock+0xf6>
ffffffffc020a284:	e022                	sd	s0,0(sp)
ffffffffc020a286:	1ad2                	slli	s5,s5,0x34
ffffffffc020a288:	034ad413          	srli	s0,s5,0x34
ffffffffc020a28c:	020a9163          	bnez	s5,ffffffffc020a2ae <sfs_io_nolock+0x1b6>
ffffffffc020a290:	01298833          	add	a6,s3,s2
ffffffffc020a294:	4501                	li	a0,0
ffffffffc020a296:	bfa1                	j	ffffffffc020a1ee <sfs_io_nolock+0xf6>
ffffffffc020a298:	60aa                	ld	ra,136(sp)
ffffffffc020a29a:	74e6                	ld	s1,120(sp)
ffffffffc020a29c:	7a06                	ld	s4,96(sp)
ffffffffc020a29e:	7ce2                	ld	s9,56(sp)
ffffffffc020a2a0:	7da2                	ld	s11,40(sp)
ffffffffc020a2a2:	79a6                	ld	s3,104(sp)
ffffffffc020a2a4:	6ae6                	ld	s5,88(sp)
ffffffffc020a2a6:	7d42                	ld	s10,48(sp)
ffffffffc020a2a8:	6ba6                	ld	s7,72(sp)
ffffffffc020a2aa:	6149                	addi	sp,sp,144
ffffffffc020a2ac:	8082                	ret
ffffffffc020a2ae:	6602                	ld	a2,0(sp)
ffffffffc020a2b0:	0874                	addi	a3,sp,28
ffffffffc020a2b2:	85de                	mv	a1,s7
ffffffffc020a2b4:	8552                	mv	a0,s4
ffffffffc020a2b6:	bd7ff0ef          	jal	ffffffffc0209e8c <sfs_bmap_load_nolock>
ffffffffc020a2ba:	f905                	bnez	a0,ffffffffc020a1ea <sfs_io_nolock+0xf2>
ffffffffc020a2bc:	46f2                	lw	a3,28(sp)
ffffffffc020a2be:	85a6                	mv	a1,s1
ffffffffc020a2c0:	8552                	mv	a0,s4
ffffffffc020a2c2:	4701                	li	a4,0
ffffffffc020a2c4:	8622                	mv	a2,s0
ffffffffc020a2c6:	9d82                	jalr	s11
ffffffffc020a2c8:	f10d                	bnez	a0,ffffffffc020a1ea <sfs_io_nolock+0xf2>
ffffffffc020a2ca:	9922                	add	s2,s2,s0
ffffffffc020a2cc:	01298833          	add	a6,s3,s2
ffffffffc020a2d0:	bf39                	j	ffffffffc020a1ee <sfs_io_nolock+0xf6>
ffffffffc020a2d2:	5575                	li	a0,-3
ffffffffc020a2d4:	b7a1                	j	ffffffffc020a21c <sfs_io_nolock+0x124>
ffffffffc020a2d6:	00004697          	auipc	a3,0x4
ffffffffc020a2da:	79268693          	addi	a3,a3,1938 # ffffffffc020ea68 <etext+0x3208>
ffffffffc020a2de:	00002617          	auipc	a2,0x2
ffffffffc020a2e2:	9ba60613          	addi	a2,a2,-1606 # ffffffffc020bc98 <etext+0x438>
ffffffffc020a2e6:	22b00593          	li	a1,555
ffffffffc020a2ea:	00004517          	auipc	a0,0x4
ffffffffc020a2ee:	60e50513          	addi	a0,a0,1550 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020a2f2:	e122                	sd	s0,128(sp)
ffffffffc020a2f4:	fca6                	sd	s1,120(sp)
ffffffffc020a2f6:	f8ca                	sd	s2,112(sp)
ffffffffc020a2f8:	f4ce                	sd	s3,104(sp)
ffffffffc020a2fa:	f0d2                	sd	s4,96(sp)
ffffffffc020a2fc:	ecd6                	sd	s5,88(sp)
ffffffffc020a2fe:	e8da                	sd	s6,80(sp)
ffffffffc020a300:	e0e2                	sd	s8,64(sp)
ffffffffc020a302:	fc66                	sd	s9,56(sp)
ffffffffc020a304:	f86a                	sd	s10,48(sp)
ffffffffc020a306:	f46e                	sd	s11,40(sp)
ffffffffc020a308:	942f60ef          	jal	ffffffffc020044a <__panic>

ffffffffc020a30c <sfs_read>:
ffffffffc020a30c:	7139                	addi	sp,sp,-64
ffffffffc020a30e:	f04a                	sd	s2,32(sp)
ffffffffc020a310:	06853903          	ld	s2,104(a0)
ffffffffc020a314:	fc06                	sd	ra,56(sp)
ffffffffc020a316:	f822                	sd	s0,48(sp)
ffffffffc020a318:	f426                	sd	s1,40(sp)
ffffffffc020a31a:	ec4e                	sd	s3,24(sp)
ffffffffc020a31c:	04090e63          	beqz	s2,ffffffffc020a378 <sfs_read+0x6c>
ffffffffc020a320:	0b092783          	lw	a5,176(s2)
ffffffffc020a324:	ebb1                	bnez	a5,ffffffffc020a378 <sfs_read+0x6c>
ffffffffc020a326:	4d38                	lw	a4,88(a0)
ffffffffc020a328:	6785                	lui	a5,0x1
ffffffffc020a32a:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a32e:	842a                	mv	s0,a0
ffffffffc020a330:	06f71463          	bne	a4,a5,ffffffffc020a398 <sfs_read+0x8c>
ffffffffc020a334:	02050993          	addi	s3,a0,32
ffffffffc020a338:	854e                	mv	a0,s3
ffffffffc020a33a:	84ae                	mv	s1,a1
ffffffffc020a33c:	abafa0ef          	jal	ffffffffc02045f6 <down>
ffffffffc020a340:	6c9c                	ld	a5,24(s1)
ffffffffc020a342:	6494                	ld	a3,8(s1)
ffffffffc020a344:	6090                	ld	a2,0(s1)
ffffffffc020a346:	85a2                	mv	a1,s0
ffffffffc020a348:	e43e                	sd	a5,8(sp)
ffffffffc020a34a:	854a                	mv	a0,s2
ffffffffc020a34c:	0038                	addi	a4,sp,8
ffffffffc020a34e:	4781                	li	a5,0
ffffffffc020a350:	da9ff0ef          	jal	ffffffffc020a0f8 <sfs_io_nolock>
ffffffffc020a354:	65a2                	ld	a1,8(sp)
ffffffffc020a356:	842a                	mv	s0,a0
ffffffffc020a358:	ed81                	bnez	a1,ffffffffc020a370 <sfs_read+0x64>
ffffffffc020a35a:	854e                	mv	a0,s3
ffffffffc020a35c:	a96fa0ef          	jal	ffffffffc02045f2 <up>
ffffffffc020a360:	70e2                	ld	ra,56(sp)
ffffffffc020a362:	8522                	mv	a0,s0
ffffffffc020a364:	7442                	ld	s0,48(sp)
ffffffffc020a366:	74a2                	ld	s1,40(sp)
ffffffffc020a368:	7902                	ld	s2,32(sp)
ffffffffc020a36a:	69e2                	ld	s3,24(sp)
ffffffffc020a36c:	6121                	addi	sp,sp,64
ffffffffc020a36e:	8082                	ret
ffffffffc020a370:	8526                	mv	a0,s1
ffffffffc020a372:	9a8fb0ef          	jal	ffffffffc020551a <iobuf_skip>
ffffffffc020a376:	b7d5                	j	ffffffffc020a35a <sfs_read+0x4e>
ffffffffc020a378:	00004697          	auipc	a3,0x4
ffffffffc020a37c:	3a068693          	addi	a3,a3,928 # ffffffffc020e718 <etext+0x2eb8>
ffffffffc020a380:	00002617          	auipc	a2,0x2
ffffffffc020a384:	91860613          	addi	a2,a2,-1768 # ffffffffc020bc98 <etext+0x438>
ffffffffc020a388:	28e00593          	li	a1,654
ffffffffc020a38c:	00004517          	auipc	a0,0x4
ffffffffc020a390:	56c50513          	addi	a0,a0,1388 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020a394:	8b6f60ef          	jal	ffffffffc020044a <__panic>
ffffffffc020a398:	815ff0ef          	jal	ffffffffc0209bac <sfs_io.part.0>

ffffffffc020a39c <sfs_write>:
ffffffffc020a39c:	7139                	addi	sp,sp,-64
ffffffffc020a39e:	f04a                	sd	s2,32(sp)
ffffffffc020a3a0:	06853903          	ld	s2,104(a0)
ffffffffc020a3a4:	fc06                	sd	ra,56(sp)
ffffffffc020a3a6:	f822                	sd	s0,48(sp)
ffffffffc020a3a8:	f426                	sd	s1,40(sp)
ffffffffc020a3aa:	ec4e                	sd	s3,24(sp)
ffffffffc020a3ac:	04090e63          	beqz	s2,ffffffffc020a408 <sfs_write+0x6c>
ffffffffc020a3b0:	0b092783          	lw	a5,176(s2)
ffffffffc020a3b4:	ebb1                	bnez	a5,ffffffffc020a408 <sfs_write+0x6c>
ffffffffc020a3b6:	4d38                	lw	a4,88(a0)
ffffffffc020a3b8:	6785                	lui	a5,0x1
ffffffffc020a3ba:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a3be:	842a                	mv	s0,a0
ffffffffc020a3c0:	06f71463          	bne	a4,a5,ffffffffc020a428 <sfs_write+0x8c>
ffffffffc020a3c4:	02050993          	addi	s3,a0,32
ffffffffc020a3c8:	854e                	mv	a0,s3
ffffffffc020a3ca:	84ae                	mv	s1,a1
ffffffffc020a3cc:	a2afa0ef          	jal	ffffffffc02045f6 <down>
ffffffffc020a3d0:	6c9c                	ld	a5,24(s1)
ffffffffc020a3d2:	6494                	ld	a3,8(s1)
ffffffffc020a3d4:	6090                	ld	a2,0(s1)
ffffffffc020a3d6:	85a2                	mv	a1,s0
ffffffffc020a3d8:	e43e                	sd	a5,8(sp)
ffffffffc020a3da:	854a                	mv	a0,s2
ffffffffc020a3dc:	0038                	addi	a4,sp,8
ffffffffc020a3de:	4785                	li	a5,1
ffffffffc020a3e0:	d19ff0ef          	jal	ffffffffc020a0f8 <sfs_io_nolock>
ffffffffc020a3e4:	65a2                	ld	a1,8(sp)
ffffffffc020a3e6:	842a                	mv	s0,a0
ffffffffc020a3e8:	ed81                	bnez	a1,ffffffffc020a400 <sfs_write+0x64>
ffffffffc020a3ea:	854e                	mv	a0,s3
ffffffffc020a3ec:	a06fa0ef          	jal	ffffffffc02045f2 <up>
ffffffffc020a3f0:	70e2                	ld	ra,56(sp)
ffffffffc020a3f2:	8522                	mv	a0,s0
ffffffffc020a3f4:	7442                	ld	s0,48(sp)
ffffffffc020a3f6:	74a2                	ld	s1,40(sp)
ffffffffc020a3f8:	7902                	ld	s2,32(sp)
ffffffffc020a3fa:	69e2                	ld	s3,24(sp)
ffffffffc020a3fc:	6121                	addi	sp,sp,64
ffffffffc020a3fe:	8082                	ret
ffffffffc020a400:	8526                	mv	a0,s1
ffffffffc020a402:	918fb0ef          	jal	ffffffffc020551a <iobuf_skip>
ffffffffc020a406:	b7d5                	j	ffffffffc020a3ea <sfs_write+0x4e>
ffffffffc020a408:	00004697          	auipc	a3,0x4
ffffffffc020a40c:	31068693          	addi	a3,a3,784 # ffffffffc020e718 <etext+0x2eb8>
ffffffffc020a410:	00002617          	auipc	a2,0x2
ffffffffc020a414:	88860613          	addi	a2,a2,-1912 # ffffffffc020bc98 <etext+0x438>
ffffffffc020a418:	28e00593          	li	a1,654
ffffffffc020a41c:	00004517          	auipc	a0,0x4
ffffffffc020a420:	4dc50513          	addi	a0,a0,1244 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020a424:	826f60ef          	jal	ffffffffc020044a <__panic>
ffffffffc020a428:	f84ff0ef          	jal	ffffffffc0209bac <sfs_io.part.0>

ffffffffc020a42c <sfs_dirent_read_nolock>:
ffffffffc020a42c:	619c                	ld	a5,0(a1)
ffffffffc020a42e:	7139                	addi	sp,sp,-64
ffffffffc020a430:	f426                	sd	s1,40(sp)
ffffffffc020a432:	84b6                	mv	s1,a3
ffffffffc020a434:	0047d683          	lhu	a3,4(a5)
ffffffffc020a438:	fc06                	sd	ra,56(sp)
ffffffffc020a43a:	f822                	sd	s0,48(sp)
ffffffffc020a43c:	4709                	li	a4,2
ffffffffc020a43e:	04e69963          	bne	a3,a4,ffffffffc020a490 <sfs_dirent_read_nolock+0x64>
ffffffffc020a442:	479c                	lw	a5,8(a5)
ffffffffc020a444:	04f67663          	bgeu	a2,a5,ffffffffc020a490 <sfs_dirent_read_nolock+0x64>
ffffffffc020a448:	0874                	addi	a3,sp,28
ffffffffc020a44a:	842a                	mv	s0,a0
ffffffffc020a44c:	a41ff0ef          	jal	ffffffffc0209e8c <sfs_bmap_load_nolock>
ffffffffc020a450:	c511                	beqz	a0,ffffffffc020a45c <sfs_dirent_read_nolock+0x30>
ffffffffc020a452:	70e2                	ld	ra,56(sp)
ffffffffc020a454:	7442                	ld	s0,48(sp)
ffffffffc020a456:	74a2                	ld	s1,40(sp)
ffffffffc020a458:	6121                	addi	sp,sp,64
ffffffffc020a45a:	8082                	ret
ffffffffc020a45c:	45f2                	lw	a1,28(sp)
ffffffffc020a45e:	c9a9                	beqz	a1,ffffffffc020a4b0 <sfs_dirent_read_nolock+0x84>
ffffffffc020a460:	405c                	lw	a5,4(s0)
ffffffffc020a462:	04f5f763          	bgeu	a1,a5,ffffffffc020a4b0 <sfs_dirent_read_nolock+0x84>
ffffffffc020a466:	7c08                	ld	a0,56(s0)
ffffffffc020a468:	e42e                	sd	a1,8(sp)
ffffffffc020a46a:	e37fe0ef          	jal	ffffffffc02092a0 <bitmap_test>
ffffffffc020a46e:	ed39                	bnez	a0,ffffffffc020a4cc <sfs_dirent_read_nolock+0xa0>
ffffffffc020a470:	66a2                	ld	a3,8(sp)
ffffffffc020a472:	8522                	mv	a0,s0
ffffffffc020a474:	4701                	li	a4,0
ffffffffc020a476:	10400613          	li	a2,260
ffffffffc020a47a:	85a6                	mv	a1,s1
ffffffffc020a47c:	3ed000ef          	jal	ffffffffc020b068 <sfs_rbuf>
ffffffffc020a480:	f969                	bnez	a0,ffffffffc020a452 <sfs_dirent_read_nolock+0x26>
ffffffffc020a482:	100481a3          	sb	zero,259(s1)
ffffffffc020a486:	70e2                	ld	ra,56(sp)
ffffffffc020a488:	7442                	ld	s0,48(sp)
ffffffffc020a48a:	74a2                	ld	s1,40(sp)
ffffffffc020a48c:	6121                	addi	sp,sp,64
ffffffffc020a48e:	8082                	ret
ffffffffc020a490:	00004697          	auipc	a3,0x4
ffffffffc020a494:	5f868693          	addi	a3,a3,1528 # ffffffffc020ea88 <etext+0x3228>
ffffffffc020a498:	00002617          	auipc	a2,0x2
ffffffffc020a49c:	80060613          	addi	a2,a2,-2048 # ffffffffc020bc98 <etext+0x438>
ffffffffc020a4a0:	18e00593          	li	a1,398
ffffffffc020a4a4:	00004517          	auipc	a0,0x4
ffffffffc020a4a8:	45450513          	addi	a0,a0,1108 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020a4ac:	f9ff50ef          	jal	ffffffffc020044a <__panic>
ffffffffc020a4b0:	4054                	lw	a3,4(s0)
ffffffffc020a4b2:	872e                	mv	a4,a1
ffffffffc020a4b4:	00004617          	auipc	a2,0x4
ffffffffc020a4b8:	47460613          	addi	a2,a2,1140 # ffffffffc020e928 <etext+0x30c8>
ffffffffc020a4bc:	05300593          	li	a1,83
ffffffffc020a4c0:	00004517          	auipc	a0,0x4
ffffffffc020a4c4:	43850513          	addi	a0,a0,1080 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020a4c8:	f83f50ef          	jal	ffffffffc020044a <__panic>
ffffffffc020a4cc:	00004697          	auipc	a3,0x4
ffffffffc020a4d0:	49468693          	addi	a3,a3,1172 # ffffffffc020e960 <etext+0x3100>
ffffffffc020a4d4:	00001617          	auipc	a2,0x1
ffffffffc020a4d8:	7c460613          	addi	a2,a2,1988 # ffffffffc020bc98 <etext+0x438>
ffffffffc020a4dc:	19500593          	li	a1,405
ffffffffc020a4e0:	00004517          	auipc	a0,0x4
ffffffffc020a4e4:	41850513          	addi	a0,a0,1048 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020a4e8:	f63f50ef          	jal	ffffffffc020044a <__panic>

ffffffffc020a4ec <sfs_getdirentry>:
ffffffffc020a4ec:	715d                	addi	sp,sp,-80
ffffffffc020a4ee:	f052                	sd	s4,32(sp)
ffffffffc020a4f0:	8a2a                	mv	s4,a0
ffffffffc020a4f2:	10400513          	li	a0,260
ffffffffc020a4f6:	e85a                	sd	s6,16(sp)
ffffffffc020a4f8:	e486                	sd	ra,72(sp)
ffffffffc020a4fa:	e0a2                	sd	s0,64(sp)
ffffffffc020a4fc:	8b2e                	mv	s6,a1
ffffffffc020a4fe:	ac3f70ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc020a502:	0e050963          	beqz	a0,ffffffffc020a5f4 <sfs_getdirentry+0x108>
ffffffffc020a506:	ec56                	sd	s5,24(sp)
ffffffffc020a508:	068a3a83          	ld	s5,104(s4)
ffffffffc020a50c:	0e0a8663          	beqz	s5,ffffffffc020a5f8 <sfs_getdirentry+0x10c>
ffffffffc020a510:	0b0aa783          	lw	a5,176(s5)
ffffffffc020a514:	0e079263          	bnez	a5,ffffffffc020a5f8 <sfs_getdirentry+0x10c>
ffffffffc020a518:	058a2703          	lw	a4,88(s4)
ffffffffc020a51c:	6785                	lui	a5,0x1
ffffffffc020a51e:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a522:	10f71063          	bne	a4,a5,ffffffffc020a622 <sfs_getdirentry+0x136>
ffffffffc020a526:	f44e                	sd	s3,40(sp)
ffffffffc020a528:	57fd                	li	a5,-1
ffffffffc020a52a:	008b3983          	ld	s3,8(s6) # 1008 <_binary_bin_swap_img_size-0x6cf8>
ffffffffc020a52e:	17fe                	slli	a5,a5,0x3f
ffffffffc020a530:	0ff78793          	addi	a5,a5,255
ffffffffc020a534:	00f9f7b3          	and	a5,s3,a5
ffffffffc020a538:	e3d5                	bnez	a5,ffffffffc020a5dc <sfs_getdirentry+0xf0>
ffffffffc020a53a:	000a3783          	ld	a5,0(s4)
ffffffffc020a53e:	0089d993          	srli	s3,s3,0x8
ffffffffc020a542:	2981                	sext.w	s3,s3
ffffffffc020a544:	479c                	lw	a5,8(a5)
ffffffffc020a546:	0b37e163          	bltu	a5,s3,ffffffffc020a5e8 <sfs_getdirentry+0xfc>
ffffffffc020a54a:	f84a                	sd	s2,48(sp)
ffffffffc020a54c:	892a                	mv	s2,a0
ffffffffc020a54e:	020a0513          	addi	a0,s4,32
ffffffffc020a552:	e45e                	sd	s7,8(sp)
ffffffffc020a554:	8a2fa0ef          	jal	ffffffffc02045f6 <down>
ffffffffc020a558:	000a3783          	ld	a5,0(s4)
ffffffffc020a55c:	0087ab83          	lw	s7,8(a5)
ffffffffc020a560:	07705c63          	blez	s7,ffffffffc020a5d8 <sfs_getdirentry+0xec>
ffffffffc020a564:	fc26                	sd	s1,56(sp)
ffffffffc020a566:	4481                	li	s1,0
ffffffffc020a568:	a811                	j	ffffffffc020a57c <sfs_getdirentry+0x90>
ffffffffc020a56a:	00092783          	lw	a5,0(s2)
ffffffffc020a56e:	c781                	beqz	a5,ffffffffc020a576 <sfs_getdirentry+0x8a>
ffffffffc020a570:	02098463          	beqz	s3,ffffffffc020a598 <sfs_getdirentry+0xac>
ffffffffc020a574:	39fd                	addiw	s3,s3,-1
ffffffffc020a576:	2485                	addiw	s1,s1,1
ffffffffc020a578:	049b8d63          	beq	s7,s1,ffffffffc020a5d2 <sfs_getdirentry+0xe6>
ffffffffc020a57c:	86ca                	mv	a3,s2
ffffffffc020a57e:	8626                	mv	a2,s1
ffffffffc020a580:	85d2                	mv	a1,s4
ffffffffc020a582:	8556                	mv	a0,s5
ffffffffc020a584:	ea9ff0ef          	jal	ffffffffc020a42c <sfs_dirent_read_nolock>
ffffffffc020a588:	842a                	mv	s0,a0
ffffffffc020a58a:	d165                	beqz	a0,ffffffffc020a56a <sfs_getdirentry+0x7e>
ffffffffc020a58c:	74e2                	ld	s1,56(sp)
ffffffffc020a58e:	020a0513          	addi	a0,s4,32
ffffffffc020a592:	860fa0ef          	jal	ffffffffc02045f2 <up>
ffffffffc020a596:	a005                	j	ffffffffc020a5b6 <sfs_getdirentry+0xca>
ffffffffc020a598:	020a0513          	addi	a0,s4,32
ffffffffc020a59c:	856fa0ef          	jal	ffffffffc02045f2 <up>
ffffffffc020a5a0:	855a                	mv	a0,s6
ffffffffc020a5a2:	00490593          	addi	a1,s2,4
ffffffffc020a5a6:	4701                	li	a4,0
ffffffffc020a5a8:	4685                	li	a3,1
ffffffffc020a5aa:	10000613          	li	a2,256
ffffffffc020a5ae:	ee9fa0ef          	jal	ffffffffc0205496 <iobuf_move>
ffffffffc020a5b2:	74e2                	ld	s1,56(sp)
ffffffffc020a5b4:	842a                	mv	s0,a0
ffffffffc020a5b6:	854a                	mv	a0,s2
ffffffffc020a5b8:	aaff70ef          	jal	ffffffffc0202066 <kfree>
ffffffffc020a5bc:	7942                	ld	s2,48(sp)
ffffffffc020a5be:	79a2                	ld	s3,40(sp)
ffffffffc020a5c0:	6ae2                	ld	s5,24(sp)
ffffffffc020a5c2:	6ba2                	ld	s7,8(sp)
ffffffffc020a5c4:	60a6                	ld	ra,72(sp)
ffffffffc020a5c6:	8522                	mv	a0,s0
ffffffffc020a5c8:	6406                	ld	s0,64(sp)
ffffffffc020a5ca:	7a02                	ld	s4,32(sp)
ffffffffc020a5cc:	6b42                	ld	s6,16(sp)
ffffffffc020a5ce:	6161                	addi	sp,sp,80
ffffffffc020a5d0:	8082                	ret
ffffffffc020a5d2:	74e2                	ld	s1,56(sp)
ffffffffc020a5d4:	5441                	li	s0,-16
ffffffffc020a5d6:	bf65                	j	ffffffffc020a58e <sfs_getdirentry+0xa2>
ffffffffc020a5d8:	5441                	li	s0,-16
ffffffffc020a5da:	bf55                	j	ffffffffc020a58e <sfs_getdirentry+0xa2>
ffffffffc020a5dc:	a8bf70ef          	jal	ffffffffc0202066 <kfree>
ffffffffc020a5e0:	5475                	li	s0,-3
ffffffffc020a5e2:	79a2                	ld	s3,40(sp)
ffffffffc020a5e4:	6ae2                	ld	s5,24(sp)
ffffffffc020a5e6:	bff9                	j	ffffffffc020a5c4 <sfs_getdirentry+0xd8>
ffffffffc020a5e8:	a7ff70ef          	jal	ffffffffc0202066 <kfree>
ffffffffc020a5ec:	5441                	li	s0,-16
ffffffffc020a5ee:	79a2                	ld	s3,40(sp)
ffffffffc020a5f0:	6ae2                	ld	s5,24(sp)
ffffffffc020a5f2:	bfc9                	j	ffffffffc020a5c4 <sfs_getdirentry+0xd8>
ffffffffc020a5f4:	5471                	li	s0,-4
ffffffffc020a5f6:	b7f9                	j	ffffffffc020a5c4 <sfs_getdirentry+0xd8>
ffffffffc020a5f8:	00004697          	auipc	a3,0x4
ffffffffc020a5fc:	12068693          	addi	a3,a3,288 # ffffffffc020e718 <etext+0x2eb8>
ffffffffc020a600:	00001617          	auipc	a2,0x1
ffffffffc020a604:	69860613          	addi	a2,a2,1688 # ffffffffc020bc98 <etext+0x438>
ffffffffc020a608:	33200593          	li	a1,818
ffffffffc020a60c:	00004517          	auipc	a0,0x4
ffffffffc020a610:	2ec50513          	addi	a0,a0,748 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020a614:	fc26                	sd	s1,56(sp)
ffffffffc020a616:	f84a                	sd	s2,48(sp)
ffffffffc020a618:	f44e                	sd	s3,40(sp)
ffffffffc020a61a:	e45e                	sd	s7,8(sp)
ffffffffc020a61c:	e062                	sd	s8,0(sp)
ffffffffc020a61e:	e2df50ef          	jal	ffffffffc020044a <__panic>
ffffffffc020a622:	00004697          	auipc	a3,0x4
ffffffffc020a626:	29e68693          	addi	a3,a3,670 # ffffffffc020e8c0 <etext+0x3060>
ffffffffc020a62a:	00001617          	auipc	a2,0x1
ffffffffc020a62e:	66e60613          	addi	a2,a2,1646 # ffffffffc020bc98 <etext+0x438>
ffffffffc020a632:	33300593          	li	a1,819
ffffffffc020a636:	00004517          	auipc	a0,0x4
ffffffffc020a63a:	2c250513          	addi	a0,a0,706 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020a63e:	fc26                	sd	s1,56(sp)
ffffffffc020a640:	f84a                	sd	s2,48(sp)
ffffffffc020a642:	f44e                	sd	s3,40(sp)
ffffffffc020a644:	e45e                	sd	s7,8(sp)
ffffffffc020a646:	e062                	sd	s8,0(sp)
ffffffffc020a648:	e03f50ef          	jal	ffffffffc020044a <__panic>

ffffffffc020a64c <sfs_truncfile>:
ffffffffc020a64c:	080007b7          	lui	a5,0x8000
ffffffffc020a650:	1ab7eb63          	bltu	a5,a1,ffffffffc020a806 <sfs_truncfile+0x1ba>
ffffffffc020a654:	7159                	addi	sp,sp,-112
ffffffffc020a656:	e0d2                	sd	s4,64(sp)
ffffffffc020a658:	06853a03          	ld	s4,104(a0)
ffffffffc020a65c:	e8ca                	sd	s2,80(sp)
ffffffffc020a65e:	e4ce                	sd	s3,72(sp)
ffffffffc020a660:	f486                	sd	ra,104(sp)
ffffffffc020a662:	f0a2                	sd	s0,96(sp)
ffffffffc020a664:	fc56                	sd	s5,56(sp)
ffffffffc020a666:	892a                	mv	s2,a0
ffffffffc020a668:	89ae                	mv	s3,a1
ffffffffc020a66a:	1a0a0163          	beqz	s4,ffffffffc020a80c <sfs_truncfile+0x1c0>
ffffffffc020a66e:	0b0a2783          	lw	a5,176(s4)
ffffffffc020a672:	18079d63          	bnez	a5,ffffffffc020a80c <sfs_truncfile+0x1c0>
ffffffffc020a676:	4d38                	lw	a4,88(a0)
ffffffffc020a678:	6785                	lui	a5,0x1
ffffffffc020a67a:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a67e:	6405                	lui	s0,0x1
ffffffffc020a680:	1cf71963          	bne	a4,a5,ffffffffc020a852 <sfs_truncfile+0x206>
ffffffffc020a684:	00053a83          	ld	s5,0(a0)
ffffffffc020a688:	147d                	addi	s0,s0,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc020a68a:	942e                	add	s0,s0,a1
ffffffffc020a68c:	000ae783          	lwu	a5,0(s5)
ffffffffc020a690:	8031                	srli	s0,s0,0xc
ffffffffc020a692:	2401                	sext.w	s0,s0
ffffffffc020a694:	02b79063          	bne	a5,a1,ffffffffc020a6b4 <sfs_truncfile+0x68>
ffffffffc020a698:	008aa703          	lw	a4,8(s5)
ffffffffc020a69c:	4781                	li	a5,0
ffffffffc020a69e:	1c871c63          	bne	a4,s0,ffffffffc020a876 <sfs_truncfile+0x22a>
ffffffffc020a6a2:	70a6                	ld	ra,104(sp)
ffffffffc020a6a4:	7406                	ld	s0,96(sp)
ffffffffc020a6a6:	6946                	ld	s2,80(sp)
ffffffffc020a6a8:	69a6                	ld	s3,72(sp)
ffffffffc020a6aa:	6a06                	ld	s4,64(sp)
ffffffffc020a6ac:	7ae2                	ld	s5,56(sp)
ffffffffc020a6ae:	853e                	mv	a0,a5
ffffffffc020a6b0:	6165                	addi	sp,sp,112
ffffffffc020a6b2:	8082                	ret
ffffffffc020a6b4:	02050513          	addi	a0,a0,32
ffffffffc020a6b8:	eca6                	sd	s1,88(sp)
ffffffffc020a6ba:	f3df90ef          	jal	ffffffffc02045f6 <down>
ffffffffc020a6be:	008aa483          	lw	s1,8(s5)
ffffffffc020a6c2:	0c84e363          	bltu	s1,s0,ffffffffc020a788 <sfs_truncfile+0x13c>
ffffffffc020a6c6:	0c947e63          	bgeu	s0,s1,ffffffffc020a7a2 <sfs_truncfile+0x156>
ffffffffc020a6ca:	48ad                	li	a7,11
ffffffffc020a6cc:	4305                	li	t1,1
ffffffffc020a6ce:	a895                	j	ffffffffc020a742 <sfs_truncfile+0xf6>
ffffffffc020a6d0:	37cd                	addiw	a5,a5,-13
ffffffffc020a6d2:	3ff00693          	li	a3,1023
ffffffffc020a6d6:	04f6ef63          	bltu	a3,a5,ffffffffc020a734 <sfs_truncfile+0xe8>
ffffffffc020a6da:	03c82683          	lw	a3,60(a6)
ffffffffc020a6de:	cab9                	beqz	a3,ffffffffc020a734 <sfs_truncfile+0xe8>
ffffffffc020a6e0:	004a2603          	lw	a2,4(s4)
ffffffffc020a6e4:	1ac6fb63          	bgeu	a3,a2,ffffffffc020a89a <sfs_truncfile+0x24e>
ffffffffc020a6e8:	038a3503          	ld	a0,56(s4)
ffffffffc020a6ec:	85b6                	mv	a1,a3
ffffffffc020a6ee:	e436                	sd	a3,8(sp)
ffffffffc020a6f0:	e842                	sd	a6,16(sp)
ffffffffc020a6f2:	ec3e                	sd	a5,24(sp)
ffffffffc020a6f4:	badfe0ef          	jal	ffffffffc02092a0 <bitmap_test>
ffffffffc020a6f8:	66a2                	ld	a3,8(sp)
ffffffffc020a6fa:	6842                	ld	a6,16(sp)
ffffffffc020a6fc:	67e2                	ld	a5,24(sp)
ffffffffc020a6fe:	1a051d63          	bnez	a0,ffffffffc020a8b8 <sfs_truncfile+0x26c>
ffffffffc020a702:	02079613          	slli	a2,a5,0x20
ffffffffc020a706:	01e65713          	srli	a4,a2,0x1e
ffffffffc020a70a:	102c                	addi	a1,sp,40
ffffffffc020a70c:	4611                	li	a2,4
ffffffffc020a70e:	8552                	mv	a0,s4
ffffffffc020a710:	ec42                	sd	a6,24(sp)
ffffffffc020a712:	e83a                	sd	a4,16(sp)
ffffffffc020a714:	e436                	sd	a3,8(sp)
ffffffffc020a716:	d602                	sw	zero,44(sp)
ffffffffc020a718:	151000ef          	jal	ffffffffc020b068 <sfs_rbuf>
ffffffffc020a71c:	87aa                	mv	a5,a0
ffffffffc020a71e:	e941                	bnez	a0,ffffffffc020a7ae <sfs_truncfile+0x162>
ffffffffc020a720:	57a2                	lw	a5,40(sp)
ffffffffc020a722:	66a2                	ld	a3,8(sp)
ffffffffc020a724:	6742                	ld	a4,16(sp)
ffffffffc020a726:	6862                	ld	a6,24(sp)
ffffffffc020a728:	48ad                	li	a7,11
ffffffffc020a72a:	4305                	li	t1,1
ffffffffc020a72c:	ebd5                	bnez	a5,ffffffffc020a7e0 <sfs_truncfile+0x194>
ffffffffc020a72e:	00882703          	lw	a4,8(a6)
ffffffffc020a732:	377d                	addiw	a4,a4,-1
ffffffffc020a734:	00e82423          	sw	a4,8(a6)
ffffffffc020a738:	00693823          	sd	t1,16(s2)
ffffffffc020a73c:	34fd                	addiw	s1,s1,-1
ffffffffc020a73e:	04940e63          	beq	s0,s1,ffffffffc020a79a <sfs_truncfile+0x14e>
ffffffffc020a742:	00093803          	ld	a6,0(s2)
ffffffffc020a746:	00882783          	lw	a5,8(a6)
ffffffffc020a74a:	0e078363          	beqz	a5,ffffffffc020a830 <sfs_truncfile+0x1e4>
ffffffffc020a74e:	fff7871b          	addiw	a4,a5,-1
ffffffffc020a752:	f6e8efe3          	bltu	a7,a4,ffffffffc020a6d0 <sfs_truncfile+0x84>
ffffffffc020a756:	02071693          	slli	a3,a4,0x20
ffffffffc020a75a:	01e6d793          	srli	a5,a3,0x1e
ffffffffc020a75e:	97c2                	add	a5,a5,a6
ffffffffc020a760:	47cc                	lw	a1,12(a5)
ffffffffc020a762:	d9e9                	beqz	a1,ffffffffc020a734 <sfs_truncfile+0xe8>
ffffffffc020a764:	8552                	mv	a0,s4
ffffffffc020a766:	e83e                	sd	a5,16(sp)
ffffffffc020a768:	e442                	sd	a6,8(sp)
ffffffffc020a76a:	c66ff0ef          	jal	ffffffffc0209bd0 <sfs_block_free>
ffffffffc020a76e:	67c2                	ld	a5,16(sp)
ffffffffc020a770:	6822                	ld	a6,8(sp)
ffffffffc020a772:	48ad                	li	a7,11
ffffffffc020a774:	0007a623          	sw	zero,12(a5)
ffffffffc020a778:	00882703          	lw	a4,8(a6)
ffffffffc020a77c:	4305                	li	t1,1
ffffffffc020a77e:	377d                	addiw	a4,a4,-1
ffffffffc020a780:	bf55                	j	ffffffffc020a734 <sfs_truncfile+0xe8>
ffffffffc020a782:	2485                	addiw	s1,s1,1
ffffffffc020a784:	00940b63          	beq	s0,s1,ffffffffc020a79a <sfs_truncfile+0x14e>
ffffffffc020a788:	4681                	li	a3,0
ffffffffc020a78a:	8626                	mv	a2,s1
ffffffffc020a78c:	85ca                	mv	a1,s2
ffffffffc020a78e:	8552                	mv	a0,s4
ffffffffc020a790:	efcff0ef          	jal	ffffffffc0209e8c <sfs_bmap_load_nolock>
ffffffffc020a794:	87aa                	mv	a5,a0
ffffffffc020a796:	d575                	beqz	a0,ffffffffc020a782 <sfs_truncfile+0x136>
ffffffffc020a798:	a819                	j	ffffffffc020a7ae <sfs_truncfile+0x162>
ffffffffc020a79a:	008aa783          	lw	a5,8(s5)
ffffffffc020a79e:	02879063          	bne	a5,s0,ffffffffc020a7be <sfs_truncfile+0x172>
ffffffffc020a7a2:	4785                	li	a5,1
ffffffffc020a7a4:	013aa023          	sw	s3,0(s5)
ffffffffc020a7a8:	00f93823          	sd	a5,16(s2)
ffffffffc020a7ac:	4781                	li	a5,0
ffffffffc020a7ae:	02090513          	addi	a0,s2,32
ffffffffc020a7b2:	e43e                	sd	a5,8(sp)
ffffffffc020a7b4:	e3ff90ef          	jal	ffffffffc02045f2 <up>
ffffffffc020a7b8:	67a2                	ld	a5,8(sp)
ffffffffc020a7ba:	64e6                	ld	s1,88(sp)
ffffffffc020a7bc:	b5dd                	j	ffffffffc020a6a2 <sfs_truncfile+0x56>
ffffffffc020a7be:	00004697          	auipc	a3,0x4
ffffffffc020a7c2:	38268693          	addi	a3,a3,898 # ffffffffc020eb40 <etext+0x32e0>
ffffffffc020a7c6:	00001617          	auipc	a2,0x1
ffffffffc020a7ca:	4d260613          	addi	a2,a2,1234 # ffffffffc020bc98 <etext+0x438>
ffffffffc020a7ce:	3c200593          	li	a1,962
ffffffffc020a7d2:	00004517          	auipc	a0,0x4
ffffffffc020a7d6:	12650513          	addi	a0,a0,294 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020a7da:	f85a                	sd	s6,48(sp)
ffffffffc020a7dc:	c6ff50ef          	jal	ffffffffc020044a <__panic>
ffffffffc020a7e0:	4611                	li	a2,4
ffffffffc020a7e2:	106c                	addi	a1,sp,44
ffffffffc020a7e4:	8552                	mv	a0,s4
ffffffffc020a7e6:	e442                	sd	a6,8(sp)
ffffffffc020a7e8:	101000ef          	jal	ffffffffc020b0e8 <sfs_wbuf>
ffffffffc020a7ec:	87aa                	mv	a5,a0
ffffffffc020a7ee:	f161                	bnez	a0,ffffffffc020a7ae <sfs_truncfile+0x162>
ffffffffc020a7f0:	55a2                	lw	a1,40(sp)
ffffffffc020a7f2:	8552                	mv	a0,s4
ffffffffc020a7f4:	bdcff0ef          	jal	ffffffffc0209bd0 <sfs_block_free>
ffffffffc020a7f8:	6822                	ld	a6,8(sp)
ffffffffc020a7fa:	4305                	li	t1,1
ffffffffc020a7fc:	48ad                	li	a7,11
ffffffffc020a7fe:	00882703          	lw	a4,8(a6)
ffffffffc020a802:	377d                	addiw	a4,a4,-1
ffffffffc020a804:	bf05                	j	ffffffffc020a734 <sfs_truncfile+0xe8>
ffffffffc020a806:	57f5                	li	a5,-3
ffffffffc020a808:	853e                	mv	a0,a5
ffffffffc020a80a:	8082                	ret
ffffffffc020a80c:	00004697          	auipc	a3,0x4
ffffffffc020a810:	f0c68693          	addi	a3,a3,-244 # ffffffffc020e718 <etext+0x2eb8>
ffffffffc020a814:	00001617          	auipc	a2,0x1
ffffffffc020a818:	48460613          	addi	a2,a2,1156 # ffffffffc020bc98 <etext+0x438>
ffffffffc020a81c:	3a100593          	li	a1,929
ffffffffc020a820:	00004517          	auipc	a0,0x4
ffffffffc020a824:	0d850513          	addi	a0,a0,216 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020a828:	eca6                	sd	s1,88(sp)
ffffffffc020a82a:	f85a                	sd	s6,48(sp)
ffffffffc020a82c:	c1ff50ef          	jal	ffffffffc020044a <__panic>
ffffffffc020a830:	00004697          	auipc	a3,0x4
ffffffffc020a834:	2c068693          	addi	a3,a3,704 # ffffffffc020eaf0 <etext+0x3290>
ffffffffc020a838:	00001617          	auipc	a2,0x1
ffffffffc020a83c:	46060613          	addi	a2,a2,1120 # ffffffffc020bc98 <etext+0x438>
ffffffffc020a840:	17b00593          	li	a1,379
ffffffffc020a844:	00004517          	auipc	a0,0x4
ffffffffc020a848:	0b450513          	addi	a0,a0,180 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020a84c:	f85a                	sd	s6,48(sp)
ffffffffc020a84e:	bfdf50ef          	jal	ffffffffc020044a <__panic>
ffffffffc020a852:	00004697          	auipc	a3,0x4
ffffffffc020a856:	06e68693          	addi	a3,a3,110 # ffffffffc020e8c0 <etext+0x3060>
ffffffffc020a85a:	00001617          	auipc	a2,0x1
ffffffffc020a85e:	43e60613          	addi	a2,a2,1086 # ffffffffc020bc98 <etext+0x438>
ffffffffc020a862:	3a200593          	li	a1,930
ffffffffc020a866:	00004517          	auipc	a0,0x4
ffffffffc020a86a:	09250513          	addi	a0,a0,146 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020a86e:	eca6                	sd	s1,88(sp)
ffffffffc020a870:	f85a                	sd	s6,48(sp)
ffffffffc020a872:	bd9f50ef          	jal	ffffffffc020044a <__panic>
ffffffffc020a876:	00004697          	auipc	a3,0x4
ffffffffc020a87a:	26268693          	addi	a3,a3,610 # ffffffffc020ead8 <etext+0x3278>
ffffffffc020a87e:	00001617          	auipc	a2,0x1
ffffffffc020a882:	41a60613          	addi	a2,a2,1050 # ffffffffc020bc98 <etext+0x438>
ffffffffc020a886:	3a900593          	li	a1,937
ffffffffc020a88a:	00004517          	auipc	a0,0x4
ffffffffc020a88e:	06e50513          	addi	a0,a0,110 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020a892:	eca6                	sd	s1,88(sp)
ffffffffc020a894:	f85a                	sd	s6,48(sp)
ffffffffc020a896:	bb5f50ef          	jal	ffffffffc020044a <__panic>
ffffffffc020a89a:	8736                	mv	a4,a3
ffffffffc020a89c:	05300593          	li	a1,83
ffffffffc020a8a0:	86b2                	mv	a3,a2
ffffffffc020a8a2:	00004517          	auipc	a0,0x4
ffffffffc020a8a6:	05650513          	addi	a0,a0,86 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020a8aa:	00004617          	auipc	a2,0x4
ffffffffc020a8ae:	07e60613          	addi	a2,a2,126 # ffffffffc020e928 <etext+0x30c8>
ffffffffc020a8b2:	f85a                	sd	s6,48(sp)
ffffffffc020a8b4:	b97f50ef          	jal	ffffffffc020044a <__panic>
ffffffffc020a8b8:	00004697          	auipc	a3,0x4
ffffffffc020a8bc:	25068693          	addi	a3,a3,592 # ffffffffc020eb08 <etext+0x32a8>
ffffffffc020a8c0:	00001617          	auipc	a2,0x1
ffffffffc020a8c4:	3d860613          	addi	a2,a2,984 # ffffffffc020bc98 <etext+0x438>
ffffffffc020a8c8:	12b00593          	li	a1,299
ffffffffc020a8cc:	00004517          	auipc	a0,0x4
ffffffffc020a8d0:	02c50513          	addi	a0,a0,44 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020a8d4:	f85a                	sd	s6,48(sp)
ffffffffc020a8d6:	b75f50ef          	jal	ffffffffc020044a <__panic>

ffffffffc020a8da <sfs_load_inode>:
ffffffffc020a8da:	7139                	addi	sp,sp,-64
ffffffffc020a8dc:	fc06                	sd	ra,56(sp)
ffffffffc020a8de:	f822                	sd	s0,48(sp)
ffffffffc020a8e0:	f426                	sd	s1,40(sp)
ffffffffc020a8e2:	f04a                	sd	s2,32(sp)
ffffffffc020a8e4:	84b2                	mv	s1,a2
ffffffffc020a8e6:	892a                	mv	s2,a0
ffffffffc020a8e8:	ec4e                	sd	s3,24(sp)
ffffffffc020a8ea:	89ae                	mv	s3,a1
ffffffffc020a8ec:	1b1000ef          	jal	ffffffffc020b29c <lock_sfs_fs>
ffffffffc020a8f0:	8526                	mv	a0,s1
ffffffffc020a8f2:	45a9                	li	a1,10
ffffffffc020a8f4:	0a893403          	ld	s0,168(s2)
ffffffffc020a8f8:	1c5000ef          	jal	ffffffffc020b2bc <hash32>
ffffffffc020a8fc:	02051793          	slli	a5,a0,0x20
ffffffffc020a900:	01c7d513          	srli	a0,a5,0x1c
ffffffffc020a904:	00a406b3          	add	a3,s0,a0
ffffffffc020a908:	87b6                	mv	a5,a3
ffffffffc020a90a:	a029                	j	ffffffffc020a914 <sfs_load_inode+0x3a>
ffffffffc020a90c:	fc07a703          	lw	a4,-64(a5)
ffffffffc020a910:	10970563          	beq	a4,s1,ffffffffc020aa1a <sfs_load_inode+0x140>
ffffffffc020a914:	679c                	ld	a5,8(a5)
ffffffffc020a916:	fef69be3          	bne	a3,a5,ffffffffc020a90c <sfs_load_inode+0x32>
ffffffffc020a91a:	04000513          	li	a0,64
ffffffffc020a91e:	ea2f70ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc020a922:	87aa                	mv	a5,a0
ffffffffc020a924:	10050b63          	beqz	a0,ffffffffc020aa3a <sfs_load_inode+0x160>
ffffffffc020a928:	14048f63          	beqz	s1,ffffffffc020aa86 <sfs_load_inode+0x1ac>
ffffffffc020a92c:	00492703          	lw	a4,4(s2)
ffffffffc020a930:	14e4fb63          	bgeu	s1,a4,ffffffffc020aa86 <sfs_load_inode+0x1ac>
ffffffffc020a934:	03893503          	ld	a0,56(s2)
ffffffffc020a938:	85a6                	mv	a1,s1
ffffffffc020a93a:	e43e                	sd	a5,8(sp)
ffffffffc020a93c:	965fe0ef          	jal	ffffffffc02092a0 <bitmap_test>
ffffffffc020a940:	16051263          	bnez	a0,ffffffffc020aaa4 <sfs_load_inode+0x1ca>
ffffffffc020a944:	65a2                	ld	a1,8(sp)
ffffffffc020a946:	4701                	li	a4,0
ffffffffc020a948:	86a6                	mv	a3,s1
ffffffffc020a94a:	04000613          	li	a2,64
ffffffffc020a94e:	854a                	mv	a0,s2
ffffffffc020a950:	718000ef          	jal	ffffffffc020b068 <sfs_rbuf>
ffffffffc020a954:	67a2                	ld	a5,8(sp)
ffffffffc020a956:	842a                	mv	s0,a0
ffffffffc020a958:	0e051e63          	bnez	a0,ffffffffc020aa54 <sfs_load_inode+0x17a>
ffffffffc020a95c:	0067d703          	lhu	a4,6(a5)
ffffffffc020a960:	10070363          	beqz	a4,ffffffffc020aa66 <sfs_load_inode+0x18c>
ffffffffc020a964:	6505                	lui	a0,0x1
ffffffffc020a966:	23550513          	addi	a0,a0,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a96a:	e43e                	sd	a5,8(sp)
ffffffffc020a96c:	8aafd0ef          	jal	ffffffffc0207a16 <__alloc_inode>
ffffffffc020a970:	67a2                	ld	a5,8(sp)
ffffffffc020a972:	842a                	mv	s0,a0
ffffffffc020a974:	cd79                	beqz	a0,ffffffffc020aa52 <sfs_load_inode+0x178>
ffffffffc020a976:	0047d683          	lhu	a3,4(a5)
ffffffffc020a97a:	4705                	li	a4,1
ffffffffc020a97c:	0ee68063          	beq	a3,a4,ffffffffc020aa5c <sfs_load_inode+0x182>
ffffffffc020a980:	4709                	li	a4,2
ffffffffc020a982:	00005597          	auipc	a1,0x5
ffffffffc020a986:	f3658593          	addi	a1,a1,-202 # ffffffffc020f8b8 <sfs_node_dirops>
ffffffffc020a98a:	16e69d63          	bne	a3,a4,ffffffffc020ab04 <sfs_load_inode+0x22a>
ffffffffc020a98e:	864a                	mv	a2,s2
ffffffffc020a990:	8522                	mv	a0,s0
ffffffffc020a992:	e43e                	sd	a5,8(sp)
ffffffffc020a994:	89efd0ef          	jal	ffffffffc0207a32 <inode_init>
ffffffffc020a998:	4c34                	lw	a3,88(s0)
ffffffffc020a99a:	6705                	lui	a4,0x1
ffffffffc020a99c:	23570713          	addi	a4,a4,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020a9a0:	67a2                	ld	a5,8(sp)
ffffffffc020a9a2:	14e69163          	bne	a3,a4,ffffffffc020aae4 <sfs_load_inode+0x20a>
ffffffffc020a9a6:	4585                	li	a1,1
ffffffffc020a9a8:	e01c                	sd	a5,0(s0)
ffffffffc020a9aa:	c404                	sw	s1,8(s0)
ffffffffc020a9ac:	00043823          	sd	zero,16(s0)
ffffffffc020a9b0:	cc0c                	sw	a1,24(s0)
ffffffffc020a9b2:	02040513          	addi	a0,s0,32
ffffffffc020a9b6:	e436                	sd	a3,8(sp)
ffffffffc020a9b8:	c35f90ef          	jal	ffffffffc02045ec <sem_init>
ffffffffc020a9bc:	4c3c                	lw	a5,88(s0)
ffffffffc020a9be:	66a2                	ld	a3,8(sp)
ffffffffc020a9c0:	10d79263          	bne	a5,a3,ffffffffc020aac4 <sfs_load_inode+0x1ea>
ffffffffc020a9c4:	0a093703          	ld	a4,160(s2)
ffffffffc020a9c8:	03840793          	addi	a5,s0,56
ffffffffc020a9cc:	4408                	lw	a0,8(s0)
ffffffffc020a9ce:	e31c                	sd	a5,0(a4)
ffffffffc020a9d0:	0af93023          	sd	a5,160(s2)
ffffffffc020a9d4:	09890793          	addi	a5,s2,152
ffffffffc020a9d8:	e038                	sd	a4,64(s0)
ffffffffc020a9da:	fc1c                	sd	a5,56(s0)
ffffffffc020a9dc:	45a9                	li	a1,10
ffffffffc020a9de:	0a893483          	ld	s1,168(s2)
ffffffffc020a9e2:	0db000ef          	jal	ffffffffc020b2bc <hash32>
ffffffffc020a9e6:	02051713          	slli	a4,a0,0x20
ffffffffc020a9ea:	01c75793          	srli	a5,a4,0x1c
ffffffffc020a9ee:	97a6                	add	a5,a5,s1
ffffffffc020a9f0:	6798                	ld	a4,8(a5)
ffffffffc020a9f2:	04840693          	addi	a3,s0,72
ffffffffc020a9f6:	e314                	sd	a3,0(a4)
ffffffffc020a9f8:	e794                	sd	a3,8(a5)
ffffffffc020a9fa:	e838                	sd	a4,80(s0)
ffffffffc020a9fc:	e43c                	sd	a5,72(s0)
ffffffffc020a9fe:	854a                	mv	a0,s2
ffffffffc020aa00:	0ad000ef          	jal	ffffffffc020b2ac <unlock_sfs_fs>
ffffffffc020aa04:	0089b023          	sd	s0,0(s3)
ffffffffc020aa08:	4401                	li	s0,0
ffffffffc020aa0a:	70e2                	ld	ra,56(sp)
ffffffffc020aa0c:	8522                	mv	a0,s0
ffffffffc020aa0e:	7442                	ld	s0,48(sp)
ffffffffc020aa10:	74a2                	ld	s1,40(sp)
ffffffffc020aa12:	7902                	ld	s2,32(sp)
ffffffffc020aa14:	69e2                	ld	s3,24(sp)
ffffffffc020aa16:	6121                	addi	sp,sp,64
ffffffffc020aa18:	8082                	ret
ffffffffc020aa1a:	fb878413          	addi	s0,a5,-72
ffffffffc020aa1e:	8522                	mv	a0,s0
ffffffffc020aa20:	e43e                	sd	a5,8(sp)
ffffffffc020aa22:	872fd0ef          	jal	ffffffffc0207a94 <inode_ref_inc>
ffffffffc020aa26:	4705                	li	a4,1
ffffffffc020aa28:	67a2                	ld	a5,8(sp)
ffffffffc020aa2a:	fce51ae3          	bne	a0,a4,ffffffffc020a9fe <sfs_load_inode+0x124>
ffffffffc020aa2e:	fd07a703          	lw	a4,-48(a5)
ffffffffc020aa32:	2705                	addiw	a4,a4,1
ffffffffc020aa34:	fce7a823          	sw	a4,-48(a5)
ffffffffc020aa38:	b7d9                	j	ffffffffc020a9fe <sfs_load_inode+0x124>
ffffffffc020aa3a:	5471                	li	s0,-4
ffffffffc020aa3c:	854a                	mv	a0,s2
ffffffffc020aa3e:	06f000ef          	jal	ffffffffc020b2ac <unlock_sfs_fs>
ffffffffc020aa42:	70e2                	ld	ra,56(sp)
ffffffffc020aa44:	8522                	mv	a0,s0
ffffffffc020aa46:	7442                	ld	s0,48(sp)
ffffffffc020aa48:	74a2                	ld	s1,40(sp)
ffffffffc020aa4a:	7902                	ld	s2,32(sp)
ffffffffc020aa4c:	69e2                	ld	s3,24(sp)
ffffffffc020aa4e:	6121                	addi	sp,sp,64
ffffffffc020aa50:	8082                	ret
ffffffffc020aa52:	5471                	li	s0,-4
ffffffffc020aa54:	853e                	mv	a0,a5
ffffffffc020aa56:	e10f70ef          	jal	ffffffffc0202066 <kfree>
ffffffffc020aa5a:	b7cd                	j	ffffffffc020aa3c <sfs_load_inode+0x162>
ffffffffc020aa5c:	00005597          	auipc	a1,0x5
ffffffffc020aa60:	ddc58593          	addi	a1,a1,-548 # ffffffffc020f838 <sfs_node_fileops>
ffffffffc020aa64:	b72d                	j	ffffffffc020a98e <sfs_load_inode+0xb4>
ffffffffc020aa66:	00004697          	auipc	a3,0x4
ffffffffc020aa6a:	0f268693          	addi	a3,a3,242 # ffffffffc020eb58 <etext+0x32f8>
ffffffffc020aa6e:	00001617          	auipc	a2,0x1
ffffffffc020aa72:	22a60613          	addi	a2,a2,554 # ffffffffc020bc98 <etext+0x438>
ffffffffc020aa76:	0ad00593          	li	a1,173
ffffffffc020aa7a:	00004517          	auipc	a0,0x4
ffffffffc020aa7e:	e7e50513          	addi	a0,a0,-386 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020aa82:	9c9f50ef          	jal	ffffffffc020044a <__panic>
ffffffffc020aa86:	00492683          	lw	a3,4(s2)
ffffffffc020aa8a:	8726                	mv	a4,s1
ffffffffc020aa8c:	00004617          	auipc	a2,0x4
ffffffffc020aa90:	e9c60613          	addi	a2,a2,-356 # ffffffffc020e928 <etext+0x30c8>
ffffffffc020aa94:	05300593          	li	a1,83
ffffffffc020aa98:	00004517          	auipc	a0,0x4
ffffffffc020aa9c:	e6050513          	addi	a0,a0,-416 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020aaa0:	9abf50ef          	jal	ffffffffc020044a <__panic>
ffffffffc020aaa4:	00004697          	auipc	a3,0x4
ffffffffc020aaa8:	ebc68693          	addi	a3,a3,-324 # ffffffffc020e960 <etext+0x3100>
ffffffffc020aaac:	00001617          	auipc	a2,0x1
ffffffffc020aab0:	1ec60613          	addi	a2,a2,492 # ffffffffc020bc98 <etext+0x438>
ffffffffc020aab4:	0a800593          	li	a1,168
ffffffffc020aab8:	00004517          	auipc	a0,0x4
ffffffffc020aabc:	e4050513          	addi	a0,a0,-448 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020aac0:	98bf50ef          	jal	ffffffffc020044a <__panic>
ffffffffc020aac4:	00004697          	auipc	a3,0x4
ffffffffc020aac8:	dfc68693          	addi	a3,a3,-516 # ffffffffc020e8c0 <etext+0x3060>
ffffffffc020aacc:	00001617          	auipc	a2,0x1
ffffffffc020aad0:	1cc60613          	addi	a2,a2,460 # ffffffffc020bc98 <etext+0x438>
ffffffffc020aad4:	0b100593          	li	a1,177
ffffffffc020aad8:	00004517          	auipc	a0,0x4
ffffffffc020aadc:	e2050513          	addi	a0,a0,-480 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020aae0:	96bf50ef          	jal	ffffffffc020044a <__panic>
ffffffffc020aae4:	00004697          	auipc	a3,0x4
ffffffffc020aae8:	ddc68693          	addi	a3,a3,-548 # ffffffffc020e8c0 <etext+0x3060>
ffffffffc020aaec:	00001617          	auipc	a2,0x1
ffffffffc020aaf0:	1ac60613          	addi	a2,a2,428 # ffffffffc020bc98 <etext+0x438>
ffffffffc020aaf4:	07700593          	li	a1,119
ffffffffc020aaf8:	00004517          	auipc	a0,0x4
ffffffffc020aafc:	e0050513          	addi	a0,a0,-512 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020ab00:	94bf50ef          	jal	ffffffffc020044a <__panic>
ffffffffc020ab04:	00004617          	auipc	a2,0x4
ffffffffc020ab08:	e0c60613          	addi	a2,a2,-500 # ffffffffc020e910 <etext+0x30b0>
ffffffffc020ab0c:	02e00593          	li	a1,46
ffffffffc020ab10:	00004517          	auipc	a0,0x4
ffffffffc020ab14:	de850513          	addi	a0,a0,-536 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020ab18:	933f50ef          	jal	ffffffffc020044a <__panic>

ffffffffc020ab1c <sfs_lookup_once.constprop.0>:
ffffffffc020ab1c:	711d                	addi	sp,sp,-96
ffffffffc020ab1e:	f852                	sd	s4,48(sp)
ffffffffc020ab20:	8a2a                	mv	s4,a0
ffffffffc020ab22:	02058513          	addi	a0,a1,32
ffffffffc020ab26:	ec86                	sd	ra,88(sp)
ffffffffc020ab28:	e0ca                	sd	s2,64(sp)
ffffffffc020ab2a:	f456                	sd	s5,40(sp)
ffffffffc020ab2c:	e862                	sd	s8,16(sp)
ffffffffc020ab2e:	8ab2                	mv	s5,a2
ffffffffc020ab30:	892e                	mv	s2,a1
ffffffffc020ab32:	8c36                	mv	s8,a3
ffffffffc020ab34:	ac3f90ef          	jal	ffffffffc02045f6 <down>
ffffffffc020ab38:	8556                	mv	a0,s5
ffffffffc020ab3a:	40b000ef          	jal	ffffffffc020b744 <strlen>
ffffffffc020ab3e:	0ff00793          	li	a5,255
ffffffffc020ab42:	0aa7e963          	bltu	a5,a0,ffffffffc020abf4 <sfs_lookup_once.constprop.0+0xd8>
ffffffffc020ab46:	10400513          	li	a0,260
ffffffffc020ab4a:	e4a6                	sd	s1,72(sp)
ffffffffc020ab4c:	c74f70ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc020ab50:	84aa                	mv	s1,a0
ffffffffc020ab52:	c959                	beqz	a0,ffffffffc020abe8 <sfs_lookup_once.constprop.0+0xcc>
ffffffffc020ab54:	00093783          	ld	a5,0(s2)
ffffffffc020ab58:	fc4e                	sd	s3,56(sp)
ffffffffc020ab5a:	0087a983          	lw	s3,8(a5)
ffffffffc020ab5e:	05305d63          	blez	s3,ffffffffc020abb8 <sfs_lookup_once.constprop.0+0x9c>
ffffffffc020ab62:	e8a2                	sd	s0,80(sp)
ffffffffc020ab64:	4401                	li	s0,0
ffffffffc020ab66:	a821                	j	ffffffffc020ab7e <sfs_lookup_once.constprop.0+0x62>
ffffffffc020ab68:	409c                	lw	a5,0(s1)
ffffffffc020ab6a:	c799                	beqz	a5,ffffffffc020ab78 <sfs_lookup_once.constprop.0+0x5c>
ffffffffc020ab6c:	00448593          	addi	a1,s1,4
ffffffffc020ab70:	8556                	mv	a0,s5
ffffffffc020ab72:	419000ef          	jal	ffffffffc020b78a <strcmp>
ffffffffc020ab76:	c139                	beqz	a0,ffffffffc020abbc <sfs_lookup_once.constprop.0+0xa0>
ffffffffc020ab78:	2405                	addiw	s0,s0,1
ffffffffc020ab7a:	02898e63          	beq	s3,s0,ffffffffc020abb6 <sfs_lookup_once.constprop.0+0x9a>
ffffffffc020ab7e:	86a6                	mv	a3,s1
ffffffffc020ab80:	8622                	mv	a2,s0
ffffffffc020ab82:	85ca                	mv	a1,s2
ffffffffc020ab84:	8552                	mv	a0,s4
ffffffffc020ab86:	8a7ff0ef          	jal	ffffffffc020a42c <sfs_dirent_read_nolock>
ffffffffc020ab8a:	87aa                	mv	a5,a0
ffffffffc020ab8c:	dd71                	beqz	a0,ffffffffc020ab68 <sfs_lookup_once.constprop.0+0x4c>
ffffffffc020ab8e:	6446                	ld	s0,80(sp)
ffffffffc020ab90:	8526                	mv	a0,s1
ffffffffc020ab92:	e43e                	sd	a5,8(sp)
ffffffffc020ab94:	cd2f70ef          	jal	ffffffffc0202066 <kfree>
ffffffffc020ab98:	02090513          	addi	a0,s2,32
ffffffffc020ab9c:	a57f90ef          	jal	ffffffffc02045f2 <up>
ffffffffc020aba0:	67a2                	ld	a5,8(sp)
ffffffffc020aba2:	79e2                	ld	s3,56(sp)
ffffffffc020aba4:	60e6                	ld	ra,88(sp)
ffffffffc020aba6:	64a6                	ld	s1,72(sp)
ffffffffc020aba8:	6906                	ld	s2,64(sp)
ffffffffc020abaa:	7a42                	ld	s4,48(sp)
ffffffffc020abac:	7aa2                	ld	s5,40(sp)
ffffffffc020abae:	6c42                	ld	s8,16(sp)
ffffffffc020abb0:	853e                	mv	a0,a5
ffffffffc020abb2:	6125                	addi	sp,sp,96
ffffffffc020abb4:	8082                	ret
ffffffffc020abb6:	6446                	ld	s0,80(sp)
ffffffffc020abb8:	57c1                	li	a5,-16
ffffffffc020abba:	bfd9                	j	ffffffffc020ab90 <sfs_lookup_once.constprop.0+0x74>
ffffffffc020abbc:	8526                	mv	a0,s1
ffffffffc020abbe:	4080                	lw	s0,0(s1)
ffffffffc020abc0:	ca6f70ef          	jal	ffffffffc0202066 <kfree>
ffffffffc020abc4:	02090513          	addi	a0,s2,32
ffffffffc020abc8:	a2bf90ef          	jal	ffffffffc02045f2 <up>
ffffffffc020abcc:	8622                	mv	a2,s0
ffffffffc020abce:	6446                	ld	s0,80(sp)
ffffffffc020abd0:	64a6                	ld	s1,72(sp)
ffffffffc020abd2:	79e2                	ld	s3,56(sp)
ffffffffc020abd4:	60e6                	ld	ra,88(sp)
ffffffffc020abd6:	6906                	ld	s2,64(sp)
ffffffffc020abd8:	7aa2                	ld	s5,40(sp)
ffffffffc020abda:	85e2                	mv	a1,s8
ffffffffc020abdc:	8552                	mv	a0,s4
ffffffffc020abde:	6c42                	ld	s8,16(sp)
ffffffffc020abe0:	7a42                	ld	s4,48(sp)
ffffffffc020abe2:	6125                	addi	sp,sp,96
ffffffffc020abe4:	cf7ff06f          	j	ffffffffc020a8da <sfs_load_inode>
ffffffffc020abe8:	02090513          	addi	a0,s2,32
ffffffffc020abec:	a07f90ef          	jal	ffffffffc02045f2 <up>
ffffffffc020abf0:	57f1                	li	a5,-4
ffffffffc020abf2:	bf4d                	j	ffffffffc020aba4 <sfs_lookup_once.constprop.0+0x88>
ffffffffc020abf4:	00004697          	auipc	a3,0x4
ffffffffc020abf8:	f7c68693          	addi	a3,a3,-132 # ffffffffc020eb70 <etext+0x3310>
ffffffffc020abfc:	00001617          	auipc	a2,0x1
ffffffffc020ac00:	09c60613          	addi	a2,a2,156 # ffffffffc020bc98 <etext+0x438>
ffffffffc020ac04:	1ba00593          	li	a1,442
ffffffffc020ac08:	00004517          	auipc	a0,0x4
ffffffffc020ac0c:	cf050513          	addi	a0,a0,-784 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020ac10:	e8a2                	sd	s0,80(sp)
ffffffffc020ac12:	e4a6                	sd	s1,72(sp)
ffffffffc020ac14:	fc4e                	sd	s3,56(sp)
ffffffffc020ac16:	f05a                	sd	s6,32(sp)
ffffffffc020ac18:	ec5e                	sd	s7,24(sp)
ffffffffc020ac1a:	831f50ef          	jal	ffffffffc020044a <__panic>

ffffffffc020ac1e <sfs_namefile>:
ffffffffc020ac1e:	6d9c                	ld	a5,24(a1)
ffffffffc020ac20:	7175                	addi	sp,sp,-144
ffffffffc020ac22:	f86a                	sd	s10,48(sp)
ffffffffc020ac24:	e506                	sd	ra,136(sp)
ffffffffc020ac26:	f46e                	sd	s11,40(sp)
ffffffffc020ac28:	4d09                	li	s10,2
ffffffffc020ac2a:	1afd7763          	bgeu	s10,a5,ffffffffc020add8 <sfs_namefile+0x1ba>
ffffffffc020ac2e:	f4ce                	sd	s3,104(sp)
ffffffffc020ac30:	89aa                	mv	s3,a0
ffffffffc020ac32:	10400513          	li	a0,260
ffffffffc020ac36:	fca6                	sd	s1,120(sp)
ffffffffc020ac38:	e42e                	sd	a1,8(sp)
ffffffffc020ac3a:	b86f70ef          	jal	ffffffffc0201fc0 <kmalloc>
ffffffffc020ac3e:	84aa                	mv	s1,a0
ffffffffc020ac40:	18050a63          	beqz	a0,ffffffffc020add4 <sfs_namefile+0x1b6>
ffffffffc020ac44:	f0d2                	sd	s4,96(sp)
ffffffffc020ac46:	0689ba03          	ld	s4,104(s3)
ffffffffc020ac4a:	1e0a0c63          	beqz	s4,ffffffffc020ae42 <sfs_namefile+0x224>
ffffffffc020ac4e:	0b0a2783          	lw	a5,176(s4)
ffffffffc020ac52:	1e079863          	bnez	a5,ffffffffc020ae42 <sfs_namefile+0x224>
ffffffffc020ac56:	0589a703          	lw	a4,88(s3)
ffffffffc020ac5a:	6785                	lui	a5,0x1
ffffffffc020ac5c:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020ac60:	e03a                	sd	a4,0(sp)
ffffffffc020ac62:	e122                	sd	s0,128(sp)
ffffffffc020ac64:	f8ca                	sd	s2,112(sp)
ffffffffc020ac66:	ecd6                	sd	s5,88(sp)
ffffffffc020ac68:	e8da                	sd	s6,80(sp)
ffffffffc020ac6a:	e4de                	sd	s7,72(sp)
ffffffffc020ac6c:	e0e2                	sd	s8,64(sp)
ffffffffc020ac6e:	1af71963          	bne	a4,a5,ffffffffc020ae20 <sfs_namefile+0x202>
ffffffffc020ac72:	6722                	ld	a4,8(sp)
ffffffffc020ac74:	854e                	mv	a0,s3
ffffffffc020ac76:	8b4e                	mv	s6,s3
ffffffffc020ac78:	6f1c                	ld	a5,24(a4)
ffffffffc020ac7a:	00073a83          	ld	s5,0(a4)
ffffffffc020ac7e:	ffe78c13          	addi	s8,a5,-2
ffffffffc020ac82:	9abe                	add	s5,s5,a5
ffffffffc020ac84:	e11fc0ef          	jal	ffffffffc0207a94 <inode_ref_inc>
ffffffffc020ac88:	0834                	addi	a3,sp,24
ffffffffc020ac8a:	00004617          	auipc	a2,0x4
ffffffffc020ac8e:	f0e60613          	addi	a2,a2,-242 # ffffffffc020eb98 <etext+0x3338>
ffffffffc020ac92:	85da                	mv	a1,s6
ffffffffc020ac94:	8552                	mv	a0,s4
ffffffffc020ac96:	e87ff0ef          	jal	ffffffffc020ab1c <sfs_lookup_once.constprop.0>
ffffffffc020ac9a:	8daa                	mv	s11,a0
ffffffffc020ac9c:	e94d                	bnez	a0,ffffffffc020ad4e <sfs_namefile+0x130>
ffffffffc020ac9e:	854e                	mv	a0,s3
ffffffffc020aca0:	008b2903          	lw	s2,8(s6)
ffffffffc020aca4:	ebffc0ef          	jal	ffffffffc0207b62 <inode_ref_dec>
ffffffffc020aca8:	6462                	ld	s0,24(sp)
ffffffffc020acaa:	0f340563          	beq	s0,s3,ffffffffc020ad94 <sfs_namefile+0x176>
ffffffffc020acae:	14040863          	beqz	s0,ffffffffc020adfe <sfs_namefile+0x1e0>
ffffffffc020acb2:	4c38                	lw	a4,88(s0)
ffffffffc020acb4:	6782                	ld	a5,0(sp)
ffffffffc020acb6:	14f71463          	bne	a4,a5,ffffffffc020adfe <sfs_namefile+0x1e0>
ffffffffc020acba:	4418                	lw	a4,8(s0)
ffffffffc020acbc:	13270063          	beq	a4,s2,ffffffffc020addc <sfs_namefile+0x1be>
ffffffffc020acc0:	6018                	ld	a4,0(s0)
ffffffffc020acc2:	00475703          	lhu	a4,4(a4)
ffffffffc020acc6:	11a71b63          	bne	a4,s10,ffffffffc020addc <sfs_namefile+0x1be>
ffffffffc020acca:	02040b93          	addi	s7,s0,32
ffffffffc020acce:	855e                	mv	a0,s7
ffffffffc020acd0:	927f90ef          	jal	ffffffffc02045f6 <down>
ffffffffc020acd4:	6018                	ld	a4,0(s0)
ffffffffc020acd6:	00872983          	lw	s3,8(a4)
ffffffffc020acda:	0b305763          	blez	s3,ffffffffc020ad88 <sfs_namefile+0x16a>
ffffffffc020acde:	8b22                	mv	s6,s0
ffffffffc020ace0:	a039                	j	ffffffffc020acee <sfs_namefile+0xd0>
ffffffffc020ace2:	4098                	lw	a4,0(s1)
ffffffffc020ace4:	01270e63          	beq	a4,s2,ffffffffc020ad00 <sfs_namefile+0xe2>
ffffffffc020ace8:	2d85                	addiw	s11,s11,1
ffffffffc020acea:	09b98763          	beq	s3,s11,ffffffffc020ad78 <sfs_namefile+0x15a>
ffffffffc020acee:	86a6                	mv	a3,s1
ffffffffc020acf0:	866e                	mv	a2,s11
ffffffffc020acf2:	85a2                	mv	a1,s0
ffffffffc020acf4:	8552                	mv	a0,s4
ffffffffc020acf6:	f36ff0ef          	jal	ffffffffc020a42c <sfs_dirent_read_nolock>
ffffffffc020acfa:	872a                	mv	a4,a0
ffffffffc020acfc:	d17d                	beqz	a0,ffffffffc020ace2 <sfs_namefile+0xc4>
ffffffffc020acfe:	a8b5                	j	ffffffffc020ad7a <sfs_namefile+0x15c>
ffffffffc020ad00:	855e                	mv	a0,s7
ffffffffc020ad02:	8f1f90ef          	jal	ffffffffc02045f2 <up>
ffffffffc020ad06:	00448513          	addi	a0,s1,4
ffffffffc020ad0a:	23b000ef          	jal	ffffffffc020b744 <strlen>
ffffffffc020ad0e:	00150793          	addi	a5,a0,1
ffffffffc020ad12:	0afc6e63          	bltu	s8,a5,ffffffffc020adce <sfs_namefile+0x1b0>
ffffffffc020ad16:	fff54913          	not	s2,a0
ffffffffc020ad1a:	862a                	mv	a2,a0
ffffffffc020ad1c:	00448593          	addi	a1,s1,4
ffffffffc020ad20:	012a8533          	add	a0,s5,s2
ffffffffc020ad24:	40fc0c33          	sub	s8,s8,a5
ffffffffc020ad28:	321000ef          	jal	ffffffffc020b848 <memcpy>
ffffffffc020ad2c:	02f00793          	li	a5,47
ffffffffc020ad30:	fefa8fa3          	sb	a5,-1(s5)
ffffffffc020ad34:	0834                	addi	a3,sp,24
ffffffffc020ad36:	00004617          	auipc	a2,0x4
ffffffffc020ad3a:	e6260613          	addi	a2,a2,-414 # ffffffffc020eb98 <etext+0x3338>
ffffffffc020ad3e:	85da                	mv	a1,s6
ffffffffc020ad40:	8552                	mv	a0,s4
ffffffffc020ad42:	ddbff0ef          	jal	ffffffffc020ab1c <sfs_lookup_once.constprop.0>
ffffffffc020ad46:	89a2                	mv	s3,s0
ffffffffc020ad48:	9aca                	add	s5,s5,s2
ffffffffc020ad4a:	8daa                	mv	s11,a0
ffffffffc020ad4c:	d929                	beqz	a0,ffffffffc020ac9e <sfs_namefile+0x80>
ffffffffc020ad4e:	854e                	mv	a0,s3
ffffffffc020ad50:	e13fc0ef          	jal	ffffffffc0207b62 <inode_ref_dec>
ffffffffc020ad54:	8526                	mv	a0,s1
ffffffffc020ad56:	b10f70ef          	jal	ffffffffc0202066 <kfree>
ffffffffc020ad5a:	640a                	ld	s0,128(sp)
ffffffffc020ad5c:	74e6                	ld	s1,120(sp)
ffffffffc020ad5e:	7946                	ld	s2,112(sp)
ffffffffc020ad60:	79a6                	ld	s3,104(sp)
ffffffffc020ad62:	7a06                	ld	s4,96(sp)
ffffffffc020ad64:	6ae6                	ld	s5,88(sp)
ffffffffc020ad66:	6b46                	ld	s6,80(sp)
ffffffffc020ad68:	6ba6                	ld	s7,72(sp)
ffffffffc020ad6a:	6c06                	ld	s8,64(sp)
ffffffffc020ad6c:	60aa                	ld	ra,136(sp)
ffffffffc020ad6e:	7d42                	ld	s10,48(sp)
ffffffffc020ad70:	856e                	mv	a0,s11
ffffffffc020ad72:	7da2                	ld	s11,40(sp)
ffffffffc020ad74:	6149                	addi	sp,sp,144
ffffffffc020ad76:	8082                	ret
ffffffffc020ad78:	5741                	li	a4,-16
ffffffffc020ad7a:	855e                	mv	a0,s7
ffffffffc020ad7c:	e03a                	sd	a4,0(sp)
ffffffffc020ad7e:	89a2                	mv	s3,s0
ffffffffc020ad80:	873f90ef          	jal	ffffffffc02045f2 <up>
ffffffffc020ad84:	6d82                	ld	s11,0(sp)
ffffffffc020ad86:	b7e1                	j	ffffffffc020ad4e <sfs_namefile+0x130>
ffffffffc020ad88:	855e                	mv	a0,s7
ffffffffc020ad8a:	869f90ef          	jal	ffffffffc02045f2 <up>
ffffffffc020ad8e:	89a2                	mv	s3,s0
ffffffffc020ad90:	5dc1                	li	s11,-16
ffffffffc020ad92:	bf75                	j	ffffffffc020ad4e <sfs_namefile+0x130>
ffffffffc020ad94:	854e                	mv	a0,s3
ffffffffc020ad96:	dcdfc0ef          	jal	ffffffffc0207b62 <inode_ref_dec>
ffffffffc020ad9a:	6922                	ld	s2,8(sp)
ffffffffc020ad9c:	85d6                	mv	a1,s5
ffffffffc020ad9e:	01893403          	ld	s0,24(s2)
ffffffffc020ada2:	00093503          	ld	a0,0(s2)
ffffffffc020ada6:	1479                	addi	s0,s0,-2
ffffffffc020ada8:	41840433          	sub	s0,s0,s8
ffffffffc020adac:	8622                	mv	a2,s0
ffffffffc020adae:	0505                	addi	a0,a0,1
ffffffffc020adb0:	25b000ef          	jal	ffffffffc020b80a <memmove>
ffffffffc020adb4:	02f00713          	li	a4,47
ffffffffc020adb8:	fee50fa3          	sb	a4,-1(a0)
ffffffffc020adbc:	00850733          	add	a4,a0,s0
ffffffffc020adc0:	00070023          	sb	zero,0(a4)
ffffffffc020adc4:	854a                	mv	a0,s2
ffffffffc020adc6:	85a2                	mv	a1,s0
ffffffffc020adc8:	f52fa0ef          	jal	ffffffffc020551a <iobuf_skip>
ffffffffc020adcc:	b761                	j	ffffffffc020ad54 <sfs_namefile+0x136>
ffffffffc020adce:	89a2                	mv	s3,s0
ffffffffc020add0:	5df1                	li	s11,-4
ffffffffc020add2:	bfb5                	j	ffffffffc020ad4e <sfs_namefile+0x130>
ffffffffc020add4:	74e6                	ld	s1,120(sp)
ffffffffc020add6:	79a6                	ld	s3,104(sp)
ffffffffc020add8:	5df1                	li	s11,-4
ffffffffc020adda:	bf49                	j	ffffffffc020ad6c <sfs_namefile+0x14e>
ffffffffc020addc:	00004697          	auipc	a3,0x4
ffffffffc020ade0:	dc468693          	addi	a3,a3,-572 # ffffffffc020eba0 <etext+0x3340>
ffffffffc020ade4:	00001617          	auipc	a2,0x1
ffffffffc020ade8:	eb460613          	addi	a2,a2,-332 # ffffffffc020bc98 <etext+0x438>
ffffffffc020adec:	2f100593          	li	a1,753
ffffffffc020adf0:	00004517          	auipc	a0,0x4
ffffffffc020adf4:	b0850513          	addi	a0,a0,-1272 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020adf8:	fc66                	sd	s9,56(sp)
ffffffffc020adfa:	e50f50ef          	jal	ffffffffc020044a <__panic>
ffffffffc020adfe:	00004697          	auipc	a3,0x4
ffffffffc020ae02:	ac268693          	addi	a3,a3,-1342 # ffffffffc020e8c0 <etext+0x3060>
ffffffffc020ae06:	00001617          	auipc	a2,0x1
ffffffffc020ae0a:	e9260613          	addi	a2,a2,-366 # ffffffffc020bc98 <etext+0x438>
ffffffffc020ae0e:	2f000593          	li	a1,752
ffffffffc020ae12:	00004517          	auipc	a0,0x4
ffffffffc020ae16:	ae650513          	addi	a0,a0,-1306 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020ae1a:	fc66                	sd	s9,56(sp)
ffffffffc020ae1c:	e2ef50ef          	jal	ffffffffc020044a <__panic>
ffffffffc020ae20:	00004697          	auipc	a3,0x4
ffffffffc020ae24:	aa068693          	addi	a3,a3,-1376 # ffffffffc020e8c0 <etext+0x3060>
ffffffffc020ae28:	00001617          	auipc	a2,0x1
ffffffffc020ae2c:	e7060613          	addi	a2,a2,-400 # ffffffffc020bc98 <etext+0x438>
ffffffffc020ae30:	2dd00593          	li	a1,733
ffffffffc020ae34:	00004517          	auipc	a0,0x4
ffffffffc020ae38:	ac450513          	addi	a0,a0,-1340 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020ae3c:	fc66                	sd	s9,56(sp)
ffffffffc020ae3e:	e0cf50ef          	jal	ffffffffc020044a <__panic>
ffffffffc020ae42:	00004697          	auipc	a3,0x4
ffffffffc020ae46:	8d668693          	addi	a3,a3,-1834 # ffffffffc020e718 <etext+0x2eb8>
ffffffffc020ae4a:	00001617          	auipc	a2,0x1
ffffffffc020ae4e:	e4e60613          	addi	a2,a2,-434 # ffffffffc020bc98 <etext+0x438>
ffffffffc020ae52:	2dc00593          	li	a1,732
ffffffffc020ae56:	00004517          	auipc	a0,0x4
ffffffffc020ae5a:	aa250513          	addi	a0,a0,-1374 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020ae5e:	e122                	sd	s0,128(sp)
ffffffffc020ae60:	f8ca                	sd	s2,112(sp)
ffffffffc020ae62:	ecd6                	sd	s5,88(sp)
ffffffffc020ae64:	e8da                	sd	s6,80(sp)
ffffffffc020ae66:	e4de                	sd	s7,72(sp)
ffffffffc020ae68:	e0e2                	sd	s8,64(sp)
ffffffffc020ae6a:	fc66                	sd	s9,56(sp)
ffffffffc020ae6c:	ddef50ef          	jal	ffffffffc020044a <__panic>

ffffffffc020ae70 <sfs_lookup>:
ffffffffc020ae70:	7139                	addi	sp,sp,-64
ffffffffc020ae72:	f426                	sd	s1,40(sp)
ffffffffc020ae74:	7524                	ld	s1,104(a0)
ffffffffc020ae76:	fc06                	sd	ra,56(sp)
ffffffffc020ae78:	f822                	sd	s0,48(sp)
ffffffffc020ae7a:	f04a                	sd	s2,32(sp)
ffffffffc020ae7c:	c4b5                	beqz	s1,ffffffffc020aee8 <sfs_lookup+0x78>
ffffffffc020ae7e:	0b04a783          	lw	a5,176(s1)
ffffffffc020ae82:	e3bd                	bnez	a5,ffffffffc020aee8 <sfs_lookup+0x78>
ffffffffc020ae84:	0005c783          	lbu	a5,0(a1)
ffffffffc020ae88:	c3c5                	beqz	a5,ffffffffc020af28 <sfs_lookup+0xb8>
ffffffffc020ae8a:	fd178793          	addi	a5,a5,-47
ffffffffc020ae8e:	cfc9                	beqz	a5,ffffffffc020af28 <sfs_lookup+0xb8>
ffffffffc020ae90:	842a                	mv	s0,a0
ffffffffc020ae92:	8932                	mv	s2,a2
ffffffffc020ae94:	e42e                	sd	a1,8(sp)
ffffffffc020ae96:	bfffc0ef          	jal	ffffffffc0207a94 <inode_ref_inc>
ffffffffc020ae9a:	4c38                	lw	a4,88(s0)
ffffffffc020ae9c:	6785                	lui	a5,0x1
ffffffffc020ae9e:	23578793          	addi	a5,a5,565 # 1235 <_binary_bin_swap_img_size-0x6acb>
ffffffffc020aea2:	06f71363          	bne	a4,a5,ffffffffc020af08 <sfs_lookup+0x98>
ffffffffc020aea6:	6018                	ld	a4,0(s0)
ffffffffc020aea8:	4789                	li	a5,2
ffffffffc020aeaa:	00475703          	lhu	a4,4(a4)
ffffffffc020aeae:	02f71863          	bne	a4,a5,ffffffffc020aede <sfs_lookup+0x6e>
ffffffffc020aeb2:	6622                	ld	a2,8(sp)
ffffffffc020aeb4:	85a2                	mv	a1,s0
ffffffffc020aeb6:	8526                	mv	a0,s1
ffffffffc020aeb8:	0834                	addi	a3,sp,24
ffffffffc020aeba:	c63ff0ef          	jal	ffffffffc020ab1c <sfs_lookup_once.constprop.0>
ffffffffc020aebe:	87aa                	mv	a5,a0
ffffffffc020aec0:	8522                	mv	a0,s0
ffffffffc020aec2:	843e                	mv	s0,a5
ffffffffc020aec4:	c9ffc0ef          	jal	ffffffffc0207b62 <inode_ref_dec>
ffffffffc020aec8:	e401                	bnez	s0,ffffffffc020aed0 <sfs_lookup+0x60>
ffffffffc020aeca:	67e2                	ld	a5,24(sp)
ffffffffc020aecc:	00f93023          	sd	a5,0(s2)
ffffffffc020aed0:	70e2                	ld	ra,56(sp)
ffffffffc020aed2:	8522                	mv	a0,s0
ffffffffc020aed4:	7442                	ld	s0,48(sp)
ffffffffc020aed6:	74a2                	ld	s1,40(sp)
ffffffffc020aed8:	7902                	ld	s2,32(sp)
ffffffffc020aeda:	6121                	addi	sp,sp,64
ffffffffc020aedc:	8082                	ret
ffffffffc020aede:	8522                	mv	a0,s0
ffffffffc020aee0:	c83fc0ef          	jal	ffffffffc0207b62 <inode_ref_dec>
ffffffffc020aee4:	5439                	li	s0,-18
ffffffffc020aee6:	b7ed                	j	ffffffffc020aed0 <sfs_lookup+0x60>
ffffffffc020aee8:	00004697          	auipc	a3,0x4
ffffffffc020aeec:	83068693          	addi	a3,a3,-2000 # ffffffffc020e718 <etext+0x2eb8>
ffffffffc020aef0:	00001617          	auipc	a2,0x1
ffffffffc020aef4:	da860613          	addi	a2,a2,-600 # ffffffffc020bc98 <etext+0x438>
ffffffffc020aef8:	3d200593          	li	a1,978
ffffffffc020aefc:	00004517          	auipc	a0,0x4
ffffffffc020af00:	9fc50513          	addi	a0,a0,-1540 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020af04:	d46f50ef          	jal	ffffffffc020044a <__panic>
ffffffffc020af08:	00004697          	auipc	a3,0x4
ffffffffc020af0c:	9b868693          	addi	a3,a3,-1608 # ffffffffc020e8c0 <etext+0x3060>
ffffffffc020af10:	00001617          	auipc	a2,0x1
ffffffffc020af14:	d8860613          	addi	a2,a2,-632 # ffffffffc020bc98 <etext+0x438>
ffffffffc020af18:	3d500593          	li	a1,981
ffffffffc020af1c:	00004517          	auipc	a0,0x4
ffffffffc020af20:	9dc50513          	addi	a0,a0,-1572 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020af24:	d26f50ef          	jal	ffffffffc020044a <__panic>
ffffffffc020af28:	00004697          	auipc	a3,0x4
ffffffffc020af2c:	cb068693          	addi	a3,a3,-848 # ffffffffc020ebd8 <etext+0x3378>
ffffffffc020af30:	00001617          	auipc	a2,0x1
ffffffffc020af34:	d6860613          	addi	a2,a2,-664 # ffffffffc020bc98 <etext+0x438>
ffffffffc020af38:	3d300593          	li	a1,979
ffffffffc020af3c:	00004517          	auipc	a0,0x4
ffffffffc020af40:	9bc50513          	addi	a0,a0,-1604 # ffffffffc020e8f8 <etext+0x3098>
ffffffffc020af44:	d06f50ef          	jal	ffffffffc020044a <__panic>

ffffffffc020af48 <sfs_rwblock_nolock>:
ffffffffc020af48:	7139                	addi	sp,sp,-64
ffffffffc020af4a:	f822                	sd	s0,48(sp)
ffffffffc020af4c:	f426                	sd	s1,40(sp)
ffffffffc020af4e:	fc06                	sd	ra,56(sp)
ffffffffc020af50:	842a                	mv	s0,a0
ffffffffc020af52:	84b6                	mv	s1,a3
ffffffffc020af54:	e219                	bnez	a2,ffffffffc020af5a <sfs_rwblock_nolock+0x12>
ffffffffc020af56:	8b05                	andi	a4,a4,1
ffffffffc020af58:	e71d                	bnez	a4,ffffffffc020af86 <sfs_rwblock_nolock+0x3e>
ffffffffc020af5a:	405c                	lw	a5,4(s0)
ffffffffc020af5c:	02f67563          	bgeu	a2,a5,ffffffffc020af86 <sfs_rwblock_nolock+0x3e>
ffffffffc020af60:	00c6161b          	slliw	a2,a2,0xc
ffffffffc020af64:	02061693          	slli	a3,a2,0x20
ffffffffc020af68:	9281                	srli	a3,a3,0x20
ffffffffc020af6a:	6605                	lui	a2,0x1
ffffffffc020af6c:	850a                	mv	a0,sp
ffffffffc020af6e:	d1efa0ef          	jal	ffffffffc020548c <iobuf_init>
ffffffffc020af72:	85aa                	mv	a1,a0
ffffffffc020af74:	7808                	ld	a0,48(s0)
ffffffffc020af76:	8626                	mv	a2,s1
ffffffffc020af78:	7118                	ld	a4,32(a0)
ffffffffc020af7a:	9702                	jalr	a4
ffffffffc020af7c:	70e2                	ld	ra,56(sp)
ffffffffc020af7e:	7442                	ld	s0,48(sp)
ffffffffc020af80:	74a2                	ld	s1,40(sp)
ffffffffc020af82:	6121                	addi	sp,sp,64
ffffffffc020af84:	8082                	ret
ffffffffc020af86:	00004697          	auipc	a3,0x4
ffffffffc020af8a:	c7268693          	addi	a3,a3,-910 # ffffffffc020ebf8 <etext+0x3398>
ffffffffc020af8e:	00001617          	auipc	a2,0x1
ffffffffc020af92:	d0a60613          	addi	a2,a2,-758 # ffffffffc020bc98 <etext+0x438>
ffffffffc020af96:	45d5                	li	a1,21
ffffffffc020af98:	00004517          	auipc	a0,0x4
ffffffffc020af9c:	c9850513          	addi	a0,a0,-872 # ffffffffc020ec30 <etext+0x33d0>
ffffffffc020afa0:	caaf50ef          	jal	ffffffffc020044a <__panic>

ffffffffc020afa4 <sfs_rblock>:
ffffffffc020afa4:	7139                	addi	sp,sp,-64
ffffffffc020afa6:	ec4e                	sd	s3,24(sp)
ffffffffc020afa8:	89b6                	mv	s3,a3
ffffffffc020afaa:	f822                	sd	s0,48(sp)
ffffffffc020afac:	f04a                	sd	s2,32(sp)
ffffffffc020afae:	e852                	sd	s4,16(sp)
ffffffffc020afb0:	fc06                	sd	ra,56(sp)
ffffffffc020afb2:	f426                	sd	s1,40(sp)
ffffffffc020afb4:	892e                	mv	s2,a1
ffffffffc020afb6:	8432                	mv	s0,a2
ffffffffc020afb8:	8a2a                	mv	s4,a0
ffffffffc020afba:	2ea000ef          	jal	ffffffffc020b2a4 <lock_sfs_io>
ffffffffc020afbe:	02098763          	beqz	s3,ffffffffc020afec <sfs_rblock+0x48>
ffffffffc020afc2:	e456                	sd	s5,8(sp)
ffffffffc020afc4:	013409bb          	addw	s3,s0,s3
ffffffffc020afc8:	6a85                	lui	s5,0x1
ffffffffc020afca:	a021                	j	ffffffffc020afd2 <sfs_rblock+0x2e>
ffffffffc020afcc:	9956                	add	s2,s2,s5
ffffffffc020afce:	01340e63          	beq	s0,s3,ffffffffc020afea <sfs_rblock+0x46>
ffffffffc020afd2:	8622                	mv	a2,s0
ffffffffc020afd4:	4705                	li	a4,1
ffffffffc020afd6:	4681                	li	a3,0
ffffffffc020afd8:	85ca                	mv	a1,s2
ffffffffc020afda:	8552                	mv	a0,s4
ffffffffc020afdc:	f6dff0ef          	jal	ffffffffc020af48 <sfs_rwblock_nolock>
ffffffffc020afe0:	84aa                	mv	s1,a0
ffffffffc020afe2:	2405                	addiw	s0,s0,1
ffffffffc020afe4:	d565                	beqz	a0,ffffffffc020afcc <sfs_rblock+0x28>
ffffffffc020afe6:	6aa2                	ld	s5,8(sp)
ffffffffc020afe8:	a019                	j	ffffffffc020afee <sfs_rblock+0x4a>
ffffffffc020afea:	6aa2                	ld	s5,8(sp)
ffffffffc020afec:	4481                	li	s1,0
ffffffffc020afee:	8552                	mv	a0,s4
ffffffffc020aff0:	2c4000ef          	jal	ffffffffc020b2b4 <unlock_sfs_io>
ffffffffc020aff4:	70e2                	ld	ra,56(sp)
ffffffffc020aff6:	7442                	ld	s0,48(sp)
ffffffffc020aff8:	7902                	ld	s2,32(sp)
ffffffffc020affa:	69e2                	ld	s3,24(sp)
ffffffffc020affc:	6a42                	ld	s4,16(sp)
ffffffffc020affe:	8526                	mv	a0,s1
ffffffffc020b000:	74a2                	ld	s1,40(sp)
ffffffffc020b002:	6121                	addi	sp,sp,64
ffffffffc020b004:	8082                	ret

ffffffffc020b006 <sfs_wblock>:
ffffffffc020b006:	7139                	addi	sp,sp,-64
ffffffffc020b008:	ec4e                	sd	s3,24(sp)
ffffffffc020b00a:	89b6                	mv	s3,a3
ffffffffc020b00c:	f822                	sd	s0,48(sp)
ffffffffc020b00e:	f04a                	sd	s2,32(sp)
ffffffffc020b010:	e852                	sd	s4,16(sp)
ffffffffc020b012:	fc06                	sd	ra,56(sp)
ffffffffc020b014:	f426                	sd	s1,40(sp)
ffffffffc020b016:	892e                	mv	s2,a1
ffffffffc020b018:	8432                	mv	s0,a2
ffffffffc020b01a:	8a2a                	mv	s4,a0
ffffffffc020b01c:	288000ef          	jal	ffffffffc020b2a4 <lock_sfs_io>
ffffffffc020b020:	02098763          	beqz	s3,ffffffffc020b04e <sfs_wblock+0x48>
ffffffffc020b024:	e456                	sd	s5,8(sp)
ffffffffc020b026:	013409bb          	addw	s3,s0,s3
ffffffffc020b02a:	6a85                	lui	s5,0x1
ffffffffc020b02c:	a021                	j	ffffffffc020b034 <sfs_wblock+0x2e>
ffffffffc020b02e:	9956                	add	s2,s2,s5
ffffffffc020b030:	01340e63          	beq	s0,s3,ffffffffc020b04c <sfs_wblock+0x46>
ffffffffc020b034:	4705                	li	a4,1
ffffffffc020b036:	8622                	mv	a2,s0
ffffffffc020b038:	86ba                	mv	a3,a4
ffffffffc020b03a:	85ca                	mv	a1,s2
ffffffffc020b03c:	8552                	mv	a0,s4
ffffffffc020b03e:	f0bff0ef          	jal	ffffffffc020af48 <sfs_rwblock_nolock>
ffffffffc020b042:	84aa                	mv	s1,a0
ffffffffc020b044:	2405                	addiw	s0,s0,1
ffffffffc020b046:	d565                	beqz	a0,ffffffffc020b02e <sfs_wblock+0x28>
ffffffffc020b048:	6aa2                	ld	s5,8(sp)
ffffffffc020b04a:	a019                	j	ffffffffc020b050 <sfs_wblock+0x4a>
ffffffffc020b04c:	6aa2                	ld	s5,8(sp)
ffffffffc020b04e:	4481                	li	s1,0
ffffffffc020b050:	8552                	mv	a0,s4
ffffffffc020b052:	262000ef          	jal	ffffffffc020b2b4 <unlock_sfs_io>
ffffffffc020b056:	70e2                	ld	ra,56(sp)
ffffffffc020b058:	7442                	ld	s0,48(sp)
ffffffffc020b05a:	7902                	ld	s2,32(sp)
ffffffffc020b05c:	69e2                	ld	s3,24(sp)
ffffffffc020b05e:	6a42                	ld	s4,16(sp)
ffffffffc020b060:	8526                	mv	a0,s1
ffffffffc020b062:	74a2                	ld	s1,40(sp)
ffffffffc020b064:	6121                	addi	sp,sp,64
ffffffffc020b066:	8082                	ret

ffffffffc020b068 <sfs_rbuf>:
ffffffffc020b068:	7179                	addi	sp,sp,-48
ffffffffc020b06a:	f406                	sd	ra,40(sp)
ffffffffc020b06c:	f022                	sd	s0,32(sp)
ffffffffc020b06e:	ec26                	sd	s1,24(sp)
ffffffffc020b070:	e84a                	sd	s2,16(sp)
ffffffffc020b072:	e44e                	sd	s3,8(sp)
ffffffffc020b074:	e052                	sd	s4,0(sp)
ffffffffc020b076:	6785                	lui	a5,0x1
ffffffffc020b078:	04f77863          	bgeu	a4,a5,ffffffffc020b0c8 <sfs_rbuf+0x60>
ffffffffc020b07c:	84ba                	mv	s1,a4
ffffffffc020b07e:	9732                	add	a4,a4,a2
ffffffffc020b080:	04e7e463          	bltu	a5,a4,ffffffffc020b0c8 <sfs_rbuf+0x60>
ffffffffc020b084:	8936                	mv	s2,a3
ffffffffc020b086:	842a                	mv	s0,a0
ffffffffc020b088:	89ae                	mv	s3,a1
ffffffffc020b08a:	8a32                	mv	s4,a2
ffffffffc020b08c:	218000ef          	jal	ffffffffc020b2a4 <lock_sfs_io>
ffffffffc020b090:	642c                	ld	a1,72(s0)
ffffffffc020b092:	864a                	mv	a2,s2
ffffffffc020b094:	8522                	mv	a0,s0
ffffffffc020b096:	4705                	li	a4,1
ffffffffc020b098:	4681                	li	a3,0
ffffffffc020b09a:	eafff0ef          	jal	ffffffffc020af48 <sfs_rwblock_nolock>
ffffffffc020b09e:	892a                	mv	s2,a0
ffffffffc020b0a0:	cd09                	beqz	a0,ffffffffc020b0ba <sfs_rbuf+0x52>
ffffffffc020b0a2:	8522                	mv	a0,s0
ffffffffc020b0a4:	210000ef          	jal	ffffffffc020b2b4 <unlock_sfs_io>
ffffffffc020b0a8:	70a2                	ld	ra,40(sp)
ffffffffc020b0aa:	7402                	ld	s0,32(sp)
ffffffffc020b0ac:	64e2                	ld	s1,24(sp)
ffffffffc020b0ae:	69a2                	ld	s3,8(sp)
ffffffffc020b0b0:	6a02                	ld	s4,0(sp)
ffffffffc020b0b2:	854a                	mv	a0,s2
ffffffffc020b0b4:	6942                	ld	s2,16(sp)
ffffffffc020b0b6:	6145                	addi	sp,sp,48
ffffffffc020b0b8:	8082                	ret
ffffffffc020b0ba:	642c                	ld	a1,72(s0)
ffffffffc020b0bc:	8652                	mv	a2,s4
ffffffffc020b0be:	854e                	mv	a0,s3
ffffffffc020b0c0:	95a6                	add	a1,a1,s1
ffffffffc020b0c2:	786000ef          	jal	ffffffffc020b848 <memcpy>
ffffffffc020b0c6:	bff1                	j	ffffffffc020b0a2 <sfs_rbuf+0x3a>
ffffffffc020b0c8:	00004697          	auipc	a3,0x4
ffffffffc020b0cc:	b8068693          	addi	a3,a3,-1152 # ffffffffc020ec48 <etext+0x33e8>
ffffffffc020b0d0:	00001617          	auipc	a2,0x1
ffffffffc020b0d4:	bc860613          	addi	a2,a2,-1080 # ffffffffc020bc98 <etext+0x438>
ffffffffc020b0d8:	05500593          	li	a1,85
ffffffffc020b0dc:	00004517          	auipc	a0,0x4
ffffffffc020b0e0:	b5450513          	addi	a0,a0,-1196 # ffffffffc020ec30 <etext+0x33d0>
ffffffffc020b0e4:	b66f50ef          	jal	ffffffffc020044a <__panic>

ffffffffc020b0e8 <sfs_wbuf>:
ffffffffc020b0e8:	7139                	addi	sp,sp,-64
ffffffffc020b0ea:	fc06                	sd	ra,56(sp)
ffffffffc020b0ec:	f822                	sd	s0,48(sp)
ffffffffc020b0ee:	f426                	sd	s1,40(sp)
ffffffffc020b0f0:	f04a                	sd	s2,32(sp)
ffffffffc020b0f2:	ec4e                	sd	s3,24(sp)
ffffffffc020b0f4:	e852                	sd	s4,16(sp)
ffffffffc020b0f6:	e456                	sd	s5,8(sp)
ffffffffc020b0f8:	6785                	lui	a5,0x1
ffffffffc020b0fa:	06f77163          	bgeu	a4,a5,ffffffffc020b15c <sfs_wbuf+0x74>
ffffffffc020b0fe:	893a                	mv	s2,a4
ffffffffc020b100:	9732                	add	a4,a4,a2
ffffffffc020b102:	04e7ed63          	bltu	a5,a4,ffffffffc020b15c <sfs_wbuf+0x74>
ffffffffc020b106:	89b6                	mv	s3,a3
ffffffffc020b108:	84aa                	mv	s1,a0
ffffffffc020b10a:	8a2e                	mv	s4,a1
ffffffffc020b10c:	8ab2                	mv	s5,a2
ffffffffc020b10e:	196000ef          	jal	ffffffffc020b2a4 <lock_sfs_io>
ffffffffc020b112:	64ac                	ld	a1,72(s1)
ffffffffc020b114:	864e                	mv	a2,s3
ffffffffc020b116:	8526                	mv	a0,s1
ffffffffc020b118:	4705                	li	a4,1
ffffffffc020b11a:	4681                	li	a3,0
ffffffffc020b11c:	e2dff0ef          	jal	ffffffffc020af48 <sfs_rwblock_nolock>
ffffffffc020b120:	842a                	mv	s0,a0
ffffffffc020b122:	cd11                	beqz	a0,ffffffffc020b13e <sfs_wbuf+0x56>
ffffffffc020b124:	8526                	mv	a0,s1
ffffffffc020b126:	18e000ef          	jal	ffffffffc020b2b4 <unlock_sfs_io>
ffffffffc020b12a:	70e2                	ld	ra,56(sp)
ffffffffc020b12c:	8522                	mv	a0,s0
ffffffffc020b12e:	7442                	ld	s0,48(sp)
ffffffffc020b130:	74a2                	ld	s1,40(sp)
ffffffffc020b132:	7902                	ld	s2,32(sp)
ffffffffc020b134:	69e2                	ld	s3,24(sp)
ffffffffc020b136:	6a42                	ld	s4,16(sp)
ffffffffc020b138:	6aa2                	ld	s5,8(sp)
ffffffffc020b13a:	6121                	addi	sp,sp,64
ffffffffc020b13c:	8082                	ret
ffffffffc020b13e:	64a8                	ld	a0,72(s1)
ffffffffc020b140:	8656                	mv	a2,s5
ffffffffc020b142:	85d2                	mv	a1,s4
ffffffffc020b144:	954a                	add	a0,a0,s2
ffffffffc020b146:	702000ef          	jal	ffffffffc020b848 <memcpy>
ffffffffc020b14a:	64ac                	ld	a1,72(s1)
ffffffffc020b14c:	4705                	li	a4,1
ffffffffc020b14e:	864e                	mv	a2,s3
ffffffffc020b150:	8526                	mv	a0,s1
ffffffffc020b152:	86ba                	mv	a3,a4
ffffffffc020b154:	df5ff0ef          	jal	ffffffffc020af48 <sfs_rwblock_nolock>
ffffffffc020b158:	842a                	mv	s0,a0
ffffffffc020b15a:	b7e9                	j	ffffffffc020b124 <sfs_wbuf+0x3c>
ffffffffc020b15c:	00004697          	auipc	a3,0x4
ffffffffc020b160:	aec68693          	addi	a3,a3,-1300 # ffffffffc020ec48 <etext+0x33e8>
ffffffffc020b164:	00001617          	auipc	a2,0x1
ffffffffc020b168:	b3460613          	addi	a2,a2,-1228 # ffffffffc020bc98 <etext+0x438>
ffffffffc020b16c:	06b00593          	li	a1,107
ffffffffc020b170:	00004517          	auipc	a0,0x4
ffffffffc020b174:	ac050513          	addi	a0,a0,-1344 # ffffffffc020ec30 <etext+0x33d0>
ffffffffc020b178:	ad2f50ef          	jal	ffffffffc020044a <__panic>

ffffffffc020b17c <sfs_sync_super>:
ffffffffc020b17c:	1101                	addi	sp,sp,-32
ffffffffc020b17e:	ec06                	sd	ra,24(sp)
ffffffffc020b180:	e822                	sd	s0,16(sp)
ffffffffc020b182:	e426                	sd	s1,8(sp)
ffffffffc020b184:	842a                	mv	s0,a0
ffffffffc020b186:	11e000ef          	jal	ffffffffc020b2a4 <lock_sfs_io>
ffffffffc020b18a:	6428                	ld	a0,72(s0)
ffffffffc020b18c:	6605                	lui	a2,0x1
ffffffffc020b18e:	4581                	li	a1,0
ffffffffc020b190:	668000ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc020b194:	6428                	ld	a0,72(s0)
ffffffffc020b196:	85a2                	mv	a1,s0
ffffffffc020b198:	02c00613          	li	a2,44
ffffffffc020b19c:	6ac000ef          	jal	ffffffffc020b848 <memcpy>
ffffffffc020b1a0:	642c                	ld	a1,72(s0)
ffffffffc020b1a2:	8522                	mv	a0,s0
ffffffffc020b1a4:	4701                	li	a4,0
ffffffffc020b1a6:	4685                	li	a3,1
ffffffffc020b1a8:	4601                	li	a2,0
ffffffffc020b1aa:	d9fff0ef          	jal	ffffffffc020af48 <sfs_rwblock_nolock>
ffffffffc020b1ae:	84aa                	mv	s1,a0
ffffffffc020b1b0:	8522                	mv	a0,s0
ffffffffc020b1b2:	102000ef          	jal	ffffffffc020b2b4 <unlock_sfs_io>
ffffffffc020b1b6:	60e2                	ld	ra,24(sp)
ffffffffc020b1b8:	6442                	ld	s0,16(sp)
ffffffffc020b1ba:	8526                	mv	a0,s1
ffffffffc020b1bc:	64a2                	ld	s1,8(sp)
ffffffffc020b1be:	6105                	addi	sp,sp,32
ffffffffc020b1c0:	8082                	ret

ffffffffc020b1c2 <sfs_sync_freemap>:
ffffffffc020b1c2:	7139                	addi	sp,sp,-64
ffffffffc020b1c4:	ec4e                	sd	s3,24(sp)
ffffffffc020b1c6:	e852                	sd	s4,16(sp)
ffffffffc020b1c8:	00456983          	lwu	s3,4(a0)
ffffffffc020b1cc:	8a2a                	mv	s4,a0
ffffffffc020b1ce:	7d08                	ld	a0,56(a0)
ffffffffc020b1d0:	67a1                	lui	a5,0x8
ffffffffc020b1d2:	17fd                	addi	a5,a5,-1 # 7fff <_binary_bin_swap_img_size+0x2ff>
ffffffffc020b1d4:	4581                	li	a1,0
ffffffffc020b1d6:	f822                	sd	s0,48(sp)
ffffffffc020b1d8:	fc06                	sd	ra,56(sp)
ffffffffc020b1da:	f426                	sd	s1,40(sp)
ffffffffc020b1dc:	99be                	add	s3,s3,a5
ffffffffc020b1de:	954fe0ef          	jal	ffffffffc0209332 <bitmap_getdata>
ffffffffc020b1e2:	00f9d993          	srli	s3,s3,0xf
ffffffffc020b1e6:	842a                	mv	s0,a0
ffffffffc020b1e8:	8552                	mv	a0,s4
ffffffffc020b1ea:	0ba000ef          	jal	ffffffffc020b2a4 <lock_sfs_io>
ffffffffc020b1ee:	02098b63          	beqz	s3,ffffffffc020b224 <sfs_sync_freemap+0x62>
ffffffffc020b1f2:	09b2                	slli	s3,s3,0xc
ffffffffc020b1f4:	f04a                	sd	s2,32(sp)
ffffffffc020b1f6:	e456                	sd	s5,8(sp)
ffffffffc020b1f8:	99a2                	add	s3,s3,s0
ffffffffc020b1fa:	4909                	li	s2,2
ffffffffc020b1fc:	6a85                	lui	s5,0x1
ffffffffc020b1fe:	a021                	j	ffffffffc020b206 <sfs_sync_freemap+0x44>
ffffffffc020b200:	2905                	addiw	s2,s2,1
ffffffffc020b202:	01340f63          	beq	s0,s3,ffffffffc020b220 <sfs_sync_freemap+0x5e>
ffffffffc020b206:	4705                	li	a4,1
ffffffffc020b208:	85a2                	mv	a1,s0
ffffffffc020b20a:	86ba                	mv	a3,a4
ffffffffc020b20c:	864a                	mv	a2,s2
ffffffffc020b20e:	8552                	mv	a0,s4
ffffffffc020b210:	d39ff0ef          	jal	ffffffffc020af48 <sfs_rwblock_nolock>
ffffffffc020b214:	84aa                	mv	s1,a0
ffffffffc020b216:	9456                	add	s0,s0,s5
ffffffffc020b218:	d565                	beqz	a0,ffffffffc020b200 <sfs_sync_freemap+0x3e>
ffffffffc020b21a:	7902                	ld	s2,32(sp)
ffffffffc020b21c:	6aa2                	ld	s5,8(sp)
ffffffffc020b21e:	a021                	j	ffffffffc020b226 <sfs_sync_freemap+0x64>
ffffffffc020b220:	7902                	ld	s2,32(sp)
ffffffffc020b222:	6aa2                	ld	s5,8(sp)
ffffffffc020b224:	4481                	li	s1,0
ffffffffc020b226:	8552                	mv	a0,s4
ffffffffc020b228:	08c000ef          	jal	ffffffffc020b2b4 <unlock_sfs_io>
ffffffffc020b22c:	70e2                	ld	ra,56(sp)
ffffffffc020b22e:	7442                	ld	s0,48(sp)
ffffffffc020b230:	69e2                	ld	s3,24(sp)
ffffffffc020b232:	6a42                	ld	s4,16(sp)
ffffffffc020b234:	8526                	mv	a0,s1
ffffffffc020b236:	74a2                	ld	s1,40(sp)
ffffffffc020b238:	6121                	addi	sp,sp,64
ffffffffc020b23a:	8082                	ret

ffffffffc020b23c <sfs_clear_block>:
ffffffffc020b23c:	7179                	addi	sp,sp,-48
ffffffffc020b23e:	f022                	sd	s0,32(sp)
ffffffffc020b240:	e84a                	sd	s2,16(sp)
ffffffffc020b242:	e44e                	sd	s3,8(sp)
ffffffffc020b244:	f406                	sd	ra,40(sp)
ffffffffc020b246:	89b2                	mv	s3,a2
ffffffffc020b248:	ec26                	sd	s1,24(sp)
ffffffffc020b24a:	842e                	mv	s0,a1
ffffffffc020b24c:	892a                	mv	s2,a0
ffffffffc020b24e:	056000ef          	jal	ffffffffc020b2a4 <lock_sfs_io>
ffffffffc020b252:	04893503          	ld	a0,72(s2)
ffffffffc020b256:	6605                	lui	a2,0x1
ffffffffc020b258:	4581                	li	a1,0
ffffffffc020b25a:	59e000ef          	jal	ffffffffc020b7f8 <memset>
ffffffffc020b25e:	02098d63          	beqz	s3,ffffffffc020b298 <sfs_clear_block+0x5c>
ffffffffc020b262:	013409bb          	addw	s3,s0,s3
ffffffffc020b266:	a019                	j	ffffffffc020b26c <sfs_clear_block+0x30>
ffffffffc020b268:	03340863          	beq	s0,s3,ffffffffc020b298 <sfs_clear_block+0x5c>
ffffffffc020b26c:	04893583          	ld	a1,72(s2)
ffffffffc020b270:	4705                	li	a4,1
ffffffffc020b272:	8622                	mv	a2,s0
ffffffffc020b274:	86ba                	mv	a3,a4
ffffffffc020b276:	854a                	mv	a0,s2
ffffffffc020b278:	cd1ff0ef          	jal	ffffffffc020af48 <sfs_rwblock_nolock>
ffffffffc020b27c:	84aa                	mv	s1,a0
ffffffffc020b27e:	2405                	addiw	s0,s0,1
ffffffffc020b280:	d565                	beqz	a0,ffffffffc020b268 <sfs_clear_block+0x2c>
ffffffffc020b282:	854a                	mv	a0,s2
ffffffffc020b284:	030000ef          	jal	ffffffffc020b2b4 <unlock_sfs_io>
ffffffffc020b288:	70a2                	ld	ra,40(sp)
ffffffffc020b28a:	7402                	ld	s0,32(sp)
ffffffffc020b28c:	6942                	ld	s2,16(sp)
ffffffffc020b28e:	69a2                	ld	s3,8(sp)
ffffffffc020b290:	8526                	mv	a0,s1
ffffffffc020b292:	64e2                	ld	s1,24(sp)
ffffffffc020b294:	6145                	addi	sp,sp,48
ffffffffc020b296:	8082                	ret
ffffffffc020b298:	4481                	li	s1,0
ffffffffc020b29a:	b7e5                	j	ffffffffc020b282 <sfs_clear_block+0x46>

ffffffffc020b29c <lock_sfs_fs>:
ffffffffc020b29c:	05050513          	addi	a0,a0,80
ffffffffc020b2a0:	b56f906f          	j	ffffffffc02045f6 <down>

ffffffffc020b2a4 <lock_sfs_io>:
ffffffffc020b2a4:	06850513          	addi	a0,a0,104
ffffffffc020b2a8:	b4ef906f          	j	ffffffffc02045f6 <down>

ffffffffc020b2ac <unlock_sfs_fs>:
ffffffffc020b2ac:	05050513          	addi	a0,a0,80
ffffffffc020b2b0:	b42f906f          	j	ffffffffc02045f2 <up>

ffffffffc020b2b4 <unlock_sfs_io>:
ffffffffc020b2b4:	06850513          	addi	a0,a0,104
ffffffffc020b2b8:	b3af906f          	j	ffffffffc02045f2 <up>

ffffffffc020b2bc <hash32>:
ffffffffc020b2bc:	9e3707b7          	lui	a5,0x9e370
ffffffffc020b2c0:	2785                	addiw	a5,a5,1 # ffffffff9e370001 <_binary_bin_sfs_img_size+0xffffffff9e2fad01>
ffffffffc020b2c2:	02a787bb          	mulw	a5,a5,a0
ffffffffc020b2c6:	02000513          	li	a0,32
ffffffffc020b2ca:	9d0d                	subw	a0,a0,a1
ffffffffc020b2cc:	00a7d53b          	srlw	a0,a5,a0
ffffffffc020b2d0:	8082                	ret

ffffffffc020b2d2 <printnum>:
ffffffffc020b2d2:	7139                	addi	sp,sp,-64
ffffffffc020b2d4:	02071893          	slli	a7,a4,0x20
ffffffffc020b2d8:	f822                	sd	s0,48(sp)
ffffffffc020b2da:	f426                	sd	s1,40(sp)
ffffffffc020b2dc:	f04a                	sd	s2,32(sp)
ffffffffc020b2de:	ec4e                	sd	s3,24(sp)
ffffffffc020b2e0:	e456                	sd	s5,8(sp)
ffffffffc020b2e2:	0208d893          	srli	a7,a7,0x20
ffffffffc020b2e6:	fc06                	sd	ra,56(sp)
ffffffffc020b2e8:	0316fab3          	remu	s5,a3,a7
ffffffffc020b2ec:	fff7841b          	addiw	s0,a5,-1
ffffffffc020b2f0:	84aa                	mv	s1,a0
ffffffffc020b2f2:	89ae                	mv	s3,a1
ffffffffc020b2f4:	8932                	mv	s2,a2
ffffffffc020b2f6:	0516f063          	bgeu	a3,a7,ffffffffc020b336 <printnum+0x64>
ffffffffc020b2fa:	e852                	sd	s4,16(sp)
ffffffffc020b2fc:	4705                	li	a4,1
ffffffffc020b2fe:	8a42                	mv	s4,a6
ffffffffc020b300:	00f75863          	bge	a4,a5,ffffffffc020b310 <printnum+0x3e>
ffffffffc020b304:	864e                	mv	a2,s3
ffffffffc020b306:	85ca                	mv	a1,s2
ffffffffc020b308:	8552                	mv	a0,s4
ffffffffc020b30a:	347d                	addiw	s0,s0,-1
ffffffffc020b30c:	9482                	jalr	s1
ffffffffc020b30e:	f87d                	bnez	s0,ffffffffc020b304 <printnum+0x32>
ffffffffc020b310:	6a42                	ld	s4,16(sp)
ffffffffc020b312:	00004797          	auipc	a5,0x4
ffffffffc020b316:	97e78793          	addi	a5,a5,-1666 # ffffffffc020ec90 <etext+0x3430>
ffffffffc020b31a:	97d6                	add	a5,a5,s5
ffffffffc020b31c:	7442                	ld	s0,48(sp)
ffffffffc020b31e:	0007c503          	lbu	a0,0(a5)
ffffffffc020b322:	70e2                	ld	ra,56(sp)
ffffffffc020b324:	6aa2                	ld	s5,8(sp)
ffffffffc020b326:	864e                	mv	a2,s3
ffffffffc020b328:	85ca                	mv	a1,s2
ffffffffc020b32a:	69e2                	ld	s3,24(sp)
ffffffffc020b32c:	7902                	ld	s2,32(sp)
ffffffffc020b32e:	87a6                	mv	a5,s1
ffffffffc020b330:	74a2                	ld	s1,40(sp)
ffffffffc020b332:	6121                	addi	sp,sp,64
ffffffffc020b334:	8782                	jr	a5
ffffffffc020b336:	0316d6b3          	divu	a3,a3,a7
ffffffffc020b33a:	87a2                	mv	a5,s0
ffffffffc020b33c:	f97ff0ef          	jal	ffffffffc020b2d2 <printnum>
ffffffffc020b340:	bfc9                	j	ffffffffc020b312 <printnum+0x40>

ffffffffc020b342 <sprintputch>:
ffffffffc020b342:	499c                	lw	a5,16(a1)
ffffffffc020b344:	6198                	ld	a4,0(a1)
ffffffffc020b346:	6594                	ld	a3,8(a1)
ffffffffc020b348:	2785                	addiw	a5,a5,1
ffffffffc020b34a:	c99c                	sw	a5,16(a1)
ffffffffc020b34c:	00d77763          	bgeu	a4,a3,ffffffffc020b35a <sprintputch+0x18>
ffffffffc020b350:	00170793          	addi	a5,a4,1
ffffffffc020b354:	e19c                	sd	a5,0(a1)
ffffffffc020b356:	00a70023          	sb	a0,0(a4)
ffffffffc020b35a:	8082                	ret

ffffffffc020b35c <vprintfmt>:
ffffffffc020b35c:	7119                	addi	sp,sp,-128
ffffffffc020b35e:	f4a6                	sd	s1,104(sp)
ffffffffc020b360:	f0ca                	sd	s2,96(sp)
ffffffffc020b362:	ecce                	sd	s3,88(sp)
ffffffffc020b364:	e8d2                	sd	s4,80(sp)
ffffffffc020b366:	e4d6                	sd	s5,72(sp)
ffffffffc020b368:	e0da                	sd	s6,64(sp)
ffffffffc020b36a:	fc5e                	sd	s7,56(sp)
ffffffffc020b36c:	f466                	sd	s9,40(sp)
ffffffffc020b36e:	fc86                	sd	ra,120(sp)
ffffffffc020b370:	f8a2                	sd	s0,112(sp)
ffffffffc020b372:	f862                	sd	s8,48(sp)
ffffffffc020b374:	f06a                	sd	s10,32(sp)
ffffffffc020b376:	ec6e                	sd	s11,24(sp)
ffffffffc020b378:	84aa                	mv	s1,a0
ffffffffc020b37a:	8cb6                	mv	s9,a3
ffffffffc020b37c:	8aba                	mv	s5,a4
ffffffffc020b37e:	89ae                	mv	s3,a1
ffffffffc020b380:	8932                	mv	s2,a2
ffffffffc020b382:	02500a13          	li	s4,37
ffffffffc020b386:	05500b93          	li	s7,85
ffffffffc020b38a:	00004b17          	auipc	s6,0x4
ffffffffc020b38e:	5aeb0b13          	addi	s6,s6,1454 # ffffffffc020f938 <sfs_node_dirops+0x80>
ffffffffc020b392:	000cc503          	lbu	a0,0(s9)
ffffffffc020b396:	001c8413          	addi	s0,s9,1
ffffffffc020b39a:	01450b63          	beq	a0,s4,ffffffffc020b3b0 <vprintfmt+0x54>
ffffffffc020b39e:	cd15                	beqz	a0,ffffffffc020b3da <vprintfmt+0x7e>
ffffffffc020b3a0:	864e                	mv	a2,s3
ffffffffc020b3a2:	85ca                	mv	a1,s2
ffffffffc020b3a4:	9482                	jalr	s1
ffffffffc020b3a6:	00044503          	lbu	a0,0(s0)
ffffffffc020b3aa:	0405                	addi	s0,s0,1
ffffffffc020b3ac:	ff4519e3          	bne	a0,s4,ffffffffc020b39e <vprintfmt+0x42>
ffffffffc020b3b0:	5d7d                	li	s10,-1
ffffffffc020b3b2:	8dea                	mv	s11,s10
ffffffffc020b3b4:	02000813          	li	a6,32
ffffffffc020b3b8:	4c01                	li	s8,0
ffffffffc020b3ba:	4581                	li	a1,0
ffffffffc020b3bc:	00044703          	lbu	a4,0(s0)
ffffffffc020b3c0:	00140c93          	addi	s9,s0,1
ffffffffc020b3c4:	fdd7061b          	addiw	a2,a4,-35
ffffffffc020b3c8:	0ff67613          	zext.b	a2,a2
ffffffffc020b3cc:	02cbe663          	bltu	s7,a2,ffffffffc020b3f8 <vprintfmt+0x9c>
ffffffffc020b3d0:	060a                	slli	a2,a2,0x2
ffffffffc020b3d2:	965a                	add	a2,a2,s6
ffffffffc020b3d4:	421c                	lw	a5,0(a2)
ffffffffc020b3d6:	97da                	add	a5,a5,s6
ffffffffc020b3d8:	8782                	jr	a5
ffffffffc020b3da:	70e6                	ld	ra,120(sp)
ffffffffc020b3dc:	7446                	ld	s0,112(sp)
ffffffffc020b3de:	74a6                	ld	s1,104(sp)
ffffffffc020b3e0:	7906                	ld	s2,96(sp)
ffffffffc020b3e2:	69e6                	ld	s3,88(sp)
ffffffffc020b3e4:	6a46                	ld	s4,80(sp)
ffffffffc020b3e6:	6aa6                	ld	s5,72(sp)
ffffffffc020b3e8:	6b06                	ld	s6,64(sp)
ffffffffc020b3ea:	7be2                	ld	s7,56(sp)
ffffffffc020b3ec:	7c42                	ld	s8,48(sp)
ffffffffc020b3ee:	7ca2                	ld	s9,40(sp)
ffffffffc020b3f0:	7d02                	ld	s10,32(sp)
ffffffffc020b3f2:	6de2                	ld	s11,24(sp)
ffffffffc020b3f4:	6109                	addi	sp,sp,128
ffffffffc020b3f6:	8082                	ret
ffffffffc020b3f8:	864e                	mv	a2,s3
ffffffffc020b3fa:	85ca                	mv	a1,s2
ffffffffc020b3fc:	02500513          	li	a0,37
ffffffffc020b400:	9482                	jalr	s1
ffffffffc020b402:	fff44783          	lbu	a5,-1(s0)
ffffffffc020b406:	02500713          	li	a4,37
ffffffffc020b40a:	8ca2                	mv	s9,s0
ffffffffc020b40c:	f8e783e3          	beq	a5,a4,ffffffffc020b392 <vprintfmt+0x36>
ffffffffc020b410:	ffecc783          	lbu	a5,-2(s9)
ffffffffc020b414:	1cfd                	addi	s9,s9,-1
ffffffffc020b416:	fee79de3          	bne	a5,a4,ffffffffc020b410 <vprintfmt+0xb4>
ffffffffc020b41a:	bfa5                	j	ffffffffc020b392 <vprintfmt+0x36>
ffffffffc020b41c:	00144683          	lbu	a3,1(s0)
ffffffffc020b420:	4525                	li	a0,9
ffffffffc020b422:	fd070d1b          	addiw	s10,a4,-48
ffffffffc020b426:	fd06879b          	addiw	a5,a3,-48
ffffffffc020b42a:	28f56063          	bltu	a0,a5,ffffffffc020b6aa <vprintfmt+0x34e>
ffffffffc020b42e:	2681                	sext.w	a3,a3
ffffffffc020b430:	8466                	mv	s0,s9
ffffffffc020b432:	002d179b          	slliw	a5,s10,0x2
ffffffffc020b436:	00144703          	lbu	a4,1(s0)
ffffffffc020b43a:	01a787bb          	addw	a5,a5,s10
ffffffffc020b43e:	0017979b          	slliw	a5,a5,0x1
ffffffffc020b442:	9fb5                	addw	a5,a5,a3
ffffffffc020b444:	fd07061b          	addiw	a2,a4,-48
ffffffffc020b448:	0405                	addi	s0,s0,1
ffffffffc020b44a:	fd078d1b          	addiw	s10,a5,-48
ffffffffc020b44e:	0007069b          	sext.w	a3,a4
ffffffffc020b452:	fec570e3          	bgeu	a0,a2,ffffffffc020b432 <vprintfmt+0xd6>
ffffffffc020b456:	f60dd3e3          	bgez	s11,ffffffffc020b3bc <vprintfmt+0x60>
ffffffffc020b45a:	8dea                	mv	s11,s10
ffffffffc020b45c:	5d7d                	li	s10,-1
ffffffffc020b45e:	bfb9                	j	ffffffffc020b3bc <vprintfmt+0x60>
ffffffffc020b460:	883a                	mv	a6,a4
ffffffffc020b462:	8466                	mv	s0,s9
ffffffffc020b464:	bfa1                	j	ffffffffc020b3bc <vprintfmt+0x60>
ffffffffc020b466:	8466                	mv	s0,s9
ffffffffc020b468:	4c05                	li	s8,1
ffffffffc020b46a:	bf89                	j	ffffffffc020b3bc <vprintfmt+0x60>
ffffffffc020b46c:	4785                	li	a5,1
ffffffffc020b46e:	008a8613          	addi	a2,s5,8 # 1008 <_binary_bin_swap_img_size-0x6cf8>
ffffffffc020b472:	00b7c463          	blt	a5,a1,ffffffffc020b47a <vprintfmt+0x11e>
ffffffffc020b476:	1c058363          	beqz	a1,ffffffffc020b63c <vprintfmt+0x2e0>
ffffffffc020b47a:	000ab683          	ld	a3,0(s5)
ffffffffc020b47e:	4741                	li	a4,16
ffffffffc020b480:	8ab2                	mv	s5,a2
ffffffffc020b482:	2801                	sext.w	a6,a6
ffffffffc020b484:	87ee                	mv	a5,s11
ffffffffc020b486:	864a                	mv	a2,s2
ffffffffc020b488:	85ce                	mv	a1,s3
ffffffffc020b48a:	8526                	mv	a0,s1
ffffffffc020b48c:	e47ff0ef          	jal	ffffffffc020b2d2 <printnum>
ffffffffc020b490:	b709                	j	ffffffffc020b392 <vprintfmt+0x36>
ffffffffc020b492:	000aa503          	lw	a0,0(s5)
ffffffffc020b496:	864e                	mv	a2,s3
ffffffffc020b498:	85ca                	mv	a1,s2
ffffffffc020b49a:	9482                	jalr	s1
ffffffffc020b49c:	0aa1                	addi	s5,s5,8
ffffffffc020b49e:	bdd5                	j	ffffffffc020b392 <vprintfmt+0x36>
ffffffffc020b4a0:	4785                	li	a5,1
ffffffffc020b4a2:	008a8613          	addi	a2,s5,8
ffffffffc020b4a6:	00b7c463          	blt	a5,a1,ffffffffc020b4ae <vprintfmt+0x152>
ffffffffc020b4aa:	18058463          	beqz	a1,ffffffffc020b632 <vprintfmt+0x2d6>
ffffffffc020b4ae:	000ab683          	ld	a3,0(s5)
ffffffffc020b4b2:	4729                	li	a4,10
ffffffffc020b4b4:	8ab2                	mv	s5,a2
ffffffffc020b4b6:	b7f1                	j	ffffffffc020b482 <vprintfmt+0x126>
ffffffffc020b4b8:	864e                	mv	a2,s3
ffffffffc020b4ba:	85ca                	mv	a1,s2
ffffffffc020b4bc:	03000513          	li	a0,48
ffffffffc020b4c0:	e042                	sd	a6,0(sp)
ffffffffc020b4c2:	9482                	jalr	s1
ffffffffc020b4c4:	864e                	mv	a2,s3
ffffffffc020b4c6:	85ca                	mv	a1,s2
ffffffffc020b4c8:	07800513          	li	a0,120
ffffffffc020b4cc:	9482                	jalr	s1
ffffffffc020b4ce:	000ab683          	ld	a3,0(s5)
ffffffffc020b4d2:	6802                	ld	a6,0(sp)
ffffffffc020b4d4:	4741                	li	a4,16
ffffffffc020b4d6:	0aa1                	addi	s5,s5,8
ffffffffc020b4d8:	b76d                	j	ffffffffc020b482 <vprintfmt+0x126>
ffffffffc020b4da:	864e                	mv	a2,s3
ffffffffc020b4dc:	85ca                	mv	a1,s2
ffffffffc020b4de:	02500513          	li	a0,37
ffffffffc020b4e2:	9482                	jalr	s1
ffffffffc020b4e4:	b57d                	j	ffffffffc020b392 <vprintfmt+0x36>
ffffffffc020b4e6:	000aad03          	lw	s10,0(s5)
ffffffffc020b4ea:	8466                	mv	s0,s9
ffffffffc020b4ec:	0aa1                	addi	s5,s5,8
ffffffffc020b4ee:	b7a5                	j	ffffffffc020b456 <vprintfmt+0xfa>
ffffffffc020b4f0:	4785                	li	a5,1
ffffffffc020b4f2:	008a8613          	addi	a2,s5,8
ffffffffc020b4f6:	00b7c463          	blt	a5,a1,ffffffffc020b4fe <vprintfmt+0x1a2>
ffffffffc020b4fa:	12058763          	beqz	a1,ffffffffc020b628 <vprintfmt+0x2cc>
ffffffffc020b4fe:	000ab683          	ld	a3,0(s5)
ffffffffc020b502:	4721                	li	a4,8
ffffffffc020b504:	8ab2                	mv	s5,a2
ffffffffc020b506:	bfb5                	j	ffffffffc020b482 <vprintfmt+0x126>
ffffffffc020b508:	87ee                	mv	a5,s11
ffffffffc020b50a:	000dd363          	bgez	s11,ffffffffc020b510 <vprintfmt+0x1b4>
ffffffffc020b50e:	4781                	li	a5,0
ffffffffc020b510:	00078d9b          	sext.w	s11,a5
ffffffffc020b514:	8466                	mv	s0,s9
ffffffffc020b516:	b55d                	j	ffffffffc020b3bc <vprintfmt+0x60>
ffffffffc020b518:	0008041b          	sext.w	s0,a6
ffffffffc020b51c:	fd340793          	addi	a5,s0,-45
ffffffffc020b520:	01b02733          	sgtz	a4,s11
ffffffffc020b524:	00f037b3          	snez	a5,a5
ffffffffc020b528:	8ff9                	and	a5,a5,a4
ffffffffc020b52a:	000ab703          	ld	a4,0(s5)
ffffffffc020b52e:	008a8693          	addi	a3,s5,8
ffffffffc020b532:	e436                	sd	a3,8(sp)
ffffffffc020b534:	12070563          	beqz	a4,ffffffffc020b65e <vprintfmt+0x302>
ffffffffc020b538:	12079d63          	bnez	a5,ffffffffc020b672 <vprintfmt+0x316>
ffffffffc020b53c:	00074783          	lbu	a5,0(a4)
ffffffffc020b540:	0007851b          	sext.w	a0,a5
ffffffffc020b544:	c78d                	beqz	a5,ffffffffc020b56e <vprintfmt+0x212>
ffffffffc020b546:	00170a93          	addi	s5,a4,1
ffffffffc020b54a:	547d                	li	s0,-1
ffffffffc020b54c:	000d4563          	bltz	s10,ffffffffc020b556 <vprintfmt+0x1fa>
ffffffffc020b550:	3d7d                	addiw	s10,s10,-1
ffffffffc020b552:	008d0e63          	beq	s10,s0,ffffffffc020b56e <vprintfmt+0x212>
ffffffffc020b556:	020c1863          	bnez	s8,ffffffffc020b586 <vprintfmt+0x22a>
ffffffffc020b55a:	864e                	mv	a2,s3
ffffffffc020b55c:	85ca                	mv	a1,s2
ffffffffc020b55e:	9482                	jalr	s1
ffffffffc020b560:	000ac783          	lbu	a5,0(s5)
ffffffffc020b564:	0a85                	addi	s5,s5,1
ffffffffc020b566:	3dfd                	addiw	s11,s11,-1
ffffffffc020b568:	0007851b          	sext.w	a0,a5
ffffffffc020b56c:	f3e5                	bnez	a5,ffffffffc020b54c <vprintfmt+0x1f0>
ffffffffc020b56e:	01b05a63          	blez	s11,ffffffffc020b582 <vprintfmt+0x226>
ffffffffc020b572:	864e                	mv	a2,s3
ffffffffc020b574:	85ca                	mv	a1,s2
ffffffffc020b576:	02000513          	li	a0,32
ffffffffc020b57a:	3dfd                	addiw	s11,s11,-1
ffffffffc020b57c:	9482                	jalr	s1
ffffffffc020b57e:	fe0d9ae3          	bnez	s11,ffffffffc020b572 <vprintfmt+0x216>
ffffffffc020b582:	6aa2                	ld	s5,8(sp)
ffffffffc020b584:	b539                	j	ffffffffc020b392 <vprintfmt+0x36>
ffffffffc020b586:	3781                	addiw	a5,a5,-32
ffffffffc020b588:	05e00713          	li	a4,94
ffffffffc020b58c:	fcf777e3          	bgeu	a4,a5,ffffffffc020b55a <vprintfmt+0x1fe>
ffffffffc020b590:	03f00513          	li	a0,63
ffffffffc020b594:	864e                	mv	a2,s3
ffffffffc020b596:	85ca                	mv	a1,s2
ffffffffc020b598:	9482                	jalr	s1
ffffffffc020b59a:	000ac783          	lbu	a5,0(s5)
ffffffffc020b59e:	0a85                	addi	s5,s5,1
ffffffffc020b5a0:	3dfd                	addiw	s11,s11,-1
ffffffffc020b5a2:	0007851b          	sext.w	a0,a5
ffffffffc020b5a6:	d7e1                	beqz	a5,ffffffffc020b56e <vprintfmt+0x212>
ffffffffc020b5a8:	fa0d54e3          	bgez	s10,ffffffffc020b550 <vprintfmt+0x1f4>
ffffffffc020b5ac:	bfe9                	j	ffffffffc020b586 <vprintfmt+0x22a>
ffffffffc020b5ae:	000aa783          	lw	a5,0(s5)
ffffffffc020b5b2:	46e1                	li	a3,24
ffffffffc020b5b4:	0aa1                	addi	s5,s5,8
ffffffffc020b5b6:	41f7d71b          	sraiw	a4,a5,0x1f
ffffffffc020b5ba:	8fb9                	xor	a5,a5,a4
ffffffffc020b5bc:	40e7873b          	subw	a4,a5,a4
ffffffffc020b5c0:	02e6c663          	blt	a3,a4,ffffffffc020b5ec <vprintfmt+0x290>
ffffffffc020b5c4:	00004797          	auipc	a5,0x4
ffffffffc020b5c8:	4cc78793          	addi	a5,a5,1228 # ffffffffc020fa90 <error_string>
ffffffffc020b5cc:	00371693          	slli	a3,a4,0x3
ffffffffc020b5d0:	97b6                	add	a5,a5,a3
ffffffffc020b5d2:	639c                	ld	a5,0(a5)
ffffffffc020b5d4:	cf81                	beqz	a5,ffffffffc020b5ec <vprintfmt+0x290>
ffffffffc020b5d6:	873e                	mv	a4,a5
ffffffffc020b5d8:	00000697          	auipc	a3,0x0
ffffffffc020b5dc:	2b068693          	addi	a3,a3,688 # ffffffffc020b888 <etext+0x28>
ffffffffc020b5e0:	864a                	mv	a2,s2
ffffffffc020b5e2:	85ce                	mv	a1,s3
ffffffffc020b5e4:	8526                	mv	a0,s1
ffffffffc020b5e6:	0f2000ef          	jal	ffffffffc020b6d8 <printfmt>
ffffffffc020b5ea:	b365                	j	ffffffffc020b392 <vprintfmt+0x36>
ffffffffc020b5ec:	00003697          	auipc	a3,0x3
ffffffffc020b5f0:	6c468693          	addi	a3,a3,1732 # ffffffffc020ecb0 <etext+0x3450>
ffffffffc020b5f4:	864a                	mv	a2,s2
ffffffffc020b5f6:	85ce                	mv	a1,s3
ffffffffc020b5f8:	8526                	mv	a0,s1
ffffffffc020b5fa:	0de000ef          	jal	ffffffffc020b6d8 <printfmt>
ffffffffc020b5fe:	bb51                	j	ffffffffc020b392 <vprintfmt+0x36>
ffffffffc020b600:	4785                	li	a5,1
ffffffffc020b602:	008a8c13          	addi	s8,s5,8
ffffffffc020b606:	00b7c363          	blt	a5,a1,ffffffffc020b60c <vprintfmt+0x2b0>
ffffffffc020b60a:	cd81                	beqz	a1,ffffffffc020b622 <vprintfmt+0x2c6>
ffffffffc020b60c:	000ab403          	ld	s0,0(s5)
ffffffffc020b610:	02044b63          	bltz	s0,ffffffffc020b646 <vprintfmt+0x2ea>
ffffffffc020b614:	86a2                	mv	a3,s0
ffffffffc020b616:	8ae2                	mv	s5,s8
ffffffffc020b618:	4729                	li	a4,10
ffffffffc020b61a:	b5a5                	j	ffffffffc020b482 <vprintfmt+0x126>
ffffffffc020b61c:	2585                	addiw	a1,a1,1
ffffffffc020b61e:	8466                	mv	s0,s9
ffffffffc020b620:	bb71                	j	ffffffffc020b3bc <vprintfmt+0x60>
ffffffffc020b622:	000aa403          	lw	s0,0(s5)
ffffffffc020b626:	b7ed                	j	ffffffffc020b610 <vprintfmt+0x2b4>
ffffffffc020b628:	000ae683          	lwu	a3,0(s5)
ffffffffc020b62c:	4721                	li	a4,8
ffffffffc020b62e:	8ab2                	mv	s5,a2
ffffffffc020b630:	bd89                	j	ffffffffc020b482 <vprintfmt+0x126>
ffffffffc020b632:	000ae683          	lwu	a3,0(s5)
ffffffffc020b636:	4729                	li	a4,10
ffffffffc020b638:	8ab2                	mv	s5,a2
ffffffffc020b63a:	b5a1                	j	ffffffffc020b482 <vprintfmt+0x126>
ffffffffc020b63c:	000ae683          	lwu	a3,0(s5)
ffffffffc020b640:	4741                	li	a4,16
ffffffffc020b642:	8ab2                	mv	s5,a2
ffffffffc020b644:	bd3d                	j	ffffffffc020b482 <vprintfmt+0x126>
ffffffffc020b646:	864e                	mv	a2,s3
ffffffffc020b648:	85ca                	mv	a1,s2
ffffffffc020b64a:	02d00513          	li	a0,45
ffffffffc020b64e:	e042                	sd	a6,0(sp)
ffffffffc020b650:	9482                	jalr	s1
ffffffffc020b652:	6802                	ld	a6,0(sp)
ffffffffc020b654:	408006b3          	neg	a3,s0
ffffffffc020b658:	8ae2                	mv	s5,s8
ffffffffc020b65a:	4729                	li	a4,10
ffffffffc020b65c:	b51d                	j	ffffffffc020b482 <vprintfmt+0x126>
ffffffffc020b65e:	eba1                	bnez	a5,ffffffffc020b6ae <vprintfmt+0x352>
ffffffffc020b660:	02800793          	li	a5,40
ffffffffc020b664:	853e                	mv	a0,a5
ffffffffc020b666:	00003a97          	auipc	s5,0x3
ffffffffc020b66a:	643a8a93          	addi	s5,s5,1603 # ffffffffc020eca9 <etext+0x3449>
ffffffffc020b66e:	547d                	li	s0,-1
ffffffffc020b670:	bdf1                	j	ffffffffc020b54c <vprintfmt+0x1f0>
ffffffffc020b672:	853a                	mv	a0,a4
ffffffffc020b674:	85ea                	mv	a1,s10
ffffffffc020b676:	e03a                	sd	a4,0(sp)
ffffffffc020b678:	0e4000ef          	jal	ffffffffc020b75c <strnlen>
ffffffffc020b67c:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020b680:	6702                	ld	a4,0(sp)
ffffffffc020b682:	01b05b63          	blez	s11,ffffffffc020b698 <vprintfmt+0x33c>
ffffffffc020b686:	864e                	mv	a2,s3
ffffffffc020b688:	85ca                	mv	a1,s2
ffffffffc020b68a:	8522                	mv	a0,s0
ffffffffc020b68c:	e03a                	sd	a4,0(sp)
ffffffffc020b68e:	3dfd                	addiw	s11,s11,-1
ffffffffc020b690:	9482                	jalr	s1
ffffffffc020b692:	6702                	ld	a4,0(sp)
ffffffffc020b694:	fe0d99e3          	bnez	s11,ffffffffc020b686 <vprintfmt+0x32a>
ffffffffc020b698:	00074783          	lbu	a5,0(a4)
ffffffffc020b69c:	0007851b          	sext.w	a0,a5
ffffffffc020b6a0:	ee0781e3          	beqz	a5,ffffffffc020b582 <vprintfmt+0x226>
ffffffffc020b6a4:	00170a93          	addi	s5,a4,1
ffffffffc020b6a8:	b54d                	j	ffffffffc020b54a <vprintfmt+0x1ee>
ffffffffc020b6aa:	8466                	mv	s0,s9
ffffffffc020b6ac:	b36d                	j	ffffffffc020b456 <vprintfmt+0xfa>
ffffffffc020b6ae:	85ea                	mv	a1,s10
ffffffffc020b6b0:	00003517          	auipc	a0,0x3
ffffffffc020b6b4:	5f850513          	addi	a0,a0,1528 # ffffffffc020eca8 <etext+0x3448>
ffffffffc020b6b8:	0a4000ef          	jal	ffffffffc020b75c <strnlen>
ffffffffc020b6bc:	40ad8dbb          	subw	s11,s11,a0
ffffffffc020b6c0:	02800793          	li	a5,40
ffffffffc020b6c4:	00003717          	auipc	a4,0x3
ffffffffc020b6c8:	5e470713          	addi	a4,a4,1508 # ffffffffc020eca8 <etext+0x3448>
ffffffffc020b6cc:	853e                	mv	a0,a5
ffffffffc020b6ce:	fbb04ce3          	bgtz	s11,ffffffffc020b686 <vprintfmt+0x32a>
ffffffffc020b6d2:	00170a93          	addi	s5,a4,1
ffffffffc020b6d6:	bd95                	j	ffffffffc020b54a <vprintfmt+0x1ee>

ffffffffc020b6d8 <printfmt>:
ffffffffc020b6d8:	7139                	addi	sp,sp,-64
ffffffffc020b6da:	02010313          	addi	t1,sp,32
ffffffffc020b6de:	f03a                	sd	a4,32(sp)
ffffffffc020b6e0:	871a                	mv	a4,t1
ffffffffc020b6e2:	ec06                	sd	ra,24(sp)
ffffffffc020b6e4:	f43e                	sd	a5,40(sp)
ffffffffc020b6e6:	f842                	sd	a6,48(sp)
ffffffffc020b6e8:	fc46                	sd	a7,56(sp)
ffffffffc020b6ea:	e41a                	sd	t1,8(sp)
ffffffffc020b6ec:	c71ff0ef          	jal	ffffffffc020b35c <vprintfmt>
ffffffffc020b6f0:	60e2                	ld	ra,24(sp)
ffffffffc020b6f2:	6121                	addi	sp,sp,64
ffffffffc020b6f4:	8082                	ret

ffffffffc020b6f6 <snprintf>:
ffffffffc020b6f6:	711d                	addi	sp,sp,-96
ffffffffc020b6f8:	15fd                	addi	a1,a1,-1
ffffffffc020b6fa:	95aa                	add	a1,a1,a0
ffffffffc020b6fc:	03810313          	addi	t1,sp,56
ffffffffc020b700:	f406                	sd	ra,40(sp)
ffffffffc020b702:	e82e                	sd	a1,16(sp)
ffffffffc020b704:	e42a                	sd	a0,8(sp)
ffffffffc020b706:	fc36                	sd	a3,56(sp)
ffffffffc020b708:	e0ba                	sd	a4,64(sp)
ffffffffc020b70a:	e4be                	sd	a5,72(sp)
ffffffffc020b70c:	e8c2                	sd	a6,80(sp)
ffffffffc020b70e:	ecc6                	sd	a7,88(sp)
ffffffffc020b710:	cc02                	sw	zero,24(sp)
ffffffffc020b712:	e01a                	sd	t1,0(sp)
ffffffffc020b714:	c515                	beqz	a0,ffffffffc020b740 <snprintf+0x4a>
ffffffffc020b716:	02a5e563          	bltu	a1,a0,ffffffffc020b740 <snprintf+0x4a>
ffffffffc020b71a:	75dd                	lui	a1,0xffff7
ffffffffc020b71c:	86b2                	mv	a3,a2
ffffffffc020b71e:	00000517          	auipc	a0,0x0
ffffffffc020b722:	c2450513          	addi	a0,a0,-988 # ffffffffc020b342 <sprintputch>
ffffffffc020b726:	871a                	mv	a4,t1
ffffffffc020b728:	ad958593          	addi	a1,a1,-1319 # ffffffffffff6ad9 <end+0x3fd601c9>
ffffffffc020b72c:	0030                	addi	a2,sp,8
ffffffffc020b72e:	c2fff0ef          	jal	ffffffffc020b35c <vprintfmt>
ffffffffc020b732:	67a2                	ld	a5,8(sp)
ffffffffc020b734:	00078023          	sb	zero,0(a5)
ffffffffc020b738:	4562                	lw	a0,24(sp)
ffffffffc020b73a:	70a2                	ld	ra,40(sp)
ffffffffc020b73c:	6125                	addi	sp,sp,96
ffffffffc020b73e:	8082                	ret
ffffffffc020b740:	5575                	li	a0,-3
ffffffffc020b742:	bfe5                	j	ffffffffc020b73a <snprintf+0x44>

ffffffffc020b744 <strlen>:
ffffffffc020b744:	00054783          	lbu	a5,0(a0)
ffffffffc020b748:	cb81                	beqz	a5,ffffffffc020b758 <strlen+0x14>
ffffffffc020b74a:	4781                	li	a5,0
ffffffffc020b74c:	0785                	addi	a5,a5,1
ffffffffc020b74e:	00f50733          	add	a4,a0,a5
ffffffffc020b752:	00074703          	lbu	a4,0(a4)
ffffffffc020b756:	fb7d                	bnez	a4,ffffffffc020b74c <strlen+0x8>
ffffffffc020b758:	853e                	mv	a0,a5
ffffffffc020b75a:	8082                	ret

ffffffffc020b75c <strnlen>:
ffffffffc020b75c:	4781                	li	a5,0
ffffffffc020b75e:	e589                	bnez	a1,ffffffffc020b768 <strnlen+0xc>
ffffffffc020b760:	a811                	j	ffffffffc020b774 <strnlen+0x18>
ffffffffc020b762:	0785                	addi	a5,a5,1
ffffffffc020b764:	00f58863          	beq	a1,a5,ffffffffc020b774 <strnlen+0x18>
ffffffffc020b768:	00f50733          	add	a4,a0,a5
ffffffffc020b76c:	00074703          	lbu	a4,0(a4)
ffffffffc020b770:	fb6d                	bnez	a4,ffffffffc020b762 <strnlen+0x6>
ffffffffc020b772:	85be                	mv	a1,a5
ffffffffc020b774:	852e                	mv	a0,a1
ffffffffc020b776:	8082                	ret

ffffffffc020b778 <strcpy>:
ffffffffc020b778:	87aa                	mv	a5,a0
ffffffffc020b77a:	0005c703          	lbu	a4,0(a1)
ffffffffc020b77e:	0585                	addi	a1,a1,1
ffffffffc020b780:	0785                	addi	a5,a5,1
ffffffffc020b782:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020b786:	fb75                	bnez	a4,ffffffffc020b77a <strcpy+0x2>
ffffffffc020b788:	8082                	ret

ffffffffc020b78a <strcmp>:
ffffffffc020b78a:	00054783          	lbu	a5,0(a0)
ffffffffc020b78e:	e791                	bnez	a5,ffffffffc020b79a <strcmp+0x10>
ffffffffc020b790:	a01d                	j	ffffffffc020b7b6 <strcmp+0x2c>
ffffffffc020b792:	00054783          	lbu	a5,0(a0)
ffffffffc020b796:	cb99                	beqz	a5,ffffffffc020b7ac <strcmp+0x22>
ffffffffc020b798:	0585                	addi	a1,a1,1
ffffffffc020b79a:	0005c703          	lbu	a4,0(a1)
ffffffffc020b79e:	0505                	addi	a0,a0,1
ffffffffc020b7a0:	fef709e3          	beq	a4,a5,ffffffffc020b792 <strcmp+0x8>
ffffffffc020b7a4:	0007851b          	sext.w	a0,a5
ffffffffc020b7a8:	9d19                	subw	a0,a0,a4
ffffffffc020b7aa:	8082                	ret
ffffffffc020b7ac:	0015c703          	lbu	a4,1(a1)
ffffffffc020b7b0:	4501                	li	a0,0
ffffffffc020b7b2:	9d19                	subw	a0,a0,a4
ffffffffc020b7b4:	8082                	ret
ffffffffc020b7b6:	0005c703          	lbu	a4,0(a1)
ffffffffc020b7ba:	4501                	li	a0,0
ffffffffc020b7bc:	b7f5                	j	ffffffffc020b7a8 <strcmp+0x1e>

ffffffffc020b7be <strncmp>:
ffffffffc020b7be:	ce01                	beqz	a2,ffffffffc020b7d6 <strncmp+0x18>
ffffffffc020b7c0:	00054783          	lbu	a5,0(a0)
ffffffffc020b7c4:	167d                	addi	a2,a2,-1 # fff <_binary_bin_swap_img_size-0x6d01>
ffffffffc020b7c6:	cb91                	beqz	a5,ffffffffc020b7da <strncmp+0x1c>
ffffffffc020b7c8:	0005c703          	lbu	a4,0(a1)
ffffffffc020b7cc:	00f71763          	bne	a4,a5,ffffffffc020b7da <strncmp+0x1c>
ffffffffc020b7d0:	0505                	addi	a0,a0,1
ffffffffc020b7d2:	0585                	addi	a1,a1,1
ffffffffc020b7d4:	f675                	bnez	a2,ffffffffc020b7c0 <strncmp+0x2>
ffffffffc020b7d6:	4501                	li	a0,0
ffffffffc020b7d8:	8082                	ret
ffffffffc020b7da:	00054503          	lbu	a0,0(a0)
ffffffffc020b7de:	0005c783          	lbu	a5,0(a1)
ffffffffc020b7e2:	9d1d                	subw	a0,a0,a5
ffffffffc020b7e4:	8082                	ret

ffffffffc020b7e6 <strchr>:
ffffffffc020b7e6:	a021                	j	ffffffffc020b7ee <strchr+0x8>
ffffffffc020b7e8:	00f58763          	beq	a1,a5,ffffffffc020b7f6 <strchr+0x10>
ffffffffc020b7ec:	0505                	addi	a0,a0,1
ffffffffc020b7ee:	00054783          	lbu	a5,0(a0)
ffffffffc020b7f2:	fbfd                	bnez	a5,ffffffffc020b7e8 <strchr+0x2>
ffffffffc020b7f4:	4501                	li	a0,0
ffffffffc020b7f6:	8082                	ret

ffffffffc020b7f8 <memset>:
ffffffffc020b7f8:	ca01                	beqz	a2,ffffffffc020b808 <memset+0x10>
ffffffffc020b7fa:	962a                	add	a2,a2,a0
ffffffffc020b7fc:	87aa                	mv	a5,a0
ffffffffc020b7fe:	0785                	addi	a5,a5,1
ffffffffc020b800:	feb78fa3          	sb	a1,-1(a5)
ffffffffc020b804:	fef61de3          	bne	a2,a5,ffffffffc020b7fe <memset+0x6>
ffffffffc020b808:	8082                	ret

ffffffffc020b80a <memmove>:
ffffffffc020b80a:	02a5f163          	bgeu	a1,a0,ffffffffc020b82c <memmove+0x22>
ffffffffc020b80e:	00c587b3          	add	a5,a1,a2
ffffffffc020b812:	00f57d63          	bgeu	a0,a5,ffffffffc020b82c <memmove+0x22>
ffffffffc020b816:	c61d                	beqz	a2,ffffffffc020b844 <memmove+0x3a>
ffffffffc020b818:	962a                	add	a2,a2,a0
ffffffffc020b81a:	fff7c703          	lbu	a4,-1(a5)
ffffffffc020b81e:	17fd                	addi	a5,a5,-1
ffffffffc020b820:	167d                	addi	a2,a2,-1
ffffffffc020b822:	00e60023          	sb	a4,0(a2)
ffffffffc020b826:	fef59ae3          	bne	a1,a5,ffffffffc020b81a <memmove+0x10>
ffffffffc020b82a:	8082                	ret
ffffffffc020b82c:	00c586b3          	add	a3,a1,a2
ffffffffc020b830:	87aa                	mv	a5,a0
ffffffffc020b832:	ca11                	beqz	a2,ffffffffc020b846 <memmove+0x3c>
ffffffffc020b834:	0005c703          	lbu	a4,0(a1)
ffffffffc020b838:	0585                	addi	a1,a1,1
ffffffffc020b83a:	0785                	addi	a5,a5,1
ffffffffc020b83c:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020b840:	feb69ae3          	bne	a3,a1,ffffffffc020b834 <memmove+0x2a>
ffffffffc020b844:	8082                	ret
ffffffffc020b846:	8082                	ret

ffffffffc020b848 <memcpy>:
ffffffffc020b848:	ca19                	beqz	a2,ffffffffc020b85e <memcpy+0x16>
ffffffffc020b84a:	962e                	add	a2,a2,a1
ffffffffc020b84c:	87aa                	mv	a5,a0
ffffffffc020b84e:	0005c703          	lbu	a4,0(a1)
ffffffffc020b852:	0585                	addi	a1,a1,1
ffffffffc020b854:	0785                	addi	a5,a5,1
ffffffffc020b856:	fee78fa3          	sb	a4,-1(a5)
ffffffffc020b85a:	feb61ae3          	bne	a2,a1,ffffffffc020b84e <memcpy+0x6>
ffffffffc020b85e:	8082                	ret
