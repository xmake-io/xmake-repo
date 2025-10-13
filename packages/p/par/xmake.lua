package("par")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/prideout/par")
    set_description("single-file C libraries from Philip Allan Rideout")
    set_license("MIT")

    add_urls("https://github.com/prideout/par.git")

    add_versions("2022.08.06", "24f26c12926b746db5814de759163144ad79843a")

    on_install(function (package)
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("par_shapes_create_parametric_sphere", {includes = "par_shapes.h"}))
    end)
