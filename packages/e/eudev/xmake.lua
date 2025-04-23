package("eudev")
    set_homepage("https://github.com/eudev-project/eudev")
    set_description("A fork of systemd with the aim of isolating udev from any particular flavor of system initialization.")
    set_license("GPL-2.0")

    add_urls("https://github.com/eudev-project/eudev/archive/refs/tags/$(version).tar.gz",
             "https://github.com/eudev-project/eudev.git")

    add_versions("v3.2.14", "c340e6c51dfc5531ac0c0fa84a34b72162acf525f9023eb9cf4931b782c8f177")
    add_versions("v3.2.9", "7d281276b480da3935d1acb239748c2c9db01a8043aad7e918ce57a223d8cd24")

    add_configs("kmod", {description = "Enable loadable modules support", default = false, type = "boolean"})
    add_configs("selinux", {description = "Enable optional SELINUX support", default = false, type = "boolean", readonly = true})
    add_configs("tools", {description = "Build tools", default = false, type = "boolean"})

    add_deps("autotools", "pkg-config", "gperf")

    on_load(function (package)
        if package:config("kmod") then
            package:add("deps", "libkmod")
        end
    end)

    on_install("linux", "cross", function (package)
        io.replace("autogen.sh", "./make.sh", "", {plain = true}) --remove doc build
        if package:config("kmod") then
            io.replace("configure.ac", "libkmod >= 15", "libkmod >= v15", {plain = true})
            io.replace("src/udev/udev-builtin-kmod.c", "#include <libkmod.h>", "#include <libkmod/libkmod.h>", {plain = true})
        end

        local configs = {"--disable-manpages"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        table.insert(configs, "--enable-kmod=" .. (package:config("kmod") and "yes" or "no"))
        table.insert(configs, "--enable-selinux=" .. (package:config("selinux") and "yes" or "no"))
        table.insert(configs, "--enable-programs=" .. (package:config("tools") and "yes" or "no"))
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("udev_new", {includes = "libudev.h"}))
    end)
