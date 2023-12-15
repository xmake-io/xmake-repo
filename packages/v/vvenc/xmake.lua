package("vvenc")
    set_homepage("https://www.hhi.fraunhofer.de/en/departments/vca/technologies-and-solutions/h266-vvc.html")
    set_description("Fraunhofer Versatile Video Encoder (VVenC)")
    set_license("BSD-3-Clause-Clear")

    add_urls("https://github.com/fraunhoferhhi/vvenc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/fraunhoferhhi/vvenc.git")

    add_versions("v1.9.0", "4ddb365dfc21bbbb7ed54655c7630ae3e8e977af31f22b28195e720215b1072d")

    add_configs("postfix", {description = "set build type postfix for apps and libs", default = false, type = "boolean"})
    add_configs("json", {description = "enable JSON support (3rd-party lib.)", default = false, type = "boolean"})
    add_configs("asan", {description = "enable address sanitizer in the build", default = false, type = "boolean"})

    add_deps("cmake")

    on_install("windows|x86", "windows|x64", "linux", "macosx", "bsd", "mingw", "msys", "android", "iphoneos", function (package)
        local configs = {}
        if package:is_debug() then
            table.insert(configs, "-DCMAKE_BUILD_TYPE=Debug")
            table.insert(configs, "-DVVENC_ENABLE_TRACING=ON")
        else
            table.insert(configs, "-DCMAKE_BUILD_TYPE=Release")
            table.insert(configs, "-DVVENC_ENABLE_TRACING=OFF")
        end
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DVVENC_ENABLE_LINK_TIME_OPT=" .. (package:config("lto") and "ON" or "OFF"))
        table.insert(configs, "-DVVENC_ENABLE_BUILD_TYPE_POSTFIX=" .. (package:config("postfix") and "ON" or "OFF"))
        table.insert(configs, "-DVVENC_ENABLE_THIRDPARTY_JSON=" .. (package:config("json") and "ON" or "OFF"))
        table.insert(configs, "-DVVENC_USE_ADDRESS_SANITIZER=" .. (package:config("asan") and "ON" or "OFF"))

        io.replace("CMakeLists.txt", [[add_subdirectory( "test/vvenclibtest" )]], "", {plain = true})
        io.replace("CMakeLists.txt", [[add_subdirectory( "test/vvencinterfacetest" )]], "", {plain = true})

        local cxflags = table.wrap(package:config("cxflags"))
        if package:is_plat("windows") then
            table.insert(cxflags, "/wd4100");
        end
        package:config_set("cxflags", cxflags)
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vvenc_init_default", {includes = "vvenc/vvenc.h"}))
    end)
