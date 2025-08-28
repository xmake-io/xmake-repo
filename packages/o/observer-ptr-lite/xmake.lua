package("observer-ptr-lite")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/martinmoene/observer-ptr-lite")
    set_description("observer-ptr - An observer_ptr for C++98 and later in a single-file header-only library (Extensions for Library Fundamentals, v2, v3)")
    set_license("BSL-1.0")

    add_urls("https://github.com/martinmoene/observer-ptr-lite/archive/refs/tags/$(version).tar.gz",
             "https://github.com/martinmoene/observer-ptr-lite.git")

    add_versions("v0.4.0", "812eafbdaccfb44ffd2536692b668cd1f16228e8d7609de56b60320c8c57cc67")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package, {"-DNSOP_OPT_BUILD_TESTS=OFF"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <nonstd/observer_ptr.hpp>
            void test(nonstd::observer_ptr<int> p) {}
        ]]}, {configs = {languages = "c++11"}}))
    end)
