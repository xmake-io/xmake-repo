package("libjq")
    set_homepage("https://jqlang.org/")
    set_description("a lightweight and flexible command-line JSON processor")

    add_urls("https://github.com/jqlang/jq/archive/refs/tags/jq-$(version).tar.gz")
    add_versions("1.7.1" , "fc75b1824aba7a954ef0886371d951c3bf4b6e0a921d1aefc553f309702d6ed1")

    add_deps("oniguruma")

    set_extsources("apt::libjq-dev")
    set_extsources("pkgconfig::libjq")

    on_install(function(package)
        local configs = {}
        local oniguruma = package:dep("oniguruma")
        table.insert(configs , "--with-oniguruma=" .. oniguruma:installdir())
        if not package:config("shared") then
            table.insert(configs , "--enable-all-static")
            table.insert(configs , "--enable-static")
            table.insert(configs , "--enable-shared=no")
        end
        import("package.tools.autoconf").install(package , configs)
    end)

    on_test(function(package)
        assert(package:has_cfuncs("jq_init" , {includes = "jq.h"}))
    end)
