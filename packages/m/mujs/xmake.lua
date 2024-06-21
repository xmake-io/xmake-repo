package("mujs")
    set_homepage("http://mujs.com/")
    set_description("An embeddable Javascript interpreter in C.")

    add_urls("https://mujs.com/downloads/mujs-$(version).tar.gz")
    add_urls("https://github.com/ccxvii/mujs/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ccxvii/mujs.git")

    add_versions("1.3.5", "78a311ae4224400774cb09ef5baa2633c26971513f8b931d3224a0eb85b13e0b")
    add_versions("1.3.4", "c015475880f6a382e706169c94371a7dd6cc22078832f6e0865af8289c2ef42b")

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    add_includedirs("include", "include/mujs")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("mujs")
                set_kind("$(kind)")
                add_files("js*.c", "utf*.c", "regexp.c")
                add_headerfiles("*.h", {prefixdir = "mujs"})
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("js_newstate", {includes = "mujs/mujs.h"}))
    end)
