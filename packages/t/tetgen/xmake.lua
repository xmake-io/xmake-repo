package("tetgen")

    set_homepage("https://www.wias-berlin.de/software/index.jsp?id=TetGen")
    set_description("A Quality Tetrahedral Mesh Generator and a 3D Delaunay Triangulator")
    set_license("AGPL-3.0")

    add_urls("https://wias-berlin.de/software/tetgen/1.5/src/tetgen1.6.0.zip")
    add_versions("1.6.0", "e7bbbb4fb8f47f0adc3b46b26ab172557ebb90808c06e21b902b2166717af582")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            set_languages("c++11")
            target("tet")
                set_kind("static")
                add_files("tetgen.cxx", "predicates.cxx")
                add_headerfiles("tetgen.h")
                add_defines("TETLIBRARY")
            target("tetgen")
                add_files("tetgen.cxx", "predicates.cxx")
        ]])
        import("package.tools.xmake").install(package)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("tetgen -h")
        end
        assert(package:has_cxxfuncs("tetrahedralize", {includes = "tetgen.h"}))
    end)
