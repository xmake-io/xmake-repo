package("samurai")
    set_kind("library", {headeronly = true})
    set_homepage("https://hpc-math-samurai.readthedocs.io")
    set_description("Intervals coupled with algebra of set to handle adaptive mesh refinement and operators on it.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/hpc-maths/samurai/archive/refs/tags/$(version).tar.gz",
             "https://github.com/hpc-maths/samurai.git")

    add_versions("v0.6.0", "bab96adac8e1553b79678a22de2248bec67c7c205b5fd35e9e1aaccaca41286e")

    add_deps("xtensor", "highfive", "pugixml", "fmt")

    on_install("windows", "linux", "macosx", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <samurai/cell_list.hpp>
            void test() {
                samurai::CellList<2> cl;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
