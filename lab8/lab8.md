# 实验八报告

## 练习0：填写已有实验

本实验依赖实验2/3/4/5/6/7。请把你做的实验2/3/4/5/6/7的代码填入本实验中代码中有“LAB2”/“LAB3”/“LAB4”/“LAB5”/“LAB6” /“LAB7”的注释相应部分。并确保编译通过。注意：为了能够正确执行lab8的测试应用程序，可能需对已完成的实验2/3/4/5/6/7的代码进行进一步改进。

## 练习1: 完成读文件操作的实现（需要编码）

首先了解打开文件的处理流程，然后参考本实验后续的文件读写操作的过程分析，填写在 kern/fs/sfs/sfs_inode.c中 的sfs_io_nolock()函数，实现读文件中数据的代码。

### 设计思路

`sfs_io_nolock` 函数主要负责在不加锁的情况下进行文件的读写操作。对于读操作，我们需要根据给定的 `offset` 和 `alenp`（长度），将文件内容从磁盘块读入到内存缓冲区 `buf` 中。

读操作主要分为三种情况处理：
1.  **起始非对齐部分**：如果 `offset` 不是块大小的整数倍，我们需要读取第一个块中从 `offset` 开始的部分数据。
2.  **中间对齐块**：对于中间完整的块，我们可以直接整块读取。
3.  **结尾非对齐部分**：如果结束位置不是块大小的整数倍，我们需要读取最后一个块中剩余的部分数据。

在实现中，我们利用了 `sfs_bmap_load_nolock` 来获取文件逻辑块对应的磁盘块号，然后使用 `sfs_buf_op` (对于读是 `sfs_rbuf`) 或 `sfs_block_op` (对于读是 `sfs_rblock`) 来实际读取数据。

### 代码实现

```c
    if ((offset % SFS_BLKSIZE) != 0) {
        size = (nblks != 0) ? (SFS_BLKSIZE - (offset % SFS_BLKSIZE)) : (endpos - offset);
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        if ((ret = sfs_buf_op(sfs, buf, size, ino, offset)) != 0) {
            goto out;
        }
        alen += size;
        if (nblks == 0) {
            goto out;
        }
        buf += size, blkno ++, nblks --;
    }

    size = SFS_BLKSIZE;
    while (nblks != 0) {
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        if ((ret = sfs_block_op(sfs, buf, ino, 1)) != 0) {
            goto out;
        }
        alen += size, buf += size, blkno ++, nblks --;
    }

    if ((size = endpos % SFS_BLKSIZE) != 0) {
        if ((ret = sfs_bmap_load_nolock(sfs, sin, blkno, &ino)) != 0) {
            goto out;
        }
        if ((ret = sfs_buf_op(sfs, buf, size, ino, 0)) != 0) {
            goto out;
        }
        alen += size;
    }
```

## 练习2: 完成基于文件系统的执行程序机制的实现（需要编码）

改写proc.c中的load_icode函数和其他相关函数，实现基于文件系统的执行程序机制。执行：make qemu。如果能看看到sh用户程序的执行界面，则基本成功了。如果在sh用户界面上可以执行exit, hello（更多用户程序放在user目录下）等其他放置在sfs文件系统中的其他执行程序，则可以认为本实验基本成功。

### 设计思路

在 Lab8 中，`load_icode` 函数的功能从直接加载内存中的 ELF 镜像变为了从文件系统中加载 ELF 文件。主要步骤如下：

1.  **创建内存空间**：调用 `mm_create` 创建新的 `mm_struct`，并调用 `setup_pgdir` 初始化页目录。
2.  **读取 ELF 头**：使用 `load_icode_read` 从文件描述符 `fd` 中读取 ELF 头，并校验魔数。
3.  **加载程序段**：遍历 ELF 的程序头表（Program Header Table），对于类型为 `ELF_PT_LOAD` 的段：
    *   根据段的标志（R/W/X）设置内存权限。
    *   调用 `mm_map` 建立虚拟内存映射。
    *   分配物理页，并使用 `load_icode_read` 将文件内容读取到物理页中。
    *   处理 BSS 段（文件大小小于内存大小的部分），将其清零。
4.  **建立用户栈**：调用 `mm_map` 映射用户栈空间，并分配物理页。
5.  **切换页表**：更新当前进程的 `mm` 和 `cr3` (通过 `lsatp`)。
6.  **处理参数**：计算参数总长度，将参数字符串拷贝到用户栈顶，并设置 `argc` 和 `argv`。
7.  **设置 Trapframe**：设置用户态的栈指针 `sp` 和入口地址 `epc`，并确保状态寄存器允许中断且处于用户模式。

### 代码实现

（代码较长，参见 `kern/process/proc.c` 中的 `load_icode` 函数实现）

## 扩展练习 Challenge1：完成基于“UNIX的PIPE机制”的设计方案

如果要在ucore里加入UNIX的管道（Pipe）机制，至少需要定义哪些数据结构和接口？（接口给出语义即可，不必具体实现。数据结构的设计应当给出一个（或多个）具体的C语言struct定义。在网络上查找相关的Linux资料和实现，请在实验报告中给出设计实现”UNIX的PIPE机制“的概要设方案，你的设计应当体现出对可能出现的同步互斥问题的处理。）

### 概要设计

管道本质上是一个内存缓冲区，用于进程间通信。在 UNIX 中，管道被视为一种特殊的文件。

#### 数据结构

我们需要一个结构体来描述管道的状态，包括缓冲区、读写指针、等待队列等。

