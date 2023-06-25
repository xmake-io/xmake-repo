package("libaio")

    set_homepage("https://pagure.io/libaio")
    set_description("Linux-native asynchronous I/O access library")
    set_license("LGPL-2.1-or-later")

    set_urls("https://pagure.io/libaio/archive/libaio-$(version)/libaio-libaio-$(version).tar.gz",
             "https://pagure.io/libaio.git")
    add_versions("0.3.113", "716c7059703247344eb066b54ecbc3ca2134f0103307192e6c2b7dab5f9528ab")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    on_install("linux", function (package)
        io.replace("Makefile", "prefix=/usr", "prefix=" .. package:installdir())
        import("package.tools.make").make(package, {})
        import("package.tools.make").make(package, {"install"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("io_setup", {includes = "libaio.h"}))
    end)
