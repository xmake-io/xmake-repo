package("gmm")

    set_homepage("http://getfem.org/gmm/index.html")
    set_description("Gmm++ provides some basic types of sparse and dense matrices and vectors.")

    add_urls("http://download-mirror.savannah.gnu.org/releases/getfem/stable/gmm-$(version).tar.gz")
    add_versions("5.4", "7163d5080efbe6893d1950e4b331cd3e9160bb3dcf583d206920fba6af7b1e56")

    on_install("macosx", "linux", "windows", "mingw", function (package)
        if package:is_plat("windows") then
            package:add("defines", "_SCL_SECURE_NO_DEPRECATE")
        end
        os.cp("include/gmm", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                gmm::dense_matrix<double> M(3, 3), M2(3, 3), M3(3, 3);
                gmm::copy(gmm::identity_matrix(), M);
                gmm::scale(M, 2.0);
                M(1, 2) = 1.0;
                gmm::copy(M, M2);
                gmm::lu_inverse(M);
                gmm::mult(M, M2, M3);
            }
        ]]}, {configs = {languages = "c++11"}, includes = "gmm/gmm_kernel.h"}))
    end)
