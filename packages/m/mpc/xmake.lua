package("mpc")

    set_homepage("http://www.multiprecision.org/mpc/")
    set_description("GNU MPC is a C library for the arithmetic of complex numbers with arbitrarily high precision and correct rounding of the result.")
    set_license("LGPL-3.0")

    add_urls("https://ftpmirror.gnu.org/gnu/mpc/mpc-$(version).tar.gz",
             "https://ftp.gnu.org/gnu/mpc/mpc-$(version).tar.gz")
    add_versions("1.2.1", "17503d2c395dfcf106b622dc142683c1199431d095367c6aacba6eec30340459")
    add_versions("1.3.1", "ab642492f5cf882b74aa0cb730cd410a81edcdbec895183ce930e706c1c759b8")

    add_deps("gmp", "mpfr")
    on_install("macosx", "linux", function (package)
        local configs = {"--disable-dependency-tracking"}
        table.insert(configs, "--with-gmp=" .. package:dep("gmp"):installdir())
        table.insert(configs, "--with-mpfr=" .. package:dep("mpfr"):installdir())
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
        assert(package:has_cfuncs("mpc_add", {includes = "mpc.h"}))
    end)
