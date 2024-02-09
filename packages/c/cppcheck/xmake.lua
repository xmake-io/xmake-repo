package("cppcheck")
    set_homepage("https://cppcheck.sourceforge.io/")
    add_urls("https://github.com/danmar/cppcheck/archive/refs/tags/$(version).tar.gz")
    add_versions("2.13.0", "8229afe1dddc3ed893248b8a723b428dc221ea014fbc76e6289840857c03d450")

    add_deps("cmake")
    on_install("windows|x64", "macosx", "linux", "mingw", function (package)
        import("package.tools.cmake").install(package, {})
    end)

    on_test(function (package) 
        os.vrun("cppcheck --version")
    end)