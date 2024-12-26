package("vvenc")
    set_homepage("https://www.hhi.fraunhofer.de/en/departments/vca/technologies-and-solutions/h266-vvc.html")
    set_description("Fraunhofer Versatile Video Encoder (VVenC)")
    set_license("BSD-3-Clause-Clear")

    add_urls("https://github.com/fraunhoferhhi/vvenc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/fraunhoferhhi/vvenc.git")

    add_versions("v1.13.0", "28994435e4f7792cc3a907b1c5f20afd0f7ef1fcd82eee2af7713df7a72422eb")
    add_versions("v1.12.1", "ba353363779e8f835200f319c801b052a97d592ebc817b52c41bdce093fa2fe2")
    add_versions("v1.12.0", "e7311ffcc87d8fcc4b839807061cca1b89be017ae7c449a69436dc2dd07615c2")
    add_versions("v1.11.1", "4f0c8ac3f03eb970bee7a0cacc57a886ac511d58f081bb08ba4bce6f547d92fa")
    add_versions("v1.9.0", "4ddb365dfc21bbbb7ed54655c7630ae3e8e977af31f22b28195e720215b1072d")

    add_configs("json", {description = "enable JSON support", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("json") then
            package:add("deps", "nlohmann_json")
        end

        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "VVENC_DYN_LINK")
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", [[add_subdirectory( "test/vvenclibtest" )]], "", {plain = true})
        io.replace("CMakeLists.txt", [[add_subdirectory( "test/vvencinterfacetest" )]], "", {plain = true})
        io.replace("CMakeLists.txt", [[add_subdirectory( "test/vvenc_unit_test" )]], "", {plain = true})
        io.replace("CMakeLists.txt", [[include( cmake/modules/vvencTests.cmake )]], "", {plain = true})
        io.replace("CMakeLists.txt", "if( CCACHE_FOUND )", "if(0)", {plain = true})
        if package:config("json") then
            io.replace("source/Lib/vvenc/CMakeLists.txt",
            "../../../thirdparty/nlohmann_json/single_include",
            path.unix(package:dep("nlohmann_json"):installdir("include")), {plain = true})

            io.replace("source/Lib/apputils/LogoRenderer.h",
                "../../../thirdparty/nlohmann_json/single_include/nlohmann/json.hpp",
                "nlohmann/json.hpp", {plain = true})
        end

        local configs = {
            "-DVVENC_ENABLE_WERROR=OFF",
            "-DVVENC_OVERRIDE_COMPILER_CHECK=ON",
            "-DVVENC_ENABLE_BUILD_TYPE_POSTFIX=OFF",
        }
        if package:is_debug() then
            table.insert(configs, "-DCMAKE_BUILD_TYPE=Debug")
            table.insert(configs, "-DVVENC_ENABLE_TRACING=ON")
        else
            table.insert(configs, "-DCMAKE_BUILD_TYPE=Release")
            table.insert(configs, "-DVVENC_ENABLE_TRACING=OFF")
        end
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DVVENC_ENABLE_LINK_TIME_OPT=" .. (package:config("lto") and "ON" or "OFF"))
        table.insert(configs, "-DVVENC_USE_ADDRESS_SANITIZER=" .. (package:config("asan") and "ON" or "OFF"))

        table.insert(configs, "-DVVENC_LIBRARY_ONLY=" .. (package:config("tools") and "OFF" or "ON"))
        table.insert(configs, "-DVVENC_ENABLE_THIRDPARTY_JSON=" .. (package:config("json") and "ON" or "OFF"))
        if (package:is_plat("android") and package:is_arch("armeabi-v7a")) or package:is_plat("wasm") then
            table.insert(configs, "-DVVENC_ENABLE_X86_SIMD=OFF")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vvenc_init_default", {includes = "vvenc/vvenc.h"}))
    end)
