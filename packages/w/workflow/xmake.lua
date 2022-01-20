package("workflow")
    set_homepage("https://github.com/sogou/workflow")
    set_description("C++ Parallel Computing and Asynchronous Networking Engine")
    set_license("Apache-2.0")

    add_urls("https://github.com/sogou/workflow.git")
    add_versions("v0.9.9", "d7d29d68f1e94020f2e31a08e76fa644fd604bd7")

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
        if package:is_plat("android") then 
            local dep = package:dep("openssl")
            if dep then
                local depinfo = dep:fetch()
                if depinfo then
                    for _, linkdir in ipairs(depinfo.linkdirs) do
                        table.insert(configs, "-DOPENSSL_ROOT_DIR=" .. path.join(linkdir, ".."))
                        table.insert(configs, "-DOPENSSL_LIBRARIES=" .. linkdir)
                    end
                    for _, includedir in ipairs(depinfo.includedirs or depinfo.sysincludedirs) do
                        table.insert(configs, "-DOPENSSL_INCLUDE_DIR=" .. includedir)
                    end
                end
            end
        end
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs, {packagedeps = "openssl"})
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
