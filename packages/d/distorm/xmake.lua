package("distorm")
    set_homepage("https://github.com/gdabah/distorm")
    set_description("Powerful Disassembler Library For x86/AMD64")

    add_urls("https://github.com/gdabah/distorm.git")
    add_versions("2021.12.18", "7a02caa1a936f0a653fc75f1aaea9bd3fa654603")

    on_install(function (package)
        io.replace("src/textdefs.c", "RSHORT(&s->p[i]) = RSHORT(&TextBTable[(*buf) * 2]);", "s->p[i] = TextBTable[(*buf) * 2];s->p[i + 1] = TextBTable[(*buf) * 2 + 1];", {plain = true})
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("distorm")
                set_kind("$(kind)")
                add_files("src/*.c")
                add_headerfiles("include/*.h", {prefixdir = "distorm"})
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("distorm_version", {includes = "distorm/distorm.h"}))
    end)
