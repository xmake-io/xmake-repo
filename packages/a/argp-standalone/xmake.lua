package("argp-standalone")

    set_homepage("https://www.lysator.liu.se/~nisse/misc/")
    set_description("Standalone version of arguments parsing functions from GLIBC")

    add_urls("https://www.lysator.liu.se/~nisse/misc/argp-standalone-$(version).tar.gz")
    add_versions("1.3", "dec79694da1319acd2238ce95df57f3680fea2482096e483323fddf3d818d8be")

    on_install("macosx", "android", function (package)
        local cxflags
        if package:config("pic") ~= false then
            cxflags = "-fPIC"
        end
        import("package.tools.autoconf").install(package, {}, {cxflags = cxflags})
        os.vcp("libargp.a", package:installdir("lib"))
        os.vcp("argp.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("argp_parse", {includes = "argp.h"}))
    end)
