package("expected-lite")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/martinmoene/expected-lite")
    set_description("expected lite - Expected objects in C++11 and later in a single-file header-only library")
    set_license("BSL-1.0")

    add_urls("https://github.com/martinmoene/expected-lite/archive/refs/tags/$(version).tar.gz",
             "https://github.com/martinmoene/expected-lite.git")

    add_versions("v0.6.3", "b2f90d5f03f6423ec67cc3c06fd0c4e813ec10c4313062b875b37d17593b57b4")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <nonstd/expected.hpp>
            nonstd::expected<int, std::string> test() {
                return 0;
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
