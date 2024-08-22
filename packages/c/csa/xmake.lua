package("csa")
    set_kind("library", {headeronly = true})
    set_homepage("https://epwalsh.github.io/software/csa")
    set_description("C++ header-only library for Coupled Simulated Annealing")
    set_license("MIT")

    add_urls("https://github.com/epwalsh/CSA.git")
    add_versions("2018.05.25", "3d7154fd35c35fb7297e25bd507c5e3f705b1ad6")

    add_deps("openmp")

    on_install("linux", "macosx", "windows", "mingw@msys", function (package)
        if package:has_tool("cxx", "gxx") then
            package:add("cxxflags", "-fpermissive")
        end
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                CSA::Solver<double, double> solver;
            }
        ]]}, {configs = {languages = "c++11"}, includes = "csa.hpp"}))
    end)
