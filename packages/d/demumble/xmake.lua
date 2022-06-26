package("demumble")
    set_kind("binary")
    set_homepage("https://github.com/nico/demumble")
    set_description("A better c++filt and a better undname.exe, in one binary.")
    set_license("Apache-2.0")

    add_urls("https://github.com/nico/demumble.git")
    add_versions("2022.3.23", "df938e45c2b0e064fb5323d88b692d03b451d271")

    add_deps("cmake")

    on_install("@linux", "@macosx", "@windows", function (package)
        import("package.tools.cmake").install(package, {}, {buildir = "build"})
        os.cp("build/demumble", package:installdir("bin"))
    end)

    on_test(function (package)
        os.vrun("demumble _Z4funcPci")
    end)
