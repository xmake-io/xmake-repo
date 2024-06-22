package("bredis")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/basiliscos/cpp-bredis")
    set_description("Boost::ASIO low-level redis client (connector)")
    set_license("MIT")

    add_urls("https://github.com/basiliscos/cpp-bredis/archive/refs/tags/$(version).tar.gz",
             "https://github.com/basiliscos/cpp-bredis.git")

    add_versions("v0.12", "c5a6aa58835d5ef8cd97c4ae7e677f6237ef4ee01ae4a609293e2351c01db6cc")

    add_deps("boost")

    on_install("macosx", "linux", "windows", "bsd", "mingw", "cross", function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("bredis::bredis_category", {configs = {languages = "c++11"}, includes = "bredis/Connection.hpp"}))
    end)
