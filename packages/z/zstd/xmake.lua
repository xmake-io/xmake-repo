package("zstd")

    set_homepage("https://www.zstd.net/")
    set_description("Zstandard - Fast real-time compression algorithm")

    set_urls("https://github.com/facebook/zstd/archive/$(version).tar.gz",
             "https://github.com/facebook/zstd.git")
    add_versions("v1.4.5", "734d1f565c42f691f8420c8d06783ad818060fc390dee43ae0a89f86d0a4f8c2")
    add_versions("v1.5.0", "0d9ade222c64e912d6957b11c923e214e2e010a18f39bec102f572e693ba2867")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
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
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ZSTD_compress", {includes = {"zstd.h"}}))
        assert(package:has_cfuncs("ZSTD_decompress", {includes = {"zstd.h"}}))
    end)
