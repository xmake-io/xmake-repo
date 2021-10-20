package("cfitsio")

    set_homepage("https://heasarc.gsfc.nasa.gov/fitsio/")
    set_description("CFITSIO is a library of C and Fortran subroutines for reading and writing data files in FITS (Flexible Image Transport System) data format.")

    add_urls("https://heasarc.gsfc.nasa.gov/FTP/software/fitsio/c/cfit-$(version).zip")
    add_versions("4.0.0", "b70423f831dc28919c56ff37baebb50b1eaca665ca8ca34094cb58b60c482386")

    add_deps("cmake", "zlib")
    if is_plat("windows") then
        add_defines("WIN32")
    end
    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DUSE_CURL=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("fits_read_wcstab", {includes = "fitsio.h"}))
    end)
