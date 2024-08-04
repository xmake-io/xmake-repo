package("liba52")
    set_homepage("https://liba52.sourceforge.io")
    set_description("Library for decoding ATSC A/52 (AC-3) audio streams")
    set_license("GPL-2.0-or-later")

    add_urls("https://git.adelielinux.org/community/a52dec/-/archive/$(version)/a52dec-$(version).tar.bz2",
             "https://git.adelielinux.org/community/a52dec.git",
             "https://code.videolan.org/videolan/liba52.git",
             "https://github.com/Distrotech/a52dec.git")

    add_versions("v0.8.0", "d4f26685d32a8c85f86a5cb800554160fb85400298a0a27151c3d1e63a170943")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::a52dec")
    elseif is_plat("linux") then
        add_extsources("pacman::a52dec", "apt::liba52-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::a52dec")
    end

    if is_plat("windows", "mingw") then
        add_syslinks("winmm")
    elseif is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    on_load("windows", function (package)
        if package:config("tools") then
            package:add("deps", "strings_h", {private = true})
        end
    end)

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "config.h.in"), "config.h.in")
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {tools = package:config("tools")})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("a52_init", {includes = {"inttypes.h", "a52dec/a52.h"}}))
    end)
