package("pulseaudio")
    set_homepage("https://www.freedesktop.org/wiki/Software/PulseAudio/")
    set_description("A featureful, general-purpose sound server")
    set_license("LGPL-2.1-or-later")

    add_urls("https://github.com/pulseaudio/pulseaudio/archive/refs/tags/$(version).tar.gz",
             "https://github.com/pulseaudio/pulseaudio.git")
    add_versions("v17.0", "ed36c8a0cdff7b57382a258d3e1a916f42500fbafd64dd3c2e258ed8f017ee90")

    add_extsources("pkgconfig::libpulse")
    if is_plat("linux") then
        add_extsources("pacman::libpulse", "apt::libpulse-dev")
    end

    add_deps("meson", "ninja")
    if is_plat("linux") then
        add_deps("alsa-lib")
    end
    add_deps("dbus", "fftw", "glib", "jack2", "libatomic_ops", "libiconv", "libsndfile", "openssl3", "soxr", "speex")

    on_install("linux", function (package)
        if package:version() then
            local v = package:version_str():gsub("v", "")
            io.writefile(".tarball-version", v)
            os.rm("git-version-gen")
            io.replace("meson.build",
                "run_command(find_program('git-version-gen'), join_paths(meson.current_source_dir(), '.tarball-version'), check : false).stdout().strip()",
                "'" .. v .. "'", {plain = true})
        end
        local configs = {
            "-Dgstreamer=disabled",

            "-Ddaemon=false",
            "-Dclient=true",
            "-Ddoxygen=false",
            "-Dgcov=false",
            "-Dman=false",
            "-Dtests=false",
            "-Dbashcompletiondir=no",
            "-Dzshcompletiondir=no",

            "-Dasyncns=disabled",
            "-Davahi=disabled",
            "-Dbluez5=disabled",
            "-Dconsolekit=disabled",
            "-Ddbus=enabled",
            "-Delogind=disabled",
            "-Dfftw=enabled",
            "-Dglib=enabled",
            "-Dgsettings=disabled",
            "-Dgtk=disabled",
            "-Dhal-compat=false",
            "-Dipv6=true",
            "-Djack=enabled",
            "-Dlirc=enabled",
            "-Dopenssl=enabled",
            "-Dorc=disabled",

            "-Dsoxr=enabled",
            "-Dspeex=enabled",
            "-Dsystemd=disabled",
            "-Dtcpwrap=disabled",
            "-Dudev=disabled",
            "-Dvalgrind=disabled",
            "-Dx11=disabled",

            "-Dadrian-aec=false",
            "-Dwebrtc-aec=disabled"
        }

        table.insert(configs, "-Dalsa=" .. (package:is_plat("linux") and "enabled" or "disabled"))
        table.insert(configs, "-Doss-output=" .. (package:is_plat("linux") and "enabled" or "disabled"))

        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pa_simple_new", {includes = "pulse/simple.h"}))
    end)
