package("quake_triangle")

    set_homepage("http://www.cs.cmu.edu/~quake/triangle.html")
    set_description("A Two-Dimensional Quality Mesh Generator and Delaunay Triangulator.")
    
    add_urls("https://netlib.org/voronoi/triangle.zip")
    add_versions("1.6", "1766327add038495fa3499e9b7cc642179229750f7201b94f8e1b7bee76f8480")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    add_configs("single", {description = "Use single-precision float.", default = false, type = "boolean"})

    on_install(function (package)
        io.replace("triangle.h", "REAL", package:config("single") and "float" or "double", {plain = true})
        io.replace("triangle.h", "#ifdef ANSI_DECLARATORS", "#if 1", {plain = true})
        io.replace("triangle.h", "VOID", "void", {plain = true})
        io.replace("triangle.c", "#define VOID int", "#define VOID void", {plain = true})
        local xmake_lua = [[
            add_rules("mode.debug", "mode.release")
            target("trilibrary")
                set_kind("static")
                add_files("triangle.c")
                add_defines("ANSI_DECLARATORS", "NO_TIMER", "TRILIBRARY")
                add_headerfiles("triangle.h")
            target("triangle")
                add_files("triangle.c")
                add_defines("ANSI_DECLARATORS", "NO_TIMER")
        ]]
        if package:config("single") then
            xmake_lua = xmake_lua .. "add_defines(\"SINGLE\")"
        end
        io.writefile("xmake.lua", xmake_lua)
        import("package.tools.xmake").install(package)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("triangle -h")
        end
        assert(package:has_cfuncs("triangulate", {includes = "triangle.h"}))
    end)
