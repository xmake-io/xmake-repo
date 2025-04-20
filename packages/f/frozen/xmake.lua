package("frozen")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/serge-sans-paille/frozen")
    set_description("A header-only, constexpr alternative to gperf for C++14 users")
    set_license("Apache-2.0")

    set_urls("https://github.com/serge-sans-paille/frozen/archive/refs/tags/$(version).tar.gz",
             "https://github.com/serge-sans-paille/frozen.git")

    add_versions("1.2.0", "ed8339c017d7c5fe019ac2c642477f435278f0dc643c1d69d3f3b1e95915e823")
    add_versions("1.1.1", "f7c7075750e8fceeac081e9ef01944f221b36d9725beac8681cbd2838d26be45")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            constexpr frozen::set<int, 4> some_ints = {1,2,3,5};
          
            void test()
            {
                constexpr bool letitgo = some_ints.count(8);
            }
        ]]}, {configs = {languages = "c++14"}, includes = { "frozen/set.h"} }))
    end)
