package("libnet")
    set_homepage("https://codedocs.xyz/libnet/libnet/")
    set_description("A portable framework for low-level network packet construction")

    add_urls("https://github.com/libnet/libnet/archive/refs/tags/$(version).tar.gz",
             "https://github.com/libnet/libnet.git")
    add_versions("v1.2", "b7a371a337d242c017f3471d70bea2963596bec5bd3bd0e33e8517550e2311ef")

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
