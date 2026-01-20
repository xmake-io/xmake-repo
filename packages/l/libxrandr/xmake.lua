package("libxrandr")
    set_homepage("https://www.x.org/")
    set_description("X.Org: X Resize, Rotate and Reflection extension library")

    set_urls("https://www.x.org/archive/individual/lib/libXrandr-$(version).tar.gz")
    add_versions("1.5.2", "3f10813ab355e7a09f17e147d61b0ce090d898a5ea5b5519acd0ef68675dcf8e")
    add_versions("1.5.4", "c72c94dc3373512ceb67f578952c5d10915b38cc9ebb0fd176a49857b8048e22")

    if is_plat("linux") then
        add_extsources("apt::libxrandr-dev")
    end

    if is_plat("macosx", "linux", "bsd", "cross") then
        add_deps("pkg-config", "xorgproto")
    end

    on_load(function (package)
        package:add("deps", "libx11", "libxext", "libxrender", { configs = { shared = package:config("shared") } })
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
        if package:is_cross() then
            table.insert(configs, "--disable-malloc0returnsnull")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_ctypes("XRRScreenSize", {includes = "X11/extensions/Xrandr.h"}))
    end)
