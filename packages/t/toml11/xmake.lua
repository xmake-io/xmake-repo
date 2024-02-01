package("toml11")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/ToruNiina/toml11")
    set_description("TOML for Modern C++")
    set_license("MIT")

    add_urls("https://github.com/ToruNiina/toml11/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ToruNiina/toml11.git")
    add_versions("v3.8.1", "6a3d20080ecca5ea42102c078d3415bef80920f6c4ea2258e87572876af77849")
    add_versions("v3.7.0", "a0b6bec77c0e418eea7d270a4437510884f2fe8f61e7ab121729624f04c4b58e")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("toml::parse(\"\")", {configs = {languages = "c++11"}, includes = "toml.hpp"}))
    end)
