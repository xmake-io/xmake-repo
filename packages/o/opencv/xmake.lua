package("opencv")

    set_homepage("https://opencv.org/")
    set_description("A open source computer vision library.")

    add_urls("https://github.com/opencv/opencv/archive/$(version).tar.gz",
             "https://github.com/opencv/opencv.git")

    add_versions("4.2.0", "9ccb2192d7e8c03c58fee07051364d94ed7599363f3b0dce1c5e6cc11c1bb0ec")
    add_versions("3.4.9", "b7ea364de7273cfb3b771a0d9c111b8b8dfb42ff2bcd2d84681902fb8f49892a")

    add_deps("cmake", "python 3.x", {kind = "binary"})

    if is_plat("macosx") then
        add_frameworks("Foundation", "CoreFoundation", "CoreGraphics", "AppKit", "OpenCL")
    elseif is_plat("linux") then
        add_deps("zlib")
        add_syslinks("pthread", "dl")
    end

    add_resources("4.2.0", "opencv_contrib", "https://github.com/opencv/opencv_contrib/archive/4.2.0.tar.gz", "8a6b5661611d89baa59a26eb7ccf4abb3e55d73f99bb52d8f7c32265c8a43020")
    add_resources("3.4.9", "opencv_contrib", "https://github.com/opencv/opencv_contrib/archive/3.4.9.tar.gz", "dc7d95be6aaccd72490243efcec31e2c7d3f21125f88286186862cf9edb14a57")

    on_load(function (package)
        if package:version():ge("4.0") then
            package:add("includedirs", "include/opencv4")
        end
    end)

    on_install("linux", "macosx", function (package)
        local configs = {"-DCMAKE_OSX_DEPLOYMENT_TARGET=",
                         "-DBUILD_JASPER=OFF",
                         "-DBUILD_JPEG=ON",
                         "-DBUILD_OPENEXR=OFF",
                         "-DBUILD_PERF_TESTS=OFF",
                         "-DBUILD_PNG=OFF",
                         "-DBUILD_TESTS=OFF",
                         "-DBUILD_TIFF=OFF",
                         "-DBUILD_ZLIB=OFF",
                         "-DBUILD_opencv_hdf=OFF",
                         "-DBUILD_opencv_java=OFF",
                         "-DBUILD_opencv_text=ON",
                         "-DOPENCV_ENABLE_NONFREE=ON",
                         "-DOPENCV_GENERATE_PKGCONFIG=ON",
                         "-DWITH_1394=OFF",
                         "-DWITH_CUDA=OFF",
                         "-DWITH_EIGEN=ON",
                         "-DWITH_FFMPEG=ON",
                         "-DWITH_GPHOTO2=OFF",
                         "-DWITH_GSTREAMER=OFF",
                         "-DWITH_JASPER=OFF",
                         "-DWITH_OPENEXR=ON",
                         "-DWITH_OPENGL=OFF",
                         "-DWITH_QT=OFF",
                         "-DWITH_TBB=ON",
                         "-DWITH_VTK=OFF",
                         "-DWITH_ITT=OFF",
                         "-DWITH_IPP=OFF",
                         "-DWITH_LAPACK=OFF",
                         "-DBUILD_opencv_python2=OFF",
                         "-DBUILD_opencv_python3=ON"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        local resourcedir = package:resourcedir("opencv_contrib")
        if resourcedir then
            import("lib.detect.find_path")
            local modulesdir = assert(find_path("modules", path.join(resourcedir, "*")), "modules not found!")
            table.insert(configs, "-DOPENCV_EXTRA_MODULES_PATH=" .. path.absolute(path.join(modulesdir, "modules")))
        end
        import("package.tools.cmake").install(package, configs)
        os.trycp("3rdparty/**/*.a", package:installdir("lib"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            void test(int argc, char** argv) {
                cv::CommandLineParser parser(argc, argv, "{help h||show help message}");
                if (parser.has("help")) {
                    parser.printMessage();
                }
                std::cout << CV_VERSION << std::endl;
            }
        ]]}, {configs = {languages = "c++11"},
              includes = package:version():ge("4.0") and "opencv2/opencv.hpp" or "opencv/cv.h"}))
    end)
