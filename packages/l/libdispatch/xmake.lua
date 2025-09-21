package("libdispatch")
    set_homepage("swift.org")
    set_description("The libdispatch Project, (a.k.a. Grand Central Dispatch), for concurrency on multicore hardware")
    set_license("Apache-2.0")

    add_urls("https://github.com/swiftlang/swift-corelibs-libdispatch/archive/refs/tags/swift-$(version)-RELEASE.tar.gz")
    add_urls("https://github.com/swiftlang/swift-corelibs-libdispatch.git", {alias = "git"})

    add_versions("6.1.1", "6fc6f8b1767a1348e1d960647b2bfbc52fd7074b7aeab97bd0f4b21af58baa47")

    add_versions("git:6.1.1", "swift-6.1.1-RELEASE")

    add_links("dispatch", "BlocksRuntime")

    if is_plat("windows", "mingw") then
        add_syslinks("shlwapi", "ws2_32", "winmm", "synchronization")
    elseif is_plat("linux", "bsd") then
        add_syslinks("pthread", "rt")
    end

    add_deps("cmake")
    
    on_check(function (package)
        if package:is_plat("windows") then
            if not package:has_tool("cxx", "clang_cl") then
                raise("package(libdispatch) unsupported msvc && clang toolchain, you can use clang-cl toolchain\nadd_requires(\"libdispatch\", {configs = {toolchains = \"clang-cl\"}}))")
            end
        else
            if not package:has_tool("cxx", "clang", "clangxx") then
                raise("package(libdispatch) unsupported gcc toolchain, you can use clang toolchain\nadd_requires(\"libdispatch\", {configs = {toolchains = \"clang\"}}))")
            end
        end
    end)

    on_install(function (package)
        io.replace("CMakeLists.txt", "set(CMAKE_POSITION_INDEPENDENT_CODE YES)", "", {plain = true})
        io.replace("cmake/modules/DispatchCompilerWarnings.cmake", "-Werror", "", {plain = true})

        local configs = {"-DBUILD_TESTING=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DBUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:has_cfuncs("dispatch_get_main_queue", {includes = "dispatch/dispatch.h"}))
    end)
