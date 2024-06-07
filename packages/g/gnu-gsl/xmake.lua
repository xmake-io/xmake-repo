package("gnu-gsl")
    set_homepage("https://www.gnu.org/software/gsl/")
    set_description("The GNU Scientific Library (GSL) is a numerical library for C and C++ programmers.")
    set_license("GPL-3.0")

    add_urls("https://ftpmirror.gnu.org/gsl/gsl-$(version).tar.gz",
             "https://ftp.gnu.org/gnu/gsl/gsl-$(version).tar.gz")

    add_versions("2.7.1", "dcb0fbd43048832b757ff9942691a8dd70026d5da0ff85601e52687f6deeb34b")
    add_versions("2.7", "efbbf3785da0e53038be7907500628b466152dbc3c173a87de1b5eba2e23602b")

    if is_plat("windows") then
        add_patches("2.7.x", path.join(os.scriptdir(), "patches", "configure.patch"), "50fe9e6a4e68750fa2e21febf05471423cc7a0a38e59cf41d5009cd79352b2e6")
        add_patches("2.7.x", path.join(os.scriptdir(), "patches", "add_fp_control.patch"), "6c6782327126ea979c5aceab3ee022b5ddc7d9d01c244774294572e73427ec4b")
    end

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

    on_install("windows", function (package)
        os.cp(path.join(os.scriptdir(), "cmake", "cmakelists.txt"), path.join(package:cachedir(), "source"))
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE="..(package:config("pic") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gsl_isnan", {includes = "gsl/gsl_math.h"}))
    end)
