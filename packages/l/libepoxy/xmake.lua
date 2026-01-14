package("libepoxy")
    set_homepage("https://download.gnome.org/sources/libepoxy/")
    set_description("Epoxy is a library for handling OpenGL function pointer management for you.")
    set_license("MIT")

    add_urls("https://github.com/anholt/libepoxy.git")
    add_urls("https://github.com/anholt/libepoxy/archive/refs/tags/$(version).tar.gz", {alias = "github"})
    add_urls("https://download.gnome.org/sources/libepoxy/$(version).tar.xz", {
        alias = "gnome",
        version = function (version)
            return format("%d.%d/libepoxy-%s", version:major(), version:minor(), version)
        end
    })

    add_versions("github:1.5.10", "a7ced37f4102b745ac86d6a70a9da399cc139ff168ba6b8002b4d8d43c900c15")

    add_versions("gnome:1.5.10", "072cda4b59dd098bba8c2363a6247299db1fa89411dc221c8b81b8ee8192e623")
    add_versions("gnome:1.5.9", "d168a19a6edfdd9977fef1308ccf516079856a4275cf876de688fb7927e365e4")

    add_configs("glx", {description = "Enable GLX support", default = false, type = "boolean"})
    add_configs("x11", {description = "Enable X11 support", default = false, type = "boolean"})
    add_configs("egl", {description = "Enable EGL support", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    if is_plat("linux") then
        add_extsources("apt::libepoxy-dev")
    end

    add_deps("meson", "ninja")
    if is_subhost("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end

    on_load(function (package)
        if package:config("egl") then
            package:add("deps", "egl-headers")
        end
        if package:config("x11") then
            package:add("deps", "libx11")
        end
    end)

    on_install("!android and !bsd", function (package)
        if package:is_plat("windows") and not package:config("shared") then
            io.replace("include/epoxy/common.h", "__declspec(dllimport)", "", {plain = true})
        end
        if package:config("egl") then
            io.replace("meson.build", "dependency('egl', required: false)", "dependency('egl-headers', required: false)", {plain = true})
        end

        local configs = {"-Dtests=false"}
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Dglx=" .. (package:config("glx") and "yes" or "no"))
        table.insert(configs, "-Dx11=" .. (package:config("x11") and "true" or "false"))
        table.insert(configs, "-Degl=" .. (package:config("egl") and "yes" or "no"))
        import("package.tools.meson").install(package, configs)

        local pc = package:installdir("lib/pkgconfig/epoxy.pc")
        io.replace(pc, "Requires.private: egl", "Requires.private: egl-headers", {plain = true})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("epoxy_gl_version", {includes = "epoxy/gl.h"}))
    end)
