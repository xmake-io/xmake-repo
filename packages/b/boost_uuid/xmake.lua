package("boost_uuid")
    set_kind("library", {headeronly = true})
    set_homepage("https://www.boost.org/libs/uuid")
    set_description("A universally unique identifier (UUID) is a 128-bit number used to uniquely identify some object or entity on the Internet.")
    set_license("BSL-1.0")

    add_urls("https://github.com/boostorg/uuid/archive/refs/tags/boost-$(version).tar.gz",
             "https://github.com/boostorg/uuid.git")

    add_versions("1.91.0", "2cfe4dda2d987eb51cb28d71212aa0afdbff96bbef584d92f758422a604bcf59")
    add_versions("1.90.0", "855801530b6dd3ec932296d275dc84cd5517049979126e01469c85456bfca29e")
    add_versions("1.89.0", "144790a4f61fa1c94ca743287bcf293bb514efda8544cdf53e9698d0f05ee4bc")

    add_deps("boost_config", "boost_assert", "boost_throw_exception", "boost_type_traits")

    on_install(function (package)
        os.cp("include/boost", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <boost/uuid/uuid.hpp>
            #include <boost/uuid/uuid_generators.hpp>
            #include <boost/uuid/uuid_io.hpp>
            #include <sstream>
            #include <cassert>
            void test() {
                boost::uuids::random_generator gen;
                boost::uuids::uuid u = gen();
                std::stringstream ss;
                ss << u;
                boost::uuids::string_generator sg;
                boost::uuids::uuid u2 = sg(ss.str());
                assert(u == u2);
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
