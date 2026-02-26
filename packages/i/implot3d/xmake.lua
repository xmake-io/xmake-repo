package("implot3d")
    set_homepage("https://github.com/brenocq/implot3d")
    set_description("Immediate Mode 3D Plotting")
    set_license("MIT")

    add_urls("https://github.com/brenocq/implot3d/archive/refs/tags/$(version).tar.gz",
             "https://github.com/brenocq/implot3d.git")

    add_versions("v0.3", "8f0012043ea4ea56cb5ca9fc44731ad005637f0d3515a5ed3bead27f3096fb55")
    add_versions("v0.2", "9b526ce01a9e9028e7d516b0699eee3c3b19d91d2dd6b546985e6a4b0bf700d4")

    add_deps("imgui")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_requires("imgui")
            add_rules("mode.release", "mode.debug")
            target("implot3d")
                set_kind("$(kind)")
                set_languages("c++11")
                add_files("*.cpp|implot3d_demo.cpp")
                add_headerfiles("*.h")
                add_packages("imgui")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                ImPlot3D::CreateContext();
                ImPlot3D::DestroyContext();
            }
        ]]}, {configs = {languages = "c++11"}, includes = "implot3d.h"}))
    end)
