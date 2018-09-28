package("pcre2")

    set_homepage("https://www.pcre.org/")
    set_description("A Perl Compatible Regular Expressions Library")

    set_urls("https://ftp.pcre.org/pub/pcre/pcre2-$(version).zip",
             "ftp://ftp.csx.cam.ac.uk/pub/software/programming/pcre/pcre2-$(version).zip")

    add_versions("10.23", "6301a525a8a7e63a5fac0c2fbfa0374d3eb133e511d886771e097e427707094a")
    add_versions("10.30", "3677ce17854fffa68fce6b66442858f48f0de1f537f18439e4bd2771f8b4c7fb")
    add_versions("10.31", "b4b40695a5347a770407d492c1749e35ba3970ca03fe83eb2c35d44343a5a444")

    if is_host("windows") then
        add_deps("cmake")
    end

    on_install("windows", function (package)
        import("package.tools.cmake").install(package)
        package:addvar("links", "pcre2-8")
        package:addvar("defines", "PCRE2_CODE_UNIT_WIDTH=8")
    end)

    on_install("macosx", "linux", function (package)
        import("package.tools.autoconf").install(package)
        package:addvar("links", "pcre2-8")
        package:addvar("defines", "PCRE2_CODE_UNIT_WIDTH=8")
    end)
