package("expat")

    set_homepage("https://libexpat.github.io")
    set_description("XML 1.0 parser")

    set_urls("https://github.com/libexpat/libexpat/releases/download/R_2_2_6/expat-$(version).tar.bz2")

    add_versions("2.2.6", "17b43c2716d521369f82fc2dc70f359860e90fa440bea65b3b85f0b246ea81f2")

    if is_host("windows") then
        add_deps("cmake")
    end

    on_install("windows", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_install("linux", "macosx", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("XML_ParserCreate", {includes = "expat.h"}))
    end)
