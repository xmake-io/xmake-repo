package("c-ares")

    set_homepage("https://c-ares.haxx.se/")
    set_description("A C library for asynchronous DNS requests")

    add_urls("https://c-ares.haxx.se/download/c-ares-$(version).tar.gz")

    add_versions("1.16.1", "d08312d0ecc3bd48eee0a4cc0d2137c9f194e0a28de2028928c0f6cae85f86ce")

    on_install("windows", function (package)
        local configs = {"-f", "Makefile.msvc"}
        local cfg = (package:config("shared") and "dll" or "lib") .. "-" .. (package:config("debug") and "debug" or "release")
        table.insert(configs, "CFG=" .. cfg)
        if package:config("vs_runtime"):startswith("MT") then
            table.insert(configs, "RTLIBCFG=static")
        end
        import("package.tools.nmake").install(package, configs)
        os.cp("include", package:installdir())
        os.cp("lib", package:installdir())
        if package:config("shared") then
            package:addenv("PATH", "lib")
        else
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
