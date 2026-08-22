package("boost_throw_exception")
    set_kind("library", {headeronly = true})
    set_homepage("https://www.boost.org/libs/throw_exception")
    set_description("Boost ThrowException Library")
    set_license("BSL-1.0")

    add_urls("https://github.com/boostorg/throw_exception/archive/refs/tags/boost-$(version).tar.gz",
             "https://github.com/boostorg/throw_exception.git")

    add_versions("1.91.0", "bba826d1380ccedbcf0468ae4b74012ac14c3830be30d9174fbaf8583b56ed67")
    add_versions("1.90.0", "30e2834ba64587a363750e35c627ee045f89be05d0cc9eab7251414eba88e110")
    add_versions("1.89.0", "7deb2dc859f608355e583747183d323d256bc4dd3230fc5958272e7dce5d1551")

    add_deps("boost_config", "boost_assert")

    on_install(function (package)
        os.cp("include/boost", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <boost/throw_exception.hpp>
            #include <stdexcept>
            void test() {
                try {
                    BOOST_THROW_EXCEPTION(std::runtime_error("oops"));
                } catch (...) {
                }
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
