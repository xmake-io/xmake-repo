package("eabase")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/electronicarts/EABase")
    set_description("EABase is a small set of header files that define platform-independent data types and platform feature macros.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/electronicarts/EABase/archive/$(version).tar.gz")
    add_versions("2.09.05", "f85b98c96f1976aa013c8d6016c5e37a409633ac3fce843cd4ec0b89c67e6b7a")

    on_install("windows", "linux", "macosx", function (package)
        os.cp("include/Common/EABase", package:installdir("include"))
    end)


    on_test(function (package)
        assert(package:has_cxxfuncs("EA_LIMITS_DIGITS_U(int)",
            {configs = {languages = "c++17"}, includes = "EABase/eabase.h"}))
    end)
