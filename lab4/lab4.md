## 实验四 — 练习1 分配并初始化进程控制块 (alloc_proc)


### 实现思路与过程

1. 分配内存

   - 使用内核内存分配器 `kmalloc` 为 `struct proc_struct` 分配一段连续内存。

2. 初始化所有字段，保证每个字段处于确定的默认值，避免野指针或未定义行为：

   - `state`：初始化为 `PROC_UNINIT`，表示尚未完成初始化的进程结构。
   - `pid`：初始化为 -1，等待 `get_pid()` 分配真实 PID。
   - `runs`：0（尚未运行过）。
   - `kstack`：0（尚未分配内核栈）。
   - `need_resched`：0（默认不需要重新调度）。
   - `parent`：NULL（尚未设置父进程）。
   - `mm`：NULL（本实验中 VM 管理尚未建立或共享）。
   - `context`：全部清零（`memset`），以确保寄存器上下文的确定初始状态。
   - `tf`：NULL（尚未建立 trapframe）。
   - `pgdir`：设为内核启动页表基址 `boot_pgdir_pa`，保证在尚未为进程建立独立页表前不会使用不正确的页表。
   - `flags`：0（默认没有特殊标志）。
   - `name`：清零，后续通过 `set_proc_name` 设定进程名。
   - 列表成员 `list_link` 与 `hash_link`：调用 `list_init()` 初始化链表头，确保后续插入与删除安全。

3. 返回初始化后的 `proc_struct *` 给上层创建流程（例如 `do_fork` 或 `proc_init`）。

实现时的关键设计考虑：

- 绝大部分字段都使用显式的、可辨认的“安全默认值”，以便后续断言与检查（例如 `proc_init` 中对 `idleproc` 的断言）能通过。
- 将 `pgdir` 设为 `boot_pgdir_pa` 是为了在尚未为进程分配独立页表前避免出现未定义的页表访问（更稳健的选择）。

### 两个关键成员变量含义与作用

1. `struct context context`

   - 含义：用于保存内核级上下文切换所需的寄存器值（主要是 callee-saved 寄存器：`ra`, `sp`, `s0`..`s11` 等）。
   - 在本实验的作用：
     - 当内核进行线程/进程切换时，当前执行实体（进程/线程）的寄存器状态会保存在该 `context` 中。
     - `switch_to(&from->context, &to->context)` 会把 `from` 的寄存器保存到其 `context`，并从 `to->context` 恢复寄存器，从而实现 CPU 执行流从 `from` 切换到 `to`。
     - `copy_thread` 在创建新线程时会设置 `context.ra`（返回地址）和 `context.sp`（栈指针），以保证新线程第一次被调度时能进入指定的内核入口（如 `forkret`）。

2. `struct trapframe *tf`

   - 含义：指向保存发生 trap（中断/异常/系统调用）时 CPU 寄存器状态的数据结构，包含通用寄存器、程序计数器（`epc`）、状态寄存器等。
   - 在本实验的作用：
     - Trapframe 用于保存从用户态进入内核态时的完整用户寄存器上下文，以便内核在处理完中断或系统调用后可以恢复用户程序的执行状态。
     - 在创建进程（如 `do_fork` / `copy_thread`）时，会把一个临时的 trapframe 复制到 `proc->tf`，并对其进行必要修改（例如在子进程 `a0` 置 0，使 fork 在子进程中返回 0）。
     - `proc->tf` 也是 `forkret` 或者 `forkrets` 这些内核入口用于确定进程首次返回到用户态时寄存器值的依据。

总结：`context` 负责保存内核态执行的寄存器集合（内核栈与内核函数返回路径），而 `trapframe` 保存从用户态进入内核态时的寄存器快照，二者在不同场景（内核内上下文切换 vs. 用户/内核边界的 trap 保存/恢复）互补地完成进程切换与返回。
//
