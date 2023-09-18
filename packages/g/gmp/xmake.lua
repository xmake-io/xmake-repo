package("gmp")

    set_homepage("https://gmplib.org/")
    set_description("GMP is a free library for arbitrary precision arithmetic, operating on signed integers, rational numbers, and floating-point numbers.")
    set_license("LGPL-3.0")

    add_urls("https://ftpmirror.gnu.org/gmp/gmp-$(version).tar.xz")
    add_urls("https://ftp.gnu.org/gnu/gmp/gmp-$(version).tar.xz")
    add_urls("https://gmplib.org/download/gmp/gmp-$(version).tar.xz")
    add_versions("6.2.1", "fd4829912cddd12f84181c3451cc752be224643e87fac497b69edddadc49b4f2")
    add_versions("6.3.0", "a3c2b80201b89e68616f4ad30bc66aee4927c3ce50e33929ca819d5c43538898")
    
    if is_plat("mingw") and is_subhost("msys") then
        add_extsources("pacman::gmp")
    elseif is_plat("linux") then
        add_extsources("pacman::gmp", "apt::libgmp-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::gmp")
    end

    add_deps("m4")

    on_install("macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gmp_randinit", {includes = "gmp.h"}))
    end)
