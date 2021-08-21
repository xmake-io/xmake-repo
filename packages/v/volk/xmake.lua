package("volk")

    set_homepage("https://github.com/zeux/volk")
    set_description("volk is a meta-loader for Vulkan")
    set_license("MIT")

    add_urls("https://github.com/zeux/volk/archive/$(version).tar.gz",
             "https://github.com/zeux/volk.git")
    add_versions("1.2.162", "ac4d9d6e88dee5a83ad176e2da57f1989ca2c6df155a0aeb5e18e9471aa4d777")

    add_deps("cmake", "vulkan-headers")

    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    if is_plat("linux") then
        add_syslinks("dl")
    end

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DVOLK_INSTALL=ON", "-DVOLK_PULL_IN_VULKAN=OFF"}
        import("package.tools.cmake").build(package, configs, {packagedeps = "vulkan-headers"})
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("volkInitialize", {configs = {languages = "c++14"}, includes = "volk.h"}))
    end)
    