package("sqrat")
    set_kind("library", {headeronly = true})
    set_homepage("http://scrat.sourceforge.net/")
    set_description("Sqrat is a C++ library for Squirrel that facilitates exposing classes and other native functionality to Squirrel scripts.")
    set_license("zlib")

    add_urls("git://git.code.sf.net/p/scrat/code")

    add_deps("squirrel")

    add_includedirs("include", "include/sqrat")

    on_install(function (package)
        os.cp("include/*.h", package:installdir("include"))
        os.cp("include/sqrat/*.h", package:installdir("include/sqrat/"))
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("Sqrat::Function", {includedirs = "include", includes = "sqrat.h"}))
    end)
