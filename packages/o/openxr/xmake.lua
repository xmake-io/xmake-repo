package("openxr")
    set_homepage("https://khronos.org/openxr")
    set_description("Generated headers and sources for OpenXR loader.")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/OpenXR-SDK.git", {alias = "git"})
    add_urls("https://github.com/KhronosGroup/OpenXR-SDK/archive/refs/tags/release-$(version).tar.gz")

    add_versions("1.1.49", "74e9260a1876b0540171571a09bad853302ec68a911200321be8b0591ca94111")

    add_versions("git:1.1.49", "release-1.1.49")

    add_patches("1.1.49", "patches/1.1.49/fix-mingw.diff", "8cc18048e3be5f64e6f2038303bcfff7137290cf60785ff795d3d57ef1a717b3")
    add_patches("1.1.49", "patches/1.1.49/fix-freebsd.diff", "f4b63875a75609d2c4ce112f67e74713edb25eb238e9a544441f534a87b523b9")
    add_patches("1.1.49", "patches/1.1.49/ppc-support.diff", "1bb423ec10110f9003803c63d50154f60ba063917c34f066f12e957eef4424c0")

    add_configs("api_layers", {description = "Build the API layers.", default = false, type = "boolean"})

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::openxr-sdk")
    elseif is_plat("linux") then
        add_extsources("pacman::openxr", "apt::libopenxr-dev")
    end

    add_deps("cmake", "python 3.x", {kind = "binary"})
    add_deps("jsoncpp")
    if is_plat("linux", "cross", "bsd") then
        add_deps("libx11")
    elseif is_plat("android") then
        add_deps("egl-headers")
    end

    if is_plat("windows", "mingw") then
        add_syslinks("advapi32")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    elseif is_plat("android") then
        add_syslinks("log", "android")
    elseif is_plat("macosx") then
        add_frameworks("AppKit", "Foundation", "CoreGraphics")
    elseif is_plat("iphoneos") then
        add_frameworks("Foundation", "CoreGraphics", "OpenGLES")
    end

    on_install("!wasm", function (package)
        io.replace("src/CMakeLists.txt", "set(CMAKE_POSITION_INDEPENDENT_CODE ON)", "", {plain = true})
        if package:is_plat("mingw") then
            io.replace("src/loader/openxr-loader.def", "LIBRARY", "LIBRARY libopenxr_loader.dll", {plain = true})
        elseif package:is_plat("windows") then
            local runtime
            if package:has_runtime("MT") then
                runtime = "MultiThreaded"
            elseif package:has_runtime("MTd") then
                runtime = "MultiThreadedDebug"
            elseif package:has_runtime("MD") then
                runtime = "MultiThreadedDLL"
            elseif package:has_runtime("MDd") then
                runtime = "MultiThreadedDebugDLL"
            end
            io.replace("src/loader/CMakeLists.txt", "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL", runtime, {plain = true})
            io.replace("src/loader/CMakeLists.txt", "MultiThreaded$<$<CONFIG:Debug>:Debug>", runtime, {plain = true})
        end

        local configs = {
            "-DBUILD_CONFORMANCE_TESTS=OFF",
            "-DBUILD_TESTS=OFF",
            "-DOPENXR_DEBUG_POSTFIX=''",
            "-DBUILD_WITH_SYSTEM_JSONCPP=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DDYNAMIC_LOADER=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_API_LAYERS=" .. (package:config("api_layers") and "ON" or "OFF"))

        if package:is_plat("android") then
            table.insert(configs, "-DINSTALL_TO_ARCHITECTURE_PREFIXES=ON")
            os.vcp("include", package:installdir())
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = "libx11"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <openxr/openxr.h>
            #include <iostream>
            #include <cstring>

            void test() {
                XrInstanceCreateInfo createInfo = {};
                createInfo.type = XR_TYPE_INSTANCE_CREATE_INFO;
                strcpy(createInfo.applicationInfo.applicationName, "OpenXRTest");
                createInfo.applicationInfo.applicationVersion = 1;
                strcpy(createInfo.applicationInfo.engineName, "NoEngine");
                createInfo.applicationInfo.engineVersion = 1;
                createInfo.applicationInfo.apiVersion = XR_CURRENT_API_VERSION;

                XrInstance instance = XR_NULL_HANDLE;
                XrResult result = xrCreateInstance(&createInfo, &instance);

                if (result == XR_SUCCESS) {
                    std::cout << "OpenXR instance created successfully." << std::endl;
                    xrDestroyInstance(instance);
                } else {
                    std::cerr << "Failed to create OpenXR instance. Error: " << result << std::endl;
                }
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
