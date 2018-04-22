find_program(CM0_CC arm-none-eabi-gcc)
find_program(CM0_CXX arm-none-eabi-g++)
find_program(CM0_OBJCOPY arm-none-eabi-objcopy)
find_program(CM0_SIZE_TOOL arm-none-eabi-size)
find_program(CM0_OBJDUMP arm-none-eabi-objdump)


# Add global includes to project. These are device headers + CMSIS headers
include_directories(
	"${CMAKE_SOURCE_DIR}/include/atmel"
	"${CMAKE_SOURCE_DIR}/include/CMSIS/include"
	"${CMAKE_SOURCE_DIR}/src/clockController"
	"${CMAKE_SOURCE_DIR}/src/Adafruit-GFX-Library"
)

set(linker_file
	"-T${CMAKE_SOURCE_DIR}/src/samd51g19a_flash.ld"
)

#----------------------------------------------------------------------------
set(CM0_CC_FLAGS "\    
    -Os \
    -g3 \
    -Wall \
    -c \
    -fdata-sections \
    -ffunction-sections \
    -ffreestanding \
    -fno-exceptions \
    -nostartfiles \
    -mthumb \
    -mcpu=cortex-m0plus \
	-D__SAMD11D14AM__ \
    -DARM \
    -DUSE_STDPERIPH_DRIVER \
    -D__CHECK_DEVICE_DEFINES \
    -DUSE_FULL_ASSERT \
	-DBUILD_TIMESTAMP=${timestamp} \
    -fmessage-length=0 \
	-fdiagnostics-color=always \
    ")

set(CM0_CXX_FLAGS "\
    -Os \
    -g3 \
    -Wall \
    -c \
    -fdata-sections \
    -ffunction-sections \
    -ffreestanding \
    -fno-exceptions \
    -nostartfiles \
    -mthumb \
    -mcpu=cortex-m4 \
	-D__SAMD51G19A__ \
    -DARM \
    -DUSE_STDPERIPH_DRIVER \
    -D__CHECK_DEVICE_DEFINES \
    -DUSE_FULL_ASSERT \
	-DBUILD_TIMESTAMP=${timestamp} \
    -fmessage-length=0 \
	-fdiagnostics-color=always \
    ")

set(CM0_LN_FLAGS "\
    --specs=nosys.specs \
	--specs=nano.specs \
    --disable-newlib-supplied-syscalls \
    -Wl,--start-group \
    -Wl,-lm \
    -Wl,--end-group \
    -Wl,--gc-sections \
    -mthumb \
    -mcpu=cortex-m4 \
	${linker_file} \
    ")
    
set(CM0_LN_DBG_FLAGS "\
    --specs=nosys.specs \
	--specs=nano.specs \
    --disable-newlib-supplied-syscalls \
    -Wl,--start-group \
    -Wl,-lm \
    -Wl,--end-group \
    -mthumb \
    -mcpu=cortex-m4 \
	${linker_file} \
    ")
    
set(CM0_OBJCOPY_FLAGS
    -O ihex -R .eeprom -R .fuse -R .lock -R .signature
    )
    
set(CM0_OBJCOPY_DBG_FLAGS
    --only-section=.logger -O binary --set-section-flags .logger=alloc --change-section-address .logger=0
    )

#----------------------------------------------------------------------------
set_property(GLOBAL PROPERTY global_cc "${CM0_CC}")
set_property(GLOBAL PROPERTY global_cxx "${CM0_CXX}")
set_property(GLOBAL PROPERTY global_objcopy "${CM0_OBJCOPY}")
set_property(GLOBAL PROPERTY global_objdump "${CM0_OBJDUMP}")
set_property(GLOBAL PROPERTY global_size "${CM0_SIZE_TOOL}")
set_property(GLOBAL PROPERTY global_cc_flags "${CM0_CC_FLAGS}")
set_property(GLOBAL PROPERTY global_cxx_flags "${CM0_CXX_FLAGS}")
set_property(GLOBAL PROPERTY global_ln_flags "${CM0_LN_FLAGS}")
set_property(GLOBAL PROPERTY global_ln_dbg_flags "${CM0_LN_DBG_FLAGS}")
set_property(GLOBAL PROPERTY global_objcopy_flags "${CM0_OBJCOPY_FLAGS}")
set_property(GLOBAL PROPERTY global_objcopy_dbg_flags "${CM0_OBJCOPY_DBG_FLAGS}")
