set_version("v1.0.1", {soname = "1"})

add_rules("mode.debug", "mode.release")

add_requires("xxhash")
add_packages("xxhash")

target("fast-lzma2")
    set_kind("$(kind)")
    add_files("*.c")
    add_headerfiles("fast-lzma2.h", "fl2_errors.h")

    if is_arch("x64", "x86_64") then
        add_defines("LZMA2_DEC_OPT")
        if is_plat("windows") then
            add_files("*.asm")
            add_asflags("-DMS_x64_CALL=1")
        else
            add_asflags("-DMS_x64_CALL=0")
            add_files("*.S")
        end
    end

    if is_kind("shared") then
        if is_plat("windows") then
            add_defines("FL2_DLL_EXPORT")
            add_defines("FL2_DLL_IMPORT", {interface = true})
        end
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end
