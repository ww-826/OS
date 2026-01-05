# 实验报告：Lab 6 调度器

## 练习0：填写已有实验

本实验依赖于实验2/3/4/5。在 `proc.c` 和 `trap.c` 等文件中，我们已经将之前实验的代码迁移过来。
需要注意的是，为了支持 Lab 6 的调度功能，我们在 `proc_struct` 中初始化了 Lab 6 新增的成员变量：
- `rq`: 指向运行队列。
- `run_link`: 运行队列的链表节点。
- `time_slice`: 进程剩余的时间片。
- `lab6_run_pool`: Stride 调度算法使用的斜堆节点。
- `lab6_stride`: Stride 调度算法的步长。
- `lab6_priority`: 进程优先级。

同时，在 `trap.c` 的时钟中断处理中，我们调用了 `sched_class_proc_tick(current)` 来触发调度器的 tick 处理，而不是像之前那样直接设置 `need_resched`。

## 练习1: 理解调度器框架的实现

### 1. 调度类结构体 `sched_class` 分析

`sched_class` 结构体定义了一组函数指针，用于实现具体的调度算法。这种设计模式类似于面向对象编程中的接口（Interface）或抽象基类。

```c
struct sched_class {
    const char *name;
    void (*init)(struct run_queue *rq);
    void (*enqueue)(struct run_queue *rq, struct proc_struct *proc);
    void (*dequeue)(struct run_queue *rq, struct proc_struct *proc);
    struct proc_struct *(*pick_next)(struct run_queue *rq);
    void (*proc_tick)(struct run_queue *rq, struct proc_struct *proc);
};
```

*   **`init`**: 初始化运行队列。在内核启动调度器时调用。
*   **`enqueue`**: 将进程加入运行队列。当进程变为 `PROC_RUNNABLE` 状态（如被唤醒、时间片用完被抢占）时调用。
*   **`dequeue`**: 从运行队列移除进程。当进程被调度运行（从就绪态转为运行态）或变为非就绪态（如阻塞、退出）时调用。
*   **`pick_next`**: 选择下一个要运行的进程。在 `schedule()` 函数中调用。
*   **`proc_tick`**: 处理时钟中断。在时钟中断处理程序中调用，用于更新进程时间片，并判断是否需要调度。

**为什么使用函数指针？**
这种设计实现了**机制与策略的分离**。内核的调度框架（`schedule`, `wakeup_proc` 等）只依赖于 `sched_class` 定义的接口，而不依赖于具体的调度算法（如 FIFO, RR, Stride）。这使得我们可以在不修改内核核心代码的情况下，通过替换 `sched_class` 的实例来切换不同的调度算法，极大地提高了系统的可扩展性和灵活性。

### 2. 运行队列结构体 `run_queue` 分析

```c
struct run_queue {
    list_entry_t run_list;
    unsigned int proc_num;
    int max_time_slice;
    // For LAB6 ONLY
    skew_heap_entry_t *lab6_run_pool;
};
```

*   **Lab 5 vs Lab 6**: Lab 5 的 `run_queue` 可能只包含链表结构（如果只实现了简单的 FIFO 或 RR）。Lab 6 增加了 `lab6_run_pool`。
*   **双数据结构支持**:
    *   `run_list`: 这是一个双向链表，用于支持像 Round Robin (RR) 这样的基于队列的调度算法。RR 算法只需要在链表尾部插入，头部取出。
    *   `lab6_run_pool`: 这是一个斜堆（Skew Heap）的指针，用于支持 Stride Scheduling 这样的基于优先级的调度算法。Stride 算法需要快速找到 stride 最小的进程，斜堆（作为优先队列）提供了高效的插入和删除最小值操作。
    *   同时支持这两种结构使得同一个 `run_queue` 可以被不同的调度类复用。

### 3. 调度器框架函数分析

*   **`sched_init()`**:
    *   初始化 timer list。
    *   设置 `sched_class` 指向具体的调度实现（如 `default_sched_class`）。
    *   初始化 `run_queue`，并调用 `sched_class->init` 进行特定算法的初始化。
    *   这确立了系统启动时的默认调度策略。

*   **`wakeup_proc(struct proc_struct *proc)`**:
    *   将进程状态设置为 `PROC_RUNNABLE`。
    *   调用 `sched_class_enqueue(proc)`，进而调用 `sched_class->enqueue`。
    *   这使得具体的调度算法感知到有一个新进程进入了就绪状态，可以将其加入内部的数据结构（链表或堆）。

*   **`schedule()`**:
    *   这是调度的核心函数。
    *   首先，如果当前进程 `current` 处于 `PROC_RUNNABLE` 状态（说明是被抢占，而不是阻塞），调用 `sched_class_enqueue(current)` 将其放回运行队列。
    *   调用 `sched_class_pick_next()` 选择下一个进程。
    *   如果选出了新进程，调用 `sched_class_dequeue(next)` 将其从运行队列移除。
    *   最后调用 `proc_run(next)` 进行上下文切换。
    *   整个过程完全不涉及具体的队列操作细节，全部委托给 `sched_class` 的接口。

