package("unity")
    set_homepage("http://www.throwtheswitch.org/unity")
    set_description("Simple Unit Testing for C")
    set_license("MIT")

    add_urls("https://github.com/ThrowTheSwitch/Unity/archive/refs/tags/$(version).tar.gz", "https://github.com/ThrowTheSwitch/Unity")

    add_versions("v2.5.2", "3786de6c8f389be3894feae4f7d8680a02e70ed4dbcce36109c8f8646da2671a")

    on_install(function (package)
        os.cp("src/*.c", package:installdir("include"))
        os.cp("src/*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            void test_main(void) {
                TEST_ASSERT_EQUAL_INT(1, 1);
            }
        ]]}, {includes = "unity.h"}))
    end)
