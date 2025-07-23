package("mapbox_variant")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/mapbox/variant")
    set_description("C++11/C++14 Variant")
    set_license("BSD")

    set_urls("https://github.com/mapbox/variant/archive/f87fcbda9daf13fba47a6a889696b0ad23fc098d.tar.gz",
             "https://github.com/mapbox/variant/archive/refs/tags/$(version).tar.gz",
             "https://github.com/mapbox/variant.git")

    add_versions("2020.12.02", "1c158fb10da5605060950eb8d2a87a3313d29e558576e35fd445653d863a0103")
    add_versions("v1.2.0", "7059f4420d504c4bc96f8a462a0f6d029c5be914ba55cc030a0a773366dd7bc8")

    on_install(function (package)
        os.cp("include/mapbox", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            struct Result {};
            struct Error
            {
                unsigned int code;
            };

            using Response = mapbox::util::variant<Result, Error>;
          
            void test()
            {
                Response ret = Result {};
                ret.match([] (const Result& r) { },
                          [] (const Error& e)  { });

            }
        ]]}, {configs = {languages = "c++14"}, includes = { "mapbox/variant.hpp"} }))
    end)
