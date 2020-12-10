package("gmp")

    set_homepage("https://gmplib.org/")
    set_description("GMP is a free library for arbitrary precision arithmetic, operating on signed integers, rational numbers, and floating-point numbers.")
    set_license("LGPL-3.0")

    add_urls("https://gmplib.org/download/gmp/gmp-$(version).tar.xz")
    add_versions("6.2.1", "fd4829912cddd12f84181c3451cc752be224643e87fac497b69edddadc49b4f2")

    on_install("macosx", "linux", function (package)
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
            table.insert(configs, "--enable-static=no")
        else
            table.insert(configs, "--enable-static=yes")
            table.insert(configs, "--enable-shared=no")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gmp_randinit", {includes = "gmp.h"}))
    end)
