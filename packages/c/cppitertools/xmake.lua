package("cppitertools")
    set_kind("library", {headeronly = true})
    set_homepage("https://twitter.com/cppitertools")
    set_description("Implementation of python itertools and builtin iteration functions for C++17")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/ryanhaining/cppitertools/archive/refs/tags/$(version).tar.gz",
            "https://github.com/ryanhaining/cppitertools.git")

    add_versions("v2.3", "419c8192691859650cca8ae7c7a8d633af42dfc453af87b7645338536c6e9e82")
    add_versions("v2.2", "d4e796c9d8ec769fbd68df92943d238d0c43667307995ede058069e770827481")
    add_versions("v2.1", "f7bcd4531e37083609bb92c3f0ae03b56e7197002d0dc9c695104dcef445f2ab")

    add_configs("boost", {description = "For zip_longest", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("boost") then
            package:add("deps", "boost")
        end
    end)

    on_install(function (package)
        if package:version() and package:version():gt("2.1") then
            os.cp("cppitertools", package:installdir("include"))
        else
            os.cp("*.hpp", package:installdir("include/cppitertools"))
            os.cp("internal", package:installdir("include/cppitertools"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cppitertools/itertools.hpp>
            void test() {
                for (auto i : iter::range(10, 15)) {}
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
