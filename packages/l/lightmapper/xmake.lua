package("lightmapper")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/ands/lightmapper")
    set_description("A C/C++ single-file library for drop-in lightmap baking. Just use your existing OpenGL renderer to bounce light!")

    add_urls("https://github.com/ands/lightmapper.git")
    add_versions("2022.01.03", "4fd3bf4e2c07263f85d5d875ebdef061bc512dd4")

    on_install(function (package)
        os.cp("lightmapper.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lmCreate", {includes = "lightmapper.h", configs = {languages = "c99"}}))
    end)
