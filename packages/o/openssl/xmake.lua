package("openssl")

    set_homepage("https://www.openssl.org/")
    set_description("A robust, commercial-grade, and full-featured toolkit for TLS and SSL.")

    add_urls("https://www.openssl.org/source/openssl-$(version).tar.gz", {alias = "home", excludes = "*/fuzz/*"})
    add_urls("https://github.com/openssl/openssl/archive/OpenSSL_$(version).zip", 
            {alias = "github", version = function (version) return version:gsub("%.", "_") end, excludes = "*/fuzz/*"})

    add_versions("home:1.1.1", "2836875a0f89c03d0fdf483941512613a50cfb421d6fd94b9f41d7279d586a3d")
    add_versions("home:1.0.2", "8c48baf3babe0d505d16cfc0cf272589c66d3624264098213db0fb00034728e9")
    add_versions("home:1.0.0", "1bbf9afc5a6215121ac094147d0a84178294fe4c3d0a231731038fd3717ba7ca")
    add_versions("github:1.1.1", "7da8c193d3828a0cb4d866dc75622b2aac392971c3d656f7817fb84355290343")
    add_versions("github:1.0.2", "b61942861405c634f86ca2b8dd1a34687e24b5036598d0fa971fac02405fdb1a")
    add_versions("github:1.0.0", "9b67e5ad1a4234c1170ada75b66321e914da4f3ebaeaef6b28400173aaa6b378")

    on_install("linux", "macosx", function (package)
        os.vrun("./config %s --prefix=\"%s\"", package:debug() and "--debug" or "", package:installdir())
        os.vrun("make -j4")
        os.vrun("make install")
    end)
 
    on_test(function (package)
        assert(package:has_cfuncs("SSL_new", {includes = "openssl/ssl.h"}))
    end)
