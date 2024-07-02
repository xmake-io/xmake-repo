package("interface99")
    set_kind("library", { headeronly = true })
    set_homepage("https://github.com/Hirrolot/interface99")
    set_description("Full-featured interfaces for C99")
    set_license("MIT")

    add_urls("https://github.com/Hirrolot/interface99/archive/refs/tags/v$(version).tar.gz",
        "https://github.com/Hirrolot/interface99.git")

    add_versions("1.0.0", "578c7e60fde4ea1c7fd3515e444c6a2e62a9095dac979516c0046a8ed008e3b2")
    add_versions("1.0.1", "ddc7cd979cf9c964a4313a5e6bdc87bd8df669142f29c8edb71d2f2f7822d9aa")

    add_deps("metalang99")

    on_install(function(package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function(package)
        assert(package:has_cincludes("interface99.h"))
    end)
