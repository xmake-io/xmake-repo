package("tomlcpp")
    set_homepage("https://github.com/cktan/tomlcpp")
    set_description("No fanfare TOML C++ Library")
    set_license("MIT")

    add_urls("https://github.com/cktan/tomlcpp.git")
    add_versions("2022.06.25", "4212f1fccf530e276a2e1b63d3f99fbfb84e86a4")

    add_deps("tomlc99")

    on_install(function (package)
        io.writefile("xmake.lua", [[
            add_requires("tomlc99")
            set_languages("c++14")
            add_rules("mode.release", "mode.debug")
            target("tomlcpp")
                set_kind("$(kind)")
                add_files("tomlcpp.cpp")
                add_headerfiles("tomlcpp.hpp")
                if is_plat("windows") and is_kind("shared") then
                    add_rules("utils.symbols.export_all", {export_classes = true})
                end
                add_packages("tomlc99")
        ]])
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <tomlcpp.hpp>
            void test() {
                auto res = toml::parseFile("sample.toml");
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
