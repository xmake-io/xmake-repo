package("fastor")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/romeric/Fastor")
    set_description("A lightweight high performance tensor algebra framework for modern C++")
    set_license("MIT")

    add_urls("https://github.com/romeric/Fastor/archive/refs/tags/V$(version).tar.gz",
             "https://github.com/romeric/Fastor.git")
    add_versions("0.6.3", "6ee13c75bed1221d0cdc0985d996bb79ae09b6d7e05798f1bb84458c2bdb238b")

    on_install("windows", "macosx", "linux", "mingw", function (package)
        os.cp("Fastor", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            enum {I,J,K,L,M,N};
            void test() {
                Fastor::Tensor<double,2,3,5> A;
                Fastor::Tensor<double,3,5,2,4> B;
                A.random();
                B.random();
                auto C = Fastor::einsum<Fastor::Index<I,J,K>,Fastor::Index<J,L,M,N>>(A,B);
            }
        ]]}, {configs = {languages = "c++14"}, includes = "Fastor/Fastor.h"}))
    end)
