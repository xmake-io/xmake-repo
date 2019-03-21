package("mysql-client")

    set_homepage("https://dev.mysql.com/doc/refman/5.7/en/")
    set_description("Open source relational database management system.")

    set_urls("https://cdn.mysql.com/Downloads/MySQL-5.7/mysql-boost-$(version).tar.gz")

    add_versions("5.7.23", "d05700ec5c1c6dae9311059dc1713206c29597f09dbd237bf0679b3c6438e87a")

    if is_plat("macosx", "linux") then
        add_deps("cmake", "openssl")
    end
    add_includedirs("include")

    on_install("macosx", "linux", function (package)
        -- https://bugs.mysql.com/bug.php?id=87348
        -- Fixes: "ADD_SUBDIRECTORY given source
        -- 'storage/ndb' which is not an existing"
        io.gsub("CMakeLists.txt", "ADD_SUBDIRECTORY%(storage/ndb%)", "")
        local configs = { "-DCOMPILATION_COMMENT=XMake",
                          "-DDEFAULT_CHARSET=utf8",
                          "-DDEFAULT_COLLATION=utf8_general_ci",
                          "-DINSTALL_DOCDIR=share/doc/#{name}",
                          "-DINSTALL_INCLUDEDIR=include/mysql",
                          "-DINSTALL_INFODIR=share/info",
                          "-DINSTALL_MANDIR=share/man",
                          "-DINSTALL_MYSQLSHAREDIR=share/mysql",
                          "-DWITH_BOOST=../boost",
                          "-DWITH_EDITLINE=system",
                          "-DWITH_SSL=yes",
                          "-DWITH_UNIT_TESTS=OFF",
                          "-DWITHOUT_SERVER=ON"}
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mysql_init", {includes = "mysql.h"}))
    end)
