package("libcoro")
    set_homepage("https://github.com/jbaldwin/libcoro")
    set_description("C++20 coroutine library")
    set_license("Apache-2.0")

    add_urls("https://github.com/jbaldwin/libcoro/archive/refs/tags/$(version).tar.gz",
             "https://github.com/jbaldwin/libcoro.git", {submodules = false})

    add_versions("v0.15.0", "9538281c742ca59c028052ad150d0e7ff688b8a724532dea95e74966b90d70c2")
    add_versions("v0.14.1", "0a18058fe17826237a868e3d266960e839db8c7aeeb2beba9b596c84124afe0e")
    add_versions("v0.14.0", "baf4b1535dee94bf47d3901b7e4842cedead5828ce7583e9a30ff8c5a8e0eb6e")
    add_versions("v0.13.0", "aea5e4f4c04ef01269cc4e40ce9e693f71e324574ea0a933d908783ef385f9f5")
    add_versions("v0.12.1", "2cb6f45fc73dad6008cc930d92939785684835e03b12df422b98fcab9e393add")

    add_patches("v0.14.1", "patches/v0.14.1.patch", "bd5892560831ec322409ed9af82466ae523d967c1c80ca77c66bc9b64a4b54c7")
    add_patches("v0.14.0", "patches/v0.14.0.patch", "bd5892560831ec322409ed9af82466ae523d967c1c80ca77c66bc9b64a4b54c7")
    add_patches("v0.13.0", "patches/v0.13.0.patch", "bd5892560831ec322409ed9af82466ae523d967c1c80ca77c66bc9b64a4b54c7")

    if not is_plat("windows", "wasm") then
        add_configs("networking", {description = "Include networking features", default = false, type = "boolean"})
        add_configs("tls", {description = "Include TLS encryption features", default = false, type = "boolean"})
    end

    add_deps("cmake")

    on_check(function (package)
        assert(package:check_cxxsnippets({test = [[
            #if defined(__clang__)
            #  if __clang_major__ < 16
            #      error "package(libcoro): Clang version too low, need at least 16.0.0"
            #  endif
            #endif
        ]]}, {configs = {languages = "c++20"}}), "package(libcoro): Clang version too low, need at least 16.0.0")
        assert(package:check_cxxsnippets({test = [[
            #if defined(__GNUC__) && !defined(__clang__)
            #  if (__GNUC__ < 10) || (__GNUC__ == 10 && (__GNUC_MINOR__ < 2))
            #      error "package(libcoro): GCC version too low, need at least 10.2.0"
            #  endif
            #endif
        ]]}, {configs = {languages = "c++20"}}), "package(libcoro): GCC version too low, need at least 10.2.0")
        assert(package:check_cxxsnippets({test = [[
            #if __has_include(<version>)
            #include <version>
            #  ifndef __cpp_lib_jthread
            #      error "package(libcoro): Feature-test macro for jthread missing in <version>"
            #  endif
            #endif
        ]]}, {configs = {languages = "c++20"}}), "package(libcoro): Feature-test macro for jthread missing in <version>")
    end)

    on_load(function (package)
        if package:config("networking") then
            package:add("deps", "c-ares")
        end
        if package:config("tls") then
            package:add("deps", "openssl")
        end
        if not package:config("shared") then
            package:add("defines", "CORO_STATIC_DEFINE")
        end
    end)

    on_install("!android", function (package)
        if package:has_tool("cxx", "gcc", "gxx") then
            package:add("cxxflags", "-fcoroutines")
            package:add("cxxflags", "-fconcepts")
            package:add("cxxflags", "-fexceptions")
        elseif package:has_tool("cxx", "clang", "clangxx") then
            package:add("cxxflags", "-fexceptions")
        end
        local configs = {
            "-DLIBCORO_EXTERNAL_DEPENDENCIES=ON",
            "-DLIBCORO_BUILD_TESTS=OFF",
            "-DLIBCORO_BUILD_EXAMPLES=OFF",
        }
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DLIBCORO_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCORO_FEATURE_NETWORKING=" .. (package:config("networking") and "ON" or "OFF"))
        table.insert(configs, "-DLIBCORO_FEATURE_TLS=" .. (package:config("tls") and "ON" or "OFF"))
        local opt = {}
        if package:is_plat("mingw") and package:config("shared") then
            opt.shflags = "-Wl,--export-all-symbols"
        end
        import("package.tools.cmake").install(package, configs, opt)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            void test() {
                auto make_task_inline = [](uint64_t x) -> coro::task<uint64_t> { co_return x + x; };
                auto result = coro::sync_wait(make_task_inline(5));
            }
        ]]}, {configs = {languages = "c++20"}, includes = "coro/coro.hpp"}))
    end)
