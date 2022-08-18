package("armadillo")

    set_kind("library", {headeronly = true})
    set_homepage("http://arma.sourceforge.net/")
    set_description("C++ library for linear algebra & scientific computing")
    set_license("Apache-2.0")

    add_urls("http://sourceforge.net/projects/arma/files/armadillo-$(version).tar.xz")
    add_versions("11.2.3", "4c2e97ce60707fc1f348f44f7af0cb6d2466d0aad0d0ea4bf5d5dc180e6cba41")
    add_versions("10.8.1", "5087ab5a2268e5ce71798c1afcb6d1fb246463f8dc88a60db49a083600f98332")
    add_versions("10.7.0", "9bf60db6fd237721908747a0e56797b97b7ceae3603f2cca0b012a3b88265d3f")
    add_versions("10.7.3", "aac930d5fbc23dca9453ff3647d03f7d90d9584a4556719ad7bc7adab7db6ff5")

    add_configs("blas", {description = "Choose BLAS library to use.", default = "openblas", type = "string", values = {"mkl", "openblas"}})

    on_load("windows", "macosx", "linux", function (package)
        package:add("deps", "superlu", {configs = {blas = package:config("blas")}})
    end)

    on_install("windows", "macosx", "linux", function (package)
        os.cd("include")
        io.gsub("armadillo_bits/config.hpp.cmake", "${.-}/?", "")
        io.gsub("armadillo_bits/config.hpp.cmake", "#cmakedefine (.-)\n", "${define %1}\n")
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("armadillo")
                set_kind("phony")
                set_configvar("ARMA_USE_LAPACK", 1)
                set_configvar("ARMA_USE_BLAS", 1)
                set_configvar("ARMA_USE_SUPERLU", 1)
                set_configdir(".")
                add_configfiles("(armadillo_bits/config.hpp.cmake)", {filename = "config.hpp"})
                on_install(function (target)
                    os.cp("armadillo", path.join(target:installdir(), "include", "armadillo"))
                    os.mkdir(path.join(target:installdir(), "include", "armadillo_bits"))
                    os.cp("armadillo_bits/*.hpp", path.join(target:installdir(), "include", "armadillo_bits"))
                end)
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                using mat = arma::Mat<double>;
                mat A(5, 5, arma::fill::randu);
                double x = A(1,2);
                mat B = A + A;
                mat C = A * B;
                mat D = A % B;
            }
        ]]}, {configs = {languages = "c++14"}, includes = "armadillo"}))
    end)
