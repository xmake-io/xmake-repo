package("libbigwig")
    set_homepage("https://github.com/dpryan79/libBigWig")
    set_description("A C library for handling bigWig files")
    set_license("MIT")

    add_urls("https://github.com/dpryan79/libBigWig/archive/refs/tags/$(version).tar.gz",
             "https://github.com/dpryan79/libBigWig.git")

    add_versions("0.4.8", "10e904ea6eab4c9926dd938050af888bebe6281e8d933237e4a254cb9d3063b1")
    add_versions("0.4.7", "8e057797011d93fa00e756600898af4fe6ca2d48959236efc9f296abe94916d9")

    add_configs("curl", {description = "Enable CURL support", default = false, type = "boolean"})
    add_configs("zlib_ng", {description = "Link to zlib-ng instead of zlib", default = false, type = "boolean"})

    if is_plat("linux") then
        add_syslinks("m")
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("curl") then
            package:add("deps", "libcurl")
        end
        if package:config("zlib_ng") then
            package:add("deps", "zlib-ng", {configs = {zlib_compat = true}})
        else
            package:add("deps", "zlib")
        end
    end)

    on_install("linux", "macosx", "bsd", "mingw", "msys", "android", "iphoneos", "cross", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_ZLIBNG=" .. (package:config("zlib_ng") and "ON" or "OFF"))
        if package:config("curl") then
            table.insert(configs, "-DWITH_CURL=ON")
        else
            table.insert(configs, "-DWITH_CURL=OFF")
            package:add("defines", "NOCURL")
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("bwOpen", {includes = "libbigwig/bigWig.h", {configs = {languages = "c11"}}}))
    end)
