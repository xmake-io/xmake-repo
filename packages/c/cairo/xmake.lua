package("cairo")

    set_homepage("https://cairographics.org/")
    set_description("Vector graphics library with cross-device output support.")

    set_urls("https://cairographics.org/releases/cairo-$(version).tar.xz")
    add_versions("1.16.0", "5e7b29b3f113ef870d1e3ecf8adf21f923396401604bda16d44be45e66052331")

    add_deps("libpng", "pixman")
    if is_plat("windows") then
        add_deps("make", "zlib")
    else
        add_deps("pkg-config", "freetype", "fontconfig")
    end

    if is_plat("macosx") then
        add_frameworks("CoreGraphics", "CoreFoundation", "Foundation")
    elseif is_plat("windows") then
        add_defines("CAIRO_WIN32_STATIC_BUILD=1")
        add_syslinks("gdi32", "msimg32", "user32")
    elseif is_plat("linux") then
        add_deps("libxrender", "zlib", {host = true})
        add_syslinks("pthread")
    end

    on_install("windows", function (package)

        -- patches
        io.replace("build/Makefile.win32.common", "-MD", "-" .. package:config("vs_runtime"), {plain = true})
        io.replace("build/Makefile.win32.common", "@mkdir -p $(CFG)/`dirname $<`", "", {plain = true})
        io.replace("build/Makefile.win32.common", "zdll.lib", "zlib.lib", {plain = true})
        io.replace("build/Makefile.win32.common", "libpng.lib", "png.lib", {plain = true})
        io.replace("build/Makefile.win32.common", "/pixman/$(CFG)", "", {plain = true})
        io.replace("src/Makefile.win32", "@for x in $(enabled_cairo_headers); do echo \"	src/$$x\"; done", "", {plain = true})

        -- configs
        local cfg = package:debug() and "debug" or "release"
        local args = {"-f", "Makefile.win32", "CFG=" .. cfg}
        local pixman = package:dep("pixman")
        if pixman then
            io.replace("build/Makefile.win32.common", "%$%(PIXMAN_CFLAGS%)", "-I\"" .. pixman:installdir("include/pixman-1") .. "\"")
            table.insert(args, "PIXMAN_PATH=" .. (pixman:installdir("lib")))
        end
        local libpng = package:dep("libpng")
        if libpng then
            io.replace("build/Makefile.win32.common", "%$%(LIBPNG_CFLAGS%)", "-I\"" .. libpng:installdir("include") .. "\"")
            table.insert(args, "LIBPNG_PATH=" .. (libpng:installdir("lib")))
        end
        local zlib = package:dep("zlib")
        if zlib then
            io.replace("build/Makefile.win32.common", "%$%(ZLIB_CFLAGS%)", "-I\"" .. zlib:installdir("include") .. "\"")
            table.insert(args, "ZLIB_PATH=" .. (zlib:installdir("lib")))
        end

        -- installation
        os.mkdir(path.join("src", cfg, "win32"))
        os.vrunv("make", args, {envs = import("core.tool.toolchain").load("msvc"):runenvs()})
        os.cp("src/*.h", package:installdir("include/cairo"))
        if package:config("shared") then
            os.cp(path.join("src", cfg, "cairo.lib"), package:installdir("lib"))
            os.cp(path.join("src", cfg, "cairo.dll"), package:installdir("bin"))
        else
            os.cp(path.join("src", cfg, "cairo-static.lib"), package:installdir("lib"))
        end
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"--disable-dependency-tracking", "--enable-shared=no"}
        table.insert(configs, "--enable-gobject=no")
        table.insert(configs, "--enable-svg=yes")
        table.insert(configs, "--enable-tee=yes")
        table.insert(configs, "--enable-quartz=no")
        table.insert(configs, "--enable-xlib=" .. (is_plat("macosx") and "no" or "yes"))
        table.insert(configs, "--enable-xlib-xrender=" .. (is_plat("macosx") and "no" or "yes"))
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cairo_create", {includes = "cairo/cairo.h"}))
    end)
