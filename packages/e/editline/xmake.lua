package("editline")
    set_homepage("http://thrysoee.dk/editline")
    set_description("Autotool- and libtoolized port of the NetBSD Editline library (libedit).")
    set_license("BSD-3-Clause")

    add_urls("https://thrysoee.dk/editline/libedit-20240808-$(version).tar.gz")

    add_versions("3.1", "5f0573349d77c4a48967191cdd6634dd7aa5f6398c6a57fe037cc02696d6099f")

    add_deps("ncurses")

    on_install("linux", "macosx", "bsd", "msys", function (package)
        local configs = {"--disable-examples"}
        table.insert(configs, "--with-debug=" .. (package:is_debug() and "yes" or "no"))
        if package:config("shared") then
            table.insert(configs, "--with-shared")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("el_init", {includes = "histedit.h"}))
    end)
