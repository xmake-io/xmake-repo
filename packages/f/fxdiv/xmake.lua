package("fxdiv")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/Maratyszcza/FXdiv")
    set_description("C99/C++ header-only library for division via fixed-point multiplication by inverse")
    set_license("MIT")

    add_urls("https://github.com/Maratyszcza/FXdiv.git")
    add_versions("2020.12.08", "63058eff77e11aa15bf531df5dd34395ec3017c8")

    add_deps("cmake")

    on_install(function (package)
        local configs = {"-DFXDIV_BUILD_TESTS=OFF", "-DFXDIV_BUILD_BENCHMARKS=OFF"}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("fxdiv_init_uint32_t", {includes = "fxdiv.h"}))
    end)
