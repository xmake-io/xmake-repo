package("seacas")
    set_homepage("https://github.com/sandialabs/seacas")
    set_description("The Sandia Engineering Analysis Code Access System (SEACAS) is a suite of preprocessing, postprocessing, translation, and utility applications supporting finite element analysis software using the Exodus database file format.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/sandialabs/seacas/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sandialabs/seacas.git")
    add_versions("v2025-08-28", "29125a84859c78b6bb0b5909ce7443aa2774235f0fc75dedf467a223603e0ffd")

    add_deps("cmake")
    add_deps("fmt", "hdf5", "netcdf-c")

    add_links("Ioex", "Iogn", "Iogs", "Iohb", "Ionit", "Ionull", "Ioss", "Iotm", "Iotr", "Iovs", "aprepro_lib", "chaco", "exoIIv2for", "exoIIv2for32", "exodus", "exodus_for", "io_info_lib", "mapvarlib", "nemesis", "supes", "suplib", "suplib_c", "suplib_cpp")

    on_load(function (package)
        if package:is_plat("windows") and package:config("shared") then
            package:add("patches", "v2025-08-28", "patches/v2025-08-28/windows_shared.patch", "286681457a359a1f498087b72f221c01ec5d51f46bf13b13c1a8c0211bebe766")
        end
    end)

    on_install("windows", "linux", "bsd", "macosx", function (package)
        io.replace("cmake/tribits/common_tpls/FindTPLNetcdf.cmake", "netCDF_FOUND", "1", {plain = true})
        local configs = {
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"),
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
