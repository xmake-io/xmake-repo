package("iniparser")
    set_homepage("http://ndevilla.free.fr/iniparser")
    set_description("ini file parser")
    set_license("MIT")

    add_urls("https://github.com/ndevilla/iniparser/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ndevilla/iniparser.git")

    add_versions("v4.2.6", "a0bd370713a744b1fa8ec27bba889ebf9dbd43060ec92e07fbe91fb43e3cb3ac")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("iniparser")
                set_kind("$(kind)")
                add_files("src/*.c")
                add_headerfiles("src/*.h", {prefixdir = "iniparser"})
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("iniparser_dump_ini", {includes = "iniparser/iniparser.h"}))
    end)
