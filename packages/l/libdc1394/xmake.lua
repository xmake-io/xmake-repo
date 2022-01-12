package("libdc1394")

    set_homepage("https://sourceforge.net/projects/libdc1394/")
    set_description("IIDC Camera Control Library")
    set_license("LGPL-2.1")

    add_urls("https://sourceforge.net/projects/libdc1394/files/libdc1394-2/$(version)/libdc1394-$(version).tar.gz")
    add_versions("2.2.6", "2b905fc9aa4eec6bdcf6a2ae5f5ba021232739f5be047dec8fe8dd6049c10fed")

    if is_plat("linux") then
        add_extsources("apt::libdc1394-22-dev", "pacman::libdc1394")
    end

    add_deps("libusb")
    if is_plat("macosx") then
        add_frameworks("CoreFoundation", "CoreServices", "IOKit")
    end
    on_install("macosx", "linux", function (package)
        local configs = {"--disable-dependency-tracking"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") then
            table.insert(configs, "--with-pic")
        end
        local cppflags = {}
        local ldflags = {}
        for _, dep in ipairs(package:orderdeps()) do
            local fetchinfo = dep:fetch()
            if fetchinfo then
                for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                    table.insert(cppflags, "-I" .. includedir)
                end
                for _, linkdir in ipairs(fetchinfo.linkdirs) do
                    table.insert(ldflags, "-L" .. linkdir)
                end
                for _, link in ipairs(fetchinfo.links) do
                    table.insert(ldflags, "-l" .. link)
                end
            end
        end
        import("package.tools.autoconf").install(package, configs, {cppflags = cppflags, ldflags = ldflags})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("dc1394_new", {includes = "dc1394/dc1394.h"}))
    end)
