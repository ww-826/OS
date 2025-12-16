

# Lab5 实验报告

## 练习1: 加载应用程序并执行

### 1. 设计实现过程

load_icode 函数的主要功能是将一个 ELF 格式的二进制程序加载到当前进程的内存空间中。

我们需要完成的是第6步：建立用户进程的 Trapframe，以便内核在返回用户态时，CPU 能够跳转到正确的入口地址，并拥有正确的栈指针和特权级。

```c
// 设置用户栈指针，指向用户栈的顶部
tf->gpr.sp = USTACKTOP;
// 设置程序入口地址，即 ELF header 中指定的入口
tf->epc = elf->e_entry;
// 设置状态寄存器：
// SSTATUS_SPP<-0,用户态
// SSTATUS_SPIE=1,开启中断
tf->status = (sstatus & ~SSTATUS_SPP) | SSTATUS_SPIE;
```

### 2. 进程从 RUNNING 到执行第一条指令的经过

1.  内核调度器（schedule）决定运行该进程，将其状态设为 PROC_RUNNING。
2.  将 CPU 的上下文（寄存器 ra, sp, s0-s11）切换到该进程的内核栈上下文。
3.  switch_to 返回后，CPU 跳转到 forkret 函数（这是在 copy_thread 中设置的 ra）。
4.  forkret 调用 forkrets，传入当前进程的 trapframe。
5.  forkrets 跳转到 __trapret。这段汇编代码会从 trapframe 中恢复所有的通用寄存器（其中栈顶被设置为 USTACKTOP）和 sstatus、sepc。
6.  执行 sret 指令，完成用户态切换（sstatus.SPP_bit=0)，并跳转到 sepc 指向的地址（即 elf->e_entry）。
7.  用户态的指令开始执行......

## 练习2: 父进程复制自己的内存空间给子进程

### 1. 设计实现过程

copy_range 函数用于在 fork 时将父进程的内存空间（包括code,data等也上存的数据本身和页表）复制给子进程。

```c
//获取源页（父进程）和目标页（子进程）的内核虚拟地址
void *src_kvaddr = page2kva(page);
void *dst_kvaddr = page2kva(npage);
//复制
memcpy(dst_kvaddr, src_kvaddr, PGSIZE);
//克隆页表的映射
ret = page_insert(to, npage, start, perm);
```

### 2. Copy on Write (COW) 机制设计

基本概念：
在 fork 时不立即复制物理内存，而是让父子进程共享同一份物理内存，并将页表项设为只读。只有当其中一方尝试写入时，才触发缺页异常，由内核分配新的物理页并复制数据，然后修改页表为可写。

设计方案：

1.  修改 copy_range (在 fork 阶段)：
    - 直接将父进程的物理页映射到子进程的页表中，但将父子进程该页的页表项权限都设为只读（去掉 PTE_W ）。
    - 增加该物理页的引用计数 (page_ref_inc)。

2.  修改缺页异常处理 (do_pgfault)：
    - 当程序尝试写入这些只读页时，会触发 Store Page Fault。
    - 在异常处理函数中检测：
      - 异常原因是否为写操作？
      - 页表项是否有效 (PTE_V) 但不可写？
    - 执行写时复制：
      - 申请一个新的物理页。
      - 将旧页面的内容拷贝到新页面。
      - 更新当前进程的页表，指向新页面，并开启 可写 (PTE_W) 权限。
      - 减少旧页面的引用计数。
    - 特殊情况：如果旧页面的引用计数已经是 1（说明只有一个进程在用），则不需要申请新页，直接把权限改为可写即可。

## 练习3: 阅读分析源代码，理解进程执行 fork/exec/wait/exit 的实现

*   fork
    - 用户态：调用 fork() 库函数 -> 执行 ecall 指令。
    - 内核态：
      - trap 分发到 sys_fork -> do_fork。
      - alloc_proc: 分配 PCB。
      - setup_kstack: 分配内核栈。
      - copy_mm: 复制内存空间（或共享）。
      - copy_thread: 设置 Trapframe 和 Context（设置子进程 fork 返回值为 0）。
      - hash_proc / set_links: 加入进程链表。
      - wakeup_proc: 设为 RUNNABLE。
      - 返回子进程 PID 给父进程。
    - 返回：父进程返回 PID，子进程被调度后返回 0。

*   exec
    - 用户态：调用 exec() -> ecall。
    - 内核态：
      - sys_exec -> do_execve。
      - 检查内存合法性。
      - 回收当前进程内存 (exit_mmap, put_pgdir)。
      - load_icode: 加载新程序二进制，建立新内存映射，重置 Trapframe。
      - set_proc_name: 设置新名字。
    - 返回：不返回原程序，而是直接跳转到新程序的入口执行。

*   wait
    - 用户态：调用 wait() -> ecall。
    - 内核态：
      - sys_wait -> do_wait。
      - 查找是否有状态为 ZOMBIE 的子进程。
      - 如果有：回收该子进程的 PCB 和内核栈，返回其 PID 和退出码。
      - 如果子进程还在运行：设置当前进程为 PROC_SLEEPING，wait_state = WT_CHILD，调用 schedule() 让出 CPU。
    - 返回：被唤醒后（子进程退出时），返回子进程 PID。

*   exit
    - 用户态：调用 exit() -> ecall。
    - 内核态：
      - sys_exit -> do_exit。
      - 回收内存资源 (mm_destroy)。
      - 设置状态为 PROC_ZOMBIE。
      - 唤醒父进程（如果父进程在 wait）。
      - 将子进程过继给 init 进程。
      - 调用 schedule() 永久让出 CPU。
    - 返回：不返回。


