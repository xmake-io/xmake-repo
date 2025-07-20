package("jack2")
    set_homepage("https://jackaudio.org/")
    set_description("Cross-platform API that enables device sharing and inter-application audio routing")
    set_license("GPL-2.0")

    add_urls("https://github.com/jackaudio/jack2/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jackaudio/jack2.git")

    add_versions("v1.9.22", "1e42b9fc4ad7db7befd414d45ab2f8a159c0b30fcd6eee452be662298766a849")

    on_install(function (package)
        os.cp(path.join(package:scriptdir(), "port", "jack.def"), "jack.def")
        io.writefile("xmake.lua", [[
            add_rules("mode.release", "mode.debug")
            add_languages("c11")

            option("version", {description = "Set the version"})
            set_version(get_config("version"))
            option("dl")
                set_showmenu(false)
                add_links("dl")

            target("jack")
                set_kind("$(kind)")
                add_includedirs("common")
                add_files("common/JackWeakAPI.c")
                add_headerfiles("common/(jack/*.h)")
                add_options("dl")
                if is_plat("windows") and is_kind("shared") then
                    add_files("jack.def")
                end
        ]])
        import("package.tools.xmake").install(package, {version = package:version()})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("jack_get_version_string", {includes = "jack/jack.h"}))
    end)
