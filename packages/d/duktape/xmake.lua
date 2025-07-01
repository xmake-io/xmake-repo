package("duktape")
    set_homepage("https://github.com/svaarala/duktape")
    set_description("Duktape - embeddable Javascript engine with a focus on portability and compact footprint")
    set_license("MIT")

    add_urls("https://github.com/svaarala/duktape/releases/download/v$(version)/duktape-$(version).tar.xz",
             "https://github.com/svaarala/duktape.git")

    add_versions("2.7.0", "90f8d2fa8b5567c6899830ddef2c03f3c27960b11aca222fa17aa7ac613c2890")

    on_install(function (package)
        local configs = {}
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            target("duktape")
                set_kind("$(kind)")
                add_files("src-noline/*.c")
                add_headerfiles("src-noline/(*.h)")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("duk_push_c_function", {includes = "duktape.h"}))
    end)
