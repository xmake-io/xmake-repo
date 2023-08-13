package("im3d")
    set_homepage("https://github.com/john-chapman/im3d")
    set_description("File Dialog for Dear ImGui")
    set_license("MIT")

    add_urls("https://github.com/john-chapman/im3d.git")

    add_versions("2023.06.09", "d03941725fd0bd08c78c46e3e5b0265526e9d060")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("im3d")
                set_kind("$(kind)")
                set_languages("c++11")
                add_files("im3d.cpp")
                add_headerfiles("im3d.h", "im3d_config.h", "im3d_math.h")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <im3d.h>
            void test() {
                Im3d::PushDrawState();
                Im3d::SetSize(2.0f);
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
