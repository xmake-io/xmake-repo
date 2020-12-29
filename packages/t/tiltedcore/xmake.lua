package("tiltedcore")

    set_homepage("https://github.com/tiltedphoques/TiltedCore")
    set_description("Core library from Tilted Phoques")

    add_urls("https://github.com/tiltedphoques/TiltedCore/releases/download/$(version)/release.zip")
    add_urls("https://github.com/tiltedphoques/TiltedCore.git")

    add_versions("v0.1.4", "c50213b6814267ccfa24212ca0fbc922c162ac97d234ff50de2e05463115e9b4")
    add_versions("v0.1.3", "e6bc279a436e32c187341af9a47a64977d00d354eda66237804aada51d1884e3")

    add_deps("mimalloc", {configs = {rltgenrandom = true}})

    on_install("windows", "msys", function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int args, char** argv) {
                TiltedPhoques::Outcome<int, float> outcome;
            }
        ]]}, {includes = {"TiltedCore/Outcome.hpp"}}))
    end)
