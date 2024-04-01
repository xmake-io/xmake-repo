package("rtm")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/nfrechette/rtm")
    set_description("Realtime Math")
    set_license("MIT")

    add_urls("https://github.com/nfrechette/rtm/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nfrechette/rtm.git")

    add_versions("v2.3.1", "a16fc698feca580533fa12c92fe7d1df4f341f807df7ec314274659fdfec11fb")
    add_versions("v2.3.0", "2b5f2c3761bb52ae89802a574e9dc9949aec3b183f7e100b9b66a65adcc6f5ab")
    add_versions("v2.1.5", "afb05cb00b59498756ca197028de291a1960e58d5f6fcad161d8240682481eae")

    on_install("linux", "macosx", "windows", function (package)
        os.cp("includes/rtm", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("rtm::vector4d", {configs = {languages = "c++11"}, includes = "rtm/types.h"}))
    end)
