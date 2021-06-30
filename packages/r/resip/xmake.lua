package("resip")

    set_homepage("https://resiprocate.org/Main_Page")
    set_description("C++ implementation of SIP, ICE, TURN and related protocols.")

    add_urls("https://www.resiprocate.org/files/pub/reSIProcate/releases/resiprocate-$(version).tar.gz")
    add_versions("1.12.0", "ec54724ff7967a6056c69e1c692838b59a5b006ceb785b9517a5c496a9a2ca3d")
    add_versions("1.10.2", "2de25691f773383a0a441792c8aad6aeabfe10dd5c0a79836c51e8e8a677b186")

    add_configs("configs", {description = "Configs for this library.", default = "", type = "string"})

    on_install("linux", "macosx", function(package)
        local confs = {}
        string.gsub(package:config("configs"), '[^ ]+', function(w)
            table.insert(confs, w)
        end)
        import("package.tools.autoconf").install(package, confs)
    end)

    on_test(function(package)
        assert(package:check_cxxsnippets({ test = [[
                #include <string>
                #include <resip/dum/DialogUsageManager.hxx>
                #include <resip/stack/SipStack.hxx>

                static void test() {
                    resip::SipStack stack;
                    stack.addTransport(resip::UDP, 0);
                    resip::DialogUsageManager dum(stack);
                }
            ]] }, {configs = {languages = "c++11"}}))
    end)
