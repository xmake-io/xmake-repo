package("leptonica")

    set_homepage("http://www.leptonica.org/")
    set_description("Leptonica is a pedagogically-oriented open source site containing software that is broadly useful for image processing and image analysis applications.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/DanBloomberg/leptonica/archive/$(version).tar.gz",
             "https://github.com/DanBloomberg/leptonica.git")
    add_versions("1.80.0", "3952b974ec057d24267aae48c54bca68ead8275604bf084a73a4b953ff79196e")
    add_versions("1.81.1", "e9dd2100194843a20bbb980ad8b94610558d47f623861bc80ac967f2d2ecb879")

    add_deps("cmake")
    add_deps("libwebp", {configs = {img2webp = true, webpmux = true}})
    add_deps("zlib", "libtiff", "libpng", "libjpeg", "giflib")
    on_install("windows", "linux", function (package)
        local configs = {"-DSW_BUILD=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        if package:config("pic") ~= false then
            table.insert(configs, "-DCMAKE_POSITION_INDEPENDENT_CODE=ON")
        end
        import("package.tools.cmake").install(package, configs, {buildir = "build"})
        -- will be removed in 2.5.4
        os.trymv(path.join("build", "install", "cmake"), package:installdir())
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pixCleanBackgroundToWhite", {includes = "leptonica/allheaders.h"}))
    end)
