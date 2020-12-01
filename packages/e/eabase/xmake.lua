package("eabase")

    set_homepage("https://github.com/electronicarts/EABase")
    set_description("EABase is a small set of header files that define platform-independent data types and platform feature macros.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/electronicarts/EABase/archive/$(version).tar.gz")
    add_versions("2.09.06", "981f922441617152b841585c0fc0bd205bd898c758016fa4985599a63c5a6e16")

    add_deps("cmake")

    on_install("windows", "linux", "macosx", function (package)
        import("package.tools.cmake").install(package)
        os.cp("include/Common/EABase", package:installdir("include"))
    end)


    on_test(function (package)
        assert(package:has_cxxfuncs("EA_LIMITS_DIGITS_U(int)",
            {configs = {languages = "c++17"}, includes = "EABase/eabase.h"}))
    end)