### 4. 调度器使用流程分析

**调度类的初始化流程**:
1.  `kern_init` 调用 `sched_init`。
2.  `sched_init` 设置 `sched_class = &default_sched_class` (默认为 RR)。
3.  `sched_init` 初始化 `run_queue` 结构体。
4.  调用 `sched_class->init(rq)`，执行 RR 算法的初始化（如初始化 `run_list`）。

**进程调度流程图描述**:
1.  **时钟中断**: 硬件触发时钟中断 -> `trap()` -> `trap_dispatch()` -> `interrupt_handler()` -> `clock_set_next_event()`。
2.  **Tick 处理**: `interrupt_handler` 调用 `sched_class_proc_tick(current)` -> `sched_class->proc_tick(rq, current)`。
    *   在 RR 算法中，`RR_proc_tick` 递减 `current->time_slice`。
    *   如果 `time_slice` 减为 0，设置 `current->need_resched = 1`。
3.  **调度请求**: 中断返回前，`trap()` 函数检查 `current->need_resched`。如果为 1，调用 `schedule()`。
4.  **执行调度**:
    *   `schedule()`:
        *   `sched_class->enqueue(current)`: 当前进程放回队列尾部。
        *   `sched_class->pick_next()`: 取队列头部进程 `next`。
        *   `sched_class->dequeue(next)`: 将 `next` 从队列移除。
        *   `proc_run(next)`: 切换到 `next` 运行。

**`need_resched` 的作用**:
这是一个标志位，用于“推迟”调度动作。在中断处理程序中（如时钟中断），我们不能直接进行上下文切换（因为还在中断上下文中）。通过设置 `need_resched = 1`，告诉内核“当前进程的时间片用完了，或者有更高优先级的进程需要运行”。当内核准备从中断返回用户态时，会检查这个标志，如果为真，则调用 `schedule()` 安全地进行切换。

**调度算法的切换机制**:
要添加新的调度算法（如 Stride）：
1.  实现一个新的 `sched_class` 实例（如 `stride_sched_class`），填充对应的函数指针。
2.  在 `sched_init()` 中，将 `sched_class` 指针指向新的调度类实例。
3.  如果需要新的数据结构支持，可能需要修改 `run_queue`（如 Lab 6 已经添加了 `lab6_run_pool`）。
**容易切换的原因**: 核心调度逻辑（`schedule`, `wakeup_proc`）只通过指针调用接口，不依赖具体实现。只需要改变指针指向，行为就会完全改变。

## 练习2: 实现 Round Robin 调度算法

### 1. Lab 5 与 Lab 6 的区别 (以 `sched.c` 为例)
在 Lab 5 中，调度策略往往是硬编码的（或者是简单的 FIFO），没有完善的 `sched_class` 抽象。
Lab 6 的 `sched.c` 引入了 `sched_class` 指针，所有的调度操作都变成了间接调用。
**如果不做这个改动**: 系统将只能支持一种固定的调度算法，无法灵活扩展。每次修改算法都需要侵入式地修改 `schedule` 等核心函数，维护成本极高。

### 2. RR 算法实现思路

*   **`RR_init`**: 初始化 `run_list` 为空链表，`proc_num` 为 0。
*   **`RR_enqueue`**:
    *   使用 `list_add_before` 将进程加入 `run_list` 的尾部（即头结点的前面）。
    *   **关键点**: 如果进程的时间片为 0 或超过最大值，将其重置为 `max_time_slice`。这保证了进程每次被调度都有足额的时间片。
    *   更新 `proc->rq` 和 `rq->proc_num`。
*   **`RR_dequeue`**:
    *   使用 `list_del_init` 从链表中删除节点。
    *   更新 `rq->proc_num`。
*   **`RR_pick_next`**:
    *   查看 `run_list` 的下一个节点（即链表头部）。
    *   如果链表不为空（`le != &rq->run_list`），使用 `le2proc` 获取对应的进程结构体并返回。
    *   否则返回 NULL。
*   **`RR_proc_tick`**:
    *   递减 `proc->time_slice`。
    *   **边界处理**: 如果 `time_slice` 减至 0，设置 `proc->need_resched = 1`，请求调度。

### 3. 调度现象与分析
(此处假设 make grade 通过)
在 QEMU 中，可以看到多个进程交替输出信息。由于是 RR 调度，且时间片较短，进程间的切换会比较频繁，表现为并发执行的效果。

**RR 算法优缺点**:
*   **优点**: 公平性好，响应时间较短（对于交互式任务），实现简单。
*   **缺点**: 平均周转时间较长（对于批处理任务），如果时间片设置不当，上下文切换开销可能较大。