用户程序通过 ecall 陷入内核，内核处理完后通过 sret 返回用户态。返回值保存在 a0 寄存器中（在 trapframe 中修改 gpr.a0）。

```
       (alloc_proc)          (wakeup_proc)
  NULL ------------> UNINIT --------------> RUNNABLE
                                               |  ^
                                    (schedule) |  | (schedule)
                                               v  |
                                            RUNNING
                                               |
         (do_wait/do_sleep)                    | (do_exit)
       +---------------------------------------+----------------+
       |                                                        |
       v                                                        v
    SLEEPING                                                 ZOMBIE
       |                                                        |
       | (wakeup_proc: event happened)                          | (do_wait: parent reclaims)
       +--------------------------------------------------------+
                                                                |
                                                                v
                                                               NULL
```

```
root@55d0333bc73d:~/share/oslearn/OS/lab5# make grade
user/testbss.c: In function 'main':
user/testbss.c:32:6: warning: array subscript 1049600 is outside array bounds of 'uint32_t[1048576]' {aka 'unsigned int[1048576]'} [-Warray-bounds=]
   32 |     p[ARRAYSIZE + 1024] = 0;
      |     ~^~~~~~~~~~~~~~~~~~
user/testbss.c:6:10: note: at offset 4198400 into object 'bigarray' of size 4194304
    6 | uint32_t bigarray[ARRAYSIZE];
      |          ^~~~~~~~
gmake[1]: Entering directory '/root/share/oslearn/OS/lab5' + cc kern/init/entry.S + cc kern/init/init.c + cc kern/libs/readline.c + cc kern/libs/stdio.c + cc kern/debug/kdebug.c + cc kern/debug/kmonitor.c + cc kern/debug/panic.c + cc kern/driver/clock.c + cc kern/driver/console.c + cc kern/driver/dtb.c + cc kern/driver/intr.c + cc kern/driver/picirq.c + cc kern/trap/trap.c + cc kern/trap/trapentry.S + cc kern/mm/default_pmm.c + cc kern/mm/kmalloc.c + cc kern/mm/pmm.c + cc kern/mm/vmm.c + cc kern/process/entry.S + cc kern/process/proc.c + cc kern/process/switch.S + cc kern/schedule/sched.c + cc kern/syscall/syscall.c + cc libs/hash.c + cc libs/printfmt.c + cc libs/rand.c + cc libs/string.c + cc user/badarg.c + cc user/libs/initcode.S + cc user/libs/panic.c + cc user/libs/stdio.c + cc user/libs/syscall.c + cc user/libs/ulib.c + cc user/libs/umain.c + cc user/badsegment.c + cc user/divzero.c + cc user/exit.c + cc user/faultread.c + cc user/faultreadkernel.c + cc user/forktest.c + cc user/forktree.c + cc user/hello.c + cc user/pgdir.c + cc user/softint.c + cc user/spin.c + cc user/testbss.c + cc user/waitkill.c + cc user/yield.c + ld bin/kernel riscv64-unknown-elf-objcopy bin/kernel --strip-all -O binary bin/ucore.img gmake[1]: Leaving directory '/root/share/oslearn/OS/lab5'
badsegment:              (s)
  -check result:                             OK
  -check output:                             OK
divzero:                 (s)
  -check result:                             WRONG
   -e !! error: missing 'value is -1.'

  -check output:                             OK
softint:                 (s)
  -check result:                             OK
  -check output:                             OK
faultread:               (s)
  -check result:                             OK
  -check output:                             OK
faultreadkernel:         (s)
  -check result:                             OK
  -check output:                             OK
hello:                   (s)
  -check result:                             OK
  -check output:                             OK
testbss:                 (s)
  -check result:                             OK
  -check output:                             OK
pgdir:                   (s)
  -check result:                             OK
  -check output:                             OK
yield:                   (s)
  -check result:                             OK
  -check output:                             OK
badarg:                  (s)
  -check result:                             OK
  -check output:                             OK
exit:                    (s)
  -check result:                             OK
  -check output:                             OK
spin:                    (s)
  -check result:                             OK
  -check output:                             OK
forktest:                (s)
  -check result:                             OK
  -check output:                             OK
Total Score: 123/130
```

## 知识点总结

### 1. 实验中重要的知识点 vs OS 原理

| 实验知识点             | OS 原理对应点               | 理解与差异                                                   |
| :--------------------- | :-------------------------- | :----------------------------------------------------------- |
| Trapframe (中断帧) | Context Saving / PCB    | 实验中 trapframe 显式地保存在内核栈顶，用于中断/系统调用时的现场保护。原理中通常作为 PCB 的一部分或内核栈的一部分。 |
| Page Table (页表)  | Virtual Memory / Paging | 实验中直接操作 SV39 页表项（PTE），体现了硬件细节。原理主要讲分页机制的抽象概念。 |
| ELF Loading        | Loader / Linker         | 实验中简化了加载过程，直接从内存读取 ELF。实际 OS 通常从磁盘文件系统加载，涉及更复杂的 I/O 和动态链接。 |
| Copy on Write      | Memory Optimization     | 实验作为选做/思考题。这是现代 OS 节省内存的关键技术，体现了“懒惰计算”的思想。 |
| Process Tree       | Process Management      | 通过 parent, cptr, optr, yptr 维护家族关系，用于资源回收和权限管理。 |

## 扩展练习 Challenge

### 2.

Lab5的用户程序嵌入在内核镜像中，随内核一起存在于物理内存。Boot 时一次性加载。内核启动后，程序数据已经在内存里了。

正常操作系统的程序存储在磁盘的文件系统中。运行时按需加载。只有当用户执行程序时，OS 才会去读取磁盘。