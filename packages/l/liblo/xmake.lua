package("liblo")
    set_homepage("https://github.com/radarsat1/liblo")
    set_description("An implementation of the Open Sound Control protocol for POSIX systems")
    set_license("LGPL-2.1-or-later")

    add_urls("https://github.com/radarsat1/liblo/archive/refs/tags/$(version).tar.gz",
             "https://github.com/radarsat1/liblo.git")
    add_versions("0.34", "e9a294c7613e1bec2abcf26f2010604643d605ed6852e16b51837400729fcbee")

    add_deps("cmake")

    if is_plat("linux", "cross", "bsd") then
        add_syslinks("pthread")
    end

    on_install(function (package)
        os.cd("cmake")
        local configs = {
            "-DWITH_STATIC=ON",
            "-DWITH_TESTS=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lo_address_new", {includes = "lo/lo.h"}))
    end)
