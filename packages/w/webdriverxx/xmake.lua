package("webdriverxx")
    set_homepage("https://github.com/sekogan/webdriverxx")
    set_description("A C++ client library for Selenium Webdriver")
    set_license("MIT")

    add_urls("https://github.com/sekogan/webdriverxx.git")
    add_versions("2018.03.25", "985d5699e663eeb8fd51cb8af8c40be059364c1a")

    add_patches("2018.03.25", "patches/2018.03.25/add_phantom.patch", "d84fc74252b395795ab45ebf71495c77a0f246fb1484096145252a8fd1931cda")
    add_patches("2018.03.25", "patches/2018.03.25/fix_firefox.patch", "f492040c0aab9582a3bc455d8fe47aa34c74ee30b926e3595d34ef2852b6aed4")

    add_deps("libcurl", "picojson")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <webdriverxx.h>
            using namespace webdriverxx;
            void test() {
                WebDriver phantom = Start(Phantom());
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
