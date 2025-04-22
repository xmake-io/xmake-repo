package("strong_type")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/rollbear/strong_type")
    set_description("An additive strong typedef library for C++14/17/20.")
    set_license("BSL-1.0")

    add_urls("https://github.com/rollbear/strong_type/archive/refs/tags/$(version).tar.gz",
             "https://github.com/rollbear/strong_type.git")

    add_versions("v15", "d445398d4c4d6795060ac2b60be146b3cd7e6039985244b2d56f9bc333f20bae")

    add_deps("cmake")
    on_install(function (package)
        import("package.tools.cmake").install(package, {"-DSTRONG_TYPE_UNIT_TEST=OFF"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets("using myint = strong::type<int, struct my_int_>;", {configs = {languages = "c++14"}, includes = "strong_type/strong_type.hpp"}))
    end)
