package("phnt")

    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/winsiderss/systeminformer")
    set_description("Native API header files for the System Informer project.")

    set_urls("https://github.com/winsiderss/phnt.git")
    add_versions("2023.6.18", "7c1adb8a7391939dfd684f27a37e31f18d303944")

    add_syslinks("ntdll")

    on_install("windows", function (package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cincludes("phnt_windows.h"))
    end)
