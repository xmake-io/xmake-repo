package("sys_wait_h")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/win32ports/sys_wait_h")
    set_description("header-only Windows implementation of the <sys/wait.h> header")
    set_license("MIT")

    add_urls("https://github.com/win32ports/sys_wait_h.git")
    add_versions("2019.05.12", "229dee8de9cb4c29a3a31115112a4175df84a8eb")

    on_install("windows", function (package)
        os.cp("sys", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("wait", {includes = "sys/wait.h"}))
    end)
