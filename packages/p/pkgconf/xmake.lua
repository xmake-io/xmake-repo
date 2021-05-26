package("pkgconf")
    set_kind("binary")
    set_homepage("http://pkgconf.org")
    set_description("A program which helps to configure compiler and linker flags for development frameworks.")
    add_urls("https://distfiles.dereferenced.org/pkgconf/pkgconf-$(version).tar.xz")
    add_versions("1.1.0", "5f1ef65d73a880fa5e7012102a17f7b32010e5e46139aed85851a541ba828a63")

    on_load("windows", function(package)
        package:add("deps", "cmake")
    end)

    on_install("linux", "bsd", function(package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no")) 
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes")) 
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end

        import("package.tools.autoconf").install(package, configs)
    end)

    on_install("windows", function(package)
        import("package.tools.cmake").install(package)
    end)

    on_test(function (package)
        os.vrun("pkgconf --version")
    end)
