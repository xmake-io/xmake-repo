package("neco")
    set_homepage("https://github.com/tidwall/neco")
    set_description("Concurrency library for C (coroutines)")
    set_license("MIT")

    add_urls("https://github.com/tidwall/neco/archive/refs/tags/$(version).tar.gz",
             "https://github.com/tidwall/neco.git")

    add_versions("v0.3.2", "ae3cefa6217428e992da0b30f254502b9974079dd9973eee9c482ea89df3fcef")

    if is_plat("linux", "bsd") then
        add_syslinks("pthread", "dl")
    end

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            set_languages("c11")
            target("neco")
                set_kind("$(kind)")
                add_files("neco.c")
                add_headerfiles("neco.h")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
                if is_plat("linux", "bsd") then
                    add_syslinks("pthread", "dl")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("neco_start", {includes = "neco.h"}))
    end)
