package("nlohmann_json")

    set_homepage("https://nlohmann.github.io/json/")
    set_description("JSON for Modern C++")

    add_urls("https://github.com/nlohmann/json/releases/download/$(version)/include.zip",
             "https://github.com/nlohmann/json.git")
    add_versions("v3.4.0", "bfec46fc0cee01c509cf064d2254517e7fa80d1e7647fea37cf81d97c5682bdc")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)
