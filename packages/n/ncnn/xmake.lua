package("ncnn")
    set_homepage("https://github.com/Tencent/ncnn")
    set_description("High-performance neural network inference framework optimized for the mobile platform")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/Tencent/ncnn.git", {submodules = false})
    add_versions("20250503", "305837fd4a722ebc47c5d72e72d8ec9ae970e932")

    add_configs("vulkan", {description = "Enable Vulkan support", default = false, type = "boolean"})
    add_configs("shared", {description = "Build shared library", default = false, type = "boolean"})
    add_configs("simpleocv", {description = "Enable SimpleOpenCV", default = true, type = "boolean"})

    add_deps("cmake")
    add_deps("protobuf-cpp 3.11.2", "glslang")
    add_links("ncnn")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) > 25, "package(libomp): need ndk api level > 25")
        end)
    end

    on_load("windows", function (package)
        if package:config("vulkan") then
            package:add("deps", "vulkansdk")
        end
    end)

    on_load("linux", "macosx", "cross", function (package)
        package:add("deps", "libomp")
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DNCNN_VULKAN=" .. (package:config("vulkan") and "ON" or "OFF"))
        table.insert(configs, "-DNCNN_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DNCNN_BUILD_EXAMPLES=OFF")
        table.insert(configs, "-DNCNN_BUILD_TOOLS=OFF")
        table.insert(configs, "-DNCNN_BUILD_BENCHMARK=OFF")
        table.insert(configs, "-DNCNN_BUILD_TESTS=OFF")
        table.insert(configs, "-DNCNN_PYTHON=OFF")
        table.insert(configs, "-DNCNN_SYSTEM_GLSLANG=ON")
        table.insert(configs, "-DNCNN_SIMPLEOCV=" .. (package:config("simpleocv") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ncnn/net.h>
            void test() {
                ncnn::Net net;
                net.load_param("model.param");
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
