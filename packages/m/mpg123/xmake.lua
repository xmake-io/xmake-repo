package("mpg123")
    set_homepage("https://www.mpg123.de/")
    set_description("Fast console MPEG Audio Player and decoder library")

    add_urls("https://sourceforge.net/projects/mpg123/files/mpg123/$(version)/mpg123-$(version).tar.bz2")

    add_versions("1.30.2", "c7ea863756bb79daed7cba2942ad3b267a410f26d2dfbd9aaf84451ff28a05d7")

    add_deps("autoconf", "automake", "libtool")
    if is_plat("linux") then
        add_syslinks("m")
    end

    on_install("linux", "macosx", "android", "iphoneos", "bsd", "cross", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:debug() then
            table.insert(configs, "--enable-debug")
        end
        if package:is_plat("linux") and package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("mpg123_init", {includes = "mpg123.h"}))
    end)
