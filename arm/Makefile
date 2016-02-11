#ARCH=none-eabi
#ARCH=linux-gnueabi
ARCH=linux-gnueabihf

AS=arm-$(ARCH)-as
LD=arm-$(ARCH)-ld
ASFLAGS=-g
LDFLAGS=
SOURCES=prog3a.s prog7a.s loop1.s prog8b.s count.s count-stdin.s
OBJECTS=$(SOURCES:.s=.o)
EXECUTABLES=$(SOURCES:.s=)

all: $(SOURCES) $(EXECUTABLES)

$(EXECUTABLES): $(OBJECTS)
	$(LD) $(LDFLAGS) $@.o -o $@

.s.o:
	$(AS) $(ASFLAGS) $< -o $@

clean:
	rm -f $(OBJECTS)
	rm -f $(EXECUTABLES)
