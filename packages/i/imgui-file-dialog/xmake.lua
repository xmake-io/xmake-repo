package("imgui-file-dialog")
    set_homepage("https://github.com/aiekick/ImGuiFileDialog")
    set_description("File Dialog for Dear ImGui")
    set_license("MIT")

    add_urls("https://github.com/aiekick/ImGuiFileDialog/archive/refs/tags/$(version).tar.gz",
             "https://github.com/aiekick/ImGuiFileDialog.git")

    add_versions("v0.6.7", "136e714965afaec2bac857bf46a653fdd74a0bf493e281682706c604113026b8")
    add_versions("v0.6.6", "75420f6eaf74fb1fa22042713f573858d8549366e7741baaf91128eb065b4b47")
    add_versions("v0.6.5", "3fac0f2cfc92b3f2c806e6743236467d0f691e54b1747a3955b82ef28b13e2fa")

    if is_plat("mingw") then
        add_configs("shared", {description = "Build shared binaries.", default = false, type = "boolean", readonly = true})
    end

    add_deps("imgui")
    if is_plat("windows") then
        add_deps("dirent")
    end

    on_install("windows", "linux", "macosx", "mingw", "android", function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_requires("imgui")
            if is_plat("windows") then
                add_requires("dirent")
                add_packages("dirent")
            end
            add_rules("mode.debug", "mode.release")
            target("imgui-file-dialog")
                set_kind("$(kind)")
                set_languages("c++11")
                add_files("ImGuiFileDialog.cpp")
                add_headerfiles("ImGuiFileDialog.h", "ImGuiFileDialogConfig.h")
                add_packages("imgui")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ImGuiFileDialog.h>
            void test() {
                ImGuiFileDialog::Instance()->Close();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
