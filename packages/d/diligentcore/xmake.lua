package("diligentcore")
    set_homepage("http://diligentgraphics.com/diligent-engine/")
    set_description("A modern cross-platform low-level graphics API")
    set_license("Apache-2.0")

    add_urls("https://github.com/DiligentGraphics/DiligentCore/archive/refs/tags/$(version).tar.gz",
             "https://github.com/DiligentGraphics/DiligentCore.git", {submodules = false})

    add_versions("v2.5.6", "abc190c05ee7e5ef2bba52fcbc5fdfe2256cce3435efba9cfe263a386653f671")
    add_patches("v2.5.6", "patches/build.diff", "9cf7ec06e126f68d39f8f045d83a7a3d6beb43d951bf5a422def77900a16a9ad")

    add_includedirs("include", "include/DiligentCore")

    add_deps("pkgconf")

    if is_plat("windows", "mingw", "linux", "macosx") then
        add_configs("opengl",           {description = "Enable OpenGL/GLES backend", default = true, type = "boolean"})
    end

    if is_plat("windows") then
        add_configs("d3d11",            {description = "Enable Direct3D11 backend", default = false, type = "boolean"})
        add_configs("d3d12",            {description = "Enable Direct3D12 backend", default = false, type = "boolean"})
    end

    if is_plat("macosx", "iphoneos") then
        add_configs("metal",            {description = "Enable Metal backend", default = true, type = "boolean"})
    end

    add_configs("vulkan",               {description = "Enable Vulkan backend", default = false, type = "boolean"})

    add_configs("hlsl",                 {description = "Enable HLSL", default = false, type = "boolean"})
    add_configs("archiver",             {description = "Enable archiver", default = false, type = "boolean"})
    add_configs("format_validation",    {description = "Enable format validation", default = true, type = "boolean"})

    add_configs("x11",                  {description = "Build support for X11", default = true, type = "boolean"})
    add_configs("wayland",              {description = "Build support for Wayland", default = false, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("pthread", "dl")
    end

    if is_plat("macosx") then
        add_frameworks("AppKit")
    elseif is_plat("iphoneos") then
        add_frameworks("CoreFoundation", "Foundation", "OpenGLES")
    end

    add_deps("cmake")
    add_deps("xxhash")

    on_load(function (package)
        if package:is_plat("linux") then
            if package:config("x11") then
                package:add("deps", "libx11", "libxrandr", "libxrender", "libxinerama", "libxfixes", "libxcursor", "libxi", "libxext")
            end
            if package:config("wayland") then
                package:add("deps", "wayland")
            end
        end
        if package:is_plat("windows") then
            package:add("defines", "NOMINMAX", "WIN32_LEAN_AND_MEAN", "UNICODE")
        end
        if package:config("shared") then
            package:add("defines", "ENGINE_DLL=1")
        end
        if package:config("opengl") then
            package:add("deps", "glew")
            if package:config("archiver") then
                package:add("deps", "spirv-headers")
            end
        end
        if package:config("metal") then
            package:add("frameworks", "Metal")
            package:add("deps", "spirv-headers")
        end
        if package:config("vulkan") or package:config("hlsl") then
            package:add("deps", "vulkan-headers")
            if package:config("vulkan") and package:is_plat("windows", "linux", "macosx", "android") then
                package:add("deps", "volk", {header_only = true})
            end
            package:add("deps", "spirv-headers")
            package:add("deps", "spirv-tools")
            package:add("deps", "glslang")
        end
        package:add("deps", "spirv-cross")
    end)

    on_install("!bsd", function (package)
        -- glslang::SPIRV
        io.replace("Graphics/ShaderTools/src/GLSLangUtils.cpp", "SPIRV/GlslangToSpv.h", "glslang/SPIRV/GlslangToSpv.h", {plain = true})

        -- spirv-cross
        io.replace("Graphics/ShaderTools/src/SPIRVShaderResources.cpp", "spirv_parser.hpp", "spirv_cross/spirv_parser.hpp", {plain = true})
        io.replace("Graphics/ShaderTools/src/SPIRVUtils.cpp", "spirv_cross.hpp", "spirv_cross/spirv_cross.hpp", {plain = true})

        -- Dump CMakeLists.txt variables related for platform & rendering backend for package defines
        local CMakeLists_content = io.readfile("CMakeLists.txt")
        io.writefile("CMakeLists.txt", CMakeLists_content .. [[
get_cmake_property(vars VARIABLES)
list(SORT vars)
set(TARGET_VARS
    PLATFORM_ANDROID PLATFORM_EMSCRIPTEN PLATFORM_IOS PLATFORM_LINUX PLATFORM_MACOS PLATFORM_TVOS PLATFORM_UNIVERSAL_WINDOWS PLATFORM_WIN32
    ARCHIVER_SUPPORTED D3D11_SUPPORTED D3D12_SUPPORTED GLES_SUPPORTED GL_SUPPORTED METAL_SUPPORTED VULKAN_SUPPORTED WEBGPU_SUPPORTED
)
message(STATUS "Writing into ${CMAKE_BINARY_DIR}/variables.txt")
file(WRITE "${CMAKE_BINARY_DIR}/variables.txt" "")
foreach(var IN LISTS vars)
    if(var IN_LIST TARGET_VARS)
        file(APPEND "${CMAKE_BINARY_DIR}/variables.txt" "${var}=${${var}}\n")
    endif()
endforeach()]])

        local configs = {"-DDILIGENT_INSTALL_CORE=ON"}

        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))

        if package:is_debug() then
            table.insert(configs, "-DDILIGENT_INSTALL_PDB=ON")
            table.insert(configs, "-DDILIGENT_DEVELOPMENT=ON")
        end

        table.insert(configs, "-DDILIGENT_NO_OPENGL=" .. (package:config("opengl") and "OFF" or "ON"))

        table.insert(configs, "-DDILIGENT_NO_DIRECT3D11=" .. (package:config("d3d11") and "OFF" or "ON"))
        table.insert(configs, "-DDILIGENT_NO_DIRECT3D12=" .. (package:config("d3d12") and "OFF" or "ON"))

        table.insert(configs, "-DDILIGENT_NO_METAL=" .. (package:config("metal") and "OFF" or "ON"))
        table.insert(configs, "-DDILIGENT_NO_VULKAN=" .. (package:config("vulkan") and "OFF" or "ON"))

        table.insert(configs, "-DDILIGENT_NO_ARCHIVER=" .. (package:config("archiver") and "OFF" or "ON"))
        table.insert(configs, "-DDILIGENT_NO_HLSL=" .. (package:config("hlsl") and "OFF" or "ON"))
        table.insert(configs, "-DDILIGENT_NO_FORMAT_VALIDATION=" .. (package:config("format_validation") and "OFF" or "ON"))

        import("package.tools.cmake").install(package, configs) --, {packagedeps = {"glslang", "spirv-cross"}}

        -- Gather missing defines
        local vars_file = path.join(package:buildir(), "variables.txt")
        if os.isfile(vars_file) then
            local content = io.readfile(vars_file)
            for _, line in ipairs(content:split("\n")) do
                line = line:trim()
                if #line > 0 then
                    local var, value = line:match("^([^=]+)=(.+)$")
                    if var and value == "TRUE" then
                        package:data_set(var, true)
                    else
                        package:data_set(var, false)
                    end
                    package:add("defines", var .. "=" .. value)
                end
            end
        end
        -- Move folders into prepended folder DiligentCore
        local target_dir = path.join(package:installdir("include"), "DiligentCore")
        os.mkdir(target_dir)
        for _, dir in ipairs(os.dirs(package:installdir("include/*"))) do
            if dir ~= target_dir then
                os.mv(dir, target_dir)
            end
        end
    end)

    on_test(function (package)
        if package:config("opengl") and (package:data("GL_SUPPORTED") or package:data("GLES_SUPPORTED")) then
            assert(package:check_cxxsnippets({test = [[
                #include <DiligentCore/Graphics/GraphicsEngineOpenGL/interface/EngineFactoryOpenGL.h>
                void test() {
                    Diligent::EngineGLCreateInfo create_info;
                    Diligent::IEngineFactoryOpenGL* factory = nullptr;
                    Diligent::SwapChainDesc scd;
                    factory->CreateDeviceAndSwapChainGL(create_info, nullptr, nullptr, scd, nullptr);
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("d3d11") and package:data("D3D11_SUPPORTED") then
            assert(package:check_cxxsnippets({test = [[
                #include <DiligentCore/Graphics/GraphicsEngineD3D11/interface/EngineFactoryD3D11.h>
                void test() {
                    Diligent::EngineD3D11CreateInfo create_info;
                    Diligent::IEngineFactoryD3D11* factory = nullptr;
                    factory->CreateDeviceAndContextsD3D11(create_info, nullptr, nullptr);
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("d3d12") and package:data("D3D12_SUPPORTED") then
            assert(package:check_cxxsnippets({test = [[
                #include <DiligentCore/Graphics/GraphicsEngineD3D12/interface/EngineFactoryD3D12.h>
                void test() {
                    Diligent::EngineD3D12CreateInfo create_info;
                    Diligent::IEngineFactoryD3D12* factory = nullptr;
                    factory->CreateDeviceAndContextsD3D12(create_info, nullptr, nullptr);
                }
            ]]}, {configs = {languages = "c++17"}}))
        end

        if package:config("metal") and package:data("METAL_SUPPORTED") then
            assert(package:check_cxxsnippets({test = [[
                #include <DiligentCore/Graphics/GraphicsEngineMetal/interface/EngineFactoryMetal.h>
                void test() {
                    Diligent::EngineMetalCreateInfo create_info;
                    Diligent::IEngineFactoryMtl* factory = nullptr;
                    factory->CreateDeviceAndContextsMtl(create_info, nullptr, nullptr);
                }
            ]]}, {configs = {languages = "c++17"}}))
        end
    end)
