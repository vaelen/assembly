ARCH=none-eabi
#ARCH=linux-gnueabi
#ARCH=linux-gnueabihf

AS=arm-$(ARCH)-as
LD=arm-$(ARCH)-ld
LDFLAGS=
SOURCES=prog3a.s
OBJECTS=$(SOURCES:.s=.o)
EXECUTABLES=$(SOURCES:.s=)

all: $(SOURCES) $(EXECUTABLES)

$(EXECUTABLES): $(OBJECTS)
	$(LD) $(LDFLAGS) $(OBJECTS) -o $@

.s.o:
	$(AS) $< -o $@

clean:
	rm $(OBJECTS)
	rm $(EXECUTABLES)
