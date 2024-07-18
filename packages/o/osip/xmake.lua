package("osip")
    set_homepage("https://savannah.gnu.org/projects/osip")
    set_description("oSIP is an LGPL implementation of SIP. It's stable, portable, flexible and compliant! -may be more-! It is used mostly with eXosip2 stack (GPL) which provides simpler API for User-Agent implementation.")
    set_license("LGPL")

    add_urls("https://git.savannah.gnu.org/cgit/osip.git/snapshot/osip-$(version).tar.gz",
             "https://git.savannah.gnu.org/git/osip.git")

    add_versions("5.3.0", "593c9d61150b230f7e757b652d70d5fe336c84db7e4db190658f9ef1597d59ed")

    add_deps("autoconf", "automake", "m4", "libtool")

    on_install("linux",  "macosx", function (package)
        local configs = {"--disable-trace"}
        if not package:debug() then
            table.insert(configs, "--disable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("osip_cond_signal", {includes = "osip2/osip_condv.h"}))
    end)
