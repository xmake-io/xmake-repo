package("nanodbc")
    set_homepage("https://github.com/nanodbc/nanodbc")
    set_description("A small C++ wrapper for the native C ODBC API | Requires C++14 since v2.12")
    set_license("MIT")

    add_urls("https://github.com/nanodbc/nanodbc/archive/refs/tags/$(version).tar.gz",
             "https://github.com/nanodbc/nanodbc.git")
    add_versions("v2.14.0", "56228372042b689beccd96b0ac3476643ea85b3f57b3f23fb11ca4314e68b9a5")

    add_deps("cmake")

    add_configs("async", {description = "nanodbc disable async", default = true, type = "boolean"})
    add_configs("mssql_tvp", {description = "nanodbc disable mssql tvp", default = true, type = "boolean"})
    add_configs("unicode", {description = "nanodbc enable unicode", default = false, type = "boolean"})
    add_configs("nodata", {description = "nanodbc enable workaround nodata", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("shared") then
            package:add("deps", "odbc", {configs = {shared = true}})
        else
            package:add("deps", "odbc")
        end
    end)

    on_install("linux", function (package)
        local configs = {"-DNANODBC_DISABLE_EXAMPLES=ON","-DNANODBC_DISABLE_TESTS=ON"}
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DNANODBC_DISABLE_ASYNC=" .. (package:config("async") and "OFF" or "ON"))
        table.insert(configs, "-DNANODBC_DISABLE_MSSQL_TVP=" .. (package:config("mssql_tvp") and "OFF" or "ON"))
        table.insert(configs, "-DNANODBC_ENABLE_UNICODE=" .. (package:config("unicode") and "ON" or "OFF"))
        table.insert(configs, "-DNANODBC_ENABLE_WORKAROUND_NODATA=" .. (package:config("nodata") and "ON" or "OFF"))
        table.insert(configs, "-DNANODBC_ODBC_VERSION=SQL_OV_ODBC3")
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                nanodbc::connection conn;
                try
                {
                    std::cout << conn.connected() << std::endl;
                }
                catch (nanodbc::database_error const& e)
                {
                    std::cout << "Connection not open - OK" << std::endl;
                }
            }
        ]]}, {configs = {languages = "c++14"}, includes = {"nanodbc/nanodbc.h", "iostream"}}))
    end)
