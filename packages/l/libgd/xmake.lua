package("libgd")

    set_homepage("http://libgd.org/")
    set_description("GD is an open source code library for the dynamic creation of images by programmers.")

    add_urls("https://github.com/libgd/libgd/archive/refs/tags/gd-$(version).tar.gz")
    add_urls("https://github.com/libgd/libgd.git", {alias = "github"})

    add_versions("2.3.2", "dcc22244d775f469bee21dce1ea42552adbb72ba0cc423f9fa6a64601b3a1893")
    add_versions("github:2023.12.04", "58d25665be1c146e7284f253fa679e8256afa6cb")

    add_patches("2.3.2", path.join(os.scriptdir(), "patches", "2.3.2", "build.patch"), "87ae73df7ce126f8b31e1988aae3ecf0638eeb1c0a085689bd82045704c8171c")

    local configdeps = {png      = "libpng",
                        liq      = "libimagequant",
                        jpeg     = "libjpeg-turbo",
                        tiff     = "libtiff",
                        freetype = "freetype",
                        webp     = "libwebp",
                        avif     = "libavif",
                        heif     = "libheif"}
    for conf, _ in pairs(configdeps) do
        add_configs(conf, {description = "Enable " .. conf .. " support.", default = (conf == "png"), type = "boolean"})
    end

    add_deps("cmake", "zlib")
    on_load("windows", "linux", "macosx", "mingw", function (package)
        for conf, dep in pairs(configdeps) do
            if package:config(conf) then
                package:add("deps", dep)
            end
        end
        if package:is_plat("windows", "mingw") and not package:config("shared") then
            package:add("defines", "BGDWIN32")
            package:add("defines", "NONDLL")
        end
    end)

    on_install("windows", "linux", "macosx", "mingw", function (package)
        local configs = {"-DBUILD_TEST=OFF", "-DBUILD_PROGRAMS=OFF", "-DBUILD_DOCS=OFF", "-DBUILD_EXAMPLES=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DBUILD_STATIC_LIBS=" .. (package:config("shared") and "OFF" or "ON"))
        for conf, dep in pairs(configdeps) do
            if package:config(conf) then
                table.insert(configs, "-DENABLE_" .. conf:upper() .. "=ON")
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("gdImageDestroy", {includes = "gd.h"}))
    end)
