package("libmill")

    set_homepage("http://libmill.org")
    set_description("Go-style concurrency in C")

    set_urls("http://libmill.org/libmill-$(version).tar.gz")

    add_versions("1.18", "12e538dbee8e52fd719a9a84004e0aba9502a6e62cd813223316a1e45d49577d")
    add_versions("1.17", "ada513275d8d5a2ce98cdbc47ad491bfb10f5e9a5429656e539a5889f863042d")

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package)
    end)

