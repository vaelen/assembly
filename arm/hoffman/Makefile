#ARCH=none-eabi
#ARCH=linux-gnueabi
ARCH=linux-gnueabihf

AS=arm-$(ARCH)-as
LD=arm-$(ARCH)-ld
ASFLAGS=-g
LDFLAGS=
OBJECTS=strings.o errors.o count.o program.o

all: hoffman

hoffman: $(OBJECTS)
	$(LD) $(LDFLAGS) $(OBJECTS) -o $@

.o:
	$(AS) $(ASFLAGS) $<.s -o $@

clean:
	rm -f *.o
	rm -f hoffman
