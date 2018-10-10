#!/usr/bin/python

import sys

if len(sys.argv) != 4:
    print("Usage: <bitstream> <bootloader> <firmware>")
    sys.exit()

def append(out_file, in_filename, pad_length):
    # Append binary data into output file with fixed padding
    with open(in_filename, 'rb') as file:
        array = file.read()
        array += bytes( [ 0xAA ] * (pad_length - len(array)))
        out_file.write(array)
    return


with open('bosonFirmware.bin', 'wb') as outfile:
    append(outfile, sys.argv[1], 0x90000)
    append(outfile, sys.argv[2], 0x10000)
    append(outfile, sys.argv[3], 0x20000)



def crc16_ccitt(crc, data):
    msb = crc >> 8
    lsb = crc & 255
    for c in data:
        x = ord(c) ^ msb
        x ^= (x >> 4)
        msb = (lsb ^ (x >> 3) ^ (x << 4)) & 255
        lsb = (x ^ (x << 5)) & 255
    return (msb << 8) + lsb