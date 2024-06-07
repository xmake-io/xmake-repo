package("iniparser")
    set_homepage("http://ndevilla.free.fr/iniparser")
    set_description("ini file parser")
    set_license("MIT")

    add_urls("https://github.com/ndevilla/iniparser.git")
    add_versions("2023.09.15", "5142f0feab8ab456cb6af607eba0516ae46e1eb2")

    on_install("linux", "macosx", "bsd", "mingw", "msys", "android", "iphoneos", "cross", "wasm", function (package)
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
