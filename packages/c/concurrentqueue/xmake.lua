package("concurrentqueue")
    set_homepage("https://github.com/cameron314/concurrentqueue")
    set_description("A fast multi-producer, multi-consumer lock-free concurrent queue for C++11")
    set_license("BSD")

    add_urls("https://github.com/cameron314/concurrentqueue/archive/refs/tags/$(version).tar.gz",
             "https://github.com/cameron314/concurrentqueue.git")

    add_versions("v1.0.4", "87fbc9884d60d0d4bf3462c18f4c0ee0a9311d0519341cac7cbd361c885e5281")

    add_configs("c_api", {description = "Build C API", default = false, type = "boolean"})

    add_deps("cmake")

    add_includedirs("include", "include/concurrentqueue/moodycamel")

    on_load(function (package)
        if not package:config("c_api") then
            package:set("kind", "library", {headeronly = true})
        end
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        io.writefile(path.join(package:installdir("include"), "concurrentqueue", "concurrentqueue.h"), [[
#pragma once

#pragma message please update include <concurrentqueue/concurrentqueue.h> to <concurrentqueue.h>
#include "moodycamel/concurrentqueue.h"
        ]])

        if package:config("c_api") then
            io.writefile("xmake.lua", [[
                add_rules("mode.debug", "mode.release")
                target("concurrentqueue-c")
                    set_kind("$(kind)")
                    add_files("c_api/*.cpp")
                    add_headerfiles("(c_api/concurrentqueue.h)")
                    if is_plat("windows") and is_kind("shared") then
                        add_defines("DLL_EXPORT")
                    end
            ]])
            import("package.tools.xmake").install(package)

            if package:is_plat("windows") and (not package:config("shared")) then
                package:add("defines", "MOODYCAMEL_STATIC")
            end
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <concurrentqueue.h>
            void test() {
                moodycamel::ConcurrentQueue<int> q;
                q.enqueue(25);
            }
        ]]}, {configs = {languages = "c++11"}}))
        if package:config("c_api") then
            assert(package:has_cfuncs("moodycamel_cq_create", {includes = "c_api/concurrentqueue.h"}))
        end
    end)
