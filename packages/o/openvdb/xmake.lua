package("openvdb")

    set_homepage("https://www.openvdb.org/")
    set_description("OpenVDB - Sparse volume data structure and tools")
    set_license("MPL-2.0")

    add_urls("https://github.com/AcademySoftwareFoundation/openvdb/archive/refs/tags/$(version).tar.gz",
             "https://github.com/AcademySoftwareFoundation/openvdb.git")
    add_versions("v7.1.0", "0c3588c1ca6e647610738654ec2c6aaf41a203fd797f609fbeab1c9f7c3dc116")
    add_versions("v8.0.1", "a6845da7c604d2c72e4141c898930ac8a2375521e535f696c2cd92bebbe43c4f")
    add_versions("v8.1.0", "3e09d47331429be7409a3a3c27fdd3c297f96d31d2153febe194e664a99d6183")
    add_versions("v8.2.0", "d2e77a0720db79e9c44830423bdb013c24a1cf50994dd61d570b6e0c3e0be699")
    add_versions("v9.0.0", "ad3816e8f1931d1d6fdbddcec5a1acd30695d049dd10aa965096b2fb9972b468")
    add_versions("v9.1.0", "914ee417b4607c75c95b53bc73a0599de4157c7d6a32e849e80f24e40fb64181")
    add_versions("v10.0.1", "887a3391fbd96b20c77914f4fb3ab4b33d26e5fc479aa036d395def5523c622f")
    add_versions("v10.1.0", "2746236e29659a0d35ab90d832f7c7987dd2537587a1a2f9237d9c98afcd5817")
    add_versions("v11.0.0", "6314ff1db057ea90050763e7b7d7ed86d8224fcd42a82cdbb9c515e001b96c74")

    add_patches(">=10.1.0", "patches/10.1.0/blosc-dep.patch", "a1a5adf4ae2c75c3a3a390b25654dd7785b88d15e459a1620fc0b42b20f81ba0")

    add_deps("cmake")
    add_deps("boost >1.73", {configs = {regex = true, system = true, iostreams = true}})

    add_configs("with_houdini", {description = "Location of Houdini installation. Set to enable built with Houdini.", default = "", type = "string"})
    add_configs("with_maya", {description = "Location of Maya installation. Set to enable built with Maya.", default = "", type = "string"})
    add_configs("simd", {description = "SIMD acceleration architecture.", type = "string", values = {"None", "SSE42", "AVX"}})
    add_configs("print", {description = "Command line binary for displaying information about OpenVDB files.", default = true, type = "boolean"})
    add_configs("lod", {description = "Command line binary for generating volume mipmaps from an OpenVDB grid.", default = false, type = "boolean"})
    add_configs("render", {description = "Command line binary for ray-tracing OpenVDB grids.", default = false, type = "boolean"})
    add_configs("view", {description = "Command line binary for displaying OpenVDB grids in a GL viewport.", default = false, type = "boolean"})
    add_configs("ax", {description = "Command line binary for OpenVDB AX.", default = false, type = "boolean"})
    add_configs("nanovdb", {description = "Enable building of NanoVDB Module.", default = false, type = "boolean"})
    add_configs("nanovdb_tools", {description = "Build NanoVDB command-line tools.", default = false, type = "boolean"})

    on_load("macosx", "linux", "windows|x64", "windows|x86", function (package)
        if package:config("with_houdini") == "" then
            package:add("deps", "zlib")
            if package:version():ge("9.0.0") then
                package:add("deps", "blosc")
            else
                package:add("deps", "blosc ~1.5.0", {configs = {shared = package:is_plat("linux")}})
                package:add("deps", "openexr 2.x", {configs = {shared = package:is_plat("windows")}})
            end
            if package:config("with_maya") == "" then
                package:add("deps", package:version():ge("9.0.0") and "tbb" or "tbb <2021.0")
            end
        end
        if package:config("view") then
            package:add("deps", "glew", {configs = {shared = true}})
            package:add("deps", "glfw")
        end
        if package:config("render") then
            package:add("deps", "libpng")
        end
        if not package:config("shared") then
            package:add("defines", "OPENVDB_STATICLIB")
        end
        if package:version():ge("9.0.0") and package:config("nanovdb") then
            package:add("deps", "cuda")
            package:add("deps", "optix")
        end
        if package:is_plat("windows") then
            package:add("defines", "_USE_MATH_DEFINES")
            package:add("defines", "NOMINMAX")
        end
    end)

    on_install("macosx", "linux", "windows|x64", "windows|x86", function (package)
        io.replace("cmake/FindBlosc.cmake", "${BUILD_TYPE} ${_BLOSC_LIB_NAME}", "${BUILD_TYPE} blosc libblosc", {plain = true})
        io.replace("cmake/FindBlosc.cmake", "lz4 snappy zlib zstd", "lz4", {plain = true})
        io.replace("cmake/FindTBB.cmake", "Tbb_${COMPONENT}_LIB_TYPE STREQUAL STATIC", "TRUE", {plain = true})

        local configs = {
            "-DOPENVDB_BUILD_DOCS=OFF",
            "-DUSE_PKGCONFIG=OFF",
            "-DBoost_USE_STATIC_LIBS=ON",
            "-DUSE_CCACHE=OFF",
            "-DBLOSC_USE_EXTERNAL_SOURCES=ON"
        }

        if package:config("shared") then
            table.insert(configs, "-DOPENVDB_CORE_SHARED=ON")
            table.insert(configs, "-DOPENVDB_CORE_STATIC=OFF")
        else
            table.insert(configs, "-DOPENVDB_CORE_SHARED=OFF")
            table.insert(configs, "-DOPENVDB_CORE_STATIC=ON")
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:is_plat("windows") then
            if package:version():lt("9.0.0") and package:config("shared") and package:config("vs_runtime"):startswith("MT") then
                raise("OpenVDB shared library cannot be linked to a static msvc runtime")
            end
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        table.insert(configs, "-DOPENVDB_BUILD_VDB_LOD=" .. (package:config("lod") and "ON" or "OFF"))
        table.insert(configs, "-DOPENVDB_BUILD_VDB_PRINT=" .. (package:config("print") and "ON" or "OFF"))
        table.insert(configs, "-DOPENVDB_BUILD_BINARIES=" .. (package:config("print") and "ON" or "OFF"))
        table.insert(configs, "-DOPENVDB_BUILD_VDB_RENDER=" .. (package:config("render") and "ON" or "OFF"))
        table.insert(configs, "-DOPENVDB_BUILD_VDB_VIEW=" .. (package:config("view") and "ON" or "OFF"))
        if package:version():ge("10.0") then
            table.insert(configs, "-DOPENVDB_BUILD_VDB_AX=" .. (package:config("ax") and "ON" or "OFF"))
        else
            table.insert(configs, "-DOPENVDB_BUILD_AX_BINARIES=" .. (package:config("ax") and "ON" or "OFF"))
        end
        if package:config("simd") then
            table.insert(configs, "-DOPENVDB_SIMD=" .. package:config("simd"))
        end
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
            if package:version():ge("8.1.0") then
                table.insert(configs, "-DUSE_IMATH_HALF=OFF")
            else
                table.insert(configs, "-DUSE_EXR=ON")
            end
        end
        if package:version():ge("9.0.0") then
            table.insert(configs, "-DUSE_NANOVDB=" .. (package:config("nanovdb") and "ON" or "OFF"))
            table.insert(configs, "-DNANOVDB_BUILD_TOOLS=" .. (package:config("nanovdb_tools") and "ON" or "OFF"))
            table.insert(configs, "-DNANOVDB_USE_CUDA=ON")
        end
        import("package.tools.cmake").install(package, configs)
        package:addenv("PATH", "bin")
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
        ]]}, {configs = {languages = "c++17"},
              includes = {"openvdb/openvdb.h", "openvdb/tools/LevelSetSphere.h"}}))
        if package:version():ge("9.0.0") and package:config("nanovdb") then
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    nanovdb::GridBuilder<float> builder(0.0f);
                    auto acc = builder.getAccessor();
                    acc.setValue(nanovdb::Coord(1, 2, 3), 1.0f);
                }
            ]]}, {configs = {languages = "c++17"},
                  includes = {"nanovdb/util/GridBuilder.h"}}))
        end
    end)
