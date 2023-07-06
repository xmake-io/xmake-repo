package("workflow")
    set_homepage("https://github.com/sogou/workflow")
    set_description("C++ Parallel Computing and Asynchronous Networking Engine")
    set_license("Apache-2.0")

    add_urls("https://github.com/sogou/workflow/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sogou/workflow.git")

    add_versions("v0.10.6", "5701ef31518a7927e61b26cd6cc1d699cb43393bf1ffc77fa61e73e64d2dd28e")
    add_versions("v0.10.7", "aa9806983f32174597549db4a129e2ee8a3d1f005923fcbb924906bc70c0e123")
    add_versions("v0.10.8", "bb5654e8011822d4251a7a433cbe4c5ecfd2c65c8f997a8196685742d24bcaf0")

    add_deps("openssl")

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
        #include <stdio.h>
        #include "workflow/WFHttpServer.h"
        void test() {
            WFHttpServer server([](WFHttpTask *task) {
                task->get_resp()->append_output_body("<html>Hello World!</html>");
            });
            if (server.start(8888) == 0) {  // start server on port 8888
                server.stop();
            }
        }
        ]]}, {configs = {languages = "c++11"}}))
    end)
