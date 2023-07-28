package("unity_test")
    set_homepage("http://www.throwtheswitch.org/unity")
    set_description("Simple Unit Testing for C")
    set_license("MIT")

    add_urls("https://github.com/ThrowTheSwitch/Unity/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ThrowTheSwitch/Unity")

    add_versions("v2.5.2", "3786de6c8f389be3894feae4f7d8680a02e70ed4dbcce36109c8f8646da2671a")
    add_versions("v2.5.1", "5ce08ef62f5f64d18f8137b3eaa6d29199ee81d1fc952cef0eea96660a2caf47")
    add_versions("v2.5.0", "d470165dc46652cf73fda54e2650b483b94a7e24ccf793ded28615729b2f41ed")
    add_versions("v2.4.3", "a8c5e384f511a03c603bbecc9edc24d2cb4a916998d51a29cf2e3a2896920d03")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DUNITY_EXTENSION_FIXTURE=ON", "-DUNITY_EXTENSION_MEMORY=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test_main(void) {
                TEST_ASSERT_EQUAL_INT(1, 1);
            }
        ]]}, {includes = "unity/unity.h"}))
    end)
