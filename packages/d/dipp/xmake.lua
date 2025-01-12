package("dipp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/01Pollux/dipp")
    set_description("C++ Dependency injection inspired inspired by .NET's Microsoft.Extensions.DependencyInjection")
    set_license("MIT")

    add_urls("https://github.com/01Pollux/dipp.git")

    add_versions("2024.01.11", "186fcac26f1e8c18cef216d490916473dd7c3625")

    on_install(function (package)
        local configs = {
            ['test'] = false,
            ['benchmark'] = false
        }
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <dipp/dipp.hpp>
            void test() {
                dipp::default_service_provider services({});
            }
        ]]}, {configs = {languages = "c++23"}}))
    end)
