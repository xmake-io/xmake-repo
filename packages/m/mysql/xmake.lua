package("mysql")
    set_homepage("http://www.mysql.com")
    set_description("A real-time, open source transactional database.")
    set_license("GPL-2.0")

    add_urls("https://github.com/mysql/mysql-server/archive/refs/tags/mysql-$(version).tar.gz")

    add_versions("9.0.1", "54a8a99a810c2c8ca51f11c7e5a764018066db1b75ba92c509c3794bd0cd552c")

    add_configs("server", {description = "Build server", default = false, type = "boolean"})

    add_includedirs("include", "include/mysql")

    add_deps("cmake")
    add_deps("zlib", "zstd", "lz4", "openssl", "rapidjson")

    on_load(function(package)
        if package:config("server") then
            package:add("deps", "icu4c", "protobuf-cpp", "libfido2")
        end
    end)

    on_install("windows", "macosx", "linux", "bsd", "mingw", "cross", function (package)
        local version = package:version()
        if version:eq("9.0.1") then
            io.replace("cmake/ssl.cmake", "FIND_CUSTOM_OPENSSL()", "FIND_SYSTEM_OPENSSL()", {plain = true})
        end
        if package:is_plat("windows") then
            io.replace("cmake/install_macros.cmake",
                [[NOT type MATCHES "STATIC_LIBRARY"]],
                [[CMAKE_BUILD_TYPE STREQUAL "DEBUG"]], {plain = true})
        end

        local configs = {
            "-DWITH_UNIT_TESTS=OFF",
            -- "-DWITH_SYSTEM_LIBS=ON", -- It will find linux lib on windows :(

            -- client deps
            -- "-DWITH_BOOST=system", -- cmkae/boost.cmake: Always use the bundled version.
            "-DWITH_ZLIB=system",
            "-DWITH_ZLIB=system",
            "-DWITH_SSL=system",
            "-DWITH_LZ4=system",
            "-DWITH_RAPIDJSON=system",

            -- todo: server deps
            -- "-DWITH_ICU=system",
            -- "-DWITH_PROTOBUF=system",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_LTO=" .. (package:config("lto") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_ASAN=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_LSAN=" .. (package:config("lsan") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_MSAN=" .. (package:config("msan") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_UBSAN=" .. (package:config("ubsan") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DLINK_STATIC_RUNTIME_LIBRARIES=" .. (package:has_runtime("MT", "MTd") and "ON" or "OFF"))
        end

        table.insert(configs, "-DWITHOUT_SERVER=" .. (package:config("server") and "OFF" or "ON"))
        import("package.tools.cmake").install(package, configs)

        os.trymv(package:installdir("lib/*.dll"), package:installdir("bin"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mysql_init", {includes = "mysql.h"}))
    end)
