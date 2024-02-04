package("quantlib")
    set_homepage("http://quantlib.org")
    set_description("The QuantLib C++ library")

    add_urls("https://github.com/lballabio/QuantLib/releases/download/v$(version)/QuantLib-$(version).tar.gz",
             "https://github.com/lballabio/QuantLib.git")

    add_versions("1.33", "f973831d951b815a30392113c7cab7b66e6e2ea05dd12e3cb7c3b7ca3b20b081")

    add_deps("cmake")
    add_deps("boost")

    on_install(function (package)
        local configs = {"-DQL_BUILD_BENCHMARK=OFF", "-DQL_BUILD_EXAMPLES=OFF", "-DQL_BUILD_TEST_SUITE=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <ql/time/calendars/target.hpp>
            using namespace QuantLib;
            void test() {
                Calendar calendar = TARGET();
                Date todaysDate(19, March, 2014);
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
