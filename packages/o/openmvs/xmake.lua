package("openmvs")
    set_homepage("https://github.com/cdcseacave/openMVS")
    set_description("open Multi-View Stereo reconstruction library")
    set_license("AGPL-3.0")

    add_urls("https://github.com/cdcseacave/openMVS/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cdcseacave/openMVS.git")

    add_versions("v2.3.0", "ac7312fb71dbab18c5b2755ad9ac3caa40ec689f6f369c330ca73c87c1f34258")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_configs("ceres", {description = "Enable CERES optimization library", default = false, type = "boolean"})
    add_configs("cuda", {description = "Enable CUDA library", default = false, type = "boolean"})
    add_configs("openmp", {description = "Enable OpenMP library", default = true, type = "boolean"})
    add_configs("python", {description = "Enable Python library bindings", default = false, type = "boolean"})

    add_deps("cmake", "cgal", "eigen <5.0", "glew", "opencv", "vcglib", "zstd")
    add_deps("boost", {configs = {iostreams = true, container = true, graph=true, program_options = true, serialization = true, thread = true, zlib = true, zstd = true}})

    if on_check then
        on_check("linux", function (package)
            assert(not package:has_tool("cxx", "clang"), "Linux Clang is not supported yet.")
        end)
    end

    add_includedirs("include", "include/OpenMVS")
    add_linkdirs("lib/OpenMVS")
    add_links("MVS", "Math", "IO", "Common")
    on_load(function (package)
        if package:has_tool("cxx", "cl") then
            package:add("cxxflags", "/Zc:__cplusplus")
        end

        if package:config("ceres") then package:add("deps", "ceres-solver") end
        if package:config("cuda") then package:add("deps", "cuda") end
        if package:config("openmp") then package:add("deps", "openmp") end
        if package:config("python") then package:add("deps", "python") end
    end)

    on_install("windows|!arm64", "linux", function (package)
        io.replace("CMakeLists.txt", "# Project-wide settings", [[
            # Project-wide settings
            find_package(PkgConfig REQUIRED)
            pkg_check_modules(libzstd REQUIRED IMPORTED_TARGET libzstd)
        ]], {plain = true})
        io.replace("libs/Common/Types.h", "#include <new>", "#include <new>\n#include <bitset>", {plain = true})
        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DOpenMVS_USE_PYTHON=" .. (package:config("python") and "ON" or "OFF"),
            "-DOpenMVS_USE_CERES=" .. (package:config("ceres") and "ON" or "OFF"),
            "-DOpenMVS_USE_CUDA=" .. (package:config("cuda") and "ON" or "OFF"),
            "-DCGAL_DISABLE_GMP=ON",
            "-DOpenMVS_BUILD_TOOLS=OFF",
            "-DOpenMVS_ENABLE_TESTS=OFF",
        }
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "MVS.h"
            using namespace MVS;
            void test() {
                SEACAVE::cListTest<true>(100);
                SEACAVE::OctreeTest<double,2>(100);
                SEACAVE::OctreeTest<float,3>(100);
                SEACAVE::TestRayTriangleIntersection<float>(1000);
                SEACAVE::TestRayTriangleIntersection<double>(1000);
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
