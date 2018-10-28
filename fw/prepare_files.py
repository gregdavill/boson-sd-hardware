#!/usr/bin/python

import sys
import zlib

def crc32(crc, data):
    return zlib.crc32(data,crc)

def calc_crc(out_file, array):
	crc = 0x00000000
	crc = crc32(crc,array)

	print('Combined CRC:', format(crc, '08x'))
	for i in range(4):
		b = (crc >> (8*i)) & 0xFF
		out_file.write(bytes([b]))
	return

def append(in_filename, pad_length):
    # Append binary data into output file with fixed padding
	with open(in_filename, 'rb') as file:
		array = file.read()
    
	print('Size:', format(len(array), '05x'), 'Adding', format((pad_length - len(array)), '05x'), 'padding bytes' )
	array += bytes( [ 0xAA ] * (pad_length - len(array)))
	return array

if len(sys.argv) != 4:
    print("Usage: <bitstream> <bootloader> <firmware>")
    sys.exit()

output_data = append(sys.argv[1], 0x90000-8)
output_data += append(sys.argv[2], 0x10000)
output_data += append(sys.argv[3], 0x20000)

with open('bosonFirmware.bin', 'wb') as outfile:
	calc_crc(outfile, output_data)
	outfile.write(output_data)
