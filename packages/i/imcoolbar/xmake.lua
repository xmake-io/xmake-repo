package("imcoolbar")
    set_homepage("https://github.com/aiekick/ImCoolBar")
    set_description("A Cool bar for Dear ImGui")
    set_license("MIT")

    add_urls("https://github.com/aiekick/ImCoolBar.git")
    add_versions("2023.07.05", "ab1f9c7e4325b89b485e1ce581a22533e0e7b8ad")

    add_deps("imgui docking")

    on_install("windows", "linux", "macosx", "mingw", "android", "iphoneos", function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_requires("imgui docking")
            add_rules("mode.release", "mode.debug")
            target("imcoolbar")
                set_kind("$(kind)")
                set_languages("c++11")
                add_files("ImCoolbar.cpp")
                add_headerfiles("ImCoolbar.h")
                add_packages("imgui")
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
            #include <ImCoolbar.h>
            void test() {
                ImGui ::CoolBarItem();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
