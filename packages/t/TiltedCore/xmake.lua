package("tiltedcore")

    set_homepage("https://github.com/tiltedphoques/TiltedCore")
    set_description("Core library from Tilted Phoques")

    add_urls("https://github.com/tiltedphoques/TiltedCore/releases/download/$(version)/release.zip")
    add_urls("https://github.com/tiltedphoques/TiltedCore.git")

    add_versions("v0.1.2", "4bffcb3fe84ec3c97173b3dc5f8c9a6f3ef67c8d4e365ee0e62607f961af6b1a")

    add_deps("mimalloc")

    on_install("windows", "msys", function (package)
        local configs = {}
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int args, char** argv) {
                TiltedPhoques::Outcome<int, float> outcome;
            }
        ]]}, {includes = {"TiltedCore/Outcome.hpp"}}))
    end)
