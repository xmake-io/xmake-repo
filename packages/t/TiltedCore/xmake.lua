package("tiltedcore")

    set_homepage("https://github.com/tiltedphoques/TiltedCore")
    set_description("Core library from Tilted Phoques")

    add_urls("https://github.com/tiltedphoques/TiltedCore/releases/download/$(version)/release.zip")
    add_urls("https://github.com/tiltedphoques/TiltedCore.git")

    add_versions("v0.1.1", "a9a5df99d10067aff1306b99b40658ad5bb3749275ae6ddb4d3f95e4fe68381a")

    add_deps("mimalloc")

    on_install("windows", "msys", function (package)
        local configs = {}
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int args, char** argv) {
                Outcome<int, float> outcome;
            }
        ]]}, {includes = {"TiltedCore/Outcome.hpp"}}))
    end)
