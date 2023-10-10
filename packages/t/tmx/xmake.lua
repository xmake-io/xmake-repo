package("tmx")
    set_homepage("http://libtmx.rtfd.io/")
    set_description("C tmx map loader")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/baylej/tmx/archive/refs/tags/tmx_$(version).tar.gz",
             "https://github.com/baylej/tmx.git")

    add_versions("1.2.0", "6f9ecb91beba1f73d511937fba3a04306a5af0058a4c2b623ad2219929a4116a")

    add_configs("zlib", {description = "use zlib (ability to decompress layers data)", default = false, type = "boolean"})
    add_configs("zstd", {description = "use zstd (ability to decompress layers data)", default = false, type = "boolean"})

    add_deps("cmake")
    add_deps("libxml2")

    on_load(function (package)
        if package:config("zlib") then
            package:add("deps", "zlib")
        end
        if package:config("zstd") then
            package:add("deps", "zstd")
        end
    end)

    on_install("windows", "linux", "macosx", "iphoneos", "android", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DWANT_ZLIB=" .. (package:config("zlib") and "ON" or "OFF"))
        table.insert(configs, "-DWANT_ZSTD=" .. (package:config("zstd") and "ON" or "OFF"))
        if package:config("zstd") then
            table.insert(configs, "-DZSTD_PREFER_STATIC=" .. (package:dep("zstd"):config("shared") and "OFF" or "ON"))
        end

        local packagedeps
        if package:is_plat("windows") then
            local cxflags = table.wrap(package:config("cxflags"))
            table.insert(cxflags, "-DLIBXML_STATIC");
            package:config_set("cxflags", cxflags)
            if package:config("shared") then
                local shflags = table.wrap(package:config("shflags"))
                table.insert(shflags, "ws2_32.lib");
                package:config_set("shflags", shflags)
            end
        elseif package:is_plat("android") then
            packagedeps = {"libxml2"}
            io.replace("CMakeLists.txt", "find_package(LibXml2 REQUIRED)", "", {plain = true})
            io.replace("CMakeLists.txt", "target_link_libraries(tmx LibXml2::LibXml2)", "", {plain = true})
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("tmx_load", {includes = "tmx.h"}))
    end)
