package("shared-mime-info")

    set_kind("binary")
    set_homepage("https://www.freedesktop.org/wiki/Software/shared-mime-info/")
    set_description("The shared-mime-info package contains the core database of common types and the update-mime-database command used to extend it.")
    set_license("GPL-2.0")

    add_urls("https://gitlab.freedesktop.org/xdg/shared-mime-info/-/archive/$(version)/shared-mime-info-$(version).tar.gz")
    add_versions("2.2", "bcf5d552318136cf7b3ae259975f414fbcdc9ebce000c87cf1f0901ff14e619f")

    if is_plat("linux") then
        add_extsources("apt::shared-mime-info")
    end
    add_deps("meson", "ninja", "glib", "libxml2", "gettext", "pkg-config")
    on_install("macosx", "linux", function (package)
        import("package.tools.meson").install(package)
    end)

    on_test(function (package)
        os.vrun("update-mime-database -v")
    end)
