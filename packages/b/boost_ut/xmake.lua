package("boost_ut")
    set_kind("library", {headeronly = true})
    set_homepage("https://boost-ext.github.io/ut/")
    set_description("UT: C++20 μ(micro)/Unit Testing Framework")
    set_license("BSL-1.0")

    add_urls("https://github.com/boost-ext/ut/archive/refs/tags/$(version).tar.gz")
    add_urls("https://github.com/boost-ext/ut.git")
    add_versions("v1.1.9", "1a666513157905aa0e53a13fac602b5673dcafb04a869100a85cd3f000c2ed0d")

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
