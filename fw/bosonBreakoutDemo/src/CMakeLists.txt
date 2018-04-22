
set(BIN_HEADERS
	bosonBreakout/hw.h
	bosonBreakout/gpio.h
)

set(BIN_SOURCE
	startup_samd51.c 
	system_samd51.c 
	bosonBreakout/main.cpp
	bosonBreakout/gen_bitstream.cpp
)

cm0_add_executable(bosonBreakout ${BIN_SOURCE} ${BIN_HEADERS})

include_directories(
  ${PROJECT_SOURCE_DIR}/include
)



