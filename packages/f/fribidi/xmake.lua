package("fribidi")

    set_homepage("https://github.com/fribidi/fribidi")
    set_description("The Free Implementation of the Unicode Bidirectional Algorithm.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/fribidi/fribidi/releases/download/v$(version)/fribidi-$(version).tar.xz")
    add_versions("1.0.10", "7f1c687c7831499bcacae5e8675945a39bacbad16ecaa945e9454a32df653c01")

    if is_plat("linux") then
        add_extsources("apt::libfribidi-dev")
    end

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
