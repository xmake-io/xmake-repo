package("libuv")

    set_homepage("http://libuv.org/")
    set_description("A multi-platform support library with a focus on asynchronous I/O.")

    set_urls("https://github.com/libuv/libuv/archive/$(version).zip",
             "https://github.com/libuv/libuv.git")
    add_versions("v1.23.1", "fc0de9d02cc09eb00c576e77b29405daca5ae541a87aeb944fee5360c83b9f4c")
    add_versions("v1.23.0", "ffa1aacc9e8374b01d1ff374b1e8f1e7d92431895d18f8e9d5e59a69a2a00c30")
    add_versions("v1.22.0", "1e8e51531732f8ef5867ae3a40370814ce2e4e627537e83ca519d40b424dced0")

    if is_host("windows") then
        add_deps("cmake")
    else
        add_deps("autoconf", "automake", "libtool", "pkg-config")
    end

    on_install("windows|x86", function (package)
        import("package.tools.cmake").install(package)
        os.cp("include", package:installdir())
    end)

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package)
    end)
