package("numactl")

    set_homepage("https://github.com/numactl/numactl")
    set_description("NUMA support for Linux")
    set_license("LGPL-2.1")

    add_urls("https://github.com/numactl/numactl/releases/download/v$(version)/numactl-$(version).tar.gz")
    add_versions("2.0.18", "b4fc0956317680579992d7815bc43d0538960dc73aa1dd8ca7e3806e30bc1274")
    add_versions("2.0.14", "826bd148c1b6231e1284e42a4db510207747484b112aee25ed6b1078756bcff6")

    on_install("linux", function (package)
        import("package.tools.autoconf").install(package)
        package:addenv("PATH", "bin")
    end)

    on_test(function (package)
        os.vrun("numactl -H")
        assert(package:has_cfuncs("numa_available", {includes = "numa.h"}))
    end)
