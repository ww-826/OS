# lab3

## 练习1：完善中断处理

### 1. 实现过程

本次实验的目标是完善时钟中断的处理机制。具体要求是，在操作系统接收到100次时钟中断后，在屏幕上打印"100 ticks"，并在打印10行后自动关机。

我的实现步骤如下：

每次进入时钟中断后，首先调用 `clock_set_next_event()` 函数，设置下一次时钟中断的触发时间。这是保证时钟中断能够周期性发生的关键。
执行 `ticks++;`，使中断计数器加一。
通过 `if (ticks % 100 == 0)` 判断 `ticks` 是否达到100的倍数。如果条件成立，则调用 `print_ticks()` 函数，输出 "100 ticks"。`if (ticks / 100 >= 10)`，即当 "100 ticks" 输出了10次后，调用 `sbi_shutdown()` 函数来关闭系统。

### 2. 定时器中断处理流程

在本次实验的RISC-V架构下，一个完整的定时器中断处理流程如下：

1.  硬件定时器（Timer）在预设的时间到达后，向CPU发送一个中断请求。
2.  CPU检测到中断信号，暂停当前正在执行的指令。它会查询 `sstatus` 寄存器，判断当前是否处于S模式（Supervisor Mode），并将 `sstatus` 中的 `SPIE` (Supervisor Previous Interrupt Enable) 位保存，然后清除 `SIE` (Supervisor Interrupt Enable) 位以屏蔽后续中断。
3.  CPU将当前的程序计数器 `pc` 的值保存到 `sepc` (Supervisor Exception Program Counter) 寄存器中，并将中断原因（如 `IRQ_S_TIMER`）存入 `scause` 寄存器。
4.  ：CPU根据 `stvec` (Supervisor Trap Vector Base Address) 寄存器中设定的地址，跳转到统一的中断/异常入口点，在我们的实验中是 `__alltraps`。
5. 
    *   `__alltraps` (位于 `trapentry.S`) 首先保存所有通用寄存器的值到栈上，构建一个 `trapframe` 结构体。
    *   调用 `trap` 函数 (位于 `trap.c`)，并将 `trapframe` 的指针作为参数传入。
    *   `trap_dispatch` 函数根据 `scause` 寄存器的值判断中断类型。由于时钟中断是外部中断，其最高位为1（即负数），因此会调用 `interrupt_handler`。
    *   `interrupt_handler` 再次根据 `scause` 的具体值，进入 `IRQ_S_TIMER` 的处理分支，执行我们在练习1中编写的业务逻辑（计数、打印、关机等）。
6.  
    *   `trap` 函数执行完毕后返回到 `__alltraps`。
    *   `__alltraps` 从栈上恢复所有通用寄存器的值。
    *   最后，执行 `sret` 指令。该指令会从 `sepc` 寄存器中恢复 `pc` 的值，并恢复 `sstatus` 寄存器中的中断使能位，从而返回到中断发生前的位置，继续执行原来的程序。


## Challenge1:描述与理解中断流程

#### 1. 中断/异常处理流程

在 uCore 中，中断和异常的处理流程主要分为以下几个步骤：

- **异常产生**：
    
    - 当 CPU 执行指令时，发生中断或异常（如时钟中断、页错误、非法指令等）。
        
    - 硬件会自动跳转到 `stvec` 寄存器中设置的异常向量地址（`__alltraps`）。
        
- **进入 `__alltraps`**：
    
    - `__alltraps` 是异常的汇编入口，定义在 `trapentry.S` 中。
        
    - 它会立即调用 `SAVE_ALL` 宏，将当前的处理器状态（寄存器和异常相关信息）保存到栈中。
        
- **保存上下文**：
    
    - `SAVE_ALL` 将所有通用寄存器（`x0`..`x31`）和部分 CSR（如 `sstatus`、`sepc`、`sbadaddr`、`scause`）保存到栈中。
        
    - 栈上的布局与 C 语言结构体 `struct trapframe` 严格对应，便于后续 C 层代码访问。
        
