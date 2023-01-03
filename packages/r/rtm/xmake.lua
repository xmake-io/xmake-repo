package("rtm")
    set_homepage("https://github.com/nfrechette/rtm")
    set_description("Realtime Math")
    set_license("MIT")

    add_urls("https://github.com/nfrechette/rtm/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nfrechette/rtm.git")
    add_versions("v2.1.5", "afb05cb00b59498756ca197028de291a1960e58d5f6fcad161d8240682481eae")

    on_install("linux", "macosx", "windows", function (package)
        os.cp("includes", path.join(package:installdir(), "include"))
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("rtm::vector4d", {includes = "rtm/types.h"}))
    end)
