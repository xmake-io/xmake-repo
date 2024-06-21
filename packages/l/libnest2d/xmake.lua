package("libnest2d")
    set_homepage("https://github.com/tamasmeszaros/libnest2d")
    set_description("2D irregular bin packaging and nesting library written in modern C++")
    set_license("LGPL-3.0")

    add_urls("https://github.com/tamasmeszaros/libnest2d.git")
    add_versions("2022.11.16", "663daa69e1d7478669f714218e27681edbc96640")

    add_deps("nlopt", "polyclipping", "boost_geometry")

    on_load(function (package)
        package:add("defines", "LIBNEST2D_GEOMETRIES_clipper")
        package:add("defines", "LIBNEST2D_OPTIMIZER_nlopt")
    end)

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        local configs = {}
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <libnest2d/libnest2d.hpp>

            void test() {
                using namespace libnest2d;
                Degrees deg(180);
            }
        ]]}, {configs = {languages = "cxx11"}}))
    end)
