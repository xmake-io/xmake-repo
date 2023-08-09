package("cpp-linenoise")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/yhirose/cpp-linenoise")
    set_description("A single file multi-platform (Unix, Windows) C++ header-only linenoise-based readline library.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/yhirose/cpp-linenoise.git")
    add_versions("2021.11.05", "4cd89adfbc07cedada1aa32be12991828919d91b")

    on_install(function (package)
        os.cp("linenoise.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                linenoise::SetMultiLine(true);
            }
        ]]}, {includes = {"linenoise.hpp"}}))
    end)
