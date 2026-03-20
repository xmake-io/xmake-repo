package("openai-cpp")
    set_homepage("https://github.com/olrea/openai-cpp")
    set_description("OpenAI C++ is a community-maintained library for the Open AI API")
    set_license("MIT")

    add_urls("https://github.com/olrea/openai-cpp/archive/refs/tags/v$(version).tar.gz")
    add_versions("0.1.3", "e73510ea7470d1a7e313bf1fcaeba1d2d67f31eeacea5e1efb3176fcb3040f42")

    add_deps("nlohmann_json", "libcurl")
    set_kind("library", {headeronly = true})

    on_install(function (package)
        os.mkdir(package:installdir("include/openai"))
        os.cp("include/openai/*.hpp", package:installdir("include/openai/"))
        package:add("includedirs", "include")
    end)
