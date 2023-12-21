package("alsa-lib")
    set_homepage("https://alsa-project.org/wiki/Main_Page")
    set_description("The Advanced Linux Sound Architecture (ALSA) provides audio and MIDI functionality to the Linux operating system.")
    set_license("LGPL-2.1")

    add_urls("http://www.alsa-project.org/files/pub/lib/alsa-lib-$(version).tar.bz2", {alias = "home"})
    add_urls("https://github.com/alsa-project/alsa-lib/archive/refs/tags/v$(version).tar.gz", {alias = "github"})
    add_versions("home:1.2.10", "c86a45a846331b1b0aa6e6be100be2a7aef92efd405cf6bac7eef8174baa920e")
    add_versions("github:1.2.10", "f55749847fd98274501f4691a2d847e89280c07d40a43cdac43d6443f69fc939")

    add_configs("versioned", {description = "pass flag --without-versioned", default = true, type = "boolean"})

    if is_plat("linux") then
        add_extsources("pacman::alsa-lib", "apt::libasound2-dev")
    end

    if not is_plat("windows") then
        add_deps("autoconf", "automake", "libtool", "m4")
    end

    on_install("linux", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:is_debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:config("versioned")then
            table.insert(configs, "--without-versioned")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("snd_pcm_open", {includes = "alsa/asoundlib.h"}))
    end)
