package("volk")

    set_homepage("https://github.com/zeux/volk")
    set_description("volk is a meta-loader for Vulkan")
    set_license("MIT")

    add_urls("https://github.com/zeux/volk/archive/$(version).tar.gz")
    add_versions("1.2.162", "ac4d9d6e88dee5a83ad176e2da57f1989ca2c6df155a0aeb5e18e9471aa4d777")

    add_deps("cmake", "vulkan-headers")

    if is_plat("linux") then
        add_syslinks("dl")
    end

    on_install("windows", "linux", "macosx", function (package)
        import("package.tools.cmake").install(package)
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
        else
            table.insert(configs, "--enable-shared=no")
        end
        import("package.tools.cmake").build(package, configs, {buildir = "build", packagedeps = "vulkan-headers"})
        if package:is_plat("windows") then
            os.trycp("build/*.lib", package:installdir("lib"))
            os.trycp("build/*.dll", package:installdir("bin"))
        else
            os.trycp("build/*.a", package:installdir("lib"))
            os.trycp("build/*.so", package:installdir("lib"))
        end
        os.cp("*.h", package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("volkInitialize", {configs = {languages = "c++14"}, includes = "volk.h"}))
    end)
    