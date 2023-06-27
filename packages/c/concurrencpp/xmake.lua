package("concurrencpp")
    set_homepage("https://github.com/David-Haim/concurrencpp")
    set_description("Modern concurrency for C++. Tasks, executors, timers and C++20 coroutines to rule them all")
    set_license("MIT")

    add_urls("https://github.com/David-Haim/concurrencpp/archive/refs/tags/$(version).tar.gz", {version = function (version)
        return "v." .. version
    end})
    add_urls("https://github.com/David-Haim/concurrencpp.git")
    add_versions("0.1.5", "330150ebe11b3d30ffcb3efdecc184a34cf50a6bd43b68e294a496225d286651")
    add_versions("0.1.6", "e7d5c23a73ff1d7199d361d3402ad2a710dfccf7630b622346df94a7532b4221")

    add_deps("cmake")

    if is_plat("windows") then
        add_syslinks("synchronization", "ws2_32", "mswsock")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    on_load(function (package)
        package:add("includedirs", "include/concurrencpp-" .. package:version_str())
    end)

    on_install("macosx", "windows", function (package)
        assert(package:has_tool("cxx", "clang", "cl"), "compiler not supported!")
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "concurrencpp/concurrencpp.h"
            #include <iostream>
            void test() {
                concurrencpp::runtime runtime;
                auto result = runtime.thread_executor()->submit([] {
                    std::cout << "hello world" << std::endl;
                });
                result.get();
            }
        ]]}, {configs = {languages = "c++20"}}))
    end)
