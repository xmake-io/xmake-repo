package("c-ares")

    set_homepage("https://c-ares.haxx.se/")
    set_description("A C library for asynchronous DNS requests")

    add_urls("https://c-ares.haxx.se/download/c-ares-$(version).tar.gz")
    add_versions("1.16.1", "d08312d0ecc3bd48eee0a4cc0d2137c9f194e0a28de2028928c0f6cae85f86ce")
    add_versions("1.17.1", "d73dd0f6de824afd407ce10750ea081af47eba52b8a6cb307d220131ad93fc40")

    if is_plat("macosx") then
        add_syslinks("resolv")
    end

    on_install("windows", function (package)
        local configs = {"-f", "Makefile.msvc"}
        local cfg = (package:config("shared") and "dll" or "lib") .. "-" .. (package:config("debug") and "debug" or "release")
        table.insert(configs, "CFG=" .. cfg)
        if package:config("vs_runtime"):startswith("MT") then
            table.insert(configs, "RTLIBCFG=static")
        end
        import("package.tools.nmake").build(package, configs)
        os.cp(path.join("include", "*.h"), package:installdir("include"))
        os.cp(path.join("msvc", "cares", cfg, "*.lib"), package:installdir("lib"))
        os.trycp(path.join("msvc", "cares", cfg, "*.dll"), package:installdir("bin"))
        if not package:config("shared") then
            package:add("defines", "CARES_STATICLIB")
        end
    end)

    on_install("macosx", "linux", function (package)
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
            table.insert(configs, "--enable-static=no")
        else
            table.insert(configs, "--enable-shared=no")
            table.insert(configs, "--enable-static=yes")
        end
        if package:config("debug") then
            table.insert(configs, "--enable-debug")
        else
            table.insert(configs, "--disable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ares_library_init", {includes = "ares.h"}))
    end)
