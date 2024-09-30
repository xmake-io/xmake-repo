package("libdom")
    set_homepage("https://www.netsurf-browser.org/projects/libdom")
    set_description("LibDOM is an implementation of the W3C DOM")
    set_license("MIT")

    set_urls("https://source.netsurf-browser.org/libdom.git/snapshot/libdom-release/$(version).tar.bz2",
             "https://git.netsurf-browser.org/libdom.git")

    add_versions("0.4.2", "dc3c00c78abe981f701cdd4dd610c44e154fa8981515d53d91b82690d80b8f98")

    add_deps("expat", "libhubbub", "libparserutils", "libwapcaplet")

    on_install(function (package)
        os.cd(package:version_str())
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("dom_namespace_finalise", {includes = "dom/dom.h"}))
    end)
