#!/usr/bin/python

import sys
import zlib

def crc32(crc, data):
	crc = zlib.crc32(data,crc)
	print('Combined CRC:', format(crc, '08x'))
	return crc

#crc = crc32(0,   bytes([0x00,0x00,0x00,0x00]))
#crc = crc32(0, bytes([0x01,0x02,0x03,0x04]))
#crc = crc32(0, bytes([0x04,0x03,0x02,0x01]))

with open("bosonFirmware.bin", 'rb') as file:
		crc = crc32(0, file.read()[8:12])
