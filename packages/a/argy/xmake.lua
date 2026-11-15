package("argy")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/mshenoda/argy")
    set_description("A lightweight, header-only command-line argument parsing library for C++17")
    set_license("MIT")

    add_urls("https://github.com/mshenoda/argy/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mshenoda/argy.git")
    add_versions("v0.6.0", "a2d18d046234a0f12fa7508ffeb4f897108fb82238b36c14fbc6b51a2b7265e9")

    on_install(function (package)
        os.cp("include/argy.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                Argy::CliParser cli(0, nullptr);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "argy.hpp"}))
    end)
