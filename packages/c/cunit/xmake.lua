package("cunit")
    set_homepage("https://gitlab.com/cunity/cunit")
    set_description("CUnit is a lightweight system for writing, administering, and running unit tests in C.")

    set_license("LGPL-2.1")

    add_urls("https://gitlab.com/cunity/cunit/-/archive/$(version)/cunit-$(version).tar.bz2",
             "https://gitlab.com/cunity/cunit.git")
    add_versions("3.4.4", "1b6ecbf9f260d026589d8ee27026e6e8fdafbfa8e8a325860e064ceb8b069416")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCUNIT_DISABLE_TESTS=TRUE")
        table.insert(configs, "-DCUNIT_DISABLE_EXAMPLES=TRUE")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("CU_basic_set_mode", {includes = "CUnit/Basic.h"}))
    end)
