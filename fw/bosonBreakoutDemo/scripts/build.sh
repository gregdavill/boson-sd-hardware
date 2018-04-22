#!/bin/bash

echo -n "extern const " > ./src/bosonBreakout/gen_bitstream.cpp
xxd -i ../hyperRAM_FIFO/hyperRAM_FIFO/hyperRAM_FIFO_Implmnt/sbt/outputs/bitmap/bosonBreakoutTest_bitmap.bin >> ./src/bosonBreakout/gen_bitstream.cpp
ninja -C kbuild