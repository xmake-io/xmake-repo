package("boost_math")
    set_kind("library", {headeronly = true})
    set_homepage("https://www.boost.org/libs/math")
    set_description("Boost Math Library")
    set_license("BSL-1.0")

    add_defines("BOOST_MATH_STANDALONE")

    add_urls("https://github.com/boostorg/math/archive/refs/tags/boost-$(version).tar.gz",
             "https://github.com/boostorg/math.git")

    add_versions("1.90.0", "7d043e9ef0ac4b2242debc55a6fcd63fdcee1f09e8b695d19a73fbc23506356d")
    add_versions("1.89.0", "1981aae64deba30df31965671d2aaaecf701bfc96a4bd5b44dd3bd88e1c247a4")
    add_versions("1.88.0", "bb753392c3908292da46034a5435107f9e0546fda54da4d47b438aff5e4d9c48")
    add_versions("1.87.0", "33bc8bebff5e0f929397b84b52afbe9d0202d7b4ca68dc6516b08acba5edf023")
    add_versions("1.86.0", "c99287823d4b163e0c58df642557f1aaf2948e9b2f08211ff8c4f5ca1146ef8e")
    add_versions("1.85.0", "a6a82e2650b9bd9bf724430cb743f17e1ca12e08c98cfa2b9098128357b13848")
    add_versions("1.84.0", "8c98eea939158bcdc5f857a10f590aae836b7f35b55d5bb695343e1f5cc0bd93")
    add_versions("1.83.0", "53e5f7539a66899fe0fca3080405cbd5f7959da5394ec13664746741aece1705")
    add_versions("1.82.0", "6fc799a50081e8215553c8076b84b9b5c1c7f7bdf9d5b14773a4be03018e9eb7")
    add_versions("1.81.0", "cef18e59017b231456bba74cda89f993ae5e54f9a2682f220fbdb7bcce804148")
    add_versions("1.80.0", "0f47bbe0479ded85670e1b1b021eda0c03f36181bd35417757e4f519616f7f13")
    add_versions("1.79.0", "04645521ee93c810cfc71632b97856b9c0322b0215ec47319967382b18a12063")

    on_install(function (package)
        os.cp("include/boost", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <boost/math/quadrature/tanh_sinh.hpp>
            #include <cassert>
            #include <cmath>
            void test() {
            boost::math::quadrature::tanh_sinh<double> integrator;
            double result = integrator.integrate([](double x) { return x; });
            assert(std::abs(result) < 1e-8);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
