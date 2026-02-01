package("nri")
    set_homepage("https://github.com/NVIDIA-RTX/NRI")
    set_description("Modular extensible low-level render interface (RHI) with higher level extensions")
    set_license("MIT")

    add_urls("https://github.com/NVIDIA-RTX/NRI/archive/refs/tags/$(version).tar.gz",
             "https://github.com/NVIDIA-RTX/NRI.git")

    add_versions("v177", "3e031984f94586cea73ed351c45324736e2b9160ec825f3e6b315c2fa4d73107")
    add_versions("v176", "fddb596caca75af684af368b83a12f476263f6646b65cde57b52674668922943")

    add_configs("none",    {description = "Enable NONE backend.", default = false, type = "boolean"})
    add_configs("vulkan",  {description = "Enable Vulkan backend.", default = false, type = "boolean"})
    add_configs("d3d11",   {description = "Enable D3D 11 backend.", default = false, type = "boolean"})
    add_configs("d3d12",   {description = "Enable D3D 12 backend.", default = false, type = "boolean"})
    add_configs("x11",     {description = "Enable X11 Support.", default = false, type = "boolean"})
    add_configs("wayland", {description = "Enable Wayland Support.", default = false, type = "boolean"})
    -- TODO: unbundle this sdk
    add_configs("amd_ags", {description = "Enable AMD AGS library for D3D.", default = false, type = "boolean"})
    add_configs("nvapi",   {description = "Enable NVAPI library for D3D.", default = false, type = "boolean"})
    add_configs("nvtx",    {description = "Annotations for NVIDIA Nsight Systems", default = false, type = "boolean"})
    add_configs("agility", {description = "Enable Agility SDK for D3D12.", default = false, type = "boolean"})
    add_configs("ngx",     {description = "Enable NVIDIA NGX(DLSS) SDK.", default = false, type = "boolean"})
    add_configs("nis",     {description = "Enable NVIDIA Image Sharpening SDK.", default = false, type = "boolean"})
    add_configs("ffx",     {description = "Enable AMD FidelityFX SDK.", default = false, type = "boolean"})
    add_configs("xess",    {description = "Enable Intel XeSS SDK.", default = false, type = "boolean"})
    add_configs("imgui",   {description = "Enable NRIImgui extension.", default = false, type = "boolean"})

    add_links("NRI", "NRI_NONE", "NRI_D3D11", "NRI_D3D12", "NRI_VK", "NRI_Validation", "NRI_Shared")

    add_deps("cmake")

    on_load(function(package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", [[NRI_API=extern "C" __declspec(dllimport)]])
        end

        if package:is_plat("windows", "mingw") then
            package:add("syslinks", "user32", "gdi32")
            if package:config("d3d11") then
                package:add("syslinks", "d3d11", "dxgi", "dxguid")
            end
            if package:config("d3d12") then
                package:add("deps", "d3d12-memory-allocator 2ac8a9bdada39ad75210be7b6da8b2b0f61e84f5") -- 2025.09.30
                package:add("syslinks", "d3d12", "dxgi", "dxguid")
            end
        end
        if package:config("vulkan") then
            package:add("deps", "vulkan-headers v1.4.329", "vulkan-memory-allocator")
            wprint([[package(nri) vulkan config require add_requireconfs("**.vulkan-headers", {override = true, version = "v1.4.329"})]])
        end

        if package:config("x11") then
            package:add("deps", "libx11")
        end
        if package:config("wayland") then
            package:add("deps", "wayland")
        end
    end)

    on_install("!wasm and !bsd and (!windows or windows|!x86) and (!android or android|!armeabi-v7a)", function(package)
        io.replace("CMakeLists.txt", "/WX", "", {plain = true})
        io.replace("CMakeLists.txt", "-Werror", "", {plain = true})
        if package:config("d3d12") then
            io.replace("CMakeLists.txt", "list(APPEND DEPS d3d12ma)", "", {plain = true})
            io.replace("CMakeLists.txt", [[set(D3D12_VMA "${d3d12ma_SOURCE_DIR}/include/D3D12MemAlloc.h")]], "find_package(D3D12MemoryAllocator CONFIG REQUIRED)", {plain = true})
            io.replace("Source/D3D12/MemoryAllocatorD3D12.h", "D3D12MemAlloc.cpp", "D3D12MemAlloc.h", {plain = true})
        end
        if package:config("vulkan") then
            io.replace("CMakeLists.txt", "list(APPEND DEPS vulkan_headers)", "", {plain = true})
            io.replace("CMakeLists.txt", "list(APPEND DEPS vma)", "", {plain = true})
            io.replace("CMakeLists.txt", [[set(VK_VMA "${vma_SOURCE_DIR}/include/vk_mem_alloc.h")]], "find_package(VulkanMemoryAllocator CONFIG REQUIRED)", {plain = true})
        end

        local file = io.open("CMakeLists.txt", "a")
        file:print("include(GNUInstallDirs)")
        file:print("install(DIRECTORY Include/ DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})")
        file:print("install(DIRECTORY Shaders/ DESTINATION Shaders)")

        if package:config("d3d12") then
            file:print("target_link_libraries(NRI_D3D12 PRIVATE GPUOpen::D3D12MemoryAllocator)")
        end
        if package:config("vulkan") then
            file:print("find_package(VulkanHeaders CONFIG REQUIRED)")
            file:print("target_link_libraries(NRI_Shared PRIVATE Vulkan::Headers)")
            file:print("target_link_libraries(NRI PRIVATE Vulkan::Headers)")
            file:print("target_link_libraries(NRI_VK PRIVATE GPUOpen::VulkanMemoryAllocator Vulkan::Headers)")
        end

        local targets = {
            ["NRI_Shared"] = true,
            ["NRI_NONE"] = package:config("none"),
            ["NRI_D3D11"] = package:config("d3d11"),
            ["NRI_D3D12"] = package:config("d3d12"),
            ["NRI_VK"] = package:config("vulkan"),
            ["NRI_Validation"] = true,
            ["NRI"] = true,
        }
        for target, enabled in pairs(targets) do
            if enabled then
                file:print(format([[
                    install(TARGETS %s
                        RUNTIME DESTINATION bin
                        LIBRARY DESTINATION lib
                        ARCHIVE DESTINATION lib
                    )
                ]], target))
            end
        end
        file:close()

        local configs = {"-DNRI_ENABLE_VALIDATION_SUPPORT=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_STATIC_LIBRARY=" .. (package:config("shared") and "OFF" or "ON"))

        table.insert(configs, "-DNRI_ENABLE_NONE_SUPPORT=" .. (package:config("none") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_VK_SUPPORT=" .. (package:config("vulkan") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_D3D11_SUPPORT=" .. (package:config("d3d11") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_D3D12_SUPPORT=" .. (package:config("d3d12") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_XLIB_SUPPORT=" .. (package:config("x11") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_WAYLAND_SUPPORT=" .. (package:config("wayland") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_AMDAGS=" .. (package:config("amd_ags") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_NVAPI=" .. (package:config("nvapi") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_NVTX_SUPPORT=" .. (package:config("nvtx") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_AGILITY_SDK_SUPPORT=" .. (package:config("agility") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_NGX_SDK=" .. (package:config("ngx") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_NIS_SDK=" .. (package:config("nis") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_FFX_SDK=" .. (package:config("ffx") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_XESS_SDK=" .. (package:config("xess") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_IMGUI_EXTENSION=" .. (package:config("imgui") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <NRI.h>
            #include <NRIDescs.h>
            #include <Extensions/NRIDeviceCreation.h>
            #include <Extensions/NRISwapChain.h>
            void test() {
                const nri::DeviceCreationDesc deviceCreateDesc = {};
                nri::Device* device = nullptr;
                nri::nriCreateDevice(deviceCreateDesc, device);
                nri::SwapChain* swapChain = nullptr;
                nri::CoreInterface nriCore;
                nri::nriGetInterface(*device, NRI_INTERFACE(nri::CoreInterface), &nriCore);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
