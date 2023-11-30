package("libdrm")

    set_homepage("https://gitlab.freedesktop.org/mesa/drm")
    set_description("libdrm - userspace library for drm (direct rendering manager)")

    add_urls("https://dri.freedesktop.org/libdrm/libdrm-$(version).tar.xz")
    add_versions("2.4.118", "a777bd85f2b5fc9c57f886c82058300578317cafdbc77d0a769d7e9a9567ab88")

    add_deps("meson", "ninja")
    add_includedirs("include", "include/libdrm")
    add_extsources("pkgconfig::libdrm", "pacman::libdrm", "apt::libdrm-dev")
    on_install("linux", function (package)
        local configs = {"-Dudev=true", "-Dvalgrind=disabled", "-Dman-pages=disabled", "-Dtests=false", "-Dcairo-tests=disabled", "-Dinstall-test-programs=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("drmAvailable", {includes = "xf86drm.h"}))
    end)
