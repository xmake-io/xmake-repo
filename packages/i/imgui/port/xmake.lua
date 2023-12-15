add_rules("mode.debug", "mode.release")
set_languages("cxx11")

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
option("vulkan",           {showmenu = true,  default = false})
option("win32",            {showmenu = true,  default = false})
option("wgpu",             {showmenu = true,  default = false})
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
    add_requires("libsdl >=2.0.17")
elseif has_config("sdl2") then
    add_requires("libsdl")
end

if has_config("vulkan") then
    add_requires("vulkansdk")
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
        add_packages("libsdl")
    end

    if has_config("sdl2_renderer") then
        if os.exists("backends/imgui_impl_sdlrenderer2.cpp") then
            add_files("backends/imgui_impl_sdlrenderer2.cpp")
            add_headerfiles("(backends/imgui_impl_sdlrenderer2.h)")
        else
            add_files("backends/imgui_impl_sdlrenderer.cpp")
            add_headerfiles("(backends/imgui_impl_sdlrenderer.h)")
        end
        add_packages("libsdl")
    end

    if has_config("vulkan") then
        add_files("backends/imgui_impl_vulkan.cpp")
        add_headerfiles("(backends/imgui_impl_vulkan.h)")
        add_packages("vulkansdk")
    end

    if has_config("win32") then
        add_files("backends/imgui_impl_win32.cpp")
        add_headerfiles("(backends/imgui_impl_win32.h)")
    end
    
    if has_config("wgpu") then
        add_files("backends/imgui_impl_wgpu.cpp")
        add_headerfiles("(backends/imgui_impl_wgpu.h)")
        add_packages("wgpu-native")
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
