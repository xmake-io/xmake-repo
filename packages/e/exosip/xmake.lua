package("exosip")
    set_homepage("https://savannah.nongnu.org/projects/exosip")
    set_description("eXosip is a library that hides the complexity of using the SIP protocol for mutlimedia session establishement")
    set_license("GPL-2.0")

    add_urls("https://git.savannah.nongnu.org/cgit/exosip.git/snapshot/exosip-$(version).tar.gz",
             "git://git.savannah.gnu.org/exosip.git")

    add_versions("5.3.0", "66c2b2ddcfdc8807054fa31f72a6068ef66d98bedd9aedb25b9031718b9906a2")

    add_deps("autoconf", "m4", "libtool", "automake", "osip", "openssl3")
    add_links("eXosip2", "osip2", "osipparser2")

    if is_plat("macosx") then
        add_syslinks("resolv")
        add_frameworks("CoreFoundation")    
        add_deps("pkg-config")
    elseif is_plat("linux") then
        add_syslinks("pthread", "resolv")
    end

    on_check("macosx", function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "TargetConditionals.h"
            #include <CoreFoundation/CoreFoundation.h>
            #include <CoreServices/CoreServices.h>
            #include <Security/Security.h>
            void test() {
                SInt32 osx_version = 0;
                OSErr res = Gestalt(gestaltSystemVersion, &osx_version);
            }
        ]]}))
    end)

    on_install("macosx", "linux", function (package)
        local configs = {"--disable-trace", "--enable-pthread=force"}
        table.insert(configs, "--enable-shared=" .. (package:config("shared") and "yes" or "no"))
        table.insert(configs, "--enable-static=" .. (package:config("shared") and "no" or "yes"))
        if not package:debug() then
            table.insert(configs, "--disable-debug")
        end
        import("package.tools.autoconf").install(package, configs)
    end)

    on_test(function (package)
          assert(package:has_cfuncs("eXosip_lock", {includes = "eXosip2/eXosip.h", "eXosip2.h"}))
    end)
