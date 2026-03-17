package("expected-lite")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/martinmoene/expected-lite")
    set_description("expected lite - Expected objects in C++11 and later in a single-file header-only library")
    set_license("BSL-1.0")

    add_urls("https://github.com/martinmoene/expected-lite/archive/refs/tags/$(version).tar.gz",
             "https://github.com/martinmoene/expected-lite.git")

    add_versions("v0.10.0", "cfe082e4ffedeeedac47763504102646a39c080599c7c1fe99299d6a1f99af92")
    add_versions("v0.9.0", "e1b3ac812295ef8512c015d8271204105a71957323f8ab4e75f6856d71b8868d")
    add_versions("v0.8.0", "27649f30bd9d4fe7b193ab3eb6f78c64d0f585c24c085f340b4722b3d0b5e701")
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
