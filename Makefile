PREFIX =
CC = $(PREFIX)gcc
LD = $(PREFIX)ld
OBJCOPY = $(PREFIX)objcopy

CFLAGS = -Wall -Og -g -MD -ffreestanding -nostdinc -nostdlib -nostartfiles
CFLAGS += -I ./include/
LDFLAGS =

QEMUPREFIX =
QEMU = $(QEMUPREFIX)qemu-system-x86_64

ifndef NCPU
NCPU = 1
endif

ifndef MEMSZ
MEMSZ = 512
endif

C = core/
OBJS = $(C)entry.o $(C)main.o

%.o: %.c
	@echo CC $@
	@$(CC) $(CFLAGS) -c $< -o $@

%.o: %.S
	@echo CC $@
	@$(CC) $(CFLAGS) -c $< -o $@

bootblock: boot/boot.o

vmm.elf: $(OBJS) link.ld
	@echo LD $@
	@$(LD) -n $(LDFLAGS) -T link.ld -o $@ $(OBJS)

vmm.img: bootblock vmm.elf

vmm.iso: vmm.elf boot/grub.cfg
	@mkdir -p iso/boot/grub
	@cp boot/grub.cfg iso/boot/grub
	@cp vmm.elf iso/boot/
	@grub-mkrescue -o $@ iso/

clean:
	$(RM) $(OBJS) vmm.elf vmm.iso
	$(RM) -rf iso/

qemu-img: vmm.img
	$(QEMU) -nographic -drive file=vmm.img,index=0,media=disk,format=raw -smp $(NCPU) -m $(MEMSZ)

qemu-iso: vmm.iso
	$(QEMU) -nographic -drive file=vmm.iso,format=raw -smp $(NCPU) -m $(MEMSZ)

.PHONY: clean qemu
