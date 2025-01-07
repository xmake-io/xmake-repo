package("cunit")
    set_homepage("https://gitlab.com/cunity/cunit")
    set_description("CUnit is a lightweight system for writing, administering, and running unit tests in C.")
    set_license("LGPL-2.1")

    add_urls("https://gitlab.com/cunity/cunit/-/archive/$(version)/cunit-$(version).tar.bz2",
             "https://gitlab.com/cunity/cunit.git")

    add_versions("3.4.4", "eda4c24afcb2f689b150dadea790a12efb1a0e5e2eb68df7d6417a3ae70a90c7")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    on_install(function (package)
        io.replace("CUnit/CMakeLists.txt", "STATIC", "", {plain = true})
        io.replace("CMakeLists.txt", "-Werror -Werror=strict-prototypes", "", {plain = true})
        io.replace("CUnit/CMakeLists.txt", "-Werror -Werror=strict-prototypes", "", {plain = true})

        local configs = {"-DCUNIT_DISABLE_TESTS=TRUE", "-DCUNIT_DISABLE_EXAMPLES=TRUE"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("CU_basic_set_mode", {includes = "CUnit/Basic.h"}))
    end)
