package("webdriverxx")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/durdyev/webdriverxx")
    set_description("A C++ client library for Selenium Webdriver")
    set_license("MIT")

    add_urls("https://github.com/durdyev/webdriverxx.git")
    add_versions("2018.02.22", "11c4addbb3f791c3d59aecfee2354ba49612d5ca")

    add_patches("2018.02.22", "patches/2018.02.22/picojson.patch", "e3eaacaad4df12429694efba597423bca4083b55f371ced3df2af1f5f009737b")
    add_patches("2018.02.22", "patches/2018.02.22/accept_insecure_certs.patch", "a390ed8b519fb751a43041631b13acfaf23270a445e11c5469969b07a1457f36")

    add_deps("libcurl", "picojson")

    on_install("!bsd and !wasm", function (package)
        os.rm("include/webdriverxx/picojson.h")
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
