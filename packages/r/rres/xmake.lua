package("rres")
    set_homepage("https://github.com/raysan5/rres")
    set_description("A simple and easy-to-use file-format to package resources")
    set_license("MIT")

    add_urls("https://github.com/raysan5/rres/archive/refs/tags/$(version).tar.gz",
             "https://github.com/raysan5/rres.git")

    add_versions("1.2.0", "b9b93a9301b7012f5cd52af45cc1ac3fef5994ccfff324ccd71c196a08faf39f")

    on_install(function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end

        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("rres")
                set_kind("$(kind)")
                add_files("src/*.c", "src/external/*.c")
                add_headerfiles("src/(*.h)", "src/external/*.h")
                if is_plat("windows") then
                    add_defines("RRES_API=__declspec(dllexport)")
                end
        ]])

        io.writefile("src/rres_impl.c", [[
            #define RRES_IMPLEMENTATION
            #include "rres.h"
        ]])

        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("rresLoadCentralDirectory", {includes = "rres.h"}))
    end)
