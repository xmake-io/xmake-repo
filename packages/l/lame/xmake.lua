package("lame")
    set_homepage("https://lame.sourceforge.io/")
    set_description("High quality MPEG Audio Layer III (MP3) encoder")
    set_license("LGPL-2.0-or-later")

    add_urls("https://downloads.sourceforge.net/project/lame/lame/$(version)/lame-$(version).tar.gz")
    add_versions("3.100", "ddfe36cab873794038ae2c1210557ad34857a4b6bdc515785d1da9e175b1da1e")

    add_deps("nasm")

    on_install("linux", "macosx", "bsd", function (package)
        local configs = {"--enable-nasm"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:is_plat("linux") and package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        -- fix undefined symbol error _lame_init_old
        -- https://sourceforge.net/p/lame/mailman/message/36081038/
        io.replace("include/libmp3lame.sym", "lame_init_old\n", "", {plain = true})
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lame_encode_buffer", {includes = "lame/lame.h"}))
    end)
