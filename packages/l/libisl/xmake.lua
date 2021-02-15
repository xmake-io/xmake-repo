package("libisl")

    set_homepage("http://isl.gforge.inria.fr/")
    set_description("Integer Set Library")

    set_urls("http://isl.gforge.inria.fr/isl-$(version).tar.xz")
    add_versions("0.23", "5efc53efaef151301f4e7dde3856b66812d8153dede24fab17673f801c8698f2")
    add_versions("0.22", "6c8bc56c477affecba9c59e2c9f026967ac8bad01b51bdd07916db40a517b9fa")

    add_deps("autoconf", "gmp")

    on_install("linux", "macosx", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        table.insert(configs, "--with-gmp-prefix=" .. package:dep("gmp"):installdir())
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("isl_version", {includes = "isl/version.h"}))
    end)
