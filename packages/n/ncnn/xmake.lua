package("ncnn")
    set_homepage("https://github.com/Tencent/ncnn")
    set_description("High-performance neural network inference framework optimized for the mobile platform")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/Tencent/ncnn.git", {submodules = false})
    add_versions("latest", "master")

    add_configs("vulkan", {description = "Enable Vulkan support", default = false, type = "boolean"})
    add_configs("shared", {description = "Build shared library", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("protobuf-cpp v3.11.2", "glslang")

    on_load("windows", function (package)
        if package:config("vulkan") then
            package:add("deps", "vulkansdk")
        end
    end)

    on_load("linux|macosx", function (package)
        package:add("deps", "libomp")
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DNCNN_VULKAN=" .. (package:config("vulkan") and "ON" or "OFF"))
        table.insert(configs, "-DNCNN_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DNCNN_BUILD_EXAMPLES=OFF")
        table.insert(configs, "-DNCNN_BUILD_TOOLS=OFF")
        table.insert(configs, "-DNCNN_BUILD_BENCHMARK=OFF")
        table.insert(configs, "-DNCNN_BUILD_TESTS=OFF")
        table.insert(configs, "-DNCNN_PYTHON=OFF")
        table.insert(configs, "-DNCNN_SYSTEM_GLSLANG=ON")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ncnn/net.h>
            void test() {
                ncnn::Net net;
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
