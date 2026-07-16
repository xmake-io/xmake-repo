package("netcdf-c")
    set_homepage("https://github.com/Unidata/netcdf-c")
    set_description("Network Common Data Form (NetCDF) libraries and utilities.")
    set_license("BSD-3-Clause")

    add_urls("https://github.com/Unidata/netcdf-c/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Unidata/netcdf-c.git")
    add_versions("v4.10.1", "33c27231c478c3b35da7c7758fbdd02da1fe407abcb16ddfe195f69d164f930d")
    add_versions("v4.9.3", "990f46d49525d6ab5dc4249f8684c6deeaf54de6fec63a187e9fb382cc0ffdff")
    add_patches("v4.10.1", "patches/v4.10.1/deps.patch", "ed8020780b49d87c212481d6c18c5981eb1a9db2a574a350918ae149fbb5d00a")
    add_patches("v4.9.3", "patches/v4.9.3/deps.patch", "b66fdf04a6d0d220ef14e078ca17ca09d33491f19ef408dc971c5c1fac6e7d6d")

    add_deps("cmake", "libcurl", "libxml2", "libzip", "zlib")
    add_deps("hdf5", {configs = {zlib = true}})

    on_install("windows", "linux", "macosx", "bsd", function (package)
        io.replace("config.h.cmake.in", "#ifndef __clang__", "#if !defined(_MSC_VER) && !defined(__clang__)", {plain = true})
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
        if is_plat("windows") then
            table.insert(configs, "-DNETCDF_USE_STATIC_CRT=" .. (package:runtimes():startswith("MT") and "ON" or "OFF"))
            if package:config("shared") then
                table.insert(configs, "-DNETCDF_ENABLE_DLL=ON")
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("nc_create", {includes = "netcdf.h"}))
    end)
