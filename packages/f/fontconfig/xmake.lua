package("fontconfig")

    set_homepage("https://www.freedesktop.org/wiki/Software/fontconfig/")
    set_description("A library for configuring and customizing font access.")

    set_urls("https://www.freedesktop.org/software/fontconfig/release/fontconfig-$(version).tar.gz")
    add_versions("2.13.1", "9f0d852b39d75fc655f9f53850eb32555394f36104a044bb2b2fc9e66dbbfa7f")
    add_versions("2.13.93", "0f302a18ee52dde0793fe38b266bf269dfe6e0c0ae140e30d72c6cca5dc08db5")
    add_versions("2.13.94", "246d1640a7e54fba697b28e4445f4d9eb63dda1b511d19986249368ee7191882")
    add_versions("2.14.0", "b8f607d556e8257da2f3616b4d704be30fd73bd71e367355ca78963f9a7f0434")
    add_versions("2.14.2", "3ba2dd92158718acec5caaf1a716043b5aa055c27b081d914af3ccb40dce8a55")

    -- fix the build issue with --enable-static
    add_patches("2.13.1", "https://gitlab.freedesktop.org/fontconfig/fontconfig/commit/8208f99fa1676c42bfd8d74de3e9dac5366c150c.diff",
                          "2abdff214b99f2d074170e6512b0149cc858ea26cd930690aa6b4ccea2c549ef")

    add_configs("nls", {description = "Enable Native Language Support (NLS)", default = false, type = "boolean"})

    add_deps("meson", "ninja", "freetype", "expat")
    add_deps("python 3.x", {kind = "binary"})
    if is_plat("linux") then
        add_deps("pkg-config")
    end

    on_load("windows", "linux", "macosx", function (package)
        if package:config("nls") and not package:is_plat("linux") then
            package:add("deps", "libintl")
        end
        if package:is_plat("linux") and package:version():lt("2.13.91") then
            package:add("deps", "util-linux", {configs = {libuuid = true}})
            package:add("deps", "autoconf", "automake", "libtool", "gperf", "bzip2")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        if package:is_plat("windows") then
            io.replace("meson.build", "c_args = []", "c_args = ['-DXML_STATIC']", {plain = true})
        end
        local configs = {
            "-Dtests=disabled",
            "-Dtools=disabled",
            "-Ddoc=disabled"}
        table.insert(configs, "-Ddebug=" .. (package:debug() and "true" or "false"))
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Dnls=" .. (package:config("nls") and "enabled" or "disabled"))
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("FcInitLoadConfigAndFonts", {includes = "fontconfig/fontconfig.h"}))
    end)
