package("odbc")
    set_homepage("https://github.com/lurcher/unixODBC")
    set_description("The unixODBC Project goals are to develop and promote unixODBC to be the definitive standard for ODBC on non MS Windows platforms.")
    set_license("LGPL-2.1, LGPL-2.1")

    add_urls("https://github.com/lurcher/unixODBC/releases/download/2.3.11/unixODBC-$(version).tar.gz",
             "https://github.com/lurcher/unixODBC.git")
    add_versions("2.3.11", "d9e55c8e7118347e3c66c87338856dad1516b490fb7c756c1562a2c267c73b5c")

    if is_plat("linux") then
        add_syslinks("dl")
    end

    on_install("linux", function (package)
        configs = {}
        table.insert(configs, "--prefix=" .. package:installdir())
        table.insert(configs, "--sysconfdir=" .. package:installdir())
        table.insert(configs, "--enable-gui=" .. "no")
        table.insert(configs, "--disable-nls")
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        os.vrunv("./configure", configs)
        import("package.tools.make").install(package)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                SQLHENV henv;
                SQLHDBC hdbc;
                SQLRETURN retcode;

                SQLAllocHandle(SQL_HANDLE_ENV, SQL_NULL_HANDLE, &henv);
                SQLSetEnvAttr(henv, SQL_ATTR_ODBC_VERSION, (void*)SQL_OV_ODBC3, 0);
                SQLAllocHandle(SQL_HANDLE_DBC, henv, &hdbc);
                SQLSetConnectAttr(hdbc, SQL_ATTR_ODBC_CURSORS, (void*)SQL_CUR_USE_ODBC, 0);
                retcode = SQLConnect(hdbc, (unsigned char*)"postgres", SQL_NTS, (unsigned char*)"", SQL_NTS, (unsigned char*)"", SQL_NTS);
            }
        ]]}, {configs = {languages = "c99"}, includes = {"sql.h", "sqlext.h"}}))
    end)
