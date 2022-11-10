package("g2o")
    set_homepage("http://openslam.org/g2o.html")
    set_description("g2o: A General Framework for Graph Optimization")

    add_urls("https://github.com/RainerKuemmerle/g2o/archive/refs/tags/$(version).tar.gz", {version = function (version)
        return version:gsub("%.", "") .. "_git"
    end})
    add_urls("https://github.com/RainerKuemmerle/g2o.git")
    add_versions("2020.12.23", "20af80edf8fd237e29bd21859b8fc734e615680e8838824e8b3f120c5f4c1672")

    add_deps("cmake", "eigen")

    on_install(function (package)
        local configs = {"-DG2O_BUILD_APPS=OFF", "-DG2O_BUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <g2o/core/sparse_optimizer.h>
            #include <g2o/core/block_solver.h>
            #include <g2o/core/robust_kernel.h>
            #include <g2o/core/robust_kernel_impl.h>
            #include <g2o/core/optimization_algorithm_levenberg.h>
            #include <g2o/solvers/cholmod/linear_solver_cholmod.h>
            #include <g2o/types/slam3d/se3quat.h>
            #include <g2o/types/sba/types_six_dof_expmap.h>
            void test() {
                g2o::SparseOptimizer optimizer;
                g2o::BlockSolver_6_3::LinearSolverType* linearSolver = new g2o::LinearSolverCholmod<g2o::BlockSolver_6_3::PoseMatrixType> ();
                g2o::BlockSolver_6_3* block_solver = new g2o::BlockSolver_6_3(linearSolver);
                g2o::OptimizationAlgorithmLevenberg* algorithm = new g2o::OptimizationAlgorithmLevenberg(block_solver);
                optimizer.setAlgorithm(algorithm);
                optimizer.setVerbose(false);
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
