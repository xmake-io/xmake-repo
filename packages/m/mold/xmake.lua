package("mold")
    set_kind("binary")
    set_homepage("https://github.com/rui314/mold")
    set_description("mold: A Modern Linker")

    add_urls("https://github.com/rui314/mold/archive/refs/tags/v$(version).tar.gz")
    add_versions("1.0.1", "b0d54602d1229c26583ee8a0132e53463c4d755f9dbc456475f388fd8a1aa3e4")

    on_install("linux", "macosx", function (package)
        import("package.tools.make").build(package)
        os.cp("mold", package:installdir("bin"))
    end)

    on_test(function (package)
        os.vrun("mold --version")
    end)