```c
#define PIPE_SIZE 4096

struct pipe_inode_info {
    wait_queue_head_t wait_reader;  // 等待读的进程队列
    wait_queue_head_t wait_writer;  // 等待写的进程队列
    unsigned int nreaders;          // 读者数量
    unsigned int nwriters;          // 写者数量
    unsigned int head;              // 缓冲区写指针（逻辑索引）
    unsigned int tail;              // 缓冲区读指针（逻辑索引）
    struct mutex lock;              // 互斥锁，保护管道结构
    char *bufs;                     // 实际的数据缓冲区
};
```

#### 接口语义

1.  **`pipe(int pipefd[2])`**:
    *   创建一个管道，返回两个文件描述符。`pipefd[0]` 用于读，`pipefd[1]` 用于写。
    *   内部会分配一个 `pipe_inode_info` 结构，并关联到两个 `file` 结构体上。

2.  **`read(int fd, void *buf, size_t count)`**:
    *   从管道读取数据。
    *   如果管道为空且有写者，则阻塞等待（放入 `wait_reader`）。
    *   如果管道为空且无写者，返回 0 (EOF)。
    *   读取数据后，唤醒等待的写者（`wait_writer`）。

3.  **`write(int fd, const void *buf, size_t count)`**:
    *   向管道写入数据。
    *   如果管道已满，则阻塞等待（放入 `wait_writer`）。
    *   如果无读者，发送 SIGPIPE 信号。
    *   写入数据后，唤醒等待的读者（`wait_reader`）。

4.  **`close(int fd)`**:
    *   关闭管道的一端。
    *   减少 `nreaders` 或 `nwriters`。
    *   如果计数归零，释放管道资源。
    *   唤醒另一端的等待进程（让它们知道对端已关闭）。

#### 同步互斥处理

*   **互斥**：使用 `mutex` 锁保护 `pipe_inode_info` 的读写操作，确保 `head`、`tail` 等状态的一致性。
*   **同步**：使用条件变量（等待队列 `wait_queue`）。
    *   当读者发现缓冲区空时，释放锁并睡眠在 `wait_reader` 上。
    *   当写者写入数据后，唤醒 `wait_reader` 中的进程。
    *   当写者发现缓冲区满时，释放锁并睡眠在 `wait_writer` 上。
    *   当读者读取数据后，唤醒 `wait_writer` 中的进程。

## 扩展练习 Challenge2：完成基于“UNIX的软连接和硬连接机制”的设计方案

如果要在ucore里加入UNIX的软连接和硬连接机制，至少需要定义哪些数据结构和接口？（接口给出语义即可，不必具体实现。数据结构的设计应当给出一个（或多个）具体的C语言struct定义。在网络上查找相关的Linux资料和实现，请在实验报告中给出设计实现”UNIX的软连接和硬连接机制“的概要设方案，你的设计应当体现出对可能出现的同步互斥问题的处理。）

### 概要设计

#### 硬连接 (Hard Link)

硬连接是指多个文件名指向同一个 inode。

*   **数据结构**：
    *   在 `disk_inode` 中已经有了 `nlinks` 字段，表示指向该 inode 的硬连接数量。
    *   不需要新的核心数据结构，主要是文件系统层面的目录项（directory entry）管理。

*   **接口语义**：
    *   `link(const char *oldpath, const char *newpath)`:
        *   查找 `oldpath` 对应的 inode。
        *   在 `newpath` 的父目录中创建一个新的目录项，指向同一个 inode 号。
        *   增加该 inode 的 `nlinks` 计数。
        *   将 inode 更新写回磁盘。
    *   `unlink(const char *pathname)`:
        *   查找 `pathname` 对应的目录项和 inode。
        *   删除目录项。
        *   减少 inode 的 `nlinks` 计数。
        *   如果 `nlinks` 为 0 且无进程打开该文件，则释放 inode 和数据块。

#### 软连接 (Symbolic Link)

软连接是一个特殊的文件，其内容是另一个文件的路径。

*   **数据结构**：
    *   需要一种新的文件类型 `SFS_TYPE_LINK`。
    *   软连接的 inode 数据块中存储的是目标路径字符串。

```c
// 在 sfs_disk_inode 的 type 字段中增加类型
#define SFS_TYPE_LINK 2
```

*   **接口语义**：
    *   `symlink(const char *target, const char *linkpath)`:
        *   创建一个新文件 `linkpath`，类型为 `SFS_TYPE_LINK`。
        *   将 `target` 字符串写入该文件的数据块。
    *   `readlink(const char *pathname, char *buf, size_t bufsiz)`:
        *   打开软连接文件。
        *   读取其内容（即目标路径）到 `buf`。
    *   **路径解析 (Lookup)**:
        *   在解析路径时，如果遇到 `SFS_TYPE_LINK` 类型的文件：
            *   读取其内容得到新路径。
            *   如果新路径是绝对路径，从根目录重新解析；如果是相对路径，从当前目录继续解析。
            *   需要防止循环链接（例如限制递归深度）。

#### 同步互斥处理

*   **硬连接**：
    *   修改 `nlinks` 时需要加锁（inode 锁），防止并发修改导致计数错误。
    *   `unlink` 操作涉及目录项删除和 inode 更新，需要保证原子性，通常通过文件系统日志或加锁顺序来保证。
*   **软连接**：
    *   创建和读取软连接本身也是文件操作，复用现有的文件读写锁机制即可。
    *   路径解析过程中的递归跳转不需要额外的锁，但要注意死锁检测（如果设计了复杂的锁机制）。

