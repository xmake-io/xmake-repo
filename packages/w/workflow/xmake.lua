package("workflow")
    set_homepage("https://github.com/sogou/workflow")
    set_description("C++ Parallel Computing and Asynchronous Networking Engine")
    set_license("Apache-2.0")

    add_configs("kafka",{description="Use kafka protocol", default="false", values={"false","true"}})

    add_urls("https://github.com/sogou/workflow/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sogou/workflow.git")
    add_versions("v0.9.9", "309775e74e9f22bead08147380be4a69072e8f603d7216992f5b73510643cbe1")

    add_deps("cmake", "openssl")

    on_load("linux", "macosx", "windows", "android", function (package)
        local kafka = package:config("kafka") or true
        package:add("deps", "lz4")
        package:add("deps", "zstd")
        package:add("deps", "snappy")
    end)

    on_install("linux", "macosx", "windows", "android", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
        #include <stdio.h>
        #include "workflow/WFHttpServer.h"
        static void test() {
            WFHttpServer server([](WFHttpTask *task) {
                task->get_resp()->append_output_body("<html>Hello World!</html>");
            });
            if (server.start(8888) == 0) {  // start server on port 8888
                getchar(); // press "Enter" to end.
                server.stop();
            }
        }
    ]]}, {configs = {languages = "c++11"}}))
    end)
