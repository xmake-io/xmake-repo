package("libx11")
    set_homepage("https://www.x.org/")
    set_description("X.Org: Core X11 protocol client library")

    set_urls("https://www.x.org/archive/individual/lib/libX11-$(version).tar.gz")
    add_versions("1.6.9", "b8c0930a9b25de15f3d773288cacd5e2f0a4158e194935615c52aeceafd1107b")
    add_versions("1.7.0", "c48ec61785ec68fc6a9a6aca0a9578393414fe2562e3cc9cca30234345c7b6ac")
    add_versions("1.7.3", "029acf61e7e760a3150716b145a58ce5052ee953e8cccc8441d4f550c420debb")
    add_versions("1.8.1", "d52f0a7c02a45449f37b0831d99ff936d92eb4ce8b4c97dc17a63cea79ce5a76")
    add_versions("1.8.7", "793ebebf569f12c864b77401798d38814b51790fce206e01a431e5feb982e20b")
    add_versions("1.8.12", "220fbcf54b6e4d8dc40076ff4ab87954358019982490b33c7802190b62d89ce1")

    if is_plat("linux") then
        add_extsources("apt::libx11-dev", "pacman::libx11")
    elseif is_plat("macosx") then
        add_extsources("brew::libx11")
    end

    if is_plat("linux", "bsd", "cross") then
        add_syslinks("dl")
    end

    add_configs("shared", {description = "Build shared library.", default = true, type = "boolean"})

    if is_plat("macosx", "linux", "bsd", "cross") then
        add_deps("pkg-config", "util-macros", "xtrans", "xorgproto")
    end
    if is_plat("macosx") then
        -- fix sed: RE error: illegal byte sequence
        add_deps("gnu-sed")
    end

    on_load(function (package)
        package:add("deps", "libxcb", { configs = { shared = package:config("shared") } })
    end)

    on_install("macosx", "linux", "bsd", "cross", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--enable-unix-transport",
                         "--enable-tcp-transport",
                         "--enable-ipv6",
                         "--enable-loadable-i18n",
                         "--enable-xthreads",
                         "--enable-specs=no"}
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
        assert(package:has_cfuncs("XOpenDisplay", {includes = "X11/Xlib.h"}))
    end)
