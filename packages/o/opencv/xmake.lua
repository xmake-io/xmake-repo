package("opencv")
    set_homepage("https://opencv.org/")
    set_description("A open source computer vision library.")
    set_license("Apache-2.0")

    add_urls("https://github.com/opencv/opencv/archive/$(version).tar.gz",
             "https://github.com/opencv/opencv.git")
    add_versions("4.13.0", "1d40ca017ea51c533cf9fd5cbde5b5fe7ae248291ddf2af99d4c17cf8e13017d")
    add_versions("4.12.0", "44c106d5bb47efec04e531fd93008b3fcd1d27138985c5baf4eafac0e1ec9e9d")
    add_versions("4.11.0", "9a7c11f924eff5f8d8070e297b322ee68b9227e003fd600d4b8122198091665f")
    add_versions("4.10.0", "b2171af5be6b26f7a06b1229948bbb2bdaa74fcf5cd097e0af6378fce50a6eb9")
    add_versions("4.9.0", "ddf76f9dffd322c7c3cb1f721d0887f62d747b82059342213138dc190f28bc6c")
    add_versions("4.8.0", "cbf47ecc336d2bff36b0dcd7d6c179a9bb59e805136af6b9670ca944aef889bd")
    add_versions("4.6.0", "1ec1cba65f9f20fe5a41fda1586e01c70ea0c9a6d7b67c9e13edf0cfe2239277")
    add_versions("4.5.5", "a1cfdcf6619387ca9e232687504da996aaa9f7b5689986b8331ec02cb61d28ad")
    add_versions("4.5.4", "c20bb83dd790fc69df9f105477e24267706715a9d3c705ca1e7f613c7b3bad3d")
    add_versions("4.5.3", "77f616ae4bea416674d8c373984b20c8bd55e7db887fd38c6df73463a0647bab")
    add_versions("4.5.2", "ae258ed50aa039279c3d36afdea5c6ecf762515836b27871a8957c610d0424f8")
    add_versions("4.5.1", "e27fe5b168918ab60d58d7ace2bd82dd14a4d0bd1d3ae182952c2113f5637513")
    add_versions("4.2.0", "9ccb2192d7e8c03c58fee07051364d94ed7599363f3b0dce1c5e6cc11c1bb0ec")
    add_versions("3.4.9", "b7ea364de7273cfb3b771a0d9c111b8b8dfb42ff2bcd2d84681902fb8f49892a")

    add_patches("4.11.0", "https://github.com/opencv/opencv/commit/767dd838d3074409fd72a4d76c320b1370e95943.diff", "376dd90500ab7205084fd4298ff26137ce9678b00233ad20ca2189ef9eca3a58")
    add_patches("4.12.0", "https://github.com/opencv/opencv/pull/27691/commits/90c444abd387ffa70b2e72a34922903a2f0f4f5a.patch", "4811cf490195a7b2952e075c4d713593326bc54fcfa42a33e19d7ed025bb5b6f")

    add_resources("4.13.0", "opencv_contrib", "https://github.com/opencv/opencv_contrib/archive/4.13.0.tar.gz", "1e0077a4fd2960a7d2f4c9e49d6ba7bb891cac2d1be36d7e8e47aa97a9d1039b")
    add_resources("4.12.0", "opencv_contrib", "https://github.com/opencv/opencv_contrib/archive/4.12.0.tar.gz", "4197722b4c5ed42b476d42e29beb29a52b6b25c34ec7b4d589c3ae5145fee98e")
    add_resources("4.11.0", "opencv_contrib", "https://github.com/opencv/opencv_contrib/archive/4.11.0.tar.gz", "2dfc5957201de2aa785064711125af6abb2e80a64e2dc246aca4119b19687041")
    add_resources("4.10.0", "opencv_contrib", "https://github.com/opencv/opencv_contrib/archive/4.10.0.tar.gz", "65597f8fb8dc2b876c1b45b928bbcc5f772ddbaf97539bf1b737623d0604cba1")
    add_resources("4.9.0", "opencv_contrib", "https://github.com/opencv/opencv_contrib/archive/4.9.0.tar.gz", "8952c45a73b75676c522dd574229f563e43c271ae1d5bbbd26f8e2b6bc1a4dae")
    add_resources("4.8.0", "opencv_contrib", "https://github.com/opencv/opencv_contrib/archive/4.8.0.tar.gz", "b4aef0f25a22edcd7305df830fa926ca304ea9db65de6ccd02f6cfa5f3357dbb")
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

    local features = {"1394", "vtk", "eigen", "ffmpeg", "gstreamer", "gtk", "ipp", "halide", "vulkan", "jasper", "openjpeg", "jpeg", "webp", "openexr", "opengl", "png", "tbb", "openmp", "tiff", "itt", "protobuf", "quirc", "obsensor"}
    local default_features = {"eigen", "ffmpeg", "jpeg", "opengl", "png", "protobuf", "quirc", "webp", "tiff"}

    for _, feature in ipairs(features) do
        add_configs(feature, {description = "Include " .. feature .. " support.", default = table.contains(default_features, feature), type = "boolean"})
    end
    add_configs("blas", {description = "Set BLAS vendor.", values = {"mkl", "openblas"}})
    add_configs("cuda", {description = "Enable CUDA support.", default = false, type = "boolean"})
    add_configs("dynamic_parallel", {description = "Dynamically load parallel runtime (TBB etc.).", default = false, type = "boolean"})
    add_configs("mirror", {description = "Set mirror for download.", values = {"github", "gitcode"}})

    if is_plat("macosx") then
        add_frameworks("Foundation", "CoreFoundation", "CoreGraphics", "AppKit", "OpenCL", "Accelerate")
        add_extsources("brew::opencv")
    elseif is_plat("linux") then
        add_extsources("pacman::opencv", "apt::libopencv-dev")
        add_syslinks("pthread", "dl")
    elseif is_plat("windows") then
        add_syslinks("gdi32", "user32", "glu32", "opengl32", "advapi32", "comdlg32", "ws2_32", "ole32")
    elseif is_plat("mingw") then
        add_syslinks("gdi32", "user32", "glu32", "opengl32", "advapi32", "comdlg32", "ws2_32", "pthread")
    end

    on_fetch("macosx", function (package, opt)
        if opt.system then
            local result = package:find_package("brew::opencv", opt)
            if result then
                local includedirs = table.wrap(result.sysincludedirs or result.includedirs)
                for _, includedir in ipairs(includedirs) do
                    local dir = path.join(includedir, "opencv4")
                    if os.isdir(dir) then
                        table.insert(includedirs, dir)
                    end
                end
                if result.sysincludedirs then
                    result.sysincludedirs = includedirs
                end
                if result.includedirs then
                    result.includedirs = includedirs
                end
            end
            return result
        end
    end)

    local vs_map = {
        ["2015"] = "vc14",
        ["2017"] = "vc15",
        ["2019"] = "vc16",
        ["2022"] = "vc17",
        ["2026"] = "vc18"
    }

    on_load("android", "linux", "macosx", "windows", "mingw@windows,msys", function (package)
        if package:is_plat("windows") then
            local arch = "x64"
            if     package:is_arch("x86")   then arch = "x86"
            elseif package:is_arch("arm64") then arch = "ARM64"
            end
            local linkdir = (package:config("shared") and "lib" or "staticlib")
            local vs = package:toolchain("msvc"):config("vs")
            local vc_ver = vs_map[vs] or raise("Unknown Visual Studio version: " .. vs)
            package:add("linkdirs", linkdir) -- fix path for 4.9.0/vs2022
            package:add("linkdirs", path.join(arch, vc_ver, linkdir))
        elseif package:is_plat("mingw") then
            local arch = (package:is_arch("x86_64") and "x64" or "x86")
            local linkdir = (package:config("shared") and "lib" or "staticlib")
            package:add("linkdirs", path.join(arch, "mingw", linkdir))
        elseif package:is_plat("android") then
            local linkdir = (package:config("shared") and "libs" or "staticlibs")
            package:add("linkdirs", path.join("sdk/native", linkdir, package:targetarch()))
            package:add("linkdirs", path.join("sdk/native/3rdparty/libs", package:targetarch()))
            package:add("includedirs", "sdk/native/jni/include")
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
        if package:config("ffmpeg") then
            if not package:is_plat("windows") or not package:is_arch("i386", "x86", "arm64") then
                package:add("deps", "ffmpeg")
            end
        end
        if package:is_plat("linux") then
            if package:config("gtk") then
                package:add("deps", "gtk3", {optional = true})
            end
        end
        if not package:is_precompiled() then
            package:add("deps", "cmake", "python 3.x", {kind = "binary"})
        end

        if package:config("tesseract") then
            package:add("deps", "tesseract 4.1.3") -- OpenCV need tesseract from the v4 series
        end
    end)

    if on_check then
        on_check("windows|arm64", function (package)
            import("core.base.semver")
            if package:version() and package:version():lt("4.10.0") then
                raise("current opencv version does not support windows/arm64!")
            end
            local vs = package:toolchain("msvc"):config("vs")
            assert(tonumber(vs) >= 2022, "package(opencv) requires Visual Studio 2022 and later for arm targets")
        end)
    end

    on_install("android", "linux", "macosx", "windows", "mingw@windows,msys", function (package)
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
        if package:config("mirror") then
            table.insert(configs, "-DOPENCV_DOWNLOAD_MIRROR_ID=" .. package:config("mirror"))
        end
        table.insert(configs, "-DPARALLEL_ENABLE_PLUGINS=" .. (package:config("dynamic_parallel") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DBUILD_WITH_STATIC_CRT=" .. (package:has_runtime("MT", "MTd") and "ON" or "OFF"))
            if package:is_arch("arm64") then
                -- https://github.com/opencv/opencv/issues/25052
                table.insert(configs, "-DCPU_NEON_FP16_SUPPORTED=OFF")
                -- Newest Windows ARM worker issue
                if package:has_runtime("MT", "MTd") then
                    table.insert(configs, "-DCPU_NEON_DOTPROD_SUPPORTED=OFF")
                end
                -- https://github.com/opencv/opencv/issues/24235
                table.insert(configs, "-DOPENCV_SKIP_SYSTEM_PROCESSOR_DETECTION=ON")
                -- Enforce ARM64 without check
                table.insert(configs, "-DAARCH64=ON")
            end
        end
        if package:is_cross() or (package:is_plat("mingw") and not package:is_arch(os.arch())) then
            if package:is_plat("windows") or package:is_plat("mingw") then
                table.insert(configs, "-DCMAKE_SYSTEM_NAME=Windows")
            elseif package:is_plat("macosx") then
                table.insert(configs, "-DCMAKE_SYSTEM_NAME=Darwin")
            elseif package:is_plat("linux") then
                table.insert(configs, "-DCMAKE_SYSTEM_NAME=Linux")
            elseif package:is_plat("android") then
                table.insert(configs, "-DCMAKE_SYSTEM_NAME=Android")
                -- from https://github.com/opencv/opencv/issues/15769#issuecomment-549570072
                table.insert(configs, "-DBUILD_ANDROID_EXAMPLES=OFF")
                table.insert(configs, "-DBUILD_ANDROID_PROJECTS=OFF")
            end

            -- In case of android we prefer to set CMAKE_ANDROID_ARCH_ABI rather than CMAKE_SYSTEM_PROCESSOR
            if package:is_plat("android") then
                table.insert(configs, "-DCMAKE_ANDROID_ARCH_ABI=" .. package:targetarch())
            else
                table.insert(configs, "-DCMAKE_SYSTEM_PROCESSOR=" .. package:targetarch())
            end
        end
        local resourcedir = package:resourcedir("opencv_contrib")
        if resourcedir then
            import("lib.detect.find_path")
            local modulesdir = assert(find_path("modules", path.join(resourcedir, "*")), "modules not found!")
            table.insert(configs, "-DOPENCV_EXTRA_MODULES_PATH=" .. path.absolute(path.join(modulesdir, "modules")))
        end
        local shflags, ldflags
        if package:config("ffmpeg") then
            -- fix https://github.com/opencv/opencv/issues/22418
            if package:version() and package:version():le("4.6") then
                io.replace("modules/videoio/src/ffmpeg_codecs.hpp",
                    "#include <libavformat/avformat.h>",
                    "#include <libavcodec/version.h>\n#include <libavformat/avformat.h>", {plain = true})
            end
            -- https://www.ffmpeg.org/platform.html#toc-Advanced-linking-configuration
            if package:config("shared") and not package:is_plat("windows", "macosx", "iphoneos") then
                ldflags = {"-Wl,-Bsymbolic"}
                shflags = {"-Wl,-Bsymbolic"}
            end
        end
        import("package.tools.cmake").install(package, configs, {builddir = "bd", shflags = shflags, ldflags = ldflags})

        if not package:is_plat("windows", "android") then
            local cmakefile = os.files(package:installdir("**/OpenCVModules.cmake"))
            if cmakefile then
                io.replace(cmakefile[1], "opencv_wechat_qrcode\n",
                           "opencv_wechat_qrcode\ninclude(CMakeFindDependencyMacro)\nfind_dependency(Iconv)\n", {plain = true})
            end
        end
        for _, link in ipairs({"opencv_phase_unwrapping", "opencv_surface_matching", "opencv_saliency",
                               "opencv_wechat_qrcode", "opencv_mcc", "opencv_face",
                               "opencv_img_hash", "opencv_videostab", "opencv_structured_light", "opencv_intensity_transform",
                               "opencv_ccalib", "opencv_line_descriptor", "opencv_stereo", "opencv_dnn_objdetect", "opencv_dnn_superres",
                               "opencv_fuzzy", "opencv_hfs", "opencv_rapid", "opencv_bgsegm", "opencv_bioinspired", "opencv_rgbd",
                               "opencv_dpm", "opencv_aruco", "opencv_reg", "opencv_tracking", "opencv_datasets", "opencv_xfeatures2d",
                               "opencv_shape", "opencv_barcode", "opencv_superres", "opencv_viz", "opencv_plot", "opencv_quality",
                               "opencv_text", "opencv_cudaoptflow", "opencv_optflow", "opencv_ximgproc", "opencv_xobjdetect",
                               "opencv_xphoto", "opencv_stitching", "opencv_ml", "opencv_photo", "opencv_cudaobjdetect", "opencv_cudalegacy",
                               "opencv_cudabgsegm", "opencv_cudafeatures2d", "opencv_cudastereo", "opencv_cudaimgproc", "opencv_cudafilters",
                               "opencv_cudaarithm", "opencv_cudawarping", "opencv_cudacodec", "opencv_cudev", "opencv_gapi", "opencv_objdetect",
                               "opencv_highgui", "opencv_videoio", "opencv_video", "opencv_calib3d", "opencv_dnn", "opencv_features2d",
                               "opencv_flann", "opencv_imgcodecs", "opencv_imgproc", "opencv_core", "kleidicv_hal", "kleidicv_thread", "kleidicv"}) do
            local reallink = link
            if package:is_plat("windows", "mingw") then
                reallink = reallink .. package:version():gsub("%.", "")
                reallink = reallink .. (package:debug() and "d" or "")
            end
            package:add("links", reallink)
        end
        if package:is_plat("android") then
            for _, suffix in ipairs({"*.a", "*.so"}) do
                for _, f in ipairs(os.files(path.join(package:installdir(path.join("sdk/native/3rdparty/libs", package:targetarch())), suffix))) do
                    package:add("links", path.basename(f):match("lib(.+)"))
                end
            end
        elseif package:is_plat("windows") then
            local arch = "x64"
            if     package:is_arch("x86")   then arch = "x86"
            elseif package:is_arch("arm64") then arch = "ARM64"
            end
            -- Workaround for arm64
            if package:is_arch("arm64") then
                os.trymv(path.join(package:installdir(), "x64"), path.join(package:installdir(), "ARM64"))
                os.trymv(path.join(package:installdir(), "x86"), path.join(package:installdir(), "ARM64"))
            end
            local linkdir = (package:config("shared") and "lib" or "staticlib")
            local vs = package:toolchain("msvc"):config("vs")
            local vc_ver = vs_map[vs] or raise("Unknown Visual Studio version: " .. vs)
            local installdir = package:installdir(arch, vc_ver)
            local libfiles = {}
            table.join2(libfiles, os.files(path.join(package:installdir(), linkdir, "*.lib")))
            table.join2(libfiles, os.files(path.join(package:installdir(), arch, vc_ver, linkdir, "*.lib")))
            for _, f in ipairs(libfiles) do
                if not f:match("opencv_.+") then
                    package:add("links", path.basename(f))
                end
            end
            package:addenv("PATH", "bin") -- Fix path for 4.9.0 / vs2022
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
            -- FIXME, it will crash on action ci/2022/MD, but it works on local machine
            if not package:has_runtime("MD", "MDd") then
                if package:debug() and package:is_plat("windows", "mingw") then
                    os.vrun("opencv_versiond")
                else
                    os.vrun("opencv_version")
                end
            end
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
