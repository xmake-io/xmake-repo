package("async_simple")

    set_homepage("https://github.com/alibaba/async_simple")
    set_description("Simple, light-weight and easy-to-use asynchronous components")
    set_license("Apache-2.0")

    add_urls("https://github.com/alibaba/async_simple/archive/refs/tags/$(version).tar.gz",
             "https://github.com/alibaba/async_simple.git")
    add_versions("1.1", "32d1ea16dfc1741206b6e4a3fbe532eeb1c378619766c1abe11a9efc53109c10")

    add_configs("aio", {description = "default not open aio", default = false, type = "boolean"})
    add_configs("modules", {description = "default not use modules", default = false, type = "boolean"})

    add_deps("cmake")

    on_install("windows", "linux", "macosx", function (package)
        local configs = {"-DASYNC_SIMPLE_ENABLE_TESTS=OFF",
                        "-DASYNC_SIMPLE_BUILD_DEMO_EXAMPLE=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:debug() and "Debug" or "Release"))
        table.insert(configs, "-DASYNC_SIMPLE_DISABLE_AIO=" .. (package:config("aio") and "OFF" or "ON"))
        table.insert(configs, "-DASYNC_SIMPLE_BUILD_MODULES=" .. (package:config("modules") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        if package:config("shared") then
            os.rm(package:installdir("lib/libasync_simple.a"))
        else
            os.rm(package:installdir("lib/libasync_simple.so"))
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include <async_simple/coro/Lazy.h>
            async_simple::coro::Lazy<void> func() {
                co_return;
            }
            void test() {
                async_simple::coro::syncAwait(func());
            }
        ]]}, {configs = {languages = "c++20"}, includes = {"async_simple/coro/Lazy.h", "async_simple/coro/SyncAwait.h"}}))
    end)
