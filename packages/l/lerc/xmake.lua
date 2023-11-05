package("lerc")
    set_homepage("https://github.com/esri/lerc")
    set_description("Limited Error Raster Compression")
    set_license("Apache-2.0")

    add_urls("https://github.com/Esri/lerc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/Esri/lerc.git")

    add_versions("v4.0.0", "91431c2b16d0e3de6cbaea188603359f87caed08259a645fd5a3805784ee30a0")

    add_deps("cmake")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DBUILD_SHARED_LIBS=ON")
        else
            table.insert(configs, "-DBUILD_SHARED_LIBS=OFF")
            if package:is_plat("windows", "mingw") then
                package:add("defines", "LERC_STATIC")
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("lerc_computeCompressedSize", {includes = "Lerc_c_api.h"}))
    end)
