package("phnt")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/winsiderss/systeminformer")
    set_description("Native API header files for the System Informer project.")

    add_urls("git@github.com:winsiderss/phnt.git")
    add_versions("2022.10.13", "7c1adb8a7391939dfd684f27a37e31f18d303944")

    if is_plat("windows") then
        add_syslinks("ntdll")
    end

    on_install("windows", function (package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("NtConnectPort", {includes = {"phnt_windows.h", "phnt.h"}}))
    end)
