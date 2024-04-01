package("pyincpp")
    set_homepage("https://github.com/chen-qingyu/pyincpp")
    set_description("A C++ type library that is as easy to use as Python built-in types.")
    set_kind("library", {headeronly = true})

    add_urls("https://github.com/chen-qingyu/pyincpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/chen-qingyu/pyincpp.git")

    add_versions("v1.3.3", "2689349de9faa35d8bbefddcc7d29d49308a2badd58961cc2b1a8f80c96d0823")
    add_versions("v1.3.2", "687148704f278c292962cffe1f440e5a4cc33f2a82f5e5a17b23aab88a282951")

    on_install(function (package)
        os.cp("sources/*.hpp", package:installdir("include/pyincpp"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cassert>
            using namespace pyincpp;
            void test() {
                Map<String, List<Integer>> map = {{"first", {123, 456}}, {"second", {789}}, {"second", {0}}, {"third", {"12345678987654321", 5}}};
                assert(map.size() == 3);
                assert(map.keys() == Set<String>({"first", "second", "third"}));
                assert(map["third"][-1].factorial() == 120);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "pyincpp/pyincpp.hpp"}))
    end)
