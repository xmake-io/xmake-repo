package("libxkbcommon")
    set_homepage("https://xkbcommon.org/")
    set_description("keymap handling library for toolkits and window systems")
    set_license("MIT")

    add_urls("https://github.com/xkbcommon/libxkbcommon/archive/refs/tags/xkbcommon-$(version).tar.gz",
             "https://github.com/xkbcommon/libxkbcommon.git")

    add_versions("1.0.3", "5d10a57ab65daad7d975926166770eca1d2c899131ab96c23845df1c42da5c31")
    add_versions("1.8.1", "c65c668810db305c4454ba26a10b6d84a96b5469719fe3c729e1c6542b8d0d87")

    if is_plat("linux") then
        add_extsources("apt::libxkbcommon-dev")
    end

    add_configs("x11", {description = "Enable backend to X11 (default is false).", default = false, type = "boolean"})
    add_configs("wayland", {description = "Enable backend to X11 (default is true).", default = true, type = "boolean"})
    add_configs("tools", {description = "Enable xkbcommon binaries.", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("x11") then
            package:add("deps", "libxcb", "xcb-proto", "libxml2", "libxau", "libxdmcp", { configs = { shared = package:config("shared") }})
            if package:is_plat("linux") then
                package:add("extsources", "pacman::libxkbcommon-x11", "apt::libxkbcommon-x11-dev")
            end
        end

        if package:config("wayland") then
            package:add("deps", "wayland", { configs = { shared = package:config("shared") }})
            package:add("deps", "wayland-protocols")
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
            "-Dxkb-config-root=/usr/share/X11/xkb",
            "-Dx-locale-root=/usr/share/X11/locale",
            format("-Denable-tools=%s", package:config("tools")),
            format("-Denable-bash-completion=%s", package:config("tools")),
            format("-Denable-x11=%s", package:config("x11")),
            format("-Denable-wayland=%s", package:config("wayland")),
            format("-Dbash-completion-path=%s", path.join(package:installdir(), "share", "bash-completion", "completions"))
        }
        local c_link_args = "-lm"
        -- fix undefined reference to XauGetBestAuthByAddr on linux
        if package:config("x11") then
            for _, dep in ipairs(package:orderdeps()) do
                local fetchinfo = dep:fetch()
                if fetchinfo then
                    for _, linkdir in ipairs(fetchinfo.linkdirs) do
                        c_link_args = c_link_args .. " -L" .. linkdir
                    end
                    for _, link in ipairs(fetchinfo.links) do
                        c_link_args = c_link_args .. " -l" .. link
                    end
                end
            end
        end
        table.insert(configs, "-Dc_link_args=" .. c_link_args)
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("xkb_context_new", {includes = "xkbcommon/xkbcommon.h"}))
    end)
