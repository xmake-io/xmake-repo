package("sqlpp11")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/rbock/sqlpp11")
    set_description("A type safe SQL template library for C++")

    add_urls("https://github.com/rbock/sqlpp11/archive/refs/tags/$(version).tar.gz",
             "https://github.com/rbock/sqlpp11.git")
    add_versions("0.61", "d5a95e28ae93930f7701f517b1342ac14bcf33a9b1c5b5f0dff6aea5e315bb50")

    add_deps("cmake")

    add_configs("sqlite3_connector",    { description = "Enable SQlite3 connector.", default = false, type = "boolean"})
    add_configs("sqlcipher_connector",  { description = "Enable SQlite3 connector with SQLCipher.", default = false, type = "boolean"})
    add_configs("mariadb_connector",    { description = "Enable MariaDB connector.", default = false, type = "boolean"})
    add_configs("postgresql_connector", { description = "Enable PostgreSQL connector.", default = false, type = "boolean"})
    add_configs("mysql_connector",      { description = "Enable MySQL connector.", default = false, type = "boolean"})

    on_load("windows", "linux", "macosx", function (package)
        if package:config("mysql_connector") then
            package:add("deps", "mysql")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:config("sqlite3_connector") then
            table.insert(configs, "-DBUILD_SQLITE3_CONNECTOR=ON")
        end
        if package:config("sqlcipher_connector") then
            table.insert(configs, "-DBUILD_SQLCIPHER_CONNECTOR=ON")
        end
        if package:config("mariadb_connector") then
            table.insert(configs, "-DBUILD_MARIADB_CONNECTOR=ON")
        end
        -- TODO we need add PostgreSQL deps
        if package:config("postgresql_connector") then
            table.insert(configs, "-DBUILD_POSTGRESQL_CONNECTOR=ON")
        end
        -- TODO we need add MySQL deps
        if package:config("mysql_connector") then
            table.insert(configs, "-DBUILD_MYSQL_CONNECTOR=ON")
            local libmysql = package:dep("mysql"):fetch()
            if libmysql then
                table.insert(configs, "-DMySQL_INCLUDE_DIR=" .. table.concat(libmysql.includedirs or libmysql.sysincludedirs, ";"))
                table.insert(configs, "-DMySQL_LIBRARY=" .. table.concat(libmysql.libfiles or {}, ";"))
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                select(sqlpp::value(false).as(sqlpp::alias::a));
            }
        ]]}, {configs = {languages = "c++14"}, includes = {"sqlpp11/sqlpp11.h"}}))
    end)
