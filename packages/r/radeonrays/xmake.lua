package("radeonrays")
    set_homepage("https://github.com/GPUOpen-LibrariesAndSDKs/RadeonRays_SDK")
    set_description("Radeon Rays is ray intersection acceleration library for hardware and software multiplatforms using CPU and GPU")
    set_license("MIT")

    add_urls("https://github.com/GPUOpen-LibrariesAndSDKs/RadeonRays_SDK/archive/refs/tags/$(version).tar.gz",
             "https://github.com/GPUOpen-LibrariesAndSDKs/RadeonRays_SDK.git", {submodules = false})

    add_versions("4.1", "96ea69b8942d2b0d58295723aa82ef19517193a09a137d0f7c6bcd44a8ae0368")

    add_configs("dx12", {description = "Enable DX12 backend", default = false, type = "boolean"})
    add_configs("vulkan", {description = "Enable Vulkan backend", default = false, type = "boolean"})
    add_configs("embedded", {description = "Enable embedding kernels/shaders into library", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools(bvh_analyzer)", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("spdlog <1.13.0", {configs = {header_only = false}})

    if is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        if package:config("vulkan") then
            package:add("deps", "vulkansdk")
        end
        if package:config("dx12") then
            package:add("deps", "directx-headers")
        end
    end)

    on_install(function (package)
        if not package:config("tools") then
            io.replace("CMakeLists.txt", "add_subdirectory(bvh_analyzer)", "", {plain = true})
        end
        if not package:config("shared") then
            io.replace("src/core/include/radeonrays.h", "__declspec(dllexport)", "", {plain = true})
            io.replace("src/core/include/radeonrays.h", "__declspec(dllimport)", "", {plain = true})
        end

        local file = io.open("CMakeLists.txt", "a")
        file:write([[
            include(GNUInstallDirs)
            install(TARGETS radeonrays
                RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
                LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
                ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
            )
            install(DIRECTORY src/core/include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
        ]])
        file:close()

        local configs = {"-DENABLE_TESTING=OFF", "-DENABLE_FUZZING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_VULKAN=" .. (package:config("vulkan") and "ON" or "OFF"))
        table.insert(configs, "-DENABLE_DX12=" .. (package:config("dx12") and "ON" or "OFF"))
        table.insert(configs, "-DEMBEDDED_KERNELS=" .. (package:config("embedded") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("rrCreateContext", {includes = "radeonrays.h"}))
        if package:config("dx12") then
            assert(package:has_cxxfuncs("rrGetDevicePtrFromD3D12Resource", {includes = "radeonrays_dx.h"}))
        end
        if package:config("vulkan") then
            assert(package:has_cxxfuncs("rrGetDevicePtrFromVkBuffer", {includes = "radeonrays_vlk.h"}))
        end
    end)
