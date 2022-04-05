package("libxdmcp")

    set_homepage("https://www.x.org/")
    set_description("X.Org: X Display Manager Control Protocol library")

    set_urls("https://www.x.org/archive/individual/lib/libXdmcp-$(version).tar.bz2")
    add_versions("1.1.3", "20523b44aaa513e17c009e873ad7bbc301507a3224c232610ce2e099011c6529")

    if is_plat("linux") then
        add_extsources("apt::libxdmcp-dev", "pacman::libxmdcp")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "xorgproto")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--enable-docs=no"}
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:config("pic") then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_ctypes("xdmOpCode", {includes = "X11/Xdmcp.h"}))
    end)
