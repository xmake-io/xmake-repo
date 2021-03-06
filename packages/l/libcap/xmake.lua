package("libcap")

    set_homepage("https://sites.google.com/site/fullycapable/")
    set_description("User-space interfaces to POSIX 1003.1e capabilities")

    set_urls("https://mirrors.edge.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-$(version).tar.xz")
    add_versions("2.27", "dac1792d0118bee6aae6ba7fb93ff1602c6a9bda812fd63916eee1435b9c486a")

    on_install("linux", function (package)
        os.vrunv("make", {"install", "prefix=" .. package:installdir(), "lib=lib", "RAISE_SETFCAP=no"})
    end)

    on_test(function (package)
        assert(package:has_cfuncs("cap_init", {includes = "sys/capability.h"}))
    end)
