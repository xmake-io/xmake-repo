package("args")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Taywee/args")
    set_description("A simple header-only C++ argument parser library.")
    set_license("MIT")

    add_urls("https://github.com/Taywee/args/archive/refs/tags/$(version).tar.gz")
    add_versions("6.4.6", "41ed136bf9b216bf5f18b1de2a8d22a870381657e8427d6621918520b6e2239c")

    on_install(function (package)
        os.cp("args.hxx", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <args.hxx>
            void test() {
                args::ArgumentParser parser("This is a test program.", "This goes after the options.");
            }
        ]]}))
    end)
