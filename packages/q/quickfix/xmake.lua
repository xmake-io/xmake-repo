package("quickfix")
    set_homepage("https://github.com/quickfix/quickfix")
    set_description("A free and open source implementation of the FIX protocol.")
    set_license("QuickFIX")

    add_urls("https://github.com/quickfix/quickfix/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/quickfix/quickfix.git")
    add_versions("1.16.0", "6eb0e678288473e57db220d3bf53c4d5c92814629ca548af09ca7e365fd7ee70")

    add_configs("ssl",        {description = "Enable SSL/TLS support.", default = false, type = "boolean"})
    add_configs("mysql",      {description = "Enable MySQL message store.", default = false, type = "boolean"})
    add_configs("postgresql", {description = "Enable PostgreSQL message store.", default = false, type = "boolean"})

    add_deps("cmake")

    on_load(function (package)
        if package:config("ssl") then
            package:add("deps", "openssl")
        end
        if package:config("mysql") then
            package:add("deps", "mariadb-connector-c")
        end
        if package:config("postgresql") then
            package:add("deps", "libpq")
        end
        if package:is_plat("windows", "mingw") then
            package:add("syslinks", "ws2_32", "crypt32")
        elseif package:is_plat("linux", "bsd", "macosx") then
            package:add("syslinks", "pthread")
        end
    end)

    if on_check then
        on_check("windows", "mingw", function (package)
            assert(not package:config("shared"), "package(quickfix): shared library is not supported on windows.")
        end)
    end

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DQUICKFIX_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DQUICKFIX_EXAMPLES=OFF")
        table.insert(configs, "-DQUICKFIX_TESTS=OFF")

        local packagedeps = {}
        local ssl = package:config("ssl")
        table.insert(configs, "-DHAVE_SSL=" .. (ssl and "ON" or "OFF"))
        if ssl then
            table.insert(packagedeps, "openssl")
        end

        local mysql = package:config("mysql")
        table.insert(configs, "-DHAVE_MYSQL=" .. (mysql and "ON" or "OFF"))
        if mysql then
            -- upstream FindMySQL only searches mysqlclient/mysql.h, adapt it for mariadb-connector-c
            io.replace("cmake/FindMySQL.cmake", "FIND_PATH(MYSQL_INCLUDE_DIR mysql.h", "FIND_PATH(MYSQL_INCLUDE_DIR mariadb/mysql.h", {plain = true})
            io.replace("cmake/FindMySQL.cmake", "FIND_LIBRARY(MYSQL_LIB NAMES mysqlclient_r mysqlclient", "FIND_LIBRARY(MYSQL_LIB NAMES mariadbclient mariadb mysqlclient_r mysqlclient", {plain = true})
            io.replace("src/C++/MySQLConnection.h", "#include <errmsg.h>", "#include <mariadb/errmsg.h>", {plain = true})
            io.replace("src/C++/MySQLConnection.h", "#include <mysql.h>", "#include <mariadb/mysql.h>", {plain = true})
            table.insert(packagedeps, "mariadb-connector-c")
        end

        local postgresql = package:config("postgresql")
        table.insert(configs, "-DHAVE_POSTGRESQL=" .. (postgresql and "ON" or "OFF"))
        if postgresql then
            table.insert(packagedeps, "libpq")
        end

        import("package.tools.cmake").install(package, configs, {packagedeps = packagedeps})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                FIX::Message message;
                message.setField(35, "0");
            }
        ]]}, {configs = {languages = "c++17"}, includes = "quickfix/Message.h"}))
    end)
