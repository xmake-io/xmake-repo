package("rpmalloc")
    set_homepage("https://github.com/mjansson/rpmalloc")
    set_description("Public domain cross platform lock free thread caching 16-byte aligned memory allocator implemented in C")

    add_urls("https://github.com/mjansson/rpmalloc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mjansson/rpmalloc.git")
    add_versions("1.4.4", "3859620c03e6473f0b3f16a4e965e7c049594253f70e8370fb9caa0e4118accb")

    if is_plat("windows") then
        add_syslinks("advapi32")
    end

    on_install(function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("rpmalloc")
                set_kind("$(kind)")
                add_files("rpmalloc/rpmalloc.c")
                add_headerfiles("rpmalloc/(*.h)")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                    add_syslinks("advapi32")
                end
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("rpmalloc", {includes = "rpmalloc.h"}))
    end)
