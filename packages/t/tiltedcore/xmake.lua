package("tiltedcore")

    set_homepage("https://github.com/tiltedphoques/TiltedCore")
    set_description("Core library from Tilted Phoques")

    add_urls("https://github.com/tiltedphoques/TiltedCore/archive/$(version).zip")
    add_urls("https://github.com/tiltedphoques/TiltedCore.git")

    add_versions("v0.2.1", "5cf7aab7f548c7dc49349af321d4e96286cea83177a4b779a2b8504e86f1ff3b")
    add_versions("v0.2.0", "c08096df42542add9ced163de4784a998fa08e343da3fcd9ffa42fc5393f8f93")
    add_versions("v0.1.6", "d29ee14db2015644fecf6410d28f823151986f15bea1dc9ec4251e605ab8461b")
    add_versions("v0.1.5", "8bd6826ba63ddb16137e54383f95997377409d2a7263acdbdf94bed05b50c9c9")
    add_versions("v0.1.4", "c50213b6814267ccfa24212ca0fbc922c162ac97d234ff50de2e05463115e9b4")
    add_versions("v0.1.3", "e6bc279a436e32c187341af9a47a64977d00d354eda66237804aada51d1884e3")

    add_deps("mimalloc", {configs = {rltgenrandom = true}})

    on_install("windows", "msys", "linux", function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test(int args, char** argv) {
                TiltedPhoques::Outcome<int, float> outcome;
            }
        ]]}, {includes = {"TiltedCore/Outcome.hpp"}}))
    end)
