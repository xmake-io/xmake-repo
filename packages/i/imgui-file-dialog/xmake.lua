package("imgui-file-dialog")
    set_homepage("https://github.com/aiekick/ImGuiFileDialog")
    set_description("File Dialog for Dear ImGui")
    set_license("MIT")

    add_urls("https://github.com/aiekick/ImGuiFileDialog/archive/refs/tags/$(version).tar.gz",
             "https://github.com/aiekick/ImGuiFileDialog.git")

    add_versions("v0.6.5", "3fac0f2cfc92b3f2c806e6743236467d0f691e54b1747a3955b82ef28b13e2fa")

    add_deps("imgui", "dirent")

    on_install("windows", function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_requires("imgui", "dirent")
            add_rules("mode.debug", "mode.release")
            target("imgui-file-dialog")
                set_kind("$(kind)")
                add_files("ImGuiFileDialog.cpp")
                add_headerfiles("ImGuiFileDialog.h", "ImGuiFileDialogConfig.h")
                add_packages("imgui", "dirent")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ImGuiFileDialog.h>
            void test() {
                ImGuiFileDialog::Instance()->OpenDialog("ChooseFileDlgKey", "Choose File", ".cpp,.h,.hpp", ".");
            }
        ]]}))
    end)
