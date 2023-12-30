package("mlpack")
    set_kind("library", {headeronly = true})
    set_homepage("https://www.mlpack.org/")
    set_description("mlpack: a fast, header-only C++ machine learning library")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/mlpack/mlpack/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mlpack/mlpack.git")

    add_versions("4.3.0", "08cd54f711fde66fc3b6c9db89dc26776f9abf1a6256c77cfa3556e2a56f1a3d")

    if is_plat("linux") then
        add_syslinks("m", "pthread")
    end

    add_configs("openmp", {description = "Enable OpenMP", default = false, type = "boolean"})
    
    add_deps("armadillo", "cereal", "ensmallen", "stb")

    on_load(function(package)
        if package:config("openmp") then
            package:add("deps", "openmp")
        end
    end)

    on_install("windows|x64", "windows|x86", "macosx", "linux", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        local configs = {}
        if package:config("openmp") then
            configs.openmp = true
        end
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
