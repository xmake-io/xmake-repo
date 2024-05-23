package("reactiveplusplus")
    set_kind("library", {headeronly = true})
    set_homepage("https://victimsnino.github.io/ReactivePlusPlus/v2/docs/html/md_docs_2readme.html")
    set_description("Implementation of async observable/observer (Reactive Programming) in C++ with care about performance and templates in mind in ReactiveX approach")
    set_license("BSL-1.0")

    add_urls("https://github.com/victimsnino/ReactivePlusPlus/archive/refs/tags/$(version).tar.gz",
             "https://github.com/victimsnino/ReactivePlusPlus.git")

    add_versions("v2.1.1", "0b962478d7c973a1f74062ce7f8d24c2fdcd2733031b1f014e65d252d59ebe6a",
                 "v2.1.0", "d84a194ef96b92201ea574f81780837c95e8956bbad09b3dc2dc5cef7c2eef98",
                 "v0.2.3", "9542419f8d7da98126ba2c6ae08fab287b4b3798d89cf75ed9bed2a9e3ec1678")

    add_deps("cmake")
    add_includedirs("include/rpp")

    on_install(function (package)
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        local snippets
        if package:version() and package:version():le("0.2.3") then
            snippets = [[
                void test() {
                    rpp::source::just(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
                        .filter([](int v) { return v % 2 == 0; })
                        .subscribe([](int v) {});
                }
            ]]
        else
            snippets = [[
                void test() {
                    rpp::source::just(0, 1, 2, 3, 4, 5, 6, 7, 8, 9)
                        | rpp::operators::filter([](int v) { return v % 2 == 0; })
                        | rpp::operators::subscribe([](int v) {});
                }
            ]]
        end
        assert(package:check_cxxsnippets({test = snippets}, {includes = "rpp/rpp.hpp", configs = {languages = "c++20"}}))
    end)
