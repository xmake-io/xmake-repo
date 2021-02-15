package("imgui")

    set_homepage("https://github.com/ocornut/imgui")
    set_description("Bloat-free Immediate Mode Graphical User interface for C++ with minimal dependencies")

    add_urls("https://github.com/ocornut/imgui/archive/$(version).tar.gz",
             "https://github.com/ocornut/imgui.git")

    add_versions("v1.81", "f7c619e03a06c0f25e8f47262dbc32d61fd033d2c91796812bf0f8c94fca78fb")
    add_versions("v1.80", "d7e4e1c7233409018437a646680316040e6977b9a635c02da93d172baad94ce9")
    add_versions("v1.79", "f1908501f6dc6db8a4d572c29259847f6f882684b10488d3a8d2da31744cd0a4")
    add_versions("v1.75", "1023227fae4cf9c8032f56afcaea8902e9bfaad6d9094d6e48fb8f3903c7b866")

    on_install("macosx", "linux", "windows", "mingw", "android", "iphoneos", function (package)
        io.writefile("xmake.lua", [[
            target("imgui")
                set_kind("static")
                add_files("*.cpp")
                add_headerfiles("imgui.h", "imconfig.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
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
