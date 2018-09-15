package("libmill")

    set_homepage("http://libmill.org")
    set_description("Go-style concurrency in C")

    set_urls("http://libmill.org/libmill-$(version).tar.gz")

    add_versions("1.18", "12e538dbee8e52fd719a9a84004e0aba9502a6e62cd813223316a1e45d49577d")
    add_versions("1.17", "ada513275d8d5a2ce98cdbc47ad491bfb10f5e9a5429656e539a5889f863042d")

    if is_host("windows") then
        add_deps("cmake")
    end

    on_build("windows", function (package)
        import("package.builder.cmake").build(package)
    end)

    on_install("windows", function (package)
        import("package.builder.cmake").install(package)
    end)

    on_build("macosx", "linux", function (package)
        os.vrun("./configure --prefix=%s", package:installdir())
        os.vrun("make")
    end)

    on_install("macosx", "linux", function (package)
        os.vrun("make install")
    end)

