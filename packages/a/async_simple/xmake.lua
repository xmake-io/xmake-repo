package("async_simple")
    set_homepage("https://github.com/alibaba/async_simple")
    set_description("Simple, light-weight and easy-to-use asynchronous components")
    set_license("Apache-2.0")

    add_urls("https://github.com/alibaba/async_simple/archive/refs/tags/$(version).tar.gz",
             "https://github.com/alibaba/async_simple/archive/refs/tags/v$(version).tar.gz",
             "https://github.com/alibaba/async_simple.git")

    add_versions("1.1", "32d1ea16dfc1741206b6e4a3fbe532eeb1c378619766c1abe11a9efc53109c10")
    add_versions("1.2", "a59a2674ac2b0a3997b90873b2bf0fbe4d96fdedbe6a2628c16c92a65a3fa39a")
    add_versions("1.3", "0ba0dc3397882611b538d04b8ee6668b1a04ce046128599205184c598b718743")

    add_configs("aio", {description = "default not open aio", default = false, type = "boolean"})
    add_configs("modules", {description = "default not use modules", default = false, type = "boolean"})

    add_deps("cmake")

    on_load("windows", function (package)
        package:set("kind", "library", {headeronly = true})
    end)

    on_install("windows", "linux", "macosx", function (package)
        if package:version():le("1.3") then
            io.replace("async_simple/CMakeLists.txt",
            [[file(GLOB coro_header "coro/*.h")]],
            "file(GLOB coro_header \"coro/*.h\")\nfile(GLOB executors_header \"executors/*.h\")", {plain = true})
        end

        local configs = {
            "-DASYNC_SIMPLE_ENABLE_TESTS=OFF",
            "-DASYNC_SIMPLE_BUILD_DEMO_EXAMPLE=OFF"
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DASYNC_SIMPLE_DISABLE_AIO=" .. (package:config("aio") and "OFF" or "ON"))
        table.insert(configs, "-DASYNC_SIMPLE_BUILD_MODULES=" .. (package:config("modules") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
        if package:config("shared") then
            os.rm(package:installdir("lib/libasync_simple.a"))
        else
            os.rm(package:installdir("lib/*.so*"))
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
