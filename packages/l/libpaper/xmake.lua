package("libpaper")

    set_homepage("https://packages.debian.org/unstable/libs/libpaper1")
    set_description("library for handling paper characteristics")
    set_license("GPL-2.0")

    add_urls("http://deb.debian.org/debian/pool/main/libp/libpaper/libpaper_$(version).tar.gz")
    add_versions("1.1.28", "c8bb946ec93d3c2c72bbb1d7257e90172a22a44a07a07fb6b802a5bb2c95fddc")

    if is_plat("linux") then
        add_extsources("apt::libpaper-dev", "pacman::libpaper")
    end
    add_deps("automake", "autoconf", "libtool")
    on_install("macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        local libtool = package:dep("libtool")
        if libtool then
            os.vrunv("autoreconf", {"--install", "-I" .. libtool:installdir("share", "aclocal")})
        else
            os.vrunv("autoreconf", {"--install"})
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("paperinfo", {includes = "paper.h"}))
    end)
