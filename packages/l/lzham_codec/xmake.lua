package("lzham_codec")
    set_homepage("https://github.com/richgel999/lzham_codec")
    set_description("Lossless data compression codec with LZMA-like ratios but 1.5x-8x faster decompression speed, C/C++")

    set_urls("https://github.com/richgel999/lzham_codec.git")

    add_versions("2023.01.03", "d379b1f9121e2197881c61cfc4713c78848bdfe7")
    add_patches("2023.01.03", path.join(os.scriptdir(), "patches", "2023.01.03", "fix_linux.patch"), "f43db780903b98567d5039bcc99c08d3ed871a979333b3387e8416536b3ba925")
    add_patches("2023.01.03", path.join(os.scriptdir(), "patches", "2023.01.03", "use_lzham_prefixed_max_int_values.patch"), "bf8dd1bf584fb0e8a7dcdb846e009ef52c1fcc0fbee7158635322b69883874a6")
    add_patches("2023.01.03", path.join(os.scriptdir(), "patches", "2023.01.03", "fix_macosx.patch"), "8c5ec78e9381215f0283dde82059775c3f8406c444013c04bb55b578415ff7ef")
    add_patches("2023.01.03", path.join(os.scriptdir(), "patches", "2023.01.03", "fix_arm64.patch"), "926689a9be5a7c2d71c37930fd99e5374938b2d80d8ac5d21a3d284223a7e98d")
    add_patches("2023.01.03", path.join(os.scriptdir(), "patches", "2023.01.03", "fix_mingw.patch"), "7dd03d1c3db59d0f2fe4e8a28b77327b28d06f2d867476f0a452c5ad375363b5")

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
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
