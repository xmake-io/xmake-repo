package("libev")

    set_homepage("http://software.schmorp.de/pkg/libev")
    set_description("Full-featured high-performance event loop loosely modelled after libevent.")

    add_urls("http://dist.schmorp.de/libev/libev-$(version).tar.gz", {alias = "home"})
    add_urls("http://git.lighttpd.net/libev.git/snapshot/libev-rel-$(version).tar.gz", {alias = "mirror"})
    add_urls("https://github.com/enki/libev.git",
             "https://git.lighttpd.net/libev.git")
    add_versions("home:4.24", "973593d3479abdf657674a55afe5f78624b0e440614e2b8cb3a07f16d4d7f821")
    add_versions("mirror:4.24", "680a0a720a3629c3c4738387dfaadd591aa282975167dbab743e453399f75963")

    on_install("macosx", "linux", "iphoneos", function (package)
        import("package.tools.autoconf").install(package)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("ev_loop", {includes = "ev.h"}))
    end)
