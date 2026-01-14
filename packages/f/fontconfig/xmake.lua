package("fontconfig")
    set_homepage("https://www.freedesktop.org/wiki/Software/fontconfig/")
    set_description("A library for configuring and customizing font access.")
    set_license("MIT")

    add_urls("https://gitlab.freedesktop.org/fontconfig/fontconfig/-/archive/$(version)/fontconfig-$(version).tar.gz",
             "https://gitlab.freedesktop.org/fontconfig/fontconfig.git")

    add_versions("2.17.1", "82e73b26adad651b236e5f5d4b3074daf8ff0910188808496326bd3449e5261d")

    -- fix the build issue with --enable-static
    add_patches("2.13.1", "https://gitlab.freedesktop.org/fontconfig/fontconfig/commit/8208f99fa1676c42bfd8d74de3e9dac5366c150c.diff",
                          "2abdff214b99f2d074170e6512b0149cc858ea26cd930690aa6b4ccea2c549ef")

    add_configs("nls", {description = "Enable Native Language Support (NLS)", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("meson", "ninja", "gperf", "python 3.x", {kind = "binary"})
    if is_subhost("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end

    add_deps("freetype", "expat")

    on_load(function (package)
        if package:config("nls") and not package:is_plat("linux") then
            package:add("deps", "libintl")
        end
        if package:is_plat("linux") and (package:version() and package:version():lt("2.13.91")) then
            package:add("deps", "util-linux", {configs = {libuuid = true}})
            package:add("deps", "autotools", "bzip2")
        end
    end)

    on_install(function (package)
        if package:is_plat("windows") then
            io.replace("meson.build", "c_args = []", "c_args = ['-DXML_STATIC']", {plain = true})
        end

        local configs = {
            "-Dtests=disabled",
            "-Ddoc=disabled",
        }
        table.insert(configs, "-Ddebug=" .. (package:is_debug() and "true" or "false"))
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Dnls=" .. (package:config("nls") and "enabled" or "disabled"))
        table.insert(configs, "-Dtools=" .. (package:config("tools") and "enabled" or "disabled"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("FcInitLoadConfigAndFonts", {includes = "fontconfig/fontconfig.h"}))
    end)
