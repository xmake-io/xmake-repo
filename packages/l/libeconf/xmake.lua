package("libeconf")
    set_homepage("https://github.com/openSUSE/libeconf")
    set_description("A highly flexible and extensible library for parsing and managing configuration files.")
    set_license("MIT")

    add_urls("https://github.com/openSUSE/libeconf/archive/refs/tags/$(version).tar.gz",
             "https://github.com/openSUSE/libeconf.git")

    add_versions("v0.7.10", "e8fee300cbbae11287d2682d185d946a1ffbd23bf02b4f97d68f2df34d8de07f")

    add_deps("meson", "ninja")
    on_install("linux", "bsd", "android", "macosx", "iphoneos", "cross", function (package)
        if package:is_plat("macosx") then
            io.replace("meson.build", " + version_flag", "", {plain = true})
        end
        io.replace("meson.build", "subdir%b()", "")
        io.replace("meson.build", "executable%b()", "")

        import("package.tools.meson").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("econf_readFile", {includes = "libeconf.h"}))
    end)
