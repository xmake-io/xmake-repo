package("linux-headers")

    set_homepage("https://kernel.org/")
    set_description("Header files of the Linux kernel")
    set_license("GPL-2.0-only")

    add_urls("https://mirror.bjtu.edu.cn/kernel/linux/kernel/$(version).tar.xz",
             "https://mirrors.edge.kernel.org/pub/linux/kernel/$(version).tar.xz",
             "https://cdn.kernel.org/pub/linux/kernel/$(version).tar.xz",
             {version = function (version)
                 return "v" .. version:major() .. ".x/linux-" .. version
             end})
    add_versions("4.20.9", "b5de28fd594a01edacd06e53491ad0890293e5fbf98329346426cf6030ef1ea6")
    add_versions("5.0.8",  "11908044e8cce1e093141f8da594708d45d05d0381676ae9aa3d8aeaf7c85435")
    add_versions("5.9.16", "b0d7abae88e5f91893627c645e680a95c818defd1b4fcaf3e2afb4b2b6b4ab86")
    add_versions("5.10.46", "569122a39c6b325befb9ac1c07da0c53e6363b3baacd82081d131b06c1dc1415")
    add_versions("5.16.9", "1660e7228ec299c187c19739d115ded97f6b1be05a24986c4c443e7c5e8b744f")
    add_versions("5.15", "57b2cf6991910e3b67a1b3490022e8a0674b6965c74c12da1e99d138d1991ee8")

    add_configs("driver_modules", {description = "Enable driver modules files.", default = false, type = "boolean"})

    on_load(function (package)
        if package:config("driver_modules") then
            package:add("deps", "flex", "bison", "bc", "pkg-config")
            package:add("deps", "openssl", "elfutils", {private = true, host = true})
        else
            package:add("deps", "rsync")
        end
    end)

    on_fetch(function (package, opt)
        if opt.system and not package:is_cross() then
            import("lib.detect.find_path")
            local linux_headersdir = find_path("include/linux", "/usr/src/linux-headers-*")
            if linux_headersdir then
                -- parse version, linux-headers-5.11.0-41-generic, linux-headers-5.11.0-41
                local version = path.filename(linux_headersdir):match("linux%-headers%-(%d+%.%d+%.%d+).*")
                return {includedirs = path.join(linux_headersdir, "include"), version = version}
            end
        end
    end)

    on_install("linux", "cross", function (package)
        import("package.tools.make")
        if package:config("driver_modules") then
            local installdir = package:installdir()
            os.cp("*", installdir)
            if package:is_plat("cross") then
                local arch
                if package:is_arch("arm", "armv7") then
                    arch = "arm"
                elseif package:is_arch("arm64", "arm64-v8a") then
                    arch = "arm64"
                elseif package:is_arch("mips") then
                    arch = "mips"
                elseif package:is_arch("ppc", "powerpc", "ppc64", "powerpc64") then
                    arch = "powerpc"
                end
                assert(arch, "unknown arch(%s)!", package:arch())
                local cc = package:tool("cc")
                local cross = cc:gsub("%-gcc$", "-")
                make.make(package, {"ARCH=" .. arch, "CROSS_COMPILE=" .. cross, "allyesconfig"}, {curdir = installdir})
                make.make(package, {"ARCH=" .. arch, "CROSS_COMPILE=" .. cross, "modules_prepare"}, {curdir = installdir})
            else
                make.make(package, {"allyesconfig"}, {curdir = installdir})
                make.make(package, {"modules_prepare"}, {curdir = installdir})
            end
            os.rm(path.join(installdir, "source"))
        else
            os.vrunv("make", {"headers_install", "INSTALL_HDR_PATH=" .. package:installdir()})
        end
    end)

    on_test(function (package)
        assert(package:has_cincludes("linux/version.h"))
    end)
