package("pkgconf")
    set_kind("binary")
    set_homepage("http://pkgconf.org")
    set_description("A program which helps to configure compiler and linker flags for development frameworks.")
    add_urls("https://distfiles.dereferenced.org/pkgconf/pkgconf-$(version).tar.xz")
    add_versions("1.7.4", "d73f32c248a4591139a6b17777c80d4deab6b414ec2b3d21d0a24be348c476ab")

    on_load("windows", function(package)
        package:add("deps", "meson")
        package:add("deps", "ninja")
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
        import("package.tools.meson").install(package, {"-Dtests=false"})
    end)

    on_test(function (package)
        os.vrun("pkgconf --version")
    end)
