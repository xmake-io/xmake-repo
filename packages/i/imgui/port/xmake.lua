add_rules("mode.debug", "mode.release")
set_languages("cxx11")

option("wchar32",      {showmenu = true,  default = false})
option("freetype",     {showmenu = true,  default = false})
option("glfw_opengl3", {showmenu = true,  default = false})
option("glfw_vulkan",  {showmenu = true,  default = false})
option("user_config",  {showmenu = true,  default = nil, type = "string"})
option("use_glad",     {showmenu = true,  default = false})

if has_config("freetype") then 
    add_requires("freetype")
end

if has_config("glfw_opengl3") then
    add_requires("glfw")
    if has_config("use_glad") then
        add_requires("glad")
    end
elseif has_config("glfw_vulkan") then
    add_requires("glfw")
    add_requires("vulkansdk")
    add_requires("vulkan-headers")
end

target("imgui")
    set_kind("static")
    add_files("*.cpp")
    add_headerfiles("*.h")
    add_includedirs(".")

    if has_config("wchar32") then
        add_headerfiles("misc/freetype/imgui_freetype.h")
        add_files("misc/freetype/imgui_freetype.cpp")
        add_defines("IMGUI_USE_WCHAR32")
    end

    if has_config("freetype") then
        add_headerfiles("misc/freetype/imgui_freetype.h")
        add_files("misc/freetype/imgui_freetype.cpp")
        add_packages("freetype")
        add_defines("IMGUI_ENABLE_FREETYPE")
    end

    if has_config("glfw_opengl3") then
        add_files("backends/imgui_impl_glfw.cpp", "backends/imgui_impl_opengl3.cpp")
        add_headerfiles("backends/imgui_impl_glfw.h", "backends/imgui_impl_opengl3.h")
        add_packages("glfw")
        if has_config("use_glad") then
            add_defines("IMGUI_IMPL_OPENGL_LOADER_GLAD")
            add_packages("glad")
        else
            add_headerfiles("backends/imgui_impl_opengl3_loader.h")
        end
    elseif has_config("glfw_vulkan") then
        add_files("backends/imgui_impl_vulkan.cpp", "backends/imgui_impl_glfw.cpp")
        add_headerfiles("backends/imgui_impl_vulkan.h", "backends/imgui_impl_glfw.h")
        add_packages("glfw")
        add_packages("vulkan-headers")
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
