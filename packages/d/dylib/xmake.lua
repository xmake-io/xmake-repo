package("dylib")
    set_kind("library", {headeronly = true})
    set_homepage("https://conan.io/center/recipes/dylib")
    set_description("C++ cross-platform wrapper around dynamic loading of shared libraries (dll, so, dylib)")
    set_license("MIT")

    add_urls("https://github.com/martin-olivier/dylib/archive/refs/tags/$(version).tar.gz",
             "https://github.com/martin-olivier/dylib.git")

    add_versions("v3.0.1", "dfef3f0aeccf4ad847a5cd02f0b0bff086b4fac6e764e33abd82d3c85cfb578c")
    add_versions("v2.2.1", "6af0d2a91860743dc9f564ba0ab7f036a9b37c904395610288791571d4dbea5b")

    add_deps("cmake")

    on_install("!android and !bsd", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        if package:version() and package:version():ge("3.0.0") then
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    dylib::library lib("./plugins/foo", dylib::decorations::os_default());
                }
            ]]}, {configs = {languages = "c++11"}, includes = "dylib.hpp"}))
        else
            assert(package:check_cxxsnippets({test = [[
                void test() {
                    dylib lib("foo");
                }
            ]]}, {configs = {languages = "c++11"}, includes = "dylib.hpp"}))
        end
    end)
