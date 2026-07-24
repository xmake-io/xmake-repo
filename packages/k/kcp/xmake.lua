package("kcp")
    set_homepage("https://github.com/skywind3000/kcp")
    set_description("A Fast and Reliable ARQ Protocol.")
    set_license("MIT")

    add_urls("https://github.com/skywind3000/kcp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/skywind3000/kcp.git")

    add_versions("2.1.1", "54d3c80928d206529f67cba6f96f2c98007182b46e3112819b200d914f96e425")
    add_versions("1.7", "b4d26994d95599ab0c44e1f93002f9fda275094a879d66c192d79d596529199e")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("kcp")
                set_kind("$(kind)")
                add_rules("utils.symbols.export_list", {symbols = {
                    "ikcp_create",
                    "ikcp_release",
                    "ikcp_setoutput",
                    "ikcp_recv",
                    "ikcp_send",
                    "ikcp_update",
                    "ikcp_check",
                    "ikcp_input",
                    "ikcp_flush",
                    "ikcp_peeksize",
                    "ikcp_setmtu",
                    "ikcp_wndsize",
                    "ikcp_waitsnd",
                    "ikcp_nodelay",
                    "ikcp_log",
                    "ikcp_allocator",
                    "ikcp_getconv"
                }})
                add_files("ikcp.c")
                add_headerfiles("ikcp.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ikcp_create", {includes = "ikcp.h"}))
    end)
