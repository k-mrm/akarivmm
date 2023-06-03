PREFIX =
CC = $(PREFIX)gcc
LD = $(PREFIX)ld
OBJCOPY = $(PREFIX)objcopy

CFLAGS = -Wall -Og -g -MD -ffreestanding -nostdinc -nostdlib -nostartfiles
CFLAGS += -I ./include/

QEMUPREFIX =
QEMU = $(QEMUPREFIX)qemu-system-x86_64

ifndef NCPU
NCPU = 1
endif

%.o: %.c
	@echo CC $@
	$(CC) $(CFLAGS) -c $< -o $@

%.o: %.S
	@echo CC $@
	$(CC) $(CFLAGS) -c $< -o $@

bootblock: boot/boot.o

vmm.img: bootblock

clean:
	$(RM)

qemu: vmm.img
	$(QEMU) -nographic -drive file=vmm.img,index=0,media=disk,format=raw -smp $(NCPU) -m 512

.PHONY: clean qemu
