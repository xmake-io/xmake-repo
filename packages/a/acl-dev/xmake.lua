package("acl-dev")

    set_homepage("https://github.com/acl-dev/acl")
    set_description("C/C++ server and network library")

    add_urls("https://github.com/acl-dev/acl/archive/refs/tags/v$(version).zip")
    add_versions("3.6.1-7", "b80b4304b11f3b89decd276ecbdb8f7bbbe422c4b2a56eea069cb25116f24d6c")

    add_configs("mbedtls", {description = "enable mbedtls", default = false, type = "boolean"})
    add_configs("mbedtls_dll", {description = "enable mbedtls DLL", default = false, type = "boolean"})

    add_configs("mysql", {description = "enable mysql", default = false, type = "boolean"})
    add_configs("mysql_dll", {description = "enable mysql DLL", default = false, type = "boolean"})

    add_configs("sqlite", {description = "enable sqlite", default = false, type = "boolean"})
    add_configs("sqlite_dll", {description = "enable sqlite DLL", default = false, type = "boolean"})

    add_configs("postgresql", {description = "enable postgresql", default = false, type = "boolean"})
    add_configs("postgresql_dll", {description = "enable postgresql DLL", default = false, type = "boolean"})
    
    add_configs("openssl", {description = "enable openssl", default = false, type = "boolean"})
    add_configs("openssl_dll", {description = "enable openssl DLL", default = false, type = "boolean"})



    add_deps("cmake")

    on_load(function (package)
        package:add("linkorders", {"lib_acl_cpp", "lib_protocol", "lib_acl"})

        if package:is_plat("windows")then
            package:add("syslinks", "user32", "gdi32")
        end
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "ACL_DLL", "HTTP_DLL", "ICMP_DLL", "ACL_CPP_DLL")
        end
        if package:config("mbedtls") or package:config("mbedtls_dll") then
            package:add("deps", "mbedtls")
        end
        if package:config("mysql") or package:config("mysql_dll") then
            package:add("deps", "mysql")
        end
        if package:config("sqlite") or package:config("sqlite_dll") then
            package:add("deps", "sqlite")
        end
        if package:config("postgresql") or package:config("postgresql_dll") then
            package:add("deps", "postgresql")
        end
        if package:config("openssl") or package:config("openssl_dll") then
            package:add("deps", "openssl")
        end
    end)

    on_install("windows", "linux", "macos", "mingw", "android", "freebsd", function (package)
        local configs = {}
        local cxflags = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        if package:config("shared") and package:is_plat("windows") then
            table.insert(configs, "-DACL_BUILD_SHARED=YES")
            table.insert(cxflags, "/DACL_PREPARE_COMPILE")
            table.insert(cxflags, "/DACL_DLL")
            table.insert(cxflags, "/DACL_EXPORTS")
            table.insert(cxflags, "/D_WINDLL")
        end
        if package:config("mbedtls") then
            table.insert(configs, "-DHAS_MBEDTLS=YES")
        end
        if package:config("mbedtls_dll") then
            table.insert(configs, "-DHAS_MBEDTLS_DLL=YES")
        end
        if package:config("mysql") then
            table.insert(configs, "-DDISABLE_DB=NO")
            table.insert(configs, "-DHAS_MYSQL=YES")
        end
        if package:config("mysql_dll") then
            table.insert(configs, "-DDISABLE_DB=NO")
            table.insert(configs, "-DHAS_MYSQL_DLL=YES")
        end
        if package:config("sqlite") then
            table.insert(configs, "-DDISABLE_DB=NO")
            table.insert(configs, "-DHAS_SQLITE=YES")
        end
        if package:config("sqlite_dll") then
            table.insert(configs, "-DDISABLE_DB=NO")
            table.insert(configs, "-DHAS_SQLITE_DLL=YES")
        end
        if package:config("postgresql") then
            table.insert(configs, "-DDISABLE_DB=NO")
            table.insert(configs, "-DHAS_PGSQL=YES")
        end
        if package:config("postgresql_dll") then
            table.insert(configs, "-DDISABLE_DB=NO")
            table.insert(configs, "-DHAS_PGSQL_DLL=YES")
        end
        if package:config("openssl") then
            table.insert(configs, "-DHAS_OPENSSL=YES")
        end
        if package:config("openssl_dll") then
            table.insert(configs, "-DHAS_OPENSSL_DLL=YES")
        end
        
        import("package.tools.cmake").install(package, configs, {cxflags = cxflags})


        os.cp(path.translate("lib_acl_cpp/include/*"), package:installdir("include"))
        os.cp(path.translate("lib_protocol/include/*"), package:installdir("include"))
        os.cp(path.translate("lib_acl/include/*"), package:installdir("include"))
        os.cp(path.translate("lib_fiber/c/include/*"), package:installdir("include"))
        os.cp(path.translate("lib_fiber/cpp/include/*"), package:installdir("include"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("acl_fiber_recv", {includes = "fiber/lib_fiber.h"}))
        assert(package:check_cxxsnippets({test = [[
            void test() {
                acl::string buf = "hello world!\r\n";
            }
        ]]}, {includes = "acl_cpp/lib_acl.hpp"}))
    end)
