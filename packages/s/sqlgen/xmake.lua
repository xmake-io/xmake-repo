package("sqlgen")
    set_homepage("https://github.com/getml/sqlgen")
    set_description("sqlgen is an ORM and SQL query generator for C++-20, similar to Python's SQLAlchemy/SQLModel or Rust's Diesel.")
    set_license("MIT")

    add_urls("https://github.com/getml/sqlgen/archive/refs/tags/$(version).tar.gz",
             "https://github.com/getml/sqlgen.git")

    add_versions("v0.2.0", "c093036ebdf2aaf1003b2d1623713b97106ed43b1d39dc3d4f38e381f371799e")

    add_patches("0.2.0", "patches/0.2.0/cmake.patch", "e9819b9a8a2c8f8a5b6c553eac3bb10fc65856aa9af451f83e2dbf55ca6c66c0")

    add_deps("cmake", "reflect-cpp")

    add_configs("mysql", {description = "Enable MySQL Support", default = false, type = "boolean", readonly = true})
    add_configs("postgres", {description = "Enable PostgreSQL Support", default = true})
    add_configs("sqlite", {description = "Enable SQLite Support", default = true})

    if is_plat("windows") then
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_load(function (package)
        if package:config("mysql") then
            package:add("deps", "mariadb-connector-c")
        end
        if package:config("postgres") then
            package:add("deps", "libpq")
        end
        if package:config("sqlite") then
            package:add("deps", "sqlite3")
        end
    end)

    on_check(function (package)
        if package:config("postgres") then
            assert(not package:is_arch("arm64"), "package(%s) does not support arm64", package:name())
        end
    end)

    on_install("windows", "macosx", "linux", "bsd", function (package)
        local configs = {
            "-DSQLGEN_USE_VCPKG=OFF",
        }
        table.insert(configs, "-DSQLGEN_MYSQL=" .. (package:config("mysql") and "ON" or "OFF"))
        table.insert(configs, "-DSQLGEN_POSTGRES=" .. (package:config("postgres") and "ON" or "OFF"))
        table.insert(configs, "-DSQLGEN_SQLITE3=" .. (package:config("sqlite") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        if package:config("postgres") then
            assert(package:check_cxxsnippets({test = [[
                #include <sqlgen/postgres.hpp>

                const auto credentials = sqlgen::postgres::Credentials{
                    .user = "username",
                    .password = "password",
                    .host = "localhost",
                    .dbname = "mydb",
                    .port = 5432
                };

                const auto conn = sqlgen::postgres::connect(credentials);
            ]]}, {configs = {languages = "c++20"}}))
        end
        if package:config("sqlite") then
            assert(package:check_cxxsnippets({test = [[
                #include <sqlgen/sqlite.hpp>

                struct User {
                    std::string name;
                    int age;
                };

                void test() {
                    const auto conn = sqlgen::sqlite::connect("test.db");
                    const auto user = User{.name = "John", .age = 30};
                    sqlgen::write(conn, user);
                }
            ]]}, {configs = {languages = "c++20"}}))
        end
        if package:config("mysql") then
            assert(package:check_cxxsnippets({test = [[
                #include <sqlgen/mysql.hpp>

                const auto creds = sqlgen::mysql::Credentials{
                                        .host = "localhost",
                                        .user = "myuser",
                                        .password = "mypassword",
                                        .dbname = "mydatabase"
                                    };

                const auto conn = sqlgen::mysql::connect(creds);
            ]]}, {configs = {languages = "c++20"}}))
        end
    end)
