package("qjswrapper")
    set_homepage("https://github.com/burdockcascade/qjswrapper")
    set_description("A C++23 header-only wrapper around quickjs-ng")
    set_license("MIT")

    add_urls("https://github.com/burdockcascade/qjswrapper/archive/refs/tags/$(version).tar.gz",
             "https://github.com/burdockcascade/qjswrapper.git")

    add_versions("v0.1.0", "c6ac958473e4572a8aa275e27fc3e5b8492f18efd252727c564f9ec0caf1a032")

    set_kind("library", {headeronly = true})

    add_deps("quickjs-ng 0.14")z

    on_install(function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <qjswrapper.hpp>
            void test() {
                qjs::Engine engine;
                auto config_obj = engine.make_object();
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)