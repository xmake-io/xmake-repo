package("inja")
    set_kind("library", {headeronly = true})
    set_homepage("https://pantor.github.io/inja/")
    set_description("A Template Engine for Modern C++")
    set_license("MIT")

    add_urls("https://github.com/pantor/inja/archive/refs/tags/$(version).tar.gz",
             "https://github.com/pantor/inja.git")

    add_versions("v3.5.0", "a5f0266673c59028eab6ceeddd8b862c70abfeb32fb7a5387c16bf46f3269ab2")
    add_versions("v3.4.0", "7155f944553ca6064b26e88e6cae8b71f8be764832c9c7c6d5998e0d5fd60c55")
    add_versions("v2.1.0", "038ecde8f6dbad5d3cedb6ceb0853fd0e488d5dc57593a869633ecb30b0dfa6e")

    add_deps("cmake")
    add_deps("nlohmann_json", {configs = {cmake = true}})

    on_install(function (package)
        import("package.tools.cmake").install(package, {
            "-DINJA_INSTALL=ON",
            "-DINJA_USE_EMBEDDED_JSON=OFF",
            "-DBUILD_TESTING=OFF",
            "-DBUILD_BENCHMARK=OFF"
        })
    end)

    on_test(function (package)
        local cxx_std = "c++17"
        if package:version() and package:version():lt("3.4.0") then
            cxx_std = "c++11"
        end
        assert(package:check_cxxsnippets({test = [[
            using namespace inja;
            using json = nlohmann::json;
            void test() {
                inja::Environment env;
                json data;
                data["name"] = "world";
                env.render("Hello {{ name }}!", data);
            }
        ]]}, {configs = {languages = cxx_std}, includes = {"inja/inja.hpp"}}))
    end)
