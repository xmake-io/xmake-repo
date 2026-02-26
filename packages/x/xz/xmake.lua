package("xz")
    set_homepage("https://tukaani.org/xz/")
    set_description("General-purpose data compression with high compression ratio.")

    set_urls("https://github.com/tukaani-project/xz/releases/download/v$(version)/xz-$(version).tar.gz",
             "https://downloads.sourceforge.net/project/lzmautils/xz-$(version).tar.gz")
    add_versions("5.8.2", "ce09c50a5962786b83e5da389c90dd2c15ecd0980a258dd01f70f9e7ce58a8f1")
    add_versions("5.2.11", "0089d47b966bd9ab48f1d01baf7ce146a3b591716c7477866b807010de3d96ab")
    add_versions("5.2.12", "61bda930767dcb170a5328a895ec74cab0f5aac4558cdda561c83559db582a13")
    add_versions("5.2.13", "2942a1a8397cd37688f79df9584947d484dd658db088d51b790317eb3184827b")
    add_versions("5.4.2", "87947679abcf77cc509d8d1b474218fd16b72281e2797360e909deaee1ac9d05")
    add_versions("5.4.3", "1c382e0bc2e4e0af58398a903dd62fff7e510171d2de47a1ebe06d1528e9b7e9")
    add_versions("5.4.4", "aae39544e254cfd27e942d35a048d592959bd7a79f9a624afb0498bb5613bdf8")
    add_versions("5.4.5", "135c90b934aee8fbc0d467de87a05cb70d627da36abe518c357a873709e5b7d6")
    add_versions("5.4.6", "aeba3e03bf8140ddedf62a0a367158340520f6b384f75ca6045ccc6c0d43fd5c")
    add_versions("5.4.7", "8db6664c48ca07908b92baedcfe7f3ba23f49ef2476864518ab5db6723836e71")
    add_versions("5.6.2", "8bfd20c0e1d86f0402f2497cfa71c6ab62d4cd35fd704276e3140bfb71414519")
    add_versions("5.6.3", "b1d45295d3f71f25a4c9101bd7c8d16cb56348bbef3bbc738da0351e17c73317")
    add_versions("5.6.4", "269e3f2e512cbd3314849982014dc199a7b2148cf5c91cedc6db629acdf5e09b")
    add_versions("5.8.1", "507825b599356c10dca1cd720c9d0d0c9d5400b9de300af00e4d1ea150795543")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = is_plat("wasm")})

    add_patches("5.2.13", "patches/5.2.13/fix-unknown-cmake-command.patch", "88c58a0e4b73d9b3020dd95726908768fa17fdad54bf0cf2cfedfef5cf95f94b")
    add_patches(">=5.3.0 && <=5.8.0", "patches/xz-cve-2025-31115.patch", "ee188eabc3220684422f62df7a385541a86d2a5c385407f9d8fd94d49b251c4e")

    set_policy("package.cmake_generator.ninja", false)
    add_deps("cmake")

    on_load(function (package)
        if package:is_plat("windows") and not package:config("shared") then
            package:add("defines", "LZMA_API_STATIC")
        end
    end)

    on_install(function (package)
        local configs = {
            "-DXZ_NLS=OFF",
            "-DENABLE_NLS=OFF", -- before 5.8
            "-DXZ_TOOL_XZDEC=OFF",
            "-DXZ_TOOL_LZMADEC=OFF",
            "-DXZ_TOOL_LZMAINFO=OFF",
            "-DXZ_TOOL_XZ=OFF",
            "-DXZ_TOOL_SYMLINKS=OFF",
            "-DXZ_TOOL_SYMLINKS_LZMA=OFF",
            "-DXZ_TOOL_SCRIPTS=OFF",
            "-DXZ_DOXYGEN=OFF",
            "-DXZ_DOC=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("asan") then
            table.insert(configs,  "-DXZ_SANDBOX=no")
        end
        local cxflags
        if not package:is_plat("windows") and package:is_arch("arm.*") then
            cxflags = "-march=armv8-a+crc+crypto"
        end
        import("package.tools.cmake").install(package, configs, {cxflags = cxflags})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                lzma_version_string();
            }
        ]]}, {configs = {languages = "c11"}, includes = "lzma.h"}))
    end)
