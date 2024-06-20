package("cdt")
    set_homepage("https://artem-ogre.github.io/CDT/")
    set_description("Constrained Delaunay Triangulation (C++)")
    set_license("MPL-2.0")

    add_urls("https://github.com/artem-ogre/CDT/archive/refs/tags/$(version).tar.gz",
             "https://github.com/artem-ogre/CDT.git")

    add_versions("1.4.1", "86df99eb5f02a73eeb8c6ea45765eed0d7f206e8d4d9f6479f77e3c590ae5bb3")

    if is_plat("macosx") then
        add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
    end

    on_install(function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("cdt")
                set_kind("$(kind)")
                set_languages("cxx17")
                add_files("CDT/src/*.cpp")
                add_headerfiles("CDT/include/(*.h)")
                add_headerfiles("CDT/include/(*.hpp)")
        ]])
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <CDT.h>
            using namespace CDT;
            void test() {
                 auto cdt = Triangulation<double>{};
                cdt.insertVertices({
                    {0.0, 1e38},
                    {1.0, 1e38},
                });
            }
        ]]}, {configs = {languages = "cxx17"}}))
    end)
