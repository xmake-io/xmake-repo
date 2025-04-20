package("wren")
    set_homepage("http://wren.io")
    set_description("Wren is a small, fast, class-based concurrent scripting language.")
    set_license("MIT")

    add_urls("https://github.com/wren-lang/wren/archive/refs/tags/$(version).tar.gz",
             "https://github.com/wren-lang/wren.git")

    add_versions("0.4.0", "23c0ddeb6c67a4ed9285bded49f7c91714922c2e7bb88f42428386bf1cf7b339")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("wren")
                set_kind("$(kind)")
                add_headerfiles("src/include/*.h", "src/vm/*.h", "src/optional/*.h")
                add_includedirs("src/include", "src/vm", "src/optional")
                add_files("src/vm/*.c", "src/optional/*.c")
                if is_mode("debug") then
                    add_defines("DEBUG")
                end
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all")
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("wrenInterpret", {includes = "wren.h"}))
    end)
