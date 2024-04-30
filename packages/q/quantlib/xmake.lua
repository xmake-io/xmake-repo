package("quantlib")
    set_homepage("http://quantlib.org")
    set_description("The QuantLib C++ library")

    add_urls("https://github.com/lballabio/QuantLib/releases/download/v$(version)/QuantLib-$(version).tar.gz",
             "https://github.com/lballabio/QuantLib.git")

    add_versions("1.34", "eb87aa8ced76550361771e167eba26aace018074ec370f7af49a01aa56b2fe50")
    add_versions("1.33", "4810d789261eb36423c7d277266a6ee3b28a3c05af1ee0d45544ca2e0e8312bd")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    add_deps("boost")

    on_install("windows", "linux", "macosx", "bsd", "mingw", "msys", "cross", function (package)
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
