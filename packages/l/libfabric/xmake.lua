package("libfabric")

    set_homepage("https://ofiwg.github.io/libfabric/")
    set_description("Open Fabric Interfaces")
    set_license("BSD-2-Clause")

    add_urls("https://github.com/ofiwg/libfabric/releases/download/v$(version)/libfabric-$(version).tar.bz2")
    add_versions("2.0.0", "1a8e40f1f331d6ee2e9ace518c0088a78c8a838968f8601c2b77fd012a7bf0f5")
    add_versions("1.22.0", "485e6cafa66c9e4f6aa688d2c9526e274c47fda3a783cf1dd8f7c69a07e2d5fe")
    add_versions("1.20.2", "75b89252a0b8b3eae8e60f7098af1598445a99a99e8fc1ff458e2fd5d4ef8cde")
    add_versions("1.20.1", "fd88d65c3139865d42a6eded24e121aadabd6373239cef42b76f28630d6eed76")
    add_versions("1.13.0", "0c68264ae18de5c31857724c754023351614330bd61a50b40cef2b5e8f63ab28")
    add_versions("1.17.0", "579c0f5ef636c0c72f4d3d6bd4da91a5aed9ac3ac4ea387404c45dbbdee4745d")

    if is_plat("linux") then
        add_syslinks("pthread", "dl", "rt", "atomic")
        add_extsources("apt::libfabric-dev", "pacman::libfabric")
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
