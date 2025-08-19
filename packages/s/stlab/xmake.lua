package("stlab")

    set_kind("library", {headeronly = true})
    set_homepage("https://stlab.cc/")
    set_description("Adobe Source Libraries from Software Technology Lab")
    set_license("BSL-1.0")

    add_urls("https://github.com/stlab/libraries/archive/refs/tags/$(version).tar.gz",
             "https://github.com/stlab/libraries.git")
    add_versions("v2.0.2", "d2496dbdb3884746c374798e1f145224995712f1ad437145cd73f0b8494ea3a4")
    add_versions("v1.6.2", "d0369d889c7bf78068d0c4f4b5125d7e9fe9abb0ad7a3be35bf13b6e2c271676")

    add_deps("cmake")
    add_deps("boost")
    on_install("windows", "macosx", "linux", function (package)
        import("package.tools.cmake").install(package, {"-Dstlab.testing=OFF", "-Dstlab.coverage=OFF"})
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("stlab::forest<char>", {configs = {languages = "c++17"}, includes = "stlab/forest.hpp"}))
    end)
