package("imgui")

    set_homepage("https://github.com/ocornut/imgui")
    set_description("Bloat-free Immediate Mode Graphical User interface for C++ with minimal dependencies")
    set_license("MIT")

    add_urls("https://github.com/ocornut/imgui/archive/$(version).tar.gz",
             "https://github.com/ocornut/imgui.git")
    add_versions("v1.89.3-docking", "192196711a7d0d7c2d60454d42654cf090498a74")
    add_versions("v1.89.3", "3b665fadd5580b7ef494d5d8bb1c12b2ec53ee723034caf43332956381f5d631")
    add_versions("v1.89-docking", "94e850fd6ff9eceb98fda3147e3ffd4781ad2dc7")
    add_versions("v1.89", "4038b05bd44c889cf40be999656d3871a0559916708cb52a6ae2fa6fa35c5c60")
    add_versions("v1.88-docking", "9cd9c2eff99877a3f10a7f9c2a3a5b9c15ea36c6")
    add_versions("v1.88", "9f14c788aee15b777051e48f868c5d4d959bd679fc5050e3d2a29de80d8fd32e")
    add_versions("v1.87-docking", "1ee252772ae9c0a971d06257bb5c89f628fa696a")
    add_versions("v1.87", "b54ceb35bda38766e36b87c25edf7a1cd8fd2cb8c485b245aedca6fb85645a20")
    add_versions("v1.86", "6ba6ae8425a19bc52c5e067702c48b70e4403cd339cba02073a462730a63e825")
    add_versions("v1.85-docking", "dc8c3618e8f8e2dada23daa1aa237626af341fd8")
    add_versions("v1.85", "7ed49d1f4573004fa725a70642aaddd3e06bb57fcfe1c1a49ac6574a3e895a77")
    add_versions("v1.84.2", "35cb5ca0fb42cb77604d4f908553f6ef3346ceec4fcd0189675bdfb764f62b9b")
    add_versions("v1.84.1", "292ab54cfc328c80d63a3315a242a4785d7c1cf7689fbb3d70da39b34db071ea")
    add_versions("v1.83-docking", "80b5fb51edba2fd3dea76ec3e88153e2492243d1")
    add_versions("v1.83", "ccf3e54b8d1fa30dd35682fc4f50f5d2fe340b8e29e08de71287d0452d8cc3ff")
    add_versions("v1.82", "fefa2804bd55f3d25b134af08c0e1f86d4d059ac94cef3ee7bd21e2f194e5ce5")
    add_versions("v1.81", "f7c619e03a06c0f25e8f47262dbc32d61fd033d2c91796812bf0f8c94fca78fb")
    add_versions("v1.80", "d7e4e1c7233409018437a646680316040e6977b9a635c02da93d172baad94ce9")
    add_versions("v1.79", "f1908501f6dc6db8a4d572c29259847f6f882684b10488d3a8d2da31744cd0a4")
    add_versions("v1.75", "1023227fae4cf9c8032f56afcaea8902e9bfaad6d9094d6e48fb8f3903c7b866")

    add_configs("dx9",         {description = "Enable the dx9 backend", default = false, type = "boolean"})
    add_configs("dx10",        {description = "Enable the dx10 backend", default = false, type = "boolean"})
    add_configs("dx11",        {description = "Enable the dx11 backend", default = false, type = "boolean"})
    add_configs("dx12",        {description = "Enable the dx12 backend", default = false, type = "boolean"})
    add_configs("glfw",        {description = "Enable the glfw backend", default = false, type = "boolean"})
    add_configs("opengl2",     {description = "Enable the opengl2 backend", default = false, type = "boolean"})
    add_configs("opengl3",     {description = "Enable the opengl3 backend", default = false, type = "boolean"})
    add_configs("sdl2",        {description = "Enable the sdl2 backend", default = false, type = "boolean"})
    add_configs("sdlrenderer", {description = "Enable the sdlrenderer backend", default = false, type = "boolean"})
    add_configs("vulkan",      {description = "Enable the vulkan backend", default = false, type = "boolean"})
    add_configs("win32",       {description = "Enable the win32 backend", default = false, type = "boolean"})
    add_configs("freetype",    {description = "Use FreeType to build and rasterize the font atlas", default = false, type = "boolean"})
    add_configs("user_config", {description = "Use user config (disables test!)", default = nil, type = "string"})
    add_configs("wchar32",     {description = "Use 32-bit for ImWchar (default is 16-bit)", default = false, type = "boolean"})

    -- deprecated configs (kept for backwards compatibility)
    add_configs("glfw_opengl3", {description = "(deprecated)", default = false, type = "boolean"})
    add_configs("glfw_vulkan",  {description = "(deprecated)", default = false, type = "boolean"})
    add_configs("sdl2_opengl3", {description = "(deprecated)", default = false, type = "boolean"})

    add_includedirs("include", "include/imgui", "include/backends")

    if is_plat("windows", "mingw") then
        add_syslinks("imm32")
    end

    on_load("macosx", "linux", "windows", "mingw", "android", "iphoneos", function (package)
        -- begin: backwards compatibility
        if package:config("glfw_opengl3") then
            package:config_set("glfw", true)
            package:config_set("opengl3", true)
        end
        if package:config("glfw_vulkan") then
            package:config_set("glfw", true)
            package:config_set("vulkan", true)
        end
        if package:config("sdl2_opengl3") then
            package:config_set("sdl2", true)
            package:config_set("opengl3", true)
        end
        -- end: backwards compatibility
        if package:config("glfw") then
            package:add("deps", "glfw")
        end
        if package:config("opengl3") then
            if not package:gitref() and package:version():lt("1.84") then
                package:add("deps", "glad")
                package:add("defines", "IMGUI_IMPL_OPENGL_LOADER_GLAD")
            end
        end
        if package:config("sdl2") then
            package:config_set("sdlrenderer", true) -- backwards compatibility
        end
        if package:config("sdlrenderer") then
            package:add("deps", "libsdl >=2.0.17")
        end
        if package:config("vulkan") then
            package:add("deps", "vulkansdk")
        end
        if package:config("freetype") then
            package:add("deps", "freetype")
        end
        if package:version_str():find("-docking", 1, true) then
            package:set("urls", {"https://github.com/ocornut/imgui.git"})
        end
    end)

    on_install("macosx", "linux", "windows", "mingw", "android", "iphoneos", function (package)
        local configs = {
            dx9         = package:config("dx9"),
            dx10        = package:config("dx10"),
            dx11        = package:config("dx11"),
            dx12        = package:config("dx12"),
            glfw        = package:config("glfw"),
            opengl2     = package:config("opengl2"),
            opengl3     = package:config("opengl3"),
            glad        = package:config("opengl3") and (not package:gitref() and package:version():lt("1.84")),
            sdl2        = package:config("sdl2"),
            sdlrenderer = package:config("sdlrenderer"),
            vulkan      = package:config("vulkan"),
            win32       = package:config("win32"),
            freetype    = package:config("freetype"),
            user_config = package:config("user_config"),
            wchar32     = package:config("wchar32")
        }

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        local user_config = package:config("user_config")
        assert(user_config ~= nil or package:check_cxxsnippets({test = [[
            void test() {
                IMGUI_CHECKVERSION();
                ImGui::CreateContext();
                ImGuiIO& io = ImGui::GetIO();
                ImGui::NewFrame();
                ImGui::Text("Hello, world!");
                ImGui::ShowDemoWindow(NULL);
                ImGui::Render();
                ImGui::DestroyContext();
            }
        ]]}, {configs = {languages = "c++11"}, includes = {"imgui.h"}}))
    end)
