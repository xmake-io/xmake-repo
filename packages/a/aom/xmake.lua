package("aom")
    set_homepage("https://aomedia.googlesource.com/aom")
    set_description("AV1 Codec Library")
    set_license("BSD-2-Clause")

    add_urls("https://storage.googleapis.com/aom-releases/libaom-$(version).tar.gz",
             "https://aomedia.googlesource.com/aom.git")

    add_versions("3.13.1", "19e45a5a7192d690565229983dad900e76b513a02306c12053fb9a262cbeca7d")
    add_versions("3.9.1", "dba99fc1c28aaade28dda59821166b2fa91c06162d1bc99fde0ddaad7cecc50e")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "m")
    end

    add_deps("cmake", "nasm")

    on_load("windows", "mingw@windows", function (package)
        if not package:is_precompiled() then
            package:add("deps", "strawberry-perl")
        end
    end)

    on_install("!wasm and (!windows or windows|!arm64)", function (package)
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

        if package:config("shared") then
            os.tryrm(package:installdir("lib/libaom.a"))
            os.tryrm(package:installdir("lib/aom.lib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("aom_codec_version_str", {includes = "aom/aom_codec.h"}))
    end)
