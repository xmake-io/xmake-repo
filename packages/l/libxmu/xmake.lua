package("libxmu")
    set_homepage("https://gitlab.freedesktop.org/xorg/lib/libxmu")
    set_description("X.Org: X miscellaneous utility routines library")

    add_urls("https://www.x.org/archive/individual/lib/libXmu-$(version).tar.gz")
    add_versions("1.1.3", "5bd9d4ed1ceaac9ea023d86bf1c1632cd3b172dce4a193a72a94e1d9df87a62e")
    add_versions("1.2.1", "bf0902583dd1123856c11e0a5085bd3c6e9886fbbd44954464975fd7d52eb599")

    if is_plat("linux") then
        add_extsources("apt::libxmu-dev", "pacman::libxmu")
    end

    on_load(function (package)
        package:add("deps", "libxt", "libxext", { configs = { shared = package:config("shared") } })
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules"}
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:config("pic") then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("XmuNewArea", {includes = "X11/Xmu/Xmu.h"}))
    end)
