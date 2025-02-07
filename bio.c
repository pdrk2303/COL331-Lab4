// Buffer cache.
//
// The buffer cache is a linked list of buf structures holding
// cached copies of disk block contents.  Caching disk blocks
// in memory reduces the number of disk reads and also provides
// a synchronization point for disk blocks used by multiple processes.
//
// Interface:
// * To get a buffer for a particular disk block, call bread.
// * After changing buffer data, call bwrite to write it to disk.
// * When done with the buffer, call brelse.
// * Do not use the buffer after calling brelse.
// * Only one process at a time can use a buffer,
//     so do not keep them longer than necessary.
//
// The implementation uses two state flags internally:
// * B_VALID: the buffer data has been read from the disk.
// * B_DIRTY: the buffer data has been modified
//     and needs to be written to disk.

#include "types.h"
#include "defs.h"
#include "param.h"
#include "spinlock.h"
#include "sleeplock.h"
#include "fs.h"
#include "buf.h"

struct {
  struct spinlock lock;
  struct buf buf[NBUF];

  // Linked list of all buffers, through prev/next.
  // head.next is most recently used.
  struct buf head;
} bcache;

void
binit(void)
{
  struct buf *b;

  initlock(&bcache.lock, "bcache");

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    b->next = bcache.head.next;
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}

// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
  struct buf *b;

  acquire(&bcache.lock);

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    if(b->dev == dev && b->blockno == blockno){
      b->refcnt++;
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
  //cprintf("block not cached\n");
  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
      b->dev = dev;
      b->blockno = blockno;
      b->flags = 0;
      b->refcnt = 1;
      release(&bcache.lock);
      acquiresleep(&b->lock);
      return b;
    }
  }
 // cprintf("buffer is full\n");
  panic("bget: no buffers");
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
  struct buf *b;

  b = bget(dev, blockno);
  if((b->flags & B_VALID) == 0) {
    iderw(b);
  }
  return b;
}

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("bwrite");
  b->flags |= B_DIRTY;
  //cprintf("hello\n");
  iderw(b);
 // cprintf("everyone\n");
}

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
  if(!holdingsleep(&b->lock))
    panic("brelse");

  releasesleep(&b->lock);

  acquire(&bcache.lock);
  b->refcnt--;
  if (b->refcnt == 0) {
    // no one is waiting for it.
    b->next->prev = b->prev;
    b->prev->next = b->next;
    b->next = bcache.head.next;
    b->prev = &bcache.head;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
  
  release(&bcache.lock);
}
//PAGEBREAK!
// Blank page.

/* Write 4096 bytes pg to the eight consecutive
 * starting at blk.
 */
void
write_page_to_disk(char *pg, uint blk)
{ 

  struct buf *b[8];

  for (int i = 0; i < 8; ++i) {
   // cprintf("Block id: %d \n", blk+i);
    b[i] = bget(ROOTDEV, blk+i);
    // cprintf("what the fuck\n");
   //Manually copying data into the struc of buffers
    int index;
    for (index = 0; index < 512; index++) {
      // cprintf("hi\n");
      b[i] -> data[index] = pg[(i*512) + index];
      // cprintf("hiiii\n");
    }
    // cprintf("a\n");
    bwrite(b[i]);
    // cprintf("b\n");
    brelse(b[i]);
    // cprintf("c\n");

  }

}

/* Read 4096 bytes from the eight consecutive
 * starting at blk into pg.
 */
void
read_page_from_disk(char *pg, uint blk)
{

  struct buf *b[8];
  int offset = 0;

  for (int i = 0; i < 8; i++) {
    
    // Read a blovk of data from the memory to the buffer b[i]
    b[i] = bread(ROOTDEV, blk + i);

   // Copy b[i] -> data into pg page
    int index;
    for (index = 0; index < 512; index++) {
        pg[(i*512) + index] = b[i] -> data[index];
    }

    // memmove(pg + offset, b[i] -> data, 512);

    offset += BSIZE;   

    // Release the lock taken by the bread
    brelse(b[i]);

  } 

}


// /* Write 4096 bytes pg to the eight consecutive
//  * starting at blk.
//  */
// void
// write_page_to_disk(char *pg, uint blk)
// {
//   //****************xv7**********************
//   struct buf* buffer;
//   int blockno=0;
//   int ithPartOfPage=0;    //which part of page (out of 8) is to be written to disk
//   for(int i=0;i<8;i++){
//     // begin_op();           //for atomicity , the block must be written to the disk
//     ithPartOfPage=i*512;
//     blockno=blk+i;
//     buffer=bget(ROOTDEV,blockno);
//     cptintf("bget returned\n");
//     /*
//     Writing physical page to disk by dividing it into 8 pieces (4096 bytes/8 = 512 bytes = 1 block)
//     As one page requires 8 disk blocks
//     */
//     memmove(buffer->data,pg+ithPartOfPage,512);   // write 512 bytes to the block
//     bwrite(buffer);
//     brelse(buffer);                               //release lock
//     // end_op();
//   }
// }

// /* Read 4096 bytes from the eight consecutive
//  * starting at blk into pg.
//  */
// void
// read_page_from_disk(char *pg, uint blk)
// {
//   //**************xv7************************
//   struct buf* buffer;
//   int blockno=0;
//   int ithPartOfPage=0;
//   for(int i=0;i<8;i++){
//     ithPartOfPage=i*512;
//     blockno=blk+i;
//     buffer=bread(ROOTDEV,blockno);    //if present in buffer, returns from buffer else from disk
//     memmove(pg+ithPartOfPage, buffer->data,512);  //write to pg from buffer
//     brelse(buffer);                   //release lock
//   }

// }