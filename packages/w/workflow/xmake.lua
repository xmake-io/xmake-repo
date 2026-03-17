package("workflow")
    set_homepage("https://github.com/sogou/workflow")
    set_description("C++ Parallel Computing and Asynchronous Networking Framework")
    set_license("Apache-2.0")

    add_urls("https://github.com/sogou/workflow/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sogou/workflow.git")
    
    add_versions("v1.0.0", "e163bcdde05e5bf0708d44995a7b8579a947acb8fef9a26e3b6da9b6df63e822")
    add_versions("v0.11.11", "5b526cdd6c2c38c89b1966afca481b54b1342ac1f53b150f2ca0353659ac7efa")
    add_versions("v0.10.6", "5701ef31518a7927e61b26cd6cc1d699cb43393bf1ffc77fa61e73e64d2dd28e")
    add_versions("v0.10.7", "aa9806983f32174597549db4a129e2ee8a3d1f005923fcbb924906bc70c0e123")
    add_versions("v0.10.8", "bb5654e8011822d4251a7a433cbe4c5ecfd2c65c8f997a8196685742d24bcaf0")
    add_versions("v0.10.9", "10f695aeb5da87ae138e3bcd2fa10c18aac782b0da20f11b2fd0b7b091d06767")
    add_versions("v0.11.1", "06968ed4e43f6676811b620d09eb5c32ac57252305e7e28def6efde8ef1ceb19")
    add_versions("v0.11.2", "cc2d18ab2b292e2f0163ef67ef6976912e2a21c271396da0e2151ca8cd22abd3")
    add_versions("v0.11.3", "af7adcdd8151f8e72247599a43c28aa849d61ed39e58058cfa80649d011575bc")
    add_versions("v0.11.4", "844fd03db120141fa61600b26a4ef35716dc0e75d1e8c8018078eb385cf746a4")
    add_versions("v0.11.9", "3592c56fd06f08274510c222786ba259e8cce78573d89d22f1e4356bf33fbf77")

    add_deps("openssl")

    if is_plat("windows") then
        add_deps("cmake")
        add_syslinks("Mswsock")
    end

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
