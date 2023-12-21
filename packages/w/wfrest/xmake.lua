package("wfrest")
    set_homepage("https://github.com/wfrest/wfrest")
    set_description("wfrest: C++ Web Framework REST API")
    set_license("Apache-2.0")

    add_urls("https://github.com/wfrest/wfrest/archive/refs/tags/$(version).tar.gz",
             "https://github.com/wfrest/wfrest.git")

    add_versions("v0.9.3", "1bd0047484e81e23c7a8ab7ba41634109169c37d80aeb2c480728214db42878e")

    add_deps("openssl", "workflow", "zlib")

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