- **调用 C 层处理函数**：
    
    - `__alltraps` 通过 `mov a0, sp` 将栈指针 `sp` 的值传递给 C 层的 `trap` 函数，作为 `struct trapframe *` 指针。
        
    - `trap` 函数根据 `tf->cause` 判断中断或异常类型，并调用相应的处理函数（如 `interrupt_handler` 或 `exception_handler`）。
        
- **处理完成后返回**：
    
    - C 层处理完成后，返回到汇编代码 `__trapret`。
        
    - `__trapret` 调用 `RESTORE_ALL` 宏恢复之前保存的寄存器和状态。
        
    - 最后通过 `sret` 指令（Supervisor Return）返回到异常发生时的执行上下文。
        

---

#### 2. `mov a0, sp` 的目的

- **作用**：`mov a0, sp` 的作用是将**当前栈指针（sp）的值传递给 `a0` 寄存器**。
    
- **目的**：
    
    - 在 **RISC-V 的调用约定**中，`a0` 是函数的**第一个参数寄存器**。
        
    - 通过这一操作，C 层的 `trap` 函数能够通过其第一个参数（即 `struct trapframe *tf`）访问到栈上保存的 `struct trapframe` 结构。
        
    - 这使得 C 代码可以读取和修改保存的上下文信息（如异常原因、返回地址等）。
        

---

#### 3. `SAVE_ALL` 中寄存器保存位置的确定

`SAVE_ALL` 宏通过预先计算好的偏移量来确定每个寄存器的存储位置：

1. **分配空间**: 使用 `addi sp, sp, -36 * REGBYTES` 预先在栈上分配足够的空间（36 个槽位，每个槽位大小为 `REGBYTES`）。
    
2. **固定偏移**:
    
    - `x0` (zero) 存储在偏移 `0 * REGBYTES`。
        
    - `x1` (ra) 存储在偏移 `1 * REGBYTES`。
        
    - ...
        
    - `x31` 存储在偏移 `31 * REGBYTES`。
        
3. **CSR 存储**: `sstatus`、`sepc`、`sbadaddr`、`scause` 分别存储在偏移 `32 * REGBYTES` 到 `35 * REGBYTES` 处。
    

这种严格的、**与 `struct trapframe` 字段顺序一致**的布局，是 C 层代码能够正确访问上下文信息的关键。

---

#### 4. 是否需要保存所有寄存器？

**是的，`__alltraps` 中需要保存所有通用寄存器和必要的 CSR。**

**原因如下：**

- **中断/异常的通用性**：任何中断或异常（无论是内核态还是用户态产生）都可能破坏当前 CPU 寄存器中的值。保存所有寄存器是确保**上下文完整性**的唯一方法。
    
- **支持嵌套中断**：保存所有寄存器可以确保在处理一个中断时，如果发生更高优先级的中断（嵌套中断），原始的执行上下文不会丢失，从而能够正确地返回和恢复。
    
- **C 层调用约定**：C 函数（如 `trap` 函数及其调用的其他函数）可能会使用到任何通用寄存器（包括**调用者保存**和**被调用者保存**寄存器）。为了防止 C 代码破坏原始线程的状态，必须在进入 C 层代码之前保存所有寄存器。
    


## Challenge 2：理解上下文切换机制

#### 1. `csrw sscratch, sp` 和 `csrrw s0, sscratch, x0` 的作用

这两条指令是 RISC-V 中**从用户态/低特权级进入内核态/高特权级（trap）时**进行栈切换的关键步骤：

|**指令**|**目的**|**详细说明**|
|---|---|---|
|`csrw sscratch, sp`|**保存用户栈指针**|将当前的栈指针 `sp`（此时指向**用户栈**或**较低特权级栈**）的值写入 `sscratch` 寄存器。`sscratch` 用于临时保存上下文信息。|
|`csrrw s0, sscratch, x0`|**切换到内核栈**|1. **读出**：将 `sscratch` 中保存的**旧栈指针**（即用户栈指针）读入 `s0` 寄存器。 2. **写入**：同时将 `x0`（值为 0）写入 `sscratch`。|

