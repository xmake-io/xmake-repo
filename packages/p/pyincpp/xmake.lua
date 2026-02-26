package("pyincpp")
    set_homepage("https://github.com/chen-qingyu/pyincpp")
    set_description("A C++ type library that is as easy to use as Python built-in types.")
    set_kind("library", {headeronly = true})
    set_license("MIT")

    add_urls("https://github.com/chen-qingyu/pyincpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/chen-qingyu/pyincpp.git")

    add_versions("v2.7.1", "acf4da027d45efebcd8a3508412b6850be5d029217dc30035d3afd14a1291ab3")
    add_versions("v2.6.2", "ce8421d873fe879048990265b84903141ed2719234eb11b9c4b3f8c6b19d7623")
    add_versions("v2.6.1", "1157d85018d0a44157ff4a17f70f8a868f336790ce30bc62516d32f397644f84")
    add_versions("v2.6.0", "70d0dba92c51baf3591104e191a899f4f701b1450aa3bc4f9bcfffc532c68c97")
    add_versions("v2.5.2", "f99df02c2a2121e2658e770113a8c9ebec5643b81daf82786039653966999f2d")
    add_versions("v2.5.1", "305bdf437146e7230c1fc7a1e59009e765468b24133b6def4e17bb01d80f54ad")
    add_versions("v2.4.1", "766fc1dec895cf54803bf8ea7f9e86f9aa8e001b38c1f14a88907849e81f634b")
    add_versions("v2.4.0", "ae48bc62e9ed8f89e31235ee79385e59b0be6fd6720e8ebe0aa3d10ec7c9fee2")
    add_versions("v2.3.0", "e10640c03a6ae9365a299f57a68a5f2a873146b07f92fd33bc4f673e21d68072")
    add_versions("v1.6.1", "6a49657cb1f36f4fa400706a631c300771972015b4181f8cc352aa3de7e1a2a3")
    add_versions("v1.6.0", "1e8e4bfde447c439974180e206087b309f50ac0e24aeddf39d21d73fd7067368")
    add_versions("v1.4.1", "f3de3b5044a5c640811e87782264acbaf14697cd8c35bb21ddcd4de5664a60d0")
    add_versions("v1.3.3", "2689349de9faa35d8bbefddcc7d29d49308a2badd58961cc2b1a8f80c96d0823")
    add_versions("v1.3.2", "687148704f278c292962cffe1f440e5a4cc33f2a82f5e5a17b23aab88a282951")

    -- Some old platforms don't support the C++20 standard well.
    if on_check then
        on_check(function (package)
            if package:version():ge("2.0.0") then
                assert(package:check_cxxsnippets({test = [[
                    #include <iterator>
                    template <std::input_iterator InputIt>
                    void test_concept(InputIt) {}

                    #include <set>
                    #include <string>
                    struct TestCmp {
                        std::string str_;
                        auto operator<=>(const TestCmp&) const = default;
                    };
                    std::set<TestCmp> s = {TestCmp(), TestCmp()};
                ]]}, {configs = {languages = "c++20"}}), "Require supports C++20 standard.")
            end
        end)
    end

    on_install(function (package)
        if package:version():ge("2.0.0") then
            os.cp("sources/*.hpp", package:installdir("include/"))
        else
            os.cp("sources/*.hpp", package:installdir("include/pyincpp/"))
        end
    end)

    on_test(function (package)
        if package:version():ge("2.0.0") then
            assert(package:check_cxxsnippets({test = [[
                #include <cassert>
                using namespace pyincpp;
                void test() {
                    Dict<Str, List<Int>> dict = {{"first", {"123", "456"}}, {"second", {"789"}}, {"third", {"12345678987654321", "5"}}};
                    assert(dict.keys() == Set<Str>({"first", "second", "third"}));
                    assert(dict["third"][-1].factorial() == 120);
                }
            ]]}, {configs = {languages = "c++20"}, includes = "pyincpp.hpp"}))
        else
            assert(package:check_cxxsnippets({test = [[
                #include <cassert>
                using namespace pyincpp;
                void test() {
                    Map<String, List<Integer>> map = {{"first", {"123", "456"}}, {"second", {"789"}}, {"third", {"12345678987654321", "5"}}};
                    assert(map.keys() == Set<String>({"first", "second", "third"}));
                    assert(map["third"][-1].factorial() == 120);
                }
            ]]}, {configs = {languages = "c++17"}, includes = "pyincpp/pyincpp.hpp"}))
        end
    end)
