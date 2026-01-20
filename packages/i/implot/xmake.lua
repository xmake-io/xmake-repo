package("implot")
    set_homepage("https://github.com/epezent/implot")
    set_description("Immediate Mode Plotting")
    set_license("MIT")

    add_urls("https://github.com/epezent/implot/archive/refs/tags/$(version).tar.gz",
             "https://github.com/epezent/implot.git")

    add_versions("v0.17", "0aa3ff4fb97e553608e6758e77980eedf01745628fe6c025e647f941ae674127")
    add_versions("v0.16", "961df327d8a756304d1b0a67316eebdb1111d13d559f0d3415114ec0eb30abd1")
    add_versions("v0.15", "3df87e67a1e28db86828059363d78972a298cd403ba1f5780c1040e03dfa2672")

    on_load(function (package)
        local imgui_version
        local version = package:version()
        if version and version:lt("0.17") then
            imgui_version = "<=1.91"
        end
        package:add("deps", "imgui", {version = imgui_version})
    end)

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            add_requires("imgui")
            target("implot")
                set_kind("$(kind)")
                set_languages("c++11")
                add_files("*.cpp|implot_demo.cpp")
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
            #include <implot.h>
            void test() {
                ImPlot::CreateContext();
                ImPlot::DestroyContext();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
