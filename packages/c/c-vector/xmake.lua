package("c-vector")
    set_homepage("https://github.com/Mashpoe/c-vector")
    set_description("A simple vector library for C that can store any type.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/Mashpoe/c-vector/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Mashpoe/c-vector.git")

    add_versions("v1.0", "c1ddd2975abd54ce55309fef04cc9d47e8a356a964298f516a9e314f9fcd20d4")

    on_install(function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("c-vector")
                set_kind("$(kind)")
                add_files("vec.c")
                add_headerfiles("vec.h")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vector_create", {includes = "vec.h"}))
    end)
