package("semver")
    set_homepage("https://github.com/Neargye/semver")
    set_description("Semantic Versioning for modern C++")
    set_license("MIT")

    add_urls("https://github.com/Neargye/semver.git")
    add_versions("2023.05.27", "492ba1beb1da6a4f150b8ca45985290f152396ed")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <semver.hpp>
            void test() {
                constexpr semver::version v1{1, 4, 3};
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
