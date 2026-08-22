package("argp-standalone")

    set_homepage("https://github.com/argp-standalone/argp-standalone")
    set_description("Standalone version of arguments parsing functions from GLIBC")
    set_license("LGPL-2.1-or-later")

    add_urls("https://github.com/argp-standalone/argp-standalone/archive/refs/tags/$(version).tar.gz",
             "https://github.com/argp-standalone/argp-standalone.git")
    add_versions("1.5.0", "c29eae929dfebd575c38174f2c8c315766092cec99a8f987569d0cad3c6d64f6")

    add_deps("libintl")

    on_install("macosx", "android", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        os.cp(path.join(package:scriptdir(), "port", "config.h.in"), "config.h.in")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("argp_parse", {includes = "argp.h"}))
    end)
