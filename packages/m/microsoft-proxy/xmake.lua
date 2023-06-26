package("microsoft-proxy")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/microsoft/proxy")
    set_description("Proxy: Easy Polymorphism in C++")
    set_license("MIT")

    add_urls("https://github.com/microsoft/proxy/archive/refs/tags/$(version).tar.gz",
             "https://github.com/microsoft/proxy.git")

    add_versions("1.1.1", "6852b135f0bb6de4dc723f76724794cff4e3d0d5706d09d0b2a4f749f309055d")

    on_install(function (package)
        os.cp("proxy.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("proxy.h", {configs = {languages = "c++20"}}))
    end)
