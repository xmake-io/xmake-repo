package("osqp")

    set_homepage("https://osqp.org/")
    set_description("The Operator Splitting QP Solver")
    set_license("Apache-2.0")

    add_urls("https://github.com/oxfordcontrol/osqp.git")
    add_versions("v0.6.2", "f9fc23d3436e4b17dd2cb95f70cfa1f37d122c24")

    add_deps("cmake")
    on_install("windows", "macosx", "linux", "mingw", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("osqp_solve", {includes = "osqp/osqp.h"}))
    end)
