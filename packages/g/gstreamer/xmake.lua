package("gstreamer")
    set_homepage("https://gstreamer.freedesktop.org")
    set_description("GStreamer is a development framework for creating applications like media players, video editors, streaming media broadcasters and so on")
    set_license("LGPL-2.0-or-later")

    add_urls("https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-$(version).tar.xz", {alias = "home"})
    -- add_urls("https://github.com/GStreamer/gstreamer/archive/refs/tags/$(version).tar.gz", {alias = "github"})

    add_versions("home:1.22.8", "ad4e3db1771139b1db17b1afa7c05db083ae0100bd4da244b71f162dcce41bfc")
    -- add_versions("github:1.22.8", "ebe085820a32f135d9a5a3442b2cb2238d8ce1d3bc66f4d6bfbc11d0873dbecc")

    add_deps("meson", "ninja")
    add_deps("glib")
    if is_plat("windows") then
        add_deps("winflexbison")
    else
        add_deps("flex", "bison")
    end

    on_install(function (package)
        local configs = {
            "-Dtools=disabled",
            "-Dexamples=disabled",
            "-Dbenchmarks=disabled",
            "-Dtests=disabled",
        }
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gst_init", {includes = "gst/gst.h"}))
    end)
