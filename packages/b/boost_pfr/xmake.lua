package("boost_pfr")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/boostorg/pfr")
    set_description("C++14 library for struct reflection")
    set_license("BSL-1.0")

    add_urls("https://github.com/boostorg/pfr/archive/refs/tags/$(version).tar.gz",
             "https://github.com/boostorg/pfr.git")

    add_versions("2.2.0", "6f490ec1383de5855dcf801c23f0a967f888eb6e1440b6ca0bf36c12d4ae7ac7")
    add_versions("2.1.0", "7c18a4ab73b70f8b3513fa3a836c6f4310f627bbf55f62b89bdd7aa787c7da31")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <boost/pfr.hpp>
            struct foo { int a; float b; };
            void test() {
                foo f{1, 2.0f};
                boost::pfr::for_each_field(f, [](auto&& field) { field += 1; });
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
