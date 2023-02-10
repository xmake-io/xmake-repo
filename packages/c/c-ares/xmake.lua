package("c-ares")

    set_homepage("https://c-ares.org/")
    set_description("A C library for asynchronous DNS requests")

    add_urls("https://c-ares.org/download/c-ares-$(version).tar.gz")
    add_versions("1.16.1", "d08312d0ecc3bd48eee0a4cc0d2137c9f194e0a28de2028928c0f6cae85f86ce")
    add_versions("1.17.0", "1cecd5dbe21306c7263f8649aa6e9a37aecb985995a3489f487d98df2b40757d")
    add_versions("1.17.1", "d73dd0f6de824afd407ce10750ea081af47eba52b8a6cb307d220131ad93fc40")
    add_versions("1.17.2", "4803c844ce20ce510ef0eb83f8ea41fa24ecaae9d280c468c582d2bb25b3913d")
    add_versions("1.18.0", "71c19708ed52a60ec6f14a4a48527187619d136e6199683e77832c394b0b0af8")
    add_versions("1.18.1", "1a7d52a8a84a9fbffb1be9133c0f6e17217d91ea5a6fa61f6b4729cda78ebbcf")

    add_patches("1.18.1",
                path.join(os.scriptdir(), "patches", "1.18.1", "guard-imported-lib.patch" ),
                "3cb03453af9e1477cfe926b1c03b2e3fbb8200a72888b590439e69e2d4253609")
    add_patches("1.18.1",
                path.join(os.scriptdir(), "patches", "1.18.1", "skip-docs.patch" ),
                "bbe389b4aab052c2e6845e87d1f56a8366bf18c944f5e5e6f05a2cf105dbe680")

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