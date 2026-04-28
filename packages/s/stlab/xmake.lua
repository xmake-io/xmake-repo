package("stlab")

    set_kind("library", {headeronly = true})
    set_homepage("https://stlab.cc/")
    set_description("Adobe Source Libraries from Software Technology Lab")
    set_license("BSL-1.0")

    add_urls("https://github.com/stlab/libraries/archive/refs/tags/$(version).tar.gz",
             "https://github.com/stlab/libraries.git")
    add_versions("v2.3.0", "22ec971dff4b4ffdc331bc31d243b50583e17a78abc284021bb22064cba8aa9c")
    add_versions("v1.6.2", "d0369d889c7bf78068d0c4f4b5125d7e9fe9abb0ad7a3be35bf13b6e2c271676")

    add_deps("cmake")
    add_deps("boost")
    on_install("windows", "macosx", "linux", function (package)
        if package:version() and package:version():eq("2.3.0") then
            io.replace("include/stlab/CMakeLists.txt", "iterator/set_next.hpp\n", "iterator/set_next.hpp\niterator/concepts.hpp\n", {plain = true})
            io.replace("cmake/stlab/development/MSVC.cmake", "/WX # Treat warnings as errors", "", {plain = true})
        end
        import("package.tools.cmake").install(package, {"-Dstlab.testing=OFF", "-Dstlab.coverage=OFF"})
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("stlab::forest<char>", {configs = {languages = "c++17"}, includes = "stlab/forest.hpp"}))
    end)
