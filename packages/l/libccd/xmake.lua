package("libccd")

    set_homepage("https://github.com/danfis/libccd/")
    set_description("libccd is library for a collision detection between two convex shapes.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/danfis/libccd/archive/refs/tags/$(version).tar.gz",
             "https://github.com/danfis/libccd.git")
    add_versions("v2.1", "542b6c47f522d581fbf39e51df32c7d1256ac0c626e7c2b41f1040d4b9d50d1e")

    add_configs("double_precision", {description = "Enable double precision floating-point arithmetic.", default = false, type = "boolean"})

    on_load("windows", "macosx", "linux", "mingw", "cross", function (package)
        if not package.is_built or package:is_built() then
            package:add("deps", "cmake")
        end
    end)

    on_install("windows", "macosx", "linux", "mingw", "cross", function (package)
        io.replace("src/ccd/ccd_export.h", "def CCD_STATIC_DEFINE", package:config("shared") and " 0" or " 1", {plain = true})
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCCD_HIDE_ALL_SYMBOLS=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DENABLE_DOUBLE_PRECISION=" .. (package:config("double_precision") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ccdFirstDirDefault", {includes = "ccd/ccd.h"}))
    end)

