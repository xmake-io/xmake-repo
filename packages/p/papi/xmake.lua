package("papi")

    set_homepage("https://icl.utk.edu/papi/index.html")
    set_description("Performance Application Programming Interface")
    set_license("BSD-3-Clause")

    add_urls("http://icl.utk.edu/projects/papi/downloads/papi-$(version).tar.gz")
    add_versions("6.0.0", "3442709dae3405c2845b304c06a8b15395ecf4f3899a89ceb4d715103cb4055f")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    on_install("linux", function (package)
        os.cd("src")
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("PAPI_library_init", {includes = "papi.h"}))
    end)
