package("stlab")

    set_kind("library", {headeronly = true})
    set_homepage("https://stlab.cc/")
    set_description("Adobe Source Libraries from Software Technology Lab")
    set_license("BSL-1.0")

    add_urls("https://github.com/stlab/libraries/archive/refs/tags/$(version).tar.gz",
             "https://github.com/stlab/libraries.git")
    add_versions("v2.2.0", "5ada2db5216d733657c981917778a137a1c34d711d2a96d7958038bdb475c041")
    add_versions("v1.6.2", "d0369d889c7bf78068d0c4f4b5125d7e9fe9abb0ad7a3be35bf13b6e2c271676")

    add_deps("cmake")
    add_deps("boost")
    on_install("windows", "macosx", "linux", function (package)
        import("package.tools.cmake").install(package, {"-Dstlab.testing=OFF", "-Dstlab.coverage=OFF"})
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("stlab::forest<char>", {configs = {languages = "c++17"}, includes = "stlab/forest.hpp"}))
    end)
