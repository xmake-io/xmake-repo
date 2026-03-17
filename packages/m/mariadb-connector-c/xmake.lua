package("mariadb-connector-c")
    set_homepage("https://github.com/mariadb-corporation/mariadb-connector-c")
    set_description("MariaDB Connector/C is used to connect applications developed in C/C++ to MariaDB and MySQL databases.")
    set_license("LGPL-2.1")

    add_urls("https://github.com/mariadb-corporation/mariadb-connector-c/archive/refs/tags/v$(version).tar.gz")

    add_versions("3.4.8", "ced7e5063c91fe2bfafd9d63a759490fe53e81df80599a9abad01c570c202f0c")
    add_versions("3.4.7", "cf81cd1c71c3199da9d2125aee840cb6083d43e1ea4c60c4be5045bfc7824eba")
    add_versions("3.3.9", "062b9ec5c26cbb236a78f0ba26981272053f59bdfc113040bab904a9da36d31f")
    add_versions("3.3.4", "ea6a23850d6a2f6f2e0d9e9fdb7d94fe905a4317f73842272cf121ed25903e1f")
    add_versions("3.1.13", "361136e9c365259397190109d50f8b6a65c628177792273b4acdb6978942b5e7")

    add_deps("cmake")

    add_linkdirs("lib/mariadb")

    if is_plat("windows") then
        add_configs("iconv", {description = "Enables character set conversion.", default = false, type = "boolean"})
        add_configs("msi", {description = "Build MSI installation package.", default = false, type = "boolean"})
        add_configs("rtc", {description = "Enables runtime checks for debug builds.", default = false, type = "boolean"})
        add_configs("signcode", {description = "Digitally sign files.", default = false, type = "boolean"})
    end

    if not is_plat("windows") then
        add_configs("mysqlcompat", {description = "Creates libmysql* symbolic links.", default = false, type = "boolean"})
    end

    local ssl_default_value = is_plat("windows") and "schannel" or "openssl"
    local ssl_values = is_plat("windows") and {"openssl", "openssl3", "gnutls", "schannel"} or {"openssl", "openssl3", "gnutls"}
    add_configs("ssl", {description = "Enables use of TLS/SSL library.", default = ssl_default_value, type = "string", readonly = is_plat("bsd"), values = ssl_values})
    add_configs("dyncol", {description = "Enables support of dynamic columns.", default = true, type = "boolean"})
    add_configs("curl", {description = "Enables use of curl.", default = true, type = "boolean"})
    add_configs("external_zlib", {description = "Enables use of external zlib.", default = false, type = "boolean"})
    add_configs("unit_tests", {description = "Build test suite.", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("shared") then
            if package:is_plat("windows") then
                package:add("links", "libmariadb")
            else
                package:add("links", "mariadb")
            end
        else
            package:add("links", "mariadbclient")
            if package:is_plat("windows") then
                package:add("syslinks", "secur32", "shlwapi")
            end
        end

        local configdeps = {external_zlib  = "zlib"}
        for name, dep in pairs(configdeps) do
            if package:config(name) then
                package:add("deps", dep)
            end
        end

        local ssl = package:config("ssl")
        if ssl == "schannel" then
            package:add("syslinks", "secur32", "crypt32", "bcrypt", "advapi32", "iphlpapi", "ws2_32")
        else
            package:add("deps", ssl)
        end
    end)

    on_install("bsd", "linux", "windows", function(package)
        io.replace("CMakeLists.txt", "-Werror", "", {plain = true})
        local configs = {"-DCMAKE_C_STANDARD=99"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))

        local openssl = package:dep("openssl") or package:dep("openssl3")
        if openssl then
            if not openssl:is_system() then
                table.insert(configs, "-DOPENSSL_ROOT_DIR=" .. openssl:installdir())
            end
        end

        for name, value in pairs(package:configs()) do
            if not package:extraconf("configs", name, "builtin") then
                if name == "ssl" then
                    table.insert(configs, "-DWITH_SSL=" .. value:upper())
                else
                    table.insert(configs, "-DWITH_" .. name:upper() .. (value and "=ON" or "=OFF"))
                end
            end
        end
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") then
            for _, lib in ipairs(os.files(path.join(package:installdir("lib"), "mariadb", "*.lib"))) do
                os.trycp(lib, path.join(package:installdir("lib"), path.filename(lib)))
            end
        else
            for _, lib in ipairs(os.files(path.join(package:installdir("lib"), "mariadb", "*.a"))) do
                os.trycp(lib, path.join(package:installdir("lib"), path.filename(lib)))
            end
        end
        if package:config("shared") then    
            os.trycp(path.join(package:installdir("lib"), "mariadb", "*.dll"), package:installdir("bin"))
            os.trycp(path.join(package:installdir("lib"), "mariadb", "*.so"), package:installdir("bin"))
            os.cp(path.join(package:installdir("lib"), "mariadb", "plugin"), package:installdir("bin"))
        end
    end)

    on_test(function (package)
        assert(package:has_cxxfuncs("mysql_init", {includes = "mariadb/mysql.h"}))
    end)
