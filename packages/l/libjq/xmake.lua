package("libjq")
    set_homepage("https://jqlang.org")
    set_description("Command-line JSON processor")

    add_urls("https://github.com/jqlang/jq/archive/refs/tags/jq-$(version).tar.gz",
             "https://github.com/jqlang/jq.git")

    add_versions("1.7.1" , "fc75b1824aba7a954ef0886371d951c3bf4b6e0a921d1aefc553f309702d6ed1")

    add_deps("autoconf", "automake", "libtool")

    add_configs("oniguruma", {description = "Build with oniguruma", default = true, type = "boolean"})

    if not is_host("windows") then
        add_extsources("pkgconfig::libjq")
    end

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::jq")
    elseif is_plat("linux") then
        add_extsources("apt::libjq-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::jq")
    end

    if is_plat("linux", "bsd") then
        add_syslinks("m", "pthread")
    elseif is_plat("windows", "mingw") then
        add_syslinks("shlwapi")
    end

    on_load(function (package)
        if package:config("oniguruma") then
            package:add("deps", "oniguruma")
        end
    end)

    on_install(function (package)
        local configs = {"--enable-docs=no"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        table.insert(configs, "--with-oniguruma=" .. (package:config("oniguruma") and "yes" or "no"))
        import("package.tools.autoconf").install(package, configs, {packagedeps = "oniguruma"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("jq_init" , {includes = "jq.h"}))
    end)
