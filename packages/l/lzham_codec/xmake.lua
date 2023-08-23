package("lzham_codec")
    set_homepage("https://github.com/richgel999/lzham_codec")
    set_description("Lossless data compression codec with LZMA-like ratios but 1.5x-8x faster decompression speed, C/C++")

    set_urls("https://github.com/richgel999/lzham_codec.git")

    add_versions("2023.01.03", "d379b1f9121e2197881c61cfc4713c78848bdfe7")

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        io.replace("lzhamdecomp/lzham_symbol_codec.h", [[#include "lzham_prefix_coding.h"]], [[#include "lzham_prefix_coding.h"
#include <cstdint>]], {plain = true})
        import("package.tools.xmake").install(package, {kind = package:config("shared") and "shared" or "static"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lzham_compress_init", {includes = "lzham_static_lib.h"}))
        assert(package:check_cxxsnippets({test = [[
            #include <lzham_static_lib.h>
            void test() {
                lzham_static_lib lzham_lib;
                lzham_lib.load();
            }
        ]]}))
    end)

package_end()
