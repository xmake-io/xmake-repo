package("libxaw")
    set_homepage("https://gitlab.freedesktop.org/xorg/lib/libxaw")
    set_description("X.Org: X Athena Widget Set")

    set_urls("https://www.x.org/archive/individual/lib/libXaw-$(version).tar.gz")
    add_versions("1.0.14", "59cfed2712cc80bbfe62dd1aacf24f58d74a76dd08329a922077b134a8d8048f")
    add_versions("1.0.16", "012f90adf8739f2f023d63a5fee1528949cf2aba92ef7ac1abcfc2ae9cf28798")

    if is_plat("linux") then
        add_extsources("apt::libxaw7-dev", "pacman::libxaw")
    end

    on_load(function (package)
        package:add("deps", "libxmu", "libxpm", "libx11", "libxt", "libxext", "libice", "libsm", { configs = { shared = package:config("shared") } })
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"--sysconfdir=" .. package:installdir("etc"),
                         "--localstatedir=" .. package:installdir("var"),
                         "--disable-dependency-tracking",
                         "--disable-silent-rules",
                         "--disable-specs"}
        -- fix undefined reference on macOS
        if package:is_plat("macosx") then
            local cflags = {}
            local ldflags = {}
            for _, dep in ipairs(package:orderdeps()) do
                local fetchinfo = dep:fetch()
                if fetchinfo then
                    for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                        table.insert(cflags, "-I" .. includedir)
                    end
                    for _, linkdir in ipairs(fetchinfo.linkdirs) do
                        table.insert(ldflags, "-L" .. linkdir)
                    end
                    for _, link in ipairs(fetchinfo.links) do
                        table.insert(ldflags, "-l" .. link)
                    end
                end
            end
            import("package.tools.autoconf").install(package, configs, {cflags = cflags, ldflags = ldflags})
        else
            import("package.tools.autoconf").install(package, configs)
        end
    end)

    on_test(function (package)
        assert(package:has_cfuncs("XawInitializeWidgetSet", {includes = "X11/Xaw/XawInit.h"}))
    end)
