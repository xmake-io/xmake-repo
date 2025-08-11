package("netcdf-c")
    set_homepage("https://github.com/Unidata/netcdf-c")
    set_description("Network Common Data Form (NetCDF) libraries and utilities.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/Unidata/netcdf-c/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Unidata/netcdf-c.git")
    add_versions("v4.9.3", "990f46d49525d6ab5dc4249f8684c6deeaf54de6fec63a187e9fb382cc0ffdff")
    add_patches("v4.9.3", "patches/dependencies.patch", "d707097e4fe72d9d747b97d61b3e6ba9ee84dfc403af477402893b4130481bfb")

    add_deps("cmake", "libcurl", "libxml2", "libzip", "zlib")
    add_deps("hdf5", {configs = {zlib = true}})

    on_install(function (package)
        local configs = {
            "-DNCNN_SHARED_LIB=" .. (package:config("shared") and "ON" or "OFF"),
            "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"),
            "-DBUILD_TESTING=OFF",
            "-DENABLE_EXAMPLES=OFF",
            "-DENABLE_TESTS=OFF",
            "-DENABLE_FILTER_TESTING=OFF",
            "-DENABLE_DAP_REMOTE_TESTS=OFF",
            "-DDISABLE_INSTALL_DEPENDENCIES=ON",
        }
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("nc_create", {includes = "netcdf.h"}))
    end)
