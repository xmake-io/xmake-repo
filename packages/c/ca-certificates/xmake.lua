package("ca-certificates")

    set_kind("library", {headeronly = true})
    set_homepage("https://mkcert.org/")
    set_description("Mozilla’s carefully curated collection of Root Certificates for validating the trustworthiness of SSL certificates while verifying the identity of TLS hosts.")

    add_urls("https://github.com/xmake-mirror/xmake-cacert/archive/refs/tags/$(version).zip")
    add_versions("20211118", "5d8b1f11d5c746d5af425063ba1f4acee4b18c681e7df2050f1b81cef079c227")
    add_versions("20220604", "a56ded4677055bbf05d94c32bddd76b22a134cab764e1ed8da8e3c080ca80ca6")
    add_versions("20230306", "f9228e16c17b411de9d592e43242b4405568daad029380b2db7e3e4227d5a6a6")

    on_install(function (package)
        os.cp("cacert.pem", package:installdir())
        package:addenv("SSL_CERT_DIR", package:installdir())
        package:addenv("SSL_CERT_FILE", path.join(package:installdir(), "cacert.pem"))
    end)

    on_test(function (package)
        assert(os.isfile(path.join(package:installdir(), "cacert.pem")))
    end)
