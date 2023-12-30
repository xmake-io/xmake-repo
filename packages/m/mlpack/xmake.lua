package("mlpack")
    set_kind("library", {headeronly = true})
    set_homepage("https://www.mlpack.org/")
    set_description("mlpack: a fast, header-only C++ machine learning library")
    set_license("Apache-2.0")

    add_urls("https://github.com/mlpack/mlpack/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mlpack/mlpack.git")

    add_versions("4.3.0", "08cd54f711fde66fc3b6c9db89dc26776f9abf1a6256c77cfa3556e2a56f1a3d")

    if is_plat("linux") then
        add_syslinks("m", "pthread")
    elseif is_plat("windows") then
        add_cxxflags("/bigobj")
    elseif is_plat("mingw") then
        add_cxxflags("-Wa,-mbig-obj")
    end

    add_deps("armadillo", "cereal", "ensmallen")

    on_install("windows", "macosx", "linux", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <mlpack.hpp>
            using namespace mlpack;
            void test() {
                arma::mat data;
                arma::rowvec responses;
                LinearRegression lr(data, responses);
                arma::vec parameters = lr.Parameters();
            }
        ]]}, {configs = {languages = "cxx17"}}))
    end)
