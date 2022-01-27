package("openmesh")

    set_homepage("https://www.graphics.rwth-aachen.de/software/openmesh/")
    set_description("OpenMesh is a generic and efficient data structure for representing and manipulating polygonal meshes.")
    set_license("BSD-3-Clause")

    add_urls("https://www.graphics.rwth-aachen.de/media/openmesh_static/Releases/$(version)/OpenMesh-$(version).tar.gz")
    add_versions("8.1", "0953777f483d47ea9fa00c329838443a7a09dde8be77bf7de188001cb9e768a7")
    add_versions("9.0", "b9574c921482798ce75a8bf578345a84b928ca26ee759219d21b310e2db9d006")

    add_deps("cmake")
    if is_plat("windows") then
        add_defines("_USE_MATH_DEFINES")
    end
    
    on_install("windows", "macosx", "linux", function (package)
        io.replace("CMakeLists.txt", "add_subdirectory (src/Unittests)", "", {plain = true})
        local configs = {"-DOPENMESH_DOCS=OFF", "-DBUILD_APPS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DOPENMESH_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        if package:is_plat("windows") and package:config("shared") then
            os.trymv(package:installdir("*.dll"), package:installdir("bin"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                typedef OpenMesh::PolyMesh_ArrayKernelT<> MyMesh;
                MyMesh mesh;
                MyMesh::VertexHandle vhandle[8];
                vhandle[0] = mesh.add_vertex(MyMesh::Point(-1, -1,  1));
            }
        ]]}, {configs = {languages = "c++11"}, includes = "OpenMesh/Core/Mesh/PolyMesh_ArrayKernelT.hh"}))
    end)
