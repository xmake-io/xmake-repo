package("libigl")

    set_homepage("https://libigl.github.io/")
    set_description("Simple C++ geometry processing library.")
    set_license("MPL-2.0")

    add_urls("https://github.com/libigl/libigl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libigl/libigl.git")
    add_versions("v2.2.0", "b336e548d718536956e2d6958a0624bc76d50be99039454072ecdc5cf1b2ede5")
    add_versions("v2.3.0", "9d6de3bdb9c1cfc61a0a0616fd96d14ef8465995600328c196fa672ee4579b70")
    add_versions("v2.4.0", "f3f53ee6f1e9a6c529378c6b0439cd2cfc0e30b2178b483fe6bea169ce6deb22")
    add_versions("v2.5.0", "1d9d8c3a3a6a269cf22612bbe24d7fd1c5f84838231d299d712969ad294f945f")

    add_resources("2.x", "libigl_imgui", "https://github.com/libigl/libigl-imgui.git", "7e1053e750b0f4c129b046f4e455243cb7f804f3")

    add_configs("header_only", {description = "Use header only version.", default = true, type = "boolean"})
    add_configs("cgal", {description = "Use CGAL library.", default = false, type = "boolean"})
    add_configs("imgui", {description = "Use imgui with libigl.", default = false, type = "boolean"})
    add_configs("embree", {description = "Use embree library.", default = false, type = "boolean"})

    if is_plat("windows") then
        add_defines("NOMINMAX")
        add_syslinks("comdlg32")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end

    add_deps("cmake", "eigen")
    on_load("macosx", "linux", "windows", "mingw", function (package)
        if package:config("header_only") then
            package:set("kind", "library", {headeronly = true})
        else
            raise("Non-header-only version is not supported yet!")
        end
        if package:config("cgal") then
            package:add("deps", "cgal")
        end
        if package:config("imgui") then
            package:add("deps", "imgui", {configs = {glfw_opengl3 = true}})
            package:add("deps", "glad")
        end
        if package:config("embree") then
            package:add("deps", "embree")
        end
    end)

    on_install("macosx", "linux", "windows", "mingw", function (package)
        if package:config("imgui") then
            local igl_imgui_dir = package:resourcefile("libigl_imgui")
            os.cp(path.join(igl_imgui_dir, "imgui_fonts_droid_sans.h"), package:installdir("include"))
        end
        if package:config("header_only") then
            os.cp("include/igl", package:installdir("include"))
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

        if package:config("imgui") then 
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    Eigen::MatrixXd V;
                    Eigen::MatrixXi F;
                    igl::opengl::glfw::Viewer viewer;
                    viewer.data().set_mesh(V, F);
                    viewer.launch();
                }
            ]]}, {configs = {languages = "c++14"}, includes = {"igl/opengl/glfw/Viewer.h", "Eigen/Dense", "Eigen/Sparse"}}))
        end

        if package:config("embree") then
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    Eigen::MatrixXf V;
                    Eigen::MatrixXi F;
                    igl::embree::EmbreeIntersector ei;
                    ei.init(V,F);

                    igl::Hit hit{};
                    Eigen::Vector3f look_from{1.0f, 1.0f, 1.0f}, dir{1.0f, 1.0f, 1.0f};
                    bool is_hit = ei.intersectRay(look_from, dir, hit);
                }
            ]]}, {configs = {languages = "c++14"}, includes = {"igl/embree/EmbreeIntersector.h", "igl/Hit.h", "Eigen/Dense", "Eigen/Sparse"}}))
        end

    end)
