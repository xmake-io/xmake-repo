package("nazarautils")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/NazaraEngine/NazaraUtils")
    set_description("Header-only utility library for Nazara projects")
    set_license("MIT")

    add_urls("https://github.com/NazaraEngine/NazaraUtils/archive/refs/tags/$(version).tar.gz",
             "https://github.com/NazaraEngine/NazaraUtils.git")

    add_versions("v1.1.1", "9febde2fe10dc46a40c5680f2f65432e60d994297c7846e7191afd2ac9aa2de9")
    add_versions("v1.0.0", "924ea35e99b163b4fd88b61fbc848d384be497e3b0dc36fa762cc5143312524a")

    set_policy("package.strict_compatibility", true)

    on_install(function (package)
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                Nz::Bitset<> bitset;
                bitset.UnboundedSet(42);
                bitset.Reverse();
            }
        ]]}, {configs = {languages = "c++17"}, includes = "NazaraUtils/Bitset.hpp"}))
    end)
