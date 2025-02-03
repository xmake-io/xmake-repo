package("itlib")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/iboB/itlib")
    set_description("A collection of std-like single-header C++ libraries")
    set_license("MIT")

    add_urls("https://github.com/iboB/itlib/archive/refs/tags/$(version).tar.gz",
             "https://github.com/iboB/itlib.git")

    add_versions("v1.11.5", "bc78b8f514dbeff2cb5a7d50dff5bc30c148ca23095838d54e6431828341fd5d")
    add_versions("v1.11.4", "09b155afcb9766fe36d0156294f6656956189235612eb7711903ebc22079c37e")
    add_versions("v1.11.1", "2c60e02660ea63dfb7a39237e29b30a066670cef228d22e8d0908e1fff2fa7f1")
    add_versions("v1.11.0", "871a96989b36560934ed86939e38ce8ff0a5a44303ed489dbde6444985702c73")
    add_versions("v1.10.3", "e533c44354d48b2251ca57f1502778033b38170d9d6aba6bb2bbad90f2bf9d27")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <itlib/static_vector.hpp>
            void test() {
                itlib::static_vector<int, 10> ivec;
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
