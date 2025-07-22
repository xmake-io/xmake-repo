package("spectra")

    set_kind("library", {headeronly = true})
    set_homepage("https://spectralib.org/")
    set_description("Sparse Eigenvalue Computation Toolkit as a Redesigned ARPACK")
    set_license("MPL-2.0")

    add_urls("https://github.com/yixuan/spectra/archive/refs/tags/$(version).tar.gz",
             "https://github.com/yixuan/spectra.git")
    add_versions("v1.1.0", "d29671e3d1b8036728933cadfddb05668a3cd6133331e91fc4535a9b85bedc79")
    add_versions("v1.0.1", "919e3fbc8c539a321fd5a0766966922b7637cc52eb50a969241a997c733789f3")

    add_deps("cmake", "eigen")
    on_install("windows", "macosx", "linux", "mingw", "cross", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <Eigen/Core>
            #include <Spectra/SymEigsSolver.h>
            void test() {
                Eigen::MatrixXd A = Eigen::MatrixXd::Random(10, 10);
                Eigen::MatrixXd M = A + A.transpose();
                Spectra::DenseSymMatProd<double> op(M);
                Spectra::SymEigsSolver<Spectra::DenseSymMatProd<double>> eigs(op, 3, 6);
                eigs.init();
                int nconv = eigs.compute(Spectra::SortRule::LargestAlge);
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
