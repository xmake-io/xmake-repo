package("emock")
    set_homepage("https://github.com/ez8-co/emock")
    set_description("🐞 下一代C/C++跨平台mock库 (Next generation cross-platform mock library for C/C++)")
    set_license("Apache-2.0")

    add_urls("https://github.com/ez8-co/emock/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ez8-co/emock.git")

    add_versions("v0.9.0", "376b3584e95642b10947da8244c9b592f62ac267c23949d875a0d5ffe5d32cf5")

    add_deps("cmake")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    add_configs("namespace", {description = "Build with the `emock::` namespace.", default = true, type = "boolean"})
    add_configs("test_framework", {description = "Choose the unit test framework for failure reporting", default = "STDEXCEPT", type = "string", values = {"STDEXCEPT", "gtest", "cpputest", "cppunit"}})

    on_load(function (package)
        test_framework = package:config("test_framework")
        if test_framework == "gtest" then
            package:add("deps", "gtest")
        elseif test_framework == "cpputest" then
            package:add("deps", "cpputest")
        elseif test_framework == "cppunit" then
            package:add("deps", "cppunit")
        end
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DEMOCK_NO_NAMESPACE=" .. (package:config("namespace") and "OFF" or "ON"))

        local test_framework = package:config("test_framework")
        table.insert(configs, "-DEMOCK_XUNIT=" .. test_framework)
        if test_framework ~= "STDEXCEPT" then
            local dir = package:dep(test_framework):installdir()
            table.insert(configs, "-DEMOCK_XUNIT_HOME=" .. dir)
        end

        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("emock/emock.hpp"))
    end)
