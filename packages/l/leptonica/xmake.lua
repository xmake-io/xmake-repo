package("leptonica")

    set_homepage("http://www.leptonica.org/")
    set_description("Leptonica is a pedagogically-oriented open source site containing software that is broadly useful for image processing and image analysis applications.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/DanBloomberg/leptonica/archive/$(version).tar.gz",
             "https://github.com/DanBloomberg/leptonica.git")
    add_versions("1.80.0", "3952b974ec057d24267aae48c54bca68ead8275604bf084a73a4b953ff79196e")
    add_versions("1.81.1", "e9dd2100194843a20bbb980ad8b94610558d47f623861bc80ac967f2d2ecb879")
    add_versions("1.82.0", "40fa9ac1e815b91e0fa73f0737e60c9eec433a95fa123f95f2573dd3127dd669")

    add_configs("libwebp",  {description = "Build with WebP support.", default = false, type = "boolean"})
    add_configs("openjpeg", {description = "Build with OpenJPEG support.", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("zlib", "libtiff", "libpng", "libjpeg-turbo", "giflib")
    on_load("windows", "macosx", "linux", function (package)
        if package:config("shared") then
            package:add("defines", "LIBLEPT_IMPORTS")
        end
        if package:config("libwebp") then
            package:add("deps", "libwebp", {configs = {libwebpmux = true}})
        end
        if package:config("openjpeg") then
            package:add("deps", "openjpeg")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DSW_BUILD=OFF", "-DCMAKE_FIND_FRAMEWORK=LAST"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLIBWEBP_SUPPORT=" .. (package:config("libwebp") and "ON" or "OFF"))
        table.insert(configs, "-DOPENJPEG_SUPPORT=" .. (package:config("openjpeg") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pixCleanBackgroundToWhite", {includes = "leptonica/allheaders.h"}))
    end)
