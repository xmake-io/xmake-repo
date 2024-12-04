package("kahip")

    set_homepage("https://kahip.github.io/")
    set_description("KaHIP - Karlsruhe High Quality Partitioning")
    set_license("MIT")

    add_urls("https://github.com/KaHIP/KaHIP/archive/refs/tags/$(version).tar.gz",
             "https://github.com/KaHIP/KaHIP.git")
    add_versions("v3.17", "3aa5fedf5a69fd3771ac97b4dbcc40f6f8a45f6c8b64e30d85c95cee124e38c3")
    add_versions("v3.16", "b0ef72a26968d37d9baa1304f7a113b61e925966a15e86578d44e26786e76c75")
    add_versions("v3.15", "20760099370ddf7ecb2f92bfdb727def48f6428001165be6ce504264b9a99a0b")

    add_deps("cmake", "openmp")
    on_install("macosx", "linux", function (package)
        local configs = {"-DNOMPI=ON", "-DPARHIP=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        import("package.tools.cmake").install(package, configs)
        local excess = package:config("shared") and "kahip_static" or "kahip"
        os.rm(path.join(package:installdir("lib"), excess .. ".*"))
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("kaffpa", {includes = "kaHIP_interface.h"}))
    end)
