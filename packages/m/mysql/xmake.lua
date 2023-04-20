package("mysql")

    set_homepage("https://dev.mysql.com/doc/refman/5.7/en/")
    set_description("Open source relational database management system.")

    if is_plat("macosx", "linux") then
        set_urls("https://cdn.mysql.com/archives/mysql-5.7/mysql-boost-$(version).tar.gz",
                 "https://github.com/xmake-mirror/mysql-boost/releases/download/$(version)/mysql-boost-$(version).tar.gz")
        add_versions("5.7.29", "00f514124de2bad1ba7b380cbbd46e316cae7fc7bc3a5621456cabf352f27978")
    end

    if is_plat("windows") then
        set_urls("https://dev.mysql.com/get/Downloads/MySQL-8.0/mysql-$(version).tar.gz")
        add_versions("8.0.31", "67bb8cba75b28e95c7f7948563f01fb84528fcbb1a35dba839d4ce44fe019baa")

        add_configs("shared", {description = "Download shared binaries.", default = false, type = "boolean"})
        add_configs("vs_runtime", {description = "Set vs compiler runtime.", default = "MT"})
    end
    
    if is_plat("macosx", "linux", "windows") then
        add_deps("cmake", "openssl")
        if is_plat("linux") then
            add_deps("ncurses")
        end
    end

    add_includedirs("include", "include/mysql")

    on_load("windows", function(package) 
        if package:version():ge("8.0.0") then
            package:add("deps", "boost")
            package:add("deps", "openssl 1.1.1-t")
            package:add("deps", "zlib v1.2.13")
            package:add("deps", "zstd")
            package:add("deps", "lz4")
        end
    end)

    on_install("windows", function (package)
        io.gsub("CMakeLists.txt", "ADD_SUBDIRECTORY%(storage/ndb%)", "")
        local configs = {"-DCOMPILATION_COMMENT=XMake",
                         "-DDEFAULT_CHARSET=utf8",
                         "-DDEFAULT_COLLATION=utf8_general_ci",
                         "-DINSTALL_DOCDIR=share/doc/#{name}",
                         "-DINSTALL_INCLUDEDIR=include/mysql",
                         "-DINSTALL_INFODIR=share/info",
                         "-DINSTALL_MANDIR=share/man",
                         "-DINSTALL_MYSQLSHAREDIR=share/mysql",
                         "-DWITH_EDITLINE=" .. (is_plat("macosx") and "system" or "bundled"),
                         "-DWITH_UNIT_TESTS=OFF",
                         "-DDISABLE_SHARED=" .. (package:config("shared") and "OFF" or "ON"),
                         "-DWITH_LZ4='system'",
                         "-DWITH_ZSTD='system'",
                         "-DWITH_ZLIB='system'",
                         "-DWINDOWS_RUNTIME_MD=" .. (package:config("vs_runtime"):startswith("MD") and "ON" or "OFF"),
                         "-DWITHOUT_SERVER=ON"}
        io.replace("cmake/ssl.cmake","IF(NOT OPENSSL_APPLINK_C)","IF(FALSE AND NOT OPENSSL_APPLINK_C)", {plain = true})
        for _, removelib in ipairs({"icu", "libevent", "re2", "rapidjson", "protobuf", "libedit"}) do
            io.replace("CMakeLists.txt", "MYSQL_CHECK_" .. string.upper(removelib) .. "()\n", "", {plain = true})
            io.replace("CMakeLists.txt", "INCLUDE(" .. removelib .. ")\n", "", {plain = true})
            io.replace("CMakeLists.txt", "WARN_MISSING_SYSTEM_" .. string.upper(removelib) .. "(" .. string.upper(removelib) .. "_WARN_GIVEN)", "# WARN_MISSING_SYSTEM_" .. string.upper(removelib) .. "(" .. string.upper(removelib) .. "_WARN_GIVEN)", {plain = true})
            io.replace("CMakeLists.txt", "SET(" .. string.upper(removelib) .. "_WARN_GIVEN)", "# SET(" .. string.upper(removelib) .. "_WARN_GIVEN)", {plain = true})
        end
        os.rmdir("extra")
        for _, folder in ipairs({"client", "man", "mysql-test", "libbinlogstandalone"}) do
            os.rmdir(folder)
            io.replace("CMakeLists.txt", "ADD_SUBDIRECTORY(" .. folder .. ")\n", "", {plain = true})
        end
        os.rmdir("storage/ndb")
        for _, line in ipairs({"INCLUDE(cmake/boost.cmake)\n", "MYSQL_CHECK_EDITLINE()\n"}) do
            io.replace("CMakeLists.txt", line, "", {plain = true})
        end
        io.replace("libbinlogevents/CMakeLists.txt", "INCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/libbinlogevents/include)", "MY_INCLUDE_SYSTEM_DIRECTORIES(LZ4)\nINCLUDE_DIRECTORIES(${CMAKE_SOURCE_DIR}/libbinlogevents/include)", {plain = true})
        io.replace("cmake/install_macros.cmake", "  INSTALL_DEBUG_SYMBOLS(","  # INSTALL_DEBUG_SYMBOLS(", {plain = true})
        import("package.tools.cmake").install(package, configs)
        if package:config("shared") then
            os.rm(package:installdir("lib/mysqlclient.lib"))
            os.cp(package:installdir("lib/libmysql.dll"), package:installdir("bin"))
        else
            os.rm(package:installdir("lib/libmysql.lib"))
            os.rm(package:installdir("lib/libmysql.dll"))
        end
    end)

    on_install("macosx", "linux", function (package)
        -- https://bugs.mysql.com/bug.php?id=87348
        -- Fixes: "ADD_SUBDIRECTORY given source
        -- 'storage/ndb' which is not an existing"
        io.gsub("CMakeLists.txt", "ADD_SUBDIRECTORY%(storage/ndb%)", "")
        local configs = {"-DCOMPILATION_COMMENT=XMake",
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
