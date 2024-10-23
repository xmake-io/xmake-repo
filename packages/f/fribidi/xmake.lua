package("fribidi")

    set_homepage("https://github.com/fribidi/fribidi")
    set_description("The Free Implementation of the Unicode Bidirectional Algorithm.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/fribidi/fribidi/releases/download/v$(version)/fribidi-$(version).tar.xz")
    add_versions("1.0.16", "1b1cde5b235d40479e91be2f0e88a309e3214c8ab470ec8a2744d82a5a9ea05c")
    add_versions("1.0.15", "0bbc7ff633bfa208ae32d7e369cf5a7d20d5d2557a0b067c9aa98bcbf9967587")
    add_versions("1.0.14", "76ae204a7027652ac3981b9fa5817c083ba23114340284c58e756b259cd2259a")
    add_versions("1.0.10", "7f1c687c7831499bcacae5e8675945a39bacbad16ecaa945e9454a32df653c01")
    add_versions("1.0.11", "30f93e9c63ee627d1a2cedcf59ac34d45bf30240982f99e44c6e015466b4e73d")
    add_versions("1.0.12", "0cd233f97fc8c67bb3ac27ce8440def5d3ffacf516765b91c2cc654498293495")
    add_versions("1.0.13", "7fa16c80c81bd622f7b198d31356da139cc318a63fc7761217af4130903f54a2")

    if not is_plat("macosx", "linux", "bsd") then
        add_deps("meson", "ninja")
    elseif is_plat("linux") then
        add_extsources("apt::libfribidi-dev", "pacman::fribidi")
    end

    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_includedirs("include", "include/fribidi")
    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "FRIBIDI_LIB_STATIC")
        end
    end)

    on_install("macosx", "linux", "bsd", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_install("windows|x86", "windows|x64", "mingw", "msys", "wasm", "cross", function (package)
        local configs = {"-Ddocs=false", "-Dtests=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("fribidi_debug_status", {includes = "fribidi/fribidi-common.h"}))
    end)
