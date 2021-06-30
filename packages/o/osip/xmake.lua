package("osip")

    set_homepage("http://www.gnu.org/software/osip/")
    set_description("A LGPL implementation of SIP")

    add_urls("https://mirrors.aliyun.com/gnu/osip/libosip2-$(version).tar.gz",
             "http://ftp.gnu.org/gnu/osip/libosip2-$(version).tar.gz")
    add_versions("5.2.1", "2bc0400f21a64cf4f2cbc9827bf8bdbb05a9b52ecc8e791b4ec0f1f9410c1291")
    add_versions("5.1.2", "2bc0400f21a64cf4f2cbc9827bf8bdbb05a9b52ecc8e791b4ec0f1f9410c1291")

    add_configs("configs", {description = "Configs for this library.", default = "", type = "string"})

    on_install("linux", "macosx", function (package)
        local confs = {}
        string.gsub(package:config("configs"), '[^ ]+', function(w)
            table.insert(confs, w)
        end)
        import("package.tools.autoconf").install(package, confs)
    end)

    on_test(function (package)
        assert(package:check_csnippets({test = [[
            #include <stdlib.h>
            #include <time.h>
            #include <osipparser2/osip_port.h>
            #include <osip2/osip.h>

            static void test() {
                osip_t *p = NULL;
                int ret = osip_init(&p);
                if (ret == OSIP_SUCCESS) {
                    osip_release(p);
                    p = NULL;
                }
            }
        ]]}))
    end)
