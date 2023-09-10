package("libsndio")
    set_homepage("https://sndio.org")
    set_description("Sndio is a small audio and MIDI framework part of the OpenBSD project and ported to FreeBSD, Linux and NetBSD")

    set_urls("https://sndio.org/sndio-$(version).tar.gz")

    add_versions("1.9.0", "f30826fc9c07e369d3924d5fcedf6a0a53c0df4ae1f5ab50fe9cf280540f699a")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    if is_plat("linux") then
        add_deps("alsa-lib")
    end

    on_install("linux", "bsd", "macosx", function (package)
        import("package.tools.autoconf")
        local configs = {}
        local buildenvs = autoconf.buildenvs(package, {packagedeps = "alsa-lib"})
        autoconf.configure(package, configs, {envs = buildenvs})
        os.vrunv("make", {}, {envs = buildenvs})
        os.vrunv("make", {"install"}, {envs = buildenvs})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sio_open", {includes = "sndio.h"}))
    end)
