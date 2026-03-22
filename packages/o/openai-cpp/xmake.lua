package("openai-cpp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/olrea/openai-cpp")
    set_description("OpenAI C++ is a community-maintained library for the Open AI API")
    set_license("MIT")

    add_urls("https://github.com/olrea/openai-cpp/archive/refs/tags/$(version).tar.gz",
             "https://github.com/olrea/openai-cpp.git")
    add_versions("v0.1.3", "e73510ea7470d1a7e313bf1fcaeba1d2d67f31eeacea5e1efb3176fcb3040f42")

    add_deps("nlohmann_json", "libcurl")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                openai::OpenAI oai;
            }
        ]]}, {configs = {languages = "c++11"}, includes = "openai/openai.hpp"}))
    end)
