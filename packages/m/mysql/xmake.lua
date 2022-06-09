package("mysql")

    set_homepage("https://dev.mysql.com/doc/refman/5.7/en/")
    set_description("Open source relational database management system.")

    set_urls("https://cdn.mysql.com/archives/mysql-5.7/mysql-boost-$(version).tar.gz",
             "https://github.com/xmake-mirror/mysql-boost/releases/download/$(version)/mysql-boost-$(version).tar.gz")

    add_versions("5.7.29", "00f514124de2bad1ba7b380cbbd46e316cae7fc7bc3a5621456cabf352f27978")

    if is_plat("macosx", "linux") then
        add_deps("cmake", "openssl")
        if is_plat("linux") then
            add_deps("ncurses")
        end
    end
    add_includedirs("include/mysql")

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
                          "-DWITH_EDITLINE=" .. (is_plat("macosx") and "system" or "bundled"),
                          "-DWITH_SSL=yes",
                          "-DWITH_UNIT_TESTS=OFF",
                          "-DWITHOUT_SERVER=ON"}
        if package:is_plat("linux") then
            local curses = package:dep("ncurses"):fetch()
            if curses then
                local includedirs = table.wrap(curses.sysincludedirs or curses.includedirs)
                local libfiles = table.wrap(curses.libfiles)
                table.insert(configs, "-DCURSES_INCLUDE_PATH=" .. table.concat(includedirs, ";"))
                table.insert(configs, "-DCURSES_LIBRARY=" .. table.concat(libfiles, ";"))
            end
        end
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mysql_init", {includes = "mysql.h"}))
    end)
