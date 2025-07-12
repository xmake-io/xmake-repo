package("stlab")

    set_kind("library", {headeronly = true})
    set_homepage("https://stlab.cc/")
    set_description("Adobe Source Libraries from Software Technology Lab")
    set_license("BSL-1.0")

    add_urls("https://github.com/stlab/libraries/archive/refs/tags/$(version).tar.gz",
             "https://github.com/stlab/libraries.git")
    add_versions("v2.0.1", "82096293cf8fbb8eb4b20818b96522491fa03798a9a7ff48b2d922c95fa118f3")
    add_versions("v1.6.2", "d0369d889c7bf78068d0c4f4b5125d7e9fe9abb0ad7a3be35bf13b6e2c271676")

    add_deps("cmake")
    add_deps("boost")
    on_install("windows", "macosx", "linux", function (package)
        import("package.tools.cmake").install(package, {"-Dstlab.testing=OFF", "-Dstlab.coverage=OFF"})
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("stlab::forest<char>", {configs = {languages = "c++17"}, includes = "stlab/forest.hpp"}))
    end)
