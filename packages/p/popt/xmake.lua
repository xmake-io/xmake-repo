package("popt")
    set_homepage("http://ftp.rpm.org/popt/")
    set_description("C library for parsing command line parameters")
    set_license("MIT")

    add_urls("http://ftp.rpm.org/popt/releases/popt-1.x/popt-$(version).tar.gz",
             "https://ftp.osuosl.org/pub/rpm/popt/releases/popt-1.x/popt-$(version).tar.gz")

    add_versions("1.19", "c25a4838fc8e4c1c8aacb8bd620edb3084a3d63bf8987fdad3ca2758c63240f9")

    if is_plat("macosx") then
        add_deps("libintl")
        add_deps("libiconv", {system = true})
    end

    on_install("linux", "macosx", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, package:is_debug() and "--enable-debug" or "--disable-debug")
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("poptGetContext", {includes = "popt.h"}))
    end)
