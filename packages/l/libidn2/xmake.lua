package("libidn2")

    set_homepage("https://www.gnu.org/software/libidn/")
    set_description("Libidn2 is an implementation of the IDNA2008 + TR46 specifications.")
    set_license("LGPL-3.0")

    add_urls("https://ftpmirror.gnu.org/gnu/libidn/libidn2-$(version).tar.gz",
             "https://ftp.gnu.org/gnu/libidn/libidn2-$(version).tar.gz")
    add_versions("2.3.2", "76940cd4e778e8093579a9d195b25fff5e936e9dc6242068528b437a76764f91")

    add_deps("libunistring")
    if is_plat("linux") then
        add_extsources("apt::libidn2-dev", "pacman::libidn2")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--disable-dependency-tracking"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs, {packagedeps = {"libunistring"}})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("idn2_to_ascii_8z", {includes = "idn2.h"}))
    end)
