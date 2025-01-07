package("tlsf")
    set_homepage("https://github.com/mattconte/tlsf")
    set_description("Two-Level Segregated Fit memory allocator implementation.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/mattconte/tlsf.git")
    add_versions("2020.03.29", "deff9ab509341f264addbd3c8ada533678591905")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("tlsf")
                set_kind("$(kind)")
                add_files("tlsf.c")
                add_headerfiles("tlsf.h")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("tlsf_malloc", {includes = "tlsf.h"}))
    end)
