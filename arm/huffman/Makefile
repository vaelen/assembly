#ARCH=none-eabi
#ARCH=linux-gnueabi
ARCH=linux-gnueabihf

AS=arm-$(ARCH)-as
LD=arm-$(ARCH)-ld
ASFLAGS=-g
LDFLAGS=
OBJECTS=syscalls.o numbers.o strings.o files.o errors.o count.o program.o
TEST_SORT_OBJECTS=syscalls.o numbers.o strings.o sort.o test-sort.o
TEST_COUNT_OBJECTS=syscalls.o numbers.o strings.o files.o errors.o count.o test-count.o
TEST_HEAP_OBJECTS=syscalls.o numbers.o strings.o heap.o heap-print.o test-heap.o 

all: huffman tests

huffman: $(OBJECTS)
	$(LD) $(LDFLAGS) $(OBJECTS) -o $@

tests: test-count test-sort test-heap

test-count: $(TEST_COUNT_OBJECTS)
	$(LD) $(LDFLAGS) $(TEST_COUNT_OBJECTS) -o $@

test-sort: $(TEST_SORT_OBJECTS)
	$(LD) $(LDFLAGS) $(TEST_SORT_OBJECTS) -o $@

test-heap: $(TEST_HEAP_OBJECTS)
	$(LD) $(LDFLAGS) $(TEST_HEAP_OBJECTS) -o $@

.o:
	$(AS) $(ASFLAGS) $<.s -o $@

clean:
	rm -f *.o
	rm -f huffman
	rm -f test-sort
	rm -f test-count
	rm -f test-heap
