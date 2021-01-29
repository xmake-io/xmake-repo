package("linux-headers")

    set_homepage("https://kernel.org/")
    set_description("Header files of the Linux kernel")
    set_license("GPL-2.0-only")

    add_urls("https://cdn.kernel.org/pub/linux/kernel/$(version).tar.gz",
             "https://mirrors.edge.kernel.org/pub/linux/kernel/$(version).tar.gz",
             {version = function (version)
                 return "v" .. version:major() .. ".x/linux-" .. version
             end})
    add_versions("4.4.80", "291d844619b5e7c43bd5aa0b2c286274fc5ffe31494ba475f167a21157e88186")
    add_versions("4.20.9", "b5de28fd594a01edacd06e53491ad0890293e5fbf98329346426cf6030ef1ea6")
    add_versions("5.9.16", "b0d7abae88e5f91893627c645e680a95c818defd1b4fcaf3e2afb4b2b6b4ab86")

    on_install("linux", function (package)
        os.vrunv("make", {"headers_install", "INSTALL_HDR_PATH=" .. package:installdir()})
    end)

    on_test(function (package)
        assert(package:has_cincludes("linux/version.h"))
    end)
