package("libxkbcommon")

    set_homepage("https://xkbcommon.org/")
    set_description("keymap handling library for toolkits and window systems")
    set_license("MIT")

    add_urls("https://github.com/xkbcommon/libxkbcommon/archive/xkbcommon-$(version).tar.gz",
             "https://github.com/xkbcommon.git")
    add_versions("1.0.3", "5d10a57ab65daad7d975926166770eca1d2c899131ab96c23845df1c42da5c31")

    add_configs("x11", {description = "Switch backend to X11 (default is wayland).", default = false, type = "boolean"})
    on_load("linux", function (package)
        if package:config("x11") then
            package:add("deps", "libxcb", "xcb-proto", "libxml2")
        else
            package:add("deps", "wayland")
        end
    end)

    add_deps("meson")
    on_install("linux", function (package)
        package:addenv("PATH", "bin")

        -- add links
        local arch = package:is_arch("x86_64", "x64") and "x86_64" or "x86"
        package:add("linkdirs", path.join("lib", arch .. "-linux-gnu"))
        package:add("links", "xkbregistry", "xkbcommon")
        os.mv(package:installdir("lib", arch .. "-linux-gnu", "pkgconfig"), package:installdir("lib"))

        -- build
        local configs = {"-Denable-docs=false", "-Dc_link_args=-lm"}
        if package:config("x11") then
            table.join2(configs, {"-Denable-wayland=false", "-Dxkb-config-root=/usr/share/X11/xkb", "-Dx-locale-root=/usr/share/X11/locale"})
        else
            table.join2(configs, {"-Denable-x11=false", "-Dxkb-config-root=/usr/share/X11/xkb", "-Dx-locale-root=/usr/share/X11/locale"})
        end
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xkb_context_new", {includes = "xkbcommon/xkbcommon.h"}))
    end)
