package("babl")
    set_homepage("https://gegl.org/babl/")
    set_description("A pixel encoding and color space conversion engine.")
    set_license("LGPL-3.0-or-later")

    add_urls("https://ftp.fau.de/gimp/babl/$(version).tar.xz", {version = function (version)
        return format("%d.%d/babl-%s", version:major(), version:minor(), version)
    end})

    add_versions("0.1.110", "bf47be7540d6275389f66431ef03064df5376315e243d0bab448c6aa713f5743")

    add_configs("lcms", {description = "Build with lcms", default = false, type = "boolean"})

    add_deps("meson", "ninja")

    on_load(function (package)
        if package:config("lcms") then
            package:add("deps", "lcms")
        end
    end)

    on_install(function (package)
        local configs = {"-Dwith-docs=false", "-Denable-gir=false", "-Denable-vapi=false", "-Dgi-docgen=disabled"}
        table.insert(configs, "-Dwith-lcms=" .. (package:config("lcms") and "true" or "false"))
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("babl_init", {includes = "babl/babl.h"}))
    end)
