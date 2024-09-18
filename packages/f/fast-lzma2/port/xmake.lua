set_version("v1.0.1", {soname = "1"})

add_rules("mode.debug", "mode.release")

add_requires("xxhash")

target("fast-lzma2")
    set_kind("$(kind)")
    add_files("*.c")
    add_headerfiles("fast-lzma2.h", "fl2_errors.h")
    add_packages("xxhash")

    if is_kind("shared") and is_plat("windows") then
        add_defines("FL2_DLL_EXPORT")
        add_defines("FL2_DLL_IMPORT", {interface = true})
    end

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    if is_arch("x64", "x86_64") then
        add_defines("LZMA2_DEC_OPT")
        add_deps("asm")
    end
target_end()

if is_arch("x64", "x86_64") then
    -- help for clang toolchain
    target("asm")
        set_kind("object")

        if is_plat("windows") then
            add_files("*.asm")
            add_asflags("-DMS_x64_CALL=1")
            set_toolchains("msvc")
        else
            add_asflags("-DMS_x64_CALL=0")
            add_files("*.S")
            set_toolchains("gcc")
        end
end
