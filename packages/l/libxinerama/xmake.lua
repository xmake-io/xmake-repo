package("libxinerama")

    set_homepage("https://www.x.org/")
    set_description("X.Org: API for Xinerama extension to X11 Protocol")

    set_urls("https://www.x.org/archive/individual/lib/libXinerama-$(version).tar.gz")
    add_versions("1.1.5", "2efa855cb42dc620eff3b77700d8655695e09aaa318f791f201fa60afa72b95c")

    if is_plat("linux") then
        add_extsources("apt::libxinerama-dev")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "xorgproto")
    end

    on_load(function (package)
        package:add("deps", "libx11", "libxext", { configs = { shared = package:config("shared") } })
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
        assert(package:has_ctypes("XineramaScreenInfo", {includes = "X11/extensions/Xinerama.h"}))
    end)
