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
    add_versions("0.1.7", "049f3e83ad1828e0b8b518652de1a3160d5849fdff03d521d0a5af0167338e89")

    -- https://github.com/David-Haim/concurrencpp/issues/166
    add_patches("0.1.7", "patches/0.1.7/add-include-string.patch", "a4b8c219fcc913a3cbeda1522c408f4b347e12f11ec130dd7df65504dcdccc09")

    if is_plat("windows") then
        add_syslinks("synchronization", "ws2_32", "mswsock")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread")
    end

    add_deps("cmake")

    on_check(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <semaphore>
            #include <new>
            void test() {
                auto x = std::hardware_destructive_interference_size;
            }
        ]]}, {configs = {languages = "c++20"}}), "package(concurrencpp) Require at least C++20.")
    end)

    on_load(function (package)
        package:add("includedirs", "include/concurrencpp-" .. package:version_str())
        if package:is_plat("windows") and package:config("shared") then
            package:add("defines", "CRCPP_IMPORT_API")
        end
    end)

    on_install(function (package)
        local configs = {}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
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
