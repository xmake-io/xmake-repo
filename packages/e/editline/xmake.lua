package("editline")
    set_homepage("http://thrysoee.dk/editline")
    set_description("Autotool- and libtoolized port of the NetBSD Editline library (libedit).")
    set_license("BSD-3-Clause")

    add_urls("https://thrysoee.dk/editline/libedit-20240808-$(version).tar.gz")

    add_versions("3.1", "5f0573349d77c4a48967191cdd6634dd7aa5f6398c6a57fe037cc02696d6099f")

    add_configs("terminal_db", {description = "Select terminal library", default = "termcap", type = "string", values = {"termcap", "ncurses", "tinfo"}})

    add_includedirs("include", "include/editline")

    on_load(function (package)
        local terminal = package:config("terminal_db")
        if terminal == "termcap" then
            package:add("deps", "termcap")
        elseif terminal == "ncurses" then
            package:add("deps", "ncurses")
            if package:is_plat("mingw") then
                raise("Unsupported ncurses on mingw, need package libsystre first")
            end
        else
            raise("Unsupported tinfo now!")
        end
    end)

    on_install("linux", "macosx", "bsd", "msys", function (package)
        local configs = {"--disable-examples"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        import("package.tools.autoconf").install(package, configs, {packagedeps = package:config("terminal_db")})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("el_init", {includes = "histedit.h"}))
    end)
