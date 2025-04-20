add_rules("mode.release", "mode.debug")

target("blake3")
    set_kind("$(kind)")
    add_files("c/blake3.c", "c/blake3_dispatch.c", "c/blake3_portable.c")
    add_headerfiles("c/blake3.h")

    if is_arch("x86_64", "x64") then
        if is_subhost("msys", "cygwin") then
            add_files("c/*x86-64_windows_gnu.S")
        elseif is_plat("windows") then
            add_files("c/*x86-64_windows_msvc.asm")
        else
            add_files("c/*x86-64_unix.S")
        end
    elseif is_arch("x86", "i386") then
        add_files("c/blake3_portable.c")
        add_files("c/blake3_sse2.c")
        add_files("c/blake3_sse41.c")
        add_files("c/blake3_avx2.c")
        add_files("c/blake3_avx512.c")
    elseif is_arch("arm64", "arm64-v8a") then
        add_files("c/blake3_neon.c")
        add_defines("BLAKE3_USE_NEON=1")
    end

    if is_plat("windows") and is_kind("shared") then
        add_rules("utils.symbols.export_all")
    end
