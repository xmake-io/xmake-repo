package("workflow")
    set_homepage("https://github.com/sogou/workflow")
    set_description("C++ Parallel Computing and Asynchronous Networking Engine")
    set_license("Apache-2.0")

    add_urls("https://github.com/sogou/workflow/archive/refs/tags/$(version).tar.gz",
             "https://github.com/sogou/workflow.git")
    add_versions("v0.9.9", "309775e74e9f22bead08147380be4a69072e8f603d7216992f5b73510643cbe1")

    add_configs("kafka", {description = "Use kafka protocol", default = false})
    add_configs("shared", {description = "Build shared library.", default = false, type = "boolean", readonly = true})

    add_deps("cmake", "openssl")

    if is_plat("linux") then
        add_syslinks("pthread", "dl")
    end

    on_load(function(package)
        if package:config("kafka") then
            package:add("deps", "lz4", "zstd", "snappy")
        end
    end )

    on_install("linux", "macosx", "android", function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        io.replace("src/CMakeLists.txt", "GROUP ( libworkflow.a AS_NEEDED ( libpthread.so libssl.so libcrypto.so ) ) ", "", {plain = true})
        io.replace("src/CMakeLists.txt", "GROUP ( libwfkafka.a AS_NEEDED ( libpthread.so libssl.so libcrypto.so ) ) ", "", {plain = true})
        import("package.tools.cmake").install(package, configs, {packagedeps = "openssl"})
        os.tryrm(path.join(package:installdir("lib"),  "*.so"))
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
                server.stop();
            }
        }
    ]]}, {configs = {languages = "c++11"}}))
    end)
