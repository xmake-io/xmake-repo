package("eudev")
    set_homepage("https://github.com/eudev-project/eudev")
    set_description("A fork of systemd with the aim of isolating udev from any particular flavor of system initialization.")
    set_license("GPL-2.0")

    add_urls("https://github.com/eudev-project/eudev/archive/refs/tags/$(version).tar.gz",
             "https://github.com/eudev-project/eudev.git")

    add_versions("v3.2.14", "c340e6c51dfc5531ac0c0fa84a34b72162acf525f9023eb9cf4931b782c8f177")
    add_versions("v3.2.9", "7d281276b480da3935d1acb239748c2c9db01a8043aad7e918ce57a223d8cd24")

    add_deps("autotools", "pkg-config", "gperf")

    on_install("linux", "cross", function (package)
        local configs = {}
        if package:config("shared") then
            table.insert(configs, "--enable-shared=yes")
        else
            table.insert(configs, "--enable-shared=no")
        end
        if package:config("pic") then
            table.insert(configs, "--with-pic")
        end
        import("package.tools.autoconf").install(package, configs)
    end)


    on_test(function (package)
        assert(package:has_cfuncs("udev_new", {includes = "libudev.h"}))
    end)
