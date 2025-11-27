package("nri")
    set_homepage("https://github.com/NVIDIA-RTX/NRI")
    set_description("Modular extensible low-level render interface (RHI) with higher level extensions")
    set_license("MIT")

    add_urls("https://github.com/NVIDIA-RTX/NRI/archive/refs/tags/$(version).tar.gz",
             "https://github.com/NVIDIA-RTX/NRI.git")

    add_versions("v176", "fddb596caca75af684af368b83a12f476263f6646b65cde57b52674668922943")

    add_configs("shared",   {description = "Build shared library.", default = false, type = "boolean", readonly = false})
    add_configs("none",     {description = "Enable NONE backend.", default = true, type = "boolean", readonly = false})
    add_configs("vulkan",   {description = "Enable Vulkan backend.", default = true, type = "boolean", readonly = false})
    add_configs("d3d11",    {description = "Enable D3D 11 backend.", default = true, type = "boolean", readonly = false})
    add_configs("d3d12",    {description = "Enable D3D 12 backend.", default = true, type = "boolean", readonly = false})
    add_configs("x11",      {description = "Enable X11 Support.", default = true, type = "boolean", readonly = false})
    add_configs("wayland",  {description = "Enable Wayland Support.", default = true, type = "boolean", readonly = false})
    add_configs("amd_ags",  {description = "Enable AMD AGS library for D3D.", default = true, type = "boolean", readonly = false})
    add_configs("nvapi",    {description = "Enable NVAPI library for D3D.", default = true, type = "boolean", readonly = false})
    add_configs("agility",  {description = "Enable Agility SDK for D3D12.", default = true, type = "boolean", readonly = false})
    add_configs("ngx",      {description = "Enable NVIDIA NGX(DLSS) SDK.", default = false, type = "boolean", readonly = false})
    add_configs("nis",      {description = "Enable NVIDIA Image Sharpening SDK.", default = true, type = "boolean", readonly = false})
    add_configs("ffx",      {description = "Enable AMD FidelityFX SDK.", default = false, type = "boolean", readonly = false})
    add_configs("xess",     {description = "Enable Intel XeSS SDK.", default = false, type = "boolean", readonly = false})
    add_configs("imgui",    {description = "Enable NRIImgui extension.", default = false, type = "boolean", readonly = false})

    add_deps("cmake")

    add_syslinks("user32", "gdi32", "dxgi", "dxguid")

    on_install(function(package)
        local configs = {}

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_STATIC_LIBRARY=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DNRI_ENABLE_NONE_SUPPORT=" .. (package:config("none") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_VK_SUPPORT=" .. (package:config("vulkan") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_D3D11_SUPPORT=" .. (package:config("d3d11") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_D3D12_SUPPORT=" .. (package:config("d3d12") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_XLIB_SUPPORT=" .. (package:config("x11") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_WAYLAND_SUPPORT=" .. (package:config("wayland") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_AMDAG=" .. (package:config("amd_ags") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_NVAPI=" .. (package:config("nvapi") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_AGILITY_SDK_SUPPORT=" .. (package:config("agility") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_NGX_SDK=" .. (package:config("ngx") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_NIS_SDK=" .. (package:config("nis") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_FFX_SDK=" .. (package:config("ffx") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_XESS_SDK=" .. (package:config("xess") and "ON" or "OFF"))
        table.insert(configs, "-DNRI_ENABLE_IMGUI_EXTENSION=" .. (package:config("imgui") and "ON" or "OFF"))

        import("package.tools.cmake").build(package, configs)
        
        os.cp("Include/**", package:installdir("include"), {rootdir = "Include"})
        os.cp("_Shaders/**", package:installdir("include"), {rootdir = "_Shaders"})
        os.cp("_Bin/**", package:installdir("bin"))
        os.cp(path.join(package:installdir("bin"), "**.lib"), package:installdir("lib"), {rootdir = path.join(package:installdir("bin"))})
        os.cp(path.join(package:installdir("bin"), "**.a"), package:installdir("lib"), {rootdir = path.join(package:installdir("bin"))})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <NRI.h>
            #include "NRIDescs.h"
            #include "Extensions/NRIDeviceCreation.h"
            #include "Extensions/NRISwapChain.h"
            void test() {
                const nri::DeviceCreationDesc deviceCreateDesc = {};
                nri::Device* device = nullptr;
                nri::nriCreateDevice(deviceCreateDesc, device);
                nri::SwapChain* swapChain = nullptr;
                nri::CoreInterface nriCore;
                nri::nriGetInterface(*device, NRI_INTERFACE(nri::CoreInterface), &nriCore);
            }
        ]]}))
    end)