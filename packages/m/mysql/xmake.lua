package("mysql")

    set_homepage("https://dev.mysql.com/doc/refman/5.7/en/")
    set_description("Open source relational database management system.")

    if is_plat("windows") then
        if is_arch("x86") then
            set_urls("https://downloads.mysql.com/archives/get/p/19/file/mysql-connector-c-$(version)-win32.zip")
            add_versions("6.1.11", "a32487407bc0c4e217d8839892333fb0cb39153194d2788f226e9c5b9abdd928")
        elseif is_arch("x64") then
            set_urls("https://downloads.mysql.com/archives/get/p/19/file/mysql-connector-c-$(version)-winx64.zip")
            add_versions("6.1.11", "3555641cea2da60435ab7f1681a94d1aa97341f1a0f52193adc82a83734818ca")
        end
    else 
        set_urls("https://cdn.mysql.com/archives/mysql-5.7/mysql-boost-$(version).tar.gz",
                 "https://github.com/xmake-mirror/mysql-boost/releases/download/$(version)/mysql-boost-$(version).tar.gz")
        add_versions("5.7.29", "00f514124de2bad1ba7b380cbbd46e316cae7fc7bc3a5621456cabf352f27978")
    end

    
    if is_plat("macosx", "linux") then
        add_includedirs("include/mysql")
        add_deps("cmake", "openssl")
        if is_plat("linux") then
            add_deps("ncurses")
        end
    end

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

    on_install("windows", function (package)
        os.cp("include", package:installdir())
        if package:config("shared") then
            os.cp("lib", package:installdir())
            os.rm(package:installdir() .. "lib" .. "/vs12")
            os.rm(package:installdir() .. "lib" .. "/vs14")  
        else
            package:add("syslinks", "advapi32")
            package:add("syslinks", "msvcrt")
            os.cp("lib/vs14/mysqlclient.lib", package:installdir("lib"))
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mysql_init", {includes = "mysql.h"}))
    end)
