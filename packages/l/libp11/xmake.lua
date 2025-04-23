package("libp11")
    set_homepage("https://github.com/OpenSC/libp11")
    set_description("PKCS#11 wrapper library")
    set_license("LGPL-2.1")

    add_urls("https://github.com/OpenSC/libp11/archive/refs/tags/libp11-$(version).tar.gz",
             "https://github.com/OpenSC/libp11.git")

    add_versions("0.4.13", "5e8e258c6a8e33155c3a2bd2bd7d12a758f82b7bda1f92e8b77075d16edc9889")

    add_deps("openssl")

    on_install("!wasm and !iphoneos" , function (package)
        os.cp(path.join(package:scriptdir(), "port", "xmake.lua"), "xmake.lua")
        os.cp(path.join(package:scriptdir(), "port", "config.h.in"), "src/config.h.in")
        io.gsub("src/config.h.in", "# ?undef (.-)\n", "${define %1}\n")
        import("package.tools.xmake").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("PKCS11_CTX_new", {includes = "libp11.h"}))
    end)
