package("cppitertools")
    set_kind("library", {headeronly = true})
    set_homepage("https://twitter.com/cppitertools")
    set_description("Implementation of python itertools and builtin iteration functions for C++17")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/ryanhaining/cppitertools.git")

    add_versions("2024.10.19", "5a7f4aa357ed9b0ad59823e3d2acd57217d5beaf")
    add_versions("2023.07.04", "492c15aab96f4ca3938a6b734d6a08cb7feea75a")

    add_configs("boost", {description = "For zip_longest", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("boost") then
            package:add("deps", "boost")
        end
    end)

    on_install(function (package)
        if package:version():gt("2023.07.04") then
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
                for (auto i : iter::range(10)) {}
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
