package("nettle")

    set_homepage("https://www.lysator.liu.se/~nisse/nettle/")
    set_description("Nettle is a cryptographic library that is designed to fit easily in more or less any context.")
    set_license("LGPL-3.0")

    add_urls("https://ftpmirror.gnu.org/gnu/nettle/nettle-$(version).tar.gz",
             "https://ftp.gnu.org/gnu/nettle/nettle-$(version).tar.gz")
    add_versions("3.6", "d24c0d0f2abffbc8f4f34dcf114b0f131ec3774895f3555922fe2f40f3d5e3f1")
    add_versions("3.9.1", "ccfeff981b0ca71bbd6fbcb054f407c60ffb644389a5be80d6716d5b550c6ce3")

    add_deps("m4")
    if is_plat("linux") then
        add_extsources("apt::nettle-dev")
    end

    on_install("macosx", "linux", function (package)
        local configs = {"--disable-openssl", "--disable-documentation", "--enable-pic"}
        if package:config("shared") then
            table.insert(configs, "--enable-shared")
            table.insert(configs, "--disable-static")
        else
            table.insert(configs, "--disable-shared")
            table.insert(configs, "--enable-static")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("sha1_init", {includes = "nettle/sha1.h"}))
    end)
