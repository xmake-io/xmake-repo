package("wfrest")
    set_homepage("https://github.com/wfrest/wfrest")
    set_description("wfrest: C++ Web Framework REST API")
    set_license("Apache-2.0")

    add_urls("https://github.com/wfrest/wfrest/archive/refs/tags/$(version).tar.gz",
             "https://github.com/wfrest/wfrest.git")

    add_versions("v0.9.3", "56a67286b4b8c126fb71d53cf8e06e5a8e84eab8fab637fd29f1288adc7e4b49")

    add_deps("openssl")
    add_deps("workflow")
    add_deps("zlib")

    if is_plat("linux") then
        add_syslinks("pthread", "dl")
    end

    on_install("linux", "macosx", "android", function (package)
        local configs = {}
        if package:config("shared") then
            configs.kind = "shared"
        end
        import("package.tools.xmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
        #include "wfrest/HttpServer.h"
        void test() {
            wfrest::HttpServer svr;
            if (svr.start(8888) == 0)
            {
                svr.stop();
            }
        }
    ]]}, {configs = {languages = "c++11"}}))
    end)
