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
    add_versions("1.15.1", "e1d862c7b6bd27a45884a825a2e509bfcbd4561307d5bfe17ce5c8a3d94a6c29")

    add_patches("1.14.1", "patches/1.14.1/clang.patch", "01bf08ac7eafc5748d38fdabac1be3b18b9ec1b2e88a4f458a2cfab3dfac5356")
    add_patches("1.14.1", "patches/1.14.1/msbuild.patch", "2a256b8916d8c32c204bf0ec57b279d212856a5a1b28ef174aaa63e14554d082")

    add_configs("cuda",          {description = "Build with cuda",     default = false,  type = "boolean"})
    add_configs("glew",          {description = "Build with glew",     default = true,   type = "boolean"})
    add_configs("libpng",        {description = "Build with libpng",   default = true,   type = "boolean"})
    add_configs("libusb",        {description = "Build with libusb",   default = true,   type = "boolean"})
    add_configs("opengl",        {description = "Build with opengl",   default = true,   type = "boolean"})
    add_configs("openmp",        {description = "Build with openmp",   default = false,  type = "boolean"})
    add_configs("libpcap",       {description = "Build with pcap",     default = false,  type = "boolean"})
    add_configs("qhull",         {description = "Build with qhull",    default = true,   type = "boolean"})
    add_configs("vtk",           {description = "Build with vtk",      default = false,  type = "boolean"})
    add_configs("visualization", {description = "Build visualization", default = false,  type = "boolean"})
    add_configs("apps",          {description = "Build apps",          default = false,  type = "boolean"})
    add_configs("tools",         {description = "Build tools",         default = false,  type = "boolean"})
    add_configs("qt",            {description = "Build with qt",       default = "AUTO", type = "string", values = {"AUTO", "YES", "QT6", "QT5", "NO"}})

    add_deps("cmake")
    add_deps("cjson", "eigen", "flann", "lz4", "nanoflann", "zlib")
    on_load(function (package)
        package:add("includedirs", "include/pcl-" .. package:version():major() .. "." .. package:version():minor())

        if package:version():le("1.14.1") then
            package:add("deps", "boost", {version = "1.85.0", configs = {filesystem = true, serialization = true, date_time = true, iostreams = true, system = true, thread = true, graph = true}})
        else
            package:add("deps", "boost", {configs = {asio = true, filesystem = true, serialization = true, date_time = true, iostreams = true, system = true, thread = true, graph = true}})
        end
        local confs = {"cuda", "glew", "libpng", "libusb", "opengl", "openmp", "libpcap", "qhull", "vtk"}
        for _, conf in ipairs(confs) do
            if package:config(conf) then
                package:add("deps", conf)
            end
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        io.replace("CMakeLists.txt", "set(CMAKE_CXX_FLAGS_DEFAULT \"/DWIN32 /D_WINDOWS /W3 /GR /EHsc\")", "set(CMAKE_CXX_FLAGS_DEFAULT \" /DWIN32 /D_WINDOWS /W3 /GR /EHsc\")\nstring(APPEND CMAKE_CXX_FLAGS ${CMAKE_CXX_FLAGS_DEFAULT})", {plain = true})
        io.replace("CMakeLists.txt", "find_package(GLEW QUIET)", "find_package(GLEW CONFIG)", {plain = true})
        io.replace("cmake/Modules/FindFLANN.cmake", "flann_cpp", "flann")
        if package:version():le("1.12.0") then
            io.replace("cmake/pcl_options.cmake", "set(CMAKE_FIND_LIBRARY_SUFFIXES", "#set(CMAKE_FIND_LIBRARY_SUFFIXES", {plain = true})
        end

        local configs = {
            "-DBUILD_examples=OFF",
            "-DBoost_USE_STATIC_LIBS=ON",
            "-DPCL_ALLOW_BOTH_SHARED_AND_STATIC_DEPENDENCIES=ON"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DPCL_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_QT=" .. package:config("qt"))
        table.insert(configs, "-DBUILD_apps=" .. (package:config("apps") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_tools=" .. (package:config("tools") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_visualization=" .. (package:config("visualization") and "ON" or "OFF"))
        local confs = { "cuda", "glew", "libusb", "opengl", "openmp", "qhull", "vtk" }
        for _, conf in ipairs(confs) do
            table.insert(configs, "-DWITH_" .. conf:upper() .. "=" .. (package:config(conf) and "ON" or "OFF"))
        end
        table.insert(configs, "-DWITH_PCAP=" .. (package:config("libpcap") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_PNG=" .. (package:config("libpng") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DBoost_USE_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end

        local opt = {packagedeps = {"lz4", "dl"}}
        if package:config("shared") and package:is_plat("macosx") then
            opt.shflags = {"-framework", "CoreFoundation", "-framework", "IOKit", "-framework", "Security"}
        end
        import("package.tools.cmake").install(package, configs, opt)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                using PointT = pcl::PointXYZI;
                pcl::PointCloud<PointT>::Ptr cloud (new pcl::PointCloud<PointT>);
            }
        ]]}, {configs = {languages = package:version():gt("1.15") and "c++17" or "c++14"}, includes = {"pcl/point_cloud.h", "pcl/point_types.h"}}))
    end)
