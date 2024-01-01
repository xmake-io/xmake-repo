package("tinyalloc")
    set_homepage("https://github.com/thi-ng/tinyalloc")
    set_description("malloc / free replacement for unmanaged, linear memory situations (e.g. WASM, embedded devices...)")
    set_license("Apache-2.0")

    add_urls("https://github.com/thi-ng/tinyalloc.git")
    add_versions("2021.10.08", "b60fcd7a351dea8a51f3ec95b19fc0d0d2e4dcd9")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("tinyalloc")
                set_kind("$(kind)")
                add_files("tinyalloc.c")
                add_headerfiles("tinyalloc.h")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ta_init", {includes = "tinyalloc.h"}))
    end)
