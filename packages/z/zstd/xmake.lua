package("zstd")

    set_homepage("https://www.zstd.net/")
    set_description("Zstandard - Fast real-time compression algorithm")

    set_urls("https://github.com/facebook/zstd/archive/$(version).tar.gz",
             "https://github.com/facebook/zstd.git")
    add_versions("v1.4.5", "734d1f565c42f691f8420c8d06783ad818060fc390dee43ae0a89f86d0a4f8c2")
    add_versions("v1.5.0", "0d9ade222c64e912d6957b11c923e214e2e010a18f39bec102f572e693ba2867")
    add_versions("v1.5.2", "f7de13462f7a82c29ab865820149e778cbfe01087b3a55b5332707abf9db4a6e")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release", "asm")
            add_rules("utils.install.pkgconfig_importfiles", {filename = "libzstd.pc"})
            target("zstd")
                set_kind("$(kind)")
                add_files("lib/common/*.c")
                add_files("lib/compress/*.c")
                add_files("lib/decompress/*.c")
                add_headerfiles("lib/*.h")
                add_defines("XXH_NAMESPACE=ZSTD_")
                if is_kind("shared") and is_plat("windows") then
                    add_defines("ZSTD_DLL_EXPORT")
                end
                on_config(function (target)
                    if target:is_arch("x64", "x86_64") and target:has_tool("cc", "clang", "gcc") then
                        target:add("files", "lib/decompress/*.S")
                    else
                        target:add("defines", "ZSTD_DISABLE_ASM")
                    end
                end)
        ]])

        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ZSTD_compress", {includes = {"zstd.h"}}))
        assert(package:has_cfuncs("ZSTD_decompress", {includes = {"zstd.h"}}))
    end)
