package("libva")
    set_homepage("https://01.org/linuxmedia")
    set_description("Libva is an implementation for VA-API (Video Acceleration API)")

    add_urls("https://github.com/intel/libva/archive/refs/tags/$(version).tar.gz",
             "https://github.com/intel/libva.git")

    add_versions("2.21.0", "f7c3fffef3f04eb146e036dad2587d852bfb70e4926d014bf437244915ef7425")

    add_configs("win32", {description = "Build with win32", default = false, type = "boolean"})
    add_configs("drm", {description = "Build with drm", default = false, type = "boolean"})
    add_configs("x11", {description = "Build with x11", default = false, type = "boolean"})
    add_configs("wayland", {description = "Build with wayland", default = false, type = "boolean"})
    add_configs("glx", {description = "Build with glx", default = false, type = "boolean"})

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    if is_plat("linux") then
        add_syslinks("dl")
    end

    add_deps("meson", "ninja")

    on_load(function (package)
        if is_host("windows") or package:is_plat("mingw", "msys") then
            package:config_set("win32", true)
        elseif not (package:config("drm") or package:config("x11") or package:config("wayland")) then
            wprint("Please enable at least one backend (DRM, X11, Wayland), defalut x11")
            package:config_set("x11", true)
        end

        if package:config("drm") or is_plat("linux") then
            package:add("deps", "libdrm")
        end
        if package:config("x11") then
            package:add("deps", "libx11", "libxext", "libxfixes")
        end
        if package:config("wayland") then
            package:add("deps", "wayland")
        end
    end)

    on_install("windows", "linux", "mingw", "msys", function (package)
        local configs = {}
        table.insert(configs, "-Ddisable_drm=" .. (package:config("drm") and "false" or "true"))
        table.insert(configs, "-Dwith_win32=" .. (package:config("win32") and "yes" or "no"))
        table.insert(configs, "-Dwith_x11=" .. (package:config("x11") and "yes" or "no"))
        table.insert(configs, "-Dwith_wayland=" .. (package:config("wayland") and "yes" or "no"))
        table.insert(configs, "-Dwith_glx=" .. (package:config("glx") and "yes" or "no"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("vaDisplayIsValid", {includes = "va/va.h"}))
    end)
