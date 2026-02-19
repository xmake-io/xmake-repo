package("nvrhi")
    set_homepage("https://github.com/NVIDIA-RTX/NVRHI")
    set_description("NVIDIA Rendering Hardware Interface")
    set_license("MIT")
    
    add_urls("https://github.com/NVIDIA-RTX/NVRHI.git")

    add_configs("shared",     { description = "Build NVRHI as a shared library (DLL or .so)",    default = false, type = "boolean" })
    add_configs("validation", { description = "Build the validation layer",                      default = true,  type = "boolean" })
    add_configs("vulkan",     { description = "Build the Vulkan backend",                        default = true,  type = "boolean" })
    add_configs("rtxmu",      { description = "Use RTXMU for acceleration structure management", default = false, type = "boolean" })
    add_configs("aftermath",  { description = "Include Aftermath support",                       default = false, type = "boolean" })
        
    if is_plat("windows") then
        add_configs("d3d11",                  { description = "Build the D3D11 backend",                         default = true,  type = "boolean" })
        add_configs("d3d12",                  { description = "Build the D3D12 backend",                         default = true,  type = "boolean" })
        add_configs("nvapi",                  { description = "Include NVAPI support (requires NVAPI SDK)",      default = false, type = "boolean" })
        add_configs("nvapi_dir",              { description = "Path to NVAPI SDK root directory",                default = nil,   type = "string"  })
        add_configs("dxr12_opacity_micromap", { description = "Use D3D12 native Opacity Micromaps from DXR 1.2", default = false, type = "boolean" })
    end

    add_deps("cmake")

    if is_plat("windows") then
        add_syslinks("d3d11", "d3d12", "dxguid")
    end

    on_load("linux", "windows|x86_64", function (package)
        if package:config("rtxmu") then
            package:add("deps", "rtxmu")
        end
        if package:config("shared") then
            package:add("defines", "NVRHI_SHARED_LIBRARY_IMPORT=1")
        end
    end)

    on_install("linux", "windows|x86_64", function (package)
        local configs = { "-DNVRHI_INSTALL=ON" }

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DNVRHI_BUILD_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DNVRHI_WITH_VALIDATION=" .. (package:config("validation") and "ON" or "OFF"))
        table.insert(configs, "-DNVRHI_WITH_VULKAN=" .. (package:config("vulkan") and "ON" or "OFF"))
        table.insert(configs, "-DNVRHI_WITH_RTXMU=" .. (package:config("rtxmu") and "ON" or "OFF"))
        table.insert(configs, "-DNVRHI_WITH_AFTERMATH=" .. (package:config("aftermath") and "ON" or "OFF"))
        
        if package:config("aftermath") then
            local aftermath_dir = package:config("aftermath_dir")
            if aftermath_dir then
                table.insert(configs, "-DAFTERMATH_SEARCH_PATHS=" .. aftermath_dir)
            end
        end

        if package:is_plat("windows") then
            table.insert(configs, "-DNVRHI_WITH_DX11=" .. (package:config("d3d11") and "ON" or "OFF"))
            table.insert(configs, "-DNVRHI_WITH_DX12=" .. (package:config("d3d12") and "ON" or "OFF"))
            table.insert(configs, "-DNVRHI_WITH_NVAPI=" .. (package:config("nvapi") and "ON" or "OFF"))

            if package:config("d3d12") then
                table.insert(configs, "-DNVRHI_D3D12_WITH_DXR12_OPACITY_MICROMAP=" .. (package:config("dxr12_opacity_micromap") and "ON" or "OFF"))
            end

            if package:config("nvapi") then
                local nvapi_dir = package:config("nvapi_dir")
                if nvapi_dir then
                    table.insert(configs, "-DNVAPI_SEARCH_PATHS=" .. nvapi_dir)
                end
            end
        else
            table.insert(configs, "-DNVRHI_WITH_DX11=OFF")
            table.insert(configs, "-DNVRHI_WITH_DX12=OFF")
            table.insert(configs, "-DNVRHI_WITH_NVAPI=OFF")
        end

        import("package.tools.cmake").install(package, configs)

        
        if package:config("aftermath") then
            local aftermath_root = package:config("aftermath_dir")
            if not aftermath_root then
                aftermath_root = package:buildir()
            end

            if package:is_plat("windows") then
                local dll_files = os.files(path.join(aftermath_root, "**", "GFSDK_Aftermath_Lib.x64.dll"))
                if dll_files and #dll_files > 0 then
                    os.cp(dll_files[1], package:installdir("bin"))
                end

                local implib_files = os.files(path.join(aftermath_root, "**", "GFSDK_Aftermath_Lib.x64.lib"))
                if implib_files and #implib_files > 0 then
                    os.cp(implib_files[1], package:installdir("lib"))
                end
            else
                local so_files = os.files(path.join(aftermath_root, "**", "libGFSDK_Aftermath_Lib.x64.so"))
                if so_files and #so_files > 0 then
                    os.cp(so_files[1], package:installdir("lib"))
                end
            end

            local aftermath_include = os.files(path.join(aftermath_root, "**", "GFSDK_Aftermath.h"))
            if aftermath_include and #aftermath_include > 0 then
                local include_dir = path.directory(aftermath_include[1])
                os.cp(path.join(include_dir, "*.h"), package:installdir("include"))
            end
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({ test = [[
            #include <nvrhi/nvrhi.h>
            void test() {
                nvrhi::GraphicsAPI api = nvrhi::GraphicsAPI::VULKAN;
                (void)api;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
package_end()