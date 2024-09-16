package("nodepp")
    set_kind("library", {headeronly = true})
    set_homepage("https://plaid-aspiring-line.glitch.me/")
    set_description("Nodepp | Asynchronous C++ like Javascript")
    set_license("MIT")

    add_urls("https://github.com/NodeppOficial/nodepp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/NodeppOficial/nodepp.git")

    add_versions("0.0.1", "9807e3ff230d08e20eab60ab942f6d0b1c66236c21594a738296d7a9513965f6")

    add_deps("openssl", "zlib")

    on_install("windows", "linux", "macosx", "bsd", "mingw", "cross", "android", function (package)
        os.vcp("include", package:installdir())
        os.vcp("ssl", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("nodepp/http.h", {configs = {languages = "c++11"}}))
        assert(package:has_cxxincludes("nodepp/date.h", {configs = {languages = "c++11"}}))
    end)
