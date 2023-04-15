package("mysql-connector-c")

    set_homepage("https://dev.mysql.com/doc/")
    set_description("Open source relational database management system.")

    if is_arch("x86") then
        set_urls("https://downloads.mysql.com/archives/get/p/19/file/mysql-connector-c-$(version)-win32.zip")
        add_versions("6.1.11", "a32487407bc0c4e217d8839892333fb0cb39153194d2788f226e9c5b9abdd928")
    end

    if is_arch("x64") then
        set_urls("https://downloads.mysql.com/archives/get/p/19/file/mysql-connector-c-$(version)-winx64.zip")
        add_versions("6.1.11", "3555641cea2da60435ab7f1681a94d1aa97341f1a0f52193adc82a83734818ca")
    end


    on_install("windows", function (package)
        os.cp("include/*", package:installdir("include"))
        os.cp("lib/*", package:installdir("lib"))
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mysql_init", {includes = "mysql.h"}))
    end)
