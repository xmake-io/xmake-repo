package("named_type")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/joboccara/NamedType")
    set_description("Implementation of strong types in C++.")
    set_license("MIT")

    add_urls("https://github.com/joboccara/NamedType.git")

    add_versions("v1.1.0.20210209", "c119054eac4b8f3599233ff480ad1ce4309a52ad")

    on_install(function (package)
        os.cp("include/NamedType", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("fluent::NamedType<int, struct TestTag>", {configs = {languages = "c++14"}, includes = "NamedType/named_type.hpp"}))
    end)
