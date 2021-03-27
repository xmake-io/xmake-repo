package("libfreenect2")
    set_homepage("https://github.com/OpenKinect/libfreenect2")
    set_description("Open source drivers for the Kinect for Windows v2 device")
    set_license("GPL-2.0")

    add_urls("https://github.com/OpenKinect/libfreenect2.git")

    add_versions("v0.2.1", "fd64c5d9b214df6f6a55b4419357e51083f15d93")
    add_versions("v0.2.0", "v0.2.0")

    add_patches("v0.2.0", path.join(os.scriptdir(), "patches", "0.2.0", "frame_listener_impl.cpp.patch"), "47687b34fd0ca275d3e1c2ce87064ffaacd13f2f8d3a310224d3b9fef2cd54a3")

    add_configs("cuda",     { description = "Enable CUDA support.", default = false, type = "boolean"})
    add_configs("opengl",   { description = "Enable OpenGL support.", default = true, type = "boolean"})
    add_configs("opencl",   { description = "Enable OpenCL support.", default = true, type = "boolean"})

    add_deps("cmake", "libjpeg-turbo", "libusb")

    if is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("macosx") then
        add_frameworks("CoreMedia", "CoreFoundation", "CoreVideo", "Foundation", "IOKit", "ImageIO", "VideoToolbox")
    end

    on_load(function (package)
        if package:config("opengl") then
            if package:is_plat("macosx") then
                package:add("deps", "glfw")
                package:add("frameworks", "OpenGL")
            end
        end
        if package:config("opencl") then
            if package:is_plat("macosx") then
                package:add("frameworks", "OpenCL")
            end
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        io.replace("CMakeLists.txt", "FIND_PACKAGE(LibUSB REQUIRED)", "", {plain = true})

        local configs = {}
        table.insert(configs, "-DBUILD_EXAMPLES=OFF")
        table.insert(configs, "-DENABLE_CXX11=ON")
        table.insert(configs, "-DENABLE_CUDA=" .. (package:config("cuda") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_OPENGL=" .. (package:config("opengl") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_OPENCL=" .. (package:config("opencl") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))

        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end

        local libjpegturbo = package:dep("libjpeg-turbo"):fetch()
        if libjpegturbo then
            table.insert(configs, "-DTurboJPEG_INCLUDE_DIRS=" .. table.concat(libjpegturbo.includedirs or libjpegturbo.sysincludedirs, ";"))
            table.insert(configs, "-DTurboJPEG_LIBRARIES=" .. table.concat(libjpegturbo.libfiles, ";"))
        end

        local shflags
        if package:is_plat("macosx") then
            shflags = "-framework IOKit"
        end

        import("package.tools.cmake").install(package, configs, {packagedeps = "libusb", shflags = shflags})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                libfreenect2::Freenect2 fn2;
                fn2.enumerateDevices();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "libfreenect2/libfreenect2.hpp"}))
    end)
