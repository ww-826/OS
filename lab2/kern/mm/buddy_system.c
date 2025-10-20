#include <pmm.h>
#include <list.h>
#include <string.h>
#include <buddy_system.h>
#include <stdio.h>

#define MAX_ORDER 14 // 2^14 页 = 64MiB
static free_area_t free_area[MAX_ORDER + 1];
#define free_list(order) (free_area[order].free_list)
#define nr_free(order) (free_area[order].nr_free)
#define ORDER2SIZE(order) (1U << (order))

extern struct Page *pages;
extern size_t npage;
extern const size_t nbase;
//BUDDY_ADDR计算方法：
//1. 计算当前页框的索引：page_idx = base - pages
//2. 计算伙伴的索引：buddy_idx = page_idx ^ (1 << order)
//3. 得到伙伴的 Page 指针：buddy = pages + buddy_idx
struct Page* get_buddy_addr(struct Page* base, int order) {
    size_t page_idx = base - pages; 
    size_t buddy_idx = page_idx ^ (1 << order); 
    if(buddy_idx >= (npage - nbase)) {
        return NULL;
    }
    struct Page *buddy = pages + buddy_idx;
    return buddy;
}
#define IS_POWER_OF_2(x) (((x) & ((x) - 1)) == 0)
size_t get_order(size_t n) {
    size_t order = 0;
    size_t size = 1;
    while (size < n) {
        size <<= 1;
        order++;
    }
    return order;
}
size_t get_current_max_order() {
    for (int order = MAX_ORDER; order >= 0; order--) {
        if (nr_free(order) > 0) {
            return order;
        }
    }
    return 0;
}
static size_t total_nr_free;
static void
buddy_system_init(void) {
    for (int i = 0; i <= MAX_ORDER; i++) {
        list_init(&free_list(i));
        nr_free(i) = 0;
    }
    total_nr_free = 0;
}

static void
buddy_system_init_memmap(struct Page *base, size_t n) {
    assert(n > 0);

    //将所有传入的页面标记为空闲，并清除标志
    for (struct Page *p = base; p < base + n; p++) {
        assert(PageReserved(p));
        p->flags = 0;
        set_page_ref(p, 0);
    }

    size_t current_pos = 0;
    while (current_pos < n) {
        // 找到当前位置的 Page 指针
        struct Page *current_page = base + current_pos;
        
        //找到从 current_page 开始，能创建的最大的、且不超过剩余内存的、自然对齐的块
        int max_possible_order = 0;
        // 从最大阶开始尝试
        for (int order = MAX_ORDER; order >= 0; order--) {
            size_t block_size = ORDER2SIZE(order);
            
            // 检查对齐：(page_idx % block_size) == 0
            if (((current_page - pages) % block_size) == 0) {
                // 检查边界：块是否会超出总范围 n
                if (current_pos + block_size <= n) {
                    max_possible_order = order;
                    break; // 找到了能创建的最大块
                }
            }
        }

        size_t block_size = ORDER2SIZE(max_possible_order);
        SetPageProperty(current_page);
        current_page->property = max_possible_order;
        list_add(&free_list(max_possible_order), &(current_page->page_link));
        nr_free(max_possible_order)++;
        total_nr_free += block_size;

        current_pos += block_size;
    }
}

static struct Page *
buddy_system_alloc_pages(size_t n) {
    if(n == 0) {
        return NULL;
    }
    if (n > ORDER2SIZE(get_current_max_order())) {
        return NULL;
    }
    if( !IS_POWER_OF_2(n)) {
        return NULL;
    }
    int order = get_order(n);
    int current_order;
    for (current_order = order; current_order <= MAX_ORDER; current_order++) {
        if (nr_free(current_order) > 0) {
            break;
        }
    }
    assert(current_order <= MAX_ORDER);

    list_entry_t *le = list_next(&free_list(current_order));
    struct Page *page = le2page(le, page_link);
    list_del(&(page->page_link));
    nr_free(current_order)--;

    while (current_order > order) {
        current_order--;
        struct Page *buddy = get_buddy_addr(page, current_order);
        assert(buddy != NULL);
        SetPageProperty(buddy);
        buddy->property = current_order;
        list_add(&free_list(current_order), &(buddy->page_link));
        nr_free(current_order)++;
    }
    ClearPageProperty(page);
    page->property = order;
    total_nr_free -= n;
    return page;
}

