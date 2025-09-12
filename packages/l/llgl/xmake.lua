package("llgl")
    set_description("Low Level Graphics Library (LLGL) is a thin abstraction layer for the modern graphics APIs OpenGL, Direct3D, Vulkan, and Metal")
    set_homepage("https://github.com/LukasBanana/LLGL")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/LukasBanana/LLGL/archive/refs/tags/Release-$(version)b.tar.gz",
             "https://github.com/LukasBanana/LLGL.git")

    add_versions("v0.04", "fdeda39bd31522bced0d889655b290e06688975d58ab20756c3eda9a5f21391f")

    if not is_plat("android", "iphoneos", "wasm", "bsd", "cross") then
        add_configs("opengl", {description = "Enable OpenGL Renderer", default = true, type = "boolean"})
    end
    if is_plat("android", "iphoneos") then
        add_configs("opengles", {description = "Enable OpenGLES Renderer", default = true, type = "boolean"})
    end
    add_configs("vulkan", {description = "Enable Vulkan Renderer", default = false, type = "boolean"})
    add_configs("null", {description = "Enable Null Renderer", default = true, type = "boolean"})

    if is_plat("windows", "mingw") then
        add_configs("d3d11", {description = "Enable D3D11 Renderer", default = true, type = "boolean"})
        add_configs("d3d12", {description = "Enable D3D12 Renderer", default = true, type = "boolean"})
        add_syslinks("dxgi", "d3d11", "d3d12", "d3dcompiler", "comdlg32", "user32", "gdi32", "opengl32", "shell32")
    elseif is_plat("linux") then
        add_configs("wayland", {description = "Enable Wayland", default = true, type = "boolean"})
        add_deps("wayland", "libxrandr", "libxrender")
    elseif is_plat("macosx") then
        add_configs("metal", {description = "Enable Metal Renderer", default = true, type = "boolean"})
    end

    add_deps("cmake")
    add_deps("gaussianlib")

    if on_check then
        on_check("android", function (package)
            local ndk = package:toolchain("ndk"):config("ndkver")
            assert(ndk and tonumber(ndk) < 27, "package(LLGL): requires NDK version earlier than r27.")
        end)
    end

    on_load(function (package)
        if package:is_plat("android") then
            -- Workaround NDK bug
            package:add("links", "android_native_app_glue")
        elseif package:is_plat("iphoneos") then
            package:add("frameworks", "Foundation", "UIKit")
        elseif package:is_plat("windows", "mingw") then
            package:add("defines", "NOMINMAX", "WIN32_LEAN_AND_MEAN", "UNICODE", "_UNICODE")
            if package:config("d3d11") or package:config("d3d12") then 
                package:add("links", "LLGL_DXCommon" .. (package:is_debug() and "D" or ""))
            end
            if package:config("d3d11") then
                package:add("links", "LLGL_Direct3D11" .. (package:is_debug() and "D" or ""))
            end
            if package:config("d3d12") then
                package:add("links", "LLGL_Direct3D12" .. (package:is_debug() and "D" or ""))
            end
        end

        package:add("links", "LLGL" .. (package:is_debug() and "D" or ""))

        if package:config("opengl") then
            package:add("links", "LLGL_OpenGL" .. (package:is_debug() and "D" or ""))
            if package:is_plat("macosx") then
                package:add("frameworks", "OpenGL")
            elseif package:is_plat("android") then
                package:add("syslinks", "GLESv2")
            end
        end

        if package:config("opengles") then
            package:add("links", "LLGL_OpenGLES3" .. (package:is_debug() and "D" or ""))
            if package:is_plat("macosx", "iphoneos") then
                package:add("frameworks", "Foundation", "UIKit", "QuartzCore", "OpenGLES", "GLKit")
            end
        end

        if package:config("metal") then
            package:add("links", "LLGL_Metal" .. (package:is_debug() and "D" or ""))
            if package:is_plat("macosx") then
                package:add("frameworks", "Metal", "MetalKit")
            end
        end

        if package:config("vulkan") then
            package:add("links", "LLGL_Vulkan" .. (package:is_debug() and "D" or ""))
            package:add("deps", "vulkansdk")
        end

        if package:config("null") then
            package:add("links", "LLGL_Null" .. (package:is_debug() and "D" or ""))
        end
    end)

    on_install("!bsd and !cross", function (package)
        -- Help MinGW linkage issues
        io.replace("sources/Renderer/DXCommon/CMakeLists.txt",
            [[add_library(LLGL_DXCommon STATIC "${FilesDXCommon}")]],
            [[add_library(LLGL_DXCommon STATIC "${FilesDXCommon}")
            target_link_libraries(LLGL_DXCommon PRIVATE LLGL)]], {plain = true})
        -- Help CMakeLists.txt to acquire UNIX-like path
        io.replace("CMakeLists.txt", [[if(LLGL_ANDROID_PLATFORM)
    set(ANDROID_APP_GLUE_DIR "$ENV{ANDROID_NDK_ROOT}/sources/android/native_app_glue")
    set(
        FilesAndroidNativeAppGlue
        "${ANDROID_APP_GLUE_DIR}/android_native_app_glue.c"
        "${ANDROID_APP_GLUE_DIR}/android_native_app_glue.h"
    )
endif()]], [[if(LLGL_ANDROID_PLATFORM)
    file(TO_CMAKE_PATH "$ENV{ANDROID_NDK_ROOT}" ANDROID_NDK_ROOT_CMAKE)
    set(ANDROID_APP_GLUE_DIR "${ANDROID_NDK_ROOT_CMAKE}/sources/android/native_app_glue")

    set(FilesAndroidNativeAppGlue
        "${ANDROID_APP_GLUE_DIR}/android_native_app_glue.c"
        "${ANDROID_APP_GLUE_DIR}/android_native_app_glue.h"
    )
endif()
]], {plain = true})
        -- Help MinGW acquire std::uint32_t
        io.replace("sources/Renderer/Direct3D12/Buffer/D3D12BufferConstantsPool.h", [[#include <d3d12.h>]], [[#include <d3d12.h>
#include <cstdint>]], {plain = true})
        local includedir = ""
        local fetchinfo = package:dep("gaussianlib"):fetch()
        if fetchinfo then
            includedir = table.concat(fetchinfo.includedirs or fetchinfo.sysincludedirs, ";")
        end
        local configs = {"-DLLGL_BUILD_TESTS=OFF", "-DLLGL_BUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DLLGL_BUILD_STATIC_LIB=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DLLGL_BUILD_RENDERER_OPENGL=" .. (package:config("opengl") and "ON" or "OFF"))
        table.insert(configs, "-DLLGL_BUILD_RENDERER_OPENGLES3=" .. (package:config("opengles") and "ON" or "OFF"))
        table.insert(configs, "-DLLGL_BUILD_RENDERER_DIRECT3D11=" .. (package:config("d3d11") and "ON" or "OFF"))
        table.insert(configs, "-DLLGL_BUILD_RENDERER_DIRECT3D12=" .. (package:config("d3d12") and "ON" or "OFF"))
        table.insert(configs, "-DLLGL_BUILD_RENDERER_VULKAN=" .. (package:config("vulkan") and "ON" or "OFF"))
        table.insert(configs, "-DLLGL_BUILD_RENDERER_NULL=" .. (package:config("null") and "ON" or "OFF"))
	    table.insert(configs, "-DLLGL_LINUX_ENABLE_WAYLAND=" .. (package:config("wayland") and "ON" or "OFF"))
        table.insert(configs, "-DLLGL_BUILD_RENDERER_METAL=" .. (package:config("metal") and "ON" or "OFF"))
        table.insert(configs, "-DGaussLib_INCLUDE_DIR=" .. includedir)
        local opt = {}
        if package:is_plat("linux") then
            opt.packagedeps = {"wayland", "libxrandr", "libxrender"}
        end
        import("package.tools.cmake").install(package, configs, opt)
        if package:is_plat("android") then
            -- Workaround NDK bug
            local ndk = package:toolchain("ndk")
            local ndk_path = ndk:config("ndk")
            os.cp(path.join(ndk_path, "sources", "android", "native_app_glue", "android_native_app_glue.h"), path.join(package:installdir("include"), "android_native_app_glue.h"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <LLGL/LLGL.h>
            void test() {
                auto t = LLGL::Timer::Tick();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)

