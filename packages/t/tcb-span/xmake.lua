package("tcb-span")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/tcbrindle/span")
    set_description("Implementation of C++20's std::span for older compilers")
    set_license("BSL-1.0")

    add_urls("https://github.com/tcbrindle/span.git")

    add_versions("2022.06.15", "836dc6a0efd9849cb194e88e4aa2387436bb079b")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("tcb/span.hpp", {configs = {languages = "c++11"}}))
    end)
