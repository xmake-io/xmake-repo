package("libxkbcommon")
    set_homepage("https://xkbcommon.org/")
    set_description("keymap handling library for toolkits and window systems")
    set_license("MIT")

    add_urls("https://github.com/xkbcommon/libxkbcommon/archive/refs/tags/xkbcommon-$(version).tar.gz",
             "https://github.com/xkbcommon/libxkbcommon.git")

    add_versions("1.0.3", "5d10a57ab65daad7d975926166770eca1d2c899131ab96c23845df1c42da5c31")

    if is_plat("linux") then
        add_extsources("apt::libxkbcommon-dev")
    end

    add_configs("x11", {description = "Enable backend to X11 (default is false).", default = false, type = "boolean"})
    add_configs("wayland", {description = "Enable backend to X11 (default is true).", default = true, type = "boolean"})

    on_load(function (package)
        if package:config("x11") then
            package:add("deps", "libxcb", "xcb-proto", "libxml2")
            if package:is_plat("linux") then
                package:add("extsources", "pacman::libxkbcommon-x11")
            end
        end

        if package:config("wayland") then
            package:add("deps", "wayland")
            if package:is_plat("linux") then
                package:add("extsources", "pacman::libxkbcommon")
            end
        end
    end)

    add_deps("meson", "ninja")

    on_install("linux", function (package)
        package:addenv("PATH", "bin")
        local configs = {
            "-Denable-docs=false",
            "-Dc_link_args=-lm",
            "-Dxkb-config-root=/usr/share/X11/xkb",
            "-Dx-locale-root=/usr/share/X11/locale",
            format("-Denable-x11=%s", package:config("x11")),
            format("-Denable-wayland=%s", package:config("wayland"))
        }

        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xkb_context_new", {includes = "xkbcommon/xkbcommon.h"}))
    end)
