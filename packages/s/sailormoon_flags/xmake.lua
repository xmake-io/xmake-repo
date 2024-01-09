package("sailormoon_flags")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/sailormoon/flags")
    set_description("Simple, extensible, header-only C++17 argument parser released into the public domain.")
    set_license("MIT")

    add_urls("https://github.com/sailormoon/flags/archive/refs/tags/v$(version).tar.gz")
    add_versions("1.1", "f6626c97ba7a45c473557db2e4b68df4d9cda18a8a97c89a5d8d4e5c53dde904")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "flags.h"
            void test() {
                int argc = 2;
                char **argv = NULL;
                const flags::args args(argc, argv);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