> **在 uCore 中**，这两条指令可能被用于 **`sret` 返回前的栈切换准备**，或者在某些特定的上下文切换中作为**临时保存寄存器**的手段。如果它们出现在异常入口，则目的更可能是：在保存上下文前，将用户栈指针存到 `s0`（后续 `SAVE_ALL` 会把 `s0` 存入 `trapframe`），同时清空 `sscratch` 表示进入内核状态。

---

#### 2. 为什么 `SAVE_ALL` 保存了 `stval` 和 `scause`，但 `RESTORE_ALL` 不恢复它们？

- **保存的意义**：
    
    - `stval` 和 `scause` 是异常相关的 **Control and Status Registers (CSRs)**。
        
    - 它们分别记录了**异常地址**（如引起页错误的地址）和**异常原因/类型**。
        
    - 保存它们的目的，是**将异常的详细上下文信息传递给 C 层处理函数**（通过 `struct trapframe`），以便 C 代码能诊断和处理异常。
        
- **不恢复的原因**：
    
    - `stval` 和 `scause` 是用于**描述异常发生时状态的只读信息**。
        
    - 它们不会影响程序从异常中**返回的行为**。
        
    - 返回时，我们只需要恢复 `sstatus`（用于恢复特权级和中断使能状态）和 `sepc`（用于恢复正确的返回地址），确保程序在正确的位置和状态下继续执行即可。恢复 `stval` 和 `scause` 是不必要且无意义的操作。
        




## Challenge3：完善异常处理

### 实现过程

Challenge的目标是捕获并处理非法指令异常和断点异常。

1.  为了触发这两种异常，我在 `kern/init/init.c` 的 `kern_init` 函数中加入了特定的内联汇编代码：
    *   **非法指令**：`asm volatile(".word 0x00000000");` 这条指令在RISC-V中是一条非法指令，执行它必然会引发非法指令异常。
    *   **断点**：`asm volatile("ebreak");` 这是一条标准的断点指令，用于调试，执行它会触发断点异常。

2.  **编写异常处理逻辑**：在 `kern/trap/trap.c` 的 `exception_handler` 函数中，我为 `CAUSE_ILLEGAL_INSTRUCTION` 和 `CAUSE_BREAKPOINT` 两个 case 添加了处理逻辑：
    *   **打印信息**：在这两个 case 中，我首先使用 `cprintf` 输出了异常的类型（如 "Exception type:Illegal instruction"）和发生异常的指令地址（`tf->epc` 的值）。
    *   **更新 `epc` 与RISC-V压缩指令**：异常处理的核心在于，处理完成后必须手动更新 `epc` 寄存器的值，使其跳过引发异常的指令，否则当从异常返回后，CPU会再次执行同一条指令，导致无限循环。

        在这里，不能简单地假设所有指令都是4字节长（即 `epc = epc + 4`）。RISC-V 架构支持一个称为“C”扩展的**压缩指令集 (Compressed Instructions)**。当启用此扩展时，指令可以是16位（2字节）长，也可以是标准的32位（4字节）长。这些2字节的指令通常是常用指令的紧凑编码，可以显著提高代码密度，减少指令缓存的压力。

        判断一条指令是2字节还是4字节长的方法是检查其最低两位：
        *   如果指令的 `inst[1:0]` 不等于 `11`，那么它是一条16位的压缩指令。
        *   如果指令的 `inst[1:0]` 等于 `11`，那么它是一条32位或更长的标准指令。

        因此，在异常处理程序中，为了正确地跳过当前指令，必须先读取异常地址 `epc` 处的指令内容，判断其长度，然后将 `epc` 增加2或4。在我们的实验代码中，`get_instruction_length(tf->epc)` 函数正是实现了这一逻辑，从而确保了无论是标准指令还是压缩指令引发的异常，都能被正确处理。

这样，当系统执行到非法指令或断点时，就会打印出相关信息，然后跳过该指令继续执行，而不会使系统崩溃。

## 重要知识点总结

### RISC-V64 中断与异常相关寄存器

在RISC-V架构中，中断和异常的处理由一系列的控制状态寄存器（CSRs）来管理。在S模式（Supervisor Mode）下，以下寄存器至关重要：

