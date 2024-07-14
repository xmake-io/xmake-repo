package("libyuv")
    set_homepage("https://chromium.googlesource.com/libyuv/libyuv/")
    set_description("libyuv is an open source project that includes YUV scaling and conversion functionality.")
    set_license("BSD-3-Clause")

    if on_source then
        on_source(function (package)
            package:add("urls", "https://github.com/lemenkov/libyuv.git")
            package:add("urls", "https://github.com/lemenkov/libyuv/archive/$(version).tar.gz", {
                alias = "github", version = import("version")
            })

            package:add("urls", "https://chromium.googlesource.com/libyuv/libyuv.git")
            package:add("urls", "https://chromium.googlesource.com/libyuv/libyuv/+archive/$(version).tar.gz", {
                alias = "home", version = import("version")
            })

            package:add("versions", "home:1891", "92eec6118d1c36c4b7dc76397351d86ec0d1da8171c63cd48d5fb130d4384c59")

            package:add("versions", "github:1891", "a8dddc6f45d6987cd3c08e00824792f3c72651fde29f475f572ee2292c03761f")
        end)
    end

    add_patches("1891", "patches/1891/cmake.patch", "72f16cfdbfe25e091add589fa1b7772c6fd6ee7b159da7ac59ac1b7d6d7f0be1")

    add_configs("jpeg", {description = "Build with JPEG.", default = false, type = "boolean"})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    add_deps("cmake")

    if is_plat("linux", "bsd") then
        add_syslinks("m")
    end

    on_load(function (package)
        if package:config("jpeg") then
            package:add("deps", "libjpeg")
        end

        if package:config("shared") then
            package:add("defines", "LIBYUV_USING_SHARED_LIBRARY")
        end
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLIBYUV_WITH_JPEG=" .. (package:config("jpeg") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_TOOLS=" .. (package:config("tools") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("I420Rotate", {includes = "libyuv/rotate.h"}))
    end)
