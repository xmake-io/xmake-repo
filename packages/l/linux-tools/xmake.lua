package("linux-tools")

    set_kind("binary")
    set_homepage("https://kernel.org/")
    set_description("Tools of the Linux kernel")
    set_license("GPL-2.0-only")

    add_urls("https://cdn.kernel.org/pub/linux/kernel/$(version).tar.xz",
             "https://mirrors.edge.kernel.org/pub/linux/kernel/$(version).tar.xz",
             {version = function (version)
                 return "v" .. version:major() .. ".x/linux-" .. version
             end})
    add_versions("4.20.9", "b5de28fd594a01edacd06e53491ad0890293e5fbf98329346426cf6030ef1ea6")
    add_versions("5.0.8",  "11908044e8cce1e093141f8da594708d45d05d0381676ae9aa3d8aeaf7c85435")
    add_versions("5.9.16", "b0d7abae88e5f91893627c645e680a95c818defd1b4fcaf3e2afb4b2b6b4ab86")
    add_versions("5.16.9", "1660e7228ec299c187c19739d115ded97f6b1be05a24986c4c443e7c5e8b744f")
    add_versions("5.19.1", "f4e27b926ea2c66b808db1f5706254cf92a8899e2108eedb0c3a7d12499aea55")

    add_configs("bpftool",     { description = "Enable bpftool.", default = true, type = "boolean"})

    local modules = {"bpftool"}

    on_load(function (package)
        for _, name in ipairs(modules) do
            if package:config(name) then
                import("modules." .. name).load(package)
            end
        end
    end)

    on_install("linux", function (package)
        for _, name in ipairs(modules) do
            if package:config(name) then
                local oldir = os.curdir()
                import("modules." .. name).install(package)
                os.cd(oldir)
            end
        end
    end)

    on_test(function (package)
        for _, name in ipairs(modules) do
            if package:config(name) then
                import("modules." .. name).test(package)
            end
        end
    end)
