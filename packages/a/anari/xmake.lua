package("anari")
    set_homepage("https://github.com/KhronosGroup/ANARI-SDK")
    set_description("ANARI Software Development Kit (SDK)")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/ANARI-SDK/archive/refs/tags/$(version).tar.gz",
             "https://github.com/KhronosGroup/ANARI-SDK.git")

    add_versions("v0.10.0", "92581623fe5523db0b2a7ad5bdb97edc735f146eab4d42703fefcb536dff863d")

    add_deps("cmake")

    on_install(function (package)
        local configs = {
            "-DBUILD_TESTING=OFF",
            "-DBUILD_EXAMPLES=OFF",
            "-DBUILD_VIEWER=OFF",
            "-DBUILD_CTS=OFF",

            "-DBUILD_HELIDE_DEVICE=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (not package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        if not package:config("shared") and package:is_plat("windows") then
            package:add("defines", "ANARI_STATIC_DEFINE")
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("anariLoadLibrary", {includes = "anari/anari.h"}))
    end)
