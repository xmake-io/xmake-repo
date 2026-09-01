package("libmpeg2")
    set_homepage("https://libmpeg2.sourceforge.io")
    set_description("MPEG-1 and MPEG-2 stream decoding library")
    set_license("GPL-2.0-or-later")

    add_urls("https://libmpeg2.sourceforge.io/files/libmpeg2-$(version).tar.gz",
             "https://github.com/cisco-open-source/libmpeg2.git")

    add_versions("0.5.1", "dee22e893cb5fc2b2b6ebd60b88478ab8556cb3b93f9a0d7ce8f3b61851871d4")

    add_patches("0.5.1", "patches/0.5.1/msvc.patch", "e71d4a9c105388a0b4a50f56a05b56cb7ce9380cc645d891f449b7655c29e26e")

    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    if is_plat("linux", "macosx", "bsd") then
        add_deps("libxext")
    end

    on_load(function (package)
        if package:is_plat("windows") and package:config("tools") then
            package:add("deps", "strings_h", {private = true})
        end
    end)

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "config.h.in"), "config.h.in")
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package, {tools = package:config("tools")})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mpeg2_init", {includes = {"inttypes.h", "mpeg2dec/mpeg2.h"}}))
    end)
