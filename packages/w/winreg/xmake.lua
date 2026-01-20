package("winreg")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/GiovanniDicanio/WinReg")
    set_description("Convenient high-level C++ wrapper around the Windows Registry API")
    set_license("MIT")

    add_urls("https://github.com/GiovanniDicanio/WinReg/archive/refs/tags/$(version).tar.gz",
             "https://github.com/GiovanniDicanio/WinReg.git")

    add_versions("v6.4.0", "a983d129b31cda357e118469d80e60bea2e8fa33010c6b40669ccd8f5f9896c2")
    add_versions("v6.3.2", "644adca91229d714efaeebf0c010cc795f888f6a1015bb7d42c2f0a45fe52f8b")
    add_versions("v6.3.1", "b92842cc37d3fe1a4d103929480045a40c39ba2efc15d7656f62e189d10d0bc4")
    add_versions("v6.3.0", "5a8b47c19ce705172cb1107451acbbb9fa7d8aa1e8f5356a2e682c16cf5532e9")
    add_versions("v6.2.0", "9dc1b287fb8c765a35791bf0deea0da81e52a969827bc2d8777f54f26ade588d")
    add_versions("v6.1.0", "d4118ccfd4f4edee29e0f6b3706979791ad537278e2f74818c150bb66f8fcc53")

    on_install("windows", "mingw", "msys", function (package)
        if package:is_plat("mingw") and package:is_arch("i386") then
            io.replace("WinReg/WinReg.hpp", "UNREFERENCED_PARAMETER(size);", "(void)size;", {plain = true})
        end
        os.cp("WinReg/WinReg.hpp", package:installdir("include/WinReg"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <WinReg/WinReg.hpp>
            void test() {
                winreg::RegKey key{ HKEY_CURRENT_USER, L"SOFTWARE\\SomeKey" };
            }
        ]]}, {configs = {languages = "c++17"}}))
    end)
