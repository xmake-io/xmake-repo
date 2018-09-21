package("openssl")

    set_homepage("https://www.openssl.org/")
    set_description("A robust, commercial-grade, and full-featured toolkit for TLS and SSL.")

    add_urls("https://www.openssl.org/source/openssl-$(version).tar.gz", {alias = "home"})
    add_urls("https://github.com/openssl/openssl/archive/OpenSSL_$(version).zip", 
            {alias = "github", version = function (version) return version:gsub("%.", "_") end})

    add_versions("home:1.1.1", "2836875a0f89c03d0fdf483941512613a50cfb421d6fd94b9f41d7279d586a3d")
    add_versions("github:1.1.1", "7da8c193d3828a0cb4d866dc75622b2aac392971c3d656f7817fb84355290343")

    on_build("linux", "macosx", function (package)
        os.vrun("./config --prefix=%s %s", package:installdir(), is_mode("debug") and "--debug" or "")
        os.vrun("make")
    end)

    on_install("linux", "macosx", function (package)
        os.vrun("make install")
    end)
