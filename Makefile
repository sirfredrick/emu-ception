.POSIX:
.SUFFIXES:
OUTDIR=build
include $(OUTDIR)/config.mk

all: sd.raw vbagx-wii
vbagx-wii:
	cd vbagx && env DEVKITPRO=$(DKPDIR) DEVKITPPC=$(DKPDIR)/devkitPPC $(MAKE) wii
	cp vbagx/executables/vbagx-wii.elf $(OUTDIR)/vbagx-wii.elf
	cp vbagx/executables/vbagx-wii.dol $(OUTDIR)/vbagx-wii.dol
vbagx-gc:
	cd vbagx && env DEVKITPRO=$(DKPDIR) DEVKITPPC=$(DKPDIR)/devkitPPC $(MAKE) gc
	cp vbagx/executables/vbagx-gc.elf $(OUTDIR)/vbagx-gc.elf
	cp vbagx/executables/vbagx-gc.dol $(OUTDIR)/vbagx-gc.dol
sd.raw: chip.gba
	cd $(OUTDIR) && dd if=/dev/zero bs=1M count=128 of=sd.raw
	cd $(OUTDIR) && mformat -F -i sd.raw ::
	cd $(OUTDIR) && mcopy -i sd.raw chip.gba ::
chip.gba: NES-CHIP-8/chip.nes pocketnes/pocketnes.gba romlist.txt
	cat pocketnes/pocketnes.gba romlist.txt NES-CHIP-8/chip.nes > $(OUTDIR)/$@
pocketnes/pocketnes.gba:
	cd pocketnes && env DEVKITPRO=$(DKPDIR) DEVKITARM=$(DKPDIR)/devkitARM $(MAKE)
NES-CHIP-8/chip.nes: NES-CHIP-8/chip.o NES-CHIP-8/nrom128.x
	$(LD) $(LDFLAGS) NES-CHIP-8/nrom128.x NES-CHIP-8/chip.o -o $@
NES-CHIP-8/chip.o: NES-CHIP-8/chip.s NES-CHIP-8/chip.lst NES-CHIP-8/pong.ch8
	$(AS) NES-CHIP-8/chip.s -l NES-CHIP-8/chip.lst -o $@
clean:
	rm -f NES-CHIP-8/*.o NES-CHIP-8/*.nes
	cd pocketnes && env DEVKITPRO=$(DKPDIR) DEVKITARM=$(DKPDIR)/devkitARM $(MAKE) clean
	cd vbagx && env DEVKITPRO=$(DKPDIR) DEVKITPPC=$(DKPDIR)/devkitPPC $(MAKE) clean
	cd $(OUTDIR) && rm -f *.gba *.elf *.dol *.raw
mrproper: clean
	rm -rf $(OUTDIR)
