package("openvdb")

    set_homepage("https://www.openvdb.org/")
    set_description("OpenVDB - Sparse volume data structure and tools")

    add_urls("https://github.com/AcademySoftwareFoundation/openvdb/archive/v$(version).tar.gz",
             "https://github.com/AcademySoftwareFoundation/openvdb.git")
    add_versions("7.1.0", "0c3588c1ca6e647610738654ec2c6aaf41a203fd797f609fbeab1c9f7c3dc116")
    add_versions("8.0.1", "a6845da7c604d2c72e4141c898930ac8a2375521e535f696c2cd92bebbe43c4f")

    add_deps("cmake")
    add_deps("boost", {system = false, configs = {regex = true, system = true, iostreams = true}})

    add_configs("with_houdini", {description = "Location of Houdini installation. Set to enable built with Houdini.", default = "", type = "string"})
    add_configs("with_maya", {description = "Location of Maya installation. Set to enable built with Maya.", default = "", type = "string"})
    add_configs("simd", {description = "SIMD acceleration architecture.", default = "None", type = "string", values = {"None", "SSE42", "AVX"}})
    add_configs("print", {description = "Command line binary for displaying information about OpenVDB files.", default = true, type = "boolean"})
    add_configs("lod", {description = "Command line binary for generating volume mipmaps from an OpenVDB grid.", default = false, type = "boolean"})
    add_configs("render", {description = "Command line binary for ray-tracing OpenVDB grids.", default = false, type = "boolean"})
    add_configs("view", {description = "Command line binary for displaying OpenVDB grids in a GL viewport.", default = false, type = "boolean"})

    on_load("macosx", "linux", "windows", function (package)
        if package:config("with_houdini") == "" then
            package:add("deps", "zlib")
            package:add("deps", "blosc ~1.5.0", {configs = {shared = package:is_plat("linux")}})
            package:add("deps", "openexr", {configs = {shared = package:is_plat("windows")}})
            if package:config("with_maya") == "" then
                package:add("deps", "tbb <2021.0", {configs = {shared = true}})
            end
        end
        if package:config("view") then
            package:add("deps", "glew", {configs = {shared = true}})
            package:add("deps", "glfw")
        end
        if not package:config("shared") then
            package:add("defines", "OPENVDB_STATICLIB")
        end
        if package:is_plat("windows") then
            package:add("defines", "_USE_MATH_DEFINES")
            package:add("defines", "NOMINMAX")
        end
    end)

    on_install("macosx", "linux", "windows", function (package)
        local configs = {"-DOPENVDB_BUILD_DOCS=OFF", "-DUSE_PKGCONFIG=OFF", "-DBoost_USE_STATIC_LIBS=ON", "-DUSE_CCACHE=OFF"}
        if package:config("shared") then
            table.insert(configs, "-DOPENVDB_CORE_SHARED=ON")
            table.insert(configs, "-DOPENVDB_CORE_STATIC=OFF")
        else
            table.insert(configs, "-DOPENVDB_CORE_SHARED=OFF")
            table.insert(configs, "-DOPENVDB_CORE_STATIC=ON")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:is_plat("windows") then
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        table.insert(configs, "-DOPENVDB_BUILD_VDB_LOD=" .. (package:config("lod") and "ON" or "OFF"))
        table.insert(configs, "-DOPENVDB_BUILD_VDB_PRINT=" .. (package:config("print") and "ON" or "OFF"))
        table.insert(configs, "-DOPENVDB_BUILD_VDB_RENDER=" .. (package:config("render") and "ON" or "OFF"))
        table.insert(configs, "-DOPENVDB_BUILD_VDB_VIEW=" .. (package:config("view") and "ON" or "OFF"))
        table.insert(configs, "-DOPENVDB_SIMD=" .. package:config("simd"))
        if package:config("with_houdini") ~= "" then
            table.insert(configs, "-DUSE_HOUDINI=ON")
            table.insert(configs, "-DOPENVDB_BUILD_HOUDINI_PLUGIN=ON")
            table.insert(configs, "-DHoudini_ROOT=" .. package:config("with_houdini"))
        elseif package:config("with_maya") ~= "" then
            table.insert(configs, "-DUSE_MAYA=ON")
            table.insert(configs, "-DOPENVDB_BUILD_MAYA_PLUGIN=ON")
            table.insert(configs, "-DMaya_ROOT=" .. package:config("with_maya"))
        else
            table.insert(configs, "-DUSE_BLOSC=ON")
            table.insert(configs, "-DUSE_EXR=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                openvdb::initialize();
                openvdb::FloatGrid::Ptr grid = openvdb::tools::createLevelSetSphere<openvdb::FloatGrid>(
                    /*radius=*/50.0, /*center=*/openvdb::Vec3f(1.5, 2, 3),
                    /*voxel size=*/0.5, /*width=*/4.0
                );
            }
        ]]}, {configs = {languages = "c++14"},
              includes = {"openvdb/openvdb.h", "openvdb/tools/LevelSetSphere.h"}}))
    end)
