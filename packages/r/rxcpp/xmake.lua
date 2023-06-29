package("rxcpp")
    set_kind("library", {headeronly = true})
    set_homepage("http://reactivex.io/RxCpp/")
    set_description("Compose async and event-based programs using observable sequences and LINQ-style query operators.")
    set_license("Apache-2.0")

    set_urls("https://github.com/ReactiveX/RxCpp.git")
    add_versions("v4.1.1", "90758767f7299ff94ba7f359944fde479a7aeb92")
    add_versions("v3.0.0", "8290f92f744f807e83b1bfe9e8c0ffd162140ec8")

    on_install(function(package)
        os.cp("Rx/v2/src/rxcpp", package:installdir("include"))
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({test = [[
            #include <rxcpp/rx.hpp>
            #include <iostream>

            void test() {
                auto values1 = rxcpp::sources::range(1, 5);
                values1.subscribe(
                    [] (int v) { std::cout << "OnNext: " << v << "\n"; },
                    [] () { std::cout << "OnCompleted\n"; }
                );
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
