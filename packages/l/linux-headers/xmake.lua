package("linux-headers")

    set_homepage("https://kernel.org/")
    set_description("Header files of the Linux kernel")
    set_license("GPL-2.0-only")

    add_urls("https://cdn.kernel.org/pub/linux/kernel/v4.x/linux-$(version).tar.gz")
    add_versions("4.4.80", "291d844619b5e7c43bd5aa0b2c286274fc5ffe31494ba475f167a21157e88186")

    on_install("linux", function (package)
        os.vrunv("make", {"headers_install", "INSTALL_HDR_PATH=" .. package:installdir()})
    end)

    on_test(function (package)
        assert(package:has_cincludes("linux/version.h"))
    end)
