package("cpp-ipc")
    set_homepage("https://github.com/mutouyun/cpp-ipc")
    set_description("A high-performance inter-process communication using shared memory on Linux/Windows")
    set_license("MIT")

    set_urls("https://github.com/mutouyun/cpp-ipc/archive/refs/tags/$(version).zip",
             "https://github.com/mutouyun/cpp-ipc.git")

    add_versions("v1.3.0", "898f97a36c855a58dfe9645b73c388e6df7bcd3762a5c9a6a75b4bca60d72b4b")
    add_versions("v1.2.0", "31739760d8f191c7aaf71d1c453fce1989d1f74fdee9a61f9fdd475b29fe1888")

    add_deps("cmake")
    if is_plat("windows") then
        add_syslinks("advapi32")
    end

    on_install("windows", "linux", "mingw", "cross", function (package)
        if package:config("shared") then
            package:add("defines", "LIBIPC_LIBRARY_SHARED_USING__")
        end

        local configs = {"-DLIBIPC_BUILD_TESTS=OFF", "-DLIBIPC_BUILD_DEMOS=OFF", "-DLIBIPC_USE_STATIC_CRT=OFF"}
        table.insert(configs, "-DCMAKE_BUILD_TYPE=" .. (package:is_debug() and "Debug" or "Release"))
        table.insert(configs, "-DLIBIPC_BUILD_SHARED_LIBS=" .. (package:config("shared") and "ON" or "OFF"))
        import("package.tools.cmake").install(package, configs)
    end)

    on_test(function (package)
        assert(package:check_cxxsnippets({test = [[
            #include "libipc/ipc.h"
            void test() { ipc::route cc { "my-ipc-route" }; }
        ]]}, {configs = {languages = "c++17"}}))
    end)
