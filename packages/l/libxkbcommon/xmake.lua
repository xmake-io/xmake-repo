package("libxkbcommon")
    set_homepage("https://xkbcommon.org/")
    set_description("keymap handling library for toolkits and window systems")
    set_license("MIT")

    add_urls("https://github.com/xkbcommon/libxkbcommon/archive/refs/tags/xkbcommon-$(version).tar.gz",
             "https://github.com/xkbcommon/libxkbcommon.git")
    add_versions("1.7.0", "20d5e40dabd927f7a7f4342bebb1e8c7a59241283c978b800ae3bf60394eabc4")
    add_versions("1.0.3", "5d10a57ab65daad7d975926166770eca1d2c899131ab96c23845df1c42da5c31")

    if is_plat("linux") then
        add_extsources("apt::libxkbcommon-dev")
    end

    add_configs("x11", {description = "Enable backend to X11 (default is false).", default = false, type = "boolean"})
    add_configs("wayland", {description = "Enable backend to Wayland (default is true).", default = true, type = "boolean"})

    on_load(function (package)
        if package:config("x11") then
            package:add("deps", "libxcb", "xcb-proto", "libxml2")
            if package:is_plat("linux") then
                package:add("extsources", "pacman::libxkbcommon-x11")
            end
        end

        if package:config("wayland") then
            package:add("deps", "wayland", "wayland-protocols")
            if package:is_plat("linux") then
                package:add("extsources", "pacman::libxkbcommon")
            end
        end
    end)

    add_deps("meson", "ninja", "pkg-config")

    on_install("linux|native", function (package)
        local configs = {
            "-Denable-docs=false",
            "-Dc_link_args=-lm",
            "-Dxkb-config-root=/usr/share/X11/xkb",
            "-Dx-locale-root=/usr/share/X11/locale"
        }
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Denable-x11=" .. (package:config("x11") and "true" or "false"))
        table.insert(configs, "-Denable-wayland=" .. (package:config("wayland") and "true" or "false"))
        import("package.tools.meson").install(package, configs)

        package:addenv("PATH", "bin")
        package:addenv("PKG_CONFIG_PATH", path.join("lib", "pkgconfig"))
    end)

    on_test(function (package)
        assert(package:check_importfiles("pkgconfig::xkbcommon"))
        assert(package:has_cfuncs("xkb_context_new", {includes = "xkbcommon/xkbcommon.h"}))
    end)
