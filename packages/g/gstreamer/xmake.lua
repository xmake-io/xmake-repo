package("gstreamer")
    set_homepage("https://gstreamer.freedesktop.org")
    set_description("GStreamer is a development framework for creating applications like media players, video editors, streaming media broadcasters and so on")
    set_license("LGPL-2.0-or-later")

    add_urls("https://gstreamer.freedesktop.org/src/gstreamer/gstreamer-$(version).tar.xz", {alias = "home"})
    -- add_urls("https://github.com/GStreamer/gstreamer/archive/refs/tags/$(version).tar.gz", {alias = "github"})

    add_versions("home:1.22.8", "ad4e3db1771139b1db17b1afa7c05db083ae0100bd4da244b71f162dcce41bfc")
    -- add_versions("github:1.22.8", "ebe085820a32f135d9a5a3442b2cb2238d8ce1d3bc66f4d6bfbc11d0873dbecc")

    add_configs("libunwind", {description = "Use libunwind to generate backtraces", default = false, type = "boolean"})

    if is_plat("linux") then
        add_extsources("pacman::gstreamer", "apt::libgstreamer1.0-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::gstreamer")
    elseif is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::gstreamer")
    end

    add_deps("meson", "ninja")
    add_deps("glib")
    if is_plat("windows") then
        add_deps("winflexbison")
    else
        add_deps("flex", "bison")
    end

    add_includedirs("include", "include/gstreamer-1.0")

    on_load(function (package)
        if package:config("libunwind") then
            package:add("deps", "libunwind")
        end
    end)

    on_install("windows", "macosx", "linux", "cross", function (package)
        local configs = {
            "-Dtools=disabled",
            "-Dexamples=disabled",
            "-Dbenchmarks=disabled",
            "-Dtests=disabled",
        }
        table.insert(configs, "-Dgst_debug=" .. (package:is_debug() and "true" or "false"))
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Dlibunwind=" .. (package:config("libunwind") and "enabled" or "disabled"))
        local packagedeps = {}
        if not package:dep("glib"):config("shared") then
            table.insert(packagedeps, "libiconv")
        end
        if package:is_plat("macosx") then
            table.insert(packagedeps, "libintl")
        end
        import("package.tools.meson").install(package, configs, {packagedeps = packagedeps})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gst_init", {includes = "gst/gst.h"}))
    end)
