package("tinyspline")
    set_homepage("https://github.com/msteinbeck/tinyspline")
    set_description("TinySpline is a small, yet powerful library for interpolating, transforming, and querying arbitrary NURBS, B-Splines, and Bézier curves. ")
    set_license("MIT License")

    add_urls("https://github.com/msteinbeck/tinyspline/archive/refs/tags/$(version).tar.gz",
        "https://github.com/msteinbeck/tinyspline.git")
    add_versions("v0.6.0", "3ea31b610dd279266f26fd7ad5b5fca7a20c0bbe05c7c32430ed6aa54d57097a")

    add_deps("cmake")
    on_load(function (package)
        if package:is_arch(".+64") then
            package:add("linkdirs", "lib64")
        end
    end)
    on_install("windows", "macosx", "linux", function (package)
        io.replace("src/tinyspline.h", "#define TS_KNOT_EPSILON 1e-4f", "#define TS_KNOT_EPSILON 1e-6f", {plain = true})
        local configs = { "-DTINYSPLINE_BUILD_EXAMPLES=OFF",
            "-DTINYSPLINE_BUILD_TESTS=OFF",
            "-DTINYSPLINE_BUILD_DOCS=OFF",
            "-DTINYSPLINE_WARNINGS_AS_ERRORS=OFF" }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)
    on_test(function (package)
        assert(package:has_cxxtypes("tinyspline::BSpline", {includes = "tinysplinecxx.h"}))
    end)
package_end()
