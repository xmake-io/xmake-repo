package("libogg")

    set_homepage("https://www.xiph.org/ogg/")
    set_description("Ogg Bitstream Library")

    set_urls("https://downloads.xiph.org/releases/ogg/libogg-$(version).tar.gz",
             "https://gitlab.xiph.org/xiph/ogg.git")
    add_versions("1.3.4", "fe5670640bd49e828d64d2879c31cb4dde9758681bb664f9bdbf159a01b0c76e")

    on_install("windows", "macosx", "linux", "mingw", "iphoneos", "android", "cross", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ogg_sync_init", {includes = {"stdint.h", "ogg/ogg.h"}}))
    end)
