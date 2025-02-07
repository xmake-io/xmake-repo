package("fgt")
    set_homepage("http://gadomski.github.io/fgt")
    set_description("C++ library for fast Gauss transforms.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/gadomski/fgt/archive/refs/tags/$(version).tar.gz",
             "https://github.com/gadomski/fgt.git")

    add_versions("v0.4.11", "3f11165ae3bb6c349b1fb8971bb4bdeee2c58ca68184e8c603f1964a67282e3b")

    add_configs("openmp", {description = "Use OpenMP parallelization", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("eigen")

    on_load(function (package)
        if package:config("openmp") then
            package:add("deps", "openmp")
            package:add("defines", "FGT_WITH_OPENMP")
        end
        if not package:config("shared") then
            package:add("defines", "LIBRARY_C___STATIC_DEFINE")
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "STATIC", "", {plain = true})
        io.replace("CMakeLists.txt", "SHARED", "", {plain = true})

        local configs = {"-DWITH_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") and package:config("shared") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end

        local opt = {}
        if package:has_tool("cxx", "cl") then
            opt.cxflags = "/utf-8"
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(const Eigen::MatrixXd& x, const Eigen::MatrixXd& y) {
                double bandwidth = 0.3;
                Eigen::VectorXd gauss_transform = fgt::direct(x, y, bandwidth);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "fgt.hpp"}))
    end)
