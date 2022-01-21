package("workflow")
    set_homepage("https://github.com/sogou/workflow")
    set_description("C++ Parallel Computing and Asynchronous Networking Engine")
    set_license("Apache-2.0")

    add_urls("https://github.com/sogou/workflow.git")
    add_versions("v0.9.9", "90cab0cb9a7567ac56a39ae2361d2dc1f4c3ee7b")

    add_configs("kafka", {description = "Use kafka protocol", default = false})

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
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        if package:is_plat("android") then
            io.replace("src/CMakeLists.txt", "add_subdirectory(client)", "add_subdirectory(client)\nlink_libraries(ssl crypto)", {plain = true})
        end
        import("package.tools.cmake").install(package, configs, {packagedeps = "openssl"})
        if package:config("shared") then
            os.tryrm(path.join(package:installdir("lib"), "*.a"))
        else
            os.tryrm(path.join(package:installdir("lib"), "*.so"))
            os.tryrm(path.join(package:installdir("lib"), "*.dylib"))
        end
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
