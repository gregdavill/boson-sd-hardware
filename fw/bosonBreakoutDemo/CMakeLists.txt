cmake_minimum_required(VERSION 2.8.7 FATAL_ERROR)
project(clockController)

if($ENV{BUILD_NUMBER})
  set(BUILD_NUMBER $ENV{BUILD_NUMBER})
else()
  set(BUILD_NUMBER 0)
endif()

set(CLOCKCONTROLLER_NAME "bosonBreakout")
set(CLOCKCONTROLLER_VERSION "0.0.0.${BUILD_NUMBER}")
set(CLOCKCONTROLLER_BRIEF "${MYPROJECT_NAME} is a simple C++ project targeting the SAMD11. Implements I2C and RS485 to display a clock on a flip dot display")

include("rules.cmake")
include("platform.cmake")


get_property(cm0_cc GLOBAL PROPERTY global_cc)
get_property(cm0_cxx GLOBAL PROPERTY global_cxx)
get_property(cm0_objcopy GLOBAL PROPERTY global_objcopy)
get_property(cm0_objdump GLOBAL PROPERTY global_objdump)
get_property(cm0_size GLOBAL PROPERTY global_size)
get_property(cm0_cc_flags GLOBAL PROPERTY global_cc_flags)
get_property(cm0_cxx_flags GLOBAL PROPERTY global_cxx_flags)
get_property(cm0_ln_flags GLOBAL PROPERTY global_ln_flags)
get_property(cm0_ln_dbg_flags GLOBAL PROPERTY global_ln_dbg_flags)
get_property(cm0_objcopy_flags GLOBAL PROPERTY global_objcopy_flags)
get_property(cm0_objcopy_dbg_flags GLOBAL PROPERTY global_objcopy_dbg_flags)

set(CMAKE_SHARED_LIBRARY_LINK_CXX_FLAGS)
set(CMAKE_SHARED_LIBRARY_LINK_C_FLAGS)

set(CMAKE_C_COMPILER ${cm0_cc})
set(CMAKE_CXX_COMPILER ${cm0_cxx})
set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR cm0)
set(CMAKE_CC_FLAGS "")
set(CMAKE_CXX_FLAGS "")
set(CMAKE_C_COMPILER_WORKS 1)
set(CMAKE_CXX_COMPILER_WORKS 1)


add_subdirectory(src)

# Licensing and stuff like that
set(LICENSE_FILE ${PROJECT_SOURCE_DIR}/LICENSE-MIT)
