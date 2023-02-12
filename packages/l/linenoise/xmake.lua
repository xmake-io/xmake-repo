package("linenoise")

    set_homepage("https://github.com/antirez/linenoise")
    set_description("A small self-contained alternative to readline and libedit")

    add_urls("https://github.com/antirez/linenoise.git")

    add_versions("2020.3.12", "97d2850af13c339369093b78abe5265845d78220")

    on_install(function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("linenoise")
                set_kind("static")
                add_files("linenoise.c")
                add_headerfiles("linenoise.h")
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("linenoise", {includes = {"stddef.h", "linenoise.h"}}))
    end)
