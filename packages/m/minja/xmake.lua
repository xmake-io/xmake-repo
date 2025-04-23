package("minja")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/google/minja")
    set_description("A minimalistic C++ Jinja templating engine for LLM chat templates")
    set_license("MIT")

    add_urls("https://github.com/google/minja.git")
    add_versions("2025.01.31", "76f0d01779aa00b0c68f2117f6cb2c9afc3a0ca8")

    add_deps("nlohmann_json")

    on_install(function (package)
        io.replace("include/minja/minja.hpp", "#include <json.hpp>", "#include <nlohmann/json.hpp>", {plain = true})

        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            using json = nlohmann::ordered_json;
            void test() {
                auto tmpl = minja::Parser::parse("Hello, {{ location }}!", /* options= */ {});
                auto context = minja::Context::make(minja::Value(json {
                    {"location", "World"},
                }));
                auto result = tmpl->render(context);
            }
        ]]}, {configs = {languages = "c++17"}, includes = "minja/minja.hpp"}))
    end)
