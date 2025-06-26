package("openmvg")
    set_homepage("https://github.com/openMVG/openMVG")
    set_description("open Multiple View Geometry library. Basis for 3D computer vision and Structure from Motion.")
    set_license("MPL-2.0")

    add_urls("https://github.com/openMVG/openMVG.git")
    add_versions("2.1", "01193a245ee3c36458e650b1cf4402caad8983ef")

    add_configs("openmp", {description = "Enable OpenMP parallelization", default = true, type = "boolean"})
    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    if is_subhost("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end
    add_deps("eigen", "libpng", "libjpeg", "libtiff", "flann", "lemon")

    if on_check then
        on_check("linux", function (package)
            assert(not package:has_tool("cxx", "clang"), "Linux Clang is not supported.")
        end)
    end

    on_load(function (package)
        if package:config("openmp") then
            package:add("deps", "openmp")
        end

        local libs = {"lib_CoinUtils", "lib_Osi", "lib_OsiClpSolver", "lib_clp", "openMVG_ceres", "openMVG_easyexif", "openMVG_exif", "openMVG_fast", "openMVG_features", "openMVG_geometry", "openMVG_image", "openMVG_kvld", "openMVG_lInftyComputerVision", "openMVG_linearProgramming", "openMVG_matching", "openMVG_matching_image_collection", "openMVG_multiview", "openMVG_numeric", "openMVG_robust_estimation", "openMVG_sfm", "openMVG_stlplus", "openMVG_system", "vlsift"}
        for _, lib in ipairs(libs) do
            package:add("links", lib)
        end
    end)

    on_install("windows|!arm*", "linux", "macosx", function (package)
        local flann = package:dep("flann")
        local lemon = package:dep("lemon")
        if not flann:is_system() then
            io.replace("src/CMakeLists.txt", "find_package(Flann QUIET CONFIG)", "include(FindPkgConfig)\npkg_search_module(flann REQUIRED IMPORTED_TARGET flann)", {plain = true})
            io.replace("src/CMakeLists.txt", "find_package(Flann QUIET)", "include(FindPkgConfig)\npkg_search_module(flann REQUIRED IMPORTED_TARGET flann)", {plain = true})
            io.replace("src/openMVG/matching/CMakeLists.txt", "$<BUILD_INTERFACE:${FLANN_INCLUDE_DIRS}>", "", {plain = true})
            io.replace("src/openMVG/matching/CMakeLists.txt", "${FLANN_LIBRARIES}", "PkgConfig::flann", {plain = true})
        end
        if not lemon:is_system() then
            io.replace("src/CMakeLists.txt", "find_package(Lemon QUIET)", "include(FindPkgConfig)\npkg_search_module(lemon REQUIRED IMPORTED_TARGET lemon)", {plain = true})
            io.replace("src/openMVG/graph/CMakeLists.txt", "${LEMON_LIBRARY}", "PkgConfig::lemon", {plain = true})
        end
        if package:is_plat("windows") then
            io.replace("src/openMVG/matching/metric_hamming.hpp", "#ifdef _MSC_VER",
                       "#if defined(_MSC_VER) && (defined(_M_X64) || defined(_M_IX86) || defined(_M_ARM64) || defined(_M_ARM64EC))", {plain = true})
            package:add("defines", "_USE_MATH_DEFINES")
        end

        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DOpenMVG_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"),
            "-DOpenMVG_BUILD_COVERAGE=OFF",
            "-DOpenMVG_BUILD_TESTS=OFF",
            "-DOpenMVG_BUILD_DOC=OFF",
            "-DOpenMVG_BUILD_EXAMPLES=OFF",
            "-DOpenMVG_BUILD_OPENGL_EXAMPLES=OFF",
            "-DOpenMVG_BUILD_SOFTWARES=OFF",
            "-DOpenMVG_BUILD_GUI_SOFTWARES=OFF",
            "-DFLANN_INCLUDE_DIR_HINTS=1",
            "-DLEMON_INCLUDE_DIR_HINTS=1",
        }

        os.cd("src")
        import("package.tools.cmake").install(package, configs)

        os.rm(package:installdir("lib/pkgconfig/*.pc"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <openMVG/geometry/pose3.hpp>
            #include <openMVG/numeric/numeric.h>
            using namespace openMVG;
            using namespace openMVG::geometry;
            void test() {
                Pose3 pose1(RotationAroundX(0.02), Vec3(0,0,-2));
                Pose3 pose2(RotationAroundX(0.06), Vec3(-1,0,-2));
                Pose3 combinedPose = pose1 * pose2;
                const Vec3 pt = combinedPose(Vec3(2.6453,3.32,6.3));
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
