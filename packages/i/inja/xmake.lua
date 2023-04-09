package("inja")

    set_homepage("https://pantor.github.io/inja/")
    set_description("A Template Engine for Modern C++")

    add_urls("https://github.com/pantor/inja/archive/$(version).tar.gz",
             "https://github.com/pantor/inja.git")

    add_versions("v2.1.0", "038ecde8f6dbad5d3cedb6ceb0853fd0e488d5dc57593a869633ecb30b0dfa6e")

    add_deps("nlohmann_json")

    on_install(function (package)
        os.cp("single_include/inja", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using namespace inja;
            using json = nlohmann::json;
            void test() {
                inja::Environment env;
                json data;
                data["name"] = "world";
                env.render("Hello {{ name }}!", data);
            }
        ]]}, {configs = {languages = "c++17"}, includes = {"inja/inja.hpp"}}))
    end)
