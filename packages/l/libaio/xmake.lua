package("libaio")

    set_homepage("https://codeberg.org/jmoyer/libaio")
    set_description("Linux-native asynchronous I/O access library")
    set_license("LGPL-2.1-or-later")

    add_urls("https://codeberg.org/jmoyer/libaio/archive/libaio-$(version).tar.gz",
             "https://codeberg.org/jmoyer/libaio.git")

    add_versions("0.3.113", "bb4807cc5fd5320242e286be2372597851fa0a23e14d4386cf045d3fcef0d8d9")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    on_install("linux", function (package)
        io.replace("Makefile", "prefix=/usr", "prefix=" .. package:installdir())
        import("package.tools.make").make(package, {})
        import("package.tools.make").make(package, {"install"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("io_setup", {includes = "libaio.h"}))
    end)
