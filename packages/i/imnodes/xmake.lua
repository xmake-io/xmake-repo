package("imnodes")
    set_homepage("https://github.com/Nelarius/imnodes")
    set_description("A small, dependency-free node editor for dear imgui")
    set_license("MIT")

    add_urls("https://github.com/Nelarius/imnodes/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Nelarius/imnodes.git")

    add_versions("v0.5", "c19a1d8e3fabf71def02b98c43a3f4551f0a5bd3740a93474a356e8957ec2ab2")

    add_deps("imgui")

    on_install("windows", "linux", "macosx", "mingw", "android", "iphoneos", function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_requires("imgui")
            add_rules("mode.release", "mode.debug")
            target("imnodes")
                set_kind("$(kind)")
                add_files("imnodes.cpp")
                add_headerfiles("imnodes.h", "imnodes_internal.h")
                add_defines("IMGUI_DEFINE_MATH_OPERATORS")
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
            #include <imnodes.h>
            void test() {
                ImNodes::CreateContext();
                ImNodes::DestroyContext();
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
