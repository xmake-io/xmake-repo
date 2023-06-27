package("frozen")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/serge-sans-paille/frozen")
    set_description("A header-only, constexpr alternative to gperf for C++14 users")
    set_license("Apache-2.0")

    set_urls("https://github.com/serge-sans-paille/frozen/archive/refs/tags/$(version).tar.gz",
             "https://github.com/serge-sans-paille/frozen.git")

    add_versions("1.1.1", "f7c7075750e8fceeac081e9ef01944f221b36d9725beac8681cbd2838d26be45")

    on_install(function (package)
        os.cp("include/frozen", package:installdir("include"))
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
