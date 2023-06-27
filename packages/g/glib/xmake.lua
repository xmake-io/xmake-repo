package("glib")

    set_homepage("https://developer.gnome.org/glib/")
    set_description("Core application library for C.")

    set_urls("https://github.com/GNOME/glib/archive/refs/tags/$(version).tar.gz",
             "https://gitlab.gnome.org/GNOME/glib/-/archive/$(version)/glib-$(version).tar.gz",
             "https://gitlab.gnome.org/GNOME/glib.git")
    add_versions("2.71.0", "10cdfa2893b7ccf6a95b25644ec51e2c609274a5af3ad8e743d6dc35434fdf11")
    add_patches("2.71.0", path.join(os.scriptdir(), "patches", "2.71.0", "macosx.patch"), "a0c928643e40f3a3dfdce52950486c7f5e6f6e9cfbd76b20c7c5b43de51d6399")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})
    end

    add_deps("meson", "ninja", "libffi", "pcre")
    if is_plat("linux") then
        add_deps("libiconv")
    elseif is_plat("windows", "macosx") then
        add_deps("libintl")
    end

    add_includedirs("include/glib-2.0", "lib/glib-2.0/include")
    add_links("gio-2.0", "gobject-2.0", "gthread-2.0", "gmodule-2.0", "glib-2.0", "intl")
    if is_plat("macosx") then
        add_syslinks("iconv")
        add_frameworks("Foundation", "CoreFoundation")
        add_extsources("brew::glib")
    elseif is_plat("linux") then
        add_syslinks("pthread", "dl", "resolv")
        add_extsources("apt::libglib2.0-dev", "pacman::glib2")
    end

    if on_fetch then
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
    end

    on_install("windows", "macosx", "linux", "cross", function (package)
        import("package.tools.meson")
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
        elseif package:is_plat("windows") then
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
        local envs = meson.buildenvs(package)
        if package:is_plat("windows") then
            for _, dep in ipairs(package:orderdeps()) do
                local fetchinfo = dep:fetch()
                if fetchinfo then
                    for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                        envs.INCLUDE = (envs.INCLUDE or "") .. path.envsep() .. includedir
                    end
                    for _, linkdir in ipairs(fetchinfo.linkdirs) do
                        envs.LIB = (envs.LIB or "") .. path.envsep() .. linkdir
                    end
                end
            end
        end
        meson.install(package, configs, {envs = envs})
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        assert(package:has_cfuncs("g_list_append", {includes = "glib.h"}))
    end)
