package("mma")

    set_homepage("https://github.com/jdumas/mma")
    set_description("A self-contained C++ implementation of MMA and GCMMA.")
    set_license("MIT")

    add_urls("https://github.com/jdumas/mma.git")
    add_versions("2018.08.01", "aa51333f942220ac98e5957accb1b7e60590ec6f")

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")
    on_install("windows", "macosx", "linux", "mingw", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("MMASolver", {includes = "mma/MMASolver.h"}))
    end)
