package("numactl")
    set_homepage("https://github.com/numactl/numactl")
    set_description("NUMA support for Linux")
    set_license("LGPL-2.1")

    add_urls("https://github.com/numactl/numactl/releases/download/v$(version)/numactl-$(version).tar.gz",
             "https://github.com/numactl/numactl.git")

    add_versions("2.0.19", "f2672a0381cb59196e9c246bf8bcc43d5568bc457700a697f1a1df762b9af884")
    add_versions("2.0.18", "b4fc0956317680579992d7815bc43d0538960dc73aa1dd8ca7e3806e30bc1274")
    add_versions("2.0.14", "826bd148c1b6231e1284e42a4db510207747484b112aee25ed6b1078756bcff6")

    add_extsources("apt::libnuma-dev")

    add_syslinks("dl", "pthread")

    on_install("linux", function (package)
        package:addenv("PATH", "bin")

        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        if not package:is_cross() then
            os.vrun("numactl --version")
        end
        assert(package:has_cfuncs("numa_available", {includes = "numa.h"}))
    end)
