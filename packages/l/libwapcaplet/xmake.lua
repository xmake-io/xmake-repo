package("libwapcaplet")
    set_homepage("https://www.netsurf-browser.org/projects/libwapcaplet")
    set_description("LibWapcaplet is a string internment library")
    set_license("MIT")

    set_urls("https://source.netsurf-browser.org/libwapcaplet.git/snapshot/libwapcaplet-release/$(version).tar.bz2",
             "https://git.netsurf-browser.org/libwapcaplet.git")

    add_versions("0.4.3", "641e2a3e02069a0c724b8d862fcda5ab87a67e879f30a2e87af1b10b9f3c3498")

    on_install(function (package)
        os.cd(package:version_str())
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lwc_intern_string", {includes = "libwapcaplet/libwapcaplet.h"}))
    end)
