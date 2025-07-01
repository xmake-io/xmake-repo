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

    add_patches("v0.14.1", path.join(os.scriptdir(), "patches", "v0.14.1.patch"), "bd5892560831ec322409ed9af82466ae523d967c1c80ca77c66bc9b64a4b54c7")
    add_patches("v0.14.0", path.join(os.scriptdir(), "patches", "v0.14.0.patch"), "bd5892560831ec322409ed9af82466ae523d967c1c80ca77c66bc9b64a4b54c7")
    add_patches("v0.13.0", path.join(os.scriptdir(), "patches", "v0.13.0.patch"), "bd5892560831ec322409ed9af82466ae523d967c1c80ca77c66bc9b64a4b54c7")

    if is_plat("windows", "wasm") then
        add_configs("networking", {description = "Include networking features", default = false, type = "boolean", readonly = true})
        add_configs("tls", {description = "Include TLS encryption features", default = false, type = "boolean", readonly = true})
    else
        add_configs("networking", {description = "Include networking features", default = false, type = "boolean"})
        add_configs("tls", {description = "Include TLS encryption features", default = false, type = "boolean"})
    end

    add_deps("cmake >=3.15")

    on_check(function (package)
        import("core.base.semver")
        os.mkdir("temp")
        os.cd("temp")
        io.writefile("CMakeLists.txt", [[
            cmake_minimum_required(VERSION 3.10)
            project(CompilerVersion LANGUAGES CXX)
            if(${CMAKE_CXX_COMPILER_ID} MATCHES "GNU")
                file(WRITE "${CMAKE_SOURCE_DIR}/gnu_version.txt" "${CMAKE_CXX_COMPILER_VERSION}")
            endif()
            if(${CMAKE_CXX_COMPILER_ID} MATCHES "Clang")
                file(WRITE "${CMAKE_SOURCE_DIR}/clang_version.txt" "${CMAKE_CXX_COMPILER_VERSION}")
            endif()
        ]])
        import("package.tools.cmake").build(package)
        if os.exists("gnu_version.txt") then
            local gnu_version = semver.new(io.readfile("gnu_version.txt"))
            assert(gnu_version:eq("10.2.0") or gnu_version:gt("10.2.0"), "package(libcoro) require gnu compiler 10.2.0 version or newer.")
        elseif os.exists("clang_version.txt") then
            local clang_version = semver.new(io.readfile("clang_version.txt"))
            assert(clang_version:eq("16.0.0") or clang_version:gt("16.0.0"), "package(libcoro) require clang compiler version 16.0.0 or newer")
        end
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

        _, toolname, _ = package:tool("cxx")
        if toolname == "gxx" then
            package:add("cxxflags", "-fcoroutines")
            package:add("cxxflags", "-fconcepts")
            package:add("cxxflags", "-fexceptions")
        elseif toolname == "clangxx" then
            package:add("cxxflags", "-fexceptions")
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

        local opt = {}
        if package:is_plat("mingw") and package:config("shared") then
            opt.shflags = "-Wl,--export-all-symbols"
        end
        import("package.tools.cmake").install(package, configs, opt)

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
