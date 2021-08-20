package("imgui")

    set_homepage("https://github.com/ocornut/imgui")
    set_description("Bloat-free Immediate Mode Graphical User interface for C++ with minimal dependencies")

    add_urls("https://github.com/ocornut/imgui/archive/$(version).tar.gz",
             "https://github.com/ocornut/imgui.git")

    add_versions("v1.83-docking", "80b5fb51edba2fd3dea76ec3e88153e2492243d1")
    add_versions("v1.83", "ccf3e54b8d1fa30dd35682fc4f50f5d2fe340b8e29e08de71287d0452d8cc3ff")
    add_versions("v1.82", "fefa2804bd55f3d25b134af08c0e1f86d4d059ac94cef3ee7bd21e2f194e5ce5")
    add_versions("v1.81", "f7c619e03a06c0f25e8f47262dbc32d61fd033d2c91796812bf0f8c94fca78fb")
    add_versions("v1.80", "d7e4e1c7233409018437a646680316040e6977b9a635c02da93d172baad94ce9")
    add_versions("v1.79", "f1908501f6dc6db8a4d572c29259847f6f882684b10488d3a8d2da31744cd0a4")
    add_versions("v1.75", "1023227fae4cf9c8032f56afcaea8902e9bfaad6d9094d6e48fb8f3903c7b866")
    
    add_configs("user_config", {description = "Use user config (disables test!)", default = nil, type = "string"})
    add_configs("glfw_opengl3", {description = "Use glfw+opengl3 as backend", default = false, type = "boolean"})

    add_includedirs("include", "include/imgui")

    if is_plat("windows", "mingw") then
        add_syslinks("Imm32")
    end

    on_load("macosx", "linux", "windows", "mingw", "android", "iphoneos", function (package)
        if package:config("glfw_opengl3") then
            package:add("deps", "glad")
            package:add("deps", "glfw")
            package:add("defines", "IMGUI_IMPL_OPENGL_LOADER_GLAD")
        end
        if string.find(package:version_str(), "-docking") ~= nil then
            package:set("urls", {"https://github.com/ocornut/imgui.git"})
        end
    end)

    on_install("macosx", "linux", "windows", "mingw", "android", "iphoneos", function (package)
        local xmake_lua
        if package:config("glfw_opengl3") then
            xmake_lua = [[
                add_rules("mode.debug", "mode.release")
                add_requires("glfw", "glad")
                target("imgui")
                    set_kind("static")
                    add_files("*.cpp", "backends/imgui_impl_glfw.cpp", "backends/imgui_impl_opengl3.cpp")
                    add_defines("IMGUI_IMPL_OPENGL_LOADER_GLAD")
                    add_packages("glfw", "glad")
                    add_includedirs(".")
                    add_headerfiles("*.h", {prefixdir = "imgui"})
                    add_headerfiles("backends/imgui_impl_glfw.h", "backends/imgui_impl_opengl3.h")
            ]]
        else
            xmake_lua = [[
                add_rules("mode.debug", "mode.release")
                target("imgui")
                    set_kind("static")
                    add_files("*.cpp")
                    add_headerfiles("imgui.h", "imconfig.h")
            ]]
        end
        
        local user_config = package:config("user_config")
        if user_config ~= nil then
            if is_host("windows") then
                user_config = user_config:gsub("\\", "\\\\")
            end
            xmake_lua = xmake_lua .. "add_defines(\"IMGUI_USER_CONFIG=\\\"" .. user_config .. "\\\"\")"
        end

        io.writefile("xmake.lua", xmake_lua)
        import("package.tools.xmake").install(package)
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