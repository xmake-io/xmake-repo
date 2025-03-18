package("libjq")
    set_homepage("https://jqlang.org")
    set_description("Command-line JSON processor")
    set_license("MIT")

    add_urls("https://github.com/jqlang/jq/archive/refs/tags/jq-$(version).tar.gz",
             "https://github.com/jqlang/jq.git")

    add_versions("1.7.1" , "fc75b1824aba7a954ef0886371d951c3bf4b6e0a921d1aefc553f309702d6ed1")

    add_deps("autoconf", "automake", "libtool")

    add_configs("oniguruma",    {description = "Build with oniguruma", default = true, type = "boolean"})
    add_configs("all_static",   {description = "Link jq with static libraries only", default = false, type = "boolean"})

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

    on_check(function (package)
        assert(not (package:is_plat("android") and is_subhost("windows")), "package(libjq): does not support windows@android.")
        assert(not (package:is_plat("mingw") and is_subhost("msys")), "package(libjq): does not support mingw@msys.")
    end)

    on_load(function (package)
        if package:config("oniguruma") then
            package:add("deps", "oniguruma")
        end
    end)

    on_install("!windows and !wasm", function (package)
        if not package:is_cross() then
            package:addenv("PATH", "bin")
        end
        local configs = {"--enable-docs=no"}
        if package:config("shared") then
            table.insert(configs, "--enable-shared")
            table.insert(configs, "--disable-static")
        else
            table.insert(configs, "--enable-static")
            table.insert(configs, "--disable-shared")
        end
        if package:debug() then
            table.insert(configs, "--enable-debug")
        else
            table.insert(configs, "--disable-debug")
        end
        if package:config("all_static") then
            table.insert(configs, "--enable-all-static")
        end
        local opt = {}
        if package:config("oniguruma") then
            opt.packagedeps = "oniguruma"
        end
        table.insert(configs, "--with-oniguruma=" .. (package:config("oniguruma") and "yes" or "no"))
        import("package.tools.autoconf").install(package, configs, opt)
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("jq --version")
        end
        assert(package:has_cfuncs("jq_init" , {includes = "jq.h"}))
    end)
