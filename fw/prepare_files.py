#!/usr/bin/python

import sys

def crc16_ccitt(crc, data):
    msb = crc >> 8
    lsb = crc & 255
    for c in data:
        x = c ^ msb
        x ^= (x >> 4)
        msb = (lsb ^ (x >> 3) ^ (x << 4)) & 255
        lsb = (x ^ (x << 5)) & 255
    return (msb << 8) + lsb

def calc_crc(out_file, input_files):
	crc = 0
	for f in input_files:
		with open(f, 'rb') as file:
			crc = crc16_ccitt(crc, file.read())

	print('Combined CRC:', format(crc, '04x'))
	out_file.write(bytes([crc >> 8, crc & 255]))
	return

def append(out_file, in_filename, pad_length):
    # Append binary data into output file with fixed padding
    with open(in_filename, 'rb') as file:
        array = file.read()
        print('Size:', format(len(array), '05x'), 'Adding', format((pad_length - len(array)), '05x'), 'padding bytes' )
        array += bytes( [ 0xAA ] * (pad_length - len(array)))
        out_file.write(array)
    return

if len(sys.argv) != 4:
    print("Usage: <bitstream> <bootloader> <firmware>")
    sys.exit()

with open('bosonFirmware.bin', 'wb') as outfile:
    calc_crc(outfile, [sys.argv[1],sys.argv[2],sys.argv[3]])
    append(outfile, sys.argv[1], 0x90000-2)
    append(outfile, sys.argv[2], 0x10000)
    append(outfile, sys.argv[3], 0x20000)
