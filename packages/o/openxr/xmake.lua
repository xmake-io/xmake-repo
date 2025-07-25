package("openxr")
    set_homepage("https://khronos.org/openxr")
    set_description("Generated headers and sources for OpenXR loader.")
    set_license("Apache-2.0")

    add_urls("https://github.com/KhronosGroup/OpenXR-SDK.git", {alias = "git"})
    add_urls("https://github.com/KhronosGroup/OpenXR-SDK/archive/refs/tags/release-$(version).tar.gz")

    add_versions("1.1.49", "74e9260a1876b0540171571a09bad853302ec68a911200321be8b0591ca94111")

    add_versions("git:1.1.49", "release-1.1.49")

    add_configs("api_layers", {description = "Build the API layers.", default = false, type = "boolean"})

    add_deps("cmake", "python 3.x", {kind = "binary"})
    add_deps("jsoncpp")
    if is_plat("linux", "cross") then
        add_deps("libx11")
    elseif is_plat("android") then
        add_deps("egl-headers")
    end

    if is_plat("windows") then
        add_syslinks("advapi32")
    elseif is_plat("linux") then
        add_syslinks("pthread")
    end

    on_install("!bsd and !wasm", function (package)
        io.replace("src/CMakeLists.txt", "set(CMAKE_POSITION_INDEPENDENT_CODE ON)", "", {plain = true})
        if package:is_plat("windows") then
            local CMAKE_MSVC_RUNTIME_LIBRARY
            if package:has_runtime("MT") then
                CMAKE_MSVC_RUNTIME_LIBRARY = "MultiThreaded"
            elseif package:has_runtime("MTd") then
                CMAKE_MSVC_RUNTIME_LIBRARY = "MultiThreadedDebug"
            elseif package:has_runtime("MD") then
                CMAKE_MSVC_RUNTIME_LIBRARY = "MultiThreadedDLL"
            elseif package:has_runtime("MDd") then
                CMAKE_MSVC_RUNTIME_LIBRARY = "MultiThreadedDebugDLL"
            end
            io.replace("src/loader/CMakeLists.txt", "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL", CMAKE_MSVC_RUNTIME_LIBRARY, {plain = true})
            io.replace("src/loader/CMakeLists.txt", "MultiThreaded$<$<CONFIG:Debug>:Debug>", CMAKE_MSVC_RUNTIME_LIBRARY, {plain = true})
        end

        local configs = {
            "-DBUILD_CONFORMANCE_TESTS=OFF",
            "-DBUILD_TESTS=OFF",
            "-DOPENXR_DEBUG_POSTFIX=''",
            "-DBUILD_WITH_SYSTEM_JSONCPP=ON",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
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
