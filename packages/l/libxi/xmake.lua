package("libxi")

    set_homepage("https://www.x.org/")
    set_description("X.Org: Library for the X Input Extension")

    set_urls("https://www.x.org/archive/individual/lib/libXi-$(version).tar.gz")
    add_versions("1.7.10", "b51e106c445a49409f3da877aa2f9129839001b24697d75a54e5c60507e9a5e3")
    add_versions("1.8",    "c80fd200a1190e4406bb4cc6958839d9651638cb47fa546a595d4bebcd3b9e2d")
    add_versions("1.8.1",  "3b5f47c223e4b63d7f7fe758886b8bf665b20a7edb6962c423892fd150e326ea")

    if is_plat("linux") then
        add_extsources("apt::libxi-dev")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "libx11", "libxext", "libxfixes", "xorgproto")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--enable-docs=no",
                         "--enable-specs=no"}
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        if package:config("pic") then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_ctypes("XDeviceButtonEvent", {includes = "X11/extensions/XInput.h"}))
    end)
