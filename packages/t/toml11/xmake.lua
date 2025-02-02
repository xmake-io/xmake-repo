package("toml11")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/ToruNiina/toml11")
    set_description("TOML for Modern C++")
    set_license("MIT")

    add_urls("https://github.com/ToruNiina/toml11/archive/refs/tags/$(version).tar.gz",
             "https://github.com/ToruNiina/toml11.git")

    add_versions("v4.3.0", "af95dab1bbb9b05a597e73d529a7269e13f1869e9ca9bd4779906c5cd96e282b")
    add_versions("v4.2.0", "9287971cd4a1a3992ef37e7b95a3972d1ae56410e7f8e3f300727ab1d6c79c2c")
    add_versions("v4.1.0", "fb4c02cc708ae28e6fc3496514e3625e4b6738ed4ce40897710ca4d7a29de4f7")
    add_versions("v4.0.3", "c8cbc7839cb3f235153045ce550e559f55a04554dfcab8743ba8a1e8ef6a54bf")
    add_versions("v4.0.2", "d1bec1970d562d328065f2667b23f9745a271bf3900ca78e92b71a324b126070")
    add_versions("v4.0.1", "96965cb00ca7757c611c169cd5a6fb15736eab1cd1c1a88aaa62ad9851d926aa")
    add_versions("v3.8.1", "6a3d20080ecca5ea42102c078d3415bef80920f6c4ea2258e87572876af77849")
    add_versions("v3.7.0", "a0b6bec77c0e418eea7d270a4437510884f2fe8f61e7ab121729624f04c4b58e")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DCMAKE_CXX_STANDARD=11"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("toml::parse(\"\")", {configs = {languages = "c++11"}, includes = "toml.hpp"}))
    end)
