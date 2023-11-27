package("soci")
    set_homepage("http://soci.sourceforge.net/")
    set_description("Official repository of the SOCI - The C++ Database Access Library")
    set_license("BSL-1.0")

    add_urls("https://github.com/SOCI/soci/archive/refs/tags/$(version).tar.gz",
             "https://github.com/SOCI/soci.git")

    add_versions("v4.0.3", "4b1ff9c8545c5d802fbe06ee6cd2886630e5c03bf740e269bb625b45cf934928")

    add_configs("empty", {description = "Build empty backend", default = false, type = "boolean"})
    add_configs("sqlite3", {description = "Build sqlite3 backend", default = false, type = "boolean"})
    add_configs("db2", {description = "Build db2 backend", default = false, type = "boolean"})
    add_configs("odbc", {description = "Build odbc backend", default = false, type = "boolean"})
    add_configs("oracle", {description = "Build oracle backend", default = false, type = "boolean"})
    add_configs("firebird", {description = "Build firebird backend", default = false, type = "boolean"})
    add_configs("mysql", {description = "Build mysql backend", default = false, type = "boolean"})
    add_configs("postgresql", {description = "Build postgresql backend", default = false, type = "boolean"})
    add_configs("boost", {description = "Build boost backend", default = false, type = "boolean"})

    add_deps("cmake")

    on_install(function (package)
        for _, pkg in ipairs({"sqlite3", "mysql", "postgresql"}) do
            if package:config(pkg) then
                package:add("deps", pkg)
            end
        end
    end)

    on_install(function (package)
        local configs = {"-DSOCI_TESTS=OFF", "-DSOCI_CXX11=ON"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DSOCI_SHARED=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DSOCI_STATIC=" .. (package:config("shared") and "OFF" or "ON"))
        table.insert(configs, "-DSOCI_LTO=" .. (package:config("lto") and "ON" or "OFF"))
        table.insert(configs, "-DSOCI_ASAN=" .. (package:config("asan") and "ON" or "OFF"))
        table.insert(configs, "-DSOCI_EMPTY=" .. (package:config("empty") and "ON" or "OFF"))
        for name, enabled in pairs(package:configs()) do
            if (not package:extraconf("configs", name, "builtin")) and (name ~= "empty") then
                table.insert(configs, "-DWITH_" .. name:upper() .. "=" .. (package:config(name) and "ON" or "OFF"))
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <soci/soci.h>
            void test() {
                soci::session sql("connectString");
            }
        ]]}, {configs = {languages = "c++14"}}))
    end)
