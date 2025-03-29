package("wfrest")
    set_homepage("https://github.com/wfrest/wfrest")
    set_description("C++ Web Framework REST API")
    set_license("Apache-2.0")

    add_urls("https://github.com/wfrest/wfrest/archive/refs/tags/$(version).tar.gz",
             "https://github.com/wfrest/wfrest.git")

    add_versions("v0.9.8", "61de0d3fd998562c54ec7a932c503a766d9f269386b28aa3cc8f8180868f58ad")
    add_versions("v0.9.7", "47eaf6feec20bd5d905a69526c0f3905f07e17b442ffff02391a35ce2ac397bf")
    add_versions("v0.9.3", "1bd0047484e81e23c7a8ab7ba41634109169c37d80aeb2c480728214db42878e")
    add_versions("v0.9.4", "1f8811e90e6c89af91db04cab0c37dc86cf4777f4f4713d6003ac0ec1a2471a9")
    add_versions("v0.9.5", "46e4957a5c00c95c85979bbc41807b4c4f2aacc11c43e123039ce440ebecab84")
    add_versions("v0.9.6", "8199e79d8703ad7e8b3c6e546395fb8f0adc302ca1d02b654fd91edb31416854")

    add_deps("openssl", "workflow", "zlib")

    if is_plat("linux") then
        add_syslinks("pthread", "dl")
    end

    on_install("linux", "macosx", "android", "windows", function (package)
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