*   **`sstatus` (Supervisor Status Register)**: S模式状态寄存器。
    *   `SIE` (Supervisor Interrupt Enable) 位：控制S模式下中断是否被响应。当该位为0时，S模式的中断被屏蔽。
    *   `SPIE` (Supervisor Previous Interrupt Enable) 位：记录在进入trap之前`SIE`位的状态。当执行`sret`指令时，`SIE`位会恢复为`SPIE`位的值，`SPIE`位本身则被置1。
    *   `SPP` (Supervisor Previous Privilege) 位：记录trap发生前的特权级（0表示U模式，1表示S模式）。`sret`指令根据此位来决定返回到U模式还是S模式。

*   **`stvec` (Supervisor Trap Vector Base Address Register)**: S模式trap向量基地址寄存器。它保存了S模式下所有中断和异常处理程序的入口地址。它可以配置为两种模式：
    *   **Direct Mode**：所有trap都跳转到`stvec`设定的同一个地址。
    *   **Vectored Mode**：根据中断/异常原因，跳转到`stvec`基地址加上一个偏移量的地址，实现硬件级别的中断分发。本实验采用的是Direct Mode。

*   **`scause` (Supervisor Cause Register)**: S模式trap原因寄存器。当trap发生时，硬件会设置此寄存器来表明trap的原因。最高位为1表示是中断（Interrupt），为0表示是异常（Exception）。其余位则编码了具体的中断号或异常码。

*   **`sepc` (Supervisor Exception Program Counter)**: S模式异常程序计数器。当trap发生时，硬件会将当前指令的地址（PC）保存在`sepc`中。在trap处理完成后，通过`sret`指令可以将`sepc`的值恢复到PC，从而返回到被中断或发生异常的地方继续执行。

*   **`stval` (Supervisor Trap Value Register)**: S模式trap值寄存器。它为trap处理程序提供补充信息。例如，在发生缺页异常时，`stval`会保存导致异常的虚拟地址；在发生非法指令异常时，它可能会保存指令本身。

*   **`sip` (Supervisor Interrupt Pending Register)**: S模式中断挂起寄存器。它显示了哪些S模式中断正在等待处理。例如，`STIP`位表示时钟中断挂起，`SSIP`位表示软件中断挂起。


| 实验知识点 | OS原理知识点 | 理解与分析 |
| :--- | :--- | :--- |
| **中断描述符表 (IDT) / stvec** | **中断向量表** | **含义**：两者都是用于存放中断服务程序入口地址的数据结构。当发生中断时，CPU通过它找到对应的处理程序。 <br> **关系**：`stvec` 是RISC-V架构下S模式的中断向量基地址寄存器，功能上等同于x86中的IDT。 <br> **差异**：x86的IDT是一个复杂的表结构，每个中断号对应一个门描述符，包含段选择子、偏移量、权限等信息。而RISC-V的`stvec`更为简洁，可以直接指向一个统一的`trap_handler`，由软件根据`scause`寄存器来分发，也可以配置为向量模式，直接跳转到不同的处理地址。本实验采用的是前者。 |
| **trapframe 结构体** | **进程控制块 (PCB) / 上下文切换** | **含义**：`trapframe`用于在中断/异常发生时，保存CPU的寄存器状态（即“现场”）。OS原理中的上下文切换指的是保存一个进程的现场，并加载另一个进程的现场。 <br> **关系**：`trapframe`是实现上下文切换的基础。中断/异常处理是上下文切换最常见的触发方式之一。保存到`trapframe`中的信息是进程上下文的一部分。 <br> **差异**：`trapframe`通常只包含通用寄存器和一些控制寄存器（如`epc`, `status`），是中断/异常发生时硬件或底层软件必须保存的部分。而一个完整的进程上下文（如PCB中描述的）除了这些，还包括内存管理信息（页表）、打开的文件列表、进程状态等更丰富的内容。 |

## OS原理中重要但实验未体现的知识点

虽然实验代码中提到了`ecall`，但并未真正实现从用户态通过系统调用进入内核态的完整流程。整个实验代码都运行在S模式（内核态）下。

