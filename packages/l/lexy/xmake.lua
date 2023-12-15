package("lexy")
    set_kind("library", {headeronly = true})
    set_homepage("https://lexy.foonathan.net")
    set_description("C++ parsing DSL")

    add_urls("https://github.com/foonathan/lexy.git")
    add_versions("2022.12.1", "f68737b725116d00e5582602e22604a14fc26547")
    add_versions("2022.03.21", "10342c6b1a03cbc6254c64064b419799a7993e0e")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("lexy/dsl.hpp", {configs = {languages = "c++17"}}))
    end)
