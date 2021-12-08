package("linux-headers")

    set_homepage("https://kernel.org/")
    set_description("Header files of the Linux kernel")
    set_license("GPL-2.0-only")

    add_urls("https://cdn.kernel.org/pub/linux/kernel/$(version).tar.xz",
             "https://mirrors.edge.kernel.org/pub/linux/kernel/$(version).tar.xz",
             {version = function (version)
                 return "v" .. version:major() .. ".x/linux-" .. version
             end})
    add_versions("4.20.9", "b5de28fd594a01edacd06e53491ad0890293e5fbf98329346426cf6030ef1ea6")
    add_versions("5.0.8",  "11908044e8cce1e093141f8da594708d45d05d0381676ae9aa3d8aeaf7c85435")
    add_versions("5.9.16", "b0d7abae88e5f91893627c645e680a95c818defd1b4fcaf3e2afb4b2b6b4ab86")
    add_versions("5.10.46", "569122a39c6b325befb9ac1c07da0c53e6363b3baacd82081d131b06c1dc1415")

    add_configs("driver_modules", {description = "Enable driver modules files.", default = true, type = "boolean"})

    on_load(function (package)
        if package:config("driver_modules") then
            package:add("deps", "flex", "bison", "bc")
        else
            package:add("deps", "rsync")
        end
    end)

    on_install("@linux", function (package)
        if package:config("driver_modules") then
            os.cp("*", package:installdir())
            os.vrunv("make", {"allyesconfig"}, {curdir = package:installdir()})
            -- disable libelf deps
            io.replace(path.join(package:installdir(), ".config"), "CONFIG_UNWINDER_ORC=y", "CONFIG_UNWINDER_ORC=n")
            os.vrunv("make", {"modules_prepare"}, {curdir = package:installdir()})
            os.rm(path.join(package:installdir(), "source"))
        else
            os.vrunv("make", {"headers_install", "INSTALL_HDR_PATH=" .. package:installdir()})
        end
    end)

    on_test(function (package)
        assert(package:has_cincludes("linux/version.h"))
    end)
