package("libstatgrab")
    set_homepage("https://libstatgrab.org/")
    set_description("A cross platform library for accessing system statistics")
    set_license("GPL-2.1")

    add_urls("https://github.com/libstatgrab/libstatgrab.git")
    add_urls("https://github.com/libstatgrab/libstatgrab/releases/download/$(version).tar.gz", {version = function (version)
        return "LIBSTATGRAB_" .. version:gsub('%.', '_') .. "/libstatgrab-" .. version
    end})

    add_versions("0.92.1", "5688aa4a685547d7174a8a373ea9d8ee927e766e3cc302bdee34523c2c5d6c11")
    
    add_configs("thread_support", {description = "support for multi-threaded environments", default = true, type = "boolean"})
    
    add_deps("automake", "autoconf", "libtool")

    if is_plat("macosx") then
        add_frameworks("IOKit", "CoreFoundation")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--disable-statgrab",
                         "--disable-saidar",
                         "--disable-man",
                         "--disable-tests"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if not package:config("thread_support") then
            table.insert(configs, "--disable-thread-support")
        else 
            package:add("syslinks", "pthread")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sg_init", {includes = "statgrab.h"}))
    end)
