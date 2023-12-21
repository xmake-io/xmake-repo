set_project("zlib")
set_languages("c++11")

add_rules("mode.debug", "mode.release")

target("zlib")
    set_kind("static")
    if not is_plat("windows") then
        set_basename("z")
    end
    if is_plat("linux") then
        add_syslinks("pthread")
    end
    add_files("adler32.c", "compress.c", "cpu_features.c", "crc32.c", "deflate.c")
    add_files("gzclose.c", "gzlib.c", "gzread.c", "gzwrite.c")
    add_files("infback.c", "inffast.c", "inftrees.c", "trees.c", "uncompr.c", "zutil.c")
    add_headerfiles("zlib.h", "zconf.h", "chromeconf.h", "deflate.h", "inffast.h", "inffixed.h", "inflate.h", "inftrees.h", "zutil.h")
    add_includedirs(".", {public = true})
    -- SIMD settings
    on_load(function (target)
        import("core.tool.toolchain")
        if is_plat("android") then
            local ndk = toolchain.load("ndk"):config("ndk")
            target:add("includedirs", path.join(ndk, "sources", "android", "cpufeatures"))
            target:add("files", path.join(ndk, "sources", "android", "cpufeatures", "cpu-features.c"))
        end
    end)
    if is_plat("cross") then
        add_defines("CPU_NO_SIMD")
        add_files("inflate.c")
    elseif is_arch("i386", "x86", "x64", "x86_64") then
        add_defines("CRC32_SIMD_SSE42_PCLMUL", "DEFLATE_FILL_WINDOW_SSE2")
        add_files("crc32_simd.c", "crc_folding.c", "fill_window_sse.c")
        add_defines("ADLER32_SIMD_SSSE3", "INFLATE_CHUNK_SIMD_SSE2")
        add_files("adler32_simd.c", "contrib/optimizations/inffast_chunk.c", "contrib/optimizations/inflate.c")
        if is_plat("windows") then
            add_vectorexts("avx")
        else
            add_cflags("-msse4.2", "-mssse3", "-mpclmul")
        end
        add_defines(is_plat("windows") and "X86_WINDOWS" or "X86_NOT_WINDOWS")
        if is_arch(".+64") then
            add_defines("INFLATE_CHUNK_READ_64LE")
        end
    -- arm optimization disabled on windows, see http://crbug.com/v8/10012.
    elseif is_arch("arm.*") and not is_plat("windows") then
        add_defines("ADLER32_SIMD_NEON", "INFLATE_CHUNK_SIMD_NEON")
        add_files("adler32_simd.c", "contrib/optimizations/inffast_chunk.c", "contrib/optimizations/inflate.c")
        if is_arch(".+64") then
            add_defines("INFLATE_CHUNK_READ_64LE")
        end
        if not is_plat("iphoneos") then
            -- ARM v8 architecture
            add_defines("CRC32_ARMV8_CRC32")
            if not is_plat("windows", "android") then
                add_cflags("-march=armv8-a+crc")
            end
            if is_plat("android") then
                add_defines("ARMV8_OS_ANDROID")
            elseif is_plat("linux") then
                add_defines("ARMV8_OS_LINUX")
            elseif is_plat("windows") then
                add_defines("ARMV8_OS_WINDOWS")
            elseif is_plat("macosx") then
                add_defines("ARMV8_OS_MACOS")
            else
                os.raise("Unsupported ARM OS")
            end
            add_files("crc32_simd.c")
        end
    else
        add_defines("CPU_NO_SIMD")
        add_files("inflate.c")
    end

target("minizip")
    set_kind("static")
    add_deps("zlib")
    add_files("contrib/minizip/ioapi.c",
              "contrib/minizip/unzip.c",
              "contrib/minizip/zip.c")
    add_headerfiles("contrib/minizip/ioapi.h",
                    "contrib/minizip/unzip.h",
                    "contrib/minizip/zip.h")
    if is_plat("windows") then
        add_files("contrib/minizip/iowin32.c")
        add_headerfiles("contrib/minizip/iowin32.h")
    elseif is_plat("macosx", "iphoneos") then
        add_defines("USE_FILE32API")
    end

target("compression_utils_portable")
    set_kind("static")
    add_deps("zlib")
    add_files("google/compression_utils_portable.cc")
    add_headerfiles("google/compression_utils_portable.h")
