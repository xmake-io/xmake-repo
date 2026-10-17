option("version", {default = "2.31.0"})

set_version(get_config("version"))

add_rules("mode.debug", "mode.release")

add_requires("nasm")
set_toolchains("nasm")

target("isa-l")
    set_kind("$(kind)")

    for _, dir in ipairs({"erasure_code", "raid", "crc", "igzip", "mem"}) do
        add_files(path.join(dir, "*.c"))
        add_includedirs(dir)
        if is_plat("windows", "mingw") then
            add_files(path.join(dir, "*.asm"))
        else
            add_files(path.join(dir, "*.S"))
        end

        if (not is_plat("windows", "mingw")) and is_arch("arm64.*") then
            add_files(path.join(dir, "aarch64", "*.c"))
            add_files(path.join(dir, "aarch64", "*.S"))
        end

        remove_files(
            path.join(dir, "*_test.c"),
            path.join(dir, "*_perf.c"),
            path.join(dir, "*_example.c")
        )
        if is_plat("windows", "mingw") then
            remove_files(path.join(dir, "data_struct2.asm"))
            remove_files(path.join(dir, "stdmac.asm"))
            remove_files(path.join(dir, "igzip_decode_block_stateless.asm"))
            remove_files(path.join(dir, "igzip_update_histogram.asm"))
            remove_files(path.join(dir, "inflate_data_structs.asm"))
            if is_arch("x64", "x86_64") then
                remove_files(path.join(dir, "*i32.asm"))
            end
        end
    end

    if is_plat("windows", "mingw") then
        add_defines("_USE_MATH_DEFINES")
        add_asflags("-DHAVE_AS_KNOWS_AVX512", "-DAS_FEATURE_LEVEL=10", {force = true})
    end

    add_includedirs("include")
    add_headerfiles("include/*.h", {prefixdir = "isa-l"})

    set_configdir(os.projectdir())
    add_configfiles("isa-l.h.in")
    add_headerfiles("isa-l.h", {prefixdir = "isa-l"})

    if is_plat("windows", "mingw") and is_kind("shared") then
        add_files("isa-l.def", "isa-l.rc")
    end
