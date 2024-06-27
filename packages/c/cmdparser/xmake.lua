package("cmdparser")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/FlorianRappl/CmdParser")
    set_description("A simple and lightweight command line parser using C++11.")
    set_license("MIT")

    add_urls("https://github.com/FlorianRappl/CmdParser.git")

    add_versions("2024.02.13", "0c28173f7914c0e47ff12b48f556baa8a5dd0721")

    on_install(function (package)
        os.cp("cmdparser.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int argc, char** argv) {
                cli::Parser parser(argc, argv);
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"cmdparser.hpp"}}))
    end)
