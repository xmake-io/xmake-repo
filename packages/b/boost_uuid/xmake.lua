package("boost_uuid")
    set_kind("library", {headeronly = true})
    set_homepage("https://www.boost.org/libs/uuid")
    set_description("Boost Uuid Library")
    set_license("BSL-1.0")

    -- add_defines("BOOST_UUID_LINK_LIBATOMIC")

    add_urls("https://github.com/boostorg/uuid/archive/refs/tags/boost-$(version).tar.gz",
             "https://github.com/boostorg/uuid.git")

    add_versions("1.91.0", "2cfe4dda2d987eb51cb28d71212aa0afdbff96bbef584d92f758422a604bcf59")
    add_versions("1.90.0", "855801530b6dd3ec932296d275dc84cd5517049979126e01469c85456bfca29e")
    add_versions("1.89.0", "144790a4f61fa1c94ca743287bcf293bb514efda8544cdf53e9698d0f05ee4bc")

    on_install(function (package)
        os.cp("include/boost", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <boost/uuid.hpp>
            #include <cassert>
            void test() {
            using namespace boost::uuids;
            uuid u;
            assert( u.size() == 16 );
            static_assert( uuid::static_size() == 16 );
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
