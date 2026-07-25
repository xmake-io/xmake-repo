package("boost_type_traits")
    set_kind("library", {headeronly = true})
    set_homepage("https://www.boost.org/libs/type_traits")
    set_description("Boost TypeTraits Library")
    set_license("BSL-1.0")

    add_urls("https://github.com/boostorg/type_traits/archive/refs/tags/boost-$(version).tar.gz",
             "https://github.com/boostorg/type_traits.git")

    add_versions("1.91.0", "e6e60d56fc2f1d7d67411690be7044e4a0441da4c20191d5d8ca15e0050f95b0")
    add_versions("1.90.0", "d8f1f937a56dacbd5bd3067312896f3b2b84ddf7cbeb93f21e1ffd844e512587")
    add_versions("1.89.0", "228a0dfdf69f60c4eb9ba47c98a358d3163a65b45e9c338793b87df8dba269c0")

    add_deps("boost_config", "boost_static_assert")

    on_install(function (package)
        os.cp("include/boost", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <boost/type_traits/is_integral.hpp>
            static_assert(boost::is_integral<int>::value, "");
            void test() {}
        ]]}, {configs = {languages = "c++17"}}))
    end)
