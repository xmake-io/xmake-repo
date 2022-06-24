package("redex")
    set_homepage("https://fbredex.com/")
    set_description("A bytecode optimizer for Android apps")
    set_license("MIT")

    add_urls("https://github.com/facebook/redex.git")
    add_versions("2022.6.23", "802e428923e15b36993106685798e33d64f3e057")

    add_deps("cmake")
    add_deps("boost 1.71.0", {configs = {system = true, regex = true}})

    on_install("linux", "macosx", "windows", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_TYPE=" .. (package:config("shared") and "Shared" or "Static"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("DexLoader", {includes = "DexLoader.h"}))
    end)
