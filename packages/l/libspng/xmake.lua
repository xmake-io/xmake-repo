package("libspng")

    set_homepage("https://libspng.org")
    set_description("Simple, modern libpng alternative")

    set_urls("https://github.com/randy408/libspng/archive/refs/tags/$(version).tar.gz",
             "https://github.com/randy408/libspng.git")
    add_versions("v0.7.1", "0726a4914ad7155028f3baa94027244d439cd2a2fbe8daf780c2150c4c951d8e")

    add_deps("cmake", "zlib")

    on_load(function (package)
        if not package:config("shared") then
            package:add("defines", "SPNG_STATIC")
        end
    end)

    on_install(function (package)
        local configs = {"-DBUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("shared") then
            table.insert(configs, "-DSPNG_SHARED=ON")
            table.insert(configs, "-DSPNG_STATIC=OFF")
        else
            table.insert(configs, "-DSPNG_SHARED=OFF")
            table.insert(configs, "-DSPNG_STATIC=ON")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("spng_decode_image", {includes = "spng.h"}))
    end)
