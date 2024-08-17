package("libspng")
    set_homepage("https://libspng.org")
    set_description("Simple, modern libpng alternative")
    set_license("BSD-2-Clause")

    set_urls("https://github.com/randy408/libspng/archive/refs/tags/$(version).tar.gz",
             "https://github.com/randy408/libspng.git")

    add_versions("v0.7.4", "47ec02be6c0a6323044600a9221b049f63e1953faf816903e7383d4dc4234487")
    add_versions("v0.7.1", "0726a4914ad7155028f3baa94027244d439cd2a2fbe8daf780c2150c4c951d8e")

    add_configs("cmake", {description = "Use cmake build system", default = false, type = "boolean"})

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    add_deps("zlib")

    on_load(function (package)
        if package:config("cmake") then
            package:add("deps", "cmake")
        end
        if not package:config("shared") then
            package:add("defines", "SPNG_STATIC")
        end
    end)

    on_install(function (package)
        if package:config("cmake") then
            local configs = {"-DBUILD_EXAMPLES=OFF"}
            table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
            if package:config("shared") then
                table.join2(configs, {"-DSPNG_SHARED=ON", "-DSPNG_STATIC=OFF"})
            else
                table.join2(configs, {"-DSPNG_SHARED=OFF", "-DSPNG_STATIC=ON"})
            end
            import("package.tools.cmake").install(package, configs)
        else
            io.writefile("xmake.lua", [[
                add_rules("mode.debug", "mode.release")
                add_requires("zlib")
                target("spng")
                    set_kind("$(kind)")
                    add_files("spng/*.c")
                    add_headerfiles("spng/*.h")
                    add_packages("zlib")
                    if is_kind("static") then
                        add_defines("SPNG_STATIC")
                    end
                    if is_plat("linux", "bsd") then
                        add_syslinks("m")
                    end
            ]])
            import("package.tools.xmake").install(package)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("spng_decode_image", {includes = "spng.h"}))
    end)
