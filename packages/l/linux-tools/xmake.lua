package("linux-tools")

    set_homepage("https://kernel.org/")
    set_description("Tools and libraries of the Linux kernel")
    set_license("GPL-2.0-only")

    add_urls("https://cdn.kernel.org/pub/linux/kernel/$(version).tar.xz",
             "https://mirrors.edge.kernel.org/pub/linux/kernel/$(version).tar.xz",
             {version = function (version)
                 return "v" .. version:major() .. ".x/linux-" .. version
             end})
    add_versions("4.20.9", "b5de28fd594a01edacd06e53491ad0890293e5fbf98329346426cf6030ef1ea6")
    add_versions("5.0.8",  "11908044e8cce1e093141f8da594708d45d05d0381676ae9aa3d8aeaf7c85435")
    add_versions("5.9.16", "b0d7abae88e5f91893627c645e680a95c818defd1b4fcaf3e2afb4b2b6b4ab86")

    add_configs("bpf",     { description = "Enable bpf tools and libraries.", default = true, type = "boolean"})

    on_load(function (package)
        if package:config("bpf") then
            package:add("deps", "libcap", "libelf", "zlib")
            package:addenv("PATH", "sbin")
            if package:is_plat("linux") and package:is_arch("x86_64") then
                package:add("links", "bpf")
                package:add("linkdirs", "lib64")
            end
        end
    end)

    on_install("linux", function (package)
        import("package.tools.make")

        local cflags = {}
        local ldflags = {}
        for _, dep in ipairs(package:orderdeps()) do
            local fetchinfo = dep:fetch()
            if fetchinfo then
                for _, includedir in ipairs(fetchinfo.includedirs or fetchinfo.sysincludedirs) do
                    table.insert(cflags, "-isystem " .. includedir)
                end
                for _, linkdir in ipairs(fetchinfo.linkdirs) do
                    table.insert(ldflags, "-L" .. linkdir)
                end
                for _, link in ipairs(fetchinfo.links) do
                    table.insert(ldflags, "-l" .. link)
                end
            end
        end

        local configs = {}
        table.insert(configs, "EXTRA_CFLAGS=" .. table.concat(cflags, " "))
        table.insert(configs, "LDFLAGS=" .. table.concat(ldflags, " "))

        if package:config("bpf") then
            local oldir = os.cd("tools/bpf/bpftool")
            io.replace("Makefile", "prefix ?= /usr/local", "prefix ?= " .. package:installdir(), {plain = true})
            io.replace("Makefile", "bash_compdir ?= /usr/share", "bash_compdir ?= " .. package:installdir("share"), {plain = true})
            make.build(package, configs)
            os.vrunv("make", table.join("install", configs))
            os.cd("../../lib/bpf")
            io.replace("Makefile", "prefix ?= /usr/local", "prefix ?= " .. package:installdir(), {plain = true})
            os.vrunv("make", table.join("install", configs))
            os.cd(oldir)
        end
    end)

    on_test(function (package)
        if package:config("bpf") then
            assert(package:has_cfuncs("bpf_object__open", {includes = "bpf/libbpf.h"}))
            os.vrun("bpftool --version")
        end
    end)
