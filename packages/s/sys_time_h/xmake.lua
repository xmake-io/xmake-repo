package("sys_time_h")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/win32ports/sys_time_h")
    set_description("header-only Windows implementation of the <sys/time.h> header")
    set_license("MIT")

    add_urls("https://github.com/win32ports/sys_time_h.git")
    add_versions("2023.03.22", "128ff475e1abc2aec0450f369bf91952a9bd2a3e")

    on_install("windows", function (package)
        os.cp("sys", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gettimeofday", {includes = "sys/time.h"}))
    end)
