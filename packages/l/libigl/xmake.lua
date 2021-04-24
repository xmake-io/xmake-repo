package("libigl")

    set_homepage("https://libigl.github.io/")
    set_description("Simple C++ geometry processing library.")

    add_urls("https://github.com/libigl/libigl/archive/$(version).tar.gz",
             "https://github.com/libigl/libigl.git")
    add_versions("v2.2.0", "b336e548d718536956e2d6958a0624bc76d50be99039454072ecdc5cf1b2ede5")
    add_versions("v2.3.0", "9d6de3bdb9c1cfc61a0a0616fd96d14ef8465995600328c196fa672ee4579b70")

    add_configs("header_only", {description = "Use header only version.", default = true, type = "boolean"})
    add_configs("use_cgal", {description = "Use CGAL library.", default = false, type = "boolean"})

    add_deps("cmake", "eigen")
    on_load("macosx", "linux", "windows", function (package)
        if not package:config("header_only") then
            raise("Non-header-only version is not supported yet!")
        end
        if package:config("use_cgal") then
            package:add("deps", "cgal")
        end
    end)

    on_install("macosx", "linux", "windows", function (package)
        if package:config("header_only") then
            os.mv("include", package:installdir())
            return
        end
        local configs = {"-DLIBIGL_BUILD_TESTS=OFF", "-DLIBIGL_BUILD_TUTORIALS=OFF", "-DLIBIGL_SKIP_DOWNLOAD=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or"OFF"))
        if not package:config("shared") then
            table.insert(configs, "-DLIBIGL_USE_STATIC_LIBRARY=ON")
        end
        if package:is_plat("windows") then
            table.insert(configs, "-DIGL_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                Eigen::MatrixXd V(4,2);
                V<<0,0,
                   1,0,
                   1,1,
                   0,1;
                Eigen::MatrixXi F(2,3);
                F<<0,1,2,
                   0,2,3;
                Eigen::SparseMatrix<double> L;
                igl::cotmatrix(V,F,L);
            }
        ]]}, {configs = {languages = "c++14"}, includes = {"igl/cotmatrix.h", "Eigen/Dense", "Eigen/Sparse"}}))
    end)
