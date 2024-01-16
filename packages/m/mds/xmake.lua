package("mds")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/chen-qingyu/MyDataStructure")
    set_description("A C++ containers library that is as easy to use as Python's containers library.")
    set_license("GPL-3.0")

    add_urls("https://github.com/chen-qingyu/MyDataStructure/archive/refs/tags/v$(version).zip",
             "https://github.com/chen-qingyu/MyDataStructure.git")
    add_versions("1.1.0", "70c985b335137c443e6cb170337d2476fd32bab663193f398c7078c4e6916f0d")

    on_install(function (package)
        os.cp("sources/*.hpp", package:installdir("include/mds"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <cassert>
            using namespace mds;
            void test() {
                Map<String, List<Integer>> map = {{"first", {123, 456}}, {"second", {789}}, {"second", {0}}, {"third", {"12345678987654321", 5}}};
                assert(map.size() == 3);
                assert(map.keys() == Set<String>({"first", "second", "third"}));
                assert(map["third"][-1].factorial() == 120);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "mds/mds.hpp"}))
    end)
