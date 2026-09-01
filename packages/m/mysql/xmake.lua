package("mysql")
    set_homepage("http://www.mysql.com")
    set_description("A real-time, open source transactional database.")
    set_license("GPL-2.0")

    add_urls("https://github.com/mysql/mysql-server/archive/refs/tags/mysql-$(version).tar.gz",
             "https://github.com/mysql/mysql-server.git")

    add_versions("8.0.40", "746c111747ba56ac9cdcd3d47867ee9f2e7d5d6230a1fd3401723db997e33f28")
    add_versions("8.0.39", "3a72e6af758236374764b7a1d682f7ab94c70ed0d00bf0cb0f7dd728352b6d96")

    add_configs("server", {description = "Build server", default = false, type = "boolean"})
    add_configs("curl", {description = "Build with curl", default = false, type = "boolean"})
    add_configs("kerberos", {description = "Build with kerberos", default = false, type = "boolean"})
    add_configs("fido", {description = "Build FIDO based authentication plugins", default = false, type = "boolean"})
    add_configs("x", {description = "Build MySQL X plugin", default = false, type = "boolean"})
    if is_plat("windows") then
        add_configs("debug", {description = "Enable debug symbols.", default = false, readonly = true})
    end

    if is_plat("linux") then
        add_extsources("apt::libmysqlclient-dev")
    elseif is_plat("macosx") then
        add_extsources("brew::mysql-client")
    end

    add_includedirs("include", "include/mysql")

    add_deps("cmake")
    add_deps("zlib", "zstd", "lz4", "openssl", "rapidjson")
    if is_plat("linux") then
        add_deps("patchelf")
        add_deps("libedit", {configs = {terminal_db = "ncurses"}})
    end
    if is_plat("windows") then
        add_deps("ninja")
        set_policy("package.cmake_generator.ninja", true)
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
            package:add("deps", "boost", {configs = {header_only = true}})
            package:add("deps", "libevent")
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

        if package:is_cross() then
            package:add("deps", "mysql-build-tools")
            package:add("patches", "8.0.39", "patches/8.0.39/cmake-cross-compilation.patch", "0f951afce6bcbc5b053d4e7e4aef57f602ff89960d230354f36385ca31c1c7a5")
        end
    end)

    on_install("windows", "macosx", "linux", function (package)
        import("patch").cmake(package)

        local is_shared = package:config("shared")
        local configs = import("configs").get(package, false)
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (is_shared and "ON" or "OFF"))
        table.insert(configs, "-DINSTALL_STATIC_LIBRARIES=" .. (is_shared and "OFF" or "ON"))
        table.insert(configs, "-DWITH_LTO=" .. (package:config("lto") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_ASAN=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_LSAN=" .. (package:config("lsan") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_MSAN=" .. (package:config("msan") and "ON" or "OFF"))
        table.insert(configs, "-DWITH_UBSAN=" .. (package:config("ubsan") and "ON" or "OFF"))
        if package:is_plat("windows") then
            table.insert(configs, "-DLINK_STATIC_RUNTIME_LIBRARIES=" .. (package:has_runtime("MT", "MTd") and "ON" or "OFF"))
        end
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") then
            if is_shared then
                os.tryrm(package:installdir("lib/mysqlclient.lib"))
                os.trymv(package:installdir("lib/libmysql.dll"), package:installdir("bin"))
            else
                os.tryrm(package:installdir("lib/libmysql.lib"))
                os.tryrm(package:installdir("lib/libmysql.dll"))
            end
        else
            if is_shared then
                os.tryrm(package:installdir("lib/*.a"))
            else
                os.tryrm(package:installdir("lib/*.so*"))
                os.tryrm(package:installdir("lib/*.dylib"))
            end
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mysql_init", {includes = "mysql.h"}))
    end)
