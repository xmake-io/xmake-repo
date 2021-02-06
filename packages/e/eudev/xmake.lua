package("eudev")

    set_homepage("https://dev.gentoo.org/~blueness/eudev/")
    set_description("A fork of systemd with the aim of isolating udev from any particular flavor of system initialization.")

    add_urls("https://dev.gentoo.org/~blueness/eudev/eudev-$(version).tar.gz")
    add_versions("3.2.9", "89618619084a19e1451d373c43f141b469c9fd09767973d73dd268b92074d4fc")

    if is_plat("linux") then
        add_deps("autoconf", "automake", "libtool", "pkg-config", "gperf")
    end

    on_install("linux", function (package)
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
        else
            table.insert(configs, "--enable-shared=no")
        end
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)


    on_test(function (package)
        assert(package:has_cfuncs("udev_new", {includes = "libudev.h"}))
    end)
