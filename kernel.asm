
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc c0 c5 10 80       	mov    $0x8010c5c0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 50 32 10 80       	mov    $0x80103250,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax
80100034:	66 90                	xchg   %ax,%ax
80100036:	66 90                	xchg   %ax,%ax
80100038:	66 90                	xchg   %ax,%ax
8010003a:	66 90                	xchg   %ax,%ax
8010003c:	66 90                	xchg   %ax,%ax
8010003e:	66 90                	xchg   %ax,%ax

80100040 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
80100040:	55                   	push   %ebp
80100041:	89 e5                	mov    %esp,%ebp
80100043:	57                   	push   %edi
80100044:	89 d7                	mov    %edx,%edi
80100046:	56                   	push   %esi
80100047:	89 c6                	mov    %eax,%esi
80100049:	53                   	push   %ebx
8010004a:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
8010004d:	68 c0 c5 10 80       	push   $0x8010c5c0
80100052:	e8 09 4b 00 00       	call   80104b60 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100057:	8b 1d 10 0d 11 80    	mov    0x80110d10,%ebx
8010005d:	83 c4 10             	add    $0x10,%esp
80100060:	81 fb bc 0c 11 80    	cmp    $0x80110cbc,%ebx
80100066:	75 13                	jne    8010007b <bget+0x3b>
80100068:	eb 26                	jmp    80100090 <bget+0x50>
8010006a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80100070:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100073:	81 fb bc 0c 11 80    	cmp    $0x80110cbc,%ebx
80100079:	74 15                	je     80100090 <bget+0x50>
    if(b->dev == dev && b->blockno == blockno){
8010007b:	39 73 04             	cmp    %esi,0x4(%ebx)
8010007e:	75 f0                	jne    80100070 <bget+0x30>
80100080:	39 7b 08             	cmp    %edi,0x8(%ebx)
80100083:	75 eb                	jne    80100070 <bget+0x30>
      b->refcnt++;
80100085:	83 43 4c 01          	addl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
80100089:	eb 3f                	jmp    801000ca <bget+0x8a>
8010008b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010008f:	90                   	nop
  }
  //cprintf("block not cached\n");
  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100090:	8b 1d 0c 0d 11 80    	mov    0x80110d0c,%ebx
80100096:	81 fb bc 0c 11 80    	cmp    $0x80110cbc,%ebx
8010009c:	75 0d                	jne    801000ab <bget+0x6b>
8010009e:	eb 4f                	jmp    801000ef <bget+0xaf>
801000a0:	8b 5b 50             	mov    0x50(%ebx),%ebx
801000a3:	81 fb bc 0c 11 80    	cmp    $0x80110cbc,%ebx
801000a9:	74 44                	je     801000ef <bget+0xaf>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
801000ab:	8b 43 4c             	mov    0x4c(%ebx),%eax
801000ae:	85 c0                	test   %eax,%eax
801000b0:	75 ee                	jne    801000a0 <bget+0x60>
801000b2:	f6 03 04             	testb  $0x4,(%ebx)
801000b5:	75 e9                	jne    801000a0 <bget+0x60>
      b->dev = dev;
801000b7:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
801000ba:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
801000bd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
801000c3:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
801000ca:	83 ec 0c             	sub    $0xc,%esp
801000cd:	68 c0 c5 10 80       	push   $0x8010c5c0
801000d2:	e8 49 4b 00 00       	call   80104c20 <release>
      acquiresleep(&b->lock);
801000d7:	8d 43 0c             	lea    0xc(%ebx),%eax
801000da:	89 04 24             	mov    %eax,(%esp)
801000dd:	e8 fe 47 00 00       	call   801048e0 <acquiresleep>
      return b;
801000e2:	83 c4 10             	add    $0x10,%esp
    }
  }
 // cprintf("buffer is full\n");
  panic("bget: no buffers");
}
801000e5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801000e8:	89 d8                	mov    %ebx,%eax
801000ea:	5b                   	pop    %ebx
801000eb:	5e                   	pop    %esi
801000ec:	5f                   	pop    %edi
801000ed:	5d                   	pop    %ebp
801000ee:	c3                   	ret    
  panic("bget: no buffers");
801000ef:	83 ec 0c             	sub    $0xc,%esp
801000f2:	68 60 77 10 80       	push   $0x80107760
801000f7:	e8 94 03 00 00       	call   80100490 <panic>
801000fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100100 <binit>:
{
80100100:	f3 0f 1e fb          	endbr32 
80100104:	55                   	push   %ebp
80100105:	89 e5                	mov    %esp,%ebp
80100107:	53                   	push   %ebx
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100108:	bb f4 c5 10 80       	mov    $0x8010c5f4,%ebx
{
8010010d:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
80100110:	68 71 77 10 80       	push   $0x80107771
80100115:	68 c0 c5 10 80       	push   $0x8010c5c0
8010011a:	e8 c1 48 00 00       	call   801049e0 <initlock>
  bcache.head.next = &bcache.head;
8010011f:	83 c4 10             	add    $0x10,%esp
80100122:	b8 bc 0c 11 80       	mov    $0x80110cbc,%eax
  bcache.head.prev = &bcache.head;
80100127:	c7 05 0c 0d 11 80 bc 	movl   $0x80110cbc,0x80110d0c
8010012e:	0c 11 80 
  bcache.head.next = &bcache.head;
80100131:	c7 05 10 0d 11 80 bc 	movl   $0x80110cbc,0x80110d10
80100138:	0c 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010013b:	eb 05                	jmp    80100142 <binit+0x42>
8010013d:	8d 76 00             	lea    0x0(%esi),%esi
80100140:	89 d3                	mov    %edx,%ebx
    b->next = bcache.head.next;
80100142:	89 43 54             	mov    %eax,0x54(%ebx)
    initsleeplock(&b->lock, "buffer");
80100145:	83 ec 08             	sub    $0x8,%esp
80100148:	8d 43 0c             	lea    0xc(%ebx),%eax
    b->prev = &bcache.head;
8010014b:	c7 43 50 bc 0c 11 80 	movl   $0x80110cbc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100152:	68 78 77 10 80       	push   $0x80107778
80100157:	50                   	push   %eax
80100158:	e8 43 47 00 00       	call   801048a0 <initsleeplock>
    bcache.head.next->prev = b;
8010015d:	a1 10 0d 11 80       	mov    0x80110d10,%eax
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100162:	8d 93 5c 02 00 00    	lea    0x25c(%ebx),%edx
80100168:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
8010016b:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010016e:	89 d8                	mov    %ebx,%eax
80100170:	89 1d 10 0d 11 80    	mov    %ebx,0x80110d10
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100176:	81 fb 60 0a 11 80    	cmp    $0x80110a60,%ebx
8010017c:	75 c2                	jne    80100140 <binit+0x40>
}
8010017e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100181:	c9                   	leave  
80100182:	c3                   	ret    
80100183:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010018a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100190 <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
80100190:	f3 0f 1e fb          	endbr32 
80100194:	55                   	push   %ebp
80100195:	89 e5                	mov    %esp,%ebp
80100197:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
8010019a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010019d:	8b 45 08             	mov    0x8(%ebp),%eax
801001a0:	e8 9b fe ff ff       	call   80100040 <bget>
  if((b->flags & B_VALID) == 0) {
801001a5:	f6 00 02             	testb  $0x2,(%eax)
801001a8:	74 06                	je     801001b0 <bread+0x20>
    iderw(b);
  }
  return b;
}
801001aa:	c9                   	leave  
801001ab:	c3                   	ret    
801001ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    iderw(b);
801001b0:	83 ec 0c             	sub    $0xc,%esp
801001b3:	89 45 f4             	mov    %eax,-0xc(%ebp)
801001b6:	50                   	push   %eax
801001b7:	e8 c4 21 00 00       	call   80102380 <iderw>
801001bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001bf:	83 c4 10             	add    $0x10,%esp
}
801001c2:	c9                   	leave  
801001c3:	c3                   	ret    
801001c4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801001cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801001cf:	90                   	nop

801001d0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001d0:	f3 0f 1e fb          	endbr32 
801001d4:	55                   	push   %ebp
801001d5:	89 e5                	mov    %esp,%ebp
801001d7:	53                   	push   %ebx
801001d8:	83 ec 10             	sub    $0x10,%esp
801001db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001de:	8d 43 0c             	lea    0xc(%ebx),%eax
801001e1:	50                   	push   %eax
801001e2:	e8 99 47 00 00       	call   80104980 <holdingsleep>
801001e7:	83 c4 10             	add    $0x10,%esp
801001ea:	85 c0                	test   %eax,%eax
801001ec:	74 0f                	je     801001fd <bwrite+0x2d>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001ee:	83 0b 04             	orl    $0x4,(%ebx)
  //cprintf("hello\n");
  iderw(b);
801001f1:	89 5d 08             	mov    %ebx,0x8(%ebp)
 // cprintf("everyone\n");
}
801001f4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001f7:	c9                   	leave  
  iderw(b);
801001f8:	e9 83 21 00 00       	jmp    80102380 <iderw>
    panic("bwrite");
801001fd:	83 ec 0c             	sub    $0xc,%esp
80100200:	68 7f 77 10 80       	push   $0x8010777f
80100205:	e8 86 02 00 00       	call   80100490 <panic>
8010020a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100210 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
80100210:	f3 0f 1e fb          	endbr32 
80100214:	55                   	push   %ebp
80100215:	89 e5                	mov    %esp,%ebp
80100217:	56                   	push   %esi
80100218:	53                   	push   %ebx
80100219:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
8010021c:	8d 73 0c             	lea    0xc(%ebx),%esi
8010021f:	83 ec 0c             	sub    $0xc,%esp
80100222:	56                   	push   %esi
80100223:	e8 58 47 00 00       	call   80104980 <holdingsleep>
80100228:	83 c4 10             	add    $0x10,%esp
8010022b:	85 c0                	test   %eax,%eax
8010022d:	74 66                	je     80100295 <brelse+0x85>
    panic("brelse");

  releasesleep(&b->lock);
8010022f:	83 ec 0c             	sub    $0xc,%esp
80100232:	56                   	push   %esi
80100233:	e8 08 47 00 00       	call   80104940 <releasesleep>

  acquire(&bcache.lock);
80100238:	c7 04 24 c0 c5 10 80 	movl   $0x8010c5c0,(%esp)
8010023f:	e8 1c 49 00 00       	call   80104b60 <acquire>
  b->refcnt--;
80100244:	8b 43 4c             	mov    0x4c(%ebx),%eax
  if (b->refcnt == 0) {
80100247:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
8010024a:	83 e8 01             	sub    $0x1,%eax
8010024d:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
80100250:	85 c0                	test   %eax,%eax
80100252:	75 2f                	jne    80100283 <brelse+0x73>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100254:	8b 43 54             	mov    0x54(%ebx),%eax
80100257:	8b 53 50             	mov    0x50(%ebx),%edx
8010025a:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
8010025d:	8b 43 50             	mov    0x50(%ebx),%eax
80100260:	8b 53 54             	mov    0x54(%ebx),%edx
80100263:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100266:	a1 10 0d 11 80       	mov    0x80110d10,%eax
    b->prev = &bcache.head;
8010026b:	c7 43 50 bc 0c 11 80 	movl   $0x80110cbc,0x50(%ebx)
    b->next = bcache.head.next;
80100272:	89 43 54             	mov    %eax,0x54(%ebx)
    bcache.head.next->prev = b;
80100275:	a1 10 0d 11 80       	mov    0x80110d10,%eax
8010027a:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010027d:	89 1d 10 0d 11 80    	mov    %ebx,0x80110d10
  }
  
  release(&bcache.lock);
80100283:	c7 45 08 c0 c5 10 80 	movl   $0x8010c5c0,0x8(%ebp)
}
8010028a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010028d:	5b                   	pop    %ebx
8010028e:	5e                   	pop    %esi
8010028f:	5d                   	pop    %ebp
  release(&bcache.lock);
80100290:	e9 8b 49 00 00       	jmp    80104c20 <release>
    panic("brelse");
80100295:	83 ec 0c             	sub    $0xc,%esp
80100298:	68 86 77 10 80       	push   $0x80107786
8010029d:	e8 ee 01 00 00       	call   80100490 <panic>
801002a2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801002a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801002b0 <write_page_to_disk>:
/* Write 4096 bytes pg to the eight consecutive
 * starting at blk.
 */
void
write_page_to_disk(char *pg, uint blk)
{ 
801002b0:	f3 0f 1e fb          	endbr32 
801002b4:	55                   	push   %ebp
801002b5:	89 e5                	mov    %esp,%ebp
801002b7:	57                   	push   %edi
801002b8:	56                   	push   %esi
801002b9:	53                   	push   %ebx
801002ba:	83 ec 1c             	sub    $0x1c,%esp
801002bd:	8b 7d 08             	mov    0x8(%ebp),%edi
801002c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801002c3:	8d 87 00 10 00 00    	lea    0x1000(%edi),%eax
801002c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)

  struct buf *b[8];

  for (int i = 0; i < 8; ++i) {
   // cprintf("Block id: %d \n", blk+i);
    b[i] = bget(ROOTDEV, blk+i);
801002cc:	89 da                	mov    %ebx,%edx
801002ce:	b8 01 00 00 00       	mov    $0x1,%eax
801002d3:	e8 68 fd ff ff       	call   80100040 <bget>
    // cprintf("what the fuck\n");
   //Manually copying data into the struc of buffers
    int index;
    for (index = 0; index < 512; index++) {
801002d8:	31 d2                	xor    %edx,%edx
    b[i] = bget(ROOTDEV, blk+i);
801002da:	89 c6                	mov    %eax,%esi
    for (index = 0; index < 512; index++) {
801002dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      // cprintf("hi\n");
      b[i] -> data[index] = pg[(i*512) + index];
801002e0:	0f b6 0c 17          	movzbl (%edi,%edx,1),%ecx
801002e4:	88 4c 16 5c          	mov    %cl,0x5c(%esi,%edx,1)
    for (index = 0; index < 512; index++) {
801002e8:	83 c2 01             	add    $0x1,%edx
801002eb:	81 fa 00 02 00 00    	cmp    $0x200,%edx
801002f1:	75 ed                	jne    801002e0 <write_page_to_disk+0x30>
      // cprintf("hiiii\n");
    }
    // cprintf("a\n");
    bwrite(b[i]);
801002f3:	83 ec 0c             	sub    $0xc,%esp
801002f6:	83 c3 01             	add    $0x1,%ebx
801002f9:	81 c7 00 02 00 00    	add    $0x200,%edi
801002ff:	56                   	push   %esi
80100300:	e8 cb fe ff ff       	call   801001d0 <bwrite>
    // cprintf("b\n");
    brelse(b[i]);
80100305:	89 34 24             	mov    %esi,(%esp)
80100308:	e8 03 ff ff ff       	call   80100210 <brelse>
  for (int i = 0; i < 8; ++i) {
8010030d:	83 c4 10             	add    $0x10,%esp
80100310:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80100313:	75 b7                	jne    801002cc <write_page_to_disk+0x1c>
    // cprintf("c\n");

  }

}
80100315:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100318:	5b                   	pop    %ebx
80100319:	5e                   	pop    %esi
8010031a:	5f                   	pop    %edi
8010031b:	5d                   	pop    %ebp
8010031c:	c3                   	ret    
8010031d:	8d 76 00             	lea    0x0(%esi),%esi

80100320 <read_page_from_disk>:
/* Read 4096 bytes from the eight consecutive
 * starting at blk into pg.
 */
void
read_page_from_disk(char *pg, uint blk)
{
80100320:	f3 0f 1e fb          	endbr32 
80100324:	55                   	push   %ebp
80100325:	89 e5                	mov    %esp,%ebp
80100327:	57                   	push   %edi
80100328:	56                   	push   %esi
80100329:	53                   	push   %ebx
8010032a:	83 ec 0c             	sub    $0xc,%esp
8010032d:	8b 7d 08             	mov    0x8(%ebp),%edi
80100330:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100333:	8d b7 00 10 00 00    	lea    0x1000(%edi),%esi
  int offset = 0;

  for (int i = 0; i < 8; i++) {
    
    // Read a blovk of data from the memory to the buffer b[i]
    b[i] = bread(ROOTDEV, blk + i);
80100339:	83 ec 08             	sub    $0x8,%esp
8010033c:	53                   	push   %ebx
8010033d:	6a 01                	push   $0x1
8010033f:	e8 4c fe ff ff       	call   80100190 <bread>
80100344:	83 c4 10             	add    $0x10,%esp

   // Copy b[i] -> data into pg page
    int index;
    for (index = 0; index < 512; index++) {
80100347:	31 d2                	xor    %edx,%edx
80100349:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
        pg[(i*512) + index] = b[i] -> data[index];
80100350:	0f b6 4c 10 5c       	movzbl 0x5c(%eax,%edx,1),%ecx
80100355:	88 0c 17             	mov    %cl,(%edi,%edx,1)
    for (index = 0; index < 512; index++) {
80100358:	83 c2 01             	add    $0x1,%edx
8010035b:	81 fa 00 02 00 00    	cmp    $0x200,%edx
80100361:	75 ed                	jne    80100350 <read_page_from_disk+0x30>
    // memmove(pg + offset, b[i] -> data, 512);

    offset += BSIZE;   

    // Release the lock taken by the bread
    brelse(b[i]);
80100363:	83 ec 0c             	sub    $0xc,%esp
80100366:	81 c7 00 02 00 00    	add    $0x200,%edi
8010036c:	83 c3 01             	add    $0x1,%ebx
8010036f:	50                   	push   %eax
80100370:	e8 9b fe ff ff       	call   80100210 <brelse>
  for (int i = 0; i < 8; i++) {
80100375:	83 c4 10             	add    $0x10,%esp
80100378:	39 fe                	cmp    %edi,%esi
8010037a:	75 bd                	jne    80100339 <read_page_from_disk+0x19>

  } 

}
8010037c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010037f:	5b                   	pop    %ebx
80100380:	5e                   	pop    %esi
80100381:	5f                   	pop    %edi
80100382:	5d                   	pop    %ebp
80100383:	c3                   	ret    
80100384:	66 90                	xchg   %ax,%ax
80100386:	66 90                	xchg   %ax,%ax
80100388:	66 90                	xchg   %ax,%ax
8010038a:	66 90                	xchg   %ax,%ax
8010038c:	66 90                	xchg   %ax,%ax
8010038e:	66 90                	xchg   %ax,%ax

80100390 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100390:	f3 0f 1e fb          	endbr32 
80100394:	55                   	push   %ebp
80100395:	89 e5                	mov    %esp,%ebp
80100397:	57                   	push   %edi
80100398:	56                   	push   %esi
80100399:	53                   	push   %ebx
8010039a:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
8010039d:	ff 75 08             	pushl  0x8(%ebp)
{
801003a0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  target = n;
801003a3:	89 de                	mov    %ebx,%esi
  iunlock(ip);
801003a5:	e8 96 15 00 00       	call   80101940 <iunlock>
  acquire(&cons.lock);
801003aa:	c7 04 24 20 b5 10 80 	movl   $0x8010b520,(%esp)
801003b1:	e8 aa 47 00 00       	call   80104b60 <acquire>
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
    }
    *dst++ = c;
801003b6:	8b 7d 0c             	mov    0xc(%ebp),%edi
  while(n > 0){
801003b9:	83 c4 10             	add    $0x10,%esp
    *dst++ = c;
801003bc:	01 df                	add    %ebx,%edi
  while(n > 0){
801003be:	85 db                	test   %ebx,%ebx
801003c0:	0f 8e 97 00 00 00    	jle    8010045d <consoleread+0xcd>
    while(input.r == input.w){
801003c6:	a1 a0 0f 11 80       	mov    0x80110fa0,%eax
801003cb:	3b 05 a4 0f 11 80    	cmp    0x80110fa4,%eax
801003d1:	74 27                	je     801003fa <consoleread+0x6a>
801003d3:	eb 5b                	jmp    80100430 <consoleread+0xa0>
801003d5:	8d 76 00             	lea    0x0(%esi),%esi
      sleep(&input.r, &cons.lock);
801003d8:	83 ec 08             	sub    $0x8,%esp
801003db:	68 20 b5 10 80       	push   $0x8010b520
801003e0:	68 a0 0f 11 80       	push   $0x80110fa0
801003e5:	e8 e6 40 00 00       	call   801044d0 <sleep>
    while(input.r == input.w){
801003ea:	a1 a0 0f 11 80       	mov    0x80110fa0,%eax
801003ef:	83 c4 10             	add    $0x10,%esp
801003f2:	3b 05 a4 0f 11 80    	cmp    0x80110fa4,%eax
801003f8:	75 36                	jne    80100430 <consoleread+0xa0>
      if(myproc()->killed){
801003fa:	e8 a1 3a 00 00       	call   80103ea0 <myproc>
801003ff:	8b 48 28             	mov    0x28(%eax),%ecx
80100402:	85 c9                	test   %ecx,%ecx
80100404:	74 d2                	je     801003d8 <consoleread+0x48>
        release(&cons.lock);
80100406:	83 ec 0c             	sub    $0xc,%esp
80100409:	68 20 b5 10 80       	push   $0x8010b520
8010040e:	e8 0d 48 00 00       	call   80104c20 <release>
        ilock(ip);
80100413:	5a                   	pop    %edx
80100414:	ff 75 08             	pushl  0x8(%ebp)
80100417:	e8 44 14 00 00       	call   80101860 <ilock>
        return -1;
8010041c:	83 c4 10             	add    $0x10,%esp
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
8010041f:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return -1;
80100422:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100427:	5b                   	pop    %ebx
80100428:	5e                   	pop    %esi
80100429:	5f                   	pop    %edi
8010042a:	5d                   	pop    %ebp
8010042b:	c3                   	ret    
8010042c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c = input.buf[input.r++ % INPUT_BUF];
80100430:	8d 50 01             	lea    0x1(%eax),%edx
80100433:	89 15 a0 0f 11 80    	mov    %edx,0x80110fa0
80100439:	89 c2                	mov    %eax,%edx
8010043b:	83 e2 7f             	and    $0x7f,%edx
8010043e:	0f be 8a 20 0f 11 80 	movsbl -0x7feef0e0(%edx),%ecx
    if(c == C('D')){  // EOF
80100445:	80 f9 04             	cmp    $0x4,%cl
80100448:	74 38                	je     80100482 <consoleread+0xf2>
    *dst++ = c;
8010044a:	89 d8                	mov    %ebx,%eax
    --n;
8010044c:	83 eb 01             	sub    $0x1,%ebx
    *dst++ = c;
8010044f:	f7 d8                	neg    %eax
80100451:	88 0c 07             	mov    %cl,(%edi,%eax,1)
    if(c == '\n')
80100454:	83 f9 0a             	cmp    $0xa,%ecx
80100457:	0f 85 61 ff ff ff    	jne    801003be <consoleread+0x2e>
  release(&cons.lock);
8010045d:	83 ec 0c             	sub    $0xc,%esp
80100460:	68 20 b5 10 80       	push   $0x8010b520
80100465:	e8 b6 47 00 00       	call   80104c20 <release>
  ilock(ip);
8010046a:	58                   	pop    %eax
8010046b:	ff 75 08             	pushl  0x8(%ebp)
8010046e:	e8 ed 13 00 00       	call   80101860 <ilock>
  return target - n;
80100473:	89 f0                	mov    %esi,%eax
80100475:	83 c4 10             	add    $0x10,%esp
}
80100478:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return target - n;
8010047b:	29 d8                	sub    %ebx,%eax
}
8010047d:	5b                   	pop    %ebx
8010047e:	5e                   	pop    %esi
8010047f:	5f                   	pop    %edi
80100480:	5d                   	pop    %ebp
80100481:	c3                   	ret    
      if(n < target){
80100482:	39 f3                	cmp    %esi,%ebx
80100484:	73 d7                	jae    8010045d <consoleread+0xcd>
        input.r--;
80100486:	a3 a0 0f 11 80       	mov    %eax,0x80110fa0
8010048b:	eb d0                	jmp    8010045d <consoleread+0xcd>
8010048d:	8d 76 00             	lea    0x0(%esi),%esi

80100490 <panic>:
{
80100490:	f3 0f 1e fb          	endbr32 
80100494:	55                   	push   %ebp
80100495:	89 e5                	mov    %esp,%ebp
80100497:	56                   	push   %esi
80100498:	53                   	push   %ebx
80100499:	83 ec 30             	sub    $0x30,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
8010049c:	fa                   	cli    
  cons.locking = 0;
8010049d:	c7 05 54 b5 10 80 00 	movl   $0x0,0x8010b554
801004a4:	00 00 00 
  getcallerpcs(&s, pcs);
801004a7:	8d 5d d0             	lea    -0x30(%ebp),%ebx
801004aa:	8d 75 f8             	lea    -0x8(%ebp),%esi
  cprintf("lapicid %d: panic: ", lapicid());
801004ad:	e8 fe 25 00 00       	call   80102ab0 <lapicid>
801004b2:	83 ec 08             	sub    $0x8,%esp
801004b5:	50                   	push   %eax
801004b6:	68 8d 77 10 80       	push   $0x8010778d
801004bb:	e8 f0 02 00 00       	call   801007b0 <cprintf>
  cprintf(s);
801004c0:	58                   	pop    %eax
801004c1:	ff 75 08             	pushl  0x8(%ebp)
801004c4:	e8 e7 02 00 00       	call   801007b0 <cprintf>
  cprintf("\n");
801004c9:	c7 04 24 3f 81 10 80 	movl   $0x8010813f,(%esp)
801004d0:	e8 db 02 00 00       	call   801007b0 <cprintf>
  getcallerpcs(&s, pcs);
801004d5:	8d 45 08             	lea    0x8(%ebp),%eax
801004d8:	5a                   	pop    %edx
801004d9:	59                   	pop    %ecx
801004da:	53                   	push   %ebx
801004db:	50                   	push   %eax
801004dc:	e8 1f 45 00 00       	call   80104a00 <getcallerpcs>
  for(i=0; i<10; i++)
801004e1:	83 c4 10             	add    $0x10,%esp
    cprintf(" %p", pcs[i]);
801004e4:	83 ec 08             	sub    $0x8,%esp
801004e7:	ff 33                	pushl  (%ebx)
801004e9:	83 c3 04             	add    $0x4,%ebx
801004ec:	68 a1 77 10 80       	push   $0x801077a1
801004f1:	e8 ba 02 00 00       	call   801007b0 <cprintf>
  for(i=0; i<10; i++)
801004f6:	83 c4 10             	add    $0x10,%esp
801004f9:	39 f3                	cmp    %esi,%ebx
801004fb:	75 e7                	jne    801004e4 <panic+0x54>
  panicked = 1; // freeze other CPU
801004fd:	c7 05 58 b5 10 80 01 	movl   $0x1,0x8010b558
80100504:	00 00 00 
  for(;;)
80100507:	eb fe                	jmp    80100507 <panic+0x77>
80100509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100510 <consputc.part.0>:
consputc(int c)
80100510:	55                   	push   %ebp
80100511:	89 e5                	mov    %esp,%ebp
80100513:	57                   	push   %edi
80100514:	56                   	push   %esi
80100515:	53                   	push   %ebx
80100516:	89 c3                	mov    %eax,%ebx
80100518:	83 ec 1c             	sub    $0x1c,%esp
  if(c == BACKSPACE){
8010051b:	3d 00 01 00 00       	cmp    $0x100,%eax
80100520:	0f 84 ea 00 00 00    	je     80100610 <consputc.part.0+0x100>
    uartputc(c);
80100526:	83 ec 0c             	sub    $0xc,%esp
80100529:	50                   	push   %eax
8010052a:	e8 01 5e 00 00       	call   80106330 <uartputc>
8010052f:	83 c4 10             	add    $0x10,%esp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100532:	bf d4 03 00 00       	mov    $0x3d4,%edi
80100537:	b8 0e 00 00 00       	mov    $0xe,%eax
8010053c:	89 fa                	mov    %edi,%edx
8010053e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010053f:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
80100544:	89 ca                	mov    %ecx,%edx
80100546:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
80100547:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010054a:	89 fa                	mov    %edi,%edx
8010054c:	c1 e0 08             	shl    $0x8,%eax
8010054f:	89 c6                	mov    %eax,%esi
80100551:	b8 0f 00 00 00       	mov    $0xf,%eax
80100556:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100557:	89 ca                	mov    %ecx,%edx
80100559:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
8010055a:	0f b6 c0             	movzbl %al,%eax
8010055d:	09 f0                	or     %esi,%eax
  if(c == '\n')
8010055f:	83 fb 0a             	cmp    $0xa,%ebx
80100562:	0f 84 90 00 00 00    	je     801005f8 <consputc.part.0+0xe8>
  else if(c == BACKSPACE){
80100568:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
8010056e:	74 70                	je     801005e0 <consputc.part.0+0xd0>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100570:	0f b6 db             	movzbl %bl,%ebx
80100573:	8d 70 01             	lea    0x1(%eax),%esi
80100576:	80 cf 07             	or     $0x7,%bh
80100579:	66 89 9c 00 00 80 0b 	mov    %bx,-0x7ff48000(%eax,%eax,1)
80100580:	80 
  if(pos < 0 || pos > 25*80)
80100581:	81 fe d0 07 00 00    	cmp    $0x7d0,%esi
80100587:	0f 8f f9 00 00 00    	jg     80100686 <consputc.part.0+0x176>
  if((pos/80) >= 24){  // Scroll up.
8010058d:	81 fe 7f 07 00 00    	cmp    $0x77f,%esi
80100593:	0f 8f a7 00 00 00    	jg     80100640 <consputc.part.0+0x130>
80100599:	89 f0                	mov    %esi,%eax
8010059b:	8d b4 36 00 80 0b 80 	lea    -0x7ff48000(%esi,%esi,1),%esi
801005a2:	88 45 e7             	mov    %al,-0x19(%ebp)
801005a5:	0f b6 fc             	movzbl %ah,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801005a8:	bb d4 03 00 00       	mov    $0x3d4,%ebx
801005ad:	b8 0e 00 00 00       	mov    $0xe,%eax
801005b2:	89 da                	mov    %ebx,%edx
801005b4:	ee                   	out    %al,(%dx)
801005b5:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
801005ba:	89 f8                	mov    %edi,%eax
801005bc:	89 ca                	mov    %ecx,%edx
801005be:	ee                   	out    %al,(%dx)
801005bf:	b8 0f 00 00 00       	mov    $0xf,%eax
801005c4:	89 da                	mov    %ebx,%edx
801005c6:	ee                   	out    %al,(%dx)
801005c7:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
801005cb:	89 ca                	mov    %ecx,%edx
801005cd:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
801005ce:	b8 20 07 00 00       	mov    $0x720,%eax
801005d3:	66 89 06             	mov    %ax,(%esi)
}
801005d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801005d9:	5b                   	pop    %ebx
801005da:	5e                   	pop    %esi
801005db:	5f                   	pop    %edi
801005dc:	5d                   	pop    %ebp
801005dd:	c3                   	ret    
801005de:	66 90                	xchg   %ax,%ax
    if(pos > 0) --pos;
801005e0:	8d 70 ff             	lea    -0x1(%eax),%esi
801005e3:	85 c0                	test   %eax,%eax
801005e5:	75 9a                	jne    80100581 <consputc.part.0+0x71>
801005e7:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
801005eb:	be 00 80 0b 80       	mov    $0x800b8000,%esi
801005f0:	31 ff                	xor    %edi,%edi
801005f2:	eb b4                	jmp    801005a8 <consputc.part.0+0x98>
801005f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    pos += 80 - pos%80;
801005f8:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
801005fd:	f7 e2                	mul    %edx
801005ff:	c1 ea 06             	shr    $0x6,%edx
80100602:	8d 04 92             	lea    (%edx,%edx,4),%eax
80100605:	c1 e0 04             	shl    $0x4,%eax
80100608:	8d 70 50             	lea    0x50(%eax),%esi
8010060b:	e9 71 ff ff ff       	jmp    80100581 <consputc.part.0+0x71>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100610:	83 ec 0c             	sub    $0xc,%esp
80100613:	6a 08                	push   $0x8
80100615:	e8 16 5d 00 00       	call   80106330 <uartputc>
8010061a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100621:	e8 0a 5d 00 00       	call   80106330 <uartputc>
80100626:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010062d:	e8 fe 5c 00 00       	call   80106330 <uartputc>
80100632:	83 c4 10             	add    $0x10,%esp
80100635:	e9 f8 fe ff ff       	jmp    80100532 <consputc.part.0+0x22>
8010063a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100640:	83 ec 04             	sub    $0x4,%esp
    pos -= 80;
80100643:	8d 5e b0             	lea    -0x50(%esi),%ebx
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100646:	8d b4 36 60 7f 0b 80 	lea    -0x7ff480a0(%esi,%esi,1),%esi
8010064d:	bf 07 00 00 00       	mov    $0x7,%edi
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100652:	68 60 0e 00 00       	push   $0xe60
80100657:	68 a0 80 0b 80       	push   $0x800b80a0
8010065c:	68 00 80 0b 80       	push   $0x800b8000
80100661:	e8 aa 46 00 00       	call   80104d10 <memmove>
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100666:	b8 80 07 00 00       	mov    $0x780,%eax
8010066b:	83 c4 0c             	add    $0xc,%esp
8010066e:	29 d8                	sub    %ebx,%eax
80100670:	01 c0                	add    %eax,%eax
80100672:	50                   	push   %eax
80100673:	6a 00                	push   $0x0
80100675:	56                   	push   %esi
80100676:	e8 f5 45 00 00       	call   80104c70 <memset>
8010067b:	88 5d e7             	mov    %bl,-0x19(%ebp)
8010067e:	83 c4 10             	add    $0x10,%esp
80100681:	e9 22 ff ff ff       	jmp    801005a8 <consputc.part.0+0x98>
    panic("pos under/overflow");
80100686:	83 ec 0c             	sub    $0xc,%esp
80100689:	68 a5 77 10 80       	push   $0x801077a5
8010068e:	e8 fd fd ff ff       	call   80100490 <panic>
80100693:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010069a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801006a0 <printint>:
{
801006a0:	55                   	push   %ebp
801006a1:	89 e5                	mov    %esp,%ebp
801006a3:	57                   	push   %edi
801006a4:	56                   	push   %esi
801006a5:	53                   	push   %ebx
801006a6:	83 ec 2c             	sub    $0x2c,%esp
801006a9:	89 55 d4             	mov    %edx,-0x2c(%ebp)
  if(sign && (sign = xx < 0))
801006ac:	85 c9                	test   %ecx,%ecx
801006ae:	74 04                	je     801006b4 <printint+0x14>
801006b0:	85 c0                	test   %eax,%eax
801006b2:	78 6d                	js     80100721 <printint+0x81>
    x = xx;
801006b4:	89 c1                	mov    %eax,%ecx
801006b6:	31 f6                	xor    %esi,%esi
  i = 0;
801006b8:	89 75 cc             	mov    %esi,-0x34(%ebp)
801006bb:	31 db                	xor    %ebx,%ebx
801006bd:	8d 7d d7             	lea    -0x29(%ebp),%edi
    buf[i++] = digits[x % base];
801006c0:	89 c8                	mov    %ecx,%eax
801006c2:	31 d2                	xor    %edx,%edx
801006c4:	89 ce                	mov    %ecx,%esi
801006c6:	f7 75 d4             	divl   -0x2c(%ebp)
801006c9:	0f b6 92 d0 77 10 80 	movzbl -0x7fef8830(%edx),%edx
801006d0:	89 45 d0             	mov    %eax,-0x30(%ebp)
801006d3:	89 d8                	mov    %ebx,%eax
801006d5:	8d 5b 01             	lea    0x1(%ebx),%ebx
  }while((x /= base) != 0);
801006d8:	8b 4d d0             	mov    -0x30(%ebp),%ecx
801006db:	89 75 d0             	mov    %esi,-0x30(%ebp)
    buf[i++] = digits[x % base];
801006de:	88 14 1f             	mov    %dl,(%edi,%ebx,1)
  }while((x /= base) != 0);
801006e1:	8b 75 d4             	mov    -0x2c(%ebp),%esi
801006e4:	39 75 d0             	cmp    %esi,-0x30(%ebp)
801006e7:	73 d7                	jae    801006c0 <printint+0x20>
801006e9:	8b 75 cc             	mov    -0x34(%ebp),%esi
  if(sign)
801006ec:	85 f6                	test   %esi,%esi
801006ee:	74 0c                	je     801006fc <printint+0x5c>
    buf[i++] = '-';
801006f0:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
    buf[i++] = digits[x % base];
801006f5:	89 d8                	mov    %ebx,%eax
    buf[i++] = '-';
801006f7:	ba 2d 00 00 00       	mov    $0x2d,%edx
  while(--i >= 0)
801006fc:	8d 5c 05 d7          	lea    -0x29(%ebp,%eax,1),%ebx
80100700:	0f be c2             	movsbl %dl,%eax
  if(panicked){
80100703:	8b 15 58 b5 10 80    	mov    0x8010b558,%edx
80100709:	85 d2                	test   %edx,%edx
8010070b:	74 03                	je     80100710 <printint+0x70>
  asm volatile("cli");
8010070d:	fa                   	cli    
    for(;;)
8010070e:	eb fe                	jmp    8010070e <printint+0x6e>
80100710:	e8 fb fd ff ff       	call   80100510 <consputc.part.0>
  while(--i >= 0)
80100715:	39 fb                	cmp    %edi,%ebx
80100717:	74 10                	je     80100729 <printint+0x89>
80100719:	0f be 03             	movsbl (%ebx),%eax
8010071c:	83 eb 01             	sub    $0x1,%ebx
8010071f:	eb e2                	jmp    80100703 <printint+0x63>
    x = -xx;
80100721:	f7 d8                	neg    %eax
80100723:	89 ce                	mov    %ecx,%esi
80100725:	89 c1                	mov    %eax,%ecx
80100727:	eb 8f                	jmp    801006b8 <printint+0x18>
}
80100729:	83 c4 2c             	add    $0x2c,%esp
8010072c:	5b                   	pop    %ebx
8010072d:	5e                   	pop    %esi
8010072e:	5f                   	pop    %edi
8010072f:	5d                   	pop    %ebp
80100730:	c3                   	ret    
80100731:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100738:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010073f:	90                   	nop

80100740 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100740:	f3 0f 1e fb          	endbr32 
80100744:	55                   	push   %ebp
80100745:	89 e5                	mov    %esp,%ebp
80100747:	57                   	push   %edi
80100748:	56                   	push   %esi
80100749:	53                   	push   %ebx
8010074a:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
8010074d:	ff 75 08             	pushl  0x8(%ebp)
{
80100750:	8b 5d 10             	mov    0x10(%ebp),%ebx
  iunlock(ip);
80100753:	e8 e8 11 00 00       	call   80101940 <iunlock>
  acquire(&cons.lock);
80100758:	c7 04 24 20 b5 10 80 	movl   $0x8010b520,(%esp)
8010075f:	e8 fc 43 00 00       	call   80104b60 <acquire>
  for(i = 0; i < n; i++)
80100764:	83 c4 10             	add    $0x10,%esp
80100767:	85 db                	test   %ebx,%ebx
80100769:	7e 24                	jle    8010078f <consolewrite+0x4f>
8010076b:	8b 7d 0c             	mov    0xc(%ebp),%edi
8010076e:	8d 34 1f             	lea    (%edi,%ebx,1),%esi
  if(panicked){
80100771:	8b 15 58 b5 10 80    	mov    0x8010b558,%edx
80100777:	85 d2                	test   %edx,%edx
80100779:	74 05                	je     80100780 <consolewrite+0x40>
8010077b:	fa                   	cli    
    for(;;)
8010077c:	eb fe                	jmp    8010077c <consolewrite+0x3c>
8010077e:	66 90                	xchg   %ax,%ax
    consputc(buf[i] & 0xff);
80100780:	0f b6 07             	movzbl (%edi),%eax
80100783:	83 c7 01             	add    $0x1,%edi
80100786:	e8 85 fd ff ff       	call   80100510 <consputc.part.0>
  for(i = 0; i < n; i++)
8010078b:	39 fe                	cmp    %edi,%esi
8010078d:	75 e2                	jne    80100771 <consolewrite+0x31>
  release(&cons.lock);
8010078f:	83 ec 0c             	sub    $0xc,%esp
80100792:	68 20 b5 10 80       	push   $0x8010b520
80100797:	e8 84 44 00 00       	call   80104c20 <release>
  ilock(ip);
8010079c:	58                   	pop    %eax
8010079d:	ff 75 08             	pushl  0x8(%ebp)
801007a0:	e8 bb 10 00 00       	call   80101860 <ilock>

  return n;
}
801007a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801007a8:	89 d8                	mov    %ebx,%eax
801007aa:	5b                   	pop    %ebx
801007ab:	5e                   	pop    %esi
801007ac:	5f                   	pop    %edi
801007ad:	5d                   	pop    %ebp
801007ae:	c3                   	ret    
801007af:	90                   	nop

801007b0 <cprintf>:
{
801007b0:	f3 0f 1e fb          	endbr32 
801007b4:	55                   	push   %ebp
801007b5:	89 e5                	mov    %esp,%ebp
801007b7:	57                   	push   %edi
801007b8:	56                   	push   %esi
801007b9:	53                   	push   %ebx
801007ba:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
801007bd:	a1 54 b5 10 80       	mov    0x8010b554,%eax
801007c2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if(locking)
801007c5:	85 c0                	test   %eax,%eax
801007c7:	0f 85 e8 00 00 00    	jne    801008b5 <cprintf+0x105>
  if (fmt == 0)
801007cd:	8b 45 08             	mov    0x8(%ebp),%eax
801007d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801007d3:	85 c0                	test   %eax,%eax
801007d5:	0f 84 5a 01 00 00    	je     80100935 <cprintf+0x185>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801007db:	0f b6 00             	movzbl (%eax),%eax
801007de:	85 c0                	test   %eax,%eax
801007e0:	74 36                	je     80100818 <cprintf+0x68>
  argp = (uint*)(void*)(&fmt + 1);
801007e2:	8d 5d 0c             	lea    0xc(%ebp),%ebx
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801007e5:	31 f6                	xor    %esi,%esi
    if(c != '%'){
801007e7:	83 f8 25             	cmp    $0x25,%eax
801007ea:	74 44                	je     80100830 <cprintf+0x80>
  if(panicked){
801007ec:	8b 0d 58 b5 10 80    	mov    0x8010b558,%ecx
801007f2:	85 c9                	test   %ecx,%ecx
801007f4:	74 0f                	je     80100805 <cprintf+0x55>
801007f6:	fa                   	cli    
    for(;;)
801007f7:	eb fe                	jmp    801007f7 <cprintf+0x47>
801007f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100800:	b8 25 00 00 00       	mov    $0x25,%eax
80100805:	e8 06 fd ff ff       	call   80100510 <consputc.part.0>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010080a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010080d:	83 c6 01             	add    $0x1,%esi
80100810:	0f b6 04 30          	movzbl (%eax,%esi,1),%eax
80100814:	85 c0                	test   %eax,%eax
80100816:	75 cf                	jne    801007e7 <cprintf+0x37>
  if(locking)
80100818:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010081b:	85 c0                	test   %eax,%eax
8010081d:	0f 85 fd 00 00 00    	jne    80100920 <cprintf+0x170>
}
80100823:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100826:	5b                   	pop    %ebx
80100827:	5e                   	pop    %esi
80100828:	5f                   	pop    %edi
80100829:	5d                   	pop    %ebp
8010082a:	c3                   	ret    
8010082b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010082f:	90                   	nop
    c = fmt[++i] & 0xff;
80100830:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100833:	83 c6 01             	add    $0x1,%esi
80100836:	0f b6 3c 30          	movzbl (%eax,%esi,1),%edi
    if(c == 0)
8010083a:	85 ff                	test   %edi,%edi
8010083c:	74 da                	je     80100818 <cprintf+0x68>
    switch(c){
8010083e:	83 ff 70             	cmp    $0x70,%edi
80100841:	74 5a                	je     8010089d <cprintf+0xed>
80100843:	7f 2a                	jg     8010086f <cprintf+0xbf>
80100845:	83 ff 25             	cmp    $0x25,%edi
80100848:	0f 84 92 00 00 00    	je     801008e0 <cprintf+0x130>
8010084e:	83 ff 64             	cmp    $0x64,%edi
80100851:	0f 85 a1 00 00 00    	jne    801008f8 <cprintf+0x148>
      printint(*argp++, 10, 1);
80100857:	8b 03                	mov    (%ebx),%eax
80100859:	8d 7b 04             	lea    0x4(%ebx),%edi
8010085c:	b9 01 00 00 00       	mov    $0x1,%ecx
80100861:	ba 0a 00 00 00       	mov    $0xa,%edx
80100866:	89 fb                	mov    %edi,%ebx
80100868:	e8 33 fe ff ff       	call   801006a0 <printint>
      break;
8010086d:	eb 9b                	jmp    8010080a <cprintf+0x5a>
    switch(c){
8010086f:	83 ff 73             	cmp    $0x73,%edi
80100872:	75 24                	jne    80100898 <cprintf+0xe8>
      if((s = (char*)*argp++) == 0)
80100874:	8d 7b 04             	lea    0x4(%ebx),%edi
80100877:	8b 1b                	mov    (%ebx),%ebx
80100879:	85 db                	test   %ebx,%ebx
8010087b:	75 55                	jne    801008d2 <cprintf+0x122>
        s = "(null)";
8010087d:	bb b8 77 10 80       	mov    $0x801077b8,%ebx
      for(; *s; s++)
80100882:	b8 28 00 00 00       	mov    $0x28,%eax
  if(panicked){
80100887:	8b 15 58 b5 10 80    	mov    0x8010b558,%edx
8010088d:	85 d2                	test   %edx,%edx
8010088f:	74 39                	je     801008ca <cprintf+0x11a>
80100891:	fa                   	cli    
    for(;;)
80100892:	eb fe                	jmp    80100892 <cprintf+0xe2>
80100894:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    switch(c){
80100898:	83 ff 78             	cmp    $0x78,%edi
8010089b:	75 5b                	jne    801008f8 <cprintf+0x148>
      printint(*argp++, 16, 0);
8010089d:	8b 03                	mov    (%ebx),%eax
8010089f:	8d 7b 04             	lea    0x4(%ebx),%edi
801008a2:	31 c9                	xor    %ecx,%ecx
801008a4:	ba 10 00 00 00       	mov    $0x10,%edx
801008a9:	89 fb                	mov    %edi,%ebx
801008ab:	e8 f0 fd ff ff       	call   801006a0 <printint>
      break;
801008b0:	e9 55 ff ff ff       	jmp    8010080a <cprintf+0x5a>
    acquire(&cons.lock);
801008b5:	83 ec 0c             	sub    $0xc,%esp
801008b8:	68 20 b5 10 80       	push   $0x8010b520
801008bd:	e8 9e 42 00 00       	call   80104b60 <acquire>
801008c2:	83 c4 10             	add    $0x10,%esp
801008c5:	e9 03 ff ff ff       	jmp    801007cd <cprintf+0x1d>
801008ca:	e8 41 fc ff ff       	call   80100510 <consputc.part.0>
      for(; *s; s++)
801008cf:	83 c3 01             	add    $0x1,%ebx
801008d2:	0f be 03             	movsbl (%ebx),%eax
801008d5:	84 c0                	test   %al,%al
801008d7:	75 ae                	jne    80100887 <cprintf+0xd7>
      if((s = (char*)*argp++) == 0)
801008d9:	89 fb                	mov    %edi,%ebx
801008db:	e9 2a ff ff ff       	jmp    8010080a <cprintf+0x5a>
  if(panicked){
801008e0:	8b 3d 58 b5 10 80    	mov    0x8010b558,%edi
801008e6:	85 ff                	test   %edi,%edi
801008e8:	0f 84 12 ff ff ff    	je     80100800 <cprintf+0x50>
801008ee:	fa                   	cli    
    for(;;)
801008ef:	eb fe                	jmp    801008ef <cprintf+0x13f>
801008f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(panicked){
801008f8:	8b 0d 58 b5 10 80    	mov    0x8010b558,%ecx
801008fe:	85 c9                	test   %ecx,%ecx
80100900:	74 06                	je     80100908 <cprintf+0x158>
80100902:	fa                   	cli    
    for(;;)
80100903:	eb fe                	jmp    80100903 <cprintf+0x153>
80100905:	8d 76 00             	lea    0x0(%esi),%esi
80100908:	b8 25 00 00 00       	mov    $0x25,%eax
8010090d:	e8 fe fb ff ff       	call   80100510 <consputc.part.0>
  if(panicked){
80100912:	8b 15 58 b5 10 80    	mov    0x8010b558,%edx
80100918:	85 d2                	test   %edx,%edx
8010091a:	74 2c                	je     80100948 <cprintf+0x198>
8010091c:	fa                   	cli    
    for(;;)
8010091d:	eb fe                	jmp    8010091d <cprintf+0x16d>
8010091f:	90                   	nop
    release(&cons.lock);
80100920:	83 ec 0c             	sub    $0xc,%esp
80100923:	68 20 b5 10 80       	push   $0x8010b520
80100928:	e8 f3 42 00 00       	call   80104c20 <release>
8010092d:	83 c4 10             	add    $0x10,%esp
}
80100930:	e9 ee fe ff ff       	jmp    80100823 <cprintf+0x73>
    panic("null fmt");
80100935:	83 ec 0c             	sub    $0xc,%esp
80100938:	68 bf 77 10 80       	push   $0x801077bf
8010093d:	e8 4e fb ff ff       	call   80100490 <panic>
80100942:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80100948:	89 f8                	mov    %edi,%eax
8010094a:	e8 c1 fb ff ff       	call   80100510 <consputc.part.0>
8010094f:	e9 b6 fe ff ff       	jmp    8010080a <cprintf+0x5a>
80100954:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010095b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010095f:	90                   	nop

80100960 <consoleintr>:
{
80100960:	f3 0f 1e fb          	endbr32 
80100964:	55                   	push   %ebp
80100965:	89 e5                	mov    %esp,%ebp
80100967:	57                   	push   %edi
80100968:	56                   	push   %esi
  int c, doprocdump = 0;
80100969:	31 f6                	xor    %esi,%esi
{
8010096b:	53                   	push   %ebx
8010096c:	83 ec 18             	sub    $0x18,%esp
8010096f:	8b 7d 08             	mov    0x8(%ebp),%edi
  acquire(&cons.lock);
80100972:	68 20 b5 10 80       	push   $0x8010b520
80100977:	e8 e4 41 00 00       	call   80104b60 <acquire>
  while((c = getc()) >= 0){
8010097c:	83 c4 10             	add    $0x10,%esp
8010097f:	eb 17                	jmp    80100998 <consoleintr+0x38>
    switch(c){
80100981:	83 fb 08             	cmp    $0x8,%ebx
80100984:	0f 84 f6 00 00 00    	je     80100a80 <consoleintr+0x120>
8010098a:	83 fb 10             	cmp    $0x10,%ebx
8010098d:	0f 85 15 01 00 00    	jne    80100aa8 <consoleintr+0x148>
80100993:	be 01 00 00 00       	mov    $0x1,%esi
  while((c = getc()) >= 0){
80100998:	ff d7                	call   *%edi
8010099a:	89 c3                	mov    %eax,%ebx
8010099c:	85 c0                	test   %eax,%eax
8010099e:	0f 88 23 01 00 00    	js     80100ac7 <consoleintr+0x167>
    switch(c){
801009a4:	83 fb 15             	cmp    $0x15,%ebx
801009a7:	74 77                	je     80100a20 <consoleintr+0xc0>
801009a9:	7e d6                	jle    80100981 <consoleintr+0x21>
801009ab:	83 fb 7f             	cmp    $0x7f,%ebx
801009ae:	0f 84 cc 00 00 00    	je     80100a80 <consoleintr+0x120>
      if(c != 0 && input.e-input.r < INPUT_BUF){
801009b4:	a1 a8 0f 11 80       	mov    0x80110fa8,%eax
801009b9:	89 c2                	mov    %eax,%edx
801009bb:	2b 15 a0 0f 11 80    	sub    0x80110fa0,%edx
801009c1:	83 fa 7f             	cmp    $0x7f,%edx
801009c4:	77 d2                	ja     80100998 <consoleintr+0x38>
        c = (c == '\r') ? '\n' : c;
801009c6:	8d 48 01             	lea    0x1(%eax),%ecx
801009c9:	8b 15 58 b5 10 80    	mov    0x8010b558,%edx
801009cf:	83 e0 7f             	and    $0x7f,%eax
        input.buf[input.e++ % INPUT_BUF] = c;
801009d2:	89 0d a8 0f 11 80    	mov    %ecx,0x80110fa8
        c = (c == '\r') ? '\n' : c;
801009d8:	83 fb 0d             	cmp    $0xd,%ebx
801009db:	0f 84 02 01 00 00    	je     80100ae3 <consoleintr+0x183>
        input.buf[input.e++ % INPUT_BUF] = c;
801009e1:	88 98 20 0f 11 80    	mov    %bl,-0x7feef0e0(%eax)
  if(panicked){
801009e7:	85 d2                	test   %edx,%edx
801009e9:	0f 85 ff 00 00 00    	jne    80100aee <consoleintr+0x18e>
801009ef:	89 d8                	mov    %ebx,%eax
801009f1:	e8 1a fb ff ff       	call   80100510 <consputc.part.0>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801009f6:	83 fb 0a             	cmp    $0xa,%ebx
801009f9:	0f 84 0f 01 00 00    	je     80100b0e <consoleintr+0x1ae>
801009ff:	83 fb 04             	cmp    $0x4,%ebx
80100a02:	0f 84 06 01 00 00    	je     80100b0e <consoleintr+0x1ae>
80100a08:	a1 a0 0f 11 80       	mov    0x80110fa0,%eax
80100a0d:	83 e8 80             	sub    $0xffffff80,%eax
80100a10:	39 05 a8 0f 11 80    	cmp    %eax,0x80110fa8
80100a16:	75 80                	jne    80100998 <consoleintr+0x38>
80100a18:	e9 f6 00 00 00       	jmp    80100b13 <consoleintr+0x1b3>
80100a1d:	8d 76 00             	lea    0x0(%esi),%esi
      while(input.e != input.w &&
80100a20:	a1 a8 0f 11 80       	mov    0x80110fa8,%eax
80100a25:	39 05 a4 0f 11 80    	cmp    %eax,0x80110fa4
80100a2b:	0f 84 67 ff ff ff    	je     80100998 <consoleintr+0x38>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100a31:	83 e8 01             	sub    $0x1,%eax
80100a34:	89 c2                	mov    %eax,%edx
80100a36:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
80100a39:	80 ba 20 0f 11 80 0a 	cmpb   $0xa,-0x7feef0e0(%edx)
80100a40:	0f 84 52 ff ff ff    	je     80100998 <consoleintr+0x38>
  if(panicked){
80100a46:	8b 15 58 b5 10 80    	mov    0x8010b558,%edx
        input.e--;
80100a4c:	a3 a8 0f 11 80       	mov    %eax,0x80110fa8
  if(panicked){
80100a51:	85 d2                	test   %edx,%edx
80100a53:	74 0b                	je     80100a60 <consoleintr+0x100>
80100a55:	fa                   	cli    
    for(;;)
80100a56:	eb fe                	jmp    80100a56 <consoleintr+0xf6>
80100a58:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100a5f:	90                   	nop
80100a60:	b8 00 01 00 00       	mov    $0x100,%eax
80100a65:	e8 a6 fa ff ff       	call   80100510 <consputc.part.0>
      while(input.e != input.w &&
80100a6a:	a1 a8 0f 11 80       	mov    0x80110fa8,%eax
80100a6f:	3b 05 a4 0f 11 80    	cmp    0x80110fa4,%eax
80100a75:	75 ba                	jne    80100a31 <consoleintr+0xd1>
80100a77:	e9 1c ff ff ff       	jmp    80100998 <consoleintr+0x38>
80100a7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      if(input.e != input.w){
80100a80:	a1 a8 0f 11 80       	mov    0x80110fa8,%eax
80100a85:	3b 05 a4 0f 11 80    	cmp    0x80110fa4,%eax
80100a8b:	0f 84 07 ff ff ff    	je     80100998 <consoleintr+0x38>
        input.e--;
80100a91:	83 e8 01             	sub    $0x1,%eax
80100a94:	a3 a8 0f 11 80       	mov    %eax,0x80110fa8
  if(panicked){
80100a99:	a1 58 b5 10 80       	mov    0x8010b558,%eax
80100a9e:	85 c0                	test   %eax,%eax
80100aa0:	74 16                	je     80100ab8 <consoleintr+0x158>
80100aa2:	fa                   	cli    
    for(;;)
80100aa3:	eb fe                	jmp    80100aa3 <consoleintr+0x143>
80100aa5:	8d 76 00             	lea    0x0(%esi),%esi
      if(c != 0 && input.e-input.r < INPUT_BUF){
80100aa8:	85 db                	test   %ebx,%ebx
80100aaa:	0f 84 e8 fe ff ff    	je     80100998 <consoleintr+0x38>
80100ab0:	e9 ff fe ff ff       	jmp    801009b4 <consoleintr+0x54>
80100ab5:	8d 76 00             	lea    0x0(%esi),%esi
80100ab8:	b8 00 01 00 00       	mov    $0x100,%eax
80100abd:	e8 4e fa ff ff       	call   80100510 <consputc.part.0>
80100ac2:	e9 d1 fe ff ff       	jmp    80100998 <consoleintr+0x38>
  release(&cons.lock);
80100ac7:	83 ec 0c             	sub    $0xc,%esp
80100aca:	68 20 b5 10 80       	push   $0x8010b520
80100acf:	e8 4c 41 00 00       	call   80104c20 <release>
  if(doprocdump) {
80100ad4:	83 c4 10             	add    $0x10,%esp
80100ad7:	85 f6                	test   %esi,%esi
80100ad9:	75 1d                	jne    80100af8 <consoleintr+0x198>
}
80100adb:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100ade:	5b                   	pop    %ebx
80100adf:	5e                   	pop    %esi
80100ae0:	5f                   	pop    %edi
80100ae1:	5d                   	pop    %ebp
80100ae2:	c3                   	ret    
        input.buf[input.e++ % INPUT_BUF] = c;
80100ae3:	c6 80 20 0f 11 80 0a 	movb   $0xa,-0x7feef0e0(%eax)
  if(panicked){
80100aea:	85 d2                	test   %edx,%edx
80100aec:	74 16                	je     80100b04 <consoleintr+0x1a4>
80100aee:	fa                   	cli    
    for(;;)
80100aef:	eb fe                	jmp    80100aef <consoleintr+0x18f>
80100af1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
}
80100af8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100afb:	5b                   	pop    %ebx
80100afc:	5e                   	pop    %esi
80100afd:	5f                   	pop    %edi
80100afe:	5d                   	pop    %ebp
    procdump();  // now call procdump() wo. cons.lock held
80100aff:	e9 7c 3c 00 00       	jmp    80104780 <procdump>
80100b04:	b8 0a 00 00 00       	mov    $0xa,%eax
80100b09:	e8 02 fa ff ff       	call   80100510 <consputc.part.0>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100b0e:	a1 a8 0f 11 80       	mov    0x80110fa8,%eax
          wakeup(&input.r);
80100b13:	83 ec 0c             	sub    $0xc,%esp
          input.w = input.e;
80100b16:	a3 a4 0f 11 80       	mov    %eax,0x80110fa4
          wakeup(&input.r);
80100b1b:	68 a0 0f 11 80       	push   $0x80110fa0
80100b20:	e8 6b 3b 00 00       	call   80104690 <wakeup>
80100b25:	83 c4 10             	add    $0x10,%esp
80100b28:	e9 6b fe ff ff       	jmp    80100998 <consoleintr+0x38>
80100b2d:	8d 76 00             	lea    0x0(%esi),%esi

80100b30 <consoleinit>:

void
consoleinit(void)
{
80100b30:	f3 0f 1e fb          	endbr32 
80100b34:	55                   	push   %ebp
80100b35:	89 e5                	mov    %esp,%ebp
80100b37:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
80100b3a:	68 c8 77 10 80       	push   $0x801077c8
80100b3f:	68 20 b5 10 80       	push   $0x8010b520
80100b44:	e8 97 3e 00 00       	call   801049e0 <initlock>

  devsw[CONSOLE].write = consolewrite;
  devsw[CONSOLE].read = consoleread;
  cons.locking = 1;

  ioapicenable(IRQ_KBD, 0);
80100b49:	58                   	pop    %eax
80100b4a:	5a                   	pop    %edx
80100b4b:	6a 00                	push   $0x0
80100b4d:	6a 01                	push   $0x1
  devsw[CONSOLE].write = consolewrite;
80100b4f:	c7 05 6c 19 11 80 40 	movl   $0x80100740,0x8011196c
80100b56:	07 10 80 
  devsw[CONSOLE].read = consoleread;
80100b59:	c7 05 68 19 11 80 90 	movl   $0x80100390,0x80111968
80100b60:	03 10 80 
  cons.locking = 1;
80100b63:	c7 05 54 b5 10 80 01 	movl   $0x1,0x8010b554
80100b6a:	00 00 00 
  ioapicenable(IRQ_KBD, 0);
80100b6d:	e8 be 19 00 00       	call   80102530 <ioapicenable>
}
80100b72:	83 c4 10             	add    $0x10,%esp
80100b75:	c9                   	leave  
80100b76:	c3                   	ret    
80100b77:	66 90                	xchg   %ax,%ax
80100b79:	66 90                	xchg   %ax,%ax
80100b7b:	66 90                	xchg   %ax,%ax
80100b7d:	66 90                	xchg   %ax,%ax
80100b7f:	90                   	nop

80100b80 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b80:	f3 0f 1e fb          	endbr32 
80100b84:	55                   	push   %ebp
80100b85:	89 e5                	mov    %esp,%ebp
80100b87:	57                   	push   %edi
80100b88:	56                   	push   %esi
80100b89:	53                   	push   %ebx
80100b8a:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100b90:	e8 0b 33 00 00       	call   80103ea0 <myproc>
80100b95:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
80100b9b:	e8 a0 23 00 00       	call   80102f40 <begin_op>

  if((ip = namei(path)) == 0){
80100ba0:	83 ec 0c             	sub    $0xc,%esp
80100ba3:	ff 75 08             	pushl  0x8(%ebp)
80100ba6:	e8 85 15 00 00       	call   80102130 <namei>
80100bab:	83 c4 10             	add    $0x10,%esp
80100bae:	85 c0                	test   %eax,%eax
80100bb0:	0f 84 fe 02 00 00    	je     80100eb4 <exec+0x334>
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
80100bb6:	83 ec 0c             	sub    $0xc,%esp
80100bb9:	89 c3                	mov    %eax,%ebx
80100bbb:	50                   	push   %eax
80100bbc:	e8 9f 0c 00 00       	call   80101860 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100bc1:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100bc7:	6a 34                	push   $0x34
80100bc9:	6a 00                	push   $0x0
80100bcb:	50                   	push   %eax
80100bcc:	53                   	push   %ebx
80100bcd:	e8 8e 0f 00 00       	call   80101b60 <readi>
80100bd2:	83 c4 20             	add    $0x20,%esp
80100bd5:	83 f8 34             	cmp    $0x34,%eax
80100bd8:	74 26                	je     80100c00 <exec+0x80>

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
    iunlockput(ip);
80100bda:	83 ec 0c             	sub    $0xc,%esp
80100bdd:	53                   	push   %ebx
80100bde:	e8 1d 0f 00 00       	call   80101b00 <iunlockput>
    end_op();
80100be3:	e8 c8 23 00 00       	call   80102fb0 <end_op>
80100be8:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
80100beb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100bf0:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100bf3:	5b                   	pop    %ebx
80100bf4:	5e                   	pop    %esi
80100bf5:	5f                   	pop    %edi
80100bf6:	5d                   	pop    %ebp
80100bf7:	c3                   	ret    
80100bf8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100bff:	90                   	nop
  if(elf.magic != ELF_MAGIC)
80100c00:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
80100c07:	45 4c 46 
80100c0a:	75 ce                	jne    80100bda <exec+0x5a>
  if((pgdir = setupkvm()) == 0)
80100c0c:	e8 af 68 00 00       	call   801074c0 <setupkvm>
80100c11:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
80100c17:	85 c0                	test   %eax,%eax
80100c19:	74 bf                	je     80100bda <exec+0x5a>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c1b:	66 83 bd 50 ff ff ff 	cmpw   $0x0,-0xb0(%ebp)
80100c22:	00 
80100c23:	8b b5 40 ff ff ff    	mov    -0xc0(%ebp),%esi
80100c29:	0f 84 a4 02 00 00    	je     80100ed3 <exec+0x353>
  sz = 0;
80100c2f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
80100c36:	00 00 00 
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c39:	31 ff                	xor    %edi,%edi
80100c3b:	e9 86 00 00 00       	jmp    80100cc6 <exec+0x146>
    if(ph.type != ELF_PROG_LOAD)
80100c40:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
80100c47:	75 6c                	jne    80100cb5 <exec+0x135>
    if(ph.memsz < ph.filesz)
80100c49:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
80100c4f:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
80100c55:	0f 82 87 00 00 00    	jb     80100ce2 <exec+0x162>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100c5b:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
80100c61:	72 7f                	jb     80100ce2 <exec+0x162>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c63:	83 ec 04             	sub    $0x4,%esp
80100c66:	50                   	push   %eax
80100c67:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
80100c6d:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
80100c73:	e8 58 66 00 00       	call   801072d0 <allocuvm>
80100c78:	83 c4 10             	add    $0x10,%esp
80100c7b:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100c81:	85 c0                	test   %eax,%eax
80100c83:	74 5d                	je     80100ce2 <exec+0x162>
    if(ph.vaddr % PGSIZE != 0)
80100c85:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100c8b:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100c90:	75 50                	jne    80100ce2 <exec+0x162>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c92:	83 ec 0c             	sub    $0xc,%esp
80100c95:	ff b5 14 ff ff ff    	pushl  -0xec(%ebp)
80100c9b:	ff b5 08 ff ff ff    	pushl  -0xf8(%ebp)
80100ca1:	53                   	push   %ebx
80100ca2:	50                   	push   %eax
80100ca3:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
80100ca9:	e8 52 65 00 00       	call   80107200 <loaduvm>
80100cae:	83 c4 20             	add    $0x20,%esp
80100cb1:	85 c0                	test   %eax,%eax
80100cb3:	78 2d                	js     80100ce2 <exec+0x162>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100cb5:	0f b7 85 50 ff ff ff 	movzwl -0xb0(%ebp),%eax
80100cbc:	83 c7 01             	add    $0x1,%edi
80100cbf:	83 c6 20             	add    $0x20,%esi
80100cc2:	39 f8                	cmp    %edi,%eax
80100cc4:	7e 3a                	jle    80100d00 <exec+0x180>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100cc6:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100ccc:	6a 20                	push   $0x20
80100cce:	56                   	push   %esi
80100ccf:	50                   	push   %eax
80100cd0:	53                   	push   %ebx
80100cd1:	e8 8a 0e 00 00       	call   80101b60 <readi>
80100cd6:	83 c4 10             	add    $0x10,%esp
80100cd9:	83 f8 20             	cmp    $0x20,%eax
80100cdc:	0f 84 5e ff ff ff    	je     80100c40 <exec+0xc0>
    freevm(pgdir);
80100ce2:	83 ec 0c             	sub    $0xc,%esp
80100ce5:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
80100ceb:	e8 50 67 00 00       	call   80107440 <freevm>
  if(ip){
80100cf0:	83 c4 10             	add    $0x10,%esp
80100cf3:	e9 e2 fe ff ff       	jmp    80100bda <exec+0x5a>
80100cf8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100cff:	90                   	nop
80100d00:	8b bd f0 fe ff ff    	mov    -0x110(%ebp),%edi
80100d06:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
80100d0c:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
80100d12:	8d b7 00 20 00 00    	lea    0x2000(%edi),%esi
  iunlockput(ip);
80100d18:	83 ec 0c             	sub    $0xc,%esp
80100d1b:	53                   	push   %ebx
80100d1c:	e8 df 0d 00 00       	call   80101b00 <iunlockput>
  end_op();
80100d21:	e8 8a 22 00 00       	call   80102fb0 <end_op>
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100d26:	83 c4 0c             	add    $0xc,%esp
80100d29:	56                   	push   %esi
80100d2a:	57                   	push   %edi
80100d2b:	8b bd f4 fe ff ff    	mov    -0x10c(%ebp),%edi
80100d31:	57                   	push   %edi
80100d32:	e8 99 65 00 00       	call   801072d0 <allocuvm>
80100d37:	83 c4 10             	add    $0x10,%esp
80100d3a:	89 c6                	mov    %eax,%esi
80100d3c:	85 c0                	test   %eax,%eax
80100d3e:	0f 84 94 00 00 00    	je     80100dd8 <exec+0x258>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d44:	83 ec 08             	sub    $0x8,%esp
80100d47:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
  for(argc = 0; argv[argc]; argc++) {
80100d4d:	89 f3                	mov    %esi,%ebx
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d4f:	50                   	push   %eax
80100d50:	57                   	push   %edi
  for(argc = 0; argv[argc]; argc++) {
80100d51:	31 ff                	xor    %edi,%edi
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d53:	e8 08 68 00 00       	call   80107560 <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100d58:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d5b:	83 c4 10             	add    $0x10,%esp
80100d5e:	8d 95 58 ff ff ff    	lea    -0xa8(%ebp),%edx
80100d64:	8b 00                	mov    (%eax),%eax
80100d66:	85 c0                	test   %eax,%eax
80100d68:	0f 84 8b 00 00 00    	je     80100df9 <exec+0x279>
80100d6e:	89 b5 f0 fe ff ff    	mov    %esi,-0x110(%ebp)
80100d74:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
80100d7a:	eb 23                	jmp    80100d9f <exec+0x21f>
80100d7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100d80:	8b 45 0c             	mov    0xc(%ebp),%eax
    ustack[3+argc] = sp;
80100d83:	89 9c bd 64 ff ff ff 	mov    %ebx,-0x9c(%ebp,%edi,4)
  for(argc = 0; argv[argc]; argc++) {
80100d8a:	83 c7 01             	add    $0x1,%edi
    ustack[3+argc] = sp;
80100d8d:	8d 95 58 ff ff ff    	lea    -0xa8(%ebp),%edx
  for(argc = 0; argv[argc]; argc++) {
80100d93:	8b 04 b8             	mov    (%eax,%edi,4),%eax
80100d96:	85 c0                	test   %eax,%eax
80100d98:	74 59                	je     80100df3 <exec+0x273>
    if(argc >= MAXARG)
80100d9a:	83 ff 20             	cmp    $0x20,%edi
80100d9d:	74 39                	je     80100dd8 <exec+0x258>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d9f:	83 ec 0c             	sub    $0xc,%esp
80100da2:	50                   	push   %eax
80100da3:	e8 c8 40 00 00       	call   80104e70 <strlen>
80100da8:	f7 d0                	not    %eax
80100daa:	01 c3                	add    %eax,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100dac:	58                   	pop    %eax
80100dad:	8b 45 0c             	mov    0xc(%ebp),%eax
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100db0:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100db3:	ff 34 b8             	pushl  (%eax,%edi,4)
80100db6:	e8 b5 40 00 00       	call   80104e70 <strlen>
80100dbb:	83 c0 01             	add    $0x1,%eax
80100dbe:	50                   	push   %eax
80100dbf:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dc2:	ff 34 b8             	pushl  (%eax,%edi,4)
80100dc5:	53                   	push   %ebx
80100dc6:	56                   	push   %esi
80100dc7:	e8 f4 68 00 00       	call   801076c0 <copyout>
80100dcc:	83 c4 20             	add    $0x20,%esp
80100dcf:	85 c0                	test   %eax,%eax
80100dd1:	79 ad                	jns    80100d80 <exec+0x200>
80100dd3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100dd7:	90                   	nop
    freevm(pgdir);
80100dd8:	83 ec 0c             	sub    $0xc,%esp
80100ddb:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
80100de1:	e8 5a 66 00 00       	call   80107440 <freevm>
80100de6:	83 c4 10             	add    $0x10,%esp
  return -1;
80100de9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100dee:	e9 fd fd ff ff       	jmp    80100bf0 <exec+0x70>
80100df3:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100df9:	8d 04 bd 04 00 00 00 	lea    0x4(,%edi,4),%eax
80100e00:	89 d9                	mov    %ebx,%ecx
  ustack[3+argc] = 0;
80100e02:	c7 84 bd 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%edi,4)
80100e09:	00 00 00 00 
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e0d:	29 c1                	sub    %eax,%ecx
  sp -= (3+argc+1) * 4;
80100e0f:	83 c0 0c             	add    $0xc,%eax
  ustack[1] = argc;
80100e12:	89 bd 5c ff ff ff    	mov    %edi,-0xa4(%ebp)
  sp -= (3+argc+1) * 4;
80100e18:	29 c3                	sub    %eax,%ebx
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e1a:	50                   	push   %eax
80100e1b:	52                   	push   %edx
80100e1c:	53                   	push   %ebx
80100e1d:	ff b5 f4 fe ff ff    	pushl  -0x10c(%ebp)
  ustack[0] = 0xffffffff;  // fake return PC
80100e23:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100e2a:	ff ff ff 
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e2d:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e33:	e8 88 68 00 00       	call   801076c0 <copyout>
80100e38:	83 c4 10             	add    $0x10,%esp
80100e3b:	85 c0                	test   %eax,%eax
80100e3d:	78 99                	js     80100dd8 <exec+0x258>
  for(last=s=path; *s; s++)
80100e3f:	8b 45 08             	mov    0x8(%ebp),%eax
80100e42:	8b 55 08             	mov    0x8(%ebp),%edx
80100e45:	0f b6 00             	movzbl (%eax),%eax
80100e48:	84 c0                	test   %al,%al
80100e4a:	74 13                	je     80100e5f <exec+0x2df>
80100e4c:	89 d1                	mov    %edx,%ecx
80100e4e:	66 90                	xchg   %ax,%ax
    if(*s == '/')
80100e50:	83 c1 01             	add    $0x1,%ecx
80100e53:	3c 2f                	cmp    $0x2f,%al
  for(last=s=path; *s; s++)
80100e55:	0f b6 01             	movzbl (%ecx),%eax
    if(*s == '/')
80100e58:	0f 44 d1             	cmove  %ecx,%edx
  for(last=s=path; *s; s++)
80100e5b:	84 c0                	test   %al,%al
80100e5d:	75 f1                	jne    80100e50 <exec+0x2d0>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100e5f:	8b bd ec fe ff ff    	mov    -0x114(%ebp),%edi
80100e65:	83 ec 04             	sub    $0x4,%esp
80100e68:	6a 10                	push   $0x10
80100e6a:	89 f8                	mov    %edi,%eax
80100e6c:	52                   	push   %edx
80100e6d:	83 c0 70             	add    $0x70,%eax
80100e70:	50                   	push   %eax
80100e71:	e8 ba 3f 00 00       	call   80104e30 <safestrcpy>
  curproc->pgdir = pgdir;
80100e76:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
  oldpgdir = curproc->pgdir;
80100e7c:	89 f8                	mov    %edi,%eax
80100e7e:	8b 7f 08             	mov    0x8(%edi),%edi
  curproc->sz = sz;
80100e81:	89 30                	mov    %esi,(%eax)
  curproc->pgdir = pgdir;
80100e83:	89 48 08             	mov    %ecx,0x8(%eax)
  curproc->tf->eip = elf.entry;  // main
80100e86:	89 c1                	mov    %eax,%ecx
80100e88:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100e8e:	8b 40 1c             	mov    0x1c(%eax),%eax
80100e91:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100e94:	8b 41 1c             	mov    0x1c(%ecx),%eax
80100e97:	89 58 44             	mov    %ebx,0x44(%eax)
  switchuvm(curproc);
80100e9a:	89 0c 24             	mov    %ecx,(%esp)
80100e9d:	e8 ce 61 00 00       	call   80107070 <switchuvm>
  freevm(oldpgdir);
80100ea2:	89 3c 24             	mov    %edi,(%esp)
80100ea5:	e8 96 65 00 00       	call   80107440 <freevm>
  return 0;
80100eaa:	83 c4 10             	add    $0x10,%esp
80100ead:	31 c0                	xor    %eax,%eax
80100eaf:	e9 3c fd ff ff       	jmp    80100bf0 <exec+0x70>
    end_op();
80100eb4:	e8 f7 20 00 00       	call   80102fb0 <end_op>
    cprintf("exec: fail\n");
80100eb9:	83 ec 0c             	sub    $0xc,%esp
80100ebc:	68 e1 77 10 80       	push   $0x801077e1
80100ec1:	e8 ea f8 ff ff       	call   801007b0 <cprintf>
    return -1;
80100ec6:	83 c4 10             	add    $0x10,%esp
80100ec9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100ece:	e9 1d fd ff ff       	jmp    80100bf0 <exec+0x70>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100ed3:	31 ff                	xor    %edi,%edi
80100ed5:	be 00 20 00 00       	mov    $0x2000,%esi
80100eda:	e9 39 fe ff ff       	jmp    80100d18 <exec+0x198>
80100edf:	90                   	nop

80100ee0 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100ee0:	f3 0f 1e fb          	endbr32 
80100ee4:	55                   	push   %ebp
80100ee5:	89 e5                	mov    %esp,%ebp
80100ee7:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100eea:	68 ed 77 10 80       	push   $0x801077ed
80100eef:	68 c0 0f 11 80       	push   $0x80110fc0
80100ef4:	e8 e7 3a 00 00       	call   801049e0 <initlock>
}
80100ef9:	83 c4 10             	add    $0x10,%esp
80100efc:	c9                   	leave  
80100efd:	c3                   	ret    
80100efe:	66 90                	xchg   %ax,%ax

80100f00 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f00:	f3 0f 1e fb          	endbr32 
80100f04:	55                   	push   %ebp
80100f05:	89 e5                	mov    %esp,%ebp
80100f07:	53                   	push   %ebx
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f08:	bb f4 0f 11 80       	mov    $0x80110ff4,%ebx
{
80100f0d:	83 ec 10             	sub    $0x10,%esp
  acquire(&ftable.lock);
80100f10:	68 c0 0f 11 80       	push   $0x80110fc0
80100f15:	e8 46 3c 00 00       	call   80104b60 <acquire>
80100f1a:	83 c4 10             	add    $0x10,%esp
80100f1d:	eb 0c                	jmp    80100f2b <filealloc+0x2b>
80100f1f:	90                   	nop
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f20:	83 c3 18             	add    $0x18,%ebx
80100f23:	81 fb 54 19 11 80    	cmp    $0x80111954,%ebx
80100f29:	74 25                	je     80100f50 <filealloc+0x50>
    if(f->ref == 0){
80100f2b:	8b 43 04             	mov    0x4(%ebx),%eax
80100f2e:	85 c0                	test   %eax,%eax
80100f30:	75 ee                	jne    80100f20 <filealloc+0x20>
      f->ref = 1;
      release(&ftable.lock);
80100f32:	83 ec 0c             	sub    $0xc,%esp
      f->ref = 1;
80100f35:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100f3c:	68 c0 0f 11 80       	push   $0x80110fc0
80100f41:	e8 da 3c 00 00       	call   80104c20 <release>
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}
80100f46:	89 d8                	mov    %ebx,%eax
      return f;
80100f48:	83 c4 10             	add    $0x10,%esp
}
80100f4b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100f4e:	c9                   	leave  
80100f4f:	c3                   	ret    
  release(&ftable.lock);
80100f50:	83 ec 0c             	sub    $0xc,%esp
  return 0;
80100f53:	31 db                	xor    %ebx,%ebx
  release(&ftable.lock);
80100f55:	68 c0 0f 11 80       	push   $0x80110fc0
80100f5a:	e8 c1 3c 00 00       	call   80104c20 <release>
}
80100f5f:	89 d8                	mov    %ebx,%eax
  return 0;
80100f61:	83 c4 10             	add    $0x10,%esp
}
80100f64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100f67:	c9                   	leave  
80100f68:	c3                   	ret    
80100f69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100f70 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100f70:	f3 0f 1e fb          	endbr32 
80100f74:	55                   	push   %ebp
80100f75:	89 e5                	mov    %esp,%ebp
80100f77:	53                   	push   %ebx
80100f78:	83 ec 10             	sub    $0x10,%esp
80100f7b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100f7e:	68 c0 0f 11 80       	push   $0x80110fc0
80100f83:	e8 d8 3b 00 00       	call   80104b60 <acquire>
  if(f->ref < 1)
80100f88:	8b 43 04             	mov    0x4(%ebx),%eax
80100f8b:	83 c4 10             	add    $0x10,%esp
80100f8e:	85 c0                	test   %eax,%eax
80100f90:	7e 1a                	jle    80100fac <filedup+0x3c>
    panic("filedup");
  f->ref++;
80100f92:	83 c0 01             	add    $0x1,%eax
  release(&ftable.lock);
80100f95:	83 ec 0c             	sub    $0xc,%esp
  f->ref++;
80100f98:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100f9b:	68 c0 0f 11 80       	push   $0x80110fc0
80100fa0:	e8 7b 3c 00 00       	call   80104c20 <release>
  return f;
}
80100fa5:	89 d8                	mov    %ebx,%eax
80100fa7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100faa:	c9                   	leave  
80100fab:	c3                   	ret    
    panic("filedup");
80100fac:	83 ec 0c             	sub    $0xc,%esp
80100faf:	68 f4 77 10 80       	push   $0x801077f4
80100fb4:	e8 d7 f4 ff ff       	call   80100490 <panic>
80100fb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100fc0 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100fc0:	f3 0f 1e fb          	endbr32 
80100fc4:	55                   	push   %ebp
80100fc5:	89 e5                	mov    %esp,%ebp
80100fc7:	57                   	push   %edi
80100fc8:	56                   	push   %esi
80100fc9:	53                   	push   %ebx
80100fca:	83 ec 28             	sub    $0x28,%esp
80100fcd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100fd0:	68 c0 0f 11 80       	push   $0x80110fc0
80100fd5:	e8 86 3b 00 00       	call   80104b60 <acquire>
  if(f->ref < 1)
80100fda:	8b 53 04             	mov    0x4(%ebx),%edx
80100fdd:	83 c4 10             	add    $0x10,%esp
80100fe0:	85 d2                	test   %edx,%edx
80100fe2:	0f 8e a1 00 00 00    	jle    80101089 <fileclose+0xc9>
    panic("fileclose");
  if(--f->ref > 0){
80100fe8:	83 ea 01             	sub    $0x1,%edx
80100feb:	89 53 04             	mov    %edx,0x4(%ebx)
80100fee:	75 40                	jne    80101030 <fileclose+0x70>
    release(&ftable.lock);
    return;
  }
  ff = *f;
80100ff0:	0f b6 43 09          	movzbl 0x9(%ebx),%eax
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);
80100ff4:	83 ec 0c             	sub    $0xc,%esp
  ff = *f;
80100ff7:	8b 3b                	mov    (%ebx),%edi
  f->type = FD_NONE;
80100ff9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  ff = *f;
80100fff:	8b 73 0c             	mov    0xc(%ebx),%esi
80101002:	88 45 e7             	mov    %al,-0x19(%ebp)
80101005:	8b 43 10             	mov    0x10(%ebx),%eax
  release(&ftable.lock);
80101008:	68 c0 0f 11 80       	push   $0x80110fc0
  ff = *f;
8010100d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  release(&ftable.lock);
80101010:	e8 0b 3c 00 00       	call   80104c20 <release>

  if(ff.type == FD_PIPE)
80101015:	83 c4 10             	add    $0x10,%esp
80101018:	83 ff 01             	cmp    $0x1,%edi
8010101b:	74 53                	je     80101070 <fileclose+0xb0>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
8010101d:	83 ff 02             	cmp    $0x2,%edi
80101020:	74 26                	je     80101048 <fileclose+0x88>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80101022:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101025:	5b                   	pop    %ebx
80101026:	5e                   	pop    %esi
80101027:	5f                   	pop    %edi
80101028:	5d                   	pop    %ebp
80101029:	c3                   	ret    
8010102a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    release(&ftable.lock);
80101030:	c7 45 08 c0 0f 11 80 	movl   $0x80110fc0,0x8(%ebp)
}
80101037:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010103a:	5b                   	pop    %ebx
8010103b:	5e                   	pop    %esi
8010103c:	5f                   	pop    %edi
8010103d:	5d                   	pop    %ebp
    release(&ftable.lock);
8010103e:	e9 dd 3b 00 00       	jmp    80104c20 <release>
80101043:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101047:	90                   	nop
    begin_op();
80101048:	e8 f3 1e 00 00       	call   80102f40 <begin_op>
    iput(ff.ip);
8010104d:	83 ec 0c             	sub    $0xc,%esp
80101050:	ff 75 e0             	pushl  -0x20(%ebp)
80101053:	e8 38 09 00 00       	call   80101990 <iput>
    end_op();
80101058:	83 c4 10             	add    $0x10,%esp
}
8010105b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010105e:	5b                   	pop    %ebx
8010105f:	5e                   	pop    %esi
80101060:	5f                   	pop    %edi
80101061:	5d                   	pop    %ebp
    end_op();
80101062:	e9 49 1f 00 00       	jmp    80102fb0 <end_op>
80101067:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010106e:	66 90                	xchg   %ax,%ax
    pipeclose(ff.pipe, ff.writable);
80101070:	0f be 5d e7          	movsbl -0x19(%ebp),%ebx
80101074:	83 ec 08             	sub    $0x8,%esp
80101077:	53                   	push   %ebx
80101078:	56                   	push   %esi
80101079:	e8 b2 29 00 00       	call   80103a30 <pipeclose>
8010107e:	83 c4 10             	add    $0x10,%esp
}
80101081:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101084:	5b                   	pop    %ebx
80101085:	5e                   	pop    %esi
80101086:	5f                   	pop    %edi
80101087:	5d                   	pop    %ebp
80101088:	c3                   	ret    
    panic("fileclose");
80101089:	83 ec 0c             	sub    $0xc,%esp
8010108c:	68 fc 77 10 80       	push   $0x801077fc
80101091:	e8 fa f3 ff ff       	call   80100490 <panic>
80101096:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010109d:	8d 76 00             	lea    0x0(%esi),%esi

801010a0 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
801010a0:	f3 0f 1e fb          	endbr32 
801010a4:	55                   	push   %ebp
801010a5:	89 e5                	mov    %esp,%ebp
801010a7:	53                   	push   %ebx
801010a8:	83 ec 04             	sub    $0x4,%esp
801010ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
801010ae:	83 3b 02             	cmpl   $0x2,(%ebx)
801010b1:	75 2d                	jne    801010e0 <filestat+0x40>
    ilock(f->ip);
801010b3:	83 ec 0c             	sub    $0xc,%esp
801010b6:	ff 73 10             	pushl  0x10(%ebx)
801010b9:	e8 a2 07 00 00       	call   80101860 <ilock>
    stati(f->ip, st);
801010be:	58                   	pop    %eax
801010bf:	5a                   	pop    %edx
801010c0:	ff 75 0c             	pushl  0xc(%ebp)
801010c3:	ff 73 10             	pushl  0x10(%ebx)
801010c6:	e8 65 0a 00 00       	call   80101b30 <stati>
    iunlock(f->ip);
801010cb:	59                   	pop    %ecx
801010cc:	ff 73 10             	pushl  0x10(%ebx)
801010cf:	e8 6c 08 00 00       	call   80101940 <iunlock>
    return 0;
  }
  return -1;
}
801010d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return 0;
801010d7:	83 c4 10             	add    $0x10,%esp
801010da:	31 c0                	xor    %eax,%eax
}
801010dc:	c9                   	leave  
801010dd:	c3                   	ret    
801010de:	66 90                	xchg   %ax,%ax
801010e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return -1;
801010e3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801010e8:	c9                   	leave  
801010e9:	c3                   	ret    
801010ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801010f0 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
801010f0:	f3 0f 1e fb          	endbr32 
801010f4:	55                   	push   %ebp
801010f5:	89 e5                	mov    %esp,%ebp
801010f7:	57                   	push   %edi
801010f8:	56                   	push   %esi
801010f9:	53                   	push   %ebx
801010fa:	83 ec 0c             	sub    $0xc,%esp
801010fd:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101100:	8b 75 0c             	mov    0xc(%ebp),%esi
80101103:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
80101106:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
8010110a:	74 64                	je     80101170 <fileread+0x80>
    return -1;
  if(f->type == FD_PIPE)
8010110c:	8b 03                	mov    (%ebx),%eax
8010110e:	83 f8 01             	cmp    $0x1,%eax
80101111:	74 45                	je     80101158 <fileread+0x68>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80101113:	83 f8 02             	cmp    $0x2,%eax
80101116:	75 5f                	jne    80101177 <fileread+0x87>
    ilock(f->ip);
80101118:	83 ec 0c             	sub    $0xc,%esp
8010111b:	ff 73 10             	pushl  0x10(%ebx)
8010111e:	e8 3d 07 00 00       	call   80101860 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80101123:	57                   	push   %edi
80101124:	ff 73 14             	pushl  0x14(%ebx)
80101127:	56                   	push   %esi
80101128:	ff 73 10             	pushl  0x10(%ebx)
8010112b:	e8 30 0a 00 00       	call   80101b60 <readi>
80101130:	83 c4 20             	add    $0x20,%esp
80101133:	89 c6                	mov    %eax,%esi
80101135:	85 c0                	test   %eax,%eax
80101137:	7e 03                	jle    8010113c <fileread+0x4c>
      f->off += r;
80101139:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
8010113c:	83 ec 0c             	sub    $0xc,%esp
8010113f:	ff 73 10             	pushl  0x10(%ebx)
80101142:	e8 f9 07 00 00       	call   80101940 <iunlock>
    return r;
80101147:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
8010114a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010114d:	89 f0                	mov    %esi,%eax
8010114f:	5b                   	pop    %ebx
80101150:	5e                   	pop    %esi
80101151:	5f                   	pop    %edi
80101152:	5d                   	pop    %ebp
80101153:	c3                   	ret    
80101154:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return piperead(f->pipe, addr, n);
80101158:	8b 43 0c             	mov    0xc(%ebx),%eax
8010115b:	89 45 08             	mov    %eax,0x8(%ebp)
}
8010115e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101161:	5b                   	pop    %ebx
80101162:	5e                   	pop    %esi
80101163:	5f                   	pop    %edi
80101164:	5d                   	pop    %ebp
    return piperead(f->pipe, addr, n);
80101165:	e9 66 2a 00 00       	jmp    80103bd0 <piperead>
8010116a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80101170:	be ff ff ff ff       	mov    $0xffffffff,%esi
80101175:	eb d3                	jmp    8010114a <fileread+0x5a>
  panic("fileread");
80101177:	83 ec 0c             	sub    $0xc,%esp
8010117a:	68 06 78 10 80       	push   $0x80107806
8010117f:	e8 0c f3 ff ff       	call   80100490 <panic>
80101184:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010118b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010118f:	90                   	nop

80101190 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80101190:	f3 0f 1e fb          	endbr32 
80101194:	55                   	push   %ebp
80101195:	89 e5                	mov    %esp,%ebp
80101197:	57                   	push   %edi
80101198:	56                   	push   %esi
80101199:	53                   	push   %ebx
8010119a:	83 ec 1c             	sub    $0x1c,%esp
8010119d:	8b 45 0c             	mov    0xc(%ebp),%eax
801011a0:	8b 75 08             	mov    0x8(%ebp),%esi
801011a3:	89 45 dc             	mov    %eax,-0x24(%ebp)
801011a6:	8b 45 10             	mov    0x10(%ebp),%eax
  int r;

  if(f->writable == 0)
801011a9:	80 7e 09 00          	cmpb   $0x0,0x9(%esi)
{
801011ad:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(f->writable == 0)
801011b0:	0f 84 c1 00 00 00    	je     80101277 <filewrite+0xe7>
    return -1;
  if(f->type == FD_PIPE)
801011b6:	8b 06                	mov    (%esi),%eax
801011b8:	83 f8 01             	cmp    $0x1,%eax
801011bb:	0f 84 c3 00 00 00    	je     80101284 <filewrite+0xf4>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
801011c1:	83 f8 02             	cmp    $0x2,%eax
801011c4:	0f 85 cc 00 00 00    	jne    80101296 <filewrite+0x106>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801011ca:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    int i = 0;
801011cd:	31 ff                	xor    %edi,%edi
    while(i < n){
801011cf:	85 c0                	test   %eax,%eax
801011d1:	7f 34                	jg     80101207 <filewrite+0x77>
801011d3:	e9 98 00 00 00       	jmp    80101270 <filewrite+0xe0>
801011d8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801011df:	90                   	nop
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
        f->off += r;
801011e0:	01 46 14             	add    %eax,0x14(%esi)
      iunlock(f->ip);
801011e3:	83 ec 0c             	sub    $0xc,%esp
801011e6:	ff 76 10             	pushl  0x10(%esi)
        f->off += r;
801011e9:	89 45 e0             	mov    %eax,-0x20(%ebp)
      iunlock(f->ip);
801011ec:	e8 4f 07 00 00       	call   80101940 <iunlock>
      end_op();
801011f1:	e8 ba 1d 00 00       	call   80102fb0 <end_op>

      if(r < 0)
        break;
      if(r != n1)
801011f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801011f9:	83 c4 10             	add    $0x10,%esp
801011fc:	39 c3                	cmp    %eax,%ebx
801011fe:	75 60                	jne    80101260 <filewrite+0xd0>
        panic("short filewrite");
      i += r;
80101200:	01 df                	add    %ebx,%edi
    while(i < n){
80101202:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80101205:	7e 69                	jle    80101270 <filewrite+0xe0>
      int n1 = n - i;
80101207:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010120a:	b8 00 06 00 00       	mov    $0x600,%eax
8010120f:	29 fb                	sub    %edi,%ebx
      if(n1 > max)
80101211:	81 fb 00 06 00 00    	cmp    $0x600,%ebx
80101217:	0f 4f d8             	cmovg  %eax,%ebx
      begin_op();
8010121a:	e8 21 1d 00 00       	call   80102f40 <begin_op>
      ilock(f->ip);
8010121f:	83 ec 0c             	sub    $0xc,%esp
80101222:	ff 76 10             	pushl  0x10(%esi)
80101225:	e8 36 06 00 00       	call   80101860 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010122a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010122d:	53                   	push   %ebx
8010122e:	ff 76 14             	pushl  0x14(%esi)
80101231:	01 f8                	add    %edi,%eax
80101233:	50                   	push   %eax
80101234:	ff 76 10             	pushl  0x10(%esi)
80101237:	e8 24 0a 00 00       	call   80101c60 <writei>
8010123c:	83 c4 20             	add    $0x20,%esp
8010123f:	85 c0                	test   %eax,%eax
80101241:	7f 9d                	jg     801011e0 <filewrite+0x50>
      iunlock(f->ip);
80101243:	83 ec 0c             	sub    $0xc,%esp
80101246:	ff 76 10             	pushl  0x10(%esi)
80101249:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010124c:	e8 ef 06 00 00       	call   80101940 <iunlock>
      end_op();
80101251:	e8 5a 1d 00 00       	call   80102fb0 <end_op>
      if(r < 0)
80101256:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101259:	83 c4 10             	add    $0x10,%esp
8010125c:	85 c0                	test   %eax,%eax
8010125e:	75 17                	jne    80101277 <filewrite+0xe7>
        panic("short filewrite");
80101260:	83 ec 0c             	sub    $0xc,%esp
80101263:	68 0f 78 10 80       	push   $0x8010780f
80101268:	e8 23 f2 ff ff       	call   80100490 <panic>
8010126d:	8d 76 00             	lea    0x0(%esi),%esi
    }
    return i == n ? n : -1;
80101270:	89 f8                	mov    %edi,%eax
80101272:	3b 7d e4             	cmp    -0x1c(%ebp),%edi
80101275:	74 05                	je     8010127c <filewrite+0xec>
80101277:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  panic("filewrite");
}
8010127c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010127f:	5b                   	pop    %ebx
80101280:	5e                   	pop    %esi
80101281:	5f                   	pop    %edi
80101282:	5d                   	pop    %ebp
80101283:	c3                   	ret    
    return pipewrite(f->pipe, addr, n);
80101284:	8b 46 0c             	mov    0xc(%esi),%eax
80101287:	89 45 08             	mov    %eax,0x8(%ebp)
}
8010128a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010128d:	5b                   	pop    %ebx
8010128e:	5e                   	pop    %esi
8010128f:	5f                   	pop    %edi
80101290:	5d                   	pop    %ebp
    return pipewrite(f->pipe, addr, n);
80101291:	e9 3a 28 00 00       	jmp    80103ad0 <pipewrite>
  panic("filewrite");
80101296:	83 ec 0c             	sub    $0xc,%esp
80101299:	68 15 78 10 80       	push   $0x80107815
8010129e:	e8 ed f1 ff ff       	call   80100490 <panic>
801012a3:	66 90                	xchg   %ax,%ax
801012a5:	66 90                	xchg   %ax,%ax
801012a7:	66 90                	xchg   %ax,%ax
801012a9:	66 90                	xchg   %ax,%ax
801012ab:	66 90                	xchg   %ax,%ax
801012ad:	66 90                	xchg   %ax,%ax
801012af:	90                   	nop

801012b0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
801012b0:	55                   	push   %ebp
801012b1:	89 c1                	mov    %eax,%ecx
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
801012b3:	89 d0                	mov    %edx,%eax
801012b5:	c1 e8 0c             	shr    $0xc,%eax
801012b8:	03 05 e0 19 11 80    	add    0x801119e0,%eax
{
801012be:	89 e5                	mov    %esp,%ebp
801012c0:	56                   	push   %esi
801012c1:	53                   	push   %ebx
801012c2:	89 d3                	mov    %edx,%ebx
  bp = bread(dev, BBLOCK(b, sb));
801012c4:	83 ec 08             	sub    $0x8,%esp
801012c7:	50                   	push   %eax
801012c8:	51                   	push   %ecx
801012c9:	e8 c2 ee ff ff       	call   80100190 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
801012ce:	89 d9                	mov    %ebx,%ecx
  if((bp->data[bi/8] & m) == 0)
801012d0:	c1 fb 03             	sar    $0x3,%ebx
  m = 1 << (bi % 8);
801012d3:	ba 01 00 00 00       	mov    $0x1,%edx
801012d8:	83 e1 07             	and    $0x7,%ecx
  if((bp->data[bi/8] & m) == 0)
801012db:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
801012e1:	83 c4 10             	add    $0x10,%esp
  m = 1 << (bi % 8);
801012e4:	d3 e2                	shl    %cl,%edx
  if((bp->data[bi/8] & m) == 0)
801012e6:	0f b6 4c 18 5c       	movzbl 0x5c(%eax,%ebx,1),%ecx
801012eb:	85 d1                	test   %edx,%ecx
801012ed:	74 25                	je     80101314 <bfree+0x64>
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
801012ef:	f7 d2                	not    %edx
  log_write(bp);
801012f1:	83 ec 0c             	sub    $0xc,%esp
801012f4:	89 c6                	mov    %eax,%esi
  bp->data[bi/8] &= ~m;
801012f6:	21 ca                	and    %ecx,%edx
801012f8:	88 54 18 5c          	mov    %dl,0x5c(%eax,%ebx,1)
  log_write(bp);
801012fc:	50                   	push   %eax
801012fd:	e8 1e 1e 00 00       	call   80103120 <log_write>
  brelse(bp);
80101302:	89 34 24             	mov    %esi,(%esp)
80101305:	e8 06 ef ff ff       	call   80100210 <brelse>
}
8010130a:	83 c4 10             	add    $0x10,%esp
8010130d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101310:	5b                   	pop    %ebx
80101311:	5e                   	pop    %esi
80101312:	5d                   	pop    %ebp
80101313:	c3                   	ret    
    panic("freeing free block");
80101314:	83 ec 0c             	sub    $0xc,%esp
80101317:	68 1f 78 10 80       	push   $0x8010781f
8010131c:	e8 6f f1 ff ff       	call   80100490 <panic>
80101321:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101328:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010132f:	90                   	nop

80101330 <balloc>:
{
80101330:	55                   	push   %ebp
80101331:	89 e5                	mov    %esp,%ebp
80101333:	57                   	push   %edi
80101334:	56                   	push   %esi
80101335:	53                   	push   %ebx
80101336:	83 ec 1c             	sub    $0x1c,%esp
  for(b = 0; b < sb.size; b += BPB){
80101339:	8b 0d c0 19 11 80    	mov    0x801119c0,%ecx
{
8010133f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101342:	85 c9                	test   %ecx,%ecx
80101344:	0f 84 87 00 00 00    	je     801013d1 <balloc+0xa1>
8010134a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    bp = bread(dev, BBLOCK(b, sb));
80101351:	8b 75 dc             	mov    -0x24(%ebp),%esi
80101354:	83 ec 08             	sub    $0x8,%esp
80101357:	89 f0                	mov    %esi,%eax
80101359:	c1 f8 0c             	sar    $0xc,%eax
8010135c:	03 05 e0 19 11 80    	add    0x801119e0,%eax
80101362:	50                   	push   %eax
80101363:	ff 75 d8             	pushl  -0x28(%ebp)
80101366:	e8 25 ee ff ff       	call   80100190 <bread>
8010136b:	83 c4 10             	add    $0x10,%esp
8010136e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101371:	a1 c0 19 11 80       	mov    0x801119c0,%eax
80101376:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101379:	31 c0                	xor    %eax,%eax
8010137b:	eb 2f                	jmp    801013ac <balloc+0x7c>
8010137d:	8d 76 00             	lea    0x0(%esi),%esi
      m = 1 << (bi % 8);
80101380:	89 c1                	mov    %eax,%ecx
80101382:	bb 01 00 00 00       	mov    $0x1,%ebx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
80101387:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      m = 1 << (bi % 8);
8010138a:	83 e1 07             	and    $0x7,%ecx
8010138d:	d3 e3                	shl    %cl,%ebx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010138f:	89 c1                	mov    %eax,%ecx
80101391:	c1 f9 03             	sar    $0x3,%ecx
80101394:	0f b6 7c 0a 5c       	movzbl 0x5c(%edx,%ecx,1),%edi
80101399:	89 fa                	mov    %edi,%edx
8010139b:	85 df                	test   %ebx,%edi
8010139d:	74 41                	je     801013e0 <balloc+0xb0>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010139f:	83 c0 01             	add    $0x1,%eax
801013a2:	83 c6 01             	add    $0x1,%esi
801013a5:	3d 00 10 00 00       	cmp    $0x1000,%eax
801013aa:	74 05                	je     801013b1 <balloc+0x81>
801013ac:	39 75 e0             	cmp    %esi,-0x20(%ebp)
801013af:	77 cf                	ja     80101380 <balloc+0x50>
    brelse(bp);
801013b1:	83 ec 0c             	sub    $0xc,%esp
801013b4:	ff 75 e4             	pushl  -0x1c(%ebp)
801013b7:	e8 54 ee ff ff       	call   80100210 <brelse>
  for(b = 0; b < sb.size; b += BPB){
801013bc:	81 45 dc 00 10 00 00 	addl   $0x1000,-0x24(%ebp)
801013c3:	83 c4 10             	add    $0x10,%esp
801013c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801013c9:	39 05 c0 19 11 80    	cmp    %eax,0x801119c0
801013cf:	77 80                	ja     80101351 <balloc+0x21>
  panic("balloc: out of blocks");
801013d1:	83 ec 0c             	sub    $0xc,%esp
801013d4:	68 32 78 10 80       	push   $0x80107832
801013d9:	e8 b2 f0 ff ff       	call   80100490 <panic>
801013de:	66 90                	xchg   %ax,%ax
        bp->data[bi/8] |= m;  // Mark block in use.
801013e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
        log_write(bp);
801013e3:	83 ec 0c             	sub    $0xc,%esp
        bp->data[bi/8] |= m;  // Mark block in use.
801013e6:	09 da                	or     %ebx,%edx
801013e8:	88 54 0f 5c          	mov    %dl,0x5c(%edi,%ecx,1)
        log_write(bp);
801013ec:	57                   	push   %edi
801013ed:	e8 2e 1d 00 00       	call   80103120 <log_write>
        brelse(bp);
801013f2:	89 3c 24             	mov    %edi,(%esp)
801013f5:	e8 16 ee ff ff       	call   80100210 <brelse>
  bp = bread(dev, bno);
801013fa:	58                   	pop    %eax
801013fb:	5a                   	pop    %edx
801013fc:	56                   	push   %esi
801013fd:	ff 75 d8             	pushl  -0x28(%ebp)
80101400:	e8 8b ed ff ff       	call   80100190 <bread>
  memset(bp->data, 0, BSIZE);
80101405:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, bno);
80101408:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
8010140a:	8d 40 5c             	lea    0x5c(%eax),%eax
8010140d:	68 00 02 00 00       	push   $0x200
80101412:	6a 00                	push   $0x0
80101414:	50                   	push   %eax
80101415:	e8 56 38 00 00       	call   80104c70 <memset>
  log_write(bp);
8010141a:	89 1c 24             	mov    %ebx,(%esp)
8010141d:	e8 fe 1c 00 00       	call   80103120 <log_write>
  brelse(bp);
80101422:	89 1c 24             	mov    %ebx,(%esp)
80101425:	e8 e6 ed ff ff       	call   80100210 <brelse>
}
8010142a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010142d:	89 f0                	mov    %esi,%eax
8010142f:	5b                   	pop    %ebx
80101430:	5e                   	pop    %esi
80101431:	5f                   	pop    %edi
80101432:	5d                   	pop    %ebp
80101433:	c3                   	ret    
80101434:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010143b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010143f:	90                   	nop

80101440 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101440:	55                   	push   %ebp
80101441:	89 e5                	mov    %esp,%ebp
80101443:	57                   	push   %edi
80101444:	89 c7                	mov    %eax,%edi
80101446:	56                   	push   %esi
  struct inode *ip, *empty;

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
80101447:	31 f6                	xor    %esi,%esi
{
80101449:	53                   	push   %ebx
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010144a:	bb 34 1a 11 80       	mov    $0x80111a34,%ebx
{
8010144f:	83 ec 28             	sub    $0x28,%esp
80101452:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
80101455:	68 00 1a 11 80       	push   $0x80111a00
8010145a:	e8 01 37 00 00       	call   80104b60 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010145f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  acquire(&icache.lock);
80101462:	83 c4 10             	add    $0x10,%esp
80101465:	eb 1b                	jmp    80101482 <iget+0x42>
80101467:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010146e:	66 90                	xchg   %ax,%ax
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101470:	39 3b                	cmp    %edi,(%ebx)
80101472:	74 6c                	je     801014e0 <iget+0xa0>
80101474:	81 c3 90 00 00 00    	add    $0x90,%ebx
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010147a:	81 fb 54 36 11 80    	cmp    $0x80113654,%ebx
80101480:	73 26                	jae    801014a8 <iget+0x68>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101482:	8b 4b 08             	mov    0x8(%ebx),%ecx
80101485:	85 c9                	test   %ecx,%ecx
80101487:	7f e7                	jg     80101470 <iget+0x30>
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
80101489:	85 f6                	test   %esi,%esi
8010148b:	75 e7                	jne    80101474 <iget+0x34>
8010148d:	89 d8                	mov    %ebx,%eax
8010148f:	81 c3 90 00 00 00    	add    $0x90,%ebx
80101495:	85 c9                	test   %ecx,%ecx
80101497:	75 6e                	jne    80101507 <iget+0xc7>
80101499:	89 c6                	mov    %eax,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010149b:	81 fb 54 36 11 80    	cmp    $0x80113654,%ebx
801014a1:	72 df                	jb     80101482 <iget+0x42>
801014a3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801014a7:	90                   	nop
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801014a8:	85 f6                	test   %esi,%esi
801014aa:	74 73                	je     8010151f <iget+0xdf>
  ip = empty;
  ip->dev = dev;
  ip->inum = inum;
  ip->ref = 1;
  ip->valid = 0;
  release(&icache.lock);
801014ac:	83 ec 0c             	sub    $0xc,%esp
  ip->dev = dev;
801014af:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
801014b1:	89 56 04             	mov    %edx,0x4(%esi)
  ip->ref = 1;
801014b4:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
801014bb:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
801014c2:	68 00 1a 11 80       	push   $0x80111a00
801014c7:	e8 54 37 00 00       	call   80104c20 <release>

  return ip;
801014cc:	83 c4 10             	add    $0x10,%esp
}
801014cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
801014d2:	89 f0                	mov    %esi,%eax
801014d4:	5b                   	pop    %ebx
801014d5:	5e                   	pop    %esi
801014d6:	5f                   	pop    %edi
801014d7:	5d                   	pop    %ebp
801014d8:	c3                   	ret    
801014d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801014e0:	39 53 04             	cmp    %edx,0x4(%ebx)
801014e3:	75 8f                	jne    80101474 <iget+0x34>
      release(&icache.lock);
801014e5:	83 ec 0c             	sub    $0xc,%esp
      ip->ref++;
801014e8:	83 c1 01             	add    $0x1,%ecx
      return ip;
801014eb:	89 de                	mov    %ebx,%esi
      release(&icache.lock);
801014ed:	68 00 1a 11 80       	push   $0x80111a00
      ip->ref++;
801014f2:	89 4b 08             	mov    %ecx,0x8(%ebx)
      release(&icache.lock);
801014f5:	e8 26 37 00 00       	call   80104c20 <release>
      return ip;
801014fa:	83 c4 10             	add    $0x10,%esp
}
801014fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101500:	89 f0                	mov    %esi,%eax
80101502:	5b                   	pop    %ebx
80101503:	5e                   	pop    %esi
80101504:	5f                   	pop    %edi
80101505:	5d                   	pop    %ebp
80101506:	c3                   	ret    
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101507:	81 fb 54 36 11 80    	cmp    $0x80113654,%ebx
8010150d:	73 10                	jae    8010151f <iget+0xdf>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
8010150f:	8b 4b 08             	mov    0x8(%ebx),%ecx
80101512:	85 c9                	test   %ecx,%ecx
80101514:	0f 8f 56 ff ff ff    	jg     80101470 <iget+0x30>
8010151a:	e9 6e ff ff ff       	jmp    8010148d <iget+0x4d>
    panic("iget: no inodes");
8010151f:	83 ec 0c             	sub    $0xc,%esp
80101522:	68 48 78 10 80       	push   $0x80107848
80101527:	e8 64 ef ff ff       	call   80100490 <panic>
8010152c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101530 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101530:	55                   	push   %ebp
80101531:	89 e5                	mov    %esp,%ebp
80101533:	57                   	push   %edi
80101534:	56                   	push   %esi
80101535:	89 c6                	mov    %eax,%esi
80101537:	53                   	push   %ebx
80101538:	83 ec 1c             	sub    $0x1c,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
8010153b:	83 fa 0b             	cmp    $0xb,%edx
8010153e:	0f 86 84 00 00 00    	jbe    801015c8 <bmap+0x98>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
80101544:	8d 5a f4             	lea    -0xc(%edx),%ebx

  if(bn < NINDIRECT){
80101547:	83 fb 7f             	cmp    $0x7f,%ebx
8010154a:	0f 87 98 00 00 00    	ja     801015e8 <bmap+0xb8>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101550:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101556:	8b 16                	mov    (%esi),%edx
80101558:	85 c0                	test   %eax,%eax
8010155a:	74 54                	je     801015b0 <bmap+0x80>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
8010155c:	83 ec 08             	sub    $0x8,%esp
8010155f:	50                   	push   %eax
80101560:	52                   	push   %edx
80101561:	e8 2a ec ff ff       	call   80100190 <bread>
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
80101566:	83 c4 10             	add    $0x10,%esp
80101569:	8d 54 98 5c          	lea    0x5c(%eax,%ebx,4),%edx
    bp = bread(ip->dev, addr);
8010156d:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
8010156f:	8b 1a                	mov    (%edx),%ebx
80101571:	85 db                	test   %ebx,%ebx
80101573:	74 1b                	je     80101590 <bmap+0x60>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
80101575:	83 ec 0c             	sub    $0xc,%esp
80101578:	57                   	push   %edi
80101579:	e8 92 ec ff ff       	call   80100210 <brelse>
    return addr;
8010157e:	83 c4 10             	add    $0x10,%esp
  }

  panic("bmap: out of range");
}
80101581:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101584:	89 d8                	mov    %ebx,%eax
80101586:	5b                   	pop    %ebx
80101587:	5e                   	pop    %esi
80101588:	5f                   	pop    %edi
80101589:	5d                   	pop    %ebp
8010158a:	c3                   	ret    
8010158b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010158f:	90                   	nop
      a[bn] = addr = balloc(ip->dev);
80101590:	8b 06                	mov    (%esi),%eax
80101592:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101595:	e8 96 fd ff ff       	call   80101330 <balloc>
8010159a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      log_write(bp);
8010159d:	83 ec 0c             	sub    $0xc,%esp
      a[bn] = addr = balloc(ip->dev);
801015a0:	89 c3                	mov    %eax,%ebx
801015a2:	89 02                	mov    %eax,(%edx)
      log_write(bp);
801015a4:	57                   	push   %edi
801015a5:	e8 76 1b 00 00       	call   80103120 <log_write>
801015aa:	83 c4 10             	add    $0x10,%esp
801015ad:	eb c6                	jmp    80101575 <bmap+0x45>
801015af:	90                   	nop
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
801015b0:	89 d0                	mov    %edx,%eax
801015b2:	e8 79 fd ff ff       	call   80101330 <balloc>
801015b7:	8b 16                	mov    (%esi),%edx
801015b9:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
801015bf:	eb 9b                	jmp    8010155c <bmap+0x2c>
801015c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if((addr = ip->addrs[bn]) == 0)
801015c8:	8d 3c 90             	lea    (%eax,%edx,4),%edi
801015cb:	8b 5f 5c             	mov    0x5c(%edi),%ebx
801015ce:	85 db                	test   %ebx,%ebx
801015d0:	75 af                	jne    80101581 <bmap+0x51>
      ip->addrs[bn] = addr = balloc(ip->dev);
801015d2:	8b 00                	mov    (%eax),%eax
801015d4:	e8 57 fd ff ff       	call   80101330 <balloc>
801015d9:	89 47 5c             	mov    %eax,0x5c(%edi)
801015dc:	89 c3                	mov    %eax,%ebx
}
801015de:	8d 65 f4             	lea    -0xc(%ebp),%esp
801015e1:	89 d8                	mov    %ebx,%eax
801015e3:	5b                   	pop    %ebx
801015e4:	5e                   	pop    %esi
801015e5:	5f                   	pop    %edi
801015e6:	5d                   	pop    %ebp
801015e7:	c3                   	ret    
  panic("bmap: out of range");
801015e8:	83 ec 0c             	sub    $0xc,%esp
801015eb:	68 58 78 10 80       	push   $0x80107858
801015f0:	e8 9b ee ff ff       	call   80100490 <panic>
801015f5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801015fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101600 <readsb>:
{
80101600:	f3 0f 1e fb          	endbr32 
80101604:	55                   	push   %ebp
80101605:	89 e5                	mov    %esp,%ebp
80101607:	56                   	push   %esi
80101608:	53                   	push   %ebx
80101609:	8b 75 0c             	mov    0xc(%ebp),%esi
  bp = bread(dev, 1);
8010160c:	83 ec 08             	sub    $0x8,%esp
8010160f:	6a 01                	push   $0x1
80101611:	ff 75 08             	pushl  0x8(%ebp)
80101614:	e8 77 eb ff ff       	call   80100190 <bread>
  memmove(sb, bp->data, sizeof(*sb));
80101619:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, 1);
8010161c:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
8010161e:	8d 40 5c             	lea    0x5c(%eax),%eax
80101621:	6a 24                	push   $0x24
80101623:	50                   	push   %eax
80101624:	56                   	push   %esi
80101625:	e8 e6 36 00 00       	call   80104d10 <memmove>
  brelse(bp);
8010162a:	89 5d 08             	mov    %ebx,0x8(%ebp)
8010162d:	83 c4 10             	add    $0x10,%esp
}
80101630:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101633:	5b                   	pop    %ebx
80101634:	5e                   	pop    %esi
80101635:	5d                   	pop    %ebp
  brelse(bp);
80101636:	e9 d5 eb ff ff       	jmp    80100210 <brelse>
8010163b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010163f:	90                   	nop

80101640 <iinit>:
{
80101640:	f3 0f 1e fb          	endbr32 
80101644:	55                   	push   %ebp
80101645:	89 e5                	mov    %esp,%ebp
80101647:	53                   	push   %ebx
80101648:	bb 40 1a 11 80       	mov    $0x80111a40,%ebx
8010164d:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
80101650:	68 6b 78 10 80       	push   $0x8010786b
80101655:	68 00 1a 11 80       	push   $0x80111a00
8010165a:	e8 81 33 00 00       	call   801049e0 <initlock>
  for(i = 0; i < NINODE; i++) {
8010165f:	83 c4 10             	add    $0x10,%esp
80101662:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    initsleeplock(&icache.inode[i].lock, "inode");
80101668:	83 ec 08             	sub    $0x8,%esp
8010166b:	68 72 78 10 80       	push   $0x80107872
80101670:	53                   	push   %ebx
80101671:	81 c3 90 00 00 00    	add    $0x90,%ebx
80101677:	e8 24 32 00 00       	call   801048a0 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
8010167c:	83 c4 10             	add    $0x10,%esp
8010167f:	81 fb 60 36 11 80    	cmp    $0x80113660,%ebx
80101685:	75 e1                	jne    80101668 <iinit+0x28>
  readsb(dev, &sb);
80101687:	83 ec 08             	sub    $0x8,%esp
8010168a:	68 c0 19 11 80       	push   $0x801119c0
8010168f:	ff 75 08             	pushl  0x8(%ebp)
80101692:	e8 69 ff ff ff       	call   80101600 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101697:	ff 35 e0 19 11 80    	pushl  0x801119e0
8010169d:	ff 35 dc 19 11 80    	pushl  0x801119dc
801016a3:	ff 35 d8 19 11 80    	pushl  0x801119d8
801016a9:	ff 35 cc 19 11 80    	pushl  0x801119cc
801016af:	ff 35 c8 19 11 80    	pushl  0x801119c8
801016b5:	ff 35 c4 19 11 80    	pushl  0x801119c4
801016bb:	ff 35 c0 19 11 80    	pushl  0x801119c0
801016c1:	68 d8 78 10 80       	push   $0x801078d8
801016c6:	e8 e5 f0 ff ff       	call   801007b0 <cprintf>
}
801016cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801016ce:	83 c4 30             	add    $0x30,%esp
801016d1:	c9                   	leave  
801016d2:	c3                   	ret    
801016d3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801016da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801016e0 <ialloc>:
{
801016e0:	f3 0f 1e fb          	endbr32 
801016e4:	55                   	push   %ebp
801016e5:	89 e5                	mov    %esp,%ebp
801016e7:	57                   	push   %edi
801016e8:	56                   	push   %esi
801016e9:	53                   	push   %ebx
801016ea:	83 ec 1c             	sub    $0x1c,%esp
801016ed:	8b 45 0c             	mov    0xc(%ebp),%eax
  for(inum = 1; inum < sb.ninodes; inum++){
801016f0:	83 3d c8 19 11 80 01 	cmpl   $0x1,0x801119c8
{
801016f7:	8b 75 08             	mov    0x8(%ebp),%esi
801016fa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
801016fd:	0f 86 8d 00 00 00    	jbe    80101790 <ialloc+0xb0>
80101703:	bf 01 00 00 00       	mov    $0x1,%edi
80101708:	eb 1d                	jmp    80101727 <ialloc+0x47>
8010170a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    brelse(bp);
80101710:	83 ec 0c             	sub    $0xc,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101713:	83 c7 01             	add    $0x1,%edi
    brelse(bp);
80101716:	53                   	push   %ebx
80101717:	e8 f4 ea ff ff       	call   80100210 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
8010171c:	83 c4 10             	add    $0x10,%esp
8010171f:	3b 3d c8 19 11 80    	cmp    0x801119c8,%edi
80101725:	73 69                	jae    80101790 <ialloc+0xb0>
    bp = bread(dev, IBLOCK(inum, sb));
80101727:	89 f8                	mov    %edi,%eax
80101729:	83 ec 08             	sub    $0x8,%esp
8010172c:	c1 e8 03             	shr    $0x3,%eax
8010172f:	03 05 dc 19 11 80    	add    0x801119dc,%eax
80101735:	50                   	push   %eax
80101736:	56                   	push   %esi
80101737:	e8 54 ea ff ff       	call   80100190 <bread>
    if(dip->type == 0){  // a free inode
8010173c:	83 c4 10             	add    $0x10,%esp
    bp = bread(dev, IBLOCK(inum, sb));
8010173f:	89 c3                	mov    %eax,%ebx
    dip = (struct dinode*)bp->data + inum%IPB;
80101741:	89 f8                	mov    %edi,%eax
80101743:	83 e0 07             	and    $0x7,%eax
80101746:	c1 e0 06             	shl    $0x6,%eax
80101749:	8d 4c 03 5c          	lea    0x5c(%ebx,%eax,1),%ecx
    if(dip->type == 0){  // a free inode
8010174d:	66 83 39 00          	cmpw   $0x0,(%ecx)
80101751:	75 bd                	jne    80101710 <ialloc+0x30>
      memset(dip, 0, sizeof(*dip));
80101753:	83 ec 04             	sub    $0x4,%esp
80101756:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80101759:	6a 40                	push   $0x40
8010175b:	6a 00                	push   $0x0
8010175d:	51                   	push   %ecx
8010175e:	e8 0d 35 00 00       	call   80104c70 <memset>
      dip->type = type;
80101763:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80101767:	8b 4d e0             	mov    -0x20(%ebp),%ecx
8010176a:	66 89 01             	mov    %ax,(%ecx)
      log_write(bp);   // mark it allocated on the disk
8010176d:	89 1c 24             	mov    %ebx,(%esp)
80101770:	e8 ab 19 00 00       	call   80103120 <log_write>
      brelse(bp);
80101775:	89 1c 24             	mov    %ebx,(%esp)
80101778:	e8 93 ea ff ff       	call   80100210 <brelse>
      return iget(dev, inum);
8010177d:	83 c4 10             	add    $0x10,%esp
}
80101780:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return iget(dev, inum);
80101783:	89 fa                	mov    %edi,%edx
}
80101785:	5b                   	pop    %ebx
      return iget(dev, inum);
80101786:	89 f0                	mov    %esi,%eax
}
80101788:	5e                   	pop    %esi
80101789:	5f                   	pop    %edi
8010178a:	5d                   	pop    %ebp
      return iget(dev, inum);
8010178b:	e9 b0 fc ff ff       	jmp    80101440 <iget>
  panic("ialloc: no inodes");
80101790:	83 ec 0c             	sub    $0xc,%esp
80101793:	68 78 78 10 80       	push   $0x80107878
80101798:	e8 f3 ec ff ff       	call   80100490 <panic>
8010179d:	8d 76 00             	lea    0x0(%esi),%esi

801017a0 <iupdate>:
{
801017a0:	f3 0f 1e fb          	endbr32 
801017a4:	55                   	push   %ebp
801017a5:	89 e5                	mov    %esp,%ebp
801017a7:	56                   	push   %esi
801017a8:	53                   	push   %ebx
801017a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017ac:	8b 43 04             	mov    0x4(%ebx),%eax
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801017af:	83 c3 5c             	add    $0x5c,%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017b2:	83 ec 08             	sub    $0x8,%esp
801017b5:	c1 e8 03             	shr    $0x3,%eax
801017b8:	03 05 dc 19 11 80    	add    0x801119dc,%eax
801017be:	50                   	push   %eax
801017bf:	ff 73 a4             	pushl  -0x5c(%ebx)
801017c2:	e8 c9 e9 ff ff       	call   80100190 <bread>
  dip->type = ip->type;
801017c7:	0f b7 53 f4          	movzwl -0xc(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801017cb:	83 c4 0c             	add    $0xc,%esp
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017ce:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801017d0:	8b 43 a8             	mov    -0x58(%ebx),%eax
801017d3:	83 e0 07             	and    $0x7,%eax
801017d6:	c1 e0 06             	shl    $0x6,%eax
801017d9:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
801017dd:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801017e0:	0f b7 53 f6          	movzwl -0xa(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801017e4:	83 c0 0c             	add    $0xc,%eax
  dip->major = ip->major;
801017e7:	66 89 50 f6          	mov    %dx,-0xa(%eax)
  dip->minor = ip->minor;
801017eb:	0f b7 53 f8          	movzwl -0x8(%ebx),%edx
801017ef:	66 89 50 f8          	mov    %dx,-0x8(%eax)
  dip->nlink = ip->nlink;
801017f3:	0f b7 53 fa          	movzwl -0x6(%ebx),%edx
801017f7:	66 89 50 fa          	mov    %dx,-0x6(%eax)
  dip->size = ip->size;
801017fb:	8b 53 fc             	mov    -0x4(%ebx),%edx
801017fe:	89 50 fc             	mov    %edx,-0x4(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101801:	6a 34                	push   $0x34
80101803:	53                   	push   %ebx
80101804:	50                   	push   %eax
80101805:	e8 06 35 00 00       	call   80104d10 <memmove>
  log_write(bp);
8010180a:	89 34 24             	mov    %esi,(%esp)
8010180d:	e8 0e 19 00 00       	call   80103120 <log_write>
  brelse(bp);
80101812:	89 75 08             	mov    %esi,0x8(%ebp)
80101815:	83 c4 10             	add    $0x10,%esp
}
80101818:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010181b:	5b                   	pop    %ebx
8010181c:	5e                   	pop    %esi
8010181d:	5d                   	pop    %ebp
  brelse(bp);
8010181e:	e9 ed e9 ff ff       	jmp    80100210 <brelse>
80101823:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010182a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101830 <idup>:
{
80101830:	f3 0f 1e fb          	endbr32 
80101834:	55                   	push   %ebp
80101835:	89 e5                	mov    %esp,%ebp
80101837:	53                   	push   %ebx
80101838:	83 ec 10             	sub    $0x10,%esp
8010183b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
8010183e:	68 00 1a 11 80       	push   $0x80111a00
80101843:	e8 18 33 00 00       	call   80104b60 <acquire>
  ip->ref++;
80101848:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
8010184c:	c7 04 24 00 1a 11 80 	movl   $0x80111a00,(%esp)
80101853:	e8 c8 33 00 00       	call   80104c20 <release>
}
80101858:	89 d8                	mov    %ebx,%eax
8010185a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010185d:	c9                   	leave  
8010185e:	c3                   	ret    
8010185f:	90                   	nop

80101860 <ilock>:
{
80101860:	f3 0f 1e fb          	endbr32 
80101864:	55                   	push   %ebp
80101865:	89 e5                	mov    %esp,%ebp
80101867:	56                   	push   %esi
80101868:	53                   	push   %ebx
80101869:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
8010186c:	85 db                	test   %ebx,%ebx
8010186e:	0f 84 b3 00 00 00    	je     80101927 <ilock+0xc7>
80101874:	8b 53 08             	mov    0x8(%ebx),%edx
80101877:	85 d2                	test   %edx,%edx
80101879:	0f 8e a8 00 00 00    	jle    80101927 <ilock+0xc7>
  acquiresleep(&ip->lock);
8010187f:	83 ec 0c             	sub    $0xc,%esp
80101882:	8d 43 0c             	lea    0xc(%ebx),%eax
80101885:	50                   	push   %eax
80101886:	e8 55 30 00 00       	call   801048e0 <acquiresleep>
  if(ip->valid == 0){
8010188b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010188e:	83 c4 10             	add    $0x10,%esp
80101891:	85 c0                	test   %eax,%eax
80101893:	74 0b                	je     801018a0 <ilock+0x40>
}
80101895:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101898:	5b                   	pop    %ebx
80101899:	5e                   	pop    %esi
8010189a:	5d                   	pop    %ebp
8010189b:	c3                   	ret    
8010189c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801018a0:	8b 43 04             	mov    0x4(%ebx),%eax
801018a3:	83 ec 08             	sub    $0x8,%esp
801018a6:	c1 e8 03             	shr    $0x3,%eax
801018a9:	03 05 dc 19 11 80    	add    0x801119dc,%eax
801018af:	50                   	push   %eax
801018b0:	ff 33                	pushl  (%ebx)
801018b2:	e8 d9 e8 ff ff       	call   80100190 <bread>
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801018b7:	83 c4 0c             	add    $0xc,%esp
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801018ba:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801018bc:	8b 43 04             	mov    0x4(%ebx),%eax
801018bf:	83 e0 07             	and    $0x7,%eax
801018c2:	c1 e0 06             	shl    $0x6,%eax
801018c5:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
801018c9:	0f b7 10             	movzwl (%eax),%edx
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801018cc:	83 c0 0c             	add    $0xc,%eax
    ip->type = dip->type;
801018cf:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
801018d3:	0f b7 50 f6          	movzwl -0xa(%eax),%edx
801018d7:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
801018db:	0f b7 50 f8          	movzwl -0x8(%eax),%edx
801018df:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
801018e3:	0f b7 50 fa          	movzwl -0x6(%eax),%edx
801018e7:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
801018eb:	8b 50 fc             	mov    -0x4(%eax),%edx
801018ee:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801018f1:	6a 34                	push   $0x34
801018f3:	50                   	push   %eax
801018f4:	8d 43 5c             	lea    0x5c(%ebx),%eax
801018f7:	50                   	push   %eax
801018f8:	e8 13 34 00 00       	call   80104d10 <memmove>
    brelse(bp);
801018fd:	89 34 24             	mov    %esi,(%esp)
80101900:	e8 0b e9 ff ff       	call   80100210 <brelse>
    if(ip->type == 0)
80101905:	83 c4 10             	add    $0x10,%esp
80101908:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
    ip->valid = 1;
8010190d:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101914:	0f 85 7b ff ff ff    	jne    80101895 <ilock+0x35>
      panic("ilock: no type");
8010191a:	83 ec 0c             	sub    $0xc,%esp
8010191d:	68 90 78 10 80       	push   $0x80107890
80101922:	e8 69 eb ff ff       	call   80100490 <panic>
    panic("ilock");
80101927:	83 ec 0c             	sub    $0xc,%esp
8010192a:	68 8a 78 10 80       	push   $0x8010788a
8010192f:	e8 5c eb ff ff       	call   80100490 <panic>
80101934:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010193b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010193f:	90                   	nop

80101940 <iunlock>:
{
80101940:	f3 0f 1e fb          	endbr32 
80101944:	55                   	push   %ebp
80101945:	89 e5                	mov    %esp,%ebp
80101947:	56                   	push   %esi
80101948:	53                   	push   %ebx
80101949:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
8010194c:	85 db                	test   %ebx,%ebx
8010194e:	74 28                	je     80101978 <iunlock+0x38>
80101950:	83 ec 0c             	sub    $0xc,%esp
80101953:	8d 73 0c             	lea    0xc(%ebx),%esi
80101956:	56                   	push   %esi
80101957:	e8 24 30 00 00       	call   80104980 <holdingsleep>
8010195c:	83 c4 10             	add    $0x10,%esp
8010195f:	85 c0                	test   %eax,%eax
80101961:	74 15                	je     80101978 <iunlock+0x38>
80101963:	8b 43 08             	mov    0x8(%ebx),%eax
80101966:	85 c0                	test   %eax,%eax
80101968:	7e 0e                	jle    80101978 <iunlock+0x38>
  releasesleep(&ip->lock);
8010196a:	89 75 08             	mov    %esi,0x8(%ebp)
}
8010196d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101970:	5b                   	pop    %ebx
80101971:	5e                   	pop    %esi
80101972:	5d                   	pop    %ebp
  releasesleep(&ip->lock);
80101973:	e9 c8 2f 00 00       	jmp    80104940 <releasesleep>
    panic("iunlock");
80101978:	83 ec 0c             	sub    $0xc,%esp
8010197b:	68 9f 78 10 80       	push   $0x8010789f
80101980:	e8 0b eb ff ff       	call   80100490 <panic>
80101985:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010198c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101990 <iput>:
{
80101990:	f3 0f 1e fb          	endbr32 
80101994:	55                   	push   %ebp
80101995:	89 e5                	mov    %esp,%ebp
80101997:	57                   	push   %edi
80101998:	56                   	push   %esi
80101999:	53                   	push   %ebx
8010199a:	83 ec 28             	sub    $0x28,%esp
8010199d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
801019a0:	8d 7b 0c             	lea    0xc(%ebx),%edi
801019a3:	57                   	push   %edi
801019a4:	e8 37 2f 00 00       	call   801048e0 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
801019a9:	8b 53 4c             	mov    0x4c(%ebx),%edx
801019ac:	83 c4 10             	add    $0x10,%esp
801019af:	85 d2                	test   %edx,%edx
801019b1:	74 07                	je     801019ba <iput+0x2a>
801019b3:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801019b8:	74 36                	je     801019f0 <iput+0x60>
  releasesleep(&ip->lock);
801019ba:	83 ec 0c             	sub    $0xc,%esp
801019bd:	57                   	push   %edi
801019be:	e8 7d 2f 00 00       	call   80104940 <releasesleep>
  acquire(&icache.lock);
801019c3:	c7 04 24 00 1a 11 80 	movl   $0x80111a00,(%esp)
801019ca:	e8 91 31 00 00       	call   80104b60 <acquire>
  ip->ref--;
801019cf:	83 6b 08 01          	subl   $0x1,0x8(%ebx)
  release(&icache.lock);
801019d3:	83 c4 10             	add    $0x10,%esp
801019d6:	c7 45 08 00 1a 11 80 	movl   $0x80111a00,0x8(%ebp)
}
801019dd:	8d 65 f4             	lea    -0xc(%ebp),%esp
801019e0:	5b                   	pop    %ebx
801019e1:	5e                   	pop    %esi
801019e2:	5f                   	pop    %edi
801019e3:	5d                   	pop    %ebp
  release(&icache.lock);
801019e4:	e9 37 32 00 00       	jmp    80104c20 <release>
801019e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    acquire(&icache.lock);
801019f0:	83 ec 0c             	sub    $0xc,%esp
801019f3:	68 00 1a 11 80       	push   $0x80111a00
801019f8:	e8 63 31 00 00       	call   80104b60 <acquire>
    int r = ip->ref;
801019fd:	8b 73 08             	mov    0x8(%ebx),%esi
    release(&icache.lock);
80101a00:	c7 04 24 00 1a 11 80 	movl   $0x80111a00,(%esp)
80101a07:	e8 14 32 00 00       	call   80104c20 <release>
    if(r == 1){
80101a0c:	83 c4 10             	add    $0x10,%esp
80101a0f:	83 fe 01             	cmp    $0x1,%esi
80101a12:	75 a6                	jne    801019ba <iput+0x2a>
80101a14:	8d 8b 8c 00 00 00    	lea    0x8c(%ebx),%ecx
80101a1a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80101a1d:	8d 73 5c             	lea    0x5c(%ebx),%esi
80101a20:	89 cf                	mov    %ecx,%edi
80101a22:	eb 0b                	jmp    80101a2f <iput+0x9f>
80101a24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101a28:	83 c6 04             	add    $0x4,%esi
80101a2b:	39 fe                	cmp    %edi,%esi
80101a2d:	74 19                	je     80101a48 <iput+0xb8>
    if(ip->addrs[i]){
80101a2f:	8b 16                	mov    (%esi),%edx
80101a31:	85 d2                	test   %edx,%edx
80101a33:	74 f3                	je     80101a28 <iput+0x98>
      bfree(ip->dev, ip->addrs[i]);
80101a35:	8b 03                	mov    (%ebx),%eax
80101a37:	e8 74 f8 ff ff       	call   801012b0 <bfree>
      ip->addrs[i] = 0;
80101a3c:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80101a42:	eb e4                	jmp    80101a28 <iput+0x98>
80101a44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }
  }

  if(ip->addrs[NDIRECT]){
80101a48:	8b 83 8c 00 00 00    	mov    0x8c(%ebx),%eax
80101a4e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101a51:	85 c0                	test   %eax,%eax
80101a53:	75 33                	jne    80101a88 <iput+0xf8>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
  iupdate(ip);
80101a55:	83 ec 0c             	sub    $0xc,%esp
  ip->size = 0;
80101a58:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  iupdate(ip);
80101a5f:	53                   	push   %ebx
80101a60:	e8 3b fd ff ff       	call   801017a0 <iupdate>
      ip->type = 0;
80101a65:	31 c0                	xor    %eax,%eax
80101a67:	66 89 43 50          	mov    %ax,0x50(%ebx)
      iupdate(ip);
80101a6b:	89 1c 24             	mov    %ebx,(%esp)
80101a6e:	e8 2d fd ff ff       	call   801017a0 <iupdate>
      ip->valid = 0;
80101a73:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
80101a7a:	83 c4 10             	add    $0x10,%esp
80101a7d:	e9 38 ff ff ff       	jmp    801019ba <iput+0x2a>
80101a82:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101a88:	83 ec 08             	sub    $0x8,%esp
80101a8b:	50                   	push   %eax
80101a8c:	ff 33                	pushl  (%ebx)
80101a8e:	e8 fd e6 ff ff       	call   80100190 <bread>
80101a93:	89 7d e0             	mov    %edi,-0x20(%ebp)
80101a96:	83 c4 10             	add    $0x10,%esp
80101a99:	8d 88 5c 02 00 00    	lea    0x25c(%eax),%ecx
80101a9f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101aa2:	8d 70 5c             	lea    0x5c(%eax),%esi
80101aa5:	89 cf                	mov    %ecx,%edi
80101aa7:	eb 0e                	jmp    80101ab7 <iput+0x127>
80101aa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101ab0:	83 c6 04             	add    $0x4,%esi
80101ab3:	39 f7                	cmp    %esi,%edi
80101ab5:	74 19                	je     80101ad0 <iput+0x140>
      if(a[j])
80101ab7:	8b 16                	mov    (%esi),%edx
80101ab9:	85 d2                	test   %edx,%edx
80101abb:	74 f3                	je     80101ab0 <iput+0x120>
        bfree(ip->dev, a[j]);
80101abd:	8b 03                	mov    (%ebx),%eax
80101abf:	e8 ec f7 ff ff       	call   801012b0 <bfree>
80101ac4:	eb ea                	jmp    80101ab0 <iput+0x120>
80101ac6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101acd:	8d 76 00             	lea    0x0(%esi),%esi
    brelse(bp);
80101ad0:	83 ec 0c             	sub    $0xc,%esp
80101ad3:	ff 75 e4             	pushl  -0x1c(%ebp)
80101ad6:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101ad9:	e8 32 e7 ff ff       	call   80100210 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101ade:	8b 93 8c 00 00 00    	mov    0x8c(%ebx),%edx
80101ae4:	8b 03                	mov    (%ebx),%eax
80101ae6:	e8 c5 f7 ff ff       	call   801012b0 <bfree>
    ip->addrs[NDIRECT] = 0;
80101aeb:	83 c4 10             	add    $0x10,%esp
80101aee:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
80101af5:	00 00 00 
80101af8:	e9 58 ff ff ff       	jmp    80101a55 <iput+0xc5>
80101afd:	8d 76 00             	lea    0x0(%esi),%esi

80101b00 <iunlockput>:
{
80101b00:	f3 0f 1e fb          	endbr32 
80101b04:	55                   	push   %ebp
80101b05:	89 e5                	mov    %esp,%ebp
80101b07:	53                   	push   %ebx
80101b08:	83 ec 10             	sub    $0x10,%esp
80101b0b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
80101b0e:	53                   	push   %ebx
80101b0f:	e8 2c fe ff ff       	call   80101940 <iunlock>
  iput(ip);
80101b14:	89 5d 08             	mov    %ebx,0x8(%ebp)
80101b17:	83 c4 10             	add    $0x10,%esp
}
80101b1a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101b1d:	c9                   	leave  
  iput(ip);
80101b1e:	e9 6d fe ff ff       	jmp    80101990 <iput>
80101b23:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101b2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101b30 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101b30:	f3 0f 1e fb          	endbr32 
80101b34:	55                   	push   %ebp
80101b35:	89 e5                	mov    %esp,%ebp
80101b37:	8b 55 08             	mov    0x8(%ebp),%edx
80101b3a:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101b3d:	8b 0a                	mov    (%edx),%ecx
80101b3f:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101b42:	8b 4a 04             	mov    0x4(%edx),%ecx
80101b45:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
80101b48:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101b4c:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101b4f:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101b53:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101b57:	8b 52 58             	mov    0x58(%edx),%edx
80101b5a:	89 50 10             	mov    %edx,0x10(%eax)
}
80101b5d:	5d                   	pop    %ebp
80101b5e:	c3                   	ret    
80101b5f:	90                   	nop

80101b60 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101b60:	f3 0f 1e fb          	endbr32 
80101b64:	55                   	push   %ebp
80101b65:	89 e5                	mov    %esp,%ebp
80101b67:	57                   	push   %edi
80101b68:	56                   	push   %esi
80101b69:	53                   	push   %ebx
80101b6a:	83 ec 1c             	sub    $0x1c,%esp
80101b6d:	8b 7d 0c             	mov    0xc(%ebp),%edi
80101b70:	8b 45 08             	mov    0x8(%ebp),%eax
80101b73:	8b 75 10             	mov    0x10(%ebp),%esi
80101b76:	89 7d e0             	mov    %edi,-0x20(%ebp)
80101b79:	8b 7d 14             	mov    0x14(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101b7c:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101b81:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101b84:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  if(ip->type == T_DEV){
80101b87:	0f 84 a3 00 00 00    	je     80101c30 <readi+0xd0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
80101b8d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101b90:	8b 40 58             	mov    0x58(%eax),%eax
80101b93:	39 c6                	cmp    %eax,%esi
80101b95:	0f 87 b6 00 00 00    	ja     80101c51 <readi+0xf1>
80101b9b:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101b9e:	31 c9                	xor    %ecx,%ecx
80101ba0:	89 da                	mov    %ebx,%edx
80101ba2:	01 f2                	add    %esi,%edx
80101ba4:	0f 92 c1             	setb   %cl
80101ba7:	89 cf                	mov    %ecx,%edi
80101ba9:	0f 82 a2 00 00 00    	jb     80101c51 <readi+0xf1>
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
80101baf:	89 c1                	mov    %eax,%ecx
80101bb1:	29 f1                	sub    %esi,%ecx
80101bb3:	39 d0                	cmp    %edx,%eax
80101bb5:	0f 43 cb             	cmovae %ebx,%ecx
80101bb8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101bbb:	85 c9                	test   %ecx,%ecx
80101bbd:	74 63                	je     80101c22 <readi+0xc2>
80101bbf:	90                   	nop
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101bc0:	8b 5d d8             	mov    -0x28(%ebp),%ebx
80101bc3:	89 f2                	mov    %esi,%edx
80101bc5:	c1 ea 09             	shr    $0x9,%edx
80101bc8:	89 d8                	mov    %ebx,%eax
80101bca:	e8 61 f9 ff ff       	call   80101530 <bmap>
80101bcf:	83 ec 08             	sub    $0x8,%esp
80101bd2:	50                   	push   %eax
80101bd3:	ff 33                	pushl  (%ebx)
80101bd5:	e8 b6 e5 ff ff       	call   80100190 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101bda:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101bdd:	b9 00 02 00 00       	mov    $0x200,%ecx
80101be2:	83 c4 0c             	add    $0xc,%esp
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101be5:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101be7:	89 f0                	mov    %esi,%eax
80101be9:	25 ff 01 00 00       	and    $0x1ff,%eax
80101bee:	29 fb                	sub    %edi,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101bf0:	89 55 dc             	mov    %edx,-0x24(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101bf3:	29 c1                	sub    %eax,%ecx
    memmove(dst, bp->data + off%BSIZE, m);
80101bf5:	8d 44 02 5c          	lea    0x5c(%edx,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101bf9:	39 d9                	cmp    %ebx,%ecx
80101bfb:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101bfe:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101bff:	01 df                	add    %ebx,%edi
80101c01:	01 de                	add    %ebx,%esi
    memmove(dst, bp->data + off%BSIZE, m);
80101c03:	50                   	push   %eax
80101c04:	ff 75 e0             	pushl  -0x20(%ebp)
80101c07:	e8 04 31 00 00       	call   80104d10 <memmove>
    brelse(bp);
80101c0c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101c0f:	89 14 24             	mov    %edx,(%esp)
80101c12:	e8 f9 e5 ff ff       	call   80100210 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101c17:	01 5d e0             	add    %ebx,-0x20(%ebp)
80101c1a:	83 c4 10             	add    $0x10,%esp
80101c1d:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80101c20:	77 9e                	ja     80101bc0 <readi+0x60>
  }
  return n;
80101c22:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
80101c25:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c28:	5b                   	pop    %ebx
80101c29:	5e                   	pop    %esi
80101c2a:	5f                   	pop    %edi
80101c2b:	5d                   	pop    %ebp
80101c2c:	c3                   	ret    
80101c2d:	8d 76 00             	lea    0x0(%esi),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101c30:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101c34:	66 83 f8 09          	cmp    $0x9,%ax
80101c38:	77 17                	ja     80101c51 <readi+0xf1>
80101c3a:	8b 04 c5 60 19 11 80 	mov    -0x7feee6a0(,%eax,8),%eax
80101c41:	85 c0                	test   %eax,%eax
80101c43:	74 0c                	je     80101c51 <readi+0xf1>
    return devsw[ip->major].read(ip, dst, n);
80101c45:	89 7d 10             	mov    %edi,0x10(%ebp)
}
80101c48:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c4b:	5b                   	pop    %ebx
80101c4c:	5e                   	pop    %esi
80101c4d:	5f                   	pop    %edi
80101c4e:	5d                   	pop    %ebp
    return devsw[ip->major].read(ip, dst, n);
80101c4f:	ff e0                	jmp    *%eax
      return -1;
80101c51:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101c56:	eb cd                	jmp    80101c25 <readi+0xc5>
80101c58:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101c5f:	90                   	nop

80101c60 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101c60:	f3 0f 1e fb          	endbr32 
80101c64:	55                   	push   %ebp
80101c65:	89 e5                	mov    %esp,%ebp
80101c67:	57                   	push   %edi
80101c68:	56                   	push   %esi
80101c69:	53                   	push   %ebx
80101c6a:	83 ec 1c             	sub    $0x1c,%esp
80101c6d:	8b 45 08             	mov    0x8(%ebp),%eax
80101c70:	8b 75 0c             	mov    0xc(%ebp),%esi
80101c73:	8b 7d 14             	mov    0x14(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101c76:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101c7b:	89 75 dc             	mov    %esi,-0x24(%ebp)
80101c7e:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101c81:	8b 75 10             	mov    0x10(%ebp),%esi
80101c84:	89 7d e0             	mov    %edi,-0x20(%ebp)
  if(ip->type == T_DEV){
80101c87:	0f 84 b3 00 00 00    	je     80101d40 <writei+0xe0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
80101c8d:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101c90:	39 70 58             	cmp    %esi,0x58(%eax)
80101c93:	0f 82 e3 00 00 00    	jb     80101d7c <writei+0x11c>
    return -1;
  if(off + n > MAXFILE*BSIZE)
80101c99:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101c9c:	89 f8                	mov    %edi,%eax
80101c9e:	01 f0                	add    %esi,%eax
80101ca0:	0f 82 d6 00 00 00    	jb     80101d7c <writei+0x11c>
80101ca6:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101cab:	0f 87 cb 00 00 00    	ja     80101d7c <writei+0x11c>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101cb1:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101cb8:	85 ff                	test   %edi,%edi
80101cba:	74 75                	je     80101d31 <writei+0xd1>
80101cbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101cc0:	8b 7d d8             	mov    -0x28(%ebp),%edi
80101cc3:	89 f2                	mov    %esi,%edx
80101cc5:	c1 ea 09             	shr    $0x9,%edx
80101cc8:	89 f8                	mov    %edi,%eax
80101cca:	e8 61 f8 ff ff       	call   80101530 <bmap>
80101ccf:	83 ec 08             	sub    $0x8,%esp
80101cd2:	50                   	push   %eax
80101cd3:	ff 37                	pushl  (%edi)
80101cd5:	e8 b6 e4 ff ff       	call   80100190 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101cda:	b9 00 02 00 00       	mov    $0x200,%ecx
80101cdf:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80101ce2:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101ce5:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
80101ce7:	89 f0                	mov    %esi,%eax
80101ce9:	83 c4 0c             	add    $0xc,%esp
80101cec:	25 ff 01 00 00       	and    $0x1ff,%eax
80101cf1:	29 c1                	sub    %eax,%ecx
    memmove(bp->data + off%BSIZE, src, m);
80101cf3:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101cf7:	39 d9                	cmp    %ebx,%ecx
80101cf9:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101cfc:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101cfd:	01 de                	add    %ebx,%esi
    memmove(bp->data + off%BSIZE, src, m);
80101cff:	ff 75 dc             	pushl  -0x24(%ebp)
80101d02:	50                   	push   %eax
80101d03:	e8 08 30 00 00       	call   80104d10 <memmove>
    log_write(bp);
80101d08:	89 3c 24             	mov    %edi,(%esp)
80101d0b:	e8 10 14 00 00       	call   80103120 <log_write>
    brelse(bp);
80101d10:	89 3c 24             	mov    %edi,(%esp)
80101d13:	e8 f8 e4 ff ff       	call   80100210 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101d18:	01 5d e4             	add    %ebx,-0x1c(%ebp)
80101d1b:	83 c4 10             	add    $0x10,%esp
80101d1e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101d21:	01 5d dc             	add    %ebx,-0x24(%ebp)
80101d24:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80101d27:	77 97                	ja     80101cc0 <writei+0x60>
  }

  if(n > 0 && off > ip->size){
80101d29:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101d2c:	3b 70 58             	cmp    0x58(%eax),%esi
80101d2f:	77 37                	ja     80101d68 <writei+0x108>
    ip->size = off;
    iupdate(ip);
  }
  return n;
80101d31:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
80101d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101d37:	5b                   	pop    %ebx
80101d38:	5e                   	pop    %esi
80101d39:	5f                   	pop    %edi
80101d3a:	5d                   	pop    %ebp
80101d3b:	c3                   	ret    
80101d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101d40:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101d44:	66 83 f8 09          	cmp    $0x9,%ax
80101d48:	77 32                	ja     80101d7c <writei+0x11c>
80101d4a:	8b 04 c5 64 19 11 80 	mov    -0x7feee69c(,%eax,8),%eax
80101d51:	85 c0                	test   %eax,%eax
80101d53:	74 27                	je     80101d7c <writei+0x11c>
    return devsw[ip->major].write(ip, src, n);
80101d55:	89 7d 10             	mov    %edi,0x10(%ebp)
}
80101d58:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101d5b:	5b                   	pop    %ebx
80101d5c:	5e                   	pop    %esi
80101d5d:	5f                   	pop    %edi
80101d5e:	5d                   	pop    %ebp
    return devsw[ip->major].write(ip, src, n);
80101d5f:	ff e0                	jmp    *%eax
80101d61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    ip->size = off;
80101d68:	8b 45 d8             	mov    -0x28(%ebp),%eax
    iupdate(ip);
80101d6b:	83 ec 0c             	sub    $0xc,%esp
    ip->size = off;
80101d6e:	89 70 58             	mov    %esi,0x58(%eax)
    iupdate(ip);
80101d71:	50                   	push   %eax
80101d72:	e8 29 fa ff ff       	call   801017a0 <iupdate>
80101d77:	83 c4 10             	add    $0x10,%esp
80101d7a:	eb b5                	jmp    80101d31 <writei+0xd1>
      return -1;
80101d7c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101d81:	eb b1                	jmp    80101d34 <writei+0xd4>
80101d83:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101d8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101d90 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80101d90:	f3 0f 1e fb          	endbr32 
80101d94:	55                   	push   %ebp
80101d95:	89 e5                	mov    %esp,%ebp
80101d97:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101d9a:	6a 0e                	push   $0xe
80101d9c:	ff 75 0c             	pushl  0xc(%ebp)
80101d9f:	ff 75 08             	pushl  0x8(%ebp)
80101da2:	e8 d9 2f 00 00       	call   80104d80 <strncmp>
}
80101da7:	c9                   	leave  
80101da8:	c3                   	ret    
80101da9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101db0 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80101db0:	f3 0f 1e fb          	endbr32 
80101db4:	55                   	push   %ebp
80101db5:	89 e5                	mov    %esp,%ebp
80101db7:	57                   	push   %edi
80101db8:	56                   	push   %esi
80101db9:	53                   	push   %ebx
80101dba:	83 ec 1c             	sub    $0x1c,%esp
80101dbd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80101dc0:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101dc5:	0f 85 89 00 00 00    	jne    80101e54 <dirlookup+0xa4>
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80101dcb:	8b 53 58             	mov    0x58(%ebx),%edx
80101dce:	31 ff                	xor    %edi,%edi
80101dd0:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101dd3:	85 d2                	test   %edx,%edx
80101dd5:	74 42                	je     80101e19 <dirlookup+0x69>
80101dd7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101dde:	66 90                	xchg   %ax,%ax
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101de0:	6a 10                	push   $0x10
80101de2:	57                   	push   %edi
80101de3:	56                   	push   %esi
80101de4:	53                   	push   %ebx
80101de5:	e8 76 fd ff ff       	call   80101b60 <readi>
80101dea:	83 c4 10             	add    $0x10,%esp
80101ded:	83 f8 10             	cmp    $0x10,%eax
80101df0:	75 55                	jne    80101e47 <dirlookup+0x97>
      panic("dirlookup read");
    if(de.inum == 0)
80101df2:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101df7:	74 18                	je     80101e11 <dirlookup+0x61>
  return strncmp(s, t, DIRSIZ);
80101df9:	83 ec 04             	sub    $0x4,%esp
80101dfc:	8d 45 da             	lea    -0x26(%ebp),%eax
80101dff:	6a 0e                	push   $0xe
80101e01:	50                   	push   %eax
80101e02:	ff 75 0c             	pushl  0xc(%ebp)
80101e05:	e8 76 2f 00 00       	call   80104d80 <strncmp>
      continue;
    if(namecmp(name, de.name) == 0){
80101e0a:	83 c4 10             	add    $0x10,%esp
80101e0d:	85 c0                	test   %eax,%eax
80101e0f:	74 17                	je     80101e28 <dirlookup+0x78>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101e11:	83 c7 10             	add    $0x10,%edi
80101e14:	3b 7b 58             	cmp    0x58(%ebx),%edi
80101e17:	72 c7                	jb     80101de0 <dirlookup+0x30>
      return iget(dp->dev, inum);
    }
  }

  return 0;
}
80101e19:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80101e1c:	31 c0                	xor    %eax,%eax
}
80101e1e:	5b                   	pop    %ebx
80101e1f:	5e                   	pop    %esi
80101e20:	5f                   	pop    %edi
80101e21:	5d                   	pop    %ebp
80101e22:	c3                   	ret    
80101e23:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101e27:	90                   	nop
      if(poff)
80101e28:	8b 45 10             	mov    0x10(%ebp),%eax
80101e2b:	85 c0                	test   %eax,%eax
80101e2d:	74 05                	je     80101e34 <dirlookup+0x84>
        *poff = off;
80101e2f:	8b 45 10             	mov    0x10(%ebp),%eax
80101e32:	89 38                	mov    %edi,(%eax)
      inum = de.inum;
80101e34:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101e38:	8b 03                	mov    (%ebx),%eax
80101e3a:	e8 01 f6 ff ff       	call   80101440 <iget>
}
80101e3f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101e42:	5b                   	pop    %ebx
80101e43:	5e                   	pop    %esi
80101e44:	5f                   	pop    %edi
80101e45:	5d                   	pop    %ebp
80101e46:	c3                   	ret    
      panic("dirlookup read");
80101e47:	83 ec 0c             	sub    $0xc,%esp
80101e4a:	68 b9 78 10 80       	push   $0x801078b9
80101e4f:	e8 3c e6 ff ff       	call   80100490 <panic>
    panic("dirlookup not DIR");
80101e54:	83 ec 0c             	sub    $0xc,%esp
80101e57:	68 a7 78 10 80       	push   $0x801078a7
80101e5c:	e8 2f e6 ff ff       	call   80100490 <panic>
80101e61:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101e68:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101e6f:	90                   	nop

80101e70 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101e70:	55                   	push   %ebp
80101e71:	89 e5                	mov    %esp,%ebp
80101e73:	57                   	push   %edi
80101e74:	56                   	push   %esi
80101e75:	53                   	push   %ebx
80101e76:	89 c3                	mov    %eax,%ebx
80101e78:	83 ec 1c             	sub    $0x1c,%esp
  struct inode *ip, *next;

  if(*path == '/')
80101e7b:	80 38 2f             	cmpb   $0x2f,(%eax)
{
80101e7e:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101e81:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  if(*path == '/')
80101e84:	0f 84 86 01 00 00    	je     80102010 <namex+0x1a0>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101e8a:	e8 11 20 00 00       	call   80103ea0 <myproc>
  acquire(&icache.lock);
80101e8f:	83 ec 0c             	sub    $0xc,%esp
80101e92:	89 df                	mov    %ebx,%edi
    ip = idup(myproc()->cwd);
80101e94:	8b 70 6c             	mov    0x6c(%eax),%esi
  acquire(&icache.lock);
80101e97:	68 00 1a 11 80       	push   $0x80111a00
80101e9c:	e8 bf 2c 00 00       	call   80104b60 <acquire>
  ip->ref++;
80101ea1:	83 46 08 01          	addl   $0x1,0x8(%esi)
  release(&icache.lock);
80101ea5:	c7 04 24 00 1a 11 80 	movl   $0x80111a00,(%esp)
80101eac:	e8 6f 2d 00 00       	call   80104c20 <release>
80101eb1:	83 c4 10             	add    $0x10,%esp
80101eb4:	eb 0d                	jmp    80101ec3 <namex+0x53>
80101eb6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101ebd:	8d 76 00             	lea    0x0(%esi),%esi
    path++;
80101ec0:	83 c7 01             	add    $0x1,%edi
  while(*path == '/')
80101ec3:	0f b6 07             	movzbl (%edi),%eax
80101ec6:	3c 2f                	cmp    $0x2f,%al
80101ec8:	74 f6                	je     80101ec0 <namex+0x50>
  if(*path == 0)
80101eca:	84 c0                	test   %al,%al
80101ecc:	0f 84 ee 00 00 00    	je     80101fc0 <namex+0x150>
  while(*path != '/' && *path != 0)
80101ed2:	0f b6 07             	movzbl (%edi),%eax
80101ed5:	84 c0                	test   %al,%al
80101ed7:	0f 84 fb 00 00 00    	je     80101fd8 <namex+0x168>
80101edd:	89 fb                	mov    %edi,%ebx
80101edf:	3c 2f                	cmp    $0x2f,%al
80101ee1:	0f 84 f1 00 00 00    	je     80101fd8 <namex+0x168>
80101ee7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101eee:	66 90                	xchg   %ax,%ax
80101ef0:	0f b6 43 01          	movzbl 0x1(%ebx),%eax
    path++;
80101ef4:	83 c3 01             	add    $0x1,%ebx
  while(*path != '/' && *path != 0)
80101ef7:	3c 2f                	cmp    $0x2f,%al
80101ef9:	74 04                	je     80101eff <namex+0x8f>
80101efb:	84 c0                	test   %al,%al
80101efd:	75 f1                	jne    80101ef0 <namex+0x80>
  len = path - s;
80101eff:	89 d8                	mov    %ebx,%eax
80101f01:	29 f8                	sub    %edi,%eax
  if(len >= DIRSIZ)
80101f03:	83 f8 0d             	cmp    $0xd,%eax
80101f06:	0f 8e 84 00 00 00    	jle    80101f90 <namex+0x120>
    memmove(name, s, DIRSIZ);
80101f0c:	83 ec 04             	sub    $0x4,%esp
80101f0f:	6a 0e                	push   $0xe
80101f11:	57                   	push   %edi
    path++;
80101f12:	89 df                	mov    %ebx,%edi
    memmove(name, s, DIRSIZ);
80101f14:	ff 75 e4             	pushl  -0x1c(%ebp)
80101f17:	e8 f4 2d 00 00       	call   80104d10 <memmove>
80101f1c:	83 c4 10             	add    $0x10,%esp
  while(*path == '/')
80101f1f:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80101f22:	75 0c                	jne    80101f30 <namex+0xc0>
80101f24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80101f28:	83 c7 01             	add    $0x1,%edi
  while(*path == '/')
80101f2b:	80 3f 2f             	cmpb   $0x2f,(%edi)
80101f2e:	74 f8                	je     80101f28 <namex+0xb8>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
80101f30:	83 ec 0c             	sub    $0xc,%esp
80101f33:	56                   	push   %esi
80101f34:	e8 27 f9 ff ff       	call   80101860 <ilock>
    if(ip->type != T_DIR){
80101f39:	83 c4 10             	add    $0x10,%esp
80101f3c:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101f41:	0f 85 a1 00 00 00    	jne    80101fe8 <namex+0x178>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
80101f47:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101f4a:	85 d2                	test   %edx,%edx
80101f4c:	74 09                	je     80101f57 <namex+0xe7>
80101f4e:	80 3f 00             	cmpb   $0x0,(%edi)
80101f51:	0f 84 d9 00 00 00    	je     80102030 <namex+0x1c0>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80101f57:	83 ec 04             	sub    $0x4,%esp
80101f5a:	6a 00                	push   $0x0
80101f5c:	ff 75 e4             	pushl  -0x1c(%ebp)
80101f5f:	56                   	push   %esi
80101f60:	e8 4b fe ff ff       	call   80101db0 <dirlookup>
80101f65:	83 c4 10             	add    $0x10,%esp
80101f68:	89 c3                	mov    %eax,%ebx
80101f6a:	85 c0                	test   %eax,%eax
80101f6c:	74 7a                	je     80101fe8 <namex+0x178>
  iunlock(ip);
80101f6e:	83 ec 0c             	sub    $0xc,%esp
80101f71:	56                   	push   %esi
80101f72:	e8 c9 f9 ff ff       	call   80101940 <iunlock>
  iput(ip);
80101f77:	89 34 24             	mov    %esi,(%esp)
80101f7a:	89 de                	mov    %ebx,%esi
80101f7c:	e8 0f fa ff ff       	call   80101990 <iput>
80101f81:	83 c4 10             	add    $0x10,%esp
80101f84:	e9 3a ff ff ff       	jmp    80101ec3 <namex+0x53>
80101f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101f90:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101f93:	8d 0c 02             	lea    (%edx,%eax,1),%ecx
80101f96:	89 4d dc             	mov    %ecx,-0x24(%ebp)
    memmove(name, s, len);
80101f99:	83 ec 04             	sub    $0x4,%esp
80101f9c:	50                   	push   %eax
80101f9d:	57                   	push   %edi
    name[len] = 0;
80101f9e:	89 df                	mov    %ebx,%edi
    memmove(name, s, len);
80101fa0:	ff 75 e4             	pushl  -0x1c(%ebp)
80101fa3:	e8 68 2d 00 00       	call   80104d10 <memmove>
    name[len] = 0;
80101fa8:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101fab:	83 c4 10             	add    $0x10,%esp
80101fae:	c6 00 00             	movb   $0x0,(%eax)
80101fb1:	e9 69 ff ff ff       	jmp    80101f1f <namex+0xaf>
80101fb6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101fbd:	8d 76 00             	lea    0x0(%esi),%esi
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80101fc0:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101fc3:	85 c0                	test   %eax,%eax
80101fc5:	0f 85 85 00 00 00    	jne    80102050 <namex+0x1e0>
    iput(ip);
    return 0;
  }
  return ip;
}
80101fcb:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101fce:	89 f0                	mov    %esi,%eax
80101fd0:	5b                   	pop    %ebx
80101fd1:	5e                   	pop    %esi
80101fd2:	5f                   	pop    %edi
80101fd3:	5d                   	pop    %ebp
80101fd4:	c3                   	ret    
80101fd5:	8d 76 00             	lea    0x0(%esi),%esi
  while(*path != '/' && *path != 0)
80101fd8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101fdb:	89 fb                	mov    %edi,%ebx
80101fdd:	89 45 dc             	mov    %eax,-0x24(%ebp)
80101fe0:	31 c0                	xor    %eax,%eax
80101fe2:	eb b5                	jmp    80101f99 <namex+0x129>
80101fe4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  iunlock(ip);
80101fe8:	83 ec 0c             	sub    $0xc,%esp
80101feb:	56                   	push   %esi
80101fec:	e8 4f f9 ff ff       	call   80101940 <iunlock>
  iput(ip);
80101ff1:	89 34 24             	mov    %esi,(%esp)
      return 0;
80101ff4:	31 f6                	xor    %esi,%esi
  iput(ip);
80101ff6:	e8 95 f9 ff ff       	call   80101990 <iput>
      return 0;
80101ffb:	83 c4 10             	add    $0x10,%esp
}
80101ffe:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102001:	89 f0                	mov    %esi,%eax
80102003:	5b                   	pop    %ebx
80102004:	5e                   	pop    %esi
80102005:	5f                   	pop    %edi
80102006:	5d                   	pop    %ebp
80102007:	c3                   	ret    
80102008:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010200f:	90                   	nop
    ip = iget(ROOTDEV, ROOTINO);
80102010:	ba 01 00 00 00       	mov    $0x1,%edx
80102015:	b8 01 00 00 00       	mov    $0x1,%eax
8010201a:	89 df                	mov    %ebx,%edi
8010201c:	e8 1f f4 ff ff       	call   80101440 <iget>
80102021:	89 c6                	mov    %eax,%esi
80102023:	e9 9b fe ff ff       	jmp    80101ec3 <namex+0x53>
80102028:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010202f:	90                   	nop
      iunlock(ip);
80102030:	83 ec 0c             	sub    $0xc,%esp
80102033:	56                   	push   %esi
80102034:	e8 07 f9 ff ff       	call   80101940 <iunlock>
      return ip;
80102039:	83 c4 10             	add    $0x10,%esp
}
8010203c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010203f:	89 f0                	mov    %esi,%eax
80102041:	5b                   	pop    %ebx
80102042:	5e                   	pop    %esi
80102043:	5f                   	pop    %edi
80102044:	5d                   	pop    %ebp
80102045:	c3                   	ret    
80102046:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010204d:	8d 76 00             	lea    0x0(%esi),%esi
    iput(ip);
80102050:	83 ec 0c             	sub    $0xc,%esp
80102053:	56                   	push   %esi
    return 0;
80102054:	31 f6                	xor    %esi,%esi
    iput(ip);
80102056:	e8 35 f9 ff ff       	call   80101990 <iput>
    return 0;
8010205b:	83 c4 10             	add    $0x10,%esp
8010205e:	e9 68 ff ff ff       	jmp    80101fcb <namex+0x15b>
80102063:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010206a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102070 <dirlink>:
{
80102070:	f3 0f 1e fb          	endbr32 
80102074:	55                   	push   %ebp
80102075:	89 e5                	mov    %esp,%ebp
80102077:	57                   	push   %edi
80102078:	56                   	push   %esi
80102079:	53                   	push   %ebx
8010207a:	83 ec 20             	sub    $0x20,%esp
8010207d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((ip = dirlookup(dp, name, 0)) != 0){
80102080:	6a 00                	push   $0x0
80102082:	ff 75 0c             	pushl  0xc(%ebp)
80102085:	53                   	push   %ebx
80102086:	e8 25 fd ff ff       	call   80101db0 <dirlookup>
8010208b:	83 c4 10             	add    $0x10,%esp
8010208e:	85 c0                	test   %eax,%eax
80102090:	75 6b                	jne    801020fd <dirlink+0x8d>
  for(off = 0; off < dp->size; off += sizeof(de)){
80102092:	8b 7b 58             	mov    0x58(%ebx),%edi
80102095:	8d 75 d8             	lea    -0x28(%ebp),%esi
80102098:	85 ff                	test   %edi,%edi
8010209a:	74 2d                	je     801020c9 <dirlink+0x59>
8010209c:	31 ff                	xor    %edi,%edi
8010209e:	8d 75 d8             	lea    -0x28(%ebp),%esi
801020a1:	eb 0d                	jmp    801020b0 <dirlink+0x40>
801020a3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801020a7:	90                   	nop
801020a8:	83 c7 10             	add    $0x10,%edi
801020ab:	3b 7b 58             	cmp    0x58(%ebx),%edi
801020ae:	73 19                	jae    801020c9 <dirlink+0x59>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801020b0:	6a 10                	push   $0x10
801020b2:	57                   	push   %edi
801020b3:	56                   	push   %esi
801020b4:	53                   	push   %ebx
801020b5:	e8 a6 fa ff ff       	call   80101b60 <readi>
801020ba:	83 c4 10             	add    $0x10,%esp
801020bd:	83 f8 10             	cmp    $0x10,%eax
801020c0:	75 4e                	jne    80102110 <dirlink+0xa0>
    if(de.inum == 0)
801020c2:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
801020c7:	75 df                	jne    801020a8 <dirlink+0x38>
  strncpy(de.name, name, DIRSIZ);
801020c9:	83 ec 04             	sub    $0x4,%esp
801020cc:	8d 45 da             	lea    -0x26(%ebp),%eax
801020cf:	6a 0e                	push   $0xe
801020d1:	ff 75 0c             	pushl  0xc(%ebp)
801020d4:	50                   	push   %eax
801020d5:	e8 f6 2c 00 00       	call   80104dd0 <strncpy>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801020da:	6a 10                	push   $0x10
  de.inum = inum;
801020dc:	8b 45 10             	mov    0x10(%ebp),%eax
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801020df:	57                   	push   %edi
801020e0:	56                   	push   %esi
801020e1:	53                   	push   %ebx
  de.inum = inum;
801020e2:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801020e6:	e8 75 fb ff ff       	call   80101c60 <writei>
801020eb:	83 c4 20             	add    $0x20,%esp
801020ee:	83 f8 10             	cmp    $0x10,%eax
801020f1:	75 2a                	jne    8010211d <dirlink+0xad>
  return 0;
801020f3:	31 c0                	xor    %eax,%eax
}
801020f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801020f8:	5b                   	pop    %ebx
801020f9:	5e                   	pop    %esi
801020fa:	5f                   	pop    %edi
801020fb:	5d                   	pop    %ebp
801020fc:	c3                   	ret    
    iput(ip);
801020fd:	83 ec 0c             	sub    $0xc,%esp
80102100:	50                   	push   %eax
80102101:	e8 8a f8 ff ff       	call   80101990 <iput>
    return -1;
80102106:	83 c4 10             	add    $0x10,%esp
80102109:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010210e:	eb e5                	jmp    801020f5 <dirlink+0x85>
      panic("dirlink read");
80102110:	83 ec 0c             	sub    $0xc,%esp
80102113:	68 c8 78 10 80       	push   $0x801078c8
80102118:	e8 73 e3 ff ff       	call   80100490 <panic>
    panic("dirlink");
8010211d:	83 ec 0c             	sub    $0xc,%esp
80102120:	68 26 7f 10 80       	push   $0x80107f26
80102125:	e8 66 e3 ff ff       	call   80100490 <panic>
8010212a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102130 <namei>:

struct inode*
namei(char *path)
{
80102130:	f3 0f 1e fb          	endbr32 
80102134:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102135:	31 d2                	xor    %edx,%edx
{
80102137:	89 e5                	mov    %esp,%ebp
80102139:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 0, name);
8010213c:	8b 45 08             	mov    0x8(%ebp),%eax
8010213f:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80102142:	e8 29 fd ff ff       	call   80101e70 <namex>
}
80102147:	c9                   	leave  
80102148:	c3                   	ret    
80102149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102150 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102150:	f3 0f 1e fb          	endbr32 
80102154:	55                   	push   %ebp
  return namex(path, 1, name);
80102155:	ba 01 00 00 00       	mov    $0x1,%edx
{
8010215a:	89 e5                	mov    %esp,%ebp
  return namex(path, 1, name);
8010215c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010215f:	8b 45 08             	mov    0x8(%ebp),%eax
}
80102162:	5d                   	pop    %ebp
  return namex(path, 1, name);
80102163:	e9 08 fd ff ff       	jmp    80101e70 <namex>
80102168:	66 90                	xchg   %ax,%ax
8010216a:	66 90                	xchg   %ax,%ax
8010216c:	66 90                	xchg   %ax,%ax
8010216e:	66 90                	xchg   %ax,%ax

80102170 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80102170:	55                   	push   %ebp
80102171:	89 e5                	mov    %esp,%ebp
80102173:	57                   	push   %edi
80102174:	56                   	push   %esi
80102175:	53                   	push   %ebx
80102176:	83 ec 0c             	sub    $0xc,%esp
  if(b == 0)
80102179:	85 c0                	test   %eax,%eax
8010217b:	0f 84 b4 00 00 00    	je     80102235 <idestart+0xc5>
    panic("idestart");
  if(b->blockno >= FSSIZE)
80102181:	8b 70 08             	mov    0x8(%eax),%esi
80102184:	89 c3                	mov    %eax,%ebx
80102186:	81 fe 9f 0f 00 00    	cmp    $0xf9f,%esi
8010218c:	0f 87 96 00 00 00    	ja     80102228 <idestart+0xb8>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102192:	b9 f7 01 00 00       	mov    $0x1f7,%ecx
80102197:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010219e:	66 90                	xchg   %ax,%ax
801021a0:	89 ca                	mov    %ecx,%edx
801021a2:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801021a3:	83 e0 c0             	and    $0xffffffc0,%eax
801021a6:	3c 40                	cmp    $0x40,%al
801021a8:	75 f6                	jne    801021a0 <idestart+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801021aa:	31 ff                	xor    %edi,%edi
801021ac:	ba f6 03 00 00       	mov    $0x3f6,%edx
801021b1:	89 f8                	mov    %edi,%eax
801021b3:	ee                   	out    %al,(%dx)
801021b4:	b8 01 00 00 00       	mov    $0x1,%eax
801021b9:	ba f2 01 00 00       	mov    $0x1f2,%edx
801021be:	ee                   	out    %al,(%dx)
801021bf:	ba f3 01 00 00       	mov    $0x1f3,%edx
801021c4:	89 f0                	mov    %esi,%eax
801021c6:	ee                   	out    %al,(%dx)

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
801021c7:	89 f0                	mov    %esi,%eax
801021c9:	ba f4 01 00 00       	mov    $0x1f4,%edx
801021ce:	c1 f8 08             	sar    $0x8,%eax
801021d1:	ee                   	out    %al,(%dx)
801021d2:	ba f5 01 00 00       	mov    $0x1f5,%edx
801021d7:	89 f8                	mov    %edi,%eax
801021d9:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
801021da:	0f b6 43 04          	movzbl 0x4(%ebx),%eax
801021de:	ba f6 01 00 00       	mov    $0x1f6,%edx
801021e3:	c1 e0 04             	shl    $0x4,%eax
801021e6:	83 e0 10             	and    $0x10,%eax
801021e9:	83 c8 e0             	or     $0xffffffe0,%eax
801021ec:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
801021ed:	f6 03 04             	testb  $0x4,(%ebx)
801021f0:	75 16                	jne    80102208 <idestart+0x98>
801021f2:	b8 20 00 00 00       	mov    $0x20,%eax
801021f7:	89 ca                	mov    %ecx,%edx
801021f9:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
801021fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
801021fd:	5b                   	pop    %ebx
801021fe:	5e                   	pop    %esi
801021ff:	5f                   	pop    %edi
80102200:	5d                   	pop    %ebp
80102201:	c3                   	ret    
80102202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80102208:	b8 30 00 00 00       	mov    $0x30,%eax
8010220d:	89 ca                	mov    %ecx,%edx
8010220f:	ee                   	out    %al,(%dx)
  asm volatile("cld; rep outsl" :
80102210:	b9 80 00 00 00       	mov    $0x80,%ecx
    outsl(0x1f0, b->data, BSIZE/4);
80102215:	8d 73 5c             	lea    0x5c(%ebx),%esi
80102218:	ba f0 01 00 00       	mov    $0x1f0,%edx
8010221d:	fc                   	cld    
8010221e:	f3 6f                	rep outsl %ds:(%esi),(%dx)
}
80102220:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102223:	5b                   	pop    %ebx
80102224:	5e                   	pop    %esi
80102225:	5f                   	pop    %edi
80102226:	5d                   	pop    %ebp
80102227:	c3                   	ret    
    panic("incorrect blockno");
80102228:	83 ec 0c             	sub    $0xc,%esp
8010222b:	68 34 79 10 80       	push   $0x80107934
80102230:	e8 5b e2 ff ff       	call   80100490 <panic>
    panic("idestart");
80102235:	83 ec 0c             	sub    $0xc,%esp
80102238:	68 2b 79 10 80       	push   $0x8010792b
8010223d:	e8 4e e2 ff ff       	call   80100490 <panic>
80102242:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102250 <ideinit>:
{
80102250:	f3 0f 1e fb          	endbr32 
80102254:	55                   	push   %ebp
80102255:	89 e5                	mov    %esp,%ebp
80102257:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
8010225a:	68 46 79 10 80       	push   $0x80107946
8010225f:	68 80 b5 10 80       	push   $0x8010b580
80102264:	e8 77 27 00 00       	call   801049e0 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80102269:	58                   	pop    %eax
8010226a:	a1 40 3d 11 80       	mov    0x80113d40,%eax
8010226f:	5a                   	pop    %edx
80102270:	83 e8 01             	sub    $0x1,%eax
80102273:	50                   	push   %eax
80102274:	6a 0e                	push   $0xe
80102276:	e8 b5 02 00 00       	call   80102530 <ioapicenable>
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
8010227b:	83 c4 10             	add    $0x10,%esp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010227e:	ba f7 01 00 00       	mov    $0x1f7,%edx
80102283:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102287:	90                   	nop
80102288:	ec                   	in     (%dx),%al
80102289:	83 e0 c0             	and    $0xffffffc0,%eax
8010228c:	3c 40                	cmp    $0x40,%al
8010228e:	75 f8                	jne    80102288 <ideinit+0x38>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102290:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
80102295:	ba f6 01 00 00       	mov    $0x1f6,%edx
8010229a:	ee                   	out    %al,(%dx)
8010229b:	b9 e8 03 00 00       	mov    $0x3e8,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801022a0:	ba f7 01 00 00       	mov    $0x1f7,%edx
801022a5:	eb 0e                	jmp    801022b5 <ideinit+0x65>
801022a7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801022ae:	66 90                	xchg   %ax,%ax
  for(i=0; i<1000; i++){
801022b0:	83 e9 01             	sub    $0x1,%ecx
801022b3:	74 0f                	je     801022c4 <ideinit+0x74>
801022b5:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
801022b6:	84 c0                	test   %al,%al
801022b8:	74 f6                	je     801022b0 <ideinit+0x60>
      havedisk1 = 1;
801022ba:	c7 05 60 b5 10 80 01 	movl   $0x1,0x8010b560
801022c1:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801022c4:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
801022c9:	ba f6 01 00 00       	mov    $0x1f6,%edx
801022ce:	ee                   	out    %al,(%dx)
}
801022cf:	c9                   	leave  
801022d0:	c3                   	ret    
801022d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801022d8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801022df:	90                   	nop

801022e0 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
801022e0:	f3 0f 1e fb          	endbr32 
801022e4:	55                   	push   %ebp
801022e5:	89 e5                	mov    %esp,%ebp
801022e7:	57                   	push   %edi
801022e8:	56                   	push   %esi
801022e9:	53                   	push   %ebx
801022ea:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
801022ed:	68 80 b5 10 80       	push   $0x8010b580
801022f2:	e8 69 28 00 00       	call   80104b60 <acquire>

  if((b = idequeue) == 0){
801022f7:	8b 1d 64 b5 10 80    	mov    0x8010b564,%ebx
801022fd:	83 c4 10             	add    $0x10,%esp
80102300:	85 db                	test   %ebx,%ebx
80102302:	74 5f                	je     80102363 <ideintr+0x83>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80102304:	8b 43 58             	mov    0x58(%ebx),%eax
80102307:	a3 64 b5 10 80       	mov    %eax,0x8010b564

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
8010230c:	8b 33                	mov    (%ebx),%esi
8010230e:	f7 c6 04 00 00 00    	test   $0x4,%esi
80102314:	75 2b                	jne    80102341 <ideintr+0x61>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102316:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010231b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010231f:	90                   	nop
80102320:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102321:	89 c1                	mov    %eax,%ecx
80102323:	83 e1 c0             	and    $0xffffffc0,%ecx
80102326:	80 f9 40             	cmp    $0x40,%cl
80102329:	75 f5                	jne    80102320 <ideintr+0x40>
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010232b:	a8 21                	test   $0x21,%al
8010232d:	75 12                	jne    80102341 <ideintr+0x61>
    insl(0x1f0, b->data, BSIZE/4);
8010232f:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80102332:	b9 80 00 00 00       	mov    $0x80,%ecx
80102337:	ba f0 01 00 00       	mov    $0x1f0,%edx
8010233c:	fc                   	cld    
8010233d:	f3 6d                	rep insl (%dx),%es:(%edi)
8010233f:	8b 33                	mov    (%ebx),%esi

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
  b->flags &= ~B_DIRTY;
80102341:	83 e6 fb             	and    $0xfffffffb,%esi
  wakeup(b);
80102344:	83 ec 0c             	sub    $0xc,%esp
  b->flags &= ~B_DIRTY;
80102347:	83 ce 02             	or     $0x2,%esi
8010234a:	89 33                	mov    %esi,(%ebx)
  wakeup(b);
8010234c:	53                   	push   %ebx
8010234d:	e8 3e 23 00 00       	call   80104690 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80102352:	a1 64 b5 10 80       	mov    0x8010b564,%eax
80102357:	83 c4 10             	add    $0x10,%esp
8010235a:	85 c0                	test   %eax,%eax
8010235c:	74 05                	je     80102363 <ideintr+0x83>
    idestart(idequeue);
8010235e:	e8 0d fe ff ff       	call   80102170 <idestart>
    release(&idelock);
80102363:	83 ec 0c             	sub    $0xc,%esp
80102366:	68 80 b5 10 80       	push   $0x8010b580
8010236b:	e8 b0 28 00 00       	call   80104c20 <release>

  release(&idelock);
}
80102370:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102373:	5b                   	pop    %ebx
80102374:	5e                   	pop    %esi
80102375:	5f                   	pop    %edi
80102376:	5d                   	pop    %ebp
80102377:	c3                   	ret    
80102378:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010237f:	90                   	nop

80102380 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80102380:	f3 0f 1e fb          	endbr32 
80102384:	55                   	push   %ebp
80102385:	89 e5                	mov    %esp,%ebp
80102387:	53                   	push   %ebx
80102388:	83 ec 10             	sub    $0x10,%esp
8010238b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;
  //cprintf("iderw enetered\n");
  if(!holdingsleep(&b->lock))
8010238e:	8d 43 0c             	lea    0xc(%ebx),%eax
80102391:	50                   	push   %eax
80102392:	e8 e9 25 00 00       	call   80104980 <holdingsleep>
80102397:	83 c4 10             	add    $0x10,%esp
8010239a:	85 c0                	test   %eax,%eax
8010239c:	0f 84 cf 00 00 00    	je     80102471 <iderw+0xf1>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
801023a2:	8b 03                	mov    (%ebx),%eax
801023a4:	83 e0 06             	and    $0x6,%eax
801023a7:	83 f8 02             	cmp    $0x2,%eax
801023aa:	0f 84 b4 00 00 00    	je     80102464 <iderw+0xe4>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
801023b0:	8b 53 04             	mov    0x4(%ebx),%edx
801023b3:	85 d2                	test   %edx,%edx
801023b5:	74 0d                	je     801023c4 <iderw+0x44>
801023b7:	a1 60 b5 10 80       	mov    0x8010b560,%eax
801023bc:	85 c0                	test   %eax,%eax
801023be:	0f 84 93 00 00 00    	je     80102457 <iderw+0xd7>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
801023c4:	83 ec 0c             	sub    $0xc,%esp
801023c7:	68 80 b5 10 80       	push   $0x8010b580
801023cc:	e8 8f 27 00 00       	call   80104b60 <acquire>
  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801023d1:	a1 64 b5 10 80       	mov    0x8010b564,%eax
  b->qnext = 0;
801023d6:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801023dd:	83 c4 10             	add    $0x10,%esp
801023e0:	85 c0                	test   %eax,%eax
801023e2:	74 6c                	je     80102450 <iderw+0xd0>
801023e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801023e8:	89 c2                	mov    %eax,%edx
801023ea:	8b 40 58             	mov    0x58(%eax),%eax
801023ed:	85 c0                	test   %eax,%eax
801023ef:	75 f7                	jne    801023e8 <iderw+0x68>
801023f1:	83 c2 58             	add    $0x58,%edx
    ;
  *pp = b;
801023f4:	89 1a                	mov    %ebx,(%edx)
  // Start disk if necessary.
  if(idequeue == b)
801023f6:	39 1d 64 b5 10 80    	cmp    %ebx,0x8010b564
801023fc:	74 42                	je     80102440 <iderw+0xc0>
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801023fe:	8b 03                	mov    (%ebx),%eax
80102400:	83 e0 06             	and    $0x6,%eax
80102403:	83 f8 02             	cmp    $0x2,%eax
80102406:	74 23                	je     8010242b <iderw+0xab>
80102408:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010240f:	90                   	nop
    sleep(b, &idelock);
80102410:	83 ec 08             	sub    $0x8,%esp
80102413:	68 80 b5 10 80       	push   $0x8010b580
80102418:	53                   	push   %ebx
80102419:	e8 b2 20 00 00       	call   801044d0 <sleep>
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010241e:	8b 03                	mov    (%ebx),%eax
80102420:	83 c4 10             	add    $0x10,%esp
80102423:	83 e0 06             	and    $0x6,%eax
80102426:	83 f8 02             	cmp    $0x2,%eax
80102429:	75 e5                	jne    80102410 <iderw+0x90>
  }

  release(&idelock);
8010242b:	c7 45 08 80 b5 10 80 	movl   $0x8010b580,0x8(%ebp)
}
80102432:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102435:	c9                   	leave  
  release(&idelock);
80102436:	e9 e5 27 00 00       	jmp    80104c20 <release>
8010243b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010243f:	90                   	nop
    idestart(b);
80102440:	89 d8                	mov    %ebx,%eax
80102442:	e8 29 fd ff ff       	call   80102170 <idestart>
80102447:	eb b5                	jmp    801023fe <iderw+0x7e>
80102449:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102450:	ba 64 b5 10 80       	mov    $0x8010b564,%edx
80102455:	eb 9d                	jmp    801023f4 <iderw+0x74>
    panic("iderw: ide disk 1 not present");
80102457:	83 ec 0c             	sub    $0xc,%esp
8010245a:	68 75 79 10 80       	push   $0x80107975
8010245f:	e8 2c e0 ff ff       	call   80100490 <panic>
    panic("iderw: nothing to do");
80102464:	83 ec 0c             	sub    $0xc,%esp
80102467:	68 60 79 10 80       	push   $0x80107960
8010246c:	e8 1f e0 ff ff       	call   80100490 <panic>
    panic("iderw: buf not locked");
80102471:	83 ec 0c             	sub    $0xc,%esp
80102474:	68 4a 79 10 80       	push   $0x8010794a
80102479:	e8 12 e0 ff ff       	call   80100490 <panic>
8010247e:	66 90                	xchg   %ax,%ax

80102480 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
80102480:	f3 0f 1e fb          	endbr32 
80102484:	55                   	push   %ebp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102485:	c7 05 54 36 11 80 00 	movl   $0xfec00000,0x80113654
8010248c:	00 c0 fe 
{
8010248f:	89 e5                	mov    %esp,%ebp
80102491:	56                   	push   %esi
80102492:	53                   	push   %ebx
  ioapic->reg = reg;
80102493:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
8010249a:	00 00 00 
  return ioapic->data;
8010249d:	8b 15 54 36 11 80    	mov    0x80113654,%edx
801024a3:	8b 72 10             	mov    0x10(%edx),%esi
  ioapic->reg = reg;
801024a6:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
  return ioapic->data;
801024ac:	8b 0d 54 36 11 80    	mov    0x80113654,%ecx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
801024b2:	0f b6 15 a0 37 11 80 	movzbl 0x801137a0,%edx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
801024b9:	c1 ee 10             	shr    $0x10,%esi
801024bc:	89 f0                	mov    %esi,%eax
801024be:	0f b6 f0             	movzbl %al,%esi
  return ioapic->data;
801024c1:	8b 41 10             	mov    0x10(%ecx),%eax
  id = ioapicread(REG_ID) >> 24;
801024c4:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
801024c7:	39 c2                	cmp    %eax,%edx
801024c9:	74 16                	je     801024e1 <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
801024cb:	83 ec 0c             	sub    $0xc,%esp
801024ce:	68 94 79 10 80       	push   $0x80107994
801024d3:	e8 d8 e2 ff ff       	call   801007b0 <cprintf>
801024d8:	8b 0d 54 36 11 80    	mov    0x80113654,%ecx
801024de:	83 c4 10             	add    $0x10,%esp
801024e1:	83 c6 21             	add    $0x21,%esi
{
801024e4:	ba 10 00 00 00       	mov    $0x10,%edx
801024e9:	b8 20 00 00 00       	mov    $0x20,%eax
801024ee:	66 90                	xchg   %ax,%ax
  ioapic->reg = reg;
801024f0:	89 11                	mov    %edx,(%ecx)

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801024f2:	89 c3                	mov    %eax,%ebx
  ioapic->data = data;
801024f4:	8b 0d 54 36 11 80    	mov    0x80113654,%ecx
801024fa:	83 c0 01             	add    $0x1,%eax
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
801024fd:	81 cb 00 00 01 00    	or     $0x10000,%ebx
  ioapic->data = data;
80102503:	89 59 10             	mov    %ebx,0x10(%ecx)
  ioapic->reg = reg;
80102506:	8d 5a 01             	lea    0x1(%edx),%ebx
80102509:	83 c2 02             	add    $0x2,%edx
8010250c:	89 19                	mov    %ebx,(%ecx)
  ioapic->data = data;
8010250e:	8b 0d 54 36 11 80    	mov    0x80113654,%ecx
80102514:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  for(i = 0; i <= maxintr; i++){
8010251b:	39 f0                	cmp    %esi,%eax
8010251d:	75 d1                	jne    801024f0 <ioapicinit+0x70>
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010251f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102522:	5b                   	pop    %ebx
80102523:	5e                   	pop    %esi
80102524:	5d                   	pop    %ebp
80102525:	c3                   	ret    
80102526:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010252d:	8d 76 00             	lea    0x0(%esi),%esi

80102530 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102530:	f3 0f 1e fb          	endbr32 
80102534:	55                   	push   %ebp
  ioapic->reg = reg;
80102535:	8b 0d 54 36 11 80    	mov    0x80113654,%ecx
{
8010253b:	89 e5                	mov    %esp,%ebp
8010253d:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102540:	8d 50 20             	lea    0x20(%eax),%edx
80102543:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
  ioapic->reg = reg;
80102547:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80102549:	8b 0d 54 36 11 80    	mov    0x80113654,%ecx
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010254f:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
80102552:	89 51 10             	mov    %edx,0x10(%ecx)
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102555:	8b 55 0c             	mov    0xc(%ebp),%edx
  ioapic->reg = reg;
80102558:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
8010255a:	a1 54 36 11 80       	mov    0x80113654,%eax
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
8010255f:	c1 e2 18             	shl    $0x18,%edx
  ioapic->data = data;
80102562:	89 50 10             	mov    %edx,0x10(%eax)
}
80102565:	5d                   	pop    %ebp
80102566:	c3                   	ret    
80102567:	66 90                	xchg   %ax,%ax
80102569:	66 90                	xchg   %ax,%ax
8010256b:	66 90                	xchg   %ax,%ax
8010256d:	66 90                	xchg   %ax,%ax
8010256f:	90                   	nop

80102570 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102570:	f3 0f 1e fb          	endbr32 
80102574:	55                   	push   %ebp
80102575:	89 e5                	mov    %esp,%ebp
80102577:	53                   	push   %ebx
80102578:	83 ec 04             	sub    $0x4,%esp
8010257b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;
  // cprintf("kfree: The address is %x %x\n", v, end);

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
8010257e:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80102584:	0f 85 7e 00 00 00    	jne    80102608 <kfree+0x98>
8010258a:	81 fb 48 6f 11 80    	cmp    $0x80116f48,%ebx
80102590:	72 76                	jb     80102608 <kfree+0x98>
80102592:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80102598:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
8010259d:	77 69                	ja     80102608 <kfree+0x98>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
8010259f:	83 ec 04             	sub    $0x4,%esp
801025a2:	68 00 10 00 00       	push   $0x1000
801025a7:	6a 01                	push   $0x1
801025a9:	53                   	push   %ebx
801025aa:	e8 c1 26 00 00       	call   80104c70 <memset>

  if(kmem.use_lock)
801025af:	8b 15 94 36 11 80    	mov    0x80113694,%edx
801025b5:	83 c4 10             	add    $0x10,%esp
801025b8:	85 d2                	test   %edx,%edx
801025ba:	75 24                	jne    801025e0 <kfree+0x70>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
801025bc:	a1 9c 36 11 80       	mov    0x8011369c,%eax
801025c1:	89 03                	mov    %eax,(%ebx)
  kmem.num_free_pages+=1;
  kmem.freelist = r;
  if(kmem.use_lock)
801025c3:	a1 94 36 11 80       	mov    0x80113694,%eax
  kmem.num_free_pages+=1;
801025c8:	83 05 98 36 11 80 01 	addl   $0x1,0x80113698
  kmem.freelist = r;
801025cf:	89 1d 9c 36 11 80    	mov    %ebx,0x8011369c
  if(kmem.use_lock)
801025d5:	85 c0                	test   %eax,%eax
801025d7:	75 1f                	jne    801025f8 <kfree+0x88>
    release(&kmem.lock);
}
801025d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801025dc:	c9                   	leave  
801025dd:	c3                   	ret    
801025de:	66 90                	xchg   %ax,%ax
    acquire(&kmem.lock);
801025e0:	83 ec 0c             	sub    $0xc,%esp
801025e3:	68 60 36 11 80       	push   $0x80113660
801025e8:	e8 73 25 00 00       	call   80104b60 <acquire>
801025ed:	83 c4 10             	add    $0x10,%esp
801025f0:	eb ca                	jmp    801025bc <kfree+0x4c>
801025f2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    release(&kmem.lock);
801025f8:	c7 45 08 60 36 11 80 	movl   $0x80113660,0x8(%ebp)
}
801025ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102602:	c9                   	leave  
    release(&kmem.lock);
80102603:	e9 18 26 00 00       	jmp    80104c20 <release>
    panic("kfree");
80102608:	83 ec 0c             	sub    $0xc,%esp
8010260b:	68 c6 79 10 80       	push   $0x801079c6
80102610:	e8 7b de ff ff       	call   80100490 <panic>
80102615:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010261c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102620 <freerange>:
{
80102620:	f3 0f 1e fb          	endbr32 
80102624:	55                   	push   %ebp
80102625:	89 e5                	mov    %esp,%ebp
80102627:	56                   	push   %esi
  p = (char*)PGROUNDUP((uint)vstart);
80102628:	8b 45 08             	mov    0x8(%ebp),%eax
{
8010262b:	8b 75 0c             	mov    0xc(%ebp),%esi
8010262e:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
8010262f:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102635:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010263b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80102641:	39 de                	cmp    %ebx,%esi
80102643:	72 26                	jb     8010266b <freerange+0x4b>
80102645:	8d 76 00             	lea    0x0(%esi),%esi
    kfree(p);
80102648:	83 ec 0c             	sub    $0xc,%esp
8010264b:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102651:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
80102657:	50                   	push   %eax
80102658:	e8 13 ff ff ff       	call   80102570 <kfree>
    kmem.num_free_pages+=1;
8010265d:	83 05 98 36 11 80 01 	addl   $0x1,0x80113698
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102664:	83 c4 10             	add    $0x10,%esp
80102667:	39 f3                	cmp    %esi,%ebx
80102669:	76 dd                	jbe    80102648 <freerange+0x28>
}
8010266b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010266e:	5b                   	pop    %ebx
8010266f:	5e                   	pop    %esi
80102670:	5d                   	pop    %ebp
80102671:	c3                   	ret    
80102672:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102679:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102680 <kinit1>:
{
80102680:	f3 0f 1e fb          	endbr32 
80102684:	55                   	push   %ebp
80102685:	89 e5                	mov    %esp,%ebp
80102687:	56                   	push   %esi
80102688:	53                   	push   %ebx
80102689:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010268c:	8b 75 0c             	mov    0xc(%ebp),%esi
  p = (char*)PGROUNDUP((uint)vstart);
8010268f:	81 c3 ff 0f 00 00    	add    $0xfff,%ebx
  initlock(&kmem.lock, "kmem");
80102695:	83 ec 08             	sub    $0x8,%esp
  p = (char*)PGROUNDUP((uint)vstart);
80102698:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  initlock(&kmem.lock, "kmem");
8010269e:	68 cc 79 10 80       	push   $0x801079cc
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026a3:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  initlock(&kmem.lock, "kmem");
801026a9:	68 60 36 11 80       	push   $0x80113660
801026ae:	e8 2d 23 00 00       	call   801049e0 <initlock>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026b3:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
801026b6:	c7 05 94 36 11 80 00 	movl   $0x0,0x80113694
801026bd:	00 00 00 
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026c0:	39 de                	cmp    %ebx,%esi
801026c2:	72 27                	jb     801026eb <kinit1+0x6b>
801026c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
801026c8:	83 ec 0c             	sub    $0xc,%esp
801026cb:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026d1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
801026d7:	50                   	push   %eax
801026d8:	e8 93 fe ff ff       	call   80102570 <kfree>
    kmem.num_free_pages+=1;
801026dd:	83 05 98 36 11 80 01 	addl   $0x1,0x80113698
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801026e4:	83 c4 10             	add    $0x10,%esp
801026e7:	39 de                	cmp    %ebx,%esi
801026e9:	73 dd                	jae    801026c8 <kinit1+0x48>
}
801026eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
801026ee:	5b                   	pop    %ebx
801026ef:	5e                   	pop    %esi
801026f0:	5d                   	pop    %ebp
  swapinit();
801026f1:	e9 1a 0f 00 00       	jmp    80103610 <swapinit>
801026f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801026fd:	8d 76 00             	lea    0x0(%esi),%esi

80102700 <kinit2>:
{
80102700:	f3 0f 1e fb          	endbr32 
80102704:	55                   	push   %ebp
80102705:	89 e5                	mov    %esp,%ebp
80102707:	56                   	push   %esi
  p = (char*)PGROUNDUP((uint)vstart);
80102708:	8b 45 08             	mov    0x8(%ebp),%eax
{
8010270b:	8b 75 0c             	mov    0xc(%ebp),%esi
8010270e:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
8010270f:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102715:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010271b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80102721:	39 de                	cmp    %ebx,%esi
80102723:	72 26                	jb     8010274b <kinit2+0x4b>
80102725:	8d 76 00             	lea    0x0(%esi),%esi
    kfree(p);
80102728:	83 ec 0c             	sub    $0xc,%esp
8010272b:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102731:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
80102737:	50                   	push   %eax
80102738:	e8 33 fe ff ff       	call   80102570 <kfree>
    kmem.num_free_pages+=1;
8010273d:	83 05 98 36 11 80 01 	addl   $0x1,0x80113698
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102744:	83 c4 10             	add    $0x10,%esp
80102747:	39 de                	cmp    %ebx,%esi
80102749:	73 dd                	jae    80102728 <kinit2+0x28>
  kmem.use_lock = 1;
8010274b:	c7 05 94 36 11 80 01 	movl   $0x1,0x80113694
80102752:	00 00 00 
}
80102755:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102758:	5b                   	pop    %ebx
80102759:	5e                   	pop    %esi
8010275a:	5d                   	pop    %ebp
8010275b:	c3                   	ret    
8010275c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102760 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102760:	f3 0f 1e fb          	endbr32 
80102764:	55                   	push   %ebp
80102765:	89 e5                	mov    %esp,%ebp
80102767:	83 ec 18             	sub    $0x18,%esp
  //cprintf("Kalloc enetered\n");
  struct run *r;

  if(kmem.use_lock)
8010276a:	8b 0d 94 36 11 80    	mov    0x80113694,%ecx
80102770:	85 c9                	test   %ecx,%ecx
80102772:	0f 85 88 00 00 00    	jne    80102800 <kalloc+0xa0>
    acquire(&kmem.lock);
  //cprintf("Kalloc acquired lock\n");
  r = kmem.freelist;
80102778:	a1 9c 36 11 80       	mov    0x8011369c,%eax
  if(r)
8010277d:	85 c0                	test   %eax,%eax
8010277f:	74 31                	je     801027b2 <kalloc+0x52>
  {
    //cprintf("Entered if\n");
    // myproc()->rss += 1;
    kmem.freelist = r->next;
80102781:	8b 10                	mov    (%eax),%edx
    kmem.num_free_pages-=1;
80102783:	83 2d 98 36 11 80 01 	subl   $0x1,0x80113698
    kmem.freelist = r->next;
8010278a:	89 15 9c 36 11 80    	mov    %edx,0x8011369c

  if(kmem.use_lock)
    release(&kmem.lock);

  return (char*)r;
}
80102790:	c9                   	leave  
80102791:	c3                   	ret    
80102792:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(kmem.use_lock) // We modified this part
80102798:	8b 15 94 36 11 80    	mov    0x80113694,%edx
8010279e:	85 d2                	test   %edx,%edx
801027a0:	74 10                	je     801027b2 <kalloc+0x52>
      release(&kmem.lock);
801027a2:	83 ec 0c             	sub    $0xc,%esp
801027a5:	68 60 36 11 80       	push   $0x80113660
801027aa:	e8 71 24 00 00       	call   80104c20 <release>
801027af:	83 c4 10             	add    $0x10,%esp
    page_out();
801027b2:	e8 79 10 00 00       	call   80103830 <page_out>
    if(kmem.use_lock)
801027b7:	a1 94 36 11 80       	mov    0x80113694,%eax
801027bc:	85 c0                	test   %eax,%eax
801027be:	75 78                	jne    80102838 <kalloc+0xd8>
    r = kmem.freelist;
801027c0:	a1 9c 36 11 80       	mov    0x8011369c,%eax
    if(r)
801027c5:	85 c0                	test   %eax,%eax
801027c7:	0f 84 83 00 00 00    	je     80102850 <kalloc+0xf0>
      kmem.freelist = r->next;
801027cd:	8b 10                	mov    (%eax),%edx
      kmem.num_free_pages-=1;
801027cf:	83 2d 98 36 11 80 01 	subl   $0x1,0x80113698
      kmem.freelist = r->next;
801027d6:	89 15 9c 36 11 80    	mov    %edx,0x8011369c
      kmem.num_free_pages-=1;
801027dc:	8b 15 94 36 11 80    	mov    0x80113694,%edx
  if(kmem.use_lock)
801027e2:	85 d2                	test   %edx,%edx
801027e4:	74 aa                	je     80102790 <kalloc+0x30>
    release(&kmem.lock);
801027e6:	83 ec 0c             	sub    $0xc,%esp
801027e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801027ec:	68 60 36 11 80       	push   $0x80113660
801027f1:	e8 2a 24 00 00       	call   80104c20 <release>
  return (char*)r;
801027f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    release(&kmem.lock);
801027f9:	83 c4 10             	add    $0x10,%esp
}
801027fc:	c9                   	leave  
801027fd:	c3                   	ret    
801027fe:	66 90                	xchg   %ax,%ax
    acquire(&kmem.lock);
80102800:	83 ec 0c             	sub    $0xc,%esp
80102803:	68 60 36 11 80       	push   $0x80113660
80102808:	e8 53 23 00 00       	call   80104b60 <acquire>
  r = kmem.freelist;
8010280d:	a1 9c 36 11 80       	mov    0x8011369c,%eax
  if(r)
80102812:	83 c4 10             	add    $0x10,%esp
80102815:	85 c0                	test   %eax,%eax
80102817:	0f 84 7b ff ff ff    	je     80102798 <kalloc+0x38>
    kmem.freelist = r->next;
8010281d:	8b 08                	mov    (%eax),%ecx
8010281f:	8b 15 94 36 11 80    	mov    0x80113694,%edx
    kmem.num_free_pages-=1;
80102825:	83 2d 98 36 11 80 01 	subl   $0x1,0x80113698
    kmem.freelist = r->next;
8010282c:	89 0d 9c 36 11 80    	mov    %ecx,0x8011369c
    kmem.num_free_pages-=1;
80102832:	eb ae                	jmp    801027e2 <kalloc+0x82>
80102834:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      acquire(&kmem.lock);
80102838:	83 ec 0c             	sub    $0xc,%esp
8010283b:	68 60 36 11 80       	push   $0x80113660
80102840:	e8 1b 23 00 00       	call   80104b60 <acquire>
80102845:	83 c4 10             	add    $0x10,%esp
80102848:	e9 73 ff ff ff       	jmp    801027c0 <kalloc+0x60>
8010284d:	8d 76 00             	lea    0x0(%esi),%esi
      cprintf("ERROR\n");
80102850:	83 ec 0c             	sub    $0xc,%esp
80102853:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102856:	68 d1 79 10 80       	push   $0x801079d1
8010285b:	e8 50 df ff ff       	call   801007b0 <cprintf>
80102860:	8b 15 94 36 11 80    	mov    0x80113694,%edx
80102866:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102869:	83 c4 10             	add    $0x10,%esp
8010286c:	e9 71 ff ff ff       	jmp    801027e2 <kalloc+0x82>
80102871:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102878:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010287f:	90                   	nop

80102880 <num_of_FreePages>:
uint 
num_of_FreePages(void)
{
80102880:	f3 0f 1e fb          	endbr32 
80102884:	55                   	push   %ebp
80102885:	89 e5                	mov    %esp,%ebp
80102887:	53                   	push   %ebx
80102888:	83 ec 10             	sub    $0x10,%esp
  acquire(&kmem.lock);
8010288b:	68 60 36 11 80       	push   $0x80113660
80102890:	e8 cb 22 00 00       	call   80104b60 <acquire>

  uint num_free_pages = kmem.num_free_pages;
80102895:	8b 1d 98 36 11 80    	mov    0x80113698,%ebx
  
  release(&kmem.lock);
8010289b:	c7 04 24 60 36 11 80 	movl   $0x80113660,(%esp)
801028a2:	e8 79 23 00 00       	call   80104c20 <release>
  
  return num_free_pages;
}
801028a7:	89 d8                	mov    %ebx,%eax
801028a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801028ac:	c9                   	leave  
801028ad:	c3                   	ret    
801028ae:	66 90                	xchg   %ax,%ax

801028b0 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801028b0:	f3 0f 1e fb          	endbr32 
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801028b4:	ba 64 00 00 00       	mov    $0x64,%edx
801028b9:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
801028ba:	a8 01                	test   $0x1,%al
801028bc:	0f 84 be 00 00 00    	je     80102980 <kbdgetc+0xd0>
{
801028c2:	55                   	push   %ebp
801028c3:	ba 60 00 00 00       	mov    $0x60,%edx
801028c8:	89 e5                	mov    %esp,%ebp
801028ca:	53                   	push   %ebx
801028cb:	ec                   	in     (%dx),%al
  return data;
801028cc:	8b 1d b4 b5 10 80    	mov    0x8010b5b4,%ebx
    return -1;
  data = inb(KBDATAP);
801028d2:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
801028d5:	3c e0                	cmp    $0xe0,%al
801028d7:	74 57                	je     80102930 <kbdgetc+0x80>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
801028d9:	89 d9                	mov    %ebx,%ecx
801028db:	83 e1 40             	and    $0x40,%ecx
801028de:	84 c0                	test   %al,%al
801028e0:	78 5e                	js     80102940 <kbdgetc+0x90>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
801028e2:	85 c9                	test   %ecx,%ecx
801028e4:	74 09                	je     801028ef <kbdgetc+0x3f>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801028e6:	83 c8 80             	or     $0xffffff80,%eax
    shift &= ~E0ESC;
801028e9:	83 e3 bf             	and    $0xffffffbf,%ebx
    data |= 0x80;
801028ec:	0f b6 d0             	movzbl %al,%edx
  }

  shift |= shiftcode[data];
801028ef:	0f b6 8a 00 7b 10 80 	movzbl -0x7fef8500(%edx),%ecx
  shift ^= togglecode[data];
801028f6:	0f b6 82 00 7a 10 80 	movzbl -0x7fef8600(%edx),%eax
  shift |= shiftcode[data];
801028fd:	09 d9                	or     %ebx,%ecx
  shift ^= togglecode[data];
801028ff:	31 c1                	xor    %eax,%ecx
  c = charcode[shift & (CTL | SHIFT)][data];
80102901:	89 c8                	mov    %ecx,%eax
  shift ^= togglecode[data];
80102903:	89 0d b4 b5 10 80    	mov    %ecx,0x8010b5b4
  c = charcode[shift & (CTL | SHIFT)][data];
80102909:	83 e0 03             	and    $0x3,%eax
  if(shift & CAPSLOCK){
8010290c:	83 e1 08             	and    $0x8,%ecx
  c = charcode[shift & (CTL | SHIFT)][data];
8010290f:	8b 04 85 e0 79 10 80 	mov    -0x7fef8620(,%eax,4),%eax
80102916:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
8010291a:	74 0b                	je     80102927 <kbdgetc+0x77>
    if('a' <= c && c <= 'z')
8010291c:	8d 50 9f             	lea    -0x61(%eax),%edx
8010291f:	83 fa 19             	cmp    $0x19,%edx
80102922:	77 44                	ja     80102968 <kbdgetc+0xb8>
      c += 'A' - 'a';
80102924:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102927:	5b                   	pop    %ebx
80102928:	5d                   	pop    %ebp
80102929:	c3                   	ret    
8010292a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    shift |= E0ESC;
80102930:	83 cb 40             	or     $0x40,%ebx
    return 0;
80102933:	31 c0                	xor    %eax,%eax
    shift |= E0ESC;
80102935:	89 1d b4 b5 10 80    	mov    %ebx,0x8010b5b4
}
8010293b:	5b                   	pop    %ebx
8010293c:	5d                   	pop    %ebp
8010293d:	c3                   	ret    
8010293e:	66 90                	xchg   %ax,%ax
    data = (shift & E0ESC ? data : data & 0x7F);
80102940:	83 e0 7f             	and    $0x7f,%eax
80102943:	85 c9                	test   %ecx,%ecx
80102945:	0f 44 d0             	cmove  %eax,%edx
    return 0;
80102948:	31 c0                	xor    %eax,%eax
    shift &= ~(shiftcode[data] | E0ESC);
8010294a:	0f b6 8a 00 7b 10 80 	movzbl -0x7fef8500(%edx),%ecx
80102951:	83 c9 40             	or     $0x40,%ecx
80102954:	0f b6 c9             	movzbl %cl,%ecx
80102957:	f7 d1                	not    %ecx
80102959:	21 d9                	and    %ebx,%ecx
}
8010295b:	5b                   	pop    %ebx
8010295c:	5d                   	pop    %ebp
    shift &= ~(shiftcode[data] | E0ESC);
8010295d:	89 0d b4 b5 10 80    	mov    %ecx,0x8010b5b4
}
80102963:	c3                   	ret    
80102964:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    else if('A' <= c && c <= 'Z')
80102968:	8d 48 bf             	lea    -0x41(%eax),%ecx
      c += 'a' - 'A';
8010296b:	8d 50 20             	lea    0x20(%eax),%edx
}
8010296e:	5b                   	pop    %ebx
8010296f:	5d                   	pop    %ebp
      c += 'a' - 'A';
80102970:	83 f9 1a             	cmp    $0x1a,%ecx
80102973:	0f 42 c2             	cmovb  %edx,%eax
}
80102976:	c3                   	ret    
80102977:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010297e:	66 90                	xchg   %ax,%ax
    return -1;
80102980:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102985:	c3                   	ret    
80102986:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010298d:	8d 76 00             	lea    0x0(%esi),%esi

80102990 <kbdintr>:

void
kbdintr(void)
{
80102990:	f3 0f 1e fb          	endbr32 
80102994:	55                   	push   %ebp
80102995:	89 e5                	mov    %esp,%ebp
80102997:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
8010299a:	68 b0 28 10 80       	push   $0x801028b0
8010299f:	e8 bc df ff ff       	call   80100960 <consoleintr>
}
801029a4:	83 c4 10             	add    $0x10,%esp
801029a7:	c9                   	leave  
801029a8:	c3                   	ret    
801029a9:	66 90                	xchg   %ax,%ax
801029ab:	66 90                	xchg   %ax,%ax
801029ad:	66 90                	xchg   %ax,%ax
801029af:	90                   	nop

801029b0 <lapicinit>:
  lapic[ID];  // wait for write to finish, by reading
}

void
lapicinit(void)
{
801029b0:	f3 0f 1e fb          	endbr32 
  if(!lapic)
801029b4:	a1 a0 36 11 80       	mov    0x801136a0,%eax
801029b9:	85 c0                	test   %eax,%eax
801029bb:	0f 84 c7 00 00 00    	je     80102a88 <lapicinit+0xd8>
  lapic[index] = value;
801029c1:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
801029c8:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
801029cb:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029ce:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
801029d5:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801029d8:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029db:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
801029e2:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
801029e5:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029e8:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
801029ef:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
801029f2:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029f5:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
801029fc:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
801029ff:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102a02:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
80102a09:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102a0c:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102a0f:	8b 50 30             	mov    0x30(%eax),%edx
80102a12:	c1 ea 10             	shr    $0x10,%edx
80102a15:	81 e2 fc 00 00 00    	and    $0xfc,%edx
80102a1b:	75 73                	jne    80102a90 <lapicinit+0xe0>
  lapic[index] = value;
80102a1d:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
80102a24:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a27:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102a2a:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
80102a31:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a34:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102a37:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
80102a3e:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a41:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102a44:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102a4b:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a4e:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102a51:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
80102a58:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a5b:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102a5e:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
80102a65:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
80102a68:	8b 50 20             	mov    0x20(%eax),%edx
80102a6b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102a6f:	90                   	nop
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
80102a70:	8b 90 00 03 00 00    	mov    0x300(%eax),%edx
80102a76:	80 e6 10             	and    $0x10,%dh
80102a79:	75 f5                	jne    80102a70 <lapicinit+0xc0>
  lapic[index] = value;
80102a7b:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80102a82:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102a85:	8b 40 20             	mov    0x20(%eax),%eax
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102a88:	c3                   	ret    
80102a89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  lapic[index] = value;
80102a90:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
80102a97:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102a9a:	8b 50 20             	mov    0x20(%eax),%edx
}
80102a9d:	e9 7b ff ff ff       	jmp    80102a1d <lapicinit+0x6d>
80102aa2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102aa9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102ab0 <lapicid>:

int
lapicid(void)
{
80102ab0:	f3 0f 1e fb          	endbr32 
  if (!lapic)
80102ab4:	a1 a0 36 11 80       	mov    0x801136a0,%eax
80102ab9:	85 c0                	test   %eax,%eax
80102abb:	74 0b                	je     80102ac8 <lapicid+0x18>
    return 0;
  return lapic[ID] >> 24;
80102abd:	8b 40 20             	mov    0x20(%eax),%eax
80102ac0:	c1 e8 18             	shr    $0x18,%eax
80102ac3:	c3                   	ret    
80102ac4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return 0;
80102ac8:	31 c0                	xor    %eax,%eax
}
80102aca:	c3                   	ret    
80102acb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102acf:	90                   	nop

80102ad0 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
80102ad0:	f3 0f 1e fb          	endbr32 
  if(lapic)
80102ad4:	a1 a0 36 11 80       	mov    0x801136a0,%eax
80102ad9:	85 c0                	test   %eax,%eax
80102adb:	74 0d                	je     80102aea <lapiceoi+0x1a>
  lapic[index] = value;
80102add:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102ae4:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102ae7:	8b 40 20             	mov    0x20(%eax),%eax
    lapicw(EOI, 0);
}
80102aea:	c3                   	ret    
80102aeb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102aef:	90                   	nop

80102af0 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80102af0:	f3 0f 1e fb          	endbr32 
}
80102af4:	c3                   	ret    
80102af5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102afc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102b00 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102b00:	f3 0f 1e fb          	endbr32 
80102b04:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102b05:	b8 0f 00 00 00       	mov    $0xf,%eax
80102b0a:	ba 70 00 00 00       	mov    $0x70,%edx
80102b0f:	89 e5                	mov    %esp,%ebp
80102b11:	53                   	push   %ebx
80102b12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102b15:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102b18:	ee                   	out    %al,(%dx)
80102b19:	b8 0a 00 00 00       	mov    $0xa,%eax
80102b1e:	ba 71 00 00 00       	mov    $0x71,%edx
80102b23:	ee                   	out    %al,(%dx)
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
80102b24:	31 c0                	xor    %eax,%eax
  wrv[1] = addr >> 4;

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102b26:	c1 e3 18             	shl    $0x18,%ebx
  wrv[0] = 0;
80102b29:	66 a3 67 04 00 80    	mov    %ax,0x80000467
  wrv[1] = addr >> 4;
80102b2f:	89 c8                	mov    %ecx,%eax
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
80102b31:	c1 e9 0c             	shr    $0xc,%ecx
  lapicw(ICRHI, apicid<<24);
80102b34:	89 da                	mov    %ebx,%edx
  wrv[1] = addr >> 4;
80102b36:	c1 e8 04             	shr    $0x4,%eax
    lapicw(ICRLO, STARTUP | (addr>>12));
80102b39:	80 cd 06             	or     $0x6,%ch
  wrv[1] = addr >> 4;
80102b3c:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapic[index] = value;
80102b42:	a1 a0 36 11 80       	mov    0x801136a0,%eax
80102b47:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102b4d:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102b50:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
80102b57:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b5a:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102b5d:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
80102b64:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102b67:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102b6a:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102b70:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102b73:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102b79:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
80102b7c:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102b82:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102b85:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
    microdelay(200);
  }
}
80102b8b:	5b                   	pop    %ebx
  lapic[ID];  // wait for write to finish, by reading
80102b8c:	8b 40 20             	mov    0x20(%eax),%eax
}
80102b8f:	5d                   	pop    %ebp
80102b90:	c3                   	ret    
80102b91:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102b98:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102b9f:	90                   	nop

80102ba0 <cmostime>:
}

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102ba0:	f3 0f 1e fb          	endbr32 
80102ba4:	55                   	push   %ebp
80102ba5:	b8 0b 00 00 00       	mov    $0xb,%eax
80102baa:	ba 70 00 00 00       	mov    $0x70,%edx
80102baf:	89 e5                	mov    %esp,%ebp
80102bb1:	57                   	push   %edi
80102bb2:	56                   	push   %esi
80102bb3:	53                   	push   %ebx
80102bb4:	83 ec 4c             	sub    $0x4c,%esp
80102bb7:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bb8:	ba 71 00 00 00       	mov    $0x71,%edx
80102bbd:	ec                   	in     (%dx),%al
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);

  bcd = (sb & (1 << 2)) == 0;
80102bbe:	83 e0 04             	and    $0x4,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bc1:	bb 70 00 00 00       	mov    $0x70,%ebx
80102bc6:	88 45 b3             	mov    %al,-0x4d(%ebp)
80102bc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102bd0:	31 c0                	xor    %eax,%eax
80102bd2:	89 da                	mov    %ebx,%edx
80102bd4:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bd5:	b9 71 00 00 00       	mov    $0x71,%ecx
80102bda:	89 ca                	mov    %ecx,%edx
80102bdc:	ec                   	in     (%dx),%al
80102bdd:	88 45 b7             	mov    %al,-0x49(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102be0:	89 da                	mov    %ebx,%edx
80102be2:	b8 02 00 00 00       	mov    $0x2,%eax
80102be7:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102be8:	89 ca                	mov    %ecx,%edx
80102bea:	ec                   	in     (%dx),%al
80102beb:	88 45 b6             	mov    %al,-0x4a(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bee:	89 da                	mov    %ebx,%edx
80102bf0:	b8 04 00 00 00       	mov    $0x4,%eax
80102bf5:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102bf6:	89 ca                	mov    %ecx,%edx
80102bf8:	ec                   	in     (%dx),%al
80102bf9:	88 45 b5             	mov    %al,-0x4b(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102bfc:	89 da                	mov    %ebx,%edx
80102bfe:	b8 07 00 00 00       	mov    $0x7,%eax
80102c03:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c04:	89 ca                	mov    %ecx,%edx
80102c06:	ec                   	in     (%dx),%al
80102c07:	88 45 b4             	mov    %al,-0x4c(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c0a:	89 da                	mov    %ebx,%edx
80102c0c:	b8 08 00 00 00       	mov    $0x8,%eax
80102c11:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c12:	89 ca                	mov    %ecx,%edx
80102c14:	ec                   	in     (%dx),%al
80102c15:	89 c7                	mov    %eax,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c17:	89 da                	mov    %ebx,%edx
80102c19:	b8 09 00 00 00       	mov    $0x9,%eax
80102c1e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c1f:	89 ca                	mov    %ecx,%edx
80102c21:	ec                   	in     (%dx),%al
80102c22:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c24:	89 da                	mov    %ebx,%edx
80102c26:	b8 0a 00 00 00       	mov    $0xa,%eax
80102c2b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c2c:	89 ca                	mov    %ecx,%edx
80102c2e:	ec                   	in     (%dx),%al

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102c2f:	84 c0                	test   %al,%al
80102c31:	78 9d                	js     80102bd0 <cmostime+0x30>
  return inb(CMOS_RETURN);
80102c33:	0f b6 45 b7          	movzbl -0x49(%ebp),%eax
80102c37:	89 fa                	mov    %edi,%edx
80102c39:	0f b6 fa             	movzbl %dl,%edi
80102c3c:	89 f2                	mov    %esi,%edx
80102c3e:	89 45 b8             	mov    %eax,-0x48(%ebp)
80102c41:	0f b6 45 b6          	movzbl -0x4a(%ebp),%eax
80102c45:	0f b6 f2             	movzbl %dl,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c48:	89 da                	mov    %ebx,%edx
80102c4a:	89 7d c8             	mov    %edi,-0x38(%ebp)
80102c4d:	89 45 bc             	mov    %eax,-0x44(%ebp)
80102c50:	0f b6 45 b5          	movzbl -0x4b(%ebp),%eax
80102c54:	89 75 cc             	mov    %esi,-0x34(%ebp)
80102c57:	89 45 c0             	mov    %eax,-0x40(%ebp)
80102c5a:	0f b6 45 b4          	movzbl -0x4c(%ebp),%eax
80102c5e:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80102c61:	31 c0                	xor    %eax,%eax
80102c63:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c64:	89 ca                	mov    %ecx,%edx
80102c66:	ec                   	in     (%dx),%al
80102c67:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c6a:	89 da                	mov    %ebx,%edx
80102c6c:	89 45 d0             	mov    %eax,-0x30(%ebp)
80102c6f:	b8 02 00 00 00       	mov    $0x2,%eax
80102c74:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c75:	89 ca                	mov    %ecx,%edx
80102c77:	ec                   	in     (%dx),%al
80102c78:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c7b:	89 da                	mov    %ebx,%edx
80102c7d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80102c80:	b8 04 00 00 00       	mov    $0x4,%eax
80102c85:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c86:	89 ca                	mov    %ecx,%edx
80102c88:	ec                   	in     (%dx),%al
80102c89:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c8c:	89 da                	mov    %ebx,%edx
80102c8e:	89 45 d8             	mov    %eax,-0x28(%ebp)
80102c91:	b8 07 00 00 00       	mov    $0x7,%eax
80102c96:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102c97:	89 ca                	mov    %ecx,%edx
80102c99:	ec                   	in     (%dx),%al
80102c9a:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102c9d:	89 da                	mov    %ebx,%edx
80102c9f:	89 45 dc             	mov    %eax,-0x24(%ebp)
80102ca2:	b8 08 00 00 00       	mov    $0x8,%eax
80102ca7:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ca8:	89 ca                	mov    %ecx,%edx
80102caa:	ec                   	in     (%dx),%al
80102cab:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102cae:	89 da                	mov    %ebx,%edx
80102cb0:	89 45 e0             	mov    %eax,-0x20(%ebp)
80102cb3:	b8 09 00 00 00       	mov    $0x9,%eax
80102cb8:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cb9:	89 ca                	mov    %ecx,%edx
80102cbb:	ec                   	in     (%dx),%al
80102cbc:	0f b6 c0             	movzbl %al,%eax
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102cbf:	83 ec 04             	sub    $0x4,%esp
  return inb(CMOS_RETURN);
80102cc2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102cc5:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102cc8:	6a 18                	push   $0x18
80102cca:	50                   	push   %eax
80102ccb:	8d 45 b8             	lea    -0x48(%ebp),%eax
80102cce:	50                   	push   %eax
80102ccf:	e8 ec 1f 00 00       	call   80104cc0 <memcmp>
80102cd4:	83 c4 10             	add    $0x10,%esp
80102cd7:	85 c0                	test   %eax,%eax
80102cd9:	0f 85 f1 fe ff ff    	jne    80102bd0 <cmostime+0x30>
      break;
  }

  // convert
  if(bcd) {
80102cdf:	80 7d b3 00          	cmpb   $0x0,-0x4d(%ebp)
80102ce3:	75 78                	jne    80102d5d <cmostime+0x1bd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102ce5:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102ce8:	89 c2                	mov    %eax,%edx
80102cea:	83 e0 0f             	and    $0xf,%eax
80102ced:	c1 ea 04             	shr    $0x4,%edx
80102cf0:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102cf3:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102cf6:	89 45 b8             	mov    %eax,-0x48(%ebp)
    CONV(minute);
80102cf9:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102cfc:	89 c2                	mov    %eax,%edx
80102cfe:	83 e0 0f             	and    $0xf,%eax
80102d01:	c1 ea 04             	shr    $0x4,%edx
80102d04:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102d07:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102d0a:	89 45 bc             	mov    %eax,-0x44(%ebp)
    CONV(hour  );
80102d0d:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102d10:	89 c2                	mov    %eax,%edx
80102d12:	83 e0 0f             	and    $0xf,%eax
80102d15:	c1 ea 04             	shr    $0x4,%edx
80102d18:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102d1b:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102d1e:	89 45 c0             	mov    %eax,-0x40(%ebp)
    CONV(day   );
80102d21:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102d24:	89 c2                	mov    %eax,%edx
80102d26:	83 e0 0f             	and    $0xf,%eax
80102d29:	c1 ea 04             	shr    $0x4,%edx
80102d2c:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102d2f:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102d32:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    CONV(month );
80102d35:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102d38:	89 c2                	mov    %eax,%edx
80102d3a:	83 e0 0f             	and    $0xf,%eax
80102d3d:	c1 ea 04             	shr    $0x4,%edx
80102d40:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102d43:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102d46:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(year  );
80102d49:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102d4c:	89 c2                	mov    %eax,%edx
80102d4e:	83 e0 0f             	and    $0xf,%eax
80102d51:	c1 ea 04             	shr    $0x4,%edx
80102d54:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102d57:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102d5a:	89 45 cc             	mov    %eax,-0x34(%ebp)
#undef     CONV
  }

  *r = t1;
80102d5d:	8b 75 08             	mov    0x8(%ebp),%esi
80102d60:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102d63:	89 06                	mov    %eax,(%esi)
80102d65:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102d68:	89 46 04             	mov    %eax,0x4(%esi)
80102d6b:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102d6e:	89 46 08             	mov    %eax,0x8(%esi)
80102d71:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102d74:	89 46 0c             	mov    %eax,0xc(%esi)
80102d77:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102d7a:	89 46 10             	mov    %eax,0x10(%esi)
80102d7d:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102d80:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102d83:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
80102d8a:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d8d:	5b                   	pop    %ebx
80102d8e:	5e                   	pop    %esi
80102d8f:	5f                   	pop    %edi
80102d90:	5d                   	pop    %ebp
80102d91:	c3                   	ret    
80102d92:	66 90                	xchg   %ax,%ax
80102d94:	66 90                	xchg   %ax,%ax
80102d96:	66 90                	xchg   %ax,%ax
80102d98:	66 90                	xchg   %ax,%ax
80102d9a:	66 90                	xchg   %ax,%ax
80102d9c:	66 90                	xchg   %ax,%ax
80102d9e:	66 90                	xchg   %ax,%ax

80102da0 <install_trans>:
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102da0:	8b 0d 08 37 11 80    	mov    0x80113708,%ecx
80102da6:	85 c9                	test   %ecx,%ecx
80102da8:	0f 8e 8a 00 00 00    	jle    80102e38 <install_trans+0x98>
{
80102dae:	55                   	push   %ebp
80102daf:	89 e5                	mov    %esp,%ebp
80102db1:	57                   	push   %edi
  for (tail = 0; tail < log.lh.n; tail++) {
80102db2:	31 ff                	xor    %edi,%edi
{
80102db4:	56                   	push   %esi
80102db5:	53                   	push   %ebx
80102db6:	83 ec 0c             	sub    $0xc,%esp
80102db9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102dc0:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80102dc5:	83 ec 08             	sub    $0x8,%esp
80102dc8:	01 f8                	add    %edi,%eax
80102dca:	83 c0 01             	add    $0x1,%eax
80102dcd:	50                   	push   %eax
80102dce:	ff 35 04 37 11 80    	pushl  0x80113704
80102dd4:	e8 b7 d3 ff ff       	call   80100190 <bread>
80102dd9:	89 c6                	mov    %eax,%esi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102ddb:	58                   	pop    %eax
80102ddc:	5a                   	pop    %edx
80102ddd:	ff 34 bd 0c 37 11 80 	pushl  -0x7feec8f4(,%edi,4)
80102de4:	ff 35 04 37 11 80    	pushl  0x80113704
  for (tail = 0; tail < log.lh.n; tail++) {
80102dea:	83 c7 01             	add    $0x1,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102ded:	e8 9e d3 ff ff       	call   80100190 <bread>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102df2:	83 c4 0c             	add    $0xc,%esp
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102df5:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102df7:	8d 46 5c             	lea    0x5c(%esi),%eax
80102dfa:	68 00 02 00 00       	push   $0x200
80102dff:	50                   	push   %eax
80102e00:	8d 43 5c             	lea    0x5c(%ebx),%eax
80102e03:	50                   	push   %eax
80102e04:	e8 07 1f 00 00       	call   80104d10 <memmove>
    bwrite(dbuf);  // write dst to disk
80102e09:	89 1c 24             	mov    %ebx,(%esp)
80102e0c:	e8 bf d3 ff ff       	call   801001d0 <bwrite>
    brelse(lbuf);
80102e11:	89 34 24             	mov    %esi,(%esp)
80102e14:	e8 f7 d3 ff ff       	call   80100210 <brelse>
    brelse(dbuf);
80102e19:	89 1c 24             	mov    %ebx,(%esp)
80102e1c:	e8 ef d3 ff ff       	call   80100210 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102e21:	83 c4 10             	add    $0x10,%esp
80102e24:	39 3d 08 37 11 80    	cmp    %edi,0x80113708
80102e2a:	7f 94                	jg     80102dc0 <install_trans+0x20>
  }
}
80102e2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102e2f:	5b                   	pop    %ebx
80102e30:	5e                   	pop    %esi
80102e31:	5f                   	pop    %edi
80102e32:	5d                   	pop    %ebp
80102e33:	c3                   	ret    
80102e34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102e38:	c3                   	ret    
80102e39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102e40 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102e40:	55                   	push   %ebp
80102e41:	89 e5                	mov    %esp,%ebp
80102e43:	53                   	push   %ebx
80102e44:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102e47:	ff 35 f4 36 11 80    	pushl  0x801136f4
80102e4d:	ff 35 04 37 11 80    	pushl  0x80113704
80102e53:	e8 38 d3 ff ff       	call   80100190 <bread>
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80102e58:	83 c4 10             	add    $0x10,%esp
  struct buf *buf = bread(log.dev, log.start);
80102e5b:	89 c3                	mov    %eax,%ebx
  hb->n = log.lh.n;
80102e5d:	a1 08 37 11 80       	mov    0x80113708,%eax
80102e62:	89 43 5c             	mov    %eax,0x5c(%ebx)
  for (i = 0; i < log.lh.n; i++) {
80102e65:	85 c0                	test   %eax,%eax
80102e67:	7e 19                	jle    80102e82 <write_head+0x42>
80102e69:	31 d2                	xor    %edx,%edx
80102e6b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102e6f:	90                   	nop
    hb->block[i] = log.lh.block[i];
80102e70:	8b 0c 95 0c 37 11 80 	mov    -0x7feec8f4(,%edx,4),%ecx
80102e77:	89 4c 93 60          	mov    %ecx,0x60(%ebx,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102e7b:	83 c2 01             	add    $0x1,%edx
80102e7e:	39 d0                	cmp    %edx,%eax
80102e80:	75 ee                	jne    80102e70 <write_head+0x30>
  }
  bwrite(buf);
80102e82:	83 ec 0c             	sub    $0xc,%esp
80102e85:	53                   	push   %ebx
80102e86:	e8 45 d3 ff ff       	call   801001d0 <bwrite>
  brelse(buf);
80102e8b:	89 1c 24             	mov    %ebx,(%esp)
80102e8e:	e8 7d d3 ff ff       	call   80100210 <brelse>
}
80102e93:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102e96:	83 c4 10             	add    $0x10,%esp
80102e99:	c9                   	leave  
80102e9a:	c3                   	ret    
80102e9b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102e9f:	90                   	nop

80102ea0 <initlog>:
{
80102ea0:	f3 0f 1e fb          	endbr32 
80102ea4:	55                   	push   %ebp
80102ea5:	89 e5                	mov    %esp,%ebp
80102ea7:	53                   	push   %ebx
80102ea8:	83 ec 3c             	sub    $0x3c,%esp
80102eab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102eae:	68 00 7c 10 80       	push   $0x80107c00
80102eb3:	68 c0 36 11 80       	push   $0x801136c0
80102eb8:	e8 23 1b 00 00       	call   801049e0 <initlock>
  readsb(dev, &sb);
80102ebd:	58                   	pop    %eax
80102ebe:	8d 45 d4             	lea    -0x2c(%ebp),%eax
80102ec1:	5a                   	pop    %edx
80102ec2:	50                   	push   %eax
80102ec3:	53                   	push   %ebx
80102ec4:	e8 37 e7 ff ff       	call   80101600 <readsb>
  log.start = sb.logstart;
80102ec9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  struct buf *buf = bread(log.dev, log.start);
80102ecc:	59                   	pop    %ecx
  log.dev = dev;
80102ecd:	89 1d 04 37 11 80    	mov    %ebx,0x80113704
  log.size = sb.nlog;
80102ed3:	8b 55 e0             	mov    -0x20(%ebp),%edx
  log.start = sb.logstart;
80102ed6:	a3 f4 36 11 80       	mov    %eax,0x801136f4
  log.size = sb.nlog;
80102edb:	89 15 f8 36 11 80    	mov    %edx,0x801136f8
  struct buf *buf = bread(log.dev, log.start);
80102ee1:	5a                   	pop    %edx
80102ee2:	50                   	push   %eax
80102ee3:	53                   	push   %ebx
80102ee4:	e8 a7 d2 ff ff       	call   80100190 <bread>
  for (i = 0; i < log.lh.n; i++) {
80102ee9:	83 c4 10             	add    $0x10,%esp
  log.lh.n = lh->n;
80102eec:	8b 48 5c             	mov    0x5c(%eax),%ecx
80102eef:	89 0d 08 37 11 80    	mov    %ecx,0x80113708
  for (i = 0; i < log.lh.n; i++) {
80102ef5:	85 c9                	test   %ecx,%ecx
80102ef7:	7e 19                	jle    80102f12 <initlog+0x72>
80102ef9:	31 d2                	xor    %edx,%edx
80102efb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102eff:	90                   	nop
    log.lh.block[i] = lh->block[i];
80102f00:	8b 5c 90 60          	mov    0x60(%eax,%edx,4),%ebx
80102f04:	89 1c 95 0c 37 11 80 	mov    %ebx,-0x7feec8f4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102f0b:	83 c2 01             	add    $0x1,%edx
80102f0e:	39 d1                	cmp    %edx,%ecx
80102f10:	75 ee                	jne    80102f00 <initlog+0x60>
  brelse(buf);
80102f12:	83 ec 0c             	sub    $0xc,%esp
80102f15:	50                   	push   %eax
80102f16:	e8 f5 d2 ff ff       	call   80100210 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
80102f1b:	e8 80 fe ff ff       	call   80102da0 <install_trans>
  log.lh.n = 0;
80102f20:	c7 05 08 37 11 80 00 	movl   $0x0,0x80113708
80102f27:	00 00 00 
  write_head(); // clear the log
80102f2a:	e8 11 ff ff ff       	call   80102e40 <write_head>
}
80102f2f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102f32:	83 c4 10             	add    $0x10,%esp
80102f35:	c9                   	leave  
80102f36:	c3                   	ret    
80102f37:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102f3e:	66 90                	xchg   %ax,%ax

80102f40 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
80102f40:	f3 0f 1e fb          	endbr32 
80102f44:	55                   	push   %ebp
80102f45:	89 e5                	mov    %esp,%ebp
80102f47:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102f4a:	68 c0 36 11 80       	push   $0x801136c0
80102f4f:	e8 0c 1c 00 00       	call   80104b60 <acquire>
80102f54:	83 c4 10             	add    $0x10,%esp
80102f57:	eb 1c                	jmp    80102f75 <begin_op+0x35>
80102f59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
80102f60:	83 ec 08             	sub    $0x8,%esp
80102f63:	68 c0 36 11 80       	push   $0x801136c0
80102f68:	68 c0 36 11 80       	push   $0x801136c0
80102f6d:	e8 5e 15 00 00       	call   801044d0 <sleep>
80102f72:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102f75:	a1 00 37 11 80       	mov    0x80113700,%eax
80102f7a:	85 c0                	test   %eax,%eax
80102f7c:	75 e2                	jne    80102f60 <begin_op+0x20>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102f7e:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80102f83:	8b 15 08 37 11 80    	mov    0x80113708,%edx
80102f89:	83 c0 01             	add    $0x1,%eax
80102f8c:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102f8f:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
80102f92:	83 fa 1e             	cmp    $0x1e,%edx
80102f95:	7f c9                	jg     80102f60 <begin_op+0x20>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
      release(&log.lock);
80102f97:	83 ec 0c             	sub    $0xc,%esp
      log.outstanding += 1;
80102f9a:	a3 fc 36 11 80       	mov    %eax,0x801136fc
      release(&log.lock);
80102f9f:	68 c0 36 11 80       	push   $0x801136c0
80102fa4:	e8 77 1c 00 00       	call   80104c20 <release>
      break;
    }
  }
}
80102fa9:	83 c4 10             	add    $0x10,%esp
80102fac:	c9                   	leave  
80102fad:	c3                   	ret    
80102fae:	66 90                	xchg   %ax,%ax

80102fb0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80102fb0:	f3 0f 1e fb          	endbr32 
80102fb4:	55                   	push   %ebp
80102fb5:	89 e5                	mov    %esp,%ebp
80102fb7:	57                   	push   %edi
80102fb8:	56                   	push   %esi
80102fb9:	53                   	push   %ebx
80102fba:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;

  acquire(&log.lock);
80102fbd:	68 c0 36 11 80       	push   $0x801136c0
80102fc2:	e8 99 1b 00 00       	call   80104b60 <acquire>
  log.outstanding -= 1;
80102fc7:	a1 fc 36 11 80       	mov    0x801136fc,%eax
  if(log.committing)
80102fcc:	8b 35 00 37 11 80    	mov    0x80113700,%esi
80102fd2:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80102fd5:	8d 58 ff             	lea    -0x1(%eax),%ebx
80102fd8:	89 1d fc 36 11 80    	mov    %ebx,0x801136fc
  if(log.committing)
80102fde:	85 f6                	test   %esi,%esi
80102fe0:	0f 85 1e 01 00 00    	jne    80103104 <end_op+0x154>
    panic("log.committing");
  if(log.outstanding == 0){
80102fe6:	85 db                	test   %ebx,%ebx
80102fe8:	0f 85 f2 00 00 00    	jne    801030e0 <end_op+0x130>
    do_commit = 1;
    log.committing = 1;
80102fee:	c7 05 00 37 11 80 01 	movl   $0x1,0x80113700
80102ff5:	00 00 00 
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
80102ff8:	83 ec 0c             	sub    $0xc,%esp
80102ffb:	68 c0 36 11 80       	push   $0x801136c0
80103000:	e8 1b 1c 00 00       	call   80104c20 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
80103005:	8b 0d 08 37 11 80    	mov    0x80113708,%ecx
8010300b:	83 c4 10             	add    $0x10,%esp
8010300e:	85 c9                	test   %ecx,%ecx
80103010:	7f 3e                	jg     80103050 <end_op+0xa0>
    acquire(&log.lock);
80103012:	83 ec 0c             	sub    $0xc,%esp
80103015:	68 c0 36 11 80       	push   $0x801136c0
8010301a:	e8 41 1b 00 00       	call   80104b60 <acquire>
    wakeup(&log);
8010301f:	c7 04 24 c0 36 11 80 	movl   $0x801136c0,(%esp)
    log.committing = 0;
80103026:	c7 05 00 37 11 80 00 	movl   $0x0,0x80113700
8010302d:	00 00 00 
    wakeup(&log);
80103030:	e8 5b 16 00 00       	call   80104690 <wakeup>
    release(&log.lock);
80103035:	c7 04 24 c0 36 11 80 	movl   $0x801136c0,(%esp)
8010303c:	e8 df 1b 00 00       	call   80104c20 <release>
80103041:	83 c4 10             	add    $0x10,%esp
}
80103044:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103047:	5b                   	pop    %ebx
80103048:	5e                   	pop    %esi
80103049:	5f                   	pop    %edi
8010304a:	5d                   	pop    %ebp
8010304b:	c3                   	ret    
8010304c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103050:	a1 f4 36 11 80       	mov    0x801136f4,%eax
80103055:	83 ec 08             	sub    $0x8,%esp
80103058:	01 d8                	add    %ebx,%eax
8010305a:	83 c0 01             	add    $0x1,%eax
8010305d:	50                   	push   %eax
8010305e:	ff 35 04 37 11 80    	pushl  0x80113704
80103064:	e8 27 d1 ff ff       	call   80100190 <bread>
80103069:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010306b:	58                   	pop    %eax
8010306c:	5a                   	pop    %edx
8010306d:	ff 34 9d 0c 37 11 80 	pushl  -0x7feec8f4(,%ebx,4)
80103074:	ff 35 04 37 11 80    	pushl  0x80113704
  for (tail = 0; tail < log.lh.n; tail++) {
8010307a:	83 c3 01             	add    $0x1,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010307d:	e8 0e d1 ff ff       	call   80100190 <bread>
    memmove(to->data, from->data, BSIZE);
80103082:	83 c4 0c             	add    $0xc,%esp
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80103085:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80103087:	8d 40 5c             	lea    0x5c(%eax),%eax
8010308a:	68 00 02 00 00       	push   $0x200
8010308f:	50                   	push   %eax
80103090:	8d 46 5c             	lea    0x5c(%esi),%eax
80103093:	50                   	push   %eax
80103094:	e8 77 1c 00 00       	call   80104d10 <memmove>
    bwrite(to);  // write the log
80103099:	89 34 24             	mov    %esi,(%esp)
8010309c:	e8 2f d1 ff ff       	call   801001d0 <bwrite>
    brelse(from);
801030a1:	89 3c 24             	mov    %edi,(%esp)
801030a4:	e8 67 d1 ff ff       	call   80100210 <brelse>
    brelse(to);
801030a9:	89 34 24             	mov    %esi,(%esp)
801030ac:	e8 5f d1 ff ff       	call   80100210 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801030b1:	83 c4 10             	add    $0x10,%esp
801030b4:	3b 1d 08 37 11 80    	cmp    0x80113708,%ebx
801030ba:	7c 94                	jl     80103050 <end_op+0xa0>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
801030bc:	e8 7f fd ff ff       	call   80102e40 <write_head>
    install_trans(); // Now install writes to home locations
801030c1:	e8 da fc ff ff       	call   80102da0 <install_trans>
    log.lh.n = 0;
801030c6:	c7 05 08 37 11 80 00 	movl   $0x0,0x80113708
801030cd:	00 00 00 
    write_head();    // Erase the transaction from the log
801030d0:	e8 6b fd ff ff       	call   80102e40 <write_head>
801030d5:	e9 38 ff ff ff       	jmp    80103012 <end_op+0x62>
801030da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    wakeup(&log);
801030e0:	83 ec 0c             	sub    $0xc,%esp
801030e3:	68 c0 36 11 80       	push   $0x801136c0
801030e8:	e8 a3 15 00 00       	call   80104690 <wakeup>
  release(&log.lock);
801030ed:	c7 04 24 c0 36 11 80 	movl   $0x801136c0,(%esp)
801030f4:	e8 27 1b 00 00       	call   80104c20 <release>
801030f9:	83 c4 10             	add    $0x10,%esp
}
801030fc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801030ff:	5b                   	pop    %ebx
80103100:	5e                   	pop    %esi
80103101:	5f                   	pop    %edi
80103102:	5d                   	pop    %ebp
80103103:	c3                   	ret    
    panic("log.committing");
80103104:	83 ec 0c             	sub    $0xc,%esp
80103107:	68 04 7c 10 80       	push   $0x80107c04
8010310c:	e8 7f d3 ff ff       	call   80100490 <panic>
80103111:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103118:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010311f:	90                   	nop

80103120 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80103120:	f3 0f 1e fb          	endbr32 
80103124:	55                   	push   %ebp
80103125:	89 e5                	mov    %esp,%ebp
80103127:	53                   	push   %ebx
80103128:	83 ec 04             	sub    $0x4,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
8010312b:	8b 15 08 37 11 80    	mov    0x80113708,%edx
{
80103131:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103134:	83 fa 1d             	cmp    $0x1d,%edx
80103137:	0f 8f 91 00 00 00    	jg     801031ce <log_write+0xae>
8010313d:	a1 f8 36 11 80       	mov    0x801136f8,%eax
80103142:	83 e8 01             	sub    $0x1,%eax
80103145:	39 c2                	cmp    %eax,%edx
80103147:	0f 8d 81 00 00 00    	jge    801031ce <log_write+0xae>
    panic("too big a transaction");
  if (log.outstanding < 1)
8010314d:	a1 fc 36 11 80       	mov    0x801136fc,%eax
80103152:	85 c0                	test   %eax,%eax
80103154:	0f 8e 81 00 00 00    	jle    801031db <log_write+0xbb>
    panic("log_write outside of trans");

  acquire(&log.lock);
8010315a:	83 ec 0c             	sub    $0xc,%esp
8010315d:	68 c0 36 11 80       	push   $0x801136c0
80103162:	e8 f9 19 00 00       	call   80104b60 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80103167:	8b 15 08 37 11 80    	mov    0x80113708,%edx
8010316d:	83 c4 10             	add    $0x10,%esp
80103170:	85 d2                	test   %edx,%edx
80103172:	7e 4e                	jle    801031c2 <log_write+0xa2>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103174:	8b 4b 08             	mov    0x8(%ebx),%ecx
  for (i = 0; i < log.lh.n; i++) {
80103177:	31 c0                	xor    %eax,%eax
80103179:	eb 0c                	jmp    80103187 <log_write+0x67>
8010317b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010317f:	90                   	nop
80103180:	83 c0 01             	add    $0x1,%eax
80103183:	39 c2                	cmp    %eax,%edx
80103185:	74 29                	je     801031b0 <log_write+0x90>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80103187:	39 0c 85 0c 37 11 80 	cmp    %ecx,-0x7feec8f4(,%eax,4)
8010318e:	75 f0                	jne    80103180 <log_write+0x60>
      break;
  }
  log.lh.block[i] = b->blockno;
80103190:	89 0c 85 0c 37 11 80 	mov    %ecx,-0x7feec8f4(,%eax,4)
  if (i == log.lh.n)
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80103197:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
}
8010319a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  release(&log.lock);
8010319d:	c7 45 08 c0 36 11 80 	movl   $0x801136c0,0x8(%ebp)
}
801031a4:	c9                   	leave  
  release(&log.lock);
801031a5:	e9 76 1a 00 00       	jmp    80104c20 <release>
801031aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  log.lh.block[i] = b->blockno;
801031b0:	89 0c 95 0c 37 11 80 	mov    %ecx,-0x7feec8f4(,%edx,4)
    log.lh.n++;
801031b7:	83 c2 01             	add    $0x1,%edx
801031ba:	89 15 08 37 11 80    	mov    %edx,0x80113708
801031c0:	eb d5                	jmp    80103197 <log_write+0x77>
  log.lh.block[i] = b->blockno;
801031c2:	8b 43 08             	mov    0x8(%ebx),%eax
801031c5:	a3 0c 37 11 80       	mov    %eax,0x8011370c
  if (i == log.lh.n)
801031ca:	75 cb                	jne    80103197 <log_write+0x77>
801031cc:	eb e9                	jmp    801031b7 <log_write+0x97>
    panic("too big a transaction");
801031ce:	83 ec 0c             	sub    $0xc,%esp
801031d1:	68 13 7c 10 80       	push   $0x80107c13
801031d6:	e8 b5 d2 ff ff       	call   80100490 <panic>
    panic("log_write outside of trans");
801031db:	83 ec 0c             	sub    $0xc,%esp
801031de:	68 29 7c 10 80       	push   $0x80107c29
801031e3:	e8 a8 d2 ff ff       	call   80100490 <panic>
801031e8:	66 90                	xchg   %ax,%ax
801031ea:	66 90                	xchg   %ax,%ax
801031ec:	66 90                	xchg   %ax,%ax
801031ee:	66 90                	xchg   %ax,%ax

801031f0 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
801031f0:	55                   	push   %ebp
801031f1:	89 e5                	mov    %esp,%ebp
801031f3:	53                   	push   %ebx
801031f4:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
801031f7:	e8 84 0c 00 00       	call   80103e80 <cpuid>
801031fc:	89 c3                	mov    %eax,%ebx
801031fe:	e8 7d 0c 00 00       	call   80103e80 <cpuid>
80103203:	83 ec 04             	sub    $0x4,%esp
80103206:	53                   	push   %ebx
80103207:	50                   	push   %eax
80103208:	68 44 7c 10 80       	push   $0x80107c44
8010320d:	e8 9e d5 ff ff       	call   801007b0 <cprintf>
  idtinit();       // load idt register
80103212:	e8 39 2d 00 00       	call   80105f50 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103217:	e8 f4 0b 00 00       	call   80103e10 <mycpu>
8010321c:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010321e:	b8 01 00 00 00       	mov    $0x1,%eax
80103223:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
8010322a:	e8 b1 0f 00 00       	call   801041e0 <scheduler>
8010322f:	90                   	nop

80103230 <mpenter>:
{
80103230:	f3 0f 1e fb          	endbr32 
80103234:	55                   	push   %ebp
80103235:	89 e5                	mov    %esp,%ebp
80103237:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
8010323a:	e8 11 3e 00 00       	call   80107050 <switchkvm>
  seginit();
8010323f:	e8 7c 3d 00 00       	call   80106fc0 <seginit>
  lapicinit();
80103244:	e8 67 f7 ff ff       	call   801029b0 <lapicinit>
  mpmain();
80103249:	e8 a2 ff ff ff       	call   801031f0 <mpmain>
8010324e:	66 90                	xchg   %ax,%ax

80103250 <main>:
{
80103250:	f3 0f 1e fb          	endbr32 
80103254:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103258:	83 e4 f0             	and    $0xfffffff0,%esp
8010325b:	ff 71 fc             	pushl  -0x4(%ecx)
8010325e:	55                   	push   %ebp
8010325f:	89 e5                	mov    %esp,%ebp
80103261:	53                   	push   %ebx
80103262:	51                   	push   %ecx
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103263:	83 ec 08             	sub    $0x8,%esp
80103266:	68 00 00 40 80       	push   $0x80400000
8010326b:	68 48 6f 11 80       	push   $0x80116f48
80103270:	e8 0b f4 ff ff       	call   80102680 <kinit1>
  kvmalloc();      // kernel page table
80103275:	e8 c6 42 00 00       	call   80107540 <kvmalloc>
  mpinit();        // detect other processors
8010327a:	e8 81 01 00 00       	call   80103400 <mpinit>
  lapicinit();     // interrupt controller
8010327f:	e8 2c f7 ff ff       	call   801029b0 <lapicinit>
  seginit();       // segment descriptors
80103284:	e8 37 3d 00 00       	call   80106fc0 <seginit>
  picinit();       // disable pic
80103289:	e8 72 06 00 00       	call   80103900 <picinit>
  ioapicinit();    // another interrupt controller
8010328e:	e8 ed f1 ff ff       	call   80102480 <ioapicinit>
  consoleinit();   // console hardware
80103293:	e8 98 d8 ff ff       	call   80100b30 <consoleinit>
  uartinit();      // serial port
80103298:	e8 d3 2f 00 00       	call   80106270 <uartinit>
  pinit();         // process table
8010329d:	e8 4e 0b 00 00       	call   80103df0 <pinit>
  tvinit();        // trap vectors
801032a2:	e8 29 2c 00 00       	call   80105ed0 <tvinit>
  binit();         // buffer cache
801032a7:	e8 54 ce ff ff       	call   80100100 <binit>
  fileinit();      // file table
801032ac:	e8 2f dc ff ff       	call   80100ee0 <fileinit>
  ideinit();       // disk 
801032b1:	e8 9a ef ff ff       	call   80102250 <ideinit>

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801032b6:	83 c4 0c             	add    $0xc,%esp
801032b9:	68 8a 00 00 00       	push   $0x8a
801032be:	68 8c b4 10 80       	push   $0x8010b48c
801032c3:	68 00 70 00 80       	push   $0x80007000
801032c8:	e8 43 1a 00 00       	call   80104d10 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801032cd:	83 c4 10             	add    $0x10,%esp
801032d0:	69 05 40 3d 11 80 b0 	imul   $0xb0,0x80113d40,%eax
801032d7:	00 00 00 
801032da:	05 c0 37 11 80       	add    $0x801137c0,%eax
801032df:	3d c0 37 11 80       	cmp    $0x801137c0,%eax
801032e4:	76 7a                	jbe    80103360 <main+0x110>
801032e6:	bb c0 37 11 80       	mov    $0x801137c0,%ebx
801032eb:	eb 1c                	jmp    80103309 <main+0xb9>
801032ed:	8d 76 00             	lea    0x0(%esi),%esi
801032f0:	69 05 40 3d 11 80 b0 	imul   $0xb0,0x80113d40,%eax
801032f7:	00 00 00 
801032fa:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80103300:	05 c0 37 11 80       	add    $0x801137c0,%eax
80103305:	39 c3                	cmp    %eax,%ebx
80103307:	73 57                	jae    80103360 <main+0x110>
    if(c == mycpu())  // We've started already.
80103309:	e8 02 0b 00 00       	call   80103e10 <mycpu>
8010330e:	39 c3                	cmp    %eax,%ebx
80103310:	74 de                	je     801032f0 <main+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103312:	e8 49 f4 ff ff       	call   80102760 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
    *(void(**)(void))(code-8) = mpenter;
    *(int**)(code-12) = (void *) V2P(entrypgdir);

    lapicstartap(c->apicid, V2P(code));
80103317:	83 ec 08             	sub    $0x8,%esp
    *(void(**)(void))(code-8) = mpenter;
8010331a:	c7 05 f8 6f 00 80 30 	movl   $0x80103230,0x80006ff8
80103321:	32 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103324:	c7 05 f4 6f 00 80 00 	movl   $0x10a000,0x80006ff4
8010332b:	a0 10 00 
    *(void**)(code-4) = stack + KSTACKSIZE;
8010332e:	05 00 10 00 00       	add    $0x1000,%eax
80103333:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    lapicstartap(c->apicid, V2P(code));
80103338:	0f b6 03             	movzbl (%ebx),%eax
8010333b:	68 00 70 00 00       	push   $0x7000
80103340:	50                   	push   %eax
80103341:	e8 ba f7 ff ff       	call   80102b00 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103346:	83 c4 10             	add    $0x10,%esp
80103349:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103350:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80103356:	85 c0                	test   %eax,%eax
80103358:	74 f6                	je     80103350 <main+0x100>
8010335a:	eb 94                	jmp    801032f0 <main+0xa0>
8010335c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103360:	83 ec 08             	sub    $0x8,%esp
80103363:	68 00 00 40 80       	push   $0x80400000
80103368:	68 00 00 40 80       	push   $0x80400000
8010336d:	e8 8e f3 ff ff       	call   80102700 <kinit2>
  userinit();      // first user process
80103372:	e8 59 0b 00 00       	call   80103ed0 <userinit>
  mpmain();        // finish this processor's setup
80103377:	e8 74 fe ff ff       	call   801031f0 <mpmain>
8010337c:	66 90                	xchg   %ax,%ax
8010337e:	66 90                	xchg   %ax,%ax

80103380 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103380:	55                   	push   %ebp
80103381:	89 e5                	mov    %esp,%ebp
80103383:	57                   	push   %edi
80103384:	56                   	push   %esi
  uchar *e, *p, *addr;

  addr = P2V(a);
80103385:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
{
8010338b:	53                   	push   %ebx
  e = addr+len;
8010338c:	8d 1c 16             	lea    (%esi,%edx,1),%ebx
{
8010338f:	83 ec 0c             	sub    $0xc,%esp
  for(p = addr; p < e; p += sizeof(struct mp))
80103392:	39 de                	cmp    %ebx,%esi
80103394:	72 10                	jb     801033a6 <mpsearch1+0x26>
80103396:	eb 50                	jmp    801033e8 <mpsearch1+0x68>
80103398:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010339f:	90                   	nop
801033a0:	89 fe                	mov    %edi,%esi
801033a2:	39 fb                	cmp    %edi,%ebx
801033a4:	76 42                	jbe    801033e8 <mpsearch1+0x68>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801033a6:	83 ec 04             	sub    $0x4,%esp
801033a9:	8d 7e 10             	lea    0x10(%esi),%edi
801033ac:	6a 04                	push   $0x4
801033ae:	68 58 7c 10 80       	push   $0x80107c58
801033b3:	56                   	push   %esi
801033b4:	e8 07 19 00 00       	call   80104cc0 <memcmp>
801033b9:	83 c4 10             	add    $0x10,%esp
801033bc:	85 c0                	test   %eax,%eax
801033be:	75 e0                	jne    801033a0 <mpsearch1+0x20>
801033c0:	89 f2                	mov    %esi,%edx
801033c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    sum += addr[i];
801033c8:	0f b6 0a             	movzbl (%edx),%ecx
801033cb:	83 c2 01             	add    $0x1,%edx
801033ce:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
801033d0:	39 fa                	cmp    %edi,%edx
801033d2:	75 f4                	jne    801033c8 <mpsearch1+0x48>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801033d4:	84 c0                	test   %al,%al
801033d6:	75 c8                	jne    801033a0 <mpsearch1+0x20>
      return (struct mp*)p;
  return 0;
}
801033d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801033db:	89 f0                	mov    %esi,%eax
801033dd:	5b                   	pop    %ebx
801033de:	5e                   	pop    %esi
801033df:	5f                   	pop    %edi
801033e0:	5d                   	pop    %ebp
801033e1:	c3                   	ret    
801033e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801033e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801033eb:	31 f6                	xor    %esi,%esi
}
801033ed:	5b                   	pop    %ebx
801033ee:	89 f0                	mov    %esi,%eax
801033f0:	5e                   	pop    %esi
801033f1:	5f                   	pop    %edi
801033f2:	5d                   	pop    %ebp
801033f3:	c3                   	ret    
801033f4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801033fb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801033ff:	90                   	nop

80103400 <mpinit>:
  return conf;
}

void
mpinit(void)
{
80103400:	f3 0f 1e fb          	endbr32 
80103404:	55                   	push   %ebp
80103405:	89 e5                	mov    %esp,%ebp
80103407:	57                   	push   %edi
80103408:	56                   	push   %esi
80103409:	53                   	push   %ebx
8010340a:	83 ec 1c             	sub    $0x1c,%esp
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
8010340d:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80103414:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
8010341b:	c1 e0 08             	shl    $0x8,%eax
8010341e:	09 d0                	or     %edx,%eax
80103420:	c1 e0 04             	shl    $0x4,%eax
80103423:	75 1b                	jne    80103440 <mpinit+0x40>
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103425:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
8010342c:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80103433:	c1 e0 08             	shl    $0x8,%eax
80103436:	09 d0                	or     %edx,%eax
80103438:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
8010343b:	2d 00 04 00 00       	sub    $0x400,%eax
    if((mp = mpsearch1(p, 1024)))
80103440:	ba 00 04 00 00       	mov    $0x400,%edx
80103445:	e8 36 ff ff ff       	call   80103380 <mpsearch1>
8010344a:	89 c6                	mov    %eax,%esi
8010344c:	85 c0                	test   %eax,%eax
8010344e:	0f 84 4c 01 00 00    	je     801035a0 <mpinit+0x1a0>
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103454:	8b 5e 04             	mov    0x4(%esi),%ebx
80103457:	85 db                	test   %ebx,%ebx
80103459:	0f 84 61 01 00 00    	je     801035c0 <mpinit+0x1c0>
  if(memcmp(conf, "PCMP", 4) != 0)
8010345f:	83 ec 04             	sub    $0x4,%esp
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103462:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
  if(memcmp(conf, "PCMP", 4) != 0)
80103468:	6a 04                	push   $0x4
8010346a:	68 5d 7c 10 80       	push   $0x80107c5d
8010346f:	50                   	push   %eax
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80103470:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103473:	e8 48 18 00 00       	call   80104cc0 <memcmp>
80103478:	83 c4 10             	add    $0x10,%esp
8010347b:	85 c0                	test   %eax,%eax
8010347d:	0f 85 3d 01 00 00    	jne    801035c0 <mpinit+0x1c0>
  if(conf->version != 1 && conf->version != 4)
80103483:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
8010348a:	3c 01                	cmp    $0x1,%al
8010348c:	74 08                	je     80103496 <mpinit+0x96>
8010348e:	3c 04                	cmp    $0x4,%al
80103490:	0f 85 2a 01 00 00    	jne    801035c0 <mpinit+0x1c0>
  if(sum((uchar*)conf, conf->length) != 0)
80103496:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
  for(i=0; i<len; i++)
8010349d:	66 85 d2             	test   %dx,%dx
801034a0:	74 26                	je     801034c8 <mpinit+0xc8>
801034a2:	8d 3c 1a             	lea    (%edx,%ebx,1),%edi
801034a5:	89 d8                	mov    %ebx,%eax
  sum = 0;
801034a7:	31 d2                	xor    %edx,%edx
801034a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    sum += addr[i];
801034b0:	0f b6 88 00 00 00 80 	movzbl -0x80000000(%eax),%ecx
801034b7:	83 c0 01             	add    $0x1,%eax
801034ba:	01 ca                	add    %ecx,%edx
  for(i=0; i<len; i++)
801034bc:	39 f8                	cmp    %edi,%eax
801034be:	75 f0                	jne    801034b0 <mpinit+0xb0>
  if(sum((uchar*)conf, conf->length) != 0)
801034c0:	84 d2                	test   %dl,%dl
801034c2:	0f 85 f8 00 00 00    	jne    801035c0 <mpinit+0x1c0>
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
801034c8:	8b 83 24 00 00 80    	mov    -0x7fffffdc(%ebx),%eax
801034ce:	a3 a0 36 11 80       	mov    %eax,0x801136a0
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801034d3:	8d 83 2c 00 00 80    	lea    -0x7fffffd4(%ebx),%eax
801034d9:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
  ismp = 1;
801034e0:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801034e5:	03 55 e4             	add    -0x1c(%ebp),%edx
801034e8:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
801034eb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801034ef:	90                   	nop
801034f0:	39 c2                	cmp    %eax,%edx
801034f2:	76 15                	jbe    80103509 <mpinit+0x109>
    switch(*p){
801034f4:	0f b6 08             	movzbl (%eax),%ecx
801034f7:	80 f9 02             	cmp    $0x2,%cl
801034fa:	74 5c                	je     80103558 <mpinit+0x158>
801034fc:	77 42                	ja     80103540 <mpinit+0x140>
801034fe:	84 c9                	test   %cl,%cl
80103500:	74 6e                	je     80103570 <mpinit+0x170>
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103502:	83 c0 08             	add    $0x8,%eax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103505:	39 c2                	cmp    %eax,%edx
80103507:	77 eb                	ja     801034f4 <mpinit+0xf4>
80103509:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
8010350c:	85 db                	test   %ebx,%ebx
8010350e:	0f 84 b9 00 00 00    	je     801035cd <mpinit+0x1cd>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80103514:	80 7e 0c 00          	cmpb   $0x0,0xc(%esi)
80103518:	74 15                	je     8010352f <mpinit+0x12f>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010351a:	b8 70 00 00 00       	mov    $0x70,%eax
8010351f:	ba 22 00 00 00       	mov    $0x22,%edx
80103524:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103525:	ba 23 00 00 00       	mov    $0x23,%edx
8010352a:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
8010352b:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010352e:	ee                   	out    %al,(%dx)
  }
}
8010352f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103532:	5b                   	pop    %ebx
80103533:	5e                   	pop    %esi
80103534:	5f                   	pop    %edi
80103535:	5d                   	pop    %ebp
80103536:	c3                   	ret    
80103537:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010353e:	66 90                	xchg   %ax,%ax
    switch(*p){
80103540:	83 e9 03             	sub    $0x3,%ecx
80103543:	80 f9 01             	cmp    $0x1,%cl
80103546:	76 ba                	jbe    80103502 <mpinit+0x102>
80103548:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010354f:	eb 9f                	jmp    801034f0 <mpinit+0xf0>
80103551:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      ioapicid = ioapic->apicno;
80103558:	0f b6 48 01          	movzbl 0x1(%eax),%ecx
      p += sizeof(struct mpioapic);
8010355c:	83 c0 08             	add    $0x8,%eax
      ioapicid = ioapic->apicno;
8010355f:	88 0d a0 37 11 80    	mov    %cl,0x801137a0
      continue;
80103565:	eb 89                	jmp    801034f0 <mpinit+0xf0>
80103567:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010356e:	66 90                	xchg   %ax,%ax
      if(ncpu < NCPU) {
80103570:	8b 0d 40 3d 11 80    	mov    0x80113d40,%ecx
80103576:	83 f9 07             	cmp    $0x7,%ecx
80103579:	7f 19                	jg     80103594 <mpinit+0x194>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010357b:	69 f9 b0 00 00 00    	imul   $0xb0,%ecx,%edi
80103581:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
        ncpu++;
80103585:	83 c1 01             	add    $0x1,%ecx
80103588:	89 0d 40 3d 11 80    	mov    %ecx,0x80113d40
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010358e:	88 9f c0 37 11 80    	mov    %bl,-0x7feec840(%edi)
      p += sizeof(struct mpproc);
80103594:	83 c0 14             	add    $0x14,%eax
      continue;
80103597:	e9 54 ff ff ff       	jmp    801034f0 <mpinit+0xf0>
8010359c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  return mpsearch1(0xF0000, 0x10000);
801035a0:	ba 00 00 01 00       	mov    $0x10000,%edx
801035a5:	b8 00 00 0f 00       	mov    $0xf0000,%eax
801035aa:	e8 d1 fd ff ff       	call   80103380 <mpsearch1>
801035af:	89 c6                	mov    %eax,%esi
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
801035b1:	85 c0                	test   %eax,%eax
801035b3:	0f 85 9b fe ff ff    	jne    80103454 <mpinit+0x54>
801035b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    panic("Expect to run on an SMP");
801035c0:	83 ec 0c             	sub    $0xc,%esp
801035c3:	68 62 7c 10 80       	push   $0x80107c62
801035c8:	e8 c3 ce ff ff       	call   80100490 <panic>
    panic("Didn't find a suitable machine");
801035cd:	83 ec 0c             	sub    $0xc,%esp
801035d0:	68 7c 7c 10 80       	push   $0x80107c7c
801035d5:	e8 b6 ce ff ff       	call   80100490 <panic>
801035da:	66 90                	xchg   %ax,%ax
801035dc:	66 90                	xchg   %ax,%ax
801035de:	66 90                	xchg   %ax,%ax

801035e0 <walkpgdir.constprop.0>:
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
801035e0:	89 d1                	mov    %edx,%ecx
801035e2:	c1 e9 16             	shr    $0x16,%ecx
  if(*pde & PTE_P){
801035e5:	8b 04 88             	mov    (%eax,%ecx,4),%eax
801035e8:	a8 01                	test   $0x1,%al
801035ea:	75 04                	jne    801035f0 <walkpgdir.constprop.0+0x10>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
      return 0;
801035ec:	31 c0                	xor    %eax,%eax
    // // be further restricted by the permissions in the page table
    // // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
}
801035ee:	c3                   	ret    
801035ef:	90                   	nop
  return &pgtab[PTX(va)];
801035f0:	c1 ea 0a             	shr    $0xa,%edx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801035f3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
801035f8:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
801035fe:	8d 84 10 00 00 00 80 	lea    -0x80000000(%eax,%edx,1),%eax
80103605:	c3                   	ret    
80103606:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010360d:	8d 76 00             	lea    0x0(%esi),%esi

80103610 <swapinit>:
void swapinit() {
80103610:	f3 0f 1e fb          	endbr32 
  for(int i=0; i<SWAPSLOTS; i++) {
80103614:	31 c0                	xor    %eax,%eax
80103616:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010361d:	8d 76 00             	lea    0x0(%esi),%esi
    swap_slots[i].is_free = 0;
80103620:	c7 04 c5 60 3d 11 80 	movl   $0x0,-0x7feec2a0(,%eax,8)
80103627:	00 00 00 00 
  for(int i=0; i<SWAPSLOTS; i++) {
8010362b:	83 c0 01             	add    $0x1,%eax
8010362e:	3d 2c 01 00 00       	cmp    $0x12c,%eax
80103633:	75 eb                	jne    80103620 <swapinit+0x10>
}
80103635:	c3                   	ret    
80103636:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010363d:	8d 76 00             	lea    0x0(%esi),%esi

80103640 <clean_swapblocks>:
void clean_swapblocks(struct proc* process) {
80103640:	f3 0f 1e fb          	endbr32 
80103644:	55                   	push   %ebp
80103645:	89 e5                	mov    %esp,%ebp
80103647:	56                   	push   %esi
80103648:	8b 45 08             	mov    0x8(%ebp),%eax
8010364b:	53                   	push   %ebx
8010364c:	8b 58 08             	mov    0x8(%eax),%ebx
8010364f:	8d b3 00 10 00 00    	lea    0x1000(%ebx),%esi
80103655:	eb 10                	jmp    80103667 <clean_swapblocks+0x27>
80103657:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010365e:	66 90                	xchg   %ax,%ax
  for(int i=0; i<1024; i++) {
80103660:	83 c3 04             	add    $0x4,%ebx
80103663:	39 de                	cmp    %ebx,%esi
80103665:	74 44                	je     801036ab <clean_swapblocks+0x6b>
    if (pde[i]==0) {
80103667:	8b 0b                	mov    (%ebx),%ecx
80103669:	85 c9                	test   %ecx,%ecx
8010366b:	74 f3                	je     80103660 <clean_swapblocks+0x20>
    if (pde[i] & PTE_P) {
8010366d:	f6 c1 01             	test   $0x1,%cl
80103670:	74 ee                	je     80103660 <clean_swapblocks+0x20>
      pte_t* pte = (pte_t*) P2V(PTE_ADDR(pde[i]));
80103672:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
80103678:	8d 81 00 00 00 80    	lea    -0x80000000(%ecx),%eax
      for (int j=0; j<1024; j++) {
8010367e:	81 e9 00 f0 ff 7f    	sub    $0x7ffff000,%ecx
80103684:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        if (!(pte[j] & PTE_P)) {
80103688:	8b 10                	mov    (%eax),%edx
8010368a:	f6 c2 01             	test   $0x1,%dl
8010368d:	75 0e                	jne    8010369d <clean_swapblocks+0x5d>
          uint slot = PTE_ADDR(pte[j]) >> 12;
8010368f:	c1 ea 0c             	shr    $0xc,%edx
          swap_slots[slot].is_free = 0;
80103692:	c7 04 d5 60 3d 11 80 	movl   $0x0,-0x7feec2a0(,%edx,8)
80103699:	00 00 00 00 
      for (int j=0; j<1024; j++) {
8010369d:	83 c0 04             	add    $0x4,%eax
801036a0:	39 c1                	cmp    %eax,%ecx
801036a2:	75 e4                	jne    80103688 <clean_swapblocks+0x48>
  for(int i=0; i<1024; i++) {
801036a4:	83 c3 04             	add    $0x4,%ebx
801036a7:	39 de                	cmp    %ebx,%esi
801036a9:	75 bc                	jne    80103667 <clean_swapblocks+0x27>
}
801036ab:	5b                   	pop    %ebx
801036ac:	5e                   	pop    %esi
801036ad:	5d                   	pop    %ebp
801036ae:	c3                   	ret    
801036af:	90                   	nop

801036b0 <choose_process>:

struct proc* choose_process()
{
801036b0:	f3 0f 1e fb          	endbr32 
 /// Write a function in proc.c that iterates over the proc table and finds the process with most pages.
    return find_proc();
801036b4:	e9 97 11 00 00       	jmp    80104850 <find_proc>
801036b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801036c0 <page_to_be_removed>:
}

pte_t* page_to_be_removed(struct proc* process) //// This is a fuction that could be made more efficient
{
801036c0:	f3 0f 1e fb          	endbr32 
801036c4:	55                   	push   %ebp
801036c5:	89 e5                	mov    %esp,%ebp
801036c7:	57                   	push   %edi
801036c8:	56                   	push   %esi
801036c9:	53                   	push   %ebx
801036ca:	83 ec 0c             	sub    $0xc,%esp
801036cd:	8b 45 08             	mov    0x8(%ebp),%eax
  for (int va=0;va<process->sz;va+=PGSIZE)
801036d0:	8b 18                	mov    (%eax),%ebx
801036d2:	85 db                	test   %ebx,%ebx
801036d4:	74 2b                	je     80103701 <page_to_be_removed+0x41>
  { 
    pte_t* result = walkpgdir(process->pgdir,(void *)va, 0);
801036d6:	8b 70 08             	mov    0x8(%eax),%esi
  for (int va=0;va<process->sz;va+=PGSIZE)
801036d9:	31 ff                	xor    %edi,%edi
801036db:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801036df:	90                   	nop
    pte_t* result = walkpgdir(process->pgdir,(void *)va, 0);
801036e0:	89 fa                	mov    %edi,%edx
801036e2:	89 f0                	mov    %esi,%eax
801036e4:	e8 f7 fe ff ff       	call   801035e0 <walkpgdir.constprop.0>
    if (result==0)
801036e9:	85 c0                	test   %eax,%eax
801036eb:	74 0a                	je     801036f7 <page_to_be_removed+0x37>
      continue;
    if((*result & PTE_P) && !(*result & PTE_A))
801036ed:	8b 10                	mov    (%eax),%edx
801036ef:	83 e2 21             	and    $0x21,%edx
801036f2:	83 fa 01             	cmp    $0x1,%edx
801036f5:	74 0c                	je     80103703 <page_to_be_removed+0x43>
  for (int va=0;va<process->sz;va+=PGSIZE)
801036f7:	81 c7 00 10 00 00    	add    $0x1000,%edi
801036fd:	39 df                	cmp    %ebx,%edi
801036ff:	72 df                	jb     801036e0 <page_to_be_removed+0x20>
      return result;
    //return result;
  }
  return 0;
80103701:	31 c0                	xor    %eax,%eax
}
80103703:	83 c4 0c             	add    $0xc,%esp
80103706:	5b                   	pop    %ebx
80103707:	5e                   	pop    %esi
80103708:	5f                   	pop    %edi
80103709:	5d                   	pop    %ebp
8010370a:	c3                   	ret    
8010370b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010370f:	90                   	nop

80103710 <choose_page>:

 // Find victim page
pte_t* choose_page(struct proc* process)
{
80103710:	f3 0f 1e fb          	endbr32 
80103714:	55                   	push   %ebp
80103715:	89 e5                	mov    %esp,%ebp
80103717:	57                   	push   %edi
80103718:	56                   	push   %esi
80103719:	53                   	push   %ebx
8010371a:	83 ec 18             	sub    $0x18,%esp
8010371d:	8b 75 08             	mov    0x8(%ebp),%esi
    pte_t* page= page_to_be_removed(process);
80103720:	56                   	push   %esi
80103721:	e8 9a ff ff ff       	call   801036c0 <page_to_be_removed>
80103726:	83 c4 10             	add    $0x10,%esp
    if (page==0)
80103729:	85 c0                	test   %eax,%eax
8010372b:	74 0b                	je     80103738 <choose_page+0x28>
        }
        
    page= page_to_be_removed(process);}
    return page;
    
}
8010372d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103730:	5b                   	pop    %ebx
80103731:	5e                   	pop    %esi
80103732:	5f                   	pop    %edi
80103733:	5d                   	pop    %ebp
80103734:	c3                   	ret    
80103735:	8d 76 00             	lea    0x0(%esi),%esi
      for (int va=0;va<process->sz;va+=PGSIZE)
80103738:	8b 16                	mov    (%esi),%edx
8010373a:	85 d2                	test   %edx,%edx
8010373c:	74 ef                	je     8010372d <choose_page+0x1d>
      int counter=0;
8010373e:	31 db                	xor    %ebx,%ebx
      for (int va=0;va<process->sz;va+=PGSIZE)
80103740:	31 ff                	xor    %edi,%edi
80103742:	eb 11                	jmp    80103755 <choose_page+0x45>
80103744:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103748:	83 c3 01             	add    $0x1,%ebx
8010374b:	81 c7 00 10 00 00    	add    $0x1000,%edi
80103751:	39 3e                	cmp    %edi,(%esi)
80103753:	76 2a                	jbe    8010377f <choose_page+0x6f>
          pte_t* result = walkpgdir(process->pgdir,(void *)va, 0);
80103755:	8b 46 08             	mov    0x8(%esi),%eax
80103758:	89 fa                	mov    %edi,%edx
8010375a:	e8 81 fe ff ff       	call   801035e0 <walkpgdir.constprop.0>
            if (*result & PTE_A) {
8010375f:	8b 10                	mov    (%eax),%edx
80103761:	f6 c2 20             	test   $0x20,%dl
80103764:	74 e5                	je     8010374b <choose_page+0x3b>
              if(counter==9)
80103766:	83 fb 09             	cmp    $0x9,%ebx
80103769:	75 dd                	jne    80103748 <choose_page+0x38>
                  *result &= ~PTE_A;
8010376b:	83 e2 df             	and    $0xffffffdf,%edx
8010376e:	bb 01 00 00 00       	mov    $0x1,%ebx
      for (int va=0;va<process->sz;va+=PGSIZE)
80103773:	81 c7 00 10 00 00    	add    $0x1000,%edi
                  *result &= ~PTE_A;
80103779:	89 10                	mov    %edx,(%eax)
      for (int va=0;va<process->sz;va+=PGSIZE)
8010377b:	39 3e                	cmp    %edi,(%esi)
8010377d:	77 d6                	ja     80103755 <choose_page+0x45>
8010377f:	89 75 08             	mov    %esi,0x8(%ebp)
}
80103782:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103785:	5b                   	pop    %ebx
80103786:	5e                   	pop    %esi
80103787:	5f                   	pop    %edi
80103788:	5d                   	pop    %ebp
80103789:	e9 32 ff ff ff       	jmp    801036c0 <page_to_be_removed>
8010378e:	66 90                	xchg   %ax,%ax

80103790 <swappage>:

// Swap in
void swappage()
{   uint va = rcr2(); // Get the faulting virtual address
80103790:	f3 0f 1e fb          	endbr32 
80103794:	55                   	push   %ebp
80103795:	89 e5                	mov    %esp,%ebp
80103797:	57                   	push   %edi
80103798:	56                   	push   %esi
80103799:	53                   	push   %ebx
8010379a:	83 ec 0c             	sub    $0xc,%esp

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010379d:	0f 20 d3             	mov    %cr2,%ebx
    //
    va = PGROUNDDOWN(va);
    pte_t *pte = walkpgdir(myproc()->pgdir, (char *)va, 0);
801037a0:	e8 fb 06 00 00       	call   80103ea0 <myproc>
    va = PGROUNDDOWN(va);
801037a5:	89 da                	mov    %ebx,%edx
    pte_t *pte = walkpgdir(myproc()->pgdir, (char *)va, 0);
801037a7:	8b 40 08             	mov    0x8(%eax),%eax
    va = PGROUNDDOWN(va);
801037aa:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
    pte_t *pte = walkpgdir(myproc()->pgdir, (char *)va, 0);
801037b0:	e8 2b fe ff ff       	call   801035e0 <walkpgdir.constprop.0>
801037b5:	89 c6                	mov    %eax,%esi
    // if (pte)
    // {
      // cprintf("TEST TEST \n");
      // Allocate a new page in memory
      // uint va = rcr();
      char *mem = kalloc();
801037b7:	e8 a4 ef ff ff       	call   80102760 <kalloc>
      if (!mem) {
801037bc:	85 c0                	test   %eax,%eax
801037be:	74 59                	je     80103819 <swappage+0x89>
          panic("page_fault_handler: kalloc failed");
      }

      // cprintf("SWAPIN START: The kalloc address is %x %x \n", mem, va);
        // char buf[BSIZE];
        int swap_slot = PTE_ADDR(*pte) >> 12;
801037c0:	8b 3e                	mov    (%esi),%edi
        read_page_from_disk(mem, 2+8*swap_slot);
801037c2:	83 ec 08             	sub    $0x8,%esp
801037c5:	89 c3                	mov    %eax,%ebx
        int swap_slot = PTE_ADDR(*pte) >> 12;
801037c7:	c1 ef 0c             	shr    $0xc,%edi
        read_page_from_disk(mem, 2+8*swap_slot);
801037ca:	8d 04 fd 02 00 00 00 	lea    0x2(,%edi,8),%eax
801037d1:	50                   	push   %eax
801037d2:	53                   	push   %ebx
        // for (int i=0; i<8; i++) {
        //     rsect(swap_slot*8 + i, buf);
        //     memmove(mem, buf, BSIZE);
        //     mem += BSIZE;
        // }
        *pte = V2P(mem) | (*pte & 0xFFF);
801037d3:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
        read_page_from_disk(mem, 2+8*swap_slot);
801037d9:	e8 42 cb ff ff       	call   80100320 <read_page_from_disk>
        *pte = V2P(mem) | (*pte & 0xFFF);
801037de:	8b 06                	mov    (%esi),%eax
801037e0:	25 ff 0f 00 00       	and    $0xfff,%eax
801037e5:	09 c3                	or     %eax,%ebx
        *pte |= PTE_P ;
801037e7:	83 cb 01             	or     $0x1,%ebx
801037ea:	89 1e                	mov    %ebx,(%esi)
        myproc()->rss += PGSIZE;
801037ec:	e8 af 06 00 00       	call   80103ea0 <myproc>
    // } else {
    //     cprintf("page_fault_handler: Page table entry not found for virtual address: %x\n", va);
    //     exit();
    // }

    return;
801037f1:	83 c4 10             	add    $0x10,%esp
        myproc()->rss += PGSIZE;
801037f4:	81 40 04 00 10 00 00 	addl   $0x1000,0x4(%eax)
        swap_slots[swap_slot].is_free = 0;
801037fb:	c7 04 fd 60 3d 11 80 	movl   $0x0,-0x7feec2a0(,%edi,8)
80103802:	00 00 00 00 
        swap_slots[swap_slot].page_perm = 0;
80103806:	c7 04 fd 64 3d 11 80 	movl   $0x0,-0x7feec29c(,%edi,8)
8010380d:	00 00 00 00 
}
80103811:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103814:	5b                   	pop    %ebx
80103815:	5e                   	pop    %esi
80103816:	5f                   	pop    %edi
80103817:	5d                   	pop    %ebp
80103818:	c3                   	ret    
          panic("page_fault_handler: kalloc failed");
80103819:	83 ec 0c             	sub    $0xc,%esp
8010381c:	68 9c 7c 10 80       	push   $0x80107c9c
80103821:	e8 6a cc ff ff       	call   80100490 <panic>
80103826:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010382d:	8d 76 00             	lea    0x0(%esi),%esi

80103830 <page_out>:

void page_out() // we have to set the PTE_P entry to 0
{
80103830:	f3 0f 1e fb          	endbr32 
80103834:	55                   	push   %ebp
80103835:	89 e5                	mov    %esp,%ebp
80103837:	57                   	push   %edi
80103838:	56                   	push   %esi
80103839:	53                   	push   %ebx
    pte_t* victime_page = choose_page(victim_proc);
    // cprintf("Page out enetered\n");
    // cprintf("SWAPOUT START: The pte entry is %x %x\n", victime_page, P2V(*victime_page));
    int f = 0;
    // pte_t* data=0;
    for (int i=0; i < SWAPSLOTS; i++)
8010383a:	31 db                	xor    %ebx,%ebx
{
8010383c:	83 ec 1c             	sub    $0x1c,%esp
    return find_proc();
8010383f:	e8 0c 10 00 00       	call   80104850 <find_proc>
    pte_t* victime_page = choose_page(victim_proc);
80103844:	83 ec 0c             	sub    $0xc,%esp
80103847:	50                   	push   %eax
80103848:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010384b:	e8 c0 fe ff ff       	call   80103710 <choose_page>
    for (int i=0; i < SWAPSLOTS; i++)
80103850:	8b 55 e4             	mov    -0x1c(%ebp),%edx
    pte_t* victime_page = choose_page(victim_proc);
80103853:	83 c4 10             	add    $0x10,%esp
80103856:	89 c6                	mov    %eax,%esi
    for (int i=0; i < SWAPSLOTS; i++)
80103858:	eb 11                	jmp    8010386b <page_out+0x3b>
8010385a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80103860:	83 c3 01             	add    $0x1,%ebx
80103863:	81 fb 2c 01 00 00    	cmp    $0x12c,%ebx
80103869:	74 75                	je     801038e0 <page_out+0xb0>
    {
      
      if (swap_slots[i].is_free == 0) {
8010386b:	8b 04 dd 60 3d 11 80 	mov    -0x7feec2a0(,%ebx,8),%eax
80103872:	85 c0                	test   %eax,%eax
80103874:	75 ea                	jne    80103860 <page_out+0x30>
        f = 1;
        char* page = (char*) P2V(PTE_ADDR(*victime_page));
80103876:	8b 3e                	mov    (%esi),%edi
        // data=(pte_t *)(P2V(PTE_ADDR(*victime_page))) ; 
        // char* data;
        // memmove(data, (char*)P2V(PTE_ADDR(*victime_page)), PGSIZE); // changed by Adithya
        //cprintf("write page to disk called with i= %d \n",i);
        // write_page_to_disk( (char *) victime_page, (uint) (2+8*i));//1 added for debugging// confirm if this function takes physical address or virtual address.
        write_page_to_disk(page, 2+8*i);
80103878:	83 ec 08             	sub    $0x8,%esp
8010387b:	8d 04 dd 02 00 00 00 	lea    0x2(,%ebx,8),%eax
80103882:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80103885:	50                   	push   %eax
        char* page = (char*) P2V(PTE_ADDR(*victime_page));
80103886:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
8010388c:	81 c7 00 00 00 80    	add    $0x80000000,%edi
        write_page_to_disk(page, 2+8*i);
80103892:	57                   	push   %edi
80103893:	e8 18 ca ff ff       	call   801002b0 <write_page_to_disk>
        //  wsect(2+8*i+j, data);
        //  data += BSIZE;
        // }
        *victime_page = (i << 12) | (*victime_page & 0xFFF);
        *victime_page &= ~PTE_P;
        victim_proc->rss -= PGSIZE;
80103898:	8b 55 e4             	mov    -0x1c(%ebp),%edx
        swap_slots[i].is_free = 1;
8010389b:	c7 04 dd 60 3d 11 80 	movl   $0x1,-0x7feec2a0(,%ebx,8)
801038a2:	01 00 00 00 
        swap_slots[i].page_perm = *victime_page & 0xFFF;
801038a6:	8b 06                	mov    (%esi),%eax
801038a8:	25 ff 0f 00 00       	and    $0xfff,%eax
801038ad:	89 04 dd 64 3d 11 80 	mov    %eax,-0x7feec29c(,%ebx,8)
        *victime_page = (i << 12) | (*victime_page & 0xFFF);
801038b4:	8b 06                	mov    (%esi),%eax
801038b6:	c1 e3 0c             	shl    $0xc,%ebx
801038b9:	25 fe 0f 00 00       	and    $0xffe,%eax
        *victime_page &= ~PTE_P;
801038be:	09 c3                	or     %eax,%ebx
801038c0:	89 1e                	mov    %ebx,(%esi)
        victim_proc->rss -= PGSIZE;
801038c2:	81 6a 04 00 10 00 00 	subl   $0x1000,0x4(%edx)
        kfree(page);
801038c9:	89 3c 24             	mov    %edi,(%esp)
801038cc:	e8 9f ec ff ff       	call   80102570 <kfree>
801038d1:	83 c4 10             	add    $0x10,%esp
    if (f == 0) {
      cprintf("No free swapslots\n");
    }
    // cprintf("Success\n");
    // return data;    //return victime_page;  Changed by Adithya
}
801038d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801038d7:	5b                   	pop    %ebx
801038d8:	5e                   	pop    %esi
801038d9:	5f                   	pop    %edi
801038da:	5d                   	pop    %ebp
801038db:	c3                   	ret    
801038dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      cprintf("No free swapslots\n");
801038e0:	83 ec 0c             	sub    $0xc,%esp
801038e3:	68 be 7c 10 80       	push   $0x80107cbe
801038e8:	e8 c3 ce ff ff       	call   801007b0 <cprintf>
801038ed:	83 c4 10             	add    $0x10,%esp
}
801038f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801038f3:	5b                   	pop    %ebx
801038f4:	5e                   	pop    %esi
801038f5:	5f                   	pop    %edi
801038f6:	5d                   	pop    %ebp
801038f7:	c3                   	ret    
801038f8:	66 90                	xchg   %ax,%ax
801038fa:	66 90                	xchg   %ax,%ax
801038fc:	66 90                	xchg   %ax,%ax
801038fe:	66 90                	xchg   %ax,%ax

80103900 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80103900:	f3 0f 1e fb          	endbr32 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103904:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103909:	ba 21 00 00 00       	mov    $0x21,%edx
8010390e:	ee                   	out    %al,(%dx)
8010390f:	ba a1 00 00 00       	mov    $0xa1,%edx
80103914:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80103915:	c3                   	ret    
80103916:	66 90                	xchg   %ax,%ax
80103918:	66 90                	xchg   %ax,%ax
8010391a:	66 90                	xchg   %ax,%ax
8010391c:	66 90                	xchg   %ax,%ax
8010391e:	66 90                	xchg   %ax,%ax

80103920 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103920:	f3 0f 1e fb          	endbr32 
80103924:	55                   	push   %ebp
80103925:	89 e5                	mov    %esp,%ebp
80103927:	57                   	push   %edi
80103928:	56                   	push   %esi
80103929:	53                   	push   %ebx
8010392a:	83 ec 0c             	sub    $0xc,%esp
8010392d:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103930:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80103933:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80103939:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010393f:	e8 bc d5 ff ff       	call   80100f00 <filealloc>
80103944:	89 03                	mov    %eax,(%ebx)
80103946:	85 c0                	test   %eax,%eax
80103948:	0f 84 ac 00 00 00    	je     801039fa <pipealloc+0xda>
8010394e:	e8 ad d5 ff ff       	call   80100f00 <filealloc>
80103953:	89 06                	mov    %eax,(%esi)
80103955:	85 c0                	test   %eax,%eax
80103957:	0f 84 8b 00 00 00    	je     801039e8 <pipealloc+0xc8>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
8010395d:	e8 fe ed ff ff       	call   80102760 <kalloc>
80103962:	89 c7                	mov    %eax,%edi
80103964:	85 c0                	test   %eax,%eax
80103966:	0f 84 b4 00 00 00    	je     80103a20 <pipealloc+0x100>
    goto bad;
  p->readopen = 1;
8010396c:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103973:	00 00 00 
  p->writeopen = 1;
  p->nwrite = 0;
  p->nread = 0;
  initlock(&p->lock, "pipe");
80103976:	83 ec 08             	sub    $0x8,%esp
  p->writeopen = 1;
80103979:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80103980:	00 00 00 
  p->nwrite = 0;
80103983:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
8010398a:	00 00 00 
  p->nread = 0;
8010398d:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103994:	00 00 00 
  initlock(&p->lock, "pipe");
80103997:	68 d1 7c 10 80       	push   $0x80107cd1
8010399c:	50                   	push   %eax
8010399d:	e8 3e 10 00 00       	call   801049e0 <initlock>
  (*f0)->type = FD_PIPE;
801039a2:	8b 03                	mov    (%ebx),%eax
  (*f0)->pipe = p;
  (*f1)->type = FD_PIPE;
  (*f1)->readable = 0;
  (*f1)->writable = 1;
  (*f1)->pipe = p;
  return 0;
801039a4:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801039a7:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801039ad:	8b 03                	mov    (%ebx),%eax
801039af:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801039b3:	8b 03                	mov    (%ebx),%eax
801039b5:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801039b9:	8b 03                	mov    (%ebx),%eax
801039bb:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
801039be:	8b 06                	mov    (%esi),%eax
801039c0:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801039c6:	8b 06                	mov    (%esi),%eax
801039c8:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801039cc:	8b 06                	mov    (%esi),%eax
801039ce:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801039d2:	8b 06                	mov    (%esi),%eax
801039d4:	89 78 0c             	mov    %edi,0xc(%eax)
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
801039d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801039da:	31 c0                	xor    %eax,%eax
}
801039dc:	5b                   	pop    %ebx
801039dd:	5e                   	pop    %esi
801039de:	5f                   	pop    %edi
801039df:	5d                   	pop    %ebp
801039e0:	c3                   	ret    
801039e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(*f0)
801039e8:	8b 03                	mov    (%ebx),%eax
801039ea:	85 c0                	test   %eax,%eax
801039ec:	74 1e                	je     80103a0c <pipealloc+0xec>
    fileclose(*f0);
801039ee:	83 ec 0c             	sub    $0xc,%esp
801039f1:	50                   	push   %eax
801039f2:	e8 c9 d5 ff ff       	call   80100fc0 <fileclose>
801039f7:	83 c4 10             	add    $0x10,%esp
  if(*f1)
801039fa:	8b 06                	mov    (%esi),%eax
801039fc:	85 c0                	test   %eax,%eax
801039fe:	74 0c                	je     80103a0c <pipealloc+0xec>
    fileclose(*f1);
80103a00:	83 ec 0c             	sub    $0xc,%esp
80103a03:	50                   	push   %eax
80103a04:	e8 b7 d5 ff ff       	call   80100fc0 <fileclose>
80103a09:	83 c4 10             	add    $0x10,%esp
}
80103a0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
80103a0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103a14:	5b                   	pop    %ebx
80103a15:	5e                   	pop    %esi
80103a16:	5f                   	pop    %edi
80103a17:	5d                   	pop    %ebp
80103a18:	c3                   	ret    
80103a19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(*f0)
80103a20:	8b 03                	mov    (%ebx),%eax
80103a22:	85 c0                	test   %eax,%eax
80103a24:	75 c8                	jne    801039ee <pipealloc+0xce>
80103a26:	eb d2                	jmp    801039fa <pipealloc+0xda>
80103a28:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103a2f:	90                   	nop

80103a30 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103a30:	f3 0f 1e fb          	endbr32 
80103a34:	55                   	push   %ebp
80103a35:	89 e5                	mov    %esp,%ebp
80103a37:	56                   	push   %esi
80103a38:	53                   	push   %ebx
80103a39:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103a3c:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
80103a3f:	83 ec 0c             	sub    $0xc,%esp
80103a42:	53                   	push   %ebx
80103a43:	e8 18 11 00 00       	call   80104b60 <acquire>
  if(writable){
80103a48:	83 c4 10             	add    $0x10,%esp
80103a4b:	85 f6                	test   %esi,%esi
80103a4d:	74 41                	je     80103a90 <pipeclose+0x60>
    p->writeopen = 0;
    wakeup(&p->nread);
80103a4f:	83 ec 0c             	sub    $0xc,%esp
80103a52:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
    p->writeopen = 0;
80103a58:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80103a5f:	00 00 00 
    wakeup(&p->nread);
80103a62:	50                   	push   %eax
80103a63:	e8 28 0c 00 00       	call   80104690 <wakeup>
80103a68:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103a6b:	8b 93 3c 02 00 00    	mov    0x23c(%ebx),%edx
80103a71:	85 d2                	test   %edx,%edx
80103a73:	75 0a                	jne    80103a7f <pipeclose+0x4f>
80103a75:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80103a7b:	85 c0                	test   %eax,%eax
80103a7d:	74 31                	je     80103ab0 <pipeclose+0x80>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80103a7f:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
80103a82:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a85:	5b                   	pop    %ebx
80103a86:	5e                   	pop    %esi
80103a87:	5d                   	pop    %ebp
    release(&p->lock);
80103a88:	e9 93 11 00 00       	jmp    80104c20 <release>
80103a8d:	8d 76 00             	lea    0x0(%esi),%esi
    wakeup(&p->nwrite);
80103a90:	83 ec 0c             	sub    $0xc,%esp
80103a93:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
    p->readopen = 0;
80103a99:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80103aa0:	00 00 00 
    wakeup(&p->nwrite);
80103aa3:	50                   	push   %eax
80103aa4:	e8 e7 0b 00 00       	call   80104690 <wakeup>
80103aa9:	83 c4 10             	add    $0x10,%esp
80103aac:	eb bd                	jmp    80103a6b <pipeclose+0x3b>
80103aae:	66 90                	xchg   %ax,%ax
    release(&p->lock);
80103ab0:	83 ec 0c             	sub    $0xc,%esp
80103ab3:	53                   	push   %ebx
80103ab4:	e8 67 11 00 00       	call   80104c20 <release>
    kfree((char*)p);
80103ab9:	89 5d 08             	mov    %ebx,0x8(%ebp)
80103abc:	83 c4 10             	add    $0x10,%esp
}
80103abf:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ac2:	5b                   	pop    %ebx
80103ac3:	5e                   	pop    %esi
80103ac4:	5d                   	pop    %ebp
    kfree((char*)p);
80103ac5:	e9 a6 ea ff ff       	jmp    80102570 <kfree>
80103aca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103ad0 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80103ad0:	f3 0f 1e fb          	endbr32 
80103ad4:	55                   	push   %ebp
80103ad5:	89 e5                	mov    %esp,%ebp
80103ad7:	57                   	push   %edi
80103ad8:	56                   	push   %esi
80103ad9:	53                   	push   %ebx
80103ada:	83 ec 28             	sub    $0x28,%esp
80103add:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80103ae0:	53                   	push   %ebx
80103ae1:	e8 7a 10 00 00       	call   80104b60 <acquire>
  for(i = 0; i < n; i++){
80103ae6:	8b 45 10             	mov    0x10(%ebp),%eax
80103ae9:	83 c4 10             	add    $0x10,%esp
80103aec:	85 c0                	test   %eax,%eax
80103aee:	0f 8e bc 00 00 00    	jle    80103bb0 <pipewrite+0xe0>
80103af4:	8b 45 0c             	mov    0xc(%ebp),%eax
80103af7:	8b 8b 38 02 00 00    	mov    0x238(%ebx),%ecx
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || myproc()->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80103afd:	8d bb 34 02 00 00    	lea    0x234(%ebx),%edi
80103b03:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103b06:	03 45 10             	add    0x10(%ebp),%eax
80103b09:	89 45 e0             	mov    %eax,-0x20(%ebp)
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103b0c:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103b12:	8d b3 38 02 00 00    	lea    0x238(%ebx),%esi
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103b18:	89 ca                	mov    %ecx,%edx
80103b1a:	05 00 02 00 00       	add    $0x200,%eax
80103b1f:	39 c1                	cmp    %eax,%ecx
80103b21:	74 3b                	je     80103b5e <pipewrite+0x8e>
80103b23:	eb 63                	jmp    80103b88 <pipewrite+0xb8>
80103b25:	8d 76 00             	lea    0x0(%esi),%esi
      if(p->readopen == 0 || myproc()->killed){
80103b28:	e8 73 03 00 00       	call   80103ea0 <myproc>
80103b2d:	8b 48 28             	mov    0x28(%eax),%ecx
80103b30:	85 c9                	test   %ecx,%ecx
80103b32:	75 34                	jne    80103b68 <pipewrite+0x98>
      wakeup(&p->nread);
80103b34:	83 ec 0c             	sub    $0xc,%esp
80103b37:	57                   	push   %edi
80103b38:	e8 53 0b 00 00       	call   80104690 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103b3d:	58                   	pop    %eax
80103b3e:	5a                   	pop    %edx
80103b3f:	53                   	push   %ebx
80103b40:	56                   	push   %esi
80103b41:	e8 8a 09 00 00       	call   801044d0 <sleep>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103b46:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103b4c:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80103b52:	83 c4 10             	add    $0x10,%esp
80103b55:	05 00 02 00 00       	add    $0x200,%eax
80103b5a:	39 c2                	cmp    %eax,%edx
80103b5c:	75 2a                	jne    80103b88 <pipewrite+0xb8>
      if(p->readopen == 0 || myproc()->killed){
80103b5e:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
80103b64:	85 c0                	test   %eax,%eax
80103b66:	75 c0                	jne    80103b28 <pipewrite+0x58>
        release(&p->lock);
80103b68:	83 ec 0c             	sub    $0xc,%esp
80103b6b:	53                   	push   %ebx
80103b6c:	e8 af 10 00 00       	call   80104c20 <release>
        return -1;
80103b71:	83 c4 10             	add    $0x10,%esp
80103b74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80103b79:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103b7c:	5b                   	pop    %ebx
80103b7d:	5e                   	pop    %esi
80103b7e:	5f                   	pop    %edi
80103b7f:	5d                   	pop    %ebp
80103b80:	c3                   	ret    
80103b81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103b88:	8b 75 e4             	mov    -0x1c(%ebp),%esi
80103b8b:	8d 4a 01             	lea    0x1(%edx),%ecx
80103b8e:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80103b94:	89 8b 38 02 00 00    	mov    %ecx,0x238(%ebx)
80103b9a:	0f b6 06             	movzbl (%esi),%eax
80103b9d:	83 c6 01             	add    $0x1,%esi
80103ba0:	89 75 e4             	mov    %esi,-0x1c(%ebp)
80103ba3:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80103ba7:	3b 75 e0             	cmp    -0x20(%ebp),%esi
80103baa:	0f 85 5c ff ff ff    	jne    80103b0c <pipewrite+0x3c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103bb0:	83 ec 0c             	sub    $0xc,%esp
80103bb3:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103bb9:	50                   	push   %eax
80103bba:	e8 d1 0a 00 00       	call   80104690 <wakeup>
  release(&p->lock);
80103bbf:	89 1c 24             	mov    %ebx,(%esp)
80103bc2:	e8 59 10 00 00       	call   80104c20 <release>
  return n;
80103bc7:	8b 45 10             	mov    0x10(%ebp),%eax
80103bca:	83 c4 10             	add    $0x10,%esp
80103bcd:	eb aa                	jmp    80103b79 <pipewrite+0xa9>
80103bcf:	90                   	nop

80103bd0 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103bd0:	f3 0f 1e fb          	endbr32 
80103bd4:	55                   	push   %ebp
80103bd5:	89 e5                	mov    %esp,%ebp
80103bd7:	57                   	push   %edi
80103bd8:	56                   	push   %esi
80103bd9:	53                   	push   %ebx
80103bda:	83 ec 18             	sub    $0x18,%esp
80103bdd:	8b 75 08             	mov    0x8(%ebp),%esi
80103be0:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
80103be3:	56                   	push   %esi
80103be4:	8d 9e 34 02 00 00    	lea    0x234(%esi),%ebx
80103bea:	e8 71 0f 00 00       	call   80104b60 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103bef:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
80103bf5:	83 c4 10             	add    $0x10,%esp
80103bf8:	39 86 38 02 00 00    	cmp    %eax,0x238(%esi)
80103bfe:	74 33                	je     80103c33 <piperead+0x63>
80103c00:	eb 3b                	jmp    80103c3d <piperead+0x6d>
80103c02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(myproc()->killed){
80103c08:	e8 93 02 00 00       	call   80103ea0 <myproc>
80103c0d:	8b 48 28             	mov    0x28(%eax),%ecx
80103c10:	85 c9                	test   %ecx,%ecx
80103c12:	0f 85 88 00 00 00    	jne    80103ca0 <piperead+0xd0>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103c18:	83 ec 08             	sub    $0x8,%esp
80103c1b:	56                   	push   %esi
80103c1c:	53                   	push   %ebx
80103c1d:	e8 ae 08 00 00       	call   801044d0 <sleep>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103c22:	8b 86 38 02 00 00    	mov    0x238(%esi),%eax
80103c28:	83 c4 10             	add    $0x10,%esp
80103c2b:	39 86 34 02 00 00    	cmp    %eax,0x234(%esi)
80103c31:	75 0a                	jne    80103c3d <piperead+0x6d>
80103c33:	8b 86 40 02 00 00    	mov    0x240(%esi),%eax
80103c39:	85 c0                	test   %eax,%eax
80103c3b:	75 cb                	jne    80103c08 <piperead+0x38>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103c3d:	8b 55 10             	mov    0x10(%ebp),%edx
80103c40:	31 db                	xor    %ebx,%ebx
80103c42:	85 d2                	test   %edx,%edx
80103c44:	7f 28                	jg     80103c6e <piperead+0x9e>
80103c46:	eb 34                	jmp    80103c7c <piperead+0xac>
80103c48:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103c4f:	90                   	nop
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103c50:	8d 48 01             	lea    0x1(%eax),%ecx
80103c53:	25 ff 01 00 00       	and    $0x1ff,%eax
80103c58:	89 8e 34 02 00 00    	mov    %ecx,0x234(%esi)
80103c5e:	0f b6 44 06 34       	movzbl 0x34(%esi,%eax,1),%eax
80103c63:	88 04 1f             	mov    %al,(%edi,%ebx,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103c66:	83 c3 01             	add    $0x1,%ebx
80103c69:	39 5d 10             	cmp    %ebx,0x10(%ebp)
80103c6c:	74 0e                	je     80103c7c <piperead+0xac>
    if(p->nread == p->nwrite)
80103c6e:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
80103c74:	3b 86 38 02 00 00    	cmp    0x238(%esi),%eax
80103c7a:	75 d4                	jne    80103c50 <piperead+0x80>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103c7c:	83 ec 0c             	sub    $0xc,%esp
80103c7f:	8d 86 38 02 00 00    	lea    0x238(%esi),%eax
80103c85:	50                   	push   %eax
80103c86:	e8 05 0a 00 00       	call   80104690 <wakeup>
  release(&p->lock);
80103c8b:	89 34 24             	mov    %esi,(%esp)
80103c8e:	e8 8d 0f 00 00       	call   80104c20 <release>
  return i;
80103c93:	83 c4 10             	add    $0x10,%esp
}
80103c96:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103c99:	89 d8                	mov    %ebx,%eax
80103c9b:	5b                   	pop    %ebx
80103c9c:	5e                   	pop    %esi
80103c9d:	5f                   	pop    %edi
80103c9e:	5d                   	pop    %ebp
80103c9f:	c3                   	ret    
      release(&p->lock);
80103ca0:	83 ec 0c             	sub    $0xc,%esp
      return -1;
80103ca3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
      release(&p->lock);
80103ca8:	56                   	push   %esi
80103ca9:	e8 72 0f 00 00       	call   80104c20 <release>
      return -1;
80103cae:	83 c4 10             	add    $0x10,%esp
}
80103cb1:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103cb4:	89 d8                	mov    %ebx,%eax
80103cb6:	5b                   	pop    %ebx
80103cb7:	5e                   	pop    %esi
80103cb8:	5f                   	pop    %edi
80103cb9:	5d                   	pop    %ebp
80103cba:	c3                   	ret    
80103cbb:	66 90                	xchg   %ax,%ax
80103cbd:	66 90                	xchg   %ax,%ax
80103cbf:	90                   	nop

80103cc0 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80103cc0:	55                   	push   %ebp
80103cc1:	89 e5                	mov    %esp,%ebp
80103cc3:	53                   	push   %ebx
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103cc4:	bb f4 46 11 80       	mov    $0x801146f4,%ebx
{
80103cc9:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
80103ccc:	68 c0 46 11 80       	push   $0x801146c0
80103cd1:	e8 8a 0e 00 00       	call   80104b60 <acquire>
80103cd6:	83 c4 10             	add    $0x10,%esp
80103cd9:	eb 14                	jmp    80103cef <allocproc+0x2f>
80103cdb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103cdf:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103ce0:	83 eb 80             	sub    $0xffffff80,%ebx
80103ce3:	81 fb f4 66 11 80    	cmp    $0x801166f4,%ebx
80103ce9:	0f 84 81 00 00 00    	je     80103d70 <allocproc+0xb0>
    if(p->state == UNUSED)
80103cef:	8b 43 10             	mov    0x10(%ebx),%eax
80103cf2:	85 c0                	test   %eax,%eax
80103cf4:	75 ea                	jne    80103ce0 <allocproc+0x20>
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
80103cf6:	a1 04 b0 10 80       	mov    0x8010b004,%eax
  p->rss = PGSIZE;
  release(&ptable.lock);
80103cfb:	83 ec 0c             	sub    $0xc,%esp
  p->state = EMBRYO;
80103cfe:	c7 43 10 01 00 00 00 	movl   $0x1,0x10(%ebx)
  p->rss = PGSIZE;
80103d05:	c7 43 04 00 10 00 00 	movl   $0x1000,0x4(%ebx)
  p->pid = nextpid++;
80103d0c:	89 43 14             	mov    %eax,0x14(%ebx)
80103d0f:	8d 50 01             	lea    0x1(%eax),%edx
  release(&ptable.lock);
80103d12:	68 c0 46 11 80       	push   $0x801146c0
  p->pid = nextpid++;
80103d17:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
  release(&ptable.lock);
80103d1d:	e8 fe 0e 00 00       	call   80104c20 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
80103d22:	e8 39 ea ff ff       	call   80102760 <kalloc>
80103d27:	83 c4 10             	add    $0x10,%esp
80103d2a:	89 43 0c             	mov    %eax,0xc(%ebx)
80103d2d:	85 c0                	test   %eax,%eax
80103d2f:	74 58                	je     80103d89 <allocproc+0xc9>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103d31:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
80103d37:	83 ec 04             	sub    $0x4,%esp
  sp -= sizeof *p->context;
80103d3a:	05 9c 0f 00 00       	add    $0xf9c,%eax
  sp -= sizeof *p->tf;
80103d3f:	89 53 1c             	mov    %edx,0x1c(%ebx)
  *(uint*)sp = (uint)trapret;
80103d42:	c7 40 14 b6 5e 10 80 	movl   $0x80105eb6,0x14(%eax)
  p->context = (struct context*)sp;
80103d49:	89 43 20             	mov    %eax,0x20(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103d4c:	6a 14                	push   $0x14
80103d4e:	6a 00                	push   $0x0
80103d50:	50                   	push   %eax
80103d51:	e8 1a 0f 00 00       	call   80104c70 <memset>
  p->context->eip = (uint)forkret;
80103d56:	8b 43 20             	mov    0x20(%ebx),%eax
  
  return p;
80103d59:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103d5c:	c7 40 10 a0 3d 10 80 	movl   $0x80103da0,0x10(%eax)
}
80103d63:	89 d8                	mov    %ebx,%eax
80103d65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d68:	c9                   	leave  
80103d69:	c3                   	ret    
80103d6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  release(&ptable.lock);
80103d70:	83 ec 0c             	sub    $0xc,%esp
  return 0;
80103d73:	31 db                	xor    %ebx,%ebx
  release(&ptable.lock);
80103d75:	68 c0 46 11 80       	push   $0x801146c0
80103d7a:	e8 a1 0e 00 00       	call   80104c20 <release>
}
80103d7f:	89 d8                	mov    %ebx,%eax
  return 0;
80103d81:	83 c4 10             	add    $0x10,%esp
}
80103d84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d87:	c9                   	leave  
80103d88:	c3                   	ret    
    p->state = UNUSED;
80103d89:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
    return 0;
80103d90:	31 db                	xor    %ebx,%ebx
}
80103d92:	89 d8                	mov    %ebx,%eax
80103d94:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d97:	c9                   	leave  
80103d98:	c3                   	ret    
80103d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103da0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80103da0:	f3 0f 1e fb          	endbr32 
80103da4:	55                   	push   %ebp
80103da5:	89 e5                	mov    %esp,%ebp
80103da7:	83 ec 14             	sub    $0x14,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80103daa:	68 c0 46 11 80       	push   $0x801146c0
80103daf:	e8 6c 0e 00 00       	call   80104c20 <release>

  if (first) {
80103db4:	a1 00 b0 10 80       	mov    0x8010b000,%eax
80103db9:	83 c4 10             	add    $0x10,%esp
80103dbc:	85 c0                	test   %eax,%eax
80103dbe:	75 08                	jne    80103dc8 <forkret+0x28>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
80103dc0:	c9                   	leave  
80103dc1:	c3                   	ret    
80103dc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    first = 0;
80103dc8:	c7 05 00 b0 10 80 00 	movl   $0x0,0x8010b000
80103dcf:	00 00 00 
    iinit(ROOTDEV);
80103dd2:	83 ec 0c             	sub    $0xc,%esp
80103dd5:	6a 01                	push   $0x1
80103dd7:	e8 64 d8 ff ff       	call   80101640 <iinit>
    initlog(ROOTDEV);
80103ddc:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103de3:	e8 b8 f0 ff ff       	call   80102ea0 <initlog>
}
80103de8:	83 c4 10             	add    $0x10,%esp
80103deb:	c9                   	leave  
80103dec:	c3                   	ret    
80103ded:	8d 76 00             	lea    0x0(%esi),%esi

80103df0 <pinit>:
{
80103df0:	f3 0f 1e fb          	endbr32 
80103df4:	55                   	push   %ebp
80103df5:	89 e5                	mov    %esp,%ebp
80103df7:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103dfa:	68 d6 7c 10 80       	push   $0x80107cd6
80103dff:	68 c0 46 11 80       	push   $0x801146c0
80103e04:	e8 d7 0b 00 00       	call   801049e0 <initlock>
}
80103e09:	83 c4 10             	add    $0x10,%esp
80103e0c:	c9                   	leave  
80103e0d:	c3                   	ret    
80103e0e:	66 90                	xchg   %ax,%ax

80103e10 <mycpu>:
{
80103e10:	f3 0f 1e fb          	endbr32 
80103e14:	55                   	push   %ebp
80103e15:	89 e5                	mov    %esp,%ebp
80103e17:	56                   	push   %esi
80103e18:	53                   	push   %ebx
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103e19:	9c                   	pushf  
80103e1a:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103e1b:	f6 c4 02             	test   $0x2,%ah
80103e1e:	75 4a                	jne    80103e6a <mycpu+0x5a>
  apicid = lapicid();
80103e20:	e8 8b ec ff ff       	call   80102ab0 <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103e25:	8b 35 40 3d 11 80    	mov    0x80113d40,%esi
  apicid = lapicid();
80103e2b:	89 c3                	mov    %eax,%ebx
  for (i = 0; i < ncpu; ++i) {
80103e2d:	85 f6                	test   %esi,%esi
80103e2f:	7e 2c                	jle    80103e5d <mycpu+0x4d>
80103e31:	31 d2                	xor    %edx,%edx
80103e33:	eb 0a                	jmp    80103e3f <mycpu+0x2f>
80103e35:	8d 76 00             	lea    0x0(%esi),%esi
80103e38:	83 c2 01             	add    $0x1,%edx
80103e3b:	39 f2                	cmp    %esi,%edx
80103e3d:	74 1e                	je     80103e5d <mycpu+0x4d>
    if (cpus[i].apicid == apicid)
80103e3f:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
80103e45:	0f b6 81 c0 37 11 80 	movzbl -0x7feec840(%ecx),%eax
80103e4c:	39 d8                	cmp    %ebx,%eax
80103e4e:	75 e8                	jne    80103e38 <mycpu+0x28>
}
80103e50:	8d 65 f8             	lea    -0x8(%ebp),%esp
      return &cpus[i];
80103e53:	8d 81 c0 37 11 80    	lea    -0x7feec840(%ecx),%eax
}
80103e59:	5b                   	pop    %ebx
80103e5a:	5e                   	pop    %esi
80103e5b:	5d                   	pop    %ebp
80103e5c:	c3                   	ret    
  panic("unknown apicid\n");
80103e5d:	83 ec 0c             	sub    $0xc,%esp
80103e60:	68 dd 7c 10 80       	push   $0x80107cdd
80103e65:	e8 26 c6 ff ff       	call   80100490 <panic>
    panic("mycpu called with interrupts enabled\n");
80103e6a:	83 ec 0c             	sub    $0xc,%esp
80103e6d:	68 c8 7d 10 80       	push   $0x80107dc8
80103e72:	e8 19 c6 ff ff       	call   80100490 <panic>
80103e77:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103e7e:	66 90                	xchg   %ax,%ax

80103e80 <cpuid>:
cpuid() {
80103e80:	f3 0f 1e fb          	endbr32 
80103e84:	55                   	push   %ebp
80103e85:	89 e5                	mov    %esp,%ebp
80103e87:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103e8a:	e8 81 ff ff ff       	call   80103e10 <mycpu>
}
80103e8f:	c9                   	leave  
  return mycpu()-cpus;
80103e90:	2d c0 37 11 80       	sub    $0x801137c0,%eax
80103e95:	c1 f8 04             	sar    $0x4,%eax
80103e98:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103e9e:	c3                   	ret    
80103e9f:	90                   	nop

80103ea0 <myproc>:
myproc(void) {
80103ea0:	f3 0f 1e fb          	endbr32 
80103ea4:	55                   	push   %ebp
80103ea5:	89 e5                	mov    %esp,%ebp
80103ea7:	53                   	push   %ebx
80103ea8:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103eab:	e8 b0 0b 00 00       	call   80104a60 <pushcli>
  c = mycpu();
80103eb0:	e8 5b ff ff ff       	call   80103e10 <mycpu>
  p = c->proc;
80103eb5:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103ebb:	e8 f0 0b 00 00       	call   80104ab0 <popcli>
}
80103ec0:	83 c4 04             	add    $0x4,%esp
80103ec3:	89 d8                	mov    %ebx,%eax
80103ec5:	5b                   	pop    %ebx
80103ec6:	5d                   	pop    %ebp
80103ec7:	c3                   	ret    
80103ec8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103ecf:	90                   	nop

80103ed0 <userinit>:
{
80103ed0:	f3 0f 1e fb          	endbr32 
80103ed4:	55                   	push   %ebp
80103ed5:	89 e5                	mov    %esp,%ebp
80103ed7:	53                   	push   %ebx
80103ed8:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103edb:	e8 e0 fd ff ff       	call   80103cc0 <allocproc>
80103ee0:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103ee2:	a3 b8 b5 10 80       	mov    %eax,0x8010b5b8
  if((p->pgdir = setupkvm()) == 0)
80103ee7:	e8 d4 35 00 00       	call   801074c0 <setupkvm>
80103eec:	89 43 08             	mov    %eax,0x8(%ebx)
80103eef:	85 c0                	test   %eax,%eax
80103ef1:	0f 84 bd 00 00 00    	je     80103fb4 <userinit+0xe4>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103ef7:	83 ec 04             	sub    $0x4,%esp
80103efa:	68 2c 00 00 00       	push   $0x2c
80103eff:	68 60 b4 10 80       	push   $0x8010b460
80103f04:	50                   	push   %eax
80103f05:	e8 76 32 00 00       	call   80107180 <inituvm>
  memset(p->tf, 0, sizeof(*p->tf));
80103f0a:	83 c4 0c             	add    $0xc,%esp
  p->sz = PGSIZE;
80103f0d:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103f13:	6a 4c                	push   $0x4c
80103f15:	6a 00                	push   $0x0
80103f17:	ff 73 1c             	pushl  0x1c(%ebx)
80103f1a:	e8 51 0d 00 00       	call   80104c70 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103f1f:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103f22:	ba 1b 00 00 00       	mov    $0x1b,%edx
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103f27:	83 c4 0c             	add    $0xc,%esp
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103f2a:	b9 23 00 00 00       	mov    $0x23,%ecx
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103f2f:	66 89 50 3c          	mov    %dx,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103f33:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103f36:	66 89 48 2c          	mov    %cx,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103f3a:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103f3d:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103f41:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103f45:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103f48:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103f4c:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103f50:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103f53:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103f5a:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103f5d:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103f64:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103f67:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103f6e:	8d 43 70             	lea    0x70(%ebx),%eax
80103f71:	6a 10                	push   $0x10
80103f73:	68 06 7d 10 80       	push   $0x80107d06
80103f78:	50                   	push   %eax
80103f79:	e8 b2 0e 00 00       	call   80104e30 <safestrcpy>
  p->cwd = namei("/");
80103f7e:	c7 04 24 0f 7d 10 80 	movl   $0x80107d0f,(%esp)
80103f85:	e8 a6 e1 ff ff       	call   80102130 <namei>
80103f8a:	89 43 6c             	mov    %eax,0x6c(%ebx)
  acquire(&ptable.lock);
80103f8d:	c7 04 24 c0 46 11 80 	movl   $0x801146c0,(%esp)
80103f94:	e8 c7 0b 00 00       	call   80104b60 <acquire>
  p->state = RUNNABLE;
80103f99:	c7 43 10 03 00 00 00 	movl   $0x3,0x10(%ebx)
  release(&ptable.lock);
80103fa0:	c7 04 24 c0 46 11 80 	movl   $0x801146c0,(%esp)
80103fa7:	e8 74 0c 00 00       	call   80104c20 <release>
}
80103fac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103faf:	83 c4 10             	add    $0x10,%esp
80103fb2:	c9                   	leave  
80103fb3:	c3                   	ret    
    panic("userinit: out of memory?");
80103fb4:	83 ec 0c             	sub    $0xc,%esp
80103fb7:	68 ed 7c 10 80       	push   $0x80107ced
80103fbc:	e8 cf c4 ff ff       	call   80100490 <panic>
80103fc1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103fc8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103fcf:	90                   	nop

80103fd0 <growproc>:
{
80103fd0:	f3 0f 1e fb          	endbr32 
80103fd4:	55                   	push   %ebp
80103fd5:	89 e5                	mov    %esp,%ebp
80103fd7:	56                   	push   %esi
80103fd8:	53                   	push   %ebx
80103fd9:	8b 75 08             	mov    0x8(%ebp),%esi
  pushcli();
80103fdc:	e8 7f 0a 00 00       	call   80104a60 <pushcli>
  c = mycpu();
80103fe1:	e8 2a fe ff ff       	call   80103e10 <mycpu>
  p = c->proc;
80103fe6:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103fec:	e8 bf 0a 00 00       	call   80104ab0 <popcli>
  sz = curproc->sz;
80103ff1:	8b 03                	mov    (%ebx),%eax
  if(n > 0){
80103ff3:	85 f6                	test   %esi,%esi
80103ff5:	7f 19                	jg     80104010 <growproc+0x40>
  } else if(n < 0){
80103ff7:	75 37                	jne    80104030 <growproc+0x60>
  switchuvm(curproc);
80103ff9:	83 ec 0c             	sub    $0xc,%esp
  curproc->sz = sz;
80103ffc:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103ffe:	53                   	push   %ebx
80103fff:	e8 6c 30 00 00       	call   80107070 <switchuvm>
  return 0;
80104004:	83 c4 10             	add    $0x10,%esp
80104007:	31 c0                	xor    %eax,%eax
}
80104009:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010400c:	5b                   	pop    %ebx
8010400d:	5e                   	pop    %esi
8010400e:	5d                   	pop    %ebp
8010400f:	c3                   	ret    
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104010:	83 ec 04             	sub    $0x4,%esp
80104013:	01 c6                	add    %eax,%esi
80104015:	56                   	push   %esi
80104016:	50                   	push   %eax
80104017:	ff 73 08             	pushl  0x8(%ebx)
8010401a:	e8 b1 32 00 00       	call   801072d0 <allocuvm>
8010401f:	83 c4 10             	add    $0x10,%esp
80104022:	85 c0                	test   %eax,%eax
80104024:	75 d3                	jne    80103ff9 <growproc+0x29>
      return -1;
80104026:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010402b:	eb dc                	jmp    80104009 <growproc+0x39>
8010402d:	8d 76 00             	lea    0x0(%esi),%esi
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80104030:	83 ec 04             	sub    $0x4,%esp
80104033:	01 c6                	add    %eax,%esi
80104035:	56                   	push   %esi
80104036:	50                   	push   %eax
80104037:	ff 73 08             	pushl  0x8(%ebx)
8010403a:	e8 d1 33 00 00       	call   80107410 <deallocuvm>
8010403f:	83 c4 10             	add    $0x10,%esp
80104042:	85 c0                	test   %eax,%eax
80104044:	75 b3                	jne    80103ff9 <growproc+0x29>
80104046:	eb de                	jmp    80104026 <growproc+0x56>
80104048:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010404f:	90                   	nop

80104050 <fork>:
{
80104050:	f3 0f 1e fb          	endbr32 
80104054:	55                   	push   %ebp
80104055:	89 e5                	mov    %esp,%ebp
80104057:	57                   	push   %edi
80104058:	56                   	push   %esi
80104059:	53                   	push   %ebx
8010405a:	83 ec 1c             	sub    $0x1c,%esp
  pushcli();
8010405d:	e8 fe 09 00 00       	call   80104a60 <pushcli>
  c = mycpu();
80104062:	e8 a9 fd ff ff       	call   80103e10 <mycpu>
  p = c->proc;
80104067:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
8010406d:	e8 3e 0a 00 00       	call   80104ab0 <popcli>
  if((np = allocproc()) == 0){
80104072:	e8 49 fc ff ff       	call   80103cc0 <allocproc>
80104077:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010407a:	85 c0                	test   %eax,%eax
8010407c:	0f 84 c1 00 00 00    	je     80104143 <fork+0xf3>
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80104082:	83 ec 08             	sub    $0x8,%esp
80104085:	ff 33                	pushl  (%ebx)
80104087:	89 c7                	mov    %eax,%edi
80104089:	ff 73 08             	pushl  0x8(%ebx)
8010408c:	e8 ff 34 00 00       	call   80107590 <copyuvm>
80104091:	83 c4 10             	add    $0x10,%esp
80104094:	89 47 08             	mov    %eax,0x8(%edi)
80104097:	85 c0                	test   %eax,%eax
80104099:	0f 84 ab 00 00 00    	je     8010414a <fork+0xfa>
  np->sz = curproc->sz;
8010409f:	8b 03                	mov    (%ebx),%eax
801040a1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801040a4:	89 01                	mov    %eax,(%ecx)
  *np->tf = *curproc->tf;
801040a6:	8b 79 1c             	mov    0x1c(%ecx),%edi
  np->parent = curproc;
801040a9:	89 c8                	mov    %ecx,%eax
801040ab:	89 59 18             	mov    %ebx,0x18(%ecx)
  *np->tf = *curproc->tf;
801040ae:	b9 13 00 00 00       	mov    $0x13,%ecx
801040b3:	8b 73 1c             	mov    0x1c(%ebx),%esi
801040b6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  for(i = 0; i < NOFILE; i++)
801040b8:	31 f6                	xor    %esi,%esi
  np->tf->eax = 0;
801040ba:	8b 40 1c             	mov    0x1c(%eax),%eax
801040bd:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
801040c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(curproc->ofile[i])
801040c8:	8b 44 b3 2c          	mov    0x2c(%ebx,%esi,4),%eax
801040cc:	85 c0                	test   %eax,%eax
801040ce:	74 13                	je     801040e3 <fork+0x93>
      np->ofile[i] = filedup(curproc->ofile[i]);
801040d0:	83 ec 0c             	sub    $0xc,%esp
801040d3:	50                   	push   %eax
801040d4:	e8 97 ce ff ff       	call   80100f70 <filedup>
801040d9:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801040dc:	83 c4 10             	add    $0x10,%esp
801040df:	89 44 b2 2c          	mov    %eax,0x2c(%edx,%esi,4)
  for(i = 0; i < NOFILE; i++)
801040e3:	83 c6 01             	add    $0x1,%esi
801040e6:	83 fe 10             	cmp    $0x10,%esi
801040e9:	75 dd                	jne    801040c8 <fork+0x78>
  np->cwd = idup(curproc->cwd);
801040eb:	83 ec 0c             	sub    $0xc,%esp
801040ee:	ff 73 6c             	pushl  0x6c(%ebx)
801040f1:	e8 3a d7 ff ff       	call   80101830 <idup>
801040f6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801040f9:	83 c4 0c             	add    $0xc,%esp
  np->cwd = idup(curproc->cwd);
801040fc:	89 47 6c             	mov    %eax,0x6c(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801040ff:	8d 43 70             	lea    0x70(%ebx),%eax
80104102:	6a 10                	push   $0x10
80104104:	50                   	push   %eax
80104105:	8d 47 70             	lea    0x70(%edi),%eax
80104108:	50                   	push   %eax
80104109:	e8 22 0d 00 00       	call   80104e30 <safestrcpy>
  pid = np->pid;
8010410e:	8b 77 14             	mov    0x14(%edi),%esi
  acquire(&ptable.lock);
80104111:	c7 04 24 c0 46 11 80 	movl   $0x801146c0,(%esp)
80104118:	e8 43 0a 00 00       	call   80104b60 <acquire>
  np->rss=curproc->rss;
8010411d:	8b 43 04             	mov    0x4(%ebx),%eax
  np->state = RUNNABLE;
80104120:	c7 47 10 03 00 00 00 	movl   $0x3,0x10(%edi)
  np->rss=curproc->rss;
80104127:	89 47 04             	mov    %eax,0x4(%edi)
  release(&ptable.lock);
8010412a:	c7 04 24 c0 46 11 80 	movl   $0x801146c0,(%esp)
80104131:	e8 ea 0a 00 00       	call   80104c20 <release>
  return pid;
80104136:	83 c4 10             	add    $0x10,%esp
}
80104139:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010413c:	89 f0                	mov    %esi,%eax
8010413e:	5b                   	pop    %ebx
8010413f:	5e                   	pop    %esi
80104140:	5f                   	pop    %edi
80104141:	5d                   	pop    %ebp
80104142:	c3                   	ret    
    return -1;
80104143:	be ff ff ff ff       	mov    $0xffffffff,%esi
80104148:	eb ef                	jmp    80104139 <fork+0xe9>
    kfree(np->kstack);
8010414a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010414d:	83 ec 0c             	sub    $0xc,%esp
    return -1;
80104150:	be ff ff ff ff       	mov    $0xffffffff,%esi
    kfree(np->kstack);
80104155:	ff 73 0c             	pushl  0xc(%ebx)
80104158:	e8 13 e4 ff ff       	call   80102570 <kfree>
    np->kstack = 0;
8010415d:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80104164:	83 c4 10             	add    $0x10,%esp
    np->state = UNUSED;
80104167:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
    return -1;
8010416e:	eb c9                	jmp    80104139 <fork+0xe9>

80104170 <print_rss>:
{
80104170:	f3 0f 1e fb          	endbr32 
80104174:	55                   	push   %ebp
80104175:	89 e5                	mov    %esp,%ebp
80104177:	53                   	push   %ebx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104178:	bb f4 46 11 80       	mov    $0x801146f4,%ebx
{
8010417d:	83 ec 10             	sub    $0x10,%esp
  cprintf("PrintingRSS\n");
80104180:	68 11 7d 10 80       	push   $0x80107d11
80104185:	e8 26 c6 ff ff       	call   801007b0 <cprintf>
  acquire(&ptable.lock);
8010418a:	c7 04 24 c0 46 11 80 	movl   $0x801146c0,(%esp)
80104191:	e8 ca 09 00 00       	call   80104b60 <acquire>
80104196:	83 c4 10             	add    $0x10,%esp
80104199:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if((p->state == UNUSED))
801041a0:	8b 43 10             	mov    0x10(%ebx),%eax
801041a3:	85 c0                	test   %eax,%eax
801041a5:	74 14                	je     801041bb <print_rss+0x4b>
    cprintf("((P)) id: %d, state: %d, rss: %d\n",p->pid,p->state,p->rss);
801041a7:	ff 73 04             	pushl  0x4(%ebx)
801041aa:	50                   	push   %eax
801041ab:	ff 73 14             	pushl  0x14(%ebx)
801041ae:	68 f0 7d 10 80       	push   $0x80107df0
801041b3:	e8 f8 c5 ff ff       	call   801007b0 <cprintf>
801041b8:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801041bb:	83 eb 80             	sub    $0xffffff80,%ebx
801041be:	81 fb f4 66 11 80    	cmp    $0x801166f4,%ebx
801041c4:	75 da                	jne    801041a0 <print_rss+0x30>
  release(&ptable.lock);
801041c6:	83 ec 0c             	sub    $0xc,%esp
801041c9:	68 c0 46 11 80       	push   $0x801146c0
801041ce:	e8 4d 0a 00 00       	call   80104c20 <release>
}
801041d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801041d6:	83 c4 10             	add    $0x10,%esp
801041d9:	c9                   	leave  
801041da:	c3                   	ret    
801041db:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801041df:	90                   	nop

801041e0 <scheduler>:
{
801041e0:	f3 0f 1e fb          	endbr32 
801041e4:	55                   	push   %ebp
801041e5:	89 e5                	mov    %esp,%ebp
801041e7:	57                   	push   %edi
801041e8:	56                   	push   %esi
801041e9:	53                   	push   %ebx
801041ea:	83 ec 0c             	sub    $0xc,%esp
  struct cpu *c = mycpu();
801041ed:	e8 1e fc ff ff       	call   80103e10 <mycpu>
  c->proc = 0;
801041f2:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801041f9:	00 00 00 
  struct cpu *c = mycpu();
801041fc:	89 c6                	mov    %eax,%esi
  c->proc = 0;
801041fe:	8d 78 04             	lea    0x4(%eax),%edi
80104201:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  asm volatile("sti");
80104208:	fb                   	sti    
    acquire(&ptable.lock);
80104209:	83 ec 0c             	sub    $0xc,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010420c:	bb f4 46 11 80       	mov    $0x801146f4,%ebx
    acquire(&ptable.lock);
80104211:	68 c0 46 11 80       	push   $0x801146c0
80104216:	e8 45 09 00 00       	call   80104b60 <acquire>
8010421b:	83 c4 10             	add    $0x10,%esp
8010421e:	66 90                	xchg   %ax,%ax
      if(p->state != RUNNABLE)
80104220:	83 7b 10 03          	cmpl   $0x3,0x10(%ebx)
80104224:	75 33                	jne    80104259 <scheduler+0x79>
      switchuvm(p);
80104226:	83 ec 0c             	sub    $0xc,%esp
      c->proc = p;
80104229:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
8010422f:	53                   	push   %ebx
80104230:	e8 3b 2e 00 00       	call   80107070 <switchuvm>
      swtch(&(c->scheduler), p->context);
80104235:	58                   	pop    %eax
80104236:	5a                   	pop    %edx
80104237:	ff 73 20             	pushl  0x20(%ebx)
8010423a:	57                   	push   %edi
      p->state = RUNNING;
8010423b:	c7 43 10 04 00 00 00 	movl   $0x4,0x10(%ebx)
      swtch(&(c->scheduler), p->context);
80104242:	e8 4c 0c 00 00       	call   80104e93 <swtch>
      switchkvm();
80104247:	e8 04 2e 00 00       	call   80107050 <switchkvm>
      c->proc = 0;
8010424c:	83 c4 10             	add    $0x10,%esp
8010424f:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80104256:	00 00 00 
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104259:	83 eb 80             	sub    $0xffffff80,%ebx
8010425c:	81 fb f4 66 11 80    	cmp    $0x801166f4,%ebx
80104262:	75 bc                	jne    80104220 <scheduler+0x40>
    release(&ptable.lock);
80104264:	83 ec 0c             	sub    $0xc,%esp
80104267:	68 c0 46 11 80       	push   $0x801146c0
8010426c:	e8 af 09 00 00       	call   80104c20 <release>
    sti();
80104271:	83 c4 10             	add    $0x10,%esp
80104274:	eb 92                	jmp    80104208 <scheduler+0x28>
80104276:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010427d:	8d 76 00             	lea    0x0(%esi),%esi

80104280 <sched>:
{
80104280:	f3 0f 1e fb          	endbr32 
80104284:	55                   	push   %ebp
80104285:	89 e5                	mov    %esp,%ebp
80104287:	56                   	push   %esi
80104288:	53                   	push   %ebx
  pushcli();
80104289:	e8 d2 07 00 00       	call   80104a60 <pushcli>
  c = mycpu();
8010428e:	e8 7d fb ff ff       	call   80103e10 <mycpu>
  p = c->proc;
80104293:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104299:	e8 12 08 00 00       	call   80104ab0 <popcli>
  if(!holding(&ptable.lock))
8010429e:	83 ec 0c             	sub    $0xc,%esp
801042a1:	68 c0 46 11 80       	push   $0x801146c0
801042a6:	e8 65 08 00 00       	call   80104b10 <holding>
801042ab:	83 c4 10             	add    $0x10,%esp
801042ae:	85 c0                	test   %eax,%eax
801042b0:	74 4f                	je     80104301 <sched+0x81>
  if(mycpu()->ncli != 1)
801042b2:	e8 59 fb ff ff       	call   80103e10 <mycpu>
801042b7:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
801042be:	75 68                	jne    80104328 <sched+0xa8>
  if(p->state == RUNNING)
801042c0:	83 7b 10 04          	cmpl   $0x4,0x10(%ebx)
801042c4:	74 55                	je     8010431b <sched+0x9b>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801042c6:	9c                   	pushf  
801042c7:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801042c8:	f6 c4 02             	test   $0x2,%ah
801042cb:	75 41                	jne    8010430e <sched+0x8e>
  intena = mycpu()->intena;
801042cd:	e8 3e fb ff ff       	call   80103e10 <mycpu>
  swtch(&p->context, mycpu()->scheduler);
801042d2:	83 c3 20             	add    $0x20,%ebx
  intena = mycpu()->intena;
801042d5:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
801042db:	e8 30 fb ff ff       	call   80103e10 <mycpu>
801042e0:	83 ec 08             	sub    $0x8,%esp
801042e3:	ff 70 04             	pushl  0x4(%eax)
801042e6:	53                   	push   %ebx
801042e7:	e8 a7 0b 00 00       	call   80104e93 <swtch>
  mycpu()->intena = intena;
801042ec:	e8 1f fb ff ff       	call   80103e10 <mycpu>
}
801042f1:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
801042f4:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
801042fa:	8d 65 f8             	lea    -0x8(%ebp),%esp
801042fd:	5b                   	pop    %ebx
801042fe:	5e                   	pop    %esi
801042ff:	5d                   	pop    %ebp
80104300:	c3                   	ret    
    panic("sched ptable.lock");
80104301:	83 ec 0c             	sub    $0xc,%esp
80104304:	68 1e 7d 10 80       	push   $0x80107d1e
80104309:	e8 82 c1 ff ff       	call   80100490 <panic>
    panic("sched interruptible");
8010430e:	83 ec 0c             	sub    $0xc,%esp
80104311:	68 4a 7d 10 80       	push   $0x80107d4a
80104316:	e8 75 c1 ff ff       	call   80100490 <panic>
    panic("sched running");
8010431b:	83 ec 0c             	sub    $0xc,%esp
8010431e:	68 3c 7d 10 80       	push   $0x80107d3c
80104323:	e8 68 c1 ff ff       	call   80100490 <panic>
    panic("sched locks");
80104328:	83 ec 0c             	sub    $0xc,%esp
8010432b:	68 30 7d 10 80       	push   $0x80107d30
80104330:	e8 5b c1 ff ff       	call   80100490 <panic>
80104335:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010433c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104340 <exit>:
{
80104340:	f3 0f 1e fb          	endbr32 
80104344:	55                   	push   %ebp
80104345:	89 e5                	mov    %esp,%ebp
80104347:	57                   	push   %edi
80104348:	56                   	push   %esi
80104349:	53                   	push   %ebx
8010434a:	83 ec 0c             	sub    $0xc,%esp
  pushcli();
8010434d:	e8 0e 07 00 00       	call   80104a60 <pushcli>
  c = mycpu();
80104352:	e8 b9 fa ff ff       	call   80103e10 <mycpu>
  p = c->proc;
80104357:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
8010435d:	e8 4e 07 00 00       	call   80104ab0 <popcli>
  if(curproc == initproc)
80104362:	8d 5e 2c             	lea    0x2c(%esi),%ebx
80104365:	8d 7e 6c             	lea    0x6c(%esi),%edi
80104368:	39 35 b8 b5 10 80    	cmp    %esi,0x8010b5b8
8010436e:	0f 84 f3 00 00 00    	je     80104467 <exit+0x127>
80104374:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(curproc->ofile[fd]){
80104378:	8b 03                	mov    (%ebx),%eax
8010437a:	85 c0                	test   %eax,%eax
8010437c:	74 12                	je     80104390 <exit+0x50>
      fileclose(curproc->ofile[fd]);
8010437e:	83 ec 0c             	sub    $0xc,%esp
80104381:	50                   	push   %eax
80104382:	e8 39 cc ff ff       	call   80100fc0 <fileclose>
      curproc->ofile[fd] = 0;
80104387:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
8010438d:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){
80104390:	83 c3 04             	add    $0x4,%ebx
80104393:	39 df                	cmp    %ebx,%edi
80104395:	75 e1                	jne    80104378 <exit+0x38>
  begin_op();
80104397:	e8 a4 eb ff ff       	call   80102f40 <begin_op>
  iput(curproc->cwd);
8010439c:	83 ec 0c             	sub    $0xc,%esp
8010439f:	ff 76 6c             	pushl  0x6c(%esi)
801043a2:	e8 e9 d5 ff ff       	call   80101990 <iput>
  end_op();
801043a7:	e8 04 ec ff ff       	call   80102fb0 <end_op>
  curproc->cwd = 0;
801043ac:	c7 46 6c 00 00 00 00 	movl   $0x0,0x6c(%esi)
  acquire(&ptable.lock);
801043b3:	c7 04 24 c0 46 11 80 	movl   $0x801146c0,(%esp)
801043ba:	e8 a1 07 00 00       	call   80104b60 <acquire>
  wakeup1(curproc->parent);
801043bf:	8b 56 18             	mov    0x18(%esi),%edx
801043c2:	83 c4 10             	add    $0x10,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043c5:	b8 f4 46 11 80       	mov    $0x801146f4,%eax
801043ca:	eb 0e                	jmp    801043da <exit+0x9a>
801043cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801043d0:	83 e8 80             	sub    $0xffffff80,%eax
801043d3:	3d f4 66 11 80       	cmp    $0x801166f4,%eax
801043d8:	74 1c                	je     801043f6 <exit+0xb6>
    if(p->state == SLEEPING && p->chan == chan)
801043da:	83 78 10 02          	cmpl   $0x2,0x10(%eax)
801043de:	75 f0                	jne    801043d0 <exit+0x90>
801043e0:	3b 50 24             	cmp    0x24(%eax),%edx
801043e3:	75 eb                	jne    801043d0 <exit+0x90>
      p->state = RUNNABLE;
801043e5:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801043ec:	83 e8 80             	sub    $0xffffff80,%eax
801043ef:	3d f4 66 11 80       	cmp    $0x801166f4,%eax
801043f4:	75 e4                	jne    801043da <exit+0x9a>
      p->parent = initproc;
801043f6:	8b 0d b8 b5 10 80    	mov    0x8010b5b8,%ecx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801043fc:	ba f4 46 11 80       	mov    $0x801146f4,%edx
80104401:	eb 10                	jmp    80104413 <exit+0xd3>
80104403:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104407:	90                   	nop
80104408:	83 ea 80             	sub    $0xffffff80,%edx
8010440b:	81 fa f4 66 11 80    	cmp    $0x801166f4,%edx
80104411:	74 3b                	je     8010444e <exit+0x10e>
    if(p->parent == curproc){
80104413:	39 72 18             	cmp    %esi,0x18(%edx)
80104416:	75 f0                	jne    80104408 <exit+0xc8>
      if(p->state == ZOMBIE)
80104418:	83 7a 10 05          	cmpl   $0x5,0x10(%edx)
      p->parent = initproc;
8010441c:	89 4a 18             	mov    %ecx,0x18(%edx)
      if(p->state == ZOMBIE)
8010441f:	75 e7                	jne    80104408 <exit+0xc8>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104421:	b8 f4 46 11 80       	mov    $0x801146f4,%eax
80104426:	eb 12                	jmp    8010443a <exit+0xfa>
80104428:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010442f:	90                   	nop
80104430:	83 e8 80             	sub    $0xffffff80,%eax
80104433:	3d f4 66 11 80       	cmp    $0x801166f4,%eax
80104438:	74 ce                	je     80104408 <exit+0xc8>
    if(p->state == SLEEPING && p->chan == chan)
8010443a:	83 78 10 02          	cmpl   $0x2,0x10(%eax)
8010443e:	75 f0                	jne    80104430 <exit+0xf0>
80104440:	3b 48 24             	cmp    0x24(%eax),%ecx
80104443:	75 eb                	jne    80104430 <exit+0xf0>
      p->state = RUNNABLE;
80104445:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
8010444c:	eb e2                	jmp    80104430 <exit+0xf0>
  curproc->state = ZOMBIE;
8010444e:	c7 46 10 05 00 00 00 	movl   $0x5,0x10(%esi)
  sched();
80104455:	e8 26 fe ff ff       	call   80104280 <sched>
  panic("zombie exit");
8010445a:	83 ec 0c             	sub    $0xc,%esp
8010445d:	68 6b 7d 10 80       	push   $0x80107d6b
80104462:	e8 29 c0 ff ff       	call   80100490 <panic>
    panic("init exiting");
80104467:	83 ec 0c             	sub    $0xc,%esp
8010446a:	68 5e 7d 10 80       	push   $0x80107d5e
8010446f:	e8 1c c0 ff ff       	call   80100490 <panic>
80104474:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010447b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010447f:	90                   	nop

80104480 <yield>:
{
80104480:	f3 0f 1e fb          	endbr32 
80104484:	55                   	push   %ebp
80104485:	89 e5                	mov    %esp,%ebp
80104487:	53                   	push   %ebx
80104488:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010448b:	68 c0 46 11 80       	push   $0x801146c0
80104490:	e8 cb 06 00 00       	call   80104b60 <acquire>
  pushcli();
80104495:	e8 c6 05 00 00       	call   80104a60 <pushcli>
  c = mycpu();
8010449a:	e8 71 f9 ff ff       	call   80103e10 <mycpu>
  p = c->proc;
8010449f:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801044a5:	e8 06 06 00 00       	call   80104ab0 <popcli>
  myproc()->state = RUNNABLE;
801044aa:	c7 43 10 03 00 00 00 	movl   $0x3,0x10(%ebx)
  sched();
801044b1:	e8 ca fd ff ff       	call   80104280 <sched>
  release(&ptable.lock);
801044b6:	c7 04 24 c0 46 11 80 	movl   $0x801146c0,(%esp)
801044bd:	e8 5e 07 00 00       	call   80104c20 <release>
}
801044c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801044c5:	83 c4 10             	add    $0x10,%esp
801044c8:	c9                   	leave  
801044c9:	c3                   	ret    
801044ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801044d0 <sleep>:
{
801044d0:	f3 0f 1e fb          	endbr32 
801044d4:	55                   	push   %ebp
801044d5:	89 e5                	mov    %esp,%ebp
801044d7:	57                   	push   %edi
801044d8:	56                   	push   %esi
801044d9:	53                   	push   %ebx
801044da:	83 ec 0c             	sub    $0xc,%esp
801044dd:	8b 7d 08             	mov    0x8(%ebp),%edi
801044e0:	8b 75 0c             	mov    0xc(%ebp),%esi
  pushcli();
801044e3:	e8 78 05 00 00       	call   80104a60 <pushcli>
  c = mycpu();
801044e8:	e8 23 f9 ff ff       	call   80103e10 <mycpu>
  p = c->proc;
801044ed:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801044f3:	e8 b8 05 00 00       	call   80104ab0 <popcli>
  if(p == 0)
801044f8:	85 db                	test   %ebx,%ebx
801044fa:	0f 84 83 00 00 00    	je     80104583 <sleep+0xb3>
  if(lk == 0)
80104500:	85 f6                	test   %esi,%esi
80104502:	74 72                	je     80104576 <sleep+0xa6>
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104504:	81 fe c0 46 11 80    	cmp    $0x801146c0,%esi
8010450a:	74 4c                	je     80104558 <sleep+0x88>
    acquire(&ptable.lock);  //DOC: sleeplock1
8010450c:	83 ec 0c             	sub    $0xc,%esp
8010450f:	68 c0 46 11 80       	push   $0x801146c0
80104514:	e8 47 06 00 00       	call   80104b60 <acquire>
    release(lk);
80104519:	89 34 24             	mov    %esi,(%esp)
8010451c:	e8 ff 06 00 00       	call   80104c20 <release>
  p->chan = chan;
80104521:	89 7b 24             	mov    %edi,0x24(%ebx)
  p->state = SLEEPING;
80104524:	c7 43 10 02 00 00 00 	movl   $0x2,0x10(%ebx)
  sched();
8010452b:	e8 50 fd ff ff       	call   80104280 <sched>
  p->chan = 0;
80104530:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
    release(&ptable.lock);
80104537:	c7 04 24 c0 46 11 80 	movl   $0x801146c0,(%esp)
8010453e:	e8 dd 06 00 00       	call   80104c20 <release>
    acquire(lk);
80104543:	89 75 08             	mov    %esi,0x8(%ebp)
80104546:	83 c4 10             	add    $0x10,%esp
}
80104549:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010454c:	5b                   	pop    %ebx
8010454d:	5e                   	pop    %esi
8010454e:	5f                   	pop    %edi
8010454f:	5d                   	pop    %ebp
    acquire(lk);
80104550:	e9 0b 06 00 00       	jmp    80104b60 <acquire>
80104555:	8d 76 00             	lea    0x0(%esi),%esi
  p->chan = chan;
80104558:	89 7b 24             	mov    %edi,0x24(%ebx)
  p->state = SLEEPING;
8010455b:	c7 43 10 02 00 00 00 	movl   $0x2,0x10(%ebx)
  sched();
80104562:	e8 19 fd ff ff       	call   80104280 <sched>
  p->chan = 0;
80104567:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
}
8010456e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104571:	5b                   	pop    %ebx
80104572:	5e                   	pop    %esi
80104573:	5f                   	pop    %edi
80104574:	5d                   	pop    %ebp
80104575:	c3                   	ret    
    panic("sleep without lk");
80104576:	83 ec 0c             	sub    $0xc,%esp
80104579:	68 7d 7d 10 80       	push   $0x80107d7d
8010457e:	e8 0d bf ff ff       	call   80100490 <panic>
    panic("sleep");
80104583:	83 ec 0c             	sub    $0xc,%esp
80104586:	68 77 7d 10 80       	push   $0x80107d77
8010458b:	e8 00 bf ff ff       	call   80100490 <panic>

80104590 <wait>:
{
80104590:	f3 0f 1e fb          	endbr32 
80104594:	55                   	push   %ebp
80104595:	89 e5                	mov    %esp,%ebp
80104597:	56                   	push   %esi
80104598:	53                   	push   %ebx
  pushcli();
80104599:	e8 c2 04 00 00       	call   80104a60 <pushcli>
  c = mycpu();
8010459e:	e8 6d f8 ff ff       	call   80103e10 <mycpu>
  p = c->proc;
801045a3:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
801045a9:	e8 02 05 00 00       	call   80104ab0 <popcli>
  acquire(&ptable.lock);
801045ae:	83 ec 0c             	sub    $0xc,%esp
801045b1:	68 c0 46 11 80       	push   $0x801146c0
801045b6:	e8 a5 05 00 00       	call   80104b60 <acquire>
801045bb:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801045be:	31 c0                	xor    %eax,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045c0:	bb f4 46 11 80       	mov    $0x801146f4,%ebx
801045c5:	eb 14                	jmp    801045db <wait+0x4b>
801045c7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801045ce:	66 90                	xchg   %ax,%ax
801045d0:	83 eb 80             	sub    $0xffffff80,%ebx
801045d3:	81 fb f4 66 11 80    	cmp    $0x801166f4,%ebx
801045d9:	74 1b                	je     801045f6 <wait+0x66>
      if(p->parent != curproc)
801045db:	39 73 18             	cmp    %esi,0x18(%ebx)
801045de:	75 f0                	jne    801045d0 <wait+0x40>
      if(p->state == ZOMBIE){
801045e0:	83 7b 10 05          	cmpl   $0x5,0x10(%ebx)
801045e4:	74 32                	je     80104618 <wait+0x88>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045e6:	83 eb 80             	sub    $0xffffff80,%ebx
      havekids = 1;
801045e9:	b8 01 00 00 00       	mov    $0x1,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801045ee:	81 fb f4 66 11 80    	cmp    $0x801166f4,%ebx
801045f4:	75 e5                	jne    801045db <wait+0x4b>
    if(!havekids || curproc->killed){
801045f6:	85 c0                	test   %eax,%eax
801045f8:	74 7b                	je     80104675 <wait+0xe5>
801045fa:	8b 46 28             	mov    0x28(%esi),%eax
801045fd:	85 c0                	test   %eax,%eax
801045ff:	75 74                	jne    80104675 <wait+0xe5>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80104601:	83 ec 08             	sub    $0x8,%esp
80104604:	68 c0 46 11 80       	push   $0x801146c0
80104609:	56                   	push   %esi
8010460a:	e8 c1 fe ff ff       	call   801044d0 <sleep>
    havekids = 0;
8010460f:	83 c4 10             	add    $0x10,%esp
80104612:	eb aa                	jmp    801045be <wait+0x2e>
80104614:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        clean_swapblocks(p);
80104618:	83 ec 0c             	sub    $0xc,%esp
8010461b:	53                   	push   %ebx
8010461c:	e8 1f f0 ff ff       	call   80103640 <clean_swapblocks>
        kfree(p->kstack);
80104621:	5a                   	pop    %edx
        pid = p->pid;
80104622:	8b 73 14             	mov    0x14(%ebx),%esi
        kfree(p->kstack);
80104625:	ff 73 0c             	pushl  0xc(%ebx)
80104628:	e8 43 df ff ff       	call   80102570 <kfree>
        freevm(p->pgdir);
8010462d:	59                   	pop    %ecx
8010462e:	ff 73 08             	pushl  0x8(%ebx)
        p->kstack = 0;
80104631:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        freevm(p->pgdir);
80104638:	e8 03 2e 00 00       	call   80107440 <freevm>
        release(&ptable.lock);
8010463d:	c7 04 24 c0 46 11 80 	movl   $0x801146c0,(%esp)
        p->pid = 0;
80104644:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->parent = 0;
8010464b:	c7 43 18 00 00 00 00 	movl   $0x0,0x18(%ebx)
        p->name[0] = 0;
80104652:	c6 43 70 00          	movb   $0x0,0x70(%ebx)
        p->killed = 0;
80104656:	c7 43 28 00 00 00 00 	movl   $0x0,0x28(%ebx)
        p->state = UNUSED;
8010465d:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        release(&ptable.lock);
80104664:	e8 b7 05 00 00       	call   80104c20 <release>
        return pid;
80104669:	83 c4 10             	add    $0x10,%esp
}
8010466c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010466f:	89 f0                	mov    %esi,%eax
80104671:	5b                   	pop    %ebx
80104672:	5e                   	pop    %esi
80104673:	5d                   	pop    %ebp
80104674:	c3                   	ret    
      release(&ptable.lock);
80104675:	83 ec 0c             	sub    $0xc,%esp
      return -1;
80104678:	be ff ff ff ff       	mov    $0xffffffff,%esi
      release(&ptable.lock);
8010467d:	68 c0 46 11 80       	push   $0x801146c0
80104682:	e8 99 05 00 00       	call   80104c20 <release>
      return -1;
80104687:	83 c4 10             	add    $0x10,%esp
8010468a:	eb e0                	jmp    8010466c <wait+0xdc>
8010468c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104690 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104690:	f3 0f 1e fb          	endbr32 
80104694:	55                   	push   %ebp
80104695:	89 e5                	mov    %esp,%ebp
80104697:	53                   	push   %ebx
80104698:	83 ec 10             	sub    $0x10,%esp
8010469b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
8010469e:	68 c0 46 11 80       	push   $0x801146c0
801046a3:	e8 b8 04 00 00       	call   80104b60 <acquire>
801046a8:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801046ab:	b8 f4 46 11 80       	mov    $0x801146f4,%eax
801046b0:	eb 10                	jmp    801046c2 <wakeup+0x32>
801046b2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801046b8:	83 e8 80             	sub    $0xffffff80,%eax
801046bb:	3d f4 66 11 80       	cmp    $0x801166f4,%eax
801046c0:	74 1c                	je     801046de <wakeup+0x4e>
    if(p->state == SLEEPING && p->chan == chan)
801046c2:	83 78 10 02          	cmpl   $0x2,0x10(%eax)
801046c6:	75 f0                	jne    801046b8 <wakeup+0x28>
801046c8:	3b 58 24             	cmp    0x24(%eax),%ebx
801046cb:	75 eb                	jne    801046b8 <wakeup+0x28>
      p->state = RUNNABLE;
801046cd:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801046d4:	83 e8 80             	sub    $0xffffff80,%eax
801046d7:	3d f4 66 11 80       	cmp    $0x801166f4,%eax
801046dc:	75 e4                	jne    801046c2 <wakeup+0x32>
  wakeup1(chan);
  release(&ptable.lock);
801046de:	c7 45 08 c0 46 11 80 	movl   $0x801146c0,0x8(%ebp)
}
801046e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801046e8:	c9                   	leave  
  release(&ptable.lock);
801046e9:	e9 32 05 00 00       	jmp    80104c20 <release>
801046ee:	66 90                	xchg   %ax,%ax

801046f0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801046f0:	f3 0f 1e fb          	endbr32 
801046f4:	55                   	push   %ebp
801046f5:	89 e5                	mov    %esp,%ebp
801046f7:	53                   	push   %ebx
801046f8:	83 ec 10             	sub    $0x10,%esp
801046fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801046fe:	68 c0 46 11 80       	push   $0x801146c0
80104703:	e8 58 04 00 00       	call   80104b60 <acquire>
80104708:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010470b:	b8 f4 46 11 80       	mov    $0x801146f4,%eax
80104710:	eb 10                	jmp    80104722 <kill+0x32>
80104712:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104718:	83 e8 80             	sub    $0xffffff80,%eax
8010471b:	3d f4 66 11 80       	cmp    $0x801166f4,%eax
80104720:	74 36                	je     80104758 <kill+0x68>
    if(p->pid == pid){
80104722:	39 58 14             	cmp    %ebx,0x14(%eax)
80104725:	75 f1                	jne    80104718 <kill+0x28>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104727:	83 78 10 02          	cmpl   $0x2,0x10(%eax)
      p->killed = 1;
8010472b:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
      if(p->state == SLEEPING)
80104732:	75 07                	jne    8010473b <kill+0x4b>
        p->state = RUNNABLE;
80104734:	c7 40 10 03 00 00 00 	movl   $0x3,0x10(%eax)
      release(&ptable.lock);
8010473b:	83 ec 0c             	sub    $0xc,%esp
8010473e:	68 c0 46 11 80       	push   $0x801146c0
80104743:	e8 d8 04 00 00       	call   80104c20 <release>
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
80104748:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return 0;
8010474b:	83 c4 10             	add    $0x10,%esp
8010474e:	31 c0                	xor    %eax,%eax
}
80104750:	c9                   	leave  
80104751:	c3                   	ret    
80104752:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  release(&ptable.lock);
80104758:	83 ec 0c             	sub    $0xc,%esp
8010475b:	68 c0 46 11 80       	push   $0x801146c0
80104760:	e8 bb 04 00 00       	call   80104c20 <release>
}
80104765:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return -1;
80104768:	83 c4 10             	add    $0x10,%esp
8010476b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104770:	c9                   	leave  
80104771:	c3                   	ret    
80104772:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104779:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104780 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104780:	f3 0f 1e fb          	endbr32 
80104784:	55                   	push   %ebp
80104785:	89 e5                	mov    %esp,%ebp
80104787:	57                   	push   %edi
80104788:	56                   	push   %esi
80104789:	8d 75 e8             	lea    -0x18(%ebp),%esi
8010478c:	53                   	push   %ebx
8010478d:	bb 64 47 11 80       	mov    $0x80114764,%ebx
80104792:	83 ec 3c             	sub    $0x3c,%esp
80104795:	eb 28                	jmp    801047bf <procdump+0x3f>
80104797:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010479e:	66 90                	xchg   %ax,%ax
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
801047a0:	83 ec 0c             	sub    $0xc,%esp
801047a3:	68 3f 81 10 80       	push   $0x8010813f
801047a8:	e8 03 c0 ff ff       	call   801007b0 <cprintf>
801047ad:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801047b0:	83 eb 80             	sub    $0xffffff80,%ebx
801047b3:	81 fb 64 67 11 80    	cmp    $0x80116764,%ebx
801047b9:	0f 84 81 00 00 00    	je     80104840 <procdump+0xc0>
    if(p->state == UNUSED)
801047bf:	8b 43 a0             	mov    -0x60(%ebx),%eax
801047c2:	85 c0                	test   %eax,%eax
801047c4:	74 ea                	je     801047b0 <procdump+0x30>
      state = "???";
801047c6:	ba 8e 7d 10 80       	mov    $0x80107d8e,%edx
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801047cb:	83 f8 05             	cmp    $0x5,%eax
801047ce:	77 11                	ja     801047e1 <procdump+0x61>
801047d0:	8b 14 85 14 7e 10 80 	mov    -0x7fef81ec(,%eax,4),%edx
      state = "???";
801047d7:	b8 8e 7d 10 80       	mov    $0x80107d8e,%eax
801047dc:	85 d2                	test   %edx,%edx
801047de:	0f 44 d0             	cmove  %eax,%edx
    cprintf("%d %s %s", p->pid, state, p->name);
801047e1:	53                   	push   %ebx
801047e2:	52                   	push   %edx
801047e3:	ff 73 a4             	pushl  -0x5c(%ebx)
801047e6:	68 92 7d 10 80       	push   $0x80107d92
801047eb:	e8 c0 bf ff ff       	call   801007b0 <cprintf>
    if(p->state == SLEEPING){
801047f0:	83 c4 10             	add    $0x10,%esp
801047f3:	83 7b a0 02          	cmpl   $0x2,-0x60(%ebx)
801047f7:	75 a7                	jne    801047a0 <procdump+0x20>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801047f9:	83 ec 08             	sub    $0x8,%esp
801047fc:	8d 45 c0             	lea    -0x40(%ebp),%eax
801047ff:	8d 7d c0             	lea    -0x40(%ebp),%edi
80104802:	50                   	push   %eax
80104803:	8b 43 b0             	mov    -0x50(%ebx),%eax
80104806:	8b 40 0c             	mov    0xc(%eax),%eax
80104809:	83 c0 08             	add    $0x8,%eax
8010480c:	50                   	push   %eax
8010480d:	e8 ee 01 00 00       	call   80104a00 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80104812:	83 c4 10             	add    $0x10,%esp
80104815:	8d 76 00             	lea    0x0(%esi),%esi
80104818:	8b 17                	mov    (%edi),%edx
8010481a:	85 d2                	test   %edx,%edx
8010481c:	74 82                	je     801047a0 <procdump+0x20>
        cprintf(" %p", pc[i]);
8010481e:	83 ec 08             	sub    $0x8,%esp
80104821:	83 c7 04             	add    $0x4,%edi
80104824:	52                   	push   %edx
80104825:	68 a1 77 10 80       	push   $0x801077a1
8010482a:	e8 81 bf ff ff       	call   801007b0 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
8010482f:	83 c4 10             	add    $0x10,%esp
80104832:	39 fe                	cmp    %edi,%esi
80104834:	75 e2                	jne    80104818 <procdump+0x98>
80104836:	e9 65 ff ff ff       	jmp    801047a0 <procdump+0x20>
8010483b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010483f:	90                   	nop
  }
}
80104840:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104843:	5b                   	pop    %ebx
80104844:	5e                   	pop    %esi
80104845:	5f                   	pop    %edi
80104846:	5d                   	pop    %ebp
80104847:	c3                   	ret    
80104848:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010484f:	90                   	nop

80104850 <find_proc>:

// Function added by Adithya
struct proc* find_proc()
{
80104850:	f3 0f 1e fb          	endbr32 
80104854:	55                   	push   %ebp
   uint max_rss=ptable.proc[0].rss;
80104855:	8b 0d f8 46 11 80    	mov    0x801146f8,%ecx
  //  cprintf("max rss: %d\n", max_rss);
   int max_proc=0;
   for (int i=0;i<NPROC;i++)
8010485b:	31 c0                	xor    %eax,%eax
{
8010485d:	89 e5                	mov    %esp,%ebp
8010485f:	53                   	push   %ebx
   int max_proc=0;
80104860:	31 db                	xor    %ebx,%ebx
80104862:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
   {
    if (ptable.proc[i].state == UNUSED) {
80104868:	89 c2                	mov    %eax,%edx
8010486a:	c1 e2 07             	shl    $0x7,%edx
8010486d:	83 ba 04 47 11 80 00 	cmpl   $0x0,-0x7feeb8fc(%edx)
80104874:	74 0e                	je     80104884 <find_proc+0x34>
      continue;
    }
    if (ptable.proc[i].rss>max_rss)
80104876:	8b 92 f8 46 11 80    	mov    -0x7feeb908(%edx),%edx
8010487c:	39 ca                	cmp    %ecx,%edx
8010487e:	76 04                	jbe    80104884 <find_proc+0x34>
80104880:	89 c3                	mov    %eax,%ebx
80104882:	89 d1                	mov    %edx,%ecx
   for (int i=0;i<NPROC;i++)
80104884:	83 c0 01             	add    $0x1,%eax
80104887:	83 f8 40             	cmp    $0x40,%eax
8010488a:	75 dc                	jne    80104868 <find_proc+0x18>
      // cprintf("find proc id: %d\n", i);
      max_rss=ptable.proc[i].rss;
      max_proc=i;
    }
   }
   return &(ptable.proc[max_proc]);
8010488c:	c1 e3 07             	shl    $0x7,%ebx
8010488f:	8d 83 f4 46 11 80    	lea    -0x7feeb90c(%ebx),%eax
}
80104895:	5b                   	pop    %ebx
80104896:	5d                   	pop    %ebp
80104897:	c3                   	ret    
80104898:	66 90                	xchg   %ax,%ax
8010489a:	66 90                	xchg   %ax,%ax
8010489c:	66 90                	xchg   %ax,%ax
8010489e:	66 90                	xchg   %ax,%ax

801048a0 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
801048a0:	f3 0f 1e fb          	endbr32 
801048a4:	55                   	push   %ebp
801048a5:	89 e5                	mov    %esp,%ebp
801048a7:	53                   	push   %ebx
801048a8:	83 ec 0c             	sub    $0xc,%esp
801048ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
801048ae:	68 2c 7e 10 80       	push   $0x80107e2c
801048b3:	8d 43 04             	lea    0x4(%ebx),%eax
801048b6:	50                   	push   %eax
801048b7:	e8 24 01 00 00       	call   801049e0 <initlock>
  lk->name = name;
801048bc:	8b 45 0c             	mov    0xc(%ebp),%eax
  lk->locked = 0;
801048bf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
}
801048c5:	83 c4 10             	add    $0x10,%esp
  lk->pid = 0;
801048c8:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  lk->name = name;
801048cf:	89 43 38             	mov    %eax,0x38(%ebx)
}
801048d2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801048d5:	c9                   	leave  
801048d6:	c3                   	ret    
801048d7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801048de:	66 90                	xchg   %ax,%ax

801048e0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801048e0:	f3 0f 1e fb          	endbr32 
801048e4:	55                   	push   %ebp
801048e5:	89 e5                	mov    %esp,%ebp
801048e7:	56                   	push   %esi
801048e8:	53                   	push   %ebx
801048e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
801048ec:	8d 73 04             	lea    0x4(%ebx),%esi
801048ef:	83 ec 0c             	sub    $0xc,%esp
801048f2:	56                   	push   %esi
801048f3:	e8 68 02 00 00       	call   80104b60 <acquire>
  while (lk->locked) {
801048f8:	8b 13                	mov    (%ebx),%edx
801048fa:	83 c4 10             	add    $0x10,%esp
801048fd:	85 d2                	test   %edx,%edx
801048ff:	74 1a                	je     8010491b <acquiresleep+0x3b>
80104901:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    sleep(lk, &lk->lk);
80104908:	83 ec 08             	sub    $0x8,%esp
8010490b:	56                   	push   %esi
8010490c:	53                   	push   %ebx
8010490d:	e8 be fb ff ff       	call   801044d0 <sleep>
  while (lk->locked) {
80104912:	8b 03                	mov    (%ebx),%eax
80104914:	83 c4 10             	add    $0x10,%esp
80104917:	85 c0                	test   %eax,%eax
80104919:	75 ed                	jne    80104908 <acquiresleep+0x28>
  }
  lk->locked = 1;
8010491b:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80104921:	e8 7a f5 ff ff       	call   80103ea0 <myproc>
80104926:	8b 40 14             	mov    0x14(%eax),%eax
80104929:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
8010492c:	89 75 08             	mov    %esi,0x8(%ebp)
}
8010492f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104932:	5b                   	pop    %ebx
80104933:	5e                   	pop    %esi
80104934:	5d                   	pop    %ebp
  release(&lk->lk);
80104935:	e9 e6 02 00 00       	jmp    80104c20 <release>
8010493a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104940 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104940:	f3 0f 1e fb          	endbr32 
80104944:	55                   	push   %ebp
80104945:	89 e5                	mov    %esp,%ebp
80104947:	56                   	push   %esi
80104948:	53                   	push   %ebx
80104949:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
8010494c:	8d 73 04             	lea    0x4(%ebx),%esi
8010494f:	83 ec 0c             	sub    $0xc,%esp
80104952:	56                   	push   %esi
80104953:	e8 08 02 00 00       	call   80104b60 <acquire>
  lk->locked = 0;
80104958:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
8010495e:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80104965:	89 1c 24             	mov    %ebx,(%esp)
80104968:	e8 23 fd ff ff       	call   80104690 <wakeup>
  release(&lk->lk);
8010496d:	89 75 08             	mov    %esi,0x8(%ebp)
80104970:	83 c4 10             	add    $0x10,%esp
}
80104973:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104976:	5b                   	pop    %ebx
80104977:	5e                   	pop    %esi
80104978:	5d                   	pop    %ebp
  release(&lk->lk);
80104979:	e9 a2 02 00 00       	jmp    80104c20 <release>
8010497e:	66 90                	xchg   %ax,%ax

80104980 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104980:	f3 0f 1e fb          	endbr32 
80104984:	55                   	push   %ebp
80104985:	89 e5                	mov    %esp,%ebp
80104987:	57                   	push   %edi
80104988:	31 ff                	xor    %edi,%edi
8010498a:	56                   	push   %esi
8010498b:	53                   	push   %ebx
8010498c:	83 ec 18             	sub    $0x18,%esp
8010498f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80104992:	8d 73 04             	lea    0x4(%ebx),%esi
80104995:	56                   	push   %esi
80104996:	e8 c5 01 00 00       	call   80104b60 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
8010499b:	8b 03                	mov    (%ebx),%eax
8010499d:	83 c4 10             	add    $0x10,%esp
801049a0:	85 c0                	test   %eax,%eax
801049a2:	75 1c                	jne    801049c0 <holdingsleep+0x40>
  release(&lk->lk);
801049a4:	83 ec 0c             	sub    $0xc,%esp
801049a7:	56                   	push   %esi
801049a8:	e8 73 02 00 00       	call   80104c20 <release>
  return r;
}
801049ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
801049b0:	89 f8                	mov    %edi,%eax
801049b2:	5b                   	pop    %ebx
801049b3:	5e                   	pop    %esi
801049b4:	5f                   	pop    %edi
801049b5:	5d                   	pop    %ebp
801049b6:	c3                   	ret    
801049b7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801049be:	66 90                	xchg   %ax,%ax
  r = lk->locked && (lk->pid == myproc()->pid);
801049c0:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
801049c3:	e8 d8 f4 ff ff       	call   80103ea0 <myproc>
801049c8:	39 58 14             	cmp    %ebx,0x14(%eax)
801049cb:	0f 94 c0             	sete   %al
801049ce:	0f b6 c0             	movzbl %al,%eax
801049d1:	89 c7                	mov    %eax,%edi
801049d3:	eb cf                	jmp    801049a4 <holdingsleep+0x24>
801049d5:	66 90                	xchg   %ax,%ax
801049d7:	66 90                	xchg   %ax,%ax
801049d9:	66 90                	xchg   %ax,%ax
801049db:	66 90                	xchg   %ax,%ax
801049dd:	66 90                	xchg   %ax,%ax
801049df:	90                   	nop

801049e0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801049e0:	f3 0f 1e fb          	endbr32 
801049e4:	55                   	push   %ebp
801049e5:	89 e5                	mov    %esp,%ebp
801049e7:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
801049ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
801049ed:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->name = name;
801049f3:	89 50 04             	mov    %edx,0x4(%eax)
  lk->cpu = 0;
801049f6:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801049fd:	5d                   	pop    %ebp
801049fe:	c3                   	ret    
801049ff:	90                   	nop

80104a00 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80104a00:	f3 0f 1e fb          	endbr32 
80104a04:	55                   	push   %ebp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
80104a05:	31 d2                	xor    %edx,%edx
{
80104a07:	89 e5                	mov    %esp,%ebp
80104a09:	53                   	push   %ebx
  ebp = (uint*)v - 2;
80104a0a:	8b 45 08             	mov    0x8(%ebp),%eax
{
80104a0d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  ebp = (uint*)v - 2;
80104a10:	83 e8 08             	sub    $0x8,%eax
  for(i = 0; i < 10; i++){
80104a13:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104a17:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104a18:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
80104a1e:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80104a24:	77 1a                	ja     80104a40 <getcallerpcs+0x40>
      break;
    pcs[i] = ebp[1];     // saved %eip
80104a26:	8b 58 04             	mov    0x4(%eax),%ebx
80104a29:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
80104a2c:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
80104a2f:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
80104a31:	83 fa 0a             	cmp    $0xa,%edx
80104a34:	75 e2                	jne    80104a18 <getcallerpcs+0x18>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
80104a36:	5b                   	pop    %ebx
80104a37:	5d                   	pop    %ebp
80104a38:	c3                   	ret    
80104a39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(; i < 10; i++)
80104a40:	8d 04 91             	lea    (%ecx,%edx,4),%eax
80104a43:	8d 51 28             	lea    0x28(%ecx),%edx
80104a46:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104a4d:	8d 76 00             	lea    0x0(%esi),%esi
    pcs[i] = 0;
80104a50:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104a56:	83 c0 04             	add    $0x4,%eax
80104a59:	39 d0                	cmp    %edx,%eax
80104a5b:	75 f3                	jne    80104a50 <getcallerpcs+0x50>
}
80104a5d:	5b                   	pop    %ebx
80104a5e:	5d                   	pop    %ebp
80104a5f:	c3                   	ret    

80104a60 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104a60:	f3 0f 1e fb          	endbr32 
80104a64:	55                   	push   %ebp
80104a65:	89 e5                	mov    %esp,%ebp
80104a67:	53                   	push   %ebx
80104a68:	83 ec 04             	sub    $0x4,%esp
80104a6b:	9c                   	pushf  
80104a6c:	5b                   	pop    %ebx
  asm volatile("cli");
80104a6d:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80104a6e:	e8 9d f3 ff ff       	call   80103e10 <mycpu>
80104a73:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a79:	85 c0                	test   %eax,%eax
80104a7b:	74 13                	je     80104a90 <pushcli+0x30>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80104a7d:	e8 8e f3 ff ff       	call   80103e10 <mycpu>
80104a82:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80104a89:	83 c4 04             	add    $0x4,%esp
80104a8c:	5b                   	pop    %ebx
80104a8d:	5d                   	pop    %ebp
80104a8e:	c3                   	ret    
80104a8f:	90                   	nop
    mycpu()->intena = eflags & FL_IF;
80104a90:	e8 7b f3 ff ff       	call   80103e10 <mycpu>
80104a95:	81 e3 00 02 00 00    	and    $0x200,%ebx
80104a9b:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80104aa1:	eb da                	jmp    80104a7d <pushcli+0x1d>
80104aa3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104aaa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104ab0 <popcli>:

void
popcli(void)
{
80104ab0:	f3 0f 1e fb          	endbr32 
80104ab4:	55                   	push   %ebp
80104ab5:	89 e5                	mov    %esp,%ebp
80104ab7:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104aba:	9c                   	pushf  
80104abb:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80104abc:	f6 c4 02             	test   $0x2,%ah
80104abf:	75 31                	jne    80104af2 <popcli+0x42>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80104ac1:	e8 4a f3 ff ff       	call   80103e10 <mycpu>
80104ac6:	83 a8 a4 00 00 00 01 	subl   $0x1,0xa4(%eax)
80104acd:	78 30                	js     80104aff <popcli+0x4f>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104acf:	e8 3c f3 ff ff       	call   80103e10 <mycpu>
80104ad4:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104ada:	85 d2                	test   %edx,%edx
80104adc:	74 02                	je     80104ae0 <popcli+0x30>
    sti();
}
80104ade:	c9                   	leave  
80104adf:	c3                   	ret    
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104ae0:	e8 2b f3 ff ff       	call   80103e10 <mycpu>
80104ae5:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104aeb:	85 c0                	test   %eax,%eax
80104aed:	74 ef                	je     80104ade <popcli+0x2e>
  asm volatile("sti");
80104aef:	fb                   	sti    
}
80104af0:	c9                   	leave  
80104af1:	c3                   	ret    
    panic("popcli - interruptible");
80104af2:	83 ec 0c             	sub    $0xc,%esp
80104af5:	68 37 7e 10 80       	push   $0x80107e37
80104afa:	e8 91 b9 ff ff       	call   80100490 <panic>
    panic("popcli");
80104aff:	83 ec 0c             	sub    $0xc,%esp
80104b02:	68 4e 7e 10 80       	push   $0x80107e4e
80104b07:	e8 84 b9 ff ff       	call   80100490 <panic>
80104b0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104b10 <holding>:
{
80104b10:	f3 0f 1e fb          	endbr32 
80104b14:	55                   	push   %ebp
80104b15:	89 e5                	mov    %esp,%ebp
80104b17:	56                   	push   %esi
80104b18:	53                   	push   %ebx
80104b19:	8b 75 08             	mov    0x8(%ebp),%esi
80104b1c:	31 db                	xor    %ebx,%ebx
  pushcli();
80104b1e:	e8 3d ff ff ff       	call   80104a60 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80104b23:	8b 06                	mov    (%esi),%eax
80104b25:	85 c0                	test   %eax,%eax
80104b27:	75 0f                	jne    80104b38 <holding+0x28>
  popcli();
80104b29:	e8 82 ff ff ff       	call   80104ab0 <popcli>
}
80104b2e:	89 d8                	mov    %ebx,%eax
80104b30:	5b                   	pop    %ebx
80104b31:	5e                   	pop    %esi
80104b32:	5d                   	pop    %ebp
80104b33:	c3                   	ret    
80104b34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  r = lock->locked && lock->cpu == mycpu();
80104b38:	8b 5e 08             	mov    0x8(%esi),%ebx
80104b3b:	e8 d0 f2 ff ff       	call   80103e10 <mycpu>
80104b40:	39 c3                	cmp    %eax,%ebx
80104b42:	0f 94 c3             	sete   %bl
  popcli();
80104b45:	e8 66 ff ff ff       	call   80104ab0 <popcli>
  r = lock->locked && lock->cpu == mycpu();
80104b4a:	0f b6 db             	movzbl %bl,%ebx
}
80104b4d:	89 d8                	mov    %ebx,%eax
80104b4f:	5b                   	pop    %ebx
80104b50:	5e                   	pop    %esi
80104b51:	5d                   	pop    %ebp
80104b52:	c3                   	ret    
80104b53:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104b5a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104b60 <acquire>:
{
80104b60:	f3 0f 1e fb          	endbr32 
80104b64:	55                   	push   %ebp
80104b65:	89 e5                	mov    %esp,%ebp
80104b67:	56                   	push   %esi
80104b68:	53                   	push   %ebx
  pushcli(); // disable interrupts to avoid deadlock.
80104b69:	e8 f2 fe ff ff       	call   80104a60 <pushcli>
  if(holding(lk))
80104b6e:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104b71:	83 ec 0c             	sub    $0xc,%esp
80104b74:	53                   	push   %ebx
80104b75:	e8 96 ff ff ff       	call   80104b10 <holding>
80104b7a:	83 c4 10             	add    $0x10,%esp
80104b7d:	85 c0                	test   %eax,%eax
80104b7f:	0f 85 7f 00 00 00    	jne    80104c04 <acquire+0xa4>
80104b85:	89 c6                	mov    %eax,%esi
  asm volatile("lock; xchgl %0, %1" :
80104b87:	ba 01 00 00 00       	mov    $0x1,%edx
80104b8c:	eb 05                	jmp    80104b93 <acquire+0x33>
80104b8e:	66 90                	xchg   %ax,%ax
80104b90:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104b93:	89 d0                	mov    %edx,%eax
80104b95:	f0 87 03             	lock xchg %eax,(%ebx)
  while(xchg(&lk->locked, 1) != 0)
80104b98:	85 c0                	test   %eax,%eax
80104b9a:	75 f4                	jne    80104b90 <acquire+0x30>
  __sync_synchronize();
80104b9c:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80104ba1:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104ba4:	e8 67 f2 ff ff       	call   80103e10 <mycpu>
80104ba9:	89 43 08             	mov    %eax,0x8(%ebx)
  ebp = (uint*)v - 2;
80104bac:	89 e8                	mov    %ebp,%eax
80104bae:	66 90                	xchg   %ax,%ax
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104bb0:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80104bb6:	81 fa fe ff ff 7f    	cmp    $0x7ffffffe,%edx
80104bbc:	77 22                	ja     80104be0 <acquire+0x80>
    pcs[i] = ebp[1];     // saved %eip
80104bbe:	8b 50 04             	mov    0x4(%eax),%edx
80104bc1:	89 54 b3 0c          	mov    %edx,0xc(%ebx,%esi,4)
  for(i = 0; i < 10; i++){
80104bc5:	83 c6 01             	add    $0x1,%esi
    ebp = (uint*)ebp[0]; // saved %ebp
80104bc8:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
80104bca:	83 fe 0a             	cmp    $0xa,%esi
80104bcd:	75 e1                	jne    80104bb0 <acquire+0x50>
}
80104bcf:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104bd2:	5b                   	pop    %ebx
80104bd3:	5e                   	pop    %esi
80104bd4:	5d                   	pop    %ebp
80104bd5:	c3                   	ret    
80104bd6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104bdd:	8d 76 00             	lea    0x0(%esi),%esi
  for(; i < 10; i++)
80104be0:	8d 44 b3 0c          	lea    0xc(%ebx,%esi,4),%eax
80104be4:	83 c3 34             	add    $0x34,%ebx
80104be7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104bee:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
80104bf0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104bf6:	83 c0 04             	add    $0x4,%eax
80104bf9:	39 d8                	cmp    %ebx,%eax
80104bfb:	75 f3                	jne    80104bf0 <acquire+0x90>
}
80104bfd:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104c00:	5b                   	pop    %ebx
80104c01:	5e                   	pop    %esi
80104c02:	5d                   	pop    %ebp
80104c03:	c3                   	ret    
    panic("acquire");
80104c04:	83 ec 0c             	sub    $0xc,%esp
80104c07:	68 55 7e 10 80       	push   $0x80107e55
80104c0c:	e8 7f b8 ff ff       	call   80100490 <panic>
80104c11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104c18:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104c1f:	90                   	nop

80104c20 <release>:
{
80104c20:	f3 0f 1e fb          	endbr32 
80104c24:	55                   	push   %ebp
80104c25:	89 e5                	mov    %esp,%ebp
80104c27:	53                   	push   %ebx
80104c28:	83 ec 10             	sub    $0x10,%esp
80104c2b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80104c2e:	53                   	push   %ebx
80104c2f:	e8 dc fe ff ff       	call   80104b10 <holding>
80104c34:	83 c4 10             	add    $0x10,%esp
80104c37:	85 c0                	test   %eax,%eax
80104c39:	74 22                	je     80104c5d <release+0x3d>
  lk->pcs[0] = 0;
80104c3b:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80104c42:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80104c49:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104c4e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}
80104c54:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c57:	c9                   	leave  
  popcli();
80104c58:	e9 53 fe ff ff       	jmp    80104ab0 <popcli>
    panic("release");
80104c5d:	83 ec 0c             	sub    $0xc,%esp
80104c60:	68 5d 7e 10 80       	push   $0x80107e5d
80104c65:	e8 26 b8 ff ff       	call   80100490 <panic>
80104c6a:	66 90                	xchg   %ax,%ax
80104c6c:	66 90                	xchg   %ax,%ax
80104c6e:	66 90                	xchg   %ax,%ax

80104c70 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104c70:	f3 0f 1e fb          	endbr32 
80104c74:	55                   	push   %ebp
80104c75:	89 e5                	mov    %esp,%ebp
80104c77:	57                   	push   %edi
80104c78:	8b 55 08             	mov    0x8(%ebp),%edx
80104c7b:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104c7e:	53                   	push   %ebx
80104c7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  if ((int)dst%4 == 0 && n%4 == 0){
80104c82:	89 d7                	mov    %edx,%edi
80104c84:	09 cf                	or     %ecx,%edi
80104c86:	83 e7 03             	and    $0x3,%edi
80104c89:	75 25                	jne    80104cb0 <memset+0x40>
    c &= 0xFF;
80104c8b:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104c8e:	c1 e0 18             	shl    $0x18,%eax
80104c91:	89 fb                	mov    %edi,%ebx
80104c93:	c1 e9 02             	shr    $0x2,%ecx
80104c96:	c1 e3 10             	shl    $0x10,%ebx
80104c99:	09 d8                	or     %ebx,%eax
80104c9b:	09 f8                	or     %edi,%eax
80104c9d:	c1 e7 08             	shl    $0x8,%edi
80104ca0:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80104ca2:	89 d7                	mov    %edx,%edi
80104ca4:	fc                   	cld    
80104ca5:	f3 ab                	rep stos %eax,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80104ca7:	5b                   	pop    %ebx
80104ca8:	89 d0                	mov    %edx,%eax
80104caa:	5f                   	pop    %edi
80104cab:	5d                   	pop    %ebp
80104cac:	c3                   	ret    
80104cad:	8d 76 00             	lea    0x0(%esi),%esi
  asm volatile("cld; rep stosb" :
80104cb0:	89 d7                	mov    %edx,%edi
80104cb2:	fc                   	cld    
80104cb3:	f3 aa                	rep stos %al,%es:(%edi)
80104cb5:	5b                   	pop    %ebx
80104cb6:	89 d0                	mov    %edx,%eax
80104cb8:	5f                   	pop    %edi
80104cb9:	5d                   	pop    %ebp
80104cba:	c3                   	ret    
80104cbb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104cbf:	90                   	nop

80104cc0 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104cc0:	f3 0f 1e fb          	endbr32 
80104cc4:	55                   	push   %ebp
80104cc5:	89 e5                	mov    %esp,%ebp
80104cc7:	56                   	push   %esi
80104cc8:	8b 75 10             	mov    0x10(%ebp),%esi
80104ccb:	8b 55 08             	mov    0x8(%ebp),%edx
80104cce:	53                   	push   %ebx
80104ccf:	8b 45 0c             	mov    0xc(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104cd2:	85 f6                	test   %esi,%esi
80104cd4:	74 2a                	je     80104d00 <memcmp+0x40>
80104cd6:	01 c6                	add    %eax,%esi
80104cd8:	eb 10                	jmp    80104cea <memcmp+0x2a>
80104cda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
80104ce0:	83 c0 01             	add    $0x1,%eax
80104ce3:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80104ce6:	39 f0                	cmp    %esi,%eax
80104ce8:	74 16                	je     80104d00 <memcmp+0x40>
    if(*s1 != *s2)
80104cea:	0f b6 0a             	movzbl (%edx),%ecx
80104ced:	0f b6 18             	movzbl (%eax),%ebx
80104cf0:	38 d9                	cmp    %bl,%cl
80104cf2:	74 ec                	je     80104ce0 <memcmp+0x20>
      return *s1 - *s2;
80104cf4:	0f b6 c1             	movzbl %cl,%eax
80104cf7:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80104cf9:	5b                   	pop    %ebx
80104cfa:	5e                   	pop    %esi
80104cfb:	5d                   	pop    %ebp
80104cfc:	c3                   	ret    
80104cfd:	8d 76 00             	lea    0x0(%esi),%esi
80104d00:	5b                   	pop    %ebx
  return 0;
80104d01:	31 c0                	xor    %eax,%eax
}
80104d03:	5e                   	pop    %esi
80104d04:	5d                   	pop    %ebp
80104d05:	c3                   	ret    
80104d06:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104d0d:	8d 76 00             	lea    0x0(%esi),%esi

80104d10 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104d10:	f3 0f 1e fb          	endbr32 
80104d14:	55                   	push   %ebp
80104d15:	89 e5                	mov    %esp,%ebp
80104d17:	57                   	push   %edi
80104d18:	8b 55 08             	mov    0x8(%ebp),%edx
80104d1b:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104d1e:	56                   	push   %esi
80104d1f:	8b 75 0c             	mov    0xc(%ebp),%esi
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80104d22:	39 d6                	cmp    %edx,%esi
80104d24:	73 2a                	jae    80104d50 <memmove+0x40>
80104d26:	8d 3c 0e             	lea    (%esi,%ecx,1),%edi
80104d29:	39 fa                	cmp    %edi,%edx
80104d2b:	73 23                	jae    80104d50 <memmove+0x40>
80104d2d:	8d 41 ff             	lea    -0x1(%ecx),%eax
    s += n;
    d += n;
    while(n-- > 0)
80104d30:	85 c9                	test   %ecx,%ecx
80104d32:	74 13                	je     80104d47 <memmove+0x37>
80104d34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      *--d = *--s;
80104d38:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
80104d3c:	88 0c 02             	mov    %cl,(%edx,%eax,1)
    while(n-- > 0)
80104d3f:	83 e8 01             	sub    $0x1,%eax
80104d42:	83 f8 ff             	cmp    $0xffffffff,%eax
80104d45:	75 f1                	jne    80104d38 <memmove+0x28>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
80104d47:	5e                   	pop    %esi
80104d48:	89 d0                	mov    %edx,%eax
80104d4a:	5f                   	pop    %edi
80104d4b:	5d                   	pop    %ebp
80104d4c:	c3                   	ret    
80104d4d:	8d 76 00             	lea    0x0(%esi),%esi
    while(n-- > 0)
80104d50:	8d 04 0e             	lea    (%esi,%ecx,1),%eax
80104d53:	89 d7                	mov    %edx,%edi
80104d55:	85 c9                	test   %ecx,%ecx
80104d57:	74 ee                	je     80104d47 <memmove+0x37>
80104d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      *d++ = *s++;
80104d60:	a4                   	movsb  %ds:(%esi),%es:(%edi)
    while(n-- > 0)
80104d61:	39 f0                	cmp    %esi,%eax
80104d63:	75 fb                	jne    80104d60 <memmove+0x50>
}
80104d65:	5e                   	pop    %esi
80104d66:	89 d0                	mov    %edx,%eax
80104d68:	5f                   	pop    %edi
80104d69:	5d                   	pop    %ebp
80104d6a:	c3                   	ret    
80104d6b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104d6f:	90                   	nop

80104d70 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80104d70:	f3 0f 1e fb          	endbr32 
  return memmove(dst, src, n);
80104d74:	eb 9a                	jmp    80104d10 <memmove>
80104d76:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104d7d:	8d 76 00             	lea    0x0(%esi),%esi

80104d80 <strncmp>:
}

int
strncmp(const char *p, const char *q, uint n)
{
80104d80:	f3 0f 1e fb          	endbr32 
80104d84:	55                   	push   %ebp
80104d85:	89 e5                	mov    %esp,%ebp
80104d87:	56                   	push   %esi
80104d88:	8b 75 10             	mov    0x10(%ebp),%esi
80104d8b:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d8e:	53                   	push   %ebx
80104d8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80104d92:	85 f6                	test   %esi,%esi
80104d94:	74 32                	je     80104dc8 <strncmp+0x48>
80104d96:	01 c6                	add    %eax,%esi
80104d98:	eb 14                	jmp    80104dae <strncmp+0x2e>
80104d9a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104da0:	38 da                	cmp    %bl,%dl
80104da2:	75 14                	jne    80104db8 <strncmp+0x38>
    n--, p++, q++;
80104da4:	83 c0 01             	add    $0x1,%eax
80104da7:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80104daa:	39 f0                	cmp    %esi,%eax
80104dac:	74 1a                	je     80104dc8 <strncmp+0x48>
80104dae:	0f b6 11             	movzbl (%ecx),%edx
80104db1:	0f b6 18             	movzbl (%eax),%ebx
80104db4:	84 d2                	test   %dl,%dl
80104db6:	75 e8                	jne    80104da0 <strncmp+0x20>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
80104db8:	0f b6 c2             	movzbl %dl,%eax
80104dbb:	29 d8                	sub    %ebx,%eax
}
80104dbd:	5b                   	pop    %ebx
80104dbe:	5e                   	pop    %esi
80104dbf:	5d                   	pop    %ebp
80104dc0:	c3                   	ret    
80104dc1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104dc8:	5b                   	pop    %ebx
    return 0;
80104dc9:	31 c0                	xor    %eax,%eax
}
80104dcb:	5e                   	pop    %esi
80104dcc:	5d                   	pop    %ebp
80104dcd:	c3                   	ret    
80104dce:	66 90                	xchg   %ax,%ax

80104dd0 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104dd0:	f3 0f 1e fb          	endbr32 
80104dd4:	55                   	push   %ebp
80104dd5:	89 e5                	mov    %esp,%ebp
80104dd7:	57                   	push   %edi
80104dd8:	56                   	push   %esi
80104dd9:	8b 75 08             	mov    0x8(%ebp),%esi
80104ddc:	53                   	push   %ebx
80104ddd:	8b 45 10             	mov    0x10(%ebp),%eax
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80104de0:	89 f2                	mov    %esi,%edx
80104de2:	eb 1b                	jmp    80104dff <strncpy+0x2f>
80104de4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104de8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80104dec:	8b 7d 0c             	mov    0xc(%ebp),%edi
80104def:	83 c2 01             	add    $0x1,%edx
80104df2:	0f b6 7f ff          	movzbl -0x1(%edi),%edi
80104df6:	89 f9                	mov    %edi,%ecx
80104df8:	88 4a ff             	mov    %cl,-0x1(%edx)
80104dfb:	84 c9                	test   %cl,%cl
80104dfd:	74 09                	je     80104e08 <strncpy+0x38>
80104dff:	89 c3                	mov    %eax,%ebx
80104e01:	83 e8 01             	sub    $0x1,%eax
80104e04:	85 db                	test   %ebx,%ebx
80104e06:	7f e0                	jg     80104de8 <strncpy+0x18>
    ;
  while(n-- > 0)
80104e08:	89 d1                	mov    %edx,%ecx
80104e0a:	85 c0                	test   %eax,%eax
80104e0c:	7e 15                	jle    80104e23 <strncpy+0x53>
80104e0e:	66 90                	xchg   %ax,%ax
    *s++ = 0;
80104e10:	83 c1 01             	add    $0x1,%ecx
80104e13:	c6 41 ff 00          	movb   $0x0,-0x1(%ecx)
  while(n-- > 0)
80104e17:	89 c8                	mov    %ecx,%eax
80104e19:	f7 d0                	not    %eax
80104e1b:	01 d0                	add    %edx,%eax
80104e1d:	01 d8                	add    %ebx,%eax
80104e1f:	85 c0                	test   %eax,%eax
80104e21:	7f ed                	jg     80104e10 <strncpy+0x40>
  return os;
}
80104e23:	5b                   	pop    %ebx
80104e24:	89 f0                	mov    %esi,%eax
80104e26:	5e                   	pop    %esi
80104e27:	5f                   	pop    %edi
80104e28:	5d                   	pop    %ebp
80104e29:	c3                   	ret    
80104e2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104e30 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104e30:	f3 0f 1e fb          	endbr32 
80104e34:	55                   	push   %ebp
80104e35:	89 e5                	mov    %esp,%ebp
80104e37:	56                   	push   %esi
80104e38:	8b 55 10             	mov    0x10(%ebp),%edx
80104e3b:	8b 75 08             	mov    0x8(%ebp),%esi
80104e3e:	53                   	push   %ebx
80104e3f:	8b 45 0c             	mov    0xc(%ebp),%eax
  char *os;

  os = s;
  if(n <= 0)
80104e42:	85 d2                	test   %edx,%edx
80104e44:	7e 21                	jle    80104e67 <safestrcpy+0x37>
80104e46:	8d 5c 10 ff          	lea    -0x1(%eax,%edx,1),%ebx
80104e4a:	89 f2                	mov    %esi,%edx
80104e4c:	eb 12                	jmp    80104e60 <safestrcpy+0x30>
80104e4e:	66 90                	xchg   %ax,%ax
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80104e50:	0f b6 08             	movzbl (%eax),%ecx
80104e53:	83 c0 01             	add    $0x1,%eax
80104e56:	83 c2 01             	add    $0x1,%edx
80104e59:	88 4a ff             	mov    %cl,-0x1(%edx)
80104e5c:	84 c9                	test   %cl,%cl
80104e5e:	74 04                	je     80104e64 <safestrcpy+0x34>
80104e60:	39 d8                	cmp    %ebx,%eax
80104e62:	75 ec                	jne    80104e50 <safestrcpy+0x20>
    ;
  *s = 0;
80104e64:	c6 02 00             	movb   $0x0,(%edx)
  return os;
}
80104e67:	89 f0                	mov    %esi,%eax
80104e69:	5b                   	pop    %ebx
80104e6a:	5e                   	pop    %esi
80104e6b:	5d                   	pop    %ebp
80104e6c:	c3                   	ret    
80104e6d:	8d 76 00             	lea    0x0(%esi),%esi

80104e70 <strlen>:

int
strlen(const char *s)
{
80104e70:	f3 0f 1e fb          	endbr32 
80104e74:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
80104e75:	31 c0                	xor    %eax,%eax
{
80104e77:	89 e5                	mov    %esp,%ebp
80104e79:	8b 55 08             	mov    0x8(%ebp),%edx
  for(n = 0; s[n]; n++)
80104e7c:	80 3a 00             	cmpb   $0x0,(%edx)
80104e7f:	74 10                	je     80104e91 <strlen+0x21>
80104e81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104e88:	83 c0 01             	add    $0x1,%eax
80104e8b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80104e8f:	75 f7                	jne    80104e88 <strlen+0x18>
    ;
  return n;
}
80104e91:	5d                   	pop    %ebp
80104e92:	c3                   	ret    

80104e93 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104e93:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104e97:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80104e9b:	55                   	push   %ebp
  pushl %ebx
80104e9c:	53                   	push   %ebx
  pushl %esi
80104e9d:	56                   	push   %esi
  pushl %edi
80104e9e:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104e9f:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104ea1:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80104ea3:	5f                   	pop    %edi
  popl %esi
80104ea4:	5e                   	pop    %esi
  popl %ebx
80104ea5:	5b                   	pop    %ebx
  popl %ebp
80104ea6:	5d                   	pop    %ebp
  ret
80104ea7:	c3                   	ret    
80104ea8:	66 90                	xchg   %ax,%ax
80104eaa:	66 90                	xchg   %ax,%ax
80104eac:	66 90                	xchg   %ax,%ax
80104eae:	66 90                	xchg   %ax,%ax

80104eb0 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104eb0:	f3 0f 1e fb          	endbr32 
80104eb4:	55                   	push   %ebp
80104eb5:	89 e5                	mov    %esp,%ebp
80104eb7:	53                   	push   %ebx
80104eb8:	83 ec 04             	sub    $0x4,%esp
80104ebb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80104ebe:	e8 dd ef ff ff       	call   80103ea0 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104ec3:	8b 00                	mov    (%eax),%eax
80104ec5:	39 d8                	cmp    %ebx,%eax
80104ec7:	76 17                	jbe    80104ee0 <fetchint+0x30>
80104ec9:	8d 53 04             	lea    0x4(%ebx),%edx
80104ecc:	39 d0                	cmp    %edx,%eax
80104ece:	72 10                	jb     80104ee0 <fetchint+0x30>
    return -1;
  *ip = *(int*)(addr);
80104ed0:	8b 45 0c             	mov    0xc(%ebp),%eax
80104ed3:	8b 13                	mov    (%ebx),%edx
80104ed5:	89 10                	mov    %edx,(%eax)
  return 0;
80104ed7:	31 c0                	xor    %eax,%eax
}
80104ed9:	83 c4 04             	add    $0x4,%esp
80104edc:	5b                   	pop    %ebx
80104edd:	5d                   	pop    %ebp
80104ede:	c3                   	ret    
80104edf:	90                   	nop
    return -1;
80104ee0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ee5:	eb f2                	jmp    80104ed9 <fetchint+0x29>
80104ee7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104eee:	66 90                	xchg   %ax,%ax

80104ef0 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104ef0:	f3 0f 1e fb          	endbr32 
80104ef4:	55                   	push   %ebp
80104ef5:	89 e5                	mov    %esp,%ebp
80104ef7:	53                   	push   %ebx
80104ef8:	83 ec 04             	sub    $0x4,%esp
80104efb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80104efe:	e8 9d ef ff ff       	call   80103ea0 <myproc>

  if(addr >= curproc->sz)
80104f03:	39 18                	cmp    %ebx,(%eax)
80104f05:	76 31                	jbe    80104f38 <fetchstr+0x48>
    return -1;
  *pp = (char*)addr;
80104f07:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f0a:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104f0c:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104f0e:	39 d3                	cmp    %edx,%ebx
80104f10:	73 26                	jae    80104f38 <fetchstr+0x48>
80104f12:	89 d8                	mov    %ebx,%eax
80104f14:	eb 11                	jmp    80104f27 <fetchstr+0x37>
80104f16:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104f1d:	8d 76 00             	lea    0x0(%esi),%esi
80104f20:	83 c0 01             	add    $0x1,%eax
80104f23:	39 c2                	cmp    %eax,%edx
80104f25:	76 11                	jbe    80104f38 <fetchstr+0x48>
    if(*s == 0)
80104f27:	80 38 00             	cmpb   $0x0,(%eax)
80104f2a:	75 f4                	jne    80104f20 <fetchstr+0x30>
      return s - *pp;
  }
  return -1;
}
80104f2c:	83 c4 04             	add    $0x4,%esp
      return s - *pp;
80104f2f:	29 d8                	sub    %ebx,%eax
}
80104f31:	5b                   	pop    %ebx
80104f32:	5d                   	pop    %ebp
80104f33:	c3                   	ret    
80104f34:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104f38:	83 c4 04             	add    $0x4,%esp
    return -1;
80104f3b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104f40:	5b                   	pop    %ebx
80104f41:	5d                   	pop    %ebp
80104f42:	c3                   	ret    
80104f43:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104f4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104f50 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104f50:	f3 0f 1e fb          	endbr32 
80104f54:	55                   	push   %ebp
80104f55:	89 e5                	mov    %esp,%ebp
80104f57:	56                   	push   %esi
80104f58:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104f59:	e8 42 ef ff ff       	call   80103ea0 <myproc>
80104f5e:	8b 55 08             	mov    0x8(%ebp),%edx
80104f61:	8b 40 1c             	mov    0x1c(%eax),%eax
80104f64:	8b 40 44             	mov    0x44(%eax),%eax
80104f67:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104f6a:	e8 31 ef ff ff       	call   80103ea0 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104f6f:	8d 73 04             	lea    0x4(%ebx),%esi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104f72:	8b 00                	mov    (%eax),%eax
80104f74:	39 c6                	cmp    %eax,%esi
80104f76:	73 18                	jae    80104f90 <argint+0x40>
80104f78:	8d 53 08             	lea    0x8(%ebx),%edx
80104f7b:	39 d0                	cmp    %edx,%eax
80104f7d:	72 11                	jb     80104f90 <argint+0x40>
  *ip = *(int*)(addr);
80104f7f:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f82:	8b 53 04             	mov    0x4(%ebx),%edx
80104f85:	89 10                	mov    %edx,(%eax)
  return 0;
80104f87:	31 c0                	xor    %eax,%eax
}
80104f89:	5b                   	pop    %ebx
80104f8a:	5e                   	pop    %esi
80104f8b:	5d                   	pop    %ebp
80104f8c:	c3                   	ret    
80104f8d:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80104f90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104f95:	eb f2                	jmp    80104f89 <argint+0x39>
80104f97:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104f9e:	66 90                	xchg   %ax,%ax

80104fa0 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104fa0:	f3 0f 1e fb          	endbr32 
80104fa4:	55                   	push   %ebp
80104fa5:	89 e5                	mov    %esp,%ebp
80104fa7:	56                   	push   %esi
80104fa8:	53                   	push   %ebx
80104fa9:	83 ec 10             	sub    $0x10,%esp
80104fac:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80104faf:	e8 ec ee ff ff       	call   80103ea0 <myproc>
 
  if(argint(n, &i) < 0)
80104fb4:	83 ec 08             	sub    $0x8,%esp
  struct proc *curproc = myproc();
80104fb7:	89 c6                	mov    %eax,%esi
  if(argint(n, &i) < 0)
80104fb9:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104fbc:	50                   	push   %eax
80104fbd:	ff 75 08             	pushl  0x8(%ebp)
80104fc0:	e8 8b ff ff ff       	call   80104f50 <argint>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104fc5:	83 c4 10             	add    $0x10,%esp
80104fc8:	85 c0                	test   %eax,%eax
80104fca:	78 24                	js     80104ff0 <argptr+0x50>
80104fcc:	85 db                	test   %ebx,%ebx
80104fce:	78 20                	js     80104ff0 <argptr+0x50>
80104fd0:	8b 16                	mov    (%esi),%edx
80104fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fd5:	39 c2                	cmp    %eax,%edx
80104fd7:	76 17                	jbe    80104ff0 <argptr+0x50>
80104fd9:	01 c3                	add    %eax,%ebx
80104fdb:	39 da                	cmp    %ebx,%edx
80104fdd:	72 11                	jb     80104ff0 <argptr+0x50>
    return -1;
  *pp = (char*)i;
80104fdf:	8b 55 0c             	mov    0xc(%ebp),%edx
80104fe2:	89 02                	mov    %eax,(%edx)
  return 0;
80104fe4:	31 c0                	xor    %eax,%eax
}
80104fe6:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104fe9:	5b                   	pop    %ebx
80104fea:	5e                   	pop    %esi
80104feb:	5d                   	pop    %ebp
80104fec:	c3                   	ret    
80104fed:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80104ff0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ff5:	eb ef                	jmp    80104fe6 <argptr+0x46>
80104ff7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104ffe:	66 90                	xchg   %ax,%ax

80105000 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80105000:	f3 0f 1e fb          	endbr32 
80105004:	55                   	push   %ebp
80105005:	89 e5                	mov    %esp,%ebp
80105007:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010500a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010500d:	50                   	push   %eax
8010500e:	ff 75 08             	pushl  0x8(%ebp)
80105011:	e8 3a ff ff ff       	call   80104f50 <argint>
80105016:	83 c4 10             	add    $0x10,%esp
80105019:	85 c0                	test   %eax,%eax
8010501b:	78 13                	js     80105030 <argstr+0x30>
    return -1;
  return fetchstr(addr, pp);
8010501d:	83 ec 08             	sub    $0x8,%esp
80105020:	ff 75 0c             	pushl  0xc(%ebp)
80105023:	ff 75 f4             	pushl  -0xc(%ebp)
80105026:	e8 c5 fe ff ff       	call   80104ef0 <fetchstr>
8010502b:	83 c4 10             	add    $0x10,%esp
}
8010502e:	c9                   	leave  
8010502f:	c3                   	ret    
80105030:	c9                   	leave  
    return -1;
80105031:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105036:	c3                   	ret    
80105037:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010503e:	66 90                	xchg   %ax,%ax

80105040 <syscall>:
[SYS_getNumFreePages]   sys_getNumFreePages,
};

void
syscall(void)
{
80105040:	f3 0f 1e fb          	endbr32 
80105044:	55                   	push   %ebp
80105045:	89 e5                	mov    %esp,%ebp
80105047:	53                   	push   %ebx
80105048:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
8010504b:	e8 50 ee ff ff       	call   80103ea0 <myproc>
80105050:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80105052:	8b 40 1c             	mov    0x1c(%eax),%eax
80105055:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105058:	8d 50 ff             	lea    -0x1(%eax),%edx
8010505b:	83 fa 16             	cmp    $0x16,%edx
8010505e:	77 20                	ja     80105080 <syscall+0x40>
80105060:	8b 14 85 a0 7e 10 80 	mov    -0x7fef8160(,%eax,4),%edx
80105067:	85 d2                	test   %edx,%edx
80105069:	74 15                	je     80105080 <syscall+0x40>
    curproc->tf->eax = syscalls[num]();
8010506b:	ff d2                	call   *%edx
8010506d:	89 c2                	mov    %eax,%edx
8010506f:	8b 43 1c             	mov    0x1c(%ebx),%eax
80105072:	89 50 1c             	mov    %edx,0x1c(%eax)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80105075:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105078:	c9                   	leave  
80105079:	c3                   	ret    
8010507a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    cprintf("%d %s: unknown sys call %d\n",
80105080:	50                   	push   %eax
            curproc->pid, curproc->name, num);
80105081:	8d 43 70             	lea    0x70(%ebx),%eax
    cprintf("%d %s: unknown sys call %d\n",
80105084:	50                   	push   %eax
80105085:	ff 73 14             	pushl  0x14(%ebx)
80105088:	68 65 7e 10 80       	push   $0x80107e65
8010508d:	e8 1e b7 ff ff       	call   801007b0 <cprintf>
    curproc->tf->eax = -1;
80105092:	8b 43 1c             	mov    0x1c(%ebx),%eax
80105095:	83 c4 10             	add    $0x10,%esp
80105098:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
}
8010509f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801050a2:	c9                   	leave  
801050a3:	c3                   	ret    
801050a4:	66 90                	xchg   %ax,%ax
801050a6:	66 90                	xchg   %ax,%ax
801050a8:	66 90                	xchg   %ax,%ax
801050aa:	66 90                	xchg   %ax,%ax
801050ac:	66 90                	xchg   %ax,%ax
801050ae:	66 90                	xchg   %ax,%ax

801050b0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
801050b0:	55                   	push   %ebp
801050b1:	89 e5                	mov    %esp,%ebp
801050b3:	57                   	push   %edi
801050b4:	56                   	push   %esi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801050b5:	8d 7d da             	lea    -0x26(%ebp),%edi
{
801050b8:	53                   	push   %ebx
801050b9:	83 ec 34             	sub    $0x34,%esp
801050bc:	89 4d d0             	mov    %ecx,-0x30(%ebp)
801050bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if((dp = nameiparent(path, name)) == 0)
801050c2:	57                   	push   %edi
801050c3:	50                   	push   %eax
{
801050c4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801050c7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  if((dp = nameiparent(path, name)) == 0)
801050ca:	e8 81 d0 ff ff       	call   80102150 <nameiparent>
801050cf:	83 c4 10             	add    $0x10,%esp
801050d2:	85 c0                	test   %eax,%eax
801050d4:	0f 84 46 01 00 00    	je     80105220 <create+0x170>
    return 0;
  ilock(dp);
801050da:	83 ec 0c             	sub    $0xc,%esp
801050dd:	89 c3                	mov    %eax,%ebx
801050df:	50                   	push   %eax
801050e0:	e8 7b c7 ff ff       	call   80101860 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
801050e5:	83 c4 0c             	add    $0xc,%esp
801050e8:	6a 00                	push   $0x0
801050ea:	57                   	push   %edi
801050eb:	53                   	push   %ebx
801050ec:	e8 bf cc ff ff       	call   80101db0 <dirlookup>
801050f1:	83 c4 10             	add    $0x10,%esp
801050f4:	89 c6                	mov    %eax,%esi
801050f6:	85 c0                	test   %eax,%eax
801050f8:	74 56                	je     80105150 <create+0xa0>
    iunlockput(dp);
801050fa:	83 ec 0c             	sub    $0xc,%esp
801050fd:	53                   	push   %ebx
801050fe:	e8 fd c9 ff ff       	call   80101b00 <iunlockput>
    ilock(ip);
80105103:	89 34 24             	mov    %esi,(%esp)
80105106:	e8 55 c7 ff ff       	call   80101860 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
8010510b:	83 c4 10             	add    $0x10,%esp
8010510e:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105113:	75 1b                	jne    80105130 <create+0x80>
80105115:	66 83 7e 50 02       	cmpw   $0x2,0x50(%esi)
8010511a:	75 14                	jne    80105130 <create+0x80>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
8010511c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010511f:	89 f0                	mov    %esi,%eax
80105121:	5b                   	pop    %ebx
80105122:	5e                   	pop    %esi
80105123:	5f                   	pop    %edi
80105124:	5d                   	pop    %ebp
80105125:	c3                   	ret    
80105126:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010512d:	8d 76 00             	lea    0x0(%esi),%esi
    iunlockput(ip);
80105130:	83 ec 0c             	sub    $0xc,%esp
80105133:	56                   	push   %esi
    return 0;
80105134:	31 f6                	xor    %esi,%esi
    iunlockput(ip);
80105136:	e8 c5 c9 ff ff       	call   80101b00 <iunlockput>
    return 0;
8010513b:	83 c4 10             	add    $0x10,%esp
}
8010513e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105141:	89 f0                	mov    %esi,%eax
80105143:	5b                   	pop    %ebx
80105144:	5e                   	pop    %esi
80105145:	5f                   	pop    %edi
80105146:	5d                   	pop    %ebp
80105147:	c3                   	ret    
80105148:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010514f:	90                   	nop
  if((ip = ialloc(dp->dev, type)) == 0)
80105150:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
80105154:	83 ec 08             	sub    $0x8,%esp
80105157:	50                   	push   %eax
80105158:	ff 33                	pushl  (%ebx)
8010515a:	e8 81 c5 ff ff       	call   801016e0 <ialloc>
8010515f:	83 c4 10             	add    $0x10,%esp
80105162:	89 c6                	mov    %eax,%esi
80105164:	85 c0                	test   %eax,%eax
80105166:	0f 84 cd 00 00 00    	je     80105239 <create+0x189>
  ilock(ip);
8010516c:	83 ec 0c             	sub    $0xc,%esp
8010516f:	50                   	push   %eax
80105170:	e8 eb c6 ff ff       	call   80101860 <ilock>
  ip->major = major;
80105175:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
80105179:	66 89 46 52          	mov    %ax,0x52(%esi)
  ip->minor = minor;
8010517d:	0f b7 45 cc          	movzwl -0x34(%ebp),%eax
80105181:	66 89 46 54          	mov    %ax,0x54(%esi)
  ip->nlink = 1;
80105185:	b8 01 00 00 00       	mov    $0x1,%eax
8010518a:	66 89 46 56          	mov    %ax,0x56(%esi)
  iupdate(ip);
8010518e:	89 34 24             	mov    %esi,(%esp)
80105191:	e8 0a c6 ff ff       	call   801017a0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80105196:	83 c4 10             	add    $0x10,%esp
80105199:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010519e:	74 30                	je     801051d0 <create+0x120>
  if(dirlink(dp, name, ip->inum) < 0)
801051a0:	83 ec 04             	sub    $0x4,%esp
801051a3:	ff 76 04             	pushl  0x4(%esi)
801051a6:	57                   	push   %edi
801051a7:	53                   	push   %ebx
801051a8:	e8 c3 ce ff ff       	call   80102070 <dirlink>
801051ad:	83 c4 10             	add    $0x10,%esp
801051b0:	85 c0                	test   %eax,%eax
801051b2:	78 78                	js     8010522c <create+0x17c>
  iunlockput(dp);
801051b4:	83 ec 0c             	sub    $0xc,%esp
801051b7:	53                   	push   %ebx
801051b8:	e8 43 c9 ff ff       	call   80101b00 <iunlockput>
  return ip;
801051bd:	83 c4 10             	add    $0x10,%esp
}
801051c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801051c3:	89 f0                	mov    %esi,%eax
801051c5:	5b                   	pop    %ebx
801051c6:	5e                   	pop    %esi
801051c7:	5f                   	pop    %edi
801051c8:	5d                   	pop    %ebp
801051c9:	c3                   	ret    
801051ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iupdate(dp);
801051d0:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink++;  // for ".."
801051d3:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
    iupdate(dp);
801051d8:	53                   	push   %ebx
801051d9:	e8 c2 c5 ff ff       	call   801017a0 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801051de:	83 c4 0c             	add    $0xc,%esp
801051e1:	ff 76 04             	pushl  0x4(%esi)
801051e4:	68 1c 7f 10 80       	push   $0x80107f1c
801051e9:	56                   	push   %esi
801051ea:	e8 81 ce ff ff       	call   80102070 <dirlink>
801051ef:	83 c4 10             	add    $0x10,%esp
801051f2:	85 c0                	test   %eax,%eax
801051f4:	78 18                	js     8010520e <create+0x15e>
801051f6:	83 ec 04             	sub    $0x4,%esp
801051f9:	ff 73 04             	pushl  0x4(%ebx)
801051fc:	68 1b 7f 10 80       	push   $0x80107f1b
80105201:	56                   	push   %esi
80105202:	e8 69 ce ff ff       	call   80102070 <dirlink>
80105207:	83 c4 10             	add    $0x10,%esp
8010520a:	85 c0                	test   %eax,%eax
8010520c:	79 92                	jns    801051a0 <create+0xf0>
      panic("create dots");
8010520e:	83 ec 0c             	sub    $0xc,%esp
80105211:	68 0f 7f 10 80       	push   $0x80107f0f
80105216:	e8 75 b2 ff ff       	call   80100490 <panic>
8010521b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010521f:	90                   	nop
}
80105220:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return 0;
80105223:	31 f6                	xor    %esi,%esi
}
80105225:	5b                   	pop    %ebx
80105226:	89 f0                	mov    %esi,%eax
80105228:	5e                   	pop    %esi
80105229:	5f                   	pop    %edi
8010522a:	5d                   	pop    %ebp
8010522b:	c3                   	ret    
    panic("create: dirlink");
8010522c:	83 ec 0c             	sub    $0xc,%esp
8010522f:	68 1e 7f 10 80       	push   $0x80107f1e
80105234:	e8 57 b2 ff ff       	call   80100490 <panic>
    panic("create: ialloc");
80105239:	83 ec 0c             	sub    $0xc,%esp
8010523c:	68 00 7f 10 80       	push   $0x80107f00
80105241:	e8 4a b2 ff ff       	call   80100490 <panic>
80105246:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010524d:	8d 76 00             	lea    0x0(%esi),%esi

80105250 <argfd.constprop.0>:
argfd(int n, int *pfd, struct file **pf)
80105250:	55                   	push   %ebp
80105251:	89 e5                	mov    %esp,%ebp
80105253:	56                   	push   %esi
80105254:	89 d6                	mov    %edx,%esi
80105256:	53                   	push   %ebx
80105257:	89 c3                	mov    %eax,%ebx
  if(argint(n, &fd) < 0)
80105259:	8d 45 f4             	lea    -0xc(%ebp),%eax
argfd(int n, int *pfd, struct file **pf)
8010525c:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
8010525f:	50                   	push   %eax
80105260:	6a 00                	push   $0x0
80105262:	e8 e9 fc ff ff       	call   80104f50 <argint>
80105267:	83 c4 10             	add    $0x10,%esp
8010526a:	85 c0                	test   %eax,%eax
8010526c:	78 2a                	js     80105298 <argfd.constprop.0+0x48>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010526e:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80105272:	77 24                	ja     80105298 <argfd.constprop.0+0x48>
80105274:	e8 27 ec ff ff       	call   80103ea0 <myproc>
80105279:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010527c:	8b 44 90 2c          	mov    0x2c(%eax,%edx,4),%eax
80105280:	85 c0                	test   %eax,%eax
80105282:	74 14                	je     80105298 <argfd.constprop.0+0x48>
  if(pfd)
80105284:	85 db                	test   %ebx,%ebx
80105286:	74 02                	je     8010528a <argfd.constprop.0+0x3a>
    *pfd = fd;
80105288:	89 13                	mov    %edx,(%ebx)
    *pf = f;
8010528a:	89 06                	mov    %eax,(%esi)
  return 0;
8010528c:	31 c0                	xor    %eax,%eax
}
8010528e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105291:	5b                   	pop    %ebx
80105292:	5e                   	pop    %esi
80105293:	5d                   	pop    %ebp
80105294:	c3                   	ret    
80105295:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80105298:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010529d:	eb ef                	jmp    8010528e <argfd.constprop.0+0x3e>
8010529f:	90                   	nop

801052a0 <sys_dup>:
{
801052a0:	f3 0f 1e fb          	endbr32 
801052a4:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0)
801052a5:	31 c0                	xor    %eax,%eax
{
801052a7:	89 e5                	mov    %esp,%ebp
801052a9:	56                   	push   %esi
801052aa:	53                   	push   %ebx
  if(argfd(0, 0, &f) < 0)
801052ab:	8d 55 f4             	lea    -0xc(%ebp),%edx
{
801052ae:	83 ec 10             	sub    $0x10,%esp
  if(argfd(0, 0, &f) < 0)
801052b1:	e8 9a ff ff ff       	call   80105250 <argfd.constprop.0>
801052b6:	85 c0                	test   %eax,%eax
801052b8:	78 1e                	js     801052d8 <sys_dup+0x38>
  if((fd=fdalloc(f)) < 0)
801052ba:	8b 75 f4             	mov    -0xc(%ebp),%esi
  for(fd = 0; fd < NOFILE; fd++){
801052bd:	31 db                	xor    %ebx,%ebx
  struct proc *curproc = myproc();
801052bf:	e8 dc eb ff ff       	call   80103ea0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
801052c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(curproc->ofile[fd] == 0){
801052c8:	8b 54 98 2c          	mov    0x2c(%eax,%ebx,4),%edx
801052cc:	85 d2                	test   %edx,%edx
801052ce:	74 20                	je     801052f0 <sys_dup+0x50>
  for(fd = 0; fd < NOFILE; fd++){
801052d0:	83 c3 01             	add    $0x1,%ebx
801052d3:	83 fb 10             	cmp    $0x10,%ebx
801052d6:	75 f0                	jne    801052c8 <sys_dup+0x28>
}
801052d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
    return -1;
801052db:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
801052e0:	89 d8                	mov    %ebx,%eax
801052e2:	5b                   	pop    %ebx
801052e3:	5e                   	pop    %esi
801052e4:	5d                   	pop    %ebp
801052e5:	c3                   	ret    
801052e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801052ed:	8d 76 00             	lea    0x0(%esi),%esi
      curproc->ofile[fd] = f;
801052f0:	89 74 98 2c          	mov    %esi,0x2c(%eax,%ebx,4)
  filedup(f);
801052f4:	83 ec 0c             	sub    $0xc,%esp
801052f7:	ff 75 f4             	pushl  -0xc(%ebp)
801052fa:	e8 71 bc ff ff       	call   80100f70 <filedup>
  return fd;
801052ff:	83 c4 10             	add    $0x10,%esp
}
80105302:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105305:	89 d8                	mov    %ebx,%eax
80105307:	5b                   	pop    %ebx
80105308:	5e                   	pop    %esi
80105309:	5d                   	pop    %ebp
8010530a:	c3                   	ret    
8010530b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010530f:	90                   	nop

80105310 <sys_read>:
{
80105310:	f3 0f 1e fb          	endbr32 
80105314:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105315:	31 c0                	xor    %eax,%eax
{
80105317:	89 e5                	mov    %esp,%ebp
80105319:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010531c:	8d 55 ec             	lea    -0x14(%ebp),%edx
8010531f:	e8 2c ff ff ff       	call   80105250 <argfd.constprop.0>
80105324:	85 c0                	test   %eax,%eax
80105326:	78 48                	js     80105370 <sys_read+0x60>
80105328:	83 ec 08             	sub    $0x8,%esp
8010532b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010532e:	50                   	push   %eax
8010532f:	6a 02                	push   $0x2
80105331:	e8 1a fc ff ff       	call   80104f50 <argint>
80105336:	83 c4 10             	add    $0x10,%esp
80105339:	85 c0                	test   %eax,%eax
8010533b:	78 33                	js     80105370 <sys_read+0x60>
8010533d:	83 ec 04             	sub    $0x4,%esp
80105340:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105343:	ff 75 f0             	pushl  -0x10(%ebp)
80105346:	50                   	push   %eax
80105347:	6a 01                	push   $0x1
80105349:	e8 52 fc ff ff       	call   80104fa0 <argptr>
8010534e:	83 c4 10             	add    $0x10,%esp
80105351:	85 c0                	test   %eax,%eax
80105353:	78 1b                	js     80105370 <sys_read+0x60>
  return fileread(f, p, n);
80105355:	83 ec 04             	sub    $0x4,%esp
80105358:	ff 75 f0             	pushl  -0x10(%ebp)
8010535b:	ff 75 f4             	pushl  -0xc(%ebp)
8010535e:	ff 75 ec             	pushl  -0x14(%ebp)
80105361:	e8 8a bd ff ff       	call   801010f0 <fileread>
80105366:	83 c4 10             	add    $0x10,%esp
}
80105369:	c9                   	leave  
8010536a:	c3                   	ret    
8010536b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010536f:	90                   	nop
80105370:	c9                   	leave  
    return -1;
80105371:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105376:	c3                   	ret    
80105377:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010537e:	66 90                	xchg   %ax,%ax

80105380 <sys_write>:
{
80105380:	f3 0f 1e fb          	endbr32 
80105384:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105385:	31 c0                	xor    %eax,%eax
{
80105387:	89 e5                	mov    %esp,%ebp
80105389:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010538c:	8d 55 ec             	lea    -0x14(%ebp),%edx
8010538f:	e8 bc fe ff ff       	call   80105250 <argfd.constprop.0>
80105394:	85 c0                	test   %eax,%eax
80105396:	78 48                	js     801053e0 <sys_write+0x60>
80105398:	83 ec 08             	sub    $0x8,%esp
8010539b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010539e:	50                   	push   %eax
8010539f:	6a 02                	push   $0x2
801053a1:	e8 aa fb ff ff       	call   80104f50 <argint>
801053a6:	83 c4 10             	add    $0x10,%esp
801053a9:	85 c0                	test   %eax,%eax
801053ab:	78 33                	js     801053e0 <sys_write+0x60>
801053ad:	83 ec 04             	sub    $0x4,%esp
801053b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
801053b3:	ff 75 f0             	pushl  -0x10(%ebp)
801053b6:	50                   	push   %eax
801053b7:	6a 01                	push   $0x1
801053b9:	e8 e2 fb ff ff       	call   80104fa0 <argptr>
801053be:	83 c4 10             	add    $0x10,%esp
801053c1:	85 c0                	test   %eax,%eax
801053c3:	78 1b                	js     801053e0 <sys_write+0x60>
  return filewrite(f, p, n);
801053c5:	83 ec 04             	sub    $0x4,%esp
801053c8:	ff 75 f0             	pushl  -0x10(%ebp)
801053cb:	ff 75 f4             	pushl  -0xc(%ebp)
801053ce:	ff 75 ec             	pushl  -0x14(%ebp)
801053d1:	e8 ba bd ff ff       	call   80101190 <filewrite>
801053d6:	83 c4 10             	add    $0x10,%esp
}
801053d9:	c9                   	leave  
801053da:	c3                   	ret    
801053db:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801053df:	90                   	nop
801053e0:	c9                   	leave  
    return -1;
801053e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801053e6:	c3                   	ret    
801053e7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801053ee:	66 90                	xchg   %ax,%ax

801053f0 <sys_close>:
{
801053f0:	f3 0f 1e fb          	endbr32 
801053f4:	55                   	push   %ebp
801053f5:	89 e5                	mov    %esp,%ebp
801053f7:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
801053fa:	8d 55 f4             	lea    -0xc(%ebp),%edx
801053fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105400:	e8 4b fe ff ff       	call   80105250 <argfd.constprop.0>
80105405:	85 c0                	test   %eax,%eax
80105407:	78 27                	js     80105430 <sys_close+0x40>
  myproc()->ofile[fd] = 0;
80105409:	e8 92 ea ff ff       	call   80103ea0 <myproc>
8010540e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  fileclose(f);
80105411:	83 ec 0c             	sub    $0xc,%esp
  myproc()->ofile[fd] = 0;
80105414:	c7 44 90 2c 00 00 00 	movl   $0x0,0x2c(%eax,%edx,4)
8010541b:	00 
  fileclose(f);
8010541c:	ff 75 f4             	pushl  -0xc(%ebp)
8010541f:	e8 9c bb ff ff       	call   80100fc0 <fileclose>
  return 0;
80105424:	83 c4 10             	add    $0x10,%esp
80105427:	31 c0                	xor    %eax,%eax
}
80105429:	c9                   	leave  
8010542a:	c3                   	ret    
8010542b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010542f:	90                   	nop
80105430:	c9                   	leave  
    return -1;
80105431:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105436:	c3                   	ret    
80105437:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010543e:	66 90                	xchg   %ax,%ax

80105440 <sys_fstat>:
{
80105440:	f3 0f 1e fb          	endbr32 
80105444:	55                   	push   %ebp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105445:	31 c0                	xor    %eax,%eax
{
80105447:	89 e5                	mov    %esp,%ebp
80105449:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010544c:	8d 55 f0             	lea    -0x10(%ebp),%edx
8010544f:	e8 fc fd ff ff       	call   80105250 <argfd.constprop.0>
80105454:	85 c0                	test   %eax,%eax
80105456:	78 30                	js     80105488 <sys_fstat+0x48>
80105458:	83 ec 04             	sub    $0x4,%esp
8010545b:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010545e:	6a 14                	push   $0x14
80105460:	50                   	push   %eax
80105461:	6a 01                	push   $0x1
80105463:	e8 38 fb ff ff       	call   80104fa0 <argptr>
80105468:	83 c4 10             	add    $0x10,%esp
8010546b:	85 c0                	test   %eax,%eax
8010546d:	78 19                	js     80105488 <sys_fstat+0x48>
  return filestat(f, st);
8010546f:	83 ec 08             	sub    $0x8,%esp
80105472:	ff 75 f4             	pushl  -0xc(%ebp)
80105475:	ff 75 f0             	pushl  -0x10(%ebp)
80105478:	e8 23 bc ff ff       	call   801010a0 <filestat>
8010547d:	83 c4 10             	add    $0x10,%esp
}
80105480:	c9                   	leave  
80105481:	c3                   	ret    
80105482:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105488:	c9                   	leave  
    return -1;
80105489:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010548e:	c3                   	ret    
8010548f:	90                   	nop

80105490 <sys_link>:
{
80105490:	f3 0f 1e fb          	endbr32 
80105494:	55                   	push   %ebp
80105495:	89 e5                	mov    %esp,%ebp
80105497:	57                   	push   %edi
80105498:	56                   	push   %esi
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105499:	8d 45 d4             	lea    -0x2c(%ebp),%eax
{
8010549c:	53                   	push   %ebx
8010549d:	83 ec 34             	sub    $0x34,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801054a0:	50                   	push   %eax
801054a1:	6a 00                	push   $0x0
801054a3:	e8 58 fb ff ff       	call   80105000 <argstr>
801054a8:	83 c4 10             	add    $0x10,%esp
801054ab:	85 c0                	test   %eax,%eax
801054ad:	0f 88 ff 00 00 00    	js     801055b2 <sys_link+0x122>
801054b3:	83 ec 08             	sub    $0x8,%esp
801054b6:	8d 45 d0             	lea    -0x30(%ebp),%eax
801054b9:	50                   	push   %eax
801054ba:	6a 01                	push   $0x1
801054bc:	e8 3f fb ff ff       	call   80105000 <argstr>
801054c1:	83 c4 10             	add    $0x10,%esp
801054c4:	85 c0                	test   %eax,%eax
801054c6:	0f 88 e6 00 00 00    	js     801055b2 <sys_link+0x122>
  begin_op();
801054cc:	e8 6f da ff ff       	call   80102f40 <begin_op>
  if((ip = namei(old)) == 0){
801054d1:	83 ec 0c             	sub    $0xc,%esp
801054d4:	ff 75 d4             	pushl  -0x2c(%ebp)
801054d7:	e8 54 cc ff ff       	call   80102130 <namei>
801054dc:	83 c4 10             	add    $0x10,%esp
801054df:	89 c3                	mov    %eax,%ebx
801054e1:	85 c0                	test   %eax,%eax
801054e3:	0f 84 e8 00 00 00    	je     801055d1 <sys_link+0x141>
  ilock(ip);
801054e9:	83 ec 0c             	sub    $0xc,%esp
801054ec:	50                   	push   %eax
801054ed:	e8 6e c3 ff ff       	call   80101860 <ilock>
  if(ip->type == T_DIR){
801054f2:	83 c4 10             	add    $0x10,%esp
801054f5:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801054fa:	0f 84 b9 00 00 00    	je     801055b9 <sys_link+0x129>
  iupdate(ip);
80105500:	83 ec 0c             	sub    $0xc,%esp
  ip->nlink++;
80105503:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
  if((dp = nameiparent(new, name)) == 0)
80105508:	8d 7d da             	lea    -0x26(%ebp),%edi
  iupdate(ip);
8010550b:	53                   	push   %ebx
8010550c:	e8 8f c2 ff ff       	call   801017a0 <iupdate>
  iunlock(ip);
80105511:	89 1c 24             	mov    %ebx,(%esp)
80105514:	e8 27 c4 ff ff       	call   80101940 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80105519:	58                   	pop    %eax
8010551a:	5a                   	pop    %edx
8010551b:	57                   	push   %edi
8010551c:	ff 75 d0             	pushl  -0x30(%ebp)
8010551f:	e8 2c cc ff ff       	call   80102150 <nameiparent>
80105524:	83 c4 10             	add    $0x10,%esp
80105527:	89 c6                	mov    %eax,%esi
80105529:	85 c0                	test   %eax,%eax
8010552b:	74 5f                	je     8010558c <sys_link+0xfc>
  ilock(dp);
8010552d:	83 ec 0c             	sub    $0xc,%esp
80105530:	50                   	push   %eax
80105531:	e8 2a c3 ff ff       	call   80101860 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105536:	8b 03                	mov    (%ebx),%eax
80105538:	83 c4 10             	add    $0x10,%esp
8010553b:	39 06                	cmp    %eax,(%esi)
8010553d:	75 41                	jne    80105580 <sys_link+0xf0>
8010553f:	83 ec 04             	sub    $0x4,%esp
80105542:	ff 73 04             	pushl  0x4(%ebx)
80105545:	57                   	push   %edi
80105546:	56                   	push   %esi
80105547:	e8 24 cb ff ff       	call   80102070 <dirlink>
8010554c:	83 c4 10             	add    $0x10,%esp
8010554f:	85 c0                	test   %eax,%eax
80105551:	78 2d                	js     80105580 <sys_link+0xf0>
  iunlockput(dp);
80105553:	83 ec 0c             	sub    $0xc,%esp
80105556:	56                   	push   %esi
80105557:	e8 a4 c5 ff ff       	call   80101b00 <iunlockput>
  iput(ip);
8010555c:	89 1c 24             	mov    %ebx,(%esp)
8010555f:	e8 2c c4 ff ff       	call   80101990 <iput>
  end_op();
80105564:	e8 47 da ff ff       	call   80102fb0 <end_op>
  return 0;
80105569:	83 c4 10             	add    $0x10,%esp
8010556c:	31 c0                	xor    %eax,%eax
}
8010556e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105571:	5b                   	pop    %ebx
80105572:	5e                   	pop    %esi
80105573:	5f                   	pop    %edi
80105574:	5d                   	pop    %ebp
80105575:	c3                   	ret    
80105576:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010557d:	8d 76 00             	lea    0x0(%esi),%esi
    iunlockput(dp);
80105580:	83 ec 0c             	sub    $0xc,%esp
80105583:	56                   	push   %esi
80105584:	e8 77 c5 ff ff       	call   80101b00 <iunlockput>
    goto bad;
80105589:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
8010558c:	83 ec 0c             	sub    $0xc,%esp
8010558f:	53                   	push   %ebx
80105590:	e8 cb c2 ff ff       	call   80101860 <ilock>
  ip->nlink--;
80105595:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
8010559a:	89 1c 24             	mov    %ebx,(%esp)
8010559d:	e8 fe c1 ff ff       	call   801017a0 <iupdate>
  iunlockput(ip);
801055a2:	89 1c 24             	mov    %ebx,(%esp)
801055a5:	e8 56 c5 ff ff       	call   80101b00 <iunlockput>
  end_op();
801055aa:	e8 01 da ff ff       	call   80102fb0 <end_op>
  return -1;
801055af:	83 c4 10             	add    $0x10,%esp
801055b2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055b7:	eb b5                	jmp    8010556e <sys_link+0xde>
    iunlockput(ip);
801055b9:	83 ec 0c             	sub    $0xc,%esp
801055bc:	53                   	push   %ebx
801055bd:	e8 3e c5 ff ff       	call   80101b00 <iunlockput>
    end_op();
801055c2:	e8 e9 d9 ff ff       	call   80102fb0 <end_op>
    return -1;
801055c7:	83 c4 10             	add    $0x10,%esp
801055ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055cf:	eb 9d                	jmp    8010556e <sys_link+0xde>
    end_op();
801055d1:	e8 da d9 ff ff       	call   80102fb0 <end_op>
    return -1;
801055d6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055db:	eb 91                	jmp    8010556e <sys_link+0xde>
801055dd:	8d 76 00             	lea    0x0(%esi),%esi

801055e0 <sys_unlink>:
{
801055e0:	f3 0f 1e fb          	endbr32 
801055e4:	55                   	push   %ebp
801055e5:	89 e5                	mov    %esp,%ebp
801055e7:	57                   	push   %edi
801055e8:	56                   	push   %esi
  if(argstr(0, &path) < 0)
801055e9:	8d 45 c0             	lea    -0x40(%ebp),%eax
{
801055ec:	53                   	push   %ebx
801055ed:	83 ec 54             	sub    $0x54,%esp
  if(argstr(0, &path) < 0)
801055f0:	50                   	push   %eax
801055f1:	6a 00                	push   $0x0
801055f3:	e8 08 fa ff ff       	call   80105000 <argstr>
801055f8:	83 c4 10             	add    $0x10,%esp
801055fb:	85 c0                	test   %eax,%eax
801055fd:	0f 88 7d 01 00 00    	js     80105780 <sys_unlink+0x1a0>
  begin_op();
80105603:	e8 38 d9 ff ff       	call   80102f40 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105608:	8d 5d ca             	lea    -0x36(%ebp),%ebx
8010560b:	83 ec 08             	sub    $0x8,%esp
8010560e:	53                   	push   %ebx
8010560f:	ff 75 c0             	pushl  -0x40(%ebp)
80105612:	e8 39 cb ff ff       	call   80102150 <nameiparent>
80105617:	83 c4 10             	add    $0x10,%esp
8010561a:	89 c6                	mov    %eax,%esi
8010561c:	85 c0                	test   %eax,%eax
8010561e:	0f 84 66 01 00 00    	je     8010578a <sys_unlink+0x1aa>
  ilock(dp);
80105624:	83 ec 0c             	sub    $0xc,%esp
80105627:	50                   	push   %eax
80105628:	e8 33 c2 ff ff       	call   80101860 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010562d:	58                   	pop    %eax
8010562e:	5a                   	pop    %edx
8010562f:	68 1c 7f 10 80       	push   $0x80107f1c
80105634:	53                   	push   %ebx
80105635:	e8 56 c7 ff ff       	call   80101d90 <namecmp>
8010563a:	83 c4 10             	add    $0x10,%esp
8010563d:	85 c0                	test   %eax,%eax
8010563f:	0f 84 03 01 00 00    	je     80105748 <sys_unlink+0x168>
80105645:	83 ec 08             	sub    $0x8,%esp
80105648:	68 1b 7f 10 80       	push   $0x80107f1b
8010564d:	53                   	push   %ebx
8010564e:	e8 3d c7 ff ff       	call   80101d90 <namecmp>
80105653:	83 c4 10             	add    $0x10,%esp
80105656:	85 c0                	test   %eax,%eax
80105658:	0f 84 ea 00 00 00    	je     80105748 <sys_unlink+0x168>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010565e:	83 ec 04             	sub    $0x4,%esp
80105661:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105664:	50                   	push   %eax
80105665:	53                   	push   %ebx
80105666:	56                   	push   %esi
80105667:	e8 44 c7 ff ff       	call   80101db0 <dirlookup>
8010566c:	83 c4 10             	add    $0x10,%esp
8010566f:	89 c3                	mov    %eax,%ebx
80105671:	85 c0                	test   %eax,%eax
80105673:	0f 84 cf 00 00 00    	je     80105748 <sys_unlink+0x168>
  ilock(ip);
80105679:	83 ec 0c             	sub    $0xc,%esp
8010567c:	50                   	push   %eax
8010567d:	e8 de c1 ff ff       	call   80101860 <ilock>
  if(ip->nlink < 1)
80105682:	83 c4 10             	add    $0x10,%esp
80105685:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
8010568a:	0f 8e 23 01 00 00    	jle    801057b3 <sys_unlink+0x1d3>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105690:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105695:	8d 7d d8             	lea    -0x28(%ebp),%edi
80105698:	74 66                	je     80105700 <sys_unlink+0x120>
  memset(&de, 0, sizeof(de));
8010569a:	83 ec 04             	sub    $0x4,%esp
8010569d:	6a 10                	push   $0x10
8010569f:	6a 00                	push   $0x0
801056a1:	57                   	push   %edi
801056a2:	e8 c9 f5 ff ff       	call   80104c70 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801056a7:	6a 10                	push   $0x10
801056a9:	ff 75 c4             	pushl  -0x3c(%ebp)
801056ac:	57                   	push   %edi
801056ad:	56                   	push   %esi
801056ae:	e8 ad c5 ff ff       	call   80101c60 <writei>
801056b3:	83 c4 20             	add    $0x20,%esp
801056b6:	83 f8 10             	cmp    $0x10,%eax
801056b9:	0f 85 e7 00 00 00    	jne    801057a6 <sys_unlink+0x1c6>
  if(ip->type == T_DIR){
801056bf:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801056c4:	0f 84 96 00 00 00    	je     80105760 <sys_unlink+0x180>
  iunlockput(dp);
801056ca:	83 ec 0c             	sub    $0xc,%esp
801056cd:	56                   	push   %esi
801056ce:	e8 2d c4 ff ff       	call   80101b00 <iunlockput>
  ip->nlink--;
801056d3:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
801056d8:	89 1c 24             	mov    %ebx,(%esp)
801056db:	e8 c0 c0 ff ff       	call   801017a0 <iupdate>
  iunlockput(ip);
801056e0:	89 1c 24             	mov    %ebx,(%esp)
801056e3:	e8 18 c4 ff ff       	call   80101b00 <iunlockput>
  end_op();
801056e8:	e8 c3 d8 ff ff       	call   80102fb0 <end_op>
  return 0;
801056ed:	83 c4 10             	add    $0x10,%esp
801056f0:	31 c0                	xor    %eax,%eax
}
801056f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801056f5:	5b                   	pop    %ebx
801056f6:	5e                   	pop    %esi
801056f7:	5f                   	pop    %edi
801056f8:	5d                   	pop    %ebp
801056f9:	c3                   	ret    
801056fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105700:	83 7b 58 20          	cmpl   $0x20,0x58(%ebx)
80105704:	76 94                	jbe    8010569a <sys_unlink+0xba>
80105706:	ba 20 00 00 00       	mov    $0x20,%edx
8010570b:	eb 0b                	jmp    80105718 <sys_unlink+0x138>
8010570d:	8d 76 00             	lea    0x0(%esi),%esi
80105710:	83 c2 10             	add    $0x10,%edx
80105713:	39 53 58             	cmp    %edx,0x58(%ebx)
80105716:	76 82                	jbe    8010569a <sys_unlink+0xba>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105718:	6a 10                	push   $0x10
8010571a:	52                   	push   %edx
8010571b:	57                   	push   %edi
8010571c:	53                   	push   %ebx
8010571d:	89 55 b4             	mov    %edx,-0x4c(%ebp)
80105720:	e8 3b c4 ff ff       	call   80101b60 <readi>
80105725:	83 c4 10             	add    $0x10,%esp
80105728:	8b 55 b4             	mov    -0x4c(%ebp),%edx
8010572b:	83 f8 10             	cmp    $0x10,%eax
8010572e:	75 69                	jne    80105799 <sys_unlink+0x1b9>
    if(de.inum != 0)
80105730:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80105735:	74 d9                	je     80105710 <sys_unlink+0x130>
    iunlockput(ip);
80105737:	83 ec 0c             	sub    $0xc,%esp
8010573a:	53                   	push   %ebx
8010573b:	e8 c0 c3 ff ff       	call   80101b00 <iunlockput>
    goto bad;
80105740:	83 c4 10             	add    $0x10,%esp
80105743:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105747:	90                   	nop
  iunlockput(dp);
80105748:	83 ec 0c             	sub    $0xc,%esp
8010574b:	56                   	push   %esi
8010574c:	e8 af c3 ff ff       	call   80101b00 <iunlockput>
  end_op();
80105751:	e8 5a d8 ff ff       	call   80102fb0 <end_op>
  return -1;
80105756:	83 c4 10             	add    $0x10,%esp
80105759:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010575e:	eb 92                	jmp    801056f2 <sys_unlink+0x112>
    iupdate(dp);
80105760:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink--;
80105763:	66 83 6e 56 01       	subw   $0x1,0x56(%esi)
    iupdate(dp);
80105768:	56                   	push   %esi
80105769:	e8 32 c0 ff ff       	call   801017a0 <iupdate>
8010576e:	83 c4 10             	add    $0x10,%esp
80105771:	e9 54 ff ff ff       	jmp    801056ca <sys_unlink+0xea>
80105776:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010577d:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80105780:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105785:	e9 68 ff ff ff       	jmp    801056f2 <sys_unlink+0x112>
    end_op();
8010578a:	e8 21 d8 ff ff       	call   80102fb0 <end_op>
    return -1;
8010578f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105794:	e9 59 ff ff ff       	jmp    801056f2 <sys_unlink+0x112>
      panic("isdirempty: readi");
80105799:	83 ec 0c             	sub    $0xc,%esp
8010579c:	68 40 7f 10 80       	push   $0x80107f40
801057a1:	e8 ea ac ff ff       	call   80100490 <panic>
    panic("unlink: writei");
801057a6:	83 ec 0c             	sub    $0xc,%esp
801057a9:	68 52 7f 10 80       	push   $0x80107f52
801057ae:	e8 dd ac ff ff       	call   80100490 <panic>
    panic("unlink: nlink < 1");
801057b3:	83 ec 0c             	sub    $0xc,%esp
801057b6:	68 2e 7f 10 80       	push   $0x80107f2e
801057bb:	e8 d0 ac ff ff       	call   80100490 <panic>

801057c0 <sys_open>:

int
sys_open(void)
{
801057c0:	f3 0f 1e fb          	endbr32 
801057c4:	55                   	push   %ebp
801057c5:	89 e5                	mov    %esp,%ebp
801057c7:	57                   	push   %edi
801057c8:	56                   	push   %esi
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801057c9:	8d 45 e0             	lea    -0x20(%ebp),%eax
{
801057cc:	53                   	push   %ebx
801057cd:	83 ec 24             	sub    $0x24,%esp
  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801057d0:	50                   	push   %eax
801057d1:	6a 00                	push   $0x0
801057d3:	e8 28 f8 ff ff       	call   80105000 <argstr>
801057d8:	83 c4 10             	add    $0x10,%esp
801057db:	85 c0                	test   %eax,%eax
801057dd:	0f 88 8a 00 00 00    	js     8010586d <sys_open+0xad>
801057e3:	83 ec 08             	sub    $0x8,%esp
801057e6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801057e9:	50                   	push   %eax
801057ea:	6a 01                	push   $0x1
801057ec:	e8 5f f7 ff ff       	call   80104f50 <argint>
801057f1:	83 c4 10             	add    $0x10,%esp
801057f4:	85 c0                	test   %eax,%eax
801057f6:	78 75                	js     8010586d <sys_open+0xad>
    return -1;

  begin_op();
801057f8:	e8 43 d7 ff ff       	call   80102f40 <begin_op>

  if(omode & O_CREATE){
801057fd:	f6 45 e5 02          	testb  $0x2,-0x1b(%ebp)
80105801:	75 75                	jne    80105878 <sys_open+0xb8>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
80105803:	83 ec 0c             	sub    $0xc,%esp
80105806:	ff 75 e0             	pushl  -0x20(%ebp)
80105809:	e8 22 c9 ff ff       	call   80102130 <namei>
8010580e:	83 c4 10             	add    $0x10,%esp
80105811:	89 c6                	mov    %eax,%esi
80105813:	85 c0                	test   %eax,%eax
80105815:	74 7e                	je     80105895 <sys_open+0xd5>
      end_op();
      return -1;
    }
    ilock(ip);
80105817:	83 ec 0c             	sub    $0xc,%esp
8010581a:	50                   	push   %eax
8010581b:	e8 40 c0 ff ff       	call   80101860 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105820:	83 c4 10             	add    $0x10,%esp
80105823:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80105828:	0f 84 c2 00 00 00    	je     801058f0 <sys_open+0x130>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010582e:	e8 cd b6 ff ff       	call   80100f00 <filealloc>
80105833:	89 c7                	mov    %eax,%edi
80105835:	85 c0                	test   %eax,%eax
80105837:	74 23                	je     8010585c <sys_open+0x9c>
  struct proc *curproc = myproc();
80105839:	e8 62 e6 ff ff       	call   80103ea0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
8010583e:	31 db                	xor    %ebx,%ebx
    if(curproc->ofile[fd] == 0){
80105840:	8b 54 98 2c          	mov    0x2c(%eax,%ebx,4),%edx
80105844:	85 d2                	test   %edx,%edx
80105846:	74 60                	je     801058a8 <sys_open+0xe8>
  for(fd = 0; fd < NOFILE; fd++){
80105848:	83 c3 01             	add    $0x1,%ebx
8010584b:	83 fb 10             	cmp    $0x10,%ebx
8010584e:	75 f0                	jne    80105840 <sys_open+0x80>
    if(f)
      fileclose(f);
80105850:	83 ec 0c             	sub    $0xc,%esp
80105853:	57                   	push   %edi
80105854:	e8 67 b7 ff ff       	call   80100fc0 <fileclose>
80105859:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010585c:	83 ec 0c             	sub    $0xc,%esp
8010585f:	56                   	push   %esi
80105860:	e8 9b c2 ff ff       	call   80101b00 <iunlockput>
    end_op();
80105865:	e8 46 d7 ff ff       	call   80102fb0 <end_op>
    return -1;
8010586a:	83 c4 10             	add    $0x10,%esp
8010586d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105872:	eb 6d                	jmp    801058e1 <sys_open+0x121>
80105874:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    ip = create(path, T_FILE, 0, 0);
80105878:	83 ec 0c             	sub    $0xc,%esp
8010587b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010587e:	31 c9                	xor    %ecx,%ecx
80105880:	ba 02 00 00 00       	mov    $0x2,%edx
80105885:	6a 00                	push   $0x0
80105887:	e8 24 f8 ff ff       	call   801050b0 <create>
    if(ip == 0){
8010588c:	83 c4 10             	add    $0x10,%esp
    ip = create(path, T_FILE, 0, 0);
8010588f:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80105891:	85 c0                	test   %eax,%eax
80105893:	75 99                	jne    8010582e <sys_open+0x6e>
      end_op();
80105895:	e8 16 d7 ff ff       	call   80102fb0 <end_op>
      return -1;
8010589a:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010589f:	eb 40                	jmp    801058e1 <sys_open+0x121>
801058a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  }
  iunlock(ip);
801058a8:	83 ec 0c             	sub    $0xc,%esp
      curproc->ofile[fd] = f;
801058ab:	89 7c 98 2c          	mov    %edi,0x2c(%eax,%ebx,4)
  iunlock(ip);
801058af:	56                   	push   %esi
801058b0:	e8 8b c0 ff ff       	call   80101940 <iunlock>
  end_op();
801058b5:	e8 f6 d6 ff ff       	call   80102fb0 <end_op>

  f->type = FD_INODE;
801058ba:	c7 07 02 00 00 00    	movl   $0x2,(%edi)
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
801058c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801058c3:	83 c4 10             	add    $0x10,%esp
  f->ip = ip;
801058c6:	89 77 10             	mov    %esi,0x10(%edi)
  f->readable = !(omode & O_WRONLY);
801058c9:	89 d0                	mov    %edx,%eax
  f->off = 0;
801058cb:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)
  f->readable = !(omode & O_WRONLY);
801058d2:	f7 d0                	not    %eax
801058d4:	83 e0 01             	and    $0x1,%eax
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801058d7:	83 e2 03             	and    $0x3,%edx
  f->readable = !(omode & O_WRONLY);
801058da:	88 47 08             	mov    %al,0x8(%edi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801058dd:	0f 95 47 09          	setne  0x9(%edi)
  return fd;
}
801058e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801058e4:	89 d8                	mov    %ebx,%eax
801058e6:	5b                   	pop    %ebx
801058e7:	5e                   	pop    %esi
801058e8:	5f                   	pop    %edi
801058e9:	5d                   	pop    %ebp
801058ea:	c3                   	ret    
801058eb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801058ef:	90                   	nop
    if(ip->type == T_DIR && omode != O_RDONLY){
801058f0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801058f3:	85 c9                	test   %ecx,%ecx
801058f5:	0f 84 33 ff ff ff    	je     8010582e <sys_open+0x6e>
801058fb:	e9 5c ff ff ff       	jmp    8010585c <sys_open+0x9c>

80105900 <sys_mkdir>:

int
sys_mkdir(void)
{
80105900:	f3 0f 1e fb          	endbr32 
80105904:	55                   	push   %ebp
80105905:	89 e5                	mov    %esp,%ebp
80105907:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
8010590a:	e8 31 d6 ff ff       	call   80102f40 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010590f:	83 ec 08             	sub    $0x8,%esp
80105912:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105915:	50                   	push   %eax
80105916:	6a 00                	push   $0x0
80105918:	e8 e3 f6 ff ff       	call   80105000 <argstr>
8010591d:	83 c4 10             	add    $0x10,%esp
80105920:	85 c0                	test   %eax,%eax
80105922:	78 34                	js     80105958 <sys_mkdir+0x58>
80105924:	83 ec 0c             	sub    $0xc,%esp
80105927:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010592a:	31 c9                	xor    %ecx,%ecx
8010592c:	ba 01 00 00 00       	mov    $0x1,%edx
80105931:	6a 00                	push   $0x0
80105933:	e8 78 f7 ff ff       	call   801050b0 <create>
80105938:	83 c4 10             	add    $0x10,%esp
8010593b:	85 c0                	test   %eax,%eax
8010593d:	74 19                	je     80105958 <sys_mkdir+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010593f:	83 ec 0c             	sub    $0xc,%esp
80105942:	50                   	push   %eax
80105943:	e8 b8 c1 ff ff       	call   80101b00 <iunlockput>
  end_op();
80105948:	e8 63 d6 ff ff       	call   80102fb0 <end_op>
  return 0;
8010594d:	83 c4 10             	add    $0x10,%esp
80105950:	31 c0                	xor    %eax,%eax
}
80105952:	c9                   	leave  
80105953:	c3                   	ret    
80105954:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    end_op();
80105958:	e8 53 d6 ff ff       	call   80102fb0 <end_op>
    return -1;
8010595d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105962:	c9                   	leave  
80105963:	c3                   	ret    
80105964:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010596b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010596f:	90                   	nop

80105970 <sys_mknod>:

int
sys_mknod(void)
{
80105970:	f3 0f 1e fb          	endbr32 
80105974:	55                   	push   %ebp
80105975:	89 e5                	mov    %esp,%ebp
80105977:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
8010597a:	e8 c1 d5 ff ff       	call   80102f40 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010597f:	83 ec 08             	sub    $0x8,%esp
80105982:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105985:	50                   	push   %eax
80105986:	6a 00                	push   $0x0
80105988:	e8 73 f6 ff ff       	call   80105000 <argstr>
8010598d:	83 c4 10             	add    $0x10,%esp
80105990:	85 c0                	test   %eax,%eax
80105992:	78 64                	js     801059f8 <sys_mknod+0x88>
     argint(1, &major) < 0 ||
80105994:	83 ec 08             	sub    $0x8,%esp
80105997:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010599a:	50                   	push   %eax
8010599b:	6a 01                	push   $0x1
8010599d:	e8 ae f5 ff ff       	call   80104f50 <argint>
  if((argstr(0, &path)) < 0 ||
801059a2:	83 c4 10             	add    $0x10,%esp
801059a5:	85 c0                	test   %eax,%eax
801059a7:	78 4f                	js     801059f8 <sys_mknod+0x88>
     argint(2, &minor) < 0 ||
801059a9:	83 ec 08             	sub    $0x8,%esp
801059ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059af:	50                   	push   %eax
801059b0:	6a 02                	push   $0x2
801059b2:	e8 99 f5 ff ff       	call   80104f50 <argint>
     argint(1, &major) < 0 ||
801059b7:	83 c4 10             	add    $0x10,%esp
801059ba:	85 c0                	test   %eax,%eax
801059bc:	78 3a                	js     801059f8 <sys_mknod+0x88>
     (ip = create(path, T_DEV, major, minor)) == 0){
801059be:	0f bf 45 f4          	movswl -0xc(%ebp),%eax
801059c2:	83 ec 0c             	sub    $0xc,%esp
801059c5:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
801059c9:	ba 03 00 00 00       	mov    $0x3,%edx
801059ce:	50                   	push   %eax
801059cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801059d2:	e8 d9 f6 ff ff       	call   801050b0 <create>
     argint(2, &minor) < 0 ||
801059d7:	83 c4 10             	add    $0x10,%esp
801059da:	85 c0                	test   %eax,%eax
801059dc:	74 1a                	je     801059f8 <sys_mknod+0x88>
    end_op();
    return -1;
  }
  iunlockput(ip);
801059de:	83 ec 0c             	sub    $0xc,%esp
801059e1:	50                   	push   %eax
801059e2:	e8 19 c1 ff ff       	call   80101b00 <iunlockput>
  end_op();
801059e7:	e8 c4 d5 ff ff       	call   80102fb0 <end_op>
  return 0;
801059ec:	83 c4 10             	add    $0x10,%esp
801059ef:	31 c0                	xor    %eax,%eax
}
801059f1:	c9                   	leave  
801059f2:	c3                   	ret    
801059f3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801059f7:	90                   	nop
    end_op();
801059f8:	e8 b3 d5 ff ff       	call   80102fb0 <end_op>
    return -1;
801059fd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105a02:	c9                   	leave  
80105a03:	c3                   	ret    
80105a04:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105a0b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105a0f:	90                   	nop

80105a10 <sys_chdir>:

int
sys_chdir(void)
{
80105a10:	f3 0f 1e fb          	endbr32 
80105a14:	55                   	push   %ebp
80105a15:	89 e5                	mov    %esp,%ebp
80105a17:	56                   	push   %esi
80105a18:	53                   	push   %ebx
80105a19:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80105a1c:	e8 7f e4 ff ff       	call   80103ea0 <myproc>
80105a21:	89 c6                	mov    %eax,%esi
  
  begin_op();
80105a23:	e8 18 d5 ff ff       	call   80102f40 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105a28:	83 ec 08             	sub    $0x8,%esp
80105a2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a2e:	50                   	push   %eax
80105a2f:	6a 00                	push   $0x0
80105a31:	e8 ca f5 ff ff       	call   80105000 <argstr>
80105a36:	83 c4 10             	add    $0x10,%esp
80105a39:	85 c0                	test   %eax,%eax
80105a3b:	78 73                	js     80105ab0 <sys_chdir+0xa0>
80105a3d:	83 ec 0c             	sub    $0xc,%esp
80105a40:	ff 75 f4             	pushl  -0xc(%ebp)
80105a43:	e8 e8 c6 ff ff       	call   80102130 <namei>
80105a48:	83 c4 10             	add    $0x10,%esp
80105a4b:	89 c3                	mov    %eax,%ebx
80105a4d:	85 c0                	test   %eax,%eax
80105a4f:	74 5f                	je     80105ab0 <sys_chdir+0xa0>
    end_op();
    return -1;
  }
  ilock(ip);
80105a51:	83 ec 0c             	sub    $0xc,%esp
80105a54:	50                   	push   %eax
80105a55:	e8 06 be ff ff       	call   80101860 <ilock>
  if(ip->type != T_DIR){
80105a5a:	83 c4 10             	add    $0x10,%esp
80105a5d:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105a62:	75 2c                	jne    80105a90 <sys_chdir+0x80>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80105a64:	83 ec 0c             	sub    $0xc,%esp
80105a67:	53                   	push   %ebx
80105a68:	e8 d3 be ff ff       	call   80101940 <iunlock>
  iput(curproc->cwd);
80105a6d:	58                   	pop    %eax
80105a6e:	ff 76 6c             	pushl  0x6c(%esi)
80105a71:	e8 1a bf ff ff       	call   80101990 <iput>
  end_op();
80105a76:	e8 35 d5 ff ff       	call   80102fb0 <end_op>
  curproc->cwd = ip;
80105a7b:	89 5e 6c             	mov    %ebx,0x6c(%esi)
  return 0;
80105a7e:	83 c4 10             	add    $0x10,%esp
80105a81:	31 c0                	xor    %eax,%eax
}
80105a83:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105a86:	5b                   	pop    %ebx
80105a87:	5e                   	pop    %esi
80105a88:	5d                   	pop    %ebp
80105a89:	c3                   	ret    
80105a8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iunlockput(ip);
80105a90:	83 ec 0c             	sub    $0xc,%esp
80105a93:	53                   	push   %ebx
80105a94:	e8 67 c0 ff ff       	call   80101b00 <iunlockput>
    end_op();
80105a99:	e8 12 d5 ff ff       	call   80102fb0 <end_op>
    return -1;
80105a9e:	83 c4 10             	add    $0x10,%esp
80105aa1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aa6:	eb db                	jmp    80105a83 <sys_chdir+0x73>
80105aa8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105aaf:	90                   	nop
    end_op();
80105ab0:	e8 fb d4 ff ff       	call   80102fb0 <end_op>
    return -1;
80105ab5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105aba:	eb c7                	jmp    80105a83 <sys_chdir+0x73>
80105abc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105ac0 <sys_exec>:

int
sys_exec(void)
{
80105ac0:	f3 0f 1e fb          	endbr32 
80105ac4:	55                   	push   %ebp
80105ac5:	89 e5                	mov    %esp,%ebp
80105ac7:	57                   	push   %edi
80105ac8:	56                   	push   %esi
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105ac9:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
{
80105acf:	53                   	push   %ebx
80105ad0:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105ad6:	50                   	push   %eax
80105ad7:	6a 00                	push   $0x0
80105ad9:	e8 22 f5 ff ff       	call   80105000 <argstr>
80105ade:	83 c4 10             	add    $0x10,%esp
80105ae1:	85 c0                	test   %eax,%eax
80105ae3:	0f 88 8b 00 00 00    	js     80105b74 <sys_exec+0xb4>
80105ae9:	83 ec 08             	sub    $0x8,%esp
80105aec:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
80105af2:	50                   	push   %eax
80105af3:	6a 01                	push   $0x1
80105af5:	e8 56 f4 ff ff       	call   80104f50 <argint>
80105afa:	83 c4 10             	add    $0x10,%esp
80105afd:	85 c0                	test   %eax,%eax
80105aff:	78 73                	js     80105b74 <sys_exec+0xb4>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80105b01:	83 ec 04             	sub    $0x4,%esp
80105b04:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
  for(i=0;; i++){
80105b0a:	31 db                	xor    %ebx,%ebx
  memset(argv, 0, sizeof(argv));
80105b0c:	68 80 00 00 00       	push   $0x80
80105b11:	8d bd 64 ff ff ff    	lea    -0x9c(%ebp),%edi
80105b17:	6a 00                	push   $0x0
80105b19:	50                   	push   %eax
80105b1a:	e8 51 f1 ff ff       	call   80104c70 <memset>
80105b1f:	83 c4 10             	add    $0x10,%esp
80105b22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105b28:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80105b2e:	8d 34 9d 00 00 00 00 	lea    0x0(,%ebx,4),%esi
80105b35:	83 ec 08             	sub    $0x8,%esp
80105b38:	57                   	push   %edi
80105b39:	01 f0                	add    %esi,%eax
80105b3b:	50                   	push   %eax
80105b3c:	e8 6f f3 ff ff       	call   80104eb0 <fetchint>
80105b41:	83 c4 10             	add    $0x10,%esp
80105b44:	85 c0                	test   %eax,%eax
80105b46:	78 2c                	js     80105b74 <sys_exec+0xb4>
      return -1;
    if(uarg == 0){
80105b48:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80105b4e:	85 c0                	test   %eax,%eax
80105b50:	74 36                	je     80105b88 <sys_exec+0xc8>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80105b52:	8d 8d 68 ff ff ff    	lea    -0x98(%ebp),%ecx
80105b58:	83 ec 08             	sub    $0x8,%esp
80105b5b:	8d 14 31             	lea    (%ecx,%esi,1),%edx
80105b5e:	52                   	push   %edx
80105b5f:	50                   	push   %eax
80105b60:	e8 8b f3 ff ff       	call   80104ef0 <fetchstr>
80105b65:	83 c4 10             	add    $0x10,%esp
80105b68:	85 c0                	test   %eax,%eax
80105b6a:	78 08                	js     80105b74 <sys_exec+0xb4>
  for(i=0;; i++){
80105b6c:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80105b6f:	83 fb 20             	cmp    $0x20,%ebx
80105b72:	75 b4                	jne    80105b28 <sys_exec+0x68>
      return -1;
  }
  return exec(path, argv);
}
80105b74:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return -1;
80105b77:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b7c:	5b                   	pop    %ebx
80105b7d:	5e                   	pop    %esi
80105b7e:	5f                   	pop    %edi
80105b7f:	5d                   	pop    %ebp
80105b80:	c3                   	ret    
80105b81:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  return exec(path, argv);
80105b88:	83 ec 08             	sub    $0x8,%esp
80105b8b:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
      argv[i] = 0;
80105b91:	c7 84 9d 68 ff ff ff 	movl   $0x0,-0x98(%ebp,%ebx,4)
80105b98:	00 00 00 00 
  return exec(path, argv);
80105b9c:	50                   	push   %eax
80105b9d:	ff b5 5c ff ff ff    	pushl  -0xa4(%ebp)
80105ba3:	e8 d8 af ff ff       	call   80100b80 <exec>
80105ba8:	83 c4 10             	add    $0x10,%esp
}
80105bab:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105bae:	5b                   	pop    %ebx
80105baf:	5e                   	pop    %esi
80105bb0:	5f                   	pop    %edi
80105bb1:	5d                   	pop    %ebp
80105bb2:	c3                   	ret    
80105bb3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105bba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80105bc0 <sys_pipe>:

int
sys_pipe(void)
{
80105bc0:	f3 0f 1e fb          	endbr32 
80105bc4:	55                   	push   %ebp
80105bc5:	89 e5                	mov    %esp,%ebp
80105bc7:	57                   	push   %edi
80105bc8:	56                   	push   %esi
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105bc9:	8d 45 dc             	lea    -0x24(%ebp),%eax
{
80105bcc:	53                   	push   %ebx
80105bcd:	83 ec 20             	sub    $0x20,%esp
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105bd0:	6a 08                	push   $0x8
80105bd2:	50                   	push   %eax
80105bd3:	6a 00                	push   $0x0
80105bd5:	e8 c6 f3 ff ff       	call   80104fa0 <argptr>
80105bda:	83 c4 10             	add    $0x10,%esp
80105bdd:	85 c0                	test   %eax,%eax
80105bdf:	78 4e                	js     80105c2f <sys_pipe+0x6f>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80105be1:	83 ec 08             	sub    $0x8,%esp
80105be4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105be7:	50                   	push   %eax
80105be8:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105beb:	50                   	push   %eax
80105bec:	e8 2f dd ff ff       	call   80103920 <pipealloc>
80105bf1:	83 c4 10             	add    $0x10,%esp
80105bf4:	85 c0                	test   %eax,%eax
80105bf6:	78 37                	js     80105c2f <sys_pipe+0x6f>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105bf8:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(fd = 0; fd < NOFILE; fd++){
80105bfb:	31 db                	xor    %ebx,%ebx
  struct proc *curproc = myproc();
80105bfd:	e8 9e e2 ff ff       	call   80103ea0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
80105c02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(curproc->ofile[fd] == 0){
80105c08:	8b 74 98 2c          	mov    0x2c(%eax,%ebx,4),%esi
80105c0c:	85 f6                	test   %esi,%esi
80105c0e:	74 30                	je     80105c40 <sys_pipe+0x80>
  for(fd = 0; fd < NOFILE; fd++){
80105c10:	83 c3 01             	add    $0x1,%ebx
80105c13:	83 fb 10             	cmp    $0x10,%ebx
80105c16:	75 f0                	jne    80105c08 <sys_pipe+0x48>
    if(fd0 >= 0)
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
80105c18:	83 ec 0c             	sub    $0xc,%esp
80105c1b:	ff 75 e0             	pushl  -0x20(%ebp)
80105c1e:	e8 9d b3 ff ff       	call   80100fc0 <fileclose>
    fileclose(wf);
80105c23:	58                   	pop    %eax
80105c24:	ff 75 e4             	pushl  -0x1c(%ebp)
80105c27:	e8 94 b3 ff ff       	call   80100fc0 <fileclose>
    return -1;
80105c2c:	83 c4 10             	add    $0x10,%esp
80105c2f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105c34:	eb 5b                	jmp    80105c91 <sys_pipe+0xd1>
80105c36:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105c3d:	8d 76 00             	lea    0x0(%esi),%esi
      curproc->ofile[fd] = f;
80105c40:	8d 73 08             	lea    0x8(%ebx),%esi
80105c43:	89 7c b0 0c          	mov    %edi,0xc(%eax,%esi,4)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105c47:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  struct proc *curproc = myproc();
80105c4a:	e8 51 e2 ff ff       	call   80103ea0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
80105c4f:	31 d2                	xor    %edx,%edx
80105c51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(curproc->ofile[fd] == 0){
80105c58:	8b 4c 90 2c          	mov    0x2c(%eax,%edx,4),%ecx
80105c5c:	85 c9                	test   %ecx,%ecx
80105c5e:	74 20                	je     80105c80 <sys_pipe+0xc0>
  for(fd = 0; fd < NOFILE; fd++){
80105c60:	83 c2 01             	add    $0x1,%edx
80105c63:	83 fa 10             	cmp    $0x10,%edx
80105c66:	75 f0                	jne    80105c58 <sys_pipe+0x98>
      myproc()->ofile[fd0] = 0;
80105c68:	e8 33 e2 ff ff       	call   80103ea0 <myproc>
80105c6d:	c7 44 b0 0c 00 00 00 	movl   $0x0,0xc(%eax,%esi,4)
80105c74:	00 
80105c75:	eb a1                	jmp    80105c18 <sys_pipe+0x58>
80105c77:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105c7e:	66 90                	xchg   %ax,%ax
      curproc->ofile[fd] = f;
80105c80:	89 7c 90 2c          	mov    %edi,0x2c(%eax,%edx,4)
  }
  fd[0] = fd0;
80105c84:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105c87:	89 18                	mov    %ebx,(%eax)
  fd[1] = fd1;
80105c89:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105c8c:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
80105c8f:	31 c0                	xor    %eax,%eax
}
80105c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105c94:	5b                   	pop    %ebx
80105c95:	5e                   	pop    %esi
80105c96:	5f                   	pop    %edi
80105c97:	5d                   	pop    %ebp
80105c98:	c3                   	ret    
80105c99:	66 90                	xchg   %ax,%ax
80105c9b:	66 90                	xchg   %ax,%ax
80105c9d:	66 90                	xchg   %ax,%ax
80105c9f:	90                   	nop

80105ca0 <sys_getNumFreePages>:
#include "proc.h"


int
sys_getNumFreePages(void)
{
80105ca0:	f3 0f 1e fb          	endbr32 
  return num_of_FreePages();  
80105ca4:	e9 d7 cb ff ff       	jmp    80102880 <num_of_FreePages>
80105ca9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105cb0 <sys_getrss>:
}

int 
sys_getrss()
{
80105cb0:	f3 0f 1e fb          	endbr32 
80105cb4:	55                   	push   %ebp
80105cb5:	89 e5                	mov    %esp,%ebp
80105cb7:	83 ec 08             	sub    $0x8,%esp
  print_rss();
80105cba:	e8 b1 e4 ff ff       	call   80104170 <print_rss>
  return 0;
}
80105cbf:	31 c0                	xor    %eax,%eax
80105cc1:	c9                   	leave  
80105cc2:	c3                   	ret    
80105cc3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105cca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80105cd0 <sys_fork>:

int
sys_fork(void)
{
80105cd0:	f3 0f 1e fb          	endbr32 
  return fork();
80105cd4:	e9 77 e3 ff ff       	jmp    80104050 <fork>
80105cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105ce0 <sys_exit>:
}

int
sys_exit(void)
{
80105ce0:	f3 0f 1e fb          	endbr32 
80105ce4:	55                   	push   %ebp
80105ce5:	89 e5                	mov    %esp,%ebp
80105ce7:	83 ec 08             	sub    $0x8,%esp
  exit();
80105cea:	e8 51 e6 ff ff       	call   80104340 <exit>
  return 0;  // not reached
}
80105cef:	31 c0                	xor    %eax,%eax
80105cf1:	c9                   	leave  
80105cf2:	c3                   	ret    
80105cf3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105cfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80105d00 <sys_wait>:

int
sys_wait(void)
{
80105d00:	f3 0f 1e fb          	endbr32 
  return wait();
80105d04:	e9 87 e8 ff ff       	jmp    80104590 <wait>
80105d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105d10 <sys_kill>:
}

int
sys_kill(void)
{
80105d10:	f3 0f 1e fb          	endbr32 
80105d14:	55                   	push   %ebp
80105d15:	89 e5                	mov    %esp,%ebp
80105d17:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105d1a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105d1d:	50                   	push   %eax
80105d1e:	6a 00                	push   $0x0
80105d20:	e8 2b f2 ff ff       	call   80104f50 <argint>
80105d25:	83 c4 10             	add    $0x10,%esp
80105d28:	85 c0                	test   %eax,%eax
80105d2a:	78 14                	js     80105d40 <sys_kill+0x30>
    return -1;
  return kill(pid);
80105d2c:	83 ec 0c             	sub    $0xc,%esp
80105d2f:	ff 75 f4             	pushl  -0xc(%ebp)
80105d32:	e8 b9 e9 ff ff       	call   801046f0 <kill>
80105d37:	83 c4 10             	add    $0x10,%esp
}
80105d3a:	c9                   	leave  
80105d3b:	c3                   	ret    
80105d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105d40:	c9                   	leave  
    return -1;
80105d41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105d46:	c3                   	ret    
80105d47:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105d4e:	66 90                	xchg   %ax,%ax

80105d50 <sys_getpid>:

int
sys_getpid(void)
{
80105d50:	f3 0f 1e fb          	endbr32 
80105d54:	55                   	push   %ebp
80105d55:	89 e5                	mov    %esp,%ebp
80105d57:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105d5a:	e8 41 e1 ff ff       	call   80103ea0 <myproc>
80105d5f:	8b 40 14             	mov    0x14(%eax),%eax
}
80105d62:	c9                   	leave  
80105d63:	c3                   	ret    
80105d64:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105d6b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105d6f:	90                   	nop

80105d70 <sys_sbrk>:

int
sys_sbrk(void)
{
80105d70:	f3 0f 1e fb          	endbr32 
80105d74:	55                   	push   %ebp
80105d75:	89 e5                	mov    %esp,%ebp
80105d77:	53                   	push   %ebx
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105d78:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105d7b:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105d7e:	50                   	push   %eax
80105d7f:	6a 00                	push   $0x0
80105d81:	e8 ca f1 ff ff       	call   80104f50 <argint>
80105d86:	83 c4 10             	add    $0x10,%esp
80105d89:	85 c0                	test   %eax,%eax
80105d8b:	78 23                	js     80105db0 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80105d8d:	e8 0e e1 ff ff       	call   80103ea0 <myproc>
  if(growproc(n) < 0)
80105d92:	83 ec 0c             	sub    $0xc,%esp
  addr = myproc()->sz;
80105d95:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80105d97:	ff 75 f4             	pushl  -0xc(%ebp)
80105d9a:	e8 31 e2 ff ff       	call   80103fd0 <growproc>
80105d9f:	83 c4 10             	add    $0x10,%esp
80105da2:	85 c0                	test   %eax,%eax
80105da4:	78 0a                	js     80105db0 <sys_sbrk+0x40>
    return -1;
  return addr;
}
80105da6:	89 d8                	mov    %ebx,%eax
80105da8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105dab:	c9                   	leave  
80105dac:	c3                   	ret    
80105dad:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80105db0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105db5:	eb ef                	jmp    80105da6 <sys_sbrk+0x36>
80105db7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105dbe:	66 90                	xchg   %ax,%ax

80105dc0 <sys_sleep>:

int
sys_sleep(void)
{
80105dc0:	f3 0f 1e fb          	endbr32 
80105dc4:	55                   	push   %ebp
80105dc5:	89 e5                	mov    %esp,%ebp
80105dc7:	53                   	push   %ebx
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105dc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105dcb:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105dce:	50                   	push   %eax
80105dcf:	6a 00                	push   $0x0
80105dd1:	e8 7a f1 ff ff       	call   80104f50 <argint>
80105dd6:	83 c4 10             	add    $0x10,%esp
80105dd9:	85 c0                	test   %eax,%eax
80105ddb:	0f 88 86 00 00 00    	js     80105e67 <sys_sleep+0xa7>
    return -1;
  acquire(&tickslock);
80105de1:	83 ec 0c             	sub    $0xc,%esp
80105de4:	68 00 67 11 80       	push   $0x80116700
80105de9:	e8 72 ed ff ff       	call   80104b60 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80105dee:	8b 55 f4             	mov    -0xc(%ebp),%edx
  ticks0 = ticks;
80105df1:	8b 1d 40 6f 11 80    	mov    0x80116f40,%ebx
  while(ticks - ticks0 < n){
80105df7:	83 c4 10             	add    $0x10,%esp
80105dfa:	85 d2                	test   %edx,%edx
80105dfc:	75 23                	jne    80105e21 <sys_sleep+0x61>
80105dfe:	eb 50                	jmp    80105e50 <sys_sleep+0x90>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80105e00:	83 ec 08             	sub    $0x8,%esp
80105e03:	68 00 67 11 80       	push   $0x80116700
80105e08:	68 40 6f 11 80       	push   $0x80116f40
80105e0d:	e8 be e6 ff ff       	call   801044d0 <sleep>
  while(ticks - ticks0 < n){
80105e12:	a1 40 6f 11 80       	mov    0x80116f40,%eax
80105e17:	83 c4 10             	add    $0x10,%esp
80105e1a:	29 d8                	sub    %ebx,%eax
80105e1c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80105e1f:	73 2f                	jae    80105e50 <sys_sleep+0x90>
    if(myproc()->killed){
80105e21:	e8 7a e0 ff ff       	call   80103ea0 <myproc>
80105e26:	8b 40 28             	mov    0x28(%eax),%eax
80105e29:	85 c0                	test   %eax,%eax
80105e2b:	74 d3                	je     80105e00 <sys_sleep+0x40>
      release(&tickslock);
80105e2d:	83 ec 0c             	sub    $0xc,%esp
80105e30:	68 00 67 11 80       	push   $0x80116700
80105e35:	e8 e6 ed ff ff       	call   80104c20 <release>
  }
  release(&tickslock);
  return 0;
}
80105e3a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return -1;
80105e3d:	83 c4 10             	add    $0x10,%esp
80105e40:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e45:	c9                   	leave  
80105e46:	c3                   	ret    
80105e47:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105e4e:	66 90                	xchg   %ax,%ax
  release(&tickslock);
80105e50:	83 ec 0c             	sub    $0xc,%esp
80105e53:	68 00 67 11 80       	push   $0x80116700
80105e58:	e8 c3 ed ff ff       	call   80104c20 <release>
  return 0;
80105e5d:	83 c4 10             	add    $0x10,%esp
80105e60:	31 c0                	xor    %eax,%eax
}
80105e62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105e65:	c9                   	leave  
80105e66:	c3                   	ret    
    return -1;
80105e67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105e6c:	eb f4                	jmp    80105e62 <sys_sleep+0xa2>
80105e6e:	66 90                	xchg   %ax,%ax

80105e70 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105e70:	f3 0f 1e fb          	endbr32 
80105e74:	55                   	push   %ebp
80105e75:	89 e5                	mov    %esp,%ebp
80105e77:	53                   	push   %ebx
80105e78:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80105e7b:	68 00 67 11 80       	push   $0x80116700
80105e80:	e8 db ec ff ff       	call   80104b60 <acquire>
  xticks = ticks;
80105e85:	8b 1d 40 6f 11 80    	mov    0x80116f40,%ebx
  release(&tickslock);
80105e8b:	c7 04 24 00 67 11 80 	movl   $0x80116700,(%esp)
80105e92:	e8 89 ed ff ff       	call   80104c20 <release>
  return xticks;
}
80105e97:	89 d8                	mov    %ebx,%eax
80105e99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105e9c:	c9                   	leave  
80105e9d:	c3                   	ret    

80105e9e <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105e9e:	1e                   	push   %ds
  pushl %es
80105e9f:	06                   	push   %es
  pushl %fs
80105ea0:	0f a0                	push   %fs
  pushl %gs
80105ea2:	0f a8                	push   %gs
  pushal
80105ea4:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105ea5:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105ea9:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105eab:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105ead:	54                   	push   %esp
  call trap
80105eae:	e8 cd 00 00 00       	call   80105f80 <trap>
  addl $4, %esp
80105eb3:	83 c4 04             	add    $0x4,%esp

80105eb6 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105eb6:	61                   	popa   
  popl %gs
80105eb7:	0f a9                	pop    %gs
  popl %fs
80105eb9:	0f a1                	pop    %fs
  popl %es
80105ebb:	07                   	pop    %es
  popl %ds
80105ebc:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105ebd:	83 c4 08             	add    $0x8,%esp
  iret
80105ec0:	cf                   	iret   
80105ec1:	66 90                	xchg   %ax,%ax
80105ec3:	66 90                	xchg   %ax,%ax
80105ec5:	66 90                	xchg   %ax,%ax
80105ec7:	66 90                	xchg   %ax,%ax
80105ec9:	66 90                	xchg   %ax,%ax
80105ecb:	66 90                	xchg   %ax,%ax
80105ecd:	66 90                	xchg   %ax,%ax
80105ecf:	90                   	nop

80105ed0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80105ed0:	f3 0f 1e fb          	endbr32 
80105ed4:	55                   	push   %ebp
  int i;

  for(i = 0; i < 256; i++)
80105ed5:	31 c0                	xor    %eax,%eax
{
80105ed7:	89 e5                	mov    %esp,%ebp
80105ed9:	83 ec 08             	sub    $0x8,%esp
80105edc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105ee0:	8b 14 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%edx
80105ee7:	c7 04 c5 42 67 11 80 	movl   $0x8e000008,-0x7fee98be(,%eax,8)
80105eee:	08 00 00 8e 
80105ef2:	66 89 14 c5 40 67 11 	mov    %dx,-0x7fee98c0(,%eax,8)
80105ef9:	80 
80105efa:	c1 ea 10             	shr    $0x10,%edx
80105efd:	66 89 14 c5 46 67 11 	mov    %dx,-0x7fee98ba(,%eax,8)
80105f04:	80 
  for(i = 0; i < 256; i++)
80105f05:	83 c0 01             	add    $0x1,%eax
80105f08:	3d 00 01 00 00       	cmp    $0x100,%eax
80105f0d:	75 d1                	jne    80105ee0 <tvinit+0x10>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);

  initlock(&tickslock, "time");
80105f0f:	83 ec 08             	sub    $0x8,%esp
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105f12:	a1 08 b1 10 80       	mov    0x8010b108,%eax
80105f17:	c7 05 42 69 11 80 08 	movl   $0xef000008,0x80116942
80105f1e:	00 00 ef 
  initlock(&tickslock, "time");
80105f21:	68 61 7f 10 80       	push   $0x80107f61
80105f26:	68 00 67 11 80       	push   $0x80116700
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80105f2b:	66 a3 40 69 11 80    	mov    %ax,0x80116940
80105f31:	c1 e8 10             	shr    $0x10,%eax
80105f34:	66 a3 46 69 11 80    	mov    %ax,0x80116946
  initlock(&tickslock, "time");
80105f3a:	e8 a1 ea ff ff       	call   801049e0 <initlock>
}
80105f3f:	83 c4 10             	add    $0x10,%esp
80105f42:	c9                   	leave  
80105f43:	c3                   	ret    
80105f44:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105f4b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105f4f:	90                   	nop

80105f50 <idtinit>:

void
idtinit(void)
{
80105f50:	f3 0f 1e fb          	endbr32 
80105f54:	55                   	push   %ebp
  pd[0] = size-1;
80105f55:	b8 ff 07 00 00       	mov    $0x7ff,%eax
80105f5a:	89 e5                	mov    %esp,%ebp
80105f5c:	83 ec 10             	sub    $0x10,%esp
80105f5f:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80105f63:	b8 40 67 11 80       	mov    $0x80116740,%eax
80105f68:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80105f6c:	c1 e8 10             	shr    $0x10,%eax
80105f6f:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105f73:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105f76:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80105f79:	c9                   	leave  
80105f7a:	c3                   	ret    
80105f7b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105f7f:	90                   	nop

80105f80 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80105f80:	f3 0f 1e fb          	endbr32 
80105f84:	55                   	push   %ebp
80105f85:	89 e5                	mov    %esp,%ebp
80105f87:	57                   	push   %edi
80105f88:	56                   	push   %esi
80105f89:	53                   	push   %ebx
80105f8a:	83 ec 1c             	sub    $0x1c,%esp
80105f8d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80105f90:	8b 43 30             	mov    0x30(%ebx),%eax
80105f93:	83 f8 40             	cmp    $0x40,%eax
80105f96:	0f 84 cc 01 00 00    	je     80106168 <trap+0x1e8>
    if(myproc()->killed)
      exit();
    return;
  }

  if (tf->trapno == T_PGFLT) {
80105f9c:	83 f8 0e             	cmp    $0xe,%eax
80105f9f:	0f 84 fb 01 00 00    	je     801061a0 <trap+0x220>
    // Invoke page fault handler
    swappage();
    return;
  }

  switch(tf->trapno){
80105fa5:	83 e8 20             	sub    $0x20,%eax
80105fa8:	83 f8 1f             	cmp    $0x1f,%eax
80105fab:	77 08                	ja     80105fb5 <trap+0x35>
80105fad:	3e ff 24 85 08 80 10 	notrack jmp *-0x7fef7ff8(,%eax,4)
80105fb4:	80 
    lapiceoi();
    break;

  //PAGEBREAK: 13
  default:
    if(myproc() == 0 || (tf->cs&3) == 0){
80105fb5:	e8 e6 de ff ff       	call   80103ea0 <myproc>
80105fba:	8b 7b 38             	mov    0x38(%ebx),%edi
80105fbd:	85 c0                	test   %eax,%eax
80105fbf:	0f 84 02 02 00 00    	je     801061c7 <trap+0x247>
80105fc5:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105fc9:	0f 84 f8 01 00 00    	je     801061c7 <trap+0x247>
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105fcf:	0f 20 d1             	mov    %cr2,%ecx
80105fd2:	89 4d d8             	mov    %ecx,-0x28(%ebp)
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpuid(), tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105fd5:	e8 a6 de ff ff       	call   80103e80 <cpuid>
80105fda:	8b 73 30             	mov    0x30(%ebx),%esi
80105fdd:	89 45 dc             	mov    %eax,-0x24(%ebp)
80105fe0:	8b 43 34             	mov    0x34(%ebx),%eax
80105fe3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            "eip 0x%x addr 0x%x--kill proc\n",
            myproc()->pid, myproc()->name, tf->trapno,
80105fe6:	e8 b5 de ff ff       	call   80103ea0 <myproc>
80105feb:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105fee:	e8 ad de ff ff       	call   80103ea0 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105ff3:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80105ff6:	8b 55 dc             	mov    -0x24(%ebp),%edx
80105ff9:	51                   	push   %ecx
80105ffa:	57                   	push   %edi
80105ffb:	52                   	push   %edx
80105ffc:	ff 75 e4             	pushl  -0x1c(%ebp)
80105fff:	56                   	push   %esi
            myproc()->pid, myproc()->name, tf->trapno,
80106000:	8b 75 e0             	mov    -0x20(%ebp),%esi
80106003:	83 c6 70             	add    $0x70,%esi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106006:	56                   	push   %esi
80106007:	ff 70 14             	pushl  0x14(%eax)
8010600a:	68 c4 7f 10 80       	push   $0x80107fc4
8010600f:	e8 9c a7 ff ff       	call   801007b0 <cprintf>
            tf->err, cpuid(), tf->eip, rcr2());
    myproc()->killed = 1;
80106014:	83 c4 20             	add    $0x20,%esp
80106017:	e8 84 de ff ff       	call   80103ea0 <myproc>
8010601c:	c7 40 28 01 00 00 00 	movl   $0x1,0x28(%eax)
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106023:	e8 78 de ff ff       	call   80103ea0 <myproc>
80106028:	85 c0                	test   %eax,%eax
8010602a:	74 1d                	je     80106049 <trap+0xc9>
8010602c:	e8 6f de ff ff       	call   80103ea0 <myproc>
80106031:	8b 50 28             	mov    0x28(%eax),%edx
80106034:	85 d2                	test   %edx,%edx
80106036:	74 11                	je     80106049 <trap+0xc9>
80106038:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
8010603c:	83 e0 03             	and    $0x3,%eax
8010603f:	66 83 f8 03          	cmp    $0x3,%ax
80106043:	0f 84 67 01 00 00    	je     801061b0 <trap+0x230>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80106049:	e8 52 de ff ff       	call   80103ea0 <myproc>
8010604e:	85 c0                	test   %eax,%eax
80106050:	74 0f                	je     80106061 <trap+0xe1>
80106052:	e8 49 de ff ff       	call   80103ea0 <myproc>
80106057:	83 78 10 04          	cmpl   $0x4,0x10(%eax)
8010605b:	0f 84 ef 00 00 00    	je     80106150 <trap+0x1d0>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106061:	e8 3a de ff ff       	call   80103ea0 <myproc>
80106066:	85 c0                	test   %eax,%eax
80106068:	74 1d                	je     80106087 <trap+0x107>
8010606a:	e8 31 de ff ff       	call   80103ea0 <myproc>
8010606f:	8b 40 28             	mov    0x28(%eax),%eax
80106072:	85 c0                	test   %eax,%eax
80106074:	74 11                	je     80106087 <trap+0x107>
80106076:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
8010607a:	83 e0 03             	and    $0x3,%eax
8010607d:	66 83 f8 03          	cmp    $0x3,%ax
80106081:	0f 84 0a 01 00 00    	je     80106191 <trap+0x211>
    exit();
}
80106087:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010608a:	5b                   	pop    %ebx
8010608b:	5e                   	pop    %esi
8010608c:	5f                   	pop    %edi
8010608d:	5d                   	pop    %ebp
8010608e:	c3                   	ret    
    ideintr();
8010608f:	e8 4c c2 ff ff       	call   801022e0 <ideintr>
    lapiceoi();
80106094:	e8 37 ca ff ff       	call   80102ad0 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106099:	e8 02 de ff ff       	call   80103ea0 <myproc>
8010609e:	85 c0                	test   %eax,%eax
801060a0:	75 8a                	jne    8010602c <trap+0xac>
801060a2:	eb a5                	jmp    80106049 <trap+0xc9>
    if(cpuid() == 0){
801060a4:	e8 d7 dd ff ff       	call   80103e80 <cpuid>
801060a9:	85 c0                	test   %eax,%eax
801060ab:	75 e7                	jne    80106094 <trap+0x114>
      acquire(&tickslock);
801060ad:	83 ec 0c             	sub    $0xc,%esp
801060b0:	68 00 67 11 80       	push   $0x80116700
801060b5:	e8 a6 ea ff ff       	call   80104b60 <acquire>
      wakeup(&ticks);
801060ba:	c7 04 24 40 6f 11 80 	movl   $0x80116f40,(%esp)
      ticks++;
801060c1:	83 05 40 6f 11 80 01 	addl   $0x1,0x80116f40
      wakeup(&ticks);
801060c8:	e8 c3 e5 ff ff       	call   80104690 <wakeup>
      release(&tickslock);
801060cd:	c7 04 24 00 67 11 80 	movl   $0x80116700,(%esp)
801060d4:	e8 47 eb ff ff       	call   80104c20 <release>
801060d9:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801060dc:	eb b6                	jmp    80106094 <trap+0x114>
    kbdintr();
801060de:	e8 ad c8 ff ff       	call   80102990 <kbdintr>
    lapiceoi();
801060e3:	e8 e8 c9 ff ff       	call   80102ad0 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801060e8:	e8 b3 dd ff ff       	call   80103ea0 <myproc>
801060ed:	85 c0                	test   %eax,%eax
801060ef:	0f 85 37 ff ff ff    	jne    8010602c <trap+0xac>
801060f5:	e9 4f ff ff ff       	jmp    80106049 <trap+0xc9>
    uartintr();
801060fa:	e8 61 02 00 00       	call   80106360 <uartintr>
    lapiceoi();
801060ff:	e8 cc c9 ff ff       	call   80102ad0 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106104:	e8 97 dd ff ff       	call   80103ea0 <myproc>
80106109:	85 c0                	test   %eax,%eax
8010610b:	0f 85 1b ff ff ff    	jne    8010602c <trap+0xac>
80106111:	e9 33 ff ff ff       	jmp    80106049 <trap+0xc9>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106116:	8b 7b 38             	mov    0x38(%ebx),%edi
80106119:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
8010611d:	e8 5e dd ff ff       	call   80103e80 <cpuid>
80106122:	57                   	push   %edi
80106123:	56                   	push   %esi
80106124:	50                   	push   %eax
80106125:	68 6c 7f 10 80       	push   $0x80107f6c
8010612a:	e8 81 a6 ff ff       	call   801007b0 <cprintf>
    lapiceoi();
8010612f:	e8 9c c9 ff ff       	call   80102ad0 <lapiceoi>
    break;
80106134:	83 c4 10             	add    $0x10,%esp
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106137:	e8 64 dd ff ff       	call   80103ea0 <myproc>
8010613c:	85 c0                	test   %eax,%eax
8010613e:	0f 85 e8 fe ff ff    	jne    8010602c <trap+0xac>
80106144:	e9 00 ff ff ff       	jmp    80106049 <trap+0xc9>
80106149:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(myproc() && myproc()->state == RUNNING &&
80106150:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80106154:	0f 85 07 ff ff ff    	jne    80106061 <trap+0xe1>
    yield();
8010615a:	e8 21 e3 ff ff       	call   80104480 <yield>
8010615f:	e9 fd fe ff ff       	jmp    80106061 <trap+0xe1>
80106164:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(myproc()->killed)
80106168:	e8 33 dd ff ff       	call   80103ea0 <myproc>
8010616d:	8b 70 28             	mov    0x28(%eax),%esi
80106170:	85 f6                	test   %esi,%esi
80106172:	75 4c                	jne    801061c0 <trap+0x240>
    myproc()->tf = tf;
80106174:	e8 27 dd ff ff       	call   80103ea0 <myproc>
80106179:	89 58 1c             	mov    %ebx,0x1c(%eax)
    syscall();
8010617c:	e8 bf ee ff ff       	call   80105040 <syscall>
    if(myproc()->killed)
80106181:	e8 1a dd ff ff       	call   80103ea0 <myproc>
80106186:	8b 48 28             	mov    0x28(%eax),%ecx
80106189:	85 c9                	test   %ecx,%ecx
8010618b:	0f 84 f6 fe ff ff    	je     80106087 <trap+0x107>
}
80106191:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106194:	5b                   	pop    %ebx
80106195:	5e                   	pop    %esi
80106196:	5f                   	pop    %edi
80106197:	5d                   	pop    %ebp
      exit();
80106198:	e9 a3 e1 ff ff       	jmp    80104340 <exit>
8010619d:	8d 76 00             	lea    0x0(%esi),%esi
}
801061a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801061a3:	5b                   	pop    %ebx
801061a4:	5e                   	pop    %esi
801061a5:	5f                   	pop    %edi
801061a6:	5d                   	pop    %ebp
    swappage();
801061a7:	e9 e4 d5 ff ff       	jmp    80103790 <swappage>
801061ac:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    exit();
801061b0:	e8 8b e1 ff ff       	call   80104340 <exit>
801061b5:	e9 8f fe ff ff       	jmp    80106049 <trap+0xc9>
801061ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      exit();
801061c0:	e8 7b e1 ff ff       	call   80104340 <exit>
801061c5:	eb ad                	jmp    80106174 <trap+0x1f4>
801061c7:	0f 20 d6             	mov    %cr2,%esi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801061ca:	e8 b1 dc ff ff       	call   80103e80 <cpuid>
801061cf:	83 ec 0c             	sub    $0xc,%esp
801061d2:	56                   	push   %esi
801061d3:	57                   	push   %edi
801061d4:	50                   	push   %eax
801061d5:	ff 73 30             	pushl  0x30(%ebx)
801061d8:	68 90 7f 10 80       	push   $0x80107f90
801061dd:	e8 ce a5 ff ff       	call   801007b0 <cprintf>
      panic("trap");
801061e2:	83 c4 14             	add    $0x14,%esp
801061e5:	68 66 7f 10 80       	push   $0x80107f66
801061ea:	e8 a1 a2 ff ff       	call   80100490 <panic>
801061ef:	90                   	nop

801061f0 <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
801061f0:	f3 0f 1e fb          	endbr32 
  if(!uart)
801061f4:	a1 bc b5 10 80       	mov    0x8010b5bc,%eax
801061f9:	85 c0                	test   %eax,%eax
801061fb:	74 1b                	je     80106218 <uartgetc+0x28>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801061fd:	ba fd 03 00 00       	mov    $0x3fd,%edx
80106202:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80106203:	a8 01                	test   $0x1,%al
80106205:	74 11                	je     80106218 <uartgetc+0x28>
80106207:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010620c:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
8010620d:	0f b6 c0             	movzbl %al,%eax
80106210:	c3                   	ret    
80106211:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80106218:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010621d:	c3                   	ret    
8010621e:	66 90                	xchg   %ax,%ax

80106220 <uartputc.part.0>:
uartputc(int c)
80106220:	55                   	push   %ebp
80106221:	89 e5                	mov    %esp,%ebp
80106223:	57                   	push   %edi
80106224:	89 c7                	mov    %eax,%edi
80106226:	56                   	push   %esi
80106227:	be fd 03 00 00       	mov    $0x3fd,%esi
8010622c:	53                   	push   %ebx
8010622d:	bb 80 00 00 00       	mov    $0x80,%ebx
80106232:	83 ec 0c             	sub    $0xc,%esp
80106235:	eb 1b                	jmp    80106252 <uartputc.part.0+0x32>
80106237:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010623e:	66 90                	xchg   %ax,%ax
    microdelay(10);
80106240:	83 ec 0c             	sub    $0xc,%esp
80106243:	6a 0a                	push   $0xa
80106245:	e8 a6 c8 ff ff       	call   80102af0 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010624a:	83 c4 10             	add    $0x10,%esp
8010624d:	83 eb 01             	sub    $0x1,%ebx
80106250:	74 07                	je     80106259 <uartputc.part.0+0x39>
80106252:	89 f2                	mov    %esi,%edx
80106254:	ec                   	in     (%dx),%al
80106255:	a8 20                	test   $0x20,%al
80106257:	74 e7                	je     80106240 <uartputc.part.0+0x20>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106259:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010625e:	89 f8                	mov    %edi,%eax
80106260:	ee                   	out    %al,(%dx)
}
80106261:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106264:	5b                   	pop    %ebx
80106265:	5e                   	pop    %esi
80106266:	5f                   	pop    %edi
80106267:	5d                   	pop    %ebp
80106268:	c3                   	ret    
80106269:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106270 <uartinit>:
{
80106270:	f3 0f 1e fb          	endbr32 
80106274:	55                   	push   %ebp
80106275:	31 c9                	xor    %ecx,%ecx
80106277:	89 c8                	mov    %ecx,%eax
80106279:	89 e5                	mov    %esp,%ebp
8010627b:	57                   	push   %edi
8010627c:	56                   	push   %esi
8010627d:	53                   	push   %ebx
8010627e:	bb fa 03 00 00       	mov    $0x3fa,%ebx
80106283:	89 da                	mov    %ebx,%edx
80106285:	83 ec 0c             	sub    $0xc,%esp
80106288:	ee                   	out    %al,(%dx)
80106289:	bf fb 03 00 00       	mov    $0x3fb,%edi
8010628e:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80106293:	89 fa                	mov    %edi,%edx
80106295:	ee                   	out    %al,(%dx)
80106296:	b8 0c 00 00 00       	mov    $0xc,%eax
8010629b:	ba f8 03 00 00       	mov    $0x3f8,%edx
801062a0:	ee                   	out    %al,(%dx)
801062a1:	be f9 03 00 00       	mov    $0x3f9,%esi
801062a6:	89 c8                	mov    %ecx,%eax
801062a8:	89 f2                	mov    %esi,%edx
801062aa:	ee                   	out    %al,(%dx)
801062ab:	b8 03 00 00 00       	mov    $0x3,%eax
801062b0:	89 fa                	mov    %edi,%edx
801062b2:	ee                   	out    %al,(%dx)
801062b3:	ba fc 03 00 00       	mov    $0x3fc,%edx
801062b8:	89 c8                	mov    %ecx,%eax
801062ba:	ee                   	out    %al,(%dx)
801062bb:	b8 01 00 00 00       	mov    $0x1,%eax
801062c0:	89 f2                	mov    %esi,%edx
801062c2:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801062c3:	ba fd 03 00 00       	mov    $0x3fd,%edx
801062c8:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
801062c9:	3c ff                	cmp    $0xff,%al
801062cb:	74 52                	je     8010631f <uartinit+0xaf>
  uart = 1;
801062cd:	c7 05 bc b5 10 80 01 	movl   $0x1,0x8010b5bc
801062d4:	00 00 00 
801062d7:	89 da                	mov    %ebx,%edx
801062d9:	ec                   	in     (%dx),%al
801062da:	ba f8 03 00 00       	mov    $0x3f8,%edx
801062df:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
801062e0:	83 ec 08             	sub    $0x8,%esp
801062e3:	be 76 00 00 00       	mov    $0x76,%esi
  for(p="xv6...\n"; *p; p++)
801062e8:	bb 88 80 10 80       	mov    $0x80108088,%ebx
  ioapicenable(IRQ_COM1, 0);
801062ed:	6a 00                	push   $0x0
801062ef:	6a 04                	push   $0x4
801062f1:	e8 3a c2 ff ff       	call   80102530 <ioapicenable>
801062f6:	83 c4 10             	add    $0x10,%esp
  for(p="xv6...\n"; *p; p++)
801062f9:	b8 78 00 00 00       	mov    $0x78,%eax
801062fe:	eb 04                	jmp    80106304 <uartinit+0x94>
80106300:	0f b6 73 01          	movzbl 0x1(%ebx),%esi
  if(!uart)
80106304:	8b 15 bc b5 10 80    	mov    0x8010b5bc,%edx
8010630a:	85 d2                	test   %edx,%edx
8010630c:	74 08                	je     80106316 <uartinit+0xa6>
    uartputc(*p);
8010630e:	0f be c0             	movsbl %al,%eax
80106311:	e8 0a ff ff ff       	call   80106220 <uartputc.part.0>
  for(p="xv6...\n"; *p; p++)
80106316:	89 f0                	mov    %esi,%eax
80106318:	83 c3 01             	add    $0x1,%ebx
8010631b:	84 c0                	test   %al,%al
8010631d:	75 e1                	jne    80106300 <uartinit+0x90>
}
8010631f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106322:	5b                   	pop    %ebx
80106323:	5e                   	pop    %esi
80106324:	5f                   	pop    %edi
80106325:	5d                   	pop    %ebp
80106326:	c3                   	ret    
80106327:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010632e:	66 90                	xchg   %ax,%ax

80106330 <uartputc>:
{
80106330:	f3 0f 1e fb          	endbr32 
80106334:	55                   	push   %ebp
  if(!uart)
80106335:	8b 15 bc b5 10 80    	mov    0x8010b5bc,%edx
{
8010633b:	89 e5                	mov    %esp,%ebp
8010633d:	8b 45 08             	mov    0x8(%ebp),%eax
  if(!uart)
80106340:	85 d2                	test   %edx,%edx
80106342:	74 0c                	je     80106350 <uartputc+0x20>
}
80106344:	5d                   	pop    %ebp
80106345:	e9 d6 fe ff ff       	jmp    80106220 <uartputc.part.0>
8010634a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80106350:	5d                   	pop    %ebp
80106351:	c3                   	ret    
80106352:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106359:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106360 <uartintr>:

void
uartintr(void)
{
80106360:	f3 0f 1e fb          	endbr32 
80106364:	55                   	push   %ebp
80106365:	89 e5                	mov    %esp,%ebp
80106367:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
8010636a:	68 f0 61 10 80       	push   $0x801061f0
8010636f:	e8 ec a5 ff ff       	call   80100960 <consoleintr>
}
80106374:	83 c4 10             	add    $0x10,%esp
80106377:	c9                   	leave  
80106378:	c3                   	ret    

80106379 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106379:	6a 00                	push   $0x0
  pushl $0
8010637b:	6a 00                	push   $0x0
  jmp alltraps
8010637d:	e9 1c fb ff ff       	jmp    80105e9e <alltraps>

80106382 <vector1>:
.globl vector1
vector1:
  pushl $0
80106382:	6a 00                	push   $0x0
  pushl $1
80106384:	6a 01                	push   $0x1
  jmp alltraps
80106386:	e9 13 fb ff ff       	jmp    80105e9e <alltraps>

8010638b <vector2>:
.globl vector2
vector2:
  pushl $0
8010638b:	6a 00                	push   $0x0
  pushl $2
8010638d:	6a 02                	push   $0x2
  jmp alltraps
8010638f:	e9 0a fb ff ff       	jmp    80105e9e <alltraps>

80106394 <vector3>:
.globl vector3
vector3:
  pushl $0
80106394:	6a 00                	push   $0x0
  pushl $3
80106396:	6a 03                	push   $0x3
  jmp alltraps
80106398:	e9 01 fb ff ff       	jmp    80105e9e <alltraps>

8010639d <vector4>:
.globl vector4
vector4:
  pushl $0
8010639d:	6a 00                	push   $0x0
  pushl $4
8010639f:	6a 04                	push   $0x4
  jmp alltraps
801063a1:	e9 f8 fa ff ff       	jmp    80105e9e <alltraps>

801063a6 <vector5>:
.globl vector5
vector5:
  pushl $0
801063a6:	6a 00                	push   $0x0
  pushl $5
801063a8:	6a 05                	push   $0x5
  jmp alltraps
801063aa:	e9 ef fa ff ff       	jmp    80105e9e <alltraps>

801063af <vector6>:
.globl vector6
vector6:
  pushl $0
801063af:	6a 00                	push   $0x0
  pushl $6
801063b1:	6a 06                	push   $0x6
  jmp alltraps
801063b3:	e9 e6 fa ff ff       	jmp    80105e9e <alltraps>

801063b8 <vector7>:
.globl vector7
vector7:
  pushl $0
801063b8:	6a 00                	push   $0x0
  pushl $7
801063ba:	6a 07                	push   $0x7
  jmp alltraps
801063bc:	e9 dd fa ff ff       	jmp    80105e9e <alltraps>

801063c1 <vector8>:
.globl vector8
vector8:
  pushl $8
801063c1:	6a 08                	push   $0x8
  jmp alltraps
801063c3:	e9 d6 fa ff ff       	jmp    80105e9e <alltraps>

801063c8 <vector9>:
.globl vector9
vector9:
  pushl $0
801063c8:	6a 00                	push   $0x0
  pushl $9
801063ca:	6a 09                	push   $0x9
  jmp alltraps
801063cc:	e9 cd fa ff ff       	jmp    80105e9e <alltraps>

801063d1 <vector10>:
.globl vector10
vector10:
  pushl $10
801063d1:	6a 0a                	push   $0xa
  jmp alltraps
801063d3:	e9 c6 fa ff ff       	jmp    80105e9e <alltraps>

801063d8 <vector11>:
.globl vector11
vector11:
  pushl $11
801063d8:	6a 0b                	push   $0xb
  jmp alltraps
801063da:	e9 bf fa ff ff       	jmp    80105e9e <alltraps>

801063df <vector12>:
.globl vector12
vector12:
  pushl $12
801063df:	6a 0c                	push   $0xc
  jmp alltraps
801063e1:	e9 b8 fa ff ff       	jmp    80105e9e <alltraps>

801063e6 <vector13>:
.globl vector13
vector13:
  pushl $13
801063e6:	6a 0d                	push   $0xd
  jmp alltraps
801063e8:	e9 b1 fa ff ff       	jmp    80105e9e <alltraps>

801063ed <vector14>:
.globl vector14
vector14:
  pushl $14
801063ed:	6a 0e                	push   $0xe
  jmp alltraps
801063ef:	e9 aa fa ff ff       	jmp    80105e9e <alltraps>

801063f4 <vector15>:
.globl vector15
vector15:
  pushl $0
801063f4:	6a 00                	push   $0x0
  pushl $15
801063f6:	6a 0f                	push   $0xf
  jmp alltraps
801063f8:	e9 a1 fa ff ff       	jmp    80105e9e <alltraps>

801063fd <vector16>:
.globl vector16
vector16:
  pushl $0
801063fd:	6a 00                	push   $0x0
  pushl $16
801063ff:	6a 10                	push   $0x10
  jmp alltraps
80106401:	e9 98 fa ff ff       	jmp    80105e9e <alltraps>

80106406 <vector17>:
.globl vector17
vector17:
  pushl $17
80106406:	6a 11                	push   $0x11
  jmp alltraps
80106408:	e9 91 fa ff ff       	jmp    80105e9e <alltraps>

8010640d <vector18>:
.globl vector18
vector18:
  pushl $0
8010640d:	6a 00                	push   $0x0
  pushl $18
8010640f:	6a 12                	push   $0x12
  jmp alltraps
80106411:	e9 88 fa ff ff       	jmp    80105e9e <alltraps>

80106416 <vector19>:
.globl vector19
vector19:
  pushl $0
80106416:	6a 00                	push   $0x0
  pushl $19
80106418:	6a 13                	push   $0x13
  jmp alltraps
8010641a:	e9 7f fa ff ff       	jmp    80105e9e <alltraps>

8010641f <vector20>:
.globl vector20
vector20:
  pushl $0
8010641f:	6a 00                	push   $0x0
  pushl $20
80106421:	6a 14                	push   $0x14
  jmp alltraps
80106423:	e9 76 fa ff ff       	jmp    80105e9e <alltraps>

80106428 <vector21>:
.globl vector21
vector21:
  pushl $0
80106428:	6a 00                	push   $0x0
  pushl $21
8010642a:	6a 15                	push   $0x15
  jmp alltraps
8010642c:	e9 6d fa ff ff       	jmp    80105e9e <alltraps>

80106431 <vector22>:
.globl vector22
vector22:
  pushl $0
80106431:	6a 00                	push   $0x0
  pushl $22
80106433:	6a 16                	push   $0x16
  jmp alltraps
80106435:	e9 64 fa ff ff       	jmp    80105e9e <alltraps>

8010643a <vector23>:
.globl vector23
vector23:
  pushl $0
8010643a:	6a 00                	push   $0x0
  pushl $23
8010643c:	6a 17                	push   $0x17
  jmp alltraps
8010643e:	e9 5b fa ff ff       	jmp    80105e9e <alltraps>

80106443 <vector24>:
.globl vector24
vector24:
  pushl $0
80106443:	6a 00                	push   $0x0
  pushl $24
80106445:	6a 18                	push   $0x18
  jmp alltraps
80106447:	e9 52 fa ff ff       	jmp    80105e9e <alltraps>

8010644c <vector25>:
.globl vector25
vector25:
  pushl $0
8010644c:	6a 00                	push   $0x0
  pushl $25
8010644e:	6a 19                	push   $0x19
  jmp alltraps
80106450:	e9 49 fa ff ff       	jmp    80105e9e <alltraps>

80106455 <vector26>:
.globl vector26
vector26:
  pushl $0
80106455:	6a 00                	push   $0x0
  pushl $26
80106457:	6a 1a                	push   $0x1a
  jmp alltraps
80106459:	e9 40 fa ff ff       	jmp    80105e9e <alltraps>

8010645e <vector27>:
.globl vector27
vector27:
  pushl $0
8010645e:	6a 00                	push   $0x0
  pushl $27
80106460:	6a 1b                	push   $0x1b
  jmp alltraps
80106462:	e9 37 fa ff ff       	jmp    80105e9e <alltraps>

80106467 <vector28>:
.globl vector28
vector28:
  pushl $0
80106467:	6a 00                	push   $0x0
  pushl $28
80106469:	6a 1c                	push   $0x1c
  jmp alltraps
8010646b:	e9 2e fa ff ff       	jmp    80105e9e <alltraps>

80106470 <vector29>:
.globl vector29
vector29:
  pushl $0
80106470:	6a 00                	push   $0x0
  pushl $29
80106472:	6a 1d                	push   $0x1d
  jmp alltraps
80106474:	e9 25 fa ff ff       	jmp    80105e9e <alltraps>

80106479 <vector30>:
.globl vector30
vector30:
  pushl $0
80106479:	6a 00                	push   $0x0
  pushl $30
8010647b:	6a 1e                	push   $0x1e
  jmp alltraps
8010647d:	e9 1c fa ff ff       	jmp    80105e9e <alltraps>

80106482 <vector31>:
.globl vector31
vector31:
  pushl $0
80106482:	6a 00                	push   $0x0
  pushl $31
80106484:	6a 1f                	push   $0x1f
  jmp alltraps
80106486:	e9 13 fa ff ff       	jmp    80105e9e <alltraps>

8010648b <vector32>:
.globl vector32
vector32:
  pushl $0
8010648b:	6a 00                	push   $0x0
  pushl $32
8010648d:	6a 20                	push   $0x20
  jmp alltraps
8010648f:	e9 0a fa ff ff       	jmp    80105e9e <alltraps>

80106494 <vector33>:
.globl vector33
vector33:
  pushl $0
80106494:	6a 00                	push   $0x0
  pushl $33
80106496:	6a 21                	push   $0x21
  jmp alltraps
80106498:	e9 01 fa ff ff       	jmp    80105e9e <alltraps>

8010649d <vector34>:
.globl vector34
vector34:
  pushl $0
8010649d:	6a 00                	push   $0x0
  pushl $34
8010649f:	6a 22                	push   $0x22
  jmp alltraps
801064a1:	e9 f8 f9 ff ff       	jmp    80105e9e <alltraps>

801064a6 <vector35>:
.globl vector35
vector35:
  pushl $0
801064a6:	6a 00                	push   $0x0
  pushl $35
801064a8:	6a 23                	push   $0x23
  jmp alltraps
801064aa:	e9 ef f9 ff ff       	jmp    80105e9e <alltraps>

801064af <vector36>:
.globl vector36
vector36:
  pushl $0
801064af:	6a 00                	push   $0x0
  pushl $36
801064b1:	6a 24                	push   $0x24
  jmp alltraps
801064b3:	e9 e6 f9 ff ff       	jmp    80105e9e <alltraps>

801064b8 <vector37>:
.globl vector37
vector37:
  pushl $0
801064b8:	6a 00                	push   $0x0
  pushl $37
801064ba:	6a 25                	push   $0x25
  jmp alltraps
801064bc:	e9 dd f9 ff ff       	jmp    80105e9e <alltraps>

801064c1 <vector38>:
.globl vector38
vector38:
  pushl $0
801064c1:	6a 00                	push   $0x0
  pushl $38
801064c3:	6a 26                	push   $0x26
  jmp alltraps
801064c5:	e9 d4 f9 ff ff       	jmp    80105e9e <alltraps>

801064ca <vector39>:
.globl vector39
vector39:
  pushl $0
801064ca:	6a 00                	push   $0x0
  pushl $39
801064cc:	6a 27                	push   $0x27
  jmp alltraps
801064ce:	e9 cb f9 ff ff       	jmp    80105e9e <alltraps>

801064d3 <vector40>:
.globl vector40
vector40:
  pushl $0
801064d3:	6a 00                	push   $0x0
  pushl $40
801064d5:	6a 28                	push   $0x28
  jmp alltraps
801064d7:	e9 c2 f9 ff ff       	jmp    80105e9e <alltraps>

801064dc <vector41>:
.globl vector41
vector41:
  pushl $0
801064dc:	6a 00                	push   $0x0
  pushl $41
801064de:	6a 29                	push   $0x29
  jmp alltraps
801064e0:	e9 b9 f9 ff ff       	jmp    80105e9e <alltraps>

801064e5 <vector42>:
.globl vector42
vector42:
  pushl $0
801064e5:	6a 00                	push   $0x0
  pushl $42
801064e7:	6a 2a                	push   $0x2a
  jmp alltraps
801064e9:	e9 b0 f9 ff ff       	jmp    80105e9e <alltraps>

801064ee <vector43>:
.globl vector43
vector43:
  pushl $0
801064ee:	6a 00                	push   $0x0
  pushl $43
801064f0:	6a 2b                	push   $0x2b
  jmp alltraps
801064f2:	e9 a7 f9 ff ff       	jmp    80105e9e <alltraps>

801064f7 <vector44>:
.globl vector44
vector44:
  pushl $0
801064f7:	6a 00                	push   $0x0
  pushl $44
801064f9:	6a 2c                	push   $0x2c
  jmp alltraps
801064fb:	e9 9e f9 ff ff       	jmp    80105e9e <alltraps>

80106500 <vector45>:
.globl vector45
vector45:
  pushl $0
80106500:	6a 00                	push   $0x0
  pushl $45
80106502:	6a 2d                	push   $0x2d
  jmp alltraps
80106504:	e9 95 f9 ff ff       	jmp    80105e9e <alltraps>

80106509 <vector46>:
.globl vector46
vector46:
  pushl $0
80106509:	6a 00                	push   $0x0
  pushl $46
8010650b:	6a 2e                	push   $0x2e
  jmp alltraps
8010650d:	e9 8c f9 ff ff       	jmp    80105e9e <alltraps>

80106512 <vector47>:
.globl vector47
vector47:
  pushl $0
80106512:	6a 00                	push   $0x0
  pushl $47
80106514:	6a 2f                	push   $0x2f
  jmp alltraps
80106516:	e9 83 f9 ff ff       	jmp    80105e9e <alltraps>

8010651b <vector48>:
.globl vector48
vector48:
  pushl $0
8010651b:	6a 00                	push   $0x0
  pushl $48
8010651d:	6a 30                	push   $0x30
  jmp alltraps
8010651f:	e9 7a f9 ff ff       	jmp    80105e9e <alltraps>

80106524 <vector49>:
.globl vector49
vector49:
  pushl $0
80106524:	6a 00                	push   $0x0
  pushl $49
80106526:	6a 31                	push   $0x31
  jmp alltraps
80106528:	e9 71 f9 ff ff       	jmp    80105e9e <alltraps>

8010652d <vector50>:
.globl vector50
vector50:
  pushl $0
8010652d:	6a 00                	push   $0x0
  pushl $50
8010652f:	6a 32                	push   $0x32
  jmp alltraps
80106531:	e9 68 f9 ff ff       	jmp    80105e9e <alltraps>

80106536 <vector51>:
.globl vector51
vector51:
  pushl $0
80106536:	6a 00                	push   $0x0
  pushl $51
80106538:	6a 33                	push   $0x33
  jmp alltraps
8010653a:	e9 5f f9 ff ff       	jmp    80105e9e <alltraps>

8010653f <vector52>:
.globl vector52
vector52:
  pushl $0
8010653f:	6a 00                	push   $0x0
  pushl $52
80106541:	6a 34                	push   $0x34
  jmp alltraps
80106543:	e9 56 f9 ff ff       	jmp    80105e9e <alltraps>

80106548 <vector53>:
.globl vector53
vector53:
  pushl $0
80106548:	6a 00                	push   $0x0
  pushl $53
8010654a:	6a 35                	push   $0x35
  jmp alltraps
8010654c:	e9 4d f9 ff ff       	jmp    80105e9e <alltraps>

80106551 <vector54>:
.globl vector54
vector54:
  pushl $0
80106551:	6a 00                	push   $0x0
  pushl $54
80106553:	6a 36                	push   $0x36
  jmp alltraps
80106555:	e9 44 f9 ff ff       	jmp    80105e9e <alltraps>

8010655a <vector55>:
.globl vector55
vector55:
  pushl $0
8010655a:	6a 00                	push   $0x0
  pushl $55
8010655c:	6a 37                	push   $0x37
  jmp alltraps
8010655e:	e9 3b f9 ff ff       	jmp    80105e9e <alltraps>

80106563 <vector56>:
.globl vector56
vector56:
  pushl $0
80106563:	6a 00                	push   $0x0
  pushl $56
80106565:	6a 38                	push   $0x38
  jmp alltraps
80106567:	e9 32 f9 ff ff       	jmp    80105e9e <alltraps>

8010656c <vector57>:
.globl vector57
vector57:
  pushl $0
8010656c:	6a 00                	push   $0x0
  pushl $57
8010656e:	6a 39                	push   $0x39
  jmp alltraps
80106570:	e9 29 f9 ff ff       	jmp    80105e9e <alltraps>

80106575 <vector58>:
.globl vector58
vector58:
  pushl $0
80106575:	6a 00                	push   $0x0
  pushl $58
80106577:	6a 3a                	push   $0x3a
  jmp alltraps
80106579:	e9 20 f9 ff ff       	jmp    80105e9e <alltraps>

8010657e <vector59>:
.globl vector59
vector59:
  pushl $0
8010657e:	6a 00                	push   $0x0
  pushl $59
80106580:	6a 3b                	push   $0x3b
  jmp alltraps
80106582:	e9 17 f9 ff ff       	jmp    80105e9e <alltraps>

80106587 <vector60>:
.globl vector60
vector60:
  pushl $0
80106587:	6a 00                	push   $0x0
  pushl $60
80106589:	6a 3c                	push   $0x3c
  jmp alltraps
8010658b:	e9 0e f9 ff ff       	jmp    80105e9e <alltraps>

80106590 <vector61>:
.globl vector61
vector61:
  pushl $0
80106590:	6a 00                	push   $0x0
  pushl $61
80106592:	6a 3d                	push   $0x3d
  jmp alltraps
80106594:	e9 05 f9 ff ff       	jmp    80105e9e <alltraps>

80106599 <vector62>:
.globl vector62
vector62:
  pushl $0
80106599:	6a 00                	push   $0x0
  pushl $62
8010659b:	6a 3e                	push   $0x3e
  jmp alltraps
8010659d:	e9 fc f8 ff ff       	jmp    80105e9e <alltraps>

801065a2 <vector63>:
.globl vector63
vector63:
  pushl $0
801065a2:	6a 00                	push   $0x0
  pushl $63
801065a4:	6a 3f                	push   $0x3f
  jmp alltraps
801065a6:	e9 f3 f8 ff ff       	jmp    80105e9e <alltraps>

801065ab <vector64>:
.globl vector64
vector64:
  pushl $0
801065ab:	6a 00                	push   $0x0
  pushl $64
801065ad:	6a 40                	push   $0x40
  jmp alltraps
801065af:	e9 ea f8 ff ff       	jmp    80105e9e <alltraps>

801065b4 <vector65>:
.globl vector65
vector65:
  pushl $0
801065b4:	6a 00                	push   $0x0
  pushl $65
801065b6:	6a 41                	push   $0x41
  jmp alltraps
801065b8:	e9 e1 f8 ff ff       	jmp    80105e9e <alltraps>

801065bd <vector66>:
.globl vector66
vector66:
  pushl $0
801065bd:	6a 00                	push   $0x0
  pushl $66
801065bf:	6a 42                	push   $0x42
  jmp alltraps
801065c1:	e9 d8 f8 ff ff       	jmp    80105e9e <alltraps>

801065c6 <vector67>:
.globl vector67
vector67:
  pushl $0
801065c6:	6a 00                	push   $0x0
  pushl $67
801065c8:	6a 43                	push   $0x43
  jmp alltraps
801065ca:	e9 cf f8 ff ff       	jmp    80105e9e <alltraps>

801065cf <vector68>:
.globl vector68
vector68:
  pushl $0
801065cf:	6a 00                	push   $0x0
  pushl $68
801065d1:	6a 44                	push   $0x44
  jmp alltraps
801065d3:	e9 c6 f8 ff ff       	jmp    80105e9e <alltraps>

801065d8 <vector69>:
.globl vector69
vector69:
  pushl $0
801065d8:	6a 00                	push   $0x0
  pushl $69
801065da:	6a 45                	push   $0x45
  jmp alltraps
801065dc:	e9 bd f8 ff ff       	jmp    80105e9e <alltraps>

801065e1 <vector70>:
.globl vector70
vector70:
  pushl $0
801065e1:	6a 00                	push   $0x0
  pushl $70
801065e3:	6a 46                	push   $0x46
  jmp alltraps
801065e5:	e9 b4 f8 ff ff       	jmp    80105e9e <alltraps>

801065ea <vector71>:
.globl vector71
vector71:
  pushl $0
801065ea:	6a 00                	push   $0x0
  pushl $71
801065ec:	6a 47                	push   $0x47
  jmp alltraps
801065ee:	e9 ab f8 ff ff       	jmp    80105e9e <alltraps>

801065f3 <vector72>:
.globl vector72
vector72:
  pushl $0
801065f3:	6a 00                	push   $0x0
  pushl $72
801065f5:	6a 48                	push   $0x48
  jmp alltraps
801065f7:	e9 a2 f8 ff ff       	jmp    80105e9e <alltraps>

801065fc <vector73>:
.globl vector73
vector73:
  pushl $0
801065fc:	6a 00                	push   $0x0
  pushl $73
801065fe:	6a 49                	push   $0x49
  jmp alltraps
80106600:	e9 99 f8 ff ff       	jmp    80105e9e <alltraps>

80106605 <vector74>:
.globl vector74
vector74:
  pushl $0
80106605:	6a 00                	push   $0x0
  pushl $74
80106607:	6a 4a                	push   $0x4a
  jmp alltraps
80106609:	e9 90 f8 ff ff       	jmp    80105e9e <alltraps>

8010660e <vector75>:
.globl vector75
vector75:
  pushl $0
8010660e:	6a 00                	push   $0x0
  pushl $75
80106610:	6a 4b                	push   $0x4b
  jmp alltraps
80106612:	e9 87 f8 ff ff       	jmp    80105e9e <alltraps>

80106617 <vector76>:
.globl vector76
vector76:
  pushl $0
80106617:	6a 00                	push   $0x0
  pushl $76
80106619:	6a 4c                	push   $0x4c
  jmp alltraps
8010661b:	e9 7e f8 ff ff       	jmp    80105e9e <alltraps>

80106620 <vector77>:
.globl vector77
vector77:
  pushl $0
80106620:	6a 00                	push   $0x0
  pushl $77
80106622:	6a 4d                	push   $0x4d
  jmp alltraps
80106624:	e9 75 f8 ff ff       	jmp    80105e9e <alltraps>

80106629 <vector78>:
.globl vector78
vector78:
  pushl $0
80106629:	6a 00                	push   $0x0
  pushl $78
8010662b:	6a 4e                	push   $0x4e
  jmp alltraps
8010662d:	e9 6c f8 ff ff       	jmp    80105e9e <alltraps>

80106632 <vector79>:
.globl vector79
vector79:
  pushl $0
80106632:	6a 00                	push   $0x0
  pushl $79
80106634:	6a 4f                	push   $0x4f
  jmp alltraps
80106636:	e9 63 f8 ff ff       	jmp    80105e9e <alltraps>

8010663b <vector80>:
.globl vector80
vector80:
  pushl $0
8010663b:	6a 00                	push   $0x0
  pushl $80
8010663d:	6a 50                	push   $0x50
  jmp alltraps
8010663f:	e9 5a f8 ff ff       	jmp    80105e9e <alltraps>

80106644 <vector81>:
.globl vector81
vector81:
  pushl $0
80106644:	6a 00                	push   $0x0
  pushl $81
80106646:	6a 51                	push   $0x51
  jmp alltraps
80106648:	e9 51 f8 ff ff       	jmp    80105e9e <alltraps>

8010664d <vector82>:
.globl vector82
vector82:
  pushl $0
8010664d:	6a 00                	push   $0x0
  pushl $82
8010664f:	6a 52                	push   $0x52
  jmp alltraps
80106651:	e9 48 f8 ff ff       	jmp    80105e9e <alltraps>

80106656 <vector83>:
.globl vector83
vector83:
  pushl $0
80106656:	6a 00                	push   $0x0
  pushl $83
80106658:	6a 53                	push   $0x53
  jmp alltraps
8010665a:	e9 3f f8 ff ff       	jmp    80105e9e <alltraps>

8010665f <vector84>:
.globl vector84
vector84:
  pushl $0
8010665f:	6a 00                	push   $0x0
  pushl $84
80106661:	6a 54                	push   $0x54
  jmp alltraps
80106663:	e9 36 f8 ff ff       	jmp    80105e9e <alltraps>

80106668 <vector85>:
.globl vector85
vector85:
  pushl $0
80106668:	6a 00                	push   $0x0
  pushl $85
8010666a:	6a 55                	push   $0x55
  jmp alltraps
8010666c:	e9 2d f8 ff ff       	jmp    80105e9e <alltraps>

80106671 <vector86>:
.globl vector86
vector86:
  pushl $0
80106671:	6a 00                	push   $0x0
  pushl $86
80106673:	6a 56                	push   $0x56
  jmp alltraps
80106675:	e9 24 f8 ff ff       	jmp    80105e9e <alltraps>

8010667a <vector87>:
.globl vector87
vector87:
  pushl $0
8010667a:	6a 00                	push   $0x0
  pushl $87
8010667c:	6a 57                	push   $0x57
  jmp alltraps
8010667e:	e9 1b f8 ff ff       	jmp    80105e9e <alltraps>

80106683 <vector88>:
.globl vector88
vector88:
  pushl $0
80106683:	6a 00                	push   $0x0
  pushl $88
80106685:	6a 58                	push   $0x58
  jmp alltraps
80106687:	e9 12 f8 ff ff       	jmp    80105e9e <alltraps>

8010668c <vector89>:
.globl vector89
vector89:
  pushl $0
8010668c:	6a 00                	push   $0x0
  pushl $89
8010668e:	6a 59                	push   $0x59
  jmp alltraps
80106690:	e9 09 f8 ff ff       	jmp    80105e9e <alltraps>

80106695 <vector90>:
.globl vector90
vector90:
  pushl $0
80106695:	6a 00                	push   $0x0
  pushl $90
80106697:	6a 5a                	push   $0x5a
  jmp alltraps
80106699:	e9 00 f8 ff ff       	jmp    80105e9e <alltraps>

8010669e <vector91>:
.globl vector91
vector91:
  pushl $0
8010669e:	6a 00                	push   $0x0
  pushl $91
801066a0:	6a 5b                	push   $0x5b
  jmp alltraps
801066a2:	e9 f7 f7 ff ff       	jmp    80105e9e <alltraps>

801066a7 <vector92>:
.globl vector92
vector92:
  pushl $0
801066a7:	6a 00                	push   $0x0
  pushl $92
801066a9:	6a 5c                	push   $0x5c
  jmp alltraps
801066ab:	e9 ee f7 ff ff       	jmp    80105e9e <alltraps>

801066b0 <vector93>:
.globl vector93
vector93:
  pushl $0
801066b0:	6a 00                	push   $0x0
  pushl $93
801066b2:	6a 5d                	push   $0x5d
  jmp alltraps
801066b4:	e9 e5 f7 ff ff       	jmp    80105e9e <alltraps>

801066b9 <vector94>:
.globl vector94
vector94:
  pushl $0
801066b9:	6a 00                	push   $0x0
  pushl $94
801066bb:	6a 5e                	push   $0x5e
  jmp alltraps
801066bd:	e9 dc f7 ff ff       	jmp    80105e9e <alltraps>

801066c2 <vector95>:
.globl vector95
vector95:
  pushl $0
801066c2:	6a 00                	push   $0x0
  pushl $95
801066c4:	6a 5f                	push   $0x5f
  jmp alltraps
801066c6:	e9 d3 f7 ff ff       	jmp    80105e9e <alltraps>

801066cb <vector96>:
.globl vector96
vector96:
  pushl $0
801066cb:	6a 00                	push   $0x0
  pushl $96
801066cd:	6a 60                	push   $0x60
  jmp alltraps
801066cf:	e9 ca f7 ff ff       	jmp    80105e9e <alltraps>

801066d4 <vector97>:
.globl vector97
vector97:
  pushl $0
801066d4:	6a 00                	push   $0x0
  pushl $97
801066d6:	6a 61                	push   $0x61
  jmp alltraps
801066d8:	e9 c1 f7 ff ff       	jmp    80105e9e <alltraps>

801066dd <vector98>:
.globl vector98
vector98:
  pushl $0
801066dd:	6a 00                	push   $0x0
  pushl $98
801066df:	6a 62                	push   $0x62
  jmp alltraps
801066e1:	e9 b8 f7 ff ff       	jmp    80105e9e <alltraps>

801066e6 <vector99>:
.globl vector99
vector99:
  pushl $0
801066e6:	6a 00                	push   $0x0
  pushl $99
801066e8:	6a 63                	push   $0x63
  jmp alltraps
801066ea:	e9 af f7 ff ff       	jmp    80105e9e <alltraps>

801066ef <vector100>:
.globl vector100
vector100:
  pushl $0
801066ef:	6a 00                	push   $0x0
  pushl $100
801066f1:	6a 64                	push   $0x64
  jmp alltraps
801066f3:	e9 a6 f7 ff ff       	jmp    80105e9e <alltraps>

801066f8 <vector101>:
.globl vector101
vector101:
  pushl $0
801066f8:	6a 00                	push   $0x0
  pushl $101
801066fa:	6a 65                	push   $0x65
  jmp alltraps
801066fc:	e9 9d f7 ff ff       	jmp    80105e9e <alltraps>

80106701 <vector102>:
.globl vector102
vector102:
  pushl $0
80106701:	6a 00                	push   $0x0
  pushl $102
80106703:	6a 66                	push   $0x66
  jmp alltraps
80106705:	e9 94 f7 ff ff       	jmp    80105e9e <alltraps>

8010670a <vector103>:
.globl vector103
vector103:
  pushl $0
8010670a:	6a 00                	push   $0x0
  pushl $103
8010670c:	6a 67                	push   $0x67
  jmp alltraps
8010670e:	e9 8b f7 ff ff       	jmp    80105e9e <alltraps>

80106713 <vector104>:
.globl vector104
vector104:
  pushl $0
80106713:	6a 00                	push   $0x0
  pushl $104
80106715:	6a 68                	push   $0x68
  jmp alltraps
80106717:	e9 82 f7 ff ff       	jmp    80105e9e <alltraps>

8010671c <vector105>:
.globl vector105
vector105:
  pushl $0
8010671c:	6a 00                	push   $0x0
  pushl $105
8010671e:	6a 69                	push   $0x69
  jmp alltraps
80106720:	e9 79 f7 ff ff       	jmp    80105e9e <alltraps>

80106725 <vector106>:
.globl vector106
vector106:
  pushl $0
80106725:	6a 00                	push   $0x0
  pushl $106
80106727:	6a 6a                	push   $0x6a
  jmp alltraps
80106729:	e9 70 f7 ff ff       	jmp    80105e9e <alltraps>

8010672e <vector107>:
.globl vector107
vector107:
  pushl $0
8010672e:	6a 00                	push   $0x0
  pushl $107
80106730:	6a 6b                	push   $0x6b
  jmp alltraps
80106732:	e9 67 f7 ff ff       	jmp    80105e9e <alltraps>

80106737 <vector108>:
.globl vector108
vector108:
  pushl $0
80106737:	6a 00                	push   $0x0
  pushl $108
80106739:	6a 6c                	push   $0x6c
  jmp alltraps
8010673b:	e9 5e f7 ff ff       	jmp    80105e9e <alltraps>

80106740 <vector109>:
.globl vector109
vector109:
  pushl $0
80106740:	6a 00                	push   $0x0
  pushl $109
80106742:	6a 6d                	push   $0x6d
  jmp alltraps
80106744:	e9 55 f7 ff ff       	jmp    80105e9e <alltraps>

80106749 <vector110>:
.globl vector110
vector110:
  pushl $0
80106749:	6a 00                	push   $0x0
  pushl $110
8010674b:	6a 6e                	push   $0x6e
  jmp alltraps
8010674d:	e9 4c f7 ff ff       	jmp    80105e9e <alltraps>

80106752 <vector111>:
.globl vector111
vector111:
  pushl $0
80106752:	6a 00                	push   $0x0
  pushl $111
80106754:	6a 6f                	push   $0x6f
  jmp alltraps
80106756:	e9 43 f7 ff ff       	jmp    80105e9e <alltraps>

8010675b <vector112>:
.globl vector112
vector112:
  pushl $0
8010675b:	6a 00                	push   $0x0
  pushl $112
8010675d:	6a 70                	push   $0x70
  jmp alltraps
8010675f:	e9 3a f7 ff ff       	jmp    80105e9e <alltraps>

80106764 <vector113>:
.globl vector113
vector113:
  pushl $0
80106764:	6a 00                	push   $0x0
  pushl $113
80106766:	6a 71                	push   $0x71
  jmp alltraps
80106768:	e9 31 f7 ff ff       	jmp    80105e9e <alltraps>

8010676d <vector114>:
.globl vector114
vector114:
  pushl $0
8010676d:	6a 00                	push   $0x0
  pushl $114
8010676f:	6a 72                	push   $0x72
  jmp alltraps
80106771:	e9 28 f7 ff ff       	jmp    80105e9e <alltraps>

80106776 <vector115>:
.globl vector115
vector115:
  pushl $0
80106776:	6a 00                	push   $0x0
  pushl $115
80106778:	6a 73                	push   $0x73
  jmp alltraps
8010677a:	e9 1f f7 ff ff       	jmp    80105e9e <alltraps>

8010677f <vector116>:
.globl vector116
vector116:
  pushl $0
8010677f:	6a 00                	push   $0x0
  pushl $116
80106781:	6a 74                	push   $0x74
  jmp alltraps
80106783:	e9 16 f7 ff ff       	jmp    80105e9e <alltraps>

80106788 <vector117>:
.globl vector117
vector117:
  pushl $0
80106788:	6a 00                	push   $0x0
  pushl $117
8010678a:	6a 75                	push   $0x75
  jmp alltraps
8010678c:	e9 0d f7 ff ff       	jmp    80105e9e <alltraps>

80106791 <vector118>:
.globl vector118
vector118:
  pushl $0
80106791:	6a 00                	push   $0x0
  pushl $118
80106793:	6a 76                	push   $0x76
  jmp alltraps
80106795:	e9 04 f7 ff ff       	jmp    80105e9e <alltraps>

8010679a <vector119>:
.globl vector119
vector119:
  pushl $0
8010679a:	6a 00                	push   $0x0
  pushl $119
8010679c:	6a 77                	push   $0x77
  jmp alltraps
8010679e:	e9 fb f6 ff ff       	jmp    80105e9e <alltraps>

801067a3 <vector120>:
.globl vector120
vector120:
  pushl $0
801067a3:	6a 00                	push   $0x0
  pushl $120
801067a5:	6a 78                	push   $0x78
  jmp alltraps
801067a7:	e9 f2 f6 ff ff       	jmp    80105e9e <alltraps>

801067ac <vector121>:
.globl vector121
vector121:
  pushl $0
801067ac:	6a 00                	push   $0x0
  pushl $121
801067ae:	6a 79                	push   $0x79
  jmp alltraps
801067b0:	e9 e9 f6 ff ff       	jmp    80105e9e <alltraps>

801067b5 <vector122>:
.globl vector122
vector122:
  pushl $0
801067b5:	6a 00                	push   $0x0
  pushl $122
801067b7:	6a 7a                	push   $0x7a
  jmp alltraps
801067b9:	e9 e0 f6 ff ff       	jmp    80105e9e <alltraps>

801067be <vector123>:
.globl vector123
vector123:
  pushl $0
801067be:	6a 00                	push   $0x0
  pushl $123
801067c0:	6a 7b                	push   $0x7b
  jmp alltraps
801067c2:	e9 d7 f6 ff ff       	jmp    80105e9e <alltraps>

801067c7 <vector124>:
.globl vector124
vector124:
  pushl $0
801067c7:	6a 00                	push   $0x0
  pushl $124
801067c9:	6a 7c                	push   $0x7c
  jmp alltraps
801067cb:	e9 ce f6 ff ff       	jmp    80105e9e <alltraps>

801067d0 <vector125>:
.globl vector125
vector125:
  pushl $0
801067d0:	6a 00                	push   $0x0
  pushl $125
801067d2:	6a 7d                	push   $0x7d
  jmp alltraps
801067d4:	e9 c5 f6 ff ff       	jmp    80105e9e <alltraps>

801067d9 <vector126>:
.globl vector126
vector126:
  pushl $0
801067d9:	6a 00                	push   $0x0
  pushl $126
801067db:	6a 7e                	push   $0x7e
  jmp alltraps
801067dd:	e9 bc f6 ff ff       	jmp    80105e9e <alltraps>

801067e2 <vector127>:
.globl vector127
vector127:
  pushl $0
801067e2:	6a 00                	push   $0x0
  pushl $127
801067e4:	6a 7f                	push   $0x7f
  jmp alltraps
801067e6:	e9 b3 f6 ff ff       	jmp    80105e9e <alltraps>

801067eb <vector128>:
.globl vector128
vector128:
  pushl $0
801067eb:	6a 00                	push   $0x0
  pushl $128
801067ed:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801067f2:	e9 a7 f6 ff ff       	jmp    80105e9e <alltraps>

801067f7 <vector129>:
.globl vector129
vector129:
  pushl $0
801067f7:	6a 00                	push   $0x0
  pushl $129
801067f9:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801067fe:	e9 9b f6 ff ff       	jmp    80105e9e <alltraps>

80106803 <vector130>:
.globl vector130
vector130:
  pushl $0
80106803:	6a 00                	push   $0x0
  pushl $130
80106805:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010680a:	e9 8f f6 ff ff       	jmp    80105e9e <alltraps>

8010680f <vector131>:
.globl vector131
vector131:
  pushl $0
8010680f:	6a 00                	push   $0x0
  pushl $131
80106811:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106816:	e9 83 f6 ff ff       	jmp    80105e9e <alltraps>

8010681b <vector132>:
.globl vector132
vector132:
  pushl $0
8010681b:	6a 00                	push   $0x0
  pushl $132
8010681d:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106822:	e9 77 f6 ff ff       	jmp    80105e9e <alltraps>

80106827 <vector133>:
.globl vector133
vector133:
  pushl $0
80106827:	6a 00                	push   $0x0
  pushl $133
80106829:	68 85 00 00 00       	push   $0x85
  jmp alltraps
8010682e:	e9 6b f6 ff ff       	jmp    80105e9e <alltraps>

80106833 <vector134>:
.globl vector134
vector134:
  pushl $0
80106833:	6a 00                	push   $0x0
  pushl $134
80106835:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010683a:	e9 5f f6 ff ff       	jmp    80105e9e <alltraps>

8010683f <vector135>:
.globl vector135
vector135:
  pushl $0
8010683f:	6a 00                	push   $0x0
  pushl $135
80106841:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106846:	e9 53 f6 ff ff       	jmp    80105e9e <alltraps>

8010684b <vector136>:
.globl vector136
vector136:
  pushl $0
8010684b:	6a 00                	push   $0x0
  pushl $136
8010684d:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106852:	e9 47 f6 ff ff       	jmp    80105e9e <alltraps>

80106857 <vector137>:
.globl vector137
vector137:
  pushl $0
80106857:	6a 00                	push   $0x0
  pushl $137
80106859:	68 89 00 00 00       	push   $0x89
  jmp alltraps
8010685e:	e9 3b f6 ff ff       	jmp    80105e9e <alltraps>

80106863 <vector138>:
.globl vector138
vector138:
  pushl $0
80106863:	6a 00                	push   $0x0
  pushl $138
80106865:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
8010686a:	e9 2f f6 ff ff       	jmp    80105e9e <alltraps>

8010686f <vector139>:
.globl vector139
vector139:
  pushl $0
8010686f:	6a 00                	push   $0x0
  pushl $139
80106871:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106876:	e9 23 f6 ff ff       	jmp    80105e9e <alltraps>

8010687b <vector140>:
.globl vector140
vector140:
  pushl $0
8010687b:	6a 00                	push   $0x0
  pushl $140
8010687d:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106882:	e9 17 f6 ff ff       	jmp    80105e9e <alltraps>

80106887 <vector141>:
.globl vector141
vector141:
  pushl $0
80106887:	6a 00                	push   $0x0
  pushl $141
80106889:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010688e:	e9 0b f6 ff ff       	jmp    80105e9e <alltraps>

80106893 <vector142>:
.globl vector142
vector142:
  pushl $0
80106893:	6a 00                	push   $0x0
  pushl $142
80106895:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
8010689a:	e9 ff f5 ff ff       	jmp    80105e9e <alltraps>

8010689f <vector143>:
.globl vector143
vector143:
  pushl $0
8010689f:	6a 00                	push   $0x0
  pushl $143
801068a1:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801068a6:	e9 f3 f5 ff ff       	jmp    80105e9e <alltraps>

801068ab <vector144>:
.globl vector144
vector144:
  pushl $0
801068ab:	6a 00                	push   $0x0
  pushl $144
801068ad:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801068b2:	e9 e7 f5 ff ff       	jmp    80105e9e <alltraps>

801068b7 <vector145>:
.globl vector145
vector145:
  pushl $0
801068b7:	6a 00                	push   $0x0
  pushl $145
801068b9:	68 91 00 00 00       	push   $0x91
  jmp alltraps
801068be:	e9 db f5 ff ff       	jmp    80105e9e <alltraps>

801068c3 <vector146>:
.globl vector146
vector146:
  pushl $0
801068c3:	6a 00                	push   $0x0
  pushl $146
801068c5:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801068ca:	e9 cf f5 ff ff       	jmp    80105e9e <alltraps>

801068cf <vector147>:
.globl vector147
vector147:
  pushl $0
801068cf:	6a 00                	push   $0x0
  pushl $147
801068d1:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801068d6:	e9 c3 f5 ff ff       	jmp    80105e9e <alltraps>

801068db <vector148>:
.globl vector148
vector148:
  pushl $0
801068db:	6a 00                	push   $0x0
  pushl $148
801068dd:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801068e2:	e9 b7 f5 ff ff       	jmp    80105e9e <alltraps>

801068e7 <vector149>:
.globl vector149
vector149:
  pushl $0
801068e7:	6a 00                	push   $0x0
  pushl $149
801068e9:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801068ee:	e9 ab f5 ff ff       	jmp    80105e9e <alltraps>

801068f3 <vector150>:
.globl vector150
vector150:
  pushl $0
801068f3:	6a 00                	push   $0x0
  pushl $150
801068f5:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801068fa:	e9 9f f5 ff ff       	jmp    80105e9e <alltraps>

801068ff <vector151>:
.globl vector151
vector151:
  pushl $0
801068ff:	6a 00                	push   $0x0
  pushl $151
80106901:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106906:	e9 93 f5 ff ff       	jmp    80105e9e <alltraps>

8010690b <vector152>:
.globl vector152
vector152:
  pushl $0
8010690b:	6a 00                	push   $0x0
  pushl $152
8010690d:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106912:	e9 87 f5 ff ff       	jmp    80105e9e <alltraps>

80106917 <vector153>:
.globl vector153
vector153:
  pushl $0
80106917:	6a 00                	push   $0x0
  pushl $153
80106919:	68 99 00 00 00       	push   $0x99
  jmp alltraps
8010691e:	e9 7b f5 ff ff       	jmp    80105e9e <alltraps>

80106923 <vector154>:
.globl vector154
vector154:
  pushl $0
80106923:	6a 00                	push   $0x0
  pushl $154
80106925:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010692a:	e9 6f f5 ff ff       	jmp    80105e9e <alltraps>

8010692f <vector155>:
.globl vector155
vector155:
  pushl $0
8010692f:	6a 00                	push   $0x0
  pushl $155
80106931:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106936:	e9 63 f5 ff ff       	jmp    80105e9e <alltraps>

8010693b <vector156>:
.globl vector156
vector156:
  pushl $0
8010693b:	6a 00                	push   $0x0
  pushl $156
8010693d:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106942:	e9 57 f5 ff ff       	jmp    80105e9e <alltraps>

80106947 <vector157>:
.globl vector157
vector157:
  pushl $0
80106947:	6a 00                	push   $0x0
  pushl $157
80106949:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
8010694e:	e9 4b f5 ff ff       	jmp    80105e9e <alltraps>

80106953 <vector158>:
.globl vector158
vector158:
  pushl $0
80106953:	6a 00                	push   $0x0
  pushl $158
80106955:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
8010695a:	e9 3f f5 ff ff       	jmp    80105e9e <alltraps>

8010695f <vector159>:
.globl vector159
vector159:
  pushl $0
8010695f:	6a 00                	push   $0x0
  pushl $159
80106961:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106966:	e9 33 f5 ff ff       	jmp    80105e9e <alltraps>

8010696b <vector160>:
.globl vector160
vector160:
  pushl $0
8010696b:	6a 00                	push   $0x0
  pushl $160
8010696d:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106972:	e9 27 f5 ff ff       	jmp    80105e9e <alltraps>

80106977 <vector161>:
.globl vector161
vector161:
  pushl $0
80106977:	6a 00                	push   $0x0
  pushl $161
80106979:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
8010697e:	e9 1b f5 ff ff       	jmp    80105e9e <alltraps>

80106983 <vector162>:
.globl vector162
vector162:
  pushl $0
80106983:	6a 00                	push   $0x0
  pushl $162
80106985:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
8010698a:	e9 0f f5 ff ff       	jmp    80105e9e <alltraps>

8010698f <vector163>:
.globl vector163
vector163:
  pushl $0
8010698f:	6a 00                	push   $0x0
  pushl $163
80106991:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106996:	e9 03 f5 ff ff       	jmp    80105e9e <alltraps>

8010699b <vector164>:
.globl vector164
vector164:
  pushl $0
8010699b:	6a 00                	push   $0x0
  pushl $164
8010699d:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801069a2:	e9 f7 f4 ff ff       	jmp    80105e9e <alltraps>

801069a7 <vector165>:
.globl vector165
vector165:
  pushl $0
801069a7:	6a 00                	push   $0x0
  pushl $165
801069a9:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801069ae:	e9 eb f4 ff ff       	jmp    80105e9e <alltraps>

801069b3 <vector166>:
.globl vector166
vector166:
  pushl $0
801069b3:	6a 00                	push   $0x0
  pushl $166
801069b5:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
801069ba:	e9 df f4 ff ff       	jmp    80105e9e <alltraps>

801069bf <vector167>:
.globl vector167
vector167:
  pushl $0
801069bf:	6a 00                	push   $0x0
  pushl $167
801069c1:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
801069c6:	e9 d3 f4 ff ff       	jmp    80105e9e <alltraps>

801069cb <vector168>:
.globl vector168
vector168:
  pushl $0
801069cb:	6a 00                	push   $0x0
  pushl $168
801069cd:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801069d2:	e9 c7 f4 ff ff       	jmp    80105e9e <alltraps>

801069d7 <vector169>:
.globl vector169
vector169:
  pushl $0
801069d7:	6a 00                	push   $0x0
  pushl $169
801069d9:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801069de:	e9 bb f4 ff ff       	jmp    80105e9e <alltraps>

801069e3 <vector170>:
.globl vector170
vector170:
  pushl $0
801069e3:	6a 00                	push   $0x0
  pushl $170
801069e5:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801069ea:	e9 af f4 ff ff       	jmp    80105e9e <alltraps>

801069ef <vector171>:
.globl vector171
vector171:
  pushl $0
801069ef:	6a 00                	push   $0x0
  pushl $171
801069f1:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801069f6:	e9 a3 f4 ff ff       	jmp    80105e9e <alltraps>

801069fb <vector172>:
.globl vector172
vector172:
  pushl $0
801069fb:	6a 00                	push   $0x0
  pushl $172
801069fd:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106a02:	e9 97 f4 ff ff       	jmp    80105e9e <alltraps>

80106a07 <vector173>:
.globl vector173
vector173:
  pushl $0
80106a07:	6a 00                	push   $0x0
  pushl $173
80106a09:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106a0e:	e9 8b f4 ff ff       	jmp    80105e9e <alltraps>

80106a13 <vector174>:
.globl vector174
vector174:
  pushl $0
80106a13:	6a 00                	push   $0x0
  pushl $174
80106a15:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106a1a:	e9 7f f4 ff ff       	jmp    80105e9e <alltraps>

80106a1f <vector175>:
.globl vector175
vector175:
  pushl $0
80106a1f:	6a 00                	push   $0x0
  pushl $175
80106a21:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106a26:	e9 73 f4 ff ff       	jmp    80105e9e <alltraps>

80106a2b <vector176>:
.globl vector176
vector176:
  pushl $0
80106a2b:	6a 00                	push   $0x0
  pushl $176
80106a2d:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106a32:	e9 67 f4 ff ff       	jmp    80105e9e <alltraps>

80106a37 <vector177>:
.globl vector177
vector177:
  pushl $0
80106a37:	6a 00                	push   $0x0
  pushl $177
80106a39:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106a3e:	e9 5b f4 ff ff       	jmp    80105e9e <alltraps>

80106a43 <vector178>:
.globl vector178
vector178:
  pushl $0
80106a43:	6a 00                	push   $0x0
  pushl $178
80106a45:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106a4a:	e9 4f f4 ff ff       	jmp    80105e9e <alltraps>

80106a4f <vector179>:
.globl vector179
vector179:
  pushl $0
80106a4f:	6a 00                	push   $0x0
  pushl $179
80106a51:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106a56:	e9 43 f4 ff ff       	jmp    80105e9e <alltraps>

80106a5b <vector180>:
.globl vector180
vector180:
  pushl $0
80106a5b:	6a 00                	push   $0x0
  pushl $180
80106a5d:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106a62:	e9 37 f4 ff ff       	jmp    80105e9e <alltraps>

80106a67 <vector181>:
.globl vector181
vector181:
  pushl $0
80106a67:	6a 00                	push   $0x0
  pushl $181
80106a69:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106a6e:	e9 2b f4 ff ff       	jmp    80105e9e <alltraps>

80106a73 <vector182>:
.globl vector182
vector182:
  pushl $0
80106a73:	6a 00                	push   $0x0
  pushl $182
80106a75:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106a7a:	e9 1f f4 ff ff       	jmp    80105e9e <alltraps>

80106a7f <vector183>:
.globl vector183
vector183:
  pushl $0
80106a7f:	6a 00                	push   $0x0
  pushl $183
80106a81:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106a86:	e9 13 f4 ff ff       	jmp    80105e9e <alltraps>

80106a8b <vector184>:
.globl vector184
vector184:
  pushl $0
80106a8b:	6a 00                	push   $0x0
  pushl $184
80106a8d:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106a92:	e9 07 f4 ff ff       	jmp    80105e9e <alltraps>

80106a97 <vector185>:
.globl vector185
vector185:
  pushl $0
80106a97:	6a 00                	push   $0x0
  pushl $185
80106a99:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106a9e:	e9 fb f3 ff ff       	jmp    80105e9e <alltraps>

80106aa3 <vector186>:
.globl vector186
vector186:
  pushl $0
80106aa3:	6a 00                	push   $0x0
  pushl $186
80106aa5:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106aaa:	e9 ef f3 ff ff       	jmp    80105e9e <alltraps>

80106aaf <vector187>:
.globl vector187
vector187:
  pushl $0
80106aaf:	6a 00                	push   $0x0
  pushl $187
80106ab1:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106ab6:	e9 e3 f3 ff ff       	jmp    80105e9e <alltraps>

80106abb <vector188>:
.globl vector188
vector188:
  pushl $0
80106abb:	6a 00                	push   $0x0
  pushl $188
80106abd:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106ac2:	e9 d7 f3 ff ff       	jmp    80105e9e <alltraps>

80106ac7 <vector189>:
.globl vector189
vector189:
  pushl $0
80106ac7:	6a 00                	push   $0x0
  pushl $189
80106ac9:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106ace:	e9 cb f3 ff ff       	jmp    80105e9e <alltraps>

80106ad3 <vector190>:
.globl vector190
vector190:
  pushl $0
80106ad3:	6a 00                	push   $0x0
  pushl $190
80106ad5:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106ada:	e9 bf f3 ff ff       	jmp    80105e9e <alltraps>

80106adf <vector191>:
.globl vector191
vector191:
  pushl $0
80106adf:	6a 00                	push   $0x0
  pushl $191
80106ae1:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106ae6:	e9 b3 f3 ff ff       	jmp    80105e9e <alltraps>

80106aeb <vector192>:
.globl vector192
vector192:
  pushl $0
80106aeb:	6a 00                	push   $0x0
  pushl $192
80106aed:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106af2:	e9 a7 f3 ff ff       	jmp    80105e9e <alltraps>

80106af7 <vector193>:
.globl vector193
vector193:
  pushl $0
80106af7:	6a 00                	push   $0x0
  pushl $193
80106af9:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106afe:	e9 9b f3 ff ff       	jmp    80105e9e <alltraps>

80106b03 <vector194>:
.globl vector194
vector194:
  pushl $0
80106b03:	6a 00                	push   $0x0
  pushl $194
80106b05:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106b0a:	e9 8f f3 ff ff       	jmp    80105e9e <alltraps>

80106b0f <vector195>:
.globl vector195
vector195:
  pushl $0
80106b0f:	6a 00                	push   $0x0
  pushl $195
80106b11:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106b16:	e9 83 f3 ff ff       	jmp    80105e9e <alltraps>

80106b1b <vector196>:
.globl vector196
vector196:
  pushl $0
80106b1b:	6a 00                	push   $0x0
  pushl $196
80106b1d:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106b22:	e9 77 f3 ff ff       	jmp    80105e9e <alltraps>

80106b27 <vector197>:
.globl vector197
vector197:
  pushl $0
80106b27:	6a 00                	push   $0x0
  pushl $197
80106b29:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106b2e:	e9 6b f3 ff ff       	jmp    80105e9e <alltraps>

80106b33 <vector198>:
.globl vector198
vector198:
  pushl $0
80106b33:	6a 00                	push   $0x0
  pushl $198
80106b35:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106b3a:	e9 5f f3 ff ff       	jmp    80105e9e <alltraps>

80106b3f <vector199>:
.globl vector199
vector199:
  pushl $0
80106b3f:	6a 00                	push   $0x0
  pushl $199
80106b41:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106b46:	e9 53 f3 ff ff       	jmp    80105e9e <alltraps>

80106b4b <vector200>:
.globl vector200
vector200:
  pushl $0
80106b4b:	6a 00                	push   $0x0
  pushl $200
80106b4d:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106b52:	e9 47 f3 ff ff       	jmp    80105e9e <alltraps>

80106b57 <vector201>:
.globl vector201
vector201:
  pushl $0
80106b57:	6a 00                	push   $0x0
  pushl $201
80106b59:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106b5e:	e9 3b f3 ff ff       	jmp    80105e9e <alltraps>

80106b63 <vector202>:
.globl vector202
vector202:
  pushl $0
80106b63:	6a 00                	push   $0x0
  pushl $202
80106b65:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106b6a:	e9 2f f3 ff ff       	jmp    80105e9e <alltraps>

80106b6f <vector203>:
.globl vector203
vector203:
  pushl $0
80106b6f:	6a 00                	push   $0x0
  pushl $203
80106b71:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106b76:	e9 23 f3 ff ff       	jmp    80105e9e <alltraps>

80106b7b <vector204>:
.globl vector204
vector204:
  pushl $0
80106b7b:	6a 00                	push   $0x0
  pushl $204
80106b7d:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106b82:	e9 17 f3 ff ff       	jmp    80105e9e <alltraps>

80106b87 <vector205>:
.globl vector205
vector205:
  pushl $0
80106b87:	6a 00                	push   $0x0
  pushl $205
80106b89:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106b8e:	e9 0b f3 ff ff       	jmp    80105e9e <alltraps>

80106b93 <vector206>:
.globl vector206
vector206:
  pushl $0
80106b93:	6a 00                	push   $0x0
  pushl $206
80106b95:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106b9a:	e9 ff f2 ff ff       	jmp    80105e9e <alltraps>

80106b9f <vector207>:
.globl vector207
vector207:
  pushl $0
80106b9f:	6a 00                	push   $0x0
  pushl $207
80106ba1:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106ba6:	e9 f3 f2 ff ff       	jmp    80105e9e <alltraps>

80106bab <vector208>:
.globl vector208
vector208:
  pushl $0
80106bab:	6a 00                	push   $0x0
  pushl $208
80106bad:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106bb2:	e9 e7 f2 ff ff       	jmp    80105e9e <alltraps>

80106bb7 <vector209>:
.globl vector209
vector209:
  pushl $0
80106bb7:	6a 00                	push   $0x0
  pushl $209
80106bb9:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106bbe:	e9 db f2 ff ff       	jmp    80105e9e <alltraps>

80106bc3 <vector210>:
.globl vector210
vector210:
  pushl $0
80106bc3:	6a 00                	push   $0x0
  pushl $210
80106bc5:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106bca:	e9 cf f2 ff ff       	jmp    80105e9e <alltraps>

80106bcf <vector211>:
.globl vector211
vector211:
  pushl $0
80106bcf:	6a 00                	push   $0x0
  pushl $211
80106bd1:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106bd6:	e9 c3 f2 ff ff       	jmp    80105e9e <alltraps>

80106bdb <vector212>:
.globl vector212
vector212:
  pushl $0
80106bdb:	6a 00                	push   $0x0
  pushl $212
80106bdd:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106be2:	e9 b7 f2 ff ff       	jmp    80105e9e <alltraps>

80106be7 <vector213>:
.globl vector213
vector213:
  pushl $0
80106be7:	6a 00                	push   $0x0
  pushl $213
80106be9:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106bee:	e9 ab f2 ff ff       	jmp    80105e9e <alltraps>

80106bf3 <vector214>:
.globl vector214
vector214:
  pushl $0
80106bf3:	6a 00                	push   $0x0
  pushl $214
80106bf5:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106bfa:	e9 9f f2 ff ff       	jmp    80105e9e <alltraps>

80106bff <vector215>:
.globl vector215
vector215:
  pushl $0
80106bff:	6a 00                	push   $0x0
  pushl $215
80106c01:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106c06:	e9 93 f2 ff ff       	jmp    80105e9e <alltraps>

80106c0b <vector216>:
.globl vector216
vector216:
  pushl $0
80106c0b:	6a 00                	push   $0x0
  pushl $216
80106c0d:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106c12:	e9 87 f2 ff ff       	jmp    80105e9e <alltraps>

80106c17 <vector217>:
.globl vector217
vector217:
  pushl $0
80106c17:	6a 00                	push   $0x0
  pushl $217
80106c19:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106c1e:	e9 7b f2 ff ff       	jmp    80105e9e <alltraps>

80106c23 <vector218>:
.globl vector218
vector218:
  pushl $0
80106c23:	6a 00                	push   $0x0
  pushl $218
80106c25:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106c2a:	e9 6f f2 ff ff       	jmp    80105e9e <alltraps>

80106c2f <vector219>:
.globl vector219
vector219:
  pushl $0
80106c2f:	6a 00                	push   $0x0
  pushl $219
80106c31:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106c36:	e9 63 f2 ff ff       	jmp    80105e9e <alltraps>

80106c3b <vector220>:
.globl vector220
vector220:
  pushl $0
80106c3b:	6a 00                	push   $0x0
  pushl $220
80106c3d:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106c42:	e9 57 f2 ff ff       	jmp    80105e9e <alltraps>

80106c47 <vector221>:
.globl vector221
vector221:
  pushl $0
80106c47:	6a 00                	push   $0x0
  pushl $221
80106c49:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106c4e:	e9 4b f2 ff ff       	jmp    80105e9e <alltraps>

80106c53 <vector222>:
.globl vector222
vector222:
  pushl $0
80106c53:	6a 00                	push   $0x0
  pushl $222
80106c55:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106c5a:	e9 3f f2 ff ff       	jmp    80105e9e <alltraps>

80106c5f <vector223>:
.globl vector223
vector223:
  pushl $0
80106c5f:	6a 00                	push   $0x0
  pushl $223
80106c61:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106c66:	e9 33 f2 ff ff       	jmp    80105e9e <alltraps>

80106c6b <vector224>:
.globl vector224
vector224:
  pushl $0
80106c6b:	6a 00                	push   $0x0
  pushl $224
80106c6d:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106c72:	e9 27 f2 ff ff       	jmp    80105e9e <alltraps>

80106c77 <vector225>:
.globl vector225
vector225:
  pushl $0
80106c77:	6a 00                	push   $0x0
  pushl $225
80106c79:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106c7e:	e9 1b f2 ff ff       	jmp    80105e9e <alltraps>

80106c83 <vector226>:
.globl vector226
vector226:
  pushl $0
80106c83:	6a 00                	push   $0x0
  pushl $226
80106c85:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106c8a:	e9 0f f2 ff ff       	jmp    80105e9e <alltraps>

80106c8f <vector227>:
.globl vector227
vector227:
  pushl $0
80106c8f:	6a 00                	push   $0x0
  pushl $227
80106c91:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106c96:	e9 03 f2 ff ff       	jmp    80105e9e <alltraps>

80106c9b <vector228>:
.globl vector228
vector228:
  pushl $0
80106c9b:	6a 00                	push   $0x0
  pushl $228
80106c9d:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106ca2:	e9 f7 f1 ff ff       	jmp    80105e9e <alltraps>

80106ca7 <vector229>:
.globl vector229
vector229:
  pushl $0
80106ca7:	6a 00                	push   $0x0
  pushl $229
80106ca9:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106cae:	e9 eb f1 ff ff       	jmp    80105e9e <alltraps>

80106cb3 <vector230>:
.globl vector230
vector230:
  pushl $0
80106cb3:	6a 00                	push   $0x0
  pushl $230
80106cb5:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106cba:	e9 df f1 ff ff       	jmp    80105e9e <alltraps>

80106cbf <vector231>:
.globl vector231
vector231:
  pushl $0
80106cbf:	6a 00                	push   $0x0
  pushl $231
80106cc1:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106cc6:	e9 d3 f1 ff ff       	jmp    80105e9e <alltraps>

80106ccb <vector232>:
.globl vector232
vector232:
  pushl $0
80106ccb:	6a 00                	push   $0x0
  pushl $232
80106ccd:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106cd2:	e9 c7 f1 ff ff       	jmp    80105e9e <alltraps>

80106cd7 <vector233>:
.globl vector233
vector233:
  pushl $0
80106cd7:	6a 00                	push   $0x0
  pushl $233
80106cd9:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80106cde:	e9 bb f1 ff ff       	jmp    80105e9e <alltraps>

80106ce3 <vector234>:
.globl vector234
vector234:
  pushl $0
80106ce3:	6a 00                	push   $0x0
  pushl $234
80106ce5:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80106cea:	e9 af f1 ff ff       	jmp    80105e9e <alltraps>

80106cef <vector235>:
.globl vector235
vector235:
  pushl $0
80106cef:	6a 00                	push   $0x0
  pushl $235
80106cf1:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80106cf6:	e9 a3 f1 ff ff       	jmp    80105e9e <alltraps>

80106cfb <vector236>:
.globl vector236
vector236:
  pushl $0
80106cfb:	6a 00                	push   $0x0
  pushl $236
80106cfd:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80106d02:	e9 97 f1 ff ff       	jmp    80105e9e <alltraps>

80106d07 <vector237>:
.globl vector237
vector237:
  pushl $0
80106d07:	6a 00                	push   $0x0
  pushl $237
80106d09:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80106d0e:	e9 8b f1 ff ff       	jmp    80105e9e <alltraps>

80106d13 <vector238>:
.globl vector238
vector238:
  pushl $0
80106d13:	6a 00                	push   $0x0
  pushl $238
80106d15:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80106d1a:	e9 7f f1 ff ff       	jmp    80105e9e <alltraps>

80106d1f <vector239>:
.globl vector239
vector239:
  pushl $0
80106d1f:	6a 00                	push   $0x0
  pushl $239
80106d21:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80106d26:	e9 73 f1 ff ff       	jmp    80105e9e <alltraps>

80106d2b <vector240>:
.globl vector240
vector240:
  pushl $0
80106d2b:	6a 00                	push   $0x0
  pushl $240
80106d2d:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80106d32:	e9 67 f1 ff ff       	jmp    80105e9e <alltraps>

80106d37 <vector241>:
.globl vector241
vector241:
  pushl $0
80106d37:	6a 00                	push   $0x0
  pushl $241
80106d39:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80106d3e:	e9 5b f1 ff ff       	jmp    80105e9e <alltraps>

80106d43 <vector242>:
.globl vector242
vector242:
  pushl $0
80106d43:	6a 00                	push   $0x0
  pushl $242
80106d45:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80106d4a:	e9 4f f1 ff ff       	jmp    80105e9e <alltraps>

80106d4f <vector243>:
.globl vector243
vector243:
  pushl $0
80106d4f:	6a 00                	push   $0x0
  pushl $243
80106d51:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80106d56:	e9 43 f1 ff ff       	jmp    80105e9e <alltraps>

80106d5b <vector244>:
.globl vector244
vector244:
  pushl $0
80106d5b:	6a 00                	push   $0x0
  pushl $244
80106d5d:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80106d62:	e9 37 f1 ff ff       	jmp    80105e9e <alltraps>

80106d67 <vector245>:
.globl vector245
vector245:
  pushl $0
80106d67:	6a 00                	push   $0x0
  pushl $245
80106d69:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80106d6e:	e9 2b f1 ff ff       	jmp    80105e9e <alltraps>

80106d73 <vector246>:
.globl vector246
vector246:
  pushl $0
80106d73:	6a 00                	push   $0x0
  pushl $246
80106d75:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80106d7a:	e9 1f f1 ff ff       	jmp    80105e9e <alltraps>

80106d7f <vector247>:
.globl vector247
vector247:
  pushl $0
80106d7f:	6a 00                	push   $0x0
  pushl $247
80106d81:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80106d86:	e9 13 f1 ff ff       	jmp    80105e9e <alltraps>

80106d8b <vector248>:
.globl vector248
vector248:
  pushl $0
80106d8b:	6a 00                	push   $0x0
  pushl $248
80106d8d:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80106d92:	e9 07 f1 ff ff       	jmp    80105e9e <alltraps>

80106d97 <vector249>:
.globl vector249
vector249:
  pushl $0
80106d97:	6a 00                	push   $0x0
  pushl $249
80106d99:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80106d9e:	e9 fb f0 ff ff       	jmp    80105e9e <alltraps>

80106da3 <vector250>:
.globl vector250
vector250:
  pushl $0
80106da3:	6a 00                	push   $0x0
  pushl $250
80106da5:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80106daa:	e9 ef f0 ff ff       	jmp    80105e9e <alltraps>

80106daf <vector251>:
.globl vector251
vector251:
  pushl $0
80106daf:	6a 00                	push   $0x0
  pushl $251
80106db1:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80106db6:	e9 e3 f0 ff ff       	jmp    80105e9e <alltraps>

80106dbb <vector252>:
.globl vector252
vector252:
  pushl $0
80106dbb:	6a 00                	push   $0x0
  pushl $252
80106dbd:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80106dc2:	e9 d7 f0 ff ff       	jmp    80105e9e <alltraps>

80106dc7 <vector253>:
.globl vector253
vector253:
  pushl $0
80106dc7:	6a 00                	push   $0x0
  pushl $253
80106dc9:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80106dce:	e9 cb f0 ff ff       	jmp    80105e9e <alltraps>

80106dd3 <vector254>:
.globl vector254
vector254:
  pushl $0
80106dd3:	6a 00                	push   $0x0
  pushl $254
80106dd5:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80106dda:	e9 bf f0 ff ff       	jmp    80105e9e <alltraps>

80106ddf <vector255>:
.globl vector255
vector255:
  pushl $0
80106ddf:	6a 00                	push   $0x0
  pushl $255
80106de1:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80106de6:	e9 b3 f0 ff ff       	jmp    80105e9e <alltraps>
80106deb:	66 90                	xchg   %ax,%ax
80106ded:	66 90                	xchg   %ax,%ax
80106def:	90                   	nop

80106df0 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80106df0:	55                   	push   %ebp
80106df1:	89 e5                	mov    %esp,%ebp
80106df3:	57                   	push   %edi
80106df4:	56                   	push   %esi
80106df5:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80106df7:	c1 ea 16             	shr    $0x16,%edx
{
80106dfa:	53                   	push   %ebx
  pde = &pgdir[PDX(va)];
80106dfb:	8d 3c 90             	lea    (%eax,%edx,4),%edi
{
80106dfe:	83 ec 0c             	sub    $0xc,%esp
  if(*pde & PTE_P){
80106e01:	8b 1f                	mov    (%edi),%ebx
80106e03:	f6 c3 01             	test   $0x1,%bl
80106e06:	74 28                	je     80106e30 <walkpgdir+0x40>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80106e08:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80106e0e:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80106e14:	89 f0                	mov    %esi,%eax
}
80106e16:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return &pgtab[PTX(va)];
80106e19:	c1 e8 0a             	shr    $0xa,%eax
80106e1c:	25 fc 0f 00 00       	and    $0xffc,%eax
80106e21:	01 d8                	add    %ebx,%eax
}
80106e23:	5b                   	pop    %ebx
80106e24:	5e                   	pop    %esi
80106e25:	5f                   	pop    %edi
80106e26:	5d                   	pop    %ebp
80106e27:	c3                   	ret    
80106e28:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106e2f:	90                   	nop
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80106e30:	85 c9                	test   %ecx,%ecx
80106e32:	74 2c                	je     80106e60 <walkpgdir+0x70>
80106e34:	e8 27 b9 ff ff       	call   80102760 <kalloc>
80106e39:	89 c3                	mov    %eax,%ebx
80106e3b:	85 c0                	test   %eax,%eax
80106e3d:	74 21                	je     80106e60 <walkpgdir+0x70>
    memset(pgtab, 0, PGSIZE);
80106e3f:	83 ec 04             	sub    $0x4,%esp
80106e42:	68 00 10 00 00       	push   $0x1000
80106e47:	6a 00                	push   $0x0
80106e49:	50                   	push   %eax
80106e4a:	e8 21 de ff ff       	call   80104c70 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80106e4f:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106e55:	83 c4 10             	add    $0x10,%esp
80106e58:	83 c8 07             	or     $0x7,%eax
80106e5b:	89 07                	mov    %eax,(%edi)
80106e5d:	eb b5                	jmp    80106e14 <walkpgdir+0x24>
80106e5f:	90                   	nop
}
80106e60:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return 0;
80106e63:	31 c0                	xor    %eax,%eax
}
80106e65:	5b                   	pop    %ebx
80106e66:	5e                   	pop    %esi
80106e67:	5f                   	pop    %edi
80106e68:	5d                   	pop    %ebp
80106e69:	c3                   	ret    
80106e6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80106e70 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80106e70:	55                   	push   %ebp
80106e71:	89 e5                	mov    %esp,%ebp
80106e73:	57                   	push   %edi
80106e74:	89 c7                	mov    %eax,%edi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106e76:	8d 44 0a ff          	lea    -0x1(%edx,%ecx,1),%eax
{
80106e7a:	56                   	push   %esi
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106e7b:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  a = (char*)PGROUNDDOWN((uint)va);
80106e80:	89 d6                	mov    %edx,%esi
{
80106e82:	53                   	push   %ebx
  a = (char*)PGROUNDDOWN((uint)va);
80106e83:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
{
80106e89:	83 ec 1c             	sub    $0x1c,%esp
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80106e8c:	89 45 e0             	mov    %eax,-0x20(%ebp)
80106e8f:	8b 45 08             	mov    0x8(%ebp),%eax
80106e92:	29 f0                	sub    %esi,%eax
80106e94:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106e97:	eb 1f                	jmp    80106eb8 <mappages+0x48>
80106e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
      return -1;
    if(*pte & PTE_P)
80106ea0:	f6 00 01             	testb  $0x1,(%eax)
80106ea3:	75 45                	jne    80106eea <mappages+0x7a>
      panic("remap");
    *pte = pa | perm | PTE_P;
80106ea5:	0b 5d 0c             	or     0xc(%ebp),%ebx
80106ea8:	83 cb 01             	or     $0x1,%ebx
80106eab:	89 18                	mov    %ebx,(%eax)
    if(a == last)
80106ead:	3b 75 e0             	cmp    -0x20(%ebp),%esi
80106eb0:	74 2e                	je     80106ee0 <mappages+0x70>
      break;
    a += PGSIZE;
80106eb2:	81 c6 00 10 00 00    	add    $0x1000,%esi
  for(;;){
80106eb8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80106ebb:	b9 01 00 00 00       	mov    $0x1,%ecx
80106ec0:	89 f2                	mov    %esi,%edx
80106ec2:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
80106ec5:	89 f8                	mov    %edi,%eax
80106ec7:	e8 24 ff ff ff       	call   80106df0 <walkpgdir>
80106ecc:	85 c0                	test   %eax,%eax
80106ece:	75 d0                	jne    80106ea0 <mappages+0x30>
    pa += PGSIZE;
  }
  return 0;
}
80106ed0:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80106ed3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106ed8:	5b                   	pop    %ebx
80106ed9:	5e                   	pop    %esi
80106eda:	5f                   	pop    %edi
80106edb:	5d                   	pop    %ebp
80106edc:	c3                   	ret    
80106edd:	8d 76 00             	lea    0x0(%esi),%esi
80106ee0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80106ee3:	31 c0                	xor    %eax,%eax
}
80106ee5:	5b                   	pop    %ebx
80106ee6:	5e                   	pop    %esi
80106ee7:	5f                   	pop    %edi
80106ee8:	5d                   	pop    %ebp
80106ee9:	c3                   	ret    
      panic("remap");
80106eea:	83 ec 0c             	sub    $0xc,%esp
80106eed:	68 90 80 10 80       	push   $0x80108090
80106ef2:	e8 99 95 ff ff       	call   80100490 <panic>
80106ef7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106efe:	66 90                	xchg   %ax,%ax

80106f00 <deallocuvm.part.0>:
// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106f00:	55                   	push   %ebp
80106f01:	89 e5                	mov    %esp,%ebp
80106f03:	57                   	push   %edi
80106f04:	56                   	push   %esi
80106f05:	89 c6                	mov    %eax,%esi
80106f07:	53                   	push   %ebx
80106f08:	89 d3                	mov    %edx,%ebx
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
80106f0a:	8d 91 ff 0f 00 00    	lea    0xfff(%ecx),%edx
80106f10:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80106f16:	83 ec 1c             	sub    $0x1c,%esp
80106f19:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80106f1c:	39 da                	cmp    %ebx,%edx
80106f1e:	73 73                	jae    80106f93 <deallocuvm.part.0+0x93>
80106f20:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80106f23:	89 d7                	mov    %edx,%edi
80106f25:	eb 14                	jmp    80106f3b <deallocuvm.part.0+0x3b>
80106f27:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106f2e:	66 90                	xchg   %ax,%ax
80106f30:	81 c7 00 10 00 00    	add    $0x1000,%edi
80106f36:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80106f39:	76 58                	jbe    80106f93 <deallocuvm.part.0+0x93>
    
    pte = walkpgdir(pgdir, (char*)a, 0);
80106f3b:	31 c9                	xor    %ecx,%ecx
80106f3d:	89 fa                	mov    %edi,%edx
80106f3f:	89 f0                	mov    %esi,%eax
80106f41:	e8 aa fe ff ff       	call   80106df0 <walkpgdir>
80106f46:	89 c3                	mov    %eax,%ebx
    if(!pte)
80106f48:	85 c0                	test   %eax,%eax
80106f4a:	74 54                	je     80106fa0 <deallocuvm.part.0+0xa0>
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
    else if((*pte & PTE_P) != 0){
80106f4c:	8b 00                	mov    (%eax),%eax
80106f4e:	a8 01                	test   $0x1,%al
80106f50:	74 de                	je     80106f30 <deallocuvm.part.0+0x30>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106f52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106f57:	74 57                	je     80106fb0 <deallocuvm.part.0+0xb0>
        panic("kfree");
      char *v = P2V(pa);
      kfree(v);
80106f59:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
80106f5c:	05 00 00 00 80       	add    $0x80000000,%eax
80106f61:	81 c7 00 10 00 00    	add    $0x1000,%edi
      kfree(v);
80106f67:	50                   	push   %eax
80106f68:	e8 03 b6 ff ff       	call   80102570 <kfree>
      *pte = 0;
80106f6d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      if(myproc()->rss > 0)
80106f73:	e8 28 cf ff ff       	call   80103ea0 <myproc>
80106f78:	83 c4 10             	add    $0x10,%esp
80106f7b:	8b 40 04             	mov    0x4(%eax),%eax
80106f7e:	85 c0                	test   %eax,%eax
80106f80:	74 b4                	je     80106f36 <deallocuvm.part.0+0x36>
      myproc()->rss -= PGSIZE;
80106f82:	e8 19 cf ff ff       	call   80103ea0 <myproc>
80106f87:	81 68 04 00 10 00 00 	subl   $0x1000,0x4(%eax)
  for(; a  < oldsz; a += PGSIZE){
80106f8e:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80106f91:	77 a8                	ja     80106f3b <deallocuvm.part.0+0x3b>
    }
  }
  return newsz;
}
80106f93:	8b 45 e0             	mov    -0x20(%ebp),%eax
80106f96:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106f99:	5b                   	pop    %ebx
80106f9a:	5e                   	pop    %esi
80106f9b:	5f                   	pop    %edi
80106f9c:	5d                   	pop    %ebp
80106f9d:	c3                   	ret    
80106f9e:	66 90                	xchg   %ax,%ax
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80106fa0:	89 fa                	mov    %edi,%edx
80106fa2:	81 e2 00 00 c0 ff    	and    $0xffc00000,%edx
80106fa8:	8d ba 00 00 40 00    	lea    0x400000(%edx),%edi
80106fae:	eb 86                	jmp    80106f36 <deallocuvm.part.0+0x36>
        panic("kfree");
80106fb0:	83 ec 0c             	sub    $0xc,%esp
80106fb3:	68 c6 79 10 80       	push   $0x801079c6
80106fb8:	e8 d3 94 ff ff       	call   80100490 <panic>
80106fbd:	8d 76 00             	lea    0x0(%esi),%esi

80106fc0 <seginit>:
{
80106fc0:	f3 0f 1e fb          	endbr32 
80106fc4:	55                   	push   %ebp
80106fc5:	89 e5                	mov    %esp,%ebp
80106fc7:	83 ec 18             	sub    $0x18,%esp
  c = &cpus[cpuid()];
80106fca:	e8 b1 ce ff ff       	call   80103e80 <cpuid>
  pd[0] = size-1;
80106fcf:	ba 2f 00 00 00       	mov    $0x2f,%edx
80106fd4:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80106fda:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80106fde:	c7 80 38 38 11 80 ff 	movl   $0xffff,-0x7feec7c8(%eax)
80106fe5:	ff 00 00 
80106fe8:	c7 80 3c 38 11 80 00 	movl   $0xcf9a00,-0x7feec7c4(%eax)
80106fef:	9a cf 00 
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80106ff2:	c7 80 40 38 11 80 ff 	movl   $0xffff,-0x7feec7c0(%eax)
80106ff9:	ff 00 00 
80106ffc:	c7 80 44 38 11 80 00 	movl   $0xcf9200,-0x7feec7bc(%eax)
80107003:	92 cf 00 
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107006:	c7 80 48 38 11 80 ff 	movl   $0xffff,-0x7feec7b8(%eax)
8010700d:	ff 00 00 
80107010:	c7 80 4c 38 11 80 00 	movl   $0xcffa00,-0x7feec7b4(%eax)
80107017:	fa cf 00 
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010701a:	c7 80 50 38 11 80 ff 	movl   $0xffff,-0x7feec7b0(%eax)
80107021:	ff 00 00 
80107024:	c7 80 54 38 11 80 00 	movl   $0xcff200,-0x7feec7ac(%eax)
8010702b:	f2 cf 00 
  lgdt(c->gdt, sizeof(c->gdt));
8010702e:	05 30 38 11 80       	add    $0x80113830,%eax
  pd[1] = (uint)p;
80107033:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80107037:	c1 e8 10             	shr    $0x10,%eax
8010703a:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010703e:	8d 45 f2             	lea    -0xe(%ebp),%eax
80107041:	0f 01 10             	lgdtl  (%eax)
}
80107044:	c9                   	leave  
80107045:	c3                   	ret    
80107046:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010704d:	8d 76 00             	lea    0x0(%esi),%esi

80107050 <switchkvm>:
{
80107050:	f3 0f 1e fb          	endbr32 
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107054:	a1 44 6f 11 80       	mov    0x80116f44,%eax
80107059:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010705e:	0f 22 d8             	mov    %eax,%cr3
}
80107061:	c3                   	ret    
80107062:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107069:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80107070 <switchuvm>:
{
80107070:	f3 0f 1e fb          	endbr32 
80107074:	55                   	push   %ebp
80107075:	89 e5                	mov    %esp,%ebp
80107077:	57                   	push   %edi
80107078:	56                   	push   %esi
80107079:	53                   	push   %ebx
8010707a:	83 ec 1c             	sub    $0x1c,%esp
8010707d:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80107080:	85 f6                	test   %esi,%esi
80107082:	0f 84 cb 00 00 00    	je     80107153 <switchuvm+0xe3>
  if(p->kstack == 0)
80107088:	8b 46 0c             	mov    0xc(%esi),%eax
8010708b:	85 c0                	test   %eax,%eax
8010708d:	0f 84 da 00 00 00    	je     8010716d <switchuvm+0xfd>
  if(p->pgdir == 0)
80107093:	8b 46 08             	mov    0x8(%esi),%eax
80107096:	85 c0                	test   %eax,%eax
80107098:	0f 84 c2 00 00 00    	je     80107160 <switchuvm+0xf0>
  pushcli();
8010709e:	e8 bd d9 ff ff       	call   80104a60 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801070a3:	e8 68 cd ff ff       	call   80103e10 <mycpu>
801070a8:	89 c3                	mov    %eax,%ebx
801070aa:	e8 61 cd ff ff       	call   80103e10 <mycpu>
801070af:	89 c7                	mov    %eax,%edi
801070b1:	e8 5a cd ff ff       	call   80103e10 <mycpu>
801070b6:	83 c7 08             	add    $0x8,%edi
801070b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801070bc:	e8 4f cd ff ff       	call   80103e10 <mycpu>
801070c1:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801070c4:	ba 67 00 00 00       	mov    $0x67,%edx
801070c9:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
801070d0:	83 c0 08             	add    $0x8,%eax
801070d3:	66 89 93 98 00 00 00 	mov    %dx,0x98(%ebx)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801070da:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801070df:	83 c1 08             	add    $0x8,%ecx
801070e2:	c1 e8 18             	shr    $0x18,%eax
801070e5:	c1 e9 10             	shr    $0x10,%ecx
801070e8:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
801070ee:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
801070f4:	b9 99 40 00 00       	mov    $0x4099,%ecx
801070f9:	66 89 8b 9d 00 00 00 	mov    %cx,0x9d(%ebx)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107100:	bb 10 00 00 00       	mov    $0x10,%ebx
  mycpu()->gdt[SEG_TSS].s = 0;
80107105:	e8 06 cd ff ff       	call   80103e10 <mycpu>
8010710a:	80 a0 9d 00 00 00 ef 	andb   $0xef,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80107111:	e8 fa cc ff ff       	call   80103e10 <mycpu>
80107116:	66 89 58 10          	mov    %bx,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
8010711a:	8b 5e 0c             	mov    0xc(%esi),%ebx
8010711d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80107123:	e8 e8 cc ff ff       	call   80103e10 <mycpu>
80107128:	89 58 0c             	mov    %ebx,0xc(%eax)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
8010712b:	e8 e0 cc ff ff       	call   80103e10 <mycpu>
80107130:	66 89 78 6e          	mov    %di,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80107134:	b8 28 00 00 00       	mov    $0x28,%eax
80107139:	0f 00 d8             	ltr    %ax
  lcr3(V2P(p->pgdir));  // switch to process's address space
8010713c:	8b 46 08             	mov    0x8(%esi),%eax
8010713f:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80107144:	0f 22 d8             	mov    %eax,%cr3
}
80107147:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010714a:	5b                   	pop    %ebx
8010714b:	5e                   	pop    %esi
8010714c:	5f                   	pop    %edi
8010714d:	5d                   	pop    %ebp
  popcli();
8010714e:	e9 5d d9 ff ff       	jmp    80104ab0 <popcli>
    panic("switchuvm: no process");
80107153:	83 ec 0c             	sub    $0xc,%esp
80107156:	68 96 80 10 80       	push   $0x80108096
8010715b:	e8 30 93 ff ff       	call   80100490 <panic>
    panic("switchuvm: no pgdir");
80107160:	83 ec 0c             	sub    $0xc,%esp
80107163:	68 c1 80 10 80       	push   $0x801080c1
80107168:	e8 23 93 ff ff       	call   80100490 <panic>
    panic("switchuvm: no kstack");
8010716d:	83 ec 0c             	sub    $0xc,%esp
80107170:	68 ac 80 10 80       	push   $0x801080ac
80107175:	e8 16 93 ff ff       	call   80100490 <panic>
8010717a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107180 <inituvm>:
{
80107180:	f3 0f 1e fb          	endbr32 
80107184:	55                   	push   %ebp
80107185:	89 e5                	mov    %esp,%ebp
80107187:	57                   	push   %edi
80107188:	56                   	push   %esi
80107189:	53                   	push   %ebx
8010718a:	83 ec 1c             	sub    $0x1c,%esp
8010718d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107190:	8b 75 10             	mov    0x10(%ebp),%esi
80107193:	8b 7d 08             	mov    0x8(%ebp),%edi
80107196:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(sz >= PGSIZE)
80107199:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
8010719f:	77 4b                	ja     801071ec <inituvm+0x6c>
  mem = kalloc();
801071a1:	e8 ba b5 ff ff       	call   80102760 <kalloc>
  memset(mem, 0, PGSIZE);
801071a6:	83 ec 04             	sub    $0x4,%esp
801071a9:	68 00 10 00 00       	push   $0x1000
  mem = kalloc();
801071ae:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
801071b0:	6a 00                	push   $0x0
801071b2:	50                   	push   %eax
801071b3:	e8 b8 da ff ff       	call   80104c70 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801071b8:	58                   	pop    %eax
801071b9:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801071bf:	5a                   	pop    %edx
801071c0:	6a 06                	push   $0x6
801071c2:	b9 00 10 00 00       	mov    $0x1000,%ecx
801071c7:	31 d2                	xor    %edx,%edx
801071c9:	50                   	push   %eax
801071ca:	89 f8                	mov    %edi,%eax
801071cc:	e8 9f fc ff ff       	call   80106e70 <mappages>
  memmove(mem, init, sz);
801071d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801071d4:	89 75 10             	mov    %esi,0x10(%ebp)
801071d7:	83 c4 10             	add    $0x10,%esp
801071da:	89 5d 08             	mov    %ebx,0x8(%ebp)
801071dd:	89 45 0c             	mov    %eax,0xc(%ebp)
}
801071e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801071e3:	5b                   	pop    %ebx
801071e4:	5e                   	pop    %esi
801071e5:	5f                   	pop    %edi
801071e6:	5d                   	pop    %ebp
  memmove(mem, init, sz);
801071e7:	e9 24 db ff ff       	jmp    80104d10 <memmove>
    panic("inituvm: more than a page");
801071ec:	83 ec 0c             	sub    $0xc,%esp
801071ef:	68 d5 80 10 80       	push   $0x801080d5
801071f4:	e8 97 92 ff ff       	call   80100490 <panic>
801071f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80107200 <loaduvm>:
{
80107200:	f3 0f 1e fb          	endbr32 
80107204:	55                   	push   %ebp
80107205:	89 e5                	mov    %esp,%ebp
80107207:	57                   	push   %edi
80107208:	56                   	push   %esi
80107209:	53                   	push   %ebx
8010720a:	83 ec 1c             	sub    $0x1c,%esp
8010720d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107210:	8b 75 18             	mov    0x18(%ebp),%esi
  if((uint) addr % PGSIZE != 0)
80107213:	a9 ff 0f 00 00       	test   $0xfff,%eax
80107218:	0f 85 99 00 00 00    	jne    801072b7 <loaduvm+0xb7>
  for(i = 0; i < sz; i += PGSIZE){
8010721e:	01 f0                	add    %esi,%eax
80107220:	89 f3                	mov    %esi,%ebx
80107222:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107225:	8b 45 14             	mov    0x14(%ebp),%eax
80107228:	01 f0                	add    %esi,%eax
8010722a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(i = 0; i < sz; i += PGSIZE){
8010722d:	85 f6                	test   %esi,%esi
8010722f:	75 15                	jne    80107246 <loaduvm+0x46>
80107231:	eb 6d                	jmp    801072a0 <loaduvm+0xa0>
80107233:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80107237:	90                   	nop
80107238:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
8010723e:	89 f0                	mov    %esi,%eax
80107240:	29 d8                	sub    %ebx,%eax
80107242:	39 c6                	cmp    %eax,%esi
80107244:	76 5a                	jbe    801072a0 <loaduvm+0xa0>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80107246:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107249:	8b 45 08             	mov    0x8(%ebp),%eax
8010724c:	31 c9                	xor    %ecx,%ecx
8010724e:	29 da                	sub    %ebx,%edx
80107250:	e8 9b fb ff ff       	call   80106df0 <walkpgdir>
80107255:	85 c0                	test   %eax,%eax
80107257:	74 51                	je     801072aa <loaduvm+0xaa>
    pa = PTE_ADDR(*pte);
80107259:	8b 00                	mov    (%eax),%eax
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010725b:	8b 4d e0             	mov    -0x20(%ebp),%ecx
    if(sz - i < PGSIZE)
8010725e:	bf 00 10 00 00       	mov    $0x1000,%edi
    pa = PTE_ADDR(*pte);
80107263:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80107268:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
8010726e:	0f 46 fb             	cmovbe %ebx,%edi
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107271:	29 d9                	sub    %ebx,%ecx
80107273:	05 00 00 00 80       	add    $0x80000000,%eax
80107278:	57                   	push   %edi
80107279:	51                   	push   %ecx
8010727a:	50                   	push   %eax
8010727b:	ff 75 10             	pushl  0x10(%ebp)
8010727e:	e8 dd a8 ff ff       	call   80101b60 <readi>
80107283:	83 c4 10             	add    $0x10,%esp
80107286:	39 f8                	cmp    %edi,%eax
80107288:	74 ae                	je     80107238 <loaduvm+0x38>
}
8010728a:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
8010728d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107292:	5b                   	pop    %ebx
80107293:	5e                   	pop    %esi
80107294:	5f                   	pop    %edi
80107295:	5d                   	pop    %ebp
80107296:	c3                   	ret    
80107297:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010729e:	66 90                	xchg   %ax,%ax
801072a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801072a3:	31 c0                	xor    %eax,%eax
}
801072a5:	5b                   	pop    %ebx
801072a6:	5e                   	pop    %esi
801072a7:	5f                   	pop    %edi
801072a8:	5d                   	pop    %ebp
801072a9:	c3                   	ret    
      panic("loaduvm: address should exist");
801072aa:	83 ec 0c             	sub    $0xc,%esp
801072ad:	68 ef 80 10 80       	push   $0x801080ef
801072b2:	e8 d9 91 ff ff       	call   80100490 <panic>
    panic("loaduvm: addr must be page aligned");
801072b7:	83 ec 0c             	sub    $0xc,%esp
801072ba:	68 90 81 10 80       	push   $0x80108190
801072bf:	e8 cc 91 ff ff       	call   80100490 <panic>
801072c4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801072cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801072cf:	90                   	nop

801072d0 <allocuvm>:
{
801072d0:	f3 0f 1e fb          	endbr32 
801072d4:	55                   	push   %ebp
801072d5:	89 e5                	mov    %esp,%ebp
801072d7:	57                   	push   %edi
801072d8:	56                   	push   %esi
801072d9:	53                   	push   %ebx
801072da:	83 ec 1c             	sub    $0x1c,%esp
  if(newsz >= KERNBASE)
801072dd:	8b 45 10             	mov    0x10(%ebp),%eax
{
801072e0:	8b 7d 08             	mov    0x8(%ebp),%edi
  if(newsz >= KERNBASE)
801072e3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801072e6:	85 c0                	test   %eax,%eax
801072e8:	0f 88 c2 00 00 00    	js     801073b0 <allocuvm+0xe0>
  if(newsz < oldsz)
801072ee:	3b 45 0c             	cmp    0xc(%ebp),%eax
    return oldsz;
801072f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(newsz < oldsz)
801072f4:	0f 82 a6 00 00 00    	jb     801073a0 <allocuvm+0xd0>
  a = PGROUNDUP(oldsz);
801072fa:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
80107300:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
80107306:	39 75 10             	cmp    %esi,0x10(%ebp)
80107309:	77 50                	ja     8010735b <allocuvm+0x8b>
8010730b:	e9 93 00 00 00       	jmp    801073a3 <allocuvm+0xd3>
    memset(mem, 0, PGSIZE);
80107310:	83 ec 04             	sub    $0x4,%esp
80107313:	68 00 10 00 00       	push   $0x1000
80107318:	6a 00                	push   $0x0
8010731a:	50                   	push   %eax
8010731b:	e8 50 d9 ff ff       	call   80104c70 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80107320:	58                   	pop    %eax
80107321:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80107327:	5a                   	pop    %edx
80107328:	6a 06                	push   $0x6
8010732a:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010732f:	89 f2                	mov    %esi,%edx
80107331:	50                   	push   %eax
80107332:	89 f8                	mov    %edi,%eax
80107334:	e8 37 fb ff ff       	call   80106e70 <mappages>
80107339:	83 c4 10             	add    $0x10,%esp
8010733c:	85 c0                	test   %eax,%eax
8010733e:	0f 88 84 00 00 00    	js     801073c8 <allocuvm+0xf8>
    myproc()->rss += PGSIZE;
80107344:	e8 57 cb ff ff       	call   80103ea0 <myproc>
  for(; a < newsz; a += PGSIZE){
80107349:	81 c6 00 10 00 00    	add    $0x1000,%esi
    myproc()->rss += PGSIZE;
8010734f:	81 40 04 00 10 00 00 	addl   $0x1000,0x4(%eax)
  for(; a < newsz; a += PGSIZE){
80107356:	39 75 10             	cmp    %esi,0x10(%ebp)
80107359:	76 48                	jbe    801073a3 <allocuvm+0xd3>
    mem = kalloc();
8010735b:	e8 00 b4 ff ff       	call   80102760 <kalloc>
80107360:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
80107362:	85 c0                	test   %eax,%eax
80107364:	75 aa                	jne    80107310 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
80107366:	83 ec 0c             	sub    $0xc,%esp
80107369:	68 0d 81 10 80       	push   $0x8010810d
8010736e:	e8 3d 94 ff ff       	call   801007b0 <cprintf>
  if(newsz >= oldsz)
80107373:	8b 45 0c             	mov    0xc(%ebp),%eax
80107376:	83 c4 10             	add    $0x10,%esp
80107379:	39 45 10             	cmp    %eax,0x10(%ebp)
8010737c:	74 32                	je     801073b0 <allocuvm+0xe0>
8010737e:	8b 55 10             	mov    0x10(%ebp),%edx
80107381:	89 c1                	mov    %eax,%ecx
80107383:	89 f8                	mov    %edi,%eax
80107385:	e8 76 fb ff ff       	call   80106f00 <deallocuvm.part.0>
      return 0;
8010738a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80107391:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107394:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107397:	5b                   	pop    %ebx
80107398:	5e                   	pop    %esi
80107399:	5f                   	pop    %edi
8010739a:	5d                   	pop    %ebp
8010739b:	c3                   	ret    
8010739c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return oldsz;
801073a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
}
801073a3:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801073a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801073a9:	5b                   	pop    %ebx
801073aa:	5e                   	pop    %esi
801073ab:	5f                   	pop    %edi
801073ac:	5d                   	pop    %ebp
801073ad:	c3                   	ret    
801073ae:	66 90                	xchg   %ax,%ax
    return 0;
801073b0:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
801073b7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801073ba:	8d 65 f4             	lea    -0xc(%ebp),%esp
801073bd:	5b                   	pop    %ebx
801073be:	5e                   	pop    %esi
801073bf:	5f                   	pop    %edi
801073c0:	5d                   	pop    %ebp
801073c1:	c3                   	ret    
801073c2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      cprintf("allocuvm out of memory (2)\n");
801073c8:	83 ec 0c             	sub    $0xc,%esp
801073cb:	68 25 81 10 80       	push   $0x80108125
801073d0:	e8 db 93 ff ff       	call   801007b0 <cprintf>
  if(newsz >= oldsz)
801073d5:	8b 45 0c             	mov    0xc(%ebp),%eax
801073d8:	83 c4 10             	add    $0x10,%esp
801073db:	39 45 10             	cmp    %eax,0x10(%ebp)
801073de:	74 0c                	je     801073ec <allocuvm+0x11c>
801073e0:	8b 55 10             	mov    0x10(%ebp),%edx
801073e3:	89 c1                	mov    %eax,%ecx
801073e5:	89 f8                	mov    %edi,%eax
801073e7:	e8 14 fb ff ff       	call   80106f00 <deallocuvm.part.0>
      kfree(mem);
801073ec:	83 ec 0c             	sub    $0xc,%esp
801073ef:	53                   	push   %ebx
801073f0:	e8 7b b1 ff ff       	call   80102570 <kfree>
      return 0;
801073f5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801073fc:	83 c4 10             	add    $0x10,%esp
}
801073ff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80107402:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107405:	5b                   	pop    %ebx
80107406:	5e                   	pop    %esi
80107407:	5f                   	pop    %edi
80107408:	5d                   	pop    %ebp
80107409:	c3                   	ret    
8010740a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107410 <deallocuvm>:
{
80107410:	f3 0f 1e fb          	endbr32 
80107414:	55                   	push   %ebp
80107415:	89 e5                	mov    %esp,%ebp
80107417:	8b 55 0c             	mov    0xc(%ebp),%edx
8010741a:	8b 4d 10             	mov    0x10(%ebp),%ecx
8010741d:	8b 45 08             	mov    0x8(%ebp),%eax
  if(newsz >= oldsz)
80107420:	39 d1                	cmp    %edx,%ecx
80107422:	73 0c                	jae    80107430 <deallocuvm+0x20>
}
80107424:	5d                   	pop    %ebp
80107425:	e9 d6 fa ff ff       	jmp    80106f00 <deallocuvm.part.0>
8010742a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80107430:	89 d0                	mov    %edx,%eax
80107432:	5d                   	pop    %ebp
80107433:	c3                   	ret    
80107434:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010743b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010743f:	90                   	nop

80107440 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80107440:	f3 0f 1e fb          	endbr32 
80107444:	55                   	push   %ebp
80107445:	89 e5                	mov    %esp,%ebp
80107447:	57                   	push   %edi
80107448:	56                   	push   %esi
80107449:	53                   	push   %ebx
8010744a:	83 ec 0c             	sub    $0xc,%esp
8010744d:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80107450:	85 f6                	test   %esi,%esi
80107452:	74 55                	je     801074a9 <freevm+0x69>
  if(newsz >= oldsz)
80107454:	31 c9                	xor    %ecx,%ecx
80107456:	ba 00 00 00 80       	mov    $0x80000000,%edx
8010745b:	89 f0                	mov    %esi,%eax
8010745d:	89 f3                	mov    %esi,%ebx
8010745f:	e8 9c fa ff ff       	call   80106f00 <deallocuvm.part.0>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80107464:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
8010746a:	eb 0b                	jmp    80107477 <freevm+0x37>
8010746c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80107470:	83 c3 04             	add    $0x4,%ebx
80107473:	39 df                	cmp    %ebx,%edi
80107475:	74 23                	je     8010749a <freevm+0x5a>
    if(pgdir[i] & PTE_P){
80107477:	8b 03                	mov    (%ebx),%eax
80107479:	a8 01                	test   $0x1,%al
8010747b:	74 f3                	je     80107470 <freevm+0x30>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010747d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
      kfree(v);
80107482:	83 ec 0c             	sub    $0xc,%esp
80107485:	83 c3 04             	add    $0x4,%ebx
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107488:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
8010748d:	50                   	push   %eax
8010748e:	e8 dd b0 ff ff       	call   80102570 <kfree>
80107493:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107496:	39 df                	cmp    %ebx,%edi
80107498:	75 dd                	jne    80107477 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
8010749a:	89 75 08             	mov    %esi,0x8(%ebp)
}
8010749d:	8d 65 f4             	lea    -0xc(%ebp),%esp
801074a0:	5b                   	pop    %ebx
801074a1:	5e                   	pop    %esi
801074a2:	5f                   	pop    %edi
801074a3:	5d                   	pop    %ebp
  kfree((char*)pgdir);
801074a4:	e9 c7 b0 ff ff       	jmp    80102570 <kfree>
    panic("freevm: no pgdir");
801074a9:	83 ec 0c             	sub    $0xc,%esp
801074ac:	68 41 81 10 80       	push   $0x80108141
801074b1:	e8 da 8f ff ff       	call   80100490 <panic>
801074b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801074bd:	8d 76 00             	lea    0x0(%esi),%esi

801074c0 <setupkvm>:
{
801074c0:	f3 0f 1e fb          	endbr32 
801074c4:	55                   	push   %ebp
801074c5:	89 e5                	mov    %esp,%ebp
801074c7:	56                   	push   %esi
801074c8:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
801074c9:	e8 92 b2 ff ff       	call   80102760 <kalloc>
801074ce:	89 c6                	mov    %eax,%esi
801074d0:	85 c0                	test   %eax,%eax
801074d2:	74 42                	je     80107516 <setupkvm+0x56>
  memset(pgdir, 0, PGSIZE);
801074d4:	83 ec 04             	sub    $0x4,%esp
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801074d7:	bb 20 b4 10 80       	mov    $0x8010b420,%ebx
  memset(pgdir, 0, PGSIZE);
801074dc:	68 00 10 00 00       	push   $0x1000
801074e1:	6a 00                	push   $0x0
801074e3:	50                   	push   %eax
801074e4:	e8 87 d7 ff ff       	call   80104c70 <memset>
801074e9:	83 c4 10             	add    $0x10,%esp
                (uint)k->phys_start, k->perm) < 0) {
801074ec:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801074ef:	83 ec 08             	sub    $0x8,%esp
801074f2:	8b 4b 08             	mov    0x8(%ebx),%ecx
801074f5:	ff 73 0c             	pushl  0xc(%ebx)
801074f8:	8b 13                	mov    (%ebx),%edx
801074fa:	50                   	push   %eax
801074fb:	29 c1                	sub    %eax,%ecx
801074fd:	89 f0                	mov    %esi,%eax
801074ff:	e8 6c f9 ff ff       	call   80106e70 <mappages>
80107504:	83 c4 10             	add    $0x10,%esp
80107507:	85 c0                	test   %eax,%eax
80107509:	78 15                	js     80107520 <setupkvm+0x60>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010750b:	83 c3 10             	add    $0x10,%ebx
8010750e:	81 fb 60 b4 10 80    	cmp    $0x8010b460,%ebx
80107514:	75 d6                	jne    801074ec <setupkvm+0x2c>
}
80107516:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107519:	89 f0                	mov    %esi,%eax
8010751b:	5b                   	pop    %ebx
8010751c:	5e                   	pop    %esi
8010751d:	5d                   	pop    %ebp
8010751e:	c3                   	ret    
8010751f:	90                   	nop
      freevm(pgdir);
80107520:	83 ec 0c             	sub    $0xc,%esp
80107523:	56                   	push   %esi
      return 0;
80107524:	31 f6                	xor    %esi,%esi
      freevm(pgdir);
80107526:	e8 15 ff ff ff       	call   80107440 <freevm>
      return 0;
8010752b:	83 c4 10             	add    $0x10,%esp
}
8010752e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80107531:	89 f0                	mov    %esi,%eax
80107533:	5b                   	pop    %ebx
80107534:	5e                   	pop    %esi
80107535:	5d                   	pop    %ebp
80107536:	c3                   	ret    
80107537:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010753e:	66 90                	xchg   %ax,%ax

80107540 <kvmalloc>:
{
80107540:	f3 0f 1e fb          	endbr32 
80107544:	55                   	push   %ebp
80107545:	89 e5                	mov    %esp,%ebp
80107547:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010754a:	e8 71 ff ff ff       	call   801074c0 <setupkvm>
8010754f:	a3 44 6f 11 80       	mov    %eax,0x80116f44
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80107554:	05 00 00 00 80       	add    $0x80000000,%eax
80107559:	0f 22 d8             	mov    %eax,%cr3
}
8010755c:	c9                   	leave  
8010755d:	c3                   	ret    
8010755e:	66 90                	xchg   %ax,%ax

80107560 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107560:	f3 0f 1e fb          	endbr32 
80107564:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107565:	31 c9                	xor    %ecx,%ecx
{
80107567:	89 e5                	mov    %esp,%ebp
80107569:	83 ec 08             	sub    $0x8,%esp
  pte = walkpgdir(pgdir, uva, 0);
8010756c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010756f:	8b 45 08             	mov    0x8(%ebp),%eax
80107572:	e8 79 f8 ff ff       	call   80106df0 <walkpgdir>
  if(pte == 0)
80107577:	85 c0                	test   %eax,%eax
80107579:	74 05                	je     80107580 <clearpteu+0x20>
    panic("clearpteu");
  *pte &= ~PTE_U;
8010757b:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010757e:	c9                   	leave  
8010757f:	c3                   	ret    
    panic("clearpteu");
80107580:	83 ec 0c             	sub    $0xc,%esp
80107583:	68 52 81 10 80       	push   $0x80108152
80107588:	e8 03 8f ff ff       	call   80100490 <panic>
8010758d:	8d 76 00             	lea    0x0(%esi),%esi

80107590 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107590:	f3 0f 1e fb          	endbr32 
80107594:	55                   	push   %ebp
80107595:	89 e5                	mov    %esp,%ebp
80107597:	57                   	push   %edi
80107598:	56                   	push   %esi
80107599:	53                   	push   %ebx
8010759a:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010759d:	e8 1e ff ff ff       	call   801074c0 <setupkvm>
801075a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
801075a5:	85 c0                	test   %eax,%eax
801075a7:	0f 84 9b 00 00 00    	je     80107648 <copyuvm+0xb8>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801075ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801075b0:	85 c9                	test   %ecx,%ecx
801075b2:	0f 84 90 00 00 00    	je     80107648 <copyuvm+0xb8>
801075b8:	31 f6                	xor    %esi,%esi
801075ba:	eb 46                	jmp    80107602 <copyuvm+0x72>
801075bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801075c0:	83 ec 04             	sub    $0x4,%esp
801075c3:	81 c7 00 00 00 80    	add    $0x80000000,%edi
801075c9:	68 00 10 00 00       	push   $0x1000
801075ce:	57                   	push   %edi
801075cf:	50                   	push   %eax
801075d0:	e8 3b d7 ff ff       	call   80104d10 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801075d5:	58                   	pop    %eax
801075d6:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801075dc:	5a                   	pop    %edx
801075dd:	ff 75 e4             	pushl  -0x1c(%ebp)
801075e0:	b9 00 10 00 00       	mov    $0x1000,%ecx
801075e5:	89 f2                	mov    %esi,%edx
801075e7:	50                   	push   %eax
801075e8:	8b 45 e0             	mov    -0x20(%ebp),%eax
801075eb:	e8 80 f8 ff ff       	call   80106e70 <mappages>
801075f0:	83 c4 10             	add    $0x10,%esp
801075f3:	85 c0                	test   %eax,%eax
801075f5:	78 61                	js     80107658 <copyuvm+0xc8>
  for(i = 0; i < sz; i += PGSIZE){
801075f7:	81 c6 00 10 00 00    	add    $0x1000,%esi
801075fd:	39 75 0c             	cmp    %esi,0xc(%ebp)
80107600:	76 46                	jbe    80107648 <copyuvm+0xb8>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80107602:	8b 45 08             	mov    0x8(%ebp),%eax
80107605:	31 c9                	xor    %ecx,%ecx
80107607:	89 f2                	mov    %esi,%edx
80107609:	e8 e2 f7 ff ff       	call   80106df0 <walkpgdir>
8010760e:	85 c0                	test   %eax,%eax
80107610:	74 61                	je     80107673 <copyuvm+0xe3>
    if(!(*pte & PTE_P))
80107612:	8b 00                	mov    (%eax),%eax
80107614:	a8 01                	test   $0x1,%al
80107616:	74 4e                	je     80107666 <copyuvm+0xd6>
    pa = PTE_ADDR(*pte);
80107618:	89 c7                	mov    %eax,%edi
    flags = PTE_FLAGS(*pte);
8010761a:	25 ff 0f 00 00       	and    $0xfff,%eax
8010761f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    pa = PTE_ADDR(*pte);
80107622:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    if((mem = kalloc()) == 0)
80107628:	e8 33 b1 ff ff       	call   80102760 <kalloc>
8010762d:	89 c3                	mov    %eax,%ebx
8010762f:	85 c0                	test   %eax,%eax
80107631:	75 8d                	jne    801075c0 <copyuvm+0x30>
    }
  }
  return d;

bad:
  freevm(d);
80107633:	83 ec 0c             	sub    $0xc,%esp
80107636:	ff 75 e0             	pushl  -0x20(%ebp)
80107639:	e8 02 fe ff ff       	call   80107440 <freevm>
  return 0;
8010763e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
80107645:	83 c4 10             	add    $0x10,%esp
}
80107648:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010764b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010764e:	5b                   	pop    %ebx
8010764f:	5e                   	pop    %esi
80107650:	5f                   	pop    %edi
80107651:	5d                   	pop    %ebp
80107652:	c3                   	ret    
80107653:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80107657:	90                   	nop
      kfree(mem);
80107658:	83 ec 0c             	sub    $0xc,%esp
8010765b:	53                   	push   %ebx
8010765c:	e8 0f af ff ff       	call   80102570 <kfree>
      goto bad;
80107661:	83 c4 10             	add    $0x10,%esp
80107664:	eb cd                	jmp    80107633 <copyuvm+0xa3>
      panic("copyuvm: page not present");
80107666:	83 ec 0c             	sub    $0xc,%esp
80107669:	68 76 81 10 80       	push   $0x80108176
8010766e:	e8 1d 8e ff ff       	call   80100490 <panic>
      panic("copyuvm: pte should exist");
80107673:	83 ec 0c             	sub    $0xc,%esp
80107676:	68 5c 81 10 80       	push   $0x8010815c
8010767b:	e8 10 8e ff ff       	call   80100490 <panic>

80107680 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107680:	f3 0f 1e fb          	endbr32 
80107684:	55                   	push   %ebp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80107685:	31 c9                	xor    %ecx,%ecx
{
80107687:	89 e5                	mov    %esp,%ebp
80107689:	83 ec 08             	sub    $0x8,%esp
  pte = walkpgdir(pgdir, uva, 0);
8010768c:	8b 55 0c             	mov    0xc(%ebp),%edx
8010768f:	8b 45 08             	mov    0x8(%ebp),%eax
80107692:	e8 59 f7 ff ff       	call   80106df0 <walkpgdir>
  if((*pte & PTE_P) == 0)
80107697:	8b 00                	mov    (%eax),%eax
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
80107699:	c9                   	leave  
  if((*pte & PTE_U) == 0)
8010769a:	89 c2                	mov    %eax,%edx
  return (char*)P2V(PTE_ADDR(*pte));
8010769c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((*pte & PTE_U) == 0)
801076a1:	83 e2 05             	and    $0x5,%edx
  return (char*)P2V(PTE_ADDR(*pte));
801076a4:	05 00 00 00 80       	add    $0x80000000,%eax
801076a9:	83 fa 05             	cmp    $0x5,%edx
801076ac:	ba 00 00 00 00       	mov    $0x0,%edx
801076b1:	0f 45 c2             	cmovne %edx,%eax
}
801076b4:	c3                   	ret    
801076b5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801076bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801076c0 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801076c0:	f3 0f 1e fb          	endbr32 
801076c4:	55                   	push   %ebp
801076c5:	89 e5                	mov    %esp,%ebp
801076c7:	57                   	push   %edi
801076c8:	56                   	push   %esi
801076c9:	53                   	push   %ebx
801076ca:	83 ec 0c             	sub    $0xc,%esp
801076cd:	8b 75 14             	mov    0x14(%ebp),%esi
801076d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801076d3:	85 f6                	test   %esi,%esi
801076d5:	75 3c                	jne    80107713 <copyout+0x53>
801076d7:	eb 67                	jmp    80107740 <copyout+0x80>
801076d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
801076e0:	8b 55 0c             	mov    0xc(%ebp),%edx
801076e3:	89 fb                	mov    %edi,%ebx
801076e5:	29 d3                	sub    %edx,%ebx
801076e7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
801076ed:	39 f3                	cmp    %esi,%ebx
801076ef:	0f 47 de             	cmova  %esi,%ebx
      n = len;
    memmove(pa0 + (va - va0), buf, n);
801076f2:	29 fa                	sub    %edi,%edx
801076f4:	83 ec 04             	sub    $0x4,%esp
801076f7:	01 c2                	add    %eax,%edx
801076f9:	53                   	push   %ebx
801076fa:	ff 75 10             	pushl  0x10(%ebp)
801076fd:	52                   	push   %edx
801076fe:	e8 0d d6 ff ff       	call   80104d10 <memmove>
    len -= n;
    buf += n;
80107703:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
80107706:	8d 97 00 10 00 00    	lea    0x1000(%edi),%edx
  while(len > 0){
8010770c:	83 c4 10             	add    $0x10,%esp
8010770f:	29 de                	sub    %ebx,%esi
80107711:	74 2d                	je     80107740 <copyout+0x80>
    va0 = (uint)PGROUNDDOWN(va);
80107713:	89 d7                	mov    %edx,%edi
    pa0 = uva2ka(pgdir, (char*)va0);
80107715:	83 ec 08             	sub    $0x8,%esp
    va0 = (uint)PGROUNDDOWN(va);
80107718:	89 55 0c             	mov    %edx,0xc(%ebp)
8010771b:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    pa0 = uva2ka(pgdir, (char*)va0);
80107721:	57                   	push   %edi
80107722:	ff 75 08             	pushl  0x8(%ebp)
80107725:	e8 56 ff ff ff       	call   80107680 <uva2ka>
    if(pa0 == 0)
8010772a:	83 c4 10             	add    $0x10,%esp
8010772d:	85 c0                	test   %eax,%eax
8010772f:	75 af                	jne    801076e0 <copyout+0x20>
  }
  return 0;
}
80107731:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80107734:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107739:	5b                   	pop    %ebx
8010773a:	5e                   	pop    %esi
8010773b:	5f                   	pop    %edi
8010773c:	5d                   	pop    %ebp
8010773d:	c3                   	ret    
8010773e:	66 90                	xchg   %ax,%ax
80107740:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80107743:	31 c0                	xor    %eax,%eax
}
80107745:	5b                   	pop    %ebx
80107746:	5e                   	pop    %esi
80107747:	5f                   	pop    %edi
80107748:	5d                   	pop    %ebp
80107749:	c3                   	ret    
