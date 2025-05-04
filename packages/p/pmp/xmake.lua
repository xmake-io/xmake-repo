package("pmp")

    set_homepage("http://www.pmp-library.org/")
    set_description("The Polygon Mesh Processing Library")
    set_license("MIT")

    add_urls("https://github.com/pmp-library/pmp-library/archive/refs/tags/$(version).tar.gz",
             "https://github.com/pmp-library/pmp-library.git")
    add_versions("3.0.0", "4533676c7ff8fe816253cb47e1a330e07e044101bdeb9b7b3a1fb437fdc0e4a1")
    add_versions("1.2.1", "4c9e6554a986710cec1e19dd67695d8ae65ce02a19100dcf1ba7e17f2f993e3b")

    add_configs("utils", {description = "Build utilities.", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("eigen", "glfw", "glew", "rply")
    on_install("windows", "macosx", "linux", function (package)
        local configs = {}
        if package:is_plat("linux") and package:config("pic") ~= false then
            configs.cxflags = "-fPIC"
        end
        configs.utils = package:config("utils")
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
        if package:config("utils") then
            package:addenv("PATH", "bin")
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                pmp::SurfaceMesh mesh;
                pmp::Vertex v0, v1, v2, v3;
                v0 = mesh.add_vertex(pmp::Point(0, 0, 0));
                v1 = mesh.add_vertex(pmp::Point(1, 0, 0));
                v2 = mesh.add_vertex(pmp::Point(0, 1, 0));
                v3 = mesh.add_vertex(pmp::Point(0, 0, 1));
            }
        ]]}, {configs = {languages = "c++17"}, includes = "pmp/SurfaceMesh.h"}))
    end)
