#include "types.h"
#include "defs.h"
#include "mmu.h"
#include "proc.h"
#include "memlayout.h"
#include "x86.h"


#define SWAPSLOTS 300
#define PGSIZE 4096
#define BSIZE 512


struct swapblocks{
int is_free;
int page_perm;
}; // I am assuming that it will be assigned to 0 and not explicitly assigning it.


struct swapblocks swap_slots[SWAPSLOTS];

void swapinit() {
  for(int i=0; i<SWAPSLOTS; i++) {
    swap_slots[i].is_free = 0;
    // swap_slots[i].page_perm = 0;
  }
}

void clean_swapblocks(struct proc* process) {
  pde_t* pde = process->pgdir;
  for(int i=0; i<1024; i++) {
    if (pde[i]==0) {
      continue;
    } 
    if (pde[i] & PTE_P) {
      pte_t* pte = (pte_t*) P2V(PTE_ADDR(pde[i]));
      for (int j=0; j<1024; j++) {
        if (!(pte[j] & PTE_P)) {
          // cprintf("Clearing swap blocks\n");
          uint slot = PTE_ADDR(pte[j]) >> 12;
          swap_slots[slot].is_free = 0;
          // swap_slots[slot].page_perm = 0;
        } 
      }
    } 
    
  }
  return;
}

static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
  if(*pde & PTE_P){
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
      return 0;
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
    // // The permissions here are overly generous, but they can
    // // be further restricted by the permissions in the page table
    // // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
}

struct proc* choose_process()
{
 /// Write a function in proc.c that iterates over the proc table and finds the process with most pages.
    return find_proc();
}

pte_t* page_to_be_removed(struct proc* process) //// This is a fuction that could be made more efficient
{
  for (int va=0;va<process->sz;va+=PGSIZE)
  { 
    pte_t* result = walkpgdir(process->pgdir,(void *)va, 0);
    if (result==0)
      continue;
    if((*result & PTE_P) && !(*result & PTE_A))
      return result;
    //return result;
  }
  return 0;
}

 // Find victim page
pte_t* choose_page(struct proc* process)
{
    pte_t* page= page_to_be_removed(process);
    if (page==0)
    {
      int counter=0;
      for (int va=0;va<process->sz;va+=PGSIZE)
        { 
          pte_t* result = walkpgdir(process->pgdir,(void *)va, 0);
          
          // if (*result & PTE_P) {
            if (*result & PTE_A) {
              if(counter==9)
              {
                  counter=0;
                  *result &= ~PTE_A;
              }
              counter++;
            }
            
          // }
          
        }
        
    page= page_to_be_removed(process);}
    return page;
    
}

// Swap in
void swappage()
{   uint va = rcr2(); // Get the faulting virtual address
    //
    va = PGROUNDDOWN(va);
    pte_t *pte = walkpgdir(myproc()->pgdir, (char *)va, 0);
    // cprintf("SWAPIN START: The pte entry is %x %x\n", *pte, va);
    // if (pte)
    // {
      // cprintf("TEST TEST \n");
      // Allocate a new page in memory
      // uint va = rcr();
      char *mem = kalloc();
      if (!mem) {
          panic("page_fault_handler: kalloc failed");
      }

      // cprintf("SWAPIN START: The kalloc address is %x %x \n", mem, va);
        // char buf[BSIZE];
        int swap_slot = PTE_ADDR(*pte) >> 12;
        read_page_from_disk(mem, 2+8*swap_slot);
        // cprintf("The SWAPSLOT read is %d\n", swap_slot);
        // for (int i=0; i<8; i++) {
        //     rsect(swap_slot*8 + i, buf);
        //     memmove(mem, buf, BSIZE);
        //     mem += BSIZE;
        // }
        *pte = V2P(mem) | (*pte & 0xFFF);
        *pte |= PTE_P ;
        myproc()->rss += PGSIZE;
        swap_slots[swap_slot].is_free = 0;
        swap_slots[swap_slot].page_perm = 0;
        // cprintf("SWAPIN: The pte entry is %x \n", mem);
        // cprintf("SWAPIN END: The pte entry is %x \n", *pte);
        // Update the page table entry of the swapped-in page
        // *pte = V2P(mem) | PTE_P | PTE_W | PTE_U;
        // exit();
    // } else {
    //     cprintf("page_fault_handler: Page table entry not found for virtual address: %x\n", va);
    //     exit();
    // }

    return;
}

void page_out() // we have to set the PTE_P entry to 0
{
    struct proc* victim_proc = choose_process();
    // cprintf("process pid: %d \n", victim_proc->pid);
    
    pte_t* victime_page = choose_page(victim_proc);
    // cprintf("Page out enetered\n");
    // cprintf("SWAPOUT START: The pte entry is %x %x\n", victime_page, P2V(*victime_page));
    int f = 0;
    // pte_t* data=0;
    for (int i=0; i < SWAPSLOTS; i++)
    {
      
      if (swap_slots[i].is_free == 0) {
        f = 1;
        char* page = (char*) P2V(PTE_ADDR(*victime_page));
        // changed by Adithya
        // data=(pte_t *)(P2V(PTE_ADDR(*victime_page))) ; 
        // char* data;
        // memmove(data, (char*)P2V(PTE_ADDR(*victime_page)), PGSIZE); // changed by Adithya
        //cprintf("write page to disk called with i= %d \n",i);
        // write_page_to_disk( (char *) victime_page, (uint) (2+8*i));//1 added for debugging// confirm if this function takes physical address or virtual address.
        write_page_to_disk(page, 2+8*i);
        swap_slots[i].is_free = 1;
        swap_slots[i].page_perm = *victime_page & 0xFFF;
        //cprintf("write page to disk returned with i= %d \n",i);
        // cprintf("SWAP SLOT ALLOCATED %d \n", i);
        // cprintf("SWAPOUT: The pte entry is %x \n", data);
        // for (int j=0; j<8; j++) {
        //  wsect(2+8*i+j, data);
        //  data += BSIZE;
        // }
        *victime_page = (i << 12) | (*victime_page & 0xFFF);
        *victime_page &= ~PTE_P;
        victim_proc->rss -= PGSIZE;
        kfree(page);
        // *victime_page = (i << 12) | PTE_S;
        
        break;
      }
    }
    
    if (f == 0) {
      cprintf("No free swapslots\n");
    }
    // cprintf("Success\n");
    // return data;    //return victime_page;  Changed by Adithya
}
