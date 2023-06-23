package("mysqlpp")
    set_homepage("https://tangentsoft.com/mysqlpp/wiki?name=MySQL%2B%2B&p&nsm")
    set_description("MySQL++ is a C++ wrapper for the MySQL and MariaDB C APIs")

    set_urls("https://tangentsoft.com/mysqlpp/releases/mysql++-$(version).tar.gz")
    add_versions("3.3.0", "449cbc46556cc2cc9f9d6736904169a8df6415f6960528ee658998f96ca0e7cf")

    add_configs("shared", {description = "Build shared binaries.", default = true, type = "boolean", readonly = true})

    add_deps("mysql")

    on_install("windows", "mingw", function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
        os.mv(package:installdir("include/*.h"), package:installdir("include/mysql++/"))
    end)

    on_install("linux", function (package)
        os.vrunv("./configure", 
                {"--enable-shared", 
                 "--with-mysql=" .. package:dep("mysql"):installdir(),
                 "--prefix=" .. package:installdir()
                })
        os.vrunv("make", {"-j4"})
        os.vrunv("make", {"install"})
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <mysql++/mysql++.h>
            void test() {
                mysqlpp::String greeting("Hello, world!");
            }
        ]]}))
    end)
