package("dipp")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/01Pollux/dipp")
    set_description("C++ Dependency injection inspired inspired by .NET's Microsoft.Extensions.DependencyInjection")
    set_license("MIT")

    add_urls("https://github.com/01Pollux/dipp.git")

    add_versions("2024.01.11", "85dd660b6829e9b2ff69f2d7b9be62811da17aed")

    on_check("windows", function (package)
        import("core.base.semver")

        local vs_toolset = package:toolchain("msvc"):config("vs_toolset")
        assert(vs_toolset and semver.new(vs_toolset):minor() >= 30, "package(dipp): need vs_toolset >= v143")
    end)

    on_install("windows", function (package)
        local configs = {
            test = false,
            benchmark = false,
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
