package("TiltedCore")

    set_homepage("https://github.com/tiltedphoques/TiltedCore")
    set_description("Core library from Tilted Phoques")

    add_urls("https://github.com/tiltedphoques/TiltedCore/releases/download/$(version)/release.zip")
    add_urls("https://github.com/tiltedphoques/TiltedCore.git")

    add_versions("v0.1.0", "7ce69086a3d4275a68877f443e682781275447ca0cc89b495428659410813655")

    add_includedirs("Code/core/include")
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
        ]]}, {includes = {"Code/core/include/Outcome.hpp"}}))
    end)
