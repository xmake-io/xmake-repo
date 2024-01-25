package("pytype")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/chen-qingyu/Pytype")
    set_description("A C++ type library that is as easy to use as Python built-in types.")

    add_urls("https://github.com/chen-qingyu/pytype-cpp/archive/refs/tags/$(version).tar.gz", 
             "https://github.com/chen-qingyu/pytype-cpp.git")

    add_versions("v1.3.0", "4f0b2efe2acb6fb678d2fcd54105fef815973d0dde17662ee8c92a10a1dc8b4f")

    on_install(function (package)
        os.cp("sources/*.hpp", package:installdir("include/pytype"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cassert>
            using namespace pytype;
            void test() {
                Map<String, List<Integer>> map = {{"first", {123, 456}}, {"second", {789}}, {"second", {0}}, {"third", {"12345678987654321", 5}}};
                assert(map.size() == 3);
                assert(map.keys() == Set<String>({"first", "second", "third"}));
                assert(map["third"][-1].factorial() == 120);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "pytype/pytype.hpp"}))
    end)
