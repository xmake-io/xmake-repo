package("libdisasm")
    set_homepage("https://bastard.sourceforge.net/libdisasm.html")
    set_description("The libdisasm library provides basic disassembly of Intel x86 instructions from a binary stream.")
    set_license("MIT")

    add_urls("http://downloads.sourceforge.net/project/bastard/libdisasm/$(version)/libdisasm-$(version).tar.gz")
    add_versions("0.23", "de3e578aa582af6e1d7729f39626892fb72dc6573658a221e0905f42a65433da")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("libdisasm")
                set_kind("$(kind)")
                add_files("libdisasm/*.c")
                add_headerfiles("(libdisasm/*.h)")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        io.replace("libdisasm/x86_disasm.c", "buf_rva+offset", "(buf_rva+offset)", {plain = true})
        io.replace("libdisasm/x86_disasm.c", "buf_rva + offset", "(buf_rva+offset)", {plain = true})
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("x86_init", {includes = "libdisasm/libdis.h"}))
    end)
