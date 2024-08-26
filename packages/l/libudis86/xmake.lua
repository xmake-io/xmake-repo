package("libudis86")
    set_homepage("http://udis86.sourceforge.net")
    set_description("Disassembler Library for x86 and x86-64")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/vmt/udis86.git")
    add_versions("2014.12.25", "56ff6c87c11de0ffa725b14339004820556e343d")

    add_deps("python")

    on_install(function (package)
        io.replace("scripts/ud_opcode.py", "/ 32", "// 32", {plain = true})
        io.replace("scripts/ud_opcode.py", "/ 2", "// 2", {plain = true})
        os.vrunv("python", {"scripts/ud_itab.py", "docs/x86/optable.xml", "libudis86"})
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("udis86")
                set_kind("$(kind)")
                add_files("libudis86/*.c")
                add_headerfiles("udis86.h")
                add_headerfiles("libudis86/*.h", {prefixdir = "libudis86"})
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_filter = function(symbol) return symbol:startswith("ud_") end})
                end
        ]])
        local configs = {kind = package:config("shared") and "shared" or "static"}
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ud_init", {includes = "udis86.h"}))
    end)
