package("dylib")
    set_kind("library", {headeronly = true})
    set_homepage("https://conan.io/center/recipes/dylib")
    set_description("C++ cross-platform wrapper around dynamic loading of shared libraries (dll, so, dylib)")
    set_license("MIT")

    add_urls("https://github.com/martin-olivier/dylib/archive/refs/tags/$(version).tar.gz",
             "https://github.com/martin-olivier/dylib.git")

    add_versions("v2.2.1", "6af0d2a91860743dc9f564ba0ab7f036a9b37c904395610288791571d4dbea5b")

    add_deps("cmake")

    on_install(function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                dylib lib("foo");
            }
        ]]}, {configs = {languages = "c++11"}, includes = "dylib.hpp"}))
    end)
