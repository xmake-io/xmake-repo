package("ncnn")
    set_homepage("https://github.com/Tencent/ncnn")
    set_description("High-performance neural network inference framework optimized for the mobile platform")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/Tencent/ncnn/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Tencent/ncnn.git", {submodules = false})

    add_versions("20250916", "7d463f1e5061facd02b8af5e792e059088695cdcfcc152c8f4892f6ffe5eab1a")
    add_versions("20250503", "3afea4cf092ce97d06305b72c6affbcfb3530f536ae8e81a4f22007d82b729e9")

    add_configs("vulkan", {description = "Enable Vulkan support", default = false, type = "boolean"})
    add_configs("c_api", {description = "Build ncnn with C api", default = false, type = "boolean"})

    add_deps("cmake")

    if is_plat("android") then
        add_syslinks("android")
    end

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk")
            local ndk_sdkver = ndk:config("ndk_sdkver")
            assert(ndk_sdkver and tonumber(ndk_sdkver) > 25, "package(ncnn): need ndk api level > 25")
        end)
    end

    on_load(function (package)
        if package:config("vulkan") then
            package:add("deps", "glslang")
        end
        if package:is_plat("windows") then
            if package:config("vulkan") then
                package:add("deps", "vulkansdk")
            end
        else
            if package:is_plat("mingw", "msys") and not is_subhost("macosx") then
                package:add("ldflags", "-fopenmp")
            end
            package:add("links" , "ncnn" .. (package:is_debug() and "d" or ""))
            if package:is_plat("linux", "macosx", "cross", "android", "mingw", "msys", "bsd") then
                package:add("deps", "libomp")
            end
        end
    end)

    on_install(function (package)
        local configs = {
            "-DNCNN_BUILD_EXAMPLES=OFF",
            "-DNCNN_BUILD_TOOLS=OFF",
            "-DNCNN_SIMPLEOCV=OFF",
            "-DNCNN_BUILD_BENCHMARK=OFF",
            "-DNCNN_BUILD_TESTS=OFF",
            "-DNCNN_PYTHON=OFF",
            "-DNCNN_SYSTEM_GLSLANG=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DNCNN_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DNCNN_VULKAN=" .. (package:config("vulkan") and "ON" or "OFF"))
        table.insert(configs, "-DNCNN_C_API=" .. (package:config("c_api") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        if not package:config("c_api") then
            assert(package:check_cxxsnippets({test = [[
                #include <ncnn/net.h>
                void test() {
                    ncnn::Net net;
                    net.load_param("model.param");
                }
            ]]}, {configs = {languages = "c++11"}}))
        else
            assert(package:check_csnippets({test = [[
                #include <ncnn/c_api.h>
                void test() {
                    const char* ver = ncnn_version();
                }
            ]]}))
        end
    end)
