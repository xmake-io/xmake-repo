package("opencv")

    set_homepage("https://opencv.org/")
    set_description("A open source computer vision library.")
    set_license("Apache-2.0")

    add_urls("https://github.com/opencv/opencv/archive/$(version).tar.gz",
             "https://github.com/opencv/opencv.git")
    add_versions("4.6.0", "1ec1cba65f9f20fe5a41fda1586e01c70ea0c9a6d7b67c9e13edf0cfe2239277")
    add_versions("4.5.5", "a1cfdcf6619387ca9e232687504da996aaa9f7b5689986b8331ec02cb61d28ad")
    add_versions("4.5.4", "c20bb83dd790fc69df9f105477e24267706715a9d3c705ca1e7f613c7b3bad3d")
    add_versions("4.5.3", "77f616ae4bea416674d8c373984b20c8bd55e7db887fd38c6df73463a0647bab")
    add_versions("4.5.2", "ae258ed50aa039279c3d36afdea5c6ecf762515836b27871a8957c610d0424f8")
    add_versions("4.5.1", "e27fe5b168918ab60d58d7ace2bd82dd14a4d0bd1d3ae182952c2113f5637513")
    add_versions("4.2.0", "9ccb2192d7e8c03c58fee07051364d94ed7599363f3b0dce1c5e6cc11c1bb0ec")
    add_versions("3.4.9", "b7ea364de7273cfb3b771a0d9c111b8b8dfb42ff2bcd2d84681902fb8f49892a")

    add_resources("4.6.0", "opencv_contrib", "https://github.com/opencv/opencv_contrib/archive/4.6.0.tar.gz", "1777d5fd2b59029cf537e5fd6f8aa68d707075822f90bde683fcde086f85f7a7")
    add_resources("4.5.5", "opencv_contrib", "https://github.com/opencv/opencv_contrib/archive/4.5.5.tar.gz", "a97c2eaecf7a23c6dbd119a609c6d7fae903e5f9ff5f1fe678933e01c67a6c11")
    add_resources("4.5.4", "opencv_contrib", "https://github.com/opencv/opencv_contrib/archive/4.5.4.tar.gz", "ad74b440b4539619dc9b587995a16b691246023d45e34097c73e259f72de9f81")
    add_resources("4.5.3", "opencv_contrib", "https://github.com/opencv/opencv_contrib/archive/4.5.3.tar.gz", "73da052fd10e73aaba2560eaff10cc5177e2dcc58b27f8aedf7c649e24c233bc")
    add_resources("4.5.2", "opencv_contrib", "https://github.com/opencv/opencv_contrib/archive/4.5.2.tar.gz", "9f52fd3114ac464cb4c9a2a6a485c729a223afb57b9c24848484e55cef0b5c2a")
    add_resources("4.5.1", "opencv_contrib", "https://github.com/opencv/opencv_contrib/archive/4.5.1.tar.gz", "12c3b1ddd0b8c1a7da5b743590a288df0934e5cef243e036ca290c2e45e425f5")
    add_resources("4.2.0", "opencv_contrib", "https://github.com/opencv/opencv_contrib/archive/4.2.0.tar.gz", "8a6b5661611d89baa59a26eb7ccf4abb3e55d73f99bb52d8f7c32265c8a43020")
    add_resources("3.4.9", "opencv_contrib", "https://github.com/opencv/opencv_contrib/archive/3.4.9.tar.gz", "dc7d95be6aaccd72490243efcec31e2c7d3f21125f88286186862cf9edb14a57")

    add_configs("bundled", {description = "Build 3rd-party libraries with OpenCV.", default = true, type = "boolean"})
    add_configs("tesseract", {description = "Enable tesseract on text module", default = false, type = "boolean"})

    local features = {"1394",
                      "vtk",
                      "eigen",
                      "ffmpeg",
                      "gstreamer",
                      "gtk",
                      "ipp",
                      "halide",
                      "vulkan",
                      "jasper",
                      "openjpeg",
                      "jpeg",
                      "webp",
                      "openexr",
                      "opengl",
                      "png",
                      "tbb",
                      "tiff",
                      "itt",
                      "protobuf",
                      "quirc"}
    local default_features = {"1394", "eigen", "ffmpeg", "jpeg", "opengl", "png", "protobuf", "quirc", "webp", "tiff"}
    local function opencv_is_default(feature)
        for _, df in ipairs(default_features) do
            if feature == df then
                return true
            end
        end
        return false
    end

    for _, feature in ipairs(features) do
        add_configs(feature, {description = "Include " .. feature .. " support.", default = opencv_is_default(feature), type = "boolean"})
    end
    add_configs("blas", {description = "Set BLAS vendor.", values = {"mkl", "openblas"}})
    add_configs("cuda", {description = "Enable CUDA support.", default = false, type = "boolean"})
    add_configs("dynamic_parallel", {description = "Dynamically load parallel runtime (TBB etc.).", default = false, type = "boolean"})

    if is_plat("macosx") then
        add_frameworks("Foundation", "CoreFoundation", "CoreGraphics", "AppKit", "OpenCL", "Accelerate")
    elseif is_plat("linux") then
        add_extsources("pacman::opencv", "apt::libopencv-dev")
        add_syslinks("pthread", "dl")
    elseif is_plat("windows", "mingw") then
        add_syslinks("gdi32", "user32", "glu32", "opengl32", "advapi32", "comdlg32", "ws2_32")
    end

    on_load("linux", "macosx", "windows", "mingw@windows,msys", function (package)
        if package:is_plat("windows") then
            local arch = "x64"
            if     package:is_arch("x86")   then arch = "x86"
            elseif package:is_arch("arm64") then arch = "ARM64"
            end
            local linkdir = (package:config("shared") and "lib" or "staticlib")
            local vs = import("core.tool.toolchain").load("msvc"):config("vs")
            local vc_ver = "vc13"
            if     vs == "2015" then vc_ver = "vc14"
            elseif vs == "2017" then vc_ver = "vc15"
            elseif vs == "2019" then vc_ver = "vc16"
            elseif vs == "2022" then vc_ver = "vc17"
            end
            package:add("linkdirs", path.join(arch, vc_ver, linkdir))
        elseif package:is_plat("mingw") then
            local arch = (package:is_arch("x86_64") and "x64" or "x86")
            local linkdir = (package:config("shared") and "lib" or "staticlib")
            package:add("linkdirs", path.join(arch, "mingw", linkdir))
        elseif package:version():ge("4.0") then
            package:add("includedirs", "include/opencv4")
            package:add("linkdirs", "lib", "lib/opencv4/3rdparty")
        end
        if package:config("blas") then
            package:add("deps", package:config("blas"))
        end
        if package:config("cuda") then
            package:add("deps", "cuda", {system = true, configs = {utils = {"cudnn", "cufft", "cublas"}}})
        end
        if package:is_plat("linux") then
            if package:config("gtk") then
                package:add("deps", "gtk+3", {optional = true})
            end
        end
        if not package.is_built or package:is_built() then
            package:add("deps", "cmake", "python 3.x", {kind = "binary"})
        end

        if package:config("tesseract") then
            package:add("deps", "tesseract 4.1.3") -- Opencv need tesseract from the v4 series
        end
    end)

    on_install("linux", "macosx", "windows", "mingw@windows,msys", function (package)
        io.replace("cmake/OpenCVUtils.cmake", "if(PKG_CONFIG_FOUND OR PkgConfig_FOUND)", "if(NOT WIN32 AND (PKG_CONFIG_FOUND OR PkgConfig_FOUND))", {plain = true})
        local configs = {"-DCMAKE_OSX_DEPLOYMENT_TARGET=",
                         "-DBUILD_PERF_TESTS=OFF",
                         "-DBUILD_TESTS=OFF",
                         "-DBUILD_opencv_hdf=OFF",
                         "-DBUILD_opencv_java=OFF",
                         "-DBUILD_opencv_text=ON",
                         "-DOPENCV_ENABLE_NONFREE=ON",
                         "-DOPENCV_GENERATE_PKGCONFIG=ON",
                         "-DBUILD_opencv_python2=OFF",
                         "-DBUILD_opencv_python3=OFF",
                         "-DBUILD_JAVA=OFF"}

        if package:config("tesseract") then
            table.insert(configs, "-DWITH_TESSERACT=ON")
        end
        if package:config("bundled") then
            table.insert(configs, "-DOPENCV_FORCE_3RDPARTY_BUILD=ON")
        end
        for _, feature in ipairs(features) do
            table.insert(configs, "-DWITH_" .. feature:upper() .. "=" .. (package:config(feature) and "ON" or "OFF"))
        end
        if package:config("cuda") then
            table.insert(configs, "-DWITH_CUDA=ON")
        end
        table.insert(configs, "-DPARALLEL_ENABLE_PLUGINS=" .. (package:config("dynamic_parallel") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DBUILD_WITH_STATIC_CRT=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
            if package:is_arch("arm64") then
                local vs = import("core.tool.toolchain").load("msvc"):config("vs")
                assert(tonumber(vs) >= 2022, "opencv requires Visual Studio 2022 and later for arm targets")
                table.insert(configs, "-DCMAKE_SYSTEM_NAME=Windows")
                table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=ARM64")
            end
        elseif package:is_plat("mingw") then
            table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=" .. (package:is_arch("x86_64") and "AMD64" or "i686"))
        end
        local resourcedir = package:resourcedir("opencv_contrib")
        if resourcedir then
            import("lib.detect.find_path")
            local modulesdir = assert(find_path("modules", path.join(resourcedir, "*")), "modules not found!")
            table.insert(configs, "-DOPENCV_EXTRA_MODULES_PATH=" .. path.absolute(path.join(modulesdir, "modules")))
        end
        import("package.tools.cmake").install(package, configs, {buildir = "bd"})
        for _, link in ipairs({"opencv_phase_unwrapping", "opencv_surface_matching", "opencv_saliency", "opencv_wechat_qrcode", "opencv_mcc", "opencv_face", "opencv_img_hash", "opencv_videostab", "opencv_structured_light", "opencv_intensity_transform", "opencv_ccalib", "opencv_line_descriptor", "opencv_stereo", "opencv_dnn_objdetect", "opencv_dnn_superres", "opencv_fuzzy", "opencv_hfs", "opencv_rapid", "opencv_bgsegm", "opencv_bioinspired", "opencv_rgbd", "opencv_dpm", "opencv_aruco", "opencv_reg", "opencv_tracking", "opencv_datasets", "opencv_xfeatures2d", "opencv_shape", "opencv_barcode", "opencv_superres", "opencv_viz", "opencv_plot", "opencv_quality", "opencv_text", "opencv_cudaoptflow", "opencv_optflow", "opencv_ximgproc", "opencv_xobjdetect", "opencv_xphoto", "opencv_stitching", "opencv_ml", "opencv_photo", "opencv_cudaobjdetect", "opencv_cudalegacy", "opencv_cudabgsegm", "opencv_cudafeatures2d", "opencv_cudastereo", "opencv_cudaimgproc", "opencv_cudafilters", "opencv_cudaarithm", "opencv_cudawarping", "opencv_cudacodec", "opencv_cudev", "opencv_gapi", "opencv_objdetect", "opencv_highgui", "opencv_videoio", "opencv_video", "opencv_calib3d", "opencv_dnn", "opencv_features2d", "opencv_flann", "opencv_imgcodecs", "opencv_imgproc", "opencv_core"}) do
            local reallink = link
            if package:is_plat("windows", "mingw") then
                reallink = reallink .. package:version():gsub("%.", "")
            end
            reallink = reallink .. (package:debug() and "d" or "")
            if xmake.version():le("2.5.7") and package:is_plat("mingw") and package:config("shared") then
                reallink = reallink .. ".dll"
            end
            package:add("links", reallink)
        end
        if package:is_plat("windows") then
            local arch = "x64"
            if     package:is_arch("x86")   then arch = "x86"
            elseif package:is_arch("arm64") then arch = "ARM64"
            end
            local linkdir = (package:config("shared") and "lib" or "staticlib")
            local vs = import("core.tool.toolchain").load("msvc"):config("vs")
            local vc_ver = "vc13"
            if     vs == "2015" then vc_ver = "vc14"
            elseif vs == "2017" then vc_ver = "vc15"
            elseif vs == "2019" then vc_ver = "vc16"
            elseif vs == "2022" then vc_ver = "vc17"
            end

            local installdir = package:installdir(arch, vc_ver)
            for _, f in ipairs(os.files(path.join(installdir, linkdir, "*.lib"))) do
                if not f:match("opencv_.+") then
                    package:add("links", path.basename(f))
                end
            end
            package:addenv("PATH", path.join(arch, vc_ver, "bin"))
        elseif package:is_plat("mingw") then
            local arch = package:is_arch("x86_64") and "x64" or "x86"
            local linkdir = (package:config("shared") and "lib" or "staticlib")
            for _, f in ipairs(os.files(path.join(package:installdir(), arch, "mingw", linkdir, "lib*.a"))) do
                if not f:match("libopencv_.+") then
                    package:add("links", path.basename(f):match("lib(.+)"))
                end
            end
            package:addenv("PATH", path.join(arch, "mingw", "bin"))
        else
            if package:version():ge("4.0") then
                for _, suffix in ipairs({"*.a", "*.so", "*.dylib"}) do
                    for _, f in ipairs(os.files(path.join(package:installdir("lib/opencv4/3rdparty"), suffix))) do
                        package:add("links", path.basename(f):match("lib(.+)"))
                    end
                end
            end
            package:addenv("PATH", "bin")
        end
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun((package:debug() and "opencv_versiond" or "opencv_version"))
        end
        assert(package:check_cxxsnippets({test = [[
            #include <iostream>
            void test(int argc, char** argv) {
                cv::CommandLineParser parser(argc, argv, "{help h||show help message}");
                if (parser.has("help")) {
                    parser.printMessage();
                }
                cv::Mat image(3, 3, CV_8UC1);
                std::cout << CV_VERSION << std::endl;
            }
        ]]}, {configs = {languages = "c++11"},
              includes = package:version():ge("4.0") and "opencv2/opencv.hpp" or "opencv/cv.h"}))
    end)
