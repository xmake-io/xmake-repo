package("amgcl")
    set_homepage("https://github.com/ddemidov/amgcl/")
    set_description("C++ library for solving large sparse linear systems with algebraic multigrid method")
    set_license("MIT")

    add_urls("https://github.com/ddemidov/amgcl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ddemidov/amgcl.git", {submodules = false})

    add_versions("1.4.5", "611b7e46b60640abab055d815e2b28af3cb92e71fa609c514465f94b51c1f886")
    add_versions("1.4.0", "018b824396494c8958faa6337cebcaba48a2584d828f279eef0bbf9e05f900a7")
    add_versions("1.4.2", "db0de6b75e6c205f44542c3ac8d9935c8357a58072963228d0bb11a54181aea8")
    add_versions("1.4.3", "e920d5767814ce697d707d1f359a16c9b9eb79eba28fe19e14c18c2a505fe0ad")
    add_versions("1.4.4", "02fd5418e14d669422f65fc739ce72bf9516ced2d8942574d4b8caa05dda9d8c")

    add_deps("cmake")
    add_deps("boost", {configs = {
        cmake = true,
        serialization = true,
        program_options = true,
        container = true,
        regex = true,
        thread = true,
    }})

    on_install("windows", "mingw", "macosx", "linux", function (package)
        io.replace("CMakeLists.txt", "cmake_policy(SET CMP0058 OLD)", "", {plain = true})
        io.replace("CMakeLists.txt", "unit_test_framework", "", {plain = true})

        local configs = {"-DBoost_USE_STATIC_LIBS=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. (package:has_runtime("MT", "MTd") and "ON" or "OFF"))
        else
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=OFF")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <vector>
            #include <amgcl/backend/builtin.hpp>
            #include <amgcl/adapter/crs_tuple.hpp>
            #include <amgcl/make_solver.hpp>
            #include <amgcl/amg.hpp>
            #include <amgcl/coarsening/smoothed_aggregation.hpp>
            #include <amgcl/relaxation/spai0.hpp>
            #include <amgcl/solver/bicgstab.hpp>
            void test() {
                typedef amgcl::backend::builtin<double> Backend;
                typedef amgcl::make_solver<
                    amgcl::amg<
                        Backend,
                        amgcl::coarsening::smoothed_aggregation,
                        amgcl::relaxation::spai0
                    >,
                    amgcl::solver::bicgstab<Backend>
                > Solver;
                ptrdiff_t           rows, cols;
                std::vector<int>    ptr, col;
                std::vector<double> val;
                Solver solve(std::tie(rows, ptr, col, val));
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
