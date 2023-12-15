add_rules("mode.debug", "mode.release")

option("mimalloc", {default = false, showmenu = true, description = "Use mimalloc"})

if has_config("mimalloc") then
    add_requires("mimalloc")
end

target("lzham_codec")
    set_kind("$(kind)")
    set_languages("cxx14")
    add_options("mimalloc")
    add_files(
        "lzhamlib/lzham_lib.cpp",

        "lzhamcomp/lzham_lzbase.cpp",
        "lzhamcomp/lzham_lzcomp_internal.cpp",
        "lzhamcomp/lzham_lzcomp_state.cpp",
        "lzhamcomp/lzham_lzcomp.cpp",
        "lzhamcomp/lzham_match_accel.cpp",

        "lzhamdecomp/lzham_assert.cpp",
        "lzhamdecomp/lzham_checksum.cpp",
        "lzhamdecomp/lzham_huffman_codes.cpp",
        "lzhamdecomp/lzham_lzdecomp.cpp",
        "lzhamdecomp/lzham_lzdecompbase.cpp",
        "lzhamdecomp/lzham_mem.cpp",
        "lzhamdecomp/lzham_platform.cpp",
        "lzhamdecomp/lzham_prefix_coding.cpp",
        "lzhamdecomp/lzham_symbol_codec.cpp",
        "lzhamdecomp/lzham_timer.cpp",
        "lzhamdecomp/lzham_vector.cpp"
    )
    add_headerfiles(
        "include/lzham_dynamic_lib.h",
        "include/lzham_static_lib.h",
        "include/lzham.h",
        "include/zlib.h",

        "lzhamcomp/lzham_comp.h",
        "lzhamcomp/lzham_lzbase.h",
        "lzhamcomp/lzham_lzcomp_internal.h",
        "lzhamcomp/lzham_match_accel.h",
        "lzhamcomp/lzham_null_threading.h",
        "lzhamcomp/lzham_threading.h",

        "lzhamdecomp/lzham_assert.h",
        "lzhamdecomp/lzham_checksum.h",
        "lzhamdecomp/lzham_config.h",
        "lzhamdecomp/lzham_core.h",
        "lzhamdecomp/lzham_decomp.h",
        "lzhamdecomp/lzham_helpers.h",
        "lzhamdecomp/lzham_huffman_codes.h",
        "lzhamdecomp/lzham_lzdecompbase.h",
        "lzhamdecomp/lzham_math.h",
        "lzhamdecomp/lzham_mem.h",
        "lzhamdecomp/lzham_platform.h",
        "lzhamdecomp/lzham_prefix_coding.h",
        "lzhamdecomp/lzham_symbol_codec.h",
        "lzhamdecomp/lzham_timer.h",
        "lzhamdecomp/lzham_traits.h",
        "lzhamdecomp/lzham_types.h",
        "lzhamdecomp/lzham_utils.h",
        "lzhamdecomp/lzham_vector.h"
    )
    add_includedirs("include", {public = true})
    add_includedirs("lzhamcomp", "lzhamdecomp")
    
    if has_config("mimalloc") then
        add_packages("mimalloc")
        add_defines("ASSERT_USE_MIMALLOC")
    end

    if is_arch("x86_64") then 
        add_defines("__x86_64__")
    elseif is_arch("i386") then 
        add_defines("__i386__")
    end
    if is_plat("mingw") then
        add_defines("__GNUC__")
        if is_arch("i386", "x86") then
            add_defines("__MINGW32__")
        else
            add_defines("__MINGW64__")
        end
    end
    if is_plat("windows") then
        add_defines("WIN32", "__WIN32__")
        if is_arch("arm64") then
            add_defines("__AARCH64__")
        elseif is_arch("x64") then
            add_defines("_WIN64")
        end
        add_files("lzhamcomp/lzham_win32_threading.cpp")
        add_headerfiles("lzhamcomp/lzham_win32_threading.h")
    else
        add_syslinks("pthread")
        if is_plat("linux") then 
            add_defines("__linux__")
        elseif is_plat("freebsd") then 
            add_defines("__FreeBSD__")
        end
        if is_plat("macosx", "iphoneos") then
            add_defines("__APPLE__")
            add_defines("__MACH__")
            if is_plat("macosx") then
                add_defines("TARGET_OS_MAC")
            else
                add_defines("TARGET_OS_IPHONE")
            end
        end
        add_files("lzhamcomp/lzham_pthreads_threading.cpp")
        add_headerfiles("lzhamcomp/lzham_pthreads_threading.h")
    end
