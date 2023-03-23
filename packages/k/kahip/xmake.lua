package("kahip")

    set_homepage("https://kahip.github.io/")
    set_description("KaHIP - Karlsruhe High Quality Partitioning")
    set_license("MIT")

    add_urls("https://github.com/KaHIP/KaHIP/archive/refs/tags/$(version).tar.gz",
             "https://github.com/KaHIP/KaHIP.git")
    add_versions("v3.14", "9da04f3b0ea53b50eae670d6014ff54c0df2cb40f6679b2f6a96840c1217f242")

    add_deps("cmake", "openmp")
    on_install("macosx", "linux", function (package)
        local configs = {"-DNOMPI=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
        local excess = package:config("shared") and "kahip_static" or "kahip"
        os.rm(path.join(package:installdir("lib"), excess .. ".*"))
        print(os.files(package:installdir("**")))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("kaffpa", {includes = "kaHIP_interface.h"}))
    end)
