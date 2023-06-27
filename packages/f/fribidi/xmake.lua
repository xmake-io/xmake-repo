package("fribidi")

    set_homepage("https://github.com/fribidi/fribidi")
    set_description("The Free Implementation of the Unicode Bidirectional Algorithm.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/fribidi/fribidi/releases/download/v$(version)/fribidi-$(version).tar.xz")
    add_versions("1.0.10", "7f1c687c7831499bcacae5e8675945a39bacbad16ecaa945e9454a32df653c01")
    add_versions("1.0.11", "30f93e9c63ee627d1a2cedcf59ac34d45bf30240982f99e44c6e015466b4e73d")
    add_versions("1.0.12", "0cd233f97fc8c67bb3ac27ce8440def5d3ffacf516765b91c2cc654498293495")

    if is_plat("windows") then
        add_deps("meson", "ninja")
    elseif is_plat("linux") then
        add_extsources("apt::libfribidi-dev", "pacman::fribidi")
    end

    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "FRIBIDI_LIB_STATIC")
        end
    end)

    on_install("windows", function (package)
        local configs = {"-Ddocs=false", "-Dtests=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_install("macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("fribidi_debug_status", {includes = "fribidi/fribidi-common.h"}))
    end)
