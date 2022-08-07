package("tabulate")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/p-ranav/tabulate")
    set_description("Header-only library for printing aligned, formatted and colorized tables in Modern C++")
    set_license("MIT")

    add_urls("https://github.com/p-ranav/tabulate/archive/refs/tags/v$(version).zip",
             "https://github.com/p-ranav/tabulate.git")
    add_versions("1.4", "77aca3b371316fb33b8a794906614bc2ef0964ca23ba096161f5e2fade181ffb")

    on_install(function (package)
        os.cp("include/tabulate/*.hpp", package:installdir("include/tabulate"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[                    
            void test() {
                tabulate::Table test{};
            }
        ]]}, {configs = {languages = "c++11"}, includes = "tabulate/table.hpp"}))
    end)