package("mysql")
    set_homepage("http://www.mysql.com")
    set_description("A real-time, open source transactional database.")
    set_license("GPL-2.0")

    add_urls("https://github.com/mysql/mysql-server/archive/refs/tags/mysql-$(version).tar.gz")

    -- add_versions("9.0.1", "54a8a99a810c2c8ca51f11c7e5a764018066db1b75ba92c509c3794bd0cd552c")
    add_versions("8.0.39", "3a72e6af758236374764b7a1d682f7ab94c70ed0d00bf0cb0f7dd728352b6d96")

    add_configs("server", {description = "Build server", default = false, type = "boolean"})
    add_configs("curl", {description = "Build with curl", default = false, type = "boolean"})
    add_configs("kerberos", {description = "Build with kerberos", default = false, type = "boolean"})
    add_configs("fido", {description = "Build FIDO based authentication plugins", default = false, type = "boolean"})
    if is_plat("windows") then
        add_configs("debug", {description = "Enable debug symbols.", default = false, readonly = true})
    end

    add_includedirs("include", "include/mysql")

    add_deps("cmake")
    add_deps("zlib", "zstd", "lz4", "openssl", "rapidjson")
    if is_plat("linux") then
        -- TODO: improve xrepo editline
        -- add_deps("editline", {configs = {terminal_db = "ncurses"}})
        add_deps("ncurses")
    end

    if on_check then
        on_check(function (package)
            local version = package:version()
            if version:ge("9.0.0") then
                assert(package:is_arch(".*64"), "package(mysql) supports only 64-bit platforms.")
                assert(not package:is_plat("macosx"), "package(mysql >=9.0.0) need c++20 compiler")
            end
        end)
    end

    on_load(function(package)
        local version = package:version()
        if version:lt("9.0.0") then
            package:add("deps", "boost", "libevent")
        end

        if package:config("server") then
            package:add("deps", "icu4c", "protobuf-cpp")
        end

        if package:config("fido") then
            -- TODO: patch cmakelists to find our fido or let it use system libfido2
            package:add("deps", "libfido2")
        end

        if package:config("curl") then
            package:add("deps", "libcurl")
        end

        if package:config("kerberos") then
            package:add("deps", "krb5")
        end
    end)

    on_install("windows|native", "macosx", "linux", function (package)
        import("patch").cmake(package)

        local configs = {
            "-DWITH_BUILD_ID=OFF",
            "-DWITH_UNIT_TESTS=OFF",
            "-DENABLED_PROFILING=OFF",
            "-DWIX_DIR=OFF",
            "-DWITH_TEST_TRACE_PLUGIN=OFF",
            "-DMYSQL_MAINTAINER_MODE=OFF",
            "-DBUNDLE_RUNTIME_LIBRARIES=OFF",
            "-DDOWNLOAD_BOOST=OFF",
            -- "-DWITH_SYSTEM_LIBS=ON", -- It will find linux lib on windows :(
            "-DWITH_BOOST=system",
            "-DWITH_LIBEVENT=system",
            "-DWITH_ZLIB=system",
            "-DWITH_ZSTD=system",
            "-DWITH_SSL=system",
            "-DWITH_LZ4=system",
            "-DWITH_RAPIDJSON=system",
        }
        if package:is_plat("linux") then
            -- TODO: improve xrepo editline
            table.insert(configs, "-DWITH_EDITLINE=bundled")
        end

        table.insert(configs, "-DWITH_CURL=" .. (package:config("curl") and "system" or "none"))
        table.insert(configs, "-DWITH_KERBEROS=" .. (package:config("kerberos") and "system" or "none"))
        table.insert(configs, "-DWITH_FIDO=" .. (package:config("fido") and "system" or "none"))
        if package:config("server") then
            -- TODO: server deps
            table.insert(configs, "-DWITH_ICU=system")
            table.insert(configs, "-DWITH_PROTOBUF=system")
        end

        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DINSTALL_STATIC_LIBRARIES=" .. (package:config("shared") and "OFF" or "ON"))
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

        if package:is_plat("windows") then
            if package:config("shared") then
                os.tryrm(package:installdir("lib/mysqlclient.lib"))
                os.trymv(package:installdir("lib/libmysql.dll"), package:installdir("bin"))
            else
                os.tryrm(package:installdir("lib/libmysql.lib"))
                os.tryrm(package:installdir("lib/libmysql.dll"))
            end
        else
            if package:config("shared") then
                os.tryrm(package:installdir("lib/*.a"))
            else
                os.tryrm(package:installdir("lib/*.so*"))
            end
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mysql_init", {includes = "mysql.h"}))
    end)
