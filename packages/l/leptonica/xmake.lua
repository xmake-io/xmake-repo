package("leptonica")

    set_homepage("http://www.leptonica.org/")
    set_description("Leptonica is a pedagogically-oriented open source site containing software that is broadly useful for image processing and image analysis applications.")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/DanBloomberg/leptonica/releases/download/$(version)/leptonica-$(version).tar.gz",
             "https://github.com/DanBloomberg/leptonica.git")
    add_versions("1.80.0", "ec9c46c2aefbb960fb6a6b7f800fe39de48343437b6ce08e30a8d9688ed14ba4")
    add_versions("1.81.1", "0f4eb315e9bdddd797f4c55fdea4e1f45fca7e3b358a2fc693fd957ce2c43ca9")
    add_versions("1.82.0", "155302ee914668c27b6fe3ca9ff2da63b245f6d62f3061c8f27563774b8ae2d6")
    add_versions("1.84.1", "2b3e1254b1cca381e77c819b59ca99774ff43530209b9aeb511e1d46588a64f6")

    add_deps("cmake")
    add_deps("libwebp", {configs = {libwebpmux = true}})
    add_deps("zlib", "libtiff", "libpng", "libjpeg", "giflib")
    on_load("windows", "macosx", "linux", function (package)
        if package:config("shared") then
            package:add("defines", "LIBLEPT_IMPORTS")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        io.replace("CMakeLists.txt", "NOT JP2K", "FALSE", {plain = true})
        local configs = {"-DSW_BUILD=OFF", "-DCMAKE_FIND_FRAMEWORK=LAST", "-DCMAKE_DISABLE_FIND_PACKAGE_PkgConfig=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("pixCleanBackgroundToWhite", {includes = "leptonica/allheaders.h"}))
    end)
