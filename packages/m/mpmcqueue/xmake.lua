package("mpmcqueue")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/rigtorp/MPMCQueue")
    set_description("A bounded multi-producer multi-consumer concurrent queue written in C++11")

    add_urls("https://github.com/rigtorp/MPMCQueue/archive/refs/tags/$(version).tar.gz",
             "https://github.com/rigtorp/MPMCQueue.git")
    add_versions("v1.0", "f009ef10b66f2b8bc6e3a4f50577efbdfea0c163464cd7de368378f173007b75")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("rigtorp::mpmc::Queue<int>", {configs = {languages = "c++14"}, includes = "rigtorp/MPMCQueue.h"}))
    end)
