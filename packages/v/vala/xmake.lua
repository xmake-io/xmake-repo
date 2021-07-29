package("vala")

    set_kind("toolchain")
    set_homepage("https://wiki.gnome.org/Projects/Vala")
    set_description("Compiler for the GObject type system")
    set_license("LGPL-2.1-or-later")

    add_urls("https://download.gnome.org/sources/vala/$(version).tar.xz", {version = function (version)
        return version:major() .. "." .. version:minor() .. "/vala-" .. version
    end})
    add_versions("0.52.4", "ecde520e5160e659ee699f8b1cdc96065edbd44bbd08eb48ef5f2506751fdf31")

    if is_plat("macosx", "linux") then
        add_deps("gettext", "glib", "pkg-config")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--disable-dependency-tracking", "--disable-silent-rules"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        os.vrun("valac --version")
    end)
