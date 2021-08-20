package("libfabric")

    set_homepage("https://ofiwg.github.io/libfabric/")
    set_description("Open Fabric Interfaces")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/ofiwg/libfabric/releases/download/v$(version)/libfabric-$(version).tar.bz2")
    add_versions("1.13.0", "0c68264ae18de5c31857724c754023351614330bd61a50b40cef2b5e8f63ab28")

    if is_plat("linux") then
        add_syslinks("pthread", "dl", "rt")
        add_extsources("apt::libfabric-dev")
    end

    on_install("macosx", "linux", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if package:config("pic") ~= false then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("fi_getinfo", {includes = "rdma/fabric.h"}))
    end)
