function(cm0_add_executable TARGET_NAME)
    set(hex_image   ${TARGET_NAME}.hex)
    set(elf_image   ${TARGET_NAME}.elf)
    set(dbg_image   ${TARGET_NAME}.dbg)
    set(map_file    ${TARGET_NAME}.map)
    
    # Rule for building the main executable
    add_executable(${elf_image} ${ARGN})    
    set_target_properties(${elf_image} 
        PROPERTIES
            COMPILE_FLAGS   "${cm0_cxx_flags}"
            LINK_FLAGS      "${cm0_ln_flags} -Wl,-Map=${map_file}"
    )

	# Rule for building the hex image
    add_custom_command(
        OUTPUT ${hex_image}
        COMMAND
            ${cm0_objcopy} ${cm0_objcopy_flags} ${elf_image} ${hex_image}
        DEPENDS
            ${elf_image}
    )
    
    # Rule for building the Buffalogger symbols image    
    if(EXISTS "/dev/null")
        set(null_file /dev/null)        
    else(EXISTS "/dev/null")
        set(null_file nul)
    endif(EXISTS "/dev/null")
        
    add_custom_command(
        OUTPUT ${dbg_image}
        COMMAND 
            ${cm0_objcopy} ${cm0_objcopy_dbg_flags} ${elf_image} ${dbg_image} > ${null_file} 2>&1
        DEPENDS
            ${elf_image}
    )

    # Ensure that the hex and debug images are always built for the target
    add_custom_target(${TARGET_NAME}
        ALL
        DEPENDS ${hex_image} ${dbg_image}
		COMMAND 
            ${cm0_size} ${elf_image}
    )
    
    # Map the target name to the elf image
    set_target_properties(${TARGET_NAME}
        PROPERTIES
            OUTPUT_NAME ${elf_image}
    )
    
    get_directory_property(clean_files ADDITIONAL_MAKE_CLEAN_FILES)
    set_directory_properties(
      PROPERTIES
         ADDITIONAL_MAKE_CLEAN_FILES "${map_file}"
    )
endfunction(cm0_add_executable)