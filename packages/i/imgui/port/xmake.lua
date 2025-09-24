add_rules("mode.debug", "mode.release")
add_rules("utils.install.cmake_importfiles")
set_languages("cxx14")

option("dx9",              {showmenu = true,  default = false})
option("dx10",             {showmenu = true,  default = false})
option("dx11",             {showmenu = true,  default = false})
option("dx12",             {showmenu = true,  default = false})
option("glfw",             {showmenu = true,  default = false})
option("opengl2",          {showmenu = true,  default = false})
option("opengl3",          {showmenu = true,  default = false})
option("glad",             {showmenu = true,  default = false})
option("sdl2",             {showmenu = true,  default = false})
option("sdl2_renderer",    {showmenu = true,  default = false})
option("sdl3",             {showmenu = true,  default = false})
option("sdl3_renderer",    {showmenu = true,  default = false})
option("sdl3_gpu",         {showmenu = true,  default = false})
option("vulkan",           {showmenu = true,  default = false})
option("volk",             {showmenu = true,  default = false})
option("win32",            {showmenu = true,  default = false})
option("osx",              {showmenu = true,  default = false})
option("wgpu",             {showmenu = true,  default = false})
option("wgpu_backend",     {showmenu = true,  default = "wgpu", type = "string", values = {"wgpu", "dawn"}})
option("freetype",         {showmenu = true,  default = false})
option("user_config",      {showmenu = true,  default = nil, type = "string"})
option("wchar32",          {showmenu = true,  default = false})

if has_config("glfw") then
    add_requires("glfw")
end

if has_config("glad") then
    add_requires("glad")
end

if has_config("sdl2_renderer") then
    add_requires("libsdl2 >=2.0.17")
elseif has_config("sdl2") then
    add_requires("libsdl2")
end
if has_config("sdl3") or has_config("sdl3_renderer") or has_config("sdl3_gpu") then
    add_requires("libsdl3")
end

if has_config("vulkan") then
    add_requires("vulkan-headers")
end

if has_config("volk") then
    add_requires("volk")
end

if has_config("wgpu") then
    add_requires("wgpu-native")
end

if has_config("freetype") then
    add_requires("freetype")
end

