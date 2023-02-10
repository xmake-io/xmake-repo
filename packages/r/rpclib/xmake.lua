package("rpclib")
    set_homepage("http://rpclib.net")
    set_description("rpclib is a modern C++ msgpack-RPC server and client library")

    add_urls("https://github.com/rpclib/rpclib/archive/refs/tags/$(version).tar.gz",
             "https://github.com/rpclib/rpclib.git")
    add_versions("v2.3.0", "eb9e6fa65e1a79b37097397f60599b93cb443d304fbc0447c50851bc3452fdef")

    add_deps("cmake")

    if is_plat("windows", "mingw") then
        add_syslinks("wsock32", "ws2_32")
        add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})
    end

    on_install("windows", "mingw", "linux", "macosx", "bsd", "iphoneos", "wasm", "android", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "rpc/client.h"
            #include <iostream>
            void test() {
                rpc::client c("localhost", rpc::constants::DEFAULT_PORT);
                std::string text;
                while (std::getline(std::cin, text)) {
                    if (!text.empty()) {
                        std::string result(c.call("echo", text).as<std::string>());
                        std::cout << "> " <<  result << std::endl;
                    }
                }
            }
        ]]}, {configs = {languages = "c++11"}}))
    end)
