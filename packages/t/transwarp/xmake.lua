package("transwarp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/bloomen/transwarp")
    set_description("A header-only C++ library for task concurrency")
    set_license("MIT")

    add_urls("https://github.com/bloomen/transwarp/archive/refs/tags/$(version).zip")
    add_versions("2.2.3", "41c45e1131233fed24ded3e5e49ec412e97b76bdeaf3bd7259a7c8c8f2f7189a")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "transwarp.h"
            namespace tw = transwarp;
            void test() {
                double x = 0;
                auto parent1 = tw::make_task(tw::root, [&x]{ return 13.3 + x; })->named("something");
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
