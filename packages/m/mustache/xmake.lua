package("mustache")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/kainjow/Mustache")
    set_description("Mustache text templates for modern C++")
    set_license("BSL-1.0")

    add_urls("https://github.com/kainjow/Mustache.git")
    add_versions("2021.12.10", "04277d5552c6e46bee41a946b7d175a660ea1b3d")

    on_install(function (package)
        os.cp("mustache.hpp", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <mustache.hpp>
            using namespace kainjow::mustache;
            void test() {
                mustache tmpl{"Hello {{what}}!"};
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
