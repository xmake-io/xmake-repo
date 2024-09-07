package("polyclipping")
    set_homepage("https://sourceforge.net/projects/polyclipping")
    set_description("Polygon and line clipping and offsetting library")
    set_license("BSL-1.0")

    add_urls("https://sourceforge.net/projects/polyclipping/files/clipper_ver$(version).zip")
    add_versions("6.4.2", "a14320d82194807c4480ce59c98aa71cd4175a5156645c4e2b3edd330b930627")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("polyclipping")
                set_kind("$(kind)")
                set_languages("cxx11")
                add_files("cpp/*.cpp")
                add_headerfiles("cpp/(*.hpp)")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <clipper.hpp>
            void test() {
                ClipperLib::Clipper clipper;
            }
        ]]}, {configs = {languages = "cxx11"}}))
    end)
