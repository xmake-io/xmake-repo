package("zeus_expected")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/zeus-cpp/expected")
    set_description("Backporting std::expected to C++17.")
    set_license("MIT")

    add_urls("https://github.com/zeus-cpp/expected/archive/refs/tags/$(version).tar.gz",
             "https://github.com/zeus-cpp/expected.git")

    add_versions("v1.0.0", "a0d81798b777f9bfcc1e1e4f3046632067bd8c6071dbfcbec5012a31a5aebc68")

    add_deps("cmake")

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
                zeus::expected<int, std::string> e1 = 42;
                zeus::expected<int, std::string> e2 = zeus::unexpected("42");
            }
        ]]}, {configs = {languages = "cxx17"}}))
    end)
