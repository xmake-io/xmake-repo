package("tmx")
    set_homepage("http://libtmx.rtfd.io/")
    set_description("C tmx map loader")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/baylej/tmx/archive/refs/tags/tmx_$(version).tar.gz",
             "https://github.com/baylej/tmx.git")

    add_versions("1.10.0", "8ee42d1728c567d6047a58b2624c39c8844aaf675c470f9f284c4ed17e94188f")
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

    on_install("!iphoneos", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DWANT_ZLIB=" .. (package:config("zlib") and "ON" or "OFF"))
        table.insert(configs, "-DWANT_ZSTD=" .. (package:config("zstd") and "ON" or "OFF"))
        if package:config("zstd") then
            table.insert(configs, "-DZSTD_PREFER_STATIC=" .. (package:dep("zstd"):config("shared") and "OFF" or "ON"))
        end

        local packagedeps
        local cxflags
        local shflags
        io.replace("CMakeLists.txt", "find_package(LibXml2 REQUIRED)", "find_package(LibXml2 CONFIG REQUIRED)", {plain = true})
        if package:is_plat("windows") then
            cxflags = {"-DLIBXML_STATIC"}
            if package:config("shared") then
                shflags = {"ws2_32.lib"}
            end
        elseif package:is_plat("android") then
            packagedeps = {"libxml2"}
            io.replace("CMakeLists.txt", "find_package(LibXml2 CONFIG REQUIRED)", "", {plain = true})
            io.replace("CMakeLists.txt", "target_link_libraries(tmx LibXml2::LibXml2)", "", {plain = true})
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps, cxflags = cxflags, shflags = shflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("tmx_load", {includes = "tmx.h"}))
    end)
