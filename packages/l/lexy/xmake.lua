package("lexy")
    set_homepage("https://lexy.foonathan.net")
    set_description("C++ parsing DSL")

    add_urls("https://github.com/foonathan/lexy.git")
    add_versions("2022.03.21", "10342c6b1a03cbc6254c64064b419799a7993e0e")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DLEXY_BUILD_EXAMPLES=off")
        table.insert(configs, "-DLEXY_BUILD_TESTS=off")
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        os.cp("include/*", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxincludes("lexy/dsl.hpp", {configs = {languages = "c++17"}}))
    end)
