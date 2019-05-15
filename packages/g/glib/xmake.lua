package("glib")

    set_homepage("https://developer.gnome.org/glib/")
    set_description("Core application library for C.")

    set_urls("https://download.gnome.org/sources/glib/$(version).tar.xz",
             {version = function (version) return table.concat(table.slice((version):split('%.'), 1, 2), '.') .. "/glib-" .. version end})
    add_versions("2.60.2", "2ef15475060addfda0443a7e8a52b28a10d5e981e82c083034061daf9a8f80d9")

    add_deps("meson", "ninja", "libffi", "pcre")
    if is_plat("linux") then
        add_deps("libiconv")
    end

    add_includedirs("include/glib-2.0", "lib/glib-2.0/include")
    add_links("glib-2.0", "gio-2.0", "gobject-2.0", "gthread-2.0", "gmodule-2.0", "intl")
    if is_plat("macosx") then
        add_syslinks("iconv")
        add_frameworks("Foundation", "CoreFoundation")
    elseif is_plat("linux") then
        add_syslinks("pthread", "dl")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"-Dbsymbolic_functions=false", 
                         "-Ddtrace=false", 
                         "-Dman=false", 
                         "-Ddefault_library=static", 
                         "-Dlibmount=false",
                         "-Dinstalled_tests=false"}
        if is_plat("macosx") then
            table.insert(configs, "-Diconv=native")
        end
        table.insert(configs, "-Dgio_module_dir=" .. path.join(package:installdir(), "lib/gio/modules"))
        if is_plat("linux") then
            table.insert(configs, "--libdir=" .. package:installdir("lib"))
        end
        io.gsub("meson.build", "subdir%('tests'%)", "")
        io.gsub("meson.build", "subdir%('fuzzing'%)", "")
        io.gsub("gio/meson.build", "subdir%('tests'%)", "")
        import("package.tools.meson").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("g_list_append", {includes = "glib.h"}))
    end)
