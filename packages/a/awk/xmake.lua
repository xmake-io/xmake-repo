package("awk")
    set_kind("binary")
    set_homepage("https://github.com/onetrueawk/awk")
    set_description("One true awk")

    add_urls("https://github.com/onetrueawk/awk.git")
    add_versions("2021.12.26", "b9c01f51224fd302519e8a35bd06effc06f6d3d1")

    add_deps("bison")

    on_install("macosx", "linux", function (package)
        local configs = {}
        import("package.tools.make").make(package, configs)
        os.cp("a.out", path.join(package:installdir("bin"), "awk"))
    end)

    on_test(function (package)
        os.vrun("awk --version")
    end)
