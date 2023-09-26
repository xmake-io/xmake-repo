package("lame")
    set_homepage("https://lame.sourceforge.io/")
    set_description("High quality MPEG Audio Layer III (MP3) encoder")
    set_license("LGPL-2.0-or-later")

    add_urls("https://downloads.sourceforge.net/project/lame/lame/$(version)/lame-$(version).tar.gz")
    add_versions("3.100", "ddfe36cab873794038ae2c1210557ad34857a4b6bdc515785d1da9e175b1da1e")
    add_configs("shared", {description = "Build static libraries", default = false, type = "boolean", readonly = true})

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

    on_install("windows|x86", function (package)
        os.cp("configMS.h", "config.h")
        io.gsub("Makefile.MSVC", "nasmw", "nasm")
        import("package.tools.nmake").build(package, {"-f", "Makefile.MSVC"})
        os.cp("output/*.lib", package:installdir("lib"))
        os.cp("output/*.exe", package:installdir("bin"))
        os.cp("include/*.h", package:installdir("include/lame"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lame_encode_buffer", {includes = "lame/lame.h"}))
    end)
