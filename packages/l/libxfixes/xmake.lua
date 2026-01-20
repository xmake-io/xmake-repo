package("libxfixes")
    set_homepage("https://www.x.org/")
    set_description("X.Org: Header files for the XFIXES extension")

    set_urls("https://www.x.org/archive/individual/lib/libXfixes-$(version).tar.gz")
    add_versions("6.0.0", "82045da5625350838390c9440598b90d69c882c324ca92f73af9f0e992cb57c7")
    add_versions("6.0.1", "e69eaa321173c748ba6e2f15c7cf8da87f911d3ea1b6af4b547974aef6366bec")

    if is_plat("linux") then
        add_extsources("apt::libxfixes-dev", "pacman::libxfixes")
    end

    if is_plat("macosx", "linux", "bsd", "cross") then
        add_deps("pkg-config", "xorgproto")
    end

    on_load(function (package)
        package:add("deps", "libx11", { configs = { shared = package:config("shared") } })
    end)

    on_install("macosx", "linux", "bsd", "cross", function (package)
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
        assert(package:has_ctypes("XFixesSelectionNotifyEvent", {includes = "X11/extensions/Xfixes.h"}))
    end)
