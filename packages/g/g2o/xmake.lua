package("g2o")
    set_homepage("http://openslam.org/g2o.html")
    set_description("g2o: A General Framework for Graph Optimization")

    add_urls("https://github.com/RainerKuemmerle/g2o/archive/refs/tags/$(version).tar.gz", {version = function (version)
        return version:gsub("%.", "") .. "_git"
    end})
    add_urls("https://github.com/RainerKuemmerle/g2o.git")
    add_versions("2020.12.23", "20af80edf8fd237e29bd21859b8fc734e615680e8838824e8b3f120c5f4c1672")
    add_versions("2024.12.28", "d691ead69184ebbb8256c9cd9f4121d1a880b169370efc0554dd31a64802a452")

    add_deps("cmake", "eigen <5.0")

    add_links("g2o_solver_slam2d_linear", "g2o_solver_structure_only", "g2o_solver_dense", "g2o_solver_eigen", "g2o_solver_pcg", "g2o_types_data", "g2o_types_icp", "g2o_types_sim3", "g2o_types_sba", "g2o_types_sclam2d", "g2o_types_slam2d_addons", "g2o_types_slam2d", "g2o_types_slam3d_addons", "g2o_types_slam3d", "g2o_core", "g2o_stuff", "g2o_opengl_helper", "g2o_ext_freeglut_minimal")

    on_install("linux", "windows", "macosx", function (package)
        local configs = {"-DG2O_BUILD_APPS=OFF", "-DG2O_BUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "g2o/core/factory.h"
            #include "g2o/core/optimization_algorithm_factory.h"
            #include "g2o/core/sparse_optimizer.h"
            #include "g2o/stuff/command_args.h"

            void test() {
                g2o::SparseOptimizer optimizer;
                optimizer.setVerbose(false);
            }
        ]]}, {configs = {languages = package:version():ge("2023.08.06") and "c++17" or "c++14"}}))
    end)
