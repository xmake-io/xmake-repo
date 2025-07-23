package("imgui-filebrowser")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/AirGuanZ/imgui-filebrowser")
    set_description("File browser implementation for dear-imgui. C++17 is required.")
    set_license("MIT")

    add_urls("https://github.com/AirGuanZ/imgui-filebrowser.git")

    add_versions("2024.10.07", "60d4e09ab1270d94d0115ad8ec40f939e801e105")

    add_deps("imgui")

    on_install("macosx", "linux", "windows", "mingw", "android", "iphoneos", function (package)
        os.cp("imfilebrowser.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <imgui.h>
            #include <imfilebrowser.h>
            void test() {
                ImGui::FileBrowser fileDialog;
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