target("imgui")
    set_kind("$(kind)")
    add_files("*.cpp", "misc/cpp/*.cpp")
    add_headerfiles("*.h", "(misc/cpp/*.h)")
    add_includedirs(".", "misc/cpp")

    if is_kind("shared") and is_plat("windows", "mingw") then
        add_defines("IMGUI_API=__declspec(dllexport)")
    end

    if has_config("dx9") then
        add_files("backends/imgui_impl_dx9.cpp")
        add_headerfiles("(backends/imgui_impl_dx9.h)")
    end

    if has_config("dx10") then
        add_files("backends/imgui_impl_dx10.cpp")
        add_headerfiles("(backends/imgui_impl_dx10.h)")
    end

    if has_config("dx11") then
        add_files("backends/imgui_impl_dx11.cpp")
        add_headerfiles("(backends/imgui_impl_dx11.h)")
    end

    if has_config("dx12") then
        add_files("backends/imgui_impl_dx12.cpp")
        add_headerfiles("(backends/imgui_impl_dx12.h)")
    end

    if has_config("glfw") then
        add_files("backends/imgui_impl_glfw.cpp")
        add_headerfiles("(backends/imgui_impl_glfw.h)")
        add_packages("glfw")
    end

    if has_config("opengl2") then
        add_files("backends/imgui_impl_opengl2.cpp")
        add_headerfiles("(backends/imgui_impl_opengl2.h)")
    end

    if has_config("opengl3") then
        add_files("backends/imgui_impl_opengl3.cpp")
        add_headerfiles("(backends/imgui_impl_opengl3.h)")
        if has_config("glad") then
            add_defines("IMGUI_IMPL_OPENGL_LOADER_GLAD")
            add_packages("glad")
        else
            add_headerfiles("(backends/imgui_impl_opengl3_loader.h)")
        end
    end

    if has_config("sdl2") then
        if os.exists("backends/imgui_impl_sdl2.cpp") then
            add_files("backends/imgui_impl_sdl2.cpp")
            add_headerfiles("(backends/imgui_impl_sdl2.h)")
        else
            add_files("backends/imgui_impl_sdl.cpp")
            add_headerfiles("(backends/imgui_impl_sdl.h)")
        end
        add_packages("libsdl2")
    end

    if has_config("sdl2_renderer") then
        if os.exists("backends/imgui_impl_sdlrenderer2.cpp") then
            add_files("backends/imgui_impl_sdlrenderer2.cpp")
            add_headerfiles("(backends/imgui_impl_sdlrenderer2.h)")
        else
            add_files("backends/imgui_impl_sdlrenderer.cpp")
            add_headerfiles("(backends/imgui_impl_sdlrenderer.h)")
        end
        add_packages("libsdl2")
    end

    if has_config("sdl3") then
        add_files("backends/imgui_impl_sdl3.cpp")
        add_headerfiles("(backends/imgui_impl_sdl3.h)")
        add_packages("libsdl3")
    end

    if has_config("sdl3_renderer") then
        add_files("backends/imgui_impl_sdlrenderer3.cpp")
        add_headerfiles("(backends/imgui_impl_sdlrenderer3.h)")
        add_packages("libsdl3")
    end

    if has_config("sdl3_gpu") then
        add_files("backends/imgui_impl_sdlgpu3.cpp")
        add_headerfiles("(backends/imgui_impl_sdlgpu3.h)", "(backends/imgui_impl_sdlgpu3_shaders.h)")
        add_packages("libsdl3")
    end

    if has_config("vulkan") then
        add_files("backends/imgui_impl_vulkan.cpp")
        add_headerfiles("(backends/imgui_impl_vulkan.h)")
        add_packages("vulkan-headers")
    end

    if has_config("volk") then
        add_files("backends/imgui_impl_vulkan.cpp")
        add_headerfiles("(backends/imgui_impl_vulkan.h)")
        add_packages("volk")
        add_defines("IMGUI_IMPL_VULKAN_USE_VOLK")
    end

    if has_config("win32") then
        add_files("backends/imgui_impl_win32.cpp")
        add_headerfiles("(backends/imgui_impl_win32.h)")
    end

    if has_config("osx") then
        add_frameworks("Cocoa", "Carbon", "GameController")
        add_files("backends/imgui_impl_osx.mm")
        add_headerfiles("(backends/imgui_impl_osx.h)")
    end

    if has_config("wgpu") then
        add_files("backends/imgui_impl_wgpu.cpp")
        add_headerfiles("(backends/imgui_impl_wgpu.h)")
        add_packages("wgpu-native")

        if has_config("wgpu_backend") then
            add_defines("IMGUI_IMPL_WEBGPU_BACKEND_" .. string.upper(get_config("wgpu_backend")))
        end
    end

    if has_config("freetype") then
        add_files("misc/freetype/imgui_freetype.cpp")
        add_headerfiles("misc/freetype/imgui_freetype.h")
        add_packages("freetype")
        add_defines("IMGUI_ENABLE_FREETYPE")
    end

    if has_config("user_config") then
        local user_config = get_config("user_config")
        add_defines("IMGUI_USER_CONFIG=\"".. user_config .."\"")
    end

    if has_config("wchar32") then
        add_defines("IMGUI_USE_WCHAR32")
    end

    after_install(function (target)
        local config_file = path.join(target:installdir(), "include/imconfig.h")
        if has_config("wchar32") then
            io.gsub(config_file, "//#define IMGUI_USE_WCHAR32", "#define IMGUI_USE_WCHAR32")
        end
        if has_config("freetype") then
            io.gsub(config_file, "//#define IMGUI_ENABLE_FREETYPE", "#define IMGUI_ENABLE_FREETYPE")
        end
    end)
