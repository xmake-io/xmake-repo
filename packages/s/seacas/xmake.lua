package("seacas")
    set_homepage("https://github.com/sandialabs/seacas")
    set_description("The Sandia Engineering Analysis Code Access System (SEACAS) is a suite of preprocessing, postprocessing, translation, and utility applications supporting finite element analysis software using the Exodus database file format.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/sandialabs/seacas/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sandialabs/seacas.git")

    add_versions("v2025-08-28", "29125a84859c78b6bb0b5909ce7443aa2774235f0fc75dedf467a223603e0ffd")

    add_deps("cmake")
    add_deps("fmt", "hdf5", "netcdf-c")

    on_install("windows", "linux", "bsd", "macosx", function (package)
        io.replace("cmake/tribits/common_tpls/FindTPLNetcdf.cmake", "netCDF_FOUND", "1", {plain = true})
        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DLIBMINC_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
            "-DBUILD_TESTING=OFF",
            "-DSeacas_ENABLE_SEACAS=ON",
            "-DSeacas_ENABLE_Zoltan=OFF",
            "-DNetcdf_FORCE_MODERN=ON",
        }
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ex_inquire", {includes = "exodusII.h"}))
    end)
