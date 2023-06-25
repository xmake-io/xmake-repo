package("mpfr")

    set_homepage("https://www.mpfr.org/")
    set_description("The MPFR library is a C library for multiple-precision floating-point computations with correct rounding.")
    set_license("LGPL-3.0")

    add_urls("https://www.mpfr.org/mpfr-$(version)/mpfr-$(version).tar.gz")
    add_versions("4.1.0", "3127fe813218f3a1f0adf4e8899de23df33b4cf4b4b3831a5314f78e65ffa2d6")
    add_versions("4.2.0", "f1cc1c6bb14d18f0c61cc416e083f5e697b6e0e3cf9630b9b33e8e483fc960f0")
    
    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::mpfr")
    elseif is_plat("linux") then
        add_extsources("pacman::mpfr", "apt::libmpfr-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::mpfr")
    end

    add_deps("gmp")
    on_install("macosx", "linux", function (package)
        local configs = {"--disable-dependency-tracking"}
        table.insert(configs, "--with-gmp=" .. package:dep("gmp"):installdir())
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
            table.insert(configs, "--enable-static=no")
        else
            table.insert(configs, "--enable-static=yes")
            table.insert(configs, "--enable-shared=no")
        end
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mpfr_get_version", {includes = "mpfr.h"}))
    end)
