package("webdriverxx")
    set_kind("library", {headeronly = true})
    set_homepage("https://GermanAizek.github.io/webdriverxx")
    set_description("A C++ client library for Selenium Webdriver")
    set_license("MIT")

    add_urls("https://github.com/GermanAizek/webdriverxx.git", {submodules = false})
    add_versions("2023.04.22", "b8c9ac36360021daca7b0fd006a092b605b19e29")

    add_patches("2023.04.22", "patches/2023.04.22/picojson.patch", "11e23fe37c7e3b8ec174642542567c9d6bae3657892f5d7ac8203cbb89c9112c")
    
    add_deps("libcurl", "picojson")

    on_install("!wasm", function (package)
        os.rm("include/webdriverxx/picojson.h")
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <webdriverxx.h>
            using namespace webdriverxx;
            void test() {
                WebDriver phantom = Start(PhantomJS());
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
