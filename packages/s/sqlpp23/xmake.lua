package("sqlpp23")
    set_kind("library", {headeronly = true})
    set_homepage("https://github.com/rbock/sqlpp23")
    set_description("A type safe SQL template library for C++23")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/rbock/sqlpp23/archive/refs/tags/$(version).tar.gz",
             "https://github.com/rbock/sqlpp23.git")
    add_versions("0.70", "191bab5fd1094b0b5d8da7513423fc7a84e62e9da6c950096488a20e44c810fb")
    add_versions("0.69", "ff4a31f4f110623781e3fd5c49846f76bb758f0c877cb15395c50cfad7a71253")
    add_versions("0.68", "b43f2afe2eaa6b9ad41e899dd85fadcd84224b567050c00651a7112035ccaa0d")

    add_deps("cmake")

    add_configs("sqlite3",    { description = "Enable SQLite3 connector.", default = false, type = "boolean"})
    add_configs("mariadb",    { description = "Enable MariaDB connector.", default = false, type = "boolean"})
    add_configs("postgresql", { description = "Enable PostgreSQL connector.", default = false, type = "boolean"})
    add_configs("mysql",      { description = "Enable MySQL connector.", default = false, type = "boolean"})

    on_load("windows", "linux", "macosx", function (package)
        if package:config("sqlite3") then
            package:add("deps", "sqlite3")
        end
        if package:config("mariadb") then
            package:add("deps", "mariadb-connector-c")
        end
        if package:config("postgresql") then
            package:add("deps", "libpq")
        end
        if package:config("mysql") then
            package:add("deps", "mysql")
        end
    end)

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DBUILD_TESTING=OFF", "-DBUILD_sqlcipher=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        if package:config("sqlite3") then
            table.insert(configs, "-DBUILD_sqlite3=ON")
        end
        if package:config("mariadb") then
            table.insert(configs, "-DBUILD_mariadb=ON")
            local mariadb = package:dep("mariadb-connector-c")
            if mariadb then
                table.insert(configs, "-DMariaDB_INCLUDE_DIR=" .. mariadb:installdir("include/mariadb"))
                local mariadb_fetchinfo = mariadb:fetch()
                if mariadb_fetchinfo then
                    table.insert(configs, "-DMariaDB_LIBRARY=" .. table.concat(mariadb_fetchinfo.libfiles or {}, ";"))
                end
            end
        end
        if package:config("postgresql") then
            table.insert(configs, "-DBUILD_postgresql=ON")
        end
        if package:config("mysql") then
            table.insert(configs, "-DBUILD_mysql=ON")
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
        ]]}, {configs = {languages = "c++23"}, includes = {"sqlpp23/sqlpp23.h"}}))
    end)
