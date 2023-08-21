package("winreg")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/GiovanniDicanio/WinReg")
    set_description("Convenient high-level C++ wrapper around the Windows Registry API")
    set_license("MIT")

    add_urls("https://github.com/GiovanniDicanio/WinReg/archive/refs/tags/$(version).tar.gz",
             "https://github.com/GiovanniDicanio/WinReg.git")

    add_versions("v6.1.0", "d4118ccfd4f4edee29e0f6b3706979791ad537278e2f74818c150bb66f8fcc53")

    on_install("windows", "mingw", "msys", function (package)
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
