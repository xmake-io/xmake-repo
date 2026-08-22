package("libnl")
    set_homepage("https://www.infradead.org/~tgr/libnl/")
    set_description("Netlink Library Suite")
    set_license("LGPL-2.1")

    add_urls("https://github.com/thom311/libnl/releases/download/$(version).tar.gz", {
        version = function (version)
            -- libnl3_12_0/libnl-3.12.0
            return format("libnl%s/libnl-%s", version:gsub("%.", "_"), version)
        end})
    add_urls("https://github.com/thom311/libnl.git", {alias = "git"})

    add_versions("3.12.0", "fc51ca7196f1a3f5fdf6ffd3864b50f4f9c02333be28be4eeca057e103c0dd18")

    add_versions("git:3.12.0", "libnl3_12_0")

    add_includedirs("include", "include/libnl3")

    add_syslinks("pthread")

    add_deps("flex", "bison", {kind = "binary"})

    on_install("linux", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("nl_socket_alloc", {includes = "netlink/socket.h"}))
    end)
