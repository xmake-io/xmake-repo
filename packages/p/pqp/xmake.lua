package("pqp")

    set_homepage("http://gamma.cs.unc.edu/SSV/")
    set_description("A Proximity Query Package")

    set_urls("http://gamma.cs.unc.edu/software/downloads/SSV/pqp-$(version).tar.gz",
             "https://github.com/GammaUNC/PQP.git")

    add_versions("1.3", "00bdcb380206393349ed7ee9a773f894bf796059c66cec0d97c0a93649eb012f")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_rules("mode.debug", "mode.release")
            target("pqp")
                set_kind("$(kind)")
                add_files("**.cpp|**/demos/**")
                add_headerfiles("**.h|**/demos/**")
                add_defines("WIN32=_WIN32")
        ]])
        local configs = {}
        configs.kind = package:config("shared") and "shared" or "static"
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("PQP_Collide", {includes = "PQP.h"}))
        assert(package:has_cxxfuncs("TriDist", {includes = "TriDist.h"}))
    end)
