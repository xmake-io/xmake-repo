package("wfrest")
    set_homepage("https://github.com/wfrest/wfrest")
    set_description("wfrest: C++ Web Framework REST API")
    set_license("Apache-2.0")

    add_urls("https://github.com/wfrest/wfrest/archive/refs/tags/$(version).tar.gz",
             "https://github.com/wfrest/wfrest.git")

    add_versions("v0.9.3", "805dd1534dc68e8484abbf67127caae43f420dbbac0f0cd766d009ccb657a601")

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
        using namespace wfrest;
        int main()
        {
            HttpServer svr;

            svr.GET("/hello", [](const HttpReq *req, HttpResp *resp)
            {
                resp->String("world\n");
            });

            if (svr.start(8888) == 0)
            {
                getchar();
                svr.stop();
            } else
            {
                fprintf(stderr, "Cannot start server");
                exit(1);
            }
            return 0;
        }
    ]]}, {configs = {languages = "c++11"}}))
    end)
