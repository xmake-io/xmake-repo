package("armadillo")
    set_kind("library", {headeronly = true})
    set_homepage("https://arma.sourceforge.net/")
    set_description("C++ library for linear algebra & scientific computing")
    set_license("Apache-2.0")

    add_urls("https://gitlab.com/conradsnicta/armadillo-code/-/archive/$(version)/armadillo-code-$(version).tar.gz",
             "https://gitlab.com/conradsnicta/armadillo-code")
    add_versions("15.2.6", "764e12d89a507f54b4dd026cb06ed52084f546a7ab4e9eab45c5abf6c88dcacb")
    add_versions("14.6.3", "25de1bd5bdb2317a5f9fa2591362427384b9e81fb63c5a5dd175568e0aaf8c22")
    add_versions("12.8.4", "21cf8aff9cace3db3ab5393b913a09a6013adaffde7a70a6e53f6ead6b78cf02")

    add_configs("blas", {description = "Choose BLAS library to use.", default = "openblas", type = "string", values = {"mkl", "openblas"}})

    on_load("windows", "macosx", "linux", function (package)
        package:add("deps", "superlu", {configs = {blas = package:config("blas")}})
    end)

    on_install("windows|!arm64", "macosx", "linux", function (package)
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
