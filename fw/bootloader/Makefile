
bootloader.elf: sections.lds start.s bootloader.c uart.c FatFs/ff.c FatFs/ff.h FatFs/ffconf.h FatFs/sdmmc.c FatFs/diskio.h FatFs/ffunicode.c
	riscv32-unknown-elf-gcc -march=rv32imc -Xlinker -Map=output.map -Wl,-Bstatic,-T,sections.lds,--no-check-sections -fpack-struct -ffreestanding -nostartfiles -g -o bootloader.elf start.s bootloader.c uart.c FatFs/ff.c FatFs/sdmmc.c FatFs/ffunicode.c
	riscv32-unknown-elf-size bootloader.elf

bootloader.hex: bootloader.elf
	riscv32-unknown-elf-objcopy -O verilog bootloader.elf bootloader.hex

bootloader.lst: bootloader.elf
	riscv32-unknown-elf-objdump -d -F -r -S -l bootloader.elf > bootloader.lst 

bootloader.bin: bootloader.elf
	riscv32-unknown-elf-objcopy --pad-to 0xA0000 -O binary bootloader.elf bootloader.bin

clean:
	rm -f bootloader.elf bootloader.hex bootloader.bin bootloader.lst

