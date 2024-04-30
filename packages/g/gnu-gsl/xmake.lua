package("gnu-gsl")

    set_homepage("https://www.gnu.org/software/gsl/")
    set_description("The GNU Scientific Library (GSL) is a numerical library for C and C++ programmers.")
    set_license("GPL-3.0")

    add_urls("https://ftpmirror.gnu.org/gsl/gsl-$(version).tar.gz",
             "https://ftp.gnu.org/gnu/gsl/gsl-$(version).tar.gz")
    add_versions("2.7.1", "DCB0FBD43048832B757FF9942691A8DD70026D5DA0FF85601E52687F6DEEB34B")
    add_patches("2.7.1", path.join(os.scriptdir(), "0001-configure.patch"), "50FE9E6A4E68750FA2E21FEBF05471423CC7A0A38E59CF41D5009CD79352B2E6")
    add_patches("2.7.1", path.join(os.scriptdir(), "0002-add-fp-control.patch"), "6C6782327126EA979C5ACEAB3EE022B5DDC7D9D01C244774294572E73427EC4B")

    add_versions("2.7", "efbbf3785da0e53038be7907500628b466152dbc3c173a87de1b5eba2e23602b")
    add_patches("2.7", path.join(os.scriptdir(), "0001-configure.patch"), "50FE9E6A4E68750FA2E21FEBF05471423CC7A0A38E59CF41D5009CD79352B2E6")
    add_patches("2.7", path.join(os.scriptdir(), "0002-add-fp-control.patch"), "6C6782327126EA979C5ACEAB3EE022B5DDC7D9D01C244774294572E73427EC4B")

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
        os.cp(path.join(os.scriptdir(), "CMakeLists.txt"), path.join(package:cachedir(), "source"))
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE="..(package:config("pic") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gsl_isnan", {includes = "gsl/gsl_math.h"}))
    end)
