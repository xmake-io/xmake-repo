package("diligentcore")
    set_homepage("http://diligentgraphics.com/diligent-engine/")
    set_description("A modern cross-platform low-level graphics API")
    set_license("Apache-2.0")

    add_urls("https://github.com/DiligentGraphics/DiligentCore/archive/refs/tags/$(version).tar.gz",
             "https://github.com/DiligentGraphics/DiligentCore.git", {submodules = false})

    add_versions("v2.5.6", "abc190c05ee7e5ef2bba52fcbc5fdfe2256cce3435efba9cfe263a386653f671")

    add_patches("v2.5.6", "patches/v2.5.6/debundle-thirdparty.diff", "3d276a78e9ae47516668229dcb644f328a3602d389a3d73784eeb52d8a53108d")
    add_patches("v2.5.6", "patches/v2.5.6/enforce-static-lib-type-for-platform-libraries.diff", "ee88a2a04348dcc9de7960a87ff5dc1fb1b534caf1f6224bb2d0c88d37a4bc53")
    add_patches("v2.5.6", "patches/v2.5.6/fix-build-deps-pkgconf.diff", "9998204546cf551a48301e972b582eeeaf002607a4f474086d7d80f4762451ee")
    add_patches("v2.5.6", "patches/v2.5.6/fix-install-path.diff", "6be244cb16df0a5d84ae4fe97ebecd0cf0f2058f8fded78f5c0a28d84510afc9")
    add_patches("v2.5.6", "patches/v2.5.6/fix-spirv-cross-namespace.diff", "d5a866d4b5bce061a3597dcc026cb88c4b9f92af352ef4071750d355b8b924f0")

    add_includedirs("include", "include/DiligentCore")

    add_deps("pkgconf")

    if is_plat("windows", "linux", "mingw", "macosx") then
        add_configs("opengl",           {description = "Enable OpenGL/GLES backend", default = true, type = "boolean"})
    end

    if is_plat("windows") then
        add_configs("d3d11",            {description = "Enable Direct3D11 backend", default = true, type = "boolean"})
        add_configs("d3d12",            {description = "Enable Direct3D12 backend", default = true, type = "boolean"})
    end

    add_configs("vulkan",               {description = "Enable Vulkan backend", default = true, type = "boolean"})

    add_configs("hlsl",                 {description = "Enable HLSL", default = true, type = "boolean"})
    add_configs("glslang",              {description = "Enable GLSLang", default = true, type = "boolean"})
    add_configs("archiver",             {description = "Enable archiver", default = true, type = "boolean"})
    add_configs("format_validation",    {description = "Enable format validation", default = false, type = "boolean"})

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

    if is_plat("linux") then
        add_deps("libx11", "libxrandr", "libxrender", "libxinerama", "libxfixes", "libxcursor", "libxi", "libxext", "wayland")
    end

    on_load(function (package)
        if package:is_plat("windows") then
            package:add("defines", "NOMINMAX", "WIN32_LEAN_AND_MEAN", "UNICODE")
        end
        if package:config("shared") then
            package:add("defines", "ENGINE_DLL=1")
        end

        if package:config("opengl") then
            package:add("deps", "opengl", "glew")
            if package:is_plat("macosx") then
                package:add("frameworks", "OpenGL")
            end
        end

        if package:config("vulkan") then
            package:add("deps", "vulkan-headers")
            package:add("deps", "volk", {configs = {header_only = true}})
        end

        if package:config("vulkan") or (package:config("archiver") and package:config("opengl")) then
            package:add("deps", "spirv-headers")
        end

        if package:config("hlsl") or package:config("archiver") or package:config("glslang") then
            if package:is_plat("linux") then
                package:add("deps", "glslang", {configs = {shared = true}})
            else
                package:add("deps", "glslang")
            end
            package:add("deps", "spirv-tools")
        end

        package:add("deps", "spirv-cross")
    end)

    on_install("windows", "linux", "macosx", function (package)
        -- Do not enforce /GL
        io.replace("CMakeLists.txt", [[set(DEFAULT_DILIGENT_MSVC_RELEASE_COMPILE_OPTIONS /GL)]], [[]], {plain = true})
        -- Dump CMakeLists.txt variables related for platform & rendering backend for package defines
        local CMakeLists_content = io.readfile("CMakeLists.txt")
        io.writefile("CMakeLists.txt", CMakeLists_content .. [[
get_cmake_property(vars VARIABLES)
list(SORT vars)
set(TARGET_VARS
    PLATFORM_ANDROID PLATFORM_EMSCRIPTEN PLATFORM_IOS PLATFORM_LINUX PLATFORM_MACOS PLATFORM_TVOS PLATFORM_UNIVERSAL_WINDOWS PLATFORM_WIN32
    ARCHIVER_SUPPORTED D3D11_SUPPORTED D3D12_SUPPORTED GLES_SUPPORTED GL_SUPPORTED METAL_SUPPORTED VULKAN_SUPPORTED WEBGPU_SUPPORTED
)
file(WRITE "${CMAKE_BINARY_DIR}/variables.txt" "")
foreach(var IN LISTS vars)
    if(var IN_LIST TARGET_VARS)
        file(APPEND "${CMAKE_BINARY_DIR}/variables.txt" "${var}=${${var}}\n")
    endif()
endforeach()
]])

        local configs = {"-DDILIGENT_INSTALL_CORE=ON"}

        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))

        table.insert(configs, "-DDILIGENT_INSTALL_PDB=" .. (package:is_debug() and "ON" or "OFF"))
        table.insert(configs, "-DDILIGENT_DEVELOPMENT=" .. (package:is_debug() and "ON" or "OFF"))

        table.insert(configs, "-DDILIGENT_NO_OPENGL=" .. (package:config("opengl") and "OFF" or "ON"))

        table.insert(configs, "-DDILIGENT_NO_DIRECT3D11=" .. (package:config("d3d11") and "OFF" or "ON"))
        table.insert(configs, "-DDILIGENT_NO_DIRECT3D12=" .. (package:config("d3d12") and "OFF" or "ON"))

        table.insert(configs, "-DDILIGENT_NO_VULKAN=" .. (package:config("vulkan") and "OFF" or "ON"))

        table.insert(configs, "-DDILIGENT_NO_ARCHIVER=" .. (package:config("archiver") and "OFF" or "ON"))
        table.insert(configs, "-DDILIGENT_NO_HLSL=" .. (package:config("hlsl") and "OFF" or "ON"))
        table.insert(configs, "-DDILIGENT_NO_GLSLANG=" .. (package:config("glslang") and "OFF" or "ON"))
        table.insert(configs, "-DDILIGENT_NO_FORMAT_VALIDATION=" .. (package:config("format_validation") and "OFF" or "ON"))

        import("package.tools.cmake").install(package, configs)
        -- Gather missing defines into *data* so we could gather *data* for on_test
        local vars_file = path.join(package:buildir(), "variables.txt")
        if os.isfile(vars_file) then
            local content = io.readfile(vars_file)
            for _, line in ipairs(content:split("\n")) do
                line = line:trim()
                if #line > 0 then
                    local var, value = line:match("^([^=]+)=(.+)$")
                    if var and value == "TRUE" then
                        package:add("defines", var)
                    end
                end
            end
        end
        -- Move every folder of $(builddir)/include into prepended folder include/DiligentCore
        local target_dir = path.join(package:installdir("include"), "DiligentCore")
        os.mkdir(target_dir)
        for _, dir in ipairs(os.dirs(package:installdir("include/*"))) do
            if dir ~= target_dir then
                os.mv(dir, target_dir)
            end
        end
    end)

    on_test(function (package)
        if package:config("opengl") then
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
        if package:config("d3d11") then
            assert(package:check_cxxsnippets({test = [[
                #include <DiligentCore/Graphics/GraphicsEngineD3D11/interface/EngineFactoryD3D11.h>
                void test() {
                    Diligent::EngineD3D11CreateInfo create_info;
                    Diligent::IEngineFactoryD3D11* factory = nullptr;
                    factory->CreateDeviceAndContextsD3D11(create_info, nullptr, nullptr);
                }
            ]]}, {configs = {languages = "c++17"}}))
        end
        if package:config("d3d12") then
            assert(package:check_cxxsnippets({test = [[
                #include <DiligentCore/Graphics/GraphicsEngineD3D12/interface/EngineFactoryD3D12.h>
                void test() {
                    Diligent::EngineD3D12CreateInfo create_info;
                    Diligent::IEngineFactoryD3D12* factory = nullptr;
                    factory->CreateDeviceAndContextsD3D12(create_info, nullptr, nullptr);
                }
            ]]}, {configs = {languages = "c++17"}}))
        end
        if package:config("vulkan") then
            assert(package:check_cxxsnippets({test = [[
                #include <DiligentCore/Graphics/GraphicsEngineVulkan/interface/EngineFactoryVk.h>
                void test() {
                    Diligent::EngineVkCreateInfo create_info;
                    Diligent::IEngineFactoryVk* factory = nullptr;
                    factory->CreateDeviceAndContextsVk(create_info, nullptr, nullptr);
                }
            ]]}, {configs = {languages = "c++17"}}))
        end
    end)
