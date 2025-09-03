package("hiredis-vip")
    set_homepage("https://github.com/vipshop/hiredis-vip")
    set_description("Support redis cluster.  Maintained and used at vipshop.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/vipshop/hiredis-vip/archive/refs/tags/$(version).tar.gz",
             "https://github.com/vipshop/hiredis-vip.git")

    add_versions("0.3.0", "84e0f9367fa25089fc073b7a8a0725043c48cccec827acf4555a63da68f36be5")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean"})

    on_install("linux", "macosx", function (package)
        local configs = {}
        table.insert(configs, "PREFIX=" .. package:installdir())
        if not package:config("debug") or package:is_mode("release") then
            table.insert(configs, "DEBUG=")
        end
        os.vrunv("make install ", configs)
        os.cp(path.join(os.curdir(), "net.h"), package:installdir("include/hiredis-vip"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("redisCommand", {includes = "hiredis-vip/hiredis.h"}))
    end)
