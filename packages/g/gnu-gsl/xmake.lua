package("gnu-gsl")

    set_homepage("https://www.gnu.org/software/gsl/")
    set_description("The GNU Scientific Library (GSL) is a numerical library for C and C++ programmers.")
    set_license("GPL-3.0")

    add_urls("https://ftpmirror.gnu.org/gsl/gsl-$(version).tar.gz",
             "https://ftp.gnu.org/gnu/gsl/gsl-$(version).tar.gz")
    add_versions("2.7", "efbbf3785da0e53038be7907500628b466152dbc3c173a87de1b5eba2e23602b")

    add_links("gsl", "gslcblas")
    on_install("macosx", "linux", function (package)
        local configs = {"--disable-dependency-tracking"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs, {cppflags = cppflags, ldflags = ldflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gsl_isnan", {includes = "gsl/gsl_math.h"}))
    end)
