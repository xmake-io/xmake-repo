package("simage")

    set_homepage("https://coin3d.github.io/simage/html/")
    set_description("Simage is a library capable of loading, manipulating and saving images, creating and saving movies (AVI and MPEG), and loading audio.")
    set_license("MIT")

    add_urls("https://github.com/coin3d/simage/releases/download/v$(version)/simage-$(version)-src.zip",
             "https://github.com/coin3d/simage.git")
    add_versions("1.8.1", "308a8712c1f28cf6e662acab2e1fdd263fbfcb11323869806f4fef435653d4d3")
    add_versions("1.8.3", "48fd116bf8493df08729ad8468ce42d7c9c73ddbb21feff48bf6aac187294f1b")

    if is_plat("windows") then
        add_syslinks("gdiplus")
    elseif is_plat("macosx") then
        add_frameworks("CoreFoundation", "ApplicationServices")
    end

    add_deps("cmake", "zlib", "giflib", "libsndfile", "libpng", "libjpeg-turbo", "libtiff")
    on_load("windows", function (package)
        package:add("defines", package:config("shared") and "SIMAGE_DLL" or "SIMAGE_NOT_DLL")
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DSIMAGE_BUILD_EXAMPLES=OFF", "-DSIMAGE_BUILD_TESTS=OFF", "-DSIMAGE_USE_QIMAGE=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DSIMAGE_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DSIMAGE_USE_MSVC_STATIC_RUNTIME=" .. (package:config("vs_runtime"):startswith("MT") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("simage_read_image", {includes = "simage.h"}))
    end)
