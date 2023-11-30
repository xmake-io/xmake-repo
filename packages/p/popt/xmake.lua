package("popt")
    set_homepage("http://ftp.rpm.org/popt/")
    set_description("C library for parsing command line parameters")
    set_license("MIT")

    add_urls("https://github.com/rpm-software-management/popt/archive/refs/tags/popt-$(version)-release.tar.gz")

    add_versions("1.19", "6eb40d650526cb9fe63eb4415bcecdf9cf306f7556e77eff689abc5a44670060")

    add_deps("libintl")

    on_install("linux", "macosx", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, package:is_debug() and "--enable-debug" or "--disable-debug")
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("poptGetContext", {includes = "popt.h"}))
    end)
