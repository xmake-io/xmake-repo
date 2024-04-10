package("zeus_expected")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/zeus-cpp/expected")
    set_description("Backporting std::expected to C++17.")
    set_license("MIT")

    add_urls("https://github.com/zeus-cpp/expected/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zeus-cpp/expected.git")

    add_versions("v1.0.0", "a0d81798b777f9bfcc1e1e4f3046632067bd8c6071dbfcbec5012a31a5aebc68")

    add_patches("v1.0.0", path.join(os.scriptdir(), "patches", "v1.0.0", "fix_typename.patch"), "710d71f8c765a2937df25a2c52abec24f5f4ef5f43281f6aa01853d0498e2a47")

    if is_plat("windows") then
        add_cxxflags("/Zc:__cplusplus")
    end

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <zeus/expected.hpp>
            void test() {
                zeus::expected<int, int> e1 = 42;
                zeus::expected<int, int> e2 = zeus::unexpected(42);
            }
        ]]}, {configs = {languages = "cxx17"}}))
    end)
