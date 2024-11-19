package("libcoro")
    set_homepage("https://github.com/jbaldwin/libcoro")
    set_description("C++20 coroutine library")
    set_license("Apache-2.0")

    add_urls("https://github.com/jbaldwin/libcoro/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jbaldwin/libcoro.git", {submodules = false})

    add_versions("v0.12.1", "2cb6f45fc73dad6008cc930d92939785684835e03b12df422b98fcab9e393add")

    if is_plat("windows", "wasm") then
        add_configs("networking", {description = "Include networking features", default = false, type = "boolean", readonly = true})
        add_configs("tls", {description = "Include TLS encryption features", default = false, type = "boolean", readonly = true})
    else
        add_configs("networking", {description = "Include networking features", default = false, type = "boolean"})
        add_configs("tls", {description = "Include TLS encryption features", default = false, type = "boolean"})
    end

    add_deps("cmake")

    on_load(function (package)
        if package:config("networking") then
            package:add("deps", "c-ares")
        end
        if package:config("tls") then
            package:add("deps", "openssl")
        end
    end)

    on_install(function (package)
        local configs = {
            "-DLIBCORO_EXTERNAL_DEPENDENCIES=ON",
            "-DLIBCORO_BUILD_TESTS=OFF",
            "-DLIBCORO_BUILD_EXAMPLES=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DLIBCORO_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCORO_FEATURE_NETWORKING=" .. (package:config("networking") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCORO_FEATURE_TLS=" .. (package:config("tls") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)

        if package:is_plat("windows") and package:is_debug() then
            local dir = package:installdir(package:config("shared") and "bin" or "lib")
            os.vcp(path.join(package:buildir(), "libcoro.pdb"), dir)
        end
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto make_task_inline = [](uint64_t x) -> coro::task<uint64_t> { co_return x + x; };
                auto result = coro::sync_wait(make_task_inline(5));
            }
        ]]}, {configs = {languages = "c++20"}, includes = "coro/coro.hpp"}))
    end)