static void
buddy_system_free_pages(struct Page *base, size_t n) {
    assert(n > 0);
    int order = get_order(n);
    struct Page *page = base;
    assert(page->property == order);
    while (order < MAX_ORDER) {
        struct Page *buddy = get_buddy_addr(page, order);
        if(buddy == NULL) {
            break;
        }
        if (!PageProperty(buddy) || buddy->property != order) {
            break;
        }
        list_del(&(buddy->page_link));
        ClearPageProperty(buddy);
        nr_free(order)--;

        if (buddy < page) {
            page = buddy;
        }
        order++;
    }
    SetPageProperty(page);
    page->property = order;
    list_add(&free_list(order), &(page->page_link));
    nr_free(order)++;
    total_nr_free += n;
}

static size_t
buddy_system_nr_free_pages(void) {
    return total_nr_free;
}
//借助AI生成的验证函数
static void print_buddy_system_status(void) {
    cprintf("  [Buddy Status] nr_free per order:\n");
    for (int i = 0; i <= MAX_ORDER; i++) {
        if (nr_free(i) > 0) {
            cprintf("    order-%-2d: %u\n", i, nr_free(i));
        }
    }
    cprintf("  Total free pages: %u\n", total_nr_free);
}
static void
buddy_system_check(void) {
    cprintf("==================================================\n");
    cprintf("buddy_system_check() starting...\n");
    cprintf("==================================================\n");

    // --- 0. 打印初始状态 ---
    size_t min_idx = -1, max_idx = 0;
    for (int i = 0; i <= MAX_ORDER; i++) {
        list_entry_t *le = &free_list(i);
        while ((le = list_next(le)) != &free_list(i)) {
            struct Page *p = le2page(le, page_link);
            size_t current_idx = p - pages;
            if (current_idx < min_idx) min_idx = current_idx;
            if (current_idx > max_idx) max_idx = current_idx + ORDER2SIZE(i) - 1;
        }
    }
    cprintf("Initial available page index range: [%u, %u]\n", min_idx, max_idx);
    print_buddy_system_status();
    cprintf("\n");

    size_t initial_free = buddy_system_nr_free_pages();

    // --- 1. 基本分配和释放测试 ---
    cprintf("--- 1. Basic alloc/free test ---\n");
    struct Page *p1, *p2, *p4;
    p1 = alloc_pages(1); assert(p1 != NULL);
    p2 = alloc_pages(2); assert(p2 != NULL);
    p4 = alloc_pages(4); assert(p4 != NULL);
    assert(p1 != p2 && p1 != p4 && p2 != p4);
    cprintf("  After allocating 1, 2, 4 pages:\n");
    print_buddy_system_status();

    free_pages(p1, 1);
    free_pages(p2, 2);
    free_pages(p4, 4);
    assert(buddy_system_nr_free_pages() == initial_free);
    cprintf("  After freeing all pages:\n");
    print_buddy_system_status();
    cprintf("buddy_system_check(): basic alloc/free pass.\n\n");

    // --- 2. 边界条件和非法请求测试 ---
    cprintf("--- 2. Edge case and invalid request test ---\n");
    assert(alloc_pages(3) == NULL); // 非2的幂次
    assert(alloc_pages(0) == NULL);
    
    size_t max_alloc_size = 1;
    // 找到一个小于总空闲页数一半的最大2的幂次
    while(max_alloc_size * 2 <= initial_free / 2) {
        max_alloc_size *= 2;
    }
    p1 = alloc_pages(max_alloc_size);
    assert(p1 != NULL);
    cprintf("  After allocating max_alloc_size (%u pages):\n", max_alloc_size);
    print_buddy_system_status();

    free_pages(p1, max_alloc_size);
    assert(buddy_system_nr_free_pages() == initial_free);
    cprintf("  After freeing max_alloc_size:\n");
    print_buddy_system_status();
    cprintf("buddy_system_check(): edge case and invalid request pass.\n\n");

    // --- 3. 分裂与合并的深度测试 ---
    cprintf("--- 3. Split and merge test ---\n");
    
    cprintf("  a. Clearing smaller blocks to ensure a clean test environment...\n");
    struct Page *p_temp1, *p_temp2, *p_temp4;
    p_temp1 = alloc_pages(1);
    p_temp2 = alloc_pages(2);
    p_temp4 = alloc_pages(4);
    cprintf("     After clearing temp blocks:\n");
    print_buddy_system_status();

    cprintf("  b. Preparing a clean 8-page block...\n");
    p1 = alloc_pages(8);
    assert(p1 != NULL);
    cprintf("     Allocated p1(8): pa=0x%lx, page_idx=%u\n", page2pa(p1), p1 - pages);
    print_buddy_system_status();
    free_pages(p1, 8);
    size_t free_after_prepare = buddy_system_nr_free_pages();
    cprintf("     Freed p1(8). Current free pages: %u\n", free_after_prepare);
    print_buddy_system_status();

    cprintf("  c. Triggering split...\n");
    struct Page *p_left = alloc_pages(4);
    assert(p_left != NULL);
    cprintf("     Allocated p_left(4): pa=0x%lx, page_idx=%u\n", page2pa(p_left), p_left - pages);
    print_buddy_system_status();
    assert(p_left == p1);

    struct Page *p_right = alloc_pages(4);
    assert(p_right != NULL);
    cprintf("     Allocated p_right(4): pa=0x%lx, page_idx=%u\n", page2pa(p_right), p_right - pages);
    print_buddy_system_status();
    assert(p_right == get_buddy_addr(p_left, 2)); 
    
    cprintf("  d. Triggering merge...\n");
    free_pages(p_left, 4);
    cprintf("     Freed p_left(4):\n");
    print_buddy_system_status();
    free_pages(p_right, 4);
    cprintf("     Freed p_right(4), should trigger merge:\n");
    print_buddy_system_status();
    assert(buddy_system_nr_free_pages() == free_after_prepare);

    cprintf("  e. Verifying merge result...\n");
    struct Page *p_merged = alloc_pages(8);
    assert(p_merged == p1);
    cprintf("     Allocated merged block p_merged(8):\n");
    print_buddy_system_status();
    free_pages(p_merged, 8);
    assert(buddy_system_nr_free_pages() == free_after_prepare);
    cprintf("     Freed merged block:\n");
    print_buddy_system_status();

    cprintf("  f. Restoring smaller blocks...\n");
    if (p_temp1) free_pages(p_temp1, 1);
    if (p_temp2) free_pages(p_temp2, 2);
    if (p_temp4) free_pages(p_temp4, 4);
    assert(buddy_system_nr_free_pages() == initial_free);
    cprintf("     Final state after all tests:\n");
    print_buddy_system_status();

    cprintf("buddy_system_check(): split and merge pass.\n");
    cprintf("==================================================\n");
    cprintf("buddy_system_check() ALL PASSED!\n");
    cprintf("==================================================\n");
}

const struct pmm_manager buddy_system_pmm_manager = {
    .name = "buddy_system_pmm_manager",
    .init = buddy_system_init,
    .init_memmap = buddy_system_init_memmap,
    .alloc_pages = buddy_system_alloc_pages,
    .free_pages = buddy_system_free_pages,
    .nr_free_pages = buddy_system_nr_free_pages,
    .check = buddy_system_check,
};


