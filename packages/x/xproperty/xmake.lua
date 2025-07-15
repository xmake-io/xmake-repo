package("xproperty")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/jupyter-xeus/xproperty")
    set_description("Traitlets-like C++ properties and implementation of the observer pattern")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/jupyter-xeus/xproperty/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jupyter-xeus/xproperty.git")

    add_versions("0.12.0", "27cbc8e441dcc515a1ebbf11bad5ef240748d32f5e1adf84deed87a1dc57a440")

    add_deps("cmake")
    add_deps("nlohmann_json")

    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <xproperty/xobserved.hpp>
            struct Foo : public xp::xobserved<Foo>
            {
                XPROPERTY(double, Foo, bar);
                XPROPERTY(double, Foo, baz);
            };
            void test() {
                Foo foo;
                XOBSERVE(foo, bar, [](Foo& f){});
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
