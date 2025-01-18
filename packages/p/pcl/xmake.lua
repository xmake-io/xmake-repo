package("pcl")

    set_homepage("https://pointclouds.org/")
    set_description("The Point Cloud Library (PCL) is a standalone, large scale, open project for 2D/3D image and point cloud processing.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/PointCloudLibrary/pcl/archive/refs/tags/pcl-$(version).tar.gz",
             "https://github.com/PointCloudLibrary/pcl.git")
    add_versions("1.12.0", "21dfa9a268de9675c1f94d54d9402e4e02120a0aa4215d064436c52b7d5bd48f")
    add_versions("1.12.1", "dc0ac26f094eafa7b26c3653838494cc0a012bd1bdc1f1b0dc79b16c2de0125a")
    add_versions("1.14.0", "de297b929eafcb93747f12f98a196efddf3d55e4edf1b6729018b436d5be594d")
    add_versions("1.14.1", "5dc5e09509644f703de9a3fb76d99ab2cc67ef53eaf5637db2c6c8b933b28af6")

    add_patches("1.14.1", "patches/1.14.1/octree_poisson.patch", "5423a29bbb3f51bb66dca3bcb7851e037944cc33e62e816a8a8d2d00b0bdc964")
    add_patches("1.14.1", "patches/1.14.1/sparse_matrix.patch", "90b20730956104f3ed61fc2d4de156401d0c470257def7ac4e1e2ec0a9456442")
    add_patches("1.14.1", "patches/1.14.1/correspondence_rejection_features.patch", "20bc608eb0bd7892a6c5fc34773fd7479021d6f5f2e6f311c17b5fe60ddff6fe")

    add_configs("vtk", {description = "Build with vtk.", default = false, type = "boolean"})
    add_configs("cuda", {description = "Build with cuda.", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("eigen", "lz4", "flann", "zlib", "libpng", "qhull", "glew")
    on_load("windows", "linux", "macosx", function (package)
        package:add("includedirs", "include/pcl-" .. package:version():major() .. "." .. package:version():minor())

        if package:version():le("1.14.1") then
            package:add("deps", "boost", {version = "1.85.0", configs = {filesystem = true, serialization = true, date_time = true, iostreams = true, system = true, thread = true, graph = true}})
        else
            package:add("deps", "boost", {configs = {asio = true, filesystem = true, serialization = true, date_time = true, iostreams = true, system = true, thread = true, graph = true}})
        end

        if package:config("vtk") then
            package:add("deps", "vtk")
        end
        if package:config("cuda") then
            package:add("deps", "cuda", {system = true})
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        io.replace("CMakeLists.txt", "set(CMAKE_CXX_FLAGS_DEFAULT \"/DWIN32 /D_WINDOWS /W3 /GR /EHsc\")", "set(CMAKE_CXX_FLAGS_DEFAULT \" /DWIN32 /D_WINDOWS /W3 /GR /EHsc\")\nstring(APPEND CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS_DEFAULT})", {plain = true})
        io.replace("cmake/Modules/FindFLANN.cmake", "flann_cpp", "flann")
        if package:version():le("1.12.0") then
            io.replace("cmake/pcl_options.cmake", "set(CMAKE_FIND_LIBRARY_SUFFIXES", "#set(CMAKE_FIND_LIBRARY_SUFFIXES", {plain = true})
        end

        local configs = {"-DWITH_OPENGL=OFF", "-DWITH_PCAP=OFF", "-DWITH_QT=OFF", "-DWITH_LIBUSB=OFF", "-DBoost_USE_STATIC_LIBS=ON", "-DPCL_ALLOW_BOTH_SHARED_AND_STATIC_DEPENDENCIES=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DPCL_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_VTK=" .. (package:config("vtk") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = {"lz4", "dl"}})
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                using PointT = pcl::PointXYZI;
                pcl::PointCloud<PointT>::Ptr cloud (new pcl::PointCloud<PointT>);
            }
        ]]}, {configs = {languages = "c++14"}, includes = {"pcl/point_cloud.h", "pcl/point_types.h"}}))
    end)
