package("libsvgtiny")
    set_homepage("https://www.netsurf-browser.org/projects/libsvgtiny")
    set_description("Libsvgtiny is a library for parsing SVG files for display.")
    set_license("MIT")

    set_urls("https://source.netsurf-browser.org/libsvgtiny.git/snapshot/libsvgtiny-release/$(version).tar.bz2",
             "git://git.netsurf-browser.org/libsvgtiny.git")

    add_versions("0.1.8", "e9e772d3b8e17f26dae26d53187b42e146be9b53632c81e601a60bf9a6ec92a6")

    add_deps("gperf")
    add_deps("libdom")

    on_install(function (package)
        os.cd(package:version_str())
        io.replace("src/svgtiny.c", "calloc(sizeof(*diagram), 1);", "calloc(1, sizeof(*diagram));", {plain = true})

        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("svgtiny_create", {includes = {"stddef.h", "svgtiny.h"}}))
    end)
