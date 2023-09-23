package("lzham_codec")
    set_homepage("https://github.com/richgel999/lzham_codec")
    set_description("Lossless data compression codec with LZMA-like ratios but 1.5x-8x faster decompression speed, C/C++")

    set_urls("https://github.com/richgel999/lzham_codec.git")

    add_versions("2023.01.03", "d379b1f9121e2197881c61cfc4713c78848bdfe7")
    add_patches("2023.01.03", path.join(os.scriptdir(), "patches", "2023.01.03", "fix_linux.patch"), "f43db780903b98567d5039bcc99c08d3ed871a979333b3387e8416536b3ba925")
    add_patches("2023.01.03", path.join(os.scriptdir(), "patches", "2023.01.03", "use_lzham_prefixed_max_int_values.patch"), "bf8dd1bf584fb0e8a7dcdb846e009ef52c1fcc0fbee7158635322b69883874a6")
    add_patches("2023.01.03", path.join(os.scriptdir(), "patches", "2023.01.03", "fix_macosx.patch"), "8c5ec78e9381215f0283dde82059775c3f8406c444013c04bb55b578415ff7ef")
    add_patches("2023.01.03", path.join(os.scriptdir(), "patches", "2023.01.03", "fix_arm64.patch"), "c1493e4e0b097e3cf0657a90d836952b1dd47c15d3977b8923805004336945d2")
    add_patches("2023.01.03", path.join(os.scriptdir(), "patches", "2023.01.03", "fix_mingw.patch"), "b35bb937a0fc2ba7a61c7e3253ede9d3e8c0f952a8f312e6fa2fe577987fa9c6")
    add_patches("2023.01.03", path.join(os.scriptdir(), "patches", "2023.01.03", "add_mimalloc.patch"), "7d42ce1d7f1d5d8874f99714ddfff97f35247506d423b488e0de8c74ded92a2f")
    
    add_configs("mimalloc", {description = "Use mimalloc instead of default malloc headers", default = is_plat("mingw"), type = "boolean", readonly = is_plat("mingw")})

    on_load(function (package)
        if package:config("mimalloc") then
            package:add("deps", "mimalloc")
        end
    end)

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        local configs = {}
        if package:config("mimalloc") then
            package:add("defines", "ASSERT_USE_MIMALLOC")
            configs.mimalloc = true
        end
        import("package.tools.xmake").install(package, configs)
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
