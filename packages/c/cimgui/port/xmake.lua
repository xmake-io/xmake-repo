add_rules("mode.debug", "mode.release")
set_languages("cxx11")

option("glfw",             {showmenu = true,  default = false})
option("opengl2",          {showmenu = true,  default = false})
option("opengl3",          {showmenu = true,  default = false})
option("sdl2",             {showmenu = true,  default = false})
option("vulkan",           {showmenu = true,  default = false})
option("freetype",         {showmenu = true,  default = false})
option("wchar32",          {showmenu = true,  default = false})

if has_config("glfw") then
    add_requires("glfw")
end

if has_config("sdl2") then
    add_requires("libsdl2")
end

if has_config("vulkan") then
    add_requires("vulkansdk")
end

if has_config("freetype") then
    add_requires("freetype")
end

target("cimgui")
    set_kind("$(kind)")
    add_files("cimgui.cpp", "imgui/*.cpp")
    add_includedirs("imgui")
    add_headerfiles("cimgui.h", "generator/output/cimgui_impl.h")

    add_defines("IMGUI_DISABLE_OBSOLETE_FUNCTIONS=1")
    if is_kind("static") then
        add_defines("IMGUI_IMPL_API=extern \"C\" ")
    else
        add_defines("IMGUI_IMPL_API=extern \"C\" __declspec(dllexport)")
    end

    if has_config("glfw") then
        add_files("imgui/backends/imgui_impl_glfw.cpp")
        add_headerfiles("imgui/(backends/imgui_impl_glfw.h)")
        add_packages("glfw")
    end

    if has_config("opengl2") then
        add_files("imgui/backends/imgui_impl_opengl2.cpp")
        add_headerfiles("imgui/(backends/imgui_impl_opengl2.h)")
    end

    if has_config("opengl3") then
        add_files("imgui/backends/imgui_impl_opengl3.cpp")
        add_headerfiles("imgui/(backends/imgui_impl_opengl3.h)")
        add_headerfiles("imgui/(backends/imgui_impl_opengl3_loader.h)")
    end

    if has_config("sdl2") then
        if os.exists("imgui/backends/imgui_impl_sdl2.cpp") then
            add_files("imgui/backends/imgui_impl_sdl2.cpp")
            add_headerfiles("imgui/(backends/imgui_impl_sdl2.h)")
        else
            add_files("imgui/backends/imgui_impl_sdl.cpp")
            add_headerfiles("imgui/(backends/imgui_impl_sdl.h)")
        end
        add_packages("libsdl2")
    end

    if has_config("vulkan") then
        add_files("imgui/backends/imgui_impl_vulkan.cpp")
        add_headerfiles("imgui/(backends/imgui_impl_vulkan.h)")
        add_packages("vulkansdk")
    end

    if has_config("freetype") then
        add_files("imgui/misc/freetype/imgui_freetype.cpp")
        add_headerfiles("imgui/misc/freetype/imgui_freetype.h")
        add_packages("freetype")
        add_defines("IMGUI_ENABLE_FREETYPE")
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
