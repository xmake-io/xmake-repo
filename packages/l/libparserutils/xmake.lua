package("libparserutils")
    set_homepage("https://www.netsurf-browser.org/projects/libparserutils")
    set_description("LibParserUtils is a library for building efficient parsers")
    set_license("MIT")

    set_urls("https://source.netsurf-browser.org/libparserutils.git/snapshot/libparserutils-release/$(version).tar.bz2",
             "https://git.netsurf-browser.org/libparserutils.git")

    add_versions("0.2.5", "816f0cb3281c6f6a6cc974ba00c3975fe91ab1425125aa9af64903065d2a36ec")

    add_patches("0.2.5", "patches/0.2.5/uninitialised-variable.patch", "1f9f6b7e0444f1bcb4e13684cc5e3660d33ab30db5e7d995e7644bc8b3fda3ff")

    on_load(function (package)
        if is_subhost("windows") and not package:is_precompiled() then
            package:add("deps", "strawberry-perl")
        end
    end)

    on_install(function (package)
        os.cd(package:version_str())
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("parserutils_error_to_string", {includes = "parserutils/parserutils.h"}))
    end)
