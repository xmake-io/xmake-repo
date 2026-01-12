package("shared-mime-info")
    set_kind("binary")
    set_homepage("https://www.freedesktop.org/wiki/Software/shared-mime-info/")
    set_description("The shared-mime-info package contains the core database of common types and the update-mime-database command used to extend it.")
    set_license("GPL-2.0")

    add_urls("https://gitlab.freedesktop.org/xdg/shared-mime-info/-/archive/$(version)/shared-mime-info-$(version).tar.bz2",
             "https://gitlab.freedesktop.org/xdg/shared-mime-info.git")

    add_versions("2.4", "32dc32ae39ff1c1bf8434dd3b36770b48538a1772bc0298509d034f057005992")
    add_versions("2.2", "418c480019d9865f67f922dfb88de00e9f38bf971205d55cdffab50432919e61")

    if is_plat("linux") then
        add_extsources("apt::shared-mime-info")
    end

    add_deps("meson", "ninja", "pkg-config")
    add_deps("libxml2", {configs = {tools = true}})
    add_deps("glib", "gettext")

    on_install("macosx", "linux", function (package)
        import("package.tools.meson").install(package, {}, {packagedeps = {"libintl", "libiconv"}})
    end)

    on_test(function (package)
        os.vrun("update-mime-database -v")
    end)