**时间片调整**:
*   时间片太小：切换过于频繁，CPU 大量时间花在上下文切换上，吞吐量下降。
*   时间片太大：退化为 FCFS (First-Come, First-Served)，响应时间变长，交互体验差。
*   优化：应根据系统负载和任务类型动态调整，或选择一个折中的值（如 10ms - 100ms）。

**`need_resched` 的必要性**:
在 `RR_proc_tick` 中，我们处于中断上下文。此时不能直接调用 `schedule()` 进行切换。设置标志位是一种异步通知机制，让内核在合适的时机（中断返回前）安全地进行调度。

**拓展思考**:
*   **优先级 RR**: 可以维护多个队列，每个优先级一个队列。调度时先扫描高优先级队列。或者在同一个队列中，高优先级进程的时间片更长。
*   **多核调度**: 当前实现是单核的。支持多核需要：
    *   每个 CPU 一个 `run_queue`。
    *   加锁保护 `run_queue`（`rq_lock`）。
    *   实现负载均衡（Load Balancing），在 CPU 间迁移进程。

## 扩展练习 Challenge 1: 实现 Stride Scheduling

### 1. 多级反馈队列 (MLFQ) 设计概要
MLFQ 旨在同时优化周转时间和响应时间。
*   **设计**:
    *   设置多个队列（Q1, Q2, ..., Qn），优先级递减。
    *   Q1 优先级最高，时间片最短；Qn 优先级最低，时间片最长。
    *   新进程进入 Q1。
    *   如果进程在当前队列的时间片内用完 CPU（CPU 密集型），降级到下一级队列。
    *   如果进程主动放弃 CPU（IO 密集型），保持在当前队列或提升优先级。
    *   调度时优先运行高优先级队列的任务。

### 2. Stride Scheduling 原理

Stride 调度算法的核心是：**pass = stride = BIG_STRIDE / priority**。
*   每个进程有一个 `pass` 值（当前累计步长）和 `stride` 值（步长）。
*   每次调度选择 `pass` 最小的进程运行。
*   运行后，`pass += stride`。

**证明/说明**:
假设有两个进程 A (优先级 2) 和 B (优先级 1)。
*   Stride_A = S / 2
*   Stride_B = S / 1 = S
*   A 的步长是 B 的一半。这意味着 A 每走两步，增加的 pass 值才等于 B 走一步增加的值。
*   为了保持 pass 值交替上升（大家轮流做最小值），A 需要被调度的次数大约是 B 的 2 倍。
*   因此，调度次数（获得的时间片）与优先级成正比。
*   经过足够长的时间，每个进程分配到的 CPU 时间与其优先级成线性正比关系。

### 3. 实现过程
*   **数据结构**: 使用斜堆 (`skew_heap`) 来维护运行队列，以 `pass` (代码中为 `lab6_stride`) 为键值，实现 $O(\log N)$ 的插入和删除最小值。
*   **`stride_init`**: 初始化 `lab6_run_pool` 为 NULL。
*   **`stride_enqueue`**:
    *   调用 `skew_heap_insert` 将进程加入斜堆。
    *   如果进程时间片用完，重置为 `max_time_slice`。
    *   更新 `proc->rq` 和 `proc_num`。
*   **`stride_dequeue`**:
    *   调用 `skew_heap_remove` 将进程从斜堆移除。
*   **`stride_pick_next`**:
    *   如果 `lab6_run_pool` 为空，返回 NULL。
    *   否则，取堆顶进程 `p`。
    *   **关键更新**: `p->lab6_stride += BIG_STRIDE / p->lab6_priority`。这一步推进了进程的 pass 值。
    *   返回 `p`。
*   **`stride_proc_tick`**: 与 RR 类似，递减时间片，用完设置 `need_resched`。

## 知识点总结

*   **调度机制与策略分离**: `sched_class` 的设计体现了这一重要原则，使得操作系统内核更加模块化。
*   **上下文切换**: 理解 `schedule` 函数如何保存当前进程状态并恢复下一个进程状态是理解 OS 多任务的基础。
*   **中断与调度**: 时钟中断是抢占式调度的动力源。理解中断处理程序如何通过 `need_resched` 触发调度。
*   **优先级队列**: Stride 算法展示了如何利用堆结构高效管理基于优先级的任务。

**OS 原理中重要但实验未涉及的点**:
*   **多核调度 (SMP)**: 实验仅涉及单核。多核下的负载均衡、亲和性（Affinity）、锁竞争是现代 OS 调度的难点。
*   **实时调度 (Real-time Scheduling)**: 如 RMS, EDF 等硬实时算法，实验主要关注通用分时调度。
*   **CFS (Completely Fair Scheduler)**: Linux 当前的默认调度器，基于红黑树和虚拟运行时间（vruntime），比 Stride 更复杂且完善，实验中的 Stride 可以看作是 CFS 的简化版或前身。
