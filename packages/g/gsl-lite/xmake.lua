package("gsl-lite")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/gsl-lite/gsl-lite")
    set_description("gsl-lite – A single-file header-only version of ISO C++ Guidelines Support Library (GSL) for C++98, C++11, and later")
    set_license("MIT")

    add_urls("https://github.com/gsl-lite/gsl-lite/archive/refs/tags/$(version).tar.gz",
             "https://github.com/gsl-lite/gsl-lite.git")

    add_versions("v0.42.0", "54a1b6f9db72eab5d8dcaf06b36d32d4f5da3471d91dac71aba19fe15291a773")
    add_versions("v0.41.0", "4682d8a60260321b92555760be3b9caab60e2a71f95eddbdfb91e557ee93302a")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <gsl/gsl-lite.hpp>
            void test(gsl::not_null<int*> p) {}
        ]]}, {configs = {languages = "c++11"}}))
    end)
