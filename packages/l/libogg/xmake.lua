package("libogg")

    set_homepage("https://www.xiph.org/ogg/")
    set_description("Ogg Bitstream Library")

    set_urls("https://downloads.xiph.org/releases/ogg/libogg-$(version).tar.gz",
             "https://gitlab.xiph.org/xiph/ogg.git")
    add_versions("1.3.4", "fe5670640bd49e828d64d2879c31cb4dde9758681bb664f9bdbf159a01b0c76e")
    add_patches("1.3.4", path.join(os.scriptdir(), "patches", "1.3.4", "macos_fix.patch"), "e12c41ad71206777f399c1048914e5e5a2fe44e18d0d50ebe9bedbfbe0624c35")

    add_deps("cmake")
    if is_plat("cross") and is_subhost("windows") then
        add_deps("make")
    end

    on_install("windows", "macosx", "linux", "mingw", "iphoneos", "android", "cross", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ogg_sync_init", {includes = {"stdint.h", "ogg/ogg.h"}}))
    end)
