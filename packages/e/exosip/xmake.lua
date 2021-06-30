package("exosip")

    set_homepage("http://savannah.nongnu.org/projects/exosip/")
    set_description("A library that hides the complexity of using the SIP protocol for mutlimedia session establishement")

    add_urls("http://download.savannah.nongnu.org/releases/exosip/libexosip2-$(version).tar.gz")
    add_versions("5.2.1", "87256b45a406f3c038e1e75e31372d526820366527c2af3bb89329bafd87ec42")
    add_versions("5.1.3", "abdee47383ee0763a198b97441d5be189a72083435b5d73627e22d8fff5beaba")

    add_deps("osip", "c-ares", "openssl")

    add_configs("configs", {description = "Configs for this library.", default = "", type = "string"})

    on_install("linux", "macosx", function (package)
--         local configs = { "--enable-shared",
--                           "--enable-static",
--                           "--enable-mt",
--                           "--enable-openssl" }
--         import("package.tools.autoconf").install(package, configs)
        local confs = {}
        string.gsub(package:config("configs"), '[^ ]+', function(w)
            table.insert(confs, w)
        end)
        import("package.tools.autoconf").install(package, confs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("eXosip_malloc", {includes = "eXosip2/eXosip.h"}))
    end)
