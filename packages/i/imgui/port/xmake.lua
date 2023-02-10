add_rules("mode.debug", "mode.release")
set_languages("cxx11")

option("wchar32",      {showmenu = true,  default = false})
option("freetype",     {showmenu = true,  default = false})
option("glfw_opengl3", {showmenu = true,  default = false})
option("glfw_vulkan",  {showmenu = true,  default = false})
option("sdl2",         {showmenu = true,  default = false})
option("sdl2_opengl3", {showmenu = true,  default = false})
option("user_config",  {showmenu = true,  default = nil, type = "string"})
option("use_glad",     {showmenu = true,  default = false})

-- Renderer backends
local has_opengl3 = has_config("glfw_opengl3") or has_config("sdl2_opengl3")
local has_vulkan = has_config("glfw_vulkan")
local has_sdl_renderer = has_config("sdl2")

-- Platform backends
local has_glfw = has_config("glfw_opengl3") or has_config("glfw_vulkan")
local has_sdl2 = has_config("sdl2") or has_config("sdl2_opengl3")

if has_config("freetype") then
    add_requires("freetype")
end

if has_opengl3 and has_config("use_glad") then
    add_requires("glad")
end

if has_vulkan then
    add_requires("vulkansdk")
end

if has_glfw then
    add_requires("glfw")
end

if has_sdl2 then
    add_requires("libsdl >=2.0.17")
end

target("imgui")
    set_kind("static")
    add_files("*.cpp")
    add_headerfiles("*.h")
    add_includedirs(".")

    if has_config("wchar32") then
        add_defines("IMGUI_USE_WCHAR32")
    end

    if has_config("freetype") then
        add_headerfiles("misc/freetype/imgui_freetype.h")
        add_files("misc/freetype/imgui_freetype.cpp")
        add_packages("freetype")
        add_defines("IMGUI_ENABLE_FREETYPE")
    end

    if has_opengl3 then
        add_files("backends/imgui_impl_opengl3.cpp")
        add_headerfiles("(backends/imgui_impl_opengl3.h)")
        if has_config("use_glad") then
            add_defines("IMGUI_IMPL_OPENGL_LOADER_GLAD")
            add_packages("glad")
        else
            add_headerfiles("(backends/imgui_impl_opengl3_loader.h)")
        end
    end

    if has_vulkan then
        add_files("backends/imgui_impl_vulkan.cpp")
        add_headerfiles("(backends/imgui_impl_vulkan.h)")
        add_packages("vulkansdk")
    end

    if has_sdl_renderer then
        add_files("backends/imgui_impl_sdlrenderer.cpp")
        add_headerfiles("(backends/imgui_impl_sdlrenderer.h)")
    end

    if has_glfw then
        add_files("backends/imgui_impl_glfw.cpp")
        add_headerfiles("(backends/imgui_impl_glfw.h)")
        add_packages("glfw")
    end

    if has_sdl2 then
        add_files("backends/imgui_impl_sdl.cpp")
        add_headerfiles("(backends/imgui_impl_sdl.h)")
        add_packages("libsdl")
    end

    if has_config("user_config") then
        local user_config = get_config("user_config")
        add_defines("IMGUI_USER_CONFIG=\"".. user_config .."\"")
    end

    -- Modify imconfig.
    after_install(function (target)
        local config_file = path.join(target:installdir(), "include/imconfig.h")
        if has_config("wchar32") then
            io.gsub(config_file, "//#define IMGUI_USE_WCHAR32", "#define IMGUI_USE_WCHAR32")
        end
        if has_config("freetype") then
            io.gsub(config_file, "//#define IMGUI_ENABLE_FREETYPE", "#define IMGUI_ENABLE_FREETYPE")
        end
    end)
