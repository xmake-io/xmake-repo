package("mariadb-connector-c")
    set_homepage("https://github.com/mariadb-corporation/mariadb-connector-c")
    set_description("MariaDB Connector/C is used to connect applications developed in C/C++ to MariaDB and MySQL databases.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/mariadb-corporation/mariadb-connector-c/archive/refs/tags/v$(version).tar.gz")
    add_versions("3.1.13", "361136e9c365259397190109d50f8b6a65c628177792273b4acdb6978942b5e7")
    add_deps("cmake")

    if is_plat("windows") then
        add_links("libmariadb")
    else
        add_links("mariadb")
    end

    add_linkdirs("lib/mariadb")

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean", readonly = true})

    if is_plat("windows") then
        add_configs("iconv", {description = "Enables character set conversion.", default = false, type = "boolean"})
        add_configs("msi", {description = "Build MSI installation package.", default = false, type = "boolean"})
        add_configs("rtc", {description = "Enables runtime checks for debug builds.", default = false, type = "boolean"})
        add_configs("signcode", {description = "Digitally sign files.", default = false, type = "boolean"})
    end

    if not is_plat("windows") then
        add_configs("mysqlcompat", {description = "Creates libmysql* symbolic links.", default = false, type = "boolean"})
    end

    if not is_plat("bsd") then
        add_configs("ssl", {description = "Enables use of TLS/SSL library.", default = true, type = "boolean"})
    end

    add_configs("dyncol", {description = "Enables support of dynamic columns.", default = true, type = "boolean"})
    add_configs("curl", {description = "Enables use of curl.", default = true, type = "boolean"})
    add_configs("external_zlib", {description = "Enables use of external zlib.", default = false, type = "boolean"})
    add_configs("unit_tests", {description = "Build test suite.", default = false, type = "boolean"})

    on_load(function (package)
        local configdeps = {external_zlib  = "zlib",
                            ssl            = "openssl"}
        for name, dep in pairs(configdeps) do
            if package:config(name) then
                package:add("deps", dep)
            end
        end
    end)

    on_install("bsd", "linux", "windows", function(package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        for name, enabled in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                if enabled then
                    table.insert(configs, "-DWITH_" .. name:upper() .. "=ON")
                else
                    table.insert(configs, "-DWITH_" .. name:upper() .. "=OFF")
                end
            end
        end
        import("package.tools.cmake").install(package, configs)
        os.trycp(path.join(package:installdir("lib"), "mariadb", "*.dll"), package:installdir("bin"))
        os.trycp(path.join(package:installdir("lib"), "mariadb", "*.so"), package:installdir("bin"))
        os.cp(path.join(package:installdir("lib"), "mariadb", "plugin"), package:installdir("bin"))
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("mysql_init", {includes = "mariadb/mysql.h"}))
    end)
