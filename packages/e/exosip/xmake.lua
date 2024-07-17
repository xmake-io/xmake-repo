package("exosip")
    set_homepage("https://savannah.nongnu.org/projects/exosip")
    set_description("eXosip is a library that hides the complexity of using the SIP protocol for mutlimedia session establishement")
    set_license("GPL-2.0")

    add_urls("https://git.savannah.nongnu.org/cgit/exosip.git/snapshot/exosip-$(version).tar.gz",
             "git://git.savannah.gnu.org/exosip.git")

    add_versions("5.3.0", "66c2b2ddcfdc8807054fa31f72a6068ef66d98bedd9aedb25b9031718b9906a2")

    add_deps("osip")

    on_install(function (package)
        local configs = {}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
          assert(package:has_cincludes("eXosip2/eXosip.h"))
    end)
