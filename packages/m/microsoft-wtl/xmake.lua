package("microsoft-wtl")
    set_kind("library", {headeronly = true})
    set_homepage("https://wtl.sourceforge.io")
    set_description("Windows Template Library (WTL) is a C++ library for developing Windows applications and UI components. It extends ATL (Active Template Library) and provides a set of classes for controls, dialogs, frame windows, GDI objects, and more.")
    set_license("MS-PL")

    add_urls("https://github.com/Win32-WTL/WTL.git")
    add_versions("2022.3.11", "a95669345fb0b3c8be5c2607aa844f6adda7b28d")

    on_install("windows", function (package)
        os.cp("Include/*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <atlbase.h>
            #include <atlapp.h>
            void test() {
                AtlInitCommonControls(ICC_WIN95_CLASSES);
            }
        ]]}))
    end)
