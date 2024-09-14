package("osqp")
    set_homepage("https://osqp.org/")
    set_description("The Operator Splitting QP Solver")
    set_license("Apache-2.0")

    add_urls("https://github.com/osqp/osqp/releases/download/$(version)/osqp-$(version)-src.tar.gz",
             "https://github.com/osqp/osqp.git")

    add_versions("v0.6.3", "285b2a60f68d113a1090767ec8a9c81a65b3af2d258f8c78a31cc3f98ba58456")

    add_patches("0.6.3", "patches/0.6.3/cmake.patch", "15524f5562ccde458d7f9885b592d982b44b0239dbfbdf31cf720861ea3be6e8")

    add_deps("cmake")
    add_deps("qdldl")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DCMAKE_WINDOWS_EXPORT_ALL_SYMBOLS=ON")
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = "qdldl"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("osqp_solve", {includes = "osqp/osqp.h"}))
    end)
