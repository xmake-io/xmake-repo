package("opencv")

    set_homepage("https://opencv.org/")
    set_description("A open source computer vision library.")

    add_urls("https://github.com/opencv/opencv/archive/$(version).tar.gz",
             "https://github.com/opencv/opencv.git")
    add_versions("4.5.3", "77f616ae4bea416674d8c373984b20c8bd55e7db887fd38c6df73463a0647bab")
    add_versions("4.5.2", "ae258ed50aa039279c3d36afdea5c6ecf762515836b27871a8957c610d0424f8")
    add_versions("4.5.1", "e27fe5b168918ab60d58d7ace2bd82dd14a4d0bd1d3ae182952c2113f5637513")
    add_versions("4.2.0", "9ccb2192d7e8c03c58fee07051364d94ed7599363f3b0dce1c5e6cc11c1bb0ec")
    add_versions("3.4.9", "b7ea364de7273cfb3b771a0d9c111b8b8dfb42ff2bcd2d84681902fb8f49892a")

    add_resources("4.5.3", "opencv_contrib", "https://github.com/opencv/opencv_contrib/archive/4.5.3.tar.gz", "73da052fd10e73aaba2560eaff10cc5177e2dcc58b27f8aedf7c649e24c233bc")
    add_resources("4.5.2", "opencv_contrib", "https://github.com/opencv/opencv_contrib/archive/4.5.2.tar.gz", "9f52fd3114ac464cb4c9a2a6a485c729a223afb57b9c24848484e55cef0b5c2a")
    add_resources("4.5.1", "opencv_contrib", "https://github.com/opencv/opencv_contrib/archive/4.5.1.tar.gz", "12c3b1ddd0b8c1a7da5b743590a288df0934e5cef243e036ca290c2e45e425f5")
    add_resources("4.2.0", "opencv_contrib", "https://github.com/opencv/opencv_contrib/archive/4.2.0.tar.gz", "8a6b5661611d89baa59a26eb7ccf4abb3e55d73f99bb52d8f7c32265c8a43020")
    add_resources("3.4.9", "opencv_contrib", "https://github.com/opencv/opencv_contrib/archive/3.4.9.tar.gz", "dc7d95be6aaccd72490243efcec31e2c7d3f21125f88286186862cf9edb14a57")

    add_configs("bundled", {description = "Build 3rd-party libraries with OpenCV.", default = true, type = "boolean"})

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
    add_configs("blas", {description = "Set BLAS vendor.", default = nil, type = "string", values = {"mkl", "openblas"}})
    add_configs("cuda", {description = "Enable CUDA support.", default = false, type = "boolean"})
    add_configs("dynamic_parallel", {description = "Dynamically load parallel runtime (TBB etc.).", default = false, type = "boolean"})

    if is_plat("macosx") then
        add_frameworks("Foundation", "CoreFoundation", "CoreGraphics", "AppKit", "OpenCL")
    elseif is_plat("linux") then
        add_syslinks("pthread", "dl")
    elseif is_plat("windows") then
        add_syslinks("gdi32", "user32", "glu32", "opengl32", "advapi32", "comdlg32", "ws2_32")
    end

    on_load("linux", "macosx", "windows", function (package)
        if package:is_plat("windows") then
            local arch = (package:is_arch("x64") and "x64" or "x86")
            local linkdir = (package:config("shared") and "lib" or "staticlib")
            local vs = import("core.tool.toolchain").load("msvc"):config("vs")
            local vc_ver = "vc13"
            if     vs == "2015" then vc_ver = "vc14"
            elseif vs == "2017" then vc_ver = "vc15"
            elseif vs == "2019" then vc_ver = "vc16"
            end
            package:add("linkdirs", path.join(arch, vc_ver, linkdir))
        elseif package:version():ge("4.0") then
            package:add("includedirs", "include/opencv4")
        end
        if package:config("blas") then
            package:add("deps", package:config("blas"))
        end
        if package:config("cuda") then
            package:add("deps", "cuda", {system = true, configs = {utils = {"cudnn", "cufft", "cublas"}}})
        end
        if not package.is_built or package:is_built() then
            package:add("deps", "cmake", "python 3.x", {kind = "binary"})
        end
    end)

    on_install("linux", "macosx", "windows", function (package)
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
        end
        local resourcedir = package:resourcedir("opencv_contrib")
        if resourcedir then
            import("lib.detect.find_path")
            local modulesdir = assert(find_path("modules", path.join(resourcedir, "*")), "modules not found!")
            table.insert(configs, "-DOPENCV_EXTRA_MODULES_PATH=" .. path.absolute(path.join(modulesdir, "modules")))
        end
        import("package.tools.cmake").install(package, configs, {buildir = "bd"})
        if package:is_plat("windows") then
            local arch = package:is_arch("x64") and "x64" or "x86"
            local linkdir = (package:config("shared") and "lib" or "staticlib")
            local vs = import("core.tool.toolchain").load("msvc"):config("vs")
            local vc_ver = "vc13"
            if     vs == "2015" then vc_ver = "vc14"
            elseif vs == "2017" then vc_ver = "vc15"
            elseif vs == "2019" then vc_ver = "vc16"
            end

            -- keep compatibility for old versions
            local installdir = package:installdir(arch, vc_ver)
            if os.isdir(path.join(os.curdir(), "bd", "install")) then
                os.trycp(path.join(os.curdir(), "bd", "install", arch, vc_ver), package:installdir(arch))
            end

            -- scanning for links and ensure link order
            for _, f in ipairs(os.files(path.join(installdir, linkdir, "opencv_*.lib"))) do
                package:add("links", path.basename(f))
            end
            for _, f in ipairs(os.files(path.join(installdir, linkdir, "*.lib"))) do
                local linkname = path.basename(f)
                if not linkname:startswith("opencv_") then
                    package:add("links", linkname)
                end
            end
            package:add("linkdirs", linkdir)
            package:addenv("PATH", path.join(arch, vc_ver, "bin"))
            print(os.files(path.join(package:installdir(), "**.lib")))
            print(os.files(path.join(package:installdir(), "**.dll")))
        else
            local linkdirs_3rd
            if package:version():ge("4.0") then
                linkdirs_3rd = "lib/opencv4/3rdparty"
            else
                linkdirs_3rd = "lib/opencv3/3rdparty"
            end
            -- scanning for links for old xmake version
            if xmake.version():le("2.5.6") then
                for _, suffix in ipairs({"*.a", "*.so", "*.dylib"}) do
                    for _, f in ipairs(os.files(path.join(package:installdir("lib"), suffix))) do
                        package:add("links", path.basename(f):match("lib(.+)"))
                    end
                    for _, f in ipairs(os.files(path.join(package:installdir(linkdirs_3rd), suffix))) do
                        package:add("links", path.basename(f):match("lib(.+)"))
                    end
                end
            end
            package:add("linkdirs", "lib", linkdirs_3rd)
            package:addenv("PATH", "bin")
        end
    end)

    on_test(function (package)
        os.vrun("opencv_version")
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
