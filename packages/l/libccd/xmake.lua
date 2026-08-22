package("libccd")
    set_homepage("https://github.com/danfis/libccd/")
    set_description("libccd is library for a collision detection between two convex shapes.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/danfis/libccd/archive/refs/tags/$(version).tar.gz",
             "https://github.com/danfis/libccd.git")
    add_versions("v2.1", "542b6c47f522d581fbf39e51df32c7d1256ac0c626e7c2b41f1040d4b9d50d1e")

    add_configs("double_precision", {description = "Enable double precision floating-point arithmetic.", default = false, type = "boolean"})
    if is_plat("wasm") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    add_deps("cmake")

    on_install(function (package)
        io.replace("src/ccd/ccd_export.h", "def CCD_STATIC_DEFINE", package:config("shared") and " 0" or " 1", {plain = true})

        io.replace("src/CMakeLists.txt", "  find_library(LIBM_LIBRARY NAMES m)", "", {plain = true})
        io.replace("src/CMakeLists.txt", "  if(NOT LIBM_LIBRARY)", "if(OFF)", {plain = true})
        io.replace("src/CMakeLists.txt", "  target_link_libraries(ccd \"${LIBM_LIBRARY}\")", "  target_link_libraries(ccd -lm)", {plain = true})

        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCCD_HIDE_ALL_SYMBOLS=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DENABLE_DOUBLE_PRECISION=" .. (package:config("double_precision") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ccdFirstDirDefault", {includes = "ccd/ccd.h"}))
    end)
