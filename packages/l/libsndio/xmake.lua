package("libsndio")
    set_homepage("https://sndio.org")
    set_description("Sndio is a small audio and MIDI framework part of the OpenBSD project and ported to FreeBSD, Linux and NetBSD")

    set_urls("https://sndio.org/sndio-$(version).tar.gz")

    add_versions("1.9.0", "f30826fc9c07e369d3924d5fcedf6a0a53c0df4ae1f5ab50fe9cf280540f699a")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    add_deps("libsoundio")

    on_install("linux", "bsd", "macosx", function (package)
        local configs = {}
        import("package.tools.autoconf").install(package, configs, {packagedeps = "libsoundio"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sio_open", {includes = "sndio.h"}))
    end)
