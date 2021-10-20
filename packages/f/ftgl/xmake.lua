package("ftgl")

    set_homepage("https://github.com/frankheckenbach/ftgl")
    set_description("FTGL is a free open source library to enable developers to use arbitrary fonts in their OpenGL applications.")
    set_license("MIT")

    add_urls("https://github.com/frankheckenbach/ftgl/archive/refs/tags/$(version).tar.gz")
    add_versions("v2.4.0", "aa97da1c3442a8fd3941037655df18016d70b5266381c81d81e8b5335f196ea8")

    add_patches("v2.4.0", path.join(os.scriptdir(), "patches", "2.4.0", "cmake.patch"), "9006ccfba2632c5ffee50c76f163a98d9867a3e11c6390c14ed07ab401a85f29")

    add_deps("cmake", "freetype", "opengl")
    on_load("windows", function (package)
        if not package:config("shared") then
            package:add("defines", "FTGL_LIBRARY_STATIC")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        local configs = {"-DBUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("FTPixmapFont", {includes = "FTGL/ftgl.h"}))
    end)
