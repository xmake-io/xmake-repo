package("xproperty")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/jupyter-xeus/xproperty")
    set_description("Traitlets-like C++ properties and implementation of the observer pattern")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/jupyter-xeus/xproperty.git")
    add_versions("2021.04.13", "4e5cc851733ad5f57dd75c33d3beb75aba2569aa")

    add_deps("cmake", "xtl")

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
        ]]}, {configs = {languages = "c++14"}}))
    end)
