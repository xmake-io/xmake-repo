package("boost_ut")
    set_kind("library", {headeronly = true})
    set_homepage("https://boost-ext.github.io/ut/")
    set_description("UT: C++20 μ(micro)/Unit Testing Framework")
    set_license("BSL-1.0")

    add_urls("https://github.com/boost-ext/ut/archive/refs/tags/$(version).tar.gz")
    add_urls("https://github.com/boost-ext/ut.git")
    add_versions("v2.3.1", "e51bf1873705819730c3f9d2d397268d1c26128565478e2e65b7d0abb45ea9b1")
    add_versions("v2.3.0", "9c07a2b7947cc169fc1713ad462ccc43a704076447893a1fd25bdda5eec4aab6")
    add_versions("v2.1.1", "016ac5ece1808cd1100be72f90da4fa59ea41de487587a3283c6c981381cc216")
    add_versions("v2.1.0", "1c9c35c039ad3a9795a278447db6da0a4ec1a1d223bf7d64687ad28f673b7ae8")
    add_versions("v1.1.9", "1a666513157905aa0e53a13fac602b5673dcafb04a869100a85cd3f000c2ed0d")
    add_versions("v2.0.1", "1e43be17045a881c95cedc843d72fe9c1e53239b02ed179c1e39e041ebcd7dad")

    add_configs("modules", {description = "Enable C++20 modules", default = false, type = "boolean", readonly = true})

    on_install("windows", "linux", "macosx", function (package)
        os.cp("include", package:installdir())
        if not package:config("modules") then
            package:add("defines", "BOOST_UT_DISABLE_MODULE")
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            constexpr auto sum(auto... values) { return (values + ...); }

            void test() {
                using namespace boost::ut;

                "sum"_test = [] {
                    expect(sum(0) == 0_i);
                    expect(sum(1, 2) == 3_i);
                    expect(sum(1, 2) > 0_i and 41_i == sum(40, 2));
                };
            }
        ]]}, {configs = {languages = "c++20", defines = "BOOST_UT_DISABLE_MODULE"}, includes = "boost/ut.hpp"}))
    end)
