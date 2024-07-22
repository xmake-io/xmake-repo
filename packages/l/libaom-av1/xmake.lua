package("libaom-av1")
    set_homepage("https://aomedia.googlesource.com/aom")
    set_description("AV1 Codec Library")
    set_license("BSD-2-Clause")

    add_urls("https://storage.googleapis.com/aom-releases/libaom-$(version).tar.gz",
             "https://aomedia.googlesource.com/aom.git")

    add_versions("3.6.1", "42b862f58b3d00bd3902d2dc469526574f5b012e5b178e6a9652845a113d6887")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "m")
    end

    add_deps("cmake", "nasm")
    if is_plat("windows", "mingw") then
        add_deps("strawberry-perl")
    end

    on_install(function (package)
        local configs = {
            "-DENABLE_EXAMPLES=OFF",
            "-DENABLE_TESTS=OFF",
            "-DENABLE_DOCS=OFF",
            "-DCONFIG_LIBYUV=0",
            "-DCONFIG_WEBM_IO=0",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") and package:is_arch("arm.*") then
            table.insert(configs, "-DCMAKE_SYSTEM_NAME=Windows")
            table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=" .. package:arch())
        end

        table.insert(configs, "-DENABLE_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("aom_codec_version_str", {includes = "aom/aom_codec.h"}))
    end)
