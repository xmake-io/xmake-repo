package("diligent-engine")
    set_kind("library")
    set_homepage("https://diligentgraphics.com/diligent-engine")
    set_description("A modern cross-platform low-level graphics API.")
    set_license("Apache-2.0")

    set_sourcedir("ThirdParty/DiligentCore")
    add_deps("cmake")

    add_configs("d3d11",                {description = "Build support for D3D11", default = true, type = "boolean"})
    add_configs("d3d12",                {description = "Build support for D3D12", default = true, type = "boolean"})
    add_configs("gl",                   {description = "Build support for GL", default = true, type = "boolean"})
    add_configs("gles",                 {description = "Build support for GLES", default = true, type = "boolean"})
    add_configs("vk",                   {description = "Build support for Vulkan", default = true, type = "boolean"})
    add_configs("wgpu",                 {description = "Build support for WebGPU", default = false, type = "boolean"})
    add_configs("mtl",                  {description = "Build support for Metal", default = false, type = "boolean"})

    add_configs("hlsl",                 {description = "Enable HLSL support in non-Direct3D backends", default = true, type = "boolean"})
    add_configs("archiver",             {description = "Build support for Archiver", default = true, type = "boolean"})
    add_configs("d3d12_pix",            {description = "Build support for PIX for D3D12", default = true, type = "boolean"})

    add_configs("x11",      {description = "Build support for X11", default = true, type = "boolean"})
    add_configs("wayland",  {description = "Build support for Wayland", default = false, type = "boolean"})
    
    add_configs("shared",       {description = "Build shared library.", default = true, type = "boolean"})
    add_configs("exceptions",   {description = "Enable exceptions", default = false, type = "boolean"})
    add_configs("symbols",      {description = "When turning this option on, the library will be compiled with debug symbols", default = false, type = "boolean"})
    add_configs("asan",         {description = "Enable Address Sanitize.", default = false, type = "boolean"})

    if is_plat("windows") then
        add_syslinks("comdlg32")
        add_syslinks("d3d11", "d3dcompiler", "dxguid")
        add_syslinks("d3d12", "dxgi")
    end
    
    on_load(function (package)
        if is_plat("linux") then
            if package:config("x11") then
                package:add("deps", "libx11", "libxrandr", "libxrender", "libxinerama", "libxfixes", "libxcursor", "libxi", "libxext")
            end
            if package:config("wayland") then
                package:add("deps", "wayland")
            end
        end

        if package:config("gl") then
            package:add("deps", "opengl")
        end
        if package:config("vk") then
            package:add("deps", "vulkansdk")
        end
    end)

    on_install(function (package)
        local package_arch = nil
        if package:is_arch("x64", "x86_64") then
            package_arch = "x64"
        elseif package:is_arch("arm64", "arm64-v8a") then
            package_arch = "ARM64"
        end

        local libraries = {
            { key = "d3d11",    macro = "D3D11_SUPPORTED"    },
            { key = "d3d12",    macro = "D3D12_SUPPORTED"    },
            { key = "gl",       macro = "GL_SUPPORTED"       },
            { key = "gles",     macro = "GLES_SUPPORTED"     },
            { key = "vk",       macro = "VULKAN_SUPPORTED"   },
            { key = "webgpu",   macro = "WEBGPU_SUPPORTED"   },
            { key = "metal",    macro = "METAL_SUPPORTED"    },
            { key = "archiver", macro = "ARCHIVER_SUPPORTED" },
        }

        local platforms = {
            "PLATFORM_WIN32",
            "PLATFORM_UNIVERSAL_WINDOWS",
            "PLATFORM_ANDROID",
            "PLATFORM_LINUX",
            "PLATFORM_MACOS",
            "PLATFORM_IOS",
            "PLATFORM_TVOS",
            "PLATFORM_EMSCRIPTEN"
        }

        -- used to append to CMakelists.txts
        local footer = [[

            add_executable(DummyExecutable dummymain.cpp)
            target_compile_options(DummyExecutable PRIVATE -DUNICODE -DENGINE_DLL)
            copy_required_dlls(DummyExecutable)

            set(XMAKE_MACROS_TO_EXPORT "")
        ]]

        -- add macros to export to XMAKE_MACROS_TO_EXPORT
        -- DiligentCore exports D3D11_SUPPORTED, ... etc
        for _, cfg in ipairs(libraries) do
            if package:config(cfg.key) then
                footer = footer .. [[
                    if (]] .. cfg.macro .. [[)  
                        set(XMAKE_MACROS_TO_EXPORT "${XMAKE_MACROS_TO_EXPORT} ]] .. cfg.macro .. [[")
                    endif()
                ]]
            end
        end

        -- add macros to export to XMAKE_MACROS_TO_EXPORT
        -- DiligentCore exports PLATFORM_WIN32, ... etc
        for _, platform in ipairs(platforms) do
            footer = footer .. [[
                if (]] .. platform .. [[)  
                    set(XMAKE_MACROS_TO_EXPORT "${XMAKE_MACROS_TO_EXPORT} ]] .. platform .. [[")
                endif()
            ]]
        end

        -- save original CMakeLists.txt
        if not os.isfile("CMakeLists.txt.dummy") then
            os.cp("CMakeLists.txt", "CMakeLists.txt.dummy")
        end

        -- read original CMakeLists.txt
        local file = io.open("CMakeLists.txt.dummy", "r")
        local content = file:read("*a")
        file:close()

        -- replace /WX with /WX- to avoid treating warnings as errors
        content = content:gsub('"/WX"', '"/WX-"')
        -- add /EHsc to enable exceptions if needed
        if package:config("exceptions") then
            content = content:gsub("/wd26812", "/wd26812 /EHsc")
        end

        -- temporary files to store macros to export after cmake build
        local macros_export = path.join(package:installdir(), "macros_export.tmp")
        macros_export = macros_export:gsub("\\", "/")

        -- append the footer and export function to CMakeLists.txt
        content = content .. footer .. [[

            #write all XMAKE_MACROS_TO_EXPORT to a file, XMAKE_MACROS_TO_EXPORT is cmakelists variable list
            file(WRITE "]] .. macros_export .. [[" "${XMAKE_MACROS_TO_EXPORT}")
        ]]

        file = io.open("CMakeLists.txt", "w")
        file:write(content)
        file:close()

        -- --

        local configs = {
            "-DCMAKE_COMPILE_WARNING_AS_ERROR=OFF",
            "-DDILIGENT_BUILD_TESTS=OFF",
            "-DDILIGENT_MSVC_RELEASE_COMPILE_OPTIONS=",
            "-DDILIGENT_NO_FORMAT_VALIDATION=ON"
        };
        
        local build_mode = nil
        if package:debug() then
            build_mode = "Debug"
            table.insert(configs, "-DCMAKE_BUILD_TYPE=Debug")
            table.insert(configs, "-DDILIGENT_INSTALL_PDB=ON")
            package:add("defines", "DILIGENT_DEBUG=1")
        elseif package:config("symbols") then
            build_mode = "RelWithDebInfo"
            table.insert(configs, "-DCMAKE_BUILD_TYPE=RelWithDebInfo")
            table.insert(configs, "-DDILIGENT_INSTALL_PDB=ON")
        else
            build_mode = "Release"
            table.insert(configs, "-DCMAKE_BUILD_TYPE=Release")
            table.insert(configs, "-DDILIGENT_INSTALL_PDB=OFF")
        end
        
        table.insert(configs, "-DDILIGENT_NO_DIRECT3D11=" .. (package:config("d3d11") and "OFF" or "ON"))
        table.insert(configs, "-DDILIGENT_NO_DIRECT3D12=" .. (package:config("d3d12") and "OFF" or "ON"))
        table.insert(configs, "-DDILIGENT_NO_OPENGL=" .. ((package:config("gl") or package:config("gles")) and "OFF" or "ON"))
        table.insert(configs, "-DDILIGENT_NO_VULKAN=" .. (package:config("vk") and "OFF" or "ON"))
        table.insert(configs, "-DDILIGENT_NO_WEBGPU=" .. (package:config("wgpu") and "OFF" or "ON"))
        table.insert(configs, "-DDILIGENT_NO_METAL=" .. (package:config("mtl") and "OFF" or "ON"))

        table.insert(configs, "-DDILIGENT_NO_HLSL=" .. (package:config("hlsl") and "OFF" or "ON"))
        table.insert(configs, "-DDILIGENT_NO_ARCHIVER=" .. (package:config("archiver") and "OFF" or "ON"))

        if package:config("d3d12") and package:config("d3d12_pix") then
            table.insert(configs, "-DDILIGENT_LOAD_PIX_EVENT_RUNTIME=ON")
        end

        io.writefile("dummymain.cpp", "int main() { return 0; }")
        if package:is_plat("windows") then
            cxflags = "/FS"
        end
        import("package.tools.cmake").install(package, configs, {cxflags = cxflags, config = (package:debug() and "Debug" or "Release")})
        os.rm("dummymain.cpp")

        local macros = io.readfile(macros_export)
        if #macros > 0 then
            -- for each macro, seperate by space
            for macro in macros:gmatch("%S+") do
                package:add("defines", macro .. "=1")
            end
            os.rm(macros_export)
        end

        if package:config("shared") then
            package:add("defines", "ENGINE_DLL=1")
        end

        -- move extra files such as compiler, pix, etc used by library
        local extra_files = {
            "D3Dcompiler_47.dll",
            "dxcompiler.dll",
            "spv_dxcompiler.dll",
            "WinPixEventRuntime_UAP.dll",
            "WinPixEventRuntime.dll"
        }

        local has_winpix = false
        local has_winpix_uwp = false

        -- check if winpix dlls if available
        for _, file in ipairs(extra_files) do
            local src_dir = path.join(package:buildir(), build_mode, file)
            if os.isfile(src_dir) then
                os.trycp(src_dir, package:installdir("bin"))
                if file == "WinPixEventRuntime.dll" then
                    has_winpix = true
                elseif file == "WinPixEventRuntime_UAP.dll" then
                    has_winpix_uwp = true
                end
            end
        end

        -- copy winpix libs
        if has_winpix or has_winpix_uwp then
            local pix_runtime = path.join(package:buildir(), "WinPixEventRuntime", "bin", package_arch)
            if os.isdir(pix_runtime) then
                if has_winpix then
                    os.trycp(path.join(pix_runtime, "WinPixEventRuntime.lib"), package:installdir("lib"))
                end
                if has_winpix_uwp then
                    os.trycp(path.join(pix_runtime, "WinPixEventRuntime_UAP.lib"), package:installdir("lib"))
                end
            end
        end

        -- copy dlls and libs
        local src_distrib_lib_dir = path.join(package:installdir("lib"), build_mode)
        local src_distrib_bin_dir = path.join(package:installdir("bin"), build_mode)

        -- move files to correct directories
        os.mv(path.join(src_distrib_lib_dir, "*.lib"),      package:installdir("lib"))
        os.mv(path.join(src_distrib_lib_dir, "*.so"),       package:installdir("lib"))
        os.mv(path.join(src_distrib_lib_dir, "*.a"),        package:installdir("lib"))
        os.mv(path.join(src_distrib_lib_dir, "*.dylib"),    package:installdir("lib"))
        os.rm(src_distrib_lib_dir)

        os.mv(path.join(src_distrib_bin_dir, "*.dll"),  package:installdir("bin"))
        os.mv(path.join(src_distrib_bin_dir, "*.pdb"),  package:installdir("bin"))
        os.rm(src_distrib_bin_dir)

        -- copy include files
        local src_inc_dir = package:installdir("include")
        local dst_inc_dir = path.join(src_inc_dir, "DiligentCore")

        os.mv(path.join(src_inc_dir, "Common"),    path.join(dst_inc_dir, "Common"))
        os.mv(path.join(src_inc_dir, "Graphics"),  path.join(dst_inc_dir, "Graphics"))
        os.mv(path.join(src_inc_dir, "Platforms"), path.join(dst_inc_dir, "Platforms"))
        os.mv(path.join(src_inc_dir, "Primitives"),path.join(dst_inc_dir, "Primitives"))
        
        -- link libraries
        local linked_libs = {}
        local function link_libs(lib_dir, lib_extension)
            for _, file in ipairs(os.files(path.join(lib_dir, lib_extension))) do
                file = path.filename(file)
                file = file:sub(1, #file - 4)
                -- if it hasn't been linked yet
                if not linked_libs[file] then
                    linked_libs[file] = true
                    package:add("links", file)
                end
            end
        end
        
        link_libs(package:installdir("lib"), "*.lib")
        link_libs(package:installdir("lib"), "*.so")
        link_libs(package:installdir("lib"), "*.a")
        link_libs(package:installdir("lib"), "*.dylib")
        link_libs(package:installdir("bin"), "*.dll")
    end)

    on_test(function (package)
        if package:config("vk") then
            assert(package:check_cxxsnippets({test = [[
            #if VULKAN_SUPPORTED
                #include <DiligentCore/Graphics/GraphicsEngineVulkan/interface/EngineFactoryVk.h>
            #endif
                void test() {
                #if VULKAN_SUPPORTED
                    Diligent::EngineVkCreateInfo create_info;
                    Diligent::IEngineFactoryVk* factory = nullptr;
                    if (factory) {
                        factory->CreateDeviceAndContextsVk(create_info, nullptr, nullptr);
                    }
                #endif
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("gl") or package:config("gles") then
            assert(package:check_cxxsnippets({test = [[
            #if GL_SUPPORTED || GLES_SUPPORTED
                #include <DiligentCore/Graphics/GraphicsEngineOpenGL/interface/EngineFactoryOpenGL.h>
            #endif
                void test() {
            #if GL_SUPPORTED || GLES_SUPPORTED
                    Diligent::EngineGLCreateInfo create_info;
                    Diligent::IEngineFactoryOpenGL* factory = nullptr;
                    Diligent::SwapChainDesc scd;
                    if (factory) {
                        factory->CreateDeviceAndSwapChainGL(create_info, nullptr, nullptr, scd, nullptr);
                    }
            #endif
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("d3d11") then
            assert(package:check_cxxsnippets({test = [[
            #if D3D11_SUPPORTED
                #include <DiligentCore/Graphics/GraphicsEngineD3D11/interface/EngineFactoryD3D11.h>
            #endif
                void test() {
            #if D3D11_SUPPORTED
                Diligent::EngineD3D11CreateInfo create_info;
                Diligent::IEngineFactoryD3D11* factory = nullptr;
                if (factory) {
                    factory->CreateDeviceAndContextsD3D11(create_info, nullptr, nullptr);
                }
            #endif
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("d3d12") then
            assert(package:check_cxxsnippets({test = [[
            #if D3D12_SUPPORTED
                #include <DiligentCore/Graphics/GraphicsEngineD3D12/interface/EngineFactoryD3D12.h>
            #endif
                void test() {
            #if D3D12_SUPPORTED
                Diligent::EngineD3D12CreateInfo create_info;
                Diligent::IEngineFactoryD3D12* factory = nullptr;
                if (factory) {
                    factory->CreateDeviceAndContextsD3D12(create_info, nullptr, nullptr);
                }
            #endif
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("mtl") then
            assert(package:check_cxxsnippets({test = [[
            #if METAL_SUPPORTED
                #include <DiligentCore/Graphics/GraphicsEngineMetal/interface/EngineFactoryMetal.h>
            #endif
                void test() {
            #if METAL_SUPPORTED
                Diligent::EngineMetalCreateInfo create_info;
                Diligent::IEngineFactoryMtl* factory = nullptr;
                if (factory) {
                    factory->CreateDeviceAndContextsMtl(create_info, nullptr, nullptr);
                }
            #endif
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("wgpu") then
            assert(package:check_cxxsnippets({test = [[
            #if WEBGPU_SUPPORTED
                #include <DiligentCore/Graphics/GraphicsEngineWebGPU/interface/EngineFactoryWebGPU.h>
            #endif
                void test() {
            #if WEBGPU_SUPPORTED
                Diligent::EngineWebGPUCreateInfo create_info;
                Diligent::IEngineFactoryWebGPU* factory = nullptr;
                if (factory) {
                    factory->CreateDeviceAndContextsWebGPU(create_info, nullptr, nullptr);
                }
            #endif
                }
            ]]}, {configs = {languages = "c++17"}}))
        end
        
    end)
