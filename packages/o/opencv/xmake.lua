package("opencv")

    set_homepage("https://opencv.org/")
    set_description("A open source computer vision library.")

    add_urls("https://github.com/opencv/opencv/archive/$(version).tar.gz",
             "https://github.com/opencv/opencv.git")

    add_versions("4.2.0", "9ccb2192d7e8c03c58fee07051364d94ed7599363f3b0dce1c5e6cc11c1bb0ec")

    add_deps("cmake", "python 3.x")

    add_includedirs("include/opencv4")
    if is_plat("macosx") then
        add_frameworks("Foundation", "CoreFoundation", "CoreGraphics", "AppKit", "OpenCL")
    elseif is_plat("linux") then
        add_syslinks("pthread", "dl")
    end

    on_load(function (package)
        package:data_set("install_modules", function()

            import("net.http")
            import("utils.archive")
            import("lib.detect.find_path")

            local contrib_resources = 
            {
                ["4.2.0"] = 
                {
                    url = "https://github.com/opencv/opencv_contrib/archive/4.2.0.tar.gz",
                    sha256 = "8a6b5661611d89baa59a26eb7ccf4abb3e55d73f99bb52d8f7c32265c8a43020"
                }
            }
            local resource = contrib_resources[package:version_str()]
            if resource then
                local resourcefile = path.join(os.curdir(), path.filename(resource.url))
                local resourcedir = resourcefile .. ".dir"
                http.download(resource.url, resourcefile)
                assert(resource.sha256 == hash.sha256(resourcefile), "unmatched resource checksum!")
                assert(archive.extract(resourcefile, resourcedir), "extract resource failed!")
                local modulesdir = assert(find_path("modules", path.join(resourcedir, "*")), "modules not found!")
                return path.absolute(path.join(modulesdir, "modules"))
            end
        end)
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
        if is_plat("linux") then
            table.insert(configs, "-DBUILD_ZLIB=ON")
        end
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        local modulesdir = package:data("install_modules")()
        if modulesdir then
            table.insert(configs, "-DOPENCV_EXTRA_MODULES_PATH=" .. modulesdir)
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <opencv2/opencv.hpp>
            #include <iostream>
            void test(int argc, char** argv) {
                cv::CommandLineParser parser(argc, argv, "{help h||show help message}");
                if (parser.has("help")) {
                    parser.printMessage();
                }
                cv::namedWindow("Image", 1);
                std::cout << CV_VERSION << std::endl;
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
