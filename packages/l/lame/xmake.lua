package("lame")
    set_homepage("https://lame.sourceforge.io/")
    set_description("High quality MPEG Audio Layer III (MP3) encoder")
    set_license("LGPL-2.0-or-later")

    add_urls("https://downloads.sourceforge.net/project/lame/lame/$(version)/lame-$(version).tar.gz")
    add_versions("3.100", "ddfe36cab873794038ae2c1210557ad34857a4b6bdc515785d1da9e175b1da1e")

    -- @see https://github.com/xmake-io/xmake-repo/pull/8377#issuecomment-3405442429
    if is_plat("linux") and is_arch("arm.*", "mips.*") then
        add_configs("debug", {description = "Enable debug symbols.", default = false, type = "boolean", readonly = true})
    end

    add_deps("nasm")
    on_install("linux", "macosx", "bsd", function (package)
        local configs = {"--enable-nasm"}
        -- fix undefined symbol error _lame_init_old
        -- https://sourceforge.net/p/lame/mailman/message/36081038/
        io.replace("include/libmp3lame.sym", "lame_init_old\n", "", {plain = true})
        import("package.tools.autoconf").install(package, configs)
    end)

    on_install("windows", function (package)
        -- slight adjustments according to https://github.com/conan-io/conan-center-index/blob/b39954231875c1350964a658c408c8a840a9eb20/recipes/libmp3lame/all/conanfile.py
        -- Honor vc runtime
        io.replace("Makefile.MSVC", "CC_OPTS = $(CC_OPTS) /MT", "", {plain = true})
        -- Do not hardcode LTO
        io.replace("Makefile.MSVC", " /GL", "", {plain = true})
        io.replace("Makefile.MSVC", " /LTCG", "", {plain = true})
        io.replace("Makefile.MSVC", "ADDL_OBJ = bufferoverflowU.lib", "", {plain = true})

        -- lame install guide says to `copy configMS.h config.h`
        -- then to `nmake -f Makefile.MSVC  comp=msvc  asm=no`
        os.cp("configMS.h", "config.h")
        -- this was here before, who knows if it's needed
        io.gsub("Makefile.MSVC", "nasmw", "nasm")

        -- more stuff from conan-io
        local configs = {"-f", "Makefile.MSVC", "comp=msvc"}
        if package:is_arch("x86") then
            table.insert(configs, "asm=yes")
        elseif package:is_arch("x64") then
            io.replace("Makefile.MSVC", "MACHINE = /machine:I386", "MACHINE =/machine:X64", {plain = true})
            table.insert(configs, "MSVCVER=Win64")
            table.insert(configs, "asm=yes")
        elseif package:is_arch("arm64") then
            io.replace("Makefile.MSVC", "MACHINE = /machine:I386", "MACHINE =/machine:ARM64", {plain = true})
            table.insert(configs, "MSVCVER=Win64")
        else
            table.insert(configs, "asm=yes")
        end
        import("package.tools.nmake").build(package, configs)

        os.cp("output/*.lib", package:installdir("lib"))
        os.cp("output/*.exe", package:installdir("bin"))
        os.cp("include/*.h", package:installdir("include/lame"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lame_encode_buffer", {includes = "lame/lame.h"}))
    end)
