package("glib")

    set_homepage("https://docs.gtk.org/glib/")
    set_description("Low-level core library that forms the basis for projects such as GTK+ and GNOME.")
    set_license("LGPL-2.1")

    add_urls("https://download.gnome.org/sources/glib/$(version).tar.xz", {alias = "home", version = function (version)
        return format("%d.%d/glib-%s", version:major(), version:minor(), version)
    end, excludes = {"*/COPYING"}})
    add_urls("https://gitlab.gnome.org/GNOME/glib/-/archive/$(version)/glib-$(version).tar.gz", {alias = "gitlab"})
    add_urls("https://gitlab.gnome.org/GNOME/glib.git")
    add_versions("home:2.71.0", "926816526f6e4bba9af726970ff87be7dac0b70d5805050c6207b7bb17ea4fca")
    add_versions("home:2.78.1", "915bc3d0f8507d650ead3832e2f8fb670fce59aac4d7754a7dab6f1e6fed78b2")
    add_patches("2.71.0", path.join(os.scriptdir(), "patches", "2.71.0", "macosx.patch"), "a0c928643e40f3a3dfdce52950486c7f5e6f6e9cfbd76b20c7c5b43de51d6399")

    add_deps("meson", "ninja", "libffi", "zlib")
    if is_plat("linux") then
        add_deps("libiconv")
    elseif is_plat("macosx") then
        add_deps("libiconv", {system = true})
        add_deps("libintl")
    elseif is_plat("windows") then
        add_deps("libintl", "pkgconf")
    end

    add_includedirs("include/glib-2.0", "lib/glib-2.0/include")
    add_links("gio-2.0", "gobject-2.0", "gthread-2.0", "gmodule-2.0", "glib-2.0")

    if is_plat("windows") then
        add_syslinks("user32", "shell32", "ole32", "ws2_32", "shlwapi", "iphlpapi", "dnsapi")
    elseif is_plat("macosx") then
        add_syslinks("resolv")
        add_frameworks("AppKit", "Foundation", "CoreServices", "CoreFoundation")
        add_extsources("brew::glib")
    elseif is_plat("linux") then
        add_syslinks("pthread", "dl", "resolv")
        add_extsources("apt::libglib2.0-dev", "pacman::glib2")
    end

    on_fetch("macosx", "linux", function (package, opt)
        if opt.system and package.find_package then
            local result
            for _, name in ipairs({"gio-2.0", "gobject-2.0", "gthread-2.0", "gmodule-2.0", "glib-2.0"}) do
                local pkginfo = package.find_package and package:find_package("pkgconfig::" .. name, opt)
                if pkginfo then
                    if not result then
                        result = table.copy(pkginfo)
                    else
                        local includedirs = pkginfo.sysincludedirs or pkginfo.includedirs
                        result.links = table.wrap(result.links)
                        result.linkdirs = table.wrap(result.linkdirs)
                        result.includedirs = table.wrap(result.includedirs)
                        table.join2(result.includedirs, includedirs)
                        table.join2(result.linkdirs, pkginfo.linkdirs)
                        table.join2(result.links, pkginfo.links)
                    end
                end
            end
            return result
        end
    end)

    on_load(function (package)
        if package:gitref() or package:version():ge("2.74.0") then
            package:add("deps", "pcre2")
        else
            package:add("deps", "pcre")
        end
    end)

    on_install("windows", "macosx", "linux", "cross", function (package)
        local configs = {"-Dbsymbolic_functions=false",
                         "-Ddtrace=false",
                         "-Dman=false",
                         "-Dgtk_doc=false",
                         "-Dtests=false",
                         "-Dinstalled_tests=false",
                         "-Dsystemtap=false",
                         "-Dselinux=disabled",
                         "-Dlibmount=disabled"}
        if package:is_plat("macosx") and package:version():le("2.61.0") then
            table.insert(configs, "-Diconv=native")
        elseif package:is_plat("windows") and package:version():le("2.74.0") then
            table.insert(configs, "-Diconv=external")
        end
        table.insert(configs, "-Dglib_debug=" .. (package:debug() and "enabled" or "disabled"))
        table.insert(configs, "-Ddefault_library=" .. (package:config("shared") and "shared" or "static"))
        table.insert(configs, "-Dgio_module_dir=" .. path.join(package:installdir(), "lib/gio/modules"))
        io.gsub("meson.build", "subdir%('tests'%)", "")
        io.gsub("meson.build", "subdir%('fuzzing'%)", "")
        io.gsub("gio/meson.build", "subdir%('tests'%)", "")
        io.replace("meson.build", "glib_conf.set('HAVE_SELINUX', selinux_dep.found())", "", {plain = true})
        if package:is_plat("windows") then
            io.gsub("meson.build", "dependency%('libffi',", "dependency('libffi', modules: ['libffi::ffi'],")
        end
        import("package.tools.meson").install(package, configs, {packagedeps = {"libintl", "libiconv", "libffi", "zlib"}})
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("g_list_append", {includes = "glib.h"}))
    end)
