package("awk")
    set_kind("binary")
    set_homepage("https://github.com/onetrueawk/awk")
    set_description("One true awk")
    set_license("MIT-Lucent")

    add_urls("https://github.com/onetrueawk/awk/archive/refs/tags/$(version).tar.gz", 
            "https://github.com/onetrueawk/awk.git")
    add_versions("20251225", "626d7d19f8e4ceae70f60e2e662291789e0f54ab86945317a3d5693c30f847a2")

    add_deps("bison")

    on_install("macosx", "linux", "bsd", function (package)
        local configs = {}
        import("package.tools.make").make(package, configs)
        os.cp("a.out", path.join(package:installdir("bin"), "awk"))
    end)

    on_test(function (package)
        os.vrun("awk --version")
    end)
