package("talloc")

    set_homepage("https://talloc.samba.org/talloc/doc/html/index.html")
    set_description("talloc is a hierarchical, reference counted memory pool system with destructors.")

    add_urls("https://www.samba.org/ftp/talloc/talloc-$(version).tar.gz")
    add_versions("2.3.3", "6be95b2368bd0af1c4cd7a88146eb6ceea18e46c3ffc9330bf6262b40d1d8aaa")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    add_deps("python 3.x", {kind = "binary"})
    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package, {"--disable-python"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("talloc_init", {includes = "talloc.h"}))
    end)
