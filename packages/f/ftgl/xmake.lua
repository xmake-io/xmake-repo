package("ftgl")
    set_homepage("https://github.com/frankheckenbach/ftgl")
    set_description("FTGL is a free open source library to enable developers to use arbitrary fonts in their OpenGL applications.")
    set_license("MIT")

    add_urls("https://github.com/frankheckenbach/ftgl/archive/refs/tags/$(version).tar.gz",
             "https://github.com/frankheckenbach/ftgl.git")

    add_versions("v2.4.0", "aa97da1c3442a8fd3941037655df18016d70b5266381c81d81e8b5335f196ea8")

    add_patches("v2.4.0", "patches/2.4.0/cmake.patch", "9006ccfba2632c5ffee50c76f163a98d9867a3e11c6390c14ed07ab401a85f29")
    add_patches("v2.4.0", "patches/2.4.0/cmake-freetype.patch", "ac43983c5d09e10db36395b68602e0f825643ae2bf3ba8415600de30608aaee9")
    add_patches("v2.4.0", "patches/2.4.0/fix-type-error.patch", "6d5080d92e8d18d39d7f4ad9279bae555fa8af6f9dcfe3b437647e09ffc88312")

    add_deps("cmake")
    if is_subhost("windows") then
        add_deps("pkgconf")
    else
        add_deps("pkg-config")
    end
    add_deps("freetype", {configs = {zlib = true}})
    add_deps("opengl", {optional = true})

    on_load("windows", "mingw", function (package)
        if not package:config("shared") then
            package:add("defines", "FTGL_LIBRARY_STATIC")
        end
    end)

    on_install("!android and !cross and !iphoneos and !bsd", function (package)
        local configs = {"-DBUILD_TESTS=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cxxtypes("FTPixmapFont", {includes = "FTGL/ftgl.h"}))
    end)
