package("libxft")
    set_homepage("https://www.x.org/")
    set_description("X.Org: X FreeType library")
    set_license("MIT")

    set_urls("https://www.x.org/archive/individual/lib/libXft-$(version).tar.gz")
    add_versions("2.3.3", "3c3cf88b1a96e49a3d87d67d9452d34b6e25e96ae83959b8d0a980935014d701")
    add_versions("2.3.7", "75b4378644f5df3a15f684f8f0b5ff1324d37aacd5a381f3b830a2fbe985f660")
    add_versions("2.3.8", "32e48fe2d844422e64809e4e99b9d8aed26c1b541a5acf837c5037b8d9f278a8")

    if is_plat("linux") then
        add_extsources("apt::libxft-dev")
    end

    if is_plat("macosx", "linux") then
        add_deps("pkg-config", "fontconfig")
    end

    on_load(function (package)
        package:add("deps", "libxrender", { configs = { shared = package:config("shared") } })
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
        assert(package:has_ctypes("XftFont", {includes = "X11/Xft/Xft.h"}))
    end)
