package("quantlib")
    set_homepage("http://quantlib.org")
    set_description("The QuantLib C++ library")

    add_urls("https://github.com/lballabio/QuantLib/releases/download/v$(version)/QuantLib-$(version).tar.gz",
             "https://github.com/lballabio/QuantLib.git")

    add_versions("1.40", "5d6b971b998b8b47e5694dfc4851e9c8809624ff24c620579efc7fedef9dc149")
    add_versions("1.39", "0126dac9fab908ca3df411ec8eb888ea1932c1044b1036d6df2f8159451fb700")
    add_versions("1.35", "fd83657bbc69d8692065256699b7424d5a606dff03e7136a820b6e9675016c89")
    add_versions("1.34", "eb87aa8ced76550361771e167eba26aace018074ec370f7af49a01aa56b2fe50")
    add_versions("1.33", "4810d789261eb36423c7d277266a6ee3b28a3c05af1ee0d45544ca2e0e8312bd")

    add_configs("openmp", {description = "Enable OpenMP.", default = false, type = "boolean"})
    add_configs("ms", {description = "Enable date resolution down to microseconds", default = false, type = "boolean"})
    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    add_deps("boost", {configs = {math = true, serialization = true, regex = true, thread = true}})

    on_load(function (package)
        if package:config("openmp") then
            package:add("deps", "openmp")
        end
    end)

    on_install("windows", "linux", "macosx", "bsd", "mingw", "msys", "cross", function (package)
        local configs = {"-DQL_BUILD_BENCHMARK=OFF", "-DQL_BUILD_EXAMPLES=OFF", "-DQL_BUILD_TEST_SUITE=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DQL_ENABLE_OPENMP=" .. (package:config("openmp") and "ON" or "OFF"))
        table.insert(configs, "-DQL_HIGH_RESOLUTION_DATE=" .. (package:config("ms") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local cppver = package:version():ge("1.36") and "c++17" or "c++14"
        assert(package:check_cxxsnippets({test = [[
            #include <ql/time/calendars/target.hpp>
            using namespace QuantLib;
            void test() {
                Calendar calendar = TARGET();
                Date todaysDate(19, March, 2014);
            }
        ]]}, {configs = {languages = cppver}}))
    end)
