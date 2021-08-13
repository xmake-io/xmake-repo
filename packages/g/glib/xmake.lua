package("glib")

    set_homepage("https://developer.gnome.org/glib/")
    set_description("Core application library for C.")

    set_urls("https://download.gnome.org/sources/glib/$(version).tar.xz",
             {version = function (version) return table.concat(table.slice((version):split('%.'), 1, 2), '.') .. "/glib-" .. version end})
    add_versions("2.60.2", "2ef15475060addfda0443a7e8a52b28a10d5e981e82c083034061daf9a8f80d9")
    add_versions("2.68.2", "ecc7798a9cc034eabdfd7f246e6dd461cdbf1175fcc2e9867cc7da7b7309e0fb")

    add_deps("meson", "ninja", "libffi", "pcre")
    if is_plat("linux") then
        add_deps("libiconv")
    elseif is_plat("macosx") then
        add_deps("gettext")
    end

    add_includedirs("include/glib-2.0", "lib/glib-2.0/include")
    add_links("gobject-2.0", "glib-2.0", "gio-2.0", "gthread-2.0", "gmodule-2.0", "intl")
    if is_plat("macosx") then
        add_syslinks("iconv")
        add_frameworks("Foundation", "CoreFoundation")
    elseif is_plat("linux") then
        add_syslinks("pthread", "dl")
    end

    if on_fetch then
        on_fetch("macosx", "linux", function (package, opt)
            if opt.system and package.find_package then
                -- TODO gobject, gmodule ...
                return package:find_package("pkgconfig::glib-2.0")
            end
        end)
    end

    on_install("macosx", "linux", function (package)
        local configs = {"-Dbsymbolic_functions=false",
                         "-Ddtrace=false",
                         "-Dman=false",
                         "-Dtests=false",
                         "-Ddefault_library=static",
                         "-Dlibmount=disabled",
                         "-Dinstalled_tests=false"}
        if package:is_plat("macosx") and package:version():le("2.61.0") then
            table.insert(configs, "-Diconv=native")
        end
        table.insert(configs, "-Dgio_module_dir=" .. path.join(package:installdir(), "lib/gio/modules"))
        table.insert(configs, "--libdir=lib")
        io.gsub("meson.build", "subdir%('tests'%)", "")
        io.gsub("meson.build", "subdir%('fuzzing'%)", "")
        io.gsub("gio/meson.build", "subdir%('tests'%)", "")
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("g_list_append", {includes = "glib.h"}))
    end)
