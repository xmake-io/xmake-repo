package("asap")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/mobius3/asap")
    set_description("A C++ header-only library for creating, displaying, iterating and manipulating dates")
    set_license("MIT")

    add_urls("https://github.com/mobius3/asap.git")
    add_versions("2023.04.21", "e39f2fe178de2ccba816d45811bf23ae0147fcb1")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <asap/asap.h>
            void test() {
                asap::datetime d1;
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
