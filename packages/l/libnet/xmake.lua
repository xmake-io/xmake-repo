package("libnet")
    set_homepage("https://codedocs.xyz/libnet/libnet/")
    set_description("A portable framework for low-level network packet construction")

    add_urls("https://github.com/libnet/libnet/releases/download/$(version).tar.gz", {version = function (version)
        return version .. "/libnet-" .. (version:gsub("v", ""))
    end})
    add_urls("https://github.com/libnet/libnet.git")

    add_versions("v1.3", "ad1e2dd9b500c58ee462acd839d0a0ea9a2b9248a1287840bc601e774fb6b28f")

    on_load(function (package)
        if package:gitref() then
            package:add("deps", "automake", "autoconf", "libtool")
        end
    end)

    on_install("linux", "macosx", "bsd", function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("libnet_init", {includes = "libnet.h"}))
    end)
