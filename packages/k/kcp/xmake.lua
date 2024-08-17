package("kcp")

    set_homepage("https://github.com/skywind3000/kcp")
    set_description("A Fast and Reliable ARQ Protocol.")
    set_license("MIT")

    add_urls("https://github.com/skywind3000/kcp/archive/$(version).tar.gz",
             "https://github.com/skywind3000/kcp.git")
    add_versions("1.7", "b4d26994d95599ab0c44e1f93002f9fda275094a879d66c192d79d596529199e")


    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("kcp")
                set_kind("$(kind)")
                if is_kind("shared") and is_plat("windows") then
                    local funcs = {"ikcp_allocator",
                                   "ikcp_check",
                                   "ikcp_create",
                                   "ikcp_flush",
                                   "ikcp_getconv",
                                   "ikcp_input",
                                   "ikcp_interval",
                                   "ikcp_log",
                                   "ikcp_nodelay",
                                   "ikcp_parse_data",
                                   "ikcp_peeksize",
                                   "ikcp_qprint",
                                   "ikcp_recv",
                                   "ikcp_release",
                                   "ikcp_send",
                                   "ikcp_setmtu",
                                   "ikcp_setoutput",
                                   "ikcp_update",
                                   "ikcp_waitsnd",
                                   "ikcp_wndsize"}
                    for _, func in ipairs(funcs) do
                        add_shflags("/export:" .. func)
                    end
                end
                add_files("ikcp.c")
                add_headerfiles("ikcp.h")
        ]])
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ikcp_create", {includes = "ikcp.h"}))
    end)