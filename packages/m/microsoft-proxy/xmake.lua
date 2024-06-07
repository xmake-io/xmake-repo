package("microsoft-proxy")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/microsoft/proxy")
    set_description("Proxy: Easy Polymorphism in C++")
    set_license("MIT")

    add_urls("https://github.com/microsoft/proxy/archive/refs/tags/$(version).tar.gz",
             "https://github.com/microsoft/proxy.git")

    add_versions("2.4.0", "7eed973655938d681a90dcc0c200e6cc1330ea8611a9c1a9e1b30439514443cb")
    add_versions("2.3.0", "ff6f17c5360895776d29ce2b1235de7b42912468b52729810506431e352a78d0")
    add_versions("2.2.1", "096f0b2d793dffc54d41def2bca0ced594b6b8efe35ac5ae27db35802e742b96")
    add_versions("1.1.1", "6852b135f0bb6de4dc723f76724794cff4e3d0d5706d09d0b2a4f749f309055d")

    on_install(function (package)
        os.cp("proxy.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("proxy.h", {configs = {languages = "c++20"}}))
    end)
