package("boost_interval")
    set_kind("library", {headeronly = true})
    set_homepage("http://boost.org/libs/numeric/interval/doc")
    set_description("interval: Boost.org numeric interval library")

    add_urls("https://github.com/boostorg/interval/archive/refs/tags/boost-$(version).tar.gz")

    add_versions("1.83.0", "64a9bba500c95f085b52c5c62870fe7b0613550e")

    add_deps("boost_limits")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
           #include <boost/numeric/interval.hpp>

            void test() {
                boost::numeric::interval<double> x = 1.0;
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
