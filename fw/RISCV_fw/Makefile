
firmware.elf: sections.lds start.s firmware.c FatFs/ff.c FatFs/ff.h FatFs/ffconf.h FatFs/sdmmc.c FatFs/diskio.h FatFs/ffunicode.c
	riscv32-unknown-elf-gcc -march=rv32imc -Wl,-Bstatic,-T,sections.lds,--strip-debug,--no-check-sections -ffreestanding -nostartfiles  -o firmware.elf start.s firmware.c FatFs/ff.c FatFs/sdmmc.c FatFs/ffunicode.c

firmware.hex: firmware.elf
	riscv32-unknown-elf-objcopy -O verilog firmware.elf firmware.hex

firmware.bin: firmware.elf
	riscv32-unknown-elf-objcopy --pad-to 0xA0000 -O binary firmware.elf firmware.bin

clean:
	rm -f firmware.elf firmware.hex firmware.bin

