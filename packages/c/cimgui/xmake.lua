package("cimgui")
    set_homepage("https://github.com/cimgui/cimgui")
    set_description("c-api for imgui (https://github.com/ocornut/imgui) Look at: https://github.com/cimgui for other widgets")
    set_license("MIT")

    add_urls("https://github.com/cimgui/cimgui.git")
    add_versions("2023.08.02", "a21e28e74027796d983f8c8d4a639a4e304251f2")

    add_configs("imgui", {description = "imgui version", default = "v1.89", type = "string"})
    add_configs("target", {description = "options as words in one string: internal for imgui_internal generation, freetype for freetype generation, comments for comments generation, nochar to skip char* function version, noimstrv to skip imstrv", default = "internal noimstrv", type = "string"})

    add_configs("glfw",             {description = "Enable the glfw backend", default = false, type = "boolean"})
    add_configs("opengl2",          {description = "Enable the opengl2 backend", default = false, type = "boolean"})
    add_configs("opengl3",          {description = "Enable the opengl3 backend", default = false, type = "boolean"})
    add_configs("sdl2",             {description = "Enable the sdl2 backend", default = false, type = "boolean"})
    add_configs("vulkan",           {description = "Enable the vulkan backend", default = false, type = "boolean"})
    add_configs("freetype",         {description = "Use FreeType to build and rasterize the font atlas", default = false, type = "boolean"})
    add_configs("wchar32",          {description = "Use 32-bit for ImWchar (default is 16-bit)", default = false, type = "boolean"})

    if is_plat("windows") then
        add_syslinks("imm32")
    end

    add_defines("IMGUI_DISABLE_OBSOLETE_FUNCTIONS=1")

    add_deps("luajit", {private = true})

    on_check(function (package)
        if package:is_arch("arm.*") then
            raise("package(cimgui/arm64): unsupported arch, because it depends on luajit, we need to improve luajit first.")
        end
    end)

    on_load(function (package)
        if package:config("sdl2") then
            package:add("deps", "libsdl2")
            package:add("defines", "CIMGUI_USE_SDL2")
        end
        if package:config("opengl2") then
            package:add("defines", "CIMGUI_USE_OPENGL2")
        end
        if package:config("opengl3") then
            package:add("defines", "CIMGUI_USE_OPENGL3")
        end
        if package:config("glfw") then
            package:add("deps", "glfw")
            package:add("defines", "CIMGUI_USE_GLFW")
        end
        if package:config("vulkan") then
            package:add("deps", "vulkansdk")
        end
        if package:config("freetype") then
            package:add("deps", "freetype")
            package:add("defines", "CIMGUI_FREETYPE=1")
        end
    end)

    on_install("windows|x64", "windows|x86", "linux", "macosx", function (package)
        os.vrun("git -c core.fsmonitor=false submodule foreach --recursive git checkout " .. package:config("imgui"))

        local envs = {}
        local args = {"generator.lua"}

        if package:is_plat("windows") then
            import("package.tools.msbuild")

            table.insert(args, "cl")
            table.join2(envs, msbuild.buildenvs(package))
        else
            if package:has_tool("cc", "gcc", "gxx") then
                table.insert(args, "gcc")
            elseif package:has_tool("cc", "clang", "clangxx") then
                table.insert(args, "clang")
            else
                raise("Compiler not found")
            end
        end

        table.insert(args, package:config("target"))

        table.join2(args, table.wrap(package:config("cflags")))
        table.join2(args, table.wrap(package:config("cxflags")))
        for _, define in ipairs(table.wrap(package:config("defines"))) do
            table.insert(args, "-D" .. define)
        end

        local configs = {
            glfw     = package:config("glfw"),
            opengl2  = package:config("opengl2"),
            opengl3  = package:config("opengl3"),
            sdl2     = package:config("sdl2"),
            vulkan   = package:config("vulkan"),
            freetype = package:config("freetype"),
            wchar32  = package:config("wchar32")
        }

        if configs.sdl2 then
            table.insert(args, "sdl")
        end
        if configs.glfw then
            table.insert(args, "glfw")
        end
        if configs.vulkan then
            table.insert(args, "vulkan")
        end
        if configs.opengl2 then
            table.insert(args, "opengl2")
        end
        if configs.opengl3 then
            table.insert(args, "opengl3")
        end

        os.vrunv("luajit", args, {envs = envs, curdir = "generator"})

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #define CIMGUI_DEFINE_ENUMS_AND_STRUCTS
            #include <cimgui.h>
            void test() {
                igCreateContext(NULL);
            }
        ]]}, {configs = {languages = "c99"}}))
    end)
