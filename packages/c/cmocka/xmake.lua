package("cmocka")
    set_homepage("https://cmocka.org/")
    set_description("cmocka is an elegant unit testing framework for C with support for mock objects.")
    set_license("Apache-2.0")

    add_urls("https://cmocka.org/files/$(version).tar.xz", {version = function (version) 
        return table.concat(table.slice(version:split('%.'), 1, 2), '.') .. "/cmocka-" .. version
    end})
    add_versions("1.1.7", "810570eb0b8d64804331f82b29ff47c790ce9cd6b163e98d47a4807047ecad82")
    add_versions("1.1.5", "f0ccd8242d55e2fd74b16ba518359151f6f8383ff8aef4976e48393f77bba8b6")

    add_deps("cmake")
    on_install("windows", "linux", "macosx", "mingw", "msys", function (package)
        local configs = {"-DUNIT_TESTING=OFF", "-DWITH_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cmocka_set_test_filter", {includes = {"stdarg.h", "stddef.h", "setjmp.h", "stdint.h", "cmocka.h"}}))
    end)
