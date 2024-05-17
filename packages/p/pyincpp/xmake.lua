package("pyincpp")
    set_homepage("https://github.com/chen-qingyu/pyincpp")
    set_description("A C++ type library that is as easy to use as Python built-in types.")
    set_kind("library", {headeronly = true})

    add_urls("https://github.com/chen-qingyu/pyincpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/chen-qingyu/pyincpp.git")

    add_versions("v2.3.0", "c7459dd3c078b78e29ab3323c5a66dba8fd18d54c27a37edcc3d24f028a12f24")

    on_install(function (package)
        os.cp("sources/*.hpp", package:installdir("include/"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cassert>
            using namespace pyincpp;
            void test() {
                Dict<Str, List<Int>> dict = {{"first", {"123", "456"}}, {"second", {"789"}}, {"third", {"12345678987654321", "5"}}};
                assert(dict.keys() == (Set<Str>{"first", "second", "third"}));
                assert(dict["third"][-1].factorial() == 120);
            }
        ]]}, {configs = {languages = "c++20"}, includes = "pyincpp.hpp"}))
    end)
