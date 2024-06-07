package("itlib")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/iboB/itlib")
    set_description("A collection of std-like single-header C++ libraries")
    set_license("MIT")

    add_urls("https://github.com/iboB/itlib/archive/refs/tags/$(version).tar.gz",
             "https://github.com/iboB/itlib.git")

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
