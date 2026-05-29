package("crashcatch")
    set_kind("library", { headeronly = true })
    set_homepage("https://github.com/keithpotz/CrashCatch")
    set_description("A cross-platform, lightweight, single-header crash-reporting library for modern C++ applications.")
    set_license("MIT")

    add_urls("https://github.com/keithpotz/CrashCatch/archive/refs/tags/v$(version).tar.gz",
        "https://github.com/keithpotz/CrashCatch.git")
    add_versions("1.4.0", "b1b965626ee200c039cfacaa77cdf458074235014c65f1862101714ce6b1fdfc")
    add_versions("1.3.0", "9723153a76c3c840ded92f1c1e53fe5817d452bcc6d2309d5b0c2bd295de5ff0")

    add_defines("CRASHCATCH_DLL_EXPORTS")
    if is_plat("linux") then
        add_syslinks("pthread")
    elseif is_plat("windows") then
        add_defines("_CRT_SECURE_NO_WARNINGS")
        add_syslinks("dbghelp", "user32")
    end

    on_install("!macosx", function(package)
        os.cp("include/*.hpp", package:installdir("include"))
    end)

    on_test(function(package)
        assert(package:has_cxxtypes("CrashCatch_Config", {configs = {languages = "cxx17"}, includes = "CrashCatchDLL.hpp"}))
    end)
