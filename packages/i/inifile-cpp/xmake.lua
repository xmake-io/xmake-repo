package("inifile-cpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Rookfighter/inifile-cpp")
    set_description("A header-only and easy to use Ini file parser for C++.")
    set_license("MIT")

    add_urls("https://github.com/Rookfighter/inifile-cpp.git")
    add_versions("2022.06.25", "e7ba25eede111e76e176a341ea12a47e9948627c")
    add_versions("2025.02.11", "7e49789411beba98ca2c98940c40f7ca7e4b23b5")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <inicpp.h>
            void test() {
                ini::IniFile myIni;
                myIni.load("some/ini/path");
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
