package("crashcatch")
    set_kind("library", { headeronly = true })
    set_homepage("https://github.com/keithpotz/CrashCatch")
    set_description("A cross-platform, lightweight, single-header crash-reporting library for modern C++ applications.")
    set_license("MIT")

    add_urls("https://github.com/keithpotz/CrashCatch/archive/refs/tags/v$(version).tar.gz",
        "https://github.com/keithpotz/CrashCatch.git")
    add_versions("1.4.0", "b1b965626ee200c039cfacaa77cdf458074235014c65f1862101714ce6b1fdfc")
    add_versions("1.3.0", "9723153a76c3c840ded92f1c1e53fe5817d452bcc6d2309d5b0c2bd295de5ff0")
    add_versions("1.2", "04e99b5627a8ceb2b62449f7be8b4b23ae98184284aab5c99d191dbb6d6fa188")
    add_versions("1.1.0", "50907a8177cb600d22a93663e9ed6b0c4f404c9091f9d64a56121df1357b8bc8")
    add_versions("1.0.0", "8bff2368892fbf7d7b3f976851005b35e36cda8f65cb481dcc042e189933e6a6")

    add_defines("CRASHCATCH_DLL_EXPORTS")
    if is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("windows") then
        add_defines("_CRT_SECURE_NO_WARNINGS")
        add_syslinks("dbghelp", "user32")
    end

    on_install(function(package)
        os.cp("include/*.hpp", package:installdir("include"))
    end)

    on_test(function(package)
        assert(package:has_cxxtypes("CrashCatch_Config", {configs = {languages = "cxx17"}, includes = "CrashCatchDLL.hpp"}))
    end)
