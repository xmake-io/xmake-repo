package("zeus_expected")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/zeus-cpp/expected")
    set_description("Backporting std::expected to C++17.")
    set_license("MIT")

    add_urls("https://github.com/zeus-cpp/expected/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zeus-cpp/expected.git")

    add_versions("v1.2.0", "460da641f212c793f46a5a8f29107c9b9540a17a91f197e2dc396dac0269a2b5")
    add_versions("v1.1.1", "47b411677ffb2fa0d43b308797542509ae2bdb101426cf0d4777e3c162b1d726")
    add_versions("v1.1.0", "a963eba43f227498da2cbb924265344209696320c75ee63a92073936bb49f7e5")
    add_versions("v1.0.1", "e2a7dd56837fa1c30ce255c52361b6a245e732d265cfbd449d60826a8d0625ae")
    add_versions("v1.0.0", "a0d81798b777f9bfcc1e1e4f3046632067bd8c6071dbfcbec5012a31a5aebc68")

    add_patches("v1.0.0", path.join(os.scriptdir(), "patches", "v1.0.0", "fix_typename.patch"), "710d71f8c765a2937df25a2c52abec24f5f4ef5f43281f6aa01853d0498e2a47")

    on_install(function (package)
        os.cp("include", package:installdir())
    end)

    on_test(function (package)
        local cxflags = {}
        if package:is_plat("windows") then
            table.insert(cxflags, "/Zc:__cplusplus")
        end
        assert(package:check_cxxsnippets({test = [[
            #include <zeus/expected.hpp>
            void test() {
                zeus::expected<int, int> e1 = 42;
                zeus::expected<int, int> e2 = zeus::unexpected(42);
            }
        ]]}, {configs = {languages = "cxx17", cxflags = cxflags}}))
    end)
