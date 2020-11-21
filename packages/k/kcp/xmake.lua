package("kcp")

    set_homepage("https://github.com/skywind3000/kcp")
    set_description("A Fast and Reliable ARQ Protocol.")

    add_urls("https://github.com/skywind3000/kcp/archive/$(version).tar.gz",
             "https://github.com/skywind3000/kcp.git")
    add_versions("1.7", "b4d26994d95599ab0c44e1f93002f9fda275094a879d66c192d79d596529199e")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("kcp")
                set_kind("static")
                add_files("ikcp.c")
                add_headerfiles("ikcp.h")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ikcp_create", {includes = "ikcp.h"}))
    end)