package("ensmallen")

    set_kind("library", {headeronly = true})
    set_homepage("https://ensmallen.org/")
    set_description("flexible C++ library for efficient numerical optimization")
    set_license("BSD-3-Clause")

    add_urls("https://ensmallen.org/files/ensmallen-$(version).tar.gz")
    add_versions("2.18.0", "62f7db71105305c0754a5f2a02fb8d05a5294bafa82584172b50609aabf7ea44")

    add_deps("cmake", "armadillo")
    on_install("windows", "macosx", "linux", function (package)
        io.replace("CMakeLists.txt", "add_subdirectory(tests)", "", {plain = true})
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                ens::L_BFGS opt;
                opt.MaxIterations() = 10;
            }
        ]]}, {configs = {languages = "c++14"}, includes = "ensmallen.hpp"}))
    end)
