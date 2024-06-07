package("eventpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/wqking/eventpp")
    set_description("Event Dispatcher and callback list for C++")
    set_license("Apache-2.0")

    add_urls("https://github.com/wqking/eventpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/wqking/eventpp.git")

    add_versions("v0.1.3", "d87aba67223fd9aced2ba55eb82bd534007e43e1b919106a53fcd3070fa125ea")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package, {"-DEVENTPP_INSTALL=ON"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <eventpp/callbacklist.h>
            void test() {
                eventpp::CallbackList<void (const std::string &, const bool)> callbackList;
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
