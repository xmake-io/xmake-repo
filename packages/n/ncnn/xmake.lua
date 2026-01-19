package("ncnn")
    set_homepage("https://github.com/Tencent/ncnn")
    set_description("High-performance neural network inference framework optimized for the mobile platform")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/Tencent/ncnn/archive/refs/tags/$(version).tar.gz",
            "https://github.com/Tencent/ncnn.git", { submodules = false })

    add_versions("20250916", "7d463f1e5061facd02b8af5e792e059088695cdcfcc152c8f4892f6ffe5eab1a")
    add_versions("20250503", "3afea4cf092ce97d06305b72c6affbcfb3530f536ae8e81a4f22007d82b729e9")

    add_configs("vulkan",        {description = "Enable Vulkan support", default = true, type = "boolean"})
    add_configs("openmp",        {description = "Enable OpenMP support", default = true, type = "boolean"})
    add_configs("threads",       {description = "Enable threads support", default = true, type = "boolean"})
    add_configs("c_api",         {description = "Build ncnn with C api", default = false, type = "boolean"})

    add_configs("simpleomp",     {description = "Enable minimal openmp runtime emulation", default = false, type = "boolean"})
    add_configs("simpleocv",     {description = "Enable minimal opencv structure emulation", default = false, type = "boolean"})
    add_configs("simplestl",     {description = "Enable minimal cpp stl structure emulation", default = false, type = "boolean"})
    add_configs("simplemath",    {description = "Enable minimal cmath", default = false, type = "boolean"})

    add_configs("pixel",         {description = "Enable pixel convert and resize", default = true, type = "boolean"})
    add_configs("pixel_rotate",  {description = "Enable pixel rotate", default = true, type = "boolean"})
    add_configs("pixel_affine",  {description = "Enable pixel affine", default = true, type = "boolean"})
    add_configs("pixel_drawing", {description = "Enable pixel drawing", default = true, type = "boolean"})

    add_deps("cmake")

    add_includedirs("include/ncnn")

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
        local glslang_ver = package:version() and package:version() or "20260113"
        if package:config("vulkan") then
            package:add("deps", "glslang-nihui " .. glslang_ver)
            if package:is_plat("macosx", "iphoneos") then
                local icd = os.getenv("VK_ICD_FILENAMES")
                local vk_driver = os.getenv("NCNN_VULKAN_DRIVER")
                if icd then
                    package:addenv("VK_ICD_FILENAMES", icd)
                end
                if vk_driver then
                    package:addenv("NCNN_VULKAN_DRIVER", vk_driver)
                end
                local has_moltenvk = package:getenv("VK_ICD_FILENAMES") or package:getenv("NCNN_VULKAN_DRIVER")
                print("================================")
                print("has_moltenvk value = %s", has_moltenvk)
                print("--------------------------------")
                print("Package env:")
                print("VK_ICD_FILENAMES   = %s", package:getenv("VK_ICD_FILENAMES") or "nil")
                print("NCNN_VULKAN_DRIVER = %s", package:getenv("NCNN_VULKAN_DRIVER") or "nil")
                print("--------------------------------")
                print("OS env:")
                print("VK_ICD_FILENAMES   = %s", icd or "nil")
                print("NCNN_VULKAN_DRIVER = %s", vk_driver or "nil")
                print("================================")
                if package:version() and package:version():lt("20260113") or not has_moltenvk then
                    package:add("deps", "moltenvk")
                    package:add("frameworks", "Metal", "Foundation", "QuartzCore", "CoreGraphics", "IOSurface")
                    if package:is_plat("macosx") then
                        package:add("frameworks", "IOKit", "AppKit")
                    else
                        package:add("frameworks", "UIKit")
                    end
                end
            end
        end

        if package:is_plat("linux", "bsd") and package:config("threads") then
            package:add("syslinks", "pthread")
        end

        if package:config("openmp") and not package:config("simpleomp") then
            if package:is_plat("mingw", "msys") and not is_subhost("macosx") then
                package:add("ldflags", "-fopenmp")
            end
            if package:is_plat("linux", "macosx", "cross", "android", "mingw", "msys", "bsd") then
                package:add("deps", "libomp")
            end
        end
        if package:config("simpleomp") then
            package:config_set("openmp", true)
        end
    end)

    on_install(function (package)
        local configs = {
            "-DNCNN_BUILD_EXAMPLES=OFF",
            "-DNCNN_BUILD_TOOLS=OFF",
            "-DNCNN_BUILD_BENCHMARK=OFF",
            "-DNCNN_BUILD_TESTS=OFF",
            "-DNCNN_PYTHON=OFF",
            "-DNCNN_SYSTEM_GLSLANG=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DNCNN_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DNCNN_VULKAN=" .. (package:config("vulkan") and "ON" or "OFF"))
        table.insert(configs, "-DNCNN_OPENMP=" .. (package:config("openmp") and "ON" or "OFF"))
        table.insert(configs, "-DNCNN_THREADS=" .. (package:config("threads") and "ON" or "OFF"))
        table.insert(configs, "-DNCNN_C_API=" .. (package:config("c_api") and "ON" or "OFF"))
        table.insert(configs, "-DNCNN_SIMPLEOMP=" .. (package:config("simpleomp") and "ON" or "OFF"))
        table.insert(configs, "-DNCNN_SIMPLEOCV=" .. (package:config("simpleocv") and "ON" or "OFF"))
        table.insert(configs, "-DNCNN_SIMPLESTL=" .. (package:config("simplestl") and "ON" or "OFF"))
        table.insert(configs, "-DNCNN_SIMPLEMATH=" .. (package:config("simplemath") and "ON" or "OFF"))
        table.insert(configs, "-DNCNN_PIXEL=" .. (package:config("pixel") and "ON" or "OFF"))
        table.insert(configs, "-DNCNN_PIXEL_ROTATE=" .. (package:config("pixel_rotate") and "ON" or "OFF"))
        table.insert(configs, "-DNCNN_PIXEL_AFFINE=" .. (package:config("pixel_affine") and "ON" or "OFF"))
        table.insert(configs, "-DNCNN_PIXEL_DRAWING=" .. (package:config("pixel_drawing") and "ON" or "OFF"))
        if package:config("vulkan") then
            table.insert(configs, "-DCMAKE_CXX_STANDARD=11")
            local moltenvk = package:dep("moltenvk")
            if moltenvk then
                table.insert(configs, "-DVulkan_LIBRARY=" .. path.join(moltenvk:installdir("lib"), "libMoltenVK." .. (moltenvk:config("shared") and "dylib" or "a")))
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        if not package:config("c_api") then
            assert(package:check_cxxsnippets({test = [[
                #include <net.h>
                void test() {
                    ncnn::Net net;
                    net.load_param("model.param");
                }
            ]]}, {configs = package:config("vulkan") and {languages = "c++11"} or {}}))
        else
            assert(package:check_csnippets({test = [[
                #include <c_api.h>
                void test() {
                    const char* ver = ncnn_version();
                }
            ]]}))
        end
    end)
